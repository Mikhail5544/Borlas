CREATE OR REPLACE PACKAGE pkg_app_param IS
  /**
  * Пакет работы с параметрами системы
  * @headcom
  */

  TYPE T_APP_PARAM IS RECORD(
     IS_NULL          NUMBER(1)
    ,APP_PARAM_ID     NUMBER
    ,APP_PARAM_VAL_ID NUMBER
    ,VAL_C            VARCHAR2(150)
    ,VAL_N            NUMBER
    ,VAL_D            DATE
    ,VAL_URE_ID       NUMBER(6)
    ,VAL_URO_ID       NUMBER);

  date_work  DATE; -- Дата работы
  date_start DATE; -- Начало периода работы
  date_end   DATE; -- Окончание периода работы

  --Purpose: Получить значение параметра в структуру определенного типа
  FUNCTION get_app_param
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN t_app_param;

  --Purpose: Получить значение параметра типа varchar2
  FUNCTION get_app_param_c
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  --Purpose: Получить значение параметра типа number
  FUNCTION get_app_param_n
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  --Purpose: Получить значение параметра типа date
  FUNCTION get_app_param_d
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN DATE;

  --Purpose: Получить значение параметра типа uref
  FUNCTION get_app_param_u
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  -- Purpose : Сохранить значение настройки приложения в виде строки
  PROCEDURE set_app_param_c
  (
    p_brief VARCHAR2
   , -- Сокращение параметра
    p_val   VARCHAR2
   , -- Значение
    p_date  DATE DEFAULT NULL
   , -- Дата значения параметра
    p_user  VARCHAR2 DEFAULT NULL -- Пользователь
  );
  -- Purpose : Сохранить значение настройки приложения в виде числа
  PROCEDURE set_app_param_n
  (
    p_brief VARCHAR2
   , -- Сокращение параметра
    p_val   NUMBER
   , -- Значение
    p_date  DATE DEFAULT NULL
   , -- Дата значения параметра
    p_user  VARCHAR2 DEFAULT NULL -- Пользователь
  );

  -- Purpose : Сохранить значение настройки приложения в виде даты  
  PROCEDURE set_app_param_d
  (
    p_brief VARCHAR2
   , -- Сокращение параметра
    p_val   DATE
   , -- Значение
    p_date  DATE DEFAULT NULL
   , -- Дата значения параметра
    p_user  VARCHAR2 DEFAULT NULL -- Пользователь
  );

  -- Purpose : Сохранить значение настройки приложения в виде универсальной ссылки
  PROCEDURE set_app_param_u
  (
    p_brief VARCHAR2
   , -- Сокращение параметра
    p_val   NUMBER
   , -- Значение ИД Объекта
    p_date  DATE DEFAULT NULL
   , -- Дата значения параметра
    p_user  VARCHAR2 DEFAULT NULL -- Пользователь
  );

  -- Purpose : Установка даты работы и периода работы в сессии
  PROCEDURE set_dates
  (
    p_work  IN DATE -- Дата работы
      DEFAULT SYSDATE
   ,p_start IN DATE -- Дата начала периода работы
    DEFAULT SYSDATE
   ,p_end   IN DATE -- Дата окончания периода работы
       DEFAULT SYSDATE
   ,p_mode  NUMBER -- Режим хранения времени
      DEFAULT 3
  );

  -- Purpose : Получить дату работы и период работы настройках
  PROCEDURE app_param_dates
  (
    p_work  OUT DATE
   ,p_start OUT DATE
   ,p_end   OUT DATE
  );

  -- Purpose : Сохранить дату работы и период работы настройках
  PROCEDURE set_app_param_dates
  (
    p_work  IN DATE
   ,p_start IN DATE
   ,p_end   IN DATE
  );
  -- Регистрирует новый параметр. Возвращает 1, если  параметр с заданным p_brief существует 
  FUNCTION register_app_param
  (
    p_name        VARCHAR2
   ,p_brief       VARCHAR2
   ,p_group_brief VARCHAR2
   ,p_param_type  NUMBER
   ,p_val         t_app_param
  ) RETURN NUMBER;
END pkg_app_param;
/
CREATE OR REPLACE PACKAGE BODY pkg_app_param IS

  FUNCTION register_app_param
  (
    p_name        VARCHAR2
   ,p_brief       VARCHAR2
   ,p_group_brief VARCHAR2
   ,p_param_type  NUMBER
   ,p_val         t_app_param
  ) RETURN NUMBER IS
    v_app_param      APP_PARAM%ROWTYPE;
    v_param_group_id NUMBER;
    v_brief          VARCHAR2(200);
  BEGIN
    v_brief := UPPER(p_brief);
    BEGIN
      SELECT * INTO v_app_param FROM APP_PARAM ap WHERE ap.brief = v_brief;
      RETURN 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    BEGIN
      SELECT app_param_group_id
        INTO v_param_group_id
        FROM APP_PARAM_GROUP
       WHERE brief = p_group_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100, 'Не найдена группа параметров');
    END;
  
    INSERT INTO ven_app_param
      (app_param_group_id
      ,brief
      ,NAME
      ,param_type
      ,def_value_n
      ,def_value_c
      ,def_value_d
      ,def_value_ure_id
      ,def_value_uro_id)
    VALUES
      (v_param_group_id
      ,v_brief
      ,p_name
      ,p_param_type
      ,p_val.VAL_N
      ,p_val.VAL_C
      ,p_val.VAL_D
      ,p_val.VAL_URE_ID
      ,p_val.VAL_URO_ID);
    RETURN 0;
  END;

  --Purpose: Получить значение параметра в структуру определенного типа
  FUNCTION get_app_param
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN t_app_param IS
    v_t_app_param t_app_param;
    v_app_param   APP_PARAM%ROWTYPE;
    v_brief       VARCHAR2(30);
    v_Param_Found NUMBER;
  BEGIN
    v_brief := UPPER(p_brief);
    BEGIN
      SELECT * INTO v_app_param FROM APP_PARAM ap WHERE ap.brief = v_brief;
      v_Param_Found := 1;
    EXCEPTION
      WHEN OTHERS THEN
        v_Param_Found := 0;
    END;
  
    IF v_Param_Found = 1
    THEN
      --Историчное значение по конкретному пользователю
      IF p_date IS NOT NULL
         AND p_user IS NOT NULL
      THEN
        BEGIN
          SELECT 0
                ,apv.app_param_id
                ,apv.app_param_val_id
                ,apv.val_c
                ,apv.val_n
                ,apv.val_d
                ,apv.val_ure_id
                ,apv.val_uro_id
            INTO v_t_app_param.is_null
                ,v_t_app_param.APP_PARAM_ID
                ,v_t_app_param.APP_PARAM_VAL_ID
                ,v_t_app_param.val_c
                ,v_t_app_param.val_n
                ,v_t_app_param.val_d
                ,v_t_app_param.val_ure_id
                ,v_t_app_param.val_uro_id
            FROM APP_PARAM_VAL apv
           WHERE apv.app_param_id = v_app_param.app_param_id
             AND apv.user_name = p_user
             AND apv.start_date = (SELECT MAX(apvs.start_date)
                                     FROM APP_PARAM_VAL apvs
                                    WHERE apvs.app_param_id = v_App_Param.App_Param_Id
                                      AND apvs.user_name = p_user
                                      AND apvs.start_date <= p_date);
        EXCEPTION
          WHEN OTHERS THEN
            --Записать значения по-умолчанию
            v_t_app_param.is_null          := 0;
            v_t_app_param.app_param_id     := v_app_param.app_param_id;
            v_t_app_param.app_param_val_id := NULL;
            v_t_app_param.val_c            := v_app_param.def_value_c;
            v_t_app_param.val_n            := v_app_param.def_value_n;
            v_t_app_param.val_d            := v_app_param.def_value_d;
            v_t_app_param.val_ure_id       := v_app_param.def_value_ure_id;
            v_t_app_param.val_uro_id       := v_app_param.def_value_uro_id;
        END;
        --Историчное общее значение
      ELSIF p_date IS NOT NULL
            AND p_user IS NULL
      THEN
        BEGIN
          SELECT 0
                ,apv.app_param_id
                ,apv.app_param_val_id
                ,apv.val_c
                ,apv.val_n
                ,apv.val_d
                ,apv.val_ure_id
                ,apv.val_uro_id
            INTO v_t_app_param.is_null
                ,v_t_app_param.APP_PARAM_ID
                ,v_t_app_param.APP_PARAM_VAL_ID
                ,v_t_app_param.val_c
                ,v_t_app_param.val_n
                ,v_t_app_param.val_d
                ,v_t_app_param.val_ure_id
                ,v_t_app_param.val_uro_id
            FROM APP_PARAM_VAL apv
           WHERE apv.app_param_id = v_app_param.app_param_id
             AND apv.user_name IS NULL
             AND apv.start_date = (SELECT MAX(apvs.start_date)
                                     FROM APP_PARAM_VAL apvs
                                    WHERE apvs.app_param_id = v_App_Param.App_Param_Id
                                      AND apvs.user_name IS NULL
                                      AND apvs.start_date <= p_date);
        EXCEPTION
          WHEN OTHERS THEN
            --Записать значения по-умолчанию
            v_t_app_param.is_null          := 0;
            v_t_app_param.app_param_id     := v_app_param.app_param_id;
            v_t_app_param.app_param_val_id := NULL;
            v_t_app_param.val_c            := v_app_param.def_value_c;
            v_t_app_param.val_n            := v_app_param.def_value_n;
            v_t_app_param.val_d            := v_app_param.def_value_d;
            v_t_app_param.val_ure_id       := v_app_param.def_value_ure_id;
            v_t_app_param.val_uro_id       := v_app_param.def_value_uro_id;
        END;
        --Неисторичное значение по конкретному пользователю
      ELSIF p_date IS NULL
            AND p_user IS NOT NULL
      THEN
        BEGIN
          SELECT 0
                ,apv.app_param_id
                ,apv.app_param_val_id
                ,apv.val_c
                ,apv.val_n
                ,apv.val_d
                ,apv.val_ure_id
                ,apv.val_uro_id
            INTO v_t_app_param.is_null
                ,v_t_app_param.APP_PARAM_ID
                ,v_t_app_param.APP_PARAM_VAL_ID
                ,v_t_app_param.val_c
                ,v_t_app_param.val_n
                ,v_t_app_param.val_d
                ,v_t_app_param.val_ure_id
                ,v_t_app_param.val_uro_id
            FROM APP_PARAM_VAL apv
           WHERE apv.app_param_id = v_app_param.app_param_id
             AND apv.user_name = p_user
             AND apv.start_date IS NULL;
        EXCEPTION
          WHEN OTHERS THEN
            --Записать значения по-умолчанию
            v_t_app_param.is_null          := 0;
            v_t_app_param.app_param_id     := v_app_param.app_param_id;
            v_t_app_param.app_param_val_id := NULL;
            v_t_app_param.val_c            := v_app_param.def_value_c;
            v_t_app_param.val_n            := v_app_param.def_value_n;
            v_t_app_param.val_d            := v_app_param.def_value_d;
            v_t_app_param.val_ure_id       := v_app_param.def_value_ure_id;
            v_t_app_param.val_uro_id       := v_app_param.def_value_uro_id;
        END;
        --Неисторичное общее значение
      ELSIF p_date IS NULL
            AND p_user IS NULL
      THEN
        --Записать значения по-умолчанию
        v_t_app_param.is_null          := 0;
        v_t_app_param.app_param_id     := v_app_param.app_param_id;
        v_t_app_param.app_param_val_id := NULL;
        v_t_app_param.val_c            := v_app_param.def_value_c;
        v_t_app_param.val_n            := v_app_param.def_value_n;
        v_t_app_param.val_d            := v_app_param.def_value_d;
        v_t_app_param.val_ure_id       := v_app_param.def_value_ure_id;
        v_t_app_param.val_uro_id       := v_app_param.def_value_uro_id;
      END IF;
    ELSE
      -- if v_Param_Found = 1
      v_t_app_param.is_null := 1;
    END IF; -- if v_Param_Found = 1
  
    RETURN v_t_app_param;
  END;

  --Purpose: Получить значение параметра типа varchar2
  FUNCTION get_app_param_c
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_t_app_param T_APP_PARAM;
    v_result      VARCHAR2(150);
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.is_null = 1
    THEN
      v_result := NULL;
    ELSE
      v_result := v_t_app_param.VAL_C;
    END IF;
    RETURN v_result;
  END;

  --Purpose: Получить значение параметра типа number
  FUNCTION get_app_param_n
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_t_app_param T_APP_PARAM;
    v_result      NUMBER;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.is_null = 1
    THEN
      v_result := NULL;
    ELSE
      v_result := v_t_app_param.VAL_N;
    END IF;
    RETURN v_result;
  END;

  --Purpose: Получить значение параметра типа date
  FUNCTION get_app_param_d
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN DATE IS
    v_t_app_param T_APP_PARAM;
    v_result      DATE;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.is_null = 1
    THEN
      v_result := NULL;
    ELSE
      v_result := v_t_app_param.VAL_D;
    END IF;
    RETURN v_result;
  END;

  --Purpose: Получить значение параметра типа uref
  FUNCTION get_app_param_u
  (
    p_brief VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_t_app_param T_APP_PARAM;
    v_result      NUMBER;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.is_null = 1
    THEN
      v_result := NULL;
    ELSE
      v_result := v_t_app_param.VAL_URO_ID;
    END IF;
    RETURN v_result;
  END;

  -- Purpose : Сохранить значение настройки приложения в виде строки
  PROCEDURE set_app_param_c
  (
    p_brief VARCHAR2
   ,p_val   VARCHAR2
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_t_app_param t_app_param;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.IS_NULL = 0
    THEN
      IF p_date IS NULL
         AND p_user IS NULL
      THEN
        UPDATE APP_PARAM p
           SET p.def_value_c = p_val
         WHERE p.app_param_id = v_t_app_param.APP_PARAM_ID;
      ELSE
        IF v_t_app_param.APP_PARAM_VAL_ID IS NULL
        THEN
          INSERT INTO APP_PARAM_VAL apv
            (apv.app_param_val_id, apv.app_param_id, apv.start_date, apv.user_name, apv.val_c)
          VALUES
            (sq_app_param_val.NEXTVAL, v_t_app_param.app_param_id, p_date, p_user, p_val);
        ELSE
          UPDATE APP_PARAM_VAL apv
             SET apv.val_c = p_val
           WHERE apv.app_param_val_id = v_t_app_param.APP_PARAM_VAL_ID;
        END IF;
      END IF;
      COMMIT;
    ELSE
      RAISE_APPLICATION_ERROR(-20110
                             ,'Параметр ' || p_brief || ' в системе не зарегистрирован!');
    END IF;
  END;

  -- Purpose : Сохранить значение настройки приложения в виде числа
  PROCEDURE set_app_param_n
  (
    p_brief VARCHAR2
   ,p_val   NUMBER
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_t_app_param t_app_param;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.IS_NULL = 0
    THEN
      IF p_date IS NULL
         AND p_user IS NULL
      THEN
        UPDATE APP_PARAM p
           SET p.def_value_n = p_val
         WHERE p.app_param_id = v_t_app_param.APP_PARAM_ID;
      ELSE
        IF v_t_app_param.APP_PARAM_VAL_ID IS NULL
        THEN
          INSERT INTO APP_PARAM_VAL apv
            (apv.app_param_val_id, apv.app_param_id, apv.start_date, apv.user_name, apv.val_n)
          VALUES
            (sq_app_param_val.NEXTVAL, v_t_app_param.app_param_id, p_date, p_user, p_val);
        ELSE
          UPDATE APP_PARAM_VAL apv
             SET apv.val_n = p_val
           WHERE apv.app_param_val_id = v_t_app_param.APP_PARAM_VAL_ID;
        END IF;
      END IF;
      COMMIT;
    ELSE
      RAISE_APPLICATION_ERROR(-20110
                             ,'Параметр ' || p_brief || ' в системе не зарегистрирован!');
    END IF;
  END;

  -- Purpose : Сохранить значение настройки приложения в виде даты
  PROCEDURE set_app_param_d
  (
    p_brief VARCHAR2
   ,p_val   DATE
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_t_app_param t_app_param;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.IS_NULL = 0
    THEN
      IF p_date IS NULL
         AND p_user IS NULL
      THEN
        UPDATE APP_PARAM p
           SET p.def_value_d = p_val
         WHERE p.app_param_id = v_t_app_param.APP_PARAM_ID;
      ELSE
        IF v_t_app_param.APP_PARAM_VAL_ID IS NULL
        THEN
          INSERT INTO APP_PARAM_VAL apv
            (apv.app_param_val_id, apv.app_param_id, apv.start_date, apv.user_name, apv.val_d)
          VALUES
            (sq_app_param_val.NEXTVAL, v_t_app_param.app_param_id, p_date, p_user, p_val);
        ELSE
          UPDATE APP_PARAM_VAL apv
             SET apv.val_d = p_val
           WHERE apv.app_param_val_id = v_t_app_param.APP_PARAM_VAL_ID;
        END IF;
      END IF;
      COMMIT;
    ELSE
      RAISE_APPLICATION_ERROR(-20110
                             ,'Параметр ' || p_brief || ' в системе не зарегистрирован!');
    END IF;
  END;

  -- Purpose : Сохранить значение настройки приложения в виде универсальной ссылки
  PROCEDURE set_app_param_u
  (
    p_brief VARCHAR2
   ,p_val   NUMBER
   ,p_date  DATE DEFAULT NULL
   ,p_user  VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_t_app_param t_app_param;
  BEGIN
    v_t_app_param := get_app_param(p_brief, p_date, p_user);
    IF v_t_app_param.IS_NULL = 0
    THEN
      IF v_t_app_param.APP_PARAM_VAL_ID IS NULL
      THEN
        INSERT INTO APP_PARAM_VAL apv
          (apv.app_param_val_id
          ,apv.app_param_id
          ,apv.start_date
          ,apv.user_name
          ,apv.val_ure_id
          ,apv.val_uro_id)
        VALUES
          (sq_app_param_val.NEXTVAL
          ,v_t_app_param.app_param_id
          ,p_date
          ,p_user
          ,v_t_app_param.val_ure_id
          ,p_val);
      ELSE
        UPDATE APP_PARAM_VAL apv
           SET apv.val_uro_id = p_val
         WHERE apv.app_param_val_id = v_t_app_param.APP_PARAM_VAL_ID;
      END IF;
      COMMIT;
    END IF;
  END;

  PROCEDURE set_dates
  (
    p_work  IN DATE DEFAULT SYSDATE
   ,p_start IN DATE DEFAULT SYSDATE
   ,p_end   IN DATE DEFAULT SYSDATE
   ,p_mode  NUMBER DEFAULT 3
  ) IS
  BEGIN
    IF p_mode = 3
    THEN
      date_work  := TRUNC(p_work, 'DD');
      date_start := TRUNC(p_start, 'DD');
      date_end   := TRUNC(p_end, 'DD');
    ELSIF p_mode = 1
    THEN
      date_work  := TRUNC(p_work, 'DD');
      date_start := p_start;
      date_end   := p_end;
    ELSIF p_mode = 0
    THEN
      date_work  := p_work;
      date_start := p_start;
      date_end   := p_end;
    ELSIF p_mode = 2
    THEN
      date_work  := p_work;
      date_start := TRUNC(p_start, 'DD');
      date_end   := TRUNC(p_end, 'DD');
    ELSE
      RAISE_APPLICATION_ERROR(-20000
                             ,'Неверное значение параметра p_mode процедуры set_dates.');
    END IF;
  END;

  PROCEDURE app_param_dates
  (
    p_work  OUT DATE
   ,p_start OUT DATE
   ,p_end   OUT DATE
  ) IS
  BEGIN
    p_work := get_app_param_d('ДатаРаботы');
    IF p_work IS NULL
    THEN
      p_work := SYSDATE;
    END IF;
    p_start := get_app_param_d('НачалоПериодаРаботы');
    IF p_start IS NULL
    THEN
      p_start := SYSDATE;
    END IF;
    p_end := get_app_param_d('ОкончаниеПериодаРаботы');
    IF p_end IS NULL
    THEN
      p_end := SYSDATE;
    END IF;
  END;

  PROCEDURE set_app_param_dates
  (
    p_work  IN DATE
   ,p_start IN DATE
   ,p_end   IN DATE
  ) IS
  BEGIN
    set_app_param_d('ДатаРаботы', p_work);
    set_app_param_d('НачалоПериодаРаботы', p_start);
    set_app_param_d('ОкончаниеПериодаРаботы', p_end);
  END;

END pkg_app_param;
/
