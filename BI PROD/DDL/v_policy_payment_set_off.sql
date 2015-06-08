CREATE OR REPLACE VIEW V_POLICY_PAYMENT_SET_OFF AS
SELECT dso.parent_doc_id main_doc_id
      ,dso.parent_doc_id
      ,dso.doc_set_off_id
      ,dso.child_doc_id
      ,cd.num list_doc_num
      ,cp.due_date list_doc_date
      ,cd.reg_date
      ,dso.set_off_date
      ,dso.set_off_child_amount set_off_amount
      ,dso.set_off_amount set_off_child_amount
      ,(cp.amount + cp.comm_amount) list_doc_amount
      ,cp.contact_id
      ,cc.obj_name_orig contact_name
      ,ds.doc_status_ref_id
      ,dsr.name doc_status_ref_name
      ,cd.doc_templ_id
      ,dt.brief doc_templ_brief
      ,dt.name doc_templ_name
      ,decode(dso.cancel_date, NULL, 0, 1) is_annulated
      ,cp.cancel_date
      ,cm.description AS coll_method_name
      ,pri.payment_register_item_id
  FROM doc_set_off           dso
      ,document              cd
      ,ac_payment            cp
      ,contact               cc
      ,doc_status            ds
      ,doc_status_ref        dsr
      ,doc_templ             dt
      ,payment_register_item pri
      ,t_collection_method   cm
 WHERE dso.child_doc_id = cd.document_id
   AND cd.document_id = cp.payment_id
   AND cp.contact_id = cc.contact_id
   AND ds.doc_status_id = cd.doc_status_id
   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
   AND dt.doc_templ_id = cd.doc_templ_id
   AND dso.pay_registry_item = pri.payment_register_item_id(+)
   AND pri.collection_method_id = cm.id(+)
UNION ALL
SELECT dso.child_doc_id main_doc_id
      ,dso.parent_doc_id
      ,dso.doc_set_off_id
      ,dso.child_doc_id
      ,cd.num list_doc_num
      ,cp.due_date list_doc_date
      ,cd.reg_date
      ,dso.set_off_date
      ,dso.set_off_amount set_off_amount
      ,dso.set_off_child_amount set_off_child_amount
      ,(cp.amount + cp.comm_amount) list_doc_amount
      ,cp.contact_id
      ,cc.obj_name_orig contact_name
      ,ds.doc_status_ref_id
      ,dsr.name doc_status_ref_name
      ,cd.doc_templ_id
      ,dt.brief doc_templ_brief
      ,dt.name doc_templ_name
      ,decode(dso.cancel_date, NULL, 0, 1) is_annulated
      ,cp.cancel_date
      ,NULL
      ,NULL
  FROM doc_set_off    dso
      ,document       cd
      ,ac_payment     cp
      ,contact        cc
      ,doc_status     ds
      ,doc_status_ref dsr
      ,doc_templ      dt
 WHERE dso.parent_doc_id = cd.document_id
   AND cd.document_id = cp.payment_id
   AND cp.contact_id = cc.contact_id
   AND ds.doc_status_id = cd.doc_status_id
   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
   AND dt.doc_templ_id = cd.doc_templ_id;
