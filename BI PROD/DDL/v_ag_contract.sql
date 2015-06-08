create or replace force view v_ag_contract as
select cont.ag_contract_header_id contract_id,
       ag.contact_id         agent_id,
       ag.contact_name       agent_name,
       cont.date_begin       date_begin,
--       cont.date_end         date_end,
       cont.last_ver_id      last_ver_contract_id,
       ad.contract_num       contract_num,
       ad.note               comments,
       doc.get_doc_status_name(ad.document_id,sysdate) status_name,
       (select vds.start_date
        from ven_doc_status vds
        where vds.doc_status_id=doc.get_doc_status_id(ad.document_id,sysdate)) status_date
 from v_agent ag,
      v_agent_docum ad,
      ven_ag_contract_header cont
where ag.contact_id=cont.agent_id
  and cont.ag_contract_header_id=ad.document_id
  and ad.status_date=(select max(status_date) from v_agent_docum where document_id=ad.document_id)
;

