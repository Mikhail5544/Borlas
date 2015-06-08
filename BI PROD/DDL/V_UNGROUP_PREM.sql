CREATE OR REPLACE VIEW V_UNGROUP_PREM AS
SELECT t.ag_contract_header_id
      ,t.ag_roll_id
      ,t.ag_roll_header_id
      ,t.agency
      ,t.agent_num
      ,t.date_begin_ad
      ,t.agent_fio
      ,ROUND(nvl(t.total_volume, 0), 2) detail_vol_amt
      ,(SELECT ROUND(nvl(SUM(apv.vol_amount * apv.vol_rate), 0), 2)
          FROM ins.ag_perfom_work_det apd
              ,ins.ag_perf_work_vol   apv
         WHERE apd.ag_perfomed_work_act_id = t.ag_perfomed_work_act_id
           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id) +
       (SELECT nvl(SUM(nvl(apd1.summ, 0)), 0)
          FROM ins.ag_perfom_work_det apd1
              ,ins.ag_rate_type       art1
         WHERE apd1.ag_perfomed_work_act_id = t.ag_perfomed_work_act_id
           AND apd1.ag_rate_type_id = art1.ag_rate_type_id
           AND art1.brief IN ('KPI_ORIG_OPS'
                             ,'KPI_PLAN_OPS'
                             ,'KSP_KPI_Reach_0510'
                             ,'LVL_0510'
                             ,'QOPS_0510'
                             ,'QMOPS_0510')) detail_commis
      ,t.ag_perfomed_work_act_id
      ,t.act_date AS act_date
      ,t.accrual_1c_date AS accrual_1c_date
  FROM ins.t_ungroup_prem t;
