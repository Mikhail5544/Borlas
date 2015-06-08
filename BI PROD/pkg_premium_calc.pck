CREATE OR REPLACE PACKAGE Pkg_Premium_Calc IS
  FUNCTION STANDART_PREMIUM(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION NOSTANDART_AMOUNT(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION CR_PREMIUM(p_p_cover_id IN NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Premium_Calc IS
  /**
  * Пакет расчета премии по покрытию
  * @author Marchuk A
  *
  */

  G_DEBUG BOOLEAN := FALSE;

  PROCEDURE LOG
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO P_COVER_DEBUG
        (P_COVER_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_PREMIUM_CALC', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION STANDART_PREMIUM(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT NUMBER;
  
    v_fee            NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
    v_p_cover_id     NUMBER;
  BEGIN
  
    SELECT pc.p_cover_id
          ,pc.fee
          ,pt.number_of_payments qty
          ,DECODE(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
      INTO v_p_cover_id
          ,v_fee
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
       AND tp.ID(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.ID(+) = pp.payment_term_id;
    --
    LOG(p_p_cover_id, 'FEE ' || v_fee || ' PERIOD_YEAR ' || v_period_year || ' QTY ' || v_qty);
  
    RESULT := (v_fee * v_qty);
    LOG(p_p_cover_id, 'RESULT ' || RESULT);
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
    
      LOG(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;
  /**/
  FUNCTION NOSTANDART_AMOUNT(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT NUMBER;
  
    v_fee            NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
    v_p_cover_id     NUMBER;
    v_tar            NUMBER;
    v_coef           NUMBER;
    min_p_policy_id  NUMBER;
    prod_line_id     NUMBER;
  BEGIN
    v_coef := NVL(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
    
    BEGIN
      SELECT MIN(a.p_policy_id)
            ,opt.product_line_id
      INTO min_p_policy_id
          ,prod_line_id
      FROM ins.p_cover pc_a
          ,ins.as_asset ab
          ,ins.t_prod_line_option opt
          ,ins.p_cover pc_b
          ,ins.status_hist st
          ,ins.as_asset a
      WHERE pc_a.t_prod_line_option_id = opt.id
        AND pc_a.p_cover_id = p_p_cover_id
        AND opt.id = pc_b.t_prod_line_option_id
        AND pc_b.status_hist_id = st.status_hist_id
        AND st.brief != 'DELETED'
        AND pc_b.as_asset_id = a.as_asset_id
        AND pc_a.as_asset_id = ab.as_asset_id
        AND a.p_asset_header_id = ab.p_asset_header_id
        AND (EXISTS (SELECT NULL
                     FROM ins.p_pol_addendum_type pt,
                          ins.t_addendum_type t
                     WHERE pt.p_policy_id = a.p_policy_id
                       AND pt.t_addendum_type_id = t.t_addendum_type_id
                       AND t.brief = 'INVEST_RESERVE_INCLUDE'
                     )
             OR EXISTS (SELECT NULL
                        FROM ins.p_policy pol
                        WHERE pol.policy_id = a.p_policy_id
                          AND pol.version_num = 1
                        )
             )      
      GROUP BY opt.product_line_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 0;
    END;
    
    SELECT pc.p_cover_id
          ,pc.fee
          ,pt.number_of_payments qty
          ,DECODE(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,pc.tariff
    INTO v_p_cover_id
        ,v_fee
        ,v_qty
        ,v_is_one_payment
        ,v_period_year
        ,v_tar
    FROM ins.p_policy pol
        ,ins.as_asset a
        ,ins.p_cover pc
        ,ins.t_payment_terms pt
        ,ins.t_period tp
        ,ins.t_prod_line_option opt
        ,ins.status_hist st
   WHERE pol.policy_id = min_p_policy_id
     AND pol.policy_id = a.p_policy_id
     AND a.as_asset_id = pc.as_asset_id
     AND pol.payment_term_id = pt.id(+)
     AND pol.period_id = tp.id(+)
     AND pc.t_prod_line_option_id = opt.id
     AND opt.product_line_id = prod_line_id
     AND pc.status_hist_id = st.status_hist_id
     AND pt.brief != 'MONTHLY'
     AND st.brief != 'DELETED';
    --
    LOG(p_p_cover_id, 'FEE ' || v_fee || ' PERIOD_YEAR ' || v_period_year || ' QTY ' || v_qty);
  
    RESULT := (v_fee / (v_tar * v_coef));
    LOG(p_p_cover_id, 'RESULT ' || RESULT);
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
    
      LOG(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;
  /**/
  FUNCTION CR_PREMIUM(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    RESULT NUMBER;
  
    v_fee            NUMBER;
    v_qty            NUMBER;
    v_is_one_payment NUMBER;
    v_period_year    NUMBER;
    v_p_cover_id     NUMBER;
  BEGIN
  
    LOG(p_p_cover_id, 'CR_PREMIUM');
  
    SELECT pc.p_cover_id
          ,pc.fee
          ,pt.number_of_payments qty
          ,DECODE(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
      INTO v_p_cover_id
          ,v_fee
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
       AND tp.ID(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.ID(+) = pp.payment_term_id;
  
    LOG(p_p_cover_id
       ,' IS_ONE_PAYMENT ' || v_is_one_payment || ' FEE ' || v_fee || ' PERIOD_YEAR ' ||
        v_period_year || ' QTY ' || v_qty);
  
    --
    IF v_is_one_payment = 1
    THEN
      RESULT := v_fee;
    ELSE
      IF v_period_year < 1
         AND v_period_year >= 1 / v_qty
      THEN
        RESULT := (v_fee * v_qty * v_period_year);
      ELSE
        RESULT := (v_fee * v_qty);
      END IF;
    END IF;
  
    LOG(p_p_cover_id, ' RESULT ' || RESULT);
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      LOG(p_p_cover_id, 'EXCEPTION');
    
      RETURN NULL;
  END;

END;
/
