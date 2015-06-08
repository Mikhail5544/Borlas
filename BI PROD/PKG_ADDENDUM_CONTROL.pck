CREATE OR REPLACE PACKAGE PKG_ADDENDUM_CONTROL IS
  FUNCTION CHECK_START_DATE(p_p_policy_id NUMBER) RETURN NUMBER;
  FUNCTION CHECK_START_DATE_FOR_STUPID(p_p_policy_id NUMBER) RETURN NUMBER;
  FUNCTION CHECK_QUART_DATE(p_p_policy_id NUMBER) RETURN NUMBER;
END; 
/
CREATE OR REPLACE PACKAGE BODY pkg_addendum_control IS

  P_DEBUG BOOLEAN DEFAULT TRUE;

  PROCEDURE LOG
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF P_DEBUG
    THEN
      INSERT INTO P_POLICY_DEBUG
        (p_policy_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_policy_id, SYSDATE, 'INS.PKG_ADDENDUM_CONTROL', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  /** �������� ������������ ���������� ���� ������ ������ ��.
   *
   */
  FUNCTION CHECK_START_DATE(p_p_policy_id NUMBER) RETURN NUMBER IS
    l_ph_start_date    DATE;
    l_pp_start_date    DATE;
    l_max_start_date   DATE;
    l_policy_header_id NUMBER;
    l_is_group         NUMBER;
    n_cnt_re           NUMBER := 0;
    is_nocheck         NUMBER := 0;
  BEGIN
    --������� ����� ��������� ������ �� � '��������������', '���������'
    --��� �������, ��� ������ ��������� �� � ������� �������
    SELECT COUNT(*)
      INTO n_cnt_re
      FROM doc_status     ds
          ,doc_status_ref rf
     WHERE ds.doc_status_ref_id = rf.doc_status_ref_id
       AND ds.document_id IN (SELECT pol.policy_id
                                FROM p_pol_header       ph
                                    ,p_policy           pp
                                    ,p_policy           pol
                                    ,ins.document       d
                                    ,ins.doc_status_ref rfa
                               WHERE pp.policy_id = p_p_policy_id
                                 AND pp.pol_header_id = ph.policy_header_id
                                 AND pol.pol_header_id = ph.policy_header_id
                                 AND pol.policy_id = d.document_id
                                 AND d.doc_status_ref_id = rfa.doc_status_ref_id
                                 AND rfa.brief != 'CANCEL')
       AND rf.name IN ('��������������', '���������');
    
    --���� ������ �� � ������� �������, �� ������� ����� ����� ��������� = <����� ���������>
    --� ����� ��������� = <�������� ���������>
    SELECT COUNT(*)
      INTO is_nocheck
      FROM ins.p_pol_addendum_type  pa
          ,ins.t_addendum_type      t
          ,ins.p_policy             pol
          ,ins.t_policy_change_type pt
          ,ins.document             d
          ,ins.doc_status_ref       rf
     WHERE pa.p_policy_id = p_p_policy_id
       AND pa.t_addendum_type_id = t.t_addendum_type_id
       AND pol.policy_id = p_p_policy_id
       AND t.brief = 'COMMON_CHANGES'
       AND pol.t_pol_change_type_id = pt.t_policy_change_type_id
       AND pt.brief = '��������'
       AND pol.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'CANCEL';
  
    --���� ������ �� � ������� �������, �� �������: 
    SELECT ph.start_date                --���� ������ ��
          ,pp.start_date                --���� ������ ������ ��
          ,policy_header_id             --�� ��������� ��
          ,nvl(pp.is_group_flag, 0)     --���� ���������� ��������(����������� �����)
      INTO l_ph_start_date
          ,l_pp_start_date
          ,l_policy_header_id
          ,l_is_group
      FROM p_pol_header       ph
          ,p_policy           pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE policy_header_id = pp.pol_header_id
       AND pp.policy_id = p_p_policy_id
       AND pp.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'CANCEL';
    
    --���� ���� ������ ������ �� �������� ���������� �� � ������� ��������������
    IF NOT (to_char(l_pp_start_date, 'dd.mm') = to_char(l_ph_start_date, 'dd.mm'))
       AND l_is_group = 0
    THEN
      --�������� �� ���� ��������� ������ ��, � ������ ���� ���� - ����� ������ �������
      --, � ����� ��� ��������� = <����� ���������>
      --� ����� ��������� = <�������� ���������>
      IF (to_char(l_pp_start_date, 'dd.mm') = '29.02')
         AND to_char(l_ph_start_date, 'dd.mm') = '28.02'
      THEN
        NULL;
      ELSIF to_char(l_pp_start_date, 'dd.mm') = '28.02'
            AND to_char(l_ph_start_date, 'dd.mm') = '29.02'
            AND to_char(l_pp_start_date + 1, 'dd.mm') = '01.03'
      THEN
        NULL;
      ELSIF is_nocheck > 0
      THEN
        NULL;
      ELSE
        PKG_FORMS_MESSAGE.put_message('����� ���� ��������������� ���������� ������ ���� ���������� ��������. �������� �� ������������. ');
        raise_application_error(-20000, '������');
      END IF;
    END IF;
    
    --���������� ������������ ���� ������ �� ������������ ������ �� � �� ������ ������ ��
    SELECT MAX(pp.start_date)
      INTO l_max_start_date
      FROM p_policy           pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE pol_header_id = l_policy_header_id
       AND policy_id != p_p_policy_id
       AND pp.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'CANCEL';
  
    LOG(p_p_policy_id
       ,'CHECK_START_DATE MAX PP_START_DATE ' || to_char(l_max_start_date, 'dd.mm.yyyy'));
       
    -- ���� ���� ������ �� ��, � ������� ���� ������ ������ ���� ������ ������ ������
    -- � ������ ������ �� �������� ������� '��������������', '���������'
    -- � �� ��� ��������� != <����� ���������> ��� ��� ��������� != <�������� ���������>
    -- �� ������ �������� �� ������
    IF NOT (l_pp_start_date >= l_max_start_date)
    THEN
      --PKG_FORMS_MESSAGE.put_message ('������ �������� ����������� 1 = '||to_char(p_p_policy_id));
      --PKG_FORMS_MESSAGE.put_message ('���-�� �������� 1 = '||to_char(n_cnt_re));
      IF is_nocheck != 0
      THEN
        NULL;
      ELSE
        IF n_cnt_re = 0
        THEN
          PKG_FORMS_MESSAGE.put_message('���������� ������ �������� ����������� � ����� ' ||
                                        to_char(l_max_start_date, 'dd.mm.yyyy'));
          raise_application_error(-20000, '������');
        END IF;
      END IF;
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION CHECK_START_DATE_FOR_STUPID(p_p_policy_id NUMBER) RETURN NUMBER IS
    l_ph_start_date    DATE;
    l_pp_start_date    DATE;
    l_max_start_date   DATE;
    l_policy_header_id NUMBER;
    l_is_group         NUMBER;
    n_cnt_re           NUMBER;
    is_nocheck         NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO n_cnt_re
      FROM doc_status     ds
          ,doc_status_ref rf
     WHERE ds.doc_status_ref_id = rf.doc_status_ref_id
       AND ds.document_id IN (SELECT pol.policy_id
                                FROM p_pol_header       ph
                                    ,p_policy           pp
                                    ,p_policy           pol
                                    ,ins.document       d
                                    ,ins.doc_status_ref rfa
                               WHERE pp.policy_id = p_p_policy_id
                                 AND pp.pol_header_id = ph.policy_header_id
                                 AND pol.pol_header_id = ph.policy_header_id
                                 AND pol.policy_id = d.document_id
                                 AND d.doc_status_ref_id = rfa.doc_status_ref_id
                                 AND rfa.brief != 'CANCEL')
       AND rf.name IN ('��������������', '���������');
  
    SELECT COUNT(*)
      INTO is_nocheck
      FROM ins.p_pol_addendum_type  pa
          ,ins.t_addendum_type      t
          ,ins.p_policy             pol
          ,ins.t_policy_change_type pt
          ,ins.document             d
          ,ins.doc_status_ref       rf
     WHERE pa.p_policy_id = p_p_policy_id
       AND pa.t_addendum_type_id = t.t_addendum_type_id
       AND pol.policy_id = p_p_policy_id
       AND t.brief = 'COMMON_CHANGES'
       AND pol.t_pol_change_type_id = pt.t_policy_change_type_id
       AND pt.brief = '��������'
       AND pol.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'CANCEL';
  
    SELECT ph.start_date
          ,pp.start_date
          ,policy_header_id
          ,nvl(pp.is_group_flag, 0)
      INTO l_ph_start_date
          ,l_pp_start_date
          ,l_policy_header_id
          ,l_is_group
      FROM p_pol_header       ph
          ,p_policy           pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE policy_header_id = pp.pol_header_id
       AND pp.policy_id = p_p_policy_id
       AND pp.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'CANCEL';
  
    SELECT MAX(pp.start_date)
      INTO l_max_start_date
      FROM p_policy           pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE pol_header_id = l_policy_header_id
       AND policy_id != p_p_policy_id
       AND pp.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'CANCEL';
  
    LOG(p_p_policy_id
       ,'CHECK_START_DATE_FOR_STUPID MAX PP_START_DATE ' || to_char(l_max_start_date, 'dd.mm.yyyy'));
  
    IF (l_pp_start_date < l_max_start_date)
    THEN
      --PKG_FORMS_MESSAGE.put_message ('������ �������� ����������� 2 = '||to_char(p_p_policy_id));
      --PKG_FORMS_MESSAGE.put_message ('���-�� �������� 2 = '||to_char(n_cnt_re));
      IF is_nocheck != 0
      THEN
        NULL;
      ELSE
        IF n_cnt_re = 0
        THEN
          PKG_FORMS_MESSAGE.put_message('���������� ������ �������� ����������� � ����� ' ||
                                        to_char(l_max_start_date, 'dd.mm.yyyy'));
          raise_application_error(-20000, '������');
        END IF;
      END IF;
    END IF;
  
    RETURN 1;
  
  END;
  /**/
  FUNCTION CHECK_QUART_DATE(p_p_policy_id NUMBER) RETURN NUMBER IS
    l_pp_start_date    DATE;
    l_max_start_date   DATE;
    l_policy_header_id NUMBER;
    n_cnt_re           NUMBER := 0;
    is_nocheck         NUMBER := 0;
    l_mod              NUMBER := 0;
  BEGIN
  
    SELECT COUNT(*)
      INTO n_cnt_re
      FROM doc_status     ds
          ,doc_status_ref rf
     WHERE ds.doc_status_ref_id = rf.doc_status_ref_id
       AND ds.document_id IN (SELECT pol.policy_id
                                FROM p_pol_header ph
                                    ,p_policy     pp
                                    ,p_policy     pol
                               WHERE pp.policy_id = p_p_policy_id
                                 AND pp.pol_header_id = ph.policy_header_id
                                 AND pol.pol_header_id = ph.policy_header_id)
       AND rf.name IN ('��������������', '���������');
  
    SELECT COUNT(*)
      INTO is_nocheck
      FROM ins.p_pol_addendum_type  pa
          ,ins.t_addendum_type      t
          ,ins.p_policy             pol
          ,ins.t_policy_change_type pt
     WHERE pa.p_policy_id = p_p_policy_id
       AND pa.t_addendum_type_id = t.t_addendum_type_id
       AND pol.policy_id = p_p_policy_id
       AND t.brief = 'COMMON_CHANGES'
       AND pol.t_pol_change_type_id = pt.t_policy_change_type_id
       AND pt.brief = '��������';
  
    SELECT CASE
             WHEN MOD(MONTHS_BETWEEN(pp.start_date, ph.start_date), 3) = 0 THEN
              1
             ELSE
              0
           END
          ,pp.start_date
      INTO l_mod
          ,l_pp_start_date
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE policy_header_id = pp.pol_header_id
       AND pp.policy_id = p_p_policy_id;
    IF l_mod != 1
    THEN
      PKG_FORMS_MESSAGE.put_message('����� ���� ��������������� ���������� ������ ���� ����� ������ ���������� ��������. �������� �� ������������. ');
      raise_application_error(-20000, '������');
    END IF;
  
    SELECT MAX(pp.start_date)
      INTO l_max_start_date
      FROM p_policy pp
     WHERE pol_header_id = l_policy_header_id
       AND policy_id != p_p_policy_id;
  
    LOG(p_p_policy_id
       ,'CHECK_START_DATE MAX PP_START_DATE ' || to_char(l_max_start_date, 'dd.mm.yyyy'));
  
    IF NOT (l_pp_start_date >= l_max_start_date)
    THEN
      --PKG_FORMS_MESSAGE.put_message ('������ �������� ����������� 1 = '||to_char(p_p_policy_id));
      --PKG_FORMS_MESSAGE.put_message ('���-�� �������� 1 = '||to_char(n_cnt_re));
      IF is_nocheck != 0
      THEN
        NULL;
      ELSE
        IF n_cnt_re = 0
        THEN
          PKG_FORMS_MESSAGE.put_message('���������� ������ �������� ����������� � ����� ' ||
                                        to_char(l_max_start_date, 'dd.mm.yyyy'));
          raise_application_error(-20000, '������');
        END IF;
      END IF;
    END IF;
  
    RETURN 1;
  
  END;
  /**/
END; 
/
