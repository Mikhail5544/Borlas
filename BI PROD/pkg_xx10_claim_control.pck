CREATE OR REPLACE PACKAGE PKG_XX10_CLAIM_CONTROL IS

  --�������� ��� ��� ����� "���������� ���������." � ������� - ���������

  FUNCTION check_victim(p_c_claim_id NUMBER) RETURN NUMBER;

END PKG_XX10_CLAIM_CONTROL;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX10_CLAIM_CONTROL IS
  /*
  ��� �������� ������ � ������ "�������" ���
  ������� ��� ������, ��������������� ��
  ������ ����� � ����� ������� ���� ��� 
  "������� �� ����������" ��� "����������
  �������. ��������� � ����� �� �������
  ���������" ������������ �������� �����
  ���������� �������� � ����� "�����������"
  */

  FUNCTION check_victim(p_c_claim_id NUMBER) RETURN NUMBER IS
    l_c_claim_header_id NUMBER(12);
    l_product_brief     VARCHAR2(200);
  
  BEGIN
    SELECT ch.c_claim_header_id
          ,tp.brief
      INTO l_c_claim_header_id
          ,l_product_brief
      FROM t_product      tp
          ,p_pol_header   ph
          ,p_policy       pp
          ,c_claim        cc
          ,c_claim_header ch
     WHERE 1 = 1
       AND cc.c_claim_id = p_c_claim_id
       AND ch.c_claim_header_id = cc.c_claim_header_id
       AND pp.policy_id = ch.p_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND tp.product_id = ph.product_id;
  
    IF l_product_brief != '�����'
    THEN
      RETURN 1;
    END IF;
  
    FOR cur IN (SELECT 1
                  FROM c_damage      d
                      ,t_damage_code dc
                 WHERE 1 = 1
                   AND d.c_claim_id = p_c_claim_id
                   AND dc.id = d.t_damage_code_id
                   AND dc.brief IN ('����������', '��������������')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM C_EVENT_CONTACT      ec
                              ,C_EVENT_CONTACT_ROLE ecr
                              ,t_victim_osago_type  vt
                         WHERE 1 = 1
                           AND ec.C_CLAIM_HEADER_ID = l_c_claim_header_id
                           AND ecr.C_EVENT_CONTACT_ROLE_ID = ec.C_EVENT_CONTACT_ROLE_ID
                           AND ecr.brief = '�����������'
                           AND vt.t_victim_osago_type_id = ec.t_victim_osago_type_id
                           AND vt.description IN ('����������� - ������������������, ����� �����-���������'
                                                 ,'����������� - �������� ������ 18 ���'
                                                 ,'����������� - ������� ������ 60 ���'
                                                 ,'����������� - ������ ����')))
    LOOP
      RETURN 0;
    END LOOP;
  
    FOR cur IN (SELECT 1
                  FROM c_damage      d
                      ,t_damage_code dc
                      ,t_peril       tp
                 WHERE tp.brief = '�����_��������'
                   AND d.c_claim_id = p_c_claim_id
                   AND dc.peril = tp.id
                   AND dc.id = d.t_damage_code_id
                   AND dc.brief NOT IN ('����������', '��������������')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM C_EVENT_CONTACT      ec
                              ,C_EVENT_CONTACT_ROLE ecr
                              ,t_victim_osago_type  vt
                         WHERE 1 = 1
                           AND ec.C_CLAIM_HEADER_ID = l_c_claim_header_id
                           AND ecr.C_EVENT_CONTACT_ROLE_ID = ec.C_EVENT_CONTACT_ROLE_ID
                           AND ecr.brief = '�����������'
                           AND vt.t_victim_osago_type_id = ec.t_victim_osago_type_id
                           AND vt.description IN
                               ('����������� - ������������ ��,���������� ������'
                               ,'����������� - ���� ��������� ��,���������� ������'
                               ,'����������� - ���������,���������� ������'
                               ,'����������� - ��������,���������� ������'
                               ,'����������� - ������ ����,���������� ������'
                               ,'����������� - ������������ ��,���������� ���� ����������� ��������'
                               ,'����������� - ���� ��������� ��,���������� ���� ����������� ��������'
                               ,'����������� - ���������,���������� ���� ����������� ��������'
                               ,'����������� - ��������,���������� ���� ����������� ��������'
                               ,'����������� - ������ ����,���������� ���� ����������� ��������')))
    LOOP
      RETURN 0;
    END LOOP;
  
    FOR cur IN (SELECT 1
                  FROM c_damage      d
                      ,t_damage_code dc
                      ,t_peril       tp
                 WHERE tp.brief = '�����_���������'
                   AND d.c_claim_id = p_c_claim_id
                   AND dc.peril = tp.id
                   AND dc.id = d.t_damage_code_id
                   AND NOT EXISTS
                 (SELECT 1
                          FROM C_EVENT_CONTACT      ec
                              ,C_EVENT_CONTACT_ROLE ecr
                              ,t_victim_osago_type  vt
                         WHERE 1 = 1
                           AND ec.C_CLAIM_HEADER_ID = l_c_claim_header_id
                           AND ecr.C_EVENT_CONTACT_ROLE_ID = ec.C_EVENT_CONTACT_ROLE_ID
                           AND ecr.brief = '�����������'
                           AND vt.t_victim_osago_type_id = ec.t_victim_osago_type_id
                           AND vt.description IN
                               ('����������� - ������������ ��, ���������� ����� ���������'
                               ,'����������� - ���� ��������� ��, ���������� ����� ���������'
                               ,'����������� - ���������, ���������� ����� ���������'
                               ,'����������� - ��������, ���������� ����� ���������'
                               ,'����������� - ������ ����, ���������� ����� ���������')))
    LOOP
      RETURN 0;
    END LOOP;
  
    RETURN 1;
  
  END;

END;
/
