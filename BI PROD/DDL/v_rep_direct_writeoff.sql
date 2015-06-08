CREATE OR REPLACE VIEW v_rep_direct_writeoff AS 
SELECT ids                     AS "ИДС"
       ,contact_name            AS "ФИО"
       ,dwo_notice_id           AS "ID заявления на ПС"
       ,NAME                    AS "Статус заявления на ПС"
       ,start_date              AS "Дата статуса"
       ,mpos_writeoff_form_id   AS "ID mPos"
       ,mpos_status             AS "Статус уведомления mPos"
       ,mpos_start_date         AS "Дата статуса mPos"
       ,acq_payment_template_id AS "ID Эквайринг"
       ,acq_start_date          AS "Дата статуса заявления"

  FROM v_dwo_jornal;
