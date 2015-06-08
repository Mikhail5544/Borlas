CREATE OR REPLACE FORCE VIEW V_REP_OAV_KIP AS
SELECT
       arh.num "����� ���������",
       ar.num  "������ ���������",
       ph.policy_header_id,
       pp.pol_ser,
       pp.pol_num,
       tp.product_id,
       tp.description   "�������",
       tplo.id          "id �����",
       tplo.description "����",
       (select decode(ig.life_property,1,'�',0,'��')
          from t_product_line      pl,
               t_lob_line          ll,
               t_insurance_group   ig
         where pl.id = tplo.product_line_id
           and pl.t_lob_line_id = ll.t_lob_line_id
           and ll.insurance_group_id = ig.t_insurance_group_id
       ) "������� �/��",
       ph.policy_id active_p_policy_id,
       ach.ag_contract_header_id,
       ach.agent_id,
       ach.num "����� ��",
       ent.obj_name('CONTACT',ach.agent_id) "����� ���",
       decode(ash.ag_category_agent_id,1,'����� ��� ���������', 2, '�����', 3, '��������', 4, '��������') "��������� ������ �� ���� ���",
       (select a.name from ag_stat_agent a where a.ag_stat_agent_id = ash.ag_stat_agent_id) "������ ������ �� ���� ���",
       art.name         "��� ��",
       apt.sav          "������",

       apw.SUM comiss_by_act,
       apd.summ commis_by_det,
       apdp.summ commiss_by_pol,
       apt.sum_premium,
       apt.sum_commission,

       apw.date_calc    "���� ������� BORLAS",
       arh.date_begin||' - '||arh.date_end "�������� ������"

  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_perfom_work_dpol apdp,
       ag_perf_work_pay_doc appad,
       ag_perf_work_trans apt,
       ag_stat_hist ash,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       t_prod_line_option tplo,
       t_product tp,
       ag_roll_type       art,
       doc_doc   dd2,
       p_policy  p2
 WHERE 1=1--arh.num = '000109'
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','DKIPRICH')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav_kip' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav_kip' and param_name = 'version_num')
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
   AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
   AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
   AND apt.ag_perf_work_pay_doc_id= appad.ag_perf_work_pay_doc_id (+)
   and dd2.child_id = appad.epg_payment_id --����� �� �� ���
   and p2.policy_id = dd2.parent_id
   and ph.policy_header_id = p2.pol_header_id
   AND pp.policy_id = ph.policy_id
  -- AND pp.policy_id = appad.policy_id
   --AND pp.policy_id = apdp.policy_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ash.ag_stat_hist_id = apw.ag_stat_hist_id
   AND tplo.ID = apt.t_prod_line_option_id
   AND ph.product_id = tp.product_id
   and art.ag_roll_type_id = arh.ag_roll_type_id
;

