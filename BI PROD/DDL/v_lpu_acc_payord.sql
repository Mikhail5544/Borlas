create or replace force view v_lpu_acc_payord as
select 
    dso.doc_set_off_id,
    dso.parent_doc_id,
    dso.child_doc_id,
    dso.set_off_amount,
    dso.set_off_fund_id,
    pf.brief set_off_fund_brief,
    dso.set_off_rate,
    dso.set_off_date,
    dso.set_off_child_amount,
    dso.set_off_child_fund_id,
    cf.brief set_off_child_fund_brief,
    ap.num ap_num,
    ap.due_date ap_due_date,
    ap.grace_date ap_grace_date,
    ap.amount ap_amount,
    ap.contact_id ap_contact_id,
    c.obj_name_orig ap_contact_name,
    doc.get_doc_status_id(ap.payment_id) ap_doc_status_ref_id,
    doc.get_doc_status_name(ap.payment_id) ap_doc_status_ref_name
  from 
    doc_set_off dso,
    dms_inv_lpu dil,
    ven_ac_payment ap,
    fund pf,
    fund cf,
    doc_templ dt,
    contact c
  where
    dso.parent_doc_id = dil.dms_inv_lpu_id and
    dso.child_doc_id = ap.payment_id and
    pf.fund_id = dso.set_off_fund_id and
    cf.fund_id = dso.set_off_child_fund_id and
    dt.doc_templ_id = ap.doc_templ_id and
    dt.brief = 'PAYORDLPU' and
    c.contact_id = ap.contact_id;

