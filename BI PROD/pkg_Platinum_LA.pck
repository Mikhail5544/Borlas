CREATE OR REPLACE PACKAGE pkg_Platinum_LA IS
  /*
   * Расчет значений нагрузки по договору продукт "Platinum_LA"
   * @author Marchuk A.
   * @version 1
  */

  /**
   * @Author Marchuk A
   * Функция расчета нагрузки для  смешанного страхования "END"
   * @p_n - срок страхования в годах
   * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION ReCalc_Value
  (
    p_result        IN NUMBER
   ,p_discount_f_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Функция расчета нагрузки для  смешанного страхования "END"
  * @Author Marchuk A
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION DD_calc_loading(p_p_cover_id IN NUMBER) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_Platinum_LA IS
  --@Author Marchuk A
  --
  --Риски:
  --  END - смешанное страхование
  --  PEPR - страхование на дожитие с возвратом взносов
  --  TERM - страхование жизни на срок
  --  CRI  - кредитное страхование жизни (то же, что и TERM, другая ТС)
  --  DD - первичное диагностирование смертельно опасного заболевания
  --  WOP - освобождение от уплаты страховых взносов
  --  PWOP - защита страховых взносов
  --  I - инвест
  --
  --  [Accident]:
  --  AD      - смерть НС
  --  Dism    - телесные повреждения в результате НС
  --  Adis    - инвалидность в результате НС
  --  TPD     - инвалидность по любой причине (НС + болезнь)
  --  ATD     - временная нетрудоспособность в результате НС
  --  H       - госпитализация в результате НС

  TYPE calc_param IS RECORD(
     p_cover_id           NUMBER
    ,age                  NUMBER
    ,gender_type          VARCHAR2(1)
    ,assured_contact_id   NUMBER
    ,period_year          NUMBER
    ,s_coef_m             NUMBER
    ,s_coef_nm            NUMBER
    ,s_coef               NUMBER
    ,k_coef_m             NUMBER
    ,k_coef_nm            NUMBER
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
    ,number_of_payment    NUMBER);

  TYPE add_info IS RECORD(
     p_cover_id_prev            NUMBER
    ,p_cover_id_curr            NUMBER
    ,is_add_found               NUMBER(1)
    ,policy_id_prev             NUMBER
    ,policy_id_curr             NUMBER
    ,contact_id_prev            NUMBER
    ,contact_id_curr            NUMBER
    ,is_assured_change          NUMBER(1)
    ,ins_amount_prev            NUMBER
    ,ins_amount_curr            NUMBER
    ,is_ins_amount_change       NUMBER(1)
    ,fee_prev                   NUMBER
    ,fee_curr                   NUMBER
    ,is_fee_change              NUMBER(1)
    ,f_prev                     NUMBER
    ,f_curr                     NUMBER
    ,payment_terms_id_prev      NUMBER
    ,payment_terms_id_curr      NUMBER
    ,is_payment_terms_id_change NUMBER(1)
    ,period_id_prev             NUMBER
    ,period_id_curr             NUMBER
    ,is_period_change           NUMBER(1)
    ,is_one_payment_prev        NUMBER(1)
    ,is_one_payment_curr        NUMBER(1)
    ,is_periodical_change       NUMBER(1)
    ,ins_fund_id_curr           NUMBER
    ,ins_fund_id_prev           NUMBER
    ,is_fund_id_change          NUMBER(1)
    ,is_underwriting            NUMBER(1));

  FUNCTION get_calc_param
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN calc_param IS
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
    v_s_coef_m         NUMBER;
    v_k_coef_m         NUMBER;
    v_s_coef_nm        NUMBER;
    v_k_coef_nm        NUMBER;
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
      FROM ven_cn_person  vcp
          ,ven_contact    vc
          ,ven_as_assured vas
          ,P_COVER        pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND vas.as_assured_id = pc.as_asset_id
       AND vc.contact_id(+) = vas.assured_contact_id
       AND vcp.contact_id(+) = vc.contact_id;
    --
    DBMS_OUTPUT.PUT_LINE('ID застрахованного ' || v_as_assured_id);
    IF v_gender_type IS NULL
    THEN
      result.is_error := 1;
    END IF;
  
    --  Признак p_re_sign исключает возможность расчета тарифов при повышающих коэффициентах K и S
  
    SELECT pp.policy_id
          ,DECODE(p_re_sign, 1, LEAST(NVL(s_coef, 0), 0), NVL(s_coef, 0)) s_coef
          ,DECODE(p_re_sign, 1, LEAST(NVL(k_coef, 0), 0), NVL(k_coef, 0)) k_koef
          ,DECODE(p_re_sign, 1, LEAST(NVL(s_coef_m, 0), 0), NVL(s_coef_m, 0)) s_coef_m
          ,DECODE(p_re_sign, 1, LEAST(NVL(k_coef_m, 0), 0), NVL(k_coef_m, 0)) k_koef_m
          ,DECODE(p_re_sign, 1, LEAST(NVL(s_coef_nm, 0), 0), NVL(s_coef_nm, 0)) s_coef_nm
          ,DECODE(p_re_sign, 1, LEAST(NVL(k_coef_nm, 0), 0), NVL(k_coef_nm, 0)) k_koef_nm
           
          ,rvb_value
          ,normrate_value
          ,NVL(pc.insured_age, ven_as_assured.insured_age) insured_age
          ,pc.tariff
          ,pc.tariff_netto
          ,pc.fee
          ,pc.ins_amount
          ,pc.premia_base_type
           --         , ven_p_policy.discount_f_id, decode (ven_t_period.period_value, null, trunc(months_between(ven_p_policy.end_date, ph.start_date)/12), ven_t_period.period_value)
          ,pp.discount_f_id
          ,TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,ph.fund_id
          ,pp.start_date
          ,ph.start_date
          ,pt.number_of_payments
          ,pt.ID
          ,DECODE(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pkg_policy.is_in_waiting_period(pp.policy_id, pp.waiting_period_id, pp.start_date) is_in_waiting_period
      INTO v_policy_id
          ,v_s_coef
          ,v_k_coef
          ,v_s_coef_m
          ,v_k_coef_m
          ,v_s_coef_nm
          ,v_k_coef_nm
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
      FROM ven_t_payment_terms pt
          ,ven_t_period
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_assured
          ,P_COVER             pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND ven_as_assured.as_assured_id = pc.as_asset_id
       AND pp.policy_id = ven_as_assured.p_policy_id
       AND ven_t_period.ID = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.ID = pp.payment_term_id;
  
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
          ,DECODE(lr.func_id
                 ,NULL
                 ,lr.deathrate_id
                 ,Pkg_Tariff_Calc.calc_fun(lr.func_id, Ent.id_by_brief('P_COVER'), v_cover_id))
      INTO v_lob_line_id
          ,v_deathrate_id
      FROM ven_t_lob_line         ll
          ,ven_t_prod_line_rate   lr
          ,ven_t_product_line
          ,ven_t_prod_line_option
          ,ven_p_cover
     WHERE 1 = 1
       AND ven_p_cover.p_cover_id = v_cover_id
       AND ven_t_prod_line_option.ID = ven_p_cover.t_prod_line_option_id
       AND ven_t_product_line.ID = ven_t_prod_line_option.product_line_id
       AND ll.t_lob_line_id = ven_t_product_line.t_lob_line_id
       AND lr.product_line_id(+) = ven_t_product_line.ID;
    --
    DBMS_OUTPUT.PUT_LINE('ID страховой программы ' || v_lob_line_id);
    DBMS_OUTPUT.PUT_LINE('Количество платежей в год ' || v_number_of_payment);
    DBMS_OUTPUT.PUT_LINE('Код валюты ответственности ' || v_fund_id);
    --
    DBMS_OUTPUT.PUT_LINE('Установленная норма доходности для "страховой программы" ' || v_normrate);
    DBMS_OUTPUT.PUT_LINE('v_f = ' || v_f);
    DBMS_OUTPUT.PUT_LINE('deathrate_id = ' || v_deathrate_id);
    --
    result.age                  := v_age;
    result.gender_type          := v_gender_type;
    result.assured_contact_id   := v_assured_contact_id;
    result.period_year          := v_period_year;
    result.s_coef               := v_s_coef;
    result.k_coef               := v_k_coef;
    result.s_coef_m             := v_s_coef_m;
    result.k_coef_m             := v_k_coef_m;
    result.s_coef_nm            := v_s_coef_nm;
    result.k_coef_nm            := v_k_coef_nm;
    result.f                    := v_f;
    result.t                    := TRUNC(MONTHS_BETWEEN(v_policy_start_date, v_header_start_date) / 12);
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
    --
    RETURN RESULT;
    --
  END;

  FUNCTION get_add_info(p_cover_id IN NUMBER) RETURN add_info IS
    -- Курсор для определения доп. соглашения
    CURSOR c_prev_version(p_p_cover_id IN NUMBER) IS
      SELECT p_cover_id_prev
            ,p_cover_id_curr
            ,is_add_found
            ,policy_id_prev
            ,policy_id_curr
            ,contact_id_prev
            ,contact_id_curr
            ,is_assured_change
            ,ins_amount_prev
            ,ins_amount_curr
            ,is_ins_amount_change
            ,fee_prev
            ,fee_curr
            ,is_fee_change
            ,f_prev
            ,f_curr
            ,payment_terms_id_prev
            ,payment_terms_id_curr
            ,is_payment_terms_id_change
            ,period_id_prev
            ,period_id_curr
            ,is_period_change
            ,is_one_payment_prev
            ,is_one_payment_curr
            ,is_periodical_change
            ,DECODE(doc.get_doc_status_brief(policy_id_prev), 'UNDERWRITING', 1, 0) is_underwriting
        FROM v_p_cover_life_add
       WHERE 1 = 1
         AND p_cover_id_curr = p_p_cover_id;
    --
    r_prev_version c_prev_version%ROWTYPE;
    --
    RESULT add_info;
  BEGIN
    OPEN c_prev_version(p_cover_id);
    FETCH c_prev_version
      INTO r_prev_version;
    -- При отсутствии предыдущей версии покрытия искуственно указываем, что это первая версия
    result.p_cover_id_prev := NVL(r_prev_version.p_cover_id_prev, p_cover_id);
    result.p_cover_id_curr := NVL(r_prev_version.p_cover_id_curr, p_cover_id);
    --
    result.is_add_found               := r_prev_version.is_add_found;
    result.policy_id_prev             := r_prev_version.policy_id_prev;
    result.policy_id_curr             := r_prev_version.policy_id_curr;
    result.contact_id_prev            := r_prev_version.contact_id_prev;
    result.contact_id_curr            := r_prev_version.contact_id_curr;
    result.is_assured_change          := r_prev_version.is_assured_change;
    result.ins_amount_prev            := r_prev_version.ins_amount_prev;
    result.ins_amount_curr            := r_prev_version.ins_amount_curr;
    result.is_ins_amount_change       := r_prev_version.is_ins_amount_change;
    result.fee_prev                   := r_prev_version.fee_prev;
    result.fee_curr                   := r_prev_version.fee_curr;
    result.is_fee_change              := r_prev_version.is_fee_change;
    result.f_prev                     := r_prev_version.f_prev;
    result.f_curr                     := r_prev_version.f_curr;
    result.payment_terms_id_prev      := r_prev_version.payment_terms_id_prev;
    result.payment_terms_id_curr      := r_prev_version.payment_terms_id_curr;
    result.is_payment_terms_id_change := r_prev_version.is_payment_terms_id_change;
    result.period_id_prev             := r_prev_version.period_id_prev;
    result.period_id_curr             := r_prev_version.period_id_curr;
    result.is_period_change           := r_prev_version.is_period_change;
    result.is_one_payment_prev        := r_prev_version.is_one_payment_prev;
    result.is_one_payment_curr        := r_prev_version.is_one_payment_curr;
    result.is_periodical_change       := r_prev_version.is_periodical_change;
    result.is_underwriting            := r_prev_version.is_underwriting;
    --
    RETURN RESULT;
    --
  END;

  -- @Author Marchuk A
  --Функция расчета нагрузки для  смешанного страхования "END"
  --@p_n - срок страхования в годах
  --@p_OnePayment - единовременный платеж (True) или периодический (False)

  FUNCTION ReCalc_Value
  (
    p_result        IN NUMBER
   ,p_discount_f_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT  NUMBER;
    v_value NUMBER;
    v_brief VARCHAR2(200);
  BEGIN
    DBMS_OUTPUT.PUT_LINE('RECALC_VALUE p_result ' || p_result || ' p_discount_f_id ' ||
                         p_discount_f_id);
    --
    SELECT VALUE INTO v_brief FROM ins.discount_f df WHERE df.discount_f_id = p_discount_f_id;
  
    DBMS_OUTPUT.PUT_LINE('RECALC_VALUE brief ' || v_brief);
    --
    IF INSTR(v_brief, '%') > 1
    THEN
      v_brief := REPLACE(v_brief, '%', '');
      v_value := TO_NUMBER(v_brief);
      IF v_value > 0
      THEN
        IF v_value < 100
        THEN
          RESULT := p_result * (1 + v_value / 100);
        ELSIF v_value >= 100
        THEN
          RESULT := NULL;
        ELSE
          RESULT := NULL;
        END IF;
      ELSE
        IF ABS(v_value) < 100
        THEN
          RESULT := p_result * (1 + v_value / 100);
        ELSIF v_value >= 100
        THEN
          RESULT := NULL;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    ELSIF v_brief IS NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('RECALC_VALUE базовая нагрузка');
      RESULT := p_result;
    ELSE
      DBMS_OUTPUT.PUT_LINE('RECALC_VALUE Нагрузка константа ' || v_brief);
      RESULT := TO_NUMBER(v_brief);
    END IF;
  
    DBMS_OUTPUT.PUT_LINE('RECALC_VALUE result ' || RESULT);
    RETURN RESULT;
  END;

  FUNCTION DD_calc_loading(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT      NUMBER;
    v_brief     VARCHAR2(200);
    r_add_info  add_info;
    cover_param calc_param;
  
    l_p_policy_id         NUMBER;
    l_p_cover_id          NUMBER;
    l_start_date          DATE;
    l_status_policy_brief VARCHAR2(2000);
  BEGIN
    DBMS_OUTPUT.PUT_LINE('END_GET_VALUE ');
    /* Определяем ИД договра для текущего покрытия*/
    SELECT aa.p_policy_id
          ,pp.start_date
      INTO l_p_policy_id
          ,l_start_date
      FROM p_policy pp
          ,as_asset aa
     WHERE aa.as_asset_id = (SELECT as_asset_id FROM p_cover WHERE p_cover_id = p_p_cover_id)
       AND pp.policy_id = aa.p_policy_id;
  
    DBMS_OUTPUT.PUT_LINE('l_p_policy_id ' || l_p_policy_id || ' l_start_date ' || l_start_date);
  
    /* Определяем статус версии догвовора*/
    l_status_policy_brief := doc.get_doc_status_brief(l_p_policy_id, SYSDATE);
  
    DBMS_OUTPUT.PUT_LINE('status_policy_brief ' || l_status_policy_brief);
  
    SELECT pc_b.p_cover_id
      INTO l_p_cover_id --p_cover Основоной программы
      FROM ven_t_product_line_type plt
          ,ven_t_lob_line          ll
          ,ven_t_product_line      pl
          ,ven_t_prod_line_option  plo
          ,ven_p_cover             pc_b
          ,ven_p_cover             pc_a
     WHERE 1 = 1
       AND pc_a.p_cover_id = p_p_cover_id
       AND pc_b.as_asset_id = pc_a.as_asset_id
       AND pc_b.p_cover_id != pc_a.p_cover_id
       AND plo.ID = pc_b.t_prod_line_option_id
       AND pl.ID = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life')
       AND plt.product_line_type_id = pl.product_line_type_id
       AND plt.brief = 'RECOMMENDED';
  
    IF l_status_policy_brief = 'INDEXATING'
    THEN
      r_add_info := get_add_info(l_p_cover_id);
      RESULT     := r_add_info.f_prev;
    ELSE
      cover_param := get_calc_param(l_p_cover_id);
      RESULT      := cover_param.f;
    END IF;
  
    RETURN RESULT;
    --
  END;
  --
END;
/
