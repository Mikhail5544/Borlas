CREATE OR REPLACE VIEW V_UREG_UBITKI_FOR_MANAG AS
select trim(substr(p2,1,instr(p2,'/') - 1 )) ord1, to_number(trim(substr(p2,instr(p2,'/') + 1))) ord2,
       p110,--ch.c_claim_header_id
       p111,--clm.c_claim_id
       p112,--e.c_event_id
       case when p45 in ('Передано на оплату','Закрыт','Отказано в выплате') then
            (case when (amount > 0) and round((nvl(paym,0) - nvl(decl,0)) * rate / amount, 3) > 0 then 1 else 0 end)
            else 2 end p51,
       p2 num_event,--№ дела
       p3 pol_num,--№ полиса
       p7 insurer,--Застрахованный
       p13 name_dep,--Город
       p16 date_in_company,--Дата получения уведомления--date_in_company
       nvl(p17,'01.01.1900') date_all_doc,--Дата получения всех документов--date_all_doc
       nvl(p20,'01.01.1900') date_event,--Дата наступления страхового события--date_event
       p23 risks,--Перечень рисков, наступивших вследствие произошедшего события
       nvl(trunc(date_request),to_date('01.01.1900','dd.mm.yyyy')) date_request,--Дата направления запроса
       nvl(trunc(date_dbl_request),to_date('01.01.1900','dd.mm.yyyy')) date_dbl_request,--Дата направления повторного запроса
       nvl(trunc(date_answ_request),to_date('01.01.1900','dd.mm.yyyy')) date_answ_request,--Дата получения ответа на запрос
       nvl(trunc(date_SB),to_date('01.01.1900','dd.mm.yyyy')) date_SB,--Дата передачи дела в СБ
       nvl(trunc(date_from_SB),to_date('01.01.1900','dd.mm.yyyy')) date_from_SB,--Дата получения дела из СБ
       nvl(p30,'01.01.1900') date_to_vipl,--Дата утверждения к выплате (дата составления страхового акта)--date_get_decision1
       nvl(p31,'01.01.1900') date_abort_vipl,--Дата отказа в выплате--date_get_decision2
       nvl(d_v,'01.01.1900') date_from_account,--Дата выплаты (берется из бухгалтерии после оплаты)--date_ppi
       p45 state,--Статус
       nvl(p49,'01.01.1900') date_to_oplata,--Дата передачи на оплату--date_oplata
       p50 otkaz,--Причина отказа--otkaz
       pol_header_id,
       (select ids from p_pol_header ph where ph.policy_header_id = pol_header_id) ids,
      'ЖУУ' import
from (
select ch.c_claim_header_id p110,
       clm.c_claim_id p111,
       e.c_event_id p112,
       case when tp.id = 30500025 then 'Ж' else
            (nvl(case tp.insurance_group_id when 2404 then 'Н' when 2 then 'П' else 'Ж' end,'-') )
            end p1,
       nvl(ch.num,'-') p2,
       nvl(decode(p.pol_ser, null, p.pol_num, p.pol_ser || '-' || p.pol_num),'-') p3,
       nvl(case nvl(p.is_group_flag,0) when 1 then 'Корпоративный' else (case when chl.id = 8 then 'Кредитный' else 'Индивидуальный' end) end,'-') p4,
       nvl(prod.description,'-')  p5,
       nvl(prod.brief,'-') p6,
       nvl(ent.obj_name('CONTACT',asu.assured_contact_id),'-') p7,
       nvl(case nvl(casu.gender,0) when 0 then 'Ж' else 'М' end,'-') p8,
       nvl(casu.date_of_birth,'01.01.1900') p9,
       nvl(prof.description,'-') p10,
       nvl(pkg_agent_1.get_agent_pol(p.pol_header_id, sysdate),'-') p11,
       nvl(pkg_agent_1.get_agentlider_pol(p.pol_header_id, sysdate),'-') p12,
       nvl(dep.name,'-') p13,
       nvl(substr(pr.kladr_code,1,2),'')  p14,
       nvl(ph.start_date,'01.01.1900') p15,
       nvl(e.date_company,'01.01.1900') p16,
       --09.12.2011_Чирков Разработка отчетных форм
       --max_date.msdate,
       (select max(ds1.start_date) msdate
                from c_claim c1
                     ,document d1
                     ,doc_status ds1
                where  c1.c_claim_header_id = ch.c_claim_header_id
                      and c1.c_claim_id = d1.document_id
                      and ds1.doc_status_id = d1.doc_status_id
       )msdate,
       --end_09.12.2011_Чирков Разработка отчетных форм
       
    /*(select max(ds.start_date)
    from ven_c_claim c, ven_c_claim_header chk, doc_status ds
    where chk.c_claim_header_id = c.c_claim_header_id
          and c.c_claim_header_id = ch.c_claim_header_id
          and ds.document_id = c.c_claim_id
          and ds.start_date = (SELECT MAX(dss.start_date)
                               FROM DOC_STATUS dss
                               WHERE dss.document_id = c.c_claim_id)
          and chk.c_claim_header_id = ch.c_claim_header_id) msdate,*/

       (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = 122) p17,
       (select decode(doc.get_last_doc_status_name(clm2.c_claim_id),'Все документы', clm2.claim_status_date)
         from ven_c_claim clm2
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and rownum = 1
               and doc.get_last_doc_status_name(clm2.c_claim_id) = 'Все документы') p19,

      (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = 129) p19_1,

       nvl(e.event_date,'01.01.1900') p20,
       nvl(e.event_date,'01.01.1900') - nvl(ph.start_date,'01.01.1900') p21,
       nvl(e.diagnose,'-') p22,


       (select plo.description progr
        from p_policy pp,
             as_asset ass,
             p_cover pc,
             t_prod_line_option plo,
             t_product_line pl,
             t_product_line_type plt
        where ass.p_policy_id = pp.policy_id
              and pc.as_asset_id = ass.as_asset_id
              and plo.id = pc.t_prod_line_option_id
              and plo.product_line_id = pl.id
              and pl.product_line_type_id = plt.product_line_type_id
              and plt.brief = 'RECOMMENDED'
              and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
              and pp.policy_id = p.policy_id
              and rownum = 1) p22_1,
         pl.description p22_2,

       /*case when pl.description in ('Защита страховых взносов','Защита страховых взносов рассчитанная по основной программе',
                           'Освобождение от уплаты взносов рассчитанное по основной программе','Освобождение от уплаты дальнейших взносов',
                           'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе',
                           'Освобождение от уплаты страховых взносов') then pl.description
            when pl.description like '%Дожитие%по независящим%' then pl.description
            else tp.description end p23,*/
       case when pl.description like 'Защита страховых%'
         then pl.description
       when pl.description like 'Освобождение%'
         then pl.description
       when pl.description like '%Дожитие%по независящим%'
         then pl.description
       when pl.description like '%"Расширенная Госпитализация"%'
         then pl.description    
       when pl.description like 'Первичное диагностирование смертельно опасного заболевания'
         then pl.description   
       else tp.description
       end p23,

       --nvl(pc.ins_amount,0) p24,             
        case when nvl(ch.is_handset_ins_sum,0) = 1 then
                  ch.ins_sum
             when nvl(pc.ins_amount,0) = 0 then
               pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
             when dmg.t_damage_code_id in (select dt.id from ins.t_damage_code dt where dt.code in 'DOP_INVEST_DOHOD' ) then
               pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
        else
             nvl(pc.ins_amount,0)
        end
          p24,
       nvl(f.brief,'-') p25,
       --nvl(pc.ins_amount,0) amount,
        case when nvl(ch.is_handset_ins_sum,0) = 1 then
                  ch.ins_sum
             when nvl(pc.ins_amount,0) = 0 then
               pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
        else
             nvl(pc.ins_amount,0)
        end
        amount,
                
        nvl(dmg.decline_sum,0) decl,
        nvl(dmg.declare_sum,0) paym,
        nvl(acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,ch.declare_date),1) rate,

        e.c_event_id p28,

         (select sum(round(nvl(dmg.payment_sum,0) * acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,chx.declare_date),2))
         from ven_c_claim_header chx
              join ven_c_claim clm on (chx.c_claim_header_id = clm.c_claim_header_id)
              join c_damage dmg on (clm.c_claim_id = dmg.c_claim_id)
              left join fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
              left join fund f on (chx.fund_id = f.fund_id)
         where chx.c_claim_header_id = ch.c_claim_header_id
               and clm.seqno = 1
               /*and doc.get_last_doc_status_name(clm.c_claim_id) = 'Ждем документы'*/) p28_1,

         (select sum(round(nvl(dmg.payment_sum,0) * acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,chx.declare_date),2))
         from ven_c_claim_header chx
              join ven_c_claim clm on (chx.c_claim_header_id = clm.c_claim_header_id)
              join c_damage dmg on (clm.c_claim_id = dmg.c_claim_id)
              left join fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
              left join fund f on (chx.fund_id = f.fund_id)
         where chx.c_claim_header_id = ch.c_claim_header_id
               and dmg.status_hist_id <> 3
               and clm.seqno = (select max(clml.seqno) from ven_c_claim clml where clml.c_claim_header_id = ch.c_claim_header_id)) p28_1_1,

        case when (nvl(dmg.payment_sum,0)) > 0 then

         (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id in (128)) end p30,--  -10 Урегулируется,11 Закрыт


         case when (nvl(dmg.payment_sum,0)) = 0 then

        (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id in (128)) end p31,

        nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id,'В'),0) +
             nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'З'),0) p32,
         0 p33,
        '-' p34,
         0 p35,
        '-' p36,

nvl(pkg_renlife_utils.ret_sod_claim(ch.c_claim_header_id),'01.01.1900') d_v,

nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'В'),0) new_pole1,
pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'З') new_pole2,

        pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'В') +
             pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'З') p37,
        '-' p38,
        '-' p39, '-' p40, '-' p41,
        '-' p43, '-' p44,
        nvl(doc.get_last_doc_status_name(ch.active_claim_id),'-') p45,
        nvl(ds.note,'-') st_note,
        nvl(clm.note,'-') p46,

        '-' p47, '-' p48,
        (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = 129) p49,
        nvl(pkg_renlife_utils.damage_decline_reason(pc.p_cover_id,ch.active_claim_id),'-') p50,
        --nvl(dmg.decline_reason,'-') p50,
        p.pol_header_id,
        nvl(cad.add_invest,0) add_invest,
        nvl(cad.risk_sum,0) risk_sum,
        nvl(cad.reinsurer_perc,0) reinsurer_perc,

        case cad.reinsurer_id when 1 then 'Кельнское перестраховочное общество' when 2 then 'Мюнхенское перестраховочное общество' else 'Не определен' end reinsurer,
        f.brief fund_brief,
        case when pl.description in ('Защита страховых взносов','Защита страховых взносов рассчитанная по основной программе',
                           'Освобождение от уплаты взносов рассчитанное по основной программе','Освобождение от уплаты дальнейших взносов',
                           'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе',
                           'Освобождение от уплаты страховых взносов')
             then pkg_claim.GET_EPG_TO_EVENT(ch.c_event_id,ch.num,e.event_date,p.first_pay_date,12 / term.number_of_payments) else to_date('01.01.1900','dd.mm.yyyy') end plan_date,
        (select min(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds,
              doc_status_ref rf
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = rf.doc_status_ref_id
               and rf.name = 'Официальный запрос документов') date_request,
        case when (select count(ds.doc_status_id)
                  from ven_c_claim clm2,
                       doc_status ds,
                       doc_status_ref rf
                   where clm2.c_claim_header_id = ch.c_claim_header_id
                         and ds.document_id = clm2.c_claim_id
                         and ds.doc_status_ref_id = rf.doc_status_ref_id
                         and rf.name = 'Официальный запрос документов') >= 2 then
        (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds,
              doc_status_ref rf
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = rf.doc_status_ref_id
               and rf.name = 'Официальный запрос документов') else null end date_dbl_request,

       (select min(ds.start_date)
       from ven_c_claim clm2, doc_status ds, doc_status_ref rf
       where clm2.c_claim_header_id = ch.c_claim_header_id
             and ds.document_id = clm2.c_claim_id
             and ds.doc_status_ref_id = rf.doc_status_ref_id
             and rf.name = 'Дело в отделе урегулирования убытков'
             and ds.start_date > nvl(
             (case when (select count(ds.doc_status_id)
                                                  from ven_c_claim clm2,
                                                       doc_status ds,
                                                       doc_status_ref rf
                                                   where clm2.c_claim_header_id = ch.c_claim_header_id
                                                         and ds.document_id = clm2.c_claim_id
                                                         and ds.doc_status_ref_id = rf.doc_status_ref_id
                                                         and rf.name = 'Официальный запрос документов') >= 2 then
                                        (select max(ds.start_date)
                                         from ven_c_claim clm2,
                                              doc_status ds,
                                              doc_status_ref rf
                                         where clm2.c_claim_header_id = ch.c_claim_header_id
                                               and ds.document_id = clm2.c_claim_id
                                               and ds.doc_status_ref_id = rf.doc_status_ref_id
                                               and rf.name = 'Официальный запрос документов') else null end),
              nvl((select min(ds.start_date)
                   from ven_c_claim clm2,
                        doc_status ds,
                        doc_status_ref rf
                   where clm2.c_claim_header_id = ch.c_claim_header_id
                         and ds.document_id = clm2.c_claim_id
                         and ds.doc_status_ref_id = rf.doc_status_ref_id
                         and rf.name = 'Официальный запрос документов'),'31.12.2999')        )
             ) date_answ_request,--Дата получения ответа на запрос

       nvl((select min(ds.start_date)
       from ven_c_claim clm2, doc_status ds, doc_status_ref rf
       where clm2.c_claim_header_id = ch.c_claim_header_id
             and ds.document_id = clm2.c_claim_id
             and ds.doc_status_ref_id = rf.doc_status_ref_id
             and ds.start_date > nvl((select max(ds.start_date)
                                     from ven_c_claim clm2,
                                          doc_status ds,
                                          doc_status_ref rf
                                     where clm2.c_claim_header_id = ch.c_claim_header_id
                                           and ds.document_id = clm2.c_claim_id
                                           and ds.doc_status_ref_id = rf.doc_status_ref_id
                                           and rf.name = 'Дело в СБ'),'31.12.2999') ),'01.01.1900') date_from_SB,--Дата получения дела из СБ

         (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds,
              doc_status_ref rf
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = rf.doc_status_ref_id
               and rf.name = 'Дело в СБ') date_SB

from ven_c_claim_header ch
     --join ven_c_claim clm on (ch.c_claim_header_id = clm.c_claim_header_id)
     join ven_c_claim clm on (ch.active_claim_id = clm.c_claim_id)
     join p_policy p on ch.p_policy_id = p.policy_id

     /*join p_policy_contact pcnt on (pcnt.policy_id = p.policy_id)
     join t_contact_pol_role polr on (polr.brief = 'Страхователь' and pcnt.contact_policy_role_id = polr.id)
     join contact cpol on (cpol.contact_id = pcnt.contact_id)*/

     join ven_c_event e on ch.c_event_id = e.c_event_id
     --join c_event_contact ec on (ch.declarant_id = ec.c_event_contact_id)
     --join contact c on ec.cn_person_id = c.contact_id
     --join ven_cn_person per on (ch.curator_id = per.contact_id)
     --join c_declarant_role dr on ch.declarant_role_id = dr.c_declarant_role_id
     --left join department ct on ch.depart_id = ct.department_id
     left join as_asset a on ch.as_asset_id = a.as_asset_id
     left join as_assured asu on asu.as_assured_id = a.as_asset_id
     left join cn_person casu on casu.contact_id = asu.assured_contact_id
     left join t_profession prof on (casu.profession = prof.id)
     left join fund f on (ch.fund_id = f.fund_id)
     join c_claim_metod_type cmt on ch.notice_type_id = cmt.c_claim_metod_type_id
     left join p_cover pc on (ch.p_cover_id = pc.p_cover_id)
     left join t_prod_line_option pl on pc.t_prod_line_option_id = pl.id
     join p_pol_header ph on ph.policy_header_id = p.pol_header_id
     join t_payment_terms term on (term.id = p.payment_term_id)
     left join t_sales_channel chl on (chl.id = ph.sales_channel_id)
     left join department dep on dep.department_id = ph.agency_id
     left join organisation_tree ot on (ot.organisation_tree_id = dep.org_tree_id)
     left join t_province pr on (pr.province_id = ot.province_id)
     left join t_product prod on prod.product_id = ph.product_id
     left join t_peril tp on tp.id = ch.peril_id
     left join t_prod_line_option opt on (opt.id = pc.t_prod_line_option_id)
     left join c_damage dmg on (dmg.p_cover_id = pc.p_cover_id and ch.active_claim_id = dmg.c_claim_id and dmg.status_hist_id <> 3)
     left join c_claim_add cad on (cad.c_claim_id = clm.c_claim_id)

     /*left join (select max(ds.start_date) msdate, chk.c_claim_header_id
                from ven_c_claim c, ven_c_claim_header chk, doc_status ds
                where chk.c_claim_header_id = c.c_claim_header_id
                      and ds.document_id = c.c_claim_id
                      and ds.start_date = (SELECT MAX(dss.start_date)
                                           FROM DOC_STATUS dss
                                           WHERE dss.document_id = c.c_claim_id)
                group by chk.c_claim_header_id) max_date on (max_date.c_claim_header_id = ch.c_claim_header_id)

     left join (select max(ds.doc_status_id) ds_id, ds.document_id
                from doc_status ds
                group by ds.document_id) mds on (mds.document_id = clm.c_claim_id)
     left join doc_status ds on (ds.doc_status_id = mds.ds_id and ds.document_id = clm.c_claim_id)*/
     inner join document d_clm on d_clm.document_id = clm.c_claim_id
     left join doc_status ds on ds.doc_status_id = d_clm.doc_status_id
     
     left join fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
where 
ch.c_claim_header_id NOT IN (select d.document_id
                                  from etl.import_export_claim et, document d, doc_templ t
                                  where t.doc_templ_id = d.doc_templ_id
                                        and t.brief = 'Претензия'
                                        and nvl(et.show_del_pret,0) = 0
                                        and trim(
                                           (case when instr(et.num_event,'-',1) > 0 then
                                              lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
                                              else lpad(et.num_event,9,'0')||'/'||'1'
                                            end)
                                            ) = d.num)
--and ch.c_event_id = 38979381                                            
)
group by p2,p3,p7,p13,p16,p17,
      p110,p111,p112,
      p20,
      p23,
      p30,
      nvl(d_v,'01.01.1900'),
      nvl(p49,'01.01.1900'),p31,
      p45,p50, case when p45 in ('Передано на оплату','Закрыт','Отказано в выплате') then
                                                          (case when (amount > 0) and round((nvl(paym,0) - nvl(decl,0)) * rate / amount, 3) > 0 then 1 else 0 end)
                                                          else 2 end,
      pol_header_id,
      nvl(trunc(date_request),to_date('01.01.1900','dd.mm.yyyy')),
      nvl(trunc(date_dbl_request),to_date('01.01.1900','dd.mm.yyyy')),
      nvl(trunc(date_answ_request),to_date('01.01.1900','dd.mm.yyyy')),
      nvl(trunc(date_SB),to_date('01.01.1900','dd.mm.yyyy')),
      nvl(trunc(date_from_SB),to_date('01.01.1900','dd.mm.yyyy'))

union

select trim(substr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),1,instr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),'/') - 1 )) ord1, to_number(trim(substr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),instr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),'/') + 1))) ord2,
       null,
       null,
       null,
       case when (case when nvl(et.to_agency,'Закрыт') <> 'Запрос документов' then 'Закрыт' else et.to_agency end) in ('Передано на оплату','Закрыт','Отказано в выплате') then
            (case when nvl(et.sum_real_risk,0) <> 0 then 1 else 0 end)
            else 2 end p51,
       (case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end) num_event,
       et.pol_num,
       et.insurer,
       substr(et.name_dep,instr(et.name_dep,'.',1) + 1) name_dep,--Город
       nvl(et.date_in_company,'01.01.1900') date_in_company,--Дата получения уведомления--date_in_company
       nvl(et.date_all_doc,'01.01.1900') date_all_doc,--Дата получения всех документов--date_all_doc
       nvl(et.date_event,'01.01.1900') date_event,--Дата наступления страхового события--date_event
       et.risks,--Перечень рисков, наступивших вследствие произошедшего события
       to_date('01.01.1900','dd.mm.yyyy') date_request,--Дата направления запроса
       to_date('01.01.1900','dd.mm.yyyy') date_dbl_request,--Дата направления повторного запроса
       to_date('01.01.1900','dd.mm.yyyy') date_answ_request,--Дата получения ответа на запрос
       to_date('01.01.1900','dd.mm.yyyy') date_SB,--Дата передачи дела в СБ
       to_date('01.01.1900','dd.mm.yyyy') date_from_SB,--Дата получения дела из СБ
       nvl(et.date_to_vipl,'01.01.1900') date_to_vipl,--Дата утверждения к выплате (дата составления страхового акта)--date_get_decision1
       nvl(et.date_abort_vipl,'01.01.1900') date_abort_vipl,--Дата отказа в выплате--date_get_decision2
       nvl(et.date_from_account,'01.01.1900') date_from_account,--Дата выплаты (берется из бухгалтерии после оплаты)--date_ppi
       case when nvl(et.state,'Закрыт') <> 'Запрос документов' then 'Закрыт' else et.state end state,--Статус
       nvl(et.date_to_oplata,'01.01.1900') date_to_oplata,--Дата передачи на оплату--date_oplata
       nvl(et.otkaz,'-') otkaz,--Причина отказа--otkaz
       (select ph.policy_header_id from p_pol_header ph where ph.ids = et.ids and rownum = 1) policy_header_id,
       et.ids,
       'Импорт' import

from etl.import_export_claim et

order by 1,2;
