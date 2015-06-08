create or replace force view v_dms_err_critical as
select
  de.c_service_med_id,
  count(*) err_count
from
  dms_err de,
  dms_err_type det
where
  de.dms_err_type_id = det.dms_err_type_id and 
  det.name = 'Критическая'
group by
  de.c_service_med_id;

