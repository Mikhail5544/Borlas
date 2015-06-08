CREATE OR REPLACE FORCE VIEW V_AGAT AS
SELECT apw.ag_perfomed_work_act_id act,
       ach.num ad_num,
       ach.date_begin ad_begin,
       (SELECT DISTINCT LAST_VALUE(ach1.num)
               OVER (ORDER BY ach1.date_begin ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
          FROM ven_ag_contract_header ach1
         WHERE ach1.agent_id = ach.agent_id) first_ad_num,
       (SELECT MIN(ach1.date_begin)
          FROM ag_contract_header ach1
         WHERE ach1.agent_id = ach.agent_id) first_ad_begin,
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= apw.status_id) AD_status_CT,
       doc.get_doc_status_name(ac.ag_contract_id) AD_status_AP,
       ent.obj_name('DEPARTMENT',ach.agency_id) agency,
       ent.obj_name('CONTACT',ach.agent_id) AGENT,
       --asa.NAME status_CT,
       ash.stat_date status_date_CT,
       pp.pol_ser||NVL2(pp.pol_ser,'-','')||pp.pol_num pol_num,
       ph.start_date "Date_from",
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) insuer,
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= apdp.policy_status_id) Active_version_status_CT,
       doc.get_doc_status_name(apdp.policy_id) Active_CT_version_status_AP,
       doc.get_doc_status_name(ph.policy_id) Active_version_status_AP,
       f.name,
       epg.num EPG,
       epg.reg_date EPG_DATE,
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= appad.epg_status_id) EPG_status_CT,
       epg.amount EPG_AMOUNT,
       pay.num PAY,
       pay.reg_date PAY_DATE,
       pay.due_date PD4_date,
       dso_p.set_off_amount set_off_AMOUNT,
       tct.description leg_pos,
       apdp.insurance_period ins_period,
       tpt.description pay_term,
       tp.DESCRIPTION product,
       apd.mounth_num operation_months,
       apd.count_recruit_agent agent_OPS_cnt,
       apdp.policy_agent_part dav_koef,
       apdp.summ*apdp.policy_agent_part sgp_by_pol,
       apdp.summ real_sgp_by_pol,
       apdp.check_1,
       apdp.check_2,
      -- apdp.check_3,
       apw.sgp1 sgp_by_act,
       apw.sgp2 cash_by_act,
       CASE WHEN apd.mounth_num = 1 THEN
       round(pkg_tariff_calc.calc_coeff_val('SGP_plan_for_DAV',t_number_type(TO_CHAR(arh.date_end,'YYYYMMDD'),apd.mounth_num, apw.sgp1))
       *(arh.date_end+1-(SELECT MIN(ach1.date_begin)
                          FROM ag_contract_header ach1
                         WHERE ach1.agent_id = ach.agent_id))
       /(arh.date_end+1- arh.date_begin))
       ELSE
       pkg_tariff_calc.calc_coeff_val('SGP_plan_for_DAV',t_number_type(TO_CHAR(arh.date_end,'YYYYMMDD'),apd.mounth_num, apw.sgp1)) END sgp_plan,
       apw.SUM comiss_by_act,
--       apd.summ commis_by_det,
       ak.ksp_value,
       (SELECT SUM(akd.conclude_policy_sgp) FROM ag_ksp_det akd WHERE akd.ag_ksp_id = ak.ag_ksp_id) conclude_sgp,
       (SELECT SUM(akd.prolong_policy_sgp) FROM ag_ksp_det akd WHERE akd.ag_ksp_id = ak.ag_ksp_id) prolong
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_perfom_work_dpol apdp,
       ag_perf_work_pay_doc appad,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       ag_contract ac,
       ven_ac_payment epg,
       ven_ac_payment pay,
       doc_set_off dso_p,
       t_product tp,
     --  ag_stat_agent asa,
       ag_stat_hist ash,
       T_CONTACT_TYPE tct,
       t_payment_terms tpt,
       fund f,
       ag_ksp ak
 WHERE 1=1
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','EGORNOVA')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'agat' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'agat' and param_name = 'version_num')
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND ak.document = apw.ag_perfomed_work_act_id
   AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
   AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
   AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
   AND pp.policy_id = apdp.policy_id
   AND pp.pol_header_id = ph.policy_header_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND Pkg_Agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE) = ac.ag_contract_id
   AND appad.epg_payment_id = epg.payment_id
   AND appad.pay_payment_id = pay.payment_id
   AND pay.payment_id = dso_p.child_doc_id
   AND dso_p.parent_doc_id = epg.payment_id
  -- AND asa.ag_stat_agent_id = apdp.ag_status_id
   AND ash.ag_stat_hist_id = apw.ag_stat_hist_id
   AND tct.ID = apdp.ag_leg_pos
   AND ph.fund_id = f.fund_id
   AND ph.product_id = tp.product_id
   AND tpt.ID = apdp.pay_term
   ORDER BY 2,1,6
;

