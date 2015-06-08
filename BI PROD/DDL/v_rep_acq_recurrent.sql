CREATE OR REPLACE VIEW V_REP_ACQ_RECURRENT AS
SELECT ip.acq_internet_payment_id AS "�� �������"
      ,dc.reg_date  AS "���� ��������"
      ,ip.transaction_date AS "���� � ����� ����������"
      ,ip.amount AS "����� ������"
      ,ip.issuer_name AS "��� ������������"
      ,ip.policy_num AS "���"
      ,(SELECT tr.description FROM t_payment_terms tr WHERE tr.id = pt.t_payment_terms_id) AS "������������� ��������"
      ,dsr.name AS "������"
      ,ds.start_date AS "���� �������"
      ,ip.bank_transaction_id AS "�� ����������"
      ,ip.approval_code AS "��� ������������� (APP_CODE)"
      ,sr.description AS "������ ��� ��-� (Result)"
      ,ps.description AS "��������� ��-� � ����. �������"
      ,rc.result_code AS "���. ���������� (Result_CODE)"
      ,rc.desc_ru_full AS "����������� ���������� ��-�"
      ,sc.description AS "������ 3D ��������������"
      ,ip.rrn AS "RRN"
      ,ip.mrch_transaction_id AS "��������"
      ,ip.card_number AS "����� �����"
      ,pkg_kladr.get_kladr_name_by_id(pkg_policy.get_region_by_pol_header(ip.policy_header_id)) AS "������"
      ,pkg_agn_control.get_current_policy_agent_name(ip.policy_header_id) AS "�����"
      ,ip.acq_writeoff_sch_id AS "�� ���"
      ,dcp.num AS "����� �������"
      ,rd.acq_oms_registry_id AS "�� ������� ���"
      ,ins.pkg_policy.get_pol_sales_chn(ip.policy_header_id,'descr') as "����� ������"

  FROM acq_internet_payment   ip
      ,document               dc
      ,doc_status             ds
      ,doc_status_ref         dsr
      ,t_acq_result_code      rc
      ,t_acq_status_result    sr
      ,t_acq_status_result_ps ps
      ,t_acq_status_3dsecure  sc
      ,acq_writeoff_sch       ws
      ,acq_oms_registry_det   rd
      ,document               dcp
      ,acq_payment_template   pt

 WHERE ip.acq_internet_payment_id = dc.document_id
   AND dc.doc_status_id = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ip.t_acq_status_result_id = sr.t_acq_status_result_id
   AND ip.t_acq_result_code_id = rc.t_acq_result_code_id
   AND ip.t_acq_status_result_ps_id = ps.t_acq_status_result_ps_id(+)
   AND ip.t_acq_status_3dsecure_id = sc.t_acq_status_3dsecure_id(+)
   AND ip.acq_writeoff_sch_id = ws.acq_writeoff_sch_id(+)
   AND ip.acq_payment_template_id = pt.acq_payment_template_id(+)
   AND pt.acq_payment_template_id = dcp.document_id(+)
   AND ip.acq_internet_payment_id = rd.acq_internet_payment_id(+)
   --AND NOT (ip.acq_payment_type_id = 2 AND dsr.brief = 'CANCEL')
   AND ip.acq_payment_type_id IN
       (dml_t_acq_payment_type.get_id_by_brief('PRIMARY_RECURRENT')
       ,dml_t_acq_payment_type.get_id_by_brief('REPEATED_RECURRENT'))
;
