CREATE OR REPLACE PACKAGE pkg_products IS

  -- Author  : Алексей Землянский
  -- Created : 22.12.2005 15:55:00
  -- Purpose : Утилиты для продуктов и всё что с ними связано (линии, периоды действия и т.д.)

  TYPE t_product_defaults IS RECORD(
     product_id           p_pol_header.product_id%TYPE
    ,product_brief        t_product.brief%TYPE
    ,fund_id              p_pol_header.fund_id%TYPE
    ,fund_pay_id          p_pol_header.fund_pay_id%TYPE
    ,fund_brief           fund.brief%TYPE
    ,confirm_condition_id p_pol_header.confirm_condition_id%TYPE
    ,payment_term_id      p_policy.payment_term_id%TYPE
    ,is_periodical        t_payment_terms.is_periodical%TYPE
    ,period_id            p_policy.period_id%TYPE
    ,waiting_period_id    p_policy.waiting_period_id%TYPE
    ,discount_f_id        p_policy.discount_f_id%TYPE
    ,paymentoff_term_id   p_policy.paymentoff_term_id%TYPE
    ,privilege_period_id  p_policy.pol_privilege_period_id%TYPE
    ,work_group_id        as_assured.work_group_id%TYPE);

  TYPE typ_prod_line_peril IS RECORD(
     peril_name t_peril.description%TYPE);
  TYPE typ_prod_line_peril_array IS TABLE OF typ_prod_line_peril;

  TYPE typ_prod_line_object IS RECORD(
     asset_type_brief       t_asset_type.brief%TYPE DEFAULT 'ASSET_PERSON'
    ,is_insured             NUMBER DEFAULT 0
    ,is_ins_amount_agregate NUMBER DEFAULT 1
    ,ins_amount_func_id     NUMBER DEFAULT NULL
    ,is_ins_amount_date     NUMBER DEFAULT 0);
  TYPE typ_prod_line_object_array IS TABLE OF typ_prod_line_object;

  TYPE typ_prod_line_coef IS RECORD(
     prod_coef_brief t_prod_coef_type.brief%TYPE
    ,sort_order      NUMBER
    ,is_restriction  NUMBER DEFAULT 0
    ,is_disable      NUMBER DEFAULT 0);
  TYPE typ_prod_line_coef_array IS TABLE OF typ_prod_line_coef;

  TYPE typ_prod_line_period IS RECORD(
     period_name t_period.description%TYPE
    ,period_type t_period_use_type.brief%TYPE
    ,is_disable  NUMBER DEFAULT 0
    ,sort_order  NUMBER
    ,is_default  NUMBER(1));
  TYPE typ_prod_line_period_array IS TABLE OF typ_prod_line_period;

  TYPE typ_prod_line_normrate IS RECORD(
     currency_brief fund.brief%TYPE
    ,normrate       NUMBER);
  TYPE typ_prod_line_normrate_array IS TABLE OF typ_prod_line_normrate;

  TYPE typ_prod_line_meth_decl IS RECORD(
     method_decl_brief t_metod_decline.brief%TYPE
    ,is_default        NUMBER(1) DEFAULT 1);
  TYPE typ_prod_line_meth_decl_array IS TABLE OF typ_prod_line_meth_decl;

  TYPE typ_product_line IS RECORD(
     prod_lob_line_brief            t_lob_line.brief%TYPE
    ,prod_line_type_brief           t_product_line_type.brief%TYPE
    ,prod_line_peril_array          typ_prod_line_peril_array
    ,prod_line_description          t_product_line.description%TYPE DEFAULT NULL
    ,prod_line_brief                t_product_line.brief%TYPE DEFAULT NULL
    ,prod_lob_brief                 t_lob.brief%TYPE DEFAULT NULL
    ,prod_line_is_visible           NUMBER DEFAULT 1
    ,prod_line_nocalc_reserve       NUMBER DEFAULT 1
    ,prod_line_premim_type          NUMBER DEFAULT 1
    ,prod_line_for_premium          NUMBER DEFAULT 1
    ,prod_line_sort_order           NUMBER DEFAULT NULL
    ,prod_line_franchise_brief      t_deductible_type.brief%TYPE DEFAULT 'NONE'
    ,prod_line_type_object_array    typ_prod_line_object_array DEFAULT NULL
    ,prod_line_coef_tar_array       typ_prod_line_coef_array DEFAULT NULL
    ,prod_line_fee_round_rules      t_round_rules.brief%TYPE DEFAULT NULL
    ,prod_line_amount_round_rules   t_round_rules.brief%TYPE DEFAULT NULL
    ,prod_line_cover_form_name      t_cover_form.brief%TYPE DEFAULT NULL
    ,prod_line_period               typ_prod_line_period_array DEFAULT NULL
    ,prod_line_calc_prem_brief      t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_tar_brief       t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_netto_brief     t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_fee_brief       t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_loading_brief   t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_amount_brief    t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_knonmed_brief   t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_snonmed_brief   t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_cost_brief      t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_calc_franchise_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
    ,prod_line_territory_brief      t_territory.brief%TYPE DEFAULT 'HW24'
    ,prod_line_norm_rate_array      typ_prod_line_normrate_array DEFAULT NULL
    ,prod_line_deathrate_brief      deathrate.brief%TYPE DEFAULT NULL
    ,prod_line_met_decl_array       typ_prod_line_meth_decl_array DEFAULT NULL);
  TYPE typ_product_line_array IS TABLE OF typ_product_line;

  TYPE typ_product_curator IS RECORD(
     employee_id   NUMBER
    ,department_id NUMBER
    ,is_default    NUMBER(1));
  TYPE typ_prod_curator_array IS TABLE OF typ_product_curator;

  TYPE typ_confirm_condition IS RECORD(
     confirm_condition_id   NUMBER
    ,contirm_condition_name t_confirm_condition.description%TYPE
    ,is_default             NUMBER(1));
  TYPE typ_confirm_condition_array IS TABLE OF typ_confirm_condition;

  TYPE typ_product_period IS RECORD(
     period_id             NUMBER
    ,period_use_type_brief t_period_use_type.brief%TYPE
    ,sort_order            NUMBER
    ,is_default            NUMBER(1));
  TYPE typ_product_period_array IS TABLE OF typ_product_period;

  TYPE typ_product_fund IS RECORD(
     fund_brief fund.brief%TYPE
    ,is_default NUMBER(1));
  TYPE typ_product_fund_array IS TABLE OF typ_product_fund;

  TYPE typ_product_contact_type IS RECORD(
     contact_type_brief t_contact_type.brief%TYPE);
  TYPE typ_product_contact_type_array IS TABLE OF typ_product_contact_type;

  TYPE typ_product_sales_chnl IS RECORD(
     sales_channel_brief t_sales_channel.brief%TYPE
    ,is_default          NUMBER(1));
  TYPE typ_product_sales_chnl_array IS TABLE OF typ_product_sales_chnl;

  TYPE typ_product_period_pay IS RECORD(
     period_brief         t_payment_terms.brief%TYPE
    ,is_default           NUMBER(1)
    ,collect_method_brief t_collection_method.brief%TYPE);
  TYPE typ_product_period_pay_array IS TABLE OF typ_product_period_pay;

  TYPE typ_product_document IS RECORD(
     issuer_doc_name t_issuer_doc_type.name%TYPE
    ,is_required     NUMBER(1)
    ,sort_order      NUMBER);
  TYPE typ_product_doc_array IS TABLE OF typ_product_document;

  TYPE typ_addendum_func IS RECORD(
     prod_coef_type_brief t_prod_coef_type.brief%TYPE
    ,sort_order           NUMBER);
  TYPE typ_add_func_array IS TABLE OF typ_addendum_func;

  TYPE typ_product_addendum IS RECORD(
     addendum_type_brief  t_addendum_type.brief%TYPE
    ,addendum_change_type t_policy_change_type.brief%TYPE
    ,addendum_function    typ_add_func_array);
  TYPE typ_product_addtype_array IS TABLE OF typ_product_addendum;

  TYPE typ_product_paym_order IS RECORD(
     payment_order t_payment_order.brief%TYPE
    ,is_default    NUMBER(1));
  TYPE typ_product_paym_order_array IS TABLE OF typ_product_paym_order;

  TYPE typ_product_bso_type IS RECORD(
     bso_type_brief bso_type.brief%TYPE);
  TYPE typ_product_bso_type_array IS TABLE OF typ_product_bso_type;

  TYPE typ_product_decline IS RECORD(
     decline_reason_brief t_decline_reason.brief%TYPE);
  TYPE typ_product_decline_array IS TABLE OF typ_product_decline;

  TYPE typ_policy_form IS RECORD(
     policy_form_name t_policy_form.t_policy_form_name%TYPE
    ,start_date       DATE
    ,end_date         DATE);
  TYPE typ_policy_form_array IS TABLE OF typ_policy_form;

  /*Создание пустого продукта и версии продукта
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, Имя продукта
    Остальные параметры по умолчанию
  */
  FUNCTION create_empty_product
  (
    p_product_name               VARCHAR2
   ,p_product_brief              VARCHAR2
   ,p_product_public_name        VARCHAR2
   ,p_policy_form_type_brief     VARCHAR2 DEFAULT 'Жизнь'
   ,p_product_group_brief        VARCHAR2 DEFAULT 'END'
   ,p_enabled                    BOOLEAN DEFAULT TRUE
   ,p_is_group                   BOOLEAN DEFAULT FALSE
   ,p_is_bso_polnum              BOOLEAN DEFAULT TRUE
   ,p_is_express                 BOOLEAN DEFAULT FALSE
   ,p_is_quart                   BOOLEAN DEFAULT FALSE
   ,p_use_ids_as_number          BOOLEAN DEFAULT TRUE
   ,p_version_start_date         DATE DEFAULT trunc(SYSDATE)
   ,p_version_end_date           DATE DEFAULT to_date('31.12.2099', 'DD.MM.YYYY')
   ,p_min_pol_period_in_days     NUMBER DEFAULT 1
   ,p_max_pol_period_in_days     NUMBER DEFAULT 10950
   ,p_min_program_count          NUMBER DEFAULT 1
   ,p_proposal_valid_days        NUMBER DEFAULT 60
   ,p_assured_count_limit        NUMBER DEFAULT 1
   ,p_custom_pol_calc_func_breif t_prod_coef_type.brief%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  /*Добавление DEFAULT продукта
    Капля П.С.
    17.06.2013
  */
  PROCEDURE create_default_product
  (
    par_product_name              VARCHAR2
   ,par_product_brief             VARCHAR2
   ,par_product_public_name       VARCHAR2
   ,par_bso_type_brief            VARCHAR2 DEFAULT NULL
   ,par_sales_channel_brief       VARCHAR2 DEFAULT NULL
   ,par_policy_form_desc          VARCHAR2 DEFAULT NULL
   ,par_policy_form_start_date    DATE DEFAULT trunc(SYSDATE)
   ,par_product_group_brief       VARCHAR2 DEFAULT 'END'
   ,par_enabled                   BOOLEAN DEFAULT TRUE
   ,par_is_group                  BOOLEAN DEFAULT FALSE
   ,par_is_bso_polnum             BOOLEAN DEFAULT TRUE
   ,par_is_express                BOOLEAN DEFAULT FALSE
   ,par_is_quart                  BOOLEAN DEFAULT FALSE
   ,par_use_ids_as_number         BOOLEAN DEFAULT TRUE
   ,par_version_start_date        DATE DEFAULT trunc(SYSDATE)
   ,par_version_end_date          DATE DEFAULT to_date('31.12.2099', 'DD.MM.YYYY')
   ,par_min_pol_period_in_days    NUMBER DEFAULT 1
   ,par_max_pol_period_in_days    NUMBER DEFAULT 10950
   ,par_assured_count_limit       NUMBER DEFAULT 1
   ,par_min_program_count         NUMBER DEFAULT 1
   ,par_proposal_valid_days       NUMBER DEFAULT 60
   ,par_t_confirm_condition_desc  VARCHAR2 DEFAULT 'С момента поступления первого взноса'
   ,par_ins_t_period_desc         VARCHAR2 DEFAULT '1 Год'
   ,par_wait_t_period_desc        VARCHAR2 DEFAULT 'Нет'
   ,par_grace_t_period_desc       VARCHAR2 DEFAULT 'Нет'
   ,par_currency_brief            VARCHAR2 DEFAULT 'RUR'
   ,par_payoff_currency_brief     VARCHAR2 DEFAULT 'RUR'
   ,par_payment_terms_brief       VARCHAR2 DEFAULT 'Единовременно'
   ,par_paym_coll_method_brief    VARCHAR2 DEFAULT 'Безналичный расчет'
   ,par_claim_payment_terms_brief VARCHAR2 DEFAULT 'Единовременно'
   ,par_claim_coll_method_brief   VARCHAR2 DEFAULT 'Безналичный расчет'
   ,par_contact_type              VARCHAR2 DEFAULT 'ФЛ'
   ,par_discount_brief            VARCHAR DEFAULT 'База'
   ,par_cust_pol_calc_func_breif  VARCHAR2 DEFAULT NULL
  );
  /*Поиск ИД продукта по Брифу Продукта
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта
  */
  FUNCTION get_product_id(par_product_brief VARCHAR2) RETURN NUMBER;
  /*Поиск ИД типа доп соглашения по Брифу
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф типа доп соглашения
  */
  FUNCTION get_addendum_type_id(par_addendum_brief VARCHAR2) RETURN NUMBER;
  /*Поиск ИД Страховой программы по Брифу Страховой программы
    Веселуха Е.В.
    17.06.2013
    Параметры обязательные: Бриф Страховой программы
  */
  PROCEDURE get_lob_line_id
  (
    par_lob_line_brief VARCHAR2
   ,par_lob_line_desc  OUT VARCHAR2
   ,par_lob_line_id    OUT NUMBER
  );

  FUNCTION get_product_line_id
  (
    par_product_brief     VARCHAR2
   ,par_product_line_desc VARCHAR2
  ) RETURN NUMBER;

  FUNCTION get_product_addendum
  (
    par_product_brief       t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
  ) RETURN t_product_addendum.t_product_addendum_id%TYPE;
  /*Добавление кураторов по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, ИД персоны
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_curators
  (
    par_product_brief        t_product.brief%TYPE
   ,par_employee_id          NUMBER
   ,par_organization_tree_id NUMBER DEFAULT NULL
   ,par_department_id        NUMBER DEFAULT NULL
   ,par_is_default           BOOLEAN DEFAULT TRUE
  );
  /*Добавление Условий вступления в силу по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_confirm_condition
  (
    par_product_brief          t_product.brief%TYPE
   ,par_confirm_condition_desc t_confirm_condition.description%TYPE DEFAULT 'С момента поступления первого взноса'
   ,par_is_default             BOOLEAN DEFAULT TRUE
  );
  /*Добавление Периодов по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, Значение периода
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_period
  (
    par_product_brief      t_product.brief%TYPE
   ,par_period_desc        t_period.description%TYPE
   ,par_period_type_brief  t_period_use_type.brief%TYPE DEFAULT 'Срок страхования'
   ,par_sort_order         t_product_period.sort_order%TYPE DEFAULT NULL
   ,par_is_default         BOOLEAN DEFAULT TRUE
   ,par_control_func_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
  );
  /*Добавление Валюты ответственности по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, Бриф валюты
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_currency
  (
    par_product_brief  t_product.brief%TYPE
   ,par_currency_brief fund.brief%TYPE DEFAULT 'RUR'
   ,par_is_default     BOOLEAN DEFAULT TRUE
  );
  /*Добавление Валюты платежа по продукту
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф валюты
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_pay_currency
  (
    par_product_brief  t_product.brief%TYPE
   ,par_currency_brief fund.brief%TYPE DEFAULT 'RUR'
   ,par_is_default     BOOLEAN DEFAULT TRUE
  );
  /*Добавление Тип контакта для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_type_contact
  (
    par_product_brief t_product.brief%TYPE
   ,par_type_brief    t_contact_type.brief%TYPE DEFAULT 'ФЛ'
  );
  /*Добавление Канала продаж для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_sales_chnl
  (
    par_product_brief    t_product.brief%TYPE
   ,par_sales_chnl_brief t_sales_channel.brief%TYPE DEFAULT 'MLM'
   ,par_is_default       BOOLEAN DEFAULT TRUE
  );
  /*Добавление Типа премии и Способа оплаты для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф типа премии
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_period_pay
  (
    par_product_brief     t_product.brief%TYPE
   ,par_payment_brief     t_payment_terms.brief%TYPE
   ,par_coll_method_brief t_collection_method.brief%TYPE DEFAULT 'Безналичный расчет'
   ,par_is_default        BOOLEAN DEFAULT TRUE
  );
  /*Добавление Типа премии и Способа выплаты для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф выплаты
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_period_payoff
  (
    par_product_brief     t_product.brief%TYPE
   ,par_payment_brief     t_payment_terms.brief%TYPE
   ,par_coll_method_brief t_collection_method.brief%TYPE DEFAULT 'Безналичный расчет'
   ,par_is_default        BOOLEAN DEFAULT TRUE
  );
  /*Добавление Документов для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_documents
  (
    par_product_brief        t_product.brief%TYPE
   ,par_issuer_doc_type_name t_issuer_doc_type.name%TYPE
   ,par_sort_order           t_prod_issuer_doc.sort_order%TYPE DEFAULT NULL
   ,par_is_required          BOOLEAN DEFAULT FALSE
  );

  /*Добавление Всех доступных документов для продукта
    Капля П.С.
    21.06.2014
    Параметры обязательные: Бриф продукта
  */
  PROCEDURE add_product_documents_all(par_product_brief t_product.brief%TYPE);

  /*Добавление Доп соглашений для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф доп соглашения
    Остальные параметры по умолчанию
  */
  FUNCTION add_product_addendum
  (
    par_product_brief       t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
   ,par_type_change_brief   t_policy_change_type.brief%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  /*Добавление Функций в Доп соглашения для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф доп соглашения, Бриф функции
    Остальные параметры по умолчанию
  */
  FUNCTION add_product_addendum_func
  (
    par_product_brief       t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
   ,par_func_brief          t_prod_coef_type.brief%TYPE
   ,par_sort_order          t_product_add_func.sort_order%TYPE DEFAULT NULL
   ,par_comments            t_product_add_func.comments%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  /*
    Капля П.
    Процедура добавления связи продукта со скидкой
  */
  PROCEDURE add_product_discount
  (
    par_product_brief  t_product.brief%TYPE
   ,par_discount_brief discount_f.brief%TYPE
   ,par_is_default     BOOLEAN DEFAULT FALSE
   ,par_is_active      BOOLEAN DEFAULT TRUE
   ,par_sort_order     t_product_discount.sort_order%TYPE DEFAULT NULL
  );

  /*
    Капля П.
    Процедура добавления связи продукта с внешней системой
    Используется для пометки продуктов для возможности работы с интеграцией
  */
  PROCEDURE add_product_external_system
  (
    par_product_brief         VARCHAR2
   ,par_external_system_brief VARCHAR2
  );

  /*
  Капля П.
    21.06.2014
    Копирование функций на доп соглашении между продуктами
  */
  PROCEDURE copy_product_addendum_funcs
  (
    par_src_product_brief        t_product.brief%TYPE
   ,par_src_addendum_type_brief  t_addendum_type.brief%TYPE
   ,par_dest_product_brief       t_product.brief%TYPE
   ,par_dest_addendum_type_brief t_addendum_type.brief%TYPE
  );
  PROCEDURE copy_product_addendum_funcs
  (
    par_src_product_addendum_id  t_product_addendum.t_product_addendum_id%TYPE
   ,par_dest_product_addendum_id t_product_addendum.t_product_addendum_id%TYPE
  );

  /*
  Капля П.
  14.08.2013
  Функция копирования доп соглашения из другого продукта вместе со всеми проверочными функциями
  */
  PROCEDURE copy_addendum_type
  (
    par_dest_product_id  NUMBER
   ,par_addendum_type_id NUMBER
   ,par_src_product_id   NUMBER
  );
  PROCEDURE copy_addendum_type
  (
    par_dest_product_brief  t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
   ,par_src_product_brief   t_product.brief%TYPE
  );

  /*Добавление Порядка выплаты для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_pay_order
  (
    par_product_brief   t_product.brief%TYPE
   ,par_pay_order_brief t_payment_order.brief%TYPE
   ,par_is_default      BOOLEAN DEFAULT FALSE
  );
  /*Добавление Типа БСО для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф типа БСО
  */
  PROCEDURE add_product_bso_type
  (
    par_product_brief  t_product.brief%TYPE
   ,par_bso_type_brief bso_type.brief%TYPE
  );
  /*Добавление Типа Расторжения для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф типа расторжения
  */
  PROCEDURE add_product_decline_type
  (
    par_product_brief        t_product.brief%TYPE
   ,par_decline_reason_brief t_decline_reason.brief%TYPE
  );
  /*Добавление Типа Территории для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
  */
  PROCEDURE add_product_territory
  (
    par_product_brief   t_product.brief%TYPE
   ,par_territory_brief t_territory.brief%TYPE DEFAULT 'HW24'
  );
  /*Добавление Типа Полисных условий для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф Полисных условий
  */
  PROCEDURE add_product_policy_form
  (
    par_product_brief    t_product.brief%TYPE
   ,par_policy_form_desc t_policy_form.t_policy_form_name%TYPE
   ,par_start_date       DATE
   ,par_end_date         DATE DEFAULT to_date('31.12.2999', 'DD.MM.YYYY')
  );

  /*Добавление фукции контроля по продукту
  Капля П.С.
  25.06.2013
  Параметры обязательные: Бриф продукта, Бриф функции
  */
  PROCEDURE add_product_control_func
  (
    par_product_brief       t_product.brief%TYPE
   ,par_func_brief          t_prod_coef_type.brief%TYPE
   ,par_is_underwriting_check BOOLEAN DEFAULT FALSE
   ,par_product_version_num t_product_version.version_nr%TYPE DEFAULT NULL
   ,par_sort_order          t_product_control.sort_order%TYPE DEFAULT NULL
   ,par_message             t_product_control.message%TYPE DEFAULT NULL
  );

  /*Добавление линий продуктов в продукт
    Веселуха Е.В.
    17.06.2013
  */
  PROCEDURE add_empty_prod_line
  (
    par_product_brief              VARCHAR2
   ,par_lob_line_brief             VARCHAR2
   ,par_peril_array                tt_one_col
   ,par_product_line_desc          VARCHAR2 DEFAULT NULL
   ,par_product_line_brief         VARCHAR2 DEFAULT NULL
   ,par_product_line_type_brief    VARCHAR2 DEFAULT 'RECOMMENDED'
   ,par_public_description         VARCHAR2 DEFAULT NULL
   ,par_sort_order                 NUMBER DEFAULT NULL
   ,par_is_aggregate               BOOLEAN DEFAULT TRUE
   ,par_is_avtoprolongation        BOOLEAN DEFAULT FALSE
   ,par_skip_on_policy_creation    BOOLEAN DEFAULT FALSE
   ,pat_t_prolong_alg_brief        VARCHAR2 DEFAULT NULL
   ,par_t_prod_line_option_brief   VARCHAR2 DEFAULT NULL
   ,par_t_prod_line_option_desc    VARCHAR2 DEFAULT NULL
   ,par_amount_round_rules_brief   VARCHAR2 DEFAULT NULL
   ,par_fee_round_rules_brief      VARCHAR2 DEFAULT NULL
   ,par_tariff_func_precision      NUMBER DEFAULT 6
   ,par_netto_func_precision       NUMBER DEFAULT 6
   ,par_loading_func_precision     NUMBER DEFAULT NULL
   ,par_premium_func_precision     NUMBER DEFAULT NULL
   ,par_ins_price_func_precision   NUMBER DEFAULT NULL
   ,par_premium_func_brief         VARCHAR2 DEFAULT 'CALC_STANDART_PREMIUM'
   ,par_tariff_func_brief          VARCHAR2 DEFAULT NULL
   ,par_tariff_cost_value          NUMBER DEFAULT NULL
   ,par_tariff_netto_func_brief    VARCHAR2 DEFAULT NULL
   ,par_tariff_netto_cost_value    NUMBER DEFAULT NULL
   ,par_ins_amount_func_brief      VARCHAR2 DEFAULT NULL
   ,par_k_coef_nm_func_brief       VARCHAR2 DEFAULT NULL
   ,par_deduct_func_brief          VARCHAR2 DEFAULT NULL
   ,par_fee_func_brief             VARCHAR2 DEFAULT NULL
   ,par_ins_price_func_brief       VARCHAR2 DEFAULT NULL
   ,par_loading_func_brief         VARCHAR2 DEFAULT NULL
   ,par_loading_cost_value         NUMBER DEFAULT NULL
   ,par_s_coef_nm_func_brief       VARCHAR2 DEFAULT NULL
   ,par_precalc_ins_amount         BOOLEAN DEFAULT FALSE
   ,par_precalc_fee                BOOLEAN DEFAULT FALSE
   ,par_active_in_wait_period      BOOLEAN DEFAULT TRUE
   ,par_disable_reserve_calc       BOOLEAN DEFAULT FALSE
   ,par_fee_invest_part_func_brief VARCHAR2 DEFAULT NULL
   ,par_agregation_control_flag    BOOLEAN DEFAULT TRUE
  );
  /*Добавление Франшизы в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_franchise
  (
    par_product_brief           t_product.brief%TYPE
   ,par_prod_line_desc          t_product_line.description%TYPE
   ,par_t_deductible_type_brief t_deductible_type.brief%TYPE DEFAULT 'NONE'
   ,par_is_default              BOOLEAN DEFAULT TRUE
   ,par_t_deduct_val_type_brief t_deduct_val_type.brief%TYPE DEFAULT 'PERCENT'
   ,par_default_value           t_prod_line_deduct.default_value%TYPE DEFAULT NULL
   ,par_is_handchange_enabled   BOOLEAN DEFAULT FALSE
  );
  /*Удаление Франшизы из Линии продукта
    Веселуха Е.В.
    19.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE del_prod_line_franchise
  (
    par_product_brief           t_product.brief%TYPE
   ,par_prod_line_desc          t_product_line.description%TYPE
   ,par_t_deductible_type_brief t_deductible_type.brief%TYPE DEFAULT NULL
  );
  /*Добавление Вида объекта в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_objects
  (
    par_product_brief          t_product.brief%TYPE
   ,par_prod_line_desc         t_product_line.description%TYPE
   ,par_t_asset_type_brief     t_asset_type.brief%TYPE DEFAULT 'ASSET_PERSON'
   ,par_t_prod_coef_type_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_is_insured             BOOLEAN DEFAULT FALSE
   ,par_is_ins_amount_agregate BOOLEAN DEFAULT TRUE
   ,par_is_ins_amount_date     BOOLEAN DEFAULT FALSE
   ,par_is_fee_agregate        BOOLEAN DEFAULT TRUE
   ,par_is_prem_agregate       BOOLEAN DEFAULT TRUE
  );
  /*Добавление Коэф.тарифа в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта, Бриф функции тарифа
  */
  PROCEDURE add_prod_line_coef_tar
  (
    par_product_brief          t_product.brief%TYPE
   ,par_prod_line_desc         t_product_line.description%TYPE
   ,par_t_prod_coef_type_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_is_restriction         BOOLEAN DEFAULT FALSE
   ,par_is_disabled            BOOLEAN DEFAULT FALSE
   ,par_sort_order             t_prod_line_coef.sort_order%TYPE DEFAULT NULL
  );
  /*Добавление Доп.параметров в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
    DEPRECATED
  */
  /*
  PROCEDURE add_prod_line_more_option
  (
    par_product_brief            VARCHAR2
   ,par_prod_line_desc           VARCHAR2
   ,par_prod_line_brief          VARCHAR2 DEFAULT NULL
   ,par_amount_round_rules_brief VARCHAR2 DEFAULT NULL
   ,par_fee_round_rules_brief    VARCHAR2 DEFAULT NULL
   ,par_tariff_func_precision    NUMBER DEFAULT NULL
   ,par_netto_func_precision     NUMBER DEFAULT NULL
   ,par_premium_func_precision   NUMBER DEFAULT NULL
   ,par_ins_price_func_precision NUMBER DEFAULT NULL
  );
  */
  /*Добавление периодов в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта, Значение периода
  */
  PROCEDURE add_prod_line_period
  (
    par_product_brief           t_product.brief%TYPE
   ,par_prod_line_desc          t_product_line.description%TYPE
   ,par_period_desc             t_period.description%TYPE
   ,par_t_period_use_type_brief t_period_use_type.brief%TYPE DEFAULT 'Срок страхования'
   ,par_control_func_brief      t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_is_default              BOOLEAN DEFAULT FALSE
   ,par_is_disabled             BOOLEAN DEFAULT FALSE
   ,par_sort_order              t_prod_line_period.sort_order%TYPE DEFAULT NULL
  );
  /*Добавление Функций в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
    DEPRECATED
  */
  /*
  PROCEDURE add_prod_line_function
  (
    par_product_brief           VARCHAR2
   ,par_prod_line_desc          VARCHAR2
   ,par_premium_func_brief      VARCHAR2 DEFAULT NULL
   ,par_tariff_func_brief       VARCHAR2 DEFAULT NULL
   ,par_tariff_netto_func_brief VARCHAR2 DEFAULT NULL
   ,par_ins_amount_func_brief   VARCHAR2 DEFAULT NULL
   ,par_k_coef_nm_func_brief    VARCHAR2 DEFAULT NULL
   ,par_deduct_func_brief       VARCHAR2 DEFAULT NULL
   ,par_fee_func_brief          VARCHAR2 DEFAULT NULL
   ,par_ins_price_func_brief    VARCHAR2 DEFAULT NULL
   ,par_loading_func_brief      VARCHAR2 DEFAULT NULL
   ,par_s_coef_nm_func_brief    VARCHAR2 DEFAULT NULL
  );
  */
  /*Добавление Функции контроля покрытия в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта, Бриф функции контроля покрыти
  */
  PROCEDURE add_prod_line_control
  (
    par_product_brief        t_product.brief%TYPE
   ,par_prod_line_desc       t_product_line.description%TYPE
   ,par_func_limit_brief     t_prod_coef_type.brief%TYPE
   ,par_is_precreation_check BOOLEAN DEFAULT FALSE
   ,par_is_underwriting_check BOOLEAN DEFAULT FALSE
   ,par_comments             t_product_line_limit.comments%TYPE DEFAULT NULL
   ,par_sort_order           t_product_line_limit.sort_order%TYPE DEFAULT NULL
   ,par_message              t_product_line_limit.message%TYPE DEFAULT NULL
  );
  /*Добавление Территории для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_territory
  (
    par_product_brief     t_product.brief%TYPE
   ,par_prod_line_desc    t_product_line.description%TYPE
   ,par_t_territory_brief t_territory.brief%TYPE DEFAULT 'HW24'
  );
  /*Добавление норм доходности для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Значение нормы доходности, Бриф Валюты
  */
  PROCEDURE add_prod_line_normrate
  (
    par_product_brief   t_product.brief%TYPE
   ,par_prod_line_desc  t_product_line.description%TYPE
   ,par_value_normrate  t_prod_line_norm.value%TYPE
   ,par_normrate_id     normrate.normrate_id%TYPE DEFAULT NULL
   ,par_is_default      BOOLEAN DEFAULT TRUE
   ,par_func_norm_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_note            t_prod_line_norm.note%TYPE DEFAULT NULL
  );
  /*Добавление Справочника смертности для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Бриф Справочника смертности
  */
  PROCEDURE add_prod_line_deathrate
  (
    par_product_brief    t_product.brief%TYPE
   ,par_prod_line_desc   t_product_line.description%TYPE
   ,par_deathrate_brief  deathrate.brief%TYPE
   ,par_func_table_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
  );
  /*Добавление Алгоритма ЗСП для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Бриф ЗСП
  */
  PROCEDURE add_prod_line_met_decl
  (
    par_product_brief        t_product.brief%TYPE
   ,par_prod_line_desc       t_product_line.description%TYPE
   ,par_t_metod_decline_desc t_metod_decline.name%TYPE
   ,par_is_default           BOOLEAN DEFAULT TRUE
  );
  /*Добавление Документов для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_prod_line_documents
  (
    par_product_brief  t_product.brief%TYPE
   ,par_prod_line_desc t_product_line.description%TYPE
   ,par_doc_desc       t_issuer_doc_type.name%TYPE
   ,par_sort_order     t_pline_issuer_doc.sort_order%TYPE DEFAULT NULL
   ,par_is_required    BOOLEAN DEFAULT FALSE
  );
  /*Добавление Родительской программы для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Наименование Родителя
  */
  PROCEDURE add_prod_line_parent
  (
    par_product_brief         t_product.brief%TYPE
   ,par_prod_line_desc        t_product_line.description%TYPE
   ,par_prod_line_parent_desc t_product_line.description%TYPE
   ,par_is_parent_ins_amount  BOOLEAN DEFAULT FALSE
   ,par_amount                parent_prod_line.amount%TYPE DEFAULT NULL
  );
  /*Добавление Конкурирующей программы для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Наименование Конкурента
  */
  PROCEDURE add_prod_line_concurrent
  (
    par_product_brief             t_product.brief%TYPE
   ,par_prod_line_desc            t_product_line.description%TYPE
   ,par_prod_line_concurrent_desc t_product_line.description%TYPE
  );
  /*DEPRACATED*/
  /*
  PROCEDURE ins_prod_line
  (
    pl           IN OUT ven_t_product_line%ROWTYPE
   ,p_product_id ven_t_product.product_id%TYPE
  );

  PROCEDURE ins_prod_line
  (
    p_product_id           ven_t_product.product_id%TYPE
   ,p_description          ven_t_product_line.description%TYPE
   ,p_premium_type         ven_t_product_line.premium_type%TYPE
   ,p_product_line_type_id ven_t_product_line.product_line_type_id%TYPE
   ,p_insurance_group_id   ven_t_product_line.insurance_group_id%TYPE
   ,p_visible_flag         ven_t_product_line.visible_flag%TYPE
   ,p_is_default           ven_t_product_line.is_default%TYPE
   ,p_sort_order           ven_t_product_line.sort_order%TYPE
   ,p_for_premium          ven_t_product_line.for_premium%TYPE
   ,p_id                   ven_t_product_line.id%TYPE DEFAULT NULL
  );
  PROCEDURE upd_prod_line
  (
    p_prod_line_id         ven_t_product_line.id%TYPE
   ,p_description          ven_t_product_line.description%TYPE
   ,p_premium_type         ven_t_product_line.premium_type%TYPE
   ,p_product_line_type_id ven_t_product_line.product_line_type_id%TYPE
   ,p_insurance_group_id   ven_t_product_line.insurance_group_id%TYPE
   ,p_visible_flag         ven_t_product_line.visible_flag%TYPE
   ,p_is_default           ven_t_product_line.is_default%TYPE
   ,p_sort_order           ven_t_product_line.sort_order%TYPE
   ,p_for_premium          ven_t_product_line.for_premium%TYPE
  );
	*/
  --  PROCEDURE del_prod_line(p_prod_line_id ven_t_product_line.id%TYPE);
  FUNCTION gear_branch_ig
  (
    p_insurance_group_id ven_t_insurance_group.t_insurance_group_id%TYPE
   ,p_gear_branch_ig     ven_t_insurance_group.t_insurance_group_id%TYPE
  ) RETURN NUMBER;
  FUNCTION gear_branch_prod
  (
    p_product_id     ven_t_product.product_id%TYPE
   ,p_gear_branch_ig ven_t_insurance_group.t_insurance_group_id%TYPE
  ) RETURN NUMBER;

  PROCEDURE drop_product(p_product_id NUMBER);

  /*
  Капля П.
  Перегрузил функцию copy_product
  */
  PROCEDURE copy_product
  (
    par_src_product_brief t_product.brief%TYPE
   ,par_product_name      t_product.description%TYPE
   ,par_product_brief     t_product.brief%TYPE
  );
  /*
    Байтин А.
    Копирует продукт, в отличии от product_copy, нормально копирует parent риски и concurrent
  */
  PROCEDURE copy_product
  (
    par_product_from_id t_product.product_id%TYPE
   ,par_product_name    t_product.description%TYPE
   ,par_product_brief   t_product.brief%TYPE
  );

  /* Копирует программу из другого продукта
  * @autor - Чирков В. Ю.
  * @param par_product_from_id - продукт с которого копируем
  * @param par_product_to_id   - id продукта в котором создаем копию программы
  * @param par_product_line_id - id копируемой программы у par_product_from_id
  */
  PROCEDURE copy_program_by_product
  (
    par_product_from_id NUMBER
   ,par_product_to_id   NUMBER
   ,par_product_line_id NUMBER
  );

  /* Копирует только продукт без программ
  * @autor - Чирков В. Ю.
  * @param par_product_from_id - продукт с которого копируем
  * @param par_product_name    - имя нового продукта
  * @param par_product_brief   - сокр. наименование нового продукта
  */
  PROCEDURE copy_only_product
  (
    par_product_from_id NUMBER
   ,par_product_name    VARCHAR2
   ,par_product_brief   VARCHAR2
  );

  /*Копирует программу из другого продукта по product_ver_lob_id, что исключает првоерку на соответствие lob_id
  * @author - Капля П.С.
  * @param par_product_from_id - product_ver_lob_id с которого копируем
  * @param par_product_to_id   - product_ver_lob_id продукта в котором создаем копию программы
  * @param par_product_line_id - id копируемой программы у par_product_from_id
  */
  PROCEDURE copy_program_by_prod_ver_lob
  (
    par_product_ver_lob_from_id NUMBER
   ,par_product_ver_lob_to_id   NUMBER
   ,par_product_line_id         NUMBER
  );

  /*
  Капля П.С.
  Инициализация значений по умолчанию для договора по продукту
  Перенесено из PKG_BORLAS_B2B
  */
  FUNCTION get_product_defaults(par_product_brief VARCHAR2) RETURN t_product_defaults;

  /* Перегруженный вариант
  * @autor - Капля П. с.
  * @param par_product_from_brief - бриф продукта с которого копируем
  * @param par_product_to_brief   - брфи продукта в котором создаем копию программы
  * @param par_product_line_name  - название копируемой программы у par_product_from_id
  */
  PROCEDURE copy_program_by_product
  (
    par_product_from_brief VARCHAR2
   ,par_product_to_brief   VARCHAR2
   ,par_product_line_name  VARCHAR2
  );

  /*Удаление Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE del_prod_line
  (
    par_product_brief  VARCHAR2
   ,par_prod_line_desc VARCHAR2
  );
  /*
  Веселуха Е.В. 31.05.2013
  Функция добавляет программу Инвест-резерв в продукт
  Параметр: ИД продукта
  */
  FUNCTION insert_invest_reserve(par_product_id NUMBER) RETURN NUMBER;

  PROCEDURE get_period_by_months_amount
  (
    par_product_id NUMBER
   ,par_start_date DATE
   ,par_months     NUMBER
   ,par_end_date   OUT DATE
   ,par_period_id  OUT NUMBER
  );

  /*
    Капля П.
    Получение ИД скидки для договора по брифу
    Другого места пока нет, но отсюда нужно функцию вынести.
  */
  FUNCTION get_discount_id(par_discount_brief discount_f.brief%TYPE)
    RETURN discount_f.discount_f_id%TYPE;

  /*
    Капля П.
    Пытаемся определить серию БСО по умолчанию для продукта
  */
  FUNCTION get_default_bso_series(par_product_id t_product.product_id%TYPE)
    RETURN bso_series.bso_series_id%TYPE;

END pkg_products;
/
CREATE OR REPLACE PACKAGE BODY pkg_products IS

  gv_product_id    t_product.product_id%TYPE;
  gv_product_brief t_product.brief%TYPE;

  /*Создание пустого продукта и версии продукта
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, Имя продукта
    Остальные параметры по умолчанию
  */
  FUNCTION create_empty_product
  (
    p_product_name               VARCHAR2
   ,p_product_brief              VARCHAR2
   ,p_product_public_name        VARCHAR2
   ,p_policy_form_type_brief     VARCHAR2 DEFAULT 'Жизнь'
   ,p_product_group_brief        VARCHAR2 DEFAULT 'END'
   ,p_enabled                    BOOLEAN DEFAULT TRUE
   ,p_is_group                   BOOLEAN DEFAULT FALSE
   ,p_is_bso_polnum              BOOLEAN DEFAULT TRUE
   ,p_is_express                 BOOLEAN DEFAULT FALSE
   ,p_is_quart                   BOOLEAN DEFAULT FALSE
   ,p_use_ids_as_number          BOOLEAN DEFAULT TRUE
   ,p_version_start_date         DATE DEFAULT trunc(SYSDATE)
   ,p_version_end_date           DATE DEFAULT to_date('31.12.2099', 'DD.MM.YYYY')
   ,p_min_pol_period_in_days     NUMBER DEFAULT 1
   ,p_max_pol_period_in_days     NUMBER DEFAULT 10950
   ,p_min_program_count          NUMBER DEFAULT 1
   ,p_proposal_valid_days        NUMBER DEFAULT 60
   ,p_assured_count_limit        NUMBER DEFAULT 1
   ,p_custom_pol_calc_func_breif t_prod_coef_type.brief%TYPE DEFAULT NULL
  ) RETURN NUMBER IS
    v_sq_product_id         NUMBER;
    v_sq_product_version_id NUMBER;
    v_policy_from_type_id   NUMBER;
    v_product_group_id      NUMBER;
    v_policy_calc_func_id   t_prod_coef_type.t_prod_coef_type_id%TYPE;
    v_enabled               t_product.enabled%TYPE := sys.diutil.bool_to_int(p_enabled);
    v_is_group              t_product.is_group%TYPE := sys.diutil.bool_to_int(p_is_group);
    v_is_bso_polnum         t_product.is_bso_polnum%TYPE := sys.diutil.bool_to_int(p_is_bso_polnum);
    v_is_express            t_product.is_express%TYPE := sys.diutil.bool_to_int(p_is_express);
    v_is_quart              t_product.is_quart%TYPE := sys.diutil.bool_to_int(p_is_quart);
    v_use_ids_as_number     t_product.use_ids_as_number%TYPE := sys.diutil.bool_to_int(p_use_ids_as_number);
  
  BEGIN
    SELECT ft.t_policy_form_type_id
      INTO v_policy_from_type_id
      FROM ins.t_policy_form_type ft
     WHERE ft.brief = p_policy_form_type_brief;
  
    SELECT pg.t_product_group_id
      INTO v_product_group_id
      FROM ins.t_product_group pg
     WHERE pg.brief = p_product_group_brief;
  
    IF p_custom_pol_calc_func_breif IS NOT NULL
    THEN
      v_policy_calc_func_id := dml_t_prod_coef_type.get_id_by_brief(par_brief => p_custom_pol_calc_func_breif);
    END IF;
  
    /*Создание Продукта*/
    SELECT sq_t_product.nextval INTO v_sq_product_id FROM dual;
    INSERT INTO ins.ven_t_product
      (description
      ,brief
      ,t_policy_form_type_id
      ,enabled
      ,is_group
      ,is_bso_polnum
      ,is_express
      ,is_quart
      ,use_ids_as_number
      ,t_product_group_id
      ,product_id
      ,custom_policy_calc_func_id
      ,public_description)
    VALUES
      (p_product_name
      ,p_product_brief
      ,v_policy_from_type_id
      ,v_enabled
      ,v_is_group
      ,v_is_bso_polnum
      ,v_is_express
      ,v_is_quart
      ,v_use_ids_as_number
      ,v_product_group_id
      ,v_sq_product_id
      ,v_policy_calc_func_id
      ,nvl(p_product_public_name, p_product_name));
    /*Создание Версии Продукта*/
    SELECT sq_t_product_version.nextval INTO v_sq_product_version_id FROM dual;
    INSERT INTO ins.ven_t_product_version
      (max_policy_period
      ,min_policy_period
      ,min_package_number
      ,proposal_valid_days
      ,start_date
      ,end_date
      ,version_nr
      ,version_status
      ,product_id
      ,t_product_version_id
      ,assured_count_limit)
    VALUES
      (p_max_pol_period_in_days
      ,p_min_pol_period_in_days
      ,p_min_program_count
      ,p_proposal_valid_days
      ,p_version_start_date
      ,p_version_end_date
      ,1
      ,1
      ,v_sq_product_id
      ,v_sq_product_version_id
      ,p_assured_count_limit);
  
    RETURN v_sq_product_id;
  
  END create_empty_product;

  /*Добавление DEFAULT продукта
    Капля П.С.
    17.06.2013
  */
  PROCEDURE create_default_product
  (
    par_product_name              VARCHAR2
   ,par_product_brief             VARCHAR2
   ,par_product_public_name       VARCHAR2
   ,par_bso_type_brief            VARCHAR2 DEFAULT NULL
   ,par_sales_channel_brief       VARCHAR2 DEFAULT NULL
   ,par_policy_form_desc          VARCHAR2 DEFAULT NULL
   ,par_policy_form_start_date    DATE DEFAULT trunc(SYSDATE)
   ,par_product_group_brief       VARCHAR2 DEFAULT 'END'
   ,par_enabled                   BOOLEAN DEFAULT TRUE
   ,par_is_group                  BOOLEAN DEFAULT FALSE
   ,par_is_bso_polnum             BOOLEAN DEFAULT TRUE
   ,par_is_express                BOOLEAN DEFAULT FALSE
   ,par_is_quart                  BOOLEAN DEFAULT FALSE
   ,par_use_ids_as_number         BOOLEAN DEFAULT TRUE
   ,par_version_start_date        DATE DEFAULT trunc(SYSDATE)
   ,par_version_end_date          DATE DEFAULT to_date('31.12.2099', 'DD.MM.YYYY')
   ,par_min_pol_period_in_days    NUMBER DEFAULT 1
   ,par_max_pol_period_in_days    NUMBER DEFAULT 10950
   ,par_assured_count_limit       NUMBER DEFAULT 1
   ,par_min_program_count         NUMBER DEFAULT 1
   ,par_proposal_valid_days       NUMBER DEFAULT 60
   ,par_t_confirm_condition_desc  VARCHAR2 DEFAULT 'С момента поступления первого взноса'
   ,par_ins_t_period_desc         VARCHAR2 DEFAULT '1 Год'
   ,par_wait_t_period_desc        VARCHAR2 DEFAULT 'Нет'
   ,par_grace_t_period_desc       VARCHAR2 DEFAULT 'Нет'
   ,par_currency_brief            VARCHAR2 DEFAULT 'RUR'
   ,par_payoff_currency_brief     VARCHAR2 DEFAULT 'RUR'
   ,par_payment_terms_brief       VARCHAR2 DEFAULT 'Единовременно'
   ,par_paym_coll_method_brief    VARCHAR2 DEFAULT 'Безналичный расчет'
   ,par_claim_payment_terms_brief VARCHAR2 DEFAULT 'Единовременно'
   ,par_claim_coll_method_brief   VARCHAR2 DEFAULT 'Безналичный расчет'
   ,par_contact_type              VARCHAR2 DEFAULT 'ФЛ'
   ,par_discount_brief            VARCHAR DEFAULT 'База'
   ,par_cust_pol_calc_func_breif  VARCHAR2 DEFAULT NULL
  ) IS
    v_product_id NUMBER;
  BEGIN
    v_product_id := pkg_products.create_empty_product(p_product_name               => par_product_name
                                                     ,p_product_brief              => par_product_brief
                                                     ,p_product_public_name        => par_product_public_name
                                                     ,p_product_group_brief        => par_product_group_brief
                                                     ,p_enabled                    => par_enabled
                                                     ,p_is_group                   => par_is_group
                                                     ,p_is_bso_polnum              => par_is_bso_polnum
                                                     ,p_is_express                 => par_is_express
                                                     ,p_is_quart                   => par_is_quart
                                                     ,p_use_ids_as_number          => par_use_ids_as_number
                                                     ,p_version_start_date         => par_version_start_date
                                                     ,p_version_end_date           => par_version_end_date
                                                     ,p_min_pol_period_in_days     => par_min_pol_period_in_days
                                                     ,p_max_pol_period_in_days     => par_max_pol_period_in_days
                                                     ,p_min_program_count          => par_min_program_count
                                                     ,p_proposal_valid_days        => par_proposal_valid_days
                                                     ,p_assured_count_limit        => par_assured_count_limit
                                                     ,p_custom_pol_calc_func_breif => par_cust_pol_calc_func_breif);
  
    IF par_sales_channel_brief IS NOT NULL
    THEN
      pkg_products.add_product_sales_chnl(par_product_brief    => par_product_brief
                                         ,par_sales_chnl_brief => par_sales_channel_brief);
    END IF;
  
    IF par_bso_type_brief IS NOT NULL
    THEN
      pkg_products.add_product_bso_type(par_product_brief  => par_product_brief
                                       ,par_bso_type_brief => par_bso_type_brief);
    END IF;
  
    IF par_policy_form_desc IS NOT NULL
    THEN
      pkg_products.add_product_policy_form(par_product_brief    => par_product_brief
                                          ,par_policy_form_desc => par_policy_form_desc
                                          ,par_start_date       => nvl(par_policy_form_start_date
                                                                      ,par_version_start_date));
    END IF;
  
    pkg_products.add_product_confirm_condition(par_product_brief          => par_product_brief
                                              ,par_confirm_condition_desc => par_t_confirm_condition_desc);
  
    pkg_products.add_product_period(par_product_brief     => par_product_brief
                                   ,par_period_desc       => par_ins_t_period_desc
                                   ,par_period_type_brief => 'Срок страхования');
  
    pkg_products.add_product_period(par_product_brief     => par_product_brief
                                   ,par_period_desc       => par_wait_t_period_desc
                                   ,par_period_type_brief => 'Выжидательный');
  
    pkg_products.add_product_period(par_product_brief     => par_product_brief
                                   ,par_period_desc       => par_grace_t_period_desc
                                   ,par_period_type_brief => 'Льготный');
  
    pkg_products.add_product_currency(par_product_brief  => par_product_brief
                                     ,par_currency_brief => par_currency_brief);
  
    pkg_products.add_product_pay_currency(par_product_brief  => par_product_brief
                                         ,par_currency_brief => par_payoff_currency_brief);
  
    pkg_products.add_product_type_contact(par_product_brief => par_product_brief
                                         ,par_type_brief    => par_contact_type);
  
    pkg_products.add_product_period_pay(par_product_brief     => par_product_brief
                                       ,par_payment_brief     => par_payment_terms_brief
                                       ,par_coll_method_brief => par_paym_coll_method_brief);
  
    pkg_products.add_product_period_payoff(par_product_brief     => par_product_brief
                                          ,par_payment_brief     => par_claim_payment_terms_brief
                                          ,par_coll_method_brief => par_claim_coll_method_brief);
  
    pkg_products.add_product_documents_all(par_product_brief => par_product_brief);
  
    pkg_products.add_product_discount(par_product_brief  => par_product_brief
                                     ,par_discount_brief => par_discount_brief);
  
    pkg_products.add_product_external_system(par_product_brief         => par_product_brief
                                            ,par_external_system_brief => 'BORLAS');
  
  END create_default_product;

  /*Поиск ИД продукта по Брифу Продукта
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта
  */
  FUNCTION get_product_id(par_product_brief VARCHAR2) RETURN NUMBER IS
    v_product dml_t_product.tt_t_product;
  BEGIN
  
    v_product := dml_t_product.get_rec_by_brief(par_product_brief);
  
    gv_product_id    := v_product.product_id;
    gv_product_brief := v_product.brief;
  
    RETURN gv_product_id;
  
  END get_product_id;

  /*Поиск ИД типа доп соглашения по Брифу
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф типа доп соглашения
  */
  FUNCTION get_addendum_type_id(par_addendum_brief VARCHAR2) RETURN NUMBER IS
    v_addendum_type_id NUMBER;
  BEGIN
    v_addendum_type_id := dml_t_addendum_type.get_id_by_brief(par_addendum_brief);
  
    RETURN v_addendum_type_id;
  
  END get_addendum_type_id;

  /*Поиск ИД Страховой программы по Брифу Страховой программы
    Веселуха Е.В.
    17.06.2013
    Параметры обязательные: Бриф Страховой программы
  */
  PROCEDURE get_lob_line_id
  (
    par_lob_line_brief VARCHAR2
   ,par_lob_line_desc  OUT VARCHAR2
   ,par_lob_line_id    OUT NUMBER
  ) IS
  BEGIN
  
    BEGIN
      SELECT lb.t_lob_line_id
            ,lb.description
        INTO par_lob_line_id
            ,par_lob_line_desc
        FROM ins.t_lob_line lb
       WHERE lb.brief = par_lob_line_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена Страховая программа по указанному Брифу.');
      WHEN too_many_rows THEN
        raise_application_error(-20002
                               ,'В БД существует слишком много Страховых программ с указанным Брифом.');
    END;
  
  END get_lob_line_id;

  FUNCTION get_product_addendum
  (
    par_product_brief       t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
  ) RETURN t_product_addendum.t_product_addendum_id%TYPE IS
    v_product_id          t_product.product_id%TYPE;
    v_addendum_type_id    t_addendum_type.t_addendum_type_id%TYPE;
    v_product_addendum_id t_product_addendum.t_product_addendum_id%TYPE;
  BEGIN
    v_product_id          := get_product_id(par_product_brief);
    v_addendum_type_id    := get_addendum_type_id(par_addendum_type_brief);
    v_product_addendum_id := dml_t_product_addendum.id_by_t_prod_id_t_adde_type_id(par_t_product_id       => v_product_id
                                                                                  ,par_t_addendum_type_id => v_addendum_type_id);
  
    RETURN v_product_addendum_id;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не удалось определить доп соглашение в продукте по брифам');
  END get_product_addendum;

  FUNCTION get_product_line_id
  (
    par_product_brief     VARCHAR2
   ,par_product_line_desc VARCHAR2
  ) RETURN NUMBER IS
    v_prod_line_id NUMBER;
  BEGIN
    SELECT pl.id
      INTO v_prod_line_id
      FROM t_product         p
          ,t_product_version pv
          ,t_product_ver_lob pvl
          ,t_product_line    pl
     WHERE p.brief = par_product_brief
       AND p.product_id = pv.product_id
       AND pv.t_product_version_id = pvl.product_version_id
       AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
       AND pl.description = par_product_line_desc;
    RETURN v_prod_line_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, 'Не найдена программа в продукте');
    WHEN too_many_rows THEN
      raise_application_error(-20002
                             ,'Найдено несколько программ в данном продукте');
  END get_product_line_id;

  /*Добавление кураторов по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, ИД персоны
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_curators
  (
    par_product_brief        t_product.brief%TYPE
   ,par_employee_id          NUMBER
   ,par_organization_tree_id NUMBER DEFAULT NULL
   ,par_department_id        NUMBER DEFAULT NULL
   ,par_is_default           BOOLEAN DEFAULT TRUE
  ) IS
    no_employee EXCEPTION;
    vr_product_curator dml_t_product_curator.tt_t_product_curator;
    v_is_employee      NUMBER;
  BEGIN
  
    vr_product_curator.t_product_id := get_product_id(par_product_brief);
    vr_product_curator.is_default   := sys.diutil.bool_to_int(par_is_default);
    vr_product_curator.employee_id  := par_employee_id;
  
    SELECT COUNT(*)
      INTO v_is_employee
      FROM ins.employee e
     WHERE e.employee_id = vr_product_curator.employee_id;
  
    IF v_is_employee = 0
    THEN
      RAISE no_employee;
    ELSE
      BEGIN
        SELECT h.department_id
              ,e.organisation_id
          INTO vr_product_curator.department_id
              ,vr_product_curator.organisation_tree_id
          FROM ins.employee      e
              ,ins.employee_hist h
         WHERE e.employee_id = h.employee_id
           AND e.employee_id = vr_product_curator.employee_id
           AND h.is_kicked = 0;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'По указанному ИД персоны не найдены параметры: Дерево, Подразделение.');
        WHEN too_many_rows THEN
          IF par_department_id IS NOT NULL
          THEN
            BEGIN
              SELECT h.department_id
                    ,e.organisation_id
                INTO vr_product_curator.department_id
                    ,vr_product_curator.organisation_tree_id
                FROM ins.employee      e
                    ,ins.employee_hist h
               WHERE e.employee_id = h.employee_id
                 AND e.employee_id = vr_product_curator.employee_id
                 AND h.department_id = par_department_id
                 AND h.is_kicked = 0;
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20001
                                       ,'По указанному ИД персоны не найдены параметры: Дерево');
              WHEN too_many_rows THEN
                raise_application_error(-20001
                                       ,'Найдено слишком много записей.');
            END;
          END IF;
      END;
    END IF;
  
    IF par_is_default
    THEN
      UPDATE ins.ven_t_product_curator c
         SET c.is_default = 0
       WHERE c.t_product_id = vr_product_curator.t_product_id;
    END IF;
  
    dml_t_product_curator.insert_record(par_record => vr_product_curator);
  
  EXCEPTION
    WHEN no_employee THEN
      raise_application_error(-20003
                             ,'По указанному ИД персоны не найден сотрудник в Персонале организации.');
  END add_product_curators;

  /*Добавление Условий вступления в силу по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_confirm_condition
  (
    par_product_brief          t_product.brief%TYPE
   ,par_confirm_condition_desc t_confirm_condition.description%TYPE DEFAULT 'С момента поступления первого взноса'
   ,par_is_default             BOOLEAN DEFAULT TRUE
  ) IS
    v_product_id             NUMBER;
    v_confirm_condition_id   NUMBER;
    v_t_product_conf_cond_id NUMBER;
    vr_product_conf_cond     dml_t_product_conf_cond.tt_t_product_conf_cond;
  BEGIN
  
    vr_product_conf_cond.product_id           := get_product_id(par_product_brief);
    vr_product_conf_cond.confirm_condition_id := dml_t_confirm_condition.get_id_by_description(par_confirm_condition_desc);
    vr_product_conf_cond.is_default           := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE ins.ven_t_product_conf_cond cc
         SET cc.is_default = 0
       WHERE cc.product_id = vr_product_conf_cond.product_id;
    END IF;
  
    dml_t_product_conf_cond.insert_record(par_record => vr_product_conf_cond);
  
  END add_product_confirm_condition;

  /*Добавление Периодов по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, Значение периода
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_period
  (
    par_product_brief      t_product.brief%TYPE
   ,par_period_desc        t_period.description%TYPE
   ,par_period_type_brief  t_period_use_type.brief%TYPE DEFAULT 'Срок страхования'
   ,par_sort_order         t_product_period.sort_order%TYPE DEFAULT NULL
   ,par_is_default         BOOLEAN DEFAULT TRUE
   ,par_control_func_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
  ) IS
    vr_product_period dml_t_product_period.tt_t_product_period;
  BEGIN
  
    vr_product_period.product_id           := get_product_id(par_product_brief);
    vr_product_period.period_id            := dml_t_period.get_id_by_description(par_period_desc);
    vr_product_period.t_period_use_type_id := dml_t_period_use_type.get_id_by_brief(par_period_type_brief);
    vr_product_period.is_default           := sys.diutil.bool_to_int(par_is_default);
  
    IF par_control_func_brief IS NOT NULL
    THEN
      vr_product_period.control_func_id := dml_t_prod_coef_type.get_id_by_brief(par_control_func_brief);
    END IF;
  
    IF par_sort_order IS NOT NULL
    THEN
      vr_product_period.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(pp.sort_order), 0) + 5
        INTO vr_product_period.sort_order
        FROM t_product_period pp
       WHERE pp.product_id = vr_product_period.product_id;
    END IF;
  
    IF par_is_default
    THEN
      UPDATE t_product_period t
         SET t.is_default = 0
       WHERE t.product_id = vr_product_period.product_id
         AND t.t_period_use_type_id = vr_product_period.t_period_use_type_id;
    END IF;
  
    dml_t_product_period.insert_record(par_record => vr_product_period);
  
  END add_product_period;

  /*Добавление Валюты ответственности по продукту
    Веселуха Е.В.
    11.06.2013
    Параметры обязательные: Бриф продукта, Бриф валюты
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_currency
  (
    par_product_brief  t_product.brief%TYPE
   ,par_currency_brief fund.brief%TYPE DEFAULT 'RUR'
   ,par_is_default     BOOLEAN DEFAULT TRUE
  ) IS
    vr_prod_currency dml_t_prod_currency.tt_t_prod_currency;
  BEGIN
  
    vr_prod_currency.product_id  := get_product_id(par_product_brief);
    vr_prod_currency.currency_id := dml_fund.get_id_by_brief(par_currency_brief);
    vr_prod_currency.is_default  := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE t_prod_currency SET is_default = 0 WHERE product_id = vr_prod_currency.product_id;
    END IF;
  
    dml_t_prod_currency.insert_record(vr_prod_currency);
  
  END add_product_currency;

  /*Добавление Валюты платежа по продукту
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф валюты
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_pay_currency
  (
    par_product_brief  t_product.brief%TYPE
   ,par_currency_brief fund.brief%TYPE DEFAULT 'RUR'
   ,par_is_default     BOOLEAN DEFAULT TRUE
  ) IS
    vr_prod_pay_curr dml_t_prod_pay_curr.tt_t_prod_pay_curr;
  BEGIN
  
    vr_prod_pay_curr.product_id  := get_product_id(par_product_brief);
    vr_prod_pay_curr.currency_id := dml_fund.get_id_by_brief(par_currency_brief);
    vr_prod_pay_curr.is_default  := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE t_prod_pay_curr SET is_default = 0 WHERE product_id = vr_prod_pay_curr.product_id;
    END IF;
  
    dml_t_prod_pay_curr.insert_record(vr_prod_pay_curr);
  
  END add_product_pay_currency;

  /*Добавление Тип контакта для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_type_contact
  (
    par_product_brief t_product.brief%TYPE
   ,par_type_brief    t_contact_type.brief%TYPE DEFAULT 'ФЛ'
  ) IS
    vr_product_cont_type dml_t_product_cont_type.tt_t_product_cont_type;
  BEGIN
  
    vr_product_cont_type.product_id := get_product_id(par_product_brief);
  
    BEGIN
      SELECT tct.id
        INTO vr_product_cont_type.contact_type_id
        FROM t_contact_type tct
       WHERE tct.brief = par_type_brief
         AND tct.id = (SELECT MAX(tt.id) FROM ins.t_contact_type tt WHERE tt.brief = tct.brief);
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден Тип контакта для указанного Брифа.');
    END;
  
    dml_t_product_cont_type.insert_record(par_record => vr_product_cont_type);
  END;

  /*Добавление Канала продаж для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_sales_chnl
  (
    par_product_brief    t_product.brief%TYPE
   ,par_sales_chnl_brief t_sales_channel.brief%TYPE DEFAULT 'MLM'
   ,par_is_default       BOOLEAN DEFAULT TRUE
  ) IS
    vr_prod_sales_chan dml_t_prod_sales_chan.tt_t_prod_sales_chan;
  BEGIN
    vr_prod_sales_chan.product_id       := get_product_id(par_product_brief);
    vr_prod_sales_chan.sales_channel_id := dml_t_sales_channel.get_id_by_brief(par_sales_chnl_brief);
    vr_prod_sales_chan.is_default       := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE t_prod_sales_chan psc
         SET psc.is_default = 0
       WHERE psc.product_id = vr_prod_sales_chan.product_id;
    END IF;
  
    dml_t_prod_sales_chan.insert_record(par_record => vr_prod_sales_chan);
  
  END add_product_sales_chnl;

  /*Добавление Типа премии и Способа оплаты для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф типа премии
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_period_pay
  (
    par_product_brief     t_product.brief%TYPE
   ,par_payment_brief     t_payment_terms.brief%TYPE
   ,par_coll_method_brief t_collection_method.brief%TYPE DEFAULT 'Безналичный расчет'
   ,par_is_default        BOOLEAN DEFAULT TRUE
  ) IS
    vr_prod_payment_terms dml_t_prod_payment_terms.tt_t_prod_payment_terms;
  BEGIN
    vr_prod_payment_terms.product_id           := get_product_id(par_product_brief);
    vr_prod_payment_terms.payment_term_id      := dml_t_payment_terms.get_id_by_brief(par_payment_brief);
    vr_prod_payment_terms.is_default           := sys.diutil.bool_to_int(par_is_default);
    vr_prod_payment_terms.collection_method_id := dml_t_collection_method.get_id_by_brief(par_coll_method_brief);
  
    IF par_is_default
    THEN
      UPDATE ins.t_prod_payment_terms tr
         SET tr.is_default = 0
       WHERE tr.product_id = vr_prod_payment_terms.product_id;
    END IF;
  
    dml_t_prod_payment_terms.insert_record(vr_prod_payment_terms);
  
  END add_product_period_pay;
  /*Добавление Типа премии и Способа выплаты для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф выплаты
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_period_payoff
  (
    par_product_brief     t_product.brief%TYPE
   ,par_payment_brief     t_payment_terms.brief%TYPE
   ,par_coll_method_brief t_collection_method.brief%TYPE DEFAULT 'Безналичный расчет'
   ,par_is_default        BOOLEAN DEFAULT TRUE
  ) IS
    vr_prod_claim_payterm dml_t_prod_claim_payterm.tt_t_prod_claim_payterm;
  BEGIN
  
    vr_prod_claim_payterm.product_id           := get_product_id(par_product_brief);
    vr_prod_claim_payterm.payment_terms_id     := dml_t_payment_terms.get_id_by_brief(par_payment_brief);
    vr_prod_claim_payterm.is_default           := sys.diutil.bool_to_int(par_is_default);
    vr_prod_claim_payterm.collection_method_id := dml_t_collection_method.get_id_by_brief(par_coll_method_brief);
  
    IF par_is_default
    THEN
      UPDATE t_prod_claim_payterm tr
         SET tr.is_default = 0
       WHERE tr.product_id = vr_prod_claim_payterm.product_id;
    END IF;
  
    dml_t_prod_claim_payterm.insert_record(vr_prod_claim_payterm);
  
  END add_product_period_payoff;

  /*Добавление Документов для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_documents
  (
    par_product_brief        t_product.brief%TYPE
   ,par_issuer_doc_type_name t_issuer_doc_type.name%TYPE
   ,par_sort_order           t_prod_issuer_doc.sort_order%TYPE DEFAULT NULL
   ,par_is_required          BOOLEAN DEFAULT FALSE
  ) IS
    vr_prod_issuer_doc dml_t_prod_issuer_doc.tt_t_prod_issuer_doc;
  BEGIN
    vr_prod_issuer_doc.t_product_id         := get_product_id(par_product_brief);
    vr_prod_issuer_doc.t_issuer_doc_type_id := dml_t_issuer_doc_type.get_id_by_name(par_issuer_doc_type_name);
    vr_prod_issuer_doc.is_required          := sys.diutil.bool_to_int(par_is_required);
  
    IF par_sort_order IS NOT NULL
    THEN
      SELECT nvl(MAX(id.sort_order), 0) + 5
        INTO vr_prod_issuer_doc.sort_order
        FROM ins.t_prod_issuer_doc id
       WHERE id.t_product_id = vr_prod_issuer_doc.t_product_id;
    ELSE
      vr_prod_issuer_doc.sort_order := par_sort_order;
    END IF;
  
    dml_t_prod_issuer_doc.insert_record(par_record => vr_prod_issuer_doc);
  
  END add_product_documents;

  /*Добавление Всех доступных документов для продукта
    Капля П.С.
    21.06.2014
    Параметры обязательные: Бриф продукта
  */
  PROCEDURE add_product_documents_all(par_product_brief t_product.brief%TYPE) IS
  BEGIN
    FOR rec IN (SELECT t.name FROM ins.t_issuer_doc_type t)
    LOOP
      add_product_documents(par_product_brief        => par_product_brief
                           ,par_issuer_doc_type_name => rec.name);
    END LOOP;
  END add_product_documents_all;

  /*Добавление Доп соглашений для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф доп соглашения
    Остальные параметры по умолчанию
  */
  FUNCTION add_product_addendum
  (
    par_product_brief       t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
   ,par_type_change_brief   t_policy_change_type.brief%TYPE DEFAULT NULL
  ) RETURN NUMBER IS
    vr_product_addendum dml_t_product_addendum.tt_t_product_addendum;
  BEGIN
    vr_product_addendum.t_product_id       := get_product_id(par_product_brief);
    vr_product_addendum.t_addendum_type_id := get_addendum_type_id(par_addendum_type_brief);
  
    IF par_type_change_brief IS NOT NULL
    THEN
      vr_product_addendum.t_policy_change_type_id := dml_t_policy_change_type.get_id_by_brief(par_type_change_brief);
    END IF;
  
    dml_t_product_addendum.insert_record(vr_product_addendum);
  
    RETURN vr_product_addendum.t_product_addendum_id;
  
  END add_product_addendum;

  /*Добавление Функций в Доп соглашения для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф доп соглашения, Бриф функции
    Остальные параметры по умолчанию
  */
  FUNCTION add_product_addendum_func
  (
    par_product_brief       t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
   ,par_func_brief          t_prod_coef_type.brief%TYPE
   ,par_sort_order          t_product_add_func.sort_order%TYPE DEFAULT NULL
   ,par_comments            t_product_add_func.comments%TYPE DEFAULT NULL
  ) RETURN NUMBER IS
    vr_t_product_add_func dml_t_product_add_func.tt_t_product_add_func;
  BEGIN
  
    vr_t_product_add_func.t_product_id := get_product_id(par_product_brief);
  
    SELECT pa.t_product_addendum_id
      INTO vr_t_product_add_func.t_product_addendum_id
      FROM t_product_addendum pa
     WHERE pa.t_product_id = vr_t_product_add_func.t_product_id
       AND pa.t_addendum_type_id = get_addendum_type_id(par_addendum_type_brief);
  
    vr_t_product_add_func.func_id  := dml_t_prod_coef_type.get_id_by_brief(par_func_brief);
    vr_t_product_add_func.comments := par_comments;
  
    IF par_sort_order IS NOT NULL
    THEN
      vr_t_product_add_func.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(fd.sort_order), 0) + 5
        INTO vr_t_product_add_func.sort_order
        FROM ins.t_product_add_func fd
       WHERE fd.t_product_addendum_id = vr_t_product_add_func.t_product_addendum_id;
    END IF;
  
    dml_t_product_add_func.insert_record(vr_t_product_add_func);
  
    RETURN vr_t_product_add_func.t_product_add_func_id;
  
  END add_product_addendum_func;

  /*
    Капля П.
    Процедура добавления связи продукта со скидкой
  */
  PROCEDURE add_product_discount
  (
    par_product_brief  t_product.brief%TYPE
   ,par_discount_brief discount_f.brief%TYPE
   ,par_is_default     BOOLEAN DEFAULT FALSE
   ,par_is_active      BOOLEAN DEFAULT TRUE
   ,par_sort_order     t_product_discount.sort_order%TYPE DEFAULT NULL
  ) IS
    v_product_discount dml_t_product_discount.tt_t_product_discount;
  BEGIN
  
    assert_deprecated(par_product_brief IS NULL
          ,'Бриф продукта не должен быть пустым');
    assert_deprecated(par_discount_brief IS NULL
          ,'Бриф скидки не должен быть пустым');
  
    v_product_discount.product_id  := get_product_id(par_product_brief => par_product_brief);
    v_product_discount.discount_id := get_discount_id(par_discount_brief => par_discount_brief);
    v_product_discount.is_active   := sys.diutil.bool_to_int(par_is_active);
    v_product_discount.is_default  := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE t_product_discount t
         SET t.is_default = 0
       WHERE t.product_id = v_product_discount.product_id
         AND t.is_default = 1;
    END IF;
  
    IF par_sort_order IS NULL
    THEN
      SELECT nvl(MAX(nvl(sort_order, 0)), 0) + 10
        INTO v_product_discount.sort_order
        FROM t_product_discount t
       WHERE t.product_id = v_product_discount.product_id;
    ELSE
      v_product_discount.sort_order := par_sort_order;
    END IF;
  
    dml_t_product_discount.insert_record(par_record => v_product_discount);
  
  END add_product_discount;

  PROCEDURE add_product_external_system
  (
    par_product_brief         VARCHAR2
   ,par_external_system_brief VARCHAR2
  ) IS
    v_product_id         NUMBER := get_product_id(par_product_brief);
    v_external_system_id NUMBER;
    v_product_ext_system dml_t_product_ext_system.tt_t_product_ext_system;
  BEGIN
    assert_deprecated(par_product_brief IS NULL
          ,'Бриф продукта не может быть пустым');
    assert_deprecated(par_external_system_brief IS NULL
          ,'Бриф внешней системы не может быть пустым');
  
    v_product_ext_system.product_id           := get_product_id(par_product_brief);
    v_product_ext_system.t_external_system_id := dml_t_external_system.get_id_by_brief(par_external_system_brief);
  
    dml_t_product_ext_system.insert_record(par_record => v_product_ext_system);
  
  END add_product_external_system;

  PROCEDURE copy_product_addendum_funcs
  (
    par_src_product_brief        t_product.brief%TYPE
   ,par_src_addendum_type_brief  t_addendum_type.brief%TYPE
   ,par_dest_product_brief       t_product.brief%TYPE
   ,par_dest_addendum_type_brief t_addendum_type.brief%TYPE
  ) IS
    v_src_product_addendum_id  t_product_addendum.t_product_addendum_id%TYPE;
    v_dest_product_addendum_id t_product_addendum.t_product_addendum_id%TYPE;
  BEGIN
    v_src_product_addendum_id := get_product_addendum(par_product_brief       => par_src_product_brief
                                                     ,par_addendum_type_brief => par_src_addendum_type_brief);
  
    v_dest_product_addendum_id := get_product_addendum(par_product_brief       => par_dest_product_brief
                                                      ,par_addendum_type_brief => par_dest_addendum_type_brief);
  
    copy_product_addendum_funcs(par_src_product_addendum_id  => v_src_product_addendum_id
                               ,par_dest_product_addendum_id => v_dest_product_addendum_id);
  END copy_product_addendum_funcs;

  PROCEDURE copy_product_addendum_funcs
  (
    par_src_product_addendum_id  t_product_addendum.t_product_addendum_id%TYPE
   ,par_dest_product_addendum_id t_product_addendum.t_product_addendum_id%TYPE
  ) IS
    v_product_addendum dml_t_product_addendum.tt_t_product_addendum;
  BEGIN
    v_product_addendum := dml_t_product_addendum.get_record(par_dest_product_addendum_id);
    INSERT INTO ins.t_product_add_func
      (t_product_add_func_id, comments, func_id, sort_order, t_product_addendum_id, t_product_id)
      SELECT sq_t_product_add_func.nextval
            ,comments
            ,func_id
            ,sort_order
            ,v_product_addendum.t_product_addendum_id --t_product_addendum_id
            ,v_product_addendum.t_product_id --t_product_id
        FROM t_product_add_func t
       WHERE t.t_product_addendum_id = par_src_product_addendum_id;
  END copy_product_addendum_funcs;

  PROCEDURE copy_addendum_type
  (
    par_dest_product_id  NUMBER
   ,par_addendum_type_id NUMBER
   ,par_src_product_id   NUMBER
  ) IS
    v_src_product_addendum  dml_t_product_addendum.tt_t_product_addendum;
    v_dest_product_addendum dml_t_product_addendum.tt_t_product_addendum;
  BEGIN
    v_src_product_addendum := dml_t_product_addendum.rec_by_t_pro_id_t_adde_type_id(par_src_product_id
                                                                                   ,par_addendum_type_id);
  
    v_dest_product_addendum              := v_src_product_addendum;
    v_dest_product_addendum.t_product_id := par_dest_product_id;
  
    dml_t_product_addendum.insert_record(par_record => v_dest_product_addendum);
  
    copy_product_addendum_funcs(par_src_product_addendum_id  => v_src_product_addendum.t_product_addendum_id
                               ,par_dest_product_addendum_id => v_dest_product_addendum.t_product_addendum_id);
  
  END;

  PROCEDURE copy_addendum_type
  (
    par_dest_product_brief  t_product.brief%TYPE
   ,par_addendum_type_brief t_addendum_type.brief%TYPE
   ,par_src_product_brief   t_product.brief%TYPE
  ) IS
  BEGIN
  
    copy_addendum_type(par_dest_product_id  => get_product_id(par_dest_product_brief)
                      ,par_addendum_type_id => get_addendum_type_id(par_addendum_type_brief)
                      ,par_src_product_id   => get_product_id(par_src_product_brief));
  
  END copy_addendum_type;

  /*Добавление Порядка выплаты для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_product_pay_order
  (
    par_product_brief   t_product.brief%TYPE
   ,par_pay_order_brief t_payment_order.brief%TYPE
   ,par_is_default      BOOLEAN DEFAULT FALSE
  ) IS
    v_prod_payment_order dml_t_prod_payment_order.tt_t_prod_payment_order;
  BEGIN
    v_prod_payment_order.t_product_id       := ins.pkg_products.get_product_id(par_product_brief);
    v_prod_payment_order.t_payment_order_id := dml_t_payment_order.get_id_by_brief(par_pay_order_brief);
    v_prod_payment_order.is_default         := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE ins.t_prod_payment_order op
         SET op.is_default = 0
       WHERE op.t_product_id = v_prod_payment_order.t_product_id
         AND op.is_default = 1;
    END IF;
  
    dml_t_prod_payment_order.insert_record(par_record => v_prod_payment_order);
  
  END add_product_pay_order;

  /*Добавление Типа БСО для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф типа БСО
  */
  PROCEDURE add_product_bso_type
  (
    par_product_brief  t_product.brief%TYPE
   ,par_bso_type_brief bso_type.brief%TYPE
  ) IS
    v_product_bso_types dml_t_product_bso_types.tt_t_product_bso_types;
  BEGIN
    v_product_bso_types.t_product_id := ins.pkg_products.get_product_id(par_product_brief);
    v_product_bso_types.bso_type_id  := dml_bso_type.get_id_by_brief(par_bso_type_brief);
  
    dml_t_product_bso_types.insert_record(par_record => v_product_bso_types);
  
  END add_product_bso_type;

  /*Добавление Типа Расторжения для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф типа расторжения
  */
  PROCEDURE add_product_decline_type
  (
    par_product_brief        t_product.brief%TYPE
   ,par_decline_reason_brief t_decline_reason.brief%TYPE
  ) IS
    vr_product_decline dml_t_product_decline.tt_t_product_decline;
  BEGIN
    vr_product_decline.t_product_id        := get_product_id(par_product_brief);
    vr_product_decline.t_decline_reason_id := dml_t_decline_reason.get_id_by_brief(par_decline_reason_brief);
  
    dml_t_product_decline.insert_record(par_record => vr_product_decline);
  
  END add_product_decline_type;

  /*Добавление Типа Территории для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта
  */
  PROCEDURE add_product_territory
  (
    par_product_brief   t_product.brief%TYPE
   ,par_territory_brief t_territory.brief%TYPE DEFAULT 'HW24'
  ) IS
    v_product_ter dml_t_product_ter.tt_t_product_ter;
  BEGIN
    v_product_ter.product_id     := get_product_id(par_product_brief);
    v_product_ter.t_territory_id := dml_t_territory.get_id_by_brief(par_territory_brief);
  
    dml_t_product_ter.insert_record(par_record => v_product_ter);
  
  END add_product_territory;

  /*Добавление Типа Полисных условий для продукта
    Веселуха Е.В.
    13.06.2013
    Параметры обязательные: Бриф продукта, Бриф Полисных условий
  */
  PROCEDURE add_product_policy_form
  (
    par_product_brief    t_product.brief%TYPE
   ,par_policy_form_desc t_policy_form.t_policy_form_name%TYPE
   ,par_start_date       DATE
   ,par_end_date         DATE DEFAULT to_date('31.12.2999', 'DD.MM.YYYY')
  ) IS
    form_exists EXCEPTION;
    v_policyform_product dml_t_policyform_product.tt_t_policyform_product;
    v_exists             NUMBER;
  BEGIN
    v_policyform_product.t_product_id     := ins.pkg_products.get_product_id(par_product_brief);
    v_policyform_product.t_policy_form_id := dml_t_policy_form.get_id_by_t_policy_form_name(par_policy_form_desc);
    v_policyform_product.user_id          := safety.curr_sys_user;
    v_policyform_product.start_date       := par_start_date;
    v_policyform_product.end_date         := par_end_date;
  
    SELECT COUNT(*)
      INTO v_exists
      FROM ins.t_policyform_product pp
     WHERE pp.t_product_id = v_policyform_product.t_product_id
       AND pp.t_policy_form_id = v_policyform_product.t_policy_form_id
       AND (pp.start_date BETWEEN v_policyform_product.start_date AND v_policyform_product.end_date OR
           pp.end_date BETWEEN v_policyform_product.start_date AND v_policyform_product.end_date);
  
    IF v_exists != 0
    THEN
      RAISE form_exists;
    END IF;
  
    dml_t_policyform_product.insert_record(par_record => v_policyform_product);
  
  EXCEPTION
    WHEN form_exists THEN
      ex.raise_custom('Такие полисные условия с указанными периодами действия существуют в продукте.');
  END add_product_policy_form;

  PROCEDURE add_product_control_func
  (
    par_product_brief       t_product.brief%TYPE
   ,par_func_brief          t_prod_coef_type.brief%TYPE
   ,par_is_underwriting_check BOOLEAN DEFAULT FALSE
   ,par_product_version_num t_product_version.version_nr%TYPE DEFAULT NULL
   ,par_sort_order          t_product_control.sort_order%TYPE DEFAULT NULL
   ,par_message             t_product_control.message%TYPE DEFAULT NULL
  ) IS
    v_product_id      t_product.product_id%TYPE := get_product_id(par_product_brief);
    v_product_control dml_t_product_control.tt_t_product_control;
  BEGIN
    IF par_product_version_num IS NULL
    THEN
      SELECT pv.t_product_version_id
        INTO v_product_control.t_product_version_id
        FROM t_product_version pv
       WHERE pv.product_id = v_product_id
         AND pv.version_nr = (SELECT MAX(pv1.version_nr)
                                FROM t_product_version pv1
                               WHERE pv1.product_id = pv.product_id);
    ELSE
      BEGIN
        SELECT pv.t_product_version_id
          INTO v_product_control.t_product_version_id
          FROM t_product_version pv
         WHERE pv.product_id = v_product_id
           AND pv.version_nr = par_product_version_num;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Версии продукта с таким номером не существует');
      END;
    END IF;
  
    v_product_control.control_func_id := pkg_prod_coef.get_prod_coef_type_id_by_brief(par_brief => par_func_brief);
    v_product_control.message         := par_message;
    v_product_control.is_underwriting_check := sys.diutil.bool_to_int(par_is_underwriting_check);
  
    IF par_sort_order IS NULL
    THEN
      SELECT nvl(MAX(sort_order), 0) + 1
        INTO v_product_control.sort_order
        FROM t_product_control pc
       WHERE pc.t_product_version_id = v_product_control.t_product_version_id;
    ELSE
      v_product_control.sort_order := par_sort_order;
    END IF;
  
    dml_t_product_control.insert_record(par_record => v_product_control);
  
  END add_product_control_func;

  /*Добавление линий продуктов в продукт
    Веселуха Е.В.
    17.06.2013
  */
  PROCEDURE add_empty_prod_line
  (
    par_product_brief              VARCHAR2
   ,par_lob_line_brief             VARCHAR2
   ,par_peril_array                tt_one_col
   ,par_product_line_desc          VARCHAR2 DEFAULT NULL
   ,par_product_line_brief         VARCHAR2 DEFAULT NULL
   ,par_product_line_type_brief    VARCHAR2 DEFAULT 'RECOMMENDED'
   ,par_public_description         VARCHAR2 DEFAULT NULL
   ,par_sort_order                 NUMBER DEFAULT NULL
   ,par_is_aggregate               BOOLEAN DEFAULT TRUE
   ,par_is_avtoprolongation        BOOLEAN DEFAULT FALSE
   ,par_skip_on_policy_creation    BOOLEAN DEFAULT FALSE
   ,pat_t_prolong_alg_brief        VARCHAR2 DEFAULT NULL
   ,par_t_prod_line_option_brief   VARCHAR2 DEFAULT NULL
   ,par_t_prod_line_option_desc    VARCHAR2 DEFAULT NULL
   ,par_amount_round_rules_brief   VARCHAR2 DEFAULT NULL
   ,par_fee_round_rules_brief      VARCHAR2 DEFAULT NULL
   ,par_tariff_func_precision      NUMBER DEFAULT 6
   ,par_netto_func_precision       NUMBER DEFAULT 6
   ,par_loading_func_precision     NUMBER DEFAULT NULL
   ,par_premium_func_precision     NUMBER DEFAULT NULL
   ,par_ins_price_func_precision   NUMBER DEFAULT NULL
   ,par_premium_func_brief         VARCHAR2 DEFAULT 'CALC_STANDART_PREMIUM'
   ,par_tariff_func_brief          VARCHAR2 DEFAULT NULL
   ,par_tariff_cost_value          NUMBER DEFAULT NULL
   ,par_tariff_netto_func_brief    VARCHAR2 DEFAULT NULL
   ,par_tariff_netto_cost_value    NUMBER DEFAULT NULL
   ,par_ins_amount_func_brief      VARCHAR2 DEFAULT NULL
   ,par_k_coef_nm_func_brief       VARCHAR2 DEFAULT NULL
   ,par_deduct_func_brief          VARCHAR2 DEFAULT NULL
   ,par_fee_func_brief             VARCHAR2 DEFAULT NULL
   ,par_ins_price_func_brief       VARCHAR2 DEFAULT NULL
   ,par_loading_func_brief         VARCHAR2 DEFAULT NULL
   ,par_loading_cost_value         NUMBER DEFAULT NULL
   ,par_s_coef_nm_func_brief       VARCHAR2 DEFAULT NULL
   ,par_precalc_ins_amount         BOOLEAN DEFAULT FALSE
   ,par_precalc_fee                BOOLEAN DEFAULT FALSE
   ,par_active_in_wait_period      BOOLEAN DEFAULT TRUE
   ,par_disable_reserve_calc       BOOLEAN DEFAULT FALSE
   ,par_fee_invest_part_func_brief VARCHAR2 DEFAULT NULL
   ,par_agregation_control_flag    BOOLEAN DEFAULT TRUE
  ) IS
    v_product_id         t_product.product_id%TYPE;
    v_product_version_id t_product_version.t_product_version_id%TYPE;
    v_product_ver_lob_id t_product_ver_lob.t_product_ver_lob_id%TYPE;
    v_lob_line_desc      t_lob_line.description%TYPE;
  
    v_product_line     dml_t_product_line.tt_t_product_line;
    v_lob_line         t_lob_line%ROWTYPE;
    v_product_ver_lob  dml_t_product_ver_lob.tt_t_product_ver_lob;
    v_prod_line_option dml_t_prod_line_option.tt_t_prod_line_option;
  
    c_cover_form_brief  CONSTANT t_cover_form.brief%TYPE := 'P_COVER_LIFE';
    c_premium_type_desc CONSTANT t_premium_type.description%TYPE := 'Годовая премия';
  BEGIN
    v_product_id := ins.pkg_products.get_product_id(par_product_brief);
  
    ins.pkg_products.get_lob_line_id(par_lob_line_brief
                                    ,v_lob_line_desc
                                    ,v_product_line.t_lob_line_id);
  
    v_lob_line                                  := dml_t_lob_line.get_record(v_product_line.t_lob_line_id);
    v_product_line.description                  := par_product_line_desc;
    v_product_line.brief                        := par_product_line_brief;
    v_product_line.insurance_group_id           := v_lob_line.insurance_group_id;
    v_product_line.is_aggregate                 := sys.diutil.bool_to_int(par_is_aggregate);
    v_product_line.is_avtoprolongation          := sys.diutil.bool_to_int(par_is_avtoprolongation);
    v_product_line.skip_on_policy_creation      := sys.diutil.bool_to_int(par_skip_on_policy_creation);
    v_product_line.tariff_func_precision        := par_tariff_func_precision;
    v_product_line.tariff_netto_func_precision  := par_netto_func_precision;
    v_product_line.loading_func_precision       := par_loading_func_precision;
    v_product_line.premium_func_precision       := par_premium_func_precision;
    v_product_line.ins_price_func_precision     := par_ins_price_func_precision;
    v_product_line.loading_const_value          := par_loading_cost_value;
    v_product_line.tariff_netto_const_value     := par_tariff_netto_cost_value;
    v_product_line.tariff_const_value           := par_tariff_cost_value;
    v_product_line.is_active_in_waitring_period := sys.diutil.bool_to_int(par_active_in_wait_period);
    v_product_line.disable_reserve_calc         := sys.diutil.bool_to_int(par_disable_reserve_calc);
    v_product_line.for_premium                  := 1;
    v_product_line.is_default                   := 0;
    v_product_line.premium_type                 := dml_t_premium_type.get_id_by_description(c_premium_type_desc);
    v_product_line.pre_calc_ins_amount          := sys.diutil.bool_to_int(par_precalc_ins_amount);
    v_product_line.pre_calc_fee                 := sys.diutil.bool_to_int(par_precalc_fee);
    v_product_line.public_description           := par_public_description;
    v_product_line.product_line_type_id         := dml_t_product_line_type.get_id_by_brief(par_product_line_type_brief);
  
    BEGIN
      SELECT tv.t_product_version_id
        INTO v_product_version_id
        FROM ins.t_product_version tv
       WHERE tv.product_id = v_product_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найдена Версия продукта.');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Слишком много у данного продукта Версий.');
    END;
  
    BEGIN
      SELECT tpvl.t_product_ver_lob_id
        INTO v_product_ver_lob_id
        FROM ins.t_product_ver_lob tpvl
       WHERE tpvl.product_version_id = v_product_version_id
         AND tpvl.lob_id = v_lob_line.t_lob_id;
    EXCEPTION
      WHEN no_data_found THEN
        dml_t_product_ver_lob.insert_record(par_product_version_id   => v_product_version_id
                                           ,par_lob_id               => v_lob_line.t_lob_id
                                           ,par_t_product_ver_lob_id => v_product_ver_lob_id);
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Ошибка определения Правила по продукту.');
    END;
  
    v_product_line.product_ver_lob_id := v_product_ver_lob_id;
  
    IF pat_t_prolong_alg_brief IS NOT NULL
    THEN
      v_product_line.t_prolong_alg_id := dml_t_prolong_alg.get_id_by_brief(pat_t_prolong_alg_brief);
    END IF;
  
    IF par_sort_order IS NOT NULL
    THEN
      v_product_line.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(pl.sort_order) + 10, 100)
        INTO v_product_line.sort_order
        FROM ins.t_product_line pl
            ,t_product_ver_lob  pvl
       WHERE pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pvl.product_version_id = v_product_version_id;
    END IF;
  
    v_product_line.t_cover_form_id := dml_t_cover_form.get_id_by_brief(c_cover_form_brief);
  
    IF par_amount_round_rules_brief IS NOT NULL
    THEN
      v_product_line.ins_amount_round_rules_id := dml_t_round_rules.get_id_by_brief(par_amount_round_rules_brief);
    END IF;
  
    IF par_fee_round_rules_brief IS NOT NULL
    THEN
      v_product_line.fee_round_rules_id := dml_t_round_rules.get_id_by_brief(par_fee_round_rules_brief);
    END IF;
  
    /*Функции*/
    IF par_premium_func_brief IS NOT NULL
    THEN
      v_product_line.premium_func_id := dml_t_prod_coef_type.get_id_by_brief(par_premium_func_brief);
    END IF;
  
    IF par_tariff_func_brief IS NOT NULL
    THEN
      v_product_line.tariff_func_id := dml_t_prod_coef_type.get_id_by_brief(par_tariff_func_brief);
    END IF;
  
    IF par_tariff_netto_func_brief IS NOT NULL
    THEN
      v_product_line.tariff_netto_func_id := dml_t_prod_coef_type.get_id_by_brief(par_tariff_netto_func_brief);
    END IF;
  
    IF par_ins_amount_func_brief IS NOT NULL
    THEN
      v_product_line.ins_amount_func_id := dml_t_prod_coef_type.get_id_by_brief(par_ins_amount_func_brief);
    END IF;
  
    IF par_k_coef_nm_func_brief IS NOT NULL
    THEN
      v_product_line.k_coef_nm_func_id := dml_t_prod_coef_type.get_id_by_brief(par_k_coef_nm_func_brief);
    END IF;
  
    IF par_deduct_func_brief IS NOT NULL
    THEN
      v_product_line.deduct_func_id := dml_t_prod_coef_type.get_id_by_brief(par_deduct_func_brief);
    END IF;
  
    IF par_fee_func_brief IS NOT NULL
    THEN
      v_product_line.fee_func_id := dml_t_prod_coef_type.get_id_by_brief(par_fee_func_brief);
    END IF;
  
    IF par_ins_price_func_brief IS NOT NULL
    THEN
      v_product_line.ins_price_func_id := dml_t_prod_coef_type.get_id_by_brief(par_ins_price_func_brief);
    END IF;
  
    IF par_loading_func_brief IS NOT NULL
    THEN
      v_product_line.loading_func_id := dml_t_prod_coef_type.get_id_by_brief(par_loading_func_brief);
    END IF;
  
    IF par_s_coef_nm_func_brief IS NOT NULL
    THEN
      v_product_line.s_coef_nm_func_id := dml_t_prod_coef_type.get_id_by_brief(par_s_coef_nm_func_brief);
    END IF;
  
    IF par_fee_invest_part_func_brief IS NOT NULL
    THEN
      v_product_line.fee_investment_part_func_id := dml_t_prod_coef_type.get_id_by_brief(par_fee_invest_part_func_brief);
    END IF;
  
    /**/
    dml_t_product_line.insert_record(par_record => v_product_line);
  
    v_prod_line_option.product_line_id := v_product_line.id;
    v_prod_line_option.brief           := nvl(par_t_prod_line_option_brief, v_lob_line.brief);
    v_prod_line_option.default_flag    := 1;
    v_prod_line_option.description     := coalesce(par_t_prod_line_option_desc
                                                  ,v_product_line.description
                                                  ,v_lob_line.description);
    v_prod_line_option.is_excluded     := 0;
    v_prod_line_option.agregation_control_flag := sys.diutil.bool_to_int(par_agregation_control_flag);
  
    dml_t_prod_line_option.insert_record(par_record => v_prod_line_option);
  
    IF par_peril_array IS NOT NULL
       AND par_peril_array.count > 0
    THEN
      FOR i IN par_peril_array.first .. par_peril_array.last
      LOOP
        DECLARE
          v_prod_line_opt_peril dml_t_prod_line_opt_peril.tt_t_prod_line_opt_peril;
        BEGIN
        
          SELECT MIN(pel.id)
            INTO v_prod_line_opt_peril.peril_id
            FROM ins.t_peril pel
           WHERE pel.description = par_peril_array(i);
        
          IF v_prod_line_opt_peril.peril_id IS NULL
          THEN
            ex.raise('Не найден Риск Группы (t_peril) по указанному Наименованию: ' ||
                     par_peril_array(i)
                    ,ex.c_no_data_found);
          END IF;
        
          v_prod_line_opt_peril.product_line_option_id := v_prod_line_option.id;
        
          dml_t_prod_line_opt_peril.insert_record(par_record => v_prod_line_opt_peril);
        
        END;
      END LOOP;
    END IF;
  
    pkg_products.add_prod_line_franchise(par_product_brief  => par_product_brief
                                        ,par_prod_line_desc => nvl(par_product_line_desc
                                                                  ,v_lob_line_desc));
  
  END add_empty_prod_line;

  /*Добавление Франшизы в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_franchise
  (
    par_product_brief           t_product.brief%TYPE
   ,par_prod_line_desc          t_product_line.description%TYPE
   ,par_t_deductible_type_brief t_deductible_type.brief%TYPE DEFAULT 'NONE'
   ,par_is_default              BOOLEAN DEFAULT TRUE
   ,par_t_deduct_val_type_brief t_deduct_val_type.brief%TYPE DEFAULT 'PERCENT'
   ,par_default_value           t_prod_line_deduct.default_value%TYPE DEFAULT NULL
   ,par_is_handchange_enabled   BOOLEAN DEFAULT FALSE
  ) IS
    v_prod_line_deduct     dml_t_prod_line_deduct.tt_t_prod_line_deduct;
    v_t_deductible_type_id NUMBER;
    v_deduct_val_type_id   NUMBER;
  BEGIN
  
    v_prod_line_deduct.product_line_id := ins.pkg_products.get_product_line_id(par_product_brief
                                                                              ,par_prod_line_desc);
  
    v_t_deductible_type_id := dml_t_deductible_type.get_id_by_brief(par_t_deductible_type_brief);
    v_deduct_val_type_id   := dml_t_deduct_val_type.get_id_by_brief(par_t_deduct_val_type_brief);
  
    BEGIN
      SELECT dr.t_deductible_rel_id
        INTO v_prod_line_deduct.deductible_rel_id
        FROM t_deductible_rel dr
       WHERE dr.deductible_type_id = v_t_deductible_type_id
         AND dr.deductible_value_type_id = v_deduct_val_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдено соответствие типа значения и типа франшизы.');
    END;
  
    IF par_is_default
    THEN
      UPDATE ins.t_prod_line_deduct dt
         SET dt.is_default = 0
       WHERE dt.product_line_id = v_prod_line_deduct.product_line_id
         AND is_default = 1;
    END IF;
  
    v_prod_line_deduct.is_default            := sys.diutil.bool_to_int(par_is_default);
    v_prod_line_deduct.is_handchange_enabled := sys.diutil.bool_to_int(par_is_handchange_enabled);
    v_prod_line_deduct.default_value         := par_default_value;
  
    dml_t_prod_line_deduct.insert_record(par_record => v_prod_line_deduct);
  
  END add_prod_line_franchise;

  /*Удаление Франшизы из Линии продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE del_prod_line_franchise
  (
    par_product_brief           t_product.brief%TYPE
   ,par_prod_line_desc          t_product_line.description%TYPE
   ,par_t_deductible_type_brief t_deductible_type.brief%TYPE DEFAULT NULL
  ) IS
    v_product_id           NUMBER;
    v_t_product_line_id    NUMBER;
    v_t_deductible_type_id NUMBER;
  BEGIN
    v_product_id        := ins.pkg_products.get_product_id(par_product_brief);
    v_t_product_line_id := ins.pkg_products.get_product_line_id(par_product_brief, par_prod_line_desc);
  
    IF par_t_deductible_type_brief IS NOT NULL
    THEN
      v_t_deductible_type_id := dml_t_deductible_type.get_id_by_brief(par_t_deductible_type_brief);
    END IF;
  
    DELETE FROM ins.ven_t_prod_line_deduct ld WHERE ld.product_line_id = v_t_product_line_id;
  
  END del_prod_line_franchise;

  /*Добавление Вида объекта в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_objects
  (
    par_product_brief          t_product.brief%TYPE
   ,par_prod_line_desc         t_product_line.description%TYPE
   ,par_t_asset_type_brief     t_asset_type.brief%TYPE DEFAULT 'ASSET_PERSON'
   ,par_t_prod_coef_type_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_is_insured             BOOLEAN DEFAULT FALSE
   ,par_is_ins_amount_agregate BOOLEAN DEFAULT TRUE
   ,par_is_ins_amount_date     BOOLEAN DEFAULT FALSE
   ,par_is_fee_agregate        BOOLEAN DEFAULT TRUE
   ,par_is_prem_agregate       BOOLEAN DEFAULT TRUE
  ) IS
    v_as_type_prod_line t_as_type_prod_line%ROWTYPE;
  BEGIN
  
    v_as_type_prod_line.product_line_id      := ins.pkg_products.get_product_line_id(par_product_brief
                                                                                    ,par_prod_line_desc);
    v_as_type_prod_line.asset_common_type_id := dml_t_asset_type.get_id_by_brief(par_t_asset_type_brief);
  
    v_as_type_prod_line.is_insured             := sys.diutil.bool_to_int(par_is_insured);
    v_as_type_prod_line.is_ins_amount_agregate := sys.diutil.bool_to_int(par_is_ins_amount_agregate);
    v_as_type_prod_line.is_ins_amount_date     := sys.diutil.bool_to_int(par_is_ins_amount_date);
    v_as_type_prod_line.is_ins_fee_agregate    := sys.diutil.bool_to_int(par_is_fee_agregate);
    v_as_type_prod_line.is_ins_prem_agregate   := sys.diutil.bool_to_int(par_is_prem_agregate);
  
    IF par_t_prod_coef_type_brief IS NOT NULL
    THEN
      v_as_type_prod_line.ins_amount_func_id := dml_t_prod_coef_type.get_id_by_brief(par_brief => par_t_prod_coef_type_brief);
    END IF;
  
    dml_t_as_type_prod_line.insert_record(par_record => v_as_type_prod_line);
  
  END add_prod_line_objects;

  /*Добавление Коэф.тарифа в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта, Бриф функции тарифа
  */
  PROCEDURE add_prod_line_coef_tar
  (
    par_product_brief          t_product.brief%TYPE
   ,par_prod_line_desc         t_product_line.description%TYPE
   ,par_t_prod_coef_type_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_is_restriction         BOOLEAN DEFAULT FALSE
   ,par_is_disabled            BOOLEAN DEFAULT FALSE
   ,par_sort_order             t_prod_line_coef.sort_order%TYPE DEFAULT NULL
  ) IS
    v_prod_line_coef dml_t_prod_line_coef.tt_t_prod_line_coef;
  
  BEGIN
  
    v_prod_line_coef.t_product_line_id   := ins.pkg_products.get_product_line_id(par_product_brief
                                                                                ,par_prod_line_desc);
    v_prod_line_coef.t_prod_coef_type_id := dml_t_prod_coef_type.get_id_by_brief(par_t_prod_coef_type_brief);
  
    IF par_sort_order IS NOT NULL
    THEN
      v_prod_line_coef.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(tpl.sort_order), 0) + 5
        INTO v_prod_line_coef.sort_order
        FROM ins.t_prod_line_coef tpl
       WHERE tpl.t_product_line_id = v_prod_line_coef.t_product_line_id;
    END IF;
  
    v_prod_line_coef.is_restriction := sys.diutil.bool_to_int(par_is_restriction);
    v_prod_line_coef.is_disabled    := sys.diutil.bool_to_int(par_is_disabled);
  
    dml_t_prod_line_coef.insert_record(par_record => v_prod_line_coef);
  
  END add_prod_line_coef_tar;

  /*Добавление Доп.параметров в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_more_option
  (
    par_product_brief            VARCHAR2
   ,par_prod_line_desc           VARCHAR2
   ,par_prod_line_brief          VARCHAR2 DEFAULT NULL
   ,par_amount_round_rules_brief VARCHAR2 DEFAULT NULL
   ,par_fee_round_rules_brief    VARCHAR2 DEFAULT NULL
   ,par_tariff_func_precision    NUMBER DEFAULT NULL
   ,par_netto_func_precision     NUMBER DEFAULT NULL
   ,par_premium_func_precision   NUMBER DEFAULT NULL
   ,par_ins_price_func_precision NUMBER DEFAULT NULL
  ) IS
    v_product_id                NUMBER;
    v_t_product_line_id         NUMBER;
    v_round_rules_ins_amount_id NUMBER := NULL;
    v_round_rules_fee_id        NUMBER := NULL;
  BEGIN
    v_product_id        := ins.pkg_products.get_product_id(par_product_brief);
    v_t_product_line_id := ins.pkg_products.get_product_line_id(par_product_brief, par_prod_line_desc);
  
    IF par_amount_round_rules_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tr.t_round_rules_id
          INTO v_round_rules_ins_amount_id
          FROM ins.t_round_rules tr
         WHERE tr.brief = par_amount_round_rules_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция округления СС по указанному Брифу.');
      END;
    END IF;
  
    IF par_fee_round_rules_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tr.t_round_rules_id
          INTO v_round_rules_fee_id
          FROM ins.t_round_rules tr
         WHERE tr.brief = par_fee_round_rules_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция округления Брутто взноса по указанному Брифу.');
      END;
    END IF;
  
    UPDATE ins.ven_t_product_line pl
       SET pl.brief                       = nvl(par_prod_line_brief, pl.brief)
          ,pl.fee_round_rules_id          = nvl(v_round_rules_fee_id, pl.fee_round_rules_id)
          ,pl.ins_amount_round_rules_id   = nvl(v_round_rules_ins_amount_id
                                               ,pl.ins_amount_round_rules_id)
          ,pl.tariff_func_precision       = nvl(par_tariff_func_precision, pl.tariff_func_precision)
          ,pl.tariff_netto_func_precision = nvl(par_netto_func_precision
                                               ,pl.tariff_netto_func_precision)
          ,pl.premium_func_precision      = nvl(par_premium_func_precision, pl.premium_func_precision)
          ,pl.ins_price_func_precision    = nvl(par_ins_price_func_precision
                                               ,pl.ins_price_func_precision)
     WHERE pl.id = v_t_product_line_id;
  
  END add_prod_line_more_option;

  /*Добавление периодов в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта, Значение периода
  */
  PROCEDURE add_prod_line_period
  (
    par_product_brief           t_product.brief%TYPE
   ,par_prod_line_desc          t_product_line.description%TYPE
   ,par_period_desc             t_period.description%TYPE
   ,par_t_period_use_type_brief t_period_use_type.brief%TYPE DEFAULT 'Срок страхования'
   ,par_control_func_brief      t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_is_default              BOOLEAN DEFAULT FALSE
   ,par_is_disabled             BOOLEAN DEFAULT FALSE
   ,par_sort_order              t_prod_line_period.sort_order%TYPE DEFAULT NULL
  ) IS
    vr_prod_line_period dml_t_prod_line_period.tt_t_prod_line_period;
  BEGIN
    vr_prod_line_period.product_line_id      := get_product_line_id(par_product_brief
                                                                   ,par_prod_line_desc);
    vr_prod_line_period.is_default           := sys.diutil.bool_to_int(par_is_default);
    vr_prod_line_period.is_disabled          := sys.diutil.bool_to_int(par_is_disabled);
    vr_prod_line_period.period_id            := dml_t_period.get_id_by_description(par_period_desc);
    vr_prod_line_period.t_period_use_type_id := dml_t_period_use_type.get_id_by_brief(par_t_period_use_type_brief);
  
    IF par_control_func_brief IS NOT NULL
    THEN
      vr_prod_line_period.control_func_id := dml_t_prod_coef_type.get_id_by_brief(par_control_func_brief);
    END IF;
  
    IF par_sort_order IS NOT NULL
    THEN
      vr_prod_line_period.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(t.sort_order), 0) + 5
        INTO vr_prod_line_period.sort_order
        FROM t_prod_line_period t
       WHERE t.product_line_id = vr_prod_line_period.product_line_id
         AND t.t_period_use_type_id = vr_prod_line_period.t_period_use_type_id;
    END IF;
  
    IF par_is_default
    THEN
      UPDATE t_prod_line_period t
         SET t.is_default = 0
       WHERE t.product_line_id = vr_prod_line_period.product_line_id
         AND t.t_period_use_type_id = vr_prod_line_period.t_period_use_type_id
         AND t.is_default = 1;
    END IF;
  
    dml_t_prod_line_period.insert_record(par_record => vr_prod_line_period);
  
  END add_prod_line_period;

  /*Добавление Функций в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта
    DEPRECATED
  */
  PROCEDURE add_prod_line_function
  (
    par_product_brief           VARCHAR2
   ,par_prod_line_desc          VARCHAR2
   ,par_premium_func_brief      VARCHAR2 DEFAULT NULL
   ,par_tariff_func_brief       VARCHAR2 DEFAULT NULL
   ,par_tariff_netto_func_brief VARCHAR2 DEFAULT NULL
   ,par_ins_amount_func_brief   VARCHAR2 DEFAULT NULL
   ,par_k_coef_nm_func_brief    VARCHAR2 DEFAULT NULL
   ,par_deduct_func_brief       VARCHAR2 DEFAULT NULL
   ,par_fee_func_brief          VARCHAR2 DEFAULT NULL
   ,par_ins_price_func_brief    VARCHAR2 DEFAULT NULL
   ,par_loading_func_brief      VARCHAR2 DEFAULT NULL
   ,par_s_coef_nm_func_brief    VARCHAR2 DEFAULT NULL
  ) IS
    v_product_id           NUMBER;
    v_t_product_line_id    NUMBER;
    v_prod_coef_type_id_1  NUMBER := NULL;
    v_prod_coef_type_id_2  NUMBER := NULL;
    v_prod_coef_type_id_3  NUMBER := NULL;
    v_prod_coef_type_id_4  NUMBER := NULL;
    v_prod_coef_type_id_5  NUMBER := NULL;
    v_prod_coef_type_id_6  NUMBER := NULL;
    v_prod_coef_type_id_7  NUMBER := NULL;
    v_prod_coef_type_id_8  NUMBER := NULL;
    v_prod_coef_type_id_9  NUMBER := NULL;
    v_prod_coef_type_id_10 NUMBER := NULL;
  BEGIN
    v_product_id        := ins.pkg_products.get_product_id(par_product_brief);
    v_t_product_line_id := ins.pkg_products.get_product_line_id(par_product_brief, par_prod_line_desc);
  
    IF par_premium_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_1
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_premium_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета страховой премии по указанному Брифу.');
      END;
    END IF;
  
    IF par_tariff_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_2
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_tariff_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета страхового тарифа по указанному Брифу.');
      END;
    END IF;
  
    IF par_tariff_netto_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_3
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_tariff_netto_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета нетто тарифа по указанному Брифу.');
      END;
    END IF;
  
    IF par_ins_amount_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_4
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_ins_amount_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета страховой суммы по указанному Брифу.');
      END;
    END IF;
  
    IF par_k_coef_nm_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_5
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_k_coef_nm_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета коэффициента К по указанному Брифу.');
      END;
    END IF;
  
    IF par_deduct_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_6
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_deduct_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета франшизы по указанному Брифу.');
      END;
    END IF;
  
    IF par_fee_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_7
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_fee_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета брутто взноса по указанному Брифу.');
      END;
    END IF;
  
    IF par_ins_price_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_8
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_ins_price_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета страховой стоимости по указанному Брифу.');
      END;
    END IF;
  
    IF par_loading_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_9
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_loading_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета нагрузки по указанному Брифу.');
      END;
    END IF;
  
    IF par_s_coef_nm_func_brief IS NOT NULL
    THEN
      BEGIN
        SELECT tpt.t_prod_coef_type_id
          INTO v_prod_coef_type_id_10
          FROM ins.t_prod_coef_type tpt
         WHERE tpt.brief = par_s_coef_nm_func_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена Функция расчета коэффициента S по указанному Брифу.');
      END;
    END IF;
  
    UPDATE ins.t_product_line pl
       SET pl.premium_func_id      = nvl(v_prod_coef_type_id_1, pl.premium_func_id)
          ,pl.tariff_func_id       = nvl(v_prod_coef_type_id_2, pl.tariff_func_id)
          ,pl.tariff_netto_func_id = nvl(v_prod_coef_type_id_3, pl.tariff_netto_func_id)
          ,pl.ins_amount_func_id   = nvl(v_prod_coef_type_id_4, pl.ins_amount_func_id)
          ,pl.k_coef_nm_func_id    = nvl(v_prod_coef_type_id_5, pl.k_coef_nm_func_id)
          ,pl.deduct_func_id       = nvl(v_prod_coef_type_id_6, pl.deduct_func_id)
          ,pl.fee_func_id          = nvl(v_prod_coef_type_id_7, pl.fee_func_id)
          ,pl.ins_price_func_id    = nvl(v_prod_coef_type_id_8, pl.ins_price_func_id)
          ,pl.loading_func_id      = nvl(v_prod_coef_type_id_9, pl.loading_func_id)
          ,pl.s_coef_nm_func_id    = nvl(v_prod_coef_type_id_10, pl.s_coef_nm_func_id)
     WHERE pl.id = v_t_product_line_id;
  
  END add_prod_line_function;

  /*Добавление Функции контроля покрытия в Линию продукта
    Веселуха Е.В.
    18.06.2013
    Обязательные параметры: Бриф продукта, Наименование Линии продукта, Бриф функции контроля покрыти
  */
  PROCEDURE add_prod_line_control
  (
    par_product_brief        t_product.brief%TYPE
   ,par_prod_line_desc       t_product_line.description%TYPE
   ,par_func_limit_brief     t_prod_coef_type.brief%TYPE
   ,par_is_precreation_check BOOLEAN DEFAULT FALSE
   ,par_is_underwriting_check BOOLEAN DEFAULT FALSE
   ,par_comments             t_product_line_limit.comments%TYPE DEFAULT NULL
   ,par_sort_order           t_product_line_limit.sort_order%TYPE DEFAULT NULL
   ,par_message              t_product_line_limit.message%TYPE DEFAULT NULL
  ) IS
    vr_product_line_limit dml_t_product_line_limit.tt_t_product_line_limit;
  BEGIN
    vr_product_line_limit.t_product_line_id    := get_product_line_id(par_product_brief
                                                                     ,par_prod_line_desc);
    vr_product_line_limit.limit_func_id        := dml_t_prod_coef_type.get_id_by_brief(par_func_limit_brief);
    vr_product_line_limit.comments             := par_comments;
    vr_product_line_limit.message              := par_message;
    vr_product_line_limit.is_precreation_check := sys.diutil.bool_to_int(par_is_precreation_check);
    vr_product_line_limit.is_underwriting_check := sys.diutil.bool_to_int(par_is_underwriting_check);
  
    IF par_sort_order IS NOT NULL
    THEN
      vr_product_line_limit.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(tll.sort_order), 0) + 5
        INTO vr_product_line_limit.sort_order
        FROM ins.t_product_line_limit tll
       WHERE tll.t_product_line_id = vr_product_line_limit.t_product_line_id;
    END IF;
  
    dml_t_product_line_limit.insert_record(par_record => vr_product_line_limit);
  
  END add_prod_line_control;

  /*Добавление Территории для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE add_prod_line_territory
  (
    par_product_brief     t_product.brief%TYPE
   ,par_prod_line_desc    t_product_line.description%TYPE
   ,par_t_territory_brief t_territory.brief%TYPE DEFAULT 'HW24'
  ) IS
    v_t_product_line_id NUMBER;
    v_ter_id            NUMBER;
    v_exists            NUMBER;
    territory_exists EXCEPTION;
    v_product_ter_id NUMBER;
    vr_prod_line_ter dml_t_prod_line_ter.tt_t_prod_line_ter;
  BEGIN
    vr_prod_line_ter.product_line_id := get_product_line_id(par_product_brief, par_prod_line_desc);
    vr_prod_line_ter.t_territory_id  := dml_t_territory.get_id_by_brief(par_t_territory_brief);
  
    dml_t_prod_line_ter.insert_record(par_record => vr_prod_line_ter);
  END add_prod_line_territory;

  /*Добавление норм доходности для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Значение нормы доходности, Бриф Валюты
  */
  PROCEDURE add_prod_line_normrate
  (
    par_product_brief   t_product.brief%TYPE
   ,par_prod_line_desc  t_product_line.description%TYPE
   ,par_value_normrate  t_prod_line_norm.value%TYPE
   ,par_normrate_id     normrate.normrate_id%TYPE DEFAULT NULL
   ,par_is_default      BOOLEAN DEFAULT TRUE
   ,par_func_norm_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_note            t_prod_line_norm.note%TYPE DEFAULT NULL
  ) IS
    vr_prod_line_norm dml_t_prod_line_norm.tt_t_prod_line_norm;
  BEGIN
    vr_prod_line_norm.product_line_id := ins.pkg_products.get_product_line_id(par_product_brief
                                                                             ,par_prod_line_desc);
    vr_prod_line_norm.is_default      := sys.diutil.bool_to_int(par_is_default);
    vr_prod_line_norm.normrate_id     := par_normrate_id;
    vr_prod_line_norm.value           := par_value_normrate;
    vr_prod_line_norm.note            := par_note;
  
    IF par_func_norm_brief IS NOT NULL
    THEN
      vr_prod_line_norm.norm_func_id := dml_t_prod_coef_type.get_id_by_brief(par_func_norm_brief);
    END IF;
  
    IF par_is_default
    THEN
      UPDATE t_prod_line_norm t
         SET t.is_default = 0
       WHERE t.product_line_id = vr_prod_line_norm.product_line_id
         AND t.is_default = 1;
    END IF;
  
    dml_t_prod_line_norm.insert_record(par_record => vr_prod_line_norm);
  
  END add_prod_line_normrate;

  /*Добавление Справочника смертности для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Бриф Справочника смертности
  */
  PROCEDURE add_prod_line_deathrate
  (
    par_product_brief    t_product.brief%TYPE
   ,par_prod_line_desc   t_product_line.description%TYPE
   ,par_deathrate_brief  deathrate.brief%TYPE
   ,par_func_table_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
  ) IS
    vr_prod_line_rate dml_t_prod_line_rate.tt_t_prod_line_rate;
  BEGIN
    vr_prod_line_rate.product_line_id := get_product_line_id(par_product_brief, par_prod_line_desc);
    vr_prod_line_rate.deathrate_id    := dml_deathrate.get_id_by_brief(par_deathrate_brief);
  
    IF par_func_table_brief IS NOT NULL
    THEN
      vr_prod_line_rate.func_id := dml_t_prod_coef_type.get_id_by_brief(par_func_table_brief);
    END IF;
  
    dml_t_prod_line_rate.insert_record(vr_prod_line_rate);
  
  END add_prod_line_deathrate;

  /*Добавление Алгоритма ЗСП для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Бриф ЗСП
  */
  PROCEDURE add_prod_line_met_decl
  (
    par_product_brief        t_product.brief%TYPE
   ,par_prod_line_desc       t_product_line.description%TYPE
   ,par_t_metod_decline_desc t_metod_decline.name%TYPE
   ,par_is_default           BOOLEAN DEFAULT TRUE
  ) IS
    v_product_id            NUMBER;
    v_t_product_line_id     NUMBER;
    v_metod_decline_id      NUMBER;
    v_prod_line_met_decl_id NUMBER;
    vr_prod_line_met_decl   dml_t_prod_line_met_decl.tt_t_prod_line_met_decl;
  BEGIN
    vr_prod_line_met_decl.t_prodline_metdec_prod_line_id := get_product_line_id(par_product_brief
                                                                               ,par_prod_line_desc);
    vr_prod_line_met_decl.t_prodline_metdec_met_decl_id  := dml_t_metod_decline.get_id_by_name(par_t_metod_decline_desc);
    vr_prod_line_met_decl.is_default                     := sys.diutil.bool_to_int(par_is_default);
  
    IF par_is_default
    THEN
      UPDATE ins.t_prod_line_met_decl tm
         SET tm.is_default = 0
       WHERE tm.t_prodline_metdec_prod_line_id = vr_prod_line_met_decl.t_prodline_metdec_prod_line_id
         AND is_default = 1;
    END IF;
  
    dml_t_prod_line_met_decl.insert_record(par_record => vr_prod_line_met_decl);
  
  END add_prod_line_met_decl;

  /*Добавление Документов для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта
    Остальные параметры по умолчанию
  */
  PROCEDURE add_prod_line_documents
  (
    par_product_brief  t_product.brief%TYPE
   ,par_prod_line_desc t_product_line.description%TYPE
   ,par_doc_desc       t_issuer_doc_type.name%TYPE
   ,par_sort_order     t_pline_issuer_doc.sort_order%TYPE DEFAULT NULL
   ,par_is_required    BOOLEAN DEFAULT FALSE
  ) IS
    vr_pline_issuer_doc dml_t_pline_issuer_doc.tt_t_pline_issuer_doc;
  BEGIN
    vr_pline_issuer_doc.t_prod_line_id       := get_product_line_id(par_product_brief
                                                                   ,par_prod_line_desc);
    vr_pline_issuer_doc.t_issuer_doc_type_id := dml_t_issuer_doc_type.get_id_by_name(par_doc_desc);
    vr_pline_issuer_doc.is_required          := sys.diutil.bool_to_int(par_is_required);
  
    IF par_sort_order IS NOT NULL
    THEN
      vr_pline_issuer_doc.sort_order := par_sort_order;
    ELSE
      SELECT nvl(MAX(t.sort_order), 0) + 5
        INTO vr_pline_issuer_doc.sort_order
        FROM t_pline_issuer_doc t
       WHERE t.t_prod_line_id = vr_pline_issuer_doc.t_prod_line_id;
    END IF;
  
    dml_t_pline_issuer_doc.insert_record(par_record => vr_pline_issuer_doc);
  
  END add_prod_line_documents;

  /*Добавление Родительской программы для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Наименование Родителя
  */
  PROCEDURE add_prod_line_parent
  (
    par_product_brief         t_product.brief%TYPE
   ,par_prod_line_desc        t_product_line.description%TYPE
   ,par_prod_line_parent_desc t_product_line.description%TYPE
   ,par_is_parent_ins_amount  BOOLEAN DEFAULT FALSE
   ,par_amount                parent_prod_line.amount%TYPE DEFAULT NULL
  ) IS
    v_parent_prod_line dml_parent_prod_line.tt_parent_prod_line;
  BEGIN
  
    v_parent_prod_line.t_prod_line_id        := ins.pkg_products.get_product_line_id(par_product_brief
                                                                                    ,par_prod_line_desc);
    v_parent_prod_line.t_parent_prod_line_id := ins.pkg_products.get_product_line_id(par_product_brief
                                                                                    ,par_prod_line_parent_desc);
  
    v_parent_prod_line.product_ver_lob_id := dml_t_product_line.get_record(v_parent_prod_line.t_prod_line_id)
                                             .product_ver_lob_id;
  
    v_parent_prod_line.is_parent_ins_amount := sys.diutil.bool_to_int(par_is_parent_ins_amount);
    v_parent_prod_line.amount               := par_amount;
  
    dml_parent_prod_line.insert_record(par_record => v_parent_prod_line);
  
  END add_prod_line_parent;

  /*Добавление Конкурирующей программы для Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта, Наименование Конкурента
  */
  PROCEDURE add_prod_line_concurrent
  (
    par_product_brief             t_product.brief%TYPE
   ,par_prod_line_desc            t_product_line.description%TYPE
   ,par_prod_line_concurrent_desc t_product_line.description%TYPE
  ) IS
    v_product_id           NUMBER;
    v_concurrent_prod_line dml_concurrent_prod_line.tt_concurrent_prod_line;
  BEGIN
  
    v_product_id                             := ins.pkg_products.get_product_id(par_product_brief);
    v_concurrent_prod_line.t_product_line_id := ins.pkg_products.get_product_line_id(par_product_brief
                                                                                    ,par_prod_line_desc);
  
    BEGIN
      SELECT pla.product_ver_lob_id
        INTO v_concurrent_prod_line.product_ver_lob_id
        FROM ins.t_product_line pla
       WHERE pla.id = v_concurrent_prod_line.t_product_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Неопределен product_ver_lob_id.');
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_concurrent_prod_line.t_concur_product_line_id
        FROM ins.t_product_line pl
       WHERE pl.description = par_prod_line_concurrent_desc
         AND pl.product_ver_lob_id = v_concurrent_prod_line.product_ver_lob_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден Конкурент по указанному Наименованию.');
    END;
  
    dml_concurrent_prod_line.insert_record(par_record => v_concurrent_prod_line);
  
  END add_prod_line_concurrent;

  /*Удаление Линии продукта
    Веселуха Е.В.
    18.06.2013
    Параметры обязательные: Бриф продукта, Наименование Линии продукта
  */
  PROCEDURE del_prod_line
  (
    par_product_brief  VARCHAR2
   ,par_prod_line_desc VARCHAR2
  ) IS
    v_product_id        NUMBER;
    v_t_product_line_id NUMBER;
    v_exists_policy     NUMBER;
    use_in_policy EXCEPTION;
  BEGIN
    v_product_id        := ins.pkg_products.get_product_id(par_product_brief);
    v_t_product_line_id := ins.pkg_products.get_product_line_id(par_product_brief, par_prod_line_desc);
  
    SELECT COUNT(*)
      INTO v_exists_policy
      FROM ins.p_cover            pc
          ,ins.t_prod_line_option opt
          ,ins.status_hist        st
     WHERE pc.t_prod_line_option_id = opt.id
       AND opt.product_line_id = v_t_product_line_id
       AND pc.status_hist_id = st.status_hist_id
       AND st.brief NOT IN ('NEW', 'CURRENT');
    IF v_exists_policy != 0
    THEN
      RAISE use_in_policy;
    END IF;
  
    DELETE FROM ins.ven_t_product_line pl WHERE pl.id = v_t_product_line_id;
  
  EXCEPTION
    WHEN use_in_policy THEN
      raise_application_error(-20001
                             ,'Линия продукта используется в ДС, удаление невозможно.');
  END del_prod_line;
  /**/
  PROCEDURE insert_product_curator
  (
    par_product_id    NUMBER
   ,par_employee_id   NUMBER
   ,par_department_id NUMBER DEFAULT NULL
   ,par_is_default    NUMBER DEFAULT NULL
  ) IS
    v_organisation_tree_id NUMBER;
  BEGIN
  
    SELECT org.organisation_tree_id
      INTO v_organisation_tree_id
      FROM ven_employee      ee
          ,organisation_tree org
     WHERE ee.employee_id = par_employee_id
       AND ee.organisation_id = org.organisation_tree_id(+);
  
    INSERT INTO ven_t_product_curator
      (department_id, employee_id, is_default, organisation_tree_id, t_product_id)
    VALUES
      (par_department_id
      ,par_employee_id
      ,nvl(par_is_default, 0)
      ,v_organisation_tree_id
      ,par_product_id);
  
  END insert_product_curator;

  PROCEDURE insert_product_curator
  (
    par_product_brief VARCHAR2
   ,par_employee_id   NUMBER
   ,par_department_id NUMBER DEFAULT NULL
   ,par_is_default    NUMBER DEFAULT NULL
  ) IS
    v_product_id NUMBER;
  BEGIN
    v_product_id := get_product_id(par_product_brief => par_product_brief);
  
    insert_product_curator(par_product_id    => v_product_id
                          ,par_employee_id   => par_employee_id
                          ,par_department_id => par_department_id
                          ,par_is_default    => par_is_default);
  
  END insert_product_curator;

  PROCEDURE ins_prod_line
  (
    pl           IN OUT ven_t_product_line%ROWTYPE
   ,p_product_id ven_t_product.product_id%TYPE
  ) AS
  BEGIN
    INSERT INTO ven_t_product_version
      (product_id, t_product_version_id, start_date, end_date)
    VALUES
      (p_product_id, sq_t_product_version.nextval, trunc(SYSDATE), trunc(SYSDATE));
    INSERT INTO ven_t_product_ver_lob
      (t_product_ver_lob_id, product_version_id)
    VALUES
      (sq_t_product_ver_lob.nextval, sq_t_product_version.currval);
    SELECT sq_t_product_ver_lob.currval INTO pl.product_ver_lob_id FROM dual;
    INSERT INTO ven_t_product_line VALUES pl;
  END ins_prod_line;

  PROCEDURE ins_prod_line
  (
    p_product_id           ven_t_product.product_id%TYPE
   ,p_description          ven_t_product_line.description%TYPE
   ,p_premium_type         ven_t_product_line.premium_type%TYPE
   ,p_product_line_type_id ven_t_product_line.product_line_type_id%TYPE
   ,p_insurance_group_id   ven_t_product_line.insurance_group_id%TYPE
   ,p_visible_flag         ven_t_product_line.visible_flag%TYPE
   ,p_is_default           ven_t_product_line.is_default%TYPE
   ,p_sort_order           ven_t_product_line.sort_order%TYPE
   ,p_for_premium          ven_t_product_line.for_premium%TYPE
   ,p_id                   ven_t_product_line.id%TYPE DEFAULT NULL
  ) AS
    v_pl ven_t_product_line%ROWTYPE;
  BEGIN
    v_pl.description          := p_description;
    v_pl.premium_type         := p_premium_type;
    v_pl.product_line_type_id := p_product_line_type_id;
    v_pl.insurance_group_id   := p_insurance_group_id;
    v_pl.visible_flag         := nvl(p_visible_flag, 1);
    v_pl.is_default           := nvl(p_is_default, 0);
    v_pl.sort_order           := nvl(p_sort_order, 100);
    v_pl.for_premium          := nvl(p_for_premium, 0);
    v_pl.id                   := p_id;
    ins_prod_line(v_pl, p_product_id);
  END ins_prod_line;

  PROCEDURE upd_prod_line
  (
    p_prod_line_id         ven_t_product_line.id%TYPE
   ,p_description          ven_t_product_line.description%TYPE
   ,p_premium_type         ven_t_product_line.premium_type%TYPE
   ,p_product_line_type_id ven_t_product_line.product_line_type_id%TYPE
   ,p_insurance_group_id   ven_t_product_line.insurance_group_id%TYPE
   ,p_visible_flag         ven_t_product_line.visible_flag%TYPE
   ,p_is_default           ven_t_product_line.is_default%TYPE
   ,p_sort_order           ven_t_product_line.sort_order%TYPE
   ,p_for_premium          ven_t_product_line.for_premium%TYPE
  ) AS
  BEGIN
    UPDATE ven_t_product_line
       SET description          = p_description
          ,premium_type         = p_premium_type
          ,product_line_type_id = p_product_line_type_id
          ,insurance_group_id   = p_insurance_group_id
          ,visible_flag         = p_visible_flag
          ,is_default           = p_is_default
          ,sort_order           = p_sort_order
          ,for_premium          = p_for_premium
     WHERE id = p_prod_line_id;
  END upd_prod_line;

  FUNCTION gear_branch_ig
  (
    p_insurance_group_id ven_t_insurance_group.t_insurance_group_id%TYPE
   ,p_gear_branch_ig     ven_t_insurance_group.t_insurance_group_id%TYPE
  ) RETURN NUMBER AS
    -- функция рекурсивно обходит ветку сущности "Вид страхования" (t_insurance_group)
    -- и возвращает "1" если элемент принадлежит этой ветке или "0" если нет ("null" - при ошибке)
    -- параметры: "p_insurance_group_id" - ИД элемента дерева
    --            "p_gear_branch_ig" - ИД ветви к которой он предположиетльно привязан
    v_insurance_group ven_t_insurance_group.t_insurance_group_id%TYPE;
  BEGIN
    IF p_insurance_group_id = p_gear_branch_ig
    THEN
      RETURN 1;
    END IF;
    BEGIN
      SELECT parent_id
        INTO v_insurance_group
        FROM ven_t_insurance_group
       WHERE t_insurance_group_id = p_insurance_group_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
    IF v_insurance_group IS NULL
    THEN
      RETURN 0;
    ELSIF v_insurance_group = p_gear_branch_ig
    THEN
      RETURN 1;
    ELSE
      RETURN gear_branch_ig(v_insurance_group, p_gear_branch_ig);
    END IF;
  END gear_branch_ig;

  FUNCTION gear_branch_prod
  (
    p_product_id     ven_t_product.product_id%TYPE
   ,p_gear_branch_ig ven_t_insurance_group.t_insurance_group_id%TYPE
  ) RETURN NUMBER AS
  BEGIN
    FOR x IN (SELECT pl.id
                    ,pv.product_id
                    ,pl.insurance_group_id
                FROM ven_t_product_line pl
                JOIN ven_t_product_ver_lob pvl
                  ON pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                JOIN ven_t_product_version pv
                  ON pv.t_product_version_id = pvl.product_version_id
               WHERE pv.product_id = p_product_id)
    LOOP
      RETURN gear_branch_ig(x.insurance_group_id, p_gear_branch_ig);
    END LOOP;
    RETURN 0;
  END gear_branch_prod;

  PROCEDURE drop_product(p_product_id NUMBER) IS
    v_product_brief VARCHAR2(100);
  BEGIN
    SELECT brief INTO v_product_brief FROM ven_t_product WHERE product_id = p_product_id;
    DELETE FROM form_item_status
     WHERE (id1 = v_product_brief AND lower(field1) LIKE '%.product_brief')
        OR (id2 = v_product_brief AND lower(field2) LIKE '%.product_brief')
        OR (id3 = v_product_brief AND lower(field3) LIKE '%.product_brief');
    DELETE FROM ven_t_product WHERE product_id = p_product_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20100
                             ,'Продукта с Id= ' || p_product_id || ' не существует');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  PROCEDURE copy_product
  (
    par_src_product_brief t_product.brief%TYPE
   ,par_product_name      t_product.description%TYPE
   ,par_product_brief     t_product.brief%TYPE
  ) IS
  BEGIN
  
    copy_product(par_product_from_id => get_product_id(par_src_product_brief)
                ,par_product_name    => par_product_name
                ,par_product_brief   => par_product_brief);
  END;
  /*
    Байтин А.
    Копирует продукт, в отличии от product_copy, нормально копирует parent риски и concurrent
  */
  PROCEDURE copy_product
  (
    par_product_from_id t_product.product_id%TYPE
   ,par_product_name    t_product.description%TYPE
   ,par_product_brief   t_product.brief%TYPE
  ) IS
    TYPE tt_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  
    vt_plines                tt_ids;
    vt_ver_lobs              tt_ids;
    v_prod_line_option_id    NUMBER;
    v_prod_line_opt_peril_id NUMBER;
    v_prod_line_contact_id   NUMBER;
    v_prod_line_coef_id      NUMBER;
    v_product_addendum_id    NUMBER;
  
    v_product         dml_t_product.tt_t_product;
    v_product_version dml_t_product_version.tt_t_product_version;
    v_product_ver_lob dml_t_product_ver_lob.tt_t_product_ver_lob;
    v_product_line    dml_t_product_line.tt_t_product_line;
  
    PROCEDURE copy_product_version_control
    (
      par_src_product_version_id t_product_version.t_product_version_id%TYPE
     ,par_dst_product_version_id t_product_version.t_product_version_id%TYPE
    ) IS
      v_product_control dml_t_product_control.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT *
                    FROM t_product_control t
                   WHERE t.t_product_version_id = par_src_product_version_id)
      LOOP
        rec.t_product_version_id := par_dst_product_version_id;
        v_product_control(v_product_control.count + 1) := rec;
      END LOOP;
    
      dml_t_product_control.insert_record_list(par_record_list => v_product_control);
    END copy_product_version_control;
  
    PROCEDURE copy_prod_line_opt_peril
    (
      par_prod_line_opt_from_id NUMBER
     ,par_prod_line_opt_to_id   NUMBER
    ) IS
      v_prod_line_opt_peril dml_t_prod_line_opt_peril.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT *
                    FROM t_prod_line_opt_peril t
                   WHERE t.product_line_option_id = par_prod_line_opt_from_id)
      LOOP
        rec.product_line_option_id := par_prod_line_opt_to_id;
        v_prod_line_opt_peril(v_prod_line_opt_peril.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_line_opt_peril.insert_record_list(par_record_list => v_prod_line_opt_peril);
    END copy_prod_line_opt_peril;
  
    PROCEDURE copy_agr_custom
    (
      par_prod_line_opt_from_id NUMBER
     ,par_prod_line_opt_to_id   NUMBER
    ) IS
      v_agr_custom dml_t_agr_custom.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT *
                    FROM t_agr_custom t
                   WHERE t.t_prod_line_option_id = par_prod_line_opt_from_id)
      LOOP
        rec.t_prod_line_option_id := par_prod_line_opt_to_id;
        v_agr_custom(v_agr_custom.count + 1) := rec;
      END LOOP;

      dml_t_agr_custom.insert_record_list(par_record_list => v_agr_custom);
    END copy_agr_custom;

    PROCEDURE copy_prod_line_opts
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_option dml_t_prod_line_option.tt_t_prod_line_option;
    BEGIN
      FOR vr_plineo IN (SELECT *
                          FROM t_prod_line_option
                         WHERE product_line_id = par_product_line_from_id)
      LOOP
        v_prod_line_option                 := vr_plineo;
        v_prod_line_option.product_line_id := par_product_line_to_id;
      
        dml_t_prod_line_option.insert_record(par_record => v_prod_line_option);
      
        copy_agr_custom(vr_plineo.id, v_prod_line_option.id);

        copy_prod_line_opt_peril(vr_plineo.id, v_prod_line_option.id);
      END LOOP;
    END copy_prod_line_opts;
  
    PROCEDURE copy_prod_line_deduct
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_deduct dml_t_prod_line_deduct.typ_associative_array;
    BEGIN
      FOR vr_prod_line_deduct IN (SELECT *
                                    FROM t_prod_line_deduct t
                                   WHERE t.product_line_id = par_product_line_from_id)
      LOOP
        vr_prod_line_deduct.product_line_id := par_product_line_to_id;
        v_prod_line_deduct(v_prod_line_deduct.count + 1) := vr_prod_line_deduct;
      END LOOP;
    
      dml_t_prod_line_deduct.insert_record_list(par_record_list => v_prod_line_deduct);
    END copy_prod_line_deduct;
  
    PROCEDURE copy_as_type_prod_line
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_as_type_prod_line dml_t_as_type_prod_line.typ_associative_array;
    BEGIN
      FOR vr_as_type_prod_line IN (SELECT *
                                     FROM t_as_type_prod_line t
                                    WHERE t.product_line_id = par_product_line_from_id)
      LOOP
        vr_as_type_prod_line.product_line_id := par_product_line_to_id;
        v_as_type_prod_line(v_as_type_prod_line.count + 1) := vr_as_type_prod_line;
      END LOOP;
    
      dml_t_as_type_prod_line.insert_record_list(par_record_list => v_as_type_prod_line);
    END copy_as_type_prod_line;
  
    PROCEDURE copy_prod_line_coef_saf
    (
      par_prod_line_coef_from_id NUMBER
     ,par_prod_line_coef_to_id   NUMBER
    ) IS
      v_prod_line_coef_saf dml_t_prod_line_coef_saf.typ_associative_array;
    BEGIN
      FOR vr_prod_line_coef_saf IN (SELECT *
                                      FROM t_prod_line_coef_saf t
                                     WHERE t.t_prod_line_coef_id = par_prod_line_coef_from_id)
      LOOP
        vr_prod_line_coef_saf.t_prod_line_coef_id := par_prod_line_coef_to_id;
      
        v_prod_line_coef_saf(v_prod_line_coef_saf.count + 1) := vr_prod_line_coef_saf;
      END LOOP;
      dml_t_prod_line_coef_saf.insert_record_list(v_prod_line_coef_saf);
    END copy_prod_line_coef_saf;
  
    PROCEDURE copy_prod_line_coef
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_coef dml_t_prod_line_coef.tt_t_prod_line_coef;
    BEGIN
      FOR vr_prod_line_coef IN (SELECT *
                                  FROM t_prod_line_coef t
                                 WHERE t.t_product_line_id = par_product_line_from_id)
      LOOP
        v_prod_line_coef                   := vr_prod_line_coef;
        v_prod_line_coef.t_product_line_id := par_product_line_to_id;
      
        dml_t_prod_line_coef.insert_record(par_record => v_prod_line_coef);
      
        copy_prod_line_coef_saf(vr_prod_line_coef.t_prod_line_coef_id
                               ,v_prod_line_coef.t_prod_line_coef_id);
      END LOOP;
    END copy_prod_line_coef;
  
    PROCEDURE copy_prod_line_period
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_period dml_t_prod_line_period.typ_associative_array;
    BEGIN
      FOR vr_prod_line_period IN (SELECT *
                                    FROM t_prod_line_period t
                                   WHERE t.product_line_id = par_product_line_from_id)
      LOOP
        vr_prod_line_period.product_line_id := par_product_line_to_id;
        v_prod_line_period(v_prod_line_period.count + 1) := vr_prod_line_period;
      END LOOP;
    
      dml_t_prod_line_period.insert_record_list(par_record_list => v_prod_line_period);
    END copy_prod_line_period;
  
    PROCEDURE copy_prod_claim_control
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_claim_control dml_t_prod_claim_control.typ_associative_array;
    BEGIN
      FOR vr_prod_claim_control IN (SELECT *
                                      FROM t_prod_claim_control t
                                     WHERE t.t_product_line_id = par_product_line_from_id)
      LOOP
        vr_prod_claim_control.t_product_line_id := par_product_line_to_id;
        v_prod_claim_control(v_prod_claim_control.count + 1) := vr_prod_claim_control;
      END LOOP;
    
      dml_t_prod_claim_control.insert_record_list(par_record_list => v_prod_claim_control);
    END copy_prod_claim_control;
  
    PROCEDURE copy_product_line_limit
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_product_line_limit dml_t_product_line_limit.typ_associative_array;
    BEGIN
      FOR vr_product_line_limit IN (SELECT *
                                      FROM t_product_line_limit t
                                     WHERE t.t_product_line_id = par_product_line_from_id)
      LOOP
        vr_product_line_limit.t_product_line_id := par_product_line_to_id;
        v_product_line_limit(v_product_line_limit.count + 1) := vr_product_line_limit;
      END LOOP;
    
      dml_t_product_line_limit.insert_record_list(par_record_list => v_product_line_limit);
    END copy_product_line_limit;
  
    PROCEDURE copy_prod_line_ter
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_ter dml_t_prod_line_ter.typ_associative_array;
    BEGIN
      FOR vr_prod_line_ter IN (SELECT *
                                 FROM t_prod_line_ter t
                                WHERE t.product_line_id = par_product_line_from_id)
      LOOP
        vr_prod_line_ter.product_line_id := par_product_line_to_id;
        v_prod_line_ter(v_prod_line_ter.count + 1) := vr_prod_line_ter;
      END LOOP;
    
      dml_t_prod_line_ter.insert_record_list(par_record_list => v_prod_line_ter);
    END copy_prod_line_ter;
  
    PROCEDURE copy_prod_line_norm
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_norm dml_t_prod_line_norm.typ_associative_array;
    BEGIN
      FOR vr_prod_line_norm IN (SELECT *
                                  FROM t_prod_line_norm t
                                 WHERE t.product_line_id = par_product_line_from_id)
      LOOP
        vr_prod_line_norm.product_line_id := par_product_line_to_id;
        v_prod_line_norm(v_prod_line_norm.count + 1) := vr_prod_line_norm;
      END LOOP;
    
      dml_t_prod_line_norm.insert_record_list(par_record_list => v_prod_line_norm);
    END copy_prod_line_norm;
  
    PROCEDURE copy_prod_line_rate
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_rate dml_t_prod_line_rate.typ_associative_array;
    BEGIN
      FOR vr_prod_line_rate IN (SELECT *
                                  FROM t_prod_line_rate t
                                 WHERE t.product_line_id = par_product_line_from_id)
      LOOP
        vr_prod_line_rate.product_line_id := par_product_line_to_id;
        v_prod_line_rate(v_prod_line_rate.count + 1) := vr_prod_line_rate;
      END LOOP;
    
      dml_t_prod_line_rate.insert_record_list(par_record_list => v_prod_line_rate);
    END copy_prod_line_rate;
  
    PROCEDURE copy_prod_line_met_decl
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_prod_line_met_decl dml_t_prod_line_met_decl.typ_associative_array;
    BEGIN
      FOR vr_prod_line_met_decl IN (SELECT *
                                      FROM t_prod_line_met_decl t
                                     WHERE t.t_prodline_metdec_prod_line_id = par_product_line_from_id)
      LOOP
        vr_prod_line_met_decl.t_prodline_metdec_prod_line_id := par_product_line_to_id;
        v_prod_line_met_decl(v_prod_line_met_decl.count + 1) := vr_prod_line_met_decl;
      END LOOP;
    
      dml_t_prod_line_met_decl.insert_record_list(par_record_list => v_prod_line_met_decl);
    END copy_prod_line_met_decl;
  
    PROCEDURE copy_pline_issuer_doc
    (
      par_product_line_from_id NUMBER
     ,par_product_line_to_id   NUMBER
    ) IS
      v_pline_issuer_doc dml_t_pline_issuer_doc.typ_associative_array;
    BEGIN
      FOR vr_pline_issuer_doc IN (SELECT *
                                    FROM t_pline_issuer_doc t
                                   WHERE t.t_prod_line_id = par_product_line_from_id)
      LOOP
        vr_pline_issuer_doc.t_prod_line_id := par_product_line_to_id;
        v_pline_issuer_doc(v_pline_issuer_doc.count + 1) := vr_pline_issuer_doc;
      END LOOP;
    
      dml_t_pline_issuer_doc.insert_record_list(par_record_list => v_pline_issuer_doc);
    END copy_pline_issuer_doc;
  
    PROCEDURE copy_parent_prod_line(par_product_from_id NUMBER) IS
      v_parent_prod_line dml_parent_prod_line.typ_associative_array;
    BEGIN
      FOR vr_parent_prod_line IN (SELECT ppl.*
                                    FROM t_product_version pv
                                        ,t_product_ver_lob lob
                                        ,parent_prod_line  ppl
                                   WHERE pv.product_id = par_product_from_id
                                     AND pv.t_product_version_id = lob.product_version_id
                                     AND lob.t_product_ver_lob_id = ppl.product_ver_lob_id)
      LOOP
      
        vr_parent_prod_line.t_parent_prod_line_id := vt_plines(vr_parent_prod_line.t_parent_prod_line_id);
        vr_parent_prod_line.t_prod_line_id        := vt_plines(vr_parent_prod_line.t_prod_line_id);
        vr_parent_prod_line.product_ver_lob_id    := vt_ver_lobs(vr_parent_prod_line.product_ver_lob_id);
      
        v_parent_prod_line(v_parent_prod_line.count + 1) := vr_parent_prod_line;
      END LOOP;
    
      dml_parent_prod_line.insert_record_list(par_record_list => v_parent_prod_line);
    END copy_parent_prod_line;
  
    PROCEDURE copy_concurrent_prod_line(par_product_from_id NUMBER) IS
      v_concurrent_prod_line dml_concurrent_prod_line.typ_associative_array;
    BEGIN
      FOR vr_concurrent_prod_line IN (SELECT cpl.*
                                        FROM t_product_version    pv
                                            ,t_product_ver_lob    lob
                                            ,concurrent_prod_line cpl
                                       WHERE pv.product_id = par_product_from_id
                                         AND pv.t_product_version_id = lob.product_version_id
                                         AND lob.t_product_ver_lob_id = cpl.product_ver_lob_id)
      LOOP
      
        vr_concurrent_prod_line.t_concur_product_line_id := vt_plines(vr_concurrent_prod_line.t_concur_product_line_id);
        vr_concurrent_prod_line.t_product_line_id        := vt_plines(vr_concurrent_prod_line.t_product_line_id);
        vr_concurrent_prod_line.product_ver_lob_id       := vt_ver_lobs(vr_concurrent_prod_line.product_ver_lob_id);
      
        v_concurrent_prod_line(v_concurrent_prod_line.count + 1) := vr_concurrent_prod_line;
      END LOOP;
    
      dml_concurrent_prod_line.insert_record_list(par_record_list => v_concurrent_prod_line);
    END copy_concurrent_prod_line;
  
    PROCEDURE copy_curators
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_curator dml_t_product_curator.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_product_curator pc WHERE pc.t_product_id = par_product_from_id)
      LOOP
        rec.t_product_id := par_product_to_id;
        v_product_curator(v_product_curator.count + 1) := rec;
      END LOOP;
    
      dml_t_product_curator.insert_record_list(par_record_list => v_product_curator);
    END copy_curators;
  
    PROCEDURE copy_product_conf_cond
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_conf_cond dml_t_product_conf_cond.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_product_conf_cond pc WHERE pc.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_product_conf_cond(v_product_conf_cond.count + 1) := rec;
      END LOOP;
    
      dml_t_product_conf_cond.insert_record_list(par_record_list => v_product_conf_cond);
    END copy_product_conf_cond;
  
    PROCEDURE copy_product_period
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_period dml_t_product_period.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_product_period t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_product_period(v_product_period.count + 1) := rec;
      END LOOP;
    
      dml_t_product_period.insert_record_list(par_record_list => v_product_period);
    END copy_product_period;
  
    PROCEDURE copy_prod_currency
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_currency dml_t_prod_currency.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_prod_currency t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_prod_currency(v_prod_currency.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_currency.insert_record_list(par_record_list => v_prod_currency);
    END copy_prod_currency;
  
    PROCEDURE copy_prod_pay_curr
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_pay_curr dml_t_prod_pay_curr.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_prod_pay_curr t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_prod_pay_curr(v_prod_pay_curr.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_pay_curr.insert_record_list(par_record_list => v_prod_pay_curr);
    END copy_prod_pay_curr;
  
    PROCEDURE copy_product_cont_type
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_cont_type dml_t_product_cont_type.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_product_cont_type t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_product_cont_type(v_product_cont_type.count + 1) := rec;
      END LOOP;
    
      dml_t_product_cont_type.insert_record_list(par_record_list => v_product_cont_type);
    END copy_product_cont_type;
  
    PROCEDURE copy_prod_sales_chan
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_sales_chan dml_t_prod_sales_chan.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_prod_sales_chan t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_prod_sales_chan(v_prod_sales_chan.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_sales_chan.insert_record_list(par_record_list => v_prod_sales_chan);
    END copy_prod_sales_chan;
  
    PROCEDURE copy_prod_payment_terms
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_payment_terms dml_t_prod_payment_terms.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_prod_payment_terms t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_prod_payment_terms(v_prod_payment_terms.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_payment_terms.insert_record_list(par_record_list => v_prod_payment_terms);
    END copy_prod_payment_terms;
  
    PROCEDURE copy_prod_claim_payterm
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_claim_payterm dml_t_prod_claim_payterm.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_prod_claim_payterm t WHERE t.product_id = par_product_from_id)
      LOOP
        rec.product_id := par_product_to_id;
        v_prod_claim_payterm(v_prod_claim_payterm.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_claim_payterm.insert_record_list(par_record_list => v_prod_claim_payterm);
    END copy_prod_claim_payterm;
  
    PROCEDURE copy_prod_issuer_doc
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_issuer_doc dml_t_prod_issuer_doc.typ_associative_array;
    BEGIN
      FOR rec IN (SELECT * FROM t_prod_issuer_doc t WHERE t.t_product_id = par_product_from_id)
      LOOP
        rec.t_product_id := par_product_to_id;
        v_prod_issuer_doc(v_prod_issuer_doc.count + 1) := rec;
      END LOOP;
    
      dml_t_prod_issuer_doc.insert_record_list(par_record_list => v_prod_issuer_doc);
    END copy_prod_issuer_doc;
  
    PROCEDURE copy_product_discount
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_discount dml_t_product_discount.typ_associative_array;
    BEGIN
      FOR vr_product_discount IN (SELECT *
                                    FROM t_product_discount t
                                   WHERE t.product_id = par_product_from_id)
      LOOP
        vr_product_discount.product_id := par_product_to_id;
        v_product_discount(v_product_discount.count + 1) := vr_product_discount;
      END LOOP;
    
      dml_t_product_discount.insert_record_list(par_record_list => v_product_discount);
    END copy_product_discount;
  
    PROCEDURE copy_prod_payment_order
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_prod_payment_order dml_t_prod_payment_order.typ_associative_array;
    BEGIN
      FOR vr_prod_payment_order IN (SELECT *
                                      FROM t_prod_payment_order t
                                     WHERE t.t_product_id = par_product_from_id)
      LOOP
        vr_prod_payment_order.t_product_id := par_product_to_id;
        v_prod_payment_order(v_prod_payment_order.count + 1) := vr_prod_payment_order;
      END LOOP;
    
      dml_t_prod_payment_order.insert_record_list(par_record_list => v_prod_payment_order);
    END copy_prod_payment_order;
  
    PROCEDURE copy_product_bso_types
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_bso_types dml_t_product_bso_types.typ_associative_array;
    BEGIN
      FOR vr_product_bso_types IN (SELECT *
                                     FROM t_product_bso_types t
                                    WHERE t.t_product_id = par_product_from_id)
      LOOP
        vr_product_bso_types.t_product_id := par_product_to_id;
        v_product_bso_types(v_product_bso_types.count + 1) := vr_product_bso_types;
      END LOOP;
    
      dml_t_product_bso_types.insert_record_list(par_record_list => v_product_bso_types);
    END copy_product_bso_types;
  
    PROCEDURE copy_product_decline
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_decline dml_t_product_decline.typ_associative_array;
    BEGIN
      FOR vr_product_decline IN (SELECT *
                                   FROM t_product_decline t
                                  WHERE t.t_product_id = par_product_from_id)
      LOOP
        vr_product_decline.t_product_id := par_product_to_id;
        v_product_decline(v_product_decline.count + 1) := vr_product_decline;
      END LOOP;
    
      dml_t_product_decline.insert_record_list(par_record_list => v_product_decline);
    END copy_product_decline;
  
    PROCEDURE copy_product_ter
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_ter dml_t_product_ter.typ_associative_array;
    BEGIN
      FOR vr_product_ter IN (SELECT * FROM t_product_ter t WHERE t.product_id = par_product_from_id)
      LOOP
        vr_product_ter.product_id := par_product_to_id;
        v_product_ter(v_product_ter.count + 1) := vr_product_ter;
      END LOOP;
    
      dml_t_product_ter.insert_record_list(par_record_list => v_product_ter);
    END copy_product_ter;
  
    PROCEDURE copy_policyform_product
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_policyform_product dml_t_policyform_product.typ_associative_array;
    BEGIN
      FOR vr_policyform_product IN (SELECT *
                                      FROM t_policyform_product t
                                     WHERE t.t_product_id = par_product_from_id)
      LOOP
        vr_policyform_product.t_product_id := par_product_to_id;
        vr_policyform_product.user_id := safety.curr_sys_user;
        v_policyform_product(v_policyform_product.count + 1) := vr_policyform_product;
      END LOOP;
    
      dml_t_policyform_product.insert_record_list(par_record_list => v_policyform_product);
    END copy_policyform_product;
  
    PROCEDURE copy_product_ext_system
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_ext_system dml_t_product_ext_system.typ_associative_array;
    BEGIN
      FOR vr_product_ext_system IN (SELECT *
                                      FROM t_product_ext_system t
                                     WHERE t.product_id = par_product_from_id)
      LOOP
        vr_product_ext_system.product_id := par_product_to_id;
        v_product_ext_system(v_product_ext_system.count + 1) := vr_product_ext_system;
      END LOOP;
    
      dml_t_product_ext_system.insert_record_list(par_record_list => v_product_ext_system);
    END copy_product_ext_system;
  
    PROCEDURE copy_product_categories
    (
      par_product_from_id NUMBER
     ,par_product_to_id   NUMBER
    ) IS
      v_product_prod_cat dml_t_product_prod_cat.typ_associative_array;
    BEGIN
      FOR vr_product_prod_cat IN (SELECT *
                                    FROM t_product_prod_cat t
                                   WHERE t.t_product_id = par_product_from_id)
      LOOP
        vr_product_prod_cat.t_product_id := par_product_to_id;
        v_product_prod_cat(v_product_prod_cat.count + 1) := vr_product_prod_cat;
      END LOOP;
    
      dml_t_product_prod_cat.insert_record_list(par_record_list => v_product_prod_cat);
    END copy_product_categories;
  
  BEGIN
    /* Продукт */
    v_product             := dml_t_product.get_record(par_product_from_id);
    v_product.description := par_product_name;
    v_product.brief       := par_product_brief;
  
    dml_t_product.insert_record(par_record => v_product);
  
    -- Структура продукта
    -- Версии продукта
    FOR vr_version IN (SELECT * FROM t_product_version WHERE product_id = par_product_from_id)
    LOOP
    
      v_product_version            := vr_version;
      v_product_version.product_id := v_product.product_id;
    
      dml_t_product_version.insert_record(par_record => v_product_version);
      v_product_version.t_product_version_id := v_product_version.t_product_version_id;
    
      -- Контроль продукта
      copy_product_version_control(vr_version.t_product_version_id
                                  ,v_product_version.t_product_version_id);
    
      -- Правила по продукту
      FOR vr_ver_lob IN (SELECT *
                           FROM t_product_ver_lob
                          WHERE product_version_id = vr_version.t_product_version_id)
      LOOP
        v_product_ver_lob                    := vr_ver_lob;
        v_product_ver_lob.product_version_id := v_product_version.t_product_version_id;
      
        dml_t_product_ver_lob.insert_record(par_record => v_product_ver_lob);
      
        -- Накапливаем id, старые и новые, чтобы использовать потом ниже
        vt_ver_lobs(vr_ver_lob.t_product_ver_lob_id) := v_product_ver_lob.t_product_ver_lob_id;
      
        -- Программы в продукте
        FOR vr_pline IN (SELECT *
                           FROM t_product_line
                          WHERE product_ver_lob_id = vr_ver_lob.t_product_ver_lob_id)
        LOOP
        
          v_product_line                    := vr_pline;
          v_product_line.product_ver_lob_id := v_product_ver_lob.t_product_ver_lob_id;
        
          dml_t_product_line.insert_record(par_record => v_product_line);
        
          -- Накапливаем id, старые и новые, чтобы использовать потом ниже
          vt_plines(vr_pline.id) := v_product_line.id;
          -- Группы Рисков
          copy_prod_line_opts(vr_pline.id, v_product_line.id);
        
          -- Франшиза
          copy_prod_line_deduct(vr_pline.id, v_product_line.id);
        
          -- Виды объектов
          copy_as_type_prod_line(vr_pline.id, v_product_line.id);
        
          -- Коэф. тарифа
          copy_prod_line_coef(vr_pline.id, v_product_line.id);
        
          -- Период
          copy_prod_line_period(vr_pline.id, v_product_line.id);
        
          -- Контроль претензии
          copy_prod_claim_control(vr_pline.id, v_product_line.id);
        
          -- Контроль покрытия
          copy_product_line_limit(vr_pline.id, v_product_line.id);
        
          -- Территории
          copy_prod_line_ter(vr_pline.id, v_product_line.id);
        
          -- Норма доходности
          copy_prod_line_norm(vr_pline.id, v_product_line.id);
        
          -- Справочник смертности
          copy_prod_line_rate(vr_pline.id, v_product_line.id);
        
          -- Алгоритм ЗСП
          copy_prod_line_met_decl(vr_pline.id, v_product_line.id);
        
          -- Документы
          copy_pline_issuer_doc(vr_pline.id, v_product_line.id);
        END LOOP vr_pline;
      END LOOP vr_ver_lob;
    END LOOP vr_version;
  
    -- Зависимость
    -- Родительская программа
    copy_parent_prod_line(par_product_from_id);
  
    -- Конкурирующая программа
    copy_concurrent_prod_line(par_product_from_id);
  
    -- Кураторы
    copy_curators(par_product_from_id, v_product.product_id);
  
    -- Условия вступления в силу
    copy_product_conf_cond(par_product_from_id, v_product.product_id);
  
    -- Период действия
    copy_product_period(par_product_from_id, v_product.product_id);
  
    -- Валюта
    -- Валюта ответственности
    copy_prod_currency(par_product_from_id, v_product.product_id);
  
    -- Валюта платежа
    copy_prod_pay_curr(par_product_from_id, v_product.product_id);
  
    -- Контакты и каналы
    -- Тип контакта
    copy_product_cont_type(par_product_from_id, v_product.product_id);
  
    -- Каналы
    copy_prod_sales_chan(par_product_from_id, v_product.product_id);
  
    -- Платежи
    copy_prod_payment_terms(par_product_from_id, v_product.product_id);
  
    -- Выплаты
    copy_prod_claim_payterm(par_product_from_id, v_product.product_id);
  
    -- Документы
    copy_prod_issuer_doc(par_product_from_id, v_product.product_id);
  
    -- Скидки
    copy_product_discount(par_product_from_id, v_product.product_id);
  
    -- Типы доп. соглашений
    FOR vr_padd IN (SELECT * FROM t_product_addendum WHERE t_product_id = par_product_from_id)
    LOOP
    
      copy_addendum_type(par_dest_product_id  => v_product.product_id
                        ,par_addendum_type_id => vr_padd.t_addendum_type_id
                        ,par_src_product_id   => par_product_from_id);
    
    END LOOP vr_padd;
    -- Порядок выплаты
    copy_prod_payment_order(par_product_from_id, v_product.product_id);
  
    -- Типы БСО
    copy_product_bso_types(par_product_from_id, v_product.product_id);
  
    -- Расторжение
    copy_product_decline(par_product_from_id, v_product.product_id);
  
    -- Территория действия
    copy_product_ter(par_product_from_id, v_product.product_id);
  
    -- Полисные условия
    --copy_product_conds(par_product_from_id,v_product.product_id);
  
    copy_policyform_product(par_product_from_id, v_product.product_id);
  
    -- копируем настройки интеграции
    copy_product_ext_system(par_product_from_id, v_product.product_id);
  
    -- Копирование категорий продукта
    copy_product_categories(par_product_from_id, v_product.product_id);
  
    -- Анкеты
    FOR rec IN (SELECT * FROM t_q_quest_form_type t WHERE t.product_id = par_product_from_id)
    LOOP
      DECLARE
        v_quest_form_type dml_t_q_quest_form_type.tt_t_q_quest_form_type;
        v_pl_questions    dml_t_q_pl_questions.tt_t_q_pl_questions;
        vr_questions      tt_ids;
      BEGIN
        v_quest_form_type            := rec;
        v_quest_form_type.product_id := v_product.product_id;
      
        dml_t_q_quest_form_type.insert_record(par_record => v_quest_form_type);
      
        FOR rec_q IN (SELECT *
                        FROM t_q_pl_questions t
                      CONNECT BY PRIOR t.t_q_pl_questions_id = t.parent_pl_question_id
                       START WITH t.parent_pl_question_id IS NULL
                              AND t.t_quest_form_type_id = rec.t_q_quest_form_type_id
                       ORDER BY LEVEL)
        LOOP
        
          v_pl_questions                      := rec_q;
          v_pl_questions.t_prod_line_id       := vt_plines(rec_q.t_prod_line_id);
          v_pl_questions.t_quest_form_type_id := v_quest_form_type.t_q_quest_form_type_id;
        
          IF rec_q.parent_pl_question_id IS NOT NULL
          THEN
            v_pl_questions.parent_pl_question_id := vr_questions(rec_q.parent_pl_question_id);
          END IF;
        
          dml_t_q_pl_questions.insert_record(par_record => v_pl_questions);
        
          -- Анкеты по программам
          vr_questions(rec_q.t_q_pl_questions_id) := v_pl_questions.t_q_pl_questions_id;
        
        END LOOP;
      
      END;
    END LOOP;
  
  END copy_product;

  /* Перегруженный вариант
  * @autor - Капля П. с.
  * @param par_product_from_brief - бриф продукта с которого копируем
  * @param par_product_to_brief   - брфи продукта в котором создаем копию программы
  * @param par_product_line_name  - название копируемой программы у par_product_from_id
  */
  PROCEDURE copy_program_by_product
  (
    par_product_from_brief VARCHAR2
   ,par_product_to_brief   VARCHAR2
   ,par_product_line_name  VARCHAR2
  ) IS
    v_product_from_id NUMBER;
    v_product_to_id   NUMBER;
    v_product_line_id NUMBER;
  BEGIN
    IF par_product_from_brief != par_product_to_brief
    THEN
      v_product_from_id := get_product_id(par_product_from_brief);
      v_product_to_id   := get_product_id(par_product_to_brief);
    
      v_product_line_id := get_product_line_id(par_product_brief     => par_product_from_brief
                                              ,par_product_line_desc => par_product_line_name);
    
      copy_program_by_product(par_product_from_id => v_product_from_id
                             ,par_product_to_id   => v_product_to_id
                             ,par_product_line_id => v_product_line_id);
    END IF;
  END;

  /* Копирует программу из другого продукта
  * @autor - Чирков В. Ю.
  * @param par_product_from_id - продукт с которого копируем
  * @param par_product_to_id   - id продукта в котором создаем копию программы
  * @param par_product_line_id - id копируемой программы у par_product_from_id
  */
  PROCEDURE copy_program_by_product
  (
    par_product_from_id NUMBER
   ,par_product_to_id   NUMBER
   ,par_product_line_id NUMBER
  ) IS
    TYPE tt_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  
    vt_plines                tt_ids;
    vt_ver_lobs              tt_ids;
    v_product_version_id     NUMBER;
    v_product_ver_lob_id     NUMBER;
    v_product_line_id        NUMBER;
    v_prod_line_option_id    NUMBER;
    v_prod_line_opt_peril_id NUMBER;
    v_prod_line_contact_id   NUMBER;
    v_prod_line_coef_id      NUMBER;
  BEGIN
  
    -- Структура продукта
    -- Версии продукта
  
    FOR vr_version IN (SELECT * FROM ven_t_product_version WHERE product_id = par_product_from_id)
    LOOP
    
      vr_version.product_id := par_product_to_id;
      v_product_version_id  := vr_version.t_product_version_id;
      --Находим версию создаваемого продукта
      SELECT pv.t_product_version_id
        INTO vr_version.t_product_version_id
        FROM ven_t_product_version pv
       WHERE pv.product_id = par_product_to_id;
    
      -- Правила по продукту
      FOR vr_ver_lob IN (SELECT *
                           FROM ven_t_product_ver_lob pvl
                          WHERE pvl.product_version_id = v_product_version_id
                            AND pvl.t_product_ver_lob_id =
                                (SELECT pl.product_ver_lob_id
                                   FROM t_product_line pl
                                  WHERE pl.id = par_product_line_id))
      LOOP
        vr_ver_lob.product_version_id := vr_version.t_product_version_id;
        v_product_ver_lob_id          := vr_ver_lob.t_product_ver_lob_id;
      
        --находим в добавляемой версии продукта, правило программы которую добавляем
        BEGIN
          SELECT pvl.t_product_ver_lob_id
            INTO vr_ver_lob.t_product_ver_lob_id
            FROM t_product             pr
                ,t_product_version     tpv
                ,ven_t_product_ver_lob pvl
           WHERE pr.product_id = tpv.product_id
             AND pr.product_id = par_product_to_id
             AND tpv.t_product_version_id = pvl.product_version_id
             AND pvl.lob_id = vr_ver_lob.lob_id;
        EXCEPTION
          WHEN no_data_found THEN
            --если правила нет то создаем его
            SELECT sq_t_product_ver_lob.nextval INTO vr_ver_lob.t_product_ver_lob_id FROM dual;
            INSERT INTO ven_t_product_ver_lob VALUES vr_ver_lob;
        END;
      
        -- Накапливаем id, старые и новые, чтобы использовать потом ниже
        vt_ver_lobs(v_product_ver_lob_id) := vr_ver_lob.t_product_ver_lob_id;
      
        -- Программы в продукте
        FOR vr_pline IN (SELECT *
                           FROM ven_t_product_line pl
                          WHERE product_ver_lob_id = v_product_ver_lob_id
                            AND pl.id = par_product_line_id)
        LOOP
          vr_pline.product_ver_lob_id := vr_ver_lob.t_product_ver_lob_id;
          v_product_line_id           := vr_pline.id;
          SELECT sq_t_product_line.nextval INTO vr_pline.id FROM dual;
          INSERT INTO ven_t_product_line VALUES vr_pline;
          -- Накапливаем id, старые и новые, чтобы использовать потом ниже
          vt_plines(v_product_line_id) := vr_pline.id;
          -- Риски
          FOR vr_plineo IN (SELECT *
                              FROM ven_t_prod_line_option
                             WHERE product_line_id = v_product_line_id)
          LOOP
            vr_plineo.product_line_id := vr_pline.id;
            v_prod_line_option_id     := vr_plineo.id;
            SELECT sq_t_prod_line_option.nextval INTO vr_plineo.id FROM dual;
            INSERT INTO ven_t_prod_line_option VALUES vr_plineo;
          
            -- Агрегация
            INSERT INTO ven_t_agr_custom
              SELECT NULL /*t_agr_custom_id*/
                    ,ent_id
                    ,filial_id
                    ,ext_id
                    ,department_id
                    ,t_agr_custom_group_id
                    ,t_agr_limit_group_id
                    ,t_asset_type_id
                    ,vr_plineo.id
               FROM ven_t_agr_custom
              WHERE t_prod_line_option_id = v_prod_line_option_id;

            -- Риски группы
            FOR vr_plineop IN (SELECT *
                                 FROM ven_t_prod_line_opt_peril
                                WHERE product_line_option_id = v_prod_line_option_id)
            LOOP
              vr_plineop.product_line_option_id := vr_plineo.id;
              v_prod_line_opt_peril_id          := vr_plineop.id;
              SELECT sq_t_prod_line_opt_peril.nextval INTO vr_plineop.id FROM dual;
              INSERT INTO ven_t_prod_line_opt_peril VALUES vr_plineop;
            
              -- Коды ущерба
              INSERT INTO ven_t_prod_line_damage
                SELECT NULL /*t_prod_line_damage_id*/
                      ,ent_id
                      ,filial_id
                      ,ext_id
                      ,is_excluded
                      ,LIMIT
                      ,t_damage_code_id
                      ,vr_plineop.id /*t_prod_line_opt_peril_id*/
                  FROM ven_t_prod_line_damage
                 WHERE t_prod_line_opt_peril_id = v_prod_line_opt_peril_id;
            END LOOP vr_plineop;
          END LOOP vr_plineo;
        
          -- Франшиза
          INSERT INTO ven_t_prod_line_deduct
            SELECT NULL /*id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,deductible_rel_id
                  ,default_value
                  ,is_default
                  ,is_handchange_enabled
                  ,vr_pline.id /*product_line_id*/
              FROM ven_t_prod_line_deduct
             WHERE product_line_id = v_product_line_id;
          -- Виды объектов
          INSERT INTO ven_t_as_type_prod_line
            SELECT NULL /*t_as_type_prod_line_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,asset_common_type_id
                  ,ins_amount_func_id
                  ,is_ins_amount_agregate
                  ,is_ins_amount_date
                  ,is_ins_fee_agregate
                  ,is_ins_prem_agregate
                  ,is_insured
                  ,vr_pline.id /*product_line_id*/
              FROM ven_t_as_type_prod_line
             WHERE product_line_id = v_product_line_id;
          -- Коэф. тарифа
          FOR vr_plinecf IN (SELECT *
                               FROM ven_t_prod_line_coef
                              WHERE t_product_line_id = v_product_line_id)
          LOOP
            v_prod_line_coef_id          := vr_plinecf.t_prod_line_coef_id;
            vr_plinecf.t_product_line_id := vr_pline.id;
            SELECT sq_t_prod_line_coef.nextval INTO vr_plinecf.t_prod_line_coef_id FROM dual;
            INSERT INTO ven_t_prod_line_coef VALUES vr_plinecf;
            -- Ограничения
            INSERT INTO ven_t_prod_line_coef_saf
              SELECT NULL /*t_prod_line_coef_saf_id*/
                    ,ent_id
                    ,filial_id
                    ,ext_id
                    ,comments
                    ,is_update_allowed
                    ,safety_right_id
                    ,vr_plinecf.t_prod_line_coef_id /*t_prod_line_coef_id*/
                FROM ven_t_prod_line_coef_saf
               WHERE t_prod_line_coef_id = v_prod_line_coef_id;
          END LOOP;
        
          -- Период
          INSERT INTO ven_t_prod_line_period
            SELECT NULL /*t_prod_line_period_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,control_func_id
                  ,is_default
                  ,is_disabled
                  ,period_id
                  ,vr_pline.id /*product_line_id*/
                  ,sort_order
                  ,t_period_use_type_id
              FROM ven_t_prod_line_period
             WHERE product_line_id = v_product_line_id;
          -- Контроль претензии
          INSERT INTO ven_t_prod_claim_control
            SELECT NULL /*t_prod_claim_control_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,comments
                  ,control_func_id
                  ,is_disabled
                  ,sort_order
                  ,vr_pline.id /*t_product_line_id*/
              FROM ven_t_prod_claim_control
             WHERE t_product_line_id = v_product_line_id;
          -- Контроль покрытия
          INSERT INTO ven_t_product_line_limit
            SELECT NULL /*t_product_line_limit_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,comments
                  ,is_precreation_check
                  ,is_underwriting_check
                  ,limit_func_id
                  ,message
                  ,sort_order
                  ,vr_pline.id /*t_product_line_id*/
              FROM ven_t_product_line_limit
             WHERE t_product_line_id = v_product_line_id;
        
          FOR vr_plinec IN (SELECT *
                              FROM ven_t_prod_line_contact
                             WHERE product_line_id = v_product_line_id)
          LOOP
            -- Контакты
            -- Контакты
            vr_plinec.product_line_id := vr_pline.id;
            v_prod_line_contact_id    := vr_plinec.t_prod_line_contact_id;
          
            SELECT sq_t_prod_line_contact.nextval INTO vr_plinec.t_prod_line_contact_id FROM dual;
            INSERT INTO ven_t_prod_line_contact VALUES vr_plinec;
            -- Типы помощи
            INSERT INTO ven_t_prod_line_aid
              SELECT NULL /*t_prod_line_aid_id*/
                    ,ent_id
                    ,filial_id
                    ,ext_id
                    ,dms_aid_type_id
                    ,vr_plinec.t_prod_line_contact_id /*t_prod_line_contact_id*/
                FROM ven_t_prod_line_aid
               WHERE t_prod_line_contact_id = v_prod_line_contact_id;
          END LOOP vr_plinec;
        
          -- Территории
          INSERT INTO ven_t_prod_line_ter
            SELECT NULL /*t_prod_line_ter_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,vr_pline.id /*product_line_id*/
                  ,t_territory_id
              FROM ven_t_prod_line_ter
             WHERE product_line_id = v_product_line_id;
          -- Норма доходности
          INSERT INTO ven_t_prod_line_norm
            (t_prod_line_norm_id
            ,ent_id
            ,filial_id
            ,ext_id
            ,is_default
            ,normrate_id
            ,note
            ,product_line_id
            ,VALUE)
            SELECT NULL /*t_prod_line_norm_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,is_default
                  ,normrate_id
                  ,note
                  ,vr_pline.id
                  ,VALUE
              FROM ven_t_prod_line_norm
             WHERE product_line_id = v_product_line_id;
          -- Справочник смертности
          INSERT INTO ven_t_prod_line_rate
            SELECT NULL /*t_prod_line_rate_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,deathrate_id
                  ,func_id
                  ,vr_pline.id
              FROM ven_t_prod_line_rate
             WHERE product_line_id = v_product_line_id;
          -- Алгоритм ЗСП
          INSERT INTO ven_t_prod_line_met_decl
            SELECT NULL /*t_prod_line_met_decl_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,is_default
                  ,t_prodline_metdec_met_decl_id
                  ,vr_pline.id
              FROM ven_t_prod_line_met_decl
             WHERE t_prodline_metdec_prod_line_id = v_product_line_id;
        
          -- Документы
          INSERT INTO ven_t_pline_issuer_doc
            SELECT NULL /*t_pline_issuer_doc_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,is_required
                  ,sort_order
                  ,t_issuer_doc_type_id
                  ,vr_pline.id /*t_prod_line_id*/
              FROM ven_t_pline_issuer_doc
             WHERE t_prod_line_id = v_product_line_id;
          -- Анкеты
          INSERT INTO ven_t_q_pl_questions
            SELECT NULL /*t_q_pl_questions_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,check_falirue_msg
                  ,check_value_func
                  ,default_can_change
                  ,default_value
                  ,default_value_func
                  ,enabled
                  ,is_group
                  ,is_main_check
                  ,max_value
                  ,max_value_func
                  ,min_value
                  ,min_value_func
                  ,parent_pl_question_id
                  ,sort_order
                  ,vr_pline.id /*t_prod_line_id*/
                  ,t_q_question_id
                  ,t_quest_form_type_id
              FROM ven_t_q_pl_questions
             WHERE t_prod_line_id = v_product_line_id;
        END LOOP vr_pline;
      END LOOP vr_ver_lob;
    END LOOP vr_version;
  
  END copy_program_by_product;

  /* Копирует только продукт без программ
  * @autor - Чирков В. Ю.
  * @param par_product_from_id - продукт с которого копируем
  * @param par_product_name    - имя нового продукта
  * @param par_product_brief   - сокр. наименование нового продукта
  */
  PROCEDURE copy_only_product
  (
    par_product_from_id NUMBER
   ,par_product_name    VARCHAR2
   ,par_product_brief   VARCHAR2
  ) IS
    v_product_id          NUMBER;
    v_product_version_id  NUMBER;
    v_product_addendum_id NUMBER;
  BEGIN
    /* Продукт */
    SELECT sq_t_product.nextval INTO v_product_id FROM dual;
    INSERT INTO ven_t_product
      (product_id
      ,ent_id
      ,filial_id
      ,ext_id
      ,asset_form
      ,brief
      ,bso_type_id
      ,claim_department_id
      ,claim_dept_role_id
      ,department_id
      ,dept_role_id
      ,description
      ,enabled
      ,ins_amount_func_id
      ,is_bso_polnum
      ,is_express
      ,is_group
      ,serial_policy
      ,t_policy_form_type_id
      ,t_product_group_id
      ,use_ids_as_number)
      SELECT v_product_id
            , /*product_id, */ent_id
            ,filial_id
            ,ext_id
            ,asset_form
            ,par_product_brief /*brief*/
            ,bso_type_id
            ,claim_department_id
            ,claim_dept_role_id
            ,department_id
            ,dept_role_id
            , /*description*/par_product_name
            ,enabled
            ,ins_amount_func_id
            ,is_bso_polnum
            ,is_express
            ,is_group
            ,serial_policy
            ,t_policy_form_type_id
            ,t_product_group_id
            ,use_ids_as_number
        FROM ven_t_product pr
       WHERE pr.product_id = par_product_from_id;
  
    -- Структура продукта
    -- Версии продукта
    FOR vr_version IN (SELECT * FROM ven_t_product_version WHERE product_id = par_product_from_id)
    LOOP
      vr_version.product_id := v_product_id;
      v_product_version_id  := vr_version.t_product_version_id;
      SELECT sq_t_product_version.nextval INTO vr_version.t_product_version_id FROM dual;
      INSERT INTO ven_t_product_version VALUES vr_version;
      -- Контроль продукта
      INSERT INTO ven_t_product_control
        SELECT NULL /*t_product_control_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,comments
              ,control_func_id
              ,is_underwriting_check
              ,message
              ,sort_order
              ,vr_version.t_product_version_id
          FROM ven_t_product_control pc
         WHERE pc.t_product_version_id = v_product_version_id;
    
    END LOOP vr_version;
  
    -- Кураторы
    INSERT INTO ven_t_product_curator
      SELECT NULL /*t_product_curator_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,department_id
            ,employee_id
            ,is_default
            ,organisation_tree_id
            ,v_product_id /*t_product_id*/
        FROM ven_t_product_curator
       WHERE t_product_id = par_product_from_id;
    -- Условия вступления в силу
    INSERT INTO ven_t_product_conf_cond
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,confirm_condition_id
            ,is_default
            ,v_product_id /*product_id*/
        FROM ven_t_product_conf_cond
       WHERE product_id = par_product_from_id;
    -- Период действия
    INSERT INTO ven_t_product_period
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,control_func_id
            ,is_default
            ,period_id
            ,v_product_id /*product_id*/
            ,sort_order
            ,t_period_use_type_id
        FROM ven_t_product_period
       WHERE product_id = par_product_from_id;
    -- Валюта
    -- Валюта ответственности
    INSERT INTO ven_t_prod_currency
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,currency_id
            ,is_default
            ,v_product_id /*product_id*/
        FROM ven_t_prod_currency
       WHERE product_id = par_product_from_id;
    -- Валюта платежа
    INSERT INTO ven_t_prod_pay_curr
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,currency_id
            ,is_default
            ,v_product_id /*product_id*/
        FROM ven_t_prod_pay_curr
       WHERE product_id = par_product_from_id;
    -- Контакты и каналы
    -- Тип контакта
    INSERT INTO ven_t_product_cont_type
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,contact_type_id
            ,v_product_id /*product_id*/
        FROM ven_t_product_cont_type
       WHERE product_id = par_product_from_id;
    -- Каналы
    INSERT INTO ven_t_prod_sales_chan
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,is_default
            ,v_product_id /*product_id*/
            ,sales_channel_id
        FROM ven_t_prod_sales_chan
       WHERE product_id = par_product_from_id;
    -- Платежи
    INSERT INTO ven_t_prod_payment_terms
      SELECT NULL /*id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,collection_method_id
            ,is_default
            ,payment_term_id
            ,v_product_id /*product_id*/
        FROM ven_t_prod_payment_terms
       WHERE product_id = par_product_from_id;
    -- Выплаты
    INSERT INTO ven_t_prod_claim_payterm
      SELECT NULL /*t_prod_claim_payterm_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,collection_method_id
            ,is_default
            ,payment_terms_id
            ,v_product_id /*product_id*/
        FROM ven_t_prod_claim_payterm
       WHERE product_id = par_product_from_id;
    -- Документы
    INSERT INTO ven_t_prod_issuer_doc
      SELECT NULL /*t_prod_issuer_doc_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,is_required
            ,sort_order
            ,t_issuer_doc_type_id
            ,v_product_id /*t_product_id*/
        FROM ven_t_prod_issuer_doc
       WHERE t_product_id = par_product_from_id;
    -- Скидки
    INSERT INTO ven_t_product_discount
      SELECT NULL /*t_prod_issuer_doc_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,t.discount_id
            ,t.is_active
            ,t.is_default
            ,v_product_id /*t_product_id*/
            ,t.sort_order
        FROM ven_t_product_discount t
       WHERE product_id = par_product_from_id;
    -- Типы доп. соглашений
    FOR vr_padd IN (SELECT * FROM ven_t_product_addendum WHERE t_product_id = par_product_from_id)
    LOOP
      v_product_addendum_id := vr_padd.t_product_addendum_id;
      vr_padd.t_product_id  := v_product_id;
      SELECT sq_t_product_addendum.nextval INTO vr_padd.t_product_addendum_id FROM dual;
      INSERT INTO ven_t_product_addendum VALUES vr_padd;
      -- Функции
      INSERT INTO ven_t_product_add_func
        SELECT NULL /*t_product_add_func_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,comments
              ,func_id
              ,sort_order
              ,vr_padd.t_product_addendum_id /*t_product_addendum_id*/
              ,v_product_id /*t_product_id*/
          FROM ven_t_product_add_func
         WHERE t_product_addendum_id = v_product_addendum_id;
    END LOOP vr_padd;
    -- Порядок выплаты
    INSERT INTO ven_t_prod_payment_order
      SELECT NULL /*t_prod_payment_order_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,is_default
            ,t_payment_order_id
            ,v_product_id /*t_product_id*/
        FROM ven_t_prod_payment_order
       WHERE t_product_id = par_product_from_id;
    -- Типы БСО
    INSERT INTO ven_t_product_bso_types
      SELECT NULL /*t_product_bso_types_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,bso_type_id
            ,v_product_id /*t_product_id*/
        FROM ven_t_product_bso_types
       WHERE t_product_id = par_product_from_id;
    -- Расторжение
    INSERT INTO ven_t_product_decline
      SELECT NULL /*t_product_decline_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,t_decline_reason_id
            ,v_product_id /*t_product_id*/
        FROM ven_t_product_decline
       WHERE t_product_id = par_product_from_id;
    -- Территория действия
    INSERT INTO ven_t_product_ter
      SELECT NULL /*t_product_ter_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,v_product_id /*product_id*/
            ,t_territory_id
        FROM ven_t_product_ter
       WHERE product_id = par_product_from_id;
    -- Анкеты
    INSERT INTO ven_t_q_quest_form_type
      SELECT NULL /*t_q_quest_form_type_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,brief
            ,common_type
            ,date_begin
            ,date_end
            ,description
            ,v_product_id /*product_id*/
        FROM ven_t_q_quest_form_type
       WHERE product_id = par_product_from_id;
    -- Полисные условия
    INSERT INTO ven_t_product_conds
      (t_product_conds_id
      ,ent_id
      ,filial_id
      ,ext_id
      ,date_from
      ,date_to
      ,description
      ,t_product_id
      ,user_name)
      SELECT NULL /*t_product_conds_id*/
            ,ent_id
            ,filial_id
            ,ext_id
            ,date_from
            ,date_to
            ,description
            ,v_product_id /*t_product_id*/
            ,USER
        FROM ven_t_product_conds
       WHERE t_product_id = par_product_from_id;
  END copy_only_product;

  PROCEDURE copy_program_by_prod_ver_lob
  (
    par_product_ver_lob_from_id NUMBER
   ,par_product_ver_lob_to_id   NUMBER
   ,par_product_line_id         NUMBER
  ) IS
    TYPE tt_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  
    vt_plines                tt_ids;
    v_product_line_id        NUMBER;
    v_prod_line_option_id    NUMBER;
    v_prod_line_opt_peril_id NUMBER;
    v_prod_line_contact_id   NUMBER;
    v_prod_line_coef_id      NUMBER;
  BEGIN
  
    -- Программы в продукте
    FOR vr_pline IN (SELECT *
                       FROM ven_t_product_line pl
                      WHERE product_ver_lob_id = par_product_ver_lob_from_id
                        AND pl.id = par_product_line_id)
    LOOP
      vr_pline.product_ver_lob_id := par_product_ver_lob_to_id;
      v_product_line_id           := vr_pline.id;
      SELECT sq_t_product_line.nextval INTO vr_pline.id FROM dual;
      INSERT INTO ven_t_product_line VALUES vr_pline;
      -- Накапливаем id, старые и новые, чтобы использовать потом ниже
      vt_plines(v_product_line_id) := vr_pline.id;
      -- Риски
      FOR vr_plineo IN (SELECT * FROM ven_t_prod_line_option WHERE product_line_id = v_product_line_id)
      LOOP
        vr_plineo.product_line_id := vr_pline.id;
        v_prod_line_option_id     := vr_plineo.id;
        SELECT sq_t_prod_line_option.nextval INTO vr_plineo.id FROM dual;
        INSERT INTO ven_t_prod_line_option VALUES vr_plineo;
      
        -- Агрегация
        INSERT INTO ven_t_agr_custom
          SELECT NULL /*t_agr_custom_id*/
                ,ent_id
                ,filial_id
                ,ext_id
                ,department_id
                ,t_agr_custom_group_id
                ,t_agr_limit_group_id
                ,t_asset_type_id
                ,vr_plineo.id
           FROM ven_t_agr_custom
          WHERE t_prod_line_option_id = v_prod_line_option_id;

        -- Риски группы
        FOR vr_plineop IN (SELECT *
                             FROM ven_t_prod_line_opt_peril
                            WHERE product_line_option_id = v_prod_line_option_id)
        LOOP
          vr_plineop.product_line_option_id := vr_plineo.id;
          v_prod_line_opt_peril_id          := vr_plineop.id;
          SELECT sq_t_prod_line_opt_peril.nextval INTO vr_plineop.id FROM dual;
          INSERT INTO ven_t_prod_line_opt_peril VALUES vr_plineop;
        
          -- Коды ущерба
          INSERT INTO ven_t_prod_line_damage
            SELECT NULL /*t_prod_line_damage_id*/
                  ,ent_id
                  ,filial_id
                  ,ext_id
                  ,is_excluded
                  ,LIMIT
                  ,t_damage_code_id
                  ,vr_plineop.id /*t_prod_line_opt_peril_id*/
              FROM ven_t_prod_line_damage
             WHERE t_prod_line_opt_peril_id = v_prod_line_opt_peril_id;
        END LOOP vr_plineop;
      END LOOP vr_plineo;
    
      -- Франшиза
      INSERT INTO ven_t_prod_line_deduct
        SELECT NULL /*id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,deductible_rel_id
              ,default_value
              ,is_default
              ,is_handchange_enabled
              ,vr_pline.id /*product_line_id*/
          FROM ven_t_prod_line_deduct
         WHERE product_line_id = v_product_line_id;
      -- Виды объектов
      INSERT INTO ven_t_as_type_prod_line
        SELECT NULL /*t_as_type_prod_line_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,asset_common_type_id
              ,ins_amount_func_id
              ,is_ins_amount_agregate
              ,is_ins_amount_date
              ,is_ins_fee_agregate
              ,is_ins_prem_agregate
              ,is_insured
              ,vr_pline.id /*product_line_id*/
          FROM ven_t_as_type_prod_line
         WHERE product_line_id = v_product_line_id;
      -- Коэф. тарифа
      FOR vr_plinecf IN (SELECT * FROM ven_t_prod_line_coef WHERE t_product_line_id = v_product_line_id)
      LOOP
        v_prod_line_coef_id          := vr_plinecf.t_prod_line_coef_id;
        vr_plinecf.t_product_line_id := vr_pline.id;
        SELECT sq_t_prod_line_coef.nextval INTO vr_plinecf.t_prod_line_coef_id FROM dual;
        INSERT INTO ven_t_prod_line_coef VALUES vr_plinecf;
        -- Ограничения
        INSERT INTO ven_t_prod_line_coef_saf
          SELECT NULL /*t_prod_line_coef_saf_id*/
                ,ent_id
                ,filial_id
                ,ext_id
                ,comments
                ,is_update_allowed
                ,safety_right_id
                ,vr_plinecf.t_prod_line_coef_id /*t_prod_line_coef_id*/
            FROM ven_t_prod_line_coef_saf
           WHERE t_prod_line_coef_id = v_prod_line_coef_id;
      END LOOP;
    
      -- Период
      INSERT INTO ven_t_prod_line_period
        SELECT NULL /*t_prod_line_period_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,control_func_id
              ,is_default
              ,is_disabled
              ,period_id
              ,vr_pline.id /*product_line_id*/
              ,sort_order
              ,t_period_use_type_id
          FROM ven_t_prod_line_period
         WHERE product_line_id = v_product_line_id;
      -- Контроль претензии
      INSERT INTO ven_t_prod_claim_control
        SELECT NULL /*t_prod_claim_control_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,comments
              ,control_func_id
              ,is_disabled
              ,sort_order
              ,vr_pline.id /*t_product_line_id*/
          FROM ven_t_prod_claim_control
         WHERE t_product_line_id = v_product_line_id;
      -- Контроль покрытия
      INSERT INTO ven_t_product_line_limit
        SELECT NULL /*t_product_line_limit_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,comments
              ,is_precreation_check
              ,is_underwriting_check
              ,limit_func_id
              ,message
              ,sort_order
              ,vr_pline.id /*t_product_line_id*/
          FROM ven_t_product_line_limit
         WHERE t_product_line_id = v_product_line_id;
    
      FOR vr_plinec IN (SELECT * FROM ven_t_prod_line_contact WHERE product_line_id = v_product_line_id)
      LOOP
        -- Контакты
        -- Контакты
        vr_plinec.product_line_id := vr_pline.id;
        v_prod_line_contact_id    := vr_plinec.t_prod_line_contact_id;
      
        SELECT sq_t_prod_line_contact.nextval INTO vr_plinec.t_prod_line_contact_id FROM dual;
        INSERT INTO ven_t_prod_line_contact VALUES vr_plinec;
        -- Типы помощи
        INSERT INTO ven_t_prod_line_aid
          SELECT NULL /*t_prod_line_aid_id*/
                ,ent_id
                ,filial_id
                ,ext_id
                ,dms_aid_type_id
                ,vr_plinec.t_prod_line_contact_id /*t_prod_line_contact_id*/
            FROM ven_t_prod_line_aid
           WHERE t_prod_line_contact_id = v_prod_line_contact_id;
      END LOOP vr_plinec;
    
      -- Территории
      INSERT INTO ven_t_prod_line_ter
        SELECT NULL /*t_prod_line_ter_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,vr_pline.id /*product_line_id*/
              ,t_territory_id
          FROM ven_t_prod_line_ter
         WHERE product_line_id = v_product_line_id;
      -- Норма доходности
      INSERT INTO ven_t_prod_line_norm
        (t_prod_line_norm_id
        ,ent_id
        ,filial_id
        ,ext_id
        ,is_default
        ,normrate_id
        ,note
        ,product_line_id
        ,VALUE)
        SELECT NULL /*t_prod_line_norm_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,is_default
              ,normrate_id
              ,note
              ,vr_pline.id
              ,VALUE
          FROM ven_t_prod_line_norm
         WHERE product_line_id = v_product_line_id;
      -- Справочник смертности
      INSERT INTO ven_t_prod_line_rate
        SELECT NULL /*t_prod_line_rate_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,deathrate_id
              ,func_id
              ,vr_pline.id
          FROM ven_t_prod_line_rate
         WHERE product_line_id = v_product_line_id;
      -- Алгоритм ЗСП
      INSERT INTO ven_t_prod_line_met_decl
        SELECT NULL /*t_prod_line_met_decl_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,is_default
              ,t_prodline_metdec_met_decl_id
              ,vr_pline.id
          FROM ven_t_prod_line_met_decl
         WHERE t_prodline_metdec_prod_line_id = v_product_line_id;
    
      -- Документы
      INSERT INTO ven_t_pline_issuer_doc
        SELECT NULL /*t_pline_issuer_doc_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,is_required
              ,sort_order
              ,t_issuer_doc_type_id
              ,vr_pline.id /*t_prod_line_id*/
          FROM ven_t_pline_issuer_doc
         WHERE t_prod_line_id = v_product_line_id;
      -- Анкеты
      INSERT INTO ven_t_q_pl_questions
        SELECT NULL /*t_q_pl_questions_id*/
              ,ent_id
              ,filial_id
              ,ext_id
              ,check_falirue_msg
              ,check_value_func
              ,default_can_change
              ,default_value
              ,default_value_func
              ,enabled
              ,is_group
              ,is_main_check
              ,max_value
              ,max_value_func
              ,min_value
              ,min_value_func
              ,parent_pl_question_id
              ,sort_order
              ,vr_pline.id /*t_prod_line_id*/
              ,t_q_question_id
              ,t_quest_form_type_id
          FROM ven_t_q_pl_questions
         WHERE t_prod_line_id = v_product_line_id;
    END LOOP vr_pline;
  END;

  /*
    Байтин А., Капля П.С.
    Инициализация значений по умолчанию для договора
  */
  FUNCTION get_product_defaults(par_product_brief VARCHAR2) RETURN t_product_defaults IS
    vr_policy_values t_product_defaults;
  BEGIN
    BEGIN
      SELECT pr.product_id
        INTO vr_policy_values.product_id
        FROM t_product pr
       WHERE pr.brief = par_product_brief;
      vr_policy_values.product_brief := par_product_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден продукт "' || par_product_brief || '"!');
    END;
  
    BEGIN
      SELECT pc.currency_id
            ,fd.brief
        INTO vr_policy_values.fund_id
            ,vr_policy_values.fund_brief
        FROM t_prod_currency pc
            ,fund            fd
       WHERE pc.product_id = vr_policy_values.product_id
         AND pc.currency_id = fd.fund_id
         AND pc.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена валюта ответственности по умолчанию');
    END;
  
    BEGIN
      SELECT pc.currency_id
        INTO vr_policy_values.fund_pay_id
        FROM t_prod_pay_curr pc
       WHERE pc.product_id = vr_policy_values.product_id
         AND pc.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена валюта платежа по умолчанию');
    END;
  
    BEGIN
      SELECT cc.confirm_condition_id
        INTO vr_policy_values.confirm_condition_id
        FROM t_product_conf_cond cc
       WHERE cc.is_default = 1
         AND cc.product_id = vr_policy_values.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдено условие вступления в силу по умолчанию');
    END;
  
    BEGIN
      SELECT pt.payment_term_id
            ,te.is_periodical
        INTO vr_policy_values.payment_term_id
            ,vr_policy_values.is_periodical
        FROM t_prod_payment_terms pt
            ,t_payment_terms      te
       WHERE pt.product_id = vr_policy_values.product_id
         AND pt.is_default = 1
         AND pt.payment_term_id = te.id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип премии по умолчанию');
    END;
  
    BEGIN
      SELECT period_id
        INTO vr_policy_values.period_id
        FROM (SELECT pp.period_id
                FROM t_product_period  pp
                    ,t_period_use_type ut
               WHERE pp.product_id = vr_policy_values.product_id
                 AND pp.t_period_use_type_id = ut.t_period_use_type_id
                 AND ut.brief = 'Срок страхования'
                 AND (pp.is_default = 1 OR NOT EXISTS
                      (SELECT NULL
                         FROM t_product_period pp1
                        WHERE pp1.product_id = pp.product_id
                          AND pp1.id != pp.id
                          AND pp1.t_period_use_type_id = ut.t_period_use_type_id))
               ORDER BY pp.sort_order)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден период действия по умолчанию');
    END;
  
    BEGIN
      SELECT period_id
        INTO vr_policy_values.waiting_period_id
        FROM (SELECT pp.period_id
                FROM t_product_period  pp
                    ,t_period_use_type ut
               WHERE pp.product_id = vr_policy_values.product_id
                 AND pp.t_period_use_type_id = ut.t_period_use_type_id
                 AND ut.brief = 'Выжидательный'
                 AND (pp.is_default = 1 OR NOT EXISTS
                      (SELECT NULL
                         FROM t_product_period pp1
                        WHERE pp1.product_id = pp.product_id
                          AND pp1.id != pp.id
                          AND pp1.t_period_use_type_id = ut.t_period_use_type_id))
               ORDER BY pp.sort_order)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден выжидательный период по умолчанию');
    END;
  
    BEGIN
      SELECT period_id
        INTO vr_policy_values.privilege_period_id
        FROM (SELECT pp.period_id
                FROM t_product_period  pp
                    ,t_period_use_type ut
               WHERE pp.product_id = vr_policy_values.product_id
                 AND pp.t_period_use_type_id = ut.t_period_use_type_id
                 AND ut.brief = 'Льготный'
               ORDER BY pp.sort_order)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найден льготный период');
    END;
  
    BEGIN
      SELECT discount_f_id
        INTO vr_policy_values.discount_f_id
        FROM discount_f
       WHERE brief = 'База';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена скидка по нагрузке "База"');
    END;
  
    BEGIN
      SELECT t_work_group_id
        INTO vr_policy_values.work_group_id
        FROM t_work_group
       WHERE description = '1 группа';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена группа профессий с названием "1 группа"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько групп профессий с названием "1 группа"');
    END;
  
    RETURN vr_policy_values;
  END get_product_defaults;

  /*
  Веселуха Е.В. 31.05.2013
  Функция добавляет программу Инвест-резерв в продукт
  Параметр: ИД продукта
  */
  FUNCTION insert_invest_reserve(par_product_id NUMBER) RETURN NUMBER IS
    v_lob_line_id         NUMBER;
    sq_t_prod_line_id     NUMBER;
    sq_prod_line_opt_id   NUMBER;
    v_normrate_id         NUMBER;
    v_t_prod_coef_type_id NUMBER;
    v_loading             NUMBER;
    v_premium             NUMBER;
    v_amount              NUMBER;
    v_ver_lob_id          NUMBER;
    sq_parent_id          NUMBER;
    v_new_product_line    VARCHAR2(25);
    is_product            NUMBER;
    no_product EXCEPTION;
  BEGIN
    SELECT COUNT(*)
      INTO is_product
      FROM ins.t_product prod
     WHERE prod.product_id = par_product_id
       AND prod.brief IN ('PEPR', 'PEPR_2', 'END', 'END_2', 'TERM', 'TERM_2', 'CHI', 'CHI_2');
    IF is_product = 0
    THEN
      RAISE no_product;
    END IF;
    /**/
    SELECT pl.product_ver_lob_id
      INTO v_ver_lob_id
      FROM ven_t_product_line    pl
          ,ins.t_product_ver_lob pb
          ,ins.t_product_version ver
     WHERE pl.product_ver_lob_id = pb.t_product_ver_lob_id
       AND pb.product_version_id = ver.t_product_version_id
       AND ver.product_id = par_product_id
       AND pl.insurance_group_id = 2421
       AND rownum = 1;
  
    SELECT sq_t_product_line.nextval INTO sq_t_prod_line_id FROM dual;
  
    SELECT te.t_prod_coef_type_id
      INTO v_loading
      FROM ins.ven_t_prod_coef_type te
     WHERE te.brief = 'LOADING_INVEST_RESERVE';
    SELECT te.t_prod_coef_type_id
      INTO v_premium
      FROM ins.ven_t_prod_coef_type te
     WHERE te.brief = 'PREMIUM_INVEST_RESERVE';
    SELECT te.t_prod_coef_type_id
      INTO v_amount
      FROM ins.ven_t_prod_coef_type te
     WHERE te.brief = 'AMOUNT_INVEST_RESERVE';
    SELECT lb.t_lob_line_id
      INTO v_lob_line_id
      FROM ins.ven_t_lob_line lb
     WHERE lb.brief = 'PEPR_INVEST_RESERVE';
  
    BEGIN
      SELECT 'Инвест-Резерв' ||
             to_char(MAX(to_number(nvl(TRIM(substr(pl.description, 14, 1)), 0))) + 1)
        INTO v_new_product_line
        FROM ins.t_product_line pl
       WHERE pl.product_ver_lob_id = v_ver_lob_id
         AND pl.description LIKE 'Инвест-Резерв%';
    EXCEPTION
      WHEN no_data_found THEN
        v_new_product_line := 'Инвест-Резерв';
    END;
  
    INSERT INTO ins.ven_t_product_line
      (id
      ,description
      ,fee_func_id
      ,fee_round_rules_id
      ,for_premium
      ,insurance_group_id
      ,ins_amount_round_rules_id
      ,is_active_in_waitring_period
      ,is_aggregate
      ,is_avtoprolongation
      ,is_default
      ,loading_func_id
      ,premium_func_id
      ,premium_type
      ,product_line_type_id
      ,product_ver_lob_id
      ,sort_order
      ,tariff_func_id
      ,tariff_netto_func_id
      ,t_cover_form_id
      ,t_lob_line_id
      ,visible_flag
      ,disable_reserve_calc
      ,ins_amount_func_id)
    VALUES
      (sq_t_prod_line_id
      ,v_new_product_line
      ,v_premium
      ,2
      ,1
      ,2421
      ,1
      ,1
      ,0
      ,0
      ,0
      ,v_loading
      ,v_premium
      ,1
      ,3
      ,v_ver_lob_id
      ,(SELECT MAX(pl.sort_order) + 1
         FROM ins.t_product_line pl
        WHERE pl.product_ver_lob_id = v_ver_lob_id)
      ,3745
      ,4727
      ,2
      ,v_lob_line_id
      ,1
      ,0
      ,v_amount);
  
    SELECT sq_t_prod_line_option.nextval INTO sq_prod_line_opt_id FROM dual;
    INSERT INTO ins.ven_t_prod_line_option
      (id, product_line_id, description, default_flag, is_excluded)
    VALUES
      (sq_prod_line_opt_id, sq_t_prod_line_id, v_new_product_line, 1, 0);
    INSERT INTO ins.ven_t_prod_line_opt_peril
      (is_default, peril_id, product_line_option_id)
    VALUES
      (1, 2643, sq_prod_line_opt_id);
    INSERT INTO ins.ven_t_prod_line_opt_peril
      (is_default, peril_id, product_line_option_id)
    VALUES
      (0, 2644, sq_prod_line_opt_id);
  
    INSERT INTO ven_t_prod_line_deduct
      (deductible_rel_id, is_default, is_handchange_enabled, product_line_id)
    VALUES
      (1, 1, 0, sq_t_prod_line_id);
  
    INSERT INTO ins.ven_t_as_type_prod_line
      (asset_common_type_id
      ,is_insured
      ,is_ins_amount_agregate
      ,is_ins_fee_agregate
      ,is_ins_prem_agregate
      ,product_line_id)
    VALUES
      (1649, 0, 0, 0, 0, sq_t_prod_line_id);
  
    INSERT INTO ins.ven_t_prod_line_coef
      (is_disabled, is_restriction, sort_order, t_prod_coef_type_id, t_product_line_id)
    VALUES
      (0, 0, 1, 4525, sq_t_prod_line_id);
  
    FOR cur IN (
                
                SELECT pl.id sq_parent_id
                  FROM ven_t_product_line      pl
                       ,ins.t_product_ver_lob   pb
                       ,ins.t_product_version   ver
                       ,ins.t_product_line_type plt
                 WHERE pl.product_ver_lob_id = pb.t_product_ver_lob_id
                   AND pb.product_version_id = ver.t_product_version_id
                   AND ver.product_id = par_product_id
                   AND pl.insurance_group_id = 2421
                   AND pl.product_line_type_id = plt.product_line_type_id
                   AND plt.brief = 'RECOMMENDED'
                   AND pl.visible_flag = 1)
    LOOP
      INSERT INTO ins.ven_parent_prod_line
        (is_parent_ins_amount, product_ver_lob_id, t_parent_prod_line_id, t_prod_line_id)
      VALUES
        (0, v_ver_lob_id, cur.sq_parent_id, sq_t_prod_line_id);
    END LOOP;
  
    SELECT nr.normrate_id
      INTO v_normrate_id
      FROM ins.ven_normrate nr
     WHERE nr.base_fund_id = 122
       AND nr.t_lob_line_id = v_lob_line_id;
    INSERT INTO ins.ven_t_prod_line_norm
      (is_default, normrate_id, product_line_id, VALUE)
    VALUES
      (1, v_normrate_id, sq_t_prod_line_id, 0.02);
  
    INSERT INTO ins.ven_t_prod_line_rate
      (deathrate_id, product_line_id)
    VALUES
      (101, sq_t_prod_line_id);
  
    INSERT INTO ins.ven_t_prod_line_met_decl
      (is_default, t_prodline_metdec_met_decl_id, t_prodline_metdec_prod_line_id)
    VALUES
      (1, 101, sq_t_prod_line_id);
  
    INSERT INTO ins.ven_t_prod_line_ter
      (product_line_id, t_territory_id)
    VALUES
      (sq_t_prod_line_id, 12);
  
    INSERT INTO ven_t_prod_line_period
      (is_default, is_disabled, period_id, product_line_id, t_period_use_type_id)
    VALUES
      (1, 0, 9, sq_t_prod_line_id, 1);
  
    SELECT te.t_prod_coef_type_id
      INTO v_t_prod_coef_type_id
      FROM ins.ven_t_prod_coef_type te
     WHERE te.brief = 'CURRENCY_INVEST_RESERVE';
    INSERT INTO ins.ven_t_prod_line_coef
      (is_disabled, is_restriction, sort_order, t_prod_coef_type_id, t_product_line_id)
    VALUES
      (0
      ,0
      ,(SELECT MAX(cf.sort_order) + 1
         FROM ins.t_prod_line_coef cf
        WHERE cf.t_product_line_id = sq_t_prod_line_id)
      ,v_t_prod_coef_type_id
      ,sq_t_prod_line_id);
  
    SELECT te.t_prod_coef_type_id
      INTO v_t_prod_coef_type_id
      FROM ins.ven_t_prod_coef_type te
     WHERE te.brief = 'END_POLICY_INVEST_RESERVE';
    INSERT INTO ins.ven_t_prod_line_coef
      (is_disabled, is_restriction, sort_order, t_prod_coef_type_id, t_product_line_id)
    VALUES
      (0
      ,0
      ,(SELECT MAX(cf.sort_order) + 1
         FROM ins.t_prod_line_coef cf
        WHERE cf.t_product_line_id = sq_t_prod_line_id)
      ,v_t_prod_coef_type_id
      ,sq_t_prod_line_id);
  
    RETURN 0;
  
  EXCEPTION
    WHEN no_product THEN
      RETURN 1;
      raise_application_error(-20001
                             ,'В данном продукте не может быть риска Инвест-Резерв.');
    WHEN OTHERS THEN
      RETURN 1;
      raise_application_error(-20002
                             ,'Не создан риск Инвест-резерв, неизвестная ошибка.');
  END insert_invest_reserve;
  /**/

  PROCEDURE get_period_by_months_amount
  (
    par_product_id NUMBER
   ,par_start_date DATE
   ,par_months     NUMBER
   ,par_end_date   OUT DATE
   ,par_period_id  OUT NUMBER
  ) IS
    v_found NUMBER;
  
  BEGIN
  
    assert_deprecated(par_condition => NOT par_months BETWEEN 0 AND 1000
          ,par_msg       => 'Период страхования должен быть положительным и не более 1000 месяцев');
  
    BEGIN
      SELECT pp.period_id
            ,ADD_MONTHS(par_start_date, par_months) - INTERVAL '1' SECOND
        INTO par_period_id
            ,par_end_date
        FROM t_product_period  pp
            ,t_period          pd
            ,t_period_type     pt
            ,t_period_use_type put
       WHERE pp.product_id = par_product_id
         AND pp.t_period_use_type_id = put.t_period_use_type_id
         AND put.brief = 'Срок страхования'
         AND pp.period_id = pd.id
         AND pd.period_type_id = pt.id
         AND ((pd.period_value = par_months / 12 AND pt.brief = 'Y') OR
             (pd.period_value = par_months AND pt.brief = 'M') OR
             (pd.period_value = par_months / 3 AND pt.brief = 'Q'));
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          SELECT COUNT(*)
            INTO v_found
            FROM dual
           WHERE EXISTS (SELECT NULL
                    FROM t_product_period  pp
                        ,t_period          p
                        ,t_period_use_type put
                   WHERE pp.t_period_use_type_id = put.t_period_use_type_id
                     AND put.brief = 'Срок страхования'
                     AND pp.product_id = par_product_id
                     AND pp.period_id = p.id
                     AND p.description = 'Другой');
        
          IF v_found = 0
          THEN
            raise_application_error(-20001
                                   ,'Не найден срок страхования для "' || par_months || '" месяцев');
          ELSE
            SELECT p.id
                  ,ADD_MONTHS(par_start_date, par_months) - INTERVAL '1' SECOND
              INTO par_period_id
                  ,par_end_date
              FROM t_period p
             WHERE p.description = 'Другой';
          END IF;
        
        END;
      
    END;
  END get_period_by_months_amount;

  /*
    Капля П.
    Получение ИД скидки для договора по брифу
    Другого места пока нет, но отсюда нужно функцию вынести.
  */

  FUNCTION get_discount_id(par_discount_brief discount_f.brief%TYPE)
    RETURN discount_f.discount_f_id%TYPE IS
    v_discount_id discount_f.discount_f_id%TYPE;
  BEGIN
    SELECT discount_f_id INTO v_discount_id FROM discount_f d WHERE d.brief = par_discount_brief;
  
    RETURN v_discount_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось найти скидку для договора по брифу: ' || par_discount_brief);
  END;

  /*
    Капля П.
    Пытаемся определить ПУ по умолчанию для продукта
  */
  FUNCTION get_default_bso_series(par_product_id t_product.product_id%TYPE)
    RETURN bso_series.bso_series_id%TYPE IS
    v_bso_series_id bso_series.bso_series_id%TYPE;
  BEGIN
  
    SELECT bs.bso_series_id
      INTO v_bso_series_id
      FROM t_product_bso_types pbt
          ,bso_series          bs
     WHERE pbt.t_product_id = par_product_id
       AND pbt.bso_type_id = bs.bso_type_id
       AND EXISTS (SELECT NULL
              FROM t_product_bso_types bt
             WHERE bs.bso_type_id = bt.bso_type_id
               AND bt.t_product_id = pbt.t_product_id);
  
    RETURN v_bso_series_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Для продукта не доступна ни одно серия БСО');
    WHEN too_many_rows THEN
      ex.raise('Не удалось однозначно определить серию БСО по продукту ' || dml_t_product.get_record(par_product_id)
               .description);
  END get_default_bso_series;

END pkg_products; 
/
