CREATE OR REPLACE VIEW V_AGN_JOURNAL AS
select /*+INDEX (cn PK_CONTACT)*/
   ach.ag_contract_header_id,
   cn.obj_name_orig agent_fio,
   dc.num ag_num,
   aca.category_name ag_cat,
   doc.get_doc_status_name(ach.ag_contract_header_id) ag_stat,
   ach.date_begin,
   adt.description ag_doc,
   doc.get_doc_status_name(agd.ag_documents_id) ag_doc_stat,
   ac.date_begin ac_date_begin,
   ac.date_end ac_date_end,
   ac.ag_contract_id,
   dpt.name agency,
   ts.brief
from
   ag_contract_header ach,
   document           dc,
   contact cn,
   ag_contract ac,
   ag_category_agent aca,
   ag_documents agd,
   ag_doc_type adt,
   DEPARTMENT dpt,
   t_sales_channel ts
WHERE ach.ag_contract_header_id = dc.document_id
  AND ach.ag_contract_header_id = ac.contract_id
  AND ach.agent_id = cn.contact_id
  AND ach.is_new = 1
  AND ac.category_id = aca.ag_category_agent_id
  AND agd.ag_contract_header_id = ach.ag_contract_header_id
  AND agd.ag_documents_id = (SELECT min(ad.ag_documents_id) ad
                               FROM ag_documents ad
                              where ad.ag_contract_header_id = agd.ag_contract_header_id
                             )
  AND adt.ag_doc_type_id = agd.ag_doc_type_id
  and dpt.department_id (+) = ach.agency_id
  and ach.t_sales_channel_id = ts.id (+)
with read only;
comment on column V_AGN_JOURNAL.AG_DOC is 'Описание';
comment on column V_AGN_JOURNAL.AG_CONTRACT_ID is 'Ид записи версия АД';
