create or replace force view v_cr_list_doc_status as
select distinct dsr.brief, dsr.doc_status_ref_id,dsr.name
from ven_doc_status ds
join ven_doc_status_ref dsr on dsr.doc_status_ref_id = ds.doc_status_ref_id
join ven_p_policy pp on ds.document_id = pp.policy_id;

