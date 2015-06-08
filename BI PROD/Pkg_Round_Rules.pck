CREATE OR REPLACE PACKAGE pkg_round_rules IS
  /**
  * Правила округления
  * @author Marchuk A
  */
  /**
  * Округлить величину в соответствии с правилом
  * @author Marchuk A
  * @param p_round_rules_id  ИД правила
  * @param p_value значение величины
  */
  FUNCTION calculate
  (
    p_round_rules_id IN NUMBER
   ,p_value          IN NUMBER
   ,p_entity_id      IN NUMBER DEFAULT NULL
   ,p_obj_id         IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION calculate
  (
    p_round_rules_brief IN VARCHAR2
   ,p_value             IN NUMBER
   ,p_entity_id         IN NUMBER DEFAULT NULL
   ,p_obj_id            IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_round_rules_by_brief(par_brief VARCHAR2) RETURN t_round_rules.t_round_rules_id%TYPE;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_round_rules IS
  /**
  * Правила округления
  * @author Marchuk A
  */
  /**
  * Округлить величину в соответствии с правилом
  * @author Marchuk A
  * @param p_round_rules_id  ИД правила
  * @param p_value значение величины
  */

  g_debug BOOLEAN := FALSE;
  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  FUNCTION calculate
  (
    p_round_rules_brief IN VARCHAR2
   ,p_value             IN NUMBER
   ,p_entity_id         IN NUMBER DEFAULT NULL
   ,p_obj_id            IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_round_rules_id t_round_rules.t_round_rules_id%TYPE;
    v_rounded_value  NUMBER;
  BEGIN
  
    v_round_rules_id := get_round_rules_by_brief(par_brief => p_round_rules_brief);
  
    v_rounded_value := calculate(p_round_rules_id => v_round_rules_id
                                ,p_value          => p_value
                                ,p_entity_id      => p_entity_id
                                ,p_obj_id         => p_obj_id);
  
    RETURN v_rounded_value;
  
  END calculate;

  FUNCTION calculate
  (
    p_round_rules_id IN NUMBER
   ,p_value          IN NUMBER
   ,p_entity_id      IN NUMBER DEFAULT NULL
   ,p_obj_id         IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT        NUMBER;
    v_is_sql      NUMBER;
    v_sql_text    VARCHAR2(2000);
    v_brief       VARCHAR2(50);
    v_func_id     NUMBER(12);
    v_all_fee     NUMBER;
    v_temp_result NUMBER;
    v_round_rules t_round_rules%ROWTYPE;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'CALCULATE';
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'p_round_rules_id'
                          ,par_trace_var_value => p_round_rules_id);
    pkg_trace.add_variable(par_trace_var_name => 'p_value', par_trace_var_value => p_value);
    pkg_trace.add_variable(par_trace_var_name => 'p_entity_id', par_trace_var_value => p_entity_id);
    pkg_trace.add_variable(par_trace_var_name => 'p_obj_id', par_trace_var_value => p_obj_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => c_proc_name);
  
    v_round_rules := dml_t_round_rules.get_record(par_t_round_rules_id => p_round_rules_id);
  
    IF v_round_rules.is_sql IS NULL
    THEN
      raise_application_error(-20000, 'Правило округления не определено');
    END IF;
  
    IF v_round_rules.func_id IS NOT NULL
    THEN
      pkg_trace.add_variable('func_id', v_round_rules.func_id);
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => c_proc_name
                     ,par_message           => 'Определние брифы округления по функции');
    
      v_round_rules.brief := ROUND(pkg_tariff_calc.calc_fun(v_round_rules.func_id
                                                           ,p_entity_id
                                                           ,p_obj_id));
    END IF;
  
    pkg_trace.add_variable(par_trace_var_name => 'brief', par_trace_var_value => v_round_rules.brief);
    pkg_trace.add_variable(par_trace_var_name  => 'is_sql'
                          ,par_trace_var_value => v_round_rules.is_sql);
    pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                   ,par_trace_subobj_name => c_proc_name
                   ,par_message           => 'Применение округления');
  
    IF v_round_rules.is_sql = 0
    THEN
      CASE v_round_rules.brief
        WHEN 'LOW_OR_EQ' THEN
          RESULT := FLOOR(p_value);
        WHEN 'HIGH_OR_EQ' THEN
          RESULT := CEIL(p_value);
        WHEN 'WITHOUT_CHANGE' THEN
          RESULT := p_value;
        WHEN '1' THEN
          RESULT := FLOOR(p_value);
        WHEN '2' THEN
          RESULT := CEIL(p_value);
        WHEN 'ceil2' THEN
          RESULT := CEIL(p_value * 100) / 100;
        WHEN 'floor2' THEN
          RESULT := FLOOR(p_value * 100) / 100;
        WHEN 'round1' THEN
          RESULT := ROUND(p_value, 1);
        WHEN 'round2' THEN
          RESULT := ROUND(p_value, 2);
        WHEN '6' THEN
        
          SELECT (p_value + SUM(fee))
            INTO v_all_fee
            FROM p_cover
           WHERE as_asset_id = (SELECT b.as_asset_id FROM p_cover b WHERE p_cover_id = p_obj_id)
             AND p_cover_id != p_obj_id;
        
          v_temp_result := (500 * FLOOR(v_all_fee / 500)) - v_all_fee;
        
          IF v_temp_result BETWEEN - 2 AND 0
          THEN
          
            RESULT := FLOOR(p_value);
          
            IF RESULT = p_value
            THEN
              RESULT := RESULT - v_temp_result;
            END IF;
          
          ELSE
          
            RESULT := CEIL(p_value);
          END IF;
        
        WHEN '0' THEN
          RESULT := p_value;
        ELSE
          raise_application_error(-20000
                                 ,'Отсутствует правило округления');
      END CASE;
    ELSIF v_round_rules.is_sql = 1
    THEN
      EXECUTE IMMEDIATE 'Begin ' || v_round_rules.text || '; end;'
        USING IN p_value, OUT RESULT;
    ELSE
      raise_application_error(-20000, 'Отсутствует правило округления');
    END IF;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => c_proc_name
                                ,par_result_value      => RESULT);
  
    RETURN RESULT;
  END;

  FUNCTION get_round_rules_by_brief(par_brief VARCHAR2) RETURN t_round_rules.t_round_rules_id%TYPE IS
    v_round_rules_id t_round_rules.t_round_rules_id%TYPE;
  BEGIN
  
    RETURN dml_t_round_rules.get_id_by_brief(par_brief => par_brief, par_raise_on_error => TRUE);
  
  END get_round_rules_by_brief;

END;
/
