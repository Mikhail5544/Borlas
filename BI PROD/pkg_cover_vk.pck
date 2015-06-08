CREATE OR REPLACE PACKAGE Pkg_Cover_vk IS
  /**
  * Управление покрытиями
  * @author Denis Ivanov
  */
  /**
  * ИД статуса историчного значения 'Новый'
  */
  status_hist_id_new NUMBER;
  /**
  * ИД статуса историчного значения 'Действующий'
  */
  status_hist_id_curr NUMBER;
  /**
  * ИД статуса историчного значения 'Удален'
  */
  status_hist_id_del NUMBER;

  FUNCTION get_status_hist_id_new RETURN NUMBER;
  FUNCTION get_status_hist_id_curr RETURN NUMBER;
  FUNCTION get_status_hist_id_del RETURN NUMBER;

  /**
  * Рассчитать франшизу по покрытию
  * @author Denis Ivanov
  * @param p_cover_id ид покрытия
  * @param p_deduct_type_id ид типа франшизы возрващаемое
  * @param p_deduct_val_type_id ид типа значения возврщаемое
  * @param p_deduct_value значение франшизы
  */
  PROCEDURE calc_deduct
  (
    p_p_cover_id         IN NUMBER
   ,p_deduct_type_id     OUT NUMBER
   ,p_deduct_val_type_id OUT NUMBER
   ,p_deduct_value       OUT NUMBER
  );

  /**
  * Рассчитать франшизу по покрытию
  * @author Denis Ivanov
  * @param p_cover_id ид покрытия
  * @param p_deduct_type_id ид типа франшизы возрващаемое
  * @param p_deduct_val_type_id ид типа значения возврщаемое
  * @param p_deduct_value значение франшизы
  */
  FUNCTION calc_deduct(p_p_cover_id IN NUMBER) RETURN NUMBER;
  /**
  * Рассчитать страховую сумму по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение суммы
  */

  FUNCTION calc_ins_amount(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_ins_price(p_p_cover_id NUMBER) RETURN NUMBER;
  /**
  * Рассчитать тариф по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_tariff(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать тариф нетто по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */

  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать премию по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */
  FUNCTION calc_premium(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать брутто взнос по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */
  FUNCTION calc_fee(p_p_cover_id NUMBER) RETURN NUMBER;
  /**
  * Рассчитать нагрузку по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_loading(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать немедицинский коэффициент S
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_s_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать немедицинский коэффициент K
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_k_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER;
  /**
  * Пересчитать суммы на покрытии
  * @author Denis Ivanov
  * @param p_p_cover_id number
  */

  PROCEDURE update_cover_sum(p_p_cover_id NUMBER);

  /**
  * Связать агента с покрытием
  * Создает запись в p_cover_agent, используя поиск определения ставки
  * в агентах @see pkg_agent.get_agent_rate_by_cover(). Если связь уже
  * была, только возвращает ид записи.
  * @author Denis Ivanov
  * @param p_cover_id ИД покрытия
  * @param p_agent_id ИД агента
  * @return ИД p_cover_agent
  */
  FUNCTION link_cover_agent
  (
    p_cover_id NUMBER
   ,p_agent_id NUMBER
  ) RETURN NUMBER;

  /**
  * Создание нового покрытия по объекту страхования и риску в продукте
  * @author Denis Ivanov
  * @param p_t_product_line_id ИД риска в продукте
  * @param p_as_asset_id ИД объекта страхования
  * @return ид нового покрытия
  */
  FUNCTION cre_new_cover
  (
    p_as_asset_id       IN NUMBER
   ,p_t_product_line_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Включить обязательные покрытия по объекту страхования
  * @author Denis Ivanov
  * @param p_as_asset_id ид объекта страхования
  */
  PROCEDURE inc_mandatory_covers_by_asset(p_as_asset_id NUMBER);

  /**
  * Добавляет покрытие объекту страхования
  * @author Patsan O.
  * @param p_asset_id ИД объекта страхования
  * @param p_prod_line_id ИД вида покрытия
  * @return ИД созданного покрытия
  */
  FUNCTION include_cover
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Удаляет покрытие у объекта страхования
  * @author Patsan O.
  * @param p_cover_id ИД покрытия, которое необходимо удалить
  */
  PROCEDURE exclude_cover(par_cover_id IN NUMBER);

  /**
  * Скопировать страховое покрытие объекта страхования
  * @author Alexander Kalabukhov
  * @param p_old_id ИД объекта страхования источника
  * @param p_new_id ИД объекта страхования приемника
  */
  PROCEDURE copy_p_cover
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * Связать агента со всеми покрытиями по полису
  * @author Patsan O.
  * @param p_pol_id ИД полиса
  * @param p_agent_id ИД агента
  */
  PROCEDURE link_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  );

  /**
  * Удалить связь между агентом и всеми покрытиями по полису
  * @author Patsan O.
  * @param p_pol_id ИД полиса
  * @param p_agent_id ИД агента
  */
  PROCEDURE unlink_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  );

  /**
  * Получить дату вступления в силу полиса, по которые указанное покрытие было добавлено
  * @author Alexander Kalabukhov
  * @param p_p_cover_id ИД покрытия
  * @return Дата вступления в силу полиса
  */
  FUNCTION get_policy_confirm_date(p_p_cover_id IN NUMBER) RETURN DATE;

  /**
  * Проверить возможность одновременного страхования видов покрытий для указанного объекта страхования
  * @author Denis Ivanov
  * @param p_asset_id ид объекта страхования
  * @param p_prod_line_id ид линии продукта
  * @param err_msg сообщение о причине несовместимости
  * @return 1 - можно привязать покрытие, 0 - нельзя привязать покрытие
  */
  FUNCTION check_dependences
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER;
  /**
  * Расчет заработанной премии при уменьшении премии по покрытию по умолчанию.
  * @author Denis Ivanov
  * @param p_p_cover_id ИД объекта сущности P_COVER
  * @return значение ЗСП прората с учетом выплат комиссионных и убытков.
  */
  FUNCTION calc_zsp_common(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Расторгнуть покрытие
  * @author Denis Ivanov
  * @param p_p_cover_id ид покрытия
  * @param p_decline_date дата расторжения
  * @returm сумма возврата
  */

  FUNCTION decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decline_date DATE
  ) RETURN NUMBER;

  /*
  Устаревшая расторнуть покрытие
  */
  PROCEDURE calc_decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decl_date    IN DATE
   ,p_is_charge    IN NUMBER
   ,p_is_comission IN NUMBER
   ,po_ins_sum     OUT NUMBER
   ,po_prem_sum    OUT NUMBER
   ,po_pay_sum     OUT NUMBER
   ,po_payoff_sum  OUT NUMBER
   ,po_charge_sum  OUT NUMBER
   ,po_com_sum     OUT NUMBER
   ,po_zsp_sum     OUT NUMBER
   ,po_decline_sum OUT NUMBER
  );

  FUNCTION calc_cover_accident_return_sum
  (
    p_p_cover_id NUMBER
   ,p_rules      NUMBER
  ) RETURN NUMBER;
  FUNCTION calc_cover_life_per_return_sum(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_cover_adm_exp_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION calc_cover_cash_surr_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER;

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_age        NUMBER
  );

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_period_id  IN NUMBER
   ,p_age        NUMBER
  );

  --@Author Marchuk A

  /**
  * Проверить возможность добавления покрытия связанного с заданной программой
  * @author Ф.Ганичев
  * @param p_asset_id ид объекта страхования
  * @param p_prod_line_id ид линии продукта
  * @param err_msg сообщение о причине несовместимости
  * @return 1 - можно привязать покрытие, 0 - нельзя привязать покрытие
  */
  FUNCTION check_dependencies_by_clause
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER;

  /**
  * Округлить значение брутто взноса по правилам для покрытия
  * @author Marchuk A
  * @param p_p_cover_id ид покрытия
  * @param p_value неокругленное значение
  * @returm округленное значение
  */

  FUNCTION round_fee
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER;

  /**
  * Округлить значение страховой суммы по правилам для покрытия
  * @author Marchuk A
  * @param p_p_cover_id ид покрытия
  * @param p_value неокругленное значение
  * @returm округленное значение
  */

  FUNCTION round_ins_amount
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER;

  /**
  * @author F.GANICHEV
  */
  FUNCTION cover_copy
  (
    p_old_cover    IN OUT ven_p_cover%ROWTYPE
   ,p_new_asset_id NUMBER
   ,p_is_new       NUMBER
  ) RETURN NUMBER;

  /**
  * Значение тарифа по страховой программе
  * @author E.Protsvetov
  * @param p_asset_id ид объекта страхования в договоре
  * @param p_prod_line_opt_dsc страховой программа
  * @returm Значение тарифа по страховой программе
  */
  FUNCTION get_cover_tariff
  (
    p_asset_id        NUMBER
   ,p_prod_line_brief VARCHAR2
  ) RETURN NUMBER;

  /**
  * Значение Суммы страховых сумм по рискам ФР и ИМФЛ (Ипотека)
  * @author E.Protsvetov
  * @param p_par_policy_id ид договорf
  * @returm Сумма страховых сумм по рискам ФР и ИМФЛ (Ипотека)
  */
  FUNCTION calc_amount_imusch_ipoteka(p_par_policy_id NUMBER) RETURN NUMBER;

  FUNCTION calc_new_cover_premium(p_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION get_cover
  (
    p_p_cover_id NUMBER
   ,p_date       DATE
  ) RETURN NUMBER;
  FUNCTION calc_cover_nonlife_return_sum(p_p_cover_id IN NUMBER) RETURN NUMBER;
  cover_property_cache Utils.hashmap_t;
END;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Cover_vk IS

  G_DEBUG BOOLEAN := FALSE;

  PROCEDURE LOG
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO P_COVER_DEBUG
        (P_COVER_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_COVER', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE logcover(p_msg VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    NULL;
    /*insert into tmp_message(text) values (p_msg);
    commit;*/
  END;

  FUNCTION get_status_hist_id_new RETURN NUMBER IS
  BEGIN
    RETURN status_hist_id_new;
  END;

  FUNCTION get_status_hist_id_curr RETURN NUMBER IS
  BEGIN
    RETURN status_hist_id_curr;
  END;

  FUNCTION get_status_hist_id_del RETURN NUMBER IS
  BEGIN
    RETURN status_hist_id_del;
  END;

  FUNCTION is_allow_set_status
  (
    p_p_cover_id   IN NUMBER
   ,p_status_brief IN STATUS_HIST.brief%TYPE
   ,p_message      OUT VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    RETURN 1;
  END;

  PROCEDURE set_cover_status
  (
    p_p_cover_id   NUMBER
   ,p_status_brief STATUS_HIST.brief%TYPE
  ) IS
    v_message VARCHAR2(4000);
    v_flag    NUMBER(1);
  BEGIN
    --logcover ('s_c_s_start');
    v_flag := is_allow_set_status(p_p_cover_id, p_status_brief, v_message);
    IF v_flag = 1
    THEN
      UPDATE P_COVER p
         SET p.status_hist_id =
             (SELECT sh.status_hist_id FROM STATUS_HIST sh WHERE sh.brief = p_status_brief)
       WHERE p.p_cover_id = p_p_cover_id;
    ELSE
      RAISE_APPLICATION_ERROR(-20000, v_message);
    END IF;
    --logcover ('s_c_s_end');
  END;

  /**
  * Рассчитать франшизу по умолчанию по покрытию
  * @author Denis Ivanov
  * @param p_cover_id ид покрытия
  * @param p_deduct_type_id ид типа франшизы возрващаемое
  * @param p_deduct_val_type_id ид типа значения возврщаемое
  * @param p_deduct_value значение франшизы
  */

  /*
    PROCEDURE calc_deduct(p_p_cover_id         IN NUMBER,
                          p_deduct_type_id     OUT NUMBER,
                          p_deduct_val_type_id OUT NUMBER,
                          p_deduct_value       OUT NUMBER) IS
      v_sql t_product_line.deduct_func%TYPE;
      i     INTEGER;
      c     INTEGER;
    BEGIN
      p_deduct_type_id     := NULL;
      p_deduct_val_type_id := NULL;
      p_deduct_value       := NULL;
  
      SELECT pl.deduct_func
        INTO v_sql
        FROM p_cover c, t_prod_line_option plo, t_product_line pl
       WHERE c.p_cover_id = p_p_cover_id
         AND plo.product_line_id = pl.id
         AND c.t_prod_line_option_id = plo.id;
  
      IF v_sql IS NOT NULL THEN
        c := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(c, v_sql, dbms_sql.native);
        DBMS_SQL.BIND_VARIABLE(c, 'p_p_cover_id', p_p_cover_id);
        dbms_sql.bind_variable(c, 'p_deductible_type_id', p_deduct_type_id);
        dbms_sql.bind_variable(c,
                               'p_deductible_value_type_id',
                               p_deduct_val_type_id);
        dbms_sql.bind_variable(c, 'p_value', p_deduct_value);
        i := DBMS_SQL.EXECUTE(c);
        dbms_sql.variable_value(c, 'p_deductible_type_id', p_deduct_type_id);
        dbms_sql.variable_value(c,
                                'p_deductible_value_type_id',
                                p_deduct_val_type_id);
        dbms_sql.variable_value(c, 'p_value', p_deduct_value);
        DBMS_SQL.CLOSE_CURSOR(c);
      END IF;
    END;
  */

  /**
  * Рассчитать франшизу (тип, тип значения, значение) по умолчанию по покрытию
  * @author Denis Ivanov
  * @param p_cover_id ид покрытия
  * @param p_deduct_type_id ид типа франшизы возрващаемое
  * @param p_deduct_val_type_id ид типа значения возврщаемое
  * @param p_deduct_value значение франшизы
  */

  PROCEDURE calc_deduct
  (
    p_p_cover_id         IN NUMBER
   ,p_deduct_type_id     OUT NUMBER
   ,p_deduct_val_type_id OUT NUMBER
   ,p_deduct_value       OUT NUMBER
  ) IS
    v_func_id NUMBER;
    v_pl_id   NUMBER;
  BEGIN
    p_deduct_type_id     := NULL;
    p_deduct_val_type_id := NULL;
    p_deduct_value       := NULL;
  
    v_pl_id := utils.get_null(cover_property_cache, 'PROD_LINE_' || p_p_cover_id);
  
    IF v_pl_id IS NOT NULL
    THEN
      v_func_id := utils.get_null(cover_property_cache, 'DEDUCT_FUNC_' || v_pl_id);
      IF v_func_id IS NULL
      THEN
        SELECT pl.DEDUCT_FUNC_ID INTO v_func_id FROM T_PRODUCT_LINE pl WHERE ID = v_pl_id;
        cover_property_cache('DEDUCT_FUNC_' || v_pl_id) := v_func_id;
      END IF;
    ELSE
      SELECT pl.DEDUCT_FUNC_ID
            ,pl.ID
        INTO v_func_id
            ,v_pl_id
        FROM P_COVER            c
            ,T_PROD_LINE_OPTION plo
            ,T_PRODUCT_LINE     pl
       WHERE c.p_cover_id = p_p_cover_id
         AND plo.product_line_id = pl.ID
         AND c.t_prod_line_option_id = plo.ID;
    END IF;
    p_deduct_type_id := utils.GET_NULL(cover_property_cache, 'DEDUCT_TYPE_' || v_pl_id);
    IF p_deduct_type_id IS NULL
    THEN
      SELECT deductible_type_id
            ,deductible_value_type_id
            ,def_val
        INTO p_deduct_type_id
            ,p_deduct_val_type_id
            ,p_deduct_value
        FROM (SELECT dr.deductible_type_id
                    ,dr.deductible_value_type_id
                    ,NVL(pld.default_value, 0) def_val
                FROM T_DEDUCTIBLE_REL dr
                JOIN T_PROD_LINE_DEDUCT pld
                  ON pld.deductible_rel_id = dr.t_deductible_rel_id
                 AND pld.product_line_id = v_pl_id
               ORDER BY def_val DESC)
       WHERE ROWNUM < 2;
    
      cover_property_cache('DEDUCT_TYPE_' || v_pl_id) := p_deduct_type_id;
      cover_property_cache('DEDUCT_VAL_TYPE_' || v_pl_id) := p_deduct_val_type_id;
      cover_property_cache('DEDUCT_DEF_' || v_pl_id) := p_deduct_value;
    ELSE
      p_deduct_val_type_id := utils.GET_NULL(cover_property_cache, 'DEDUCT_VAL_TYPE_' || v_pl_id);
      p_deduct_value       := utils.GET_NULL(cover_property_cache, 'DEDUCT_DEF_' || v_pl_id);
    END IF;
  END;

  /**
  * Рассчитать франшизу по покрытию
  * @author Ф.Ганичев.
  * @param  p_cover_id ид покрытия
  * @return значение суммы
  */
  FUNCTION calc_deduct(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_sql             VARCHAR2(4000);
    v_deduct          NUMBER;
    i                 INTEGER;
    c                 INTEGER;
    v_func_id         NUMBER;
    v_deduct_val_type NUMBER;
    v_deduct_val      NUMBER;
  BEGIN
  
    LOG(p_p_cover_id, 'CALC_DEDUCT ');
  
    FOR cur IN (SELECT pl.deduct_func_id
                  FROM T_PRODUCT_LINE     pl
                      ,T_PROD_LINE_OPTION plo
                      ,P_COVER            pc
                 WHERE pl.ID = plo.product_line_id
                   AND plo.ID = pc.t_prod_line_option_id
                   AND pc.p_cover_id = p_p_cover_id)
    LOOP
    
      v_func_id := cur.deduct_func_id;
    END LOOP;
  
    LOG(p_p_cover_id, 'CALC_DEDUCT FUNC_ID ' || v_func_id);
  
    IF v_func_id IS NOT NULL
    THEN
      v_deduct := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
    
      LOG(p_p_cover_id, 'CALC_DEDUCT DEDUCT ' || v_deduct);
    ELSE
      calc_deduct(p_p_cover_id, v_deduct_val_type, v_deduct_val, v_deduct);
    
    END IF;
    RETURN v_deduct;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Не найдена функция расчета франшизы по программе');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END calc_deduct;

  /**
  * Рассчитать премию по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */
  FUNCTION calc_ins_amount(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_sql        T_PRODUCT_LINE.ins_amount_func%TYPE;
    v_ins_amount NUMBER;
    i            INTEGER;
    c            INTEGER;
    v_func_id    NUMBER;
  BEGIN
    BEGIN
      SELECT pl.ins_amount_func
            ,pl.ins_amount_func_id
        INTO v_sql
            ,v_func_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_COVER            pc
       WHERE pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    
      IF v_sql IS NOT NULL
      THEN
        c := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(c, v_sql, dbms_sql.native);
        DBMS_SQL.BIND_VARIABLE(c, 'p_p_cover_id', p_p_cover_id);
        DBMS_SQL.BIND_VARIABLE(c, 'p_ins_amount', v_ins_amount);
        i := DBMS_SQL.EXECUTE(c);
        DBMS_SQL.VARIABLE_VALUE(c, 'p_ins_amount', v_ins_amount);
        DBMS_SQL.CLOSE_CURSOR(c);
      ELSIF v_func_id IS NOT NULL
      THEN
        v_ins_amount := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
      END IF;
    
      v_ins_amount := Pkg_cover.round_ins_amount(p_p_cover_id, v_ins_amount);
    
      RETURN v_ins_amount;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Ошибка расчета страховой суммы');
    END;
  END;

  FUNCTION calc_ins_price(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_sql       T_PRODUCT_LINE.ins_price_func%TYPE;
    v_ins_price NUMBER;
    i           INTEGER;
    c           INTEGER;
    v_func_id   NUMBER;
  BEGIN
    BEGIN
      SELECT pl.ins_price_func
            ,pl.ins_price_func_id
        INTO v_sql
            ,v_func_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_COVER            pc
       WHERE pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    
      IF v_sql IS NOT NULL
      THEN
        c := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(c, v_sql, dbms_sql.native);
        DBMS_SQL.BIND_VARIABLE(c, 'p_p_cover_id', p_p_cover_id);
        DBMS_SQL.BIND_VARIABLE(c, 'p_ins_price', v_ins_price);
        i := DBMS_SQL.EXECUTE(c);
        DBMS_SQL.VARIABLE_VALUE(c, 'p_ins_price', v_ins_price);
        DBMS_SQL.CLOSE_CURSOR(c);
      ELSIF v_func_id IS NOT NULL
      THEN
        v_ins_price := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
      END IF;
      RETURN v_ins_price;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Ошибка расчета страховой стоимости');
    END;
  END;

  /**
  * Рассчитать тариф по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_tariff(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_sql                   VARCHAR2(4000);
    v_tariff                NUMBER;
    v_tariff_func           VARCHAR2(4000);
    v_tariff_func_precision NUMBER;
    i                       INTEGER;
    c                       INTEGER;
    v_func_id               NUMBER;
  BEGIN
    SELECT pl.tariff_func
          ,pl.tariff_func_id
          ,NVL(pl.tariff_func_precision, 6)
      INTO v_tariff_func
          ,v_func_id
          ,v_tariff_func_precision
      FROM T_PRODUCT_LINE     pl
          ,T_PROD_LINE_OPTION plo
          ,P_COVER            pc
     WHERE 1 = 1
       AND pl.ID = plo.product_line_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_tariff_func IS NOT NULL
    THEN
      v_sql := v_tariff_func;
      c     := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(c, v_sql, dbms_sql.native);
      DBMS_SQL.BIND_VARIABLE(c, 'p_p_cover_id', p_p_cover_id);
      DBMS_SQL.BIND_VARIABLE(c, 'p_tariff', v_tariff);
      i := DBMS_SQL.EXECUTE(c);
      DBMS_SQL.VARIABLE_VALUE(c, 'p_tariff', v_tariff);
      DBMS_SQL.CLOSE_CURSOR(c);
    ELSIF v_func_id IS NOT NULL
    THEN
      v_tariff := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
      --    При установленных настройках на линии продукта осуществляется округление результата по заданной точности
      --    Иначе значение установленное разработчиком
      v_tariff := ROUND(v_tariff, v_tariff_func_precision);
    END IF;
    RETURN v_tariff;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Не найдена функция расчета тарифа по программе');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  /**
  * Рассчитать тариф по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_sql                   VARCHAR2(4000);
    v_tariff                NUMBER;
    v_tariff_func           VARCHAR2(4000);
    v_tariff_func_precision NUMBER;
    i                       INTEGER;
    c                       INTEGER;
    v_func_id               NUMBER;
  BEGIN
    SELECT pl.tariff_netto_func_id
          ,NVL(pl.tariff_func_precision, 6)
      INTO v_func_id
          ,v_tariff_func_precision
      FROM T_PRODUCT_LINE     pl
          ,T_PROD_LINE_OPTION plo
          ,P_COVER            pc
     WHERE 1 = 1
       AND pl.ID = plo.product_line_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    DBMS_OUTPUT.PUT_LINE('v_func_id ' || v_func_id);
  
    IF v_func_id IS NOT NULL
    THEN
      v_tariff := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
      --    При установленных настройках на линии продукта осуществляется округление результата по заданной точности
      --    Иначе значение установленное разработчиком
      v_tariff := ROUND(v_tariff, v_tariff_func_precision);
    END IF;
    RETURN v_tariff;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Не найдена функция расчета тарифа по программе');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  /**
  * Рассчитать тариф по умолчанию по покрытию
  * @Author Marchuk Alexander
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */

  /**
  * Рассчитать премию по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */
  FUNCTION calc_premium(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_sql          VARCHAR2(4000);
    v_premium      NUMBER;
    v_premium_func VARCHAR2(4000);
    i              INTEGER;
    c              INTEGER;
    v_func_id      NUMBER;
  BEGIN
    BEGIN
      SELECT pl.premium_func
            ,pl.premium_func_id
        INTO v_premium_func
            ,v_func_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_COVER            pc
       WHERE pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'Не найдена функция расчета премии : p_cover_id ' || p_p_cover_id);
    END;
    --
    BEGIN
      IF v_premium_func IS NOT NULL
      THEN
        v_sql := v_premium_func;
        c     := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(c, v_sql, dbms_sql.native);
        DBMS_SQL.BIND_VARIABLE(c, 'p_p_cover_id', p_p_cover_id);
        DBMS_SQL.BIND_VARIABLE(c, 'p_premium', v_premium);
        i := DBMS_SQL.EXECUTE(c);
        DBMS_SQL.VARIABLE_VALUE(c, 'p_premium', v_premium);
        DBMS_SQL.CLOSE_CURSOR(c);
      ELSIF v_func_id IS NOT NULL
      THEN
        v_premium := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
      END IF;
      RETURN v_premium;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002
                               ,'Не найдена функция расчета премии : p_cover_id ' || p_p_cover_id);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    END;
  END;

  /**
  * Рассчитать брутто взнос по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */
  FUNCTION calc_fee(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT    NUMBER;
    v_func_id NUMBER;
    --
    CURSOR c_fee IS
      SELECT pl.fee_func_id func_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_POLICY           pp
            ,AS_ASSET           aa
            ,P_COVER            pc
       WHERE 1 = 1
         AND pp.policy_id = aa.p_policy_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    --
  
  BEGIN
    FOR cur IN c_fee
    LOOP
      RESULT := Pkg_Tariff_Calc.calc_fun(cur.func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
      EXIT;
    END LOOP;
  
    RESULT := pkg_cover.round_fee(p_p_cover_id, RESULT);
  
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  /**
  * Рассчитать премию по умолчанию по покрытию
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */
  FUNCTION calc_loading(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_loading       NUMBER;
    i               INTEGER;
    c               INTEGER;
    v_func_id       NUMBER;
    v_discount_f_id NUMBER;
    --
    CURSOR c_loading IS
      SELECT pl.loading_func_id func_id
            ,pp.discount_f_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_POLICY           pp
            ,AS_ASSET           aa
            ,P_COVER            pc
       WHERE 1 = 1
         AND pp.policy_id = aa.p_policy_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_loading c_loading%ROWTYPE;
    --
  BEGIN
    OPEN c_loading;
    FETCH c_loading
      INTO r_loading;
    CLOSE c_loading;
    --
    IF r_loading.func_id IS NOT NULL
    THEN
      v_loading := Pkg_Tariff_Calc.calc_fun(r_loading.func_id
                                           ,Ent.id_by_brief('P_COVER')
                                           ,p_p_cover_id);
      --v_loading := pkg_PrdLifeLoading.RECALC_VALUE (v_loading, r_loading.discount_f_id);
    END IF;
    RETURN v_loading;
    --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  /**
  * Рассчитать немедицинский коэффициент S
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_s_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_func_id NUMBER;
    RESULT    NUMBER;
    --
    CURSOR c_s_coef_nm IS
      SELECT pl.s_coef_nm_func_id
        INTO v_func_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_COVER            pc
       WHERE pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    --
  BEGIN
    OPEN c_s_coef_nm;
    FETCH c_s_coef_nm
      INTO v_func_id;
    CLOSE c_s_coef_nm;
    --
    IF v_func_id IS NOT NULL
    THEN
      RESULT := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
    END IF;
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  /**
  * Рассчитать немедицинский коэффициент K
  * @author Denis Ivanov
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_k_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_func_id NUMBER;
    RESULT    NUMBER;
    --
    CURSOR c_k_coef_nm IS
      SELECT pl.k_coef_nm_func_id
        INTO v_func_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,P_COVER            pc
       WHERE pl.ID = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
    --
  BEGIN
    OPEN c_k_coef_nm;
    FETCH c_k_coef_nm
      INTO v_func_id;
    CLOSE c_k_coef_nm;
    --
    IF v_func_id IS NOT NULL
    THEN
      RESULT := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER'), p_p_cover_id);
    END IF;
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  PROCEDURE update_cover_sum(p_p_cover_id NUMBER) IS
    v_product_line T_PRODUCT_LINE%ROWTYPE;
    v_cover        P_COVER%ROWTYPE;
    v_pl_id        NUMBER;
    v_pl_name      VARCHAR2(200);
    v_ins_var_id   NUMBER;
    v_prod_brief   VARCHAR2(1000);
    v_recalc_flag  VARCHAR2(100);
  BEGIN
    v_recalc_flag := utils.GET_NULL('RECALC_COVERS', 'TRUE');
    IF v_recalc_flag = 'FALSE'
    THEN
      RETURN;
    END IF;
    v_pl_id := utils.get_null(cover_property_cache, 'PROD_LINE_' || p_p_cover_id);
  
    IF v_pl_id IS NOT NULL
    THEN
    
      SELECT pl.* INTO v_product_line FROM T_PRODUCT_LINE pl WHERE ID = v_pl_id;
    
    ELSE
    
      SELECT pl.*
        INTO v_product_line
        FROM T_PRODUCT_LINE     pl
            ,P_COVER            pc
            ,T_PROD_LINE_OPTION plo
       WHERE pc.p_cover_id = p_p_cover_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pl.ID = plo.product_line_id;
    END IF;
  
    SELECT pc.* INTO v_cover FROM P_COVER pc WHERE pc.p_cover_id = p_p_cover_id;
  
    IF v_cover.status_hist_id = status_hist_id_del
    THEN
      RETURN;
    END IF;
  
    v_prod_brief := utils.GET_NULL(cover_property_cache, 'COVER_PL_PRODUCT_' || v_product_line.ID);
    IF v_prod_brief IS NULL
    THEN
      SELECT pr.BRIEF
        INTO v_prod_brief
        FROM t_product    pr
            ,as_asset     a
            ,p_policy     p
            ,p_pol_header ph
            ,p_cover      pc
       WHERE a.AS_ASSET_ID = pc.AS_ASSET_ID
         AND a.P_POLICY_ID = p.POLICY_ID
         AND ph.POLICY_HEADER_ID = p.POL_HEADER_ID
         AND pc.P_COVER_ID = p_p_cover_id
         AND pr.PRODUCT_ID = ph.PRODUCT_ID;
      cover_property_cache('COVER_PL_PRODUCT_' || v_product_line.ID) := v_prod_brief;
    END IF;
    --Сергеев Д. проверка на вариантность объекта страхования
    IF v_prod_brief = 'ДМС'
    THEN
      BEGIN
        --изменено Д.Сыровецким
        /*select aa.ins_var_id
        into   v_ins_var_id
        from   as_asset aa, p_cover pc
        where  aa.as_asset_id = pc.as_asset_id and
               pc.p_cover_id = p_p_cover_id;*/
        SELECT t.dms_prog_type_id
          INTO v_ins_var_id
          FROM ven_dms_prog_type   t
              ,ven_t_prod_line_dms d
         WHERE t.brief = 'INSPR'
           AND d.T_PROD_LINE_DMS_ID = v_product_line.ID
           AND t.dms_prog_TYPE_ID = d.dms_prog_TYPE_ID;
      EXCEPTION
        WHEN OTHERS THEN
          v_ins_var_id := NULL;
      END;
    END IF;
    -- страховая сумма
    IF v_ins_var_id IS NULL
    THEN
      IF ((v_product_line.ins_amount_func IS NOT NULL OR v_product_line.ins_amount_func_id IS NOT NULL) AND
         v_cover.is_handchange_amount = 0)
      THEN
      
        v_cover.ins_amount := calc_ins_amount(v_cover.p_cover_id);
      
      END IF;
      UPDATE P_COVER c
         SET c.ins_amount = v_cover.ins_amount
            ,c.ins_price  = DECODE(v_product_line.description
                                  ,'Дополнительное оборудование'
                                  ,v_cover.ins_amount
                                  ,c.ins_price)
       WHERE c.p_cover_id = v_cover.p_cover_id;
    ELSE
      /* Исправлено Д.Сыровецким
      update p_cover c
      set c.ins_amount = (
        select nvl(sum(divp.ins_amount), 0)
        from   dms_ins_var_prg divp
        where  divp.dms_ins_var_id = v_ins_var_id and
               divp.t_product_line_id = v_product_line.id
      )
      where  c.p_cover_id = p_p_cover_id;*/
      UPDATE P_COVER c SET c.ins_amount = v_product_line.ins_amount WHERE c.p_cover_id = p_p_cover_id;
    END IF;
  
    -- страховая стоимость
  
    /* 2008/02/27
       Add Marchuk A
       bug http://tango.ibs.ru/show_bug.cgi?id=1572
    */
    IF v_ins_var_id IS NULL
    THEN
      IF ((v_product_line.ins_price_func IS NOT NULL OR v_product_line.ins_price_func_id IS NOT NULL) AND
         v_cover.is_handchange_amount = 0)
      THEN
      
        v_cover.ins_price := calc_ins_price(v_cover.p_cover_id);
      
      END IF;
      UPDATE P_COVER c SET c.ins_price = v_cover.ins_price WHERE c.p_cover_id = v_cover.p_cover_id;
    END IF;
  
    -- франшиза
    LOG(v_cover.p_cover_id, 'UPDATE_COVER_SUM DEDUCT_FUNC');
  
    IF NVL(v_cover.is_handchange_deduct, 0) = 0
    THEN
    
      IF v_product_line.DEDUCT_FUNC_ID IS NOT NULL
      THEN
        v_cover.deductible_value := pkg_cover.calc_deduct(v_cover.p_cover_id);
      
        LOG(v_cover.p_cover_id, 'UPDATE_COVER_SUM DEDUCTIBLE_VALUE ' || v_cover.deductible_value);
      
        FOR cur IN (SELECT dt.ID dt_id
                          ,dv.ID dv_id
                      FROM p_cover               pc
                          ,t_deductible_type     dt
                          ,ven_t_deduct_val_type dv
                     WHERE pc.p_cover_id = v_cover.p_cover_id
                       AND dt.ID = pc.t_deductible_type_id
                       AND dv.ID = pc.t_deduct_val_type_id)
        LOOP
          v_cover.t_deductible_type_id := cur.dt_id;
          v_cover.t_deduct_val_type_id := cur.dv_id;
        END LOOP;
      
        IF v_cover.t_deductible_type_id IS NULL
           OR v_cover.t_deduct_val_type_id IS NULL
        THEN
          FOR cur IN (SELECT dt.ID dt_id
                            ,dv.ID dv_id
                        FROM t_deductible_rel      dr
                            ,T_PROD_LINE_DEDUCT    d
                            ,T_PRODUCT_LINE        pl
                            ,T_PROD_LINE_OPTION    plo
                            ,p_cover               pc
                            ,t_deductible_type     dt
                            ,ven_t_deduct_val_type dv
                       WHERE pc.p_cover_id = v_cover.p_cover_id
                         AND plo.ID = pc.t_prod_line_option_id
                         AND pl.ID = plo.product_line_id
                         AND dr.t_deductible_rel_id = d.deductible_rel_id
                         AND dt.ID = dr.deductible_type_id
                         AND dv.ID = dr.deductible_value_type_id
                       ORDER BY d.is_default DESC)
          LOOP
            v_cover.t_deductible_type_id := cur.dt_id;
            v_cover.t_deduct_val_type_id := cur.dv_id;
            EXIT;
          END LOOP;
        END IF;
      
        LOG(v_cover.p_cover_id
           ,'UPDATE_COVER_SUM t_deductible_type_id ' || v_cover.t_deductible_type_id);
        LOG(v_cover.p_cover_id
           ,'UPDATE_COVER_SUM t_deductible_type_id ' || v_cover.t_deduct_val_type_id);
      
      ELSE
        calc_deduct(v_cover.p_cover_id
                   ,v_cover.t_deductible_type_id
                   ,v_cover.t_deduct_val_type_id
                   ,v_cover.deductible_value);
      END IF;
    
    END IF;
  
    -- Механизм пересчета значений франшизы по условиям договора. Если стоит "ручной режим", то франшиза не пересчитыыается
  
    IF NVL(v_cover.is_handchange_deduct, 0) = 0
    THEN
      v_cover.deductible_value := NVL(calc_deduct(v_cover.p_cover_id), v_cover.deductible_value);
    END IF;
  
    UPDATE P_COVER c
       SET c.t_deductible_type_id = v_cover.t_deductible_type_id
          ,c.t_deduct_val_type_id = v_cover.t_deduct_val_type_id
          ,c.deductible_value     = v_cover.deductible_value
     WHERE c.p_cover_id = v_cover.p_cover_id;
  
    -- нетто тариф
    --измения по указанию Балашова А.
    --v_cover.tariff := pkg_tariff.calc_cover_coef(v_cover.p_cover_id);
  
    IF v_product_line.tariff_netto_func_id IS NOT NULL
       AND v_cover.is_handchange_tariff = 0
    THEN
      v_cover.tariff_netto := calc_tariff_netto(v_cover.p_cover_id);
    
      UPDATE P_COVER c
         SET c.tariff_netto = v_cover.tariff_netto
       WHERE c.p_cover_id = v_cover.p_cover_id;
    
    END IF;
  
    --
  
    LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_K_COEF_NM');
  
    IF v_product_line.k_coef_nm_func_id IS NOT NULL
       AND v_cover.is_handchange_k_coef_nm = 0
    THEN
    
      LOG(v_cover.p_cover_id, 'CALC_K_COEF_NM');
    
      v_cover.k_coef_nm := calc_k_coef_nm(v_cover.p_cover_id);
    
      LOG(v_cover.p_cover_id, 'CALC_K_COEF_NM RESULT ' || v_cover.k_coef_nm);
    
      UPDATE P_COVER c SET c.k_coef_nm = v_cover.k_coef_nm WHERE c.p_cover_id = v_cover.p_cover_id;
    
    END IF;
  
    LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_S_COEF_NM');
  
    IF v_product_line.s_coef_nm_func_id IS NOT NULL
       AND v_cover.is_handchange_s_coef_nm = 0
    THEN
    
      LOG(v_cover.p_cover_id, 'CALC_S_COEF_NM');
    
      v_cover.s_coef_nm := calc_s_coef_nm(v_cover.p_cover_id);
    
      LOG(v_cover.p_cover_id, 'CALC_S_COEF_NM RESULT ' || v_cover.s_coef_nm);
    
      UPDATE P_COVER c SET c.s_coef_nm = v_cover.s_coef_nm WHERE c.p_cover_id = v_cover.p_cover_id;
    
    END IF;
    -- тариф
    --измения по указанию Балашова А.
    --v_cover.tariff := pkg_tariff.calc_cover_coef(v_cover.p_cover_id);
  
    LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_TARIFF');
  
    IF ((v_product_line.tariff_func IS NOT NULL OR v_product_line.tariff_func_id IS NOT NULL) AND
       v_cover.is_handchange_tariff = 0)
    THEN
      v_cover.tariff := calc_tariff(v_cover.p_cover_id);
    END IF;
  
    UPDATE P_COVER c SET c.tariff = v_cover.tariff WHERE c.p_cover_id = v_cover.p_cover_id;
  
    LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_FEE');
  
    -- брутто взнос
    --исправлено Д.Сыровецким (метка "change")
    -- if v_ins_var_id is null then --"change"
    IF (v_product_line.fee_func_id IS NOT NULL)
       AND (v_cover.is_handchange_fee = 0)
    THEN
    
      v_cover.fee := calc_fee(v_cover.p_cover_id);
    
    END IF;
  
    UPDATE P_COVER c SET c.fee = v_cover.fee WHERE c.p_cover_id = v_cover.p_cover_id;
  
    LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_PREMIUM');
  
    -- премия
    --исправлено Д.Сыровецким (метка "change")
    -- if v_ins_var_id is null then --"change"
    IF ((v_product_line.premium_func IS NOT NULL OR v_product_line.premium_func_id IS NOT NULL) AND
       v_cover.is_handchange_premium = 0)
    THEN
      --if (v_product_line.premium_func is not null)  then
      v_cover.premium := calc_premium(v_cover.p_cover_id);
    END IF;
  
    -- Исправлено Ф.Ганичевым. Страховые программы идентифицировать по description, а не Id
  
    SELECT plo.product_line_id
          ,plo.description
      INTO v_pl_id
          ,v_pl_name
      FROM P_COVER            pc
          ,T_PROD_LINE_OPTION plo
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.t_prod_line_option_id = plo.ID;
  
    IF NVL(ents.client_id, 0) = 10
    THEN
    
      IF (v_pl_name = 'Ущерб')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_casco_damage(p_p_cover_id);
      ELSIF (v_pl_name = 'Дополнительное оборудование')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_casco_acces(p_p_cover_id);
      ELSIF (v_pl_name = 'Несчастные случаи')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_casco_ns(p_p_cover_id);
      ELSIF (v_pl_name = 'Гражданская ответственность')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_casco_liability(p_p_cover_id);
      ELSIF (v_pl_name = 'FLEXA')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_flexa(p_p_cover_id) * 100 /
                          v_cover.ins_amount;
      ELSIF (v_pl_name = 'Пакет рисков для спецтехники')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_sm_pack(p_p_cover_id);
      ELSIF (v_pl_name = 'Авария')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_sm_avar(p_p_cover_id);
      ELSIF (v_pl_name = 'Пожар/взрыв')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Буря и град')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Прочие стихийные бедствия')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'ПДТЛ для спецрисков')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Кража со взломом/грабеж/разбой')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Вода')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Спринклер')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Наезд')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_srisks(p_p_cover_id);
      ELSIF (v_pl_name = 'Бой стекол,витрин и зеркал')
      THEN
        v_cover.tariff := Pkg_Tariff.calc_tariff_property_glass(p_p_cover_id);
      ELSIF (v_pl_name = 'ОСАГО')
      THEN
        v_cover.tariff := ROUND(v_cover.premium / v_cover.ins_amount * 100, 10);
      END IF;
    
    END IF;
  
    IF NVL(v_cover.ins_amount, 0) <> 0
    THEN
      IF v_cover.tariff IS NULL
         AND v_cover.premium IS NOT NULL
      THEN
        v_cover.tariff := ROUND(v_cover.premium / v_cover.ins_amount * 100, 10);
      ELSIF v_cover.premium IS NULL
            AND v_cover.tariff IS NOT NULL
      THEN
        v_cover.premium := ROUND(v_cover.ins_amount * v_cover.tariff / 100, 2);
      END IF;
    END IF;
  
    UPDATE P_COVER c
       SET c.tariff  = v_cover.tariff
          ,c.premium = v_cover.premium
     WHERE c.p_cover_id = v_cover.p_cover_id;
    /* -- "change"
    else
     --D.Syrovetskiy
       update p_cover c
       set c.premium = (
         select nvl(sum(divp.premium), 0)
         from   dms_ins_var_prg divp
         where  divp.dms_ins_var_id = v_ins_var_id and
                divp.t_product_line_id = v_product_line.id
       )
       where  c.p_cover_id = p_p_cover_id;
     end if; */
  END;

  FUNCTION link_cover_agent
  (
    p_cover_id NUMBER
   ,p_agent_id NUMBER
  ) RETURN NUMBER IS
    v_ret_val               NUMBER;
    v_ag_prod_line_contr_id NUMBER;
    v_rate                  AG_RATE%ROWTYPE;
  BEGIN
    v_ret_val := NULL;
    -- opatsan
    -- переделывается p_cover_agent
    -- баг 1208
    -- также для установления однозначной связи между покрытием и агентом
  
    /*
    -- begin
    -- проверим существование связи
    BEGIN
      SELECT ca.cover_agent_id
        INTO v_ret_val
        FROM P_COVER_AGENT ca
       WHERE ca.cover_id = p_cover_id
         AND ca.agent_id = p_agent_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    
    IF p_agent_id IS NOT NULL AND p_cover_id IS NOT NULL AND
       v_ret_val IS NULL THEN
      -- попытка найти нужную ставку для агента
      v_ag_prod_line_contr_id := Pkg_Agent.get_agent_rate_by_cover(p_cover_id,
                                                                   p_agent_id,
                                                                   SYSDATE);
      IF v_ag_prod_line_contr_id IS NOT NULL THEN
        SELECT r.*
          INTO v_rate
          FROM AG_PROD_LINE_CONTR a, AG_RATE r
         WHERE a.ag_prod_line_contr_id = v_ag_prod_line_contr_id
           AND a.ag_rate_id = r.ag_rate_id;
    
        -- копируем ставку
        SELECT sq_ag_rate.NEXTVAL INTO v_rate.ag_rate_id FROM dual;
        INSERT INTO AG_RATE VALUES v_rate;
    
        -- связываем покрытие с содержимым агентского договора
        SELECT sq_p_cover_agent.NEXTVAL INTO v_ret_val FROM dual;
        INSERT INTO P_COVER_AGENT
          (cover_agent_id,
           cover_id,
           agent_id,
           rate_id,
           rate_value,
           ag_prod_line_contr_id)
          SELECT v_ret_val,
                 p_cover_id,
                 p_agent_id,
                 v_rate.ag_rate_id,
                 v_rate.value,
                 v_ag_prod_line_contr_id
            FROM dual;
      ELSE
        -- todo: вообще-то нельзя заводить такое покрытие в договоре, который
        -- заключил агент. Агент не имел права продавать покрытие, для которого не
        -- определены ставки в его агентском договоре. (либо договор истек и т.п.)
        NULL;
      END IF;
    END IF;
    
    */
  
    RETURN v_ret_val;
    /*  exception
        when others then
          null;
      end;
    */
  END;

  /**
  * Создание нового покрытия по объекту страхования и риску в продукте
  * @author Denis Ivanov
  * @param p_t_product_line_id ИД риска в продукте
  * @param p_as_asset_id ИД объекта страхования
  * @return ид нового покрытия
  *
  * 16,01,2007 Шидловской Т.В.
  * добавлен анализ периода страхования и флага автопролонгирования
  *
  */
  FUNCTION cre_new_cover
  (
    p_as_asset_id       IN NUMBER
   ,p_t_product_line_id IN NUMBER
  ) RETURN NUMBER IS
  
    v_product_line          T_PRODUCT_LINE%ROWTYPE;
    v_cover                 P_COVER%ROWTYPE;
    v_agent_id              NUMBER;
    v_ag_prod_line_contr_id NUMBER;
    v_rate                  AG_RATE%ROWTYPE;
    v_p_cover_agent_id      NUMBER;
    v_period_prizn          NUMBER;
    v_hand                  NUMBER;
    v_assured_brief         VARCHAR2(100);
    v_policy_id             NUMBER;
  
    /* Курсор для выбора периода по умолчанию для создаваемого покрытия */
    CURSOR c_period IS
      SELECT ID
            ,NAME
            ,VALUE
            ,IS_DEFAULT
            ,P_POLICY_ID
        FROM (SELECT P.ID
                    ,P.description NAME
                    ,DECODE(put.brief
                           ,'Срок страхования по объекту страхования'
                           ,p.period_value_to
                           ,NULL) VALUE
                    ,plp.IS_DEFAULT
                    ,AA.P_POLICY_ID
                FROM t_period_use_type  put
                    ,t_period_type      pt
                    ,t_period           p
                    ,t_prod_line_period plp
                    ,p_pol_header       ph
                    ,p_policy           p_p
                    ,t_product_line     pl
                    ,as_asset           aa
               WHERE 1 = 1
                 AND pl.ID = p_t_product_line_id
                 AND aa.as_asset_id = p_as_asset_id
                 AND p_p.policy_id = aa.p_policy_id
                 AND ph.policy_header_id = p_p.pol_header_id
                 AND plp.product_line_id = pl.ID
                 AND p.ID = plp.period_id
                 AND pt.ID = p.period_type_id
                 AND put.t_period_use_type_id = plp.t_period_use_type_id
                 AND put.brief IN ('Срок страхования'
                                  ,'Срок страхования по объекту страхования')
                 AND plp.is_disabled = 0
              UNION
              SELECT p.ID
                    ,p.description NAME
                    ,DECODE(put.brief
                           ,'Срок страхования по объекту страхования'
                           ,p.period_value_to
                           ,NULL) VALUE
                    ,0.5 IS_DEFAULT
                    ,AA.P_POLICY_ID
                FROM t_period_use_type put
                    ,t_period_type     pt
                    ,t_period          p
                    ,t_product_period  pp
                    ,p_pol_header      ph
                    ,p_policy          p_p
                    ,t_product_line    pl
                    ,as_asset          aa
               WHERE 1 = 1
                 AND pl.ID = p_t_product_line_id
                 AND aa.as_asset_id = p_as_asset_id
                 AND p_p.policy_id = aa.p_policy_id
                 AND ph.policy_header_id = p_p.pol_header_id
                 AND pp.product_id = ph.product_id
                 AND pp.period_id = p_p.period_id
                 AND p.ID = pp.period_id
                 AND put.t_period_use_type_id = pp.t_period_use_type_id
                 AND pt.ID = p.period_type_id
                 AND put.brief IN ('Срок страхования'
                                  ,'Срок страхования по объекту страхования')
                 AND NOT EXISTS (SELECT 1
                        FROM ven_t_prod_line_period plp
                       WHERE plp.period_id = pp.period_id
                         AND plp.product_line_id = pl.ID
                         AND plp.is_disabled = 1)
               ORDER BY IS_DEFAULT DESC);
  
  BEGIN
    -- запросы необходимых значений
    SELECT pl.* INTO v_product_line FROM T_PRODUCT_LINE pl WHERE pl.ID = p_t_product_line_id;
  
    -- инициализация значений атрибутов покрытия по умолчанию
    -- ид
    SELECT sq_p_cover.NEXTVAL INTO v_cover.p_cover_id FROM dual;
    v_cover.ent_id := Ent.id_by_brief('P_COVER');
  
    -- объект страхования
    v_cover.as_asset_id := p_as_asset_id;
  
    -- Признак автопролонгации
    v_cover.is_avtoprolongation := v_product_line.is_avtoprolongation;
  
    -- группа рисков
    SELECT ID
      INTO v_cover.t_prod_line_option_id
      FROM (SELECT plo.ID
              FROM T_PROD_LINE_OPTION plo
             WHERE plo.product_line_id = p_t_product_line_id
             ORDER BY plo.option_id)
     WHERE ROWNUM = 1;
  
    -- признак периода страхования и анализ автопролонгирования
  
    BEGIN
      v_period_prizn := 0; -- признак периода
    
      SELECT 1
        INTO v_period_prizn
        FROM dual
       WHERE EXISTS --признак периода =1 ,т.е. договор более чем на год
       (SELECT '*'
                FROM P_POLICY pp
                JOIN AS_ASSET a
                  ON (pp.policy_id = a.p_policy_id)
                JOIN T_PERIOD tp
                  ON (pp.period_id = tp.ID)
                JOIN T_PERIOD_TYPE tpt
                  ON (tp.period_type_id = tpt.ID)
               WHERE ((tpt.brief = 'Y' -- годы
                     AND tp.period_value > 1) -- более одного
                     OR (tpt.brief = 'M' AND tp.period_value > 12) OR
                     (tpt.brief = 'O' AND MONTHS_BETWEEN(pp.end_date, pp.start_date) >= 24))
                 AND a.as_asset_id = p_as_asset_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_period_prizn := 0;
    END;
  
    IF v_period_prizn = 1
       AND v_product_line.is_avtoprolongation = 1
    THEN
      -- если признак периода =1 и флаг автопролонгирования = 1
    
      -- даты и страховая стоимость
      SELECT p.start_date
            ,ADD_MONTHS(p.start_date, 12) - 1
            ,DECODE(v_product_line.description
                   ,'Автокаско'
                   ,a.ins_price
                   ,'Ущерб'
                   ,a.ins_price
                   ,v_cover.ins_price)
        INTO v_cover.start_date
            ,v_cover.end_date
            ,v_cover.ins_price
        FROM AS_ASSET a
        JOIN P_POLICY p
          ON p.policy_id = a.p_policy_id
       WHERE a.as_asset_id = p_as_asset_id;
    
    ELSE
      -- даты и страховая стоимость
      SELECT p.start_date
            ,p.end_date
            , --v_cover.ins_price
             DECODE(v_product_line.description
                   ,'Автокаско'
                   ,a.ins_price
                   ,'Ущерб'
                   ,a.ins_price
                   ,v_cover.ins_price)
        INTO v_cover.start_date
            ,v_cover.end_date
            ,v_cover.ins_price
        FROM AS_ASSET a
        JOIN P_POLICY p
          ON p.policy_id = a.p_policy_id
       WHERE a.as_asset_id = p_as_asset_id;
    
    END IF;
    -- статус
    SELECT SH.STATUS_HIST_ID INTO v_cover.status_hist_id FROM STATUS_HIST sh WHERE sh.brief = 'NEW';
  
    -- Ф.Ганичев
    -- Подставить страхование до возраста из периода страхования на договоре
  
    FOR cur IN c_period
    LOOP
      v_cover.period_id            := cur.ID;
      v_cover.accum_period_end_age := cur.VALUE;
      v_policy_id                  := cur.p_policy_id;
      EXIT;
    END LOOP;
  
    -- Ф.Ганичев
    BEGIN
      SELECT pc.IS_HANDCHANGE_TARIFF
        INTO v_hand
        FROM p_cover            pc
            ,t_prod_line_option plo
       WHERE pc.AS_ASSET_ID = v_cover.as_asset_id
         AND pc.T_PROD_LINE_OPTION_ID = plo.ID
         AND plo.BRIEF = 'FLEXA';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    -- insured age для Ренессанса
  
    BEGIN
      --logcover('ins_age_start');
      SELECT ent.brief_by_id(a.ent_id)
        INTO v_assured_brief
        FROM AS_ASSET A
       WHERE as_asset_id = p_as_asset_id;
    
      IF v_assured_brief = 'AS_ASSURED'
      THEN
      
        SELECT TRUNC(MONTHS_BETWEEN(ass.start_date, cp.date_of_birth) / 12)
          INTO v_cover.insured_age
          FROM ven_as_assured ass
              ,ven_contact    c
              ,ven_cn_person  cp
         WHERE ass.as_assured_id = p_as_asset_id
           AND ass.assured_contact_id = c.contact_id
           AND c.contact_id = cp.contact_id
           AND MONTHS_BETWEEN(ass.start_date, cp.date_of_birth) > 0
           AND MONTHS_BETWEEN(ass.start_date, cp.date_of_birth) / 12 < 1000;
      
      END IF;
    END;
  
    -- 2008/03/12 Marchuk A
    -- Копирование страховой суммы с родительской программы
    FOR cur IN (SELECT pc.p_cover_id
                      ,pc.ins_amount
                  FROM PARENT_PROD_LINE   PPL
                      ,T_PROD_LINE_OPTION PLO
                      ,P_COVER            PC
                 WHERE 1 = 1
                   AND pc.as_asset_id = p_as_asset_id
                   AND plo.ID = pc.t_prod_line_option_id
                   AND ppl.t_prod_line_id = p_t_product_line_id
                   AND plo.product_line_id = ppl.t_parent_prod_line_id
                   AND ppl.is_parent_ins_amount = 1)
    LOOP
      v_cover.ins_amount := cur.ins_amount;
    END LOOP;
  
    BEGIN
      IF v_assured_brief != 'AS_ASSURED'
      THEN
        -- запишем в базу
        INSERT INTO P_COVER
          (p_cover_id
          ,as_asset_id
          ,t_prod_line_option_id
          ,period_id
          ,start_date
          ,end_date
          ,ins_price
          ,ins_amount
          ,status_hist_id
          ,is_avtoprolongation
          ,accum_period_end_age)
        VALUES
          (v_cover.p_cover_id
          ,v_cover.as_asset_id
          ,v_cover.t_prod_line_option_id
          ,v_cover.period_id
          ,v_cover.start_date
          ,v_cover.end_date
          ,v_cover.ins_price
          ,v_cover.ins_amount
          ,v_cover.status_hist_id
          ,v_cover.is_avtoprolongation
          ,v_cover.accum_period_end_age);
      
      ELSIF v_assured_brief = 'AS_ASSURED'
      THEN
        INSERT INTO P_COVER
          (p_cover_id
          ,as_asset_id
          ,t_prod_line_option_id
          ,period_id
          ,start_date
          ,end_date
          ,ins_price
          ,ins_amount
          ,status_hist_id
          ,is_avtoprolongation
          ,accum_period_end_age
          ,insured_age)
        VALUES
          (v_cover.p_cover_id
          ,v_cover.as_asset_id
          ,v_cover.t_prod_line_option_id
          ,v_cover.period_id
          ,v_cover.start_date
          ,v_cover.end_date
          ,v_cover.ins_price
          ,v_cover.ins_amount
          ,v_cover.status_hist_id
          ,v_cover.is_avtoprolongation
          ,v_cover.accum_period_end_age
          ,v_cover.insured_age);
      END IF;
      --logcover('ins_age_insertend');
    END;
    --  if nvl(v_hand, 0)=1 then
    --     update p_cover set is_handchange_amount = v_hand, is_handchange_tariff=v_hand where p_cover_id =   v_cover.p_cover_id;
    --  end if;
    -- Заполенение страховой суммы
    --   v_cover.ins_amount := pkg_cover.calc_ins_amount (v_cover.p_cover_id);
    --   update p_cover set ins_amount = v_cover.ins_amount where p_cover_id = v_cover.p_cover_id;
  
    -- поиск наибольшего значения даты окончания
    --
    --logcover('ins_age_upstart');
    UPDATE p_cover pcc
       SET pcc.insured_age = v_cover.insured_age
     WHERE pcc.p_cover_id = v_cover.p_cover_id;
    --logcover('ins_age_upend');
    --
    BEGIN
    
      SELECT MAX(c.end_date) INTO v_cover.end_date FROM P_COVER c WHERE c.as_asset_id = p_as_asset_id;
    
      UPDATE AS_ASSET a SET a.end_date = v_cover.end_date WHERE a.as_asset_id = p_as_asset_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    -- Исправлено Ф.Ганичевым. Надо определять программу по названию, а не id
    /*
        if (p_t_product_line_id = 8) then
          insert into p_cover_accident
            (id, accident_insurance_type)
          values
            (v_cover.p_cover_id, 1);
          update p_cover pc
             set pc.ent_id = ent.id_by_brief('P_COVER_ACCIDENT')
           where pc.p_cover_id = v_cover.p_cover_id;
        end if;
    */
    DECLARE
      v_pl_id NUMBER;
    BEGIN
      SELECT ID
        INTO v_pl_id
        FROM T_PRODUCT_LINE
       WHERE ID = p_t_product_line_id
         AND description = 'Несчастные случаи';
      INSERT INTO P_COVER_ACCIDENT (ID, accident_insurance_type) VALUES (v_cover.p_cover_id, 1);
      UPDATE P_COVER pc
         SET pc.ent_id = Ent.id_by_brief('P_COVER_ACCIDENT')
       WHERE pc.p_cover_id = v_cover.p_cover_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    -- агент
    -- todo: цикл по всем агентам в договоре
  
    v_agent_id := NULL;
  
    --!!! Временно закомментировано для показа в Ренесанс. Киселёв П. 12.07.2006г.
    -- Верный запрос чуть ниже.
    /* begin
      SELECT ppc.contact_id
        into v_agent_id
        FROM p_policy p, as_asset a, p_policy_contact ppc
       where a.as_asset_id = p_as_asset_id
         and a.p_policy_id = p.policy_id
         and ppc.policy_id = p.policy_id
         and ppc.contact_policy_role_id =
             (select *
                from (select cpr.id
                        from t_contact_pol_role cpr
                       where cpr.brief = 'Агент')
               where rownum = 1);
    exception
      when no_data_found then
        null;
    end;
    */
    BEGIN
      SELECT ach.agent_id
        INTO v_agent_id
        FROM P_POLICY           p
            ,AS_ASSET           a
            ,P_POL_HEADER       ph
            ,AG_CONTRACT        ac
            ,AG_CONTRACT_HEADER ach
       WHERE a.as_asset_id = p_as_asset_id
         AND a.p_policy_id = p.policy_id
         AND ph.policy_header_id = p.pol_header_id
         AND ph.ag_contract_1_id = ac.ag_contract_id
         AND ac.contract_id = ach.ag_contract_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    IF v_agent_id IS NOT NULL
    THEN
      BEGIN
        v_p_cover_agent_id := link_cover_agent(v_cover.p_cover_id, v_agent_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
    END IF;
  
    --opatsan
    --bug 1208
    BEGIN
      INSERT INTO p_cover_agent
        (cover_agent_id, cover_id, p_policy_agent_com_id)
        SELECT sq_p_cover_agent.NEXTVAL
              ,v_cover.p_cover_id
              ,pac.p_policy_agent_com_id
          FROM p_policy_agent_com pac
              ,p_policy_agent     pa
              ,p_policy           pp
         WHERE pp.policy_id = v_policy_id
           AND pp.pol_header_id = pa.policy_header_id
           AND pac.p_policy_agent_id = pa.p_policy_agent_id
           AND pac.t_product_line_id = p_t_product_line_id;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        NULL;
    END;
  
    --Каткевич А.Г. 01/08/2008  Не совсем мне понятно зачем здесь добавили расчет
    --Он мешает заливке бордеро, поэтому когда его вкачиваем это лучше коментить.
  
    /*  -- расчеты
    cover_property_cache('PROD_LINE_'||v_cover.p_cover_id):= p_t_product_line_id;
    update_cover_sum(v_cover.p_cover_id);*/
  
    --cover_property_cache('PROD_LINE_'||v_cover.p_cover_id):= null;
    RETURN(v_cover.p_cover_id);
  END;

  PROCEDURE inc_mandatory_covers_by_asset(p_as_asset_id NUMBER) IS
    v_p_cover_id NUMBER;
    v_ins_var_id NUMBER;
  
    v_prod_brief VARCHAR2(50);
  
    CURSOR cur_prod IS
      SELECT prod.brief
        FROM ven_as_asset          aa
            ,ven_p_policy          p
            ,ven_p_pol_header      ph
            ,ven_t_insurance_group ig
            ,ven_t_product         prod
       WHERE prod.product_id = ph.product_id
         AND ph.policy_header_id = p.pol_header_id
         AND p.policy_id = aa.p_policy_id
         AND aa.as_asset_id = p_as_asset_id;
  BEGIN
    BEGIN
      SELECT aa.ins_var_id INTO v_ins_var_id FROM AS_ASSET aa WHERE aa.as_asset_id = p_as_asset_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_ins_var_id := NULL;
    END;
  
    OPEN cur_prod;
    FETCH cur_prod
      INTO v_prod_brief;
    IF cur_prod%NOTFOUND
    THEN
      v_prod_brief := NULL;
    END IF;
    CLOSE cur_prod;
  
    IF v_ins_var_id IS NULL
    THEN
      FOR rec IN (SELECT pl.ID
                    FROM T_PRODUCT           pr
                        ,T_PRODUCT_VERSION   pv
                        ,T_PRODUCT_VER_LOB   pvl
                        ,T_PRODUCT_LINE      pl
                        ,T_PRODUCT_LINE_TYPE plt
                   WHERE pr.product_id = (SELECT ph.product_id
                                            FROM AS_ASSET     a
                                                ,P_POLICY     p
                                                ,P_POL_HEADER ph
                                           WHERE a.as_asset_id = p_as_asset_id
                                             AND a.p_policy_id = p.policy_id
                                             AND p.pol_header_id = ph.policy_header_id)
                     AND pv.product_id = pr.product_id
                     AND pvl.product_version_id = pv.t_product_version_id
                     AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
                     AND plt.product_line_type_id = pl.product_line_type_id
                     AND (plt.brief = 'MANDATORY' /* or plt.brief = 'RECOMMENDED'*/
                         ))
      LOOP
        BEGIN
          v_p_cover_id := include_cover(p_as_asset_id, rec.ID);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000
                                   ,'Ошибка подключения обязательной программы: ' || SQLERRM);
        END;
      END LOOP;
    END IF;
  
    IF v_prod_brief = 'ДМС'
       AND v_ins_var_id IS NOT NULL
    THEN
      FOR rec IN (SELECT pl.ID
                    FROM T_PRODUCT_LINE      pl
                        ,T_PRODUCT_LINE_TYPE plt
                   WHERE pl.ID = v_ins_var_id
                     AND pl.product_line_type_id = plt.product_line_type_id
                     AND pl.ID = v_ins_var_id
                     AND (plt.brief IN
                         ('COMBO', 'RISC', 'DEPOS', 'ATTACH' /*or plt.brief = 'RECOMMENDED'*/)))
      LOOP
        BEGIN
          v_p_cover_id := include_cover(p_as_asset_id, rec.ID);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Ошибка подключения программы');
        END;
      END LOOP;
    END IF;
  END;

  FUNCTION include_cover
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
  ) RETURN NUMBER IS
    v_ret             NUMBER;
    v_p_cover_id      NUMBER;
    v_brief           STATUS_HIST.brief%TYPE;
    v_decline_sum     NUMBER;
    v_policy_id       NUMBER;
    v_err_msg         VARCHAR2(4000);
    v_is_proportional NUMBER;
    v_recalc_covers   NUMBER := 1;
  BEGIN
    --logcover ('include_cov_start');
    SELECT a.p_policy_id INTO v_policy_id FROM as_asset a WHERE a.AS_ASSET_ID = p_asset_id;
    -- проверим зависимости покрытий
    IF check_dependences(p_asset_id, p_prod_line_id, v_err_msg) = 0
    THEN
      RAISE_APPLICATION_ERROR(-20000, v_err_msg);
    END IF;
    -- проверим, есть ли уже в договоре такое покрытие со статусом удален
    v_p_cover_id := NULL;
    BEGIN
      --logcover ('1');
      SELECT pc.p_cover_id
            ,sh.brief
            ,pc.decline_summ
        INTO v_p_cover_id
            ,v_brief
            ,v_decline_sum
        FROM P_COVER            pc
            ,AS_ASSET           a
            ,T_PROD_LINE_OPTION plo
            ,STATUS_HIST        sh
       WHERE a.as_asset_id = p_asset_id
         AND a.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = plo.ID
         AND plo.product_line_id = p_prod_line_id
         AND pc.status_hist_id = sh.status_hist_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_p_cover_id := NULL;
    END;
  
    IF v_brief = 'DELETED'
    THEN
    
      set_cover_status(v_p_cover_id, 'CURRENT');
      -- отменяем расторжение
    
      --UPDATE P_COVER pc
      --   SET pc.decline_date = NULL,
      --           pc.decline_summ = NULL,
      --          pc.RETURN_SUMM = NULL,
      --          pc.premium = pc.old_PREMIUM + pc.ADDED_SUMM -pc.PAYED_SUMM,
      --          pc.ADDED_SUMM = NULL,
      --          pc.PAYED_SUMM = NULL,
      --          pc.DECLINE_PARTY_ID = NULL,
      --          pc.DECLINE_REASON_ID = NULL
      -- WHERE pc.p_cover_id = v_p_cover_id;
    
      --UPDATE P_POLICY p
      --  SET p.decline_summ = p.decline_summ - v_decline_sum
      --WHERE p.policy_id = v_policy_id;
    
      pkg_decline2.ROLLBACK_COVER_DECLINE(v_p_cover_id, 1);
      v_recalc_covers := 0;
    
      /* 2008/03/04 Add Marchuk A bug #1596 */
      v_ret := v_p_cover_id;
      /* 2008/03/04 End bug #1596 */
    
    ELSIF (v_brief = 'NEW' OR v_brief = 'CURRENT')
    THEN
      v_ret := v_p_cover_id;
    ELSIF v_p_cover_id IS NULL
    THEN
      v_ret := cre_new_cover(p_asset_id, p_prod_line_id);
    END IF;
  
    BEGIN
      --logcover ('4');
      SELECT DECODE(po.brief, 'PROPORTIONAL', 1, 0)
        INTO v_is_proportional
        FROM p_pol_header    ph
            ,t_payment_order po
            ,p_policy        p
       WHERE ph.T_PROD_PAYMENT_ORDER_ID = po.T_PAYMENT_ORDER_ID(+)
         AND ph.POLICY_HEADER_ID = p.POL_HEADER_ID
         AND p.POLICY_ID = v_policy_id;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_is_proportional := 0;
    END;
    IF v_is_proportional = 1
    THEN
      --logcover ('5');
      UPDATE p_cover pc SET pc.IS_PROPORTIONAL = 1 WHERE pc.P_COVER_ID = v_ret;
    END IF;
  
    --opatsan
    --перенес в cre_new_cover
    /*    insert into p_cover_agent
          (cover_agent_id, cover_id, p_policy_agent_com_id)
          select sq_p_cover_agent.nextval, v_ret, pac.p_policy_agent_com_id
            from p_policy_agent_com pac, p_policy_agent pa, p_policy pp
           where pp.policy_id = v_policy_id
             and pp.pol_header_id = pa.policy_header_id
             and pac.p_policy_agent_id = pa.p_policy_agent_id
             and pac.t_product_line_id = p_prod_line_id
             and not exists
           (select 1
                    from p_policy_agent_com pac1,
                         p_policy_agent     pa1,
                         p_policy           pp1,
                         p_cover_agent      ca
                   where ca.cover_id = v_ret
                     and ca.p_policy_agent_com_id = pac1.p_policy_agent_com_id
                     and pp1.policy_id = v_policy_id
                     and pp1.pol_header_id = pa1.policy_header_id
                     and pac1.p_policy_agent_id = pa1.p_policy_agent_id
                     and pac1.t_product_line_id = p_prod_line_id);
    */
    IF v_recalc_covers = 0
    THEN
      utils.PUT('RECALC_COVERS', 'FALSE');
    END IF;
  
    Pkg_Policy.update_policy_sum(v_policy_id);
  
    utils.PUT('RECALC_COVERS', 'TRUE');
  
    RETURN v_ret;
    --logcover ('include_cov_end');
  END;
  /*
    Устаревшая
  */
  PROCEDURE calc_decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decl_date    IN DATE
   ,p_is_charge    IN NUMBER
   ,p_is_comission IN NUMBER
   ,po_ins_sum     OUT NUMBER
   ,po_prem_sum    OUT NUMBER
   ,po_pay_sum     OUT NUMBER
   ,po_payoff_sum  OUT NUMBER
   ,po_charge_sum  OUT NUMBER
   ,po_com_sum     OUT NUMBER
   ,po_zsp_sum     OUT NUMBER
   ,po_decline_sum OUT NUMBER
  ) IS
    v_cover         P_COVER%ROWTYPE;
    plo             T_PROD_LINE_OPTION%ROWTYPE;
    v_amount        Pkg_Payment.t_amount;
    dni_ost         NUMBER;
    dni_all         NUMBER;
    v_policy        P_POLICY%ROWTYPE; -- Действующая версия полиса
    v_prev_cover    P_COVER%ROWTYPE; -- Действующая версия покрытия
    v_charge_amount NUMBER;
    v_pay_amount    NUMBER;
  BEGIN
    SELECT c.* INTO v_cover FROM P_COVER c WHERE c.p_cover_id = p_p_cover_id;
  
    -- Ф. Ганичев. Поиск соответствующего покрытия в действующей версии, чтобы взять с него премию
    BEGIN
      -- Нахожу расторгаемую версию полиса
      SELECT p.*
        INTO v_policy
        FROM P_POLICY p
            ,P_COVER  c
            ,AS_ASSET a
       WHERE a.P_POLICY_ID = p.policy_id
         AND c.as_asset_id = a.AS_ASSET_ID
         AND c.p_cover_id = p_p_cover_id;
      -- Нахожу действующую версию
      SELECT *
        INTO v_policy
        FROM P_POLICY
       WHERE version_num = v_policy.version_num - 1
         AND pol_header_id = v_policy.pol_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Невозможно найти действующую версию полиса');
    END;
  
    BEGIN
      SELECT c.*
        INTO v_prev_cover
        FROM P_COVER  c
            ,AS_ASSET a
       WHERE c.AS_ASSET_ID = a.AS_ASSET_ID
         AND a.P_POLICY_ID = v_policy.policy_id
         AND c.T_PROD_LINE_OPTION_ID = v_cover.T_PROD_LINE_OPTION_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Невозможно найти покрытие на действующей версии полиса');
    END;
    -- Конец. Поиск соответствующего покрытия в действующей версии, чтобы взять с него премию
  
    SELECT p.* INTO plo FROM T_PROD_LINE_OPTION p WHERE p.ID = v_cover.t_prod_line_option_id;
  
    po_ins_sum := v_cover.ins_amount;
    -- Ф.Ганичев
    po_prem_sum := v_prev_cover.premium;
    --po_prem_sum := v_cover.premium;
  
    -- расчет оплаченной суммы
    v_amount        := Pkg_Payment.get_pay_cover_amount(p_p_cover_id);
    v_pay_amount    := v_amount.fund_amount;
    v_charge_amount := Pkg_Payment.get_charge_cover_amount(p_p_cover_id).fund_amount;
  
    po_pay_sum := v_amount.fund_amount;
  
    -- расчет выплаченной суммы
    IF pkg_app_param.get_app_param_n('CLIENTID') = 10
    THEN
      BEGIN
        SELECT NVL(SUM(cc.payment_sum), 0)
          INTO po_payoff_sum
          FROM c_claim_header ch
              ,c_claim        cc
              ,c_claim_status cs
         WHERE ch.p_cover_id = v_prev_cover.p_cover_id
           AND cc.c_claim_header_id = ch.c_claim_header_id
           AND cc.seqno =
               (SELECT MAX(cl.seqno) FROM c_claim cl WHERE cl.c_claim_header_id = ch.c_claim_header_id)
           AND cs.c_claim_status_id = cc.claim_status_id
           AND cs.brief LIKE 'ЗАКРЫТО'
           AND cc.claim_status_date <= p_decl_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          po_payoff_sum := 0;
      END;
    ELSE
      po_payoff_sum := 0;
    END IF;
  
    -- расчет расходов на ведение дела
    SELECT ROUND(NVL(ig.operation_cost, 0) * /*v_cover.premium*/
                 po_prem_sum
                ,2)
      INTO po_charge_sum
      FROM T_INSURANCE_GROUP  ig
          ,T_PROD_LINE_OPTION plo
          ,T_PRODUCT_LINE     pl
     WHERE plo.ID = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.ID
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- расчет суммы коммиссии агента
    -- todo предусмотреть, что ставка может быть задана абсолютным значением
    SELECT NVL(ROUND(SUM(pac.val_com) * /*v_cover.premium*/
                     po_prem_sum / 100
                    ,2)
              ,0)
      INTO po_com_sum
      FROM P_COVER_AGENT      ca
          ,p_policy_agent_com pac
     WHERE ca.cover_id = p_p_cover_id
       AND pac.p_policy_agent_com_id = ca.p_policy_agent_com_id;
  
    -- расчет ЗСП (прората)
    -- todo сделать возможность выбора алгоритма расчета ЗСП и суммы возврата
    IF (v_cover.start_date < p_decl_date AND v_cover.end_date > p_decl_date)
    THEN
      -- для ОСАГО
      IF (plo.description = 'ОСАГО')
      THEN
        -- ОСАГО
        SELECT SUM(d.dni_ost)
              ,SUM(d.dni_all)
          INTO dni_ost
              ,dni_all
          FROM (SELECT --p.as_asset_id,
                 CASE
                   WHEN p.end_date < p_decl_date THEN
                    0
                   WHEN p.end_date >= p_decl_date
                        AND p.start_date <= p_decl_date THEN
                    (TRUNC(p.end_date) - TRUNC(p_decl_date))
                   WHEN p.start_date > p_decl_date THEN
                    (TRUNC(p.end_date) - TRUNC(p.start_date))
                 END dni_ost
                ,(TRUNC(p.end_date) - TRUNC(p.start_date) + 1) dni_all
                  FROM AS_ASSET_PER p
                 WHERE p.as_asset_id = v_cover.as_asset_id) d;
        po_zsp_sum := ROUND( /*v_cover.premium*/(po_prem_sum - po_charge_sum) * (dni_all - dni_ost) /
                            dni_all
                           ,2);
        -- для Автокаско
      ELSIF (plo.description = 'Автокаско' OR plo.description = 'Ущерб' OR
            plo.description = 'Несчастные случаи' OR plo.description = 'Гражданская ответственность' OR
            plo.description = 'Дополнительное оборудование' OR plo.description = 'Техническая помощь')
      THEN
        po_zsp_sum := ROUND( /*v_cover.premium*/po_prem_sum *
                            CEIL(MONTHS_BETWEEN(p_decl_date + 1
                                               ,v_cover.start_date)) /
                            MONTHS_BETWEEN((v_cover.end_date + 1)
                                          ,v_cover.start_date)
                           ,2);
      ELSE
        po_zsp_sum := ROUND( /*v_cover.premium*/po_prem_sum * (p_decl_date - v_cover.start_date) /
                            (v_cover.end_date - v_cover.start_date)
                           ,2);
      END IF;
    ELSIF v_cover.start_date > p_decl_date
    THEN
      po_zsp_sum := 0;
    ELSIF v_cover.end_date < p_decl_date
    THEN
      po_zsp_sum :=  /*v_cover.premium*/
       po_prem_sum;
    END IF;
  
    -- расчет суммы возврата
    po_decline_sum := po_pay_sum - po_zsp_sum - po_payoff_sum;
    IF NVL(p_is_charge, 0) = 1
    THEN
      po_decline_sum := po_decline_sum - po_charge_sum;
      po_zsp_sum     := po_zsp_sum + po_charge_sum;
    END IF;
    IF NVL(p_is_comission, 0) = 1
    THEN
      po_decline_sum := po_decline_sum - po_com_sum;
      po_zsp_sum     := po_zsp_sum + po_com_sum;
    END IF;
    IF po_decline_sum < 0
    THEN
      po_decline_sum := 0;
    END IF;
    IF po_zsp_sum > /*v_cover.premium*/
       po_prem_sum
    THEN
      po_zsp_sum :=  /*v_cover.premium*/
       po_prem_sum;
    END IF;
  
    po_prem_sum := po_prem_sum + v_pay_amount - v_charge_amount;
  
    UPDATE ven_p_cover pc
       SET pc.decline_date = p_decl_date
          ,pc.decline_summ = po_decline_sum
          ,pc.return_summ  = po_decline_sum
          ,
           --     pc.old_premium = po_prem_sum+v_pay_amount-v_charge_amount,
           --   pc.premium = po_zsp_sum,
           pc.premium               = po_prem_sum
          ,pc.IS_HANDCHANGE_DECLINE = 1
          ,pc.IS_HANDCHANGE_AMOUNT  = 1
          ,pc.IS_HANDCHANGE_DEDUCT  = 1
          ,pc.IS_HANDCHANGE_PREMIUM = 1
          ,pc.IS_HANDCHANGE_TARIFF  = 1
     WHERE pc.p_cover_id = v_cover.p_cover_id;
  
    COMMIT;
    -- po_prem_sum:= po_zsp_sum;
  END;

  FUNCTION decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decline_date DATE
  ) RETURN NUMBER IS
    v_cover         P_COVER%ROWTYPE;
    v_amount        Pkg_Payment.t_amount;
    v_func_brief    T_PROD_COEF_TYPE.brief%TYPE;
    v_decline_sum   NUMBER;
    v_zsp           NUMBER;
    v_charge_amount NUMBER;
    v_pay_amount    NUMBER;
  
  BEGIN
  
    -- установим дату расторжения
    UPDATE P_COVER pc SET pc.decline_date = p_decline_date WHERE pc.p_cover_id = p_p_cover_id;
  
    SELECT c.* INTO v_cover FROM P_COVER c WHERE c.p_cover_id = p_p_cover_id;
  
    -- расчет оплаченной суммы
    v_amount        := Pkg_Payment.get_pay_cover_amount(p_p_cover_id);
    v_pay_amount    := v_amount.fund_amount;
    v_charge_amount := Pkg_Payment.get_charge_cover_amount(p_p_cover_id).fund_amount;
  
    --pkg_renlife_utils.tmp_log_writer('v_pay_amount '||v_pay_amount||' v_cahrge_amount '||v_charge_amount);
    -- расчет ЗСП по алгоритму,
    -- определенному по умолчанию для данной программы по покрытию.
    BEGIN
      SELECT pct.brief
        INTO v_func_brief
        FROM T_METOD_DECLINE  md
            ,T_PROD_COEF_TYPE pct
       WHERE md.t_metod_decline_id = (SELECT *
                                        FROM (SELECT plmd.t_prodline_metdec_met_decl_id
                                                FROM T_PRODUCT_LINE       pl
                                                    ,T_PROD_LINE_OPTION   plo
                                                    ,T_PROD_LINE_MET_DECL plmd
                                               WHERE plo.ID = v_cover.t_prod_line_option_id
                                                 AND plo.product_line_id = pl.ID
                                                 AND plmd.t_prodline_metdec_prod_line_id = pl.ID
                                               ORDER BY NVL(plmd.is_default, 0) DESC)
                                       WHERE ROWNUM = 1)
         AND pct.t_prod_coef_type_id = md.metod_func_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Не определен алгоритм расчета ЗСП по программе');
    END;
    BEGIN
      v_zsp := Pkg_Tariff_Calc.calc_fun(v_func_brief, Ent.id_by_brief('P_COVER'), v_cover.p_cover_id);
      --  pkg_renlife_utils.tmp_log_writer('v_zsp '||v_zsp);
      v_decline_sum := v_amount.fund_amount - v_zsp;
      --  pkg_renlife_utils.tmp_log_writer('v_decline_sum '||v_decline_sum);
      /*
      EXCEPTION
       WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20000, SQLERRM);*/
    END;
  
    IF v_decline_sum < 0
    THEN
      v_decline_sum := 0;
    END IF;
  
    UPDATE P_COVER pc
       SET pc.premium      = pc.premium + v_pay_amount - v_charge_amount
          ,pc.decline_summ = v_decline_sum
          ,pc.return_summ  = v_decline_sum
     WHERE pc.p_cover_id = p_p_cover_id;
  
    RETURN v_decline_sum;
  END;

  FUNCTION calc_cover_adm_exp_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount Pkg_Payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM P_POLICY p
                     ,P_COVER  pc
                     ,AS_ASSET a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      -- amount:= Pkg_Decline.get_cover_admin_exp_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := Pkg_Decline2.get_cover_admin_exp_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  FUNCTION calc_cover_cash_surr_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount Pkg_Payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM P_POLICY p
                     ,P_COVER  pc
                     ,AS_ASSET a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      --amount:= Pkg_Decline.get_cover_cash_surr_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := Pkg_Decline2.get_cover_cash_surr_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  FUNCTION calc_cover_accident_return_sum
  (
    p_p_cover_id NUMBER
   ,p_rules      NUMBER
  ) RETURN NUMBER IS
    amount Pkg_Payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM P_POLICY p
                     ,P_COVER  pc
                     ,AS_ASSET a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      --amount:= Pkg_Decline.get_cover_accident_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := Pkg_Decline_veselek.get_cover_accident_return_sum(ph.pol_header_id
                                                                 ,p_p_cover_id
                                                                 ,p_rules);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  FUNCTION calc_cover_life_per_return_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount Pkg_Payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM P_POLICY p
                     ,P_COVER  pc
                     ,AS_ASSET a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      --amount:= Pkg_Decline.get_cover_life_per_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := Pkg_Decline2.get_cover_life_per_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  /**
  * Расчет заработанной премии при уменьшении премии по покрытию по умолчанию.
  * @author Denis Ivanov
  * @param p_p_cover_id ИД объекта сущности P_COVER
  * @return значение ЗСП прората с учетом выплат комиссионных и убытков.
  */
  FUNCTION calc_zsp_common(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_cover      P_COVER%ROWTYPE;
    v_payoff_sum NUMBER;
    v_rvd_sum    NUMBER;
    v_com_sum    NUMBER;
    v_zsp_sum    NUMBER;
    v_decl_date  DATE;
  BEGIN
    SELECT pc.* INTO v_cover FROM P_COVER pc WHERE pc.p_cover_id = p_p_cover_id;
    v_decl_date := v_cover.decline_date;
  
    -- расчет суммы выплат
    v_payoff_sum := 0; -- выплаты не учитываются
  
    -- расчет суммы коммиссии агента
    v_com_sum := 0; -- комиссионные не учитваются, поскольку учитываются РВД
  
    -- расчет "чистой" ЗСП  (прората)
    v_zsp_sum := 0;
    IF (v_cover.start_date < v_decl_date AND v_cover.end_date > v_decl_date)
    THEN
      v_zsp_sum := ROUND(v_cover.premium * (v_decl_date - v_cover.start_date) /
                         (v_cover.end_date - v_cover.start_date)
                        ,2);
    ELSIF v_cover.start_date > v_decl_date
    THEN
      v_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decl_date
    THEN
      v_zsp_sum := v_cover.premium;
    END IF;
  
    v_rvd_sum := 0;
  
    -- расчет расходов на ведение дела
    SELECT ROUND(NVL(ig.operation_cost, 0) * (v_cover.premium - v_zsp_sum), 2)
      INTO v_rvd_sum
      FROM T_INSURANCE_GROUP  ig
          ,T_PROD_LINE_OPTION plo
          ,T_PRODUCT_LINE     pl
     WHERE plo.ID = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.ID
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- расчет ЗСП с учетом РВД в части незаработанной премии
    v_zsp_sum := v_zsp_sum + v_rvd_sum;
    RETURN v_zsp_sum;
  END;

  PROCEDURE exclude_child_covers(par_cover_id IN NUMBER) IS
  BEGIN
    FOR pcov IN (SELECT pc.*
                   FROM p_cover            pc
                       ,t_prod_line_option plo
                  WHERE pc.AS_ASSET_ID =
                        (SELECT as_asset_id FROM p_cover WHERE p_cover_id = par_cover_id)
                    AND pc.STATUS_HIST_ID <> status_hist_id_del
                    AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                    AND plo.PRODUCT_LINE_ID IN
                        (SELECT ppl.T_PROD_LINE_ID
                           FROM parent_prod_line ppl
                          WHERE ppl.T_PARENT_PROD_LINE_ID IN
                                (SELECT plop.PRODUCT_LINE_ID
                                   FROM t_prod_line_option plop
                                       ,p_cover            pcv
                                  WHERE plop.ID = pcv.T_PROD_LINE_OPTION_ID
                                    AND pcv.P_COVER_ID = par_cover_id)))
    LOOP
      exclude_cover(pcov.p_cover_id);
    END LOOP;
  END;

  FUNCTION calc_new_cover_premium(p_p_cover_id NUMBER) RETURN NUMBER IS
  
    v_prem             NUMBER := 0;
    v_is_cover_changed NUMBER := 0;
    v_start            DATE;
    v_end              DATE;
    v_start_per        DATE;
    v_end_per          DATE;
    d1                 DATE;
    d2                 DATE;
  BEGIN
  
    -- Алгоритм работает, если покрытие действует не более года
    -- для многолетних договоров покрытия должны пролонгироваться
    -- Срок покрытия не долджен меняться иначе чем автопролонгацией!
    -- Периодичность оплаты не должна меняться от версии к версии
    -- Выборка всех версия покрытия, в которых были изменения взноса
    -- Со start_date версии действует уже НОВЫЙ ВЗНОС
    -- END_DATE покрытия - последний день его действия
    FOR covers IN (SELECT c.*
                         ,lead(c.pol_start_date) OVER(PARTITION BY c.POL_HEADER_ID ORDER BY c.policy_id ASC) next_pol_start_date
                     FROM (SELECT pc.*
                                 ,lag(pc.FEE) OVER(PARTITION BY pc.T_PROD_LINE_OPTION_ID, a.P_ASSET_HEADER_ID ORDER BY pc.AS_ASSET_ID ASC) prev_pc_fee
                                 ,p.START_DATE pol_start_date
                                 ,NVL(pt.NUMBER_OF_PAYMENTS, 1) num_of_paym
                                 ,p.VERSION_NUM
                                 ,p.num
                                 ,ph.start_date ph_start_date
                                 ,p.POL_HEADER_ID
                                 ,p.POLICY_ID
                             FROM p_cover         pc
                                 ,p_cover         pc1
                                 ,as_asset        a
                                 ,as_asset        a1
                                 ,ven_p_policy    p
                                 ,p_pol_header    ph
                                 ,t_payment_terms pt
                            WHERE pc1.P_COVER_ID = p_p_cover_id
                              AND pc1.T_PROD_LINE_OPTION_ID = pc.T_PROD_LINE_OPTION_ID
                              AND pc1.AS_ASSET_ID = a1.AS_ASSET_ID
                              AND a1.P_ASSET_HEADER_ID = a.P_ASSET_HEADER_ID
                              AND a.AS_ASSET_ID = pc.AS_ASSET_ID
                              AND pc.start_date = pc1.start_date
                              AND pc.end_date = pc1.end_date
                              AND a.P_POLICY_ID = p.POLICY_ID
                              AND p.PAYMENT_TERM_ID = pt.ID
                              AND ph.policy_header_id = p.pol_header_id) c
                    WHERE NVL(prev_pc_fee, 0) <> NVL(fee, 0)
                    ORDER BY p_cover_id ASC)
    LOOP
      IF covers.FEE IS NULL
      THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Не указан взнос по покрытию в версии № ' || covers.version_num ||
                                '.Договор ' || covers.num);
      END IF;
    
      v_start     := GREATEST(TRUNC(covers.start_date, 'DD'), TRUNC(covers.pol_start_date, 'DD'));
      v_end       := LEAST(TRUNC(covers.end_date + 1, 'DD')
                          ,TRUNC(NVL(covers.next_pol_start_date, covers.end_date + 1), 'DD'));
      v_start_per := pkg_payment.GET_PERIOD_DATE(TRUNC(covers.ph_start_date, 'DD')
                                                ,covers.num_of_paym
                                                ,v_start);
      -- Цикл по всем периодам оплаты, куда попадает покрытие
      LOOP
        v_end_per := ADD_MONTHS(v_start_per, 12 / covers.num_of_paym);
        IF (v_start <= v_start_per)
           AND (v_end >= v_end_per)
        THEN
          -- Срок действия покрытия полностью охватывает период
          v_prem := v_prem + covers.fee;
        ELSE
          d1     := GREATEST(v_start, v_start_per);
          d2     := LEAST(v_end, v_end_per);
          v_prem := v_prem + covers.fee * (d2 - d1) / (v_end_per - v_start_per);
          --dbms_output.put_line((covers.fee*(d2-d1)/(v_end_per - v_start_per))||' '||d2||' '||d1||' '||v_end_per||' '||v_start_per);
        END IF;
      
        IF v_end <= v_end_per
        THEN
          EXIT;
        ELSE
          v_start_per := v_end_per;
        END IF;
      END LOOP;
    
    END LOOP;
    RETURN v_prem;
  END;

  PROCEDURE exclude_cover(par_cover_id IN NUMBER) IS
    v_brief                VARCHAR2(30);
    v_prod_line_type_brief T_PRODUCT_LINE_TYPE.brief%TYPE;
    v_decline_sum          NUMBER;
    v_s                    NUMBER;
    v_policy_id            NUMBER;
    v_policy_start_date    DATE;
    v_err                  VARCHAR2(1000);
  BEGIN
  
    exclude_child_covers(par_cover_id);
  
    SELECT sh.brief
          ,a.p_policy_id
      INTO v_brief
          ,v_policy_id
      FROM P_COVER     p
          ,STATUS_HIST sh
          ,AS_ASSET    a
     WHERE p.p_cover_id = par_cover_id
       AND p.as_asset_id = a.as_asset_id
       AND p.status_hist_id = sh.status_hist_id(+);
  
    -- если обязательное покрытие, то удалять нельзя
    /*    SELECT plt.brief
        into v_prod_line_type_brief
        FROM t_product_line_type plt,
             t_product_line      pl,
             t_prod_line_option  plo,
             p_cover             pc
       where pc.p_cover_id = par_cover_id
         and pc.t_prod_line_option_id = plo.id
         and plo.product_line_id = pl.id
         and pl.product_line_type_id = plt.product_line_type_id;
      if v_prod_line_type_brief = 'MANDATORY' then
        raise_application_error(-20000,
                                'Покрытие является обязательным. Исключать нельзя.');
      end if;
    */
    CASE v_brief
      WHEN 'NEW' THEN
        -- delete from p_cover p where p.p_cover_id = par_cover_id;
        -- Исправлено Ф.Ганичевым для удаления дочерних P_COVER-ов, напр, P_COVER_ACCIDENT
        DELETE FROM ven_p_cover p WHERE p.p_cover_id = par_cover_id;
      WHEN 'CURRENT' THEN
        -- получим ид и дату начала полиса, откуда исключается покрытие
        SELECT p.policy_id
              ,p.start_date
          INTO v_policy_id
              ,v_policy_start_date
          FROM P_POLICY p
              ,AS_ASSET a
              ,P_COVER  pc
         WHERE pc.p_cover_id = par_cover_id
           AND pc.as_asset_id = a.as_asset_id
           AND a.p_policy_id = p.policy_id;
      
        -- подсчитаем сумму возврата
        /*        calc_decline_cover(par_cover_id,
        v_policy_start_date,
        0,
        0,
        v_s,
        v_s,
        v_s,
        v_s,
        v_s,
        v_s,
        v_s,
        v_decline_sum);*/
      
        -- Ф.Ганичев
        SELECT decline_summ INTO v_decline_sum FROM P_COVER WHERE p_cover_id = par_cover_id;
        IF v_decline_sum IS NULL
        THEN
          v_decline_sum := decline_cover(par_cover_id, v_policy_start_date);
          UPDATE P_COVER pc
             SET pc.decline_date = v_policy_start_date
                ,pc.decline_summ = v_decline_sum
           WHERE pc.p_cover_id = par_cover_id;
        END IF;
        -- просуммируем на полис
        --UPDATE P_POLICY p
        --   SET p.decline_date = p.start_date,
        --       p.decline_summ = NVL(p.decline_summ, 0) + v_decline_sum
        -- WHERE p.policy_id = v_policy_id;
      
        set_cover_status(par_cover_id, 'DELETED');
      ELSE
        NULL;
    END CASE;
    -- пересчитать суммы на содержимом полиса
    --pkg_policy.update_policy_sum(v_policy_id);
  EXCEPTION
    WHEN OTHERS THEN
      v_err := SQLERRM;
      IF v_err LIKE '%ORA-02292%FK_TRANS_OBJ%'
      THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Есть начисления по покрытию. Проверьте наличие счетов в статусе к оплате');
      ELSE
        RAISE;
      END IF;
  END;

  PROCEDURE copy_p_cover
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    v_cover_old_id   NUMBER;
    v_cover_new_id   NUMBER;
    v_cover_accident P_COVER_ACCIDENT%ROWTYPE;
    p_p              P_POLICY%ROWTYPE;
    p_h              P_POL_HEADER%ROWTYPE;
    v_is_new         NUMBER;
  
  BEGIN
  
    SELECT ph.*
      INTO p_h
      FROM AS_ASSET ass
      JOIN P_POLICY pp
        ON pp.policy_id = ass.p_policy_id
      JOIN P_POL_HEADER ph
        ON ph.policy_header_id = pp.pol_header_id
     WHERE ass.as_asset_id = p_new_id;
  
    SELECT pp.*
      INTO p_p
      FROM AS_ASSET ass
      JOIN P_POLICY pp
        ON pp.policy_id = ass.p_policy_id
     WHERE ass.as_asset_id = p_new_id;
  
    FOR v_r IN (SELECT *
                  FROM ven_p_cover t
                 WHERE t.as_asset_id = p_old_id
                   AND t.status_hist_id <> status_hist_id_del)
    LOOP
      IF (p_h.is_new = 0 AND p_p.version_num = 1)
      THEN
        v_is_new := 1;
      ELSE
        v_is_new := 0;
      END IF;
      v_cover_new_id := cover_copy(v_r, p_new_id, v_is_new);
      /*
       v_cover_old_id := v_r.p_cover_id;
       SELECT sq_p_cover.NEXTVAL INTO v_r.p_cover_id FROM dual;
       v_r.as_asset_id := p_new_id;
      
       -- замена статуса навый на текущий
       IF (p_h.is_new = 0 AND p_p.version_num = 1) THEN
        v_r.status_hist_id := status_hist_id_new;
       ELSE
         IF v_r.status_hist_id = status_hist_id_new THEN
           v_r.status_hist_id := status_hist_id_curr;
         END IF;
       END IF;
      
       v_r.old_premium := v_r.premium;
       INSERT INTO ven_p_cover VALUES v_r;
      
      -- copy
       Pkg_Tariff.copy_tariff(v_cover_old_id ,v_r.p_cover_id);
      
       -- если НС
       IF (Ent.brief_by_id(v_r.ent_id) = 'P_COVER_ACCIDENT') THEN
         SELECT *
           INTO v_cover_accident
           FROM p_cover_accident pca
          WHERE pca.id = v_cover_old_id;
         v_cover_accident.id := v_r.p_cover_id;
         INSERT INTO p_cover_accident VALUES v_cover_accident;
       END IF;*/
    END LOOP;
  END;

  FUNCTION cover_copy
  (
    p_old_cover    IN OUT ven_p_cover%ROWTYPE
   ,p_new_asset_id NUMBER
   ,p_is_new       NUMBER
  ) RETURN NUMBER IS
    v_cover_old_id    NUMBER;
    v_cover_accident  P_COVER_ACCIDENT%ROWTYPE;
    v_form_type_brief VARCHAR2(30);
  BEGIN
    v_cover_old_id := p_old_cover.p_cover_id;
    SELECT sq_p_cover.NEXTVAL INTO p_old_cover.p_cover_id FROM dual;
    p_old_cover.as_asset_id := p_new_asset_id;
  
    -- замена статуса навый на текущий
    IF (p_is_new = 1)
    THEN
      p_old_cover.status_hist_id := status_hist_id_new;
    ELSE
      IF p_old_cover.status_hist_id = status_hist_id_new
      THEN
        p_old_cover.status_hist_id := status_hist_id_curr;
      END IF;
    END IF;
  
    -- opatsan
    -- если автопролонгирование + клиент 10 + ипотека или автокаско
    -- снимаем флаги ручного изменения
    SELECT pft.brief
      INTO v_form_type_brief
      FROM p_pol_header       ph
          ,t_product          p
          ,t_policy_form_type pft
          ,p_policy           pp
          ,as_asset           aa
     WHERE aa.as_asset_id = p_new_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND ph.product_id = p.product_id
       AND p.t_policy_form_type_id = pft.t_policy_form_type_id(+);
  
    IF p_old_cover.is_avtoprolongation = 1
       AND v_form_type_brief IN ('Ипотека', 'Автокаско')
       AND ents.client_id = 10
    THEN
      p_old_cover.is_handchange_amount  := 0;
      p_old_cover.is_handchange_decline := 0;
      p_old_cover.is_handchange_deduct  := 0;
      p_old_cover.is_handchange_premium := 0;
      p_old_cover.is_handchange_tariff  := 0;
    END IF;
  
    p_old_cover.old_premium      := p_old_cover.premium;
    p_old_cover.ext_id           := NULL;
    p_old_cover.premia_base_type := 0;
  
    LOG(p_old_cover.p_cover_id, 'P_OLD_COVER.PREMIA_BASE_TYPE ' || p_old_cover.premia_base_type);
  
    INSERT INTO ven_p_cover VALUES p_old_cover;
    -- copy
    Pkg_Tariff.copy_tariff(v_cover_old_id, p_old_cover.p_cover_id);
  
    -- если НС
    IF (Ent.brief_by_id(p_old_cover.ent_id) = 'P_COVER_ACCIDENT')
    THEN
      SELECT * INTO v_cover_accident FROM P_COVER_ACCIDENT pca WHERE pca.ID = v_cover_old_id;
      v_cover_accident.ID := p_old_cover.p_cover_id;
      INSERT INTO P_COVER_ACCIDENT VALUES v_cover_accident;
    END IF;
    RETURN p_old_cover.p_cover_id;
  END;

  PROCEDURE link_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  ) IS
    c NUMBER;
  BEGIN
    FOR rc IN (SELECT p.p_cover_id
                 FROM AS_ASSET a
                     ,P_COVER  p
                WHERE a.p_policy_id = p_pol_id
                  AND p.as_asset_id = a.as_asset_id)
    LOOP
      c := link_cover_agent(rc.p_cover_id, p_agent_id);
    END LOOP;
  END;

  PROCEDURE unlink_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  ) IS
  BEGIN
    /* DELETE FROM P_COVER_AGENT ca
    WHERE ca.agent_id = p_agent_id
      AND ca.cover_id IN
          (SELECT p.p_cover_id
             FROM AS_ASSET a, P_COVER p
            WHERE a.p_policy_id = p_pol_id
              AND a.as_asset_id = p.as_asset_id); */
    NULL;
  END;

  FUNCTION get_policy_confirm_date(p_p_cover_id IN NUMBER) RETURN DATE AS
    v_result DATE;
  BEGIN
    SELECT pp.confirm_date
      INTO v_result
      FROM P_COVER pc
     INNER JOIN AS_ASSET aa
        ON aa.as_asset_id = pc.as_asset_id
     INNER JOIN P_POLICY pp
        ON pp.policy_id = aa.p_policy_id
     WHERE EXISTS (SELECT 1
              FROM P_COVER pc_curr
             INNER JOIN AS_ASSET aa_curr
                ON aa_curr.as_asset_id = pc_curr.as_asset_id
             WHERE pc_curr.p_cover_id = p_p_cover_id
               AND aa.p_asset_header_id = aa_curr.p_asset_header_id
               AND pc.t_prod_line_option_id = pc_curr.t_prod_line_option_id)
       AND pc.status_hist_id = Pkg_Cover.status_hist_id_new;
    RETURN v_result;
  END;

  /**
  * Проверить возможность добавления покрытия связанного с заданной программой
  * @author Ф.Ганичев
  * @param p_asset_id ид объекта страхования
  * @param p_prod_line_id ид линии продукта
  * @param err_msg сообщение о причине несовместимости
  * @return 1 - можно привязать покрытие, 0 - нельзя привязать покрытие
  */
  FUNCTION check_dependencies_by_clause
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER IS
    v_issuer_id        NUMBER;
    v_pl_brief         VARCHAR2(100);
    v_product_brief    VARCHAR2(100);
    v_asset_contact_id NUMBER;
  BEGIN
    SELECT NVL(brief, '?') INTO v_pl_brief FROM T_PRODUCT_LINE WHERE ID = p_prod_line_id;
    SELECT NVL(p.brief, '?')
      INTO v_product_brief
      FROM T_PRODUCT_LINE    pl
          ,T_PRODUCT         p
          ,T_PRODUCT_VERSION pv
          ,T_PRODUCT_VER_LOB pvl
     WHERE pl.ID = p_prod_line_id
       AND pl.PRODUCT_VER_LOB_ID = pvl.T_PRODUCT_VER_LOB_ID
       AND p.product_id = pv.product_id
       AND pv.T_PRODUCT_VERSION_ID = pvl.PRODUCT_VERSION_ID;
    IF v_product_brief = 'END'
       AND v_pl_brief IN ('ЗащСтрахВзнос', 'ОсвобУплВзнос')
    THEN
      BEGIN
        SELECT pi.contact_id
          INTO v_issuer_id
          FROM v_pol_issuer   pi
              ,ven_as_assured a
         WHERE a.P_POLICY_ID = pi.POLICY_ID
           AND a.AS_ASSURED_ID = p_asset_id
           AND a.ASSURED_CONTACT_ID = pi.contact_id;
        IF v_pl_brief = 'ЗащСтрахВзнос'
        THEN
          err_msg := 'Невозможно включить программу "Защита страховых взносов", т.к. страхователь совпадает с застрахованным';
          RETURN 0;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Страхователь не совпадает с застрахованным-> Освобождение от уплаты взносов недоступна
          IF v_pl_brief = 'ОсвобУплВзнос'
          THEN
            err_msg := 'Невозможно включить программу "Освобождение от уплаты взносов", т.к. страхователь не совпадает с застрахованным';
            RETURN 0;
          END IF;
      END;
    END IF;
    RETURN 1;
  END;
  /**
  * Проверить возможность одновременного страхования видов покрытий для указанного объекта страхования
  * @author Denis Ivanov
  * @param p_asset_id ид объекта страхования
  * @param p_prod_line_id ид линии продукта
  * @param err_msg сообщение о причине несовместимости
  * @return 1 - можно привязать покрытие, 0 - нельзя привязать покрытие
  */
  FUNCTION check_dependences
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER IS
    v_desc_concurrent_pl VARCHAR2(4000);
    v_ret_val            NUMBER(1);
  BEGIN
    v_ret_val := check_dependencies_by_clause(p_asset_id, p_prod_line_id, err_msg);
    IF v_ret_val = 0
    THEN
      RETURN v_ret_val;
    END IF;
    -- проверяем наличие конкурирующих видов покрытий
    BEGIN
      SELECT t.description
        INTO v_desc_concurrent_pl
        FROM (SELECT pl.ID
                    ,pl.description
                FROM P_COVER pc
                    ,T_PROD_LINE_OPTION plo
                    ,T_PRODUCT_LINE pl
                    ,(SELECT cpl.t_concur_product_line_id concurrent_prod_line_id
                        FROM CONCURRENT_PROD_LINE cpl
                       WHERE cpl.t_product_line_id = p_prod_line_id
                      UNION
                      SELECT cpl.t_product_line_id concurrent_prod_line_id
                        FROM CONCURRENT_PROD_LINE cpl
                       WHERE cpl.t_concur_product_line_id = p_prod_line_id) t
               WHERE pc.as_asset_id = p_asset_id
                 AND pc.t_prod_line_option_id = plo.ID
                 AND plo.product_line_id = pl.ID
                 AND t.concurrent_prod_line_id = pl.ID
                 AND pc.status_hist_id <> status_hist_id_del) t
       WHERE ROWNUM = 1;
      v_ret_val := 0;
      err_msg   := 'Данный вид покрытия не может быть применен одновременно с ' ||
                   v_desc_concurrent_pl;
      RETURN v_ret_val;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    -- проверяем включены ли все родительские покрытия
    BEGIN
      SELECT tt.description
        INTO v_desc_concurrent_pl
        FROM T_PRODUCT_LINE tt
            ,(SELECT ppl.t_parent_prod_line_id parent_prod_line_id
                FROM PARENT_PROD_LINE ppl
               WHERE ppl.t_prod_line_id = p_prod_line_id
              MINUS
              SELECT pl.ID
                FROM P_COVER            pc
                    ,T_PROD_LINE_OPTION plo
                    ,T_PRODUCT_LINE     pl
               WHERE pc.as_asset_id = p_asset_id
                 AND pc.t_prod_line_option_id = plo.ID
                 AND plo.product_line_id = pl.ID
                 AND pc.status_hist_id <> status_hist_id_del
              MINUS
              SELECT *
                FROM (SELECT cpl.t_concur_product_line_id concurrent_prod_line_id
                        FROM CONCURRENT_PROD_LINE cpl
                       WHERE cpl.t_product_line_id IN
                             (SELECT pl_.ID
                                FROM P_COVER            pc
                                    ,T_PROD_LINE_OPTION plo
                                    ,T_PRODUCT_LINE     pl_
                               WHERE pc.as_asset_id = p_asset_id
                                 AND pc.t_prod_line_option_id = plo.ID
                                 AND plo.product_line_id = pl_.ID
                                 AND pc.status_hist_id <> status_hist_id_del)
                      UNION
                      SELECT cpl.t_product_line_id concurrent_prod_line_id
                        FROM CONCURRENT_PROD_LINE cpl
                       WHERE cpl.t_concur_product_line_id IN
                             (SELECT pl_.ID
                                FROM P_COVER            pc
                                    ,T_PROD_LINE_OPTION plo
                                    ,T_PRODUCT_LINE     pl_
                               WHERE pc.as_asset_id = p_asset_id
                                 AND pc.t_prod_line_option_id = plo.ID
                                 AND plo.product_line_id = pl_.ID
                                 AND pc.status_hist_id <> status_hist_id_del))) ttt
       WHERE ROWNUM = 1
         AND ttt.parent_prod_line_id = tt.ID;
      v_ret_val := 0;
      err_msg   := 'Данный вид покрытия может быть применен только одновременно с ' ||
                   v_desc_concurrent_pl;
      RETURN v_ret_val;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN v_ret_val;
    END;
  END;

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_age        NUMBER
  ) IS
    v_end_date     DATE;
    v_asset_id     NUMBER;
    v_pol_id       NUMBER;
    v_pol_end_date DATE;
    v_one_sec      NUMBER := 1 / 24 / 3600;
  BEGIN
    UPDATE P_COVER SET accum_period_end_age = p_age WHERE p_cover_id = p_p_cover_id;
    -- Сроки не пересчитывать если период полиса указан явно
  
    FOR v_pol_period IN (SELECT pc.p_cover_id
                           FROM P_COVER pc
                          WHERE 1 = 1
                            AND pc.p_cover_id = p_p_cover_id
                            AND (accum_period_end_age IS NULL OR pc.IS_AVTOPROLONGATION = 1))
    LOOP
    
      LOG(p_p_cover_id
         ,'SET_COVER_ACCUM_PERIOD_END_AGE ACCUM_PERIOD_END_AGE IS NULL OR IS_AVTOPROLONGATION = 1 ');
      RETURN;
    END LOOP;
  
    -- Корректируется дата окончания покрытия
    UPDATE P_COVER
       SET end_date = ADD_MONTHS(start_date, 12 * (p_age - insured_age)) - v_one_sec
     WHERE p_cover_id = p_p_cover_id
       AND insured_age < p_age
    RETURNING end_date INTO v_end_date;
  
    IF SQL%ROWCOUNT = 0
    THEN
      --raise_application_error(-20100, 'Страховой возраст должен быть меньше возраста окончания накопительного периода');
      LOG(p_p_cover_id
         ,'Страховой возраст должен быть меньше возраста окончания накопительного периода');
      RETURN;
    END IF;
  
    LOG(p_p_cover_id
       ,'SET_COVER_ACCUM_PERIOD_END_AGE END_DATE ' || TO_CHAR(v_end_date, 'dd.mm.yyyy hh24:mi:ss'));
  
    SELECT as_asset_id INTO v_asset_id FROM P_COVER WHERE p_cover_id = p_p_cover_id;
    SELECT MAX(pc.end_date) INTO v_end_date FROM P_COVER pc WHERE pc.as_asset_id = v_asset_id;
    -- Корректируется дата окончания объекта
    UPDATE AS_ASSET SET end_date = v_end_date WHERE as_asset_id = v_asset_id;
    SELECT p_policy_id INTO v_pol_id FROM AS_ASSET WHERE as_asset_id = v_asset_id;
  
    SELECT MAX(pc.end_date)
      INTO v_pol_end_date
      FROM P_COVER  pc
          ,AS_ASSET a
     WHERE a.P_POLICY_ID = v_pol_id
       AND pc.AS_ASSET_ID = a.AS_ASSET_ID;
  
    LOG(p_p_cover_id
       ,'SET_COVER_ACCUM_PERIOD_END_AGE UPDATE POLICY END_DATE ' ||
        TO_CHAR(v_pol_end_date, 'dd.mm.yyyy hh24:mi:ss'));
  
    UPDATE P_POLICY
       SET end_date         = v_pol_end_date
          ,fee_payment_term = LEAST(fee_payment_term
                                   ,TRUNC(MONTHS_BETWEEN(v_end_date, start_date) / 12) + 1)
     WHERE policy_id = v_pol_id;
  
  END;

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_period_id  IN NUMBER
   ,p_age        NUMBER
  ) IS
    v_end_date     DATE;
    v_asset_id     NUMBER;
    v_pol_id       NUMBER;
    v_pol_end_date DATE;
  BEGIN
  
    IF p_period_id IS NULL
    THEN
      set_cover_accum_period_end_age(p_p_cover_id, p_period_id, p_age);
    ELSE
      UPDATE P_COVER SET period_id = p_period_id WHERE p_cover_id = p_p_cover_id;
      set_cover_accum_period_end_age(p_p_cover_id, p_age);
    END IF;
  
  END;

  /**
  * Округлить значение брутто взноса по правилам для покрытия
  * @author Marchuk A
  * @param p_p_cover_id ид покрытия
  * @param p_value неокругленное значение
  * @returm округленное значение
  */

  FUNCTION round_fee
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER IS
    RESULT           NUMBER;
    v_round_rules_id NUMBER;
  BEGIN
  
    SELECT pl.fee_round_rules_id
      INTO v_round_rules_id
      FROM T_PRODUCT_LINE     pl
          ,T_PROD_LINE_OPTION plo
          ,P_COVER            pc
     WHERE pl.ID = plo.product_line_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_round_rules_id IS NOT NULL
    THEN
      RESULT := INS.Pkg_Round_Rules.calculate(v_round_rules_id
                                             ,p_value
                                             ,Ent.id_by_brief('P_COVER')
                                             ,p_p_cover_id);
    ELSE
      RESULT := p_value;
    END IF;
    RETURN RESULT;
  END;
  /**
  * Округлить значение брутто взноса по правилам для покрытия
  * @author Marchuk A
  * @param p_p_cover_id ид покрытия
  * @param p_value неокругленное значение
  * @returm округленное значение
  */

  FUNCTION round_ins_amount
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER IS
    RESULT           NUMBER;
    v_round_rules_id NUMBER;
  BEGIN
  
    SELECT pl.ins_amount_round_rules_id
      INTO v_round_rules_id
      FROM T_PRODUCT_LINE     pl
          ,T_PROD_LINE_OPTION plo
          ,P_COVER            pc
     WHERE pl.ID = plo.product_line_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_round_rules_id IS NOT NULL
    THEN
      RESULT := INS.Pkg_Round_Rules.calculate(v_round_rules_id
                                             ,p_value
                                             ,Ent.id_by_brief('P_COVER')
                                             ,p_p_cover_id);
    ELSE
      RESULT := p_value;
    END IF;
    RETURN RESULT;
  END;

  FUNCTION get_cover_tariff
  (
    p_asset_id        NUMBER
   ,p_prod_line_brief VARCHAR2
  ) RETURN NUMBER IS
    v_val NUMBER;
  BEGIN
    SELECT SUM(pc.tariff)
      INTO v_val
      FROM ven_p_cover pc
      JOIN ven_t_prod_line_option plo
        ON plo.ID = pc.T_PROD_LINE_OPTION_ID
       AND plo.brief = p_prod_line_brief
      JOIN status_hist sh
        ON sh.STATUS_HIST_ID = pc.STATUS_HIST_ID
       AND sh.BRIEF NOT IN ('DELETED')
     WHERE pc.AS_ASSET_ID = p_asset_id;
  
    RETURN v_val;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

  FUNCTION calc_amount_imusch_ipoteka(p_par_policy_id NUMBER) RETURN NUMBER IS
    ret_sum NUMBER;
  BEGIN
    SELECT SUM(pc.INS_AMOUNT)
      INTO ret_sum
      FROM ven_as_property ap
      JOIN ven_p_cover pc
        ON pc.AS_ASSET_ID = as_property_id
      JOIN ven_t_prod_line_option plo
        ON plo.ID = pc.T_PROD_LINE_OPTION_ID
       AND plo.DESCRIPTION IN ('ФР Комплексное ипотечное страхование'
                              ,'ИМФЛ Комплексное ипотечное страхование')
      JOIN status_hist sh
        ON sh.STATUS_HIST_ID = pc.STATUS_HIST_ID
       AND sh.BRIEF NOT IN ('DELETED')
     WHERE ap.P_POLICY_ID = p_par_policy_id;
    RETURN ret_sum;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

  FUNCTION get_cover
  (
    p_p_cover_id NUMBER
   ,p_date       DATE
  ) RETURN NUMBER IS
    v_cover_id NUMBER;
  BEGIN
    -- Выбираю покрытие на дату с такой же программой и объектом страхования
    SELECT p_cover_id
      INTO v_cover_id
      FROM (SELECT pc.p_cover_id
              FROM p_cover  pc
                  ,as_asset a
                  ,p_policy p
                  ,p_cover  pc1
                  ,as_asset a1
             WHERE pc.END_DATE >= p_date
               AND pc.AS_ASSET_ID = a.AS_ASSET_ID
               AND pc.START_DATE <= p_date
               AND pc.STATUS_HIST_ID <> status_hist_id_del
               AND p.START_DATE <= p_date
               AND p.POLICY_ID = a.p_policy_id
               AND pc.T_PROD_LINE_OPTION_ID = pc1.T_PROD_LINE_OPTION_ID
               AND a.P_ASSET_HEADER_ID = a1.P_ASSET_HEADER_ID
               AND a1.AS_ASSET_ID = pc1.AS_ASSET_ID
               AND pc1.p_cover_id = p_p_cover_id
             ORDER BY p.START_DATE  DESC
                     ,p.version_num DESC)
     WHERE ROWNUM < 2;
    RETURN v_cover_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  -- Параметр - покрытие ДЕЙСТВУЮЩЕЙ версии
  FUNCTION calc_cover_nonlife_return_sum(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_cover         P_COVER%ROWTYPE; -- Покрытие расторгаемой версии
    plo             T_PROD_LINE_OPTION%ROWTYPE;
    v_amount        Pkg_Payment.t_amount;
    dni_ost         NUMBER;
    dni_all         NUMBER;
    v_policy_decl   P_POLICY%ROWTYPE;
    v_policy        P_POLICY%ROWTYPE; -- Действующая версия полиса
    v_prev_cover    P_COVER%ROWTYPE; -- Действующая версия покрытия
    v_charge_amount NUMBER;
    v_pay_amount    NUMBER;
    po_pay_sum      NUMBER;
    po_payoff_sum   NUMBER;
    po_charge_sum   NUMBER;
    po_com_sum      NUMBER;
    po_zsp_sum      NUMBER;
    po_decline_sum  NUMBER;
    v_decline_date  DATE;
    v_prorate       NUMBER;
  BEGIN
  
    SELECT c.* INTO v_prev_cover FROM P_COVER c WHERE c.p_cover_id = p_p_cover_id;
  
    SELECT *
      INTO v_policy
      FROM p_policy
     WHERE policy_id IN (SELECT p.policy_id
                           FROM p_policy p
                               ,as_asset a
                          WHERE p.POLICY_ID = a.P_POLICY_ID
                            AND a.AS_ASSET_ID = v_prev_cover.as_asset_id
                          GROUP BY p.POLICY_ID);
  
    SELECT *
      INTO v_cover
      FROM p_cover
     WHERE p_cover_id IN
           (SELECT MAX(pc.P_COVER_ID)
              FROM p_cover  pc
                  ,as_asset a
                  ,as_asset a1
             WHERE (pc.T_PROD_LINE_OPTION_ID = v_prev_cover.t_prod_line_option_id AND
                   a.P_ASSET_HEADER_ID = a1.P_ASSET_HEADER_ID AND
                   a1.AS_ASSET_ID = v_prev_cover.as_asset_id AND pc.as_asset_id = a.as_asset_id));
    SELECT *
      INTO v_policy_decl
      FROM p_policy
     WHERE policy_id IN (SELECT p.policy_id
                           FROM p_policy p
                               ,as_asset a
                          WHERE p.POLICY_ID = a.P_POLICY_ID
                            AND a.AS_ASSET_ID = v_cover.as_asset_id
                          GROUP BY p.POLICY_ID);
  
    SELECT NVL(v_policy_decl.decline_date, v_cover.decline_date) INTO v_decline_date FROM dual;
  
    SELECT p.* INTO plo FROM T_PROD_LINE_OPTION p WHERE p.ID = v_cover.t_prod_line_option_id;
  
    v_prorate := TRUNC(MONTHS_BETWEEN(v_decline_date + 1, v_prev_cover.start_date)) /
                 TRUNC(MONTHS_BETWEEN(v_prev_cover.end_date + 1, v_prev_cover.start_date));
    -- расчет оплаченной суммы
    v_amount     := Pkg_Payment.get_pay_cover_amount(p_p_cover_id);
    v_pay_amount := v_amount.fund_amount;
    --v_charge_amount:= Pkg_Payment.get_charge_cover_amount(p_p_cover_id).fund_amount;
    v_charge_amount := Pkg_Payment.get_charge_cover_amount(p_p_cover_id,'PROLONG').fund_amount;
    po_pay_sum      := v_amount.fund_amount;
  
    -- расчет выплаченной суммы
    IF pkg_app_param.get_app_param_n('CLIENTID') = 10
    THEN
      BEGIN
        SELECT NVL(SUM(cc.payment_sum), 0)
          INTO po_payoff_sum
          FROM c_claim_header ch
              ,c_claim        cc
              ,c_claim_status cs
         WHERE ch.p_cover_id = v_prev_cover.p_cover_id
           AND cc.c_claim_header_id = ch.c_claim_header_id
           AND cc.seqno =
               (SELECT MAX(cl.seqno) FROM c_claim cl WHERE cl.c_claim_header_id = ch.c_claim_header_id)
           AND cs.c_claim_status_id = cc.claim_status_id
           AND cs.brief LIKE 'ЗАКРЫТО'
           AND cc.claim_status_date <= v_cover.decline_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          po_payoff_sum := 0;
      END;
    ELSE
      po_payoff_sum := 0;
    END IF;
  
    -- расчет расходов на ведение дела
    --SELECT ROUND(NVL(ig.operation_cost, 0) * v_prev_cover.premium, 2)
    --  INTO po_charge_sum
    --  FROM T_INSURANCE_GROUP ig, T_PROD_LINE_OPTION plo, T_PRODUCT_LINE pl
    -- WHERE plo.id = v_cover.t_prod_line_option_id
    --   AND plo.product_line_id = pl.id
    --   AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- РВД=РВД%*(оплачено-премия_за_весь_период*prorate)
  
    SELECT ROUND(NVL(v_prev_cover.add_exp_proc / 100, NVL(ig.operation_cost, 0)) *
                 (v_pay_amount - v_charge_amount * v_prorate)
                ,2)
      INTO po_charge_sum
      FROM T_INSURANCE_GROUP  ig
          ,T_PROD_LINE_OPTION plo
          ,T_PRODUCT_LINE     pl
     WHERE plo.ID = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.ID
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- расчет суммы коммиссии агента
    -- todo предусмотреть, что ставка может быть задана абсолютным значением
  
    --SELECT NVL(ROUND(SUM(pac.val_com) * v_prev_cover.premium / 100, 2), 0)
    --  INTO po_com_sum
    --  FROM P_COVER_AGENT ca, p_policy_agent_com pac
    -- WHERE ca.cover_id = p_p_cover_id and pac.p_policy_agent_com_id = ca.p_policy_agent_com_id;
  
    SELECT NVL(ROUND(SUM(pac.val_com) * v_charge_amount / 100, 2), 0)
      INTO po_com_sum
      FROM P_COVER_AGENT      ca
          ,p_policy_agent_com pac
     WHERE ca.cover_id = p_p_cover_id
       AND pac.p_policy_agent_com_id = ca.p_policy_agent_com_id;
  
    -- расчет ЗСП (прората)
    -- todo сделать возможность выбора алгоритма расчета ЗСП и суммы возврата
    IF (v_cover.start_date < v_decline_date AND v_cover.end_date > v_decline_date)
    THEN
      -- для ОСАГО
    
      IF (plo.description = 'ОСАГО')
      THEN
        -- ОСАГО
        SELECT SUM(d.dni_ost)
              ,SUM(d.dni_all)
          INTO dni_ost
              ,dni_all
          FROM (SELECT --p.as_asset_id,
                 CASE
                   WHEN p.end_date < v_decline_date THEN
                    0
                   WHEN p.end_date >= v_decline_date
                        AND p.start_date <= v_decline_date THEN
                    (TRUNC(p.end_date) - TRUNC(v_decline_date))
                   WHEN p.start_date > v_decline_date THEN
                    (TRUNC(p.end_date) - TRUNC(p.start_date))
                 END dni_ost
                ,(TRUNC(p.end_date) - TRUNC(p.start_date) + 1) dni_all
                  FROM AS_ASSET_PER p
                 WHERE p.as_asset_id = v_cover.as_asset_id) d;
        --  po_zsp_sum := ROUND((v_prev_cover.premium - po_charge_sum) * (dni_all - dni_ost)/dni_all,2);
      
        po_zsp_sum := ROUND((v_charge_amount - po_charge_sum) * (dni_all - dni_ost) / dni_all, 2);
        -- для Автокаско
      ELSIF (plo.description = 'Автокаско' OR plo.description = 'Ущерб' OR
            plo.description = 'Несчастные случаи' OR plo.description = 'Гражданская ответственность' OR
            plo.description = 'Дополнительное оборудование' OR plo.description = 'Техническая помощь')
      THEN
        -- po_zsp_sum := ROUND(v_prev_cover.premium *
        --                     CEIL(MONTHS_BETWEEN( v_decline_date+1,v_cover.start_date))
        --                      /MONTHS_BETWEEN((v_cover.end_date+1),v_cover.start_date),
        --                     2);
      
        po_zsp_sum := ROUND(v_charge_amount * v_prorate, 2);
      
      ELSE
        -- po_zsp_sum := ROUND(v_prev_cover.premium*
        --                     ( v_decline_date - v_cover.start_date) /
        --                     (v_cover.end_date - v_cover.start_date),
        --                     2);
        po_zsp_sum := ROUND(v_charge_amount * (v_decline_date - v_cover.start_date) /
                            (v_cover.end_date - v_cover.start_date)
                           ,2);
      
      END IF;
    ELSIF v_cover.start_date > v_decline_date
    THEN
      po_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decline_date
    THEN
      --po_zsp_sum := v_prev_cover.premium;
      po_zsp_sum := v_charge_amount;
    END IF;
  
    -- расчет суммы возврата
    po_decline_sum := po_pay_sum - po_zsp_sum - po_payoff_sum;
  
    IF NVL(v_policy_decl.is_charge, NVL(v_cover.is_decline_charge, 0)) = 1
    THEN
      po_decline_sum := po_decline_sum - po_charge_sum;
      --po_zsp_sum := po_zsp_sum + po_charge_sum;
    END IF;
  
    IF NVL(v_policy_decl.is_comission, NVL(v_cover.is_decline_comission, 0)) = 1
    THEN
      po_decline_sum := po_decline_sum - po_com_sum;
      --po_zsp_sum := po_zsp_sum + po_com_sum;
    END IF;
  
    IF NVL(v_policy_decl.is_decline_payoff, NVL(v_cover.is_decline_payoff, 0)) = 1
    THEN
      po_decline_sum := po_decline_sum * (1 - po_payoff_sum / v_cover.ins_amount);
      --po_zsp_sum := po_zsp_sum + po_com_sum;
    END IF;
    IF po_decline_sum < 0
    THEN
      po_decline_sum := 0;
    END IF;
  
    IF po_zsp_sum > v_prev_cover.premium
    THEN
      po_zsp_sum := v_prev_cover.premium;
    END IF;
  
    UPDATE ven_p_cover pc
       SET pc.decline_summ = po_decline_sum
          ,pc.return_summ  = po_decline_sum
          ,pc.old_premium  = pc.premium + v_pay_amount - v_charge_amount
          ,pc.premium      = po_zsp_sum
          ,
           --  pc.IS_HANDCHANGE_DECLINE=1,
           --  pc.IS_HANDCHANGE_AMOUNT=1,
           --  pc.IS_HANDCHANGE_DEDUCT=1,
           --  pc.IS_HANDCHANGE_PREMIUM=1,
           --  pc.IS_HANDCHANGE_TARIFF=1,
           pc.ADD_EXP_SUM = po_charge_sum
          ,pc.AG_COMM_SUM = po_com_sum
          ,pc.PAYOFF_SUM  = po_payoff_sum
     WHERE pc.p_cover_id = v_cover.p_cover_id;
    RETURN po_decline_sum;
  END;

BEGIN
  SELECT sh.status_hist_id INTO status_hist_id_new FROM ven_status_hist sh WHERE sh.brief = 'NEW';
  SELECT sh.status_hist_id
    INTO status_hist_id_curr
    FROM ven_status_hist sh
   WHERE sh.brief = 'CURRENT';
  SELECT sh.status_hist_id INTO status_hist_id_del FROM ven_status_hist sh WHERE sh.brief = 'DELETED';
END;
/
