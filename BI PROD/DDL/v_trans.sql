create or replace force view v_trans as
select
    t.trans_id,
    t.ent_id,
    t.filial_id,
    t.trans_date,
    t.trans_fund_id,
    tf.brief trans_fund_brief,
    tf.name trans_fund_name,
    t.trans_amount,
    t.dt_account_id,
    ad.num dt_account_num,
    ad.name dT_account_name,
    t.ct_account_id,
    ac.num ct_account_num,
    ac.name ct_account_name,
    t.acc_fund_id,
    af.brief acc_fund_brief,
    af.name acc_fund_name,
    t.acc_amount,
    t.acc_rate,
    t.is_accepted,
    t.Acc_Chart_Type_ID,
    act.name acc_chart_type_name,
    t.a1_dt_ure_id,
    t.a1_dt_uro_id,
    t.a2_dt_ure_id,
    t.a2_dt_uro_id,
    t.a3_dt_ure_id,
    t.a3_dt_uro_id,
    t.a4_dt_ure_id,
    t.a4_dt_uro_id,
    t.a5_dt_ure_id,
    t.a5_dt_uro_id,
    t.a1_ct_ure_id,
    t.a1_ct_uro_id,
    t.a2_ct_ure_id,
    t.a2_ct_uro_id,
    t.a3_ct_ure_id,
    t.a3_ct_uro_id,
    t.a4_ct_ure_id,
    t.a4_ct_uro_id,
    t.a5_ct_ure_id,
    t.a5_ct_uro_id,
    d.document_id,
    ent.obj_name(d.ent_id, d.document_id) document_name,
    t.trans_templ_id,
    tt.name trans_templ_name,
    tt.brief trans_templ_brief,
    t.trans_quantity,
    t.Source,
    t.note,
    t.oper_id
  from
    trans t,
    fund tf,
    account ad,
    account ac,
    fund af,
    acc_chart_type act,
    oper o,
    document d,
    trans_templ tt
  where
    t.trans_fund_id = tf.fund_id
    and
    t.dt_account_id = ad.account_id
    and
    t.ct_account_id = ac.account_id
    and
    t.acc_fund_id = af.fund_id
    and
    t.acc_chart_type_id = act.acc_chart_type_id
    and
    t.oper_id = o.oper_id
    and
    d.document_id = o.document_id
    and
    t.trans_templ_id = tt.trans_templ_id
 --AND d.document_id = 6103612
;

