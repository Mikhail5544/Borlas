create or replace force view v_c_service_med_sel as
select
    NULL c_service_med_id,
    NULL dms_serv_reg_id,
    NULL dms_serv_act_id,
    NULL service_date,
    NULL bso_num,
    NULL as_assured_name,
    NULL service_code,
    NULL service_name,
    NULL count_plan,
    NULL amount_plan,
    NULL is_tech_check,
    NULL is_med_check,
    NULL count_exp,
    NULL amount_exp,
    NULL  amount_fact,
    NULL  critical_count,
    NULL  medical_count
  FROM dual

  --Это от ДМС которого в системе нет

/*select
    csm.c_service_med_id,
    csm.dms_serv_reg_id,
    dsr.dms_serv_act_id,
    csm.service_date,
    csm.bso_num,
    csm.as_assured_name,
    csm.service_code,
    csm.service_name,
    csm.count_plan,
    csm.amount_plan,
    csm.is_tech_check,
    csm.is_med_check,
    nvl(sum(drsa.serv_count),0) count_exp,
    nvl(sum(drsa.serv_amount),0) amount_exp,
    case
      when csm.is_med_check = 1 then csm.count_plan else 0
    end
    -
    case
      when csm.is_med_check = 1 then nvl(sum(drsa.serv_count),0) else 0
    end count_fact,
    case
      when csm.is_med_check = 1 then csm.amount_plan else 0
    end
    -
    case
      when csm.is_med_check = 1 then nvl(sum(drsa.serv_amount),0) else 0
    end amount_fact,
    nvl(sum(vdec.err_count), 0) critical_count,
    nvl(sum(vdem.err_count), 0) medical_count
  from
    c_service_med csm,
    dms_serv_reg dsr,
    dms_rel_serv_act drsa,
    v_dms_err_critical vdec,
    v_dms_err_medical vdem
  where
    csm.dms_serv_reg_id = dsr.dms_serv_reg_id and
    csm.is_tech_check <> 0 and
    csm.c_service_med_id = drsa.c_service_med_id(+) and
    csm.c_service_med_id = vdec.c_service_med_id(+) and
    csm.c_service_med_id = vdem.c_service_med_id(+)
  group by
    csm.c_service_med_id,
    csm.dms_serv_reg_id,
    dsr.dms_serv_act_id,
    csm.service_date,
    csm.bso_num,
    csm.as_assured_name,
    csm.service_code,
    csm.service_name,
    csm.count_plan,
    csm.amount_plan,
    csm.is_tech_check,
    csm.is_med_check*/
;

