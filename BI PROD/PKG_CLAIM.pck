CREATE OR REPLACE PACKAGE pkg_claim IS

  /**
  * Работа с претензиями
  * @author Patsan O.
  */

  /**
   * Возвращает значение суммы по ущербу в валюте ущерба (претензия-> ущерб)
   * @author Ф.Ганичев
   * @param p_damage_id - id ущерба
   * @param value - сумма в валюте претензии
   * @return Сумма по ущербу в валюте ущерба
  */
  FUNCTION f_d
  (
    p_damage_id NUMBER
   ,VALUE       NUMBER
  ) RETURN NUMBER;

  /**
   * Возвращает значение суммы по ущербу в валюте претензии (ущерб-> претензия)
   * @author Ф.Ганичев
   * @param p_damage_id - id ущерба
   * @param value - сумма в валюте ущерба
   * @return Сумма по ущербу в валюте претензии
  */

  FUNCTION f_d2
  (
    p_damage_id NUMBER
   ,VALUE       NUMBER
  ) RETURN NUMBER;

  /**
  *  Рассчитывает итоговые суммы для последней версии претензии
  *  @author Ganichev F.
  * @param p_claim_header_id ИД заголовка претензии
  * @param p_declare_sum Заявленная сумма
  * @param p_damage_payment_sum Сумма страховых ущербов
  * @param p_add_expenses_noown_sum Сумма возмещаемых дополнительных ущербов
  * @param p_payment_sum Сумма к оплате
  * @param p_decline_sum Сумма отказа
  * @param p_add_expences_own_sum Сумма невозмещаемых дополнительных ущербов
  * @param p_deduct_sum Франшиза
  */
  PROCEDURE recalc_claim_head_paym_sums
  (
    p_claim_header_id        NUMBER
   ,p_declare_sum            OUT NUMBER
   ,p_damage_payment_sum     OUT NUMBER
   ,p_add_expenses_noown_sum OUT NUMBER
   ,p_payment_sum            OUT NUMBER
   ,p_decline_sum            OUT NUMBER
   ,p_add_expences_own_sum   OUT NUMBER
   ,p_deduct_sum             OUT NUMBER
  );
  /**
  *  Рассчитывает итоговые суммы для заданой версии претензии
  *  @author Ganichev F.
  * @param p_claim_id ИД версии претензии
  * @param p_declare_sum Заявленная сумма
  * @param p_damage_payment_sum Сумма страховых ущербов
  * @param p_add_expenses_noown_sum Сумма возмещаемых дополнительных ущербов
  * @param p_payment_sum Сумма к оплате
  * @param p_decline_sum Сумма отказа
  * @param p_add_expences_own_sum Сумма невозмещаемых дополнительных ущербов
  * @param p_deduct_sum Франшиза
  */
  PROCEDURE recalc_claim_paym_sums
  (
    p_claim_id               NUMBER
   ,p_declare_sum            OUT NUMBER
   ,p_damage_payment_sum     OUT NUMBER
   ,p_add_expenses_noown_sum OUT NUMBER
   ,p_payment_sum            OUT NUMBER
   ,p_decline_sum            OUT NUMBER
   ,p_add_expences_own_sum   OUT NUMBER
   ,p_deduct_sum             OUT NUMBER
   ,fl_no_update             IN NUMBER DEFAULT 0
  );

  /**
  * Возвращает номер претензии
  * @author Patsan O.
  * @param p_cl_head_id ИД заголовка претензии
  * @return Номер претензии
  */
  FUNCTION get_claim_num(p_cl_head_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Копирует версию убытка
  * @author Patsan O.
  * @param p_claim_id ИД копируемой версии
  * @return ИД новой версии
  */
  FUNCTION copy_claim_version(p_claim_id IN NUMBER) RETURN NUMBER;

  /**
  * Получение лимита ответственности
  * @author Patsan O.
  * @param p_damage_code ИД кода ущерба
  * @param par_cover  ИД покрытия
  * @return Лимит ответственности
  */
  FUNCTION get_lim_amount
  (
    p_damage_code IN NUMBER
   ,par_cover     IN NUMBER
   ,p_damage_id   NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получение суммы выплаты по ущербу в валюте претензии
  * @author Patsan O.
  * @param par_sum Заявленная сумма ущерба в валюте претензии
  * @param par_cover_id ИД страхового покрытия
  * @return Сумма к выплате
  */
  FUNCTION get_dam_pay_sum
  (
    par_sum      IN NUMBER
   ,par_cover_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получение суммы выплаты для заданной франшизы в валюте претензии
  * @author
  * @param par_sum Заявленная сумма ущерба в валюте претензии
  * @param par_cover_id ИД страхового покрытия
  * @param par_deduc Значение франшизы в валюте претензии
  * @return Сумма к выплате
  */
  FUNCTION get_dam_pay_sum_deduc
  (
    par_sum      IN NUMBER
   ,par_cover_id IN NUMBER
   ,par_deduc    IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получение суммы остатка по лимиту ответсвенности.
  * Остаток = Лимит ответственности - сумма ущербов по этому покрытию.
  * @author Denis Ivanov
  * @param p_damage_code ИД кода ущерба
  * @param par_cover ИД страхового покрытия
  * @return Сумма остатка по лимиту ответственности
  */
  FUNCTION get_lim_rest_amount
  (
    p_damage_code IN NUMBER
   ,par_cover     IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить куратора и подразделение для полиса в претензии
  * @author Patsan O.
  * @param par_product_id ИД продукта
  * @param par_department_id ИД подразделения
  * @param par_contact_id ИД контакта
  */
  PROCEDURE get_dept_person
  (
    par_policy_id     IN NUMBER
   ,par_department_id IN OUT NUMBER
   ,par_contact_id    IN OUT NUMBER
  );

  /**
  * Получить список ущербов по претензии
  * @author Alexander Kalabukhov
  * @param p_claim_id ИД претензии
  * @return Список ущербов через запятую
  */
  FUNCTION get_damage_list(p_c_claim_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Получить список рисков, наступивших в результате СС
  * @author Mirovich M.
  * @param p_claim_id ИД претензии
  * @return Список рисков через запятую
  */
  FUNCTION get_damage_risk_list(p_c_claim_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Dозвращает суммарный процент от страховой суммы по всем страховым убыткам
  * @author Mirovich M.
  * @param p_claim_id ИД претензии
  * @return процент
  */
  FUNCTION get_percent_sum(p_claim_id NUMBER) RETURN NUMBER;

  /**
  * Получить действуюшию версию претензии
  * @author Alexander Kalabukhov
  * @param p_c_claim_header_id ИД претензии
  * @return Список ущербов через запятую
  */
  FUNCTION get_curr_claim(p_c_claim_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Начисление претензии
  * @author Pavel Kiselev
  * @param p_claim_id - ИД претензии
  **/
  PROCEDURE claim_charge(p_claim_id IN NUMBER);

  /**
  * Генерация номера претензии
  * @author Filipp Ganichev
  * @param p_prod_id - ИД продукта
  **/
  FUNCTION get_claim_nr(p_prod_id IN NUMBER) RETURN NUMBER;

  /**
  * Количество убытков по договору
  * @author Балашов
  * @param p_pol_header_id ИД заголовка полиса
  * @param p_plo Программа
  * @return Количество убытков по договору
  */
  FUNCTION count_loss_by_prev
  (
    p_pol_header_id IN NUMBER
   ,p_plo           IN VARCHAR DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Убыточность по договору
  * @author Балашов
  * @param p_pol_header_id ИД заголовка полиса
  * @return Убыточность
  */
  FUNCTION unprofitableness(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Ранее заявленные убытки по договору на дату
  * @author Балашов
  * @param par_ph
  * @param par_dat
  * @return Количество убытков
  */
  FUNCTION get_declare_sum
  (
    par_ph  IN NUMBER
   ,par_dat IN DATE
  ) RETURN NUMBER;

  /**
   * Перерасчет значений франшизы и суммы выплаты для каждого ущерба претензии
   * @author Filipp Ganichev
   * @param p_claim_id - ИД претензии
   * @param p_cover_id - ИД покрытия, если не задано берется с претензии
  **/
  PROCEDURE recalc_claim_dam_sums
  (
    p_claim_id NUMBER
   ,p_cover_id NUMBER DEFAULT NULL
  );

  /**
  * Расчет заявленной суммы ущерба по % кода ущерба
  * @author Patsan O.
  * @param p_damage_id ИД ущерба
  * @return Заявленная сумму ущерба
  */
  FUNCTION damage_perc(p_damage_id IN NUMBER) RETURN NUMBER;

  /**
  * Расчет заявленной суммы ущерба по дням восстановления
  * @author Patsan O.
  * @param p_damage_id ИД ущерба
  * @return Заявленная сумму ущерба
  */
  FUNCTION damage_days(p_damage_id IN NUMBER) RETURN NUMBER;

  /**
  * Получение следующего номера претензии по страховому событию
  * @author Patsan O.
  * @param p_event_id ИД страхового события
  * @return Номер претензии
  */
  FUNCTION get_next_claim_header_num(p_event_id NUMBER) RETURN VARCHAR2;

  /**
  * Возвращает номер предыдущего дела по одному застрахованному
  * @author Mirovich M.
  * @param p_claim_id - ИД дела
  * @return Номер претензии
  */
  FUNCTION get_prev_claim_num(p_claim_id NUMBER) RETURN VARCHAR2;

  /**
   * Перерасчет значений франшизы и суммы выплаты для каждого ущерба претензии
   * только страховые ущербы
   * @author Oleg Patsan
   * @param p_claim_id - ИД претензии
   * @param p_cover_id - ИД покрытия, если не задано берется с претензии
  **/
  PROCEDURE recalc_claim_dam_sums_life
  (
    p_claim_id NUMBER
   ,p_cover_id NUMBER DEFAULT NULL
  );

  /**
  * Установить версию дела как активную для заголока дела
  * @author Alexander Marchuk
  * @param par_claim_id ИД версии дела
  */

  PROCEDURE set_self_as_active_version(par_claim_id IN NUMBER);

  /**
  * Установить версию предыдущего дела как активную для заголока дела
  * @author Alexander Marchuk
  * @param par_claim_id ИД версии дела
  */

  PROCEDURE set_previous_as_active_version(par_claim_id IN NUMBER);

  /**
  * Проверка на существование дел по версии договора страхования
  * если таковые имеются - вызывается исключение
  * @author Patsan Oleg
  * @param p_doc_id ИД версии полиса
  */
  PROCEDURE check_claim_on_policy(p_doc_id IN NUMBER);

  /**
  * Создание Распоряжений на взаимозачет и возврат по претензии
  * @author Patsan Oleg
  * @param p_doc_id ИД версии полиса
  */
  PROCEDURE create_payments(p_doc_id IN NUMBER);

  /**
  * Проведение Распоряжений на взаимозачет и возврат по претензии
  * @author Patsan Oleg
  * @param p_doc_id ИД версии полиса
  */
  PROCEDURE setoff_status(p_doc_id IN NUMBER);

  /**
  * Отзыв Распоряжений на взаимозачет и возврат по претензии
  * @author Patsan Oleg
  * @param p_doc_id ИД версии полиса
  */
  PROCEDURE setoff_cancel(p_doc_id IN NUMBER);

  /**
  * Удаление Распоряжений на взаимозачет и возврат по претензии
  * @author Patsan Oleg
  * @param p_doc_id ИД версии полиса
  */
  PROCEDURE setoff_delete(p_doc_id IN NUMBER);

  /**
  * Расчет лимита ответственности по убытку
  * @author Patsan Oleg
  * @param par_damage_code_id ИД кода ущерба
  * @param par_cover_id ИД покрытия
  * @param par_claim_id ИД версии убытка
  * @return Значение лимита
  */
  FUNCTION get_compensation_limit
  (
    par_damage_code_id IN NUMBER
   ,par_cover_id       IN NUMBER
   ,par_claim_id       IN NUMBER
  ) RETURN NUMBER;

  /**
   * Получение суммы выплат по всем ущербам данного покрытия во всех предыдущих претензиях
   * @author Pavel A. Mikushin
   * @param p_claim_id - ИД претензии
   * @param p_cover_id - ИД покрытия
  **/
  FUNCTION get_payed_cover_sum
  (
    p_claim_id NUMBER
   ,p_cover_id NUMBER
  ) RETURN NUMBER;

  FUNCTION get_epg_to_event
  (
    p_event_id   NUMBER
   ,p_num_event  VARCHAR2
   ,p_event_date DATE
   ,p_date_first DATE
   ,p_period     NUMBER
  ) RETURN DATE;
  FUNCTION get_min_num_event(p_event_id NUMBER) RETURN NUMBER;
  PROCEDURE contact_date_death(p_claim_id NUMBER);

  /**
   * процедура проверяет существование документа вида ППИ по версии дела
   * статус которых отличен от  "Анулирован" и поля "Номер реквеста" и "Дата выплаты" не заполнены
   * переводит ППИ из "Проведен" в "Аннулирован" если поля "Номер реквеста" и "Дата выплаты" не заполнены
   * Вызывается при смене статуса версии дела с "Проведен" на "Аннулирован"  
   * @author В. Чирков
   * @param p_claim_id - id версии претензии
  */
  PROCEDURE annulate_ppi(p_claim_id NUMBER);

  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  FUNCTION damage_decline_reason
  (
    par_p_cover_id NUMBER
   ,par_c_claim_id NUMBER
  ) RETURN VARCHAR2;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  FUNCTION ret_amount_active
  (
    p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  FUNCTION ret_amount_claim
  (
    p_event_id     NUMBER
   ,p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  FUNCTION ret_sod_claim(p_claim_header NUMBER) RETURN DATE;

  /* Процедура создает назначение платежа для Выплаты по ПС на переходе статусов Док добавлен->Новый 
  *
  *--299415: FW: назначение платежа
  * @autor Чирков
  * @param par_doc_id - документ выплата по ПС (PAYORDER)
  */
  PROCEDURE create_purpose4payorder(par_doc_id NUMBER);

  /* Определение назначение платежа для реквеста
  * по заявке 185449 доработка назначения платежа в BI и 1С   
  * @autor Чирков В.Ю. 
  */
  FUNCTION get_purpose4request
  (
    par_event_id NUMBER
   ,par_ppi_id   NUMBER
   ,par_peril_id NUMBER
  ) RETURN VARCHAR2;

  /*
    Байтин А.
    Перенесено из формы DISP_LIFE (DB_C_EVENT.KEY-CREREC)
  */
  PROCEDURE add_non_insurance_claims(par_c_event_id NUMBER);

  ---------------------------------------------------------------------------------------------------
  -- Author  : Гаргонов Д.А.
  -- Created : 17.01.2014
  -- Purpose : 315504 не верно отображается статус на диспетчерском пульте дело 14091
  -- Comment : Проверяет является ли последняя версия по делу активной.
  -- Param   : par_claim_id ИД версии дела

  -- Author  : Гаргонов Д.А.
  -- Created : 17.01.2014
  -- Purpose : 315504 не верно отображается статус на диспетчерском пульте дело 14091
  -- Comment : Проверяет является ли последняя версия по делу активной.
  -- Param   : par_claim_id ИД версии дела
  PROCEDURE check_active_ver_on_claim_head(par_claim_id IN NUMBER);

  -- Author  : Мизинов Г.В.
  -- Created : 25.09.2014
  -- Comment : Возвращает ID версии ДС по ID дел
  -- Param   : par_claim_id ИД версии дела
  FUNCTION get_policy_by_claim_id(par_claim_id ins.c_claim.c_claim_id%TYPE)
    RETURN ins.p_policy.policy_id%TYPE;
END pkg_claim;
/
CREATE OR REPLACE PACKAGE BODY pkg_claim IS

  FUNCTION is_addendum(p_c_claim_id NUMBER) RETURN NUMBER IS
    is_a NUMBER;
  BEGIN
    SELECT 1
      INTO is_a
      FROM dual
     WHERE 1 = 1
       AND p_c_claim_id IN (SELECT c_claim_id
                              FROM (SELECT c_claim_id
                                          ,rownum rn
                                      FROM (SELECT p.c_claim_id
                                              FROM ven_c_claim p
                                                  ,ven_c_claim p1
                                             WHERE 1 = 1
                                               AND p1.c_claim_id = p_c_claim_id
                                               AND p.c_claim_header_id = p1.c_claim_header_id
                                             ORDER BY p.seqno ASC))
                             WHERE rn > 1);
    --
    RETURN is_a;
    --
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  FUNCTION get_next_claim_header_num(p_event_id NUMBER) RETURN VARCHAR2 IS
    v_event_num  VARCHAR2(100);
    v_next_claim VARCHAR2(100);
  BEGIN
    SELECT num INTO v_event_num FROM document WHERE document_id = p_event_id;
  
    SELECT COUNT(*) + 1 INTO v_next_claim FROM c_claim_header WHERE c_event_id = p_event_id;
  
    RETURN v_event_num || '/' || v_next_claim;
  END;

  FUNCTION f
  (
    p_damage_id NUMBER
   ,VALUE       NUMBER
   ,dim         NUMBER
  ) RETURN NUMBER IS
    v_fund_rate NUMBER;
  BEGIN
    IF dim = 1
    THEN
      SELECT acc.get_cross_rate_by_brief(1, fc.brief, fd.brief, ch.declare_date)
        INTO v_fund_rate
        FROM ven_c_damage       d
            ,ven_c_claim        c
            ,ven_c_claim_header ch
            ,ven_fund           fd
            ,ven_fund           fc
       WHERE d.c_claim_id = c.c_claim_id
         AND c.c_claim_header_id = ch.c_claim_header_id
         AND fd.fund_id = d.damage_fund_id
         AND fc.fund_id = ch.fund_id
         AND d.c_damage_id = p_damage_id;
    ELSE
      SELECT acc.get_cross_rate_by_brief(1, fd.brief, fc.brief, ch.declare_date)
        INTO v_fund_rate
        FROM ven_c_damage       d
            ,ven_c_claim        c
            ,ven_c_claim_header ch
            ,ven_fund           fd
            ,ven_fund           fc
       WHERE d.c_claim_id = c.c_claim_id
         AND c.c_claim_header_id = ch.c_claim_header_id
         AND fd.fund_id = d.damage_fund_id
         AND fc.fund_id = ch.fund_id
         AND d.c_damage_id = p_damage_id;
    END IF;
    RETURN ROUND(nvl(VALUE, 0) * v_fund_rate, 2);
  END;
  FUNCTION f_d
  (
    p_damage_id NUMBER
   ,VALUE       NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN f(p_damage_id, VALUE, 1);
  END;
  FUNCTION f_d2
  (
    p_damage_id NUMBER
   ,VALUE       NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN f(p_damage_id, VALUE, 0);
  END;

  PROCEDURE recalc_claim_head_paym_sums
  (
    p_claim_header_id        NUMBER
   ,p_declare_sum            OUT NUMBER
   ,p_damage_payment_sum     OUT NUMBER
   ,p_add_expenses_noown_sum OUT NUMBER
   ,p_payment_sum            OUT NUMBER
   ,p_decline_sum            OUT NUMBER
   ,p_add_expences_own_sum   OUT NUMBER
   ,p_deduct_sum             OUT NUMBER
  ) IS
  BEGIN
    recalc_claim_paym_sums(get_curr_claim(p_claim_header_id)
                          ,p_declare_sum
                          ,p_damage_payment_sum
                          ,p_add_expenses_noown_sum
                          ,p_payment_sum
                          ,p_decline_sum
                          ,p_add_expences_own_sum
                          ,p_deduct_sum);
  END;

  PROCEDURE recalc_claim_paym_sums
  (
    p_claim_id               NUMBER
   ,p_declare_sum            OUT NUMBER
   ,p_damage_payment_sum     OUT NUMBER
   ,p_add_expenses_noown_sum OUT NUMBER
   ,p_payment_sum            OUT NUMBER
   ,p_decline_sum            OUT NUMBER
   ,p_add_expences_own_sum   OUT NUMBER
   ,p_deduct_sum             OUT NUMBER
   ,fl_no_update             IN NUMBER DEFAULT 0
  ) IS
    v_claim_id NUMBER := p_claim_id;
  BEGIN
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0))
      INTO p_declare_sum
      FROM ven_c_damage       d
          ,ven_status_hist    sh
          ,ven_c_damage_type  dt
          ,c_damage_cost_type dct
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dct.c_damage_cost_type_id(+) = d.c_damage_cost_type_id
       AND (dt.brief = 'СТРАХОВОЙ' OR dct.brief = 'ВОЗМЕЩАЕМЫЕ');
  
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.deduct_sum), 0))
      INTO p_deduct_sum
      FROM ven_c_damage    d
          ,ven_status_hist sh
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT');
  
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO p_damage_payment_sum
      FROM ven_c_damage      d
          ,ven_status_hist   sh
          ,ven_c_damage_type dt
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dt.brief = 'СТРАХОВОЙ';
  
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO p_add_expenses_noown_sum
      FROM ven_c_damage           d
          ,ven_status_hist        sh
          ,ven_c_damage_type      dt
          ,ven_c_damage_cost_type dct
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dct.c_damage_cost_type_id = d.c_damage_cost_type_id
       AND dt.brief IN ('ДОПРАСХОД')
       AND dct.brief = 'ВОЗМЕЩАЕМЫЕ';
  
    /* select sum(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
     into p_payment_sum
     from ven_c_damage d, ven_status_hist sh
    where d.c_claim_id = v_claim_id
      and d.status_hist_id = sh.status_hist_id
      and sh.BRIEF in ('NEW', 'CURRENT'); */
  
    p_payment_sum := nvl(p_damage_payment_sum, 0) + nvl(p_add_expenses_noown_sum, 0);
  
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.decline_sum), 0))
      INTO p_decline_sum
      FROM ven_c_damage    d
          ,ven_status_hist sh
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT');
  
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO p_add_expences_own_sum
      FROM ven_c_damage           d
          ,ven_status_hist        sh
          ,ven_c_damage_type      dt
          ,ven_c_damage_cost_type dct
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dct.c_damage_cost_type_id = d.c_damage_cost_type_id
       AND dt.brief IN ('ДОПРАСХОД')
       AND dct.brief = 'НЕВОЗМЕЩАЕМЫЕ';
  
    IF fl_no_update = 0
    THEN
      UPDATE ven_c_claim
         SET additional_expenses_noown_sum = p_add_expenses_noown_sum
            ,additional_expenses_own_sum   = p_add_expences_own_sum
            ,additional_expenses_sum       = p_add_expences_own_sum + p_add_expenses_noown_sum
            ,damage_payment_sum            = p_damage_payment_sum
            ,payment_sum                   = p_payment_sum
            ,declare_sum                   = p_declare_sum
       WHERE c_claim_id = v_claim_id;
    END IF;
  END;
  FUNCTION get_dam_pay_sum
  (
    par_sum      IN NUMBER
   ,par_cover_id IN NUMBER
  ) RETURN NUMBER IS
    v_sum     NUMBER;
    v_ins_sum NUMBER;
    v_dt      t_deductible_type.description%TYPE;
    v_dvt     t_deduct_val_type.description%TYPE;
    v_ret     NUMBER := par_sum;
  BEGIN
    -- Валюта на покрытии = валюте полиса = валюте претензии!!
    SELECT pc.deductible_value
          ,dt.description
          ,dvt.description
          ,pc.ins_amount
      INTO v_sum
          ,v_dt
          ,v_dvt
          ,v_ins_sum
      FROM p_cover           pc
          ,t_deductible_type dt
          ,t_deduct_val_type dvt
     WHERE par_cover_id = pc.p_cover_id
       AND dt.id = pc.t_deductible_type_id
       AND dvt.id = pc.t_deduct_val_type_id;
  
    IF v_dvt = 'Процент'
    THEN
      IF v_dt = 'Безусловная'
         OR (v_dt = 'Условная' AND par_sum <= v_ins_sum * v_sum / 100)
      THEN
        v_ret := par_sum - v_ins_sum * v_sum / 100;
      END IF;
    ELSE
      IF v_dt = 'Безусловная'
         OR (v_dt = 'Условная' AND par_sum <= v_sum)
      THEN
        v_ret := par_sum - v_sum;
      END IF;
    END IF;
  
    RETURN greatest(v_ret, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN par_sum;
    
  END;

  FUNCTION get_dam_pay_sum_deduc
  (
    par_sum      IN NUMBER
   ,par_cover_id IN NUMBER
   ,par_deduc    IN NUMBER
  ) RETURN NUMBER IS
    v_ins_sum NUMBER;
    v_dt      t_deductible_type.description%TYPE;
    v_dvt     t_deduct_val_type.description%TYPE;
    v_ret     NUMBER := par_sum;
  BEGIN
    -- Валюта на покрытии = валюте полиса = валюте претензии!!
    SELECT dt.description
          ,dvt.description
          ,pc.ins_amount
      INTO v_dt
          ,v_dvt
          ,v_ins_sum
      FROM p_cover           pc
          ,t_deductible_type dt
          ,t_deduct_val_type dvt
     WHERE par_cover_id = pc.p_cover_id
       AND dt.id = pc.t_deductible_type_id
       AND dvt.id = pc.t_deduct_val_type_id;
  
    IF v_dt = 'Безусловная'
       OR (v_dt = 'Условная' AND par_sum <= par_deduc)
    THEN
      v_ret := par_sum - par_deduc;
    END IF;
  
    RETURN greatest(v_ret, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN par_sum;
    
  END;

  PROCEDURE recalc_claim_dam_sums
  (
    p_claim_id NUMBER
   ,p_cover_id NUMBER DEFAULT NULL
  ) IS
    v_declare_sum_all   NUMBER; -- Сумма всех заявленных убытков
    v_payment_sum_all   NUMBER; -- Сумма к выплате
    v_p_cover_id        NUMBER; -- Id покрытия
    v_sum               NUMBER; -- Значение франшизы на покрытии
    v_dt                VARCHAR2(100); -- Тип франшизы
    v_dvt               VARCHAR2(100); -- Тип значения франшизы
    v_claim_deduct_sum  NUMBER; -- Сумма франшизы claim-а
    v_ins_sum           NUMBER; -- Страховая сумма
    v_ins_price         NUMBER; -- Страховая стоимость
    v_is_proportional   NUMBER; -- Пропорциональный рассчет суммы к выплате
    v_is_aggregate      NUMBER; -- Сумма по покрытию агрегатная (,т.е. страховая сумма по покрытию является лимитом)
    v_event_limit_sum   NUMBER; -- Сумма лимита по страховому событию
    v_payed_cover_sum   NUMBER; -- Сумма уже "выплаченная" по покрытию
    v_payed_event_sum   NUMBER; -- Сумма уже "выплаченная" по событию (и покрываемому риску, если ОСАГО)
    v_limit             NUMBER; -- Оставшаяся сумма ответственности
    v_osago_peril       NUMBER := NULL; -- Риск по осаго (Порча авто либо причинение вреда здоровью)
    v_osago_peril_brief VARCHAR2(1000);
    v_plo               VARCHAR2(100);
  BEGIN
    -- Получаем покрытие
    SELECT nvl(p_cover_id, ch.p_cover_id)
      INTO v_p_cover_id
      FROM ven_c_claim        c
          ,ven_c_claim_header ch
     WHERE c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = p_claim_id;
  
    -- заявленная сумма по-умолчанию
    -- opatsan
    FOR rec IN (SELECT d.c_damage_id
                      ,d.ent_id
                      ,d.declare_sum
                      ,dc.t_prod_coef_type_id id
                  FROM c_damage      d
                      ,t_damage_code dc
                 WHERE d.c_claim_id = p_claim_id
                   AND dc.id = d.t_damage_code_id)
    LOOP
      IF nvl(rec.declare_sum, 0) = 0
      THEN
        v_sum := pkg_tariff_calc.calc_fun(rec.id, rec.ent_id, rec.c_damage_id);
        IF nvl(v_sum, 0) <> 0
        THEN
          UPDATE c_damage d SET d.declare_sum = v_sum WHERE d.c_damage_id = rec.c_damage_id;
        END IF;
      END IF;
    END LOOP;
  
    -- Проверка на ОСАГО. Если ОСАГО. то покрываем только один тип рисков
    SELECT tplo.description
      INTO v_plo
      FROM t_prod_line_option tplo
          ,p_cover            pc
     WHERE pc.t_prod_line_option_id = tplo.id
       AND pc.p_cover_id = v_p_cover_id;
    IF v_plo = 'ОСАГО'
    THEN
      BEGIN
        SELECT peril
              ,brief
          INTO v_osago_peril
              ,v_osago_peril_brief
          FROM (SELECT dc.peril
                      ,per.brief
                  FROM ven_c_damage        d
                      ,ven_status_hist     sh
                      ,ven_c_damage_status ds
                      ,ven_t_damage_code   dc
                      ,ven_t_peril         per
                 WHERE d.p_cover_id = v_p_cover_id
                   AND dc.id = d.t_damage_code_id
                   AND d.c_claim_id = p_claim_id
                   AND d.status_hist_id = sh.status_hist_id
                   AND d.c_damage_status_id = ds.c_damage_status_id
                   AND sh.brief IN ('NEW', 'CURRENT')
                   AND ds.brief NOT IN ('НЕПОКРЫТ')
                   AND per.id = dc.peril
                 ORDER BY d.c_damage_id ASC)
         WHERE rownum < 2;
        UPDATE c_damage d
           SET d.c_damage_status_id =
               (SELECT ds.c_damage_status_id
                  FROM ven_c_damage_status ds
                 WHERE ds.brief = 'НЕПОКРЫТ')
         WHERE d.c_claim_id = p_claim_id
           AND d.c_damage_id IN (SELECT d.c_damage_id
                                   FROM ven_c_damage        d
                                       ,ven_status_hist     sh
                                       ,ven_c_damage_status ds
                                       ,ven_t_damage_code   dc
                                  WHERE d.p_cover_id = v_p_cover_id
                                    AND dc.peril <> v_osago_peril
                                    AND dc.id = d.t_damage_code_id
                                    AND d.c_claim_id = p_claim_id
                                    AND d.status_hist_id = sh.status_hist_id
                                    AND d.c_damage_status_id = ds.c_damage_status_id
                                    AND sh.brief IN ('NEW', 'CURRENT'));
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  
    -- Для непокрытых и отмененных рисков задаем сумму отказа = заявленной сумме и сумму к выплате = 0
    UPDATE c_damage d
       SET d.deduct_sum  = 0
          ,d.decline_sum = d.declare_sum
          ,d.payment_sum = 0
     WHERE d.c_claim_id = p_claim_id
       AND d.c_damage_id IN (SELECT d.c_damage_id
                               FROM ven_c_damage        d
                                   ,ven_status_hist     sh
                                   ,ven_c_damage_status ds
                              WHERE d.p_cover_id = v_p_cover_id
                                AND d.c_claim_id = p_claim_id
                                AND d.status_hist_id = sh.status_hist_id
                                AND d.c_damage_status_id = ds.c_damage_status_id
                                AND sh.brief IN ('NEW', 'CURRENT')
                                AND ds.brief NOT IN ('ОТКРЫТ', 'ЗАКРЫТ'));
  
    -- Получаем сумму заявленных убытков в валюте претензии, чтобы вычислить франшизу
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0))
      INTO v_declare_sum_all
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
     WHERE d.p_cover_id = v_p_cover_id
       AND d.c_claim_id = p_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT');
  
    -- Получаем сумму франшизы,тип франшизы, страховую сумму, стоимость на покрытии (в валюте претензии)
    SELECT nvl(pc.deductible_value, 0)
          ,dt.description
          ,dvt.description
          ,nvl(pc.ins_amount, 0)
          ,nvl(pc.is_proportional, 0)
          ,nvl(pc.is_aggregate, 0)
          ,nvl(pc.ins_price, 0)
      INTO v_sum
          ,v_dt
          ,v_dvt
          ,v_ins_sum
          ,v_is_proportional
          ,v_is_aggregate
          ,v_ins_price
      FROM p_cover           pc
          ,t_deductible_type dt
          ,t_deduct_val_type dvt
     WHERE v_p_cover_id = pc.p_cover_id
       AND dt.id = pc.t_deductible_type_id
       AND dvt.id = pc.t_deduct_val_type_id;
  
    IF v_dvt = 'Процент'
    THEN
      IF v_dt = 'Безусловная'
         OR (v_dt = 'Условная' AND v_declare_sum_all <= ROUND(v_ins_sum * v_sum / 100, 2))
      THEN
        v_claim_deduct_sum := ROUND(v_ins_sum * v_sum / 100, 2);
      END IF;
    ELSE
      IF v_dt = 'Безусловная'
         OR (v_dt = 'Условная' AND v_declare_sum_all <= v_sum)
      THEN
        -- @Marchuk A. 2008.08.16
        -- При типе значения франшизы отличном от %, требуется перевести значение в %. Для этого на коде ущерба есть специальная функция, задающая
        -- величину зависимости единицы франшизы к процентам от риска
        FOR rec IN (SELECT MAX(nvl(pc.deductible_value, 0) *
                               nvl(pkg_tariff_calc.calc_fun(dc.deduct_func_id, d.ent_id, d.c_damage_id)
                                  ,1)) percent
                      FROM p_cover       pc
                          ,c_damage      d
                          ,t_damage_code dc
                          ,c_damage_type dt
                     WHERE 1 = 1
                       AND d.c_claim_id = p_claim_id
                       AND dc.id = d.t_damage_code_id
                       AND dt.c_damage_type_id = d.c_damage_type_id
                       AND dt.brief = 'СТРАХОВОЙ'
                       AND pc.p_cover_id = d.p_cover_id)
        LOOP
          v_claim_deduct_sum := ROUND(v_ins_sum * rec.percent / 100, 2);
        END LOOP;
      END IF;
    END IF;
    dbms_output.put_line(' v_claim_deduct_sum ' || v_claim_deduct_sum);
    v_claim_deduct_sum := nvl(v_claim_deduct_sum, 0);
    -- Если франшиза>=заявленной суммы, то на каждом ущербе сумма отказа=заявл. сумме и сумма выплаты=0
    IF v_claim_deduct_sum >= v_declare_sum_all
    THEN
      UPDATE c_damage d
         SET d.deduct_sum  = d.declare_sum
            ,d.decline_sum = d.declare_sum
            ,d.payment_sum = 0
       WHERE d.c_damage_id IN (SELECT d.c_damage_id
                                 FROM ven_c_damage        d
                                     ,ven_status_hist     sh
                                     ,ven_c_damage_status ds
                                WHERE d.p_cover_id = v_p_cover_id
                                  AND d.c_claim_id = p_claim_id
                                  AND d.status_hist_id = sh.status_hist_id
                                  AND d.c_damage_status_id = ds.c_damage_status_id
                                  AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                  AND sh.brief IN ('NEW', 'CURRENT'));
      RETURN;
    END IF;
    -- Вычисляем франшизу по каждому ущербу пропорционально заявленному убытку
    /*
    UPDATE c_damage d
       SET d.deduct_sum = ROUND(f_d(d.c_damage_id, v_claim_deduct_sum) *
                                NVL(d.declare_sum, 0) /
                                f_d(d.c_damage_id, v_declare_sum_all),
                                2)
     WHERE d.c_damage_id IN
           (SELECT d.c_damage_id
              FROM c_damage        d,
                   ven_status_hist     sh,
                   ven_c_damage_status ds
             WHERE d.p_cover_id = v_p_cover_id
               AND d.c_claim_id = p_claim_id
               AND d.status_hist_id = sh.status_hist_id
               AND d.c_damage_status_id = ds.c_damage_status_id
               AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
               AND sh.BRIEF IN ('NEW', 'CURRENT'));
     */
    FOR dd IN (SELECT d.c_damage_id
                     ,d.deduct_sum
                     ,d.declare_sum
                 FROM c_damage            d
                     ,ven_status_hist     sh
                     ,ven_c_damage_status ds
                WHERE d.p_cover_id = v_p_cover_id
                  AND d.c_claim_id = p_claim_id
                  AND d.status_hist_id = sh.status_hist_id
                  AND d.c_damage_status_id = ds.c_damage_status_id
                  AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                  AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
    
      DECLARE
        a1 NUMBER := f_d(dd.c_damage_id, v_claim_deduct_sum);
        a2 NUMBER := f_d(dd.c_damage_id, v_declare_sum_all);
      BEGIN
        UPDATE c_damage
           SET deduct_sum = ROUND(a1 * nvl(dd.declare_sum, 0) / a2, 2)
         WHERE c_damage_id = dd.c_damage_id;
      END;
    END LOOP;
  
    -- Если больше одного ущерба
    IF SQL%ROWCOUNT > 1
    THEN
      -- Корректируем сумму франшизы на последнем ущербе, так чтобы сумма франшизы по всем ущербам была равна общей сумме франшизы
      -- Это может быть не так из-за округлений
      DECLARE
        v_last_damage_id NUMBER;
        v_s              NUMBER;
      BEGIN
        SELECT c_damage_id
          INTO v_last_damage_id
          FROM (SELECT c_damage_id
                  FROM ven_c_damage        d
                      ,ven_status_hist     sh
                      ,ven_c_damage_status ds
                 WHERE d.p_cover_id = v_p_cover_id
                   AND d.c_claim_id = p_claim_id
                   AND d.status_hist_id = sh.status_hist_id
                   AND d.c_damage_status_id = ds.c_damage_status_id
                   AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                   AND sh.brief IN ('NEW', 'CURRENT')
                 ORDER BY c_damage_id DESC)
         WHERE rownum < 2;
      
        SELECT SUM(nvl(f_d2(d.c_damage_id, d.deduct_sum), 0))
          INTO v_s
          FROM ven_c_damage        d
              ,ven_status_hist     sh
              ,ven_c_damage_status ds
         WHERE d.p_cover_id = v_p_cover_id
           AND d.c_claim_id = p_claim_id
           AND d.c_damage_id <> v_last_damage_id
           AND d.status_hist_id = sh.status_hist_id
           AND d.c_damage_status_id = ds.c_damage_status_id
           AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
           AND sh.brief IN ('NEW', 'CURRENT');
      
        UPDATE ven_c_damage d
           SET d.deduct_sum = f_d(d.c_damage_id, v_claim_deduct_sum - v_s)
         WHERE c_damage_id = v_last_damage_id;
      END;
    END IF;
  
    -- Устанавливаем по ущербам сумму отказа с учетом франшизы и лимита по ущербу
    /*
    UPDATE c_damage d
       SET d.decline_sum = GREATEST(d.deduct_sum,
                                    d.declare_sum -
                                    f_d(d.c_damage_id,
                                        NVL(damage_perc(d.c_damage_id), 0)))
     WHERE d.c_damage_id IN
           (SELECT d.c_damage_id
              FROM c_damage        d,
                   ven_status_hist     sh,
                   ven_c_damage_status ds
             WHERE d.p_cover_id = v_p_cover_id
               AND d.c_claim_id = p_claim_id
               AND d.status_hist_id = sh.status_hist_id
               AND d.c_damage_status_id = ds.c_damage_status_id
               AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
               AND sh.BRIEF IN ('NEW', 'CURRENT'));
     */
    FOR dd IN (SELECT d.c_damage_id
                     ,d.deduct_sum
                     ,d.declare_sum
                 FROM c_damage            d
                     ,ven_status_hist     sh
                     ,ven_c_damage_status ds
                WHERE d.p_cover_id = v_p_cover_id
                  AND d.c_claim_id = p_claim_id
                  AND d.status_hist_id = sh.status_hist_id
                  AND d.c_damage_status_id = ds.c_damage_status_id
                  AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                  AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
    
      DECLARE
        a1 NUMBER := f_d(dd.c_damage_id, nvl(damage_perc(dd.c_damage_id), 0));
        a2 NUMBER;
      BEGIN
        UPDATE c_damage
           SET decline_sum = greatest(dd.deduct_sum, dd.declare_sum - a1)
         WHERE c_damage_id = dd.c_damage_id;
      END;
    END LOOP;
  
    -- Вычисляем сумму к выплате без учета лимитов, но с учетом франшизы, суммы отказа и пропорциональности
    IF v_is_proportional = 1
    THEN
      SELECT ROUND(SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0) -
                       nvl(f_d2(d.c_damage_id, d.decline_sum), 0)) * v_ins_price / v_ins_sum
                  ,2)
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.brief IN ('NEW', 'CURRENT');
    ELSE
      SELECT SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0) -
                 nvl(f_d2(d.c_damage_id, d.decline_sum), 0))
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.brief IN ('NEW', 'CURRENT');
    END IF;
  
    -- Проверяем лимит по покрытию и по событию
  
    -- Получаем сумму лимита по событию
    SELECT a.ins_limit
      INTO v_event_limit_sum
      FROM ven_as_asset a
          ,ven_p_cover  p
     WHERE a.as_asset_id = p.as_asset_id
       AND p.p_cover_id = v_p_cover_id;
  
    IF v_osago_peril_brief = 'ОСАГО_ЗДОРОВЬЕ'
    THEN
      v_event_limit_sum := greatest(240000, nvl(v_event_limit_sum, 0));
    ELSIF v_osago_peril_brief = 'ОСАГО_ИМУЩЕСТВО'
    THEN
      v_event_limit_sum := greatest(160000, nvl(v_event_limit_sum, 0));
    END IF;
  
    -- Получаем сумму выплат по всем ущербам данного покрытия во всех предыдущих претензиях
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO v_payed_cover_sum
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
          ,ven_c_claim         c
          ,ven_c_claim_header  ch
     WHERE d.p_cover_id = v_p_cover_id
          --and d.c_claim_id <> p_claim_id
       AND ch.c_claim_header_id <>
           (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT');
  
    IF v_osago_peril IS NOT NULL
    THEN
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем и покрываемым риском (для ОСАГО)
      SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
        INTO v_payed_event_sum
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
            ,ven_c_claim         c
            ,ven_c_event         e
            ,ven_c_claim_header  ch
            ,ven_p_cover         p
            ,ven_t_damage_code   damc
       WHERE
      -- Не рассматриваем текущую претензию
      --d.c_claim_id <> p_claim_id
       ch.c_claim_header_id <>
       (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
      -- Условие на актуальные версии претензий
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.c_event_id = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.c_claim_header_id = ch.c_claim_header_id
                          AND c.c_claim_id = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT')
      -- Условие на риск
       AND damc.peril = v_osago_peril
       AND damc.id = d.c_damage_id;
    ELSE
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем
      SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
        INTO v_payed_event_sum
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
            ,ven_c_claim         c
            ,ven_c_event         e
            ,ven_c_claim_header  ch
            ,ven_p_cover         p
       WHERE
      -- Не рассматриваем текущую претензию
      --d.c_claim_id <> p_claim_id
       ch.c_claim_header_id <>
       (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
      -- Условие на актуальные версии претензий
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.c_event_id = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.c_claim_header_id = ch.c_claim_header_id
                          AND c.c_claim_id = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT');
    END IF;
  
    -- Если задан лимит по покрытию, то максимально возможная сумма к выплате = страх.сумма-выплаченная сумма
    IF v_is_aggregate = 1
    THEN
      v_limit := greatest(0, v_ins_sum - nvl(v_payed_cover_sum, 0));
    ELSE
      -- иначе максимально возможная сумма к выплате = страх.сумма, либо лимит на риске(в случае ОСАГО)
      IF v_osago_peril IS NULL
      THEN
        v_limit := v_ins_sum;
      ELSE
        -- select nvl(tplop.limit_amount, v_ins_sum) into v_limit from t_prod_line_opt_peril tplop
        --  where tplop.peril_id = v_osago_peril;
        IF v_osago_peril_brief = 'ОСАГО_ЗДОРОВЬЕ'
        THEN
          v_limit := 160000;
        ELSIF v_osago_peril_brief = 'ОСАГО_ИМУЩЕСТВО'
        THEN
          v_limit := 120000;
        END IF;
      END IF;
    END IF;
    -- Если задан лимит на объекте (макс. сумма по 1 страх. случаю)
    IF v_event_limit_sum IS NOT NULL
    THEN
      -- Берем минимальное из ограничений по выплате (по событию и покрытию)
      IF v_event_limit_sum - v_payed_event_sum < v_limit
      THEN
        v_limit := v_event_limit_sum - v_payed_event_sum;
        IF v_limit < 0
        THEN
          v_limit := 0;
        END IF;
      END IF;
    END IF;
    -- Если рассчитанная сумма к выплате по претензии< макс. возможной....
    IF v_limit < v_payment_sum_all
    THEN
      v_payment_sum_all := v_limit;
    END IF;
    -- конец анализа лимитов
    FOR v_damage IN (SELECT d.*
                       FROM ven_c_damage        d
                           ,ven_status_hist     sh
                           ,ven_c_damage_status ds
                      WHERE d.p_cover_id = v_p_cover_id
                        AND d.c_claim_id = p_claim_id
                        AND d.status_hist_id = sh.status_hist_id
                        AND d.c_damage_status_id = ds.c_damage_status_id
                        AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                        AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
      v_damage.payment_sum := nvl(v_damage.declare_sum, 0) - nvl(v_damage.decline_sum, 0);
      IF nvl(v_payment_sum_all, 0) < nvl(v_damage.payment_sum, 0)
      THEN
        v_damage.payment_sum := v_payment_sum_all;
      END IF;
      v_damage.decline_sum := greatest(0, nvl(v_damage.declare_sum, 0) - nvl(v_damage.payment_sum, 0));
      v_payment_sum_all    := greatest(v_payment_sum_all -
                                       nvl(f_d2(v_damage.c_damage_id, v_damage.payment_sum), 0)
                                      ,0);
      UPDATE c_damage
         SET payment_sum = v_damage.payment_sum
            ,decline_sum = v_damage.decline_sum
       WHERE c_damage_id = v_damage.c_damage_id;
    END LOOP;
  END;

  FUNCTION get_claim_num(p_cl_head_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN p_cl_head_id;
  END;

  FUNCTION copy_claim_version(p_claim_id IN NUMBER) RETURN NUMBER IS
    v_id         NUMBER;
    v_header_id  NUMBER;
    v_active_id  NUMBER;
    v_claim      ven_c_claim%ROWTYPE;
    v_claim_add  c_claim_add%ROWTYPE;
    v_sh_brief   status_hist.brief%TYPE;
    v_last_brief VARCHAR2(30);
    v_max_status DATE;
  BEGIN
    IF p_claim_id IS NULL
    THEN
      RETURN NULL;
    ELSE
    
      -- пытаемся заблокировать заголовок убытка
      SELECT ch.c_claim_header_id
        INTO v_id
        FROM c_claim_header ch
       WHERE ch.c_claim_header_id IN
             (SELECT c.c_claim_header_id FROM c_claim c WHERE c.c_claim_id = p_claim_id)
         FOR UPDATE NOWAIT;
    
      -- новый ид
      SELECT sq_c_claim.nextval INTO v_id FROM dual;
      -- старая запись
      SELECT v.* INTO v_claim FROM ven_c_claim v WHERE v.c_claim_id = p_claim_id;
    
      BEGIN
        SELECT vd.* INTO v_claim_add FROM c_claim_add vd WHERE vd.c_claim_id = p_claim_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    
      v_header_id := v_claim.c_claim_header_id;
    
      dbms_output.put_line(' copy_claim_version ... p_claim_id = ' || p_claim_id || ' v_header_id = ' ||
                           v_header_id);
    
      SELECT active_claim_id
        INTO v_active_id
        FROM c_claim_header
       WHERE c_claim_header_id = v_header_id;
    
      dbms_output.put_line(' active_claim_id = ' || v_active_id);
    
      -- новый ид и дата регистрации
      v_claim.c_claim_id := v_id;
      --Чирков Урегулирование убытков разработка /из-за пересоздания сущности c_claim_header
      --и определения последнего статуса по полю doc_status_id в таблице document/
      v_claim.doc_status_id     := NULL;
      v_claim.doc_status_ref_id := NULL;
      v_claim.reg_date          := NULL;
      --      v_claim.reg_date   := SYSDATE;
    
      SELECT MAX(start_date) INTO v_max_status FROM doc_status ds WHERE ds.document_id = p_claim_id;
    
      v_claim.reg_date := nvl(v_max_status + 1 / (24 * 60 * 60), SYSDATE);
    
      v_last_brief := doc.get_last_doc_status_brief(p_claim_id);
      IF pkg_app_param.get_app_param_n('CLIENTID') = 10
         AND v_last_brief = 'CLOSE'
      THEN
        SELECT cs.c_claim_status_id
          INTO v_claim.claim_status_id
          FROM c_claim_status cs
         WHERE cs.brief = 'ПЕРЕОТКРЫТ';
      END IF;
      -- новый номер пп
      SELECT MAX(c.seqno) + 1
        INTO v_claim.seqno
        FROM c_claim c
       WHERE c.c_claim_header_id = v_claim.c_claim_header_id;
      -- добавляем запись
      INSERT INTO ven_c_claim VALUES v_claim;
      IF nvl(v_claim_add.reinsurer_perc, 0) > 0
      THEN
        INSERT INTO c_claim_add dd
          (dd.c_claim_id, dd.reinsurer_perc, dd.reinsurer_id)
        VALUES
          (v_id, v_claim_add.reinsurer_perc, v_claim_add.reinsurer_id);
      END IF;
    
      IF pkg_app_param.get_app_param_n('CLIENTID') = 10
      THEN
        IF v_last_brief = 'CLOSE'
        THEN
          doc.set_doc_status(v_claim.c_claim_id, 'REVISION', v_claim.reg_date);
        ELSE
          doc.set_doc_status(v_claim.c_claim_id, v_last_brief, v_claim.reg_date);
        END IF;
      ELSE
        doc.set_doc_status(v_claim.c_claim_id, 'PROJECT', v_claim.reg_date);
      END IF;
    
      -- цикл по убыткам
      FOR v_damage IN (SELECT d.* FROM ven_c_damage d WHERE d.c_claim_id = p_claim_id)
      LOOP
        -- ид статуса истории убытка
        SELECT sh.brief
          INTO v_sh_brief
          FROM status_hist sh
         WHERE sh.status_hist_id = v_damage.status_hist_id;
        -- если не удален
        IF v_sh_brief <> 'DELETED'
        THEN
          -- если новый, то меняем на текущий
          IF v_sh_brief = 'NEW'
          THEN
            SELECT sh.status_hist_id
              INTO v_damage.status_hist_id
              FROM status_hist sh
             WHERE sh.brief = 'CURRENT';
          END IF;
          -- новые ид
          SELECT sq_c_damage.nextval
                ,v_id
            INTO v_damage.c_damage_id
                ,v_damage.c_claim_id
            FROM dual;
          -- вставляем убыток
          INSERT INTO ven_c_damage VALUES v_damage;
        END IF;
      END LOOP;
    
      SELECT active_claim_id
        INTO v_active_id
        FROM c_claim_header
       WHERE c_claim_header_id = v_header_id;
    
      dbms_output.put_line('after copy ... active_id = ' || v_active_id);
    
      RETURN v_id;
    END IF;
  END;

  FUNCTION get_lim_amount
  (
    p_damage_code IN NUMBER
   ,par_cover     IN NUMBER
   ,p_damage_id   NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_lim_am   NUMBER;
    v_d_lim_am NUMBER;
  BEGIN
    IF p_damage_id IS NOT NULL
    THEN
      SELECT d.limit_amount INTO v_d_lim_am FROM c_damage d WHERE d.c_damage_id = p_damage_id;
    END IF;
  
    SELECT nvl(v_d_lim_am, nvl(plop.limit_amount, pc.ins_amount))
      INTO v_lim_am
      FROM p_cover               pc
          ,t_prod_line_option    plo
          ,t_prod_line_opt_peril plop
          ,t_damage_code         dc
     WHERE pc.p_cover_id = par_cover
       AND plo.id = pc.t_prod_line_option_id
       AND pc.t_prod_line_option_id = plop.product_line_option_id
       AND dc.peril = plop.peril_id
       AND dc.id = p_damage_code;
    RETURN v_lim_am;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_lim_rest_amount
  (
    p_damage_code IN NUMBER
   ,par_cover     IN NUMBER
  ) RETURN NUMBER IS
    v_ret NUMBER;
  BEGIN
    SELECT get_lim_amount(p_damage_code, par_cover) - SUM(d.payment_sum)
      INTO v_ret
      FROM c_damage           d
          ,c_damage_status    ds
          ,c_damage_cost_type dct
     WHERE d.p_cover_id = par_cover
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND d.c_damage_cost_type_id = dct.c_damage_cost_type_id
       AND dct.brief IN ('ВОЗМЕЩАЕМЫЕ');
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  PROCEDURE get_dept_person
  (
    par_policy_id     IN NUMBER
   ,par_department_id IN OUT NUMBER
   ,par_contact_id    IN OUT NUMBER
  ) IS
    v_employee_id NUMBER;
  BEGIN
    -- выбираем сотрудника для текущего пользователя
    SELECT su.employee_id INTO v_employee_id FROM sys_user su WHERE su.sys_user_name = USER;
  
    -- если не найден, то берем сотрудника и отдел из значений по-умолчанию
    IF v_employee_id IS NULL
    THEN
      RAISE no_data_found;
    ELSE
      -- иначе находим текущий отдел пользователя
      SELECT e.contact_id INTO par_contact_id FROM employee e WHERE e.employee_id = v_employee_id;
    
      BEGIN
        SELECT eh.department_id
          INTO par_department_id
          FROM employee_hist eh
         WHERE eh.employee_id = v_employee_id
           AND eh.date_hist = (SELECT MAX(e.date_hist)
                                 FROM employee_hist e
                                WHERE e.employee_id = v_employee_id
                                  AND e.date_hist <= SYSDATE
                                  AND e.is_kicked = 0);
      EXCEPTION
        WHEN OTHERS THEN
          par_department_id := pkg_app_param.get_app_param_u('ПОДРУБ');
      END;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      par_department_id := pkg_app_param.get_app_param_u('ПОДРУБ');
      SELECT c.contact_id INTO par_contact_id FROM v_pol_curator c WHERE c.policy_id = par_policy_id;
  END;

  FUNCTION get_damage_list(p_c_claim_id IN NUMBER) RETURN VARCHAR2 AS
    v_result VARCHAR2(1000);
  BEGIN
    FOR v_r IN (SELECT tdc.description
                  FROM c_damage cd
                 INNER JOIN t_damage_code tdc
                    ON tdc.id = cd.t_damage_code_id
                 WHERE cd.c_claim_id = p_c_claim_id)
    LOOP
      IF v_result IS NULL
      THEN
        v_result := v_r.description;
      ELSE
        v_result := v_result || ', ' || v_r.description;
      END IF;
    END LOOP;
    RETURN v_result;
  END;

  -- Возвращает список рисков по претензии
  FUNCTION get_damage_risk_list(p_c_claim_id IN NUMBER) RETURN VARCHAR2 IS
    v_result VARCHAR2(1000);
  BEGIN
    FOR v_r IN (SELECT tp.description
                  FROM c_damage cd
                  JOIN t_damage_code tdc
                    ON tdc.id = cd.t_damage_code_id
                  JOIN t_peril tp
                    ON tp.id = tdc.peril
                 WHERE cd.c_claim_id = p_c_claim_id)
    LOOP
      IF v_result IS NULL
      THEN
        v_result := v_r.description;
      ELSE
        v_result := v_result || ', ' || v_r.description;
      END IF;
    END LOOP;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_curr_claim(p_c_claim_header_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    SELECT c_claim_id
      INTO v_result
      FROM (SELECT cc.c_claim_id
              FROM c_claim cc
             WHERE cc.c_claim_header_id = p_c_claim_header_id
             ORDER BY cc.seqno DESC) t
     WHERE rownum = 1;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE claim_charge(p_claim_id IN NUMBER) IS
    v_oper_templ_charge_id NUMBER;
    v_res_id               NUMBER;
  BEGIN
    SELECT ot.oper_templ_id
      INTO v_oper_templ_charge_id
      FROM oper_templ ot
     WHERE ot.brief = 'ВозмещениеНач';
  
    FOR c_claim IN (SELECT dam.c_damage_id
                          ,dam.ent_id
                          ,dam.payment_sum *
                           acc.get_cross_rate_by_id(1
                                                   ,dam.damage_fund_id
                                                   ,ch.fund_id
                                                   ,c.claim_status_date) payment_sum
                      FROM c_damage           dam
                          ,c_damage_status    ds
                          ,status_hist        sh
                          ,c_claim            c
                          ,c_claim_header     ch
                          ,c_damage_type      dt
                          ,c_damage_cost_type dct
                     WHERE dam.c_claim_id = p_claim_id
                       AND dam.c_claim_id = c.c_claim_id
                       AND c.c_claim_header_id = ch.c_claim_header_id
                       AND dam.c_damage_status_id = ds.c_damage_status_id
                       AND dam.status_hist_id = sh.status_hist_id
                       AND dam.c_damage_type_id = dt.c_damage_type_id
                       AND dam.c_damage_cost_type_id = dct.c_damage_cost_type_id(+)
                       AND (dt.brief = 'СТРАХОВОЙ' OR dct.brief = 'ВОЗМЕЩАЕМЫЕ')
                       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                       AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
      dbms_output.put_line('go ' || c_claim.c_damage_id);
      v_res_id := acc_new.run_oper_by_template(v_oper_templ_charge_id
                                              ,p_claim_id
                                              ,c_claim.ent_id
                                              ,c_claim.c_damage_id
                                              ,doc.get_last_doc_status_ref_id(p_claim_id)
                                              ,1
                                              ,c_claim.payment_sum
                                              ,'INS');
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR claim_charge ' || p_claim_id);
      dbms_output.put_line(SQLERRM);
      RAISE;
  END;

  -- Возвращает номер предыдущего дела
  FUNCTION get_prev_claim_num(p_claim_id NUMBER) RETURN VARCHAR2 IS
    num VARCHAR2(100);
  
  BEGIN
  
    SELECT a.num
      INTO num
      FROM (SELECT ch2.num
                  ,MAX(ch2.reg_date) over(PARTITION BY ch.as_asset_id) max_date
                  ,ch2.reg_date
              FROM ven_c_claim_header ch
              JOIN ven_as_asset ass
                ON ass.as_asset_id = ch.as_asset_id
              JOIN ven_as_assured assur
                ON assur.as_assured_id = ass.as_asset_id
              JOIN ven_c_claim_header ch2
                ON ch2.as_asset_id = assur.as_assured_id
             WHERE ch2.reg_date < ch.reg_date
               AND ch.active_claim_id = p_claim_id) a
     WHERE a. max_date = a.reg_date;
  
    RETURN(num);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает суммарный процент от страховой суммы по всем страховым убыткам
  FUNCTION get_percent_sum(p_claim_id NUMBER) RETURN NUMBER IS
    per     NUMBER(5, 2);
    dec_sum NUMBER; -- заявленная сумма по убытку
    ins_sum NUMBER; -- страховая сумма
  BEGIN
    SELECT SUM(cd.declare_sum)
      INTO dec_sum
      FROM ven_c_damage cd
      JOIN ven_c_damage_type dt
        ON cd.c_damage_type_id = dt.c_damage_type_id
     WHERE cd.c_claim_id = p_claim_id
       AND dt.brief = 'СТРАХОВОЙ';
  
    SELECT pc.ins_amount
      INTO ins_sum
      FROM c_claim_header ch
      JOIN p_cover pc
        ON pc.p_cover_id = ch.p_cover_id
     WHERE ch.active_claim_id = p_claim_id;
    per := (dec_sum / ins_sum) * 100;
    RETURN(per);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_claim_nr(p_prod_id IN NUMBER) RETURN NUMBER IS
    v_claim_nr   NUMBER;
    v_prod_brief VARCHAR2(30);
  BEGIN
  
    SELECT sq_claim_num.nextval INTO v_claim_nr FROM dual;
    RETURN v_claim_nr;
  END;

  FUNCTION count_loss_by_prev
  (
    p_pol_header_id IN NUMBER
   ,p_plo           IN VARCHAR DEFAULT NULL
  ) RETURN NUMBER IS
    -- количество убытоков по договору / Балашов
    v_ret NUMBER := 0;
  BEGIN
  
    IF (p_plo IS NULL)
    THEN
      SELECT nvl(COUNT(ce.c_event_id), 0)
        INTO v_ret
        FROM c_event ce
        JOIN as_asset ass
          ON ass.as_asset_id = ce.as_asset_id
        JOIN p_policy pp
          ON pp.policy_id = ass.p_policy_id
       WHERE pp.pol_header_id = p_pol_header_id;
    ELSE
      SELECT COUNT(DISTINCT ce.c_event_id)
        INTO v_ret
        FROM c_event ce
        JOIN as_asset ass
          ON ass.as_asset_id = ce.as_asset_id
        JOIN p_policy pp
          ON pp.policy_id = ass.p_policy_id
        JOIN c_claim_header ch
          ON ch.c_event_id = ce.c_event_id
        JOIN p_cover pc
          ON pc.p_cover_id = ch.p_cover_id
        JOIN t_prod_line_option plo
          ON plo.id = pc.t_prod_line_option_id
       WHERE pp.pol_header_id = p_pol_header_id
         AND plo.description = p_plo;
    END IF;
    RETURN v_ret;
  END;

  FUNCTION unprofitableness(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    -- убыточность по договору / Балашов
    v_ret     NUMBER := 0;
    paym      NUMBER;
    nach      NUMBER;
    prod_avto NUMBER;
  BEGIN
    -- выплаты : сумма выплаченных и подлежащих к выплате возмещений,
    --           сумма начисленной премии
    SELECT instr(upper(pr.brief), 'АВТОКАСКО')
      INTO prod_avto
      FROM p_pol_header ph
      JOIN t_product pr
        ON pr.product_id = ph.product_id
     WHERE ph.policy_header_id = p_pol_header_id;
  
    IF prod_avto > 0
    THEN
      SELECT nvl(SUM(cc.payment_sum), 0)
            ,nvl(SUM(pkg_payment.get_charge_cover_amount_pfa(pc.start_date
                                                            ,pc.end_date
                                                            ,pc.p_cover_id))
                ,SUM(pc.premium - nvl(pc.old_premium, 0)))
        INTO paym
            ,nach
        FROM p_policy pp
        JOIN as_asset ass
          ON ass.p_policy_id = pp.policy_id
        JOIN p_cover pc
          ON pc.as_asset_id = ass.as_asset_id
        JOIN t_prod_line_option plo
          ON plo.id = pc.t_prod_line_option_id
        LEFT JOIN c_claim_header ch
          ON ch.p_cover_id = pc.p_cover_id
        LEFT JOIN c_claim cc
          ON ch.c_claim_header_id = cc.c_claim_header_id
        LEFT JOIN c_claim_status cs
          ON cs.c_claim_status_id = cc.claim_status_id
       WHERE pp.pol_header_id = p_pol_header_id
         AND cs.brief = 'ЗАКРЫТО'
         AND plo.description IN ('Автокаско'
                                ,'Ущерб'
                                ,'Дополнительное оборудование');
    ELSE
      SELECT nvl(SUM(cc.payment_sum), 0)
            ,nvl(SUM(pkg_payment.get_charge_cover_amount_pfa(pc.start_date
                                                            ,pc.end_date
                                                            ,pc.p_cover_id))
                ,SUM(pc.premium - nvl(pc.old_premium, 0)))
        INTO paym
            ,nach
        FROM p_policy pp
        JOIN as_asset ass
          ON ass.p_policy_id = pp.policy_id
        JOIN p_cover pc
          ON pc.as_asset_id = ass.as_asset_id
        LEFT JOIN c_claim_header ch
          ON ch.p_policy_id = pp.policy_id
        LEFT JOIN c_claim cc
          ON ch.c_claim_header_id = cc.c_claim_header_id
        LEFT JOIN c_claim_status cs
          ON cs.c_claim_status_id = cc.claim_status_id
       WHERE pp.pol_header_id = p_pol_header_id
         AND cs.brief = 'ЗАКРЫТО';
    END IF;
    v_ret := ROUND(paym / nach, 2);
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_declare_sum
  (
    par_ph  IN NUMBER
   ,par_dat IN DATE
  ) RETURN NUMBER IS
    v_dec_sum NUMBER;
  BEGIN
    SELECT SUM(cc.declare_sum)
      INTO v_dec_sum
      FROM p_pol_header ph
      JOIN p_policy pp
        ON pp.pol_header_id = ph.policy_header_id
      JOIN as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN c_event ce
        ON ce.as_asset_id = ass.as_asset_id
      JOIN c_claim_header ch
        ON ch.c_event_id = ce.c_event_id
      JOIN c_claim cc
        ON cc.c_claim_header_id = ch.c_claim_header_id
     WHERE ph.policy_header_id = par_ph
       AND cc.seqno = (SELECT MAX(cc1.seqno)
                         FROM c_claim cc1
                        WHERE cc1.c_claim_header_id = ch.c_claim_header_id
                          AND cc1.claim_status_date < par_dat);
    RETURN v_dec_sum;
  END;

  FUNCTION damage_perc(p_damage_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT dc.limit_val
                     ,c.ins_amount
                     ,ch.ins_sum
                     ,ch.is_handset_ins_sum
                 FROM c_damage       d
                     ,t_damage_code  dc
                     ,p_cover        c
                     ,c_claim        cc
                     ,c_claim_header ch --Чирков Урегулирование убытков разработка  /24.01.2012/ Если ручной ввод, то берется сумма ins_sum
                WHERE d.c_damage_id = p_damage_id
                  AND dc.id = d.t_damage_code_id
                  AND c.p_cover_id = d.p_cover_id
                  AND d.c_claim_id = cc.c_claim_id --Чирков Урегулирование убытков разработка  /24.01.2012/ Если ручной ввод, то берется сумма ins_sum
                  AND cc.c_claim_header_id = ch.c_claim_header_id --Чирков Урегулирование убытков разработка  /24.01.2012/ Если ручной ввод, то берется сумма ins_sum
               )
    LOOP
      IF nvl(rc.is_handset_ins_sum, 0) = 1
      THEN
        --Чирков Урегулирование убытков разработка добавил условие
        RETURN ROUND(rc.limit_val * rc.ins_sum / 100, 2);
      ELSE
        RETURN ROUND(rc.limit_val * rc.ins_amount / 100, 2);
      END IF;
      --RETURN ROUND(rc.limit_val * rc.ins_amount / 100, 2);
    END LOOP;
    RETURN NULL;
  END;

  FUNCTION damage_days(p_damage_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT d.rec_start_date
                     ,d.rec_end_date
                     ,c.ins_amount
                 FROM c_damage d
                     ,p_cover  c
                WHERE d.c_damage_id = p_damage_id
                  AND c.p_cover_id = d.p_cover_id)
    LOOP
      RETURN ROUND((rc.rec_end_date - rc.rec_start_date + 1) * rc.ins_amount * 0.002, 2);
    END LOOP;
    RETURN NULL;
  END;

  PROCEDURE recalc_claim_dam_sums_life
  (
    p_claim_id NUMBER
   ,p_cover_id NUMBER DEFAULT NULL
  ) IS
    v_declare_sum_all    NUMBER; -- Сумма всех заявленных убытков
    v_payment_sum_all    NUMBER; -- Сумма к выплате
    v_p_cover_id         NUMBER; -- Id покрытия
    v_is_handset_ins_sum NUMBER; -- Признак ручного ввода
    v_sum                NUMBER; -- Значение франшизы на покрытии
    v_dt                 VARCHAR2(100); -- Тип франшизы
    v_dvt                VARCHAR2(100); -- Тип значения франшизы
    v_claim_deduct_sum   NUMBER; -- Сумма франшизы claim-а
    v_refuse_sum         NUMBER; -- Сумма отказа claim-а
    v_ins_sum            NUMBER; -- Страховая сумма
    v_ins_price          NUMBER; -- Страховая стоимость
    v_is_proportional    NUMBER; -- Пропорциональный рассчет суммы к выплате
    v_is_aggregate       NUMBER; -- Сумма по покрытию агрегатная (,т.е. страховая сумма по покрытию является лимитом)
    v_event_limit_sum    NUMBER; -- Сумма лимита по страховому событию
    v_payed_cover_sum    NUMBER; -- Сумма уже "выплаченная" по покрытию
    v_payed_event_sum    NUMBER; -- Сумма уже "выплаченная" по событию (и покрываемому риску, если ОСАГО)
    v_limit              NUMBER; -- Оставшаяся сумма ответственности
    v_osago_peril        NUMBER := NULL; -- Риск по осаго (Порча авто либо причинение вреда здоровью)
    v_osago_peril_brief  VARCHAR2(1000);
    v_plo                VARCHAR2(1000);
  BEGIN
    -- Получаем покрытие
    SELECT nvl(p_cover_id, ch.p_cover_id)
          ,nvl(ch.is_handset_ins_sum, 0)
      INTO v_p_cover_id
          ,v_is_handset_ins_sum
      FROM ven_c_claim        c
          ,ven_c_claim_header ch
     WHERE c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = p_claim_id;
  
    -- Получаем сумму франшизы,тип франшизы, страховую сумму, стоимость на покрытии (в валюте претензии)
    SELECT nvl(pc.deductible_value, 0)
          ,dt.description
          ,dvt.description
          ,nvl(pc.ins_amount, 0)
          ,nvl(pc.is_proportional, 0)
          ,nvl(pc.is_aggregate, 0)
          ,nvl(pc.ins_price, 0)
      INTO v_sum
          ,v_dt
          ,v_dvt
          ,v_ins_sum
          ,v_is_proportional
          ,v_is_aggregate
          ,v_ins_price
      FROM p_cover           pc
          ,t_deductible_type dt
          ,t_deduct_val_type dvt
     WHERE v_p_cover_id = pc.p_cover_id
       AND dt.id = pc.t_deductible_type_id
       AND dvt.id = pc.t_deduct_val_type_id;
  
    -- Получаем сумму выплат по всем ущербам данного покрытия во всех предыдущих претензиях
    SELECT nvl(SUM(f_d2(d.c_damage_id, d.payment_sum)), 0)
      INTO v_payed_cover_sum
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
          ,ven_c_claim         c
          ,ven_c_claim_header  ch
     WHERE d.p_cover_id = v_p_cover_id
          --and d.c_claim_id <> p_claim_id
       AND ch.c_claim_header_id <>
           (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
          -- AND ds.BRIEF IN (/*'ОТКРЫТ',*/ 'ЗАКРЫТ')
       AND doc.get_doc_status_brief(c.c_claim_id) IN ('CLOSE');
    -- AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    -- заявленная сумма по-умолчанию
    -- opatsan
    FOR rec IN (SELECT d.c_damage_id
                      ,d.ent_id
                      ,d.declare_sum
                      ,dc.t_prod_coef_type_id id
                      ,d.c_claim_id
                      ,d.p_cover_id
                  FROM c_damage      d
                      ,t_damage_code dc
                      ,c_damage_type dt
                 WHERE d.c_claim_id = p_claim_id
                   AND dc.id = d.t_damage_code_id
                   AND dt.c_damage_type_id = d.c_damage_type_id
                   AND dt.brief = 'СТРАХОВОЙ')
    LOOP
      IF nvl(rec.declare_sum, 0) = 0
      THEN
        v_sum := pkg_tariff_calc.calc_fun(rec.id, rec.ent_id, rec.c_damage_id);
      
        IF nvl(v_sum, 0) <> 0
        THEN
          IF v_is_aggregate = 1
          THEN
            v_sum := (v_sum / v_ins_sum) * (v_ins_sum - v_payed_cover_sum);
          END IF;
        
          UPDATE c_damage d SET d.declare_sum = v_sum WHERE d.c_damage_id = rec.c_damage_id;
        END IF;
      END IF;
    END LOOP;
  
    -- Проверка на ОСАГО. Если ОСАГО. то покрываем только один тип рисков
    SELECT tplo.description
      INTO v_plo
      FROM t_prod_line_option tplo
          ,p_cover            pc
     WHERE pc.t_prod_line_option_id = tplo.id
       AND pc.p_cover_id = v_p_cover_id;
  
    -- Для непокрытых и отмененных рисков задаем сумму отказа = заявленной сумме и сумму к выплате = 0
    UPDATE c_damage d
       SET d.deduct_sum  = 0
          ,d.decline_sum = d.declare_sum
          ,d.payment_sum = 0
     WHERE d.c_claim_id = p_claim_id
       AND d.c_damage_id IN (SELECT d.c_damage_id
                               FROM ven_c_damage        d
                                   ,ven_status_hist     sh
                                   ,ven_c_damage_status ds
                              WHERE d.p_cover_id = v_p_cover_id
                                AND d.c_claim_id = p_claim_id
                                AND d.status_hist_id = sh.status_hist_id
                                AND d.c_damage_status_id = ds.c_damage_status_id
                                AND sh.brief IN ('NEW', 'CURRENT')
                                AND ds.brief NOT IN ('ОТКРЫТ', 'ЗАКРЫТ'));
  
    -- Получаем сумму заявленных убытков в валюте претензии, чтобы вычислить франшизу
    SELECT SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0))
      INTO v_declare_sum_all
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
          ,c_damage_type       dt
     WHERE d.p_cover_id = v_p_cover_id
       AND d.c_claim_id = p_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT')
          --   AND doc.get_doc_status_brief(c.c_claim_id) IN ('CLOSE')
       AND dt.c_damage_type_id = d.c_damage_type_id
       AND dt.brief = 'СТРАХОВОЙ';
  
    IF v_dvt = 'Процент'
    THEN
      IF v_dt = 'Безусловная'
         OR (v_dt = 'Условная' AND v_declare_sum_all <= ROUND(v_ins_sum * v_sum / 100, 2))
      THEN
        v_claim_deduct_sum := ROUND(v_ins_sum * v_sum / 100, 2);
      END IF;
    ELSE
      IF v_dt = 'Безусловная'
         OR (v_dt = 'Условная' AND v_declare_sum_all <= v_sum)
      THEN
        -- Пересчет франшизы по правилам пересчета кода ущерба
        -- @Marchuk A. 2008.08.16
        -- При типе значения франшизы отличном от %, требуется перевести значение в %. Для этого на коде ущерба есть специальная функция, задающая
        -- величину зависимости единицы франшизы к процентам от риска
      
        FOR rec IN (SELECT MAX(nvl(pc.deductible_value, 0) *
                               nvl(pkg_tariff_calc.calc_fun(dc.deduct_func_id, d.ent_id, d.c_damage_id)
                                  ,1)) percent
                      FROM p_cover       pc
                          ,c_damage      d
                          ,t_damage_code dc
                          ,c_damage_type dt
                     WHERE 1 = 1
                       AND d.c_claim_id = p_claim_id
                       AND dc.id = d.t_damage_code_id
                       AND dt.c_damage_type_id = d.c_damage_type_id
                       AND dt.brief = 'СТРАХОВОЙ'
                       AND pc.p_cover_id = d.p_cover_id)
        LOOP
          v_claim_deduct_sum := ROUND(v_ins_sum * rec.percent / 100, 2);
        END LOOP;
      END IF;
    END IF;
    v_claim_deduct_sum := nvl(v_claim_deduct_sum, 0);
    -- Если франшиза>=заявленной суммы, то на каждом ущербе сумма отказа=заявл. сумме и сумма выплаты=0
    IF v_claim_deduct_sum >= v_declare_sum_all
    THEN
      UPDATE c_damage d
         SET d.deduct_sum  = d.declare_sum
            ,d.decline_sum = d.declare_sum
            ,d.payment_sum = 0
       WHERE d.c_damage_id IN (SELECT d.c_damage_id
                                 FROM ven_c_damage        d
                                     ,ven_status_hist     sh
                                     ,ven_c_damage_status ds
                                     ,c_damage_type       dt
                                WHERE d.p_cover_id = v_p_cover_id
                                  AND d.c_claim_id = p_claim_id
                                  AND d.status_hist_id = sh.status_hist_id
                                  AND d.c_damage_status_id = ds.c_damage_status_id
                                  AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                  AND sh.brief IN ('NEW', 'CURRENT')
                                  AND dt.c_damage_type_id = d.c_damage_type_id
                                  AND dt.brief = 'СТРАХОВОЙ');
      RETURN;
    END IF;
    -- Вычисляем франшизу по каждому ущербу пропорционально заявленному убытку
  
    -- edited by opatsan for compability with oracle10g
    DECLARE
      v_num NUMBER;
    BEGIN
      FOR rrc IN (SELECT c_damage_id
                        ,declare_sum
                    FROM c_damage d
                   WHERE d.c_damage_id IN (SELECT d.c_damage_id
                                             FROM ven_c_damage        d
                                                 ,ven_status_hist     sh
                                                 ,ven_c_damage_status ds
                                                 ,c_damage_type       dt
                                            WHERE d.p_cover_id = v_p_cover_id
                                              AND d.c_claim_id = p_claim_id
                                              AND d.status_hist_id = sh.status_hist_id
                                              AND d.c_damage_status_id = ds.c_damage_status_id
                                              AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                              AND sh.brief IN ('NEW', 'CURRENT')
                                              AND dt.c_damage_type_id = d.c_damage_type_id
                                              AND dt.brief = 'СТРАХОВОЙ'))
      LOOP
        v_num := ROUND(f_d(rrc.c_damage_id, v_claim_deduct_sum) * nvl(rrc.declare_sum, 0) /
                       f_d(rrc.c_damage_id, v_declare_sum_all)
                      ,2);
        UPDATE c_damage SET deduct_sum = v_num WHERE c_damage_id = rrc.c_damage_id;
      END LOOP;
    END;
  
    /*    update ven_c_damage d
           set d.deduct_sum = round (f_d(d.c_damage_id, v_claim_deduct_sum) *
                                    nvl(d.declare_sum, 0) /
                                    f_d(d.c_damage_id, v_declare_sum_all),
                                    2)
         where d.c_damage_id in
               (select d.c_damage_id
                  from ven_c_damage        d,
                       ven_status_hist     sh,
                       ven_c_damage_status ds,
                       c_damage_type dt
                 where d.p_cover_id = v_p_cover_id
                   and d.c_claim_id = p_claim_id
                   and d.status_hist_id = sh.status_hist_id
                   and d.c_damage_status_id = ds.c_damage_status_id
                   and ds.BRIEF in ('ОТКРЫТ', 'ЗАКРЫТ')
                   and sh.BRIEF in ('NEW', 'CURRENT')
                   and dt.c_damage_type_id = d.c_damage_type_id and dt.brief = 'СТРАХОВОЙ');
    */
  
    -- Если больше одного ущерба
    IF SQL%ROWCOUNT > 1
    THEN
      -- Корректируем сумму франшизы на последнем ущербе, так чтобы сумма франшизы по всем ущербам была равна общей сумме франшизы
      -- Это может быть не так из-за округлений
      DECLARE
        v_last_damage_id NUMBER;
        v_s              NUMBER;
      BEGIN
        SELECT c_damage_id
          INTO v_last_damage_id
          FROM (SELECT c_damage_id
                  FROM ven_c_damage        d
                      ,ven_status_hist     sh
                      ,ven_c_damage_status ds
                      ,c_damage_type       dt
                 WHERE d.p_cover_id = v_p_cover_id
                   AND d.c_claim_id = p_claim_id
                   AND d.status_hist_id = sh.status_hist_id
                   AND d.c_damage_status_id = ds.c_damage_status_id
                   AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                   AND sh.brief IN ('NEW', 'CURRENT')
                   AND dt.c_damage_type_id = d.c_damage_type_id
                   AND dt.brief = 'СТРАХОВОЙ'
                 ORDER BY c_damage_id DESC)
         WHERE rownum < 2;
      
        SELECT SUM(nvl(f_d2(d.c_damage_id, d.deduct_sum), 0))
          INTO v_s
          FROM ven_c_damage        d
              ,ven_status_hist     sh
              ,ven_c_damage_status ds
              ,c_damage_type       dt
         WHERE d.p_cover_id = v_p_cover_id
           AND d.c_claim_id = p_claim_id
           AND d.c_damage_id <> v_last_damage_id
           AND d.status_hist_id = sh.status_hist_id
           AND d.c_damage_status_id = ds.c_damage_status_id
           AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
           AND sh.brief IN ('NEW', 'CURRENT')
           AND dt.c_damage_type_id = d.c_damage_type_id
           AND dt.brief = 'СТРАХОВОЙ';
      
        UPDATE c_damage d
           SET d.deduct_sum = f_d(d.c_damage_id, v_claim_deduct_sum - v_s)
         WHERE c_damage_id = v_last_damage_id;
      END;
    END IF;
  
    /*    -- Устанавливаем по ущербам сумму отказа с учетом франшизы и лимита по ущербу
    */
  
    /* Привенный код был до 07.08.2007 закомментирован.
    
        update ven_c_damage d
           set d.decline_sum = greatest(d.deduct_sum, d.declare_sum - f_d(d.c_damage_id, nvl(damage_perc(d.c_damage_id),0)))
         where d.c_damage_id in
               (select d.c_damage_id
                  from ven_c_damage        d,
                       ven_status_hist     sh,
                       ven_c_damage_status ds
                 where d.p_cover_id = v_p_cover_id
                   and d.c_claim_id = p_claim_id
                   and d.status_hist_id = sh.status_hist_id
                   and d.c_damage_status_id = ds.c_damage_status_id
                   and ds.BRIEF in ('ОТКРЫТ', 'ЗАКРЫТ')
                   and sh.BRIEF in ('NEW', 'CURRENT'));
    
    */
  
    /* 07.08.2007 Исправил расчет отказано как сумма лимита - сумма заявлено. При наличии отрицительной разницы
    сумма отказано устанавливаетяс как модуль разницы */
  
    --
    -- edited by opatsan for compability with oracle10g
    DECLARE
      v_num NUMBER;
    BEGIN
      FOR rrc IN (SELECT c_damage_id
                        ,declare_sum
                    FROM c_damage d
                   WHERE d.c_damage_id IN (SELECT d.c_damage_id
                                             FROM ven_c_damage        d
                                                 ,ven_status_hist     sh
                                                 ,ven_c_damage_status ds
                                            WHERE d.p_cover_id = v_p_cover_id
                                              AND d.c_claim_id = p_claim_id
                                              AND d.status_hist_id = sh.status_hist_id
                                              AND d.c_damage_status_id = ds.c_damage_status_id
                                              AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                              AND sh.brief IN ('NEW', 'CURRENT')))
      LOOP
        IF v_is_handset_ins_sum = 1
        THEN
          --Чирков Урегулирование убытков разработка/добавил условие if и то что в then/
          v_num := 0;
        ELSE
          SELECT decode(sign(rrc.declare_sum -
                             f_d(rrc.c_damage_id, nvl(damage_perc(rrc.c_damage_id), 0)))
                       ,1
                       ,abs(rrc.declare_sum -
                            f_d(rrc.c_damage_id, nvl(damage_perc(rrc.c_damage_id), 0)))
                       ,0
                       ,abs(rrc.declare_sum -
                            f_d(rrc.c_damage_id, nvl(damage_perc(rrc.c_damage_id), 0)))
                       ,0)
            INTO v_num
            FROM dual;
        END IF;
        UPDATE c_damage SET decline_sum = v_num WHERE c_damage_id = rrc.c_damage_id;
      
      END LOOP;
    END;
  
    /*
      update ven_c_damage d
         set d.decline_sum = decode(sign(d.declare_sum -
                                         f_d(d.c_damage_id,
                                             nvl(damage_perc(d.c_damage_id), 0))),
                                    1,
                                    abs(d.declare_sum -
                                        f_d(d.c_damage_id,
                                            nvl(damage_perc(d.c_damage_id), 0))),
                                    0,
                                    abs(d.declare_sum -
                                        f_d(d.c_damage_id,
                                            nvl(damage_perc(d.c_damage_id), 0))),
                                    0)
       where d.c_damage_id in
             (select d.c_damage_id
                from ven_c_damage d, ven_status_hist sh, ven_c_damage_status ds
               where d.p_cover_id = v_p_cover_id
                 and d.c_claim_id = p_claim_id
                 and d.status_hist_id = sh.status_hist_id
                 and d.c_damage_status_id = ds.c_damage_status_id
                 and ds.BRIEF in ('ОТКРЫТ', 'ЗАКРЫТ')
                 and sh.BRIEF in ('NEW', 'CURRENT'));
    */
  
    -- Проверка превышения лимиа (Марчук А.С.)
  
    -- Вычисляем сумму к выплате без учета лимитов, но с учетом франшизы, суммы отказа и пропорциональности
    IF v_is_proportional = 1
    THEN
      SELECT ROUND(SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0) -
                       nvl(f_d2(d.c_damage_id, d.decline_sum), 0)) * v_ins_price / v_ins_sum
                  ,2)
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.brief IN ('NEW', 'CURRENT');
    ELSE
      SELECT SUM(nvl(f_d2(d.c_damage_id, d.declare_sum), 0) -
                 nvl(f_d2(d.c_damage_id, d.decline_sum), 0))
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.brief IN ('NEW', 'CURRENT');
    END IF;
  
    -- Проверяем лимит по покрытию и по событию
  
    -- Получаем сумму лимита по событию
    SELECT a.ins_limit
      INTO v_event_limit_sum
      FROM ven_as_asset a
          ,ven_p_cover  p
     WHERE a.as_asset_id = p.as_asset_id
       AND p.p_cover_id = v_p_cover_id;
  
    IF v_osago_peril_brief = 'ОСАГО_ЗДОРОВЬЕ'
    THEN
      v_event_limit_sum := greatest(240000, nvl(v_event_limit_sum, 0));
    ELSIF v_osago_peril_brief = 'ОСАГО_ИМУЩЕСТВО'
    THEN
      v_event_limit_sum := greatest(160000, nvl(v_event_limit_sum, 0));
    END IF;
  
    IF v_osago_peril IS NOT NULL
    THEN
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем и покрываемым риском (для ОСАГО)
      SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
        INTO v_payed_event_sum
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
            ,ven_c_claim         c
            ,ven_c_event         e
            ,ven_c_claim_header  ch
            ,ven_p_cover         p
            ,ven_t_damage_code   damc
       WHERE
      -- Не рассматриваем текущую претензию
      --d.c_claim_id <> p_claim_id
       ch.c_claim_header_id <>
       (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
      -- Условие на актуальные версии претензий
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.c_event_id = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.c_claim_header_id = ch.c_claim_header_id
                          AND c.c_claim_id = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT')
      -- Условие на риск
       AND damc.peril = v_osago_peril
       AND damc.id = d.c_damage_id;
    ELSE
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем
      SELECT SUM(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
        INTO v_payed_event_sum
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
            ,ven_c_claim         c
            ,ven_c_event         e
            ,ven_c_claim_header  ch
            ,ven_p_cover         p
       WHERE
      -- Не рассматриваем текущую претензию
      --d.c_claim_id <> p_claim_id
       ch.c_claim_header_id <>
       (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
      -- Условие на актуальные версии претензий
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.c_event_id = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.c_claim_header_id = ch.c_claim_header_id
                          AND c.c_claim_id = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT');
    END IF;
  
    -- Если задан лимит по покрытию, то максимально возможная сумма к выплате = страх.сумма-выплаченная сумма
    IF v_is_aggregate = 1
    THEN
      v_limit := greatest(0, v_ins_sum - nvl(v_payed_cover_sum, 0));
    ELSE
      -- иначе максимально возможная сумма к выплате = страх.сумма, либо лимит на риске(в случае ОСАГО)
      IF v_osago_peril IS NULL
      THEN
        v_limit := v_ins_sum;
      ELSE
        -- select nvl(tplop.limit_amount, v_ins_sum) into v_limit from t_prod_line_opt_peril tplop
        --  where tplop.peril_id = v_osago_peril;
        IF v_osago_peril_brief = 'ОСАГО_ЗДОРОВЬЕ'
        THEN
          v_limit := 160000;
        ELSIF v_osago_peril_brief = 'ОСАГО_ИМУЩЕСТВО'
        THEN
          v_limit := 120000;
        END IF;
      END IF;
    END IF;
    -- Если задан лимит на объекте (макс. сумма по 1 страх. случаю)
    IF v_event_limit_sum IS NOT NULL
    THEN
      -- Берем минимальное из ограничений по выплате (по событию и покрытию)
      IF v_event_limit_sum - v_payed_event_sum < v_limit
      THEN
        v_limit := v_event_limit_sum - v_payed_event_sum;
        IF v_limit < 0
        THEN
          v_limit := 0;
        END IF;
      END IF;
    END IF;
    -- Если рассчитанная сумма к выплате по претензии< макс. возможной....
    IF v_limit < v_payment_sum_all
    THEN
      v_payment_sum_all := v_limit;
    END IF;
    -- конец анализа лимитов
    FOR v_damage IN (SELECT d.*
                       FROM ven_c_damage        d
                           ,ven_status_hist     sh
                           ,ven_c_damage_status ds
                      WHERE d.p_cover_id = v_p_cover_id
                        AND d.c_claim_id = p_claim_id
                        AND d.status_hist_id = sh.status_hist_id
                        AND d.c_damage_status_id = ds.c_damage_status_id
                        AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                        AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
      dbms_output.put_line('1. v_damage.payment_sum ' || v_damage.payment_sum);
      dbms_output.put_line('2. v_damage.decline_sum ' || v_damage.decline_sum);
      dbms_output.put_line('3. v_damage.deduct_sum  ' || v_damage.deduct_sum);
      dbms_output.put_line('4. v_damage.declare_sum  ' || v_damage.declare_sum);
      v_damage.payment_sum := nvl(v_damage.declare_sum, 0) - nvl(v_damage.decline_sum, 0) -
                              nvl(v_damage.deduct_sum, 0);
      dbms_output.put_line('5. v_damage.payment_sum ' || v_damage.payment_sum);
      IF nvl(v_payment_sum_all, 0) < nvl(v_damage.payment_sum, 0)
      THEN
        v_damage.payment_sum := v_payment_sum_all;
      END IF;
      /*
      v_damage.decline_sum := greatest(0,
                                       nvl(v_damage.declare_sum, 0) -
                                       nvl(v_damage.payment_sum, 0) +
                                       nvl(v_damage.deduct_sum, 0));
       */
      -- 2007.09.19 Марчук.А.С.  Расчет отказано не происходит. Для этого приложения сумма отказано - это сумма лимита + франшиза
      v_damage.decline_sum := nvl(v_damage.declare_sum - v_damage.payment_sum, 0);
      dbms_output.put_line('6. v_damage.decline_sum ' || v_damage.decline_sum);
      v_payment_sum_all := greatest(v_payment_sum_all -
                                    nvl(f_d2(v_damage.c_damage_id, v_damage.payment_sum), 0)
                                   ,0);
      UPDATE c_damage
         SET payment_sum = v_damage.payment_sum
            ,decline_sum = v_damage.decline_sum
       WHERE c_damage_id = v_damage.c_damage_id;
    END LOOP;
  END;

  /**
  * Установить версию дела как активную для заголока дела
  * @author Alexander Marchuk
  * @param par_claim_id ИД версии дела
  */

  PROCEDURE set_self_as_active_version(par_claim_id IN NUMBER) IS
    v_old_curr_claim_id NUMBER;
    v_status_date       DATE;
    v_doc_status_id     NUMBER;
    v_doc_status        doc_status%ROWTYPE;
    v_oper_templ_id     NUMBER;
    v_cover_ent_id      NUMBER;
    v_cover_obj_id      NUMBER;
    v_amount            NUMBER;
    id                  NUMBER;
  
    CURSOR c_oper_claim
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,dam.ent_id
            ,dam.c_damage_id
            ,pkg_claim_payment.get_claim_adds_sum(c.c_claim_header_id, c.c_claim_id) amount
        FROM c_claim            c
            ,c_damage           dam
            ,status_hist        sh
            ,c_damage_status    ds
            ,c_claim_header     ch
            ,c_damage_type      cdt
            ,c_damage_cost_type cdct
            ,
             
             doc_action_type    dat
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE dam.c_claim_id = c.c_claim_id
         AND dam.c_damage_status_id = ds.c_damage_status_id
         AND dam.status_hist_id = sh.status_hist_id
         AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.brief IN ('NEW', 'CURRENT')
         AND dam.c_damage_type_id = cdt.c_damage_type_id
         AND dam.c_damage_cost_type_id = cdct.c_damage_cost_type_id(+)
         AND cdt.brief = 'ДОПРАСХОД'
         AND cdct.brief = 'НЕВОЗМЕЩАЕМЫЕ'
         AND ch.c_claim_header_id = c.c_claim_header_id
         AND d.document_id = par_claim_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  BEGIN
  
    dbms_output.put_line(' Проверка на ПРОЕКТ ... ' || par_claim_id);
    -- Если статус документа = Проект, то версия должна стать активной, только если она первая
    IF doc.get_doc_status_brief(par_claim_id) = 'PROJECT'
    THEN
      RETURN;
    END IF;
    -- Прописывается в p_pol_header ссылка на активную версию полиса
    dbms_output.put_line(' Замена активной версии ... ' || par_claim_id);
    UPDATE c_claim_header ch
       SET ch.active_claim_id = par_claim_id
     WHERE ch.c_claim_header_id IN
           (SELECT cc.c_claim_header_id FROM c_claim cc WHERE cc.c_claim_id = par_claim_id);
  
    -- формирование проводок по начислению доп.расходов
    v_doc_status_id := doc.get_last_doc_status_id(par_claim_id);
    IF v_doc_status_id IS NOT NULL
    THEN
    
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      OPEN c_oper_claim(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
      LOOP
        FETCH c_oper_claim
          INTO v_oper_templ_id
              ,v_cover_ent_id
              ,v_cover_obj_id
              ,v_amount;
        EXIT WHEN c_oper_claim%NOTFOUND;
        IF v_amount <> 0
        THEN
          id := acc_new.run_oper_by_template(v_oper_templ_id
                                            ,par_claim_id
                                            ,v_cover_ent_id
                                            ,v_cover_obj_id
                                            ,v_doc_status.doc_status_ref_id
                                            ,1
                                            ,v_amount);
        END IF;
      END LOOP;
      CLOSE c_oper_claim;
    END IF;
  
    /*
          -- Предыдущей активной версии ставим статус "Завершен"
          if doc.get_doc_status_brief(par_claim_id) in ('CURRENT', 'BREAK', 'STOPED') then
               begin
                 -- Получаем дату статуса новой активной версии
                 select start_date  into v_status_date from
                  (select ds.start_date
                    from doc_status ds, doc_status_ref dsr
                      where dsr.doc_status_ref_id = ds.doc_status_ref_id
                            and dsr.brief = doc.get_doc_status_brief(par_claim_id)
                            and ds.document_id = par_claim_id
                         order by start_date desc)
                 where rownum = 1;
    
                  select cc.c_claim_id into v_old_curr_claim_id from c_claim cc where
                         cc.c_claim_id<>par_claim_id and
                        doc.get_doc_status_brief(cc.c_claim_id) = 'CURRENT' and
                        cc.c_claim_header_id in
                                     (select cc.c_claim_header_id
                                      from c_claim cc2
                                      where cc2.c_claim_id = par_claim_id);
                 doc.set_doc_status(v_old_curr_claim_id, 'STOPED', v_status_date);
    --
    
             exception when no_data_found then null;
             end;
          end if;
    */
  END;

  /**
  * Установить версию предыдущего дела как активную для заголока дела
  * @author Alexander Marchuk
  * @param par_claim_id ИД версии дела
  */

  PROCEDURE set_previous_as_active_version(par_claim_id IN NUMBER) IS
    v_status_date         DATE;
    v_new_active_claim_id NUMBER;
  BEGIN
    BEGIN
      SELECT c_claim_id
        INTO v_new_active_claim_id
        FROM ven_c_claim cc
       WHERE 1 = 1
         AND (cc.c_claim_header_id, cc.seqno) =
             (SELECT cc1.c_claim_header_id
                    ,(cc1.seqno - 1) seqno
                FROM ven_c_claim cc1
               WHERE cc1.c_claim_id = par_claim_id);
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
  
    -- Прописывается в p_pol_header ссылка на активную версию полиса
    UPDATE c_claim_header ch
       SET ch.active_claim_id = v_new_active_claim_id
     WHERE ch.c_claim_header_id IN
           (SELECT cc.c_claim_header_id FROM c_claim cc WHERE cc.c_claim_id = par_claim_id);
  
  END;

  PROCEDURE check_claim_on_policy(p_doc_id IN NUMBER) IS
    v NUMBER;
    b NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v
      FROM c_claim_header ch
     WHERE ch.p_policy_id = p_doc_id
          -- sergey.ilyushkin 25/07/2012
          -- Добавил условие проверки флага и изменил сообщение ошибки
       AND nvl(ch.is_can_cancel_policy, 0) = 0
       AND NOT EXISTS (SELECT NULL
              FROM ins.ac_payment     ac
                  ,ins.doc_doc        dd
                  ,ins.document       d
                  ,ins.doc_status_ref rf
                  ,ins.doc_templ      dt
                  ,ins.doc_set_off    dso
                  ,ins.document       d_dso
                  ,ins.doc_status_ref rf_dso
                  ,
                   /**/ins.ac_payment ac_c
                  ,ins.document   d_c
                  ,ins.doc_templ  dt_c
             WHERE ac.payment_id = dd.child_id
               AND dd.parent_id = p_doc_id
               AND ac.payment_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND d.doc_templ_id = dt.doc_templ_id
               AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
               AND rf.brief != 'ANNULATED'
               AND ac.payment_id = dso.parent_doc_id
               AND dso.doc_set_off_id = d_dso.document_id
               AND d_dso.doc_status_ref_id = rf_dso.doc_status_ref_id
               AND rf_dso.brief != 'ANNULATED'
                  /**/
               AND dso.child_doc_id = ac_c.payment_id
               AND ac_c.payment_id = d_c.document_id
               AND d_c.doc_templ_id = dt_c.doc_templ_id
               AND dt_c.brief = 'PAYORDER_SETOFF');
    IF v > 0
    THEN
      -- RAISE_APPLICATION_ERROR(-20000, 'Существуют дела по версии договора');
      raise_application_error(-20000
                             ,'Внимание! По отменяемой версии существуют дела. Пожалуйста, согласуйте отмену дел с управлением страховых выплат.');
    END IF;
    /*если по версии существует дело или есть зачет вида «Распоряжение на выплату
    возмещения взаимозачетом» ЭПГ относящемуся к версии – запретить переход
    статуса, уведомив пользователя*/
    SELECT COUNT(*)
      INTO b
      FROM c_claim_header ch
     WHERE ch.p_policy_id = p_doc_id
       AND nvl(ch.is_can_cancel_policy, 0) = 0
       AND EXISTS (SELECT NULL
              FROM ins.ac_payment     ac
                  ,ins.doc_doc        dd
                  ,ins.document       d
                  ,ins.doc_status_ref rf
                  ,ins.doc_templ      dt
                  ,ins.doc_set_off    dso
                  ,ins.document       d_dso
                  ,ins.doc_status_ref rf_dso
                  ,
                   /**/ins.ac_payment ac_c
                  ,ins.document   d_c
                  ,ins.doc_templ  dt_c
             WHERE ac.payment_id = dd.child_id
               AND dd.parent_id = p_doc_id
               AND ac.payment_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND d.doc_templ_id = dt.doc_templ_id
               AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
               AND rf.brief != 'ANNULATED'
               AND ac.payment_id = dso.parent_doc_id
               AND dso.doc_set_off_id = d_dso.document_id
               AND d_dso.doc_status_ref_id = rf_dso.doc_status_ref_id
               AND rf_dso.brief != 'ANNULATED'
                  /**/
               AND dso.child_doc_id = ac_c.payment_id
               AND ac_c.payment_id = d_c.document_id
               AND d_c.doc_templ_id = dt_c.doc_templ_id
               AND dt_c.brief = 'PAYORDER_SETOFF');
    IF b > 0
    THEN
      -- RAISE_APPLICATION_ERROR(-20000, 'Существуют дела по версии договора');
      raise_application_error(-20000
                             ,'Внимание! ЭПГ изменяемой версии зачтен взаимозачетом урегулированного убытка. Необходимо согласовать изменение версии с отделом урегулирования страховых выплат и экспертизы.');
    END IF;
    /**/
  END;

  PROCEDURE create_payments(p_doc_id IN NUMBER) IS
    v_claim_sum           NUMBER := pkg_claim_payment.get_claim_payment_sum(p_doc_id) -
                                    pkg_claim_payment.get_claim_plan_sum(p_doc_id);
    v_sum                 NUMBER := 0;
    v_company_brief       VARCHAR2(200);
    v_company_bank_acc_id NUMBER;
    v_pay_term_id         NUMBER;
  BEGIN
  
    -- если есть сумма к выплате
    IF v_claim_sum > 0
    THEN
      -- валюта,срок,полис
      FOR rec IN --15.11.2011.Чирков заменил select на цикл FOR для учета нескольких заявителей.
       (SELECT ch.fund_id                v_claim_fund_id
              ,ch.payment_term_id        v_pay_term_id
              ,ch.p_policy_id            v_policy_id
              ,cc.claim_status_date      v_status_date
              ,rt.rate_type_id           v_rt_id
              ,dt.payment_templ_id       v_templ_id
              ,cec.cn_person_id          v_declarant_id
              , --заявитель
               cd.share_payment          v_share_payment
              , --доля заявителя
               pph.fund_pay_id           v_pay_fund_id
              ,pph.policy_header_id      v_pol_header_id
              ,pph.fund_id               v_ph_fund_id
              ,cd.cn_contact_bank_acc_id
          FROM c_claim          cc
              ,c_claim_header   ch
              ,rate_type        rt
              ,ac_payment_templ dt
              ,p_policy         pp
              ,p_pol_header     pph
              ,c_declarants     cd
              ,c_event_contact  cec
         WHERE cc.c_claim_header_id = ch.c_claim_header_id
           AND cc.c_claim_id = p_doc_id
           AND rt.brief = 'ЦБ'
           AND dt.brief = 'PAYORDER_SETOFF'
           AND pp.policy_id = ch.p_policy_id
           AND pph.policy_header_id = pp.pol_header_id
           AND cd.c_claim_header_id = ch.c_claim_header_id
           AND cd.declarant_id = cec.c_event_contact_id)
      
      LOOP
        v_sum := ROUND(pkg_payment.get_to_pay_amount(rec.v_pol_header_id) *
                       acc_new.get_cross_rate_by_id(rec.v_rt_id
                                                   ,rec.v_ph_fund_id
                                                   ,rec.v_claim_fund_id
                                                   ,rec.v_status_date)
                      ,2);
        -- создаем взаимозачет
        IF v_sum > 0
        THEN
        
          --Чирков 16.12.2011 урегулирование убытков
          v_company_bank_acc_id := pkg_app_param.get_app_param_u('COMPANY_ACCOUNT');
        
          pkg_payment.create_paymnt_sheduler(rec.v_templ_id
                                            ,rec.v_pay_term_id
                                            ,least(v_sum, v_claim_sum) * rec.v_share_payment / 100
                                            ,rec.v_claim_fund_id
                                            ,rec.v_pay_fund_id
                                            ,rec.v_rt_id
                                            ,acc.get_cross_rate_by_id(rec.v_rt_id
                                                                     ,rec.v_claim_fund_id
                                                                     ,rec.v_pay_fund_id
                                                                     ,rec.v_status_date)
                                            ,rec.v_declarant_id
                                            ,rec.cn_contact_bank_acc_id
                                            ,v_company_bank_acc_id
                                            ,rec.v_status_date
                                            ,p_doc_id);
          NULL;
        END IF;
        v_pay_term_id := rec.v_pay_term_id;
      END LOOP; --end--15.11.2011.Чирков заменил select на цикл FOR для учета нескольких заявителей.
      -- создаем выплаты
      pkg_payment.claim_make_planning(p_doc_id, v_pay_term_id, 'PAYMENT');
    END IF;
  END;

  PROCEDURE setoff_status(p_doc_id IN NUMBER) IS
    v_status_date DATE;
  BEGIN
    SELECT c.claim_status_date INTO v_status_date FROM c_claim c WHERE c.c_claim_id = p_doc_id;
  
    FOR rc IN (SELECT ap.payment_id
                 FROM ac_payment ap
                     ,doc_doc    dd
                WHERE dd.parent_id = p_doc_id
                  AND dd.child_id = ap.payment_id)
    LOOP
      doc.set_doc_status(rc.payment_id, 'TO_PAY', v_status_date);
    END LOOP;
  END;

  PROCEDURE setoff_cancel(p_doc_id IN NUMBER) IS
    v_status_date DATE;
  BEGIN
    SELECT c.claim_status_date INTO v_status_date FROM c_claim c WHERE c.c_claim_id = p_doc_id;
  
    FOR rc IN (SELECT ap.payment_id
                 FROM ac_payment ap
                     ,doc_doc    dd
                WHERE dd.parent_id = p_doc_id
                  AND dd.child_id = ap.payment_id)
    LOOP
      doc.set_doc_status(rc.payment_id, 'NEW', v_status_date + 1 / 24 / 3600);
    END LOOP;
  END;

  PROCEDURE setoff_delete(p_doc_id IN NUMBER) IS
  BEGIN
    -- Байтин А.
    -- Заявка 263911
    DELETE FROM /*ven_ac_payment*/ document p
     WHERE /*p.payment_id*/
     p.document_id IN (SELECT dd.child_id FROM doc_doc dd WHERE dd.parent_id = p_doc_id);
  END;

  FUNCTION get_compensation_limit
  (
    par_damage_code_id IN NUMBER
   ,par_cover_id       IN NUMBER
   ,par_claim_id       IN NUMBER
  ) RETURN NUMBER IS
    v_paym_order_brief  VARCHAR2(30);
    v_ret_val           NUMBER;
    v_ins_amount        NUMBER;
    v_comp_limit        NUMBER;
    v_claim_id          NUMBER;
    v_claim_header_id   NUMBER;
    v_policy_header_id  NUMBER;
    par_claim_header_id NUMBER;
    v_attribut_id       NUMBER;
  BEGIN
    SELECT po.brief
          ,pc.ins_amount
          ,pp.compensation_limit
          ,ph.policy_header_id
          ,cc.c_claim_header_id
          ,ta.t_attribut_id
      INTO v_paym_order_brief
          ,v_ins_amount
          ,v_comp_limit
          ,v_policy_header_id
          ,par_claim_header_id
          ,v_attribut_id
      FROM p_cover         pc
          ,as_asset        ass
          ,p_policy        pp
          ,p_pol_header    ph
          ,t_payment_order po
          ,c_claim         cc
          ,t_attribut      ta
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = ass.as_asset_id
       AND ass.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.t_prod_payment_order_id = po.t_payment_order_id(+)
       AND cc.c_claim_id(+) = par_claim_id
       AND ta.brief = 'PROPERTY_NON_DESCR';
  
    CASE v_paym_order_brief
    
    /* Первый риск ------ ЛО = страховая сумма по программе */
      WHEN 'NO_PROPORTIONAL' THEN
        v_ret_val := v_ins_amount;
      
    /* Лимит возмещения по событию------ЛО = Лимит с договора  */
      WHEN 'PAYMENT_LIMIT_EVENT' THEN
        v_ret_val := v_comp_limit;
      
    /* Лимит возмещения по договору------ЛО =
                                                                                                    страховая сумма по программе - заявленные
                                                                                                    убытки по договору (сумма к ваплате по всем
                                                                                                    заявленным претензиям по договору) */
      WHEN 'PAYMENT_LIMIT_POLICY' THEN
        SELECT SUM(dam.payment_sum) payment_sum
          INTO v_ret_val
          FROM c_damage           dam
              ,c_damage_status    ds
              ,status_hist        sh
              ,c_claim            c
              ,c_damage_type      dt
              ,c_damage_cost_type dct
              ,p_policy           pp
              ,c_claim_header     ch
         WHERE pp.pol_header_id = v_policy_header_id
           AND ch.p_policy_id = pp.policy_id
           AND c.c_claim_id = ch.active_claim_id
           AND dam.c_claim_id = c.c_claim_id
           AND dam.c_damage_status_id = ds.c_damage_status_id
           AND dam.status_hist_id = sh.status_hist_id
           AND dam.c_damage_type_id = dt.c_damage_type_id
           AND dam.c_damage_cost_type_id = dct.c_damage_cost_type_id(+)
           AND (dt.brief = 'СТРАХОВОЙ' OR dct.brief = 'ВОЗМЕЩАЕМЫЕ')
           AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
           AND sh.brief IN ('NEW', 'CURRENT')
           AND (c.c_claim_id <> par_claim_id OR dam.t_damage_code_id <> par_damage_code_id);
      
        v_ret_val := v_ins_amount - v_ret_val;
      
    /* Лимит возмещение по первому случаю------
                                                                                                    ЛО = если по договору нет других претензий,
                                                                                                    то лимит с договора, иначе 0 */
      WHEN 'FIRST_LOSS' THEN
        BEGIN
          SELECT c_claim_header_id
            INTO v_claim_header_id
            FROM (SELECT ch.c_claim_header_id
                        ,rownum rn
                    FROM c_claim_header ch
                        ,p_policy       pp
                   WHERE ch.p_policy_id = pp.policy_id
                     AND pp.pol_header_id = v_policy_header_id
                   ORDER BY ch.declare_date
                           ,ch.c_claim_header_id)
           WHERE rn = 1;
        EXCEPTION
          WHEN no_data_found THEN
            v_claim_header_id := par_claim_header_id;
        END;
        IF v_claim_header_id = par_claim_header_id
        THEN
          v_ret_val := v_comp_limit;
        ELSE
          v_ret_val := 0;
        END IF;
      
    /* Пропорциональный------ЛО = страховая сумма по программе */
      WHEN 'PROPORTIONAL' THEN
        v_ret_val := v_ins_amount;
      
    /* Неснижаемый остаток-------ЛО = Аргумент PROPERTY_NON_DESCR возвращает сумму неснижаемого остатка. Если ее нет, то 0. */
      WHEN 'NON_DECR' THEN
        BEGIN
          v_ret_val := nvl(pkg_tariff_calc.get_attribut(ent.id_by_brief('P_COVER')
                                                       ,par_cover_id
                                                       ,v_attribut_id)
                          ,0);
        EXCEPTION
          WHEN OTHERS THEN
            v_ret_val := 0;
        END;
      ELSE
        v_ret_val := v_ins_amount;
    END CASE;
  
    RETURN v_ret_val;
  
  END;

  FUNCTION get_min_num_event(p_event_id NUMBER) RETURN NUMBER IS
    p_p_min_num NUMBER;
  BEGIN
  
    BEGIN
      SELECT MIN(to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))))
        INTO p_p_min_num
        FROM ven_c_claim_header ch
            ,p_cover            pc
            ,t_prod_line_option pl
       WHERE ch.c_event_id = p_event_id
         AND ch.p_cover_id = pc.p_cover_id(+)
         AND pc.t_prod_line_option_id = pl.id(+)
         AND pl.description IN ('Защита страховых взносов'
                               ,'Защита страховых взносов рассчитанная по основной программе'
                               ,'Освобождение от уплаты взносов рассчитанное по основной программе'
                               ,'Освобождение от уплаты дальнейших взносов'
                               ,'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе'
                               ,'Освобождение от уплаты страховых взносов');
    EXCEPTION
      WHEN no_data_found THEN
        p_p_min_num := 0;
    END;
  
    RETURN p_p_min_num;
  
  END;

  FUNCTION get_epg_to_event
  (
    p_event_id   NUMBER
   ,p_num_event  VARCHAR2
   ,p_event_date DATE
   ,p_date_first DATE
   ,p_period     NUMBER
  ) RETURN DATE IS
    p_p_min_num     NUMBER;
    p_p_num         NUMBER;
    p_p_date_return DATE;
    i               NUMBER := 0;
    p_p_mnt         NUMBER;
    p_p_koef        NUMBER;
    p_p_num_sq      NUMBER;
    n               NUMBER := 0;
    sq              NUMBER := 0;
  BEGIN
  
    FOR rc IN (SELECT to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))) p_p_num_sq
                 FROM ven_c_claim_header ch
                     ,p_cover            pc
                     ,t_prod_line_option pl
                WHERE ch.c_event_id = p_event_id
                  AND ch.p_cover_id = pc.p_cover_id(+)
                  AND pc.t_prod_line_option_id = pl.id(+)
                  AND to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))) <=
                      to_number(TRIM(substr(p_num_event, instr(p_num_event, '/') + 1)))
                  AND pl.description IN ('Защита страховых взносов'
                                        ,'Защита страховых взносов рассчитанная по основной программе'
                                        ,'Освобождение от уплаты взносов рассчитанное по основной программе'
                                        ,'Освобождение от уплаты дальнейших взносов'
                                        ,'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе'
                                        ,'Освобождение от уплаты страховых взносов')
                ORDER BY to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))))
    LOOP
      IF rc.p_p_num_sq = n + 1
      THEN
        NULL;
      ELSE
        sq := sq + 1;
      END IF;
      n := rc.p_p_num_sq;
    END LOOP;
  
    p_p_date_return := to_date('01.01.1900', 'dd.mm.yyyy');
  
    BEGIN
      SELECT MIN(to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))))
        INTO p_p_min_num
        FROM ven_c_claim_header ch
            ,p_cover            pc
            ,t_prod_line_option pl
       WHERE ch.c_event_id = p_event_id
         AND ch.p_cover_id = pc.p_cover_id(+)
         AND pc.t_prod_line_option_id = pl.id(+)
         AND pl.description IN ('Защита страховых взносов'
                               ,'Защита страховых взносов рассчитанная по основной программе'
                               ,'Освобождение от уплаты взносов рассчитанное по основной программе'
                               ,'Освобождение от уплаты дальнейших взносов'
                               ,'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе'
                               ,'Освобождение от уплаты страховых взносов');
    EXCEPTION
      WHEN no_data_found THEN
        p_p_min_num := 0;
    END;
  
    BEGIN
      SELECT rn --, d_number, num
        INTO p_p_num
        FROM (SELECT rownum rn
                    ,d_number
                    ,num
                FROM (SELECT to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))) d_number
                            ,d.num
                        FROM ven_c_claim_header ch
                        LEFT JOIN (SELECT to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))) num_d
                                        ,ch.num
                                    FROM ven_c_claim_header ch
                                   WHERE ch.c_event_id = p_event_id
                                     AND ch.num = p_num_event) d
                          ON (d.num_d = to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))))
                       WHERE ch.c_event_id = p_event_id
                       ORDER BY to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1)))))
       WHERE num <> ''
          OR num IS NOT NULL;
    EXCEPTION
      WHEN no_data_found THEN
        p_p_num := -1;
    END;
  
    SELECT trunc(MONTHS_BETWEEN(p_event_date, p_date_first)) INTO p_p_mnt FROM dual;
    SELECT FLOOR(p_p_mnt / p_period) INTO p_p_koef FROM dual;
  
    IF p_p_num >= 0
    THEN
      p_p_date_return := ADD_MONTHS(p_date_first
                                   ,p_period * (p_p_koef + (p_p_num - (p_p_min_num + sq) + 1)));
      /*   WHILE p_p_date_return < p_event_date LOOP
       i := i + 1;
       p_p_date_return := add_months(p_date_first, p_period * (p_p_num + i));
      END LOOP;*/
    END IF;
  
    RETURN p_p_date_return;
  
  END;

  FUNCTION get_payed_cover_sum
  (
    p_claim_id NUMBER
   ,p_cover_id NUMBER
  ) RETURN NUMBER IS
    v_sum NUMBER;
  BEGIN
    SELECT SUM(f_d2(d.c_damage_id, d.payment_sum))
      INTO v_sum
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
          ,ven_c_claim         c
          ,ven_c_claim_header  ch
     WHERE d.p_cover_id = get_payed_cover_sum.p_cover_id
       AND ch.c_claim_header_id <>
           (SELECT c_claim_header_id FROM ven_c_claim WHERE c_claim_id = p_claim_id)
       AND d.c_claim_id = get_curr_claim(ch.c_claim_header_id)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND doc.get_doc_status_brief(c.c_claim_id) IN ('CLOSE');
    --  AND ds.BRIEF IN('ОТКРЫТ', 'ЗАКРЫТ')
    --  AND sh.BRIEF IN('NEW', 'CURRENT');
  
    RETURN nvl(v_sum, 0);
  END get_payed_cover_sum;

  PROCEDURE contact_date_death(p_claim_id NUMBER) IS
    proc_name VARCHAR2(35) := 'contact_date_death';
    not_exist_holder  EXCEPTION;
    not_exist_insurer EXCEPTION;
  BEGIN
  
    FOR rc IN (SELECT ch.active_claim_id
                     ,p.pol_num
                     ,e.num
                     ,tp.description
                     ,e.event_date
                     ,cas.contact_id contact_asset_id
                     ,ent.obj_name(a.ent_id, a.as_asset_id) asset_name
                     ,(SELECT con.contact_id
                         FROM ven_p_policy           pol
                             ,ven_as_asset           ass
                             ,ven_p_policy_contact   pc
                             ,ven_contact            con
                             ,ven_t_contact_pol_role tpr
                        WHERE ass.as_asset_id = ch.as_asset_id
                          AND pol.policy_id = ass.p_policy_id
                          AND pol.policy_id = pc.policy_id
                          AND pc.contact_policy_role_id = tpr.id
                          AND tpr.brief = 'Страхователь'
                          AND con.contact_id = pc.contact_id) contact_holder_id
                 FROM ven_c_claim_header ch
                     ,ven_p_policy       p
                      --ven_c_declarant_role   dr,
                     ,ven_c_event e
                      --,ven_cn_person          per
                      --ven_c_event_contact    ec,
                      --ven_contact            c,
                     ,ven_department         ct
                     ,ven_as_asset           a
                     ,as_assured             asr
                     ,contact                cas
                     ,ven_fund               f
                     ,ven_c_claim_metod_type cmt
                     ,ven_p_cover            pc
                     ,ven_t_prod_line_option pl
                     ,ven_p_pol_header       ph
                     ,ven_t_product          prod
                     ,ven_t_peril            tp
                WHERE ch.notice_type_id = cmt.c_claim_metod_type_id
                     --and ch.declarant_role_id = dr.c_declarant_role_id
                  AND ch.p_policy_id = p.policy_id
                  AND ch.c_event_id = e.c_event_id
                     --Чирков удаление старых связей заявителей
                     --and ch.declarant_id = ec.c_event_contact_id
                     --and ec.cn_person_id = c.contact_id
                     --end_Чирков удаление старых связей заявителей
                  AND prod.product_id = ph.product_id
                  --AND ch.curator_id = per.contact_id
                  AND ch.depart_id = ct.department_id(+)
                  AND ch.as_asset_id = a.as_asset_id
                  AND a.as_asset_id = asr.as_assured_id
                  AND asr.assured_contact_id = cas.contact_id
                  AND ch.fund_id = f.fund_id(+)
                  AND ch.p_cover_id = pc.p_cover_id(+)
                  AND pc.t_prod_line_option_id = pl.id(+)
                  AND ph.policy_header_id = p.pol_header_id
                  AND tp.id(+) = ch.peril_id
                     
                  AND tp.description IN ('Смерть Застрахованного по любой причине'
                                        ,'Смерть застрахованного в результате несчастного случая'
                                        ,'Смерть застрахованного в результате болезни или несчастного случая'
                                        ,'Смерть Страхователя'
                                        ,'Смерть страхователя')
                  AND ch.active_claim_id = p_claim_id)
    
    LOOP
    
      IF (rc.description = ('Смерть Застрахованного по любой причине') OR
         rc.description = ('Смерть застрахованного в результате несчастного случая') OR
         rc.description = ('Смерть застрахованного в результате болезни или несчастного случая'))
      THEN
      
        IF nvl(rc.active_claim_id, 0) > 0
           AND nvl(rc.contact_asset_id, 0) > 1
        THEN
          UPDATE cn_person per
             SET per.date_of_death = rc.event_date
           WHERE per.contact_id = rc.contact_asset_id;
        ELSE
          RAISE not_exist_insurer;
        END IF;
      
      ELSIF (rc.description = ('Смерть Страхователя') OR rc.description = ('Смерть страхователя'))
      THEN
      
        IF nvl(rc.active_claim_id, 0) > 0
           AND nvl(rc.contact_holder_id, 0) > 1
        THEN
          UPDATE cn_person per
             SET per.date_of_death = rc.event_date
           WHERE per.contact_id = rc.contact_holder_id;
        ELSE
          RAISE not_exist_holder;
        END IF;
      
      ELSE
        NULL;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN not_exist_insurer THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Не хватает параметров для проставления даты смерти у контакта Застрахованного.');
    WHEN not_exist_holder THEN
      raise_application_error(-20001
                             ,'Невозможен переход. Не хватает параметров для проставления даты смерти у контакта Страхователя.');
    
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END contact_date_death;

  PROCEDURE annulate_ppi(p_claim_id NUMBER) IS
    v_req_number  ac_payment_add_info.nav_req_number%TYPE;
    v_cancel_date DATE := SYSDATE;
  BEGIN
    BEGIN
      SELECT ai.nav_req_number
        INTO v_req_number
        FROM ven_c_claim_header  cch
            ,c_claim             cc
            ,ins.doc_doc         dd
            ,ven_ac_payment      ac
            ,doc_templ           dt
            ,doc_set_off         dso
            ,ven_ac_payment      ppi
            ,doc_templ           dt_ppi
            ,ac_payment_add_info ai
       WHERE cch.c_claim_header_id = cc.c_claim_header_id
         AND dd.parent_id = cc.c_claim_id
         AND dd.child_id = ac.payment_id
         AND dt.doc_templ_id = ac.doc_templ_id
         AND dt.brief = 'PAYORDER'
         AND cc.c_claim_id = p_claim_id
         AND dso.parent_doc_id = ac.payment_id
         AND dso.child_doc_id = ppi.payment_id
         AND doc.get_doc_status_brief(dso.doc_set_off_id) != ('ANNULATED')
         AND ppi.doc_templ_id = dt_ppi.doc_templ_id
         AND dt_ppi.brief = 'ППИ'
         AND ppi.payment_id = ai.ac_payment_add_info_id(+)
         AND (ai.nav_req_number IS NOT NULL OR ppi.due_date IS NOT NULL)
         AND rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN OTHERS THEN
        raise_application_error(-20000, 'Ошибка анулирования ППИ.');
    END;
    IF v_req_number IS NOT NULL
    THEN
      raise_application_error(-20000
                             ,'Внимание. По данному делу создан реквест №' || v_req_number);
    END IF;
  
    FOR rec IN (SELECT ppi.payment_id
                      ,dso.doc_set_off_id
                      ,nvl(dsr_dso.brief, 'NULL') dso_brief
                  FROM ven_c_claim_header  cch
                      ,c_claim             cc
                      ,c_claim             cc_vipl
                      ,ins.doc_doc         dd
                      ,ven_ac_payment      ac
                      ,doc_templ           dt
                      ,doc_set_off         dso
                      ,ven_ac_payment      ppi
                      ,doc_templ           dt_ppi
                      ,ac_payment_add_info ai
                      ,document            d_dso
                      ,doc_status_ref      dsr_dso
                 WHERE cch.c_claim_header_id = cc.c_claim_header_id
                   AND cc_vipl.c_claim_header_id = cc.c_claim_header_id --Чирков 22.06.2012
                   AND dd.parent_id = cc_vipl.c_claim_id
                   AND dd.child_id = ac.payment_id
                   AND dt.doc_templ_id = ac.doc_templ_id
                   AND dt.brief = 'PAYORDER'
                   AND cc.c_claim_id = p_claim_id
                   AND dso.parent_doc_id = ac.payment_id
                   AND dso.child_doc_id = ppi.payment_id
                   AND d_dso.document_id = dso.doc_set_off_id
                   AND dsr_dso.doc_status_ref_id(+) = d_dso.doc_status_ref_id
                   AND nvl(dsr_dso.brief, 'NULL') != ('ANNULATED')
                   AND ppi.doc_templ_id = dt_ppi.doc_templ_id
                   AND dt_ppi.brief = 'ППИ'
                   AND ppi.payment_id = ai.ac_payment_add_info_id(+)
                   AND ai.nav_req_number IS NULL
                   AND ppi.due_date IS NULL)
    LOOP
      doc.set_doc_status(rec.payment_id, 'ANNULATED');
    
      IF rec.dso_brief != 'NULL'
      THEN
        --документ добавлен
        UPDATE ven_doc_set_off
           SET cancel_date = v_cancel_date
         WHERE doc_set_off_id = rec.doc_set_off_id;
      
        doc.set_doc_status(rec.doc_set_off_id, 'ANNULATED', v_cancel_date);
      ELSE
        DELETE FROM ven_doc_set_off dso WHERE dso.doc_set_off_id = rec.doc_set_off_id;
      END IF;
    END LOOP;
  
  END;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  FUNCTION damage_decline_reason
  (
    par_p_cover_id NUMBER
   ,par_c_claim_id NUMBER
  ) RETURN VARCHAR2 IS
    p_buf     VARCHAR2(650) := '';
    func_name VARCHAR2(25) := 'damage_decline_reason';
  BEGIN
    FOR cur IN (SELECT dmg.decline_reason
                  FROM c_damage dmg
                 WHERE dmg.p_cover_id = par_p_cover_id
                   AND dmg.c_claim_id = par_c_claim_id)
    LOOP
      p_buf := p_buf || cur.decline_reason || ' ';
    END LOOP;
  
    RETURN p_buf;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || func_name || chr(10));
  END damage_decline_reason;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  FUNCTION ret_amount_active
  (
    p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(nvl(csh.amount, 0)) amount
      INTO RESULT
      FROM v_claim_payment_schedule csh
     WHERE csh.c_claim_header_id = p_claim_header
       AND csh.doc_templ_brief = p_flag;
    RETURN(RESULT);
  END;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  --Веселуха 14.09.2009
  FUNCTION ret_amount_claim
  (
    p_event_id     NUMBER
   ,p_claim_header NUMBER
   ,p_flag         VARCHAR2
  ) RETURN NUMBER IS
    RESULT   NUMBER;
    spaym    NUMBER;
    spaymord NUMBER;
    v_sum    NUMBER;
  BEGIN
    spaym    := 0;
    spaymord := 0;
    v_sum    := 0;
  
    FOR rec IN (SELECT ch.document_id
                      ,decode(ch.doc_templ_brief, 'PAYORDER_SETOFF', 'З', 'PAYORDER', 'В', 'Н') flag
                  FROM v_claim_payment_schedule ch
                 WHERE ch.c_claim_header_id = p_claim_header
                   AND decode(ch.doc_templ_brief, 'PAYORDER_SETOFF', 'З', 'PAYORDER', 'В', 'Н') =
                       p_flag)
    LOOP
    
      IF nvl(rec.flag, 'Н') = 'З'
      THEN
      
        SELECT SUM(nvl(cd.rev_amount, 0) -
                   nvl(pkg_payment.get_paym_set_off_amount(t.child_doc_id, t.doc_set_off_id), 0))
          INTO spaymord
          FROM doc_set_off        t
              ,ac_payment         pd
              ,ac_payment         cd
              ,ins.document       d
              ,ins.doc_status_ref dsr
         WHERE t.parent_doc_id = pd.payment_id
           AND t.child_doc_id = cd.payment_id
           AND d.document_id = t.doc_set_off_id
           AND dsr.doc_status_ref_id = d.doc_status_ref_id
           AND dsr.brief != 'ANNULATED'
           AND t.cancel_date IS NULL
           AND t.child_doc_id = rec.document_id;
        /* select sum(nvl(cd.rev_AMOUNT,0) - nvl(pkg_payment.get_paym_set_off_amount(t.child_doc_id,t.doc_set_off_id),0))
                --sum(round(nvl(cd.amount,0) * nvl(cd.rev_rate,0), 2))
                into sPaym
                from VEN_DOC_SET_OFF  t,
                     ven_ac_payment   pd,
                     ven_ac_payment   cd,
                     Fund             f,
                     Fund             cf,
                     Fund             pdf,
                     Fund             pdpf,
                     Fund             cdf,
                     contact          pc,
                     contact          cc,
                     doc_templ        pdt,
                     doc_templ        cdt,
                     rate_type        rt,
                     ac_payment_templ ppt,
                     ac_payment_templ cpt,
                     ins.document         d,
                     ins.doc_status_ref   dsr
               where t.Parent_Doc_id = pd.payment_id
                 and t.child_doc_id = cd.payment_id
                 and t.set_off_fund_id = f.fund_id
                 and t.set_off_child_fund_id = cf.fund_id
                 and pd.contact_id = pc.contact_id
                 and cd.contact_id = cc.contact_id
                 and pd.doc_templ_id = pdt.doc_templ_id
                 and cd.doc_templ_id = cdt.doc_templ_id
                 and pd.fund_id = pdf.fund_id
                 and cd.fund_id = cdf.fund_id
                 and pd.rev_fund_id = pdpf.fund_id
                 and pd.rev_rate_type_id = rt.rate_type_id(+)
                 and pdt.doc_templ_id = ppt.doc_templ_id
                 and cdt.doc_templ_id = cpt.doc_templ_id
                 and d.document_id = t.doc_set_off_id
                 and dsr.doc_status_ref_id = d.doc_status_ref_id
                 and dsr.brief != 'ANNULATED'
                 and t.cancel_date is null
                 and t.child_doc_id = rec.document_id;
        */
      ELSE
        SELECT SUM(nvl(cd.amount, 0) -
                   nvl(pkg_payment.get_paym_set_off_amount(t.child_doc_id, t.doc_set_off_id), 0))
          INTO spaym
          FROM doc_set_off        t
              ,ac_payment         pd
              ,ac_payment         cd
              ,ins.document       d
              ,ins.doc_status_ref dsr
         WHERE t.parent_doc_id = pd.payment_id
           AND t.child_doc_id = cd.payment_id
           AND d.document_id = t.doc_set_off_id
           AND dsr.doc_status_ref_id = d.doc_status_ref_id
           AND dsr.brief != 'ANNULATED'
           AND t.cancel_date IS NULL
           AND t.parent_doc_id = rec.document_id;
      
        /*        select sum(nvl(cd.rev_AMOUNT,0) - nvl(pkg_payment.get_paym_set_off_amount(t.child_doc_id,t.doc_set_off_id),0))
                --sum(round(nvl(cd.amount,0) * nvl(cd.rev_rate,0), 2))
                into sPaymOrd
                  from VEN_DOC_SET_OFF  t,
                       ven_ac_payment   pd,
                       ven_ac_payment   cd,
                       Fund             f,
                       Fund             cf,
                       Fund             pdf,
                       Fund             pdpf,
                       Fund             cdf,
                       contact          pc,
                       contact          cc,
                       doc_templ        pdt,
                       doc_templ        cdt,
                       rate_type        rt,
                       ac_payment_templ ppt,
                       ac_payment_templ cpt,
                       ins.document         d,
                       ins.doc_status_ref   dsr
                 where t.Parent_Doc_id = pd.payment_id
                   and t.child_doc_id = cd.payment_id
                   and t.set_off_fund_id = f.fund_id
                   and t.set_off_child_fund_id = cf.fund_id
                   and pd.contact_id = pc.contact_id
                   and cd.contact_id = cc.contact_id
                   and pd.doc_templ_id = pdt.doc_templ_id
                   and cd.doc_templ_id = cdt.doc_templ_id
                   and pd.fund_id = pdf.fund_id
                   and cd.fund_id = cdf.fund_id
                   and pd.rev_fund_id = pdpf.fund_id
                   and pd.rev_rate_type_id = rt.rate_type_id(+)
                   and pdt.doc_templ_id = ppt.doc_templ_id
                   and cdt.doc_templ_id = cpt.doc_templ_id
                   and d.document_id = t.doc_set_off_id
                   and dsr.doc_status_ref_id = d.doc_status_ref_id
                   and dsr.brief != 'ANNULATED'
                   and t.cancel_date is null
                   and t.parent_doc_id = rec.document_id;
        */
      END IF;
      v_sum    := v_sum + nvl(spaymord, 0) + nvl(spaym, 0); --Чирков Урегулирование убытков разработка
      spaymord := 0;
      spaym    := 0;
    END LOOP;
    --result := nvl(sPaymOrd,0) + nvl(sPaym,0); --Чирков Урегулирование убытков разработка /комментировал, т.к. у выплаты может быть несколько ППИ/
  
    /*select sum(nvl(s.child_doc_amount,0)) amount--sum(nvl(s.set_off_amount,0)) amount
    into result
    from tmptable_input_data vp,
         tmptable_input_datac s
    where --s.parent_doc_id = vp.document_id
          s.child_doc_id = vp.document_id
          and vp.c_event_id = p_event_id
          and vp.flag = p_flag
          and vp.c_claim_header_id = p_claim_header;*/
    RETURN(v_sum);
  
  END;
  /*
    Байтин А.
    Перенесено из PKG_RENLIFE_UTILS
  */
  --Веселуха 14.09.2009
  FUNCTION ret_sod_claim(p_claim_header NUMBER) RETURN DATE IS
    RESULT          DATE;
    v_date_spaym    DATE;
    v_date_spaymord DATE;
  BEGIN
  
    FOR rec IN (SELECT ch.document_id
                      ,decode(ch.doc_templ_brief, 'PAYORDER_SETOFF', 'З', 'PAYORDER', 'В', 'Н') flag
                  FROM v_claim_payment_schedule ch
                 WHERE ch.c_claim_header_id = p_claim_header)
    LOOP
    
      IF nvl(rec.flag, 'Н') = 'З'
      THEN
      
        SELECT MAX(t.set_off_date)
          INTO v_date_spaym
          FROM ven_doc_set_off  t
              ,ven_ac_payment   pd
              ,ven_ac_payment   cd
              ,fund             f
              ,fund             cf
              ,fund             pdf
              ,fund             pdpf
              ,fund             cdf
              ,contact          pc
              ,contact          cc
              ,doc_templ        pdt
              ,doc_templ        cdt
              ,rate_type        rt
              ,ac_payment_templ ppt
              ,ac_payment_templ cpt
         WHERE t.parent_doc_id = pd.payment_id
           AND t.child_doc_id = cd.payment_id
           AND t.set_off_fund_id = f.fund_id
           AND t.set_off_child_fund_id = cf.fund_id
           AND pd.contact_id = pc.contact_id
           AND cd.contact_id = cc.contact_id
           AND pd.doc_templ_id = pdt.doc_templ_id
           AND cd.doc_templ_id = cdt.doc_templ_id
           AND pd.fund_id = pdf.fund_id
           AND cd.fund_id = cdf.fund_id
           AND pd.rev_fund_id = pdpf.fund_id
           AND pd.rev_rate_type_id = rt.rate_type_id(+)
           AND pdt.doc_templ_id = ppt.doc_templ_id
           AND cdt.doc_templ_id = cpt.doc_templ_id
           AND t.child_doc_id = rec.document_id;
      
      ELSE
      
        SELECT MAX(t.set_off_date)
          INTO v_date_spaymord
          FROM ven_doc_set_off  t
              ,ven_ac_payment   pd
              ,ven_ac_payment   cd
              ,fund             f
              ,fund             cf
              ,fund             pdf
              ,fund             pdpf
              ,fund             cdf
              ,contact          pc
              ,contact          cc
              ,doc_templ        pdt
              ,doc_templ        cdt
              ,rate_type        rt
              ,ac_payment_templ ppt
              ,ac_payment_templ cpt
         WHERE t.parent_doc_id = pd.payment_id
           AND t.child_doc_id = cd.payment_id
           AND t.set_off_fund_id = f.fund_id
           AND t.set_off_child_fund_id = cf.fund_id
           AND pd.contact_id = pc.contact_id
           AND cd.contact_id = cc.contact_id
           AND pd.doc_templ_id = pdt.doc_templ_id
           AND cd.doc_templ_id = cdt.doc_templ_id
           AND pd.fund_id = pdf.fund_id
           AND cd.fund_id = cdf.fund_id
           AND pd.rev_fund_id = pdpf.fund_id
           AND pd.rev_rate_type_id = rt.rate_type_id(+)
           AND pdt.doc_templ_id = ppt.doc_templ_id
           AND cdt.doc_templ_id = cpt.doc_templ_id
           AND t.parent_doc_id = rec.document_id;
      
      END IF;
    END LOOP;
  
    IF nvl(v_date_spaymord, '01.01.1900') > nvl(v_date_spaym, '01.01.1900')
    THEN
      RESULT := v_date_spaymord;
    ELSE
      RESULT := v_date_spaym;
    END IF;
    /*select n.set_off_date
    into result
    from
    (select max(s.set_off_date) set_off_date,
            vp.c_event_id
     from tmptable_input_data vp,
          tmptable_input_datac s
     where s.parent_doc_id = vp.document_id
           and vp.c_event_id = p_event_id
           and vp.flag = p_flag
           and vp.c_claim_header_id = p_claim_header
     group by vp.c_event_id) n;*/
    RETURN(RESULT);
  END;

  /* Процедура создает назначение платежа для Выплаты по ПС на переходе статусов Док добавлен->Новый 
  *
  *--299415: FW: назначение платежа
  * @autor Чирков
  * @param par_doc_id - документ выплата по ПС (PAYORDER)
  */
  PROCEDURE create_purpose4payorder(par_doc_id NUMBER) AS
    v_peril_id   NUMBER;
    v_c_event_id NUMBER;
    v_purpose    document.note%TYPE;
    v_payord_id  NUMBER;
  BEGIN
    --формируем назначения платежа по всем выплатам по всем подделам
    --в статусе активной версии = приянто решение 
    FOR rec IN (SELECT cch.peril_id
                      ,cch.c_event_id
                      ,ac.payment_id
                  FROM c_claim            cc
                      ,ven_c_claim_header cch
                      ,ven_c_claim_header cch_
                      ,c_claim            cc_
                      ,ins.doc_doc        dd
                      ,ven_ac_payment     ac
                      ,doc_templ          dt
                 WHERE cc.c_claim_id = par_doc_id
                      --
                   AND cch.c_claim_header_id = cc.c_claim_header_id
                   AND cch.c_event_id = cch_.c_event_id
                   AND cch_.c_claim_header_id = cc_.c_claim_header_id
                      --and cch_.active_claim_id = cc_.c_claim_id
                   AND dd.parent_id = cc_.c_claim_id
                   AND dd.child_id = ac.payment_id
                   AND dt.doc_templ_id = ac.doc_templ_id
                   AND dt.brief = 'PAYORDER'
                      --активная версия по подделу в статусе принято решение       
                   AND EXISTS (SELECT 1
                          FROM c_claim        cc2
                              ,document       d_cc
                              ,doc_status_ref dsr_cc
                         WHERE cc2.c_claim_id = cch_.active_claim_id
                           AND d_cc.document_id = cc2.c_claim_id
                           AND dsr_cc.doc_status_ref_id = d_cc.doc_status_ref_id
                           AND dsr_cc.brief = 'DECISION'))
    LOOP
      --формируем назначение платежа  
      v_purpose := get_purpose4request(rec.c_event_id, rec.payment_id, rec.peril_id);
      --сохраняем
      UPDATE ins.ven_ac_payment ac SET ac.note = v_purpose WHERE ac.payment_id = rec.payment_id;
    END LOOP;
  END create_purpose4payorder;

  /* Определение назначение платежа для реквеста
  * @autor Чирков В.Ю.
  */
  FUNCTION get_purpose4request
  (
    par_event_id NUMBER
   ,par_ppi_id   NUMBER
   ,par_peril_id NUMBER
  ) RETURN VARCHAR2 IS
    v_is_dogitie       INT;
    v_pol_num          VARCHAR2(1024);
    v_bank_card        cn_contact_bank_acc.account_corr%TYPE;
    v_lic_code         cn_contact_bank_acc.lic_code%TYPE;
    v_account_nr       cn_contact_bank_acc.account_nr%TYPE;
    v_did_sum          NUMBER;
    v_dss_sum          NUMBER;
    v_str              VARCHAR2(1024);
    v_vipl_note        VARCHAR2(1024);
    v_insur_contact_id contact.contact_id%TYPE;
    v_ppi_contact_id   contact.contact_id%TYPE;
    v_payment_sum      NUMBER; --сумма платежа
  
    /** Определение суммы платежа по уведомлению. Взято из <payment_request.jsp> (печ док Платежное требование)
    * autor Чирков В.Ю.
    * param par_event_id - id уведомления  
    */
    FUNCTION get_payment_sum(par_event_id NUMBER) RETURN NUMBER IS
      v_result NUMBER;
    BEGIN
      WITH main_vipl AS
       (SELECT ch.c_claim_header_id
              ,d_vipl.note
              ,vipl.amount
              ,dt.brief
          FROM ins.c_claim_header ch
              ,c_claim            cc
              ,doc_doc            dd
              ,ac_payment         vipl
              ,document           d_vipl
              ,doc_status_ref     dsr
              ,doc_templ          dt
         WHERE cc.c_claim_header_id = ch.c_claim_header_id
              --and cc.c_claim_id = ch.active_claim_id
           AND dd.parent_id = cc.c_claim_id
           AND vipl.payment_id = dd.child_id
           AND vipl.payment_id = d_vipl.document_id
           AND d_vipl.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief NOT IN ('ANNULATED', 'CANCEL')
           AND dt.doc_templ_id = d_vipl.doc_templ_id
           AND dt.brief IN ('PAYORDER', 'PAYORDER_SETOFF')
              --активная версия по подделу в статусе принято решение
           AND EXISTS
         (SELECT 1
                  FROM c_claim        cc_
                      ,document       d_cc
                      ,doc_status_ref dsr_cc
                 WHERE cc_.c_claim_id = ch.active_claim_id
                   AND d_cc.document_id = cc_.c_claim_id
                   AND dsr_cc.doc_status_ref_id = d_cc.doc_status_ref_id
                   AND dsr_cc.brief = 'DECISION')
              --по контрагенту по выплате
           AND vipl.contact_id =
               (SELECT ac.contact_id FROM ins.ac_payment ac WHERE ac.payment_id = par_ppi_id
                
                )
           AND ch.c_event_id = par_event_id),
      main_pay_sum AS
       (SELECT nvl((SELECT SUM(mvpl.amount)
                     FROM main_vipl mvpl
                    WHERE mvpl.c_claim_header_id = ch.c_claim_header_id
                      AND mvpl.brief = 'PAYORDER')
                  ,0) payorder_sum
               
              ,nvl((SELECT SUM(mvpl.amount)
                     FROM main_vipl mvpl
                    WHERE mvpl.c_claim_header_id = ch.c_claim_header_id
                      AND mvpl.brief = 'PAYORDER_SETOFF')
                  ,0) payorder_setoff_sum
               
              ,CASE
                 WHEN EXISTS ( --
                       SELECT 1
                         FROM main_vipl mvpl
                        WHERE mvpl.c_claim_header_id = ch.c_claim_header_id
                          AND mvpl.brief = 'PAYORDER') THEN
                  1
                 ELSE
                  0
               END has_payorder
              ,CASE
                 WHEN EXISTS (SELECT 1
                         FROM main_vipl mvpl
                        WHERE mvpl.c_claim_header_id = ch.c_claim_header_id
                          AND mvpl.brief = 'PAYORDER_SETOFF') THEN
                  1
                 ELSE
                  0
               END has_payorder_setoff
          FROM ins.c_claim_header ch
         WHERE ch.c_event_id = par_event_id)
      SELECT SUM(CASE
                   WHEN has_payorder = 1
                        AND has_payorder_setoff = 0 --есть только В, то сумма В
                    THEN
                    nvl(payorder_sum, 0)
                   WHEN has_payorder = 0
                        AND has_payorder_setoff = 1 --есть только З, то сумма З
                    THEN
                    nvl(payorder_setoff_sum, 0)
                 --если и В и З, то только В    
                   ELSE
                    nvl(payorder_sum, 0)
                 END)
        INTO v_result
        FROM main_pay_sum;
      RETURN v_result;
    
    END get_payment_sum;
  BEGIN
    --Определяем тип риска, совпадающий с 'Дожитие%'
    SELECT COUNT(1)
      INTO v_is_dogitie
      FROM t_peril tp
     WHERE tp.id = par_peril_id
       AND tp.description LIKE 'Дожитие%';
    --находим номер договора с которым связано уведомление
    --находим id страхователя
    --нахоидм id получателя
    SELECT decode(pp.pol_ser, NULL, pp.pol_num, pp.pol_ser || '-' || pp.pol_num) AS pol_num
          ,(SELECT vi.contact_id FROM v_pol_issuer vi WHERE vi.policy_id = pp.policy_id) insur_contact_id
          ,(SELECT ac.contact_id FROM ins.ac_payment ac WHERE ac.payment_id = par_ppi_id) ppi_contact_id
      INTO v_pol_num
          ,v_insur_contact_id
          ,v_ppi_contact_id
      FROM c_event        ce
          ,c_claim_header ch
          ,p_policy       pp
     WHERE ce.c_event_id = par_event_id
       AND ce.c_event_id = ch.c_event_id
       AND pp.policy_id = ch.p_policy_id
       AND rownum = 1;
    --находим банковскую карту получателя/контрагент из ППИ/
    BEGIN
      SELECT account_corr
        INTO v_bank_card
        FROM (SELECT cba.account_corr
                FROM cn_contact_bank_acc      cba
                    ,ac_payment               ac
                    ,ven_cn_document_bank_acc cdb
               WHERE cba.contact_id = ac.contact_id
                 AND cdb.cn_contact_bank_acc_id = cba.id
                 AND doc.get_doc_status_brief(cdb.cn_document_bank_acc_id) = 'ACTIVE'
                 AND nvl(cba.used_flag, 0) = 1
                 AND ac.payment_id = par_ppi_id
               ORDER BY cdb.reg_date) x
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_bank_card := NULL;
    END;
  
    --находим лицевой счет, расчетный счет
    BEGIN
      SELECT bacc.lic_code
            ,bacc.account_nr
        INTO v_lic_code
            ,v_account_nr
        FROM cn_contact_bank_acc bacc
            ,ins.ac_payment      ac
       WHERE bacc.id = ac.contact_bank_acc_id
         AND ac.payment_id = par_ppi_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_lic_code   := NULL;
        v_account_nr := NULL;
    END;
  
    --определяем результирующую строку в зависимости от риска дожития
    IF v_is_dogitie > 0
    THEN
      --находим сумму <к оплате> всех ущербов по ДИД по которым сформированы выплаты и <дата зачета> ППИ которых пустая
      SELECT SUM(ROUND(dam.payment_sum *
                       acc.get_cross_rate_by_brief(1, fu_dam.brief, fu_ch.brief, declare_date)
                      ,2))
        INTO v_did_sum
        FROM c_claim_header ch
            ,c_claim        cc
            ,c_damage       dam
            ,t_damage_code  dc
            ,fund           fu_dam
            ,fund           fu_ch
       WHERE ch.c_event_id = par_event_id
         AND ch.c_claim_header_id = cc.c_claim_header_id
         AND ch.active_claim_id = cc.c_claim_id
         AND cc.c_claim_id = dam.c_claim_id
         AND dc.id = dam.t_damage_code_id
         AND fu_dam.fund_id = dam.damage_fund_id
         AND fu_ch.fund_id = ch.fund_id
         AND dam.status_hist_id IN (1, 2)
         AND dc.brief IN ('DOP_INVEST_DOHOD');
    
      SELECT SUM(ROUND(dam.payment_sum *
                       acc.get_cross_rate_by_brief(1, fu_dam.brief, fu_ch.brief, declare_date)
                      ,2))
        INTO v_dss_sum
        FROM c_claim_header ch
            ,c_claim        cc
            ,c_damage       dam
            ,t_damage_code  dc
            ,fund           fu_dam
            ,fund           fu_ch
       WHERE ch.c_event_id = par_event_id
         AND ch.c_claim_header_id = cc.c_claim_header_id
         AND ch.active_claim_id = cc.c_claim_id
         AND cc.c_claim_id = dam.c_claim_id
         AND dc.id = dam.t_damage_code_id
         AND fu_dam.fund_id = dam.damage_fund_id
         AND fu_ch.fund_id = ch.fund_id
         AND dam.status_hist_id IN (1, 2)
         AND dc.brief IN ('ADD_INS_SUM');
    
      --Комментарий Чирков 299415: FW: назначение платежа
      --только у тех дел, дата зачета ППИ которых пустая
      /*AND EXISTS (SELECT 1
       FROM c_claim        cc_
           ,doc_doc        dd_
           ,ac_payment     ac_p_
           ,ven_ac_payment ppi_
           ,doc_templ      dt_
           ,doc_set_off    dso_
           ,doc_status_ref dsr_ppi_
      WHERE cc_.c_claim_header_id = ch.c_claim_header_id
        AND dd_.parent_id = cc_.c_claim_id
        AND dd_.child_id = ac_p_.payment_id
        AND dso_.parent_doc_id = ac_p_.payment_id
        AND ppi_.payment_id = dso_.child_doc_id
        AND dt_.doc_templ_id = ppi_.doc_templ_id
        AND dt_.brief = 'ППИ'
        AND dso_.set_off_date IS NULL
        AND ppi_.doc_status_ref_id = dsr_ppi_.doc_status_ref_id
        AND dsr_ppi_.brief != 'ANNULATED')*/
    
      v_str := 'Выплата страхового обеспечения по риску Дожитие договор №' || v_pol_num;
      IF v_did_sum > 0
      THEN
        --        v_str := v_str || v_damage_name || nvl(v_did_sum, 0);
        v_str := v_str || ' ДИД ' || nvl(v_did_sum, 0);
      END IF;
    
      IF v_dss_sum > 0
      THEN
        -- 374507 СРОЧНАЯ заявка изменение коды убытка с ДИД на ДСС
        -- В назначении платежа по подделам, код убытка по которым «Дополнительная страховая сумма» 
        -- фраза в распоряжении на выплату возмещения по ПС должна изменится вместо «ДИД» на  «ДСС».
        v_str := v_str || ' ДСС ' || nvl(v_dss_sum, 0);
      END IF;
    ELSE
      v_str := 'Выплата страхового обеспечения по договору №' || v_pol_num;
    END IF;
  
    IF v_bank_card IS NOT NULL
    THEN
      v_str := v_str || ' н.к ' || v_bank_card;
    END IF;
  
    /*if nvl(v_did_sum,0) > 0 or v_insur_contact_id != v_ppi_contact_id
      then v_str := v_str || ' НДФЛ удержан ст.213 НК РФ';
    else
      v_str := v_str || ' НДФЛ не облагается';
    end if;*/
  
    IF v_did_sum > 0
       OR v_is_dogitie > 0
    THEN
      v_str := v_str || ' НДФЛ удержан ст.213 НК РФ';
    END IF;
  
    IF v_bank_card IS NULL
       AND v_lic_code != v_account_nr
       AND v_lic_code IS NOT NULL
    THEN
      v_str := v_str || ', л.с' || v_lic_code;
    END IF;
  
    v_payment_sum := get_payment_sum(par_event_id);
    IF v_payment_sum != 0
    THEN
      v_str := v_str || ' Сумма ' || to_char(v_payment_sum);
    END IF;
  
    v_str := v_str /*|| ' ' || v_vipl_note*/
             || ' НДС не облагается.';
  
    RETURN v_str;
  END get_purpose4request;

  /*
    Байтин А.
    Перенесено из формы DISP_LIFE (DB_C_EVENT.KEY-CREREC)
  */
  PROCEDURE add_non_insurance_claims(par_c_event_id NUMBER) IS
    v_as_asset_id  NUMBER;
    v_prod_line_id NUMBER;
    v_cover_id     NUMBER;
    v_exists       NUMBER(1);
  BEGIN
  
    SELECT ce.as_asset_id INTO v_as_asset_id FROM c_event ce WHERE ce.c_event_id = par_c_event_id;
  
    SELECT pl.id INTO v_prod_line_id FROM t_product_line pl WHERE pl.brief = 'NonInsuranceClaims';
    -- Проверка существования не страховых убытков на версии
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_cover            pc
                  ,t_prod_line_option plo
             WHERE pc.as_asset_id = v_as_asset_id
               AND pc.t_prod_line_option_id = plo.id
               AND plo.product_line_id = v_prod_line_id);
    IF v_exists = 0
    THEN
      -- Байтин А.
      -- Заявка 263911
      v_cover_id := pkg_cover.cre_new_cover(p_as_asset_id       => v_as_asset_id
                                           ,p_t_product_line_id => v_prod_line_id
                                           ,p_update_asset      => FALSE);
    END IF;
  END add_non_insurance_claims;

  ---------------------------------------------------------------------------------------------------
  -- Author  : Гаргонов Д.А.
  -- Created : 17.01.2014
  -- Purpose : 315504 не верно отображается статус на диспетчерском пульте дело 14091
  -- Comment : Проверяет является ли последняя версия по делу активной.
  -- Param   : par_claim_id ИД версии дела

  PROCEDURE check_active_ver_on_claim_head(par_claim_id IN NUMBER) IS
    var_claim_head_updated NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO var_claim_head_updated
      FROM dual
     WHERE EXISTS
     (SELECT NULL
              FROM c_claim_header h
                  ,ven_c_claim    c_last
                  ,ven_c_claim    c
             WHERE h.c_claim_header_id = c_last.c_claim_header_id
               AND c.num = c_last.num
               AND c_last.seqno = (SELECT MAX(cl.seqno)
                                     FROM c_claim cl
                                    WHERE cl.c_claim_header_id = h.c_claim_header_id)
               AND c_last.c_claim_id = h.active_claim_id
               AND c.c_claim_id = par_claim_id);
  
    IF var_claim_head_updated != 1
    THEN
      raise_application_error(-20999
                             ,'Не обновился статус активной версии, пожалуйста сообщите разработчикам!');
    END IF;
  END check_active_ver_on_claim_head;

  FUNCTION get_policy_by_claim_id(par_claim_id ins.c_claim.c_claim_id%TYPE)
    RETURN ins.p_policy.policy_id%TYPE IS
    v_policy_id ins.p_policy.policy_id%TYPE;
  BEGIN
    SELECT pp.policy_id
      INTO v_policy_id
      FROM c_claim        cc
          ,c_claim_header ch
          ,p_policy       pp
     WHERE ch.c_claim_header_id = cc.c_claim_header_id
       AND pp.policy_id = ch.p_policy_id
       AND cc.c_claim_id = par_claim_id;
    RETURN v_policy_id;
  EXCEPTION
    WHEN too_many_rows THEN
      ex.raise('Дело соответствует нескольким версиям договора страхования!');
    WHEN no_data_found THEN
      RETURN NULL;
  END get_policy_by_claim_id;

END;
/
