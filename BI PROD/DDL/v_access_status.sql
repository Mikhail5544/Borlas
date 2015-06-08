create or replace force view v_access_status as
select acs.access_status_id,
         acs.sys_safety_id,
         ss.name sys_safety_name,
         acs.doc_templ_status_id,
         dsr.name doc_status_ref_name,
         dts.doc_templ_id,
         dt.name doc_templ_name
    from access_status      acs,
         sys_safety         ss,
         doc_templ_status   dts,
         doc_status_ref     dsr,
         doc_templ          dt
   where acs.sys_safety_id = ss.sys_safety_id
     and acs.doc_templ_status_id = dts.doc_templ_status_id
     and dts.doc_templ_id = dt.doc_templ_id
     and dts.doc_status_ref_id = dsr.doc_status_ref_id;

