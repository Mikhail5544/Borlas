CREATE OR REPLACE PACKAGE pkg_TERM_tariff IS
  /*
   * Расчет брутто, нетто премии по покрытиям страхование жизни на срок
   * @author Marchuk A.
   * @version 1
   * @headcom
  */

  --  !TERM - страхование жизни на срок

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION TERM_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION TERM_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_age          Возраст застрахованного
   * @param p_gender_type  Пол застрахованного
   * @param p_period_year  Длительность страхования (в годах)
   * @param p_normrate     Норма доходности по выбранной программе покрытия
   * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
   * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
   * @param p_f            Нагрузка по договору страхования
   * @param p_deathrate_id ИД таблицы смертности
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION TERM_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_OnePayment_Property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_age          Возраст застрахованного
   * @param p_gender_type  Пол застрахованного
   * @param p_period_year  Длительность страхования (в годах)
   * @param p_normrate     Норма доходности по выбранной программе покрытия
   * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
   * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
   * @param p_f            Нагрузка по договору страхования
   * @param p_deathrate_id ИД таблицы смертности
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION TERM_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_OnePayment_Property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

/**
   * Расчет нетто по покрытию договора страхования жизни "кредитное страхование жизни (то же, что и TERM, другая ТС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_TERM_Tariff IS
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
    ,is_error_desc        VARCHAR2(200)
    ,is_in_waiting_period NUMBER
    ,number_of_payment    NUMBER);
  --
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

  /*
   * Расчет брутто, нетто премии по покрытию договора страхования жизни
   * @author Marchuk A.
   * @version 1
  */
  --

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
        (p_p_cover_id, SYSDATE, 'INS.PKG_PRDLIFECALC', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE error
  (
    p_p_cover_id   IN NUMBER
   ,p_message_date IN DATE
   ,p_message      IN VARCHAR2
  ) IS
    --  pragma AUTONOMOUS_TRANSACTION;
  BEGIN
    /*
         INSERT INTO p_cover_err_log
            (p_cover_id, message_date, message)
          VALUES
            (p_p_cover_id, p_message_date, p_message);
          commit;
    */
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

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
    DBMS_OUTPUT.PUT_LINE('GET_CALC_PARAM ID покрытия ' || v_cover_id);
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
      result.is_error      := 1;
      result.is_error_desc := 'Не определен тип застрахованного лица';
    END IF;
  
    --  Признак p_re_sign исключает возможность расчета тарифов при повышающих коэффициентах K и S
  
    SELECT pp.policy_id
          ,DECODE(p_re_sign, 1, LEAST(NVL(s_coef, 0), 0), NVL(s_coef, 0)) s_coef
          ,DECODE(p_re_sign, 1, LEAST(NVL(k_coef, 0), 0), NVL(k_coef, 0)) k_koef
          ,DECODE(p_re_sign, 1, LEAST(NVL(s_coef_m, 0), 0), NVL(s_coef_m, 0)) s_coef_m
          ,DECODE(p_re_sign, 1, LEAST(NVL(k_coef_m, 0), 0), NVL(k_coef_m, 0)) k_koef_m
          ,DECODE(p_re_sign, 1, LEAST(NVL(s_coef_nm, 0), 0), NVL(s_coef_nm, 0)) s_coef_nm
          ,DECODE(p_re_sign, 1, LEAST(NVL(k_coef_nm, 0), 0), NVL(k_coef_nm, 0)) k_koef_nm
           
          ,pc.rvb_value
          ,pc.normrate_value
          ,NVL(pc.insured_age, aa.insured_age) insured_age
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
      FROM t_payment_terms pt
          ,t_period        tp
          ,p_pol_header    ph
          ,p_policy        pp
          ,ven_as_assured  aa
          ,P_COVER         pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.ID = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.ID = pp.payment_term_id;
  
    --
    DBMS_OUTPUT.PUT_LINE('ID версии договора (полиса) ' || v_policy_id);
    DBMS_OUTPUT.PUT_LINE('Возраст застрахованного ' || v_age);
    IF v_age IS NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Возраст застрахованного не расчитан';
    END IF;
    --
    IF v_f IS NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('Нагрузка не найдена....Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Нагрузка не найдена';
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
      result.is_error      := 1;
      result.is_error_desc := 'Базовая нагрузка по договору не найдена';
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

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */
  FUNCTION TERM_add_ins_amount_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
  
    v_ax1n_p  NUMBER;
    v_ax1n_c  NUMBER;
    v_a_xn_c  NUMBER;
    v_a_xn_p  NUMBER;
    v_P_p     NUMBER;
    v_P_c     NUMBER;
    v_S_p     NUMBER;
    v_S_c     NUMBER;
    v_delta_S NUMBER;
    v_f       NUMBER;
    v_i       NUMBER;
    v_t       NUMBER;
    v_x       NUMBER;
    v_n       NUMBER;
    v_g       VARCHAR2(1);
  BEGIN
    v_i := calc_param_curr.NORMRATE;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --
    DBMS_OUTPUT.PUT_LINE('TERM_ADD_INS_AMOUNT_GET_BRUTTO Зафиксировано изменение только страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      v_ax1n_c  := ROUND(pkg_amath.Ax1n(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,calc_param_curr.k_coef
                                       ,calc_param_curr.s_coef
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,7);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,calc_param_curr.k_coef
                                       ,calc_param_curr.s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,7);
      v_S_p     := calc_param_prev.ins_amount;
      v_S_c     := calc_param_curr.ins_amount;
      v_delta_S := v_S_c - v_S_p;
      v_f       := calc_param_curr.f;
      v_P_p     := calc_param_prev.tariff_netto * v_S_p;
      DBMS_OUTPUT.PUT_LINE('v_ax1n_c ' || v_ax1n_c || ' v_a_xn_c ' || v_a_xn_c);
      v_P_c := v_P_p + v_delta_S * v_ax1n_c / v_a_xn_c;
    
      RESULT        := calc_param_curr;
      result.tariff := v_P_c / (v_S_c * (1 - v_f));
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p || ' v_P_c ' || v_P_c || ' tariff ' || result.tariff);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      v_ax1n_c := ROUND(pkg_amath.Ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_S_p    := calc_param_prev.ins_amount;
      v_S_c    := calc_param_curr.ins_amount;
      v_P_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_S_p, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_P_c := v_P_p + (v_S_c - v_S_p) * v_ax1n_c / v_a_xn_c;
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      RESULT        := calc_param_curr;
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - v_f)), 7);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения о изменении стр. суммы
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */
  FUNCTION TERM_add_ins_amount_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
  
    v_ax1n_p NUMBER;
    v_ax1n_c NUMBER;
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    v_P_p    NUMBER;
    v_P_c    NUMBER;
    v_S_p    NUMBER;
    v_S_c    NUMBER;
    v_f      NUMBER;
    v_i      NUMBER;
    v_t      NUMBER;
    v_x      NUMBER;
    v_n      NUMBER;
    v_g      VARCHAR2(1);
  BEGIN
    v_i := calc_param_curr.NORMRATE;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --
    DBMS_OUTPUT.PUT_LINE('TERM_ADD_INS_AMOUNT_GET_NETTO Зафиксировано изменение только страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      v_ax1n_c := ROUND(pkg_amath.Ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_S_p    := calc_param_prev.ins_amount;
      v_S_c    := calc_param_curr.ins_amount;
      v_f      := calc_param_curr.f;
      v_P_p    := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_P_c := v_P_p + (v_S_c - v_S_p) * v_ax1n_c / v_a_xn_c;
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      v_ax1n_c := ROUND(pkg_amath.Ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_S_p    := calc_param_prev.ins_amount;
      v_S_c    := calc_param_curr.ins_amount;
      v_P_p    := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_P_c := v_P_p + (v_S_c - v_S_p) * v_ax1n_c / v_a_xn_c;
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
    ELSE
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения изменение страховой премии
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION TERM_add_fee_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT     calc_param;
    v_ax1n_p   NUMBER;
    v_ax1n_c   NUMBER;
    v_a_xn_c   NUMBER;
    v_a_xn_p   NUMBER;
    v_P_p      NUMBER;
    v_P_c      NUMBER;
    v_S_p      NUMBER;
    v_S_c      NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_Gd       NUMBER;
    v_Gf_p     NUMBER;
    v_Gf_c     NUMBER;
    v_Pc       NUMBER;
    v_Pp       NUMBER;
  BEGIN
    v_i := calc_param_curr.NORMRATE;
    v_t := calc_param_curr.t;
    v_f := calc_param_curr.f;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --  Коэффициенты, нагружающие таблицы смертности
    v_k_coef_c := calc_param_curr.k_coef;
    v_s_coef_c := calc_param_curr.s_coef;
    --
    v_k_coef_p := calc_param_prev.k_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    --
    v_S_p := calc_param_prev.ins_amount;
    v_S_c := calc_param_curr.ins_amount;
    --
    v_Pc := pkg_tariff.calc_tarif_mul(calc_param_curr.p_cover_id);
    v_Pp := pkg_tariff.calc_tarif_mul(calc_param_prev.p_cover_id);
    --
    IF v_Pp != 0
    THEN
      v_Gf_p := calc_param_prev.fee / NVL(v_Pp, 1);
    ELSE
      v_Gf_p := NULL;
    END IF;
    --
    IF v_Pc != 0
    THEN
      v_Gf_c := calc_param_curr.fee / NVL(v_Pc, 1);
    ELSE
      v_Gf_c := NULL;
    END IF;
  
    DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение страховой премии');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение страховой премии (Периодическая оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_f      := calc_param_curr.f;
      v_P_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_S_p, 7);
      v_P_c    := v_Gf_c / (1 - v_f);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      v_S_c         := v_S_p + (v_P_c - v_P_c) * v_a_xn_c / v_ax1n_c;
      v_S_c         := ROUND(v_S_c, 7);
      RESULT        := calc_param_curr;
      result.tariff := ROUND(v_Gf_c / v_S_c, 7);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_f      := calc_param_curr.f;
      v_P_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_S_p, 7);
      v_P_c    := v_Gf_c / (1 - v_f);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      v_S_c         := v_S_p + (v_P_c / v_ax1n_c);
      v_S_c         := ROUND(v_S_c, 7);
      RESULT        := calc_param_curr;
      result.tariff := ROUND(v_Gf_c / v_S_c, 7);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения изменение страховой премии
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION TERM_add_fee_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT     calc_param;
    v_ax1n_p   NUMBER;
    v_ax1n_c   NUMBER;
    v_a_xn_c   NUMBER;
    v_a_xn_p   NUMBER;
    v_P_p      NUMBER;
    v_P_c      NUMBER;
    v_S_p      NUMBER;
    v_S_c      NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_Gd       NUMBER;
    v_Gf_p     NUMBER;
    v_Gf_c     NUMBER;
    v_Pc       NUMBER;
    v_Pp       NUMBER;
  BEGIN
    v_i := calc_param_curr.NORMRATE;
    v_t := calc_param_curr.t;
    v_f := calc_param_curr.f;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --  Коэффициенты, нагружающие таблицы смертности
    v_k_coef_c := calc_param_curr.k_coef;
    v_s_coef_c := calc_param_curr.s_coef;
    --
    v_k_coef_p := calc_param_prev.k_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    --
    v_S_p := calc_param_prev.ins_amount;
    v_S_c := calc_param_curr.ins_amount;
    --
    v_Pc := pkg_tariff.calc_tarif_mul(calc_param_curr.p_cover_id);
    v_Pp := pkg_tariff.calc_tarif_mul(calc_param_prev.p_cover_id);
    --
    IF v_Pp != 0
    THEN
      v_Gf_p := calc_param_prev.fee / NVL(v_Pp, 1);
    ELSE
      v_Gf_p := NULL;
    END IF;
    --
    IF v_Pc != 0
    THEN
      v_Gf_c := calc_param_curr.fee / NVL(v_Pc, 1);
    ELSE
      v_Gf_c := NULL;
    END IF;
  
    DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение страховой премии');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение страховой премии (Периодическая оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_f      := calc_param_curr.f;
      v_P_p    := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      v_P_c    := v_Gf_c / (1 - v_f);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      v_S_c               := v_S_p + (v_P_c - v_P_c) * v_a_xn_c / v_ax1n_c;
      v_S_c               := ROUND(v_S_c, 7);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_Gf_c * (1 - v_f) / v_S_c, 7);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      v_f      := calc_param_curr.f;
      v_P_p    := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      v_P_c    := v_Gf_c / (1 - v_f);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      v_S_c               := v_S_p + (v_P_c / v_ax1n_c);
      v_S_c               := ROUND(v_S_c, 7);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_Gf_c * (1 - v_f) / v_S_c, 7);
    ELSE
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения "Замена застрахованного"
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION TERM_add_assured_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT   calc_param;
    v_ax1n_c NUMBER;
    v_a_xn_c NUMBER;
    v_ax1n_p NUMBER;
    v_a_xn_p NUMBER;
    v_P_p    NUMBER;
    v_P_c    NUMBER;
    v_S_p    NUMBER;
    v_S_c    NUMBER;
    --
    v_s_coef_c NUMBER;
    v_s_coef_p NUMBER;
    v_k_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_g_p      VARCHAR2(1);
    v_g_c      VARCHAR2(1);
  BEGIN
    v_i   := calc_param_curr.NORMRATE;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_n   := calc_param_curr.period_year;
    v_g_c := calc_param_curr.gender_type;
    v_g_p := calc_param_prev.gender_type;
    v_S_p := calc_param_prev.ins_amount;
    v_S_c := calc_param_curr.ins_amount;
    --
    v_s_coef_c := calc_param_curr.s_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    v_k_coef_c := calc_param_curr.k_coef;
    v_k_coef_p := calc_param_prev.k_coef;
    --
    DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_S_c = v_S_p
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой сумме (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_S_p, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_P_c := ROUND(v_S_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_P_p * v_a_xn_p / v_a_xn_c, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_S_c = v_S_p
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой сумме (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_P_p         := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_S_p, 7);
      v_P_c         := ROUND(v_S_c * (v_ax1n_c - v_ax1n_p), 7);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой премии (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_S_p, 7);
      v_P_c := v_P_p;
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_S_c := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c) + v_P_p * (v_a_xn_c - v_a_xn_c) / v_ax1n_c, 7);
      DBMS_OUTPUT.PUT_LINE(' v_S_c ' || v_S_c);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_P_p         := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_S_p, 7);
      v_P_c         := v_P_p;
      v_S_c         := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c), 7);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения "Замена застрахованного"
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION TERM_add_assured_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT   calc_param;
    v_ax1n_c NUMBER;
    v_a_xn_c NUMBER;
    v_ax1n_p NUMBER;
    v_a_xn_p NUMBER;
    v_P_p    NUMBER;
    v_P_c    NUMBER;
    v_S_p    NUMBER;
    v_S_c    NUMBER;
    --
    v_s_coef_c NUMBER;
    v_s_coef_p NUMBER;
    v_k_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_g_p      VARCHAR2(1);
    v_g_c      VARCHAR2(1);
  BEGIN
    v_i   := calc_param_curr.NORMRATE;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_n   := calc_param_curr.period_year;
    v_g_c := calc_param_curr.gender_type;
    v_g_p := calc_param_prev.gender_type;
    v_S_p := calc_param_prev.ins_amount;
    v_S_c := calc_param_curr.ins_amount;
    --
    v_s_coef_c := calc_param_curr.s_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    v_k_coef_c := calc_param_curr.k_coef;
    v_k_coef_p := calc_param_prev.k_coef;
    --
    DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_S_c = v_S_p
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой сумме (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_S_p, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_P_c := ROUND(v_S_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_P_p * v_a_xn_p / v_a_xn_c, 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      result.tariff_netto := ROUND(v_P_c / v_S_c, 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_S_c = v_S_p
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой сумме (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_P_p               := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      v_P_c               := ROUND(v_S_c * (v_ax1n_c - v_ax1n_p), 7);
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой премии (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      v_P_c := v_P_p;
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      v_S_c := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c) + v_P_p * (v_a_xn_c - v_a_xn_c) / v_ax1n_c, 7);
      DBMS_OUTPUT.PUT_LINE(' v_S_c ' || v_S_c);
      result.tariff := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного при постоянной страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_P_p         := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      v_P_c         := v_P_p;
      v_S_c         := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c), 7);
      result.tariff := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result.tariff ' || result.tariff_netto);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения "Изменение срока"
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */
  FUNCTION TERM_add_period_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
    --
    v_ax1n_c NUMBER;
    v_ax1n_p NUMBER;
    --
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    --
    v_P_p NUMBER;
    v_P_c NUMBER;
    v_S_p NUMBER;
    v_S_c NUMBER;
    --
    v_f_c NUMBER;
    v_f_p NUMBER;
    --
    v_i NUMBER;
    v_t NUMBER;
    v_x NUMBER;
    --
    v_n_c NUMBER;
    v_n_p NUMBER;
    --
    v_g VARCHAR2(1);
  BEGIN
    v_i   := calc_param_curr.NORMRATE;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_g   := calc_param_curr.gender_type;
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    --
    v_S_p := calc_param_prev.ins_amount;
    v_S_c := calc_param_curr.ins_amount;
  
    v_f_p := calc_param_prev.f;
    v_f_c := calc_param_curr.f;
    --
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_S_p = v_S_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)');
      DBMS_OUTPUT.PUT_LINE('v_x + v_t ' || (v_x + v_t) || 'v_n_c - v_t ' || (v_n_c - v_t));
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      DBMS_OUTPUT.PUT_LINE('v_x + v_t ' || (v_x + v_t) || 'v_n_p - v_t ' || (v_n_p - v_t));
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - v_f_p) * v_S_p, 7);
    
      v_P_c := ROUND(v_S_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_P_p * (v_a_xn_p / v_a_xn_c), 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - v_f_c)), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_S_p = v_S_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата) ');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount, 7);
      v_S_p := calc_param_prev.ins_amount;
      v_S_c := calc_param_prev.ins_amount;
      v_P_c := ROUND(v_P_p + v_S_c * (v_ax1n_c - v_ax1n_p), 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount, 7);
      v_S_p := calc_param_prev.ins_amount;
      v_S_c := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c) + v_P_p * (v_a_xn_c - v_a_xn_p) / v_ax1n_c, 7);
      v_P_c := v_P_p;
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount, 7);
      v_S_p := calc_param_prev.ins_amount;
      v_S_c := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c), 7);
      v_P_c := v_P_p;
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      result.tariff := ROUND(v_P_c / (v_S_c * (1 - calc_param_curr.f)), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Условия расчета не описаны по алгоритму');
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения "Изменение срока"
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */
  FUNCTION TERM_add_period_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
    --
    v_ax1n_c NUMBER;
    v_ax1n_p NUMBER;
    --
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    --
    v_P_p NUMBER;
    v_P_c NUMBER;
    v_S_p NUMBER;
    v_S_c NUMBER;
    --
    v_f_c NUMBER;
    v_f_p NUMBER;
    --
    v_i NUMBER;
    v_t NUMBER;
    v_x NUMBER;
    --
    v_n_c NUMBER;
    v_n_p NUMBER;
    --
    v_g VARCHAR2(1);
  BEGIN
    v_i   := calc_param_curr.NORMRATE;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_g   := calc_param_curr.gender_type;
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    --
    v_S_p := calc_param_prev.ins_amount;
    v_S_c := calc_param_curr.ins_amount;
  
    v_f_p := calc_param_prev.f;
    v_f_c := calc_param_curr.f;
    --
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_S_p = v_S_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)');
      DBMS_OUTPUT.PUT_LINE('v_x + v_t ' || (v_x + v_t) || 'v_n_c - v_t ' || (v_n_c - v_t));
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      DBMS_OUTPUT.PUT_LINE('v_x + v_t ' || (v_x + v_t) || 'v_n_p - v_t ' || (v_n_p - v_t));
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
    
      v_P_c := ROUND(v_S_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_P_p * (v_a_xn_p / v_a_xn_c), 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_S_p = v_S_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата) ');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff_netto * calc_param_prev.ins_amount, 7);
      v_P_c := ROUND(v_P_p + v_S_c * (v_ax1n_c - v_ax1n_p), 7);
      DBMS_OUTPUT.PUT_LINE(' v_P_c ' || v_P_c);
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_a_xn_p ' || v_a_xn_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff_netto * v_S_p, 7);
      v_S_c := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c) + v_P_p * (v_a_xn_c - v_a_xn_p) / v_ax1n_c, 7);
      v_P_c := v_P_p;
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)
      DBMS_OUTPUT.PUT_LINE('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.NORMRATE)
                       ,7);
      DBMS_OUTPUT.PUT_LINE(' v_ax1n_p ' || v_ax1n_p);
      --
      v_P_p := ROUND(calc_param_prev.tariff_netto * calc_param_prev.ins_amount, 7);
      v_S_c := ROUND(v_S_p * (v_ax1n_p / v_ax1n_c), 7);
      v_P_c := v_P_p;
      DBMS_OUTPUT.PUT_LINE(' v_P_p ' || v_P_p);
      result.tariff_netto := ROUND(v_P_c / (v_S_c), 7);
      DBMS_OUTPUT.PUT_LINE(' result ' || result.tariff);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Условия расчета не описаны по алгоритму');
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --
  --
  /*
   * Расчет брутто тарифа по покрытию при наличии дополнительного соглашения
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION TERM_add_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_add_info add_info;
    --
    calc_result calc_param;
    RESULT      NUMBER;
    --
  BEGIN
    r_add_info        := get_add_info(p_cover_id);
    r_calc_param_prev := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
    r_calc_param_curr := get_calc_param(p_cover_id, p_re_sign);
    DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    DBMS_OUTPUT.PUT_LINE(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    DBMS_OUTPUT.PUT_LINE('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного ');
        --
        calc_result := TERM_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение срока страхования');
        --
        calc_result := TERM_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        --
        calc_result := TERM_add_ins_amount_get_brutto(r_calc_param_prev
                                                     ,r_calc_param_curr
                                                     ,r_add_info
                                                     ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        RESULT := NULL;
      ELSE
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        DBMS_OUTPUT.PUT_LINE(' result ' || RESULT);
      
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := TERM_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSIF r_add_info.is_period_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение срока страхования');
      
        calc_result := TERM_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение брутто взноса ...');
        calc_result := TERM_add_fee_get_brutto(r_calc_param_prev
                                              ,r_calc_param_curr
                                              ,r_add_info
                                              ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSE
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        DBMS_OUTPUT.PUT_LINE(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, 7);
  END;

  /**
   * Расчет нетто тарифа по покрытию при наличии дополнительного соглашения по "Первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION TERM_add_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_add_info add_info;
    --
    calc_result calc_param;
    RESULT      NUMBER;
    --
  BEGIN
    r_add_info        := get_add_info(p_cover_id);
    r_calc_param_prev := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
    r_calc_param_curr := get_calc_param(p_cover_id, p_re_sign);
    DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    DBMS_OUTPUT.PUT_LINE(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    DBMS_OUTPUT.PUT_LINE('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застрахованного ');
        --
        calc_result := TERM_add_assured_get_netto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение срока страхования');
        --
        calc_result := TERM_add_period_get_netto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        --
        calc_result := TERM_add_ins_amount_get_netto(r_calc_param_prev
                                                    ,r_calc_param_curr
                                                    ,r_add_info
                                                    ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        RESULT := NULL;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        DBMS_OUTPUT.PUT_LINE(' result ' || RESULT);
      
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := TERM_add_assured_get_netto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_period_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение срока страхования');
      
        calc_result := TERM_add_period_get_netto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение брутто взноса ...');
        calc_result := TERM_add_fee_get_netto(r_calc_param_prev
                                             ,r_calc_param_curr
                                             ,r_add_info
                                             ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        DBMS_OUTPUT.PUT_LINE(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        DBMS_OUTPUT.PUT_LINE(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, 7);
  END;

  /**
   * Расчет брутто тарифа по покрытию при наличии дополнительного соглашения по "Первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION TERM_GET_BRUTTO
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
  
    DBMS_OUTPUT.PUT_LINE('TERM_GET_BRUTTO');
  
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    DBMS_OUTPUT.PUT_LINE('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      DBMS_OUTPUT.PUT_LINE('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := TERM_add_get_brutto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      DBMS_OUTPUT.PUT_LINE('Найдено доп соглашение... Полис в андерайтинге ');
      --r_calc_param := get_calc_param (p_cover_id);
      --
      IF r_calc_param.is_error = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      RESULT := TERM_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.NORMRATE
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      DBMS_OUTPUT.PUT_LINE('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := TERM_get_brutto(r_calc_param.age
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.period_year
                                 ,r_calc_param.NORMRATE
                                 ,r_calc_param.s_coef
                                 ,r_calc_param.k_coef
                                 ,r_calc_param.f
                                 ,r_calc_param.deathrate_id
                                 ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      DBMS_OUTPUT.PUT_LINE('Обычный расчет ....');
      RESULT := TERM_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.NORMRATE
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
    
    END IF;
    RETURN RESULT;
  END;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION TERM_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
  
    DBMS_OUTPUT.PUT_LINE('TERM_GET_NETTO');
  
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    DBMS_OUTPUT.PUT_LINE('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      DBMS_OUTPUT.PUT_LINE('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := TERM_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      DBMS_OUTPUT.PUT_LINE('Найдено доп соглашение... Полис в андерайтинге ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      RESULT := TERM_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.NORMRATE
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      DBMS_OUTPUT.PUT_LINE('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := TERM_get_netto(r_calc_param.age
                                ,r_calc_param.gender_type
                                ,r_calc_param.period_year
                                ,r_calc_param.NORMRATE
                                ,r_calc_param.s_coef
                                ,r_calc_param.k_coef
                                ,r_calc_param.f
                                ,r_calc_param.deathrate_id
                                ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        DBMS_OUTPUT.PUT_LINE('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      DBMS_OUTPUT.PUT_LINE('Обычный расчет ....');
      RESULT := TERM_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.NORMRATE
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  
  END;

  /* Расчет брутто по покрытию договора страхования жизни по "страхование жизни на срок"
  * @author Marchuk A.
  * @param p_age          Возраст застрахованного
  * @param p_gender_type  Пол застрахованного
  * @param p_period_year  Длительность страхования (в годах)
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION TERM_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_OnePayment_Property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_P NUMBER;
    v_G NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_Ax1n NUMBER;
    v_axn1 NUMBER;
    --
    v_f    NUMBER;
    RESULT NUMBER;
  BEGIN
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    DBMS_OUTPUT.PUT_LINE('TERM_GET_BRUTTO age ' || p_age || ' period_year ' || p_period_year ||
                         ' k_coef ' || p_k_coef || ' s_coef ' || p_s_coef || ' normrate ' ||
                         p_normrate || ' f ' || p_f);
  
    v_a_xn := pkg_amath.a_xn(p_age
                            ,p_period_year
                            ,p_gender_type
                            ,p_k_coef
                            ,p_s_coef
                            ,1
                            ,p_deathrate_id
                            ,p_normrate);
    v_ax1n := pkg_amath.ax1n(p_age
                            ,p_period_year
                            ,p_gender_type
                            ,p_k_coef
                            ,p_s_coef
                            ,p_deathrate_id
                            ,p_normrate);
  
    DBMS_OUTPUT.PUT_LINE('a_xn ' || v_a_xn);
    DBMS_OUTPUT.PUT_LINE('v_ax1n ' || v_ax1n);
  
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_G := v_ax1n / (v_a_xn * (1 - p_f));
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_G := v_ax1n / (1 - p_f);
    END IF;
    dbms_output.put_line('f ' || p_f || ' G ' || v_G);
    --dbms_output.put_line ('p_OnePayment_Property '||p_OnePayment_Property||'-----------------');
    RESULT := v_G;
    RETURN RESULT;
  END;

  /* Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок"
  * @author Marchuk A.
  * @param p_age          Возраст застрахованного
  * @param p_gender_type  Пол застрахованного
  * @param p_period_year  Длительность страхования (в годах)
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION TERM_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_OnePayment_Property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_P NUMBER;
    v_G NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_Ax1n NUMBER;
    v_axn1 NUMBER;
    --
    v_f    NUMBER;
    RESULT NUMBER;
  BEGIN
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn := pkg_amath.a_xn(p_age
                            ,p_period_year
                            ,p_gender_type
                            ,p_k_coef
                            ,p_s_coef
                            ,1
                            ,p_deathrate_id
                            ,p_normrate);
    v_ax1n := pkg_amath.ax1n(p_age
                            ,p_period_year
                            ,p_gender_type
                            ,p_k_coef
                            ,p_s_coef
                            ,p_deathrate_id
                            ,p_normrate);
  
    DBMS_OUTPUT.PUT_LINE('a_xn ' || v_a_xn);
    DBMS_OUTPUT.PUT_LINE('v_ax1n ' || v_ax1n);
  
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_P := v_ax1n / v_a_xn;
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_P := v_ax1n;
    END IF;
    --dbms_output.put_line ('v_Lx '||v_Lx||' v_qx '||v_qx||' v_ax1n '||v_ax1n||' v_a_xn '||v_a_xn||' p_f '||p_f||' G '||v_G);
    --dbms_output.put_line ('p_OnePayment_Property '||p_OnePayment_Property||'-----------------');
    RESULT := v_P;
    RETURN RESULT;
  END;

END;
/
