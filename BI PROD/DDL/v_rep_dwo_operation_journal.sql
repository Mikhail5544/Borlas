create or replace view v_rep_dwo_operation_journal as
SELECT vdo.dwo_operation_id AS "ИД операции"
       ,vdo.ids AS "ИДС"
       ,vdo.insured_fio AS "Страхователь"
       ,vdo.notice_fee AS "Сумма взноса"
       ,vdo.writeoff_description AS "Расшифровка рез-та списания"
       ,vdo.writeoff_datetime AS "Дата/время опер. списания"
       ,vdo.oper_status_name AS "Статус ЭС"
       ,vdo.oper_status_date AS "Дата статуса ЭС"
       ,vdo.agent AS "Агент"
       ,vdo.region_name AS "Регион"
       ,vdo.dwo_notice_id AS "ИД заявления"
       ,vdo.notice_type_description AS "Вид заявления"
       ,vdo.payer_fio AS "ФИО Плательщика"
       ,vdo.dwo_schedule_id AS "ИД графика"
       ,CASE
         WHEN vdo.prolongation_flag = 1 THEN
          'Да'
         ELSE
          'Нет'
       END "Пролонгация"
       ,vdo.operation_id_recognize AS "ИД операции для распознания"
       ,vdo.writeoff_result AS "Результат списания"
       ,vdo.notice_writeoff_date AS "Дата списания по заявлению"
       ,vdo.date_end AS "Дата окончания ЛП"
       ,vdo.download_date AS "Дата выгрузки"
       ,vdo.upload_date AS "Дата загрузки"
       ,vdo.policy_fee AS "Сумма взноса по ДС в рублях"
       ,vdo.card_type_name AS "Вид карты"
       ,vdo.card_num AS "Номер карты"
       ,vdo.notice_note AS "Примечание"
       ,vdo.writeoff_reference AS "Ссылка (банк)"
       ,vdo.check_num AS "Номер чека"
  FROM ins.v_dwo_operation vdo
 WHERE vdo.registry_type_brief IN ('TO_WRITEOFF')
   AND vdo.oper_status_brief != 'CANCEL';