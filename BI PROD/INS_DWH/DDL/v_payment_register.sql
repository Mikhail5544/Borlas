CREATE OR REPLACE VIEW INS_DWH.V_PAYMENT_REGISTER AS
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
          FROM ins.doc_set_off dso1
         WHERE dso1.pay_registry_item = pri.payment_register_item_id
           AND dso1.cancel_date IS NULL) sum2setoff
      ,acp_pp.num
      ,acp_pp.due_date
      ,acp_pp.amount
      ,(SELECT nvl(SUM(dso.set_off_child_amount), 0)
          FROM ins.doc_set_off dso
         WHERE dso.child_doc_id = acp_pp.payment_id
           AND dso.cancel_date IS NULL) set_off_amount
      ,dt.name title
      ,nvl(acp_pp.payer_bank_name, ins.ent.obj_name('CONTACT', acp_pp.contact_id)) contact_name
      ,cm.id collection_metod_id
      ,cm.description collection_metod_desc
      ,pri.set_off_state
      ,(SELECT ll.description
          FROM ins.xx_lov_list ll
         WHERE ll.val(+) = pri.set_off_state
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
         WHEN 60 THEN
          6 --Ошибочное перечисление
         WHEN 70 THEN
          7 --Возвращено
         ELSE
          10
       END sort_2
      ,
       
       --Данные по распознаным ЭР
       coalesce(pp1.pol_num, pp2.pol_num) b_pol_num
      ,(SELECT cont.obj_name_orig insurer_name
          FROM ins.p_policy_contact   pc
              ,ins.contact            cont
              ,ins.t_contact_pol_role cpr
         WHERE pc.policy_id = coalesce(pp1.policy_id, pp2.policy_id)
           AND cont.contact_id = pc.contact_id
           AND pc.contact_policy_role_id = cpr.id
           AND cpr.brief = 'Страхователь') insurer_name
      ,(SELECT dep.name
          FROM ins.p_policy_agent_doc pad
              ,ins.ag_contract_header agh
              ,ins.ag_contract        ag
              ,ins.department         dep
         WHERE pad.policy_header_id = coalesce(ph1.policy_header_id, ph2.policy_header_id)
           AND pad.ag_contract_header_id = agh.ag_contract_header_id
           AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           AND nvl(agh.is_new, 0) = 1
           AND agh.ag_contract_header_id = ag.contract_id
           AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
           AND ag.agency_id = dep.department_id) dep_name
      ,(SELECT c.obj_name_orig
          FROM ins.p_policy_agent_doc pad
              ,ins.ag_contract_header agh
              ,ins.contact            c
         WHERE pad.policy_header_id = coalesce(ph1.policy_header_id, ph2.policy_header_id)
           AND pad.ag_contract_header_id = agh.ag_contract_header_id
           AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           AND nvl(agh.is_new, 0) = 1
           AND agh.agent_id = c.contact_id) ag_name
      ,(SELECT c.obj_name_orig
          FROM ins.p_policy_agent_doc pad
              ,ins.ag_contract_header agh
              ,ins.ag_contract        ag
              ,ins.ag_contract        agl
              ,ins.ag_contract_header aghl
              ,ins.contact            c
         WHERE pad.policy_header_id = coalesce(ph1.policy_header_id, ph2.policy_header_id)
           AND pad.ag_contract_header_id = agh.ag_contract_header_id
           AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           AND nvl(agh.is_new, 0) = 1
           AND agh.ag_contract_header_id = ag.contract_id
           AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
           AND ag.contract_leader_id = agl.ag_contract_id
           AND agl.contract_id = aghl.ag_contract_header_id
           AND aghl.agent_id = c.contact_id) leader_name
      ,coalesce(epg1.amount, epg2.amount) epg_amount
      ,coalesce(epg1.due_date, epg2.due_date) epg_due_date
      ,epg3.due_date a7_due_date
      ,epg3.num a7_num
      ,coalesce(pp1.is_group_flag, pp2.is_group_flag) is_group_flag
      ,coalesce(ph1.start_date, ph2.start_date) start_date_dog
      ,coalesce(ph1.ids, ph2.ids) num_ids
      ,coalesce(pp1.pol_ser, pp2.pol_ser) num_ser
      ,coalesce(ph1.policy_header_id, ph2.policy_header_id) ph_id
      ,coalesce(dd1.parent_amount, dd2.parent_amount) pay_amount
      ,ins.pkg_payment.get_set_off_amount(coalesce(dd1.child_id, dd2.child_id)
                                         ,coalesce(ph1.policy_header_id, ph2.policy_header_id)
                                         ,NULL) part_pay_amount
      ,coalesce(colm1.description, colm2.description) paym_term
      ,xx_g.receiver_account xx_receiver_account
      ,xx_g.receiver_bank_name xx_receiver_bank_name
      ,nvl((SELECT gg.status_date
             FROM insi.xx_gap_process_log gg
            WHERE gg.document_id = acp_pp.payment_id
              AND gg.status_id = 1)
          ,acp_pp.reg_date) AS reg_date
      ,(SELECT tcm.description
          FROM ins.t_collection_method tcm
         WHERE tcm.id = pri.collection_method_id) reg_item_coll_method_name
  FROM ins.payment_register_item pri
      ,ins.ven_ac_payment acp_pp
      ,ins.doc_templ dt
      ,ins.t_collection_method cm
      ,ins.doc_set_off dso
      ,(SELECT * FROM ins.ven_ac_payment acp_epg WHERE acp_epg.doc_templ_id = 4) epg1
      ,ins.doc_doc dd1
      ,ins.p_policy pp1
      ,ins.t_collection_method colm1
      ,ins.p_pol_header ph1
      ,(SELECT * FROM ins.ven_ac_payment acp_a7 WHERE acp_a7.doc_templ_id IN (6432, 6533)) a7_copy
      ,ins.doc_doc dd2_1
      ,(SELECT * FROM ins.ven_ac_payment WHERE cancel_date IS NULL) epg3
      ,ins.doc_set_off dso2
      ,ins.ven_ac_payment epg2
      ,ins.doc_doc dd2
      ,ins.p_policy pp2
      ,ins.t_collection_method colm2
      ,ins.p_pol_header ph2
      ,insi.xx_gap_good xx_g
 WHERE pri.ac_payment_id = acp_pp.payment_id
   AND dt.doc_templ_id = acp_pp.doc_templ_id
   AND cm.id = acp_pp.collection_metod_id
   AND pri.payment_register_item_id = dso.pay_registry_item(+)
      --Ветка когда реестр разнесен с ПП на ЭПГ
   AND dso.parent_doc_id = epg1.payment_id(+)
   AND epg1.payment_id = dd1.child_id(+)
   AND dd1.parent_id = pp1.policy_id(+)
   AND pp1.pol_header_id = ph1.policy_header_id(+)
   AND pp1.collection_method_id = colm1.id(+)
      --Ветка когда реестр разнесен с ПП на копию А7/ПД4
   AND dso.parent_doc_id = a7_copy.payment_id(+)
   AND a7_copy.payment_id = dd2_1.child_id(+)
      
   AND dd2_1.child_id = epg3.payment_id(+)
      
   AND dd2_1.parent_id = dso2.child_doc_id(+)
   AND dso2.parent_doc_id = epg2.payment_id(+)
   AND epg2.payment_id = dd2.child_id(+)
   AND dd2.parent_id = pp2.policy_id(+)
   AND pp2.pol_header_id = ph2.policy_header_id(+)
   AND pp2.collection_method_id = colm2.id(+)
   AND acp_pp.code = xx_g.code(+)

 ORDER BY sort_2
         ,abs(sum2setoff) DESC
/*select count(dep.department_id), pad.policy_header_id
          from ins.p_policy_agent_doc pad,
               ag_contract_header agh,
               ag_contract ag,
               department dep
          where pad.ag_contract_header_id = agh.ag_contract_header_id
                and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                and nvl(agh.is_new,0) = 0
                and agh.last_ver_id = ag.ag_contract_id
                and ag.agency_id = dep.department_id
group by pad.policy_header_id
having count(dep.department_id) > 1*/
;
