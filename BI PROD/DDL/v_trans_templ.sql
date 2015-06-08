create or replace force view v_trans_templ as
select
    tt.trans_templ_id,
    tt.ent_id,
    tt.filial_id,
    tt.name,
    tt.brief,
    tt.is_accepted,
    tt.acc_chart_type_id,
    act.name acc_chart_type_name,
    act.brief acc_chart_type_brief,
    tt.dt_account_id,
    ad.name dt_account_name,
    ad.num dt_account_num,
    tt.ct_account_id,
    ac.name ct_account_name,
    ac.num ct_account_num,
    tt.dt_acc_def_rule_id,
    adrd.name dt_acc_def_rule_name,
    adrd.brief dt_acc_def_rule_brief,
    tt.ct_acc_def_rule_id,
    adrc.name ct_acc_def_rule_name,
    adrc.brief ct_acc_def_rule_brief,
    tt.date_type_id,
    dt.name date_type_name,
    tt.fund_type_id,
    ft.name fund_type_name,
    tt.summ_type_id,
    st.name summ_type_name,
    tt.qty_type_id,
    qt.name qty_type_name,
    tt.dt_analytic_type_id,
    atd.name dt_analytic_type_name,
    tt.ct_analytic_type_id,
    atc.name ct_analytic_type_name,
    tt.dt_ure_id,
    ed.name dt_ure_name,
    tt.dt_uro_id,
    ent.obj_name(tt.dt_ure_id, tt.dt_uro_id) dt_uro_name,
    tt.ct_ure_id,
    ec.name ct_ure_name,
    tt.ct_uro_id,
    ent.obj_name(tt.ct_ure_id, tt.ct_uro_id) ct_uro_name,
    tt.summ_fund_type_id,
    fts.name summ_fund_type_name,
    tt.Note,
    tt.dt_acc_type_templ_id,
    attd.name dt_acc_type_templ_name,
    tt.ct_acc_type_templ_id,
    attc.name ct_acc_type_templ_name,
    tt.dt_rev_acc_chart_type_id,
    actdr.name dt_rev_acc_chart_type_name,
    tt.ct_rev_acc_chart_type_id,
    actcr.name ct_rev_acc_chart_type_name,
    tt.is_export,
    tt.export_type_id,
    et.name export_type_name
  from 
    Trans_Templ tt,
    Acc_Chart_Type act,
    Account ad,
    Account ac,
    Acc_Def_Rule adrd,
    Acc_Def_Rule adrc,
    Date_Type dt,
    Fund_Type ft,
    Fund_Type fts,
    Summ_Type st,
    Summ_Type qt,
    Analytic_Type atd,
    Analytic_Type atc,
    Entity ed,
    Entity ec,
    Acc_type_Templ attd,
    Acc_type_Templ attc,
    Acc_Chart_Type actdr,
    Acc_Chart_Type actcr,
    Export_Type et
  where
    tt.acc_chart_type_id = act.acc_chart_type_id(+)
    and
    tt.dt_account_id = ad.account_id(+)
    and
    tt.ct_account_id = ac.account_id(+)
    and
    tt.dt_acc_def_rule_id = adrd.acc_def_rule_id(+)
    and
    tt.ct_acc_def_rule_id = adrc.acc_def_rule_id(+)
    and
    tt.date_type_id = dt.date_type_id(+)
    and
    tt.fund_type_id = ft.fund_type_id(+)
    and
    tt.summ_fund_type_id = fts.fund_type_id(+)
    and
    tt.summ_type_id = st.summ_type_id(+)
    and
    tt.qty_type_id = qt.summ_type_id(+)
    and
    tt.dt_analytic_type_id = atd.analytic_type_id(+)
    and
    tt.ct_analytic_type_id = atc.analytic_type_id(+)
    and
    tt.dt_ure_id = ed.ent_id(+)
    and
    tt.ct_ure_id = ec.ent_id(+)
    and
    tt.dt_acc_type_templ_id = attd.acc_type_templ_id(+)
    and
    tt.ct_acc_type_templ_id = attc.acc_type_templ_id(+)
    and
    tt.dt_rev_acc_chart_type_id = actdr.acc_chart_type_id(+)
    and
    tt.ct_rev_acc_chart_type_id = actcr.acc_chart_type_id(+)
    and
    tt.export_type_id = et.export_type_id(+)
 order by tt.name;

