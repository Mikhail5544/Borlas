create or replace view V_ASSURED_DEAD as
WITH death_event AS
 (SELECT ce.date_get_doc_death_inshured
        ,ce.as_asset_id
    FROM c_event ce
   WHERE ce.date_get_doc_death_inshured IS NOT NULL)
SELECT 
/*�������� �����������, � ��������� ���������� ������� ������ �0 � ���,  
� ������� �������� �� �� �����������. ����� ��� ��������    �, �� �����������. ��������, ����������. ������ ����������, 
����������. ��������� ���������, ����������. � �������, ����������, �� ����������� �������� ������� ���ݻ,  
� ����������� �������������� ������ 1, 
����������� ����� ����� ��������� ������������� � ������ ���������������*/
pph.policy_id
      ,to_number(NULL) p_pol_change_notice_id
  FROM p_policy     pp
      ,as_asset     ast
      ,death_event  ce
      ,p_pol_header pph
 WHERE pp.is_group_flag = 0 /*�� ���������*/
   AND pp.policy_id = ast.p_policy_id
   AND pph.policy_id = pp.policy_id
   AND ast.as_asset_id = ce.as_asset_id
   AND ce.date_get_doc_death_inshured <= pp.end_date /*���� ������������� � ������ � ������ �������� ��*/
   AND (SELECT COUNT(*) FROM as_asset t WHERE t.p_policy_id = pp.policy_id) = 1 /*���-�� ������������� = 1*/
   AND NOT EXISTS (SELECT NULL
          FROM document       d
              ,doc_status_ref dsr
         WHERE pp.policy_id = d.document_id
           AND d.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief IN ('TO_QUIT_CHECK_READY'
                            ,'TO_QUIT_CHECKED'
                            ,'QUIT_REQ_QUERY'
                            ,'QUIT_REQ_GET'
                            ,'QUIT_TO_PAY'
                            ,'QUIT'
                            ,'TO_QUIT_AWAITING_USVE'
                            ,'STOPED'))

