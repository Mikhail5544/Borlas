create or replace force view v_right_docstatus_wiz as
select q2.doc_templ_status_id ent_id,
       q2.name,
       q2.brief
  from (select dsa.doc_status_allowed_id doc_templ_status_id,
               dt.name||'.'||dsr1.name||'.'||dsr2.name name,
               dt.brief||'.'||dsr1.brief||'.'||dsr2.brief brief
          from doc_templ_status dts1, doc_templ dt, doc_status_ref dsr1,
          doc_templ_status dts2, doc_status_ref dsr2, doc_status_allowed dsa
          where dt.doc_templ_id = dts1.doc_templ_id
          and dsr1.doc_status_ref_id = dts1.doc_status_ref_id
          and dsa.src_doc_templ_status_id = dts1.doc_templ_status_id
          and dsa.dest_doc_templ_status_id = dts2.doc_templ_status_id
          and dsr2.doc_status_ref_id = dts2.doc_status_ref_id
         ) q2,
       (select right_obj_id
          from safety_right sr, safety_right_type srt
         where srt.brief = 'DOCSTATUS'
           and srt.safety_right_type_id = sr.safety_right_type_id) q1
 where q2.doc_templ_status_id = q1.right_obj_id(+)
   and (q1.right_obj_id is null);

