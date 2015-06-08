CREATE OR REPLACE VIEW v_rep_acq_template AS

SELECT dc.num AS "�����"
       ,dc.reg_date AS "���� �����������"
       ,pt.fee AS "����� ������"
       ,pt.admin_expenses AS "������ �����. ��������"
       ,pt.issuer_name AS "��� ������������"
       ,pt.pol_number AS "���"
       ,tr.description AS "������������� ��������"
       ,dsr.name AS "������"
       ,ds.start_date AS "���� �������"
       ,pt.till AS "���� �������� ��������"
       ,mr.name AS "������� ������"
       ,CASE
         WHEN dsr.brief IN ('CANCEL', 'STOPED') THEN
          ds.change_date
       END AS "���� ������"
       ,dsra.name AS "������ �������� ������ ��"
       ,pkg_kladr.get_kladr_name_by_id(pkg_policy.get_region_by_pol_header(pt.policy_header_id)) AS "������"
       ,pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id) AS "�����"
       ,pt.acq_payment_template_id AS "�� �������"
       ,pt.acq_internet_payment_id AS "�� �������"
       ,pt.policy_start_date AS "���� ���. �� �� ���������"
       ,pt.policy_end_date AS "���� ��������� �� �� ���������"
       ,pt.cell_phone AS "���������"
       ,f.brief AS "������"
       ,dc.note AS "�����������"

  FROM ins.acq_payment_template pt
      ,ins.document             dc
      ,ins.t_payment_terms      tr
      ,ins.doc_status           ds
      ,ins.doc_status_ref       dsr
      ,ins.t_mpos_rejection     mr
      ,ins.p_pol_header         ph
      ,ins.doc_status_ref       dsra
      ,ins.fund                 f

 WHERE pt.acq_payment_template_id = dc.document_id
   AND pt.t_payment_terms_id = tr.id(+)
   AND dc.doc_status_id = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND pt.t_mpos_rejection_id = mr.t_mpos_rejection_id(+)
   AND pt.policy_header_id = ph.policy_header_id(+)
   AND pt.current_status_ref_id = dsra.doc_status_ref_id(+)
   AND pt.pay_fund_id = f.fund_id(+)
