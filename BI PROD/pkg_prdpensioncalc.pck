CREATE OR REPLACE PACKAGE pkg_PrdPensionCalc IS
  /*
   * Расчет брутто, нетто премии по покрытию договора страхования пенсий
   * @author Marchuk A.
   * @version 1
   * @headcom
  */

  /**
   * Расчет брутто по покрытию "Программа 1 Пожизненная пенсия"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION LIFELONG_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию "Программа 1 Пожизненная пенсия"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION LIFELONG_get_netto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возвращает размер брутто по программе "Программа 1 Пожизненная пенсия"
  * @author Marchuk A.
  * @param p_age_x  возраст застрахованного на момент заключения договора
  * @param p_gender_type_x пол застрахованного
  * @param p_age_y  возраст супруга (супруги) на момент заключения договора
  * @param p_gender_type_y супруга (супруги)
  * @param p_m количество выплат в году
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_k доля от исходного таннуитета, выплачиваемая пережившей супруге (супругу)
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_get_brutto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает размер нетто по программе "Программа 1 Пожизненная пенсия"
  * @author Marchuk A.
  * @param p_age_x  возраст застрахованного на момент заключения договора
  * @param p_gender_type_x пол застрахованного
  * @param p_age_y  возраст супруга (супруги) на момент заключения договора
  * @param p_gender_type_y супруга (супруги)
  * @param p_m количество выплат в году
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_k доля от исходного таннуитета, выплачиваемая пережившей супруге (супругу)
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_get_netto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает размер брутто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_cover_id - ИД покрытия
  */

  FUNCTION LIFELONG_PERIOD_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возвращает размер нетто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_cover_id - ИД покрытия
  */

  FUNCTION LIFELONG_PERIOD_get_netto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возвращает размер брутто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_age  возраст застрахованного на момент заключения договора
  * @param p_gender_type пол застрахованного
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PERIOD_get_brutto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает размер нетто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_age  возраст застрахованного на момент заключения договора
  * @param p_gender_type пол застрахованного
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PERIOD_get_netto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_cover ИД покрытия
  */

  FUNCTION LIFELONG_PARTNER_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возвращает размер нетто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_cover ИД покрытия
  */

  FUNCTION LIFELONG_PARTNER_get_netto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_age_x  возраст застрахованного на момент заключения договора
  * @param p_gender_type_x пол застрахованного
  * @param p_age_y  возраст супруга (супруги) на момент заключения договора
  * @param p_gender_type_y супруга (супруги)
  * @param p_m количество выплат в году
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_k доля от исходного таннуитета, выплачиваемая пережившей супруге (супругу)
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PARTNER_get_brutto
  (
    p_age_x               IN NUMBER
   ,p_gender_type_x       IN VARCHAR2
   ,p_age_y               IN NUMBER
   ,p_gender_type_y       IN VARCHAR2
   ,p_m                   IN NUMBER
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_k                   IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_age_x  возраст застрахованного на момент заключения договора
  * @param p_gender_type_x пол застрахованного
  * @param p_age_y  возраст супруга (супруги) на момент заключения договора
  * @param p_gender_type_y супруга (супруги)
  * @param p_m количество выплат в году
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_k доля от исходного таннуитета, выплачиваемая пережившей супруге (супругу)
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PARTNER_get_netto
  (
    p_age_x               IN NUMBER
   ,p_gender_type_x       IN VARCHAR2
   ,p_age_y               IN NUMBER
   ,p_gender_type_y       IN VARCHAR2
   ,p_m                   IN NUMBER
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_k                   IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER;

END pkg_PrdPensionCalc;
/
CREATE OR REPLACE PACKAGE BODY pkg_PrdPensionCalc IS
  /*
   * Расчет брутто, нетто премии по покрытию договора страхования пенсий
   * @author Marchuk A.
   * @version 1
   * @headcom
  */

  TYPE calc_param IS RECORD(
     p_cover_id           NUMBER
    ,age_x                NUMBER
    ,birth_date_x         DATE
    ,gender_type_x        VARCHAR2(1)
    ,assured_contact_id   NUMBER
    ,age_y                NUMBER
    ,birth_date_y         DATE
    ,gender_type_y        VARCHAR2(1)
    ,period_year          NUMBER
    ,s_coef               NUMBER
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
    ,is_in_waiting_period NUMBER);
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

  FUNCTION get_calc_param(p_cover_id IN NUMBER) RETURN calc_param IS
    --
    v_cover_id NUMBER;
    --
    v_age_x        NUMBER;
    v_birth_date_x DATE;
    --
    v_age_y        NUMBER;
    v_birth_date_y DATE;
    --
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
    v_deathrate_id           NUMBER;
    v_discount_f_id          NUMBER;
    v_gender_type            VARCHAR2(1);
    v_gender_type_x          VARCHAR2(1);
    v_gender_type_y          VARCHAR2(1);
    v_assured_contact_id     NUMBER;
    v_assured_add_contact_id NUMBER;
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
    dbms_output.put_line('ID покрытия ' || v_cover_id);
    SELECT vas.as_assured_id
          ,decode(nvl(vcp_x.gender, vas.gender), 0, 'w', 1, 'm') gender_type
          ,vcp_x.date_of_birth
          ,vas.assured_contact_id
          ,decode(vcp_y.gender, 0, 'w', 1, 'm') gender_type_y
          ,assured_add_contact_id
          ,vcp_y.date_of_birth
      INTO v_as_assured_id
          ,v_gender_type_x
          ,v_birth_date_x
          ,v_assured_contact_id
          ,v_gender_type_y
          ,v_assured_add_contact_id
          ,v_birth_date_y
      FROM ven_cn_person  vcp_y
          ,ven_contact    vc_y
          ,ven_cn_person  vcp_x
          ,ven_contact    vc_x
          ,ven_as_assured vas
          ,ven_p_cover    vpc
     WHERE 1 = 1
       AND vpc.p_cover_id = v_cover_id
       AND vas.as_assured_id = vpc.as_asset_id
       AND vc_x.contact_id(+) = vas.assured_contact_id
       AND vcp_x.contact_id(+) = vc_x.contact_id
       AND vc_y.contact_id(+) = vas.assured_add_contact_id
       AND vcp_y.contact_id(+) = vc_y.contact_id;
    --
    dbms_output.put_line('ID застрахованного ' || v_as_assured_id);
    IF v_gender_type IS NULL
    THEN
      result.is_error := 1;
      RETURN RESULT;
    END IF;
  
    --
    SELECT pp.policy_id
          ,nvl(s_coef, 0) s_coef
          ,nvl(k_coef, 0) k_koef
          ,rvb_value
          ,normrate_value
          ,nvl(ven_p_cover.insured_age, ven_as_assured.insured_age) insured_age
          ,ven_p_cover.tariff
          ,ven_p_cover.tariff_netto
          ,ven_p_cover.fee
          ,ven_p_cover.ins_amount
          ,ven_p_cover.premia_base_type
           --         , ven_p_policy.discount_f_id, decode (ven_t_period.period_value, null, trunc(months_between(ven_p_policy.end_date, ph.start_date)/12), ven_t_period.period_value)
          ,pp.discount_f_id
          ,trunc(MONTHS_BETWEEN(ven_p_cover.end_date + 1, ven_p_cover.start_date) / 12) period_year
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
          ,v_f
          ,v_normrate
          ,v_age_x
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
          ,ven_p_cover
     WHERE 1 = 1
       AND ven_p_cover.p_cover_id = v_cover_id
       AND ven_as_assured.as_assured_id = ven_p_cover.as_asset_id
       AND pp.policy_id = ven_as_assured.p_policy_id
       AND ven_t_period.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
  
    --
    dbms_output.put_line('ID версии договора (полиса) ' || v_policy_id);
    dbms_output.put_line('Возраст застрахованного ' || v_age_x);
    IF v_age_x IS NULL
    THEN
      dbms_output.put_line('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error := 1;
      RETURN RESULT;
    END IF;
    --
    IF v_f IS NULL
    THEN
      dbms_output.put_line('Нагрузка не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
      RETURN RESULT;
    END IF;
    --
    IF v_normrate IS NULL
    THEN
      dbms_output.put_line('Норма доходности не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
      RETURN RESULT;
    END IF;
    --
    dbms_output.put_line('ID discount_f= ' || v_discount_f_id);
    --
    IF v_discount_f_id IS NULL
    THEN
      dbms_output.put_line('Базовая нагрузка по договору не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
      RETURN RESULT;
    END IF;
    --
    dbms_output.put_line('Срок действия договора ' || to_char(v_period_year));
    --
    SELECT ll.t_lob_line_id
          ,lr.deathrate_id
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
    result.age_x              := v_age_x;
    result.gender_type_x      := v_gender_type_x;
    result.assured_contact_id := v_assured_contact_id;
    result.period_year        := v_period_year;
    result.s_coef             := v_s_coef;
    result.k_coef             := v_k_coef;
    result.f                  := v_f;
    result.t                  := trunc(MONTHS_BETWEEN(v_policy_start_date, v_header_start_date) / 12);
    dbms_output.put_line('v_policy_start_date = ' || v_policy_start_date);
    dbms_output.put_line('v_header_start_date = ' || v_header_start_date);
    dbms_output.put_line('result.t = ' || result.t);
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
    --
    IF v_deathrate_id IS NULL
    THEN
      dbms_output.put_line('Таблица смертности не указана....Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
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

  /**
   * Расчет брутто по покрытию договора страхования пенсий. Программа "" по "смешанное страхование"
   * @author Marchuk A.
  * @param p_age  возраст застрахованного на момент заключения договора
  * @param p_gender_type пол застрахованного
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_get_brutto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER IS
    --
    v_G    NUMBER;
    v_a_z  NUMBER;
    v_s_n  NUMBER;
    RESULT NUMBER;
    v      NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v     := 1 / (1 + p_normrate);
    v_a_z := pkg_amath.a_x(p_age + p_period_year
                          ,p_gender_type
                          ,p_k_coef
                          ,p_s_coef
                          ,1
                          ,p_deathrate_id
                          ,p_normrate);
    v_s_n := ROUND(pkg_amath.s_n(p_period_year, 1, 1, p_normrate), 6);
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_G := power(v, p_period_year) * v_a_z / (1 - p_f);
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_G := power(v, p_period_year) * (v_a_z / v_s_n) * (1 / (1 - p_f));
    ELSE
      v_G := NULL;
    END IF;
    dbms_output.put_line('v_a_z ' || v_a_z || ' v ' || v || ' v_G ' || v_G);
  
    RESULT := v_G;
    RETURN RESULT;
    --
  END;

  /**
   * Расчет брутто по покрытию договора страхования пенсий. Программа "Пожизненная пенсия"
   * @author Marchuk A.
  * @param p_age  возраст застрахованного на момент заключения договора
  * @param p_gender_type пол застрахованного
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_get_netto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER IS
    --
    v_P    NUMBER;
    v_a_z  NUMBER;
    v_s_n  NUMBER;
    RESULT NUMBER;
    v      NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v     := 1 / (1 + p_normrate);
    v_a_z := pkg_amath.a_x(p_age + p_period_year
                          ,p_gender_type
                          ,p_k_coef
                          ,p_s_coef
                          ,1
                          ,p_deathrate_id
                          ,p_normrate);
    v_s_n := ROUND(pkg_amath.s_n(p_period_year, 1, 1, p_normrate), 6);
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_P := power(v, p_period_year) * v_a_z;
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_P := power(v, p_period_year) * (v_a_z / v_s_n);
    ELSE
      v_P := NULL;
    END IF;
    dbms_output.put_line('v_a_z ' || v_a_z || ' v ' || v || ' v_P ' || v_P);
  
    RESULT := v_P;
    RETURN RESULT;
    --
  END;

  /**
  * Возвращает размер брутто по программе "Программа 1 Пожизненная пенсия"
  * @author Marchuk A.
  * @param p_cover_id - ИД покрытия
  *
  */

  FUNCTION LIFELONG_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT            NUMBER;
    r_calc_param_prev calc_param;
    r_calc_param_curr calc_param;
    r_calc_param      calc_param;
    r_add_info        add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := NULL;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_get_brutto(r_calc_param.age_x
                                                        ,r_calc_param.gender_type_x
                                                        ,r_calc_param.period_year
                                                        ,r_calc_param.normrate
                                                        ,r_calc_param.s_coef
                                                        ,r_calc_param.k_coef
                                                        ,r_calc_param.f
                                                        ,r_calc_param.deathrate_id
                                                        ,r_calc_param.is_one_payment);
      END IF;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_get_brutto(r_calc_param.age_x
                                                        ,r_calc_param.gender_type_x
                                                        ,r_calc_param.period_year
                                                        ,r_calc_param.normrate
                                                        ,r_calc_param.s_coef
                                                        ,r_calc_param.k_coef
                                                        ,r_calc_param.f
                                                        ,r_calc_param.deathrate_id
                                                        ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ');
      RESULT := pkg_PrdPensionCalc.LIFELONG_get_brutto(r_calc_param.age_x
                                                      ,r_calc_param.gender_type_x
                                                      ,r_calc_param.period_year
                                                      ,r_calc_param.normrate
                                                      ,r_calc_param.s_coef
                                                      ,r_calc_param.k_coef
                                                      ,r_calc_param.f
                                                      ,r_calc_param.deathrate_id
                                                      ,r_calc_param.is_one_payment);
    
    END IF;
  END;
  --

  /**
  * Возвращает размер брутто по программе "Программа 1 Пожизненная пенсия"
  * @author Marchuk A.
  * @param p_cover_id - ИД покрытия
  *
  */

  FUNCTION LIFELONG_get_netto(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT            NUMBER;
    r_calc_param_prev calc_param;
    r_calc_param_curr calc_param;
    r_calc_param      calc_param;
    r_add_info        add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := NULL;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_get_netto(r_calc_param.age_x
                                                       ,r_calc_param.gender_type_x
                                                       ,r_calc_param.period_year
                                                       ,r_calc_param.normrate
                                                       ,r_calc_param.s_coef
                                                       ,r_calc_param.k_coef
                                                       ,r_calc_param.f
                                                       ,r_calc_param.deathrate_id
                                                       ,r_calc_param.is_one_payment);
      END IF;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_get_netto(r_calc_param.age_x
                                                       ,r_calc_param.gender_type_x
                                                       ,r_calc_param.period_year
                                                       ,r_calc_param.normrate
                                                       ,r_calc_param.s_coef
                                                       ,r_calc_param.k_coef
                                                       ,r_calc_param.f
                                                       ,r_calc_param.deathrate_id
                                                       ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ');
      RESULT := pkg_PrdPensionCalc.LIFELONG_get_netto(r_calc_param.age_x
                                                     ,r_calc_param.gender_type_x
                                                     ,r_calc_param.period_year
                                                     ,r_calc_param.normrate
                                                     ,r_calc_param.s_coef
                                                     ,r_calc_param.k_coef
                                                     ,r_calc_param.f
                                                     ,r_calc_param.deathrate_id
                                                     ,r_calc_param.is_one_payment);
    
    END IF;
    --
  
  END;
  --

  /**
  * Возвращает размер брутто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_cover_id - ИД покрытия
  */

  FUNCTION LIFELONG_PERIOD_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT            NUMBER;
    r_calc_param_prev calc_param;
    r_calc_param_curr calc_param;
    r_calc_param      calc_param;
    r_add_info        add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := NULL;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_PERIOD_get_brutto(r_calc_param.age_x
                                                               ,r_calc_param.gender_type_x
                                                               ,r_calc_param.period_year
                                                               ,r_calc_param.normrate
                                                               ,r_calc_param.s_coef
                                                               ,r_calc_param.k_coef
                                                               ,r_calc_param.f
                                                               ,r_calc_param.deathrate_id
                                                               ,r_calc_param.is_one_payment);
      END IF;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_PERIOD_get_brutto(r_calc_param.age_x
                                                               ,r_calc_param.gender_type_x
                                                               ,r_calc_param.period_year
                                                               ,r_calc_param.normrate
                                                               ,r_calc_param.s_coef
                                                               ,r_calc_param.k_coef
                                                               ,r_calc_param.f
                                                               ,r_calc_param.deathrate_id
                                                               ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ');
      RESULT := pkg_PrdPensionCalc.LIFELONG_PERIOD_get_brutto(r_calc_param.age_x
                                                             ,r_calc_param.gender_type_x
                                                             ,r_calc_param.period_year
                                                             ,r_calc_param.normrate
                                                             ,r_calc_param.s_coef
                                                             ,r_calc_param.k_coef
                                                             ,r_calc_param.f
                                                             ,r_calc_param.deathrate_id
                                                             ,r_calc_param.is_one_payment);
    
    END IF;
  END;

  /**
  * Возвращает размер брутто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_cover_id - ИД покрытия
  */

  FUNCTION LIFELONG_PERIOD_get_netto(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT            NUMBER;
    r_calc_param_prev calc_param;
    r_calc_param_curr calc_param;
    r_calc_param      calc_param;
    r_add_info        add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := NULL;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_PERIOD_get_netto(r_calc_param.age_x
                                                              ,r_calc_param.gender_type_x
                                                              ,r_calc_param.period_year
                                                              ,r_calc_param.normrate
                                                              ,r_calc_param.s_coef
                                                              ,r_calc_param.k_coef
                                                              ,r_calc_param.f
                                                              ,r_calc_param.deathrate_id
                                                              ,r_calc_param.is_one_payment);
      END IF;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pkg_PrdPensionCalc.LIFELONG_PERIOD_get_netto(r_calc_param.age_x
                                                              ,r_calc_param.gender_type_x
                                                              ,r_calc_param.period_year
                                                              ,r_calc_param.normrate
                                                              ,r_calc_param.s_coef
                                                              ,r_calc_param.k_coef
                                                              ,r_calc_param.f
                                                              ,r_calc_param.deathrate_id
                                                              ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ');
      RESULT := pkg_PrdPensionCalc.LIFELONG_PERIOD_get_netto(r_calc_param.age_x
                                                            ,r_calc_param.gender_type_x
                                                            ,r_calc_param.period_year
                                                            ,r_calc_param.normrate
                                                            ,r_calc_param.s_coef
                                                            ,r_calc_param.k_coef
                                                            ,r_calc_param.f
                                                            ,r_calc_param.deathrate_id
                                                            ,r_calc_param.is_one_payment);
    
    END IF;
  END;

  /**
  * Возвращает размер брутто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_age  возраст застрахованного на момент заключения договора
  * @param p_gender_type пол застрахованного
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PERIOD_get_brutto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER IS
    --
    v_G     NUMBER;
    v_n_a_z NUMBER;
    v_s_n   NUMBER;
    v_a_n   NUMBER;
    RESULT  NUMBER;
    v       NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v       := 1 / (1 + p_normrate);
    v_n_a_z := pkg_amath.n_a_x(p_age
                              ,p_period_year
                              ,p_gender_type
                              ,p_k_coef
                              ,p_s_coef
                              ,1
                              ,p_deathrate_id
                              ,p_normrate);
    v_s_n   := ROUND(pkg_amath.s_n(p_period_year, 1, 1, p_normrate), 6);
    v_a_n   := ROUND(pkg_amath.a_n(p_age, 1, 1, p_normrate), 6);
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_G := (v_a_n + v_n_a_z) / (v_s_n * (1 - p_f));
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_G := power(v, p_period_year) * (v_a_n + v_n_a_z) * (1 / (1 - p_f));
    ELSE
      v_G := NULL;
    END IF;
    dbms_output.put_line('v_n_a_z ' || v_n_a_z || ' v ' || v || ' v_G ' || v_G);
  
    RESULT := v_G;
    RETURN RESULT;
    --
  END LIFELONG_PERIOD_get_brutto;

  /**
  * Возвращает размер брутто по программе "Программа 2 Пожизненная пенсия с периодом гарантированной выплаты"
  * @author Marchuk A.
  * @param p_age  возраст застрахованного на момент заключения договора
  * @param p_gender_type пол застрахованного
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PERIOD_get_netto
  (
    p_age                 IN NUMBER
   ,p_gender_type         IN VARCHAR2
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER IS
    --
    v_P     NUMBER;
    v_n_a_z NUMBER;
    v_s_n   NUMBER;
    v_a_n   NUMBER;
    RESULT  NUMBER;
    v       NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v       := 1 / (1 + p_normrate);
    v_n_a_z := pkg_amath.n_a_x(p_age
                              ,p_period_year
                              ,p_gender_type
                              ,p_k_coef
                              ,p_s_coef
                              ,1
                              ,p_deathrate_id
                              ,p_normrate);
    v_s_n   := ROUND(pkg_amath.s_n(p_period_year, 1, 1, p_normrate), 6);
    v_a_n   := ROUND(pkg_amath.a_n(p_age, 1, 1, p_normrate), 6);
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_P := (v_a_n + v_n_a_z) / (v_s_n);
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_P := power(v, p_period_year) * (v_a_n + v_n_a_z);
    ELSE
      v_P := NULL;
    END IF;
    dbms_output.put_line('v_n_a_z ' || v_n_a_z || ' v ' || v || ' v_P ' || v_P);
  
    RESULT := v_P;
    RETURN RESULT;
    --
  END LIFELONG_PERIOD_get_netto;

  --
  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_cover ИД покрытия
  */

  FUNCTION LIFELONG_PARTNER_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT            NUMBER;
    r_calc_param_prev calc_param;
    r_calc_param_curr calc_param;
    r_calc_param      calc_param;
    r_add_info        add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := NULL;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := LIFELONG_PARTNER_get_brutto(r_calc_param.age_x
                                             ,r_calc_param.gender_type_x
                                             ,r_calc_param.age_y
                                             ,r_calc_param.gender_type_y
                                             ,1
                                             ,r_calc_param.period_year
                                             ,r_calc_param.normrate
                                             ,1
                                             ,r_calc_param.s_coef
                                             ,r_calc_param.k_coef
                                             ,r_calc_param.f
                                             ,r_calc_param.deathrate_id
                                             ,r_calc_param.is_one_payment);
      END IF;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := LIFELONG_PARTNER_get_brutto(r_calc_param.age_x
                                             ,r_calc_param.gender_type_x
                                             ,r_calc_param.age_y
                                             ,r_calc_param.gender_type_y
                                             ,1
                                             ,r_calc_param.period_year
                                             ,r_calc_param.normrate
                                             ,1
                                             ,r_calc_param.s_coef
                                             ,r_calc_param.k_coef
                                             ,r_calc_param.f
                                             ,r_calc_param.deathrate_id
                                             ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ');
      RESULT := LIFELONG_PARTNER_get_brutto(r_calc_param.age_x
                                           ,r_calc_param.gender_type_x
                                           ,r_calc_param.age_y
                                           ,r_calc_param.gender_type_y
                                           ,1
                                           ,r_calc_param.period_year
                                           ,r_calc_param.normrate
                                           ,1
                                           ,r_calc_param.s_coef
                                           ,r_calc_param.k_coef
                                           ,r_calc_param.f
                                           ,r_calc_param.deathrate_id
                                           ,r_calc_param.is_one_payment);
    END IF;
  END LIFELONG_PARTNER_get_brutto;

  --
  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_cover ИД покрытия
  */

  FUNCTION LIFELONG_PARTNER_get_netto(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT            NUMBER;
    r_calc_param_prev calc_param;
    r_calc_param_curr calc_param;
    r_calc_param      calc_param;
    r_add_info        add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := NULL;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := LIFELONG_PARTNER_get_netto(r_calc_param.age_x
                                            ,r_calc_param.gender_type_x
                                            ,r_calc_param.age_y
                                            ,r_calc_param.gender_type_y
                                            ,1
                                            ,r_calc_param.period_year
                                            ,r_calc_param.normrate
                                            ,1
                                            ,r_calc_param.s_coef
                                            ,r_calc_param.k_coef
                                            ,r_calc_param.f
                                            ,r_calc_param.deathrate_id
                                            ,r_calc_param.is_one_payment);
      END IF;
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := LIFELONG_PARTNER_get_netto(r_calc_param.age_x
                                            ,r_calc_param.gender_type_x
                                            ,r_calc_param.age_y
                                            ,r_calc_param.gender_type_y
                                            ,1
                                            ,r_calc_param.period_year
                                            ,r_calc_param.normrate
                                            ,1
                                            ,r_calc_param.s_coef
                                            ,r_calc_param.k_coef
                                            ,r_calc_param.f
                                            ,r_calc_param.deathrate_id
                                            ,r_calc_param.is_one_payment);
      END IF;
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ');
      RESULT := LIFELONG_PARTNER_get_netto(r_calc_param.age_x
                                          ,r_calc_param.gender_type_x
                                          ,r_calc_param.age_y
                                          ,r_calc_param.gender_type_y
                                          ,1
                                          ,r_calc_param.period_year
                                          ,r_calc_param.normrate
                                          ,1
                                          ,r_calc_param.s_coef
                                          ,r_calc_param.k_coef
                                          ,r_calc_param.f
                                          ,r_calc_param.deathrate_id
                                          ,r_calc_param.is_one_payment);
    END IF;
  END LIFELONG_PARTNER_get_netto;

  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_age_x  возраст застрахованного на момент заключения договора
  * @param p_gender_type_x пол застрахованного
  * @param p_age_y  возраст супруга (супруги) на момент заключения договора
  * @param p_gender_type_y супруга (супруги)
  * @param p_m количество выплат в году
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_k доля от исходного таннуитета, выплачиваемая пережившей супруге (супругу)
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PARTNER_get_brutto
  (
    p_age_x               IN NUMBER
   ,p_gender_type_x       IN VARCHAR2
   ,p_age_y               IN NUMBER
   ,p_gender_type_y       IN VARCHAR2
   ,p_m                   IN NUMBER
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_k                   IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER IS
    v_G    NUMBER;
    v_z    NUMBER;
    v_y    NUMBER;
    v_a_z  NUMBER;
    v_a_y  NUMBER;
    v_a_zy NUMBER;
    v_s_n  NUMBER;
    v_a_n  NUMBER;
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v   := 1 / (1 + p_normrate);
    v_z := p_age_x + p_period_year;
    v_y := p_age_y + p_period_year;
    --
    v_a_z  := ROUND(pkg_amath.a_x(v_z
                                 ,p_gender_type_x
                                 ,p_k_coef
                                 ,p_s_coef
                                 ,1
                                 ,p_deathrate_id
                                 ,p_normrate)
                   ,6);
    v_a_y  := ROUND(pkg_amath.a_x(v_y
                                 ,p_gender_type_y
                                 ,p_k_coef
                                 ,p_s_coef
                                 ,1
                                 ,p_deathrate_id
                                 ,p_normrate)
                   ,6);
    v_a_zy := ROUND(pkg_amath.a_xy(v_z
                                  ,p_gender_type_x
                                  ,v_y
                                  ,p_gender_type_x
                                  ,1
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,6);
    v_s_n  := ROUND(pkg_amath.s_n(p_period_year, 1, 1, p_normrate), 6);
    --
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_G := (1 / 1 - p_f) * (v_a_z + p_k * (v_a_y - v_a_zy)) / v_s_n;
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_G := (1 / 1 - p_f) * power(v, p_period_year) * (v_a_z + p_k * (v_a_y - v_a_zy));
    ELSE
      v_G := NULL;
    END IF;
    --
    RESULT := v_G;
    RETURN RESULT;
  END LIFELONG_PARTNER_get_brutto;

  /**
  * Возвращает размер брутто по программе "Программа 3 Пожизненная пенсия с передачей пережившей супруге (супругу)"
  * @author Marchuk A.
  * @param p_age_x  возраст застрахованного на момент заключения договора
  * @param p_gender_type_x пол застрахованного
  * @param p_age_y  возраст супруга (супруги) на момент заключения договора
  * @param p_gender_type_y супруга (супруги)
  * @param p_m количество выплат в году
  * @param p_period_year срок страхования
  * @param p_normrate     Норма доходности по выбранной программе покрытия
  * @param p_k доля от исходного таннуитета, выплачиваемая пережившей супруге (супругу)
  * @param p_s_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_k_coef       Коэффициент, нагружающий таблицу смертности
  * @param p_f            Нагрузка по договору страхования
  * @param p_deathrate_id ИД таблицы смертности
  * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION LIFELONG_PARTNER_get_netto
  (
    p_age_x               IN NUMBER
   ,p_gender_type_x       IN VARCHAR2
   ,p_age_y               IN NUMBER
   ,p_gender_type_y       IN VARCHAR2
   ,p_m                   IN NUMBER
   ,p_period_year         IN NUMBER
   ,p_normrate            IN NUMBER
   ,p_k                   IN NUMBER
   ,p_s_coef              IN NUMBER
   ,p_k_coef              IN NUMBER
   ,p_f                   IN NUMBER
   ,p_deathrate_id        IN NUMBER
   ,p_OnePayment_Property IN NUMBER
  ) RETURN NUMBER IS
    v_P    NUMBER;
    v_z    NUMBER;
    v_y    NUMBER;
    v_a_z  NUMBER;
    v_a_y  NUMBER;
    v_a_zy NUMBER;
    v_s_n  NUMBER;
    v_a_n  NUMBER;
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v   := 1 / (1 + p_normrate);
    v_z := p_age_x + p_period_year;
    v_y := p_age_y + p_period_year;
    --
    v_a_z  := ROUND(pkg_amath.a_x(v_z
                                 ,p_gender_type_x
                                 ,p_k_coef
                                 ,p_s_coef
                                 ,1
                                 ,p_deathrate_id
                                 ,p_normrate)
                   ,6);
    v_a_y  := ROUND(pkg_amath.a_x(v_y
                                 ,p_gender_type_y
                                 ,p_k_coef
                                 ,p_s_coef
                                 ,1
                                 ,p_deathrate_id
                                 ,p_normrate)
                   ,6);
    v_a_zy := ROUND(pkg_amath.a_xy(v_z
                                  ,p_gender_type_x
                                  ,v_y
                                  ,p_gender_type_x
                                  ,1
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,6);
    v_s_n  := ROUND(pkg_amath.s_n(p_period_year, 1, 1, p_normrate), 6);
    --
    IF p_OnePayment_Property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_P := (v_a_z + p_k * (v_a_y - v_a_zy)) / v_s_n;
    ELSIF p_OnePayment_Property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_P := power(v, p_period_year) * (v_a_z + p_k * (v_a_y - v_a_zy));
    ELSE
      v_P := NULL;
    END IF;
    --
    RESULT := v_P;
    RETURN RESULT;
  END LIFELONG_PARTNER_get_netto;
  --

END pkg_PrdPensionCalc;
/
