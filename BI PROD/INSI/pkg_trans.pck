CREATE OR REPLACE PACKAGE PKG_TRANS IS

  -- Author  : RKUDRYAVCEV
  -- Created : 08.08.2007 12:21:19
  -- Purpose : Пакет для экспорта Финансовых операция й Navision

  -----------------------------------------------------------------
  --
  -- Функция переопределяет значения аналитик
  --
  -----------------------------------------------------------------
  FUNCTION get_calc_analytic
  (
    p_analytic_type_bi    gate_analytics_type.analytic_type_bi%TYPE
   ,p_analytic_value_bi   gate_analytics_type.analytic_type_nav%TYPE
   ,p_analytic_value_name gate_analytic_value.analytic_value_name%TYPE DEFAULT NULL
   ,p_type                VARCHAR2 DEFAULT 'CALC_CODE'
  ) RETURN VARCHAR2;
  -----------------------------------------------------------------
  --
  -- Функция обновляет mview перечня значений Аналитик
  --
  -----------------------------------------------------------------
  FUNCTION unloading_trans(p_date VARCHAR2 DEFAULT SYSDATE -- дата (месяц) выгружаемого отчетного периода
                           ) RETURN VARCHAR2;

END PKG_TRANS;
/
CREATE OR REPLACE PACKAGE BODY PKG_TRANS IS
  -----------------------------------------------------------------
  --
  -- Функция переопределяет значения аналитик
  --
  -----------------------------------------------------------------
  FUNCTION get_calc_analytic
  (
    p_analytic_type_bi    gate_analytics_type.analytic_type_bi%TYPE
   ,p_analytic_value_bi   gate_analytics_type.analytic_type_nav%TYPE
   ,p_analytic_value_name gate_analytic_value.analytic_value_name%TYPE DEFAULT NULL
   ,p_type                VARCHAR2 DEFAULT 'CALC_CODE'
  ) RETURN VARCHAR2 IS
    var_return VARCHAR2(2000);
    i          INTEGER;
    c          INTEGER;
    var_calc   VARCHAR2(2000);
  
  BEGIN
  
    SELECT decode(p_type, 'CALC_CODE', at.calc_code, at.calc_name)
      INTO var_return
      FROM gate_analytics_type at
     WHERE at.analytic_type_bi = p_analytic_type_bi;
  
    -- если не определен 
    IF var_return IS NULL
       AND p_type = 'CALC_CODE'
    THEN
    
      RETURN p_analytic_value_bi;
    ELSIF var_return IS NULL
          AND p_type = 'CALC_NAME'
    THEN
      RETURN p_analytic_value_name;
    ELSE
    
      --execute immediate var_return USING IN p_analytic_value_bi, OUT var_return;
      -- вычислим
      c := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(c, var_return, dbms_sql.native);
      DBMS_SQL.BIND_VARIABLE(c, 'analytic_value_bi', p_analytic_value_bi);
      DBMS_SQL.BIND_VARIABLE(c, 'analytic_value_nav', var_return);
      i := DBMS_SQL.EXECUTE(c);
      dbms_sql.variable_value(c, 'analytic_value_nav', var_return);
      DBMS_SQL.CLOSE_CURSOR(c);
    END IF;
  
    RETURN var_return;
  
  END get_calc_analytic;
  -----------------------------------------------------------------
  --
  -- Функция обновляет mview перечня значений Аналитик
  --
  -----------------------------------------------------------------
  FUNCTION unloading_trans(p_date VARCHAR2 DEFAULT SYSDATE -- дата (месяц) выгружаемого отчетного периода
                           ) RETURN VARCHAR2 IS
    res_fun            NUMBER;
    var_res            VARCHAR2(32000);
    var_sql            VARCHAR2(32000);
    var_number_package NUMBER;
    var_date           DATE := TRUNC(to_date(p_date, 'DD/MM/YY'), 'MM');
  BEGIN
    --savepoint;
    -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    -- !!!!                                                        !!!!
    -- !!!! ТУТ ДОЛЖНА БЫТЬ ПРОВЕРКА, то что Отчетный период закрыт !!!!
    -- !!!!                                                        !!!!
    -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    --
    -- определим пакет
    -- Создание пакета для данных
    res_fun := pkg_gate.CreatePackage(var_number_package, 200);
  
    -- если создание пакета вызвало ошибку - выйдем
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN 'Системная ошибка создания пакета данных';
    END IF;
  
    -- 1) выгружаем аналитику
    -- 1.1 Проверим все ли аналитику у нас присутствуют в таблице соответствия
  
    FOR r IN (SELECT AT.*
                FROM ins.analytic_type AT
               WHERE NOT EXISTS
               (SELECT * FROM GATE_ANALYTICS_TYPE GAT WHERE AT.BRIEF = GAT.ANALYTIC_TYPE_BI))
    LOOP
      var_res := r.NAME || ' (BRIEF:' || r.brief || '); ' || var_res;
    END LOOP;
  
    IF var_res IS NOT NULL
    THEN
    
      var_res := 'Нет соответствий для типа аналитики: ' || var_res;
    
      RETURN var_res;
    
    END IF;
  
    -- Аналитику загрузили, остались проводки.
  
    -- проверим все ли у нас есть в таблице соответствия, если нет, то это означает что добавили новую
    -- соответственно скажем об этом
  
    FOR r IN (SELECT TT.*
                FROM ins.trans_templ TT
               WHERE NOT EXISTS
               (SELECT * FROM GATE_TRANS_TEMPL GTT WHERE TT.BRIEF = GTT.TRANS_TEMPL_BI))
    LOOP
      var_res := r.NAME || ' (BRIEF:' || r.brief || '); ' || var_res;
    END LOOP;
  
    IF var_res IS NOT NULL
    THEN
    
      var_res := 'Нет соответствий для типа финансовых операций: ' || var_res;
    
      RETURN var_res;
    
    END IF;
    var_res := 'Выгрузка фин транзакций';
    -- выгрузим Фин операции за требуемый месяц
    -- пройдемся по Типам фин операций
    FOR r IN (SELECT TT.TRANS_TEMPL_ID
                    ,GTT.*
                    ,TT.NAME
                FROM INSI.GATE_TRANS_TEMPL GTT
                    ,INS.TRANS_TEMPL       TT
               WHERE GTT.IS_EXPORT = 'Д'
                 AND GTT.TRANS_TEMPL_BI = TT.BRIEF)
    LOOP
    
      var_sql := 'insert into GATE_TRANS (CODE,
                                        ROW_STATUS,
                                        GATE_PACKAGE_ID,
                                        TRANS_DATE,	
                                        AMOUNT_CUR,
                                        DT_EXT_ACCOUNT_ID,
                                        CT_EXT_ACCOUNT_ID,
                                        CURRENCY,
                                        AMOUNT_RUR,
                                        ACC_RATE,
                                        REG_DATE,
                                        TRANS_QUANTITY,
                                        NOTE,
                                        ACCOUNTING_PERIOD,
                                        TRANS_TEMPL_NAME
                                        )
                                SELECT T.trans_id as CODE,' ||
                 INSI.PKG_GATE.row_update || ' as ROW_STATUS, ' || var_number_package ||
                 ' as GATE_PACKAGE_ID,
                 T.TRANS_DATE as TRANS_DATE,
                 to_char(T.ACC_AMOUNT, ''9999999999999999.99'') as AMOUNT_CUR,
                 (' || r.account_db_nav || ') as DT_EXT_ACCOUNT_ID,
                 (' || r.account_kr_nav || ') as CT_EXT_ACCOUNT_ID,
                 F.BRIEF as CURRENCY,
                 to_char(T.TRANS_AMOUNT, ''9999999999999999.99'') as AMOUNT_RUR,
                 to_char(T.ACC_RATE, ''9999999999999999.9999'') as ACC_RATE,
                 T.REG_DATE as REG_DATE,
                 T.TRANS_QUANTITY as TRANS_QUANTITY,
                 T.NOTE as NOTE, 
                 to_date(''' || to_char(var_date, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY''), 
                 ''' || r.NAME || ''' as TRANS_TEMPL_NAME
            FROM INS.TRANS             T,
                 INS.FUND       F
           WHERE TRUNC(T.TRANS_DATE,
                  ''MM'') = to_date(''' || to_char(var_date, 'DD.MM.YYYY') ||
                 ''', ''DD.MM.YYYY'')       
             AND F.FUND_ID = T.ACC_FUND_ID
             AND T.TRANS_TEMPL_ID = ' || r.trans_templ_id;
    
      EXECUTE IMMEDIATE var_sql;
      -- выгрузим аналитику. Зашиваемся на то что всего 5 аналитик
      -- Дебет/кредит
      var_res := 'Выгрузка аналитик по фин транзакциям';
      FOR CT_DT IN (SELECT 'KR' AS DB_OR_KR
                          ,'CT' AS DB_CT
                      FROM dual
                    UNION ALL
                    SELECT 'DB' AS DB_OR_KR
                          ,'DT' AS DB_CT
                      FROM dual)
      LOOP
        -- 1..5 аналитика
        FOR AN IN 1 .. 5
        LOOP
        
          var_sql := 'insert into GATE_TRANS_ANALITYC 
                                       (CODE,
                                        ROW_STATUS,
                                        GATE_PACKAGE_ID,
                                        DB_OR_KR,
                                        ANALYTIC_TYPE_NAV,
                                        ANALYTIC_VALUE_ID
                                        )
                                 SELECT T.trans_id as CODE,' ||
                     INSI.PKG_GATE.row_update || ' as ROW_STATUS, ' || var_number_package ||
                     ' as GATE_PACKAGE_ID,
                                        ''' || CT_DT.DB_OR_KR ||
                     ''' as DB_OR_KR,
                                        GAT.ANALYTIC_TYPE_NAV ANALYTIC_TYPE_NAV,
                                        pkg_trans.get_calc_analytic(AT.brief, T.A' || AN || '_' ||
                     CT_DT.DB_CT || '_URO_ID, null, ''CALC_CODE'')  ANALYTIC_VALUE_ID
                                   from INS.ACCOUNT A,
                                        INS.TRANS T,
                                        INSI.GATE_ANALYTICS_TYPE GAT,
                                        INS.ANALYTIC_TYPE AT
          where A.ACCOUNT_ID = T.' || CT_DT.DB_CT ||
                     '_ACCOUNT_ID
            and AT.ANALYTIC_TYPE_ID = A.A' || AN || '_ANALYTIC_TYPE_ID
            and GAT.ANALYTIC_TYPE_BI = AT.BRIEF
            and T.A' || AN || '_' || CT_DT.DB_CT ||
                     '_URO_ID is not null
            and GAT.IS_EXPORT = ''Д''
            AND TRUNC(T.TRANS_DATE,
                  ''MM'') = to_date(''' || to_char(var_date, 'DD.MM.YYYY') ||
                     ''', ''DD.MM.YYYY'')       
            AND T.TRANS_TEMPL_ID = ' || r.trans_templ_id;
        
          EXECUTE IMMEDIATE var_sql;
        
        END LOOP;
      END LOOP;
    END LOOP;
  
    -- логируем что есть
    var_res := 'Логирование таблиц';
    -- удаляем информацию из ЛОГ таблиц за выгружаемый период (исключаем дублирование)
    DELETE FROM gate_analytic_value_log v WHERE v.fin_month = var_date;
  
    DELETE FROM gate_trans_log t WHERE t.fin_month = var_date;
  
    DELETE FROM GATE_TRANS_ANALITYC_log t WHERE t.fin_month = var_date;
  
    -- залогируем
  
    INSERT INTO gate_trans_LOG
      (trans_date
      ,amount_cur
      ,dt_ext_account_id
      ,ct_ext_account_id
      ,currency
      ,amount_rur
      ,acc_rate
      ,reg_date
      ,trans_quantity
      ,note
      ,code
      ,row_status
      ,gate_package_id
      ,accounting_period
      ,trans_templ_name
      ,fin_Month)
      SELECT trans_date
            ,amount_cur
            ,dt_ext_account_id
            ,ct_ext_account_id
            ,currency
            ,amount_rur
            ,acc_rate
            ,reg_date
            ,trans_quantity
            ,note
            ,code
            ,row_status
            ,gate_package_id
            ,accounting_period
            ,trans_templ_name
            ,var_date
        FROM gate_trans;
  
    INSERT INTO GATE_TRANS_ANALITYC_LOG
      (CODE, DB_OR_KR, ANALYTIC_TYPE_NAV, ANALYTIC_VALUE_ID, ROW_STATUS, GATE_PACKAGE_ID, fin_Month)
      SELECT CODE
            ,DB_OR_KR
            ,ANALYTIC_TYPE_NAV
            ,ANALYTIC_VALUE_ID
            ,ROW_STATUS
            ,GATE_PACKAGE_ID
            ,var_date
        FROM GATE_TRANS_ANALITYC;
  
    -- построим список по всем Аналитикам. которые необходимо выгружать
    -- пришлось данную обработку перенести в схему INS. 
    -- т.к. в селектах не указаны схемы в которых находятся объекты.
  
    var_res := INS.Pkg_Gate_Trans_Utils.EXPORT_ANALYTICS_TO_NAV(var_number_package);
  
    IF var_res IS NOT NULL
    THEN
    
      RETURN var_res;
    
    ELSE
    
      var_res := NULL;
    
    END IF;
  
    -- теперь необходмо хитро удалить Перечень значений аналитик, которых не было в Транзакции
  
    DELETE FROM gate_analytic_value GAV
     WHERE NOT EXISTS (SELECT *
              FROM GATE_TRANS_ANALITYC_LOG GAT
             WHERE GAT.ANALYTIC_TYPE_NAV = GAV.ANALYTIC_TYPE_NAV
               AND GAT.ANALYTIC_VALUE_ID = GAV.ANALYTIC_VALUE_ID);
  
    -- залогируем Перечень аналитик
  
    INSERT INTO gate_analytic_value_LOG
      (Analytic_Type_Nav
      ,Analytic_Value_Id
      ,Analytic_Value_Name
      ,Code
      ,Row_Status
      ,Gate_Package_Id
      ,fin_Month)
      SELECT Analytic_Type_Nav
            ,Analytic_Value_Id
            ,Analytic_Value_Name
            ,Code
            ,Row_Status
            ,Gate_Package_Id
            ,var_date
        FROM gate_analytic_value;
  
    -- зарегистрируем пакет для дальнейшей обработки
  
    res_fun := pkg_gate.InsertMessage_Gate(200, var_number_package);
    -- если регистрация вызвала ошибку - выйдем
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN 'Системная ошибка регистрации пакета данных';
    END IF;
    RETURN NULL;
  
  EXCEPTION
    WHEN OTHERS THEN
      --rollback;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_TRANS.unloading_trans:' || var_sql
                                              ,pkg_gate.event_error);
    
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_TRANS.unloading_trans:' || SQLERRM
                                              ,pkg_gate.event_error);
      RETURN 'Ошибка выгрузки фин операций:' || var_res || ' ошибка Oracle:' || SQLERRM(SQLCODE);
    
  END unloading_trans;

END PKG_TRANS;
/
