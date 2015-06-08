create or replace force view v_access_doc_templ as
select adt.access_doc_templ_id,
  adt.doc_templ_id, dt.name doc_templ_name,
  adt.sys_safety_id, ss.name sys_safety_name, adt.access_level_id,
  al.name access_level_name, al.brief access_level_brief
    from access_doc_templ adt, sys_safety ss, doc_templ dt, access_level al
    where adt.sys_safety_id = ss.sys_safety_id
    and adt.doc_templ_id = dt.doc_templ_id
    and adt.access_level_id = al.access_level_id;

