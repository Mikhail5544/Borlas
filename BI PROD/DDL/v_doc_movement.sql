create or replace force view v_doc_movement as
select d.document_id,
       d.num document_num,
       d.reg_date document_date,
       dt.name doc_templ_name,
       dt.brief doc_templ_brief,
       dsr.name doc_status_name,
       dsr.brief doc_status_brief,
       dm.doc_movement_id,
       dm.fact_start_date,
       dm.plan_end_date,
       dm.t_dm_status_id,
       dms.name as dm_status,
       dm.person_to_id
  from doc_movement dm,
       doc_templ dt,
       v_doc_status ds,
       document d,
       sys_user su,
       employee e,
       doc_status_ref dsr,
       ven_t_dm_status dms
 where 
   su.sys_user_name = user --'ABALASHOV'
   and 
   su.employee_id = e.employee_id
   and dm.person_to_id = e.contact_id
   and d.document_id = dm.document_id
   and d.doc_templ_id = dt.doc_templ_id
   and ds.document_id = d.document_id
   and dsr.doc_status_ref_id = ds.doc_status_ref_id
   and dm.t_dm_status_id=dms.t_dm_status_id(+)
order by dm.t_dm_status_id desc, dm.fact_start_date desc
;

