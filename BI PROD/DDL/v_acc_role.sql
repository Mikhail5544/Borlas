create or replace force view v_acc_role as
select 
    ar.acc_role_id,
    ar.ent_id,
    ar.filial_id,
    ar.name,
    ar.brief,
    ar.is_exp
  from 
    Acc_Role ar;

