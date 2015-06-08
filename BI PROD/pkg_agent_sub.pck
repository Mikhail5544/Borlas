CREATE OR REPLACE PACKAGE Pkg_Agent_Sub IS

  -- Author  : T.SHIDLOVSKAYA
  -- Created : 12.07.2007 11:18:21
  -- Purpose :

  /**
  *  анализ: Вырастивший менеджер1 (M1) координировал менеджер2 (М2) 30 дней, пока тот (М2) был агентом
  *
  * @author T.SHIDLOVSKAYA
  * @param p_ag_contract_header_id_1 ИД агентского договора 1
  * @param p_ag_contract_header_id_2 ИД агентского договора 2
  *
  * @return boolean
  */
  FUNCTION CHECK_M1_M2
  (
    p_ag_contract_header_id_1 IN NUMBER
   ,p_ag_contract_header_id_2 IN NUMBER
  ) RETURN BOOLEAN;

  /**
  *  анализ: менеджер (М) рекрутировал не менее 2-х агентов, пока был агентом
  *
  * @author T.SHIDLOVSKAYA
  * @param p_ag_contract_header_id ИД агентского договора (Менеджера)
  *
  * @return boolean
  */
  FUNCTION CHECK_M(p_ag_contract_header_id IN NUMBER) RETURN BOOLEAN;

  /**
   * процедура проверки наличия у агентов по договору
   * записей по ставкам по программам в договоре страхования.
   * @author T.SHIDLOVSKAYA
   *
   * @param p_policy_id - версия договора страхования
  */
  PROCEDURE CHECK_agent_program(p_policy_id NUMBER);

  /**
   * процедура проверки наличия агентов по договору
   * @author T.SHIDLOVSKAYA
   *
   * @param p_policy_id - версия договора страхования
  */
  PROCEDURE CHECK_agent_policy(p_policy_id NUMBER);

  /**
   * функция подсчета действующих агентов по договору
   * @author Chikashova
   * @param p_policy_id - версия договора страхования
   * @return number
  */
  FUNCTION count_agent_policy(p_policy_id NUMBER) RETURN NUMBER;
  /**
   * процедура изменения статуса договора "Новый" в "Напечатан"
   * @author T.SHIDLOVSKAYA
   *
   * @param p_ag_contract_id - версия агентского договора
  */
  PROCEDURE Change_agent_contract_status(p_ag_contract_id IN NUMBER);

  /**
   * функция проверяет права пользователя на выполнение расчетов
   * используется в формах : ag_vedom, ag_report, ag_report-dav
   * @author T.SHIDLOVSKAYA
   *
   * @param p_ag_contract_id - версия агентского договора
  */
  FUNCTION Check_agent_role RETURN BOOLEAN;

  /**
   * Процедура установки статуса для отчетов по агентским вознаграждениям,
   * относящимся к данной ведомости
   *
   * p_AG_VEDOM_AV_ID - иди ведомости агентских вознаграждений
  */
  PROCEDURE set_vedom_status(p_AG_VEDOM_AV_ID IN NUMBER);

  /**
   * процедура проверок перед удалением связки агент-полиси
   * @author T.SHIDLOVSKAYA
   *
   *  @param p_head_policy_id - заголовок договора страхования
   *  @param p_ag_con_head_id - заголовок агентского договора
  */
  PROCEDURE Checks_connect_agent_policy
  (
    p_head_policy_id NUMBER
   ,p_ag_con_head_id IN NUMBER
  );

  /**
   * процедура удалениz связки агент-полиси
   * @author T.SHIDLOVSKAYA
   *
   *  @param p_head_policy_id - заголовок договора страхования
   *  @param p_ag_con_head_id - заголовок агентского договора
  */
  PROCEDURE PRE_del_connect_agent_policy
  (
    p_head_policy_id NUMBER
   ,p_ag_con_head_id IN NUMBER
  );

  /**
   * функция определение руководителя менеджера у агента на дату
   * возвращает : иди заголовока договора менеджера (если нет , то иди заголовока агентского договора)
   * @author Surovtsev Alexey
   *
   *  @param p_date - на заданную дату
   *  @param p_ag_header - иди заголовока агентского договора
  */

  FUNCTION Getidmanagerbydate
  (
    p_date      DATE
   ,p_ag_header NUMBER
  ) RETURN NUMBER;
  FUNCTION GetIdRecruterByDate
  (
    p_date      DATE
   ,p_ag_header NUMBER
  ) RETURN NUMBER;
  FUNCTION IsRecrutCalcByDate
  (
    p_date             DATE
   ,p_ag_header_recrut NUMBER
   ,p_ag_header_agent  NUMBER
  ) RETURN NUMBER;
  FUNCTION Get_Leader_Id_By_Date
  (
    p_data_begin      DATE
   ,p_ag_contr_header NUMBER
   ,p_data_pay        DATE
  ) RETURN NUMBER;
  FUNCTION get_ac_contrat_id_by_date
  (
    p_ag_contr_header NUMBER
   ,p_data_pay        DATE
  ) RETURN NUMBER;
  FUNCTION A7_get_money_analyze
  (
    p_acp_id IN NUMBER
   ,p_date   IN DATE DEFAULT SYSDATE
  ) RETURN INTEGER;
  FUNCTION get_p_agent_status_by_date
  (
    p_ach_id           NUMBER
   ,p_policy_header_id IN NUMBER
   ,p_date             DATE
  ) RETURN VARCHAR2;
  FUNCTION double_trans_analyze
  (
    p_ag_contract_header_id IN NUMBER
   ,p_part_agent            IN NUMBER
   ,p_trans_id              IN NUMBER
  ) RETURN NUMBER;

END Pkg_Agent_Sub;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Agent_Sub IS

  ---///// анализ: Вырастивший менеджер1 (M1) координировал менеджер2 (М2) 30 дней, пока тот (М2) был агентом
  ---      M1 растит M2 из агента в менеджеры
  FUNCTION CHECK_M1_M2
  (
    p_ag_contract_header_id_1 IN NUMBER
   ,p_ag_contract_header_id_2 IN NUMBER
  ) RETURN BOOLEAN IS
  
    CURSOR k_period IS
    /*      select ac2.category_id, ac2.date_begin
                                 from ven_ag_contract_header ah1 -- менеджер1
                                 join ven_ag_contract ac1 on (ah1.ag_contract_header_id=ac1.contract_id) -- все версии менеджер1
                                 join ven_ag_contract ac2 on (ac2.contract_f_lead_id = ac1.ag_contract_id) -- выросший на плечах у менеджер1
                                 join ven_ag_contract_header ah2 on (ah2.ag_contract_header_id=ac2.contract_id ) -- менеджер2 в купе со всеми своими версиями
                                 -- ограничения
                                 where
                                 -- выбираем единственную действующую версию для менеджер1, чтобы не плодить ненужных строк
                                     ah1.last_ver_id = PKG_AGENT_1.find_last_ver_id( ac2.contract_f_lead_id )
                                 -- выбираем конкрентные договора для анализа
                                 and ah1.ag_contract_header_id = p_ag_contract_header_id_1
                                 and ah2.ag_contract_header_id = p_ag_contract_header_id_2
                                 order by ac2.date_begin;*/
      SELECT ac2.date_begin
            ,ac2.category_id
            ,ac2.contract_f_lead_id
        FROM ven_ag_contract_header ah2 -- менеджер2 (M2)
        JOIN ven_ag_contract ac2
          ON (ah2.ag_contract_header_id = ac2.contract_id) -- все версии M2
       WHERE ah2.ag_contract_header_id = p_ag_contract_header_id_2
       ORDER BY ac2.date_begin
      
      ;
  
    v_period           k_period%ROWTYPE;
    v_period_start_new DATE := SYSDATE;
    v_period_start_old DATE := SYSDATE;
    v_period_end_old   DATE := SYSDATE;
  
    v_cat_ag          NUMBER; -- эталон
    v_cat_id          NUMBER := 99;
    v_M1_last_ver_id  NUMBER; -- эталон
    v_ag_last_ver_new NUMBER := 0;
    v_ag_last_ver_old NUMBER := 0;
    v_prizn           BOOLEAN := FALSE;
  
  BEGIN
    -- поиск категории для агента (для эталона)
    SELECT ca.ag_category_agent_id INTO v_cat_ag FROM ven_ag_category_agent ca WHERE ca.brief = 'AG';
    -- поиск ласт-вершн для менеджера1 (для эталона)
    SELECT ah1.last_ver_id
      INTO v_M1_last_ver_id
      FROM ven_ag_contract_header ah1
     WHERE ah1.ag_contract_header_id = p_ag_contract_header_id_1;
  
    OPEN k_period;
    LOOP
      FETCH k_period
        INTO v_period;
      EXIT WHEN k_period%NOTFOUND;
    
      v_ag_last_ver_new := Pkg_Agent_1.find_last_ver_id(v_period.contract_f_lead_id);
      -- при отсутствии "вырастившего" - принимается его значение из предыдущей версии
      IF v_ag_last_ver_new = 0
      THEN
        v_ag_last_ver_new := v_ag_last_ver_old;
      END IF;
    
      IF v_period.category_id <> v_cat_id -- произошла смена категории
         OR v_ag_last_ver_new <> v_ag_last_ver_old -- смена "вырастившего"
      THEN
        v_period_start_old := v_period_start_new; -- присвоение даты предыдущего периода
      
        v_period_start_new := v_period.date_begin;
        v_period_end_old   := v_period.date_begin; -- окончание срока предыдущего периода
      
        -- проверка условий: 1.)текущая категория = агент, 2.)вырастивший = М1, 3.)период более 30 дней
        IF v_cat_id = v_cat_ag
           AND v_M1_last_ver_id = v_ag_last_ver_new
           AND (v_period_end_old - v_period_start_old) + 1 >= 30
        THEN
          v_prizn := TRUE;
          EXIT;
        END IF;
        v_cat_id          := v_period.category_id; -- для проверки сменs категории
        v_ag_last_ver_old := v_ag_last_ver_new; -- для проверки смены вырастившего
      END IF;
    END LOOP;
    IF (NOT v_prizn)
       AND v_cat_id = v_cat_ag
       AND v_M1_last_ver_id = v_ag_last_ver_new
       AND (v_period_end_old - v_period_start_old) + 1 >= 30
    THEN
      v_prizn := TRUE;
    END IF;
    CLOSE k_period;
    RETURN(v_prizn);
  END;

  ---////// анализ: менеджер (М) рекрутировал не менее 2-х агентов, пока был агентом
  FUNCTION CHECK_M(p_ag_contract_header_id IN NUMBER) RETURN BOOLEAN IS
  
    v_rez   NUMBER := 0;
    v_prizn BOOLEAN := FALSE;
  
  BEGIN
    SELECT COUNT(DISTINCT ah2.ag_contract_header_id)
      INTO v_rez
      FROM ven_ag_contract_header ah1 -- менеджер
      JOIN ven_ag_contract ac1
        ON (ah1.ag_contract_header_id = ac1.contract_id) -- все версии менеджер
      JOIN ven_ag_contract ac2
        ON (ac2.contract_recrut_id = ac1.ag_contract_id) -- рекрутируемый агент менеджером1
      JOIN ven_ag_contract_header ah2
        ON (ah2.ag_contract_header_id = ac2.contract_id) -- агент в купе со всеми своими версиями
    -- ограничения
     WHERE
    -- выбираем конкрентные договора для менеджера
     ah1.ag_contract_header_id = p_ag_contract_header_id
    -- выбираем версии договоров менеджера, пока он был агентом
     AND ac1.category_id =
     (SELECT ca.ag_category_agent_id FROM ven_ag_category_agent ca WHERE ca.brief = 'AG');
  
    -- не менее 2-х агентов
    IF v_rez >= 2
    THEN
      v_prizn := TRUE;
    END IF;
    RETURN(v_prizn);
  
  END;
  ---/// процедура проверки наличия у агентов по договору
  --     записей по ставкам по программам в договоре страхования.

  PROCEDURE CHECK_agent_program(p_policy_id NUMBER) IS
    v_rez NUMBER := 0;
  BEGIN
    -- процедура проверки наличия у каждого действующего агента по договору  записей по ставкам
    FOR rr IN (SELECT pp.policy_id
                     ,pa.p_policy_agent_id
                     ,sc.brief
                 FROM ven_p_pol_header ph
                 JOIN ven_p_policy pp
                   ON (pp.pol_header_id = ph.policy_header_id)
                  AND (pp.policy_id = p_policy_id)
                 LEFT JOIN ven_p_policy_agent pa
                   ON (ph.policy_header_id = pa.policy_header_id)
                 LEFT JOIN ven_policy_agent_status pas
                   ON (pas.policy_agent_status_id = pa.status_id)
                  AND pas.brief = 'CURRENT'
                 LEFT JOIN ven_t_prod_sales_chan psc
                   ON (psc.product_id = ph.product_id)
                  AND (psc.SALES_CHANNEL_ID = ph.SALES_CHANNEL_ID)
                 LEFT JOIN ven_t_sales_channel sc
                   ON (sc.id = psc.sales_channel_id))
    LOOP
    
      BEGIN
      
        SELECT 1
          INTO v_rez
          FROM dual
         WHERE EXISTS (SELECT '1'
                  FROM dual
                 WHERE rr.brief = 'DIRECT'
                UNION ALL
                SELECT '1'
                  FROM ven_p_policy_agent_com c
                 WHERE c.p_policy_agent_id = rr.p_policy_agent_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_rez := 0;
      END;
      IF v_rez = 0
      THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'По договору существуют действующие агенты, у которых не определены ставки');
      END IF;
    END LOOP;
  END;

  ---/// процедура проверки наличия агентов по договору
  PROCEDURE CHECK_agent_policy(p_policy_id NUMBER) IS
    v_rez   NUMBER := 0;
    v_brief VARCHAR2(200);
  BEGIN
    BEGIN
      SELECT COUNT(*)
            ,sc.brief
        INTO v_rez
            ,v_brief
        FROM ven_p_pol_header ph
        JOIN ven_p_policy pp
          ON (pp.pol_header_id = ph.policy_header_id)
         AND (pp.policy_id = p_policy_id)
        LEFT JOIN ven_p_policy_agent pa
          ON (ph.policy_header_id = pa.policy_header_id)
        LEFT JOIN ven_policy_agent_status pas
          ON (pas.policy_agent_status_id = pa.status_id)
         AND pas.brief = 'CURRENT'
        LEFT JOIN ven_t_prod_sales_chan psc
          ON (psc.product_id = ph.product_id)
         AND (psc.SALES_CHANNEL_ID = ph.SALES_CHANNEL_ID)
        LEFT JOIN ven_t_sales_channel sc
          ON (sc.id = psc.sales_channel_id)
       GROUP BY sc.brief;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'По договору не существует действующих агентов: ' || SQLERRM);
    END;
    IF v_rez = 0
       AND NOT (v_brief = 'DIRECT')
    THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'По договору не существует действующих агентов');
    END IF;
  
  END;

  --/// функция подсчета действующих агентов по договору
  FUNCTION count_agent_policy(p_policy_id NUMBER) RETURN NUMBER IS
    v_rez NUMBER := 0;
  BEGIN
    BEGIN
      SELECT COUNT(*)
        INTO v_rez
        FROM p_policy           pp
            ,p_policy_agent_doc pad
            ,document           d
            ,doc_status_ref     dsr
       WHERE pp.policy_id = p_policy_id
         AND pp.pol_header_id = pad.policy_header_id
         AND pad.p_policy_agent_doc_id = d.document_id
         AND d.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'CURRENT';
      --Старая версия
      /*      SELECT COUNT(*)
       INTO v_rez
        FROM ven_p_pol_header ph
       JOIN ven_p_policy pp ON (pp.pol_header_id = ph.policy_header_id)
       JOIN ven_p_policy_agent pa ON (ph.policy_header_id =
                                     pa.policy_header_id)
       JOIN ven_policy_agent_status pas ON (pas.policy_agent_status_id =
                                           pa.status_id)
       WHERE pp.policy_id = p_policy_id
        AND pas.brief = 'CURRENT';*/
    EXCEPTION
      WHEN OTHERS THEN
        v_rez := 0;
    END;
    RETURN v_rez;
  END;

  ---/// процедура изменения статуса договора "Новый" в "Напечатан"
  PROCEDURE Change_agent_contract_status(p_ag_contract_id IN NUMBER) IS
    v_ag_contract_header_id NUMBER;
  BEGIN
    BEGIN
      SELECT h.ag_contract_header_id
        INTO v_ag_contract_header_id
        FROM ven_ag_contract_header h
        JOIN ven_ag_contract c
          ON (h.last_ver_id = c.ag_contract_id)
       WHERE Doc.get_doc_status_brief(h.ag_contract_header_id) = 'NEW'
         AND c.ag_contract_id = p_ag_contract_id;
    
      Pkg_Agent_1.set_last_ver(v_ag_contract_header_id, p_ag_contract_id);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END;

  /**
   * функция проверяет права пользователя на выполнение расчетов
   * используется в форме : ag_vedom
   * @author T.SHIDLOVSKAYA
   *
   * @param p_ag_contract_id - версия агентского договора
  */
  FUNCTION Check_agent_role RETURN BOOLEAN IS
    v_right_brief VARCHAR2(100) := 'MANAGER_CENTRE';
  BEGIN
    IF Safety.check_right_custom(v_right_brief) = 0
    THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END;
  /**
   * Процедура установки статуса для отчетов по агентским вознаграждениям,
   * относящимся к данной ведомости
   *
   * p_AG_VEDOM_AV_ID - иди ведомости агентских вознаграждений
  */
  PROCEDURE set_vedom_status(p_AG_VEDOM_AV_ID IN NUMBER) IS
    v_status_id    NUMBER;
    v_status_brief VARCHAR2(100);
    v_status_stop  NUMBER;
    v_status_date  DATE;
  BEGIN
    -- остановлен
    SELECT r.doc_status_ref_id INTO v_status_stop FROM DOC_STATUS_REF r WHERE r.brief = 'STOP';
  
    --Каткевич А.Г. 14/01/2009 последний статус всегда имеет sysdate
    /*    SELECT s.start_date
     INTO v_status_date
     FROM DOC_STATUS s
    WHERE s.doc_status_id =
          (SELECT MAX(s1.doc_status_id)
             FROM DOC_STATUS s1
            WHERE s1.document_id = p_AG_VEDOM_AV_ID);*/
  
    v_status_id := Doc.get_doc_status_id(p_AG_VEDOM_AV_ID); --, v_status_date);
    FOR rr IN (SELECT r.agent_report_id
                 FROM ven_agent_report r
                WHERE r.ag_vedom_av_id = p_AG_VEDOM_AV_ID)
    LOOP
      IF Doc.get_doc_status_id(rr.agent_report_id) <> v_status_id
         AND Doc.get_doc_status_id(rr.agent_report_id /*, v_status_date*/) <> v_status_stop
      THEN
        /* IF (Doc.get_doc_status_brief(rr.agent_report_id \*, v_status_date*\) =
        'NULL' AND
        Doc.get_doc_status_brief(p_AG_VEDOM_AV_ID \*, v_status_date*\) =
        'NEW') OR
        (Doc.get_doc_status_brief(rr.agent_report_id\*, v_status_date*\) =
        'NEW' AND
        Doc.get_doc_status_brief(p_AG_VEDOM_AV_ID \*, v_status_date*\) =
        'PRINTED') OR
        (Doc.get_doc_status_brief(rr.agent_report_id \*, v_status_date*\) =
        'PRINTED' AND
        Doc.get_doc_status_brief(p_AG_VEDOM_AV_ID \*, v_status_date*\) =
        'CONFIRMED') THEN*/
        BEGIN
          Doc.set_doc_status(rr.agent_report_id, v_status_id);
          --                               v_status_date);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000
                                   ,'Can''t set status Report=' || rr.agent_report_id || ' ' ||
                                    SQLERRM);
        END;
        -- END IF;
      END IF;
    END LOOP;
  END;

  ---/// процедура проверок перед удалением связки агент-полиси
  PROCEDURE Checks_connect_agent_policy
  (
    p_head_policy_id NUMBER
   ,p_ag_con_head_id IN NUMBER
  ) IS
    v_prizn       NUMBER := 0;
    v_policy_id   NUMBER;
    v_policy_stat VARCHAR2(100);
  BEGIN
    -- по полиси в статусе "проект" можно удалять связь агент-полиси
    BEGIN
      SELECT Doc.get_doc_status_brief(pp.policy_id)
            ,pp.policy_id
        INTO v_policy_stat
            ,v_policy_id
        FROM ven_p_pol_header ph
        JOIN ven_p_policy pp
          ON (pp.pol_header_id = ph.policy_header_id)
       WHERE ph.policy_header_id = p_head_policy_id;
      IF v_policy_stat <> 'PROJECT'
      THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Удаление агента возможно только для полиси в статусе "Проект"');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Пакет PKG_AGENT_SUB - проверьте целостность БД');
    END;
    -- по данному договору есть акты (ОАВ и ДАВ) по данному агентскому договору и по полиси
    BEGIN
      SELECT COUNT(*)
        INTO v_prizn
        FROM ven_agent_report rep
       WHERE rep.ag_contract_h_id = p_ag_con_head_id
         AND (EXISTS (SELECT '1'
                        FROM ven_agent_report_cont c
                       WHERE c.agent_report_id = rep.agent_report_id
                         AND c.policy_id = v_policy_id) OR EXISTS
              (SELECT '1'
                 FROM ven_agent_report_dav d
                WHERE d.agent_report_id = rep.agent_report_id
                  AND EXISTS
                (SELECT '1' FROM ven_agent_report_dav_ct ct WHERE ct.policy_id = v_policy_id)));
      IF v_prizn <> 0
      THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'По агентскому договору существуют акты расчетов вознаграждения');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_prizn := 0;
    END;
    BEGIN
      SELECT COUNT(*)
        INTO v_prizn
        FROM UREF t
        JOIN ENTITY e
          ON (e.ent_id = t.ure_id AND e.brief = 'P_POL_HEADER')
       WHERE t.uro_id = p_head_policy_id;
      IF v_prizn <> 0
      THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'По данному полиси существуют проводки');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_prizn := 0;
    END;
  END;

  ---/// процедура удаления связки агент-полиси
  PROCEDURE PRE_del_connect_agent_policy
  (
    p_head_policy_id NUMBER
   ,p_ag_con_head_id IN NUMBER
  ) IS
    v_policy_id NUMBER;
  BEGIN
    -- по полиси в статусе "проект" можно удалять связь агент-полиси
    BEGIN
      SELECT pp.policy_id
        INTO v_policy_id
        FROM ven_p_pol_header ph
        JOIN ven_p_policy pp
          ON (pp.pol_header_id = ph.policy_header_id)
       WHERE ph.policy_header_id = p_head_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Пакет PKG_AGENT_SUB - проверьте целостность БД');
    END;
    -- удаление ставок
    BEGIN
      DELETE FROM ven_p_policy_agent_com c
       WHERE EXISTS (SELECT '1'
                FROM ven_p_policy_agent pa
                JOIN ven_p_pol_header ph
                  ON (ph.policy_header_id = pa.policy_header_id)
                JOIN ven_p_policy pp
                  ON (pp.pol_header_id = ph.policy_header_id)
                JOIN ven_ag_contract_header h
                  ON (pa.ag_contract_header_id = h.ag_contract_header_id)
               WHERE pp.policy_id = v_policy_id
                 AND h.ag_contract_header_id = p_ag_con_head_id
                 AND c.p_policy_agent_id = pa.p_policy_agent_id);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    /* удаление агентов производится в форме
    -- удаление агентов по полиси
        begin
           delete from ven_p_policy_agent pa
           where pa.p_policy_agent_id = r.p_policy_agent_id;
        exception when others then null;
        end;
    */
  END;

  -- определение руководителя менеджера у агента на дату
  FUNCTION Getidmanagerbydate
  (
    p_date      DATE
   ,p_ag_header NUMBER
  ) RETURN NUMBER IS
    res_proc NUMBER;
  
    CURSOR cur_res
    (
      cv_date      DATE
     ,cv_ag_header NUMBER
    ) IS
      SELECT Acc.contract_id
        FROM (SELECT NVL(ag.contract_leader_id, ag.ag_contract_id) res
                FROM (SELECT a.ag_contract_id
                        FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m
                                    ,ac.ag_contract_id
                                FROM AG_CONTRACT ac
                               WHERE ac.date_begin <= cv_date
                                 AND ac.CONTRACT_ID = cv_ag_header) a
                       WHERE a.m = a.ag_contract_id) b
                    ,AG_CONTRACT ag
               WHERE b.ag_contract_id = ag.ag_contract_id) C
            ,AG_CONTRACT Acc
       WHERE Acc.AG_CONTRACT_ID = c.res
      UNION ALL
      SELECT -1
        FROM dual;
  
  BEGIN
  
    OPEN cur_res(p_date, p_ag_header);
    FETCH cur_res
      INTO res_proc;
  
    IF (res_proc = -1)
    THEN
      res_proc := NULL;
    END IF;
  
    CLOSE cur_res;
    RETURN res_proc;
  END;

  FUNCTION GetIdRecruterByDate
  (
    p_date      DATE
   ,p_ag_header NUMBER
  ) RETURN NUMBER IS
  
    CURSOR cur_rec
    (
      cv_date      DATE
     ,cv_ag_header NUMBER
    ) IS
      SELECT a_rec.CONTRACT_ID
        FROM AG_CONTRACT a_agent
            ,AG_CONTRACT a_rec
       WHERE a_agent.contract_id = cv_ag_header
         AND a_rec.AG_CONTRACT_ID = a_agent.contract_f_lead_id
         AND a_agent.DATE_BEGIN <= cv_date
         AND a_agent.DATE_END >= cv_date
       ORDER BY a_agent.DATE_BEGIN DESC;
  
    res NUMBER;
  
  BEGIN
    OPEN cur_rec(p_date, p_ag_header);
    FETCH cur_rec
      INTO res;
  
    IF (cur_rec%NOTFOUND)
    THEN
      CLOSE cur_rec;
      RETURN NULL;
    END IF;
  
    CLOSE cur_rec;
    RETURN res;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GetIdRecruterByDate;

  FUNCTION IsRecrutCalcByDate
  (
    p_date             DATE
   ,p_ag_header_recrut NUMBER
   ,p_ag_header_agent  NUMBER
  ) RETURN NUMBER IS
  
    /*достает максимальное количество дней. дней, сколько управлялся агент тем или иным менеджером*/
    /*    CURSOR cur_res(cv_date DATE, cv_ag_header_lead NUMBER, cv_ag_header_agent NUMBER) IS
    SELECT c.max_day
      FROM (SELECT MAX(c_day) AS max_day, b.contract_leader_id
              FROM (SELECT (CASE A.day_count
                             WHEN 0 THEN
                              day_count_to_current_date
                             ELSE
                              A.day_count
                           END) AS c_day,
                           A.*
                      FROM (SELECT (FIRST_VALUE(a.date_begin)
                                    OVER(ORDER BY a.date_begin DESC
                                         ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) -
                                    a.date_begin) AS day_count,
                                   (cv_date - a.date_begin) AS day_count_to_current_date,
                                   ag_lead.contract_id AS contract_leader_id,
                                   a.ag_contract_id,
                                   a.date_begin
                              FROM AG_CONTRACT a, AG_CONTRACT ag_lead
                             WHERE a.contract_id = cv_ag_header_agent
                               AND ag_lead.AG_CONTRACT_ID =
                                   a.contract_leader_id) A) B
             GROUP BY b.contract_leader_id) C
     WHERE c.contract_leader_id = cv_ag_header_lead; */
  
    CURSOR cur_res IS
      SELECT * FROM V_ISRECRUTCALCBYDATE;
  
    day_count NUMBER;
  BEGIN
  
    pkg_rep_utils2.dSetVal('cv_date', p_date);
    pkg_rep_utils2.iSetVal('cv_ag_header_lead', p_ag_header_recrut);
    pkg_rep_utils2.iSetVal('cv_ag_header_agent', p_ag_header_agent);
  
    --    OPEN cur_res(p_date, p_ag_header_recrut, p_ag_header_agent);
  
    OPEN cur_res;
    FETCH cur_res
      INTO day_count;
  
    IF (cur_res%NOTFOUND)
    THEN
      CLOSE cur_res;
      RETURN Utils.c_false;
    END IF;
  
    CLOSE cur_res;
  
    IF (day_count < 30)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    /*по поводу сколько и как он рекрутировал за этот период, надо еще переделать*/
  
    RETURN Utils.c_true;
  END IsRecrutCalcByDate;

  FUNCTION Get_Leader_Id_By_Date
  (
    p_data_begin      IN DATE
   ,p_ag_contr_header IN NUMBER
   ,p_data_pay        IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    IF p_data_pay < p_data_begin
    THEN
      SELECT NVL(ac_lead.contract_id, 0)
        INTO RESULT
        FROM AG_CONTRACT ac_ag
            ,AG_CONTRACT ac_lead
       WHERE ac_ag.contract_leader_id = ac_lead.ag_contract_id
         AND ac_ag.ag_contract_id = (SELECT a.ag_contract_id
                                       FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m
                                                   ,ac.ag_contract_id
                                                   ,ac.date_begin
                                               FROM AG_CONTRACT ac
                                              WHERE TRUNC(ac.date_begin) <= TRUNC(p_data_begin)
                                                AND ac.contract_id = p_ag_contr_header
                                              ORDER BY ac.date_begin DESC) a
                                      WHERE a.m = a.ag_contract_id
                                        AND ROWNUM = 1);
    ELSE
      SELECT NVL(ac_lead.contract_id, 0)
        INTO RESULT
        FROM AG_CONTRACT ac_ag
            ,AG_CONTRACT ac_lead
       WHERE ac_ag.contract_leader_id = ac_lead.ag_contract_id
         AND ac_ag.ag_contract_id = (SELECT a.ag_contract_id
                                       FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m
                                                   ,ac.ag_contract_id
                                                   ,ac.date_begin
                                               FROM AG_CONTRACT ac
                                              WHERE TRUNC(ac.date_begin) <= TRUNC(p_data_pay)
                                                AND ac.contract_id = p_ag_contr_header
                                              ORDER BY ac.date_begin DESC) a
                                      WHERE a.m = a.ag_contract_id
                                        AND ROWNUM = 1);
    END IF;
    /*  dbms_output.put_line(p_data_begin||' '||p_ag_contr_header||' '||p_data_pay);
    dbms_output.put_line(Result);*/
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
    
  END Get_Leader_Id_By_Date;

  FUNCTION get_ac_contrat_id_by_date
  (
    p_ag_contr_header IN NUMBER
   ,p_data_pay        IN DATE
  ) RETURN NUMBER IS
    RESULT       NUMBER;
    v_date_start DATE;
  BEGIN
    SELECT ach.date_begin
      INTO v_date_start
      FROM AG_CONTRACT_HEADER ach
     WHERE ach.ag_contract_header_id = p_ag_contr_header;
    IF p_data_pay > v_date_start
    THEN
      SELECT a.ag_contract_id
        INTO RESULT
        FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m
                    ,ac.ag_contract_id
                    ,ac.date_begin
                FROM AG_CONTRACT ac
               WHERE TRUNC(ac.date_begin) <= TRUNC(p_data_pay)
                 AND ac.contract_id = p_ag_contr_header
               ORDER BY ac.date_begin DESC) a
       WHERE a.m = a.ag_contract_id
         AND ROWNUM = 1;
    ELSE
      SELECT a.ag_contract_id
        INTO RESULT
        FROM (SELECT MIN(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m
                    ,ac.ag_contract_id
                    ,ac.date_begin
                FROM AG_CONTRACT ac
               WHERE TRUNC(ac.date_begin) >= TRUNC(v_date_start)
                 AND ac.contract_id = p_ag_contr_header
               ORDER BY ac.date_begin DESC) a
       WHERE a.m = a.ag_contract_id
         AND ROWNUM = 1;
    END IF;
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_ac_contrat_id_by_date;

  FUNCTION A7_get_money_analyze
  (
    p_acp_id IN NUMBER
   ,p_date   IN DATE DEFAULT SYSDATE
  ) RETURN INTEGER IS
    RESULT         INTEGER;
    tmp_doc_brief  VARCHAR2(20);
    tmp_paym_brief VARCHAR2(20);
  BEGIN
    IF p_date > to_date('29022008', 'ddmmyyyy')
    THEN
      BEGIN
      
        SELECT apt1.brief
          INTO tmp_doc_brief
          FROM AC_PAYMENT       a11
              ,AC_PAYMENT_TEMPL apt1
         WHERE p_acp_id = a11.payment_id
           AND apt1.payment_templ_id = a11.payment_templ_id;
      
        IF (tmp_doc_brief = 'A7' OR tmp_doc_brief = 'PD4')
        THEN
          SELECT Doc.get_doc_status_brief(a22.payment_id, TO_DATE('31.12.9999', 'DD.MM.YYYY'))
            INTO tmp_paym_brief
            FROM DOC_DOC          dd1
                ,AC_PAYMENT       a11
                ,AC_PAYMENT       a22
                ,AC_PAYMENT_TEMPL apt1
           WHERE p_acp_id = a11.payment_id
             AND dd1.parent_id = a11.payment_id
             AND dd1.child_id = a22.payment_id
             AND (apt1.brief = 'A7' OR apt1.brief = 'PD4')
             AND apt1.payment_templ_id = a11.payment_templ_id;
        ELSE
          tmp_paym_brief := 'PAID';
        END IF;
      
        IF tmp_paym_brief = 'PAID'
        THEN
          RESULT := 1;
        ELSE
          RESULT := 0;
        END IF;
      
      END;
    ELSE
      RESULT := 1;
    END IF;
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END A7_get_money_analyze;

  FUNCTION get_p_agent_status_by_date
  (
    p_ach_id           NUMBER
   ,p_policy_header_id IN NUMBER
   ,p_date             DATE
  ) RETURN VARCHAR2 IS
    RESULT              VARCHAR2(20);
    tmp_status_brief    VARCHAR2(20);
    tmp_contr_header_id VARCHAR2(20);
  BEGIN
  
    SELECT nvl(pas.brief, 'CANCEL')
      INTO tmp_status_brief
      FROM p_policy_agent      pa
          ,policy_agent_status pas
     WHERE pa.policy_header_id = p_policy_header_id
       AND pa.ag_contract_header_id = p_ach_id
       AND pas.policy_agent_status_id = pa.status_id
       AND NOT EXISTS (SELECT '1'
              FROM p_policy_agent      pa1
                  ,policy_agent_status pas1
             WHERE pas1.policy_agent_status_id = pa1.status_id
               AND pa.policy_header_id = pa1.policy_header_id
               AND pas1.brief = 'ERROR')
       AND rownum = 1;
  
    IF tmp_status_brief NOT IN ('CURRENT')
    THEN
      SELECT a.brief
            ,ag_contract_header_id
        INTO tmp_status_brief
            ,tmp_contr_header_id
        FROM (SELECT MAX(pa.date_start) OVER(PARTITION BY pa.policy_header_id) m
                    ,pa.p_policy_agent_id
                    ,pa.date_start
                    ,pas.brief
                    ,pa.ag_contract_header_id
                FROM p_policy_agent      pa
                    ,policy_agent_status pas
               WHERE pa.policy_header_id = p_policy_header_id
                 AND pas.policy_agent_status_id = pa.status_id
                 AND pa.date_start < p_date
               ORDER BY pa.date_start DESC) a
       WHERE rownum = 1;
    
    END IF;
    IF tmp_status_brief = 'CURRENT'
    THEN
      RESULT := 'CURRENT';
    ELSIF tmp_status_brief = 'CANCEL'
          AND tmp_contr_header_id = p_ach_id
    THEN
      RESULT := 'CURRENT';
    ELSE
      RESULT := 'CANCEL';
    END IF;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'CANCEL';
  END get_p_agent_status_by_date;

  FUNCTION double_trans_analyze
  (
    p_ag_contract_header_id IN NUMBER
   ,p_part_agent            IN NUMBER
   ,p_trans_id              IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_tmp  NUMBER;
  BEGIN
    IF p_part_agent = 50
    THEN
      SELECT COUNT(1)
        INTO v_tmp
        FROM agent_report_cont arc
        JOIN agent_report ar
          ON (ar.agent_report_id = arc.agent_report_id)
       WHERE arc.part_agent = 50
         AND arc.trans_id = p_trans_id
         AND ar.ag_contract_h_id <> p_ag_contract_header_id;
      IF v_tmp > 1
      THEN
        RESULT := 0;
      ELSE
        RESULT := 1;
      END IF;
    ELSE
      SELECT COUNT(1)
        INTO v_tmp
        FROM agent_report_cont arc
        JOIN agent_report ar
          ON (ar.agent_report_id = arc.agent_report_id)
       WHERE arc.trans_id = p_trans_id;
      IF v_tmp > 0
      THEN
        RESULT := 0;
      ELSE
        RESULT := 1;
      END IF;
    END IF;
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(0);
  END double_trans_analyze;

END Pkg_Agent_Sub;
/
