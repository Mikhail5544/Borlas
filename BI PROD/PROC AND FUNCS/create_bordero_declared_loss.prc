create or replace procedure create_bordero_declared_loss(par_bordero_id in number)
  is
    v_re_claim_header ven_re_claim_header%rowtype;
    v_re_claim        ven_re_claim%rowtype;
    v_re_damage       ven_re_damage%rowtype;
    v_re_line_damage  ven_re_line_damage%rowtype;
    db                date;
    de                date;
    recont            number;
    all_amount_dec    number;
    d_decsum          number;

  begin
    -- удаляем расчитанные ранее убытки по данному бордеро   
    delete from rel_redamage_bordero r
    where r.re_bordero_id = par_bordero_id; 
    
    -- определяем период,за который ищутся заявленные убытки и версию договора облигаторного перестрахования
    select bp.start_date,bp.end_date,cv.re_main_contract_id
    into db,de,recont
    from re_bordero b
     join re_bordero_package bp on bp.re_bordero_package_id = b.re_bordero_package_id
     join re_contract_version cv on cv.re_contract_version_id = bp.re_contract_id
    where b.re_bordero_id = par_bordero_id;  
    
    for loss in ( --ищем претензии, которые попадают в отчетный период и под версию договора перестрахования
                  
                    select ch.c_claim_header_id,
                           p.t_prod_line_option_id,
                           (cc.declare_sum - nvl(v.vipl,0)) dec_s, --заявленная сумма - оплаченная раньше
                           cc.seqno,
                           cc.claim_status_date,
                           ch.num h_num,
                           cc.num c_num,
                           ce.event_date,
                           nvl(cc.claim_status_id,1) claim_status_id,
                           cc.c_claim_id,
                           p.damage_fund_id
                    from ven_c_claim_header ch 
                     join ven_c_event ce on ce.c_event_id = ch.c_event_id
                     join ven_c_claim cc on cc.c_claim_header_id =ch.c_claim_header_id
                     join (select distinct cd.c_claim_id,pc.t_prod_line_option_id, cd.damage_fund_id
                           from  ven_c_damage cd 
                            join p_cover pc on pc.p_cover_id = cd.p_cover_id
                             join re_cover rc on rc.p_cover_id = pc.p_cover_id
                           where rc.re_m_contract_id = recont 
                         ) p on p.c_claim_id = cc.c_claim_id
                     left join (select cd.c_claim_id,
                                       nvl(sum(t.acc_amount),0) vipl
                                from trans t
                                 join trans_templ tt on tt.trans_templ_id = t.trans_templ_id
                                 join c_damage cd on t.a5_dt_uro_id = cd.c_damage_id
                                 join re_cover rc on rc.p_cover_id = cd.p_cover_id 
                                where tt.brief in ('ЗачВыплКонтр','ЗачВыплВыгод') 
                                  and t.trans_date >= db
                                  and t.trans_date <= de
                                  and rc.re_m_contract_id = recont
                                group by cd.c_claim_id  
                               ) v on v.c_claim_id = cc.c_claim_id
                    where cc.seqno = (                                           -- последняя версия претензии
                                      select max(c.seqno)
                                      from c_claim c 
                                      where c.c_claim_header_id = ch.c_claim_header_id
                                        and c.claim_status_date between db and de
                                     )                                                
                           and (cc.declare_sum - nvl(v.vipl,0)) is not null
                     and p.damage_fund_id in (select reb.fund_id from re_bordero reb where reb.re_bordero_id=par_bordero_id) --валюта ущерба совпадает с валютой бордеро
                 )                      
   loop
     if (loss.dec_s > 0) then
      -- добавляем re_claim_header,усли такой нет
      begin
        insert into ven_re_claim_header
          (re_claim_header_id,c_claim_header_id,num,doc_templ_id,t_prod_line_option_id,re_m_contract_id,event_date)
          select sq_re_claim_header.nextval, -- ид
                 loss.c_claim_header_id,
                 loss.h_num,
                 (select dc.doc_templ_id
                 from doc_templ dc
                 where dc.doc_ent_id = ent.id_by_brief('RE_CLAIM_HEADER')),
                 loss.t_prod_line_option_id,
                 recont,
                 loss.event_date
            from dual;
            commit;
      exception
        when dup_val_on_index then
          null;
      end;
      
      -- выбираем запись re_claim_header
      select *
        into v_re_claim_header
      from ven_re_claim_header r
      where r.c_claim_header_id = loss.c_claim_header_id
        and r.re_m_contract_id = recont;       
      -- добавлем re_claim,усли такой нет
      begin
        insert into ven_re_claim
          (re_claim_id,re_claim_header_id,seqno,re_claim_status_date,num,doc_templ_id,status_id)
          select sq_re_claim.nextval,
                 v_re_claim_header.re_claim_header_id,
                 loss.seqno,
                 loss.claim_status_date,
                 loss.c_num,
                 (select dc.doc_templ_id
                 from doc_templ dc
                 where dc.doc_ent_id = ent.id_by_brief('RE_CLAIM')),
                 loss.claim_status_id
            from dual;
            commit;
      exception
        when dup_val_on_index then
          null;
      end;  
      -- выбираем запись re_claim
      select *
        into v_re_claim
      from ven_re_claim r
      where r.re_claim_header_id = v_re_claim_header.re_claim_header_id
        and r.seqno = loss.seqno;            
      -- добавляем запись в  re_damage,усли такой нет
      
      for ins_rd in ( --выбираем все ущербы по выбранным претензиям
                     select rc.re_cover_id,cd.c_damage_id,cd.t_damage_code_id
                      from c_claim cc
                       join c_damage cd on cd.c_claim_id = cc.c_claim_id
                       left join c_damage_cost_type dct on dct.c_damage_cost_type_id = cd.c_damage_cost_type_id
                       join p_cover pc on pc.p_cover_id = cd.p_cover_id
                       join re_cover rc on rc.p_cover_id = pc.p_cover_id
                      where cc.c_claim_id = loss.c_claim_id
                        and cc.seqno = loss.seqno 
                        and rc.re_m_contract_id = recont
                        and dct.brief is null or dct.brief = 'ВОЗМЕЩАЕМЫЕ'  
                    )
      loop
       begin
        insert into re_damage
          (re_damage_id,re_cover_id,damage_id,re_claim_id,t_damage_code_id)
          select sq_re_damage.nextval,
                 ins_rd.re_cover_id,
                 ins_rd.c_damage_id,
                 v_re_claim.re_claim_id,
                 ins_rd.t_damage_code_id
            from dual;
           
       exception
        when dup_val_on_index then
          null;
       end; 
      end loop;   
      commit;           
      --выбираем в v_re_demage все ущербы
      for re_d in (
                   select rd.re_damage_id,rc.re_contract_ver_id
                   from re_damage rd
                    join re_cover rc on rc.re_cover_id = rd.re_cover_id
                   where rd.re_claim_id = v_re_claim.re_claim_id
                  )
      loop
       select *
       into v_re_damage
       from ven_re_damage r
       where r.re_damage_id = re_d.re_damage_id;
       --удаляем линии по ущербу
       delete from re_line_damage r
       where r.re_damage_id = v_re_damage.re_damage_id;
       
       -- заявленная сумма по оригинальному ущербу-уже оплаченная
       select (cd.declare_sum-nvl(v.s,0))
         into d_decsum
       from c_damage cd
        left join (select t.a5_dt_uro_id,
                          nvl(sum(t.acc_amount),0) s
                   from trans t
                    join trans_templ tt on tt.trans_templ_id = t.trans_templ_id
                   where t.trans_date >= db
                     and t.trans_date <= de
                     and tt.brief in ('ЗачВыплКонтр','ЗачВыплВыгод')
                   group by t.a5_dt_uro_id  
                   )v on v.a5_dt_uro_id = cd.c_damage_id
       where cd.c_damage_id = v_re_damage.damage_id;
        all_amount_dec := 0;
       --по каждой линии считаем долю страховщика и добавляем в re_line_damage
       for cur in (select rlc.line_number, 
                          rlc.limit,
                          rlc.part_perc
                   from re_line_contract rlc,
                        ven_re_cond_filter_obl fo
                   where rlc.fund_id = loss.damage_fund_id
                     and fo.re_contract_ver_id=re_d.re_contract_ver_id
                     and rlc.re_cond_filter_obl_id=fo.re_cond_filter_obl_id
                   order by rlc.line_number)
       loop
    
        v_re_line_damage.re_damage_id   := v_re_damage.re_damage_id;
        v_re_line_damage.line_number    := cur.line_number;
        v_re_line_damage.part_perc      := cur.part_perc;
      
        if (cur.line_number = 1) then   
            v_re_line_damage.limit       := least(cur.limit,d_decsum);
        else
          if (d_decsum >= all_amount_dec+cur.limit) then
            v_re_line_damage.limit       := cur.limit;
          else
            v_re_line_damage.limit       := d_decsum - all_amount_dec;
          end if; 
        end if;

        v_re_line_damage.part_sum    := round(v_re_line_damage.limit*v_re_line_damage.part_perc/100,2);

        all_amount_dec                  := all_amount_dec + cur.limit; --сумма лимитов по линии
        insert into ven_re_line_damage values v_re_line_damage;
        --если заявленная сумма меньше суммы лимитов по линиям, то выходим
       if (d_decsum<= all_amount_dec) then exit;  end if;
       end loop; 
       commit;
       --заносим в таблицу перестрах. ущерба сумму перестраховщика в заявленной сумме ущерба
       select sum(rld.part_sum)
       into v_re_damage.re_declared_sum
       from ven_re_line_damage rld
       where rld.re_damage_id = v_re_damage.re_damage_id;
  
       update ven_re_damage rd
          set re_declared_sum = 
         (select v_re_damage.re_declared_sum
          from dual)
       where rd.re_damage_id = v_re_damage.re_damage_id;
       commit;
       select * into v_re_damage
       from ven_re_damage r
       where r.re_damage_id = re_d.re_damage_id;
       -- связываем re_damage и re_bordero: rel_redamage_bordero
       begin
        insert into rel_redamage_bordero
         (rel_redamage_bordero_id, re_damage_id,re_bordero_id,re_payment_sum)
          select sq_rel_redamage_bordero.nextval,
                 v_re_damage.re_damage_id,
                 par_bordero_id,
                 round(nvl(v_re_damage.re_declared_sum,0),2)
          from dual;
          commit;
       exception
        when dup_val_on_index then
          null;
       end;       
            end loop;      
     end if;
   end loop;
   
   update re_bordero r
   set r.declared_sum = (select sum(rr.re_payment_sum)
                         from rel_redamage_bordero rr
                         where rr.re_bordero_id  =par_bordero_id
                         )
   where r.re_bordero_id =par_bordero_id;                       
  end;
/

