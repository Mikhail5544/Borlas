CREATE OR REPLACE VIEW V_DWO_OPERATION AS
SELECT
/*
Операции по заявлению прямого списания
Черных М.Г. 30.07.2014
*/
 do.dwo_operation_id
,do_dsr.name               oper_status_name
,do_dsr.brief              oper_status_brief
,dc_do.doc_status_ref_id   oper_status_ref_id
,dc_do.reg_date            operation_date
,do_ds.start_date          oper_status_date
,do.dwo_notice_id
,do.product_name
,do.insured_fio
,do.insured_id
,do.card_type_id
,do.ids
,do.policy_fee
,do.notice_fee
,do.pay_fund_name
,do.payer_fio
,do.payer_id
,do.agent
,do.cell_phone
,do.notice_writeoff_date
,do.plan_end_date
,do.region_name
,do.region_id
,do.upload_date
,do.download_date
,do.pol_last_status
,do.writeoff_result
,do.writeoff_description
,do.writeoff_reference
,do.check_num
,do.author_id
,do.registry_ref_writeoff
,do.registry_ref_result
,do.prolongation_flag
,do.dwo_ext_id
,do.pay_fund_id
,do.writeoff_datetime
,do.operation_id_recognize
,dsr.name                  registry_status_name
,dsr.brief                 registry_status_brief
,dr.dwo_oper_registry_id
,dr.registry_type_id
,dr.creation_date
,dr.file_path
,drt.brief registry_type_brief
,drt.description registry_type_desc
,tdnt.description notice_type_description
,dc_dn.note notice_note
,tps.name card_type_name
,regexp_replace(dn.card_num, '^(\d{4})(\d{8})(\d{4})$', '\1********\3') card_num
,do.dwo_schedule_id
,ds.date_start schedule_start_date
,ds.date_end
,dr.start_date registry_start_date
,dr.end_date registry_end_date
,do.PAYMENT_REGISTER_ITEM_ID  --ИД элемента реестра платежей
,dn.policy_header_id
  FROM dwo_operation       do
      ,dwo_oper_registry   dr
      ,document            dc_dr
      ,doc_status_ref      dsr
      ,t_dwo_registry_type drt
      ,document            dc_do
      ,doc_status_ref      do_dsr
      ,doc_status          do_ds
      ,dwo_notice          dn
      ,document            dc_dn
      ,t_dwo_notice_type   tdnt
      ,t_payment_system    tps
      ,dwo_schedule        ds
 WHERE do.dwo_oper_registry_id = dr.dwo_oper_registry_id
   AND dr.dwo_oper_registry_id = dc_dr.document_id
   AND dc_dr.doc_status_ref_id = dsr.doc_status_ref_id
   AND dr.registry_type_id = drt.t_dwo_registry_type_id
   AND do.dwo_operation_id = dc_do.document_id
   AND dc_do.doc_status_ref_id = do_dsr.doc_status_ref_id
   AND dc_do.doc_status_id = do_ds.doc_status_id
   AND do.dwo_notice_id = dn.dwo_notice_id(+)
   AND dn.notice_type_id = tdnt.t_dwo_notice_type_id(+)
   AND dn.dwo_notice_id = dc_dn.document_id(+)
   AND dn.card_type_id = tps.t_payment_system_id(+)
   AND do.dwo_schedule_id = ds.dwo_schedule_id(+)
;
