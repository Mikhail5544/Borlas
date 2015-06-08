CREATE OR REPLACE PACKAGE pkg_fee_calc IS
  FUNCTION acc_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION standart_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION acc_period_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION cr_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION cr_alfa_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION monthly_rounded_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION monthly_rounded_up_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;

  --  Доброхотова И., октябрь, 2014
  --  349442: Настройка РусФинансБанка  
  --  Расчет брутто-взноса по годовому тарифу 
  --   с округлением месяцев до целого по математическим правилам
  FUNCTION year_round_month_fee(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /* Капля П.
  Функция расчета брутто-взноса для продуктов CR92_4, CR92_5 
  */
  FUNCTION cr92_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;
  /*
    Капля П.
    Функция расчета брутто-взноса для продуктов CR111_1, CR111_2
  */
  FUNCTION cr111_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;

  /*
    Пиядин А.
    Функция расчета брутто-взноса для продуктов CR109_1_1 - CR109_1_7, CR109_2_1- CR109_2_4
  */
  FUNCTION cr109_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;

  /*
    Пиядин А.
    Функция расчета брутто-взноса для продуктов CR113_1_1 - CR113_1_3
  */
  FUNCTION cr113_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;

  /*
    Доброхтова И.
    Функция расчета брутто-взноса для продуктов CR119_1
  */
  FUNCTION cr119_1_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;

  /*
    Доброхтова И.
    Функция расчета брутто-взноса для продуктов CR119_2
  */
  FUNCTION cr119_2_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_fee_calc IS
  /**
  * Пакет расчета брутто взноса по покрытию
  * @author Marchuk A
  */
  /**
  * Протокол расчета брутто взноса
  * @author Marchuk A
  * @param p_p_cover_id ИД покрытия
  * @param p_message_date Дата события
  * @param p_message сообщение
  */

  g_debug BOOLEAN := FALSE;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO p_cover_debug
        (p_cover_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_FEE_CALC', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --Нестандартный расчет брутто-взноса для программ НС
  FUNCTION acc_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
  BEGIN
    log(p_p_cover_id, 'ACC_FEE ');
  
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    log(p_p_cover_id, 'v_coef = ' || v_coef);
  
    SELECT pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
           --Наличие Trunc не позволяет производить расчет с периодами не кратными 1 году.
           /* , TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date)/12) period_year*/
          ,MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12 period_year
      INTO v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_year
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
  
    IF v_is_one_payment = 1
    THEN
    
      RESULT := v_ins_amount * v_tariff * v_coef * v_period_year;
    ELSE
    
      RESULT := v_ins_amount * v_tariff * v_coef;
    
    END IF;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_cover_id, 'EXCEPTION');
      RETURN NULL;
  END;

  --  Доброхотова И., октябрь, 2014
  --  349442: Настройка РусФинансБанка  
  --  Расчет брутто-взноса по годовому тарифу 
  --  с округлением месяцев до целого по математическим правилам
  FUNCTION year_round_month_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
  BEGIN
    log(p_p_cover_id, 'YEAR_ROUND_MONTH_FEE ');
  
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    log(p_p_cover_id, 'v_coef = ' || v_coef);
  
    SELECT pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, trunc(pc.start_date))) / 12 period_year
      INTO v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_year
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
  
    RESULT := v_ins_amount * v_tariff * v_coef * v_period_year;
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_cover_id, 'EXCEPTION');
      RETURN NULL;
  END year_round_month_fee;

  FUNCTION standart_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
    v_p_cover_id     NUMBER;
  BEGIN
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    SELECT pc.p_cover_id
          ,pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
      INTO v_p_cover_id
          ,v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_year
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id(+) = pc.as_asset_id
       AND pp.policy_id(+) = aa.p_policy_id
       AND tp.id(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.id(+) = pp.payment_term_id;
    --
    RESULT := (v_ins_amount * v_tariff * nvl(v_coef, 0));
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
    
      log(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;

  FUNCTION acc_period_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
    v_p_cover_id     NUMBER;
  BEGIN
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    SELECT pc.p_cover_id
          ,pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,ROUND((MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12), 1) period_year
      INTO v_p_cover_id
          ,v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_year
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id(+) = pc.as_asset_id
       AND pp.policy_id(+) = aa.p_policy_id
       AND tp.id(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.id(+) = pp.payment_term_id;
    --
    RESULT := (v_ins_amount * v_tariff * v_coef) * v_period_year;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
    
      log(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;

  FUNCTION cr_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
  BEGIN
    log(p_p_cover_id, 'CR_FEE');
  
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    log(p_p_cover_id, 'v_coef = ' || v_coef);
  
    SELECT pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12, 2) period_year
      INTO v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_year
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    log(p_p_cover_id
       ,' IS_ONE_PAYMENT ' || v_is_one_payment || ' TARIFF ' || v_tariff || ' PERIOD_YEAR ' ||
        v_period_year);
  
    /*
    надо не 
    брутто-тариф_1 * страховая сумма * действует
    в годах * поправочные\проверочные коэфы =
    брутто-взнос
    
    а
    (брутто-тариф_1 * страховая сумма *
    поправочные\проверочные коэфы) / колво
    платежей в год = брутто-взнос
    */
  
    IF v_is_one_payment = 1
    THEN
    
      RESULT := (v_ins_amount * v_tariff * v_coef / v_qty) * v_period_year;
    
    ELSE
      IF v_period_year < 1
         AND v_period_year >= 1 / v_qty
      THEN
        RESULT := v_ins_amount * v_tariff * v_coef * (1 / v_qty);
      ELSE
        RESULT := v_ins_amount * v_tariff * v_coef * (1 / v_qty);
      END IF;
    END IF;
  
    log(p_p_cover_id, 'RESULT ' || RESULT);
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_cover_id, 'EXCEPTION ');
      RETURN NULL;
  END;

  --Расчет брутто-взноса для Кредитного страхования альфа банка (окрушлнение суммы каждый месяц)
  FUNCTION cr_alfa_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_fee            NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
    v_months         NUMBER;
    --
    v_plt_brief   VARCHAR2(2000);
    v_as_asset_id NUMBER(12);
  
  BEGIN
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    log(p_p_cover_id, 'CR_Alfa_fee v_coef = ' || v_coef);
  
    SELECT plt.brief
          ,pc.as_asset_id
      INTO v_plt_brief
          ,v_as_asset_id
      FROM t_product_line_type plt
          ,t_lob_line          ll
          ,t_product_line      pl
          ,t_prod_line_option  plo
          ,p_cover             pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND plo.id = pc.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND plt.product_line_type_id = pl.product_line_type_id;
  
    log(p_p_cover_id, 'PLT.BRIEF ' || v_plt_brief);
  
    IF v_plt_brief = 'RECOMMENDED'
    THEN
    
      SELECT pc.tariff
            ,pc.ins_amount
            ,pt.number_of_payments qty
            ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
            ,MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12 period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date)) period_months
        INTO v_tariff
            ,v_ins_amount
            ,v_qty
            ,v_is_one_payment
            ,v_period_year
            ,v_months
        FROM t_payment_terms pt
            ,t_period        tp
            ,p_pol_header    ph
            ,p_policy        pp
            ,as_asset        aa
            ,p_cover         pc
       WHERE 1 = 1
         AND pc.p_cover_id = p_p_cover_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND tp.id = pp.period_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id;
    
      log(p_p_cover_id
         ,'IS_ONE_PAYMENT ' || v_is_one_payment || ' TARIFF ' || v_tariff || ' PERIOD_YEAR ' ||
          v_period_year || ' MONTHS ' || v_months);
    
      IF v_is_one_payment = 1
      THEN
      
        RESULT := ROUND(v_ins_amount * v_tariff / v_months * v_period_year, 2) * v_coef * v_months;
        RESULT := ROUND(RESULT, 2);
      
      ELSE
        IF v_period_year < 1
        THEN
        
          RESULT := v_ins_amount * v_tariff * v_coef / v_qty * v_period_year;
        
        ELSE
        
          RESULT := ROUND(v_ins_amount * v_tariff / v_months * v_period_year, 2) * v_coef * v_months /
                    v_period_year;
          RESULT := ROUND(RESULT, 2);
        
        END IF;
      END IF;
    
    ELSIF v_plt_brief = 'OPTIONAL'
    THEN
    
      SELECT SUM(pc.tariff) INTO v_tariff FROM p_cover pc WHERE pc.as_asset_id = v_as_asset_id;
    
      SELECT pc.ins_amount
            ,pt.number_of_payments qty
            ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
            ,MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12 period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date)) period_months
        INTO v_ins_amount
            ,v_qty
            ,v_is_one_payment
            ,v_period_year
            ,v_months
        FROM t_payment_terms pt
            ,t_period        tp
            ,p_pol_header    ph
            ,p_policy        pp
            ,as_asset        aa
            ,p_cover         pc
       WHERE 1 = 1
         AND pc.p_cover_id = p_p_cover_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND tp.id = pp.period_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id;
    
      SELECT pc.fee
        INTO v_fee
        FROM p_cover pc
       WHERE 1 = 1
         AND pc.as_asset_id = v_as_asset_id
         AND pc.p_cover_id != p_p_cover_id;
    
      log(p_p_cover_id
         ,'IS_ONE_PAYMENT ' || v_is_one_payment || ' TARIFF ' || v_tariff || ' PERIOD_YEAR ' ||
          v_period_year || ' MONTHS ' || v_months);
    
      IF v_is_one_payment = 1
      THEN
      
        RESULT := ROUND(v_ins_amount * v_tariff / v_months * v_period_year, 2) * v_coef * v_months;
        RESULT := ROUND(RESULT, 2);
      
      ELSE
        IF v_period_year < 1
        THEN
        
          RESULT := v_ins_amount * v_tariff * v_coef / v_qty * v_period_year;
        
        ELSE
        
          RESULT := ROUND(v_ins_amount * v_tariff / v_months * v_period_year, 2) * v_coef * v_months /
                    v_period_year;
          RESULT := ROUND(RESULT, 2);
        
        END IF;
      END IF;
    
      RESULT := RESULT - v_fee;
    
    END IF;
    --
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_cover_id, 'EXCEPTION ');
      RETURN NULL;
  END;

  FUNCTION monthly_rounded_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_month   NUMBER;
    v_p_cover_id     NUMBER;
  BEGIN
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    SELECT pc.p_cover_id
          ,pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,trunc(MONTHS_BETWEEN(trunc(pc.end_date), pc.start_date)) + CASE
             WHEN (trunc(pc.end_date) -
                  ADD_MONTHS(pc.start_date, trunc(MONTHS_BETWEEN(trunc(pc.end_date), pc.start_date)))) < 15 THEN
              0
             ELSE
              1
           END period_month
      INTO v_p_cover_id
          ,v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_month
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id(+) = pc.as_asset_id
       AND pp.policy_id(+) = aa.p_policy_id
       AND tp.id(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.id(+) = pp.payment_term_id;
  
    --
    RESULT := (v_ins_amount * v_tariff * nvl(v_coef, 1) * v_period_month);
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
    
      log(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;

  FUNCTION monthly_rounded_up_fee(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT           NUMBER;
    v_tariff         NUMBER;
    v_coef           NUMBER;
    v_ins_amount     NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_month   NUMBER;
    v_p_cover_id     NUMBER;
  BEGIN
    v_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    SELECT pc.p_cover_id
          ,pc.tariff
          ,pc.ins_amount
          ,pt.number_of_payments qty
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,CEIL(MONTHS_BETWEEN(trunc(pc.end_date), pc.start_date)) period_month
      INTO v_p_cover_id
          ,v_tariff
          ,v_ins_amount
          ,v_qty
          ,v_is_one_payment
          ,v_period_month
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_asset        aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id(+) = pc.as_asset_id
       AND pp.policy_id(+) = aa.p_policy_id
       AND tp.id(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.id(+) = pp.payment_term_id;
  
    --
    RESULT := (v_ins_amount * v_tariff * nvl(v_coef, 1) * v_period_month);
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
    
      log(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;

  FUNCTION cr92_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee              NUMBER;
    v_base_sum         p_policy.base_sum%TYPE;
    v_total_target_fee p_cover.fee%TYPE;
    v_product_brief    t_product.brief%TYPE;
  BEGIN
  
    /*
     По продукту CR92_6 базовая сумма является ежемесячной выплатой, поэтому необходимо умножить на 12
    */
    SELECT pp.base_sum
          ,(SELECT ROUND(pp.base_sum * SUM(pc2.tariff) / 360 *
                        (trunc(pp2.end_date) + 1 - ph.start_date) * CASE
                          WHEN p.brief IN ('CR92_17','CR92_6', 'CR92_3', 'CR92_3.1') THEN
                           12
                          ELSE
                           1
                        END
                       ,0)
             FROM p_cover pc2
            WHERE pc2.as_asset_id = pc.as_asset_id)
          ,p.brief
      INTO v_base_sum
          ,v_total_target_fee
          ,v_product_brief
      FROM p_policy     pp
          ,as_asset     aa
          ,p_cover      pc
          ,p_pol_header ph
          ,p_policy     pp2
          ,t_product    p
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.policy_id = pp2.policy_id
       AND ph.product_id = p.product_id;
  
    /* 
    Сначала считаем взнос по каждой программе как СС*Т*Период (как обычно)
    Затем суммируем рассчитанные таким образом взносы и вычитаем их из целевой велечины взноса, 
    полученной с использованием суммарного тарифа. Получаем Основную поправку.
    Делаем поправку по риску. 
    Если риск - Дожитие, делаем дополнительную поправку, чтобы доразнести еще оставшуюся копейку
    */
  
    /*
      v_total_target_fee - суммарный взнос по договору, который в итоге должен получиться 
    */
  
    IF v_product_brief LIKE 'CR92_1%'
       OR v_product_brief LIKE 'CR92_2%'
       OR v_product_brief LIKE 'CR92_3%'
    THEN
      WITH cover AS
       (SELECT -- взнос по программе 
         pc2.p_cover_id
        ,ROUND(v_total_target_fee * ratio_to_report(pc2.tariff) over(), 2) AS self_fee
          FROM p_cover pc1
              ,p_cover pc2
         WHERE pc2.as_asset_id = pc1.as_asset_id
           AND pc1.p_cover_id = par_cover_id)
      SELECT self_fee
             -- делаем дополнительную поправку по Дожитию т.к. все равно остается копейка 
              + CASE
                WHEN self_fee = MAX(self_fee) over() THEN
                 v_total_target_fee - (SELECT SUM(self_fee) FROM cover)
                ELSE
                 0
              END result_fee
        INTO v_fee
        FROM cover pc
       WHERE pc.p_cover_id = par_cover_id;
    
    ELSE
    
      WITH cover AS
       (SELECT -- взнос по программе 
         pc2.self_fee
         /* Определяем основную поправку в разрезе риска */
        ,ROUND((v_total_target_fee - SUM(pc2.self_fee) over()) -- Разность полных взносов целевого и фактического
               * pc2.tariff / SUM(pc2.tariff) over() -- отношение тарифка по программе к суммарному тарифу, чтобы получить пропорцию для размазки поправки
              ,2) delta
        ,pc2.p_cover_id
        ,plo.brief prod_line_option_brief
          FROM p_cover pc1
              ,(SELECT p_cover_id
                      ,as_asset_id
                      ,t_prod_line_option_id
                      ,tariff
                       /* Рассчитываем фактический суммарный взнос без поправок по формуле СС*Т*Период */
                      ,ROUND(tariff * (trunc(end_date) + 1 - start_date) / 360 * v_base_sum, 2) self_fee
                  FROM p_cover) pc2
              ,t_prod_line_option plo
         WHERE pc2.as_asset_id = pc1.as_asset_id
           AND pc2.t_prod_line_option_id = plo.id
           AND pc1.p_cover_id = par_cover_id)
      SELECT self_fee + delta -- Делаем Основную поправку
             -- делаем дополнительную поправку по Дожитию т.к. все равно остается копейка 
              + CASE
                WHEN prod_line_option_brief = 'PEPR_2' THEN
                 v_total_target_fee - (SELECT SUM(self_fee + delta) FROM cover)
                ELSE
                 0
              END result_fee
        INTO v_fee
        FROM cover pc
       WHERE pc.p_cover_id = par_cover_id;
    END IF;
  
    RETURN v_fee;
  
  END cr92_calc;

  FUNCTION cr111_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee              NUMBER;
    v_base_sum         p_policy.base_sum%TYPE;
    v_policy_id        p_policy.policy_id%TYPE;
    v_total_target_fee NUMBER;
  BEGIN
  
    SELECT pp.base_sum
          ,pp.policy_id
      INTO v_base_sum
          ,v_policy_id
      FROM p_cover  pc
          ,as_asset aa
          ,p_policy pp
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    SELECT CEIL(SUM(sum_fee))
      INTO v_total_target_fee
      FROM (SELECT pc.start_date
                  ,pc.end_date
                  ,SUM(pc.tariff) * ROUND(MONTHS_BETWEEN(pc.end_date, pc.start_date)) * v_base_sum AS sum_fee
              FROM as_asset aa
                  ,p_cover  pc
             WHERE aa.p_policy_id = v_policy_id
               AND aa.as_asset_id = pc.as_asset_id
             GROUP BY pc.start_date
                     ,pc.end_date);
  
    /*SELECT pp.base_sum
         ,ROUND(CASE p.brief
                  WHEN 'CR111_1' THEN
                   0.0045
                  ELSE
                   0.0029
                END * MONTHS_BETWEEN(pp2.end_date, ph.start_date) * pp.base_sum
               ,0)
     INTO v_base_sum
         ,v_total_target_fee
     FROM p_policy     pp
         ,as_asset     aa
         ,p_cover      pc
         ,p_pol_header ph
         ,p_policy     pp2
         ,t_product    p
    WHERE pc.p_cover_id = par_cover_id
      AND pc.as_asset_id = aa.as_asset_id
      AND aa.p_policy_id = pp.policy_id
      AND pp.pol_header_id = ph.policy_header_id
      AND ph.last_ver_id = pp2.policy_id
     AND ph.product_id = p.product_id;*/
  
    WITH covers AS
     (SELECT ROUND((v_total_target_fee - SUM(original_fee) over()) * original_fee /
                   (SUM(original_fee) over())
                  ,2) delta
            ,p_cover_id
            ,original_fee
            ,row_number() over(ORDER BY original_fee DESC NULLS LAST) order_num
        FROM (SELECT ROUND(MONTHS_BETWEEN(trunc(pc2.end_date) + 1, pc2.start_date) * pc2.tariff *
                           v_base_sum
                          ,2) original_fee
                    ,pc2.p_cover_id
                FROM p_cover pc1
                    ,p_cover pc2
               WHERE pc1.p_cover_id = par_cover_id
                 AND pc1.as_asset_id = pc2.as_asset_id))
    SELECT original_fee + delta + CASE
             WHEN (order_num = 1) THEN
              v_total_target_fee - (SELECT SUM(original_fee + delta) FROM covers)
             ELSE
              0
           END
      INTO v_fee
      FROM covers pc
     WHERE pc.p_cover_id = par_cover_id;
  
    RETURN v_fee;
  END cr111_calc;

  /*
    Пиядин А.
    Функция расчета брутто-взноса для продуктов CR109_1_1 - CR109_1_7, CR109_2_1- CR109_2_4
  */
  FUNCTION cr109_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee              NUMBER;
    v_base_sum         p_policy.base_sum%TYPE;
    v_total_target_fee p_cover.fee%TYPE;
  BEGIN
  
    SELECT pp.base_sum
          ,(SELECT ROUND(pp.base_sum * SUM(pc2.tariff) / 12 *
                        MONTHS_BETWEEN(pp2.end_date + 1, ph.start_date)
                       ,2)
             FROM p_cover pc2
            WHERE pc2.as_asset_id = pc.as_asset_id)
      INTO v_base_sum
          ,v_total_target_fee
      FROM p_policy     pp
          ,as_asset     aa
          ,p_cover      pc
          ,p_pol_header ph
          ,p_policy     pp2
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.policy_id = pp2.policy_id;
  
    /* 
    Сначала считаем взнос по каждой программе как СС*Т*Период (как обычно)
    Затем суммируем рассчитанные таким образом взносы и вычитаем их из целевой велечины взноса, 
    полученной с использованием суммарного тарифа. Получаем Основную поправку.
    Делаем поправку по риску. 
    Если риск - Дожитие, делаем дополнительную поправку, чтобы доразнести еще оставшуюся копейку
    */
  
    /*
      v_total_target_fee - суммарный взнос по договору, который в итоге должен получиться 
    */
  
    WITH cover AS
     (SELECT -- взнос по программе 
       pc2.self_fee
       /* Определяем основную поправку в разрезе риска */
      ,ROUND((v_total_target_fee - SUM(pc2.self_fee) over()) -- Разность полных взносов целевого и фактического
             * pc2.tariff / SUM(pc2.tariff) over() -- отношение тарифка по программе к суммарному тарифу, чтобы получить пропорцию для размазки поправки
            ,2) delta
      ,pc2.p_cover_id
      ,plo.brief prod_line_option_brief
        FROM p_cover pc1
            ,(SELECT p_cover_id
                    ,as_asset_id
                    ,t_prod_line_option_id
                    ,tariff
                     /* Рассчитываем фактический суммарный взнос без поправок по формуле СС*Т*Период */
                    ,ROUND(tariff * MONTHS_BETWEEN(trunc(end_date) + 1, start_date) / 12 * v_base_sum
                          ,2) self_fee
                FROM p_cover) pc2
            ,t_prod_line_option plo
       WHERE pc2.as_asset_id = pc1.as_asset_id
         AND pc2.t_prod_line_option_id = plo.id
         AND pc1.p_cover_id = par_cover_id)
    SELECT self_fee + delta -- Делаем Основную поправку
           -- делаем дополнительную поправку по риску Смерть т.к. все равно остается копейка 
            + CASE
              WHEN prod_line_option_brief = 'TERM_2' THEN
               v_total_target_fee - (SELECT SUM(self_fee + delta) FROM cover)
              ELSE
               0
            END result_fee
      INTO v_fee
      FROM cover pc
     WHERE pc.p_cover_id = par_cover_id;
  
    RETURN v_fee;
  
  END cr109_calc;

  /*
    Пиядин А.
    Функция расчета брутто-взноса для продуктов CR113_1_1 - CR113_1_3
  */
  FUNCTION cr113_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee              NUMBER;
    v_base_sum         p_policy.base_sum%TYPE;
    v_total_target_fee p_cover.fee%TYPE;
  BEGIN
  
    SELECT pp.base_sum
          ,(SELECT ROUND(pp.base_sum * SUM(pc2.tariff) *
                        MONTHS_BETWEEN(pp2.end_date + 1, ph.start_date)
                       ,2)
             FROM p_cover pc2
            WHERE pc2.as_asset_id = pc.as_asset_id)
      INTO v_base_sum
          ,v_total_target_fee
      FROM p_policy     pp
          ,as_asset     aa
          ,p_cover      pc
          ,p_pol_header ph
          ,p_policy     pp2
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.policy_id = pp2.policy_id;
  
    /* 
    Сначала считаем взнос по каждой программе как СС*Т*Период (как обычно)
    Затем суммируем рассчитанные таким образом взносы и вычитаем их из целевой велечины взноса, 
    полученной с использованием суммарного тарифа. Получаем Основную поправку.
    Делаем поправку по риску. 
    Если риск - Смерть, делаем дополнительную поправку, чтобы доразнести еще оставшуюся копейку
    */
  
    /*
      v_total_target_fee - суммарный взнос по договору, который в итоге должен получиться 
    */
  
    WITH cover AS
     (SELECT -- взнос по программе 
       pc2.self_fee
       /* Определяем основную поправку в разрезе риска */
      ,ROUND((v_total_target_fee - SUM(pc2.self_fee) over()) -- Разность полных взносов целевого и фактического
             * pc2.tariff / SUM(pc2.tariff) over() -- отношение тарифка по программе к суммарному тарифу, чтобы получить пропорцию для размазки поправки
            ,2) delta
      ,pc2.p_cover_id
      ,plo.brief prod_line_option_brief
        FROM p_cover pc1
            ,(SELECT p_cover_id
                    ,as_asset_id
                    ,t_prod_line_option_id
                    ,tariff
                     /* Рассчитываем фактический суммарный взнос без поправок по формуле СС*Т*Период */
                    ,ROUND(tariff * MONTHS_BETWEEN(trunc(end_date) + 1, start_date) * v_base_sum, 2) self_fee
                FROM p_cover) pc2
            ,t_prod_line_option plo
       WHERE pc2.as_asset_id = pc1.as_asset_id
         AND pc2.t_prod_line_option_id = plo.id
         AND pc1.p_cover_id = par_cover_id)
    SELECT self_fee -- Делаем поправку по риску Смерть т.к. все равно остается копейка 
           + CASE
             WHEN prod_line_option_brief = 'TERM_2' THEN
              (SELECT SUM(delta) FROM cover)
             ELSE
              0
           END result_fee
      INTO v_fee
      FROM cover pc
     WHERE pc.p_cover_id = par_cover_id;
  
    RETURN v_fee;
  
  END cr113_calc;

  /*
    Доброхтова И.
    Универсальная функция расчета брутто-взноса 
    по годовому тарифу с двойной корректировкой (вторая - по заданному риску)
  */
  FUNCTION cr_fee_year_2delta_calc
  (
    par_cover_id   p_cover.p_cover_id%TYPE
   ,par_brief_risk t_prod_line_option.brief%TYPE
  ) RETURN NUMBER IS
    v_fee              NUMBER;
    v_base_sum         p_policy.base_sum%TYPE;
    v_total_target_fee p_cover.fee%TYPE;
  BEGIN
  
    SELECT pp.base_sum
          ,(SELECT ROUND(pp.base_sum * SUM(pc2.tariff) / 12 *
                        MONTHS_BETWEEN(pp2.end_date + 1, ph.start_date)
                       ,2)
             FROM p_cover pc2
            WHERE pc2.as_asset_id = pc.as_asset_id)
      INTO v_base_sum
          ,v_total_target_fee
      FROM p_policy     pp
          ,as_asset     aa
          ,p_cover      pc
          ,p_pol_header ph
          ,p_policy     pp2
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.policy_id = pp2.policy_id;
  
    /* 
    Сначала считаем взнос по каждой программе как СС*Т*Период (как обычно)
    Затем суммируем рассчитанные таким образом взносы и вычитаем их из целевой велечины взноса, 
    полученной с использованием суммарного тарифа. Получаем Основную поправку.
    Делаем поправку по риску. 
    Если риск - заданный par_brief_risk, делаем дополнительную поправку, чтобы доразнести еще оставшуюся копейку
    */
  
    /*
      v_total_target_fee - суммарный взнос по договору, который в итоге должен получиться 
    */
  
    WITH cover AS
     (SELECT -- взнос по программе 
       pc2.self_fee
       /* Определяем основную поправку в разрезе риска */
      ,ROUND((v_total_target_fee - SUM(pc2.self_fee) over()) -- Разность полных взносов целевого и фактического
             * pc2.tariff / SUM(pc2.tariff) over() -- отношение тарифа по программе к суммарному тарифу, чтобы получить пропорцию для размазки поправки
            ,2) delta
      ,pc2.p_cover_id
      ,plo.brief prod_line_option_brief
        FROM p_cover pc1
            ,(SELECT p_cover_id
                    ,as_asset_id
                    ,t_prod_line_option_id
                    ,tariff
                     /* Рассчитываем фактический суммарный взнос без поправок по формуле СС*Т*Период */
                    ,ROUND(tariff * MONTHS_BETWEEN(trunc(end_date) + 1, start_date) / 12 * v_base_sum
                          ,2) self_fee
                FROM p_cover) pc2
            ,t_prod_line_option plo
       WHERE pc2.as_asset_id = pc1.as_asset_id
         AND pc2.t_prod_line_option_id = plo.id
         AND pc1.p_cover_id = par_cover_id)
    SELECT self_fee + delta -- Делаем Основную поправку
           -- делаем дополнительную поправку по заданному риску т.к. все равно остается копейка 
            + CASE
              WHEN prod_line_option_brief = par_brief_risk THEN
               v_total_target_fee - (SELECT SUM(self_fee + delta) FROM cover)
              ELSE
               0
            END result_fee
      INTO v_fee
      FROM cover pc
     WHERE pc.p_cover_id = par_cover_id;
  
    RETURN v_fee;
  END cr_fee_year_2delta_calc;

  /*
    Доброхтова И.
    Функция расчета брутто-взноса для продуктов CR119_1
  */
  FUNCTION cr119_1_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee NUMBER;
  BEGIN
    v_fee := cr_fee_year_2delta_calc(par_cover_id, 'AD');
    RETURN v_fee;
  END cr119_1_calc;

  /*
    Доброхтова И.
    Функция расчета брутто-взноса для продуктов CR119_2
  */
  FUNCTION cr119_2_calc(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee NUMBER;
  BEGIN
    v_fee := cr_fee_year_2delta_calc(par_cover_id, 'ATD');
    RETURN v_fee;
  END cr119_2_calc;

END;
/
