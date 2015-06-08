create or replace view ins.v_rep_mpos_payment_notice as
SELECT pn.mpos_payment_notice_id AS "�� �����������"
       ,pn.transaction_date       AS "���� � ����� ����������"
       ,pn.amount                 AS "����� ������"
       ,pn.insured_name           AS "��� ������������"
       ,pn.description            AS "����������"
       ,pn.policy_number          AS "���"
       ,ps.name                   AS "��� �����"
       ,dsrc.name                 AS "������"
       ,pn.transaction_id         AS "�� ����������"
       ,pn.cliche                 AS "�����"
       ,pn.device_id              AS "�� ���������� � �����������"
       ,pn.device_name            AS "�������� mPos"
       ,pn.device_model           AS "������ mPos"
       ,mp.name                   AS "��������� �������"
       ,pn.rrn                    AS "RRN"
       ,pn.card_number            AS "����� �����"
       ,dcc.reg_date              AS "���� �������"

  FROM mpos_payment_notice   pn
      ,payment_register_item pri
      ,document              dc
      ,t_payment_system      ps
      ,t_mpos_payment_status mp
      ,document              dcc
      ,doc_status_ref        dsrc

 WHERE pn.t_payment_system_id = ps.t_payment_system_id
   AND pn.payment_register_item_id = pri.payment_register_item_id(+)
   AND pri.ac_payment_id = dc.document_id(+)
   AND pn.t_mpos_payment_status_id = mp.t_mpos_payment_status_id
   AND pn.mpos_payment_notice_id = dcc.document_id
   AND dcc.doc_status_ref_id = dsrc.doc_status_ref_id

   
   
 
