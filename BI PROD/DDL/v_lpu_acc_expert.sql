create or replace force view v_lpu_acc_expert as
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
    da.num da_num,
    da.act_date,
    da.doc_templ_id,
    dt.name doc_templ_name,
    dt.brief doc_templ_brief,
    doc.get_doc_status_id(ap.payment_id) da_doc_status_ref_id,
    doc.get_doc_status_name(ap.payment_id) da_doc_status_ref_name
  from
    doc_set_off dso,
    ven_ac_payment ap,
    ven_dms_act da,
    fund pf,
    fund cf,
    doc_templ dt
  where
    dso.parent_doc_id = ap.payment_id and
    dso.child_doc_id = da.dms_act_id and
    pf.fund_id = dso.set_off_fund_id and
    cf.fund_id = dso.set_off_child_fund_id and
    dt.doc_templ_id = da.doc_templ_id;

