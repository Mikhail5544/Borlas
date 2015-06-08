CREATE OR REPLACE PACKAGE PKG_FRM_BSO_DOC IS

  ex_err EXCEPTION;
  Text_exMssage VARCHAR2(255);

  table_agent tmp_table_int;

  FUNCTION GetTextErr RETURN VARCHAR2;

  /*p_policy_id*/
  PROCEDURE set_policy_id(l_p_policy_id NUMBER);
  FUNCTION get_policy_id RETURN NUMBER;

  /*p_pol_header_id*/
  PROCEDURE set_pol_header_id(l_pol_header_id NUMBER);
  FUNCTION get_pol_header_id RETURN NUMBER;
  ----

  /*p_bso_type_id*/
  PROCEDURE set_bso_type_id(l_bso_type_id NUMBER);
  FUNCTION get_bso_type_id RETURN NUMBER;
  ----

  /*p_bso_type_id*/
  PROCEDURE set_series_name(l_series_name VARCHAR2);
  FUNCTION get_series_name RETURN VARCHAR2;
  ----

  /*p_bso_num */
  PROCEDURE set_bso_num(l_bso_num VARCHAR2);
  FUNCTION get_bso_num RETURN VARCHAR2;
  ----

  /*p_bso_num */
  PROCEDURE set_bso_series_id(val NUMBER);
  FUNCTION get_bso_series_id RETURN NUMBER;
  ----

  /*p_bso_num */
  PROCEDURE set_bso(l_bso bso%ROWTYPE);
  FUNCTION get_bso RETURN bso%ROWTYPE;
  ----

  FUNCTION Check_BSO RETURN INT;

END PKG_FRM_BSO_DOC;
/
CREATE OR REPLACE PACKAGE BODY PKG_FRM_BSO_DOC IS

  p_policy_id     NUMBER;
  p_pol_header_id NUMBER;
  p_bso_type_id   NUMBER;
  p_bso_series_id NUMBER;
  p_series_name   VARCHAR2(50);
  p_bso_num       VARCHAR2(50);

  p_bso bso%ROWTYPE;

  /*p_policy_id*/
  PROCEDURE set_policy_id(l_p_policy_id NUMBER) IS
  BEGIN
    p_policy_id := l_p_policy_id;
  END set_policy_id;

  FUNCTION get_policy_id RETURN NUMBER IS
  BEGIN
    RETURN p_policy_id;
  END get_policy_id;
  ----

  /*p_pol_header_id*/
  PROCEDURE set_pol_header_id(l_pol_header_id NUMBER) IS
  BEGIN
    p_pol_header_id := l_pol_header_id;
  END set_pol_header_id;

  FUNCTION get_pol_header_id RETURN NUMBER IS
  BEGIN
    RETURN p_pol_header_id;
  END get_pol_header_id;
  ----

  /*p_bso_type_id*/
  PROCEDURE set_bso_type_id(l_bso_type_id NUMBER) IS
  BEGIN
    p_bso_type_id := l_bso_type_id;
  END set_bso_type_id;

  FUNCTION get_bso_type_id RETURN NUMBER IS
  BEGIN
    RETURN p_bso_type_id;
  END get_bso_type_id;
  ----

  /*p_bso_type_id*/
  PROCEDURE set_series_name(l_series_name VARCHAR2) IS
  BEGIN
    p_series_name := l_series_name;
  END set_series_name;

  FUNCTION get_series_name RETURN VARCHAR2 IS
  BEGIN
    RETURN p_series_name;
  END get_series_name;
  ----

  /*p_bso_num */
  PROCEDURE set_bso_num(l_bso_num VARCHAR2) IS
  BEGIN
    p_bso_num := l_bso_num;
  END set_bso_num;

  FUNCTION get_bso_num RETURN VARCHAR2 IS
  BEGIN
    RETURN p_bso_num;
  END get_bso_num;
  ----

  /*p_bso_num */
  PROCEDURE set_bso(l_bso bso%ROWTYPE) IS
  BEGIN
    p_bso := l_bso;
  END set_bso;

  FUNCTION get_bso RETURN bso%ROWTYPE IS
  BEGIN
    RETURN p_bso;
  END get_bso;
  ----

  PROCEDURE set_bso_series_id(val NUMBER) IS
  BEGIN
    p_bso_series_id := val;
  END set_bso_series_id;

  FUNCTION get_bso_series_id RETURN NUMBER IS
  BEGIN
    RETURN p_bso_series_id;
  END get_bso_series_id;

  FUNCTION GetBSO RETURN bso%ROWTYPE IS
    rec_bso bso%ROWTYPE;
  BEGIN
    SELECT b.*
      INTO rec_bso
      FROM bso        b
          ,bso_series bs
     WHERE bs.bso_type_id = p_bso_type_id
       AND b.bso_series_id = bs.bso_series_id
       AND bs.series_name = p_series_name
       AND (b.num = p_bso_num OR b.num <> p_bso_num AND b.num LIKE p_bso_num || '_' AND
           bs.chars_in_num = 7 AND length(p_bso_num) = 6);
  
    RETURN rec_bso;
  EXCEPTION
    WHEN OTHERS THEN
      Text_exMssage := 'БСО не найден';
      RAISE ex_err;
  END GetBSO;

  PROCEDURE LoadAgentByPolicy IS
  BEGIN
    table_agent := tmp_table_int();
  
    SELECT pa.AG_CONTRACT_HEADER_ID BULK COLLECT
      INTO table_agent
      FROM p_policy            pp
          ,p_policy_agent      pa
          ,policy_agent_status pas
     WHERE pp.policy_id = p_policy_id
       AND pa.policy_header_id = pp.POL_HEADER_ID
       AND pas.policy_agent_status_id = pa.status_id
       AND pas.brief = 'CURRENT';
  
    --  if (table_agent.Count = 0) then
    --       Text_exMssage := 'Не найдены агенты имеющие статус Действующие';
    --      raise ex_err;
    -- end if;
  
  EXCEPTION
    WHEN ex_err THEN
      RAISE ex_err;
    WHEN OTHERS THEN
      Text_exMssage := 'Неизвестная ошибка. ' || 'LoadAgentByPolicy ' || SQLERRM || ' -- ' || SQLCODE;
      RAISE ex_err;
  END LoadAgentByPolicy;

  PROCEDURE IsUsed IS
  BEGIN
  
    IF (p_bso.pol_header_id IS NOT NULL OR p_bso.policy_id IS NOT NULL)
    THEN
      Text_exMssage := 'БСО уже использован';
      RAISE ex_err;
    END IF;
  END IsUsed;

  PROCEDURE IsFreeBSO IS
  
    CURSOR cur_get_bso
    (
      cv_BSO_SERIES_ID NUMBER
     ,cv_NUM           VARCHAR2
     ,cv_contact_id    NUMBER
    ) IS
      SELECT b.BSO_ID
        FROM bso                b
            ,bso_hist           bh
            ,bso_hist_type      bht
            ,AG_CONTRACT_HEADER agh
       WHERE b.bso_hist_id = bh.bso_hist_id
         AND bht.bso_hist_type_id = bh.hist_type_id
         AND UPPER(bht.brief) = UPPER('Выдан')
         AND b.BSO_SERIES_ID = cv_BSO_SERIES_ID
         AND b.NUM = cv_NUM
         AND bh.contact_id = agh.AGENT_ID
         AND agh.AG_CONTRACT_HEADER_ID = cv_contact_id;
  
    rec_get_bso cur_get_bso%ROWTYPE;
  
  BEGIN
  
    FOR r IN table_agent.first .. table_agent.last
    LOOP
    
      OPEN cur_get_bso(get_bso_series_id, get_bso_num, table_agent(r));
      FETCH cur_get_bso
        INTO rec_get_bso;
    
      IF (cur_get_bso%FOUND)
      THEN
        CLOSE cur_get_bso;
        RETURN;
      END IF;
    
      CLOSE cur_get_bso;
    END LOOP;
  
    Text_exMssage := 'У текущих агентов не был найден необходимый БСО.';
    RAISE ex_err;
  
  EXCEPTION
    WHEN ex_err THEN
      RAISE ex_err;
    WHEN OTHERS THEN
      Text_exMssage := 'Неизвестная ошибка.' || 'IsFreeBSO';
      RAISE ex_err;
  END IsFreeBSO;

  -- проверка на наличие полиса у другого агента
  PROCEDURE CheckOtherAgent IS
    v_count          NUMBER;
    v_pol_start_date DATE;
  BEGIN
  
    SELECT pp.start_date INTO v_pol_start_date FROM p_policy pp WHERE pp.policy_id = get_policy_id;
  
    SELECT COUNT(1)
      INTO v_count
      FROM bso           b
          ,bso_hist      bh
          ,bso_hist_type bht
          ,bso_doc_cont  bdc
          ,bso_document  bd
          ,ven_contact   c
     WHERE bh.bso_id = b.bso_id
       AND bh.num = (SELECT MAX(bh1.num)
                       FROM bso_hist bh1
                      WHERE bh1.bso_id = b.bso_id
                        AND bh1.hist_date <= v_pol_start_date)
       AND bht.bso_hist_type_id = bh.hist_type_id
       AND bht.brief = 'Выдан'
       AND bh.bso_doc_cont_id = bdc.bso_doc_cont_id
       AND bd.bso_document_id = bdc.bso_document_id
       AND bd.contact_to_id = c.contact_id
       AND b.bso_id = p_bso.bso_id
       AND c.contact_id IN
           (SELECT ah.agent_id
              FROM p_policy_agent      pa
                  ,policy_agent_status pas
                  ,ag_contract_header  ah
             WHERE pas.brief = 'CURRENT'
               AND pas.policy_agent_status_id = pa.status_id
               AND ah.ag_contract_header_id = pa.ag_contract_header_id);
  
    IF v_count > 0
    THEN
      Text_exMssage := 'Данный бланк выдан другому агенту.';
      RAISE ex_err;
    ELSE
      NULL;
    
      /*      
      -- взято из формы
      -- непонятно назначение этого кода
      -- по идее должен быть эксепшн с ошибкой
      
      select pkg_bso.get_bso_last_status_brief(v_bso.bso_id)
            into v_st
            from dual;
            if v_st='Зарезервирован' then
              message('Передача БСО не завершена'); 
              prizn:=1;          
            end if;  */
    
    END IF;
  
    RETURN;
  END;

  --проверка на наличие полиса у МОЛ
  PROCEDURE CheckMOL IS
    v_mo_contact_id NUMBER;
  BEGIN
  
    BEGIN
      -- поиск материально-ответственного с бланком
      SELECT contact_to_id
        INTO v_mo_contact_id
        FROM (SELECT bd.contact_to_id
                FROM bso           b
                    ,bso_series    bs
                    ,bso_hist      bh
                    ,bso_hist_type bht
                    ,bso_doc_cont  bdc
                    ,bso_document  bd
               WHERE b.num = p_bso_num
                 AND bs.series_name = p_series_name
                 AND bs.bso_type_id = p_bso_type_id
                 AND bht.brief IN ('НеВыдан', 'Передан')
                 AND bs.bso_series_id = b.bso_series_id
                 AND bh.bso_id = b.bso_id
                 AND bht.bso_hist_type_id = bh.hist_type_id
                 AND bdc.bso_doc_cont_id = bh.bso_doc_cont_id
                 AND bd.bso_document_id = bdc.bso_document_id
               ORDER BY bh.hist_date DESC
                       ,bht.brief    DESC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          -- поиск контакта с ролью BSOUSER с бланком
          -- ОК, если найден
          SELECT contact_to_id
            INTO v_mo_contact_id
            FROM (SELECT bd.contact_to_id
                    FROM bso             b
                        ,bso_series      bs
                        ,bso_hist        bh
                        ,bso_hist_type   bht
                        ,bso_doc_cont    bdc
                        ,bso_document    bd
                        ,cn_contact_role cr
                        ,t_contact_role  tcr
                   WHERE b.num = p_bso_num
                     AND bs.series_name = p_series_name
                     AND bs.bso_type_id = p_bso_type_id
                     AND bht.brief IN ('Выдан')
                     AND bs.bso_series_id = b.bso_series_id
                     AND bh.bso_id = b.bso_id
                     AND bht.bso_hist_type_id = bh.hist_type_id
                     AND bdc.bso_doc_cont_id = bh.bso_doc_cont_id
                     AND bd.bso_document_id = bdc.bso_document_id
                     AND bd.contact_to_id = cr.contact_id
                     AND cr.role_id = tcr.id
                     AND tcr.brief = 'BSOUSER'
                   ORDER BY bh.hist_date DESC
                           ,bht.brief    DESC)
           WHERE rownum = 1;
          RETURN;
        EXCEPTION
          WHEN OTHERS THEN
            Text_exMssage := 'Не найден мат. ответственный.';
            RAISE ex_err;
        END;
    END;
  
    -- проверяем на принадлежность МОЛ филиалу пользователя
    IF pkg_app_param.get_app_param_n('CLIENTID') <> 11
    THEN
      DECLARE
        v_dummy NUMBER;
      BEGIN
        SELECT 1
          INTO v_dummy
          FROM employee          e
              ,organisation_tree ot
              ,employee_hist     eh
         WHERE e.organisation_id = ot.organisation_tree_id
           AND eh.employee_id = e.employee_id
           AND eh.date_hist = (SELECT MAX(ehlast.date_hist)
                                 FROM employee_hist ehlast
                                WHERE ehlast.employee_id = e.employee_id
                                  AND ehlast.date_hist <= SYSDATE
                                  AND ehlast.is_kicked = 0)
           AND e.contact_id = v_mo_contact_id
           AND ot.organisation_tree_id = pkg_filial.get_user_org_tree_id;
      EXCEPTION
        WHEN no_data_found THEN
          Text_exMssage := 'Мат. ответственный в другом филиале.';
          RAISE ex_err;
      END;
    END IF;
  
    RETURN;
  END;

  FUNCTION Check_BSO RETURN INT IS
  BEGIN
    p_bso := GetBSO;
    IsUsed;
  
    LoadAgentByPolicy;
    IF table_agent.Count > 0
    THEN
      IF pkg_app_param.get_app_param_n('CLIENTID') <> 11
      THEN
        IsFreeBSO;
      END IF;
    ELSE
      CheckOtherAgent;
      CheckMOL;
    END IF;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN ex_err THEN
      RETURN Utils.c_false;
    WHEN OTHERS THEN
      Text_exMssage := 'Неизвестная ошибка.' || 'Check_BSO';
      RETURN Utils.c_false;
  END Check_BSO;

  FUNCTION GetTextErr RETURN VARCHAR2 IS
  BEGIN
    RETURN Text_exMssage;
  END GetTextErr;

END PKG_FRM_BSO_DOC;
/
