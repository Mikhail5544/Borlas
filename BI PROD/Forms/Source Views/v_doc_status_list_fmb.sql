create or replace view v_doc_status_list_fmb as
-- Вьюха для блока DB_E формы DOC_STATUS_LIST
SELECT ds.doc_status_id
      ,ds.src_doc_status_ref_id
      ,ds.doc_status_ref_id
      ,dsr.name dest_doc_status_name
      ,sdsr.name src_doc_status_name
      ,ds.document_id
      ,ds.start_date
      ,ds.user_name
      ,ds.change_date
      ,ds.note
			,ds.call_stack
      ,ds.status_change_type_id
      ,sct.name status_change_type_name
  FROM ven_doc_status     ds
      ,doc_status_ref     dsr
      ,doc_status_ref     sdsr
      ,status_change_type sct
 WHERE ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ds.src_doc_status_ref_id = sdsr.doc_status_ref_id
   AND ds.status_change_type_id = sct.status_change_type_id;
	 
grant select on	v_doc_status_list_fmb to ins_read;
