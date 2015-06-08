CREATE OR REPLACE FORCE VIEW V_AGN_DOCUMENTS AS
SELECT agd.ag_documents_id,
       agt.DESCRIPTION doc_desc,
       agd.doc_date,
       doc.get_last_doc_status_name(agd.ag_documents_id) doc_status,
       doc.get_last_doc_status_date(agd.ag_documents_id) doc_status_date,
       doc.get_status_date(agd.ag_documents_id,'CONFIRMED') conf_date,
       (SELECT wmsys.wm_concat(
               DECODE(apc.new_value,'NULL','Пустое значение',
               decode(apt.source_ent, NULL, apc.new_value ,
               ent.obj_name(apt.source_ent, to_number(apc.new_value)))))
         FROM ag_props_change apc,
              ag_props_type apt
        WHERE apc.ag_documents_id = agd.ag_documents_id
          AND apt.ag_props_type_id = apc.ag_props_type_id) val,
       ach.ag_contract_header_id,
       agt.doc_class,
       agd.note,
       agt.ag_doc_type_id,
       agt.description doc_type
  FROM ag_contract_header ach,
       ven_ag_documents agd,
       ag_doc_type agt
 WHERE ach.ag_contract_header_id = agd.ag_contract_header_id
   AND agd.ag_doc_type_id = agt.ag_doc_type_id
with read only;
comment on column V_AGN_DOCUMENTS.DOC_DESC is 'Описание';
comment on column V_AGN_DOCUMENTS.AG_CONTRACT_HEADER_ID is 'Ид записи заголовка АД';
comment on column V_AGN_DOCUMENTS.DOC_CLASS is 'Вид документа (1- основной, 2 - дополнительный)';
comment on column V_AGN_DOCUMENTS.AG_DOC_TYPE_ID is 'Ид записи тип документа АД';
comment on column V_AGN_DOCUMENTS.DOC_TYPE is 'Описание';

