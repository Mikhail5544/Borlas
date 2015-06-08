CREATE OR REPLACE VIEW V_REP_ACQ_RECURRENT AS
SELECT ip.acq_internet_payment_id AS "ИД платежа"
      ,dc.reg_date  AS "Дата создания"
      ,ip.transaction_date AS "Дата и время транзакции"
      ,ip.amount AS "Сумма взноса"
      ,ip.issuer_name AS "ФИО Страхователя"
      ,ip.policy_num AS "ИДС"
      ,(SELECT tr.description FROM t_payment_terms tr WHERE tr.id = pt.t_payment_terms_id) AS "Периодичность списания"
      ,dsr.name AS "Статус"
      ,ds.start_date AS "Дата статуса"
      ,ip.bank_transaction_id AS "ИД транзакции"
      ,ip.approval_code AS "Код подтверждения (APP_CODE)"
      ,sr.description AS "Статус рез тр-и (Result)"
      ,ps.description AS "Результат тр-и в Плат. сервисе"
      ,rc.result_code AS "Рез. транзакции (Result_CODE)"
      ,rc.desc_ru_full AS "Расшифровка результата тр-и"
      ,sc.description AS "Статус 3D аутентификации"
      ,ip.rrn AS "RRN"
      ,ip.mrch_transaction_id AS "Описание"
      ,ip.card_number AS "Номер карты"
      ,pkg_kladr.get_kladr_name_by_id(pkg_policy.get_region_by_pol_header(ip.policy_header_id)) AS "Регион"
      ,pkg_agn_control.get_current_policy_agent_name(ip.policy_header_id) AS "Агент"
      ,ip.acq_writeoff_sch_id AS "ИД ЭГС"
      ,dcp.num AS "Номер шаблона"
      ,rd.acq_oms_registry_id AS "ИД реестра ОМС"
      ,ins.pkg_policy.get_pol_sales_chn(ip.policy_header_id,'descr') as "Канал продаж"

  FROM acq_internet_payment   ip
      ,document               dc
      ,doc_status             ds
      ,doc_status_ref         dsr
      ,t_acq_result_code      rc
      ,t_acq_status_result    sr
      ,t_acq_status_result_ps ps
      ,t_acq_status_3dsecure  sc
      ,acq_writeoff_sch       ws
      ,acq_oms_registry_det   rd
      ,document               dcp
      ,acq_payment_template   pt

 WHERE ip.acq_internet_payment_id = dc.document_id
   AND dc.doc_status_id = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ip.t_acq_status_result_id = sr.t_acq_status_result_id
   AND ip.t_acq_result_code_id = rc.t_acq_result_code_id
   AND ip.t_acq_status_result_ps_id = ps.t_acq_status_result_ps_id(+)
   AND ip.t_acq_status_3dsecure_id = sc.t_acq_status_3dsecure_id(+)
   AND ip.acq_writeoff_sch_id = ws.acq_writeoff_sch_id(+)
   AND ip.acq_payment_template_id = pt.acq_payment_template_id(+)
   AND pt.acq_payment_template_id = dcp.document_id(+)
   AND ip.acq_internet_payment_id = rd.acq_internet_payment_id(+)
   --AND NOT (ip.acq_payment_type_id = 2 AND dsr.brief = 'CANCEL')
   AND ip.acq_payment_type_id IN
       (dml_t_acq_payment_type.get_id_by_brief('PRIMARY_RECURRENT')
       ,dml_t_acq_payment_type.get_id_by_brief('REPEATED_RECURRENT'))
;
