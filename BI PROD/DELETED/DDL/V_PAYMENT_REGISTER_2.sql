CREATE OR REPLACE VIEW V_PAYMENT_REGISTER AS
SELECT   pri.PAYMENT_REGISTER_ITEM_ID,
         pri.AC_PAYMENT_ID,
         pri.PAYMENT_ID,
         pri.DOC_NUM,
         pri.PAYMENT_DATA,
         pri.PAYER_FIO,
         pri.PAYER_BIRTH,
         pri.PAYER_ADDRESS,
         pri.PAYER_ID_NAME,
         pri.PAYER_ID_SER_NUM,
         pri.PAYER_ID_ISSUER,
         pri.PAYER_ID_ISSUE_DATE,
         pri.PAYMENT_PURPOSE,
         pri.POL_SER,
         pri.POL_NUM,
         pri.IDS,
         pri.INSURED_FIO,
         pri.PAYMENT_SUM,
         pri.PAYMENT_CURRENCY,
         pri.COMMISSION,
         pri.COMMISSION_CURRENCY,
         pri.TERRITORY,
         pri.ADD_INFO,
         pri.STATUS,
         pri.RECOGNIZE_DATA,
         pri.RECOGNIZED_PAYMENT_ID,
         pri.NOTE,
         (SELECT pri.payment_sum - NVL(SUM(dso1.set_off_child_amount), 0)
            FROM Doc_Set_Off dso1
           WHERE dso1.pay_registry_item = pri.payment_register_item_id
             AND dso1.cancel_date IS NULL) sum2setoff,
         acp_pp.num,
         acp_pp.due_date,
         acp_pp.amount,
         (SELECT NVL(SUM(dso.set_off_child_amount), 0)
            FROM Doc_Set_Off dso
           WHERE dso.child_doc_id = acp_pp.payment_id
             AND dso.cancel_date IS NULL) Set_Off_Amount,
         dt.NAME title,
         ent.obj_name('CONTACT', acp_pp.contact_id) contact_name,
         cm.id collection_metod_id,
         cm.DESCRIPTION collection_metod_desc,
         pri.set_off_state,
         (SELECT ll.description
           FROM xx_lov_list ll
          WHERE ll.val (+) = pri.set_off_state
            AND ll.NAME = 'PAYMENT_SET_OFF_STATE') set_off_state_descr,
         CASE pri.STATUS
            WHEN 50 THEN 0                                                 --Распознан автоматически
            WHEN 10 THEN 1                                                       --Условно распознан
            WHEN 20 THEN 2                                              --Автоматически не распознан
            WHEN 0 THEN 3                                                                    --Новый
            WHEN 40 THEN 4                                                                --Разнесён
            WHEN 30 THEN 5                                                 --Распознаваться не будет
            ELSE 10
         END sort_2,

         --Данные по распознаным ЭР
         coalesce(pp1.pol_num,pp2.pol_num) b_pol_num,
         (SELECT cont.obj_name_orig insurer_name
            FROM P_POLICY_CONTACT pc,
                 CONTACT cont,
                 T_CONTACT_POL_ROLE cpr
           WHERE pc.policy_id = coalesce(pp1.policy_id,pp2.policy_id)
             AND cont.contact_id = pc.contact_id
             AND pc.contact_policy_role_id = cpr.ID
             AND cpr.brief = 'Страхователь') insurer_name,
         coalesce(epg1.amount, epg2.amount) epg_amount,
         coalesce(epg1.due_date, epg2.due_date) epg_due_date,
         coalesce(pp1.is_group_flag,pp2.is_group_flag) is_group_flag,
         coalesce(ph1.start_date, ph2.start_date) start_date_dog,
         coalesce(ph1.Ids, ph2.Ids) num_ids,
         coalesce(pp1.pol_ser, pp2.pol_ser) num_ser,
         COALESCE(ph1.policy_header_id, ph2.policy_header_id) ph_id
        ,nvl((select gg.status_date
               from insi.xx_gap_process_log gg
              where gg.document_id = acp_pp.payment_id
                and gg.status_id   = 1
             ),acp_pp.reg_date) as pp_reg_date
    FROM payment_register_item pri,
         ven_ac_payment acp_pp,
         doc_templ dt,
         t_collection_method cm,
         doc_set_off dso,
         (SELECT * FROM ven_ac_payment acp_epg WHERE acp_epg.doc_templ_id = 4) epg1,
         doc_doc dd1,
         p_policy pp1,
         p_pol_header ph1,
         --Чироков 23.11.2011
         --(SELECT * FROM ven_ac_payment acp_a7 WHERE acp_a7.doc_templ_id IN (6432,6533)) a7_copy,
         (SELECT * FROM ven_ac_payment acp_a7, doc_templ dt_a7
         WHERE dt_a7.doc_templ_id = acp_a7.doc_templ_id
         and dt_a7.brief IN ('A7COPY','PD4COPY', 'ЗачетУ_КВ_COPY')) a7_copy,
         --
         doc_doc dd2_1,
         doc_set_off dso2,
         ven_ac_payment epg2,
         doc_doc dd2,
         p_policy pp2,
         p_pol_header ph2
   WHERE pri.ac_payment_id = acp_pp.payment_id
     AND dt.doc_templ_id = acp_pp.doc_templ_id
     AND cm.ID =  acp_pp.collection_metod_id
     AND pri.payment_register_item_id = dso.pay_registry_item (+)
     --Ветка когда реестр разнесен с ПП на ЭПГ
     AND dso.parent_doc_id = epg1.payment_id (+)
     AND epg1.payment_id = dd1.child_id (+)
     AND dd1.parent_id = pp1.policy_id (+)
     AND pp1.pol_header_id = ph1.policy_header_id (+)
     --Ветка когда реестр разнесен с ПП на копию А7/ПД4
     AND dso.parent_doc_id = a7_copy.payment_id (+)
     AND a7_copy.payment_id = dd2_1.child_id (+)
     AND dd2_1.parent_id = dso2.child_doc_id (+)
     AND dso2.parent_doc_id = epg2.payment_id (+)
     AND epg2.payment_id = dd2.child_id (+)
     AND dd2.parent_id = pp2.policy_id (+)
     AND pp2.pol_header_id = ph2.policy_header_id (+)
ORDER BY sort_2, abs(sum2setoff) DESC;
