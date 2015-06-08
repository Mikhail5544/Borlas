CREATE OR REPLACE VIEW v_ag_acts_banks
AS
SELECT up.date_begin_ad
      ,up.agent_num
      ,up.agent_fio
      ,up.rl_vol                  AS detail_vol_amt
      ,up.commission              AS detail_commis
      ,up.agency
      ,up.ag_perfomed_work_act_id
      ,up.ag_roll_id
      ,up.ag_contract_header_id
      ,nvl(up.act_date, sysdate) as act_date
      ,nvl(accrual_1c_date, sysdate) as accrual_1c_date
  FROM t_ungroup_prem up;
grant select on v_ag_acts_banks to ins_read;
