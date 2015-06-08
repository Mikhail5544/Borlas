CREATE OR REPLACE PACKAGE PKG_XX10_PRODUCT_VZR IS

  --пакет для расчета продукта "Страхование ВЗР" 

  FUNCTION calc_tariff_brutto(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_fee(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_premium(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_period(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_premuim_cancel(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_deduct_VZR(p_p_cover_id NUMBER) RETURN NUMBER;

END PKG_XX10_PRODUCT_VZR;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX10_PRODUCT_VZR IS

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
        (p_p_cover_id, SYSDATE, 'INS.PKG_XX10_PRODUCT_VZR', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION calc_tariff_brutto(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RETURN RESULT;
  END;

  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RETURN RESULT;
  END;
  FUNCTION calc_fee(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    RESULT := pkg_tariff.calc_cover_coef(p_p_cover_id);
    LOG(p_p_cover_id, 'CALC_FEE');
  
    RESULT := 1;
    FOR cur IN (SELECT pcc.val FROM P_COVER_COEF pcc WHERE pcc.p_cover_id = p_p_cover_id)
    LOOP
      RESULT := RESULT * cur.val * 0.01;
    END LOOP;
  
    FOR cur IN (SELECT pc.ins_amount
                      ,TRUNC(pc.end_date) end_date
                      ,TRUNC(pc.start_date) start_date
                  FROM P_COVER pc
                 WHERE pc.p_cover_id = p_p_cover_id)
    LOOP
      RESULT := cur.ins_amount * RESULT * (cur.end_date - cur.start_date);
    END LOOP;
  
    RETURN RESULT;
  
  END;
  FUNCTION calc_premium(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    RESULT := pkg_tariff.calc_cover_coef(p_p_cover_id);
    LOG(p_p_cover_id, 'CALC_FEE');
  
    RESULT := 1;
    FOR cur IN (SELECT pcc.val FROM P_COVER_COEF pcc WHERE pcc.p_cover_id = p_p_cover_id)
    LOOP
      RESULT := RESULT * cur.val;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  FUNCTION calc_period(p_p_cover_id NUMBER) RETURN NUMBER IS
  
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_cover_id, 'CALC_PERIOD');
  
    FOR cur IN (SELECT pc.ins_amount
                      ,TRUNC(pc.end_date) end_date
                      ,TRUNC(pc.start_date) start_date
                  FROM P_COVER pc
                 WHERE pc.p_cover_id = p_p_cover_id)
    LOOP
      RESULT := cur.end_date - cur.start_date + 1;
    END LOOP;
  
    RETURN RESULT;
  END;

  -- функция расчета страховой премии от страховой суммы
  FUNCTION calc_premuim_cancel(p_p_cover_id NUMBER) RETURN NUMBER IS
  
    RESULT NUMBER;
  BEGIN
  
    LOG(p_p_cover_id, 'CALC_PREMIUM_CANCEL');
  
    FOR cur IN (SELECT pc.ins_amount FROM P_COVER pc WHERE pc.p_cover_id = p_p_cover_id)
    LOOP
      RESULT := cur.ins_amount *
                (pkg_tariff_calc.calc_fun('CANCEL_TARIF', (ent.id_by_brief('P_COVER')), p_p_cover_id));
      --      result := cur.ins_amount * 0.012;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  FUNCTION calc_deduct_VZR(p_p_cover_id NUMBER) RETURN NUMBER IS
  
    v_t_deductible_type_id NUMBER;
    v_t_deduct_val_type_id NUMBER;
    v_deductible_value     NUMBER;
  
    RESULT NUMBER;
  
  BEGIN
  
    LOG(p_p_cover_id, 'CALC_DEDUCT_VZR');
  
    FOR cur IN (SELECT aa.is_deductible
                      ,pc.ins_amount
                      ,pc.ins_price
                      ,f.brief
                      ,tt.brief tt_brief
                  FROM T_TERRITORY  tt
                      ,FUND         f
                      ,P_POL_HEADER ph
                      ,P_POLICY     pp
                      ,AS_ASSURED   aas
                      ,AS_ASSET     aa
                      ,P_COVER      pc
                 WHERE pc.p_cover_id = p_p_cover_id
                   AND aa.as_asset_id = pc.as_asset_id
                   AND aas.as_assured_id = aa.as_asset_id
                   AND tt.t_territory_id(+) = aas.t_territory_id
                   AND pp.policy_id = aa.p_policy_id
                   AND ph.policy_header_id = pp.pol_header_id
                   AND f.fund_id = ph.fund_id)
    LOOP
    
      LOG(p_p_cover_id
         ,'CALC_DEDUCT_VZR IS_DEDUCTIBLE ' || cur.is_deductible || ' BRIEF ' || cur.brief ||
          ' TT_BRIEF ' || cur.tt_brief || ' INS_PRICE ' || cur.ins_price || ' INS_AMOUNT ' ||
          cur.ins_amount);
    
      IF cur.is_deductible = 1
         AND /* cur.brief = 'USD' and */
         cur.tt_brief = 'SSNG'
         AND cur.ins_price = 5000
      THEN
      
        SELECT ID INTO v_t_deductible_type_id FROM T_DEDUCTIBLE_TYPE WHERE brief = 'CONDITIONAL';
        SELECT ID INTO v_t_deduct_val_type_id FROM T_DEDUCT_VAL_TYPE WHERE brief = 'AMOUNT';
        v_deductible_value := 25;
      
      ELSIF cur.is_deductible = 1
            AND /* cur.brief = 'USD' and */
            cur.tt_brief IN ('RUCEN', 'RUOTH', 'ERF')
            AND cur.ins_price = 15000
      THEN
      
        SELECT ID INTO v_t_deductible_type_id FROM T_DEDUCTIBLE_TYPE WHERE brief = 'CONDITIONAL';
        SELECT ID INTO v_t_deduct_val_type_id FROM T_DEDUCT_VAL_TYPE WHERE brief = 'AMOUNT';
        v_deductible_value := 25;
      
      ELSIF cur.is_deductible = 1
            AND /* cur.brief = 'USD' and */
            cur.ins_price IN (15000, 30000, 50000)
      THEN
      
        SELECT ID INTO v_t_deductible_type_id FROM T_DEDUCTIBLE_TYPE WHERE brief = 'CONDITIONAL';
        SELECT ID INTO v_t_deduct_val_type_id FROM T_DEDUCT_VAL_TYPE WHERE brief = 'AMOUNT';
        v_deductible_value := 50;
      
      ELSIF cur.is_deductible = 0
      THEN
      
        SELECT ID INTO v_t_deductible_type_id FROM T_DEDUCTIBLE_TYPE WHERE brief = 'NONE';
        SELECT ID INTO v_t_deduct_val_type_id FROM T_DEDUCT_VAL_TYPE WHERE brief = 'PERCENT';
        v_deductible_value := 0;
      
      ELSE
      
        SELECT ID INTO v_t_deductible_type_id FROM T_DEDUCTIBLE_TYPE WHERE brief = 'NONE';
        SELECT ID INTO v_t_deduct_val_type_id FROM T_DEDUCT_VAL_TYPE WHERE brief = 'PERCENT';
        v_deductible_value := 0;
      
      END IF;
    
    END LOOP;
  
    LOG(p_p_cover_id
       ,'CALC_DEDUCT_VZR T_DEDUCTIBLE_TYPE_ID ' || v_t_deductible_type_id || ' T_DEDUCT_VAL_TYPE_ID ' ||
        v_t_deduct_val_type_id || ' DEDUCTIBLE_VALUE ' || v_deductible_value);
  
    UPDATE P_COVER
    --
       SET t_deductible_type_id = v_t_deductible_type_id
          ,t_deduct_val_type_id = v_t_deduct_val_type_id
          ,deductible_value     = v_deductible_value
    --
     WHERE P_COVER_ID = P_P_COVER_ID;
  
    RETURN v_deductible_value;
  
  END;

END;
/
