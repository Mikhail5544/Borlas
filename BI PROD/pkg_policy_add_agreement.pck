CREATE OR REPLACE PACKAGE pkg_policy_add_agreement IS

  -- Author  : Marchuk A.
  -- Created : 05.09.2007
  -- Purpose : Утилиты для контроля продукта в контексте бизнес процессов

  PROCEDURE create_add(p_p_policy_id IN NUMBER);
END pkg_policy_add_agreement;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_add_agreement IS

  -- Author  : Marchuk A.
  -- Created : 05.09.2007
  -- Purpose : Утилиты для контроля продукта в контексте бизнес процессов

  /*
   * Проверка договора на соответствие правилам продукта
   * @author Marchuk A.
   * @param p_p_policy_id       ИД версии договора страхования
  */

  g_debug BOOLEAN DEFAULT TRUE;

  PROCEDURE log
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO p_policy_debug
        (p_policy_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_policy_id, SYSDATE, 'PKG_POLICY_ADD_AGREEMENT', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE create_add(p_p_policy_id IN NUMBER) IS
    message pkg_forms_message.t_message;
    CURSOR c_func IS
    
      SELECT paf.func_id
            ,ct.name
            ,paf.comments message
        FROM t_prod_coef_type    ct
            ,t_product_add_func  paf
            ,t_product_addendum  pa
            ,p_pol_addendum_type pat
            ,t_product           p
            ,p_policy            pp
            ,p_pol_header        ph
       WHERE 1 = 1
         AND pp.policy_id = p_p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND p.product_id = ph.product_id
         AND pat.p_policy_id = pp.policy_id
         AND pa.t_addendum_type_id = pat.t_addendum_type_id
         AND pa.t_product_id = p.product_id
         AND paf.t_product_id(+) = pa.t_product_id
         AND paf.t_product_addendum_id(+) = pa.t_product_addendum_id
         AND ct.t_prod_coef_type_id(+) = paf.func_id
       ORDER BY paf.sort_order;
  
    --
    v_func_id   NUMBER;
    RESULT      NUMBER;
    v_msg       VARCHAR2(4000);
    control_qty NUMBER DEFAULT 0;
    /* Внимание ! Работа данной процедуры основано на предположении, что функции контроля возвращают 1 при корректном контроле
    и 0 при ошибочном*/
    --
  BEGIN
    log(p_p_policy_id, 'CREATE_ADD');
  
    FOR cur IN c_func
    LOOP
      log(p_p_policy_id, 'CREATE_ADD Найдена функция ' || cur.name);
      RESULT := pkg_tariff_calc.calc_fun(cur.func_id, ent.id_by_brief('P_POLICY'), p_p_policy_id);
      log(p_p_policy_id
         ,'CREATE_ADD Результат выполнения (' || cur.name || ') ' || RESULT);
    
      IF RESULT != 1
      THEN
        IF control_qty > 0
        THEN
          IF cur.message IS NULL
          THEN
            v_msg := v_msg || chr(10) || ' Замечание по функции контроля ' || '"' || cur.name || '"';
          ELSE
            v_msg := v_msg || chr(10) || cur.message;
          END IF;
          control_qty := control_qty + 1;
        ELSE
          IF cur.message IS NULL
          THEN
            v_msg := ' Замечание по функции контроля ' || '"' || cur.name || '"';
          ELSE
            v_msg := v_msg || chr(10) || cur.message;
          END IF;
          control_qty := control_qty + 1;
        END IF;
      END IF;
    
      IF length(v_msg) > 2000
      THEN
        v_msg := substr(v_msg, 1, 2000);
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_policy_id, SQLERRM);
      RAISE;
    
  END;
  --
END pkg_policy_add_agreement;
/
