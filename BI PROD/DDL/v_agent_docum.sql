create or replace force view v_agent_docum as
select d.document_id document_id, 
       d.num         contract_num,
       d.reg_date    reg_date,
       d.note        note,
       ds.doc_status_id doc_status_id,
       ds.start_date status_date,
       dsr.name      status_name,
       dsr.brief     status_brief
from ven_document d,
     ven_doc_templ    dt,
     ven_doc_templ_status dts,
     ven_doc_status ds,
     ven_doc_status_ref dsr
where d.doc_templ_id=dt.doc_templ_id
  and dts.doc_templ_id=dt.doc_templ_id
  and dts.doc_status_ref_id=dsr.doc_status_ref_id
  and ds.doc_status_ref_id=dsr.doc_status_ref_id
  and ds.document_id=d.document_id
  and dt.brief='AG_CONTRACT_HEADER';

