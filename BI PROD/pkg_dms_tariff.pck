CREATE OR REPLACE PACKAGE pkg_dms_tariff IS

  -- Author  : ABALASHOV
  -- Created : 28.02.2007 12:04:28
  -- Purpose :

  FUNCTION calc_tariff_dms_age(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Расчитывает коэффициет приведения реальной суммы премии
  * @author Сыровецкий Д.
  * @param p_p_cover_id - ИД покрытия
  * @return коэффициет приведения реальной суммы премии
  */
  FUNCTION calc_real_premium_coef
  (
    p_p_cover_id IN NUMBER
   ,p_opt        IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Расчитывает ЗСП
  * @author Сыровецкий Д.
  * @param p_p_cover_id - ИД покрытия
  * @return ЗСП
  */
  FUNCTION calc_zsp_premium(p_p_cover_id IN NUMBER) RETURN NUMBER;

  PROCEDURE set_conext_for_real_premium
  (
    p_t_prod_line_dms_id NUMBER
   ,p_prod_premium       NUMBER
   ,p_prog_premium       NUMBER
   ,p_drm_prod_brief     VARCHAR2
   ,p_drm_prog_brief     VARCHAR2
   ,p_start_date         DATE
   ,p_end_date           DATE
  );

END pkg_dms_tariff;
/
CREATE OR REPLACE PACKAGE BODY pkg_dms_tariff IS

  v_p_cover p_cover%ROWTYPE;

  gl_t_prod_line_dms_id NUMBER;
  gl_prod_premium       NUMBER;
  gl_prog_premium       NUMBER;
  gl_drm_prod_brief     VARCHAR2(4000);
  gl_drm_prog_brief     VARCHAR2(4000);
  gl_start_date         DATE;
  gl_end_date           DATE;

  PROCEDURE set_conext_for_real_premium
  (
    p_t_prod_line_dms_id NUMBER
   ,p_prod_premium       NUMBER
   ,p_prog_premium       NUMBER
   ,p_drm_prod_brief     VARCHAR2
   ,p_drm_prog_brief     VARCHAR2
   ,p_start_date         DATE
   ,p_end_date           DATE
  ) IS
  BEGIN
    gl_t_prod_line_dms_id := p_t_prod_line_dms_id;
    gl_prod_premium       := p_prod_premium;
    gl_prog_premium       := p_prog_premium;
    gl_drm_prod_brief     := p_drm_prod_brief;
    gl_drm_prog_brief     := p_drm_prog_brief;
    gl_start_date         := p_start_date;
    gl_end_date           := p_end_date;
  END;

  -- регистрация коэффициента
  PROCEDURE reg_coeff
  (
    p_p_cover_id IN NUMBER
   ,p_brief      IN VARCHAR2
   ,p_val        IN NUMBER
   ,p_is_damage  IN NUMBER DEFAULT 0
  ) AS
    v_n NUMBER;
    v_m NUMBER;
  BEGIN
    SELECT tpct.t_prod_coef_type_id
          ,plc.t_prod_line_coef_id
      INTO v_n
          ,v_m
      FROM t_prod_coef_type   tpct
          ,p_cover            pc
          ,t_prod_line_option plo
          ,t_prod_line_coef   plc
     WHERE tpct.brief = p_brief
       AND pc.p_cover_id = p_p_cover_id
       AND pc.t_prod_line_option_id = plo.ID
       AND plc.t_product_line_id = plo.product_line_id
       AND plc.t_prod_coef_type_id = tpct.t_prod_coef_type_id;
    INSERT INTO ven_p_cover_coef
      (p_cover_id, t_prod_coef_type_id, val, t_prod_line_coef_id, is_damage)
    VALUES
      (p_p_cover_id, v_n, p_val, v_m, p_is_damage);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE ven_p_cover_coef
         SET val = p_val
       WHERE p_cover_id = p_p_cover_id
         AND t_prod_coef_type_id = v_n
         AND is_damage = p_is_damage;
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20100
                             ,'Для продукта не задан коэффициэнт тарифа: ' || p_brief);
    WHEN OTHERS THEN
      RAISE;
    
  END;

  FUNCTION calc_tariff_dms_age(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
    k_1      NUMBER;
    k_all    NUMBER;
  
    CURSOR cur_coef IS
      SELECT pct.brief
        FROM ven_p_cover            pc
            ,ven_t_prod_line_coef   plc
            ,ven_t_prod_line_option plo
            ,ven_t_prod_coef_type   pct
       WHERE pct.t_prod_coef_type_id = plc.t_prod_coef_type_id
         AND plc.t_product_line_id = plo.product_line_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pc.p_cover_id = p_p_cover_id;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    k_all := 1;
    k_1   := 1;
  
    FOR c_coef IN cur_coef
    LOOP
      k_1 := NVL(pkg_tariff_calc.calc_fun(c_coef.brief, v_p_cover.ent_id, p_p_cover_id), 1);
      reg_coeff(p_p_cover_id, c_coef.brief, k_1);
      k_all := k_all * k_1;
    END LOOP;
  
    k_all := k_all * calc_real_premium_coef(p_p_cover_id);
  
    v_result := k_all;
    RETURN v_result;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION calc_method_repay
  (
    cur_t_prod_line_dms_id NUMBER
   ,cur_prod_premium       NUMBER
   ,cur_prog_premium       NUMBER
   ,cur_drm_prod_brief     VARCHAR2
   ,cur_drm_prog_brief     VARCHAR2
   ,cur_start_date         DATE
   ,cur_end_date           DATE
   ,p_opt                  NUMBER
  ) RETURN NUMBER IS
  BEGIN
    NULL;
  END;

  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------

  FUNCTION calc_real_premium_coef
  (
    p_p_cover_id IN NUMBER
   ,p_opt        IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_coef      NUMBER;
    v_drm_brief VARCHAR2(100); --метод расчета
    v_rp_i      NUMBER; --реальная сумма за период
  
    v_count_day  NUMBER;
    v_min_day    NUMBER;
    v_start_date DATE;
    v_end_date   DATE;
    --v_tmp_year number;
    v_tmp_end_day DATE;
  
    v_sum            NUMBER;
    v_total_real_sum NUMBER;
    v_total_prog_sum NUMBER;
    v_total_prod_sum NUMBER;
  
    v_tmp_start_date DATE;
    v_tmp_end_date   DATE;
  
    v_year_day NUMBER := NULL;
  
    cur_t_prod_line_dms_id NUMBER;
    cur_prod_premium       NUMBER;
    cur_prog_premium       NUMBER;
    cur_drm_prod_brief     VARCHAR2(255);
    cur_drm_prog_brief     VARCHAR2(255);
    cur_start_date         DATE;
    cur_end_date           DATE;
  
    suffics VARCHAR2(20);
  
    CURSOR include IS
      SELECT pld.t_prod_line_dms_id t_prod_line_dms_id
            ,pld.ins_premium        prod_premium
            ,ppld.amount            prog_premium
            ,drm.brief              drm_prod_brief
            ,drm_c.brief            drm_prog_brief
            ,pc.start_date          start_date
            ,pc.end_date            end_date
        FROM p_cover                  pc
            ,t_prod_line_option       plo
            ,ven_t_prod_line_dms      pld
            ,dms_prog_type            pt
            ,ven_parent_prod_line_dms ppld
            ,dms_repay_method         drm
            ,ven_t_prod_line_dms      pld_c
            ,dms_repay_method         drm_c
       WHERE pc.p_cover_id = p_p_cover_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pld.t_prod_line_dms_id = plo.product_line_id
         AND pt.dms_prog_type_id = pld.dms_prog_type_id
         AND pt.brief = 'INSPR'
         AND ppld.t_parent_prod_line_id = pld.t_prod_line_dms_id
         AND drm.dms_repay_method_id(+) = ppld.dms_repay_method_id
         AND pld_c.t_prod_line_dms_id = ppld.t_prod_line_id
         AND drm_c.dms_repay_method_id(+) = pld_c.dms_repay_method_id;
  
    CURSOR exclude IS
      SELECT pld.t_prod_line_dms_id t_prod_line_dms_id
            ,pld.ins_premium prod_premium
            ,ppld.amount prog_premium
            ,drm.brief drm_prod_brief
            ,drm_c.brief drm_prog_brief
            ,pc.start_date start_date
            ,NVL(pc.DECLINE_DATE, SYSDATE) end_date -- дата расторжения
        FROM p_cover                  pc
            ,t_prod_line_option       plo
            ,ven_t_prod_line_dms      pld
            ,dms_prog_type            pt
            ,ven_parent_prod_line_dms ppld
            ,dms_repay_method         drm
            ,ven_t_prod_line_dms      pld_c
            ,dms_repay_method         drm_c
       WHERE pc.p_cover_id = p_p_cover_id
         AND plo.ID = pc.t_prod_line_option_id
         AND pld.t_prod_line_dms_id = plo.product_line_id
         AND pt.dms_prog_type_id = pld.dms_prog_type_id
         AND pt.brief = 'INSPR'
         AND ppld.t_parent_prod_line_id = pld.t_prod_line_dms_id
         AND drm.dms_repay_method_id(+) = ppld.DMS_RECALC_METHOD_ID
         AND pld_c.t_prod_line_dms_id = ppld.t_prod_line_id
         AND drm_c.dms_repay_method_id(+) = pld_c.DMS_RECALC_METHOD_ID;
  
    CURSOR include_acc IS
      SELECT gl_t_prod_line_dms_id t_prod_line_dms_id
            ,gl_prod_premium       prod_premium
            ,gl_prog_premium       prog_premium
            ,gl_drm_prod_brief     drm_prod_brief
            ,gl_drm_prog_brief     drm_prog_brief
            ,gl_start_date         start_date
            ,gl_end_date           end_date
        FROM dual;
  
  BEGIN
    v_coef           := 1;
    v_total_real_sum := 0;
    v_total_prog_sum := 0;
    v_total_prod_sum := 0;
  
    IF p_opt = 0
    THEN
      OPEN include;
      suffics := 'FOR_';
    ELSIF p_opt = 1
    THEN
      OPEN exclude;
      suffics := 'REP_';
    ELSIF p_opt = 2
    THEN
      OPEN include_acc;
      suffics := 'FOR_';
    END IF;
  
    LOOP
    
      IF p_opt = 0
      THEN
        FETCH include
          INTO cur_t_prod_line_dms_id
              ,cur_prod_premium
              ,cur_prog_premium
              ,cur_drm_prod_brief
              ,cur_drm_prog_brief
              ,cur_start_date
              ,cur_end_date;
        EXIT WHEN include%NOTFOUND;
      ELSIF p_opt = 1
      THEN
        FETCH exclude
          INTO cur_t_prod_line_dms_id
              ,cur_prod_premium
              ,cur_prog_premium
              ,cur_drm_prod_brief
              ,cur_drm_prog_brief
              ,cur_start_date
              ,cur_end_date;
        EXIT WHEN exclude%NOTFOUND;
      ELSIF p_opt = 2
      THEN
        FETCH include_acc
          INTO cur_t_prod_line_dms_id
              ,cur_prod_premium
              ,cur_prog_premium
              ,cur_drm_prod_brief
              ,cur_drm_prog_brief
              ,cur_start_date
              ,cur_end_date;
        EXIT WHEN include_acc%NOTFOUND;
      END IF;
    
      -- нужно узнать метод расчета премии
      IF cur_drm_prod_brief IS NOT NULL
      THEN
        --назначенный метод на продукте является приоритетным
        v_drm_brief := cur_drm_prod_brief;
      ELSE
        IF cur_drm_prog_brief IS NOT NULL
        THEN
          -- метод программы
          v_drm_brief := cur_drm_prog_brief;
        ELSE
          v_drm_brief := suffics || 'DAYS';
        END IF;
      END IF;
    
      v_start_date := TRUNC(cur_start_date);
      v_end_date   := TRUNC(cur_end_date);
      --v_tmp_year := to_char(v_start_date, 'yyyy');
      v_tmp_end_day := ADD_MONTHS(v_start_date, 12) - 1;
      v_year_day    := v_tmp_end_day - v_start_date + 1;
    
      CASE
        WHEN v_drm_brief = 'ALL' THEN
          v_sum := cur_prog_premium;
        
        WHEN v_drm_brief LIKE (suffics || 'DAYS%') THEN
          v_count_day := v_end_date - v_start_date + 1;
        
          CASE v_drm_brief
          
            WHEN suffics || 'DAYS_3' THEN
              v_min_day := 90;
            WHEN suffics || 'DAYS_4' THEN
              v_min_day := 120;
            WHEN suffics || 'DAYS_5' THEN
              v_min_day := 150;
            WHEN suffics || 'DAYS_6' THEN
              v_min_day := 180;
            ELSE
              v_min_day := 0;
          END CASE;
        
          v_sum := cur_prog_premium / v_year_day * GREATEST(v_count_day, v_min_day);
        
        WHEN v_drm_brief LIKE (suffics || 'HALFMON%') THEN
        
          IF TO_CHAR(v_start_date, 'dd') < 15
          THEN
            v_tmp_start_date := TO_DATE('01' || TO_CHAR(v_start_date, 'mmyyyy'), 'ddmmyyyy');
          ELSE
            v_tmp_start_date := TO_DATE('15' || TO_CHAR(v_start_date, 'mmyyyy'), 'ddmmyyyy');
          END IF;
        
          IF TO_CHAR(v_end_date, 'dd') < 15
          THEN
            v_tmp_end_date := TO_DATE('15' || TO_CHAR(v_end_date, 'mmyyyy'), 'ddmmyyyy');
          ELSE
            v_tmp_end_date := ADD_MONTHS(TO_DATE('01' || TO_CHAR(v_end_date, 'mmyyyy'), 'ddmmyyyy'), 1);
          END IF;
        
          v_count_day /*в данном контексте полумесяц*/
          := ROUND(MONTHS_BETWEEN(v_tmp_end_date, v_tmp_start_date), 1);
        
          v_count_day := v_count_day * 2; --т.к полумесяцы
        
          CASE v_drm_brief
            WHEN suffics || 'HALFMON_3' THEN
              v_min_day := 6;
            WHEN suffics || 'HALFMON_4' THEN
              v_min_day := 8;
            WHEN suffics || 'HALFMON_5' THEN
              v_min_day := 10;
            WHEN suffics || 'HALFMON_6' THEN
              v_min_day := 12;
            ELSE
              v_min_day := 0;
          END CASE;
        
          v_sum := cur_prog_premium / 24 * GREATEST(v_count_day, v_min_day);
        
        WHEN v_drm_brief = 'NOREPAY' THEN
          v_count_day := v_end_date - v_start_date;
          IF v_count_day > 0
          THEN
            v_sum := cur_prog_premium;
          ELSE
            v_sum := 0;
          END IF;
        
        WHEN v_drm_brief LIKE (suffics || 'MONTH%') THEN
          v_count_day /*в данном контексте месяц*/
          := MONTHS_BETWEEN(TO_DATE('01' || TO_CHAR(v_end_date, 'mmyyyy'), 'ddmmyyyy')
                           ,TO_DATE('01' || TO_CHAR(v_start_date, 'mmyyyy'), 'ddmmyyyy'));
        
          CASE v_drm_brief
            WHEN suffics || 'MONTH_3' THEN
              v_min_day := 3;
            WHEN suffics || 'MONTH_4' THEN
              v_min_day := 4;
            WHEN suffics || 'MONTH_5' THEN
              v_min_day := 5;
            WHEN suffics || 'MONTH_6' THEN
              v_min_day := 6;
            ELSE
              v_min_day := 0;
          END CASE;
        
          v_sum := cur_prog_premium / 12 * GREATEST(v_count_day, v_min_day);
        
        WHEN v_drm_brief LIKE (suffics || 'QUART') THEN
          --нужно даты привести к кварталам
          CASE
            WHEN TO_CHAR(v_start_date, 'mm') IN ('01', '02', '03') THEN
              v_start_date := TO_DATE('0101' || TO_CHAR(v_start_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_start_date, 'mm') IN ('04', '05', '06') THEN
              v_start_date := TO_DATE('0104' || TO_CHAR(v_start_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_start_date, 'mm') IN ('07', '08', '09') THEN
              v_start_date := TO_DATE('0107' || TO_CHAR(v_start_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_start_date, 'mm') IN ('10', '11', '12') THEN
              v_start_date := TO_DATE('0110' || TO_CHAR(v_start_date, 'yyyy'), 'ddmmyyyy');
          END CASE;
        
          CASE
            WHEN TO_CHAR(v_end_date, 'mm') IN ('01', '02', '03') THEN
              v_end_date := TO_DATE('0104' || TO_CHAR(v_end_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_end_date, 'mm') IN ('04', '05', '06') THEN
              v_end_date := TO_DATE('0107' || TO_CHAR(v_end_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_start_date, 'mm') IN ('07', '08', '09') THEN
              v_end_date := TO_DATE('0110' || TO_CHAR(v_end_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_end_date, 'mm') IN ('10', '11', '12') THEN
              v_end_date := TO_DATE('0101' || TO_CHAR(TO_NUMBER(TO_CHAR(v_end_date, 'yyyy')) + 1)
                                   ,'ddmmyyyy');
          END CASE;
        
          v_count_day /*в данном контексте месяц*/
          := MONTHS_BETWEEN(v_end_date, v_start_date) / 4;
        
          v_sum := cur_prog_premium / 4 * v_count_day;
        
        WHEN v_drm_brief LIKE (suffics || 'HALF_YEAR') THEN
          --нужно даты привести к кварталам
          CASE
            WHEN TO_CHAR(v_start_date, 'mm') IN ('01', '02', '03', '04', '05', '06') THEN
              v_start_date := TO_DATE('0101' || TO_CHAR(v_start_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_start_date, 'mm') IN ('07', '08', '09', '10', '11', '12') THEN
              v_start_date := TO_DATE('0107' || TO_CHAR(v_start_date, 'yyyy'), 'ddmmyyyy');
          END CASE;
        
          CASE
            WHEN TO_CHAR(v_end_date, 'mm') IN ('01', '02', '03', '04', '05', '06') THEN
              v_end_date := TO_DATE('0107' || TO_CHAR(v_end_date, 'yyyy'), 'ddmmyyyy');
            WHEN TO_CHAR(v_end_date, 'mm') IN ('07', '08', '09', '10', '11', '12') THEN
              v_end_date := TO_DATE('0101' || TO_CHAR(TO_NUMBER(TO_CHAR(v_end_date, 'yyyy')) + 1)
                                   ,'ddmmyyyy');
          END CASE;
        
          v_count_day /*в данном контексте полугодия*/
          := MONTHS_BETWEEN(v_end_date, v_start_date) / 2;
        
          v_sum := cur_prog_premium / 2 * v_count_day;
        
      END CASE;
      v_total_real_sum := v_total_real_sum + v_sum;
      v_total_prog_sum := v_total_prog_sum + cur_prog_premium;
      v_total_prod_sum := cur_prod_premium;
    END LOOP;
  
    IF p_opt = 0
    THEN
      CLOSE include;
    ELSIF p_opt = 1
    THEN
      CLOSE exclude;
    ELSIF p_opt = 2
    THEN
      CLOSE include_acc;
    END IF;
  
    IF v_total_prog_sum = 0
    THEN
      v_coef := 1;
    ELSE
      IF v_total_real_sum / v_total_prog_sum = 1
      THEN
        v_coef := 1;
      ELSE
        v_coef := (v_total_real_sum / v_total_prog_sum) * (v_total_prod_sum / v_total_prog_sum);
      END IF;
    END IF;
  
    IF p_opt > 1
    THEN
      RETURN v_total_real_sum;
    ELSE
      RETURN v_coef;
    END IF;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION calc_zsp_premium(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_cover     P_COVER%ROWTYPE;
    v_rvd_sum   NUMBER;
    v_zsp_sum   NUMBER;
    v_decl_date DATE;
  
  BEGIN
  
    SELECT pc.* INTO v_cover FROM P_COVER pc WHERE pc.p_cover_id = p_p_cover_id;
    v_decl_date := v_cover.decline_date;
    IF v_decl_date IS NULL
    THEN
      v_decl_date := SYSDATE;
    END IF;
  
    -- расчет "чистой" ЗСП
    v_zsp_sum := 0;
    IF (v_cover.start_date < v_decl_date AND v_cover.end_date > v_decl_date)
    THEN
      v_zsp_sum := ROUND(v_cover.premium * calc_real_premium_coef(p_p_cover_id, 1), 2);
    ELSIF v_cover.start_date > v_decl_date
    THEN
      v_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decl_date
    THEN
      v_zsp_sum := v_cover.premium;
    END IF;
  
    v_rvd_sum := 0;
  
    -- расчет расходов на ведение дела
    BEGIN
    
      SELECT coef
        INTO v_rvd_sum
        FROM (SELECT ROUND(NVL(dpi.max_rvd, 0) / 100 * (v_cover.premium - v_zsp_sum), 2) coef
                FROM VEN_DMS_POLICY_INFO dpi
                    ,p_policy            pp
                    ,p_policy            pp1
                    ,ven_as_asset        aa
                    ,p_cover             pc
               WHERE dpi.POLICY_ID = pp.POLICY_ID
                 AND pp1.POL_HEADER_ID = pp.POL_HEADER_ID
                 AND aa.P_POLICY_ID = pp1.policy_id
                 AND aa.AS_ASSET_ID = pc.AS_ASSET_ID
                 AND pc.p_cover_id = 10883
               ORDER BY pp.POLICY_ID DESC)
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    -- расчет ЗСП с учетом РВД в части незаработанной премии
    v_zsp_sum := v_zsp_sum + v_rvd_sum;
    RETURN v_zsp_sum;
  END;

END pkg_dms_tariff;
/
