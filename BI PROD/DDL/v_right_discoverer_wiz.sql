create or replace force view v_right_discoverer_wiz as
select q2.doc_id ent_id, q2.name, q2.brief
  from (select t.doc_id, t.doc_name name, t.doc_developer_key brief
          from ins_eul.eul5_documents_tab t) q2,
       (select right_obj_id
          from safety_right sr, safety_right_type srt
         where srt.brief = 'DISCOVERER'
           and srt.safety_right_type_id = sr.safety_right_type_id) q1
 where q2.doc_id = q1.right_obj_id(+)
   and (q1.right_obj_id is null);

