create or replace force view v_rel_acc_role as
select 
    rar.rel_acc_role_id,
    rar.ent_id,
    rar.filial_id,
    rar.acc_role_id,
    ar.name acc_role_name,
    rar.acc_mask,
    rar.acc_chart_type_id,
    act.name acc_chart_type_name,
    rar.is_not,
    rar.characteristics
  from 
    Rel_Acc_Role rar,
    Acc_Role ar,
    Acc_Chart_Type act
  where 
    rar.acc_role_id = ar.acc_role_id
    and
    rar.acc_chart_type_id = act.acc_chart_type_id;

