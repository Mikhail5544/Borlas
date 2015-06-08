create or replace force view v_account as
select 
    a.ACCOUNT_ID ACCOUNT_ID,
    a.ENT_ID ENT_ID,
    a.FILIAL_ID FILIAL_ID,
    a.PARENT_ID PARENT_ID,
    pa.name Parent_Name,
    pa.num Parent_Num,
    a.ACC_CHART_TYPE_ID ACC_CHART_TYPE_ID,
    act.name ACC_CHART_TYPE_NAME,
    a.NAME NAME,
    a.NUM NUM,
    a.CHARACTERISTICS CHARACTERISTICS,
    a.OPEN_DATE OPEN_DATE,
    a.CLOSE_DATE CLOSE_DATE,
    a.FUND_ID FUND_ID,
    f.NAME FUND_NAME,
    f.Brief FUND_BRIEF,
    a.ACC_STATUS_ID ACC_STATUS_ID,
    ast.name ACC_STATUS_NAME,
    a.IS_REVALUED IS_REVALUED,
    a.IS_SYNTH IS_SYNTH,
    a.a1_analytic_type_id a1_analytic_type_id,
    a1.name a1_analytic_type_name,
    a.a2_analytic_type_id a2_analytic_type_id,
    a2.name a2_analytic_type_name,
    a.a3_analytic_type_id a3_analytic_type_id,
    a3.name a3_analytic_type_name,
    a.a4_analytic_type_id a4_analytic_type_id,
    a4.name a4_analytic_type_name,
    a.a5_analytic_type_id a5_analytic_type_id,
    a5.name a5_analytic_type_name,
    a.a1_ure_id,
    a.a2_ure_id,
    a.a3_ure_id,
    a.a4_ure_id,
    a.a5_ure_id,
    a.a1_uro_id,
    ent.obj_name(a1.analytic_ent_id, a.a1_uro_id) a1_uro_name,
    a.a2_uro_id,
    ent.obj_name(a2.analytic_ent_id, a.a2_uro_id) a2_uro_name,
    a.a3_uro_id,
    ent.obj_name(a3.analytic_ent_id, a.a3_uro_id) a3_uro_name,
    a.a4_uro_id,
    ent.obj_name(a4.analytic_ent_id, a.a4_uro_id) a4_uro_name,
    a.a5_uro_id,
    ent.obj_name(a5.analytic_ent_id, a.a5_uro_id) a5_uro_name,
    a.acc_role_id,
    ar.name acc_role_name
  from 
    Account a,
    Account pa,
    Fund f,
    Acc_Chart_Type act,
    Acc_Status ast,
    analytic_Type a1,
    analytic_Type a2,
    analytic_Type a3,
    analytic_Type a4,
    analytic_Type a5,
    Acc_Role ar
  where
    a.Parent_ID = pa.account_id(+)
    and
    a.Fund_Id = f.Fund_Id(+)
    and
    a.acc_chart_type_id = act.acc_chart_type_id
    and
    a.acc_status_id = ast.acc_status_id 
    and
    a.a1_analytic_type_id = a1.analytic_type_id(+)
    and
    a.a2_analytic_type_id = a2.analytic_type_id(+)
    and
    a.a3_analytic_type_id = a3.analytic_type_id(+)
    and
    a.a4_analytic_type_id = a4.analytic_type_id(+)
    and
    a.a5_analytic_type_id = a5.analytic_type_id(+)
    and
    a.acc_role_id = ar.acc_role_id(+);

