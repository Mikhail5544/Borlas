CREATE OR REPLACE VIEW V_MPOS_PAYMENT_REFUSE AS
SELECT
/*
������� mPos, �� ������� ��������� "�����"
17.09.2014 ������ �.
*/
 wn.mpos_writeoff_notice_id
,wn.processing_policy_number
,fi.policy_number ids /*����� �� �� ����������� � �������� �� - ���*/
,fi.insured_name
,wn.amount
,wn.transaction_date
,wn.work_status /*������ ���������*/
,wn.transaction_id
,wn.rrn
,wn.processing_result /*��������� ��������*/
,wn.cliche
,ps.name /*��� �����*/
,dsrc.name oper_status_name /*������ ��������*/
,wn.device_name /*����������*/
,wn.card_number /*����� �����*/
,wn.doc_status_id
,wn.doc_status_ref_id
,wn.note
,wn.num
,wn.reg_date
,wn.description
,wn.device_id
,wn.device_model
,wn.g_mpos_id
,wn.mpos_writeoff_form_id
,wn.payment_register_item_id
,wn.terminal_bank_id
,wn.t_payment_system_id
,wn.writeoff_number
,wn.processing_status
,mr.result_code
,mr.process_description  /*��������� �������� �� �����������*/
,mr.personal_description /*����������� ���������� �������� �� �� 2Can*/
,pkg_agn_control.get_current_policy_agent_name(fi.policy_header_id) agent_name /*����������� �����*/
,(SELECT t.name
    FROM t_kladr t
   WHERE t.t_kladr_id = pkg_policy.get_region_by_pol_header(fi.policy_header_id)) region_name /*������*/
  FROM ven_mpos_writeoff_notice wn
      ,mpos_writeoff_form       fi
      ,t_payment_terms          pt
      ,t_payment_system         ps
      ,doc_status_ref           dsrc
      ,t_mpos_result            mr
 WHERE wn.mpos_writeoff_form_id = fi.mpos_writeoff_form_id(+)
   AND fi.t_payment_terms_id = pt.id (+)
   AND wn.t_payment_system_id = ps.t_payment_system_id
   AND wn.doc_status_ref_id = dsrc.doc_status_ref_id
   AND dsrc.brief IN ('PROJECT', 'REFUSE')
   and wn.work_status is not null /*�������, �� ������� �����, ����������� ����� ��*/
   AND wn.t_mpos_result_id = mr.t_mpos_result_id(+);
