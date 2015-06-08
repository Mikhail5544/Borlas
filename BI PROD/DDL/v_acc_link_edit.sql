create or replace force view v_acc_link_edit as
select
    0 Account_ID,
    '' Account_Num,
    '' Account_Name,
    null Acc_Chart_Type_ID,
    '' Acc_Chart_Type_Name,
    null Fund_ID,
    '' Fund_Brief,
    null Acc_Role_ID,
    '' Acc_Role_Name,
    null Analytic_Type_ID,
    '' Analytic_Type_Name,
    null URO_ID,
    '' URO_Name
  from 
    Dual
  
  union all
  
  select
    a.Account_ID,
    a.Num,
    a.Name,
    a.acc_chart_type_id,
    act.name Acc_Chart_Type_Name,
    a.fund_id,
    f.brief,
    a.acc_role_id,
    ar.name Acc_Role_Name,
    null Analytic_Type_ID,
    '' Analytic_Type_Name,
    null URO_ID,
    '' URO_Name
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
    a.acc_role_id = ar.acc_role_id(+);

