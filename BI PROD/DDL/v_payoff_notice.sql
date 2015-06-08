CREATE OR REPLACE VIEW V_PAYOFF_NOTICE AS
SELECT
/*
�������� �����������, � ��������� ���������� ������� ������ �0 � ���,
��� ������� ���������� �������� ���� ���������� �� �������
� ����� ���������� �� ����������� � ������� ������ � ���������
26.12.2015 ������ �.
*/
 pph.policy_id
,cn.p_pol_change_notice_id
  FROM p_pol_change_notice      cn
      ,document                 d
      ,doc_status_ref           dsr
      ,t_pol_change_notice_type typ
      ,p_pol_header             pph
 WHERE cn.p_pol_change_notice_id = d.document_id
   AND d.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief = 'READY_TO_WORK' /*����� � ������*/
   AND cn.t_pol_change_notice_type_id = typ.t_pol_change_notice_type_id
   AND typ.brief = 'PAYOFF' /*��������� �� �������*/
   AND cn.policy_header_id = pph.policy_header_id
   AND NOT EXISTS (SELECT NULL
          FROM p_policy pp
         WHERE pp.pol_header_id = cn.policy_header_id
           AND pp.is_group_flag = 1) /*��� ������ � ��������� "��������� ��"*/
;
