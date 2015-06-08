create or replace view v_contact_agent_contr_info as
select ch.agent_id               as contact_id
      ,ch.ag_contract_header_id
      ,dc.num                    as num_ad
      ,ca.category_name
      ,ch.date_begin
      ,(select max(ds.doc_date)
          from ag_documents ds
         where ds.ag_documents_id = bp.ag_documents_id
       )                          as doc_date_pay_prop
  from ag_contract_header ch
      ,document           dc
      ,ag_contract        cn
      ,ag_category_agent  ca
      ,ag_bank_props       bp
 where ch.ag_contract_header_id  = dc.document_id
   and ch.last_ver_id            = cn.ag_contract_id
   and cn.category_id            = ca.ag_category_agent_id
   and ch.ag_contract_header_id  = bp.ag_contract_header_id
   and ch.is_new                 = 1;
