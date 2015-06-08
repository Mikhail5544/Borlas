CREATE OR REPLACE FORCE VIEW V_PREM_MD_ADVANCED AS
select a."����� ���������",
       a."�������� ������",
       a."��������",
       a."���",
       a."����/����� ������� ����",
       a."Id ��������",
       a."����� ��������",
       a."��� ������",
       a."������ �� �� ��",
       a."������ ������ �� ��",
       a."������ ������ �� ��4/�����.",
       a."Id ������������",
       a."��� ������������",
       a."���������� ������� ������",
       a."���������� ����� �������",
       a."������",
       a."�����",
       a."Id ��",
       a."���������",
       a."���� �",
       a."���� �����������",
       a."��������� �������",
       a."�������",
       a."�� �� ��",
       a."��� ������ �� ��",
       a."������������",
       a."������ �� � ������ ��",
       a."������ ������ � ������ ��",
       a."������ ������ � ������ ������",
       a."������",
       a."����� ���",
       a."���� ���",
       a."������ ��� ��",
       a."����� ���",
       a."����� ���������� ���",
       a."���� ��",
       a."�����. ���",
       a."���/����������� ������ �� ��",
       a."����������� ������ �� ��",
       a."��� �� ���� (���������� �����)",
       a."����������� ������ �� ����",
       a.check_1,
       a.check_2,
       a."������� �� ����",
       a."�������� �� ������",
       a."����".sgp_amount    "����.sgp_amount",
       a."����".policy_count  "����.policy_count",
       a."�������������� ����".sgp_amount   "����� ����.sgp_amount",
       a."�������������� ����".policy_count "����� ����.policy_count"
from(
SELECT arh.num "����� ���������",
       to_CHAR(arh.date_end, 'MONTH', 'NLS_DATE_LANGUAGE=RUSSIAN') "�������� ������",
       ent.obj_name('DEPARTMENT',ach.agency_id) "��������",
       apw.ag_perfomed_work_act_id "���",
       apw.date_calc "����/����� ������� ����",
       ach.ag_contract_header_id "Id ��������",
       ach.num "����� ��������",
       ent.obj_name('CONTACT',ach.agent_id) "��� ������",
       doc.get_doc_status_name(ac.ag_contract_id, arh.date_end) "������ �� �� ��",
       (SELECT asa1.name FROM ag_stat_agent asa1 WHERE asa1.ag_stat_agent_id = apw.status_id) "������ ������ �� ��",
        asa.NAME "������ ������ �� ��4/�����.",
       (SELECT achr.ag_contract_header_id
          FROM ag_contract acr,
               ag_contract_header achr
         WHERE acr.ag_contract_id = ac.contract_f_lead_id
           AND acr.contract_id = achr.ag_contract_header_id) "Id ������������",
       (SELECT ent.obj_name('CONTACT',achr.agent_id)
          FROM ag_contract acr,
               ag_contract_header achr
         WHERE acr.ag_contract_id = ac.contract_f_lead_id
           AND acr.contract_id = achr.ag_contract_header_id) "��� ������������",
       apd.mounth_num "���������� ������� ������",
       apd.count_recruit_agent "���������� ����� �������",
       art.NAME "������",
       pp.pol_ser||NVL2(pp.pol_ser,'-','')||pp.pol_num "�����",
       pp.pol_header_id "Id ��",
       pp.Notice_Ser||NVL2(pp.notice_ser,'-','')||pp.notice_num "���������",
       ph.start_date "���� �",
       apdp.insurance_period "���� �����������",
       tpt.description "��������� �������",
       tp.DESCRIPTION "�������",
       achp.num "�� �� ��",
       ent.obj_name('CONTACT',achp.agent_id) "��� ������ �� ��",
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(pp.policy_id,'������������')) "������������",
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= apdp.policy_status_id) "������ �� � ������ ��",
       doc.get_doc_status_name(apdp.policy_id) "������ ������ � ������ ��",
       doc.get_doc_status_name(ph.policy_id) "������ ������ � ������ ������",
       f.NAME "������",
       epg.num "����� ���",
       epg.reg_date "���� ���",
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= appad.epg_status_id) "������ ��� ��",
       epg.amount "����� ���",
       pay.num "����� ���������� ���",
       pay.due_date "���� ��",
       apdp.policy_agent_part "�����. ���",
       apdp.summ "���/����������� ������ �� ��",
       (select dso.set_off_amount
          from doc_set_off dso
         where dso.child_doc_id  = appad.pay_payment_id
           AND dso.parent_doc_id = appad.epg_payment_id
       ) "����������� ������ �� ��",
       apw.sgp1 "��� �� ���� (���������� �����)",
       apw.sgp2 "����������� ������ �� ����",
       check_1,
       check_2,
       apw.SUM "������� �� ����",
       apd.summ "�������� �� ������",
       pkg_ag_calc_admin.get_plan(apd.mounth_num,apw.status_id,arh.date_end) "����",
       pkg_ag_calc_admin.get_individual_plan(apw.ag_contract_header_id,arh.date_end) "�������������� ����"
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_rate_type art,
       ag_perfom_work_dpol apdp,
       ag_perf_work_pay_doc appad,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       ven_ag_contract_header achp,
       ag_contract ac,
       ven_ac_payment epg,
       ven_ac_payment pay,
       t_product tp,
       ag_stat_agent asa,
       t_payment_terms tpt,
       fund f
 WHERE 1=1
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','IGOVOROV','AKATKEVICH','INS','EGORNOVA')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'prem_md' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'prem_md' and param_name = 'version_num')
   --AND apdp.policy_id = 10770210
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
   AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
   AND pp.policy_id = apdp.policy_id
   AND pp.pol_header_id = ph.policy_header_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND Pkg_Agent_1.get_status_by_date(ach.ag_contract_header_id, arh.date_end) = ac.ag_contract_id
   AND appad.epg_payment_id = epg.payment_id (+)
   AND appad.pay_payment_id = pay.payment_id (+)
   AND asa.ag_stat_agent_id (+) = apdp.ag_status_id
   AND ph.fund_id = f.fund_id
   AND tpt.id = pp.payment_term_id
   AND ph.product_id = tp.product_id
   AND achp.ag_contract_header_id = apdp.ag_contract_header_ch_id
  ORDER BY 3,4,"������"
)a
;

