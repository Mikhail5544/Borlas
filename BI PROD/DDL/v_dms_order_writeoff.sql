CREATE OR REPLACE FORCE VIEW V_DMS_ORDER_WRITEOFF AS
SELECT
  d.document_id,
  dt.doc_templ_id,
  dt.brief doc_templ_brief,
  ap.due_date,
  d.num,
  f.fund_id,
  f.brief fund_brief,
  ap.amount In_Amount,
  0 Out_Amount,
  ap.comm_amount,
  (
    SELECT NVL(SUM(dso.set_off_amount),0)
    FROM   Doc_Set_Off dso
    WHERE  dso.parent_doc_id = ap.payment_id
  ) Set_Off_Amount,
  c.contact_id,
  c.obj_name_orig contact_name
FROM
  ac_payment ap,
  document d,
  doc_templ dt,
  fund f,
  Contact c,
  t_Collection_Method cm,
  ac_payment_direct pd,
  ac_payment_templ pt
WHERE
  ap.payment_id = d.document_id AND
  d.doc_templ_id = dt.doc_templ_id AND
  pt.doc_templ_id = dt.doc_templ_id AND
  ap.collection_metod_id = cm.ID AND
  pd.payment_direct_id = ap.payment_direct_id AND
  ap.fund_id = f.fund_id AND
  ap.contact_id = c.contact_id AND
  --pt.payment_type_id = 0 and
  dt.brief IN  ('WRITEOFFSERV', 'DMS_ORDER_LPU_ATTACH', 'DMS_ORDER_LPU_FREE') AND
  pd.brief = 'OUT'
ORDER BY 4,5
;

