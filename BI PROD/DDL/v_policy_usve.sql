create or replace view V_POLICY_USVE as
/*�������� �����������, � ��������� ���������� ������� ������ �0 � ���,  � ������� �� �����������. �������� ������� ���ݻ, 
��� ������� ���� �� ���������� ������� �� ������, ��������� ����, ��������� ���� � ������� ��������� � �������,
 ���� � ������� ��������� �� ������, ���� � ������� �������. 
������ ������:
�  ������� ��������������� � ����������  �������;
�  ������� ��������������� � ���������� ����- ��� ��������������� �����������;
�  ������� ��������������� � ���������� ������� ��� ����������� �������;
�  ������� ��������������� � ���������� �������-������������� �������������;
�  ������� ��������������� � ���������� ����������� �������;
�  ������� ��������������� �� ����� �������;
�  ������� � ������������ � ���������� ����������� �������.
26.1.2015 ������ �.
*/
WITH policy_usve AS
 (SELECT pp.policy_id
        ,pp.pol_header_id
    FROM p_policy       pp
        ,document       d
        ,doc_status_ref dsr
        ,p_pol_header   pph
   WHERE pp.is_group_flag = 0 /*�� ���������*/
     AND pp.policy_id = pph.policy_id /*�������� ������*/
     AND pp.policy_id = d.document_id
     AND d.doc_status_ref_id = dsr.doc_status_ref_id
     AND dsr.brief IN ('TO_QUIT_AWAITING_USVE'))
SELECT pu.policy_id
      ,to_number(NULL) p_pol_change_notice_id
  FROM policy_usve    pu
      ,p_policy       pp
      ,c_claim_header ch
      ,c_claim        c
      ,document       cd
      ,doc_status_ref cdsr
      ,t_peril        tp
 WHERE pu.pol_header_id = pp.pol_header_id
   AND ch.p_policy_id = pp.policy_id
   AND ch.c_claim_header_id = c.c_claim_header_id
   AND c.c_claim_id = cd.document_id
   AND cd.doc_status_ref_id = cdsr.doc_status_ref_id
   AND cdsr.brief IN ('REFUSE_PAY', 'FOR_PAY', 'CLOSE')
   AND ch.peril_id = tp.id
   AND tp.description IN ('������ ��������������� � ���������� �������'
                         ,'������ ��������������� � ���������� ����- ��� ��������������� ����������'
                         ,'������ ��������������� � ���������� ������� ��� ����������� ������'
                         ,'������ ��������������� � ���������� �������-������������� ������������'
                         ,'������ ��������������� � ���������� ����������� ������'
                         ,'������ ��������������� �� ����� �������')
