CREATE OR REPLACE PACKAGE pkg_policy_calc_procedure IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 08.04.2014 16:24:03
  -- Purpose : Специальный расчет договора страхования

  TYPE t_strong_start_program_weight IS RECORD(
     asset_type_brief    t_asset_type.brief%TYPE
    ,prod_line_opt_brief t_prod_line_option.brief%TYPE
    ,val                 NUMBER);

  TYPE tt_strong_start_program_weight IS TABLE OF t_strong_start_program_weight;

  FUNCTION get_strong_start_weight_tariff(par_policy_id p_policy.policy_id%TYPE)
    RETURN tt_strong_start_program_weight
    PIPELINED;

  -- Стандартный последовательный расчет договора страхования
  -- Пересчитываем каждый риск каждого застрахованного
  PROCEDURE standard_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Капля П.
    Расчет по суммарному тарифу
  */
  PROCEDURE total_tariff_based_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Капля П.
    Расчет продуктов серии Семейная защита
  */
  PROCEDURE family_protection_policy_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Черных М.
    Расчет продуктов ХКФ CR92_7, CR92_8, CR92_9, CR92_10
    22.05.2014
  */
  PROCEDURE hkf_policy_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Капля П.
    Расчет договоров по продукту Platinum Life
    22.05.2014
  */
  PROCEDURE platinum_life_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
  Доброхотова И.
  Расчет за год по суммарному тарифу, копейка на основную программу
  22.05.2014
  */
  PROCEDURE total_year_tariff_based_calc(par_policy_id p_policy.policy_id%TYPE);

  -- Процедура аналогична total_year_tariff_based_calc, 
  -- но без использования ratio_to_report
  -- Доброхотова И., ноябрь, 2014
  PROCEDURE total_year_tariff_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Черных М.
    Расчет продуктов Накта (CR113_2.1, CR113_2.4)
    27.05.2014
  */
  PROCEDURE nakta_policy_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
  Черных М.
  Расчет за год по суммарному тарифу, копейка на основную программу
  29.08.2014
  */
  PROCEDURE total_year_tariff_integer(par_policy_id p_policy.policy_id%TYPE);

  /*
  Расчет за год по суммарному тарифу, копейка на основную программу (суммарный годовой взнос считается через месячный)
  01.09.2014
  Черных М.
  */
  PROCEDURE total_year_tariff_month(par_policy_id p_policy.policy_id%TYPE);

  /*
  Доброхотова И.
  Расчет Евросиба
  ноябрь, 2014
  */
  PROCEDURE total_evrosib_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Полный расчет Уверенного старта
    374307 FW настройка продукта Уверенный старт  
    Доброхотова И.,  ноябрь, 2014  
  */
  PROCEDURE total_strong_start_2014_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
  Доброхотова И.
  Расчет продуктов Интеркоммерц:
    за год по суммарному тарифу, 
    копейка на программу по риску Смерть в результате несчастного случая  
  08.09.2014
  */
  PROCEDURE intercommerce_policy_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Расчет продукта Platinum_Life_2
    378726 Заявка на настройку продукта Platinum Life
    Доброхотова И., декабрь, 2014
  */
  PROCEDURE platinum_life_mbg_calc(par_policy_id p_policy.policy_id%TYPE);

  /*
    Расчет продукта Семейный депозит 2014
    400191: Семейный депозит. Новый продукт
    Доброхотова И., Капля П., март, 2015
  */
  PROCEDURE famdep_calc(par_policy_id IN NUMBER);
END pkg_policy_calc_procedure;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_calc_procedure IS

  -- Стандартный последовательный расчет договора страхования
  -- Пересчитываем каждый риск каждого застрахованного
  PROCEDURE standard_calc(par_policy_id p_policy.policy_id%TYPE) IS
  
  BEGIN
    FOR rec IN (SELECT a.as_asset_id
                  FROM as_asset    a
                      ,status_hist sh
                 WHERE a.p_policy_id = par_policy_id
                   AND a.status_hist_id = sh.status_hist_id
                   AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
      pkg_asset.recalc_asset(par_asset_id => rec.as_asset_id);
    END LOOP;
  END standard_calc;

  /*
    Капля П.
    Расчет по суммарному тарифу
  */
  PROCEDURE total_tariff_based_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee  NUMBER;
    v_ins_amount NUMBER;
    v_premium    NUMBER;
  BEGIN
  
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    
      IF nvl(rec.is_handchange_ins_amount, 0) = 0
         AND nvl(rec.is_handchange_amount, 0) = 0
      THEN
        v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
        UPDATE p_cover pc SET pc.ins_amount = v_ins_amount WHERE pc.rowid = rec.cover_rowid;
      END IF;
    END LOOP;
  
    SELECT SUM(pc.tariff * ROUND(MONTHS_BETWEEN(pc.end_date, pc.start_date)) * pp.base_sum)
      INTO v_total_fee
      FROM /* p_pol_header ph
           ,*/ p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,CASE
                    WHEN p_cover_id = MAX(p_cover_id)
                     keep(dense_rank FIRST ORDER BY fee_part DESC, p_cover_id) over() THEN
                     fee_part + v_total_fee - SUM(fee_part) over()
                    ELSE
                     fee_part
                  END fee
             FROM (SELECT pc.p_cover_id
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,ratio_to_report(pc.tariff * v_total_fee *
                                                                    MONTHS_BETWEEN(pc.end_date
                                                                                  ,pc.start_date))
                                                    over() * v_total_fee) fee_part
                     FROM as_asset           aa
                         ,p_cover            pc
                         ,t_prod_line_option plo
                         ,t_product_line     pl
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE SET pc.fee = pc2.fee;
  
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_premium
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    
      IF rec.is_handchange_premium = 0
      THEN
        v_premium := pkg_cover.calc_premium(rec.p_cover_id);
        UPDATE p_cover pc SET pc.premium = v_premium WHERE pc.rowid = rec.cover_rowid;
      END IF;
    END LOOP;
  
  END total_tariff_based_calc;

  PROCEDURE family_protection_policy_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_cover               p_cover%ROWTYPE;
    v_base_sum            p_policy.base_sum%TYPE;
    v_payment_terms_brief t_payment_terms.brief%TYPE;
    v_coef                NUMBER;
    vc_total_tariff CONSTANT NUMBER := 0.02;
    v_payment_terms_coeff NUMBER;
    v_total_fee           NUMBER;
    v_number_of_payments  t_payment_terms.number_of_payments%TYPE;
  BEGIN
  
    SELECT base_sum
          ,pt.brief
          ,pt.number_of_payments
      INTO v_base_sum
          ,v_payment_terms_brief
          ,v_number_of_payments
      FROM p_policy        pp
          ,t_payment_terms pt
     WHERE pp.policy_id = par_policy_id
       AND pp.payment_term_id = pt.id;
  
    IF v_payment_terms_brief = 'MONTHLY'
    THEN
      v_payment_terms_coeff := 0.084;
    ELSE
      v_payment_terms_coeff := 1;
    END IF;
  
    v_total_fee := v_base_sum * v_payment_terms_coeff * vc_total_tariff;
  
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                      ,pl.tariff_netto_func_id
                  FROM as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
    
      SELECT * INTO v_cover FROM p_cover pc WHERE pc.rowid = rec.cover_rowid;
    
      pkg_cover.calc_deduct(v_cover.p_cover_id
                           ,v_cover.t_deductible_type_id
                           ,v_cover.t_deduct_val_type_id
                           ,v_cover.deductible_value);
    
      UPDATE p_cover c
         SET c.t_deductible_type_id = v_cover.t_deductible_type_id
            ,c.t_deduct_val_type_id = v_cover.t_deduct_val_type_id
            ,c.deductible_value     = v_cover.deductible_value
       WHERE c.rowid = rec.cover_rowid;
    
      IF rec.tariff_netto_func_id IS NOT NULL
         AND v_cover.is_handchange_tariff = 0
      THEN
        v_cover.tariff_netto := pkg_cover.calc_tariff_netto(v_cover.p_cover_id);
      
        UPDATE p_cover c SET c.tariff_netto = v_cover.tariff_netto WHERE c.rowid = rec.cover_rowid;
      END IF;
    
      v_cover.normrate_value := pkg_productlifeproperty.calc_normrate_value(p_cover_id => v_cover.p_cover_id);
    
      UPDATE p_cover c
         SET c.normrate_value = nvl(v_cover.normrate_value, c.normrate_value)
       WHERE c.rowid = rec.cover_rowid;
    
      IF nvl(v_cover.is_handchange_amount, 0) = 0
         AND nvl(v_cover.is_handchange_ins_amount, 0) = 0
      THEN
        v_cover.ins_amount := pkg_cover.calc_ins_amount(v_cover.p_cover_id);
        UPDATE p_cover c SET c.ins_amount = v_cover.ins_amount WHERE c.rowid = rec.cover_rowid;
      
        v_coef := pkg_tariff.calc_cover_coef(v_cover.p_cover_id);
      
      END IF;
    
    END LOOP;
  
    MERGE INTO p_cover pc
    USING (
      WITH cover_base AS
       (SELECT pc.p_cover_id
              ,pc.tariff_netto / number_of_assured_of_type tariff_netto
              ,v_base_sum / pc.ins_amount ins_amount_koef
              ,pc.ins_amount
              ,number_of_assured_of_type
              ,pl.fee_round_rules_id
              ,pl.tariff_func_precision
              ,pl.tariff_netto_func_precision
          FROM (SELECT aa.as_asset_id
                      ,COUNT(*) over(PARTITION BY ah.t_asset_type_id) number_of_assured_of_type
                  FROM as_asset       aa
                      ,p_asset_header ah
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.p_asset_header_id = ah.p_asset_header_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)) aa
              ,p_cover pc
              ,t_prod_line_option plo
              ,t_product_line pl
         WHERE aa.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = plo.id
           AND plo.product_line_id = pl.id
           AND pc.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)),
      cover_advanced AS
       (SELECT p_cover_id
              ,tariff_netto / ins_amount_koef / (SUM(tariff_netto / ins_amount_koef) over()) fee_part
              ,ins_amount_koef
              ,ROUND(tariff_netto, tariff_netto_func_precision) tariff_netto
              ,number_of_assured_of_type
              ,fee_round_rules_id
              ,tariff_func_precision
          FROM cover_base)
      SELECT p_cover_id
            ,tariff
            ,self_fee + CASE
               WHEN delta_sum_self_fee != 0
                    AND row_number()
                over(ORDER BY self_fee DESC, p_cover_id) <= abs(delta_sum_self_fee) * 100 THEN
                sign(delta_sum_self_fee) * 0.01
               ELSE
                0
             END fee
            ,tariff_netto
        FROM (SELECT p_cover_id
                    ,ROUND(vc_total_tariff * fee_part * ins_amount_koef
                           --/      number_of_assured_of_type
                          ,tariff_func_precision) tariff
                    ,pkg_round_rules.calculate(fee_round_rules_id
                                              ,fee_part * v_total_fee /*/ number_of_assured_of_type*/) self_fee
                    ,v_total_fee -
                     SUM(pkg_round_rules.calculate(fee_round_rules_id
                                                  ,fee_part * v_total_fee /*/ number_of_assured_of_type*/)) over() delta_sum_self_fee
                    ,tariff_netto
                FROM cover_advanced)) pc2
          ON (pc.p_cover_id = pc2.p_cover_id) WHEN MATCHED THEN
        UPDATE
           SET pc.fee          = pc2.fee
              ,pc.tariff       = pc2.tariff
              ,pc.tariff_netto = pc2.tariff_netto
              ,pc.rvb_value    = 1 - pc2.tariff_netto / pc2.tariff
              ,pc.premium      = pc2.fee * v_number_of_payments;
  
  END family_protection_policy_calc;

  /*
    Черных М.
    Расчет продуктов ХКФ CR92_7, CR92_8, CR92_9, CR92_10
    22.05.2014
  */
  PROCEDURE hkf_policy_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_cover                  p_cover%ROWTYPE;
    v_base_sum               p_policy.base_sum%TYPE;
    v_payment_terms_brief    t_payment_terms.brief%TYPE;
    v_product_brief          t_product.brief%TYPE;
    v_coef                   NUMBER;
    v_payment_terms_coeff    NUMBER;
    v_total_fee              NUMBER;
    vc_total_tariff          NUMBER;
    v_number_of_payments     t_payment_terms.number_of_payments%TYPE;
    v_period_in_pseudomonths NUMBER;
  BEGIN
  
    SELECT base_sum
          ,(trunc(pp.end_date + 1) - pp.start_date) / 30 /*+1 нужен, т.к. заканчивается в 59:59 */
          ,pt.number_of_payments
          ,p.brief
      INTO v_base_sum
          ,v_period_in_pseudomonths
          ,v_number_of_payments
          ,v_product_brief
      FROM p_policy        pp
          ,t_payment_terms pt
          ,p_pol_header    ph
          ,t_product       p
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pp.payment_term_id = pt.id
       AND p.product_id = ph.product_id;
  
    /*заполенение тарифов на покрытиях*/
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                      ,pl.tariff_netto_func_id
                  FROM as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
    
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    
    END LOOP;
  
    /*Подсчет общего тарифа как суммы тарифов по рискам*/
    SELECT SUM(pc.tariff)
      INTO vc_total_tariff
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND pp.policy_id = aa.p_policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    v_total_fee := v_base_sum * vc_total_tariff * v_period_in_pseudomonths;
  
    MERGE INTO p_cover pc
    USING (SELECT cc.p_cover_id
                 ,cc.tariff
                 ,cc.distributed_fee + CASE
                    WHEN (v_product_brief IN ('CR92_12') AND cc.brief = 'PEPR_2')
                         OR (v_product_brief NOT IN ('CR92_12') AND cc.brief IN ('ADis', 'ANY_12_GR')) THEN
                     cc.total_fee - SUM(cc.distributed_fee) over() /*Списывание копеек на Инвалидность*/
                    ELSE
                     0
                  END fee
                 ,cc.tariff_netto
             FROM (SELECT ROUND(self_fee_without_round /*не округленные*/
                                + (cb.total_fee - SUM(cb.self_fee /*округленные до 2 знаков*/) over()) *
                                ratio_to_report(cb.tariff) over()
                               ,2) distributed_fee
                         ,cb.*
                     FROM (SELECT pc.p_cover_id
                                 ,pc.as_asset_id
                                 ,pc.t_prod_line_option_id
                                 ,plo.brief
                                 ,pc.tariff_netto
                                 ,tariff /*Брутто тариф по каждому риску*/
                                 ,ROUND(pc.tariff * (trunc(pc.end_date + 1) - pc.start_date) / 30 *
                                        v_base_sum
                                       ,2) self_fee
                                 , /*взнос по каждому риску*/pc.tariff *
                                  (trunc(pc.end_date + 1) - pc.start_date) / 30 *
                                  v_base_sum self_fee_without_round
                                  /*Без округления - это важно*/
                                 ,ROUND(v_total_fee, 0) total_fee /*общая страховой взнос (премия) округл. до целых*/
                                 ,SUM(pc.tariff) over() total_tariff /*суммарный брутто тариф*/
                             FROM p_policy           pp
                                 ,as_asset           aa
                                 ,p_cover            pc
                                 ,t_prod_line_option plo
                            WHERE pp.policy_id = par_policy_id
                              AND pp.policy_id = aa.p_policy_id
                              AND aa.as_asset_id = pc.as_asset_id
                              AND pc.t_prod_line_option_id = plo.id) cb) cc) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee        = pc2.fee
            ,pc.tariff     = pc2.tariff
            ,pc.rvb_value  = 1 - pc2.tariff_netto / pc2.tariff
            ,pc.premium    = pc2.fee * v_number_of_payments
            ,pc.ins_amount = v_base_sum /*страховая сумма равна базовой*/
      ;
  
  END hkf_policy_calc;

  PROCEDURE platinum_life_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_base_sum           p_policy.base_sum%TYPE;
    v_coef               NUMBER;
    v_dummy              NUMBER;
    v_ins_amount         NUMBER;
    v_total_fee          NUMBER;
    v_number_of_payments NUMBER;
  BEGIN
  
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
      v_dummy := pkg_tariff.calc_cover_coef(p_p_cover_id => rec.p_cover_id);
    END LOOP;
  
    v_coef := pkg_tariff_calc.calc_fun(p_brief  => 'Коэффициент рассрочки платежа'
                                      ,p_ent_id => ent.id_by_brief('P_POLICY')
                                      ,p_obj_id => par_policy_id);
  
    SELECT ROUND(pp.base_sum / (SELECT SUM(pc.tariff * v_coef)
                                  FROM as_asset aa
                                      ,p_cover  pc
                                 WHERE aa.p_policy_id = pp.policy_id
                                   AND aa.as_asset_id = pc.as_asset_id)
                ,0)
          ,pp.base_sum
          ,pt.number_of_payments
      INTO v_ins_amount
          ,v_total_fee
          ,v_number_of_payments
      FROM t_payment_terms pt
          ,p_policy        pp
     WHERE pp.policy_id = par_policy_id
       AND pp.payment_term_id = pt.id;
  
    v_coef := pkg_tariff_calc.calc_fun(p_brief  => 'Коэффициент рассрочки платежа'
                                      ,p_ent_id => ent.id_by_brief('P_POLICY')
                                      ,p_obj_id => par_policy_id);
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee_part + CASE
                    WHEN row_number()
                     over(ORDER BY prod_line_type_sort_order, fee_part DESC, p_cover_id) = 1 THEN
                     v_total_fee - SUM(fee_part) over()
                    ELSE
                     0
                  END AS fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,pc.tariff * v_ins_amount * v_coef) fee_part
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee        = pc2.fee
            ,pc.premium    = pc2.fee * v_number_of_payments
            ,pc.ins_amount = v_ins_amount;
  END platinum_life_calc;

  /*
  Доброхотова И.
  Расчет за год по суммарному тарифу, копейка на основную программу
  22.05.2014
  */
  PROCEDURE total_year_tariff_based_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee     NUMBER;
    v_ins_amount    NUMBER;
    v_is_periodical NUMBER;
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      UPDATE p_cover pc SET pc.ins_amount = v_ins_amount WHERE ROWID = rec.cover_rowid;
    END LOOP;
  
    --
    SELECT ROUND(SUM(pc.tariff * pc.ins_amount *
                     CASE pt.is_periodical
                       WHEN 0 THEN
                        ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12
                       ELSE
                        least(ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12, 1)
                     END)
                ,2)
          ,pt.is_periodical
      INTO v_total_fee
          ,v_is_periodical
      FROM p_policy        pp
          ,as_asset        aa
          ,p_cover         pc
          ,t_payment_terms pt
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.payment_term_id = pt.id
     GROUP BY pt.is_periodical;
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee_part + CASE
                    WHEN row_number()
                     over(ORDER BY prod_line_type_sort_order, fee_part DESC, p_cover_id DESC) = 1 THEN
                     v_total_fee - SUM(fee_part) over()
                    ELSE
                     0
                  END fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,ratio_to_report(pc.tariff * pc.ins_amount *
                                                                    CASE v_is_periodical
                                                                      WHEN 0 THEN
                                                                       ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                                           ,pc.start_date)) / 12
                                                                      ELSE
                                                                       least(ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                                                 ,pc.start_date)) / 12
                                                                            ,1)
                                                                    END) over() * v_total_fee) fee_part
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee     = pc2.fee
            ,pc.premium = pc2.fee;
  
  END total_year_tariff_based_calc;

  -- Процедура аналогична total_year_tariff_based_calc, 
  -- но без использования ratio_to_report
  -- Доброхотова И., ноябрь, 2014
  PROCEDURE total_year_tariff_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee     NUMBER;
    v_ins_amount    NUMBER;
    v_is_periodical NUMBER;
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      UPDATE p_cover pc SET pc.ins_amount = v_ins_amount WHERE ROWID = rec.cover_rowid;
    END LOOP;
  
    SELECT ROUND(SUM(pc.tariff * pc.ins_amount *
                     --ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12
                     CASE pt.is_periodical
                       WHEN 0 THEN
                        ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12
                       ELSE
                        least(ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12, 1)
                     END)
                ,2)
          ,pt.is_periodical
      INTO v_total_fee
          ,v_is_periodical
      FROM p_policy        pp
          ,as_asset        aa
          ,p_cover         pc
          ,t_payment_terms pt
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.payment_term_id = pt.id
     GROUP BY pt.is_periodical;
  
    -- Установка взносов           
    -- копейку на основную программу      
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee + CASE
                    WHEN row_number() over(ORDER BY prod_line_type_sort_order, fee DESC) = 1 THEN
                     v_total_fee - SUM(fee) over()
                    ELSE
                     0
                  END fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   , pc.ins_amount * pc.tariff *
                                                    --                                                    ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12
                                                     CASE v_is_periodical
                                                       WHEN 0 THEN
                                                        ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                            ,pc.start_date)) / 12
                                                       ELSE
                                                        least(ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                                  ,pc.start_date)) / 12
                                                             ,1)
                                                     END) fee
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee     = pc2.fee
            ,pc.premium = pc2.fee;
  
  END total_year_tariff_calc;

  /*
    Черных М.
    Расчет продуктов Накта (CR113_2.1, CR113_2.4)
    27.05.2014
  */
  PROCEDURE nakta_policy_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_cover                  p_cover%ROWTYPE;
    v_base_sum               p_policy.base_sum%TYPE;
    v_payment_terms_brief    t_payment_terms.brief%TYPE;
    v_coef                   NUMBER;
    v_payment_terms_coeff    NUMBER;
    v_total_fee              NUMBER;
    vc_total_tariff          NUMBER;
    v_number_of_payments     t_payment_terms.number_of_payments%TYPE;
    v_period_in_pseudomonths NUMBER;
  BEGIN
  
    SELECT base_sum
          ,MONTHS_BETWEEN(trunc(pp.end_date + 1), pp.start_date) /*+1 нужен, т.к. заканчивается в 59:59 */
          ,pt.number_of_payments
      INTO v_base_sum
          ,v_period_in_pseudomonths
          ,v_number_of_payments
      FROM p_policy        pp
          ,t_payment_terms pt
          ,p_pol_header    ph
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pp.payment_term_id = pt.id;
  
    /*заполенение тарифов на покрытиях*/
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                      ,pl.tariff_netto_func_id
                  FROM as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
    
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    
    END LOOP;
  
    /*Подсчет общего тарифа как суммы тарифов по рискам*/
    SELECT SUM(pc.tariff)
      INTO vc_total_tariff
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND pp.policy_id = aa.p_policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    v_total_fee := v_base_sum * vc_total_tariff * v_period_in_pseudomonths;
  
    MERGE INTO p_cover pc
    USING (SELECT cc.p_cover_id
                 ,cc.tariff
                 ,cc.distributed_fee + CASE
                    WHEN cc.brief IN ('TERM_2') THEN
                     cc.total_fee - SUM(cc.distributed_fee) over() /*Списывание копеек на Смерть ЛП*/
                    ELSE
                     0
                  END fee
                 ,cc.tariff_netto
             FROM (SELECT ROUND(self_fee_without_round /*не округленные*/
                                + (cb.total_fee - SUM(cb.self_fee /*округленные до 2 знаков*/) over()) *
                                ratio_to_report(cb.tariff) over()
                               ,2) distributed_fee
                         ,cb.*
                     FROM (SELECT pc.p_cover_id
                                 ,pc.as_asset_id
                                 ,pc.t_prod_line_option_id
                                 ,plo.brief
                                 ,pc.tariff_netto
                                 ,tariff /*Брутто тариф по каждому риску*/
                                 ,ROUND(pc.tariff *
                                        MONTHS_BETWEEN(trunc(pc.end_date + 1), pc.start_date) *
                                        v_base_sum
                                       ,2) self_fee
                                 , /*взнос по каждому риску*/pc.tariff *
                                  MONTHS_BETWEEN(trunc(pc.end_date + 1)
                                                ,pc.start_date) * v_base_sum self_fee_without_round
                                  /*Без округления - это важно*/
                                 ,ROUND(v_total_fee, 2) total_fee /*общая страховой взнос (премия) округл. до 2 знаков*/
                                 ,SUM(pc.tariff) over() total_tariff /*суммарный брутто тариф*/
                             FROM p_policy           pp
                                 ,as_asset           aa
                                 ,p_cover            pc
                                 ,t_prod_line_option plo
                            WHERE pp.policy_id = par_policy_id
                              AND pp.policy_id = aa.p_policy_id
                              AND aa.as_asset_id = pc.as_asset_id
                              AND pc.t_prod_line_option_id = plo.id) cb) cc) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee        = pc2.fee
            ,pc.tariff     = pc2.tariff
            ,pc.rvb_value  = 1 - pc2.tariff_netto / pc2.tariff
            ,pc.premium    = pc2.fee * v_number_of_payments
            ,pc.ins_amount = v_base_sum /*страховая сумма равна базовой*/
      ;
  
  END nakta_policy_calc;

  /*
  Черных М.
  Расчет за год по суммарному тарифу, копейка на основную программу
  29.08.2014
  */
  PROCEDURE total_year_tariff_integer(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee  NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      UPDATE p_cover pc SET pc.ins_amount = v_ins_amount WHERE ROWID = rec.cover_rowid;
    END LOOP;
  
    SELECT CEIL(SUM(pc.tariff * pc.ins_amount *
                    ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12))
      INTO v_total_fee
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee_part + CASE
                    WHEN row_number() over(ORDER BY prod_line_type_sort_order, fee_part DESC) = 1 THEN
                     v_total_fee - SUM(fee_part) over()
                    ELSE
                     0
                  END fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,ratio_to_report(pc.tariff * pc.ins_amount *
                                                                    ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                                        ,pc.start_date)))
                                                    over() * v_total_fee) fee_part
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee     = pc2.fee
            ,pc.premium = pc2.fee;
  
  END total_year_tariff_integer;

  /*
  Расчет за год по суммарному тарифу, копейка на основную программу (суммарный годовой взнос считается через месячный)
  Используется в КС CR18_1 «Альфа-Банк»
  01.09.2014
  Черных М.
  */
  PROCEDURE total_year_tariff_month(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee         NUMBER;
    v_ins_amount        NUMBER;
    v_sum_brutto_tariff NUMBER; --Суммарный брутто-тариф
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      UPDATE p_cover pc SET pc.ins_amount = v_ins_amount WHERE ROWID = rec.cover_rowid;
    END LOOP;
  
    /*Странный расчет страховой премии (перевод годового тарифа в месячный)*/
    SELECT SUM(pc.tariff)
      INTO v_sum_brutto_tariff
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    SELECT ROUND(v_sum_brutto_tariff / 12 * pp.base_sum, 2) *
           ROUND(MONTHS_BETWEEN(trunc(pp.end_date) + 1, pp.start_date) / 12) * 12
      INTO v_total_fee
      FROM p_policy pp
     WHERE pp.policy_id = par_policy_id;
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee_part + CASE
                    WHEN row_number() over(ORDER BY prod_line_type_sort_order, fee_part DESC) = 1 THEN
                     v_total_fee - SUM(fee_part) over()
                    ELSE
                     0
                  END fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,ratio_to_report(pc.tariff * pc.ins_amount *
                                                                    ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                                        ,pc.start_date)))
                                                    over() * v_total_fee) fee_part
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee     = pc2.fee
            ,pc.premium = pc2.fee;
  
  END total_year_tariff_month;

  /*
  Доброхотова И.
  Расчет Евросиба
  ноябрь, 2014
  */
  PROCEDURE total_evrosib_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee  NUMBER;
    v_ins_amount NUMBER;
  
    FUNCTION get_ins_amount RETURN NUMBER IS
    
      v_total_policy_period NUMBER;
      v_policy_id           NUMBER;
      v_base_sum            NUMBER;
      v_result              NUMBER;
      v_is_credit           NUMBER;
      v_ins_amount          NUMBER;
    BEGIN
      SELECT pp.policy_id
            ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date))
            ,pp.base_sum
            ,pp.is_credit
        INTO v_policy_id
            ,v_total_policy_period
            ,v_base_sum
            ,v_is_credit
        FROM p_policy     pp
            ,p_pol_header ph
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id;
    
      IF v_is_credit = 1
      THEN
        SELECT v_base_sum + ROUND(SUM(v_base_sum * all_covers * v_total_policy_period /
                                      (1 - all_covers * v_total_policy_period))
                                 ,2)
          INTO v_result
          FROM (SELECT SUM(nvl(pc.tariff, 0)) all_covers
                  FROM p_cover  pc
                      ,as_asset aa
                 WHERE aa.p_policy_id = v_policy_id
                   AND pc.as_asset_id = aa.as_asset_id);
      ELSE
        v_result := v_base_sum;
      END IF;
    
      RETURN v_result;
    
    END get_ins_amount;
  
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    END LOOP;
  
    v_ins_amount := get_ins_amount;
  
    SELECT ROUND(SUM(pc.tariff * v_ins_amount *
                     ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)))
                ,2)
      INTO v_total_fee
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    -- копейку на основную программу  
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee + CASE
                    WHEN row_number() over(ORDER BY prod_line_type_sort_order, fee DESC) = 1 THEN
                     v_total_fee - SUM(fee) over()
                    ELSE
                     0
                  END fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,ROUND(v_ins_amount * pc.tariff *
                                ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date))
                               ,2) fee
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee        = pc2.fee
            ,pc.premium    = pc2.fee
            ,pc.ins_amount = v_ins_amount;
  
  END total_evrosib_calc;

  --  Функция расчета Вклада (доли) в премию для Уверенного старта
  --  374307 FW настройка продукта Уверенный старт  
  --  Доброхотова И.,  ноябрь, 2014
  FUNCTION get_strong_start_weight_tariff(par_policy_id p_policy.policy_id%TYPE)
    RETURN tt_strong_start_program_weight
    PIPELINED IS
    v_product_line_desc      t_product_line.description%TYPE;
    v_asset_type_brief       t_asset_type.brief%TYPE;
    v_product_brief          t_product.brief%TYPE;
    v_discount_brief         discount_f.brief%TYPE;
    v_prod_line_option_brief t_prod_line_option.brief%TYPE;
  
    v_tariff_reinsurer NUMBER;
    v_children_cnt     NUMBER;
    v_person_cnt       NUMBER;
    v_weight           NUMBER;
    v_base_tariff      NUMBER;
  
    v_program_weight t_strong_start_program_weight;
  
    FUNCTION get_children_count(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
      v_children_count PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_children_count
        FROM as_asset       aa
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE aa.p_policy_id = par_policy_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND at.brief = 'ASSET_PERSON_CHILD';
      RETURN v_children_count;
    
    END get_children_count;
  
    FUNCTION get_person_count(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
      v_person_count PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_person_count
        FROM as_asset       aa
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE aa.p_policy_id = par_policy_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND at.brief IN ('ASSET_PERSON', 'ASSET_PERSON_ADULT');
      RETURN v_person_count;
    END get_person_count;
  
  BEGIN
    v_base_tariff  := pkg_tariff_calc.calc_fun('BASE_WEIGHT'
                                              ,dml_p_policy.get_entity_id
                                              ,par_policy_id);
    v_children_cnt := get_children_count(par_policy_id => par_policy_id);
    v_person_cnt   := get_person_count(par_policy_id => par_policy_id);
  
    FOR rec IN (SELECT DISTINCT at.brief  asset_type_brief
                               ,plo.brief prod_line_option_brief
                               ,pl.id     prod_line_id
                  FROM p_policy           pp
                      ,p_pol_header       ph
                      ,t_product          p
                      ,t_product_version  pv
                      ,t_product_ver_lob  pvl
                      ,t_product_line     pl
                      ,t_prod_line_option plo
                      ,as_asset           aa
                      ,p_asset_header     ah
                      ,t_asset_type       at
                 WHERE pp.policy_id = par_policy_id
                   AND ph.policy_header_id = pp.pol_header_id
                   AND ph.product_id = p.product_id
                   AND p.product_id = pv.product_id
                   AND pv.t_product_version_id = pvl.product_version_id
                   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                   AND plo.product_line_id = pl.id
                   AND aa.p_policy_id = pp.policy_id
                   AND aa.p_asset_header_id = ah.p_asset_header_id
                   AND ah.t_asset_type_id = at.t_asset_type_id)
    LOOP
      v_tariff_reinsurer := pkg_tariff_calc.calc_coeff_val('TARIFF_REINSURER'
                                                          ,t_number_type(rec.prod_line_id));
      v_weight           := v_tariff_reinsurer / v_base_tariff;
    
      IF rec.prod_line_option_brief IN ('AD', 'ADis')
      THEN
        v_weight := v_weight * 0.7;
      ELSIF rec.prod_line_option_brief IN ('CrashDeath', 'CrashDis')
      THEN
        v_weight := v_weight * 0.3;
      ELSIF rec.prod_line_option_brief IN ('Dism')
      THEN
        v_weight := v_weight * 0.1;
      END IF;
    
      IF rec.asset_type_brief = 'ASSET_PERSON'
      THEN
        v_weight := v_weight / v_person_cnt;
        IF rec.prod_line_option_brief IN ('ADis', 'CrashDis', 'Dism')
           AND v_children_cnt > 0
        THEN
          v_weight := v_weight * 0.9;
        END IF;
      ELSE
        v_weight := v_weight / v_children_cnt * 0.1;
      END IF;
    
      v_program_weight.asset_type_brief    := rec.asset_type_brief;
      v_program_weight.prod_line_opt_brief := rec.prod_line_option_brief;
      v_program_weight.val                 := ROUND(v_weight, 12);
    
      PIPE ROW(v_program_weight);
    
    END LOOP;
  
    RETURN;
  
  END get_strong_start_weight_tariff;

  /*
    Полный расчет Уверенного старта
    374307 FW настройка продукта Уверенный старт  
    Доброхотова И.,  ноябрь, 2014  
  */
  PROCEDURE total_strong_start_2014_calc(par_policy_id p_policy.policy_id%TYPE) IS
  
    --    v_target_premium NUMBER;
    v_base_sum      p_policy.base_sum%TYPE;
    v_ins_amount    p_cover.ins_amount%TYPE;
    v_product_id    t_product.product_id%TYPE;
    v_brutto_effect NUMBER;
    v_brutto_tariff NUMBER;
    v_netto_effect  NUMBER;
    v_netto_tariff  NUMBER;
    v_load_tariff   NUMBER;
    v_total_fee     NUMBER;
    v_fee           NUMBER;
  BEGIN
    v_brutto_effect := pkg_tariff_calc.calc_fun('EFFECT_BRUTTO'
                                               ,dml_p_policy.get_entity_id
                                               ,par_policy_id);
  
    v_netto_effect := pkg_tariff_calc.calc_fun('EFFECT_NETTO'
                                              ,dml_p_policy.get_entity_id
                                              ,par_policy_id);
  
    v_load_tariff := 1 - v_netto_effect / v_brutto_effect;
  
    v_base_sum  := dml_p_policy.get_record(par_policy_id).base_sum;
    v_total_fee := v_base_sum * v_brutto_effect;
  
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.rowid cover_rowid
                      ,w.val weight
                      ,nvl(pl.loading_func_precision, 6) loading_func_precision
                  FROM as_asset aa
                      ,p_asset_header ah
                      ,t_asset_type at
                      ,p_cover pc
                      ,t_prod_line_option plo
                      ,t_product_line pl
                      ,t_product_line_type plt
                      ,(SELECT * FROM TABLE(get_strong_start_weight_tariff(par_policy_id))) w
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND pl.product_line_type_id = plt.product_line_type_id
                   AND aa.p_asset_header_id = ah.p_asset_header_id
                   AND ah.t_asset_type_id = at.t_asset_type_id
                   AND w.asset_type_brief = at.brief
                   AND w.prod_line_opt_brief = plo.brief
                   AND aa.status_hist_id != pkg_asset.status_hist_id_del)
    LOOP
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      IF v_ins_amount <> 0
      THEN
        v_brutto_tariff := ROUND(v_brutto_effect * rec.weight * v_base_sum / v_ins_amount, 9);
        v_netto_tariff  := ROUND(v_netto_effect * rec.weight * v_base_sum / v_ins_amount, 9);
      ELSE
        v_brutto_tariff := 0;
        v_netto_tariff  := 0;
      END IF;
    
      v_fee := rec.weight * v_total_fee;
    
      UPDATE p_cover pc
         SET pc.ins_amount   = v_ins_amount
            ,pc.tariff       = v_brutto_tariff
            ,pc.tariff_netto = v_netto_tariff
            ,pc.rvb_value    = ROUND(v_load_tariff, rec.loading_func_precision)
            ,pc.fee          = ROUND(v_fee, 0)
            ,pc.premium      = ROUND(v_fee, 0)
       WHERE ROWID = rec.cover_rowid;
    
    END LOOP;
  
    UPDATE p_cover pc
       SET pc.fee     = ROUND(pc.fee + v_total_fee -
                              (SELECT SUM(pc1.fee)
                                 FROM p_cover  pc1
                                     ,as_asset aa
                                WHERE aa.p_policy_id = par_policy_id
                                  AND aa.as_asset_id = pc1.as_asset_id))
          ,pc.premium = ROUND(pc.fee + v_total_fee -
                              (SELECT SUM(pc1.fee)
                                 FROM p_cover  pc1
                                     ,as_asset aa
                                WHERE aa.p_policy_id = par_policy_id
                                  AND aa.as_asset_id = pc1.as_asset_id))
     WHERE pc.p_cover_id = (SELECT MIN(p_cover_id) keep(dense_rank FIRST ORDER BY aa.as_asset_id DESC)
                            -- выбираем минимального взрослого
                              FROM as_asset           aa
                                  ,p_cover            pc
                                  ,t_prod_line_option plo
                             WHERE aa.p_policy_id = par_policy_id
                               AND aa.as_asset_id = pc.as_asset_id
                               AND pc.t_prod_line_option_id = plo.id
                               AND plo.brief = 'AD' -- программа AD есть только у взрослых
                               AND aa.status_hist_id != pkg_asset.status_hist_id_del);
  
  END;

  /*
  Доброхотова И.
  Расчет продуктов Интеркоммерц:
    за год по суммарному тарифу, 
    копейка на программу по риску Смерть в результате несчастного случая  
  08.09.2014
  */
  PROCEDURE intercommerce_policy_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_total_fee  NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 ORDER BY aa.as_asset_id
                         ,(SELECT plt.sort_order
                            FROM t_prod_line_option  plo
                                ,t_product_line      pl
                                ,t_product_line_type plt
                           WHERE pc.t_prod_line_option_id = plo.id
                             AND plo.product_line_id = pl.id
                             AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      UPDATE p_cover pc SET pc.ins_amount = v_ins_amount WHERE ROWID = rec.cover_rowid;
    END LOOP;
  
    SELECT ROUND(SUM(pc.tariff * pc.ins_amount *
                     ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date)) / 12)
                ,2)
      INTO v_total_fee
      FROM p_policy pp
          ,as_asset aa
          ,p_cover  pc
     WHERE pp.policy_id = par_policy_id
       AND aa.p_policy_id = pp.policy_id
       AND aa.as_asset_id = pc.as_asset_id;
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee_part + CASE
                    WHEN brief IN ('AD') THEN -- списывание копейки на Смерть в результате несчастного случая
                     v_total_fee - SUM(fee_part) over()
                    ELSE
                     0
                  END fee
             FROM (SELECT pc.p_cover_id
                          --                         ,plt.sort_order prod_line_type_sort_order
                         ,plo.brief
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,ratio_to_report(pc.tariff * pc.ins_amount *
                                                                    ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1
                                                                                        ,pc.start_date)))
                                                    over() * v_total_fee) fee_part
                     FROM as_asset           aa
                         ,p_cover            pc
                         ,t_prod_line_option plo
                         ,t_product_line     pl
                   --                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                         --                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee     = pc2.fee
            ,pc.premium = pc2.fee;
  
  END intercommerce_policy_calc;

  /*
    Расчет продукта Platinum_Life_2
    378726 Заявка на настройку продукта Platinum Life
    Доброхотова И., декабрь, 2014
  */
  PROCEDURE platinum_life_mbg_calc(par_policy_id p_policy.policy_id%TYPE) IS
    v_base_sum           p_policy.base_sum%TYPE;
    v_coef               NUMBER;
    v_ins_amount         NUMBER;
    v_total_fee          NUMBER;
    v_number_of_payments NUMBER;
    v_fee                NUMBER;
  BEGIN
  
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.is_handchange_ins_amount
                      ,pc.is_handchange_amount
                      ,pc.rowid cover_rowid
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    END LOOP;
  
    v_coef := pkg_tariff_calc.calc_fun(p_brief  => 'Коэффициент рассрочки платежа'
                                      ,p_ent_id => ent.id_by_brief('P_POLICY')
                                      ,p_obj_id => par_policy_id);
  
    SELECT ROUND(pp.base_sum /
                 (SELECT SUM(pc.tariff * v_coef)
                    FROM as_asset           aa
                        ,p_cover            pc
                        ,t_prod_line_option plo
                   WHERE aa.p_policy_id = pp.policy_id
                     AND aa.as_asset_id = pc.as_asset_id
                     AND plo.id = pc.t_prod_line_option_id
                     AND plo.brief NOT IN ('WOP_DD_SURGERY', 'DMS_DD_SURGERY'))
                ,0)
          ,pp.base_sum
          ,pt.number_of_payments
      INTO v_ins_amount
          ,v_total_fee
          ,v_number_of_payments
      FROM t_payment_terms pt
          ,p_policy        pp
     WHERE pp.policy_id = par_policy_id
       AND pp.payment_term_id = pt.id;
  
    -- Установка взносов
    MERGE INTO p_cover pc
    USING (SELECT p_cover_id
                 ,fee_part + CASE
                    WHEN row_number()
                     over(ORDER BY prod_line_type_sort_order, fee_part DESC, p_cover_id) = 1 THEN
                     v_total_fee - SUM(fee_part) over()
                    ELSE
                     0
                  END AS fee
             FROM (SELECT pc.p_cover_id
                         ,plt.sort_order prod_line_type_sort_order
                         ,pkg_round_rules.calculate(pl.fee_round_rules_id
                                                   ,pc.tariff * v_ins_amount * v_coef) fee_part
                     FROM as_asset            aa
                         ,p_cover             pc
                         ,t_prod_line_option  plo
                         ,t_product_line      pl
                         ,t_product_line_type plt
                    WHERE aa.p_policy_id = par_policy_id
                      AND aa.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.product_line_type_id = plt.product_line_type_id
                      AND aa.status_hist_id IN
                          (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                      AND pc.status_hist_id IN
                          (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                      AND plo.brief NOT IN ('WOP_DD_SURGERY', 'DMS_DD_SURGERY'))) pc2
    ON (pc.p_cover_id = pc2.p_cover_id)
    WHEN MATCHED THEN
      UPDATE
         SET pc.fee        = pc2.fee
            ,pc.premium    = pc2.fee * v_number_of_payments
            ,pc.ins_amount = v_ins_amount;
  
    -- МБГ
    FOR rec IN (SELECT pc.p_cover_id
                      ,pc.tariff
                      ,pc.rowid cover_rowid
                  FROM as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                 WHERE aa.p_policy_id = par_policy_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND plo.brief IN ('WOP_DD_SURGERY', 'DMS_DD_SURGERY')
                   AND aa.status_hist_id IN
                       (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                   AND pc.status_hist_id IN
                       (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                
                )
    LOOP
      v_ins_amount := pkg_cover.calc_ins_amount(rec.p_cover_id);
      v_fee        := ROUND(v_ins_amount * rec.tariff) * v_coef;
      UPDATE p_cover pc
         SET pc.ins_amount = v_ins_amount
            ,pc.fee        = v_fee
            ,pc.premium    = v_fee * v_number_of_payments
       WHERE ROWID = rec.cover_rowid;
    END LOOP;
  
  END platinum_life_mbg_calc;

  /*
    Расчет продукта Семейный депозит 2014
    400191: Семейный депозит. Новый продукт
    Доброхотова И., Капля П., март, 2015
  */
  PROCEDURE famdep_calc(par_policy_id IN NUMBER) IS
    v_ins_amount       NUMBER;
    v_effective_tariff NUMBER;
    v_base_sum         NUMBER;
    c_avia_rail_brief CONSTANT VARCHAR2(50) := 'AVIA_RAIL_ACC_DEATH';
    v_fee     NUMBER;
    v_fee_sum NUMBER := 0;
    v_coef    NUMBER;
    v_premium NUMBER;
  BEGIN
    v_base_sum := dml_p_policy.get_record(par_policy_id, TRUE).base_sum;
  
    FOR rec IN (SELECT p_cover_id
                  FROM v_policy_active_covers t
                 WHERE t.policy_id = par_policy_id
                   AND (prod_line_option_brief NOT LIKE 'Adm%' AND prod_line_option_brief != 'Penalty'))
    LOOP
      pkg_cover.recalc_cover_tariffs(par_cover_id => rec.p_cover_id);
    END LOOP;
  
    FOR rec IN (SELECT p_cover_id
                  FROM v_policy_active_covers t
                 WHERE t.policy_id = par_policy_id
                   AND (prod_line_option_brief LIKE 'Adm%' OR prod_line_option_brief = 'Penalty'))
    LOOP
      pkg_cover.update_cover_sum(p_p_cover_id => rec.p_cover_id);
    END LOOP;
  
    /*
    SELECT SUM(tariff * decode(prod_line_option_brief, c_avia_rail_brief, 2, 1) *
               pkg_tariff.calc_tarif_mul(p_cover_id))
      INTO v_effective_tariff
      FROM v_policy_active_covers t
     WHERE t.policy_id = par_policy_id
       AND (prod_line_option_brief NOT LIKE 'Adm%' AND prod_line_option_brief != 'Penalty');
    */
  
    v_effective_tariff := pkg_tariff_calc.calc_fun(p_brief  => 'FAMILY_DEP2014_INS_AMOUNT_CALC_COEF'
                                                  ,p_ent_id => dml_p_policy.get_entity_id
                                                  ,p_obj_id => par_policy_id);
  
    v_ins_amount := ROUND(v_base_sum * v_effective_tariff, 2);
  
    FOR rec IN (SELECT p_cover_id
                      ,is_handchange_ins_amount
                      ,is_handchange_amount
                      ,t.fee_round_rules_id
                      ,t.tariff
                      ,v_ins_amount * decode(prod_line_option_brief, c_avia_rail_brief, 2, 1) ins_amount
                      ,nvl2(lead(1) over(ORDER BY decode(prod_line_option_brief, 'END', 2, 1)), 0, 1) is_last
                  FROM v_policy_active_covers t
                 WHERE t.policy_id = par_policy_id
                   AND (prod_line_option_brief NOT LIKE 'Adm%' AND prod_line_option_brief != 'Penalty')
                 ORDER BY decode(prod_line_option_brief, 'END', 2, 1))
    LOOP
      v_coef := pkg_tariff.calc_tarif_mul(rec.p_cover_id);
      v_fee  := pkg_round_rules.calculate(rec.fee_round_rules_id, rec.ins_amount * rec.tariff * v_coef);
    
      IF rec.is_last = 0
      THEN
        v_fee_sum := v_fee_sum + v_fee;
        UPDATE p_cover pc
           SET pc.ins_amount = rec.ins_amount
              ,pc.fee        = v_fee
         WHERE pc.p_cover_id = rec.p_cover_id;
      ELSE
        IF v_fee_sum > v_base_sum
        THEN
          ex.raise_custom(v_fee_sum);
        END IF;
        UPDATE p_cover pc
           SET pc.ins_amount = rec.ins_amount
              ,pc.fee        = v_base_sum - v_fee_sum
         WHERE pc.p_cover_id = rec.p_cover_id;
      END IF;
    
    END LOOP;
  
    FOR rec IN (SELECT p_cover_id
                  FROM v_policy_active_covers t
                 WHERE t.policy_id = par_policy_id
                   AND (prod_line_option_brief NOT LIKE 'Adm%' AND prod_line_option_brief != 'Penalty'))
    LOOP
      v_premium := pkg_cover.calc_premium(rec.p_cover_id);
      UPDATE p_cover pc SET pc.premium = v_premium WHERE pc.p_cover_id = rec.p_cover_id;
    END LOOP;
  
  END famdep_calc;

END pkg_policy_calc_procedure;
/
