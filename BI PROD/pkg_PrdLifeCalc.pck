CREATE OR REPLACE PACKAGE pkg_prdlifecalc IS

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
   * @headcom
  */

  --  ! END - смешанное страхование
  --  !PEPR - страхование на дожитие с возвратом взносов
  --  !TERM - страхование жизни на срок
  --  !CRI  - кредитное страхование жизни (то же, что и TERM, другая ТС)
  --  !DD - первичное диагностирование смертельно опасного заболевания
  --  !WOP - освобождение от уплаты страховых взносов
  --  !PWOP - защита страховых взносов
  --  I! - инвест
  --
  --  [Accident]:
  --  !AD      - смерть НС
  --  !Dism    - телесные повреждения в результате НС
  --  !Adis    - инвалидность в результате НС
  --  !TPD     - инвалидность по любой причине (НС + болезнь)
  --  !ATD     - временная нетрудоспособность в результате НС
  --  H       - госпитализация в результате НС
  --

  FUNCTION get_add_info(p_cover_id IN NUMBER) RETURN add_info;
  FUNCTION get_calc_param
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN calc_param;

  /**
  Функция стандартного расчета брутто-тарифа через нетто-тариф и нагрузку
  Рекомендуетяс к использованию вместо аналогичной из пакета pkg_renlife_utils
  */
  FUNCTION standard_brutto_tariff_calc(par_cover_id NUMBER) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "смешанное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION end_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "смешанное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION end_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /**
   * Расчет брутто по покрытию договора страхования жизни по  программе "смешанное страхование жизни"
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

  FUNCTION end_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по  программе "смешанное страхование жизни"
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

  FUNCTION end_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION pepr_get_brutto
  (
    p_cover_id  IN NUMBER
   ,p_re_sign   IN NUMBER DEFAULT NULL
   ,p_no_change NUMBER DEFAULT 0
  ) RETURN NUMBER;
  FUNCTION pepr_get_brutto_chi
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION pepr_get_netto
  (
    p_cover_id  IN NUMBER
   ,p_re_sign   IN NUMBER DEFAULT NULL
   ,p_no_change NUMBER DEFAULT 0
  ) RETURN NUMBER;
  FUNCTION pepr_get_netto_chi
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
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

  FUNCTION pepr_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
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

  FUNCTION pepr_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION pepr_get_netto_new
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION pepr_get_brutto_new
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "пожизненное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION alltime_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION term_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION term_get_netto
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

  FUNCTION term_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
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

  FUNCTION term_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "кредитное страхование жизни (то же, что и TERM, другая ТС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION cri_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "кредитное страхование жизни (то же, что и TERM, другая ТС"
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
  FUNCTION cri_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION dd_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни "первичное диагностирование смертельно опасного заболевания"
   * для продукта Platinum_LA2_CityService
   * @author Kaplya P.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION dd_get_brutto_pla2_cs
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION dd_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни ""первичное диагностирование смертельно опасного заболевания"
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

  FUNCTION dd_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни ""первичное диагностирование смертельно опасного заболевания"
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

  FUNCTION dd_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "освобождение от уплаты страховых взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION wop_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет брутто по покрытию договора страхования жизни "инвест"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION i_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "инвест"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION i_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "смерть НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION ad_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "телесные повреждения в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION dism_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "инвалидность в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION adis_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "инвалидность по любой причине (НС + болезнь)"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION tpd_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "временная нетрудоспособность в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION atd_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни "госпитализация в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION h_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет суммы риска по покрытию договора страхования жизни "освобождение от уплаты страховых взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  /**
   * Расчет нетто по покрытию договора страхования жизни "госпитализация в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION acc_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION wop_get_risk(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
   * Расчет суммы риска по покрытию договора страхования жизни "освобождение от уплаты страховых взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION wop_get_risk_basic(p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION ppjl_get_risk_basic(p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION wop_get_risk_fla(p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION ppjl_get_risk_fla(p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION term_fla_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION term_fla_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /*
    Байтин А.
    198215. Расчет страховой суммы для продукта Ситисервиса.
  */
  FUNCTION prin_dp_new_city_get_insamount(par_cover_id NUMBER) RETURN NUMBER;
  FUNCTION investreserve_get_risk(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /*
  Капля П.
  Функция расчета нетто-тарифа для продукта Уверенный старт Русь
  */
  FUNCTION strong_start_get_netto(par_cover_id NUMBER) RETURN NUMBER;
  /*
    Капля П.
    Нетто- и Брутто- тарифы для Инвестора с ед. ф. оплаты
  */
  FUNCTION investor_lump_get_brutto(par_cover_id NUMBER) RETURN NUMBER;
  FUNCTION investor_lump_get_netto(par_cover_id NUMBER) RETURN NUMBER;

  /*
   * Расчет нетто по покрытию договора страхования жизни по "смешанное страхование"
   * для продукта Семейный Депозит 2014
   * использует специальные для продукта функции пакета pkg_amath
   * @author Капля П., Доброхотова И.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION end_get_netto_famdep2014
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * Расчет нетто по покрытию договора страхования жизни по  программе "смешанное страхование жизни"
   * для продукта Семейный Депозит 2014
   * использует специальные для продукта функции пакета pkg_amath
   * @author Капля П., Доброхотова И.
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
  FUNCTION end_get_netto_famdep2014
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет нетто-тарифа для программы Страхование жизни к сроку
  FUNCTION ins_life_to_date_get_netto(par_cover_id NUMBER) RETURN NUMBER;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет нетто-тарифа для программы Смерть Застрахованного по любой причине продуктов Наследия
  FUNCTION term_2_nasledie_get_netto(par_cover_id NUMBER) RETURN NUMBER;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет нетто-тарифа для программ Смерть НС, Смерть ДТП продуктов Наследия
  FUNCTION ad_nasledie_get_netto(par_cover_id NUMBER) RETURN NUMBER;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет брутто-тарифа по базовой формуле без учета повышающих коэффициентов
  FUNCTION get_brutto_base_formula(par_cover_id NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_prdlifecalc IS

  /*
   * Расчет брутто, нетто премии по покрытию договора страхования жизни
   * @author Marchuk A.
   * @version 1
  */
  --

  g_debug BOOLEAN := FALSE;

  gc_precision CONSTANT NUMBER := 7;

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  PROCEDURE log_autonomouns
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO p_cover_debug
      (p_cover_id, execution_date, operation_type, debug_message)
    VALUES
      (p_p_cover_id, SYSDATE, 'INS.PKG_PRDLIFECALC', substr(p_message, 1, 4000));
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
  BEGIN
    IF g_debug
    THEN
      log_autonomouns(p_p_cover_id, p_message);
    END IF;
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
    v_glag                 NUMBER;
    --
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'get_calc_param';
  
    RESULT calc_param;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name => 'p_cover_id', par_trace_var_value => p_cover_id);
    pkg_trace.add_variable(par_trace_var_name => 'p_re_sign', par_trace_var_value => p_re_sign);
  
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    result.p_cover_id := p_cover_id;
    v_cover_id        := p_cover_id;
    --
    SELECT CASE
             WHEN opt.description LIKE '%до потери постоянной работы%' THEN
              1
             ELSE
              0
           END flag
      INTO v_glag
      FROM p_cover            pc
          ,t_prod_line_option opt
     WHERE opt.id = pc.t_prod_line_option_id
       AND pc.p_cover_id = v_cover_id;
    --
    --dbms_output.put_line('GET_CALC_PARAM ID покрытия ' || v_cover_id);
    IF nvl(v_glag, 0) = 1
    THEN
      SELECT vas.as_assured_id
            ,decode(nvl(per.gender, vas.gender), 0, 'w', 1, 'm') gender_type
            ,vas.assured_contact_id
        INTO v_as_assured_id
            ,v_gender_type
            ,v_assured_contact_id
        FROM p_policy           pp
            ,as_asset           a
            ,ven_as_assured     vas
            ,p_cover            pc
            ,p_policy_contact   cn
            ,t_contact_pol_role cpr
            ,cn_person          per
       WHERE pc.p_cover_id = v_cover_id
         AND pc.as_asset_id = a.as_asset_id
         AND pp.policy_id = a.p_policy_id
         AND cn.policy_id = pp.policy_id
         AND cpr.id = cn.contact_policy_role_id
         AND cpr.brief = 'Страхователь'
         AND cn.contact_id = per.contact_id
         AND vas.as_assured_id = a.as_asset_id;
    ELSE
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
    END IF;
    --
    --dbms_output.put_line('ID застрахованного ' || v_as_assured_id);
    pkg_trace.add_variable('v_as_assured_id', v_as_assured_id);
    pkg_trace.add_variable('v_gender_type', v_gender_type);
  
    IF v_gender_type IS NULL
    THEN
      result.is_error      := 1;
      result.is_error_desc := 'Не определен тип застрахованного лица';
    END IF;
  
    --  Признак p_re_sign исключает возможность расчета тарифов при повышающих коэффициентах K и S
  
    SELECT pp.policy_id
          ,decode(p_re_sign, 1, least(nvl(s_coef, 0), 0), nvl(s_coef, 0)) s_coef
          ,decode(p_re_sign, 1, least(nvl(k_coef, 0), 0), nvl(k_coef, 0)) k_koef
          ,decode(p_re_sign, 1, least(nvl(s_coef_m, 0), 0), nvl(s_coef_m, 0)) s_coef_m
          ,decode(p_re_sign, 1, least(nvl(k_coef_m, 0), 0), nvl(k_coef_m, 0)) k_koef_m
          ,decode(p_re_sign, 1, least(nvl(s_coef_nm, 0), 0), nvl(s_coef_nm, 0)) s_coef_nm
          ,decode(p_re_sign, 1, least(nvl(k_coef_nm, 0), 0), nvl(k_coef_nm, 0)) k_koef_nm
           
          ,pc.rvb_value
          ,pc.normrate_value
          ,nvl(pc.insured_age, aa.insured_age) insured_age
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
          ,(CASE
             WHEN (SELECT COUNT(*)
                     FROM ins.t_prod_line_option opt
                         ,ins.t_product_line     pl
                         ,ins.t_lob_line         ll
                    WHERE opt.id = pc.t_prod_line_option_id
                      AND opt.product_line_id = pl.id
                      AND pl.t_lob_line_id = ll.t_lob_line_id
                      AND ll.brief = 'PEPR_INVEST_RESERVE') > 0 THEN
              1
             ELSE
              decode(pt.is_periodical, 0, 1, 1, 0)
           END) is_one_payment
           /*DECODE (pt.is_periodical, 0, 1, 1, 0) is_one_payment*/
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
          ,p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
  
    --ID версии договора (полиса) 
    pkg_trace.add_variable('v_policy_id', v_policy_id);
    --Возраст застрахованного 
    pkg_trace.add_variable('v_age', v_age);
  
    --dbms_output.put_line('ID версии договора (полиса) ' || v_policy_id);
    --dbms_output.put_line('Возраст застрахованного ' || v_age);
    IF v_age IS NULL
    THEN
      --dbms_output.put_line('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Возраст застрахованного не расчитан';
    END IF;
    --
    IF v_f IS NULL
    THEN
      dbms_output.put_line('Нагрузка не найдена....Устанавливаем флаг ошибки ');
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
    --dbms_output.put_line('ID discount_f= ' || v_discount_f_id);
    pkg_trace.add_variable('v_discount_f_id', v_discount_f_id);
    --
    IF v_discount_f_id IS NULL
    THEN
      dbms_output.put_line('Базовая нагрузка по договору не найдена....Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Базовая нагрузка по договору не найдена';
    END IF;
    --
    --dbms_output.put_line('Срок действия договора ' || to_char(v_period_year));
    pkg_trace.add_variable('v_period_year', v_period_year);
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
    pkg_trace.add_variable('v_lob_line_id', v_lob_line_id);
    pkg_trace.add_variable('v_number_of_payment', v_number_of_payment);
    pkg_trace.add_variable('v_fund_id', v_fund_id);
    --dbms_output.put_line('ID страховой программы ' || v_lob_line_id);
    --dbms_output.put_line('Количество платежей в год ' || v_number_of_payment);
    --dbms_output.put_line('Код валюты ответственности ' || v_fund_id);
    --
    pkg_trace.add_variable('v_normrate', v_normrate);
    pkg_trace.add_variable('v_f', v_f);
    pkg_trace.add_variable('v_deathrate_id', v_deathrate_id);
    --dbms_output.put_line('Установленная норма доходности для "страховой программы" ' || v_normrate);
    --dbms_output.put_line('v_f = ' || v_f);
    --dbms_output.put_line('deathrate_id = ' || v_deathrate_id);
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
  
    pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                   ,par_trace_subobj_name => vc_proc_name
                   ,par_message           => 'Ошибка. ' || result.is_error_desc);
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
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
  */
  FUNCTION standard_brutto_tariff_calc(par_cover_id NUMBER) RETURN NUMBER IS
    brutto_presc NUMBER;
    netto_presc  NUMBER;
    proc_name CONSTANT VARCHAR2(2000) := 'pkg_PrdLifeCalc.standard_brutto_tariff_calc';
    r_calc_param calc_param;
    RESULT       NUMBER;
  BEGIN
    SELECT nvl(pl.tariff_func_precision, 7)
          ,nvl(pl.tariff_netto_func_precision, 7)
      INTO brutto_presc
          ,netto_presc
      FROM t_product_line     pl
          ,t_prod_line_option plo
          ,p_cover            pc
     WHERE pl.id = plo.product_line_id
       AND pc.t_prod_line_option_id = plo.id
       AND pc.p_cover_id = par_cover_id;
  
    --Передалал на более технологичный (возможно более "тяжелый" подход)
    r_calc_param := get_calc_param(par_cover_id);
  
    r_calc_param.s_coef := nvl(greatest(nvl(r_calc_param.s_coef_m, r_calc_param.s_coef_nm)
                                       ,nvl(r_calc_param.s_coef_nm, r_calc_param.s_coef_m))
                              ,0) / 1000;
  
    r_calc_param.k_coef := nvl(greatest(nvl(r_calc_param.k_coef_m, r_calc_param.k_coef_nm)
                                       ,nvl(r_calc_param.k_coef_nm, r_calc_param.k_coef_m))
                              ,0) / 100;
  
    RESULT := ROUND(r_calc_param.tariff_netto / (1 - r_calc_param.f) *
                    (1 + nvl(r_calc_param.k_coef, 0)) + nvl(r_calc_param.s_coef, 0)
                   ,brutto_presc);
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении процедуры ' || proc_name || '. Текст ошибки: ' ||
                              SQLERRM);
  END standard_brutto_tariff_calc;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "смешанное страхование при наличии допсоглашения с изменением стр. суммы
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */
  FUNCTION end_add_ins_amount_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT    calc_param;
    v_axn_c   NUMBER;
    v_a_xn_c  NUMBER;
    v_axn_p   NUMBER;
    v_a_xn_p  NUMBER;
    v_p_p     NUMBER;
    v_p_c     NUMBER;
    v_s_p     NUMBER;
    v_s_c     NUMBER;
    v_delta_s NUMBER;
    v_f       NUMBER;
    v_i       NUMBER;
    v_t       NUMBER;
    v_x       NUMBER;
    v_n       NUMBER;
    v_g       VARCHAR2(1);
  BEGIN
    v_i := calc_param_curr.normrate;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --
    dbms_output.put_line('END_ADD_INS_AMOUNT_GET_BRUTTO  Зафиксировано изменение только страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      v_axn_c  := ROUND(pkg_amath.axn(v_x + v_t
                                     ,v_n - v_t
                                     ,v_g
                                     ,calc_param_curr.k_coef
                                     ,calc_param_curr.s_coef
                                     ,calc_param_curr.deathrate_id
                                     ,v_i)
                       ,gc_precision);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                       ,gc_precision);
    
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := calc_param_curr.ins_amount;
    
      v_delta_s := v_s_c - v_s_p;
    
      v_f   := calc_param_curr.f;
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      dbms_output.put_line('v_axn_c ' || v_axn_c || ' v_a_xn_c ' || v_a_xn_c || ' v_delta_S ' ||
                           v_delta_s || ' v_S_p ' || v_s_p || ' v_S_c ' || v_s_c);
      v_p_c := v_p_p + v_delta_s * v_axn_c / v_a_xn_c;
      dbms_output.put_line(' v_P_p ' || v_p_p || ' v_P_c ' || v_p_c);
      RESULT := calc_param_curr;
    
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - v_f)), gc_precision);
      dbms_output.put_line(' tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
    
      v_axn_c   := ROUND(pkg_amath.axn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_s_p     := calc_param_prev.ins_amount;
      v_s_c     := calc_param_curr.ins_amount;
      v_delta_s := v_s_c - v_s_p;
      v_p_p     := ROUND(calc_param_prev.tariff * (1 - v_f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := v_p_p + v_delta_s * v_axn_c / v_a_xn_c;
    
      dbms_output.put_line(' v_P_c ' || v_p_c);
      RESULT        := calc_param_curr;
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - v_f)), gc_precision);
      dbms_output.put_line(' tariff ' || result.tariff);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --
  /*
   * Расчет нетто тарифа по покрытию договора страхования жизни по "смешанное страхование при наличии допсоглашения с изменением стр. суммы
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_ins_amount_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT   calc_param;
    v_axn_c  NUMBER;
    v_a_xn_c NUMBER;
    v_axn_p  NUMBER;
    v_a_xn_p NUMBER;
    v_p_p    NUMBER;
    v_p_c    NUMBER;
    v_s_p    NUMBER;
    v_s_c    NUMBER;
    v_f      NUMBER;
    v_i      NUMBER;
    v_t      NUMBER;
    v_x      NUMBER;
    v_n      NUMBER;
    v_g      VARCHAR2(1);
  BEGIN
    v_i := calc_param_curr.normrate;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --
    dbms_output.put_line('END_ADD_INS_AMOUNT_GET_NETTO Зафиксировано изменение ТОЛЬКО СТРАХОВОЙ СУММЫ');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      v_axn_c  := ROUND(pkg_amath.axn(v_x + v_t
                                     ,v_n - v_t
                                     ,v_g
                                     ,calc_param_curr.k_coef
                                     ,calc_param_curr.s_coef
                                     ,calc_param_curr.deathrate_id
                                     ,v_i)
                       ,gc_precision);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_s_p    := calc_param_prev.ins_amount;
      v_s_c    := calc_param_curr.ins_amount;
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := v_p_p + (v_s_c - v_s_p) * v_axn_c / v_a_xn_c;
      dbms_output.put_line(' v_P_c ' || v_p_c);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      v_s_p   := calc_param_prev.ins_amount;
      v_s_c   := calc_param_curr.ins_amount;
      v_p_p   := ROUND(calc_param_prev.tariff * (1 - v_f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := v_p_p + (v_s_c - v_s_p) * v_axn_c / v_a_xn_c;
      dbms_output.put_line(' v_P_c ' || v_p_c);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
    ELSE
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет брутто тарифа по покрытию договора страхования жизни по "смешанное страхование при наличии допсоглашения с изменением стр. премии
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_fee_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    --
    RESULT     calc_param;
    v_axn_p    NUMBER;
    v_axn_c    NUMBER;
    v_a_xn_c   NUMBER;
    v_a_xn_p   NUMBER;
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
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
    v_gd       NUMBER;
    v_gf_p     NUMBER;
    v_gf_c     NUMBER;
    v_delta_g  NUMBER;
    v_pc       NUMBER;
    v_pp       NUMBER;
    --
  BEGIN
    v_i := calc_param_curr.normrate;
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
    v_s_p := calc_param_prev.ins_amount;
    --
    v_pc := pkg_tariff.calc_tarif_mul(calc_param_curr.p_cover_id);
    v_pp := pkg_tariff.calc_tarif_mul(calc_param_prev.p_cover_id);
    --
    IF v_pp != 0
    THEN
      v_gf_p := calc_param_prev.fee / nvl(v_pp, 1);
    ELSE
      v_gf_p := NULL;
    END IF;
    --
    IF v_pc != 0
    THEN
      v_gf_c := calc_param_curr.fee / nvl(v_pc, 1);
    ELSE
      v_gf_c := NULL;
    END IF;
  
    v_delta_g := v_gf_c - v_gf_p;
  
    dbms_output.put_line('END_ADD_FEE_GET_BRUTTO  Зафиксировано изменение страховой премии');
  
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 1
    THEN
      dbms_output.put_line('v_x ' || v_x || ' v_t ' || v_t || ' v_n ' || v_n || ' v_i ' || v_i ||
                           ' k_coef ' || calc_param_curr.k_coef || ' s_coef ' ||
                           calc_param_curr.s_coef);
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Периодическая оплата)');
    
      v_axn_c  := pkg_amath.axn(v_x + v_t
                               ,v_n - v_t
                               ,v_g
                               ,calc_param_curr.k_coef
                               ,calc_param_curr.s_coef
                               ,calc_param_prev.deathrate_id
                               ,v_i);
      v_a_xn_c := pkg_amath.a_xn(v_x + v_t
                                ,v_n - v_t
                                ,v_g
                                ,calc_param_curr.k_coef
                                ,calc_param_curr.s_coef
                                ,1
                                ,calc_param_prev.deathrate_id
                                ,v_i);
    
      v_f := calc_param_curr.f;
      dbms_output.put_line(' v_Gf_p ' || v_gf_p || ' v_Gf_c ' || v_gf_c || ' v_delta_G ' || v_delta_g);
    
      v_p_p := calc_param_prev.tariff_netto * v_s_p;
      /* P'= P+ delta G * (1-f) */
      v_p_c := v_p_p + v_delta_g * (1 - v_f);
    
      dbms_output.put_line(' v_P_p ' || v_p_p || ' v_P_c ' || v_p_c || ' delta P ' || (v_p_c - v_p_p));
    
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c || ' v_axn_c ' || v_axn_c);
      v_s_c := v_s_p + ((v_p_c - v_p_p) * v_a_xn_c / v_axn_c);
    
      v_s_c := ROUND(v_s_c, gc_precision);
    
      dbms_output.put_line(' v_S_p ' || v_s_p || ' v_S_c ' || v_s_c || ' v_f ' || v_f);
    
      RESULT            := calc_param_curr;
      result.tariff     := v_gf_c / v_s_c;
      result.ins_amount := v_s_c;
    
      dbms_output.put_line(' tariff ' || result.tariff);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Единовременная оплата)');
      v_axn_c  := pkg_amath.axn(v_x + v_t
                               ,v_n - v_t
                               ,v_g
                               ,calc_param_curr.k_coef
                               ,calc_param_curr.s_coef
                               ,calc_param_prev.deathrate_id
                               ,v_i);
      v_a_xn_c := pkg_amath.a_xn(v_x + v_t
                                ,v_n - v_t
                                ,v_g
                                ,calc_param_curr.k_coef
                                ,calc_param_curr.s_coef
                                ,1
                                ,calc_param_prev.deathrate_id
                                ,v_i);
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_s_p, gc_precision);
      v_p_c    := v_gf_c / (1 - v_f);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      v_s_c             := v_s_p + (v_p_c / v_axn_c);
      v_s_c             := ROUND(v_s_c, 10);
      RESULT            := calc_param_curr;
      result.tariff     := v_gf_c / (v_s_c * (1 - v_f));
      result.ins_amount := v_s_c;
    
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет нетто тарифа по покрытию договора страхования жизни по "смешанное страхование при наличии допсоглашения с изменением стр. премии
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_fee_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT     calc_param;
    v_axn_p    NUMBER;
    v_axn_c    NUMBER;
    v_a_xn_c   NUMBER;
    v_a_xn_p   NUMBER;
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
  
    v_gd   NUMBER;
    v_gf_p NUMBER;
    v_gf_c NUMBER;
    v_pc   NUMBER;
    v_pp   NUMBER;
  BEGIN
    dbms_output.put_line('END_ADD_FEE_GET_NETTO  Зафиксировано изменение страховой премии');
    RESULT := end_add_fee_get_brutto(calc_param_prev
                                    ,calc_param_curr
                                    ,cover_add_info
                                    ,p_premia_base_type);
  
    v_s_c := result.ins_amount;
    dbms_output.put_line('END_ADD_FEE_GET_NETTO v_S_c ' || v_s_c);
  
    result.tariff_netto := calc_param_prev.tariff_netto * calc_param_prev.ins_amount +
                           (result.tariff * v_s_c -
                           calc_param_prev.tariff * calc_param_prev.ins_amount) *
                           (1 - calc_param_curr.f);
    result.tariff_netto := result.tariff_netto / v_s_c;
    dbms_output.put_line('END_ADD_FEE_GET_NETTO tariff_netto ' || result.tariff_netto);
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет брутто по покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Замена застрахованного
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_assured_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT   calc_param;
    v_axn_c  NUMBER;
    v_a_xn_c NUMBER;
    v_axn_p  NUMBER;
    v_a_xn_p NUMBER;
    v_p_p    NUMBER;
    v_p_c    NUMBER;
    v_s_p    NUMBER;
    v_s_c    NUMBER;
    v_f      NUMBER;
    v_i      NUMBER;
    v_t      NUMBER;
    v_x      NUMBER;
    v_n      NUMBER;
    v_g      VARCHAR2(1);
  BEGIN
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_n   := calc_param_curr.period_year;
    v_g   := calc_param_curr.gender_type;
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    dbms_output.put_line(' Зафиксировано изменение застрахованного');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (периодичная оплата)');
      v_axn_c := pkg_amath.axn(calc_param_curr.age + v_t
                              ,v_n - v_t
                              ,v_g
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,calc_param_prev.deathrate_id
                              ,v_i);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := pkg_amath.a_xn(calc_param_curr.age + v_t
                                ,v_n - v_t
                                ,v_g
                                ,calc_param_curr.k_coef
                                ,calc_param_curr.s_coef
                                ,1
                                ,calc_param_prev.deathrate_id
                                ,v_i);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_axn_p := pkg_amath.axn(calc_param_prev.age + v_t
                              ,v_n - v_t
                              ,v_g
                              ,calc_param_prev.k_coef
                              ,calc_param_prev.s_coef
                              ,calc_param_prev.deathrate_id
                              ,calc_param_prev.normrate);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := ROUND(v_s_p * (v_axn_c - v_axn_p) / v_a_xn_c + v_p_p * v_a_xn_p / v_a_xn_c
                    ,gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (Единовременная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_curr.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_p_p         := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c         := ROUND(v_s_c * (v_axn_c - v_axn_p), gc_precision);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (периодичная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_curr.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_s_c := ROUND(v_s_p * (v_axn_p / v_axn_c) + v_p_p * (v_a_xn_c - v_a_xn_c) / v_axn_c
                    ,gc_precision);
      dbms_output.put_line(' v_S_c ' || v_s_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (Единовременная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_curr.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_p_p         := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c         := v_p_p;
      v_s_c         := ROUND(v_s_p * (v_axn_p / v_axn_c), gc_precision);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --
  /*
   * Расчет нетто тарифа по покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Замена застрахованного
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_assured_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT   calc_param;
    v_axn_c  NUMBER;
    v_a_xn_c NUMBER;
    v_axn_p  NUMBER;
    v_a_xn_p NUMBER;
    v_p_p    NUMBER;
    v_p_c    NUMBER;
    v_s_p    NUMBER;
    v_s_c    NUMBER;
    v_f      NUMBER;
    v_i      NUMBER;
    v_t      NUMBER;
    v_x      NUMBER;
    v_n      NUMBER;
    v_g      VARCHAR2(1);
  BEGIN
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_n   := calc_param_curr.period_year;
    v_g   := calc_param_curr.gender_type;
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    dbms_output.put_line(' Зафиксировано изменение застрахованного');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (периодичная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := ROUND(v_s_p * (v_axn_c - v_axn_p) / v_a_xn_c + v_p_p * v_a_xn_p / v_a_xn_c
                    ,gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff_netto := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (Единовременная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_curr.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_p_p               := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p
                                  ,gc_precision);
      v_p_c               := ROUND(v_s_c * (v_axn_c - v_axn_p), gc_precision);
      result.tariff_netto := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (периодичная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_curr.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_s_c := ROUND(v_s_p * (v_axn_p / v_axn_c) + v_p_p * (v_a_xn_c - v_a_xn_c) / v_axn_c
                    ,gc_precision);
      dbms_output.put_line(' v_S_c ' || v_s_c);
      result.tariff_netto := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (Единовременная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(calc_param_curr.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_curr.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_axn_p := ROUND(pkg_amath.axn(calc_param_prev.age + v_t
                                    ,v_n - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_p_p               := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p
                                  ,gc_precision);
      v_p_c               := v_p_p;
      v_s_c               := ROUND(v_s_p * (v_axn_p / v_axn_c), gc_precision);
      result.tariff_netto := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSE
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Изменение срока
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_period_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
    --
    v_axn_c NUMBER;
    v_axn_p NUMBER;
    --
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    --
    v_p_p NUMBER;
    v_p_c NUMBER;
    v_s_p NUMBER;
    v_s_c NUMBER;
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
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_g   := calc_param_curr.gender_type;
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    --
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
  
    v_f_p := calc_param_prev.f;
    v_f_c := calc_param_curr.f;
    --
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)');
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_c - v_t ' || (v_n_c - v_t));
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,v_n_c - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_p - v_t ' || (v_n_p - v_t));
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,v_n_p - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
    
      v_p_c := ROUND(v_s_p * (v_axn_c - v_axn_p) / v_a_xn_c + v_p_p * (v_a_xn_p / v_a_xn_c)
                    ,gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - v_f_c)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата) ');
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_curr.period_year - v_t
                                    ,calc_param_curr.gender_type
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_prev.period_year - v_t
                                    ,calc_param_prev.gender_type
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := calc_param_prev.ins_amount;
      v_p_c := ROUND(v_p_p + v_s_c * (v_axn_c - v_axn_p), gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_curr.period_year - v_t
                                    ,calc_param_curr.gender_type
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_prev.period_year - v_t
                                    ,calc_param_prev.gender_type
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_s_c := ROUND(v_s_p * (v_axn_p / v_axn_c) + v_p_p * (v_a_xn_c - v_a_xn_p) / v_axn_c
                    ,gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_p_p ' || calc_param_prev.tariff_netto || ' v_P_p ' || v_p_p ||
                           ' v_S_c ' || v_s_c);
      result.tariff_netto := v_p_c / v_s_c;
      result.tariff       := ROUND(result.tariff_netto / (1 - calc_param_curr.f), gc_precision);
    
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_curr.period_year - v_t
                                    ,calc_param_curr.gender_type
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_prev.period_year - v_t
                                    ,calc_param_prev.gender_type
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := ROUND(v_s_p * (v_axn_p / v_axn_c), gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSE
      dbms_output.put_line('Условия расчета не описаны по алгоритму');
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --
  /*
   * Расчет нетто по покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Изменение срока
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_period_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
    --
    v_axn_c NUMBER;
    v_axn_p NUMBER;
    --
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    --
    v_p_p NUMBER;
    v_p_c NUMBER;
    v_s_p NUMBER;
    v_s_c NUMBER;
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
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_g   := calc_param_curr.gender_type;
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    --
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
  
    v_f_p := calc_param_prev.f;
    v_f_c := calc_param_curr.f;
    --
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)');
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_c - v_t ' || (v_n_c - v_t));
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,v_n_c - v_t
                                    ,v_g
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_p - v_t ' || (v_n_p - v_t));
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,v_n_p - v_t
                                    ,v_g
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - v_f_p) * v_s_p, gc_precision);
    
      v_p_c := ROUND(v_s_p * (v_axn_c - v_axn_p) / v_a_xn_c + v_p_p * (v_a_xn_p / v_a_xn_c)
                    ,gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата) ');
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_curr.period_year - v_t
                                    ,calc_param_curr.gender_type
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_prev.period_year - v_t
                                    ,calc_param_prev.gender_type
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := calc_param_prev.ins_amount;
      v_p_c := ROUND(v_p_p + v_s_c * (v_axn_c - v_axn_p), gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_curr.period_year - v_t
                                    ,calc_param_curr.gender_type
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_prev.period_year - v_t
                                    ,calc_param_prev.gender_type
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_s_c := ROUND(v_s_p * (v_axn_p / v_axn_c) + v_p_p * (v_a_xn_c - v_a_xn_p) / v_axn_c
                    ,gc_precision);
      v_p_c := v_p_p;
    
      dbms_output.put_line(' v_P_p ' || v_p_p);
    
      result.tariff_netto := v_p_c / v_s_c;
    
      dbms_output.put_line(' result ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_axn_c := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_curr.period_year - v_t
                                    ,calc_param_curr.gender_type
                                    ,calc_param_curr.k_coef
                                    ,calc_param_curr.s_coef
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_c ' || v_axn_c);
      --
      v_axn_p := ROUND(pkg_amath.axn(v_x + v_t
                                    ,calc_param_prev.period_year - v_t
                                    ,calc_param_prev.gender_type
                                    ,calc_param_prev.k_coef
                                    ,calc_param_prev.s_coef
                                    ,calc_param_prev.deathrate_id
                                    ,calc_param_prev.normrate)
                      ,gc_precision);
      dbms_output.put_line(' v_axn_p ' || v_axn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := ROUND(v_s_p * (v_axn_p / v_axn_c), gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSE
      dbms_output.put_line('Условия расчета не описаны по алгоритму');
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет бруттопо покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Изменение валюты
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_fund_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT       calc_param;
    v_axn_c      NUMBER;
    v_a_xn_c     NUMBER;
    v_axn_p      NUMBER;
    v_a_xn_p     NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_s_p        NUMBER;
    v_s_c        NUMBER;
    v_f          NUMBER;
    v_i          NUMBER;
    v_t          NUMBER;
    v_x          NUMBER;
    v_n          NUMBER;
    v_fund_rate  NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    v_i := calc_param_curr.normrate;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    --
    v_axn_p := pkg_amath.axn(calc_param_prev.age + v_t
                            ,calc_param_curr.period_year - v_t
                            ,calc_param_curr.gender_type
                            ,calc_param_curr.k_coef
                            ,calc_param_curr.s_coef
                            ,calc_param_prev.deathrate_id
                            ,calc_param_prev.normrate);
    dbms_output.put_line(' v_axn_p ' || v_axn_p);
    v_a_xn_p := pkg_amath.a_xn(calc_param_prev.age + v_t
                              ,calc_param_curr.period_year - v_t
                              ,calc_param_curr.gender_type
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,1
                              ,calc_param_prev.deathrate_id
                              ,calc_param_prev.normrate);
    --
    v_axn_c  := pkg_amath.axn(calc_param_prev.age + v_t
                             ,calc_param_curr.period_year - v_t
                             ,calc_param_curr.gender_type
                             ,calc_param_curr.k_coef
                             ,calc_param_curr.s_coef
                             ,calc_param_curr.deathrate_id
                             ,v_i);
    v_a_xn_c := pkg_amath.a_xn(calc_param_prev.age + v_t
                              ,calc_param_curr.period_year - v_t
                              ,calc_param_curr.gender_type
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,1
                              ,calc_param_curr.deathrate_id
                              ,v_i);
  
    v_ins_amount := (calc_param_prev.ins_amount / v_fund_rate) * v_axn_p / v_axn_c +
                    calc_param_curr.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount /
                    v_fund_rate * (v_a_xn_c - v_a_xn_p) / v_axn_c;
    --
    v_p_c := calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount /
             v_fund_rate;
    dbms_output.put_line(' v_P_c ' || v_p_c);
    --
    v_axn_c  := pkg_amath.axn(calc_param_curr.age + calc_param_curr.t
                             ,calc_param_curr.period_year - calc_param_curr.t
                             ,calc_param_curr.gender_type
                             ,calc_param_curr.k_coef
                             ,calc_param_curr.s_coef
                             ,calc_param_curr.deathrate_id
                             ,v_i);
    v_a_xn_c := pkg_amath.a_xn(calc_param_curr.age + calc_param_curr.t
                              ,calc_param_curr.period_year - calc_param_curr.t
                              ,calc_param_curr.gender_type
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,1
                              ,calc_param_curr.deathrate_id
                              ,v_i);
    --
    v_p_c         := v_p_c + (calc_param_prev.ins_amount - v_ins_amount) * v_axn_c / v_a_xn_c;
    result.tariff := v_p_c / calc_param_curr.ins_amount * (1 - calc_param_curr.f);
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет нетто оп покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Изменение валюты
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION end_add_fund_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT       calc_param;
    v_axn_c      NUMBER;
    v_a_xn_c     NUMBER;
    v_axn_p      NUMBER;
    v_a_xn_p     NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_s_p        NUMBER;
    v_s_c        NUMBER;
    v_f          NUMBER;
    v_i          NUMBER;
    v_t          NUMBER;
    v_x          NUMBER;
    v_n          NUMBER;
    v_fund_rate  NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    v_i := calc_param_curr.normrate;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    --
    v_axn_p := pkg_amath.axn(calc_param_prev.age + v_t
                            ,calc_param_curr.period_year - v_t
                            ,calc_param_curr.gender_type
                            ,calc_param_curr.k_coef
                            ,calc_param_curr.s_coef
                            ,calc_param_prev.deathrate_id
                            ,calc_param_prev.normrate);
    dbms_output.put_line(' v_axn_p ' || v_axn_p);
    v_a_xn_p := pkg_amath.a_xn(calc_param_prev.age + v_t
                              ,calc_param_curr.period_year - v_t
                              ,calc_param_curr.gender_type
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,1
                              ,calc_param_prev.deathrate_id
                              ,calc_param_prev.normrate);
    --
    v_axn_c  := pkg_amath.axn(calc_param_prev.age + v_t
                             ,calc_param_curr.period_year - v_t
                             ,calc_param_curr.gender_type
                             ,calc_param_curr.k_coef
                             ,calc_param_curr.s_coef
                             ,calc_param_curr.deathrate_id
                             ,v_i);
    v_a_xn_c := pkg_amath.a_xn(calc_param_prev.age + v_t
                              ,calc_param_curr.period_year - v_t
                              ,calc_param_curr.gender_type
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,1
                              ,calc_param_curr.deathrate_id
                              ,v_i);
  
    v_ins_amount := (calc_param_prev.ins_amount / v_fund_rate) * v_axn_p / v_axn_c +
                    calc_param_curr.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount /
                    v_fund_rate * (v_a_xn_c - v_a_xn_p) / v_axn_c;
    --
    v_p_c := calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount /
             v_fund_rate;
    dbms_output.put_line(' v_P_c ' || v_p_c);
    --
    v_axn_c  := pkg_amath.axn(calc_param_curr.age + calc_param_curr.t
                             ,calc_param_curr.period_year - calc_param_curr.t
                             ,calc_param_curr.gender_type
                             ,calc_param_curr.k_coef
                             ,calc_param_curr.s_coef
                             ,calc_param_curr.deathrate_id
                             ,v_i);
    v_a_xn_c := pkg_amath.a_xn(calc_param_curr.age + calc_param_curr.t
                              ,calc_param_curr.period_year - calc_param_curr.t
                              ,calc_param_curr.gender_type
                              ,calc_param_curr.k_coef
                              ,calc_param_curr.s_coef
                              ,1
                              ,calc_param_curr.deathrate_id
                              ,v_i);
    --
    v_p_c               := v_p_c + (calc_param_prev.ins_amount - v_ins_amount) * v_axn_c / v_a_xn_c;
    result.tariff_netto := v_p_c / calc_param_curr.ins_amount;
    --
    RETURN RESULT;
  END;
  --
  /*
   * Расчет нетто оп покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Изменение валюты
   * @author Marchuk A.
   * @param p_cover_id     ИД текущего покрытия
  */

  FUNCTION end_add_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn_p NUMBER;
    v_axn_p  NUMBER;
    --
    v_a_xn_c NUMBER;
    v_axn_c  NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_add_info add_info;
    --
    calc_result calc_param;
    --
    d_result NUMBER;
    result_1 NUMBER DEFAULT 0;
    result_2 NUMBER DEFAULT 0;
    RESULT   NUMBER;
  
    v_ins_amount NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_pc         NUMBER; --Произведение коэффициентов покрытия
    v_s1         NUMBER;
    v_s_c        NUMBER;
    v_s_p        NUMBER;
    v_fund_rate  NUMBER;
  BEGIN
    dbms_output.put_line(' END_add_get_brutto');
  
    r_add_info        := get_add_info(p_cover_id);
    r_calc_param_prev := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
    r_calc_param_curr := get_calc_param(p_cover_id, p_re_sign);
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := end_add_assured_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := end_add_period_get_brutto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение страховой суммы ...Было ' ||
                             r_calc_param_prev.ins_amount || ' Стало ' ||
                             r_calc_param_curr.ins_amount);
        --
        calc_result := end_add_ins_amount_get_brutto(r_calc_param_prev
                                                    ,r_calc_param_curr
                                                    ,r_add_info
                                                    ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSIF r_add_info.is_ins_amount_change = 0
            AND (r_add_info.is_assured_change = 0 AND r_add_info.is_payment_terms_id_change = 0 AND
            r_add_info.is_periodical_change = 0)
      THEN
        --
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение валюты договора ');
        --
        v_axn_p := pkg_amath.axn(r_calc_param_prev.age + r_calc_param_curr.t
                                ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                ,r_calc_param_curr.gender_type
                                ,r_calc_param_curr.k_coef
                                ,r_calc_param_curr.s_coef
                                ,r_calc_param_prev.deathrate_id
                                ,r_calc_param_prev.normrate);
        dbms_output.put_line(' v_axn_p ' || v_axn_p);
        v_a_xn_p := pkg_amath.a_xn(r_calc_param_prev.age + r_calc_param_curr.t
                                  ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                  ,r_calc_param_curr.gender_type
                                  ,r_calc_param_curr.k_coef
                                  ,r_calc_param_curr.s_coef
                                  ,1
                                  ,r_calc_param_prev.deathrate_id
                                  ,r_calc_param_prev.normrate);
        --
        v_axn_c  := pkg_amath.axn(r_calc_param_prev.age + r_calc_param_curr.t
                                 ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                 ,r_calc_param_curr.gender_type
                                 ,r_calc_param_curr.k_coef
                                 ,r_calc_param_curr.s_coef
                                 ,r_calc_param_curr.deathrate_id
                                 ,r_calc_param_curr.normrate);
        v_a_xn_c := pkg_amath.a_xn(r_calc_param_prev.age + r_calc_param_curr.t
                                  ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                  ,r_calc_param_curr.gender_type
                                  ,r_calc_param_curr.k_coef
                                  ,r_calc_param_curr.s_coef
                                  ,1
                                  ,r_calc_param_prev.deathrate_id
                                  ,r_calc_param_curr.normrate);
      
        v_ins_amount := (r_calc_param_prev.ins_amount / v_fund_rate) * v_axn_p / v_axn_c +
                        r_calc_param_curr.tariff * (1 - r_calc_param_prev.f) *
                        r_calc_param_prev.ins_amount / v_fund_rate * (v_a_xn_c - v_a_xn_p) / v_axn_c;
        --
        v_p_c := r_calc_param_prev.tariff * (1 - r_calc_param_prev.f) * r_calc_param_prev.ins_amount /
                 v_fund_rate;
        dbms_output.put_line(' v_P_c ' || v_p_c);
        --
        v_axn_c  := pkg_amath.axn(r_calc_param_curr.age + r_calc_param_curr.t
                                 ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                 ,r_calc_param_curr.gender_type
                                 ,r_calc_param_curr.k_coef
                                 ,r_calc_param_curr.s_coef
                                 ,r_calc_param_prev.deathrate_id
                                 ,r_calc_param_curr.normrate);
        v_a_xn_c := pkg_amath.a_xn(r_calc_param_curr.age + r_calc_param_curr.t
                                  ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                  ,r_calc_param_curr.gender_type
                                  ,r_calc_param_curr.k_coef
                                  ,r_calc_param_curr.s_coef
                                  ,1
                                  ,r_calc_param_prev.deathrate_id
                                  ,r_calc_param_curr.normrate);
        --
        v_p_c  := v_p + (r_calc_param_prev.ins_amount - v_ins_amount) * v_axn_c / v_a_xn_c;
        RESULT := v_p_c / r_calc_param_curr.ins_amount * (1 - r_calc_param_curr.f);
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      dbms_output.put_line(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := end_add_assured_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
      
        calc_result := end_add_period_get_brutto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := end_add_fee_get_brutto(r_calc_param_prev
                                             ,r_calc_param_curr
                                             ,r_add_info
                                             ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /*
   * Расчет нетто оп покрытию договора страхования жизни "Смешанное страхование" при наличии доп соглашения Изменение валюты
   * @author Marchuk A.
   * @param p_cover_id     ИД текущего покрытия
  */

  FUNCTION end_add_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn_p NUMBER;
    v_axn_p  NUMBER;
    --
    v_a_xn_c NUMBER;
    v_axn_c  NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_add_info add_info;
    --
    calc_result calc_param;
    --
    d_result NUMBER;
    result_1 NUMBER DEFAULT 0;
    result_2 NUMBER DEFAULT 0;
    RESULT   NUMBER;
  
    v_ins_amount NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_pc         NUMBER; --Произведение коэффициентов покрытия
    v_s1         NUMBER;
    v_s_c        NUMBER;
    v_s_p        NUMBER;
    v_fund_rate  NUMBER;
  BEGIN
    r_add_info        := get_add_info(p_cover_id);
    r_calc_param_prev := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
    r_calc_param_curr := get_calc_param(p_cover_id, p_re_sign);
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := end_add_assured_get_netto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := end_add_period_get_netto(r_calc_param_prev
                                               ,r_calc_param_curr
                                               ,r_add_info
                                               ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение страховой суммы ...');
        calc_result := end_add_ins_amount_get_netto(r_calc_param_prev
                                                   ,r_calc_param_curr
                                                   ,r_add_info
                                                   ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSIF r_add_info.is_ins_amount_change = 0
            AND (r_add_info.is_assured_change = 0 AND r_add_info.is_payment_terms_id_change = 0 AND
            r_add_info.is_periodical_change = 0)
      THEN
        --
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение валюты договора ');
        --
        calc_result := end_add_fund_get_netto(r_calc_param_prev
                                             ,r_calc_param_curr
                                             ,r_add_info
                                             ,r_calc_param_curr.premia_base_type);
        RESULT      := v_p_c / r_calc_param_curr.ins_amount;
        RESULT      := calc_result.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      dbms_output.put_line(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := end_add_assured_get_netto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
      
        calc_result := end_add_period_get_netto(r_calc_param_prev
                                               ,r_calc_param_curr
                                               ,r_add_info
                                               ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := end_add_fee_get_netto(r_calc_param_prev
                                            ,r_calc_param_curr
                                            ,r_add_info
                                            ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Дожитие с возвратом взносов" при наличии допсоглашения
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_ins_amount_get_brutto
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
    v_iax1n    NUMBER;
    v_ax1n     NUMBER;
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
    v_nex_c    NUMBER;
    v_nex_p    NUMBER;
    v_bt_p     NUMBER;
    v_bt_c     NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_iax1n_c  NUMBER;
    v_iax1n_p  NUMBER;
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_gd       NUMBER;
    v_gf_p     NUMBER;
    v_gf_c     NUMBER;
  BEGIN
    v_i := calc_param_curr.normrate;
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
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    dbms_output.put_line(' Зафиксировано изменение страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой суммы (Периодическая оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
    
      dbms_output.put_line('nEx_c ' || v_nex_c || ' IAx1n_c ' || v_iax1n_c || ' a_xn_c ' || v_a_xn_c ||
                           ' ax1n_c ' || v_ax1n_c);
      dbms_output.put_line('nEx_p ' || v_nex_p || ' IAx1n_p ' || v_iax1n_p || ' a_xn_p ' || v_a_xn_p ||
                           ' ax1n_c ' || v_ax1n_p);
    
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      dbms_output.put_line('Bt_p ' || v_bt_p || ' Bt_c ' || v_bt_c || ' tariff_p ' ||
                           calc_param_prev.tariff);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
      v_gf_c := v_gf_p - (v_s_c - v_s_p) * (v_nex_c / v_bt_c);
    
      dbms_output.put_line('v_Gf_p ' || v_gf_p || ' Gf_c ' || v_gf_c);
    
      result.tariff := ROUND(v_gf_c / v_s_c, gc_precision);
    
      dbms_output.put_line('tariff ' || result.tariff);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой суммы (Единовременная оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p        := calc_param_prev.tariff * v_s_p;
      v_gd          := (v_s_c - v_s_p) * (v_nex_p) / (1 - v_f - v_ax1n_c);
      result.tariff := ROUND(v_gd / v_s_c * (1 - v_f), gc_precision);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет нетто по покрытию договора страхования жизни по "смешанное страхование при наличии допсоглашения
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_ins_amount_get_netto
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
    v_iax1n    NUMBER;
    v_ax1n     NUMBER;
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
    v_nex_c    NUMBER;
    v_nex_p    NUMBER;
    v_bt_p     NUMBER;
    v_bt_c     NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_iax1n_c  NUMBER;
    v_iax1n_p  NUMBER;
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_gd       NUMBER;
    v_gf_p     NUMBER;
    v_gf_c     NUMBER;
  BEGIN
    v_i := calc_param_curr.normrate;
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
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    dbms_output.put_line(' Зафиксировано изменение страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой суммы (Периодическая оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
    
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
      v_gf_c := v_gf_p - (v_s_c - v_s_p) * (v_nex_c / v_bt_c);
    
      result.tariff_netto := ROUND(v_gf_c * (1 - v_f) / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой суммы (Единовременная оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
    
      v_gd                := (v_s_c - v_s_p) * (v_nex_c) / (1 - v_f - v_ax1n_c);
      result.tariff_netto := ROUND(v_gd * (1 - v_f) / v_s_c, gc_precision);
    ELSE
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии допсоглашения изменение страховой премии
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_fee_get_brutto
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
    v_iax1n    NUMBER;
    v_ax1n     NUMBER;
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
    v_nex_c    NUMBER;
    v_nex_p    NUMBER;
    v_bt_p     NUMBER;
    v_bt_c     NUMBER;
    v_f        NUMBER;
    v_i        NUMBER;
    v_t        NUMBER;
    v_x        NUMBER;
    v_n        NUMBER;
    v_iax1n_c  NUMBER;
    v_iax1n_p  NUMBER;
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_gd       NUMBER;
    v_gf_p     NUMBER;
    v_gf_c     NUMBER;
    v_delta_g  NUMBER;
    v_pc       NUMBER;
    v_pp       NUMBER;
  BEGIN
  
    dbms_output.put_line('PEPR_ADD_FEE_GET_BRUTTO');
    v_i := calc_param_curr.normrate;
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
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
  
    v_pc := pkg_tariff.calc_tarif_mul(calc_param_curr.p_cover_id);
    v_pp := pkg_tariff.calc_tarif_mul(calc_param_prev.p_cover_id);
  
    dbms_output.put_line(' v_Pc ' || v_pc || ' v_Pp ' || v_pp);
  
    IF nvl(v_pp, 1) != 0
    THEN
      v_gf_p := ROUND(calc_param_prev.fee / v_pp, 2);
    END IF;
  
    IF nvl(v_pc, 1) != 0
    THEN
      v_gf_c := ROUND(calc_param_curr.fee / v_pc, 2);
    END IF;
  
    v_delta_g := v_gf_c - v_gf_p;
  
    dbms_output.put_line('Зафиксировано изменение страховой премии delta_G' || v_delta_g);
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 1
    THEN
    
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Периодическая оплата)');
    
      v_nex_c   := pkg_amath.nex(v_x + v_t
                                ,v_n - v_t
                                ,v_g
                                ,v_k_coef_c
                                ,v_s_coef_c
                                ,calc_param_curr.deathrate_id
                                ,v_i);
      v_iax1n_c := pkg_amath.iax1n(v_x + v_t
                                  ,v_n - v_t
                                  ,v_g
                                  ,v_k_coef_c
                                  ,v_s_coef_c
                                  ,calc_param_curr.deathrate_id
                                  ,v_i);
      v_a_xn_c  := pkg_amath.a_xn(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,1
                                 ,calc_param_prev.deathrate_id
                                 ,v_i);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --    Расчет значений для предшествующего застрахованного не производится, т.к. не требуется
      --
      dbms_output.put_line('v_Gf_p ' || v_gf_p || ' v_Gf_c ' || v_gf_c);
      dbms_output.put_line('nEx_c ' || v_nex_c || ' IAx1n_c ' || v_iax1n_c || ' a_xn_c ' || v_a_xn_c ||
                           ' ax1n_c ' || v_ax1n_c);
    
      RESULT := calc_param_curr;
    
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      dbms_output.put_line(' v_Bt_c ' || v_bt_c);
    
      v_s_c := v_s_p - (v_gf_c - v_gf_p) * v_bt_c / v_nex_c;
      v_s_c := v_s_c;
    
      dbms_output.put_line('v_S_c  ' || v_s_c);
      --*
      result.tariff := ROUND(v_gf_c / v_s_c, 9);
    
      dbms_output.put_line('tariff ' || result.tariff);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Единовременная оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      dbms_output.put_line('v_Gf_p ' || v_gf_p || ' v_Gf_c ' || v_gf_c);
      dbms_output.put_line('nEx_c ' || v_nex_c || ' IAx1n_c ' || v_iax1n_c || ' a_xn_c ' || v_a_xn_c ||
                           ' ax1n_c ' || v_ax1n_c);
      dbms_output.put_line('nEx_p ' || v_nex_p || ' IAx1n_p ' || v_iax1n_p || ' a_xn_p ' || v_a_xn_p ||
                           ' ax1n_p ' || v_ax1n_p);
    
      RESULT := calc_param_curr;
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      dbms_output.put_line(' v_Bt_c ' || v_bt_c);
    
      v_s_c := v_s_p + v_gf_c * (1 - v_f - v_ax1n_c) / v_nex_c;
      v_s_c := ROUND(v_s_c, gc_precision);
    
      dbms_output.put_line('v_S_c  ' || v_s_c);
    
      result.tariff := ROUND(v_gf_c / (v_s_c), gc_precision);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии допсоглашения изменение страховой премии
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_fee_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT calc_param;
  
    v_s_p NUMBER;
    v_s_c NUMBER;
  
  BEGIN
    dbms_output.put_line('PEPR_ADD_FEE_GET_NETTO  Зафиксировано изменение страховой премии');
    RESULT := pepr_add_fee_get_brutto(calc_param_prev
                                     ,calc_param_curr
                                     ,cover_add_info
                                     ,p_premia_base_type);
  
    v_s_c := result.ins_amount;
    dbms_output.put_line('PEPR_ADD_FEE_GET_NETTO v_S_c ' || v_s_c);
  
    result.tariff_netto := calc_param_prev.tariff_netto * calc_param_prev.ins_amount +
                           (result.tariff * v_s_c -
                           calc_param_prev.tariff * calc_param_prev.ins_amount) *
                           (1 - calc_param_curr.f);
    IF v_s_c = 0
    THEN
      result.tariff_netto := 0;
    ELSE
      result.tariff_netto := result.tariff_netto / v_s_c;
    END IF;
    dbms_output.put_line('PEPR_ADD_FEE_GET_NETTO tariff_netto ' || result.tariff_netto);
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии допсоглашения "Замена застрахованного"
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_assured_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT    calc_param;
    v_axn_c   NUMBER;
    v_a_xn_c  NUMBER;
    v_axn_p   NUMBER;
    v_a_xn_p  NUMBER;
    v_iax1n_c NUMBER; -- Значение актуарной функции для нового застрахованного
    v_iax1n_p NUMBER; -- Значение актуарной функции для предыдущего застрахованного
    v_ax1n_c  NUMBER;
    v_ax1n_p  NUMBER;
    v_p_p     NUMBER;
    v_p_c     NUMBER;
    v_s_p     NUMBER;
    v_s_c     NUMBER;
    v_nex_c   NUMBER; -- Значение актуарной функции для нового застрахованного
    v_nex_p   NUMBER; -- Значение актуарной функции для предыдущего застрахованного
    v_bt_c    NUMBER;
    v_bt_p    NUMBER;
    v_f       NUMBER;
    v_i       NUMBER;
    v_t       NUMBER;
    v_x_c     NUMBER;
    v_x_p     NUMBER;
    v_n       NUMBER;
    v_k_coef  NUMBER;
    v_s_coef  NUMBER;
    v_g_c     VARCHAR2(1);
    v_g_p     VARCHAR2(1);
    v_gd      NUMBER;
    v_gf_c    NUMBER;
    v_gf_p    NUMBER;
  BEGIN
    v_i      := calc_param_curr.normrate;
    v_t      := calc_param_curr.t;
    v_f      := calc_param_curr.f;
    v_x_c    := calc_param_curr.age;
    v_x_p    := calc_param_prev.age;
    v_n      := calc_param_curr.period_year;
    v_g_c    := calc_param_curr.gender_type;
    v_g_p    := calc_param_prev.gender_type;
    v_k_coef := calc_param_curr.k_coef;
    v_s_coef := calc_param_curr.s_coef;
    v_s_p    := calc_param_prev.ins_amount;
    v_s_c    := calc_param_curr.ins_amount;
  
    --
    dbms_output.put_line(' Зафиксировано изменение "Застрахованного"');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой суммы (Периодичная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p        := calc_param_prev.tariff * v_s_p;
      v_gf_c        := v_s_p * (v_nex_p - v_nex_c) / v_bt_c +
                       v_gf_p * (v_bt_p + v_t * (v_ax1n_p - v_ax1n_c)) / v_bt_c;
      result.tariff := ROUND(v_gf_c / v_s_c, gc_precision);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой суммы (Единовременная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p        := calc_param_prev.tariff * v_s_p;
      v_gd          := v_s_p * (v_nex_p - v_nex_c) / (1 - v_f - v_ax1n_c) +
                       v_gf_p * (v_ax1n_c - v_ax1n_p) / (1 - v_f - v_ax1n_c);
      v_gd          := ROUND(v_gd, gc_precision);
      result.tariff := ROUND(v_gd / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой премии (Периодичная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
      v_s_c  := v_s_p * (v_nex_p / v_nex_c) +
                v_gf_p * (v_bt_p - v_bt_c + v_t * (v_ax1n_p - v_ax1n_c)) / v_nex_c;
    
      result.tariff := ROUND(v_gf_p / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой премии (Единовременная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
      v_s_c  := v_s_p * (v_nex_p / v_nex_c) - v_gf_p * (v_ax1n_c - v_ax1n_p) / v_nex_c;
    
      result.tariff := ROUND(v_gf_p / v_s_c, gc_precision);
    ELSE
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --

  /*
   * Расчет нетто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии допсоглашения "Замена застрахованного"
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_assured_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT    calc_param;
    v_axn_c   NUMBER;
    v_a_xn_c  NUMBER;
    v_axn_p   NUMBER;
    v_a_xn_p  NUMBER;
    v_iax1n_c NUMBER; -- Значение актуарной функции для нового застрахованного
    v_iax1n_p NUMBER; -- Значение актуарной функции для предыдущего застрахованного
    v_ax1n_c  NUMBER;
    v_ax1n_p  NUMBER;
    v_p_p     NUMBER;
    v_p_c     NUMBER;
    v_s_p     NUMBER;
    v_s_c     NUMBER;
    v_nex_c   NUMBER; -- Значение актуарной функции для нового застрахованного
    v_nex_p   NUMBER; -- Значение актуарной функции для предыдущего застрахованного
    v_bt_c    NUMBER;
    v_bt_p    NUMBER;
    v_f       NUMBER;
    v_i       NUMBER;
    v_t       NUMBER;
    v_x_c     NUMBER;
    v_x_p     NUMBER;
    v_n       NUMBER;
    v_k_coef  NUMBER;
    v_s_coef  NUMBER;
    v_g_c     VARCHAR2(1);
    v_g_p     VARCHAR2(1);
    v_gd      NUMBER;
    v_gf_c    NUMBER;
    v_gf_p    NUMBER;
  BEGIN
    v_i      := calc_param_curr.normrate;
    v_t      := calc_param_curr.t;
    v_f      := calc_param_curr.f;
    v_x_c    := calc_param_curr.age;
    v_x_p    := calc_param_prev.age;
    v_n      := calc_param_curr.period_year;
    v_g_c    := calc_param_curr.gender_type;
    v_g_p    := calc_param_prev.gender_type;
    v_k_coef := calc_param_curr.k_coef;
    v_s_coef := calc_param_curr.s_coef;
    v_s_p    := calc_param_prev.ins_amount;
    v_s_c    := calc_param_curr.ins_amount;
  
    --
    dbms_output.put_line(' Зафиксировано изменение "Застрахованного"');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой суммы (Периодичная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p              := calc_param_prev.tariff * v_s_p;
      v_gf_c              := v_s_p * (v_nex_p - v_nex_c) / v_bt_c +
                             v_gf_p * (v_bt_p + v_t * (v_ax1n_p - v_ax1n_c)) / v_bt_c;
      result.tariff_netto := ROUND(v_gf_c * (1 - v_f) / v_s_c, gc_precision);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой суммы (Единовременная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p              := calc_param_prev.tariff * v_s_p;
      v_gd                := v_s_p * (v_nex_p - v_nex_c) / (1 - v_f - v_ax1n_c) +
                             v_gf_p * (v_ax1n_c - v_ax1n_p) / (1 - v_f - v_ax1n_c);
      v_gd                := ROUND(v_gd, gc_precision);
      result.tariff_netto := ROUND(v_gd * (1 - v_f) / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой премии (Периодичная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
      v_s_c  := v_s_p * (v_nex_p / v_nex_c) +
                v_gf_p * (v_bt_p - v_bt_c + v_t * (v_ax1n_p - v_ax1n_c)) / v_nex_c;
    
      result.tariff_netto := ROUND(v_gf_p * (1 - v_f) / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Ищзменение застрахованного при сохранении страховой премии (Единовременная оплата)');
      --    Расчет значений для нового застрахованного
      v_nex_c   := ROUND(pkg_amath.nex(v_x_c + v_t
                                      ,v_n
                                      ,v_g_c
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x_c + v_t
                                        ,v_n
                                        ,v_g_c
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x_c + v_t
                                       ,v_n - v_t
                                       ,v_g_c
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x_c + v_t
                                 ,v_n - v_t
                                 ,v_g_c
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
    
      --    Расчет значений для предшествующего застрахованного
      v_nex_p   := ROUND(pkg_amath.nex(v_x_p + v_t
                                      ,v_n
                                      ,v_g_p
                                      ,v_k_coef
                                      ,v_s_coef
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x_p + v_t
                                        ,v_n
                                        ,v_g_p
                                        ,v_k_coef
                                        ,v_s_coef
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x_p + v_t
                                       ,v_n - v_t
                                       ,v_g_p
                                       ,v_k_coef
                                       ,v_s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x_p + v_t
                                 ,v_n - v_t
                                 ,v_g_p
                                 ,v_k_coef
                                 ,v_s_coef
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      --
      RESULT := calc_param_curr;
      v_bt_p := ROUND(v_iax1n_p - (1 - v_f) * v_a_xn_p, gc_precision);
      v_bt_c := ROUND(v_iax1n_c - (1 - v_f) * v_a_xn_c, gc_precision);
    
      v_gf_p := calc_param_prev.tariff * v_s_p;
      v_s_c  := v_s_p * (v_nex_p / v_nex_c) - v_gf_p * (v_ax1n_c - v_ax1n_p) / v_nex_c;
    
      result.tariff_netto := ROUND(v_gf_p * (1 - v_f) / v_s_c, gc_precision);
    ELSE
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии допсоглашения "Изменение срока"
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_period_get_brutto
  (
    calc_param_prev calc_param
   ,calc_param_curr calc_param
   ,cover_add_info  add_info
  ) RETURN calc_param IS
    RESULT calc_param;
    --
    v_ax1n_p NUMBER;
    v_ax1n_c NUMBER;
    --
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    --
    v_iax1n_c NUMBER;
    v_iax1n_p NUMBER;
    --
    v_p_p NUMBER;
    v_p_c NUMBER;
    --
    v_s_p NUMBER;
    v_s_c NUMBER;
    --
    v_nex_c NUMBER;
    v_nex_p NUMBER;
    --
    v_bt_c NUMBER;
    v_bt_p NUMBER;
    --
    v_ft_c NUMBER;
    v_ft_p NUMBER;
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
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_g_c      NUMBER;
    v_g_p      NUMBER;
  BEGIN
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_f_c := calc_param_curr.f;
    v_f_p := calc_param_prev.f;
    v_x   := calc_param_curr.age;
    -- Секция инициализации локальных переменных значениями срока действия покрытия ( в полных годах)
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    v_g   := calc_param_curr.gender_type;
    -- Секция инициализации локальных переменных значениями нагружающих коэффициентов для текущего и предыдущего покрытия
    v_k_coef_c := calc_param_curr.k_coef;
    v_s_coef_c := calc_param_curr.s_coef;
    v_k_coef_p := calc_param_prev.k_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    -- Секция инициализации локальных переменных значениями страховой суммы
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
  
    --
    dbms_output.put_line(' Зафиксировано изменение срока страхования');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой суммы. (Периодичная оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_c - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_p - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_c - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_curr.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_bt_c    := ROUND(v_iax1n_c - (1 - v_f_c) * v_a_xn_c, gc_precision);
      --
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_p - v_t
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_prev.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_c - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_p - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_bt_p    := ROUND(v_iax1n_c - (1 - v_f_p) * v_a_xn_p, gc_precision);
      --
      RESULT        := calc_param_curr;
      v_g_p         := calc_param_prev.tariff * v_s_p;
      v_g_c         := v_g_p * (v_bt_p + v_t * (v_ax1n_p - v_ax1n_c)) * (1 / v_bt_p) +
                       v_s_p * (v_nex_p - v_nex_c) / v_bt_c;
      v_g_c         := ROUND(v_g_c, gc_precision);
      result.tariff := ROUND(v_g_c / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой суммы. (Единовременная оплата)');
      v_nex_c       := ROUND(pkg_amath.nex(v_x + v_t
                                          ,v_n_c - v_t
                                          ,v_g
                                          ,v_k_coef_c
                                          ,v_s_coef_c
                                          ,calc_param_curr.deathrate_id
                                          ,v_i)
                            ,gc_precision);
      v_iax1n_c     := ROUND(pkg_amath.iax1n(v_x + v_t
                                            ,v_n_c - v_t
                                            ,v_g
                                            ,v_k_coef_c
                                            ,v_s_coef_p
                                            ,calc_param_curr.deathrate_id
                                            ,v_i)
                            ,gc_precision);
      v_a_xn_c      := ROUND(pkg_amath.a_xn(v_x + v_t
                                           ,v_n_c - v_t
                                           ,v_g
                                           ,v_k_coef_c
                                           ,v_s_coef_p
                                           ,1
                                           ,calc_param_prev.deathrate_id
                                           ,v_i)
                            ,gc_precision);
      v_ax1n_c      := pkg_amath.ax1n(v_x + v_t
                                     ,v_n_c - v_t
                                     ,v_g
                                     ,v_k_coef_c
                                     ,v_s_coef_c
                                     ,calc_param_curr.deathrate_id
                                     ,v_i);
      RESULT        := calc_param_curr;
      v_g_p         := calc_param_prev.tariff * v_s_p;
      v_g_c         := v_g_p + (v_s_c - v_s_p) * v_nex_c / (1 - v_f_c - v_ax1n_c);
      v_g_c         := ROUND(v_g_c, gc_precision);
      result.tariff := ROUND(v_g_c / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой премии. (Периодичная оплата)');
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_p - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_p - v_t
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_p - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      --
      v_ft_p := ROUND(v_t * v_ax1n_c + v_iax1n_c - (1 - v_f_p) * v_a_xn_c, gc_precision);
      --
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_c - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_c - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_c - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      --
      v_ft_c := ROUND(v_t * v_ax1n_c + v_iax1n_c - (1 - v_f_c) * v_a_xn_c, gc_precision);
      --
      v_nex_c := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_c
                                    ,v_g
                                    ,v_k_coef_c
                                    ,v_s_coef_c
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      v_nex_p := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_p
                                    ,v_g
                                    ,v_k_coef_p
                                    ,v_s_coef_p
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      --
      v_s_c := ROUND(v_s_p * (v_nex_p / v_nex_c) * v_s_p * calc_param_prev.tariff * (v_ft_c - v_ft_p) /
                     v_nex_c
                    ,gc_precision);
    
      RESULT        := calc_param_curr;
      result.tariff := ROUND(calc_param_prev.tariff * v_s_p / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой премии. (Периодичная оплата)');
      v_ax1n_p := pkg_amath.ax1n(v_x + v_t
                                ,v_n_p - v_t
                                ,v_g
                                ,v_k_coef_p
                                ,v_s_coef_p
                                ,calc_param_curr.deathrate_id
                                ,v_i);
      v_ax1n_c := pkg_amath.ax1n(v_x + v_t
                                ,v_n_c - v_t
                                ,v_g
                                ,v_k_coef_c
                                ,v_s_coef_c
                                ,calc_param_curr.deathrate_id
                                ,v_i);
      --
      v_nex_c := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_c
                                    ,v_g
                                    ,v_k_coef_c
                                    ,v_s_coef_c
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      v_nex_p := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_p
                                    ,v_g
                                    ,v_k_coef_p
                                    ,v_s_coef_p
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      --
      v_s_c := ROUND(v_s_p * (v_nex_p / v_nex_c) +
                     v_s_p * calc_param_prev.tariff * (v_ax1n_p - v_ax1n_c) / v_nex_c
                    ,gc_precision);
    
      RESULT        := calc_param_curr;
      result.tariff := ROUND(calc_param_prev.tariff * v_s_p / v_s_c);
    ELSE
      dbms_output.put_line('Алгоритм расчета не описан для текущих условий');
      RESULT        := calc_param_curr;
      result.tariff := NULL;
    END IF;
    --
    RETURN RESULT;
  END;
  --
  /*
   * Расчет нетто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии допсоглашения "Изменение срока"
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_period_get_netto
  (
    calc_param_prev calc_param
   ,calc_param_curr calc_param
   ,cover_add_info  add_info
  ) RETURN calc_param IS
    RESULT calc_param;
    --
    v_ax1n_p NUMBER;
    v_ax1n_c NUMBER;
    --
    v_a_xn_c NUMBER;
    v_a_xn_p NUMBER;
    --
    v_iax1n_c NUMBER;
    v_iax1n_p NUMBER;
    --
    v_p_p NUMBER;
    v_p_c NUMBER;
    --
    v_s_p NUMBER;
    v_s_c NUMBER;
    --
    v_nex_c NUMBER;
    v_nex_p NUMBER;
    --
    v_bt_c NUMBER;
    v_bt_p NUMBER;
    --
    v_ft_c NUMBER;
    v_ft_p NUMBER;
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
    v_k_coef_c NUMBER;
    v_s_coef_c NUMBER;
    v_k_coef_p NUMBER;
    v_s_coef_p NUMBER;
    v_g        VARCHAR2(1);
    v_g_c      NUMBER;
    v_g_p      NUMBER;
  BEGIN
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_f_c := calc_param_curr.f;
    v_f_p := calc_param_prev.f;
    v_x   := calc_param_curr.age;
    -- Секция инициализации локальных переменных значениями срока действия покрытия ( в полных годах)
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    v_g   := calc_param_curr.gender_type;
    -- Секция инициализации локальных переменных значениями нагружающих коэффициентов для текущего и предыдущего покрытия
    v_k_coef_c := calc_param_curr.k_coef;
    v_s_coef_c := calc_param_curr.s_coef;
    v_k_coef_p := calc_param_prev.k_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    -- Секция инициализации локальных переменных значениями страховой суммы
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
  
    --
    dbms_output.put_line(' Зафиксировано изменение срока страхования');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой суммы. (Периодичная оплата)');
      v_nex_c   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_c - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_p - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_c - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_curr.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_bt_c    := ROUND(v_iax1n_c - (1 - v_f_c) * v_a_xn_c, gc_precision);
      --
      v_nex_p   := ROUND(pkg_amath.nex(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                        ,gc_precision);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_p - v_t
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_prev.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_c - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_p - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_bt_p    := ROUND(v_iax1n_c - (1 - v_f_p) * v_a_xn_p, gc_precision);
      --
      RESULT              := calc_param_curr;
      v_g_p               := calc_param_prev.tariff * v_s_p;
      v_g_c               := v_g_p * (v_bt_p + v_t * (v_ax1n_p - v_ax1n_c)) * (1 / v_bt_p) +
                             v_s_p * (v_nex_p - v_nex_c) / v_bt_c;
      v_g_c               := ROUND(v_g_c, gc_precision);
      result.tariff_netto := ROUND(v_g_c * (1 - v_f_c) / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND v_s_p = v_s_c
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой суммы. (Единовременная оплата)');
      v_nex_c             := ROUND(pkg_amath.nex(v_x + v_t
                                                ,v_n_c - v_t
                                                ,v_g
                                                ,v_k_coef_c
                                                ,v_s_coef_c
                                                ,calc_param_curr.deathrate_id
                                                ,v_i)
                                  ,gc_precision);
      v_iax1n_c           := ROUND(pkg_amath.iax1n(v_x + v_t
                                                  ,v_n_c - v_t
                                                  ,v_g
                                                  ,v_k_coef_c
                                                  ,v_s_coef_p
                                                  ,calc_param_curr.deathrate_id
                                                  ,v_i)
                                  ,gc_precision);
      v_a_xn_c            := ROUND(pkg_amath.a_xn(v_x + v_t
                                                 ,v_n_c - v_t
                                                 ,v_g
                                                 ,v_k_coef_c
                                                 ,v_s_coef_p
                                                 ,1
                                                 ,calc_param_prev.deathrate_id
                                                 ,v_i)
                                  ,gc_precision);
      v_ax1n_c            := pkg_amath.ax1n(v_x + v_t
                                           ,v_n_c - v_t
                                           ,v_g
                                           ,v_k_coef_c
                                           ,v_s_coef_c
                                           ,calc_param_curr.deathrate_id
                                           ,v_i);
      RESULT              := calc_param_curr;
      v_g_p               := calc_param_prev.tariff * v_s_p;
      v_g_c               := v_g_p + (v_s_c - v_s_p) * v_nex_c / (1 - v_f_c - v_ax1n_c);
      v_g_c               := ROUND(v_g_c, gc_precision);
      result.tariff_netto := ROUND(v_g_c * (1 - v_f_c) / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой премии. (Периодичная оплата)');
      v_ax1n_p  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_p - v_t
                                 ,v_g
                                 ,v_k_coef_p
                                 ,v_s_coef_p
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_iax1n_p := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_p - v_t
                                        ,v_g
                                        ,v_k_coef_p
                                        ,v_s_coef_p
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_p  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_p - v_t
                                       ,v_g
                                       ,v_k_coef_p
                                       ,v_s_coef_p
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      --
      v_ft_p := ROUND(v_t * v_ax1n_c + v_iax1n_c - (1 - v_f_p) * v_a_xn_c, gc_precision);
      --
      v_ax1n_c  := pkg_amath.ax1n(v_x + v_t
                                 ,v_n_c - v_t
                                 ,v_g
                                 ,v_k_coef_c
                                 ,v_s_coef_c
                                 ,calc_param_curr.deathrate_id
                                 ,v_i);
      v_iax1n_c := ROUND(pkg_amath.iax1n(v_x + v_t
                                        ,v_n_c - v_t
                                        ,v_g
                                        ,v_k_coef_c
                                        ,v_s_coef_c
                                        ,calc_param_curr.deathrate_id
                                        ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n_c - v_t
                                       ,v_g
                                       ,v_k_coef_c
                                       ,v_s_coef_c
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      --
      v_ft_c := ROUND(v_t * v_ax1n_c + v_iax1n_c - (1 - v_f_c) * v_a_xn_c, gc_precision);
      --
      v_nex_c := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_c
                                    ,v_g
                                    ,v_k_coef_c
                                    ,v_s_coef_c
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      v_nex_p := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_p
                                    ,v_g
                                    ,v_k_coef_p
                                    ,v_s_coef_p
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      --
      v_s_c := ROUND(v_s_p * (v_nex_p / v_nex_c) * v_s_p * calc_param_prev.tariff * (v_ft_c - v_ft_p) /
                     v_nex_c
                    ,gc_precision);
    
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(calc_param_prev.tariff_netto * v_s_p / v_s_c, gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      dbms_output.put_line('Доп. соглашение по изменению срока при сохранении страховой премии. (Периодичная оплата)');
      v_ax1n_p := pkg_amath.ax1n(v_x + v_t
                                ,v_n_p - v_t
                                ,v_g
                                ,v_k_coef_p
                                ,v_s_coef_p
                                ,calc_param_curr.deathrate_id
                                ,v_i);
      v_ax1n_c := pkg_amath.ax1n(v_x + v_t
                                ,v_n_c - v_t
                                ,v_g
                                ,v_k_coef_c
                                ,v_s_coef_c
                                ,calc_param_curr.deathrate_id
                                ,v_i);
      --
      v_nex_c := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_c
                                    ,v_g
                                    ,v_k_coef_c
                                    ,v_s_coef_c
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      v_nex_p := ROUND(pkg_amath.nex(v_x + v_t
                                    ,v_n_p
                                    ,v_g
                                    ,v_k_coef_p
                                    ,v_s_coef_p
                                    ,calc_param_curr.deathrate_id
                                    ,v_i)
                      ,gc_precision);
      --
      v_s_c := ROUND(v_s_p * (v_nex_p / v_nex_c) +
                     v_s_p * calc_param_prev.tariff * (v_ax1n_p - v_ax1n_c) / v_nex_c
                    ,gc_precision);
    
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(calc_param_prev.tariff_netto * v_s_p / v_s_c, gc_precision);
    ELSE
      dbms_output.put_line('Алгоритм расчета не описан для текущих условий');
      RESULT              := calc_param_curr;
      result.tariff_netto := NULL;
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни "Дожитие до возраста вс возвратом взносов" при наличии доп соглашения Изменение валюты
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_fund_get_brutto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT       calc_param;
    v_axn_c      NUMBER;
    v_a_xn_c     NUMBER;
    v_axn_p      NUMBER;
    v_a_xn_p     NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_s_p        NUMBER;
    v_s_c        NUMBER;
    v_f          NUMBER;
    v_i          NUMBER;
    v_t          NUMBER;
    v_x          NUMBER;
    v_n          NUMBER;
    v_fund_rate  NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни "Дожитие до возраста вс возвратом взносов" при наличии доп соглашения Изменение валюты
   * @author Marchuk A.
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */

  FUNCTION pepr_add_fund_get_netto
  (
    calc_param_prev    calc_param
   ,calc_param_curr    calc_param
   ,cover_add_info     add_info
   ,p_premia_base_type IN NUMBER
  ) RETURN calc_param IS
    RESULT       calc_param;
    v_axn_c      NUMBER;
    v_a_xn_c     NUMBER;
    v_axn_p      NUMBER;
    v_a_xn_p     NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_s_p        NUMBER;
    v_s_c        NUMBER;
    v_f          NUMBER;
    v_i          NUMBER;
    v_t          NUMBER;
    v_x          NUMBER;
    v_n          NUMBER;
    v_fund_rate  NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии доп соглашения
   * @author Marchuk A.
   * @param p_cover_id     ИД покрытия
  */

  FUNCTION pepr_add_get_brutto
  (
    p_cover_id  IN NUMBER
   ,p_re_sign   IN NUMBER DEFAULT NULL
   ,p_no_change NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn_p NUMBER;
    v_axn_p  NUMBER;
    --
    v_a_xn_c NUMBER;
    v_axn_c  NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_add_info add_info;
    --
    calc_result calc_param;
    --
    d_result NUMBER;
    result_1 NUMBER DEFAULT 0;
    result_2 NUMBER DEFAULT 0;
    RESULT   NUMBER;
  
    v_ins_amount NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_pc         NUMBER; --Произведение коэффициентов покрытия
    v_s1         NUMBER;
    v_s_c        NUMBER;
    v_s_p        NUMBER;
    v_fund_rate  NUMBER;
  BEGIN
    dbms_output.put_line('PEPR_add_get_brutto');
    r_add_info        := get_add_info(p_cover_id);
    r_calc_param_prev := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
    r_calc_param_curr := get_calc_param(p_cover_id, p_re_sign);
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
         AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := pepr_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_period_change = 1
            AND r_add_info.is_ins_amount_change = 0
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := pepr_add_period_get_brutto(r_calc_param_prev, r_calc_param_curr, r_add_info);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение страховой суммы');
        calc_result := pepr_add_ins_amount_get_brutto(r_calc_param_prev
                                                     ,r_calc_param_curr
                                                     ,r_add_info
                                                     ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSIF r_add_info.is_ins_amount_change = 0
            AND p_no_change = 0
            AND (r_add_info.is_assured_change = 0 AND r_add_info.is_payment_terms_id_change = 0 AND
            r_add_info.is_periodical_change = 0)
      THEN
        --
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
      ELSIF r_add_info.is_fund_id_change = 1
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение валюты договора ');
        --
        v_axn_p := pkg_amath.axn(r_calc_param_prev.age + r_calc_param_curr.t
                                ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                ,r_calc_param_curr.gender_type
                                ,r_calc_param_curr.k_coef
                                ,r_calc_param_curr.s_coef
                                ,r_calc_param_prev.deathrate_id
                                ,r_calc_param_prev.normrate);
        dbms_output.put_line(' v_axn_p ' || v_axn_p);
        v_a_xn_p := pkg_amath.a_xn(r_calc_param_prev.age + r_calc_param_curr.t
                                  ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                  ,r_calc_param_curr.gender_type
                                  ,r_calc_param_curr.k_coef
                                  ,r_calc_param_curr.s_coef
                                  ,1
                                  ,r_calc_param_prev.deathrate_id
                                  ,r_calc_param_prev.normrate);
        --
        v_axn_c  := pkg_amath.axn(r_calc_param_prev.age + r_calc_param_curr.t
                                 ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                 ,r_calc_param_curr.gender_type
                                 ,r_calc_param_curr.k_coef
                                 ,r_calc_param_curr.s_coef
                                 ,r_calc_param_curr.deathrate_id
                                 ,r_calc_param_curr.normrate);
        v_a_xn_c := pkg_amath.a_xn(r_calc_param_prev.age + r_calc_param_curr.t
                                  ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                  ,r_calc_param_curr.gender_type
                                  ,r_calc_param_curr.k_coef
                                  ,r_calc_param_curr.s_coef
                                  ,1
                                  ,r_calc_param_prev.deathrate_id
                                  ,r_calc_param_curr.normrate);
      
        v_ins_amount := (r_calc_param_prev.ins_amount / v_fund_rate) * v_axn_p / v_axn_c +
                        r_calc_param_curr.tariff * (1 - r_calc_param_prev.f) *
                        r_calc_param_prev.ins_amount / v_fund_rate * (v_a_xn_c - v_a_xn_p) / v_axn_c;
        --
        v_p_c := r_calc_param_prev.tariff * (1 - r_calc_param_prev.f) * r_calc_param_prev.ins_amount /
                 v_fund_rate;
        dbms_output.put_line(' v_P_c ' || v_p_c);
        --
        v_axn_c  := pkg_amath.axn(r_calc_param_curr.age + r_calc_param_curr.t
                                 ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                 ,r_calc_param_curr.gender_type
                                 ,r_calc_param_curr.k_coef
                                 ,r_calc_param_curr.s_coef
                                 ,r_calc_param_prev.deathrate_id
                                 ,r_calc_param_curr.normrate);
        v_a_xn_c := pkg_amath.a_xn(r_calc_param_curr.age + r_calc_param_curr.t
                                  ,r_calc_param_curr.period_year - r_calc_param_curr.t
                                  ,r_calc_param_curr.gender_type
                                  ,r_calc_param_curr.k_coef
                                  ,r_calc_param_curr.s_coef
                                  ,1
                                  ,r_calc_param_prev.deathrate_id
                                  ,r_calc_param_curr.normrate);
        --
        v_p_c  := v_p + (r_calc_param_prev.ins_amount - v_ins_amount) * v_axn_c / v_a_xn_c;
        RESULT := v_p_c / r_calc_param_curr.ins_amount * (1 - r_calc_param_curr.f);
      ELSE
        RESULT := r_calc_param_prev.tariff;
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      IF r_add_info.is_assured_change = 1
         AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := pepr_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_period_change = 1
            AND r_add_info.is_ins_amount_change = 0
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := pepr_add_period_get_brutto(r_calc_param_prev, r_calc_param_curr, r_add_info);
        RESULT      := calc_result.tariff;
        --
        /*      elsif r_add_info.is_ins_amount_change = 1 then
                dbms_output.put_line (' Зафиксировано изменение страховой суммы');
                calc_result := PEPR_add_ins_amount_get_brutto (r_calc_param_prev, r_calc_param_curr, r_add_info, r_calc_param_curr.premia_base_type);
                result := calc_result.tariff;
        */
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSIF r_add_info.is_fee_change = 1
            AND p_no_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := pepr_add_fee_get_brutto(r_calc_param_prev
                                              ,r_calc_param_curr
                                              ,r_add_info
                                              ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
        --
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни по "Дожиотие с возвратом взносов" при наличии доп соглашения
   * @author Marchuk A.
   * @param p_cover_id     ИД покрытия
  */

  FUNCTION pepr_add_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn_p NUMBER;
    v_axn_p  NUMBER;
    --
    v_a_xn_c NUMBER;
    v_axn_c  NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_add_info add_info;
    --
    calc_result calc_param;
    --
    d_result NUMBER;
    result_1 NUMBER DEFAULT 0;
    result_2 NUMBER DEFAULT 0;
    RESULT   NUMBER;
  
    v_ins_amount NUMBER;
    v_p_p        NUMBER;
    v_p_c        NUMBER;
    v_pc         NUMBER; --Произведение коэффициентов покрытия
    v_s1         NUMBER;
    v_s_c        NUMBER;
    v_s_p        NUMBER;
    v_fund_rate  NUMBER;
  BEGIN
    r_add_info        := get_add_info(p_cover_id);
    r_calc_param_prev := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
    r_calc_param_curr := get_calc_param(p_cover_id, p_re_sign);
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := pepr_add_assured_get_netto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_period_change = 1
            AND r_add_info.is_ins_amount_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := pepr_add_period_get_netto(r_calc_param_prev, r_calc_param_curr, r_add_info);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение страховой суммы');
        calc_result := pepr_add_ins_amount_get_netto(r_calc_param_prev
                                                    ,r_calc_param_curr
                                                    ,r_add_info
                                                    ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSIF r_add_info.is_ins_amount_change = 0
            AND (r_add_info.is_assured_change = 0 AND r_add_info.is_payment_terms_id_change = 0 AND
            r_add_info.is_periodical_change = 0)
      THEN
        --
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение валюты договора ');
        --
        calc_result := pepr_add_fund_get_netto(r_calc_param_prev
                                              ,r_calc_param_curr
                                              ,r_add_info
                                              ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := pepr_add_assured_get_netto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_period_change = 1
            AND r_add_info.is_ins_amount_change = 0
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := pepr_add_period_get_netto(r_calc_param_prev, r_calc_param_curr, r_add_info);
        RESULT      := calc_result.tariff_netto;
        --
      
        /*      elsif r_add_info.is_ins_amount_change = 1 then
                dbms_output.put_line (' Зафиксировано изменение страховой суммы');
                calc_result := PEPR_add_ins_amount_get_brutto (r_calc_param_prev, r_calc_param_curr, r_add_info, r_calc_param_curr.premia_base_type);
                result := calc_result.tariff_netto;
        */
      ELSIF r_add_info.is_fee_change = 1
      THEN
        calc_result := pepr_add_fee_get_netto(r_calc_param_prev
                                             ,r_calc_param_curr
                                             ,r_add_info
                                             ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
        --
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "Страхование жизни на срок" при наличии допсоглашения
   * @param calc_param_prev      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param calc_param_curr      Данные типа запись, содержащие сведения о параметрах предыдущего покрытия
   * @param cover_add_info       Данные типа запись, содержащие сведения о изменениях, которые произошли в покрытии
   * @param p_premia_base_type   Признак направления расчета изменения по доп соглашению
  */
  FUNCTION term_add_ins_amount_get_brutto
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
    v_p_p     NUMBER;
    v_p_c     NUMBER;
    v_s_p     NUMBER;
    v_s_c     NUMBER;
    v_delta_s NUMBER;
    v_f       NUMBER;
    v_i       NUMBER;
    v_t       NUMBER;
    v_x       NUMBER;
    v_n       NUMBER;
    v_g       VARCHAR2(1);
  BEGIN
    v_i := calc_param_curr.normrate;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --
    dbms_output.put_line('TERM_ADD_INS_AMOUNT_GET_BRUTTO Зафиксировано изменение только страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      v_ax1n_c  := ROUND(pkg_amath.ax1n(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,calc_param_curr.k_coef
                                       ,calc_param_curr.s_coef
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_a_xn_c  := ROUND(pkg_amath.a_xn(v_x + v_t
                                       ,v_n - v_t
                                       ,v_g
                                       ,calc_param_curr.k_coef
                                       ,calc_param_curr.s_coef
                                       ,1
                                       ,calc_param_prev.deathrate_id
                                       ,v_i)
                        ,gc_precision);
      v_s_p     := calc_param_prev.ins_amount;
      v_s_c     := calc_param_curr.ins_amount;
      v_delta_s := v_s_c - v_s_p;
      v_f       := calc_param_curr.f;
      v_p_p     := calc_param_prev.tariff_netto * v_s_p;
      dbms_output.put_line('v_ax1n_c ' || v_ax1n_c || ' v_a_xn_c ' || v_a_xn_c);
      v_p_c := v_p_p + v_delta_s * v_ax1n_c / v_a_xn_c;
    
      RESULT              := calc_param_curr;
      result.tariff       := v_p_c / (v_s_c * (1 - v_f));
      result.tariff_netto := v_p_c / v_s_c;
      dbms_output.put_line(' v_P_p ' || v_p_p || ' v_P_c ' || v_p_c || ' tariff ' || result.tariff);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_s_p    := calc_param_prev.ins_amount;
      v_s_c    := calc_param_curr.ins_amount;
      v_p_p    := calc_param_prev.tariff * (1 - v_f) * v_s_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := v_p_p + (v_s_c - v_s_p) * v_ax1n_c / v_a_xn_c;
      dbms_output.put_line(' v_P_c ' || v_p_c);
      RESULT              := calc_param_curr;
      result.tariff       := v_p_c / (v_s_c * (1 - v_f));
      result.tariff_netto := v_p_c / v_s_c;
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
  FUNCTION term_add_ins_amount_get_netto
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
    v_p_p    NUMBER;
    v_p_c    NUMBER;
    v_s_p    NUMBER;
    v_s_c    NUMBER;
    v_f      NUMBER;
    v_i      NUMBER;
    v_t      NUMBER;
    v_x      NUMBER;
    v_n      NUMBER;
    v_g      VARCHAR2(1);
  BEGIN
    v_i := calc_param_curr.normrate;
    v_t := calc_param_curr.t;
    v_x := calc_param_curr.age;
    v_n := calc_param_curr.period_year;
    v_g := calc_param_curr.gender_type;
    --
    dbms_output.put_line('TERM_ADD_INS_AMOUNT_GET_NETTO Зафиксировано изменение только страховой суммы');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
    THEN
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_s_p    := calc_param_prev.ins_amount;
      v_s_c    := calc_param_curr.ins_amount;
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := v_p_p + (v_s_c - v_s_p) * v_ax1n_c / v_a_xn_c;
      dbms_output.put_line(' v_P_c ' || v_p_c);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
    THEN
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_s_p    := calc_param_prev.ins_amount;
      v_s_c    := calc_param_curr.ins_amount;
      v_p_p    := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := v_p_p + (v_s_c - v_s_p) * v_ax1n_c / v_a_xn_c;
      dbms_output.put_line(' v_P_c ' || v_p_c);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
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

  FUNCTION term_add_fee_get_brutto
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
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
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
    v_gd       NUMBER;
    v_gf_p     NUMBER;
    v_gf_c     NUMBER;
    v_pc       NUMBER;
    v_pp       NUMBER;
  BEGIN
    v_i := calc_param_curr.normrate;
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
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    v_pc := pkg_tariff.calc_tarif_mul(calc_param_curr.p_cover_id);
    v_pp := pkg_tariff.calc_tarif_mul(calc_param_prev.p_cover_id);
    --
    IF v_pp != 0
    THEN
      v_gf_p := calc_param_prev.fee / nvl(v_pp, 1);
    ELSE
      v_gf_p := NULL;
    END IF;
    --
    IF v_pc != 0
    THEN
      v_gf_c := calc_param_curr.fee / nvl(v_pc, 1);
    ELSE
      v_gf_c := NULL;
    END IF;
  
    dbms_output.put_line(' Зафиксировано изменение страховой премии');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 1
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Периодическая оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_s_p, gc_precision);
      v_p_c    := v_gf_c / (1 - v_f);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      v_s_c         := v_s_p + (v_p_c - v_p_c) * v_a_xn_c / v_ax1n_c;
      v_s_c         := ROUND(v_s_c, gc_precision);
      RESULT        := calc_param_curr;
      result.tariff := ROUND(v_gf_c / v_s_c, gc_precision);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff * (1 - v_f) * v_s_p, gc_precision);
      v_p_c    := v_gf_c / (1 - v_f);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      v_s_c         := v_s_p + (v_p_c / v_ax1n_c);
      v_s_c         := ROUND(v_s_c, gc_precision);
      RESULT        := calc_param_curr;
      result.tariff := ROUND(v_gf_c / v_s_c, gc_precision);
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

  FUNCTION term_add_fee_get_netto
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
    v_p_p      NUMBER;
    v_p_c      NUMBER;
    v_s_p      NUMBER;
    v_s_c      NUMBER;
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
    v_gd       NUMBER;
    v_gf_p     NUMBER;
    v_gf_c     NUMBER;
    v_pc       NUMBER;
    v_pp       NUMBER;
  BEGIN
    v_i := calc_param_curr.normrate;
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
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    v_pc := pkg_tariff.calc_tarif_mul(calc_param_curr.p_cover_id);
    v_pp := pkg_tariff.calc_tarif_mul(calc_param_prev.p_cover_id);
    --
    IF v_pp != 0
    THEN
      v_gf_p := calc_param_prev.fee / nvl(v_pp, 1);
    ELSE
      v_gf_p := NULL;
    END IF;
    --
    IF v_pc != 0
    THEN
      v_gf_c := calc_param_curr.fee / nvl(v_pc, 1);
    ELSE
      v_gf_c := NULL;
    END IF;
  
    dbms_output.put_line(' Зафиксировано изменение страховой премии');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 1
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Периодическая оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_p_c    := v_gf_c / (1 - v_f);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      v_s_c               := v_s_p + (v_p_c - v_p_c) * v_a_xn_c / v_ax1n_c;
      v_s_c               := ROUND(v_s_c, gc_precision);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_gf_c * (1 - v_f) / v_s_c, gc_precision);
    
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
    THEN
      dbms_output.put_line(' Зафиксировано изменение страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      v_f      := calc_param_curr.f;
      v_p_p    := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_p_c    := v_gf_c / (1 - v_f);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      v_s_c               := v_s_p + (v_p_c / v_ax1n_c);
      v_s_c               := ROUND(v_s_c, gc_precision);
      RESULT              := calc_param_curr;
      result.tariff_netto := ROUND(v_gf_c * (1 - v_f) / v_s_c, gc_precision);
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

  FUNCTION term_add_assured_get_brutto
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
    v_p_p    NUMBER;
    v_p_c    NUMBER;
    v_s_p    NUMBER;
    v_s_c    NUMBER;
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
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_n   := calc_param_curr.period_year;
    v_g_c := calc_param_curr.gender_type;
    v_g_p := calc_param_prev.gender_type;
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    v_s_coef_c := calc_param_curr.s_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    v_k_coef_c := calc_param_curr.k_coef;
    v_k_coef_p := calc_param_prev.k_coef;
    --
    dbms_output.put_line(' Зафиксировано изменение застрахованного');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := ROUND(v_s_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_p_p * v_a_xn_p / v_a_xn_c
                    ,gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_p_p         := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c         := ROUND(v_s_c * (v_ax1n_c - v_ax1n_p), gc_precision);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_s_c := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c) + v_p_p * (v_a_xn_c - v_a_xn_c) / v_ax1n_c
                    ,gc_precision);
      dbms_output.put_line(' v_S_c ' || v_s_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_p_p         := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      v_p_c         := v_p_p;
      v_s_c         := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c), gc_precision);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff);
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

  FUNCTION term_add_assured_get_netto
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
    v_p_p    NUMBER;
    v_p_c    NUMBER;
    v_s_p    NUMBER;
    v_s_c    NUMBER;
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
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_n   := calc_param_curr.period_year;
    v_g_c := calc_param_curr.gender_type;
    v_g_p := calc_param_prev.gender_type;
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
    --
    v_s_coef_c := calc_param_curr.s_coef;
    v_s_coef_p := calc_param_prev.s_coef;
    v_k_coef_c := calc_param_curr.k_coef;
    v_k_coef_p := calc_param_prev.k_coef;
    --
    dbms_output.put_line(' Зафиксировано изменение застрахованного');
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * v_s_p, gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_p_c := ROUND(v_s_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_p_p * v_a_xn_p / v_a_xn_c
                    ,gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff_netto := ROUND(v_p_c / v_s_c, gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_c = v_s_p
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой сумме (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_curr.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_p_p               := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_p_c               := ROUND(v_s_c * (v_ax1n_c - v_ax1n_p), gc_precision);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      v_s_c := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c) + v_p_p * (v_a_xn_c - v_a_xn_c) / v_ax1n_c
                    ,gc_precision);
      dbms_output.put_line(' v_S_c ' || v_s_c);
      result.tariff := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_prev.fee = calc_param_curr.fee
    THEN
      dbms_output.put_line(' Зафиксировано изменение застрахованного при постоянной страховой премии (Единовременная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(calc_param_curr.age + v_t
                                      ,v_n - v_t
                                      ,v_g_c
                                      ,v_k_coef_c
                                      ,v_s_coef_c
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_curr.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_ax1n_p := ROUND(pkg_amath.ax1n(calc_param_prev.age + v_t
                                      ,v_n - v_t
                                      ,v_g_p
                                      ,v_k_coef_p
                                      ,v_s_coef_p
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_p_p         := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_p_c         := v_p_p;
      v_s_c         := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c), gc_precision);
      result.tariff := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result.tariff ' || result.tariff_netto);
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
  FUNCTION term_add_period_get_brutto
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
    v_p_p NUMBER;
    v_p_c NUMBER;
    v_s_p NUMBER;
    v_s_c NUMBER;
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
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_g   := calc_param_curr.gender_type;
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    --
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
  
    v_f_p := calc_param_prev.f;
    v_f_c := calc_param_curr.f;
    --
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)');
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_c - v_t ' || (v_n_c - v_t));
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_p - v_t ' || (v_n_p - v_t));
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - v_f_p) * v_s_p, gc_precision);
    
      v_p_c := ROUND(v_s_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_p_p * (v_a_xn_p / v_a_xn_c)
                    ,gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - v_f_c)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата) ');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := calc_param_prev.ins_amount;
      v_p_c := ROUND(v_p_p + v_s_c * (v_ax1n_c - v_ax1n_p), gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c) + v_p_p * (v_a_xn_c - v_a_xn_p) / v_ax1n_c
                    ,gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff * (1 - calc_param_prev.f) * calc_param_prev.ins_amount
                    ,gc_precision);
      v_s_p := calc_param_prev.ins_amount;
      v_s_c := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c), gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      result.tariff := ROUND(v_p_c / (v_s_c * (1 - calc_param_curr.f)), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSE
      dbms_output.put_line('Условия расчета не описаны по алгоритму');
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
  FUNCTION term_add_period_get_netto
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
    v_p_p NUMBER;
    v_p_c NUMBER;
    v_s_p NUMBER;
    v_s_c NUMBER;
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
    v_i   := calc_param_curr.normrate;
    v_t   := calc_param_curr.t;
    v_x   := calc_param_curr.age;
    v_g   := calc_param_curr.gender_type;
    v_n_c := calc_param_curr.period_year;
    v_n_p := calc_param_prev.period_year;
    --
    v_s_p := calc_param_prev.ins_amount;
    v_s_c := calc_param_curr.ins_amount;
  
    v_f_p := calc_param_prev.f;
    v_f_c := calc_param_curr.f;
    --
    IF calc_param_curr.is_one_payment = 0
       AND calc_param_prev.is_one_payment = 0
       AND p_premia_base_type = 0
       AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (периодичная оплата)');
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_c - v_t ' || (v_n_c - v_t));
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_c - v_t
                                      ,v_g
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      dbms_output.put_line('v_x + v_t ' || (v_x + v_t) || 'v_n_p - v_t ' || (v_n_p - v_t));
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,v_n_p - v_t
                                      ,v_g
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
    
      v_p_c := ROUND(v_s_p * (v_ax1n_c - v_ax1n_p) / v_a_xn_c + v_p_p * (v_a_xn_p / v_a_xn_c)
                    ,gc_precision);
      dbms_output.put_line(' v_P_p ' || v_p_p);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 0
          AND v_s_p = v_s_c
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой сумме  (единовременная оплата) ');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * calc_param_prev.ins_amount, gc_precision);
      v_p_c := ROUND(v_p_p + v_s_c * (v_ax1n_c - v_ax1n_p), gc_precision);
      dbms_output.put_line(' v_P_c ' || v_p_c);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 0
          AND calc_param_prev.is_one_payment = 0
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      v_a_xn_c := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_c ' || v_a_xn_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      v_a_xn_p := ROUND(pkg_amath.a_xn(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,1
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_a_xn_p ' || v_a_xn_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * v_s_p, gc_precision);
      v_s_c := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c) + v_p_p * (v_a_xn_c - v_a_xn_p) / v_ax1n_c
                    ,gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff_netto);
    ELSIF calc_param_curr.is_one_payment = 1
          AND calc_param_prev.is_one_payment = 1
          AND p_premia_base_type = 1
          AND calc_param_curr.fee = calc_param_prev.fee
    THEN
      -- Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (единовременная оплата)
      dbms_output.put_line('Доп. соглашение - изменение срока страхования при сохранении условий по страховой премии  (периодичная оплата)');
      v_ax1n_c := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_curr.period_year - v_t
                                      ,calc_param_curr.gender_type
                                      ,calc_param_curr.k_coef
                                      ,calc_param_curr.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,v_i)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_c ' || v_ax1n_c);
      --
      v_ax1n_p := ROUND(pkg_amath.ax1n(v_x + v_t
                                      ,calc_param_prev.period_year - v_t
                                      ,calc_param_prev.gender_type
                                      ,calc_param_prev.k_coef
                                      ,calc_param_prev.s_coef
                                      ,calc_param_prev.deathrate_id
                                      ,calc_param_prev.normrate)
                       ,gc_precision);
      dbms_output.put_line(' v_ax1n_p ' || v_ax1n_p);
      --
      v_p_p := ROUND(calc_param_prev.tariff_netto * calc_param_prev.ins_amount, gc_precision);
      v_s_c := ROUND(v_s_p * (v_ax1n_p / v_ax1n_c), gc_precision);
      v_p_c := v_p_p;
      dbms_output.put_line(' v_P_p ' || v_p_p);
      result.tariff_netto := ROUND(v_p_c / (v_s_c), gc_precision);
      dbms_output.put_line(' result ' || result.tariff);
    ELSE
      dbms_output.put_line('Условия расчета не описаны по алгоритму');
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

  FUNCTION term_add_get_brutto
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
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := term_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := term_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        --
        calc_result := term_add_ins_amount_get_brutto(r_calc_param_prev
                                                     ,r_calc_param_curr
                                                     ,r_add_info
                                                     ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        RESULT := NULL;
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
      
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      dbms_output.put_line(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := term_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
      
        calc_result := term_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := term_add_fee_get_brutto(r_calc_param_prev
                                              ,r_calc_param_curr
                                              ,r_add_info
                                              ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /**
   * Расчет нетто тарифа по покрытию при наличии дополнительного соглашения по "Первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION term_add_get_netto
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
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := term_add_assured_get_netto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := term_add_period_get_netto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        --
        calc_result := term_add_ins_amount_get_netto(r_calc_param_prev
                                                    ,r_calc_param_curr
                                                    ,r_add_info
                                                    ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        RESULT := NULL;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      dbms_output.put_line(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := term_add_assured_get_netto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
      
        calc_result := term_add_period_get_netto(r_calc_param_prev
                                                ,r_calc_param_curr
                                                ,r_add_info
                                                ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := term_add_fee_get_netto(r_calc_param_prev
                                             ,r_calc_param_curr
                                             ,r_add_info
                                             ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /**
   * Расчет брутто тарифа по покрытию при наличии дополнительного соглашения по "Первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION dd_add_get_brutto
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
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := term_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := term_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        --
        calc_result := term_add_ins_amount_get_brutto(r_calc_param_prev
                                                     ,r_calc_param_curr
                                                     ,r_add_info
                                                     ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        RESULT := NULL;
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
      
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      dbms_output.put_line(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := term_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
      
        calc_result := term_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := term_add_fee_get_brutto(r_calc_param_prev
                                              ,r_calc_param_curr
                                              ,r_add_info
                                              ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /**
   * Расчет нетто тарифа по покрытию при наличии дополнительного соглашения по "Первичное диагностирование смертельно опасного заболевания"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION dd_add_get_netto
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
    dbms_output.put_line(' Зафиксировано изменение по доп соглашению....Основание для расчета ' ||
                         r_calc_param_curr.premia_base_type);
    dbms_output.put_line(' p_cover_id_prev ' || r_add_info.p_cover_id_prev || ' p_cover_id_curr ' ||
                         p_cover_id);
    dbms_output.put_line('Страховая сумма до ' || r_calc_param_prev.ins_amount ||
                         ' Страховая сумма теперь ' || r_calc_param_curr.ins_amount);
    IF r_calc_param_curr.premia_base_type = 0
    THEN
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застрахованного ');
        --
        calc_result := term_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
        --
        calc_result := term_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_ins_amount_change = 1
      THEN
        --
        calc_result := term_add_ins_amount_get_brutto(r_calc_param_prev
                                                     ,r_calc_param_curr
                                                     ,r_add_info
                                                     ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_fund_id_change = 1
      THEN
        RESULT := NULL;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      
      END IF;
    ELSIF r_calc_param_curr.premia_base_type = 1
    THEN
      dbms_output.put_line(' основание расчета брутто премия');
      IF r_add_info.is_assured_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение застр. Брутто без изменений');
        --
        calc_result := term_add_assured_get_brutto(r_calc_param_prev
                                                  ,r_calc_param_curr
                                                  ,r_add_info
                                                  ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      ELSIF r_add_info.is_period_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение срока страхования');
      
        calc_result := term_add_period_get_brutto(r_calc_param_prev
                                                 ,r_calc_param_curr
                                                 ,r_add_info
                                                 ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
        --
      ELSIF r_add_info.is_fee_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение брутто взноса ...');
        calc_result := term_add_fee_get_brutto(r_calc_param_prev
                                              ,r_calc_param_curr
                                              ,r_add_info
                                              ,r_calc_param_curr.premia_base_type);
        RESULT      := calc_result.tariff_netto;
      
      ELSIF r_add_info.is_payment_terms_id_change = 1
      THEN
        dbms_output.put_line(' Зафиксировано изменение периода оплаты ...');
        RESULT := r_calc_param_prev.tariff_netto;
      
      ELSE
        dbms_output.put_line(' Зафиксировано отсутствие изменений ...');
        RESULT := r_calc_param_prev.tariff_netto;
        dbms_output.put_line(' result ' || RESULT);
      END IF;
    END IF;
    RETURN ROUND(RESULT, gc_precision);
  END;

  /**
   * Расчет ,брутто тарифа по покрытию при наличии дополнительного соглашения по "Смешанное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION end_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_calc_param calc_param;
    --
    r_add_info add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' r_add_info.is_underwriting ' || r_add_info.is_underwriting ||
                         'r_calc_param.is_in_waiting_period ' || r_calc_param.is_in_waiting_period);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := end_add_get_brutto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...' || r_calc_param.age || ' ' ||
                           r_calc_param.period_year || ' ' || r_calc_param.s_coef || ' ' ||
                           r_calc_param.k_coef || ' ' || r_calc_param.f || ' ' ||
                           r_calc_param.deathrate_id);
      --      r_calc_param := get_calc_param (p_cover_id); -- Второй вызов наверняка не нужен
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := end_get_brutto(r_calc_param.age
                                ,r_calc_param.gender_type
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
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := end_get_brutto(r_calc_param.age
                                ,r_calc_param.gender_type
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
      dbms_output.put_line('Стандартный вариант расчета брутто... Вообще не понятно что с полисом. Точнее. ' ||
                           r_calc_param.age || ' ' || r_calc_param.period_year || ' ' ||
                           r_calc_param.s_coef || ' ' || r_calc_param.k_coef || ' ' || r_calc_param.f || ' ' ||
                           r_calc_param.deathrate_id);
      RESULT := end_get_brutto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  END;

  /**
   * Расчет нетто тарифа по покрытию при наличии дополнительного соглашения по "Смешанное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * при расчете использованы формулы. указанные в документе Изменения жизни
  */

  FUNCTION end_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_calc_param calc_param;
    --
    r_add_info add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
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
      RESULT := end_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := end_get_netto(r_calc_param.age
                               ,r_calc_param.gender_type
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
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := end_get_netto(r_calc_param.age
                               ,r_calc_param.gender_type
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
      RESULT := end_get_netto(r_calc_param.age
                             ,r_calc_param.gender_type
                             ,r_calc_param.period_year
                             ,r_calc_param.normrate
                             ,r_calc_param.s_coef
                             ,r_calc_param.k_coef
                             ,r_calc_param.f
                             ,r_calc_param.deathrate_id
                             ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION end_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    RESULT NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v_lx := pkg_amath.lx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id);
    v_qx := pkg_amath.qx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id);
  
    dbms_output.put_line('p_age ' || p_age || ' p_period_year' || p_period_year || ' p_gender_type ' ||
                         p_gender_type || ' p_k_coef ' || p_k_coef || ' p_s_coef ' || p_s_coef ||
                         ' p_deathrate_id ' || p_deathrate_id || ' p_normrate ' || p_normrate);
  
    v_axn  := pkg_amath.axn(p_age
                           ,p_period_year
                           ,p_gender_type
                           ,p_k_coef
                           ,p_s_coef
                           ,p_deathrate_id
                           ,p_normrate);
    v_a_xn := pkg_amath.a_xn(p_age
                            ,p_period_year
                            ,p_gender_type
                            ,p_k_coef
                            ,p_s_coef
                            ,1
                            ,p_deathrate_id
                            ,p_normrate);
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_g := v_axn / ((1 - p_f) * v_a_xn);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := ROUND(v_axn / (1 - p_f), gc_precision);
    ELSIF p_onepayment_property IS NULL
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := ROUND(v_axn / ((1 - p_f) * v_a_xn), gc_precision);
    END IF;
    dbms_output.put_line('v_Lx ' || v_lx || ' v_qx ' || v_qx || ' v_axn ' || v_axn || ' v_a_xn ' ||
                         v_a_xn || ' G ' || v_g);
    dbms_output.put_line('------------------------------------------');
  
    RESULT := v_g;
    RETURN RESULT;
    --
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION end_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_iax1n NUMBER;
    --
    RESULT NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v_lx   := pkg_amath.lx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id);
    v_qx   := pkg_amath.qx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id);
    v_axn  := pkg_amath.axn(p_age
                           ,p_period_year
                           ,p_gender_type
                           ,p_k_coef
                           ,p_s_coef
                           ,p_deathrate_id
                           ,p_normrate);
    v_a_xn := pkg_amath.a_xn(p_age
                            ,p_period_year
                            ,p_gender_type
                            ,p_k_coef
                            ,p_s_coef
                            ,1
                            ,p_deathrate_id
                            ,p_normrate);
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := ROUND(v_axn / v_a_xn, gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_p := ROUND(v_axn, gc_precision);
    END IF;
    dbms_output.put_line('v_Lx ' || v_lx || ' v_qx ' || v_qx || ' v_axn ' || v_axn ||
                         ' p_deathrate_id=' || p_deathrate_id || ' p_f=' || p_f || ' v_a_xn ' ||
                         v_a_xn || ' p_OnePayment=' || p_onepayment_property || ' P ' || v_p);
    dbms_output.put_line('---------');
  
    RESULT := v_p;
    RETURN RESULT;
    --
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION pepr_get_brutto
  (
    p_cover_id  IN NUMBER
   ,p_re_sign   IN NUMBER DEFAULT NULL
   ,p_no_change NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
    dbms_output.put_line('PEPR_GET_BRUTTO');
  
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0 AND p_no_change = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := pepr_add_get_brutto(p_cover_id, p_re_sign, p_no_change);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1 AND
          p_no_change = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pepr_get_brutto(r_calc_param.age
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.period_year
                                 ,r_calc_param.normrate
                                 ,r_calc_param.s_coef
                                 ,r_calc_param.k_coef
                                 ,r_calc_param.f
                                 ,r_calc_param.deathrate_id
                                 ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1 AND p_no_change = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pepr_get_brutto(r_calc_param.age
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.period_year
                                 ,r_calc_param.normrate
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
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      RESULT := pepr_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
    --
  END;

  FUNCTION pepr_get_brutto_chi
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
    dbms_output.put_line('PEPR_GET_BRUTTO');
  
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := pepr_add_get_brutto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        IF r_calc_param.age = 0
        THEN
          r_calc_param.age := 1;
          --r_calc_param.period_year := r_calc_param.period_year-1;
        END IF;
        RESULT := pepr_get_brutto(r_calc_param.age
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.period_year
                                 ,r_calc_param.normrate
                                 ,r_calc_param.s_coef
                                 ,r_calc_param.k_coef
                                 ,r_calc_param.f
                                 ,r_calc_param.deathrate_id
                                 ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        IF r_calc_param.age = 0
        THEN
          r_calc_param.age := 1;
          --r_calc_param.period_year := r_calc_param.period_year-1;
        END IF;
        RESULT := pepr_get_brutto(r_calc_param.age
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.period_year
                                 ,r_calc_param.normrate
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
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      IF r_calc_param.age = 0
      THEN
        r_calc_param.age := 1;
        --r_calc_param.period_year := r_calc_param.period_year-1;
      END IF;
      RESULT := pepr_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
    --
  END;

  FUNCTION pepr_get_netto
  (
    p_cover_id  IN NUMBER
   ,p_re_sign   IN NUMBER DEFAULT NULL
   ,p_no_change NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0 AND p_no_change = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := pepr_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1 AND
          p_no_change = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      RESULT := pepr_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1 AND p_no_change = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := pepr_get_netto(r_calc_param.age
                                ,r_calc_param.gender_type
                                ,r_calc_param.period_year
                                ,r_calc_param.normrate
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
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      RESULT := pepr_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
    --
  END;

  FUNCTION pepr_get_netto_chi
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := pepr_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      IF r_calc_param.age = 0
      THEN
        r_calc_param.age := 1;
        --r_calc_param.period_year := r_calc_param.period_year-1;
      END IF;
      RESULT := pepr_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        IF r_calc_param.age = 0
        THEN
          r_calc_param.age := 1;
          --r_calc_param.period_year := r_calc_param.period_year-1;
        END IF;
        RESULT := pepr_get_netto(r_calc_param.age
                                ,r_calc_param.gender_type
                                ,r_calc_param.period_year
                                ,r_calc_param.normrate
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
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      /*---------Приводим к общему виду с калькулятором, письмо от Максима Решетняка от 20-09-2011------------*/
      IF r_calc_param.age = 0
      THEN
        r_calc_param.age := 1;
        --r_calc_param.period_year := r_calc_param.period_year-1;
      END IF;
      RESULT := pepr_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
    --
  END;

  /*
  * Расчет брутто по покрытию договора страхования жизни по "страхование на дожитие с возвратом взносов"
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

  FUNCTION pepr_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_nex  NUMBER;
    --
    v_iax1n NUMBER;
    --
    RESULT NUMBER;
  BEGIN
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn  := ROUND(pkg_amath.a_xn(p_age
                                   ,p_period_year
                                   ,p_gender_type
                                   ,p_k_coef
                                   ,p_s_coef
                                   ,1
                                   ,p_deathrate_id
                                   ,p_normrate)
                    ,gc_precision);
    v_ax1n  := pkg_amath.ax1n(p_age
                             ,p_period_year
                             ,p_gender_type
                             ,p_k_coef
                             ,p_s_coef
                             ,p_deathrate_id
                             ,p_normrate);
    v_nex   := ROUND(pkg_amath.nex(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                    ,gc_precision);
    v_iax1n := pkg_amath.iax1n(p_age
                              ,p_period_year
                              ,p_gender_type
                              ,p_k_coef
                              ,p_s_coef
                              ,p_deathrate_id
                              ,p_normrate);
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := v_nex * (1 - p_f) / (v_a_xn * (1 - p_f) - v_iax1n);
      v_g := ROUND(v_nex / (v_a_xn * (1 - p_f) - v_iax1n), gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_p := ROUND(v_nex * (1 - p_f) / (1 - p_f - v_ax1n), gc_precision);
      v_g := ROUND(v_nex / (1 - p_f - v_ax1n), gc_precision);
    END IF;
    dbms_output.put_line(' p_f ' || p_f || ' v_qx ' || v_qx || ' v_Enx ' || v_nex || ' v_a_xn ' ||
                         v_a_xn || ' v_ax1n ' || v_ax1n || ' v_IAx1n ' || v_iax1n || ' G ' || v_g);
    dbms_output.put_line('------------------------------------------');
    RESULT := v_g;
    RETURN RESULT;
  END;

  FUNCTION pepr_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_nex  NUMBER;
    --
    v_iax1n NUMBER;
    --
    RESULT NUMBER;
  BEGIN
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn  := ROUND(pkg_amath.a_xn(p_age
                                   ,p_period_year
                                   ,p_gender_type
                                   ,p_s_coef
                                   ,p_k_coef
                                   ,1
                                   ,p_deathrate_id
                                   ,p_normrate)
                    ,gc_precision);
    v_ax1n  := pkg_amath.ax1n(p_age
                             ,p_period_year
                             ,p_gender_type
                             ,p_k_coef
                             ,p_s_coef
                             ,p_deathrate_id
                             ,p_normrate);
    v_nex   := ROUND(pkg_amath.nex(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                    ,gc_precision);
    v_iax1n := pkg_amath.iax1n(p_age
                              ,p_period_year
                              ,p_gender_type
                              ,p_k_coef
                              ,p_s_coef
                              ,p_deathrate_id
                              ,p_normrate);
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := v_nex * (1 - p_f) / (v_a_xn * (1 - p_f) - v_iax1n);
      v_g := ROUND(v_nex / (v_a_xn * (1 - p_f) - v_iax1n), gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_p := ROUND(v_nex * (1 - p_f) / (1 - p_f - v_ax1n), gc_precision);
      v_g := ROUND(v_nex / (1 - p_f - v_ax1n), gc_precision);
    END IF;
    dbms_output.put_line(' p_f ' || p_f || ' v_qx ' || v_qx || ' v_Enx ' || v_nex || ' v_a_xn ' ||
                         v_a_xn || ' v_ax1n ' || v_ax1n || ' G ' || v_g);
    dbms_output.put_line('------------------------------------------');
    RESULT := v_p;
    RETURN RESULT;
  END;

  /*
  * Расчет брутто по покрытию договора страхования жизни 
  * по "страхование на дожитие с возвратом взносов" для продукта Линия защиты
  * Alexey.Katkevich
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

  FUNCTION pepr_get_brutto_new
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p NUMBER;
    v_g NUMBER;
    -- v_qx NUMBER;
    --
    v_a_xn NUMBER;
    --  v_axn NUMBER;
    --
    --   v_Ax1n NUMBER;
    --  v_axn1 NUMBER;
    v_nex NUMBER;
    --
    v_iax1n NUMBER;
    /*   v_IAx1n_s NUMBER;
    
    Dx NUMBER;
    Rx NUMBER;
    Rxn NUMBER;
    Mxn NUMBER;*/
    --
    RESULT NUMBER;
  BEGIN
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn := ROUND(pkg_amath.a_xn(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
  
    --Прямой расчет - долго
    /*  dx:=ROUND (pkg_amath.dx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id, p_normrate), gc_precision);
    Rx:=ROUND (pkg_amath.Rx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id, p_normrate), gc_precision);
    Rxn:=ROUND (pkg_amath.Rx(p_age+p_period_year, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id, p_normrate), gc_precision);    
    Mxn:=ROUND (pkg_amath.Mx(p_age+p_period_year, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id, p_normrate), gc_precision);    
    
    v_IAx1n_s:=(rx-rxn-p_period_year*mxn)/dx;*/
  
    v_nex   := ROUND(pkg_amath.nex(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                    ,gc_precision);
    v_iax1n := pkg_amath.iax1n(p_age
                              ,p_period_year
                              ,p_gender_type
                              ,p_k_coef
                              ,p_s_coef
                              ,p_deathrate_id
                              ,p_normrate);
  
    v_p := (10 * v_nex + v_iax1n) / (10 * v_a_xn);
  
    v_g := ROUND((10 * v_nex + v_iax1n) / (10 * v_a_xn * ((1 - p_f))), gc_precision);
  
    RESULT := v_g;
    RETURN RESULT;
  END;

  FUNCTION pepr_get_netto_new
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p NUMBER;
    v_g NUMBER;
    -- v_qx NUMBER;
    --
    v_a_xn NUMBER;
    -- v_axn NUMBER;
    --
    --   v_Ax1n NUMBER;
    --   v_axn1 NUMBER;
    v_nex NUMBER;
    --
    v_iax1n NUMBER;
    --
    RESULT NUMBER;
  BEGIN
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn := ROUND(pkg_amath.a_xn(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    --v_ax1n := pkg_amath.Ax1n (p_age, p_period_year, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id, p_normrate);
    v_nex   := ROUND(pkg_amath.nex(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                    ,gc_precision);
    v_iax1n := pkg_amath.iax1n(p_age
                              ,p_period_year
                              ,p_gender_type
                              ,p_k_coef
                              ,p_s_coef
                              ,p_deathrate_id
                              ,p_normrate);
  
    v_p := (10 * v_nex + v_iax1n) / (10 * v_a_xn);
  
    v_g := ROUND((10 * v_nex + v_iax1n) / (10 * v_a_xn * (1 - p_f)), gc_precision);
  
    RESULT := v_p;
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни 
   * по "страхование на дожитие с возвратом взносов" для продукта Линия защиты
   * Alexey.Katkevich
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION pepr_get_netto_new
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
  
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0)
    THEN
      --В описании продукта (Линия Защиты) сказано что он не может менятся,
      --поэтому если есть допник то тариф используем старый
      r_calc_param := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
      RESULT       := r_calc_param.tariff;
    
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
    
      IF r_calc_param.is_error = 1
      THEN
        RETURN NULL;
      ELSE
        RESULT := pepr_get_netto_new(r_calc_param.age
                                    ,r_calc_param.gender_type
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
      dbms_output.put_line('Обычный расчет ....');
      RESULT := pepr_get_netto_new(r_calc_param.age
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.period_year
                                  ,r_calc_param.normrate
                                  ,r_calc_param.s_coef
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.f
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
    --
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни 
   * по "страхование на дожитие с возвратом взносов" для продукта Линия защиты
   * Alexey.Katkevich
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION pepr_get_brutto_new
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
  
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0)
    THEN
      --В описании продукта (Линия Защиты) сказано что он не может менятся,
      --поэтому если есть допник то тариф используем старый
      r_calc_param := get_calc_param(r_add_info.p_cover_id_prev, p_re_sign);
      RESULT       := r_calc_param.tariff;
    
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
    
      IF r_calc_param.is_error = 1
      THEN
        RETURN NULL;
      ELSE
        RESULT := pepr_get_brutto_new(r_calc_param.age
                                     ,r_calc_param.gender_type
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
      dbms_output.put_line('Обычный расчет ....');
      RESULT := pepr_get_brutto_new(r_calc_param.age
                                   ,r_calc_param.gender_type
                                   ,r_calc_param.period_year
                                   ,r_calc_param.normrate
                                   ,r_calc_param.s_coef
                                   ,r_calc_param.k_coef
                                   ,r_calc_param.f
                                   ,r_calc_param.deathrate_id
                                   ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
    --
  END;

  /*
   * Расчет брутто по покрытию договора страхования жизни по "пожизненное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */

  FUNCTION alltime_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_cover_id NUMBER;
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_iax1n NUMBER;
    --
    r_calc_param calc_param;
    --
    RESULT NUMBER;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id);
    --
    -- # Секция расчета страховой нетто премии
    v_ax   := pkg_amath.ax(r_calc_param.age
                          ,r_calc_param.gender_type
                          ,r_calc_param.k_coef
                          ,r_calc_param.s_coef
                          ,r_calc_param.deathrate_id
                          ,r_calc_param.normrate);
    v_a_xn := pkg_amath.a_xn(r_calc_param.age
                            ,r_calc_param.period_year
                            ,r_calc_param.gender_type
                            ,r_calc_param.k_coef
                            ,r_calc_param.s_coef
                            ,1
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.normrate);
    IF r_calc_param.is_one_payment = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := v_ax / v_a_xn;
      v_g := v_ax / ((1 - r_calc_param.f) * v_a_xn);
    ELSIF r_calc_param.is_one_payment = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := v_ax;
      v_g := v_ax / (1 - r_calc_param.f);
    END IF;
    dbms_output.put_line('v_Lx ' || v_lx || ' v_qx ' || v_qx || ' v_axn ' || v_axn || ' v_ax ' || v_ax ||
                         ' v_a_xn ' || ' G ' || v_g);
    dbms_output.put_line('--------');
    RESULT := v_g;
    RETURN RESULT;
  END;

  /**
   * Расчет брутто по покрытию договора страхования жизни по "страхование жизни на срок"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION term_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    --
    RESULT NUMBER := 0;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := term_add_get_brutto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андерайтинге ');
      --r_calc_param := get_calc_param (p_cover_id);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      END IF;
      RESULT := term_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      ELSE
        RESULT := term_get_brutto(r_calc_param.age
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.period_year
                                 ,r_calc_param.normrate
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
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      RESULT := term_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.normrate
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

  FUNCTION term_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    --
    RESULT NUMBER := 0;
    --
    r_add_info add_info;
    --
    r_calc_param calc_param;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := term_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андерайтинге ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      END IF;
      RESULT := term_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      ELSE
        RESULT := term_get_netto(r_calc_param.age
                                ,r_calc_param.gender_type
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
        RETURN 0; --NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      RESULT := term_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
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

  FUNCTION term_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_iax1n NUMBER;
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
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_g := v_ax1n / (v_a_xn * (1 - p_f));
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := v_ax1n / (1 - p_f);
    END IF;
    --dbms_output.put_line ('v_Lx '||v_Lx||' v_qx '||v_qx||' v_ax1n '||v_ax1n||' v_a_xn '||v_a_xn||' p_f '||p_f||' G '||v_G);
    --dbms_output.put_line ('p_OnePayment_Property '||p_OnePayment_Property||'-----------------');
    RESULT := nvl(v_g, 0);
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

  FUNCTION term_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_iax1n NUMBER;
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
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := v_ax1n / v_a_xn;
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_p := v_ax1n;
    END IF;
    --dbms_output.put_line ('v_Lx '||v_Lx||' v_qx '||v_qx||' v_ax1n '||v_ax1n||' v_a_xn '||v_a_xn||' p_f '||p_f||' G '||v_G);
    --dbms_output.put_line ('p_OnePayment_Property '||p_OnePayment_Property||'-----------------');
    RESULT := nvl(v_p, 0);
    RETURN RESULT;
  END;

  FUNCTION cri_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param calc_param;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    IF r_calc_param.is_error = 1
    THEN
      RETURN NULL;
    END IF;
    RESULT := cri_get_brutto(r_calc_param.age
                            ,r_calc_param.gender_type
                            ,r_calc_param.period_year
                            ,r_calc_param.normrate
                            ,r_calc_param.s_coef
                            ,r_calc_param.k_coef
                            ,r_calc_param.f
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.is_one_payment);
    --
    RETURN RESULT;
  END;

  /*
  * Расчет нетто по покрытию договора страхования жизни "кредитное страхование жизни (то же, что и TERM, другая ТС"
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

  FUNCTION cri_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p NUMBER;
    v_g NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_s_coef NUMBER;
    v_k_coef NUMBER;
    v_iax1n  NUMBER;
    --
    v_f    NUMBER;
    RESULT NUMBER;
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn := ROUND(pkg_amath.a_xn(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    v_ax1n := ROUND(pkg_amath.ax1n(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    IF p_onepayment_property = 0
       OR p_onepayment_property IS NULL
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_g := ROUND(v_ax1n / (v_a_xn * (1 - p_f)), gc_precision);
      v_p := ROUND(v_ax1n / (v_a_xn), gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := ROUND(v_ax1n / (1 - v_f), gc_precision);
      v_p := ROUND(v_ax1n, gc_precision);
    END IF;
    dbms_output.put_line(' v_axn ' || v_axn || ' v_ax ' || v_ax || ' v_a_xn ' || ' G ' || v_g);
    dbms_output.put_line('------------------------------------------');
    RESULT := v_g;
    RETURN RESULT;
  END;

  /*
  * Расчет брутто по покрытию договора
  * @author Marchuk A.
  * @param p_age          Возраст застрахованного
  */

  FUNCTION dd_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_calc_param calc_param;
    --
    r_add_info add_info;
    --
  BEGIN
    dbms_output.put_line('DD_get_brutto');
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := dd_add_get_brutto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := dd_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := dd_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,r_calc_param.period_year
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF r_add_info.p_cover_id_prev = r_add_info.p_cover_id_curr
    THEN
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Новое покрытие ... Стандартный вариант расчета ');
      RESULT := dd_get_brutto(r_calc_param.age
                             ,r_calc_param.gender_type
                             ,r_calc_param.period_year
                             ,r_calc_param.normrate
                             ,r_calc_param.s_coef
                             ,r_calc_param.k_coef
                             ,r_calc_param.f
                             ,r_calc_param.deathrate_id
                             ,r_calc_param.is_one_payment);
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Непонятное состояние полиса... Стандартный вариант расчета ');
      RESULT := dd_get_brutto(r_calc_param.age
                             ,r_calc_param.gender_type
                             ,r_calc_param.period_year
                             ,r_calc_param.normrate
                             ,r_calc_param.s_coef
                             ,r_calc_param.k_coef
                             ,r_calc_param.f
                             ,r_calc_param.deathrate_id
                             ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  END;

  /**
   * Расчет брутто по покрытию договора страхования жизни "первичное диагностирование смертельно опасного заболевания"
   * для продукта Platinum_LA2_CityService
   * @author Kaplya P.
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION dd_get_brutto_pla2_cs
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_calc_param calc_param;
    --
    r_add_info add_info;
    --
  BEGIN
    dbms_output.put_line('DD_get_brutto');
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := dd_add_get_brutto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := dd_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,15 /*r_calc_param.period_year*/
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := dd_get_brutto(r_calc_param.age
                               ,r_calc_param.gender_type
                               ,15 /*r_calc_param.period_year*/
                               ,r_calc_param.normrate
                               ,r_calc_param.s_coef
                               ,r_calc_param.k_coef
                               ,r_calc_param.f
                               ,r_calc_param.deathrate_id
                               ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF r_add_info.p_cover_id_prev = r_add_info.p_cover_id_curr
    THEN
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Новое покрытие ... Стандартный вариант расчета ');
      RESULT := dd_get_brutto(r_calc_param.age
                             ,r_calc_param.gender_type
                             ,15 /*r_calc_param.period_year*/
                             ,r_calc_param.normrate
                             ,r_calc_param.s_coef
                             ,r_calc_param.k_coef
                             ,r_calc_param.f
                             ,r_calc_param.deathrate_id
                             ,r_calc_param.is_one_payment);
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Непонятное состояние полиса... Стандартный вариант расчета ');
      RESULT := dd_get_brutto(r_calc_param.age
                             ,r_calc_param.gender_type
                             ,15 /*r_calc_param.period_year*/
                             ,r_calc_param.normrate
                             ,r_calc_param.s_coef
                             ,r_calc_param.k_coef
                             ,r_calc_param.f
                             ,r_calc_param.deathrate_id
                             ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  END;

  /*
  * Расчет брутто по покрытию договора
  * @author Marchuk A.
  * @param p_age          Возраст застрахованного
  */

  FUNCTION dd_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_calc_param calc_param;
    --
    r_add_info add_info;
    --
  BEGIN
    dbms_output.put_line('DD_get_brutto');
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := dd_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := dd_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
      END IF;
      --
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := dd_get_netto(r_calc_param.age
                              ,r_calc_param.gender_type
                              ,r_calc_param.period_year
                              ,r_calc_param.normrate
                              ,r_calc_param.s_coef
                              ,r_calc_param.k_coef
                              ,r_calc_param.f
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.is_one_payment);
      END IF;
    ELSIF r_add_info.p_cover_id_prev = r_add_info.p_cover_id_curr
    THEN
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Новое покрытие ... Стандартный вариант расчета ');
      RESULT := dd_get_netto(r_calc_param.age
                            ,r_calc_param.gender_type
                            ,r_calc_param.period_year
                            ,r_calc_param.normrate
                            ,r_calc_param.s_coef
                            ,r_calc_param.k_coef
                            ,r_calc_param.f
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.is_one_payment);
    ELSE
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      END IF;
      dbms_output.put_line('Непонятное состояние полиса... Стандартный вариант расчета ');
      RESULT := dd_get_netto(r_calc_param.age
                            ,r_calc_param.gender_type
                            ,r_calc_param.period_year
                            ,r_calc_param.normrate
                            ,r_calc_param.s_coef
                            ,r_calc_param.k_coef
                            ,r_calc_param.f
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни "первичное диагностирование смертельно опасного заболевания"
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

  FUNCTION dd_get_brutto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p NUMBER;
    v_g NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_s_coef NUMBER;
    v_k_coef NUMBER;
    v_iax1n  NUMBER;
    --
    v_f    NUMBER;
    RESULT NUMBER;
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn := ROUND(pkg_amath.a_xn(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    v_ax1n := ROUND(pkg_amath.ax1n(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    IF p_onepayment_property = 0
       OR p_onepayment_property IS NULL
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_g := ROUND(v_ax1n / (v_a_xn * (1 - p_f)), gc_precision);
      v_p := ROUND(v_ax1n / (v_a_xn), gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := ROUND(v_ax1n / (1 - p_f), gc_precision);
      v_p := ROUND(v_ax1n, gc_precision);
    END IF;
    dbms_output.put_line(' v_a_xn ' || v_a_xn || ' v_ax1n ' || v_ax1n || ' G ' || v_g);
    dbms_output.put_line('------------------------------------------');
    RESULT := v_g;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни "первичное диагностирование смертельно опасного заболевания"
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

  FUNCTION dd_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p NUMBER;
    v_g NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_s_coef NUMBER;
    v_k_coef NUMBER;
    v_iax1n  NUMBER;
    --
    v_f    NUMBER;
    RESULT NUMBER;
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    -- Задаем актуальную таблицу смертности для проведения расчета
    v_a_xn := ROUND(pkg_amath.a_xn(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,1
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    v_ax1n := ROUND(pkg_amath.ax1n(p_age
                                  ,p_period_year
                                  ,p_gender_type
                                  ,p_k_coef
                                  ,p_s_coef
                                  ,p_deathrate_id
                                  ,p_normrate)
                   ,gc_precision);
    IF p_onepayment_property = 0
       OR p_onepayment_property IS NULL
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_g := ROUND(v_ax1n / (v_a_xn * (1 - p_f)), gc_precision);
      v_p := ROUND(v_ax1n / (v_a_xn), gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_g := ROUND(v_ax1n / (1 - p_f), gc_precision);
      v_p := ROUND(v_ax1n, gc_precision);
    END IF;
    dbms_output.put_line(' v_a_xn ' || v_a_xn || ' v_ax1n ' || v_ax1n || ' G ' || v_g);
    dbms_output.put_line('------------------------------------------');
    RESULT := v_p;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни "освобождение от уплаты страховых взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION wop_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "инвест"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION i_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT NUMBER;
    --
    r_calc_param calc_param;
    --
    v_a_xn NUMBER;
    vn     NUMBER;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    IF r_calc_param.is_error = 1
    THEN
      RESULT := NULL;
      RETURN RESULT;
    END IF;
    IF r_calc_param.is_one_payment = 1
    THEN
      --*
      RESULT := ROUND(power(1 / (1 + r_calc_param.normrate), r_calc_param.period_year) /
                      (1 - r_calc_param.f)
                     ,6);
    ELSIF r_calc_param.is_one_payment = 0
    THEN
      v_a_xn := pkg_amath.a_xn(r_calc_param.age
                              ,r_calc_param.period_year
                              ,r_calc_param.gender_type
                              ,r_calc_param.k_coef
                              ,r_calc_param.s_coef
                              ,1
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.normrate);
      dbms_output.put_line('v_a_xn ' || v_a_xn);
      vn := power(1 / (1 + r_calc_param.normrate), r_calc_param.period_year);
      --*
      RESULT := ROUND(vn / ((1 - r_calc_param.f) * v_a_xn), 6);
    ELSE
      RESULT := NULL;
    END IF;
  
    dbms_output.put_line('power(1/(1 + r_calc_param.normrate) =' || vn || ' v_a_xn ' || v_a_xn ||
                         ' G=' || RESULT);
    RETURN RESULT;
  END;

  /*
   * Расчет нетто по покрытию договора страхования жизни "инвест"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION i_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT NUMBER;
    --
    r_calc_param calc_param;
    --
    v_a_xn NUMBER;
    vn     NUMBER;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    IF r_calc_param.is_error = 1
    THEN
      RESULT := NULL;
      RETURN RESULT;
    END IF;
    IF r_calc_param.is_one_payment = 1
    THEN
      RESULT := ROUND(power(1 / (1 + r_calc_param.normrate), r_calc_param.period_year), 6);
    ELSIF r_calc_param.is_one_payment = 0
    THEN
      v_a_xn := pkg_amath.a_xn(r_calc_param.age
                              ,r_calc_param.period_year
                              ,r_calc_param.gender_type
                              ,r_calc_param.k_coef
                              ,r_calc_param.s_coef
                              ,1
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.normrate);
      dbms_output.put_line('v_a_xn ' || v_a_xn);
      vn     := power(1 / (1 + r_calc_param.normrate), r_calc_param.period_year);
      RESULT := ROUND(vn / (v_a_xn), 6);
    ELSE
      RESULT := NULL;
    END IF;
  
    dbms_output.put_line('power(1/(1 + r_calc_param.normrate) =' || vn || ' v_a_xn ' || v_a_xn ||
                         ' G=' || RESULT);
    RETURN RESULT;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "смерть НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION ad_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "телесные повреждения в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION dism_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "инвалидность в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION adis_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "инвалидность по любой причине (НС + болезнь)"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION tpd_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "временная нетрудоспособность в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION atd_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
  /*
   * Расчет нетто по покрытию договора страхования жизни "госпитализация в результате НС"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION h_get_brutto(p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;

  /*
   * Расчет брутто взноса по покрытию договора при страховании по правилам "Страхование от несчастных случаев и болезней"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_PrdLife_Id     ИД страховой программы (временно введено в тестовых целях)
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION acc_get_brutto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT NUMBER;
    --
    r_calc_param calc_param;
    --
    v_a_xn       NUMBER;
    vn           NUMBER;
    v_p_cover_id NUMBER := p_cover_id;
  BEGIN
    log(v_p_cover_id, 'ACC_GET_BRUTTO');
  
    r_calc_param := get_calc_param(v_p_cover_id);
    --if r_calc_param.is_error = 1 then
    RESULT := NULL;
    --select tariff_netto into result  from p_cover where p_cover_id  = v_p_cover_id;
    --return nvl(r_calc_param.tariff_netto, 0);
    --end if;
  
    log(v_p_cover_id, 'ACC_GET_BRUTTO K_COEF_NM ' || r_calc_param.s_coef_nm);
    log(v_p_cover_id, 'ACC_GET_BRUTTO S_COEF_NM ' || r_calc_param.k_coef_nm);
  
    r_calc_param.s_coef := nvl(greatest(nvl(r_calc_param.s_coef_m, r_calc_param.s_coef_nm)
                                       ,nvl(r_calc_param.s_coef_nm, r_calc_param.s_coef_m))
                              ,0) / 1000;
    --
    r_calc_param.k_coef := nvl(greatest(nvl(r_calc_param.k_coef_m, r_calc_param.k_coef_nm)
                                       ,nvl(r_calc_param.k_coef_nm, r_calc_param.k_coef_m))
                              ,0) / 100;
  
    log(v_p_cover_id, 'ACC_GET_BRUTTO TARIFF_NETTO ' || r_calc_param.tariff_netto);
  
    log(v_p_cover_id, 'ACC_GET_BRUTTO K_COEF ' || r_calc_param.k_coef);
    log(v_p_cover_id, 'ACC_GET_BRUTTO S_COEF ' || r_calc_param.s_coef);
  
    RESULT := ROUND(r_calc_param.tariff_netto * (1 + nvl(r_calc_param.k_coef, 0)) +
                    nvl(r_calc_param.s_coef, 0)
                   ,gc_precision);
  
    log(v_p_cover_id, 'ACC_GET_BRUTTO RESULT ' || RESULT);
    RETURN RESULT;
  END;

  /*
   * Расчет суммы риска по покрытию договора страхования жизни "смешанное страхование"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION end_get_risk(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
    --
  BEGIN
    RETURN RESULT;
  END;

  /*
   * Расчет суммы риска по покрытию договора страхования жизни "освобождение от уплаты страховых взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION wop_get_risk(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    v_p_cover_id NUMBER;
  BEGIN
    v_p_cover_id := p_cover_id;
    SELECT SUM(pc_b.premium)
      INTO RESULT
      FROM ven_t_lob_line         ll
          ,ven_t_product_line
          ,ven_t_prod_line_option
          ,ven_p_cover            pc_b
          ,ven_p_cover            pc_a
     WHERE 1 = 1
       AND pc_a.p_cover_id = v_p_cover_id
       AND pc_b.as_asset_id = pc_a.as_asset_id
       AND pc_b.p_cover_id != pc_a.p_cover_id
       AND ven_t_prod_line_option.id = pc_b.t_prod_line_option_id
       AND ven_t_product_line.id = ven_t_prod_line_option.product_line_id
       AND ll.t_lob_line_id = ven_t_product_line.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life');
    RETURN RESULT;
  END;

  /*
   * Расчет суммы риска по покрытию договора страхования жизни "освобождение от уплаты страховых взносов"
   * @author Marchuk A.
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION wop_get_risk_basic(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    v_p_cover_id NUMBER;
  BEGIN
    v_p_cover_id := p_cover_id;
    -- Выбор страховой премии только по основной программе
    SELECT SUM(pc_b.premium)
      INTO RESULT
      FROM ven_t_product_line_type plt
          ,ven_t_lob_line          ll
          ,ven_t_product_line      pl
          ,ven_t_prod_line_option  plo
          ,ven_p_cover             pc_b
          ,ven_p_cover             pc_a
     WHERE 1 = 1
       AND pc_a.p_cover_id = v_p_cover_id
       AND pc_b.as_asset_id = pc_a.as_asset_id
       AND pc_b.p_cover_id != pc_a.p_cover_id
       AND plo.id = pc_b.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life')
       AND plt.product_line_type_id = pl.product_line_type_id
       AND plt.brief = 'RECOMMENDED';
    --
    RETURN RESULT;
  END;
  /*
   * Расчет суммы риска по покрытию договора страхования жизни "Инвест-резерв"
   * @author Veselek
   * @param p_cover_id       ИД покрытия
   * @param p_OnePayment_Property Признак единовременной(в рассрочку) оплаты. 0 - единовременно, 1 - в рассрочку
  */
  FUNCTION investreserve_get_risk(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT          NUMBER;
    min_p_policy_id NUMBER;
  BEGIN
  
    SELECT MIN(a.p_policy_id)
      INTO min_p_policy_id
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
                AND pol.version_num = 1));
  
    SELECT nvl(SUM(pc.fee), 0)
      INTO RESULT
      FROM ins.p_policy            pol
          ,ins.as_asset            a
          ,ins.p_cover             pc
          ,ins.t_prod_line_option  opt
          ,ins.t_product_line      pl
          ,ins.t_lob_line          ll
          ,ins.t_product_line_type plt
     WHERE pol.policy_id = min_p_policy_id
       AND pol.policy_id = a.p_policy_id
       AND a.as_asset_id = pc.as_asset_id
       AND pc.t_prod_line_option_id = opt.id
       AND opt.product_line_id = pl.id
       AND pl.t_lob_line_id = ll.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'PEPR_INVEST_RESERVE')
       AND plt.product_line_type_id = pl.product_line_type_id;
    /*SELECT SUM(pc_b.fee)
     INTO RESULT
     FROM ven_t_product_line_type plt
         ,ven_t_lob_line          ll
         ,ven_t_product_line      pl
         ,ven_t_prod_line_option  plo
         ,ven_p_cover             pc_b
         ,ven_p_cover             pc_a
    WHERE 1 = 1
      AND pc_a.p_cover_id = v_p_cover_id
      AND pc_b.as_asset_id = pc_a.as_asset_id
      AND pc_b.p_cover_id != pc_a.p_cover_id
      AND plo.ID = pc_b.t_prod_line_option_id
      AND pl.ID = plo.product_line_id
      AND ll.t_lob_line_id = pl.t_lob_line_id
      AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'PEPR_INVEST_RESERVE')
      AND plt.product_line_type_id = pl.product_line_type_id;*/
    --
    RETURN RESULT;
  END;
  /*
   * Расчет СС по покрытию "Дожитие Страхователя до потери работы..."
   * @author SLEZIN I.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION ppjl_get_risk_basic(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    v_p_cover_id NUMBER;
    proc_name    VARCHAR2(30) := 'PPJL_get_risk_BASIC';
  BEGIN
    v_p_cover_id := p_cover_id;
    -- Выбор страховой премии по основной программе и (освобождению либо защите)
    SELECT SUM(pc_b.premium)
      INTO RESULT
      FROM ven_t_product_line_type plt
          ,ven_t_lob_line          ll
          ,ven_t_product_line      pl
          ,ven_t_prod_line_option  plo
          ,ven_p_cover             pc_b
          ,ven_p_cover             pc_a
     WHERE 1 = 1
       AND pc_a.p_cover_id = v_p_cover_id
       AND pc_b.as_asset_id = pc_a.as_asset_id
       AND pc_b.p_cover_id != pc_a.p_cover_id
       AND plo.id = pc_b.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life')
       AND plt.product_line_type_id = pl.product_line_type_id
       AND (plt.brief = 'RECOMMENDED' OR ll.brief IN ('WOP', 'PWOP'));
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END ppjl_get_risk_basic;

  /*
   * Расчет СС по покрытию "Освобождение для FLA"
   * @author SLEZIN I.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION wop_get_risk_fla(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    v_p_cover_id NUMBER;
    proc_name    VARCHAR2(30) := 'WOP_get_risk_FLA';
  BEGIN
    v_p_cover_id := p_cover_id;
    -- Выбор страховой премии по основной программе и обязательным
    SELECT SUM(pc_b.premium)
      INTO RESULT
      FROM t_product_line_type plt
          ,t_lob_line          ll
          ,t_product_line      pl
          ,t_prod_line_option  plo
          ,p_cover             pc_a
          ,as_asset            aa_a
          ,as_assured          aas
          ,as_asset            aa_b
          ,p_cover             pc_b
          ,p_asset_header      pah
          ,t_asset_type        aat
     WHERE 1 = 1
       AND pc_a.p_cover_id = v_p_cover_id
       AND aa_a.as_asset_id = pc_a.as_asset_id
       AND aas.as_assured_id = aa_a.as_asset_id
       AND aas.assured_contact_id =
           pkg_policy.get_policy_contact(aa_a.p_policy_id, 'Страхователь')
       AND aa_b.p_policy_id = aa_a.p_policy_id
       AND pc_b.as_asset_id = aa_b.as_asset_id
       AND pah.p_asset_header_id = aa_b.p_asset_header_id
       AND aat.t_asset_type_id = pah.t_asset_type_id
       AND aat.brief IN ('ASSET_PERSON_ADULT', 'ASSET_PERSON') --застрахованный взрослый, Застрахованный
       AND plo.id = pc_b.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life')
       AND plt.product_line_type_id = pl.product_line_type_id
       AND plt.brief IN ('RECOMMENDED', 'MANDATORY');
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END wop_get_risk_fla;

  /*
   * Расчет СС по покрытию "Дожитие до потери работы для FLA"
   * @author SLEZIN I.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION ppjl_get_risk_fla(p_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    v_p_cover_id NUMBER;
    proc_name    VARCHAR2(30) := 'PPJL_get_risk_FLA';
  BEGIN
    v_p_cover_id := p_cover_id;
    -- Выбор страховой премии по основной программе, обязательным и Освобождению
    SELECT SUM(pc_b.premium)
      INTO RESULT
      FROM t_product_line_type plt
          ,t_lob_line          ll
          ,t_product_line      pl
          ,t_prod_line_option  plo
          ,p_cover             pc_a
          ,as_asset            aa_a
          ,as_assured          aas
          ,as_asset            aa_b
          ,p_cover             pc_b
          ,p_asset_header      pah
          ,t_asset_type        aat
     WHERE 1 = 1
       AND pc_a.p_cover_id = v_p_cover_id
       AND aa_a.as_asset_id = pc_a.as_asset_id
       AND aas.as_assured_id = aa_a.as_asset_id
       AND aas.assured_contact_id =
           pkg_policy.get_policy_contact(aa_a.p_policy_id, 'Страхователь')
       AND aa_b.p_policy_id = aa_a.p_policy_id
       AND pc_b.as_asset_id = aa_b.as_asset_id
       AND pah.p_asset_header_id = aa_b.p_asset_header_id
       AND aat.t_asset_type_id = pah.t_asset_type_id
       AND aat.brief IN ('ASSET_PERSON_ADULT', 'ASSET_PERSON') --застрахованный взрослый, Застрахованный
       AND plo.id = pc_b.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life')
       AND plt.product_line_type_id = pl.product_line_type_id
       AND (plt.brief IN ('RECOMMENDED', 'MANDATORY') OR ll.brief = 'WOP');
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END ppjl_get_risk_fla;

  /**
   * Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок FLA"
   * @author SLEZIN ILYA
   * @param p_cover_id       ИД покрытия
  */

  FUNCTION term_fla_get_netto
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT       NUMBER := 0;
    r_add_info   add_info;
    r_calc_param calc_param;
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
    r_add_info   := get_add_info(p_cover_id);
    dbms_output.put_line('r_add_info.p_cover_id_prev' || r_add_info.p_cover_id_prev ||
                         ' r_add_info.p_cover_id_curr ' || r_add_info.p_cover_id_curr ||
                         ' is_underwriting ' || r_add_info.is_underwriting);
    IF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 0 AND
       r_calc_param.is_in_waiting_period = 0)
    THEN
      dbms_output.put_line('Найдено доп соглашение... r_add_info.p_cover_id_prev' ||
                           r_add_info.p_cover_id_prev || ' r_add_info.p_cover_id_curr ' ||
                           r_add_info.p_cover_id_curr);
      RESULT := term_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андерайтинге ');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      --
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      END IF;
      RESULT := term_fla_get_netto(r_calc_param.age
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.period_year
                                  ,r_calc_param.normrate
                                  ,r_calc_param.s_coef
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.f
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.is_one_payment);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND
          r_calc_param.is_in_waiting_period = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в выжидательном периоде ...');
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN 0; --NULL;
      ELSE
        RESULT := term_fla_get_netto(r_calc_param.age
                                    ,r_calc_param.gender_type
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
        RETURN 0; --NULL;
      END IF;
      dbms_output.put_line('Обычный расчет ....');
      RESULT := term_fla_get_netto(r_calc_param.age
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.period_year
                                  ,r_calc_param.normrate
                                  ,r_calc_param.s_coef
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.f
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.is_one_payment);
    
    END IF;
    RETURN RESULT;
  END term_fla_get_netto;

  /* Расчет нетто по покрытию договора страхования жизни по "страхование жизни на срок FLA"
  * @author SLEZIN ILYA
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

  FUNCTION term_fla_get_netto
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_g  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_iax1n NUMBER;
    --
    v_f    NUMBER;
    RESULT NUMBER;
    v      NUMBER;
    vn     NUMBER;
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
    v      := 1 / (1 + p_normrate);
    vn     := power(v, p_period_year);
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := vn / v_a_xn;
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_p := vn;
    END IF;
    RESULT := nvl(v_p, 0);
    RETURN RESULT;
  END term_fla_get_netto;

  /*
    Байтин А.
    198215. Расчет страховой суммы для продукта Ситисервиса.
  */
  FUNCTION prin_dp_new_city_get_insamount(par_cover_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT ROUND(trunc(1 / pc.tariff, 5) * pc.fee, 2)
      INTO v_result
      FROM p_cover pc
     WHERE pc.p_cover_id = par_cover_id;
  
    RETURN v_result;
  END prin_dp_new_city_get_insamount;

  FUNCTION strong_start_get_netto(par_cover_id NUMBER) RETURN NUMBER IS
    v_netto_tariff NUMBER;
    v_adjustment   NUMBER;
    v_coef         NUMBER;
    v_re_rate      NUMBER;
    v_round        NUMBER;
  
    FUNCTION children_exists(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_children_exists BOOLEAN;
      v_children_count  PLS_INTEGER;
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
    
      v_children_exists := v_children_count > 0;
      RETURN v_children_exists;
    
    END children_exists;
  
    PROCEDURE get_round_and_coef
    (
      par_cover_id   p_cover.p_cover_id%TYPE
     ,par_adjustment OUT NUMBER
     ,par_coef_out   OUT NUMBER
     ,par_precision  OUT PLS_INTEGER
    ) IS
      v_product_line_desc      t_product_line.description%TYPE;
      v_asset_type_brief       t_asset_type.brief%TYPE;
      v_product_brief          t_product.brief%TYPE;
      v_discount_brief         discount_f.brief%TYPE;
      v_policy_id              p_policy.policy_id%TYPE;
      v_prod_line_option_brief t_prod_line_option.brief%TYPE;
    BEGIN
    
      SELECT (SELECT d.brief FROM discount_f d WHERE pp.discount_f_id = d.discount_f_id) discount
            ,p.brief roduct_brief
            ,at.brief asset_type_brief
            ,pl.description product_line_desc
            ,pp.policy_id
            ,plo.brief
        INTO v_discount_brief
            ,v_product_brief
            ,v_asset_type_brief
            ,v_product_line_desc
            ,v_policy_id
            ,v_prod_line_option_brief
        FROM p_cover            pc
            ,as_asset           aa
            ,p_asset_header     ah
            ,t_asset_type       at
            ,p_policy           pp
            ,p_pol_header       ph
            ,t_product          p
            ,t_prod_line_option plo
            ,t_product_line     pl
       WHERE pc.p_cover_id = par_cover_id
         AND pc.as_asset_id = aa.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND aa.p_policy_id = pp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = p.product_id;
    
      /* Определяем точность округления и adjustment */
      IF v_product_brief LIKE 'STRONG_START_RUS%'
      THEN
        par_adjustment := 0.005;
      
        par_precision := CASE v_product_brief
                           WHEN 'STRONG_START_RUS_2' THEN
                            6
                           ELSE
                            5
                         END;
      ELSIF v_product_brief LIKE 'STRONG_START_TRINITI%'
            OR v_product_brief LIKE 'STRONG_START_SIX_CONTINENTS%'
      THEN
        IF v_product_brief IN ('STRONG_START_TRINITI_1', 'STRONG_START_SIX_CONTINENTS_1')
        THEN
          par_adjustment := 0.1465;
          par_precision  := 7;
        ELSE
          par_adjustment := 0.142;
          par_precision  := 5;
        END IF;
      ELSIF v_product_brief LIKE 'STRONG_START_AVTODOM%'
      THEN
        IF v_product_brief = 'STRONG_START_AVTODOM_1'
        THEN
          par_adjustment := 0.27;
          par_precision  := 7;
        ELSE
          par_adjustment := 0.22;
          par_precision  := 5;
        END IF;
      ELSIF v_product_brief LIKE 'STRONG_START_ROLF__'
      THEN
      
        IF v_product_brief = 'STRONG_START_ROLF_1'
        THEN
          IF v_discount_brief IN ('База', '5%', '10%', '45%')
          THEN
            par_adjustment := 0.005;
          ELSIF v_discount_brief IN ('15%')
          THEN
            par_adjustment := 0.007;
          END IF;
        
          par_precision := 7;
        ELSE
          IF v_discount_brief IN ('База', '45%')
          THEN
            par_adjustment := 0.005;
          ELSIF v_discount_brief IN ('5%', '10%')
          THEN
            par_adjustment := 0.008;
          ELSIF v_discount_brief IN ('15%')
          THEN
            par_adjustment := 0.015;
          END IF;
          par_precision := 5;
        END IF;
        /*Настройки для Агент Моторс Черных М.Г. 19.08.2014*/
      ELSIF v_product_brief LIKE 'STRONG_START_AM__'
      THEN
        IF v_product_brief = 'STRONG_START_AM_1'
        THEN
          par_adjustment := 0.1472;
          par_precision  := 7;
        ELSE
          par_adjustment := 0.146;
          par_precision  := 5;
        END IF;
      END IF;
    
      /* Высчитываем коэффициент для программы */
      IF v_product_brief LIKE '%1'
      THEN
        par_coef_out := 1;
      ELSE
        IF v_asset_type_brief = 'ASSET_PERSON'
        THEN
          IF NOT children_exists(par_policy_id => v_policy_id)
             OR v_prod_line_option_brief IN ('AD', 'CrashDeath')
          THEN
            par_coef_out := 1;
          ELSE
            par_coef_out := 0.9;
          END IF;
        ELSE
          par_coef_out := 0.1 * 2;
        END IF;
      END IF;
    
      IF v_prod_line_option_brief IN ('AD', 'ADis', 'ADisChild')
      THEN
        par_coef_out := par_coef_out * 0.7;
      ELSIF v_prod_line_option_brief IN ('CrashDeath', 'CrashDis', 'CrashDisChild')
      THEN
        par_coef_out := par_coef_out * 0.3 / 2;
      END IF;
    
    END get_round_and_coef;
  
    FUNCTION get_re_rate(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
      v_re_rate NUMBER;
    BEGIN
      SELECT p.val
        INTO v_re_rate
        FROM t_prod_coef        p
            ,t_prod_coef_type   pct
            ,p_cover            pc
            ,t_prod_line_option plo
       WHERE pc.p_cover_id = par_cover_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = p.criteria_1
         AND p.t_prod_coef_type_id = pct.t_prod_coef_type_id
         AND pct.brief = pkg_prod_coef.gc_cr_re_rate_brief;
    
      RETURN v_re_rate;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не удалось определить значение коэффициента Re rate для покрытия');
      WHEN too_many_rows THEN
        raise_application_error(-20000
                               ,'Для данного покрытия обнаружено несколько коэффициентов Re rate');
    END get_re_rate;
  BEGIN
  
    get_round_and_coef(par_cover_id   => par_cover_id
                      ,par_adjustment => v_adjustment
                      ,par_coef_out   => v_coef
                      ,par_precision  => v_round);
  
    v_re_rate := get_re_rate(par_cover_id => par_cover_id);
  
    v_netto_tariff := ROUND(v_re_rate * (1 + v_adjustment), v_round) * v_coef;
  
    RETURN v_netto_tariff;
  
  END strong_start_get_netto;

  FUNCTION investor_lump_get_brutto(par_cover_id NUMBER) RETURN NUMBER IS
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
            v_result := 1 / 1.00703;
          WHEN 'PEPR_A' THEN
            v_result := 1 / 1.00703;
          WHEN 'PEPR_A_PLUS' THEN
            v_result := 1 / 0.80525;
        END CASE;
      
      ELSE
        DECLARE
          v_func_id NUMBER;
        BEGIN
          SELECT pl.tariff_func_id
            INTO v_func_id
            FROM t_prod_line_option plo
                ,t_product_line     pl
                ,p_cover            pc
           WHERE pc.p_cover_id = par_cover_id
             AND pc.t_prod_line_option_id = plo.id
             AND plo.product_line_id = pl.id;
        
          v_result := pkg_tariff_calc.calc_fun(p_id     => pkg_prod_coef.get_prod_coef_type_id_by_brief('brutto_for_investor_lump')
                                              ,p_ent_id => 305
                                              ,p_obj_id => par_cover_id);
        END;
    END CASE;
  
    RETURN v_result;
  
  END investor_lump_get_brutto;

  FUNCTION investor_lump_get_netto(par_cover_id NUMBER) RETURN NUMBER IS
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
            v_result := 1 / 1.00703 * (1 - 0.05);
          WHEN 'PEPR_A' THEN
            v_result := 1 / 1.00703 * (1 - 0.05);
          WHEN 'PEPR_A_PLUS' THEN
            v_result := 1 / 0.80525 * (1 - 0.18);
        END CASE;
      
      ELSE
        DECLARE
          v_func_id NUMBER;
        BEGIN
          SELECT pl.tariff_netto_func_id
            INTO v_func_id
            FROM t_prod_line_option plo
                ,t_product_line     pl
                ,p_cover            pc
           WHERE pc.p_cover_id = par_cover_id
             AND pc.t_prod_line_option_id = plo.id
             AND plo.product_line_id = pl.id;
        
          v_result := pkg_tariff_calc.calc_fun(p_id     => pkg_prod_coef.get_prod_coef_type_id_by_brief('netto_for_investor_lump')
                                              ,p_ent_id => 305
                                              ,p_obj_id => par_cover_id);
        END;
    END CASE;
  
    RETURN v_result;
  
  END investor_lump_get_netto;

  /**
   * Расчет нетто по покрытию договора страхования жизни по  программе "смешанное страхование жизни"
   * для продукта Семейный Депозит 2014
   * использует специальные для продукта функции пакета pkg_amath
   * @author Капля П., Доброхотова И.
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
  FUNCTION end_get_netto_famdep2014
  (
    p_age                 NUMBER
   ,p_gender_type         VARCHAR2
   ,p_period_year         NUMBER
   ,p_normrate            NUMBER
   ,p_s_coef              NUMBER
   ,p_k_coef              NUMBER
   ,p_f                   NUMBER
   ,p_deathrate_id        NUMBER
   ,p_onepayment_property IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    v_p  NUMBER;
    v_lx NUMBER;
    v_qx NUMBER;
    --
    v_a_xn NUMBER;
    v_axn  NUMBER;
    v_ax   NUMBER;
    --
    v_ax1n NUMBER;
    v_axn1 NUMBER;
    v_enx  NUMBER;
    --
    v_iax1n NUMBER;
    --
    RESULT NUMBER;
    --
  BEGIN
    --
    -- # Секция расчета страховой нетто премии
    v_lx := pkg_amath.lx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id);
    v_qx := pkg_amath.qx(p_age, p_gender_type, p_k_coef, p_s_coef, p_deathrate_id);
  
    v_axn := pkg_amath.axn_famdep2014(p_age
                                     ,p_period_year
                                     ,p_gender_type
                                     ,p_k_coef
                                     ,p_s_coef
                                     ,p_deathrate_id);
  
    v_a_xn := pkg_amath.a_xn_famdep2014(p_age
                                       ,p_period_year
                                       ,p_gender_type
                                       ,p_k_coef
                                       ,p_s_coef
                                       ,p_deathrate_id);
    IF p_onepayment_property = 0
    THEN
      -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
      v_p := ROUND(v_axn / v_a_xn, gc_precision);
    ELSIF p_onepayment_property = 1
    THEN
      -- Случай единовременоой оплаты страховой премии
      v_p := ROUND(v_axn, gc_precision);
    END IF;
    dbms_output.put_line('v_Lx ' || v_lx || ' v_qx ' || v_qx || ' v_axn ' || v_axn ||
                         ' p_deathrate_id=' || p_deathrate_id || ' p_f=' || p_f || ' v_a_xn ' ||
                         v_a_xn || ' p_OnePayment=' || p_onepayment_property || ' P ' || v_p);
    dbms_output.put_line('---------');
  
    RESULT := v_p;
    RETURN RESULT;
    --
  END end_get_netto_famdep2014;

  /*
   * Расчет нетто по покрытию договора страхования жизни по "смешанное страхование"
   * для продукта Семейный Депозит 2014
   * использует специальные для продукта функции пакета pkg_amath
   * @author Капля П., Доброхотова И.
   * @param p_cover_id       ИД покрытия
  */
  FUNCTION end_get_netto_famdep2014
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    --
    RESULT NUMBER;
    --
    r_calc_param_prev calc_param;
    --
    r_calc_param_curr calc_param;
    --
    r_calc_param calc_param;
    --
    r_add_info add_info;
    --
  BEGIN
    r_calc_param := get_calc_param(p_cover_id, p_re_sign);
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
      RESULT := end_add_get_netto(p_cover_id, p_re_sign);
    ELSIF (r_add_info.p_cover_id_prev != r_add_info.p_cover_id_curr AND r_add_info.is_underwriting = 1)
    THEN
      dbms_output.put_line('Найдено доп соглашение... Полис в андеррайтинге ...');
      r_calc_param := get_calc_param(p_cover_id, p_re_sign);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := end_get_netto_famdep2014(r_calc_param.age
                                          ,r_calc_param.gender_type
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
      --r_calc_param := get_calc_param (p_cover_id);
      IF r_calc_param.is_error = 1
      THEN
        dbms_output.put_line('Найдена ошибка в вводных данных. расчет невозможен.');
        RETURN NULL;
      ELSE
        RESULT := end_get_netto_famdep2014(r_calc_param.age
                                          ,r_calc_param.gender_type
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
      RESULT := end_get_netto_famdep2014(r_calc_param.age
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.period_year
                                        ,r_calc_param.normrate
                                        ,r_calc_param.s_coef
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.f
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.is_one_payment);
    
    END IF;
    --
    RETURN RESULT;
  END end_get_netto_famdep2014;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет нетто-тарифа для программы Страхование жизни к сроку
  FUNCTION ins_life_to_date_get_netto(par_cover_id NUMBER) RETURN NUMBER IS
    --    v_brutto     NUMBER;
    v_netto      NUMBER;
    v_loading    NUMBER;
    r_calc_param calc_param;
    v_a_xn       NUMBER;
    v_a_xn_1     NUMBER;
    v_p_1        NUMBER;
    v_p          NUMBER;
    v            NUMBER;
    v_n          NUMBER;
  BEGIN
    -- Определяем повышающие коэффициенты
    r_calc_param        := get_calc_param(par_cover_id);
    r_calc_param.s_coef := (coalesce(r_calc_param.s_coef_m, r_calc_param.s_coef_nm, 0) +
                           coalesce(r_calc_param.s_coef_nm, r_calc_param.s_coef_m, 0)) / 1000;
    r_calc_param.k_coef := (coalesce(r_calc_param.k_coef_m, r_calc_param.k_coef_nm, 0) +
                           coalesce(r_calc_param.k_coef_nm, r_calc_param.k_coef_m, 0)) / 100;
    -- нагрузка
    v_loading := r_calc_param.f;
    -- нетто-тариф для данного срока страхования                                         
    v_netto := pkg_tariff_calc.calc_fun(p_id     => pkg_prod_coef.get_prod_coef_type_id_by_brief('YEAR_NETTO_TARIF')
                                       ,p_ent_id => 305
                                       ,p_obj_id => par_cover_id);
  
    -- расчитываем нетто-тариф БЕЗ ПОВЫШАЮЩИХ КОЭФФИЦИЕНТОВ к таблице смертности    
    v   := 1 / (1 + r_calc_param.normrate);
    v_n := ROUND(power(v, r_calc_param.period_year), 10);
  
    v_a_xn := pkg_amath.a_xn(r_calc_param.age
                            ,r_calc_param.period_year
                            ,r_calc_param.gender_type
                            ,0
                            ,0
                            ,1
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.normrate);
  
    v_p := v_n / v_a_xn;
  
    -- расчитываем нетто-тариф С ПОВЫШАЮЩИМИ КОЭФФИЦИЕНТАМи к таблице смертности 
    v_a_xn_1 := pkg_amath.a_xn(r_calc_param.age
                              ,r_calc_param.period_year
                              ,r_calc_param.gender_type
                              ,r_calc_param.k_coef
                              ,r_calc_param.s_coef
                              ,1
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.normrate);
  
    v_p_1 := v_n / v_a_xn_1;
  
    --    v_brutto := (v_netto + greatest(v_p_1 - v_p, 0)) / (1 - v_loading);
    v_netto := v_netto + greatest(v_p_1 - v_p, 0);
  
    RETURN v_netto;
  END ins_life_to_date_get_netto;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет нетто-тарифа для программы Смерть Застрахованного по любой причине продуктов Наследия
  FUNCTION term_2_nasledie_get_netto(par_cover_id NUMBER) RETURN NUMBER IS
    --    v_brutto     NUMBER;
    v_netto      NUMBER;
    v_loading    NUMBER;
    r_calc_param calc_param;
    v_ax1n       NUMBER;
    v_ax1n_1     NUMBER;
    v_a_xn       NUMBER;
    v_a_xn_1     NUMBER;
    v_p          NUMBER;
    v_p_1        NUMBER;
  BEGIN
    -- Определяем повышающие коэффициенты
    r_calc_param        := get_calc_param(par_cover_id);
    r_calc_param.s_coef := (coalesce(r_calc_param.s_coef_m, r_calc_param.s_coef_nm, 0) +
                           coalesce(r_calc_param.s_coef_nm, r_calc_param.s_coef_m, 0)) / 1000;
    r_calc_param.k_coef := (coalesce(r_calc_param.k_coef_m, r_calc_param.k_coef_nm, 0) +
                           coalesce(r_calc_param.k_coef_nm, r_calc_param.k_coef_m, 0)) / 100;
  
    -- нагрузка
    v_loading := r_calc_param.f;
    -- нетто-тариф для данного срока страхования                                         
    v_netto := pkg_tariff_calc.calc_fun(p_id     => pkg_prod_coef.get_prod_coef_type_id_by_brief('YEAR_NETTO_TARIF')
                                       ,p_ent_id => 305
                                       ,p_obj_id => par_cover_id);
  
    -- расчитываем нетто-тариф БЕЗ ПОВЫШАЮЩИХ КОЭФФИЦИЕНТОВ к таблице смертности      
    v_ax1n := pkg_amath.ax1n(r_calc_param.age
                            ,r_calc_param.period_year
                            ,r_calc_param.gender_type
                            ,0
                            ,0
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.normrate);
    v_a_xn := pkg_amath.a_xn(r_calc_param.age
                            ,r_calc_param.period_year
                            ,r_calc_param.gender_type
                            ,0
                            ,0
                            ,1
                            ,r_calc_param.deathrate_id
                            ,r_calc_param.normrate);
    v_p    := v_ax1n / v_a_xn;
  
    -- расчитываем нетто-тариф С ПОВЫШАЮЩИМИ КОЭФФИЦИЕНТАМИ к таблице смертности 
    v_ax1n_1 := pkg_amath.ax1n(r_calc_param.age
                              ,r_calc_param.period_year
                              ,r_calc_param.gender_type
                              ,r_calc_param.k_coef
                              ,r_calc_param.s_coef
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.normrate);
    v_a_xn_1 := pkg_amath.a_xn(r_calc_param.age
                              ,r_calc_param.period_year
                              ,r_calc_param.gender_type
                              ,r_calc_param.k_coef
                              ,r_calc_param.s_coef
                              ,1
                              ,r_calc_param.deathrate_id
                              ,r_calc_param.normrate);
    v_p_1    := v_ax1n_1 / v_a_xn_1;
  
    --    v_brutto := (v_netto + greatest(v_p_1 - v_p, 0)) / (1 - v_loading);
    v_netto := v_netto + greatest(v_p_1 - v_p, 0);
  
    RETURN v_netto;
  END term_2_nasledie_get_netto;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет нетто-тарифа для программ Смерть НС, Смерть ДТП продуктов Наследия
  FUNCTION ad_nasledie_get_netto(par_cover_id NUMBER) RETURN NUMBER IS
    v_netto      NUMBER;
    r_calc_param calc_param;
  BEGIN
    -- Определяем повышающие коэффициенты
    r_calc_param        := get_calc_param(par_cover_id);
    r_calc_param.s_coef := (coalesce(r_calc_param.s_coef_m, r_calc_param.s_coef_nm, 0) +
                           coalesce(r_calc_param.s_coef_nm, r_calc_param.s_coef_m, 0)) / 1000;
    r_calc_param.k_coef := (coalesce(r_calc_param.k_coef_m, r_calc_param.k_coef_nm, 0) +
                           coalesce(r_calc_param.k_coef_nm, r_calc_param.k_coef_m, 0)) / 100;
  
    v_netto := pkg_tariff_calc.calc_fun(p_id     => pkg_prod_coef.get_prod_coef_type_id_by_brief(pkg_prod_coef.gc_cr_netto_tariff_brief)
                                       ,p_ent_id => 305
                                       ,p_obj_id => par_cover_id);
    v_netto := (v_netto + r_calc_param.s_coef) * (1 + r_calc_param.k_coef);
  
    RETURN v_netto;
  END ad_nasledie_get_netto;

  -- Доброхотова И., апрель, 2015  
  -- 403843: настройка модели расчета тарифов с учетом андер. коэф-тов 
  -- Расчет брутто-тарифа по базовой формуле без учета повышающих коэффициентов
  FUNCTION get_brutto_base_formula(par_cover_id NUMBER) RETURN NUMBER IS
    v_brutto     NUMBER;
    r_calc_param calc_param;
  BEGIN
    -- Определяем повышающие коэффициенты
    r_calc_param := get_calc_param(par_cover_id);
    v_brutto     := r_calc_param.tariff_netto / (1 - r_calc_param.f);
    RETURN v_brutto;
  END get_brutto_base_formula;
  ---------
BEGIN
  sys.dbms_output.disable;
END;
/
