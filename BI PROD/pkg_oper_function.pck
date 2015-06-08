CREATE OR REPLACE PACKAGE PKG_OPER_FUNCTION IS

  /**
  * Работа с функциями шаблонов операций
  * @author Sergeev D.
  * @version 1
  */

  /**
  * Получить результат выполнения функции шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Oper_Templ_ID ИД шаблона операции
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Get_Oper_Function_Result
  (
    p_Document_ID   NUMBER
   ,p_Oper_Templ_ID NUMBER
   ,p_Ent_ID        NUMBER
   ,p_Obj_ID        NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Комиссия агента удержана" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_Hold_Commission
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Комиссия агента не удержана" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_Not_Hold_Commission
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Риск относится к страхованию жизни" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_Cover_Life
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Риск не относится к страхованию жизни" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_Cover_Non_Life
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Срок действия договора, по которому это покрытие, меньше 1 года" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_One_Year
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Срок действия договора, по которому это вознаграждение агента, меньше 1 года" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_One_Year_Comm
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Срок действия договора, по которому это покрытие, больше 1 года" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_Many_Years
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Срок действия договора, по которому это вознаграждение агента, больше 1 года" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_Many_Years_Comm
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  /**
  * Получить признак "Покрытие действует в первый год действия договора" для выполнения шаблона операции
  * @author Sergeev D.
  * @param p_Document_ID ИД документа
  * @param p_Ent_id ИД сущности исходного объекта
  * @param p_Obj_id ИД исходного объекта
  * @return Результат выполнения функции (1/0)
  */
  FUNCTION Is_First_Year
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

  FUNCTION Is_One_Year_CA
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;
  FUNCTION Is_Many_Years_CA
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER;

END PKG_OPER_FUNCTION;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Oper_Function IS

  --Функция, возвращающая результат функции шаблона операции
  FUNCTION Get_Oper_Function_Result
  (
    p_Document_ID   NUMBER
   ,p_Oper_Templ_ID NUMBER
   ,p_Ent_ID        NUMBER
   ,p_Obj_ID        NUMBER
  ) RETURN NUMBER IS
    v_Result     NUMBER;
    v_SQL_Text   VARCHAR2(4000);
    v_Oper_Templ OPER_TEMPL%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO v_Oper_Templ FROM OPER_TEMPL ot WHERE ot.oper_templ_id = p_Oper_Templ_ID;
      IF v_Oper_Templ.Templ_Function IS NULL
      THEN
        v_Result := 1;
      ELSE
        BEGIN
          v_SQL_Text := 'begin :v_Result := ' || v_Oper_Templ.Templ_Function ||
                        '(:p_Document_ID, :p_Ent_ID, :p_Obj_ID); end;';
          EXECUTE IMMEDIATE v_SQL_Text
            USING OUT v_Result, IN p_Document_ID, IN p_Ent_ID, IN p_Obj_ID;
        EXCEPTION
          WHEN OTHERS THEN
            v_Result := 0;
        END;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_Result := 1;
    END;
    RETURN v_Result;
  END;

  --Определить, сформировано ли удержание комиссии
  FUNCTION Is_Hold_Commission
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_Result NUMBER;
  BEGIN
    BEGIN
      SELECT NVL(arc.is_deduct, 0)
        INTO v_Result
        FROM AGENT_REPORT_CONT arc
       WHERE arc.agent_report_cont_id = p_Obj_ID;
    EXCEPTION
      WHEN OTHERS THEN
        v_Result := 0;
    END;
    RETURN v_Result;
  END;

  --Определить, что удержание комиссии не производилось
  FUNCTION Is_Not_Hold_Commission
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_Result NUMBER;
  BEGIN
    BEGIN
      SELECT NVL(arc.is_deduct, 0)
        INTO v_Result
        FROM AGENT_REPORT_CONT arc
       WHERE arc.agent_report_cont_id = p_Obj_ID;
    EXCEPTION
      WHEN OTHERS THEN
        v_Result := 0;
    END;
    IF v_Result = 1
    THEN
      v_Result := 0;
    ELSE
      v_Result := 1;
    END IF;
    RETURN v_Result;
  END;

  FUNCTION Is_Cover_Life
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT CASE
             WHEN ig.life_property = 1 THEN
              1
             ELSE
              0
           END
      INTO v_result
      FROM P_COVER                pc
          ,t_prod_line_option plo
          ,t_product_line     pl
          ,t_product_ver_lob  pvl
          ,t_lob_line         ll
          ,t_insurance_group  ig
     WHERE pc.p_cover_id = p_Obj_ID
       AND pc.t_prod_line_option_id = plo.ID
       AND plo.product_line_id = pl.ID
       AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
       AND pl.t_lob_line_id = ll.t_lob_line_id
       AND pvl.lob_id = ll.t_lob_id
       AND ll.insurance_group_id = ig.t_insurance_group_id;
  
    RETURN v_result;
  END;

  FUNCTION Is_Cover_Non_Life
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT CASE
             WHEN NVL(ig.life_property, 0) = 0 THEN
              1
             ELSE
              0
           END
      INTO v_result
      FROM P_COVER                pc
          ,ven_t_prod_line_option plo
          ,ven_t_product_line     pl
          ,ven_t_product_ver_lob  pvl
          ,ven_t_lob_line         ll
          ,ven_t_insurance_group  ig
     WHERE pc.p_cover_id = p_Obj_ID
       AND pc.t_prod_line_option_id = plo.ID
       AND plo.product_line_id = pl.ID
       AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
       AND pl.t_lob_line_id = ll.t_lob_line_id
       AND pvl.lob_id = ll.t_lob_id
       AND ll.insurance_group_id = ig.t_insurance_group_id;
  
    RETURN v_result;
  END;

  FUNCTION Is_One_Year
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT MONTHS_BETWEEN(p.end_date, p.start_date)
      INTO v_result
      FROM P_COVER  pc
          ,AS_ASSET a
          ,P_POLICY p
     WHERE pc.p_cover_id = p_Obj_ID
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id;
    IF v_result < 12
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END;

  FUNCTION Is_One_Year_Comm
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT MONTHS_BETWEEN(p.end_date, p.start_date)
      INTO v_result
      FROM P_POLICY_AGENT_COM ppac
          ,P_POLICY_AGENT     ppa
          ,P_POLICY           p
     WHERE ppac.p_policy_agent_com_id = p_Obj_ID
       AND ppac.p_policy_agent_id = ppa.p_policy_agent_id
       AND ppa.policy_header_id = p.pol_header_id
       AND p.policy_id = p_Document_ID;
    IF v_result < 12
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END;

  FUNCTION Is_Many_Years
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT MONTHS_BETWEEN(p.end_date, p.start_date)
      INTO v_result
      FROM P_COVER  pc
          ,AS_ASSET a
          ,P_POLICY p
     WHERE pc.p_cover_id = p_Obj_ID
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id;
    IF v_result >= 12
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END;

  FUNCTION Is_Many_Years_Comm
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_pol_id NUMBER;
  BEGIN
  
    SELECT dd.parent_id
      INTO v_pol_id
      FROM doc_doc  dd
          ,document d
     WHERE dd.CHILD_ID = p_document_id
       AND d.DOCUMENT_ID = dd.PARENT_ID
       AND Ent.brief_by_id(d.ENT_ID) = 'P_POLICY';
  
    SELECT MONTHS_BETWEEN(p.end_date, p.start_date)
      INTO v_result
      FROM P_POLICY_AGENT_COM ppac
          ,P_POLICY_AGENT     ppa
          ,P_POLICY           p
     WHERE ppac.p_policy_agent_com_id = p_Obj_ID
       AND ppac.p_policy_agent_id = ppa.p_policy_agent_id
       AND ppa.policy_header_id = p.pol_header_id
       AND p.policy_id = v_pol_ID;
    IF v_result >= 12
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
  
    RETURN v_result;
  END;

  FUNCTION Is_First_Year
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    --SELECT CASE
    --         WHEN p.start_date <= TO_DATE(TO_CHAR(TO_NUMBER(SUBSTR(TO_CHAR(ph.start_date, 'yyyymmdd'), 1, 4)) + 1, '0000') || SUBSTR(TO_CHAR(ph.start_date, 'yyyymmdd'), 5, 4), 'yyyymmdd') THEN 1
    --         ELSE 0
    --      END
    --INTO   v_result
    --FROM   P_COVER pc,
    --       AS_ASSET a,
    --       P_POLICY p,
    --       P_POL_HEADER ph
    --WHERE  pc.p_cover_id = p_Obj_ID AND
    --       pc.as_asset_id = a.as_asset_id AND
    --       a.p_policy_id = p.policy_id AND
    --       p.pol_header_id = ph.policy_header_id;
  
    SELECT pkg_payment.GET_YEAR_NUMBER(ph.start_date, p.start_date)
      INTO v_result
      FROM P_COVER      pc
          ,AS_ASSET     a
          ,P_POLICY     p
          ,P_POL_HEADER ph
     WHERE pc.p_cover_id = p_Obj_ID
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
    IF v_result = 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  
    --RETURN v_result;
  END;

  FUNCTION Is_One_Year_CA
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT MONTHS_BETWEEN(p.end_date, p.start_date)
      INTO v_result
      FROM P_POLICY_AGENT_COM ppac
          ,P_POLICY_AGENT     ppa
          ,P_POLICY           p
          ,P_COVER_AGENT      CA
     WHERE ppac.p_policy_agent_com_id = ca.p_policy_agent_com_id
       AND ppac.p_policy_agent_id = ppa.p_policy_agent_id
       AND ppa.policy_header_id = p.pol_header_id
       AND ca.cover_agent_id = p_Obj_ID
       AND p.policy_id = p_Document_ID;
    IF v_result < 12
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END;

  FUNCTION Is_Many_Years_CA
  (
    p_Document_ID NUMBER
   ,p_Ent_ID      NUMBER
   ,p_Obj_ID      NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_pol_id NUMBER;
  BEGIN
  
    SELECT dd.parent_id
      INTO v_pol_id
      FROM doc_doc  dd
          ,document d
     WHERE dd.CHILD_ID = p_document_id
       AND d.DOCUMENT_ID = dd.PARENT_ID
       AND Ent.brief_by_id(d.ENT_ID) = 'P_POLICY';
  
    SELECT MONTHS_BETWEEN(p.end_date, p.start_date)
      INTO v_result
      FROM P_POLICY_AGENT_COM ppac
          ,P_POLICY_AGENT     ppa
          ,P_POLICY           p
          ,P_COVER_AGENT      CA
     WHERE ppac.p_policy_agent_com_id = ca.p_policy_agent_com_id
       AND ppac.p_policy_agent_id = ppa.p_policy_agent_id
       AND ppa.policy_header_id = p.pol_header_id
       AND ca.cover_agent_id = p_Obj_ID
       AND p.policy_id = v_pol_ID;
    IF v_result >= 12
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
  
    RETURN v_result;
  END;

END;
/
