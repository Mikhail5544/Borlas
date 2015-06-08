create or replace view v_rep_dwo_operation_journal as
SELECT vdo.dwo_operation_id AS "�� ��������"
       ,vdo.ids AS "���"
       ,vdo.insured_fio AS "������������"
       ,vdo.notice_fee AS "����� ������"
       ,vdo.writeoff_description AS "����������� ���-�� ��������"
       ,vdo.writeoff_datetime AS "����/����� ����. ��������"
       ,vdo.oper_status_name AS "������ ��"
       ,vdo.oper_status_date AS "���� ������� ��"
       ,vdo.agent AS "�����"
       ,vdo.region_name AS "������"
       ,vdo.dwo_notice_id AS "�� ���������"
       ,vdo.notice_type_description AS "��� ���������"
       ,vdo.payer_fio AS "��� �����������"
       ,vdo.dwo_schedule_id AS "�� �������"
       ,CASE
         WHEN vdo.prolongation_flag = 1 THEN
          '��'
         ELSE
          '���'
       END "�����������"
       ,vdo.operation_id_recognize AS "�� �������� ��� �����������"
       ,vdo.writeoff_result AS "��������� ��������"
       ,vdo.notice_writeoff_date AS "���� �������� �� ���������"
       ,vdo.date_end AS "���� ��������� ��"
       ,vdo.download_date AS "���� ��������"
       ,vdo.upload_date AS "���� ��������"
       ,vdo.policy_fee AS "����� ������ �� �� � ������"
       ,vdo.card_type_name AS "��� �����"
       ,vdo.card_num AS "����� �����"
       ,vdo.notice_note AS "����������"
       ,vdo.writeoff_reference AS "������ (����)"
       ,vdo.check_num AS "����� ����"
  FROM ins.v_dwo_operation vdo
 WHERE vdo.registry_type_brief IN ('TO_WRITEOFF')
   AND vdo.oper_status_brief != 'CANCEL';