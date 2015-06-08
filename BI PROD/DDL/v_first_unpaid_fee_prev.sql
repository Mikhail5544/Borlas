CREATE OR REPLACE VIEW V_FIRST_UNPAID_FEE_PREV AS
SELECT
/*
����������� �� �������� ������� ������ �� ������� �����

�������� �����������, � ��������� ���������� ������� ������ �0 � ���, �������� ������� ������ �DWH_����� � ���������_������_�������_2011�, 
� ������� ���� ������ �������� �������� �����������  ����� ���� ���������� ������������� ���,  �� ����������� ��������� ��������� �����������:
�  �� � �������� ������� � ������� ������� ��� ����������;
�  ��, � ������� ����� ������� ��� � ������� �������� � ������������ �� ������ ������� ����.
��� �� �� ������ ������ ����������� ��� ����������� � ���� ��� � ����� ������� ���������� �������� �������� ������ 45 ����.
� �������� ���������� ��� ������ �DWH_����� � ���������_������_�������_2011� ������������ ��������� ��������:
�  ����� ������� �� - 01.10.2008;
� ����� ������� �� - ��������� ���� �������� ������.
30.1.2015 ������ �.
*/
DISTINCT (SELECT insp.policy_id
            FROM p_pol_header insp
           WHERE insp.policy_header_id = pph.policy_header_id) policy_id /*�������� ������ ��*/
        ,to_number(NULL) p_pol_change_notice_id
  FROM ins_dwh.dm_p_pol_header    pph
      ,ins_dwh.dm_t_sales_channel sc
      ,ins_dwh.dm_contact         c
      ,ins_dwh.fc_egp             e
 WHERE pph.sales_channel_id = sc.id
   AND pph.insurer_contact_id = c.contact_id(+) /*����. ��� �������, �.�. ��� �������*/
   AND pph.policy_header_id = e."ID �������� �����������"
   AND pph.is_tech_work = 0 /*�� �������, ��� �� ����*/
   AND ins_dwh.pkg_renlife_rep_utils.check_save_date_kp(pph.policy_header_id
                                                       ,pph.agent_header_id
                                                       ,e."���� �������"
                                                        ,'DWH_����� � ���������_������ ������_2011') = 0
      
   AND CASE
         WHEN sc.brief IN ('BANK', 'BR') THEN
          e."���� �������" + 45
         ELSE
          e."���� �������"
       END <= trunc(SYSDATE, 'mm') - 1 /*��� �� �� ������ ������ ����������� ��� ����������� � ���� ��� �
                                                                                                                              ����� ������� ���������� �������� �������� ������ 45 ����. (���� ������� �� - ��������� ���� �������� ������. )*/
   AND e."������ ���" != '�������'
   AND pph.start_date = e."���� ���" /*���� ������ �������� �������� �����������  ����� ���� ���������� ������������� ���*/
   AND CASE
         WHEN sc.brief IN ('BANK', 'BR') THEN
          e."���� ���" + 45
         ELSE
          e."���� ���"
       END >= SYSDATE - 30 --to_date('01.10.2008', 'dd.mm.rrrr') /*����� ������� �� - 01.10.2008*/
   AND pph.is_group_flag = 0 /*�� ���������*/
   AND e."������ ���" != '�����������'
      
   AND pph.status NOT IN ('����������'
                         ,'��������'
                         ,'�������'
                         ,'�������������'
                         ,'��������� � �����������'
                         ,'���������'
                         ,'� �����������. ����� ��� ��������'
                         ,'���������.� �������'
                         ,'� �����������'
                         ,'� �����������. ��������'
                         ,'���������.������ ����������'
                         ,'������'
                         ,'���������') /*������ ������� ������*/
   AND pph.last_ver_stat NOT IN ('����������'
                                ,'��������'
                                ,'�������������'
                                ,'��������� � �����������'
                                ,'��������� �� �����������'
                                ,'� �����������'
                                ,'� �����������. ����� ��� ��������'
                                ,'� �����������. ��������'
                                ,'���������. ������ ����������'
                                ,'���������. ��������� ��������'
                                ,'���������.� �������'
                                ,'���������'
                                ,'��������������'
                                ,'����� � ��������������'
                                ,'������� ������������� �� B2B') /*������ ��������� ������*/
      
   AND NOT EXISTS
 (SELECT NULL
          FROM ac_payment last_pay
         WHERE last_pay.payment_id IN (SELECT MAX(ac.payment_id)
                                         FROM p_policy       pp
                                             ,doc_doc        dd
                                             ,ac_payment     ac
                                             ,document       d
                                             ,doc_status_ref dsr
                                        WHERE pp.pol_header_id = pph.policy_header_id
                                          AND pp.policy_id = dd.parent_id
                                          AND dd.child_id = ac.payment_id
                                          AND ac.payment_id = d.document_id
                                          AND d.doc_status_ref_id = dsr.doc_status_ref_id
                                          AND dsr.brief = 'PAID')
           AND last_pay.plan_date > SYSDATE) /*��������� ��, � ������� ����� ������� ��� � ������� �������� � ������������ �� ������ ������� ����.*/
   AND NOT EXISTS (SELECT NULL
          FROM p_policy             pp
              ,t_policyform_product tp
         WHERE pp.pol_header_id = pph.policy_header_id
           AND pp.t_product_conds_id = tp.t_policyform_product_id
           AND tp.is_handchange = 1) /*��������� �� ��� ������� ����� �������� ������� � ��������� �������� ��������� ������� ���� (������ �������� �������).  */
 GROUP BY pph.policy_header_id
HAVING SUM(e."����� ��� �") - (CASE
  WHEN SUM(e."��������� �� ��� ����� �") IS NULL THEN
   0
  ELSE
   SUM(e."��������� �� ��� ����� �")
END) > 500 AND SUM(e."����� ��� �") != 0;
