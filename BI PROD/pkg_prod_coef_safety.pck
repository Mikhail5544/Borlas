CREATE OR REPLACE PACKAGE PKG_PROD_COEF_SAFETY IS

  /**
  * Пакет для проверки прав на редактирование коэффициента тарифа на покрытии
  * @author Patsan O.
  */

  FUNCTION check_right_update(p_prod_line_coef_id IN NUMBER) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY PKG_PROD_COEF_SAFETY IS

  FUNCTION check_right_update(p_prod_line_coef_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.safety_right_id
                 FROM safety_right         sr
                     ,safety_right_role    srr
                     ,safety_right_type    srt
                     ,t_prod_line_coef_saf cs
                WHERE 1 = 1
                  AND cs.t_prod_line_coef_id = p_prod_line_coef_id
                  AND cs.is_update_allowed = 1
                  AND srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id(+) = srr.safety_right_id
                  AND sr.safety_right_id = cs.safety_right_id
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

END;
/
