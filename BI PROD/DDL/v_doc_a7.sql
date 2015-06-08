create or replace force view v_doc_a7 as
select
  d.document_id,
  dt.doc_templ_id,
  dt.brief doc_templ_brief,
  ap.due_date,
  d.num,
  f.fund_id,
  f.brief fund_brief,
  case
    when pd.brief = 'IN' then ap.amount
    else 0
  end In_Amount,
  case
    when pd.brief = 'OUT' then ap.amount
    else 0
  end Out_Amount,
  ap.comm_amount,
  (
    select nvl(sum(dso.set_off_child_amount),0)
    from   Doc_Set_Off dso
    where  dso.child_doc_id = ap.payment_id and dso.cancel_date is null
  ) Set_Off_Amount,
  c.contact_id,
  c.obj_name_orig contact_name,
  ap.is_agent,
  doc.get_doc_status_name(ap.payment_id) doc_status_name,
  d.note
from
  ac_payment ap,
  document d,
  doc_templ dt,
  fund f,
  Contact c,
  t_Collection_Method cm,
  ac_payment_direct pd,
  ac_payment_templ pt
where
  ap.payment_id = d.document_id and
  d.doc_templ_id = dt.doc_templ_id and
  pt.doc_templ_id = dt.doc_templ_id and
  cm.description = 'Наличный расчет' and
  dt.brief = 'A7' and
  ap.collection_metod_id = cm.id and
  pd.payment_direct_id = ap.payment_direct_id and
  ap.fund_id = f.fund_id and
  ap.contact_id = c.contact_id and
  pt.payment_type_id = 1
order by 4,5;

