CREATE OR REPLACE PACKAGE PKG_CLAIM_CONTROL IS

  -- Author  : Marchuk A.
  -- Created : 16.04.2008
  -- Purpose : Утилиты для контроля продукта в контексте бизнес процессов

  PROCEDURE claim_control(p_c_claim_id IN NUMBER);
END PKG_CLAIM_CONTROL;
/
CREATE OR REPLACE PACKAGE BODY PKG_CLAIM_CONTROL IS

  -- Author  : Marchuk A.
  -- Created : 16.04.2008
  -- Purpose : Утилиты для контроля претензии в контексте бизнес процессов

  /*
   * Проверка договора на соответствие правилам продукта
   * @author Marchuk A.
   * @param p_c_claim_id      ИД версии договора страхования
  */

  PROCEDURE claim_control(p_c_claim_id IN NUMBER) IS
    CURSOR c_control_func IS
    --
      SELECT DISTINCT control_func_id
                     ,ct.name
                     ,pc.comments
        FROM T_PROD_COEF_TYPE CT
            ,T_PROD_CLAIM_CONTROL pc
            ,(SELECT pl.id t_product_line_id
                FROM T_PRODUCT_LINE     pl
                    ,T_PROD_LINE_OPTION plo
                    ,P_COVER            pc
                    ,C_CLAIM_HEADER     ch
                    ,C_CLAIM            cc
               WHERE 1 = 1
                 AND cc.c_claim_id = p_c_claim_id
                 AND ch.c_claim_header_id = cc.c_claim_header_id
                 AND pc.p_cover_id = ch.p_cover_id
                 AND plo.id = pc.t_prod_line_option_id
                 AND pl.id = plo.product_line_id) claim
       WHERE 1 = 1
         AND pc.t_product_line_id = claim.t_product_line_id
         AND ct.t_prod_coef_type_id = pc.control_func_id
         AND pc.is_disabled = 0;
    --
    v_func_id   NUMBER;
    v_func_name VARCHAR2(2000);
    RESULT      NUMBER;
    v_msg       VARCHAR2(4000);
    control_qty NUMBER DEFAULT 0;
    /* Внимание ! Работа данной процедуры основано на предположении, что функции контроля возвращают 1 при корректном контроле
    и 0 при ошибочном*/
  BEGIN
    FOR cur IN c_control_func
    LOOP
      v_func_name := cur.name;
      BEGIN
        RESULT := Pkg_Tariff_Calc.calc_fun(cur.control_func_id
                                          ,Ent.id_by_brief('C_CLAIM')
                                          ,p_c_claim_id);
        IF RESULT != 1
        THEN
          IF control_qty > 0
          THEN
            v_msg       := v_msg || CHR(10) || ' Замечание по функции контроля ' || '"' || cur.name || '"';
            control_qty := control_qty + 1;
          ELSE
            v_msg       := ' Замечание по функции контроля ' || '"' || cur.name || '"';
            control_qty := control_qty + 1;
          END IF;
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'При выполнении процедуры проверки "' || v_func_name ||
                                  '" произошла ошибка ');
      END;
    
    END LOOP;
  
    IF control_qty > 0
    THEN
      RAISE_APPLICATION_ERROR(-20000, v_msg);
    END IF;
  END;
  --
END PKG_CLAIM_CONTROL;
/
