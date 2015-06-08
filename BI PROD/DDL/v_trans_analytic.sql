create or replace force view v_trans_analytic as
select
    t.trans_id,
    ad.name dt_name,
    ac.name ct_name,
    ad.characteristics dt_char,
    ac.characteristics ct_char,
    atd1.name a1_dt_analytic_type_name,
    atd2.name a2_dt_analytic_type_name,
    atd3.name a3_dt_analytic_type_name,
    atd4.name a4_dt_analytic_type_name,
    atd5.name a5_dt_analytic_type_name,
    atc1.name a1_ct_analytic_type_name,
    atc2.name a2_ct_analytic_type_name,
    atc3.name a3_ct_analytic_type_name,
    atc4.name a4_ct_analytic_type_name,
    atc5.name a5_ct_analytic_type_name,
    ent.obj_name(t.a1_dt_ure_id, t.a1_dt_uro_id) a1_dt_uro_name,
    ent.obj_name(t.a2_dt_ure_id, t.a2_dt_uro_id) a2_dt_uro_name,
    ent.obj_name(t.a3_dt_ure_id, t.a3_dt_uro_id) a3_dt_uro_name,
    ent.obj_name(t.a4_dt_ure_id, t.a4_dt_uro_id) a4_dt_uro_name,
    ent.obj_name(t.a5_dt_ure_id, t.a5_dt_uro_id) a5_dt_uro_name,
    ent.obj_name(t.a1_ct_ure_id, t.a1_ct_uro_id) a1_ct_uro_name,
    ent.obj_name(t.a2_ct_ure_id, t.a2_ct_uro_id) a2_ct_uro_name,
    ent.obj_name(t.a3_ct_ure_id, t.a3_ct_uro_id) a3_ct_uro_name,
    ent.obj_name(t.a4_ct_ure_id, t.a4_ct_uro_id) a4_ct_uro_name,
    ent.obj_name(t.a5_ct_ure_id, t.a5_ct_uro_id) a5_ct_uro_name,
    t.note
  from
    Trans t,
    Account ad,
    Account ac,
    Analytic_Type atd1,
    Analytic_Type atd2,
    Analytic_Type atd3,
    Analytic_Type atd4,
    Analytic_Type atd5,
    Analytic_Type atc1,
    Analytic_Type atc2,
    Analytic_Type atc3,
    Analytic_Type atc4,
    Analytic_Type atc5
  where
    t.dt_account_id = ad.account_id
    and
    t.ct_account_id = ac.account_id
    and
    ad.a1_analytic_type_id = atd1.analytic_type_id(+)
    and
    ad.a2_analytic_type_id = atd2.analytic_type_id(+)
    and
    ad.a3_analytic_type_id = atd3.analytic_type_id(+)
    and
    ad.a4_analytic_type_id = atd4.analytic_type_id(+)
    and
    ad.a5_analytic_type_id = atd5.analytic_type_id(+)
    and
    ac.a1_analytic_type_id = atc1.analytic_type_id(+)
    and
    ac.a2_analytic_type_id = atc2.analytic_type_id(+)
    and
    ac.a3_analytic_type_id = atc3.analytic_type_id(+)
    and
    ac.a4_analytic_type_id = atc4.analytic_type_id(+)
    and
    ac.a5_analytic_type_id = atc5.analytic_type_id(+);

