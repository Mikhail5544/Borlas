CREATE OR REPLACE PROCEDURE cancel_last_version
(
  p_policy_id IN p_policy.policy_id%TYPE
)
is
  v_prev_policy_id      p_policy.policy_id%TYPE;
  v_pol_header_id       p_pol_header.policy_header_id%TYPE;
  v_change_allowed      NUMBER;
--  v_role                sys_role.sys_role_id%TYPE;
  v_status_date         doc_status.start_date%TYPE;
  v_current_status      doc_status_ref.brief%type;
  v_path                varchar2(2000);
  v_cnt                 pls_integer := 0;
  v_version_num         pls_integer := 0;
  v_a3_ct_ure_id        number;
  v_a3_ct_uro_id        number;
begin
  -- проверка существования версии
  begin
    SELECT pol_header_id
          ,pp.version_num
          ,dsr.brief
      INTO v_pol_header_id
          ,v_version_num
          ,v_current_status
      FROM p_policy       pp
          ,document       dc
          ,doc_status_ref dsr
     WHERE pp.policy_id         = p_policy_id
       and pp.policy_id         = dc.document_id
       and dc.doc_status_ref_id = dsr.doc_status_ref_id;
  exception
    when NO_DATA_FOUND then
      raise_application_error(-20001, 'Не найдена указанная версия ДС');
  end;
  -- Проверка является ли версия последней
  if pkg_policy.is_last_version(p_policy_id) != 1 then
    raise_application_error(-20001, 'Откатываемая версия не является последней');
  end if;
  -- Проверка является ли версия первой
  if v_version_num = 1 then
    raise_application_error(-20001, 'Откатываемая версия является первой');
  end if;

  v_status_date := SYSDATE;
--  v_current_status := doc.get_doc_status_brief(p_policy_id,to_date('31.12.2999','dd.mm.yyyy'));

  -- Предыдущая версия
  SELECT p.policy_id
    INTO v_prev_policy_id
    FROM p_policy p
        ,p_policy p2
  where p.pol_header_id = p2.pol_header_id
    AND p.version_num = p2.version_num - 1
    and p2.policy_id = p_policy_id;

  -- есть ли немедленный переход в Отменен
  SELECT count(1)
    INTO v_change_allowed
    FROM dual
   WHERE /*doc.get_doc_status_brief(p_policy_id)*/
         v_current_status IN (SELECT f.brief
                                FROM (SELECT brief, doc_templ_id, doc_templ_status_id
                                        FROM doc_templ_status dts
                                            ,doc_status_ref   dsr
                                       where dts.doc_status_ref_id = dsr.doc_status_ref_id) f
                                    ,doc_status_allowed dso
                                    ,(SELECT name, doc_templ_status_id
                                        FROM doc_templ_status dts
                                            ,doc_status_ref   dsr
                                       where dts.doc_status_ref_id = dsr.doc_status_ref_id) t
                                     ,doc_templ dt
                                WHERE t.name = 'Отменен'
                                  AND dt.brief = 'POLICY'
                                  and dt.doc_templ_id = f.doc_templ_id
                                  and dso.src_doc_templ_status_id = f.doc_templ_status_id
                                  and dso.dest_doc_templ_status_id = t.doc_templ_status_id
                            );

  -- Если нет перехода в один шаг, то
  if v_change_allowed = 0 then
    -- Перевод ПП и Распоряжения на выплату возмещения взаимозачетом в статус Аннулирован
    FOR pp IN (SELECT dso.doc_set_off_id
                 FROM doc_doc dd
                     ,doc_set_off dso
                     ,document d
                     ,doc_templ dt
                WHERE dd.parent_id      = cancel_last_version.p_policy_id
                  AND dso.parent_doc_id = dd.child_id
                  AND d.document_id     = dso.child_doc_id
                  AND dt.doc_templ_id   = d.doc_templ_id
                  AND dt.brief in ('ПП','PAYORDER_SETOFF')
              )
    LOOP
      UPDATE doc_set_off
         SET cancel_date = v_status_date
       WHERE doc_set_off_id = pp.doc_set_off_id;

      doc.set_doc_status(p_doc_id       => pp.doc_set_off_id
                        ,p_status_brief => 'ANNULATED'
                        ,p_status_date  => v_status_date);
      v_status_date := v_status_date + interval '1' second;
    END LOOP;


    -- Перевод ПД4, А7 и документов по зачету в статус Аннулирован
    FOR dso IN (SELECT dso2.doc_set_off_id
                      ,d2.document_id
                  FROM doc_doc dd
                      ,doc_set_off dso
                      ,doc_doc dd2
                      ,document da7copy
                      ,doc_templ dt
                      ,doc_set_off dso2
                      ,document d2
                      ,doc_templ dt2
                 WHERE dd.parent_id      = cancel_last_version.p_policy_id
                   AND dso.parent_doc_id = dd.child_id
                   AND dd2.parent_id     = dso.child_doc_id
                   AND d2.document_id    = dso.child_doc_id
                   AND dt2.doc_templ_id  = d2.doc_templ_id
                   AND dt2.brief IN ('PD4', 'A7')
                   AND da7copy.document_id = dd2.child_id
                   AND dt.doc_templ_id     = da7copy.doc_templ_id
                   AND dt.brief            = 'A7COPY'
                   AND dso2.parent_doc_id  = da7copy.document_id)
      LOOP
        UPDATE doc_set_off
           SET cancel_date = v_status_date
         WHERE doc_set_off_id = dso.doc_set_off_id;
        doc.set_doc_status(p_doc_id => dso.doc_set_off_id
                          ,p_status_brief => 'ANNULATED'
                          ,p_status_date => v_status_date);

        v_status_date := v_status_date + interval '1' second;
        UPDATE doc_set_off
           SET cancel_date = v_status_date
         WHERE doc_set_off_id = dso.document_id;
        doc.set_doc_status(p_doc_id => dso.document_id
                          ,p_status_brief => 'ANNULATED'
                          ,p_status_date => v_status_date);
        v_status_date := v_status_date + interval '1' second;
      END LOOP;

-- находим кратчайший путь к статусу Новый, но так, чтобы не проходить через статус Отменен
    begin
      select substr(pt,length('//'||v_current_status||'//')+1)
        into v_path
        from (select distinct sys_connect_by_path(src_brief,'//') as pt, src_brief, level
                from (select dsa.src_doc_templ_status_id
                            ,dss.brief as src_brief
                            ,dsa.dest_doc_templ_status_id
                        from doc_status_ref     dss
                            ,doc_status_ref     dsd
                            ,doc_templ_status   dts
                            ,doc_templ_status   dtd
                            ,doc_status_allowed dsa
                       where dsa.src_doc_templ_status_id  = dts.doc_templ_status_id
                         and dsa.dest_doc_templ_status_id = dtd.doc_templ_status_id
                         and dts.doc_status_ref_id        = dss.doc_status_ref_id
                         and dtd.doc_status_ref_id        = dsd.doc_status_ref_id
                         and dts.doc_templ_id             = 2
                         and dtd.doc_templ_id             = 2
                      ) z
               connect by nocycle z.src_doc_templ_status_id = prior z.dest_doc_templ_status_id
                   and z.src_brief != 'CANCEL'
                   and level <= 10 -- ограничение в 10 переходов, иначе получается слишком много вариантов
                 start with z.src_brief = v_current_status
                 order by level
                 )
       where src_brief = 'NEW'--'PROJECT'
         and rownum = 1;

      -- Цикл по переходам от текущего статуса до статуса Новый
      if v_path is not null then -- Если null - значит уже в статусе Новый
        for r_status in (select regexp_substr(v_path,'(\s|\w)+',1,rownum) as new_status
                               ,rownum
                           from dual
                        connect by level <= (length(v_path)-length(replace(v_path,'//')))/2+1)
        loop
          doc.set_doc_status(p_doc_id       => p_policy_id
                            ,p_status_brief => r_status.new_status
                            ,p_status_date  => v_status_date
                            ,p_status_change_type_brief => 'AUTO');
          v_current_status := r_status.new_status;
          v_status_date := v_status_date + interval '1' second;
        end loop;
      end if;
    exception
      when NO_DATA_FOUND then
        -- Если не нашли путь без статуса "Отменен", идем до статуса "Отменен"
        begin
          select substr(pt,length('//'||v_current_status||'//')+1)
            into v_path
            from (select distinct sys_connect_by_path(src_brief,'//') as pt, src_brief, level
                    from (select dsa.src_doc_templ_status_id
                                ,dss.brief as src_brief
                                ,dsa.dest_doc_templ_status_id
                            from doc_status_ref     dss
                                ,doc_status_ref     dsd
                                ,doc_templ_status   dts
                                ,doc_templ_status   dtd
                                ,doc_status_allowed dsa
                           where dsa.src_doc_templ_status_id  = dts.doc_templ_status_id
                             and dsa.dest_doc_templ_status_id = dtd.doc_templ_status_id
                             and dts.doc_status_ref_id        = dss.doc_status_ref_id
                             and dtd.doc_status_ref_id        = dsd.doc_status_ref_id
                             and dts.doc_templ_id             = 2
                             and dtd.doc_templ_id             = 2
                          ) z
                   connect by nocycle z.src_doc_templ_status_id = prior z.dest_doc_templ_status_id
                       and level <= 10 -- ограничение в 10 переходов, иначе получается слишком много вариантов
                     start with z.src_brief = v_current_status
                     order by level
                     )
           where src_brief = 'CANCEL'
             and rownum = 1;

          -- Цикл по переходам от текущего статуса до статуса, предшествующего статусу Отменен.
          for r_status in (select regexp_substr(v_path,'(\s|\w)+',1,rownum) as new_status
                                 ,rownum
                             from dual
                          connect by level <= (length(v_path)-length(replace(v_path,'//')))/2)
          loop
            doc.set_doc_status(p_doc_id       => p_policy_id
                              ,p_status_brief => r_status.new_status
                              ,p_status_date  => v_status_date
                              ,p_status_change_type_brief => 'AUTO');
            v_current_status := r_status.new_status;
            v_status_date := v_status_date + interval '1' second;
          end loop;
        exception
          when NO_DATA_FOUND then
            raise_application_error(-20001, 'Не найден подходящий переход к статусу "Отменен". Произведите откат до статуса "Новый" вручную!');
        end;
    end;

  -- Удалим неоплаченные, что оплачено - аннулируется
    pkg_payment.delete_unpayed(v_pol_header_id);
    -- Перепривязываем аннулированные ЭПГ на предыдущую версию
--return;
    update doc_doc dd
       set dd.parent_id = v_prev_policy_id
     where dd.parent_id = p_policy_id
       and exists (select null
                     from document       d
                         ,doc_templ      dt
                         ,doc_status_ref dsr
                   WHERE dd.child_id         = d.document_id
                     and d.doc_templ_id      = dt.doc_templ_id
                     and dt.brief            = 'PAYMENT'
                     and d.doc_status_ref_id = dsr.doc_status_ref_id
                     and dsr.brief           = 'ANNULATED'
                     --and doc.get_doc_status_brief(d.document_id) = 'ANNULATED'
                  );
    if v_current_status = 'NEW' then
      doc.set_doc_status(p_doc_id       => p_policy_id
                        ,p_status_brief => 'PROJECT'
                        ,p_status_date  => v_status_date
                        ,p_status_change_type_brief => 'AUTO');
      v_status_date := v_status_date + interval '1' second;
    end if;
  end if;
  -- Привязка проводок к предыдущей версии
  FOR tr IN
    (SELECT a.trans_id, a.trans_templ_id, b.p_cover_id, b.prev_policy_id
      FROM (SELECT t.trans_id, t.trans_templ_id, pc.t_prod_line_option_id --, pc.p_cover_id old_p_cover_id
           FROM trans t, p_policy pp, as_asset aa, p_cover pc
           WHERE pp.pol_header_id = pp.pol_header_id
           AND aa.p_policy_id = pp.policy_id
           AND pc.as_asset_id = aa.as_asset_id
           AND ((t.obj_ure_id = 305 AND t.obj_uro_id = pc.p_cover_id) OR
                 (t.a1_dt_ure_id = 305 AND t.a1_dt_uro_id = pc.p_cover_id) OR
                 (t.a2_dt_ure_id = 305 AND t.a2_dt_uro_id = pc.p_cover_id) OR
                 (t.a3_dt_ure_id = 305 AND t.a3_dt_uro_id = pc.p_cover_id) OR
                 (t.a4_dt_ure_id = 305 AND t.a4_dt_uro_id = pc.p_cover_id) OR
                 (t.a5_dt_ure_id = 305 AND t.a5_dt_uro_id = pc.p_cover_id) OR
                 (t.a1_ct_ure_id = 305 AND t.a1_ct_uro_id = pc.p_cover_id) OR
                 (t.a2_ct_ure_id = 305 AND t.a2_ct_uro_id = pc.p_cover_id) OR
                 (t.a3_ct_ure_id = 305 AND t.a3_ct_uro_id = pc.p_cover_id) OR
                 (t.a4_ct_ure_id = 305 AND t.a4_ct_uro_id = pc.p_cover_id) OR
                 (t.a5_ct_ure_id = 305 AND t.a5_ct_uro_id = pc.p_cover_id))
           AND t.trans_templ_id NOT IN (67, 623/*, 57, 581*/) --В этих Проводках аналитики плохо обрабатывать автоматически
           AND pp.policy_id = cancel_last_version.p_policy_id) a,
           (SELECT v_prev_policy_id prev_policy_id, aa.as_asset_id, pc.t_prod_line_option_id, pc.p_cover_id
              FROM as_asset aa, p_cover pc
             WHERE aa.p_policy_id = v_prev_policy_id
               AND pc.as_asset_id = aa.as_asset_id) b
      WHERE b.t_prod_line_option_id = a.t_prod_line_option_id)
  LOOP
    IF tr.trans_templ_id <> 42
    THEN
      UPDATE trans t SET
        t.a1_ct_uro_id = case t.a1_ct_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a1_ct_uro_id
                         end
       ,t.a1_dt_uro_id = case t.a1_dt_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a1_dt_uro_id
                         end
       ,t.a2_ct_uro_id = case t.a2_ct_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a2_ct_uro_id
                         end
       ,t.a2_dt_uro_id = case t.a2_dt_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a2_dt_uro_id
                         end
       ,t.a3_ct_uro_id = case t.a3_ct_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a3_ct_uro_id
                         end
       ,t.a3_dt_uro_id = case t.a3_dt_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a3_dt_uro_id
                         end
       ,t.a4_ct_uro_id = case t.a4_ct_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a4_ct_uro_id
                         end
       ,t.a4_dt_uro_id = case t.a4_dt_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a4_dt_uro_id
                         end
       ,t.a5_ct_uro_id = case t.a5_ct_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a5_ct_uro_id
                         end
       ,t.a5_dt_uro_id = case t.a5_dt_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.a5_dt_uro_id
                         end
       ,t.obj_uro_id = case t.obj_ure_id
                           when 283 then tr.prev_policy_id
                           when 305 then tr.p_cover_id
                           else t.obj_uro_id
                       end
      WHERE t.trans_id = tr.trans_id
      returning t.a3_ct_ure_id, t.a3_ct_uro_id into v_a3_ct_ure_id, v_a3_ct_uro_id;

     /* Бывает, что в uref нет соответствующих записей */
      if v_a3_ct_ure_id is not null then
        select count(1)
          into v_cnt
          from dual
         where exists (select null
                         from uref uf
                        where uf.ure_id = v_a3_ct_ure_id
                          and uf.uro_id = v_a3_ct_uro_id);

        if v_cnt = 0 then
          insert into uref
          values
            (v_a3_ct_ure_id, v_a3_ct_uro_id);
        end if;
      end if;
    ELSIF tr.trans_templ_id = 42
    THEN
      UPDATE trans t SET
        t.a5_ct_uro_id = tr.p_cover_id,
        t.a5_ct_ure_id = 305
      WHERE t.trans_id = tr.trans_id;
    END IF;
  END LOOP;

  -- Т.к. могут остаться проводки, не перенесенные на предыдущую версию из-за отсутствия там нужных рисков,
  -- чистим ID риска у проводки, заменяем ID полиса
  update trans tr
     set tr.a3_dt_uro_id = null
        ,tr.a3_ct_uro_id = null
        ,tr.a2_dt_uro_id = case
                             when tr.a2_dt_uro_id = p_policy_id then
                               v_prev_policy_id
                             else
                               tr.a2_dt_uro_id
                           end
        ,tr.a2_ct_uro_id = case
                             when tr.a2_ct_uro_id = p_policy_id then
                               v_prev_policy_id
                             else
                               tr.a2_ct_uro_id
                           end
   where tr.a3_dt_ure_id = 305
     and tr.a3_dt_uro_id in (select pc.p_cover_id
                               from as_asset se
                                   ,p_cover  pc
                              where se.p_policy_id = cancel_last_version.p_policy_id
                                and se.as_asset_id = pc.as_asset_id
                            );

  update trans tr
     set tr.a3_dt_uro_id = null
        ,tr.a3_ct_uro_id = null
        ,tr.a2_dt_uro_id = case
                             when tr.a2_dt_uro_id = p_policy_id then
                               v_prev_policy_id
                             else
                               tr.a2_dt_uro_id
                           end
        ,tr.a2_ct_uro_id = case
                             when tr.a2_ct_uro_id = p_policy_id then
                               v_prev_policy_id
                             else
                               tr.a2_ct_uro_id
                           end
   where tr.a3_ct_ure_id = 305
     and tr.a3_ct_uro_id in (select pc.p_cover_id
                               from as_asset se
                                   ,p_cover  pc
                              where se.p_policy_id = cancel_last_version.p_policy_id
                                and se.as_asset_id = pc.as_asset_id
                            );
     
  execute immediate 'set constraints FK_TRANS_A3_CT_UR, FK_TRANS_A3_DT_UR, FK_TRANS_A4_DT_UR immediate';

  UPDATE doc_doc dd
     SET dd.parent_id = v_prev_policy_id
   WHERE dd.parent_id = p_policy_id;

  UPDATE oper o
     SET o.document_id = v_prev_policy_id
   WHERE o.document_id = p_policy_id;

  update trans t
     set t.a2_dt_uro_id = v_prev_policy_id
   where t.a2_dt_uro_id = p_policy_id;

  -- Перенесем комиссию
  /*update agent_report_cont co
     set co.policy_id  = v_prev_policy_id
        ,co.p_cover_id = (select pc_p.p_cover_id
                            from p_cover   pc_c
                                ,as_asset  ss_c
                                ,p_cover   pc_p
                                ,as_asset  ss_p
                           where ss_c.p_policy_id           = co.policy_id
                             and pc_c.as_asset_id           = ss_c.as_asset_id
                             and pc_c.p_cover_id            = co.p_cover_id
                             and ss_p.p_policy_id           = v_prev_policy_id
                             and pc_p.as_asset_id           = ss_p.as_asset_id
                             and pc_c.t_prod_line_option_id = pc_p.t_prod_line_option_id
                             and ss_c.contact_id            = ss_p.contact_id
                          )
   where co.policy_id = p_policy_id
     and exists (select null
                  from p_cover   pc_c
                      ,as_asset  ss_c
                      ,p_cover   pc_p
                      ,as_asset  ss_p
                 where ss_c.p_policy_id           = co.policy_id
                   and pc_c.as_asset_id           = ss_c.as_asset_id
                   and pc_c.p_cover_id            = co.p_cover_id
                   and ss_p.p_policy_id           = v_prev_policy_id
                   and pc_p.as_asset_id           = ss_p.as_asset_id
                   and pc_c.t_prod_line_option_id = pc_p.t_prod_line_option_id
                   and ss_c.contact_id            = ss_p.contact_id
                );*/
  update agent_report_cont co
     set co.policy_id  = v_prev_policy_id
        ,co.p_cover_id = (select pc_p.p_cover_id
                            from p_cover    pc_c
                                ,as_asset   ss_c
                                ,as_assured su_c
                                ,p_cover    pc_p
                                ,as_asset   ss_p
                                ,as_assured su_p
                           where ss_c.p_policy_id           = co.policy_id
                             and pc_c.as_asset_id           = ss_c.as_asset_id
                             and pc_c.p_cover_id            = co.p_cover_id
                             and ss_p.p_policy_id           = v_prev_policy_id
                             and pc_p.as_asset_id           = ss_p.as_asset_id
                             and pc_c.t_prod_line_option_id = pc_p.t_prod_line_option_id
                             /*and ss_c.contact_id            = ss_p.contact_id*/
                             and ss_c.as_asset_id           = su_c.as_assured_id
                             and ss_p.as_asset_id           = su_p.as_assured_id
                             and su_c.assured_contact_id    = su_p.assured_contact_id
                          )
   where co.policy_id = p_policy_id
     and exists (select null
                  from p_cover   pc_c
                      ,as_asset  ss_c
                      ,as_assured su_c
                      ,p_cover   pc_p
                      ,as_asset  ss_p
                      ,as_assured su_p
                 where ss_c.p_policy_id           = co.policy_id
                   and pc_c.as_asset_id           = ss_c.as_asset_id
                   and pc_c.p_cover_id            = co.p_cover_id
                   and ss_p.p_policy_id           = v_prev_policy_id
                   and pc_p.as_asset_id           = ss_p.as_asset_id
                   and pc_c.t_prod_line_option_id = pc_p.t_prod_line_option_id
                   /*and ss_c.contact_id            = ss_p.contact_id*/
                   and ss_c.as_asset_id           = su_c.as_assured_id
                   and ss_p.as_asset_id           = su_p.as_assured_id
                   and su_c.assured_contact_id    = su_p.assured_contact_id
                );
  -- Проверяем, перенеслась ли вся комиссия
  /*select count(1)
    into v_cnt
    from dual
   where exists (select null
                   from agent_report_cont co
                  where co.policy_id = p_policy_id
                );
  if v_cnt = 1 then
    raise_application_error(-20001, 'Нет соответствующих рисков, чтобы перенести комиссию');
  end if;*/
  -- Удаляем комиссию, которая не перенеслась
  delete from agent_report_cont co
        where co.policy_id = p_policy_id;
  /*update agent_report_cont co
     set co.policy_id = v_prev_policy_id
   where co.policy_id = p_policy_id;*/

  -- Переносим операции на другие статусы, чтобы было возможно удаление статусов
  update oper op
     set op.doc_status_id = (select min(ds.doc_status_id)
                               from doc_status ds
                              where ds.document_id = v_prev_policy_id
                            )
   where exists(select null
                  from doc_status ds
                 where ds.document_id   = p_policy_id
                   and ds.doc_status_id = op.doc_status_id
               );
  doc.set_doc_status(p_policy_id, 'CANCEL', v_status_date, 'AUTO');
EXCEPTION
  WHEN OTHERS
  THEN
    raise_application_error(-20001, 'Ошибка при откате ('|| SQLERRM ||')');
END;
/

