CREATE OR REPLACE FORCE VIEW V_REP_KSP AS
SELECT pkg_renlife_utils.get_ag_stat_brief(ach.ag_contract_header_id, arh.date_end) stat,
ent.obj_name('CONTACT',ach.agent_id) ag,
ach.num ad,
pp.pol_ser||NVL2(pp.pol_ser,'-','')||pp.pol_num pol,
ph.start_date Date_S,
pp.notice_ser||NVL2(pp.notice_ser,'-','')||pp.notice_num notice,
ent.obj_name('CONTACT',acha.agent_id) ag_cur_agent,
acha.num ad_cur_agent,
dsr1.NAME active_pol,
dsr2.NAME last_pol,
akd.decline_date,
-- pt.description,
round(akd.conclude_policy_sgp,2) Conclude_sgp,
round(akd.prolong_policy_sgp,2) Prolong_sgp,
ak.ksp_value
FROM ven_ag_roll_header arh,
ag_roll ar,
ag_perfomed_work_act apw,
ag_ksp ak,
ag_ksp_det akd,
ven_ag_contract_header ach,
ven_ag_contract_header acha,
p_pol_header ph,
p_policy pp,
doc_status_ref dsr1,
doc_status_ref dsr2
WHERE 1=1
and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA')
AND arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_ksp' and param_name = 'rep_num')
AND arh.ag_roll_header_id = ar.ag_roll_header_id
AND ar.ag_roll_id = apw.ag_roll_id
AND apw.ag_perfomed_work_act_id = ak.document
AND ak.ag_ksp_id = akd.ag_ksp_id
AND ach.ag_contract_header_id (+) = akd.ag_contract_header_id
AND ph.policy_header_id = akd.policy_header_id
AND ph.policy_id = pp.policy_id
AND dsr1.doc_status_ref_id = akd.active_policy_status_id
AND dsr2.doc_status_ref_id = akd.last_policy_status_id
AND akd.policy_agent (+) = acha.ag_contract_header_id
ORDER BY 1, 2
;

