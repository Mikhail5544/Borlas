CREATE OR REPLACE VIEW v_rep_direct_writeoff AS 
SELECT ids                     AS "���"
       ,contact_name            AS "���"
       ,dwo_notice_id           AS "ID ��������� �� ��"
       ,NAME                    AS "������ ��������� �� ��"
       ,start_date              AS "���� �������"
       ,mpos_writeoff_form_id   AS "ID mPos"
       ,mpos_status             AS "������ ����������� mPos"
       ,mpos_start_date         AS "���� ������� mPos"
       ,acq_payment_template_id AS "ID ���������"
       ,acq_start_date          AS "���� ������� ���������"

  FROM v_dwo_jornal;
