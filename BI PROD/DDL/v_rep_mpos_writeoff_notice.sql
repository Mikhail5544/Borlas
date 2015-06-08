CREATE OR REPLACE VIEW v_rep_mpos_writeoff_notice AS 
SELECT wn.mpos_writeoff_notice_id AS "�� �����������"
       ,wn.transaction_date        AS "���� � ����� ����������"
       ,wn.amount                  AS "����� ������"
       ,fi.insured_name            AS "��� ������������"
       ,wn.description             AS "����������"
       ,fi.policy_number           AS "���"
       ,ps.name                    AS "��� �����"
       ,pt.description             AS "������������� ��������"
       ,dsrc.name                  AS "������"
       ,wn.transaction_id          AS "�� ����������"
       ,wn.cliche                  AS "����� mPos"
       ,wn.device_id               AS "�� ���������� � �����������"
       ,wn.device_name             AS "�������� mPos"
       ,wn.device_model            AS "������ mPos"
       ,wn.rrn                     AS "RRN"
       ,wn.card_number             AS "����� �����"
       ,NULL /*kl.name*/                       AS "������"
       ,NULL /*pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id)*/                       AS "�����"
       ,wn.reg_date                AS "���� �������"
       ,fi.transaction_id          AS "�� ��-� ����. � �������� ��"
       ,wn.writeoff_number         AS "���������� ����� ��������"
       ,wn.note                    AS "����������"

  FROM ven_mpos_writeoff_notice wn
      ,payment_register_item    pri
      ,document                 dc
      ,mpos_writeoff_form       fi
      ,t_payment_terms          pt
      ,t_payment_system         ps
      ,doc_status_ref           dsrc

 WHERE wn.payment_register_item_id = pri.payment_register_item_id(+)
   AND pri.ac_payment_id = dc.document_id(+)
   AND wn.mpos_writeoff_form_id = fi.mpos_writeoff_form_id(+)
   AND fi.t_payment_terms_id = pt.id
   AND wn.t_payment_system_id = ps.t_payment_system_id
   AND wn.doc_status_ref_id = dsrc.doc_status_ref_id;
