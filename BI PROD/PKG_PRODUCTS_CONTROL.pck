CREATE OR REPLACE PACKAGE pkg_products_control IS

  -- Author  : Marchuk A.
  -- Created : 05.09.2007
  -- Purpose : Утилиты для контроля продукта в контексте бизнес процессов

  PROCEDURE policy_control
  (
    p_p_policy_id             p_policy.policy_id%TYPE
   ,par_is_underwriting_check t_product_control.is_underwriting_check%TYPE DEFAULT NULL
  );

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_control_inc_underwr(par_policy_id p_policy.policy_id%TYPE);

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    НЕ установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_control_exc_underwr(par_policy_id p_policy.policy_id%TYPE);

  PROCEDURE is_express(par_policy_id NUMBER);
  PROCEDURE exist_day_of_charge_off(par_policy_id NUMBER);

  PROCEDURE back_from_revision(par_policy_id NUMBER);
  PROCEDURE permit_new_current(par_policy_id NUMBER);
  PROCEDURE payment_setoff_not_payed(par_policy_id NUMBER);
  PROCEDURE ins_sum_rec_vs_opt(par_policy_id NUMBER);
  PROCEDURE undrw_check(par_policy_id NUMBER);
  PROCEDURE ins_amount_limit_control(par_p_policy_id NUMBER);
  PROCEDURE limit_agregation(par_policy_id NUMBER);
  PROCEDURE check_investor(par_policy_id NUMBER);
  PROCEDURE check_limit_investor(par_policy_id NUMBER);
  /* Проверка минимальной премии по продуктам INVESTOR_LUMP
  * На данный момент указывается на переходе статусов
  * @param par_policy_id - ИД версии ДС
  */
  PROCEDURE check_limit_investor_lump(par_policy_id NUMBER);
  -- ishch (
  PROCEDURE work_group(par_policy_id NUMBER);
  PROCEDURE benefic(par_policy_id NUMBER);
  /* Проверка на стандартность/нестандартность по хобби
  * Заявка №192041
  * @autor Чирков В. Ю.
  * @param par_policy_id - версия полиса ДС
  */
  PROCEDURE check_hobby(par_policy_id NUMBER);
  -- ishch )
  PROCEDURE limit_agregation_for_region(par_policy_id NUMBER);
  PROCEDURE is_autoprolong(par_policy_id NUMBER);
  PROCEDURE update_contact_payment(par_document_id NUMBER);
  PROCEDURE check_use_in_ad(par_document_id NUMBER);
  PROCEDURE check_admcost(par_policy_id NUMBER);
  PROCEDURE check_investorplus(par_policy_id NUMBER);

  /*
    Байтин А.
    Проверки по программе забота
  */
  PROCEDURE check_zabota_post(par_policy_id NUMBER);

  /* Процедура осуществляет проверку для продуктов Локо банк при переходе версии ДС <Проект> -> <Новый>
  * @autor Чирков В.Ю.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_cr99(par_policy_id NUMBER);

  /* Процедура осуществляет проверку для продуктов Защита 163/164 при переходе версии ДС <Проект> -> <Новый>
  * @autor Капля П.С.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_acc163_acc64(par_policy_id NUMBER);

  /* Процедура осуществляет проверку для продуктов:
  * <Приоритет Инвест (единовременный) Сбербанк>
  * <Приоритет Инвест (регулярный) Сбербанк>
  * при переходе версии ДС <Проект> -> <Новый>
  * @autor Чирков В.Ю.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_priority_invest(par_policy_id NUMBER);

  /* Процедура выполняет проверку продукта при
  *  переходе статусов Активный - Напечатан.
  * Если Продукт - <Защита 164>, переход невозможен.
  * @autor Изместьев Д.И.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_acc164_status(par_policy_id NUMBER);

  /*Функциоя контроля состава покрытий для продукта Защита Экспресс
  Капля П.
  25.06.2013
  */
  FUNCTION check_acc167_programs(par_policy_id NUMBER) RETURN NUMBER;

  /*
  Капля П.
  Функции контроля состава покрытий и возраста застрахованного для продукта Защита Экспресс Детский
  23.07.2013
  */
  FUNCTION check_acc168_programs(par_policy_id NUMBER) RETURN NUMBER;
  FUNCTION check_acc168_assured_age(par_policy_id NUMBER) RETURN NUMBER;

  /**
  Проверка новых ПУ при выборе анкологии
  */
  FUNCTION check_oncology(par_policy_id NUMBER) RETURN NUMBER;
  PROCEDURE check_198_blood_pressure(par_policy_id NUMBER);

  /**
  Капля П.
  19.09.2013
  Проверка для продуктов ACC172/ACC173
  Госпитализация НС без Хирургии НС, Госпитализация НСиБ без Хирургия НСиБ не может быть.
  */
  FUNCTION check_acc_172173_hosp_surge(par_policy_id NUMBER) RETURN NUMBER;

  /** Процедура осуществляет 'Контроль льготного периода' на переходе статуса ДС
  *  @autor - Чирков
  *  @param par_p_policy_id - Версия ДС
  */
  PROCEDURE privilege_period_control(par_p_policy_id NUMBER);

  /**
  Проверка возратных ограничений для продуктов серии Уверенный старт
  */
  FUNCTION strong_start_age_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;
  /* Контроль величины базовой суммы по продуктам серии Уверенный старт */
  FUNCTION strong_start_check_base_sum(par_policy_id NUMBER) RETURN NUMBER;

  /*
  Капля П.
  Функция контроля суммарной премии по инвестиционным программам продукта INEVSTOR_LUMP_ALPHA
  */
  FUNCTION investor_lump_alpha_premium(par_policy_id NUMBER) RETURN NUMBER;

  /*
    Капля П.
    Контроль по продукту.
    Проверка ПУ для Гармонии Жизни_2, Дети_2, Будущее_2, Семья_2
  */
  FUNCTION check_life_policy_form(par_policy_id NUMBER) RETURN NUMBER;

  /*
    Капля П.
    Контроль возраста и числа застрахованных в продукте серии "Семейная защита"
  */
  FUNCTION family_protection_age_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  /*
    Контроль годовой премии по договорам Platinum Life
    Преимя должна быть кратна 25000 при ежегодной форме оплаты и 2250 при ежемесячной форме оплаты
  */
  FUNCTION platinum_life_premium_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  /**
  * Контроль дублирования ID контакта при заведении договора на последующих застрахованных 
  * @author Мизинов Г.В.
  * @param par_policy_id       ИД версии договора страхования
  */
  FUNCTION check_assured_duplicates(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  -- Процедура проверки срока действия ДС для ренкап.
  -- Срок действия ДС должен быть между 5.5 и 60.5 мес.
  -- 363797: Перевод статуса договоров
  -- Гаргонов Д. А.

  FUNCTION check_policy_period_rencap(par_policy_id ins.p_policy.policy_id%TYPE) RETURN NUMBER;

  -- Контроль количества/возраста застрахованных
  -- для продуктов Уверенный старт 2014
  -- Доброхотова И., ноябрь, 2014
  -- 374307 FW настройка продукта Уверенный старт
  FUNCTION strong_start_new_age_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  /**
  * Проверку на наличие более одного ДС со страховым продуктом типа  «ОПС+ (New)», «Линия защиты», «Защита экспресс» 
  * или «Защита экспресс детский» на один контакт (застрахованное лицо)
  *
  * Текст ошибки и сама ошибка формируется в теле проверки
  * @author Капля П.
  * @param par_policy_id - ИД версии договора страхования
  * @return - результат проверки
  */
  FUNCTION check_assured_has_policies(par_policy_id NUMBER) RETURN NUMBER;

  -- Контроль наличия программ Медицины без границ
  -- (программы МБГ должны либо быть обе, либо их не быть вообще)   
  -- 378726: Заявка на настройку продукта "Platinum Life"
  -- Доброхотова И., декабрь, 2014
  FUNCTION platinum_life_mbg_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  -- Контроль обязательно подключения основных и обязательных программ 
  -- с учетом проверок на возможность подключения и контроля по покрытию
  -- 389610: Ошибки в b2b Брокера по программе "Platinum Life 2"
  -- Доброхотова И., январь, 2015   
  FUNCTION check_include_program(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  -- Контроль наличия программ Достояния
  -- 384116 Достояние_ГПБ
  -- Доброхотова И., январь, 2015
  FUNCTION dostoyanie_program_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER;

  -- Период страхования должен быть кратен году
  -- 373858 Дил банк настройка продукта 
  -- Доброхотова И., ноябрь, 2014  
  FUNCTION check_policy_period_year(par_policy_id NUMBER) RETURN NUMBER;

  /**
  * Контроль величины базовой суммы для продукта Семейный депозит (Family_Dep_2014);
  * В случае ошибки вызывает ошибку контроля по продукту
  * @author Капля п.
  * @param par_base_sum - Базовая сумма по договору
  * @return 1 в случае успеха
  */
  FUNCTION family_dep_basesum_control(par_base_sum NUMBER) RETURN NUMBER;
END pkg_products_control;
/
CREATE OR REPLACE PACKAGE BODY pkg_products_control IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'PKG_PRODUCTS_CONTROL';

  -- Author  : Marchuk A.
  -- Created : 05.09.2007
  -- Purpose : Утилиты для контроля продукта в контексте бизнес процессов

  /*
   * Проверка договора на соответствие правилам продукта
   * @author Marchuk A.
   * @param p_p_policy_id       ИД версии договора страхования
  */

  ex_product_control_exception EXCEPTION;
  gv_error_text VARCHAR2(2000);

  PROCEDURE raise_product_control_ex(par_error_text VARCHAR2) IS
  BEGIN
    gv_error_text := par_error_text;
    RAISE ex_product_control_exception;
  END raise_product_control_ex;

  PROCEDURE policy_control
  (
    p_p_policy_id             p_policy.policy_id%TYPE
   ,par_is_underwriting_check t_product_control.is_underwriting_check%TYPE DEFAULT NULL
  ) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'POLICY_CONTROL';
  
    /* Байтин А.
       Переписал запрос, чтобы быстрее работало на групповых
    */
    /*CURSOR c_control_func IS
     SELECT DISTINCT control_func_id
                    ,ct.name
                    ,pc.message
       FROM VEN_T_PROD_COEF_TYPE CT
           ,T_PRODUCT_CONTROL pc
           ,(SELECT pv.t_product_version_id
               FROM T_PRODUCT_VERSION  pv
                   ,T_PRODUCT_VER_LOB  pvl
                   ,T_PRODUCT_LINE     pl
                   ,T_PROD_LINE_OPTION plo
                   ,P_COVER            pc
                   ,AS_ASSET           aa
                   ,P_POLICY           pp
              WHERE 1 = 1
                AND pp.policy_id = p_p_policy_id
                AND aa.p_policy_id = pp.policy_id
                AND pc.as_asset_id = aa.as_asset_id
                AND plo.id = pc.t_prod_line_option_id
                AND pl.id = plo.product_line_id
                AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
                AND pv.t_product_version_id = pvl.product_version_id) tv
      WHERE 1 = 1
        AND pc.t_product_version_id = tv.t_product_version_id
    AND ct.t_prod_coef_type_id = pc.control_func_id;*/
  
    /*
    TODO: owner="pavel.kaplya" category="Fix" priority="2 - Medium" created="27.10.2013"
    text="Изменить, чтобы версия продукта определялась по дате начала договора.
          
          Необходимо учесть, что из-за кривых данных нужно будет исправить ряд продуктов, т.к. по ним есть договоры с датой начала меньше даты начала версии продукта"
    */
    CURSOR c_control_func IS
      SELECT control_func_id
            ,ct.name
            ,pc.message
        FROM ven_t_prod_coef_type ct
            ,t_product_control pc
            ,(SELECT pv.t_product_version_id
                FROM t_product_version pv
                    ,p_policy          pp
                    ,p_pol_header      ph
               WHERE pp.policy_id = p_p_policy_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND ph.product_id = pv.product_id
                 AND pv.t_product_version_id =
                     (SELECT MAX(t_product_version_id)
                        FROM t_product_version pv2
                       WHERE pv2.product_id = ph.product_id)) tv
       WHERE pc.t_product_version_id = tv.t_product_version_id
         AND ct.t_prod_coef_type_id = pc.control_func_id
         AND pc.is_underwriting_check = nvl(par_is_underwriting_check, pc.is_underwriting_check)
       ORDER BY pc.sort_order NULLS LAST;
    --
    -- v_func_id NUMBER;
    RESULT      NUMBER;
    v_msg       VARCHAR2(4000);
    control_qty NUMBER DEFAULT 0;
  
    PROCEDURE check_assured_count(par_policy_id p_policy.policy_id%TYPE) IS
      v_assured_count_limit t_product_version.assured_count_limit%TYPE;
      v_real_assured_count  NUMBER;
    BEGIN
      /*
      TODO: owner="pavel.kaplya" created="10.10.2013"
      text="Необходимо сделать связь версии проудкта с датой начала договора и отбирать правильную версию продукта на дату начала ДС. 
      Нужно учесть возможные ошибки из-за кривых данных"
      */
      SELECT pv.assured_count_limit
        INTO v_assured_count_limit
        FROM p_policy          pp
            ,p_pol_header      ph
            ,t_product_version pv
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = pv.product_id
         AND rownum < 2;
    
      IF v_assured_count_limit IS NOT NULL
      THEN
        SELECT COUNT(*)
          INTO v_real_assured_count
          FROM as_asset aa
         WHERE aa.p_policy_id = par_policy_id
           AND aa.status_hist_id != pkg_asset.status_hist_id_del;
      
        IF v_real_assured_count > v_assured_count_limit
        THEN
          v_msg := 'Превышен лимит числа застрахованных';
          raise_application_error(-20001, v_msg);
        END IF;
      END IF;
    
    EXCEPTION
      WHEN no_data_found THEN
        v_msg := 'Внутренняя ошибка табличных функций. Обратитесь к администратору';
    END check_assured_count;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
    /* Внимание ! Работа данной процедуры основано на предположении, что функции контроля возвращают 1 при корректном контроле
    и 0 при ошибочном*/
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'P_P_POLICY_ID'
                          ,par_trace_var_value => p_p_policy_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    check_assured_count(par_policy_id => p_p_policy_id);
    FOR cur IN c_control_func
    LOOP
      pkg_trace.add_variable(par_trace_var_name  => 'FUNC_ID'
                            ,par_trace_var_value => cur.control_func_id);
      pkg_trace.add_variable(par_trace_var_name => 'FUNC_NAME', par_trace_var_value => cur.name);
      trace(par_message => 'Вызов функции контроля продукта');
    
      BEGIN
        gv_error_text := NULL;
        RESULT        := pkg_tariff_calc.calc_fun(cur.control_func_id
                                                 ,ent.id_by_brief('P_POLICY')
                                                 ,p_p_policy_id);
      EXCEPTION
        WHEN ex_product_control_exception THEN
          v_msg := nvl(gv_error_text
                      ,'Внутренняя ошибка при работе функции "' || cur.name ||
                       '". Обратитесь к администратору');
          RAISE;
        WHEN OTHERS THEN
          v_msg := 'Внутренняя ошибка при работе функции "' || cur.name ||
                   '". Обратитесь к администратору';
          RAISE;
      END;
      IF RESULT != 1
      THEN
        IF control_qty > 0
        THEN
          v_msg := v_msg || chr(10);
        END IF;
        v_msg       := v_msg ||
                       coalesce(gv_error_text
                               ,cur.message
                               ,' Замечание по функции контроля ' || '"' || cur.name || '"');
        control_qty := control_qty + 1;
      END IF;
    
      IF length(v_msg) > 2000
      THEN
        v_msg := substr(v_msg, 1, 2000);
      END IF;
    
    END LOOP;
    IF control_qty > 0
    THEN
      raise_application_error(-20000, v_msg);
    END IF;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
      --Изменение текста ошибки согласовал Капля П. с Касьяненко А. 02.09.2013.
      raise_application_error(-20000
                             ,'Не пройден контроль по продукту' || CASE WHEN
                              par_is_underwriting_check = 1 THEN ' в процессе Андеррайтинга' ELSE ''
                              END || '. ' || v_msg);
  END;

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_control_inc_underwr(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    IF par_policy_id =
       pkg_policy.get_first_uncanceled_version(dml_p_policy.get_record(par_policy_id).pol_header_id)
    THEN
      policy_control(par_policy_id, 1);
    END IF;
  END policy_control_inc_underwr;

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    НЕ установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_control_exc_underwr(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    policy_control(par_policy_id, 0);
  END policy_control_exc_underwr;

  FUNCTION check_product_line_exists
  (
    par_policy_id              NUMBER
   ,par_prod_line_option_brief VARCHAR2
  ) RETURN BOOLEAN IS
    v_exists NUMBER(1);
  BEGIN
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM as_asset           aa
                  ,p_cover            pc
                  ,t_prod_line_option plo
             WHERE aa.p_policy_id = par_policy_id
               AND aa.as_asset_id = pc.as_asset_id
               AND pc.t_prod_line_option_id = plo.id
               AND plo.brief = par_prod_line_option_brief
               AND aa.status_hist_id != pkg_asset.status_hist_id_del);
    RETURN v_exists > 0;
  END check_product_line_exists;

  FUNCTION get_policy_form_short_name(par_policy_id NUMBER)
    RETURN t_policy_form.t_policy_form_short_name%TYPE IS
    v_policy_form_short_name t_policy_form.t_policy_form_short_name%TYPE;
  BEGIN
    SELECT tpf.t_policy_form_short_name
      INTO v_policy_form_short_name
      FROM ins.p_policy             pol
          ,ins.t_policyform_product tpp
          ,ins.t_policy_form        tpf
     WHERE pol.policy_id = par_policy_id
       AND pol.t_product_conds_id = tpp.t_policyform_product_id
       AND tpp.t_policy_form_id = tpf.t_policy_form_id;
    RETURN v_policy_form_short_name;
  END get_policy_form_short_name;
  --
  -- Author  : Ilya Slezin
  -- Created : 15.10.2009
  -- Purpose : Контроль наличия галки Экспресс
  PROCEDURE is_express(par_policy_id NUMBER) IS
    proc_name VARCHAR2(20) := 'is_express';
    not_is_express EXCEPTION;
    v_is_express NUMBER := 0;
  BEGIN
    SELECT tp.is_express
      INTO v_is_express
      FROM ven_t_product    tp
          ,ven_p_pol_header ph
          ,ven_p_policy     p
     WHERE p.policy_id = par_policy_id
       AND ph.policy_header_id = p.pol_header_id
       AND tp.product_id = ph.product_id;
  
    IF v_is_express <> 1
    THEN
      RAISE not_is_express;
    END IF;
  EXCEPTION
    WHEN not_is_express THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Продукт не относится к категории Экспресс.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END is_express;

  PROCEDURE check_use_in_ad(par_document_id NUMBER) IS
    proc_name VARCHAR2(30) := 'check_use_in_ad';
    n_cnt     NUMBER;
    no_change EXCEPTION;
  BEGIN
  
    BEGIN
      SELECT COUNT(*)
        INTO n_cnt
        FROM ven_cn_contact_bank_acc  bac
            ,ven_ag_contract_header   agh
            ,ven_ag_bank_props        pr
            ,ven_cn_document_bank_acc dac
       WHERE pr.ag_contract_header_id = agh.ag_contract_header_id
         AND agh.agent_id = bac.owner_contact_id
         AND bac.id = pr.cn_contact_bank_acc_id
         AND dac.cn_document_bank_acc_id = par_document_id
         AND dac.cn_contact_bank_acc_id = bac.id;
    EXCEPTION
      WHEN no_data_found THEN
        n_cnt := 0;
    END;
  
    IF n_cnt > 0
    THEN
      RAISE no_change;
    END IF;
  
  EXCEPTION
    WHEN no_change THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Данный реквизит используется в агентском договоре.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END check_use_in_ad;

  PROCEDURE update_contact_payment(par_document_id NUMBER) IS
    proc_name VARCHAR2(30) := 'update_contact_payment';
    is_role   NUMBER;
    no_is_role EXCEPTION;
  BEGIN
  
    BEGIN
      SELECT safety.check_right_custom('RECOVER_PAYMENT_REQEST') INTO is_role FROM dual;
    EXCEPTION
      WHEN no_data_found THEN
        is_role := 0;
    END;
  
    IF is_role = 0
    THEN
      RAISE no_is_role;
    END IF;
  
    UPDATE ven_cn_contact_bank_acc bac
       SET bac.is_check_owner   = 1
          ,bac.owner_contact_id =
           (SELECT bac.contact_id
              FROM ven_cn_document_bank_acc dac
                  ,ven_cn_contact_bank_acc  bac
             WHERE dac.cn_document_bank_acc_id = par_document_id
               AND dac.cn_contact_bank_acc_id = bac.id)
     WHERE bac.id = (SELECT dac.cn_contact_bank_acc_id
                       FROM ven_cn_document_bank_acc dac
                      WHERE dac.cn_document_bank_acc_id = par_document_id);
  
    doc.set_doc_status(par_document_id, 'ACTIVE');
  
    FOR cur IN (SELECT bac.contact_id
                      ,bacc.id
                      ,dacb.cn_document_bank_acc_id cn_doc_id
                  FROM ven_cn_document_bank_acc dac
                      ,ven_cn_contact_bank_acc  bac
                      ,ven_cn_contact_bank_acc  bacc
                      ,ven_cn_document_bank_acc dacb
                 WHERE 1 = 1
                   AND dac.cn_document_bank_acc_id = par_document_id
                   AND dac.cn_contact_bank_acc_id = bac.id
                   AND bac.account_nr = bacc.account_nr
                   AND bac.bank_id = bacc.bank_id
                   AND nvl(bac.account_corr, 'X') = nvl(bacc.account_corr, 'X')
                   AND nvl(bac.lic_code, 'X') = nvl(bacc.lic_code, 'X')
                   AND bac.bank_account_currency_id = bacc.bank_account_currency_id
                   AND bac.id <> bacc.id
                   AND bacc.id = dacb.cn_contact_bank_acc_id
                   AND doc.get_doc_status_name(dacb.cn_document_bank_acc_id) = 'Отменен')
    LOOP
    
      UPDATE ven_cn_contact_bank_acc b
         SET b.owner_contact_id =
             (SELECT bac.contact_id
                FROM ven_cn_document_bank_acc dac
                    ,ven_cn_contact_bank_acc  bac
               WHERE dac.cn_document_bank_acc_id = par_document_id
                 AND dac.cn_contact_bank_acc_id = bac.id)
       WHERE b.id = cur.id;
    
      INSERT INTO ven_doc_status ds
        (doc_status_id
        ,change_date
        ,doc_status_ref_id
        ,document_id
        ,note
        ,src_doc_status_ref_id
        ,start_date
        ,status_change_type_id
        ,user_name)
      VALUES
        (sq_doc_status.nextval
        ,SYSDATE
        ,19
        ,cur.cn_doc_id
        ,'Создание записи при переводе из Отменен в Активный'
        ,8
        ,SYSDATE
        ,2
        ,'INS');
    
    END LOOP;
  
  EXCEPTION
    WHEN no_is_role THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Нет права на Восстановление реквизита.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END update_contact_payment;

  PROCEDURE is_autoprolong(par_policy_id NUMBER) IS
    proc_name VARCHAR2(20) := 'is_autoprolong';
    no_autoprolong EXCEPTION;
    v_is_autoprolong    NUMBER := 0;
    v_start_date        DATE;
    v_header_start_date DATE;
    v_opt_prog          NUMBER;
    v_add               NUMBER;
  BEGIN
  
    SELECT p.start_date
      INTO v_header_start_date
      FROM p_policy p
     WHERE p.policy_id = (SELECT pp.policy_id
                            FROM p_policy pol
                                ,p_policy pp
                           WHERE pol.policy_id = par_policy_id
                             AND pp.pol_header_id = pol.pol_header_id
                             AND pp.version_num = 1);
  
    BEGIN
      SELECT 1
            ,p.start_date
        INTO v_add
            ,v_start_date
        FROM p_policy            p
            ,p_pol_addendum_type tp
            ,t_addendum_type     adt
       WHERE p.policy_id = par_policy_id
         AND p.policy_id = tp.p_policy_id
         AND tp.t_addendum_type_id = adt.t_addendum_type_id
         AND adt.description = 'Изменение формы оплаты договора';
    EXCEPTION
      WHEN no_data_found THEN
        v_add        := 0;
        v_start_date := to_date('01.01.1900', 'DD.MM.YYYY');
    END;
  
    IF v_add > 0
    THEN
    
      BEGIN
        SELECT COUNT(*)
          INTO v_opt_prog
          FROM p_policy                p
              ,ven_as_asset            ass
              ,ven_p_cover             pc
              ,status_hist             st
              ,ven_t_prod_line_option  plo
              ,ven_t_product_line      pl
              ,ven_t_product_line_type plt
              ,p_pol_header            ph
              ,t_product               pr
         WHERE p.policy_id = (SELECT pp.policy_id
                                FROM p_policy pol
                                    ,p_policy pp
                               WHERE pol.policy_id = par_policy_id
                                 AND pp.pol_header_id = pol.pol_header_id
                                 AND pp.version_num = pol.version_num - 1)
           AND ass.p_policy_id = p.policy_id
           AND pc.as_asset_id = ass.as_asset_id
           AND plo.id = pc.t_prod_line_option_id
           AND plo.product_line_id = pl.id
           AND pc.status_hist_id = st.status_hist_id
           AND st.brief <> 'DELETED'
           AND pl.product_line_type_id = plt.product_line_type_id
           AND plt.brief IN ('OPTIONAL', 'MANDATORY')
           AND plo.brief NOT IN ('Adm_Cost_Acc'
                                ,'TERM'
                                ,'TERM_2'
                                ,'INVEST2'
                                ,'DD'
                                ,'Adm_Cost_Life'
                                ,'END'
                                ,'Penalty'
                                ,'INVEST')
           AND p.pol_header_id = ph.policy_header_id
           AND ph.product_id = pr.product_id
           AND pr.brief NOT IN ('Investor', 'INVESTOR_LUMP') -- Заявка №190831
        /*
        and UPPER(trim(plo.description)) NOT IN
           ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ',
            'ПЕРВИЧНОЕ ДИАГНОСТИРОВАНИЕ СМЕРТЕЛЬНО ОПАСНОГО ЗАБОЛЕВАНИЯ',
            'ИНВЕСТ',
            'ИНВЕСТ2',
            'ИНВЕСТ2_1',
            'ШТРАФ',
            'СТРАХОВАНИЕ ЖИЗНИ НА СРОК',
            'СТРАХОВАНИЕ ЖИЗНИ К СРОКУ')*/
        ;
      EXCEPTION
        WHEN no_data_found THEN
          v_opt_prog := 0;
      END;
    
      IF v_opt_prog > 0
      THEN
      
        IF v_start_date >= ADD_MONTHS(v_header_start_date, 12)
        THEN
        
          BEGIN
            SELECT COUNT(*)
              INTO v_is_autoprolong
              FROM p_policy            p
                  ,p_pol_addendum_type tp
                  ,t_addendum_type     adt
             WHERE p.pol_header_id =
                   (SELECT pol.pol_header_id FROM p_policy pol WHERE pol.policy_id = par_policy_id)
               AND p.policy_id = tp.p_policy_id
               AND tp.t_addendum_type_id = adt.t_addendum_type_id
               AND adt.description = 'автопролонгация'
               AND p.start_date BETWEEN ADD_MONTHS(v_start_date, -12) + 1 AND v_start_date;
          EXCEPTION
            WHEN no_data_found THEN
              v_is_autoprolong := 0;
          END;
        
        ELSE
          v_is_autoprolong := 1;
        END IF;
      
        IF v_is_autoprolong <= 0
        THEN
          RAISE no_autoprolong;
        END IF;
      
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_autoprolong THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Нет автопролонгации за страховой год. ');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END is_autoprolong;

  PROCEDURE limit_agregation(par_policy_id NUMBER) IS
    proc_name VARCHAR2(35) := 'limit_agregation';
    p_p_sum   NUMBER;
    p_p_progr VARCHAR2(2000);
    no_standart_insurer EXCEPTION;
    no_standart_holder  EXCEPTION;
  BEGIN
  
    FOR cur_a IN (SELECT c.contact_id
                        ,ph.product_id
                        ,pl.id         pl_id
                        ,opt.id        opt_id
                        ,
                         --opt.description progr,
                         pr.description progr
                        ,pr.id pr_id
                        ,trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12) age
                        ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT'
                                                       ,t_number_type(ph.product_id
                                                                     ,pl.id
                                                                     ,opt.id
                                                                     ,pr.id)) group_risk
                        ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT'
                                                       ,t_number_type(ph.product_id
                                                                     ,pl.id
                                                                     ,opt.id
                                                                     ,pr.id)) group_limit
                        ,pkg_tariff_calc.calc_coeff_val('FIND_LIMIT_FOR_GROUP'
                                                       ,t_number_type(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT'
                                                                                                    ,t_number_type(ph.product_id
                                                                                                                  ,pl.id
                                                                                                                  ,opt.id
                                                                                                                  ,pr.id))
                                                                     ,trunc(MONTHS_BETWEEN(SYSDATE
                                                                                          ,cn.date_of_birth) / 12))) limit_sum
                    FROM p_pol_header          ph
                        ,p_policy              pp
                        ,as_asset              a
                        ,as_assured            ass
                        ,contact               c
                        ,cn_person             cn
                        ,ven_status_hist       sh
                        ,p_cover               pc
                        ,t_prod_line_option    opt
                        ,t_product_line        pl
                        ,t_prod_line_opt_peril per
                        ,t_peril               pr
                   WHERE 1 = 1
                     AND ph.policy_id = pp.policy_id
                     AND a.p_policy_id = pp.policy_id
                     AND a.p_policy_id = par_policy_id
                     AND nvl(pp.is_group_flag, 0) <> 1
                     AND a.as_asset_id = ass.as_assured_id
                     AND c.contact_id = ass.assured_contact_id
                     AND pc.t_prod_line_option_id = opt.id
                     AND sh.status_hist_id = pc.status_hist_id
                     AND sh.brief != 'DELETED'
                     AND opt.product_line_id = pl.id
                     AND per.product_line_option_id = opt.id
                     AND per.peril_id = pr.id
                     AND cn.contact_id = c.contact_id
                     AND pc.as_asset_id = a.as_asset_id
                     AND pp.version_num = 1
                     AND pl.description NOT IN
                         ('Защита страховых взносов'
                         ,'Защита страховых взносов рассчитанная по основной программе'
                         ,'Защита страховых взносов расчитанная по основной программе'))
    LOOP
      SELECT nvl(SUM(pc.ins_amount * (
                     
                      CASE
                        WHEN f.brief = 'USD' THEN
                         (CASE
                           WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 30 THEN
                            30
                           ELSE
                            acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                         END)
                        WHEN f.brief = 'EUR' THEN
                         (CASE
                           WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 35 THEN
                            35
                           ELSE
                            acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                         END)
                        ELSE
                         1
                      END
                     
                     ))
                ,0)
        INTO p_p_sum
        FROM p_cover               pc
            ,t_prod_line_option    opt
            ,t_product_line        pl
            ,t_prod_line_opt_peril per
            ,t_peril               pr
            ,as_asset              a
            ,as_assured            ass
            ,cn_person             cn
            ,p_policy              pp
            ,ven_status_hist       sh
            ,p_pol_header          ph
            ,fund                  f
       WHERE 1 = 1
         AND ass.assured_contact_id = cur_a.contact_id
         AND pc.t_prod_line_option_id = opt.id
         AND sh.status_hist_id = pc.status_hist_id
         AND sh.brief != 'DELETED'
         AND opt.product_line_id = pl.id
         AND per.product_line_option_id = opt.id
         AND per.peril_id = pr.id
         AND pc.as_asset_id = a.as_asset_id
         AND a.p_policy_id = pp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.fund_id = f.fund_id
         AND pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
         AND ass.as_assured_id = a.as_asset_id
         AND cn.contact_id = ass.assured_contact_id
         AND pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT'
                                           ,t_number_type(ph.product_id, pl.id, opt.id, pr.id)) =
             cur_a.group_risk
            --and pp.policy_id <> par_policy_id
         AND doc.get_doc_status_name(pkg_policy.get_last_version(ph.policy_header_id)
                                    ,to_date('31.12.2999', 'dd.mm.yyyy')) NOT IN
             ('Завершен'
             ,'Готовится к расторжению'
             ,'Расторгнут'
             ,'Отменен'
             ,'Приостановлен'
             ,'К прекращению'
             ,'К прекращению. Готов для проверки'
             ,'К прекращению. Проверен'
             ,'Прекращен');
      p_p_progr := cur_a.progr;
      IF p_p_sum > cur_a.limit_sum
      THEN
        RAISE no_standart_insurer;
      END IF;
    
    END LOOP;
  
    FOR cur_b IN (SELECT c.contact_id
                        ,ph.product_id
                        ,pl.id         pl_id
                        ,opt.id        opt_id
                        ,
                         --opt.description progr,
                         pr.description progr
                        ,pr.id pr_id
                        ,trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12) age
                        ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT'
                                                       ,t_number_type(ph.product_id
                                                                     ,pl.id
                                                                     ,opt.id
                                                                     ,pr.id)) group_risk
                        ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT'
                                                       ,t_number_type(ph.product_id
                                                                     ,pl.id
                                                                     ,opt.id
                                                                     ,pr.id)) group_limit
                        ,pkg_tariff_calc.calc_coeff_val('FIND_LIMIT_FOR_GROUP'
                                                       ,t_number_type(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT'
                                                                                                    ,t_number_type(ph.product_id
                                                                                                                  ,pl.id
                                                                                                                  ,opt.id
                                                                                                                  ,pr.id))
                                                                     ,trunc(MONTHS_BETWEEN(SYSDATE
                                                                                          ,cn.date_of_birth) / 12))) limit_sum
                    FROM p_pol_header          ph
                        ,p_policy              pp
                        ,as_asset              a
                        ,as_assured            ass
                        ,p_policy_contact      pcnt
                        ,t_contact_pol_role    polr
                        ,contact               c
                        ,cn_person             cn
                        ,ven_status_hist       sh
                        ,p_cover               pc
                        ,t_prod_line_option    opt
                        ,t_product_line        pl
                        ,t_prod_line_opt_peril per
                        ,t_peril               pr
                   WHERE 1 = 1
                     AND ph.policy_id = pp.policy_id
                     AND a.p_policy_id = pp.policy_id
                     AND a.p_policy_id = par_policy_id
                     AND nvl(pp.is_group_flag, 0) <> 1
                     AND a.as_asset_id = ass.as_assured_id
                        
                     AND polr.brief = 'Страхователь'
                     AND pcnt.policy_id = pp.policy_id
                     AND pcnt.contact_policy_role_id = polr.id
                     AND c.contact_id = pcnt.contact_id
                        
                     AND pc.t_prod_line_option_id = opt.id
                     AND sh.status_hist_id = pc.status_hist_id
                     AND sh.brief != 'DELETED'
                     AND opt.product_line_id = pl.id
                     AND per.product_line_option_id = opt.id
                     AND per.peril_id = pr.id
                     AND cn.contact_id = c.contact_id
                     AND pc.as_asset_id = a.as_asset_id
                     AND pp.version_num = 1
                     AND pl.description IN
                         ('Защита страховых взносов'
                         ,'Защита страховых взносов рассчитанная по основной программе'
                         ,'Защита страховых взносов расчитанная по основной программе'))
    LOOP
      SELECT nvl(SUM(pc.ins_amount * (
                     
                      CASE
                        WHEN f.brief = 'USD' THEN
                         (CASE
                           WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 30 THEN
                            30
                           ELSE
                            acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                         END)
                        WHEN f.brief = 'EUR' THEN
                         (CASE
                           WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 35 THEN
                            35
                           ELSE
                            acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                         END)
                        ELSE
                         1
                      END
                     
                     ))
                ,0)
        INTO p_p_sum
        FROM p_cover               pc
            ,t_prod_line_option    opt
            ,t_product_line        pl
            ,t_prod_line_opt_peril per
            ,t_peril               pr
            ,as_asset              a
            ,as_assured            ass
            ,p_policy_contact      pcnt
            ,t_contact_pol_role    polr
            ,contact               c
            ,cn_person             cn
            ,p_policy              pp
            ,ven_status_hist       sh
            ,p_pol_header          ph
            ,fund                  f
       WHERE 1 = 1
         AND polr.brief = 'Страхователь'
         AND pcnt.policy_id = a.p_policy_id
         AND pcnt.contact_policy_role_id = polr.id
         AND c.contact_id = pcnt.contact_id
            
         AND c.contact_id = cur_b.contact_id
         AND pc.t_prod_line_option_id = opt.id
         AND sh.status_hist_id = pc.status_hist_id
         AND sh.brief != 'DELETED'
         AND opt.product_line_id = pl.id
         AND per.product_line_option_id = opt.id
         AND per.peril_id = pr.id
         AND pc.as_asset_id = a.as_asset_id
         AND a.p_policy_id = pp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.fund_id = f.fund_id
         AND pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
         AND ass.as_assured_id = a.as_asset_id
         AND cn.contact_id = c.contact_id
         AND pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT'
                                           ,t_number_type(ph.product_id, pl.id, opt.id, pr.id)) =
             cur_b.group_risk
            --and pp.policy_id <> par_policy_id
         AND doc.get_doc_status_name(pkg_policy.get_last_version(ph.policy_header_id)
                                    ,to_date('31.12.2999', 'dd.mm.yyyy')) NOT IN
             ('Завершен'
             ,'Готовится к расторжению'
             ,'Расторгнут'
             ,'Отменен'
             ,'Приостановлен'
             ,'К прекращению'
             ,'К прекращению. Готов для проверки'
             ,'К прекращению. Проверен'
             ,'Прекращен');
      p_p_progr := cur_b.progr;
      IF p_p_sum > cur_b.limit_sum
      THEN
        RAISE no_standart_holder;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN no_standart_insurer THEN
      raise_application_error(-20001
                             ,'Застрахованный: Страховая сумма по ' || p_p_progr || ' равная ' ||
                              p_p_sum ||
                              ' больше разрешенной агрегированной суммы. Договор может быть переведен в статус Нестандартный или Проект.');
    WHEN no_standart_holder THEN
      raise_application_error(-20001
                             ,'Страхователь: Страховая сумма по ' || p_p_progr || ' равная ' ||
                              p_p_sum ||
                              ' больше разрешенной агрегированной суммы. Договор может быть переведен в статус Нестандартный или Проект.');
    
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END limit_agregation;

  PROCEDURE check_investor(par_policy_id NUMBER) IS
    p_all_sum NUMBER;
    proc_name VARCHAR2(35) := 'check_INVESTOR';
    no_role_policy EXCEPTION;
    no_role_cover  EXCEPTION;
    no_sum_check   EXCEPTION;
    p_progr     VARCHAR(255);
    p_inv       NUMBER;
    p_p_ver     NUMBER;
    p_dop_count NUMBER;
    p_old_sum   NUMBER;
  BEGIN
  
    BEGIN
      SELECT p.version_num
            ,(SELECT COUNT(*)
               FROM p_pol_addendum_type tp
                   ,t_addendum_type     t
              WHERE tp.p_policy_id = par_policy_id
                AND t.t_addendum_type_id = tp.t_addendum_type_id
                AND t.description = 'изменения по результатам андеррайтинга')
        INTO p_p_ver
            ,p_dop_count
        FROM p_policy p
       WHERE p.policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_p_ver     := 1;
        p_dop_count := 1;
    END;
  
    BEGIN
      SELECT decode(upper(prod.brief), 'INVESTOR', 1, 0)
        INTO p_inv
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    prod
       WHERE pp.policy_id = par_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND ph.product_id = prod.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_inv := 0;
    END;
  
    IF p_inv = 1
    THEN
    
      BEGIN
        SELECT nvl(SUM(nvl(pc.premium, 0)), 0)
          INTO p_all_sum
          FROM p_policy           pp
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
              ,t_product_line     pl
         WHERE pp.policy_id = par_policy_id
           AND pp.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id
           AND opt.product_line_id = pl.id
           AND pl.description NOT IN ('Административные издержки');
      EXCEPTION
        WHEN no_data_found THEN
          p_all_sum := 0;
      END;
    
      IF p_all_sum < 10000
      THEN
        RAISE no_role_policy;
      END IF;
    
      FOR cur IN (SELECT nvl(pc.premium, 0) ins_premium
                        ,opt.description progr
                    FROM p_policy           pp
                        ,as_asset           a
                        ,p_cover            pc
                        ,t_prod_line_option opt
                        ,t_product_line     pl
                   WHERE pp.policy_id = par_policy_id
                     AND pp.policy_id = a.p_policy_id
                     AND a.as_asset_id = pc.as_asset_id
                     AND pc.t_prod_line_option_id = opt.id
                     AND opt.product_line_id = pl.id
                     AND pl.description NOT IN ('Административные издержки'))
      
      LOOP
        IF cur.ins_premium < p_all_sum * 0.1
        THEN
          p_progr := cur.progr;
          RAISE no_role_cover;
        END IF;
      END LOOP;
    
      IF p_p_ver > 1
         AND p_dop_count = 0
      THEN
      
        BEGIN
          SELECT nvl(SUM(nvl(pc.premium, 0)), 0)
            INTO p_old_sum
            FROM p_policy           p
                ,as_asset           a
                ,p_cover            pc
                ,t_prod_line_option opt
                ,t_product_line     pl
           WHERE p.policy_id = par_policy_id
             AND a.p_policy_id = p.policy_id
             AND a.as_asset_id = pc.as_asset_id
             AND pc.t_prod_line_option_id = opt.id
             AND opt.product_line_id = pl.id
             AND pl.description NOT IN ('Административные издержки')
             AND p.policy_id = (SELECT pp.policy_id
                                  FROM p_policy pp
                                 WHERE pp.pol_header_id = p.pol_header_id
                                   AND pp.version_num = p_p_ver - 1);
        EXCEPTION
          WHEN no_data_found THEN
            p_old_sum := 0;
        END;
      
        IF p_old_sum < p_all_sum
        THEN
          RAISE no_sum_check;
        END IF;
      
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_role_policy THEN
      raise_application_error(-20001
                             ,'Общий страховой взнос по продукту Инвестор менее 10 000 рублей. Перевод в статус Новый невозможен.');
    WHEN no_role_cover THEN
      raise_application_error(-20001
                             ,'Страховой взнос по программе ' || p_progr ||
                              ' менее 10% от общего страхового взноса. Перевод в статус Новый невозможен.');
    WHEN no_sum_check THEN
      raise_application_error(-20001
                             ,'Сумма страхового взноса по предыдущей версии ДС больше, чем по текущей версии. Перевод в статус Новый невозможен.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
    
  END check_investor;

  PROCEDURE check_limit_investor(par_policy_id NUMBER) IS
    p_all_sum NUMBER;
    proc_name VARCHAR2(35) := 'check_limit_investor';
    no_standart EXCEPTION;
    p_inv NUMBER;
  BEGIN
  
    BEGIN
      SELECT decode(upper(prod.brief), 'INVESTOR', 1, 0)
        INTO p_inv
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    prod
       WHERE pp.policy_id = par_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND ph.product_id = prod.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_inv := 0;
    END;
  
    IF p_inv = 1
    THEN
    
      BEGIN
        SELECT nvl(SUM(nvl(pc.premium, 0)), 0)
          INTO p_all_sum
          FROM p_policy           pp
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
              ,t_product_line     pl
         WHERE pp.policy_id = par_policy_id
           AND pp.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id
           AND opt.product_line_id = pl.id;
      EXCEPTION
        WHEN no_data_found THEN
          p_all_sum := 0;
      END;
    
      IF p_all_sum < 10300
         OR p_all_sum > 600300
      THEN
        RAISE no_standart;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_standart THEN
      raise_application_error(-20001
                             ,'Общий страховой взнос по продукту Инвестор менее установленных возможных сумм. Возможен перевод в статус Нестандартный.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
    
  END check_limit_investor;

  /* Проверка минимальной премии по продуктам INVESTOR_LUMP
  * На данный момент указывается на переходе статусов
  * @param par_policy_id - ИД версии ДС
  */
  PROCEDURE check_limit_investor_lump(par_policy_id NUMBER) IS
    proc_name VARCHAR2(35) := 'check_limit_investor_lump';
    no_standart EXCEPTION;
    p_inv               NUMBER;
    v_product_brief     t_product.brief%TYPE;
    v_current_agent_num document.num%TYPE;
    v_total_premium     NUMBER;
    c_hkf_num CONSTANT document.num%TYPE := '44730'; --ООО «Хоум Кредит энд Финанс Банк»
  BEGIN
    -- определяем, что продукт по версии - это INVESTOR_LUMP
  
    SELECT prod.brief
           --номер действующего агента по договору
          ,(SELECT d.num
             FROM document d
            WHERE d.document_id = pkg_agn_control.get_current_policy_agent(pp.pol_header_id))
          ,(SELECT nvl(SUM(nvl(pc.premium, 0)), 0)
             FROM as_asset a
                 ,p_cover  pc
            WHERE a.p_policy_id = pp.policy_id
              AND a.as_asset_id = pc.as_asset_id)
      INTO v_product_brief
          ,v_current_agent_num
          ,v_total_premium
      FROM p_policy     pp
          ,p_pol_header ph
          ,t_product    prod
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND ph.product_id = prod.product_id
       AND prod.brief IN ('INVESTOR_LUMP', 'INVESTOR_LUMP_CALL_CENTRE' /*, 'INVESTOR_LUMP_ALPHA'*/);
  
    --проверяем на соответствие премии правилам по продукту.
    IF (v_total_premium < 100300 AND v_product_brief = 'INVESTOR_LUMP')
       OR (v_total_premium < 50000 AND v_product_brief = 'INVESTOR_LUMP_CALL_CENTRE')
       OR (v_total_premium < 100000 AND v_product_brief = 'INVESTOR_LUMP_ALPHA' AND
       v_current_agent_num != c_hkf_num)
       OR (v_total_premium < 30000 AND v_product_brief = 'INVESTOR_LUMP_ALPHA' AND
       v_current_agent_num = c_hkf_num)
    THEN
      RAISE no_standart;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN no_standart THEN
      raise_application_error(-20001
                             ,'Общий страховой взнос по продукту Инвестор менее установленных возможных сумм. Возможен перевод в статус Нестандартный.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
    
  END check_limit_investor_lump;

  FUNCTION investor_lump_alpha_premium(par_policy_id NUMBER) RETURN NUMBER IS
    c_proc_name            VARCHAR2(30) := 'investor_lump_alpha_premium';
    v_ag_contract_num      ven_ag_contract_header.num%TYPE;
    v_total_invest_premium p_cover.premium%TYPE;
  
    c_hkf_num       CONSTANT ven_ag_contract_header.num%TYPE := '44730'; --ООО «Хоум Кредит энд Финанс Банк»
    c_vtb24_num     CONSTANT ven_ag_contract_header.num%TYPE := '45130'; --ЗАО ВТБ 24
    c_vtb24_num_new CONSTANT ven_ag_contract_header.num%TYPE := '50592'; --ЗАО ВТБ 24 (новый)
  BEGIN
    assert_deprecated(par_policy_id IS NULL
                     ,'Входной параметр в функцию ' || c_proc_name || ' не может быть пустым');
  
    SELECT d.num
      INTO v_ag_contract_num
      FROM p_policy pp
          ,document d
     WHERE pp.policy_id = par_policy_id
       AND d.document_id = pkg_agn_control.get_current_policy_agent(pp.pol_header_id);
  
    SELECT nvl(SUM(pc.premium), 0)
      INTO v_total_invest_premium
      FROM p_cover            pc
          ,as_asset           aa
          ,t_prod_line_option plo
     WHERE aa.p_policy_id = par_policy_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND plo.brief IN ('PEPR_A_PLUS', 'PEPR_A', 'PEPR_B');
  
    IF v_ag_contract_num = c_hkf_num
       AND v_total_invest_premium < 30000
    THEN
      RETURN 0;
      /*assert_deprecated(v_total_invest_premium < 30000
      ,'Суммарная премия по инвестиционным программам должна быть не менее 30000 руб.');*/
    ELSIF v_ag_contract_num IN (c_vtb24_num, c_vtb24_num_new)
          AND v_total_invest_premium < 350000
    THEN
      RETURN 0;
      /*assert_deprecated(v_total_invest_premium < 350000
      ,'Суммарная премия по инвестиционным программам должна быть не менее 350000 руб.');*/
    ELSIF v_total_invest_premium < 100000
    THEN
      RETURN 0;
      /*assert_deprecated(v_total_invest_premium < 100000
      ,'Суммарная премия по инвестиционным программам должна быть не менее 100000 руб.');*/
    END IF;
  
    RETURN 1;
  
  END investor_lump_alpha_premium;

  PROCEDURE undrw_check(par_policy_id NUMBER) IS
    p_non_st        NUMBER := 0;
    p_k_coef_m      NUMBER;
    p_k_coef_nm     NUMBER;
    p_s_coef_m      NUMBER;
    p_s_coef_nm     NUMBER;
    p_flag          NUMBER;
    p_num_re        VARCHAR2(255);
    proc_name       VARCHAR2(35) := 'undrw_check';
    v_is_group_flag p_policy.is_group_flag%TYPE;
    no_check EXCEPTION;
  
    CURSOR c1 IS(
      SELECT /*f.brief, pc.ins_amount,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               pl.description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               opt.description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               pr.description,*/
       nvl(pkg_tariff_calc.calc_coeff_val('REINSURER_RISK'
                                         ,t_number_type(ph.product_id
                                                       ,pl.id
                                                       ,opt.id
                                                       ,pr.id
                                                       ,f.fund_id
                                                       ,trunc(MONTHS_BETWEEN(SYSDATE
                                                                            ,per.date_of_birth) / 12)
                                                       ,pc.ins_amount))
          ,0) flag
        FROM p_pol_header          ph
            ,p_policy              pp
            ,as_asset              a
            ,as_assured            ass
            ,cn_person             per
            ,p_cover               pc
            ,t_prod_line_option    opt
            ,t_product_line        pl
            ,t_prod_line_opt_peril per
            ,t_peril               pr
            ,ven_status_hist       sh
            ,fund                  f
       WHERE pc.t_prod_line_option_id = opt.id
         AND pp.policy_id = a.p_policy_id
         AND opt.product_line_id = pl.id
         AND a.as_asset_id = pc.as_asset_id
         AND a.as_asset_id = ass.as_assured_id
         AND ass.assured_contact_id = per.contact_id
         AND ph.policy_header_id = pp.pol_header_id
         AND nvl(pp.is_group_flag, 0) <> 1
         AND pc.t_prod_line_option_id = opt.id
         AND sh.status_hist_id = pc.status_hist_id
         AND sh.brief != 'DELETED'
         AND opt.product_line_id = pl.id
         AND per.product_line_option_id = opt.id
         AND per.peril_id = pr.id
         AND ph.fund_id = f.fund_id
         AND pp.version_num > 1
         AND a.p_policy_id = par_policy_id /*20938538*/
       );
  
    CURSOR c2 IS(
      SELECT nvl(pc.k_coef_m, 0)
            ,nvl(pc.k_coef_nm, 0)
            ,nvl(pc.s_coef_m, 0)
            ,nvl(pc.s_coef_nm, 0)
        FROM p_pol_header       ph
            ,p_policy           pp
            ,as_asset           a
            ,p_cover            pc
            ,t_prod_line_option opt
            ,t_product_line     pl
            ,fund               f
       WHERE pc.t_prod_line_option_id = opt.id
         AND pp.policy_id = a.p_policy_id
         AND opt.product_line_id = pl.id
         AND a.as_asset_id = pc.as_asset_id
         AND ph.policy_id = pp.policy_id
         AND ph.fund_id = f.fund_id
         AND pp.version_num > 1
         AND a.p_policy_id = par_policy_id);
  BEGIN
    -- Байтин А.
    -- Заявка 246930
    SELECT pp.is_group_flag INTO v_is_group_flag FROM p_policy pp WHERE pp.policy_id = par_policy_id;
    IF v_is_group_flag = 1
    THEN
      OPEN c1;
      LOOP
        FETCH c1
          INTO p_flag;
        EXIT WHEN c1%NOTFOUND;
        IF p_flag > 0
        THEN
          p_non_st := p_non_st + 1;
        END IF;
        /*case
        when p_brief = 'RUR' then
          if p_ins_amount > 7500000 then
             p_non_st := p_non_st + 1;
          end if;
        when p_brief = 'USD' then
          if p_ins_amount > 250000 then
             p_non_st := p_non_st + 1;
          end if;
        when p_brief = 'EUR' then
          if p_ins_amount > 215000 then
             p_non_st := p_non_st + 1;
          end if;
        else
          if p_ins_amount > 7500000 then
             p_non_st := p_non_st + 1;
          end if;
        end case;*/
      END LOOP;
      CLOSE c1;
    
      OPEN c2;
      LOOP
        FETCH c2
          INTO p_k_coef_m
              ,p_k_coef_nm
              ,p_s_coef_m
              ,p_s_coef_nm;
        EXIT WHEN c2%NOTFOUND;
        IF p_k_coef_m > 200
        THEN
          p_non_st := p_non_st + 1;
        ELSIF p_s_coef_m > 2
        THEN
          p_non_st := p_non_st + 1;
        ELSIF p_k_coef_nm > 200
        THEN
          p_non_st := p_non_st + 1;
        ELSIF p_s_coef_nm > 2
        THEN
          p_non_st := p_non_st + 1;
        END IF;
      END LOOP;
      CLOSE c2;
    
      IF p_non_st > 0
      THEN
        SELECT ra.num_re
          INTO p_num_re
          FROM p_policy      pp
              ,as_assured_re ra
         WHERE pp.policy_id = par_policy_id
           AND pp.policy_id = ra.p_policy_id(+);
      
        IF p_num_re IS NULL
        THEN
          RAISE no_check;
        END IF;
      
      END IF;
    END IF;
  EXCEPTION
    WHEN no_check THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Необходимо получить подтверждение перестраховщика.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END undrw_check;

  PROCEDURE exist_day_of_charge_off(par_policy_id NUMBER) IS
    proc_name VARCHAR2(35) := 'exist_day_of_charge_off';
    not_exist EXCEPTION;
    v_exist NUMBER := 0;
    dday    NUMBER;
    ssum    NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_exist
      FROM p_policy            pp
          ,t_collection_method t
     WHERE pp.policy_id = par_policy_id
       AND pp.collection_method_id = t.id
       AND t.description = 'Прямое списание с карты';
  
    IF v_exist > 0
    THEN
      SELECT nvl(pp.day_of_charge_off, 0)
        INTO dday
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
    
      SELECT nvl(pp.amount_of_charge_off, 0)
        INTO ssum
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
    
      IF dday = 0
         OR ssum = 0
      THEN
        RAISE not_exist;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN not_exist THEN
      raise_application_error(-20001
                             ,'Невозможен переход. При данном виде расчетов необходимо заполнение: числа списания, суммы по заявлению на списание.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END exist_day_of_charge_off;

  -- Author  : Ilya Slezin
  -- Created : 19.10.2009
  -- Purpose : Запрещает обратный переход из Доработки в статус отличный от предыдущего
  PROCEDURE back_from_revision(par_policy_id NUMBER) IS
    proc_name VARCHAR2(20) := 'back_from_REVISION';
    back_canceled EXCEPTION;
    v_src_doc_status_id NUMBER;
    v_src_doc_status    VARCHAR2(150);
    v_doc_status_id     NUMBER;
  BEGIN
    SELECT ds.doc_status_ref_id --Последний статус
      INTO v_doc_status_id
      FROM doc_status ds
     WHERE ds.document_id = par_policy_id
       AND rownum = 1
     ORDER BY ds.start_date DESC;
  
    SELECT a.src_doc_status_ref_id
      INTO v_src_doc_status_id
      FROM (SELECT ds.*
                  ,row_number() over(PARTITION BY ds.document_id ORDER BY ds.start_date DESC) c
              FROM doc_status ds
             WHERE ds.document_id = par_policy_id) a
     WHERE a.c = 2; --предпоследний статус
  
    SELECT dsr.name
      INTO v_src_doc_status
      FROM doc_status_ref dsr
     WHERE dsr.doc_status_ref_id = v_src_doc_status_id;
  
    IF v_doc_status_id <> v_src_doc_status_id
    THEN
      RAISE back_canceled;
    END IF;
  
  EXCEPTION
    WHEN back_canceled THEN
      raise_application_error(-20001
                             ,'Переход возможен только в предыдущий статус ' || v_src_doc_status);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END back_from_revision;

  -- Author  : Ilya Slezin
  -- Created : 16.10.2009
  -- Purpose : Запретить перевод Новый-Действующий, если тип допника не Автопролонгация
  PROCEDURE permit_new_current(par_policy_id NUMBER) IS
    proc_name VARCHAR2(20) := 'permit_new_current';
    is_autoprolongation_not_1 EXCEPTION;
    v_is_autoprolongation NUMBER := 0;
  BEGIN
    SELECT COUNT(*)
      INTO v_is_autoprolongation
      FROM ven_p_pol_addendum_type pat
          ,t_addendum_type         tat
     WHERE pat.p_policy_id = par_policy_id
       AND tat.t_addendum_type_id = pat.t_addendum_type_id
       AND tat.brief IN ('Автопролонгация', 'INDEXING2'); --Каткевич А.Г. - добавил индексацию
    IF v_is_autoprolongation < 1
    THEN
      RAISE is_autoprolongation_not_1;
    END IF;
  EXCEPTION
    WHEN is_autoprolongation_not_1 THEN
      raise_application_error(-20001
                             ,'Переход возможен только для типа допсоглашения Автопролонгация');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END permit_new_current;

  -- Author  : Ilya Slezin
  -- Created : 04.03.2010
  -- Purpose : Контроль оплаченного Взаимозачета
  PROCEDURE payment_setoff_not_payed(par_policy_id NUMBER) IS
    proc_name VARCHAR2(50) := 'PAYMENT_SETOFF_not_payed';
    is_exeption EXCEPTION;
    v_msg          VARCHAR2(500);
    v_is_exception NUMBER := 0;
  BEGIN
    SELECT 1
      INTO v_is_exception
      FROM p_policy  p2
          ,p_policy  p
          ,doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE p2.policy_id = par_policy_id
       AND p.pol_header_id = p2.pol_header_id
       AND dd.parent_id = p.policy_id --Поиск по всем версиям
       AND dd.child_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief IN ('PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC') --Это взаимозачёт
       AND doc.get_doc_status_brief(d.document_id) IN ('NEW', 'TO_PAY');
  
    IF v_is_exception = 1
    THEN
      RAISE is_exeption;
    END IF;
  EXCEPTION
    WHEN is_exeption THEN
      v_msg := 'Переход запрёщен. По договору существует не оплаченный взаимозачёт.';
      raise_application_error(-20002, v_msg);
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END payment_setoff_not_payed;

  -- Author  : Ilya Slezin
  -- Created : 25.11.2009
  -- Purpose : СС по ДОП программам =< СС по ОСН
  PROCEDURE ins_sum_rec_vs_opt(par_policy_id NUMBER) IS
    proc_name VARCHAR2(50) := 'ins_sum_REC_vs_OPT';
    is_exeption EXCEPTION;
    v_msg         VARCHAR2(500);
    rec_sum       NUMBER;
    opt_sum       NUMBER;
    opt_name      VARCHAR2(255);
    v_version_num NUMBER;
    v_product     VARCHAR2(100);
  BEGIN
    SELECT p.version_num
          ,pr.brief
      INTO v_version_num
          ,v_product
      FROM p_policy     p
          ,p_pol_header ph
          ,t_product    pr
     WHERE p.policy_id = par_policy_id
       AND ph.policy_header_id = p.pol_header_id
       AND pr.product_id = ph.product_id;
  
    IF v_version_num = 1
       AND v_product IN ('PEPR', 'END', 'CHI', 'APG', 'TERM', 'ACC163', 'ACC164')
    THEN
      SELECT pc.ins_amount
        INTO rec_sum
        FROM p_policy            p
            ,as_asset            aa
            ,status_hist         sha
            ,p_cover             pc
            ,status_hist         shp
            ,t_product_line_type plt
            ,t_product_line      pl
            ,t_prod_line_option  plo
       WHERE 1 = 1
         AND p.policy_id = par_policy_id
         AND p.version_num = 1
         AND aa.p_policy_id = p.policy_id
         AND sha.status_hist_id = aa.status_hist_id
         AND sha.brief <> 'DELETED'
         AND pc.as_asset_id = aa.as_asset_id
         AND shp.status_hist_id = pc.status_hist_id
         AND shp.brief <> 'DELETED'
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND plt.brief = 'RECOMMENDED';
    
      SELECT MAX(opt_sum) opt_sum
            ,MAX(opt_name) opt_name
        INTO opt_sum
            ,opt_name
        FROM (SELECT pc.ins_amount   opt_sum
                    ,plo.description opt_name
                FROM p_policy            p
                    ,as_asset            aa
                    ,status_hist         sha
                    ,p_cover             pc
                    ,status_hist         shp
                    ,t_product_line_type plt
                    ,t_product_line      pl
                    ,t_prod_line_option  plo
               WHERE 1 = 1
                 AND p.policy_id = par_policy_id
                 AND p.version_num = 1
                 AND aa.p_policy_id = p.policy_id
                 AND sha.status_hist_id = aa.status_hist_id
                 AND sha.brief <> 'DELETED'
                 AND pc.as_asset_id = aa.as_asset_id
                 AND shp.status_hist_id = pc.status_hist_id
                 AND shp.brief <> 'DELETED'
                 AND plo.id = pc.t_prod_line_option_id
                 AND pl.id = plo.product_line_id
                 AND plt.product_line_type_id = pl.product_line_type_id
                 AND plt.brief <> 'RECOMMENDED'
               ORDER BY nvl(pc.ins_amount, 0) DESC)
       WHERE rownum = 1;
    
      IF rec_sum < opt_sum
      THEN
        RAISE is_exeption;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN is_exeption THEN
      v_msg := 'Страховая сумма по дополнительной программе ' || opt_name ||
               ' больше страховой суммы по основной программе. Договор может быть переведен в статус "Нестандарт" или "Проект"';
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END ins_sum_rec_vs_opt;

  -- Author  : Ilya Slezin
  -- Created : 25.03.2010
  -- Purpose : Контроль лимита СС
  PROCEDURE ins_amount_limit_control(par_p_policy_id NUMBER) IS
    proc_name VARCHAR2(50) := 'Ins_amount_limit_control';
    v_msg     VARCHAR2(500);
    is_exeption EXCEPTION;
    v_version_num NUMBER;
    v_ins_lim     NUMBER;
  
    CURSOR c_cur IS
      SELECT pc.p_cover_id
            ,pc.ent_id
            ,pc.ins_amount
            ,plo.description plo_name
        FROM p_cover            pc
            ,t_prod_line_option plo
            ,as_asset           aa
            ,status_hist        sha
            ,status_hist        shp
       WHERE aa.p_policy_id = par_p_policy_id
         AND plo.id = pc.t_prod_line_option_id
         AND aa.as_asset_id = pc.as_asset_id
         AND sha.status_hist_id = aa.status_hist_id
         AND sha.brief <> 'DELETED'
         AND shp.status_hist_id = pc.status_hist_id
         AND shp.brief <> 'DELETED';
  
  BEGIN
    -- pkg_renlife_utils.tmp_log_writer('Ins_amount_limit_control p_policy_id'||par_p_policy_id);
  
    SELECT p.version_num INTO v_version_num FROM p_policy p WHERE p.policy_id = par_p_policy_id;
  
    IF v_version_num = 1
    THEN
      FOR c IN c_cur
      LOOP
        v_ins_lim := pkg_tariff_calc.calc_fun('Ins_amount_cover_limit', c.ent_id, c.p_cover_id);
        IF v_ins_lim > 0
           AND v_ins_lim < c.ins_amount
        THEN
          v_msg := 'Страховая сумма по программе ' || c.plo_name ||
                   ' больше лимита. Договор может быть переведен в статус "Нестандарт" или "Проект"';
          RAISE is_exeption;
        END IF;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN is_exeption THEN
      raise_application_error(-20002, v_msg);
    
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ins_amount_limit_control;

  -- ishch (
  -- Контроль группы профессий
  -- Параметр: идентификатор версии ДС
  PROCEDURE work_group(par_policy_id NUMBER) IS
    v_proc_name VARCHAR2(50) := 'Work_Group';
    v_msg       VARCHAR2(500);
    v_exeption EXCEPTION;
    v_dummy CHAR(1);
    CURSOR main_curs(pcurs_policy_id NUMBER) IS
      SELECT '1'
        FROM p_policy       p
            ,p_pol_header   h
            ,ven_as_assured a
            ,t_product      pr
       WHERE p.policy_id = pcurs_policy_id
         AND p.pol_header_id = h.policy_header_id
         AND h.product_id = pr.product_id
         AND p.version_num = 1 -- только для первой версии договора
         AND p.policy_id = a.p_policy_id
         AND a.work_group_id IN (3, 4) -- группа профессий - 3 или 4
         AND pr.description IN -- проверка только для заданного списка
            -- продуктов - ishch 23.11.2010
             ('Будущее'
             ,'Гармония жизни'
             ,'Дети'
             ,'Защита APG'
             ,'Защита 163'
             ,'Защита 164'
             ,'Семейный депозит'
             ,'Семья'
             ,'Будущее_2'
             ,'Гармония жизни_2'
             ,'Дети_2'
             ,'Семья_2'
             ,'Семейный депозит 2011'
             ,'Защита 172'
             ,'Защита 173');
  BEGIN
    OPEN main_curs(par_policy_id);
    FETCH main_curs
      INTO v_dummy;
    IF main_curs%FOUND
    THEN
      CLOSE main_curs;
      v_msg := 'Профессия у застрахованного не удовлетворяет ' ||
               'стандартным требованиям компании. Договор может быть переведен ' ||
               'в статус "Нестандарт" или "Проект"';
      RAISE v_exeption;
    END IF;
    CLOSE main_curs;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END work_group;

  -- Контроль выгодоприобретателя
  -- Параметр: идентификатор версии ДС
  PROCEDURE benefic(par_policy_id NUMBER) IS
    v_proc_name VARCHAR2(50) := 'Work_Group';
    v_msg       VARCHAR2(500);
    v_exeption EXCEPTION;
    v_dummy CHAR(1);
    CURSOR main_curs(pcurs_policy_id NUMBER) IS
      SELECT '1'
        FROM p_policy           p
            ,p_pol_header       ph
            ,t_sales_channel    sc
            ,as_asset           a
            ,as_beneficiary     ab
            ,t_contact_rel_type rt
            ,ven_cn_contact_rel cr
            ,t_product          pr
       WHERE p.policy_id = pcurs_policy_id
         AND p.version_num = 1 -- только для первой версии договора
         AND p.pol_header_id = ph.policy_header_id
         AND ph.sales_channel_id = sc.id
         AND sc.brief != 'BANK' -- канал продаж НЕ "Банковский"
         AND p.policy_id = a.p_policy_id
         AND a.as_asset_id = ab.as_asset_id
         AND ab.cn_contact_rel_id = cr.id
         AND cr.relationship_type = rt.id
         AND rt.relationship_dsc NOT IN ('Дочь'
                                        ,'Сын'
                                        ,'Жена'
                                        ,'Муж'
                                        ,'Мать'
                                        ,'Отец'
                                        ,
                                         ----
                                         'Бабушка'
                                        ,'Дедушка'
                                        ,'Брат'
                                        ,'Сестра') -- ishch 28.01.2011
         AND ph.product_id = pr.product_id
         AND pr.description IN -- проверка только для заданного списка
            -- продуктов - ishch 23.11.2010
             ('Будущее'
             ,'Гармония жизни'
             ,'Дети'
             ,'Защита APG'
             ,'Защита 163'
             ,'Защита 164'
             ,'Семейный депозит'
             ,'Семья'
             ,'Будущее_2'
             ,'Гармония жизни_2'
             ,'Дети_2'
             ,'Семья_2'
             ,'Семейный депозит 2011')
            --заявка 220752 Изместьев.11.03.2013
         AND NOT EXISTS
       (SELECT NULL
                FROM as_beneficiary     ab1
                    ,t_contact_rel_type rt1
                    ,ven_cn_contact_rel cr1
               WHERE ab.cn_contact_rel_id = cr.id
                 AND cr.relationship_type = rt.id
                 AND ab1.as_asset_id = a.as_asset_id
                 AND (ab1.contact_id = 667079 AND rt1.relationship_dsc = 'Другой'));
  BEGIN
    OPEN main_curs(par_policy_id);
    FETCH main_curs
      INTO v_dummy;
    IF main_curs%FOUND
    THEN
      CLOSE main_curs;
      v_msg := 'Выгодоприобретатель не удовлетворяет стандартным ' ||
               'требованиям компании . Договор может быть переведен ' ||
               'в статус "Нестандарт" или "Проект"';
      RAISE v_exeption;
    END IF;
    CLOSE main_curs;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END benefic;
  -- ishch )

  /* Проверка на стандартность/нестандартность по хобби
  * Заявка №192041
  * @autor Чирков В. Ю.
  * @param par_policy_id - версия полиса ДС
  */
  PROCEDURE check_hobby(par_policy_id NUMBER) AS
    v_cnt INT;
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM ins.ven_as_insured ai
          ,ins.t_hobby        th
          ,ins.p_policy       pp
          ,ins.p_pol_header   ph
          ,ins.t_product      pr
     WHERE ai.policy_id = par_policy_id
       AND th.t_hobby_id(+) = ai.t_hobby_id
       AND th.t_hobby_id != 61 --Нет
       AND pp.policy_id = ai.policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pr.product_id = ph.product_id
       AND pr.brief IN ('END'
                       ,'TERM'
                       ,'CHI'
                       ,'PEPR'
                       ,'END_2'
                       ,'TERM_2'
                       ,'CHI_2'
                       ,'PEPR_2'
                       ,'Family_Dep'
                       ,'Family_Dep_2011')
       AND EXISTS (SELECT 1
              FROM ins.as_asset           aa
                  ,ins.p_cover            pc
                  ,ins.t_prod_line_option plo
             WHERE aa.p_policy_id = par_policy_id
               AND pc.as_asset_id = aa.as_asset_id
               AND plo.id = pc.t_prod_line_option_id
               AND plo.description LIKE 'Защита страховых взносов%'
               AND pc.status_hist_id IN (1, 2));
    IF v_cnt > 0
    THEN
      v_msg := 'Вид спорта <Нет> у страхователя не удовлетворяет стандартным ' ||
               'требованиям компании . Договор может быть переведен ' ||
               'в статус "Нестандарт" или "Проект" ';
      RAISE v_exeption;
    END IF;
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM ins.as_asset     aa
          ,ins.as_assured   aas
          ,ins.p_policy     pp
          ,ins.p_pol_header ph
          ,t_product        pr
          ,t_hobby          th
     WHERE aa.p_policy_id = par_policy_id
       AND aas.as_assured_id = aa.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND pr.product_id = ph.product_id
       AND aas.t_hobby_id = th.t_hobby_id
       AND th.t_hobby_id != 61 --Нет
       AND pr.brief IN ('PEPR'
                       ,'PEPR_2'
                       ,'END'
                       ,'END_2'
                       ,'CHI'
                       ,'CHI_2'
                       ,'APG'
                       ,'ACC163'
                       ,'ACC164'
                       ,'TERM'
                       ,'TERM_2'
                       ,'Family_Dep'
                       ,'Family_Dep_2011');
    IF v_cnt > 0
    THEN
      v_msg := 'Вид спорта <Нет> у объекта страхования не удовлетворяет стандартным ' ||
               'требованиям компании . Договор может быть переведен ' ||
               'в статус "Нестандарт" или "Проект" ';
      RAISE v_exeption;
    END IF;
  
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
  END check_hobby;

  PROCEDURE limit_agregation_for_region(par_policy_id NUMBER) IS
    proc_name       VARCHAR2(35) := 'limit_agregation_for_region';
    p_p_sum         NUMBER;
    p_p_progr       VARCHAR2(2000);
    p_holder_name   VARCHAR2(255);
    p_insurer_name  VARCHAR2(255);
    p_insurer_age   NUMBER;
    p_min_limit_age NUMBER;
    p_max_limit_age NUMBER;
    no_standart_insurer EXCEPTION;
    no_standart_holder  EXCEPTION;
    p_sum_limit NUMBER;
    p_dep_name  VARCHAR2(655);
  BEGIN
    FOR cur_parm_a IN (SELECT c.contact_id
                             ,c.obj_name_orig insurer_name
                             ,trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12) cn_age
                             ,(SELECT dep.name
                                 FROM ins.p_policy_agent_doc     pad
                                     ,ins.ven_ag_contract_header agh
                                     ,ins.ag_contract            ag
                                     ,ins.department             dep
                                WHERE pad.policy_header_id = ph.policy_header_id
                                  AND agh.ag_contract_header_id = pad.ag_contract_header_id
                                  AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                                  AND rownum = 1 /*старые агенты привязаны как хотишь*/
                                  AND agh.last_ver_id = ag.ag_contract_id
                                  AND ag.agency_id = dep.department_id) dep_name
                         FROM p_pol_header ph
                             ,p_policy     pp
                             ,as_asset     a
                             ,as_assured   ass
                             ,contact      c
                             ,cn_person    cn
                        WHERE 1 = 1
                          AND ph.policy_header_id = pp.pol_header_id
                          AND a.p_policy_id = pp.policy_id
                          AND a.p_policy_id = par_policy_id
                          AND nvl(pp.is_group_flag, 0) <> 1
                          AND a.as_asset_id = ass.as_assured_id
                          AND c.contact_id = ass.assured_contact_id
                          AND cn.contact_id = c.contact_id
                          AND (pp.version_num = 1 OR EXISTS
                               (SELECT NULL
                                  FROM ins.p_pol_addendum_type padt
                                      ,ins.t_addendum_type     tat
                                 WHERE padt.p_policy_id = pp.policy_id
                                   AND padt.t_addendum_type_id = tat.t_addendum_type_id
                                   AND tat.brief IN ('FEE_INCREASE'
                                                    ,'COVER_ADDING'
                                                    ,'CLOSE_FIN_WEEKEND'
                                                    ,'POLICY_FROM_PAYED'
                                                    ,'RECOVER_MAIN'))))
    LOOP
    
      p_insurer_name := cur_parm_a.insurer_name;
      p_dep_name     := cur_parm_a.dep_name;
      p_insurer_age  := cur_parm_a.cn_age;
    
      FOR cur_lim_a IN (SELECT /*+ NO_MERGE(t) */
                         MIN(pkg_tariff_calc.calc_coeff_val(tpct.brief, t_number_type(group_limit, age))) limit_sum
                        ,peril_name
                        ,prog_name
                        ,group_risk
                        ,nvl(MAX(tpc_2.criteria_2), 0) min_age_limit
                        ,MIN(tpc.criteria_2) max_age_limit
                        
                          FROM (SELECT nvl(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT_REGION'
                                                                         ,t_number_type(dep.department_id
                                                                                       ,ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))
                                          ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT_DEFAULT'
                                                                         ,t_number_type(ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))) group_limit
                                      ,nvl(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_REGION'
                                                                         ,t_number_type(dep.department_id
                                                                                       ,ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))
                                          ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_DEFAULT'
                                                                         ,t_number_type(ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))) group_risk
                                      ,CASE
                                         WHEN MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12 < 1 THEN
                                          MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12
                                         ELSE
                                          trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12)
                                       END age
                                      ,pr.description peril_name
                                      ,pl.description prog_name
                                  FROM p_cover               pc
                                      ,t_prod_line_option    opt
                                      ,t_product_line        pl
                                      ,t_prod_line_opt_peril per
                                      ,t_peril               pr
                                      ,as_asset              a
                                      ,as_assured            ass
                                      ,cn_person             cn
                                      ,p_policy              pp
                                      ,ven_status_hist       sh
                                      ,p_pol_header          ph
                                      ,fund                  f
                                      ,ins.department        dep
                                 WHERE 1 = 1
                                   AND ass.assured_contact_id = cur_parm_a.contact_id
                                   AND pc.t_prod_line_option_id = opt.id
                                   AND sh.status_hist_id = pc.status_hist_id
                                      
                                   AND pr.id IN (SELECT pr.id
                                                   FROM p_cover               pc
                                                       ,t_prod_line_option    opt
                                                       ,t_product_line        pl
                                                       ,t_prod_line_opt_peril per
                                                       ,t_peril               pr
                                                       ,as_asset              a
                                                       ,as_assured            ass
                                                       ,p_policy              pp
                                                       ,ven_status_hist       sh
                                                  WHERE 1 = 1
                                                    AND ass.assured_contact_id = cur_parm_a.contact_id
                                                    AND pc.t_prod_line_option_id = opt.id
                                                    AND sh.status_hist_id = pc.status_hist_id
                                                    AND sh.brief != 'DELETED'
                                                    AND opt.product_line_id = pl.id
                                                    AND per.product_line_option_id = opt.id
                                                    AND per.peril_id = pr.id
                                                    AND pc.as_asset_id = a.as_asset_id
                                                    AND a.p_policy_id = pp.policy_id
                                                    AND ass.as_assured_id = a.as_asset_id
                                                    AND pp.policy_id = par_policy_id)
                                   AND dep.department_id =
                                       (SELECT dep1.department_id
                                          FROM ins.p_policy_agent_doc     pad
                                              ,ins.ven_ag_contract_header agh
                                              ,ins.ag_contract            ag
                                              ,ins.department             dep1
                                         WHERE pad.policy_header_id = ph.policy_header_id
                                           AND agh.ag_contract_header_id = pad.ag_contract_header_id
                                           AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) =
                                               'CURRENT'
                                           AND rownum = 1 /*старые агенты привязаны как хотишь*/
                                           AND agh.last_ver_id = ag.ag_contract_id
                                           AND ag.agency_id = dep1.department_id)
                                   AND sh.brief != 'DELETED'
                                   AND opt.product_line_id = pl.id
                                   AND per.product_line_option_id = opt.id
                                   AND per.peril_id = pr.id
                                   AND pc.as_asset_id = a.as_asset_id
                                   AND a.p_policy_id = pp.policy_id
                                   AND pp.pol_header_id = ph.policy_header_id
                                   AND ph.fund_id = f.fund_id
                                   AND pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
                                   AND ass.as_assured_id = a.as_asset_id
                                   AND cn.contact_id = ass.assured_contact_id
                                   AND doc.get_doc_status_name(pkg_policy.get_last_version(ph.policy_header_id)
                                                              ,to_date('31.12.2999', 'dd.mm.yyyy')) NOT IN
                                       ('Завершен'
                                       ,'Готовится к расторжению'
                                       ,'Расторгнут'
                                       ,'Отменен'
                                       ,'Приостановлен'
                                       ,'К прекращению'
                                       ,'К прекращению. Готов для проверки'
                                       ,'К прекращению. Проверен'
                                       ,'Прекращен'
                                       ,'Прекращен. Запрос реквизитов'
                                       , --Чирков/159374: Доработка - контроль агрегации/
                                        'Прекращен. Реквизиты получены'
                                       , --Чирков/159374: Доработка - контроль агрегации/
                                        'Прекращен.К выплате' --Чирков/159374: Доработка - контроль агрегации/
                                        )
                                   AND pl.description NOT IN
                                       ('Защита страховых взносов'
                                       ,'Защита страховых взносов рассчитанная по основной программе'
                                       ,'Защита страховых взносов расчитанная по основной программе')) t
                              ,t_prod_coef tpc
                              ,t_prod_coef_type tpct
                              ,t_prod_coef tpc_2
                         WHERE 1 = 1
                           AND tpc.t_prod_coef_type_id = tpct.t_prod_coef_type_id
                           AND tpc_2.t_prod_coef_type_id = tpct.t_prod_coef_type_id
                           AND tpc.criteria_1 = t.group_limit
                           AND tpc_2.criteria_1(+) = t.group_limit
                           AND tpct.brief = CASE
                                 WHEN EXISTS (SELECT NULL
                                         FROM t_prod_coef      tpc1
                                             ,t_prod_coef_type tpct1
                                        WHERE tpct1.brief = 'FIND_LIMIT_FOR_GROUP_REGION'
                                          AND tpc1.t_prod_coef_type_id = tpct1.t_prod_coef_type_id
                                          AND tpc1.criteria_1 = t.group_limit) THEN
                                  'FIND_LIMIT_FOR_GROUP_REGION'
                                 ELSE
                                  'FIND_LIMIT_FOR_GROUP_DEFAULT'
                               END
                           AND tpc.criteria_2 >= t.age
                           AND tpc_2.criteria_2 < t.age
                         GROUP BY (tpct.brief, t.age, t.peril_name, t.prog_name, t.group_risk))
      LOOP
      
        SELECT nvl(SUM(pc.ins_amount * (
                       
                        CASE
                          WHEN f.brief = 'USD' THEN
                           (CASE
                             WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 30 THEN
                              30
                             ELSE
                              acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                           END)
                          WHEN f.brief = 'EUR' THEN
                           (CASE
                             WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 35 THEN
                              35
                             ELSE
                              acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                           END)
                          ELSE
                           1
                        END
                       
                       ))
                  ,0)
          INTO p_p_sum
          FROM p_cover               pc
              ,t_prod_line_option    opt
              ,t_product_line        pl
              ,t_prod_line_opt_peril per
              ,t_peril               pr
              ,as_asset              a
              ,as_assured            ass
              ,cn_person             cn
              ,p_policy              pp
              ,ven_status_hist       sh
              ,p_pol_header          ph
              ,fund                  f
              ,ins.department        dep
         WHERE 1 = 1
           AND ass.assured_contact_id = cur_parm_a.contact_id
           AND pc.t_prod_line_option_id = opt.id
           AND sh.status_hist_id = pc.status_hist_id
           AND sh.brief != 'DELETED'
           AND opt.product_line_id = pl.id
           AND per.product_line_option_id = opt.id
           AND per.peril_id = pr.id
           AND pc.as_asset_id = a.as_asset_id
           AND a.p_policy_id = pp.policy_id
           AND pp.pol_header_id = ph.policy_header_id
           AND ph.fund_id = f.fund_id
           AND pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
           AND ass.as_assured_id = a.as_asset_id
           AND cn.contact_id = ass.assured_contact_id
           AND dep.department_id =
               (SELECT dep1.department_id
                  FROM ins.p_policy_agent_doc     pad
                      ,ins.ven_ag_contract_header agh
                      ,ins.ag_contract            ag
                      ,ins.department             dep1
                 WHERE pad.policy_header_id = ph.policy_header_id
                   AND agh.ag_contract_header_id = pad.ag_contract_header_id
                   AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND rownum = 1 /*старые агенты привязаны как хотишь*/
                   AND agh.last_ver_id = ag.ag_contract_id
                   AND ag.agency_id = dep1.department_id)
           AND nvl(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_REGION'
                                                 ,t_number_type(dep.department_id
                                                               ,ph.product_id
                                                               ,pl.id
                                                               ,opt.id
                                                               ,pr.id))
                  ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_DEFAULT'
                                                 ,t_number_type(ph.product_id, pl.id, opt.id, pr.id))) =
               cur_lim_a.group_risk
              --and pp.policy_id <> par_policy_id
           AND doc.get_doc_status_name(pkg_policy.get_last_version(ph.policy_header_id)
                                      ,to_date('31.12.2999', 'dd.mm.yyyy')) NOT IN
               ('Завершен'
               ,'Готовится к расторжению'
               ,'Расторгнут'
               ,'Отменен'
               ,'Приостановлен'
               ,'К прекращению'
               ,'К прекращению. Готов для проверки'
               ,'К прекращению. Проверен'
               ,'Прекращен'
               ,'Прекращен. Запрос реквизитов'
               , --Чирков/159374: Доработка - контроль агрегации/
                'Прекращен. Реквизиты получены'
               , --Чирков/159374: Доработка - контроль агрегации/
                'Прекращен.К выплате' --Чирков/159374: Доработка - контроль агрегации/
                );
        p_p_progr       := cur_lim_a.prog_name;
        p_sum_limit     := cur_lim_a.limit_sum;
        p_min_limit_age := cur_lim_a.min_age_limit;
        p_max_limit_age := cur_lim_a.max_age_limit;
      
        IF p_p_sum > cur_lim_a.limit_sum
        THEN
          RAISE no_standart_insurer;
        END IF;
      
      END LOOP;
    
    END LOOP;
  
    FOR cur_parm_b IN (SELECT c.contact_id
                             ,c.obj_name_orig holder_name
                             ,trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12) cn_age
                             ,(SELECT dep.name
                                 FROM ins.p_policy_agent_doc     pad
                                     ,ins.ven_ag_contract_header agh
                                     ,ins.ag_contract            ag
                                     ,ins.department             dep
                                WHERE pad.policy_header_id = ph.policy_header_id
                                  AND agh.ag_contract_header_id = pad.ag_contract_header_id
                                  AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                                  AND rownum = 1 /*старые агенты привязаны как хотишь*/
                                  AND agh.last_ver_id = ag.ag_contract_id
                                  AND ag.agency_id = dep.department_id) dep_name
                         FROM p_pol_header       ph
                             ,p_policy           pp
                             ,p_policy_contact   pcnt
                             ,t_contact_pol_role polr
                             ,contact            c
                             ,cn_person          cn
                        WHERE 1 = 1
                          AND ph.policy_header_id = pp.pol_header_id
                          AND pp.policy_id = par_policy_id
                          AND nvl(pp.is_group_flag, 0) <> 1
                          AND polr.brief = 'Страхователь'
                          AND pcnt.policy_id = pp.policy_id
                          AND pcnt.contact_policy_role_id = polr.id
                          AND c.contact_id = pcnt.contact_id
                          AND c.contact_id = cn.contact_id
                          AND (pp.version_num = 1 OR EXISTS
                               (SELECT NULL
                                  FROM ins.p_pol_addendum_type padt
                                      ,ins.t_addendum_type     tat
                                 WHERE padt.p_policy_id = pp.policy_id
                                   AND padt.t_addendum_type_id = tat.t_addendum_type_id
                                   AND tat.brief IN ('FEE_INCREASE'
                                                    ,'COVER_ADDING'
                                                    ,'CLOSE_FIN_WEEKEND'
                                                    ,'POLICY_FROM_PAYED'
                                                    ,'RECOVER_MAIN'))))
    LOOP
    
      p_holder_name := cur_parm_b.holder_name;
      p_dep_name    := cur_parm_b.dep_name;
      p_insurer_age := cur_parm_b.cn_age;
    
      FOR cur_lim_b IN (SELECT /*+ NO_MERGE(t) */
                         MIN(pkg_tariff_calc.calc_coeff_val(tpct.brief, t_number_type(group_limit, age))) limit_sum
                        ,peril_name
                        ,prog_name
                        ,group_risk
                        ,nvl(MAX(tpc_2.criteria_2), 0) min_age_limit
                        ,MIN(tpc.criteria_2) max_age_limit
                        
                          FROM (SELECT nvl(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT_REGION'
                                                                         ,t_number_type(dep.department_id
                                                                                       ,ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))
                                          ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_LIMIT_DEFAULT'
                                                                         ,t_number_type(ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))) group_limit
                                      ,nvl(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_REGION'
                                                                         ,t_number_type(dep.department_id
                                                                                       ,ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))
                                          ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_DEFAULT'
                                                                         ,t_number_type(ph.product_id
                                                                                       ,pl.id
                                                                                       ,opt.id
                                                                                       ,pr.id))) group_risk
                                      ,CASE
                                         WHEN MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12 < 1 THEN
                                          MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12
                                         ELSE
                                          trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth) / 12)
                                       END age
                                      ,pr.description peril_name
                                      ,pl.description prog_name
                                  FROM p_cover               pc
                                      ,t_prod_line_option    opt
                                      ,t_product_line        pl
                                      ,t_prod_line_opt_peril per
                                      ,t_peril               pr
                                      ,as_asset              a
                                      ,as_assured            ass
                                      ,p_policy_contact      pcnt
                                      ,t_contact_pol_role    polr
                                      ,contact               c
                                      ,cn_person             cn
                                      ,p_policy              pp
                                      ,ven_status_hist       sh
                                      ,p_pol_header          ph
                                      ,fund                  f
                                      ,ins.department        dep
                                 WHERE 1 = 1
                                   AND polr.brief = 'Страхователь'
                                   AND pcnt.policy_id = a.p_policy_id
                                   AND pcnt.contact_policy_role_id = polr.id
                                   AND c.contact_id = pcnt.contact_id
                                      
                                   AND pr.id IN (SELECT pr.id
                                                   FROM p_cover               pc
                                                       ,t_prod_line_option    opt
                                                       ,t_product_line        pl
                                                       ,t_prod_line_opt_peril per
                                                       ,t_peril               pr
                                                       ,as_asset              a
                                                       ,as_assured            ass
                                                       ,p_policy              pp
                                                       ,ven_status_hist       sh
                                                  WHERE pc.t_prod_line_option_id = opt.id
                                                    AND sh.status_hist_id = pc.status_hist_id
                                                    AND sh.brief != 'DELETED'
                                                    AND opt.product_line_id = pl.id
                                                    AND per.product_line_option_id = opt.id
                                                    AND per.peril_id = pr.id
                                                    AND pc.as_asset_id = a.as_asset_id
                                                    AND a.p_policy_id = pp.policy_id
                                                    AND ass.as_assured_id = a.as_asset_id
                                                    AND pp.policy_id = par_policy_id)
                                      
                                   AND c.contact_id = cur_parm_b.contact_id
                                   AND pc.t_prod_line_option_id = opt.id
                                   AND sh.status_hist_id = pc.status_hist_id
                                   AND dep.department_id =
                                       (SELECT dep1.department_id
                                          FROM ins.p_policy_agent_doc     pad
                                              ,ins.ven_ag_contract_header agh
                                              ,ins.ag_contract            ag
                                              ,ins.department             dep1
                                         WHERE pad.policy_header_id = ph.policy_header_id
                                           AND agh.ag_contract_header_id = pad.ag_contract_header_id
                                           AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) =
                                               'CURRENT'
                                           AND rownum = 1 /*старые агенты привязаны как хотишь*/
                                           AND agh.last_ver_id = ag.ag_contract_id
                                           AND ag.agency_id = dep1.department_id)
                                   AND sh.brief != 'DELETED'
                                   AND opt.product_line_id = pl.id
                                   AND per.product_line_option_id = opt.id
                                   AND per.peril_id = pr.id
                                   AND pc.as_asset_id = a.as_asset_id
                                   AND a.p_policy_id = pp.policy_id
                                   AND pp.pol_header_id = ph.policy_header_id
                                   AND ph.fund_id = f.fund_id
                                   AND pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
                                   AND ass.as_assured_id = a.as_asset_id
                                   AND cn.contact_id = c.contact_id
                                   AND doc.get_doc_status_name(pkg_policy.get_last_version(ph.policy_header_id)
                                                              ,to_date('31.12.2999', 'dd.mm.yyyy')) NOT IN
                                       ('Завершен'
                                       ,'Готовится к расторжению'
                                       ,'Расторгнут'
                                       ,'Отменен'
                                       ,'Приостановлен'
                                       ,'К прекращению'
                                       ,'К прекращению. Готов для проверки'
                                       ,'К прекращению. Проверен'
                                       ,'Прекращен'
                                       ,'Прекращен. Запрос реквизитов'
                                       , --Чирков/159374: Доработка - контроль агрегации/
                                        'Прекращен. Реквизиты получены'
                                       , --Чирков/159374: Доработка - контроль агрегации/
                                        'Прекращен.К выплате' --Чирков/159374: Доработка - контроль агрегации/
                                        )
                                   AND pl.description IN
                                       ('Защита страховых взносов'
                                       ,'Защита страховых взносов рассчитанная по основной программе'
                                       ,'Защита страховых взносов расчитанная по основной программе')) t
                              ,t_prod_coef tpc
                              ,t_prod_coef_type tpct
                              ,t_prod_coef tpc_2
                         WHERE 1 = 1
                           AND tpc.t_prod_coef_type_id = tpct.t_prod_coef_type_id
                           AND tpc_2.t_prod_coef_type_id = tpct.t_prod_coef_type_id
                           AND tpc.criteria_1 = t.group_limit
                           AND tpc_2.criteria_1(+) = t.group_limit
                           AND tpct.brief = CASE
                                 WHEN EXISTS (SELECT NULL
                                         FROM t_prod_coef      tpc1
                                             ,t_prod_coef_type tpct1
                                        WHERE tpct1.brief = 'FIND_LIMIT_FOR_GROUP_REGION'
                                          AND tpc1.t_prod_coef_type_id = tpct1.t_prod_coef_type_id
                                          AND tpc1.criteria_1 = t.group_limit) THEN
                                  'FIND_LIMIT_FOR_GROUP_REGION'
                                 ELSE
                                  'FIND_LIMIT_FOR_GROUP_DEFAULT'
                               END
                           AND tpc.criteria_2 >= t.age
                           AND tpc_2.criteria_2 < t.age
                         GROUP BY (tpct.brief, t.age, t.peril_name, t.prog_name, t.group_risk))
      LOOP
      
        SELECT nvl(SUM(pc.ins_amount * (
                       
                        CASE
                          WHEN f.brief = 'USD' THEN
                           (CASE
                             WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 30 THEN
                              30
                             ELSE
                              acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                           END)
                          WHEN f.brief = 'EUR' THEN
                           (CASE
                             WHEN acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE) < 35 THEN
                              35
                             ELSE
                              acc_new.get_rate_by_brief('ЦБ', f.brief, SYSDATE)
                           END)
                          ELSE
                           1
                        END
                       
                       ))
                  ,0)
          INTO p_p_sum
          FROM p_cover               pc
              ,t_prod_line_option    opt
              ,t_product_line        pl
              ,t_prod_line_opt_peril per
              ,t_peril               pr
              ,as_asset              a
              ,as_assured            ass
              ,p_policy_contact      pcnt
              ,t_contact_pol_role    polr
              ,contact               c
              ,cn_person             cn
              ,p_policy              pp
              ,ven_status_hist       sh
              ,p_pol_header          ph
              ,fund                  f
              ,department            dep
         WHERE 1 = 1
           AND polr.brief = 'Страхователь'
           AND pcnt.policy_id = a.p_policy_id
           AND pcnt.contact_policy_role_id = polr.id
           AND c.contact_id = pcnt.contact_id
              
           AND c.contact_id = cur_parm_b.contact_id
           AND pc.t_prod_line_option_id = opt.id
           AND sh.status_hist_id = pc.status_hist_id
           AND sh.brief != 'DELETED'
           AND opt.product_line_id = pl.id
           AND per.product_line_option_id = opt.id
           AND per.peril_id = pr.id
           AND pc.as_asset_id = a.as_asset_id
           AND a.p_policy_id = pp.policy_id
           AND pp.pol_header_id = ph.policy_header_id
           AND ph.fund_id = f.fund_id
           AND pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
           AND ass.as_assured_id = a.as_asset_id
           AND cn.contact_id = c.contact_id
           AND dep.department_id =
               (SELECT dep1.department_id
                  FROM p_policy_agent_doc     pad
                      ,ven_ag_contract_header agh
                      ,ag_contract            ag
                      ,department             dep1
                 WHERE pad.policy_header_id = ph.policy_header_id
                   AND agh.ag_contract_header_id = pad.ag_contract_header_id
                   AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND rownum = 1 /*старые агенты привязаны как хотишь*/
                   AND agh.last_ver_id = ag.ag_contract_id
                   AND ag.agency_id = dep1.department_id)
           AND nvl(pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_REGION'
                                                 ,t_number_type(dep.department_id
                                                               ,ph.product_id
                                                               ,pl.id
                                                               ,opt.id
                                                               ,pr.id))
                  ,pkg_tariff_calc.calc_coeff_val('FIND_GROUP_FOR_PRODUCT_DEFAULT'
                                                 ,t_number_type(ph.product_id, pl.id, opt.id, pr.id))) =
               cur_lim_b.group_risk
              --and pp.policy_id <> par_policy_id
           AND doc.get_doc_status_name(pkg_policy.get_last_version(ph.policy_header_id)
                                      ,to_date('31.12.2999', 'dd.mm.yyyy')) NOT IN
               ('Завершен'
               ,'Готовится к расторжению'
               ,'Расторгнут'
               ,'Отменен'
               ,'Приостановлен'
               ,'К прекращению'
               ,'К прекращению. Готов для проверки'
               ,'К прекращению. Проверен'
               ,'Прекращен'
               ,'Прекращен. Запрос реквизитов'
               , --Чирков/159374: Доработка - контроль агрегации/
                'Прекращен. Реквизиты получены'
               , --Чирков/159374: Доработка - контроль агрегации/
                'Прекращен.К выплате' --Чирков/159374: Доработка - контроль агрегации/
                );
        p_p_progr       := cur_lim_b.prog_name;
        p_sum_limit     := cur_lim_b.limit_sum;
        p_min_limit_age := cur_lim_b.min_age_limit;
        p_max_limit_age := cur_lim_b.max_age_limit;
      
        IF p_p_sum > cur_lim_b.limit_sum
        THEN
          RAISE no_standart_holder;
        END IF;
      
      END LOOP;
    
    END LOOP;
  
  EXCEPTION
    WHEN no_standart_insurer THEN
      DECLARE
        str VARCHAR2(20);
      BEGIN
        IF MOD(p_min_limit_age, 1) = 0
           OR p_min_limit_age > 1
        THEN
          str := to_char(p_min_limit_age);
        ELSE
          str := TRIM(to_char(p_min_limit_age, '0.9'));
        END IF;
        raise_application_error(-20001
                               ,'Для Застрахованного ' || p_insurer_name || ' (' || p_insurer_age ||
                                ' лет) возрастом от (' || str || ') до (' || p_max_limit_age ||
                                ') лет лимит страховой суммы (' || ROUND(p_p_sum, 2) ||
                                ') по программе (' || p_p_progr || ') установлен на уровне (' ||
                                p_sum_limit ||
                                '). Возможен перевод договора только в статус "Нестандартный".');
      END;
      --                              'Страховая сумма по программе '||p_p_progr||' в договорах клиента '||p_insurer_name||' составляет '||p_p_sum||' рублей - что превышает допустимый лимит в размере '||p_sum_limit||' рублей для агентства '||p_dep_name||'.');
    WHEN no_standart_holder THEN
      DECLARE
        str VARCHAR2(20);
      BEGIN
        IF MOD(p_min_limit_age, 1) = 0
           OR p_min_limit_age > 1
        THEN
          str := to_char(p_min_limit_age);
        ELSE
          str := TRIM(to_char(p_min_limit_age, '0.9'));
        END IF;
        raise_application_error(-20001
                               ,'Для Страхователя ' || p_holder_name || ' (' || p_insurer_age ||
                                ' лет) возрастом от (' || str || ') до (' || p_max_limit_age ||
                                ') лет лимит страховой суммы (' || ROUND(p_p_sum, 2) ||
                                ') по программе (' || p_p_progr || ') установлен на уровне (' ||
                                p_sum_limit ||
                                '). Возможен перевод договора только в статус "Нестандартный".');
      END;
      --                              'Страховая сумма по программе '||p_p_progr||' в договорах клиента '||p_holder_name||' составляет '||round(p_p_sum,2)||' рублей - что превышает допустимый лимит в размере '||p_sum_limit||' рублей для агентства '||p_dep_name||'.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END limit_agregation_for_region;

  /*
    Байтин А.
    Проверки по программе Забота для Почты России
    --
    ДС. Проверки по программе Забота для Почты России. Переход: Проект - Новый
  */
  PROCEDURE check_zabota_post(par_policy_id NUMBER) IS
    v_product_brief    t_product.brief%TYPE;
    v_ins_amount       p_cover.ins_amount%TYPE;
    v_cnt              NUMBER(1);
    v_fee_payment_term p_policy.fee_payment_term%TYPE;
  BEGIN
    -- Проверка продукта
    SELECT pr.brief
      INTO v_product_brief
      FROM p_pol_header ph
          ,t_product    pr
     WHERE ph.last_ver_id = par_policy_id
       AND ph.product_id = pr.product_id;
  
    IF v_product_brief IN ('ZabotaPost_Single', 'ZabotaPost_Regular')
    THEN
      -- Сумма по одному договору должна быть 5000
      BEGIN
        SELECT nvl(pc.ins_amount, 0)
          INTO v_ins_amount
          FROM as_asset se
              ,p_cover  pc
         WHERE se.p_policy_id = par_policy_id
           AND se.as_asset_id = pc.as_asset_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001, 'Не найдено ни одного риска!');
        WHEN too_many_rows THEN
          raise_application_error(-20001
                                 ,'У данного продукта не должно быть более одного риска!');
      END;
      IF v_ins_amount != 5000
      THEN
        raise_application_error(-20001
                               ,'Сумма по договору должна быть 5000 рублей!');
      END IF;
      -- Количество действующих договоров не должно превышать 5
      SELECT COUNT(1)
        INTO v_cnt
        FROM v_pol_issuer   pi
            ,document       dc
            ,doc_status_ref dsr
            ,p_pol_header   ph
       WHERE pi.contact_id IN
             (SELECT pi_.contact_id FROM v_pol_issuer pi_ WHERE pi_.policy_id = par_policy_id)
         AND pi.policy_id = ph.last_ver_id
         AND ph.product_id IN
             (SELECT pr.product_id
                FROM t_product pr
               WHERE pr.brief IN ('ZabotaPost_Single', 'ZabotaPost_Regular'))
         AND pi.policy_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief NOT IN ('CANCEL', 'STOPED', 'QUIT');
      IF v_cnt > 5
      THEN
        raise_application_error(-20001
                               ,'Количество договоров по программе "Забота для Почты России" для данного застрахованного не должно первышать 5 штук!');
      END IF;
      -- Срок уплаты взносов 5 лет
      SELECT nvl(pp.fee_payment_term, 0)
        INTO v_fee_payment_term
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
      IF v_fee_payment_term != 5
      THEN
        raise_application_error(-20001
                               ,'Срок уплаты взносов для программы "Забота для Почты России" должен быть 5 лет!');
      END IF;
    END IF;
  END check_zabota_post;

  /* Процедура осуществляет проверку для продуктов Локо банк при переходе версии ДС <Проект> -> <Новый>
  * @autor Чирков В.Ю.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_cr99(par_policy_id NUMBER) IS
    v_sum        NUMBER;
    v_pr_brief   t_product.brief%TYPE;
    v_start_date DATE;
  BEGIN
    --Чирков 222214 
    SELECT pr.brief
          ,ph.start_date
      INTO v_pr_brief
          ,v_start_date
      FROM ins.p_pol_header ph
          ,t_product        pr
          ,ins.p_policy     pp
     WHERE ph.product_id = pr.product_id
       AND ph.policy_header_id = pp.pol_header_id
          --
       AND pp.policy_id = par_policy_id;
  
    IF v_pr_brief IN ('CR99_1', 'CR99_2', 'CR99_3', 'CR99_4')
    THEN
      SELECT MAX(aa.ins_amount * acc.get_cross_rate_by_brief(1, f.brief, 'RUR', ph.start_date) -- предусматриваем если договор валютный
                 )
        INTO v_sum
        FROM p_policy     pp
            ,as_asset     aa
            ,status_hist  sh
            ,p_pol_header ph
            ,t_product    pr
            ,fund         f
       WHERE pp.policy_id = par_policy_id
         AND aa.p_policy_id = pp.policy_id
         AND sh.status_hist_id = aa.status_hist_id
         AND sh.status_hist_id IN (1, 2)
         AND ph.policy_header_id = pp.pol_header_id
         AND pr.product_id = ph.product_id
         AND f.fund_id = ph.fund_id;
    
      IF v_sum > 1500000
         AND v_pr_brief = 'CR99_1'
      THEN
        raise_application_error('-20000'
                               ,'Страховая сумма ' || v_sum ||
                                ' для данного продукта не может быть более 1500000 рублей на дату начала действия ДС ' ||
                                v_start_date);
      ELSIF v_sum > 1500000
            AND v_pr_brief = 'CR99_2'
      THEN
        raise_application_error('-20000'
                               ,'Страховая сумма ' || v_sum ||
                                ' для данного продукта не может быть более 1500000 рублей на дату начала действия ДС ' ||
                                v_start_date);
      ELSIF v_sum > 30000
            AND v_pr_brief = 'CR99_3'
      THEN
        raise_application_error('-20000'
                               ,'Страховая сумма ' || v_sum ||
                                ' для данного продукта не может быть более 30000 рублей на дату начала действия ДС ' ||
                                v_start_date);
      ELSIF v_sum > 100000
            AND v_pr_brief = 'CR99_4'
      THEN
        raise_application_error('-20000'
                               ,'Страховая сумма ' || v_sum ||
                                ' для данного продукта не может быть более 100000 рублей на дату начала действия ДС ' ||
                                v_start_date);
      END IF;
    END IF;
  END check_cr99;

  /* Процедура осуществляет проверку для продуктов Защита 163/164 при переходе версии ДС <Проект> -> <Новый>
  * @autor Капля П.С.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_acc163_acc64(par_policy_id NUMBER) IS
    v_sum          NUMBER;
    v_pr_brief     t_product.brief%TYPE;
    v_payment_term t_payment_terms.brief%TYPE;
    v_fund_brief   fund.brief%TYPE;
  BEGIN
  
    SELECT pr.brief
      INTO v_pr_brief
      FROM p_policy     pp
          ,p_pol_header ph
          ,t_product    pr
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pr.product_id = ph.product_id;
  
    IF v_pr_brief IN ('ACC163', 'ACC164')
    THEN
      SELECT SUM(aa.fee) * acc_new.get_rate_by_brief('ЦБ', f.brief, ph.start_date)
            ,pt.brief
            ,f.brief
        INTO v_sum
            ,v_payment_term
            ,v_fund_brief
        FROM p_policy        pp
            ,as_asset        aa
            ,status_hist     sh
            ,p_pol_header    ph
            ,fund            f
            ,t_payment_terms pt
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pp.policy_id = aa.p_policy_id
         AND ph.fund_id = f.fund_id
         AND sh.status_hist_id = aa.status_hist_id
         AND sh.status_hist_id IN (1, 2)
         AND pp.payment_term_id = pt.id
       GROUP BY pt.brief
               ,f.brief
               ,ph.start_date;
    
      IF (v_payment_term = 'Единовременно')
      THEN
        IF (v_fund_brief = 'RUR' AND v_sum < 2500)
        THEN
          raise_application_error('-20000'
                                 ,'Страховая премия ' || v_sum ||
                                  ' для данного продукта не может быть менее 2500 рублей при единовременной форме оплаты. Возможен перевод договора только в статус "Нестандартный"');
        ELSIF (v_fund_brief = 'USD' AND v_sum < 83)
        THEN
          raise_application_error('-20000'
                                 ,'Страховая премия ' || v_sum ||
                                  ' для данного продукта не может быть менее 83 долларов при единовременной форме оплаты. Возможен перевод договора только в статус "Нестандартный"');
        ELSIF (v_fund_brief = 'EURO' AND v_sum < 58)
        THEN
          raise_application_error('-20000'
                                 ,'Страховая премия ' || v_sum ||
                                  ' для данного продукта не может быть менее 58 евро при единовременной форме оплаты. Возможен перевод договора только в статус "Нестандартный"');
        END IF;
      ELSIF (v_payment_term = 'MONTHLY')
      THEN
        IF (v_fund_brief = 'RUR' AND v_sum < 500)
        THEN
          raise_application_error('-20000'
                                 ,'Страховая премия ' || v_sum ||
                                  ' для данного продукта не может быть менее 500 рублей при единовременной форме оплаты. Возможен перевод договора только в статус "Нестандартный"');
        ELSIF (v_fund_brief = 'USD' AND v_sum < 16)
        THEN
          raise_application_error('-20000'
                                 ,'Страховая премия ' || v_sum ||
                                  ' для данного продукта не может быть менее 16 долларов при единовременной форме оплаты. Возможен перевод договора только в статус "Нестандартный"');
        ELSIF (v_fund_brief = 'EURO' AND v_sum < 12)
        THEN
          raise_application_error('-20000'
                                 ,'Страховая премия ' || v_sum ||
                                  ' для данного продукта не может быть менее 12 евро при единовременной форме оплаты. Возможен перевод договора только в статус "Нестандартный"');
        END IF;
      END IF;
    
      FOR rec IN (SELECT trunc(MONTHS_BETWEEN(SYSDATE, cn.date_of_birth)) age
                        ,c.ins_amount * acc_new.get_rate_by_brief('ЦБ', f.brief, NULL) ins_amount
                    FROM p_policy           pp
                        ,p_pol_header       ph
                        ,t_product          p
                        ,as_asset           aa
                        ,as_assured         aas
                        ,status_hist        sh
                        ,cn_person          cn
                        ,p_cover            c
                        ,t_prod_line_option plo
                        ,t_product_line     pl
                        ,fund               f
                   WHERE pp.policy_id = par_policy_id
                     AND pp.pol_header_id = ph.policy_header_id
                     AND ph.product_id = p.product_id
                     AND p.brief = 'ACC163'
                     AND ph.fund_id = f.fund_id
                     AND pp.policy_id = aa.p_policy_id
                     AND sh.status_hist_id = aa.status_hist_id
                     AND sh.status_hist_id IN (1, 2)
                     AND aa.as_asset_id = aas.as_assured_id
                     AND aas.assured_contact_id = cn.contact_id
                     AND c.as_asset_id = aa.as_asset_id
                     AND c.t_prod_line_option_id = plo.id
                     AND plo.product_line_id = pl.id
                     AND pl.description = 'СмертьЗастрахованного в результате несчастного случая') -- смерт НС
      LOOP
        IF (rec.age BETWEEN 6 AND (17 * 12 + 11))
           AND rec.ins_amount > 500000
        THEN
          IF rec.age < 1
          THEN
            raise_application_error('-20000'
                                   ,'Для Застрахованного (' || rec.age ||
                                    ' месяцев) возрастом от 6 месяцев до 17 лет лимит страховой суммы (' ||
                                    rec.ins_amount ||
                                    ') установлен на уровне 500 000 рублей. Возможен перевод договора только в статус "Нестандартный"');
          ELSE
            raise_application_error('-20000'
                                   ,'Для Застрахованного (' || trunc(rec.age / 12) ||
                                    ' лет) возрастом от 6 месяцев до 17 лет лимит страховой суммы (' ||
                                    rec.ins_amount ||
                                    ') установлен на уровне 500 000 рублей. Возможен перевод договора только в статус "Нестандартный"');
          END IF;
        ELSIF (trunc(rec.age / 12) BETWEEN 18 AND 44)
              AND rec.ins_amount > 1500000
        THEN
          raise_application_error('-20000'
                                 ,'Для Застрахованного (' || trunc(rec.age / 12) ||
                                  'лет ) возрастом от 18 до 44 лет лимит страховой суммы (' ||
                                  rec.ins_amount ||
                                  ') установлен на уровне 1 500 000 рублей. Возможен перевод договора только в статус "Нестандартный"');
        ELSIF (trunc(rec.age / 12) BETWEEN 45 AND 64)
              AND rec.ins_amount > 750000
        THEN
          raise_application_error('-20000'
                                 ,'Для Застрахованного (' || trunc(rec.age / 12) ||
                                  'лет ) возрастом от 45 до 64 лет лимит страховой суммы (' ||
                                  rec.ins_amount ||
                                  ') установлен на уровне 750 000 рублей. Возможен перевод договора только в статус "Нестандартный"');
        END IF;
      END LOOP;
    END IF;
  END check_acc163_acc64;

  /* Процедура осуществляет проверку для продуктов:
  * <Приоритет Инвест (единовременный) Сбербанк>
  * <Приоритет Инвест (регулярный) Сбербанк>
  * при переходе версии ДС <Проект> -> <Новый>
  * @autor Чирков В.Ю.
  * @param par_policy_id - версия ДС
  */
  PROCEDURE check_priority_invest(par_policy_id NUMBER) IS
    v_sum        NUMBER;
    v_pr_brief   t_product.brief%TYPE;
    v_start_date DATE;
    v_ver_num    NUMBER;
  
    v_agressive_plus NUMBER; --Агрессивная плюс
    v_balance        NUMBER; --Сбалансированная
    v_agressive      NUMBER; --Агрессивная
    v_conservative   NUMBER; --Консервативная
  BEGIN
    SELECT pr.brief
          ,pp.version_num
      INTO v_pr_brief
          ,v_ver_num
      FROM p_pol_header ph
          ,p_policy     pp
          ,t_product    pr
     WHERE ph.policy_header_id = pp.pol_header_id
       AND pr.product_id = ph.product_id
       AND pp.policy_id = par_policy_id;
    --ПРОВЕРКА ПРОДУКТА
    IF v_pr_brief IN ('Priority_Invest(lump)', 'Priority_Invest(regular)')
       AND v_ver_num = 1
    THEN
      --ПРОВЕРКА СТРАХОВОЙ ПРЕМИИ
      SELECT MIN(aa.ins_amount * acc.get_cross_rate_by_brief(1, f.brief, 'RUR', ph.start_date) -- предусматриваем если договор валютный
                 )
            ,ph.start_date
        INTO v_sum
            ,v_start_date
        FROM p_policy     pp
            ,as_asset     aa
            ,status_hist  sh
            ,p_pol_header ph
            ,t_product    pr
            ,fund         f
       WHERE pp.policy_id = par_policy_id
         AND aa.p_policy_id = pp.policy_id
         AND sh.status_hist_id = aa.status_hist_id
         AND sh.status_hist_id IN (1, 2)
         AND ph.policy_header_id = pp.pol_header_id
         AND pr.product_id = ph.product_id
         AND f.fund_id = ph.fund_id
       GROUP BY pr.brief
               ,ph.start_date;
    
      IF v_sum < 300000
         AND v_pr_brief = 'Priority_Invest(lump)'
      THEN
        raise_application_error('-20000'
                               ,'Минимальная годовая страховая премия  ' || v_sum ||
                                ' для данного продукта не может быть менее 300 000 рублей на дату начала действия ДС ' ||
                                v_start_date);
      ELSIF v_sum < 100000
            AND v_pr_brief = 'Priority_Invest(regular)'
      THEN
        raise_application_error('-20000'
                               ,'Минимальная годовая страховая премия ' || v_sum ||
                                ' для данного продукта не может быть менее 100 000 рублей на дату начала действия ДС ' ||
                                v_start_date);
      END IF;
      --ПРОВЕРКА РАСПРЕДЕЛЕНИЯ ПРЕМИИ
      v_agressive_plus := 0;
      v_balance        := 0;
      v_agressive      := 0;
      v_conservative   := 0;
      FOR rec IN (SELECT pc.premium
                        ,pl.description
                        ,pr.brief
                        ,SUM(pc.premium) over() total_premium
                    FROM p_policy           pp
                        ,as_asset           aa
                        ,status_hist        sh
                        ,p_pol_header       ph
                        ,t_product          pr
                        ,p_cover            pc
                        ,t_product_line     pl
                        ,t_prod_line_option plo
                   WHERE pp.policy_id = par_policy_id
                     AND aa.p_policy_id = pp.policy_id
                     AND sh.status_hist_id = aa.status_hist_id
                     AND sh.status_hist_id IN (1, 2)
                     AND ph.policy_header_id = pp.pol_header_id
                     AND pr.product_id = ph.product_id
                     AND pc.as_asset_id = aa.as_asset_id
                     AND plo.id = pc.t_prod_line_option_id
                     AND pl.id = plo.product_line_id
                     AND pl.description != 'Административные издержки')
      LOOP
        IF rec.description = 'Агрессивная плюс'
        THEN
          v_agressive_plus := nvl(ROUND((rec.premium / rec.total_premium) * 100, 2), 0);
        ELSIF rec.description = 'Сбалансированная'
        THEN
          v_balance := nvl(ROUND((rec.premium / rec.total_premium) * 100, 2), 0);
        ELSIF rec.description = 'Агрессивная'
        THEN
          v_agressive := nvl(ROUND((rec.premium / rec.total_premium) * 100, 2), 0);
        ELSIF rec.description = 'Консервативная'
        THEN
          v_conservative := nvl(ROUND((rec.premium / rec.total_premium) * 100, 2), 0);
        END IF;
      END LOOP;
    
      IF v_pr_brief = 'Priority_Invest(lump)'
      THEN
        IF v_agressive_plus = 0
           AND v_agressive = 10
           AND v_balance = 90
        THEN
          NULL;
        ELSE
          raise_application_error('-20000'
                                 ,'Распределение премии для продукта "Приоритет Инвест (единовременный) Сбербанк" для 1-ой версии ДС должно быть:
                     Агрессивная плюс = 0%, Агрессивная = 10%, Сбалансированная = 90%. В данном же договоре распределение:
                     Агрессивная плюс = ' || v_agressive_plus ||
                                  ', Агрессивная = ' || v_agressive || ' , Сбалансированная = ' ||
                                  v_balance);
        END IF;
      END IF;
      IF v_pr_brief = 'Priority_Invest(regular)'
      THEN
        IF ((v_agressive = 80 AND v_balance = 10 AND v_conservative = 10) OR
           (v_agressive = 10 AND v_balance = 80 AND v_conservative = 10) OR
           (v_agressive = 10 AND v_balance = 10 AND v_conservative = 80))
        THEN
          NULL;
        ELSE
          raise_application_error('-20000'
                                 ,'Неверное распределение премии для продукта "Приоритет Инвест (регулярный) Сбербанк" для 1-ой версии ДС
                   . В данном же договоре распределение:
                     Агрессивная = ' || v_agressive ||
                                  ' , Сбалансированная = ' || v_balance || ', Консервативная = ' ||
                                  v_conservative);
        END IF;
      END IF;
    
    END IF;
  END check_priority_invest;

  /**/
  PROCEDURE check_admcost(par_policy_id NUMBER) IS
    proc_name VARCHAR2(35) := 'Check_AdmCost';
    no_standart EXCEPTION;
    is_inv    NUMBER;
    is_end    NUMBER;
    is_fam    NUMBER;
    exist_adm NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO is_end
      FROM ins.p_policy        pp
          ,ins.p_pol_header    ph
          ,ins.t_product       prod
          ,ins.t_payment_terms trm
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND ph.product_id = prod.product_id
       AND prod.brief IN ('END', 'END_2', 'CHI', 'CHI_2', 'PEPR', 'PEPR_2', 'TERM', 'TERM_2')
       AND pp.payment_term_id = trm.id
       AND trm.description != 'Ежемесячно';
  
    SELECT COUNT(*)
      INTO is_fam
      FROM ins.p_policy        pp
          ,ins.p_pol_header    ph
          ,ins.t_product       prod
          ,ins.t_payment_terms trm
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND ph.product_id = prod.product_id
       AND prod.brief IN ('Family_Dep', 'Family_Dep_2011')
       AND pp.payment_term_id = trm.id
       AND trm.description NOT IN ('Ежемесячно', 'Ежеквартально');
  
    SELECT COUNT(*)
      INTO is_inv
      FROM ins.p_policy        pp
          ,ins.p_pol_header    ph
          ,ins.t_product       prod
          ,ins.t_payment_terms trm
     WHERE pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND ph.product_id = prod.product_id
       AND pp.payment_term_id = trm.id
       AND ((trm.description = 'Ежегодно' AND prod.brief IN ('Investor', 'InvestorPlus')) OR
           (trm.description = 'Единовременно' AND prod.brief = 'INVESTOR_LUMP'));
  
    IF (is_inv != 0 OR is_end != 0 OR is_fam != 0)
    THEN
    
      SELECT COUNT(*)
        INTO exist_adm
        FROM ins.p_policy           pol
            ,ins.as_asset           a
            ,ins.p_cover            pc
            ,ins.t_prod_line_option opt
       WHERE pol.policy_id = par_policy_id
         AND a.p_policy_id = pol.policy_id
         AND a.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = opt.id
         AND opt.description = 'Административные издержки';
    
      IF exist_adm = 0
      THEN
        RAISE no_standart;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_standart THEN
      raise_application_error(-20001
                             ,'Административные издержки не подключены. Исправьте. Переход в статус Новый невозможен.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
    
  END check_admcost;
  /**/
  PROCEDURE check_investorplus(par_policy_id NUMBER) IS
    p_all_sum NUMBER;
    proc_name VARCHAR2(35) := 'check_INVESTORPLUS';
    no_role_policy EXCEPTION;
    no_role_cover  EXCEPTION;
    no_sum_check   EXCEPTION;
    p_inv NUMBER;
  BEGIN
  
    BEGIN
      SELECT decode(upper(prod.brief), 'INVESTORPLUS', 1, 0)
        INTO p_inv
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    prod
       WHERE pp.policy_id = par_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND ph.product_id = prod.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_inv := 0;
    END;
  
    IF p_inv = 1
    THEN
    
      BEGIN
        SELECT nvl(SUM(nvl(pc.premium, 0)), 0)
          INTO p_all_sum
          FROM p_policy           pp
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
              ,t_product_line     pl
         WHERE pp.policy_id = par_policy_id
           AND pp.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id
           AND opt.product_line_id = pl.id
           AND pl.description NOT IN
               ('Административные издержки'
               ,'Административные издержки на восстановление');
      EXCEPTION
        WHEN no_data_found THEN
          p_all_sum := 0;
      END;
    
      IF p_all_sum < 50000
      THEN
        RAISE no_role_policy;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_role_policy THEN
      raise_application_error(-20001
                             ,'Общий страховой взнос по продукту Инвестор Плюс менее 50 000 рублей. Перевод в статус Новый невозможен.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
    
  END check_investorplus;

  /**/
  --Заявка 226474. Изместьев
  --10.04.2013
  PROCEDURE check_acc164_status(par_policy_id NUMBER) IS
    proc_name VARCHAR2(20) := 'АСС164_status';
    forbidden EXCEPTION;
    v_is_express NUMBER := 0;
  BEGIN
    SELECT tp.product_id
      INTO v_is_express
      FROM ins.ven_t_product    tp
          ,ins.ven_p_pol_header ph
          ,ins.ven_p_policy     p
     WHERE p.policy_id = par_policy_id
       AND ph.policy_header_id = p.pol_header_id
       AND tp.product_id = ph.product_id
       AND tp.brief = 'ACC164';
    RAISE forbidden;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN forbidden THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Продукт Защита 164 не может быть переведен из статуса Активный в Договор подписан.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END check_acc164_status;

  FUNCTION check_acc167_programs(par_policy_id NUMBER) RETURN NUMBER IS
    v_count  NUMBER;
    v_result NUMBER := 1;
  BEGIN
    FOR rec IN (SELECT aa.as_asset_id FROM as_asset aa WHERE aa.p_policy_id = par_policy_id)
    LOOP
      SELECT COUNT(*) INTO v_count FROM p_cover pc WHERE pc.as_asset_id = rec.as_asset_id;
      IF v_count = 4
         OR v_count = 1
      THEN
        v_result := 0;
      END IF;
    END LOOP;
    RETURN v_result;
  END check_acc167_programs;

  FUNCTION check_acc168_programs(par_policy_id NUMBER) RETURN NUMBER IS
    v_count  NUMBER;
    v_result NUMBER := 1;
  BEGIN
    FOR rec IN (SELECT aa.as_asset_id FROM as_asset aa WHERE aa.p_policy_id = par_policy_id)
    LOOP
      SELECT COUNT(*) INTO v_count FROM p_cover pc WHERE pc.as_asset_id = rec.as_asset_id;
      IF v_count = 3
         OR v_count = 1
      THEN
        v_result := 0;
      END IF;
    END LOOP;
    RETURN v_result;
  END check_acc168_programs;
  FUNCTION check_acc168_assured_age(par_policy_id NUMBER) RETURN NUMBER IS
    v_result NUMBER := 1;
    v_age    NUMBER;
  BEGIN
    SELECT MAX(FLOOR(MONTHS_BETWEEN(ph.start_date, c.date_of_birth) / 12))
      INTO v_age
      FROM p_pol_header ph
          ,p_policy     pp
          ,as_asset     aa
          ,as_assured   aas
          ,cn_person    c
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND aa.p_policy_id = pp.policy_id
       AND aas.as_assured_id = aa.as_asset_id
       AND aas.assured_contact_id = c.contact_id;
  
    IF v_age > 17
    THEN
      v_result := 0;
    ELSE
      v_result := 1;
    END IF;
  
    RETURN v_result;
  
  END check_acc168_assured_age;

  FUNCTION check_oncology(par_policy_id NUMBER) RETURN NUMBER IS
    vc_oncology_prod_line_brief CONSTANT VARCHAR2(15) := 'FEMALE_ONCOLOGY';
    v_policy_form_short_name    t_policy_form.t_policy_form_short_name%TYPE;
    v_oncology_prod_line_exists BOOLEAN;
    v_count                     NUMBER;
  BEGIN
    SELECT pf.t_policy_form_short_name
      INTO v_policy_form_short_name
      FROM p_policy             pp
          ,t_policyform_product pfp
          ,t_policy_form        pf
     WHERE pp.policy_id = par_policy_id
       AND pp.t_product_conds_id = pfp.t_policyform_product_id
       AND pfp.t_policy_form_id = pf.t_policy_form_id;
  
    v_oncology_prod_line_exists := check_product_line_exists(par_policy_id              => par_policy_id
                                                            ,par_prod_line_option_brief => vc_oncology_prod_line_brief);
  
    IF NOT v_oncology_prod_line_exists
       OR v_policy_form_short_name IN ('Гармония, Семья, Дети, Будущее от 24.06.2013'
                                      ,'Подари жизнь  от 28.01.2014'
                                      ,'ПУ «Гармония жизни_2» от 03.12.2014')
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END check_oncology;
  PROCEDURE check_198_blood_pressure(par_policy_id NUMBER) IS
    v_exists_198 NUMBER;
    --    v_up_blood_pressure_a   NUMBER;
    --    v_low_blood_pressure_a  NUMBER;
    --    v_age                 NUMBER;
    v_up_blood_pressure_ai  NUMBER;
    v_low_blood_pressure_ai NUMBER;
    v_blood_is_null EXCEPTION;
    v_blood_limit   EXCEPTION;
    v_msg                 VARCHAR2(30) := '';
    v_up_blood_up_limit   NUMBER := 120;
    v_up_blood_low_limit  NUMBER := 90;
    v_low_blood_up_limit  NUMBER := 80;
    v_low_blood_low_limit NUMBER := 60;
  BEGIN
  
    SELECT COUNT(*)
      INTO v_exists_198
      FROM ins.p_policy             pol
          ,ins.t_policyform_product tpp
          ,ins.t_policy_form        tpf
     WHERE pol.policy_id = par_policy_id
       AND pol.t_product_conds_id = tpp.t_policyform_product_id
       AND tpp.t_policy_form_id = tpf.t_policy_form_id
       AND tpf.t_policy_form_short_name = 'Гармония, Семья, Дети, Будущее от 24.06.2013'
       AND pol.version_num = 1;
  
    IF v_exists_198 > 0
    THEN
    
      /*Застрахованный*/
      -- Пиядин А., 31.10.2013, 276866 Изменени _Дети 2 _АД_профессии_печатная форма
      -- Исключение проверки артериального давления ЗАСТРАХОВАННОГО
      /*
            SELECT aa.up_blood_pressure
              INTO v_up_blood_pressure_a
              FROM ins.p_policy       pp
                  ,ins.ven_as_assured aa
             WHERE pp.policy_id = aa.p_policy_id
               AND pp.policy_id = par_policy_id;
            SELECT aa.low_blood_pressure
              INTO v_low_blood_pressure_a
              FROM ins.p_policy       pp
                  ,ins.ven_as_assured aa
             WHERE pp.policy_id = aa.p_policy_id
               AND pp.policy_id = par_policy_id;
            SELECT MAX(FLOOR(MONTHS_BETWEEN(ph.start_date, c.date_of_birth) / 12))
              INTO v_age
              FROM ins.p_policy       pp
                  ,ins.ven_as_assured aa
                  ,ins.p_pol_header   ph
                  ,ins.cn_person      c
             WHERE pp.policy_id = aa.p_policy_id
               AND pp.policy_id = par_policy_id
               AND aa.assured_contact_id = c.contact_id
               AND pp.pol_header_id = ph.policy_header_id;
      */
      /*Страхователь*/
      SELECT ai.up_blood_pressure
        INTO v_up_blood_pressure_ai
        FROM ins.p_policy       pp
            ,ins.ven_as_insured ai
       WHERE pp.policy_id = ai.policy_id
         AND pp.policy_id = par_policy_id
         AND rownum = 1;
      SELECT ai.low_blood_pressure
        INTO v_low_blood_pressure_ai
        FROM ins.p_policy       pp
            ,ins.ven_as_insured ai
       WHERE pp.policy_id = ai.policy_id
         AND pp.policy_id = par_policy_id
         AND rownum = 1;
    
      IF /* 
                                                                                                                                                                                                                                                                                                                                                         (v_up_blood_pressure_a IS NULL AND v_age > 17)
                                                                                                                                                                                                                                                                                                                                                         OR (v_low_blood_pressure_a IS NULL AND v_age > 17)
                                                                                                                                                                                                                                                                                                                                                         OR */
       v_up_blood_pressure_ai IS NULL
       OR v_low_blood_pressure_ai IS NULL
      THEN
        RAISE v_blood_is_null;
      ELSE
      
        IF v_up_blood_pressure_ai > v_up_blood_up_limit
           OR v_up_blood_pressure_ai < v_up_blood_low_limit
           OR v_low_blood_pressure_ai > v_low_blood_up_limit
           OR v_low_blood_pressure_ai < v_low_blood_low_limit
        THEN
          v_msg := 'Страхователь';
          RAISE v_blood_limit;
        END IF;
      
        -- Пиядин А., 31.10.2013, 276866 Изменени _Дети 2 _АД_профессии_печатная форма
        -- Исключение проверки артериального давления ЗАСТРАХОВАННОГО
        /*        
                IF (v_up_blood_pressure_a IS NOT NULL AND v_low_blood_pressure_a IS NOT NULL)
                   AND (v_up_blood_pressure_a > v_up_blood_up_limit OR
                   v_up_blood_pressure_ai < v_up_blood_low_limit OR
                   v_low_blood_pressure_a > v_low_blood_up_limit OR
                   v_low_blood_pressure_ai < v_low_blood_low_limit)
                THEN
                  v_msg := 'Застрахованный';
                  RAISE v_blood_limit;
                END IF;
        */
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN v_blood_is_null THEN
      raise_application_error(-20001
                             ,'Заполните, пожалуйста, цифры артериального давления Cтрахователя - возможен перевод статуса только в статус "Нестандартный".');
    WHEN v_blood_limit THEN
      raise_application_error(-20001
                             ,'Цифры артериального давления (' || v_msg ||
                              ') не соответствуют стандартным условиям. Перевод только в статус "Нестандартный".');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении check_198_blood_pressure');
  END check_198_blood_pressure;
  /**/
  FUNCTION check_acc_172173_hosp_surge(par_policy_id NUMBER) RETURN NUMBER IS
    v_count  NUMBER;
    v_result NUMBER;
  BEGIN
    --Госпитализация НС без Хирургии НС, Госпитализация НСиБ без Хирургия НСиБ не может быть
    WITH cover AS
     (SELECT /*+ inline */
       pc.as_asset_id
      ,plo.brief product_line_brief
        FROM p_cover            pc
            ,t_prod_line_option plo
       WHERE pc.t_prod_line_option_id = plo.id)
    SELECT COUNT(*)
      INTO v_count
      FROM as_asset aa
     WHERE aa.p_policy_id = par_policy_id
       AND ((EXISTS (SELECT NULL
                       FROM cover t
                      WHERE t.as_asset_id = aa.as_asset_id
                        AND product_line_brief = 'H') AND NOT EXISTS
            (SELECT NULL
                FROM cover t
               WHERE t.as_asset_id = aa.as_asset_id
                 AND product_line_brief = 'Surg_ACC')) OR
           (EXISTS (SELECT NULL
                       FROM cover t
                      WHERE t.as_asset_id = aa.as_asset_id
                        AND product_line_brief = 'H_any') AND NOT EXISTS
            (SELECT NULL
                FROM cover t
               WHERE t.as_asset_id = aa.as_asset_id
                 AND product_line_brief = 'Surg')));
    IF v_count = 0
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END check_acc_172173_hosp_surge;

  /** Процедура осуществляет 'Контроль льготного периода' на переходе статуса ДС
  *  по заявке 268793: Исключение контроля ЛП для доп.версий
  *  @autor - Чирков
  *  @param par_p_policy_id - Версия ДС
  */
  PROCEDURE privilege_period_control(par_p_policy_id NUMBER) AS
    v_min_pol_id    NUMBER;
    v_klp_func_id   NUMBER;
    v_product_id    NUMBER;
    v_check_product INT;
    RESULT          NUMBER;
    v_msg           VARCHAR2(4000);
  BEGIN
    --функцию 'Контроль льготного периода' применяем только 
    --для версии с минимальным номером в статусе отличном от "Отменен"    
    BEGIN
      SELECT policy_id
        INTO v_min_pol_id
        FROM (SELECT pp_.policy_id
                FROM ins.ven_p_policy   pp
                    ,ins.doc_status_ref dsr
                    ,ins.p_policy       pp_
               WHERE pp.pol_header_id = pp_.pol_header_id
                 AND pp.policy_id = par_p_policy_id
                 AND pp.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CANCEL'
               ORDER BY pp_.version_num) x
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_min_pol_id := NULL;
    END;
  
    IF par_p_policy_id = v_min_pol_id
       AND v_min_pol_id IS NOT NULL
    THEN
      --определяем id функции 'Контроль льготного периода'
      SELECT pct.t_prod_coef_type_id
            ,' Замечание по функции контроля ' || '"' || pct.name || '"'
        INTO v_klp_func_id
            ,v_msg
        FROM t_prod_coef_type pct
       WHERE pct.name = 'Контроль льготного периода';
    
      --Контроль льготного периода должен осуществляться только для тех продуктов,
      --которые находятся в данной функции контроля. 
      --Проверяем наличие продукта по версии содним из продуктов, в функции контроля по
      --аргументу 1 <Страховой продукт> 
    
      SELECT ph.product_id
        INTO v_product_id
        FROM ins.p_pol_header ph
            ,ins.p_policy     pp
       WHERE ph.policy_header_id = pp.pol_header_id
         AND pp.policy_id = par_p_policy_id;
    
      SELECT COUNT(1)
        INTO v_check_product
        FROM dual
       WHERE EXISTS (SELECT 1
                FROM t_prod_coef_type pct
                    ,t_prod_coef      tpc
               WHERE 1 = 1
                 AND pct.t_prod_coef_type_id = tpc.t_prod_coef_type_id
                 AND pct.t_prod_coef_type_id = v_klp_func_id
                 AND tpc.criteria_1 = v_product_id
              
              );
      IF v_check_product = 1
      THEN
        --вызовыем функцию 'Контроль льготного периода'      
        RESULT := pkg_tariff_calc.calc_fun(v_klp_func_id, ent.id_by_brief('P_POLICY'), par_p_policy_id);
      
        --если результат функции не равен 1, значит проверка не пройдена и выводим сообщение об ошибке
        IF RESULT != 1
        THEN
          raise_application_error(-20000, v_msg);
        END IF;
      
        dbms_output.put_line(RESULT);
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, v_msg);
  END privilege_period_control;

  /**/

  FUNCTION strong_start_age_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    v_elder_assured_wrong_age BOOLEAN := FALSE;
    v_young_assured_wrong_age BOOLEAN := FALSE;
  
    v_elder_assured_total_count PLS_INTEGER;
    v_young_assured_total_count PLS_INTEGER;
  
    v_product_brief t_product.brief%TYPE;
  
    v_checked NUMBER(1);
  
    FUNCTION get_total_assured_count
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_asset_type_brief t_asset_type.brief%TYPE
    ) RETURN PLS_INTEGER IS
      v_total_count PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_total_count
        FROM as_asset       aa
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE aa.p_policy_id = par_policy_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND at.brief = par_asset_type_brief;
    
      RETURN v_total_count;
    
    END get_total_assured_count;
  
    FUNCTION get_assured_wrong_age_exists
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_asset_type_brief t_asset_type.brief%TYPE
     ,par_min_age          NUMBER
     ,par_max_age          NUMBER
    ) RETURN BOOLEAN IS
      v_exists NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM as_asset       aa
                    ,as_assured     aas
                    ,cn_person      cp
                    ,p_asset_header ah
                    ,t_asset_type   at
                    ,p_policy       pp
                    ,p_pol_header   ph
               WHERE aa.p_policy_id = par_policy_id
                 AND aa.p_asset_header_id = ah.p_asset_header_id
                 AND ah.t_asset_type_id = at.t_asset_type_id
                 AND at.brief = par_asset_type_brief
                 AND aa.p_policy_id = pp.policy_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND aa.as_asset_id = aas.as_assured_id
                 AND aas.assured_contact_id = cp.contact_id
                 AND NOT FLOOR(MONTHS_BETWEEN(ph.start_date, cp.date_of_birth) / 12) BETWEEN
                      par_min_age AND par_max_age);
      RETURN v_exists > 0;
    END get_assured_wrong_age_exists;
  
    FUNCTION get_product_brief(par_policy_id p_policy.policy_id%TYPE) RETURN t_product.brief%TYPE IS
      v_product_brief t_product.brief%TYPE;
    BEGIN
      SELECT p.brief
        INTO v_product_brief
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    p
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = p.product_id;
    
      RETURN v_product_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить продукт по версии договора страхования в процедуре strong_start_age_check');
    END get_product_brief;
  BEGIN
    /* Получаем пролное число застрахованных взрослых*/
    v_elder_assured_total_count := get_total_assured_count(par_policy_id        => par_policy_id
                                                          ,par_asset_type_brief => 'ASSET_PERSON');
  
    IF v_elder_assured_total_count > 0
    THEN
      /* Проверяем наличие застрахованных взрослых не в возрасте 18-64 на дату начала договора страхования */
      v_elder_assured_wrong_age := get_assured_wrong_age_exists(par_policy_id        => par_policy_id
                                                               ,par_asset_type_brief => 'ASSET_PERSON'
                                                               ,par_min_age          => 18
                                                               ,par_max_age          => 64);
    END IF;
  
    /* Получаем полное число застрахованных детей */
    v_product_brief := get_product_brief(par_policy_id => par_policy_id);
    IF v_product_brief LIKE ('STRONG_START%2')
    THEN
    
      v_young_assured_total_count := get_total_assured_count(par_policy_id        => par_policy_id
                                                            ,par_asset_type_brief => 'ASSET_PERSON_CHILD');
    
      IF v_young_assured_total_count > 0
      THEN
        /* Проверяем наличие застрахованных детей не в возрасте 1-17 на дату начала договора страхования */
        v_young_assured_wrong_age := get_assured_wrong_age_exists(par_policy_id        => par_policy_id
                                                                 ,par_asset_type_brief => 'ASSET_PERSON_CHILD'
                                                                 ,par_min_age          => 1
                                                                 ,par_max_age          => 17);
      END IF;
    END IF;
  
    IF ((v_product_brief LIKE ('STRONG_START%1') AND v_elder_assured_total_count = 1) OR
       (v_product_brief LIKE ('STRONG_START%2') AND v_elder_assured_total_count BETWEEN 1 AND 2 AND
       v_young_assured_total_count BETWEEN 0 AND 2))
       AND NOT v_elder_assured_wrong_age
       AND NOT v_young_assured_wrong_age
    THEN
      v_checked := 1;
    ELSE
      v_checked := 0;
    END IF;
  
    RETURN v_checked;
  
  END strong_start_age_check;

  /* Контроль величины базовой суммы по продуктам серии Уверенный старт */
  FUNCTION strong_start_check_base_sum(par_policy_id NUMBER) RETURN NUMBER IS
    v_check    NUMBER;
    v_base_sum p_policy.base_sum%TYPE;
  
    /* Определяем базовую сумму как сумму страховых сумм по основной программе взрослых застрахованных */
    FUNCTION get_base_sum(par_policy_id NUMBER) RETURN NUMBER IS
      v_base_sum NUMBER;
    BEGIN
      -- Пытаемся определить базовую сумму по полю на версии
      SELECT base_sum INTO v_base_sum FROM p_policy pp WHERE pp.policy_id = par_policy_id;
    
      -- Если не получилось, пытаемся определить по застрахованным
      IF v_base_sum IS NULL
      THEN
        SELECT nvl(SUM(pc.ins_amount), 0)
          INTO v_base_sum
          FROM as_asset            aa
              ,p_cover             pc
              ,p_asset_header      ah
              ,t_asset_type        at
              ,t_prod_line_option  plo
              ,t_product_line      pl
              ,t_product_line_type plt
         WHERE aa.p_policy_id = par_policy_id
           AND aa.as_asset_id = pc.as_asset_id
           AND aa.p_asset_header_id = ah.p_asset_header_id
           AND ah.t_asset_type_id = at.t_asset_type_id
           AND at.brief = 'ASSET_PERSON'
           AND pc.t_prod_line_option_id = plo.id
           AND plo.product_line_id = pl.id
           AND pl.product_line_type_id = plt.product_line_type_id
           AND plt.brief = 'RECOMMENDED';
      END IF;
    
      RETURN v_base_sum;
    
    END get_base_sum;
  BEGIN
  
    v_base_sum := get_base_sum(par_policy_id => par_policy_id);
  
    IF v_base_sum IN ( /*250000,*/ 500000, 1000000, 2000000)
    THEN
      v_check := 1;
    ELSE
      v_check := 0;
    END IF;
  
    RETURN v_check;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось найти версию договора страхования по ИД');
  END strong_start_check_base_sum;

  /*
    Капля П.
    Контроль по продукту. 
    Проверка ПУ для Гармонии Жизни_2, Дети_2, Будущее_2, Семья_2
  */
  FUNCTION check_life_policy_form(par_policy_id NUMBER) RETURN NUMBER IS
    vc_proc_name              CONSTANT pkg_trace.t_object_name := 'CHECK_LIFE_POLICY_FORM';
    vc_policy_form_short_name CONSTANT t_policy_form.t_policy_form_short_name%TYPE := 'Подари жизнь  от 28.01.2014';
    vc_present_life_plo_brief CONSTANT t_prod_line_option.brief%TYPE := 'PRESENT_LIFE';
    vc_ppjl_plo_brief         CONSTANT t_prod_line_option.brief%TYPE := 'PPJL'; -- Дожитие Страхователя до потери постоянной работы по независящим от него причинам
  
    v_result                     NUMBER;
    v_present_life_exists        BOOLEAN;
    v_ppjl_exists                BOOLEAN;
    v_cur_policy_form_short_name t_policy_form.t_policy_form_short_name%TYPE;
  
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_POLICY_ID'
                          ,par_trace_var_value => par_policy_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_cur_policy_form_short_name := get_policy_form_short_name(par_policy_id => par_policy_id);
  
    v_present_life_exists := check_product_line_exists(par_policy_id              => par_policy_id
                                                      ,par_prod_line_option_brief => vc_present_life_plo_brief);
  
    v_ppjl_exists := check_product_line_exists(par_policy_id              => par_policy_id
                                              ,par_prod_line_option_brief => vc_ppjl_plo_brief);
  
    -- Подари жизнь может быть подключена при наличии ПУ 'Подари жизнь  от 28.01.2014'
    -- По ПУ 'Подари жизнь  от 28.01.2014' не может быть подключено дожитие
    IF (v_present_life_exists AND v_cur_policy_form_short_name != vc_policy_form_short_name)
       OR (v_ppjl_exists AND v_cur_policy_form_short_name = vc_policy_form_short_name)
    THEN
      v_result := 0;
    ELSE
      v_result := 1;
    END IF;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN v_result;
  
  END check_life_policy_form;

  /*
    Проверка 
  */
  FUNCTION family_protection_age_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    v_elder_assured_wrong_age BOOLEAN := FALSE;
    v_young_assured_wrong_age BOOLEAN := FALSE;
  
    v_elder_assured_total_count PLS_INTEGER;
    v_young_assured_total_count PLS_INTEGER;
  
    v_product_brief t_product.brief%TYPE;
  
    FUNCTION get_total_assured_count
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_asset_type_brief t_asset_type.brief%TYPE
    ) RETURN PLS_INTEGER IS
      v_total_count PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_total_count
        FROM as_asset       aa
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE aa.p_policy_id = par_policy_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND at.brief = par_asset_type_brief;
    
      RETURN v_total_count;
    
    END get_total_assured_count;
  
    FUNCTION get_assured_wrong_age_exists
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_asset_type_brief t_asset_type.brief%TYPE
     ,par_min_age          NUMBER
     ,par_max_age          NUMBER
    ) RETURN BOOLEAN IS
      v_exists NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM as_asset       aa
                    ,as_assured     aas
                    ,cn_person      cp
                    ,p_asset_header ah
                    ,t_asset_type   at
                    ,p_policy       pp
                    ,p_pol_header   ph
               WHERE aa.p_policy_id = par_policy_id
                 AND aa.p_asset_header_id = ah.p_asset_header_id
                 AND ah.t_asset_type_id = at.t_asset_type_id
                 AND at.brief = par_asset_type_brief
                 AND aa.p_policy_id = pp.policy_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND aa.as_asset_id = aas.as_assured_id
                 AND aas.assured_contact_id = cp.contact_id
                 AND NOT FLOOR(MONTHS_BETWEEN(ph.start_date, cp.date_of_birth) / 12) BETWEEN
                      par_min_age AND par_max_age);
      RETURN v_exists > 0;
    END get_assured_wrong_age_exists;
  
    FUNCTION get_product_brief(par_policy_id p_policy.policy_id%TYPE) RETURN t_product.brief%TYPE IS
      v_product_brief t_product.brief%TYPE;
    BEGIN
      SELECT p.brief
        INTO v_product_brief
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    p
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = p.product_id;
    
      RETURN v_product_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить продукт по версии договора страхования в процедуре strong_start_age_check');
    END get_product_brief;
  BEGIN
    /* Получаем пролное число застрахованных взрослых*/
    v_elder_assured_total_count := get_total_assured_count(par_policy_id        => par_policy_id
                                                          ,par_asset_type_brief => 'ASSET_PERSON');
  
    IF v_elder_assured_total_count > 0
    THEN
      /* Проверяем наличие застрахованных взрослых не в возрасте 18-64 на дату начала договора страхования */
      v_elder_assured_wrong_age := get_assured_wrong_age_exists(par_policy_id        => par_policy_id
                                                               ,par_asset_type_brief => 'ASSET_PERSON'
                                                               ,par_min_age          => 18
                                                               ,par_max_age          => 64);
    END IF;
  
    v_young_assured_total_count := get_total_assured_count(par_policy_id        => par_policy_id
                                                          ,par_asset_type_brief => 'ASSET_PERSON_CHILD');
  
    IF v_young_assured_total_count > 0
    THEN
      /* Проверяем наличие застрахованных детей не в возрасте 1-17 на дату начала договора страхования */
      v_young_assured_wrong_age := get_assured_wrong_age_exists(par_policy_id        => par_policy_id
                                                               ,par_asset_type_brief => 'ASSET_PERSON_CHILD'
                                                               ,par_min_age          => 1
                                                               ,par_max_age          => 17);
    END IF;
  
    IF v_elder_assured_total_count = 0
    THEN
      gv_error_text := 'В договоре олжен быть хотя бы один взрослый застрахованный';
      RAISE ex_product_control_exception;
    ELSIF v_elder_assured_total_count > 2
    THEN
      gv_error_text := 'Взрослых застрахованных в договоре может быть не более двух';
      RAISE ex_product_control_exception;
    ELSIF v_elder_assured_wrong_age
    THEN
      gv_error_text := 'Возраст застрахованного взрослого должен быть от 18 до 64 лет на дату начала действия договора';
      RAISE ex_product_control_exception;
    ELSIF v_young_assured_wrong_age
    THEN
      gv_error_text := 'Возраст застрахованного ребенка должен быть от 1 до 17 лет на дату начала действия договора';
      RAISE ex_product_control_exception;
    END IF;
  
    RETURN 1;
  
  END family_protection_age_check;

  /*
    Контроль годовой премии по договорам Platinum Life
    Преимя должна быть кратна 25000 при ежегодной форме оплаты и 2250 при ежемесячной форме оплаты
  */
  FUNCTION platinum_life_premium_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    v_payment_terms_brief t_payment_terms.brief%TYPE;
    v_policy_premium      p_policy.premium%TYPE;
    v_number_of_payments  t_payment_terms.number_of_payments%TYPE;
    v_result              NUMBER(1);
    v_product_brief       t_product.brief%TYPE;
  BEGIN
    SELECT pt.brief
          ,pt.number_of_payments
          ,pp.premium
          ,p.brief
      INTO v_payment_terms_brief
          ,v_number_of_payments
          ,v_policy_premium
          ,v_product_brief
      FROM p_policy        pp
          ,p_pol_header    ph
          ,t_product       p
          ,t_payment_terms pt
     WHERE pp.policy_id = par_policy_id
       AND pp.payment_term_id = pt.id
       AND ph.policy_header_id = pp.pol_header_id
       AND p.product_id = ph.product_id;
  
    IF v_product_brief = 'Platinum_Life_2'
    THEN
      SELECT SUM(nvl(pc.premium, 0))
        INTO v_policy_premium
        FROM p_cover            pc
            ,as_asset           aa
            ,t_prod_line_option plo
            ,t_product_line     pl
       WHERE aa.p_policy_id = par_policy_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND plo.brief NOT LIKE '%DD_SURGERY';
    END IF;
  
    IF v_payment_terms_brief = 'EVERY_YEAR'
    THEN
      IF MOD(v_policy_premium, 25000) != 0
      THEN
        raise_product_control_ex('Суммарная премия по договору при ежегодной форме оплаты должна быть кратна 25000');
      END IF;
    ELSIF v_payment_terms_brief = 'MONTHLY'
    THEN
      IF v_policy_premium / v_number_of_payments < 4500
      THEN
        raise_product_control_ex('Суммарная премия по договору при ежемесячной форме оплаты должна быть не менее 4500');
      ELSIF MOD(v_policy_premium / v_number_of_payments, 2250) != 0
      THEN
        raise_product_control_ex('Суммарная премия по договору при ежемесячной форме оплаты должна быть кратна 2250');
      END IF;
    END IF;
    RETURN 1;
  END platinum_life_premium_check;

  FUNCTION check_assured_duplicates(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    v_duplicates_exists NUMBER;
  BEGIN
    SELECT CASE COUNT(*)
             WHEN 0 THEN
              1
             ELSE
              0
           END
      INTO v_duplicates_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM as_assured au
                  ,as_asset   a
             WHERE a.p_policy_id = par_policy_id
               AND a.as_asset_id = au.as_assured_id
             GROUP BY au.assured_contact_id
            HAVING COUNT(*) > 1);
    RETURN v_duplicates_exists;
  END check_assured_duplicates;

  -- Процедура проверки срока действия ДС для ренкап.
  -- Срок действия ДС должен быть между 5.5 и 60.5 мес.
  -- 363797: Перевод статуса договоров
  -- Гаргонов Д. А.

  FUNCTION check_policy_period_rencap(par_policy_id ins.p_policy.policy_id%TYPE) RETURN NUMBER IS
    RESULT          NUMBER := 0;
    v_policy_period NUMBER;
  BEGIN
    SELECT trunc(MONTHS_BETWEEN(trunc(p.end_date), h.start_date)) + CASE
             WHEN (trunc(p.end_date) -
                  ADD_MONTHS(h.start_date, trunc(MONTHS_BETWEEN(trunc(p.end_date), h.start_date)))) < 15 THEN
              0
             ELSE
              1
           END
      INTO v_policy_period
      FROM ins.p_policy     p
          ,ins.p_pol_header h
     WHERE p.pol_header_id = h.policy_header_id
       AND p.policy_id = par_policy_id;
  
    IF v_policy_period BETWEEN 6 AND 60
    THEN
      RESULT := 1;
    ELSE
      RESULT := 0;
    END IF;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise_custom('Не найден договор страхования по ID версии.');
    
  END check_policy_period_rencap;

  -- Контроль количества/возраста застрахованных
  -- для продуктов Уверенный старт 2014
  -- Доброхотова И., ноябрь, 2014
  -- 374307 FW настройка продукта Уверенный старт
  FUNCTION strong_start_new_age_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    v_elder_assured_wrong_age BOOLEAN := FALSE;
    v_young_assured_wrong_age BOOLEAN := FALSE;
  
    v_elder_assured_total_count PLS_INTEGER;
    v_young_assured_total_count PLS_INTEGER;
  
    v_product_brief t_product.brief%TYPE;
  
    RESULT NUMBER;
  
    FUNCTION get_total_assured_count
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_asset_type_brief t_asset_type.brief%TYPE
    ) RETURN PLS_INTEGER IS
      v_total_count PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_total_count
        FROM as_asset       aa
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE aa.p_policy_id = par_policy_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND at.brief = par_asset_type_brief;
    
      RETURN v_total_count;
    
    END get_total_assured_count;
  
    FUNCTION get_assured_wrong_age_exists
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_asset_type_brief t_asset_type.brief%TYPE
     ,par_min_age          NUMBER
     ,par_max_age          NUMBER
    ) RETURN BOOLEAN IS
      v_exists NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_exists
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM as_asset       aa
                    ,as_assured     aas
                    ,cn_person      cp
                    ,p_asset_header ah
                    ,t_asset_type   at
                    ,p_policy       pp
                    ,p_pol_header   ph
               WHERE aa.p_policy_id = par_policy_id
                 AND aa.p_asset_header_id = ah.p_asset_header_id
                 AND ah.t_asset_type_id = at.t_asset_type_id
                 AND at.brief = par_asset_type_brief
                 AND aa.p_policy_id = pp.policy_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND aa.as_asset_id = aas.as_assured_id
                 AND aas.assured_contact_id = cp.contact_id
                 AND NOT ((par_asset_type_brief = 'ASSET_PERSON_CHILD' AND
                      FLOOR(MONTHS_BETWEEN(ph.start_date, cp.date_of_birth) / 12) BETWEEN
                      par_min_age AND par_max_age) OR
                      (par_asset_type_brief = 'ASSET_PERSON' AND
                      FLOOR(MONTHS_BETWEEN(ph.start_date, cp.date_of_birth) / 12) >= par_min_age AND
                      FLOOR(MONTHS_BETWEEN(pp.end_date, cp.date_of_birth) / 12) <= par_max_age)));
      RETURN v_exists > 0;
    END get_assured_wrong_age_exists;
  
    FUNCTION get_product_brief(par_policy_id p_policy.policy_id%TYPE) RETURN t_product.brief%TYPE IS
      v_product_brief t_product.brief%TYPE;
    BEGIN
      SELECT p.brief
        INTO v_product_brief
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    p
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = p.product_id;
    
      RETURN v_product_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить продукт по версии договора страхования в процедуре strong_start_age_check');
    END get_product_brief;
  
    FUNCTION is_sigle_product(par_product_brief VARCHAR2) RETURN BOOLEAN IS
    BEGIN
      RETURN par_product_brief = 'STRONG_START_NEW' OR par_product_brief LIKE '%1';
    END;
  BEGIN
    v_product_brief := get_product_brief(par_policy_id);
  
    /* Получаем пролное число застрахованных взрослых*/
    v_elder_assured_total_count := get_total_assured_count(par_policy_id        => par_policy_id
                                                          ,par_asset_type_brief => 'ASSET_PERSON');
  
    IF v_elder_assured_total_count > 0
    THEN
      /* Проверяем наличие застрахованных взрослых не в возрасте 18-64 на дату начала договора страхования */
      v_elder_assured_wrong_age := get_assured_wrong_age_exists(par_policy_id        => par_policy_id
                                                               ,par_asset_type_brief => 'ASSET_PERSON'
                                                               ,par_min_age          => 18
                                                               ,par_max_age          => 64);
    END IF;
  
    IF NOT is_sigle_product(v_product_brief)
    THEN
      --семейный
      v_young_assured_total_count := get_total_assured_count(par_policy_id        => par_policy_id
                                                            ,par_asset_type_brief => 'ASSET_PERSON_CHILD');
    
      IF v_young_assured_total_count > 0
      THEN
        /* Проверяем наличие застрахованных детей не в возрасте 1-17 на дату начала договора страхования */
        v_young_assured_wrong_age := get_assured_wrong_age_exists(par_policy_id        => par_policy_id
                                                                 ,par_asset_type_brief => 'ASSET_PERSON_CHILD'
                                                                 ,par_min_age          => 1
                                                                 ,par_max_age          => 17);
      END IF;
    END IF;
  
    IF ((is_sigle_product(v_product_brief) AND v_elder_assured_total_count = 1) OR
       (NOT is_sigle_product(v_product_brief) AND
       v_elder_assured_total_count + v_young_assured_total_count >= 2 AND
       v_elder_assured_total_count BETWEEN 1 AND 2 AND v_young_assured_total_count BETWEEN 0 AND 2))
      
       AND NOT v_elder_assured_wrong_age
       AND NOT v_young_assured_wrong_age
    THEN
      RESULT := 1;
    ELSE
      RESULT := 0;
    END IF;
  
    RETURN RESULT;
  
  END strong_start_new_age_check;

  /**
  * Проверку на наличие более одного ДС со страховым продуктом типа  «ОПС+ (New)», «Линия защиты», «Защита экспресс» 
  * или «Защита экспресс детский» на один контакт (застрахованное лицо)
  *
  * Текст ошибки и сама ошибка формируется в теле проверки
  * @author Капля П.
  * @param par_policy_id - ИД версии договора страхования
  * @return - результат проверки
  */
  FUNCTION check_assured_has_policies(par_policy_id NUMBER) RETURN NUMBER IS
    v_policy_count        NUMBER;
    v_product_id          NUMBER;
    v_product_name        t_product.description%TYPE;
    v_product_category_id NUMBER;
    v_aggregated_string   tt_one_col;
    v_policies            VARCHAR2(2000);
  
    PROCEDURE get_product_info
    (
      par_policy_id    NUMBER
     ,par_product_id   OUT NUMBER
     ,par_product_name OUT VARCHAR2
    ) IS
      v_product_id t_product.product_id%TYPE;
    BEGIN
      SELECT p.product_id
            ,p.description
        INTO par_product_id
            ,par_product_name
        FROM p_policy     pp
            ,p_pol_header ph
            ,t_product    p
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = p.product_id;
    END get_product_info;
  BEGIN
    assert_deprecated(par_policy_id IS NULL
                     ,'ИД версии договора страхования должен быть заполнен');
    get_product_info(par_policy_id, v_product_id, v_product_name);
  
    v_product_category_id := pkg_product_category.get_product_category_id(par_category_type_brief => 'UK_POLICY_FOR_ASSURED'
                                                                         ,par_product_id          => v_product_id);
  
    WITH assureds AS
     (SELECT aas.assured_contact_id
        FROM as_asset   aa
            ,as_assured aas
       WHERE aa.p_policy_id = par_policy_id
         AND aa.status_hist_id != pkg_asset.status_hist_id_del
         AND aa.as_asset_id = aas.as_assured_id),
    cur_pol AS
     (SELECT pp.pol_header_id
            ,ph.start_date
            ,pp.end_date
        FROM p_policy     pp
            ,p_pol_header ph
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id)
    
    --383731 Григорьев Ю.А. Добавил статусы, поменял условие по датам и поставил вывод номеров договоров в ошибку
    SELECT /*+leading(t) use_nl(t, ph)*/
     pp.pol_num BULK COLLECT
      INTO v_aggregated_string
      FROM p_pol_header ph
          ,p_policy pp
          ,cur_pol cp
          ,(SELECT /*+dynamic_samplng(t 2)*/
             column_value AS product_id
              FROM TABLE(pkg_product_category.get_product_list(v_product_category_id)) t) t
     WHERE ph.policy_header_id != cp.pol_header_id
       AND ph.product_id = t.product_id
       AND ph.policy_id = pp.policy_id
       AND EXISTS (SELECT NULL
              FROM as_asset   aa
                  ,as_assured aas
             WHERE aa.p_policy_id = ph.policy_id
               AND aa.as_asset_id = aas.as_assured_id
               AND aa.status_hist_id != pkg_asset.status_hist_id_del
               AND aas.assured_contact_id IN (SELECT assured_contact_id FROM assureds))
       AND doc.get_last_doc_status_brief(ph.policy_id) NOT IN
           ('CANCEL'
           ,'STOPED'
           ,'PROJECT'
           ,'STOP'
           ,'QUIT'
           ,'TO_QUIT'
           ,'TO_QUIT_CHECK_READY'
           ,'TO_QUIT_CHECKED'
           ,'QUIT_REQ_QUERY'
           ,'QUIT_REQ_GET'
           ,'QUIT_TO_PAY'
           ,'READY_TO_CANCEL')
       AND (cp.start_date < pp.end_date AND cp.end_date >= ph.start_date);
  
    v_policies := pkg_utils.get_aggregated_string(par_table     => v_aggregated_string
                                                 ,par_separator => ',');
  
    IF v_aggregated_string.count > 0
    THEN
      raise_product_control_ex('На одного и того же застрахованного не может быть заведено более одного ДС с продуктом страхования «' ||
                               v_product_name ||
                               '». Необходимо выполнить ручной перевод статуса договора в Доработка агентом. Номера договоров: ' ||
                               v_policies);
    END IF;
  
    RETURN 1;
  END check_assured_has_policies;

  -- Контроль наличия программ Медицины без границ
  -- (программы МБГ должны либо быть обе, либо их не быть вообще)   
  -- 378726: Заявка на настройку продукта "Platinum Life"
  -- Доброхотова И., декабрь, 2014
  FUNCTION platinum_life_mbg_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    RESULT       NUMBER;
    v_dms_exists BOOLEAN;
    v_wop_exists BOOLEAN;
  BEGIN
    v_dms_exists := check_product_line_exists(par_policy_id, 'DMS_DD_SURGERY');
    v_wop_exists := check_product_line_exists(par_policy_id, 'WOP_DD_SURGERY');
    IF (v_dms_exists AND v_wop_exists)
       OR (NOT v_dms_exists AND NOT v_wop_exists)
    THEN
      RESULT := 1;
    ELSE
      RESULT := 0;
    END IF;
    RETURN RESULT;
  END platinum_life_mbg_check;

  -- Контроль обязательно подключения основных и обязательных программ 
  -- с учетом проверок на возможность подключения и контроля по покрытию
  -- 389610: Ошибки в b2b Брокера по программе "Platinum Life 2"
  -- Доброхотова И., январь, 2015  
  FUNCTION check_include_program(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    RESULT          NUMBER;
    v_cnt_product   NUMBER;
    v_cnt_policy    NUMBER;
    v_product_brief t_product.brief%TYPE;
  
    v_err_msg       VARCHAR2(4000);
    v_program_names VARCHAR2(4000);
  BEGIN
    SELECT p.brief
      INTO v_product_brief
      FROM p_policy     pp
          ,p_pol_header ph
          ,t_product    p
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND p.product_id = ph.product_id;
  
    FOR rec_ass IN (SELECT aa.as_asset_id
                          ,c.genitive fio
                      FROM as_asset   aa
                          ,as_assured aas
                          ,contact    c
                     WHERE aa.as_asset_id = aas.as_assured_id
                       AND c.contact_id = aas.assured_contact_id
                       AND aa.p_policy_id = par_policy_id)
    LOOP
      v_cnt_policy    := 0;
      v_cnt_product   := 0;
      v_program_names := NULL;
      FOR rec IN (SELECT pc.as_asset_id
                        ,pl.id prod_line_id
                        ,nvl(pl.public_description, pl.description) AS description
                        ,pc.t_prod_line_option_id policy_prod_line_id
                    FROM t_prod_line_option plo
                        ,t_product_line pl
                        ,v_prod_product_line ppl
                        ,t_product_line_type plt
                        ,(SELECT pc.t_prod_line_option_id
                                ,pc.ins_amount
                                ,pc.fee
                                ,aa.as_asset_id
                            FROM p_cover  pc
                                ,as_asset aa
                           WHERE aa.p_policy_id = par_policy_id
                             AND aa.as_asset_id = rec_ass.as_asset_id
                             AND aa.as_asset_id = pc.as_asset_id) pc
                   WHERE ppl.product_brief = v_product_brief
                     AND ppl.t_product_line_id = plo.product_line_id
                     AND ppl.t_product_line_id = pl.id
                     AND plo.id = pc.t_prod_line_option_id(+)
                     AND plt.product_line_type_id = pl.product_line_type_id
                     AND plt.brief IN ('RECOMMENDED', 'MANDATORY')
                   ORDER BY pl.sort_order)
      LOOP
        -- проверка зависимостей и предварительный контроль
        IF pkg_cover.check_dependences(p_asset_id     => rec_ass.as_asset_id
                                      ,p_prod_line_id => rec.prod_line_id
                                      ,err_msg        => v_err_msg) = 1
           AND
           pkg_cover_control.precreation_cover_control(par_asset_id        => rec_ass.as_asset_id
                                                      ,par_product_line_id => rec.prod_line_id) = 1
        THEN
          v_cnt_product := v_cnt_product + 1;
          IF v_program_names IS NOT NULL
          THEN
            v_program_names := v_program_names || ', ' || chr(10);
          END IF;
          v_program_names := v_program_names || '"' || rec.description || '"';
          IF rec.policy_prod_line_id IS NOT NULL
          THEN
            v_cnt_policy := v_cnt_policy + 1;
          END IF;
        END IF;
      END LOOP;
      IF v_cnt_policy <> v_cnt_product
      THEN
        raise_product_control_ex('Для застрахованного ' || rec_ass.fio ||
                                 ' должны быть обязательно выбраны программа(ы): ' || chr(10) ||
                                 v_program_names);
      END IF;
    END LOOP;
    RETURN 1;
  END check_include_program;

  -- Контроль наличия программ Достояния
  -- 384116 Достояние_ГПБ
  -- Доброхотова И., январь, 2015
  FUNCTION dostoyanie_program_check(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
    RESULT       NUMBER;
    v_dms_exists BOOLEAN;
    v_wop_exists BOOLEAN;
    v_h_dms      BOOLEAN;
    v_result     NUMBER;
  BEGIN
    IF check_product_line_exists(par_policy_id, 'Ins_life_to_date')
    THEN
      IF check_product_line_exists(par_policy_id, 'TERM_2')
         AND check_product_line_exists(par_policy_id, 'AD')
         AND check_product_line_exists(par_policy_id, 'AD_AVTO')
      THEN
        v_result := 1;
      ELSE
        v_result := 0;
      END IF;
    ELSIF check_product_line_exists(par_policy_id, 'END')
    THEN
      IF check_product_line_exists(par_policy_id, 'AD')
         AND check_product_line_exists(par_policy_id, 'AD_AVTO')
      THEN
        v_result := 1;
      ELSE
        v_result := 0;
      END IF;
    END IF;
  
    IF v_result = 1
    THEN
      -- МБГ либо все либо ни одной 
      v_dms_exists := check_product_line_exists(par_policy_id, 'DMS_DD_SURGERY');
      v_wop_exists := check_product_line_exists(par_policy_id, 'WOP_DD_SURGERY');
      v_h_dms      := check_product_line_exists(par_policy_id, 'H_DMS');
      IF (v_dms_exists AND v_wop_exists AND v_h_dms)
         OR (NOT v_dms_exists AND NOT v_wop_exists AND NOT v_h_dms)
      THEN
        v_result := 1;
      ELSE
        v_result := 0;
      END IF;
    END IF;
  
    RETURN v_result;
  END dostoyanie_program_check;

  -- Период страхования должен быть кратен году
  -- 373858 Дил банк настройка продукта 
  -- Доброхотова И., ноябрь, 2014  
  FUNCTION check_policy_period_year(par_policy_id NUMBER) RETURN NUMBER IS
    RESULT          NUMBER := 0;
    v_policy_period NUMBER;
  BEGIN
    SELECT MONTHS_BETWEEN(trunc(p.end_date) + 1, h.start_date)
      INTO v_policy_period
      FROM ins.p_policy     p
          ,ins.p_pol_header h
     WHERE p.pol_header_id = h.policy_header_id
       AND p.policy_id = par_policy_id;
  
    IF MOD(v_policy_period, 12) = 0
    THEN
      RESULT := 1;
    ELSE
      RESULT := 0;
    END IF;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise_custom('Не найден договор страхования по ID версии.');
    
  END check_policy_period_year;

  /**
  * Контроль величины базовой суммы для продукта Семейный депозит (Family_Dep_2014);
  * В случае ошибки вызывает ошибку контроля по продукту
  * @author Капля п.
  * @param par_base_sum - Базовая сумма по договору
  * @return 1 в случае успеха
  */
  FUNCTION family_dep_basesum_control(par_base_sum NUMBER) RETURN NUMBER IS
  BEGIN
    IF par_base_sum IS NULL
    THEN
      raise_product_control_ex('Базовая сумма должна быть указана.');
    ELSIF par_base_sum < 20000
    THEN
      raise_product_control_ex('Базовая сумма должна быть не менее 20 тыс. рублей.');
    ELSIF MOD(par_base_sum, 20000) != 0
    THEN
      raise_product_control_ex('Базовая сумма должна быть кратна 20 тыс. рублей.');
    END IF;
  
    RETURN 1;
  END family_dep_basesum_control;

END pkg_products_control;
/
