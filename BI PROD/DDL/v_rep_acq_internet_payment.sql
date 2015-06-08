CREATE OR REPLACE VIEW v_rep_acq_internet_payment AS
SELECT ip.acq_internet_payment_id   AS "ID �������"
       ,ip.transaction_date          AS "���� � ����� ����������"
       ,ip.amount                    AS "����� ������"
       ,ip.issuer_name               AS "��� ������������"
       ,ip.policy_num                AS "���"
       ,dsr.name                     AS "������"
       ,ip.bank_transaction_id       AS "�� ����������"
       ,ip.email                     AS "����������� �����"
       ,ip.approval_code             AS "��� ������������� (APP_CODE)"
       ,sr.description               AS "������ ���. ��-� (Result)"
       ,ps.description               AS "���. ��-� � ����-� �������"
       ,rc.result_code               AS "���. ��-� (Result_CODE)"
       ,rc.desc_ru_full              AS "����������� ���������� ��-�"
       ,sc.description               AS "������ 3D ��������������"
       ,ip.rrn                       AS "RRN"
       ,ip.mrch_transaction_id       AS "��������"
       ,ip.card_number               AS "����� �����"
       ,rd.acq_oms_registry_id       AS "�� ������� ���"
       ,rd.acq_oms_registry_det_id   AS "�� ����������� ������� ���"

  FROM acq_internet_payment   ip
      ,document               dc
      ,doc_status_ref         dsr
      ,t_acq_result_code      rc
      ,t_acq_status_result    sr
      ,t_acq_status_result_ps ps
      ,t_acq_status_3dsecure  sc
      ,acq_oms_registry_det   rd

 WHERE ip.acq_internet_payment_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
   AND ip.t_acq_status_result_id = sr.t_acq_status_result_id
   AND ip.t_acq_result_code_id = rc.t_acq_result_code_id
   AND ip.t_acq_status_result_ps_id = ps.t_acq_status_result_ps_id
   AND ip.t_acq_status_3dsecure_id = sc.t_acq_status_3dsecure_id(+)
   AND ip.acq_internet_payment_id = rd.acq_internet_payment_id(+)
   AND ip.acq_payment_type_id = dml_t_acq_payment_type.get_id_by_brief('SINGLE')
