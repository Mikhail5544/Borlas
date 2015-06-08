CREATE OR REPLACE PACKAGE Pkg_Cover_11 IS
  /**
  * Расчет параметров покрытия Ренесанс
  * @author Marchuk A
  */

  /**
  * Рассчитать тариф по умолчанию по покрытию
  * @author Marchuk A
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_tariff(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать тариф по умолчанию по покрытию
  * @author Marchuk A
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитать данные покрытия Ренесанс Жизнь
  * @author Marchuk A
  * @param  p_cover_id ид покрытия
  * @return значение тарифа
  */
  PROCEDURE calc_Cover_11(p_p_policy_id IN NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Cover_11 IS

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
    --
    v_sql_parse        VARCHAR2(1000);
    v_func_define_type VARCHAR2(30);
    v_other            NUMBER;
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
       AND pl.id = plo.product_line_id
       AND plo.id = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_tariff_func IS NOT NULL
    THEN
      v_sql := v_tariff_func;
      c     := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(c, v_sql, dbms_sql.native);
      DBMS_SQL.BIND_VARIABLE(c, 'p_p_cover_id', p_p_cover_id);
      dbms_sql.bind_variable(c, 'p_tariff', v_tariff);
      i := DBMS_SQL.EXECUTE(c);
      dbms_sql.variable_value(c, 'p_tariff', v_tariff);
      DBMS_SQL.CLOSE_CURSOR(c);
    ELSIF v_func_id IS NOT NULL
    THEN
      -- тип определения фукнции (константа - пока не сделано, табличная фукнция, pl\sql или правило)
      -- пока тип фукнции определеем по заданным полям
      SELECT ct.r_sql
            ,ct.sub_t_prod_coef_type_id
            ,fdt.brief
        INTO v_sql
            ,v_other
            ,v_func_define_type
        FROM t_prod_coef_type ct
            ,func_define_type fdt
       WHERE ct.t_prod_coef_type_id = v_func_id
         AND ct.func_define_type_id = fdt.func_define_type_id;
    
      v_tariff := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER_11'), p_p_cover_id);
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
       AND pl.id = plo.product_line_id
       AND plo.id = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_func_id IS NOT NULL
    THEN
      v_tariff := Pkg_Tariff_Calc.calc_fun(v_func_id, Ent.id_by_brief('P_COVER_11'), p_p_cover_id);
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
  * Рассчитать покрытие Ренесанс Жизнь по умолчанию 
  * @author A.Marchuk
  * @param  p_cover_id ид покрытия
  * @return значение премии
  */

  PROCEDURE calc_Cover_11(p_p_policy_id IN NUMBER) IS
  
    TYPE resultset_1 IS TABLE OF p_cover_11.p_cover_11_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE resultset_2 IS TABLE OF p_cover_11.p%TYPE INDEX BY BINARY_INTEGER;
    TYPE resultset_3 IS TABLE OF p_cover_11.g%TYPE INDEX BY BINARY_INTEGER;
    TYPE resultset_4 IS TABLE OF p_cover_11.s_coef%TYPE INDEX BY BINARY_INTEGER;
    TYPE resultset_5 IS TABLE OF p_cover_11.k_coef%TYPE INDEX BY BINARY_INTEGER;
  
    r_resultset p_cover_11%ROWTYPE;
  
    result_i_1 resultset_1;
    result_i_2 resultset_2;
    result_i_3 resultset_3;
    result_i_4 resultset_4;
    result_i_5 resultset_5;
    l_idx      NUMBER DEFAULT 0;
  
    bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381);
  
  BEGIN
    FOR cur IN (SELECT pc.p_cover_id
                      ,pc.k_coef
                      ,pc.s_coef
                  FROM p_cover  pc
                      ,as_asset aa
                 WHERE aa.p_policy_id = p_p_policy_id
                   AND pc.as_asset_id = aa.as_asset_id)
    LOOP
      dbms_output.put_line('p_cover_id ' || cur.p_cover_id);
      dbms_output.put_line(' calc_tariff_netto (cur.p_cover_id) ' ||
                           calc_tariff_netto(cur.p_cover_id));
      l_idx := l_idx + 1;
      r_resultset.p_cover_11_id := cur.p_cover_id;
      r_resultset.p := calc_tariff_netto(cur.p_cover_id);
      r_resultset.g := calc_tariff(cur.p_cover_id);
      result_i_1(l_idx) := r_resultset.p_cover_11_id;
      result_i_2(l_idx) := r_resultset.p;
      result_i_3(l_idx) := r_resultset.g;
      result_i_4(l_idx) := least(0, cur.s_coef);
      result_i_5(l_idx) := least(0, cur.k_coef);
    
    END LOOP;
    BEGIN
      FORALL indx IN result_i_1.first .. result_i_1.last SAVE EXCEPTIONS
        INSERT INTO p_cover_11
          (p_cover_11_id, p, g, s_coef, k_coef)
        VALUES
          (result_i_1(indx), result_i_2(indx), result_i_3(indx), result_i_4(indx), result_i_5(indx));
    EXCEPTION
      WHEN bulk_errors THEN
        dbms_output.put_line('Обнаружено исключение... Производим апдейт ');
        FORALL indx IN result_i_1.first .. result_i_1.last
          UPDATE p_cover_11
             SET p      = result_i_2(indx)
                ,g      = result_i_3(indx)
                ,s_coef = result_i_4(indx)
                ,k_coef = result_i_5(indx)
           WHERE p_cover_11_id = result_i_1(indx);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20001
                             ,'Ошибка расчета покрытия по ренесанс' || SQLERRM);
  END;

END;
/
