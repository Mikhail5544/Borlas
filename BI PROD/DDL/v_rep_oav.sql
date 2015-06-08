CREATE OR REPLACE FORCE VIEW V_REP_OAV AS
SELECT arh.num "Номер ведомости",
       ar.num "Номер версии",
       apw.ag_perfomed_work_act_id "Номер акта",
       apw.date_calc "Дата расчета акта",
       ach.num "Номер АД",
       ent.obj_name('DEPARTMENT',ach.agency_id) "Агенсто",
       ent.obj_name('CONTACT',ach.agent_id) "Агент ФИО",
       asa.NAME "Статус Агента CT",
       ash.stat_date "Дата статуса",
       pp.pol_ser||NVL2(pp.pol_ser,'-','')||pp.pol_num "Номер/серия полиса",
       ph.policy_header_id "Id ДС (pol_header_id)",
       ph.start_date "Дата С",
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) "Страхователь",
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= apdp.policy_status_id) Active_version_status_CT,
       doc.get_doc_status_name(apdp.policy_id) Active_CT_version_status_AP,
       doc.get_doc_status_name(ph.policy_id) Active_version_status_AP,
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= appad.policy_status_id) Payed_version_status_CT,
       doc.get_doc_status_name(appad.policy_id) Payed_version_status_AP,
       asa2.name status_PD,
       (SELECT decode(ac.leg_pos, 1, 'ПБОЮЛ', 'ФЛ')
          FROM ag_contract ac
         WHERE ac.ag_contract_id = pkg_agent_1.get_status_by_date(ach.ag_contract_header_id,epg.plan_date)) leg_pos,
--       tct.description leg_pos,
       apdp.insurance_period ins_period,
       appad.year_of_insurance year_of_ins,
       pt.description pay_term,
       apdp.is_transfered policy_trasferd,
       apdp.check_1,
       apdp.check_2,
       apdp.check_3,
       epg.num EPG,
       epg.plan_date EPG_DATE,
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= appad.epg_status_id) EPG_status_CT,
       epg.amount EPG_AMOUNT,
       pay.num PAY,
       pay.reg_date PAY_DATE,
       pay.amount PAY_AMOUNT,
       bank_d.num BANK,
       bank_d.reg_date BANK_DATE,
       bank_d.amount BANK_D_AMOUNT,
       apw.SUM comiss_by_act,
       apd.summ commis_by_det,
       apdp.summ commiss_by_pol,
       tp.DESCRIPTION product,
       tplo.DESCRIPTION programm,
       apt.sum_premium,
       apt.sav,
       apt.sum_commission,
       apt.trans_id,
       apt.is_indexing
     --  appad.pay_bank_doc_id,
     --  apdp.policy_id
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_perfom_work_dpol apdp,
       ag_perf_work_pay_doc appad,
       ag_perf_work_trans apt,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       ven_ac_payment epg,
       ven_ac_payment pay,
       ven_ac_payment bank_d,
       t_prod_line_option tplo,
       t_product tp,
       ag_stat_agent asa,
       ag_stat_agent asa2,
       ag_stat_hist ash,
       T_CONTACT_TYPE tct,
       t_payment_terms pt,
       doc_doc   dd2,
       p_policy  p2
 WHERE 1=1--arh.num = '000109'
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','EGORNOVA')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav' and param_name = 'version_num')
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
   AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
   AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
   AND apt.ag_perf_work_pay_doc_id= appad.ag_perf_work_pay_doc_id (+)
   and dd2.child_id = appad.epg_payment_id
   and p2.policy_id = dd2.parent_id
   and ph.policy_header_id = p2.pol_header_id
   AND pp.policy_id = ph.policy_id
  -- AND pp.policy_id = appad.policy_id
   --AND pp.policy_id = apdp.policy_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND appad.epg_payment_id = epg.payment_id
   AND appad.pay_payment_id = pay.payment_id
   AND appad.pay_bank_doc_id= bank_d.payment_id
   AND tplo.ID = apt.t_prod_line_option_id
   AND asa.ag_stat_agent_id = apw.status_id
   AND ash.ag_stat_hist_id = apw.ag_stat_hist_id
   AND tct.ID = apdp.ag_leg_pos
   AND ph.product_id = tp.product_id
   AND pt.ID = apdp.pay_term
   AND asa2.ag_stat_agent_id = pkg_renlife_utils.get_ag_stat_id(ach.ag_contract_header_id, epg.plan_date,2)
 --  AND pp.pol_header_id = 11770768
  -- AND apt.trans_id =11112613
--   AND apt.is_indexing <> 0
 --  AND apdp.is_transfered = 1
 --  AND apdp.ag_status_id IS NULL
--   AND apt.trans_id IN (1921438,1921437,1921436)
   ---AND apw.ag_perfomed_work_act_id = 10274191
   ORDER BY 2, 5, 6, 7
   --AND apw.ag_perfomed_work_act_id = 10123260
;

