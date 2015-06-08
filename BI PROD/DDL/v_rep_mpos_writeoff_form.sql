CREATE OR REPLACE VIEW v_rep_mpos_writeoff_form AS 
SELECT wc.mpos_writeoff_form_id AS "ID �����������"
       ,wc.transaction_date AS "���� � ����� ����������"
       ,wc.amount AS "����� ������"
       ,wc.insured_name AS "��� ������������"
       ,wc.policy_number AS "���"
       ,ps.name AS "��� �����"
       ,pt.description AS "������������� ��������"
       ,dsrc.name AS "������"
       ,dsc.start_date AS "���� �������"
       ,wc.description AS "����������"
       ,wc.transaction_id AS "�� ����������"
       ,wc.cliche AS "����� mPos"
       ,wc.device_id AS "�� ���������� � �����������"
       ,wc.device_name AS "�������� mPos"
       ,wc.device_model AS "������ mPos"
       ,mp.name AS "��������� �������"
       ,wc.rrn AS "RRN"
       ,wc.card_number AS "����� �����"
       ,wc.ids_for_recognition AS "��� ��� �������������"
       ,mr.name AS "������� ������"
       ,CASE
         WHEN dsrc.brief IN ('CANCEL', 'CANCEL_NOT_SENT', 'STOPED', 'STOPED_NOT_SENT') THEN
          dsc.start_date
       END AS "���� ������"
       ,dsr.name AS "������ ��������� ������"
       ,kl.name AS "������"
       ,pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id) AS "�����"
       ,dcc.reg_date AS "���� �������"

  FROM ins.mpos_writeoff_form    wc
      ,ins.p_pol_header          ph
      ,ins.p_policy              pp
      ,ins.t_kladr               kl
      ,ins.document              dc
      ,ins.doc_status_ref        dsr
      ,ins.t_payment_terms       pt
      ,ins.t_payment_system      ps
      ,ins.document              dcc
      ,ins.doc_status            dsc
      ,ins.doc_status_ref        dsrc
      ,ins.t_mpos_rejection      mr
      ,ins.t_mpos_payment_status mp

 WHERE wc.policy_header_id = ph.policy_header_id(+)
   AND ph.last_ver_id = pp.policy_id(+)
   AND pp.region_id = kl.t_kladr_id(+)
   AND pp.policy_id = dc.document_id(+)
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id(+)
   AND wc.t_payment_terms_id = pt.id
   AND wc.t_payment_system_id = ps.t_payment_system_id
   AND wc.mpos_writeoff_form_id = dcc.document_id
   AND wc.t_mpos_rejection_id = mr.t_mpos_rejection_id(+)
   AND dcc.doc_status_id = dsc.doc_status_id
   AND dsc.doc_status_ref_id = dsrc.doc_status_ref_id
   AND wc.t_mpos_payment_status_id = mp.t_mpos_payment_status_id
