create or replace force view v_acc_group as
select ag.acc_group_id,
       ag.name,
       ag.brief,
       a.account_id,
       a.num,
       a.name account_name,
       act.acc_chart_type_id,
       act.name acc_chart_type_name
  from acc_group ag, account a, acc_chart_type act
 where ag.root_account_id = a.account_id(+)
   and act.acc_chart_type_id(+) = a.acc_chart_type_id;

