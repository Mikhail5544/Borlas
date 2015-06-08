create or replace force view v_acc_link as
select
  a.account_id,
  a.num,
  a.name,
  f.fund_id,
  f.brief fund_brief,
  a.acc_chart_type_id,
  act.name acc_chart_type_name,
  a.acc_role_id,
  ar.name acc_role_name,
  a.a1_analytic_type_id,
  a.a1_uro_id,
  a.a2_analytic_type_id,
  a.a2_uro_id,
  a.a3_analytic_type_id,
  a.a3_uro_id,
  a.a4_analytic_type_id,
  a.a4_uro_id,
  a.a5_analytic_type_id,
  a.a5_uro_id
from
  Account a,
  Acc_Chart_Type act,
  Fund f,
  Acc_Role ar
where
  a.acc_chart_type_id = act.acc_chart_type_id  
  and
  a.fund_id = f.fund_id
  and
  a.acc_role_id = ar.acc_role_id(+)
  and
  ( 
    (a.a1_uro_id is not null)
    or
    (a.a2_uro_id is not null)
    or
    (a.a3_uro_id is not null)
    or
    (a.a4_uro_id is not null)
    or
    (a.a5_uro_id is not null)
  );

