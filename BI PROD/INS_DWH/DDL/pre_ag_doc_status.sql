create materialized view INS_DWH.PRE_AG_DOC_STATUS
refresh force on demand
as
select
   dd.date_id, dd.sql_date, nvl(ag_doc_status.ag_contract_header_id,-1) ag_contract_header_id,
   ag_doc_status.ag_contract_id,
   ag_doc_status.status,
   ag_doc_status.status_brief

     from dm_date dd,
          dm_ag_contract_header dm_ah,
            (select trunc(ds.change_date, 'dd') begin_date,
                    nvl(trunc(lead(ds.change_date)
                              over(partition by ds.document_id order by
                                   ds.change_date),
                              'dd') - 1,
                        ac.date_end) end_date,
                    ac.contract_id ag_contract_header_id,
                    ac.ag_contract_id ag_contract_id,
                    sr.name status,
                    sr.brief status_brief
               from ins.doc_status         ds,
                    ins.ag_contract        ac,
                    ins.ag_contract_header ah,
                    ins.doc_status_ref sr
              where ds.document_id = ac.ag_contract_id
                and ds.doc_status_ref_id = sr.doc_status_ref_id
                and ah.ag_contract_header_id = ac.contract_id
                and ah.templ_brief is null) ag_doc_status
 where dd.sql_date between ag_doc_status.begin_date and
       ag_doc_status.end_date
       and ag_doc_status.ag_contract_header_id = dm_ah.ag_contract_header_id (+);

