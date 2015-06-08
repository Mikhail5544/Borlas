create or replace view ins.v_rep_mpos_payment_notice as
SELECT pn.mpos_payment_notice_id AS "ИД уведомления"
       ,pn.transaction_date       AS "Дата и время транзакции"
       ,pn.amount                 AS "Сумма взноса"
       ,pn.insured_name           AS "ФИО страхователя"
       ,pn.description            AS "Назначение"
       ,pn.policy_number          AS "ИДС"
       ,ps.name                   AS "Тип карты"
       ,dsrc.name                 AS "Статус"
       ,pn.transaction_id         AS "ИД транзакции"
       ,pn.cliche                 AS "Клише"
       ,pn.device_id              AS "ИД устройства в Процессинге"
       ,pn.device_name            AS "Название mPos"
       ,pn.device_model           AS "Модель mPos"
       ,mp.name                   AS "Состояние платежа"
       ,pn.rrn                    AS "RRN"
       ,pn.card_number            AS "Номер карты"
       ,dcc.reg_date              AS "Дата импорта"

  FROM mpos_payment_notice   pn
      ,payment_register_item pri
      ,document              dc
      ,t_payment_system      ps
      ,t_mpos_payment_status mp
      ,document              dcc
      ,doc_status_ref        dsrc

 WHERE pn.t_payment_system_id = ps.t_payment_system_id
   AND pn.payment_register_item_id = pri.payment_register_item_id(+)
   AND pri.ac_payment_id = dc.document_id(+)
   AND pn.t_mpos_payment_status_id = mp.t_mpos_payment_status_id
   AND pn.mpos_payment_notice_id = dcc.document_id
   AND dcc.doc_status_ref_id = dsrc.doc_status_ref_id

   
   
 
