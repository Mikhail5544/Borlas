CREATE OR REPLACE PACKAGE PKG_INFO_NODE AS
  /******************************************************************************
     NAME:       PKG_INFO_NODE
     PURPOSE: Набор логики для работы с информационными узлами
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        23.05.2012      sergey.ilyushkin       1. Created this package.
  ******************************************************************************/

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для сотрудника
    @param par_Employee_ID - ИД сотрудника
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_Employee_Inf_Node
  (
    par_Employee_ID NUMBER
   ,par_Date        DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для агента
    @param par_Agent_ID - ИД агента
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_Agent_Inf_Node
  (
    par_Agent_ID NUMBER
   ,par_Date     DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для пользователя системы
    @param par_User_ID - ИД пользователя
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_User_Inf_Node
  (
    par_User_ID NUMBER
   ,par_Date    DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для пользователя системы (перегруженый вариант)
    @param par_User_Name - имя пользователя
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_User_Inf_Node
  (
    par_User_Name VARCHAR2
   ,par_Date      DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа инфоузла к данным другого инфоузла
    @param par_Access_Node_ID - ИД инфоузла, который пытается получить доступ
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r (read) - чтение, w (write) - запись
    @param par_Access_Group_ID - ИД группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access
  (
    par_Access_Node_ID  NUMBER
   ,par_Data_Node_ID    NUMBER
   ,par_Mode            VARCHAR2
   ,par_Access_Group_ID NUMBER
  ) RETURN NUMBER;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа инфоузла к данным другого инфоузла (перегружена)
    @param par_Access_Node_ID - ИД инфоузла, который пытается получить доступ
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r (read) - чтение, w (write) - запись
    @param par_Access_Group_Name - Наименование группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access
  (
    par_Access_Node_ID    NUMBER
   ,par_Data_Node_ID      NUMBER
   ,par_Mode              VARCHAR2
   ,par_Access_Group_Name VARCHAR2
  ) RETURN NUMBER;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа пользователя к данным инфоузла
    @param par_User_ID - ИД пользователя
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_ID - ИД группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_User
  (
    par_User_ID         NUMBER
   ,par_Data_Node_ID    NUMBER
   ,par_Mode            VARCHAR2
   ,par_Access_Group_ID NUMBER
  ) RETURN NUMBER;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа пользователя к данным инфоузла (перегружена)
    @param par_User_Name - Наименование пользователя
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_Name - Наименование группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_User
  (
    par_User_Name         VARCHAR2
   ,par_Data_Node_ID      NUMBER
   ,par_Mode              VARCHAR2
   ,par_Access_Group_Name VARCHAR2
  ) RETURN NUMBER;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа сотрудника к данным инфоузла
    @param par_Emp_ID - ИД сотрудника
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_ID - ИД группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_Emp
  (
    par_Emp_ID          NUMBER
   ,par_Data_Node_ID    NUMBER
   ,par_Mode            VARCHAR2
   ,par_Access_Group_ID NUMBER
  ) RETURN NUMBER;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа сотрудника к данным инфоузла (перегружена)
    @param par_Emp_ID - ИД сотрудника
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_Name - Наименование группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_Emp
  (
    par_Emp_ID            NUMBER
   ,par_Data_Node_ID      NUMBER
   ,par_Mode              VARCHAR2
   ,par_Access_Group_Name VARCHAR2
  ) RETURN NUMBER;

  /* sergey.ilyushkin   29/05/2012
    Установка инфоузла для договора страхования
    @param par_Pol_Header_ID - ИД заголовка договора страхования
    @return ИД присвоенного инфоузла 
  */
  PROCEDURE Set_Policy_Node_by_Header(par_Pol_Header_ID NUMBER);

  /* sergey.ilyushkin   29/05/2012
    Установка инфоузла для договора страхования по ИД агента
    @param par_Policy_Agent_Doc_ID - ИД связки Договор-Агент
    @return ИД присвоенного инфоузла 
  */
  PROCEDURE Set_Policy_Node_by_Agent(par_Policy_Agent_Doc_ID NUMBER);

  /* sergey.ilyushkin 16/08/2012
  Добавить/изменить Информационный узел 
  */
  PROCEDURE Edit_Info_Node
  (
    par_Info_Node_ID      IN OUT NUMBER
   ,par_Node_Name         IN VARCHAR2 DEFAULT NULL
   ,par_Brief             IN VARCHAR2 DEFAULT NULL
   ,par_Code              IN VARCHAR2 DEFAULT NULL
   ,par_Org_ID            IN NUMBER DEFAULT NULL
   ,par_Detail_Table_Name IN VARCHAR2 DEFAULT NULL
   ,par_Detail_Table_ID   IN NUMBER DEFAULT NULL
   ,par_Force_Update      IN INT DEFAULT 0 -- признак принудительной записи передаваемых значений в поля
    -- если = 0, то параметры = NULL игнорируются
    -- актуально только для UPDATE
  );

END PKG_INFO_NODE;
/
CREATE OR REPLACE PACKAGE BODY PKG_INFO_NODE AS
  /******************************************************************************
     NAME:       PKG_INFO_NODE
     PURPOSE: Набор логики для работы с информационными узлами
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        23.05.2012      sergey.ilyushkin       1. Created this package body.
  ******************************************************************************/

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для сотрудника
    @param par_Employee_ID - ИД сотрудника
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_Employee_Inf_Node
  (
    par_Employee_ID NUMBER
   ,par_Date        DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_Info_Node_ID INTEGER := NULL;
  BEGIN
    SELECT INF_ID
      INTO v_Info_Node_ID
      FROM (SELECT INF_ID
              FROM EMPLOYEE_HIST
             WHERE EMPLOYEE_ID = par_Employee_ID
               AND DATE_HIST <= par_Date
               AND IS_KICKED = 0
             ORDER BY DATE_HIST DESC)
     WHERE rownum = 1;
  
    RETURN v_Info_Node_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Employee_Inf_Node;

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для агента
    @param par_Agent_ID - ИД агента
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_Agent_Inf_Node
  (
    par_Agent_ID NUMBER
   ,par_Date     DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_Info_Node_ID INTEGER := NULL;
  BEGIN
    SELECT INF.INFO_NODE_ID
      INTO v_Info_Node_ID
      FROM ag_contract_header ach
          ,department         d
          ,info_node          inf
     WHERE ACH.AGENT_ID = par_Agent_ID
       AND D.DEPARTMENT_ID = ACH.AGENCY_ID
       AND INF.ORG_ID = D.ORG_TREE_ID
       AND par_Date BETWEEN ACH.DATE_BEGIN AND ACH.DATE_BREAK;
  
    RETURN v_Info_Node_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Agent_Inf_Node;

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для пользователя системы
    @param par_User_ID - ИД пользователя
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_User_Inf_Node
  (
    par_User_ID NUMBER
   ,par_Date    DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
  
    v_Info_Node_ID INTEGER := NULL;
    v_User_ID      INTEGER := NULL;
  BEGIN
    -- пока предполагаем, что пользователь системы является сотрудником
    BEGIN
      SELECT EMPLOYEE_ID INTO v_User_ID FROM SYS_USER WHERE sys_user_id = par_User_ID;
    EXCEPTION
      WHEN OTHERS THEN
        v_User_ID := NULL;
    END;
  
    IF v_User_ID IS NOT NULL
    THEN
      v_Info_Node_ID := Get_Employee_Inf_Node(v_User_ID, par_Date);
    END IF;
  
    RETURN v_Info_Node_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_User_Inf_Node;

  /* sergey.ilyushkin   23/05/2012
    Вычислить ИУ для пользователя системы (перегруженый вариант)
    @param par_User_Name - имя пользователя
    @param par_Date - Дата, на которую требуется вычислить ИУ
    @return ИД информационного узла
  */
  FUNCTION Get_User_Inf_Node
  (
    par_User_Name VARCHAR2
   ,par_Date      DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_Info_Node_ID INTEGER := NULL;
    v_User_ID      INTEGER := NULL;
  BEGIN
    SELECT SYS_USER_ID INTO v_User_ID FROM SYS_USER WHERE upper(SYS_USER_NAME) = upper(par_User_Name);
  
    v_Info_Node_ID := Get_User_Inf_Node(v_User_ID, par_Date);
    RETURN v_Info_Node_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_User_Inf_Node;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа инфоузла к данным другого инфоузла
    @param par_Access_Node_ID - ИД инфоузла, который пытается получить доступ
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r (read) - чтение, w (write) - запись
    @param par_Access_Group_ID - ИД группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access
  (
    par_Access_Node_ID  NUMBER
   ,par_Data_Node_ID    NUMBER
   ,par_Mode            VARCHAR2
   ,par_Access_Group_ID NUMBER
  ) RETURN NUMBER IS
    v_Mode   VARCHAR2(10) := NULL;
    v_RetVal INTEGER := 0;
  BEGIN
    IF par_Access_Node_ID = par_Data_Node_ID
    THEN
      RETURN 1;
    END IF;
  
    v_Mode := upper(substr(par_Mode, 1, 1));
    IF v_Mode NOT IN ('R', 'W')
    THEN
      v_Mode := 'R';
    END IF;
  
    BEGIN
      SELECT 1
        INTO v_RetVal
        FROM INFO_NODE_ACCESS ina
       WHERE INA.ACCESS_NODE_ID = par_Access_Node_ID
            --and INA.DATA_NODE_ID = par_Data_Node_ID
         AND INA.ACCESS_GROUP_ID = par_Access_Group_ID
         AND ((INA.IS_READ = instr(v_Mode, 'R') AND instr(v_Mode, 'R') = 1) OR
             (INA.IS_WRITE = instr(v_Mode, 'W') AND instr(v_Mode, 'W') = 1))
      CONNECT BY PRIOR ina.access_node_id = ina.data_node_id
       START WITH ina.data_node_id = par_Data_Node_ID;
    EXCEPTION
      WHEN no_data_found THEN
        v_RetVal := 0;
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  
    RETURN v_RetVal;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Check_Access;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа инфоузла к данным другого инфоузла (перегружена)
    @param par_Access_Node_ID - ИД инфоузла, который пытается получить доступ
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r (read) - чтение, w (write) - запись
    @param par_Access_Group_Name - Наименование группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access
  (
    par_Access_Node_ID    NUMBER
   ,par_Data_Node_ID      NUMBER
   ,par_Mode              VARCHAR2
   ,par_Access_Group_Name VARCHAR2
  ) RETURN NUMBER IS
    v_RetVal          INTEGER := 0;
    v_Access_Group_ID NUMBER;
  BEGIN
    BEGIN
      SELECT TAG.T_ACCESS_GROUP_ID
        INTO v_Access_Group_ID
        FROM T_ACCESS_GROUP tag
       WHERE upper(TAG.BRIEF) = upper(par_Access_Group_Name);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  
    v_RetVal := Check_Access(par_Access_Node_ID  => par_Access_Node_ID
                            ,par_Data_Node_ID    => par_Data_Node_ID
                            ,par_Mode            => par_Mode
                            ,par_Access_Group_ID => v_Access_Group_ID);
    RETURN v_RetVal;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Check_Access;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа пользователя к данным инфоузла
    @param par_User_ID - ИД пользователя
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_ID - ИД группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_User
  (
    par_User_ID         NUMBER
   ,par_Data_Node_ID    NUMBER
   ,par_Mode            VARCHAR2
   ,par_Access_Group_ID NUMBER
  ) RETURN NUMBER IS
    v_RetVal         NUMBER := NULL;
    v_Access_Node_ID NUMBER := NULL;
  BEGIN
    v_Access_Node_ID := Get_User_Inf_Node(par_User_ID);
  
    IF v_Access_Node_ID IS NOT NULL
    THEN
      v_RetVal := Check_Access(par_Access_Node_ID  => v_Access_Node_ID
                              ,par_Data_Node_ID    => par_Data_Node_ID
                              ,par_Mode            => par_Mode
                              ,par_Access_Group_ID => par_Access_Group_ID);
    ELSE
      RETURN NULL;
    END IF;
  
    RETURN V_RetVal;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Check_Access_by_User;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа пользователя к данным инфоузла (перегружена)
    @param par_User_Name - Наименование пользователя
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_Name - Наименование группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_User
  (
    par_User_Name         VARCHAR2
   ,par_Data_Node_ID      NUMBER
   ,par_Mode              VARCHAR2
   ,par_Access_Group_Name VARCHAR2
  ) RETURN NUMBER IS
    v_User_ID         NUMBER := NULL;
    v_Access_Group_ID NUMBER := NULL;
    v_RetVal          NUMBER := NULL;
  BEGIN
    BEGIN
      SELECT SU.SYS_USER_ID
        INTO v_User_ID
        FROM sys_user su
       WHERE SU.SYS_USER_NAME = upper(par_User_Name);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  
    BEGIN
      SELECT TAG.T_ACCESS_GROUP_ID
        INTO v_Access_Group_ID
        FROM T_ACCESS_GROUP tag
       WHERE upper(TAG.BRIEF) = upper(par_Access_Group_Name);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  
    IF v_User_ID IS NOT NULL
       AND v_Access_Group_ID IS NOT NULL
    THEN
      v_RetVal := Check_Access_by_User(par_User_ID         => v_User_ID
                                      ,par_Data_Node_ID    => par_Data_Node_ID
                                      ,par_Mode            => par_Mode
                                      ,par_Access_Group_ID => v_Access_Group_ID);
    ELSE
      RETURN NULL;
    END IF;
  
    RETURN v_RetVal;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Check_Access_by_User;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа сотрудника к данным инфоузла
    @param par_Emp_ID - ИД сотрудника
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_ID - ИД группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_Emp
  (
    par_Emp_ID          NUMBER
   ,par_Data_Node_ID    NUMBER
   ,par_Mode            VARCHAR2
   ,par_Access_Group_ID NUMBER
  ) RETURN NUMBER IS
    v_Access_Node_ID NUMBER := NULL;
    v_RetVal         NUMBER := NULL;
  BEGIN
    v_Access_Node_ID := Get_Employee_Inf_Node(par_Emp_ID);
  
    IF v_Access_Node_ID IS NOT NULL
    THEN
      v_RetVal := Check_Access(par_Access_Node_ID  => v_Access_Node_ID
                              ,par_Data_Node_ID    => par_Data_Node_ID
                              ,par_Mode            => par_Mode
                              ,par_Access_Group_ID => par_Access_Group_ID);
    ELSE
      RETURN NULL;
    END IF;
  
    RETURN v_RetVal;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Check_Access_by_Emp;

  /* sergey.ilyushkin   28/05/2012
    Проверка на права доступа сотрудника к данным инфоузла (перегружена)
    @param par_Emp_ID - ИД сотрудника
    @param par_Data_Node_ID - ИД инфоузла - владельца данных
    @param par_Mode - режим доступа : r - чтение, w - запись
    @param par_Access_Group_Name - Наименование группы доступа
    @return : 1 - доступ разрешен, 0 - доступ запрещен
  */
  FUNCTION Check_Access_by_Emp
  (
    par_Emp_ID            NUMBER
   ,par_Data_Node_ID      NUMBER
   ,par_Mode              VARCHAR2
   ,par_Access_Group_Name VARCHAR2
  ) RETURN NUMBER IS
    v_Access_Group_ID NUMBER := NULL;
    v_RetVal          NUMBER := NULL;
  BEGIN
    BEGIN
      SELECT TAG.T_ACCESS_GROUP_ID
        INTO v_Access_Group_ID
        FROM T_ACCESS_GROUP tag
       WHERE upper(TAG.BRIEF) = upper(par_Access_Group_Name);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  
    IF v_Access_Group_ID IS NOT NULL
    THEN
      v_RetVal := Check_Access_By_Emp(par_Emp_ID          => par_Emp_ID
                                     ,par_Data_Node_ID    => par_Data_Node_ID
                                     ,par_Mode            => par_Mode
                                     ,par_Access_Group_ID => v_Access_Group_ID);
    ELSE
      RETURN NULL;
    END IF;
  
    RETURN v_RetVal;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Check_Access_by_Emp;

  /* sergey.ilyushkin   29/05/2012
    Установка инфоузла для договора страхования по ИД заголовка
    @param par_Pol_Header_ID - ИД заголовка договора страхования
    @return ИД присвоенного инфоузла 
  */
  PROCEDURE Set_Policy_Node_by_Header(par_Pol_Header_ID NUMBER) IS
    v_Filial_ID NUMBER := NULL;
  BEGIN
    BEGIN
      SELECT INF.INFO_NODE_ID
        INTO v_Filial_ID
        FROM p_pol_header ph
            ,(SELECT ppa.policy_header_id
                    ,PPA.AG_CONTRACT_HEADER_ID
                FROM p_policy_agent ppa
                    ,(SELECT DISTINCT policy_header_id
                                     ,MAX(p_policy_agent_id) over(PARTITION BY policy_header_id) p_policy_agent_id
                        FROM p_policy_agent
                       WHERE status_id = 1) t1
               WHERE PPA.POLICY_HEADER_ID = t1.policy_header_id
                 AND PPA.p_policy_agent_id = t1.p_policy_agent_id) pa
            ,ag_contract_header ach
            ,dept_agent da
            ,department d
            ,info_node inf
       WHERE PA.POLICY_HEADER_ID = PH.POLICY_HEADER_ID
         AND ACH.AG_CONTRACT_HEADER_ID = PA.AG_CONTRACT_HEADER_ID
         AND DA.AGENT_ID = ACH.AGENT_ID
         AND D.DEPARTMENT_ID = DA.DEPARTMENT_ID
         AND INF.ORG_ID = D.ORG_TREE_ID
         AND pa.policy_header_id = par_Pol_Header_ID;
    EXCEPTION
      WHEN OTHERS THEN
        v_Filial_ID := NULL;
    END;
  
    IF v_Filial_ID IS NULL
    THEN
      v_Filial_ID := Get_User_Inf_Node(USER);
    END IF;
  
    IF v_Filial_ID IS NOT NULL
    THEN
      UPDATE P_POL_HEADER SET FILIAL_ID = v_Filial_ID WHERE POLICY_HEADER_ID = par_Pol_Header_ID;
    
      UPDATE P_POLICY SET FILIAL_ID = v_Filial_ID WHERE POL_HEADER_ID = par_Pol_Header_ID;
    
      --    commit;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END Set_Policy_Node_by_Header;

  /* sergey.ilyushkin   29/05/2012
    Установка инфоузла для договора страхования по ИД агента
    @param par_Policy_Agent_Doc_ID - ИД связки Договор-Агент
    @return ИД присвоенного инфоузла 
  */
  PROCEDURE Set_Policy_Node_by_Agent(par_Policy_Agent_Doc_ID NUMBER) IS
    v_Filial_ID        NUMBER := NULL;
    v_Policy_Header_ID NUMBER := NULL;
    v_Agent_ID         NUMBER := NULL;
  BEGIN
    BEGIN
      SELECT PAD.POLICY_HEADER_ID
            ,ACH.AGENT_ID
        INTO v_Policy_Header_ID
            ,v_Agent_ID
        FROM P_POLICY_AGENT_DOC pad
            ,AG_CONTRACT_HEADER ach
            ,DOC_STATUS         ds
       WHERE ACH.AG_CONTRACT_HEADER_ID = PAD.AG_CONTRACT_HEADER_ID
         AND PAD.P_POLICY_AGENT_DOC_ID = par_Policy_Agent_Doc_ID
         AND DS.DOCUMENT_ID = PAD.P_POLICY_AGENT_DOC_ID
         AND DS.DOC_STATUS_REF_ID = 2
         AND DS.DOC_STATUS_ID =
             (SELECT MAX(DOC_STATUS_ID) FROM DOC_STATUS WHERE DOCUMENT_ID = par_Policy_Agent_Doc_ID);
    EXCEPTION
      WHEN OTHERS THEN
        v_Filial_ID        := NULL;
        v_Agent_ID         := NULL;
        v_Policy_Header_ID := NULL;
    END;
  
    IF v_Agent_ID IS NOT NULL
    THEN
      v_Filial_ID := Get_Agent_Inf_Node(v_Agent_ID);
    END IF;
  
    IF v_Filial_ID IS NULL
    THEN
      v_Filial_ID := Get_User_Inf_Node(USER);
    END IF;
  
    IF v_Filial_ID IS NOT NULL
       AND v_Policy_Header_ID IS NOT NULL
    THEN
      UPDATE P_POL_HEADER SET FILIAL_ID = v_Filial_ID WHERE POLICY_HEADER_ID = v_Policy_Header_ID;
    
      UPDATE P_POLICY SET FILIAL_ID = v_Filial_ID WHERE POL_HEADER_ID = v_Policy_Header_ID;
    
      --    commit;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END Set_Policy_Node_by_Agent;

  /* sergey.ilyushkin 16/08/2012
  Добавить/изменить Информационный узел 
  */
  PROCEDURE Edit_Info_Node
  (
    par_Info_Node_ID      IN OUT NUMBER
   ,par_Node_Name         IN VARCHAR2 DEFAULT NULL
   ,par_Brief             IN VARCHAR2 DEFAULT NULL
   ,par_Code              IN VARCHAR2 DEFAULT NULL
   ,par_Org_ID            IN NUMBER DEFAULT NULL
   ,par_Detail_Table_Name IN VARCHAR2 DEFAULT NULL
   ,par_Detail_Table_ID   IN NUMBER DEFAULT NULL
   ,par_Force_Update      IN INT DEFAULT 0 -- признак принудительной записи передаваемых значений в поля
    -- если = 0, то параметры = NULL игнорируются
    -- актуально только для UPDATE
  ) IS
  BEGIN
    IF par_Info_Node_ID IS NOT NULL
    THEN
      UPDATE info_node
         SET node_name         = decode(par_Force_Update
                                       ,1
                                       ,par_Node_Name
                                       ,0
                                       ,nvl(par_Node_Name, node_name))
            ,brief             = decode(par_Force_Update, 1, par_Brief, 0, nvl(par_Brief, brief))
            ,code              = decode(par_Force_Update, 1, par_Code, 0, nvl(par_Code, code))
            ,org_id            = decode(par_Force_Update, 1, par_Org_ID, 0, nvl(par_Org_ID, org_id))
            ,detail_table_name = decode(par_Force_Update
                                       ,1
                                       ,par_Detail_Table_Name
                                       ,0
                                       ,nvl(par_Detail_Table_Name, detail_table_name))
            ,detail_table_id   = decode(par_Force_Update
                                       ,1
                                       ,par_Detail_Table_ID
                                       ,0
                                       ,nvl(par_Detail_Table_ID, detail_table_id))
       WHERE info_node_id = par_Info_Node_ID;
    ELSE
      INSERT INTO info_node
        (info_node_id, node_name, brief, code, org_id, detail_table_name, detail_table_id)
      VALUES
        (SQ_INFO_NODE.nextval
        ,par_Node_Name
        ,par_Brief
        ,par_Code
        ,par_Org_ID
        ,par_Detail_Table_Name
        ,par_Detail_Table_ID)
      RETURNING info_node_id INTO par_Info_Node_ID;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Неудачная попытка создать/модифицировать ИУ ID = ' || par_Info_Node_ID || '. ' ||
                              SQLERRM);
  END Edit_Info_Node;

END PKG_INFO_NODE;
/
