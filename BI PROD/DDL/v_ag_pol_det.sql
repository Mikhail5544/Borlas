create or replace force view v_ag_pol_det as
select pwd.AG_PERFOM_WORK_DPOL_ID AS AG_PERFOM_WORK_DPOL_ID,
       pwd.AG_PERFOM_WORK_DET_ID AS AG_PERFOM_WORK_DET_ID,
       concat(concat(pp.pol_ser, ' - '), pp.pol_num) AS POL_NUM,
       tp.DESCRIPTION AS PROD_NAME,
       concat(concat(concat(concat(ach1.num, ' - '), c1.obj_name_orig),' - '),asa1.name) AS AGENT_SALE,
       concat(concat(concat(concat(ach2.num, ' - '), c2.obj_name_orig),' - '),asa2.name) AS AGENT_LEAD,
       round(pwd.SUMM,2) AS SUMM
  from ven_ag_perfom_work_dpol pwd
  join ven_ag_perfom_work_det apd on apd.ag_perfom_work_det_id = pwd.ag_perfom_work_det_id
  join ven_ag_perfomed_work_act apa on apa.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
  LEFT join ven_ag_sgp agp on agp.ag_contract_header_id = apa.ag_contract_header_id
                     and apa.ag_roll_id = agp.ag_roll_id
  LEFT join ven_ag_sgp_det asd on asd.ag_sgp_id = agp.ag_sgp_id
                         and asd.policy_id = pwd.policy_id
                         and asd.ag_contract_header_ch_id = asd.ag_contract_header_ch_id
  join ven_ag_contract_header ach1 on ach1.ag_contract_header_id = pwd.ag_contract_header_ch_id
  left join ven_ag_contract_header ach2 on ach2.ag_contract_header_id = asd.child_id
  join ven_contact c1 on c1.contact_id = ach1.agent_id
  left join ven_contact c2 on c2.contact_id = ach2.agent_id
  join ven_ag_roll ar on ar.ag_roll_id = apa.ag_roll_id
  join ven_ag_roll_header arh on arh.ag_roll_header_id = ar.ag_roll_header_id
  join ven_p_policy pp on pp.policy_id = pwd.policy_id
  join ven_p_pol_header pph on pph.policy_header_id = pp.pol_header_id
  join ven_t_product tp on tp.product_id = pph.product_id
  left join ven_ag_stat_agent asa1 on asa1.ag_stat_agent_id = pkg_ag_sgp.get_status(arh.date_end,ach1.ag_contract_header_id)
  left join ven_ag_stat_agent asa2 on asa1.ag_stat_agent_id = pkg_ag_sgp.get_status(arh.date_end,ach2.ag_contract_header_id);

