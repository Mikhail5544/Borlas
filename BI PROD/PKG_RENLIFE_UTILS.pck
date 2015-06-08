CREATE OR REPLACE PACKAGE "PKG_RENLIFE_UTILS" IS
  /*
    -- Author  : ALEXEY.KATKEVICH
    -- Created : 03.04.2008 18:15:50
    -- Purpose : Всякие полезности
  
    -- Public type declarations
    TYPE <TypeName> IS <Datatype>;
  
    -- Public constant declarations
    <ConstantName> CONSTANT <Datatype> := <VALUE>;
  
    -- Public variable declarations
    <VariableName> <Datatype>;
  */

  TYPE r_tmpaccum IS RECORD(
     policy_header_id NUMBER(4)
    ,value_amount     NUMBER
    ,pol_num          VARCHAR2(25)
    ,label            VARCHAR2(25)
    ,koef             NUMBER
    ,idx_accumsum     NUMBER);
  --TYPE tbl_tmpaccum IS TABLE OF r_tmpaccum INDEX BY BINARY_INTEGER;
  TYPE tbl_tmpaccum IS TABLE OF r_tmpaccum;

  v_some VARCHAR2(255);

  /*--БСО
  v_series  number;
  v_current number :=0;
  v_max     number :=0; */

  --FUNCTION set_tmptable_accum (p_policy_header_id number) RETURN tbl_tmpaccum pipelined;

  PROCEDURE tmp_life_nonlife_agency
  (
    p_date_begin DATE
   ,p_date_end   DATE
  );
  PROCEDURE input_data;
  PROCEDURE exec_sql(p_str VARCHAR2);
  FUNCTION run_tmp_trans_table
  (
    p_insurer     VARCHAR2
   ,p_pol_num     VARCHAR2
   ,p_version_num NUMBER
  ) RETURN NUMBER;
  FUNCTION get_fee_sum(p_policy NUMBER) RETURN NUMBER;
  FUNCTION ret_ser_policy(p_policy_id NUMBER) RETURN VARCHAR2;
  FUNCTION ret_osn_progr(p_policy_id NUMBER) RETURN VARCHAR2;
  FUNCTION ret_sod_claim(p_claim_header NUMBER) RETURN DATE;
  FUNCTION ret_amount_claim
  (
    p_event_id     NUMBER
   ,p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER;
  FUNCTION ret_amount_active
  (
    p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER;
  PROCEDURE tmp_trans_table
  (
    p_insurer     VARCHAR2
   ,p_pol_num     VARCHAR2
   ,p_version_num NUMBER
  );
  PROCEDURE set_tmptable_surr(p_policy_header_id NUMBER);
  PROCEDURE set_tmptable_event(p_event NUMBER);
  PROCEDURE set_tmptable_event_wop
  (
    p_event NUMBER
   ,p_claim NUMBER
  );
  PROCEDURE set_tmptable_vipl(p_event NUMBER);
  PROCEDURE set_tmptable_vipl_wop
  (
    p_event NUMBER
   ,p_claim NUMBER
  );
  PROCEDURE set_tmptable_comvipl(p_event NUMBER);
  PROCEDURE set_tmptable_ben(p_as_asset NUMBER);
  PROCEDURE set_tmptable_agent(p_agroll_id NUMBER);
  PROCEDURE set_tmptable_agento(p_agroll_id NUMBER);
  PROCEDURE set_tmptable_paym(p_event_id NUMBER);
  FUNCTION get_plan_sgp
  (
    p_insurer VARCHAR2
   ,dt        VARCHAR2
   ,mn        NUMBER
   ,sg        NUMBER
  ) RETURN NUMBER;
  PROCEDURE set_tmptable_zakl(p_agroll_id NUMBER);
  PROCEDURE set_tmptable_dzakl(p_agroll_id NUMBER);
  PROCEDURE create_mv(p_view VARCHAR2);
  FUNCTION f_param
  (
    p_func  VARCHAR2
   ,p_param NUMBER
  ) RETURN VARCHAR2;
  FUNCTION f_param
  (
    p_func   VARCHAR2
   ,p_param1 NUMBER
   ,p_param2 NUMBER
  ) RETURN VARCHAR2;
  PROCEDURE set_tmptable_accum(p_policy_header_id NUMBER);

  --Функиця возвращает описание для работника по его контакту
  --Подробнее в BODY
  FUNCTION get_emp_description
  (
    par_contact_id IN NUMBER
   ,par_date       IN DATE
   ,par_descr_type IN VARCHAR
  ) RETURN VARCHAR2;

  PROCEDURE tmp_log_writer(any_varchar IN VARCHAR2);

  PROCEDURE time_elapsed
  (
    any_varchar    VARCHAR2
   ,par_sid        NUMBER
   ,possible_count NUMBER DEFAULT NULL
  );

  FUNCTION ins_sum_general_prog(par_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION ins_sum_general_prog_pla
  (
    par_p_cover_id NUMBER
   ,par_fund_id    NUMBER
  ) RETURN NUMBER;

  FUNCTION fract_koeff
  (
    par_year_int NUMBER
   ,par_year_mod NUMBER
   ,par_koeff    NUMBER
   ,par_pay_term NUMBER
  ) RETURN NUMBER;

  FUNCTION fla_tariff_calc
  (
    par_end_tariff  NUMBER
   ,par_term_tariff NUMBER
  ) RETURN NUMBER;

  FUNCTION simple_brutto_tariff(par_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION simple_netto_tariff(par_p_cover_id NUMBER) RETURN NUMBER;

  PROCEDURE trans_time_shift
  (
    par_policy_header_id NUMBER
   ,par_policy_id        NUMBER DEFAULT NULL
   ,par_date             DATE DEFAULT NULL
  );

  FUNCTION val_divide_1000(par_value NUMBER) RETURN NUMBER;

  PROCEDURE add_policy_contact
  (
    par_policy_id      NUMBER
   ,par_contact_id     NUMBER
   ,par_pol_role_brief VARCHAR2
  );

  PROCEDURE add_contact_role
  (
    par_contact_id         NUMBER
   ,par_contact_role_brief VARCHAR2
  );

  FUNCTION add_contact_rel
  (
    par_contact_from NUMBER
   ,par_contact_to   NUMBER
   ,par_rel_type_id  NUMBER
  ) RETURN NUMBER;

  PROCEDURE add_asset_beneficiary
  (
    par_as_asset_id            NUMBER
   ,par_beneficiary_id         NUMBER
   ,par_beneficiary_role_brief VARCHAR2 DEFAULT NULL
   ,par_as_asset_id_role_brief VARCHAR2 DEFAULT NULL
   ,par_currency_id            NUMBER DEFAULT 122
   ,par_value                  NUMBER DEFAULT 100
   ,par_value_type             NUMBER DEFAULT 1
   ,par_comment                VARCHAR2 DEFAULT NULL
  );

  PROCEDURE add_policy_agent
  (
    par_pol_header   NUMBER
   ,par_agent_header NUMBER
   ,par_start_date   DATE
   ,par_percent      NUMBER
  );

  FUNCTION policy_insert
  (
    p_product_id           IN NUMBER
   ,p_sales_channel_id     IN NUMBER
   ,p_agency_id            IN NUMBER
   ,p_fund_id              IN NUMBER
   ,p_fund_pay_id          IN NUMBER
   ,p_confirm_condition_id IN NUMBER
   ,p_pol_ser              IN VARCHAR2
   ,p_pol_num              IN VARCHAR2
   ,p_notice_date          IN DATE
   ,p_sign_date            IN DATE
   ,p_confirm_date         IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_first_pay_date       IN DATE
   ,p_payment_term_id      IN NUMBER
   ,p_period_id            IN NUMBER
   ,p_issuer_id            IN NUMBER
   ,p_fee_payment_term     IN NUMBER
   ,p_fact_j               IN NUMBER DEFAULT NULL
   ,p_admin_cost           IN NUMBER DEFAULT 0
   ,p_is_group_flag        IN NUMBER DEFAULT 0
   , -- Байтин А. Заменил null на 0
    p_notice_num           IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id    IN NUMBER DEFAULT NULL
   ,p_region_id            IN NUMBER DEFAULT NULL
   ,p_discount_f_id        IN NUMBER DEFAULT NULL
   ,p_description          IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id   IN NUMBER DEFAULT NULL
   ,p_ph_description       IN VARCHAR2 DEFAULT NULL
   ,p_privilege_period     IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE load_bordero(vedom_id NUMBER);

  FUNCTION load_policy_from_bordero(par_row_id NUMBER) RETURN NUMBER;

  FUNCTION create_as_assured
  (
    p_pol_id        NUMBER
   ,p_contact_id    NUMBER
   ,p_work_group_id NUMBER
   ,p_asset_type    VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE set_contact_contacts
  (
    par_contact_id        NUMBER
   ,par_address           VARCHAR2
   ,par_contact_telephone VARCHAR2 DEFAULT NULL
   ,par_country_id        NUMBER DEFAULT NULL
  );

  FUNCTION create_person_contact
  (
    p_last_name       VARCHAR2
   ,p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_birth_date      DATE
   ,p_gender          VARCHAR2
   ,p_pass_ser        VARCHAR2
   ,p_pass_num        VARCHAR2
   ,p_pass_issue_date DATE
   ,p_pass_issued_by  VARCHAR2
   ,p_address         VARCHAR2 DEFAULT NULL
   ,p_contact_phone   VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION cover_amount_from_trans
  (
    p_cover_id       NUMBER
   ,p_trans_templ_id NUMBER
   ,p_start_date     DATE DEFAULT NULL
   ,p_end_date       DATE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION policy_amount_from_trans
  (
    p_pol_id         NUMBER
   ,p_trans_templ_id NUMBER
   ,p_start_date     DATE DEFAULT NULL
   ,p_end_date       DATE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_idx_sum(p_payment_id NUMBER) RETURN NUMBER;

  FUNCTION get_indexing_summ
  (
    par_payment_id NUMBER
   ,par_tplo_id    NUMBER DEFAULT -1
   ,par_return     NUMBER DEFAULT 1
  ) RETURN NUMBER;

  FUNCTION get_contact_doc
  (
    p_contact_id NUMBER
   ,doc_attr     NUMBER
   ,doc_date     DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION get_fio_by_ag_contract_id
  (
    par_ag_contract_id NUMBER
   ,par_category_id    NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;
  /*Функция получает коэффициент для индексирования страховых сумм*/
  FUNCTION get_ins_amount_koef
  (
    p_gdv    IN NUMBER
   ,p_progr  IN NUMBER
   ,p_sex    IN NUMBER
   ,p_period IN NUMBER
  ) RETURN NUMBER;
  /*Функция получает коэффициент для индексирования выкупных сумм*/
  FUNCTION get_surr_koef
  (
    p_gdv    IN NUMBER
   ,p_progr  IN NUMBER
   ,p_sex    IN NUMBER
   ,p_period IN NUMBER
   ,p_quat   IN NUMBER
  ) RETURN NUMBER;
  FUNCTION get_ag_stat_id
  (
    par_ag_contract_header NUMBER
   ,par_date               DATE DEFAULT SYSDATE
   ,par_return             NUMBER DEFAULT 1
  ) RETURN NUMBER;

  FUNCTION get_ag_stat_brief
  (
    par_ag_contract_header NUMBER
   ,par_date               DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION get_p_ag_status_by_date
  (
    par_ag_header_id  NUMBER
   ,par_pol_header_id NUMBER
   ,par_date          DATE
  ) RETURN VARCHAR2;

  FUNCTION is_p_agent_transfered
  (
    p_ag_contract_header NUMBER
   ,p_pol_header         NUMBER
  ) RETURN NUMBER;
  FUNCTION get_p_agent_sale(par_pol_header_id NUMBER) RETURN NUMBER;
  FUNCTION get_p_agent_sale_new(par_pol_header_id NUMBER) RETURN NUMBER;
  FUNCTION get_p_agent_current
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER;
  FUNCTION get_p_agent_current_new
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER;

  FUNCTION get_ag_plan
  (
    par_ag_contract_header NUMBER
   ,par_date               DATE
   ,par_ret                NUMBER
  ) RETURN NUMBER;
  FUNCTION get_ag_cat_date
  (
    par_ag_contract_header_id NUMBER
   ,par_date                  DATE
   ,par_cat                   NUMBER
  ) RETURN DATE;

  FUNCTION temp_sav
  (
    p_policy_id  NUMBER
   ,p_agc        NUMBER
   ,p_t_lob_line NUMBER
   ,par_t        NUMBER
  ) RETURN VARCHAR2;

  FUNCTION get_amount_for_bsv
  (
    par_ag_contract_header_id NUMBER
   ,par_prog_group            NUMBER
   ,par_expire_date           NUMBER
  ) RETURN NUMBER;

  FUNCTION get_policy_main_prog
  (
    par_ag_contract_header_id NUMBER
   ,par_product_line          NUMBER
   ,par_policy_header         NUMBER
  ) RETURN NUMBER;

  FUNCTION first_unpaid
  (
    par_pol_header_id NUMBER
   ,par_ret_type      NUMBER DEFAULT 1
   ,par_date          DATE DEFAULT SYSDATE
  ) RETURN DATE;
  FUNCTION paid_unpaid
  (
    par_pol_header_id NUMBER
   ,par_ret_type      NUMBER DEFAULT 1
   ,par_date          DATE DEFAULT SYSDATE
  ) RETURN DATE;

  FUNCTION get_bso_status_brief
  (
    par_bso_id NUMBER
   ,par_date   DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  /* Байтин А.
     08.2014
     Отключена, т.к. вместо нее должна использоваться процедура из acc_new
  FUNCTION trans_storno
  (
    p_oper_id PLS_INTEGER
   ,p_date    DATE
  ) RETURN PLS_INTEGER;*/

  PROCEDURE agent_ws(par_date DATE);

  FUNCTION brutto_ins_dep(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION ins_amount_ins_dep(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION standart_ins_amount(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION brutto_sf_avcr(p_p_cover_id IN NUMBER) RETURN NUMBER;
  PROCEDURE load_damage_code
  (
    p_parent_id  PLS_INTEGER
   ,p_session_id PLS_INTEGER
  );
  FUNCTION get_first_a_policy(par_p_pol_header PLS_INTEGER) RETURN NUMBER;

  -- ishch (
  PROCEDURE load_bordero_create_temp_rec(par_session_id NUMBER);
  PROCEDURE load_bordero_blob_to_table(par_session_id NUMBER);
  -- ishch )

  FUNCTION get_grace_date_nonpayed
  (
    par_p_pol_header   NUMBER
   ,par_p_decline_date DATE
  ) RETURN VARCHAR2;
  FUNCTION damage_decline_reason
  (
    par_p_cover_id NUMBER
   ,par_c_claim_id NUMBER
  ) RETURN VARCHAR2;
  FUNCTION get_due_date_payed
  (
    par_p_pol_header   NUMBER
   ,par_p_decline_date DATE
   ,p_type             NUMBER DEFAULT 1
  ) RETURN VARCHAR2;
  PROCEDURE for_sms_report_payment
  (
    p_date_from DATE
   ,p_date_to   DATE
  );

  /*
    Байтин А.
    Процедура для сохранения изменений.
    Используется при некоторых переводах статусов
  
    Параметр указан формально и не используется
  */
  PROCEDURE commit_it(par_doc_id NUMBER);

  -- ishch (
  -- Процедура привязки агентского договора к договору страхования через
  -- ven_p_policy_agent_doc
  -- Параметры: id ДС и АД
  -- Байтин А.
  -- Перенес в спецификацию
  PROCEDURE add_policy_agent_doc
  (
    par_policy_header_id      NUMBER
   ,par_ag_contract_header_id NUMBER
  );

  /* Wrapper for pkg_bso.Create_BSO_History */
  FUNCTION create_bso_history
  (
    par_bso_id    NUMBER
   ,par_policy_id NUMBER
  ) RETURN NUMBER;

END pkg_renlife_utils; 
/
CREATE OR REPLACE PACKAGE BODY "PKG_RENLIFE_UTILS" IS

  -- Private type declarations
  TYPE t_bordero IS RECORD(
     produc_id            NUMBER
    ,sales_channel_id     NUMBER
    ,agency_id            NUMBER
    ,fund_id              NUMBER
    ,pay_fund_id          NUMBER
    ,confirm_condition_id NUMBER
    ,pol_ser              VARCHAR2(50)
    ,payment_term_id      NUMBER
    ,period_id            NUMBER
    ,fee_payment_term     NUMBER
    ,fact_j               NUMBER
    ,admin_cost           NUMBER
    ,is_group             NUMBER
    ,waiting_periood_id   NUMBER
    ,region_id            NUMBER
    ,f_discount_id        NUMBER
    ,description          VARCHAR2(100)
    ,payment_off_id       NUMBER
    ,header_description   VARCHAR2(100)
    ,discount_period      NUMBER
    ,
    --death_prod_line_id        NUMBER,
    --disability_prod_line_id   NUMBER,
    --job_loss_prod_line_id     NUMBER,
    prod_line_id_1 NUMBER
    ,percent_1      NUMBER
    ,prod_line_id_2 NUMBER
    ,percent_2      NUMBER
    ,prod_line_id_3 NUMBER
    ,percent_3      NUMBER
    ,prod_line_id_4 NUMBER
    ,percent_4      NUMBER
    ,prod_line_id_5 NUMBER
    ,percent_5      NUMBER
    ,prod_line_id_6 NUMBER
    ,percent_6      NUMBER
    --
    ,death_coef             NUMBER
    ,disability_coef        NUMBER
    ,benificiary_id         NUMBER
    ,benificiary_part_id    NUMBER
    ,benificiary_part_value NUMBER
    ,benificiary_role       VARCHAR2(50)
    ,asset_role             VARCHAR2(50)
    ,flag_zabota            NUMBER
    ,special_program_flag   NUMBER);

  g_bordero t_bordero;
  -- Private constant declarations
  debug CONSTANT BOOLEAN := FALSE;
  --G_Bordero as_bordero_vedom%ROWTYPE;
  -- Private variable declarations
  --<VariableName> <Datatype>;

  ------------------------------------------------------------
  -- Функиця возвращает описание для работника по его контакту
  -- если контакт не является работником на указанную дату возвращает null
  -- если контакт на указанную дату увлоен то возвращается -1
  -- contact_id - ид контакта
  -- date - дата на которую надо вернуть описание
  -- descr_type - тип возвращаемых данных
  --         1 - должность (звание?)
  --         2 - департамент
  --         3 - материально ответсвеннный? 1/0
  --         4 - краткое название подразделения организации
  --         5 - полное название подразделения ораганизации
  --         6 - ИД подразделения организации
  --         7 - ИД департамента
  --
  --
  -- v1.0 3.04.2008 Каткевич А.Г.
  ----------------------------------------------------------
  FUNCTION get_emp_description
  (
    par_contact_id IN NUMBER
   ,par_date       IN DATE
   ,par_descr_type IN VARCHAR
  ) RETURN VARCHAR2 IS
    RESULT VARCHAR2(2000);
    func_name CONSTANT VARCHAR2(2000) := 'GET_EMP_DESCRIPTION';
  BEGIN
    SELECT descript
      INTO RESULT
      FROM (SELECT CASE
                     WHEN par_descr_type = 1 THEN
                      eh.appointment
                     WHEN par_descr_type = 2 THEN
                      ins.ent.obj_name(ins.ent.id_by_brief('DEPARTMENT'), eh.department_id)
                     WHEN par_descr_type = 3 THEN
                      to_char(eh.is_brokeage)
                     WHEN par_descr_type = 4 THEN
                      ot.brief
                     WHEN par_descr_type = 5 THEN
                      ot.name
                     WHEN par_descr_type = 6 THEN
                      to_char(ot.organisation_tree_id)
                     WHEN par_descr_type = 7 THEN
                      to_char(eh.department_id)
                   END descript
              FROM ins.employee          e
                  ,ins.employee_hist     eh
                  ,ins.department        d
                  ,ins.organisation_tree ot
             WHERE e.contact_id = par_contact_id
               AND e.employee_id = eh.employee_id
               AND eh.date_hist <= par_date
               AND eh.department_id = d.department_id
               AND d.org_tree_id = ot.organisation_tree_id
             ORDER BY eh.date_hist DESC)
     WHERE rownum = 1; --В результат падает последняя хапись из employee_hist
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,' Не удалось вернуть описание  ' || func_name || ' с параметрами ' ||
                              par_contact_id || '|' || par_date || '|' || par_descr_type || chr(10) ||
                              chr(13) || SQLERRM(SQLCODE));
  END get_emp_description;

  -- Байтин А.
  -- Обернул автономную транзакцию, чтобы не было лишних commit'ов
  PROCEDURE tmp_log_writer_auto(any_varchar IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO temp_log (dt, VALUE) VALUES (SYSDATE, any_varchar);
    COMMIT;
  END tmp_log_writer_auto;

  PROCEDURE tmp_log_writer(any_varchar IN VARCHAR2) IS
  BEGIN
    IF debug
    THEN
      tmp_log_writer_auto(any_varchar);
    END IF;
  END tmp_log_writer;

  /*Функция получает коэффициент для индексирования страховых сумм*/
  FUNCTION get_ins_amount_koef
  (
    p_gdv    IN NUMBER
   ,p_progr  IN NUMBER
   ,p_sex    IN NUMBER
   ,p_period IN NUMBER
  ) RETURN NUMBER IS
    ret     NUMBER;
    p_p_gdv NUMBER;
  BEGIN
    p_p_gdv := p_gdv;
    IF p_p_gdv > 5
    THEN
      p_p_gdv := 5;
    END IF;
    SELECT am.koef
      INTO ret
      FROM tmp_koef_insamount am
     WHERE am.gdv = p_p_gdv
       AND am.progr = p_progr
       AND am.sex = p_sex
       AND am.period = p_period;
    RETURN(ret);
  END get_ins_amount_koef;

  /*Функция получает коэффициент для индексирования выкупных сумм*/
  FUNCTION get_surr_koef
  (
    p_gdv    IN NUMBER
   ,p_progr  IN NUMBER
   ,p_sex    IN NUMBER
   ,p_period IN NUMBER
   ,p_quat   IN NUMBER
  ) RETURN NUMBER IS
    ret     NUMBER;
    p_p_gdv NUMBER;
  BEGIN
  
    p_p_gdv := p_gdv;
    IF p_p_gdv > 5
    THEN
      p_p_gdv := 5;
    END IF;
  
    SELECT am.koef
      INTO ret
      FROM tmp_koef_surr am
     WHERE am.gdv = p_p_gdv
       AND am.progr = p_progr
       AND am.sex = p_sex
       AND am.period = p_period
       AND am.quat = p_quat;
    RETURN(ret);
  END get_surr_koef;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 04.09.2008 16:35:58
  -- Purpose : Помогает отследить долго выполняющиеся процедуры
  PROCEDURE time_elapsed
  (
    any_varchar    VARCHAR2
   ,par_sid        NUMBER
   ,possible_count NUMBER DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    proc_name      VARCHAR2(20) := 'time_elapsed';
    v_time_elapsed NUMBER;
  BEGIN
    --TOTDO !!!! - произвести тестирование производительности с помощью runstats
    --BEGIN --Сколько времени в секундах прошло с последнего измерения
    SELECT (SYSDATE - nvl(MAX(TIME), SYSDATE)) * 3600 * 24
      INTO v_time_elapsed
      FROM time_elapsed
     WHERE sid = par_sid;
    /*EXCEPTION
    WHEN NO_DATA_FOUND THEN v_time_elapsed :=0;
    END;
    */
    INSERT INTO time_elapsed
      (sid, message, TIME, elapsed_time, possible_count)
    VALUES
      (par_sid, any_varchar, SYSDATE, v_time_elapsed, possible_count);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END time_elapsed;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.05.2008 17:09:46
  -- Purpose : Страховая сумма основной программы
  FUNCTION ins_sum_general_prog(par_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
    func_name CONSTANT VARCHAR2(2000) := 'INS_SUM_GENERAL_PROG';
  BEGIN
    SELECT nvl(pc_osn.ins_amount, 0)
      INTO RESULT
      FROM p_cover             pc_tek
          ,as_asset            as_tek
          ,p_cover             pc_osn
          ,as_asset            as_osn
          ,t_prod_line_option  plo_osn
          ,t_product_line      pl_osn
          ,t_product_line_type plt
     WHERE (pc_tek.p_cover_id = par_p_cover_id AND pc_tek.as_asset_id = as_tek.as_asset_id)
       AND (pc_osn.t_prod_line_option_id = plo_osn.id AND pc_osn.as_asset_id = as_osn.as_asset_id AND
           plo_osn.product_line_id = pl_osn.id AND plt.description LIKE 'Основн%' AND
           pl_osn.product_line_type_id = plt.product_line_type_id)
       AND as_tek.as_asset_id = as_osn.as_asset_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        RETURN(0);
      END;
    WHEN OTHERS THEN
      BEGIN
        raise_application_error(-20000
                               ,'Не удалось получить страховую сумму основной программы ' ||
                                func_name || ' ' || SQLERRM(SQLCODE));
      END;
      RETURN(RESULT);
    
  END ins_sum_general_prog;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.05.2008
  -- Purpose : Страховая сумма основной программы (для Platinum Life Active)
  FUNCTION ins_sum_general_prog_pla
  (
    par_p_cover_id NUMBER
   ,par_fund_id    NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    func_name CONSTANT VARCHAR2(2000) := 'INS_SUM_FLA_PROG';
  BEGIN
    SELECT nvl(pc_osn.ins_amount, 0)
      INTO RESULT
      FROM p_cover             pc_tek
          ,as_asset            as_tek
          ,p_cover             pc_osn
          ,as_asset            as_osn
          ,t_prod_line_option  plo_osn
          ,t_product_line      pl_osn
          ,t_product_line_type plt
     WHERE (pc_tek.p_cover_id = par_p_cover_id AND pc_tek.as_asset_id = as_tek.as_asset_id)
       AND (pc_osn.t_prod_line_option_id = plo_osn.id AND pc_osn.as_asset_id = as_osn.as_asset_id AND
           plo_osn.product_line_id = pl_osn.id AND plt.description LIKE 'Основн%' AND
           pl_osn.product_line_type_id = plt.product_line_type_id)
       AND as_tek.as_asset_id = as_osn.as_asset_id;
  
    IF par_fund_id = 122
    THEN
      IF RESULT > 300000
      THEN
        RETURN(300000);
      END IF;
    ELSE
      IF RESULT > 10000
      THEN
        RETURN(10000);
      END IF;
    END IF;
  
    RETURN(RESULT);
  
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        RETURN(0);
      END;
    WHEN OTHERS THEN
      BEGIN
        raise_application_error(-20000
                               ,'Не удалось получить страховую сумму основной программы ' ||
                                func_name || ' ' || SQLERRM(SQLCODE));
      END;
  END ins_sum_general_prog_pla;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.05.2008 18:09:06
  -- Purpose : Функция подсчета прямого коэффициента недострахования (для сроков страхования не кратных году)
  -- Year_int - количество полных лет в сроке страхования (округленное в меньшую сторону)
  -- year_mod - остаток в месяцах от неполного года страхования
  -- koeff - непрямой коэффициент недострахования
  FUNCTION fract_koeff
  (
    par_year_int NUMBER
   ,par_year_mod NUMBER
   ,par_koeff    NUMBER
   ,par_pay_term NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    IF par_pay_term <> 433
    THEN
      RETURN(1);
    END IF;
    RESULT := (par_year_int + par_koeff) / (par_year_int + par_year_mod / 12);
    tmp_log_writer('fract_coef ' || RESULT || ' year ' || par_year_int || '  ' || par_year_mod || ' ' ||
                   par_koeff);
    RETURN(RESULT);
  
  EXCEPTION
    WHEN zero_divide THEN
      RETURN(0);
    
  END fract_koeff;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.05.2008 13:29:59
  -- Purpose : Функция для расчета тарифа по продукту Family Life Active
  -- End_tariff - тариф по смешанному страхованию
  -- Term_tariff - тариф по страхованию жини на срок
  FUNCTION fla_tariff_calc
  (
    par_end_tariff  NUMBER
   ,par_term_tariff NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    func_name CONSTANT VARCHAR2(2000) := 'FLA_Tariff_calc';
  BEGIN
    RESULT := par_end_tariff + par_term_tariff;
    -- tmp_log_writer('End  '||par_End_Tariff||' TERM  '||par_TERM_Tariff);
    RETURN(RESULT);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Не удалось получить тариф к для FLA ' || func_name || ' ' ||
                              SQLERRM(SQLCODE));
  END fla_tariff_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.06.2008 16:36:54
  -- Purpose : Функция для расчета "Простого" брутто-тарифа
  -- p_cover_id - ID поркытия.
  FUNCTION simple_brutto_tariff(par_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  
    r_calc_param pkg_prdlifecalc.calc_param;
    netto_presc  NUMBER;
    brutto_presc NUMBER;
    -- v_f NUMBER;
    -- v_tariff_netto number;
    func_name CONSTANT VARCHAR2(2000) := 'Simple_brutto_Tariff_calc';
  BEGIN
    --Оркугление на формсах работает не пойми как
    --(брутто от нетто тарифа округлить отдельно нельзя)
    SELECT nvl(pl.tariff_func_precision, 7)
          ,nvl(pl.tariff_netto_func_precision, 7)
      INTO brutto_presc
          ,netto_presc
      FROM t_product_line     pl
          ,t_prod_line_option plo
          ,p_cover            pc
     WHERE pl.id = plo.product_line_id
       AND pc.t_prod_line_option_id = plo.id
       AND pc.p_cover_id = par_p_cover_id;
  
    --Передалал на более технологичный (возможно более "тяжелый" подход)
    r_calc_param := ins.pkg_prdlifecalc.get_calc_param(par_p_cover_id);
  
    r_calc_param.s_coef := nvl(greatest(nvl(r_calc_param.s_coef_m, r_calc_param.s_coef_nm)
                                       ,nvl(r_calc_param.s_coef_nm, r_calc_param.s_coef_m))
                              ,0) / 1000;
  
    r_calc_param.k_coef := nvl(greatest(nvl(r_calc_param.k_coef_m, r_calc_param.k_coef_nm)
                                       ,nvl(r_calc_param.k_coef_nm, r_calc_param.k_coef_m))
                              ,0) / 100;
  
    RESULT := trunc(ROUND(r_calc_param.tariff_netto / (1 - r_calc_param.f) *
                          (1 + nvl(r_calc_param.k_coef, 0)) + nvl(r_calc_param.s_coef, 0)
                         ,7)
                   ,netto_presc);
  
    --Вытащим нагрузку и нетто тариф
  
    /*  select rvb_value, pc.tariff_netto
      into v_f, v_tariff_netto
      FROM p_cover pc
     WHERE pc.p_cover_id = par_p_cover_id;
    
    RESULT:= v_tariff_netto/(1-v_f);*/
  
    RETURN(RESULT);
  
  EXCEPTION
    WHEN zero_divide THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Ошибка при выполнении' || func_name || ' ' || SQLERRM(SQLCODE));
  END simple_brutto_tariff;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 03.03.2009 14:06:17
  -- Purpose : Расчет "простого" нетто тарифа для тех случаев когда
  --           таирф вычисляется из заданных СС и БВ
  FUNCTION simple_netto_tariff(par_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT       NUMBER;
    r_calc_param pkg_prdlifecalc.calc_param;
    proc_name    VARCHAR2(20) := 'Simple_netto_tariff';
  BEGIN
    r_calc_param := ins.pkg_prdlifecalc.get_calc_param(par_p_cover_id);
  
    --r_calc_param.S_COEF := NVL (GREATEST (NVL(r_calc_param.S_COEF_M, r_calc_param.S_COEF_NM), NVL(r_calc_param.S_COEF_NM, r_calc_param.S_COEF_M)), 0)/1000;
  
    --r_calc_param.K_COEF := NVL (GREATEST (NVL(r_calc_param.K_COEF_M, r_calc_param.K_COEF_NM), NVL(r_calc_param.K_COEF_NM, r_calc_param.K_COEF_M)), 0)/100;
  
    RESULT := r_calc_param.fee / r_calc_param.ins_amount * (1 - r_calc_param.f);
    --ROUND(r_calc_param.tariff_netto /(1- r_calc_param.f) * (1 + NVL(r_calc_param.K_COEF, 0)) + NVL(r_calc_param.S_COEF, 0), 7);
  
    RETURN(RESULT);
  EXCEPTION
    WHEN zero_divide THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END simple_netto_tariff;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2008 19:30:43
  -- Purpose : Процедура переброски даты проводки
  -- par_policy_header_id - id договора (будут переброшены все проводки по этому договору)
  -- par_policy_id - id версии договора (будут переблошены проводки только по этой версии, и общие для всего договора проводки)
  -- par_date - дата на которую перебросить проводки (по умолчанию используется doc_daye самих проводок)
  PROCEDURE trans_time_shift
  (
    par_policy_header_id NUMBER
   ,par_policy_id        NUMBER DEFAULT NULL
   ,par_date             DATE DEFAULT NULL
  ) IS
    func_name CONSTANT VARCHAR2(2000) := 'Trans_Time_Shift';
    var_policy_header_id NUMBER := par_policy_header_id;
  
  BEGIN
    FOR r IN (SELECT DISTINCT t.trans_id
                FROM trans    t
                    ,p_policy pp
               WHERE pp.pol_header_id = var_policy_header_id
                 AND (pp.policy_id = par_policy_id OR par_policy_id IS NULL)
                 AND ((t.a1_dt_ure_id = 283 AND t.a1_dt_uro_id = policy_id) OR
                     (t.a2_dt_ure_id = 283 AND t.a2_dt_uro_id = policy_id) OR
                     (t.a3_dt_ure_id = 283 AND t.a3_dt_uro_id = policy_id) OR
                     (t.a4_dt_ure_id = 283 AND t.a4_dt_uro_id = policy_id) OR
                     (t.a5_dt_ure_id = 283 AND t.a5_dt_uro_id = policy_id) OR
                     (t.a1_ct_ure_id = 283 AND t.a1_ct_uro_id = policy_id) OR
                     (t.a2_ct_ure_id = 283 AND t.a2_ct_uro_id = policy_id) OR
                     (t.a3_ct_ure_id = 283 AND t.a3_ct_uro_id = policy_id) OR
                     (t.a4_ct_ure_id = 283 AND t.a4_ct_uro_id = policy_id) OR
                     (t.a5_ct_ure_id = 283 AND t.a5_ct_uro_id = policy_id))
              UNION ALL
              SELECT DISTINCT t.trans_id
                FROM trans t
               WHERE (t.a1_dt_ure_id = 282 AND t.a1_dt_uro_id = var_policy_header_id)
                  OR (t.a2_dt_ure_id = 282 AND t.a2_dt_uro_id = var_policy_header_id)
                  OR (t.a3_dt_ure_id = 282 AND t.a3_dt_uro_id = var_policy_header_id)
                  OR (t.a4_dt_ure_id = 282 AND t.a4_dt_uro_id = var_policy_header_id)
                  OR (t.a5_dt_ure_id = 282 AND t.a5_dt_uro_id = var_policy_header_id)
                  OR (t.a1_ct_ure_id = 282 AND t.a1_ct_uro_id = var_policy_header_id)
                  OR (t.a2_ct_ure_id = 282 AND t.a2_ct_uro_id = var_policy_header_id)
                  OR (t.a3_ct_ure_id = 282 AND t.a3_ct_uro_id = var_policy_header_id)
                  OR (t.a4_ct_ure_id = 282 AND t.a4_ct_uro_id = var_policy_header_id)
                  OR (t.a5_ct_ure_id = 282 AND t.a5_ct_uro_id = var_policy_header_id))
    LOOP
    
      UPDATE ins.trans t
         SET t.trans_date = decode(nvl(par_date, to_date('01.01.1900', 'dd.mm.yyyy'))
                                  ,to_date('01.01.1900', 'dd.mm.yyyy')
                                  ,t.doc_date
                                  ,par_date)
       WHERE trans_id = r.trans_id;
    
    END LOOP;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Не удалось перебросить проводки' || func_name || ' ' ||
                              SQLERRM(SQLCODE));
  END trans_time_shift;

  --Веселуха 05.08.2009
  FUNCTION ret_ser_policy(p_policy_id NUMBER) RETURN VARCHAR2 IS
    RESULT VARCHAR2(30);
  BEGIN
    SELECT CASE
             WHEN length(pp.pol_num) > 6 THEN
              (SELECT CASE
                        WHEN t.brief = 'Заяв.Жизнь.New' THEN
                         '192'
                        WHEN t.brief = 'Заяв.Страх.Жизнь' THEN
                         '195'
                        ELSE
                         t.brief
                      END brief
                 FROM bso_series ser
                     ,bso_type   t
                WHERE t.bso_type_id = ser.bso_type_id
                  AND ser.series_name = substr(pp.pol_num, 1, 3))
             ELSE
              pp.notice_ser
           END
      INTO RESULT
      FROM p_policy pp
     WHERE pp.policy_id = p_policy_id;
    RETURN(RESULT);
  END;

  --Веселуха 14.09.2009
  FUNCTION ret_osn_progr(p_policy_id NUMBER) RETURN VARCHAR2 IS
    RESULT VARCHAR2(2000);
  BEGIN
    SELECT plo.description progr
      INTO RESULT
      FROM p_policy            pp
          ,as_asset            ass
          ,p_cover             pc
          ,t_prod_line_option  plo
          ,t_product_line      pl
          ,t_product_line_type plt
     WHERE ass.p_policy_id = pp.policy_id
       AND pc.as_asset_id = ass.as_asset_id
       AND plo.id = pc.t_prod_line_option_id
       AND plo.product_line_id = pl.id
       AND pl.product_line_type_id = plt.product_line_type_id
       AND plt.brief = 'RECOMMENDED'
       AND upper(TRIM(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
       AND ass.p_policy_id = p_policy_id;
    RETURN(RESULT);
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN('-');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ret_osn_progr ' || SQLERRM);
  END;

  --Веселуха 14.09.2009
  PROCEDURE input_data IS
  BEGIN
    DELETE FROM tmptable_input_data;
    INSERT INTO tmptable_input_data
      SELECT d.document_id
            ,ch.c_event_id
            ,ch.c_claim_header_id
            ,dd.parent_id
            ,pr.description
            ,a.amount
            ,decode(dt.brief, 'PAYORDER_SETOFF', 'З', 'PAYORDER', 'В', 'Н') flag
        FROM document       d
            ,ac_payment     a
            ,doc_templ      dt
            ,doc_doc        dd
            ,c_claim        cc
            ,c_claim_header ch
            ,contact        c
            ,doc_status     ds
            ,doc_status_ref dsr
            ,p_policy       p
            ,t_peril        pr
       WHERE d.document_id = a.payment_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dd.child_id = d.document_id
         AND dd.parent_id = cc.c_claim_id
         AND a.contact_id = c.contact_id
         AND ds.document_id = d.document_id
         AND ds.start_date =
             (SELECT MAX(dss.start_date) FROM doc_status dss WHERE dss.document_id = d.document_id)
         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
         AND ch.c_claim_header_id = cc.c_claim_header_id
         AND p.policy_id = ch.p_policy_id
         AND pr.id = ch.peril_id;
  
    DELETE FROM tmptable_input_datac;
    INSERT INTO tmptable_input_datac
      SELECT dso.parent_doc_id
            ,dso.doc_set_off_id
            ,dso.child_doc_id
            ,cd.num               child_doc_num
            ,cp.due_date          child_doc_date
            ,dso.set_off_date
            ,dso.set_off_amount
            ,cp.rev_amount        child_doc_amount
            ,cp.contact_id
            ,cc.obj_name_orig     contact_name
            ,ds.doc_status_ref_id
            ,dsr.name             doc_status_ref_name
            ,cd.doc_templ_id
            ,dt.brief             doc_templ_brief
        FROM doc_set_off    dso
            ,document       cd
            ,ac_payment     cp
            ,contact        cc
            ,doc_status     ds
            ,doc_status_ref dsr
            ,doc_templ      dt
       WHERE dso.child_doc_id = cd.document_id
         AND cd.document_id = cp.payment_id
         AND cp.contact_id = cc.contact_id
         AND ds.document_id = cd.document_id
         AND ds.start_date =
             (SELECT MAX(dss.start_date) FROM doc_status dss WHERE dss.document_id = cd.document_id)
         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
         AND dt.doc_templ_id = cd.doc_templ_id
      UNION
      SELECT dso.child_doc_id     parent_doc_id
            ,dso.doc_set_off_id
            ,dso.parent_doc_id    child_doc_id
            ,cd.num               child_doc_num
            ,cp.due_date          child_doc_date
            ,dso.set_off_date
            ,dso.set_off_amount
            ,cp.rev_amount        child_doc_amount
            ,cp.contact_id
            ,cc.obj_name_orig     contact_name
            ,ds.doc_status_ref_id
            ,dsr.name             doc_status_ref_name
            ,cd.doc_templ_id
            ,dt.brief             doc_templ_brief
        FROM doc_set_off    dso
            ,document       cd
            ,ac_payment     cp
            ,contact        cc
            ,doc_status     ds
            ,doc_status_ref dsr
            ,doc_templ      dt
       WHERE dso.parent_doc_id = cd.document_id
         AND cd.document_id = cp.payment_id
         AND cp.contact_id = cc.contact_id
         AND ds.document_id = cd.document_id
         AND ds.start_date =
             (SELECT MAX(dss.start_date) FROM doc_status dss WHERE dss.document_id = cd.document_id)
         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
         AND dt.doc_templ_id = cd.doc_templ_id;
  
  END;

  --Веселуха 14.09.2009
  FUNCTION ret_sod_claim(p_claim_header NUMBER) RETURN DATE IS
  BEGIN
    RETURN pkg_claim.ret_sod_claim(p_claim_header);
  END;

  --Веселуха 14.09.2009
  FUNCTION ret_amount_claim
  (
    p_event_id     NUMBER
   ,p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_claim.ret_amount_claim(p_event_id, p_claim_header, p_flag);
  END;

  FUNCTION ret_amount_active
  (
    p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_claim.ret_amount_active(p_claim_header, p_flag);
  END;

  FUNCTION get_fee_sum(p_policy NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(pc.fee) fee
      INTO RESULT
      FROM p_policy    p
          ,as_asset    aa
          ,status_hist sha
          ,p_cover     pc
          ,status_hist shp
     WHERE aa.p_policy_id = p.policy_id
       AND sha.status_hist_id = aa.status_hist_id
       AND sha.brief <> 'DELETED'
       AND pc.as_asset_id = aa.as_asset_id
       AND shp.status_hist_id = pc.status_hist_id
       AND shp.brief <> 'DELETED'
       AND p.policy_id = p_policy;
    RETURN(RESULT);
  END;

  -- Веселуха 26.05.2009
  FUNCTION get_idx_sum(p_payment_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT idx
      INTO RESULT
      FROM (SELECT SUM(pc.fee) idx
              FROM doc_doc dd
                  ,p_policy pp
                  ,(SELECT p.policy_id
                          ,p.pol_header_id
                          ,p.start_date
                          ,p.version_num
                          ,pkg_policy.get_last_version(p.pol_header_id) last_ver_id
                      FROM p_policy p
                     WHERE doc.get_doc_status_brief(p.policy_id) = 'INDEXATING') ind
                  ,as_asset a
                  ,p_cover pc
                  ,
                   -- Байтин А.
                   -- Добавлено ЭПГ, для того, чтобы сумма индексации не считалась для ЭПГ с датой меньшей даты индексации
                   ac_payment epg
             WHERE pp.policy_id = dd.parent_id
               AND ind.pol_header_id = pp.pol_header_id
                  -- Изменено ! При индексации не всегда есть версия договора, у которой даты начала совпадают
               AND ((ind.start_date = pp.start_date)
                   --Чирков /265108: Проблема с принятием индексации и разнесением платежей/
                   --OR (ind.version_num = pp.version_num + 1)
                   OR ind.policy_id = ind.last_ver_id
                   --265108               
                   )
               AND a.p_policy_id = ind.policy_id
               AND pc.as_asset_id = a.as_asset_id
               AND dd.child_id = epg.payment_id
               AND epg.payment_id = p_payment_id
               AND epg.plan_date >= ind.start_date HAVING SUM(pc.fee) IS NOT NULL
            -- Байтин А.
            -- вместо union сделал union all
            -- т.к. исключен вариант, когда обе части запроса вернут значения
            UNION ALL
            SELECT SUM(pc.fee) idx
              FROM doc_doc dd
                  ,as_asset a
                  ,p_cover pc
                  ,ven_ac_payment aca
                  ,doc_templ acat
                  ,doc_set_off ffo
                  ,doc_doc dad
                  ,p_policy ppa
                  ,(SELECT p.policy_id
                          ,p.pol_header_id
                          ,p.start_date
                          ,p.version_num
                          ,pkg_policy.get_last_version(p.pol_header_id) last_ver_id
                      FROM p_policy p
                     WHERE doc.get_doc_status_brief(p.policy_id) = 'INDEXATING') inda
                   -- Байтин А.
                   -- Добавлено ЭПГ, для того, чтобы сумма индексации не считалась для ЭПГ с датой меньшей даты индексации
                  ,ac_payment epg
             WHERE 1 = 1
                  -- Изменено ! При индексации не всегда есть версия договора, у которой даты начала совпадают
               AND ((inda.start_date = ppa.start_date)
                   --Чирков /265108: Проблема с принятием индексации и разнесением платежей/
                   --OR (inda.version_num = ppa.version_num + 1)  
                   OR inda.policy_id = inda.last_ver_id
                   --265108  
                   )
               AND pc.as_asset_id = a.as_asset_id
               AND a.p_policy_id = inda.policy_id
               AND dd.child_id = p_payment_id
                  
               AND dd.parent_id = aca.payment_id
               AND aca.doc_templ_id = acat.doc_templ_id
               AND acat.brief IN ('A7', 'PD4')
                  
               AND ffo.child_doc_id = aca.payment_id
               AND ffo.parent_doc_id = epg.payment_id
               AND epg.payment_id = dad.child_id
               AND dad.parent_id = ppa.policy_id
               AND inda.pol_header_id = ppa.pol_header_id
               AND epg.plan_date >= inda.start_date HAVING SUM(pc.fee) IS NOT NULL);
    -- where idx <> -333;
  
    /*    SELECT SUM(pc.FEE) idx
          INTO RESULT
          FROM doc_doc dd,
               p_policy pp,
               (SELECT p.policy_id,
                       p.pol_header_id,
                       p.start_date,
                       p.version_num
                  FROM p_policy p
                 WHERE doc.get_doc_status_brief(p.policy_id) = 'INDEXATING') ind,
               as_asset a,
               p_cover pc
         WHERE pp.policy_id = dd.parent_id
           AND ind.pol_header_id = pp.pol_header_id
    -- Изменено ! При индексации не всегда есть версия договора, у которой даты начала совпадают
           AND ((ind.start_date = pp.start_date) or (ind.version_num = pp.version_num + 1))
           AND a.p_policy_id = ind.policy_id
           AND pc.as_asset_id = a.as_asset_id
           AND dd.child_id = p_payment_id;*/
    RETURN(ROUND(RESULT, 2));
    -- Байтин А
    -- Когда нет версии Индексация, возвращаем 0
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.06.2009 11:51:25
  -- Purpose : Возвращает индексированную сумму (для не индексированных договоров = 0)
  -- par_tplo_id - риск по которому нужно вернуть сумму по умолчанию, все риски
  -- par_return - определяет тип возвращаемой суммы
  -- 1 - возвращает всю сумму
  -- 2 - возвращает дельту от не индескированной суммы
  -- 3 - возвращает % индексации
  FUNCTION get_indexing_summ
  (
    par_payment_id NUMBER
   ,par_tplo_id    NUMBER DEFAULT -1
   ,par_return     NUMBER DEFAULT 1
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'get_indexing_summ';
  BEGIN
    SELECT CASE
             WHEN par_return = 1 THEN
              SUM(ind_pc.fee)
             WHEN par_return = 2 THEN
              SUM(ind_pc.fee) - SUM(pc.fee)
             WHEN par_return = 3 THEN
              SUM(ind_pc.fee) / SUM(pc.fee) - 1
           END summ
      INTO RESULT
      FROM doc_doc             dd
          ,p_policy            ind_p
          ,p_pol_addendum_type ppa
          ,t_addendum_type     ta
          ,as_asset            ind_a
          ,p_cover             ind_pc
          ,p_policy            pp
          ,as_asset            a
          ,p_cover             pc
     WHERE dd.child_id = par_payment_id
       AND dd.parent_id = ind_p.policy_id
       AND ind_p.policy_id = ppa.p_policy_id
       AND ta.t_addendum_type_id = ppa.t_addendum_type_id
       AND ta.brief = 'INDEXING2'
       AND ind_a.p_policy_id = ppa.p_policy_id
       AND ind_a.as_asset_id = ind_pc.as_asset_id
       AND pp.policy_id = pkg_policy.get_previous_version(ind_p.policy_id)
       AND pp.policy_id = a.p_policy_id
       AND pc.as_asset_id = a.as_asset_id
       AND pc.t_prod_line_option_id = ind_pc.t_prod_line_option_id
       AND pc.t_prod_line_option_id = decode(par_tplo_id, -1, pc.t_prod_line_option_id, par_tplo_id);
  
    RETURN(ROUND(RESULT, 6));
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_indexing_summ;

  -- Веселуха 02.06.2009
  PROCEDURE set_tmptable_zakl(p_agroll_id NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_zakl';
  BEGIN
    DELETE FROM temp_tmptable_zakl;
    INSERT INTO temp_tmptable_zakl
      SELECT COUNT(1) over() zakl_row_cnt
            ,a.ag_perfomed_work_act_id agent_report_id
            ,decode(pp.pol_ser, NULL, pp.pol_num, pp.pol_ser || '-' || pp.pol_num) pol_num
            ,conp.name || ' ' || conp.first_name || ' ' || conp.middle_name strahov_name
            ,
             --prod.description product,
             opt.description progr
            ,tr.sav stavka
            ,nvl(a.part_agent, 100) part_agent
            ,payd.year_of_insurance god
            ,ac.due_date date_pay
            ,nvl(tr.sum_premium, 0) sum_premium
            ,nvl(tr.sum_commission, 0) comission_sum
            ,CASE stag.brief
               WHEN 'Совмест' THEN
                'CAB1'
               WHEN 'Конс' THEN
                'CAB1'
               WHEN 'ФинКонс' THEN
                'CAB2'
               WHEN 'ВедКонс' THEN
                'CAB3'
               WHEN 'ФинСов' THEN
                'CAB4'
               ELSE
                'CAB2'
             END status_name
            ,a.sum comm_rep
            ,
             
             to_char(ac.reg_date, 'dd.mm.yyyy') first_pay_date
            ,tpt.description pay_term
            ,to_char(pp.notice_date, 'dd.mm.yyyy') notice_date
            ,dp.policy_agent_part * dp.summ sgp
            ,prod.description product
            ,dp.insurance_period years
      
        FROM ag_roll              ar
            ,ag_roll_header       arh
            ,ag_roll_type         rt
            ,ag_perfomed_work_act a
            ,ag_contract_header   heda
            ,document             dd
            ,department           dep
            ,contact              cca
            ,
             
             ag_perfom_work_det   det
            ,ag_perfom_work_dpol  dp
            ,ag_perf_work_pay_doc payd
            ,ven_ac_payment       ac
            ,ag_perf_work_trans   tr
            ,p_policy             pp
            ,p_pol_header         ph
            ,t_product            prod
            ,p_policy_contact     pc
            ,contact              conp
            ,t_prod_line_option   opt
            ,ag_stat_agent        stag
            ,t_payment_terms      tpt
       WHERE ar.ag_roll_id = p_agroll_id
            /*and a.AG_PERFOMED_WORK_ACT_ID=:p_ag_perfomed_work_act_id*/
            --and nvl(tr.sum_commission,0) > 0
            --and (tr.sav/100) * (nvl(tr.sum_premium,0)) > 0
         AND (arh.ag_roll_header_id = ar.ag_roll_header_id)
         AND heda.ag_contract_header_id = dd.document_id
         AND rt.ag_roll_type_id = arh.ag_roll_type_id
         AND (a.ag_roll_id = ar.ag_roll_id)
         AND (heda.ag_contract_header_id = a.ag_contract_header_id)
         AND (dep.department_id(+) = heda.agency_id)
         AND (cca.contact_id = heda.agent_id)
         AND tpt.id = dp.pay_term
            
         AND det.ag_perfomed_work_act_id = a.ag_perfomed_work_act_id
         AND det.ag_perfom_work_det_id = dp.ag_perfom_work_det_id
         AND payd.ag_preformed_work_dpol_id = dp.ag_perfom_work_dpol_id
         AND payd.ag_perf_work_pay_doc_id = tr.ag_perf_work_pay_doc_id
            
         AND payd.policy_id = pp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND prod.product_id = ph.product_id
         AND pc.policy_id = pp.policy_id
         AND pc.contact_policy_role_id = 6
         AND pc.contact_id = conp.contact_id
            
         AND opt.id = tr.t_prod_line_option_id
         AND stag.ag_stat_agent_id = dp.ag_status_id
         AND payd.pay_payment_id = ac.payment_id
         AND nvl(tr.sum_commission, 0) <> 0;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_zakl;

  PROCEDURE set_tmptable_dzakl(p_agroll_id NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_dzakl';
  BEGIN
    DELETE FROM temp_tmptable_dzakl;
    INSERT INTO temp_tmptable_dzakl
      SELECT COUNT(1) over() zakl_row_cnt
            ,apw.ag_perfomed_work_act_id agent_report_id
            ,pp.pol_ser || nvl2(pp.pol_ser, '-', '') || pp.pol_num pol_num
            ,ent.obj_name('CONTACT'
                         ,pkg_policy.get_policy_contact(pp.policy_id, 'Страхователь')) strahov_name
            ,to_char(pay.reg_date, 'dd.mm.yyyy') first_pay_date
            ,tpt.description pay_term
            ,to_char(ph.start_date, 'dd.mm.yyyy') notice_date
            ,apdp.policy_agent_part * apdp.summ sgp
            ,tp.description product
            ,'ДАВ' brief
            ,0 is_break
            ,0 is_included
            ,apdp.insurance_period years
        FROM ven_ag_roll_header     arh
            ,ven_ag_roll            ar
            ,ag_perfomed_work_act   apw
            ,ag_perfom_work_det     apd
            ,ag_perfom_work_dpol    apdp
            ,ag_perf_work_pay_doc   appad
            ,p_policy               pp
            ,p_pol_header           ph
            ,ven_ag_contract_header ach
            ,ven_ac_payment         epg
            ,ven_ac_payment         pay
            ,t_product              tp
            ,ag_stat_agent          asa
            ,ag_stat_hist           ash
            ,t_contact_type         tct
            ,t_payment_terms        tpt
       WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
         AND apw.ag_roll_id = ar.ag_roll_id
         AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
         AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
         AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
         AND pp.policy_id = apdp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND appad.epg_payment_id = epg.payment_id
         AND appad.pay_payment_id = pay.payment_id
         AND asa.ag_stat_agent_id = apdp.ag_status_id
         AND ash.ag_stat_hist_id = apw.ag_stat_hist_id
         AND tct.id = apdp.ag_leg_pos
         AND ph.product_id = tp.product_id
         AND tpt.id = apdp.pay_term
         AND ar.ag_roll_id = p_agroll_id
       ORDER BY 2
               ,1
               ,6;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_dzakl;

  FUNCTION get_plan_sgp
  (
    p_insurer VARCHAR2
   ,dt        VARCHAR2
   ,mn        NUMBER
   ,sg        NUMBER
  ) RETURN NUMBER IS
    n       NUMBER;
    v_attrs pkg_tariff_calc.attr_type;
  BEGIN
    v_attrs.delete;
    v_attrs(2) := mn;
    v_attrs(3) := sg;
    v_attrs(1) := dt;
    n := pkg_tariff_calc.calc_coeff_val(p_insurer, v_attrs, 3);
    RETURN(n);
  END get_plan_sgp;

  PROCEDURE set_tmptable_paym(p_event_id NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_paym';
  BEGIN
    DELETE FROM temp_tmptable_paym;
    INSERT INTO temp_tmptable_paym
      SELECT start_date
            ,num
            ,pol
            ,ltrim(to_char(amount
                          ,'999G999G999G999G999G999G990D99'
                          ,'NLS_NUMERIC_CHARACTERS = '', ''')) amount
            ,brief
            ,flag
            ,pkg_utils.money2speech(amount, fund_id) amount_in_words
            ,bank
            ,bank_adr
            ,bic
            ,account_corr
            ,beneficiary
            ,beneficiary_adr
            ,inn
            ,account_nr
            ,cpp
            ,note
            ,prod
            ,region_code
            ,prep
            ,status_claim
        FROM (SELECT start_date
                    ,num
                    ,pol
                    ,CASE
                       WHEN s_z > SUM(amount) THEN
                        1
                       ELSE
                        0
                     END flag
                    ,CASE
                       WHEN s_z > SUM(amount) THEN
                        s_z
                       ELSE
                        s_v
                     END amount
                    ,brief
                    ,fund_id
                    ,amount_in_words
                    ,bank
                    ,bank_adr
                    ,bic
                    ,account_corr
                    ,beneficiary
                    ,beneficiary_adr
                    ,inn
                    ,account_nr
                    ,cpp
                    ,note
                    ,prod
                    ,region_code
                    ,prep
                    ,status_claim
                FROM (SELECT rownum rn
                            ,to_char(ph.start_date, 'dd.mm.yyyy') start_date
                            ,e.num
                            ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) pol
                            ,(SELECT SUM(nvl(csh.amount, 0))
                                FROM v_claim_payment_schedule csh
                               WHERE csh.c_claim_header_id = ch.c_claim_header_id
                                 AND csh.doc_templ_brief = 'PAYORDER_SETOFF') s_z
                            ,(SELECT SUM(nvl(csh.amount, 0))
                                FROM v_claim_payment_schedule csh
                               WHERE csh.c_claim_header_id = ch.c_claim_header_id
                                 AND csh.doc_templ_brief = 'PAYORDER') s_v
                            ,nvl(d.payment_sum, 0) amount
                            ,f_pol.brief
                            ,f_pol.fund_id
                            ,ch.c_claim_header_id
                            ,' ' amount_in_words
                            ,bb.bank_name || ' ' || bb.branch_name bank
                            ,' ' bank_adr
                            ,bic.id_value bic
                            ,bb.account_corr
                            ,ent.obj_name(a.ent_id, a.as_asset_id) beneficiary
                            ,adr.address_name beneficiary_adr
                            ,inn.id_value inn
                            ,bb.account_nr
                            ,cpp.id_value cpp
                            ,cont.note
                            ,prod.brief prod
                            ,'' region_code
                            ,decode(us.name
                                   ,'Панферова Валерия Олеговна'
                                   ,'Панферова В.О.'
                                   ,us.name) prep
                            ,decode(doc.get_last_doc_status_name(ch.active_claim_id)
                                   ,'Урегулируется'
                                   ,to_char(clm.claim_status_date, 'dd.mm.yyyy')
                                   ,'') status_claim
                        FROM ven_c_claim_header ch
                            ,ven_c_claim clm
                            ,ven_p_policy p
                            ,p_pol_header ph
                            ,t_product prod
                            ,fund f_pol
                            ,ven_c_event e
                            ,as_asset a
                            ,as_assured ass
                            ,cn_contact_bank_acc bb
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 10) bic
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 1) inn
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 1) cpp
                            ,v_cn_contact_address adr
                            ,contact cont
                            ,ven_sys_user us
                            ,c_damage d
                       WHERE ch.p_policy_id = p.policy_id
                         AND d.c_claim_id = ch.active_claim_id
                         AND ph.policy_header_id = p.pol_header_id
                         AND prod.product_id = ph.product_id
                         AND ch.active_claim_id = clm.c_claim_id
                         AND f_pol.fund_id = ph.fund_id
                         AND a.as_asset_id = ass.as_assured_id
                         AND ass.assured_contact_id = bb.contact_id(+)
                         AND ass.assured_contact_id = bic.contact_id(+)
                         AND ass.assured_contact_id = inn.contact_id(+)
                         AND ass.assured_contact_id = cpp.contact_id(+)
                         AND ass.assured_contact_id = adr.contact_id
                         AND ass.assured_contact_id = cont.contact_id
                         AND us.sys_user_name = USER
                         AND ch.c_event_id = e.c_event_id
                         AND ch.as_asset_id = a.as_asset_id
                         AND e.c_event_id = ch.c_event_id
                         AND e.c_event_id = p_event_id)
               GROUP BY start_date
                       ,num
                       ,pol
                       ,brief
                       ,fund_id
                       ,amount_in_words
                       ,bank
                       ,s_z
                       ,s_v
                       ,bank_adr
                       ,bic
                       ,account_corr
                       ,beneficiary
                       ,beneficiary_adr
                       ,inn
                       ,account_nr
                       ,cpp
                       ,note
                       ,prod
                       ,region_code
                       ,prep
                       ,status_claim)
       WHERE rownum = 1;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END set_tmptable_paym;

  PROCEDURE set_tmptable_agent(p_agroll_id NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_agent';
  BEGIN
    DELETE FROM temp_tmptable_agent;
    INSERT INTO temp_tmptable_agent
      SELECT COUNT(1) over() row_cnt
            ,agr.ag_perfomed_work_act_id agent_report_id
            ,agch.ag_contract_header_id
            ,hed.num act_num
            ,agr.date_calc report_date
            ,hed.date_begin
            ,hed.date_end
            ,con.contact_id
            ,decode(dep.code, NULL, NULL, dep.code || '-') || agch.num dognum
            ,ent.obj_name(con.ent_id, con.contact_id) agname
            ,nvl(agr.sum, 0) av_sum
            ,dept_exe.contact_id dir_contact_id
            ,decode(vca.category_name
                   ,'Агент'
                   ,agent_status.status_name
                   ,'Финансовый консультант') status_name
            ,salchan.brief saleschanel
            ,pkg_contact.get_fio_fmt(ent.obj_name(con.ent_id, con.contact_id), 4) ag_name_initial
            ,pkg_contact.get_fio_fmt(nvl(ent.obj_name(ent.id_by_brief('CONTACT'), dept_exe.contact_id)
                                        ,'Смышляев Юрий Олегович')
                                    ,4) dir_name_initial
            ,nvl(nvl((SELECT genitive FROM contact WHERE contact_id = dept_exe.contact_id)
                    ,ent.obj_name(ent.id_by_brief('CONTACT'), dept_exe.contact_id))
                ,'Смышляева Юрия Олеговича') dir_name_genitive
            ,nvl(ent.obj_name(ent.id_by_brief('CONTACT'), dept_exe.contact_id)
                ,'Смышляев Юрий Олегович') dir_name
            ,
             
             to_char(agch.date_begin, 'dd.mm.yyyy') ag_date
            ,dep.name filial
            ,to_char(hed.date_begin, 'dd.mm.yyyy') || '-' || to_char(hed.date_end, 'dd.mm.yyyy') MONTH
            ,to_char(hed.date_begin, 'yyyy') YEAR
            ,(SELECT CASE nvl(cag.leg_pos, 0)
                       WHEN 0 THEN
                        'ФЛ'
                       ELSE
                        'ПБОЮЛ'
                     END
                FROM ag_contract cag
               WHERE cag.ag_contract_id =
                     pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, hed.date_end)) leg_pos
      
        FROM ag_perfomed_work_act agr
        JOIN ven_ag_roll ved
          ON (ved.ag_roll_id = agr.ag_roll_id)
        JOIN ven_ag_roll_header hed
          ON (hed.ag_roll_header_id = ved.ag_roll_header_id)
        JOIN ven_ag_contract_header agch
          ON (agch.ag_contract_header_id = agr.ag_contract_header_id)
        JOIN ven_t_sales_channel salchan
          ON (agch.t_sales_channel_id = salchan.id)
        JOIN ven_contact con
          ON (agch.agent_id = con.contact_id)
        LEFT JOIN (SELECT CASE ac.brief
                            WHEN 'MN' THEN
                             'Статус Менеджера'
                            ELSE
                             sa.name
                          END status_name
                         ,sh.ag_stat_hist_id
                     FROM ven_ag_stat_hist      sh
                         ,ven_ag_category_agent ac
                         ,ven_ag_stat_agent     sa
                    WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
                      AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
                      AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)) agent_status
          ON (agent_status.ag_stat_hist_id =
             pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id, hed.date_end))
        LEFT OUTER JOIN ven_department dep
          ON (agch.agency_id = dep.department_id)
        LEFT OUTER JOIN ven_dept_executive dept_exe
          ON (agch.agency_id = dept_exe.department_id)
        LEFT OUTER JOIN ven_ag_category_agent vca
          ON (vca.ag_category_agent_id =
             pkg_agent_1.get_agent_cat_by_date(agch.ag_contract_header_id, hed.date_end))
       WHERE /*agr.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id and*/
       ved.ag_roll_id = p_agroll_id
       AND nvl(agr.sum, 0) <> 0;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END set_tmptable_agent;

  PROCEDURE set_tmptable_agento(p_agroll_id NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_agento';
  BEGIN
    DELETE FROM temp_tmptable_agento;
    INSERT INTO temp_tmptable_agento
      SELECT COUNT(1) over() row_cnt
            ,agr.ag_perfomed_work_act_id agent_report_id
            ,agch.ag_contract_header_id
            ,hed.num act_num
            ,to_char(hed.date_end, 'dd.mm.yyyy') report_date
            ,to_char(hed.date_begin, 'dd.mm.yyyy') date_begin
            ,to_char(hed.date_end, 'dd.mm.yyyy') date_end
            ,con.contact_id
            ,agch.num dognum
            ,ent.obj_name(con.ent_id, con.contact_id) agname
            ,agr.sum av_sum
            ,dept_exe.contact_id dir_contact_id
            ,decode(vca.category_name
                   ,'Агент'
                   ,agent_status.status_name
                   ,'Финансовый консультант') status_name
            ,decode(vca_n.category_name
                   ,'Агент'
                   ,agent_status_next.status_name
                   ,'Финансовый консультант') status_name_next
            ,pkg_contact.get_fio_fmt(ent.obj_name(con.ent_id, con.contact_id), 4) ag_name_initial
            ,pkg_contact.get_fio_fmt(nvl(ent.obj_name(ent.id_by_brief('CONTACT'), dept_exe.contact_id)
                                        ,'Смышляев Юрий Олегович')
                                    ,4) dir_name_initial
            ,nvl(nvl((SELECT genitive FROM contact WHERE contact_id = dept_exe.contact_id)
                    ,ent.obj_name(ent.id_by_brief('CONTACT'), dept_exe.contact_id))
                ,'Смышляева Юрия Олеговича') dir_name_genitive
            ,nvl(ent.obj_name(ent.id_by_brief('CONTACT'), dept_exe.contact_id)
                ,'Смышляев Юрий Олегович') dir_name
            ,to_char(agch.date_begin, 'dd.mm.yyyy') ag_date
            ,dep.name filial
            ,to_char(hed.date_begin, 'dd.mm.yyyy') || '-' || to_char(hed.date_end, 'dd.mm.yyyy') MONTH
            ,to_char(hed.date_begin, 'yyyy') YEAR
            ,(SELECT CASE nvl(cag.leg_pos, 0)
                       WHEN 0 THEN
                        'ФЛ'
                       ELSE
                        'ПБОЮЛ'
                     END
                FROM ag_contract cag
               WHERE cag.ag_contract_id =
                     pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, hed.date_end)) leg_pos
        FROM ag_perfomed_work_act agr
        JOIN ven_ag_roll ved
          ON (ved.ag_roll_id = agr.ag_roll_id)
        JOIN ven_ag_roll_header hed
          ON (hed.ag_roll_header_id = ved.ag_roll_header_id)
        JOIN ven_ag_contract_header agch
          ON (agch.ag_contract_header_id = agr.ag_contract_header_id)
        JOIN ven_contact con
          ON (agch.agent_id = con.contact_id)
        LEFT OUTER JOIN ven_ag_category_agent vca
          ON (vca.ag_category_agent_id =
             pkg_agent_1.get_agent_cat_by_date(agch.ag_contract_header_id, hed.date_end))
        LEFT OUTER JOIN ven_ag_category_agent vca_n
          ON (vca_n.ag_category_agent_id =
             pkg_agent_1.get_agent_cat_by_date(agch.ag_contract_header_id, hed.date_end + 1))
        LEFT OUTER JOIN ven_department dep
          ON (agch.agency_id = dep.department_id)
        LEFT OUTER JOIN ven_dept_executive dept_exe
          ON (agch.agency_id = dept_exe.department_id)
        LEFT JOIN (SELECT CASE ac.brief
                            WHEN 'MN' THEN
                             'Статус Менеджера'
                            ELSE
                             sa.name
                          END status_name
                         ,sh.ag_stat_hist_id
                     FROM ven_ag_stat_hist      sh
                         ,ven_ag_category_agent ac
                         ,ven_ag_stat_agent     sa
                    WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
                      AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
                      AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)) agent_status
          ON (agent_status.ag_stat_hist_id =
             pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id, hed.date_end))
        LEFT JOIN (SELECT CASE ac.brief
                            WHEN 'MN' THEN
                             'Статус Менеджера'
                            ELSE
                             sa.name
                          END status_name
                         ,sh.ag_stat_hist_id
                     FROM ven_ag_stat_hist      sh
                         ,ven_ag_category_agent ac
                         ,ven_ag_stat_agent     sa
                    WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
                      AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
                      AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)) agent_status_next
          ON (agent_status_next.ag_stat_hist_id =
             pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id, hed.date_end + 1))
       WHERE ved.ag_roll_id = p_agroll_id
         AND agr.sum > 0;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END set_tmptable_agento;

  PROCEDURE set_tmptable_surr(p_policy_header_id NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_surr';
    cnt NUMBER;
  BEGIN
  
    --delete from temp_tmptable_surr;
    SELECT COUNT(*)
      INTO cnt
      FROM temp_tmptable_surr ss
     WHERE ss.policy_header_id = p_policy_header_id;
    IF cnt > 0
    THEN
      DELETE FROM temp_tmptable_surr ss WHERE ss.policy_header_id = p_policy_header_id;
    END IF;
  
    INSERT INTO temp_tmptable_surr
      SELECT DISTINCT pol.policy_header_id
                     ,ROUND(pkg_renlife_utils.get_surr_koef(pol.gdv
                                                           ,pol.progr
                                                           ,pol.sex
                                                           ,pol.period
                                                           ,pol.quat)
                           ,6) koef_surr
                     ,pol.ins_amount * ROUND(pkg_renlife_utils.get_surr_koef(pol.gdv
                                                                            ,pol.progr
                                                                            ,pol.sex
                                                                            ,pol.period
                                                                            ,pol.quat)
                                            ,6) idx_surrsum
                     , --"Индексированные выкупные суммы"
                      pol.quat
                     ,MAX(pol.payment_number) over(PARTITION BY pol.quat) max_paym_number
                     ,last_value(pol.amount) over(PARTITION BY pol.quat ORDER BY pol.payment_number rows BETWEEN unbounded preceding AND unbounded following) value_amount --"Стандартные выкупные суммы"
        FROM (SELECT ph.policy_header_id
                    ,pp.policy_id
                    ,extract(YEAR FROM pp.start_date) - extract(YEAR FROM ph.start_date) gdv
                    ,CASE
                       WHEN pr.brief IN ('END', 'END_Old', 'END_2') THEN
                        1
                       WHEN pr.brief IN ('CHI'
                                        ,'CHI_Old'
                                        ,'CHI_2'
                                        ,'PEPR'
                                        ,'PEPR_2'
                                        ,'Platinum_LA'
                                        ,'Platinum_LA2'
                                        ,'Baby_LA'
                                        ,'Baby_LA2'
                                        ,'Family La'
                                        ,'Family_La2'
                                        ,'PRIN_DP'
                                        ,'PRIN_DP_NEW') THEN
                        2
                       ELSE
                        0
                     END progr
                    ,dop.amount
                    ,dop.quat
                    ,dop.gender sex
                    ,trunc(MONTHS_BETWEEN(trunc(pp.end_date) + 1, trunc(ph.start_date)) / 12, 0) period
                    ,
                     --extract(year from pp.end_date) - extract(year from ph.start_date) /*+ 1 убрано по письму от Аннели Кэбин 09-06-2010*/ period,
                     dop.payment_number
                    ,dop.ins_amount
                FROM ven_policy_index_item pii
                    ,ven_p_pol_header ph
                    ,t_product pr
                    ,ven_p_policy pp
                    ,(SELECT --d.insurance_year_number quat
                       MONTHS_BETWEEN(d.insurance_year_date, ph.start_date) / 12 + 1 quat
                      ,d.value amount
                      ,p.policy_id
                      ,p.pol_header_id
                      ,c.gender
                      ,pl.version_num
                      ,nvl(d.payment_number
                          ,row_number()
                           over(PARTITION BY d.policy_cash_surr_id ORDER BY d.start_cash_surr_date)) payment_number
                      ,pc.ins_amount
                        FROM p_policy            pl
                            ,ins.document        d
                            ,ins.doc_status_ref  rf
                            ,policy_cash_surr    p
                            ,policy_cash_surr_d  d
                            ,as_asset            ast
                            ,as_assured          sa
                            ,cn_person           c
                            ,p_cover             pc
                            ,t_prod_line_option  plo
                            ,t_product_line      pl
                            ,t_product_line_type plt
                            ,ins.p_pol_header    ph
                       WHERE pl.policy_id = p.policy_id
                         AND ast.p_policy_id = p.policy_id
                         AND ast.as_asset_id = sa.as_assured_id
                         AND sa.assured_contact_id = c.contact_id
                         AND sa.as_assured_id = pc.as_asset_id
                         AND plo.id = pc.t_prod_line_option_id
                         AND plo.product_line_id = pl.id
                         AND p.pol_header_id = ph.policy_header_id
                         AND pl.policy_id = d.document_id
                         AND d.doc_status_ref_id = rf.doc_status_ref_id
                         AND rf.brief != 'CANCEL'
                         AND pl.product_line_type_id = plt.product_line_type_id
                         AND plt.brief = 'RECOMMENDED'
                         AND upper(TRIM(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
                         AND d.policy_cash_surr_id = p.policy_cash_surr_id
                         AND p.t_lob_line_id =
                             (SELECT DISTINCT t_lob_line_id
                                FROM t_product_line      prl
                                    ,t_product_line_type prt
                               WHERE prl.product_line_type_id = prt.product_line_type_id
                                 AND p.t_lob_line_id = prl.t_lob_line_id
                                 AND prl.visible_flag = 1
                                 AND prt.brief = 'RECOMMENDED')
                         AND p.pol_header_id = p_policy_header_id) dop
               WHERE ph.policy_header_id = pii.policy_header_id
                 AND pii.policy_id = pp.policy_id
                 AND ph.product_id = pr.product_id
                 AND (dop.pol_header_id = ph.policy_header_id
                     --Чирков /изменил/ 254431: Индексация. Журнал 92
                     --AND dop.version_num = pp.version_num - 1
                     AND dop.policy_id = pp.prev_ver_id
                     --
                     )
                 AND doc.get_doc_status_brief(dop.policy_id, to_date('31.12.2999', 'dd.mm.yyyy')) IN
                     ('CURRENT', 'ACTIVE', 'PRINTED', 'CONCLUDED', 'PASSED_TO_AGENT')
                    --and doc.get_doc_status_name(pii.POLICY_INDEX_ITEM_ID) <> 'Согласились на индексацию'
                 AND pii.policy_header_id = p_policy_header_id) pol
       ORDER BY pol.quat
               ,MAX(pol.payment_number) over(PARTITION BY pol.quat);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END set_tmptable_surr;

  -- Веселуха 09.06.2009
  PROCEDURE set_tmptable_vipl_wop
  (
    p_event NUMBER
   ,p_claim NUMBER
  ) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_vipl_WOP';
  BEGIN
    NULL;
    DELETE FROM temp_tmptable_vipl;
    INSERT INTO temp_tmptable_vipl
    
      SELECT a.policy_id
            ,a.peril_name
            ,a.ins_amount
            ,a.payment_sum
            ,a.ins_paym
            ,a.flag
            ,a.rate_tbl
            ,a.rate_day
            ,a.kolvo
            ,a.viplata
            ,a.s_z
            ,a.s_v
            ,CASE
               WHEN a.peril_name LIKE 'Защита страховых%' THEN
                b.dko_date
               WHEN a.peril_name LIKE 'Освобождение%' THEN
                b.dko_date
               ELSE
                b.due_date
             END due_date
            ,a.diagnose
            ,b.real_z
            ,a.peril
            ,a.rec_days
            ,a.peril_id
            ,a.peril_d
        FROM (SELECT policy_id
                    ,p23 peril_name
                    ,p24 ins_amount
                    ,0 payment_sum
                    ,p24 ins_paym
                    ,CASE
                       WHEN p23 LIKE '%оспитализация%' THEN
                        1
                       WHEN p23 LIKE '%трудоспособн%' THEN
                        1
                       ELSE
                        0
                     END flag
                    ,SUM(CASE
                           WHEN p23 LIKE '%оспитализация%' THEN
                            0
                           ELSE
                            (CASE
                              WHEN amount > 0 THEN
                               ROUND(nvl(paym, 0) * rate / amount * 100, 1)
                              ELSE
                               0
                            END)
                         END) rate_tbl
                    ,SUM(CASE
                           WHEN p23 NOT LIKE '%оспитализация%' THEN
                            0
                           ELSE
                            (CASE
                              WHEN amount > 0 THEN
                               ROUND(nvl(paym, 0) * rate / amount * 100, 1)
                              ELSE
                               0
                            END)
                         END) rate_day
                    ,'-' kolvo
                    ,CASE
                       WHEN p31 IS NULL THEN
                        ROUND(SUM((nvl(amount, 0)) * (CASE
                                    WHEN amount > 0 THEN
                                     ((nvl(paym, 0) - nvl(decl, 0)) * rate / amount)
                                    ELSE
                                     0
                                  END))
                             ,2)
                       ELSE
                        0
                     END viplata
                    ,SUM(p_z) s_z
                    ,SUM(p_v) s_v
                    ,p23 peril_d
                    ,p22 diagnose
                    ,peril
                    ,rec_days
                    ,peril_id
                    ,c_event_id
              
                FROM (SELECT p.policy_id
                            ,e.c_event_id
                            ,ch.active_claim_id
                            ,dmg.t_damage_code_id
                            ,nvl(e.diagnose, '-') p22
                            ,CASE
                               WHEN opt.description LIKE 'Защита страховых%' THEN
                                opt.description
                               WHEN opt.description LIKE 'Освобождение%' THEN
                                opt.description
                               WHEN opt.description LIKE '%Дожитие%по независящим%' THEN
                                opt.description
                               ELSE
                                nvl(tp.description, '-')
                             END p23
                            ,tp.id peril_id
                            ,CASE
                               WHEN opt.description LIKE 'Защита страховых%' THEN
                                1
                               WHEN opt.description LIKE 'Освобождение%' THEN
                                1
                               ELSE
                                0
                             END peril
                            ,nvl(pc.ins_amount, 0) p24
                            ,nvl(pc.ins_amount, 0) amount
                            ,nvl(dmg.decline_sum, 0) decl
                            ,nvl(dmg.declare_sum, 0) paym
                            ,nvl(acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, ch.declare_date)
                                ,1) rate
                            ,e.c_event_id p28
                            ,CASE
                               WHEN (nvl(dmg.payment_sum, 0)) = 0 THEN
                                (SELECT decode(doc.get_last_doc_status_name(clm3.c_claim_id)
                                              ,'Урегулируется'
                                              ,clm3.claim_status_date
                                              ,'Закрыт'
                                              ,clm3.claim_status_date)
                                   FROM ven_c_claim clm3
                                  WHERE clm3.c_claim_header_id = ch.c_claim_header_id
                                    AND rownum = 1
                                    AND doc.get_last_doc_status_name(clm3.c_claim_id) IN
                                        ('Урегулируется', 'Закрыт'))
                             END p31
                            ,nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                   ,ch.c_claim_header_id
                                                                   ,'В')
                                ,0) p_v
                            ,nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                   ,ch.c_claim_header_id
                                                                   ,'З')
                                ,0) p_z
                            ,CASE
                               WHEN nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                          ,ch.c_claim_header_id
                                                                          ,'В')
                                       ,0) > nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                                   ,ch.c_claim_header_id
                                                                                   ,'З')
                                                ,0) THEN
                                pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                  ,ch.c_claim_header_id
                                                                  ,'В')
                               ELSE
                                pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                  ,ch.c_claim_header_id
                                                                  ,'З')
                             END p37
                            ,tp.description
                            ,trunc(dmg.rec_end_date) - trunc(dmg.rec_start_date) + 1 rec_days
                        FROM ven_c_claim_header ch
                        JOIN ven_c_claim clm
                          ON (ch.active_claim_id = clm.c_claim_id)
                      --Чирков удаление старых связей заявителей
                      --join c_declarant_role dr on ch.declarant_role_id = dr.c_declarant_role_id
                      --join c_event_contact ec on (ch.declarant_id = ec.c_event_contact_id)
                        JOIN c_declarants cd
                          ON cd.c_claim_header_id = ch.c_claim_header_id
                         AND cd.c_declarants_id =
                             (SELECT MAX(cd_1.c_declarants_id)
                                FROM c_declarants cd_1
                               WHERE cd_1.c_claim_header_id = cd.c_claim_header_id)
                        JOIN c_event_contact ec
                          ON cd.declarant_id = ec.c_event_contact_id
                        JOIN c_declarant_role dr
                          ON cd.declarant_role_id = dr.c_declarant_role_id
                      --end_Чирков удаление старых связей заявителей
                        JOIN p_policy p
                          ON ch.p_policy_id = p.policy_id
                        JOIN ven_c_event e
                          ON ch.c_event_id = e.c_event_id
                        JOIN contact c
                          ON ec.cn_person_id = c.contact_id
                        JOIN ven_cn_person per
                          ON (ch.curator_id = per.contact_id)
                        LEFT JOIN department ct
                          ON ch.depart_id = ct.department_id
                        LEFT JOIN as_asset a
                          ON ch.as_asset_id = a.as_asset_id
                        LEFT JOIN as_assured asu
                          ON asu.as_assured_id = a.as_asset_id
                        LEFT JOIN cn_person casu
                          ON casu.contact_id = asu.assured_contact_id
                        LEFT JOIN t_profession prof
                          ON (casu.profession = prof.id)
                        LEFT JOIN fund f
                          ON (ch.fund_id = f.fund_id)
                        JOIN c_claim_metod_type cmt
                          ON ch.notice_type_id = cmt.c_claim_metod_type_id
                        LEFT JOIN p_cover pc
                          ON (ch.p_cover_id = pc.p_cover_id)
                        LEFT JOIN t_prod_line_option pl
                          ON pc.t_prod_line_option_id = pl.id
                        JOIN p_pol_header ph
                          ON ph.policy_header_id = p.pol_header_id
                        LEFT JOIN department dep
                          ON dep.department_id = ph.agency_id
                        LEFT JOIN t_product prod
                          ON prod.product_id = ph.product_id
                        LEFT JOIN t_peril tp
                          ON tp.id = ch.peril_id
                        LEFT JOIN t_prod_line_option opt
                          ON (opt.id = pc.t_prod_line_option_id)
                        LEFT JOIN c_damage dmg
                          ON (dmg.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg.c_claim_id AND
                             dmg.status_hist_id <> 3)
                        LEFT JOIN fund dmgf
                          ON (dmgf.fund_id = dmg.damage_fund_id)
                       WHERE e.c_event_id = p_event
                         AND ch.active_claim_id = p_claim)
               GROUP BY policy_id
                       ,p22
                       ,p23
                       ,peril
                       ,p24
                       ,p28
                       ,p31
                       ,p37
                       ,rec_days
                       ,peril_id
                       ,c_event_id) a
        LEFT JOIN v_claim_viplata b
          ON (b.c_event_id = a.c_event_id AND a.peril_name = b.description AND
             b.active_claim_id = p_claim);
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_vipl_wop;

  -- Веселуха 09.06.2009
  PROCEDURE set_tmptable_vipl(p_event NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_vipl';
  BEGIN
    NULL;
    DELETE FROM temp_tmptable_vipl;
    INSERT INTO temp_tmptable_vipl
      SELECT a.policy_id
            ,a.peril_name
            ,a.ins_amount
            ,a.payment_sum
            ,a.ins_paym
            ,a.flag
            ,a.rate_tbl
            ,a.rate_day
            ,a.kolvo
            ,a.viplata
            ,a.s_z
            ,a.s_v
            ,CASE
               WHEN a.peril_name LIKE 'Защита страховых%' THEN
                b.dko_date
               WHEN a.peril_name LIKE 'Освобождение%' THEN
                b.dko_date
               ELSE
                b.due_date
             END due_date
            ,a.diagnose
            ,b.real_z
            ,a.peril
            ,a.rec_days
            ,a.peril_id
            ,a.peril_d
        FROM (SELECT policy_id
                    ,p23 peril_name
                    ,p24 ins_amount
                    ,nvl(ot_claim, 0) payment_sum
                    ,p24 - nvl(ot_claim, 0) ins_paym
                    ,CASE
                       WHEN p23 LIKE '%оспитализация%' THEN
                        1
                       WHEN p23 LIKE '%трудоспособн%' THEN
                        1
                       ELSE
                        0
                     END flag
                    ,SUM(CASE
                           WHEN p23 LIKE '%оспитализация%' THEN
                            0
                           ELSE
                            (CASE
                              WHEN amount > 0 THEN
                               ROUND(nvl(paym, 0) * rate / (amount - nvl(ot_claim, 0)) * 100, 1)
                              ELSE
                               0
                            END)
                         END) rate_tbl
                    ,SUM(CASE
                           WHEN p23 NOT LIKE '%оспитализация%' THEN
                            0
                           ELSE
                            (CASE
                              WHEN amount > 0 THEN
                               ROUND(nvl(paym, 0) * rate / (amount - nvl(ot_claim, 0)) * 100, 1)
                              ELSE
                               0
                            END)
                         END) rate_day
                    ,'-' kolvo
                    ,CASE
                       WHEN p31 IS NULL THEN
                        ROUND(SUM((nvl(amount, 0) - nvl(ot_claim, 0)) * (CASE
                                    WHEN amount > 0 THEN
                                     (nvl(paym, 0) - nvl(decl, 0)) * rate / (amount - nvl(ot_claim, 0))
                                    ELSE
                                     0
                                  END))
                             ,2)
                       ELSE
                        0
                     END viplata
                    ,
                     --case when p31 is null then sum( (nvl(amount,0) - nvl(ot_claim,0)) * (case when amount > 0 then round((nvl(paym,0) - nvl(decl,0)) * rate / (amount - nvl(ot_claim,0)), 3) else 0 end) ) else 0 end viplata,
                     SUM(p_z) s_z
                    ,SUM(p_v) s_v
                    ,
                     --a.due_date,
                     /* case when a.p23 like 'Защита страховых%'
                     then b.dko_date
                     when a.p23 like 'Освобождение%'
                     then b.dko_date
                     else b.due_date
                     end due_date,*/
                     
                     p23 peril_d
                    ,p22 diagnose
                    ,
                     --sum(nvl(b.real_z,0)) real_z,
                     peril
                    ,rec_days
                    ,peril_id
                    ,c_event_id
                    ,t_prod_line_option_id
              
                FROM (SELECT DISTINCT p.policy_id
                                     ,e.c_event_id
                                     ,dmg.t_damage_code_id
                                     ,nvl(e.diagnose, '-') p22
                                     ,CASE
                                        WHEN opt.description LIKE 'Защита страховых%' THEN
                                         opt.description
                                        WHEN opt.description LIKE 'Освобождение%' THEN
                                         opt.description
                                        WHEN opt.description LIKE '%Дожитие%по независящим%' THEN
                                         opt.description
                                        ELSE
                                         nvl(tp.description, '-')
                                      END p23
                                     ,tp.id peril_id
                                     ,CASE
                                        WHEN opt.description LIKE 'Защита страховых%' THEN
                                         1
                                        WHEN opt.description LIKE 'Освобождение%' THEN
                                         1
                                        ELSE
                                         0
                                      END peril
                                     ,nvl(pc.ins_amount, 0) p24
                                     ,nvl(pc.ins_amount, 0) amount
                                     ,nvl(dmg.decline_sum, 0) decl
                                     ,nvl(dmg.declare_sum, 0) paym
                                     ,(SELECT SUM(nvl(x.payment_sum, 0))
                                         FROM v_other_claim_header x
                                             ,c_claim_header       hl
                                             ,p_cover              pc
                                        WHERE x.c_claim_header_id = hl.c_claim_header_id
                                          AND hl.c_event_id = ch.c_event_id
                                          AND x.c_claim_header_id = ch.c_claim_header_id
                                          AND hl.p_policy_id = ch.p_policy_id
                                          AND pc.p_cover_id = hl.p_cover_id
                                          AND nvl(pc.is_aggregate, 0) = 1
                                          AND hl.p_cover_id = ch.p_cover_id
                                          AND x.as_asset_id = a.as_asset_id
                                          AND x.policy_id = hl.p_policy_id) ot_claim
                                     ,nvl(acc.get_cross_rate_by_brief(1
                                                                     ,dmgf.brief
                                                                     ,f.brief
                                                                     ,ch.declare_date)
                                         ,1) rate
                                     ,e.c_event_id p28
                                     ,CASE
                                        WHEN (nvl(dmg.payment_sum, 0)) = 0 THEN
                                         (SELECT decode(doc.get_last_doc_status_name(clm3.c_claim_id)
                                                       ,'Урегулируется'
                                                       ,clm3.claim_status_date
                                                       ,'Закрыт'
                                                       ,clm3.claim_status_date)
                                            FROM ven_c_claim clm3
                                           WHERE clm3.c_claim_header_id = ch.c_claim_header_id
                                             AND rownum = 1
                                             AND doc.get_last_doc_status_name(clm3.c_claim_id) IN
                                                 ('Урегулируется', 'Закрыт'))
                                      END p31
                                     ,nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                            ,ch.c_claim_header_id
                                                                            ,'В')
                                         ,0) p_v
                                     ,nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                            ,ch.c_claim_header_id
                                                                            ,'З')
                                         ,0) p_z
                                     ,CASE
                                        WHEN nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                                   ,ch.c_claim_header_id
                                                                                   ,'В')
                                                ,0) > nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                                            ,ch.c_claim_header_id
                                                                                            ,'З')
                                                         ,0) THEN
                                         pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                           ,ch.c_claim_header_id
                                                                           ,'В')
                                        ELSE
                                         pkg_renlife_utils.ret_amount_claim(e.c_event_id
                                                                           ,ch.c_claim_header_id
                                                                           ,'З')
                                      END p37
                                     ,
                                      /*case when opt.description like 'Защита страховых%'
                                      then vp.dko_date
                                      when opt.description like 'Освобождение%'
                                      then vp.dko_date
                                      else vp.due_date
                                      end due_date,*/tp.description
                                     ,
                                      --nvl(vp.real_z,0) real_z,
                                      trunc(dmg.rec_end_date) - trunc(dmg.rec_start_date) + 1 rec_days
                                     ,pc.t_prod_line_option_id
                        FROM ven_c_claim_header ch
                        JOIN ven_c_claim clm
                          ON (ch.active_claim_id = clm.c_claim_id)
                      --Чирков удаление старых связей заявителей
                      --join c_declarant_role dr on ch.declarant_role_id = dr.c_declarant_role_id
                      --join c_event_contact ec on (ch.declarant_id = ec.c_event_contact_id)
                        JOIN c_declarants cd
                          ON cd.c_claim_header_id = ch.c_claim_header_id
                         AND cd.c_declarants_id =
                             (SELECT MAX(cd_1.c_declarants_id)
                                FROM c_declarants cd_1
                               WHERE cd_1.c_claim_header_id = cd.c_claim_header_id)
                        JOIN c_event_contact ec
                          ON cd.declarant_id = ec.c_event_contact_id
                        JOIN c_declarant_role dr
                          ON cd.declarant_role_id = dr.c_declarant_role_id
                      --end_Чирков удаление старых связей заявителей
                      
                        JOIN p_policy p
                          ON ch.p_policy_id = p.policy_id
                        JOIN ven_c_event e
                          ON ch.c_event_id = e.c_event_id
                        JOIN contact c
                          ON ec.cn_person_id = c.contact_id
                        JOIN ven_cn_person per
                          ON (ch.curator_id = per.contact_id)
                        LEFT JOIN department ct
                          ON ch.depart_id = ct.department_id
                        LEFT JOIN as_asset a
                          ON ch.as_asset_id = a.as_asset_id
                        LEFT JOIN as_assured asu
                          ON asu.as_assured_id = a.as_asset_id
                        LEFT JOIN cn_person casu
                          ON casu.contact_id = asu.assured_contact_id
                        LEFT JOIN t_profession prof
                          ON (casu.profession = prof.id)
                        LEFT JOIN fund f
                          ON (ch.fund_id = f.fund_id)
                        JOIN c_claim_metod_type cmt
                          ON ch.notice_type_id = cmt.c_claim_metod_type_id
                        LEFT JOIN p_cover pc
                          ON (ch.p_cover_id = pc.p_cover_id)
                        LEFT JOIN t_prod_line_option pl
                          ON pc.t_prod_line_option_id = pl.id
                        JOIN p_pol_header ph
                          ON ph.policy_header_id = p.pol_header_id
                        LEFT JOIN department dep
                          ON dep.department_id = ph.agency_id
                        LEFT JOIN t_product prod
                          ON prod.product_id = ph.product_id
                        LEFT JOIN t_peril tp
                          ON tp.id = ch.peril_id
                        LEFT JOIN t_prod_line_option opt
                          ON (opt.id = pc.t_prod_line_option_id)
                        LEFT JOIN c_damage dmg
                          ON (dmg.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg.c_claim_id AND
                             dmg.status_hist_id <> 3)
                      --left join v_claim_viplata vp on (vp.c_event_id = e.c_event_id and tp.description = vp.description)
                        LEFT JOIN fund dmgf
                          ON (dmgf.fund_id = dmg.damage_fund_id)
                       WHERE e.c_event_id = p_event
                         AND doc.get_last_doc_status_name(ch.active_claim_id) <> 'Закрыт')
               GROUP BY policy_id
                       ,p22
                       ,p23
                       ,peril
                       ,p24
                       ,p24 - ot_claim
                       ,p28
                       ,ot_claim
                       ,p31
                       ,p37
                       ,rec_days
                       ,peril_id
                       ,c_event_id
                       ,t_prod_line_option_id) a
        LEFT JOIN ins.v_claim_viplata b
          ON (b.c_event_id = a.c_event_id AND a.peril_name = b.description AND
             b.opt_id = a.t_prod_line_option_id);
  
    DELETE FROM temp_payment_reqst;
    INSERT INTO temp_payment_reqst
      SELECT start_date
            ,num
            ,pol
            ,ltrim(to_char(amount
                          ,'999G999G999G999G999G999G990D99'
                          ,'NLS_NUMERIC_CHARACTERS = '', ''')) amount
            ,brief
            ,flag
            ,bank
            ,bank_adr
            ,bic
            ,account_corr
            ,beneficiary
            ,beneficiary_adr
            ,inn
            ,account_nr
            ,cpp
            ,note
            ,prod
            ,region_code
            ,prep
            ,status_claim
            ,code
      --into :start_date,:num,:pol,:amount,:brief,:flag,:bank,:bank_adr,:bic,:account_corr,:beneficiary,:beneficiary_adr,:inn,:account_nr,:cpp,:note,:prod,:region_code,:prep,:status_claim,:code
        FROM (SELECT start_date
                    ,num
                    ,pol
                    ,CASE
                       WHEN s_z >= (amount) THEN
                        1
                       ELSE
                        0
                     END flag
                    ,CASE
                       WHEN s_z >= (amount) THEN
                        s_z
                       ELSE
                        s_v
                     END amount
                    ,brief
                    ,fund_id
                    ,bank
                    ,bank_adr
                    ,bic
                    ,account_corr
                    ,beneficiary
                    ,beneficiary_adr
                    ,inn
                    ,account_nr
                    ,cpp
                    ,CASE
                       WHEN nvl(lic_code, 'X') = 'X' THEN
                        CASE
                          WHEN nvl(paym_porp, 'X') = 'X' THEN
                           ''
                          ELSE
                           'Банковская карта № ' || paym_porp
                        END
                       ELSE
                        'Лицевой счет № ' || lic_code
                     END note
                    ,prod
                    ,region_code
                    ,prep
                    ,status_claim
                    ,code
                FROM (SELECT to_char(ph.start_date, 'dd.mm.yyyy') start_date
                            ,e.num
                            ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) pol
                            ,SUM(nvl(pkg_renlife_utils.ret_amount_active(ch.c_claim_header_id
                                                                        ,'PAYORDER_SETOFF')
                                    ,0)) s_z
                            ,SUM(nvl(pkg_renlife_utils.ret_amount_active(ch.c_claim_header_id
                                                                        ,'PAYORDER')
                                    ,0)) s_v
                            ,SUM(d.payment_sum) amount
                            ,f_pol.brief
                            ,f_pol.fund_id
                            ,bb.bank_name || ' ' || bb.branch_name bank
                            ,adr.address_name bank_adr
                            ,bic.id_value bic
                            ,krc.id_value account_corr
                            , --bb.account_corr,
                             --ent.obj_name(a.ent_id, a.as_asset_id) beneficiary,
                             cont.obj_name_orig beneficiary
                            ,adr.address_name   beneficiary_adr
                            ,inn.id_value       inn
                            ,
                             --krc.id_value krc,
                             bb.account_nr
                            ,cpp.id_value cpp
                            ,prod.brief prod
                            ,'' region_code
                            ,decode(us.name
                                   ,'Панферова Валерия Олеговна'
                                   ,'Панферова В.О.'
                                   ,'Асланова Елена Федоровна'
                                   ,'Асланова Е.Ф.'
                                   ,'Асланова Елена Фёдоровна'
                                   ,'Асланова Е.Ф.'
                                   ,'Кутенкова Марина Юрьевна'
                                   ,'Кутенкова М.Ю.'
                                   ,'Вера Вадимовна Лопотовская'
                                   ,'Лопотовская В.В.'
                                   ,us.name) prep
                            ,nvl(to_char(d_stat.status_claim, 'dd.mm.yyyy'), '') status_claim
                            ,nvl(substr(pr.kladr_code, 1, 2), '') code
                            ,(SELECT MAX(bac.lic_code) keep(dense_rank FIRST ORDER BY ds.start_date DESC) --bac.lic_code, ds.start_date, dac.cn_document_bank_acc_id acc_doc_id, bac.contact_id
                                FROM ins.cn_contact_bank_acc  bac
                                    ,ins.cn_document_bank_acc dac
                                    ,doc_status               ds
                               WHERE bac.contact_id = cont.contact_id
                                 AND bac.used_flag = 1
                                 AND bac.id = dac.cn_contact_bank_acc_id
                                 AND dac.cn_document_bank_acc_id = ds.document_id
                                 AND ds.start_date =
                                     (SELECT MAX(dsz.start_date)
                                        FROM doc_status     dsz
                                            ,doc_status_ref rf
                                       WHERE dsz.document_id = dac.cn_document_bank_acc_id
                                         AND dsz.doc_status_ref_id = rf.doc_status_ref_id
                                         AND rf.brief = 'ACTIVE')
                                 AND bac.lic_code IS NOT NULL) lic_code
                            ,(SELECT MAX(bac.account_corr) keep(dense_rank FIRST ORDER BY ds.start_date DESC)
                                FROM ins.cn_contact_bank_acc  bac
                                    ,ins.cn_document_bank_acc dac
                                    ,doc_status               ds
                               WHERE bac.contact_id = cont.contact_id
                                 AND bac.used_flag = 1
                                 AND bac.id = dac.cn_contact_bank_acc_id
                                 AND dac.cn_document_bank_acc_id = ds.document_id
                                 AND ds.start_date = (SELECT MAX(ds.start_date)
                                                        FROM document       d
                                                            ,doc_status     ds
                                                            ,doc_status_ref rf
                                                       WHERE d.document_id = dac.cn_document_bank_acc_id
                                                         AND d.document_id = ds.document_id
                                                         AND ds.doc_status_ref_id = rf.doc_status_ref_id
                                                         AND rf.brief = 'ACTIVE')
                                 AND bac.account_corr IS NOT NULL) paym_porp
                      --decode(doc.get_last_doc_status_name(ch.active_claim_id),'Принято решение', to_char(clm.claim_status_date,'dd.mm.yyyy'),'') status_claim
                        FROM ven_c_claim_header  ch
                            ,ven_c_claim         clm
                            ,ven_p_policy        p
                            ,p_pol_header        ph
                            ,department          dep
                            ,organisation_tree   ot
                            ,t_province          pr
                            ,t_product           prod
                            ,fund                f_pol
                            ,ven_c_event         e
                            ,ven_c_event_contact ec
                            ,c_declarants        cd
                            ,
                             --cn_contact_bank_acc bb,
                             (SELECT bb.bank_id
                                    ,bb.account_nr
                                    ,bb.bank_name
                                    ,bb.branch_name
                                    ,bb.contact_id
                                FROM cn_contact_bank_acc bb
                               WHERE nvl(bb.used_flag, 0) = 1) bb
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 10) bic
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 1) inn
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 20022) cpp
                            ,(SELECT ii.id_value
                                    ,ii.contact_id
                                FROM cn_contact_ident ii
                               WHERE ii.id_type = 11) krc
                            ,
                             
                             v_cn_contact_address adr
                            ,contact cont
                            ,ven_sys_user us
                            ,c_damage d
                            ,(SELECT MAX(trunc(ds.start_date)) status_claim
                                    ,ch.c_claim_header_id
                                FROM doc_status         ds
                                    ,ven_c_claim_header ch
                               WHERE ds.document_id = ch.active_claim_id
                                 AND ds.doc_status_ref_id = 128
                                 AND doc.get_last_doc_status_name(ch.active_claim_id) <> 'Закрыт'
                               GROUP BY ch.c_claim_header_id) d_stat
                      
                       WHERE ch.p_policy_id = p.policy_id
                         AND d.c_claim_id = ch.active_claim_id
                         AND ph.policy_header_id = p.pol_header_id
                         AND prod.product_id = ph.product_id
                         AND ch.active_claim_id = clm.c_claim_id
                         AND f_pol.fund_id = ph.fund_id
                         AND ec.cn_person_id = bb.contact_id(+)
                         AND bb.bank_id = bic.contact_id(+)
                         AND bb.bank_id = inn.contact_id(+)
                         AND bb.bank_id = cpp.contact_id(+)
                         AND bb.bank_id = krc.contact_id(+)
                         AND bb.bank_id = adr.contact_id(+)
                         AND d_stat.c_claim_header_id(+) = ch.c_claim_header_id
                            --and ass.assured_contact_id = lic.contact_id(+)
                            --and ass.assured_contact_id = cont.contact_id
                            
                            --Чирков удаление старых связей заявителей
                            --and ch.declarant_id = ec.c_event_contact_id
                         AND cd.c_claim_header_id = ch.c_claim_header_id
                         AND cd.declarant_id = ec.c_event_contact_id
                         AND cd.c_declarants_id =
                             (SELECT MAX(cd_1.c_declarants_id)
                                FROM c_declarants cd_1
                               WHERE cd_1.c_claim_header_id = cd.c_claim_header_id)
                            --end_Чирков удаление старых связей заявителей
                         AND ec.cn_person_id = cont.contact_id
                            
                         AND us.sys_user_name = USER
                         AND dep.department_id(+) = ph.agency_id
                         AND ot.organisation_tree_id(+) = dep.org_tree_id
                         AND pr.province_id(+) = ot.province_id
                         AND ch.c_event_id = e.c_event_id
                         AND e.c_event_id = ch.c_event_id
                         AND e.c_event_id = p_event
                         AND doc.get_last_doc_status_name(ch.active_claim_id) <> 'Закрыт'
                       GROUP BY to_char(ph.start_date, 'dd.mm.yyyy')
                               ,e.num
                               ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num)
                               ,f_pol.brief
                               ,f_pol.fund_id
                               ,bb.bank_name || ' ' || bb.branch_name
                               ,adr.address_name
                               ,bic.id_value
                               ,krc.id_value
                               ,cont.obj_name_orig
                               ,adr.address_name
                               ,bb.bank_id
                               ,inn.id_value
                               ,bb.account_nr
                               ,cpp.id_value
                               ,prod.brief
                               ,cont.contact_id
                               ,decode(us.name
                                      ,'Панферова Валерия Олеговна'
                                      ,'Панферова В.О.'
                                      ,'Асланова Елена Федоровна'
                                      ,'Асланова Е.Ф.'
                                      ,'Асланова Елена Фёдоровна'
                                      ,'Асланова Е.Ф.'
                                      ,'Кутенкова Марина Юрьевна'
                                      ,'Кутенкова М.Ю.'
                                      ,'Вера Вадимовна Лопотовская'
                                      ,'Лопотовская В.В.'
                                      ,us.name)
                               ,nvl(to_char(d_stat.status_claim, 'dd.mm.yyyy'), '')
                               ,nvl(substr(pr.kladr_code, 1, 2), '')))
       WHERE rownum = 1;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_vipl;

  PROCEDURE exec_sql(p_str VARCHAR2) IS
    par_s VARCHAR2(6);
    no_exec EXCEPTION;
  BEGIN
  
    BEGIN
      SELECT substr(TRIM(p_str), 1, 6) INTO par_s FROM dual;
    EXCEPTION
      WHEN no_data_found THEN
        par_s := 'X';
    END;
  
    IF upper(par_s) = 'SELECT'
    THEN
      EXECUTE IMMEDIATE p_str;
    ELSE
      RAISE no_exec;
    END IF;
  EXCEPTION
    WHEN no_exec THEN
      raise_application_error(-20001
                             ,'Невозможно выполнить код. Строка не начинается с SELECT.');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при попытке выполнить ' || p_str || ' ' || SQLERRM);
  END exec_sql;

  PROCEDURE set_tmptable_comvipl(p_event NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_comvipl';
  BEGIN
    DELETE FROM temp_tmptable_comvipl;
    INSERT INTO temp_tmptable_comvipl
    /*select distinct p.policy_id,
           tp.description,
           (select vcl.amount
           from v_claim_payment_schedule vcl
           where vcl.c_claim_header_id = ch.c_claim_header_id
                 and vcl.doc_templ_brief = 'PAYORDER')
    from ven_c_claim_header     ch,
           ven_c_declarant_role   dr,
           ven_p_policy           p,
           ven_c_event            e,
           ven_c_event_contact    ec,
           ven_contact            c,
           ven_cn_person          per,
           ven_department         ct,
           ven_as_asset           a,
           ven_fund               f,
           ven_c_claim_metod_type cmt,
           ven_p_cover            pc,
           ven_t_prod_line_option pl,
           ven_p_pol_header       ph,
           ven_t_product          prod,
           ven_t_peril            tp,
           v_other_claim_header ovr,
           ven_c_damage dmg,
           ven_t_damage_code dc,
           fund dmgf
    where ch.notice_type_id = cmt.c_claim_metod_type_id
       and ch.declarant_role_id = dr.c_declarant_role_id
       and ch.p_policy_id = p.policy_id
       and ch.c_event_id = e.c_event_id
       and ch.declarant_id = ec.c_event_contact_id
       and ec.cn_person_id = c.contact_id
       and prod.product_id = ph.product_id
       and ch.curator_id = per.contact_id
       and ch.depart_id = ct.department_id(+)
       and ch.as_asset_id = a.as_asset_id
       and ch.fund_id = f.fund_id(+)
       and ch.p_cover_id = pc.p_cover_id(+)
       and pc.t_prod_line_option_id = pl.id(+)
       and ph.policy_header_id = p.pol_header_id
       and tp.id(+) = ch.peril_id
       and ovr.c_claim_header_id(+) = ch.c_claim_header_id
       and dmg.p_cover_id(+) = pc.p_cover_id
       and dmg.t_damage_code_id = dc.id(+)
       and ch.active_claim_id = dmg.c_claim_id
       and dmgf.fund_id = dmg.damage_fund_id
       and e.c_event_id = p_event
    union
    select distinct null,
           'Итоговая сумма:',
           sum(vp.s_v)
    from v_claim_viplata vp
    where vp.c_event_id = p_event;*/
    
      SELECT vp.policy_id
            ,peril_name
            ,CASE
               WHEN real_z > 0 THEN
                (CASE
                  WHEN viplata - real_z > 0 THEN
                   viplata - real_z
                  ELSE
                   viplata
                END)
               ELSE
                viplata
             END
        FROM temp_tmptable_vipl vp
       WHERE peril <> 1
      UNION
      SELECT NULL
            ,'Итоговая сумма:'
            ,SUM(CASE
                   WHEN real_z > 0 THEN
                    (CASE
                      WHEN viplata - real_z > 0 THEN
                       viplata - real_z
                      ELSE
                       viplata
                    END)
                   ELSE
                    viplata
                 END)
        FROM temp_tmptable_vipl vp
       WHERE peril <> 1;
  
    NULL;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_comvipl;

  PROCEDURE set_tmptable_ben(p_as_asset NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_ben';
  BEGIN
    DELETE FROM temp_tmptable_ben;
    INSERT INTO temp_tmptable_ben
      SELECT rownum
            ,c.obj_name_orig
            ,b.as_asset_id
        FROM as_beneficiary b
            ,contact        c
       WHERE b.contact_id = c.contact_id
         AND b.as_asset_id = p_as_asset;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_ben;

  PROCEDURE set_tmptable_event_wop
  (
    p_event NUMBER
   ,p_claim NUMBER
  ) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_event_WOP';
    n VARCHAR2(10);
  BEGIN
    DELETE FROM temp_tmptable_event;
  
    INSERT INTO temp_tmptable_event
      SELECT num
            ,pol
            ,prod
            ,brief
            ,start_date
            ,end_date
            ,beneficiary
            ,holder
            ,name_1 || ' ' || name_2 || ' ' || name_3 || ' ' || name_4 vigod
            ,AGENT
            ,event_date
            ,status_claim
            ,pol_vipl
            ,header_end_date
            ,peril
            ,0
            ,0
        FROM (SELECT DISTINCT e.num
                             ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) pol
                             ,prod.description prod
                             ,f.brief
                             ,to_char(p.end_date, 'DD.MM.YYYY') header_end_date
                             ,to_char(ph.start_date, 'DD.MM.YYYY') start_date
                             ,to_char(pc.end_date, 'DD.MM.YYYY') end_date
                             ,ent.obj_name(a.ent_id, a.as_asset_id) beneficiary
                             ,(SELECT c.obj_name_orig
                                 FROM p_policy_contact pco
                                     ,contact          c
                                WHERE pco.contact_id = c.contact_id
                                  AND pco.contact_policy_role_id = 6
                                  AND pco.policy_id = p.policy_id) holder
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 1
                                  AND vgd.as_asset_id = a.as_asset_id) name_1
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 2
                                  AND vgd.as_asset_id = a.as_asset_id) name_2
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 3
                                  AND vgd.as_asset_id = a.as_asset_id) name_3
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 4
                                  AND vgd.as_asset_id = a.as_asset_id) name_4
                             ,(SELECT c.obj_name_orig
                                 FROM ins.p_policy_agent_doc pad
                                     ,ag_contract_header     ag
                                     ,contact                c
                                WHERE pad.ag_contract_header_id = ag.ag_contract_header_id
                                  AND ag.agent_id = c.contact_id
                                  AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                                  AND pad.policy_header_id = p.pol_header_id
                                  AND rownum = 1) AGENT
                             ,to_char(e.event_date, 'DD.MM.YYYY') event_date
                             ,(SELECT to_char(MAX(ds.start_date), 'dd.mm.yyyy')
                                 FROM ven_c_claim clm2
                                     ,doc_status  ds
                                WHERE clm2.c_claim_header_id = ch.c_claim_header_id
                                  AND ds.document_id = clm2.c_claim_id
                                  AND ds.doc_status_ref_id = 128) status_claim
                             ,c.obj_name_orig pol_vipl
                             ,CASE
                                WHEN pl.description LIKE 'Защита страховых%' THEN
                                 1
                                WHEN pl.description LIKE 'Освобождение%' THEN
                                 1
                                ELSE
                                 0
                              END peril
                FROM ven_c_claim_header     ch
                    ,ven_c_claim            clm
                    ,ven_c_declarant_role   dr
                    ,ven_p_policy           p
                    ,ven_c_event            e
                    ,ven_c_event_contact    ec
                    ,c_declarants           cd
                    ,ven_contact            c
                    ,ven_cn_person          per
                    ,ven_department         ct
                    ,ven_as_asset           a
                    ,ven_fund               f
                    ,ven_c_claim_metod_type cmt
                    ,ven_p_cover            pc
                    ,ven_t_prod_line_option pl
                    ,ven_p_pol_header       ph
                    ,ven_t_product          prod
                    ,ven_t_peril            tp
               WHERE ch.notice_type_id = cmt.c_claim_metod_type_id
                 AND ch.p_policy_id = p.policy_id
                 AND ch.c_event_id = e.c_event_id
                    --Чирков удаление старых связей заявителей
                    --and ch.declarant_id = ec.c_event_contact_id
                    --and ch.declarant_role_id = dr.c_declarant_role_id
                 AND cd.c_claim_header_id = ch.c_claim_header_id
                 AND cd.declarant_id = ec.c_event_contact_id
                 AND cd.c_declarants_id =
                     (SELECT MAX(cd_1.c_declarants_id)
                        FROM c_declarants cd_1
                       WHERE cd_1.c_claim_header_id = cd.c_claim_header_id)
                 AND dr.c_declarant_role_id = cd.declarant_role_id
                    --end_Чирков удаление старых связей заявителей
                 AND ec.cn_person_id = c.contact_id
                 AND prod.product_id = ph.product_id
                 AND ch.active_claim_id = clm.c_claim_id
                 AND ch.curator_id = per.contact_id
                 AND ch.depart_id = ct.department_id(+)
                 AND ch.as_asset_id = a.as_asset_id
                 AND ch.fund_id = f.fund_id(+)
                 AND ch.p_cover_id = pc.p_cover_id(+)
                 AND pc.t_prod_line_option_id = pl.id(+)
                 AND ph.policy_header_id = p.pol_header_id
                 AND tp.id(+) = ch.peril_id
                 AND ch.active_claim_id = p_claim
                 AND e.c_event_id = p_event);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_event_wop;

  PROCEDURE set_tmptable_event(p_event NUMBER) IS
    proc_name CONSTANT VARCHAR2(2000) := 'set_tmptable_event';
    n               VARCHAR2(10);
    v_srok_pc_short NUMBER;
    v_srok_pc_long  NUMBER;
  BEGIN
    DELETE FROM temp_tmptable_event;
  
    INSERT INTO temp_tmptable_event
      SELECT num
            ,pol
            ,prod
            ,brief
            ,start_date
            ,end_date
            ,beneficiary
            ,holder
            ,name_1 || ' ' || name_2 || ' ' || name_3 || ' ' || name_4 vigod
            ,AGENT
            ,event_date
            ,status_claim
            ,pol_vipl
            ,header_end_date
            ,peril
            ,(nvl(amount, 0) - nvl(ot_claim, 0)) * (CASE
               WHEN amount > 0 THEN
                ROUND((nvl(paym, 0) - nvl(decl, 0)) * rate / (amount - nvl(ot_claim, 0)), 3)
               ELSE
                0
             END) viplata
            ,srok_pc
        FROM (SELECT DISTINCT e.num
                             ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) pol
                             ,prod.description prod
                             ,f.brief
                             ,to_char(p.end_date, 'DD.MM.YYYY') header_end_date
                             ,to_char(ph.start_date, 'DD.MM.YYYY') start_date
                             ,
                              
                              CASE
                                WHEN trunc(MONTHS_BETWEEN(trunc(pc.end_date) + 1, trunc(pc.start_date)) / 12
                                          ,2) > 1 THEN
                                 to_char(pc.end_date, 'DD.MM.YYYY')
                                ELSE
                                 nvl((SELECT to_char(pcp.end_date, 'DD.MM.YYYY')
                                       FROM p_policy           ppol
                                           ,as_asset           ap
                                           ,as_assured         assp
                                           ,p_cover            pcp
                                           ,ven_status_hist    ht
                                           ,t_prod_line_option optp
                                      WHERE pkg_policy.get_last_version(ph.policy_header_id) =
                                            ppol.policy_id
                                        AND ppol.policy_id = ap.p_policy_id
                                        AND ap.as_asset_id = pcp.as_asset_id
                                        AND ap.as_asset_id = assp.as_assured_id
                                        AND assp.assured_contact_id = ass.assured_contact_id
                                        AND pcp.t_prod_line_option_id = optp.id
                                        AND pcp.status_hist_id = ht.status_hist_id
                                        AND ht.brief != 'DELETED'
                                        AND optp.id = pl.id)
                                    ,to_char(pc.end_date, 'DD.MM.YYYY'))
                              END end_date
                             ,
                              
                              --to_char(pc.end_date,'DD.MM.YYYY') end_date,
                              ent.obj_name(a.ent_id, a.as_asset_id) beneficiary
                             ,
                              
                              trunc(MONTHS_BETWEEN(trunc(pc.end_date) + 1, trunc(pc.start_date)) / 12
                                   ,2) srok_pc
                             ,trunc(MONTHS_BETWEEN(trunc(p.end_date) + 1, trunc(ph.start_date)) / 12
                                   ,2) srok_pol
                             ,
                              
                              (SELECT c.obj_name_orig
                                 FROM p_policy_contact pco
                                     ,contact          c
                                WHERE pco.contact_id = c.contact_id
                                  AND pco.contact_policy_role_id = 6
                                  AND pco.policy_id = p.policy_id) holder
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 1
                                  AND vgd.as_asset_id = a.as_asset_id) name_1
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 2
                                  AND vgd.as_asset_id = a.as_asset_id) name_2
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 3
                                  AND vgd.as_asset_id = a.as_asset_id) name_3
                             ,(SELECT vgd.name
                                 FROM temp_tmptable_ben vgd
                                WHERE rn = 4
                                  AND vgd.as_asset_id = a.as_asset_id) name_4
                             ,(SELECT c.obj_name_orig
                                 FROM ins.p_policy_agent_doc pad
                                     ,ag_contract_header     ag
                                     ,contact                c
                                WHERE pad.ag_contract_header_id = ag.ag_contract_header_id
                                  AND ag.agent_id = c.contact_id
                                  AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                                  AND pad.policy_header_id = p.pol_header_id
                                  AND rownum = 1) AGENT
                             ,to_char(e.event_date, 'DD.MM.YYYY') event_date
                             ,(SELECT to_char(MAX(ds.start_date), 'dd.mm.yyyy')
                                 FROM ven_c_claim clm2
                                     ,doc_status  ds
                                WHERE clm2.c_claim_header_id = ch.c_claim_header_id
                                  AND ds.document_id = clm2.c_claim_id
                                  AND ds.doc_status_ref_id = 128) status_claim
                             ,c.obj_name_orig pol_vipl
                             ,CASE
                                WHEN pl.description LIKE 'Защита страховых%' THEN
                                 1
                                WHEN pl.description LIKE 'Освобождение%' THEN
                                 1
                                ELSE
                                 0
                              END peril
                             ,nvl(pc.ins_amount, 0) amount
                             ,nvl(dmg.decline_sum, 0) decl
                             ,nvl(dmg.declare_sum, 0) paym
                             ,(SELECT SUM(nvl(x.payment_sum, 0))
                                 FROM v_other_claim_header x
                                     ,c_claim_header       hl
                                     ,p_cover              pc
                                WHERE x.c_claim_header_id = hl.c_claim_header_id
                                  AND hl.c_event_id = ch.c_event_id
                                  AND x.c_claim_header_id = ch.c_claim_header_id
                                  AND hl.p_policy_id = ch.p_policy_id
                                  AND pc.p_cover_id = hl.p_cover_id
                                  AND nvl(pc.is_aggregate, 0) = 1
                                  AND hl.p_cover_id = ch.p_cover_id
                                  AND x.as_asset_id = a.as_asset_id
                                  AND x.policy_id = hl.p_policy_id) ot_claim
                             ,nvl(acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, ch.declare_date)
                                 ,1) rate
                FROM ven_c_claim_header ch
                JOIN ven_c_claim clm
                  ON (ch.active_claim_id = clm.c_claim_id)
              --join ven_c_declarant_role   dr on (ch.declarant_role_id = dr.c_declarant_role_id)
              --join ven_c_event_contact    ec on (ch.declarant_id = ec.c_event_contact_id)
              --Чирков удаление старых связей заявителей
                JOIN c_declarants cd
                  ON cd.c_claim_header_id = ch.c_claim_header_id
                 AND cd.c_declarants_id =
                     (SELECT MAX(cd_1.c_declarants_id)
                        FROM c_declarants cd_1
                       WHERE cd_1.c_claim_header_id = cd.c_claim_header_id)
                JOIN c_event_contact ec
                  ON cd.declarant_id = ec.c_event_contact_id
                JOIN c_declarant_role dr
                  ON cd.declarant_role_id = dr.c_declarant_role_id
              --end_Чирков удаление старых связей заявителей
                JOIN ven_p_policy p
                  ON (ch.p_policy_id = p.policy_id)
                JOIN ven_c_event e
                  ON (ch.c_event_id = e.c_event_id)
                JOIN ven_contact c
                  ON (ec.cn_person_id = c.contact_id)
                JOIN ven_cn_person per
                  ON (ch.curator_id = per.contact_id)
                LEFT JOIN ven_department ct
                  ON (ch.depart_id = ct.department_id)
                JOIN ven_as_asset a
                  ON (ch.as_asset_id = a.as_asset_id)
                JOIN as_assured ass
                  ON (a.as_asset_id = ass.as_assured_id)
                LEFT JOIN ven_fund f
                  ON (ch.fund_id = f.fund_id)
                JOIN ven_c_claim_metod_type cmt
                  ON (ch.notice_type_id = cmt.c_claim_metod_type_id)
                LEFT JOIN ven_p_cover pc
                  ON (ch.p_cover_id = pc.p_cover_id)
                LEFT JOIN ven_t_prod_line_option pl
                  ON (pc.t_prod_line_option_id = pl.id)
                JOIN ven_p_pol_header ph
                  ON (ph.policy_header_id = p.pol_header_id)
                JOIN ven_t_product prod
                  ON (prod.product_id = ph.product_id)
                LEFT JOIN ven_t_peril tp
                  ON (tp.id = ch.peril_id)
                LEFT JOIN c_damage dmg
                  ON (dmg.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg.c_claim_id AND
                     dmg.status_hist_id <> 3)
                LEFT JOIN fund dmgf
                  ON (dmgf.fund_id = dmg.damage_fund_id)
               WHERE doc.get_last_doc_status_name(ch.active_claim_id) <> 'Закрыт'
                    
                 AND e.c_event_id = p_event);
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END set_tmptable_event;

  -- Веселуха 02.06.2009
  FUNCTION f_param
  (
    p_func  VARCHAR2
   ,p_param NUMBER
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    RESULT VARCHAR2(100);
  BEGIN
    RESULT := '';
    CASE
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_accum' THEN
        pkg_renlife_utils.set_tmptable_accum(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_surr' THEN
        pkg_renlife_utils.set_tmptable_surr(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_event' THEN
        pkg_renlife_utils.set_tmptable_event(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_vipl' THEN
        pkg_renlife_utils.set_tmptable_vipl(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_comvipl' THEN
        pkg_renlife_utils.set_tmptable_comvipl(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_agent' THEN
        pkg_renlife_utils.set_tmptable_agent(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_agento' THEN
        pkg_renlife_utils.set_tmptable_agento(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_zakl' THEN
        pkg_renlife_utils.set_tmptable_zakl(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_dzakl' THEN
        pkg_renlife_utils.set_tmptable_dzakl(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_ben' THEN
        pkg_renlife_utils.set_tmptable_ben(p_param);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_paym' THEN
        pkg_renlife_utils.set_tmptable_paym(p_param);
      ELSE
        RESULT := '';
    END CASE;
    COMMIT;
    RETURN(RESULT);
  END;

  FUNCTION f_param
  (
    p_func   VARCHAR2
   ,p_param1 NUMBER
   ,p_param2 NUMBER
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    RESULT VARCHAR2(100);
  BEGIN
    RESULT := '';
    CASE
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_vipl_WOP' THEN
        pkg_renlife_utils.set_tmptable_vipl_wop(p_param1, p_param2);
      WHEN p_func = 'pkg_renlife_utils.set_tmptable_event_WOP' THEN
        pkg_renlife_utils.set_tmptable_event_wop(p_param1, p_param2);
      ELSE
        RESULT := '';
    END CASE;
    COMMIT;
    RETURN(RESULT);
  END;

  PROCEDURE create_mv(p_view VARCHAR2) IS
  BEGIN
    dbms_mview.refresh(p_view);
  END;

  PROCEDURE set_tmptable_accum(p_policy_header_id NUMBER) IS
    func_name CONSTANT VARCHAR2(2000) := 'set_tmptable_accum';
    cnt NUMBER;
  BEGIN
  
    --delete from temp_tmptable_accum;
    SELECT COUNT(*)
      INTO cnt
      FROM temp_tmptable_accum acc
     WHERE acc.policy_header_id = p_policy_header_id;
    IF cnt > 0
    THEN
      DELETE FROM temp_tmptable_accum acc WHERE acc.policy_header_id = p_policy_header_id;
    END IF;
  
    INSERT INTO temp_tmptable_accum
      SELECT pol.policy_header_id
            ,pol.ins_amount value_amount
            , --"Стандартные накопления"
             pol.pol pol_num
            , --"Полис"
             '-' label
            , --"Метка"
             trunc(pkg_renlife_utils.get_ins_amount_koef(pol.gdv, pol.progr, pol.sex, pol.period), 6) koef
            ,pol.ins_amount *
             trunc(pkg_renlife_utils.get_ins_amount_koef(pol.gdv, pol.progr, pol.sex, pol.period), 6) idx_accumsum --"Накопления при индексации"
        FROM (SELECT ph.policy_header_id
                    ,pp.policy_id
                    ,decode(pp.pol_num, NULL, pp.pol_num, pp.pol_ser || '-' || pp.pol_num) pol
                    ,extract(YEAR FROM pp.start_date) - extract(YEAR FROM dop.start_date) gdv
                    ,CASE
                       WHEN pr.brief IN ('END', 'END_Old', 'END_2') THEN
                        1
                       WHEN pr.brief IN ('CHI'
                                        ,'CHI_Old'
                                        ,'CHI_2'
                                        ,'PEPR'
                                        ,'PEPR_2'
                                        ,'Platinum_LA'
                                        ,'Platinum_LA2'
                                        ,'Baby_LA'
                                        ,'Baby_LA2'
                                        ,'Family La'
                                        ,'Family_La2'
                                        ,'PRIN_DP'
                                        ,'PRIN_DP_NEW') THEN
                        2
                       ELSE
                        0
                     END progr
                    ,dop.ins_amount
                    ,dop.gender sex
                    ,trunc(MONTHS_BETWEEN(trunc(pp.end_date) + 1, trunc(ph.start_date)) / 12, 0) period
              --extract(year from pp.end_date) - extract(year from ph.start_date) + 1 period
                FROM ven_policy_index_item pii
                    ,ven_p_pol_header ph
                    ,t_product pr
                    ,ven_p_policy pp
                    ,(SELECT ph.start_date
                            ,c.gender
                            ,pc.ins_amount
                            ,p.version_num
                            ,ph.policy_header_id
                            ,p.policy_id
                        FROM p_pol_header        ph
                            ,p_policy            p
                            ,as_asset            ast
                            ,as_assured          sa
                            ,cn_person           c
                            ,p_cover             pc
                            ,t_prod_line_option  plo
                            ,t_product_line      pl
                            ,t_product_line_type plt
                            ,ins.document        d
                            ,ins.doc_status_ref  rf
                       WHERE ph.policy_header_id = p.pol_header_id
                         AND ast.p_policy_id = p.policy_id
                         AND ast.as_asset_id = sa.as_assured_id
                         AND sa.assured_contact_id = c.contact_id
                         AND sa.as_assured_id = pc.as_asset_id
                         AND plo.id = pc.t_prod_line_option_id
                         AND plo.product_line_id = pl.id
                         AND pl.product_line_type_id = plt.product_line_type_id
                         AND plt.brief = 'RECOMMENDED'
                         AND p.policy_id = d.document_id
                         AND d.doc_status_ref_id = rf.doc_status_ref_id
                         AND rf.brief != 'CANCEL'
                         AND upper(TRIM(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
                         AND ph.policy_header_id = p_policy_header_id) dop
               WHERE ph.policy_header_id = pii.policy_header_id
                 AND pii.policy_id = pp.policy_id
                 AND ph.product_id = pr.product_id
                 AND (dop.policy_header_id = ph.policy_header_id AND
                     --Чирков /изменил/ 254431: Индексация. Журнал 92
                     --dop.version_num = pp.version_num - 1
                     dop.policy_id = pp.prev_ver_id
                     --
                     )
                 AND doc.get_doc_status_brief(dop.policy_id, to_date('31.12.2999', 'dd.mm.yyyy')) IN
                     ('CURRENT', 'ACTIVE', 'PRINTED', 'CONCLUDED', 'PASSED_TO_AGENT')
                    --and doc.get_doc_status_name(pii.POLICY_INDEX_ITEM_ID) <> 'Согласились на индексацию'
                 AND pii.policy_header_id = p_policy_header_id) pol;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || func_name || SQLERRM);
  END set_tmptable_accum;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.06.2008 17:12:23
  -- Purpose : Т.к. в системе нельзя использовать числа с точность более 6 знаков после запятой делим руками
  FUNCTION val_divide_1000(par_value NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := par_value / 1000;
    RETURN(RESULT);
  END val_divide_1000;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.11.2008 20:51:08
  -- Purpose : Добавляет контакт с указанным типом на полис
  PROCEDURE add_policy_contact
  (
    par_policy_id      NUMBER
   ,par_contact_id     NUMBER
   ,par_pol_role_brief VARCHAR2
  ) IS
    proc_name          VARCHAR2(20) := 'add_policy_contact';
    v_contact_pol_role NUMBER;
    v_p_pol_contact    NUMBER;
  BEGIN
    --Проверяем что указанный тип роли существует
    SELECT t.id INTO v_contact_pol_role FROM t_contact_pol_role t WHERE t.brief = par_pol_role_brief;
  
    --Если на полисе такого контакта с такой ролью нет - заводим
    --если он такой не один удалим лишний
    BEGIN
      SELECT pc.id
        INTO v_p_pol_contact
        FROM p_policy_contact pc
       WHERE pc.policy_id = par_policy_id
         AND pc.contact_id = par_contact_id
         AND pc.contact_policy_role_id = v_contact_pol_role;
    EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO ven_p_policy_contact
          (policy_id, contact_id, contact_policy_role_id)
        VALUES
          (par_policy_id, par_contact_id, v_contact_pol_role);
      WHEN too_many_rows THEN
        DELETE FROM ven_p_policy_contact
         WHERE policy_id = par_policy_id
           AND contact_id = par_contact_id
           AND contact_policy_role_id = v_contact_pol_role
           AND id <> (SELECT MIN(id)
                        FROM ven_p_policy_contact
                       WHERE policy_id = par_policy_id
                         AND contact_id = par_contact_id
                         AND contact_policy_role_id = v_contact_pol_role);
    END;
  
    --Добавим роль на сам контакт
    add_contact_role(par_contact_id, par_pol_role_brief);
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END add_policy_contact;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 14.11.2008 12:33:13
  -- Purpose : Добавляет контакту роль
  PROCEDURE add_contact_role
  (
    par_contact_id         NUMBER
   ,par_contact_role_brief VARCHAR2
  ) IS
    proc_name           VARCHAR2(20) := 'Add_contact_role';
    v_contact_role_type NUMBER;
    v_contact_role_id   NUMBER;
  BEGIN
    --Проверим что указанный тип роли существует
    SELECT tc.id
      INTO v_contact_role_type
      FROM t_contact_role tc
     WHERE tc.description = par_contact_role_brief;
  
    --Если на такого контакта с такой ролью нет - заводим
    --если он такой не один удалим лишний
    BEGIN
      SELECT cr.id
        INTO v_contact_role_id
        FROM cn_contact_role cr
       WHERE cr.contact_id = par_contact_id
         AND cr.role_id = v_contact_role_type;
    EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO ven_cn_contact_role
          (role_id, contact_id)
        VALUES
          (v_contact_role_type, par_contact_id);
      WHEN too_many_rows THEN
        DELETE FROM ven_cn_contact_role
         WHERE contact_id = par_contact_id
           AND role_id = v_contact_role_type
           AND id <> (SELECT MIN(id)
                        FROM cn_contact_role
                       WHERE contact_id = par_contact_id
                         AND role_id = v_contact_role_type);
    END;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END add_contact_role;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 14.11.2008 12:59:23
  -- Purpose : Добавляет связь между контактами
  FUNCTION add_contact_rel
  (
    par_contact_from NUMBER
   ,par_contact_to   NUMBER
   ,par_rel_type_id  NUMBER
  ) RETURN NUMBER IS
    proc_name     VARCHAR2(20) := 'add_contact_rel';
    v_contact_rel NUMBER;
  BEGIN
    SELECT cr.id
      INTO v_contact_rel
      FROM cn_contact_rel cr
     WHERE cr.contact_id_a = par_contact_from
       AND cr.contact_id_b = par_contact_to
       AND cr.relationship_type = par_rel_type_id;
    RETURN(v_contact_rel);
  EXCEPTION
    WHEN no_data_found THEN
      INSERT INTO ven_cn_contact_rel
        (contact_id_a, contact_id_b, relationship_type, is_disabled, remarks)
      VALUES
        (par_contact_from, par_contact_to, par_rel_type_id, 0, 'Заливка!');
    
      SELECT cr.id
        INTO v_contact_rel
        FROM cn_contact_rel cr
       WHERE cr.contact_id_a = par_contact_from
         AND cr.contact_id_b = par_contact_to
         AND cr.relationship_type = par_rel_type_id;
      RETURN(v_contact_rel);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END add_contact_rel;

  PROCEDURE tmp_life_nonlife_agency
  (
    p_date_begin DATE
   ,p_date_end   DATE
  ) IS
    proc_name VARCHAR2(30) := 'tmp_life_nonlife_agency';
    --v_agency varchar2(100);
    --v_pol1 number;
    --v_pol2 number;
    --v_pol3 number;
    --v_date_begin date;
    --v_date_end date;
  BEGIN
    DELETE FROM tmp_life_nonlife_agency;
    COMMIT;
    INSERT INTO tmp_life_nonlife_agency
      (agency, pol1, pol2, pol3, date_begin, date_end)
      (SELECT agency.agency_name
             ,life.pol1
             ,ns.pol2
             ,dor.pol3
             ,p_date_begin
             ,p_date_end
         FROM (SELECT DISTINCT pp.agency_name FROM v_policy_version_journal pp) agency
         LEFT JOIN (SELECT COUNT(pp.policy_header_id) pol1
                         ,pp.agency_name ag1
                     FROM v_policy_version_journal pp
                    INNER JOIN t_product prod
                       ON (prod.product_id = pp.product_id)
                    WHERE prod.description IN ('Гармония жизни'
                                              ,'Будущее'
                                              ,'Семья'
                                              ,'Дети'
                                              ,'Семейный депозит'
                                              ,'Семья (Старая версия)'
                                              ,'Гармония жизни (Старая версия)'
                                              ,'Дети (Старая версия)'
                                              ,'Будущее (Старая версия)')
                      AND pp.policy_id = pp.active_policy_id
                      AND pp.notice_date BETWEEN p_date_begin AND p_date_end
                    GROUP BY pp.agency_name) life
           ON (life.ag1 = agency.agency_name)
         LEFT JOIN (SELECT COUNT(pp.policy_header_id) pol2
                         ,pp.agency_name ag2
                     FROM v_policy_version_journal pp
                    INNER JOIN t_product prod
                       ON (prod.product_id = pp.product_id)
                    WHERE prod.description NOT IN ('Гармония жизни'
                                                  ,'Будущее'
                                                  ,'Семья'
                                                  ,'Дети'
                                                  ,'Семейный депозит'
                                                  ,'Семья (Старая версия)'
                                                  ,'Гармония жизни (Старая версия)'
                                                  ,'Дети (Старая версия)'
                                                  ,'Будущее (Старая версия)')
                      AND pp.policy_id = pp.active_policy_id
                      AND CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date_header)) <= 12
                      AND pp.notice_date BETWEEN p_date_begin AND p_date_end
                    GROUP BY pp.agency_name) ns
           ON (ns.ag2 = agency.agency_name)
         LEFT JOIN (SELECT DISTINCT COUNT(pp.pol_header_id) pol3
                                  ,ot1.name || ' - ' || dep1.name ag3
                     FROM p_policy pp
                    INNER JOIN doc_status st
                       ON (st.document_id = pp.policy_id)
                    INNER JOIN p_pol_header ph
                       ON (ph.policy_header_id = pp.pol_header_id)
                    INNER JOIN t_product prod
                       ON (prod.product_id = ph.product_id)
                     LEFT JOIN department dep1
                       ON ph.agency_id = dep1.department_id
                     LEFT JOIN organisation_tree ot1
                       ON ot1.organisation_tree_id = dep1.org_tree_id
                    WHERE st.doc_status_ref_id IN (17)
                      AND st.user_name NOT IN ('NBOGORODSKAYA', 'SALCHAKO', 'OTITOV')
                      AND st.start_date BETWEEN p_date_begin AND p_date_end
                      AND pp.notice_date BETWEEN p_date_begin AND p_date_end
                    GROUP BY ot1.name || ' - ' || dep1.name) dor
           ON (dor.ag3 = agency.agency_name));
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END;

  FUNCTION run_tmp_trans_table
  (
    p_insurer     VARCHAR2
   ,p_pol_num     VARCHAR2
   ,p_version_num NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    --Result number;
  BEGIN
    pkg_renlife_utils.tmp_trans_table(p_insurer, p_pol_num, p_version_num);
    RETURN 1;
  END run_tmp_trans_table;

  PROCEDURE tmp_trans_table
  (
    p_insurer     VARCHAR2
   ,p_pol_num     VARCHAR2
   ,p_version_num NUMBER
  ) IS
    pol_head   NUMBER;
    pol_policy NUMBER;
  BEGIN
  
    /*num := '011734';
    insurer := 'Хосровян А%';
    doc := 2;*/
  
    SELECT pp.policy_header_id
          ,pp.policy_id
      INTO pol_head
          ,pol_policy
      FROM v_policy_version_journal pp
     WHERE pp.pol_num LIKE p_pol_num
       AND pp.insurer_name LIKE p_insurer
       AND pp.version_num = p_version_num;
  
    DELETE FROM tmp_table_trans;
    COMMIT;
    INSERT INTO tmp_table_trans
      (SELECT pp.pol_ser
             ,pp.pol_num
             ,tmp.name
             ,t.trans_id
             ,t.trans_amount
             ,t.acc_amount
             ,t.trans_date
             ,t.oper_id
         FROM trans       t
             ,p_policy    pp
             ,trans_templ tmp
        WHERE pp.pol_header_id = pol_head
          AND tmp.trans_templ_id = t.trans_templ_id
          AND (pp.policy_id = pol_policy OR pol_policy IS NULL)
          AND ((t.a1_dt_ure_id = 283 AND t.a1_dt_uro_id = pol_policy) OR
              (t.a2_dt_ure_id = 283 AND t.a2_dt_uro_id = pol_policy) OR
              (t.a3_dt_ure_id = 283 AND t.a3_dt_uro_id = pol_policy) OR
              (t.a4_dt_ure_id = 283 AND t.a4_dt_uro_id = pol_policy) OR
              (t.a5_dt_ure_id = 283 AND t.a5_dt_uro_id = pol_policy) OR
              (t.a1_ct_ure_id = 283 AND t.a1_ct_uro_id = pol_policy) OR
              (t.a2_ct_ure_id = 283 AND t.a2_ct_uro_id = pol_policy) OR
              (t.a3_ct_ure_id = 283 AND t.a3_ct_uro_id = pol_policy) OR
              (t.a4_ct_ure_id = 283 AND t.a4_ct_uro_id = pol_policy) OR
              (t.a5_ct_ure_id = 283 AND t.a5_ct_uro_id = pol_policy))
       UNION ALL
       SELECT ''
             ,p_pol_num
             ,tmp.name
             ,t.trans_id
             ,t.trans_amount
             ,t.acc_amount
             ,t.trans_date
             ,t.oper_id
         FROM trans       t
             ,trans_templ tmp
        WHERE ((t.a1_dt_ure_id = 282 AND t.a1_dt_uro_id = pol_head) OR
              (t.a2_dt_ure_id = 282 AND t.a2_dt_uro_id = pol_head) OR
              (t.a3_dt_ure_id = 282 AND t.a3_dt_uro_id = pol_head) OR
              (t.a4_dt_ure_id = 282 AND t.a4_dt_uro_id = pol_head) OR
              (t.a5_dt_ure_id = 282 AND t.a5_dt_uro_id = pol_head) OR
              (t.a1_ct_ure_id = 282 AND t.a1_ct_uro_id = pol_head) OR
              (t.a2_ct_ure_id = 282 AND t.a2_ct_uro_id = pol_head) OR
              (t.a3_ct_ure_id = 282 AND t.a3_ct_uro_id = pol_head) OR
              (t.a4_ct_ure_id = 282 AND t.a4_ct_uro_id = pol_head) OR
              (t.a5_ct_ure_id = 282 AND t.a5_ct_uro_id = pol_head))
          AND tmp.trans_templ_id = t.trans_templ_id);
    COMMIT;
  
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 14.11.2008 10:27:40
  -- Purpose : Добавляет на выгодопиробретателя на застрахованного
  PROCEDURE add_asset_beneficiary
  (
    par_as_asset_id            NUMBER
   ,par_beneficiary_id         NUMBER
   ,par_beneficiary_role_brief VARCHAR2 DEFAULT NULL
   ,par_as_asset_id_role_brief VARCHAR2 DEFAULT NULL
   ,par_currency_id            NUMBER DEFAULT 122
   ,par_value                  NUMBER DEFAULT 100
   ,par_value_type             NUMBER DEFAULT 1
   ,par_comment                VARCHAR2 DEFAULT NULL
  ) IS
    proc_name             VARCHAR2(30) := 'add_asset_beneficiary';
    v_beneficiary_cn_role NUMBER;
    v_policy_id           NUMBER;
    v_contact_rel_type    NUMBER;
    v_asset_contact       NUMBER;
    v_contact_rel         NUMBER;
  BEGIN
    --Добавим запись в policy_contact
    --Нужно для отчетонсти всякой.
    SELECT ass.p_policy_id
          ,ass.contact_id
      INTO v_policy_id
          ,v_asset_contact
      FROM as_asset ass
     WHERE ass.as_asset_id = par_as_asset_id;
  
    add_policy_contact(v_policy_id, par_beneficiary_id, 'Выгодоприобретатель');
  
    SELECT tr.id
      INTO v_beneficiary_cn_role
      FROM t_contact_role tr
     WHERE tr.description = 'Выгодоприобретатель';
  
    --Найдем тип связи для Застрахованный - > Выгодоприобретатель
    SELECT trt.id
      INTO v_contact_rel_type
      FROM t_contact_rel_type trt
     WHERE trt.relationship_dsc = par_as_asset_id_role_brief
       AND trt.target_contact_role_id = v_beneficiary_cn_role;
  
    --Добавляем контакту Застарахованного соответвующую связь.
    v_contact_rel := add_contact_rel(v_asset_contact, par_beneficiary_id, v_contact_rel_type);
    --Это тупая проверка чтобы компильятор не ругался что v_contact_rel не используется
    IF v_contact_rel IS NULL
    THEN
      NULL;
    END IF;
  
    --Найдем тип связи для Выгодоприобретатель - > Застрахованный
    SELECT trt.id
      INTO v_contact_rel_type
      FROM t_contact_rel_type trt
     WHERE trt.relationship_dsc = par_beneficiary_role_brief
       AND trt.source_contact_role_id = v_beneficiary_cn_role;
  
    --Добавляем контакту выгодоприобретателя соответвующую связь
    v_contact_rel := add_contact_rel(par_beneficiary_id, v_asset_contact, v_contact_rel_type);
  
    --Добавляем выгодоприобретателя
    INSERT INTO ven_as_beneficiary
      (as_asset_id, cn_contact_rel_id, comments, contact_id, t_currency_id, VALUE, value_type_id)
    VALUES
      (par_as_asset_id
      ,v_contact_rel
      ,par_comment
      ,par_beneficiary_id
      ,par_currency_id
      ,par_value
      ,par_value_type);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END add_asset_beneficiary;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 14.11.2008 15:13:32
  -- Purpose : Добавляет агента на ДС и определяет программы
  PROCEDURE add_policy_agent
  (
    par_pol_header   NUMBER
   ,par_agent_header NUMBER
   ,par_start_date   DATE
   ,par_percent      NUMBER
  ) IS
    proc_name         VARCHAR2(20) := 'add_policy_agent';
    v_policy_id       NUMBER;
    v_agent_id        NUMBER;
    deff_error        NUMBER;
    v_policy_agent_id NUMBER;
    v_ag_pol_agent    NUMBER;
    v_policy_date_end DATE;
  BEGIN
    --Добавим контакт "Агент" на полис
    SELECT policy_id INTO v_policy_id FROM ven_p_pol_header WHERE policy_header_id = par_pol_header;
  
    SELECT agent_id
      INTO v_agent_id
      FROM ag_contract_header ach
     WHERE ach.ag_contract_header_id = par_agent_header;
  
    add_policy_contact(v_policy_id, v_agent_id, 'Агент');
  
    --Добавляем агнета по полису
    BEGIN
      SELECT pa.p_policy_agent_id
        INTO v_ag_pol_agent
        FROM p_policy_agent pa
       WHERE pa.policy_header_id = par_pol_header
         AND pa.ag_contract_header_id = par_agent_header
         AND pa.status_id = 1;
    
    EXCEPTION
      WHEN no_data_found THEN
        SELECT pp.end_date
          INTO v_policy_date_end
          FROM p_policy pp
         WHERE pp.pol_header_id = par_pol_header
           AND pp.version_num = (SELECT MAX(version_num)
                                   FROM p_policy           p1
                                       ,ins.document       d
                                       ,ins.doc_status_ref rf
                                  WHERE p1.pol_header_id = par_pol_header
                                    AND p1.start_date <= par_start_date
                                    AND p1.policy_id = d.document_id
                                    AND d.doc_status_ref_id = rf.doc_status_ref_id
                                    AND rf.brief != 'CANCEL');
      
        SELECT sq_p_policy_agent.nextval INTO v_policy_agent_id FROM dual;
      
        INSERT INTO ven_p_policy_agent
          (p_policy_agent_id
          ,ag_contract_header_id
          ,date_start
          ,date_end
          ,policy_header_id
          ,part_agent
          ,ag_type_rate_value_id
          ,status_date
          ,status_id)
        VALUES
          (v_policy_agent_id
          ,par_agent_header
          ,par_start_date
          ,v_policy_date_end
          ,par_pol_header
          ,par_percent
          ,3
          ,SYSDATE
          ,1);
        --Определим программы по агенту
        deff_error := pkg_agent.define_agent_prod_line(v_policy_agent_id, par_agent_header);
        IF deff_error <> 0
        THEN
          raise_application_error(-20001
                                 ,'Не удается определить программы ' || SQLERRM);
        END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END add_policy_agent;

  -- ishch (
  -- Процедура привязки агентского договора к договору страхования через
  -- ven_p_policy_agent_doc
  -- Параметры: id ДС и АД
  PROCEDURE add_policy_agent_doc
  (
    par_policy_header_id      NUMBER
   ,par_ag_contract_header_id NUMBER
  ) IS
    v_proc_name             VARCHAR2(30) := 'Add_Policy_Agent_Doc';
    v_msg                   VARCHAR2(2000);
    v_state                 VARCHAR2(35);
    v_doc_tmp               NUMBER;
    v_doc_cnt               NUMBER;
    v_date_begin            DATE;
    v_date_end              DATE;
    v_ag_cnt                NUMBER;
    v_mdt                   DATE;
    v_p_policy_agent_doc_id NUMBER;
  BEGIN
    SELECT sq_p_policy_agent_doc.nextval INTO v_p_policy_agent_doc_id FROM dual;
    BEGIN
      SELECT t.doc_templ_id INTO v_doc_tmp FROM doc_templ t WHERE t.brief = 'P_POLICY_AGENT_DOC';
    EXCEPTION
      WHEN no_data_found THEN
        v_doc_tmp := 1;
    END;
    BEGIN
      SELECT COUNT(*)
        INTO v_doc_cnt
        FROM ven_p_policy_agent_doc
       WHERE policy_header_id = par_policy_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_doc_cnt := 0;
    END;
    BEGIN
      SELECT pp.notice_date
            ,trunc(pp.end_date) end_date
        INTO v_date_begin
            ,v_date_end
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE ph.policy_id = pp.policy_id
         AND ph.policy_header_id = par_policy_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_date_begin := SYSDATE;
        v_date_end   := SYSDATE;
    END;
    IF nvl(v_doc_cnt, 0) <= 0
    THEN
      INSERT INTO ven_p_policy_agent_doc
        (p_policy_agent_doc_id
        ,date_end
        ,date_begin
        ,policy_header_id
        ,doc_templ_id
        ,ag_contract_header_id)
      VALUES
        (v_p_policy_agent_doc_id
        ,v_date_end
        ,v_date_begin
        ,par_policy_header_id
        ,v_doc_tmp
        ,par_ag_contract_header_id);
      doc.set_doc_status(v_p_policy_agent_doc_id, 'NEW', SYSDATE);
      doc.set_doc_status(v_p_policy_agent_doc_id, 'CURRENT', SYSDATE + 1 / (24 * 60 * 60));
    ELSE
      BEGIN
        SELECT COUNT(*)
          INTO v_ag_cnt
          FROM ven_p_policy_agent_doc dc
              ,document               d
              ,doc_status             ds
              ,doc_status_ref         rf
         WHERE dc.policy_header_id = par_policy_header_id
           AND d.document_id = dc.p_policy_agent_doc_id
           AND ds.document_id = d.document_id
           AND ds.start_date =
               (SELECT MAX(dss.start_date) FROM doc_status dss WHERE dss.document_id = d.document_id)
           AND rf.doc_status_ref_id = ds.doc_status_ref_id
           AND nvl(rf.brief, 'NEW') IN ('NEW', 'CURRENT');
      EXCEPTION
        WHEN no_data_found THEN
          v_ag_cnt := 1;
      END;
      BEGIN
        SELECT MAX(dc.date_begin)
          INTO v_mdt
          FROM ven_p_policy_agent_doc dc
         WHERE dc.policy_header_id = par_policy_header_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_mdt := v_date_begin;
      END;
      IF nvl(v_ag_cnt, 0) = 0
      THEN
        INSERT INTO ven_p_policy_agent_doc
          (p_policy_agent_doc_id
          ,date_end
          ,date_begin
          ,policy_header_id
          ,doc_templ_id
          ,ag_contract_header_id)
        VALUES
          (v_p_policy_agent_doc_id
          ,v_date_end
          ,v_mdt
          ,par_policy_header_id
          ,v_doc_tmp
          ,par_ag_contract_header_id);
        doc.set_doc_status(v_p_policy_agent_doc_id, 'NEW', SYSDATE);
        doc.set_doc_status(v_p_policy_agent_doc_id, 'CURRENT', SYSDATE + 1 / (24 * 60 * 60));
      ELSE
        raise_application_error(-20001
                               ,' Ошибка добавления агента: ' ||
                                'Есть статус агента по ДС Действующий или Новый');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END add_policy_agent_doc;
  -- ishch )

  -- Author  : ALEXEY.KATKEVICH
  --Функция выдрана из pkg_policy и немного доработана под нужды RenLife
  FUNCTION policy_insert
  (
    p_product_id           IN NUMBER
   ,p_sales_channel_id     IN NUMBER
   ,p_agency_id            IN NUMBER
   ,p_fund_id              IN NUMBER
   ,p_fund_pay_id          IN NUMBER
   ,p_confirm_condition_id IN NUMBER
   ,p_pol_ser              IN VARCHAR2
   ,p_pol_num              IN VARCHAR2
   ,p_notice_date          IN DATE
   ,p_sign_date            IN DATE
   ,p_confirm_date         IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_first_pay_date       IN DATE
   ,p_payment_term_id      IN NUMBER
   ,p_period_id            IN NUMBER
   ,p_issuer_id            IN NUMBER
   ,p_fee_payment_term     IN NUMBER
   ,p_fact_j               IN NUMBER DEFAULT NULL
   ,p_admin_cost           IN NUMBER DEFAULT 0
   ,p_is_group_flag        IN NUMBER DEFAULT 0
   , -- Байтин А. Заменил null на 0
    p_notice_num           IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id    IN NUMBER DEFAULT NULL
   ,p_region_id            IN NUMBER DEFAULT NULL
   ,p_discount_f_id        IN NUMBER DEFAULT NULL
   ,p_description          IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id   IN NUMBER DEFAULT NULL
   ,p_ph_description       IN VARCHAR2 DEFAULT NULL
   ,p_privilege_period     IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_pol_head_id NUMBER;
    v_policy_id   NUMBER;
  BEGIN
  
    v_pol_head_id := pkg_policy.create_policy_base(p_product_id           => p_product_id
                                                  ,p_sales_channel_id     => p_sales_channel_id
                                                  ,p_agency_id            => p_agency_id
                                                  ,p_fund_id              => p_fund_id
                                                  ,p_fund_pay_id          => p_fund_pay_id
                                                  ,p_confirm_condition_id => p_confirm_condition_id
                                                  ,p_pol_ser              => p_pol_ser
                                                  ,p_pol_num              => p_pol_num
                                                  ,p_notice_date          => p_notice_date
                                                  ,p_sign_date            => p_sign_date
                                                  ,p_confirm_date         => p_confirm_date
                                                  ,p_start_date           => p_start_date
                                                  ,p_end_date             => p_end_date
                                                  ,p_first_pay_date       => p_first_pay_date
                                                  ,p_payment_term_id      => p_payment_term_id
                                                  ,p_period_id            => p_period_id
                                                  ,p_issuer_id            => p_issuer_id
                                                  ,p_fee_payment_term     => p_fee_payment_term
                                                  ,p_fact_j               => p_fact_j
                                                  ,p_admin_cost           => p_admin_cost
                                                  ,p_is_group_flag        => p_is_group_flag
                                                  ,p_notice_num           => p_notice_num
                                                  ,p_waiting_period_id    => p_waiting_period_id
                                                  ,p_region_id            => p_region_id
                                                  ,p_discount_f_id        => p_discount_f_id
                                                  ,p_description          => p_description
                                                  ,p_paymentoff_term_id   => p_paymentoff_term_id
                                                  ,p_ph_description       => p_ph_description
                                                  ,p_privilege_period     => p_privilege_period);
  
    RETURN v_pol_head_id;
  END;

  -- ishch (
  -- Процедура создания строки во временной таблице для последующей загрузки в нее
  -- файла данных
  -- Параметр: идентификатор сессии загрузки (из sq_bordero_session_id)
  PROCEDURE load_bordero_create_temp_rec(par_session_id NUMBER) IS
  BEGIN
    DELETE FROM temp_load_blob WHERE session_id = par_session_id;
    INSERT INTO temp_load_blob (session_id) VALUES (par_session_id);
    DELETE FROM as_bordero_load WHERE session_id = par_session_id;
    COMMIT;
  END load_bordero_create_temp_rec;

  -- Процедура загрузки файла из BLOB-а в таблицу строк бордеро (as_bordero_load)
  -- Параметр: идентификатор сессии загрузки (из sq_bordero_session_id)
  PROCEDURE load_bordero_blob_to_table(par_session_id NUMBER) IS
    TYPE t_varay IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
    va_values         t_varay;
    v_blob_data       BLOB;
    v_blob_len        NUMBER;
    v_position        NUMBER;
    v_countrow        NUMBER := 2;
    c_chunk_len       NUMBER := 1;
    v_line            VARCHAR2(32767) := NULL;
    v_line_num        NUMBER := 0;
    v_char            CHAR(1);
    v_raw_chunk       RAW(10000);
    v_check_field     NUMBER;
    v_as_bordero_load as_bordero_load%ROWTYPE;
    ------------------------------------------------------------------------------
    -- Функция разбра строки данных
    FUNCTION str2array(p_str VARCHAR2) RETURN t_varay IS
      v_offset NUMBER := 1;
      v_length NUMBER := 0;
      va_res   t_varay;
    BEGIN
      FOR i IN 1 .. 100
      LOOP
        v_length := instr(p_str, ';', v_offset);
        IF v_length = 0
        THEN
          va_res(i) := TRIM(substr(p_str, v_offset));
          EXIT;
        ELSE
          va_res(i) := TRIM(substr(p_str, v_offset, v_length - v_offset));
        END IF;
        v_offset := v_length + 1;
      END LOOP;
      RETURN va_res;
    END str2array;
    ------------------------------------------------------------------------------
    FUNCTION hex2dec(par_hexval IN CHAR) RETURN NUMBER IS
      v_i                 NUMBER;
      v_digits            NUMBER;
      v_result            NUMBER := 0;
      v_current_digit     CHAR(1);
      v_current_digit_dec NUMBER;
    BEGIN
      v_digits := length(par_hexval);
      FOR i IN 1 .. v_digits
      LOOP
        v_current_digit := substr(par_hexval, i, 1);
        IF v_current_digit IN ('A', 'B', 'C', 'D', 'E', 'F')
        THEN
          v_current_digit_dec := ascii(v_current_digit) - ascii('A') + 10;
        ELSE
          v_current_digit_dec := to_number(v_current_digit);
        END IF;
        v_result := (v_result * 16) + v_current_digit_dec;
      END LOOP;
      RETURN(v_result);
    END hex2dec;
    ------------------------------------------------------------------------------
  BEGIN
    SAVEPOINT before_load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_session_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := str2array(v_line); -- разбиение строки на поля
          IF v_line IS NOT NULL
          THEN
            v_as_bordero_load := NULL;
            SELECT sq_bordero_load_id.nextval INTO v_as_bordero_load.row_id FROM dual;
            v_as_bordero_load.session_id := par_session_id;
            v_as_bordero_load.is_loaded  := 0;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  --Фамилия
                  BEGIN
                    v_as_bordero_load.surname := va_values(i);
                    v_as_bordero_load.surname := to_char(v_as_bordero_load.surname);
                    SELECT length(v_as_bordero_load.surname) INTO v_check_field FROM dual;
                    IF v_check_field > 100
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 100 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Фамилия" ' || chr(10) || SQLERRM);
                  END;
                
                WHEN i = 2 THEN
                  --Имя
                  BEGIN
                    v_as_bordero_load.first_name := va_values(i);
                    v_as_bordero_load.first_name := to_char(v_as_bordero_load.first_name);
                    SELECT length(v_as_bordero_load.first_name) INTO v_check_field FROM dual;
                    IF v_check_field > 30
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 30 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Имя" ' || chr(10) || SQLERRM);
                  END;
                
                WHEN i = 3 THEN
                  --Отчество
                  BEGIN
                    v_as_bordero_load.middle_name := va_values(i);
                    v_as_bordero_load.middle_name := to_char(v_as_bordero_load.middle_name);
                    SELECT length(v_as_bordero_load.middle_name) INTO v_check_field FROM dual;
                    IF v_check_field > 30
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 30 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Отчество" ' || chr(10) || SQLERRM);
                  END;
                
                WHEN i = 4 THEN
                  --Дата рождения
                  BEGIN
                    --При заливке бордеро страхователь только физ. лицо. Значит Дата рождения обязательна
                    IF va_values(i) IS NULL
                    THEN
                      raise_application_error(-20002
                                             ,'Поле не может быть пустым');
                    END IF;
                    v_as_bordero_load.birth_date := to_date(regexp_substr(va_values(i)
                                                                         ,'\d{2}\.\d{2}\.\d{4}')
                                                           ,'DD.MM.YYYY');
                    IF v_as_bordero_load.birth_date IS NULL
                    THEN
                      raise_application_error(-20002
                                             ,'Дата рождения должна быть в формате ДД.ММ.ГГГГ');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Дата рождения" ' || chr(10) || SQLERRM);
                  END;
                WHEN i = 5 THEN
                  --Пол
                  BEGIN
                    -- v_as_bordero_load.gender := va_values(i);
                    --REGEXP_LIKE(UPPER(v_as_bordero_load.gender),'^(М|Ж|M|F)$');
                    v_as_bordero_load.gender := regexp_substr(upper(va_values(i)), '^(М|Ж|M|F)$');
                    IF v_as_bordero_load.gender IS NULL
                    THEN
                      raise_application_error(-20002
                                             ,'Допустимые значения m/f, м/ж');
                    END IF;
                    SELECT length(v_as_bordero_load.gender) INTO v_check_field FROM dual;
                    IF v_check_field > 5
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 5 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- IF v_check_field THEN
                      -- RAISE_APPLICATION_ERROR(-20002,'Ошибка в поле Пол. Допустимые значения m/f, м/ж');
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Пол" ' || chr(10) || SQLERRM);
                  END;
                WHEN i = 6 THEN
                  --серия паспорта
                  BEGIN
                    /* IF length(regexp_replace(TRIM(va_values(i)),'[^0-9]+',''))-length(TRIM(va_values(i))) != 0
                      THEN
                        RAISE_APPLICATION_ERROR(-20002,'Неверное число');
                    END IF;*/
                    v_as_bordero_load.doc_ser := va_values(i);
                    SELECT length(v_as_bordero_load.doc_ser) INTO v_check_field FROM dual;
                    IF v_check_field > 5
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 5 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Серия Паспорта" ' || chr(10) || SQLERRM);
                  END;
                WHEN i = 7 THEN
                  --Номер паспорта
                  BEGIN
                    IF length(regexp_replace(TRIM(va_values(i)), '[^0-9]+', '')) -
                       length(TRIM(va_values(i))) != 0
                    THEN
                      raise_application_error(-20002, 'Неверное число');
                    END IF;
                    v_as_bordero_load.doc_num := va_values(i);
                    SELECT length(v_as_bordero_load.doc_num) INTO v_check_field FROM dual;
                    IF v_check_field > 10
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 10 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Номер Паспорта" ' || chr(10) || SQLERRM);
                  END;
                WHEN i = 8 THEN
                  --Документ выдан
                  BEGIN
                    v_as_bordero_load.doc_issued_by := va_values(i);
                    SELECT length(v_as_bordero_load.doc_issued_by) INTO v_check_field FROM dual;
                    IF v_check_field > 255
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 255 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Кем выдан"' || chr(10) || SQLERRM);
                  END;
                WHEN i = 9 THEN
                  --Дата выдачи
                  BEGIN
                    v_as_bordero_load.doc_issued_date := to_date(regexp_substr(va_values(i)
                                                                              ,'\d{2}\.\d{2}\.\d{4}')
                                                                ,'DD.MM.YYYY');
                    IF v_as_bordero_load.doc_issued_date IS NULL
                       AND va_values(i) IS NOT NULL
                    THEN
                      raise_application_error(-20002
                                             ,'"Дата выдачи документа" должна быть в формате ДД.ММ.ГГГГ');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Дата выдачи документа"' || chr(10) ||
                                              SQLERRM);
                  END;
                WHEN i = 10 THEN
                  --Адрес застрахованного
                  BEGIN
                    v_as_bordero_load.person_addres := va_values(i); --Поскряков заявка 156973
                    SELECT length(v_as_bordero_load.person_addres) INTO v_check_field FROM dual;
                    IF v_check_field > 2000
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 2000 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Адрес застрахованного" ' || chr(10) ||
                                              SQLERRM);
                  END;
                  --NULL; -- person_addres - не загружается
                WHEN i = 11 THEN
                  --Телефон застрахованного
                  BEGIN
                    v_as_bordero_load.person_telephone := va_values(i); --Поскряков заявка 156973
                    SELECT length(v_as_bordero_load.person_telephone) INTO v_check_field FROM dual;
                    IF v_check_field > 30
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 30 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Телефон застрахованного" ' || chr(10) ||
                                              SQLERRM);
                  END;
                  --NULL; -- person_telephone - не загружается
                WHEN i = 12 THEN
                  --Номер заявления
                  BEGIN
                    v_as_bordero_load.notice_num := va_values(i);
                    SELECT length(v_as_bordero_load.notice_num) INTO v_check_field FROM dual;
                    IF v_check_field > 30
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 30 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Телефон застрахованного" ' || chr(10) ||
                                              SQLERRM);
                  END;
                WHEN i = 13 THEN
                  --Дата заявления
                  BEGIN
                    IF va_values(i) IS NULL --Дата заявления обязательна
                    THEN
                      raise_application_error(-20002
                                             ,'Поле не может быть пустым');
                    END IF;
                    v_as_bordero_load.notice_date := to_date(regexp_substr(va_values(i)
                                                                          ,'\d{2}\.\d{2}\.\d{4}')
                                                            ,'DD.MM.YYYY');
                    IF v_as_bordero_load.notice_date IS NULL
                    THEN
                      raise_application_error(-20002
                                             ,'Дата заявления должна быть в формате ДД.ММ.ГГГГ');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Дата Заявления"' || chr(10) || SQLERRM);
                  END;
                WHEN i = 14 THEN
                  --Дата начала
                  BEGIN
                    IF va_values(i) IS NULL --Дата начала ДС обязательна
                    THEN
                      raise_application_error(-20002
                                             ,'Поле не может быть пустым');
                    END IF;
                    v_as_bordero_load.start_date := to_date(regexp_substr(va_values(i)
                                                                         ,'\d{2}\.\d{2}\.\d{4}')
                                                           ,'DD.MM.YYYY');
                    IF v_as_bordero_load.start_date IS NULL
                    THEN
                      raise_application_error(-20002
                                             ,'Дата начала ДС должна быть в формате ДД.ММ.ГГГГ');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Дата начала ДС"' || chr(10) || SQLERRM);
                  END;
                WHEN i = 15 THEN
                  --Дата окончания
                  BEGIN
                    IF va_values(i) IS NULL --Дата окончания обязательна!
                    THEN
                      raise_application_error(-20002
                                             ,'Поле не может быть пустым');
                    END IF;
                    v_as_bordero_load.end_date := to_date(regexp_substr(va_values(i)
                                                                       ,'\d{2}\.\d{2}\.\d{4}')
                                                         ,'DD.MM.YYYY');
                    IF v_as_bordero_load.end_date IS NULL
                    THEN
                      raise_application_error(-20002
                                             ,'Дата окончания ДС должна быть в формате ДД.ММ.ГГГГ');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Дата окончания ДС"' || chr(10) ||
                                              SQLERRM);
                  END;
                WHEN i = 16 THEN
                  --Страховая сумма
                  BEGIN
                    v_as_bordero_load.ins_sum := ROUND(to_number(translate(va_values(i), ',.', '..')
                                                                ,'9999999999D9999999999'
                                                                ,'NLS_NUMERIC_CHARACTERS=''. ''')
                                                      ,2);
                    IF v_as_bordero_load.ins_sum IS NULL --AND va_values(i) is not null
                    THEN
                      raise_application_error(-20002, 'Неверное число');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Страховая сумма ДС"' || chr(10) ||
                                              SQLERRM);
                  END;
                WHEN i = 17 THEN
                  --Премия
                  BEGIN
                    v_as_bordero_load.ins_prem := ROUND(to_number(translate(va_values(i), ',.', '..')
                                                                 ,'9999999999D9999999999'
                                                                 ,'NLS_NUMERIC_CHARACTERS=''. ''')
                                                       ,2);
                    IF v_as_bordero_load.ins_prem IS NULL --AND va_values(i) is not null
                    THEN
                      raise_application_error(-20002, 'Неверное число');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Страховая премия ДС"' || chr(10) ||
                                              SQLERRM);
                  END;
                WHEN i = 18 THEN
                  --Валюта
                  BEGIN
                    v_as_bordero_load.fund := va_values(i);
                    v_as_bordero_load.fund := to_char(v_as_bordero_load.fund);
                    SELECT length(v_as_bordero_load.fund) INTO v_check_field FROM dual;
                    IF v_check_field > 5
                    THEN
                      raise_application_error(-20002
                                             ,'Должно быть менее 5 символов');
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      raise_application_error(-20002
                                             ,'Ошибка в поле "Валюта"' || chr(10) || SQLERRM);
                  END;
              END CASE;
            END LOOP;
            v_countrow := v_countrow + 1;
            INSERT INTO as_bordero_load
              (session_id
              ,row_id
              ,surname
              ,first_name
              ,middle_name
              ,birth_date
              ,doc_ser
              ,doc_num
              ,doc_issued_by
              ,doc_issued_date
              ,person_addres
              ,person_telephone
              ,notice_num
              ,notice_date
              ,start_date
              ,end_date
              ,ins_sum
              ,ins_prem
              ,gender
              ,fund
              ,is_loaded)
            VALUES
              (v_as_bordero_load.session_id
              ,v_as_bordero_load.row_id
              ,v_as_bordero_load.surname
              ,v_as_bordero_load.first_name
              ,v_as_bordero_load.middle_name
              ,v_as_bordero_load.birth_date
              ,v_as_bordero_load.doc_ser
              ,v_as_bordero_load.doc_num
              ,v_as_bordero_load.doc_issued_by
              ,v_as_bordero_load.doc_issued_date
              ,v_as_bordero_load.person_addres
              ,v_as_bordero_load.person_telephone
              ,v_as_bordero_load.notice_num
              ,v_as_bordero_load.notice_date
              ,v_as_bordero_load.start_date
              ,v_as_bordero_load.end_date
              ,v_as_bordero_load.ins_sum
              ,v_as_bordero_load.ins_prem
              ,v_as_bordero_load.gender
              ,v_as_bordero_load.fund
              ,v_as_bordero_load.is_loaded);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,' Ошибка в строке: ' || v_countrow || chr(10) || 'Страхователь: ' ||
                              v_as_bordero_load.surname || ' ' || v_as_bordero_load.first_name || ' ' ||
                              v_as_bordero_load.middle_name || chr(10) || 'Дата рождения: ' ||
                              to_char(v_as_bordero_load.birth_date, 'dd.mm.yyyy') || chr(10) ||
                              SQLERRM);
  END load_bordero_blob_to_table;
  -- ishch )

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.11.2008 16:03:07
  -- Purpose : Закачка бордеро ДС в систему
  PROCEDURE load_bordero(vedom_id NUMBER) IS
    proc_name           VARCHAR2(20) := 'Load_bordero';
    v_bordero_vedom     as_bordero_vedom%ROWTYPE;
    v_policy_header     NUMBER;
    v_policy_start_date DATE;
    error_count         NUMBER;
    v_error_text        VARCHAR2(4000);
  BEGIN
  
    SELECT * INTO v_bordero_vedom FROM as_bordero_vedom WHERE doc_id = vedom_id;
  
    SELECT brief INTO g_bordero.pol_ser FROM t_product WHERE product_id = v_bordero_vedom.product_id;
  
    BEGIN
      SELECT 1
        INTO g_bordero.flag_zabota
        FROM t_product
       WHERE product_id = v_bordero_vedom.product_id
         AND brief IN ('ZabotaPost' /*,'CR92_2'*/);
    EXCEPTION
      WHEN no_data_found THEN
        g_bordero.flag_zabota := 0;
    END;
  
    BEGIN
      SELECT CASE
               WHEN brief LIKE 'CR102%' THEN
                1
               WHEN brief IN ('CR50_5', 'CR50_6') THEN
                2
               WHEN brief IN ('CR106', 'CR50_7', 'CR50_8', 'CR50_9') THEN
                3
               ELSE
                0
             END
        INTO g_bordero.special_program_flag
        FROM t_product
       WHERE product_id = v_bordero_vedom.product_id;
      --              and brief LIKE 'CR102%';
    EXCEPTION
      WHEN no_data_found THEN
        g_bordero.special_program_flag := 0;
    END;
  
    SELECT ach.t_sales_channel_id
          ,ach.agency_id
      INTO g_bordero.sales_channel_id
          ,g_bordero.agency_id
      FROM ag_contract_header ach
     WHERE ach.ag_contract_header_id = v_bordero_vedom.main_ag_contract_id;
  
    -- Байтин А.
    -- Заявка 173710
    -- Теперь это не нужно
    /*     SELECT MAX(CASE WHEN upper(tpl.DESCRIPTION) LIKE '%СМЕРТ%' THEN tpl.ID ELSE 0 END),
                MAX(CASE WHEN upper(tpl.DESCRIPTION) LIKE '%ИНВАЛИДНО%' THEN tpl.ID ELSE 0 END),
                MAX(CASE WHEN tpl.DESCRIPTION LIKE 'Дожитие % до потери %' THEN tpl.ID ELSE 0 END)
           INTO g_bordero.death_prod_line_id,
                g_bordero.disability_prod_line_id,
                g_bordero.job_loss_prod_line_id
           FROM T_product tp,
                t_product_version tv,
                t_product_ver_lob tpv,
                t_product_line tpl
          WHERE tp.product_id = v_bordero_vedom.product_id
            AND tp.product_id = tv.product_id
            AND tpv.product_version_id = tv.t_product_version_id
            AND tpl.product_ver_lob_id = tpv.t_product_ver_lob_id
    --Эти 2 риска были добавлены ради двух ДС, а тут их надо исключить:
            and ((tpl.description not in ('Инвалидность в результате НС','Смерть в результате НС')
                  and tp.description = 'КС CR49 Малый и ср. бизнес'
                  )
                 or tp.description <> 'КС CR49 Малый и ср. бизнес'
                );*/
  
    g_bordero.prod_line_id_1 := v_bordero_vedom.prod_line_id_1;
    g_bordero.percent_1      := v_bordero_vedom.percent_1;
    g_bordero.prod_line_id_2 := v_bordero_vedom.prod_line_id_2;
    g_bordero.percent_2      := v_bordero_vedom.percent_2;
    g_bordero.prod_line_id_3 := v_bordero_vedom.prod_line_id_3;
    g_bordero.percent_3      := v_bordero_vedom.percent_3;
    g_bordero.prod_line_id_4 := v_bordero_vedom.prod_line_id_4;
    g_bordero.percent_4      := v_bordero_vedom.percent_4;
    g_bordero.prod_line_id_5 := v_bordero_vedom.prod_line_id_5;
    g_bordero.percent_5      := v_bordero_vedom.percent_5;
    g_bordero.prod_line_id_6 := v_bordero_vedom.prod_line_id_6;
    g_bordero.percent_6      := v_bordero_vedom.percent_6;
  
    g_bordero.produc_id          := v_bordero_vedom.product_id;
    g_bordero.payment_term_id    := v_bordero_vedom.payment_term_id;
    g_bordero.header_description := v_bordero_vedom.description;
    g_bordero.discount_period    := v_bordero_vedom.grace_period_id;
    g_bordero.waiting_periood_id := v_bordero_vedom.waiting_period_id;
    g_bordero.description        := v_bordero_vedom.description;
    g_bordero.death_coef         := v_bordero_vedom.death_part / 100;
    g_bordero.disability_coef    := v_bordero_vedom.disability_part / 100;
  
    --TODO: Получение этих данных из типа закачки
    g_bordero.pay_fund_id          := 122; --Валюта ответственонсти "Рубли"
    g_bordero.confirm_condition_id := 2; --Условие вступлния в силу "С момента поступления платежа"
    g_bordero.period_id            := 9; --Срок страхования "Другой"
    g_bordero.fee_payment_term     := 1; --"Срок уплаты взносов" количество взносов в год
    g_bordero.fact_j               := NULL; --Норма доходности
    g_bordero.admin_cost           := NULL; --Административные издержки
    g_bordero.is_group             := NULL; --Групповое страхование
    g_bordero.region_id            := 88; --47; --Регион "Московский"
    g_bordero.f_discount_id        := 2; --Скидка "Нет"
    g_bordero.payment_off_id       := 163; --Рассрочка выплат "Единовременная"
  
    --Данные по выгодоприобретателю
    SELECT tp.t_path_type_id
      INTO g_bordero.benificiary_part_id
      FROM t_path_type tp
     WHERE tp.description = 'Процент';
    g_bordero.benificiary_part_value := 100;
    g_bordero.asset_role             := 'Клиент';
    g_bordero.benificiary_role       := 'Банк';
    g_bordero.benificiary_id         := v_bordero_vedom.beneficiary_id;
  
    FOR v_tmp IN (SELECT *
                    FROM as_bordero_load
                   WHERE session_id = v_bordero_vedom.session_id
                     AND is_loaded = 0)
    LOOP
      BEGIN
        SAVEPOINT before_load;
      
        v_policy_header := load_policy_from_bordero(v_tmp.row_id);
      
        -- ishch (
      
        --Добавляем на полис агентов
      
        /*SELECT ph.start_date
         INTO v_policy_start_date
         FROM p_pol_header ph
        WHERE ph.policy_header_id = v_policy_header; */
      
        BEGIN
          IF v_bordero_vedom.main_ag_contract_id IS NOT NULL
          THEN
            add_policy_agent_doc(v_policy_header, v_bordero_vedom.main_ag_contract_id);
            /*add_policy_agent(v_policy_header ,
            v_bordero_vedom.main_ag_contract_id ,
            v_policy_start_date,
            100); */
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        BEGIN
          IF v_bordero_vedom.ag2_contract_id IS NOT NULL
          THEN
            add_policy_agent_doc(v_policy_header, v_bordero_vedom.ag2_contract_id);
            /*add_policy_agent(v_policy_header ,
            v_bordero_vedom.ag2_contract_id ,
            v_policy_start_date,
            100); */
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        IF v_bordero_vedom.ag3_contract_id IS NOT NULL
        THEN
          add_policy_agent_doc(v_policy_header, v_bordero_vedom.ag3_contract_id);
          /*add_policy_agent(v_policy_header ,
          v_bordero_vedom.ag3_contract_id ,
          v_policy_start_date,
          100); */
        END IF;
      
        BEGIN
          IF v_bordero_vedom.ag4_contract_id IS NOT NULL
          THEN
            add_policy_agent_doc(v_policy_header, v_bordero_vedom.ag4_contract_id);
            /*add_policy_agent(v_policy_header ,
            v_bordero_vedom.ag4_contract_id ,
            v_policy_start_date,
            100); */
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        -- ishch )
      
        UPDATE as_bordero_load abl SET abl.is_loaded = 1 WHERE abl.row_id = v_tmp.row_id;
        COMMIT;
      
      EXCEPTION
        WHEN OTHERS THEN
          -- Байтин А.
          -- исправлено, чтобы ошибка писАлась в загружаемую строчку
          -- все равно error_count не увеличивался из-за того, что не был инициализирован :)
          /*
                error_count:= error_count + 1;
                IF error_count> 10 THEN
                  ROLLBACK TO Before_load;
                  RAISE_APPLICATION_ERROR(-20001, 'При закачке бордеро произошло более 10 ошибок');
                END IF;
          */
          v_error_text := SQLERRM;
          ROLLBACK TO before_load;
          UPDATE as_bordero_load bl SET bl.error_text = v_error_text WHERE bl.row_id = v_tmp.row_id;
          COMMIT;
      END;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END load_bordero;

  --Каткевич А.Г
  --08.2008
  --Создает полис из строки в бордеро.
  --Возвращает policy_header_id
  FUNCTION load_policy_from_bordero(par_row_id NUMBER) RETURN NUMBER IS
    v_bordero               as_bordero_load%ROWTYPE;
    v_contact_id            NUMBER;
    v_pol_header_id         NUMBER;
    v_policy_id             NUMBER;
    v_bso_series_id         bso_series.bso_series_id%TYPE;
    v_bso_id                bso.bso_id%TYPE;
    v_work_group_id         NUMBER;
    v_assured_id            NUMBER;
    v_cover_id              NUMBER;
    v_asset_prem            NUMBER;
    v_fund_id               NUMBER;
    p_is_handchange_amount  NUMBER := 1;
    p_is_handchange_premium NUMBER := 1;
    p_is_handchange_fee     NUMBER := 1;
    p_is_handchange_tariff  NUMBER := 1;
    v_fee                   NUMBER;
    special_limit_age EXCEPTION;
    v_bso_series_num bso_series.series_num%TYPE;
  
    CURSOR cur_prod(cur_assured_id IN NUMBER) IS
      SELECT pl.id
            ,CASE
               WHEN lead(pl.id) over(ORDER BY pl.id) IS NULL THEN
                1
               ELSE
                0
             END AS is_last
            ,CASE pl.id
               WHEN g_bordero.prod_line_id_1 THEN
                nvl(g_bordero.percent_1, 0) / 100
               WHEN g_bordero.prod_line_id_2 THEN
                nvl(g_bordero.percent_2, 0) / 100
               WHEN g_bordero.prod_line_id_3 THEN
                nvl(g_bordero.percent_3, 0) / 100
               WHEN g_bordero.prod_line_id_4 THEN
                nvl(g_bordero.percent_4, 0) / 100
               WHEN g_bordero.prod_line_id_5 THEN
                nvl(g_bordero.percent_5, 0) / 100
               WHEN g_bordero.prod_line_id_6 THEN
                nvl(g_bordero.percent_6, 0) / 100
               ELSE
                0
             END AS percent
            ,pl.ins_amount_round_rules_id
            ,pl.fee_round_rules_id
        FROM t_product           pr
            ,t_product_version   pv
            ,t_product_ver_lob   pvl
            ,t_product_line      pl
            ,t_product_line_type plt
       WHERE pr.product_id = (SELECT ph.product_id
                                FROM as_asset     a
                                    ,p_policy     p
                                    ,p_pol_header ph
                               WHERE a.as_asset_id = cur_assured_id
                                 AND a.p_policy_id = p.policy_id
                                 AND p.pol_header_id = ph.policy_header_id)
         AND pv.product_id = pr.product_id
         AND pvl.product_version_id = pv.t_product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND pl.skip_on_policy_creation = 0
         AND ((pl.description NOT IN ('Инвалидность в результате НС'
                                     ,'Смерть в результате НС') AND
             pr.description = 'КС CR49 Малый и ср. бизнес') OR
             pr.description <> 'КС CR49 Малый и ср. бизнес');
    r_cur_prod cur_prod%ROWTYPE;
    CURSOR cur_altai
    (
      cur_assured_id IN NUMBER
     ,cur_birth_date IN DATE
     ,cur_start_date IN DATE
     ,cur_end_date   IN DATE
    ) IS
      SELECT id
            ,CASE
               WHEN lead(id) over(ORDER BY id) IS NULL THEN
                1
               ELSE
                0
             END AS is_last
            ,perc
            ,start_date
            ,CASE
               WHEN end_date < end_date_bordero THEN
                end_date - INTERVAL '1' SECOND
               ELSE
                end_date
             END AS end_date
            ,MONTHS_BETWEEN(end_date, start_date) /
             MONTHS_BETWEEN(end_date_bordero, start_date_bordero) koef_period
        FROM (SELECT pl.description
                    ,pl.id
                    ,cur_birth_date birth_date
                    ,cur_start_date AS start_date_bordero
                    ,cur_end_date AS end_date_bordero
                    ,CASE
                       WHEN pl.description = 'Смерть НСиБ' THEN
                        0.0105 / 0.02
                       WHEN pl.description = 'Инвалидность НСиБ I группы' THEN
                        0.0045 / 0.02
                       WHEN pl.description = 'ВНТ НСиБ' THEN
                        0.005 / 0.02
                       WHEN pl.description = 'Смерть НС (66-71)' THEN
                        0.014 / 0.02
                       WHEN pl.description = 'Инвалидность НС I группы (66-71)' THEN
                        0.006 / 0.02
                       WHEN pl.description = 'Смерть НС (71-76)' THEN
                        1
                       ELSE
                        0
                     END perc
                    ,least(ADD_MONTHS(cur_birth_date
                                     ,(to_number(regexp_substr(pct.brief, '\d+', 1, 2)) + 1) * 12)
                          ,cur_end_date) end_date
                    ,greatest(ADD_MONTHS(cur_birth_date
                                        ,(to_number(regexp_substr(pct.brief, '\d+')) + 1) * 12)
                             ,cur_start_date) start_date
                FROM t_product                pr
                    ,t_product_version        pv
                    ,t_product_ver_lob        pvl
                    ,t_product_line           pl
                    ,t_product_line_type      plt
                    ,ins.ven_t_prod_line_coef tplc
                    ,ins.t_prod_coef_type     pct
               WHERE pr.product_id = (SELECT ph.product_id
                                        FROM as_asset     a
                                            ,p_policy     p
                                            ,p_pol_header ph
                                       WHERE a.as_asset_id = cur_assured_id
                                         AND a.p_policy_id = p.policy_id
                                         AND p.pol_header_id = ph.policy_header_id)
                 AND pv.product_id = pr.product_id
                 AND pvl.product_version_id = pv.t_product_version_id
                 AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
                 AND plt.product_line_type_id = pl.product_line_type_id
                 AND tplc.t_product_line_id = pl.id
                 AND tplc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                 AND pct.brief LIKE 'Age_Limits%'
                 AND pl.skip_on_policy_creation = 0
              /*AND TRUNC(MONTHS_BETWEEN(cur_start_date,cur_birth_date) / 12) BETWEEN TO_NUMBER(REGEXP_SUBSTR(pct.brief,'\d+')) AND TO_NUMBER(REGEXP_SUBSTR(pct.brief,'\d+',1,2))*/
              )
       WHERE start_date <= end_date;
    r_cur_altai cur_altai%ROWTYPE;
  
    CURSOR cur_eurokom
    (
      cur_assured_id IN NUMBER
     ,cur_birth_date IN DATE
     ,cur_start_date IN DATE
     ,cur_end_date   IN DATE
    ) IS
      SELECT id
            ,CASE
               WHEN lead(id) over(ORDER BY id) IS NULL THEN
                1
               ELSE
                0
             END AS is_last
            ,perc
            ,start_date
            ,CASE
               WHEN end_date < end_date_bordero THEN
                end_date - INTERVAL '1' SECOND
               ELSE
                end_date
             END AS end_date
            ,FLOOR(MONTHS_BETWEEN(end_date, start_date)) /
             MONTHS_BETWEEN(end_date_bordero, start_date_bordero) koef_period
            ,CASE
               WHEN end_date < end_date_bordero
                    OR start_date > start_date_bordero THEN
                CASE description
                  WHEN 'Смерть ЛП (61-80)' THEN
                   CEIL(MONTHS_BETWEEN(end_date, start_date))
                  ELSE
                   FLOOR(MONTHS_BETWEEN(end_date, start_date))
                END
             --                 months_between(end_date,start_date)
               ELSE
                ROUND(MONTHS_BETWEEN(end_date, start_date))
             END months
      --             (end_date - start_date) / (end_date_bordero-start_date_bordero) koef_period
        FROM (SELECT pl.description
                    ,pl.id
                    ,cur_birth_date birth_date
                    ,cur_start_date AS start_date_bordero
                    ,cur_end_date AS end_date_bordero
                    ,CASE pr.brief
                       WHEN 'CR50_5' THEN
                        CASE
                          WHEN pl.description = 'Смерть застрахованного по любой причине' THEN
                           0.0004
                          WHEN pl.description = 'Инвалидность ЛП I группы' THEN
                           0.0001
                          WHEN pl.description = 'Смерть ЛП (61-80)' THEN
                           0.0016666666667
                          ELSE
                           0
                        END
                       WHEN 'CR50_6' THEN
                        0.0016666666667
                       ELSE
                        0
                     END perc
                    ,least(ADD_MONTHS(cur_birth_date
                                     ,(to_number(regexp_substr(pct.brief, '\d+', 1, 2)) + 1) * 12)
                          ,cur_end_date) end_date
                    ,greatest(ADD_MONTHS(cur_birth_date
                                        ,(to_number(regexp_substr(pct.brief, '\d+')) + 1) * 12)
                             ,cur_start_date) start_date
                FROM t_product                pr
                    ,t_product_version        pv
                    ,t_product_ver_lob        pvl
                    ,t_product_line           pl
                    ,t_product_line_type      plt
                    ,ins.ven_t_prod_line_coef tplc
                    ,ins.t_prod_coef_type     pct
               WHERE pr.product_id = (SELECT ph.product_id
                                        FROM as_asset     a
                                            ,p_policy     p
                                            ,p_pol_header ph
                                       WHERE a.as_asset_id = cur_assured_id
                                         AND a.p_policy_id = p.policy_id
                                         AND p.pol_header_id = ph.policy_header_id)
                 AND pv.product_id = pr.product_id
                 AND pvl.product_version_id = pv.t_product_version_id
                 AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
                 AND plt.product_line_type_id = pl.product_line_type_id
                 AND tplc.t_product_line_id = pl.id
                 AND tplc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                 AND pct.brief LIKE 'Age_Limits%'
                 AND pl.skip_on_policy_creation = 0
              /*AND TRUNC(MONTHS_BETWEEN(cur_start_date,cur_birth_date) / 12) BETWEEN TO_NUMBER(REGEXP_SUBSTR(pct.brief,'\d+')) AND TO_NUMBER(REGEXP_SUBSTR(pct.brief,'\d+',1,2))*/
              )
       WHERE start_date <= end_date;
    r_cur_eurokom cur_eurokom%ROWTYPE;
  BEGIN
    SELECT * INTO v_bordero FROM as_bordero_load asl WHERE asl.row_id = par_row_id;
  
    BEGIN
      /*Создаем контакт*/
      /*Эти чебуреки не дают пол застрахованного и фио слитно дают >:-/ */
      /*воспользуемся pkg_contact.get_fio_fmt*/
      /*-- 1 - Фамилия -- 2 - Имя -- 3 - Отчество и все осталное. -- 4 - Фамилия И. О. -- 5 - И. О. Фамилия
      -- 6 - Имя Отчество Фамилия*/
      IF v_bordero.first_name IS NULL
      THEN
        v_bordero.first_name := TRIM(pkg_contact.get_fio_fmt(v_bordero.surname, 2));
      END IF;
    
      IF v_bordero.middle_name IS NULL
      THEN
        v_bordero.middle_name := TRIM(pkg_contact.get_fio_fmt(v_bordero.surname, 3));
      END IF;
    
      IF v_bordero.gender IS NULL
      THEN
        v_bordero.gender := pkg_contact.get_sex_char(pkg_contact.get_fio_fmt(v_bordero.surname, 3));
      END IF;
      /*Проверяем на возрастные ограничения для Алтай*/
      IF g_bordero.special_program_flag = 1
      THEN
        BEGIN
          IF trunc(MONTHS_BETWEEN(v_bordero.start_date, v_bordero.birth_date) / 12) < 18
             OR trunc(MONTHS_BETWEEN(v_bordero.start_date, v_bordero.birth_date) / 12) > 76
          THEN
            tmp_log_writer('Возрастные ограничения для Алтай');
            RAISE special_limit_age;
          END IF;
        EXCEPTION
          WHEN special_limit_age THEN
            raise_application_error(-20001
                                   ,'Ограничение по возрасту застрахованного: ' || v_bordero.surname || ' ' ||
                                    v_bordero.first_name || ' ' || v_bordero.middle_name);
        END;
      END IF;
      /**/
      /*Проверяем на возрастные ограничения для Еврокоммерц*/
      IF g_bordero.special_program_flag = 2
      THEN
        BEGIN
          IF trunc(MONTHS_BETWEEN(v_bordero.start_date, v_bordero.birth_date) / 12) < 18
             OR trunc(MONTHS_BETWEEN(v_bordero.start_date, v_bordero.birth_date) / 12) > 80
          THEN
            tmp_log_writer('Возрастные ограничения для Еврокоммерц');
            RAISE special_limit_age;
          END IF;
        EXCEPTION
          WHEN special_limit_age THEN
            raise_application_error(-20001
                                   ,'Ограничение по возрасту застрахованного: ' || v_bordero.surname || ' ' ||
                                    v_bordero.first_name || ' ' || v_bordero.middle_name);
        END;
      END IF;
      /**/
    
      tmp_log_writer('Создем контакт');
      v_contact_id := create_person_contact(p_last_name       => v_bordero.surname /*TRIM(pkg_contact.get_fio_fmt(v_bordero.SURNAME
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ,1))*/
                                           , /*v_bordero.name*/p_first_name      => v_bordero.first_name
                                           ,p_middle_name     => v_bordero.middle_name
                                           ,p_birth_date      => v_bordero.birth_date
                                           ,p_gender          => v_bordero.gender
                                           ,p_pass_ser        => v_bordero.doc_ser
                                           ,p_pass_num        => v_bordero.doc_num
                                           ,p_pass_issue_date => v_bordero.doc_issued_date
                                           ,p_pass_issued_by  => v_bordero.doc_issued_by
                                           ,p_address         => v_bordero.person_addres
                                           ,p_contact_phone   => v_bordero.person_telephone);
      tmp_log_writer('Создали контакт');
      /*Создаем полис*/
      tmp_log_writer('Создем полис');
    
      --Проверяем есть ли уже в системе подобный полис
      BEGIN
        SELECT pol_header_id
              ,policy_id
          INTO v_pol_header_id
              ,v_policy_id
          FROM (SELECT vp.pol_header_id
                      ,vp.policy_id
                      ,vp.version_num
                  FROM ven_p_policy vp
                 WHERE notice_ser = g_bordero.pol_ser
                   AND notice_num = v_bordero.notice_num
                 ORDER BY vp.version_num DESC)
         WHERE rownum = 1;
        --Полис есть ничего не делаем
        tmp_log_writer('Полис существует');
        RETURN(v_pol_header_id);
      
        --TODO Сделать update имеющегося полиса на основании его состояни (Project)
        --получить и обновить если надо объект страхования, удалить покрытия
        -- Возможно и не надо ничего делать. ВОзможно сюда попадет закачка версий полиса
        /*for c_cover in
        (select pc.p_cover_id
           from ven_p_cover pc
          where pc.as_asset_id = p_asset_id)
        loop
          pkg_cover.exclude_cover(c_cover.p_cover_id);
        end loop;*/
      
      EXCEPTION
        WHEN too_many_rows THEN
          --Ничего пока не делаем, может пригодится
          RETURN(NULL);
        WHEN no_data_found THEN
          --Полиса нет заведем
          SELECT f.fund_id
            INTO v_fund_id
            FROM fund f
           WHERE f.brief = substr(TRIM(v_bordero.fund), 1, 3);
        
          v_pol_header_id := pkg_renlife_utils.policy_insert(g_bordero.produc_id
                                                            ,g_bordero.sales_channel_id
                                                            ,g_bordero.agency_id
                                                            ,v_fund_id
                                                            ,
                                                             --g_bordero.fund_id,
                                                             g_bordero.pay_fund_id
                                                            ,g_bordero.confirm_condition_id
                                                            ,g_bordero.pol_ser
                                                            ,v_bordero.notice_num
                                                            ,v_bordero.start_date
                                                            , --notice date
                                                             v_bordero.start_date
                                                            , --sign date
                                                             v_bordero.start_date
                                                            , --confirm date
                                                             v_bordero.start_date
                                                            , --strat date
                                                             v_bordero.end_date
                                                            ,v_bordero.start_date
                                                            , --first pay date
                                                             g_bordero.payment_term_id
                                                            ,g_bordero.period_id
                                                            ,v_contact_id
                                                            ,g_bordero.fee_payment_term
                                                            ,g_bordero.fact_j
                                                            ,g_bordero.admin_cost
                                                            ,g_bordero.is_group
                                                            ,v_bordero.notice_num
                                                            ,g_bordero.waiting_periood_id
                                                            ,g_bordero.region_id
                                                            ,g_bordero.f_discount_id
                                                            ,g_bordero.description
                                                            ,g_bordero.payment_off_id
                                                            ,g_bordero.header_description
                                                            ,g_bordero.discount_period);
          tmp_log_writer('Создали полис' || v_pol_header_id || ', добавляем объект страхования');
        
          /*Добавляем застрахованного как объект страхования*/
          SELECT policy_id
            INTO v_policy_id
            FROM ven_p_pol_header
           WHERE policy_header_id = v_pol_header_id;
        
      END;
      --      v_assured_id := create_as_assured(v_policy_id, v_contact_id, v_work_group_id);
      v_assured_id := pkg_asset.create_as_assured(p_pol_id        => v_policy_id
                                                 ,p_contact_id    => v_contact_id
                                                 ,p_work_group_id => v_work_group_id);
    
      pkg_asset.create_insuree_info(p_pol_id => v_policy_id, p_work_group_id => v_work_group_id);
    
      IF g_bordero.benificiary_id IS NOT NULL
      THEN
        add_asset_beneficiary(v_assured_id
                             ,g_bordero.benificiary_id
                             ,g_bordero.benificiary_role
                             ,g_bordero.asset_role
                             ,g_bordero.fund_id
                             ,g_bordero.benificiary_part_value
                             ,g_bordero.benificiary_part_id
                             ,g_bordero.description);
      END IF;
    
      tmp_log_writer('Создали застрахованного ' || v_assured_id);
    
      IF g_bordero.special_program_flag = 0
         OR g_bordero.special_program_flag IS NULL
      THEN
        /*договора кроме Алтай и Жизнь бюджетника 506/507 серий*/
      
        OPEN cur_prod(v_assured_id);
      
        LOOP
          FETCH cur_prod
            INTO r_cur_prod;
          EXIT WHEN cur_prod%NOTFOUND;
        
          IF r_cur_prod.percent != 0
          THEN
            BEGIN
              -- Байтин А.
              -- Иногда дата окончания покрытия сдвигается в большую сторону,
              -- из-за обновления даты окончания действия застрахованного максимальной датой покрытия,
              -- а она в свою очередь рассчитывается как as_asset.end_date+1-interval '1' second.
              -- Так что обновление даты производим только в последнем риске 
              tmp_log_writer('Добавляем покрытие по программе ' || r_cur_prod.id);
              v_cover_id := pkg_cover.cre_new_cover(v_assured_id
                                                   ,r_cur_prod.id
                                                   ,r_cur_prod.is_last = 1);
            
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20001
                                       ,'Ошибка подключения покрытия: ' || SQLERRM);
            END;
          
            tmp_log_writer('Добавляем сумму на покрытие');
            /*Добавляем страховую сумму и премию на покрытие*/
            IF g_bordero.flag_zabota = 1
            THEN
              p_is_handchange_amount  := 0;
              p_is_handchange_premium := 0;
              p_is_handchange_fee     := 0;
              p_is_handchange_tariff  := 0;
            ELSE
              p_is_handchange_amount  := 1;
              p_is_handchange_premium := 1;
              p_is_handchange_fee     := 1;
              p_is_handchange_tariff  := 1;
            END IF;
          
            IF r_cur_prod.fee_round_rules_id IS NOT NULL
            THEN
              v_fee := pkg_round_rules.calculate(r_cur_prod.fee_round_rules_id
                                                ,v_bordero.ins_prem * r_cur_prod.percent);
            ELSE
              v_fee := v_bordero.ins_prem * r_cur_prod.percent;
            
            END IF;
          
            DECLARE
              v_ins_amount NUMBER;
            BEGIN
            
              IF r_cur_prod.ins_amount_round_rules_id IS NOT NULL
              THEN
                v_ins_amount := pkg_round_rules.calculate(r_cur_prod.ins_amount_round_rules_id
                                                         ,v_bordero.ins_sum);
              ELSE
                v_ins_amount := v_bordero.ins_sum;
              
              END IF;
            
              UPDATE p_cover
                 SET is_handchange_amount  = p_is_handchange_amount
                    ,is_handchange_premium = p_is_handchange_premium
                    ,is_handchange_fee     = p_is_handchange_fee
                    ,is_handchange_tariff  = p_is_handchange_tariff
                    ,ins_amount            = v_ins_amount
                    ,fee                   = v_fee
                    ,premium               = v_fee
               WHERE p_cover_id = v_cover_id;
            END;
          END IF;
        END LOOP;
      
        CLOSE cur_prod;
      ELSIF g_bordero.special_program_flag = 1
      THEN
        /*Алтай*/
        OPEN cur_altai(v_assured_id, v_bordero.birth_date, v_bordero.start_date, v_bordero.end_date);
      
        LOOP
          FETCH cur_altai
            INTO r_cur_altai;
          EXIT WHEN cur_altai%NOTFOUND;
          BEGIN
            tmp_log_writer('Добавляем покрытие по программе ' || r_cur_altai.id);
            v_cover_id := pkg_cover.cre_new_cover(v_assured_id
                                                 ,r_cur_altai.id
                                                 ,r_cur_altai.is_last = 1
                                                 ,r_cur_altai.start_date
                                                 ,r_cur_altai.end_date);
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001
                                     ,'Ошибка подключения покрытия: ' || SQLERRM);
          END;
        
          tmp_log_writer('Добавляем сумму на покрытие');
          /*Добавляем страховую сумму и премию на покрытие*/
          p_is_handchange_amount  := 1;
          p_is_handchange_premium := 1;
          p_is_handchange_fee     := 1;
          p_is_handchange_tariff  := 1;
          v_fee                   := ROUND(v_bordero.ins_prem * r_cur_altai.koef_period *
                                           r_cur_altai.perc
                                          ,2);
          UPDATE p_cover
             SET is_handchange_amount  = p_is_handchange_amount
                ,is_handchange_premium = p_is_handchange_premium
                ,is_handchange_fee     = p_is_handchange_fee
                ,is_handchange_tariff  = p_is_handchange_tariff
                ,ins_amount            = v_bordero.ins_sum
                ,fee                   = v_fee
                ,premium               = v_fee
           WHERE p_cover_id = v_cover_id;
        END LOOP;
      ELSIF g_bordero.special_program_flag = 2
      THEN
        /*Еврокоммерц*/
        OPEN cur_eurokom(v_assured_id
                        ,v_bordero.birth_date
                        ,v_bordero.start_date
                        ,v_bordero.end_date + INTERVAL '1' DAY - INTERVAL '1' SECOND);
      
        LOOP
          FETCH cur_eurokom
            INTO r_cur_eurokom;
          EXIT WHEN cur_eurokom%NOTFOUND;
          BEGIN
            tmp_log_writer('Добавляем покрытие по программе ' || r_cur_eurokom.id);
            v_cover_id := pkg_cover.cre_new_cover(v_assured_id
                                                 ,r_cur_eurokom.id
                                                 ,r_cur_eurokom.is_last = 1
                                                 ,r_cur_eurokom.start_date
                                                 ,r_cur_eurokom.end_date);
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001
                                     ,'Ошибка подключения покрытия: ' || SQLERRM);
          END;
        
          tmp_log_writer('Добавляем сумму на покрытие');
          /*Добавляем страховую сумму и премию на покрытие*/
          p_is_handchange_amount  := 1;
          p_is_handchange_premium := 1;
          p_is_handchange_fee     := 1;
          p_is_handchange_tariff  := 1;
          v_fee                   := ROUND(v_bordero.ins_sum * r_cur_eurokom.months *
                                           r_cur_eurokom.perc
                                          ,2);
          UPDATE p_cover
             SET is_handchange_amount  = p_is_handchange_amount
                ,is_handchange_premium = p_is_handchange_premium
                ,is_handchange_fee     = p_is_handchange_fee
                ,is_handchange_tariff  = p_is_handchange_tariff
                ,ins_amount            = v_bordero.ins_sum
                ,fee                   = v_fee
                ,premium               = v_fee
           WHERE p_cover_id = v_cover_id;
        END LOOP;
        CLOSE cur_eurokom;
      
      ELSIF g_bordero.special_program_flag = 3
      THEN
        OPEN cur_prod(v_assured_id);
      
        LOOP
          FETCH cur_prod
            INTO r_cur_prod;
          EXIT WHEN cur_prod%NOTFOUND;
        
          BEGIN
            -- Байтин А.
            -- Иногда дата окончания покрытия сдвигается в большую сторону,
            -- из-за обновления даты окончания действия застрахованного максимальной датой покрытия,
            -- а она в свою очередь рассчитывается как as_asset.end_date+1-interval '1' second.
            -- Так что обновление даты производим только в последнем риске 
            tmp_log_writer('Добавляем покрытие по программе ' || r_cur_prod.id);
            v_cover_id := pkg_cover.cre_new_cover(v_assured_id, r_cur_prod.id, r_cur_prod.is_last = 1);
          
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001
                                     ,'Ошибка подключения покрытия: ' || SQLERRM);
          END;
        
          DECLARE
            v_ins_amount NUMBER;
          BEGIN
          
            IF r_cur_prod.ins_amount_round_rules_id IS NOT NULL
            THEN
              v_ins_amount := pkg_round_rules.calculate(r_cur_prod.ins_amount_round_rules_id
                                                       ,v_bordero.ins_sum);
            ELSE
              v_ins_amount := v_bordero.ins_sum;
            
            END IF;
          
            UPDATE p_cover
               SET ins_amount = v_ins_amount
                  ,fee        = NULL
                  ,premium    = NULL
             WHERE p_cover_id = v_cover_id;
          END;
        END LOOP;
      
        CLOSE cur_prod;
      END IF;
    
      IF g_bordero.special_program_flag = 1
         OR g_bordero.special_program_flag = 2
      THEN
        DECLARE
          v_sum       NUMBER;
          v_delta_fee NUMBER := 0;
          step        NUMBER := 0.01;
        BEGIN
          SELECT v_bordero.ins_prem - SUM(fee)
            INTO v_delta_fee
            FROM p_cover
           WHERE as_asset_id = v_assured_id;
        
          IF v_delta_fee != 0
          THEN
            IF v_delta_fee < 0
            THEN
              step := -0.01;
            END IF;
          
            WHILE (v_delta_fee != 0)
            LOOP
              UPDATE p_cover
                 SET fee     = fee + step
                    ,premium = premium + step
               WHERE p_cover_id =
                     (SELECT pc.p_cover_id
                        FROM p_cover pc
                       WHERE pc.as_asset_id = v_assured_id
                         AND fee = (SELECT MAX(fee) FROM p_cover WHERE as_asset_id = v_assured_id));
              v_delta_fee := v_delta_fee - step;
            END LOOP;
          END IF;
        END;
      END IF;
    
      tmp_log_writer('Добавляем сумму на застрахованного');
      /*Т.к. у нас одна строка на одного застрахованного то сумму по застрахованному по покрытиям не складываем*/
      v_asset_prem := v_bordero.ins_prem;
      /*Обновляем сумму по застрахованному*/
    
      pkg_policy.update_policy_sum(v_policy_id, v_asset_prem, v_bordero.ins_sum);
    
      -- ishch (
    
      -- Присоединить БСО к ДС
      SELECT bv.bso_series_id
            ,bs.series_num
        INTO v_bso_series_id
            ,v_bso_series_num
        FROM as_bordero_vedom bv
            ,bso_series       bs
       WHERE bv.session_id = v_bordero.session_id
         AND bs.bso_series_id = bv.bso_series_id;
    
      DECLARE
        v_product_brief t_product.brief%TYPE;
        --        v_bso_series_id bso.bso_series_id%type;
      BEGIN
        SELECT pr.brief
          INTO v_product_brief
          FROM t_product pr
         WHERE pr.product_id = g_bordero.produc_id;
      
        IF (v_product_brief LIKE 'CR92%' OR v_product_brief LIKE 'CR102%' OR
           v_product_brief LIKE 'RenCap%')
        THEN
          -- Находим серию
        
          v_bordero.notice_num := pkg_bso.gen_next_bso_number(v_bso_series_id);
        
        END IF;
      END;
			
      v_bso_id        := pkg_bso.find_bso_by_num(par_policy_id     => v_policy_id
                                                ,par_bso_num       => v_bordero.notice_num
                                                ,par_bso_series_id => v_bso_series_id);
    
      pkg_bso.attach_bso_to_policy(par_policy_id => v_policy_id, par_bso_id => v_bso_id);
    
      RETURN(v_pol_header_id);
    EXCEPTION
      WHEN OTHERS THEN
        --ROLLBACK TO BEfore_load;
        --COMMIT;
        raise_application_error(-20001, 'Ошибка создании полиса ' || SQLERRM);
    END;
    NULL;
    --ROLLBACK TO BEfore_load;
  
  END load_policy_from_bordero;

  /*Создасть на полисе застрахованного*/
  FUNCTION create_as_assured
  (
    p_pol_id        NUMBER
   ,p_contact_id    NUMBER
   ,p_work_group_id NUMBER
   ,p_asset_type    VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_ah               NUMBER;
    v_sh               NUMBER;
    v_a                NUMBER;
    v_asset_type       NUMBER;
    v_asset_start_date DATE;
    v_asset_end_date   DATE;
    v_issuer_id        NUMBER;
    v_hobby_id         NUMBER;
    v_gender           NUMBER;
  BEGIN
    v_a := pkg_asset.create_as_assured(p_pol_id        => p_pol_id
                                      ,p_contact_id    => p_contact_id
                                      ,p_work_group_id => p_work_group_id
                                      ,p_asset_type    => p_asset_type);
    RETURN v_a;
  END create_as_assured;

  /*Добавить контакту контакты*/
  PROCEDURE set_contact_contacts
  (
    par_contact_id        NUMBER
   ,par_address           VARCHAR2
   ,par_contact_telephone VARCHAR2 DEFAULT NULL
   ,par_country_id        NUMBER DEFAULT NULL
  ) IS
  BEGIN
    pkg_contact.set_contact_contacts(par_contact_id        => par_contact_id
                                    ,par_address           => par_address
                                    ,par_contact_telephone => par_contact_telephone
                                    ,par_country_id        => par_country_id);
  END;

  /*Создать контакт*/
  FUNCTION create_person_contact
  (
    p_last_name       VARCHAR2
   ,p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_birth_date      DATE
   ,p_gender          VARCHAR2
   ,p_pass_ser        VARCHAR2
   ,p_pass_num        VARCHAR2
   ,p_pass_issue_date DATE
   ,p_pass_issued_by  VARCHAR2
   ,p_address         VARCHAR2 DEFAULT NULL
   ,p_contact_phone   VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_contact.create_person_contact_rlu(p_last_name
                                                ,p_first_name
                                                ,p_middle_name
                                                ,p_birth_date
                                                ,p_gender
                                                ,p_pass_ser
                                                ,p_pass_num
                                                ,p_pass_issue_date
                                                ,p_pass_issued_by
                                                ,p_address
                                                ,p_contact_phone);
  END create_person_contact;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.07.2008 16:44:01
  -- Purpose : Вычисляем сумму из проводок по покрытию
  FUNCTION cover_amount_from_trans
  (
    p_cover_id       NUMBER
   ,p_trans_templ_id NUMBER
   ,p_start_date     DATE DEFAULT NULL
   ,p_end_date       DATE DEFAULT NULL
  ) RETURN NUMBER IS
    cover_ent_id NUMBER;
    RESULT       NUMBER;
  BEGIN
  
    SELECT ent_id INTO cover_ent_id FROM entity WHERE brief = 'P_COVER';
  
    SELECT SUM(t.trans_amount)
      INTO RESULT
      FROM trans t
     WHERE (t.trans_date >= p_start_date OR p_start_date IS NULL)
       AND (t.trans_date < p_end_date OR p_end_date IS NULL)
       AND t.trans_templ_id = p_trans_templ_id
       AND ((t.a1_dt_ure_id = cover_ent_id AND t.a1_dt_uro_id = p_cover_id) OR
           (t.a2_dt_ure_id = cover_ent_id AND t.a2_dt_uro_id = p_cover_id) OR
           (t.a3_dt_ure_id = cover_ent_id AND t.a3_dt_uro_id = p_cover_id) OR
           (t.a4_dt_ure_id = cover_ent_id AND t.a4_dt_uro_id = p_cover_id) OR
           (t.a5_dt_ure_id = cover_ent_id AND t.a5_dt_uro_id = p_cover_id) OR
           (t.a1_ct_ure_id = cover_ent_id AND t.a1_ct_uro_id = p_cover_id) OR
           (t.a2_ct_ure_id = cover_ent_id AND t.a2_ct_uro_id = p_cover_id) OR
           (t.a3_ct_ure_id = cover_ent_id AND t.a3_ct_uro_id = p_cover_id) OR
           (t.a4_ct_ure_id = cover_ent_id AND t.a4_ct_uro_id = p_cover_id) OR
           (t.a5_ct_ure_id = cover_ent_id AND t.a5_ct_uro_id = p_cover_id));
  
    RETURN(nvl(RESULT, 0));
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка выполнения Cover_amount_from_trans ' || SQLERRM);
  END cover_amount_from_trans;

  -- Веселуха
  -- 13.07.2009
  -- Сумма проводок по версии договора
  FUNCTION policy_amount_from_trans
  (
    p_pol_id         NUMBER
   ,p_trans_templ_id NUMBER
   ,p_start_date     DATE DEFAULT NULL
   ,p_end_date       DATE DEFAULT NULL
  ) RETURN NUMBER IS
    pol_ent_id NUMBER;
    RESULT     NUMBER;
  BEGIN
  
    SELECT ent_id INTO pol_ent_id FROM entity WHERE brief = 'P_POLICY';
  
    SELECT SUM(t.trans_amount)
      INTO RESULT
      FROM trans    t
          ,p_policy pp
     WHERE (t.trans_date >= p_start_date OR p_start_date IS NULL)
       AND (t.trans_date < p_end_date OR p_end_date IS NULL)
       AND (pp.policy_id = p_pol_id OR p_pol_id IS NULL)
       AND t.trans_templ_id = p_trans_templ_id
       AND ((t.a1_dt_ure_id = pol_ent_id AND t.a1_dt_uro_id = p_pol_id) OR
           (t.a2_dt_ure_id = pol_ent_id AND t.a2_dt_uro_id = p_pol_id) OR
           (t.a3_dt_ure_id = pol_ent_id AND t.a3_dt_uro_id = p_pol_id) OR
           (t.a4_dt_ure_id = pol_ent_id AND t.a4_dt_uro_id = p_pol_id) OR
           (t.a5_dt_ure_id = pol_ent_id AND t.a5_dt_uro_id = p_pol_id) OR
           (t.a1_ct_ure_id = pol_ent_id AND t.a1_ct_uro_id = p_pol_id) OR
           (t.a2_ct_ure_id = pol_ent_id AND t.a2_ct_uro_id = p_pol_id) OR
           (t.a3_ct_ure_id = pol_ent_id AND t.a3_ct_uro_id = p_pol_id) OR
           (t.a4_ct_ure_id = pol_ent_id AND t.a4_ct_uro_id = p_pol_id) OR
           (t.a5_ct_ure_id = pol_ent_id AND t.a5_ct_uro_id = p_pol_id));
    RETURN(nvl(RESULT, 0));
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка выполнения policy_amount_from_trans ' || SQLERRM);
  END policy_amount_from_trans;

  -- Author  : ALEXEY.KATKEVICH
  -- Purpose : Получает документы по контакту
  --doc_attr:
  -- 1 Серия
  -- 2 Номер
  -- 3 Выдан
  -- 4 Дата выдачи
  FUNCTION get_contact_doc
  (
    p_contact_id NUMBER
   ,doc_attr     NUMBER
   ,doc_date     DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    var_ser       VARCHAR2(20);
    var_num       VARCHAR2(20);
    var_date      DATE;
    var_issued_by VARCHAR2(255);
  BEGIN
    SELECT *
      INTO var_ser
          ,var_num
          ,var_issued_by
          ,var_date
      FROM (SELECT cci.serial_nr
                  ,cci.id_value
                  ,cci.place_of_issue
                  ,to_char(cci.issue_date, 'dd.mm.yyyy')
              FROM ven_cn_person        vcp
                  ,ven_cn_contact_ident cci
                  ,ven_t_id_type        tit
             WHERE vcp.contact_id = p_contact_id
               AND vcp.contact_id = cci.contact_id
               AND cci.id_type = tit.id
               AND tit.description <> 'ИНН'
               AND (cci.issue_date < doc_date OR doc_date IS NULL)
             ORDER BY nvl(cci.is_default, 0) DESC
                     ,tit.sort_order
                     ,nvl(cci.issue_date, '01.01.1900') DESC)
     WHERE rownum = 1;
  
    CASE
      WHEN doc_attr = 1 THEN
        RETURN var_ser;
      WHEN doc_attr = 2 THEN
        RETURN var_num;
      WHEN doc_attr = 3 THEN
        RETURN var_date;
      WHEN doc_attr = 4 THEN
        RETURN var_issued_by;
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.09.2008
  -- Purpose : Получает ФИО по номеру договора (только если агнет имеет заданную категорию)
  -- Удалить после использования делалась для упрощения написания отчетов
  FUNCTION get_fio_by_ag_contract_id
  (
    par_ag_contract_id NUMBER
   ,par_category_id    NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
    proc_name VARCHAR2(30) := 'get_fio_by_ag_contract_id';
    RESULT    VARCHAR2(255);
  BEGIN
    SELECT c.obj_name_orig
      INTO RESULT
      FROM contact            c
          ,ag_contract_header ach
          ,ag_contract        ac
     WHERE c.contact_id = ach.agent_id
       AND ac.contract_id = ach.ag_contract_header_id
       AND ac.ag_contract_id = par_ag_contract_id
       AND (ac.category_id = par_category_id OR par_category_id IS NULL);
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка выполнения ' || proc_name || ' ' || SQLERRM);
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 05.06.2009 16:12:16
  -- Purpose : Получает наименование статуса агента
  FUNCTION get_ag_stat_brief
  (
    par_ag_contract_header NUMBER
   ,par_date               DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    RESULT    VARCHAR(50);
    proc_name VARCHAR2(20) := 'get_ag_stat_brief';
  BEGIN
    SELECT NAME
      INTO RESULT
      FROM ag_stat_agent a
     WHERE a.ag_stat_agent_id = get_ag_stat_id(par_ag_contract_header, par_date, 1);
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_ag_stat_brief;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.09.2008
  -- Purpose : Получает статус агента по id шапки договора
  -- par_return - определяет возвращать ли статус если на нужную дату он не найден
  -- 1 - возвращаем статус на дату
  -- 2 - возвращаем статус, если на такую дату статуса нет то возвращаем минимальный
  -- 3 - возвращаем статус, если есть статус базовый с датой больше то возвращаем его
  --     если статус не найден то возвращаем минимальный
  -- 4 - возвращает ag_stat_hist_id
  FUNCTION get_ag_stat_id
  (
    par_ag_contract_header NUMBER
   ,par_date               DATE DEFAULT SYSDATE
   ,par_return             NUMBER DEFAULT 1
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(30) := 'get_ag_stat_brief';
  BEGIN
  
    SELECT CASE
             WHEN par_return = 4 THEN
              ag_stat_hist_id
             ELSE
              ag_stat_agent_id
           END
      INTO RESULT
      FROM (SELECT ash.ag_stat_agent_id
                  ,ash.ag_stat_hist_id
              FROM ag_stat_hist  ash
                  ,ag_stat_agent asa
             WHERE ash.ag_contract_header_id = par_ag_contract_header
               AND asa.ag_stat_agent_id(+) = ash.ag_stat_agent_id
               AND (ash.stat_date <= par_date OR
                   (par_return = 3 AND asa.brief LIKE 'Баз%' AND ash.stat_date > par_date))
             ORDER BY ash.num DESC)
     WHERE rownum = 1;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN no_data_found THEN
      IF par_return > 1
         AND par_return < 4
      THEN
        SELECT MAX(ag_stat_agent_id)
          INTO RESULT
          FROM (SELECT ash.ag_stat_agent_id
                  FROM ag_stat_hist  ash
                      ,ag_stat_agent asa
                 WHERE ash.ag_contract_header_id = par_ag_contract_header
                   AND asa.ag_stat_agent_id(+) = ash.ag_stat_agent_id
                 ORDER BY ash.num DESC)
         WHERE rownum = 1;
        RETURN(RESULT);
      ELSE
        RETURN(NULL);
      END IF;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка выполнения ' || proc_name || ' ' || SQLERRM);
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.09.2008 14:17:58
  -- Purpose : Получает статус агента по ДС на дату
  -- Понадобилась потому что pkg_agent_subs.get_p_agent_status_by_date работает не адекватно
  --
  FUNCTION get_p_ag_status_by_date
  (
    par_ag_header_id  NUMBER
   ,par_pol_header_id NUMBER
   ,par_date          DATE
  ) RETURN VARCHAR2 IS
    RESULT    VARCHAR2(20);
    proc_name VARCHAR2(30) := 'get_pol_ag_status_by_date';
  BEGIN
    --Каткевич А.Г. 05/06/2009
    SELECT CASE
             WHEN SUM(CASE
                        WHEN ag_contract_header_id = par_ag_header_id THEN
                         1
                        ELSE
                         0
                      END) = 0 THEN
              'CANCEL'
             WHEN SUM(CASE
                        WHEN ag_contract_header_id = par_ag_header_id THEN
                         1
                        ELSE
                         0
                      END) > 0 THEN
              'CURRENT'
             ELSE
              'ERROR'
           END stat
      INTO RESULT
      FROM p_policy_agent      pa
          ,policy_agent_status pas
     WHERE pa.policy_header_id = par_pol_header_id
       AND pa.status_id = pas.policy_agent_status_id
       AND pas.brief <> 'ERROR'
       AND pa.date_start <= par_date
       AND pa.date_end > par_date;
  
    /*    SELECT brief, ag_contract_header_id
           INTO RESULT, ach_id
           FROM
         (SELECT pas.brief, pa.ag_contract_header_id
            FROM (SELECT date_start,
                         date_end,
                         status_date,
                         p_policy_agent_id,
                         status_id,
                         ag_contract_header_id
                    FROM p_policy_agent
                   WHERE policy_header_id=par_pol_header_id)  pa,
                 policy_agent_status pas
           WHERE pas.policy_agent_status_id = pa.status_id
    --         AND pa.policy_header_id = par_pol_header_id
             AND pa.date_start <= par_date
             AND pa.date_end > par_date
             AND pas.brief <> 'ERROR'
           ORDER BY pa.date_start DESC, pa.status_date DESC, pa.p_policy_agent_id DESC)
         WHERE ROWNUM = 1;
    
        IF RESULT = 'CURRENT' THEN Return(Result);
     ELSIF RESULT = 'CANCEL' AND ach_id = par_ag_header_id THEN Return('CURRENT');
      ELSE Return('CANCEL');
       END IF;    */
  
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN('ERROR');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_p_ag_status_by_date;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.04.2009 15:22:26
  -- Purpose : Получает признак переданного ДС для АД
  FUNCTION is_p_agent_transfered
  (
    p_ag_contract_header NUMBER
   ,p_pol_header         NUMBER
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(30) := 'is_p_agent_transfered';
  BEGIN
    SELECT CASE
             WHEN SUM(tr) > 0 THEN
              1
             ELSE
              0
           END
      INTO RESULT
      FROM (SELECT (nvl2(lag(pa1.date_start) over(ORDER BY pa1.date_start), 1, 0)) tr
                  ,pa1.ag_contract_header_id
              FROM p_policy_agent      pa1
                  ,policy_agent_status pas1
             WHERE pa1.status_id = pas1.policy_agent_status_id
               AND pas1.brief <> 'ERROR'
               AND pa1.policy_header_id = p_pol_header) pa
     WHERE pa.ag_contract_header_id = p_ag_contract_header;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END is_p_agent_transfered;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.09.2008 17:25:24
  -- Purpose : Получает ag_header_id продавшего ДС агента
  FUNCTION get_p_agent_sale(par_pol_header_id NUMBER) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'get_p_agent_sale';
  BEGIN
    SELECT ag_contract_header_id
      INTO RESULT
      FROM (SELECT pa.ag_contract_header_id
              FROM p_policy_agent      pa
                  ,policy_agent_status pas
             WHERE pas.policy_agent_status_id = pa.status_id
               AND pa.policy_header_id = par_pol_header_id
               AND pas.brief <> 'ERROR'
             ORDER BY pa.date_start        ASC
                     ,pa.status_date       ASC
                     ,pa.p_policy_agent_id ASC)
     WHERE rownum = 1;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_p_agent_sale;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 28.02.2011 17:25:24
  -- Purpose : Получает ag_header_id продавшего ДС агента
  FUNCTION get_p_agent_sale_new(par_pol_header_id NUMBER) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'get_p_agent_sale_new';
  BEGIN
    SELECT ag_contract_header_id
      INTO RESULT
      FROM (SELECT pad.ag_contract_header_id
              FROM p_policy_agent_doc pad
             WHERE pad.policy_header_id = par_pol_header_id
               AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN ('ERROR')
             ORDER BY pad.date_begin            ASC
                     ,pad.p_policy_agent_doc_id ASC)
     WHERE rownum = 1;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_p_agent_sale_new;

  -- Author  : GERASIMOV.ANDREY
  -- Created : 19.12.2008
  -- Purpose : Получает ag_header_id текущего агента по Договору Страхования
  -- par_date - дата на которую нужно получить действующего агента
  -- par_return - параметр определяет что вернуть.
  FUNCTION get_p_agent_current
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(30) := 'get_p_agent_current';
  BEGIN
    SELECT a
      INTO RESULT
      FROM (SELECT CASE
                     WHEN par_return = 1 THEN
                      pa.ag_contract_header_id
                     ELSE
                      pa.p_policy_agent_id
                   END a
              FROM p_policy_agent      pa
                  ,policy_agent_status pas
             WHERE pas.policy_agent_status_id = pa.status_id
               AND pa.policy_header_id = par_pol_header_id
               AND pas.brief <> 'ERROR'
               AND (pa.date_start <= par_date OR par_date IS NULL)
             ORDER BY pa.date_start        DESC
                     ,pa.status_date       DESC
                     ,pa.p_policy_agent_id DESC)
     WHERE rownum = 1;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_p_agent_current;

  -- Author  : GERASIMOV.ANDREY
  -- Created : 28.02.2011
  -- Purpose : Получает ag_header_id текущего агента по Договору Страхования
  -- par_date - дата на которую нужно получить действующего агента
  -- par_return - параметр определяет что вернуть.
  FUNCTION get_p_agent_current_new
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(30) := 'get_p_agent_current_new';
  BEGIN
    SELECT a
      INTO RESULT
      FROM (SELECT CASE
                     WHEN par_return = 1 THEN
                      pad.ag_contract_header_id
                     ELSE
                      pad.p_policy_agent_doc_id
                   END a
              FROM p_policy_agent_doc pad
             WHERE pad.policy_header_id = par_pol_header_id
               AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN ('ERROR')
               AND (pad.date_begin <= par_date OR par_date IS NULL)
             ORDER BY pad.date_begin            DESC
                     ,pad.p_policy_agent_doc_id DESC)
     WHERE rownum = 1;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_p_agent_current_new;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.10.2008 11:32:32
  -- Purpose : Получает индивидуальный план продаж
  -- par_ret - тип возврашаемого плана 1 - сумма СГП, 2 - количество договоров
  FUNCTION get_ag_plan
  (
    par_ag_contract_header NUMBER
   ,par_date               DATE
   ,par_ret                NUMBER
  ) RETURN NUMBER IS
    RESULT      NUMBER;
    proc_name   VARCHAR2(20) := 'ag_get_plan';
    v_month_num NUMBER;
    v_status_id NUMBER;
  
  BEGIN
  
    SELECT decode(par_ret, 1, k_sgp, 2, ag_count, 0)
      INTO RESULT
      FROM ag_plan_sale ap
     WHERE ap.ag_contract_header_id = par_ag_contract_header
       AND par_date BETWEEN ap.date_start AND ap.date_end;
  
    RETURN(RESULT);
  
  EXCEPTION
    WHEN no_data_found THEN
      /*Если индивидуальный план не заполнен тягаем общий*/
      v_month_num := pkg_ag_calc_admin.get_months(par_ag_contract_header, last_day(par_date), 4); --Берем только для директоров
      SELECT ag_stat_agent_id
        INTO v_status_id
        FROM (SELECT ash.ag_stat_agent_id
                FROM ag_stat_agent aga
                    ,ag_stat_hist  ash
               WHERE ash.ag_contract_header_id = par_ag_contract_header
                 AND ash.ag_stat_agent_id = aga.ag_stat_agent_id
                 AND (ash.stat_date <= par_date OR par_date IS NULL)
               ORDER BY ash.num DESC)
       WHERE rownum = 1;
      RESULT := pkg_ag_calc_admin.get_plan_old(v_month_num, v_status_id, last_day(par_date));
      RETURN(RESULT);
    
    WHEN too_many_rows THEN
      raise_application_error(-20002
                             ,'Для ' || par_ag_contract_header ||
                              ' есть более одного плана продаж на ' || par_date);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_ag_plan;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.10.2008 18:42:03
  -- Purpose : Получает дату изменения категории
  FUNCTION get_ag_cat_date
  (
    par_ag_contract_header_id NUMBER
   ,par_date                  DATE
   ,par_cat                   NUMBER
  ) RETURN DATE IS
    RESULT    DATE;
    proc_name VARCHAR2(20) := 'get_ag_cat_date';
  BEGIN
  
    FOR r IN (
              
              SELECT num
                     ,date_begin
                     ,category_id
                FROM ven_ag_contract
               WHERE contract_id = par_ag_contract_header_id
                 AND date_begin <= par_date
               ORDER BY num DESC)
    LOOP
      IF r.category_id = par_cat
      THEN
        RESULT := r.date_begin;
      ELSE
        GOTO end_loop;
      END IF;
    END LOOP;
    <<end_loop>>
    RETURN(RESULT);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_ag_cat_date;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.10.2008 17:17:28
  -- Purpose : Для работ по савам Ткаченко
  FUNCTION temp_sav
  (
    p_policy_id  NUMBER
   ,p_agc        NUMBER
   ,p_t_lob_line NUMBER
   ,par_t        NUMBER
  ) RETURN VARCHAR2 IS
    RESULT    VARCHAR2(255);
    proc_name VARCHAR2(20) := 'temp_sav';
  BEGIN
  
    SELECT CASE
             WHEN par_t = 1 THEN
              to_char(comission_sum)
             WHEN par_t = 2 THEN
              to_char(sav)
             WHEN par_t = 3 THEN
              to_char(report_date, 'DD.MM.YYYY')
           END
      INTO RESULT
      FROM (SELECT arc.comission_sum
                  ,arc.sav
                  ,ar.report_date
                  ,av.ag_vedom_av_id
                  ,av.date_begin
              FROM agent_report       ar
                  ,agent_report_cont  arc
                  ,ag_vedom_av        av
                  ,p_policy_agent_com pac
                  ,t_product_line     tpl
             WHERE ar.agent_report_id = arc.agent_report_id
               AND arc.policy_id = p_policy_id
               AND ar.ag_contract_h_id = p_agc
               AND pac.t_product_line_id = tpl.id
               AND tpl.t_lob_line_id = p_t_lob_line
               AND ar.ag_vedom_av_id = av.ag_vedom_av_id
               AND pac.p_policy_agent_com_id = arc.p_policy_agent_com_id
             ORDER BY av.date_begin)
     WHERE rownum = 1;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END temp_sav;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.11.2008 13:33:28
  -- Purpose : Получает сумму денег за расчетный период для определения БСВ
  FUNCTION get_amount_for_bsv
  (
    par_ag_contract_header_id NUMBER
   ,par_prog_group            NUMBER
   ,par_expire_date           NUMBER
  ) RETURN NUMBER IS
    RESULT                  NUMBER;
    proc_name               VARCHAR2(20) := 'Get_amount_for_BSV';
    var_bsv_num             NUMBER;
    var_bsv_min_num         NUMBER;
    var_expire_date         DATE;
    var_ag_date_begin       DATE;
    var_sales_channel       VARCHAR2(20);
    var_func_id             NUMBER;
    var_curent_period_end   DATE;
    var_curent_period_begin DATE;
  BEGIN
  
    SELECT ach.date_begin
          ,ts.brief
      INTO var_ag_date_begin
          ,var_sales_channel
      FROM ag_contract_header ach
          ,t_sales_channel    ts
     WHERE ach.ag_contract_header_id = par_ag_contract_header_id
       AND ach.t_sales_channel_id = ts.id;
  
    --Выбираем функцию по которой считаемся
    CASE
      WHEN var_sales_channel = 'BANK' THEN
        var_func_id := 6406;
      WHEN var_sales_channel = 'BR' THEN
        var_func_id := 6467;
      ELSE
        var_func_id := -1;
    END CASE;
  
    --Достанем из этой функции примерный желаемый результат
    BEGIN
      SELECT bsv
            ,bsv_min
            ,bsv_min_date
        INTO var_bsv_num
            ,var_bsv_min_num
            ,var_expire_date
        FROM (SELECT bsv
                    ,dt
                    ,bsv_min
                    ,bsv_min_date
                FROM (SELECT criteria_5 bsv
                            ,to_date(criteria_6, 'YYYYMMDD') dt
                            ,MIN(criteria_5) keep(dense_rank FIRST ORDER BY to_date(criteria_6, 'YYYYMMDD')) over(PARTITION BY criteria_1) bsv_min
                            ,MIN(to_date(criteria_6, 'YYYYMMDD')) over(PARTITION BY criteria_1) bsv_min_date
                        FROM t_prod_coef
                       WHERE t_prod_coef_type_id = var_func_id
                         AND criteria_1 = par_ag_contract_header_id
                         AND criteria_2 = par_prog_group
                       ORDER BY to_date(criteria_6, 'YYYYMMDD'))
               WHERE dt >= to_date(par_expire_date, 'YYYYMMDD')
               ORDER BY 2
                       ,1)
       WHERE rownum = 1;
    EXCEPTION
      --Если ставки для такого агента нету.
      WHEN no_data_found THEN
        RETURN(-1);
    END;
    --Если для даной ставки БСВ не используется вернем сумму -1
    IF var_bsv_num = 0
    THEN
      RETURN(-1);
    END IF;
  
    --Если БСВ по договору начали расчитывать позже чем дата начала договора
    --то началом отсчета отчетного периода берем дату начала расчета по БСВ
    IF var_bsv_min_num <> 0
    THEN
      var_expire_date := var_ag_date_begin;
    END IF;
  
    --Поучим дату начала и окончания текущего отчетного периода
    --(Для БСВ отчетный период сичтается по 3 месяца)
    SELECT ADD_MONTHS(var_expire_date
                     ,FLOOR(FLOOR(MONTHS_BETWEEN(pkg_agent_rate.date_end, var_expire_date)) / 3) * 3)
          ,ADD_MONTHS(var_expire_date
                     ,(FLOOR(FLOOR(MONTHS_BETWEEN(pkg_agent_rate.date_end, var_expire_date)) / 3) * 3) - 3)
      INTO var_curent_period_end
          ,var_curent_period_begin
      FROM dual;
  
    --Получим сумму по проданным договорам за отчетный период
    SELECT SUM(CASE
                 WHEN doc.get_doc_status_brief(pp.policy_id, pkg_agent_rate.date_end) IN
                      ('BREAK', 'CANCEL') THEN
                  0
                 ELSE
                  dso.set_off_child_amount
               END) amount
      INTO RESULT
      FROM ag_contract_header  ach
          ,p_policy_agent      pa
          ,policy_agent_status pas
          ,p_policy            pp
          ,doc_doc             dd
          ,ac_payment          ap
          ,doc_set_off         dso
          ,ven_ac_payment      vap
     WHERE ach.ag_contract_header_id = par_ag_contract_header_id
       AND pa.ag_contract_header_id = ach.ag_contract_header_id
       AND pa.status_id = pas.policy_agent_status_id
       AND pp.pol_header_id = pa.policy_header_id
       AND dd.parent_id = pp.policy_id
       AND dd.child_id = ap.payment_id
       AND dso.parent_doc_id = ap.payment_id
       AND dso.child_doc_id = vap.payment_id
       AND nvl(pas.brief, 'CURRENT') = 'CURRENT'
       AND vap.reg_date BETWEEN var_curent_period_begin AND var_curent_period_end;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END get_amount_for_bsv;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.11.2008 11:13:01
  -- Purpose : Получает "Основную" программу по ДС (Для расчета БСВ)
  FUNCTION get_policy_main_prog
  (
    par_ag_contract_header_id NUMBER
   ,par_product_line          NUMBER
   ,par_policy_header         NUMBER
  ) RETURN NUMBER IS
    RESULT            NUMBER;
    proc_name         VARCHAR2(20) := 'Get_policy_main_prog';
    var_ag_date_begin DATE;
    var_sales_channel VARCHAR2(20);
    var_func_id       NUMBER;
  BEGIN
  
    SELECT ach.date_begin
          ,ts.brief
      INTO var_ag_date_begin
          ,var_sales_channel
      FROM ag_contract_header ach
          ,t_sales_channel    ts
     WHERE ach.ag_contract_header_id = par_ag_contract_header_id
       AND ach.t_sales_channel_id = ts.id;
  
    --Выбираем функцию по которой считаемся
    CASE
      WHEN var_sales_channel = 'BANK' THEN
        var_func_id := 6405;
      WHEN var_sales_channel = 'BR' THEN
        var_func_id := 6465;
      ELSE
        var_func_id := -1;
    END CASE;
  
    --Получим значение основной программы в этой функции
    FOR r IN (SELECT criteria_3 product_line
                FROM t_prod_coef
               WHERE t_prod_coef_type_id = var_func_id
                 AND criteria_1 = par_ag_contract_header_id
                 AND criteria_2 = par_product_line)
    LOOP
      --Если основная программа - "_не имеет значения" то это и вернем
      IF r.product_line = -1
      THEN
        RETURN(-1);
      END IF;
    
      --Проверим есть ли такая программа в проданном ДС
      BEGIN
        SELECT plo.product_line_id
          INTO RESULT
          FROM p_policy           pp
              ,as_asset           ass
              ,p_cover            pc
              ,t_prod_line_option plo
         WHERE pp.pol_header_id = par_policy_header
           AND pp.version_num = (SELECT MAX(p1.version_num)
                                   FROM p_policy           p1
                                       ,ins.document       d
                                       ,ins.doc_status_ref rf
                                  WHERE p1.pol_header_id = par_policy_header
                                    AND p1.start_date <= pkg_agent_rate.date_end
                                    AND p1.policy_id = d.document_id
                                    AND d.doc_status_ref_id = rf.doc_status_ref_id
                                    AND rf.brief != 'CANCEL')
           AND pp.policy_id = ass.p_policy_id
           AND ass.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = plo.id
           AND plo.product_line_id = r.product_line;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    
    END LOOP;
  
    IF RESULT IS NULL
    THEN
      RESULT := -1;
    END IF;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END get_policy_main_prog;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.11.2008 17:33:58
  -- Purpose : Получает дату первого не оплаченого Графика платежа
  -- par_ret_type - тип возвращаемой даты
  -- 1 - Дата первого не оплаченого Планграфика
  -- 2 - Дата последнего оплаченого Планграфика
  FUNCTION first_unpaid
  (
    par_pol_header_id NUMBER
   ,par_ret_type      NUMBER DEFAULT 1
   ,par_date          DATE DEFAULT SYSDATE
  ) RETURN DATE IS
  BEGIN
    RETURN pkg_payment.first_unpaid(par_pol_header_id, par_ret_type, par_date);
  END first_unpaid;

  FUNCTION paid_unpaid
  (
    par_pol_header_id NUMBER
   ,par_ret_type      NUMBER DEFAULT 1
   ,par_date          DATE DEFAULT SYSDATE
  ) RETURN DATE IS
  BEGIN
    RETURN pkg_payment.paid_unpaid(par_pol_header_id, par_ret_type, par_date);
  END paid_unpaid;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.11.2008 17:33:58
  -- Purpose : Получает последний статус БСО
  FUNCTION get_bso_status_brief
  (
    par_bso_id NUMBER
   ,par_date   DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    RESULT    VARCHAR2(50);
    proc_name VARCHAR2(30) := 'get_bso_status_brief';
  BEGIN
    SELECT brief
      INTO RESULT
      FROM (SELECT bht.brief
              FROM bso_hist      bh
                  ,bso_hist_type bht
             WHERE bh.hist_date < par_date
               AND bh.bso_id = par_bso_id
               AND bht.bso_hist_type_id = bh.hist_type_id
             ORDER BY bh.num DESC)
     WHERE rownum = 1;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_bso_status_brief;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 10.02.2009 13:15:03
  -- Purpose : Сторнирует проводку по oper_id
  -- Байтин А.
  -- 08.2014
  -- Отключена, т.к. вместо нее должна использоваться процедура из acc_new
  /*FUNCTION trans_storno
  (
    p_oper_id PLS_INTEGER
   ,p_date    DATE
  ) RETURN PLS_INTEGER IS
    proc_name VARCHAR2(20) := 'Trans_storno';
    --  v_trans TRANS%ROWTYPE;
    v_storno_oper_id  PLS_INTEGER;
    v_storno_trans_id PLS_INTEGER;
    v_doc_id          PLS_INTEGER;
    v_storno_date     DATE;
  BEGIN
    SELECT document_id
          ,nvl(p_date, doc.get_last_doc_status_date(document_id))
      INTO v_doc_id
          ,v_storno_date
      FROM oper
     WHERE oper_id = p_oper_id;
  
    FOR transes IN (SELECT t.* FROM trans t WHERE t.oper_id = p_oper_id)
    LOOP
      IF v_storno_oper_id IS NULL
      THEN
        SELECT sq_oper.nextval INTO v_storno_oper_id FROM dual;
      
        INSERT INTO oper
          (oper_id, oper_templ_id, document_id, reg_date, oper_date, doc_status_ref_id, NAME)
          SELECT v_storno_oper_id
                ,ot.oper_templ_id
                ,v_doc_id
                ,SYSDATE
                ,v_storno_date
                ,doc.get_last_doc_status_ref_id(v_doc_id)
                ,NAME
            FROM oper_templ ot
           WHERE ot.brief = 'Аннулирование';
      END IF;
      v_storno_trans_id := transes.trans_id;
      SELECT sq_trans.nextval
            ,-transes.trans_amount
            ,-transes.acc_amount
            ,-transes.trans_quantity
            ,0
            ,SYSDATE
            ,v_storno_oper_id
            ,v_storno_date
            ,'Сторно проводки: ' || v_storno_trans_id
            ,v_storno_trans_id
        INTO transes.trans_id
            ,transes.trans_amount
            ,transes.acc_amount
            ,transes.trans_quantity
            ,transes.is_closed
            ,transes.reg_date
            ,transes.oper_id
            ,transes.trans_date
            ,transes.note
            ,transes.storned_id
        FROM dual;
      INSERT INTO trans VALUES transes;
    END LOOP;
  
    RETURN(v_storno_oper_id);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END trans_storno;*/

  -- Author  : ILYA.SLEZIN
  -- Created : 11.02.2009
  -- Purpose : Вывести агентов, не продающих с момента par_date-60
  -- @param par_date - дата, от которой исчисляются эти 60 дней. По умолчанию - sysdate.
  PROCEDURE agent_ws(par_date DATE) IS
    /*CREATE TABLE t_agent_ws (
           num_AD          VARCHAR2(100),
           agent_fio       VARCHAR2(500),
           agency         varchar2(300),
           sale_channel   VARCHAR2(255),
           agent_status   VARCHAR2(255),
           date_begin_AD  DATE,
           last_sale_date DATE
           );
    DROP TABLE t_agent_ws;*/
    --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM t_agent_ws;
    --TRUNCATE t_agent_ws;
    --         execute immediate 'TRUNCATE TABLE t_AGENT_WS';
  
    INSERT INTO t_agent_ws
      (SELECT DISTINCT k.ad_num
                      ,k.agent_name
                      ,k.dep
                      ,k.sales_chnl
                      ,k.status_name
                      ,k.date_start
                      ,k.m_date
                      ,k.adl_num
                      ,k.lead_name
         FROM (SELECT dep.name AS dep
                     ,d.num ad_num
                     ,cc.name || ' ' || cc.first_name || ' ' || cc.middle_name AS agent_name
                     ,ah.date_begin date_start
                     ,ch.description AS sales_chnl
                     ,decode(doc.get_doc_status_brief(d.document_id, ds.start_date)
                            ,'BREAK'
                            ,doc.get_doc_status_name(d.document_id, par_date)
                            ,doc.get_doc_status_name(d.document_id, ds.start_date)) status_name
                     ,dl.num adl_num
                     ,cl.obj_name_orig lead_name
                     ,
                      
                      ag.m_date
                     ,par_date - ag.m_date AS days
                 FROM (SELECT MAX(ag.date_start) AS m_date
                             ,ag.ag_contract_header_id
                         FROM p_policy_agent ag
                        GROUP BY ag.ag_contract_header_id) ag
                 LEFT JOIN p_policy_agent ags
                   ON (ags.ag_contract_header_id = ag.ag_contract_header_id AND
                      ags.date_start = ag.m_date)
                 LEFT JOIN v_policy_version_journal pp
                   ON (ags.policy_header_id = pp.policy_header_id)
                 LEFT JOIN ven_ag_contract_header ah
                   ON (ags.ag_contract_header_id = ah.ag_contract_header_id)
                 JOIN document d
                   ON d.document_id = ah.ag_contract_header_id
                 JOIN doc_status ds
                   ON (ds.document_id = d.document_id AND
                      ds.start_date IN (SELECT MAX(dd.start_date)
                                           FROM doc_status dd
                                          WHERE dd.document_id = d.document_id))
                 LEFT JOIN contact cc
                   ON (cc.contact_id = ah.agent_id)
                 LEFT JOIN department dep
                   ON ah.agency_id = dep.department_id
                 LEFT JOIN policy_agent_status st
                   ON (ags.status_id = st.policy_agent_status_id)
                 LEFT JOIN t_sales_channel ch
                   ON (ch.id = pp.sales_channel_id)
                 LEFT JOIN ag_contract agc
                   ON (agc.ag_contract_id = ah.last_ver_id)
                 LEFT JOIN ag_category_agent cat
                   ON (cat.ag_category_agent_id = agc.category_id)
               
                 LEFT JOIN ag_contract agl
                   ON (agl.ag_contract_id = agc.contract_leader_id)
                 LEFT JOIN ag_contract_header hl
                   ON (hl.ag_contract_header_id = agl.contract_id)
                 LEFT JOIN document dl
                   ON (dl.document_id = hl.ag_contract_header_id)
                 LEFT JOIN contact cl
                   ON (cl.contact_id = hl.agent_id)
               
                WHERE pp.policy_id = pp.active_policy_id
                  AND pp.status_name NOT IN ('Отменен')
                  AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                  AND par_date - ag.m_date > 60
                  AND decode(doc.get_doc_status_brief(d.document_id, ds.start_date)
                            ,'BREAK'
                            ,doc.get_doc_status_name(d.document_id, par_date)
                            ,doc.get_doc_status_name(d.document_id, ds.start_date)) NOT IN
                      ('Расторгнут'
                      ,'Завершен'
                      ,'Отменен'
                      ,'Приостановлен'
                      ,'Закрыт')
                  AND ch.description = 'Агентский'
                  AND cat.category_name = 'Агент'
               UNION
               SELECT dep.name
                     ,d.num
                     ,c.name || ' ' || c.first_name || ' ' || c.middle_name
                     ,h.date_begin
                     ,ch.description
                     ,doc.get_doc_status_name(d.document_id, ds.start_date) status_name
                     ,dl.num
                     ,cl.obj_name_orig
                     ,
                      
                      NULL
                     ,NULL
                 FROM ag_contract_header h
                 LEFT JOIN document d
                   ON (d.document_id = h.ag_contract_header_id)
                 JOIN doc_status ds
                   ON (ds.document_id = d.document_id AND
                      ds.start_date IN (SELECT MAX(dd.start_date)
                                           FROM doc_status dd
                                          WHERE dd.document_id = d.document_id))
                 LEFT JOIN contact c
                   ON (c.contact_id = h.agent_id)
                 LEFT JOIN department dep
                   ON h.agency_id = dep.department_id
                 LEFT JOIN t_sales_channel ch
                   ON (ch.id = h.t_sales_channel_id)
                 LEFT JOIN ag_contract agc
                   ON (agc.ag_contract_id = h.last_ver_id)
                 LEFT JOIN ag_category_agent cat
                   ON (cat.ag_category_agent_id = agc.category_id)
               
                 LEFT JOIN ag_contract agl
                   ON (agl.ag_contract_id = agc.contract_leader_id)
                 LEFT JOIN ag_contract_header hl
                   ON (hl.ag_contract_header_id = agl.contract_id)
                 LEFT JOIN document dl
                   ON (dl.document_id = hl.ag_contract_header_id)
                 LEFT JOIN contact cl
                   ON (cl.contact_id = hl.agent_id)
                WHERE h.ag_contract_header_id NOT IN
                      (SELECT pa.ag_contract_header_id FROM p_policy_agent pa)
                  AND doc.get_doc_status_name(d.document_id, ds.start_date) NOT IN
                      ('Расторгнут'
                      ,'Завершен'
                      ,'Отменен'
                      ,'Приостановлен'
                      ,'Закрыт'
                      ,'Готовится к расторжению')
                  AND ch.description = 'Агентский'
                  AND cat.category_name = 'Агент'
               
               ) k);
    COMMIT;
  
  END agent_ws;
  --Брутто-взнос для Страховой депозит
  FUNCTION brutto_ins_dep(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'brutto_ins_dep';
    RESULT    NUMBER;
    v_variant NUMBER;
    v_tpl_id  NUMBER;
    v_period  NUMBER;
  BEGIN
    RESULT := NULL;
    SELECT pcc.val
          ,tplo2.product_line_id
          ,ROUND(MONTHS_BETWEEN(pc.end_date, pc.start_date) / 12)
      INTO v_variant
          ,v_tpl_id
          ,v_period
      FROM p_cover             pc
          ,as_asset            ass
          ,p_cover             pc_all
          ,t_prod_line_option  tplo
          ,t_prod_line_option  tplo2
          ,t_product_line      tpl
          ,t_product_line_type tplt
          ,p_cover_coef        pcc
          ,t_prod_coef_type    tpct
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = ass.as_asset_id
       AND ass.as_asset_id = pc_all.as_asset_id
       AND pc_all.t_prod_line_option_id = tplo.id
       AND pc.t_prod_line_option_id = tplo2.id
       AND tplo.product_line_id = tpl.id
       AND tpl.product_line_type_id = tplt.product_line_type_id
       AND tplt.brief = 'RECOMMENDED'
       AND pcc.p_cover_id = pc_all.p_cover_id
       AND tpct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
       AND tpct.brief IN ('Option_num', 'Part_count');
    IF v_variant BETWEEN 1 AND 120
    THEN
      IF v_period = 3
         AND v_tpl_id = 79336
      THEN
        RESULT := 24897 * v_variant;
      ELSIF v_period = 3
            AND v_tpl_id = 79323
      THEN
        RESULT := 48 * v_variant;
      ELSIF v_period = 3
            AND v_tpl_id = 79325
      THEN
        RESULT := 55 * v_variant;
      ELSIF v_period = 5
            AND v_tpl_id = 79336
      THEN
        RESULT := 24720 * v_variant;
      ELSIF v_period = 5
            AND v_tpl_id = 79323
      THEN
        RESULT := 152 * v_variant;
      ELSIF v_period = 5
            AND v_tpl_id = 79325
      THEN
        RESULT := 128 * v_variant;
      END IF;
    END IF;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END brutto_ins_dep;
  --СС для Страховой депозит
  FUNCTION ins_amount_ins_dep(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'ins_amount_ins_dep';
    RESULT    NUMBER;
    v_variant NUMBER;
    v_tpl_id  NUMBER;
    v_period  NUMBER;
  BEGIN
    RESULT := NULL;
    SELECT pcc.val
          ,tplo2.product_line_id
          ,ROUND(MONTHS_BETWEEN(pc.end_date, pc.start_date) / 12)
      INTO v_variant
          ,v_tpl_id
          ,v_period
      FROM p_cover             pc
          ,as_asset            ass
          ,p_cover             pc_all
          ,t_prod_line_option  tplo
          ,t_prod_line_option  tplo2
          ,t_product_line      tpl
          ,t_product_line_type tplt
          ,p_cover_coef        pcc
          ,t_prod_coef_type    tpct
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = ass.as_asset_id
       AND ass.as_asset_id = pc_all.as_asset_id
       AND pc_all.t_prod_line_option_id = tplo.id
       AND pc.t_prod_line_option_id = tplo2.id
       AND tplo.product_line_id = tpl.id
       AND tpl.product_line_type_id = tplt.product_line_type_id
       AND tplt.brief = 'RECOMMENDED'
       AND pcc.p_cover_id = pc_all.p_cover_id
       AND tpct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
       AND tpct.brief IN ('Option_num', 'Part_count');
    IF v_variant BETWEEN 1 AND 120
    THEN
      IF v_period = 3
         AND v_tpl_id = 79336
      THEN
        RESULT := 31750 * v_variant;
      ELSIF v_period = 3
            AND v_tpl_id = 79323
      THEN
        RESULT := 50000 * v_variant;
      ELSIF v_period = 3
            AND v_tpl_id = 79325
      THEN
        RESULT := 50000 * v_variant;
      ELSIF v_period = 5
            AND v_tpl_id = 79336
      THEN
        RESULT := 36250 * v_variant;
      ELSIF v_period = 5
            AND v_tpl_id = 79323
      THEN
        RESULT := 75000 * v_variant;
      ELSIF v_period = 5
            AND v_tpl_id = 79325
      THEN
        RESULT := 75000 * v_variant;
      END IF;
    END IF;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END ins_amount_ins_dep;

  FUNCTION standart_ins_amount(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                         ,par_subject => 'STANDART_ins_amount'
                                         ,par_text    => 'Процедура STANDART_ins_amount была запущена.' ||
                                                         chr(10) || 'Call stack:' || chr(10) ||
                                                         dbms_utility.format_call_stack() || chr(10));
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    RETURN pkg_ins_amount_calc.standart_ins_amount(p_p_cover_id => p_p_cover_id);
  
  END standart_ins_amount;

  FUNCTION brutto_sf_avcr(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'brutto_sf_AVCR';
    RESULT    NUMBER;
    v_variant NUMBER;
  BEGIN
    RESULT := 0;
    SELECT pcc.val
      INTO v_variant
      FROM p_cover             pc
          ,as_asset            ass
          ,p_cover             pc_all
          ,t_prod_line_option  tplo
          ,t_prod_line_option  tplo2
          ,t_product_line      tpl
          ,t_product_line_type tplt
          ,p_cover_coef        pcc
          ,t_prod_coef_type    tpct
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = ass.as_asset_id
       AND ass.as_asset_id = pc_all.as_asset_id
       AND pc_all.t_prod_line_option_id = tplo.id
       AND pc.t_prod_line_option_id = tplo2.id
       AND tplo.product_line_id = tpl.id
       AND tpl.product_line_type_id = tplt.product_line_type_id
       AND tplt.brief = 'RECOMMENDED'
       AND pcc.p_cover_id = pc_all.p_cover_id
       AND tpct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
       AND tpct.brief IN ('Option_num', 'Part_count');
    IF v_variant BETWEEN 1 AND 500
    THEN
      RESULT := 6000 * v_variant;
    END IF;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END brutto_sf_avcr;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.11.2009 13:12:02
  -- Purpose : Вкачивает коды убытков
  PROCEDURE load_damage_code
  (
    p_parent_id  PLS_INTEGER
   ,p_session_id PLS_INTEGER
  ) IS
    proc_name VARCHAR2(20) := 'load_damage_code';
    TYPE t_parent IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  
    v_parent t_parent;
    --v_lvl    PLS_INTEGER := 0;
    v_peril PLS_INTEGER;
    v_sq    PLS_INTEGER := 100;
  BEGIN
  
    SELECT peril INTO v_peril FROM t_damage_code WHERE id = p_parent_id;
  
    v_parent(1) := p_parent_id;
  
    FOR r IN (SELECT * FROM damage_code_load_tmp t WHERE t.session_id = p_session_id ORDER BY t.num)
    LOOP
    
      SELECT sq_t_damage_code.nextval INTO v_sq FROM dual;
    
      -- if v_lvl <> r.lvl then
      v_parent(r.lvl + 1) := v_sq;
      -- v_lvl := r.lvl;
      --end if;
    
      --dbms_output.put_line(v_sq||'  '||r.code||r.claim||r.perc||'    '||v_parent(r.lvl));
    
      INSERT INTO ven_t_damage_code
        (id
        ,parent_id
        ,code
        ,description
        ,limit_val
        ,comments
        ,is_insurance
        ,is_refundable
        ,peril
        ,t_prod_coef_type_id)
      VALUES
        (v_sq
        ,v_parent(r.lvl)
        ,r.code
        ,r.claim
        ,nvl(r.perc, 0)
        ,r.note
        ,1
        ,1
        ,v_peril
        ,(SELECT tt.t_prod_coef_type_id FROM t_prod_coef_type tt WHERE tt.name = r.calc_func));
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END load_damage_code;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 23.12.2009 11:16:04
  -- Purpose : Получает первую "Активную" версию ДС
  FUNCTION get_first_a_policy(par_p_pol_header PLS_INTEGER) RETURN NUMBER IS
    v_policy_id NUMBER;
    proc_name   VARCHAR2(20) := 'get_first_a_policy';
  BEGIN
    SELECT pp_v.policy_id
      INTO v_policy_id
      FROM p_policy pp_v
     WHERE 1 = 1
       AND pp_v.pol_header_id = par_p_pol_header
       AND pp_v.version_num =
           (SELECT MAX(pp_v2.version_num)
              FROM p_policy           pp_v2
                  ,ins.document       d
                  ,ins.doc_status_ref rf
             WHERE pp_v2.pol_header_id = par_p_pol_header
               AND pp_v2.policy_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND rf.brief NOT IN ('CANCEL', 'UNDERWRITING')
                  --AND doc.get_doc_status_brief(pp_v2.policy_id) <> 'UNDERWRITING'
               AND pp_v2.start_date =
                   (SELECT MIN(pp_v3.start_date)
                      FROM p_policy pp_v3
                     WHERE pp_v3.pol_header_id = par_p_pol_header));
    RETURN(v_policy_id);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || chr(10));
  END get_first_a_policy;

  FUNCTION get_grace_date_nonpayed
  (
    par_p_pol_header   NUMBER
   ,par_p_decline_date DATE
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_payment.get_grace_date_nonpayed(par_p_pol_header, par_p_decline_date);
  END get_grace_date_nonpayed;

  FUNCTION damage_decline_reason
  (
    par_p_cover_id NUMBER
   ,par_c_claim_id NUMBER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_claim.damage_decline_reason(par_p_cover_id, par_c_claim_id);
  END damage_decline_reason;

  FUNCTION get_due_date_payed
  (
    par_p_pol_header   NUMBER
   ,par_p_decline_date DATE
   ,p_type             NUMBER DEFAULT 1
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_payment.get_due_date_payed(par_p_pol_header, par_p_decline_date, p_type);
  END get_due_date_payed;

  PROCEDURE for_sms_report_payment
  (
    p_date_from DATE
   ,p_date_to   DATE
  ) IS
    func_name CONSTANT VARCHAR2(2000) := 'for_sms_report_payment';
  BEGIN
  
    DELETE FROM tmp$_sms_report_paym;
    DELETE FROM tmp$_sms_report_pol;
  
    INSERT INTO tmp$_sms_report_pol
      (SELECT cpol.obj_name_orig contact_name
             ,nvl(cpol.name, '') || ' ' || nvl(substr(cpol.first_name, 1, 1) || '.', '') ||
              nvl(substr(cpol.middle_name, 1, 1) || '.', '') init_name
             ,nvl(pp.pol_ser, '-') pol_ser
             ,nvl(pp.pol_num, '-') pol_num
             ,ph.ids
             ,pt.description period
             ,doc.get_doc_status_name(pkg_policy.get_last_version(pp.pol_header_id)) pol_status
             ,dep.name department
             ,(SELECT tel.telephone_number tel
                 FROM t_telephone_type     tt
                     ,cn_contact_telephone tel
                WHERE tel.contact_id = cpol.contact_id
                  AND tt.id = tel.telephone_type
                  AND tt.description IN ('Мобильный')
                  AND length(tel.telephone_number) > 3
                  AND tel.control = 0
                  AND tel.status = 1
                  AND rownum = 1) tel
             ,(SELECT tel.telephone_number tel
                 FROM t_telephone_type     tt
                     ,cn_contact_telephone tel
                WHERE tel.contact_id = cpol.contact_id
                  AND tt.id = tel.telephone_type
                  AND tt.description IN ('Рабочий телефон')
                  AND length(tel.telephone_number) > 3
                  AND tel.control = 0
                  AND tel.status = 1
                  AND rownum = 1) tel_1
             ,(SELECT tel.telephone_number tel
                 FROM t_telephone_type     tt
                     ,cn_contact_telephone tel
                WHERE tel.contact_id = cpol.contact_id
                  AND tt.id = tel.telephone_type
                  AND tt.description IN ('Домашний телефон')
                  AND length(tel.telephone_number) > 3
                  AND tel.control = 0
                  AND tel.status = 1
                  AND rownum = 1) tel_2
             ,ph.policy_header_id
             ,pp.policy_id
         FROM p_pol_header        ph
             ,ins.document        dph
             ,ins.doc_status_ref  rf
             ,fund                fh
             ,ven_p_policy        pp
             ,t_product           prod
             ,department          dep
             ,t_payment_terms     pt
             ,t_contact_type      tc
             ,t_contact_pol_role  polr
             ,p_policy_contact    pcnt
             ,contact             cpol
             ,t_collection_method colm
             ,t_sales_channel     ch
             ,ins.ven_p_policy    pp_av -- активная версия
             ,ins.doc_status_ref  dsr_av -- статус активной версии
       
        WHERE 1 = 1
          AND ph.policy_header_id = pp.pol_header_id
          AND fh.fund_id = ph.fund_id
          AND ph.product_id = prod.product_id
          AND pt.id = pp.payment_term_id
             /*заявка №17963*/
          AND ((pt.description NOT IN ('Единовременно') AND prod.brief NOT IN ('APG', 'OPS_Plus')) OR
              (prod.brief IN ('APG', 'OPS_Plus')))
             /**/
          AND dep.department_id(+) = ph.agency_id
          AND pp.collection_method_id = colm.id
          AND ph.sales_channel_id = ch.id
          AND ((ch.description IN ('Банковский') AND prod.brief = 'InvestorALFA') OR
              (ch.description IN ('SAS'
                                  ,'SAS 2'
                                  ,'DSF'
                                  ,'Брокерский'
                                  ,'Брокерский без скидки'
                                  ,'RLA') AND prod.brief != 'InvestorALFA') OR
              (ch.description IN ('Банковский') AND pt.description NOT IN ('Единовременно')))
          AND polr.brief = 'Страхователь'
          AND pcnt.policy_id = pp.policy_id
          AND pcnt.contact_policy_role_id = polr.id
          AND cpol.contact_id = pcnt.contact_id
             /*заявка №178915*/
          AND dph.document_id = ph.last_ver_id
          AND dph.doc_status_ref_id = rf.doc_status_ref_id
             
             --Заявка 283064: Изменения в Отчетах смс
             --Гаргонов Д.А.
             --Исключение статусов для последней версии.
             /*AND rf.brief NOT IN ('READY_TO_CANCEL'
             ,'STOPED'
             ,'CANCEL'
             ,'STOP'
             ,'BREAK'
             ,'QUIT_DECL'
             ,'TO_QUIT'
             ,'TO_QUIT_CHECK_READY'
             ,'TO_QUIT_CHECKED'
             ,'QUIT_REQ_QUERY'
             ,'QUIT_REQ_GET'
             ,'QUIT_TO_PAY'
             ,'QUIT')*/
          AND ph.policy_id = pp_av.policy_id
          AND pp_av.doc_status_ref_id = dsr_av.doc_status_ref_id
          AND dsr_av.brief NOT IN ('RECOVER_DENY'
                                  ,'RECOVER'
                                  ,'READY_TO_CANCEL'
                                  ,'STOPED'
                                  ,'CANCEL'
                                  ,'STOP'
                                  ,'BREAK'
                                  ,'QUIT_DECL'
                                  ,'TO_QUIT'
                                  ,'TO_QUIT_CHECK_READY'
                                  ,'TO_QUIT_CHECKED'
                                  ,'QUIT_REQ_QUERY'
                                  ,'QUIT_REQ_GET'
                                  ,'QUIT_TO_PAY'
                                  ,'QUIT'
                                  ,'RECOVER'
                                  ,'RECOVER_DENY')
             
             /*AND doc.get_doc_status_brief(pkg_policy.get_last_version(pp.pol_header_id)) NOT IN ('READY_TO_CANCEL','STOPED','CANCEL','STOP',\*'INDEXATING',*\'BREAK','QUIT_DECL','TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY','QUIT')*/
             /**/
          AND tc.id = cpol.contact_type_id
             /*заявка №178915*/
             /*and prod.brief in ('Baby_LA','Baby_LA2','Platinum_LA2','ACC_MLN','ACC_5000','RP4','RP-9','ERZ','Zabota','END','ACC','ACC_EXP',
             'ACC_EXP_NEW','ACC_EXP_NEW2','APG','CHI','Family_Dep','Fof_Prot','OPS_Plus','OPS_Plus_2','OPS_Plus_New','PEPR','TERM')*/
          AND prod.brief != 'GN'
             /**/
             /*заявка №17963*/
             /*and NVL(dep.name,'X') not in ('Екатеринбург','Екатеринбург Подразделение','Екатеринбург Подразделение 1','Екатеринбург Подразделение 2','Екатеринбург Подразделение 3')*/
             /**/
             /*заявка №178915*/
          AND EXISTS (SELECT NULL
                 FROM ins.cn_contact_telephone tel
                     ,ins.t_telephone_type     tt
                WHERE tel.contact_id = cpol.contact_id
                  AND tt.id = tel.telephone_type
                  AND tt.description = 'Мобильный'
                  AND tel.status = 1
                  AND tel.control = 0
                  AND tel.telephone_number IS NOT NULL)
             /**/
          AND NOT EXISTS
        (SELECT ch.p_policy_id FROM ven_c_claim_header ch WHERE ch.p_policy_id = pp.policy_id));
  
    INSERT INTO tmp$_sms_report_paym
      (SELECT DISTINCT pri.payment_register_item_id
                      ,TRIM(pri.payer_fio) payer_fio
                      ,
                       /*pri.PAYMENT_SUM,*/dso.set_off_amount   payment_sum
                      ,pri.payment_currency
                      ,acp_pp.due_date
                      ,pri.recognize_data   reg_date
                      ,
                       --acp_pp.reg_date,
                       --Данные по распознаным ЭР
                       (SELECT cont.obj_name_orig insurer_name
                          FROM p_policy_contact   pc
                              ,contact            cont
                              ,t_contact_pol_role cpr
                         WHERE pc.policy_id = coalesce(pp1.policy_id, pp2.policy_id)
                           AND cont.contact_id = pc.contact_id
                           AND pc.contact_policy_role_id = cpr.id
                           AND cpr.brief = 'Страхователь') insurer_name
                      ,coalesce(pp1.pol_header_id, pp2.pol_header_id) pol_header_id
                      ,coalesce(pp1.policy_id, pp2.policy_id) policy_id
                      ,coalesce(pp1.pol_ser, pp2.pol_ser) num_ser
                      ,coalesce(pp1.pol_num, pp2.pol_num) b_pol_num
                      ,coalesce(ph1.ids, ph2.ids) num_ids
       
         FROM payment_register_item pri
             ,ven_ac_payment acp_pp
             ,doc_templ dt
             ,t_collection_method cm
             ,doc_set_off dso
             ,(SELECT *
                 FROM ven_ac_payment     acp_epg
                     ,ins.document       dac
                     ,ins.doc_status_ref rfac
                WHERE acp_epg.doc_templ_id = 4
                  AND acp_epg.payment_id = dac.document_id
                  AND dac.doc_status_ref_id = rfac.doc_status_ref_id
                  AND rfac.brief != 'ANNULATED') epg1
             ,doc_doc dd1
             ,p_policy pp1
             ,p_pol_header ph1
             ,(SELECT * FROM ven_ac_payment acp_a7 WHERE acp_a7.doc_templ_id IN (6432, 6533)) a7_copy
             ,doc_doc dd2_1
             ,doc_set_off dso2
             ,(SELECT *
                 FROM ven_ac_payment     epg_2
                     ,ins.document       da
                     ,ins.doc_status_ref rf
                WHERE epg_2.payment_id = da.document_id
                  AND da.doc_status_ref_id = rf.doc_status_ref_id
                  AND rf.brief != 'ANNULATED') epg2
             ,doc_doc dd2
             ,p_policy pp2
             ,p_pol_header ph2
        WHERE pri.ac_payment_id = acp_pp.payment_id
          AND dt.doc_templ_id = acp_pp.doc_templ_id
          AND cm.id = acp_pp.collection_metod_id
          AND pri.payment_register_item_id = dso.pay_registry_item(+)
             --Ветка когда реестр разнесен с ПП на ЭПГ
          AND dso.parent_doc_id = epg1.payment_id(+)
          AND epg1.payment_id = dd1.child_id(+)
          AND dd1.parent_id = pp1.policy_id(+)
          AND pp1.pol_header_id = ph1.policy_header_id(+)
             --Ветка когда реестр разнесен с ПП на копию А7/ПД4
          AND dso.parent_doc_id = a7_copy.payment_id(+)
          AND a7_copy.payment_id = dd2_1.child_id(+)
          AND dd2_1.parent_id = dso2.child_doc_id(+)
          AND dso2.parent_doc_id = epg2.payment_id(+)
          AND epg2.payment_id = dd2.child_id(+)
          AND dd2.parent_id = pp2.policy_id(+)
          AND pp2.pol_header_id = ph2.policy_header_id(+)
             /*Заявка №178915*/
             /*AND pri.payer_fio NOT IN 'Contact'
             AND UPPER(trim(pri.payer_fio)) NOT IN (SELECT UPPER(c.name)
                                                    FROM ven_contact c,
                                                         t_contact_type tp
                                                   WHERE c.contact_type_id = tp.id
                                                     AND tp.description in ('Коммерческий банк','неизвестно','Закрытое акционерное общество')
                                                     AND UPPER(trim(pri.payer_fio)) = UPPER(c.name))*/
             /**/
             --AND acp_pp.due_date between to_date(p_date_from) and to_date(p_date_to)
             /*Заявка №130045*/
          AND pri.recognize_data BETWEEN to_date(p_date_from) AND to_date(p_date_to)+INTERVAL '1439:59' MINUTE TO SECOND
       /*(SELECT r.param_value
       FROM ins_dwh.rep_param r
       WHERE r.rep_name = 'sms_payment'
         AND r.param_name = 'date_from') and
        (SELECT r.param_value
       FROM ins_dwh.rep_param r
       WHERE r.rep_name = 'sms_payment'
         AND r.param_name = 'date_to')*/
       );
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || func_name || chr(25));
    
  END for_sms_report_payment;

  FUNCTION create_bso_history
  (
    par_bso_id    NUMBER
   ,par_policy_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_bso.create_bso_history(par_bso_id, par_policy_id);
  END;

  /*
    Байтин А.
    Процедура для сохранения изменений.
    Используется при некоторых переводах статусов
  
    Параметр указан формально и не используется
  */
  PROCEDURE commit_it(par_doc_id NUMBER) IS
  BEGIN
    COMMIT;
  END commit_it;

END pkg_renlife_utils; 
/
