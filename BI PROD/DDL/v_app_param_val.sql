create or replace force view v_app_param_val as
select 
  apv.app_param_val_id,
  apv.ent_id,
  apv.filial_id,
  apv.app_param_id,
  apv.start_date,
  apv.user_name,
  apv.val_c, 
  apv.val_n, 
  apv.val_d, 
  apv.val_ure_id,
  apv.val_uro_id,
  ent.obj_name(apv.val_ure_id, apv.val_uro_id) val_uro_name,
  ap.param_type
from 
  app_param_val apv,
  app_param ap
where
  ap.app_param_id = apv.app_param_id
order by 5 desc, 6 asc;

