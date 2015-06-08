CREATE OR REPLACE PACKAGE pkg_re_insurance IS

  -- Author  : SERGEY.POSKRYAKOV
  -- Created : 15.11.2011 12:17:37
  -- Purpose : Пакет для расчета договоров перестрахования

  TYPE r_decline IS RECORD(
     re_bordero_line_id NUMBER
    ,policy_id          NUMBER
    ,cover_id           NUMBER
    ,decline_date       DATE
    ,type_id            NUMBER);

  TYPE tbl_decline IS TABLE OF r_decline;

  TYPE r_change IS RECORD(
     re_bordero_line_id NUMBER
    ,policy_id          NUMBER
    ,cover_id           NUMBER
    ,start_date         DATE
    ,type_id            NUMBER);

  TYPE tbl_change IS TABLE OF r_change;

  t_change tbl_change;

  TYPE r_claim IS RECORD(
     re_bordero_line_id NUMBER
    ,policy_id          NUMBER
    ,claim_id           NUMBER
    ,claim_type         NUMBER
    ,reins_sum          NUMBER
    ,pay_sum            NUMBER
    ,reserve_sum        NUMBER);

  TYPE tbl_claim IS TABLE OF r_claim;

  t_claim tbl_claim;

  PROCEDURE calc_bordero(par_bordero_package_id IN NUMBER);

  PROCEDURE calc_claim /*_new*/
  (par_bordero_package_id IN NUMBER);
  PROCEDURE calc_claim_old(par_bordero_package_id IN NUMBER);

  PROCEDURE calc_decline(par_bordero_package_id IN NUMBER);

  /*Функция рассчитывает рассроченную оплату ежегодной премии
    SA - Страховая сумма
    t  - период в годах
  */
  /*function get_t_v(par_n in number, par_t number, par_brief in varchar2, par_A1_xn in number,
  par_A_xn in number, par_a_x_n in number, par_number_of_payments in number,
  par_normrate_value in number, par_premium in number) return  number;*/

  FUNCTION Get_Limit
  (
    par_re_version_id   IN NUMBER
   ,par_policy_id       IN NUMBER
   ,par_assured_id      IN NUMBER
   ,par_reassured_id    IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_rvb_value       IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Get_Limit_percent
  (
    par_re_version_id   IN NUMBER
   ,par_policy_id       IN NUMBER
   ,par_assured_id      IN NUMBER
   ,par_reassured_id    IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_rvb_value       IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_MF
  (
    par_re_version_id    IN NUMBER
   ,par_paymentoff_id    IN NUMBER
   ,par_is_group         IN NUMBER
   ,par_paymentoff_count IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_re_com_rate
  (
    par_re_version_id IN NUMBER
   ,par_prod_line_id  IN NUMBER
   ,par_autoprolong   IN NUMBER
   ,par_cover_year    IN NUMBER
   ,par_fund_id       IN NUMBER
  ) RETURN NUMBER;

  PROCEDURE get_re_comiss
  (
    par_re_version_id        IN NUMBER
   ,par_re_bordero_type_id   IN NUMBER
   ,par_flg_no_comiss        IN NUMBER
   ,par_PRP                  IN NUMBER
   ,par_year_cover           IN NUMBER
   ,par_year                 IN NUMBER
   ,par_autoprolongation     IN NUMBER
   ,par_re_calc_func_id      IN NUMBER
   ,par_cover_start_date     IN DATE
   ,par_cover_end_date       IN DATE
   ,par_bordero_start_date   IN DATE
   ,par_bordero_end_date     IN DATE
   ,par_product_line_id      IN NUMBER
   ,par_product_line_type_id IN NUMBER
   ,par_payment_period_start IN DATE
   ,par_payment_period_end   IN DATE
   ,par_first_payment_date   IN DATE
   ,par_insurance_type       IN VARCHAR2
   ,par_header_start         IN DATE
   ,par_header_end           IN DATE
   ,par_re_com_rate          IN OUT NUMBER
   ,par_result               OUT NUMBER
  );

  FUNCTION get_bordero_id
  (
    par_bordero_package_id IN NUMBER
   ,par_bordero_type_id    IN NUMBER
   ,par_fund_id            IN NUMBER
  ) RETURN NUMBER;

  /*  Функция определения типа бордеро
      1 - Бордеро первых платежей(БПП),
      2 - Бордеро доплат (БД)
      41 - Бордеро изменений (БИ)
  
  */

  FUNCTION get_bordero_type
  (
    par_bordero_date_begin IN DATE
   ,par_bordero_date_end   IN DATE
   ,par_first_pay_date     IN DATE
   ,par_pay_date           IN DATE
   ,par_cover_start_date   IN DATE
   ,par_pol_header_id      IN NUMBER
   ,par_policy_id          IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_premium_type
  (
    par_start_pay_date   IN DATE
   ,par_bordero_end_date IN DATE
   ,par_type             IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_YRP_single
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER;

  FUNCTION get_RP
  (
    par_PRP            IN NUMBER
   ,par_pay_start_date IN DATE
   ,par_pay_end_date   IN DATE
   ,par_decline_date   IN DATE
    --  ,par_periodical in number
   ,par_return_finc_id NUMBER
  ) RETURN NUMBER;

  FUNCTION get_tariff
  (
    par_policy_id       IN NUMBER
   ,par_asset_id        IN NUMBER
   ,par_insured_age     IN NUMBER
   ,par_cover_id        IN NUMBER
   ,par_bordero_type    IN NUMBER
   ,par_flg_all_program IN NUMBER
   ,par_re_version_id   IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_gender          IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_prod_line_id    IN NUMBER
   ,par_work_group_id   IN NUMBER
   ,par_ins_amount      IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_norm_rate(par_cover_year IN NUMBER) RETURN NUMBER;

  FUNCTION get_RS
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_claim_id
  (
    par_policy_id          IN NUMBER
   ,par_asset_id           IN NUMBER
   ,par_cover_id           IN NUMBER
   ,par_border_start_date  IN DATE
   ,par_bordero_end_date   IN DATE
   ,par_payment_start_date IN DATE
   ,par_payment_end_date   IN DATE
   ,par_reins_perc         IN NUMBER
   ,par_bordero_line_id    IN NUMBER
  ) RETURN NUMBER;

  FUNCTION check_claim
  (
    par_claim_id           IN NUMBER
   ,par_cover_id           IN NUMBER
   ,par_date_company       IN DATE
   ,par_bordero_start_date IN DATE
   ,par_bordero_end_date   IN DATE
   ,par_pay_date           IN DATE
   ,par_event_date         IN DATE
   ,par_date_cancel        IN DATE
   ,par_status_brief       IN VARCHAR2
  ) RETURN NUMBER;

  FUNCTION get_claim_flag
  (
    par_claim_id IN NUMBER
   ,par_cover_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_version_before_change
  (
    par_pol_header_id IN NUMBER
   ,par_change_date   IN DATE
  ) RETURN NUMBER;

  PROCEDURE clear_bordero(par_bordero_package_id IN NUMBER);

  PROCEDURE save_bordero(par_bordero_package_id IN NUMBER);

  FUNCTION compare_cover
  (
    par_cover_before_id IN NUMBER
   ,par_cover_after_id  IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_changed_version
  (
    par_pol_header_id   IN NUMBER
   ,par_pay_start_date  IN DATE
   ,par_pay_end_date    IN DATE
   , /*par_bordero_end_date in date,*/par_policy_id       IN NUMBER
   ,par_contact_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_cover_id        IN NUMBER
   ,par_bordero_line_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_policy_cover_id
  (
    par_policy_id       IN NUMBER
   ,par_contact_id      IN NUMBER
   ,par_product_line_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_IR_by_func
  (
    par_version_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,ret_percent         IN NUMBER
   ,OBI                 IN NUMBER
   ,ret_limit           IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_IR
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_RP_by_func
  (
    par_version_id      IN NUMBER
   ,par_PRP             IN NUMBER
   ,par_pay_start_date  IN DATE
   ,par_pay_end_date    IN DATE
   ,par_decline_date    IN DATE
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_RS_by_func
  (
    par_version_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,ret_percent         IN NUMBER
   ,OBI                 IN NUMBER
   ,ret_limit           IN NUMBER
  ) RETURN NUMBER;

  /*function get_RBI(par_SA in number, par_V in number, par_brief in varchar2, par_a_x_n in number) return number;*/

  /*function get_OBI(par_SA in number, par_V in number, par_flag_single in number,
  par_brief in varchar2, par_a_xn in number)
  return number;*/

  FUNCTION get_bordero_line_id
  (
    par_re_version_id IN NUMBER
   ,par_cover_id      IN NUMBER
   ,par_event_date    IN DATE
  ) RETURN NUMBER;

  /*--------------------*/
  FUNCTION Check_koef
  (
    par_s_med           IN NUMBER
   ,par_s_no_med        IN NUMBER
   ,par_k_med           IN NUMBER
   ,par_k_no_med        IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_re_version_id   IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Check_limit
  (
    par_ins_amount      IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_re_version_id   IN NUMBER
   ,par_insurer_id      IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Check_assured
  (
    par_assured       IN NUMBER
   ,par_re_version_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Check_total_limit
  (
    par_sum           IN NUMBER
   ,par_fund_id       IN NUMBER
   ,par_re_version_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Get_sum_by_rate
  (
    par_base_fund_id IN NUMBER
   ,par_fund_id      IN NUMBER
   ,par_sum          IN NUMBER
   ,par_rate_date    IN DATE
   ,par_rate_type_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Check_limit_contract
  (
    par_policy_id       IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_re_version_id   IN NUMBER
   ,par_plo_id          IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_contact_d       IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_YRP_by_func
  (
    par_version_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_RBI             IN NUMBER
   ,par_tarif           IN NUMBER
   ,par_SRR             IN NUMBER
   ,par_RS              IN NUMBER
   ,par_k_med           IN NUMBER
   ,par_k_no_med        IN NUMBER
   ,par_s_med           IN NUMBER
   ,par_s_no_med        NUMBER
  ) RETURN NUMBER;

  FUNCTION get_YRP
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER;

  FUNCTION YRP_SwissRe
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER;

  FUNCTION get_P
  (
    par_prod_line_id  IN NUMBER
   ,par_program_brief IN VARCHAR2
   ,par_A_xn          IN NUMBER
   ,par_a_x_n         IN NUMBER
   ,par_is_periodical IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_re_start_date
  (
    par_pay_plan_date    IN DATE
   ,par_cover_start_date IN DATE
   ,par_first_pay_date   IN DATE
  ) RETURN DATE;

  FUNCTION get_re_end_date
  (
    par_pay_plan_date        DATE
   ,par_first_pay_date       DATE
   ,par_cover_end_date       DATE
   ,par_one_str_for_one_prem NUMBER
  ) RETURN DATE;

  FUNCTION get_anniversary_date
  (
    par_date       IN DATE
   ,par_start_date IN DATE
   ,par_mode       IN NUMBER
  ) RETURN DATE;

  FUNCTION Check_cover_period
  (
    par_cover_start_date   IN DATE
   ,par_cover_end_date     IN DATE
   ,par_bordero_start_date IN DATE
   ,par_bordero_end_date   IN DATE
  ) RETURN NUMBER;

  FUNCTION Check_date_year
  (
    par_first_date  IN DATE
   ,par_second_date IN DATE
  ) RETURN NUMBER;

  FUNCTION Check_cover_in_bordero
  (
    par_cover_id         IN NUMBER
   ,par_re_version_id    IN NUMBER
   ,par_bordero_type     IN NUMBER
   ,par_in_reins_program IN NUMBER
   ,par_all_program      IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Check_SQL_Text(par_sql IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION Check_policy_type
  (
    par_re_ver_contract_id IN NUMBER
   ,par_policy_id          IN NUMBER
  ) RETURN NUMBER;

  FUNCTION Check_policy
  (
    par_pol_header_id IN NUMBER
   ,par_date          IN DATE
  ) RETURN NUMBER;

  PROCEDURE check_reins_number(par_policy_id IN NUMBER);

  PROCEDURE fill_policy_reins(par_policy_id IN NUMBER);

  PROCEDURE del_assured(par_policy_id IN NUMBER);

  PROCEDURE CreateFunc
  (
    func_name  IN VARCHAR2
   ,func_brief IN VARCHAR2
  );

  --Function Axn_i (x in number, n in number, p_Sex in varchar2
  --             ,K_koeff in number default 0, S_koeff in number default 0, p_table_id in number, p_i in number) return number;

  PROCEDURE fill_all_policy;

  FUNCTION Policy_Effective_On_Date
  (
    par_pol_header_id IN NUMBER
   ,Effect_Date       IN DATE
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает долю перестраховщика
  */
  FUNCTION get_reinsurer_share
  (
    par_bordero_type_brief VARCHAR2
   ,par_bordero_id         NUMBER
  ) RETURN NUMBER;

  FUNCTION get_reinsurer_share_rur
  (
    par_bordero_type_brief VARCHAR2
   ,par_bordero_id         NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму заявленных убытков
  */
  FUNCTION get_declared_sum
  (
    par_bordero_type_brief VARCHAR2
   ,par_bordero_id         NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму заявленных убытков в рублях
  */
  FUNCTION get_declared_sum_rur
  (
    par_bordero_type_brief    VARCHAR2
   ,par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму в рублях на дату окончания пакета бордеро
  */
  FUNCTION get_rate_on_package_end
  (
    par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной премии
  */
  FUNCTION get_returned_premium(par_bordero_id NUMBER) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной премии в рублях
  */
  FUNCTION get_returned_premium_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной комиссии
  */
  FUNCTION get_returned_commission(par_bordero_id NUMBER) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной комиссии в рублях
  */
  FUNCTION get_returned_commission_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму пакета бордеро
  */
  FUNCTION get_bordero_package_sum(par_re_bordero_package_id NUMBER) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму перестраховочной комиссии в рублях
  */

  FUNCTION get_commission_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER;

  /*
    Байтин А.
    Возвращает сумму перестраховочной премии в рублях
  */

  FUNCTION get_re_premium_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER;
  /*
  
      function get_netto_tariff_new
    (
      par_p_cover_id       number
     ,par_version_num      number
     ,par_pol_header_id    number
     ,par_prod_line_opt_id number
     ,par_asset_header_id  number
     ,par_msfo_brief varchar2
     ,par_header_start_date date
     ,par_date_of_birth date
     ,par_sex varchar2
     ,par_deathrate_id number
     ,par_norm_rate number
    )
    return number;
  */

  /*
    Байтин А.
    Проверка, можно ли удалять версию ДС
  */
  FUNCTION can_delete_policy(par_policy_id NUMBER) RETURN NUMBER;
END pkg_re_insurance;
/
CREATE OR REPLACE PACKAGE BODY pkg_re_insurance IS

  gc_deatrate_wop_brief  CONSTANT VARCHAR2(50) := 'Таблица смертности для риска освобождение';
  gc_deatrate_pwop_brief CONSTANT VARCHAR2(50) := 'Таблица смертности для риска защита';
  gv_deatrate_wop_id  NUMBER;
  gv_deatrate_pwop_id NUMBER;
  gc_max_age_wop CONSTANT NUMBER := 65;

  PROCEDURE clear_bordero_log(par_bordero_package_id NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM re_calc_bordero_log WHERE bordero_package_id = par_bordero_package_id;
    COMMIT;
  END clear_bordero_log;

  PROCEDURE calc_bordero_log
  (
    par_bordero_package_id NUMBER
   ,par_cover_id           NUMBER
   ,par_error_message      VARCHAR2
   ,par_backtrace          VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO re_calc_bordero_log
      (bordero_package_id, p_cover_id, error_message, backtrace)
    VALUES
      (par_bordero_package_id, par_cover_id, par_error_message, par_backtrace);
    COMMIT;
  END calc_bordero_log;

  PROCEDURE clear_claim_log(par_bordero_package_id NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM re_calc_claim_log WHERE bordero_package_id = par_bordero_package_id;
    COMMIT;
  END clear_claim_log;

  PROCEDURE calc_claim_log
  (
    par_bordero_package_id NUMBER
   ,par_claim_id           NUMBER
   ,par_error_message      VARCHAR2
   ,par_backtrace          VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO re_calc_claim_log
      (bordero_package_id, c_claim_id, error_message, backtrace)
    VALUES
      (par_bordero_package_id, par_claim_id, par_error_message, par_backtrace);
    COMMIT;
  END calc_claim_log;

  PROCEDURE clear_decline_log(par_bordero_package_id NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM re_calc_decline_log WHERE bordero_package_id = par_bordero_package_id;
    COMMIT;
  END clear_decline_log;

  PROCEDURE calc_decline_log
  (
    par_bordero_package_id NUMBER
   ,par_cover_id           NUMBER
   ,par_error_message      VARCHAR2
   ,par_backtrace          VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO re_calc_decline_log
      (bordero_package_id, p_cover_id, error_message, backtrace)
    VALUES
      (par_bordero_package_id, par_cover_id, par_error_message, par_backtrace);
    COMMIT;
  END calc_decline_log;

  FUNCTION get_OBI
  (
    par_SA                  IN NUMBER
   ,par_V                   IN NUMBER
   ,par_flag_single         IN NUMBER
   ,par_brief               IN VARCHAR2
   ,par_a_xn                IN NUMBER
   ,par_flg_no_calc_reserve IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_RBI
  (
    par_SA                  IN NUMBER
   ,par_V                   IN NUMBER
   ,par_brief               IN VARCHAR2
   ,par_a_x_n               IN NUMBER
   ,par_flg_no_calc_reserve IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_t_v
  (
    par_n                   IN NUMBER
   ,par_t                   NUMBER
   ,par_brief               IN VARCHAR2
   ,par_A1_xn               IN NUMBER
   ,par_A_xn                IN NUMBER
   ,par_a_x_n               IN NUMBER
   ,par_number_of_payments  IN NUMBER
   ,par_normrate_value      IN NUMBER
   ,par_premium             IN NUMBER
   ,par_flg_no_calc_reserve IN NUMBER
  ) RETURN NUMBER;

  /* Функция расчета нетто-тарифа для вычисления актарного резерва */
  FUNCTION get_netto_tariff
  (
    par_p_cover_id        NUMBER
   ,par_version_num       NUMBER
   ,par_pol_header_id     NUMBER
   ,par_prod_line_opt_id  NUMBER
   ,par_asset_header_id   NUMBER
   ,par_msfo_brief        VARCHAR2
   ,par_header_start_date DATE
   ,par_date_of_birth     DATE
   ,par_sex               VARCHAR2
   ,par_deathrate_id      NUMBER
   ,par_norm_rate         NUMBER
  ) RETURN NUMBER;
  /*
    Функция расчета актуарного резерва
  */
  PROCEDURE calc_bordero(par_bordero_package_id IN NUMBER) IS
    res                           NUMBER := 1;
    n_A_xn                        NUMBER;
    n_A1_xn                       NUMBER;
    n_a_x_n                       NUMBER;
    p_t                           NUMBER := 1;
    t_V                           NUMBER;
    t_O_V                         NUMBER;
    n_OBI                         NUMBER;
    n_reserve                     NUMBER;
    n_IR                          NUMBER;
    n_RS                          NUMBER;
    n_limit                       NUMBER;
    n_percent                     NUMBER;
    n_ISRAR                       NUMBER;
    n_OBR                         NUMBER;
    n_RBI                         NUMBER;
    n_R                           NUMBER;
    n_SRR                         NUMBER;
    n_YRP                         NUMBER;
    n_MF                          NUMBER;
    n_PRP                         NUMBER;
    n_RP                          NUMBER;
    n_P                           NUMBER;
    n_tarif                       NUMBER;
    n_norm_rate                   NUMBER;
    v_add_com_rate                NUMBER;
    v_add_commission              NUMBER;
    v_re_commission               NUMBER;
    v_re_com_rate                 NUMBER;
    n_t_cover                     NUMBER;
    v_t_policy_year               NUMBER;
    d_start_bordero               DATE;
    d_end_bordero                 DATE;
    d_re_start_date               DATE;
    d_re_expiry_date              DATE;
    v_re_version_id               NUMBER;
    v_re_main_contract_id         NUMBER;
    v_bordero_id                  NUMBER;
    v_bordero_type_id             NUMBER;
    v_re_cover                    re_cover%ROWTYPE;
    v_pay_first_date              DATE;
    v_pay_end_date                DATE;
    v_pay_last_date               DATE := to_date('01.01.1900', 'DD.MM.YYYY');
    n_year                        NUMBER := 0;
    v_policy_state                VARCHAR2(100);
    d_decline_date                DATE;
    d_claim_date                  DATE;
    d_claim_pay_date              DATE;
    d_claim_den_date              DATE;
    v_claim_id                    NUMBER;
    v_claim_flag                  NUMBER;
    v_claim_state                 VARCHAR2(100);
    v_claim_sum                   NUMBER;
    v_re_contract_version         re_contract_version%ROWTYPE;
    n_need_save                   NUMBER := 1;
    v_premium_type_id             NUMBER := 11; --Премия
    v_change_policy_id            NUMBER;
    v_change_policy_date          DATE;
    v_change_policy_type          NUMBER;
    v_change_policy_cover_id      NUMBER;
    v_change_pol_cover_start_date DATE;
    v_change_pol_cover_end_date   DATE;
    v_change_pol_cover_sum        NUMBER;
    t_decline                     tbl_decline;
    --  t_change tbl_change;
    --  t_claim tbl_claim;  --Сделана глобальной
    p_bordero_line_id      NUMBER;
    i                      NUMBER;
    p_re_bordero_line      re_bordero_line%ROWTYPE;
    v_cover_decline_date   DATE;
    v_netto_tariff_mode    NUMBER(1);
    v_issuer_age_main      NUMBER;
    v_error_message        VARCHAR2(250);
    v_insured_age_pay      NUMBER;
    v_issuer_age_main_pay  NUMBER;
    v_fixed_commission     re_bordero_line.fixed_commission%TYPE;
    v_fixed_com_rate       re_bordero_line.fixed_com_rate%TYPE;
    v_is_inclusion_package re_bordero_package.is_inclusion_package%TYPE;
  BEGIN
    clear_bordero_log(par_bordero_package_id => par_bordero_package_id);
    t_decline := tbl_decline();
    t_change  := tbl_change();
    --  t_claim:= tbl_claim();
    --Смена статуса В расчете
    --  doc.set_doc_status(par_bordero_package_id,'IN_CALCULATE');
  
    --Определяем версию и период действия пакета бордеро
    SELECT bp.re_contract_id
          ,CASE bp.is_inclusion_package
             WHEN 0 THEN
              bp.start_date
             WHEN 1 THEN
              ADD_MONTHS(mc.start_date, -12)
           END AS start_date
          ,CASE bp.is_inclusion_package
             WHEN 0 THEN
              bp.end_date
             WHEN 1 THEN
              mc.start_date - 1
           END AS end_date
          ,bp.re_m_contract_id
          ,bp.is_inclusion_package
      INTO v_re_version_id
          ,d_start_bordero
          ,d_end_bordero
          ,v_re_main_contract_id
          ,v_is_inclusion_package
      FROM re_bordero_package bp
          ,re_main_contract   mc
     WHERE bp.re_bordero_package_id = par_bordero_package_id
       AND bp.re_m_contract_id = mc.re_main_contract_id;
  
    --Берем параметры версии
    SELECT *
      INTO v_re_contract_version
      FROM re_contract_version cv
     WHERE cv.re_contract_version_id = v_re_version_id;
  
    clear_bordero(par_bordero_package_id);
  
    -- Определяем режим вычисления ставки нетто-тарифа
    v_netto_tariff_mode := nvl(pkg_app_param.get_app_param_n(p_brief => 'NETTO_TARIFF_CALC_MODE'), 0);
  
    FOR cur IN (SELECT --Check_policy(p.pol_header_id, p.start_date) as pol_id,
                 prod.brief AS prod_brief
                ,ph.policy_header_id
                ,p.policy_id
                ,p.version_num
                ,p.first_pay_date
                ,pc.p_cover_id
                ,pv.product_id
                ,pl.id AS product_line_id
                ,plo.id AS product_line_options_id
                ,pl.product_line_type_id
                ,c.obj_name_orig AS assured_name
                ,cp.date_of_birth
                ,plo.description AS plo_description
                ,plo.brief AS plo_brief
                ,nvl(pm.start_date, ph.start_date) AS start_date_main -- ** #П58
                ,pc.start_date
                ,pc.end_date
                ,ph.start_date AS pol_start_date
                ,(SELECT MAX(pp.end_date) FROM p_policy pp WHERE pp.pol_header_id = ph.policy_header_id) AS pol_end_date
                ,f.brief AS fund_brief
                ,pc.ins_amount
                ,pc.rvb_value
                ,UPPER(pl.msfo_brief) AS msfo_brief
                , --floor(pm.insured_age -  /** О21+ **/ months_between( get_anniversary_date(pm.start_date, ph.start_date /** О21 p.first_pay_date **/, 2),pm.start_date /** О21 p.first_pay_date **/)/12) as insured_age_main
                 trunc(MONTHS_BETWEEN(get_anniversary_date(nvl(pm.start_date, ph.start_date)
                                                          ,ph.start_date
                                                          ,2)
                                     ,cp.date_of_birth) / 12) AS insured_age_main -- ** #П58
                 -- * О15 Так как в поле p_cover.insured_age сохраняется значение страхового возраста на дату начала
                 -- * О15 страхования по всему договору, то к для того, чтобы получить страховой возраст на дату
                 -- * О15 начала покрытия необходимо к значению указанного поля добавить сдвиг относительно
                 -- * О15 даты начала договора
                , --floor(pc.insured_age - /** О21+ **/ months_between(get_anniversary_date(pc.start_date, ph.start_date /** О21 p.first_pay_date **/, 2),pc.start_date /** О21 p.first_pay_date **/)/12)
                 trunc(MONTHS_BETWEEN(get_anniversary_date(pc.start_date, ph.start_date, 2)
                                     ,cp.date_of_birth) / 12) AS insured_age
                 --Повышающие коэффициенты
                ,pkg_re_insurance.Check_koef(decode(pcu.is_s_coef_m_re_default
                                                   ,1
                                                   ,pc.s_coef_m
                                                   ,pcu.s_coef_m_re)
                                            ,decode(pcu.is_s_coef_nm_re_default
                                                   ,1
                                                   ,pc.s_coef_nm
                                                   ,pcu.s_coef_nm_re)
                                            ,decode(pcu.is_k_coef_m_re_default
                                                   ,1
                                                   ,pc.k_coef_m
                                                   ,pcu.k_coef_m_re)
                                            ,decode(pcu.is_k_coef_nm_re_default
                                                   ,1
                                                   ,pc.k_coef_nm
                                                   ,pcu.k_coef_nm_re)
                                            ,f.fund_id
                                            ,pv.product_id
                                            ,pl.id
                                            ,v_re_version_id) AS check_koef
                 --Лимит по продукту
                ,pkg_re_insurance.check_limit(pc.ins_amount
                                             ,f.fund_id
                                             ,pv.product_id
                                             ,pl.id
                                             ,v_re_version_id
                                             ,pi.contact_id) AS check_limit
                 --Количество застрахованных
                ,pkg_re_insurance.check_assured((SELECT COUNT(aa.as_assured_id)
                                                  FROM as_assured aa
                                                 WHERE aa.as_assured_id = a.as_asset_id
                                                 GROUP BY aa.assured_contact_id)
                                               ,v_re_version_id) AS check_assured
                 --Общий лимит
                ,pkg_re_insurance.check_total_limit((SELECT SUM(pc1.ins_amount)
                                                      FROM p_cover  pc1
                                                          ,as_asset a1
                                                     WHERE a1.as_asset_id = pc1.as_asset_id
                                                       AND a1.p_policy_id = p.policy_id)
                                                   ,f.fund_id
                                                   ,v_re_version_id) AS check_total_limit
                 --Совокупный лимит
                 --        ,pkg_re_insurance.Check_limit_contract(prod.product_id, pl.id,v_re_version_id, plo.id, f.fund_id) as check_limit_contract
                 --Наличие программы на закладке Перестраховаение в договоре страхования
                ,(SELECT COUNT(rprp.policy_reinsurance_program_id)
                    FROM re_policy_reinsurance_program rprp
                   WHERE rprp.policy_id = p.policy_id
                     AND rprp.product_line_id = pl.id
                     AND rprp.fund_id = f.fund_id) AS in_reins_program
                ,ar.re_bordero_type_id
                ,ar.flg_all_program
                ,ar.flg_no_comis
                ,nvl(ar.re_discount_proc, 0) AS re_discount_proc
                ,ar.p_re_id
                ,p.is_group_flag
                 --       ,pt.is_periodical
                ,decode(pt.is_periodical, 0, 1, 0) AS is_not_periodical
                ,pt.description
                ,pt.number_of_payments
                 --       ,pto.number_of_payments as number_pay_off --*2 данное поле не используется в логике процедуры, однако приводит к проблемам с отбором так поле не везде заполнено
                 --Значения повышающих коэффициентов
                ,nvl(decode(pcu.is_s_coef_m_re_default, 1, pc.s_coef_m, pcu.s_coef_m_re), 0) AS s_coem_m
                ,nvl(decode(pcu.is_s_coef_nm_re_default, 1, pc.s_coef_nm, pcu.s_coef_nm_re), 0) AS s_coef_nm
                ,nvl(decode(pcu.is_k_coef_m_re_default, 1, pc.k_coef_m, pcu.k_coef_m_re), 0) AS k_coef_m
                ,nvl(decode(pcu.is_k_coef_nm_re_default, 1, pc.k_coef_nm, pcu.k_coef_nm_re), 0) AS k_coef_nm
                ,nvl(pc.s_coef, 0) AS s_coef
                ,nvl(pc.k_coef, 0) AS k_coef
                ,nvl(pc.normrate_value, 0) AS normrate_value
                ,decode(cp.gender, 1, 'm', 'w') AS sex
                ,cp.gender
                ,pc.premium
                ,pc.tariff_netto
                ,pc.is_avtoprolongation
                ,CEIL(MONTHS_BETWEEN(trunc(nvl(pm.end_date, p.end_date)) + 1
                                    ,trunc(nvl(pm.start_date, ph.start_date))) / 12) AS period_value_main -- ** #П58
                ,CEIL(MONTHS_BETWEEN(trunc(pc.end_date) + 1, trunc(pc.start_date)) / 12) AS period_value
                ,a.as_asset_id
                , --a.contact_id
                 ard.assured_contact_id AS contact_id
                ,a.p_asset_header_id
                ,f.fund_id
                ,p.payment_term_id
                ,p.confirm_date
                ,DECODE(plr.func_id
                       ,NULL
                       ,plr.deathrate_id
                       ,pkg_tariff_calc.calc_fun(plr.func_id
                                                ,ent.id_by_brief('P_COVER')
                                                ,pc.p_cover_id)) AS deathrate_id
                 --  Тут надо брать возраст на дату страховой годовщины get_anniversary_date(pm.start_date, p.first_pay_date, 2)
                 --               ,trunc(months_between(pm.start_date,cpi.date_of_birth)/12) as issuer_age_main
                ,trunc(MONTHS_BETWEEN(get_anniversary_date(nvl(pm.start_date, ph.start_date)
                                                          ,ph.start_date
                                                          ,2)
                                     ,cpi.date_of_birth) / 12) AS issuer_age_main -- ** #П58
                ,decode(cpi.gender, 1, 'm', 'w') AS issuer_sex
                ,tl.brief AS insurance_type
                ,ard.work_group_id
                ,cpi.date_of_birth AS issuer_birthdate
                  FROM p_policy           p
                      ,p_pol_header       ph
                      ,t_product          prod
                      ,document           d
                      ,doc_status_ref     dsr
                      ,as_asset           a
                      ,contact            c
                      ,cn_person          cp
                      ,as_assured         ard
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                      ,t_lob              tl
                      ,t_period           per --* данная таблица нигде не используется
                      ,fund               f
                      ,t_product_ver_lob  pvl
                      ,t_product_version  pv
                      ,p_cover_underwr    pcu
                      ,as_assured_re      ar
                      ,t_payment_terms    pt
                       --        ,t_payment_terms pto
                      ,t_prod_line_rate plr
                      ,t_period         tpr --* данная таблица нигде не используется
                       
                       --
                      ,v_pol_issuer pi
                      ,cn_person    cpi
                       --
                       
                      ,(SELECT -- ** #П58 pc.insured_age,
                         pc.start_date
                        ,pc.end_date
                        ,pc.as_asset_id
                          FROM p_cover             pc
                              ,t_prod_line_option  plo
                              ,t_product_line      pl
                              ,t_product_line_type lt
                         WHERE pc.t_prod_line_option_id = plo.id
                           AND plo.product_line_id = pl.id
                           AND pl.product_line_type_id = lt.product_line_type_id
                           AND lt.brief = 'RECOMMENDED'
                           AND pc.status_hist_id != 3 /*только неисключенные программы*/
                        ) pm
                 WHERE p.policy_id = pi.policy_id
                      -- Если это пакет заключения, то нужно проверить дату расторжения последней версии
                   AND (v_is_inclusion_package = 0 OR EXISTS
                        (SELECT NULL
                           FROM p_policy ppl
                          WHERE ppl.policy_id = ph.last_ver_id
                            AND (ppl.decline_date <= d_end_bordero OR ppl.decline_date IS NULL)))
                   AND pi.contact_id = cpi.contact_id(+)
                   AND ph.policy_header_id = p.pol_header_id
                   AND prod.product_id = ph.product_id
                   AND dsr.doc_status_ref_id = d.doc_status_ref_id
                   AND d.document_id = p.policy_id
                      --*        and dsr.brief not in ('STOPED', 'CANCEL', 'CLOSE', 'ERROR','BREAK','PROJECT','STOP')
                      --*        and dsr.brief not like '%QUIT%'
                      --* Отладка (возникает ошибка при начитке тарифа в бордеро изменений в промежуточных датах)
                      --        and ph.policy_header_id in (38926360)
                      --*
                      
                      -- Тестовые примеры 31.03.2011
                      --        and (ph.policy_header_id in (29343347,19525355,19314360,19322737,27976323,26333894,29840242,29108692,20456139,20851004) or ph.policy_header_id in (18224031, 20638634))
                      --        and ph.policy_header_id in (29343347) -- (19525355) -- (19314360) -- (19322737)-- (20456139) -- (19525355) --(29343347) -- -- -- --(27976323) --,26333894,27976323,19322737,19314360,19525355,29840242,29343347,29108692,20456139,20851004) --Оганичение по договорам
                      --        and ph.policy_header_id in (27976323) --(10645479)-- (26333894)-- (27976323) --(19525355) --(29343347,19525355,19314360,19322737,20456139,19525355,29343347,27976323,26333894,27976323,19322737,19314360,19525355,29840242,29343347,29108692,20456139,20851004) (19525355) --(29343347,19525355,19314360,19322737,20456139,19525355,29343347,27976323,26333894,27976323,19322737,19314360,19525355,29840242,29343347,29108692,20456139,20851004) --Оганичение по договорам
                      
                      -- тестирование убытков
                      -- индивидуальные ДС
                      -- and ph.policy_header_id in (26333894) -- БЗУ 31.03.2011 --(27976323) -- БОУ 31.03.2011  20638634
                      --        and ph.policy_header_id in (18224031, 20638634) -- (29343347,19525355,19314360,19322737,27976323,26333894,29840242,29108692,20456139,20851004)
                      -- корпоративные ДС
                      --        and ph.policy_header_id in (28887327) and c.contact_id = 1066294 -- Б3У 31.03.2011 БОУ 30.06.2011
                      --        and ph.policy_header_id in (27976323,29343347,19525355,20456139,19322737,19314360,19525355,29840242) -- актуарный резерв
                      
                      --        and ph.policy_header_id = /*30292685*/30293804
                      --        and ard.assured_contact_id = /*1264498*/641299
                      --          and ph.policy_header_id = 19525355 and pl.msfo_brief = 'WOP' -- WOP
                      --          and ph.policy_header_id = 29840242 and pl.msfo_brief = 'PWOP' -- PWOP
                      --          and ph.policy_header_id = 20456139 and pl.msfo_brief = 'FAMDEP' -- FAMDEP
                      --          and ph.policy_header_id = 38533606 and ard.assured_contact_id = 893482 and pl.id = 16589  -- диагностика ошибки Гейнц
                      --          and ph.policy_header_id = 38686963 and ard.assured_contact_id = 211741 and pl.id = 26996 and p.policy_id = 38686762 -- дубли в корпоративных договорах
                      --            and ph.policy_header_id = 798514 and pl.msfo_brief = 'END' -- пример Решетняка с неправильным возрастом в поле re_bordero_line.assurer_age Бордеро 3 кв. 2010
                      --            and ph.policy_header_id = 819822 and pl.msfo_brief = 'END' -- единовременная периодичность (долгосрочный договор с актуарным резервом)
                      --            and ph.policy_header_id = 834377 and p.policy_id = 33146004 and pl.msfo_brief = 'END' -- задвоение строк в бордеро 4 кв. 2009 (пример Решетняка)
                      --              and ph.policy_header_id = 12880696 and pl.msfo_brief = 'CRED'
                      
                      --              and ph.policy_header_id = 30965672
                      -- Корпоративный договор, по которому не проставляются сумма премии
                      --              and ph.policy_header_id = 27184952 and UPPER(pl.msfo_brief) = 'TERM' and ard.assured_contact_id = 1013792
                      --              and ph.policy_header_id = 819822 and UPPER(pl.msfo_brief) = 'END'
                      
                      -- Пример Решетняка с неправильно рассчитанным возрастом
                      --              and ph.policy_header_id = 796633 and UPPER(pl.msfo_brief) = 'TERM'
                      -- Пример Решетняка с неправильно рассчитанной величиной OBI для покрытия WOP
                      --              and ph.policy_header_id = 7694026 and UPPER(pl.msfo_brief) = 'WOP'
                      -- Пример Решетняка с неправильно рассчитанным резервов по программе 'TERM'
                      --              and ph.policy_header_id = 796633 and UPPER(pl.msfo_brief) = 'TERM'
                      -- Пример Решетняка с неправильно рассчитанным резервов по программе 'WOP'
                      --              and ph.policy_header_id = 7694026 and UPPER(pl.msfo_brief) = 'WOP'
                      
                      ------------------------------
                      
                      -- Исключение договоров при потоковом тестировании
                      
                      --and pl.t_lob_line_id not in (6322,6323,30500044,92) -- ('WOP','PWOP','WOP_Life','PWOP_Life') исключение из потоков до исправления несоответствия 71 файла внутреннего тестирования
                      
                      -- *** Пример договора в период основной программы которого актуарный возраст застрахованного
                      -- достигает 66 лет
                      --              and ph.policy_header_id = 31535766 and UPPER(pl.msfo_brief) = 'PWOP'
                      
                      --and pc.p_cover_id=752127 -- ситуация с отсутствием тарифов
                      
                      -- Конец Исключение договоров при потоковом тестировании
                      
                      ------------------------------
                      -- Тестирование ОПЕРУ на выборочных продуктах
                      --and ph.ids = 2020005113 -- пустое значение YRP
                      -- and pc.p_cover_id = 45526273 --неверное значение возраста, связанное со сдвигом даты первого платежа
                      --and ph.policy_header_id = 38585136 --неверное значение возраста, связанное со сдвигом даты первого платежа
                      --and pc.p_cover_id = 51745235 -- неверное значение возраста (пример 2)
                      ------------------------------
                      --Тестовая вставка 08052013
                      
                      --and ph.ids = 2550006320
                      --and ph.ids = 2020005113 and pc.p_cover_id = 51745235
                      --and ph.ids = 1140093127 -- and pc.p_cover_id = 752127 -- Тестовый пример О18
                      --and (ph.ids = 1140093127 or ph.ids = 2550006320) -- Тестирование отката транзакции только по одному покрытию с продолжением вычисления по другим покрытиям.
                      --and pc.p_cover_id = 9088578
                      --and pc.p_cover_id = 22341779 -- неопределенный проф.класс
                      --and ph.policy_header_id = 38927986 and pc.p_cover_id = 10513168 -- зависимость тарифа от страховой суммы
                      ------------------------------
                      -- 3-й этап тестирования
                      --and ph.ids = 2550012998 and UPPER(pl.msfo_brief) = 'DD' -- пример совпадающей нетто-ставки
                      --and ph.ids = 2550006137 and UPPER(pl.msfo_brief) = 'DD'
                      --and ph.ids = 1230138887 and UPPER(pl.msfo_brief) = 'FAMDEP'
                      --and p.pol_header_id = 8591851 and UPPER(pl.msfo_brief) = 'FAMDEP'
                      --and ph.ids = 2550002140 and UPPER(pl.msfo_brief)= 'WOP'
                      --and ph.ids = 1140229138 and UPPER(pl.msfo_brief)= 'END' -- END нетто-ставка
                      ------------------------------
                      -- 4-ый этап тестирования
                      --and ph.ids = 1190004926 and UPPER(pl.msfo_brief)= 'TERM_FIX'
                      --and ph.ids = 1920125443
                      
                      -- Сужение по продуктам 
                      -- SCOR_IND (с актуарным резервом)
                      /*
                      and (
                          (v_re_version_id = 63949948 and ph.product_id in (28487)) -- Семейный депозит --(2267,7679,28487,28290,38555))
                          or v_re_version_id != 63949948
                          )
                      */
                      -- SCOR_CRED
                      
                      /*
                      and (
                          (v_re_version_id = 63949962 and ph.product_id in (35372)) -- CR47 13108,13112,13118,13120,13122,13124,13127,13129,13131,13134))
                          or v_re_version_id != 63949962
                          )
                      */
                      -- GRS_IND
                      /*AND (v_re_version_id != 63949971 OR
                      (v_re_version_id = 63949971 AND ph.product_id = 43622) -- КС CR92_2 ООО "ХКФ БАНК" Кредиты наличными (самый маленький по содержанию продукт 51674/1583488=3.3% договоров)
                      )*/
                      
                      -- Актуарный резерв FamDep Scor Ind Оперу
                      --and ph.ids = 1230089485
                      --and ((v_re_version_id = 63923022 and ph.ids in (1230089485,1230059890))
                      --    or v_re_version_id != 63923022
                      --    )
                      --and ph.ids = 1230059890 and UPPER(pl.msfo_brief) = 'FAMDEP' -- FAMDEP сверка с Поляковским
                      --                      and ph.policy_header_id = 20456139 and UPPER(pl.msfo_brief) = 'FAMDEP' -- FAMDEP (пример, рассчитанный Решетняком в test-case)
                      --and ph.ids = 2240052133 -- пример по ошибке ORA-01841
                      --and ph.policy_header_id = 58374152 -- пример по HANN_IND 3 кв. 2012 со статусом 'Передано Агенту'
                      ------------------------------
                      -- Тестирование доработок для ПУ                   
                      --and ph.product_id = 32680 -- Экспресс-Семья 15 договоров страхования                   
                      --and ph.product_id = 46763 -- Продукт для HANN_IND 127 договоров
                      --and ph.policy_header_id = 30178949 -- договор для тестирования пакета заключения
                      --and ph.policy_header_id in (57077739) --,14005028) -- тестирование взимание фиксированной комиссии в года позже первого
                      --and ph.policy_header_id in (38853998) -- пробный пример договора по GRS_IND
                      
                      ------------------------------
                      
                   AND a.p_policy_id = p.policy_id
                   AND c.contact_id = a.contact_id
                   AND pc.as_asset_id = a.as_asset_id
                   AND pm.as_asset_id(+) = a.as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND plo.product_line_id = pl.id
                   AND cp.contact_id = ard.assured_contact_id
                   AND per.id = pc.period_id
                   AND f.fund_id = ph.fund_id
                   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                   AND pvl.lob_id = tl.t_lob_id
                   AND pv.t_product_version_id = pvl.product_version_id
                   AND pcu.p_cover_underwr_id(+) = pc.p_cover_id
                   AND a.as_asset_id = ard.as_assured_id
                      --Фильтр по перестраховщику
                      --*        and ar.p_re_id=(select mc.reinsurer_id from re_contract_version cv, re_main_contract mc
                      --*                       where cv.re_main_contract_id=mc.re_main_contract_id and cv.re_contract_version_id=v_re_version_id)
                      --* надо брать запись по версии договора перестрахования, а не по перестраховщику
                      --* иначе это приводит к дублированию записей так как договоров на одном перестраховщике
                      --* может быть несколько
                   AND ar.re_contract_version_id = v_re_version_id
                      --*
                   AND ar.p_policy_id = p.policy_id
                   AND pt.id = p.payment_term_id
                      --        and pto.id=p.paymentoff_term_id -- данное поле не используется в логике процедуры, однако приводит к проблемам с отбором так поле не везде заполнено
                   AND plr.product_line_id(+) = pl.id
                   AND tpr.id = pc.period_id
                      --Фильтр по списку валют договора перестрахования
                   AND f.fund_id IN (SELECT vf.fund_id
                                       FROM re_contract_ver_fund vf
                                      WHERE vf.re_contract_version_id = v_re_version_id)
                      --Фильтр по списку рисков договора перестрахования
                   AND pl.id IN (SELECT v.product_line_id
                                   FROM re_cond_filter_obl   v
                                       ,re_contract_ver_fund vf
                                  WHERE v.re_contract_ver_fund_id = vf.re_contract_ver_fund_id
                                    AND v.re_contract_ver_id = v_re_version_id
                                    AND vf.fund_id = ph.fund_id)
                   AND pv.product_id IN (SELECT v.product_id
                                           FROM re_cond_filter_obl   v
                                               ,re_contract_ver_fund vf
                                          WHERE v.re_contract_ver_fund_id = vf.re_contract_ver_fund_id
                                            AND v.re_contract_ver_id = v_re_version_id
                                            AND vf.fund_id = ph.fund_id)
                      --Фильтр по признаку "Отказан перестраховщиком"
                   AND nvl(pcu.is_reinsurer_failure, 0) = 0
                      --Фильтр по периодам. Если покрытие действует хотя бы один день в период действия бордеро
                   AND pkg_re_insurance.Check_cover_period(pc.start_date
                                                          ,pc.end_date
                                                          ,d_start_bordero
                                                          ,d_end_bordero) = 1
                   AND pc.ins_amount > 0 --
                   AND pc.status_hist_id != 3 /* только неисключенные программы */
                   AND EXISTS (SELECT NULL
                          FROM doc_status ds
                         WHERE ds.document_id = p.policy_id
                           AND (ds.doc_status_ref_id IN (91 -- CONCLUDED - Договор подписан
                                                        ,2 -- CURRENT - Действующий
                                                         --#П59_1                                                       ,89 -- ** #П59-- PASSED_TO_AGENT - Передано Агенту
                                                         )
                               -- #П59_1 Скорректировано на переход 'Проект'->'Передано Агенту', а не просто в 'Передано Агенту'
                               OR (ds.doc_status_ref_id = 89 -- #П59_1 Передано Агенту
                               AND ds.src_doc_status_ref_id = 16 -- #П59_1 Проект
                               )
                               
                               ))
                --*        and p.policy_id = Check_policy(p.pol_header_id, d_start_bordero)
                /*where pkg_re_insurance.Check_cover_in_bordero(p_cover_id,v_re_contract_version.re_contract_version_id,
                re_bordero_type_id, in_reins_program,flg_all_program)=1
                and check_assured = 1*/
                )
    LOOP
      SAVEPOINT before_calc_bordero_loop;
      BEGIN
        /* Актуарный возраст на конец основной программы */
        --      v_insured_age_main := cur.period_value_main + cur.insured_age_main;
        --  Нужен возраст страхователя, а не застрахованного
        v_issuer_age_main := cur.period_value_main + cur.issuer_age_main - 1;
      
        --if cur.msfo_brief in ('WOP','PWOP') is null or cur.period_value + cur.insured_age <= gc_max_age_wop then
      
        /** О17 Логика переменной нормы доходности по программе FAMILY_DEP перенесена в ветвление
        при вычислении актуарных функций, а в целом по продукту так ветвить не надо
        просто должно быть всегда n_norm_rate:=cur.normrate_value;
        О17
               if upper(cur.prod_brief) ='FAMILY_DEP' then
                 n_norm_rate:=get_norm_rate(cur.period_value);
               else
                 n_norm_rate:=cur.normrate_value;
               end if;
        О17 **/
        -- ** О17 Добавление по несоответствию
        n_norm_rate := cur.normrate_value;
        -- ** О17 Конец Добавление по несоответствию
      
        -- ** О20 Добавление по несоответствию
        IF cur.is_not_periodical = 0
        THEN
          -- Если MSFO_BRIEF одно из DD, TERM, END, TERM_FIX
          IF cur.msfo_brief IN ('DD', 'TERM', 'END', 'TERM_FIX')
          THEN
            IF n_norm_rate = 0
            THEN
              BEGIN
                SELECT nvl(pln.value, nr.value)
                  INTO n_norm_rate
                  FROM normrate         nr
                      ,t_product_line   pr
                      ,t_prod_line_norm pln
                 WHERE nr.t_lob_line_id = pr.t_lob_line_id
                   AND pr.id = cur.product_line_id
                   AND pr.id = pln.product_line_id(+)
                   AND nr.base_fund_id = cur.fund_id
                   AND cur.pol_start_date BETWEEN nr.d_begin AND nvl(nr.d_end, cur.pol_start_date);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  raise_application_error(-20001
                                         ,'Не найдена норма доходности');
                WHEN TOO_MANY_ROWS THEN
                  raise_application_error(-20001
                                         ,'Найдено несколько значений норм доходности');
              END;
            END IF;
          END IF;
        END IF;
        -- ** О20 Конец Добавление по несоответствию
      
        -- Вычисляем нетто-тариф
        -- если параметр системы NETTO_TARIFF_CALC_MODE = 1
        IF v_netto_tariff_mode = 1
        THEN
          -- если взнос не единовременный
          IF cur.is_not_periodical = 0
          THEN
            -- Если MSFO_BRIEF одно из DD, TERM, END, FAM_DEP, TERM_FIX
          
            IF cur.msfo_brief IN ('DD', 'TERM', 'END', 'FAMDEP', 'TERM_FIX')
            THEN
              /** О20 Исходный код             if n_norm_rate is null then
                             begin
                               select nvl(pln.value, nr.value)
                                 into n_norm_rate
                                 from normrate         nr
                                     ,t_product_line   pr
                                     ,t_prod_line_norm pln
                                where nr.t_lob_line_id = pr.t_lob_line_id
                                  and pr.id            = cur.product_line_id
                                  and pr.id            = pln.product_line_id (+)
                                  and nr.base_fund_id  = cur.fund_id
                                  and cur.pol_start_date between nr.d_begin and nvl(nr.d_end, cur.pol_start_date);
                             exception
                               when NO_DATA_FOUND then
                                 raise_application_error(-20001,'Не найдена норма доходности');
                               when TOO_MANY_ROWS then
                                 raise_application_error(-20001,'Найдено несколько значений норм доходности');
                             end;
                           end if;
              О20 **/
              -- О24 Старая процедура
            
              cur.tariff_netto := get_netto_tariff(par_p_cover_id        => cur.p_cover_id
                                                  ,par_version_num       => cur.version_num
                                                  ,par_pol_header_id     => cur.policy_header_id
                                                  ,par_prod_line_opt_id  => cur.product_line_options_id
                                                  ,par_asset_header_id   => cur.p_asset_header_id
                                                  ,par_msfo_brief        => cur.msfo_brief
                                                  ,par_header_start_date => cur.pol_start_date
                                                  ,par_date_of_birth     => cur.date_of_birth
                                                  ,par_sex               => cur.sex
                                                  ,par_deathrate_id      => cur.deathrate_id
                                                  ,par_norm_rate         => n_norm_rate);
            
              -- О24 Новая процедура                                                 
              /*
                           cur.tariff_netto := get_netto_tariff_new(par_p_cover_id        => cur.p_cover_id
                                                               ,par_version_num       => cur.version_num
                                                               ,par_pol_header_id     => cur.policy_header_id
                                                               ,par_prod_line_opt_id  => cur.product_line_options_id
                                                               ,par_asset_header_id   => cur.p_asset_header_id
                                                               ,par_msfo_brief        => cur.msfo_brief
                                                               ,par_header_start_date => cur.pol_start_date
                                                               ,par_date_of_birth     => cur.date_of_birth
                                                               ,par_sex               => cur.sex
                                                               ,par_deathrate_id      => cur.deathrate_id
                                                               ,par_norm_rate         => n_norm_rate);
              */
            ELSE
              cur.tariff_netto := 0;
            END IF;
          ELSE
            cur.tariff_netto := 0;
          END IF;
        END IF;
      
        IF p_t = 1
        THEN
          IF cur.msfo_brief NOT IN ('WOP', 'PWOP', 'FAMDEP')
          THEN
            -- В случае пустого cur.msfo_brief актуарные функции не вычисляются
            -- при этом функция get_t_v возвращает 0, т.е. система в этом случае
            -- рассматривает программу, как программу без актуарного резерва
            n_A1_xn := pkg_AMATH.Ax1n(cur.insured_age
                                     ,cur.period_value
                                     ,cur.sex
                                     ,cur.k_coef
                                     ,cur.s_coef
                                     ,nvl(cur.deathrate_id, 1)
                                     ,n_norm_rate); -- cur.normrate_value);
            n_A_xn  := pkg_AMATH.Axn(cur.insured_age
                                    ,cur.period_value
                                    ,cur.sex
                                    ,cur.k_coef
                                    ,cur.s_coef
                                    ,nvl(cur.deathrate_id, 1)
                                    ,n_norm_rate); --cur.normrate_value);
            n_a_x_n := pkg_AMATH.a_xn(cur.insured_age
                                     ,cur.period_value
                                     ,cur.sex
                                     ,cur.k_coef
                                     ,cur.s_coef
                                     ,1
                                     ,nvl(cur.deathrate_id, 1)
                                     ,n_norm_rate); --cur.normrate_value);
          ELSIF cur.msfo_brief = 'WOP'
          THEN
            IF v_issuer_age_main > gc_max_age_wop
            THEN
              cur.period_value_main := cur.period_value_main - (v_issuer_age_main - gc_max_age_wop);
            END IF;
            n_A1_xn := pkg_AMATH.Ax1n(cur.issuer_age_main
                                     ,cur.period_value_main
                                     ,cur.issuer_sex
                                     ,cur.k_coef
                                     ,cur.s_coef
                                     ,gv_deatrate_wop_id
                                     ,n_norm_rate); -- cur.normrate_value);
            n_A_xn  := pkg_AMATH.Axn(cur.issuer_age_main
                                    ,cur.period_value_main
                                    ,cur.issuer_sex
                                    ,cur.k_coef
                                    ,cur.s_coef
                                    ,gv_deatrate_wop_id
                                    ,n_norm_rate); --cur.normrate_value);
            n_a_x_n := pkg_AMATH.a_xn(cur.issuer_age_main
                                     ,cur.period_value_main
                                     ,cur.issuer_sex
                                     ,cur.k_coef
                                     ,cur.s_coef
                                     ,1
                                     ,gv_deatrate_wop_id
                                     ,n_norm_rate); --cur.normrate_value);
          ELSIF cur.msfo_brief = 'PWOP'
          THEN
            IF v_issuer_age_main > gc_max_age_wop
            THEN
              cur.period_value_main := cur.period_value_main - (v_issuer_age_main - gc_max_age_wop);
            END IF;
            n_A1_xn := pkg_AMATH.Ax1n(cur.issuer_age_main
                                     ,cur.period_value_main
                                     ,cur.issuer_sex
                                     ,cur.k_coef
                                     ,cur.s_coef
                                     ,gv_deatrate_pwop_id
                                     ,n_norm_rate); -- cur.normrate_value);
            n_A_xn  := pkg_AMATH.Axn(cur.issuer_age_main
                                    ,cur.period_value_main
                                    ,cur.issuer_sex
                                    ,cur.k_coef
                                    ,cur.s_coef
                                    ,gv_deatrate_pwop_id
                                    ,n_norm_rate); --cur.normrate_value);
            n_a_x_n := pkg_AMATH.a_xn(cur.issuer_age_main
                                     ,cur.period_value_main
                                     ,cur.issuer_sex
                                     ,cur.k_coef
                                     ,cur.s_coef
                                     ,1
                                     ,gv_deatrate_pwop_id
                                     ,n_norm_rate); --cur.normrate_value);
          ELSIF cur.msfo_brief = 'FAMDEP'
          THEN
            --* Для программы 'Смешанное страхование жизни' в продукте 'Семейный депозит'
            --* используется таблица смертности SF_AVCR ID=101
            n_A1_xn := pkg_AMATH.Axt1nt_FAMDEP(cur.insured_age
                                              ,cur.period_value
                                              ,0
                                              ,cur.sex
                                              ,cur.k_coef
                                              ,cur.s_coef
                                              ,101 /**nvl( cur.deathrate_id,1)**/); -- cur.normrate_value);
            n_A_xn  := pkg_AMATH.Axtnt_FAMDEP(cur.insured_age
                                             ,cur.period_value
                                             ,0
                                             ,cur.sex
                                             ,cur.k_coef
                                             ,cur.s_coef
                                             ,101 /**nvl(cur.deathrate_id,1)**/); --cur.normrate_value);
            n_a_x_n := pkg_AMATH.a_xtnt_FAMDEP(cur.insured_age
                                              ,cur.period_value
                                              ,0
                                              ,cur.sex
                                              ,cur.k_coef
                                              ,cur.s_coef
                                              ,1
                                              ,101 /**nvl(cur.deathrate_id,1)**/); --cur.normrate_value);
          END IF;
          --         n_P:=get_P(cur.p_cover_id, cur.prod_brief, n_A_xn, n_a_x_n, cur.is_not_periodical);
          t_V   := get_t_v(cur.period_value
                          ,0
                          ,cur.msfo_brief
                          ,n_A1_xn
                          ,n_A_xn
                          ,n_a_x_n
                          ,cur.is_not_periodical
                          , /*cur.number_of_payments,/* cur.number_pay_off,*/n_norm_rate
                          ,cur.tariff_netto
                          ,v_re_contract_version.flg_no_calc_reserve); -- cur.premium);
          t_O_V := t_v;
        END IF;
      
        n_reserve := cur.ins_amount * t_V;
      
        n_OBI := get_OBI(cur.ins_amount
                        ,t_O_V
                        ,cur.is_not_periodical
                        ,cur.msfo_brief
                        , /*n_A_xn*/n_a_x_n
                        ,v_re_contract_version.flg_no_calc_reserve);
      
        n_limit := get_limit(v_re_version_id
                            ,cur.policy_id
                            ,cur.as_asset_id
                            ,cur.p_re_id
                            ,cur.product_line_id
                            ,cur.fund_id
                            ,cur.rvb_value);
      
        n_percent := get_limit_percent(v_re_version_id
                                      ,cur.policy_id
                                      ,cur.as_asset_id
                                      ,cur.p_re_id
                                      ,cur.product_line_id
                                      ,cur.fund_id
                                      ,cur.rvb_value);
      
        n_IR := get_IR_by_func(v_re_version_id
                              ,cur.product_line_id
                              ,cur.fund_id
                              ,n_percent
                              ,n_OBI
                              ,n_limit);
        --n_IR:=least(n_percent * n_OBI, n_limit);
        n_RS := get_RS_by_func(v_re_version_id
                              ,cur.product_line_id
                              ,cur.fund_id
                              ,n_percent
                              ,n_OBI
                              ,n_limit);
        --n_RS := 1 - n_IR / n_OBI;
      
        n_ISRAR := n_OBI - n_IR;
        n_OBR   := n_OBI * n_RS;
      
        n_year          := 0;
        v_pay_last_date := to_date('01.01.1900', 'DD.MM.YYYY');
        --цикл по платежам
        FOR pay IN (SELECT ap.plan_date
                          ,ap.payment_id
                          ,ap.payment_number
                          ,ap.fund_id
                          ,p.policy_id
                          ,p.start_date
                          ,p.decline_date
                          ,cur.pol_start_date AS first_pay_date /** О21 **/ -- О21 p.first_pay_date
                      FROM (SELECT p.policy_id
                                  ,p.start_date
                                  ,p.decline_date
                                   --,p.first_pay_date
                                  ,ADD_MONTHS((p.end_date + 1), -round(12 / (tpt.number_of_payments))) AS end_period
                              FROM p_policy        p
                                  ,t_payment_terms tpt
                             WHERE p.pol_header_id = cur.policy_header_id
                               AND tpt.id = p.payment_term_id
                               AND tpt.is_periodical != 0) p
                          ,ac_payment ap
                          ,doc_doc dd
                          ,document dc
                          ,doc_templ dt
                          ,doc_status_ref dsr
                     WHERE dd.parent_id = p.policy_id
                       AND dd.child_id = ap.payment_id
                       AND ap.fund_id = cur.fund_id
                       AND ap.payment_id = dc.document_id
                       AND dc.doc_templ_id = dt.doc_templ_id
                       AND dt.brief = 'PAYMENT'
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief != 'ANNULATED'
                       AND ap.plan_date <= p.end_period
                       AND ap.plan_date BETWEEN d_start_bordero AND d_end_bordero --Фильтр по периоду бордеро ???
                          --  Необходимо отбирать оплаченные периоды только в период действия покрытия
                       AND ap.plan_date BETWEEN cur.start_date AND cur.end_date
                    UNION ALL
                    SELECT pv.plan_date
                          ,NULL               AS payment_id
                          ,NULL               AS payment_number
                          ,cur.fund_id
                          ,NULL               AS policy_id
                          ,cur.pol_start_date AS start_date
                          ,NULL               AS decline_date
                          ,cur.pol_start_date AS first_pay_date /** О21 **/ -- О21 cur.first_pay_date
                      FROM (SELECT plan_date
                              FROM (SELECT ADD_MONTHS(cur.pol_start_date, (rownum - 1) * 12) AS plan_date
                                      FROM dual
                                    CONNECT BY rownum <=
                                               1 +
                                               MONTHS_BETWEEN(cur.pol_end_date, cur.pol_start_date) / 12)
                            /*
                              Байтин А.
                              При переборе страховых годовщин по договорам с единовременным взносом
                              в случае установленного признака IS_ONE_STRING_FOR_SINGLE_PREMIUM
                              и если на обрабатываемом пакете бордеро не установлен признак ‘Пакет заключения’
                              во второй части запроса курсора pay должна отбираться только нулевая страховая годовщина
                              по договору страхования, а не все страховые годовщины по договору.
                              Таким образом будет реализован режим добавления только одной строки
                              бордеро премий по договорам с единовременным взносом.
                            */
                             WHERE ((cur.is_not_periodical = 1 AND v_is_inclusion_package = 0 AND
                                   v_re_contract_version.flg_one_str_for_one_prem = 1 AND
                                   plan_date = cur.start_date) OR
                                   ((cur.is_not_periodical = 0 OR v_is_inclusion_package = 1 OR
                                   v_re_contract_version.flg_one_str_for_one_prem = 0) AND
                                   plan_date BETWEEN cur.start_date AND cur.end_date))
                               AND plan_date BETWEEN d_start_bordero AND d_end_bordero
                                  --  Необходимо отбирать страховые годовщины только в период действия покрытия
                               AND plan_date BETWEEN cur.start_date AND cur.end_date) pv
                     WHERE EXISTS (SELECT NULL
                              FROM p_policy        p
                                  ,t_payment_terms tpt
                             WHERE p.pol_header_id = cur.policy_header_id
                               AND tpt.id = p.payment_term_id
                               AND tpt.is_periodical = 0)
                     ORDER BY payment_number
                             ,plan_date
                    /*select ap.plan_date
                         ,ap.payment_id
                         ,ap.payment_number
                         ,ap.fund_id
                         ,p.policy_id
                         ,p.start_date
                         ,p.decline_date
                         ,p.first_pay_date
                     from p_policy        p
                         ,ac_payment      ap
                         ,doc_doc         dd
                         ,t_payment_terms tpt
                    where dd.parent_id    = p.policy_id
                      and dd.child_id     = ap.payment_id
                      and p.pol_header_id = cur.policy_header_id
                      and ap.fund_id      = cur.fund_id
                      and (
                           (ap.plan_date <= add_months((p.end_date + 1),-round(12/(tpt.number_of_payments)))
                            and tpt.is_periodical <> 0
                           )
                           or
                           (ap.plan_date <= p.first_pay_date and tpt.is_periodical = 0)
                           )
                      and tpt.id = p.payment_term_id
                      and ap.plan_date between d_start_bordero and d_end_bordero  --Фильтр по периоду бордеро ???
                    order by ap.payment_number*/
                    )
        LOOP
          IF v_pay_last_date <> pay.plan_date
          THEN
            -- if v_pay_last_date <> pay.plan_date
            --          if pay.payment_number=1 then  --Запоминаем первый платеж по договору страхования
            --          if  v_pay_first_date = pay.plan_date then
            v_pay_first_date := nvl(pay.first_pay_date, pay.plan_date);
          
            d_re_start_date := get_re_start_date(pay.plan_date, cur.start_date, v_pay_first_date);
          
            v_insured_age_pay     := trunc(MONTHS_BETWEEN(d_re_start_date, cur.date_of_birth) / 12);
            v_issuer_age_main_pay := trunc(MONTHS_BETWEEN(d_re_start_date, cur.issuer_birthdate) / 12);
          
            d_re_expiry_date := get_re_end_date(pay.plan_date
                                               ,v_pay_first_date
                                               ,cur.end_date
                                               ,v_re_contract_version.flg_one_str_for_one_prem); --  add_months(d_re_start_date,12)-1;
            /** О12 Исправления в соответствии с замечанием О12 файла анализа кода О12 **/
            v_premium_type_id := get_premium_type(pay.plan_date, d_end_bordero, 10); --Определяем тип премии. 10 - тип Премия
          
            /** О12 конец исправлений О12 **/
          
            --          end if;
          
            --            if Check_date_year(v_pay_first_date, pay.plan_date) = 1 then  --Проверяем годовщину от первого платежа
            --               n_year := n_year+1;
            --               v_premium_type_id := get_premium_type(pay.plan_date, d_end_bordero,10); --Определяем тип премии. 10 - тип Премия
            --               d_re_start_date   := pay.plan_date;
            --               d_re_expiry_date  := add_months(d_re_start_date,12)-1;
            --             end if;
          
            /**
                        if cur.msfo_brief not in ('WOP','PWOP') then
                          n_t_cover:=months_between(get_anniversary_date(pay.plan_date, v_pay_first_date, 2), get_anniversary_date(cur.start_date, v_pay_first_date, 2))/12;
                        else
            --* Диагностика
                          begin
                          n_t_cover:=months_between(get_anniversary_date(pay.plan_date, v_pay_first_date, 2), get_anniversary_date(cur.start_date_main, v_pay_first_date, 2))/12;
                          exception
                            when others then
                              raise_application_error(-20000,'n_t_cover = '||TO_CHAR(n_t_cover)
                              ||';msfo_brief = '||cur.msfo_brief
                              ||';policy_id = '||TO_CHAR(pay.policy_id)
                              ||';product_line_id = '||TO_CHAR(cur.product_line_id)
                              ||';contact_id = '||TO_CHAR(cur.contact_id));
                          end;
            --*
                        end if;
            **/
          
            IF cur.msfo_brief IN ('WOP', 'PWOP')
            THEN
              --* Диагностика
              BEGIN
                /** О19 добавлено round О19 **/
                n_t_cover := ROUND(MONTHS_BETWEEN(get_anniversary_date(pay.plan_date
                                                                      ,v_pay_first_date
                                                                      ,2)
                                                 ,get_anniversary_date(cur.start_date_main
                                                                      ,v_pay_first_date
                                                                      ,2)) / 12);
              EXCEPTION
                WHEN OTHERS THEN
                  raise_application_error(-20000
                                         ,'n_t_cover = ' || TO_CHAR(n_t_cover) || ';msfo_brief = ' ||
                                          cur.msfo_brief || ';policy_id = ' || TO_CHAR(pay.policy_id) ||
                                          ';product_line_id = ' || TO_CHAR(cur.product_line_id) ||
                                          ';contact_id = ' || TO_CHAR(cur.contact_id));
              END;
              --*
            ELSE
              /** О19 добавлено round О19 **/
              n_t_cover := ROUND(MONTHS_BETWEEN(get_anniversary_date(pay.plan_date
                                                                    ,v_pay_first_date
                                                                    ,2)
                                               ,get_anniversary_date(cur.start_date
                                                                    ,v_pay_first_date
                                                                    ,2)) / 12);
            END IF;
            v_t_policy_year := ROUND(MONTHS_BETWEEN(get_anniversary_date(pay.plan_date
                                                                        ,v_pay_first_date
                                                                        ,2)
                                                   ,v_pay_first_date) / 12);
            IF cur.msfo_brief NOT IN ('WOP', 'PWOP', 'FAMDEP')
            THEN
              -- В случае пустого cur.msfo_brief актуарные функции не вычисляются
              -- при этом функция get_t_v возвращает 0, т.е. система в этом случае
              -- рассматривает программу, как программу без актуарного резерва
              n_A1_xn := pkg_AMATH.Ax1n( /*cur.insured_age + n_t_cover*/v_insured_age_pay
                                       ,cur.period_value - n_t_cover
                                       ,cur.sex
                                       ,cur.k_coef
                                       ,cur.s_coef
                                       ,nvl(cur.deathrate_id, 1)
                                       ,n_norm_rate); --cur.normrate_value);
              n_A_xn  := pkg_AMATH.Axn( /*cur.insured_age + n_t_cover*/v_insured_age_pay
                                      ,cur.period_value - n_t_cover
                                      ,cur.sex
                                      ,cur.k_coef
                                      ,cur.s_coef
                                      ,nvl(cur.deathrate_id, 1)
                                      ,n_norm_rate); --cur.normrate_value);
              n_a_x_n := pkg_AMATH.a_xn( /*cur.insured_age + n_t_cover*/v_insured_age_pay
                                       ,cur.period_value - n_t_cover
                                       ,cur.sex
                                       ,cur.k_coef
                                       ,cur.s_coef
                                       ,1
                                       ,nvl(cur.deathrate_id, 1)
                                       ,n_norm_rate); --cur.normrate_value);
            ELSIF cur.msfo_brief = 'WOP'
            THEN
              n_A1_xn := pkg_AMATH.Ax1n( /*cur.issuer_age_main + n_t_cover*/v_issuer_age_main_pay
                                       ,cur.period_value_main - n_t_cover
                                       ,cur.issuer_sex
                                       ,cur.k_coef
                                       ,cur.s_coef
                                       ,gv_deatrate_wop_id
                                       ,n_norm_rate); --cur.normrate_value);
              n_A_xn  := pkg_AMATH.Axn( /*cur.issuer_age_main + n_t_cover*/v_issuer_age_main_pay
                                      ,cur.period_value_main - n_t_cover
                                      ,cur.issuer_sex
                                      ,cur.k_coef
                                      ,cur.s_coef
                                      ,gv_deatrate_wop_id
                                      ,n_norm_rate); --cur.normrate_value);
              n_a_x_n := pkg_AMATH.a_xn( /*cur.issuer_age_main + n_t_cover*/v_issuer_age_main_pay
                                       ,cur.period_value_main - n_t_cover
                                       ,cur.issuer_sex
                                       ,cur.k_coef
                                       ,cur.s_coef
                                       ,1
                                       ,gv_deatrate_wop_id
                                       ,n_norm_rate); --cur.normrate_value);
            ELSIF cur.msfo_brief = 'PWOP'
            THEN
              n_A1_xn := pkg_AMATH.Ax1n( /*cur.issuer_age_main + n_t_cover*/v_issuer_age_main_pay
                                       ,cur.period_value_main - n_t_cover
                                       ,cur.issuer_sex
                                       ,cur.k_coef
                                       ,cur.s_coef
                                       ,gv_deatrate_pwop_id
                                       ,n_norm_rate); --cur.normrate_value);
              n_A_xn  := pkg_AMATH.Axn( /*cur.issuer_age_main + n_t_cover*/v_issuer_age_main_pay
                                      ,cur.period_value_main - n_t_cover
                                      ,cur.issuer_sex
                                      ,cur.k_coef
                                      ,cur.s_coef
                                      ,gv_deatrate_pwop_id
                                      ,n_norm_rate); --cur.normrate_value);
              n_a_x_n := pkg_AMATH.a_xn( /*cur.issuer_age_main + n_t_cover*/v_issuer_age_main_pay
                                       ,cur.period_value_main - n_t_cover
                                       ,cur.issuer_sex
                                       ,cur.k_coef
                                       ,cur.s_coef
                                       ,1
                                       ,gv_deatrate_pwop_id
                                       ,n_norm_rate); --cur.normrate_value);
            ELSIF cur.msfo_brief = 'FAMDEP'
            THEN
              --* Для программы 'Смешанное страхование жизни' в продукте 'Семейный депозит'
              --* используется таблица смертности SF_AVCR ID=101
              -- ** FAMDEP1 В функциях для FAMDEP указывается возраст на начало страхования x и срок страхования n без сдвига t.
              -- ** FAMDEP1 Сдвиг t задается отдельным параметров
              n_A1_xn := pkg_AMATH.Axt1nt_FAMDEP(cur.insured_age /** FAMDEP1 v_insured_age_pay**/
                                                ,cur.period_value
                                                ,n_t_cover
                                                ,cur.sex
                                                ,cur.k_coef
                                                ,cur.s_coef
                                                ,101 /** nvl(cur.deathrate_id,1) **/); --cur.normrate_value);
              n_A_xn  := pkg_AMATH.Axtnt_FAMDEP(cur.insured_age /** FAMDEP1 v_insured_age_pay**/
                                               ,cur.period_value
                                               ,n_t_cover
                                               ,cur.sex
                                               ,cur.k_coef
                                               ,cur.s_coef
                                               ,101 /** nvl(cur.deathrate_id,1) **/); --cur.normrate_value);
              n_a_x_n := pkg_AMATH.a_xtnt_FAMDEP(cur.insured_age /** FAMDEP1 v_insured_age_pay**/
                                                ,cur.period_value
                                                ,n_t_cover
                                                ,cur.sex
                                                ,cur.k_coef
                                                ,cur.s_coef
                                                ,1
                                                ,101 /** nvl(cur.deathrate_id,1)**/); --cur.normrate_value);
            END IF;
            --             n_P:=get_P(cur.p_cover_id, cur.prod_brief, n_A_xn, n_a_x_n, cur.is_not_periodical);
            t_V := get_t_v(cur.period_value
                          ,n_t_cover
                          ,cur.msfo_brief
                          ,n_A1_xn
                          ,n_A_xn
                          ,n_a_x_n
                          ,cur.is_not_periodical
                          ,n_norm_rate
                          ,cur.tariff_netto
                          ,v_re_contract_version.flg_no_calc_reserve);
          
            n_reserve := cur.ins_amount * t_V;
          
            n_RBI := get_RBI(cur.ins_amount
                            ,t_V
                            ,cur.msfo_brief
                            ,n_a_x_n
                            ,v_re_contract_version.flg_no_calc_reserve);
            n_R   := n_IR * n_RBI / n_OBI;
            n_SRR := n_RBI * n_RS;
          
            --Временно
            --  if cur.msfo_brief = 'DISM' then n_tarif:=0.000792;
            --  elsif cur.msfo_brief = 'ASURG' then n_tarif:=0.001464;
            --  else
            n_tarif := get_tariff(cur.policy_id
                                 ,cur.as_asset_id
                                 , /*cur.insured_age + n_t_cover*/v_insured_age_pay
                                 ,cur.p_cover_id
                                 ,cur.re_bordero_type_id
                                 ,cur.flg_all_program
                                 ,v_re_contract_version.re_contract_version_id
                                 ,cur.fund_id
                                 ,cur.gender
                                 ,cur.product_id
                                 ,cur.product_line_id
                                 ,cur.work_group_id
                                 ,cur.ins_amount);
            --  end if;
          
            n_YRP := get_YRP_by_func(v_re_contract_version.re_contract_version_id
                                    ,cur.product_line_id
                                    ,cur.fund_id
                                    ,n_RBI
                                    ,n_tarif
                                    ,n_SRR
                                    ,n_RS
                                    ,cur.k_coef_m
                                    ,cur.k_coef_nm
                                    ,cur.s_coem_m
                                    ,cur.s_coef_nm);
          
            /*             if cur.number_of_payments=1 then
                           n_YRP:=get_YRP_single( n_RBI, n_RS,cur.k_coef_m,cur.k_coef_nm,n_tarif,cur.s_coem_m,cur.s_coef_nm);
                         else
                           n_YRP:=get_YRP(n_SRR,cur.k_coef_m,cur.k_coef_nm,n_tarif,cur.s_coem_m,cur.s_coef_nm);
                         end if;
            */
          
            n_MF := get_MF(v_re_version_id
                          ,cur.payment_term_id
                          ,cur.is_group_flag
                          ,cur.number_of_payments);
          
            IF v_re_contract_version.flg_pay_year = 1
            THEN
              --Для для договора с оплатой перестраховочной премии раз в год формируем одну строку бордеро на год
              IF (Check_date_year(v_pay_first_date, pay.plan_date) = 1)
                 OR (v_pay_first_date = pay.plan_date)
              THEN
                --Если годовщина или первый платеж, то сохраняем
                IF v_re_contract_version.flg_one_str_for_one_prem = 1
                   AND cur.is_not_periodical = 1 /* П62 */
                THEN
                  n_PRP          := n_YRP * MONTHS_BETWEEN(cur.end_date + 1, pay.plan_date) / 12;
                  v_pay_end_date := cur.end_date;
                ELSE
                  n_PRP          := n_YRP; --Периодический платеж равен годовому
                  v_pay_end_date := ADD_MONTHS(pay.plan_date, 12) - 1;
                END IF;
                --Если версия не изменилась, то записываем
                IF cur.policy_id = Policy_Effective_On_Date(cur.policy_header_id, pay.plan_date)
                THEN
                  n_need_save := 1;
                ELSE
                  n_need_save := 0;
                END IF;
              ELSE
                n_need_save := 0;
              END IF;
            ELSE
              --Если версия не изменилась, то записываем
              IF cur.policy_id = Policy_Effective_On_Date(cur.policy_header_id, pay.plan_date)
              THEN
                n_need_save := 1;
              ELSE
                n_need_save := 0;
              END IF;
              IF v_re_contract_version.flg_one_str_for_one_prem = 1
                 AND cur.is_not_periodical = 1 /* П62 */
              THEN
                n_PRP          := n_YRP * MONTHS_BETWEEN(cur.end_date + 1, pay.plan_date) / 12;
                v_pay_end_date := cur.end_date;
              ELSE
                n_PRP          := n_YRP * n_MF;
                v_pay_end_date := ADD_MONTHS(pay.plan_date, 12 / cur.NUMBER_OF_PAYMENTS) - 1;
              END IF;
            END IF;
          
            IF n_need_save = 1
            THEN
              SELECT sq_re_bordero_line.nextval INTO p_bordero_line_id FROM dual;
              --Проверяем изменения в промежуточных датах
              --* Изменения в промежуточных датах
              /**1 заремлено, так как код не отлажен
              v_change_policy_id := get_changed_version(cur.policy_header_id,pay.plan_date, v_pay_end_date, /*d_end_bordero*/
              /**1               cur.policy_id,cur.contact_id,cur.product_line_id,cur.p_cover_id,p_bordero_line_id);
              1**/
            END IF;
          
            /*         if v_change_policy_id is not null and v_change_policy_id <> pay.policy_id then
            
                         v_change_policy_cover_id:=get_policy_cover_id(v_change_policy_id, cur.contact_id,cur.product_line_id);
                         v_change_policy_type:=compare_cover(cur.p_cover_id, v_change_policy_cover_id);
                         --Берем дату начала версии
                         select p.start_date into v_change_policy_date
                         from p_policy p where p.policy_id=v_change_policy_id;
            
                         --Сохранияем в коллекцию
                         t_change.extend(1);
                         t_change(t_change.count).re_bordero_line_id:=p_bordero_line_id;
                         t_change(t_change.count).policy_id:=v_change_policy_id;
                         t_change(t_change.count).cover_id:=v_change_policy_cover_id;
                         t_change(t_change.count).type_id:=v_change_policy_type;
            
                       end if;
            */
            --Проверяем наличие убытков по версии
            --            v_claim_id:=get_claim_id(cur.policy_id, cur.as_asset_id, cur.p_cover_id, d_start_bordero, d_end_bordero,pay.start_date, v_pay_end_date, n_RS, p_bordero_line_id);
            /*     PS Вынесено во внешнюю процедуру
                    if v_claim_id is not null then
                           --Сохранияем в коллекцию
                           t_claim.extend(1);
                           t_claim(t_claim.count).re_bordero_line_id:=p_bordero_line_id;
                           t_claim(t_claim.count).policy_id:=v_change_policy_id;
                           t_claim(t_claim.count).claim_id:=v_claim_id;
                         end if;
            */
          
            --Проверяем статус версии
            v_policy_state := doc.get_doc_status_brief(pay.policy_id, pay.plan_date);
            /*             if v_policy_state like 'QUIT%' then --Если версия договора "Прекращен", то сохраняем дату расторжения для формирования бордеро расторжений
                           d_decline_date:=pay.decline_date;
                           --Сохранияем в коллекцию
                           t_decline.extend(1);
                           t_decline(t_decline.count).re_bordero_line_id:=p_bordero_line_id;
                           t_decline(t_decline.count).policy_id:=pay.policy_id;
                           t_decline(t_decline.count).decline_date:=d_decline_date;
            --               t_declain(t_change.count).cover_id:=v_change_policy_cover_id;
            
                         end if;
              */
            -- Исправления Этап 4, замечание #57
            v_fixed_com_rate   := get_re_com_rate(v_re_version_id
                                                 ,cur.product_line_id
                                                 ,cur.is_avtoprolongation
                                                 ,cur.period_value
                                                 ,cur.fund_id);
            v_fixed_commission := v_fixed_com_rate * n_PRP;
          
            --Определяем тип бордеро
            v_bordero_type_id := get_bordero_type(d_start_bordero
                                                 ,d_end_bordero
                                                 ,v_pay_first_date
                                                 ,pay.plan_date
                                                 ,cur.start_date
                                                 ,cur.policy_header_id
                                                 ,cur.policy_id);
          
            -- В случае премии или премии предыдущих лет, рассчитывается комиссия
            IF v_premium_type_id IN (11, 12)
            THEN
              pkg_re_insurance.get_re_comiss(par_re_version_id        => v_re_version_id
                                            ,par_re_bordero_type_id   => /*cur.re_bordero_type_id*/ v_bordero_type_id
                                            ,par_flg_no_comiss        => cur.flg_no_comis
                                            ,par_prp                  => n_PRP
                                            ,par_year_cover           => /*n_year*/ n_t_cover + 1
                                            ,par_year                 => v_t_policy_year + 1
                                            ,par_header_start         => cur.pol_start_date
                                            ,par_header_end           => cur.pol_end_date
                                            ,par_autoprolongation     => cur.is_avtoprolongation
                                            ,par_re_calc_func_id      => v_re_contract_version.re_calc_comis_func_id
                                            ,par_cover_start_date     => cur.start_date
                                            ,par_cover_end_date       => cur.end_date
                                            ,par_bordero_start_date   => d_start_bordero
                                            ,par_bordero_end_date     => d_end_bordero
                                            ,par_product_line_id      => cur.product_line_id
                                            ,par_product_line_type_id => cur.product_line_type_id
                                            ,par_payment_period_start => pay.plan_date
                                            ,par_payment_period_end   => v_pay_end_date
                                            ,par_first_payment_date   => v_pay_first_date
                                            ,par_insurance_type       => cur.insurance_type
                                             /* 'Правила страхования жизни' - 'Life.Life'
                                                                                                                                                                                                                                    'Страхование от несчастных случаев и болезней' - 'Acc' */
                                            ,par_re_com_rate => v_add_com_rate
                                            ,par_result      => v_add_commission);
            ELSE
              -- TODO: В противном случае считается возврат перестраховочной комиссии
              v_add_commission := 0;
            END IF;
          
            IF v_add_commission = 0
            THEN
              v_add_com_rate := 0;
            END IF;
          
            -- Исправления Этап 4, замечание #57
            v_re_commission := v_fixed_commission + v_add_commission;
          
            IF n_PRP = 0
               OR n_PRP IS NULL
            THEN
              v_re_com_rate := 0;
            ELSE
              v_re_com_rate := v_re_commission / n_PRP;
            END IF;
          
            IF v_bordero_type_id > 0
            THEN
              --Получаем ИД бордеро по типу бордеро и валюте
              v_bordero_id := get_bordero_id(par_bordero_package_id, v_bordero_type_id, cur.fund_id);
            
              IF n_need_save = 1
              THEN
                IF v_is_inclusion_package = 1
                THEN
                  IF d_end_bordero + 1 BETWEEN pay.plan_date AND v_pay_end_date
                  THEN
                    -- ** #П56_1 Тут надо брать разность (v_pay_end_date+1)-(d_end_bordero+1)
                    -- ** #П56_1 поэтому +1-1=0
                    n_PRP           := n_PRP * (v_pay_end_date - d_end_bordero /* #П56_1  + 2 */
                                       ) / (v_pay_end_date - pay.plan_date + 1);
                    v_re_commission := v_re_commission * (v_pay_end_date - d_end_bordero /* #П56_1  + 2 */
                                       ) / (v_pay_end_date - pay.plan_date + 1);
                    -- ** #56 Кроме общей комиссии необходимо еще пересчитывать
                    -- фиксированную и нефиксированную комиссии
                    v_fixed_commission := v_fixed_commission * (v_pay_end_date - d_end_bordero /* #П56_1  + 2 */
                                          ) / (v_pay_end_date - pay.plan_date + 1);
                    v_add_commission   := v_add_commission * (v_pay_end_date - d_end_bordero /* #П56_1  + 2 */
                                          ) / (v_pay_end_date - pay.plan_date + 1);
                    -- ** #56 Конец вставки  
                  
                    --Сохраняем
                    INSERT INTO re_bordero_line
                      (re_bordero_line_id
                      ,re_bordero_id
                      ,pol_header_id
                      ,policy_id
                      ,cover_id
                      ,payment_id
                      ,payment_start_date
                      ,payment_end_date
                      ,as_assured_id
                      ,assurer_gender
                      ,assurer_age
                      ,payment_number
                      ,year_pay_count
                      ,year_reinsurer_premium
                      ,risk_benefit_insured
                      ,reinsurer_share
                      ,reinsurer_tariff
                      ,k_med
                      ,k_no_med
                      ,s_med
                      ,s_no_med
                      ,period_reinsurer_premium
                      ,modal_factor
                      ,ins_amount
                      ,add_com_rate
                      ,add_commission
                      ,original_benefit_insured
                      ,original_benefit_reinsured
                      ,initial_retention
                      ,retention
                      ,initial_sum_above_retention
                      ,sum_risk_reinsurer
                      ,sum_assured
                      ,tv
                      ,t_0_v
                      ,a1_xn
                      ,a_xn
                      ,a_x_n
                      ,calc_year_number
                      ,tariff
                      ,limit_sum
                      ,limit_proc
                      ,reserve
                      ,policy_decline_date
                      ,premium_type_id
                      ,fund_id
                      ,re_start_date
                      ,re_expiry_date
                      ,claim_id
                      ,policy_start_date
                      ,change_policy_id
                      ,change_type
                      ,change_cover_id
                      ,product_id
                      ,product_line_id
                      ,fixed_com_rate
                      ,fixed_commission
                      ,re_comision
                      ,re_com_rate)
                    VALUES
                      (p_bordero_line_id
                      ,v_bordero_id
                      ,cur.policy_header_id
                      ,cur.policy_id
                      ,cur.p_cover_id
                      ,pay.payment_id
                      ,d_end_bordero + 1
                      ,v_pay_end_date
                      ,cur.as_asset_id
                      ,cur.gender
                      , /*cur.insured_age + n_t_cover*/v_insured_age_pay
                      ,pay.payment_number
                      ,cur.number_of_payments
                      ,n_YRP
                      ,n_RBI
                      ,n_RS
                      ,n_tarif
                      ,cur.k_coef_m
                      ,cur.k_coef_nm
                      ,cur.s_coem_m
                      ,cur.s_coef_nm
                      ,n_PRP
                      ,n_MF
                      ,cur.ins_amount
                      ,v_add_com_rate
                      ,v_add_commission
                      ,n_OBI
                      ,n_OBR
                      ,n_IR
                      ,n_R
                      ,n_ISRAR
                      ,n_SRR
                      ,cur.ins_amount
                      ,t_v
                      ,t_O_V
                      ,n_A1_xn
                      ,n_A_xn
                      ,n_a_x_n
                      , /*n_year*/n_t_cover
                      ,n_tarif
                      ,n_limit
                      ,n_percent
                      ,n_reserve
                      ,d_decline_date
                      ,v_premium_type_id
                      ,pay.fund_id
                      ,d_end_bordero + 1 --d_re_start_date /* П63 */
                      ,d_re_expiry_date
                      ,v_claim_id
                      ,v_change_policy_date
                      ,v_change_policy_id
                      ,v_change_policy_type
                      ,v_change_policy_cover_id
                      ,cur.product_id
                      ,cur.product_line_id
                      ,v_fixed_com_rate
                      ,v_fixed_commission
                      ,v_re_commission
                      ,v_re_com_rate);
                  
                  END IF;
                ELSE
                  --Сохраняем -- не идентичен предыдущему
                  INSERT INTO re_bordero_line
                    (re_bordero_line_id
                    ,re_bordero_id
                    ,pol_header_id
                    ,policy_id
                    ,cover_id
                    ,payment_id
                    ,payment_start_date
                    ,payment_end_date
                    ,as_assured_id
                    ,assurer_gender
                    ,assurer_age
                    ,payment_number
                    ,year_pay_count
                    ,year_reinsurer_premium
                    ,risk_benefit_insured
                    ,reinsurer_share
                    ,reinsurer_tariff
                    ,k_med
                    ,k_no_med
                    ,s_med
                    ,s_no_med
                    ,period_reinsurer_premium
                    ,modal_factor
                    ,ins_amount
                    ,add_com_rate
                    ,add_commission
                    ,original_benefit_insured
                    ,original_benefit_reinsured
                    ,initial_retention
                    ,retention
                    ,initial_sum_above_retention
                    ,sum_risk_reinsurer
                    ,sum_assured
                    ,tv
                    ,t_0_v
                    ,a1_xn
                    ,a_xn
                    ,a_x_n
                    ,calc_year_number
                    ,tariff
                    ,limit_sum
                    ,limit_proc
                    ,reserve
                    ,policy_decline_date
                    ,premium_type_id
                    ,fund_id
                    ,re_start_date
                    ,re_expiry_date
                    ,claim_id
                    ,policy_start_date
                    ,change_policy_id
                    ,change_type
                    ,change_cover_id
                    ,product_id
                    ,product_line_id
                    ,fixed_com_rate
                    ,fixed_commission
                    ,re_comision
                    ,re_com_rate)
                  VALUES
                    (p_bordero_line_id
                    ,v_bordero_id
                    ,cur.policy_header_id
                    ,cur.policy_id
                    ,cur.p_cover_id
                    ,pay.payment_id
                    ,pay.plan_date
                    ,v_pay_end_date
                    ,cur.as_asset_id
                    ,cur.gender
                    , /*cur.insured_age + n_t_cover*/v_insured_age_pay
                    ,pay.payment_number
                    ,cur.number_of_payments
                    ,n_YRP
                    ,n_RBI
                    ,n_RS
                    ,n_tarif
                    ,cur.k_coef_m
                    ,cur.k_coef_nm
                    ,cur.s_coem_m
                    ,cur.s_coef_nm
                    ,n_PRP
                    ,n_MF
                    ,cur.ins_amount
                    ,v_add_com_rate
                    ,v_add_commission
                    ,n_OBI
                    ,n_OBR
                    ,n_IR
                    ,n_R
                    ,n_ISRAR
                    ,n_SRR
                    ,cur.ins_amount
                    ,t_v
                    ,t_O_V
                    ,n_A1_xn
                    ,n_A_xn
                    ,n_a_x_n
                    , /*n_year*/n_t_cover
                    ,n_tarif
                    ,n_limit
                    ,n_percent
                    ,n_reserve
                    ,d_decline_date
                    ,v_premium_type_id
                    ,pay.fund_id
                    ,d_re_start_date
                    ,d_re_expiry_date
                    ,v_claim_id
                    ,v_change_policy_date
                    ,v_change_policy_id
                    ,v_change_policy_type
                    ,v_change_policy_cover_id
                    ,cur.product_id
                    ,cur.product_line_id
                    ,v_fixed_com_rate
                    ,v_fixed_commission
                    ,v_re_commission
                    ,v_re_com_rate);
                END IF;
              END IF;
            END IF;
            v_pay_last_date := pay.plan_date;
            -- p_t:=p_t+1;
          END IF; -- if v_pay_last_date <> pay.plan_date
        END LOOP;
      
        --Растожение. Если была версия расторжения, то формируем строки бордеро расторжений
        /*  for cur_br in (select bl.* from re_bordero_package bp, re_bordero b, re_bordero_line bl
        where bl.re_bordero_id=b.re_bordero_id
        and b.re_bordero_package_id=bp.re_bordero_package_id
        and bp.re_bordero_package_id=par_bordero_package_id
        and bl.policy_decline_date is not null
        order by bl.re_bordero_line_id ) loop
        */
        /*         for i in 1..t_decline.count loop
                     --Ищем бордеро расторжений в пакете бордеро
        --             v_bordero_id:=get_bordero_id(par_bordero_package_id, 5, cur_br.fund_id);
        
                     --Получаем строку бордеро
                     select * into p_re_bordero_line from re_bordero_line bl
                     where bl.re_bordero_line_id=t_decline(i).re_bordero_line_id;
        
                     --Для перида, содержащего дату расторжения, делаем перерасчет
                     if t_decline(i).decline_date between p_re_bordero_line.payment_start_date and p_re_bordero_line.payment_end_date then
                       n_RP:=get_RP_by_func(v_re_version_id,n_PRP,p_re_bordero_line.payment_start_date,p_re_bordero_line.payment_end_date,
                               p_re_bordero_line.policy_decline_date);
                     -- n_RP:=get_RP(n_PRP, cur_br.payment_start_date,cur_br.payment_end_date,
                     --          cur_br.policy_decline_date,cur.is_periodical,v_re_contract_version.return_premium_function_id);
        
        
                     else
                       n_RP:=p_re_bordero_line.period_reinsurer_premium;
                     end if;
        
                     --Определяем тип премии
                     if cur.is_not_periodical=1 then
                       v_premium_type_id:= get_premium_type(p_re_bordero_line.payment_start_date, d_end_bordero,20); --Определяем тип премии. 20 - тип Доля в возвратах
                     else
                       v_premium_type_id:= get_premium_type(p_re_bordero_line.payment_start_date, d_end_bordero,30); --Определяем тип премии. 30 - тип Сторно
                     end if;
        
                     --Сохраняем
                     insert into re_bordero_line(re_bordero_line_id,re_bordero_id,pol_header_id,policy_id,cover_id,payment_id
                     ,payment_start_date,payment_end_date,as_assured_id,assurer_gender,assurer_age,payment_number
                     ,year_pay_count,year_reinsurer_premium,risk_benefit_insured,reinsurer_share,reinsurer_tariff
                     ,k_med,k_no_med,s_med,s_no_med,period_reinsurer_premium,modal_factor,ins_amount
                     ,re_com_rate,re_comision,original_benefit_insured,original_benefit_reinsured,initial_retention
                     ,retention,initial_sum_above_retention,sum_risk_reinsurer,sum_assured
                     ,tv,t_0_v,a1_xn,a_xn,a_x_n,calc_year_number,tariff,limit_sum,limit_proc,reserve
                     ,policy_decline_date,premium_type_id,returned_premium,returned_comission
                     ,fund_id,re_start_date,re_expiry_date,parent_line_id)
                     values(SQ_RE_BORDERO_LINE.NEXTVAL,p_re_bordero_line.re_bordero_line_id,p_re_bordero_line.pol_header_id,p_re_bordero_line.policy_id,p_re_bordero_line.cover_id, p_re_bordero_line.payment_id
                     ,p_re_bordero_line.payment_start_date,p_re_bordero_line.payment_end_date,p_re_bordero_line.as_assured_id,p_re_bordero_line.assurer_gender,p_re_bordero_line.assurer_age,p_re_bordero_line.payment_number
                     ,p_re_bordero_line.year_pay_count,0,0,0, p_re_bordero_line.tariff
                     ,p_re_bordero_line.k_med,p_re_bordero_line.k_no_med,p_re_bordero_line.s_med,p_re_bordero_line.s_no_med,0,n_MF,p_re_bordero_line.ins_amount
                     ,n_re_com_rate,0,0,0,0
                     ,0, 0,0, p_re_bordero_line.ins_amount
                     ,t_v,t_O_V, n_A1_xn,n_A_xn,n_a_x_n,p_re_bordero_line.calc_year_number,p_re_bordero_line.tariff,n_limit,n_percent,n_reserve
                     ,d_decline_date, v_premium_type_id,n_RP, p_re_bordero_line.re_comision
                     ,p_re_bordero_line.fund_id,p_re_bordero_line.re_start_date,p_re_bordero_line.re_expiry_date, p_re_bordero_line.re_bordero_line_id);
        
                  end loop; --Расторжение
          */
        --Убытки--
        /*           for cur_claim in (select bl.* from re_bordero_package bp, re_bordero b, re_bordero_line bl
        where bl.re_bordero_id=b.re_bordero_id
        and b.re_bordero_package_id=bp.re_bordero_package_id
        and bp.re_bordero_package_id=par_bordero_package_id
        and bl.claim_id is not null
        order by bl.re_bordero_line_id ) loop*/
      
        /*            for i in 1..t_claim.count loop
                      --Получаем строку бордеро
                     select * into p_re_bordero_line from re_bordero_line bl
                     where bl.re_bordero_line_id=t_claim(i).re_bordero_line_id;
        
                     if t_claim(i).claim_type = 1 then  --Оплаченный
                       v_bordero_id:=get_bordero_id(par_bordero_package_id, 4, p_re_bordero_line.fund_id);-- БОУ=4
                       n_RP:=get_RP(n_PRP, p_re_bordero_line.payment_start_date,p_re_bordero_line.payment_end_date,
                                    d_claim_pay_date,cur.is_not_periodical,v_re_contract_version.return_premium_function_id);
        
                     elsif t_claim(i).claim_type = 2 then --Заявленный, но не оплаченный
                       v_bordero_id:=get_bordero_id(par_bordero_package_id, 3, p_re_bordero_line.fund_id);-- БЗУ=3
                       n_RP:=p_re_bordero_line.period_reinsurer_premium;
                     end if;
        
                     --Сохраняем
                     insert into re_bordero_line(re_bordero_line_id,re_bordero_id,pol_header_id,policy_id,cover_id,payment_id
                     ,payment_start_date,payment_end_date,as_assured_id,assurer_gender,assurer_age,payment_number
                     ,year_pay_count,year_reinsurer_premium,risk_benefit_insured,reinsurer_share,reinsurer_tariff
                     ,k_med,k_no_med,s_med,s_no_med,period_reinsurer_premium,modal_factor,ins_amount
                     ,re_com_rate,re_comision,original_benefit_insured,original_benefit_reinsured,initial_retention
                     ,retention,initial_sum_above_retention,sum_risk_reinsurer,sum_assured
                     ,tv,t_0_v,a1_xn,a_xn,a_x_n,calc_year_number,tariff,limit_sum,limit_proc,reserve
                     ,policy_decline_date,premium_type_id,returned_premium,returned_comission
                     ,fund_id,re_start_date,re_expiry_date,parent_line_id)
                     values(SQ_RE_BORDERO_LINE.NEXTVAL,v_bordero_id,p_re_bordero_line.pol_header_id,p_re_bordero_line.policy_id,p_re_bordero_line.cover_id, p_re_bordero_line.payment_id
                     ,p_re_bordero_line.payment_start_date,p_re_bordero_line.payment_end_date,p_re_bordero_line.as_assured_id,p_re_bordero_line.assurer_gender,p_re_bordero_line.assurer_age,p_re_bordero_line.payment_number
                     ,p_re_bordero_line.year_pay_count,n_YRP * -1,n_RBI * -1,n_RS * -1, p_re_bordero_line.tariff
                     ,p_re_bordero_line.k_med,p_re_bordero_line.k_no_med,p_re_bordero_line.s_med,p_re_bordero_line.s_no_med,0,n_MF,p_re_bordero_line.ins_amount
                     ,n_re_com_rate,0,n_OBI * -1,n_OBR * -1,n_IR * -1
                     ,n_R * -1, n_ISRAR * -1,n_SRR * -1, p_re_bordero_line.ins_amount
                     ,t_v,t_O_V, n_A1_xn,n_A_xn,n_a_x_n,p_re_bordero_line.calc_year_number,p_re_bordero_line.tariff,n_limit,n_percent,n_reserve
                     ,p_re_bordero_line.policy_decline_date, 0,n_RP, p_re_bordero_line.re_comision
                     ,p_re_bordero_line.fund_id,p_re_bordero_line.re_start_date,p_re_bordero_line.re_expiry_date,p_re_bordero_line.parent_line_id);
        
                   end loop; --Убытки
        */
        --Изменения. Если была версия изменения то формируем строки бордеро изменений
        /*        for cur_ch in (select bl.* from re_bordero_package bp, re_bordero b, re_bordero_line bl
        where bl.re_bordero_id=b.re_bordero_id
        and b.re_bordero_package_id=bp.re_bordero_package_id
        and bp.re_bordero_package_id=par_bordero_package_id
        and bl.change_policy_id is not null
        order by bl.re_bordero_line_id ) loop
        */
      
        --* Изменения в промежуточных датах
        /**1 заремлено, так как код не отлажен
        
        for i in 1..t_change.count loop
           --Получаем строку бордеро
          select *
            into p_re_bordero_line
            from re_bordero_line bl
           where bl.re_bordero_line_id = t_change(i).re_bordero_line_id;
        
          if t_change(i).type_id = 3 then
            select pc.decline_date
                  ,pc.end_date
              into v_cover_decline_date
                  ,v_change_pol_cover_end_date
              from p_cover pc
             where pc.p_cover_id=t_change(i).cover_id;
        
            v_change_pol_cover_end_date := least(v_change_pol_cover_end_date,p_re_bordero_line.payment_end_date);
        
            n_RP:=get_RP(p_re_bordero_line.period_reinsurer_premium
                        ,p_re_bordero_line.payment_start_date
                        ,p_re_bordero_line.payment_end_date
                        ,v_cover_decline_date
                        --,cur.is_not_periodical
                        ,v_re_contract_version.return_premium_function_id);
        
            v_premium_type_id:= get_premium_type(p_re_bordero_line.payment_start_date, d_end_bordero,20);
        
            v_bordero_id := get_bordero_id(par_bordero_package_id,41,cur.fund_id);
        
            --Создаем запись по старым суммам по периоду до начала действия новой версии
            insert into re_bordero_line(re_bordero_line_id,re_bordero_id,pol_header_id,policy_id,cover_id,payment_id
              ,payment_start_date,payment_end_date,as_assured_id,assurer_gender,assurer_age,payment_number
              ,year_pay_count,year_reinsurer_premium,risk_benefit_insured,reinsurer_share,reinsurer_tariff
              ,k_med,k_no_med,s_med,s_no_med,period_reinsurer_premium,modal_factor,ins_amount
              ,re_com_rate,re_comision,original_benefit_insured,original_benefit_reinsured,initial_retention
              ,retention,initial_sum_above_retention,sum_risk_reinsurer,sum_assured
              ,tv,t_0_v,a1_xn,a_xn,a_x_n,calc_year_number,tariff,limit_sum,limit_proc,reserve
              ,policy_decline_date,premium_type_id,returned_premium,returned_comission
              ,fund_id,re_start_date,re_expiry_date,parent_line_id)
            values(SQ_RE_BORDERO_LINE.NEXTVAL,v_bordero_id,p_re_bordero_line.pol_header_id,p_re_bordero_line.policy_id,t_change(i).cover_id, p_re_bordero_line.payment_id
              ,p_re_bordero_line.payment_start_date,v_change_pol_cover_start_date,p_re_bordero_line.as_assured_id,p_re_bordero_line.assurer_gender,p_re_bordero_line.assurer_age,p_re_bordero_line.payment_number
              ,p_re_bordero_line.year_pay_count,n_YRP * -1,n_RBI * -1,n_RS * -1, p_re_bordero_line.tariff
              ,p_re_bordero_line.k_med,p_re_bordero_line.k_no_med,p_re_bordero_line.s_med,p_re_bordero_line.s_no_med,0,n_MF,p_re_bordero_line.ins_amount
              ,n_re_com_rate,0,n_OBI * -1,n_OBR * -1,n_IR * -1
              ,n_R * -1, n_ISRAR * -1,n_SRR * -1, p_re_bordero_line.ins_amount
              ,t_v,t_O_V, n_A1_xn,n_A_xn,n_a_x_n,p_re_bordero_line.calc_year_number,p_re_bordero_line.tariff,n_limit,n_percent,n_reserve
              ,d_decline_date, v_premium_type_id,n_RP, p_re_bordero_line.re_comision
              ,p_re_bordero_line.fund_id,p_re_bordero_line.re_start_date,p_re_bordero_line.re_expiry_date, p_re_bordero_line.re_bordero_line_id);
        
          else
            --Получаем параметры измененного покрытия
            select pc.start_date
                  ,pc.end_date
                  ,pc.ins_amount
            into v_change_pol_cover_start_date,v_change_pol_cover_end_date,v_change_pol_cover_sum
            from p_cover pc where pc.p_cover_id=t_change(i).cover_id;
        
            v_change_pol_cover_end_date:=least(v_change_pol_cover_end_date, p_re_bordero_line.re_expiry_date);
        
            --Ищем бордеро изменений в пакете бордеро
            v_bordero_id:=get_bordero_id(par_bordero_package_id, 41 /*БОРДЕРО_ИЗМЕН*/
        /**1               , p_re_bordero_line.fund_id);
        
        --Для перида, содержащего дату изменения, делаем перерасчет
        n_RP:=get_RP(n_PRP, p_re_bordero_line.payment_start_date,v_change_pol_cover_start_date,
                       cur.end_date,/*cur.is_not_periodical,*/
        /**1                              v_re_contract_version.return_premium_function_id);
                     --Определяем тип премии
                     if cur.is_not_periodical = 1 then
                       v_premium_type_id:= get_premium_type(p_re_bordero_line.payment_start_date, d_end_bordero,20); --Определяем тип премии. 20 - тип Доля в возвратах
                     else
                       v_premium_type_id:= get_premium_type(p_re_bordero_line.payment_start_date, d_end_bordero,30); --Определяем тип премии. 30 - тип Сторно
                     end if;
        
                     --Создаем запись по старым суммам по периоду до начала действия новой версии
                     insert into re_bordero_line(re_bordero_line_id,re_bordero_id,pol_header_id,policy_id,cover_id,payment_id
                     ,payment_start_date,payment_end_date,as_assured_id,assurer_gender,assurer_age,payment_number
                     ,year_pay_count,year_reinsurer_premium,risk_benefit_insured,reinsurer_share,reinsurer_tariff
                     ,k_med,k_no_med,s_med,s_no_med,period_reinsurer_premium,modal_factor,ins_amount
                     ,re_com_rate,re_comision,original_benefit_insured,original_benefit_reinsured,initial_retention
                     ,retention,initial_sum_above_retention,sum_risk_reinsurer,sum_assured
                     ,tv,t_0_v,a1_xn,a_xn,a_x_n,calc_year_number,tariff,limit_sum,limit_proc,reserve
                     ,policy_decline_date,premium_type_id,returned_premium,returned_comission
                     ,fund_id,re_start_date,re_expiry_date,parent_line_id)
                     values(SQ_RE_BORDERO_LINE.NEXTVAL,v_bordero_id,p_re_bordero_line.pol_header_id,p_re_bordero_line.policy_id,p_re_bordero_line.cover_id, p_re_bordero_line.payment_id
                     ,p_re_bordero_line.payment_start_date,v_change_pol_cover_start_date,p_re_bordero_line.as_assured_id,p_re_bordero_line.assurer_gender,p_re_bordero_line.assurer_age,p_re_bordero_line.payment_number
                     ,p_re_bordero_line.year_pay_count,n_YRP * -1,n_RBI * -1,n_RS * -1, p_re_bordero_line.tariff
                     ,p_re_bordero_line.k_med,p_re_bordero_line.k_no_med,p_re_bordero_line.s_med,p_re_bordero_line.s_no_med,0,n_MF,p_re_bordero_line.ins_amount
                     ,n_re_com_rate,0,n_OBI * -1,n_OBR * -1,n_IR * -1
                     ,n_R * -1, n_ISRAR * -1,n_SRR * -1, p_re_bordero_line.ins_amount
                     ,t_v,t_O_V, n_A1_xn,n_A_xn,n_a_x_n,p_re_bordero_line.calc_year_number,p_re_bordero_line.tariff,n_limit,n_percent,n_reserve
                     ,d_decline_date, v_premium_type_id,n_RP, p_re_bordero_line.re_comision
                     ,p_re_bordero_line.fund_id,p_re_bordero_line.re_start_date,p_re_bordero_line.re_expiry_date, p_re_bordero_line.re_bordero_line_id);
        
        
                     --Рассчитываем платеж измененного периода по новой сумме
                     -- Надо будет сделать разделение на WOP/PWOP с deathrate_id (как сделано выше в процедуре)
                     n_A1_xn:= pkg_AMATH.Ax1n(p_re_bordero_line.assurer_age, p_t,cur.sex, cur.k_coef, cur.s_coef,  nvl(cur.deathrate_id,1),cur.normrate_value);
                     n_A_xn:= pkg_AMATH.Axn(p_re_bordero_line.assurer_age, p_t,cur.sex, cur.k_coef, cur.s_coef, nvl(cur.deathrate_id,1),cur.normrate_value);
                     n_a_x_n:= pkg_AMATH.a_xn(p_re_bordero_line.assurer_age, p_t,cur.sex, cur.k_coef, cur.s_coef,1, nvl(cur.deathrate_id,1),cur.normrate_value);
                     t_V:=get_t_v(cur.period_value, n_t_cover, cur.msfo_brief, n_A1_xn, n_A_xn, n_a_x_n, cur.number_of_payments, cur.normrate_value, cur.premium, v_re_contract_version.flg_no_calc_reserve);
        
                     n_RBI := cur.ins_amount * (1 - t_V);
                     n_R := n_IR * n_RBI / n_OBI;
                     n_SRR:=n_RBI * n_RS;
        
                     n_tarif:=get_tarif(t_change(i).policy_id, p_re_bordero_line.as_assured_id, p_re_bordero_line.assurer_age, p_re_bordero_line.change_cover_id, cur.re_bordero_type_id,
                                        cur.flg_all_program,v_re_contract_version.re_contract_version_id, cur.fund_id, cur.gender,
                                        cur.product_id, cur.product_line_id);
        /*             if cur.number_of_payments=1 then
                       n_YRP:=get_YRP_single( n_RBI, n_RS,cur_ch.k_med,cur_ch.k_no_med,n_tarif,cur_ch.s_med,cur_ch.s_no_med);
                     else
                       n_YRP:=get_YRP(n_SRR,cur_ch.k_med,cur_ch.k_no_med,n_tarif,cur_ch.s_med,cur_ch.s_no_med);
                     end if;
        */
        /**1
        n_MF:=get_MF(v_re_version_id, cur.payment_term_id, cur.is_group_flag, cur.number_of_payments);
        n_PRP:=n_YRP * n_MF;
        
        --Для перида, содержащего дату изменения, делаем перерасчет
        n_RP:=get_RP(n_PRP, v_change_pol_cover_start_date, cur.end_date,
                       p_re_bordero_line.policy_start_date,/*cur.is_not_periodical,*/
        /**1           v_re_contract_version.return_premium_function_id);
        
                       --Создаем запись по старым суммам по периоду после начала действия новой версии
                       insert into re_bordero_line(re_bordero_line_id,re_bordero_id,pol_header_id,policy_id,cover_id,payment_id
                       ,payment_start_date,payment_end_date,as_assured_id,assurer_gender,assurer_age,payment_number
                       ,year_pay_count,year_reinsurer_premium,risk_benefit_insured,reinsurer_share,reinsurer_tariff
                       ,k_med,k_no_med,s_med,s_no_med,period_reinsurer_premium,modal_factor,ins_amount
                       ,re_com_rate,re_comision,original_benefit_insured,original_benefit_reinsured,initial_retention
                       ,retention,initial_sum_above_retention,sum_risk_reinsurer,sum_assured
                       ,tv,t_0_v,a1_xn,a_xn,a_x_n,calc_year_number,tariff,limit_sum,limit_proc,reserve
                       ,policy_decline_date,premium_type_id,returned_premium,returned_comission
                       ,fund_id,re_start_date,re_expiry_date,parent_line_id)
                       values(SQ_RE_BORDERO_LINE.NEXTVAL,v_bordero_id,p_re_bordero_line.pol_header_id,p_re_bordero_line.policy_id,p_re_bordero_line.cover_id, p_re_bordero_line.payment_id
                       ,v_change_pol_cover_start_date,v_change_pol_cover_end_date,p_re_bordero_line.as_assured_id,p_re_bordero_line.assurer_gender,p_re_bordero_line.assurer_age,p_re_bordero_line.payment_number
                       ,p_re_bordero_line.year_pay_count,n_YRP,n_RBI,n_RS, n_tarif
                       ,p_re_bordero_line.k_med,p_re_bordero_line.k_no_med,p_re_bordero_line.s_med,p_re_bordero_line.s_no_med,n_PRP,n_MF,v_change_pol_cover_sum
                       ,n_re_com_rate,0,n_OBI,n_OBR ,n_IR
                       ,n_R, n_ISRAR,n_SRR , v_change_pol_cover_sum
                       ,t_v,t_O_V, n_A1_xn,n_A_xn,n_a_x_n,p_re_bordero_line.calc_year_number,n_tarif,n_limit,n_percent,n_reserve
                       ,d_decline_date, v_premium_type_id,n_RP, p_re_bordero_line.re_comision
                       ,p_re_bordero_line.fund_id,p_re_bordero_line.re_start_date,p_re_bordero_line.re_expiry_date, p_re_bordero_line.re_bordero_line_id);
                     end if;
        
                   end loop; --Изменение в промежуточных датах
        1**/
        --end if; -- v_insured_age_wop <= gc_max_age_wop
      
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_calc_bordero_loop;
          v_error_message := substr(SQLERRM, 1, 255);
          calc_bordero_log(par_bordero_package_id => par_bordero_package_id
                          ,par_cover_id           => cur.p_cover_id
                          ,par_error_message      => v_error_message
                          ,par_backtrace          => dbms_utility.format_error_backtrace);
      END;
    
    END LOOP;
  
    --   save_bordero(par_bordero_package_id);
  
    --Смена статуса в Рассчитан
    --  doc.set_doc_status(par_bordero_package_id,'FINISH_CALCULATE');
  
    --exception
    --  when others then
    --Смена статуса в Ошибка
    --   doc.set_doc_status(par_bordero_package_id,'ERROR_CALCULATE');
    --    RAISE_APPLICATION_ERROR(-20002, 'Ошибка при расчете бордеро '||SQLERRM);
  
  END calc_bordero;

  /*------------------------Функции расчетов ---------------------------*/

  /*Функция рассчитывает рассроченную оплату ежегодной премии
    par_t  - период в годах
    par_brief - код риска
    par_A1_xn
    par_A_xn
    par_a_x_n
    par_number_of_payments
    par_normrate_value
    par_premium
  */
  FUNCTION get_t_v
  (
    par_n                   IN NUMBER
   ,par_t                   NUMBER
   ,par_brief               IN VARCHAR2
   ,par_A1_xn               IN NUMBER
   ,par_A_xn                IN NUMBER
   ,par_a_x_n               IN NUMBER
   ,par_number_of_payments  IN NUMBER
   ,par_normrate_value      IN NUMBER
   ,par_premium             IN NUMBER
   ,par_flg_no_calc_reserve IN NUMBER
  ) RETURN NUMBER AS
    t_V NUMBER;
  BEGIN
    --Проверка настроенной функции
    --  if
  
    --Вызов PL/SQL функции
  
    --  else
    IF par_flg_no_calc_reserve = 1
       OR (par_number_of_payments != 1 AND par_t = 0)
    THEN
      t_V := 0;
    ELSE
      IF upper(TRIM(par_brief)) = 'DD'
         OR upper(TRIM(par_brief)) = 'TERM'
      THEN
        IF par_number_of_payments = 1
        THEN
          t_V := greatest(par_A1_xn, 0);
        ELSE
          t_V := greatest(par_A1_xn - par_premium * par_a_x_n, 0);
        END IF;
      
      ELSIF (upper(TRIM(par_brief)) = 'END')
            OR (upper(TRIM(par_brief)) = 'FAMDEP')
      THEN
        IF par_number_of_payments = 1
        THEN
          t_V := greatest(par_A_xn, 0);
        ELSE
          t_V := greatest(par_A_xn - par_premium * par_a_x_n, 0);
        END IF;
      
      ELSIF upper(TRIM(par_brief)) = 'TERM_FIX'
      THEN
        IF par_number_of_payments = 1
        THEN
          t_V := greatest(power(1 / (1 + par_normrate_value), par_n - par_t), 0);
        ELSE
          t_V := greatest(power(1 / (1 + par_normrate_value), par_n - par_t) - par_premium * par_a_x_n
                         ,0);
        END IF;
      
      ELSIF (upper(TRIM(par_brief)) = 'WOP')
            OR (upper(TRIM(par_brief)) = 'PWOP')
      THEN
        t_V := 0;
      
      ELSIF upper(TRIM(par_brief)) = 'RBI'
      THEN
        t_V := 0;
      
      ELSE
        t_V := 0;
      
      END IF;
    END IF;
    --   end if;
  
    RETURN t_V;
  END;

  /* Функция вовращает лимит по застрахованному
  par_policy       - ID версии договора
  par_assured_id   - ID застрахованного
  par_reassured_id - ID перестрахователя
  */
  FUNCTION Get_Limit
  (
    par_re_version_id   IN NUMBER
   ,par_policy_id       IN NUMBER
   ,par_assured_id      IN NUMBER
   ,par_reassured_id    IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_rvb_value       IN NUMBER
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
  
    BEGIN
      SELECT nvl(rlc.limit, 0)
        INTO res
        FROM ven_RE_LINE_CONTRACT   RLC
            ,ven_re_cond_filter_obl v
       WHERE v.re_cond_filter_obl_id = rlc.re_cond_filter_obl_id
         AND v.re_contract_ver_id = par_re_version_id
         AND rlc.fund_id = par_fund_id
         AND v.product_line_id = par_product_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        res := 0;
        --* Диагностика ошибок
      --*    when others then
      --*      raise_application_error(-20000, 'par_re_version_id = '||TO_CHAR(par_re_version_id)||';par_fund_id = '||TO_CHAR(par_fund_id)||';par_product_line_id = '||TO_CHAR(par_product_line_id));
      --*
    END;
  
    IF nvl(res, 0) = 0
    THEN
      BEGIN
        SELECT nvl(prp.limit, 0)
          INTO res
          FROM re_policy_reinsurance_program prp
         WHERE prp.product_line_id = par_product_line_id
           AND prp.policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    END IF;
  
    IF nvl(res, 0) = 0
    THEN
      BEGIN
        SELECT nvl(cl.limit, 0) INTO res FROM re_cumulative_limit cl WHERE cl.fund_id = par_fund_id;
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    END IF;
  
    IF nvl(res, 0) = 0
    THEN
      BEGIN
        SELECT nvl(fo.limit, 0)
          INTO res
          FROM re_cond_filter_obl  fo
              ,re_contract_version cv -- ven_re_line_contract c--  re_limit_contract c
         WHERE cv.re_contract_version_id = fo.re_contract_ver_id
           AND cv.re_contract_version_id = par_re_version_id
           AND fo.product_line_id = par_product_line_id
           AND cv.fund_id = par_fund_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    END IF;
  
    RETURN res;
  END get_limit;

  /* Функция вовращает процент лимита по застрахованному
  par_policy       - ID версии договора
  par_assured_id   - ID застрахованного
  par_reassured_id - ID перестрахователя
  */
  FUNCTION Get_Limit_percent
  (
    par_re_version_id   IN NUMBER
   ,par_policy_id       IN NUMBER
   ,par_assured_id      IN NUMBER
   ,par_reassured_id    IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_rvb_value       IN NUMBER
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    /*
      begin
        select ar.reinsurer_percent/100 into res
        from as_assured_cover_re ar, as_assured_re r, t_prod_line_option plo, p_cover pc
        where r.as_assured_re_id=ar.as_assured_re_id
        and pc.p_cover_id=ar.p_cover_id
        and plo.id=pc.t_prod_line_option_id
        and r.p_policy_id=par_policy_id
        and r.p_re_id=par_reassured_id
        and plo.product_line_id=par_product_line_id;
      exception
        when no_data_found then
          res:=0;
      end;
    */
    BEGIN
      SELECT nvl(rlc.retention_perc, 0) / 100
        INTO res
        FROM ven_RE_LINE_CONTRACT   RLC
            ,ven_re_cond_filter_obl v
       WHERE v.re_cond_filter_obl_id = rlc.re_cond_filter_obl_id
         AND v.re_contract_ver_id = par_re_version_id
         AND rlc.fund_id = par_fund_id
         AND v.product_line_id = par_product_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        res := 0;
    END;
  
    IF nvl(res, 0) = 0
    THEN
      BEGIN
        SELECT nvl(prp.self_deduction_percent, 0) / 100
          INTO res
          FROM re_policy_reinsurance_program prp
         WHERE prp.product_line_id = par_product_line_id
           AND prp.policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    END IF;
  
    IF nvl(res, 0) = 0
    THEN
      BEGIN
        SELECT nvl(cl.limit_percent, 0)
          INTO res
          FROM re_cumulative_limit cl
         WHERE cl.fund_id = par_fund_id;
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    END IF;
  
    IF nvl(res, 0) = 0
    THEN
      BEGIN
        SELECT nvl(fo.limit_percent, 0)
          INTO res
          FROM re_cond_filter_obl  fo
              ,re_contract_version cv -- ven_re_line_contract c--  re_limit_contract c
         WHERE cv.re_contract_version_id = fo.re_contract_ver_id
           AND cv.re_contract_version_id = par_re_version_id
           AND fo.product_line_id = par_product_line_id
           AND cv.fund_id = par_fund_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    END IF;
  
    IF res = 0
       AND nvl(par_rvb_value, 0) > 0
    THEN
      res := 1 - par_rvb_value;
    END IF;
  
    RETURN res;
  END get_limit_percent;

  /* Функция рассчитывает  годовую перстраховочную премию
   T        - тариф перестраховщика,
   K_med    - повышающий медицинский коэффициент в %,
   K_no_med - повышающий немедицинский коэффициент в %,
   S_med    - повышающий медицинский коэффициент в ‰,
   S_no_med - повышающий немедицинский коэффициент в ‰.
  */
  FUNCTION get_reinsurance_premium
  (
    par_t        IN NUMBER
   ,par_K_med    IN NUMBER
   ,par_K_no_med IN NUMBER
   ,par_S_med    IN NUMBER
   ,par_no_med   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    NULL;
  END get_reinsurance_premium;

  /* Функция возвращает долю перестраховщика
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_kind_reinsurance
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN least(ret_percent * obi, ret_limit);
  END get_kind_reinsurance;

  /* Функция расчитывает долю перестраховщика по настраиваемой функции
  */
  FUNCTION get_RS_by_func
  (
    par_version_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,ret_percent         IN NUMBER
   ,OBI                 IN NUMBER
   ,ret_limit           IN NUMBER
  ) RETURN NUMBER AS
    v_func_text VARCHAR2(1000);
    v_func_id   NUMBER;
    res         NUMBER;
    c           INTEGER;
    i           INTEGER;
  BEGIN
  
    SELECT v.re_portion_function_id
      INTO v_func_id
      FROM re_contract_ver_func v
          ,re_cond_filter_obl   fo
          ,re_contract_ver_fund f
     WHERE v.re_cond_filter_obl_id = fo.re_cond_filter_obl_id
       AND fo.re_contract_ver_fund_id = f.re_contract_ver_fund_id
       AND fo.re_contract_ver_id = par_version_id
       AND fo.product_line_id = par_product_line_id
       AND f.fund_id = par_fund_id;
  
    SELECT t.r_sql INTO v_func_text FROM t_prod_coef_type t WHERE t.t_prod_coef_type_id = v_func_id;
  
    IF v_func_text IS NOT NULL
    THEN
      IF Check_SQL_Text(v_func_text)
      THEN
        c := DBMS_SQL.open_cursor;
        DBMS_SQL.PARSE(c, v_func_text, dbms_sql.native);
      
        dbms_sql.bind_variable(c, 'res', res);
        dbms_sql.bind_variable(c, 'ret_percent', ret_percent);
        dbms_sql.bind_variable(c, 'OBI', OBI);
        dbms_sql.bind_variable(c, 'ret_limit', ret_limit);
      
        i := DBMS_SQL.EXECUTE(c);
        DBMS_SQL.VARIABLE_VALUE(c, 'res', res);
        Dbms_SQL.close_cursor(c);
      END IF;
    END IF;
  
    RETURN res;
  EXCEPTION
    WHEN OTHERS THEN
      res := get_RS(ret_percent, OBI, ret_limit);
      RETURN res;
  END get_RS_by_func;

  /* Функция возвращает долю перестраховщика
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_RS
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN(1 - least(ret_percent * obi, ret_limit) / obi);
  END get_RS;

  /* Функция возвращает долю перестраховщика
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_RS_add
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN 0.5 *(1 - (ret_percent * least(obi, ret_limit) + nvl(obi - ret_limit, 0)) / obi);
  END get_RS_add;

  /* Функция расчитывает собственное удержание  по настраиваемой функции
  */
  FUNCTION get_IR_by_func
  (
    par_version_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,ret_percent         IN NUMBER
   ,OBI                 IN NUMBER
   ,ret_limit           IN NUMBER
  ) RETURN NUMBER AS
    v_func_text VARCHAR2(1000);
    v_func_id   NUMBER;
    res         NUMBER;
    c           INTEGER;
    i           INTEGER;
  BEGIN
    SELECT v.deduction_function_id
      INTO v_func_id
      FROM re_contract_ver_func v
          ,re_cond_filter_obl   fo
          ,re_contract_ver_fund f
     WHERE v.re_cond_filter_obl_id = fo.re_cond_filter_obl_id
       AND fo.re_contract_ver_fund_id = f.re_contract_ver_fund_id
       AND fo.re_contract_ver_id = par_version_id
       AND fo.product_line_id = par_product_line_id
       AND f.fund_id = par_fund_id;
  
    --  from re_contract_ver_func v where v.re_contract_version_id=par_version_id;
  
    SELECT t.r_sql INTO v_func_text FROM t_prod_coef_type t WHERE t.t_prod_coef_type_id = v_func_id;
  
    IF v_func_text IS NOT NULL
    THEN
      IF Check_SQL_Text(v_func_text)
      THEN
        c := DBMS_SQL.open_cursor;
        DBMS_SQL.PARSE(c, v_func_text, dbms_sql.native);
      
        dbms_sql.bind_variable(c, 'res', res);
        dbms_sql.bind_variable(c, 'ret_percent', ret_percent);
        dbms_sql.bind_variable(c, 'OBI', OBI);
        dbms_sql.bind_variable(c, 'ret_limit', ret_limit);
      
        i := DBMS_SQL.EXECUTE(c);
        DBMS_SQL.VARIABLE_VALUE(c, 'res', res);
        Dbms_SQL.close_cursor(c);
      END IF;
    END IF;
  
    RETURN res;
  
  EXCEPTION
    WHEN no_data_found THEN
      res := get_IR(ret_percent, OBI, ret_limit);
      RETURN res;
  END get_IR_by_func;

  /* Функция возвращает собственное удержание
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_IR
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN least(ret_percent * OBI, ret_limit);
  END get_IR;

  /* Функция возвращает собственное удержание
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_IR_add
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN least(ret_percent * OBI, ret_limit);
  END get_IR_add;

  /* Функция возвращает дополнительную долю перестраховщика
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_added_kind_reinsurance
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN least(ret_percent * obi, ret_limit) + greatest(OBI - ret_limit);
  END get_added_kind_reinsurance;

  /* Функция возвращает дополнительное собственное удержание
    ret_percent - процент собственного удержания
    OBI         - первоначальное перестраховочное обеспечение под риском
    ret_limit   - лимит собственного удержания
  */
  FUNCTION get_added_RS
  (
    ret_percent IN NUMBER
   ,OBI         IN NUMBER
   ,ret_limit   IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN(1 - (least(ret_percent * obi, ret_limit) + greatest(OBI - ret_limit) / obi));
  END get_added_RS;

  FUNCTION get_norm_rate(par_cover_year IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
  
    SELECT pc.val
      INTO res
      FROM t_prod_coef      pc
          ,t_prod_coef_type t
     WHERE t.t_prod_coef_type_id = pc.t_prod_coef_type_id
       AND t.brief = 'RE_NORM_RATE'
       AND pc.criteria_1 > par_cover_year
       AND pc.criteria_2 <= par_cover_year;
  
    RETURN res;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END get_norm_rate;

  /* Функция расчета годовой премии по настраиваемой функции
  */
  FUNCTION get_YRP_by_func
  (
    par_version_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_RBI             IN NUMBER
   ,par_tarif           IN NUMBER
   ,par_SRR             IN NUMBER
   ,par_RS              IN NUMBER
   ,par_k_med           IN NUMBER
   ,par_k_no_med        IN NUMBER
   ,par_s_med           IN NUMBER
   ,par_s_no_med        NUMBER
  ) RETURN NUMBER AS
    v_sql       VARCHAR2(1000);
    v_func_text VARCHAR2(1000);
    v_func_id   NUMBER;
    res         NUMBER;
    c           INTEGER;
    i           INTEGER;
  BEGIN
    SELECT v.re_premium_function_id
      INTO v_func_id
      FROM re_contract_ver_func v
          ,re_cond_filter_obl   fo
          ,re_contract_ver_fund f
     WHERE v.re_cond_filter_obl_id = fo.re_cond_filter_obl_id
       AND fo.re_contract_ver_fund_id = f.re_contract_ver_fund_id
       AND fo.re_contract_ver_id = par_version_id
       AND fo.product_line_id = par_product_line_id
       AND f.fund_id = par_fund_id;
  
    SELECT t.r_sql INTO v_func_text FROM t_prod_coef_type t WHERE t.t_prod_coef_type_id = v_func_id;
  
    -- v_sql:='select ' || v_func_text ||'(:par_RBI, :par_tarif, :par_SRR, :par_RS, :par_k_med, :par_k_no_med, :par_s_med, :par_s_no_med) from dual';
    --EXECUTE IMMEDIATE v_sql  INTO res using par_RBI,  par_SRR, par_tarif, par_RS, par_k_med, par_k_no_med, par_s_med, par_s_no_med;
  
    IF v_func_text IS NOT NULL
    THEN
      IF Check_SQL_Text(v_func_text)
      THEN
        c := DBMS_SQL.open_cursor;
        DBMS_SQL.PARSE(c, v_func_text, dbms_sql.native);
      
        dbms_sql.bind_variable(c, 'res', res);
        dbms_sql.bind_variable(c, 'RBI', par_RBI);
        dbms_sql.bind_variable(c, 'tarif', par_tarif);
        dbms_sql.bind_variable(c, 'SRR', par_SRR);
        dbms_sql.bind_variable(c, 'RS', par_RS);
        dbms_sql.bind_variable(c, 'k_med', par_k_med);
        dbms_sql.bind_variable(c, 'k_no_med', par_k_med);
        dbms_sql.bind_variable(c, 's_med', par_k_med);
        dbms_sql.bind_variable(c, 's_no_med', par_k_med);
      
        i := DBMS_SQL.EXECUTE(c);
        DBMS_SQL.VARIABLE_VALUE(c, 'res', res);
        Dbms_SQL.close_cursor(c);
      END IF;
    END IF;
  
    RETURN res;
  EXCEPTION
    WHEN OTHERS THEN
      res := get_YRP(par_RBI
                    ,par_tarif
                    ,par_SRR
                    ,par_RS
                    ,par_k_med
                    ,par_k_no_med
                    ,par_s_med
                    ,par_s_no_med);
    
      RETURN res;
  END get_YRP_by_func;

  /* Расчет суммы годовой премии перестраховщика
    par_SRR      - Сумма под риском перестраховщика
    par_k_med    - повышающий медицинский коэффициент %
    par_k_no_med - повышающий немедецинский коэффициент %
    par_tarif    - тариф перестраховщика
    par_s_med    - повышающий медицинский коэффициент %
    par_s_no_med - повышающий немедицинский коэффициент %
  */
  FUNCTION get_YRP
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_SRR *((100 + par_k_med + par_k_no_med) / 100) *(par_tarif +
                                                               (par_s_med + par_s_no_med) / 1000);
  END get_YRP;

  /* Расчет суммы годовой премии перестраховщика (для договоров с единовременной уплатой взносов)
    par_RBI      - Текущее страховое обеспечение под риском
    par_RS       - Доля перестраховщика в убытке
    par_k_med    - повышающий медицинский коэффициент %
    par_k_no_med - повышающий немедецинский коэффициент %
    par_tarif    - тариф перестраховщика
    par_s_med    - повышающий медицинский коэффициент %
    par_s_no_med - повышающий немедицинский коэффициент %
  */

  FUNCTION get_YRP_single
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_RBI * par_RS *((par_tarif * (100 + par_k_med + par_k_no_med) / 100) +
                              (par_s_med + par_s_no_med) / 1000);
  END get_YRP_single;

  /* Дополнительная сумма премии перестраховщиа
    par_RBI   - текущая сумма под риском
    par_tarif - Тариф
  */
  FUNCTION get_added_YRP
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_RBI * par_tarif;
  END get_added_YRP;

  /* Дополнительная сумма премии перестраховщиа
    par_RBI   - текущая сумма под риском
    par_tarif - Тариф
  */
  FUNCTION YRP_SwissRe
  (
    par_RBI      IN NUMBER
   ,par_tarif    IN NUMBER
   ,par_SRR      IN NUMBER
   ,par_RS       IN NUMBER
   ,par_k_med    IN NUMBER
   ,par_k_no_med IN NUMBER
   ,par_s_med    IN NUMBER
   ,par_s_no_med NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_RBI * par_tarif;
  END YRP_SwissRe;

  /*  Первоначальная сумма под риском
    par_SA          - Страховая сумма
    par_V           - Актуарный резерв
    par_flag_single - Флаг единовременной выплаты
  */
  FUNCTION get_OBI
  (
    par_SA                  IN NUMBER
   ,par_V                   IN NUMBER
   ,par_flag_single         IN NUMBER
   ,par_brief               IN VARCHAR2
   ,par_a_xn                IN NUMBER
   ,par_flg_no_calc_reserve IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
  
    IF par_brief IN ('WOP', 'PWOP')
    THEN
      IF par_flg_no_calc_reserve = 1
      THEN
        RETURN par_SA;
      ELSE
        RETURN par_SA * par_a_xn;
      END IF;
    ELSE
      IF par_flag_single = 1 /** О14 должна быть 1 соответствует непериодическому случаю О14 **/
      THEN
        RETURN par_SA *(1 - par_V);
      ELSE
        RETURN par_SA;
      END IF;
    END IF;
  END get_OBI;

  /* Первоначальная сумма под риском свыше собственного удержания
    par_OBI - Первоначальная сумма под риском
    par_IR  - Первоначальное собственное удержание
  */
  FUNCTION get_ISRAR
  (
    par_OBI IN NUMBER
   ,par_IR  IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_OBI - par_IR;
  END get_ISRAR;

  /* Первоначальное перестраховочное обеспечение под риском
    par_OBI - Первоначальное страховое обеспечение под риском
    par_RS  - Величина доли перестраховщика
  */
  FUNCTION get_OBR
  (
    par_OBI IN NUMBER
   ,par_RS  IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_OBI * par_RS;
  END get_OBR;

  /* Сумма страхового обеспечения под риском
    par_SA - Страховая сумма
    par_V  - Актуарный резерв
  */
  FUNCTION get_RBI
  (
    par_SA                  IN NUMBER
   ,par_V                   IN NUMBER
   ,par_brief               IN VARCHAR2
   ,par_a_x_n               IN NUMBER
   ,par_flg_no_calc_reserve IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    --Если настроена функция, то запускаем функцию
    --if   then
  
    --else
    IF par_brief IN ('WOP', 'PWOP')
    THEN
      IF par_flg_no_calc_reserve = 1
      THEN
        RETURN par_SA;
      ELSE
        RETURN par_SA * par_a_x_n;
      END IF;
    ELSE
      RETURN par_SA *(1 - par_V);
    END IF;
    --end if;
  END get_RBI;

  /* Собственное удержание
    par_IR  - Первоначальное собственное удержание
    par_RBI - Сумма страхового обеспечения под риском
    par_OBI - Первоначальное страховое обеспечение под риском
  */
  FUNCTION get_R
  (
    par_IR  IN NUMBER
   ,par_RBI IN NUMBER
   ,par_OBI IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_IR * par_RBI / par_OBI;
  END get_R;

  /* Сумма перестраховочного обеспечения под риском
    par_RBI - Сумма страхового обеспечения под риском
    par_RS  - Величина доли перестраховщика
  */
  FUNCTION get_SRR
  (
    par_RBI IN NUMBER
   ,par_RS  IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_RBI * par_RS;
  END get_SRR;

  /* Риск (смертельно опасное заболевание)
  
  */
  FUNCTION get_DD
  (
    par_A_xn        IN NUMBER
   ,par_a_x_n       IN NUMBER
   ,par_P           IN NUMBER
   ,par_flag_single IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    IF par_flag_single = 1
    THEN
      RETURN greatest(par_A_xn, 0);
    ELSE
      RETURN greatest(par_A_xn - par_P * par_a_x_n, 0);
    END IF;
  END get_DD;

  FUNCTION get_v(par_i IN NUMBER) RETURN NUMBER AS
  BEGIN
    RETURN 1 /(1 + par_i);
  END get_v;

  /* коэффициент периодичности рассрочки платежа
  
  */
  FUNCTION get_MF
  (
    par_re_version_id    IN NUMBER
   ,par_paymentoff_id    IN NUMBER
   ,par_is_group         IN NUMBER
   ,par_paymentoff_count IN NUMBER
  ) RETURN NUMBER AS
    v_val     NUMBER;
    v_func_id NUMBER;
  BEGIN
    --Для групповых договоров рассчитываем по кличеству платежей
    IF par_is_group = 1
    THEN
      v_val := 1 / par_paymentoff_count;
    ELSE
      --Ищем функцию в договоре перестрахования
      SELECT cv.func_calc_id
        INTO v_func_id
        FROM re_contract_version cv
       WHERE cv.re_contract_version_id = par_re_version_id;
    
      IF v_func_id IS NOT NULL
      THEN
        SELECT pc.val
          INTO v_val
          FROM t_prod_coef pc
         WHERE pc.t_prod_coef_type_id = v_func_id
           AND pc.criteria_1 = par_paymentoff_id;
      END IF;
    END IF;
  
    RETURN v_val;
  END get_MF;

  /* База суммы перестраховочной премии
    par_YRP - Сумма годовой премии перестраховщика
    par_MF  - Перестраховочный коэффициент рассочки
  */
  FUNCTION get_PRP
  (
    par_YRP IN NUMBER
   ,par_MF  IN NUMBER
  ) RETURN NUMBER AS
  BEGIN
    RETURN par_YRP * par_MF;
  END get_PRP;

  /*  Функция для расчета процента перестраховочной комиссии
  */
  FUNCTION get_re_com_rate
  (
    par_re_version_id IN NUMBER
   ,par_prod_line_id  IN NUMBER
   ,par_autoprolong   IN NUMBER
   ,par_cover_year    IN NUMBER
   ,par_fund_id       IN NUMBER
  ) RETURN NUMBER IS
    res             NUMBER;
    v_comis_func_id NUMBER;
    v_cover_year    NUMBER;
    v_func_text     VARCHAR2(1000);
    c               INTEGER;
    i               INTEGER;
  BEGIN
    --Проверяем заполнение полей перестраховочной комиссии
    SELECT cv.re_comis_func_id
      INTO v_comis_func_id
      FROM re_contract_version cv
     WHERE cv.re_contract_version_id = par_re_version_id;
  
    IF v_comis_func_id IS NULL
    THEN
      --Если не указана функция перестраховочной комиссии, то берем процент из фильтров
      BEGIN
        SELECT l.commission_perc / 100
          INTO res
          FROM re_cond_filter_obl   fo
              ,re_line_contract     l
              ,re_contract_ver_fund rcvf
         WHERE l.re_cond_filter_obl_id = fo.re_cond_filter_obl_id
           AND fo.re_contract_ver_id = par_re_version_id
           AND fo.product_line_id = par_prod_line_id
           AND fo.re_contract_ver_fund_id = rcvf.re_contract_ver_fund_id
           AND rcvf.fund_id = par_fund_id;
      EXCEPTION
        WHEN no_data_found THEN
          res := 0;
      END;
    ELSE
      --если функция задана, то расчитываем по функции
      IF par_cover_year > 5
      THEN
        --Приводим срок действия покрытия к табличному виду
        v_cover_year := 999;
      ELSE
        v_cover_year := par_cover_year;
      END IF;
    
      IF par_autoprolong = 1
      THEN
        --Для договоров с автопролонгацией берем срок действия 1 год
        v_cover_year := 1;
      END IF;
    
      --Определяем процент комиссии по функции
      SELECT t.val / 100
        INTO res
        FROM t_prod_coef t
       WHERE t.t_prod_coef_type_id = v_comis_func_id
         AND t.criteria_1 = v_cover_year;
    END IF;
  
    RETURN res;
  END get_re_com_rate;

  /*  Функция расчета перестраховочной комиссии
  */
  PROCEDURE get_re_comiss
  (
    par_re_version_id        IN NUMBER
   ,par_re_bordero_type_id   IN NUMBER
   ,par_flg_no_comiss        IN NUMBER
   ,par_PRP                  IN NUMBER
   ,par_year_cover           IN NUMBER
   ,par_year                 IN NUMBER
   ,par_autoprolongation     IN NUMBER
   ,par_re_calc_func_id      IN NUMBER
   ,par_cover_start_date     IN DATE
   ,par_cover_end_date       IN DATE
   ,par_bordero_start_date   IN DATE
   ,par_bordero_end_date     IN DATE
   ,par_product_line_id      IN NUMBER
   ,par_product_line_type_id IN NUMBER
   ,par_payment_period_start IN DATE
   ,par_payment_period_end   IN DATE
   ,par_first_payment_date   IN DATE
   ,par_insurance_type       IN VARCHAR2
   ,par_header_start         IN DATE
   ,par_header_end           IN DATE
   ,par_re_com_rate          IN OUT NUMBER
   ,par_result               OUT NUMBER
  ) IS
    --  v_result number := 0;
    v_re_calc_func_id        NUMBER;
    v_re_return_calc_func_id NUMBER;
    v_func_text              t_prod_coef_type.r_sql%TYPE;
    c                        INTEGER;
    i                        INTEGER;
  BEGIN
    par_result := 0;
    IF par_flg_no_comiss = 0
       AND par_re_bordero_type_id IN (1, 2, 3) /* БПП, БД, БИ */
    THEN
      --Вызов функции PL/SQL
      IF par_re_calc_func_id IS NOT NULL
      THEN
        SELECT t.r_sql
          INTO v_func_text
          FROM t_prod_coef_type t
         WHERE t.t_prod_coef_type_id = par_re_calc_func_id;
      
        IF v_func_text IS NOT NULL
        THEN
          IF Check_SQL_Text(v_func_text)
          THEN
            c := DBMS_SQL.open_cursor;
            DBMS_SQL.PARSE(c, v_func_text, dbms_sql.native);
          
            dbms_sql.bind_variable(c, 'res', par_result);
            dbms_sql.bind_variable(c, 'PRP', par_PRP);
            dbms_sql.bind_variable(c, 'cover_start_date', par_cover_start_date);
            dbms_sql.bind_variable(c, 'cover_end_date', par_cover_end_date);
            dbms_sql.bind_variable(c, 'start_date', par_bordero_start_date);
            dbms_sql.bind_variable(c, 'end_date', par_bordero_end_date);
            dbms_sql.bind_variable(c, 'year', par_year);
            dbms_sql.bind_variable(c, 'year_cover', par_year_cover);
            dbms_sql.bind_variable(c, 'product_line_id', par_product_line_id);
            dbms_sql.bind_variable(c, 'product_line_type_id', par_product_line_type_id);
            dbms_sql.bind_variable(c, 'payment_period_start', par_payment_period_start);
            dbms_sql.bind_variable(c, 'payment_period_end', par_payment_period_end);
            dbms_sql.bind_variable(c, 'first_payment_date', par_first_payment_date);
            dbms_sql.bind_variable(c, 'insurance_type', par_insurance_type);
            dbms_sql.bind_variable(c, 'header_start_date', par_header_start);
            dbms_sql.bind_variable(c, 'header_end_date', par_header_end);
          
            i := DBMS_SQL.EXECUTE(c);
            DBMS_SQL.VARIABLE_VALUE(c, 'res', par_result);
            Dbms_SQL.close_cursor(c);
          
            /** О18 Код до исправления О18 **/
            --          par_re_com_rate := par_result/par_PRP;
            /** О18 Конец Код до исправления О18 **/
          
            /** О18 Код после исправления О18 **/
          
            IF ((par_PRP = 0) OR (par_PRP IS NULL))
            THEN
              -- ** О18 Убрано деление на нуль в случае когда PRP = 0
              -- ** О18 Эта ситуация происходит в случае если значение перестраховочного тарифа не найдено
              -- ** О18 При этом зануляем также и результат расчета комиссии так как комиссия нулевая, когда PRP нулевая
              par_re_com_rate := 0; -- add_com_rate
              par_result      := 0; -- add_commission
            ELSE
              par_re_com_rate := par_result / par_PRP;
            END IF;
          
            /** О18 Конец Код после исправления О18 **/
          
          END IF;
        END IF;
      ELSE
        /*if par_year = 1 or (par_year > 1 and par_autoprolongation = 1) then  --Расчет первого года для всех рисков и последующих лет с автопролонгацией
          par_result := par_PRP * par_re_com_rate;
        end if;*/
        par_re_com_rate := 0;
        par_result      := 0;
      END IF;
    END IF;
  END get_re_comiss;

  FUNCTION get_paid_re_comission
  (
    par_re_main_contract_id NUMBER
   ,par_p_pol_header_id     NUMBER
   ,par_product_line_id     NUMBER
   ,par_assured_contact_id  NUMBER
   ,par_start_date          DATE
   ,par_cancel_date         DATE
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT SUM(nvl(bl.re_comision, 0) - nvl(bl.returned_comission, 0))
      INTO v_result
      FROM re_bordero_line    bl
          ,re_bordero         rb
          ,re_bordero_package bp
          ,as_assured         su
     WHERE bl.re_bordero_id = rb.re_bordero_id
       AND rb.re_bordero_package_id = bp.re_bordero_package_id
       AND bp.re_m_contract_id = par_re_main_contract_id
          
       AND bl.product_line_id = par_product_line_id
       AND bl.as_assured_id = su.as_assured_id
       AND su.assured_contact_id = par_assured_contact_id
       AND rb.re_bordero_type_id IN (1, 2, 41) /* БПП, БД, БИ */
       AND bl.payment_start_date BETWEEN par_start_date AND par_cancel_date - 1
       AND bl.pol_header_id = par_p_pol_header_id;
  
    RETURN v_result;
  END get_paid_re_comission;

  /*
    Функция расчета перестраховочной комиссии к возврату
  */
  PROCEDURE get_re_comiss_returned
  (
    par_re_main_contract_id  IN NUMBER
   ,par_p_pol_header_id      IN NUMBER
   ,par_assured_contact_id   IN NUMBER
   ,par_re_bordero_type_id   IN NUMBER
   ,par_flg_no_comiss        IN NUMBER
   ,par_re_calc_func_id      IN NUMBER
   ,par_cover_start_date     IN DATE
   ,par_cover_end_date       IN DATE
   ,par_bordero_start_date   IN DATE
   ,par_bordero_end_date     IN DATE
   ,par_product_line_id      IN NUMBER
   ,par_product_line_type_id IN NUMBER
   ,par_payment_period_start IN DATE
   ,par_payment_period_end   IN DATE
   ,par_first_payment_date   IN DATE
   ,par_cancel_date          IN DATE
   ,par_insurance_type       IN VARCHAR2
   ,par_re_fixed_com         IN NUMBER
   ,par_return_add_com       OUT NUMBER
   ,par_return_fixed_com     OUT NUMBER
  ) IS
    v_result                   NUMBER := 0;
    v_re_calc_func_id          NUMBER;
    v_re_return_calc_func_id   NUMBER;
    v_func_text                t_prod_coef_type.r_sql%TYPE;
    c                          PLS_INTEGER;
    i                          PLS_INTEGER;
    v_paid_re_comiss           NUMBER;
    v_paid_re_comiss_last_year NUMBER;
    v_last_year_date           DATE;
  BEGIN
    IF /*par_flg_no_comiss = 0 and */
     par_re_bordero_type_id IN (3, 5) /* БИ, БР */
    THEN
      --Вызов функции PL/SQL
      IF par_re_calc_func_id IS NOT NULL
      THEN
        SELECT t.r_sql
          INTO v_func_text
          FROM t_prod_coef_type t
         WHERE t.t_prod_coef_type_id = par_re_calc_func_id;
      
        IF v_func_text IS NOT NULL
        THEN
          IF Check_SQL_Text(v_func_text)
          THEN
            v_paid_re_comiss := get_paid_re_comission(par_re_main_contract_id => par_re_main_contract_id
                                                     ,par_p_pol_header_id     => par_p_pol_header_id
                                                     ,par_product_line_id     => par_product_line_id
                                                     ,par_assured_contact_id  => par_assured_contact_id
                                                     ,par_start_date          => par_first_payment_date
                                                     ,par_cancel_date         => par_cancel_date);
          
            v_last_year_date := get_anniversary_date(par_date       => par_cancel_date
                                                    ,par_start_date => par_first_payment_date
                                                    ,par_mode       => 2 /* Не позднее*/);
          
            v_paid_re_comiss_last_year := get_paid_re_comission(par_re_main_contract_id => par_re_main_contract_id
                                                               ,par_p_pol_header_id     => par_p_pol_header_id
                                                               ,par_product_line_id     => par_product_line_id
                                                               ,par_assured_contact_id  => par_assured_contact_id
                                                               ,par_start_date          => v_last_year_date
                                                               ,par_cancel_date         => par_cancel_date);
            c                          := DBMS_SQL.open_cursor;
            DBMS_SQL.PARSE(c, v_func_text, dbms_sql.native);
          
            dbms_sql.bind_variable(c, 'res', par_return_add_com);
            dbms_sql.bind_variable(c, 'cover_start_date', par_cover_start_date);
            dbms_sql.bind_variable(c, 'cover_end_date', par_cover_end_date);
            dbms_sql.bind_variable(c, 'start_date', par_bordero_start_date);
            dbms_sql.bind_variable(c, 'end_date', par_bordero_end_date);
            dbms_sql.bind_variable(c, 'product_line_id', par_product_line_id);
            dbms_sql.bind_variable(c, 'product_line_type_id', par_product_line_type_id);
            dbms_sql.bind_variable(c, 'payment_period_start', par_payment_period_start);
            dbms_sql.bind_variable(c, 'payment_period_end', par_payment_period_end);
            dbms_sql.bind_variable(c, 'first_payment_date', par_first_payment_date);
            dbms_sql.bind_variable(c, 'insurance_type', par_insurance_type);
            dbms_sql.bind_variable(c, 'cancel_date', par_cancel_date);
            dbms_sql.bind_variable(c, 'paid_re_comiss', v_paid_re_comiss);
            dbms_sql.bind_variable(c, 'paid_re_comiss_last_year', v_paid_re_comiss_last_year);
            --          dbms_sql.bind_variable(c,'re_comission',par_re_comission);
          
            i := DBMS_SQL.EXECUTE(c);
            DBMS_SQL.VARIABLE_VALUE(c, 'res', par_return_add_com);
            Dbms_SQL.close_cursor(c);
          END IF;
        END IF;
        -- ** #57 тут надо также вычислять возврат фиксированной комиссии
        par_return_fixed_com := par_re_fixed_com *
                                ((par_payment_period_end - par_cancel_date + 1 /* #П56_1 */
                                ) / (par_payment_period_end + 1 - par_payment_period_start));
        -- ** #57 конец вставки
      ELSE
        par_return_add_com   := 0;
        par_return_fixed_com := par_re_fixed_com *
                                ((par_payment_period_end - par_cancel_date + 1 /* #П56_1 */
                                ) / (par_payment_period_end + 1 - par_payment_period_start));
        --      v_result := par_re_comission * (((par_payment_period_end - par_cancel_date)+ 1) / ((par_payment_period_end - par_payment_period_start) + 1));
        -- Расчет прораты без 1
        -- надо тестировать цифры (пока сделано одинаково с возвратом премии get_RP)
        --v_result := par_re_comission * ((par_payment_period_end - par_cancel_date) / (par_payment_period_end - par_payment_period_start));
      END IF;
    END IF;
    --return v_result;
  END get_re_comiss_returned;

  FUNCTION get_bordero_id
  (
    par_bordero_package_id IN NUMBER
   ,par_bordero_type_id    IN NUMBER
   ,par_fund_id            IN NUMBER
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    SELECT b.re_bordero_id
      INTO res
      FROM re_bordero b
     WHERE b.re_bordero_package_id = par_bordero_package_id
       AND b.re_bordero_type_id = par_bordero_type_id
       AND b.fund_id = par_fund_id;
  
    RETURN res;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'Не найдено бордеро. Расчет невозможен!');
  END get_bordero_id;

  /*  Функция определения типа бордеро
      1 - Бордеро первых платежей(БПП),
      2 - Бордеро доплат (БД)
      41 - Бордеро изменений (БИ)
  
  */

  FUNCTION get_bordero_type
  (
    par_bordero_date_begin IN DATE
   ,par_bordero_date_end   IN DATE
   ,par_first_pay_date     IN DATE
   ,par_pay_date           IN DATE
   ,par_cover_start_date   IN DATE
   ,par_pol_header_id      IN NUMBER
   ,par_policy_id          IN NUMBER
  ) RETURN NUMBER IS
    res         NUMBER;
    v_policy_id NUMBER;
  BEGIN
    --Проверяем, входит ли первый платеж в бордеро
    --  if par_first_pay_date between par_bordero_date_begin and par_bordero_date_end then
    IF par_pay_date = par_cover_start_date
    THEN
      --Если дата начала покрытия совпадает с датой первого платежа, то БПП
      res := 1;
    ELSE
      --Проверяем, что дата платежа входит в период действия бордеро
      IF par_pay_date BETWEEN par_bordero_date_begin AND par_bordero_date_end
      THEN
        --Проверяем, какая версия действовала на дату платежа
        v_policy_id := Policy_Effective_On_Date(par_pol_header_id, par_pay_date);
      
        /*  select MAX(pp.policy_id) into v_policy_id
          from p_policy pp where pp.pol_header_id=par_pol_header_id
          and pp.start_date between par_first_pay_date and par_pay_date;
        */
        IF v_policy_id = par_policy_id
        THEN
          --Если версия не изменилясь, то это бордеро доплат
          res := 2; --Бордеро доплат
        ELSE
          res := 41; --Если версия изменилась, то это бордеро изменений
        END IF;
      ELSE
        res := 0;
      END IF;
    END IF;
    --  end if;
  
    RETURN res;
  END;

  /* Функция определения типа премии
  */

  FUNCTION get_premium_type
  (
    par_start_pay_date   IN DATE
   ,par_bordero_end_date IN DATE
   ,par_type             IN NUMBER
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    IF trunc(par_start_pay_date, 'YYYY') >= trunc(par_bordero_end_date, 'YYYY')
    THEN
      res := 1;
    ELSE
      res := 2;
    END IF;
  
    RETURN par_type + res;
  END get_premium_type;

  /* Функция расчитывает сумму возврата премии по настраиваемой функции
  */
  FUNCTION get_RP_by_func
  (
    par_version_id      IN NUMBER
   ,par_PRP             IN NUMBER
   ,par_pay_start_date  IN DATE
   ,par_pay_end_date    IN DATE
   ,par_decline_date    IN DATE
   ,par_product_line_id IN NUMBER
   ,par_fund_id         IN NUMBER
  ) RETURN NUMBER AS
    v_func_text VARCHAR2(1000);
    v_func_id   NUMBER;
    res         NUMBER;
    c           INTEGER;
    i           INTEGER;
  BEGIN
    BEGIN
      SELECT v.return_premium_function_id
        INTO v_func_id
        FROM re_contract_ver_func v
            ,re_cond_filter_obl   fo
       WHERE fo.re_cond_filter_obl_id = v.re_cond_filter_obl_id
         AND fo.re_contract_ver_id = par_version_id
         AND v.re_contract_ver_fund_id = par_fund_id
         AND fo.product_line_id = par_product_line_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не настроена функция расчета возврата премии ');
    END;
  
    IF v_func_id IS NOT NULL
    THEN
      SELECT t.r_sql INTO v_func_text FROM t_prod_coef_type t WHERE t.t_prod_coef_type_id = v_func_id;
    
      IF v_func_text IS NOT NULL
      THEN
        IF Check_SQL_Text(v_func_text)
        THEN
          c := DBMS_SQL.open_cursor;
          DBMS_SQL.PARSE(c, v_func_text, dbms_sql.native);
        
          dbms_sql.bind_variable(c, 'res', res);
          dbms_sql.bind_variable(c, 'PRP', par_PRP);
          dbms_sql.bind_variable(c, 'start_date', par_pay_start_date);
          dbms_sql.bind_variable(c, 'end_date', par_pay_end_date);
          dbms_sql.bind_variable(c, 'decline_date', par_decline_date);
        
          i := DBMS_SQL.EXECUTE(c);
          DBMS_SQL.VARIABLE_VALUE(c, 'res', res);
          Dbms_SQL.close_cursor(c);
        END IF;
      END IF;
    ELSE
      raise_application_error(-20000
                             ,'Не настроена функция расчета возврата премии ');
    END IF;
    RETURN res;
  END get_RP_by_func;

  /*Функция расчета суммы возврата премии
  */
  FUNCTION get_RP
  (
    par_PRP            IN NUMBER
   ,par_pay_start_date IN DATE
   ,par_pay_end_date   IN DATE
   ,par_decline_date   IN DATE
    -- ,par_periodical in number
   ,par_return_finc_id NUMBER
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
  
    IF par_return_finc_id IS NULL
    THEN
      --Если не определена функция расчета, то рассчитываем долю по датам
      res := par_PRP * (par_pay_end_date - par_decline_date + 1 /* #П56_1 */
             ) / (par_pay_end_date - par_pay_start_date + 1 /* #П56_1 */
             );
    ELSE
      SELECT pc.val INTO res FROM t_prod_coef pc WHERE pc.t_prod_coef_type_id = par_return_finc_id;
      -- and pc.criteria_1=par_paymentoff_id;
    END IF;
    RETURN res;
  END;

  /*  Функция расчета тарифа
  par_policy_id - ID версии договора страхования
  par_asset_id - ID застрахованного
  par_insured_age - Возраст застахованного
  par_bordero_type - Тип бордеро
  par_flg_all_program - Флаг Перечисления всех программ
  par_re_version_id - ID версии договора престрахования
  par_fund_id - ID валюты
  par_gender - ID пола
  */
  FUNCTION get_tariff
  (
    par_policy_id       IN NUMBER
   ,par_asset_id        IN NUMBER
   ,par_insured_age     IN NUMBER
   ,par_cover_id        IN NUMBER
   ,par_bordero_type    IN NUMBER
   ,par_flg_all_program IN NUMBER
   ,par_re_version_id   IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_gender          IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_prod_line_id    IN NUMBER
   ,par_work_group_id   IN NUMBER
   ,par_ins_amount      IN NUMBER
  ) RETURN NUMBER IS
    res                 NUMBER;
    v_func_tarif_id     NUMBER;
    v_work_group_id     NUMBER;
    v_cover_under       NUMBER;
    v_first_param_brief VARCHAR2(100);
    v_func_brief        VARCHAR2(100);
    v_message           VARCHAR2(500);
  
    v_flg_prof_loading re_contract_version.flg_prof_loading%TYPE;
    v_func_loading_id  re_contract_version.func_loading_id%TYPE;
    v_loading          NUMBER;
    v_discount         NUMBER;
  BEGIN
    --Поиск тарифа из договора страхования по функции
    BEGIN
      SELECT prp.func_tariff_id
        INTO v_func_tarif_id
        FROM re_policy_reinsurance_program prp
       WHERE prp.policy_id = par_policy_id
         AND prp.p_cover_id = par_cover_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_func_tarif_id := NULL;
        --Поиск тарифа из договора перестрахования
        BEGIN
          SELECT rlc.t_prod_coef_type_id
            INTO v_func_tarif_id
            FROM re_line_contract   rlc
                ,re_cond_filter_obl fo
           WHERE fo.re_cond_filter_obl_id = rlc.re_cond_filter_obl_id
             AND fo.re_contract_ver_id = par_re_version_id
             AND rlc.fund_id = par_fund_id
             AND fo.product_id = par_product_id
             AND fo.product_line_id = par_prod_line_id;
        EXCEPTION
          WHEN no_data_found THEN
            --Если функция не указана, то возвращаем 0
            -- return 0;
            --Собираем строку сообщения об ошибке
            v_message := 'Не настроен тариф по программе: ' || chr(10);
          
            SELECT v_message || f.brief || chr(10)
              INTO v_message
              FROM fund f
             WHERE f.fund_id = par_fund_id;
          
            SELECT v_message || pr.description || chr(10)
              INTO v_message
              FROM t_product pr
             WHERE pr.product_id = par_product_id;
          
            SELECT v_message || pl.description || chr(10) || 'Расчет бордеро невозможен!'
              INTO v_message
              FROM t_product_line pl
             WHERE pl.id = par_prod_line_id;
          
            raise_application_error(-20000, v_message);
        END;
    END;
  
    -- ** О23 Возможна ситуация когда запись в таблице re_line_contract есть, но значение в поле    
    -- ** О23 t_prod_coef_type_id в ней пустое, тогда исключительной ситуации не возникает
    -- ** О23 Далее идет анализ этой ситуации
  
    IF v_func_tarif_id IS NULL
    THEN
      v_message := 'Не настроен тариф по программе: ' || chr(10);
    
      SELECT v_message || f.brief || chr(10) INTO v_message FROM fund f WHERE f.fund_id = par_fund_id;
    
      SELECT v_message || pr.description || chr(10)
        INTO v_message
        FROM t_product pr
       WHERE pr.product_id = par_product_id;
    
      SELECT v_message || pl.description || chr(10) || 'Расчет бордеро невозможен!'
        INTO v_message
        FROM t_product_line pl
       WHERE pl.id = par_prod_line_id;
    
      raise_application_error(-20000, v_message);
    END IF;
    -- ** О23 Конец фрагмента
  
    IF v_func_tarif_id IS NOT NULL
    THEN
      --Если найдена функция тарифа, то определяем BRIEF и по нему определяем тип функции
      SELECT t.brief
        INTO v_func_brief
        FROM t_prod_coef_type t
       WHERE t.t_prod_coef_type_id = v_func_tarif_id;
    
      IF v_func_brief LIKE 'RE_TARIFF_CLASS%'
      THEN
        --Функция по классу
        --Первый параметр - рабочая группа
        BEGIN
          SELECT CASE
                   WHEN a.work_group_id IN (5, 6) THEN
                    1
                   ELSE
                    nvl(a.work_group_id, 1)
                 END
            INTO v_work_group_id
            FROM as_assured a
          --,P_COVER    pc2
           WHERE /*pc2.as_asset_id = */
           a.as_assured_id
          /*AND pc2.as_asset_id*/
           = par_asset_id /*
                                                   AND pc2.P_COVER_ID = par_cover_id*/
          ;
          --* Отладка
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SELECT 'Отладка. par_asset_id = ' || TO_CHAR(par_asset_id) || ' par_cover_id = ' ||
                   TO_CHAR(TO_CHAR(par_cover_id))
              INTO v_message
              FROM dual;
            raise_application_error(-20000, v_message);
        END;
        --* Конец Отладка
        --Запуск функции
        BEGIN
          SELECT prc.val
            INTO res
            FROM t_prod_coef prc
           WHERE prc.t_prod_coef_type_id = v_func_tarif_id
             AND prc.criteria_1 = v_work_group_id
             AND prc.criteria_3 = CASE
                   WHEN par_insured_age < 18 THEN
                    1
                   ELSE
                    0
                 END; --1 - ребенок, 0 - взрослый
        EXCEPTION
          WHEN no_data_found THEN
            /*res:=0;*/
            raise_application_error(-20001, 'Не найдено значение тарифа');
        END;
      ELSIF v_func_brief LIKE 'RE_TARIFF_AGE%'
      THEN
        --Функция по возрасту и полу
        --Запуск функции
        BEGIN
          SELECT prc.val
            INTO res
            FROM t_prod_coef prc
           WHERE prc.t_prod_coef_type_id = v_func_tarif_id
             AND prc.criteria_1 = par_insured_age --Возраст
             AND prc.criteria_3 = par_gender; --Пол 1-мужчина, 0-женщина
        EXCEPTION
          WHEN no_data_found THEN
            /*res:=0;*/
            raise_application_error(-20001, 'Не найдено значение тарифа');
        END;
      ELSIF v_func_brief LIKE 'RE_TARIFF_STAVKA%'
      THEN
        --Функция по возрасту
        --Запуск функции
        BEGIN
          SELECT prc.val
            INTO res
            FROM t_prod_coef prc
           WHERE prc.t_prod_coef_type_id = v_func_tarif_id
             AND prc.criteria_3 = par_insured_age; --Возраст
        EXCEPTION
          WHEN no_data_found THEN
            /*res:=0;*/
            raise_application_error(-20001, 'Не найдено значение тарифа');
        END;
      ELSIF v_func_brief LIKE 'RE_TARIFF_INSSUM%'
      THEN
        --Функция по страховой сумме
        --Запуск функции
        BEGIN
          SELECT val
            INTO res
            FROM (SELECT prc.val
                    FROM t_prod_coef prc
                   WHERE prc.t_prod_coef_type_id = v_func_tarif_id
                     AND prc.criteria_2 >= par_ins_amount -- Страховая сумма
                   ORDER BY prc.criteria_2)
           WHERE rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            /*res:=0;*/
            raise_application_error(-20001, 'Не найдено значение тарифа');
        END;
        -- ** О23 Может быть настроена функция не стандартного типа
      ELSE
        raise_application_error(-20001
                               ,'Сокращение функции тарифа не соответствует стандартным типам RE_TARIFF_CLASS, RE_TARIFF_AGE, RE_TARIFF_STAVKA,RE_TARIFF_INSSUM');
        -- ** О23 Конец фрагмента
      END IF; --Разбор функций закончен
    END IF; --Функция найдена
  
    -- Получение функции нагрузки к тарифам
    SELECT cv.flg_prof_loading
          ,cv.func_loading_id
      INTO v_flg_prof_loading
          ,v_func_loading_id
      FROM re_contract_version cv
     WHERE cv.re_contract_version_id = par_re_version_id;
  
    IF v_flg_prof_loading = 1
       AND v_func_loading_id IS NOT NULL
       AND par_work_group_id IS NOT NULL
    THEN
      -- Получаем результат функции
      BEGIN
        SELECT prc.val
          INTO v_loading
          FROM t_prod_coef prc
         WHERE prc.t_prod_coef_type_id = v_func_loading_id
           AND prc.criteria_1 = par_work_group_id; -- Группа профессий
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_loading := 1;
      END;
    ELSE
      v_loading := 1;
    END IF;
  
    -- Получаем значение скидки к тарифам из версии договора страхования
    BEGIN
      SELECT nvl(aar.re_discount_proc / 100, 0)
        INTO v_discount
        FROM as_assured_re aar
       WHERE aar.p_policy_id = par_policy_id
         AND aar.re_contract_version_id = par_re_version_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_discount := 0;
    END;
  
    RETURN(res / 1000) * v_loading *(1 - v_discount);
  
  END get_tariff;

  PROCEDURE calc_claim /*_new*/
  (par_bordero_package_id IN NUMBER) IS
    v_re_version_id       re_contract_version.re_contract_version_id%TYPE;
    v_re_contract_version re_contract_version%ROWTYPE;
    v_bordero_line        re_bordero_line%ROWTYPE;
    v_ins_group_brief     VARCHAR2(100);
    v_pay_date            DATE;
    v_rate                NUMBER;
    v_reins_sum           NUMBER;
  
    v_start_bordero        DATE;
    v_end_bordero          DATE;
    v_re_main_contract_id  NUMBER;
    v_bordero_line_id      NUMBER;
    v_cancel_date          DATE;
    v_status_brief         doc_status_ref.name%TYPE;
    v_claim_type           NUMBER;
    v_bordero_id           NUMBER;
    v_re_claim_id          NUMBER;
    v_error_message        VARCHAR2(250);
    v_is_inclusion_package re_bordero_package.is_inclusion_package%TYPE;
  
    PROCEDURE insert_common_data
    (
      par_cover_id          re_cover.p_cover_id%TYPE
     ,par_start_date        re_cover.start_date%TYPE
     ,par_end_date          re_cover.end_date%TYPE
     ,par_pol_decline_date  re_cover.cancel_date%TYPE
     ,par_period_reins_prem re_cover.brutto_premium%TYPE
     ,par_re_comision       re_cover.commission%TYPE
      
     ,par_c_claim_header_id   re_claim_header.c_claim_header_id%TYPE
     ,par_claim_id            re_claim.c_claim_id%TYPE
     ,par_reclaim_header_num  document.num%TYPE
     ,par_prod_line_option_id re_claim_header.t_prod_line_option_id%TYPE
     ,par_re_m_contract_id    re_claim_header.re_m_contract_id%TYPE
     ,par_event_date          re_claim_header.event_date%TYPE
     ,par_fund_id             re_claim_header.fund_id%TYPE
      
     ,par_re_bordero_line_id re_claim.re_bordero_line_id%TYPE
     ,par_seqno              re_claim.seqno%TYPE
     ,par_claim_status_date  re_claim.re_claim_status_date%TYPE
     ,par_reclaim_num        document.num%TYPE
     ,par_claim_status_id    re_claim.status_id%TYPE
     ,par_re_declare_sum     re_claim.declare_sum%TYPE
     ,par_declare_sum        re_claim.re_declare_sum%TYPE
     ,par_reinsurer_share    re_claim.re_payment_share%TYPE
     ,par_bordero_id         re_claim.re_bordero_id%TYPE
     ,par_reclaim_id         OUT NUMBER
    ) IS
      v_re_claim_header_id NUMBER;
      v_re_cover_id        NUMBER;
    BEGIN
      SELECT sq_re_cover.nextval INTO v_re_cover_id FROM dual;
    
      INSERT INTO re_cover
        (re_cover_id, p_cover_id, start_date, end_date, cancel_date, brutto_premium, commission)
      VALUES
        (v_re_cover_id
        ,par_cover_id
        ,par_start_date
        ,par_end_date
        ,par_pol_decline_date
        ,par_period_reins_prem
        ,par_re_comision);
    
      SELECT sq_re_claim_header.nextval INTO v_re_claim_header_id FROM dual;
    
      INSERT INTO ven_re_claim_header
        (re_claim_header_id
        ,c_claim_header_id
        ,num
        ,t_prod_line_option_id
        ,re_m_contract_id
        ,event_date
        ,fund_id
        ,re_cover_id)
      VALUES
        (v_re_claim_header_id
        ,par_c_claim_header_id
        ,par_reclaim_header_num
        ,par_prod_line_option_id
        ,par_re_m_contract_id
        ,par_event_date
        ,par_fund_id
        ,v_re_cover_id);
    
      SELECT sq_re_claim.nextval INTO par_reclaim_id FROM dual;
    
      INSERT INTO ven_re_claim
        (re_claim_id
        ,re_claim_header_id
        ,seqno
        ,re_claim_status_date
        ,num
        ,status_id
        ,declare_sum
        ,re_declare_sum
        ,re_payment_share
        ,re_bordero_id
        ,c_claim_id
        ,re_bordero_line_id)
      VALUES
        (par_reclaim_id
        ,v_re_claim_header_id
        ,par_seqno
        ,par_claim_status_date
        ,par_reclaim_num
        ,par_claim_status_id
        ,par_declare_sum
        ,par_re_declare_sum
        ,par_reinsurer_share
        ,par_bordero_id
        ,par_claim_id
        ,par_re_bordero_line_id);
    END insert_common_data;
  BEGIN
    --Определяем версию и период действия пакета бордеро
    BEGIN
      SELECT bp.re_contract_id
            ,bp.start_date
            ,bp.end_date
            ,bp.re_m_contract_id
            ,bp.is_inclusion_package
        INTO v_re_version_id
            ,v_start_bordero
            ,v_end_bordero
            ,v_re_main_contract_id
            ,v_is_inclusion_package
        FROM re_bordero_package bp
       WHERE bp.re_bordero_package_id = par_bordero_package_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найден пакет бордеро с id: ' ||
                                nvl(to_char(par_bordero_package_id), 'null'));
    END;
    /*
      Бордеро убытков и бордеро расторжений для пакета бордеро с установленным признаком
      "Пакет заключения" не формируются
    */
    IF v_is_inclusion_package = 0
    THEN
      -- Удаление бордеро убытков
      FOR vr_loss IN (SELECT b.re_bordero_id
                        FROM re_bordero      b
                            ,re_bordero_type t
                       WHERE b.re_bordero_package_id = par_bordero_package_id
                         AND b.re_bordero_type_id = t.re_bordero_type_id
                         AND t.brief IN ('БОРДЕРО_ОПЛ_УБЫТКОВ'
                                        ,'БОРДЕРО_ЗАЯВ_УБЫТКОВ'))
      LOOP
        pkg_re_bordero.delete_bordero_loss(vr_loss.re_bordero_id);
      END LOOP;
    
      --Берем параметры версии
      SELECT *
        INTO v_re_contract_version
        FROM re_contract_version cv
       WHERE cv.re_contract_version_id = v_re_version_id;
    
      clear_claim_log(par_bordero_package_id => par_bordero_package_id);
    
      -- Цикл по убыткам
      FOR vr_main IN (SELECT --distinct
                       ch.num
                      ,ch.c_claim_header_id
                      ,ch.declare_date
                      ,ch.active_claim_id
                      ,ce.date_company
                      ,ce.event_date
                      ,f.brief AS claim_fund_brief
                       --                          ,dmgf.brief                  as damage_fund_brief
                      , /*c.declare_sum*/nvl((SELECT SUM(cd.declare_sum)
                             FROM c_damage cd
                            WHERE cd.c_claim_id = c.c_claim_id
                              AND cd.status_hist_id != 3)
                          , /* актуальная версия */(SELECT SUM(cd1.declare_sum)
                              FROM c_claim_header ch1
                                  ,c_claim        c1
                                  ,c_damage       cd1
                             WHERE cd1.c_claim_id =
                                   c1.c_claim_id
                               AND cd1.status_hist_id != 3
                               AND c1.seqno = 1
                               AND c1.c_claim_header_id =
                                   ch1.c_claim_header_id
                               AND ch1.c_claim_header_id =
                                   c.c_claim_header_id) /* первая версия */) AS declare_sum
                      ,c.c_claim_id
                      ,ch.p_cover_id
                      ,pc.start_date
                      ,pc.end_date
                       --                          ,dmg.c_damage_id
                       --                          ,dmg.t_damage_code_id
                      ,pc.t_prod_line_option_id
                      ,c.seqno
                      ,c.num                    AS c_num
                      ,c.claim_status_date
                      ,c.claim_status_id
                      ,f.fund_id
                      --                          ,dmg.declare_sum             as damage_declare_sum
                        FROM ven_c_claim_header ch
                            ,ven_c_claim        c
                            ,c_event            ce
                            ,fund               f
                             --                          ,c_damage dmg
                             --* не убрал damage         ,fund dmgf
                            ,p_cover pc
                             /** БУ16 **/
                            ,re_bordero_package p
                            ,re_bordero         b
                            ,re_bordero_line    bl
                            ,p_cover            pcbl
                            ,as_asset           asabl
                            ,as_asset           asac
                      
                      /** БУ16 **/
                      
                       WHERE ch.active_claim_id = c.c_claim_id
                         AND ch.c_event_id = ce.c_event_id
                            --                       and c.c_claim_id       = dmg.c_claim_id
                            --                       and dmg.damage_fund_id = dmgf.fund_id
                         AND ch.fund_id = f.fund_id
                         AND ch.p_cover_id = pc.p_cover_id
                         AND ce.date_company <= v_re_contract_version.end_date
                         AND ce.event_date BETWEEN v_re_contract_version.start_date AND
                             v_re_contract_version.end_date
                            /** БУ16 **/
                         AND bl.re_bordero_id = b.re_bordero_id
                         AND b.re_bordero_package_id = p.re_bordero_package_id
                         AND p.re_contract_id = v_re_version_id
                         AND bl.cover_id = pcbl.p_cover_id
                            
                            -- Соответствие строке бордеро премий
                         AND pc.t_prod_line_option_id = pcbl.t_prod_line_option_id
                         AND asac.as_asset_id = pc.as_asset_id
                         AND asabl.as_asset_id = pcbl.as_asset_id
                         AND asac.p_asset_header_id = asabl.p_asset_header_id
                         AND ce.event_date BETWEEN bl.payment_start_date AND bl.payment_end_date
                      
                      /** БУ16
                                             and pc.p_cover_id in (select bl.cover_id
                                                                     from re_bordero_package p
                                                                         ,re_bordero b
                                                                         ,re_bordero_line bl
                                                                    where bl.re_bordero_id        = b.re_bordero_id
                                                                      and b.re_bordero_package_id = p.re_bordero_package_id
                                                                      and p.re_contract_id        = v_re_version_id)
                      БУ16 **/
                      
                      --* тестовые примеры
                      --*                       and c.c_claim_id = 41649876
                      --*                          and c.c_claim_id = 39677291
                      --*                             and ch.c_claim_header_id = 27707266 -- Убыток заявлен в 4 кв 2010, отказан во 2 кв. 2012
                      --*
                      )
      LOOP
        SAVEPOINT before_calc_claim_loop;
        BEGIN
          --
          v_bordero_line_id := get_bordero_line_id(par_re_version_id => v_re_contract_version.re_contract_version_id
                                                  ,par_cover_id      => vr_main.p_cover_id
                                                  ,par_event_date    => vr_main.event_date);
          --
          IF v_bordero_line_id IS NOT NULL
          THEN
            SELECT *
              INTO v_bordero_line
              FROM re_bordero_line bl
             WHERE bl.re_bordero_line_id = v_bordero_line_id;
          
            v_pay_date := nvl(pkg_renlife_utils.ret_sod_claim(vr_main.c_claim_header_id), '01.01.1900');
          
            SELECT MAX(ds.start_date)
              INTO v_cancel_date
              FROM ven_c_claim clm2
                  ,doc_status  ds
             WHERE clm2.c_claim_header_id = vr_main.c_claim_header_id
               AND ds.document_id = clm2.c_claim_id
               AND ds.doc_status_ref_id = 130; -- Отказано в выплате
            --           and ds.doc_status_ref_id   = 128; -- Принято решение по делу
          
            v_status_brief := nvl(doc.get_last_doc_status_brief(vr_main.active_claim_id), '-');
          
            v_claim_type := check_claim(par_claim_id           => vr_main.c_claim_id
                                       ,par_cover_id           => vr_main.p_cover_id
                                       ,par_date_company       => vr_main.date_company
                                       ,par_bordero_start_date => v_start_bordero
                                       ,par_bordero_end_date   => v_end_bordero
                                       ,par_pay_date           => v_pay_date
                                       ,par_event_date         => vr_main.event_date
                                       ,par_date_cancel        => v_cancel_date
                                       ,par_status_brief       => v_status_brief);
          
            IF v_claim_type = 1
            THEN
              --БЗУ
              --* В БЗУ величины v_rate считаются, но ни куда не сохраняются
              --* По идее v_rate вычислять и сохранять тут не надо
              --* а v_reins_sum можно вычислять в валюте ответственности и сохранять в
              --* поле ven_re_claim.RE_DECALRED_SUM, при этом в поле ven_re_claim.DECALRED_SUM (надо ввести) можно еще писать
              --* задекларированную сумму по версии дела vr_main.declare_sum, которая сейчас пишется
              --* в  ven_re_claim.RE_DECALRED_SUM
              v_reins_sum := vr_main.declare_sum * v_bordero_line.reinsurer_share;
              --*          v_rate := nvl(acc.get_rate_by_brief('ЦБ', vr_main.claim_fund_brief, v_end_bordero),1);
              --*          v_reins_sum := vr_main.declare_sum * v_bordero_line.reinsurer_share * v_rate;
            
              SELECT b.re_bordero_id
                INTO v_bordero_id
                FROM re_bordero      b
                    ,re_bordero_type t
               WHERE b.re_bordero_type_id = t.re_bordero_type_id
                 AND t.short_name = 'БЗУ'
                 AND b.re_bordero_package_id = par_bordero_package_id
                 AND b.fund_id = vr_main.fund_id;
            
              -------------------------------------
              --сохраняем
            
              insert_common_data(par_cover_id          => vr_main.p_cover_id
                                ,par_start_date        => vr_main.start_date
                                ,par_end_date          => vr_main.end_date
                                ,par_pol_decline_date  => v_bordero_line.policy_decline_date
                                ,par_period_reins_prem => nvl(v_bordero_line.period_reinsurer_premium
                                                             ,0)
                                ,par_re_comision       => v_bordero_line.re_comision
                                 
                                ,par_c_claim_header_id   => vr_main.c_claim_header_id
                                ,par_claim_id            => vr_main.c_claim_id
                                ,par_reclaim_header_num  => vr_main.num
                                ,par_prod_line_option_id => vr_main.t_prod_line_option_id
                                ,par_re_m_contract_id    => v_re_contract_version.re_main_contract_id
                                ,par_event_date          => vr_main.event_date
                                ,par_fund_id             => vr_main.fund_id
                                 
                                ,par_re_bordero_line_id => v_bordero_line_id
                                ,par_seqno              => vr_main.seqno
                                ,par_claim_status_date  => vr_main.claim_status_date
                                ,par_reclaim_num        => vr_main.c_num
                                ,par_claim_status_id    => vr_main.claim_status_id
                                ,par_declare_sum        => vr_main.declare_sum
                                ,par_re_declare_sum     => v_reins_sum
                                ,par_reinsurer_share    => v_bordero_line.reinsurer_share
                                ,par_bordero_id         => v_bordero_id
                                ,par_reclaim_id         => v_re_claim_id);
              --------------------------------------------
            
            ELSIF v_claim_type = 2
            THEN
              --БОУ
              --v_rate := nvl(acc.get_rate_by_brief('ЦБ', vr_main.claim_fund_brief, v_pay_date),1);
              v_reins_sum := vr_main.declare_sum * v_bordero_line.reinsurer_share;
              SELECT b.re_bordero_id
                INTO v_bordero_id
                FROM re_bordero      b
                    ,re_bordero_type t
               WHERE b.re_bordero_type_id = t.re_bordero_type_id
                 AND t.short_name = 'БОУ'
                 AND b.re_bordero_package_id = par_bordero_package_id
                 AND b.fund_id = vr_main.fund_id;
            
              SELECT ig.brief
                INTO v_ins_group_brief
                FROM p_cover            pc
                    ,t_prod_line_option plo
                    ,t_product_line     pl
                    ,t_lob_line         ll
                    ,t_insurance_group  ig
               WHERE ig.t_insurance_group_id = ll.insurance_group_id
                 AND ll.t_lob_line_id = pl.t_lob_line_id
                 AND pl.id = plo.product_line_id
                 AND plo.id = pc.t_prod_line_option_id
                 AND pc.p_cover_id = vr_main.p_cover_id;
            
              -----------------------------------------------
              --сохраняем
              insert_common_data(par_cover_id          => vr_main.p_cover_id
                                ,par_start_date        => vr_main.start_date
                                ,par_end_date          => vr_main.end_date
                                ,par_pol_decline_date  => v_bordero_line.policy_decline_date
                                ,par_period_reins_prem => nvl(v_bordero_line.period_reinsurer_premium
                                                             ,0)
                                ,par_re_comision       => v_bordero_line.re_comision
                                 
                                ,par_c_claim_header_id   => vr_main.c_claim_header_id
                                ,par_claim_id            => vr_main.c_claim_id
                                ,par_reclaim_header_num  => vr_main.num
                                ,par_prod_line_option_id => vr_main.t_prod_line_option_id
                                ,par_re_m_contract_id    => v_re_contract_version.re_main_contract_id
                                ,par_event_date          => vr_main.event_date
                                ,par_fund_id             => vr_main.fund_id
                                 
                                ,par_re_bordero_line_id => v_bordero_line_id
                                ,par_seqno              => vr_main.seqno
                                ,par_claim_status_date  => vr_main.claim_status_date
                                ,par_reclaim_num        => vr_main.c_num
                                ,par_claim_status_id    => vr_main.claim_status_id
                                ,par_declare_sum        => vr_main.declare_sum
                                ,par_re_declare_sum     => v_reins_sum
                                ,par_reinsurer_share    => v_bordero_line.reinsurer_share
                                ,par_bordero_id         => v_bordero_id
                                ,par_reclaim_id         => v_re_claim_id);
              ---------------------------------
            
              --Суммы выплаченного страхового обеспечения
              IF v_ins_group_brief != 'NonInsuranceClaims'
              THEN
                FOR vr_pays IN (SELECT dso.set_off_amount AS pay_sum
                                      ,dso.set_off_rate
                                      ,dso.set_off_date
                                --into p_pay_sum
                                  FROM doc_doc        dd
                                      ,doc_set_off    dso
                                      ,document       d_p
                                      ,document       d_ch
                                      ,doc_templ      dt_p
                                      ,doc_templ      dt_ch
                                      ,ven_ac_payment ac
                                      ,doc_status_ref dsr
                                 WHERE dd.parent_id = vr_main.c_claim_id
                                   AND dso.parent_doc_id = d_p.document_id
                                   AND dso.child_doc_id = d_ch.document_id
                                   AND d_p.doc_templ_id = dt_p.doc_templ_id
                                   AND d_ch.doc_templ_id = dt_ch.doc_templ_id
                                   AND dd.child_id = dso.parent_doc_id
                                   AND dt_p.brief = 'PAYORDER'
                                   AND dt_ch.brief = 'ППИ'
                                   AND ac.payment_id = d_p.document_id
                                   AND ac.doc_status_ref_id = dsr.doc_status_ref_id
                                   AND dsr.brief = 'PAID'
                                   AND dso.cancel_date IS NULL
                                   AND dso.set_off_date IS NOT NULL)
                LOOP
                  --* Здесь сейчас считается сумма в рублях и сохраняется вместе с курсом
                  --*            v_reins_sum := vr_pays.pay_sum * v_bordero_line.reinsurer_share * vr_pays.set_off_rate;
                  --* По идее надо сохранять сумму в валюте отвественности и курс
                  v_reins_sum := vr_pays.pay_sum * v_bordero_line.reinsurer_share;
                  INSERT INTO ven_rel_reclaim_bordero
                    (pay_date, rate, re_claim_id, re_payment_sum, payment_sum)
                  VALUES
                    (vr_pays.set_off_date
                    ,vr_pays.set_off_rate
                    ,v_re_claim_id
                    ,v_reins_sum
                    ,vr_pays.pay_sum);
                END LOOP;
              END IF;
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO before_calc_claim_loop;
            v_error_message := substr(SQLERRM, 1, 250);
            calc_claim_log(par_bordero_package_id => par_bordero_package_id
                          ,par_claim_id           => vr_main.c_claim_id
                          ,par_error_message      => v_error_message
                          ,par_backtrace          => dbms_utility.format_error_backtrace);
        END;
      END LOOP;
    END IF;
  END calc_claim /*_new*/
  ;

  PROCEDURE calc_claim_old(par_bordero_package_id IN NUMBER) AS
    v_re_version_id       NUMBER;
    d_start_bordero       DATE;
    d_end_bordero         DATE;
    v_re_main_contract_id NUMBER;
    v_re_contract_version re_contract_version%ROWTYPE;
    p_claim_type          NUMBER;
    p_pay_date            DATE;
    p_cancel_date         DATE;
    p_status_brief        VARCHAR2(100);
    p_rate                NUMBER;
    p_reins_sum           NUMBER;
    p_pay_sum             NUMBER;
    p_ins_group_brief     VARCHAR2(100);
    p_bordero_line_id     NUMBER;
    p_bordero_line        re_bordero_line%ROWTYPE;
    --  p_reins_perc number;
    p_re_claim_header_id NUMBER;
    p_re_claim_id        NUMBER;
    p_re_damage_id       NUMBER;
    p_bordero_id         NUMBER;
    p_re_cover_id        NUMBER;
  BEGIN
  
    FOR d IN (SELECT b.re_bordero_id
                FROM re_bordero b
               WHERE b.re_bordero_package_id = par_bordero_package_id)
    LOOP
      Pkg_Re_Bordero.delete_bordero_loss(d.re_bordero_id);
    END LOOP;
  
    --Определяем версию и период действия пакета бордеро
    SELECT bp.re_contract_id
          ,bp.start_date
          ,bp.end_date
          ,bp.re_m_contract_id
      INTO v_re_version_id
          ,d_start_bordero
          ,d_end_bordero
          ,v_re_main_contract_id
      FROM re_bordero_package bp
     WHERE bp.re_bordero_package_id = par_bordero_package_id;
  
    --Берем параметры версии
    SELECT *
      INTO v_re_contract_version
      FROM re_contract_version cv
     WHERE cv.re_contract_version_id = v_re_version_id;
  
    FOR cur IN (SELECT DISTINCT ch.num
                               ,ch.c_claim_header_id
                               ,ch.declare_date
                               ,ch.active_claim_id
                               ,ce.date_company
                               ,ce.event_date
                               ,f.brief                  AS claim_fund_brief
                               ,dmgf.brief               AS damage_fund_brief
                               ,c.declare_sum
                               ,c.c_claim_id
                               ,ch.p_cover_id
                               ,pc.start_date
                               ,pc.end_date
                               ,dmg.c_damage_id
                               ,dmg.t_damage_code_id
                               ,pc.t_prod_line_option_id
                               ,c.seqno
                               ,c.num                    AS c_num
                               ,c.claim_status_date
                               ,c.claim_status_id
                               ,f.fund_id
                               ,dmg.declare_sum          AS damage_declare_sum
                  FROM ven_c_claim_header ch
                      ,ven_c_claim        c
                      ,c_event            ce
                      ,fund               f
                      ,c_damage           dmg
                      ,fund               dmgf
                      ,p_cover            pc
                 WHERE ch.active_claim_id = c.c_claim_id
                   AND ch.c_event_id = ce.c_event_id
                   AND dmg.c_claim_id = c.c_claim_id
                   AND dmgf.fund_id = dmg.damage_fund_id
                   AND f.fund_id = ch.fund_id
                   AND pc.p_cover_id = ch.p_cover_id
                   AND ce.date_company <= v_re_contract_version.end_date
                   AND ce.event_date BETWEEN v_re_contract_version.start_date AND
                       v_re_contract_version.end_date
                   AND pc.p_cover_id IN (SELECT bl.cover_id
                                           FROM re_bordero_package p
                                               ,re_bordero         b
                                               ,re_bordero_line    bl
                                          WHERE bl.re_bordero_id = b.re_bordero_id
                                            AND b.re_bordero_package_id = p.re_bordero_package_id
                                            AND p.re_contract_id = v_re_version_id))
    LOOP
    
      p_bordero_line_id := get_bordero_line_id(v_re_contract_version.re_contract_version_id
                                              ,cur.p_cover_id
                                              ,cur.event_date);
      IF p_bordero_line_id IS NOT NULL
      THEN
        SELECT *
          INTO p_bordero_line
          FROM re_bordero_line bl
         WHERE bl.re_bordero_line_id = p_bordero_line_id;
      
        p_pay_date := nvl(pkg_renlife_utils.ret_sod_claim(cur.c_claim_header_id), '01.01.1900');
      
        SELECT MAX(ds.start_date)
          INTO p_cancel_date
          FROM ven_c_claim clm2
              ,doc_status  ds
         WHERE clm2.c_claim_header_id = cur.c_claim_header_id
           AND ds.document_id = clm2.c_claim_id
           AND ds.doc_status_ref_id IN (128);
      
        p_status_brief := nvl(doc.get_last_doc_status_brief(cur.active_claim_id), '-');
      
        p_claim_type := check_claim(cur.c_claim_id
                                   ,cur.p_cover_id
                                   ,cur.date_company
                                   ,d_start_bordero
                                   ,d_end_bordero
                                   ,p_pay_date
                                   ,cur.event_date
                                   ,p_cancel_date
                                   ,p_status_brief);
      
        IF p_claim_type = 1
        THEN
          --БЗУ
          p_rate      := nvl(acc.Get_Rate_By_Brief('ЦБ', cur.claim_fund_brief, d_end_bordero), 1);
          p_reins_sum := cur.damage_declare_sum * p_bordero_line.reinsurer_share * p_rate;
        
          SELECT b.re_bordero_id
            INTO p_bordero_id
            FROM re_bordero      b
                ,re_bordero_type t
           WHERE b.re_bordero_type_id = t.re_bordero_type_id
             AND t.short_name = 'БЗУ'
             AND b.re_bordero_package_id = par_bordero_package_id
             AND b.fund_id = cur.fund_id;
        
        ELSIF p_claim_type = 2
        THEN
          --БОУ
          p_rate := nvl(acc.Get_Cross_Rate_By_Brief(1
                                                   ,cur.damage_fund_brief
                                                   ,cur.claim_fund_brief
                                                   ,p_pay_date)
                       ,1);
        
          SELECT b.re_bordero_id
            INTO p_bordero_id
            FROM re_bordero      b
                ,re_bordero_type t
           WHERE b.re_bordero_type_id = t.re_bordero_type_id
             AND t.short_name = 'БОУ'
             AND b.re_bordero_package_id = par_bordero_package_id
             AND b.fund_id = cur.fund_id;
        
          SELECT ig.brief
            INTO p_ins_group_brief
            FROM p_cover            pc
                ,t_prod_line_option plo
                ,t_product_line     pl
                ,t_lob_line         ll
                ,t_insurance_group  ig
           WHERE ig.t_insurance_group_id = ll.insurance_group_id
             AND ll.t_lob_line_id = pl.t_lob_line_id
             AND pl.id = plo.product_line_id
             AND plo.id = pc.t_prod_line_option_id
             AND pc.p_cover_id = cur.p_cover_id;
        
          --Суммы выплаченного страхового обеспечения
          SELECT SUM(CASE
                       WHEN dso.set_off_date IS NOT NULL THEN
                        ac.rev_amount
                       ELSE
                        0
                     END)
            INTO p_pay_sum
            FROM doc_doc        dd
                ,doc_set_off    dso
                ,document       d_p
                ,document       d_ch
                ,doc_templ      dt_p
                ,doc_templ      dt_ch
                ,ven_ac_payment ac
                ,doc_status_ref dsr
           WHERE dd.parent_id = cur.c_claim_id
             AND p_ins_group_brief != 'NonInsuranceClaims'
             AND dso.parent_doc_id = d_p.document_id
             AND dso.child_doc_id = d_ch.document_id
             AND d_p.doc_templ_id = dt_p.doc_templ_id
             AND d_ch.doc_templ_id = dt_ch.doc_templ_id
             AND ((dd.child_id = dso.child_doc_id AND dt_ch.brief = 'PAYORDER_SETOFF' AND
                 dt_p.brief = 'PAYMENT' AND ac.payment_id = d_ch.document_id) OR
                 (dd.child_id = dso.parent_doc_id AND dt_p.brief = 'PAYORDER' AND dt_ch.brief = 'ППИ' AND
                 ac.payment_id = d_p.document_id))
             AND ac.doc_status_ref_id = dsr.doc_status_ref_id
             AND dsr.brief = 'PAID'
             AND dso.cancel_date IS NULL;
        
          p_reins_sum := p_pay_sum * p_bordero_line.reinsurer_share * p_rate;
        END IF;
      
      END IF; --p_bordero_line_id
    
      --* Вставка кода для отладки
      IF p_claim_type = 1
         OR p_claim_type = 2
      THEN
        --*
        --сохраняем
        SELECT sq_re_cover.nextval INTO p_re_cover_id FROM dual;
      
        INSERT INTO re_cover
          (re_cover_id, p_cover_id, start_date, end_date, cancel_date, brutto_premium, commission)
        VALUES
          (p_re_cover_id
          ,cur.p_cover_id
          ,cur.start_date
          ,cur.end_date
          ,p_bordero_line.policy_decline_date
          ,nvl(p_bordero_line.period_reinsurer_premium, 0)
          ,p_bordero_line.re_comision);
      
        SELECT sq_re_claim_header.NEXTVAL INTO p_re_claim_header_id FROM dual;
        INSERT INTO ven_re_claim_header
          (re_claim_header_id
          ,c_claim_header_id
          ,num
          ,doc_templ_id
          ,t_prod_line_option_id
          ,re_m_contract_id
          ,event_date)
          SELECT p_re_claim_header_id
                , -- ид
                 cur.c_claim_header_id
                ,cur.num
                ,(SELECT dc.doc_templ_id
                   FROM doc_templ dc
                  WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM_HEADER'))
                ,cur.t_prod_line_option_id
                ,v_re_contract_version.re_main_contract_id
                ,cur.event_date
            FROM dual;
      
        SELECT sq_re_claim.NEXTVAL INTO p_re_claim_id FROM dual;
      
        INSERT INTO ven_re_claim
          (re_claim_id, re_claim_header_id, seqno, re_claim_status_date, num, doc_templ_id, status_id)
          SELECT p_re_claim_id
                ,p_re_claim_header_id
                ,cur.seqno
                ,cur.claim_status_date
                ,cur.c_num
                ,(SELECT dc.doc_templ_id
                   FROM doc_templ dc
                  WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM'))
                ,cur.claim_status_id
            FROM dual;
      
        SELECT sq_re_damage.NEXTVAL INTO p_re_damage_id FROM dual;
      
        INSERT INTO re_damage
          (re_damage_id
          ,re_cover_id
          ,damage_id
          ,re_claim_id
          ,t_damage_code_id
          ,re_bordero_line_id
          ,ins_payment_sum
          ,rate)
          SELECT p_re_damage_id
                ,p_re_cover_id
                ,cur.c_damage_id
                ,p_re_claim_id
                ,cur.t_damage_code_id
                ,p_bordero_line_id
                ,p_pay_sum
                ,p_rate
            FROM dual;
      
        INSERT INTO rel_redamage_bordero
          (rel_redamage_bordero_id, re_damage_id, re_bordero_id, re_payment_sum, re_payment_share)
          SELECT sq_rel_redamage_bordero.NEXTVAL
                ,p_re_damage_id
                ,p_bordero_id
                ,ROUND(NVL(p_reins_sum, 0), 2)
                ,p_bordero_line.reinsurer_share
            FROM dual;
        --* Вставка кода для отладки
      END IF;
      --*
    END LOOP;
  
  END calc_claim_old;

  FUNCTION get_bordero_line_id
  (
    par_re_version_id IN NUMBER
   ,par_cover_id      IN NUMBER
   ,par_event_date    IN DATE
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --Ищем строку бордеро в оплаченном периоде
    /*    select max(l.re_bordero_line_id) into res
        from re_bordero_package p, re_bordero b, re_bordero_line l
        where l.re_bordero_id=b.re_bordero_id
        and b.re_bordero_package_id=p.re_bordero_package_id
        and p.re_contract_id = par_re_version_id
        and l.cover_id = par_cover_id
        and par_event_date between l.payment_start_date and l.payment_end_date
        and l.period_reinsurer_premium > 0;
    */
  
    SELECT MAX(l.re_bordero_line_id)
      INTO res
      FROM re_bordero_package p
          ,re_bordero         b
          ,re_bordero_line    l
          ,p_cover            pc1
          ,p_cover            pc2
          ,
           /** БУ16
                    as_assured asa1,
                    as_assured asa2,
                    contact c1,
                    contact c2
           БУ16 **/as_asset asa1
          ,as_asset asa2
    /** БУ16 **/
     WHERE l.re_bordero_id = b.re_bordero_id
       AND b.re_bordero_package_id = p.re_bordero_package_id
       AND p.re_contract_id = par_re_version_id
          
       AND pc1.p_cover_id = par_cover_id
       AND pc2.p_cover_id = l.cover_id
       AND pc1.t_prod_line_option_id = pc2.t_prod_line_option_id -- the same risk group
          
          /** БУ16
              and asa1.as_assured_id = pc1.as_asset_id
              and asa2.as_assured_id = pc2.as_asset_id
              and c1.contact_id = asa1.assured_contact_id
              and c2.contact_id = asa2.assured_contact_id
              and c1.contact_id = c2.contact_id -- the same assured contact id
          БУ16 **/
          
          /** БУ16 Condition was replaced by correspondence of asset header **/
       AND asa1.as_asset_id = pc1.as_asset_id
       AND asa2.as_asset_id = pc2.as_asset_id
       AND asa1.p_asset_header_id = asa2.p_asset_header_id
          /** БУ16 **/
       AND b.re_bordero_type_id IN (1, 2, 41) -- БПП, БД, БИ
       AND l.period_reinsurer_premium > 0 -- outcoming payment to reinsurer
       AND par_event_date BETWEEN l.payment_start_date AND l.payment_end_date;
  
    IF res IS NULL
    THEN
      --Если не строка найдена, то ищем в периоде действия договора перестрахования
      SELECT MAX(l.re_bordero_line_id)
        INTO res
        FROM re_contract_version v
            ,re_bordero_package  p
            ,re_bordero          b
            ,re_bordero_line     l
             --* Замечание БУ9_2
            ,p_cover    pc1
            ,p_cover    pc2
            ,as_assured asa1
            ,as_assured asa2
            ,contact    c1
            ,contact    c2
      --*
       WHERE l.re_bordero_id = b.re_bordero_id
         AND b.re_bordero_package_id = p.re_bordero_package_id
         AND v.re_contract_version_id = p.re_contract_id
         AND p.re_contract_id = par_re_version_id
            
            --* Замечание БУ9_2
            --*      and l.cover_id = par_cover_id
            
         AND pc1.p_cover_id = par_cover_id
         AND pc2.p_cover_id = l.cover_id
         AND pc1.t_prod_line_option_id = pc2.t_prod_line_option_id -- the same risk group
         AND asa1.as_assured_id = pc1.as_asset_id
         AND asa2.as_assured_id = pc2.as_asset_id
         AND c1.contact_id = asa1.assured_contact_id
         AND c2.contact_id = asa2.assured_contact_id
         AND c1.contact_id = c2.contact_id -- the same assured contact id
         AND b.re_bordero_type_id IN (1, 2, 41) -- БПП, БД, БИ
            --*
         AND par_event_date BETWEEN v.start_date AND v.end_date
         AND l.period_reinsurer_premium > 0;
    
      IF res IS NULL
      THEN
        --Если не строка найдена, то ищем в периоде действия покрытия
        SELECT MAX(l.re_bordero_line_id)
          INTO res
          FROM re_bordero_package p
              ,re_bordero         b
              ,re_bordero_line    l
              ,p_cover            pc
               --* Замечание БУ9_2
              ,p_cover    pc1
              ,p_cover    pc2
              ,as_assured asa1
              ,as_assured asa2
              ,contact    c1
              ,contact    c2
        --*
         WHERE l.re_bordero_id = b.re_bordero_id
              
           AND b.re_bordero_package_id = p.re_bordero_package_id
              
              --*        and pc.p_cover_id=l.cover_id
           AND pc.p_cover_id = par_cover_id -- по заданному покрытию
              
           AND p.re_contract_id = par_re_version_id
              --* Замечание БУ9_2
              --*      and l.cover_id = par_cover_id
              
           AND pc1.p_cover_id = par_cover_id
           AND pc2.p_cover_id = l.cover_id
           AND pc1.t_prod_line_option_id = pc2.t_prod_line_option_id -- the same risk group
           AND asa1.as_assured_id = pc1.as_asset_id
           AND asa2.as_assured_id = pc2.as_asset_id
           AND c1.contact_id = asa1.assured_contact_id
           AND c2.contact_id = asa2.assured_contact_id
           AND c1.contact_id = c2.contact_id -- the same assured contact id
           AND b.re_bordero_type_id IN (1, 2, 41) -- БПП, БД, БИ
              --*
           AND par_event_date BETWEEN pc.start_date AND pc.end_date
           AND l.period_reinsurer_premium > 0;
      END IF;
    END IF;
  
    RETURN res;
  
  END get_bordero_line_id;

  /*  Процедура расчета расторжений
  */

  PROCEDURE calc_decline(par_bordero_package_id IN NUMBER) AS
    с_re_bordero_type_id CONSTANT NUMBER := 5; /* Бордеро расторжений */
  
    v_re_version_id       NUMBER;
    d_start_bordero       DATE;
    d_end_bordero         DATE;
    v_re_main_contract_id NUMBER;
    v_re_contract_version re_contract_version%ROWTYPE;
    v_premium_type_id     NUMBER;
    n_RP                  NUMBER;
    p_re_cover_id         NUMBER;
    -- t_decline tbl_decline;
    p_re_claim_header_id   NUMBER;
    p_bordero_id           NUMBER;
    v_return_re_commission NUMBER;
    v_error_message        VARCHAR2(250);
    v_return_add_com       NUMBER;
    v_return_fixed_com     NUMBER;
    v_is_inclusion_package re_bordero_package.is_inclusion_package%TYPE;
  BEGIN
    --  t_decline:= tbl_decline();
  
    --Определяем версию и период действия пакета бордеро
    SELECT bp.re_contract_id
          ,bp.start_date
          ,bp.end_date
          ,bp.re_m_contract_id
          ,bp.is_inclusion_package
      INTO v_re_version_id
          ,d_start_bordero
          ,d_end_bordero
          ,v_re_main_contract_id
          ,v_is_inclusion_package
      FROM re_bordero_package bp
     WHERE bp.re_bordero_package_id = par_bordero_package_id;
  
    /*
      Бордеро убытков и бордеро расторжений для пакета бордеро с установленным признаком
      "Пакет заключения" не формируются
    */
    IF v_is_inclusion_package = 0
    THEN
    
      --Удаляем все бордеро расторжений в пакете бордеро
      DELETE FROM re_cover r
       WHERE r.re_bordero_id IN
             (SELECT b.re_bordero_id
                FROM re_bordero      b
                    ,re_bordero_type t
               WHERE b.re_bordero_type_id = t.re_bordero_type_id
                 AND t.short_name = 'БР'
                 AND b.re_bordero_package_id = par_bordero_package_id);
    
      --Берем параметры версии
      SELECT *
        INTO v_re_contract_version
        FROM re_contract_version cv
       WHERE cv.re_contract_version_id = v_re_version_id;
    
      clear_decline_log(par_bordero_package_id => par_bordero_package_id);
      --Отбираем договора, имеющие последний статус Прекращен
      FOR cur IN (SELECT p.decline_date
                        ,p.first_pay_date
                        ,decode(pt.is_periodical, 0, 1, 0) AS is_not_periodical
                        ,a.as_asset_id
                        ,pc.start_date
                        ,pc.end_date
                        ,pc.p_cover_id
                        ,bp.start_date AS bordero_start_date
                        ,bp.end_date AS bordero_end_date
                        ,pl.product_line_type_id
                        ,tl.brief AS insurance_type
                        ,blc.start_date AS cover_start_date
                        ,blc.end_date AS cover_end_date
                        ,ph.policy_header_id
                        ,su.assured_contact_id
                        ,bl.*
                    FROM re_bordero         b
                        ,re_bordero_line    bl
                        ,t_prod_line_option plo
                        ,t_product_line     pl
                        ,p_cover            pc
                        ,as_asset           a
                        ,as_assured         su
                        ,p_policy           p
                        ,p_pol_header       ph
                        ,t_payment_terms    pt
                        ,re_bordero_package bp
                        ,re_bordero_type    bt
                        ,t_product_ver_lob  vl
                        ,t_lob              tl
                        ,p_cover            blc
                   WHERE -- Отбор соответствующей строки бордеро премий
                   bl.re_bordero_id = b.re_bordero_id
               AND bl.payment_end_date >= p.decline_date
               AND bl.product_line_id = plo.product_line_id
               AND bl.pol_header_id = ph.policy_header_id
               AND bt.re_bordero_type_id = b.re_bordero_type_id
               AND bt.short_name IN ('БПП', 'БД', 'БИ')
               AND bp.re_bordero_package_id = b.re_bordero_package_id
               AND bp.re_contract_id = v_re_version_id
                  --and b.re_bordero_package_id=par_bordero_package_id
                  -- Отбор согласованных данных по договору страхования
               AND pc.t_prod_line_option_id = plo.id
               AND a.as_asset_id = pc.as_asset_id
               AND p.policy_id = a.p_policy_id
               AND ph.policy_id = p.policy_id
               AND pt.id = p.payment_term_id
               AND plo.product_line_id = pl.id
               AND pl.product_ver_lob_id = vl.t_product_ver_lob_id
               AND vl.lob_id = tl.t_lob_id
               AND doc.get_doc_status_brief(p.policy_id) = 'QUIT'
               AND bl.cover_id = blc.p_cover_id
               AND a.as_asset_id = su.as_assured_id
                  -- Принадлежность даты расторжения интервалу необходима для уникальности отбора
                  -- расторжения в рамках одного отчетного интервала
                  -- такое условие отбора должно присутствовать в любом случае, чтобы формирование
                  -- строк бордеро расторжений не происходило повторно в нескольких интервалах
                  -- Можно использовать другое условие уникальности определения интервала бордеро,
                  -- например, по дате установки последнего статуса. Пока сделано по ТЗ так с предположением
                  -- того, что будем добирать по предыдущим интервалам.
               AND p.decline_date BETWEEN d_start_bordero AND d_end_bordero
                  --* Отладка на тестовых примерах
                  --*                 and ph.policy_header_id = 20638634 and pl.msfo_brief = 'WOP' -- БР одна строка 1 кв. 2011
                  --*                 and ph.policy_header_id = 18224031 and pl.msfo_brief = 'WOP' -- БР три строки 1 кв. 2011 (надо заремливать статус ЭПГ Annulated в курсоре pay процедуры calc_bordero иначе строки нет строк бордеро премий)
                  
                  )
      LOOP
        SAVEPOINT before_calc_decline_loop;
        BEGIN
        
          /*          for pay in (select bl.* from re_bordero b, re_bordero_line bl
                      where bl.re_bordero_id=b.re_bordero_id
                      and b.re_bordero_package_id=par_bordero_package_id
                      and bl.payment_end_date > cur.decline_date
                      and not exists (select 1 from re_bordero_line l
                                      where l.parent_line_id = bl.re_bordero_line_id)) loop
          */
        
          IF cur.decline_date BETWEEN cur.payment_start_date AND cur.payment_end_date
          THEN
            --* Тут надо добавлять флаг типа n_need_save, который будет определять актуальную строку
            --* исходного бордеро премий, так как в случае изменений задними числамиможет быть несколько
            --* строк бордеро премий (хотя ситуация достаточно редкая)
            --* Вообще говоря должно быть ветвление (если определена функция возврата премии)
          
            -- Определение типа премии
            v_premium_type_id := get_premium_type(cur.payment_start_date, d_end_bordero, 20); --Определяем тип премии. 20 - тип Доля в возвратах
          
            n_RP := get_RP(cur.period_reinsurer_premium
                          ,cur.payment_start_date
                          ,cur.payment_end_date
                          ,cur.decline_date
                          ,NULL /** необходимо начитать ID функции возврата **/);
            --*
            --*               n_RP:=get_RP_by_func(v_re_version_id, cur.period_reinsurer_premium,cur.payment_start_date,cur.payment_end_date,
            --*                       cur.decline_date,cur.product_line_id, cur.fund_id );
            --*
            get_re_comiss_returned(par_re_main_contract_id  => v_re_main_contract_id
                                  ,par_re_bordero_type_id   => с_re_bordero_type_id
                                  ,par_p_pol_header_id      => cur.policy_header_id
                                  ,par_assured_contact_id   => cur.assured_contact_id
                                  ,par_flg_no_comiss        => 0 /* считаем, что комиссию взимали */
                                  ,par_re_calc_func_id      => v_re_contract_version.re_return_comis_func_id
                                  ,par_cover_start_date     => cur.cover_start_date
                                  ,par_cover_end_date       => cur.cover_end_date
                                  ,par_bordero_start_date   => cur.bordero_start_date
                                  ,par_bordero_end_date     => cur.bordero_end_date
                                  ,par_product_line_id      => cur.product_line_id
                                  ,par_product_line_type_id => cur.product_line_type_id
                                  ,par_payment_period_start => cur.payment_start_date
                                  ,par_payment_period_end   => cur.payment_end_date
                                  ,par_first_payment_date   => cur.first_pay_date
                                  ,par_cancel_date          => cur.decline_date
                                  ,par_insurance_type       => cur.insurance_type
                                  ,par_re_fixed_com         => cur.fixed_commission
                                  ,par_return_add_com       => v_return_add_com
                                  ,par_return_fixed_com     => v_return_fixed_com);
            v_return_re_commission := v_return_add_com + v_return_fixed_com;
          ELSE
            -- Определение типа премии
            v_premium_type_id      := get_premium_type(cur.payment_start_date, d_end_bordero, 30); --Определяем тип премии. 30 - тип Сторно
            n_RP                   := cur.period_reinsurer_premium;
            v_return_add_com       := cur.add_commission;
            v_return_fixed_com     := cur.fixed_commission;
            v_return_re_commission := cur.re_comision;
          END IF;
        
          SELECT b.re_bordero_id
            INTO p_bordero_id
            FROM re_bordero      b
                ,re_bordero_type t
           WHERE b.re_bordero_type_id = t.re_bordero_type_id
             AND t.short_name = 'БР'
             AND b.re_bordero_package_id = par_bordero_package_id
             AND b.fund_id = cur.fund_id;
        
          --Сохраняем
          SELECT sq_re_cover.nextval INTO p_re_cover_id FROM dual;
        
          INSERT INTO re_cover
            (re_cover_id
            ,p_cover_id
            ,start_date
            ,end_date
            ,cancel_date
            ,brutto_premium
            ,commission
            ,fund_id
            ,re_bordero_id
            ,re_bordero_line_id)
          VALUES
            (p_re_cover_id
            ,cur.p_cover_id
            ,cur.start_date
            ,cur.end_date
            ,cur.decline_date
            ,cur.period_reinsurer_premium
            ,cur.re_comision
            ,cur.fund_id
            ,p_bordero_id
            ,cur.re_bordero_line_id);
        
          INSERT INTO rel_recover_bordero
            (rel_recover_bordero_id
            ,re_cover_id
            ,re_bordero_id
            ,commission
            ,ac_payment_id
            ,sum_assured
            ,re_comm_rate
            ,re_commission
            ,return_re_commission
            ,cover_start_date
            ,cover_end_date
            ,payment_start_date
            ,payment_end_date
            ,original_benefit_insured
            ,tariff
            ,reinsurance_share
            ,year_reinsurance_premium
            ,returned_premium
            ,cover_decline_date
            ,premium_type_id
            ,return_fixed_commission
            ,return_add_commission)
          VALUES
            (sq_rel_recover_bordero.nextval
            ,p_re_cover_id
            ,p_bordero_id
            ,0
            ,cur.payment_id
            ,cur.ins_amount
            ,0
            ,0
            ,nvl(v_return_re_commission, 0)
            ,cur.start_date
            ,cur.end_date
            ,cur.payment_start_date
            ,cur.payment_end_date
            ,cur.original_benefit_insured
            ,cur.tariff
            ,cur.reinsurer_share
            ,cur.year_reinsurer_premium
            ,n_RP
            ,cur.decline_date
            ,v_premium_type_id
            ,v_return_fixed_com
            ,v_return_add_com);
          --   end loop;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO before_calc_decline_loop;
            v_error_message := substr(SQLERRM, 1, 250);
            calc_decline_log(par_bordero_package_id => par_bordero_package_id
                            ,par_cover_id           => cur.p_cover_id
                            ,par_error_message      => v_error_message
                            ,par_backtrace          => dbms_utility.format_error_backtrace);
        END;
      END LOOP;
    
      --* Возможно сохранение итоговых сумм нам пока в таком виде не нужно
      --Прописываем итоговые суммы в бордеро
      FOR cur_s IN (SELECT b.re_bordero_id
                      FROM re_bordero      b
                          ,re_bordero_type t
                     WHERE b.re_bordero_type_id = t.re_bordero_type_id
                       AND t.short_name = 'БР'
                       AND b.re_bordero_package_id = par_bordero_package_id)
      LOOP
        UPDATE re_bordero r
           SET r.returned_premium =
               (SELECT SUM(r.returned_premium)
                  FROM rel_recover_bordero r
                 WHERE r.re_bordero_id = cur_s.re_bordero_id)
         WHERE r.re_bordero_id = cur_s.re_bordero_id;
      END LOOP;
    END IF;
  END calc_decline;

  /*  Функция возвращает дату получения уведомления по страховому случаю
  par_policy_id - ID версии договора страхования
  par_asset_id - ID застрахованного
  par_cover_id - ID покрытия
  par_border_start_date - Дата начала действия бордеро
  par_bordero_end_date - Дата окончания действия бордеро
  */
  FUNCTION get_claim_id
  (
    par_policy_id          IN NUMBER
   ,par_asset_id           IN NUMBER
   ,par_cover_id           IN NUMBER
   ,par_border_start_date  IN DATE
   ,par_bordero_end_date   IN DATE
   ,par_payment_start_date IN DATE
   ,par_payment_end_date   IN DATE
   ,par_reins_perc         IN NUMBER
   ,par_bordero_line_id    IN NUMBER
  ) RETURN NUMBER IS
    res               NUMBER := 0;
    p_claim_type      NUMBER;
    p_pay_date        DATE;
    p_cancel_date     DATE;
    p_status_brief    VARCHAR2(100);
    p_rate            NUMBER;
    p_reins_sum       NUMBER;
    p_pay_sum         NUMBER;
    p_ins_group_brief VARCHAR2(100);
  BEGIN
  
    --Выбираем убытки, заявленные до окончания действия периода бордеро
    --select max(ch.active_claim_id) into res
    FOR cur IN (SELECT DISTINCT ch.c_claim_header_id
                               ,ch.declare_date
                               ,ch.active_claim_id
                               ,ce.date_company
                               ,ce.event_date
                               ,f.brief              AS claim_fund_brief
                               ,dmgf.brief           AS damage_fund_brief
                               ,c.declare_sum
                               ,c.c_claim_id
                  FROM c_claim_header ch
                      ,c_claim        c
                      ,c_event        ce
                      ,fund           f
                      ,c_damage       dmg
                      ,fund           dmgf
                 WHERE ch.active_claim_id = c.c_claim_id
                   AND ch.c_event_id = ce.c_event_id
                   AND ch.p_policy_id = par_policy_id
                   AND ch.as_asset_id = par_asset_id
                   AND ch.p_cover_id = par_cover_id
                   AND dmg.c_claim_id = c.c_claim_id
                   AND dmgf.fund_id = dmg.damage_fund_id
                   AND f.fund_id = ch.fund_id
                   AND ce.date_company <= par_bordero_end_date)
    LOOP
    
      p_pay_date := nvl(pkg_renlife_utils.ret_sod_claim(cur.c_claim_header_id), '01.01.1900');
    
      SELECT MAX(ds.start_date)
        INTO p_cancel_date
        FROM ven_c_claim clm2
            ,doc_status  ds
       WHERE clm2.c_claim_header_id = cur.c_claim_header_id
         AND ds.document_id = clm2.c_claim_id
         AND ds.doc_status_ref_id = 128;
    
      p_status_brief := nvl(doc.get_last_doc_status_brief(cur.active_claim_id), '-');
    
      p_claim_type := check_claim(cur.active_claim_id
                                 ,par_cover_id
                                 ,cur.date_company
                                 ,par_border_start_date
                                 ,par_bordero_end_date
                                 ,p_pay_date
                                 ,cur.event_date
                                 ,p_cancel_date
                                 ,p_status_brief);
    
      IF p_claim_type = 1
      THEN
        --БЗУ
        p_rate      := nvl(acc.Get_Rate_By_Brief('ЦБ', cur.claim_fund_brief, par_bordero_end_date)
                          ,1);
        p_reins_sum := cur.declare_sum * par_reins_perc * p_rate;
      ELSIF p_claim_type = 2
      THEN
        --БОУ
        p_rate := nvl(acc.Get_Cross_Rate_By_Brief(1
                                                 ,cur.damage_fund_brief
                                                 ,cur.claim_fund_brief
                                                 ,p_pay_date)
                     ,1);
      
        SELECT ig.brief
          INTO p_ins_group_brief
          FROM p_cover            pc
              ,t_prod_line_option plo
              ,t_product_line     pl
              ,t_lob_line         ll
              ,t_insurance_group  ig
         WHERE ig.t_insurance_group_id = ll.insurance_group_id
           AND ll.t_lob_line_id = pl.t_lob_line_id
           AND pl.id = plo.product_line_id
           AND plo.id = pc.t_prod_line_option_id
           AND pc.p_cover_id = par_cover_id;
      
        --Суммы выплаченного страхового обеспечения
        SELECT SUM(CASE
                     WHEN dso.set_off_date IS NOT NULL THEN
                      ac.rev_amount
                     ELSE
                      0
                   END)
          INTO p_pay_sum
          FROM doc_doc        dd
              ,doc_set_off    dso
              ,document       d_p
              ,document       d_ch
              ,doc_templ      dt_p
              ,doc_templ      dt_ch
              ,ven_ac_payment ac
              ,doc_status_ref dsr
         WHERE dd.parent_id = cur.c_claim_id
           AND p_ins_group_brief != 'NonInsuranceClaims'
           AND dso.parent_doc_id = d_p.document_id
           AND dso.child_doc_id = d_ch.document_id
           AND d_p.doc_templ_id = dt_p.doc_templ_id
           AND d_ch.doc_templ_id = dt_ch.doc_templ_id
           AND ((dd.child_id = dso.child_doc_id AND dt_ch.brief = 'PAYORDER_SETOFF' AND
               dt_p.brief = 'PAYMENT' AND ac.payment_id = d_ch.document_id) OR
               (dd.child_id = dso.parent_doc_id AND dt_p.brief = 'PAYORDER' AND dt_ch.brief = 'ППИ' AND
               ac.payment_id = d_p.document_id))
           AND ac.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'PAID'
           AND dso.cancel_date IS NULL;
      
        p_reins_sum := p_pay_sum * par_reins_perc * p_rate;
      END IF;
    
      --Сохранияем в коллекцию
      t_claim.extend(1);
      t_claim(t_claim.count).re_bordero_line_id := par_bordero_line_id;
      t_claim(t_claim.count).policy_id := par_policy_id;
      t_claim(t_claim.count).claim_id := cur.c_claim_id;
      t_claim(t_claim.count).claim_type := p_claim_type;
      t_claim(t_claim.count).reins_sum := p_reins_sum;
      t_claim(t_claim.count).pay_sum := p_pay_sum;
      t_claim(t_claim.count).reserve_sum := cur.declare_sum;
    
      res := 1; --Возвращаем флаг наличия убытка
    
    END LOOP;
  
    RETURN res;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    
  END get_claim_id;

  /*функция определяет, к какому типу относится убыток
  0 - не входит в бордеро
  1 - Бордеро заявленных убытков (БЗУ)
  2 - Бордеро оплаченных убытков (БОУ)
  */
  FUNCTION check_claim
  (
    par_claim_id           IN NUMBER
   ,par_cover_id           IN NUMBER
   ,par_date_company       IN DATE
   ,par_bordero_start_date IN DATE
   ,par_bordero_end_date   IN DATE
   ,par_pay_date           IN DATE
   ,par_event_date         IN DATE
   ,par_date_cancel        IN DATE
   ,par_status_brief       IN VARCHAR2
  ) RETURN NUMBER IS
    res    NUMBER := 0;
    p_flag NUMBER;
  BEGIN
    p_flag := get_claim_flag(par_claim_id, par_cover_id);
  
    IF p_flag = 0
       AND par_date_company <= par_bordero_end_date
       AND par_date_cancel > par_bordero_end_date
    THEN
      res := 1;
    END IF;
  
    IF p_flag = 1
       AND par_date_company <= par_bordero_end_date
       AND par_pay_date > par_bordero_end_date
    THEN
      res := 1;
    END IF;
  
    IF p_flag = 2
       AND par_date_company <= par_bordero_end_date
       AND nvl(par_pay_date, '01.01.1900') = to_date('01.01.1900', 'dd.mm.yyyy')
       AND nvl(par_date_cancel, '01.01.1900') = to_date('01.01.1900', 'dd.mm.yyyy')
    THEN
      res := 1;
    END IF;
  
    --Бодеро оплаченных убытков
    IF p_flag = 1
       AND par_date_company <= par_bordero_end_date
       AND par_pay_date BETWEEN par_bordero_start_date AND par_bordero_end_date
       AND par_status_brief = 'CLOSE'
    THEN
      res := 2;
    END IF;
  
    RETURN res;
  END check_claim;

  /*  Функция возвращает значение флага убытка
  */
  FUNCTION get_claim_flag
  (
    par_claim_id IN NUMBER
   ,par_cover_id IN NUMBER
  ) RETURN NUMBER AS
    res           NUMBER;
    p_doc_status  VARCHAR2(255);
    p_declare_sum NUMBER;
    p_payment_sum NUMBER;
    p_decline_sum NUMBER;
    p_amount      NUMBER;
  BEGIN
    p_doc_status := nvl(doc.get_last_doc_status_name(par_claim_id), '-');
  
    SELECT CASE
             WHEN nvl(pc.ins_amount, 0) = 0 THEN
              nvl((SELECT SUM(plop.limit_amount)
                    FROM t_prod_line_opt_peril plop
                        ,c_claim_header        ch
                   WHERE plop.product_line_option_id = pc.t_prod_line_option_id
                     AND plop.peril_id = ch.peril_id
                     AND ch.p_cover_id = pc.p_cover_id)
                 ,0)
             ELSE
              nvl(pc.ins_amount, 0)
           END
      INTO p_amount
      FROM p_cover pc
     WHERE pc.p_cover_id = par_cover_id;
  
    SELECT SUM(nvl(d.declare_sum, 0))
          ,SUM(nvl(d.decline_sum, 0))
          ,SUM(nvl(d.payment_sum, 0))
      INTO p_declare_sum
          ,p_decline_sum
          ,p_payment_sum
      FROM p_cover        pc
          ,t_peril        tp
          ,c_claim_header ch
          ,c_claim        c
          ,c_damage       d
     WHERE pc.p_cover_id = par_cover_id
       AND ch.p_cover_id = pc.p_cover_id
       AND tp.id = ch.peril_id
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND d.c_claim_id = c.c_claim_id
       AND c.c_claim_id = par_claim_id --* идентификация версии дела
       AND d.status_hist_id <> 3; --* Без учета удаленных элементов
  
    IF p_doc_status IN
       ('Передано на оплату', 'Закрыт', 'Отказано в выплате')
    THEN
      IF (p_amount > 0)
         AND (p_payment_sum > 0)
      -- round((nvl(p_declare_sum,0) - nvl(p_decline_sum,0)), 3) > 0
      THEN
        res := 1;
      ELSE
        res := 0;
      END IF;
    ELSE
      res := 2;
    END IF;
  
    RETURN res;
  
  END get_claim_flag;

  /* Функция возвращает самую старшую версию до даты изменения
  par_pol_header_id - ID заголовка договора страховаиня
  par_change_date - Дата изменения версии
  */

  FUNCTION get_version_before_change
  (
    par_pol_header_id IN NUMBER
   ,par_change_date   IN DATE
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    SELECT MAX(p.policy_id)
      INTO res --Берем последнюю версию до даты изменения
      FROM p_policy       p
          ,doc_status     ds
          ,doc_status_ref dsr
     WHERE p.pol_header_id = par_pol_header_id
       AND p.start_date < par_change_date
       AND p.policy_id = ds.document_id
       AND dsr.doc_status_ref_id = ds.doc_status_ref_id;
  
    RETURN res;
  END get_version_before_change;

  /*  Функция определяет начало периода перестраховщика
  
  */
  FUNCTION get_re_start_date
  (
    par_pay_plan_date    IN DATE
   ,par_cover_start_date IN DATE
   ,par_first_pay_date   IN DATE
  ) RETURN DATE AS
    res             DATE;
    p_max_year_date DATE;
    p_b             BOOLEAN := FALSE;
  BEGIN
    --Определяем дату самой поздней страховой годовщины
    p_max_year_date := par_first_pay_date;
    WHILE NOT p_b
    LOOP
      IF ADD_MONTHS(p_max_year_date, 12) > par_pay_plan_date
      THEN
        p_b := TRUE;
      ELSE
        p_max_year_date := ADD_MONTHS(p_max_year_date, 12);
      END IF;
    END LOOP;
  
    res := greatest(p_max_year_date, par_cover_start_date);
  
    RETURN res;
  END get_re_start_date;

  /*  Функция определяет окончание периода перестраховщика
  
  */
  FUNCTION get_re_end_date
  (
    par_pay_plan_date        DATE
   ,par_first_pay_date       DATE
   ,par_cover_end_date       DATE
   ,par_one_str_for_one_prem NUMBER
  ) RETURN DATE AS
    res             DATE;
    p_max_year_date DATE;
    p_b             BOOLEAN := FALSE;
  BEGIN
    IF par_one_str_for_one_prem = 0
    THEN
      --Определяем дату самой поздней страховой годовщины
      p_max_year_date := par_first_pay_date;
      WHILE NOT p_b
      LOOP
        p_max_year_date := ADD_MONTHS(p_max_year_date, 12);
        IF p_max_year_date > par_pay_plan_date
        THEN
          p_b := TRUE;
        END IF;
      END LOOP;
    
      res := p_max_year_date - 1;
    ELSE
      res := par_cover_end_date;
    END IF;
    RETURN res;
  END get_re_end_date;

  /* Функция возвращает дату страховой годовщины
    par_mode - вариант расчета  1 - ранее par_date
                                2 - не позднее par_date
                                3 - не ранее par_date
                                4 - позднее par_date
  */
  FUNCTION get_anniversary_date
  (
    par_date       IN DATE
   ,par_start_date IN DATE
   ,par_mode       IN NUMBER
  ) RETURN DATE IS
    p_max_year_date DATE;
    p_b             BOOLEAN := FALSE;
  BEGIN
    p_max_year_date := par_start_date;
  
    IF par_mode = 1
    THEN
      --Определяем дату самой поздней страховой годовщины
      WHILE NOT p_b
      LOOP
        IF ADD_MONTHS(p_max_year_date, 12) >= par_date
        THEN
          p_b := TRUE;
        ELSE
          p_max_year_date := ADD_MONTHS(p_max_year_date, 12);
        END IF;
      END LOOP;
    ELSIF par_mode = 2
    THEN
      --не позднее
      WHILE NOT p_b
      LOOP
        IF ADD_MONTHS(p_max_year_date, 12) > par_date
        THEN
          p_b := TRUE;
        ELSE
          p_max_year_date := ADD_MONTHS(p_max_year_date, 12);
        END IF;
      END LOOP;
    ELSIF par_mode = 3
    THEN
      --не ранее
      WHILE NOT p_b
      LOOP
        p_max_year_date := ADD_MONTHS(p_max_year_date, 12);
        IF p_max_year_date >= par_date
        THEN
          p_b := TRUE;
        END IF;
      END LOOP;
    ELSIF par_mode = 4
    THEN
      --позднее
      WHILE NOT p_b
      LOOP
        p_max_year_date := ADD_MONTHS(p_max_year_date, 12);
        IF p_max_year_date > par_date
        THEN
          p_b := TRUE;
        END IF;
      END LOOP;
    
    END IF;
  
    RETURN p_max_year_date;
  END get_anniversary_date;

  /*  Функция сравнивает риски разных версий и возвращает тип изменений
    0-Нет изменений,
    1-Новый риск,
    2-Изменения,
    3-Удаление
  */
  FUNCTION compare_cover
  (
    par_cover_before_id IN NUMBER
   ,par_cover_after_id  IN NUMBER
  ) RETURN NUMBER IS
    res          NUMBER;
    v_begin_date DATE;
    v_end_date   DATE;
    v_amount     NUMBER;
  BEGIN
    --Берем статус из последней версии
    SELECT pc.status_hist_id INTO res FROM p_cover pc WHERE pc.p_cover_id = par_cover_after_id;
  
    IF res = 2
    THEN
      --Если статус не менялся, то проверяем остальные параметры
      --Берем параметры из старой версии
      SELECT pc.start_date
            ,pc.end_date
            ,pc.ins_amount
        INTO v_begin_date
            ,v_end_date
            ,v_amount
        FROM p_cover pc
       WHERE pc.p_cover_id = par_cover_before_id;
    
      --Делаем запрос на сравнение параметров. Если были изменения, то возвращаем 2, если не было, то 0
      SELECT decode(COUNT(*), 0, 2, 0)
        INTO res
        FROM p_cover pc
       WHERE pc.p_cover_id = par_cover_after_id
         AND pc.start_date = v_begin_date
         AND pc.end_date = v_end_date
         AND pc.ins_amount = v_amount;
    
    END IF;
  
    RETURN res;
  END compare_cover;

  /* Процедура обнуления бордеро
  par_bordero_package_id - ID пакета бордеро
  */
  PROCEDURE clear_bordero(par_bordero_package_id IN NUMBER) AS
  BEGIN
    UPDATE re_bordero b
       SET b.brutto_premium = 0
          ,b.netto_premium  = 0
          ,b.commission     = 0
     WHERE b.re_bordero_package_id = par_bordero_package_id;
  
    -- Удаление бордеро убытков
    FOR vr_loss IN (SELECT b.re_bordero_id
                      FROM re_bordero      b
                          ,re_bordero_type t
                     WHERE b.re_bordero_package_id = par_bordero_package_id
                       AND b.re_bordero_type_id = t.re_bordero_type_id
                       AND t.brief IN ('БОРДЕРО_ОПЛ_УБЫТКОВ'
                                      ,'БОРДЕРО_ЗАЯВ_УБЫТКОВ'))
    LOOP
      pkg_re_bordero.delete_bordero_loss(vr_loss.re_bordero_id);
    END LOOP;
  
    DELETE FROM re_cover rc
     WHERE rc.re_bordero_id IN
           (SELECT b.re_bordero_id
              FROM re_bordero b
             WHERE b.re_bordero_package_id = par_bordero_package_id);
  
    DELETE FROM re_bordero_line bl
     WHERE bl.re_bordero_id IN
           (SELECT b.re_bordero_id
              FROM re_bordero b
             WHERE b.re_bordero_package_id = par_bordero_package_id);
  
    --Обнуляем расчет в пакет бордеро
    UPDATE re_bordero_package bp
       SET bp.summ = 0
     WHERE bp.re_bordero_package_id = par_bordero_package_id;
  
  END clear_bordero;

  /* процедура сохранения рассчитанных линий в бордеро
  par_bordero_package_id - ID пакета бордеро
  */
  PROCEDURE save_bordero(par_bordero_package_id IN NUMBER) AS
    v_sum NUMBER;
  BEGIN
    --Сохранияем в бордеро
    FOR cur IN (SELECT bl.re_bordero_id
                      ,SUM(bl.period_reinsurer_premium) AS PRP
                      ,SUM(bl.year_reinsurer_premium) AS YRP
                      ,SUM(bl.re_comision) AS comission
                  FROM re_bordero_line bl
                      ,re_bordero      b
                 WHERE bl.re_bordero_id = b.re_bordero_id
                   AND b.re_bordero_package_id = par_bordero_package_id
                 GROUP BY bl.re_bordero_id)
    LOOP
    
      UPDATE re_bordero b
         SET b.brutto_premium = cur.prp
            ,b.netto_premium  = cur.yrp
            ,b.commission     = cur.comission
       WHERE b.re_bordero_id = cur.re_bordero_id;
    END LOOP;
  
    SELECT SUM(b.brutto_premium)
      INTO v_sum
      FROM re_bordero b
     WHERE b.re_bordero_package_id = par_bordero_package_id;
    --Сохряняем расчет в пакет бордеро
    UPDATE re_bordero_package bp
       SET bp.summ = nvl(v_sum, 0)
     WHERE bp.re_bordero_package_id = par_bordero_package_id;
  
  END save_bordero;

  /*  Функция для поиска версий изменений в промежуточных датах
  par_pol_header_id - ID заголовка договора страхования
  par_pay_start_date - Дата начала платежей
  par_pay_end_date - Дата окончания платежей
  par_bordero_end_date - Дата окончания пакета бордеро
  */
  FUNCTION get_changed_version
  (
    par_pol_header_id  IN NUMBER
   ,par_pay_start_date IN DATE
   ,par_pay_end_date   IN DATE
    --  ,par_bordero_end_date in date
   ,par_policy_id       IN NUMBER
   ,par_contact_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_cover_id        IN NUMBER
   ,par_bordero_line_id IN NUMBER
  ) RETURN NUMBER IS
    v_res                    NUMBER;
    v_change_policy_cover_id NUMBER;
    v_change_policy_type     NUMBER;
  BEGIN
    FOR cur IN (SELECT pp.policy_id
                      ,pp.start_date
                  FROM p_policy       pp
                      ,doc_status     ds
                      ,doc_status_ref dsr
                 WHERE ds.document_id = pp.policy_id
                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                   AND dsr.brief = 'CURRENT'
                   AND pp.pol_header_id = par_pol_header_id
                   AND pp.start_date > par_pay_start_date
                   AND pp.start_date <= par_pay_end_date
                      --and ds.change_date       <= par_bordero_end_date
                   AND pp.policy_id != par_policy_id)
    LOOP
    
      v_change_policy_cover_id := get_policy_cover_id(cur.policy_id
                                                     ,par_contact_id
                                                     ,par_product_line_id);
      v_change_policy_type     := compare_cover(par_cover_id, v_change_policy_cover_id);
    
      --Сохранияем в коллекцию
      t_change.extend(1);
      t_change(t_change.count).re_bordero_line_id := par_bordero_line_id;
      t_change(t_change.count).policy_id := cur.policy_id;
      t_change(t_change.count).cover_id := v_change_policy_cover_id;
      t_change(t_change.count).type_id := v_change_policy_type;
    
      v_res := 1;
    END LOOP;
    RETURN v_res;
  END get_changed_version;

  /* функция ищет ID покрытия в новой версии договора, соотвествующий ID покрытия рассчитываемой версии договора
  par_policy_id - ID договора страхования
  par_contact_id - ID застрахованного
  par_product_line_id - ID продукта
  */

  FUNCTION get_policy_cover_id
  (
    par_policy_id       IN NUMBER
   ,par_contact_id      IN NUMBER
   ,par_product_line_id IN NUMBER
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    SELECT pc.p_cover_id
      INTO res
      FROM as_asset           a
          ,as_assured         su
          ,p_cover            pc
          ,t_prod_line_option plo
     WHERE a.as_asset_id = pc.as_asset_id
       AND plo.id = pc.t_prod_line_option_id
       AND a.p_policy_id = par_policy_id
       AND plo.product_line_id = par_product_line_id
       AND a.as_asset_id = su.as_assured_id
       AND su.assured_contact_id = par_contact_id;
    RETURN res;
  END get_policy_cover_id;

  /* Функция рассчитывает нетто-ставку
  
  */
  FUNCTION get_P
  (
    par_prod_line_id  IN NUMBER
   ,par_program_brief IN VARCHAR2
   ,par_A_xn          IN NUMBER
   ,par_a_x_n         IN NUMBER
   ,par_is_periodical IN NUMBER
  ) RETURN NUMBER AS
    res       NUMBER := 0;
    p_func_id NUMBER;
  BEGIN
  
    IF par_program_brief = 'END'
    THEN
      res := pkg_PrdLifeCalc.END_get_netto(par_prod_line_id);
    END IF;
    /*  IF par_is_periodical = 0 THEN
       -- Оплата в рассрочку (ежегодно, ежемесячто, ежеквартально и т.д.)
         res := ROUND (par_A_xn/par_a_x_n, 7);
       ELSIF par_is_periodical = 1 THEN
       -- Случай единовременоой оплаты страховой премии
         res := ROUND (par_A_xn, 7);
       END IF;
    
      else
    
        --Ищем функцию расчета
        begin
          select pl.tariff_netto_func_id into p_func_id
          from t_product_line pl
          where pl.id=par_prod_line_id;
    
          --запускаем функцию
          select c.val into res
          from t_prod_coef c
          where c.t_prod_coef_type_id=p_func_id
          and c.criteria_1=par_prod_line_id;
        exception
          when no_data_found then
            res:=0;
        end;
      end if;
    */
    RETURN res;
  END get_P;

  /*------------------------Функции проверок ---------------------------*/
  /*
    Функция проверки повышающих коэффициентов
  
  */
  FUNCTION Check_koef
  (
    par_s_med           IN NUMBER
   ,par_s_no_med        IN NUMBER
   ,par_k_med           IN NUMBER
   ,par_k_no_med        IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_re_version_id   IN NUMBER
  ) RETURN NUMBER IS
    res        NUMBER;
    v_s_med    NUMBER;
    v_s_no_med NUMBER;
    v_k_med    NUMBER;
    v_k_no_med NUMBER;
  BEGIN
    -- Проверяем коэффициенты на риске
    BEGIN
      SELECT v.s_koef_m_max
            ,v.s_koef_nm_max
            ,v.k_koef_m_max
            ,v.k_koef_nm_max
        INTO v_s_med
            ,v_s_no_med
            ,v_k_med
            ,v_k_no_med
        FROM re_cond_filter_obl   v
            ,re_contract_ver_fund cf
       WHERE cf.re_contract_ver_fund_id = v.re_contract_ver_fund_id
         AND v.re_contract_ver_id = par_re_version_id
         AND v.product_id = par_product_id
         AND v.product_line_id = par_product_line_id
         AND cf.fund_id = par_fund_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_s_med    := 0;
        v_s_no_med := 0;
        v_k_med    := 0;
        v_k_no_med := 0;
    END;
  
    IF nvl(v_s_med, 0) = 0
       AND nvl(v_s_no_med, 0) = 0
       AND nvl(v_k_med, 0) = 0
       AND nvl(v_k_no_med, 0) = 0
    THEN
      --Если в риске не указан ни один коэффициент, то берем из договора(фильтра валют)
      BEGIN
        SELECT vf.s_koef_m_max
              ,vf.s_koef_nm_max
              ,vf.k_koef_m_max
              ,vf.k_koef_nm_max
          INTO v_s_med
              ,v_s_no_med
              ,v_k_med
              ,v_k_no_med
          FROM re_contract_ver_fund vf
         WHERE vf.fund_id = par_fund_id
           AND vf.re_contract_version_id = par_re_version_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_s_med    := 0;
          v_s_no_med := 0;
          v_k_med    := 0;
          v_k_no_med := 0;
      END;
    END IF;
  
    /*    IF nvl(v_s_med, 0) = 0
       AND nvl(v_s_no_med, 0) = 0
       AND nvl(v_k_med, 0) = 0
       AND nvl(v_k_no_med, 0) = 0
    THEN
      --Если коэффициенты не заданы, то считаем условие выполненным
      res := 1;
    ELSE*/
    --Проверяем соответствие коэффициентов
    IF (nvl(par_s_med, 0) > nvl(v_s_med, 0) AND nvl(v_s_med, 0) != 0)
       OR (nvl(par_s_no_med, 0) > nvl(v_s_no_med, 0) AND nvl(v_s_no_med, 0) != 0)
       OR (nvl(par_k_med, 0) > nvl(v_k_med, 0) AND nvl(v_k_med, 0) != 0)
       OR (nvl(par_k_no_med, 0) > nvl(v_k_no_med, 0) AND nvl(v_k_no_med, 0) != 0)
    THEN
      res := 0;
    ELSE
      res := 1;
    END IF;
    /*    END IF;*/
  
    RETURN res;
  END Check_koef;

  /*  Функция проверки лимитов
  par_ins_amount - Сумма
  par_ins_amount - ID валюты
  par_product_id - ID продукта
  par_product_line_id - ID линии продукта
  par_re_version_id - ID версии договора перестрахования
  */
  FUNCTION Check_limit
  (
    par_ins_amount      IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_re_version_id   IN NUMBER
   ,par_insurer_id      IN NUMBER
  ) RETURN NUMBER IS
    v_result       NUMBER;
    v_limit        NUMBER;
    v_fund_id      fund.fund_id%TYPE;
    v_rate_type_id rate_type.rate_type_id%TYPE;
  BEGIN
  
    BEGIN
      SELECT limit_amount
            ,t_fund_id
            ,rate_type_id
        INTO v_limit
            ,v_fund_id
            ,v_rate_type_id
        FROM (SELECT il.limit_amount
                    ,il.t_fund_id
                    ,il.rate_type_id
                FROM re_insurer_limits il
               WHERE il.re_contract_ver_id = par_re_version_id
                 AND il.insurer_contact_id = par_insurer_id
                 AND (il.t_product_id = par_product_id OR il.t_product_id IS NULL)
                 AND (il.t_product_line_id = par_product_line_id OR il.t_product_line_id IS NULL)
               ORDER BY il.t_product_id      NULLS LAST
                       ,il.t_product_line_id NULLS LAST)
       WHERE rownum = 1;
    
      v_limit := pkg_re_insurance.get_sum_by_rate(par_base_fund_id => par_fund_id
                                                 ,par_fund_id      => v_fund_id
                                                 ,par_sum          => v_limit
                                                 ,par_rate_date    => trunc(SYSDATE) -- Это системная дата (без времени)
                                                 ,par_rate_type_id => v_rate_type_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --Проверяем лимит  для риска
        BEGIN
          SELECT nvl(v.limit, 0)
            INTO v_limit
            FROM re_cond_filter_obl   v
                ,re_contract_ver_fund cf
           WHERE cf.re_contract_ver_fund_id = v.re_contract_ver_fund_id
             AND v.re_contract_ver_id = par_re_version_id
             AND v.product_id = par_product_id
             AND v.product_line_id = par_product_line_id
             AND cf.fund_id = par_fund_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_limit := 0;
        END;
      
        IF v_limit = 0
        THEN
          --Проверяем лимит по версии договора
          BEGIN
            SELECT nvl(vf.limit, 0)
              INTO v_limit
              FROM re_contract_ver_fund vf
             WHERE vf.fund_id = par_fund_id
               AND vf.re_contract_version_id = par_re_version_id;
          EXCEPTION
            WHEN no_data_found THEN
              v_limit := 0;
          END;
        END IF;
    END;
  
    IF v_limit = 0
    THEN
      --Если лимит не задан, то условие считается выполненным
      v_result := 1;
    ELSE
      IF par_ins_amount > v_limit
      THEN
        --Если страховая сумма превышает лимит, то это не соответствует условиям
        v_result := 0;
      ELSE
        v_result := 1;
      END IF;
    END IF;
  
    RETURN v_result;
  END Check_limit;

  /*  Проверка на количество застрахованных
  par_assured - Количество застрахованных
  par_re_version_id - ID версии договора перестрахования
  */
  FUNCTION Check_assured
  (
    par_assured       IN NUMBER
   ,par_re_version_id IN NUMBER
  ) RETURN NUMBER IS
    res   NUMBER;
    v_min NUMBER;
    v_max NUMBER;
  BEGIN
    --Ищем минимальное и максимальное значеиния застрахованных
    SELECT nvl(v.min_val, 0)
          ,nvl(v.max_val, 0)
      INTO v_min
          ,v_max
      FROM re_contract_version v
     WHERE v.re_contract_version_id = par_re_version_id;
  
    IF v_min = 0
       OR v_max = 0
    THEN
      --Если параметры не заданы, то условие считается выполненным
      res := 1;
    ELSE
      IF par_assured >= v_min
         AND par_assured < v_max
      THEN
        -- Если значение попадает в диапазон, то условие считается выполненным
        res := 1;
      ELSE
        res := 0;
      END IF;
    END IF;
  
    RETURN res;
  END check_assured;

  /* Проверка общему лимиту договора перестрахования
  par_sum - сумма
  par_fund_id - ID валюты
  par_re_version_id - Версия договора перестрахования
  */
  FUNCTION Check_total_limit
  (
    par_sum           IN NUMBER
   ,par_fund_id       IN NUMBER
   ,par_re_version_id IN NUMBER
  ) RETURN NUMBER IS
    res            NUMBER;
    v_limit        NUMBER;
    v_fund_id      NUMBER;
    v_rate_type_id NUMBER;
    v_rate         NUMBER;
    v_summ         NUMBER;
  BEGIN
    --Ищем лимит по договору перестрахования
    SELECT nvl(v.limit, 0)
          ,v.fund_id
          ,v.rate_type_id
      INTO v_limit
          ,v_fund_id
          ,v_rate_type_id
      FROM re_contract_version v
     WHERE v.re_contract_version_id = par_re_version_id;
  
    IF v_limit = 0
    THEN
      --Если лимит не задан, то условие считается выполненным
      res := 1;
    ELSE
    
      v_summ := pkg_re_insurance.Get_sum_by_rate(v_fund_id
                                                ,par_fund_id
                                                ,par_sum
                                                ,SYSDATE
                                                ,v_rate_type_id);
    
      IF v_summ > v_limit
      THEN
        --Если сумма превышает лимит, то условие не выполнено
        res := 0;
      ELSE
        res := 1;
      END IF;
    END IF;
  
    RETURN res;
  END check_total_limit;

  FUNCTION Get_sum_by_rate
  (
    par_base_fund_id IN NUMBER
   ,par_fund_id      IN NUMBER
   ,par_sum          IN NUMBER
   ,par_rate_date    IN DATE
   ,par_rate_type_id IN NUMBER
  ) RETURN NUMBER IS
    v_rate NUMBER;
  BEGIN
  
    --приводим валюты договора к валюте договора перестрахования
    IF par_base_fund_id <> par_fund_id
    THEN
      --Определяем курс
      IF par_base_fund_id = 122
      THEN
        --Если договор в рублях
        SELECT r.rate_value
          INTO v_rate
          FROM rate r
         WHERE r.rate_type_id = par_rate_type_id
           AND r.base_fund_id = par_base_fund_id
           AND r.contra_fund_id = par_fund_id
           AND r.rate_date = (SELECT MAX(r1.rate_date)
                                FROM rate r1
                               WHERE r1.rate_type_id = par_rate_type_id
                                 AND r1.base_fund_id = par_base_fund_id
                                 AND r1.contra_fund_id = par_fund_id);
        RETURN par_sum * v_rate;
      
      ELSE
        --Если договор в валюте
        --* Вставлена диагностика валюты
        BEGIN
          SELECT r.rate_value
            INTO v_rate
            FROM rate r
           WHERE r.rate_type_id = par_rate_type_id
             AND r.contra_fund_id = par_base_fund_id
             AND r.base_fund_id = par_fund_id
             AND r.rate_date = (SELECT MAX(r1.rate_date)
                                  FROM rate r1
                                 WHERE r1.rate_type_id = par_rate_type_id
                                   AND r1.contra_fund_id = par_base_fund_id
                                   AND r1.base_fund_id = par_fund_id);
          --*      exception when no_data_found then
          --*        raise_application_error(-20000, 'par_fund_id = '||TO_CHAR(par_fund_id)||' par_base_fund_id = '||TO_CHAR(par_base_fund_id));
        END;
        RETURN par_sum / v_rate;
      
      END IF;
    ELSE
      RETURN par_sum;
    END IF;
  
  END Get_sum_by_rate;

  /*  Проверка по совокупному лимиту
  par_product_line_id - Линия продукта
  par_re_version_id - Версия договора перестрахования
  */
  FUNCTION Check_limit_contract
  (
    par_policy_id       IN NUMBER
   ,par_product_id      IN NUMBER
   ,par_product_line_id IN NUMBER
   ,par_re_version_id   IN NUMBER
   ,par_plo_id          IN NUMBER
   ,par_fund_id         IN NUMBER
   ,par_contact_d       IN NUMBER
  ) RETURN NUMBER IS
    v_res           NUMBER := 1; /* Должно быть по умолчанию условие выполнено, так как цикл может ни разу не выполняться вообще, т.е. 1 */
    v_prod_group    NUMBER;
    v_peril_id      NUMBER;
    v_as_assured    NUMBER;
    v_amount_sum    NUMBER := 0;
    v_cnt           NUMBER := 0;
    v_pol_header_id p_policy.pol_header_id%TYPE;
  BEGIN
    SELECT pp.pol_header_id INTO v_pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;
  
    --Проверяем наличие совокупных лимитов
    BEGIN
      SELECT c.risk_group
        INTO v_prod_group
        FROM re_limit_contract c
       WHERE c.re_contract_version_id = par_re_version_id
         AND rownum = 1;
    
      --Если лимитов нет, то выходим без проверки.
    EXCEPTION
      WHEN no_data_found THEN
        v_res := 1;
        RETURN v_res;
    END;
  
    -- Цикл по группам агрегации
    --Ищем значение группы для продукта по функции
    FOR vr_prodg IN (SELECT fc.val prod_group
                           ,c.limit
                           ,c.rate_type_id
                           ,c.fund_id
                       FROM t_prod_coef fc
                            --,t_prod_coef_type  t
                           ,re_limit_contract   c
                           ,re_contract_version cv
                      WHERE /*t.brief = 'FIND_GROUP_FOR_PRODUCT'-- Теперь из формы, согласно ТЗ
                                                                                                          and t.t_prod_coef_type_id=*/
                      fc.t_prod_coef_type_id = cv.func_aggr_group_id
                  AND fc.criteria_1 = par_product_id
                  AND fc.criteria_2 = par_product_line_id
                  AND fc.criteria_3 = par_plo_id
                  AND fc.criteria_4 IN (SELECT pr.id
                                          FROM t_product             prod
                                              ,t_product_version     ver
                                              ,t_product_ver_lob     vl
                                              ,t_product_line        pl
                                              ,t_product_line_type   tl
                                              ,t_prod_line_option    opt
                                              ,t_prod_line_opt_peril per
                                              ,t_peril               pr
                                         WHERE prod.product_id = ver.product_id
                                           AND vl.product_version_id = ver.t_product_version_id
                                           AND pl.product_ver_lob_id = vl.t_product_ver_lob_id
                                           AND pl.product_ver_lob_id = vl.t_product_ver_lob_id
                                           AND pl.product_line_type_id = tl.product_line_type_id
                                           AND opt.product_line_id = pl.id
                                           AND per.product_line_option_id = opt.id
                                           AND per.peril_id = pr.id
                                           AND opt.id = par_plo_id
                                           AND pl.id = par_product_line_id
                                           AND prod.product_id = par_product_id)
                  AND c.re_contract_version_id = par_re_version_id
                  AND c.re_contract_version_id = cv.re_contract_version_id
                  AND nvl(c.risk_group, 0) = fc.val)
    LOOP
      -- Обнуление суммы контроля по группе агрегации
      v_amount_sum := 0;
      -- Обнуление флага проверки лимита
      v_cnt := 0;
    
      --Ищем совокупные лимиты
      --Лимит по группе риска есть, то ищем все договора застрахованного по данному страховому продукту
    
      --Цикл по  программам из группа риска, входящие в договор перестрахования по валюте
      FOR cur IN (SELECT fo.*
                        ,mc.reinsurer_id
                        ,pr.description  AS prod_name
                        ,pl.description  AS pl_name
                    FROM re_cond_filter_obl   fo
                        ,re_contract_ver_fund vf
                        ,re_contract_version  cv
                        ,re_main_contract     mc
                        ,t_product            pr
                        ,t_product_line       pl
                   WHERE fo.re_contract_ver_id = par_re_version_id
                     AND vf.re_contract_version_id = cv.re_contract_version_id
                     AND cv.re_main_contract_id = mc.re_main_contract_id
                     AND fo.re_contract_ver_fund_id = vf.re_contract_ver_fund_id
                     AND vf.fund_id = par_fund_id
                     AND pl.id = fo.product_line_id
                     AND pr.product_id = fo.product_id
                     AND fo.product_id IN (SELECT c.criteria_1
                                             FROM T_PROD_COEF      c
                                                 ,t_prod_coef_type t
                                            WHERE t.t_prod_coef_type_id = cv.func_aggr_group_id /** A1 из настройки формы - необходимо принять код A1 **/
                                              AND t.t_prod_coef_type_id = c.t_prod_coef_type_id
                                              AND val = vr_prodg.prod_group)
                     AND fo.product_line_id IN (SELECT c.criteria_2
                                                  FROM T_PROD_COEF      c
                                                      ,t_prod_coef_type t
                                                 WHERE t.t_prod_coef_type_id = cv.func_aggr_group_id /** A1 из настройки формы - необходимо принять код A1 **/
                                                   AND t.t_prod_coef_type_id = c.t_prod_coef_type_id
                                                   AND val = vr_prodg.prod_group))
      LOOP
        --По каждой программе ищем застрахованного и его договоры, в которых есть найденные страховые программы
        FOR cur_ass IN (SELECT ph.fund_id
                              ,SUM(pc.ins_amount) AS amount_sum
                          FROM p_cover            pc
                              ,t_prod_line_option plo
                              ,t_product_line     pl
                              ,t_product_ver_lob  pvl
                              ,t_product_version  pv
                              ,as_asset           a
                              ,as_assured         s
                              ,p_policy           p
                              ,document           d
                              ,doc_status_ref     dsr
                              ,p_pol_header       ph
                         WHERE pc.as_asset_id = a.as_asset_id
                           AND a.as_asset_id = s.as_assured_id
                           AND a.p_policy_id = p.policy_id
                           AND d.document_id = p.policy_id
                           AND dsr.doc_status_ref_id = d.doc_status_ref_id
                           AND plo.id = pc.t_prod_line_option_id
                           AND pl.id = plo.product_line_id
                           AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                           AND pv.t_product_version_id = pvl.product_version_id
                              --                               and ph.policy_id = p.policy_id -- только активная версия /** О16 исправления по замечанию анализа кода О16 **/
                           AND ph.policy_header_id = p.pol_header_id -- несколько версий по одному заголовку
                           AND pv.product_id = cur.product_id
                           AND pl.id = cur.product_line_id
                           AND (p.policy_id = par_policy_id OR
                               (p.pol_header_id != v_pol_header_id AND p.policy_id = ph.policy_id /** 246223 **/
                               -- Замечание 21 пользовательского тестирования
                               AND doc.get_doc_status_brief(ph.policy_id) NOT IN
                               ('STOP'
                                     ,'CANCEL'
                                     ,'STOPED'
                                     ,'READY_TO_CANCEL'
                                     ,'QUIT'
                                     ,'QUIT_TO_PAY'
                                     ,'QUIT_REQ_GET'
                                     ,'QUIT_REQ_QUERY'
                                     ,'TO_QUIT_CHECKED'
                                     ,'TO_QUIT_CHECK_READY'
                                     ,'TO_QUIT')))
                           AND p.start_date <= SYSDATE --Версия входит в период расчета
                           AND p.end_date >= SYSDATE
                           AND s.assured_contact_id = par_contact_d
                         GROUP BY ph.fund_id)
        LOOP
          --преобразуем сумму в валюте договора страхования к валюте договора перестрахования
          v_amount_sum := v_amount_sum +
                          pkg_re_insurance.Get_sum_by_rate(vr_prodg.fund_id
                                                          ,cur_ass.fund_id
                                                          ,cur_ass.amount_sum
                                                          ,SYSDATE
                                                          ,vr_prodg.rate_type_id);
          v_cnt        := 1;
        END LOOP; --Цикл по застрахованному и его программам по всем действующим договорам
      
        -- Проверку лимита можно осуществлять и вне этого цикла
        IF v_cnt > 0
        THEN
          IF v_amount_sum > /*=*/
             vr_prodg.limit
          THEN
            --Если хоть одна сумма страхования больше лимита, то условие считается невыполненным.
            v_res := 0;
            RETURN v_res;
          ELSE
            v_res := 1;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    RETURN v_res;
  
  END Check_limit_contract;

  /* Проверка вхождения периода действия программы в период действия пакета бордеро
  par_cover_start_date - Дата начала действия покрытия
  par_cover_end_date - Дата окончания действия покрытия
  par_bordero_start_date - Дата начала действия бордеро
  par_bordero_end_date - Дата окончаюя действия бордер
  */
  FUNCTION Check_cover_period
  (
    par_cover_start_date   IN DATE
   ,par_cover_end_date     IN DATE
   ,par_bordero_start_date IN DATE
   ,par_bordero_end_date   IN DATE
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --Если дата начала покрытия больше даты окончание бордеро, то 0
    IF par_cover_start_date > par_bordero_end_date
    THEN
      res := 0;
      --Если дата окончания покрытия меньше даты начала бордеро, то 0
    ELSIF par_cover_end_date < par_cover_start_date
    THEN
      res := 0;
      --Если дата начала покрытия между  датами начала и окончания бордеро, то 1
    ELSIF par_cover_start_date BETWEEN par_bordero_start_date AND par_bordero_end_date
    THEN
      res := 1;
      --Если дата начала покрытия меньше даты начала бордеро и дата завершения покрытия больше даты начала бордеро, то 1
    ELSIF par_cover_start_date < par_bordero_start_date
          AND par_cover_end_date > par_bordero_start_date
    THEN
      res := 1;
      --Если дата окончания покрытия больше даты окончания бордеро и дата начала покрытия меньше даты окончания бордеро
    ELSIF par_cover_end_date > par_bordero_end_date
          AND par_cover_start_date < par_bordero_end_date
    THEN
      res := 1;
    ELSE
      res := 0; --Если вариант не предусмотрен, то обнуляем
    END IF;
  
    RETURN res;
  END Check_cover_period;

  /*  Функция сравнивает две даты и возвращает 1 если дата является годовщиной
  */
  FUNCTION Check_date_year
  (
    par_first_date  IN DATE
   ,par_second_date IN DATE
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --  if par_first_date<>par_second_date then
    IF to_char(par_first_date, 'DD.MM') = to_char(par_second_date, 'DD.MM')
    THEN
      res := 1;
    ELSE
      res := 0;
    END IF;
    --  else
    --    res:=0;
    --  end if;
  
    RETURN res;
  END Check_date_year;

  /*  Функция проверки вхождения риска в перестрахования
  par_cover_id - ID покрытия
  par_re_version_id - ID версии договора перестрахования
  par_bordero_type - Тип бордеро
  par_in_reins_program - Флаг обязательного перестрахования
  par_all_program - Флаг Все программы
  */
  FUNCTION Check_cover_in_bordero
  (
    par_cover_id         IN NUMBER
   ,par_re_version_id    IN NUMBER
   ,par_bordero_type     IN NUMBER
   ,par_in_reins_program IN NUMBER
   ,par_all_program      IN NUMBER
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --Если облигатор, то проверяем риск в договоре перестрахования
    IF par_bordero_type = 0
    THEN
      SELECT decode(COUNT(*), 0, 0, 1)
        INTO res
        FROM re_cond_filter_obl f
            ,t_product_line     pl
            ,t_prod_line_option plo
            ,p_cover            pc
       WHERE f.re_contract_ver_id = par_re_version_id
         AND f.product_line_id = pl.id
         AND plo.product_line_id = pl.id
         AND pc.t_prod_line_option_id = plo.id
         AND pc.p_cover_id = par_cover_id;
      --    and nvl(f.limit,0)>0;
    ELSE
      --Для факультатива проверяем, установлен ли флаг "Перечисление всех программ"
      IF nvl(par_all_program, 0) = 1
      THEN
        --Если флаг установлен, то проверяем входит ли риск в фильтр
        SELECT decode(COUNT(*), 0, 0, 1)
          INTO res
          FROM re_cond_filter_obl f
              ,t_product_line     pl
              ,t_prod_line_option plo
              ,p_cover            pc
         WHERE f.re_contract_ver_id = par_re_version_id
           AND f.product_line_id = pl.id
           AND plo.product_line_id = pl.id
           AND pc.t_prod_line_option_id = plo.id
           AND pc.p_cover_id = par_cover_id
           AND nvl(f.limit, 0) > 0;
      ELSE
        --Если флаг не установлен, то проверяем, входит ли риск в список рисков на закладке Перестрахование договора страхования
        IF nvl(par_in_reins_program, 0) = 1
        THEN
          --Если риск входит в список рисков, то берем его не проверяя на фильтр
          res := 1;
        ELSE
          SELECT decode(COUNT(*), 0, 0, 1)
            INTO res --Если не входит, то проверяем по фильтру
            FROM re_cond_filter_obl f
                ,t_product_line     pl
                ,t_prod_line_option plo
                ,p_cover            pc
           WHERE f.re_contract_ver_id = par_re_version_id
             AND f.product_line_id = pl.id
             AND plo.product_line_id = pl.id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.p_cover_id = par_cover_id
             AND nvl(f.limit, 0) > 0;
        END IF;
      END IF;
    END IF;
    RETURN res;
  END Check_cover_in_bordero;

  --Функция ищет в тексте PL/SQL блока ключевые слова
  FUNCTION Check_SQL_Text(par_sql IN VARCHAR2) RETURN BOOLEAN AS
  BEGIN
    IF instr(upper(par_sql), 'SELECT') > 0
       OR instr(upper(par_sql), 'UPDATE') > 0
       OR instr(upper(par_sql), 'DELETE') > 0
       OR instr(upper(par_sql), 'INSERT') > 0
       OR instr(upper(par_sql), 'DROP') > 0
       OR instr(upper(par_sql), 'ALTER') > 0
       OR instr(upper(par_sql), 'GRANT') > 0
       OR instr(upper(par_sql), 'COMMIT') > 0
       OR instr(upper(par_sql), 'ROLLBACK') > 0
       OR instr(upper(par_sql), 'MERGE') > 0
       OR instr(upper(par_sql), 'CREATE') > 0
       OR instr(upper(par_sql), 'EXECUTE') > 0
       OR instr(upper(par_sql), 'ROLLBACK') > 0
    THEN
      --Если встретилось хоть одно ключевое слово, то false
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  
  END Check_SQL_Text;

  /* Функция определяет к какому типу перестрахования относится договор страхования
   результат:
   -1 - Не входит в договор перестрахования
    0 - Облигатор (стандарт)
    1 - Облигатор (не стандарт)
    2 - Факультатив
  */
  FUNCTION Check_policy_type
  (
    par_re_ver_contract_id IN NUMBER
   ,par_policy_id          IN NUMBER
  ) RETURN NUMBER IS
    res                    NUMBER := -1;
    n_check_coef           NUMBER := 0;
    n_check_limit          NUMBER := 0;
    n_check_limit_contract NUMBER := 0;
    n_check_assured        NUMBER := 0;
    n_check_total_limit    NUMBER := 0;
    n_rowcount             NUMBER := 0;
    v_flg_no_standart_type re_contract_version.flg_no_standart_type%TYPE;
  BEGIN
    SELECT cv.flg_no_standart_type
      INTO v_flg_no_standart_type
      FROM re_contract_version cv
     WHERE cv.re_contract_version_id = par_re_ver_contract_id;
  
    --Проверяем, есть ли в договоре риски, попадающие под перестрахование
    FOR cur IN (SELECT nvl(decode(nvl(pcu.is_s_coef_m_re_default, 1), 1, pc.s_coef_m, pcu.s_coef_m_re)
                          ,0) s_coef_m
                      ,nvl(decode(nvl(pcu.is_s_coef_nm_re_default, 1)
                                 ,1
                                 ,pc.s_coef_nm
                                 ,pcu.s_coef_nm_re)
                          ,0) s_coef_nm
                      ,nvl(decode(nvl(pcu.is_k_coef_m_re_default, 1), 1, pc.k_coef_m, pcu.k_coef_m_re)
                          ,0) k_coef_m
                      ,nvl(decode(nvl(pcu.is_k_coef_nm_re_default, 1)
                                 ,1
                                 ,pc.k_coef_nm
                                 ,pcu.k_coef_nm_re)
                          ,0) k_coef_nm
                      ,pl.id AS product_line_id
                      ,pv.product_id
                      ,pc.ins_amount
                      ,ph.fund_id
                      ,a.as_asset_id
                      ,(SELECT COUNT(aa.as_assured_id)
                          FROM as_assured aa
                              ,as_asset   a1
                         WHERE aa.as_assured_id = a1.as_asset_id
                           AND a1.p_policy_id = p.policy_id
                           AND a1.status_hist_id != 3) AS assured_count --Исключаем удаленных застрахованных
                      ,(SELECT SUM(pc1.ins_amount)
                          FROM p_cover  pc1
                              ,as_asset a1
                         WHERE a1.as_asset_id = pc1.as_asset_id
                           AND a1.p_policy_id = p.policy_id
                           AND a1.status_hist_id != 3 -- неисключенный объект страхования
                           AND pc1.status_hist_id != 3 -- неисключенная программа
                        ) AS total_amount
                      ,plo.id AS plo_id
                      ,p.policy_id
                      ,s.assured_contact_id
                      ,pi.contact_id
                  FROM p_policy                 p
                      ,p_pol_header             ph
                      ,as_asset                 a
                      ,as_assured               s
                      ,p_cover                  pc
                      ,p_cover_underwr          pcu
                      ,t_prod_line_option       plo
                      ,t_product_line           pl
                      ,t_product_ver_lob        pvl
                      ,t_product_version        pv
                      ,re_cond_filter_obl       fo
                      ,ven_re_contract_ver_fund vf
                      ,v_pol_issuer             pi
                 WHERE a.as_asset_id = pc.as_asset_id
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = fo.product_line_id
                   AND p.pol_header_id = ph.policy_header_id
                   AND p.policy_id = a.p_policy_id
                   AND pcu.p_cover_underwr_id(+) = pc.p_cover_id
                   AND pl.id = plo.product_line_id
                   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                   AND pv.t_product_version_id = pvl.product_version_id
                   AND fo.re_contract_ver_fund_id = vf.re_contract_ver_fund_id
                   AND plo.product_line_id = fo.product_line_id
                   AND ph.fund_id = vf.fund_id
                   AND nvl(pcu.is_reinsurer_failure, 0) = 0
                   AND a.p_policy_id = par_policy_id
                   AND fo.re_contract_ver_id = par_re_ver_contract_id
                   AND s.as_assured_id = a.as_asset_id
                   AND p.policy_id = pi.policy_id
                      /** О8 Исправлено в соответствии с замечанием О8 из файла анализа кода О8 **/
                   AND pc.status_hist_id != 3
                   AND a.status_hist_id != 3)
    LOOP
      --Проверяем коэффициенты
      n_check_coef := n_check_coef + Check_koef(cur.s_coef_m
                                               ,cur.s_coef_nm
                                               ,cur.k_coef_m
                                               ,cur.k_coef_nm
                                               ,cur.fund_id
                                               ,cur.product_id
                                               ,cur.product_line_id
                                               ,par_re_ver_contract_id);
      --Проверяем лимит
      n_check_limit := n_check_limit + check_limit(cur.ins_amount
                                                  ,cur.fund_id
                                                  ,cur.product_id
                                                  ,cur.product_line_id
                                                  ,par_re_ver_contract_id
                                                  ,cur.contact_id);
      --Совокупный лимит
      n_check_limit_contract := n_check_limit_contract +
                                Check_limit_contract(cur.policy_id
                                                    ,cur.product_id
                                                    ,cur.product_line_id
                                                    ,par_re_ver_contract_id
                                                    ,cur.plo_id
                                                    ,cur.fund_id
                                                    ,cur.assured_contact_id);
      --Количество застрахованных
      n_check_assured := n_check_assured + Check_assured(cur.assured_count, par_re_ver_contract_id);
      --Общий лимит
      n_check_total_limit := n_check_total_limit +
                             Check_total_limit(cur.total_amount, cur.fund_id, par_re_ver_contract_id);
    
      n_rowcount := n_rowcount + 1;
    END LOOP;
    -- Делаем разбор результатов
    IF n_rowcount > 0
    THEN
      IF n_check_coef = n_rowcount
         AND n_check_limit = n_rowcount
         AND n_check_limit_contract = n_rowcount
         AND n_check_assured = n_rowcount
         AND n_check_total_limit = n_rowcount
      THEN
        res := 0; --Если все программамы удовлетворяют условиям, то это Облигатор
      ELSIF n_check_coef = n_rowcount
            AND n_check_limit_contract = n_rowcount
            AND (n_check_limit < n_rowcount OR n_check_assured < n_rowcount OR
            n_check_total_limit < n_rowcount)
      THEN
        res := 1; --Облигатор нестандарт
      ELSIF (n_check_coef < n_rowcount OR n_check_limit_contract < n_rowcount
            -- or n_check_limit < n_rowcount  --
            )
      THEN
        res := 2; --Факультатив
      END IF;
    END IF;
  
    /* В некоторых договорах перестрахования нет необходимости выделять нестандартные риски
       из факультативного типа перестрахования, т.е. выделять особое значение признака перестрахования
       "Облигатор (не стандарт)" из значения "Факультатив"
    */
    IF v_flg_no_standart_type = 1
       AND res = 1
    THEN
      res := 2;
    END IF;
  
    RETURN res;
  END Check_policy_type;

  /* Процедура заполняет Перестраховщика на закладке Перестрахование договора страхования при смене статуса
  par_policy_id  - ID договора
  */
  PROCEDURE fill_policy_reins(par_policy_id IN NUMBER) IS
    v_fund_id          NUMBER;
    v_bordero_type     NUMBER;
    v_old_bordero_type NUMBER;
    v_as_assured_re_id NUMBER;
  BEGIN
    --Определяем валюту договора
    SELECT ph.fund_id
      INTO v_fund_id
      FROM p_pol_header ph
          ,p_policy     p
     WHERE p.pol_header_id = ph.policy_header_id
       AND p.policy_id = par_policy_id;
  
    -- select ph.fund_id into p_fund_id
    -- from p_pol_header ph where ph.policy_header_id=par_pol_header_id;
  
    --Ищем договора перестрахования в статусе Действующий
    FOR r IN (SELECT DISTINCT mc.re_main_contract_id
                             ,mc.last_version_id
                             ,mc.reinsurer_id
                FROM re_main_contract     mc
                    ,re_contract_version  cv
                    ,re_contract_ver_fund cvf
                    ,document             d
                    , /*doc_status ds,*/doc_status_ref       dsr
               WHERE d.document_id = cv.re_contract_version_id
                 AND cv.re_main_contract_id = mc.re_main_contract_id
                 AND cvf.re_contract_version_id = cv.re_contract_version_id
                    --            and ds.document_id=d.document_id
                 AND dsr.doc_status_ref_id = d.doc_status_ref_id
                 AND upper(dsr.brief) = 'CURRENT'
                 AND cvf.fund_id = v_fund_id)
    LOOP
    
      --Определяем тип перестрахования
      v_bordero_type := Check_policy_type(r.last_version_id, par_policy_id);
    
      IF v_bordero_type >= 0
      THEN
        --Если в версии есть риски, попадающие под перестрахование, то добавляем перестраховщика
        --  pkg_re_insurance.del_assured(par_policy_id);
        --Проверяем наличие в том договора перестраховщика с таким же типом перестрахования
        BEGIN
          SELECT ar.as_assured_re_id
                ,ar.re_bordero_type_id
            INTO v_as_assured_re_id
                ,v_old_bordero_type
            FROM as_assured_re ar
           WHERE ar.p_policy_id = par_policy_id
             AND ar.p_re_id = r.reinsurer_id
             AND ar.re_contract_version_id = r.last_version_id;
          -- Байтин А.
          -- Заявка №249376
          --IF p_old_bordero_type < p_bordero_type
          --если есть перестраховщик с меньшим типом бордеро, то меняем тип бордеро
          UPDATE as_assured_re ar
             SET ar.re_bordero_type_id = v_bordero_type
           WHERE ar.as_assured_re_id = v_as_assured_re_id;
          --END IF;
        EXCEPTION
          WHEN no_data_found THEN
            SELECT sq_as_assured_re.nextval INTO v_as_assured_re_id FROM dual;
            INSERT INTO as_assured_re
              (as_assured_re_id, p_policy_id, p_re_id, re_bordero_type_id, re_contract_version_id)
            VALUES
              (v_as_assured_re_id, par_policy_id, r.reinsurer_id, v_bordero_type, r.last_version_id);
        END;
      END IF;
    END LOOP;
  
  END fill_policy_reins;

  PROCEDURE del_assured(par_policy_id IN NUMBER) AS
  BEGIN
    DELETE FROM as_assured_re r
     WHERE r.p_policy_id IN (SELECT p.policy_id FROM p_policy p WHERE p.policy_id = par_policy_id);
  
  END del_assured;

  --Процедура проверяет наличие номера перестраховщика в облигаторном типе перестрахования
  PROCEDURE check_reins_number(par_policy_id IN NUMBER) AS
  BEGIN
    FOR cur IN (SELECT *
                  FROM as_assured_re ar
                 WHERE ar.p_policy_id = par_policy_id
                   AND ar.re_bordero_type_id = 2)
    LOOP
      IF TRIM(cur.num_re) IS NULL
      THEN
        raise_application_error('-20001'
                               ,'Ошибка проверки номера перестраховщика');
      END IF;
    END LOOP;
  
  END check_reins_number;

  --Процедура загрузки тарифов в настраиваемую функцию
  PROCEDURE CreateFunc
  (
    func_name  IN VARCHAR2
   ,func_brief IN VARCHAR2
  ) AS
    func_id NUMBER;
  BEGIN
    SELECT sq_t_prod_coef_type.nextval INTO func_id FROM dual;
    INSERT INTO t_prod_coef_type
      (t_prod_coef_type_id
      ,NAME
      ,brief
      ,t_prod_coef_tariff_id
      ,func_define_type_id
      ,ent_id
      ,factor_1
      ,factor_3)
    VALUES
      (func_id, func_name, func_brief, 41, 2, 641, 1242, 1008);
    -- values(func_id,func_name, func_brief, 41,2,641, 1066, 2326);
  
    --Загружаем значения из таблицы TMP
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, ent_id, criteria_1, criteria_3, val)
      (SELECT func_id
             ,642
             ,tmp.age
             ,tmp.pol
             ,tmp.val
         FROM tmp);
  
  END;
  /* Функция возвращает актуальную версию договора по дате
  par_pol_header_id - ID заголовка договора
  par_date - Дата начала действия бордеро
  */
  FUNCTION Check_policy
  (
    par_pol_header_id IN NUMBER
   ,par_date          IN DATE
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
  
    res := Policy_Effective_On_Date(par_pol_header_id, par_date);
  
    /* сейчас функция выдает самую старшую версию, которая начинается после */
    --  select max(p.policy_id) into res
    --  from p_policy p, document d
    --  where d.document_id=p.policy_id
    --  and p.pol_header_id=par_pol_header_id
    --  and p.start_date >= par_date;
    /*
    select max(p.policy_id) into res
    from p_policy p, document d
    where d.document_id=p.policy_id
    and p.pol_header_id=par_pol_header_id
    and p.start_date <= par_date;
    */
  
    RETURN res;
  
  END Check_policy;

  /*
    Байтин А.
  */
  FUNCTION get_Axn_i
  (
    par_x        IN NUMBER
   ,par_n        IN NUMBER
   ,par_sex      IN VARCHAR2
   ,par_k_koeff  IN NUMBER DEFAULT 0
   ,par_s_koeff  IN NUMBER DEFAULT 0
   ,par_table_id IN NUMBER
   ,par_i        IN t_number_type
  ) RETURN t_number_type IS
    vt_return t_number_type := t_number_type();
  BEGIN
    vt_return.extend(par_i.count);
    FOR v_idx IN par_i.first .. par_i.last
    LOOP
      vt_return(v_idx) := pkg_amath.Axn(x          => par_x
                                       ,n          => par_n
                                       ,p_Sex      => par_sex
                                       ,K_koeff    => par_k_koeff
                                       ,S_koeff    => par_s_koeff
                                       ,p_table_id => par_table_id
                                       ,p_i        => par_i(v_idx));
    END LOOP;
    RETURN vt_return;
  END get_Axn_i;

  /*
  Function Axn_i (x in number, n in number, p_Sex in varchar2
               ,K_koeff in number default 0, S_koeff in number default 0, p_table_id in number, p_i in number) return number is
    Result number;
    p_xk number;
    j number;
    v number;
  begin
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    v := 1 / (1 + p_i);
    Result := 0;
   --значение p(x, 0)
    p_xk := 1;
    For j in 0 .. (n - 1) loop
      Result := Result + p_xk * qx (x + j, p_sex, K_koeff, S_koeff, p_table_id) * power (v , (j + 1));
   -- значение p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px (x + j, p_sex, K_koeff, S_koeff, p_table_id);
    end loop;
  -- now Result = Ax1n
  -- Set Axn = Ax1n + v^n* p(x, n)
    result := Result + power (v , n) * p_xk;
    return result;
  End Axn_i;
  */

  PROCEDURE fill_all_policy AS
  BEGIN
    FOR cur IN (SELECT p.policy_id
                  FROM p_policy p
                 WHERE
                --     p.pol_header_id in (819822))
                --     p.pol_header_id in (27976323,26333894)) -- убытки
                --     p.pol_header_id in (27976323,29343347,19525355,20456139,19322737,19314360,19525355,29840242)) -- актуарный резерв
                --     p.pol_header_id in (29343347,19525355,19314360,19322737,27976323,26333894,29840242,29108692,20456139,20851004)
                --p.pol_header_id in (20638634,18224031) -- расторжения
                --p.pol_header_id in (35767034)) -- пример Гейнц
                --p.pol_header_id in(38686963)) -- пример Гейнц
                --p.pol_header_id in (38533606)) -- пример Гейнц
                --p.pol_header_id in (20334123)) -- единовременная периодичности (краткосрочный договор)
                --p.pol_header_id in (819822)) -- единовременная периодичность (долгосрочный договор с актуарным резервом) + тестирование перестраховочной комиссии 2
                --  p.pol_header_id in (11037612)) --тестирование перестраховочной комиссии
                --  p.pol_header_id in (16051313)) --тестирование возврата перестраховочной комиссии 2
                --  p.pol_header_id in (12880696)) --тестирование возврата перестраховочной комиссии
                --  p.pol_header_id in (796633)) --тестирование возврата перестраховочной комиссии 1
                
                -- Список договоров страхования в соответствии с test-case
                -- Предварительное тестирование
                -- p.pol_header_id in (31573923,31575959,30289721))
                -- 1 Фаза
                -- Тестирование андеррайтинга
                --p.pol_header_id in (29108692,36069105,32706197,27936920,27366867,7694026,36071097,30306073,36067375,36069204,30013287,27444561,7575132))
                -- Тестирование бордеро
                --p.pol_header_id in (27976323,26333894,5919474,28546269,19322737,28887327,19314360,19525355,29840242,29343347,29108692,10645479,20456139,20851004))
                
                -- 2 Фаза
                -- корпоративные
                -- p.pol_header_id in (25060339))
                
                -- индивидуальные
                --p.pol_header_id in (819822))
                
                --p.pol_header_id in (31535766)
                --p.pol_header_id in (29579050,62915499)) -- Примеры Поляковского
                --p.pol_header_id in (28838787,39215031)) -- Примеры убытков Поляковского
                --p.pol_header_id in (30173129,38734675)) -- Примеры расторжений Поляковского
                --p.pol_header_id in (37006626)) -- Пример кредитного индивидуального договора
                --p.pol_header_id in (29579050)) -- Примеры Поляковского
                -- Тестовая вставка 08052013
                --p.pol_header_id in (29883970)
                --p.pol_header_id in (38927986)
                --p.pol_header_id in (37408642) -- Семейный депозит Нетто-ставка ежегодная периодичность
                --p.pol_header_id in (8591851) -- Семейный депозит единовременный
                --p.pol_header_id in (20633255) -- пример, упавший в log
                --p.pol_header_id in (27403901,28474307) -- Актуарный резерв FAMDEP
                --p.pol_header_id in (20456139) -- Актуарный резерв FAMDEP (пример рассчитанный Решетняков в test-case)
                --                 p.pol_header_id IN (33044523) -- Пример ошибки ORA-01841
                 p.pol_header_id IN (57077739))
    
    LOOP
      -- заполнение признака перестрахования происходит по всем перестраховщикам сразу
      -- в разрезе версий договоров страхования
    
      fill_policy_reins(cur.policy_id);
    END LOOP;
  END;

  FUNCTION Policy_Effective_On_Date
  (
    par_pol_header_id IN NUMBER
   ,Effect_Date       IN DATE
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
  
    -- Новая версия процедуры
    SELECT MAX(pp.policy_id)
      INTO res
      FROM p_policy       pp
          ,document       d
          ,doc_status     ds
          ,doc_status_ref dsr
    -- ** #П59_1          ,p_pol_header   pph -- ** #П59
    
     WHERE pp.pol_header_id = par_pol_header_id
          -- ** #П59_1       AND pph.policy_header_id = par_pol_header_id -- ** #П59
          
       AND d.document_id = pp.policy_id
          -- Version effective interval contains Effect_Date
       AND pp.start_date <= Effect_Date
       AND pp.end_date >= Effect_Date
       AND (( -- Если статус версии на Effect_Date определен
            EXISTS (SELECT NULL
                       FROM doc_status ds_effect_date1
                      WHERE ds_effect_date1.document_id = pp.policy_id
                        AND ds_effect_date1.start_date <= Effect_Date)
           -- Status on Effect_Date
            AND ds.doc_status_id =
            (SELECT MAX(ds_effect_date.doc_status_id)
                           FROM doc_status ds_effect_date
                          WHERE ds_effect_date.document_id = pp.policy_id
                            AND ds_effect_date.start_date <= Effect_Date) AND
            ds.document_id = pp.policy_id AND ds.doc_status_ref_id = dsr.doc_status_ref_id AND
            dsr.brief NOT IN ('CANCEL', 'QUIT') -- Отменен, Прекращен
           ) OR ( -- Если статус версии на Effect_Date не определен
            NOT EXISTS
            (SELECT NULL
                     FROM doc_status ds_effect_date1
                    WHERE ds_effect_date1.document_id = pp.policy_id
                      AND ds_effect_date1.start_date <= Effect_Date) AND
            ds.doc_status_ref_id = dsr.doc_status_ref_id AND ds.doc_status_id = d.doc_status_id -- текущий статус версии
           ))
          
          -- History contains conclusion
       AND (EXISTS (SELECT NULL
                      FROM doc_status     ds_conc
                          ,doc_status_ref dsr_conc
                     WHERE ds_conc.document_id = pp.policy_id
                       AND ds_conc.doc_status_ref_id = dsr_conc.doc_status_ref_id
                       AND dsr_conc.brief IN ('CONCLUDED', 'CURRENT') -- Договор подписан, Действующий
                    ) OR
           -- ** #П59 По продуктам, в которых по каким-то причинам действующие договоры страхования
           -- ** #П59 не имеют переход в статус Договор подписан, Действующий
           -- ** #П59 ищем перевод в статус 'Передано Агенту'
           -- ** #П59 В этих договорах необходимо актуализировать историю по статусам или оставлять эту заплатку
            (EXISTS (SELECT NULL
                              FROM doc_status ds_conc
                            -- ** #П59_1                           ,doc_status_ref dsr_conc
                             WHERE ds_conc.document_id = pp.policy_id
                                  -- ** #П59_1                        AND ds_conc.doc_status_ref_id = dsr_conc.doc_status_ref_id
                               AND ds_conc.doc_status_ref_id = 89 -- ** #П59_1 'Передано Агенту'
                                  -- ** #П59_1                        AND dsr_conc.brief = 'PASSED_TO_AGENT' -- 'Передано Агенту'
                               AND ds_conc.src_doc_status_ref_id = 16 -- #П59_1 Из 'Проект' 
                            )
            -- ** #П59 Это продукты для перестраховщиков HANN_IND, GRS_IND
            -- ** #П59_1             AND pph.product_id IN (46758, 46761, 46762, 46763, 43620, 43622, 45176, 45177))
            ));
  
    /** Старая версия процедуры
    select max(pp.policy_id)
    into res
    from p_policy pp,
         doc_status ds,
         doc_status_ref dsr
    
    where pp.pol_header_id = par_pol_header_id
    
    -- Version effective interval contains Effect_Date
    and pp.start_date <= Effect_Date
    and pp.end_date >= Effect_Date
    
    -- Status on Effect_Date
    and ds.doc_status_id = (
                            select max(ds_effect_date.doc_status_id)
                            from doc_status ds_effect_date
                            where ds_effect_date.document_id = pp.policy_id
                            and ds_effect_date.start_date <= Effect_Date
                           )
    and ds.document_id = pp.policy_id
    and ds.doc_status_ref_id = dsr.doc_status_ref_id
    and (dsr.brief not in ('CANCEL','QUIT') or dsr.brief in ('CONCLUDED','CURRENT'))
    
    -- History contains conclusion
    and (
        select count(*)
        from doc_status ds_conc,
        doc_status_ref dsr_conc
        where ds_conc.document_id = pp.policy_id
        and ds_conc.doc_status_ref_id = dsr_conc.doc_status_ref_id
        and dsr_conc.brief in ('CONCLUDED','CURRENT') -- Договор подписан, Действующий
        ) > 0;
    **/
    RETURN res;
  
  END Policy_Effective_On_Date;

  /*
     Байтин А.
     Функция расчета нетто-тарифа для вычисления актуарного резерва
  */
  FUNCTION get_netto_tariff_old
  (
    par_p_cover_id       NUMBER
   ,par_version_num      NUMBER
   ,par_pol_header_id    NUMBER
   ,par_prod_line_opt_id NUMBER
   ,par_asset_header_id  NUMBER
  ) RETURN NUMBER IS
    v_p_cover_id NUMBER;
  
  BEGIN
    -- Находим первый включенный риск
    BEGIN
      SELECT pc.p_cover_id
        INTO v_p_cover_id
        FROM p_policy pp
            ,as_asset se
            ,p_cover  pc
       WHERE pp.pol_header_id = par_pol_header_id
         AND pp.version_num <= par_version_num
         AND pp.policy_id = se.p_policy_id
         AND se.p_asset_header_id = par_asset_header_id
         AND se.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = par_prod_line_opt_id
            --and pc.status_hist_id        = 1; -- NEW
         AND pp.version_num IN
             (SELECT MIN(pp_.version_num)
                FROM p_policy pp_
                    ,as_asset se_
                    ,p_cover  pc_
               WHERE pp_.pol_header_id = par_pol_header_id
                 AND pp_.version_num <= par_version_num
                 AND pp_.policy_id = se_.p_policy_id
                 AND se_.p_asset_header_id = par_asset_header_id
                 AND se_.as_asset_id = pc_.as_asset_id
                 AND pc_.t_prod_line_option_id = par_prod_line_opt_id
                 AND EXISTS (SELECT NULL
                        FROM doc_status ds
                       WHERE ds.document_id = pp_.policy_id
                         AND ds.doc_status_ref_id IN (91 -- CONCLUDED - Договор подписан
                                                     ,2 -- CURRENT - Действующий
                                                      )));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Невозможно определить элемент покрытия в get_netto_tariff для p_cover_id "' ||
                                to_char(par_p_cover_id) || '"');
    END;
  
    -- Запуск процедуры расчета нетто-тарифа на этом риске.
    RETURN pkg_cover.calc_tariff_netto(p_p_cover_id => v_p_cover_id);
  
  END get_netto_tariff_old;

  -- О24
  FUNCTION get_netto_tariff
  (
    par_p_cover_id        NUMBER
   ,par_version_num       NUMBER
   ,par_pol_header_id     NUMBER
   ,par_prod_line_opt_id  NUMBER
   ,par_asset_header_id   NUMBER
   ,par_msfo_brief        VARCHAR2
   ,par_header_start_date DATE
   ,par_date_of_birth     DATE
   ,par_sex               VARCHAR2
   ,par_deathrate_id      NUMBER
   ,par_norm_rate         NUMBER
  ) RETURN NUMBER IS
    v_p_cover_id       NUMBER;
    v_x                NUMBER; -- возраст застрахованного на начало покрытия
    v_n                NUMBER; -- срок по покрытию
    v_cover_start_date DATE;
    v_cover_end_date   DATE;
    v_k_coef           NUMBER;
    v_s_coef           NUMBER;
    v_A1_xn            NUMBER;
    v_Axn              NUMBER;
    v_a_x_n            NUMBER;
  
    v_result NUMBER;
  BEGIN
    -- Находим первый включенный риск
    BEGIN
      SELECT pc.p_cover_id
            ,pc.start_date
            ,pc.end_date
            ,pc.k_coef
            ,pc.s_coef
        INTO v_p_cover_id
            ,v_cover_start_date
            ,v_cover_end_date
            ,v_k_coef
            ,v_s_coef
        FROM p_policy pp
            ,as_asset se
            ,p_cover  pc
       WHERE pp.pol_header_id = par_pol_header_id
         AND pp.version_num <= par_version_num
         AND pp.policy_id = se.p_policy_id
         AND se.p_asset_header_id = par_asset_header_id
         AND se.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = par_prod_line_opt_id
            --and pc.status_hist_id        = 1; -- NEW
         AND pp.version_num IN
             (SELECT MIN(pp_.version_num)
                FROM p_policy pp_
                    ,as_asset se_
                    ,p_cover  pc_
               WHERE pp_.pol_header_id = par_pol_header_id
                 AND pp_.version_num <= par_version_num
                 AND pp_.policy_id = se_.p_policy_id
                 AND se_.p_asset_header_id = par_asset_header_id
                 AND se_.as_asset_id = pc_.as_asset_id
                 AND pc_.t_prod_line_option_id = par_prod_line_opt_id
                 AND EXISTS (SELECT NULL
                        FROM doc_status ds
                       WHERE ds.document_id = pp_.policy_id
                         AND ds.doc_status_ref_id IN (91 -- CONCLUDED - Договор подписан
                                                     ,2 -- CURRENT - Действующий
                                                      )));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Невозможно определить элемент покрытия в get_netto_tariff для p_cover_id "' ||
                                to_char(par_p_cover_id) || '"');
    END;
  
    -- Запуск процедуры расчета нетто-тарифа на этом риске.
    -- Также как вычисляется в Borlas
    --    return pkg_cover.calc_tariff_netto(p_p_cover_id => v_p_cover_id);
  
    -- Вычисление по формулам
    /*select pc.start_date, pc.end_date, pc.k_coef, pc.s_coef
    into v_cover_start_date, v_cover_end_date, v_k_coef, v_s_coef
    from p_cover pc
    where pc.p_cover_id = v_p_cover_id;*/
  
    v_n := CEIL(MONTHS_BETWEEN(trunc(v_cover_end_date) + 1, trunc(v_cover_start_date)) / 12);
    v_x := trunc(MONTHS_BETWEEN(get_anniversary_date(v_cover_start_date, par_header_start_date, 2)
                               ,par_date_of_birth) / 12);
    IF par_msfo_brief IN ('DD', 'TERM')
    THEN
      v_A1_xn  := pkg_AMATH.Ax1n(v_x
                                ,v_n
                                ,par_sex
                                ,v_k_coef
                                ,v_s_coef
                                ,par_deathrate_id
                                ,par_norm_rate);
      v_a_x_n  := pkg_AMATH.a_xn(v_x
                                ,v_n
                                ,par_sex
                                ,v_k_coef
                                ,v_s_coef
                                ,1
                                ,par_deathrate_id
                                ,par_norm_rate);
      v_result := v_A1_xn / v_a_x_n;
    ELSIF par_msfo_brief = 'END'
    THEN
      v_Axn    := pkg_AMATH.Axn(v_x, v_n, par_sex, v_k_coef, v_s_coef, par_deathrate_id, par_norm_rate);
      v_a_x_n  := pkg_AMATH.a_xn(v_x
                                ,v_n
                                ,par_sex
                                ,v_k_coef
                                ,v_s_coef
                                ,1
                                ,par_deathrate_id
                                ,par_norm_rate);
      v_result := v_Axn / v_a_x_n;
    ELSIF par_msfo_brief = 'FAMDEP'
    THEN
      -- FAMDEP1 для программы FAMDEP на программе в справочнике программ в продукте
      -- указана таблица смертности Life_1997, а должна быть SF_AVCR
      -- Жестко проставлен ID
      v_Axn    := pkg_AMATH.Axtnt_FAMDEP(x          => v_x
                                        ,n          => v_n
                                        ,t          => 0
                                        ,p_Sex      => par_sex
                                        ,K_koeff    => v_k_coef
                                        ,S_koeff    => v_s_coef
                                        ,p_table_id => 101 /** FAMDEP1 par_deathrate_id**/);
      v_a_x_n  := pkg_AMATH.a_xtnt_FAMDEP(v_x
                                         ,v_n
                                         ,0
                                         ,par_sex
                                         ,v_k_coef
                                         ,v_s_coef
                                         ,1
                                         ,101 /** FAMDEP1 par_deathrate_id**/);
      v_result := v_Axn / v_a_x_n;
    ELSIF par_msfo_brief = 'TERM_FIX'
    THEN
      v_a_x_n  := pkg_AMATH.a_xn(v_x
                                ,v_n
                                ,par_sex
                                ,v_k_coef
                                ,v_s_coef
                                ,1
                                ,par_deathrate_id
                                ,par_norm_rate);
      v_result := power((1 / 1 + par_norm_rate), v_n) / v_a_x_n;
      --ELSE
      -- Запуск процедуры расчета нетто-тарифа на этом риске.
      --  v_result := pkg_cover.calc_tariff_netto(p_p_cover_id => v_p_cover_id);
    END IF;
  
    RETURN v_result;
  END get_netto_tariff;
  -- Конец О24

  /*
    Байтин А.
    Возвращает долю перестраховщика
  */
  FUNCTION get_reinsurer_share
  (
    par_bordero_type_brief VARCHAR2
   ,par_bordero_id         NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    IF par_bordero_type_brief = 'БОРДЕРО_ОПЛ_УБЫТКОВ'
    THEN
      SELECT nvl(SUM(rb.re_payment_sum), 0)
        INTO v_result
        FROM re_claim            rc
            ,rel_reclaim_bordero rb
       WHERE rc.re_bordero_id = par_bordero_id
         AND rc.re_claim_id = rb.re_claim_id;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END get_reinsurer_share;

  FUNCTION get_reinsurer_share_rur
  (
    par_bordero_type_brief VARCHAR2
   ,par_bordero_id         NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    IF par_bordero_type_brief = 'БОРДЕРО_ОПЛ_УБЫТКОВ'
    THEN
      SELECT nvl(SUM(rb.re_payment_sum * rb.rate), 0)
        INTO v_result
        FROM re_claim            rc
            ,rel_reclaim_bordero rb
       WHERE rc.re_bordero_id = par_bordero_id
         AND rc.re_claim_id = rb.re_claim_id;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END get_reinsurer_share_rur;

  /*
    Байтин А.
    Возвращает сумму заявленных убытков
  */
  FUNCTION get_declared_sum
  (
    par_bordero_type_brief VARCHAR2
   ,par_bordero_id         NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    IF par_bordero_type_brief = 'БОРДЕРО_ЗАЯВ_УБЫТКОВ'
    THEN
      SELECT nvl(SUM(rc.declare_sum * rc.re_payment_share), 0)
        INTO v_result
        FROM re_claim rc
       WHERE rc.re_bordero_id = par_bordero_id;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END get_declared_sum;

  /*
    Байтин А.
    Возвращает сумму заявленных убытков в рублях
  */
  FUNCTION get_declared_sum_rur
  (
    par_bordero_type_brief    VARCHAR2
   ,par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := get_declared_sum(par_bordero_type_brief, par_bordero_id);
    v_result := v_result * get_rate_on_package_end(par_re_bordero_package_id, par_fund_id);
    RETURN v_result;
  END get_declared_sum_rur;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной премии
  */
  FUNCTION get_returned_premium(par_bordero_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(bl.returned_premium), 0)
      INTO v_result
      FROM re_bordero_line bl
     WHERE bl.re_bordero_id = par_bordero_id;
  
    SELECT nvl(SUM(rc.returned_premium), 0) + v_result
      INTO v_result
      FROM rel_recover_bordero rc
     WHERE rc.re_bordero_id = par_bordero_id;
  
    RETURN v_result;
  END get_returned_premium;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной премии в рублях
  */
  FUNCTION get_returned_premium_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := get_returned_premium(par_bordero_id);
    v_result := v_result * get_rate_on_package_end(par_re_bordero_package_id, par_fund_id);
    RETURN v_result;
  END get_returned_premium_rur;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной комиссии
  */
  FUNCTION get_returned_commission(par_bordero_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(bl.returned_comission), 0)
      INTO v_result
      FROM re_bordero_line bl
     WHERE bl.re_bordero_id = par_bordero_id;
  
    SELECT nvl(SUM(rc.return_re_commission), 0) + v_result
      INTO v_result
      FROM rel_recover_bordero rc
     WHERE rc.re_bordero_id = par_bordero_id;
  
    RETURN v_result;
  END get_returned_commission;

  /*
    Байтин А.
    Возвращает сумму возвратов перестраховочной комиссии в рублях
  */
  FUNCTION get_returned_commission_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := get_returned_commission(par_bordero_id);
    v_result := v_result * get_rate_on_package_end(par_re_bordero_package_id, par_fund_id);
  
    RETURN v_result;
  END get_returned_commission_rur;

  /*
    Байтин А.
    Возвращает сумму перестраховочной комиссии
  */
  FUNCTION get_commission(par_bordero_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(bl.re_comision), 0)
      INTO v_result
      FROM re_bordero_line bl
     WHERE bl.re_bordero_id = par_bordero_id;
  
    RETURN v_result;
  END get_commission;
  /*
    Байтин А.
    Возвращает сумму перестраховочной комиссии в рублях
  */

  FUNCTION get_commission_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := get_commission(par_bordero_id);
    v_result := v_result * get_rate_on_package_end(par_re_bordero_package_id, par_fund_id);
    RETURN v_result;
  END get_commission_rur;

  /*
    Байтин А.
    Возвращает сумму перестраховочной премии
  */
  FUNCTION get_re_premium(par_bordero_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(bl.period_reinsurer_premium), 0)
      INTO v_result
      FROM re_bordero_line bl
     WHERE bl.re_bordero_id = par_bordero_id;
  
    RETURN v_result;
  END get_re_premium;

  /*
    Байтин А.
    Возвращает сумму перестраховочной премии в рублях
  */

  FUNCTION get_re_premium_rur
  (
    par_bordero_id            NUMBER
   ,par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := get_re_premium(par_bordero_id);
    v_result := v_result * get_rate_on_package_end(par_re_bordero_package_id, par_fund_id);
    RETURN v_result;
  END get_re_premium_rur;

  /*
    Байтин А.
    Возвращает сумму в рублях на дату окончания пакета бордеро
  */
  FUNCTION get_rate_on_package_end
  (
    par_re_bordero_package_id NUMBER
   ,par_fund_id               NUMBER
  ) RETURN NUMBER IS
    v_rate NUMBER;
  BEGIN
    SELECT acc_new.get_rate_by_id(1, par_fund_id, re.end_date)
      INTO v_rate
      FROM re_bordero_package re
     WHERE re.re_bordero_package_id = par_re_bordero_package_id;
  
    RETURN v_rate;
  END get_rate_on_package_end;

  /*
    Байтин А.
    Возвращает сумму пакета бордеро
  */
  FUNCTION get_bordero_package_sum(par_re_bordero_package_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT SUM(pkg_re_insurance.get_re_premium_rur(rb.re_bordero_id
                                                  ,rb.RE_BORDERO_PACKAGE_ID
                                                  ,rb.FUND_ID) +
               pkg_re_insurance.get_returned_commission_rur(rb.re_bordero_id
                                                           ,rb.RE_BORDERO_PACKAGE_ID
                                                           ,rb.FUND_ID)) -
           SUM(pkg_re_insurance.get_reinsurer_share_rur(rbt.brief, rb.re_bordero_id) +
               (pkg_re_insurance.get_returned_premium_rur(rb.re_bordero_id
                                                         ,rb.re_bordero_package_id
                                                         ,rb.fund_id) +
                pkg_re_insurance.get_commission_rur(rb.re_bordero_id
                                                   ,rb.RE_BORDERO_PACKAGE_ID
                                                   ,rb.FUND_ID)))
      INTO v_result
      FROM re_bordero      rb
          ,re_bordero_type rbt
     WHERE rb.re_bordero_package_id = par_re_bordero_package_id
       AND rb.re_bordero_type_id = rbt.re_bordero_type_id;
  
    RETURN v_result;
  END get_bordero_package_sum;

  /*
    Байтин А.
    Проверка, можно ли удалять версию ДС
  */
  FUNCTION can_delete_policy(par_policy_id NUMBER) RETURN NUMBER IS
    v_result NUMBER(1);
  BEGIN
    SELECT decode(COUNT(*), 0, 1, 0)
      INTO v_result
      FROM dual
     WHERE EXISTS (SELECT NULL FROM re_bordero_line rbl WHERE rbl.policy_id = par_policy_id);
    RETURN v_result;
  END can_delete_policy;

BEGIN
  BEGIN
    SELECT dr.deathrate_id
      INTO gv_deatrate_wop_id
      FROM deathrate dr
     WHERE dr.brief = gc_deatrate_wop_brief;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001
                             ,'Не найдена запись справочника таблицы смертности "Таблица смертности для риска освобождение"');
  END;
  BEGIN
    SELECT dr.deathrate_id
      INTO gv_deatrate_pwop_id
      FROM deathrate dr
     WHERE dr.brief = gc_deatrate_pwop_brief;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001
                             ,'Не найдена запись справочника таблицы смертности "Таблица смертности для риска защита"');
  END;

END pkg_re_insurance;
/
