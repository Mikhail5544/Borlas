CREATE OR REPLACE PACKAGE pkg_prdlifeloading IS
  /*
   * Расчет значений нагрузки по договору страхования жизни
   * @author Marchuk A.
   * @version 1
  */

  /**
   * @Author Marchuk A
   * Функция расчета нагрузки для  смешанного страхования "END"
   * @p_n - срок страхования в годах
   * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION recalc_value
  (
    p_result        IN NUMBER
   ,p_discount_f_id IN NUMBER
  ) RETURN NUMBER;

  /**
  *@Author Marchuk A
  * Функция расчета нагрузки для  смешанного страхования "END"
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION end_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_f_id     IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Функция расчета нагрузки для  смешанного страхования "END"
  * @Author Marchuk A
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION end_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  *Расчет нагрузки по "программе "страхование на дожитие с возвратом взносов"
  * @Author Marchuk A
  *@p_n - срок страхования в годах
  *@p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION pepr_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_id       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Расчет нагрузки по "программе "страхование на дожитие с возвратом взносов"
  * @Author Marchuk A
  * Функция расчета нагрузки для  смешанного страхования "END"
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION pepr_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "Пожизненное страхование"
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */
  FUNCTION wl_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER;

  /**
  * Расчет нагрузки по "программе "Пожизненное страхование"
  * @Author Marchuk A
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION wl_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "страхование на срок"
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION term_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_id       IN NUMBER
  ) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "страхование на срок"
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION term_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе кредитное страхование жизни (то же, что и TERM, другая ТС)
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION cri_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "кредитное страхование жизни (то же, что и TERM, другая ТС)
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION cri_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "первичное диагностирование смертельно опасного заболевания
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION dd_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_id       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "первичное диагностирование смертельно опасного заболевания
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION dd_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "освобождение от уплаты страховых взносов
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION wop_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "освобождение от уплаты страховых взносов
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION wop_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "Инвест"
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION invest_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "Инвест"
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION invest_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "НС"
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION accident_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER;

  /**
  * @Author Marchuk A
  * Расчет нагрузки по программе "НС"
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION accident_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * @Author Veselek
  * Расчет нагрузки по программе "Инвест-Резерв"
  * @p_n - срок страхования в годах
  * @p_OnePayment - единовременный платеж (True) или периодический (False)
  */

  FUNCTION investreserve_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER;

  /**
  * @Author Veselek
  * Расчет нагрузки по программе "Инвест-Резерв"
  * @p_p_cover_id - ИД покрытия
  */

  FUNCTION investreserve_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER;
  /**
  * Расчет нагрузки для продукта Защита Экспресс
  */
  FUNCTION accexp167_get_value(par_cover_id NUMBER) RETURN NUMBER;

  /**
  * Расчет нагрузки для продукта Уверенный старт
  */
  FUNCTION strong_start_get_value(par_cover_id NUMBER) RETURN NUMBER;

  /**
    Капля П.
    Функция определения нагрузки для продуктов серии CR104
  */
  FUNCTION cr104_get_value(par_cover_id NUMBER) RETURN NUMBER;

  /*
    Капля П.
    Нагрузка для Инвестора с ед. ф. оплаты
  */
  FUNCTION investor_lump_get_velue(par_cover_id NUMBER) RETURN NUMBER;

  /**
  * Расчет нагрузки для продукта Защита Экспресс (junior)
  */
  FUNCTION accexp168_get_value(par_cover_id NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_prdlifeloading IS
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
    ,normrate             NUMBER
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

  FUNCTION get_discount_brief(par_discount_f_id discount_f.discount_f_id%TYPE)
    RETURN discount_f.brief%TYPE IS
    v_discount_brief discount_f.brief%TYPE;
  BEGIN
    SELECT brief INTO v_discount_brief FROM discount_f d WHERE d.discount_f_id = par_discount_f_id;
    RETURN v_discount_brief;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_discount_brief;

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
    dbms_output.put_line('ID покрытия ' || v_cover_id);
    SELECT vas.as_assured_id
          ,decode(nvl(vcp.gender, vas.gender), 0, 'w', 1, 'm') gender_type
          ,assured_contact_id
      INTO v_as_assured_id
          ,v_gender_type
          ,v_assured_contact_id
      FROM ven_cn_person  vcp
          ,ven_contact    vc
          ,ven_as_assured vas
          ,p_cover        pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND vas.as_assured_id = pc.as_asset_id
       AND vc.contact_id(+) = vas.assured_contact_id
       AND vcp.contact_id(+) = vc.contact_id;
    --
    dbms_output.put_line('ID застрахованного ' || v_as_assured_id);
    IF v_gender_type IS NULL
    THEN
      result.is_error := 1;
    END IF;
  
    --  Признак p_re_sign исключает возможность расчета тарифов при повышающих коэффициентах K и S
  
    SELECT pp.policy_id
          ,decode(p_re_sign, 1, least(nvl(s_coef, 0), 0), nvl(s_coef, 0)) s_coef
          ,decode(p_re_sign, 1, least(nvl(k_coef, 0), 0), nvl(k_coef, 0)) k_koef
          ,decode(p_re_sign, 1, least(nvl(s_coef_m, 0), 0), nvl(s_coef_m, 0)) s_coef_m
          ,decode(p_re_sign, 1, least(nvl(k_coef_m, 0), 0), nvl(k_coef_m, 0)) k_koef_m
          ,decode(p_re_sign, 1, least(nvl(s_coef_nm, 0), 0), nvl(s_coef_nm, 0)) s_coef_nm
          ,decode(p_re_sign, 1, least(nvl(k_coef_nm, 0), 0), nvl(k_coef_nm, 0)) k_koef_nm
           
          ,rvb_value
          ,normrate_value
          ,nvl(pc.insured_age, ven_as_assured.insured_age) insured_age
          ,pc.tariff
          ,pc.tariff_netto
          ,pc.fee
          ,pc.ins_amount
          ,pc.premia_base_type
           --         , ven_p_policy.discount_f_id, decode (ven_t_period.period_value, null, trunc(months_between(ven_p_policy.end_date, ph.start_date)/12), ven_t_period.period_value)
          ,pp.discount_f_id
          ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,ph.fund_id
          ,pp.start_date
          ,ph.start_date
          ,pt.number_of_payments
          ,pt.id
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
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
          ,p_cover             pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND ven_as_assured.as_assured_id = pc.as_asset_id
       AND pp.policy_id = ven_as_assured.p_policy_id
       AND ven_t_period.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
  
    --
    dbms_output.put_line('ID версии договора (полиса) ' || v_policy_id);
    dbms_output.put_line('Возраст застрахованного ' || v_age);
    IF v_age IS NULL
    THEN
      dbms_output.put_line('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    IF v_f IS NULL
    THEN
      dbms_output.put_line('Нагрузка не найдена....Устанавливаем флаг ошибки ');
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
    dbms_output.put_line('ID discount_f= ' || v_discount_f_id);
    --
    IF v_discount_f_id IS NULL
    THEN
      dbms_output.put_line('Базовая нагрузка по договору не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    dbms_output.put_line('Срок действия договора ' || to_char(v_period_year));
    --
    SELECT ll.t_lob_line_id
          ,decode(lr.func_id
                 ,NULL
                 ,lr.deathrate_id
                 ,pkg_tariff_calc.calc_fun(lr.func_id, ent.id_by_brief('P_COVER'), v_cover_id))
      INTO v_lob_line_id
          ,v_deathrate_id
      FROM ven_t_lob_line         ll
          ,ven_t_prod_line_rate   lr
          ,ven_t_product_line
          ,ven_t_prod_line_option
          ,ven_p_cover
     WHERE 1 = 1
       AND ven_p_cover.p_cover_id = v_cover_id
       AND ven_t_prod_line_option.id = ven_p_cover.t_prod_line_option_id
       AND ven_t_product_line.id = ven_t_prod_line_option.product_line_id
       AND ll.t_lob_line_id = ven_t_product_line.t_lob_line_id
       AND lr.product_line_id(+) = ven_t_product_line.id;
    --
    dbms_output.put_line('ID страховой программы ' || v_lob_line_id);
    dbms_output.put_line('Количество платежей в год ' || v_number_of_payment);
    dbms_output.put_line('Код валюты ответственности ' || v_fund_id);
    --
    dbms_output.put_line('Установленная норма доходности для "страховой программы" ' || v_normrate);
    dbms_output.put_line('v_f = ' || v_f);
    dbms_output.put_line('deathrate_id = ' || v_deathrate_id);
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
    result.t                    := trunc(MONTHS_BETWEEN(v_policy_start_date, v_header_start_date) / 12);
    result.deathrate_id         := v_deathrate_id;
    result.normrate             := v_normrate;
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
            ,decode(doc.get_doc_status_brief(policy_id_prev), 'UNDERWRITING', 1, 0) is_underwriting
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
    result.p_cover_id_prev := nvl(r_prev_version.p_cover_id_prev, p_cover_id);
    result.p_cover_id_curr := nvl(r_prev_version.p_cover_id_curr, p_cover_id);
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

  FUNCTION recalc_value
  (
    p_result        IN NUMBER
   ,p_discount_f_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT           NUMBER;
    v_value          NUMBER;
    v_discount_value discount_f.value%TYPE;
  BEGIN
    dbms_output.put_line('RECALC_VALUE p_result ' || p_result || ' p_discount_f_id ' ||
                         p_discount_f_id);
    --
    SELECT VALUE
      INTO v_discount_value
      FROM ins.discount_f df
     WHERE df.discount_f_id = p_discount_f_id;
  
    dbms_output.put_line('RECALC_VALUE brief ' || v_discount_value);
    --
    IF instr(v_discount_value, '%') > 1
    THEN
      v_discount_value := REPLACE(v_discount_value, '%', '');
      v_value          := to_number(v_discount_value);
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
        IF abs(v_value) < 100
        THEN
          RESULT := p_result * (1 + v_value / 100);
        ELSIF v_value >= 100
        THEN
          RESULT := NULL;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    ELSIF v_discount_value IS NULL
    THEN
      dbms_output.put_line('RECALC_VALUE базовая нагрузка');
      RESULT := p_result;
    ELSE
      dbms_output.put_line('RECALC_VALUE Нагрузка константа ' || v_discount_value);
      RESULT := to_number(v_discount_value);
    END IF;
  
    dbms_output.put_line('RECALC_VALUE result ' || RESULT);
    RETURN RESULT;
  END;

  FUNCTION end_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_f_id     IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_loading_val    NUMBER;
    v_discount_brief discount_f.brief%TYPE := get_discount_brief(par_discount_f_id);
  BEGIN
    IF v_discount_brief = 'База'
    THEN
      IF p_onepayment_property = 1
      THEN
        -- единовременные взносы
        IF (p_n >= 5)
           AND (p_n <= 30)
        THEN
          v_loading_val := (12 + (p_n - 5) * 0.2) / 100;
        ELSE
          IF (p_n > 30)
          THEN
            v_loading_val := 17 / 100;
          ELSE
            v_loading_val := NULL;
          END IF;
        END IF;
      ELSE
        IF (p_n >= 5)
           AND (p_n <= 20)
        THEN
          v_loading_val := (12.5 + (p_n - 5) * 0.5) / 100;
        ELSE
          IF (p_n > 20)
          THEN
            v_loading_val := 20 / 100;
          ELSE
            v_loading_val := NULL;
          END IF;
        END IF;
      END IF;
    ELSIF v_discount_brief = 'EMPLOYEE'
    THEN
      IF p_n >= 5
      THEN
        v_loading_val := (3 + (least(p_n, 20) - 5) * 0.6) / 100;
      END IF;
    
    END IF;
  
    RETURN v_loading_val;
  END;

  FUNCTION end_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
    cover_param      calc_param;
  
    v_p_policy_id         NUMBER;
    l_start_date          DATE;
    l_status_policy_brief VARCHAR2(2000);
    l_addendum_brief      VARCHAR2(200);
    l_as_asset_id         NUMBER;
    v_policy_header_id    NUMBER;
    l_count_close_week    NUMBER;
    l_count_indexating    NUMBER;
  
  BEGIN
    dbms_output.put_line('END_GET_VALUE ');
    /* Определяем ИД договра для текущего покрытия*/
    SELECT aa.p_policy_id
          ,pp.start_date
          ,aa.as_asset_id
          ,pp.pol_header_id
      INTO v_p_policy_id
          ,l_start_date
          ,l_as_asset_id
          ,v_policy_header_id
      FROM p_policy pp
          ,as_asset aa
     WHERE aa.as_asset_id = (SELECT as_asset_id FROM p_cover WHERE p_cover_id = p_p_cover_id)
       AND pp.policy_id = aa.p_policy_id;
    dbms_output.put_line('l_p_policy_id ' || v_p_policy_id || ' l_start_date ' || l_start_date);
  
    /* Проверка условий на выход из условий "финансовых каникул"   */
    SELECT at.brief
      INTO l_addendum_brief
      FROM p_policy            pp
          ,p_pol_addendum_type pa
          ,t_addendum_type     at
     WHERE pp.policy_id = v_p_policy_id
       AND pa.p_policy_id(+) = pp.policy_id
       AND at.t_addendum_type_id(+) = pa.t_addendum_type_id
       AND at.brief(+) = 'CLOSE_FIN_WEEKEND';
  
    /* Проверка условий на выход из условий "финансовых каникул"   */
    SELECT COUNT(at.brief)
      INTO l_count_close_week
      FROM p_policy            pp
          ,p_pol_addendum_type pa
          ,t_addendum_type     at
     WHERE pp.pol_header_id = v_policy_header_id
       AND pa.p_policy_id = pp.policy_id
       AND at.t_addendum_type_id = pa.t_addendum_type_id
       AND at.brief = 'CLOSE_FIN_WEEKEND';
  
    dbms_output.put_line('l_addendum_brief ' || l_addendum_brief);
    /* Определяем статус версии догвовора*/
    l_status_policy_brief := doc.get_doc_status_brief(v_p_policy_id, SYSDATE);
  
    SELECT COUNT(1)
      INTO l_count_indexating
      FROM p_policy            pp
          ,p_pol_addendum_type pa
          ,t_addendum_type     at
     WHERE 1 = 1
       AND pp.policy_id = v_p_policy_id
       AND pa.p_policy_id = pp.policy_id
       AND at.t_addendum_type_id = pa.t_addendum_type_id
       AND at.brief = 'INDEXING2';
  
    dbms_output.put_line('l_count_indexating ' || l_count_indexating);
  
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
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
  
    --
    IF l_status_policy_brief = 'INDEXATING'
    THEN
      cover_param := get_calc_param(p_p_cover_id);
      dbms_output.put_line('n ' || cover_param.period_year || ' t ' || cover_param.t);
      IF nvl((cover_param.period_year - cover_param.t), 0) < 20
      THEN
        RESULT := (cover_param.period_year - cover_param.t - 5) * 0.005 + 0.125;
      ELSE
        RESULT := 0.2;
      END IF;
    
    ELSIF nvl(l_addendum_brief, '#') = 'CLOSE_FIN_WEEKEND'
    THEN
      dbms_output.put_line('Выход из каникул ');
    
      /* По условиям фин каникул нагрузка устанавливается в размер 50% от оригинального*/
      SELECT pc.rvb_value / 2
        INTO RESULT
        FROM p_cover pc
       WHERE p_cover_id =
             (SELECT source_cover_id FROM p_cover pc1 WHERE pc1.p_cover_id = p_p_cover_id);
    
      /* По условиям фин каникул нагрузка устанавливается в размер 50% от оригинального.. Следующие версии должны учитывать это трбеование*/
    ELSIF l_count_close_week > 0
    THEN
      dbms_output.put_line('Покрытие после выхода из каникул ');
    
      SELECT pc.rvb_value
        INTO RESULT
        FROM p_cover pc
       WHERE p_cover_id = (SELECT p_cover_id_prev
                             FROM v_p_cover_life_add pc1
                            WHERE pc1.p_cover_id_curr = p_p_cover_id);
      /* По условиям индексации нагрузка меняется.. следующие версии должны учитывать это*/
    ELSIF l_count_indexating > 0
    THEN
      dbms_output.put_line('Покрытие после индексации ');
    
      SELECT pc.rvb_value
        INTO RESULT
        FROM p_cover pc
       WHERE p_cover_id = (SELECT p_cover_id_prev
                             FROM v_p_cover_life_add pc1
                            WHERE pc1.p_cover_id_curr = p_p_cover_id);
    
    ELSE
      dbms_output.put_line('Обычный расчет ');
      RESULT := end_get_value(v_n, v_is_one_payment, v_discount_f_id);
      --
      r_add_info := get_add_info(p_p_cover_id);
      --
      RESULT := recalc_value(RESULT, v_discount_f_id);
      --
      IF r_add_info.f_prev > RESULT
         AND pkg_policy.get_first_uncanceled_version(v_policy_header_id) != v_p_policy_id
      THEN
        RESULT := r_add_info.f_prev;
      END IF;
    
    END IF;
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
      --
  END;
  --
  FUNCTION investreserve_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    dbms_output.put_line('INVESTRESERVE_GET_VALUE p_n ' || p_n || ' p_OnePayment_property ' ||
                         p_onepayment_property);
    IF (p_n >= 10)
       AND (p_n <= 14)
    THEN
      RESULT := 3.5 / 100;
      dbms_output.put_line('INVESTRESERVE_GET_VALUE result ' || RESULT);
    ELSE
      RESULT := 2.5 / 100;
    END IF;
    RETURN RESULT;
  END;
  --
  FUNCTION investreserve_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
    min_p_policy_id  NUMBER;
    prod_line_id     NUMBER;
  BEGIN
    BEGIN
      SELECT MIN(a.p_policy_id)
            ,opt.product_line_id
        INTO min_p_policy_id
            ,prod_line_id
        FROM ins.p_cover            pc_a
            ,ins.t_prod_line_option opt
            ,ins.p_cover            pc_b
            ,ins.status_hist        st
            ,ins.as_asset           a
            ,ins.as_asset           ab
       WHERE pc_a.t_prod_line_option_id = opt.id
         AND pc_a.p_cover_id = p_p_cover_id
         AND opt.id = pc_b.t_prod_line_option_id
         AND pc_b.status_hist_id = st.status_hist_id
         AND st.brief != 'DELETED'
         AND pc_b.as_asset_id = a.as_asset_id
         AND pc_a.as_asset_id = ab.as_asset_id
         AND a.p_asset_header_id = ab.p_asset_header_id
         AND NOT EXISTS (SELECT NULL
                FROM ins.p_policy        pola
                    ,ins.t_payment_terms trm
               WHERE pola.payment_term_id = trm.id
                 AND trm.brief = 'MONTHLY'
                 AND pola.policy_id = a.p_policy_id)
         AND (EXISTS (SELECT NULL
                        FROM ins.p_pol_addendum_type pt
                            ,ins.t_addendum_type     t
                       WHERE pt.p_policy_id = a.p_policy_id
                         AND pt.t_addendum_type_id = t.t_addendum_type_id
                         AND t.brief = 'INVEST_RESERVE_INCLUDE') OR EXISTS
              (SELECT NULL
                 FROM ins.p_policy pol
                WHERE pol.policy_id = a.p_policy_id
                  AND pol.version_num = 1))
       GROUP BY opt.product_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 0;
    END;
  
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pol.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM ins.p_policy           pol
          ,ins.as_asset           a
          ,ins.p_cover            pc
          ,ins.t_payment_terms    pt
          ,ins.t_prod_line_option opt
          ,ins.status_hist        st
     WHERE pol.policy_id = min_p_policy_id
       AND pol.policy_id = a.p_policy_id
       AND a.as_asset_id = pc.as_asset_id
       AND pol.payment_term_id = pt.id(+)
       AND pc.t_prod_line_option_id = opt.id
       AND opt.product_line_id = prod_line_id
       AND pc.status_hist_id = st.status_hist_id
       AND st.brief != 'DELETED';
  
    RESULT := investreserve_get_value(v_n, v_is_one_payment);
  
    RESULT     := recalc_value(RESULT, v_discount_f_id);
    r_add_info := get_add_info(p_p_cover_id);
  
    IF nvl(r_add_info.f_prev, 0) > RESULT
    THEN
      RESULT := r_add_info.f_prev;
    END IF;
  
    RETURN RESULT;
    --
  END;
  --
  FUNCTION pepr_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_id       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_loading_val    NUMBER;
    v_discount_brief discount_f.brief%TYPE := get_discount_brief(par_discount_id);
  BEGIN
    dbms_output.put_line('PEPR_GET_VALUE p_n ' || p_n || ' p_OnePayment_property ' ||
                         p_onepayment_property);
  
    IF v_discount_brief = 'EMPLOYEE'
    THEN
    
      IF p_n >= 5
      THEN
        v_loading_val := (3 + (least(p_n, 20) - 5) * 0.6) / 100;
      END IF;
    
    ELSIF v_discount_brief = 'База'
    THEN
      IF p_onepayment_property = 1
      THEN
        -- единовременные взносы
        IF (p_n >= 5)
           AND (p_n <= 30)
        THEN
          v_loading_val := (12 + (p_n - 5) * 0.2) / 100;
        ELSE
          IF (p_n > 30)
          THEN
            v_loading_val := 17 / 100;
          ELSE
            v_loading_val := NULL;
          END IF;
        END IF;
      ELSE
        IF (p_n >= 5)
           AND (p_n <= 20)
        THEN
          v_loading_val := (12.5 + (p_n - 5) * 0.5) / 100;
          dbms_output.put_line('PEPR_GET_VALUE result ' || v_loading_val);
        ELSE
          IF (p_n > 20)
          THEN
            v_loading_val := 20 / 100;
          ELSE
            v_loading_val := NULL;
          END IF;
        END IF;
      END IF;
    END IF;
  
    RETURN v_loading_val;
  END;
  --
  FUNCTION pepr_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
    cover_param      calc_param;
  
    l_p_policy_id         NUMBER;
    l_policy_header_id    NUMBER;
    l_as_asset_id         NUMBER;
    l_start_date          DATE;
    l_status_policy_brief VARCHAR2(2000);
    l_addendum_brief      VARCHAR2(200);
    l_count_indexating    NUMBER;
    l_count_close_week    NUMBER;
  BEGIN
    dbms_output.put_line('PEPR_GET_VALUE');
    /* Определяем ИД договра для текущего покрытия*/
    SELECT aa.p_policy_id
          ,pp.start_date
          ,pp.pol_header_id
      INTO l_p_policy_id
          ,l_start_date
          ,l_policy_header_id
      FROM p_policy pp
          ,as_asset aa
     WHERE aa.as_asset_id = (SELECT as_asset_id FROM p_cover WHERE p_cover_id = p_p_cover_id)
       AND pp.policy_id = aa.p_policy_id;
    dbms_output.put_line('l_p_policy_id ' || l_p_policy_id || ' l_start_date ' || l_start_date);
  
    /* Проверка условий на выход из условий "финансовых каникул"   */
    SELECT at.brief
      INTO l_addendum_brief
      FROM p_policy            pp
          ,p_pol_addendum_type pa
          ,t_addendum_type     at
     WHERE pp.policy_id = l_p_policy_id
       AND pa.p_policy_id(+) = pp.policy_id
       AND at.t_addendum_type_id(+) = pa.t_addendum_type_id
       AND at.brief(+) = 'CLOSE_FIN_WEEKEND';
  
    /* Проверка условий на выход из условий "финансовых каникул"   */
    SELECT COUNT(at.brief)
      INTO l_count_close_week
      FROM p_policy            pp
          ,p_pol_addendum_type pa
          ,t_addendum_type     at
     WHERE pp.pol_header_id = l_policy_header_id
       AND pa.p_policy_id = pp.policy_id
       AND at.t_addendum_type_id = pa.t_addendum_type_id
       AND at.brief = 'CLOSE_FIN_WEEKEND';
  
    dbms_output.put_line('l_addendum_brief ' || l_addendum_brief);
    /* Определяем статус версии догвовора*/
    l_status_policy_brief := doc.get_doc_status_brief(l_p_policy_id, SYSDATE);
  
    SELECT COUNT(1)
      INTO l_count_indexating
      FROM p_policy            pp
          ,p_pol_addendum_type pa
          ,t_addendum_type     at
     WHERE 1 = 1
       AND pp.policy_id = l_p_policy_id
       AND pa.p_policy_id = pp.policy_id
       AND at.t_addendum_type_id = pa.t_addendum_type_id
       AND at.brief = 'INDEXING2';
  
    SELECT
    /*case when nvl(pc.insured_age,ass.insured_age) = 0 then
    TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date)/12) - 1 else*/
     trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) /*end*/ period_year
    ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
    ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM t_payment_terms pt
          ,t_period        tp
          ,p_pol_header    ph
          ,p_policy        pp
          ,as_asset        aa
          ,p_cover         pc
          ,ven_as_assured  ass
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND ass.as_assured_id = aa.as_asset_id
       AND ass.p_policy_id = pp.policy_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    IF l_status_policy_brief = 'INDEXATING'
    THEN
      cover_param := get_calc_param(p_p_cover_id);
      dbms_output.put_line('n ' || cover_param.period_year || ' t ' || cover_param.t);
      IF nvl((cover_param.period_year - cover_param.t), 0) < 20
      THEN
        RESULT := (cover_param.period_year - cover_param.t - 5) * 0.005 + 0.125;
      ELSE
        RESULT := 0.2;
      END IF;
    ELSIF nvl(l_addendum_brief, '#') = 'CLOSE_FIN_WEEKEND'
    THEN
    
      /* По условиям фин каникул нагрузка устанавливается в размер 50% от оригинального*/
      SELECT pc.rvb_value / 2
        INTO RESULT
        FROM p_cover pc
       WHERE p_cover_id =
             (SELECT source_cover_id FROM p_cover pc1 WHERE pc1.p_cover_id = p_p_cover_id);
      /* По условиям фин каникул нагрузка устанавливается в размер 50% от оригинального.. Следующие версии должны учитывать это трбеование*/
    ELSIF l_count_close_week > 0
    THEN
      SELECT pc.rvb_value
        INTO RESULT
        FROM p_cover pc
       WHERE p_cover_id = (SELECT p_cover_id_prev
                             FROM v_p_cover_life_add pc1
                            WHERE pc1.p_cover_id_curr = p_p_cover_id);
      /* По условиям индексации нагрузка меняется.. следующие версии должны учитывать это*/
    ELSIF l_count_indexating > 0
    THEN
      SELECT pc.rvb_value
        INTO RESULT
        FROM p_cover pc
       WHERE p_cover_id = (SELECT p_cover_id_prev
                             FROM v_p_cover_life_add pc1
                            WHERE pc1.p_cover_id_curr = p_p_cover_id);
      -- 
    ELSE
      RESULT := pepr_get_value(v_n, v_is_one_payment, v_discount_f_id);
      --
      r_add_info := get_add_info(p_p_cover_id);
      --
      RESULT := recalc_value(RESULT, v_discount_f_id);
      dbms_output.put_line('PEPR_GET_VALUE p_cover_id_prev ' || r_add_info.p_cover_id_prev);
      --
      IF r_add_info.f_prev > RESULT
         AND r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr
      THEN
        RESULT := r_add_info.f_prev;
      END IF;
    
    END IF;
    dbms_output.put_line('PEPR_GET_VALUE result ' || RESULT);
  
    RETURN RESULT;
    --
  END;

  --
  FUNCTION wl_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    IF p_onepayment_property = 1
    THEN
      -- единовременные взносы
      IF (p_n >= 5)
         AND (p_n <= 30)
      THEN
        RESULT := (12 + (p_n - 5) * 0.2) / 100;
      ELSE
        IF (p_n > 30)
        THEN
          RESULT := 17 / 100;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    ELSE
      -- периодические
      IF (p_n >= 5)
         AND (p_n <= 20)
      THEN
        RESULT := (12.5 + (p_n - 5) * 0.5) / 100;
      ELSE
        IF (p_n > 20)
        THEN
          RESULT := 20 / 100;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    END IF;
    RETURN RESULT;
  END;
  --
  FUNCTION wl_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_assured      aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    RESULT := wl_get_value(v_n, v_is_one_payment);
    --
  
    r_add_info := get_add_info(p_p_cover_id);
    --
    --
    RESULT := recalc_value(RESULT, v_discount_f_id);
    --
    IF r_add_info.f_prev > RESULT
    THEN
      RESULT := r_add_info.f_prev;
    END IF;
  
    RETURN RESULT;
    --
  END;
  --
  FUNCTION term_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_id       IN NUMBER
  ) RETURN NUMBER IS
    v_loading_val    NUMBER;
    v_discount_brief discount_f.brief%TYPE := get_discount_brief(par_discount_id);
  BEGIN
    IF v_discount_brief = 'EMPLOYEE'
    THEN
      v_loading_val := 0.225;
    ELSE
      v_loading_val := 0.3;
    END IF;
    RETURN v_loading_val;
  END;
  --
  FUNCTION term_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_loading_val    NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
    v_policy_id      NUMBER;
    v_pol_header_id  NUMBER;
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
          ,pp.policy_id
          ,pp.pol_header_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
          ,v_policy_id
          ,v_pol_header_id
      FROM t_payment_terms pt
          ,t_period        tp
          ,p_pol_header    ph
          ,p_policy        pp
          ,as_asset        aa
          ,p_cover         pc
     WHERE pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    v_loading_val := term_get_value(v_n, v_is_one_payment, v_discount_f_id);
    --
    v_loading_val := recalc_value(v_loading_val, v_discount_f_id);
    --
    --
    r_add_info := get_add_info(p_p_cover_id);
    --
  
    IF r_add_info.f_prev > v_loading_val
       AND pkg_policy.get_first_uncanceled_version(v_pol_header_id) != v_policy_id
    THEN
      v_loading_val := r_add_info.f_prev;
    END IF;
  
    RETURN v_loading_val;
    --
  END;
  --
  FUNCTION cri_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 0.3;
    RETURN RESULT;
  END;
  --
  FUNCTION cri_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_assured      aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    RESULT := cri_get_value(v_n, v_is_one_payment);
    --
    RESULT := recalc_value(RESULT, v_discount_f_id);
    --
    RETURN RESULT;
    --
  END;
  --
  FUNCTION dd_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
   ,par_discount_id       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_loading_val    NUMBER;
    v_discount_breif discount_f.brief%TYPE := get_discount_brief(par_discount_id);
  BEGIN
    IF v_discount_breif = 'EMPLOYEE'
    THEN
      v_loading_val := 0.225;
    ELSE
      v_loading_val := 0.3;
    END IF;
  
    RETURN v_loading_val;
  END;
  --
  FUNCTION dd_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
    v_pol_header_id  NUMBER;
    v_policy_id      NUMBER;
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
          ,pp.pol_header_id
          ,pp.policy_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
          ,v_pol_header_id
          ,v_policy_id
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
    --
    RESULT := dd_get_value(v_n, v_is_one_payment, v_discount_f_id);
    --
    RESULT := recalc_value(RESULT, v_discount_f_id);
    --
    r_add_info := get_add_info(p_p_cover_id);
    --
    --
    IF r_add_info.f_prev > RESULT
       AND pkg_policy.get_first_uncanceled_version(v_pol_header_id) != v_policy_id
    THEN
      RESULT := r_add_info.f_prev;
    END IF;
  
    RETURN RESULT;
  
  END;
  --
  FUNCTION wop_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 0.3;
    RETURN RESULT;
  END;
  --
  FUNCTION wop_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_assured      aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    RESULT := wop_get_value(v_n, v_is_one_payment);
    --
    RESULT := recalc_value(RESULT, v_discount_f_id);
    --
    RETURN RESULT;
    --
  END;
  --
  FUNCTION invest_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 0.3;
    RETURN RESULT;
  END;
  --
  FUNCTION invest_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
    r_add_info       add_info;
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_assured      aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    RESULT := invest_get_value(v_n, v_is_one_payment);
    --
    RESULT := recalc_value(RESULT, v_discount_f_id);
    --
    --
    r_add_info := get_add_info(p_p_cover_id);
    --
  
    --
    IF r_add_info.f_prev > RESULT
    THEN
      RESULT := r_add_info.f_prev;
    END IF;
  
    RETURN RESULT;
    --
  END;

  --
  FUNCTION accident_get_value
  (
    p_n                   IN NUMBER
   ,p_onepayment_property IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 0.35;
    RETURN RESULT;
  END;

  --
  FUNCTION accident_get_value(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER;
    v_n              NUMBER;
    v_discount_f_id  NUMBER;
    v_brief          VARCHAR2(200);
    v_is_one_payment NUMBER(1);
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pp.discount_f_id
      INTO v_n
          ,v_is_one_payment
          ,v_discount_f_id
      FROM ven_t_payment_terms pt
          ,ven_t_period        tp
          ,ven_p_pol_header    ph
          ,ven_p_policy        pp
          ,ven_as_assured      aa
          ,ven_p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
    --
    RESULT := accident_get_value(v_n, v_is_one_payment);
    --
    RESULT := recalc_value(RESULT, v_discount_f_id);
    --
    RETURN RESULT;
    --
  END;

  FUNCTION accexp167_get_value(par_cover_id NUMBER) RETURN NUMBER IS
    v_work_group_desc t_work_group.description%TYPE;
    v_hobby_class     t_hobby.class_cover%TYPE;
    v_hobby_desc      t_hobby.description%TYPE;
    v_loading         NUMBER := 0.475;
  BEGIN
    SELECT wg.description
          ,h.class_cover
          ,h.description
      INTO v_work_group_desc
          ,v_hobby_class
          ,v_hobby_desc
      FROM p_cover      pc
          ,as_assured   aas
          ,t_work_group wg
          ,t_hobby      h
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aas.as_assured_id
       AND aas.work_group_id = wg.t_work_group_id
       AND aas.t_hobby_id = h.t_hobby_id;
  
    IF v_work_group_desc = '1 группа'
    THEN
      v_loading := 0.475;
    ELSE
      v_loading := 0.671875; --0.375+0.475/1.6;
    END IF;
  
    RETURN v_loading;
  
  END;
  --

  FUNCTION strong_start_get_value(par_cover_id NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    v_agent_name contact.obj_name%TYPE;
    v_disc_brief discount_f.brief%TYPE;
  BEGIN
    SELECT (SELECT c.obj_name
              FROM p_policy_agent     pa
                  ,ag_contract_header ac
                  ,contact            c
             WHERE pp.pol_header_id = pa.policy_header_id
               AND pa.ag_contract_header_id = ac.ag_contract_header_id
               AND ac.agent_id = c.contact_id)
          ,(SELECT d.brief FROM discount_f d WHERE pp.discount_f_id = d.discount_f_id)
      INTO v_agent_name
          ,v_disc_brief
      FROM p_cover  pc
          ,as_asset aa
          ,p_policy pp
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    IF v_disc_brief = 'База'
    THEN
      RESULT := 0.91528615;
    ELSE
      raise_application_error(-20000
                             ,'Не удалось определить нагрузку для выбранной скидки');
    END IF;
  
    /*IF v_agent_name LIKE '%РУСЬ%'
    THEN
      RESULT := 0.91528615;
    ELSIF v_agent_name LIKE '%РОЛЬФ%'
    THEN
      CASE v_disc_brief
        WHEN 'База' THEN
          RESULT := 0.9195;
        WHEN 'KV_5' THEN
          RESULT := 0.91528615;
        WHEN 'KV_10' THEN
          RESULT := 0.9105645;
        WHEN 'KV_15' THEN
          RESULT := 0.9052036;
        ELSE
          raise_application_error(-20000
                                 ,'Не удалось рассчитать нагрузку для данной скидки');
      END CASE;
    ELSE
      RESULT := 0.8025;
    END IF;*/
    RETURN RESULT;
  END strong_start_get_value;

  FUNCTION cr104_get_value(par_cover_id NUMBER) RETURN NUMBER IS
    v_discount_brief discount_f.brief%TYPE;
    v_line_brief     t_prod_line_option.brief%TYPE;
    v_product_brief  t_product.brief%TYPE;
    v_result         NUMBER;
  BEGIN
  
    SELECT d.brief
          ,plo.brief
          ,p.brief
      INTO v_discount_brief
          ,v_line_brief
          ,v_product_brief
      FROM p_cover            pc
          ,t_prod_line_option plo
          ,as_asset           aa
          ,p_policy           pp
          ,discount_f         d
          ,p_pol_header       ph
          ,t_product          p
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.discount_f_id = d.discount_f_id
       AND pc.t_prod_line_option_id = plo.id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.product_id = p.product_id;
  
    IF v_product_brief NOT IN ('CR104_1', 'CR104_2')
    THEN
      raise_application_error(-20000
                             ,'Не верный продукт для данной функции расчета нагрузки');
    END IF;
  
    CASE v_discount_brief
      WHEN 'База' THEN
        IF v_product_brief = 'CR104_2'
        THEN
          IF v_line_brief = 'PEPR_2'
          THEN
            v_result := 0.80907668; -- Пакет 2
          ELSE
            v_result := 0.80971339;
          END IF;
        ELSE
          v_result := 0.8112; -- Пакет 1
        END IF;
      ELSE
        raise_application_error(-20000
                               ,'Нагрузка для данной скидки не определена');
    END CASE;
  
    RETURN v_result;
  
  END cr104_get_value;

  FUNCTION investor_lump_get_velue(par_cover_id NUMBER) RETURN NUMBER IS
    v_result              NUMBER;
    v_agent_num           document.num%TYPE;
    v_prod_line_opt_brief t_prod_line_option.brief%TYPE;
    v_period_in_years     NUMBER;
    v_pol_header_id       NUMBER;
  BEGIN
  
    SELECT pp.pol_header_id
      INTO v_pol_header_id
      FROM p_cover  pc
          ,as_asset aa
          ,p_policy pp
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    BEGIN
      SELECT num
        INTO v_agent_num
        FROM document
       WHERE document_id = pkg_agn_control.get_current_policy_agent(v_pol_header_id);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    CASE
      WHEN v_agent_num IN ('44730') THEN
      
        SELECT brief
              ,CEIL(MONTHS_BETWEEN(pc.end_date, pc.start_date) / 12)
          INTO v_prod_line_opt_brief
              ,v_period_in_years
          FROM t_prod_line_option plo
              ,p_cover            pc
         WHERE pc.p_cover_id = par_cover_id
           AND pc.t_prod_line_option_id = plo.id;
      
        CASE v_prod_line_opt_brief
          WHEN 'PEPR_B' THEN
            v_result := 0.05;
          WHEN 'PEPR_A' THEN
            v_result := 0.05;
          WHEN 'PEPR_A_PLUS' THEN
            v_result := 0.18;
        END CASE;
      
      ELSE
        DECLARE
          v_func_id NUMBER;
        BEGIN
          SELECT pl.loading_func_id
            INTO v_func_id
            FROM t_prod_line_option plo
                ,t_product_line     pl
                ,p_cover            pc
           WHERE pc.p_cover_id = par_cover_id
             AND pc.t_prod_line_option_id = plo.id
             AND plo.product_line_id = pl.id;
        
          v_result := pkg_tariff_calc.calc_fun(p_id     => pkg_prod_coef.get_prod_coef_type_id_by_brief('loading_rate_for_investor_lump')
                                              ,p_ent_id => 305
                                              ,p_obj_id => par_cover_id);
        END;
    END CASE;
  
    RETURN v_result;
  END investor_lump_get_velue;

  FUNCTION accexp168_get_value(par_cover_id NUMBER) RETURN NUMBER IS
    v_category_brief t_assured_category.brief%TYPE;
    v_loading        NUMBER := 0.475;
  BEGIN
    BEGIN
      SELECT t.brief
        INTO v_category_brief
        FROM t_assured_category t
            ,p_cover            pc
            ,as_assured         aa
       WHERE pc.p_cover_id = par_cover_id
         AND pc.as_asset_id = aa.as_assured_id
         AND aa.assured_category_id = t.t_assured_category_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не выбрана категория застрахованного, невозможно расчитать нагрузку');
    END;
  
    IF v_category_brief = 'cat_1'
       OR v_category_brief IS NULL
    THEN
      v_loading := 0.475;
    ELSIF v_category_brief = 'cat_2'
    THEN
      v_loading := 0.65; --(1.5-1+0.475)/1.5;
    ELSE
      raise_application_error(-20000
                             ,'Для выбранной категории застрахованного не определена нагрузка');
    END IF;
  
    RETURN v_loading;
  
  END accexp168_get_value;
  --
END pkg_prdlifeloading;
/
