CREATE OR REPLACE VIEW V_SMS_REPORT_BEFORE AS
SELECT prod_name
      ,contact_name
      ,init_name
      ,pol_ser
      ,pol_num
      ,ids
      ,num
      ,due_date
      ,grace_date
      ,plan_date
      ,parent_amount fee
      ,s1 zacht
      ,(nvl(child_amount, 0) - nvl(set_off_amount, 0)) to_pay
      ,parent_amount - s1 sum_fee
      ,CASE
         WHEN st_ds = 'INDEXATING' THEN
          sum_fee_idx
         ELSE
          0
       END sum_fee_idx
      ,CASE
         WHEN st_ds = 'INDEXATING' THEN
          sum_amount_idx
         ELSE
          0
       END sum_amount_idx
      ,CASE
         WHEN (nvl(child_amount, 0) - nvl(set_off_amount, 0)) > parent_amount THEN
          (nvl(child_amount, 0) - nvl(set_off_amount, 0)) - (parent_amount - s1)
         ELSE
          0
       END amount
      ,cur_brief
      ,DESCRIPTION
      ,pol_status
      ,NAME
      ,tel
      ,tel_1
      ,tel_2
      ,tel_status
      ,tel_1_status
      ,tel_2_status
      ,coll_method
      ,name_product "Программа страхования"
      ,pol_end_date "Дата окончания ДС"
      ,pkg_sms_alerts.get_sms_before_text(name_product, substr_ids, end_date_header, child_amount, set_off_amount, parent_amount, s1, ids, pol_end_date, cur_brief, st_ds, coll_method, sum_amount_idx, sum_fee_idx, plan_date, sum_amount_invest_idx) text_field
      ,contact_id
      ,'Исходящий' "Вид сообщения"
      ,'СМС ДО' "Тип сообщения"
      ,'Телефон' "Тип реквизита"
      ,'Отправлен' "Статус"
      ,'смс до-напоминание об оплате' "Тема сообщения"
      ,NULL "Дата регистрации"
      ,NULL "Номер реестра"
      ,NULL "Инициатор доставки"
      ,NULL "Порядковый номер"
      ,NULL "Комментарий"
      ,'14' || LPAD((SELECT TO_NUMBER(r.param_value)
                      FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'sms_before'
                       AND r.param_name = 'order_num') + ROWNUM - 1
                  ,6
                  ,'0') || '-' || TO_CHAR(SYSDATE, 'MM') || '/' || TO_CHAR(SYSDATE, 'YYYY') "Исходящий номер"
  FROM (SELECT cpol.obj_name_orig contact_name
              ,cpol.contact_id
              ,nvl(cpol.NAME, '') || ' ' || nvl(substr(cpol.first_name, 1, 1) || '.', '') ||
               nvl(substr(cpol.middle_name, 1, 1) || '.', '') init_name
              ,nvl(p.pol_ser, '-') pol_ser
              ,nvl(p.pol_num, '-') pol_num
              ,ph.ids
              ,da.num
              ,a.due_date
              ,a.grace_date
              ,a.plan_date
              ,doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) st_ds
              ,(SELECT SUM(ROUND(pc.fee, 2))
                  FROM p_policy           ps
                      ,as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option tplo
                      ,ins.t_product_line pl
                 WHERE ps.policy_id = ph.last_ver_id
                   AND ps.policy_id = aa.p_policy_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND pc.decline_reason_id IS NULL
                   AND pc.t_prod_line_option_id = tplo.id
                   AND tplo.product_line_id = pl.id
                   AND pl.t_lob_line_id NOT IN
                       (SELECT ll.t_lob_line_id
                          FROM ins.t_lob_line ll
                         WHERE ll.brief = 'PEPR_INVEST_RESERVE')) sum_fee_idx
              ,(SELECT SUM(ROUND(pc.ins_amount, 2))
                  FROM p_policy                ps
                      ,as_asset                aa
                      ,p_cover                 pc
                      ,t_prod_line_option      tplo
                      ,ins.t_product_line      pl
                      ,ins.t_product_line_type tplt
                      ,ins.status_hist         st
                 WHERE ps.policy_id = ph.last_ver_id
                   AND ps.policy_id = aa.p_policy_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND pc.decline_reason_id IS NULL
                   AND tplo.product_line_id = pl.id
                   AND pl.product_line_type_id = tplt.product_line_type_id
                   AND tplt.brief = 'RECOMMENDED'
                   AND st.status_hist_id = pc.status_hist_id
                   AND st.brief != 'DELETED'
                   AND pc.t_prod_line_option_id = tplo.id) sum_amount_idx
              ,(SELECT SUM(ROUND(pc.ins_amount, 2))
                  FROM p_policy            ps
                      ,as_asset            aa
                      ,p_cover             pc
                      ,t_prod_line_option  tplo
                      ,status_hist         st
                 WHERE ps.policy_id = ph.last_ver_id
                   AND ps.policy_id = aa.p_policy_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND pc.decline_reason_id IS NULL
                   AND tplo.brief in ('INVEST','INVEST2')
                   AND st.status_hist_id = pc.status_hist_id
                   AND st.brief != 'DELETED'
                   AND pc.t_prod_line_option_id = tplo.id) sum_amount_invest_idx
              ,dd.parent_amount - (SELECT NVL(SUM(ir.invest_reserve_amount), 0)
                                     FROM ins.ac_payment_ir ir
                                    WHERE ir.ac_payment_id = a.payment_id) parent_amount
              ,(SELECT SUM(dd.child_amount -
                           (SELECT NVL(ir.invest_reserve_amount, 0)
                              FROM ins.ac_payment_ir ir
                             WHERE ir.ac_payment_id = ac.payment_id))
                  FROM P_POLICY   p
                      ,ac_payment ac
                      ,DOC_DOC    dd
                      ,document   dac
                 WHERE ac.payment_id = dac.document_id
                   AND dac.doc_status_ref_id IN
                       (SELECT rf.doc_status_ref_id
                          FROM ins.doc_status_ref rf
                         WHERE rf.brief IN ('TO_PAY', 'NEW'))
                   AND ac.PAYMENT_ID = dd.CHILD_ID
                   AND p.POLICY_ID = dd.PARENT_ID
                   AND p.POL_HEADER_ID = ph.policy_header_id
                   AND (ac.plan_date <= --to_date('07.07.2012','dd.mm.yyyy') + 5
                       to_date((SELECT r.param_value
                                  FROM ins_dwh.rep_param r
                                 WHERE r.rep_name = 'sms_before'
                                   AND r.param_name = 'date_to')
                               ,'dd.mm.yyyy') + 5 OR
                       ac.plan_date <= to_date((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                 WHERE r.rep_name = 'sms_before'
                                                   AND r.param_name = 'date_to')
                                               ,'dd.mm.yyyy') + 25)
                   AND dac.DOC_TEMPL_ID IN
                       (SELECT dt.doc_templ_id FROM DOC_TEMPL dt WHERE dt.brief = 'PAYMENT')) child_amount
              ,
               
               (SELECT SUM((SELECT SUM(dsf.set_off_amount -
                                      (SELECT NVL(ir.invest_reserve_amount, 0)
                                         FROM ins.ac_payment_ir ir
                                        WHERE ir.ac_payment_id = ac.payment_id))
                             FROM doc_set_off dsf
                            WHERE dsf.PARENT_DOC_ID(+) = ac.PAYMENT_ID
                              AND Doc.get_last_doc_status_brief(dsf.doc_set_off_id) <> 'ANNULATED')) set_off_amount
                  FROM P_POLICY   p
                      ,ac_payment ac
                      ,DOC_DOC    dd
                      ,document   dac
                 WHERE dac.document_id = ac.payment_id
                   AND dac.doc_status_ref_id IN
                       (SELECT rf.doc_status_ref_id
                          FROM ins.doc_status_ref rf
                         WHERE rf.brief IN ('TO_PAY', 'NEW'))
                   AND ac.PAYMENT_ID = dd.CHILD_ID
                   AND p.POLICY_ID = dd.PARENT_ID
                   AND p.POL_HEADER_ID = ph.policy_header_id
                   AND (ac.plan_date <= --to_date('07.07.2012','dd.mm.yyyy') + 5
                       to_date((SELECT r.param_value
                                  FROM ins_dwh.rep_param r
                                 WHERE r.rep_name = 'sms_before'
                                   AND r.param_name = 'date_to')
                               ,'dd.mm.yyyy') + 5 OR
                       ac.plan_date <= to_date((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                 WHERE r.rep_name = 'sms_before'
                                                   AND r.param_name = 'date_to')
                                               ,'dd.mm.yyyy') + 25)
                   AND dac.DOC_TEMPL_ID IN
                       (SELECT dt.doc_templ_id FROM DOC_TEMPL dt WHERE dt.brief = 'PAYMENT')) set_off_amount
              ,Pkg_Payment.get_set_off_amount(a.payment_id, ph.policy_header_id, NULL) -
               NVL(Pkg_Payment.get_set_off_amount_ir(a.payment_id, ph.policy_header_id, NULL), 0) s1
              ,ph.policy_header_id
              ,p.policy_id
              ,fh.brief cur_brief
              ,pt.DESCRIPTION
              ,(SELECT rf.name
                  FROM ins.document       dta
                      ,ins.doc_status_ref rf
                 WHERE dta.document_id = pkg_policy.get_last_version(p.pol_header_id)
                   AND rf.doc_status_ref_id = dta.doc_status_ref_id) pol_status
              ,dep.name
              ,PKG_CONTACT.GET_TELEPHONE_NUMBER(cpol.contact_id
                                               ,(SELECT tt.id
                                                  FROM t_telephone_type tt
                                                 WHERE tt.description = 'Мобильный')) tel
              ,PKG_CONTACT.GET_TELEPHONE_STATE(cpol.contact_id
                                              ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.description = 'Мобильный')) tel_status
              ,PKG_CONTACT.GET_TELEPHONE_NUMBER(cpol.contact_id
                                               ,(SELECT tt.id
                                                  FROM t_telephone_type tt
                                                 WHERE tt.description = 'Рабочий телефон')) tel_1
              ,PKG_CONTACT.GET_TELEPHONE_STATE(cpol.contact_id
                                              ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.description = 'Рабочий телефон')) tel_1_status
              ,PKG_CONTACT.GET_TELEPHONE_NUMBER(cpol.contact_id
                                               ,(SELECT tt.id
                                                  FROM t_telephone_type tt
                                                 WHERE tt.description = 'Домашний телефон')) tel_2
              ,PKG_CONTACT.GET_TELEPHONE_STATE(cpol.contact_id
                                              ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.description = 'Домашний телефон')) tel_2_status
              ,colm.description coll_method
              ,prod.description name_product
              ,p.end_date pol_end_date
              ,(SELECT 1
                  FROM DUAL
                 WHERE TRUNC(p.end_date - 15) BETWEEN --to_date('05.06.2012','dd.mm.yyyy') AND to_date('07.07.2012','dd.mm.yyyy')
                       to_date((SELECT r.param_value
                                 FROM ins_dwh.rep_param r
                                WHERE r.rep_name = 'sms_before'
                                  AND r.param_name = 'date_from')
                              ,'dd.mm.yyyy')
                   AND to_date((SELECT r.param_value
                                 FROM ins_dwh.rep_param r
                                WHERE r.rep_name = 'sms_before'
                                  AND r.param_name = 'date_to')
                              ,'dd.mm.yyyy')) end_date_header
              ,SUBSTR(TO_CHAR(ph.ids), 1, 3) substr_ids
              ,prod.description prod_name
              ,CASE
                 WHEN MOD(MONTHS_BETWEEN(a.plan_date, ph.start_date), 12) = 0 THEN
                  (SELECT SUM(pc.fee)
                     FROM ins.as_asset           aa
                         ,ins.p_cover            pc
                         ,ins.t_prod_line_option tplo
                         ,ins.status_hist        st
                         ,ins.t_product_line     pl
                    WHERE aa.p_policy_id = p.policy_id
                      AND pc.as_asset_id = aa.as_asset_id
                      AND pc.t_prod_line_option_id = tplo.id
                      AND st.status_hist_id = pc.status_hist_id
                      AND st.brief != 'DELETED'
                      AND tplo.description != 'Административные издержки на восстановление'
                      AND tplo.product_line_id = pl.id
                      AND pl.t_lob_line_id NOT IN
                          (SELECT ll.t_lob_line_id
                             FROM ins.t_lob_line ll
                            WHERE ll.brief = 'PEPR_INVEST_RESERVE'))
                 ELSE
                  (SELECT SUM(pc.fee)
                     FROM ins.as_asset           aa
                         ,ins.p_cover            pc
                         ,ins.t_prod_line_option tplo
                         ,ins.status_hist        st
                         ,ins.t_product_line     pl
                    WHERE aa.p_policy_id = p.policy_id
                      AND pc.as_asset_id = aa.as_asset_id
                      AND pc.t_prod_line_option_id = tplo.id
                      AND st.status_hist_id = pc.status_hist_id
                      AND st.brief != 'DELETED'
                      AND tplo.product_line_id = pl.id
                      AND pl.t_lob_line_id NOT IN
                          (SELECT ll.t_lob_line_id
                             FROM ins.t_lob_line ll
                            WHERE ll.brief = 'PEPR_INVEST_RESERVE')
                      AND tplo.description NOT IN
                          ('Административные издержки'
                          ,'Административные издержки на восстановление'))
               END fee
          FROM p_pol_header        ph
              ,fund                fh
              ,t_product           prod
              ,department          dep
              ,p_policy            p
              ,T_PAYMENT_TERMS     pt
              ,doc_doc             dd
              ,ac_payment      a
              ,document            da
              ,fund                f
              ,ac_payment_templ    apt
              ,t_contact_type      tc
              ,t_contact_pol_role  polr
              ,p_policy_contact    pcnt
              ,contact             cpol
              ,t_collection_method colm
              ,t_sales_channel     ch
              ,ins.ven_p_policy    pp_av -- активная версия
              ,ins.doc_status_ref  dsr_av -- статус активной версии
         WHERE a.payment_templ_id = apt.payment_templ_id
           AND apt.brief = 'PAYMENT'
           AND a.payment_id = da.document_id
           AND da.doc_status_ref_id NOT IN
               (SELECT rf.doc_status_ref_id
                  FROM ins.doc_status_ref rf
                 WHERE rf.brief IN ('PAID', 'ANNULATED'))
           AND a.payment_id = dd.child_id
           AND dd.parent_id = p.policy_id
           AND ph.refuse_sms_send != 1 --Чирков 158544: Доработка - признак по договору "Отказ от услуг"
              --Чирков /192022 Доработка АС BI в части обеспечения регистрации    
           AND NOT EXISTS (SELECT 1
                  FROM ins.ven_journal_tech_work jtw
                      ,ins.doc_status_ref        dsr
                 WHERE jtw.doc_status_ref_id = dsr.doc_status_ref_id
                   AND jtw.policy_header_id = ph.policy_header_id
                   AND dsr.brief = 'CURRENT'
                   AND jtw.work_type = 0) --'Технические работы'
              --Чирков /192022//   
           AND ph.product_id = prod.product_id
           AND ph.fund_id = fh.fund_id
           AND p.pol_header_id = ph.policy_header_id
           AND pt.ID = p.PAYMENT_TERM_ID
           AND pt.DESCRIPTION NOT IN ('Единовременно')
           AND ph.agency_id = dep.department_id(+)
           AND p.collection_method_id = colm.id
           AND colm.description != 'Перечисление средств Плательщиком'
           AND ch.id = ph.sales_channel_id
           AND NOT EXISTS
         (SELECT NULL
                  FROM doc_set_off    f
                      ,ven_ac_payment acp
                      ,doc_templ      dtt
                 WHERE f.parent_doc_id = a.payment_id
                   AND acp.doc_templ_id = dtt.doc_templ_id
                   AND dtt.brief IN
                       ('PAYORDBACK', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
                   AND f.child_doc_id = acp.payment_id)
           AND (CASE
                 WHEN (SELECT rf.brief
                         FROM ins.document       dr
                             ,ins.doc_status_ref rf
                        WHERE dr.document_id = pkg_policy.get_last_version(p.pol_header_id)
                          AND dr.doc_status_ref_id = rf.doc_status_ref_id) = 'INDEXATING' THEN
                  1
                 ELSE
                  (CASE
                    WHEN colm.description = 'Прямое списание с карты' THEN
                     0
                    ELSE
                     1
                  END)
               END) = 1
           AND (CASE
                 WHEN ch.description IN
                      ('Брокерский', 'Брокерский без скидки') THEN
                  (CASE
                    WHEN ph.start_date = a.plan_date THEN
                     0
                    ELSE
                     1
                  END)
                 ELSE
                  1
               END) = 1
           AND ((tc.description = 'Физическое лицо' AND EXISTS
                (SELECT NULL
                    FROM ins.cn_person per
                   WHERE per.contact_id = cpol.contact_id
                     AND per.date_of_death IS NULL)) OR tc.description != 'Физическое лицо')
           AND ch.description IN ('SAS'
                                 ,'SAS 2'
                                 ,'DSF'
                                 ,'Брокерский'
                                 ,'Брокерский без скидки'
                                 ,'Банковский')
           AND polr.brief = 'Страхователь'
           AND pcnt.policy_id = p.policy_id
           AND pcnt.contact_policy_role_id = polr.id
           AND cpol.contact_id = pcnt.contact_id
           AND f.fund_id = a.fund_id
           --Заявка 283064: Изменения в Отчетах смс
           --Гаргонов Д.А.
           --Исключение статусов для последней версии.
           AND ph.policy_id = pp_av.policy_id
           AND pp_av.doc_status_ref_id = dsr_av.doc_status_ref_id
           AND dsr_av.brief NOT IN ('RECOVER_DENY'
                           ,'RECOVER'
                           ,'READY_TO_CANCEL'
                           ,'STOPED'
                           ,'CANCEL'
                           ,'STOP'
                           ,'BREAK'
                           ,'QUIT_DECL'
                           ,'TO_QUIT'
                           ,'TO_QUIT_CHECK_READY'
                           ,'TO_QUIT_CHECKED'
                           ,'QUIT_REQ_QUERY'
                           ,'QUIT_REQ_GET'
                           ,'QUIT_TO_PAY'
                           ,'QUIT'
                           ,'RECOVER'
                           ,'RECOVER_DENY')
           AND (SELECT rf.brief
                  FROM ins.p_pol_header   pph
                      ,ins.p_policy       pola
                      ,ins.document       dal
                      ,ins.doc_status_ref rf
                 WHERE pph.policy_header_id = ph.policy_header_id
                   AND pph.policy_id = pola.policy_id
                   AND pola.policy_id = dal.document_id
                   AND dal.doc_status_ref_id = rf.doc_status_ref_id) NOT IN ('RECOVER', 'RECOVER_DENY')
           AND tc.id = cpol.contact_type_id
           AND NOT EXISTS
         (SELECT ch.p_policy_id FROM ven_c_claim_header ch WHERE ch.p_policy_id = p.policy_id)
              --and ph.ids IN (4110204156,1560257850,4110180970)
           AND EXISTS
         (SELECT NULL
                  FROM ins.cn_contact_telephone telf
                 WHERE telf.contact_id = cpol.contact_id
                   AND telf.telephone_type IN
                       (SELECT tt.id
                          FROM ins.t_telephone_type tt
                         WHERE tt.description IN ('Мобильный'))
                   AND telf.status = 1
                   AND telf.control = 0)
           AND ((a.plan_date BETWEEN --to_date('05.06.2012','dd.mm.yyyy') + 5 and to_date('07.07.2012','dd.mm.yyyy') + 5
               to_date((SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'sms_before'
                            AND r.param_name = 'date_from')
                        ,'dd.mm.yyyy') + 5 AND
               to_date((SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'sms_before'
                            AND r.param_name = 'date_to')
                        ,'dd.mm.yyyy') + 5 OR
               a.plan_date BETWEEN --to_date('05.06.2012','dd.mm.yyyy') + 5 and to_date('07.07.2012','dd.mm.yyyy') + 5
               to_date((SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'sms_before'
                            AND r.param_name = 'date_from')
                        ,'dd.mm.yyyy') + 25 AND
               to_date((SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'sms_before'
                            AND r.param_name = 'date_to')
                        ,'dd.mm.yyyy') + 25) OR
               (prod.brief IN ('APG') AND SUBSTR(TO_CHAR(ids), 1, 3) = '156' AND
               TRUNC(p.end_date - 15) BETWEEN --to_date('05.06.2012','dd.mm.yyyy') AND to_date('07.07.2012','dd.mm.yyyy')
               to_date((SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'sms_before'
                            AND r.param_name = 'date_from')
                        ,'dd.mm.yyyy') AND to_date((SELECT r.param_value
                                                       FROM ins_dwh.rep_param r
                                                      WHERE r.rep_name = 'sms_before'
                                                        AND r.param_name = 'date_to')
                                                    ,'dd.mm.yyyy')) OR
               (prod.brief IN ('OPS_Plus', 'OPS_Plus_New') AND SUBSTR(TO_CHAR(ids), 1, 3) = '216' AND
               TRUNC(p.end_date - 15) BETWEEN --to_date('05.06.2012','dd.mm.yyyy') AND to_date('07.07.2012','dd.mm.yyyy')
               to_date((SELECT r.param_value
                           FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'sms_before'
                            AND r.param_name = 'date_from')
                        ,'dd.mm.yyyy') AND to_date((SELECT r.param_value
                                                       FROM ins_dwh.rep_param r
                                                      WHERE r.rep_name = 'sms_before'
                                                        AND r.param_name = 'date_to')
                                                    ,'dd.mm.yyyy')))
        
        )
 WHERE (parent_amount - s1) > (CASE cur_brief
         WHEN 'RUR' THEN /*300*/
          300 --Заявка 157682
         WHEN 'EUR' THEN /*10*/
          10
         WHEN 'USD' THEN /*10*/
          10
         ELSE
          300
       END)
   AND (DESCRIPTION != 'Ежемесячно' OR (DESCRIPTION = 'Ежемесячно' AND (CASE
         WHEN (nvl(child_amount, 0) - nvl(set_off_amount, 0)) > parent_amount THEN
          (nvl(child_amount, 0) - nvl(set_off_amount, 0)) - (parent_amount - s1)
         ELSE
          0
       END) < (parent_amount - s1) * 2))
;
