CREATE OR REPLACE PACKAGE pkg_policy_wrapper IS

  FUNCTION do_validate_dates(p_policy_id NUMBER) RETURN NUMBER;
  PROCEDURE validate_pol_start_date
  (
    p_pol_id         NUMBER
   ,p_ph_id          NUMBER
   ,p_form_type      VARCHAR2
   ,p_is_autoprolong NUMBER
   ,p_err            OUT VARCHAR2
   ,p_raise          OUT NUMBER
  );
  PROCEDURE validate_pol_num
  (
    p_pol_id     NUMBER
   ,p_product_id NUMBER
   ,p_is_insert  NUMBER DEFAULT 0
   ,p_err        OUT VARCHAR2
   ,p_raise      OUT NUMBER
  );
  PROCEDURE SET_POL_END_DATE
  (
    p_pol_id        NUMBER
   ,p_product_brief VARCHAR2
   ,p_err           OUT VARCHAR2
   ,p_raise         OUT NUMBER
  );
  PROCEDURE change_pol_period
  (
    p_pol_id NUMBER
   ,p_err    OUT VARCHAR2
   ,p_raise  OUT NUMBER
  );
END pkg_policy_wrapper;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_wrapper IS

  FUNCTION do_validate_dates(p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
    -- if doc.get_last_doc_status_brief(p_policy_id) in ('BREAK','READY_TO_CANCEL') then
    IF doc.get_last_doc_status_brief(p_policy_id) NOT IN ('PROJECT')
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END;

  PROCEDURE validate_pol_start_date
  (
    p_pol_id         NUMBER
   ,p_ph_id          NUMBER
   ,p_form_type      VARCHAR2
   ,p_is_autoprolong NUMBER
   ,p_err            OUT VARCHAR2
   ,p_raise          OUT NUMBER
  ) IS
    v_pol_start_date DATE;
    v_pol_end_date   DATE;
    v_date           DATE;
    v_acc_cnt        NUMBER;
    v_validate_flag  NUMBER := do_validate_dates(p_pol_id);
    v_cur_policy     P_POLICY%ROWTYPE;
    v_policy         P_POLICY%ROWTYPE;
  BEGIN
  
    p_raise := 1;
  
    SELECT * INTO v_policy FROM P_POLICY WHERE policy_id = p_pol_id;
  
    SELECT p.*
      INTO v_cur_policy
      FROM P_POLICY     p
          ,P_POL_HEADER ph
     WHERE p.POLICY_ID = ph.POLICY_ID
       AND ph.POLICY_HEADER_ID = p_ph_id;
  
    v_pol_start_date := TRUNC(v_cur_policy.start_date, 'DD');
    v_pol_end_date   := TRUNC(v_cur_policy.end_date, 'DD');
  
    IF pkg_policy.is_addendum(p_pol_id) = 1
    THEN
    
      -- Для ВТБ проверка на дату подписания    
      IF pkg_app_param.get_app_param_n('CLIENTID') = 10
      THEN
        v_date := GREATEST(NVL(TRUNC(v_policy.notice_DATE_ADDENDUM, 'DD')
                              ,TRUNC(v_policy.sign_date, 'DD')));
        IF v_validate_flag = 1
           AND v_date > TRUNC(v_policy.start_date, 'DD')
        THEN
          p_err := 'Неверная дата подписания доп. соглашения';
          RETURN;
        END IF;
      
        IF v_validate_flag = 1
           AND
           TRUNC(v_policy.CONFIRM_DATE_ADDENDUM, 'DD') < TRUNC(v_policy.notice_date_addendum, 'DD')
        THEN
          p_err := 'Дата вступления в силу раньше даты подписания';
          RETURN;
        END IF;
      
        IF v_validate_flag = 1
           AND TRUNC(v_policy.start_date, 'DD') < TRUNC(v_policy.confirm_date_addendum, 'DD')
        THEN
          p_err := 'Дата вступления в силу позже даты начала';
          RETURN;
        END IF;
      
      END IF;
      -- конец проверки   
    
      IF v_validate_flag = 1
         AND TRUNC(v_policy.start_date, 'DD') >= v_pol_end_date
      THEN
        p_err := 'Дата начала доп. соглашения не должна быть равна или позже даты окончания текущего полиса (доп.соглашения)';
        RETURN;
      END IF;
    
      IF v_validate_flag = 1
         AND v_policy.start_date > v_policy.end_date
      THEN
        p_err := 'Дата начала не должна быть позже даты окончания';
        RETURN;
      END IF;
    ELSE
      -- Для ВТБ проверка на дату подписания    
      IF pkg_app_param.get_app_param_n('CLIENTID') = 10
      THEN
      
        IF v_validate_flag = 1
           AND TRUNC(v_policy.start_date, 'DD') < TRUNC(v_policy.notice_date_addendum, 'DD')
        THEN
          p_err := 'Дата начала раньше даты подписания';
          RETURN;
        END IF;
      
        IF v_validate_flag = 1
           AND
           TRUNC(v_policy.CONFIRM_DATE_ADDENDUM, 'DD') < TRUNC(v_policy.notice_date_addendum, 'DD')
        THEN
          p_err := 'Дата вступления в силу раньше даты подписания';
          RETURN;
        END IF;
      
        IF v_validate_flag = 1
           AND TRUNC(v_policy.start_date, 'DD') < TRUNC(v_policy.confirm_date_addendum, 'DD')
        THEN
          p_err := 'Дата вступления в силу позже даты начала';
          RETURN;
        END IF;
      
      END IF;
      -- конец проверки
    END IF;
  
    -- Для продуктов РЖ и для ВТБ (с признаком автопролонгация) проверка на то, что дата доп. соглашения попадает в страховую годовщину
  
    IF (NVL(p_form_type, '?') = 'Жизнь' AND NVL(v_policy.is_group_flag, 0) = 0)
       OR (pkg_app_param.get_app_param_n('CLIENTID') = 10 AND p_is_autoprolong = 1)
    THEN
      IF pkg_policy.is_addendum(v_policy.policy_id) = 1
      THEN
        IF v_validate_flag = 1
        THEN
          v_pol_start_date := TRUNC(v_cur_policy.start_date, 'DD');
          v_pol_end_date   := TRUNC(v_cur_policy.start_date, 'DD');
          v_date           := v_pol_start_date;
          LOOP
            IF TRUNC(v_policy.start_date, 'DD') = v_date
            THEN
              EXIT;
            END IF;
            IF v_date < v_pol_start_date
               OR v_date > v_pol_end_date
            THEN
              p_err := 'Неверная дата начала доп. соглашения';
              RETURN;
            END IF;
            v_date := ADD_MONTHS(v_date, 12);
          END LOOP;
        END IF;
      END IF;
    END IF;
  
    -- конец кода для РЖ
  END;

  PROCEDURE validate_pol_num
  (
    p_pol_id     NUMBER
   ,p_product_id NUMBER
   ,p_is_insert  NUMBER DEFAULT 0
   ,p_err        OUT VARCHAR2
   ,p_raise      OUT NUMBER
  ) IS
    v_num    NUMBER := 0;
    v_policy P_POLICY%ROWTYPE;
  BEGIN
    p_raise := 1;
  
    SELECT * INTO v_policy FROM P_POLICY WHERE policy_id = p_pol_id;
  
    BEGIN
      SELECT COUNT(DISTINCT ph.policy_header_id)
        INTO v_num
        FROM ven_p_policy     p
            ,ven_p_pol_header ph
       WHERE p.pol_num LIKE v_policy.pol_num
         AND ph.policy_header_id = p.pol_header_id
         AND ph.policy_header_id <> v_policy.pol_header_id
         AND ph.product_id = p_product_id;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_num := 0;
    END;
    IF v_num > 0
    THEN
      p_err := 'Договор с таким номером уже существует';
      RETURN;
    END IF;
  END;

  PROCEDURE SET_POL_END_DATE
  (
    p_pol_id        NUMBER
   ,p_product_brief VARCHAR2
   ,p_err           OUT VARCHAR2
   ,p_raise         OUT NUMBER
  ) IS
    v_val     NUMBER;
    v_name    VARCHAR2(150);
    v_one_sec NUMBER := 1 / 24 / 3600;
    v_policy  P_POLICY%ROWTYPE;
  BEGIN
  
    p_raise := 1;
  
    SELECT * INTO v_policy FROM P_POLICY WHERE policy_id = p_pol_id;
  
    SELECT p.period_value
          ,pt.description
      INTO v_val
          ,v_name
      FROM ven_t_period      p
          ,ven_t_period_type pt
     WHERE p.PERIOD_TYPE_ID = pt.ID
       AND p.ID = v_policy.period_id;
  
    IF v_val IS NOT NULL
    THEN
      IF p_product_brief = 'ОСАГО'
      THEN
        CASE v_name
          WHEN 'Дни' THEN
            v_policy.end_date := TRUNC(v_policy.start_date, 'DD') + v_val - v_one_sec;
          WHEN 'Месяцы' THEN
            v_policy.end_date := ADD_MONTHS(TRUNC(v_policy.start_date, 'DD'), v_val) - v_one_sec;
          WHEN 'Годы' THEN
            IF TO_CHAR(TRUNC(v_policy.start_date), 'ddmm') = '2902'
            THEN
              v_policy.end_date := ADD_MONTHS(TRUNC(v_policy.start_date, 'DD') + 1, v_val * 12) -
                                   v_one_sec;
            ELSE
              v_policy.end_date := ADD_MONTHS(TRUNC(v_policy.start_date, 'DD'), v_val * 12) -
                                   v_one_sec;
            END IF;
          ELSE
            NULL;
        END CASE;
      ELSE
        CASE v_name
          WHEN 'Дни' THEN
            v_policy.end_date := v_policy.start_date + v_val - v_one_sec;
          WHEN 'Месяцы' THEN
            v_policy.end_date := ADD_MONTHS(v_policy.start_date, v_val) - v_one_sec;
          WHEN 'Годы' THEN
            IF TO_CHAR(v_policy.start_date, 'ddmm') = '2902'
            THEN
              v_policy.end_date := ADD_MONTHS(v_policy.start_date + 1, v_val * 12) - v_one_sec;
            ELSE
              v_policy.end_date := ADD_MONTHS(v_policy.start_date, v_val * 12) - v_one_sec;
            END IF;
          ELSE
            NULL;
        END CASE;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      v_policy.end_date := NULL;
  END;

  PROCEDURE change_pol_period
  (
    p_pol_id NUMBER
   ,p_err    OUT VARCHAR2
   ,p_raise  OUT NUMBER
  ) IS
    v_period_id   NUMBER;
    v_period_name VARCHAR2(2000);
    v_brief       VARCHAR2(30);
    v_policy      P_POLICY%ROWTYPE;
  BEGIN
    p_raise := 1;
  
    SELECT * INTO v_policy FROM P_POLICY WHERE policy_id = p_pol_id;
  
    IF (v_policy.start_date IS NOT NULL)
       AND (v_policy.end_date IS NOT NULL)
    THEN
      v_period_id := pkg_policy.find_pol_period(p_pol_id
                                               ,v_policy.period_id
                                               ,v_policy.start_date
                                               ,v_policy.end_date);
      BEGIN
        v_brief := doc.get_last_doc_status_brief(p_pol_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_brief := 'NOTNULL';
      END;
    
      IF (v_period_id IS NULL)
         AND (v_brief NOT IN ('BREAK', 'READY_TO_CANCEL'))
      THEN
        p_err := 'На продукте нет периода, соответствующего срокам действия договора';
        RETURN;
      END IF;
    
    END IF;
  
  END;

BEGIN
  -- Initialization
  NULL;
END pkg_policy_wrapper;
/
