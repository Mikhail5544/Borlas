CREATE OR REPLACE VIEW V_MPOS_PAYMENT_REFUSE_REP AS
SELECT
/*
������� mPos, �� ������� ��������� "�����" (��� ������ ����������)
22.09.2014 ������ �.
*/
 rownum rn
,wn.processing_policy_number
,fi.policy_number ids /*����� �� �� ����������� � �������� �� - ���*/
,fi.insured_name
,wn.amount
,wn.transaction_date
,mr.personal_description /*����������� ���������� �������� �� �� 2Can*/
,pkg_agn_control.get_current_policy_agent_name(fi.policy_header_id) agent_name /*����������� �����*/
,dep.name department_name /*��������, � �������� ��������� ������� ����� �� ��������*/
,(SELECT t.name
    FROM t_kladr t
   WHERE t.t_kladr_id = pkg_policy.get_region_by_pol_header(fi.policy_header_id)) region_name /*������*/
  FROM ven_mpos_writeoff_notice wn
      ,mpos_writeoff_form       fi
      ,t_payment_terms          pt
      ,t_payment_system         ps
      ,doc_status_ref           dsrc
      ,t_mpos_result            mr
      ,ag_contract_header       ach
      ,department               dep
 WHERE wn.mpos_writeoff_form_id = fi.mpos_writeoff_form_id(+)
   AND fi.t_payment_terms_id = pt.id
   AND wn.t_payment_system_id = ps.t_payment_system_id
   AND wn.doc_status_ref_id = dsrc.doc_status_ref_id
   AND dsrc.brief IN ('REFUSE')
   AND wn.t_mpos_result_id = mr.t_mpos_result_id(+)
   AND pkg_agn_control.get_current_policy_agent(fi.policy_header_id) = ach.ag_contract_header_id(+)
   AND ach.agency_id = dep.department_id(+)
   AND dep.name IN (SELECT decode(r.param_value, ' <���>', dep.name, r.param_value)
                      FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'V_MPOS_REFUSE'
                       AND r.param_name = 'AGENCY')
   AND wn.transaction_date BETWEEN (SELECT r.param_value
                                      FROM ins_dwh.rep_param r
                                     WHERE r.rep_name = 'V_MPOS_REFUSE'
                                       AND r.param_name = 'DATE_FROM')
   AND (SELECT r.param_value
          FROM ins_dwh.rep_param r
         WHERE r.rep_name = 'V_MPOS_REFUSE'
           AND r.param_name = 'DATE_TO');
