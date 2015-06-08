create or replace force view v_acc_chart_type as
select 
    act.acc_chart_type_id, act.ent_id, act.filial_id,
    act.name, act.brief, act.base_fund_id, f.brief BASE_FUND_BRIEF
  from Acc_Chart_Type act, Fund f
  where
    act.base_fund_id = f.fund_id(+);

