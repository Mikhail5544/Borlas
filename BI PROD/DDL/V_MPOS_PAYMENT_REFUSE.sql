CREATE OR REPLACE VIEW V_MPOS_PAYMENT_REFUSE AS
SELECT
/*
Платежи mPos, по которым результат "Отказ"
17.09.2014 Черных М.
*/
 wn.mpos_writeoff_notice_id
,wn.processing_policy_number
,fi.policy_number ids /*Номер ДС из Уведомления о создании ПС - ИДС*/
,fi.insured_name
,wn.amount
,wn.transaction_date
,wn.work_status /*Статус обработки*/
,wn.transaction_id
,wn.rrn
,wn.processing_result /*Результат списания*/
,wn.cliche
,ps.name /*Тип карты*/
,dsrc.name oper_status_name /*Статус операции*/
,wn.device_name /*Устройство*/
,wn.card_number /*Номер карты*/
,wn.doc_status_id
,wn.doc_status_ref_id
,wn.note
,wn.num
,wn.reg_date
,wn.description
,wn.device_id
,wn.device_model
,wn.g_mpos_id
,wn.mpos_writeoff_form_id
,wn.payment_register_item_id
,wn.terminal_bank_id
,wn.t_payment_system_id
,wn.writeoff_number
,wn.processing_status
,mr.result_code
,mr.process_description  /*Результат списания из Процессинга*/
,mr.personal_description /*Расшифровка результата списания из ЛК 2Can*/
,pkg_agn_control.get_current_policy_agent_name(fi.policy_header_id) agent_name /*Действующий агент*/
,(SELECT t.name
    FROM t_kladr t
   WHERE t.t_kladr_id = pkg_policy.get_region_by_pol_header(fi.policy_header_id)) region_name /*Регион*/
  FROM ven_mpos_writeoff_notice wn
      ,mpos_writeoff_form       fi
      ,t_payment_terms          pt
      ,t_payment_system         ps
      ,doc_status_ref           dsrc
      ,t_mpos_result            mr
 WHERE wn.mpos_writeoff_form_id = fi.mpos_writeoff_form_id(+)
   AND fi.t_payment_terms_id = pt.id (+)
   AND wn.t_payment_system_id = ps.t_payment_system_id
   AND wn.doc_status_ref_id = dsrc.doc_status_ref_id
   AND dsrc.brief IN ('PROJECT', 'REFUSE')
   and wn.work_status is not null /*Платежи, по которым отказ, загруженные через УЗ*/
   AND wn.t_mpos_result_id = mr.t_mpos_result_id(+);
