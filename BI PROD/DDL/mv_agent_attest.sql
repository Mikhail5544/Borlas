create materialized view MV_AGENT_ATTEST
refresh force on demand
as
select SYSDATE attest_date,
       t.stat_date,
--       ash_o.stat_date old_stat_date,
       tmp$_ag_stat(ash_o.ag_contract_header_id, ash_o.stat_date, asa1.ag_stat_agent_id) old_stat_date,
       ach.num,
       ent.obj_name('CONTACT',ach.agent_id) AGENT,
       ent.obj_name('DEPARTMENT', ach.agency_id) agency,
       ach.date_begin,
       ceil(months_between(SYSDATE, ach.date_begin)/12) ad_lasts,
       asa1.name ag_stat,
       asa2.name ag_stat_new,
       t.k_sgp,
       t.k_kd,
       t.k_ksp
  from AG_STAT_HIST_TMP t,
       ven_ag_contract_header ach,
       ag_stat_agent asa1,
       ag_stat_agent asa2,
       (SELECT MAX(stat_date) stat_date,
               ag_contract_header_id
          FROM ag_stat_hist
         GROUP BY ag_contract_header_id) ash_o
 WHERE ach.ag_contract_header_id= t.ag_contract_header_id
   AND asa1.ag_stat_agent_id = t.ag_stat_agent_id_old
   AND asa2.ag_stat_agent_id = t.ag_stat_agent_id
   AND ash_o.ag_contract_header_id = ach.ag_contract_header_id;

