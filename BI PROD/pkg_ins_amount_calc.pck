CREATE OR REPLACE PACKAGE pkg_ins_amount_calc IS
  /**
  * Пакет расчета страховой суммы по покрытию
  * @author Marchuk A
  */

  /**
  * Получить страховую сумму основной программы
  * @author Marchuk A
  * @param p_p_cover_id  ИД покрытия
  * 
  */
  FUNCTION get_primary_ins_amount(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  Капля П.
  Фукнция копирования СС с основной программы
  */
  FUNCTION get_ins_amount_pla2(par_cover_id NUMBER) RETURN NUMBER;

  /*
    Капля П.
    Страховая сумма по договору равна базовой сумме
  */
  FUNCTION get_policy_base_sum_by_cover(par_cover_id NUMBER) RETURN NUMBER;

  /**
  Капля П.
  Стандартный расчет страховой суммы
  Перенесено из pkg_ren_life_utils
  */
  FUNCTION standart_ins_amount(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /*
  Разбиение страховой премии по рискам для продуктов Уверенный старт Семейный и Индивидуальный
  */
  FUNCTION get_strong_start_ins_amount(par_cover_id NUMBER) RETURN NUMBER;

  /**
  Капля П.
  Фукнция пересчета СС по базовой сумме по кредитным договорам страхования
  */
  FUNCTION get_ins_amount_cr_by_base_sum(par_cover_id NUMBER) RETURN NUMBER;

  /*
    Пиядин А.
    Функция расчета СС для кредиток ROLF
  */
  FUNCTION get_ins_amount_rolf(par_cover_id NUMBER) RETURN NUMBER;

  /*
    Черных М.Г. 12.05.2014
    Функция расчета СС для кредиток КС Авто
  */
  FUNCTION get_ins_amount_ks_avto(par_cover_id NUMBER) RETURN NUMBER;

  /**
  * Расчет страховой суммы с учетом "Кредитования взносов"
  * @author Капля П.
  * @task 359670
  */
  FUNCTION get_ins_amount_rolf_yeartariff(par_cover_id NUMBER) RETURN NUMBER;

  /*
    Капля П.
    Получение СС как минимальной из базовой и ограничения по СС
  */
  FUNCTION get_by_base_sum_with_limit
  (
    par_cover_id         NUMBER
   ,par_ins_amount_limit NUMBER
  ) RETURN NUMBER;

  /*
  Доброхотова И.
  374307 FW настройка продукта Уверенный старт
  Разбиение страховой премии по рискам для продуктов Уверенный старт Семейный и Индивидуальный
  версии 2014г.
  */
  FUNCTION get_strong_start_2014(par_cover_id NUMBER) RETURN NUMBER;

  -- Расчет СС для кредита
  -- 339295 - Анкета на настройку продукта ТКБ
  -- Доброхотова, декабрь, 2014
  FUNCTION get_policy_base_sum_credit(par_cover_id NUMBER) RETURN NUMBER;

  /*
  * Расчет страховой суммы с учетом "Кредитования взносов"
  * по годовому тарифу, без доп.коэфф.
  * @author Доброхотова И.
  * @task 397365: Ирбис настройка продуктов
  */
  FUNCTION get_cr_by_base_yeartariff(par_cover_id NUMBER) RETURN NUMBER;

  /**
  * Расчет СС по программе как суммы премий по основной и обязательным программам, умноженной на срок действия договора
  * Функция суммирует годовую премию по обязательным и основным программам
  * Суммарная премия умножается на срок действия договора в годах
  * @author Капля П.
  * @param par_cover_id - ИД покрытия в договоре страхования
  * @return NUMBER
  */
  FUNCTION get_alltime_mandatory_premium(par_cover_id NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_ins_amount_calc IS
  /**
  * Пакет расчета страховой суммы по покрытию
  * @author Marchuk A
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
        (p_p_cover_id, SYSDATE, 'INS.PKG_XX_LIFE_RECALC', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /**
  * Получить страховую сумму основной программы
  * @author Marchuk A
  * @param p_p_cover_id  ИД покрытия
  * 
  */

  FUNCTION get_primary_ins_amount(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT NUMBER;
  BEGIN
  
    -- Выбор страховой суммы только по основной программе
    SELECT pc_b.ins_amount
      INTO RESULT
      FROM t_product_line_type plt
          ,t_lob_line          ll
          ,t_product_line      pl
          ,t_prod_line_option  plo
          ,p_cover             pc_b
          ,p_cover             pc_a
     WHERE 1 = 1
       AND pc_a.p_cover_id = p_p_cover_id
       AND pc_b.as_asset_id = pc_a.as_asset_id
       AND pc_b.p_cover_id != pc_a.p_cover_id
       AND plo.id = pc_b.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life')
       AND plt.product_line_type_id = pl.product_line_type_id
       AND plt.brief = 'RECOMMENDED'
       AND rownum = 1;
    --
    RETURN RESULT;
  END;

  FUNCTION get_ins_amount_pla2(par_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT pc2.ins_amount
      INTO RESULT
      FROM p_cover            pc1
          ,p_cover            pc2
          ,t_prod_line_option plo
     WHERE pc1.p_cover_id = par_cover_id
       AND pc1.as_asset_id = pc2.as_asset_id
       AND pc2.t_prod_line_option_id = plo.id
       AND plo.brief = 'PEPR';
  
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_ins_amount_pla2;

  FUNCTION get_policy_base_sum_by_cover(par_cover_id NUMBER) RETURN NUMBER IS
    v_result    NUMBER;
    v_proc_name VARCHAR2(255) := 'get_policy_base_sum_by_cover';
  BEGIN
    SELECT pp.base_sum
      INTO v_result
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-2000
                             ,'Ошибка при выполнении функции ' || v_proc_name || chr(10) || SQLERRM);
  END get_policy_base_sum_by_cover;

  FUNCTION standart_ins_amount(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'STANDART_ins_amount';
    RESULT    NUMBER;
    v_tariff  NUMBER;
    v_fee     NUMBER;
  BEGIN
    SELECT pc.tariff
          ,pc.fee
      INTO v_tariff
          ,v_fee
      FROM ven_p_cover pc
     WHERE pc.p_cover_id = p_p_cover_id;
    RESULT := v_fee / v_tariff;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
      RETURN NULL;
  END standart_ins_amount;

  FUNCTION get_strong_start_ins_amount(par_cover_id NUMBER) RETURN NUMBER IS
    RESULT              NUMBER;
    v_product_brief     t_product.brief%TYPE;
    v_policy_base_sum   p_policy.base_sum%TYPE;
    v_product_line_desc t_prod_line_option.description%TYPE;
    v_asset_type_brief  t_asset_type.brief%TYPE;
    v_policy_id         NUMBER;
    v_cnt               NUMBER;
  BEGIN
  
    SELECT pp.base_sum
          ,p.brief
          ,plo.description
          ,pp.policy_id
          ,at.brief
      INTO v_policy_base_sum
          ,v_product_brief
          ,v_product_line_desc
          ,v_policy_id
          ,v_asset_type_brief
      FROM p_cover            pc
          ,as_asset           aa
          ,p_policy           pp
          ,p_pol_header       ph
          ,t_product          p
          ,t_prod_line_option plo
          ,p_asset_header     ah
          ,t_asset_type       at
     WHERE pc.p_cover_id = par_cover_id
       AND pc.t_prod_line_option_id = plo.id
       AND pc.as_asset_id = aa.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND aa.p_asset_header_id = ah.p_asset_header_id
       AND ah.t_asset_type_id = at.t_asset_type_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.product_id = p.product_id;
  
    IF v_policy_base_sum IS NOT NULL
    THEN
    
      SELECT COUNT(*)
        INTO v_cnt
        FROM as_asset       aa
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE aa.p_policy_id = v_policy_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND at.brief = v_asset_type_brief;
    
      IF v_asset_type_brief = 'ASSET_PERSON'
      THEN
        --индивидуальный
        IF v_product_line_desc LIKE '%ДТП'
        THEN
          RESULT := v_policy_base_sum * 2;
        ELSIF v_product_line_desc LIKE '%ереломы%'
        THEN
          RESULT := least(v_policy_base_sum / 10, 100000);
        ELSE
          RESULT := v_policy_base_sum;
        END IF;
      ELSE
        IF v_product_line_desc LIKE '%ДТП'
        THEN
          RESULT := v_policy_base_sum;
        ELSIF v_product_line_desc LIKE '%ереломы%'
        THEN
          RESULT := least(v_policy_base_sum / 20, 50000);
        ELSE
          RESULT := v_policy_base_sum / 2;
        END IF;
      
      END IF;
    
      RESULT := RESULT / v_cnt;
    
    END IF;
  
    RETURN RESULT;
  
  END get_strong_start_ins_amount;

  FUNCTION get_ins_amount_cr_by_base_sum(par_cover_id NUMBER) RETURN NUMBER IS
    --    v_total_premia t_number_type := t_number_type;
    v_tp                  NUMBER := 0; --premia*full_period_in_years
    v_total_policy_period NUMBER;
    v_policy_id           NUMBER;
    v_pc_rowid            ROWID;
    v_cover_id            NUMBER;
    v_base_sum            NUMBER;
    v_result              NUMBER;
    v_is_credit           NUMBER;
  BEGIN
    SELECT pp.policy_id
          ,MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12
          ,pp.base_sum
          ,pp.is_credit
      INTO v_policy_id
          ,v_total_policy_period
          ,v_base_sum
          ,v_is_credit
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    --    SAVEPOINT before_recalc;
  
    IF nvl(v_is_credit, 0) = 1
    THEN
      SELECT v_base_sum +
             SUM(pkg_round_rules.calculate(round_rules_id, v_base_sum * one_cover / (1 - all_covers)))
        INTO v_result
        FROM (SELECT nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date), 0) one_cover
                    ,SUM(nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date), 0)) over() all_covers
                    ,nvl((SELECT pl.ins_amount_round_rules_id
                           FROM t_prod_line_option plo
                               ,t_product_line     pl
                          WHERE plo.id = t_prod_line_option_id
                            AND pl.id = plo.product_line_id)
                        ,(SELECT rr.t_round_rules_id FROM t_round_rules rr WHERE rr.brief = 'round2')) round_rules_id
                FROM p_cover  pc
                    ,as_asset aa
               WHERE aa.p_policy_id = v_policy_id
                 AND pc.as_asset_id = aa.as_asset_id);
    ELSE
      v_result := v_base_sum;
    END IF;
  
    RETURN v_result;
  
  END get_ins_amount_cr_by_base_sum;

  /*
    Пиядин А.
    Функция расчета СС для кредиток ROLF
  */
  FUNCTION get_ins_amount_rolf(par_cover_id NUMBER) RETURN NUMBER IS
    v_tp                  NUMBER := 0;
    v_total_policy_period NUMBER;
    v_policy_id           p_policy.policy_id%TYPE;
    v_pc_rowid            ROWID;
    v_cover_id            NUMBER;
    v_base_sum            p_policy.base_sum%TYPE;
    v_result              NUMBER;
    v_is_credit           p_policy.is_credit%TYPE;
  
  BEGIN
    SELECT pp.policy_id
          ,MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12
          ,pp.base_sum * 1.1 -- по условиям новых продуктов CR103_3, CR103_4, CR103_5
           -- при расчете страховой премии «в кредит» также использовать поправочный коэффициент 1,1
          ,pp.is_credit
      INTO v_policy_id
          ,v_total_policy_period
          ,v_base_sum
          ,v_is_credit
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    IF nvl(v_is_credit, 0) = 1
    THEN
      SELECT v_base_sum +
             SUM(pkg_round_rules.calculate(round_rules_id, v_base_sum * one_cover / (1 - all_covers)))
        INTO v_result
        FROM (SELECT nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date), 0) one_cover
                    ,SUM(nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date), 0)) over() all_covers
                    ,nvl((SELECT pl.ins_amount_round_rules_id
                           FROM t_prod_line_option plo
                               ,t_product_line     pl
                          WHERE plo.id = t_prod_line_option_id
                            AND pl.id = plo.product_line_id)
                        ,(SELECT rr.t_round_rules_id FROM t_round_rules rr WHERE rr.brief = 'round2')) round_rules_id
                FROM p_cover  pc
                    ,as_asset aa
               WHERE aa.p_policy_id = v_policy_id
                 AND pc.as_asset_id = aa.as_asset_id);
    ELSE
      v_result := v_base_sum;
    END IF;
  
    RETURN v_result;
  
  END get_ins_amount_rolf;

  /**
  * Расчет страховой суммы с учетом "Кредитования взносов"
  * @author Капля П.
  * @task 359670
  */
  FUNCTION get_ins_amount_rolf_yeartariff(par_cover_id NUMBER) RETURN NUMBER IS
    v_tp                  NUMBER := 0;
    v_total_policy_period NUMBER;
    v_policy_id           p_policy.policy_id%TYPE;
    v_pc_rowid            ROWID;
    v_cover_id            NUMBER;
    v_base_sum            p_policy.base_sum%TYPE;
    v_result              NUMBER;
    v_is_credit           p_policy.is_credit%TYPE;
  
  BEGIN
    SELECT pp.policy_id
          ,pp.base_sum * 1.1
           -- при расчете страховой премии «в кредит» также использовать поправочный коэффициент 1,1
          ,pp.is_credit
      INTO v_policy_id
          ,v_base_sum
          ,v_is_credit
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    IF nvl(v_is_credit, 0) = 1
    THEN
      SELECT v_base_sum +
             SUM(pkg_round_rules.calculate(round_rules_id, v_base_sum * one_cover / (1 - all_covers)))
        INTO v_result
        FROM (SELECT nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date) / 12, 0) one_cover
                    ,SUM(nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date) / 12, 0)) over() all_covers
                    ,nvl((SELECT pl.ins_amount_round_rules_id
                           FROM t_prod_line_option plo
                               ,t_product_line     pl
                          WHERE plo.id = t_prod_line_option_id
                            AND pl.id = plo.product_line_id)
                        ,(SELECT rr.t_round_rules_id FROM t_round_rules rr WHERE rr.brief = 'round2')) round_rules_id
                FROM p_cover  pc
                    ,as_asset aa
               WHERE aa.p_policy_id = v_policy_id
                 AND pc.as_asset_id = aa.as_asset_id);
    ELSE
      v_result := v_base_sum;
    END IF;
  
    RETURN v_result;
  
  END get_ins_amount_rolf_yeartariff;

  /*
    Черных М.Г. 12.05.2014
    Функция расчета СС для кредиток КС Авто
  */
  FUNCTION get_ins_amount_ks_avto(par_cover_id NUMBER) RETURN NUMBER IS
    v_tp                  NUMBER := 0;
    v_total_policy_period NUMBER;
    v_policy_id           p_policy.policy_id%TYPE;
    v_pc_rowid            ROWID;
    v_cover_id            NUMBER;
    v_base_sum            p_policy.base_sum%TYPE;
    v_result              NUMBER;
    v_is_credit           p_policy.is_credit%TYPE;
  BEGIN
    SELECT pp.policy_id
          ,MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12
          ,pp.base_sum * 1.1 -- по условиям новых продуктов CR103_3, CR103_4, CR103_5
           -- при расчете страховой премии «в кредит» также использовать поправочный коэффициент 1,1
          ,pp.is_credit
      INTO v_policy_id
          ,v_total_policy_period
          ,v_base_sum
          ,v_is_credit
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
          ,t_product    tp
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.product_id = tp.product_id;
  
    IF nvl(v_is_credit, 0) = 1
    THEN
      SELECT v_base_sum +
             SUM(pkg_round_rules.calculate(round_rules_id, v_base_sum * one_cover / (1 - all_covers)))
        INTO v_result
        FROM (SELECT nvl(pc.tariff / 12 * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date), 0) one_cover
                    ,SUM(nvl(pc.tariff / 12 * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date), 0)) over() all_covers
                    ,nvl((SELECT pl.ins_amount_round_rules_id
                           FROM t_prod_line_option plo
                               ,t_product_line     pl
                          WHERE plo.id = t_prod_line_option_id
                            AND pl.id = plo.product_line_id)
                        ,(SELECT rr.t_round_rules_id FROM t_round_rules rr WHERE rr.brief = 'round2')) round_rules_id
                FROM p_cover  pc
                    ,as_asset aa
               WHERE aa.p_policy_id = v_policy_id
                 AND pc.as_asset_id = aa.as_asset_id);
    ELSE
      v_result := v_base_sum;
    END IF;
  
    RETURN v_result;
  
  END get_ins_amount_ks_avto;

  /*
    Капля П.
    Получение СС как минимальной из базовой и ограничения по СС
  */
  FUNCTION get_by_base_sum_with_limit
  (
    par_cover_id         NUMBER
   ,par_ins_amount_limit NUMBER
  ) RETURN NUMBER IS
    v_base_sum p_policy.base_sum%TYPE;
    v_result   NUMBER;
  BEGIN
    SELECT pp.base_sum
      INTO v_base_sum
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    IF par_ins_amount_limit IS NOT NULL
    THEN
      v_result := least(v_base_sum, par_ins_amount_limit);
    ELSE
      v_result := v_base_sum;
    END IF;
  
    RETURN v_result;
  
  END get_by_base_sum_with_limit;

  /*
  Доброхотова И.
  374307 FW настройка продукта Уверенный старт
  Разбиение страховой премии по рискам для продуктов Уверенный старт Семейный и Индивидуальный
  версии 2014г.
  */
  FUNCTION get_strong_start_2014(par_cover_id NUMBER) RETURN NUMBER IS
    RESULT              NUMBER;
    v_product_brief     t_product.brief%TYPE;
    v_policy_base_sum   p_policy.base_sum%TYPE;
    v_product_line_desc t_prod_line_option.description%TYPE;
    v_asset_type_brief  t_asset_type.brief%TYPE;
    v_policy_id         NUMBER;
    v_cnt               NUMBER;
    v_cnt_child         NUMBER;
  BEGIN
  
    SELECT pp.base_sum
          ,p.brief
          ,plo.description
          ,pp.policy_id
          ,at.brief
      INTO v_policy_base_sum
          ,v_product_brief
          ,v_product_line_desc
          ,v_policy_id
          ,v_asset_type_brief
      FROM p_cover            pc
          ,as_asset           aa
          ,p_policy           pp
          ,p_pol_header       ph
          ,t_product          p
          ,t_prod_line_option plo
          ,p_asset_header     ah
          ,t_asset_type       at
     WHERE pc.p_cover_id = par_cover_id
       AND pc.t_prod_line_option_id = plo.id
       AND pc.as_asset_id = aa.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND aa.p_asset_header_id = ah.p_asset_header_id
       AND ah.t_asset_type_id = at.t_asset_type_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.product_id = p.product_id;
  
    IF v_policy_base_sum IS NOT NULL
    THEN
      IF v_asset_type_brief IN ('ASSET_PERSON', 'ASSET_PERSON_ADULT') -- взрослые 
      THEN
        IF v_product_line_desc LIKE '%ереломы%'
        THEN
          RESULT := v_policy_base_sum / 10;
        ELSE
          RESULT := v_policy_base_sum;
        END IF;
      ELSE
        -- дети
        IF v_product_line_desc LIKE '%ереломы%'
        THEN
          RESULT := v_policy_base_sum / 20;
        ELSE
          RESULT := v_policy_base_sum / 2;
        END IF;
      END IF;
    END IF;
  
    RETURN RESULT;
  END get_strong_start_2014;

  -- Расчет СС для кредита
  -- 339295 - Анкета на настройку продукта ТКБ
  -- Доброхотова, декабрь, 2014
  FUNCTION get_policy_base_sum_credit(par_cover_id NUMBER) RETURN NUMBER IS
    v_result    NUMBER;
    v_proc_name VARCHAR2(255) := 'get_policy_base_sum_by_cover';
  BEGIN
    SELECT pp.base_sum * 1.1
      INTO v_result
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-2000
                             ,'Ошибка при выполнении функции ' || v_proc_name || chr(10) || SQLERRM);
  END get_policy_base_sum_credit;

  /*
  * Расчет страховой суммы с учетом "Кредитования взносов"
  * по годовому тарифу, без доп.коэфф.
  * @author Доброхотова И.
  * @task 397365: Ирбис настройка продуктов
  */
  FUNCTION get_cr_by_base_yeartariff(par_cover_id NUMBER) RETURN NUMBER IS
    v_policy_id NUMBER;
    v_base_sum  NUMBER;
    v_result    NUMBER;
    v_is_credit NUMBER;
  BEGIN
    SELECT pp.policy_id
          ,pp.base_sum
          ,pp.is_credit
      INTO v_policy_id
          ,v_base_sum
          ,v_is_credit
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    IF nvl(v_is_credit, 0) = 1
    THEN
      SELECT v_base_sum +
             SUM(pkg_round_rules.calculate(round_rules_id, v_base_sum * one_cover / (1 - all_covers)))
        INTO v_result
        FROM (SELECT nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date) / 12, 0) one_cover
                    ,SUM(nvl(pc.tariff * MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date) / 12, 0)) over() all_covers
                    ,nvl((SELECT pl.ins_amount_round_rules_id
                           FROM t_prod_line_option plo
                               ,t_product_line     pl
                          WHERE plo.id = t_prod_line_option_id
                            AND pl.id = plo.product_line_id)
                        ,(SELECT rr.t_round_rules_id FROM t_round_rules rr WHERE rr.brief = 'round2')) round_rules_id
                FROM p_cover  pc
                    ,as_asset aa
               WHERE aa.p_policy_id = v_policy_id
                 AND pc.as_asset_id = aa.as_asset_id);
    ELSE
      v_result := v_base_sum;
    END IF;
  
    RETURN v_result;
  
  END get_cr_by_base_yeartariff;

  /**
  * Расчет СС по программе как суммы премий по основной и обязательным программам, умноженной на срок действия договора
  * Функция суммирует годовую премию по обязательным и основным программам
  * Суммарная премия умножается на срок действия договора в годах
  * @author Капля П.
  * @param par_cover_id - ИД покрытия в договоре страхования
  * @return NUMBER
  */
  FUNCTION get_alltime_mandatory_premium(par_cover_id NUMBER) RETURN NUMBER IS
    v_ins_amount    NUMBER;
    v_premium       NUMBER;
    v_policy_period NUMBER;
  BEGIN
  
    SELECT MONTHS_BETWEEN(trunc(pp.end_date) + 1, ph.start_date) / 12
      INTO v_policy_period
      FROM p_cover      pc
          ,as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    SELECT SUM(pc2.premium)
      INTO v_premium
      FROM p_cover             pc1
          ,p_cover             pc2
          ,t_prod_line_option  plo
          ,t_product_line      pl
          ,t_product_line_type plt
     WHERE pc1.as_asset_id = pc2.as_asset_id
       AND pc2.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
       AND pc2.t_prod_line_option_id = plo.id
       AND plo.product_line_id = pl.id
       AND pl.product_line_type_id = plt.product_line_type_id
       AND plt.brief IN ('MANDATORY', 'RECOMMENDED')
       AND pc1.p_cover_id = par_cover_id;
  
    v_ins_amount := ROUND(v_premium * v_policy_period, 2);
  
    RETURN v_ins_amount;
  
  END get_alltime_mandatory_premium;

END pkg_ins_amount_calc;
/
