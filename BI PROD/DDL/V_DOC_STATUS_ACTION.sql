CREATE OR REPLACE VIEW V_DOC_STATUS_ACTION AS 
SELECT dt.doc_templ_id
      ,dt.name                      doc_templ_name
      ,dt.brief                     doc_templ_brief
      ,e.ent_id                     entity_id
      ,e.brief                      entity_brief
      ,e.name                       entity_name
      ,dsa.doc_status_allowed_id
      ,dsa.is_del_trans
      ,dsa.is_auto_only
      ,dsa.is_storno_trans
      ,dsa.plan_duration
      ,dsa.respons_pers
      ,dsa.note
      ,dsa.src_doc_templ_status_id
      ,dsa.dest_doc_templ_status_id
      ,dsr_src.doc_status_ref_id    src_dsr_id
      ,dsr_src.name                 src_dsr_name
      ,dsr_src.brief                src_dsr_brief
      ,dsr_dest.doc_status_ref_id   dest_dsr_id
      ,dsr_dest.name                dest_dsr_name
      ,dsr_dest.brief               dest_dsr_brief
      ,dsan.doc_status_action_id
      ,dsan.sort_order
      ,dsan.is_execute
      ,dsan.is_required
      ,dsan.obj_ure_id
      ,dsan.obj_uro_id
      ,dp.name                      proc_description
      ,dp.proc_name
      ,ot.oper_templ_id
      ,ot.name                      oper_templ_name
      ,ot.brief                     oper_templ_brief
  FROM doc_templ          dt
      ,entity             e
      ,doc_templ_status   dts_src
      ,doc_status_ref     dsr_src
      ,doc_status_allowed dsa
      ,doc_templ_status   dts_dest
      ,doc_status_ref     dsr_dest
      ,doc_status_action  dsan
      ,doc_action_type    dat
      ,doc_procedure      dp
      ,oper_templ         ot
 WHERE dts_src.doc_templ_id = dt.doc_templ_id
   AND dsr_src.doc_status_ref_id = dts_src.doc_status_ref_id
   AND dsa.src_doc_templ_status_id = dts_src.doc_templ_status_id
   AND dts_dest.doc_templ_status_id = dsa.dest_doc_templ_status_id
   AND dsr_dest.doc_status_ref_id = dts_dest.doc_status_ref_id
   AND dsan.doc_status_allowed_id = dsa.doc_status_allowed_id
   AND dat.doc_action_type_id = dsan.doc_action_type_id
   AND dsan.obj_uro_id = dp.doc_procedure_id(+)
   AND dsan.obj_ure_id = dp.ent_id(+)
   AND dsan.obj_uro_id = ot.oper_templ_id(+)
   AND dsan.obj_ure_id = ot.ent_id(+)
   AND dt.doc_ent_id = e.ent_id(+);
	 
grant select on V_DOC_STATUS_ACTION to ins_read;
