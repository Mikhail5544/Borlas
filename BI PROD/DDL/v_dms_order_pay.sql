create or replace force view v_dms_order_pay as
select
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
    select nvl(sum(dso.set_off_amount),0)
    from   Doc_Set_Off dso
    where  dso.parent_doc_id = ap.payment_id
  ) Set_Off_Amount,
  c.contact_id,
  c.obj_name_orig contact_name
from
  ac_payment ap,
  document d,
  doc_templ dt,
  fund f,
  Contact c,
  t_Collection_Method cm,
  ac_payment_direct pd,
  ac_payment_templ pt,
  entity e
where
  ap.payment_id = d.document_id and
  d.doc_templ_id = dt.doc_templ_id and
  pt.doc_templ_id = dt.doc_templ_id and
  ap.collection_metod_id = cm.id and
  pd.payment_direct_id = ap.payment_direct_id and
  ap.fund_id = f.fund_id and
  ap.contact_id = c.contact_id and
  pt.payment_type_id = 0 and
  pt.parent_doc_ent_id = e.ent_id and
  e.brief = 'AC_PAYMENT' and
  pd.brief = 'IN'
order by 4,5;

