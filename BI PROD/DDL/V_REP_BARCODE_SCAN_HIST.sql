CREATE OR REPLACE VIEW V_REP_BARCODE_SCAN_HIST AS
SELECT bss.t_barcode_scan_sessn_id
      ,bss.sys_user_id
      ,bsh.barcode_num "� �����-����"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          CASE substr(bsh.barcode_num, 1, 2)
            WHEN '01' THEN
             '�����'
            WHEN '02' THEN
             '���������'
            WHEN '03' THEN
             '���������'
            ELSE
             '��� �� ���������'
          END
         ELSE
          NULL
       END "��� ���������"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          substr(bsh.barcode_num, 3, 10)
         ELSE
          NULL
       END "����� ���������"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          substr(bsh.barcode_num, 13, 3)
         ELSE
          NULL
       END "����� ������"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          substr(bsh.barcode_num, 16, 4)
         ELSE
          NULL
       END "����������� �����"
       ,(SELECT nvl(c.obj_name_orig, su.sys_user_name)
          FROM sys_user su
              ,contact  c
         WHERE su.contact_id = c.contact_id(+)
           AND su.sys_user_id = bss.sys_user_id) "��� ������������"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          '�������'
         WHEN 1 THEN
          '�������� �� ������'
         WHEN 2 THEN
          '������ ������������'
         ELSE
          '������ �� ���������'
       END "���������"
       ,trunc(bss.start_date) "���� ������������"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          (SELECT ph.ids
             FROM bso          b
                 ,p_pol_header ph
            WHERE b.pol_header_id = ph.policy_header_id
              AND b.barcode_num = bsh.barcode_num)
         ELSE
          NULL
       END "���"
       ,(SELECT NAME FROM doc_status_ref WHERE doc_status_ref_id = bss.src_doc_status_ref_id) "������ ��"
       ,(SELECT NAME FROM doc_status_ref WHERE doc_status_ref_id = bss.dest_doc_status_ref_id) "������ �"
       ,bsh.change_status_msg "��������� �������� �������"
       ,(SELECT vi.contact_name
          FROM bso                 b
              ,p_policy            pp
              ,v_pol_issuer        vi
         WHERE b.policy_id = pp.policy_id
           AND b.barcode_num = bsh.barcode_num
           AND pp.policy_id = vi.policy_id) "��� ������������"
  FROM t_barcode_scan_hist  bsh
      ,t_barcode_scan_sessn bss
 WHERE bsh.t_barcode_scan_sessn_id = bss.t_barcode_scan_sessn_id;
