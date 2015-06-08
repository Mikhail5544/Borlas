CREATE OR REPLACE PACKAGE acc IS

  cb_rate_type_id NUMBER; -- ИД типа курса ЦБ

  TYPE t_Turn_Rest IS RECORD(
     Rest_In_Fund            NUMBER
    ,Rest_In_Base_Fund       NUMBER
    ,Rest_In_Qty             NUMBER
    ,Rest_In_Fund_Type       VARCHAR2(1)
    ,Rest_In_Base_Fund_Type  VARCHAR2(1)
    ,Rest_In_Qty_Type        VARCHAR2(1)
    ,Turn_Dt_Fund            NUMBER
    ,Turn_Dt_Base_Fund       NUMBER
    ,Turn_Dt_Qty             NUMBER
    ,Turn_Ct_Fund            NUMBER
    ,Turn_Ct_Base_Fund       NUMBER
    ,Turn_Ct_Qty             NUMBER
    ,Rest_Out_Fund           NUMBER
    ,Rest_Out_Base_Fund      NUMBER
    ,Rest_Out_Qty            NUMBER
    ,Rest_Out_Fund_Type      VARCHAR2(1)
    ,Rest_Out_Base_Fund_Type VARCHAR2(1)
    ,Rest_Out_Qty_Type       VARCHAR2(1));

  TYPE t_Rest IS RECORD(
     Rest_Amount_Fund      NUMBER
    ,Rest_Amount_Base_Fund NUMBER
    ,Rest_Amount_Qty       NUMBER
    ,Rest_Fund_Type        VARCHAR2(1)
    ,Rest_Base_Fund_Type   VARCHAR2(1)
    ,Rest_Qty_Type         VARCHAR2(1));

  TYPE t_Uref_ID IS RECORD(
     Entity_ID NUMBER(6)
    ,Object_ID NUMBER);

  -- ИД типа курса ЦБ
  FUNCTION get_cb_rate_type_id RETURN NUMBER;

  --Функция для определения счета по М.О.С.
  FUNCTION Get_Acc_By_Acc_Def_Rule
  (
    p_ADR_ID    NUMBER
   ,p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  --Функция для определения счета по типу счета
  FUNCTION Get_Acc_By_Acc_Type
  (
    p_Acc_Type_Templ_ID    NUMBER
   ,p_Acc_Chart_Type_ID    NUMBER
   ,p_Settlement_Scheme_ID NUMBER
   ,p_Doc_ID               NUMBER
  ) RETURN NUMBER;

  --Функция для определения приоритета счета по типу счета
  FUNCTION Get_Acc_Priority_By_Acc_Type
  (
    p_Acc_Type_Templ_ID    NUMBER
   ,p_Acc_Chart_Type_ID    NUMBER
   ,p_Settlement_Scheme_ID NUMBER
   ,p_Doc_ID               NUMBER
  ) RETURN NUMBER;

  --Формирование примечания проводки
  FUNCTION Get_Trans_Note
  (
    p_Trans_Templ_ID NUMBER
   ,p_Oper_ID        NUMBER
  ) RETURN VARCHAR2;

  --Функция для М.О.С. "Счет в валюте"
  FUNCTION Acc_By_Fund
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  --Функция для М.О.С. "Счет дебет во внутреннем документе"
  FUNCTION Acc_DT_MO
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  --Функция для М.О.С. "Счет дебет (приведенный) во внутреннем документе"
  FUNCTION Acc_DT_MO_Rev
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  --Функция для М.О.С. "Счет кредит во внутреннем документе"
  FUNCTION Acc_CT_MO
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  --Функция для М.О.С. "Счет кредит (приведенный) во внутреннем документе"
  FUNCTION Acc_CT_MO_Rev
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /* Катеквич 11/18/2008 - есть подозрение что где-то создаются проводки по этим функциям
            это не хорошо
  --Функция для создания проводки по шаблону
  function Add_Trans_By_Template(p_Trans_Templ_ID number,
                                 p_Oper_ID        number,
                                 p_is_accepted    number default 1,
                                 p_date           date default null,
                                 p_summ           number default null,
                                 p_qty            number default null,
                                 p_Source         varchar2 default 'TRS')
    return number;
  
  --Функция для создания операции по шаблону
  function Run_Oper_By_Template(p_Oper_Templ_ID     number,
                                p_Document_ID       number,
                                p_Doc_Status_Ref_ID number default null,
                                p_is_accepted       number default 1,
                                p_Source            varchar2 default 'TRS')
    return number;*/

  --Функция для расчета курса валюты
  FUNCTION Get_Rate_By_ID
  (
    p_Rate_Type_ID NUMBER
   ,p_Fund_ID      NUMBER
   ,p_Date         DATE
  ) RETURN NUMBER;

  --Функция для расчета курса валюты (по сокращению типа курса и валюты)
  FUNCTION Get_Rate_By_Brief
  (
    p_Rate_Type_Brief VARCHAR2
   ,p_Fund_Brief      VARCHAR2
   ,p_Date            DATE
  ) RETURN NUMBER;

  --Получить сущность аналитики заданного уровня по счету
  FUNCTION Get_Analytic_Entity_ID
  (
    p_Account_ID NUMBER
   ,p_An_Num     NUMBER
  ) RETURN NUMBER;

  --Получить ИД аналитики заданного уровня по счету
  FUNCTION Get_Analytic_Object_ID
  (
    p_Account_ID  NUMBER
   ,p_An_Num      NUMBER
   ,p_Document_ID NUMBER
  ) RETURN NUMBER;

  --Получить кросс-курс между двумя валютами через тип курса
  FUNCTION Get_Cross_Rate_By_Id
  (
    p_Rate_Type_Id IN NUMBER
   ,p_Fund_Id_In   IN NUMBER
   ,p_Fund_Id_Out  IN NUMBER
   ,p_Date         IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER;

  --Остатки и обороты по счету за период
  FUNCTION Get_Acc_Turn_Rest
  (
    p_Account_ID NUMBER
   ,p_Fund_ID    NUMBER
   ,p_Start_Date DATE DEFAULT SYSDATE
   ,p_End_Date   DATE DEFAULT SYSDATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A1_nulls   NUMBER DEFAULT 0
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A2_nulls   NUMBER DEFAULT 0
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A3_nulls   NUMBER DEFAULT 0
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A4_nulls   NUMBER DEFAULT 0
   ,p_A5_ID      NUMBER DEFAULT NULL
   ,p_A5_nulls   NUMBER DEFAULT 0
  ) RETURN t_Turn_Rest;

  --Исходящий остаток по счету на дату
  FUNCTION Get_Acc_Rest
  (
    p_Account_ID NUMBER
   ,p_Fund_ID    NUMBER
   ,p_Date       DATE DEFAULT SYSDATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A1_nulls   NUMBER DEFAULT 0
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A2_nulls   NUMBER DEFAULT 0
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A3_nulls   NUMBER DEFAULT 0
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A4_nulls   NUMBER DEFAULT 0
   ,p_A5_ID      NUMBER DEFAULT NULL
   ,p_A5_nulls   NUMBER DEFAULT 0
  ) RETURN t_Rest;

  --Исходящий остаток по счету на дату (дебет-кредит)
  FUNCTION Get_Acc_Rest_Abs
  (
    p_Rest_Amount_Type VARCHAR2
   ,p_Account_ID       NUMBER
   ,p_Fund_ID          NUMBER
   ,p_Date             DATE DEFAULT SYSDATE
   ,p_A1_ID            NUMBER DEFAULT NULL
   ,p_A1_nulls         NUMBER DEFAULT 0
   ,p_A2_ID            NUMBER DEFAULT NULL
   ,p_A2_nulls         NUMBER DEFAULT 0
   ,p_A3_ID            NUMBER DEFAULT NULL
   ,p_A3_nulls         NUMBER DEFAULT 0
   ,p_A4_ID            NUMBER DEFAULT NULL
   ,p_A4_nulls         NUMBER DEFAULT 0
   ,p_A5_ID            NUMBER DEFAULT NULL
   ,p_A5_nulls         NUMBER DEFAULT 0
  ) RETURN NUMBER;

  --Остатки и обороты по счету за период
  FUNCTION Get_Acc_Turn_Rest_By_Type
  (
    p_Type       VARCHAR2
   ,p_Char       VARCHAR2
   ,p_Account_ID NUMBER
   ,p_Fund_ID    NUMBER
   ,p_Start_Date DATE DEFAULT SYSDATE
   ,p_End_Date   DATE DEFAULT SYSDATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A1_nulls   NUMBER DEFAULT 0
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A2_nulls   NUMBER DEFAULT 0
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A3_nulls   NUMBER DEFAULT 0
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A4_nulls   NUMBER DEFAULT 0
   ,p_A5_ID      NUMBER DEFAULT NULL
   ,p_A5_nulls   NUMBER DEFAULT 0
  ) RETURN NUMBER;

  FUNCTION Get_Cross_Rate_By_Brief
  (
    p_Rate_Type_Id   IN NUMBER
   ,p_Fund_Brief_In  IN VARCHAR2
   ,p_Fund_Brief_Out IN VARCHAR2
   ,p_Date           IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER;

  --Расчитать ключевой разряд в банковском счете
  FUNCTION Get_Key_Account
  (
    p_BIC     VARCHAR2
   ,p_Account VARCHAR2
  ) RETURN VARCHAR2;

  --Установка соответствующих признаков всем дочерним счетам
  PROCEDURE Set_Attr_Inherit_Child_Acc
  (
    p_Account_ID NUMBER
   ,p_IS_CHAR    NUMBER
   ,p_IS_AN      NUMBER
  );
  --Найти счет по маске
  FUNCTION Get_Account_By_Mask
  (
    p_Account_ID            NUMBER
   ,p_Acc_Chart_Type_ID     NUMBER
   ,p_Rev_Acc_Chart_Type_ID NUMBER
  ) RETURN NUMBER;

  --Количество значащих символов в маске счета
  FUNCTION Mask_Sign_Count(p_Mask VARCHAR2) RETURN NUMBER;

  --Проверка на присутствие аналитики в счете
  FUNCTION Is_Valid_Analytic
  (
    p_Analytic_Type_ID NUMBER
   ,p_URO_ID           NUMBER
   ,p_Account_ID       NUMBER
  ) RETURN NUMBER;

  --Найти роль по маске счета
  FUNCTION Get_Role_By_Mask
  (
    p_Account_Num       VARCHAR2
   ,p_Acc_Char          VARCHAR2
   ,p_Acc_Chart_Type_ID NUMBER
  ) RETURN NUMBER;

  --Обновить роли счетов в плане счетов, согласно заведенным маскам
  PROCEDURE Refresh_Acc_Roles(p_Acc_Chart_Type_ID NUMBER);

  --Унаследовать признаки родительского счета дочерним счетам
  PROCEDURE Update_Nested_Accounts(p_Account_ID NUMBER);

END acc;
/
CREATE OR REPLACE PACKAGE BODY "ACC" IS

  -- ИД типа курса ЦБ
  FUNCTION get_cb_rate_type_id RETURN NUMBER AS
  BEGIN
    RETURN cb_rate_type_id;
  END;

  --Функция для определения счета по М.О.С.
  FUNCTION Get_Acc_By_Acc_Def_Rule
  (
    p_ADR_ID    NUMBER
   ,p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
    v_ADR_Name   VARCHAR2(150);
    v_ADR_Brief  VARCHAR2(61);
    v_SQL_Text   VARCHAR2(4000);
  BEGIN
    BEGIN
      SELECT adr.name
            ,adr.brief
        INTO v_ADR_Name
            ,v_ADR_Brief
        FROM Acc_Def_Rule adr
       WHERE adr.acc_def_rule_id = p_ADR_ID;
      v_SQL_Text := 'begin select ' || v_ADR_Brief ||
                    '(:p_Entity_ID, :p_Object_ID, :p_Fund_ID, :p_Date, :p_Doc_ID) ' ||
                    'Account_ID into :v_Account_ID from dual; end;';
      EXECUTE IMMEDIATE v_SQL_Text
        USING IN p_Entity_ID, IN p_Object_ID, IN p_Fund_ID, IN p_Date, IN p_Doc_ID, OUT v_Account_ID;
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := 0;
    END;
    RETURN v_Account_ID;
  END;

  --Функция для определения счета по типу счета
  FUNCTION Get_Acc_By_Acc_Type
  (
    p_Acc_Type_Templ_ID    NUMBER
   ,p_Acc_Chart_Type_ID    NUMBER
   ,p_Settlement_Scheme_ID NUMBER
   ,p_Doc_ID               NUMBER
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
    CURSOR c_Acc_Set IS
      SELECT dta.doc_templ_acc_id
            ,dta.acc_role_id
            ,doc.get_fund_type(p_Doc_ID, dta.fund_type_id) fund_id
            ,dta.a1_analytic_type_id
            ,nvl2(dta.a1_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a1_analytic_type_id), NULL) a1_uro_id
            ,dta.a2_analytic_type_id
            ,nvl2(dta.a2_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a2_analytic_type_id), NULL) a2_uro_id
            ,dta.a3_analytic_type_id
            ,nvl2(dta.a3_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a3_analytic_type_id), NULL) a3_uro_id
            ,dta.a4_analytic_type_id
            ,nvl2(dta.a4_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a4_analytic_type_id), NULL) a4_uro_id
            ,dta.a5_analytic_type_id
            ,nvl2(dta.a5_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a5_analytic_type_id), NULL) a5_uro_id
        FROM Document      d
            ,Doc_Templ     dt
            ,Doc_Templ_Acc dta
       WHERE d.document_id = p_Doc_ID
         AND dta.acc_type_templ_id = p_Acc_Type_Templ_ID
         AND dta.acc_chart_type_id = p_Acc_Chart_Type_ID
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = dta.doc_templ_id
         AND ((dta.settlement_scheme_id IS NULL) OR
             (dta.settlement_scheme_id IS NOT NULL) AND
             (dta.settlement_scheme_id = p_Settlement_Scheme_ID))
       ORDER BY dta.priority_order;
    v_Doc_Templ_Acc_ID    NUMBER;
    v_Acc_Role_ID         NUMBER;
    v_Fund_ID             NUMBER;
    v_a1_analytic_type_ID NUMBER;
    v_a1_uro_ID           NUMBER;
    v_a2_analytic_type_ID NUMBER;
    v_a2_uro_ID           NUMBER;
    v_a3_analytic_type_ID NUMBER;
    v_a3_uro_ID           NUMBER;
    v_a4_analytic_type_ID NUMBER;
    v_a4_uro_ID           NUMBER;
    v_a5_analytic_type_ID NUMBER;
    v_a5_uro_ID           NUMBER;
    CURSOR c_Account
    (
      cp_Fund_ID             NUMBER
     ,cp_Acc_Role_ID         NUMBER
     ,cp_a1_analytic_type_id NUMBER
     ,cp_a1_uro_id           NUMBER
     ,cp_a2_analytic_type_id NUMBER
     ,cp_a2_uro_id           NUMBER
     ,cp_a3_analytic_type_id NUMBER
     ,cp_a3_uro_id           NUMBER
     ,cp_a4_analytic_type_id NUMBER
     ,cp_a4_uro_id           NUMBER
     ,cp_a5_analytic_type_id NUMBER
     ,cp_a5_uro_id           NUMBER
    ) IS
      SELECT a.account_id
        FROM Account a
       WHERE a.acc_chart_type_id = p_Acc_Chart_Type_ID
         AND a.fund_id = cp_Fund_ID
         AND a.acc_role_id = cp_Acc_Role_ID
         AND ((((cp_a1_analytic_type_ID IS NULL) AND (cp_a1_uro_ID IS NULL)) OR
             ((cp_a1_analytic_type_ID IS NOT NULL) AND (cp_a1_uro_ID IS NOT NULL) AND
             (acc.Is_Valid_Analytic(cp_a1_analytic_type_ID, cp_a1_uro_ID, a.account_id) = 1))) AND
             (((cp_a2_analytic_type_ID IS NULL) AND (cp_a2_uro_ID IS NULL)) OR
             ((cp_a2_analytic_type_ID IS NOT NULL) AND (cp_a2_uro_ID IS NOT NULL) AND
             (acc.Is_Valid_Analytic(cp_a2_analytic_type_ID, cp_a2_uro_ID, a.account_id) = 1))) AND
             (((cp_a3_analytic_type_ID IS NULL) AND (cp_a3_uro_ID IS NULL)) OR
             ((cp_a3_analytic_type_ID IS NOT NULL) AND (cp_a3_uro_ID IS NOT NULL) AND
             (acc.Is_Valid_Analytic(cp_a3_analytic_type_ID, cp_a3_uro_ID, a.account_id) = 1))) AND
             (((cp_a4_analytic_type_ID IS NULL) AND (cp_a4_uro_ID IS NULL)) OR
             ((cp_a4_analytic_type_ID IS NOT NULL) AND (cp_a4_uro_ID IS NOT NULL) AND
             (acc.Is_Valid_Analytic(cp_a4_analytic_type_ID, cp_a4_uro_ID, a.account_id) = 1))) AND
             (((cp_a5_analytic_type_ID IS NULL) AND (cp_a5_uro_ID IS NULL)) OR
             ((cp_a5_analytic_type_ID IS NOT NULL) AND (cp_a5_uro_ID IS NOT NULL) AND
             (acc.Is_Valid_Analytic(cp_a5_analytic_type_ID, cp_a5_uro_ID, a.account_id) = 1))));
    CURSOR c_Doc_Acc_Redefine
    (
      cp_Doc_ID           NUMBER
     ,cp_Doc_Templ_Acc_ID NUMBER
    ) IS
      SELECT dar.account_id
        FROM Doc_AcC_redefine dar
       WHERE dar.document_id = cp_Doc_ID
         AND dar.doc_templ_acc_id = cp_Doc_Templ_Acc_ID;
  BEGIN
    v_Account_ID := NULL;
    OPEN c_Acc_Set;
    LOOP
      FETCH c_Acc_Set
        INTO v_Doc_Templ_Acc_ID
            ,v_Fund_ID
            ,v_Acc_Role_ID
            ,v_a1_analytic_type_ID
            ,v_a1_uro_ID
            ,v_a2_analytic_type_ID
            ,v_a2_uro_ID
            ,v_a3_analytic_type_ID
            ,v_a3_uro_ID
            ,v_a4_analytic_type_ID
            ,v_a4_uro_ID
            ,v_a5_analytic_type_ID
            ,v_a5_uro_ID;
      EXIT WHEN c_Acc_Set%NOTFOUND;
      IF (((v_a1_analytic_type_id IS NULL) AND (v_a1_uro_id IS NULL)) OR
         ((v_a1_analytic_type_id IS NOT NULL) AND (v_a1_uro_id IS NOT NULL)))
         AND (((v_a2_analytic_type_id IS NULL) AND (v_a2_uro_id IS NULL)) OR
         ((v_a2_analytic_type_id IS NOT NULL) AND (v_a2_uro_id IS NOT NULL)))
         AND (((v_a3_analytic_type_id IS NULL) AND (v_a3_uro_id IS NULL)) OR
         ((v_a3_analytic_type_id IS NOT NULL) AND (v_a3_uro_id IS NOT NULL)))
         AND (((v_a4_analytic_type_id IS NULL) AND (v_a4_uro_id IS NULL)) OR
         ((v_a4_analytic_type_id IS NOT NULL) AND (v_a4_uro_id IS NOT NULL)))
         AND (((v_a5_analytic_type_id IS NULL) AND (v_a5_uro_id IS NULL)) OR
         ((v_a5_analytic_type_id IS NOT NULL) AND (v_a5_uro_id IS NOT NULL)))
      THEN
        OPEN c_Doc_Acc_Redefine(p_Doc_ID, v_Doc_Templ_Acc_ID);
        FETCH c_Doc_Acc_Redefine
          INTO v_Account_ID;
        IF c_Doc_Acc_Redefine%NOTFOUND
        THEN
          OPEN c_Account(v_Acc_Role_ID
                        ,v_Fund_ID
                        ,v_a1_analytic_type_ID
                        ,v_a1_uro_ID
                        ,v_a2_analytic_type_ID
                        ,v_a2_uro_ID
                        ,v_a3_analytic_type_ID
                        ,v_a3_uro_ID
                        ,v_a4_analytic_type_ID
                        ,v_a4_uro_ID
                        ,v_a5_analytic_type_ID
                        ,v_a5_uro_ID);
          FETCH c_Account
            INTO v_Account_ID;
          IF c_Acc_Set%NOTFOUND
          THEN
            v_Account_ID := NULL;
          END IF;
          CLOSE c_Account;
        END IF;
        CLOSE c_Doc_Acc_Redefine;
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_Acc_Set;
    RETURN v_Account_ID;
  END;

  --Функция для определения приоритета счета по типу счета
  FUNCTION Get_Acc_Priority_By_Acc_Type
  (
    p_Acc_Type_Templ_ID    NUMBER
   ,p_Acc_Chart_Type_ID    NUMBER
   ,p_Settlement_Scheme_ID NUMBER
   ,p_Doc_ID               NUMBER
  ) RETURN NUMBER IS
    --v_Priority_ID number;
    CURSOR c_Acc_Set IS
      SELECT dta.priority_order
            ,dta.a1_analytic_type_id
            ,nvl2(dta.a1_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a1_analytic_type_id), NULL) a1_uro_id
            ,dta.a2_analytic_type_id
            ,nvl2(dta.a2_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a2_analytic_type_id), NULL) a2_uro_id
            ,dta.a3_analytic_type_id
            ,nvl2(dta.a3_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a3_analytic_type_id), NULL) a3_uro_id
            ,dta.a4_analytic_type_id
            ,nvl2(dta.a4_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a4_analytic_type_id), NULL) a4_uro_id
            ,dta.a5_analytic_type_id
            ,nvl2(dta.a5_analytic_type_id, doc.get_an_type(p_Doc_ID, dta.a5_analytic_type_id), NULL) a5_uro_id
        FROM Document      d
            ,Doc_Templ     dt
            ,Doc_Templ_Acc dta
       WHERE d.document_id = p_Doc_ID
         AND dta.acc_type_templ_id = p_Acc_Type_Templ_ID
         AND dta.acc_chart_type_id = p_Acc_Chart_Type_ID
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = dta.doc_templ_id
         AND ((dta.settlement_scheme_id IS NULL) OR
             (dta.settlement_scheme_id IS NOT NULL) AND
             (dta.settlement_scheme_id = p_Settlement_Scheme_ID))
       ORDER BY dta.priority_order;
    --v_Doc_Templ_Acc_ID    number;
    --v_Acc_Role_ID         number;
    --v_Fund_ID             number;
    v_a1_analytic_type_ID NUMBER;
    v_a1_uro_ID           NUMBER;
    v_a2_analytic_type_ID NUMBER;
    v_a2_uro_ID           NUMBER;
    v_a3_analytic_type_ID NUMBER;
    v_a3_uro_ID           NUMBER;
    v_a4_analytic_type_ID NUMBER;
    v_a4_uro_ID           NUMBER;
    v_a5_analytic_type_ID NUMBER;
    v_a5_uro_ID           NUMBER;
    v_Priority            NUMBER;
    v_Priority_Order      NUMBER;
  BEGIN
    v_Priority := 0;
    OPEN c_Acc_Set;
    LOOP
      FETCH c_Acc_Set
        INTO v_Priority_Order
            ,v_a1_analytic_type_ID
            ,v_a1_uro_ID
            ,v_a2_analytic_type_ID
            ,v_a2_uro_ID
            ,v_a3_analytic_type_ID
            ,v_a3_uro_ID
            ,v_a4_analytic_type_ID
            ,v_a4_uro_ID
            ,v_a5_analytic_type_ID
            ,v_a5_uro_ID;
      EXIT WHEN c_Acc_Set%NOTFOUND;
      IF (((v_a1_analytic_type_id IS NULL) AND (v_a1_uro_id IS NULL)) OR
         ((v_a1_analytic_type_id IS NOT NULL) AND (v_a1_uro_id IS NOT NULL)))
         AND (((v_a2_analytic_type_id IS NULL) AND (v_a2_uro_id IS NULL)) OR
         ((v_a2_analytic_type_id IS NOT NULL) AND (v_a2_uro_id IS NOT NULL)))
         AND (((v_a3_analytic_type_id IS NULL) AND (v_a3_uro_id IS NULL)) OR
         ((v_a3_analytic_type_id IS NOT NULL) AND (v_a3_uro_id IS NOT NULL)))
         AND (((v_a4_analytic_type_id IS NULL) AND (v_a4_uro_id IS NULL)) OR
         ((v_a4_analytic_type_id IS NOT NULL) AND (v_a4_uro_id IS NOT NULL)))
         AND (((v_a5_analytic_type_id IS NULL) AND (v_a5_uro_id IS NULL)) OR
         ((v_a5_analytic_type_id IS NOT NULL) AND (v_a5_uro_id IS NOT NULL)))
      THEN
        v_Priority := v_Priority_Order;
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_Acc_Set;
    RETURN v_Priority;
  END;

  --Формирование примечания проводки
  FUNCTION Get_Trans_Note
  (
    p_Trans_Templ_ID NUMBER
   ,p_Oper_ID        NUMBER
  ) RETURN VARCHAR2 IS
    v_Note       VARCHAR2(2000);
    v_Res_Note   VARCHAR2(2000);
    i            INTEGER;
    j            INTEGER;
    f            INTEGER;
    v_Attr_Brief VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT tt.note INTO v_Note FROM Trans_Templ tt WHERE tt.trans_templ_id = p_Trans_Templ_ID;
    EXCEPTION
      WHEN OTHERS THEN
        v_Note := '';
    END;
    IF length(v_Note) > 0
    THEN
      i          := 1;
      v_Res_Note := '';
      WHILE i <= length(v_Note)
      LOOP
        IF (substr(v_Note, i, 1) <> '[')
        THEN
          v_Res_Note := v_Res_Note || substr(v_Note, i, 1);
          i          := i + 1;
        ELSE
          f            := 0;
          j            := i + 1;
          v_Attr_Brief := '';
          WHILE (f = 0)
                AND (j <= length(v_Note))
          LOOP
            IF (substr(v_Note, j, 1) <> ']')
            THEN
              v_Attr_Brief := v_Attr_Brief || substr(v_Note, j, 1);
              j            := j + 1;
            ELSE
              f := 1;
            END IF;
          END LOOP;
          IF (f = 1)
          THEN
            v_Res_Note := v_Res_Note || doc.get_attr('OPER', v_Attr_Brief, p_Oper_ID);
            i          := i + length(v_Attr_Brief) + 2;
          ELSE
            i := i + 1;
          END IF;
        END IF;
      END LOOP;
    END IF;
    RETURN v_Res_Note;
  END;

  --Функция для М.О.С. "Счет в валюте"
  FUNCTION Acc_By_Fund
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
  BEGIN
    -- Входящий параметр: ИД синтетического балансового счета
    -- Необходимо найти лицевой счет по баланосовому в указанной валюте
    BEGIN
      SELECT nvl(MIN(a.account_id), 0)
        INTO v_Account_ID
        FROM Account a
       WHERE a.Parent_Id = p_Object_ID
         AND a.fund_id = p_Fund_ID
         AND a.open_date <= p_Date
         AND ((a.close_date > p_Date) OR (a.close_date IS NULL))
         AND (a.acc_status_id <> 5);
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := 0;
        dbms_output.put_line('М.О.С. "Счет в валюте"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_Char(p_Entity_ID));
        dbms_output.put_line('p_Object_ID = ' || to_Char(p_Object_ID));
        dbms_output.put_line('p_Fund_ID   = ' || to_Char(p_Fund_ID));
        dbms_output.put_line('p_Date      = ' || to_Char(p_Entity_ID, 'DD/MM/YYYY'));
    END;
    RETURN v_Account_ID;
  END;

  --Функция для М.О.С. "Счет дебет во внутреннем документе"
  FUNCTION Acc_DT_MO
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.Account_ID
        INTO v_Account_ID
        FROM Document      d
            ,Doc_Mem_Order dmo
            ,Account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_Object_ID
         AND a.account_id = dmo.dt_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := 0;
        dbms_output.put_line('М.О.С. "Счет дебет во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_Char(p_Entity_ID));
        dbms_output.put_line('p_Object_ID = ' || to_Char(p_Object_ID));
        dbms_output.put_line('p_Fund_ID   = ' || to_Char(p_Fund_ID));
        dbms_output.put_line('p_Date      = ' || to_Char(p_Entity_ID, 'DD/MM/YYYY'));
    END;
    RETURN v_Account_ID;
  END;

  --Функция для М.О.С. "Счет дебет (приведенный) во внутреннем документе"
  FUNCTION Acc_DT_MO_Rev
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.Account_ID
        INTO v_Account_ID
        FROM Document      d
            ,Doc_Mem_Order dmo
            ,Account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_Object_ID
         AND a.account_id = dmo.dt_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
      v_Account_ID := acc.Get_Account_By_Mask(v_Account_ID, 1, 2);
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := 0;
        dbms_output.put_line('М.О.С. "Счет дебет во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_Char(p_Entity_ID));
        dbms_output.put_line('p_Object_ID = ' || to_Char(p_Object_ID));
        dbms_output.put_line('p_Fund_ID   = ' || to_Char(p_Fund_ID));
        dbms_output.put_line('p_Date      = ' || to_Char(p_Entity_ID, 'DD/MM/YYYY'));
    END;
    RETURN v_Account_ID;
  END;

  --Функция для М.О.С. "Счет кредит во внутреннем документе"
  FUNCTION Acc_CT_MO
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.Account_ID
        INTO v_Account_ID
        FROM Document      d
            ,Doc_Mem_Order dmo
            ,Account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_Object_ID
         AND a.account_id = dmo.ct_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := 0;
        dbms_output.put_line('М.О.С. "Счет кредит во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_Char(p_Entity_ID));
        dbms_output.put_line('p_Object_ID = ' || to_Char(p_Object_ID));
        dbms_output.put_line('p_Fund_ID   = ' || to_Char(p_Fund_ID));
        dbms_output.put_line('p_Date      = ' || to_Char(p_Entity_ID, 'DD/MM/YYYY'));
    END;
    RETURN v_Account_ID;
  END;

  --Функция для М.О.С. "Счет кредит (приведенный) во внутреннем документе"
  FUNCTION Acc_CT_MO_Rev
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_Account_ID NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.Account_ID
        INTO v_Account_ID
        FROM Document      d
            ,Doc_Mem_Order dmo
            ,Account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_Object_ID
         AND a.account_id = dmo.ct_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
      v_Account_ID := acc.Get_Account_By_Mask(v_Account_ID, 1, 2);
    EXCEPTION
      WHEN OTHERS THEN
        v_Account_ID := 0;
        dbms_output.put_line('М.О.С. "Счет кредит во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_Char(p_Entity_ID));
        dbms_output.put_line('p_Object_ID = ' || to_Char(p_Object_ID));
        dbms_output.put_line('p_Fund_ID   = ' || to_Char(p_Fund_ID));
        dbms_output.put_line('p_Date      = ' || to_Char(p_Entity_ID, 'DD/MM/YYYY'));
    END;
    RETURN v_Account_ID;
  END;

  --Функция для создания проводки по шаблону
  FUNCTION Add_Trans_By_Template
  (
    p_Trans_Templ_ID NUMBER
   ,p_Oper_ID        NUMBER
   ,p_is_accepted    NUMBER DEFAULT 1
   ,p_date           DATE DEFAULT NULL
   ,p_summ           NUMBER DEFAULT NULL
   ,p_qty            NUMBER DEFAULT NULL
   ,p_Source         VARCHAR2 DEFAULT 'TRS'
  ) RETURN NUMBER IS
    TYPE t_An IS RECORD(
       ure_name VARCHAR2(30)
      ,uro_name VARCHAR2(30)
      ,corr     VARCHAR2(1)
      ,a_num    VARCHAR2(1));
    --v_SQL_Text             varchar2(4000);
    v_document_id    NUMBER;
    v_Rate_Type_ID   NUMBER;
    v_Recalc_Fund_ID NUMBER;
    v_Rate           NUMBER;
    v_Recalc_Rate    NUMBER;
    v_Trans_Templ    Trans_Templ%ROWTYPE;
    v_Trans          Trans%ROWTYPE;
    --v_An_Col_Name          varchar2(30);
    v_Temp_Str_1 VARCHAR2(150);
    v_Temp_Str_2 VARCHAR2(150);
    --v_Temp_Str_3           varchar2(150);
    v_Settlement_Scheme_ID NUMBER;
    CURSOR c_An IS
      SELECT atc.COLUMN_NAME ure_name
            ,atco.COLUMN_NAME uro_name
            ,substr(atc.COLUMN_NAME, 4, 1) corr
            ,substr(atc.COLUMN_NAME, 2, 1) a_num
        FROM all_tab_columns atc
            ,all_tab_columns atco
       WHERE atc.TABLE_NAME = 'TRANS'
         AND atc.OWNER = 'TRS'
         AND atc.COLUMN_NAME LIKE 'A%T_URE_ID'
         AND atco.TABLE_NAME = atc.TABLE_NAME
         AND atco.OWNER = atc.OWNER
         AND atco.COLUMN_NAME = 'A' || substr(atc.COLUMN_NAME, 2, 3) || 'T_URO_ID';
    v_An         t_An;
    v_Trans_Err  Trans_Err%ROWTYPE;
    v_Account    Account%ROWTYPE;
    v_Dt_Account Account%ROWTYPE;
    v_Ct_Account Account%ROWTYPE;
  BEGIN
    v_Trans_Err.Trans_Err_Id := 0;
    v_Trans_Err.Trans        := NULL;
    v_Trans_Err.Trans_Templ  := NULL;
    v_Trans_Err.Trans_Date   := NULL;
    v_Trans_Err.Acc_Fund     := NULL;
    v_Trans_Err.Recalc_Fund  := NULL;
    v_Trans_Err.Acc_Amount   := NULL;
    v_Trans_Err.Base_Fund    := NULL;
    v_Trans_Err.Rate_Type    := NULL;
    v_Trans_Err.Dt_Account   := NULL;
    v_Trans_Err.Ct_Account   := NULL;
    --Найти шаблон проводки
    BEGIN
      SELECT * INTO v_Trans_Templ FROM Trans_Templ tt WHERE tt.trans_templ_id = p_Trans_Templ_ID;
      v_Trans_Err.Trans_Templ := v_Trans_Templ.Name;
    EXCEPTION
      WHEN OTHERS THEN
        v_Trans_Err.Trans_Err_Id := 1;
        v_Trans_Err.Trans_Templ  := '<неизвестный> ИД=' || to_char(p_Trans_Templ_ID);
    END;
  
    IF v_Trans_Err.Trans_Err_Id = 0
    THEN
      --автономер
      SELECT sq_trans.nextval INTO v_Trans.Trans_ID FROM dual;
      --документ
      SELECT o.document_id INTO v_document_id FROM Oper o WHERE o.oper_id = p_Oper_ID;
      --дата проведения
      v_Trans.trans_date := nvl(p_date, doc.get_date_type(v_document_id, v_Trans_Templ.Date_Type_Id));
      -- oper day
      /*    if pkg_oper_day.get_date_status(v_Trans.Trans_Date)=1 then
            v_Trans_Err.Trans_Err_Id := 1;
            v_Trans_Err.trans_date   := to_char(v_Trans.Trans_Date, 'dd.mm.yyyy') || ' в закрытом дне';
          end if;
      */ -- oper day
    
      /*    --схема расчетов
          begin
            select df.settlement_scheme_id into v_Settlement_Scheme_ID from Doc_Fto df where df.doc_fto_id = v_document_id;
          exception when others then
            v_Settlement_Scheme_ID := null;
          end;
      */
    
      v_Settlement_Scheme_ID := NULL;
    
      IF v_Trans.trans_date IS NULL
      THEN
        BEGIN
          SELECT dt.name
            INTO v_Temp_Str_1
            FROM Date_Type dt
           WHERE dt.date_type_id = v_Trans_Templ.Date_Type_Id;
        EXCEPTION
          WHEN OTHERS THEN
            v_Temp_Str_1 := '<неизвестный>';
        END;
        v_Trans_Err.Trans_Err_Id := 1;
        v_Trans_Err.trans_date   := v_Temp_Str_1 || ', ИД=' || to_char(v_Trans_Templ.Date_Type_Id);
      END IF;
      --валюта счета
      v_Trans.acc_fund_id := doc.get_fund_type(v_document_id, v_Trans_Templ.Fund_Type_Id);
      IF v_Trans.acc_fund_id IS NULL
      THEN
        BEGIN
          SELECT ft.name
            INTO v_Temp_Str_1
            FROM Fund_Type ft
           WHERE ft.fund_type_id = v_Trans_Templ.fund_Type_Id;
        EXCEPTION
          WHEN OTHERS THEN
            v_Temp_Str_1 := '<неизвестный>';
        END;
        v_Trans_Err.Trans_Err_Id := 1;
        v_Trans_Err.Acc_Fund     := v_Temp_Str_1 || ', ИД=' || to_char(v_Trans_Templ.Fund_Type_Id);
      END IF;
      --валюта пересчета суммы
      v_Recalc_Fund_ID := doc.get_fund_type(v_document_id, v_Trans_Templ.Summ_Fund_Type_Id);
      IF v_Recalc_Fund_ID IS NULL
      THEN
        BEGIN
          SELECT ft.name
            INTO v_Temp_Str_1
            FROM Fund_Type ft
           WHERE ft.fund_type_id = v_Trans_Templ.Summ_Fund_Type_Id;
        EXCEPTION
          WHEN OTHERS THEN
            v_Temp_Str_1 := '<неизвестный>';
        END;
        v_Trans_Err.Trans_Err_Id := 1;
        v_Trans_Err.Recalc_Fund  := v_Temp_Str_1 || ', ИД=' ||
                                    to_char(v_Trans_Templ.Summ_Fund_Type_Id);
      END IF;
      --сумма в валюте счета
      v_Trans.acc_amount := nvl(p_summ, doc.get_summ_type(v_document_id, v_Trans_Templ.Summ_Type_Id));
      IF v_Trans.acc_amount IS NULL
      THEN
        BEGIN
          SELECT st.name
            INTO v_Temp_Str_1
            FROM Summ_Type st
           WHERE st.summ_type_id = v_Trans_Templ.Summ_Type_Id;
        EXCEPTION
          WHEN OTHERS THEN
            v_Temp_Str_1 := '<неизвестный>';
        END;
        v_Trans_Err.Trans_Err_Id := 1;
        v_Trans_Err.Acc_Amount   := v_Temp_Str_1 || ', ИД=' || to_char(v_Trans_Templ.Summ_Type_Id);
      ELSIF v_Trans.acc_amount = 0
      THEN
        BEGIN
          SELECT st.name
            INTO v_Temp_Str_1
            FROM Summ_Type st
           WHERE st.summ_type_id = v_Trans_Templ.Summ_Type_Id;
        EXCEPTION
          WHEN OTHERS THEN
            v_Temp_Str_1 := '<неизвестный>';
        END;
        v_Trans_Err.Trans_Err_Id := 1;
        v_Trans_Err.Acc_Amount   := 'сумма=0, ' || v_Temp_Str_1 || ', ИД=' ||
                                    to_char(v_Trans_Templ.Summ_Type_Id);
      END IF;
      v_Trans.Trans_Quantity    := nvl(p_qty
                                      ,doc.get_summ_type(v_document_id, v_Trans_Templ.Qty_Type_Id));
      v_trans_templ.is_accepted := p_is_accepted;
    
      IF (v_Trans_Err.Trans_Err_Id = 0)
      THEN
        --план счетов, валюта плана счетов
        SELECT act.base_fund_id
          INTO v_Trans.trans_fund_id
          FROM Acc_Chart_Type act
         WHERE v_Trans_Templ.Acc_Chart_Type_ID = act.acc_chart_type_id;
        --ИД Типа курса Курс ЦБ
        SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
        --курс пересчета, сумма пересчета
        IF (v_Recalc_Fund_Id <> v_Trans.Acc_Fund_Id)
        THEN
          v_Recalc_Rate        := acc.Get_Rate_By_ID(v_Rate_Type_ID
                                                    ,v_Recalc_Fund_Id
                                                    ,v_Trans.Trans_Date);
          v_Trans.Acc_Amount   := v_Trans.Acc_Amount * v_Recalc_Rate;
          v_Trans.Acc_Amount   := ROUND(v_Trans.Acc_Amount * 100) / 100;
          v_Trans.Trans_Amount := v_Trans.Acc_Amount;
          v_Recalc_Rate        := acc.Get_Rate_By_ID(v_Rate_Type_ID
                                                    ,v_Trans.Acc_Fund_Id
                                                    ,v_Trans.Trans_Date);
          v_Trans.Acc_Amount   := v_Trans.Acc_Amount / v_Recalc_Rate;
          v_Trans.Acc_Amount   := ROUND(v_Trans.Acc_Amount * 100) / 100;
          v_Trans.Acc_Rate     := v_Trans.Trans_Amount / v_Trans.Acc_Amount;
        ELSE
          --курс приведения, сумма приведения
          IF (v_Trans.Trans_Fund_Id = v_Trans.Acc_Fund_Id)
          THEN
            v_Trans.Trans_Amount := v_Trans.acc_amount;
            v_Trans.Acc_Rate     := 1;
          ELSE
            v_Rate := acc.Get_Rate_By_ID(v_Rate_Type_ID, v_Trans.Acc_Fund_Id, v_Trans.Trans_Date);
            IF v_Rate > 0
            THEN
              v_Trans.Trans_Amount := v_Trans.Acc_Amount * v_Rate;
              v_Trans.Trans_Amount := ROUND(v_Trans.Trans_Amount * 100) / 100;
              v_Trans.Acc_Rate     := v_Rate;
            ELSE
              v_Trans.Trans_Amount := v_Trans.acc_amount;
              v_Trans.Acc_Rate     := 1;
            END IF;
          END IF;
        END IF;
      
        --счет по дебету
        IF v_Trans_Templ.Dt_Account_Id IS NOT NULL
        THEN
          --Указан конкретный счет
          v_Trans.Dt_Account_Id := v_trans_templ.dt_account_id;
          SELECT * INTO v_Account FROM Account a WHERE a.account_id = v_trans_templ.dt_account_id;
          --Если план счетов счета не идентичен плану счетов проводки,
          --то найти счет по маске
          IF v_Trans_Templ.Acc_Chart_Type_ID <> v_Account.Acc_Chart_Type_Id
          THEN
            v_Trans.Dt_Account_Id := acc.Get_Account_By_Mask(v_Trans.Dt_Account_Id
                                                            ,v_Account.Acc_Chart_Type_Id
                                                            ,v_Trans_Templ.Acc_Chart_Type_ID);
            IF v_Trans.Dt_Account_Id IS NULL
            THEN
              BEGIN
                SELECT act.name
                  INTO v_Temp_Str_1
                  FROM Acc_Chart_Type act
                 WHERE act.acc_chart_type_id = v_Trans_Templ.Acc_Chart_Type_ID;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_1 := '<неизвестный>';
              END;
              v_Trans_Err.Trans_Err_Id := 1;
              v_Trans_Err.Dt_Account   := 'Счет ' || v_Account.Num || ', ИД=' ||
                                          to_char(v_Account.Account_Id) ||
                                          ', приведенный к плану счетов ' || v_Temp_Str_1 || ', ИД=' ||
                                          to_char(v_Trans_Templ.Acc_Chart_Type_ID);
            END IF;
          END IF;
        ELSE
          IF v_Trans_Templ.Dt_Acc_Type_Templ_Id IS NOT NULL
          THEN
            v_Trans.Dt_Account_Id := acc.Get_Acc_By_Acc_Type(v_Trans_Templ.Dt_Acc_Type_Templ_Id
                                                            ,v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id
                                                            ,v_Settlement_Scheme_ID
                                                            ,v_Document_ID);
            IF v_Trans.Dt_Account_Id IS NULL
            THEN
              BEGIN
                SELECT att.name
                  INTO v_Temp_Str_1
                  FROM Acc_Type_Templ att
                 WHERE att.acc_type_templ_id = v_Trans_Templ.Dt_Acc_Type_Templ_Id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_1 := '<неизвестный>';
              END;
              BEGIN
                SELECT act.name
                  INTO v_Temp_Str_2
                  FROM Acc_Chart_Type act
                 WHERE act.acc_chart_type_id = v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_2 := '<неизвестный>';
              END;
              v_Trans_Err.Trans_Err_Id := 1;
              v_Trans_Err.Dt_Account   := 'Тип счета ' || v_Temp_Str_1 || ', ИД=' ||
                                          to_char(v_Trans_Templ.Dt_Acc_Type_Templ_Id) ||
                                          ', по плану счетов ' || v_Temp_Str_2 || ', ИД=' ||
                                          to_char(v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id);
            ELSE
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_Trans_Templ.Acc_Chart_Type_ID <> v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id
              THEN
                v_Trans.Dt_Account_Id := acc.Get_Account_By_Mask(v_Trans.Dt_Account_Id
                                                                ,v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id
                                                                ,v_Trans_Templ.Acc_Chart_Type_ID);
                IF v_Trans.Dt_Account_Id IS NULL
                THEN
                  BEGIN
                    SELECT att.name
                      INTO v_Temp_Str_1
                      FROM Acc_Type_Templ att
                     WHERE att.acc_type_templ_id = v_Trans_Templ.Dt_Acc_Type_Templ_Id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_Temp_Str_2
                      FROM Acc_Chart_Type act
                     WHERE act.acc_chart_type_id = v_Trans_Templ.Acc_Chart_Type_ID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_2 := '<неизвестный>';
                  END;
                  v_Trans_Err.Trans_Err_Id := 1;
                  v_Trans_Err.Dt_Account   := 'Тип счета ' || v_Temp_Str_1 || ', ИД=' ||
                                              to_char(v_Trans_Templ.Dt_Acc_Type_Templ_Id) ||
                                              ', приведенный к плану счетов ' || v_Temp_Str_2 ||
                                              ', ИД=' || to_char(v_Trans_Templ.Acc_Chart_Type_ID);
                END IF;
              END IF;
            END IF;
          ELSE
            IF v_Trans_Templ.Dt_Uro_Id IS NOT NULL
            THEN
              --В МОС подставляется конкретный объект
              v_Trans.Dt_Account_Id := acc.Get_Acc_By_Acc_Def_Rule(v_Trans_Templ.dt_acc_def_rule_id
                                                                  ,v_Trans_Templ.dt_ure_id
                                                                  ,v_Trans_Templ.dt_uro_id
                                                                  ,v_Trans.Acc_fund_id
                                                                  ,v_Trans.Trans_Date
                                                                  ,v_document_id);
            ELSE
              --В МОС подставляется документ
              v_Trans.Dt_Account_Id := acc.Get_Acc_By_Acc_Def_Rule(v_Trans_Templ.dt_acc_def_rule_id
                                                                  ,NULL
                                                                  ,v_document_id
                                                                  ,v_Trans.Acc_fund_id
                                                                  ,v_Trans.Trans_Date
                                                                  ,v_document_id);
            END IF;
            IF v_Trans.Dt_Account_Id IS NOT NULL
            THEN
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_Trans_Templ.Acc_Chart_Type_ID <> v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id
              THEN
                v_Trans.Dt_Account_Id := acc.Get_Account_By_Mask(v_Trans.Dt_Account_Id
                                                                ,v_Trans_Templ.Dt_Rev_Acc_Chart_Type_Id
                                                                ,v_Trans_Templ.Acc_Chart_Type_ID);
                IF v_Trans.Dt_Account_Id IS NULL
                THEN
                  BEGIN
                    SELECT adr.name
                      INTO v_Temp_Str_1
                      FROM Acc_Def_Rule adr
                     WHERE adr.acc_def_rule_id = v_Trans_Templ.dt_acc_def_rule_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_Temp_Str_2
                      FROM Acc_Chart_Type act
                     WHERE act.acc_chart_type_id = v_Trans_Templ.Acc_Chart_Type_ID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_2 := '<неизвестный>';
                  END;
                  v_Trans_Err.Trans_Err_Id := 1;
                  v_Trans_Err.Dt_Account   := 'Счет по М.О.С. ' || v_Temp_Str_1 || ', ИД=' ||
                                              to_char(v_Trans_Templ.Dt_Acc_Type_Templ_Id) ||
                                              ', приведенный к плану счетов ' || v_Temp_Str_2 ||
                                              ', ИД=' || to_char(v_Trans_Templ.Acc_Chart_Type_ID);
                END IF;
              END IF;
            ELSE
              BEGIN
                SELECT adr.name
                  INTO v_Temp_Str_1
                  FROM Acc_Def_Rule adr
                 WHERE adr.acc_def_rule_id = v_Trans_Templ.dt_acc_def_rule_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_1 := '<неизвестный>';
              END;
              v_Trans_Err.Trans_Err_Id := 1;
              v_Trans_Err.Dt_Account   := 'М.О.С. ' || v_Temp_Str_1 || ', ИД=' ||
                                          to_char(v_Trans_Templ.dt_acc_def_rule_id);
            END IF;
          END IF;
        END IF;
        --счет по кредиту
        IF v_Trans_Templ.Ct_Account_Id IS NOT NULL
        THEN
          --Указан конкретный счет
          v_Trans.Ct_Account_Id := v_trans_templ.Ct_account_id;
          SELECT * INTO v_Account FROM Account a WHERE a.account_id = v_trans_templ.ct_account_id;
          --Если план счетов счета не идентичен плану счетов проводки,
          --то найти счет по маске
          IF v_Trans_Templ.Acc_Chart_Type_ID <> v_Account.Acc_Chart_Type_Id
          THEN
            v_Trans.Ct_Account_Id := acc.Get_Account_By_Mask(v_Trans.Ct_Account_Id
                                                            ,v_Account.Acc_Chart_Type_Id
                                                            ,v_Trans_Templ.Acc_Chart_Type_ID);
            IF v_Trans.Ct_Account_Id IS NULL
            THEN
              BEGIN
                SELECT act.name
                  INTO v_Temp_Str_1
                  FROM Acc_Chart_Type act
                 WHERE act.acc_chart_type_id = v_Trans_Templ.Acc_Chart_Type_ID;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_1 := '<неизвестный>';
              END;
              v_Trans_Err.Trans_Err_Id := 1;
              v_Trans_Err.Ct_Account   := 'Счет ' || v_Account.Num || ', ИД=' ||
                                          to_char(v_Account.Account_Id) ||
                                          ', приведенный к плану счетов ' || v_Temp_Str_1 || ', ИД=' ||
                                          to_char(v_Trans_Templ.Acc_Chart_Type_ID);
            END IF;
          END IF;
        ELSE
          IF v_Trans_Templ.Ct_Acc_Type_Templ_Id IS NOT NULL
          THEN
            v_Trans.Ct_Account_Id := acc.Get_Acc_By_Acc_Type(v_Trans_Templ.Ct_Acc_Type_Templ_Id
                                                            ,v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id
                                                            ,v_Settlement_Scheme_ID
                                                            ,v_Document_ID);
            IF v_Trans.Ct_Account_Id IS NULL
            THEN
              BEGIN
                SELECT att.name
                  INTO v_Temp_Str_1
                  FROM Acc_Type_Templ att
                 WHERE att.acc_type_templ_id = v_Trans_Templ.Ct_Acc_Type_Templ_Id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_1 := '<неизвестный>';
              END;
              BEGIN
                SELECT act.name
                  INTO v_Temp_Str_2
                  FROM Acc_Chart_Type act
                 WHERE act.acc_chart_type_id = v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_2 := '<неизвестный>';
              END;
              v_Trans_Err.Trans_Err_Id := 1;
              v_Trans_Err.Ct_Account   := 'Тип счета ' || v_Temp_Str_1 || ', ИД=' ||
                                          to_char(v_Trans_Templ.Ct_Acc_Type_Templ_Id) ||
                                          ', по плану счетов ' || v_Temp_Str_2 || ', ИД=' ||
                                          to_char(v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id);
            ELSE
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_Trans_Templ.Acc_Chart_Type_ID <> v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id
              THEN
                v_Trans.Ct_Account_Id := acc.Get_Account_By_Mask(v_Trans.Ct_Account_Id
                                                                ,v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id
                                                                ,v_Trans_Templ.Acc_Chart_Type_ID);
                IF v_Trans.Ct_Account_Id IS NULL
                THEN
                  BEGIN
                    SELECT att.name
                      INTO v_Temp_Str_1
                      FROM Acc_Type_Templ att
                     WHERE att.acc_type_templ_id = v_Trans_Templ.Ct_Acc_Type_Templ_Id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_Temp_Str_2
                      FROM Acc_Chart_Type act
                     WHERE act.acc_chart_type_id = v_Trans_Templ.Acc_Chart_Type_ID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_2 := '<неизвестный>';
                  END;
                  v_Trans_Err.Trans_Err_Id := 1;
                  v_Trans_Err.Ct_Account   := 'Тип счета ' || v_Temp_Str_1 || ', ИД=' ||
                                              to_char(v_Trans_Templ.Dt_Acc_Type_Templ_Id) ||
                                              ', приведенный к плану счетов ' || v_Temp_Str_2 ||
                                              ', ИД=' || to_char(v_Trans_Templ.Acc_Chart_Type_ID);
                END IF;
              END IF;
            END IF;
          ELSE
            IF v_Trans_Templ.Ct_Uro_Id IS NOT NULL
            THEN
              --В МОС подставляется конкретный объект
              v_Trans.Ct_Account_Id := acc.Get_Acc_By_Acc_Def_Rule(v_Trans_Templ.Ct_acc_def_rule_id
                                                                  ,v_Trans_Templ.Ct_ure_id
                                                                  ,v_Trans_Templ.Ct_uro_id
                                                                  ,v_Trans.Acc_fund_id
                                                                  ,v_Trans.Trans_Date
                                                                  ,v_document_id);
            ELSE
              --В МОС подставляется документ
              v_Trans.Ct_Account_Id := acc.Get_Acc_By_Acc_Def_Rule(v_Trans_Templ.Ct_acc_def_rule_id
                                                                  ,NULL
                                                                  ,v_document_id
                                                                  ,v_Trans.Acc_fund_id
                                                                  ,v_Trans.Trans_Date
                                                                  ,v_document_id);
            END IF;
            IF v_Trans.Ct_Account_Id IS NOT NULL
            THEN
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_Trans_Templ.Acc_Chart_Type_ID <> v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id
              THEN
                v_Trans.Ct_Account_Id := acc.Get_Account_By_Mask(v_Trans.Ct_Account_Id
                                                                ,v_Trans_Templ.Ct_Rev_Acc_Chart_Type_Id
                                                                ,v_Trans_Templ.Acc_Chart_Type_ID);
                IF v_Trans.Ct_Account_Id IS NULL
                THEN
                  BEGIN
                    SELECT adr.name
                      INTO v_Temp_Str_1
                      FROM Acc_Def_Rule adr
                     WHERE adr.acc_def_rule_id = v_Trans_Templ.ct_acc_def_rule_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_Temp_Str_2
                      FROM Acc_Chart_Type act
                     WHERE act.acc_chart_type_id = v_Trans_Templ.Acc_Chart_Type_ID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_Temp_Str_2 := '<неизвестный>';
                  END;
                  v_Trans_Err.Trans_Err_Id := 1;
                  v_Trans_Err.Ct_Account   := 'Счет по М.О.С. ' || v_Temp_Str_1 || ', ИД=' ||
                                              to_char(v_Trans_Templ.Ct_Acc_Type_Templ_Id) ||
                                              ', приведенный к плану счетов ' || v_Temp_Str_2 ||
                                              ', ИД=' || to_char(v_Trans_Templ.Acc_Chart_Type_ID);
                END IF;
              END IF;
            ELSE
              BEGIN
                SELECT adr.name
                  INTO v_Temp_Str_1
                  FROM Acc_Def_Rule adr
                 WHERE adr.acc_def_rule_id = v_Trans_Templ.ct_acc_def_rule_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_Temp_Str_1 := '<неизвестный>';
              END;
              v_Trans_Err.Trans_Err_Id := 1;
              v_Trans_Err.Ct_Account   := 'М.О.С. ' || v_Temp_Str_1 || ', ИД=' ||
                                          to_char(v_Trans_Templ.ct_acc_def_rule_id);
            END IF;
          END IF;
        END IF;
      END IF;
    
      --Проверка на равенства счета дебета и кредита
      IF (v_Trans_Err.Trans_Err_Id = 0)
      THEN
        IF (v_Trans.Dt_Account_Id = v_Trans.Ct_Account_Id)
        THEN
          SELECT a.num INTO v_Temp_Str_1 FROM Account a WHERE a.account_id = v_Trans.Dt_Account_Id;
          v_Trans_Err.Trans_Err_Id := 1;
          v_Trans_Err.Dt_Account   := 'Одинаковые счета по ДТ/КТ №' || v_Temp_Str_1 || ', ИД=' ||
                                      to_char(v_Trans.Dt_Account_Id);
          v_Trans_Err.Ct_Account   := 'Одинаковые счета по ДТ/КТ №' || v_Temp_Str_1 || ', ИД=' ||
                                      to_char(v_Trans.Dt_Account_Id);
        END IF;
      END IF;
    
      IF (v_Trans_Err.Trans_Err_Id = 0)
      THEN
        --Определение аналитик по счетам
        SELECT * INTO v_Dt_Account FROM Account a WHERE a.account_id = v_Trans.Dt_Account_Id;
        SELECT * INTO v_Ct_Account FROM Account a WHERE a.account_id = v_Trans.Ct_Account_Id;
        OPEN c_An;
        LOOP
          FETCH c_An
            INTO v_An;
          EXIT WHEN c_An%NOTFOUND;
          BEGIN
            CASE
              WHEN v_An.corr = 'D'
                   AND v_An.a_num = '1' THEN
                IF (v_Dt_Account.A1_Uro_Id IS NULL)
                THEN
                  v_Trans.a1_dt_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id, 1);
                  v_Trans.a1_dt_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Dt_Account_Id
                                                                    ,1
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a1_dt_ure_id := v_Dt_Account.A1_Ure_Id;
                  v_Trans.a1_dt_uro_id := v_Dt_Account.A1_Uro_Id;
                END IF;
              WHEN v_An.corr = 'D'
                   AND v_An.a_num = '2' THEN
                IF (v_Dt_Account.A2_Uro_Id IS NULL)
                THEN
                  v_Trans.a2_dt_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id, 2);
                  v_Trans.a2_dt_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Dt_Account_Id
                                                                    ,2
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a2_dt_ure_id := v_Dt_Account.A2_Ure_Id;
                  v_Trans.a2_dt_uro_id := v_Dt_Account.A2_Uro_Id;
                END IF;
              WHEN v_An.corr = 'D'
                   AND v_An.a_num = '3' THEN
                IF (v_Dt_Account.A3_Uro_Id IS NULL)
                THEN
                  v_Trans.a3_dt_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id, 3);
                  v_Trans.a3_dt_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Dt_Account_Id
                                                                    ,3
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a3_dt_ure_id := v_Dt_Account.A3_Ure_Id;
                  v_Trans.a3_dt_uro_id := v_Dt_Account.A3_Uro_Id;
                END IF;
              WHEN v_An.corr = 'D'
                   AND v_An.a_num = '4' THEN
                IF (v_Dt_Account.A4_Uro_Id IS NULL)
                THEN
                  v_Trans.a4_dt_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id, 4);
                  v_Trans.a4_dt_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Dt_Account_Id
                                                                    ,4
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a4_dt_ure_id := v_Dt_Account.A4_Ure_Id;
                  v_Trans.a4_dt_uro_id := v_Dt_Account.A4_Uro_Id;
                END IF;
              WHEN v_An.corr = 'D'
                   AND v_An.a_num = '5' THEN
                IF (v_Dt_Account.A5_Uro_Id IS NULL)
                THEN
                  v_Trans.a5_dt_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id, 5);
                  v_Trans.a5_dt_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Dt_Account_Id
                                                                    ,5
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a5_dt_ure_id := v_Dt_Account.A5_Ure_Id;
                  v_Trans.a5_dt_uro_id := v_Dt_Account.A5_Uro_Id;
                END IF;
              WHEN v_An.corr = 'C'
                   AND v_An.a_num = '1' THEN
                IF (v_Ct_Account.A1_Uro_Id IS NULL)
                THEN
                  v_Trans.a1_Ct_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id, 1);
                  v_Trans.a1_Ct_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Ct_Account_Id
                                                                    ,1
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a1_Ct_ure_id := v_Ct_Account.A1_Ure_Id;
                  v_Trans.a1_Ct_uro_id := v_Ct_Account.A1_Uro_Id;
                END IF;
              WHEN v_An.corr = 'C'
                   AND v_An.a_num = '2' THEN
                IF (v_Ct_Account.A2_Uro_Id IS NULL)
                THEN
                  v_Trans.a2_Ct_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id, 2);
                  v_Trans.a2_Ct_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Ct_Account_Id
                                                                    ,2
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a2_Ct_ure_id := v_Ct_Account.A2_Ure_Id;
                  v_Trans.a2_Ct_uro_id := v_Ct_Account.A2_Uro_Id;
                END IF;
              WHEN v_An.corr = 'C'
                   AND v_An.a_num = '3' THEN
                IF (v_Ct_Account.A3_Uro_Id IS NULL)
                THEN
                  v_Trans.a3_Ct_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id, 3);
                  v_Trans.a3_Ct_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Ct_Account_Id
                                                                    ,3
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a3_Ct_ure_id := v_Ct_Account.A3_Ure_Id;
                  v_Trans.a3_Ct_uro_id := v_Ct_Account.A3_Uro_Id;
                END IF;
              WHEN v_An.corr = 'C'
                   AND v_An.a_num = '4' THEN
                IF (v_Ct_Account.A4_Uro_Id IS NULL)
                THEN
                  v_Trans.a4_Ct_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id, 4);
                  v_Trans.a4_Ct_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Ct_Account_Id
                                                                    ,4
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a4_Ct_ure_id := v_Ct_Account.A4_Ure_Id;
                  v_Trans.a4_Ct_uro_id := v_Ct_Account.A4_Uro_Id;
                END IF;
              WHEN v_An.corr = 'C'
                   AND v_An.a_num = '5' THEN
                IF (v_Ct_Account.A5_Uro_Id IS NULL)
                THEN
                  v_Trans.a5_Ct_ure_id := acc.Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id, 5);
                  v_Trans.a5_Ct_uro_id := acc.Get_Analytic_Object_ID(v_Trans.Ct_Account_Id
                                                                    ,5
                                                                    ,v_Document_ID);
                ELSE
                  v_Trans.a5_Ct_ure_id := v_Ct_Account.A5_Ure_Id;
                  v_Trans.a5_Ct_uro_id := v_Ct_Account.A5_Uro_Id;
                END IF;
            END CASE;
          EXCEPTION
            WHEN OTHERS THEN
              dbms_output.put_line(SQLERRM);
          END;
        END LOOP;
        CLOSE c_An;
      END IF;
    END IF;
  
    IF (v_Trans_Err.Trans_Err_Id = 0)
    THEN
      INSERT INTO Trans t
        (t.trans_id
        , --ok
         t.trans_date
        , --ok
         t.trans_fund_id
        , --ok
         t.trans_amount
        , --ok
         t.dt_account_id
        , --ok
         t.ct_account_id
        , --ok
         t.is_accepted
        , --ok
         t.a1_dt_ure_id
        ,t.a1_dt_uro_id
        ,t.a1_ct_ure_id
        ,t.a1_ct_uro_id
        ,t.a2_dt_ure_id
        ,t.a2_dt_uro_id
        ,t.a2_ct_ure_id
        ,t.a2_ct_uro_id
        ,t.a3_dt_ure_id
        ,t.a3_dt_uro_id
        ,t.a3_ct_ure_id
        ,t.a3_ct_uro_id
        ,t.a4_dt_ure_id
        ,t.a4_dt_uro_id
        ,t.a4_ct_ure_id
        ,t.a4_ct_uro_id
        ,t.a5_dt_ure_id
        ,t.a5_dt_uro_id
        ,t.a5_ct_ure_id
        ,t.a5_ct_uro_id
        ,t.trans_templ_id
        , --ok
         t.acc_chart_type_id
        , --ok
         t.acc_fund_id
        , --ok
         t.acc_amount
        , --ok
         t.acc_rate
        , --ok
         t.Oper_ID
        , --ok
         t.Trans_Quantity
        ,t.Source
        ,t.Note)
      VALUES
        (v_Trans.Trans_id
        , --ok
         v_Trans.trans_date
        , --ok
         v_Trans.trans_fund_id
        , --ok
         v_Trans.trans_amount
        , --ok
         v_Trans.dt_account_id
        , --ok
         v_Trans.ct_account_id
        , --ok
         v_Trans_Templ.is_accepted
        , --ok
         v_Trans.a1_dt_ure_id
        ,v_Trans.a1_dt_uro_id
        ,v_Trans.a1_ct_ure_id
        ,v_Trans.a1_ct_uro_id
        ,v_Trans.a2_dt_ure_id
        ,v_Trans.a2_dt_uro_id
        ,v_Trans.a2_ct_ure_id
        ,v_Trans.a2_ct_uro_id
        ,v_Trans.a3_dt_ure_id
        ,v_Trans.a3_dt_uro_id
        ,v_Trans.a3_ct_ure_id
        ,v_Trans.a3_ct_uro_id
        ,v_Trans.a4_dt_ure_id
        ,v_Trans.a4_dt_uro_id
        ,v_Trans.a4_ct_ure_id
        ,v_Trans.a4_ct_uro_id
        ,v_Trans.a5_dt_ure_id
        ,v_Trans.a5_dt_uro_id
        ,v_Trans.a5_ct_ure_id
        ,v_Trans.a5_ct_uro_id
        ,p_Trans_Templ_ID
        , --ok
         v_Trans_Templ.acc_chart_type_id
        , --ok
         v_Trans.acc_fund_id
        , --ok
         v_Trans.acc_amount
        , --ok
         v_Trans.acc_rate
        , --ok
         p_Oper_ID
        , --ok
         nvl(v_Trans.Trans_Quantity, 0)
        ,p_Source
        ,Acc.Get_Trans_Note(p_Trans_Templ_ID, p_Oper_ID));
    ELSE
      INSERT INTO Trans_Err te
        (te.Trans_Err_Id
        ,te.Oper_Id
        ,te.Trans
        ,te.Trans_Templ
        ,te.Trans_Date
        ,te.Acc_Fund
        ,te.Recalc_Fund
        ,te.Acc_Amount
        ,te.Base_Fund
        ,te.Rate_Type
        ,te.Dt_Account
        ,te.Ct_Account
        ,te.Source)
      VALUES
        (sq_trans_err.nextval
        ,p_Oper_ID
        ,v_Trans_Err.Trans
        ,v_Trans_Err.Trans_Templ
        ,v_Trans_Err.Trans_Date
        ,v_Trans_Err.Acc_Fund
        ,v_Trans_Err.Recalc_Fund
        ,v_Trans_Err.Acc_Amount
        ,v_Trans_Err.Base_Fund
        ,v_Trans_Err.Rate_Type
        ,v_Trans_Err.Dt_Account
        ,v_Trans_Err.Ct_Account
        ,p_Source);
    END IF;
  
    RETURN v_Trans.Trans_id;
  END;

  --Функция для создания операции по шаблону
  FUNCTION Run_Oper_By_Template
  (
    p_Oper_Templ_ID     NUMBER
   ,p_Document_ID       NUMBER
   ,p_Doc_Status_Ref_ID NUMBER DEFAULT NULL
   ,p_is_accepted       NUMBER DEFAULT 1
   ,p_Source            VARCHAR2 DEFAULT 'TRS'
  ) RETURN NUMBER IS
    v_Oper_ID           NUMBER;
    v_Doc_Status_Ref_ID NUMBER;
    v_Trans_Templ_ID    NUMBER;
    v_Trans_ID          trans%ROWTYPE;
    v_Parent_ID         NUMBER;
    v_sql               VARCHAR2(4000);
    c_sum_type          SYS_REFCURSOR;
    v_st_date           DATE;
    v_st_summ           NUMBER;
    v_Level             NUMBER;
    v_Trans_Err         Trans_Err%ROWTYPE;
    CURSOR c_Rel_Oper_Trans_Templ(cp_Oper_Templ_ID NUMBER) IS
      SELECT LEVEL        x_level
            ,tt.id        id
            ,tt.Parent_ID Parent_ID
        FROM (SELECT NULL parent_id
                    ,0    id
                FROM oper_templ ot
               WHERE ot.oper_templ_id = cp_Oper_Templ_ID
              UNION ALL
              SELECT DISTINCT nvl(rott.parent_id, 0) parent_id
                             ,rott.trans_templ_id id
                FROM Rel_Oper_Trans_Templ rott
               WHERE rott.oper_templ_id = cp_Oper_Templ_ID) tt
       START WITH tt.parent_id IS NULL
      CONNECT BY PRIOR tt.id = tt.parent_id;
    v_Document   document%ROWTYPE;
    v_Temp_Str_1 VARCHAR2(150);
    /*    cursor c_Trans is
    select t.*
      from Trans t, Oper o, Trans_Templ tt
     where t.oper_id = o.oper_id
       and o.document_id = p_Document_id
       and o.oper_templ_id = p_Oper_Templ_ID
       and o.doc_status_ref_id = p_Doc_Status_Ref_ID
       and t.trans_templ_id = tt.trans_templ_id
       and tt.is_export = 1;*/
  BEGIN
    v_Doc_Status_Ref_ID := nvl(p_Doc_Status_Ref_ID, doc.get_doc_status_id(p_Document_ID));
    BEGIN
    
      /*    --Удалить выгруженные проводки из АБС
          open c_Trans;
          loop
            fetch c_Trans into v_Trans_ID;
            exit when c_Trans%notfound;
            --oper day
            if pkg_oper_day.get_date_status(v_Trans_ID.Trans_Date)=0 then
              macrobank_conv.Delete_Doc(v_Trans_ID.Trans_Id);
            end if;
            --oper day
      
                  --macrobank_conv.Delete_Doc(v_Trans_ID);
          end loop;
          close c_Trans;
          commit;
      */
      --Удалить операцию
      BEGIN
        DELETE Oper o
         WHERE o.Document_Id = p_Document_ID
           AND o.oper_templ_id = p_Oper_Templ_ID
           AND o.doc_status_ref_id = v_Doc_Status_Ref_ID;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
      END;
    
      SELECT * INTO v_Document FROM Document d WHERE d.document_id = p_Document_ID;
      --Создать операцию по шаблону
      SELECT sq_Oper.Nextval INTO v_Oper_ID FROM dual;
      INSERT INTO Oper o
        (o.Oper_Id
        ,o.Name
        ,o.Oper_Templ_Id
        ,o.Document_Id
        ,o.Reg_Date
        ,o.Oper_Date
        ,o.Doc_Status_Ref_ID)
      VALUES
        (v_Oper_ID
        ,(SELECT ot.Name FROM Oper_Templ ot WHERE ot.oper_templ_id = p_Oper_Templ_ID)
        ,p_Oper_Templ_ID
        ,p_Document_ID
        ,SYSDATE
        ,doc.get_date_type(p_Document_ID
                          ,(SELECT ot.date_type_id
                             FROM Oper_Templ ot
                            WHERE ot.oper_templ_id = p_Oper_Templ_ID))
        ,v_Doc_Status_Ref_ID);
      --Создать проводки по шаблону операции
      OPEN c_Rel_Oper_Trans_Templ(p_Oper_Templ_ID);
      LOOP
        v_Trans_Err.Trans_Err_Id := 0;
        v_Trans_Err.Trans        := NULL;
        v_Trans_Err.Trans_Templ  := NULL;
        v_Trans_Err.Trans_Date   := NULL;
        v_Trans_Err.Acc_Fund     := NULL;
        v_Trans_Err.Recalc_Fund  := NULL;
        v_Trans_Err.Acc_Amount   := NULL;
        v_Trans_Err.Base_Fund    := NULL;
        v_Trans_Err.Rate_Type    := NULL;
        v_Trans_Err.Dt_Account   := NULL;
        v_Trans_Err.Ct_Account   := NULL;
        FETCH c_Rel_Oper_Trans_Templ
          INTO v_Level
              ,v_Trans_Templ_ID
              ,v_Parent_ID;
        EXIT WHEN c_Rel_Oper_Trans_Templ%NOTFOUND;
        --      dbms_output.put_line('Шаблон проводочки!');
      
        IF v_Level >= 2
        THEN
          IF v_Level > 2
          THEN
            BEGIN
              SELECT t.*
                INTO v_Trans_ID
                FROM Trans t
               WHERE t.oper_id = v_Oper_ID
                 AND t.trans_templ_id = v_Parent_ID;
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  SELECT tt.name
                    INTO v_Temp_Str_1
                    FROM Trans_Templ tt
                   WHERE tt.trans_templ_id = v_Parent_ID;
                EXCEPTION
                  WHEN OTHERS THEN
                    v_Temp_Str_1 := '<неизвестный>';
                END;
                v_Trans_Err.Trans_Err_Id := 1;
                v_Trans_Err.Trans        := 'Не найдена исходная проводка по шаблону ' || v_Temp_Str_1 ||
                                            ', ИД=' || to_Char(v_Parent_ID);
                BEGIN
                  SELECT tt.name
                    INTO v_Temp_Str_1
                    FROM Trans_Templ tt
                   WHERE tt.trans_templ_id = v_Trans_Templ_ID;
                EXCEPTION
                  WHEN OTHERS THEN
                    v_Temp_Str_1 := '<неизвестный>';
                END;
                v_Trans_Err.Trans_Templ := v_Temp_Str_1 || ', ИД=' || to_Char(v_Parent_ID);
            END;
          END IF;
        
          IF (v_Trans_Err.Trans_Err_Id = 0)
          THEN
            SELECT st.sql_query
              INTO v_sql
              FROM trans_templ tt
                  ,summ_type   st
             WHERE tt.trans_templ_id = v_Trans_Templ_ID
               AND tt.summ_type_id = st.summ_type_id;
            IF v_sql IS NULL
            THEN
              v_Trans_ID.Trans_Id := acc.Add_Trans_By_Template(v_Trans_Templ_ID
                                                              ,v_Oper_ID
                                                              ,p_is_accepted
                                                              ,NULL
                                                              ,NULL
                                                              ,NULL
                                                              ,p_Source);
            ELSE
              OPEN c_sum_type FOR v_sql
                USING IN p_Document_ID;
              LOOP
                FETCH c_sum_type
                  INTO v_st_date
                      ,v_st_summ;
                EXIT WHEN c_sum_type%NOTFOUND;
                v_Trans_ID.Trans_Id := acc.Add_Trans_By_Template(v_Trans_Templ_ID
                                                                ,v_Oper_ID
                                                                ,p_is_accepted
                                                                ,v_st_date
                                                                ,v_st_summ
                                                                ,NULL
                                                                ,p_Source);
              END LOOP;
              CLOSE c_sum_type;
            END IF;
          ELSE
            INSERT INTO Trans_Err te
              (te.Trans_Err_Id, te.Oper_Id, te.Trans, te.Trans_Templ, te.Source)
            VALUES
              (sq_trans_err.nextval, v_Oper_ID, v_Trans_Err.Trans, v_Trans_Err.Trans_Templ, p_Source);
          END IF;
        END IF;
      
      END LOOP;
      CLOSE c_Rel_Oper_Trans_Templ;
    EXCEPTION
      WHEN OTHERS THEN
        v_Oper_ID := 0;
    END;
  
    COMMIT;
  
    /*  --Произвести выгрузку в АБС
      open c_Trans;
      loop
        fetch c_Trans into v_Trans_ID;
        exit when c_Trans%notfound;
        --oper day
        if pkg_oper_day.get_date_status( v_Trans_ID.Trans_Date)=0 then
          macrobank_conv.Create_Doc(v_Trans_ID.Trans_Id);
        end if;
        --oper day
    
        --macrobank_conv.Create_Doc(v_Trans_ID.Trans_Id);
      end loop;
      close c_Trans;
    */
  
    RETURN v_Oper_ID;
  END;

  --Функция для расчета курса валюты
  FUNCTION Get_Rate_By_ID
  (
    p_Rate_Type_ID NUMBER
   ,p_Fund_ID      NUMBER
   ,p_Date         DATE
  ) RETURN NUMBER IS
    v_Rate NUMBER;
  BEGIN
    BEGIN
      /*
      Дэн, позырь че за хрень тут написана
      я убрал Rate_Type rt из запросов
      и r.rate_type_id = rt.rate_type_id (ибо оно дублировалось)
      но все равно не понимаю нафига тут юнион алл
      
      
            select rate_value
            into v_Rate
            from (select r.rate_value
                    from Rate r, Rate_Type rt
                   where r.rate_type_id = rt.rate_type_id
                     and r.contra_fund_id = p_Fund_ID
                     and r.rate_type_id = p_Rate_Type_ID
                     and r.Rate_Date =
                         (select max(rs.Rate_Date)
                            from Rate rs
                           where rs.rate_type_id = rt.rate_type_id
                             and rs.contra_fund_id = p_Fund_ID
                             and rs.rate_type_id = p_Rate_Type_ID
                             and rs.rate_date <= p_Date)
                  union all
                  select 1
                    from Rate_Type r
                   where r.rate_type_id = p_Rate_Type_ID
                     and r.base_fund_id = p_Fund_ID);
      */
      SELECT rate_value
        INTO v_Rate
        FROM (SELECT r.rate_value
                FROM Rate r
               WHERE r.contra_fund_id = p_Fund_ID
                 AND r.rate_type_id = p_Rate_Type_ID
                 AND r.Rate_Date = (SELECT MAX(rs.Rate_Date)
                                      FROM Rate rs
                                     WHERE rs.contra_fund_id = p_Fund_ID
                                       AND rs.rate_type_id = p_Rate_Type_ID
                                       AND rs.rate_date <= p_Date)
              UNION ALL
              SELECT 1
                FROM Rate_Type r
               WHERE r.rate_type_id = p_Rate_Type_ID
                 AND r.base_fund_id = p_Fund_ID);
    
    EXCEPTION
      WHEN OTHERS THEN
        v_Rate := 0;
    END;
    RETURN v_Rate;
  END;

  FUNCTION Get_Cross_Rate_By_Brief
  (
    p_Rate_Type_Id   IN NUMBER
   ,p_Fund_Brief_In  IN VARCHAR2
   ,p_Fund_Brief_Out IN VARCHAR2
   ,p_Date           IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER IS
    v_fund_in  NUMBER;
    v_fund_out NUMBER;
  
  BEGIN
    SELECT fin.fund_id
          ,fout.fund_id
      INTO v_fund_in
          ,v_fund_out
      FROM fund fin
          ,fund fout
     WHERE fin.brief = p_Fund_Brief_In
       AND fout.brief = p_Fund_Brief_Out;
  
    RETURN acc.Get_Cross_Rate_By_Id(p_Rate_Type_Id, v_fund_in, v_fund_out, p_Date);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --Получить кросс-курс между двумя валютами через тип курса
  FUNCTION Get_Cross_Rate_By_Id
  (
    p_Rate_Type_Id IN NUMBER
   ,p_Fund_Id_In   IN NUMBER
   ,p_Fund_Id_Out  IN NUMBER
   ,p_Date         IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER IS
    v_Rate NUMBER;
    v_R1   NUMBER;
    v_R2   NUMBER;
  BEGIN
    IF p_Fund_Id_In = p_Fund_Id_Out
    THEN
      v_Rate := 1;
    ELSE
      BEGIN
        v_R1   := Get_Rate_By_ID(p_Rate_Type_ID, p_fund_id_in, p_Date);
        v_R2   := Get_Rate_By_ID(p_Rate_Type_ID, p_fund_id_out, p_Date);
        v_Rate := v_R1 / v_R2;
      EXCEPTION
        WHEN OTHERS THEN
          v_Rate := 1;
      END;
    END IF;
    RETURN v_Rate;
  END;

  --Функция для расчета курса валюты (по сокращению типа курса и валюты)
  FUNCTION Get_Rate_By_Brief
  (
    p_Rate_Type_Brief VARCHAR2
   ,p_Fund_Brief      VARCHAR2
   ,p_Date            DATE
  ) RETURN NUMBER IS
    v_Rate_Type_ID NUMBER;
    v_Fund_ID      NUMBER;
    v_Rate         NUMBER;
  BEGIN
    BEGIN
      SELECT rt.rate_type_id INTO v_Rate_type_ID FROM Rate_Type rt WHERE rt.brief = p_Rate_Type_Brief;
      SELECT f.fund_id INTO v_Fund_ID FROM Fund f WHERE f.brief = p_Fund_Brief;
      v_Rate := acc.Get_Rate_By_ID(v_Rate_Type_ID, v_Fund_ID, p_Date);
    EXCEPTION
      WHEN OTHERS THEN
        v_Rate := 0;
    END;
    RETURN v_Rate;
  END;

  --Получить сущность аналитики заданного уровня по счету
  FUNCTION Get_Analytic_Entity_ID
  (
    p_Account_ID NUMBER
   ,p_An_Num     NUMBER
  ) RETURN NUMBER IS
    v_Entity_ID NUMBER;
  BEGIN
    BEGIN
      SELECT aty.analytic_ent_id
        INTO v_Entity_id
        FROM account       a
            ,analytic_type aty
       WHERE (a.account_id = p_Account_ID)
         AND (((p_An_Num = 1) AND (a.a1_analytic_type_id = aty.analytic_type_id)) OR
             ((p_An_Num = 2) AND (a.a2_analytic_type_id = aty.analytic_type_id)) OR
             ((p_An_Num = 3) AND (a.a3_analytic_type_id = aty.analytic_type_id)) OR
             ((p_An_Num = 4) AND (a.a4_analytic_type_id = aty.analytic_type_id)) OR
             ((p_An_Num = 5) AND (a.a5_analytic_type_id = aty.analytic_type_id)));
    
    EXCEPTION
      WHEN OTHERS THEN
        v_Entity_ID := NULL;
    END;
    RETURN v_Entity_ID;
  END;

  --Получить ИД аналитики заданного уровня по счету
  FUNCTION Get_Analytic_Object_ID
  (
    p_Account_ID  NUMBER
   ,p_An_Num      NUMBER
   ,p_Document_ID NUMBER
  ) RETURN NUMBER IS
    v_Object_ID  NUMBER;
    v_An_Type_ID NUMBER;
  BEGIN
    BEGIN
      SELECT CASE
               WHEN p_An_Num = 1 THEN
                a.a1_analytic_type_id
               WHEN p_An_Num = 2 THEN
                a.a2_analytic_type_id
               WHEN p_An_Num = 3 THEN
                a.a3_analytic_type_id
               WHEN p_An_Num = 4 THEN
                a.a4_analytic_type_id
               WHEN p_An_Num = 5 THEN
                a.a5_analytic_type_id
               ELSE
                0
             END
        INTO v_An_Type_id
        FROM account a
       WHERE a.account_id = p_Account_ID;
      --    dbms_output.put_line('An_Type = ' || to_char(v_An_Type_id));
      v_Object_ID := doc.get_an_type(p_Document_ID, v_An_Type_ID);
    EXCEPTION
      WHEN OTHERS THEN
        v_Object_ID := NULL;
    END;
    RETURN v_Object_ID;
  END;

  --Остатки и обороты по счету за период
  FUNCTION Get_Acc_Turn_Rest
  (
    p_Account_ID NUMBER
   ,p_Fund_ID    NUMBER
   ,p_Start_Date DATE DEFAULT SYSDATE
   ,p_End_Date   DATE DEFAULT SYSDATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A1_nulls   NUMBER DEFAULT 0
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A2_nulls   NUMBER DEFAULT 0
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A3_nulls   NUMBER DEFAULT 0
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A4_nulls   NUMBER DEFAULT 0
   ,p_A5_ID      NUMBER DEFAULT NULL
   ,p_A5_nulls   NUMBER DEFAULT 0
  ) RETURN t_Turn_Rest IS
    v_Turn_Rest                t_Turn_Rest;
    v_Account                  Account%ROWTYPE;
    v_Base_Fund_ID             NUMBER;
    v_Temp_Dt_Amount_Fund      NUMBER;
    v_Temp_Dt_Amount_Base_Fund NUMBER;
    v_Temp_Dt_Amount_Qty       NUMBER;
    v_Temp_Ct_Amount_Fund      NUMBER;
    v_Temp_Ct_Amount_Base_Fund NUMBER;
    v_Temp_Ct_Amount_Qty       NUMBER;
  BEGIN
    BEGIN
      --описание счета
      SELECT * INTO v_Account FROM Account a WHERE a.account_id = p_Account_ID;
      --базовая валюта плана счетов
      SELECT act.base_fund_id
        INTO v_Base_Fund_ID
        FROM Acc_Chart_Type act
       WHERE act.acc_chart_type_id = v_Account.Acc_Chart_Type_Id;
      --расчет входящего остатка по дебету
      SELECT nvl(SUM(t.acc_amount), 0)
            ,nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.trans_quantity), 0)
        INTO v_Temp_Dt_Amount_Fund
            ,v_Temp_Dt_Amount_Base_Fund
            ,v_Temp_Dt_Amount_Qty
        FROM Trans t
       WHERE t.dt_account_id = v_Account.Account_ID
         AND t.trans_date < p_Start_Date
         AND t.acc_fund_id = p_Fund_ID
         AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
             ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_dt_uro_id IS NULL)) OR
             ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_dt_uro_id)))
         AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
             ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_dt_uro_id IS NULL)) OR
             ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_dt_uro_id)))
         AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
             ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_dt_uro_id IS NULL)) OR
             ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_dt_uro_id)))
         AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
             ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_dt_uro_id IS NULL)) OR
             ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_dt_uro_id)))
         AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
             ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_dt_uro_id IS NULL)) OR
             ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_dt_uro_id)));
      --расчет входящего остатка по кредиту
      SELECT nvl(SUM(t.acc_amount), 0)
            ,nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.trans_quantity), 0)
        INTO v_Temp_Ct_Amount_Fund
            ,v_Temp_Ct_Amount_Base_Fund
            ,v_Temp_Ct_Amount_Qty
        FROM Trans t
       WHERE t.ct_account_id = v_Account.Account_ID
         AND t.trans_date < p_Start_Date
         AND t.acc_fund_id = p_Fund_ID
         AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
             ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_ct_uro_id IS NULL)) OR
             ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_ct_uro_id)))
         AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
             ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_ct_uro_id IS NULL)) OR
             ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_ct_uro_id)))
         AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
             ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_ct_uro_id IS NULL)) OR
             ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_ct_uro_id)))
         AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
             ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_ct_uro_id IS NULL)) OR
             ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_ct_uro_id)))
         AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
             ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_ct_uro_id IS NULL)) OR
             ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_ct_uro_id)));
      --подсчет входящего остатка
      v_Turn_Rest.Rest_In_Fund := v_Temp_Dt_Amount_Fund - v_Temp_Ct_Amount_Fund;
      IF (v_Turn_Rest.Rest_In_Fund > 0)
      THEN
        v_Turn_Rest.Rest_In_Fund_Type := 'Д';
      ELSE
        IF (v_Turn_Rest.Rest_In_Fund < 0)
        THEN
          v_Turn_Rest.Rest_In_Fund_Type := 'К';
        ELSE
          v_Turn_Rest.Rest_In_Fund_Type := '';
        END IF;
      END IF;
      v_Turn_Rest.Rest_In_Base_Fund := v_Temp_Dt_Amount_Base_Fund - v_Temp_Ct_Amount_Base_Fund;
      IF (v_Turn_Rest.Rest_In_Base_Fund > 0)
      THEN
        v_Turn_Rest.Rest_In_Base_Fund_Type := 'Д';
      ELSE
        IF (v_Turn_Rest.Rest_In_Base_Fund < 0)
        THEN
          v_Turn_Rest.Rest_In_Base_Fund_Type := 'К';
        ELSE
          v_Turn_Rest.Rest_In_Base_Fund_Type := '';
        END IF;
      END IF;
      v_Turn_Rest.Rest_In_Qty := v_Temp_Dt_Amount_Qty - v_Temp_Ct_Amount_Qty;
      IF (v_Turn_Rest.Rest_In_Qty > 0)
      THEN
        v_Turn_Rest.Rest_In_Qty_Type := 'Д';
      ELSE
        IF (v_Turn_Rest.Rest_In_Qty < 0)
        THEN
          v_Turn_Rest.Rest_In_Qty_Type := 'К';
        ELSE
          v_Turn_Rest.Rest_In_Qty_Type := '';
        END IF;
      END IF;
    
      --расчет оборота по дебету
      SELECT nvl(SUM(t.acc_amount), 0)
            ,nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.trans_quantity), 0)
        INTO v_Turn_Rest.Turn_Dt_Fund
            ,v_Turn_Rest.Turn_Dt_Base_Fund
            ,v_Turn_Rest.Turn_Dt_Qty
        FROM Trans t
       WHERE t.dt_account_id = v_Account.Account_Id
         AND t.trans_date >= p_Start_Date
         AND t.trans_date <= p_End_Date
         AND p_Fund_ID = t.acc_fund_id
         AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
             ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_dt_uro_id IS NULL)) OR
             ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_dt_uro_id)))
         AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
             ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_dt_uro_id IS NULL)) OR
             ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_dt_uro_id)))
         AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
             ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_dt_uro_id IS NULL)) OR
             ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_dt_uro_id)))
         AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
             ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_dt_uro_id IS NULL)) OR
             ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_dt_uro_id)))
         AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
             ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_dt_uro_id IS NULL)) OR
             ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_dt_uro_id)));
      --расчет оборота по кредиту
      SELECT nvl(SUM(t.acc_amount), 0)
            ,nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.trans_quantity), 0)
        INTO v_Turn_Rest.Turn_Ct_Fund
            ,v_Turn_Rest.Turn_Ct_Base_Fund
            ,v_Turn_Rest.Turn_Ct_Qty
        FROM Trans t
       WHERE t.ct_account_id = v_Account.Account_Id
         AND t.trans_date >= p_Start_Date
         AND t.trans_date <= p_End_Date
         AND p_Fund_ID = t.acc_fund_id
         AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
             ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_ct_uro_id IS NULL)) OR
             ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_ct_uro_id)))
         AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
             ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_ct_uro_id IS NULL)) OR
             ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_ct_uro_id)))
         AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
             ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_ct_uro_id IS NULL)) OR
             ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_ct_uro_id)))
         AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
             ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_ct_uro_id IS NULL)) OR
             ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_ct_uro_id)))
         AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
             ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_ct_uro_id IS NULL)) OR
             ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_ct_uro_id)));
    
      --подсчет исходящего остатка
      v_Turn_Rest.Rest_Out_Fund := v_Turn_Rest.Rest_In_Fund + v_Turn_Rest.Turn_Dt_Fund -
                                   v_Turn_Rest.Turn_Ct_Fund;
      IF (v_Turn_Rest.Rest_Out_Fund > 0)
      THEN
        v_Turn_Rest.Rest_Out_Fund_Type := 'Д';
      ELSE
        IF (v_Turn_Rest.Rest_Out_Fund < 0)
        THEN
          v_Turn_Rest.Rest_Out_Fund_Type := 'К';
        ELSE
          v_Turn_Rest.Rest_Out_Fund_Type := '';
        END IF;
      END IF;
      v_Turn_Rest.Rest_In_Fund  := abs(v_Turn_Rest.Rest_In_Fund);
      v_Turn_Rest.Rest_Out_Fund := abs(v_Turn_Rest.Rest_Out_Fund);
    
      v_Turn_Rest.Rest_Out_Base_Fund := v_Turn_Rest.Rest_In_Base_Fund + v_Turn_Rest.Turn_Dt_Base_Fund -
                                        v_Turn_Rest.Turn_Ct_Base_Fund;
      IF (v_Turn_Rest.Rest_Out_Base_Fund > 0)
      THEN
        v_Turn_Rest.Rest_Out_Base_Fund_Type := 'Д';
      ELSE
        IF (v_Turn_Rest.Rest_Out_Base_Fund < 0)
        THEN
          v_Turn_Rest.Rest_Out_Base_Fund_Type := 'К';
        ELSE
          v_Turn_Rest.Rest_Out_Base_Fund_Type := '';
        END IF;
      END IF;
      v_Turn_Rest.Rest_In_Base_Fund  := abs(v_Turn_Rest.Rest_In_Base_Fund);
      v_Turn_Rest.Rest_Out_Base_Fund := abs(v_Turn_Rest.Rest_Out_Base_Fund);
    
      v_Turn_Rest.Rest_Out_Qty := v_Turn_Rest.Rest_In_Qty + v_Turn_Rest.Turn_Dt_Qty -
                                  v_Turn_Rest.Turn_Ct_Qty;
      IF (v_Turn_Rest.Rest_Out_Qty > 0)
      THEN
        v_Turn_Rest.Rest_Out_Qty_Type := 'Д';
      ELSE
        IF (v_Turn_Rest.Rest_Out_Qty < 0)
        THEN
          v_Turn_Rest.Rest_Out_Qty_Type := 'К';
        ELSE
          v_Turn_Rest.Rest_Out_Qty_Type := '';
        END IF;
      END IF;
      v_Turn_Rest.Rest_In_Qty  := abs(v_Turn_Rest.Rest_In_Qty);
      v_Turn_Rest.Rest_Out_Qty := abs(v_Turn_Rest.Rest_Out_Qty);
    
    EXCEPTION
      WHEN OTHERS THEN
        v_Turn_Rest.Rest_In_Fund            := 0.0;
        v_Turn_Rest.Rest_In_Base_Fund       := 0.0;
        v_Turn_Rest.Rest_In_Qty             := 0.0;
        v_Turn_Rest.Rest_In_Fund_Type       := '';
        v_Turn_Rest.Rest_In_Base_Fund_Type  := '';
        v_Turn_Rest.Rest_In_Qty_Type        := '';
        v_Turn_Rest.Turn_Dt_Fund            := 0.0;
        v_Turn_Rest.Turn_Dt_Base_Fund       := 0.0;
        v_Turn_Rest.Turn_Dt_Qty             := 0.0;
        v_Turn_Rest.Turn_Ct_Fund            := 0.0;
        v_Turn_Rest.Turn_Ct_Base_Fund       := 0.0;
        v_Turn_Rest.Turn_Ct_Qty             := 0.0;
        v_Turn_Rest.Rest_Out_Fund           := 0.0;
        v_Turn_Rest.Rest_Out_Base_Fund      := 0.0;
        v_Turn_Rest.Rest_Out_Qty            := 0.0;
        v_Turn_Rest.Rest_Out_Fund_Type      := '';
        v_Turn_Rest.Rest_Out_Base_Fund_Type := '';
        v_Turn_Rest.Rest_Out_Qty_Type       := '';
        dbms_output.put_line(SQLERRM);
    END;
    RETURN v_Turn_Rest;
  END;

  --Исходящий остаток по счету на дату
  FUNCTION Get_Acc_Rest
  (
    p_Account_ID NUMBER
   ,p_Fund_ID    NUMBER
   ,p_Date       DATE DEFAULT SYSDATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A1_nulls   NUMBER DEFAULT 0
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A2_nulls   NUMBER DEFAULT 0
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A3_nulls   NUMBER DEFAULT 0
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A4_nulls   NUMBER DEFAULT 0
   ,p_A5_ID      NUMBER DEFAULT NULL
   ,p_A5_nulls   NUMBER DEFAULT 0
  ) RETURN t_Rest IS
    v_Rest                     acc.t_Rest;
    v_Account                  Account%ROWTYPE;
    v_Base_Fund_ID             NUMBER;
    v_Temp_Dt_Amount_Fund      NUMBER;
    v_Temp_Dt_Amount_Base_Fund NUMBER;
    v_Temp_Dt_Amount_Qty       NUMBER;
    v_Temp_Ct_Amount_Fund      NUMBER;
    v_Temp_Ct_Amount_Base_Fund NUMBER;
    v_Temp_Ct_Amount_Qty       NUMBER;
  BEGIN
    v_Rest.Rest_Amount_Fund      := 0;
    v_Rest.Rest_Amount_Base_Fund := 0;
    v_Rest.Rest_Amount_Qty       := 0;
    v_Rest.Rest_Fund_Type        := '';
    v_Rest.Rest_Base_Fund_Type   := '';
    v_Rest.Rest_Qty_Type         := '';
    --описание счета
    SELECT * INTO v_Account FROM Account a WHERE a.account_id = p_Account_ID;
    --базовая валюта плана счетов
    SELECT act.base_fund_id
      INTO v_Base_Fund_ID
      FROM Acc_Chart_Type act
     WHERE act.acc_chart_type_id = v_Account.Acc_Chart_Type_Id;
    --расчет входящего остатка по дебету
    SELECT nvl(SUM(t.acc_amount), 0)
          ,nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.trans_quantity), 0)
      INTO v_Temp_Dt_Amount_Fund
          ,v_Temp_Dt_Amount_Base_Fund
          ,v_Temp_Dt_Amount_Qty
      FROM Trans t
     WHERE t.dt_account_id = v_Account.Account_ID
       AND t.trans_date <= p_Date
       AND t.acc_fund_id = p_Fund_ID
       AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
           ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_dt_uro_id IS NULL)) OR
           ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_dt_uro_id)))
       AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
           ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_dt_uro_id IS NULL)) OR
           ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_dt_uro_id)))
       AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
           ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_dt_uro_id IS NULL)) OR
           ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_dt_uro_id)))
       AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
           ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_dt_uro_id IS NULL)) OR
           ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_dt_uro_id)))
       AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
           ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_dt_uro_id IS NULL)) OR
           ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_dt_uro_id)));
    --расчет входящего остатка по кредиту
    SELECT nvl(SUM(t.acc_amount), 0)
          ,nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.trans_quantity), 0)
      INTO v_Temp_Ct_Amount_Fund
          ,v_Temp_Ct_Amount_Base_Fund
          ,v_Temp_Ct_Amount_Qty
      FROM Trans t
     WHERE t.ct_account_id = v_Account.Account_ID
       AND t.trans_date <= p_Date
       AND t.acc_fund_id = p_Fund_ID
       AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
           ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_ct_uro_id IS NULL)) OR
           ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_ct_uro_id)))
       AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
           ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_ct_uro_id IS NULL)) OR
           ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_ct_uro_id)))
       AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
           ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_ct_uro_id IS NULL)) OR
           ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_ct_uro_id)))
       AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
           ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_ct_uro_id IS NULL)) OR
           ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_ct_uro_id)))
       AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
           ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_ct_uro_id IS NULL)) OR
           ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_ct_uro_id)));
    --подсчет исходящего остатка
    v_Rest.Rest_Amount_Fund := v_Temp_Dt_Amount_Fund - v_Temp_Ct_Amount_Fund;
    IF (v_Rest.Rest_Amount_Fund > 0)
    THEN
      v_Rest.Rest_Fund_Type := 'Д';
    ELSE
      IF (v_Rest.Rest_Amount_Fund < 0)
      THEN
        v_Rest.Rest_Fund_Type   := 'К';
        v_Rest.Rest_Amount_Fund := -v_Rest.Rest_Amount_Fund;
      ELSE
        v_Rest.Rest_Fund_Type := '';
      END IF;
    END IF;
    v_Rest.Rest_Amount_Base_Fund := v_Temp_Dt_Amount_Base_Fund - v_Temp_Ct_Amount_Base_Fund;
    IF (v_Rest.Rest_Amount_Base_Fund > 0)
    THEN
      v_Rest.Rest_Base_Fund_Type := 'Д';
    ELSE
      IF (v_Rest.Rest_Amount_Base_Fund < 0)
      THEN
        v_Rest.Rest_Base_Fund_Type   := 'К';
        v_Rest.Rest_Amount_Base_Fund := -v_Rest.Rest_Amount_Base_Fund;
      ELSE
        v_Rest.Rest_Base_Fund_Type := '';
      END IF;
    END IF;
    v_Rest.Rest_Amount_Qty := v_Temp_Dt_Amount_Qty - v_Temp_Ct_Amount_Qty;
    IF (v_Rest.Rest_Amount_Qty > 0)
    THEN
      v_Rest.Rest_Qty_Type := 'Д';
    ELSE
      IF (v_Rest.Rest_Amount_Qty < 0)
      THEN
        v_Rest.Rest_Qty_Type   := 'К';
        v_Rest.Rest_Amount_Qty := -v_Rest.Rest_Amount_Qty;
      ELSE
        v_Rest.Rest_Qty_Type := '';
      END IF;
    END IF;
  
    RETURN v_Rest;
  END;

  --Исходящий остаток по счету на дату (дебет-кредит)
  FUNCTION Get_Acc_Rest_Abs
  (
    p_Rest_Amount_Type VARCHAR2
   ,p_Account_ID       NUMBER
   ,p_Fund_ID          NUMBER
   ,p_Date             DATE DEFAULT SYSDATE
   ,p_A1_ID            NUMBER DEFAULT NULL
   ,p_A1_nulls         NUMBER DEFAULT 0
   ,p_A2_ID            NUMBER DEFAULT NULL
   ,p_A2_nulls         NUMBER DEFAULT 0
   ,p_A3_ID            NUMBER DEFAULT NULL
   ,p_A3_nulls         NUMBER DEFAULT 0
   ,p_A4_ID            NUMBER DEFAULT NULL
   ,p_A4_nulls         NUMBER DEFAULT 0
   ,p_A5_ID            NUMBER DEFAULT NULL
   ,p_A5_nulls         NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_Rest           NUMBER;
    v_Account        Account%ROWTYPE;
    v_Base_Fund_ID   NUMBER;
    v_Temp_Dt_Amount NUMBER;
    v_Temp_Ct_Amount NUMBER;
  BEGIN
    --описание счета
    SELECT * INTO v_Account FROM Account a WHERE a.account_id = p_Account_ID;
    --базовая валюта плана счетов
    SELECT act.base_fund_id
      INTO v_Base_Fund_ID
      FROM Acc_Chart_Type act
     WHERE act.acc_chart_type_id = v_Account.Acc_Chart_Type_Id;
    --расчет исходящего остатка по дебету
    SELECT CASE
             WHEN p_Rest_Amount_Type = 'F' THEN
              nvl(SUM(t.acc_amount), 0)
             WHEN p_Rest_Amount_Type = 'B' THEN
              nvl(SUM(t.trans_amount), 0)
             WHEN p_Rest_Amount_Type = 'Q' THEN
              nvl(SUM(t.trans_quantity), 0)
             ELSE
              0
           END Rest
      INTO v_Temp_Dt_Amount
      FROM Trans t
     WHERE t.dt_account_id = v_Account.Account_ID
       AND t.trans_date <= p_Date
       AND t.acc_fund_id = p_Fund_ID
       AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
           ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_dt_uro_id IS NULL)) OR
           ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_dt_uro_id)))
       AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
           ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_dt_uro_id IS NULL)) OR
           ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_dt_uro_id)))
       AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
           ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_dt_uro_id IS NULL)) OR
           ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_dt_uro_id)))
       AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
           ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_dt_uro_id IS NULL)) OR
           ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_dt_uro_id)))
       AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
           ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_dt_uro_id IS NULL)) OR
           ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_dt_uro_id)));
    --расчет исходящего остатка по кредиту
    SELECT CASE
             WHEN p_Rest_Amount_Type = 'F' THEN
              nvl(SUM(t.acc_amount), 0)
             WHEN p_Rest_Amount_Type = 'B' THEN
              nvl(SUM(t.trans_amount), 0)
             WHEN p_Rest_Amount_Type = 'Q' THEN
              nvl(SUM(t.trans_quantity), 0)
             ELSE
              0
           END Rest
      INTO v_Temp_Ct_Amount
      FROM Trans t
     WHERE t.ct_account_id = v_Account.Account_ID
       AND t.trans_date <= p_Date
       AND t.acc_fund_id = p_Fund_ID
       AND (((p_A1_ID IS NULL) AND (p_A1_nulls = 0)) OR
           ((p_A1_ID IS NULL) AND (p_A1_nulls = 1) AND (t.a1_ct_uro_id IS NULL)) OR
           ((p_A1_ID IS NOT NULL) AND (p_A1_ID = t.a1_ct_uro_id)))
       AND (((p_A2_ID IS NULL) AND (p_A2_nulls = 0)) OR
           ((p_A2_ID IS NULL) AND (p_A2_nulls = 1) AND (t.a2_ct_uro_id IS NULL)) OR
           ((p_A2_ID IS NOT NULL) AND (p_A2_ID = t.a2_ct_uro_id)))
       AND (((p_A3_ID IS NULL) AND (p_A3_nulls = 0)) OR
           ((p_A3_ID IS NULL) AND (p_A3_nulls = 1) AND (t.a3_ct_uro_id IS NULL)) OR
           ((p_A3_ID IS NOT NULL) AND (p_A3_ID = t.a3_ct_uro_id)))
       AND (((p_A4_ID IS NULL) AND (p_A4_nulls = 0)) OR
           ((p_A4_ID IS NULL) AND (p_A4_nulls = 1) AND (t.a4_ct_uro_id IS NULL)) OR
           ((p_A4_ID IS NOT NULL) AND (p_A4_ID = t.a4_ct_uro_id)))
       AND (((p_A5_ID IS NULL) AND (p_A5_nulls = 0)) OR
           ((p_A5_ID IS NULL) AND (p_A5_nulls = 1) AND (t.a5_ct_uro_id IS NULL)) OR
           ((p_A5_ID IS NOT NULL) AND (p_A5_ID = t.a5_ct_uro_id)));
    --подсчет исходящего остатка
    v_Rest := v_Temp_Dt_Amount - v_Temp_Ct_Amount;
    RETURN v_Rest;
  END;

  --Остатки и обороты по счету за период
  FUNCTION Get_Acc_Turn_Rest_By_Type
  (
    p_Type       VARCHAR2
   ,p_Char       VARCHAR2
   ,p_Account_ID NUMBER
   ,p_Fund_ID    NUMBER
   ,p_Start_Date DATE DEFAULT SYSDATE
   ,p_End_Date   DATE DEFAULT SYSDATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A1_nulls   NUMBER DEFAULT 0
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A2_nulls   NUMBER DEFAULT 0
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A3_nulls   NUMBER DEFAULT 0
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A4_nulls   NUMBER DEFAULT 0
   ,p_A5_ID      NUMBER DEFAULT NULL
   ,p_A5_nulls   NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_Turn_Rest t_Turn_Rest;
    v_result    NUMBER;
  BEGIN
    v_Turn_Rest := Get_Acc_Turn_Rest(p_Account_ID
                                    ,p_Fund_ID
                                    ,p_Start_Date
                                    ,p_End_Date
                                    ,p_A1_ID
                                    ,p_A1_Nulls
                                    ,p_A2_ID
                                    ,p_A2_Nulls
                                    ,p_A3_ID
                                    ,p_A3_Nulls
                                    ,p_A4_ID
                                    ,p_A4_Nulls
                                    ,p_A5_ID
                                    ,p_A5_Nulls);
  
    IF (p_Type = 'IR_F')
    THEN
      IF (p_Char = 'А')
      THEN
        IF v_Turn_Rest.Rest_In_Fund_Type = 'Д'
        THEN
          v_Result := v_Turn_rest.Rest_In_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_In_Fund;
        END IF;
      ELSE
        IF v_Turn_Rest.Rest_In_Fund_Type = 'К'
        THEN
          v_Result := v_Turn_rest.Rest_In_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_In_Fund;
        END IF;
      END IF;
    ELSIF (p_Type = 'IR_BF')
    THEN
      IF (p_Char = 'А')
      THEN
        IF v_Turn_Rest.Rest_In_Base_Fund_Type = 'Д'
        THEN
          v_Result := v_Turn_rest.Rest_In_Base_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_In_Base_Fund;
        END IF;
      ELSE
        IF v_Turn_Rest.Rest_In_Base_Fund_Type = 'К'
        THEN
          v_Result := v_Turn_rest.Rest_In_Base_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_In_Base_Fund;
        END IF;
      END IF;
    ELSIF (p_Type = 'IR_Q')
    THEN
      IF (p_Char = 'А')
      THEN
        IF v_Turn_Rest.Rest_In_Qty_Type = 'Д'
        THEN
          v_Result := v_Turn_rest.Rest_In_Qty;
        ELSE
          v_Result := -v_Turn_rest.Rest_In_Qty;
        END IF;
      ELSE
        IF v_Turn_Rest.Rest_In_Qty_Type = 'К'
        THEN
          v_Result := v_Turn_rest.Rest_In_Qty;
        ELSE
          v_Result := -v_Turn_rest.Rest_In_Qty;
        END IF;
      END IF;
    ELSIF (p_Type = 'IR_F_')
    THEN
      v_Result := v_Turn_rest.Rest_In_Fund;
    ELSIF (p_Type = 'IR_BF_')
    THEN
      v_Result := v_Turn_rest.Rest_In_Base_Fund;
    ELSIF (p_Type = 'IR_Q_')
    THEN
      v_Result := v_Turn_rest.Rest_In_Qty;
    ELSIF (p_Type = 'IRT_F')
    THEN
      IF (v_Turn_rest.Rest_In_Fund_Type = 'Д')
      THEN
        v_Result := 1;
      ELSIF (v_Turn_rest.Rest_In_Fund_Type = 'К')
      THEN
        v_Result := 2;
      ELSE
        v_Result := 0;
      END IF;
    ELSIF (p_Type = 'IRT_BF')
    THEN
      IF (v_Turn_rest.Rest_In_Base_Fund_Type = 'Д')
      THEN
        v_Result := 1;
      ELSIF (v_Turn_rest.Rest_In_Base_Fund_Type = 'К')
      THEN
        v_Result := 2;
      ELSE
        v_Result := 0;
      END IF;
    ELSIF (p_Type = 'IRT_Q')
    THEN
      IF (v_Turn_rest.Rest_In_Qty_Type = 'Д')
      THEN
        v_Result := 1;
      ELSIF (v_Turn_rest.Rest_In_Qty_Type = 'К')
      THEN
        v_Result := 2;
      ELSE
        v_Result := 0;
      END IF;
    ELSIF (p_Type = 'TD_F')
    THEN
      v_Result := v_Turn_rest.Turn_Dt_Fund;
    ELSIF (p_Type = 'TD_BF')
    THEN
      v_Result := v_Turn_rest.Turn_Dt_Base_Fund;
    ELSIF (p_Type = 'TD_Q')
    THEN
      v_Result := v_Turn_rest.Turn_Dt_Qty;
    ELSIF (p_Type = 'TC_F')
    THEN
      v_Result := v_Turn_Rest.Turn_Ct_Fund;
    ELSIF (p_Type = 'TC_BF')
    THEN
      v_Result := v_Turn_Rest.Turn_Ct_Base_Fund;
    ELSIF (p_Type = 'TC_Q')
    THEN
      v_Result := v_Turn_Rest.Turn_Ct_Qty;
    ELSIF (p_Type = 'OR_F')
    THEN
      IF (p_Char = 'А')
      THEN
        IF v_Turn_Rest.Rest_Out_Fund_Type = 'Д'
        THEN
          v_Result := v_Turn_rest.Rest_Out_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_Out_Fund;
        END IF;
      ELSE
        IF v_Turn_Rest.Rest_Out_Fund_Type = 'К'
        THEN
          v_Result := v_Turn_rest.Rest_Out_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_Out_Fund;
        END IF;
      END IF;
    ELSIF (p_Type = 'OR_BF')
    THEN
      IF (p_Char = 'А')
      THEN
        IF v_Turn_Rest.Rest_Out_Base_Fund_Type = 'Д'
        THEN
          v_Result := v_Turn_rest.Rest_Out_Base_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_Out_Base_Fund;
        END IF;
      ELSE
        IF v_Turn_Rest.Rest_Out_Base_Fund_Type = 'К'
        THEN
          v_Result := v_Turn_rest.Rest_Out_Base_Fund;
        ELSE
          v_Result := -v_Turn_rest.Rest_Out_Base_Fund;
        END IF;
      END IF;
    ELSIF (p_Type = 'OR_Q')
    THEN
      IF (p_Char = 'А')
      THEN
        IF v_Turn_Rest.Rest_Out_Qty_Type = 'Д'
        THEN
          v_Result := v_Turn_rest.Rest_Out_Qty;
        ELSE
          v_Result := -v_Turn_rest.Rest_Out_Qty;
        END IF;
      ELSE
        IF v_Turn_Rest.Rest_Out_Qty_Type = 'К'
        THEN
          v_Result := v_Turn_rest.Rest_Out_Qty;
        ELSE
          v_Result := -v_Turn_rest.Rest_Out_Qty;
        END IF;
      END IF;
    ELSIF (p_Type = 'OR_F_')
    THEN
      v_Result := v_Turn_rest.Rest_Out_Fund;
    ELSIF (p_Type = 'OR_BF_')
    THEN
      v_Result := v_Turn_rest.Rest_Out_Base_Fund;
    ELSIF (p_Type = 'OR_Q_')
    THEN
      v_Result := v_Turn_rest.Rest_Out_Qty;
    ELSIF (p_Type = 'ORT_F')
    THEN
      IF (v_Turn_rest.Rest_Out_Fund_Type = 'Д')
      THEN
        v_Result := 1;
      ELSIF (v_Turn_rest.Rest_Out_Fund_Type = 'К')
      THEN
        v_Result := 2;
      ELSE
        v_Result := 0;
      END IF;
    ELSIF (p_Type = 'ORT_BF')
    THEN
      IF (v_Turn_rest.Rest_Out_Base_Fund_Type = 'Д')
      THEN
        v_Result := 1;
      ELSIF (v_Turn_rest.Rest_Out_Base_Fund_Type = 'К')
      THEN
        v_Result := 2;
      ELSE
        v_Result := 0;
      END IF;
    ELSIF (p_Type = 'ORT_Q')
    THEN
      IF (v_Turn_rest.Rest_Out_Qty_Type = 'Д')
      THEN
        v_Result := 1;
      ELSIF (v_Turn_rest.Rest_Out_Qty_Type = 'К')
      THEN
        v_Result := 2;
      ELSE
        v_Result := 0;
      END IF;
    ELSE
      v_Result := 0;
    END IF;
    RETURN v_Result;
  END;

  --Расчитать ключевой разряд в банковском счете
  FUNCTION Get_Key_Account
  (
    p_BIC     VARCHAR2
   ,p_Account VARCHAR2
  ) RETURN VARCHAR2 IS
    v_Temp_Acc    VARCHAR2(23);
    v_Multi       VARCHAR2(23);
    i             NUMBER;
    v_Number      NUMBER;
    v_Temp_Number NUMBER;
    v_Result      VARCHAR2(20);
  BEGIN
    IF ((length(p_BIC) = 3) AND (length(p_Account) = 20))
    THEN
      v_Temp_Acc := p_BIC || substr(p_Account, 1, 8) || '0' || substr(p_Account, 10, 11);
      v_Multi    := '71371371371371371371371';
      v_Number   := 0;
      FOR i IN 1 .. 23
      LOOP
        BEGIN
          v_Temp_Number := to_number(substr(v_Temp_Acc, i, 1)) * to_number(substr(v_Multi, i, 1));
        EXCEPTION
          WHEN OTHERS THEN
            v_Temp_Number := 0;
        END;
        v_Number := v_Number + v_Temp_Number;
      END LOOP;
      v_Result := TRIM(to_char(v_Number));
      v_Result := substr(v_Result, length(v_Result), 1);
      v_Number := to_number(v_Result) * 3;
      v_Result := TRIM(to_char(v_Number));
      v_Result := substr(v_Result, length(v_Result), 1);
      v_Result := substr(p_Account, 1, 8) || v_Result || substr(p_Account, 10, 11);
    ELSE
      v_Result := '';
    END IF;
    RETURN v_Result;
  END;

  --Установка соответствующих признаков всем дочерним счетам
  PROCEDURE Set_Attr_Inherit_Child_Acc
  (
    p_Account_ID NUMBER
   ,p_IS_CHAR    NUMBER
   ,p_IS_AN      NUMBER
  ) IS
    v_Account Account%ROWTYPE;
  BEGIN
    SELECT * INTO v_Account FROM Account a WHERE a.account_id = p_Account_ID;
    IF (p_IS_CHAR = 1)
    THEN
      BEGIN
        UPDATE Account a
           SET a.characteristics = v_Account.Characteristics
         WHERE a.account_id IN (SELECT aa.account_id
                                  FROM account aa
                                 WHERE aa.acc_chart_type_id = v_Account.Acc_Chart_Type_Id
                                 START WITH aa.parent_id = p_Account_ID
                                CONNECT BY PRIOR aa.account_id = aa.parent_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  
    IF (p_IS_AN = 1)
    THEN
      BEGIN
        UPDATE Account a
           SET a.a1_analytic_type_id = v_Account.A1_Analytic_Type_Id
              ,a.a2_analytic_type_id = v_Account.A2_Analytic_Type_Id
              ,a.a3_analytic_type_id = v_Account.A3_Analytic_Type_Id
              ,a.a4_analytic_type_id = v_Account.A4_Analytic_Type_Id
              ,a.a5_analytic_type_id = v_Account.A5_Analytic_Type_Id
              ,a.a1_ure_id           = v_Account.A1_Ure_Id
              ,a.a2_ure_id           = v_Account.A2_Ure_Id
              ,a.a3_ure_id           = v_Account.A3_Ure_Id
              ,a.a4_ure_id           = v_Account.A4_Ure_Id
              ,a.a5_ure_id           = v_Account.A5_Ure_Id
         WHERE a.account_id IN (SELECT aa.account_id
                                  FROM account aa
                                 WHERE aa.acc_chart_type_id = v_Account.Acc_Chart_Type_Id
                                 START WITH aa.parent_id = p_Account_ID
                                CONNECT BY PRIOR aa.account_id = aa.parent_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  
  END;

  --Найти счет по связи счетов
  FUNCTION Get_Account_By_Mask
  (
    p_Account_ID            NUMBER
   ,p_Acc_Chart_Type_ID     NUMBER
   ,p_Rev_Acc_Chart_Type_ID NUMBER
  ) RETURN NUMBER IS
    v_Account        Account%ROWTYPE;
    v_Rel_Acc        Rel_Acc%ROWTYPE;
    v_Rev_Account_ID NUMBER;
    --v_Rev_Account_num varchar2(50);
    CURSOR c_Rel_Acc
    (
      p_Account_Num VARCHAR2
     ,p_Acc_Char    VARCHAR2
    ) IS
      SELECT ra.*
        FROM Rel_Acc ra
            ,Account a
       WHERE p_Account_Num LIKE ra.acc_mask
         AND ra.account_id = a.account_id
         AND a.acc_chart_type_id = p_Rev_Acc_Chart_Type_ID
         AND (ra.characteristics = p_Acc_Char OR ra.characteristics IS NULL)
         AND ra.is_not = 0
         AND ra.acc_chart_type_id = p_Acc_Chart_Type_ID
         AND (acc.Mask_Sign_Count(ra.acc_mask) =
             (SELECT MAX(acc.Mask_Sign_Count(ras.acc_mask))
                 FROM Rel_Acc ras
                     ,Account ass
                WHERE p_Account_Num LIKE ras.acc_mask
                  AND ras.account_id = ass.account_id
                  AND ass.acc_chart_type_id = p_Rev_Acc_Chart_Type_ID
                  AND (ras.characteristics = p_Acc_Char OR ras.characteristics IS NULL)
                  AND ras.is_not = 0
                  AND ras.acc_chart_type_id = p_Acc_Chart_Type_ID))
         AND ra.account_id NOT IN
             (SELECT ral.account_id
                FROM Rel_Acc ral
                    ,Account al
               WHERE p_Account_Num LIKE ral.acc_mask
                 AND ral.account_id = al.account_id
                 AND al.acc_chart_type_id = p_Rev_Acc_Chart_Type_ID
                 AND (ral.characteristics = p_Acc_Char OR ral.characteristics IS NULL)
                 AND ral.is_not = 1
                 AND ral.acc_chart_type_id = p_Acc_Chart_Type_ID
                 AND (acc.Mask_Sign_Count(ral.acc_mask) =
                     (SELECT MAX(acc.Mask_Sign_Count(rasl.acc_mask))
                         FROM Rel_Acc rasl
                             ,Account asl
                        WHERE p_Account_Num LIKE rasl.acc_mask
                          AND rasl.account_id = asl.account_id
                          AND asl.acc_chart_type_id = p_Rev_Acc_Chart_Type_ID
                          AND (rasl.characteristics = p_Acc_Char OR rasl.characteristics IS NULL)
                          AND rasl.is_not = 1
                          AND rasl.acc_chart_type_id = p_Acc_Chart_Type_ID)));
  BEGIN
    --Получить счет для подбора
    SELECT * INTO v_Account FROM Account a WHERE a.account_id = p_Account_ID;
    --Открыть курсор
    v_Rev_Account_ID := NULL;
    OPEN c_Rel_Acc(v_Account.NUM, v_account.CHARACTERISTICS);
    LOOP
      FETCH c_Rel_Acc
        INTO v_Rel_Acc;
      EXIT WHEN c_Rel_Acc%NOTFOUND;
      v_Rev_Account_ID := v_Rel_Acc.account_id;
    END LOOP;
    CLOSE c_Rel_Acc;
    RETURN v_Rev_Account_ID;
  END;

  --Количество значащих символов в маске счета
  FUNCTION Mask_Sign_Count(p_Mask VARCHAR2) RETURN NUMBER IS
    j NUMBER;
  BEGIN
    j := 0;
    FOR i IN 1 .. length(p_Mask)
    LOOP
      IF (substr(p_Mask, i, 1) NOT IN ('%', '_'))
      THEN
        j := j + 1;
      END IF;
    END LOOP;
    RETURN j;
  END;

  --Проверка на присутствие аналитики в счете
  FUNCTION Is_Valid_Analytic
  (
    p_Analytic_Type_ID NUMBER
   ,p_URO_ID           NUMBER
   ,p_Account_ID       NUMBER
  ) RETURN NUMBER IS
    v_Result NUMBER;
    CURSOR c IS
      SELECT a.account_id
        FROM Account a
             ----
            ,analytic_type att
      ----
       WHERE (a.account_id = p_Account_ID)
            /*        and
                    (
                      ((a.a1_analytic_type_id = p_Analytic_Type_ID) and (a.a1_uro_id = p_URO_ID))
                      or
                      ((a.a2_analytic_type_id = p_Analytic_Type_ID) and (a.a2_uro_id = p_URO_ID))
                      or
                      ((a.a3_analytic_type_id = p_Analytic_Type_ID) and (a.a3_uro_id = p_URO_ID))
                      or
                      ((a.a4_analytic_type_id = p_Analytic_Type_ID) and (a.a4_uro_id = p_URO_ID))
                      or
                      ((a.a5_analytic_type_id = p_Analytic_Type_ID) and (a.a5_uro_id = p_URO_ID))
            */
         AND att.analytic_type_id = p_Analytic_Type_ID
         AND (((a.a1_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a1_uro_id = p_URO_ID)) OR
             ((a.a2_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a2_uro_id = p_URO_ID)) OR
             ((a.a3_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a3_uro_id = p_URO_ID)) OR
             ((a.a4_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a4_uro_id = p_URO_ID)) OR
             ((a.a5_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a5_uro_id = p_URO_ID)));
  BEGIN
    OPEN c;
    FETCH c
      INTO v_Result;
    IF c%NOTFOUND
    THEN
      v_Result := 0;
    ELSE
      v_Result := 1;
    END IF;
    CLOSE c;
    RETURN v_Result;
  END;

  --Найти роль по маске счета
  FUNCTION Get_Role_By_Mask
  (
    p_Account_Num       VARCHAR2
   ,p_Acc_Char          VARCHAR2
   ,p_Acc_Chart_Type_ID NUMBER
  ) RETURN NUMBER IS
    --v_Acc_Role        Acc_Role%rowtype;
    v_Rel_Acc_Role    Rel_Acc_Role%ROWTYPE;
    v_Rev_Acc_Role_ID NUMBER;
    --v_Rev_Account_num varchar2(50);
    CURSOR c_Rel_Acc_Role IS
      SELECT *
        FROM Rel_Acc_Role rar
       WHERE p_Account_Num LIKE rar.acc_mask
         AND (rar.characteristics = p_Acc_Char OR rar.characteristics IS NULL)
         AND rar.is_not = 0
         AND rar.acc_chart_type_id = p_Acc_Chart_Type_ID
         AND (acc.Mask_Sign_Count(rar.acc_mask) =
             (SELECT MAX(acc.Mask_Sign_Count(rars.acc_mask))
                 FROM Rel_Acc_Role rars
                WHERE p_Account_Num LIKE rars.acc_mask
                  AND (rars.characteristics = p_Acc_Char OR rars.characteristics IS NULL)
                  AND rars.is_not = 0
                  AND rars.acc_chart_type_id = p_Acc_Chart_Type_ID))
         AND rar.acc_role_id NOT IN
             (SELECT rar1.acc_role_id
                FROM Rel_Acc_Role rar1
               WHERE p_Account_Num LIKE rar1.acc_mask
                 AND (rar1.characteristics = p_Acc_Char OR rar1.characteristics IS NULL)
                 AND rar1.is_not = 1
                 AND rar1.acc_chart_type_id = p_Acc_Chart_Type_ID
                 AND (acc.Mask_Sign_Count(rar1.acc_mask) =
                     (SELECT MAX(acc.Mask_Sign_Count(rars1.acc_mask))
                         FROM Rel_Acc_Role rars1
                        WHERE p_Account_Num LIKE rars1.acc_mask
                          AND (rars1.characteristics = p_Acc_Char OR rars1.characteristics IS NULL)
                          AND rars1.is_not = 1
                          AND rars1.acc_chart_type_id = p_Acc_Chart_Type_ID)));
  BEGIN
    v_Rev_Acc_Role_ID := NULL;
    OPEN c_Rel_Acc_Role;
    LOOP
      FETCH c_Rel_Acc_Role
        INTO v_Rel_Acc_Role;
      EXIT WHEN c_Rel_Acc_Role%NOTFOUND;
      v_Rev_Acc_Role_ID := v_Rel_Acc_Role.acc_role_id;
    END LOOP;
    CLOSE c_Rel_Acc_Role;
    RETURN v_Rev_Acc_Role_ID;
  END;

  --Обновить роли счетов в плане счетов, согласно заведенным маскам
  PROCEDURE Refresh_Acc_Roles(p_Acc_Chart_Type_ID NUMBER) IS
  BEGIN
    UPDATE Account a
       SET a.acc_role_id = acc.Get_Role_By_Mask(a.num, a.characteristics, a.acc_chart_type_id)
     WHERE a.acc_chart_type_id = p_Acc_Chart_Type_ID
       AND length(a.num) = 20;
    COMMIT;
  END;

  --Унаследовать признаки родительского счета дочерним счетам
  PROCEDURE Update_Nested_Accounts(p_Account_ID NUMBER) IS
    v_Account_ID     NUMBER;
    v_Parent_Account Account%ROWTYPE;
    CURSOR c IS
      SELECT a.Account_ID
        FROM Account a
       START WITH a.parent_id = p_Account_ID
      CONNECT BY PRIOR a.account_id = a.parent_id;
  BEGIN
    SELECT * INTO v_Parent_Account FROM Account a WHERE a.account_id = p_Account_ID;
    OPEN c;
    LOOP
      FETCH c
        INTO v_Account_ID;
      EXIT WHEN c%NOTFOUND;
      UPDATE Account a
         SET a.characteristics     = v_Parent_Account.Characteristics
            ,a.is_revalued         = v_Parent_Account.is_revalued
            ,a.a1_analytic_type_id = v_Parent_Account.A1_Analytic_Type_Id
            ,a.a2_analytic_type_id = v_Parent_Account.A2_Analytic_Type_Id
            ,a.a3_analytic_type_id = v_Parent_Account.A3_Analytic_Type_Id
            ,a.a4_analytic_type_id = v_Parent_Account.A4_Analytic_Type_Id
            ,a.a5_analytic_type_id = v_Parent_Account.A5_Analytic_Type_Id
            ,a.a1_ure_id           = v_Parent_Account.A1_Ure_Id
            ,a.a2_ure_id           = v_Parent_Account.A2_Ure_Id
            ,a.a3_ure_id           = v_Parent_Account.A3_Ure_Id
            ,a.a4_ure_id           = v_Parent_Account.A4_Ure_Id
            ,a.a5_ure_id           = v_Parent_Account.A5_Ure_Id
            ,a.a1_uro_id           = v_Parent_Account.A1_Uro_Id
            ,a.a2_uro_id           = v_Parent_Account.A2_Uro_Id
            ,a.a3_uro_id           = v_Parent_Account.A3_Uro_Id
            ,a.a4_uro_id           = v_Parent_Account.A4_Uro_Id
            ,a.a5_uro_id           = v_Parent_Account.A5_Uro_Id
       WHERE a.account_id = v_Account_ID;
    END LOOP;
    CLOSE c;
  END;

BEGIN
  SELECT rt.rate_type_id INTO cb_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';

END;
/
