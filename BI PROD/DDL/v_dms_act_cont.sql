CREATE OR REPLACE FORCE VIEW V_DMS_ACT_CONT AS
SELECT NULL dms_act_id,
       NULL c_service_med_id,
       NULL card_num,
       NULL name,
       NULL service_code,
       NULL service_name,
       NULL service_date,
       NULL amount,
       NULL decline_amount,
       NULL dms_decline_reason_id,
       NULL dms_decline_reason_name FROM dual
/*select
  csm.dms_act_id,
  csm.c_service_med_id,
  csm.card_num,
  trim(csm.last_name || ' ' || csm.first_name || ' ' || csm.middle_name) name,
  csm.service_code,
  csm.service_name,
  csm.service_date,
  csm.amount,
  csm.decline_amount,
  csm.dms_decline_reason_id,
  ddr.name dms_decline_reason_name
from
  c_service_med csm,
  dms_decline_reason ddr
where
  csm.dms_decline_reason_id = ddr.dms_decline_reason_id(+)*/;

