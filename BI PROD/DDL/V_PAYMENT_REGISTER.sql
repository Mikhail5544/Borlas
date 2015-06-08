CREATE OR REPLACE VIEW V_PAYMENT_REGISTER AS
SELECT pri.payment_register_item_id
      ,pri.ac_payment_id
      ,pri.payment_id
      ,pri.doc_num
      ,pri.payment_data
      ,pri.payer_fio
      ,pri.payer_birth
      ,pri.payer_address
      ,pri.payer_id_name
      ,pri.payer_id_ser_num
      ,pri.payer_id_issuer
      ,pri.payer_id_issue_date
      ,pri.payment_purpose
      ,pri.pol_ser
      ,pri.pol_num
      ,pri.ids
      ,pri.insured_fio
      ,pri.payment_sum
      ,pri.payment_currency
      ,pri.commission
      ,pri.commission_currency
      ,pri.territory
      ,pri.add_info
      ,pri.status
      ,pri.recognize_data
      ,pri.recognized_payment_id
      ,pri.note
      ,(SELECT pri.payment_sum - nvl(SUM(dso1.set_off_child_amount), 0)
          FROM doc_set_off dso1
         WHERE dso1.pay_registry_item = pri.payment_register_item_id
           AND dso1.cancel_date IS NULL) sum2setoff
      ,dc_pp.num
      ,acp_pp.due_date
      ,acp_pp.amount
      ,(SELECT nvl(SUM(dso.set_off_child_amount), 0)
          FROM doc_set_off dso
         WHERE dso.child_doc_id = acp_pp.payment_id
           AND dso.cancel_date IS NULL) set_off_amount
      ,dt.name title
      ,nvl(acp_pp.payer_bank_name
          ,(SELECT co.obj_name_orig FROM contact co WHERE co.contact_id = acp_pp.contact_id)) contact_name
      ,acp_pp.payer_inn -- Капля П.С. Заявка 167467 под руководством Киприча Д.
      ,cm.id collection_metod_id
      ,cm.description collection_metod_desc
      ,pri.set_off_state
      ,(SELECT ll.description
          FROM xx_lov_list ll
         WHERE ll.val = pri.set_off_state
           AND ll.name = 'PAYMENT_SET_OFF_STATE') set_off_state_descr
      ,CASE pri.status
         WHEN 50 THEN
          0 --Распознан автоматически
         WHEN 10 THEN
          1 --Условно распознан
         WHEN 20 THEN
          2 --Автоматически не распознан
         WHEN 0 THEN
          3 --Новый
         WHEN 40 THEN
          4 --Разнесён
         WHEN 30 THEN
          5 --Распознаваться не будет
         ELSE
          10
       END sort_2
      ,coalesce((SELECT gg.status_date
                  FROM insi.xx_gap_process_log gg
                 WHERE gg.document_id = acp_pp.payment_id
                   AND gg.status_id = 1)
               ,(SELECT gg.proc_date --заявка 240869
                  FROM insi.xx_gap_good gg
                 WHERE gg.code = acp_pp.code
                   AND gg.rowid = (SELECT MAX(gg_m.rowid) --284519 Чирков /иключил задвоения/
                                     FROM insi.xx_gap_good gg_m
                                    WHERE gg_m.code = gg.code))
               ,dc_pp.reg_date) AS pp_reg_date
      ,dso.parent_doc_id
       --Данные по распознаным ЭР
      ,epg.pol_num b_pol_num
      ,(SELECT co.obj_name_orig
          FROM p_policy_contact   pc
              ,t_contact_pol_role cpr
              ,contact            co
         WHERE pc.policy_id = epg.policy_id
           AND cpr.id = pc.contact_policy_role_id
           AND cpr.brief = 'Страхователь'
           AND pc.contact_id = co.contact_id) insurer_name
      ,epg.amount epg_amount
      ,epg.payment_id2 epg_payment_id
      ,epg.due_date epg_due_date
      ,epg.is_group_flag is_group_flag
      ,epg.start_date start_date_dog
      ,epg.ids num_ids
      ,epg.pol_ser num_ser
      ,epg.policy_header_id ph_id
      ,rf.brief ddso_status
      ,cm_pri.id AS reg_item_coll_method_id
      ,cm_pri.brief AS reg_item_coll_method_brief
      ,cm_pri.description AS reg_item_coll_method_name
  FROM payment_register_item pri
      ,document dc_pp
      ,ac_payment acp_pp
      ,doc_templ dt
      ,t_collection_method cm
      ,doc_set_off dso
      ,document ddso
      ,ins.doc_status_ref rf
      ,t_collection_method cm_pri
      ,( --Ветка когда реестр разнесен с ПП на ЭПГ
        SELECT acp_epg.payment_id
               ,ph1.policy_header_id
               ,pp1.pol_ser
               ,pp1.pol_num
               ,ph1.ids
               ,pp1.is_group_flag
               ,ph1.start_date
               ,pp1.policy_id
               ,acp_epg.amount
               ,acp_epg.due_date
               ,acp_epg.payment_id AS payment_id2
          FROM ac_payment   acp_epg
               ,doc_doc      dd1
               ,p_policy     pp1
               ,p_pol_header ph1
         WHERE acp_epg.payment_id = dd1.child_id
           AND dd1.parent_id = pp1.policy_id
           AND pp1.pol_header_id = ph1.policy_header_id
        UNION ALL
        --Ветка когда реестр разнесен с ПП на копию А7/ПД4
        SELECT acp_a7.document_id
               ,ph2.policy_header_id
               ,pp2.pol_ser
               ,pp2.pol_num
               ,ph2.ids
               ,pp2.is_group_flag
               ,ph2.start_date
               ,pp2.policy_id
               ,epg2.amount
               ,epg2.due_date
               ,epg2.payment_id AS payment_id2
          FROM document     acp_a7
               ,doc_doc      dd2_1
               ,doc_set_off  dso2
               ,ac_payment   epg2
               ,doc_doc      dd2
               ,p_policy     pp2
               ,p_pol_header ph2
         WHERE acp_a7.doc_templ_id IN (6432, 6533, 23095)
           AND acp_a7.document_id = dd2_1.child_id
           AND dd2_1.parent_id = dso2.child_doc_id
           AND dso2.parent_doc_id = epg2.payment_id
           AND epg2.payment_id = dd2.child_id
           AND dd2.parent_id = pp2.policy_id
           AND pp2.pol_header_id = ph2.policy_header_id) epg

 WHERE pri.ac_payment_id = acp_pp.payment_id
   AND pri.ac_payment_id = dc_pp.document_id
   AND dc_pp.doc_templ_id = dt.doc_templ_id
   AND acp_pp.collection_metod_id = cm.id
   AND pri.payment_register_item_id = dso.pay_registry_item(+)
   AND dso.doc_set_off_id = ddso.document_id(+)
   AND ddso.doc_status_ref_id = rf.doc_status_ref_id(+)
   AND pri.collection_method_id = cm_pri.id(+)
   AND dso.parent_doc_id = epg.payment_id(+);
