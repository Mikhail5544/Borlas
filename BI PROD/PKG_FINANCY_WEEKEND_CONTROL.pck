CREATE OR REPLACE PACKAGE PKG_FINANCY_WEEKEND_CONTROL IS

  FUNCTION Check_Period(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --
  FUNCTION Check_Payment(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --  
  FUNCTION Check_Duration_2009(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --  
  FUNCTION Check_Duration_2010(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --
  FUNCTION Check_Anniversary(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --
  FUNCTION Check_Start_Date(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --
  FUNCTION Check_Insurance_Limit(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --
  FUNCTION Check_Version(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --  
  FUNCTION Check_Start(p_p_policy_id IN NUMBER) RETURN NUMBER;
  --
  FUNCTION FW_EXIT_Check_Start(p_p_policy_id IN NUMBER) RETURN NUMBER;
END; 
/
CREATE OR REPLACE PACKAGE BODY PKG_FINANCY_WEEKEND_CONTROL IS

  P_DEBUG   BOOLEAN DEFAULT TRUE;
  g_message VARCHAR2(100) := '������ "���������� ��������" �� ����� ���� ���������';

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
        (P_POLICY_ID, execution_date, operation_type, debug_message)
      VALUES
        (P_P_POLICY_id, SYSDATE, 'INS.PKG_FINANCY_WEEKEND_CONTROL', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  
  /** ��������, ��� ���� �������� �������� ������ ��� ����� 10 �����
    *
    */
  FUNCTION Check_Period(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_PERIOD');
  
    SELECT ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12)
      INTO RESULT
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    LOG(p_p_policy_id, 'CHECK_PERIOD result ' || RESULT);
    --
    IF RESULT < 10
    THEN
      PKG_FORMS_MESSAGE.put_message('���� �������� �������� ������ 10 ���. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_PERIOD ' || '���� �������� �������� ������ 10 ���. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    RETURN 1;
  END;
  --
  /** �������� ��� ���� �� ������ ������ ������������� ��� � �������� ���� �������
   * ������ ��� ����� ���� ������ ������ ��
   *
   */
  FUNCTION Check_Payment(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_PAYMENT');
  
    SELECT COUNT(1)
      INTO RESULT
      FROM v_policy_payment_schedule ps
          ,p_policy                  pp
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ps.POL_HEADER_ID = pp.pol_header_id
       AND plan_date < pp.start_date --sysdate
       AND doc_status_ref_name != '�������';
  
    LOG(p_p_policy_id, 'CHECK_PAYMENT result ' || RESULT);
  
    IF RESULT > 2
    THEN
      PKG_FORMS_MESSAGE.put_message('���������� ������������ �������� ������ 2. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_PAYMENT ' || '���������� ������������ �������� ������ 2. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    RETURN 1;
  END;

  --  
  FUNCTION Check_Duration_2009(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_DURATION_2009 ');
  
    IF extract(YEAR FROM SYSDATE) != 2009
    THEN
      RETURN 1;
    END IF;
  
    SELECT /*sysdate �������� �� pp.start_date ��������� 26.08.2009 �� ������� �������*/
     (MIN(pp.start_date) - MIN(decode(doc_status_ref_name, '�������', plan_date, ph.start_date)))
      INTO RESULT
      FROM v_policy_payment_schedule ps
          ,p_policy                  pp
          ,p_pol_header              ph
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ph.POLICY_HEADER_ID = pp.pol_header_id
       AND ps.POL_HEADER_ID = pp.pol_header_id;
  
    LOG(p_p_policy_id, 'CHECK_DURATION_2009 result ' || RESULT);
  
    IF RESULT < 182
    THEN
      PKG_FORMS_MESSAGE.put_message('���������� ������ ������ ��������. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_DURATION_2009 ' || '���������� ������ ������ ��������. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    RETURN 1;
  
  END;
  --  
  FUNCTION Check_Duration_2010(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    term             NUMBER;
    v_pol_start_date DATE;
    v_cnt            NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_DURATION_2010 ');
  
    IF extract(YEAR FROM SYSDATE) = 2009
    THEN
      RETURN 1;
    END IF;
  
    /*select t.number_of_payments
    into term
    from p_policy pp,
         t_payment_terms t
    where t.id = pp.payment_term_id
          and pp.policy_id = p_p_policy_id
          and t.description = '��������';
          
    
    if term >= 1 then
       
        select count(*)
        into result 
        from 
          v_policy_payment_schedule ps
        , p_policy pp 
        where 1=1
          and pp.policy_id = p_p_policy_id 
          and ps.POL_HEADER_ID = pp.pol_header_id
          and doc_status_ref_name ='�������';
      
        if result > 0 then 
           result := 367;
        else result := 0;
        end if;
     
     else*/
    -- ������ �.
    -- �������� ������� �������� ��� ���������� (������ 126303)
    SELECT pp.start_date INTO v_pol_start_date FROM p_policy pp WHERE pp.policy_id = p_p_policy_id;
  
    -- ������ ���� ��� �� ���� ������
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_policy   pp
                  ,p_policy   ph
                  ,doc_doc    dd
                  ,ac_payment ap
                  ,document   dc
                  ,doc_templ  dt
             WHERE pp.policy_id = p_p_policy_id
               AND ph.pol_header_id = pp.pol_header_id
               AND dd.parent_id = ph.policy_id
               AND dd.child_id = ap.payment_id
               AND dd.child_id = dc.document_id
               AND dc.doc_templ_id = dt.doc_templ_id
               AND dt.brief = 'PAYMENT'
               AND ap.plan_date = v_pol_start_date
               AND doc.get_doc_status_brief(ap.payment_id) IN ('NEW', 'TO_PAY'));
  
    LOG(p_p_policy_id, 'CHECK_DURATION_2010 ');
  
    IF v_cnt = 0
    THEN
      PKG_FORMS_MESSAGE.put_message('���� ������ ������ ������� �������. ���� ������ ���� ����� ���� ��� � ������� "� ������" ��� "�����"! ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_DURATION_2010 ' || '���� ������ ������ ������� �������. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
    -- �� ������ ���� ��� � �������� "� ������" � "�����" ����� ��������� ���
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_policy   pp
                  ,p_policy   ph
                  ,doc_doc    dd
                  ,ac_payment ap
                  ,document   dc
                  ,doc_templ  dt
             WHERE pp.policy_id = p_p_policy_id
               AND ph.pol_header_id = pp.pol_header_id
               AND dd.parent_id = ph.policy_id
               AND dd.child_id = ap.payment_id
               AND dd.child_id = dc.document_id
               AND dc.doc_templ_id = dt.doc_templ_id
               AND dt.brief = 'PAYMENT'
               AND ap.plan_date < v_pol_start_date
               AND doc.get_doc_status_brief(ap.payment_id) IN ('NEW', 'TO_PAY'));
  
    IF v_cnt = 1
    THEN
      PKG_FORMS_MESSAGE.put_message('�� ������ ���� ��� � ������� "�����" ��� "� ������" ����� ���� ������ ������. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_DURATION_2010 ' ||
          '�� ������ ���� ��� � ������� "�����" ��� "� ������" ����� ���� ������ ������. ' ||
          g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    -- ���� ����� ������ ��������������, ������ ���� �� ����� 2-� ���������� ���
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_policy        pp
                  ,t_payment_terms pt
             WHERE pp.policy_id = p_p_policy_id
               AND pp.payment_term_id = pt.id
               AND pt.brief = 'EVERY_QUARTER');
    IF v_cnt = 1
    THEN
      SELECT COUNT(1)
        INTO v_cnt
        FROM p_policy   pp
            ,p_policy   ph
            ,doc_doc    dd
            ,ac_payment ap
            ,document   dc
            ,doc_templ  dt
       WHERE pp.policy_id = p_p_policy_id
         AND ph.pol_header_id = pp.pol_header_id
         AND dd.parent_id = ph.policy_id
         AND dd.child_id = ap.payment_id
         AND dd.child_id = dc.document_id
         AND dc.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'PAYMENT'
         AND ap.plan_date < v_pol_start_date
         AND doc.get_doc_status_brief(ap.payment_id) = 'PAID';
      IF v_cnt < 2
      THEN
        PKG_FORMS_MESSAGE.put_message('���������� ������ ����� ��������. ' || g_message);
        LOG(p_p_policy_id
           ,'CHECK_DURATION_2010 ' || '���������� ������ ����� ��������. ' || g_message);
        raise_application_error(-20000, '������');
      END IF;
    END IF;
    /* ��� ���� ������
             select max(plan_date) - min (plan_date) into result 
            from 
              v_policy_payment_schedule ps
            , p_policy pp 
            where 1=1
              and pp.policy_id = p_p_policy_id 
              and ps.POL_HEADER_ID = pp.pol_header_id
              and plan_date < sysdate
              and doc_status_ref_name ='�������';
    
        LOG (p_p_policy_id, 'CHECK_DURATION_2010 ');        
        
        IF result < 366 THEN    
          PKG_FORMS_MESSAGE.put_message ('���������� ������ ������ ����. '||g_message);
          LOG (p_p_policy_id, 'CHECK_DURATION_2010 '||'���������� ������ ������ ����. '||g_message);
          
          raise_application_error (-20000, '������');
        END IF;          
    
    
    */
  
    /*elsif term = 4 then
    
    select sum(cn) 
    into result 
    from (  
        select count(ps.document_id) cn, ps.plan_date
        from 
          v_policy_payment_schedule ps
        , p_policy pp 
        where 1=1
          and pp.policy_id = p_p_policy_id 
          and ps.POL_HEADER_ID = pp.pol_header_id
          and plan_date < sysdate
          and doc_status_ref_name ='�������'
          group by ps.plan_date
          having count(ps.document_id) = 1
       );
       if result >= 4 then 
          result := 1;
       else result := 0;
       end if;*/
  
    /*elsif term = 2 then
    
        select sum(cn) 
        into result 
        from (  
            select count(ps.document_id) cn, ps.plan_date
            from 
              v_policy_payment_schedule ps
            , p_policy pp 
            where 1=1
              and pp.policy_id = p_p_policy_id 
              and ps.POL_HEADER_ID = pp.pol_header_id
              and plan_date < sysdate
              and doc_status_ref_name ='�������'
              group by ps.plan_date
              having count(ps.document_id) = 1
           );
           if result >= 2 then 
              result := 1;
           else result := 0;
           end if;
       
    elsif term = 12 then
    
        select sum(cn) 
        into result 
        from (  
            select count(ps.document_id) cn, ps.plan_date
            from 
              v_policy_payment_schedule ps
            , p_policy pp 
            where 1=1
              and pp.policy_id = p_p_policy_id 
              and ps.POL_HEADER_ID = pp.pol_header_id
              and plan_date < sysdate
              and doc_status_ref_name ='�������'
              group by ps.plan_date
              having count(ps.document_id) = 1
           );
           if result >= 12 then 
              result := 1;
           else result := 0;
           end if;
    end if;*/
  
    RETURN 1;
  END;
  --
  
 /** �������� 4-�� ���������
  * @param p_p_policy_id - ������ ��
  */    
  FUNCTION Check_Anniversary(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_ANNIVERSARY ');
    
    --���������� ����� ������ ��� � ���� ������ �������� �� �� ������� ����
    SELECT ROUND(MONTHS_BETWEEN(SYSDATE, ph.start_date) / 12)
      INTO RESULT
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    LOG(p_p_policy_id, 'CHECK_ANNIVERSARY result ' || RESULT);
    --���� ������ ��� ������ ����� 4-��, �� ������ ������: <��������� 4�� ���������>
    IF RESULT > 4
    THEN
      PKG_FORMS_MESSAGE.put_message('��������� 4�� ���������. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_ANNIVERSARY ' || '��������� 4�� ���������. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    RETURN 1;
  END;
  
  /** �������� ������������ ���� ������ ������ �� � ���� ���� �������� ���
  *
  */

  FUNCTION Check_Start_Date(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT            DATE;
    l_status_ref_name VARCHAR2(200);
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_START_DATE ');
    
    --��������, ��� ��� ������������ ���, � ������� ���� ������� ������ ���� ������ ������ �� 
    FOR cur IN (SELECT plan_date
                      ,ps.doc_status_ref_name       -- ��������� ������ ���
                  FROM v_policy_payment_schedule ps
                      ,p_policy                  pp
                 WHERE 1 = 1
                   AND pp.policy_id = p_p_policy_id
                   AND ps.POL_HEADER_ID = pp.pol_header_id
                   AND ps.plan_date < pp.start_date
                   AND ps.doc_status_ref_name NOT IN ('�������', '�����������'))
    LOOP
      PKG_FORMS_MESSAGE.put_message('���� ������ �������� ������ ������ ��������� � ����� ������� ������������� �������. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_START_DATE ' ||
          '���� ������ �������� ������ ������ ��������� � ����� ������� ������������� �������. ' ||
          g_message);
      raise_application_error(-20000, '������');
    
    END LOOP;
  
    FOR cur IN (SELECT plan_date
                      ,ps.doc_status_ref_name
                  FROM v_policy_payment_schedule ps
                      ,p_policy                  pp
                 WHERE 1 = 1
                   AND pp.policy_id = p_p_policy_id
                   AND ps.POL_HEADER_ID = pp.pol_header_id
                   AND ps.plan_date = pp.start_date)
    LOOP
      RESULT            := cur.plan_date;
      l_status_ref_name := cur.doc_status_ref_name;
    
    END LOOP;
  
    LOG(p_p_policy_id
       ,'CHECK_START_DATE PLAN_DATE ' || to_char(RESULT, 'dd.mm.yyyy') || l_status_ref_name);
       
    --���� ��� ���, � �������� ���� ���� ������� ��������� � ����� ������ ������,
    --�������� ������ 
    IF RESULT IS NULL
    THEN
      PKG_FORMS_MESSAGE.put_message('���� ������ �������� ������ �� ��������� � �������� ������. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_START_DATE ' || '���� ������ �������� ������ �� ��������� � �������� ������. ' ||
          g_message);
      raise_application_error(-20000, '������');
    END IF;
    
    --���� ���� ���������� ���, � �������� ���� ���� ������� ��������� � ����� ������ ������,
    --�������� ������ 
    IF RESULT IS NOT NULL
       AND l_status_ref_name = '�������'
    THEN
      PKG_FORMS_MESSAGE.put_message('���� ������ �������� ������ ��������� � ����� ����������� �������� �������. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_START_DATE ' ||
          '���� ������ �������� ������ ��������� � ����� ����������� �������� �������. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    RETURN 1;
  
  END;
  --
  FUNCTION Check_Insurance_Limit(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT            DATE;
    l_status_ref_name VARCHAR2(200);
    l_role_id         NUMBER;
    l_role_name       VARCHAR2(200);
    l_message         VARCHAR2(200) := '��������� ����� �� ���������  "������ ��������������� � ���������� ����������� ������" ��������� �����. ��������� ������� ������������. ';
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT');
  
    l_role_id := safety.get_curr_role;
    SELECT NAME INTO l_role_name FROM VEN_SYS_ROLE WHERE SYS_ROLE_ID = l_role_id;
  
    IF l_role_name = '�����������'
    THEN
      RETURN 1;
    END IF;
  
    LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT ROLE ' || l_role_name);
  
    FOR cur IN (SELECT cl.ins_amount
                      ,ph.fund_id
                  FROM v_asset_cover_life cl
                      ,as_asset           aa
                      ,p_pol_header       ph
                      ,p_policy           pp
                 WHERE aa.p_policy_id = p_p_policy_id
                   AND cl.as_asset_id = aa.as_asset_id
                   AND pp.policy_id = p_p_policy_id
                   AND ph.policy_header_id = pp.pol_header_id
                   AND cl.pl_brief =
                       '������ ��������������� � ���������� ����������� ������.���������� ��������')
    LOOP
    
      IF cur.fund_id = 5
         AND cur.ins_amount > 200000
      THEN
        PKG_FORMS_MESSAGE.put_message(l_message || ' ' || g_message);
        LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT');
        raise_application_error(-20000, '������');
      ELSIF cur.fund_id = 121
            AND cur.ins_amount > 300000
      THEN
        PKG_FORMS_MESSAGE.put_message(l_message || g_message);
        LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT ' || l_message || ' ' || g_message);
        raise_application_error(-20000, '������');
      ELSIF cur.fund_id = 122
            AND cur.ins_amount > 10000000
      THEN
        PKG_FORMS_MESSAGE.put_message(l_message || ' ' || g_message);
        LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT ' || l_message || ' ' || g_message);
        raise_application_error(-20000, '������');
      END IF;
    
    END LOOP;
  
    RETURN 1;
  
  END;

  FUNCTION Check_Version(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT            DATE;
    l_status_ref_name VARCHAR2(200);
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_VERSION');
  
    FOR cur IN (SELECT pp.start_date
                  FROM p_policy pp
                 WHERE pp.policy_id = p_p_policy_id
                   AND EXISTS (SELECT 1
                          FROM p_policy            pp1
                              ,p_pol_addendum_type pa
                              ,t_addendum_type     at
                              ,ins.document        d
                              ,ins.doc_status_ref  rf
                         WHERE pp1.pol_header_id = pp.pol_header_id
                           AND pp1.policy_id != pp.policy_id
                           AND trunc(pp1.start_date) >= trunc(pp.start_date)
                           AND pa.p_policy_id = pp1.policy_id
                           AND at.t_addendum_type_id = pa.t_addendum_type_id
                           AND at.brief = '���������������'
                           AND pp1.policy_id = d.document_id
                           AND d.doc_status_ref_id = rf.doc_status_ref_id
                           AND rf.brief != 'CANCEL'))
    LOOP
    
      PKG_FORMS_MESSAGE.put_message('���������� ������ �������� ����������� � ����� �� . ' ||
                                    to_char(cur.start_date, 'dd.mm.yyyy') ||
                                    ' ���������� �������� ��. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_VERSION ' || '���������� ������ �������� ����������� � ����� �� . ' ||
          to_char(cur.start_date, 'dd.mm.yyyy') || ' ���������� �������� ��. ' || g_message);
      raise_application_error(-20000, '������');
    
    END LOOP;
  
    RETURN 1;
  
  END;
  
  /** ��������� ������������ ��� � ����� ���� ������� ������ ���� ������ ������
   *
   */
   
  FUNCTION Check_FW_EXIT_Payment(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_PAYMENT');
    --��������� ������������ ��� � ����� ���� ������� ������ ���� ������ ������
    SELECT COUNT(1)
      INTO RESULT
      FROM v_policy_payment_schedule ps
          ,p_policy                  pp
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ps.POL_HEADER_ID = pp.pol_header_id
       AND plan_date < pp.start_date --sysdate
       AND doc_status_ref_name NOT IN ('�������', '�����������');
    --!='�������';
  
    LOG(p_p_policy_id, 'CHECK_FW_EXIT_PAYMENT result ' || RESULT);
    
    IF RESULT > 2
    THEN
      PKG_FORMS_MESSAGE.put_message('���������� ������������ �������. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_PAYMENT ' || '���������� ������������ �������. ' || g_message);
      raise_application_error(-20000, '������');
    END IF;
  
    RETURN 1;
  END;
  --
  FUNCTION Check_Start(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    LOG(p_p_policy_id, 'CHECK_START');
  
    RESULT := Check_Period(p_p_policy_id);
    --
    --result := Check_Payment (p_p_policy_id);
    --  
    RESULT := Check_Duration_2009(p_p_policy_id);
    --  
    RESULT := Check_Duration_2010(p_p_policy_id);
    --
    RESULT := Check_Anniversary(p_p_policy_id);
  
    RESULT := Check_Start_Date(p_p_policy_id);
  
    RESULT := Check_Version(p_p_policy_id);
  
    RESULT := Check_Insurance_Limit(p_p_policy_id);
  
    RETURN 1;
  END;
  
  /** �������� ������ �� ������ "���������� ��������"
  * ��������� ����������� � ��������� �������� �� ������� <���� ���. ����������>
  * @param p_p_policy_id - ������ ��
  */    
  FUNCTION FW_EXIT_Check_Start(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    LOG(p_p_policy_id, 'FW_EXIT_Check_Start');
    g_message := '����� �� ������ "���������� ��������" �� ����� ���� ��������';
    --�������� 4-�� ���������
    RESULT    := Check_Anniversary(p_p_policy_id);
    --��������� ������������ ��� � ����� ���� ������� ������ ���� ������ ������
    RESULT    := Check_FW_EXIT_Payment(p_p_policy_id);
  
    RETURN 1;
  
  END;

END; 
/
