create or replace force view v_acc_group_cont as
select agc.acc_group_contents_id,
       agc.acc_group_id,
       agc.name_level,
       a.account_id,
       a.num,
       a.name account_name,
       act.acc_chart_type_id,
       act.name acc_chart_type_name,
       agc.note
  from acc_group_contents agc, account a, acc_chart_type act
 where agc.account_id = a.account_id
   and act.acc_chart_type_id = a.acc_chart_type_id;

