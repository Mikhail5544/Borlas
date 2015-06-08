create or replace force view v_ag_prem_det as
select apd.AG_PERFOM_WORK_DET_ID as AG_PERFOM_WORK_DET_ID,
       apd.AG_PERFOMED_WORK_ACT_ID AS AG_PERFOMED_WORK_ACT_ID,
       art.NAME AS PREM_NAME,
       round(apd.SUMM,2) AS PREM_SUMM,
       decode(apd.mounth_num, null, '-', 0, '-', apd.mounth_num) AS MONTH_NUM,
       decode(apd.count_recruit_agent,null,'-',0,'-',apd.count_recruit_agent) AS COUNT_RECRUIT_AGENT
  from ven_ag_perfom_work_det apd
  join ven_ag_rate_type art on art.ag_rate_type_id = apd.ag_rate_type_id;

