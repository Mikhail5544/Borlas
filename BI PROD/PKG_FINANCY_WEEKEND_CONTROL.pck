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
  g_message VARCHAR2(100) := 'Услуга "Финансовые каникулы" не может быть применена';

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
  
  /** Проверка, что срок действия договора больше или равен 10 годам
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
      PKG_FORMS_MESSAGE.put_message('Срок действия договора меньше 10 лет. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_PERIOD ' || 'Срок действия договора меньше 10 лет. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
    END IF;
  
    RETURN 1;
  END;
  --
  /** Проверка что есть не больше одного неоплаченного ЭПГ у которого дата графика
   * больше или равна дате начала версии ДС
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
       AND doc_status_ref_name != 'Оплачен';
  
    LOG(p_p_policy_id, 'CHECK_PAYMENT result ' || RESULT);
  
    IF RESULT > 2
    THEN
      PKG_FORMS_MESSAGE.put_message('Количество неоплаченных платежей больше 2. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_PAYMENT ' || 'Количество неоплаченных платежей больше 2. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
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
  
    SELECT /*sysdate изменено на pp.start_date Веселухой 26.08.2009 по просьбе Марчука*/
     (MIN(pp.start_date) - MIN(decode(doc_status_ref_name, 'Оплачен', plan_date, ph.start_date)))
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
      PKG_FORMS_MESSAGE.put_message('Оплаченный период меньше полугода. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_DURATION_2009 ' || 'Оплаченный период меньше полугода. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
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
          and t.description = 'Ежегодно';
          
    
    if term >= 1 then
       
        select count(*)
        into result 
        from 
          v_policy_payment_schedule ps
        , p_policy pp 
        where 1=1
          and pp.policy_id = p_p_policy_id 
          and ps.POL_HEADER_ID = pp.pol_header_id
          and doc_status_ref_name ='Оплачен';
      
        if result > 0 then 
           result := 367;
        else result := 0;
        end if;
     
     else*/
    -- Байтин А.
    -- Изменены условия проверки для ФинКаникул (заявка 126303)
    SELECT pp.start_date INTO v_pol_start_date FROM p_policy pp WHERE pp.policy_id = p_p_policy_id;
  
    -- Должна быть ЭПГ на дату версии
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
      PKG_FORMS_MESSAGE.put_message('Дата начала версии указана неверно. Дата должна быть равна дате ЭПГ в статусе "К оплате" или "Новый"! ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_DURATION_2010 ' || 'Дата начала версии указана неверно. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
    END IF;
    -- Не должно быть ЭПГ в статусах "К оплате" и "Новый" ранее найденной ЭПГ
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
      PKG_FORMS_MESSAGE.put_message('Не должно быть ЭПГ в статусе "Новый" или "К оплате" ранее даты начала версии. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_DURATION_2010 ' ||
          'Не должно быть ЭПГ в статусе "Новый" или "К оплате" ранее даты начала версии. ' ||
          g_message);
      raise_application_error(-20000, 'Ошибка');
    END IF;
  
    -- Если форма оплаты ежеквартальная, должно быть не менее 2-х оплаченных ЭПГ
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
        PKG_FORMS_MESSAGE.put_message('Оплаченный период менее полугода. ' || g_message);
        LOG(p_p_policy_id
           ,'CHECK_DURATION_2010 ' || 'Оплаченный период менее полугода. ' || g_message);
        raise_application_error(-20000, 'Ошибка');
      END IF;
    END IF;
    /* Так было раньше
             select max(plan_date) - min (plan_date) into result 
            from 
              v_policy_payment_schedule ps
            , p_policy pp 
            where 1=1
              and pp.policy_id = p_p_policy_id 
              and ps.POL_HEADER_ID = pp.pol_header_id
              and plan_date < sysdate
              and doc_status_ref_name ='Оплачен';
    
        LOG (p_p_policy_id, 'CHECK_DURATION_2010 ');        
        
        IF result < 366 THEN    
          PKG_FORMS_MESSAGE.put_message ('Оплаченный период меньше года. '||g_message);
          LOG (p_p_policy_id, 'CHECK_DURATION_2010 '||'Оплаченный период меньше года. '||g_message);
          
          raise_application_error (-20000, 'Ошибка');
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
          and doc_status_ref_name ='Оплачен'
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
              and doc_status_ref_name ='Оплачен'
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
              and doc_status_ref_name ='Оплачен'
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
  
 /** Проверка 4-ой годовщины
  * @param p_p_policy_id - версия ДС
  */    
  FUNCTION Check_Anniversary(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_ANNIVERSARY ');
    
    --Определяем число полных лет с даты начала действия ДС по текущую дату
    SELECT ROUND(MONTHS_BETWEEN(SYSDATE, ph.start_date) / 12)
      INTO RESULT
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    LOG(p_p_policy_id, 'CHECK_ANNIVERSARY result ' || RESULT);
    --Если полных лет прошло более 4-ех, то выдаем ошибку: <Наступила 4ая годовщина>
    IF RESULT > 4
    THEN
      PKG_FORMS_MESSAGE.put_message('Наступила 4ая годовщина. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_ANNIVERSARY ' || 'Наступила 4ая годовщина. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
    END IF;
  
    RETURN 1;
  END;
  
  /** Проверка соответствия даты начала версии ДС и даты план графиков ЭПГ
  *
  */

  FUNCTION Check_Start_Date(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT            DATE;
    l_status_ref_name VARCHAR2(200);
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_START_DATE ');
    
    --Проверям, что нет неоплаченных ЭПГ, у которых дата графика меньше дата начала версии ДС 
    FOR cur IN (SELECT plan_date
                      ,ps.doc_status_ref_name       -- последний статус ЭПГ
                  FROM v_policy_payment_schedule ps
                      ,p_policy                  pp
                 WHERE 1 = 1
                   AND pp.policy_id = p_p_policy_id
                   AND ps.POL_HEADER_ID = pp.pol_header_id
                   AND ps.plan_date < pp.start_date
                   AND ps.doc_status_ref_name NOT IN ('Оплачен', 'Аннулирован'))
    LOOP
      PKG_FORMS_MESSAGE.put_message('Дата начала действия версии должна совпадать с датой первого неоплаченного платежа. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_START_DATE ' ||
          'Дата начала действия версии должна совпадать с датой первого неоплаченного платежа. ' ||
          g_message);
      raise_application_error(-20000, 'Ошибка');
    
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
       
    --если нет ЭПГ, у которого дата план графика совпадает с датой начала версии,
    --сообщаем ошибку 
    IF RESULT IS NULL
    THEN
      PKG_FORMS_MESSAGE.put_message('Дата начала действия версии не совпадает с графиком оплаты. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_START_DATE ' || 'Дата начала действия версии не совпадает с графиком оплаты. ' ||
          g_message);
      raise_application_error(-20000, 'Ошибка');
    END IF;
    
    --если есть оплаченное ЭПГ, у которого дата план графика совпадает с датой начала версии,
    --сообщаем ошибку 
    IF RESULT IS NOT NULL
       AND l_status_ref_name = 'Оплачен'
    THEN
      PKG_FORMS_MESSAGE.put_message('Дата начала действия версии совпадает с датой оплаченного элемента графика. ' ||
                                    g_message);
      LOG(p_p_policy_id
         ,'CHECK_START_DATE ' ||
          'Дата начала действия версии совпадает с датой оплаченного элемента графика. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
    END IF;
  
    RETURN 1;
  
  END;
  --
  FUNCTION Check_Insurance_Limit(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT            DATE;
    l_status_ref_name VARCHAR2(200);
    l_role_id         NUMBER;
    l_role_name       VARCHAR2(200);
    l_message         VARCHAR2(200) := 'Страховая сумма по программе  "Смерть Застрахованного в результате несчастного случая" превышает лимит. Требуется участие Андеррайтера. ';
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT');
  
    l_role_id := safety.get_curr_role;
    SELECT NAME INTO l_role_name FROM VEN_SYS_ROLE WHERE SYS_ROLE_ID = l_role_id;
  
    IF l_role_name = 'Андеррайтер'
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
                       'Смерть Застрахованного в результате несчастного случая.Финансовые каникулы')
    LOOP
    
      IF cur.fund_id = 5
         AND cur.ins_amount > 200000
      THEN
        PKG_FORMS_MESSAGE.put_message(l_message || ' ' || g_message);
        LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT');
        raise_application_error(-20000, 'Ошибка');
      ELSIF cur.fund_id = 121
            AND cur.ins_amount > 300000
      THEN
        PKG_FORMS_MESSAGE.put_message(l_message || g_message);
        LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT ' || l_message || ' ' || g_message);
        raise_application_error(-20000, 'Ошибка');
      ELSIF cur.fund_id = 122
            AND cur.ins_amount > 10000000
      THEN
        PKG_FORMS_MESSAGE.put_message(l_message || ' ' || g_message);
        LOG(p_p_policy_id, 'CHECK_INSURANCE_LIMIT ' || l_message || ' ' || g_message);
        raise_application_error(-20000, 'Ошибка');
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
                           AND at.brief = 'Автопролонгация'
                           AND pp1.policy_id = d.document_id
                           AND d.doc_status_ref_id = rf.doc_status_ref_id
                           AND rf.brief != 'CANCEL'))
    LOOP
    
      PKG_FORMS_MESSAGE.put_message('Обнаружена версия договора страхования с датой до . ' ||
                                    to_char(cur.start_date, 'dd.mm.yyyy') ||
                                    ' Необходимо отменить ДС. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_VERSION ' || 'Обнаружена версия договора страхования с датой до . ' ||
          to_char(cur.start_date, 'dd.mm.yyyy') || ' Необходимо отменить ДС. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
    
    END LOOP;
  
    RETURN 1;
  
  END;
  
  /** Проверяем неоплаченные ЭПГ с датой план графика меньше даты начала версии
   *
   */
   
  FUNCTION Check_FW_EXIT_Payment(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_policy_id, 'CHECK_PAYMENT');
    --проверяем неоплаченные ЭПГ с датой план графика меньше даты начала версии
    SELECT COUNT(1)
      INTO RESULT
      FROM v_policy_payment_schedule ps
          ,p_policy                  pp
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ps.POL_HEADER_ID = pp.pol_header_id
       AND plan_date < pp.start_date --sysdate
       AND doc_status_ref_name NOT IN ('Оплачен', 'Аннулирован');
    --!='Оплачен';
  
    LOG(p_p_policy_id, 'CHECK_FW_EXIT_PAYMENT result ' || RESULT);
    
    IF RESULT > 2
    THEN
      PKG_FORMS_MESSAGE.put_message('Обнаружены неоплаченные платежи. ' || g_message);
      LOG(p_p_policy_id
         ,'CHECK_PAYMENT ' || 'Обнаружены неоплаченные платежи. ' || g_message);
      raise_application_error(-20000, 'Ошибка');
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
  
  /** Контроль выхода из услуги "Финансовые каникулы"
  * Процедура установлена в настройке продукта на вкладке <Типы доп. соглашений>
  * @param p_p_policy_id - версия ДС
  */    
  FUNCTION FW_EXIT_Check_Start(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    LOG(p_p_policy_id, 'FW_EXIT_Check_Start');
    g_message := 'Выход из услуги "Финансовые каникулы" не может быть применен';
    --Проверка 4-ой годовщины
    RESULT    := Check_Anniversary(p_p_policy_id);
    --Проверяем неоплаченные ЭПГ с датой план графика меньше даты начала версии
    RESULT    := Check_FW_EXIT_Payment(p_p_policy_id);
  
    RETURN 1;
  
  END;

END; 
/
