create or replace force view v_lpu_acc_serv_act as
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
    dsa.doc_date act_date,
    dsa.num act_num,
    dsa.amount act_amount,
    dsa.fund_id act_fund_id,
    af.brief act_fund_brief,
    dsa.executor_id act_executor_id,
    c.obj_name_orig act_executor_name
  from
    doc_set_off dso,
    dms_inv_lpu dil,
    ven_dms_serv_act dsa,
    fund pf,
    fund cf,
    fund af,
    contact c
  where
    dso.parent_doc_id = dil.dms_inv_lpu_id and
    dso.child_doc_id = dsa.dms_serv_act_id and
    pf.fund_id = dso.set_off_fund_id and
    cf.fund_id = dso.set_off_child_fund_id and
    af.fund_id = dsa.fund_id and
    dsa.executor_id = c.contact_id;

