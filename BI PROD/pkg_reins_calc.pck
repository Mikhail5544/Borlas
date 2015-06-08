CREATE OR REPLACE PACKAGE pkg_reins_calc IS
  /**
  * Ппакет для вычислений в перестраховании
  * @author Syrovetskiy D.
  *
  */

  /**
  * Рассчитывает перестраховочную премию по линии в покрытие в перестраховании
  * @author Сыровецкий Д.
  * @param p_re_line_cover_id - ИД рассчитанной линии по покрытию в перестраховании
  * @return значение премии по линии
  */
  FUNCTION calc_re_premium_line(p_re_line_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитывает перестраховочную премию по покрытию в перестраховании
  * @author Сыровецкий Д.
  * @param p_re_cover_id - ИД покрытия в перестраховании
  * @return значение премии по покрытию в перестраховании
  */
  FUNCTION calc_re_premium(p_re_cover_id NUMBER) RETURN NUMBER;

  /**
  * Рассчитывает перестраховочную премию по покрытию в перестраховании по счету
  * @author Сыровецкий Д.
  * @param p_re_cover_id - ИД покрытия в перестраховании
  * @param p_ac_payment_id - ИД платежного документа
  * @parem p_opl_sum - Оплаченная сумма
  * @return значение премии по покрытию в перестраховании
  */
  FUNCTION calc_rel_recover
  (
    p_rel_recover_id NUMBER
   ,p_ac_payment_id  NUMBER
   ,p_opl_sum        NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает сумму резервов по дате
  * @author Сыровецкий Д.
  * @param p_re_cover_id - ИД покрытия в перестраховании
  * @param p_date - дата для расчета резервов
  * @return значение резерва
  */
  FUNCTION get_reserve
  (
    p_re_cover_id NUMBER
   ,p_date        DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Возвращает значение коэффициента
  * @author Сыровецкий Д.
  * @param p_re_cover_id - ИД покрытия в перестраховании
  * @param p_type - тип возвращаемого коэффициента (S или K)
  * @return значение коэффициента
  */
  FUNCTION get_coef
  (
    p_re_cover_id NUMBER
   ,p_type        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает значение тарифа по линии
  * @author Сыровецкий Д.
  * @param p_re_cover_line_id - ИД линии в покрытии
  * @param p_rel_recover_bordero_id - ИД привязки бордеро и ре_ковера
  * @return значение тарифа
  */
  FUNCTION get_line_tarif
  (
    p_re_cover_line_id       NUMBER
   ,p_rel_recover_bordero_id NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает значение тарифа по линии
  * @author Сыровецкий Д.
  * @param p_p_cover_id - ИД покрытия
  * @param p_fund_id - ИД валюты
  * @return значение тарифа
  */
  FUNCTION get_sum_first
  (
    p_p_cover_id NUMBER
   ,p_fund_id    NUMBER
   ,p_date       DATE DEFAULT NULL
   ,p_type       NUMBER DEFAULT 0
   ,p_k          NUMBER DEFAULT 0
   ,p_s          NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Возвращает значение параметра при расчете тантьемы
  * @author Сыровецкий Д.
  * @param p_id - ИД счета тантьемы
  * @param p_param - Название параметра
  * @return значение тарифа
  */
  FUNCTION calc_tant
  (
    p_id    IN NUMBER
   ,p_param IN VARCHAR2
  ) RETURN NUMBER;

END; -- Package spec
/
CREATE OR REPLACE PACKAGE BODY pkg_reins_calc IS
  --------------------------------------------------------------------------------
  --вычисление перестраховочной премии
  --------------------------------------------------------------------------------

  g_debug BOOLEAN := TRUE;

  PROCEDURE LOG
  (
    p_object_id IN NUMBER
   ,p_message   IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO RE_BORDERO_DEBUG
        (object_id, execution_date, operation_type, debug_message)
      VALUES
        (p_object_id, SYSDATE, 'INS.PKG_REINS_CALC', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION calc_re_premium_line(p_re_line_cover_id NUMBER) RETURN NUMBER IS
    v_sum_ins   NUMBER; --страховая сумма по линии
    v_sum_selv  NUMBER; --собственное удержание
    v_sum_first NUMBER; --первоначальное страховое обеспечение
    v_Q         NUMBER; --доля перестраховщика
    v_BARt      NUMBER; --страховое обеспечение под риском по договору страхования
    v_RBARt     NUMBER; --перестрахованное страховое обеспечение под риском
  
    v_reserve_begin_null NUMBER; --резерв на нулевую годовщину
    v_reserve_begin      NUMBER; --резерв на начало страховой годовщины
  
    v_sum_self    NUMBER; --собственная доля
    v_re_tarif    NUMBER; --тариф в перестраховании
    v_func_id     NUMBER; --функция расчета коэффициента рассрочки
    v_ent_id      NUMBER;
    v_pcover_id   NUMBER;
    v_re_cover_id NUMBER;
  
    v_k         NUMBER;
    v_s         NUMBER;
    v_base_rate NUMBER; -- годовая базисная ставка
    v_k_ras     NUMBER; --коэффициент рассрочки
    v_ret_val   NUMBER := 0;
  BEGIN
  
    --получение начальных данных
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'P_COVER';
  
    SELECT rlc.re_tariff --тариф в линии
          ,rc.p_cover_id
          ,rc.re_cover_id
          ,rlc.retention_val + rlc.part_sum --сумма линии
          ,rlc.retention_val --собственная доля
          ,rcv.func_calc_id
      INTO v_re_tarif
          ,v_pcover_id
          ,v_re_cover_id
          ,v_sum_ins
          ,v_sum_self
          ,v_func_id
      FROM ven_re_line_cover       rlc
          ,ven_re_cover            rc
          ,ven_re_contract_version rcv
     WHERE rlc.re_line_cover_id = p_re_line_cover_id
       AND rc.re_cover_id = rlc.re_cover_id
       AND rcv.re_contract_version_id = rc.re_contract_ver_id;
  
    --вычисление резервов по покрытию
    v_reserve_begin_null := 0;
    v_reserve_begin      := 0;
  
    v_sum_first := v_sum_ins - v_reserve_begin_null;
    v_Q         := (v_sum_first - v_sum_self) / v_sum_first;
    v_BARt      := v_sum_ins - v_reserve_begin;
    v_RBARt     := v_Q * v_BARt;
  
    v_base_rate := v_RBARt * v_re_tarif;
  
    v_k := 0;
    v_s := 0;
  
    BEGIN
      v_k_ras := pkg_tariff_calc.calc_fun(v_func_id, v_ent_id, v_pcover_id);
      v_k_ras := NVL(v_k_ras, 1);
    EXCEPTION
      WHEN OTHERS THEN
        v_k_ras := 1;
    END;
  
    v_ret_val := v_k_ras * v_RBARt * (v_re_tarif * (1 + v_k / 100) + v_s);
  
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'RE_LINE_COVER';
  
    INSERT INTO ven_re_calculation
      (re_calculation_id
      ,ure_id
      ,uro_id
      ,FIRST_INS_GUARANTEE
      ,part_sum
      ,INS_GUARANTEE
      ,REINS_GUARANTEE
      ,BASE_RATE_REINS
      ,K_DOWN_PAYMENT
      ,RE_TARIFF
      ,RE_PREMIUM
      ,RESERVE_BEGIN
      ,RESERVE_BEGIN_NULL
      ,RE_COVER_ID)
    VALUES
      (sq_re_calculation.NEXTVAL
      ,v_ent_id
      ,p_re_line_cover_id
      ,v_sum_first
      ,v_Q
      ,v_BARt
      ,v_RBARt
      ,v_base_rate
      ,v_k_ras
      ,v_re_tarif
      ,v_ret_val
      ,v_reserve_begin
      ,v_reserve_begin_null
      ,v_re_cover_id);
  
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20003
                             ,SQLERRM || ' Ошибка расчета перестраховочной премии');
  END;
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  FUNCTION calc_re_premium(p_re_cover_id NUMBER) RETURN NUMBER IS
  
    v_reserve_begin_null NUMBER;
    v_reserve_begin      NUMBER;
    v_sum_first          NUMBER;
    v_Q                  NUMBER;
    v_BARt               NUMBER;
    v_RBARt              NUMBER;
    v_re_tarif           NUMBER;
    v_base_rate          NUMBER;
    v_re_premium         NUMBER;
    v_k_ras              NUMBER;
  
    v_ent_id NUMBER;
    v_count  NUMBER;
  BEGIN
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'RE_LINE_COVER';
  
    SELECT SUM(NVL(rc.reserve_begin_null, 0))
          ,SUM(NVL(rc.reserve_begin, 0))
          ,SUM(NVL(rc.FIRST_INS_GUARANTEE, 0))
          ,SUM(NVL(rc.INS_GUARANTEE, 0))
          ,SUM(NVL(rc.REINS_GUARANTEE, 0))
          ,SUM(NVL(rc.RE_TARIFF, 0))
          ,SUM(NVL(rc.BASE_RATE_REINS, 0))
          ,SUM(NVL(rc.RE_PREMIUM, 0))
      INTO v_reserve_begin_null
          ,v_reserve_begin
          ,v_sum_first
          ,v_BARt
          ,v_RBARt
          ,v_re_tarif
          ,v_base_rate
          ,v_re_premium
      FROM re_calculation rc
     WHERE rc.re_cover_id = p_re_cover_id
       AND ure_id = v_ent_id;
  
    v_Q := v_RBARt / v_BARt;
  
    SELECT COUNT(1)
      INTO v_count
      FROM re_calculation rc
     WHERE rc.re_cover_id = p_re_cover_id
       AND ure_id = v_ent_id;
    IF v_count > 1
    THEN
      v_re_tarif := v_base_rate / v_RBARt;
    END IF;
  
    SELECT K_DOWN_PAYMENT
      INTO v_k_ras
      FROM re_calculation rc
     WHERE rc.re_cover_id = p_re_cover_id
       AND ure_id = v_ent_id
       AND ROWNUM = 1;
  
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'RE_COVER';
  
    INSERT INTO ven_re_calculation
      (re_calculation_id
      ,ure_id
      ,uro_id
      ,FIRST_INS_GUARANTEE
      ,part_sum
      ,INS_GUARANTEE
      ,REINS_GUARANTEE
      ,BASE_RATE_REINS
      ,RE_TARIFF
      ,RE_PREMIUM
      ,RESERVE_BEGIN
      ,RESERVE_BEGIN_NULL
      ,K_DOWN_PAYMENT
      ,RE_COVER_ID)
    VALUES
      (sq_re_calculation.NEXTVAL
      ,v_ent_id
      ,p_re_cover_id
      ,v_sum_first
      ,v_Q
      ,v_BARt
      ,v_RBARt
      ,v_base_rate
      ,v_re_tarif
      ,v_re_premium
      ,v_reserve_begin
      ,v_reserve_begin_null
      ,v_k_ras
      ,p_re_cover_id);
  
    RETURN v_re_premium;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004
                             ,SQLERRM || ' Ошибка расчета перестраховочной премии');
  END;
  ---------------------------------------------------------------
  --Нужно пересчитать перестраховочную премию в зависимости от
  --резервов и периода
  ---------------------------------------------------------------

  FUNCTION calc_rel_recover
  (
    p_rel_recover_id NUMBER
   ,p_ac_payment_id  NUMBER
   ,p_opl_sum        NUMBER
  ) RETURN NUMBER IS
  
    v_date        DATE;
    v_re_cover_id NUMBER;
  
    v_reserve_begin_null NUMBER;
    v_reserve_begin      NUMBER;
    v_ins_sum            NUMBER;
  
    v_sum_first NUMBER;
    v_Q         NUMBER;
    v_BARt      NUMBER;
    v_RBARt     NUMBER;
    v_re_tarif  NUMBER;
    v_ent_id    NUMBER;
  
    v_base_rate NUMBER;
  
    v_k     NUMBER;
    v_s     NUMBER;
    v_k_ras NUMBER;
  
    v_re_premium NUMBER;
    v_commis     NUMBER;
  
    v_re_calculation_id NUMBER;
  
    vt_sum_first          NUMBER;
    vt_BARt               NUMBER;
    vt_RBARt              NUMBER;
    vt_base_rate          NUMBER;
    vt_re_tarif           NUMBER;
    vt_re_premium         NUMBER;
    vt_commis             NUMBER;
    vt_commis_pers        NUMBER;
    vt_reserve_begin      NUMBER;
    vt_reserve_begin_null NUMBER;
    vt_limit              NUMBER;
    vt_amount             NUMBER;
  BEGIN
    BEGIN
      SELECT plan_date INTO v_date FROM ac_payment WHERE payment_id = p_ac_payment_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    SELECT re_cover_id
          ,NVL(plan_date, v_date)
      INTO v_re_cover_id
          ,v_date
      FROM rel_recover_bordero
     WHERE rel_recover_bordero_id = p_rel_recover_id;
  
    vt_sum_first          := 0;
    vt_BARt               := 0;
    vt_RBARt              := 0;
    vt_base_rate          := 0;
    vt_re_tarif           := 0;
    vt_re_premium         := 0;
    vt_commis             := 0;
    vt_commis_pers        := 0;
    vt_reserve_begin      := 0;
    vt_reserve_begin_null := 0;
    vt_limit              := 0;
    vt_amount             := 0;
  
    FOR cur IN (SELECT rlc.re_line_cover_id
                      ,rlc.re_tariff
                      ,rc.p_cover_id
                      ,rc.re_cover_id
                      ,NVL(rlc.retention_val, 0) retention_val
                      ,NVL(rlc.part_sum, 0) part_sum
                      ,rlc.part_perc
                      ,rlc.retention_perc
                      ,rlc.commission_perc
                      ,rcv.func_calc_id
                      ,ll.brief
                      ,rb.fund_id
                      ,mc.FLG_TYPE_PAYMENT
                      ,pc.PREMIUM
                  FROM re_line_cover       rlc
                      ,re_cover            rc
                      ,re_bordero          rb
                      ,re_contract_version rcv
                      ,re_main_contract    mc
                      ,p_cover             pc
                      ,t_prod_line_option  plo
                      ,t_product_line      pl
                      ,t_lob_line          ll
                 WHERE rlc.re_cover_id = v_re_cover_id
                   AND rc.re_cover_id = v_re_cover_id
                   AND rc.re_contract_ver_id = rcv.re_contract_version_id
                   AND mc.re_main_contract_id = rcv.re_main_contract_id
                   AND rb.re_bordero_id = rc.re_bordero_id
                   AND pc.p_cover_id = rc.p_cover_id
                   AND plo.ID = pc.t_prod_line_option_id
                   AND pl.ID = plo.product_line_id
                   AND ll.t_lob_line_id = pl.t_lob_line_id
                   AND rlc.part_sum >= 0
                 ORDER BY rlc.line_number)
    LOOP
    
      v_ins_sum := cur.retention_val + cur.part_sum;
    
      --вычисление резервов по покрытию
      v_reserve_begin_null := get_reserve(cur.re_cover_id, NULL) * (v_ins_sum);
      v_reserve_begin      := get_reserve(cur.re_cover_id, v_date) * (v_ins_sum);
    
      v_k := get_coef(v_re_cover_id, 'K');
      v_s := get_coef(v_re_cover_id, 'S');
      --исправлено 20.04.2009 Веселуха по заявке 18970
      ------------------------------------------------
      BEGIN
        SELECT reg.limit
              ,reg.ins_amount
          INTO vt_limit
              ,vt_amount
          FROM (SELECT cont.limit
                      ,pc.ins_amount
                  FROM re_line_cover       rlc
                      ,re_cover            rc
                      ,re_bordero          rb
                      ,re_contract_version rcv
                      ,re_main_contract    mc
                      ,p_cover             pc
                      ,as_asset            ass
                      ,p_policy            pp
                      ,p_pol_header        ph
                      ,t_prod_line_option  plo
                      ,t_product_line      pl
                      ,t_lob_line          ll
                      ,t_insurance_group   gr
                       
                      ,re_line_contract   cont
                      ,re_cond_filter_obl obl
                 WHERE rlc.re_cover_id = v_re_cover_id
                   AND rc.re_cover_id = v_re_cover_id
                   AND rc.re_contract_ver_id = rcv.re_contract_version_id
                   AND mc.re_main_contract_id = rcv.re_main_contract_id
                   AND rb.re_bordero_id = rc.re_bordero_id
                   AND pc.p_cover_id = rc.p_cover_id
                   AND plo.ID = pc.t_prod_line_option_id
                   AND pl.ID = plo.product_line_id
                   AND ll.t_lob_line_id = pl.t_lob_line_id
                   AND rlc.part_sum >= 0
                   AND gr.t_insurance_group_id = ll.insurance_group_id
                   AND cont.re_contract_id = rc.re_contract_ver_id
                   AND obl.re_contract_ver_id = rc.re_contract_ver_id
                   AND obl.product_line_id = pl.id
                   AND obl.insurance_group_id = ll.insurance_group_id
                   AND cont.re_cond_filter_obl_id = obl.re_cond_filter_obl_id
                   AND ass.as_asset_id = pc.as_asset_id
                   AND pp.policy_id = ass.p_policy_id
                   AND pp.pol_header_id = ph.policy_header_id
                   AND cont.fund_id = ph.fund_id
                 ORDER BY rlc.line_number) reg
         WHERE rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vt_amount := 0;
          vt_limit  := 99999999;
      END;
      -----------------------------------------------------
      IF UPPER(cur.brief) IN ('WOP', 'PWOP', 'WOP_ACC', 'PWOP_ACC', 'PWOP_LIFE', 'WOP_LIFE')
      THEN
        v_sum_first := get_sum_first(cur.p_cover_id, cur.fund_id, v_date, 0, v_k, v_s);
        v_BARt      := get_sum_first(cur.p_cover_id, cur.fund_id, v_date, 1, v_k, v_s);
      ELSE
        v_sum_first := v_ins_sum - v_reserve_begin_null;
        v_BARt      := v_ins_sum - v_reserve_begin;
      END IF;
    
      v_Q     := cur.part_perc / 100;
      v_RBARt := v_Q * v_BARt;
    
      v_re_tarif := get_line_tarif(cur.re_line_cover_id, p_rel_recover_id);
    
      v_base_rate := v_RBARt * v_re_tarif;
    
      BEGIN
        SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'P_COVER';
        v_k_ras := pkg_tariff_calc.calc_fun(cur.func_calc_id, v_ent_id, cur.p_cover_id);
        v_k_ras := NVL(v_k_ras, 1);
      EXCEPTION
        WHEN OTHERS THEN
          v_k_ras := 1;
      END;
    
      IF cur.flg_type_payment = 0
      THEN
        v_re_premium := v_k_ras * v_RBARt * (v_re_tarif * (1 + v_k) + v_s);
      ELSE
        v_re_premium := p_opl_sum * v_re_tarif * cur.part_sum;
        IF NVL(cur.premium, 0) = 0
        THEN
          v_re_premium := v_re_premium / pkg_cover.CALC_PREMIUM(cur.p_cover_id);
        ELSE
          v_re_premium := v_re_premium / cur.premium;
        END IF;
      END IF;
    
      v_commis := v_re_premium * cur.commission_perc / 100;
    
      vt_reserve_begin_null := vt_reserve_begin_null + v_reserve_begin_null;
      vt_reserve_begin      := vt_reserve_begin + v_reserve_begin;
      vt_sum_first          := vt_sum_first + v_sum_first;
      vt_BARt               := vt_BARt + v_BARt;
      vt_RBARt              := vt_RBARt + v_RBARt;
      vt_base_rate          := vt_base_rate + v_base_rate;
      vt_re_premium         := vt_re_premium + v_re_premium;
      vt_commis             := vt_commis + v_commis;
    
    END LOOP;
  
    BEGIN
      --исправлено 20.04.2009 Веселуха по заявке 18970,27061
      ------------------------------------------------
      IF vt_limit * 0.65 < vt_sum_first
      THEN
        v_Q := (vt_limit * 0.35 + (vt_sum_first - vt_limit)) / vt_sum_first; --vt_sum_first
      ELSE
        v_Q := vt_RBARt / vt_BARt;
      END IF;
      --изменено 06.07.2009 Веселуха по заявке 25955
      IF v_Q < 0.35
      THEN
        v_Q := 0.35;
      END IF;
      --v_Q := vt_RBARt/vt_BARt;
      -----------------------------------------------
    
      IF vt_re_premium = v_re_premium
      THEN
        vt_re_tarif := v_re_tarif;
      ELSE
        vt_re_tarif := vt_base_rate / vt_RBARt;
      END IF;
    
      --vt_base_rate := vt_RBARt*vt_re_tarif;
      vt_commis_pers := vt_commis / vt_re_premium * 100;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'REL_RECOVER_BORDERO';
  
    SELECT sq_re_calculation.NEXTVAL INTO v_re_calculation_id FROM dual;
  
    INSERT INTO ven_re_calculation
      (re_calculation_id
      ,ure_id
      ,uro_id
      ,FIRST_INS_GUARANTEE
      ,part_sum
      ,INS_GUARANTEE
      ,REINS_GUARANTEE
      ,BASE_RATE_REINS
      ,RE_TARIFF
      ,RE_PREMIUM
      ,COMMISSION_VAl
      ,COMMISSION
      ,RESERVE_BEGIN
      ,RESERVE_BEGIN_NULL
      ,K_DOWN_PAYMENT
      ,K_COEF_M
      ,K_COEF_NM
      ,S_COEF_M
      ,S_COEF_NM
      ,RE_COVER_ID)
    VALUES
      (v_re_calculation_id
      ,v_ent_id
      ,p_rel_recover_id
      ,vt_sum_first
      ,v_Q
      ,vt_BARt
      ,vt_RBARt
      ,vt_base_rate
      ,vt_re_tarif
      ,vt_re_premium
      ,vt_commis
      ,vt_commis_pers
      ,vt_reserve_begin
      ,vt_reserve_begin_null
      ,v_k_ras
      ,get_coef(v_re_cover_id, 'KM')
      ,get_coef(v_re_cover_id, 'KN')
      ,get_coef(v_re_cover_id, 'SM')
      ,get_coef(v_re_cover_id, 'SN')
      ,v_re_cover_id);
  
    RETURN v_re_calculation_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20003
                             ,SQLERRM || ' Ошибка расчета текущей доли перестраховщика.');
  END;

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  FUNCTION get_reserve
  (
    p_re_cover_id NUMBER
   ,p_date        DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
    v_ret_val := 0;
    IF p_date IS NULL
    THEN
      SELECT NVL(r.tv_p_re, 0)
        INTO v_ret_val
        FROM re_cover     rc
            ,v_re_reserve r
       WHERE rc.re_cover_id = p_re_cover_id
         AND r.p_cover_id = rc.p_cover_id
         AND r.insurance_year_number = 0;
    ELSE
      SELECT *
        INTO v_ret_val
        FROM (SELECT NVL(r.tv_p_re, 0)
                FROM re_cover     rc
                    ,v_re_reserve r
               WHERE rc.re_cover_id = p_re_cover_id
                 AND r.p_cover_id = rc.p_cover_id
                 AND p_date BETWEEN r.start_date AND r.end_date
              --and r.insurance_year_number <> 0
               ORDER BY r.INSURANCE_YEAR_NUMBER)
       WHERE ROWNUM = 1;
    END IF;
  
    IF v_ret_val < 0
    THEN
      v_ret_val := 0;
    END IF;
  
    RETURN v_ret_val;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      RETURN 0;
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RETURN 0;
  END;

  ---------------------------------------------------------------
  ---------------------------------------------------------------

  FUNCTION get_coef
  (
    p_re_cover_id NUMBER
   ,p_type        VARCHAR2
  ) RETURN NUMBER IS
    v_k_m  NUMBER;
    v_k_nm NUMBER;
    v_s_m  NUMBER;
    v_s_nm NUMBER;
  BEGIN
    SELECT NVL(pcu.k_coef_m_re, 0) / 100
          ,NVL(pcu.k_coef_nm_re, 0) / 100
          ,NVL(pcu.s_coef_m_re, 0) / 1000
          ,NVL(pcu.s_coef_nm_re, 0) / 1000
      INTO v_k_m
          ,v_k_nm
          ,v_s_m
          ,v_s_nm
      FROM P_COVER_UNDERWR pcu
          ,re_cover        rc
     WHERE pcu.p_cover_underwr_id = rc.p_cover_id
       AND rc.re_cover_id = p_re_cover_id;
    CASE UPPER(p_type)
      WHEN 'K' THEN
        IF v_k_m > v_k_nm
        THEN
          RETURN v_k_m;
        ELSE
          RETURN v_k_nm;
        END IF;
      WHEN 'S' THEN
        IF v_s_m > v_s_nm
        THEN
          RETURN v_s_m;
        ELSE
          RETURN v_s_nm;
        END IF;
      WHEN 'KM' THEN
        RETURN v_k_m;
      WHEN 'KN' THEN
        RETURN v_k_nm;
      WHEN 'SM' THEN
        RETURN v_s_m;
      WHEN 'SN' THEN
        RETURN v_s_nm;
      ELSE
        RETURN 0;
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  ---------------------------------------------------------------
  ---------------------------------------------------------------

  FUNCTION get_line_tarif
  (
    p_re_cover_line_id       NUMBER
   ,p_rel_recover_bordero_id NUMBER
  ) RETURN NUMBER IS
    v_re_line_tarif_func_id NUMBER;
    v_p_cover_id            NUMBER;
    v_ent_id                NUMBER;
    v_re_tariff             NUMBER;
    v_ins_tariff            NUMBER;
    v_ins_premium           NUMBER;
    v_ins_amount            NUMBER;
  
    v_re_line_contract_id NUMBER;
    v_re_cover_id         NUMBER;
  BEGIN
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (1)');
  
    SELECT rc.p_cover_id
           -- , e.ent_id
          ,pc.tariff
          ,pc.premium
          ,pc.ins_amount
          ,lc.RE_COVER_ID
          ,lc.RE_LINE_CONTRACT_ID
      INTO v_p_cover_id
           --, v_ent_id
          ,v_ins_tariff
          ,v_ins_premium
          ,v_ins_amount
          ,v_re_cover_id
          ,v_re_line_contract_id
      FROM re_line_cover lc
          ,re_cover      rc
          ,p_cover       pc
    --         , entity e
     WHERE lc.re_line_cover_id = p_re_cover_line_id
       AND rc.re_cover_id = lc.re_cover_id
       AND pc.p_cover_id = rc.p_cover_id;
    --   AND e.brief = 'REL_RECOVER_BORDERO';
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (2)');
  
    SELECT e.ent_id INTO v_ent_id FROM entity e WHERE e.brief = 'REL_RECOVER_BORDERO';
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (3)');
  
    --raise_application_error(-20000,'error!!!!');
  
    FOR cur IN (SELECT rlc.T_PROD_COEF_TYPE_ID
                  FROM re_line_cover    lc
                      ,re_line_contract rlc
                 WHERE lc.RE_cover_id = v_re_cover_id
                   AND rlc.re_line_contract_id = lc.RE_LINE_CONTRACT_ID
                   AND lc.RE_LINE_COVER_ID <= p_re_cover_line_id
                   AND rlc.T_PROD_COEF_TYPE_ID IS NOT NULL
                 ORDER BY lc.re_line_cover_id DESC)
    LOOP
      v_re_line_tarif_func_id := cur.T_PROD_COEF_TYPE_ID;
      EXIT;
    END LOOP;
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (4)');
  
    LOG(v_re_line_tarif_func_id, 'v_re_line_tarif_func_id (4)');
    LOG(v_ent_id, 'v_ent_id (4)');
    LOG(p_rel_recover_bordero_id, 'p_rel_recover_bordero_id (4)');
  
    v_re_tariff := pkg_tariff_calc.calc_fun(v_re_line_tarif_func_id
                                           ,v_ent_id
                                           ,p_rel_recover_bordero_id);
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (5)');
  
    v_re_tariff := NVL(v_re_tariff, 0);
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (6)');
  
    IF v_re_tariff = 0
    THEN
    
      v_re_tariff := 0;
      /*BEGIN
        IF NVL(v_ins_tariff,0) <> 0 THEN
          v_re_tariff := v_ins_tariff/100;
        ELSE
          v_re_tariff := v_ins_premium/v_ins_amount;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN v_re_tariff := NULL;
      END;*/
    END IF;
  
    LOG(p_re_cover_line_id, 'p_re_cover_line_id (7)');
  
    RETURN v_re_tariff;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Ошибка расчета тарифа p_re_cover_line_id:' || p_re_cover_line_id ||
                              SQLERRM);
  END;
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  FUNCTION get_sum_first
  (
    p_p_cover_id NUMBER
   ,p_fund_id    NUMBER
   ,p_date       DATE DEFAULT NULL
   ,p_type       NUMBER DEFAULT 0
   ,p_k          NUMBER DEFAULT 0
   ,p_s          NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_product_line_id NUMBER;
    v_temp_val        NUMBER;
  
    v_old_year     NUMBER;
    v_ost          NUMBER;
    v_m            NUMBER;
    v_date_b       DATE;
    v_date_p       DATE;
    v_date_h       DATE;
    v_period       NUMBER;
    v_sex          VARCHAR2(1);
    v_deathrate_id NUMBER;
  
    v_ins_premium NUMBER;
    v_ins_amount  NUMBER;
  
    v_ret_val NUMBER;
  
  BEGIN
  
    BEGIN
      SELECT plo.product_line_id
            ,decode(plo.description
                   ,'Защита страховых взносов'
                   ,ABS(TRUNC(MONTHS_BETWEEN(pph.start_date, cont.date_of_birth) / 12))
                   ,'Защита страховых взносов расчитанная по основной программе'
                   ,ABS(TRUNC(MONTHS_BETWEEN(pph.start_date, cont.date_of_birth) / 12))
                   ,ABS(TRUNC(MONTHS_BETWEEN(pph.start_date, cn.date_of_birth) / 12))) old_year
            ,decode(plo.description
                   ,'Защита страховых взносов'
                   ,cont.date_of_birth
                   ,'Защита страховых взносов расчитанная по основной программе'
                   ,cont.date_of_birth
                   ,cn.date_of_birth)
            ,pc.start_date
            ,pph.start_date
            ,ABS(TRUNC(MONTHS_BETWEEN(pph.start_date, pp.end_date + 1) / 12)) period
            ,ABS(CEIL(MONTHS_BETWEEN(pc.start_date + 1, pph.start_date) / 12))
            ,decode(plo.description
                   ,'Защита страховых взносов'
                   ,DECODE(LOWER(SUBSTR(gc.brief, 1, 1)), 'f', 'w', 'm')
                   ,'Защита страховых взносов расчитанная по основной программе'
                   ,DECODE(LOWER(SUBSTR(gc.brief, 1, 1)), 'f', 'w', 'm')
                   ,DECODE(LOWER(SUBSTR(g.brief, 1, 1)), 'f', 'w', 'm')) sex
            ,decode(plo.description
                   ,'Защита страховых взносов'
                   ,81
                   ,'Защита страховых взносов расчитанная по основной программе'
                   ,81
                   ,'Освобождение от уплаты взносов расчитанное по основной программе'
                   ,82
                   ,'Освобождение от уплаты дальнейших взносов'
                   ,82
                   ,'Освобождение от уплаты дальнейших взносов расчитанное по основной программе'
                   ,82
                   ,'Освобождение от уплаты страховых взносов'
                   ,82
                   ,plr.deathrate_id)
            ,decode(plo.description
                   ,'Защита страховых взносов расчитанная по основной программе'
                   ,nvl(pc.ins_amount, 0)
                   ,'Освобождение от уплаты взносов расчитанное по основной программе'
                   ,nvl(pc.ins_amount, 0)
                   ,'Освобождение от уплаты дальнейших взносов расчитанное по основной программе'
                   ,nvl(pc.ins_amount, 0)
                   ,pc.PREMIUM)
            ,pc.ins_amount
            ,decode(nvl(pp.payment_term_id, 1)
                   ,163
                   ,1
                   ,6
                   ,1
                   ,422
                   ,1
                   ,433
                   ,1
                   ,369
                   ,4
                   ,161
                   ,4
                   ,165
                   ,4
                   ,8
                   ,4
                   ,10000
                   ,4
                   ,162
                   ,2
                   ,1002
                   ,2
                   ,164
                   ,2
                   ,166
                   ,12
                   ,2
                   ,12
                   ,1)
        INTO v_product_line_id
            ,v_old_year
            ,v_date_b
            ,v_date_p
            ,v_date_h
            ,v_period
            ,v_ost
            ,v_sex
            ,v_deathrate_id
            ,v_ins_premium
            ,v_ins_amount
            ,v_m
        FROM p_cover            pc
            ,ven_as_assured     aa
            ,p_policy           pp
            ,p_pol_header       pph
            ,cn_person          cn
            ,t_gender           g
            ,t_prod_line_option plo
            ,t_prod_line_rate   plr
            ,P_POLICY_CONTACT   pc
            ,cn_person          cont
            ,t_gender           gc
       WHERE pc.p_cover_id = p_p_cover_id
         AND aa.as_assured_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND pph.policy_header_id = pp.pol_header_id
         AND cn.contact_id = aa.assured_contact_id
         AND g.ID = cn.gender
         AND plo.ID = pc.t_prod_line_option_id
         AND plr.product_line_id(+) = plo.product_line_id
         AND pc.policy_id = pp.policy_id
         AND pc.contact_policy_role_id = 6
         AND cont.contact_id = pc.contact_id
         AND gc.ID = cont.gender;
    
      v_period := LEAST(60 - v_old_year, v_period);
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'no select for p_cover');
        RETURN NULL;
    END;
  
    BEGIN
      SELECT nr_value
        INTO v_temp_val
        FROM ven_t_prod_line_norm pln
            ,(SELECT nr.normrate_id nr_normrate_id
                    ,nr.VALUE       nr_value
                    ,pr.ID          pr_id
                FROM ven_t_product_line pr
                    ,ven_t_lob_line     ll
                    ,ven_normrate       nr
               WHERE pr.ID = v_product_line_id
                 AND nr.base_fund_id = p_fund_id --!!!!!!!!!!!!!!
                 AND ll.t_lob_line_id = nr.t_lob_line_id
                 AND pr.t_lob_line_id = ll.t_lob_line_id) nr
       WHERE pln.product_line_id(+) = nr.pr_id
         AND pln.normrate_id(+) = nr.nr_normrate_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'no normalizate, fund_id=' || p_fund_id || ',pl_id=' ||
                                v_product_line_id);
        RETURN NULL;
    END;
    --raise_application_error(-20000, 'x='||v_old_year||',n='||v_period||',p_sex='||v_sex||',p_table_id='||v_deathrate_id||',p_i='||v_temp_val||'!!!!');
    BEGIN
    
      IF p_type = 0
      THEN
        v_ost := 1;
      END IF;
    
      v_ret_val := pkg_amath.am_xn(x              => v_old_year -- + v_ost
                                  ,n              => v_period -- - v_ost
                                  ,p_sex          => v_sex
                                  ,K_koeff        => 0 --p_k
                                  ,S_koeff        => 0 --p_s
                                  ,m              => v_m -- 1
                                  ,IsPrenumerando => 1
                                  ,p_table_id     => v_deathrate_id
                                  ,p_i            => v_temp_val) * v_ins_premium; --!!!!!!!!!!!!!!!!!!*/
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,SQLERRM || ' p_cover_ID=' || p_p_cover_id || ',x=' || v_old_year ||
                                ',n=' || v_period || ',p_sex=' || v_sex || ',k_coef=' || p_k ||
                                ',s_coef=' || p_s || ',p_table_id=' || v_deathrate_id || ',p_i=' ||
                                v_temp_val || '!!!!');
    END;
    IF NVL(v_ret_val, 0) = 0
    THEN
      RETURN 1;
      RAISE_APPLICATION_ERROR(-20000
                             ,'sum is null. p_cover_ID=' || p_p_cover_id || ',x=' || v_old_year ||
                              ',n=' || v_period || ',p_sex=' || v_sex || ',k_coef=' || p_k ||
                              ',s_coef=' || p_s || ',p_table_id=' || v_deathrate_id || ',p_i=' ||
                              v_temp_val || '!!!!');
    END IF;
    --raise_application_error(-20000, 'v_ret_val:'||v_ret_val||','||sqlerrm);
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN v_ins_amount;
      --raise_application_error(-20000, 'error in get_sum_first:'||sqlerrm);
  END;
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  FUNCTION calc_tant
  (
    p_id    IN NUMBER
   ,p_param IN VARCHAR2
  ) RETURN NUMBER IS
    v_name   VARCHAR2(50);
    v_result NUMBER := 0;
  
    v_ts re_tant_score%ROWTYPE;
  
  BEGIN
    v_name := UPPER(p_param);
    IF TRIM(v_name) || ' ' = ' '
    THEN
      RETURN 0;
    END IF;
  
    CASE v_name
      WHEN 'ALL' THEN
        -- полностью выполнить расчет
      
        SELECT * INTO v_ts FROM re_tant_score WHERE re_tant_score_id = p_id;
      
        v_ts.count_pol          := calc_tant(p_id, 'COUNT_POL');
        v_ts.premium            := calc_tant(p_id, 'A1');
        v_ts.IN_RES_NG_PREMIUM  := calc_tant(p_id, 'A2');
        v_ts.IN_RES_NP_LOSS     := calc_tant(p_id, 'A3');
        v_ts.IN_RES_ND_LOSS     := calc_tant(p_id, 'A4');
        v_ts.IN_RES_LOSS        := calc_tant(p_id, 'A5');
        v_ts.PAY_LOSS_SUM       := calc_tant(p_id, 'B1');
        v_ts.PAY_COMMIS         := calc_tant(p_id, 'B2');
        v_ts.OUT_RES_NG_PREMIUM := NVL(v_ts.in_res_np_loss, 0) * 0.5;
        v_ts.OUT_RES_NP_LOSS    := calc_tant(p_id, 'B4');
        v_ts.OUT_RES_ND_LOSS    := calc_tant(p_id, 'B5');
        v_ts.OUT_RES_LOSS       := calc_tant(p_id, 'B6');
        v_ts.ADMIN_LOSS         := (NVL(v_ts.premium, 0) + NVL(v_ts.in_res_ng_premium, 0) -
                                   NVL(v_ts.out_res_ng_premium, 0)) * 0.1;
        v_ts.PAST_LOSS          := calc_tant(p_id, 'B8');
        v_ts.PERC_LOSS          := calc_tant(p_id, 'B9');
      
        v_ts.sum_in  := v_ts.premium + v_ts.IN_RES_NG_PREMIUM + v_ts.IN_RES_NP_LOSS +
                        v_ts.IN_RES_ND_LOSS + v_ts.IN_RES_LOSS;
        v_ts.sum_out := v_ts.PAY_LOSS_SUM + v_ts.PAY_COMMIS + v_ts.OUT_RES_NG_PREMIUM +
                        v_ts.OUT_RES_NP_LOSS + v_ts.OUT_RES_ND_LOSS + v_ts.OUT_RES_LOSS +
                        v_ts.ADMIN_LOSS + v_ts.PAST_LOSS + v_ts.PERC_LOSS;
        v_ts.SUM     := v_ts.sum_in - v_ts.sum_out;
      
        --if v_ts.sum < 0 then
        --v_ts.sum := 0;
        --end if;
      
        SELECT t.MIN_COUNT_CONTRACT
          INTO v_result
          FROM re_tantieme   t
              ,re_tant_score ts
         WHERE ts.RE_TANT_SCORE_ID = p_id
           AND t.RE_TANTIEME_ID = ts.RE_TANTIEME_ID;
      
        IF v_result > v_ts.count_pol
        THEN
          v_result := 0;
        ELSE
          v_result := v_ts.SUM;
        END IF;
      
        IF v_ts.SUM < 0
        THEN
          v_result := 0;
        END IF;
      
        BEGIN
          SELECT tc.re_tant_cond_id
                ,tc.PERC / 100 * v_result
            INTO v_ts.re_tant_cond_id
                ,v_ts.TOTAL
            FROM re_tant_cond  tc
                ,re_tant_score ts
           WHERE tc.re_tantieme_id = ts.re_tantieme_id
             AND ts.re_tant_score_id = p_id
             AND NVL(tc.MIN_SUM_NETTO, 0) < v_result
             AND NVL(tc.MAX_SUM_NETTO, v_ts.SUM) >= v_ts.SUM;
        EXCEPTION
          WHEN OTHERS THEN
            v_ts.total           := 0;
            v_ts.re_tant_cond_id := NULL;
        END;
      
        UPDATE re_tant_score SET ROW = v_ts WHERE re_tant_score_id = v_ts.re_tant_score_id;
      
        RETURN 0;
      
      WHEN 'COUNT_POL' THEN
        --Количество договоров страхования
        SELECT COUNT(1)
          INTO v_result
          FROM (SELECT DISTINCT pph.POLICY_HEADER_ID
                  FROM re_tant_score       ts
                      ,re_tantieme         t
                      ,re_bordero_package  bp
                      ,re_bordero          b
                      ,rel_recover_bordero rrb
                      ,re_cover            rc
                      ,p_policy            pp
                      ,p_pol_header        pph
                 WHERE ts.RE_TANT_SCORE_ID = p_id
                   AND t.re_tantieme_id = ts.RE_TANTIEME_ID
                   AND bp.RE_M_CONTRACT_ID = t.re_main_contract_id
                   AND b.RE_BORDERO_PACKAGE_ID = bp.RE_BORDERO_PACKAGE_ID
                   AND rrb.re_bordero_id = b.re_bordero_id
                   AND rc.re_cover_id = rrb.re_cover_id
                   AND pp.POLICY_ID = rc.INS_POLICY
                   AND pph.POLICY_HEADER_ID = pp.POL_HEADER_ID
                   AND bp.START_DATE >= ts.start_date
                   AND bp.END_DATE <= ts.end_date);
      WHEN 'A1' THEN
        --уплаченные за период перестраховочные премии за вычетом расторжений
        SELECT NVL(SUM(b.netto_premium * b.RATE_VAL), 0) - NVL(SUM(b.return_sum * b.RATE_VAL), 0)
          INTO v_result
          FROM re_bordero         b
              ,re_bordero_package bp
              ,re_tantieme        t
              ,re_tant_score      ts
         WHERE ts.RE_TANT_SCORE_ID = p_id
           AND t.re_tantieme_id = ts.re_tantieme_id
           AND bp.RE_M_CONTRACT_ID = t.re_main_contract_id
           AND b.re_bordero_package_id = bp.re_bordero_package_id
           AND bp.START_DATE >= ts.start_date
           AND bp.END_DATE <= ts.end_date;
      WHEN 'A2' THEN
        SELECT NVL(ts.OUT_RES_NG_PREMIUM, 0)
          INTO v_result
          FROM re_tant_score ts_cur
              ,re_tantieme   t
              ,re_tant_score ts
         WHERE ts_cur.re_tant_score_id = p_id
           AND t.re_tantieme_id = ts_cur.RE_TANTIEME_ID
           AND ts.re_tantieme_id = t.re_tantieme_id
           AND ts.end_date = ts_cur.start_date - 1 / (24 * 60 * 60);
      WHEN 'A3' THEN
        SELECT NVL(ts.OUT_RES_NP_LOSS, 0)
          INTO v_result
          FROM re_tant_score ts_cur
              ,re_tantieme   t
              ,re_tant_score ts
         WHERE ts_cur.re_tant_score_id = p_id
           AND t.re_tantieme_id = ts_cur.RE_TANTIEME_ID
           AND ts.re_tantieme_id = t.re_tantieme_id
           AND ts.end_date = ts_cur.start_date - 1 / (24 * 60 * 60);
      WHEN 'A4' THEN
        SELECT NVL(ts.OUT_RES_ND_LOSS, 0)
          INTO v_result
          FROM re_tant_score ts_cur
              ,re_tantieme   t
              ,re_tant_score ts
         WHERE ts_cur.re_tant_score_id = p_id
           AND t.re_tantieme_id = ts_cur.RE_TANTIEME_ID
           AND ts.re_tantieme_id = t.re_tantieme_id
           AND ts.end_date = ts_cur.start_date - 1 / (24 * 60 * 60);
      WHEN 'A5' THEN
        SELECT NVL(ts.OUT_RES_LOSS, 0)
          INTO v_result
          FROM re_tant_score ts_cur
              ,re_tantieme   t
              ,re_tant_score ts
         WHERE ts_cur.re_tant_score_id = p_id
           AND t.re_tantieme_id = ts_cur.RE_TANTIEME_ID
           AND ts.re_tantieme_id = t.re_tantieme_id
           AND ts.end_date = ts_cur.start_date - 1 / (24 * 60 * 60);
      WHEN 'B1' THEN
        SELECT NVL(SUM(b.payment_sum * b.RATE_VAL), 0)
          INTO v_result
          FROM re_bordero         b
              ,re_bordero_package bp
              ,re_tantieme        t
              ,re_tant_score      ts
         WHERE ts.RE_TANT_SCORE_ID = p_id
           AND t.re_tantieme_id = ts.re_tantieme_id
           AND bp.RE_M_CONTRACT_ID = t.re_main_contract_id
           AND b.re_bordero_package_id = bp.re_bordero_package_id
           AND bp.START_DATE >= ts.start_date
           AND bp.END_DATE <= ts.end_date;
      WHEN 'B2' THEN
        SELECT NVL(SUM(b.commission * b.RATE_VAL), 0)
          INTO v_result
          FROM re_bordero         b
              ,re_bordero_package bp
              ,re_tantieme        t
              ,re_tant_score      ts
         WHERE ts.RE_TANT_SCORE_ID = p_id
           AND t.re_tantieme_id = ts.re_tantieme_id
           AND bp.RE_M_CONTRACT_ID = t.re_main_contract_id
           AND b.re_bordero_package_id = bp.re_bordero_package_id
           AND bp.START_DATE >= ts.start_date
           AND bp.END_DATE <= ts.end_date;
      WHEN 'B3' THEN
        SELECT NVL(ts.in_res_np_loss, 0) * 0.5
          INTO v_result
          FROM re_tant_score ts
         WHERE re_tant_score_id = p_id;
      WHEN 'B4' THEN
        SELECT NVL(SUM(b.declared_sum * b.RATE_VAL), 0) - NVL(SUM(b.payment_sum * b.RATE_VAL), 0)
          INTO v_result
          FROM re_bordero         b
              ,re_bordero_package bp
              ,re_tantieme        t
              ,re_tant_score      ts
         WHERE ts.RE_TANT_SCORE_ID = p_id
           AND t.re_tantieme_id = ts.re_tantieme_id
           AND bp.RE_M_CONTRACT_ID = t.re_main_contract_id
           AND b.re_bordero_package_id = bp.re_bordero_package_id
           AND bp.START_DATE >= ts.start_date
           AND bp.END_DATE <= ts.end_date;
        IF v_result < 0
        THEN
          v_result := 0;
        END IF;
      WHEN 'B5' THEN
        SELECT NVL(ts.OUT_RES_ND_LOSS, 0)
          INTO v_result
          FROM re_tant_score ts
         WHERE ts.re_tant_score_id = p_id;
      WHEN 'B6' THEN
        /*select nvl(ts.OUT_RES_LOSS,0) 
        into v_result
        from re_tant_score ts
        where ts.re_tant_score_id = p_id;*/
        SELECT NVL(SUM(b.payment_sum * b.RATE_VAL), 0)
          INTO v_result
          FROM re_bordero         b
              ,re_bordero_package bp
              ,re_tantieme        t
              ,re_tant_score      ts
         WHERE ts.RE_TANT_SCORE_ID = p_id
           AND t.re_tantieme_id = ts.re_tantieme_id
           AND bp.RE_M_CONTRACT_ID = t.re_main_contract_id
           AND b.re_bordero_package_id = bp.re_bordero_package_id
           AND bp.START_DATE >= ts.start_date
           AND bp.END_DATE <= ts.end_date;
      WHEN 'B7' THEN
        SELECT (NVL(ts.premium, 0) + NVL(ts.in_res_ng_premium, 0) - NVL(ts.out_res_ng_premium, 0)) * 0.1
          INTO v_result
          FROM re_tant_score ts
         WHERE ts.re_tant_score_id = p_id;
      WHEN 'B8' THEN
        SELECT NVL(ts.PAST_LOSS, 0)
          INTO v_result
          FROM re_tant_score ts
         WHERE ts.re_tant_score_id = p_id;
      WHEN 'B9' THEN
        SELECT NVL(ts.PAST_LOSS, 0) * 0.125
          INTO v_result
          FROM re_tant_score ts
         WHERE ts.re_tant_score_id = p_id;
    END CASE;
  
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
      --raise_application_error(-20000,'p_id='||p_id||'  '||sqlerrm);
  END;
END;
/
