CREATE OR REPLACE PACKAGE "PKG_CLAIM_TEMP" IS

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

END PKG_CLAIM_TEMP;
/
CREATE OR REPLACE PACKAGE BODY "PKG_CLAIM_TEMP" IS

  FUNCTION is_addendum(p_c_claim_id NUMBER) RETURN NUMBER IS
    is_a NUMBER;
  BEGIN
    SELECT 1
      INTO is_a
      FROM dual
     WHERE 1 = 1
       AND p_c_claim_id IN (SELECT c_claim_id
                              FROM (SELECT c_claim_id
                                          ,ROWNUM rn
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
    WHEN NO_DATA_FOUND THEN
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
      SELECT Acc.get_cross_rate_by_brief(1, fc.brief, fd.brief, ch.declare_date)
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
      SELECT Acc.get_cross_rate_by_brief(1, fd.brief, fc.brief, ch.declare_date)
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
    RETURN ROUND(NVL(VALUE, 0) * v_fund_rate, 2);
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
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0))
      INTO p_declare_sum
      FROM ven_c_damage       d
          ,ven_status_hist    sh
          ,ven_c_damage_type  dt
          ,c_damage_cost_type dct
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.BRIEF IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dct.c_damage_cost_type_id(+) = d.c_damage_cost_type_id
       AND (dt.BRIEF = 'СТРАХОВОЙ' OR dct.brief = 'ВОЗМЕЩАЕМЫЕ');
  
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.deduct_sum), 0))
      INTO p_deduct_sum
      FROM ven_c_damage    d
          ,ven_status_hist sh
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO p_damage_payment_sum
      FROM ven_c_damage      d
          ,ven_status_hist   sh
          ,ven_c_damage_type dt
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.BRIEF IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dt.BRIEF = 'СТРАХОВОЙ';
  
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO p_add_expenses_noown_sum
      FROM ven_c_damage           d
          ,ven_status_hist        sh
          ,ven_c_damage_type      dt
          ,ven_c_damage_cost_type dct
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.BRIEF IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dct.c_damage_cost_type_id = d.c_damage_cost_type_id
       AND dt.BRIEF IN ('ДОПРАСХОД')
       AND dct.brief = 'ВОЗМЕЩАЕМЫЕ';
  
    /* select sum(nvl(f_d2(d.c_damage_id, d.payment_sum), 0))
     into p_payment_sum
     from ven_c_damage d, ven_status_hist sh
    where d.c_claim_id = v_claim_id
      and d.status_hist_id = sh.status_hist_id
      and sh.BRIEF in ('NEW', 'CURRENT'); */
  
    p_payment_sum := NVL(p_damage_payment_sum, 0) + NVL(p_add_expenses_noown_sum, 0);
  
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.decline_sum), 0))
      INTO p_decline_sum
      FROM ven_c_damage    d
          ,ven_status_hist sh
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO p_add_expences_own_sum
      FROM ven_c_damage           d
          ,ven_status_hist        sh
          ,ven_c_damage_type      dt
          ,ven_c_damage_cost_type dct
     WHERE d.c_claim_id = v_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND sh.BRIEF IN ('NEW', 'CURRENT')
       AND d.c_damage_type_id = dt.c_damage_type_id
       AND dct.c_damage_cost_type_id = d.c_damage_cost_type_id
       AND dt.BRIEF IN ('ДОПРАСХОД')
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
       AND dt.ID = pc.t_deductible_type_id
       AND dvt.ID = pc.t_deduct_val_type_id;
  
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
  
    RETURN GREATEST(v_ret, 0);
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
       AND dt.ID = pc.t_deductible_type_id
       AND dvt.ID = pc.t_deduct_val_type_id;
  
    IF v_dt = 'Безусловная'
       OR (v_dt = 'Условная' AND par_sum <= par_deduc)
    THEN
      v_ret := par_sum - par_deduc;
    END IF;
  
    RETURN GREATEST(v_ret, 0);
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
    SELECT NVL(p_cover_id, ch.p_cover_id)
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
                      ,dc.t_prod_coef_type_id ID
                  FROM c_damage      d
                      ,t_damage_code dc
                 WHERE d.c_claim_id = p_claim_id
                   AND dc.ID = d.t_damage_code_id)
    LOOP
      IF NVL(rec.declare_sum, 0) = 0
      THEN
        v_sum := Pkg_Tariff_Calc.calc_fun(rec.ID, rec.ent_id, rec.c_damage_id);
        IF NVL(v_sum, 0) <> 0
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
     WHERE pc.t_prod_line_option_id = tplo.ID
       AND pc.P_COVER_ID = v_p_cover_id;
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
                   AND dc.ID = d.T_DAMAGE_CODE_ID
                   AND d.c_claim_id = p_claim_id
                   AND d.status_hist_id = sh.status_hist_id
                   AND d.c_damage_status_id = ds.c_damage_status_id
                   AND sh.BRIEF IN ('NEW', 'CURRENT')
                   AND ds.BRIEF NOT IN ('НЕПОКРЫТ')
                   AND per.ID = dc.peril
                 ORDER BY d.C_DAMAGE_ID ASC)
         WHERE ROWNUM < 2;
        UPDATE c_damage d
           SET d.c_damage_status_id =
               (SELECT ds.C_DAMAGE_STATUS_ID
                  FROM ven_c_damage_status ds
                 WHERE ds.BRIEF = 'НЕПОКРЫТ')
         WHERE d.C_CLAIM_ID = p_claim_id
           AND d.C_DAMAGE_ID IN (SELECT d.C_DAMAGE_ID
                                   FROM ven_c_damage        d
                                       ,ven_status_hist     sh
                                       ,ven_c_damage_status ds
                                       ,ven_t_damage_code   dc
                                  WHERE d.p_cover_id = v_p_cover_id
                                    AND dc.peril <> v_osago_peril
                                    AND dc.ID = d.T_DAMAGE_CODE_ID
                                    AND d.c_claim_id = p_claim_id
                                    AND d.status_hist_id = sh.status_hist_id
                                    AND d.c_damage_status_id = ds.c_damage_status_id
                                    AND sh.BRIEF IN ('NEW', 'CURRENT'));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;
  
    -- Для непокрытых и отмененных рисков задаем сумму отказа = заявленной сумме и сумму к выплате = 0
    UPDATE c_damage d
       SET d.DEDUCT_SUM  = 0
          ,d.DECLINE_SUM = d.DECLARE_SUM
          ,d.PAYMENT_SUM = 0
     WHERE d.C_CLAIM_ID = p_claim_id
       AND d.C_DAMAGE_ID IN (SELECT d.C_DAMAGE_ID
                               FROM ven_c_damage        d
                                   ,ven_status_hist     sh
                                   ,ven_c_damage_status ds
                              WHERE d.p_cover_id = v_p_cover_id
                                AND d.c_claim_id = p_claim_id
                                AND d.status_hist_id = sh.status_hist_id
                                AND d.c_damage_status_id = ds.c_damage_status_id
                                AND sh.BRIEF IN ('NEW', 'CURRENT')
                                AND ds.brief NOT IN ('ОТКРЫТ', 'ЗАКРЫТ'));
  
    -- Получаем сумму заявленных убытков в валюте претензии, чтобы вычислить франшизу
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0))
      INTO v_declare_sum_all
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
     WHERE d.p_cover_id = v_p_cover_id
       AND d.c_claim_id = p_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    -- Получаем сумму франшизы,тип франшизы, страховую сумму, стоимость на покрытии (в валюте претензии)
    SELECT NVL(pc.deductible_value, 0)
          ,dt.description
          ,dvt.description
          ,NVL(pc.ins_amount, 0)
          ,NVL(pc.is_proportional, 0)
          ,NVL(pc.is_aggregate, 0)
          ,NVL(pc.ins_price, 0)
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
       AND dt.ID = pc.t_deductible_type_id
       AND dvt.ID = pc.t_deduct_val_type_id;
  
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
        FOR rec IN (SELECT MAX(NVL(pc.deductible_value, 0) *
                               NVL(Pkg_Tariff_Calc.calc_fun(dc.deduct_func_id, d.ent_id, d.c_damage_id)
                                  ,1)) PERCENT
                      FROM p_cover       pc
                          ,c_damage      d
                          ,t_damage_code dc
                          ,c_damage_type dt
                     WHERE 1 = 1
                       AND d.c_claim_id = p_claim_id
                       AND dc.ID = d.t_damage_code_id
                       AND dt.c_damage_type_id = d.c_damage_type_id
                       AND dt.brief = 'СТРАХОВОЙ'
                       AND pc.p_cover_id = d.p_cover_id)
        LOOP
          v_claim_deduct_sum := ROUND(v_ins_sum * rec.PERCENT / 100, 2);
        END LOOP;
      END IF;
    END IF;
    DBMS_OUTPUT.PUT_LINE(' v_claim_deduct_sum ' || v_claim_deduct_sum);
    v_claim_deduct_sum := NVL(v_claim_deduct_sum, 0);
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
                                  AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                  AND sh.BRIEF IN ('NEW', 'CURRENT'));
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
                  AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                  AND sh.BRIEF IN ('NEW', 'CURRENT'))
    LOOP
    
      DECLARE
        a1 NUMBER := f_d(dd.c_damage_id, v_claim_deduct_sum);
        a2 NUMBER := f_d(dd.c_damage_id, v_declare_sum_all);
      BEGIN
        UPDATE c_damage
           SET deduct_sum = ROUND(a1 * NVL(dd.declare_sum, 0) / a2, 2)
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
                   AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                   AND sh.BRIEF IN ('NEW', 'CURRENT')
                 ORDER BY c_damage_id DESC)
         WHERE ROWNUM < 2;
      
        SELECT SUM(NVL(f_d2(d.c_damage_id, d.deduct_sum), 0))
          INTO v_s
          FROM ven_c_damage        d
              ,ven_status_hist     sh
              ,ven_c_damage_status ds
         WHERE d.p_cover_id = v_p_cover_id
           AND d.c_claim_id = p_claim_id
           AND d.c_damage_id <> v_last_damage_id
           AND d.status_hist_id = sh.status_hist_id
           AND d.c_damage_status_id = ds.c_damage_status_id
           AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
           AND sh.BRIEF IN ('NEW', 'CURRENT');
      
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
                  AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                  AND sh.BRIEF IN ('NEW', 'CURRENT'))
    LOOP
    
      DECLARE
        a1 NUMBER := f_d(dd.c_damage_id, NVL(damage_perc(dd.c_damage_id), 0));
        a2 NUMBER;
      BEGIN
        UPDATE c_damage
           SET decline_sum = GREATEST(dd.deduct_sum, dd.declare_sum - a1)
         WHERE c_damage_id = dd.c_damage_id;
      END;
    END LOOP;
  
    -- Вычисляем сумму к выплате без учета лимитов, но с учетом франшизы, суммы отказа и пропорциональности
    IF v_is_proportional = 1
    THEN
      SELECT ROUND(SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0) -
                       NVL(f_d2(d.c_damage_id, d.decline_sum), 0)) * v_ins_price / v_ins_sum
                  ,2)
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.BRIEF IN ('NEW', 'CURRENT');
    ELSE
      SELECT SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0) -
                 NVL(f_d2(d.c_damage_id, d.decline_sum), 0))
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.BRIEF IN ('NEW', 'CURRENT');
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
      v_event_limit_sum := GREATEST(240000, NVL(v_event_limit_sum, 0));
    ELSIF v_osago_peril_brief = 'ОСАГО_ИМУЩЕСТВО'
    THEN
      v_event_limit_sum := GREATEST(160000, NVL(v_event_limit_sum, 0));
    END IF;
  
    -- Получаем сумму выплат по всем ущербам данного покрытия во всех предыдущих претензиях
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
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
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    IF v_osago_peril IS NOT NULL
    THEN
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем и покрываемым риском (для ОСАГО)
      SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
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
       AND d.c_claim_id = get_curr_claim(ch.C_CLAIM_HEADER_ID)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.C_EVENT_ID = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.C_CLAIM_HEADER_ID = ch.C_CLAIM_HEADER_ID
                          AND c.C_CLAIM_ID = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT')
      -- Условие на риск
       AND damc.peril = v_osago_peril
       AND damc.ID = d.C_DAMAGE_ID;
    ELSE
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем
      SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
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
       AND d.c_claim_id = get_curr_claim(ch.C_CLAIM_HEADER_ID)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.C_EVENT_ID = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.C_CLAIM_HEADER_ID = ch.C_CLAIM_HEADER_ID
                          AND c.C_CLAIM_ID = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT');
    END IF;
  
    -- Если задан лимит по покрытию, то максимально возможная сумма к выплате = страх.сумма-выплаченная сумма
    IF v_is_aggregate = 1
    THEN
      v_limit := GREATEST(0, v_ins_sum - NVL(v_payed_cover_sum, 0));
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
                        AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                        AND sh.BRIEF IN ('NEW', 'CURRENT'))
    LOOP
      v_damage.payment_sum := NVL(v_damage.declare_sum, 0) - NVL(v_damage.decline_sum, 0);
      IF NVL(v_payment_sum_all, 0) < NVL(v_damage.payment_sum, 0)
      THEN
        v_damage.payment_sum := v_payment_sum_all;
      END IF;
      v_damage.decline_sum := GREATEST(0, NVL(v_damage.declare_sum, 0) - NVL(v_damage.payment_sum, 0));
      v_payment_sum_all    := GREATEST(v_payment_sum_all -
                                       NVL(f_d2(v_damage.c_damage_id, v_damage.payment_sum), 0)
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
    v_sh_brief   status_hist.brief%TYPE;
    v_last_brief VARCHAR2(30);
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
      SELECT sq_c_claim.NEXTVAL INTO v_id FROM dual;
      -- старая запись
      SELECT v.* INTO v_claim FROM ven_c_claim v WHERE v.c_claim_id = p_claim_id;
    
      v_header_id := v_claim.c_claim_header_id;
    
      DBMS_OUTPUT.PUT_LINE(' copy_claim_version ... p_claim_id = ' || p_claim_id || ' v_header_id = ' ||
                           v_header_id);
    
      SELECT active_claim_id
        INTO v_active_id
        FROM c_claim_header
       WHERE c_claim_header_id = v_header_id;
    
      DBMS_OUTPUT.PUT_LINE(' active_claim_id = ' || v_active_id);
    
      -- новый ид и дата регистрации
      v_claim.c_claim_id := v_id;
      v_claim.reg_date   := SYSDATE;
      v_last_brief       := doc.get_last_doc_status_brief(p_claim_id);
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
    
      IF pkg_app_param.get_app_param_n('CLIENTID') = 10
      THEN
        IF v_last_brief = 'CLOSE'
        THEN
          Doc.set_doc_status(v_claim.c_claim_id, 'REVISION');
        ELSE
          Doc.set_doc_status(v_claim.c_claim_id, v_last_brief);
        END IF;
      ELSE
        Doc.set_doc_status(v_claim.c_claim_id, 'PROJECT');
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
          SELECT sq_c_damage.NEXTVAL
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
    
      DBMS_OUTPUT.PUT_LINE('after copy ... active_id = ' || v_active_id);
    
      RETURN v_id;
    END IF;
  END;

  FUNCTION get_lim_amount
  (
    p_damage_code IN NUMBER
   ,par_cover     IN NUMBER
  ) RETURN NUMBER IS
    v_lim_am NUMBER;
  BEGIN
  
    SELECT NVL(plop.limit_amount, pc.ins_amount)
      INTO v_lim_am
      FROM p_cover               pc
          ,t_prod_line_option    plo
          ,t_prod_line_opt_peril plop
          ,t_damage_code         dc
     WHERE pc.p_cover_id = par_cover
       AND plo.ID = pc.t_prod_line_option_id
       AND pc.t_prod_line_option_id = plop.product_line_option_id
       AND dc.peril = plop.peril_id
       AND dc.ID = p_damage_code;
  
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
      RAISE NO_DATA_FOUND;
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
          par_department_id := Pkg_App_Param.get_app_param_u('ПОДРУБ');
      END;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      par_department_id := Pkg_App_Param.get_app_param_u('ПОДРУБ');
      SELECT c.contact_id INTO par_contact_id FROM v_pol_curator c WHERE c.policy_id = par_policy_id;
  END;

  FUNCTION get_damage_list(p_c_claim_id IN NUMBER) RETURN VARCHAR2 AS
    v_result VARCHAR2(1000);
  BEGIN
    FOR v_r IN (SELECT tdc.description
                  FROM c_damage cd
                 INNER JOIN t_damage_code tdc
                    ON tdc.ID = cd.t_damage_code_id
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
                    ON tdc.ID = cd.t_damage_code_id
                  JOIN t_peril tp
                    ON tp.ID = tdc.peril
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
     WHERE ROWNUM = 1;
  
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
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
                           Acc.Get_Cross_Rate_By_Id(1
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
      DBMS_OUTPUT.PUT_LINE('go ' || c_claim.c_damage_id);
      v_res_id := Acc_New.Run_Oper_By_Template(v_oper_templ_charge_id
                                              ,p_claim_id
                                              ,c_claim.ent_id
                                              ,c_claim.c_damage_id
                                              ,Doc.get_last_doc_status_ref_id(p_claim_id)
                                              ,1
                                              ,c_claim.payment_sum
                                              ,'INS');
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERROR claim_charge ' || p_claim_id);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      RAISE;
  END;

  -- Возвращает номер предыдущего дела
  FUNCTION get_prev_claim_num(p_claim_id NUMBER) RETURN VARCHAR2 IS
    num VARCHAR2(100);
  
  BEGIN
  
    SELECT A.num
      INTO num
      FROM (SELECT ch2.num
                  ,MAX(ch2.reg_date) OVER(PARTITION BY ch.as_asset_id) max_date
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
  
    SELECT sq_claim_num.NEXTVAL INTO v_claim_nr FROM dual;
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
      SELECT NVL(COUNT(ce.c_event_id), 0)
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
          ON plo.ID = pc.t_prod_line_option_id
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
    SELECT INSTR(UPPER(pr.brief), 'АВТОКАСКО')
      INTO prod_avto
      FROM p_pol_header ph
      JOIN t_product pr
        ON pr.product_id = ph.product_id
     WHERE ph.policy_header_id = p_pol_header_id;
  
    IF prod_avto > 0
    THEN
      SELECT NVL(SUM(cc.payment_sum), 0)
            ,NVL(SUM(pkg_payment.get_charge_cover_amount_pfa(pc.start_date
                                                            ,pc.end_date
                                                            ,pc.p_cover_id))
                ,SUM(pc.premium - NVL(pc.old_premium, 0)))
        INTO paym
            ,nach
        FROM p_policy pp
        JOIN as_asset ass
          ON ass.p_policy_id = pp.policy_id
        JOIN p_cover pc
          ON pc.as_asset_id = ass.as_asset_id
        JOIN t_prod_line_option plo
          ON plo.ID = pc.t_prod_line_option_id
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
      SELECT NVL(SUM(cc.payment_sum), 0)
            ,NVL(SUM(pkg_payment.get_charge_cover_amount_pfa(pc.start_date
                                                            ,pc.end_date
                                                            ,pc.p_cover_id))
                ,SUM(pc.premium - NVL(pc.old_premium, 0)))
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
                 FROM c_damage      d
                     ,t_damage_code dc
                     ,p_cover       c
                WHERE d.c_damage_id = p_damage_id
                  AND dc.ID = d.t_damage_code_id
                  AND c.p_cover_id = d.p_cover_id)
    LOOP
      RETURN ROUND(rc.limit_val * rc.ins_amount / 100, 2);
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
    v_declare_sum_all   NUMBER; -- Сумма всех заявленных убытков
    v_payment_sum_all   NUMBER; -- Сумма к выплате
    v_p_cover_id        NUMBER; -- Id покрытия
    v_sum               NUMBER; -- Значение франшизы на покрытии
    v_dt                VARCHAR2(100); -- Тип франшизы
    v_dvt               VARCHAR2(100); -- Тип значения франшизы
    v_claim_deduct_sum  NUMBER; -- Сумма франшизы claim-а
    v_refuse_sum        NUMBER; -- Сумма отказа claim-а
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
    v_plo               VARCHAR2(1000);
  BEGIN
    -- Получаем покрытие
    SELECT NVL(p_cover_id, ch.p_cover_id)
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
                      ,dc.t_prod_coef_type_id ID
                  FROM c_damage      d
                      ,t_damage_code dc
                      ,c_damage_type dt
                 WHERE d.c_claim_id = p_claim_id
                   AND dc.ID = d.t_damage_code_id
                   AND dt.c_damage_type_id = d.c_damage_type_id
                   AND dt.brief = 'СТРАХОВОЙ')
    LOOP
      IF NVL(rec.declare_sum, 0) = 0
      THEN
        v_sum := Pkg_Tariff_Calc.calc_fun(rec.ID, rec.ent_id, rec.c_damage_id);
        IF NVL(v_sum, 0) <> 0
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
     WHERE pc.t_prod_line_option_id = tplo.ID
       AND pc.P_COVER_ID = v_p_cover_id;
  
    -- Для непокрытых и отмененных рисков задаем сумму отказа = заявленной сумме и сумму к выплате = 0
    UPDATE c_damage d
       SET d.DEDUCT_SUM  = 0
          ,d.DECLINE_SUM = d.DECLARE_SUM
          ,d.PAYMENT_SUM = 0
     WHERE d.C_CLAIM_ID = p_claim_id
       AND d.C_DAMAGE_ID IN (SELECT d.C_DAMAGE_ID
                               FROM ven_c_damage        d
                                   ,ven_status_hist     sh
                                   ,ven_c_damage_status ds
                              WHERE d.p_cover_id = v_p_cover_id
                                AND d.c_claim_id = p_claim_id
                                AND d.status_hist_id = sh.status_hist_id
                                AND d.c_damage_status_id = ds.c_damage_status_id
                                AND sh.BRIEF IN ('NEW', 'CURRENT')
                                AND ds.brief NOT IN ('ОТКРЫТ', 'ЗАКРЫТ'));
  
    -- Получаем сумму заявленных убытков в валюте претензии, чтобы вычислить франшизу
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0))
      INTO v_declare_sum_all
      FROM ven_c_damage        d
          ,ven_status_hist     sh
          ,ven_c_damage_status ds
          ,c_damage_type       dt
     WHERE d.p_cover_id = v_p_cover_id
       AND d.c_claim_id = p_claim_id
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT')
       AND dt.c_damage_type_id = d.c_damage_type_id
       AND dt.brief = 'СТРАХОВОЙ';
  
    -- Получаем сумму франшизы,тип франшизы, страховую сумму, стоимость на покрытии (в валюте претензии)
    SELECT NVL(pc.deductible_value, 0)
          ,dt.description
          ,dvt.description
          ,NVL(pc.ins_amount, 0)
          ,NVL(pc.is_proportional, 0)
          ,NVL(pc.is_aggregate, 0)
          ,NVL(pc.ins_price, 0)
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
       AND dt.ID = pc.t_deductible_type_id
       AND dvt.ID = pc.t_deduct_val_type_id;
  
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
      
        FOR rec IN (SELECT MAX(NVL(pc.deductible_value, 0) *
                               NVL(Pkg_Tariff_Calc.calc_fun(dc.deduct_func_id, d.ent_id, d.c_damage_id)
                                  ,1)) PERCENT
                      FROM p_cover       pc
                          ,c_damage      d
                          ,t_damage_code dc
                          ,c_damage_type dt
                     WHERE 1 = 1
                       AND d.c_claim_id = p_claim_id
                       AND dc.ID = d.t_damage_code_id
                       AND dt.c_damage_type_id = d.c_damage_type_id
                       AND dt.brief = 'СТРАХОВОЙ'
                       AND pc.p_cover_id = d.p_cover_id)
        LOOP
          v_claim_deduct_sum := ROUND(v_ins_sum * rec.PERCENT / 100, 2);
        END LOOP;
      END IF;
    END IF;
    v_claim_deduct_sum := NVL(v_claim_deduct_sum, 0);
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
                                  AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                  AND sh.BRIEF IN ('NEW', 'CURRENT')
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
                                              AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                              AND sh.BRIEF IN ('NEW', 'CURRENT')
                                              AND dt.c_damage_type_id = d.c_damage_type_id
                                              AND dt.brief = 'СТРАХОВОЙ'))
      LOOP
        v_num := ROUND(f_d(rrc.c_damage_id, v_claim_deduct_sum) * NVL(rrc.declare_sum, 0) /
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
                   AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                   AND sh.BRIEF IN ('NEW', 'CURRENT')
                   AND dt.c_damage_type_id = d.c_damage_type_id
                   AND dt.brief = 'СТРАХОВОЙ'
                 ORDER BY c_damage_id DESC)
         WHERE ROWNUM < 2;
      
        SELECT SUM(NVL(f_d2(d.c_damage_id, d.deduct_sum), 0))
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
           AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
           AND sh.BRIEF IN ('NEW', 'CURRENT')
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
                                              AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                                              AND sh.BRIEF IN ('NEW', 'CURRENT')))
      LOOP
      
        SELECT DECODE(SIGN(rrc.declare_sum -
                           f_d(rrc.c_damage_id, NVL(damage_perc(rrc.c_damage_id), 0)))
                     ,1
                     ,ABS(rrc.declare_sum - f_d(rrc.c_damage_id, NVL(damage_perc(rrc.c_damage_id), 0)))
                     ,0
                     ,ABS(rrc.declare_sum - f_d(rrc.c_damage_id, NVL(damage_perc(rrc.c_damage_id), 0)))
                     ,0)
          INTO v_num
          FROM dual;
      
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
      SELECT ROUND(SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0) -
                       NVL(f_d2(d.c_damage_id, d.decline_sum), 0)) * v_ins_price / v_ins_sum
                  ,2)
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.BRIEF IN ('NEW', 'CURRENT');
    ELSE
      SELECT SUM(NVL(f_d2(d.c_damage_id, d.declare_sum), 0) -
                 NVL(f_d2(d.c_damage_id, d.decline_sum), 0))
        INTO v_payment_sum_all
        FROM ven_c_damage        d
            ,ven_status_hist     sh
            ,ven_c_damage_status ds
       WHERE d.p_cover_id = v_p_cover_id
         AND d.c_claim_id = p_claim_id
         AND d.status_hist_id = sh.status_hist_id
         AND d.c_damage_status_id = ds.c_damage_status_id
         AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
         AND sh.BRIEF IN ('NEW', 'CURRENT');
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
      v_event_limit_sum := GREATEST(240000, NVL(v_event_limit_sum, 0));
    ELSIF v_osago_peril_brief = 'ОСАГО_ИМУЩЕСТВО'
    THEN
      v_event_limit_sum := GREATEST(160000, NVL(v_event_limit_sum, 0));
    END IF;
  
    -- Получаем сумму выплат по всем ущербам данного покрытия во всех предыдущих претензиях
    SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
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
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    IF v_osago_peril IS NOT NULL
    THEN
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем и покрываемым риском (для ОСАГО)
      SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
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
       AND d.c_claim_id = get_curr_claim(ch.C_CLAIM_HEADER_ID)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.C_EVENT_ID = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.C_CLAIM_HEADER_ID = ch.C_CLAIM_HEADER_ID
                          AND c.C_CLAIM_ID = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT')
      -- Условие на риск
       AND damc.peril = v_osago_peril
       AND damc.ID = d.C_DAMAGE_ID;
    ELSE
      -- Получаем сумму выплат по всем предыдущим претензиям связанным с тем же страховым случаем
      SELECT SUM(NVL(f_d2(d.c_damage_id, d.payment_sum), 0))
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
       AND d.c_claim_id = get_curr_claim(ch.C_CLAIM_HEADER_ID)
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND c.c_claim_id = d.c_claim_id
      -- Условие на событие
       AND ch.c_event_id = e.c_event_id
       AND e.as_asset_id = p.as_asset_id
       AND ch.as_asset_id = p.as_asset_id
       AND e.C_EVENT_ID = (SELECT ch.c_event_id
                         FROM c_claim        c
                             ,c_claim_header ch
                        WHERE c.C_CLAIM_HEADER_ID = ch.C_CLAIM_HEADER_ID
                          AND c.C_CLAIM_ID = p_claim_id)
      -- Условия на статусы ущербов
       AND d.status_hist_id = sh.status_hist_id
       AND d.c_damage_status_id = ds.c_damage_status_id
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT');
    END IF;
  
    -- Если задан лимит по покрытию, то максимально возможная сумма к выплате = страх.сумма-выплаченная сумма
    IF v_is_aggregate = 1
    THEN
      v_limit := GREATEST(0, v_ins_sum - NVL(v_payed_cover_sum, 0));
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
                        AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
                        AND sh.BRIEF IN ('NEW', 'CURRENT'))
    LOOP
      DBMS_OUTPUT.PUT_LINE('1. v_damage.payment_sum ' || v_damage.payment_sum);
      DBMS_OUTPUT.PUT_LINE('2. v_damage.decline_sum ' || v_damage.decline_sum);
      DBMS_OUTPUT.PUT_LINE('3. v_damage.deduct_sum  ' || v_damage.deduct_sum);
      DBMS_OUTPUT.PUT_LINE('4. v_damage.declare_sum  ' || v_damage.declare_sum);
      v_damage.payment_sum := NVL(v_damage.declare_sum, 0) - NVL(v_damage.decline_sum, 0) -
                              NVL(v_damage.deduct_sum, 0);
      DBMS_OUTPUT.PUT_LINE('5. v_damage.payment_sum ' || v_damage.payment_sum);
      IF NVL(v_payment_sum_all, 0) < NVL(v_damage.payment_sum, 0)
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
      v_damage.decline_sum := NVL(v_damage.declare_sum - v_damage.payment_sum, 0);
      DBMS_OUTPUT.PUT_LINE('6. v_damage.decline_sum ' || v_damage.decline_sum);
      v_payment_sum_all := GREATEST(v_payment_sum_all -
                                    NVL(f_d2(v_damage.c_damage_id, v_damage.payment_sum), 0)
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
    v_Oper_Templ_ID     NUMBER;
    v_Cover_Ent_ID      NUMBER;
    v_Cover_Obj_ID      NUMBER;
    v_Amount            NUMBER;
    ID                  NUMBER;
  
    CURSOR c_Oper_Claim
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,dam.ent_id
            ,dam.c_damage_id
            ,Pkg_Claim_Payment.get_claim_adds_sum(c.c_claim_header_id, c.c_claim_id) Amount
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
  
    DBMS_OUTPUT.PUT_LINE(' Проверка на ПРОЕКТ ... ' || par_claim_id);
    -- Если статус документа = Проект, то версия должна стать активной, только если она первая
    IF Doc.get_doc_status_brief(par_claim_id) = 'PROJECT'
    THEN
      RETURN;
    END IF;
    -- Прописывается в p_pol_header ссылка на активную версию полиса
    DBMS_OUTPUT.PUT_LINE(' Замена активной версии ... ' || par_claim_id);
    UPDATE c_claim_header ch
       SET ch.active_claim_id = par_claim_id
     WHERE ch.c_claim_header_id IN
           (SELECT cc.c_claim_header_id FROM c_claim cc WHERE cc.c_claim_id = par_claim_id);
  
    -- формирование проводок по начислению доп.расходов
    v_doc_status_id := Doc.get_last_doc_status_id(par_claim_id);
    IF v_doc_status_id IS NOT NULL
    THEN
    
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      OPEN c_Oper_Claim(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
      LOOP
        FETCH c_Oper_Claim
          INTO v_Oper_Templ_ID
              ,v_Cover_Ent_ID
              ,v_Cover_Obj_ID
              ,v_Amount;
        EXIT WHEN c_Oper_Claim%NOTFOUND;
        IF v_Amount <> 0
        THEN
          ID := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID
                                            ,par_claim_id
                                            ,v_Cover_Ent_ID
                                            ,v_Cover_Obj_ID
                                            ,v_doc_status.doc_status_ref_id
                                            ,1
                                            ,v_Amount);
        END IF;
      END LOOP;
      CLOSE c_Oper_Claim;
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
      WHEN NO_DATA_FOUND THEN
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
  BEGIN
    SELECT COUNT(*) INTO v FROM c_claim_header ch WHERE ch.p_policy_id = p_doc_id;
    IF v > 0
    THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Существуют дела по версии договора');
    END IF;
  END;

  PROCEDURE create_payments(p_doc_id IN NUMBER) IS
    v_claim_sum           NUMBER := pkg_claim_payment.get_claim_payment_sum(p_doc_id) -
                                    pkg_claim_payment.get_claim_plan_sum(p_doc_id);
    v_claim_fund_id       NUMBER;
    v_pay_term_id         NUMBER;
    v_policy_id           NUMBER;
    v_status_date         DATE;
    v_sum                 NUMBER := 0;
    v_rt_id               NUMBER;
    v_templ_id            NUMBER;
    v_declarant_id        NUMBER;
    v_Company_Bank_Acc_ID NUMBER;
    v_Company_Brief       VARCHAR2(200);
    v_pay_fund_id         NUMBER;
    v_pol_header_id       NUMBER;
    v_ph_fund_id          NUMBER;
  BEGIN
  
    -- если есть сумма к выплате
    IF v_claim_sum > 0
    THEN
      -- валюта,срок,полис
      SELECT ch.fund_id
            ,ch.payment_term_id
            ,ch.p_policy_id
            ,cc.claim_status_date
            ,rt.rate_type_id
            ,dt.payment_templ_id
            ,
             ----Чирков удаление старых связей заявителей
             ( /*SELECT t.cn_person_id
                                            FROM C_EVENT_CONTACT t
                                           WHERE t.c_event_contact_id = ch.declarant_id*/
              SELECT t.cn_person_id
                FROM c_event_contact t
                     ,c_declarants    cd
               WHERE cd.c_claim_header_id = ch.c_claim_header_id
                 AND cd.declarant_id = t.c_event_contact_id
                 AND cd.c_declarants_id =
                     (SELECT MAX(cd_1.c_declarants_id)
                        FROM c_declarants cd_1
                       WHERE cd_1.c_claim_header_id = cd.c_claim_header_id))
            ,
             --end_Чирков удаление старых связей заявителей  
             pph.fund_pay_id
            ,pph.policy_header_id
            ,pph.fund_id
        INTO v_claim_fund_id
            ,v_pay_term_id
            ,v_policy_id
            ,v_status_date
            ,v_rt_id
            ,v_templ_id
            ,v_declarant_id
            ,v_pay_fund_id
            ,v_pol_header_id
            ,v_ph_fund_id
        FROM c_claim          cc
            ,c_claim_header   ch
            ,rate_type        rt
            ,ac_payment_templ dt
            ,p_policy         pp
            ,p_pol_header     pph
       WHERE cc.c_claim_header_id = ch.c_claim_header_id
         AND cc.c_claim_id = p_doc_id
         AND rt.brief = 'ЦБ'
         AND dt.brief = 'PAYORDER_SETOFF'
         AND pp.policy_id = ch.p_policy_id
         AND pph.policy_header_id = pp.pol_header_id;
    
      -- узнаем неоплаченные счета по договору
      /* for rc in (select ap.amount -
                        nvl((select sum(dso.set_off_amount)
                              from doc_set_off dso
                             where dso.parent_doc_id = ap.payment_id),
                            0) amount,
                        ap.fund_id p_fund_id
                   from ac_payment ap, doc_doc dd
                  where ap.payment_id = dd.child_id
                    and v_policy_id = dd.parent_id
                    and ap.due_date <= v_status_date
                    and doc.get_last_doc_status_brief(ap.payment_id) =
                        'TO_PAY') loop
        v_sum := v_sum + round(acc_new.Get_Cross_Rate_By_Id(v_rt_id,
                                                            rc.p_fund_id,
                                                            v_claim_fund_id,
                                                            v_status_date) *
                               rc.amount,
                               2);
      
      end loop; */
      v_sum := ROUND(pkg_payment.get_to_pay_amount(v_pol_header_id) *
                     acc_new.Get_Cross_Rate_By_Id(v_rt_id
                                                 ,v_ph_fund_id
                                                 ,v_claim_fund_id
                                                 ,v_status_date)
                    ,2);
      -- создаем взаимозачет
      IF v_sum > 0
      THEN
      
        SELECT c.LATIN_NAME
          INTO v_Company_Brief
          FROM CONTACT c
         WHERE c.contact_id = Pkg_App_Param.get_app_param_u('WHOAMI');
      
        IF v_Company_Brief = 'RenLife'
        THEN
          SELECT cba.ID
            INTO v_Company_Bank_Acc_ID
            FROM CN_CONTACT_BANK_ACC cba
           WHERE cba.contact_id = Pkg_App_Param.get_app_param_u('WHOAMI')
             AND cba.ID = (SELECT MAX(cbas.ID)
                             FROM CN_CONTACT_BANK_ACC cbas
                            WHERE cbas.contact_id = Pkg_App_Param.get_app_param_u('WHOAMI'));
        ELSE
          SELECT cba.ID
            INTO v_Company_Bank_Acc_ID
            FROM CN_CONTACT_BANK_ACC cba
                ,ORGANISATION_TREE   ot
           WHERE cba.contact_id = ot.company_id
             AND ot.organisation_tree_id = Pkg_Filial.get_user_org_tree_id
             AND cba.ID = (SELECT MAX(cbas.ID)
                             FROM CN_CONTACT_BANK_ACC cbas
                            WHERE cbas.contact_id = ot.company_id);
        END IF;
      
        Pkg_Payment.create_paymnt_sheduler(v_templ_id
                                          ,v_pay_term_id
                                          ,LEAST(v_sum, v_claim_sum)
                                          ,v_claim_fund_id
                                          ,v_pay_fund_id
                                          ,v_rt_id
                                          ,acc.Get_Cross_Rate_By_ID(v_rt_id
                                                                   ,v_claim_fund_id
                                                                   ,v_pay_fund_id
                                                                   ,v_status_date)
                                          ,v_declarant_id
                                          ,NULL
                                          ,v_Company_Bank_Acc_ID
                                          ,v_status_date
                                          ,p_doc_id);
        NULL;
      END IF;
      -- создаем выплаты
      pkg_payment.claim_make_planning(p_doc_id, v_Pay_Term_ID, 'PAYMENT');
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
    DELETE FROM ven_ac_payment p
     WHERE p.payment_id IN (SELECT dd.child_id FROM doc_doc dd WHERE dd.parent_id = p_doc_id);
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
                        ,ROWNUM rn
                    FROM c_claim_header ch
                        ,p_policy       pp
                   WHERE ch.p_policy_id = pp.policy_id
                     AND pp.pol_header_id = v_policy_header_id
                   ORDER BY ch.declare_date
                           ,ch.c_claim_header_id)
           WHERE rn = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
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
          v_ret_val := NVL(pkg_tariff_calc.get_attribut(ent.id_by_brief('P_COVER')
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
       AND ds.BRIEF IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.BRIEF IN ('NEW', 'CURRENT');
  
    RETURN nvl(v_sum, 0);
  END get_payed_cover_sum;
END;
/
