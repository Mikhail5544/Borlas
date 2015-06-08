CREATE OR REPLACE PACKAGE PKG_TRANS IS

  -- Author  : RKUDRYAVCEV
  -- Created : 08.08.2007 12:21:19
  -- Purpose : ����� ��� �������� ���������� �������� � Navision

  -----------------------------------------------------------------
  --
  -- ������� �������������� �������� ��������
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
  -- ������� ��������� mview ������� �������� ��������
  --
  -----------------------------------------------------------------
  FUNCTION unloading_trans(p_date VARCHAR2 DEFAULT SYSDATE -- ���� (�����) ������������ ��������� �������
                           ) RETURN VARCHAR2;

END PKG_TRANS;
/
CREATE OR REPLACE PACKAGE BODY PKG_TRANS IS
  -----------------------------------------------------------------
  --
  -- ������� �������������� �������� ��������
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
  
    -- ���� �� ��������� 
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
      -- ��������
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
  -- ������� ��������� mview ������� �������� ��������
  --
  -----------------------------------------------------------------
  FUNCTION unloading_trans(p_date VARCHAR2 DEFAULT SYSDATE -- ���� (�����) ������������ ��������� �������
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
    -- !!!! ��� ������ ���� ��������, �� ��� �������� ������ ������ !!!!
    -- !!!!                                                        !!!!
    -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    --
    -- ��������� �����
    -- �������� ������ ��� ������
    res_fun := pkg_gate.CreatePackage(var_number_package, 200);
  
    -- ���� �������� ������ ������� ������ - ������
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN '��������� ������ �������� ������ ������';
    END IF;
  
    -- 1) ��������� ���������
    -- 1.1 �������� ��� �� ��������� � ��� ������������ � ������� ������������
  
    FOR r IN (SELECT AT.*
                FROM ins.analytic_type AT
               WHERE NOT EXISTS
               (SELECT * FROM GATE_ANALYTICS_TYPE GAT WHERE AT.BRIEF = GAT.ANALYTIC_TYPE_BI))
    LOOP
      var_res := r.NAME || ' (BRIEF:' || r.brief || '); ' || var_res;
    END LOOP;
  
    IF var_res IS NOT NULL
    THEN
    
      var_res := '��� ������������ ��� ���� ���������: ' || var_res;
    
      RETURN var_res;
    
    END IF;
  
    -- ��������� ���������, �������� ��������.
  
    -- �������� ��� �� � ��� ���� � ������� ������������, ���� ���, �� ��� �������� ��� �������� �����
    -- �������������� ������ �� ����
  
    FOR r IN (SELECT TT.*
                FROM ins.trans_templ TT
               WHERE NOT EXISTS
               (SELECT * FROM GATE_TRANS_TEMPL GTT WHERE TT.BRIEF = GTT.TRANS_TEMPL_BI))
    LOOP
      var_res := r.NAME || ' (BRIEF:' || r.brief || '); ' || var_res;
    END LOOP;
  
    IF var_res IS NOT NULL
    THEN
    
      var_res := '��� ������������ ��� ���� ���������� ��������: ' || var_res;
    
      RETURN var_res;
    
    END IF;
    var_res := '�������� ��� ����������';
    -- �������� ��� �������� �� ��������� �����
    -- ��������� �� ����� ��� ��������
    FOR r IN (SELECT TT.TRANS_TEMPL_ID
                    ,GTT.*
                    ,TT.NAME
                FROM INSI.GATE_TRANS_TEMPL GTT
                    ,INS.TRANS_TEMPL       TT
               WHERE GTT.IS_EXPORT = '�'
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
      -- �������� ���������. ���������� �� �� ��� ����� 5 ��������
      -- �����/������
      var_res := '�������� �������� �� ��� �����������';
      FOR CT_DT IN (SELECT 'KR' AS DB_OR_KR
                          ,'CT' AS DB_CT
                      FROM dual
                    UNION ALL
                    SELECT 'DB' AS DB_OR_KR
                          ,'DT' AS DB_CT
                      FROM dual)
      LOOP
        -- 1..5 ���������
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
            and GAT.IS_EXPORT = ''�''
            AND TRUNC(T.TRANS_DATE,
                  ''MM'') = to_date(''' || to_char(var_date, 'DD.MM.YYYY') ||
                     ''', ''DD.MM.YYYY'')       
            AND T.TRANS_TEMPL_ID = ' || r.trans_templ_id;
        
          EXECUTE IMMEDIATE var_sql;
        
        END LOOP;
      END LOOP;
    END LOOP;
  
    -- �������� ��� ����
    var_res := '����������� ������';
    -- ������� ���������� �� ��� ������ �� ����������� ������ (��������� ������������)
    DELETE FROM gate_analytic_value_log v WHERE v.fin_month = var_date;
  
    DELETE FROM gate_trans_log t WHERE t.fin_month = var_date;
  
    DELETE FROM GATE_TRANS_ANALITYC_log t WHERE t.fin_month = var_date;
  
    -- ����������
  
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
  
    -- �������� ������ �� ���� ����������. ������� ���������� ���������
    -- �������� ������ ��������� ��������� � ����� INS. 
    -- �.�. � �������� �� ������� ����� � ������� ��������� �������.
  
    var_res := INS.Pkg_Gate_Trans_Utils.EXPORT_ANALYTICS_TO_NAV(var_number_package);
  
    IF var_res IS NOT NULL
    THEN
    
      RETURN var_res;
    
    ELSE
    
      var_res := NULL;
    
    END IF;
  
    -- ������ ��������� ����� ������� �������� �������� ��������, ������� �� ���� � ����������
  
    DELETE FROM gate_analytic_value GAV
     WHERE NOT EXISTS (SELECT *
              FROM GATE_TRANS_ANALITYC_LOG GAT
             WHERE GAT.ANALYTIC_TYPE_NAV = GAV.ANALYTIC_TYPE_NAV
               AND GAT.ANALYTIC_VALUE_ID = GAV.ANALYTIC_VALUE_ID);
  
    -- ���������� �������� ��������
  
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
  
    -- �������������� ����� ��� ���������� ���������
  
    res_fun := pkg_gate.InsertMessage_Gate(200, var_number_package);
    -- ���� ����������� ������� ������ - ������
    IF (res_fun = Utils_tmp.c_false)
    THEN
      RETURN '��������� ������ ����������� ������ ������';
    END IF;
    RETURN NULL;
  
  EXCEPTION
    WHEN OTHERS THEN
      --rollback;
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_TRANS.unloading_trans:' || var_sql
                                              ,pkg_gate.event_error);
    
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_TRANS.unloading_trans:' || SQLERRM
                                              ,pkg_gate.event_error);
      RETURN '������ �������� ��� ��������:' || var_res || ' ������ Oracle:' || SQLERRM(SQLCODE);
    
  END unloading_trans;

END PKG_TRANS;
/
