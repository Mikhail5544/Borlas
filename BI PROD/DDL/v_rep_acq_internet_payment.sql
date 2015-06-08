CREATE OR REPLACE VIEW v_rep_acq_internet_payment AS
SELECT ip.acq_internet_payment_id   AS "ID платежа"
       ,ip.transaction_date          AS "Дата и время транзакции"
       ,ip.amount                    AS "Сумма взноса"
       ,ip.issuer_name               AS "ФИО Страхователя"
       ,ip.policy_num                AS "ИДС"
       ,dsr.name                     AS "Статус"
       ,ip.bank_transaction_id       AS "ИД транзакции"
       ,ip.email                     AS "Электронный адрес"
       ,ip.approval_code             AS "Код подтверждения (APP_CODE)"
       ,sr.description               AS "Статус рез. тр-и (Result)"
       ,ps.description               AS "Рез. тр-и в Плат-м сервисе"
       ,rc.result_code               AS "Рез. тр-и (Result_CODE)"
       ,rc.desc_ru_full              AS "Расшифровка результата тр-и"
       ,sc.description               AS "Статус 3D аутентификации"
       ,ip.rrn                       AS "RRN"
       ,ip.mrch_transaction_id       AS "Описание"
       ,ip.card_number               AS "Номер карты"
       ,rd.acq_oms_registry_id       AS "ИД реестра ОМС"
       ,rd.acq_oms_registry_det_id   AS "ИД детализации реестра ОМС"

  FROM acq_internet_payment   ip
      ,document               dc
      ,doc_status_ref         dsr
      ,t_acq_result_code      rc
      ,t_acq_status_result    sr
      ,t_acq_status_result_ps ps
      ,t_acq_status_3dsecure  sc
      ,acq_oms_registry_det   rd

 WHERE ip.acq_internet_payment_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
   AND ip.t_acq_status_result_id = sr.t_acq_status_result_id
   AND ip.t_acq_result_code_id = rc.t_acq_result_code_id
   AND ip.t_acq_status_result_ps_id = ps.t_acq_status_result_ps_id
   AND ip.t_acq_status_3dsecure_id = sc.t_acq_status_3dsecure_id(+)
   AND ip.acq_internet_payment_id = rd.acq_internet_payment_id(+)
   AND ip.acq_payment_type_id = dml_t_acq_payment_type.get_id_by_brief('SINGLE')
