CREATE OR REPLACE FORCE VIEW V_DOC_BILL AS
SELECT
  d.document_id,
  dt.doc_templ_id,
  dt.brief doc_templ_brief,
  ap.due_date,
  d.num,
  f.fund_id,
  f.brief fund_brief,
  CASE
    WHEN pd.brief = 'IN' THEN ap.amount
    ELSE 0
  END In_Amount,
  CASE
    WHEN pd.brief = 'OUT' THEN ap.amount
    ELSE 0
  END Out_Amount,
  ap.comm_amount,
  (
    SELECT NVL(SUM(dso.set_off_amount),0)
    FROM   DOC_SET_OFF dso
    WHERE  dso.parent_doc_id = ap.payment_id
  ) Set_Off_Amount,
  c.contact_id,
  ent.obj_name(c.ent_id, c.contact_id) contact_name,
  doc.get_doc_status_name(ap.payment_id) doc_status_name,
  d.note
FROM
  AC_PAYMENT ap,
  DOCUMENT d,
  DOC_TEMPL dt,
  FUND f,
  CONTACT c,
  T_COLLECTION_METHOD cm,
  AC_PAYMENT_DIRECT pd,
  AC_PAYMENT_TEMPL pt
WHERE
  ap.payment_id = d.document_id AND
  d.doc_templ_id = dt.doc_templ_id AND
  pt.doc_templ_id = dt.doc_templ_id AND
  ap.collection_metod_id = cm.ID AND
  pd.payment_direct_id = ap.payment_direct_id AND
  ap.fund_id = f.fund_id AND
  ap.contact_id = c.contact_id AND
  dt.brief NOT IN ('DMS_INV_LPU_ADV',
'DMS_INV_LPU_SERV',
'DMS_INV_LPU_ADV_ATTACH',
'DMS_SERV_ACT',
'DMS_SERV_INV',
'PAYADVLPU',
'PAYORDLPU',
'WRITEOFFSERV',
'DMS_ORDER_LPU_ATTACH'
) AND 
  (pt.payment_type_id = 0 OR dt.brief LIKE '%SETOFF') AND
  ( ap.filial_id IS NULL OR
   ap.filial_id IN (
        SELECT COLUMN_VALUE FROM TABLE(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id))
      ))
ORDER BY 4,5;

