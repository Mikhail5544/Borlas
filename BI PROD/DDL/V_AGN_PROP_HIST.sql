CREATE OR REPLACE VIEW V_AGN_PROP_HIST AS
SELECT apt.DESCRIPTION prop,
       decode(apc.new_value, 'NULL', 'Пустое значение', decode(apt.source_ent, NULL, apc.new_value,
              ent.obj_name(apt.source_ent, to_number(apc.new_value)))) val,
       agd.doc_date begin_date,
       apc.end_date,
       ds.user_name,
       ds.change_date,
       ach.ag_contract_header_id,
       agd.ag_documents_id,
       ds.start_date
  FROM ag_props_change apc,
       ag_props_type apt,
       ag_documents agd,
       doc_status ds,
       doc_status_ref dsr,
       ag_contract_header ach
 WHERE apc.is_accepted = 1
   AND apc.ag_props_type_id = apt.ag_props_type_id
   AND apc.ag_documents_id = agd.ag_documents_id
   AND agd.ag_contract_header_id = ach.ag_contract_header_id
   AND ds.document_id = agd.ag_documents_id
   and ds.start_date = (select min(dss.start_date)
                        from doc_status dss, doc_status_ref dsrs
                        where dss.document_id = agd.ag_documents_id
                              and dsrs.doc_status_ref_id = dss.doc_status_ref_id
                              and dsrs.brief = 'CONFIRMED')
   AND ds.doc_status_ref_id =dsr.doc_status_ref_id
   AND dsr.brief = 'CONFIRMED'
   --and ach.ag_contract_header_id = 22813277
with read only


