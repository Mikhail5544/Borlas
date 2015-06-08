CREATE OR REPLACE VIEW v_rep_mpos_writeoff_notice AS 
SELECT wn.mpos_writeoff_notice_id AS "ИД уведомления"
       ,wn.transaction_date        AS "Дата и время транзакции"
       ,wn.amount                  AS "Сумма взноса"
       ,fi.insured_name            AS "ФИО страхователя"
       ,wn.description             AS "Назначение"
       ,fi.policy_number           AS "ИДС"
       ,ps.name                    AS "Тип карты"
       ,pt.description             AS "Периодичность списания"
       ,dsrc.name                  AS "Статус"
       ,wn.transaction_id          AS "ИД транзакции"
       ,wn.cliche                  AS "Клише mPos"
       ,wn.device_id               AS "ИД устройства в Процессинге"
       ,wn.device_name             AS "Название mPos"
       ,wn.device_model            AS "Модель mPos"
       ,wn.rrn                     AS "RRN"
       ,wn.card_number             AS "Номер карты"
       ,NULL /*kl.name*/                       AS "Регион"
       ,NULL /*pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id)*/                       AS "Агент"
       ,wn.reg_date                AS "Дата импорта"
       ,fi.transaction_id          AS "ИД тр-и увед. о создании ПС"
       ,wn.writeoff_number         AS "Порядковый номер списания"
       ,wn.note                    AS "Примечание"

  FROM ven_mpos_writeoff_notice wn
      ,payment_register_item    pri
      ,document                 dc
      ,mpos_writeoff_form       fi
      ,t_payment_terms          pt
      ,t_payment_system         ps
      ,doc_status_ref           dsrc

 WHERE wn.payment_register_item_id = pri.payment_register_item_id(+)
   AND pri.ac_payment_id = dc.document_id(+)
   AND wn.mpos_writeoff_form_id = fi.mpos_writeoff_form_id(+)
   AND fi.t_payment_terms_id = pt.id
   AND wn.t_payment_system_id = ps.t_payment_system_id
   AND wn.doc_status_ref_id = dsrc.doc_status_ref_id;
