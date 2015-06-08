CREATE OR REPLACE PACKAGE PKG_XX11_UNDERWR_CONTROL IS

  FUNCTION ins_amount_control(p_p_cover_id NUMBER) RETURN NUMBER;

END PKG_XX11_UNDERWR_CONTROL;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX11_UNDERWR_CONTROL IS

  G_DEBUG BOOLEAN := FALSE;

  TYPE calc_param IS RECORD(
     p_cover_id           NUMBER
    ,age                  NUMBER
    ,gender_type          VARCHAR2(1)
    ,assured_contact_id   NUMBER
    ,period_year          NUMBER
    ,s_coef               NUMBER
    ,k_coef               NUMBER
    ,f                    NUMBER
    ,t                    NUMBER
    ,NORMRATE             NUMBER
    ,deathrate_id         NUMBER
    ,payment_terms_id     NUMBER
    ,tariff               NUMBER
    ,tariff_netto         NUMBER
    ,fee                  NUMBER
    ,as_assured_id        NUMBER
    ,ins_amount           NUMBER
    ,payment_base_type    NUMBER
    ,premia_base_type     NUMBER(1)
    ,is_one_payment       NUMBER
    ,is_error             NUMBER
    ,is_in_waiting_period NUMBER
    ,number_of_payment    NUMBER
    ,fund_brief           VARCHAR2(30)
    ,ll_brief             VARCHAR2(30));

  FUNCTION get_calc_param(p_cover_id IN NUMBER) RETURN calc_param IS
    --
    v_cover_id    NUMBER;
    v_age         NUMBER;
    v_period_year NUMBER;
    --
    v_as_assured_id NUMBER;
    v_lob_line_id   NUMBER;
    v_policy_id     NUMBER;
    --
    v_fund_id  NUMBER;
    v_normrate NUMBER;
    v_d_notice DATE;
    --
    v_header_start_date DATE;
    v_policy_start_date DATE;
    v_number_of_payment NUMBER;
    v_payment_terms_id  NUMBER;
    --
    v_deathrate_id       NUMBER;
    v_discount_f_id      NUMBER;
    v_gender_type        VARCHAR2(1);
    v_assured_contact_id NUMBER;
    --
    v_s_coef           NUMBER;
    v_k_coef           NUMBER;
    v_f                NUMBER;
    v_premia_base_type NUMBER;
    --
    v_ins_amount           NUMBER;
    v_tariff               NUMBER;
    v_tariff_netto         NUMBER;
    v_fee                  NUMBER;
    v_is_in_waiting_period NUMBER;
    --
    RESULT calc_param;
  BEGIN
    result.p_cover_id := p_cover_id;
    v_cover_id        := p_cover_id;
    --
    DBMS_OUTPUT.PUT_LINE('ID покрытия ' || v_cover_id);
    SELECT vas.as_assured_id
          ,DECODE(NVL(vcp.gender, vas.gender), 0, 'w', 1, 'm') gender_type
          ,assured_contact_id
      INTO v_as_assured_id
          ,v_gender_type
          ,v_assured_contact_id
      FROM CN_PERSON  vcp
          ,CONTACT    vc
          ,AS_ASSURED vas
          ,P_COVER    vpc
     WHERE 1 = 1
       AND vpc.p_cover_id = v_cover_id
       AND vas.as_assured_id = vpc.as_asset_id
       AND vc.contact_id(+) = vas.assured_contact_id
       AND vcp.contact_id(+) = vc.contact_id;
    --
    DBMS_OUTPUT.PUT_LINE('ID застрахованного ' || v_as_assured_id);
    IF v_gender_type IS NULL
    THEN
      result.is_error := 1;
    END IF;
  
    --
    SELECT pp.policy_id
          ,NVL(s_coef, 0) s_coef
          ,NVL(k_coef, 0) k_koef
          ,rvb_value
          ,normrate_value
          ,NVL(pc.insured_age, pc.insured_age) insured_age
          ,pc.tariff
          ,pc.tariff_netto
          ,pc.fee
          ,pc.ins_amount
          ,pc.premia_base_type
          ,pp.discount_f_id
          ,TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,ph.fund_id
          ,pp.start_date
          ,ph.start_date
          ,pt.number_of_payments
          ,pt.ID
          ,DECODE(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pkg_policy.is_in_waiting_period(pp.policy_id, pp.waiting_period_id, pp.start_date) is_in_waiting_period
          ,f.brief fund_brief
      INTO v_policy_id
          ,v_s_coef
          ,v_k_coef
          ,v_f
          ,v_normrate
          ,v_age
          ,v_tariff
          ,v_tariff_netto
          ,v_fee
          ,v_ins_amount
          ,v_premia_base_type
          ,v_discount_f_id
          ,v_period_year
          ,v_fund_id
          ,v_policy_start_date
          ,v_header_start_date
          ,v_number_of_payment
          ,v_payment_terms_id
          ,result.is_one_payment
          ,v_is_in_waiting_period
          ,result.fund_brief
      FROM T_PAYMENT_TERMS pt
          ,T_PERIOD        tp
          ,FUND            f
          ,P_POL_HEADER    ph
          ,P_POLICY        pp
          ,AS_ASSET        aa
          ,P_COVER         pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.ID = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.ID = pp.payment_term_id
       AND f.fund_id = ph.fund_id;
    --
    DBMS_OUTPUT.PUT_LINE('ID версии договора (полиса) ' || v_policy_id);
    DBMS_OUTPUT.PUT_LINE('Возраст застрахованного ' || v_age);
    IF v_age IS NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    IF v_f IS NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('Нагрузка не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    /*
        if v_normrate is null then
          dbms_output.put_line ('Норма доходности не найдена....Устанавливаем флаг ошибки ');
          result.is_error := 1;
          return  result;
        end if;
    */
    --
    DBMS_OUTPUT.PUT_LINE('ID discount_f= ' || v_discount_f_id);
    --
    IF v_discount_f_id IS NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('Базовая нагрузка по договору не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    DBMS_OUTPUT.PUT_LINE('Срок действия договора ' || TO_CHAR(v_period_year));
    --
    SELECT ll.t_lob_line_id
          ,lr.deathrate_id
          ,ll.brief
      INTO v_lob_line_id
          ,v_deathrate_id
          ,result.ll_brief
      FROM T_LOB_LINE         ll
          ,T_PROD_LINE_RATE   lr
          ,T_PRODUCT_LINE     pl
          ,T_PROD_LINE_OPTION plo
          ,P_COVER            pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pl.ID = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND lr.product_line_id(+) = pl.ID;
    --
    DBMS_OUTPUT.PUT_LINE('ID страховой программы ' || v_lob_line_id);
    DBMS_OUTPUT.PUT_LINE('Количество платежей в год ' || v_number_of_payment);
    DBMS_OUTPUT.PUT_LINE('Код валюты ответственности ' || v_fund_id);
    --
    DBMS_OUTPUT.PUT_LINE('Установленная норма доходности для "страховой программы" ' || v_normrate);
    DBMS_OUTPUT.PUT_LINE('v_f = ' || v_f);
    DBMS_OUTPUT.PUT_LINE('deathrate_id = ' || v_deathrate_id);
    --
    result.age                := v_age;
    result.gender_type        := v_gender_type;
    result.assured_contact_id := v_assured_contact_id;
    result.period_year        := v_period_year;
    result.s_coef             := v_s_coef;
    result.k_coef             := v_k_coef;
    result.f                  := v_f;
    result.t                  := TRUNC(MONTHS_BETWEEN(v_policy_start_date, v_header_start_date) / 12);
    DBMS_OUTPUT.PUT_LINE('v_policy_start_date = ' || v_policy_start_date);
    DBMS_OUTPUT.PUT_LINE('v_header_start_date = ' || v_header_start_date);
    DBMS_OUTPUT.PUT_LINE('result.t = ' || result.t);
    result.deathrate_id         := v_deathrate_id;
    result.NORMRATE             := v_normrate;
    result.tariff               := v_tariff;
    result.tariff_netto         := v_tariff_netto;
    result.fee                  := v_fee;
    result.ins_amount           := v_ins_amount;
    result.as_assured_id        := v_as_assured_id;
    result.payment_terms_id     := v_payment_terms_id;
    result.premia_base_type     := v_premia_base_type;
    result.is_in_waiting_period := v_is_in_waiting_period;
    result.number_of_payment    := v_number_of_payment;
    result.fund_brief           := result.fund_brief;
    --
    RETURN RESULT;
    --
  END;

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
        (p_p_cover_id, SYSDATE, 'INS.PKG_XX11_UNDERWR_CONTROL', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION ins_amount_control(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    r_calc_param calc_param;
  BEGIN
    LOG(p_p_cover_id, 'INS_AMOUNT_CONTROL');
  
    r_calc_param := get_calc_param(p_p_cover_id);
  
    IF r_calc_param.ins_amount < 10000
       AND r_calc_param.fund_brief = 'RUR'
    THEN
    
      LOG(p_p_cover_id, 'PKG_COVER.EXCLUDE_COVER');
      pkg_cover.exclude_cover(p_p_cover_id);
    
    ELSIF r_calc_param.ins_amount < 400
          AND r_calc_param.fund_brief = 'USD'
    THEN
      LOG(p_p_cover_id, 'PKG_COVER.EXCLUDE_COVER');
      pkg_cover.exclude_cover(p_p_cover_id);
    
    ELSIF r_calc_param.ins_amount < 250
          AND r_calc_param.fund_brief = 'EUR'
    THEN
    
      LOG(p_p_cover_id, 'PKG_COVER.EXCLUDE_COVER');
      pkg_cover.exclude_cover(p_p_cover_id);
    
    END IF;
  
    RETURN 1;
  
  END;

END;
/
