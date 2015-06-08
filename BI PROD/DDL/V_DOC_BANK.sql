CREATE OR REPLACE VIEW V_DOC_BANK AS
SELECT /*+ FIRST_ROWS */
  d.document_id,
  dt.doc_templ_id,
  dt.brief doc_templ_brief,
  dt.name  doc_templ_name,
  cm.description collection_method_desc,
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
    SELECT NVL(SUM(dso.set_off_child_amount),0)
    FROM   Doc_Set_Off dso
    WHERE  dso.child_doc_id = ap.payment_id AND dso.cancel_date IS NULL
  ) Set_Off_Amount,
  c.contact_id,
  nvl(ap.payer_bank_name,c.obj_name_orig) as contact_name,
  ap.is_agent,
  doc.get_doc_status_name(ap.payment_id) doc_status_name,
  nvl(ap.company_bank_account_num, comp.account_nr||' '||comp.bank_name ) acc_company,
  nvl(ap.contact_bank_account_num, client.account_nr||' '||client.bank_name) acc_client,
  d.note,
  ap.set_off_state,
  (SELECT l.description
     FROM xx_lov_list l
    WHERE l.NAME = 'PAYMENT_SET_OFF_STATE'
      AND l.val = ap.set_off_state) set_off_state_descr
FROM
  ac_payment ap,
  document d,
  doc_templ dt,
  fund f,
  Contact c,
  t_Collection_Method cm,
  ac_payment_direct pd,
  ac_payment_templ pt,
  cn_contact_bank_acc comp,
  cn_contact_bank_acc client
WHERE
  ap.payment_id = d.document_id AND
  d.doc_templ_id = dt.doc_templ_id AND
  dt.brief IN ('ПП', 'ППИ','ПП_ОБ','ПП_ПС', 'ППУКВ') AND
  pt.doc_templ_id = dt.doc_templ_id AND
  ap.collection_metod_id = cm.ID AND
  /*cm.description = 'Безналичный расчет' AND*/
  pd.payment_direct_id = ap.payment_direct_id AND
  ap.fund_id = f.fund_id AND
  ap.company_bank_acc_id = comp.id (+)
  and ap.contact_bank_acc_id = client.id (+) and
  ap.contact_id = c.contact_id AND
  pt.payment_type_id = 1 AND (ap.filial_id IS NULL OR
  ap.filial_id  = pkg_filial.get_user_org_tree_id OR pkg_filial.is_filials_enabled=0);
