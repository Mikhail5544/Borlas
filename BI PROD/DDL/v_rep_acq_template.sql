CREATE OR REPLACE VIEW v_rep_acq_template AS

SELECT dc.num AS "Номер"
       ,dc.reg_date AS "Дата регистрации"
       ,pt.fee AS "Сумма взноса"
       ,pt.admin_expenses AS "Размер админ. издержек"
       ,pt.issuer_name AS "ФИО Страхователя"
       ,pt.pol_number AS "ИДС"
       ,tr.description AS "Периодичность списания"
       ,dsr.name AS "Статус"
       ,ds.start_date AS "Дата статуса"
       ,pt.till AS "Срок действия списания"
       ,mr.name AS "Причина отказа"
       ,CASE
         WHEN dsr.brief IN ('CANCEL', 'STOPED') THEN
          ds.change_date
       END AS "Дата отказа"
       ,dsra.name AS "Статус активной версии ДС"
       ,pkg_kladr.get_kladr_name_by_id(pkg_policy.get_region_by_pol_header(pt.policy_header_id)) AS "Регион"
       ,pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id) AS "Агент"
       ,pt.acq_payment_template_id AS "ИД шаблона"
       ,pt.acq_internet_payment_id AS "ИД платежа"
       ,pt.policy_start_date AS "Дата нач. ДС по Заявлению"
       ,pt.policy_end_date AS "Дата окончания ДС по Заявлению"
       ,pt.cell_phone AS "Мобильный"
       ,f.brief AS "Валюта"
       ,dc.note AS "Комментарий"

  FROM ins.acq_payment_template pt
      ,ins.document             dc
      ,ins.t_payment_terms      tr
      ,ins.doc_status           ds
      ,ins.doc_status_ref       dsr
      ,ins.t_mpos_rejection     mr
      ,ins.p_pol_header         ph
      ,ins.doc_status_ref       dsra
      ,ins.fund                 f

 WHERE pt.acq_payment_template_id = dc.document_id
   AND pt.t_payment_terms_id = tr.id(+)
   AND dc.doc_status_id = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND pt.t_mpos_rejection_id = mr.t_mpos_rejection_id(+)
   AND pt.policy_header_id = ph.policy_header_id(+)
   AND pt.current_status_ref_id = dsra.doc_status_ref_id(+)
   AND pt.pay_fund_id = f.fund_id(+)
