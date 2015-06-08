create or replace force view vf_bso_search_act as
select /*+ FIRST_ROWS(10)*/
         bd.BSO_DOCUMENT_ID,
         bd.FILIAL_ID,
         bd.EXT_ID,
         bd.DOC_FOLDER_ID,
         bd.DOC_TEMPL_ID,
         bd.CONTACT_FROM_ID,
         bd.CONTACT_TO_ID,
         bd.ENT_ID,
         dt.name as doc_templ_name,
         bd.num,
         rf.name as doc_status_name,
         bd.reg_date,
         ent.obj_name (c1.ent_id, c1.contact_id) as contact_from_name,
         vot.name as dep_to_name,
         ent.obj_name (c2.ent_id, c2.contact_id) as contact_to_name,
         vot2.name as dep_from_name
    from ven_bso_document bd,
         document bdoc,
         doc_status_ref rf,
         ven_doc_templ dt,
         ven_contact c1,
         ven_contact c2,
         ven_department dep,
         ven_department dep2,
         ven_organisation_tree vot,
         ven_organisation_tree vot2
   where     bd.doc_templ_id = dt.doc_templ_id
         and bd.contact_from_id = c1.contact_id(+)
         and bd.contact_to_id = c2.contact_id(+)
         and bd.department_to_id = dep.department_id(+)
         and bd.department_from_id = dep2.department_id(+)
         and vot.organisation_tree_id(+) = dep.org_tree_id
         and vot2.organisation_tree_id(+) = dep2.org_tree_id
         and bd.bso_document_id = bdoc.document_id
         and bdoc.doc_status_ref_id = rf.doc_status_ref_id;

