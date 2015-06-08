create or replace view v_rep_att_roo as
select agh.ag_contract_header_id,
       agd.ag_documents_id,
       dep.name dep,
       (select ds.user_name
       from ins.doc_status ds,  
            ins.doc_status_ref rf
       where ds.document_id = agd.ag_documents_id
             and rf.doc_status_ref_id = ds.src_doc_status_ref_id
             and rf.name = '<Документ добавлен>') login_name,
       d.num ag_num,
       c.obj_name_orig ag_name,
       (select ds.start_date
       from ins.doc_status ds,  
            ins.doc_status_ref rf
       where ds.document_id = agd.ag_documents_id
             and rf.doc_status_ref_id = ds.src_doc_status_ref_id
             and rf.name = '<Документ добавлен>') start_date_new_ad,
       dt.description type_doc,
       agd.doc_date,
       (select max(ds.start_date)
       from ins.doc_status ds,  
            ins.doc_status_ref rf
       where ds.document_id = agd.ag_documents_id
             and rf.doc_status_ref_id = ds.doc_status_ref_id
             and rf.name = 'Подтвержден') start_date_conf_ad,
       ins.doc.get_doc_status_name(agh.ag_contract_header_id) ag_stat
from ins.ag_contract_header agh,
     ins.document d,
     ins.contact c,
     ins.ag_documents agd,
     ins.ag_contract ag,
     ins.department dep,
     ins.ag_doc_type dt
where agh.ag_contract_header_id = d.document_id
      and agh.agent_id = c.contact_id
      and agh.ag_contract_header_id = agd.ag_contract_header_id
      and agh.ag_contract_header_id = ag.contract_id
      and sysdate between ag.date_begin and ag.date_end
      and nvl(agh.is_new,0) = 1
      and ag.agency_id = dep.department_id(+)
      and dt.ag_doc_type_id = agd.ag_doc_type_id
      and dt.brief = 'NEW_AD'
      and (select ds.start_date
           from ins.doc_status ds,  
                ins.doc_status_ref rf
           where ds.document_id = agd.ag_documents_id
                 and rf.doc_status_ref_id = ds.src_doc_status_ref_id
                 and rf.name = '<Документ добавлен>') between --to_date('02-10-2010','dd-mm-yyyy') and to_date('10-01-2011','dd-mm-yyyy')

                 to_date((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'att_roo'
                            AND r.param_name = 'date_from'),'dd.mm.yyyy') and
                            to_date((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'att_roo'
                            AND r.param_name = 'date_to'),'dd.mm.yyyy')