create materialized view INS_DWH.MV_CR_LIST_DOC_STATUS
build deferred
refresh force on demand
as
select distinct dsr.brief, dsr.doc_status_ref_id,dsr.name
from ins.ven_doc_status ds
join ins.ven_doc_status_ref dsr on dsr.doc_status_ref_id = ds.doc_status_ref_id
join ins.ven_p_policy pp on ds.document_id = pp.policy_id;

