CREATE OR REPLACE PACKAGE pkg_decline AS

  FUNCTION active_in_waiting_period(per_cover_id NUMBER) RETURN NUMBER;
  FUNCTION get_cover_accident_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount;
  FUNCTION get_cover_life_per_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount;
  FUNCTION get_cover_admin_exp_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount;
  FUNCTION get_cover_cash_surr_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount;
  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
   ,p_zsp_sum          OUT NUMBER
   ,p_added_sum        OUT NUMBER
   ,p_payed_sum        OUT NUMBER
   ,p_extra_profit_sum OUT NUMBER
   ,p_debt_fee_sum     OUT NUMBER
   ,p_payoff_sum       OUT NUMBER
   ,p_admin_cost_sum   OUT NUMBER
  );

  PROCEDURE get_undewriting_pol_year
  (
    p_pol_id     NUMBER
   ,p_date       DATE
   ,p_start_date OUT DATE
   ,p_end_date   OUT DATE
   ,p_period     NUMBER DEFAULT 12
  );

  PROCEDURE get_undewriting_year
  (
    p_pol_header_id NUMBER
   ,p_date          DATE
   ,p_start_date    OUT DATE
   ,p_end_date      OUT DATE
   ,p_period        NUMBER DEFAULT 12
  );

  -----
  FUNCTION check_hkf(par_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION check_medo(par_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION check_comiss(par_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION policy_cancel
  (
    par_policy_id         IN NUMBER
   ,par_decline_reason_id IN NUMBER
   ,par_xkf               IN NUMBER
   ,par_medo              IN NUMBER
   ,par_comission         IN NUMBER
   ,par_cover_admin       IN NUMBER DEFAULT 0
   ,par_region_id         IN NUMBER
   ,par_product_conds_id  IN NUMBER
  ) RETURN NUMBER;

  FUNCTION create_payreq(par_policy_id IN NUMBER
                         -- Байтин А.
                         -- Добавил параметры, чтобы была возможность указывать контакт и реквизиты, не первые попавшиеся
                        ,par_contact_id          NUMBER DEFAULT NULL
                        ,par_contact_bank_acc_id NUMBER DEFAULT NULL) RETURN NUMBER;

  /* Процедура создания платежного требования
  *  @autor Чирков
  *  @param par_policy_id - ИД версии ДС
  *  @param par_contact_id - ИД контрагента платежного требования
  *  @param par_contact_bank_acc_id - ИД банковского реквизита контакта
  */

  FUNCTION create_decline_payreq(par_policy_id IN NUMBER
                                 -- Добавил параметры, чтобы была возможность указывать контакт и реквизиты, не первые попавшиеся
                                ,par_contact_id          NUMBER DEFAULT NULL
                                ,par_contact_bank_acc_id NUMBER DEFAULT NULL) RETURN NUMBER;

  PROCEDURE policy_to_state_check_ready(par_policy_id IN NUMBER);

  /*
    Байтин А.
    Проверка при загрузке аннулирования
    Пока просто устанавливает текстовое значение для причины расторжения
  */
  -- Переместил в пакет pkg_universal_loader. Изместьев.
  /*procedure check_annulation_row
  (
    par_load_file_rows_id     number
   ,par_status            out varchar2
   ,par_comment           out varchar2
  );*/

  /*
    Байтин А.
    Групповое аннулирование договоров, процедура загрузки
  */
  -- Переместил в пакет pkg_universal_loader. Изместьев.
  /*procedure annulate_list
  (
    par_load_file_rows_id number
  );*/

  /* sergey.ilyushkin 20/07/2012
  Процедура обработки - Поиск договоров для группового аннулирования */
  PROCEDURE find_annulate_list(par_load_file_rows_id NUMBER);

  /* Процедура округляет значения суммы по программам в версии прекращения договора
  * @autor Чирков В.Ю.
  * @param par_document_id - версия рассторжения
  */
  PROCEDURE round_cover_decline_sums(par_document_id NUMBER);

  /*
    Процедура на переходе версии ДС из статуса <Документ добавлен> в Статус <К прекращению>
    Аннулируются все виды документов - А7, ПД4, ППвх. Отвязанным платежам присваивается статус ручной обработки - расторжение, статус ЭР - условно-распознан.
  
    @author Пиядин А. 06.12.2013, 218940 Отвязка платежей после даты расторжения
    @param par_policy_id - ИД версии ДС
  */
  PROCEDURE policy_cancel_set_off_annulate(par_policy_id IN NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_decline AS

  FUNCTION get_next_acc_payment_date(p_pol_id NUMBER) RETURN DATE IS
    v_date      DATE;
    v_next_date DATE;
  BEGIN
    -- Нахожу первый не оплаченный счет
    BEGIN
      SELECT due_date
        INTO v_date
        FROM (SELECT acp.due_date
                FROM doc_doc    dd
                    ,ac_payment acp
               WHERE dd.parent_id = p_pol_id
                 AND acp.payment_id = dd.child_id
                 AND doc.get_doc_status_brief(acp.payment_id) <> 'PAID'
               ORDER BY acp.due_date ASC)
       WHERE rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100, 'Все счета по полису оплачены');
    END;
    -- Нахожу следующий за неоплаченным счет
    BEGIN
      SELECT due_date
        INTO v_next_date
        FROM (SELECT acp.due_date
                FROM doc_doc    dd
                    ,ac_payment acp
               WHERE dd.parent_id = p_pol_id
                 AND acp.payment_id = dd.child_id
                 AND acp.due_date > v_date
               ORDER BY acp.due_date ASC)
       WHERE rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
    RETURN v_next_date - 1;
  END;
  PROCEDURE get_undewriting_pol_year
  (
    p_pol_id     NUMBER
   ,p_date       DATE
   ,p_start_date OUT DATE
   ,p_end_date   OUT DATE
   ,p_period     NUMBER DEFAULT 12
  ) IS
    v_policy p_policy%ROWTYPE;
  BEGIN
    SELECT * INTO v_policy FROM p_policy WHERE policy_id = p_pol_id;
    p_start_date := v_policy.start_date;
    p_end_date   := ADD_MONTHS(p_start_date, p_period);
    WHILE p_date > p_end_date
    LOOP
      p_start_date := p_end_date;
      p_end_date   := ADD_MONTHS(p_start_date, p_period);
    END LOOP;
    p_end_date := p_end_date - 1;
  END;

  PROCEDURE get_undewriting_year
  (
    p_pol_header_id NUMBER
   ,p_date          DATE
   ,p_start_date    OUT DATE
   ,p_end_date      OUT DATE
   ,p_period        NUMBER DEFAULT 12
  ) IS
    v_curr_pol NUMBER;
  BEGIN
    SELECT policy_id INTO v_curr_pol FROM p_pol_header WHERE policy_header_id = p_pol_header_id;
    get_undewriting_pol_year(v_curr_pol, p_date, p_start_date, p_end_date, p_period);
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20100
                             ,'Не найдена активная версия полиса');
  END;

  PROCEDURE prepare_data_for_accounting
  (
    p_pol_header_id           NUMBER
   ,per_cover_id              NUMBER
   ,v_active_policy           OUT p_policy%ROWTYPE
   ,v_ready_to_cancel_policy  OUT p_policy%ROWTYPE
   ,v_decl_party_brief        OUT VARCHAR2
   ,v_decl_reason_brief       OUT VARCHAR2
   ,v_waiting_period_end_date OUT DATE
   ,v_active_in_wp            OUT NUMBER
  ) IS
  BEGIN
    SELECT p.*
      INTO v_active_policy
      FROM p_policy     p
          ,p_pol_header ph
     WHERE ph.policy_header_id = p_pol_header_id
       AND p.policy_id = ph.policy_id;
  
    SELECT p.*
      INTO v_ready_to_cancel_policy
      FROM p_policy p
     WHERE doc.get_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
       AND p.pol_header_id = v_active_policy.pol_header_id
       AND p.version_num > v_active_policy.version_num;
  
    SELECT dp.brief
          ,dr.brief
      INTO v_decl_party_brief
          ,v_decl_reason_brief
      FROM t_decline_reason dr
          ,t_decline_party  dp
          ,p_policy         p
     WHERE p.policy_id = v_ready_to_cancel_policy.policy_id
       AND p.decline_party_id = dp.t_decline_party_id(+)
       AND p.decline_reason_id = dr.t_decline_reason_id(+);
    v_waiting_period_end_date := pkg_policy.get_waiting_per_end_date(v_active_policy.policy_id
                                                                    ,v_active_policy.waiting_period_id
                                                                    ,v_active_policy.start_date);
  
    v_active_in_wp := active_in_waiting_period(per_cover_id);
  END;
  PROCEDURE prepare_data_for_accounting
  (
    p_pol_header_id           NUMBER
   ,per_cover_id              NUMBER
   ,v_active_policy           OUT p_policy%ROWTYPE
   ,v_ready_to_cancel_policy  OUT p_policy%ROWTYPE
   ,v_decl_party_brief        OUT VARCHAR2
   ,v_decl_reason_brief       OUT VARCHAR2
   ,v_waiting_period_end_date OUT DATE
   ,v_active_in_wp            OUT NUMBER
   ,v_cover                   OUT p_cover%ROWTYPE
  ) IS
  BEGIN
    SELECT * INTO v_cover FROM p_cover WHERE p_cover_id = per_cover_id;
    prepare_data_for_accounting(p_pol_header_id
                               ,per_cover_id
                               ,v_active_policy
                               ,v_ready_to_cancel_policy
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp);
  END;
  FUNCTION get_cover_cash_surr_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_date          DATE
  ) RETURN pkg_payment.t_amount IS
    amount pkg_payment.t_amount;
  BEGIN
    amount.fund_amount     := pkg_policy_cash_surrender.get_value_c(per_cover_id, p_date);
    amount.pay_fund_amount := amount.fund_amount;
    RETURN amount;
  END;

  FUNCTION get_cover_cash_surr_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount IS
    v_active_policy           p_policy%ROWTYPE;
    v_ready_to_cancel_policy  p_policy%ROWTYPE;
    v_start_date              DATE;
    v_end_date                DATE;
    v_date                    DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    amount                    pkg_payment.t_amount;
    v_pay_term_brief          VARCHAR2(100);
    v_number_of_payments      NUMBER;
    v_cover                   p_cover%ROWTYPE;
  BEGIN
  
    prepare_data_for_accounting(p_pol_header_id
                               ,per_cover_id
                               ,v_active_policy
                               ,v_ready_to_cancel_policy
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_cover);
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    IF v_ready_to_cancel_policy.decline_date > v_cover.end_date
       OR v_ready_to_cancel_policy.decline_date < v_cover.start_date
    THEN
      RETURN amount;
    END IF;
    IF v_ready_to_cancel_policy.decline_date <= v_waiting_period_end_date
    THEN
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        IF v_active_in_wp = 1
        THEN
          RETURN get_cover_cash_surr_sum(p_pol_header_id
                                        ,per_cover_id
                                        ,v_ready_to_cancel_policy.decline_date);
        
          /*
            select brief, number_of_payments into v_pay_term_brief, v_number_of_payments from t_payment_terms
             where id = v_active_policy.payment_term_id;
            if   v_pay_term_brief='Единовременно' then
             get_undewriting_pol_year(v_active_policy.policy_id,
                    v_ready_to_cancel_policy.decline_date,
                  v_start_date,
                  v_end_date,
                  3);
              return     get_cover_cash_surr_sum(p_pol_header_id,
                                         per_cover_id,
                                   v_end_date);
          else
             get_undewriting_pol_year(v_active_policy.policy_id,
                    v_ready_to_cancel_policy.decline_date,
                  v_start_date,
                  v_end_date,
                  12/v_number_of_payments);
             return    get_cover_cash_surr_sum(p_pol_header_id,
                                       per_cover_id,
                                 v_end_date);
          end if;
                */
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
        RETURN amount;
      END IF;
    ELSE
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        /*
        select brief, number_of_payments into v_pay_term_brief, v_number_of_payments from t_payment_terms
           where id = v_active_policy.payment_term_id;
          if   v_pay_term_brief='Единовременно' then
           get_undewriting_pol_year(v_active_policy.policy_id,
                  v_ready_to_cancel_policy.decline_date,
                v_start_date,
                v_end_date,
                3);
            return     get_cover_cash_surr_sum(p_pol_header_id,
                                       per_cover_id,
                                 v_end_date);
        else
           get_undewriting_pol_year(v_active_policy.policy_id,
                  v_ready_to_cancel_policy.decline_date,
                v_start_date,
                v_end_date,
                12/v_number_of_payments);
           return    get_cover_cash_surr_sum(p_pol_header_id,
                                     per_cover_id,
                               v_end_date);
        end if;
        */
        RETURN get_cover_cash_surr_sum(p_pol_header_id
                                      ,per_cover_id
                                      ,v_ready_to_cancel_policy.decline_date);
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса')
        THEN
          /*
           select brief, number_of_payments into v_pay_term_brief, v_number_of_payments from t_payment_terms
          where id = v_active_policy.payment_term_id;
             if   v_pay_term_brief='Единовременно' then
             v_date:= nvl(get_next_acc_payment_date(v_active_policy.policy_id), v_active_policy.end_date);
           amount:= get_cover_cash_surr_sum(p_pol_header_id,
                                    per_cover_id,
                              v_date);
           end if;
          */
          RETURN get_cover_cash_surr_sum(p_pol_header_id
                                        ,per_cover_id
                                        ,v_ready_to_cancel_policy.decline_date);
          /*elsif    v_decl_reason_brief in ('СообщЛожСвед') then*/
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      END IF;
    END IF;
    RETURN amount;
  END;

  FUNCTION get_cover_accident_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount IS
    v_active_policy           p_policy%ROWTYPE;
    v_ready_to_cancel_policy  p_policy%ROWTYPE;
    v_start_date              DATE;
    v_end_date                DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    v_cover                   p_cover%ROWTYPE;
    amount                    pkg_payment.t_amount;
    v_pay_term_brief          VARCHAR2(100);
    v_number_of_payments      NUMBER;
  BEGIN
    prepare_data_for_accounting(p_pol_header_id
                               ,per_cover_id
                               ,v_active_policy
                               ,v_ready_to_cancel_policy
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_cover);
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    IF v_ready_to_cancel_policy.decline_date > v_cover.end_date
       OR v_ready_to_cancel_policy.decline_date < v_cover.start_date
    THEN
      RETURN amount;
    END IF;
    IF v_ready_to_cancel_policy.decline_date <= v_waiting_period_end_date
    THEN
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        IF v_active_in_wp = 1
        THEN
          SELECT brief
                ,number_of_payments
            INTO v_pay_term_brief
                ,v_number_of_payments
            FROM t_payment_terms
           WHERE id = v_active_policy.payment_term_id;
          IF v_pay_term_brief = 'Единовременно'
          THEN
            amount                 := pkg_payment.get_charge_cover_amount(v_cover.start_date
                                                                         ,v_cover.end_date
                                                                         ,per_cover_id);
            amount.fund_amount     := amount.fund_amount *
                                      (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            amount.pay_fund_amount := amount.pay_fund_amount *
                                      (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            RETURN amount;
          ELSE
            get_undewriting_pol_year(v_active_policy.policy_id
                                    ,v_ready_to_cancel_policy.decline_date
                                    ,v_start_date
                                    ,v_end_date
                                    ,12 / v_number_of_payments);
            amount                 := pkg_payment.get_charge_cover_amount(v_cover.start_date
                                                                         ,v_cover.end_date
                                                                         ,per_cover_id);
            amount.fund_amount     := amount.fund_amount *
                                      (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            amount.pay_fund_amount := amount.pay_fund_amount *
                                      (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
          END IF;
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
        RETURN amount;
      END IF;
    ELSE
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        SELECT brief
              ,number_of_payments
          INTO v_pay_term_brief
              ,v_number_of_payments
          FROM t_payment_terms
         WHERE id = v_active_policy.payment_term_id;
        IF v_pay_term_brief = 'Единовременно'
        THEN
          amount                 := pkg_payment.get_charge_cover_amount(v_cover.start_date
                                                                       ,v_cover.end_date
                                                                       ,per_cover_id);
          amount.fund_amount     := amount.fund_amount *
                                    (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          amount.pay_fund_amount := amount.pay_fund_amount *
                                    (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          RETURN amount;
        ELSE
          get_undewriting_pol_year(v_active_policy.policy_id
                                  ,v_ready_to_cancel_policy.decline_date
                                  ,v_start_date
                                  ,v_end_date
                                  ,12 / v_number_of_payments);
          amount                 := pkg_payment.get_charge_cover_amount(v_cover.start_date
                                                                       ,v_cover.end_date
                                                                       ,per_cover_id);
          amount.fund_amount     := amount.fund_amount *
                                    (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          amount.pay_fund_amount := amount.pay_fund_amount *
                                    (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        /*
            if v_decl_reason_brief in ('НеоплВзноса')  then
             amount.fund_amount:= 0;
           amount.pay_fund_amount:= 0;
          elsif v_decl_reason_brief in ('СообщЛожСвед') then
             amount:= pkg_payment.get_pay_cover_amount(v_active_policy.start_date,
                                   v_ready_to_cancel_policy.decline_date,
                               per_cover_id);
          end if;
        */
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      END IF;
    END IF;
    RETURN amount;
  END;

  FUNCTION active_in_waiting_period(per_cover_id NUMBER) RETURN NUMBER IS
    v_is_active NUMBER;
  BEGIN
    SELECT decode(pl.is_active_in_waitring_period, 0, 0, 1)
      INTO v_is_active
      FROM t_product_line     pl
          ,t_prod_line_option tplo
          ,p_cover            pc
     WHERE pc.p_cover_id = per_cover_id
       AND pc.t_prod_line_option_id = tplo.id
       AND tplo.product_line_id = pl.id;
    RETURN v_is_active;
  END;

  PROCEDURE get_acc_payments_for_date
  (
    p_date            DATE
   ,p_pol_id          NUMBER
   ,p_acc_date_before OUT DATE
   ,p_acc_date_after  OUT DATE
  ) IS
  BEGIN
    BEGIN
      SELECT due_date
        INTO p_acc_date_before
        FROM (SELECT acp.due_date
                FROM doc_doc    dd
                    ,ac_payment acp
               WHERE dd.parent_id = p_pol_id
                 AND acp.payment_id = dd.child_id
                 AND doc.get_doc_status_brief(acp.payment_id) = 'PAID'
                 AND acp.due_date <= p_date
               ORDER BY acp.due_date DESC)
       WHERE rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
    BEGIN
      SELECT due_date
        INTO p_acc_date_after
        FROM (SELECT acp.due_date
                FROM doc_doc    dd
                    ,ac_payment acp
               WHERE dd.parent_id = p_pol_id
                 AND acp.payment_id = dd.child_id
                 AND acp.due_date > p_date
               ORDER BY acp.due_date ASC)
       WHERE rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
  END;

  FUNCTION get_pay_cover_admin_exp_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount IS
    v_active_policy          p_policy%ROWTYPE;
    v_ready_to_cancel_policy p_policy%ROWTYPE;
    amount                   pkg_payment.t_amount;
  BEGIN
    SELECT p.*
      INTO v_active_policy
      FROM p_policy     p
          ,p_pol_header ph
     WHERE ph.policy_header_id = p_pol_header_id
       AND p.policy_id = ph.policy_id;
    SELECT p.*
      INTO v_ready_to_cancel_policy
      FROM p_policy     p
          ,p_pol_header ph
     WHERE ph.policy_header_id = p_pol_header_id
       AND p.pol_header_id = ph.policy_header_id
       AND doc.get_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL';
    amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                              ,v_ready_to_cancel_policy.decline_date
                                              ,per_cover_id);
    RETURN amount;
  END;

  FUNCTION get_cover_admin_exp_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount IS
    v_active_policy           p_policy%ROWTYPE;
    v_ready_to_cancel_policy  p_policy%ROWTYPE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    amount                    pkg_payment.t_amount;
  BEGIN
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    prepare_data_for_accounting(p_pol_header_id
                               ,per_cover_id
                               ,v_active_policy
                               ,v_ready_to_cancel_policy
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp);
    IF v_decl_party_brief NOT IN ('Страхователь', 'По соглашению сторон')
    THEN
      IF v_decl_reason_brief NOT IN ('НеоплВзноса')
      THEN
        amount := pkg_decline.get_pay_cover_admin_exp_sum(p_pol_header_id, per_cover_id);
      END IF;
    END IF;
    RETURN amount;
  END;

  FUNCTION get_cover_life_per_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN pkg_payment.t_amount IS
    v_active_policy           p_policy%ROWTYPE;
    v_ready_to_cancel_policy  p_policy%ROWTYPE;
    v_start_date              DATE;
    v_end_date                DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    amount                    pkg_payment.t_amount;
    v_cover                   p_cover%ROWTYPE;
    v_pay_term_brief          VARCHAR2(100);
    v_number_of_payments      NUMBER;
  BEGIN
    prepare_data_for_accounting(p_pol_header_id
                               ,per_cover_id
                               ,v_active_policy
                               ,v_ready_to_cancel_policy
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_cover);
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    IF v_ready_to_cancel_policy.decline_date > v_cover.end_date
       OR v_ready_to_cancel_policy.decline_date < v_cover.start_date
    THEN
      RETURN amount;
    END IF;
    IF v_ready_to_cancel_policy.decline_date <= v_waiting_period_end_date
    THEN
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        IF v_active_in_wp = 1
        THEN
          SELECT brief
                ,number_of_payments
            INTO v_pay_term_brief
                ,v_number_of_payments
            FROM t_payment_terms
           WHERE id = v_active_policy.payment_term_id;
          IF v_pay_term_brief = 'Единовременно'
          THEN
            amount                 := pkg_payment.get_charge_cover_amount(v_cover.start_date
                                                                         ,v_cover.end_date
                                                                         ,per_cover_id);
            amount.fund_amount     := amount.fund_amount *
                                      (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_cover.end_date - v_cover.start_date);
            amount.pay_fund_amount := amount.pay_fund_amount *
                                      (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_cover.end_date - v_cover.start_date);
            RETURN amount;
          ELSE
            get_undewriting_pol_year(v_active_policy.policy_id
                                    ,v_ready_to_cancel_policy.decline_date
                                    ,v_start_date
                                    ,v_end_date
                                    ,12 / v_number_of_payments);
            amount                 := pkg_payment.get_charge_cover_amount(v_start_date
                                                                         ,v_end_date
                                                                         ,per_cover_id);
            amount.fund_amount     := amount.fund_amount *
                                      (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_end_date - v_start_date);
            amount.pay_fund_amount := amount.pay_fund_amount *
                                      (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                      (v_end_date - v_start_date);
          END IF;
        
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      END IF;
    ELSE
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        SELECT brief
              ,number_of_payments
          INTO v_pay_term_brief
              ,v_number_of_payments
          FROM t_payment_terms
         WHERE id = v_active_policy.payment_term_id;
        IF v_pay_term_brief = 'Единовременно'
        THEN
          amount                 := pkg_payment.get_charge_cover_amount(v_cover.start_date
                                                                       ,v_cover.end_date
                                                                       ,per_cover_id);
          amount.fund_amount     := amount.fund_amount *
                                    (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_cover.end_date - v_cover.start_date);
          amount.pay_fund_amount := amount.pay_fund_amount *
                                    (v_cover.end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_cover.end_date - v_cover.start_date);
          RETURN amount;
        ELSE
          get_undewriting_pol_year(v_active_policy.policy_id
                                  ,v_ready_to_cancel_policy.decline_date
                                  ,v_start_date
                                  ,v_end_date
                                  ,12 / v_number_of_payments);
          amount                 := pkg_payment.get_charge_cover_amount(v_start_date
                                                                       ,v_end_date
                                                                       ,per_cover_id);
          amount.fund_amount     := amount.fund_amount *
                                    (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_end_date - v_start_date);
          amount.pay_fund_amount := amount.pay_fund_amount *
                                    (v_end_date - v_ready_to_cancel_policy.decline_date) /
                                    (v_end_date - v_start_date);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := pkg_payment.get_pay_cover_amount(v_active_policy.start_date
                                                    ,v_ready_to_cancel_policy.decline_date
                                                    ,per_cover_id);
        END IF;
      END IF;
    END IF;
    RETURN amount;
  END;

  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
   ,p_zsp_sum          OUT NUMBER
   ,p_added_sum        OUT NUMBER
   ,p_payed_sum        OUT NUMBER
   ,p_extra_profit_sum OUT NUMBER
   ,p_debt_fee_sum     OUT NUMBER
   ,p_payoff_sum       OUT NUMBER
   ,p_admin_cost_sum   OUT NUMBER
  ) IS
    v_cover_prem        NUMBER := 0; -- Премия по покрытию
    v_cover_ret         NUMBER := 0; -- Возврат по покрытию
    v_cover_topay       NUMBER := 0; -- К выплате по покрытию
    v_cover_added       NUMBER := 0; -- начислено по покрытию
    v_cover_payed       NUMBER := 0; -- оплачено по покрытию
    v_debt_fee_sum      NUMBER := 0;
    v_decline_date      DATE;
    v_cancel_pol_id     NUMBER;
    v_pol_prem          NUMBER := 0;
    v_cancel_pol_ver    NUMBER := 0;
    v_decl_reason_brief VARCHAR2(100);
  BEGIN
    p_zsp_sum          := 0;
    p_added_sum        := 0;
    p_payed_sum        := 0;
    p_extra_profit_sum := 0;
    p_debt_fee_sum     := 0;
    p_admin_cost_sum   := 0;
    p_payoff_sum       := 0;
    SELECT p.decline_date
          ,p.policy_id
          ,p.version_num
          ,dr.brief
      INTO v_decline_date
          ,v_cancel_pol_id
          ,v_cancel_pol_ver
          ,v_decl_reason_brief
      FROM p_policy         p
          ,t_decline_reason dr
     WHERE p.pol_header_id = p_pol_header_id
       AND doc.get_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
       AND dr.t_decline_reason_id = p.decline_reason_id;
  
    FOR pol IN (SELECT p.*
                  FROM p_policy p
                 WHERE p.pol_header_id = p_pol_header_id
                   AND version_num = v_cancel_pol_ver - 1)
    LOOP
      FOR pc IN (SELECT pc.*
                   FROM p_cover  pc
                       ,as_asset a
                  WHERE a.as_asset_id = pc.as_asset_id
                    AND a.p_policy_id = pol.policy_id
                    AND a.status_hist_id <> pkg_cover.status_hist_id_del
                    AND pc.status_hist_id <> pkg_cover.status_hist_id_del)
      LOOP
        FOR pct IN (SELECT md.metod_func_id
                          ,pl.brief
                          ,plt.brief plt_brief
                          ,pl.description
                      FROM t_prod_line_met_decl plmd
                          ,t_metod_decline      md
                          ,t_prod_line_option   plo
                          ,t_product_line       pl
                          ,t_product_line_type  plt
                     WHERE md.t_metod_decline_id = plmd.t_prodline_metdec_met_decl_id
                       AND plmd.t_prodline_metdec_prod_line_id = plo.product_line_id
                       AND plo.id = pc.t_prod_line_option_id
                       AND pl.id = plo.product_line_id
                       AND pl.product_line_type_id = plt.product_line_type_id(+))
        LOOP
        
          v_debt_fee_sum := nvl(pkg_payment.get_debt_cover_amount(pc.p_cover_id, v_decline_date)
                                .fund_amount
                               ,0);
          IF v_debt_fee_sum != 0
             AND v_decl_reason_brief != 'НеоплВзноса'
             AND pkg_policy.get_privilege_per_end_date(pol.policy_id) < v_decline_date
          THEN
            raise_application_error(-20120
                                   ,'Есть задолженность по программе ' || pct.description ||
                                    '.Причиной расторжения должна быть Неоплата');
          END IF;
          p_debt_fee_sum := p_debt_fee_sum + v_debt_fee_sum;
        
          v_cover_ret   := nvl(pkg_tariff_calc.calc_fun(pct.metod_func_id
                                                       ,ent.id_by_brief('P_COVER')
                                                       ,pc.p_cover_id)
                              ,0);
          p_zsp_sum     := p_zsp_sum + v_cover_ret;
          v_cover_added := nvl(pkg_payment.get_charge_cover_amount(pc.start_date, pc.end_date, pc.p_cover_id)
                               .fund_amount
                              ,0);
        
          p_added_sum   := p_added_sum + v_cover_added;
          v_cover_payed := nvl(pkg_payment.get_pay_cover_amount(pc.start_date, v_decline_date, pc.p_cover_id)
                               .fund_amount
                              ,0);
        
          p_payed_sum := p_payed_sum + v_cover_payed;
          IF pct.brief = 'ADMIN_EXPENCES'
          THEN
            p_admin_cost_sum := pkg_decline.get_pay_cover_admin_exp_sum(p_pol_header_id, pc.p_cover_id)
                                .fund_amount;
          END IF;
          IF pct.plt_brief = 'RECOMMENDED'
          THEN
            FOR pol_decl IN (SELECT dp.brief
                                   ,p.med_cost
                               FROM t_decline_party dp
                                   ,p_policy        p
                              WHERE p.decline_party_id = dp.t_decline_party_id
                                AND doc.get_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
                                AND p.version_num = pol.version_num + 1
                                AND p.pol_header_id = p_pol_header_id)
            LOOP
              IF pol_decl.brief = 'Страхователь'
              THEN
                p_zsp_sum := p_zsp_sum - nvl(pol_decl.med_cost, 0);
              END IF;
            END LOOP;
          END IF;
        END LOOP;
        -- Запоминаем премию и возврат по покрытию
        -- v_cover_topay:= GREATEST(v_cover_ret- v_debt_fee_sum, 0);
        -- Ф.Ганичев. Е. Воинова
        v_cover_topay := v_cover_ret;
        p_payoff_sum  := p_payoff_sum + v_cover_topay;
        v_cover_prem  := v_cover_payed - v_cover_topay;
        v_pol_prem    := v_pol_prem + v_cover_prem;
        FOR pc_declare IN (SELECT pc_dec.*
                             FROM p_cover  pc_dec
                                 ,as_asset a
                                 ,p_policy p
                            WHERE p.pol_header_id = pol.pol_header_id
                              AND doc.get_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
                              AND p.version_num = pol.version_num + 1
                              AND a.p_policy_id = p.policy_id
                              AND pc_dec.as_asset_id = a.as_asset_id
                              AND pc.t_prod_line_option_id = pc_dec.t_prod_line_option_id)
        LOOP
          UPDATE p_cover
             SET old_premium  = pc.premium
                ,premium      = v_cover_prem
                ,decline_summ = v_cover_topay
                ,return_summ  = v_cover_ret
                ,added_summ   = v_cover_added
                ,payed_summ   = v_cover_payed
                ,debt_summ    = v_debt_fee_sum
           WHERE p_cover_id = pc_declare.p_cover_id;
          --dbms_output.put_line('pc_dec.P_COVER_ID = '||pc_declare.P_COVER_ID||' '||v_cover_prem);
        END LOOP;
      END LOOP;
    END LOOP;
    --p_payoff_sum:= p_zsp_sum - p_debt_fee_sum;
    p_payoff_sum := nvl(p_payoff_sum, 0);
    UPDATE p_policy
       SET premium      = v_pol_prem
          ,decline_summ = p_payoff_sum
          ,return_summ  = p_zsp_sum
          ,added_summ   = p_added_sum
          ,payed_summ   = p_payed_sum
          ,debt_summ    = p_debt_fee_sum
     WHERE policy_id = v_cancel_pol_id;
  END;

  /* Поскряков 14.03.2012
    Проверка на наличие банка НКФ
  */
  FUNCTION check_hkf(par_policy_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --Определяем наличие "ХКФ БАНК"
    SELECT nvl(COUNT(pr.product_id), 0)
      INTO res
      FROM t_product    pr
          ,p_pol_header ph
          ,p_policy     p
     WHERE pr.product_id = ph.product_id
       AND ph.policy_header_id = p.pol_header_id
       AND p.policy_id = par_policy_id
       AND pr.description LIKE '%ХКФ%';
  
    RETURN res;
  END check_hkf;

  /* Поскряков 14.03.2012
    Проверка на наличие MEDO
  */
  FUNCTION check_medo(par_policy_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --Определяем MEDO
    SELECT nvl(SUM(am.exam_cost), 0)
      INTO res
      FROM assured_medical_exam am
          ,as_asset             a
          ,as_assured           s
     WHERE am.as_assured_id = s.as_assured_id
       AND s.as_assured_id = a.as_asset_id
       AND a.p_policy_id = par_policy_id;
    /*
        --второй вариант определения Медо
        select nvl(sum(s.exam_cost),0) into res
        from   as_asset a, as_assured s
        where s.as_assured_id=a.as_asset_id
        and a.p_policy_id=par_policy_id;
    */
    RETURN res;
  END check_medo;

  /* Поскряков 14.03.2012
    Проверка на наличие Комиссии
  */
  FUNCTION check_comiss(par_policy_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    --Ищем сумму комиссии
    SELECT nvl(SUM(pri.commission), 0)
      INTO res
      FROM payment_register_item pri
     WHERE pri.ids IN (SELECT ph.ids
                         FROM p_pol_header ph
                             ,p_policy     p
                        WHERE p.pol_header_id = ph.policy_header_id
                          AND p.policy_id = par_policy_id)
       AND rownum = 1
     ORDER BY pri.ac_payment_id;
  
    RETURN res;
  
  END check_comiss;

  /* Поскряков 14.03.2012
    Процедура аннулирования версии договора
  
  */
  FUNCTION policy_cancel
  (
    par_policy_id         IN NUMBER
   ,par_decline_reason_id IN NUMBER
   ,par_xkf               IN NUMBER
   ,par_medo              IN NUMBER
   ,par_comission         IN NUMBER
   ,par_cover_admin       IN NUMBER DEFAULT 0
   ,par_region_id         IN NUMBER
   ,par_product_conds_id  IN NUMBER
  ) RETURN NUMBER IS
    decline_row            p_cover_decline%ROWTYPE;
    pol_decline            p_pol_decline%ROWTYPE;
    new_p_pol_decline_id   NUMBER;
    p_first_version_id     NUMBER;
    p_fee                  NUMBER;
    p_brutto_all           NUMBER;
    p_pay_sum              NUMBER;
    p_pay_count            NUMBER;
    p_risk_type            NUMBER;
    p_reg_code             NUMBER;
    p_payreg_id            NUMBER;
    p_confirm_date         DATE;
    p_doc_status_action_id NUMBER;
    p_admin_exp            NUMBER := 0;
  BEGIN
  
    /* Капля П.С. Заявка 250048
    IF par_XKF = 0
    THEN
      --Продукт по договору не содержит "ХКФ БАНК" считаем МЕДО без комиссии
      pol_decline.management_expenses := par_medo;
    ELSE
      pol_decline.management_expenses := par_medo + par_comission;
    END IF;*/
    pol_decline.management_expenses := par_medo;
  
    --Ищем код региона
    BEGIN
      SELECT ot.reg_code
        INTO p_reg_code
        FROM /*VEN_P_POLICY_AGENT_DOC ad,*/ p_policy_agent_doc ad
            ,document           d
            ,ag_contract_header ch
            ,department         dp
            ,organisation_tree  ot
       WHERE ad.policy_header_id =
             (SELECT p2.pol_header_id FROM p_policy p2 WHERE p2.policy_id = par_policy_id)
         AND d.document_id = ad.p_policy_agent_doc_id
         AND d.doc_status_ref_id = 2
         AND ch.ag_contract_header_id = ad.ag_contract_header_id
         AND dp.department_id = ch.agency_id
         AND ot.organisation_tree_id = dp.org_tree_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_reg_code := par_region_id;
    END;
  
    pol_decline.t_product_conds_id := par_product_conds_id; --По умолчанию Общие условия страхования
  
    /*    update p_pol_decline
          set management_expenses = pol_decline.management_expenses
          ,reg_code = pol_decline.reg_code
          ,t_product_conds_id=pol_decline.t_product_conds_id
         where p_pol_decline_id = new_p_pol_decline_id;
    */
  
    --Ищем ID первой версии договора
    SELECT MIN(p.policy_id)
      INTO p_first_version_id
      FROM p_policy p
     WHERE p.pol_header_id =
           (SELECT p2.pol_header_id FROM p_policy p2 WHERE p2.policy_id = par_policy_id);
  
    -- Ищем зачтенные платежи по договору
    SELECT SUM(ps.part_pay_amount)
      INTO p_pay_sum
      FROM v_policy_payment_schedule ps
     WHERE ps.pol_header_id =
           (SELECT p2.pol_header_id FROM p_policy p2 WHERE p2.policy_id = par_policy_id);
  
    --Определяем дату вступления в силу первой версии
    SELECT p.confirm_date INTO p_confirm_date FROM p_policy p WHERE p.policy_id = p_first_version_id;
  
    --Вставка в p_pol_decline чтобы была родительская запись. После расчетов заполним остальные поля
    SELECT sq_p_pol_decline.nextval INTO new_p_pol_decline_id FROM dual;
    INSERT INTO p_pol_decline
      (p_pol_decline_id
      ,p_policy_id
      ,management_expenses
      ,reg_code
      ,t_product_conds_id
      ,medo_cost
      ,act_date
      ,total_fee_payment_sum
      ,debt_fee_fact
      ,overpayment
      ,issuer_return_date)
    VALUES
      (new_p_pol_decline_id
      ,par_policy_id
      ,pol_decline.management_expenses
      ,p_reg_code
      ,pol_decline.t_product_conds_id
      ,par_medo
      ,SYSDATE
      ,p_pay_sum
      ,0
      ,0
      ,decode(par_cover_admin, 0, SYSDATE, NULL));
  
    --Ставим причину расторжения
    UPDATE p_policy p
       SET p.decline_reason_id = par_decline_reason_id
          ,p.debt_summ         = 0
          ,p.decline_date      = p_confirm_date
     WHERE p.policy_id = par_policy_id;
  
    --Ищем общий брутто-взнос по первой версии договора
    SELECT SUM(pc.fee)
      INTO p_brutto_all
      FROM as_asset           a
          ,as_assured         s
          ,p_cover            pc
          ,t_prod_line_option plo
     WHERE pc.as_asset_id = a.as_asset_id
       AND a.as_asset_id = s.as_assured_id
       AND plo.id = pc.t_prod_line_option_id
       AND a.p_policy_id = p_first_version_id
       AND plo.description <> 'Административные издержки';
  
    --Цикл по застрахованным и программам версии
    FOR cur IN (SELECT pc.*
                      ,plo.product_line_id
                      ,ph.product_id
                      ,ph.policy_header_id
                      ,plo.description
                      ,pt.number_of_payments
                  FROM p_pol_header       ph
                      ,p_policy           p
                      ,as_asset           a
                      ,as_assured         s
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_payment_terms    pt
                 WHERE pc.as_asset_id = a.as_asset_id
                   AND s.as_assured_id = a.as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND a.p_policy_id = p_first_version_id -- par_policy_id
                   AND ph.policy_header_id = p.pol_header_id
                   AND p.policy_id = a.p_policy_id
                   AND p.payment_term_id = pt.id
                   AND plo.brief != 'NonInsuranceClaims')
    LOOP
    
      decline_row.p_pol_decline_id  := new_p_pol_decline_id;
      decline_row.as_asset_id       := cur.as_asset_id;
      decline_row.t_product_line_id := cur.product_line_id;
      decline_row.cover_period      := trunc(MONTHS_BETWEEN(trunc(cur.end_date) + 1
                                                           ,trunc(cur.start_date)) / 12
                                            ,2);
    
      --находим брутто-взнос программы в первой версии, соответствующей версии расторжения
      BEGIN
        SELECT pc.fee
          INTO p_fee
          FROM p_cover            pc
              ,as_asset           a
              ,as_assured         s
              ,t_prod_line_option plo
         WHERE plo.id = pc.t_prod_line_option_id
           AND pc.as_asset_id = a.as_asset_id
           AND a.as_asset_id = s.as_assured_id
           AND a.p_policy_id = p_first_version_id
              --    and a.as_asset_id=cur.as_asset_id
           AND plo.product_line_id = cur.product_line_id;
      EXCEPTION
        WHEN no_data_found THEN
          p_fee := 0;
      END;
    
      --Рассчитываем возврат части премии
      decline_row.return_bonus_part := (p_pay_sum - pol_decline.management_expenses) * p_fee /
                                       p_brutto_all;
    
      --Премии к списанию
      -- NC
      --Определяем, действует ли риск в текущем году
      SELECT COUNT(DISTINCT ap.payment_number)
        INTO p_pay_count
        FROM doc_doc    dd
            ,ac_payment ap
       WHERE dd.parent_id IN (SELECT p.policy_id
                                FROM p_pol_header ph
                                    ,p_policy     p
                               WHERE ph.policy_header_id = p.pol_header_id
                                 AND p.pol_header_id = cur.policy_header_id)
         AND ap.payment_id = dd.child_id
         AND ap.plan_date >= to_date('01.01.' || to_char(SYSDATE, 'YYYY'), 'DD.MM.YYYY');
    
      --Для текущего года просто умножаем на количество платежей в году
      IF p_pay_count > 0
      THEN
        decline_row.bonus_off_current := p_fee * cur.number_of_payments;
      END IF;
    
      --Определяем количество годовщин до текущего года
      SELECT COUNT(DISTINCT(to_char(ap.plan_date, 'YYYY')))
        INTO p_pay_count
        FROM doc_doc    dd
            ,ac_payment ap
       WHERE dd.parent_id IN
             (SELECT p.policy_id
                FROM p_pol_header ph
                    ,p_policy     p
               WHERE ph.policy_header_id = p.pol_header_id
                 AND p.pol_header_id =
                     (SELECT p2.pol_header_id FROM p_policy p2 WHERE p2.policy_id = par_policy_id))
         AND ap.payment_id = dd.child_id
         AND ap.plan_date < to_date('01.01.' || to_char(SYSDATE, 'YYYY'), 'DD.MM.YYYY');
    
      decline_row.bonus_off_prev := p_fee * p_pay_count * cur.number_of_payments;
    
      IF par_xkf = 1
      THEN
        --Для ХКФ Возврат части премии  = примия к списанию в зависимости от года заключения
        --Если дата заключения/расторжения в текущем году, то списание этого года = ВЧП
        IF to_char(p_confirm_date, 'YYYY') = to_char(SYSDATE, 'YYYY')
        THEN
          decline_row.bonus_off_prev    := 0;
          decline_row.bonus_off_current := decline_row.return_bonus_part;
        ELSIF to_char(p_confirm_date, 'YYYY') < to_char(SYSDATE, 'YYYY')
        THEN
          decline_row.bonus_off_prev    := decline_row.return_bonus_part;
          decline_row.bonus_off_current := 0;
        END IF;
      END IF;
    
      --вставка строки
      decline_row.p_pol_decline_id    := new_p_pol_decline_id;
      decline_row.ent_id              := 4743;
      decline_row.redemption_sum      := 0;
      decline_row.add_invest_income   := 0;
      decline_row.underpayment_actual := 0;
    
      IF cur.description = 'Административные издержки'
      THEN
        p_admin_exp := cur.fee;
        UPDATE p_pol_decline pd
           SET pd.admin_expenses = cur.fee
         WHERE pd.p_pol_decline_id = new_p_pol_decline_id;
      END IF;
    
      SELECT sq_p_cover_decline.nextval INTO decline_row.p_cover_decline_id FROM dual;
    
      IF (par_cover_admin = 0 AND cur.description <> 'Административные издержки')
         OR par_cover_admin = 1
      THEN
        INSERT INTO p_cover_decline VALUES decline_row;
      END IF;
    END LOOP;
  
    /*NVL(pd.issuer_return_sum, 0 )
     + NVL( pd.overpayment, 0 )
    -- - NVL( p_debt_fee_sum, 0 )
     - NVL( pd.medo_cost, 0 )
     - NVL( pd.admin_expenses, 0 )
     - NVL( pd.other_pol_sum, 0 ),*/
  
    --Чирков--182525: Доработка - корректировка расчета суммы "к возврату" при 
    --округляем суммы до 2-ух знаков  
    round_cover_decline_sums(par_policy_id);
    --
  
    UPDATE p_pol_decline pd
       SET pd.issuer_return_sum =
           (SELECT SUM(cd.return_bonus_part)
              FROM p_cover_decline cd
             WHERE cd.p_pol_decline_id = new_p_pol_decline_id)
          ,pd.admin_expenses    = p_admin_exp
     WHERE pd.p_pol_decline_id = new_p_pol_decline_id;
  
    UPDATE p_policy p
       SET p.return_summ =
           (SELECT SUM(cd.return_bonus_part)
              FROM p_cover_decline cd
             WHERE cd.p_pol_decline_id = new_p_pol_decline_id)
     WHERE p.policy_id = par_policy_id;
  
    RETURN 1;
    --exception when others then
    --  raise_application_error(-20100, sqlerrm);
    --  return 0;
  
  END policy_cancel;

  PROCEDURE policy_to_state_check_ready(par_policy_id IN NUMBER) IS
    p_doc_status_action_id NUMBER;
    v_is_execute           doc_status_action.is_execute%TYPE;
    v_is_required          doc_status_action.is_required%TYPE;
  BEGIN
    --Отключаем проверку Прекращение ДС. Формирование корректирующих проводок
    --Ищем ID процедуры при переходе
    SELECT dsa3.doc_status_action_id
           -- Байтин А.
           -- Запоминаем предыдущее состояние
          ,dsa3.is_execute
          ,dsa3.is_required
      INTO p_doc_status_action_id
          ,v_is_execute
          ,v_is_required
      FROM ven_doc_templ          dt
          ,entity                 e
          ,ven_doc_templ_status   dts
          ,doc_status_ref         dsr
          ,ven_doc_status_allowed dsa2
          ,doc_templ_status       dts2
          ,doc_status_ref         dsr2
          ,ven_doc_status_action  dsa3
          ,doc_action_type        dat
     WHERE dt.doc_ent_id = e.ent_id
       AND dts.doc_templ_id = dt.doc_templ_id
       AND dsr.doc_status_ref_id = dts.doc_status_ref_id
       AND dt.brief = 'POLICY'
       AND dsr.brief = 'TO_QUIT'
       AND dsa2.dest_doc_templ_status_id = dts2.doc_templ_status_id
       AND dts2.doc_status_ref_id = dsr2.doc_status_ref_id
       AND dsa2.src_doc_templ_status_id = dts.doc_templ_status_id
       AND dsr2.brief = 'TO_QUIT_CHECK_READY'
       AND dsa3.doc_action_type_id = dat.doc_action_type_id
       AND dsa3.doc_status_allowed_id = dsa2.doc_status_allowed_id
       AND ent.obj_name(dsa3.obj_ure_id, dsa3.obj_uro_id) =
           'Прекращение ДС. Формирование корректирующих проводок';
  
    IF v_is_execute != 0
       OR v_is_required != 0
    THEN
      --Отключаем выполнение процедуры
      UPDATE doc_status_action dsa
         SET dsa.is_execute  = 0
            ,dsa.is_required = 0
       WHERE dsa.doc_status_action_id = p_doc_status_action_id;
    END IF;
    --Переводим в статус  Готов для проверки
    doc.set_doc_status(par_policy_id, 'TO_QUIT_CHECK_READY');
  
    IF v_is_execute != 0
       OR v_is_required != 0
    THEN
      --Включаем выполнение процедуры
      UPDATE doc_status_action dsa
         SET dsa.is_execute  = /*1*/ v_is_execute
            ,dsa.is_required = /*1*/ v_is_required
       WHERE dsa.doc_status_action_id = p_doc_status_action_id;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /* Поскряков 14.03.2012
    Процедура создания платежного требования (и перевода статуса договора)
  */
  FUNCTION create_payreq(par_policy_id IN NUMBER
                         -- Байтин А.
                         -- Добавил параметры, чтобы была возможность указывать контакт и реквизиты, не первые попавшиеся
                        ,par_contact_id          NUMBER DEFAULT NULL
                        ,par_contact_bank_acc_id NUMBER DEFAULT NULL) RETURN NUMBER AS
    v_contact_id          NUMBER;
    v_contact_bank_acc_id NUMBER;
    v_payment_id          NUMBER;
  
  BEGIN
  
    IF par_contact_id IS NOT NULL
       AND par_contact_bank_acc_id IS NOT NULL
    THEN
      v_contact_id          := par_contact_id;
      v_contact_bank_acc_id := par_contact_bank_acc_id;
    ELSE
      BEGIN
        SELECT contact_id INTO v_contact_id FROM v_pol_issuer WHERE policy_id = par_policy_id;
      
        SELECT a.id
          INTO v_contact_bank_acc_id
          FROM ven_cn_contact_bank_acc a
              ,v_pol_issuer            i
         WHERE i.policy_id = par_policy_id
           AND i.contact_id = a.contact_id
           AND a.used_flag = 1
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          doc.set_doc_status(par_policy_id, 'TO_QUIT_CHECKED');
          raise_application_error(-20001
                                 ,'Не обнаружены банковские реквизиты получателя');
      END;
    END IF;
  
    v_payment_id := create_decline_payreq(par_policy_id, v_contact_id, v_contact_bank_acc_id);
  
    SAVEPOINT before_quit_req_query;
    BEGIN
      --Переводим в статус "Прекращен.Запрос реквизитов"
      doc.set_doc_status(par_policy_id, 'QUIT_REQ_QUERY');
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO before_quit_req_query;
        RAISE;
    END;
  
    SAVEPOINT before_quit_req_get;
    BEGIN
      --Переводим в статус "Прекращен.Реквизиты получены"
      doc.set_doc_status(par_policy_id, 'QUIT_REQ_GET');
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO before_quit_req_get;
        RAISE;
    END;
  
    SAVEPOINT before_quit_to_pay;
    BEGIN
      --Переводим в статус "Прекращен.К выплате"
      doc.set_doc_status(par_policy_id, 'QUIT_TO_PAY');
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO before_quit_to_pay;
        RAISE;
    END;
  
    COMMIT;
  
    RETURN v_payment_id;
  
  END create_payreq;

  /* Процедура создания платежного требования
  *  @autor Чирков
  *  @param par_policy_id - ИД версии ДС
  *  @param par_contact_id - ИД контрагента платежного требования
  *  @param par_contact_bank_acc_id - ИД банковского реквизита контакта
  */
  FUNCTION create_decline_payreq(par_policy_id IN NUMBER
                                 -- Добавил параметры, чтобы была возможность указывать контакт и реквизиты, не первые попавшиеся
                                ,par_contact_id          NUMBER DEFAULT NULL
                                ,par_contact_bank_acc_id NUMBER DEFAULT NULL) RETURN NUMBER IS
    v_payment_id               ins.ac_payment.payment_id%TYPE;
    v_doc_templ_id             ins.doc_templ.doc_templ_id%TYPE;
    v_payment_templ_id         ins.ac_payment.payment_templ_id%TYPE;
    v_num                      NUMBER;
    v_payment_terms_id         ins.t_payment_terms.id%TYPE;
    v_fund_id                  ins.fund.fund_id%TYPE;
    v_payment_type_id          ins.ac_payment.payment_type_id%TYPE;
    v_payment_direct_id        ins.ac_payment.payment_direct_id%TYPE;
    v_amount                   ins.p_pol_decline.overpayment%TYPE;
    v_collection_method_id     ins.t_payment_terms.collection_method_id%TYPE;
    v_fund_brief               ins.fund.brief%TYPE;
    v_sum_redemption_sum       ins.p_cover_decline.redemption_sum%TYPE;
    v_sum_add_invest_income    ins.p_cover_decline.add_invest_income%TYPE;
    v_sum_return_bonus_part    ins.p_cover_decline.return_bonus_part%TYPE;
    v_medo_cost                ins.p_pol_decline.medo_cost%TYPE;
    v_debt_fee_fact            ins.p_pol_decline.debt_fee_fact%TYPE;
    v_note                     VARCHAR2(210);
    v_doc_txt                  VARCHAR2(1000);
    v_debt_fee_sum             ins.p_policy.debt_summ%TYPE;
    v_pol_num                  ins.p_policy.pol_num%TYPE;
    v_admin_exp                ins.p_pol_decline.admin_expenses%TYPE := 0;
    v_contact_id               ins.contact.contact_id%TYPE;
    v_insurer_id               ins.contact.contact_id%TYPE;
    v_contact_bank_acc_id      ins.cn_contact_bank_acc.id%TYPE;
    v_owner_contact_id         ins.cn_contact_bank_acc.owner_contact_id%TYPE;
    v_is_ndfl                  NUMBER;
    v_insurer_type_brief       t_contact_type.brief%TYPE;
    v_owner_contact_type_brief t_contact_type.brief%TYPE;
  
    /* Процедура формирования назначения платежа для платежного требования
    * @autor Чирков
    */
    /*
    TODO: owner="Pavel.Kaplya" category="Fix" created="15.05.2014"
    text="Сделать процедуру локальной для функции crate_decline_payreq и убрать из спецификации"
    */
    FUNCTION build_note
    (
      par_policy_id             IN NUMBER
     ,par_sum_return_bonus_part IN NUMBER
     ,par_admin_expenses        IN NUMBER
     ,par_medo_cost             IN NUMBER
     ,par_sum_redemption_sum    IN NUMBER
     ,par_sum_add_invest_income IN NUMBER
     ,par_debt_fee_fact         IN NUMBER
     ,par_pol_num               IN VARCHAR2
     ,par_is_ndfl               IN NUMBER := NULL
    ) RETURN VARCHAR2 AS
      v_note             VARCHAR2(210);
      v_note_1           VARCHAR2(500);
      v_note_2           VARCHAR2(500);
      v_note_3           VARCHAR2(500);
      v_note_4           VARCHAR2(500);
      v_str              VARCHAR2(1000);
      v_personal_account VARCHAR2(30);
      v_pc_account       VARCHAR2(30);
      v_contact_id       NUMBER;
      v_beneficiary_name VARCHAR2(1000);
      v_cnt              NUMBER;
      v_return_sum       NUMBER;
      --v_ndfl             NUMBER;
      v_issuer_name VARCHAR2(1000);
    BEGIN
      BEGIN
        SELECT a.lic_code
              ,i.contact_name
              ,a.account_corr
          INTO v_personal_account
              ,v_issuer_name
              ,v_pc_account
          FROM ven_cn_contact_bank_acc a
              ,v_pol_issuer            i
         WHERE i.policy_id = par_policy_id
           AND i.contact_id = a.contact_id
           AND a.used_flag = 1
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
          /*
           raise_application_error(-20001, 'Ошибка создания платежного требования' ||
              'Не обнаруженв банковские реквизиты получателя: ' || SQLERRM);
          WHEN others THEN
            raise_application_error(-20001,  'Ошибка создания платежного требования' ||
              'Ошибка определения банковских реквизитов: ' || SQLERRM);
              */
      END;
    
      --v_note_3
      v_note_3 := '';
      IF nvl(par_sum_return_bonus_part, 0) != 0
      THEN
        --v_note_3 := v_note_3 || 'Возврат части премии ';      --Чирков/комментарий/ 184788: FW: Назначение платежа в платежном требовании
        v_note_3 := v_note_3 || 'Возв части прем '; --Чирков/изменил/ 184788: FW: Назначение платежа в платежном требовании   
        v_str    := '';
        IF nvl(par_admin_expenses, 0) != 0
        THEN
          v_str := v_str || 'адм. издержек';
        END IF;
        IF nvl(par_medo_cost, 0) != 0
        THEN
          IF v_str IS NOT NULL
          THEN
            v_str := v_str || ', ';
          END IF;
          v_str := v_str || 'МЕДО';
        END IF;
        IF v_str IS NOT NULL
        THEN
          v_note_3 := v_note_3 || 'за вычетом ' || v_str;
        END IF;
      END IF;
      IF nvl(par_sum_redemption_sum, 0) != 0
      THEN
        IF v_note_3 IS NOT NULL
        THEN
          --v_str := 'выкупная сумма';                    --Чирков/комментарий/ 184788: FW: Назначение платежа в платежном требовании
          v_str := 'выкуп сумма'; --Чирков/изменил/ 184788: FW: Назначение платежа в платежном требовании 
        ELSE
          --v_str := 'Выкупная сумма';                   --Чирков/комментарий/ 184788: FW: Назначение платежа в платежном требовании
          v_str := 'Выкуп сумма'; --Чирков/изменил/ 184788: FW: Назначение платежа в платежном требовании 
        END IF;
      ELSE
        v_str := '';
      END IF;
      IF nvl(par_sum_add_invest_income, 0) != 0
      THEN
        IF v_str IS NOT NULL
        THEN
          v_str := v_str || ' и ';
        END IF;
        v_str := v_str || 'доп. доход ';
      END IF;
    
      IF v_str IS NOT NULL
      THEN
        IF v_note_3 IS NOT NULL
        THEN
          v_note_3 := v_note_3 || ', ';
        END IF;
        v_note_3 := v_note_3 || v_str;
      END IF;
      IF v_note_3 IS NOT NULL
      THEN
        v_note_3 := v_note_3 || ' ';
      END IF;
      IF nvl(par_debt_fee_fact, 0) != 0
      THEN
        v_note_3 := v_note_3 || 'с учетом задолж-ти ';
      END IF;
      v_note_3 := v_note_3 || 'по дог страх-я ' || par_pol_num || '. ';
    
      --v_note_1
      BEGIN
        SELECT contact_id INTO v_contact_id FROM v_pol_issuer WHERE policy_id = par_policy_id;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'Ошибка создания платежного требования' ||
                                  'Ошибка определения страхователя: ' || SQLERRM);
      END;
      IF length(v_personal_account) = 20
      THEN
        v_note_1 := 'л/сч ' || v_personal_account || ' ';
      ELSIF length(v_personal_account) = 23
      THEN
        v_note_1 := 'л/сч ' || substr(v_personal_account, 1, 20) || ' ';
      ELSE
        IF v_pc_account IS NOT NULL
        THEN
          v_note_1 := 'п/к ' || v_pc_account || ' ';
        ELSE
          v_note_1 := '';
        END IF;
      END IF;
      --v_note_2
      BEGIN
        SELECT c.obj_name_orig
          INTO v_beneficiary_name
          FROM contact c
         WHERE c.contact_id = v_contact_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_beneficiary_name := NULL;
      END;
      IF v_beneficiary_name IS NOT NULL
         AND v_note_1 IS NOT NULL
      THEN
        v_note_2 := v_beneficiary_name || '. ';
      ELSE
        v_note_2 := '';
      END IF;
      --301281: Доработка текста назначения платежа
      /*--v_note_4
      v_note_4 := 'НДФЛ ';
      IF NVL(par_sum_add_invest_income, 0) != 0
      THEN
        v_note_4 := v_note_4 || 'удержан ст.213 НК РФ';
      ELSE
        v_note_4 := v_note_4 || 'не облагается';
      END IF;*/
      IF par_is_ndfl IS NOT NULL
      THEN
        IF par_is_ndfl = 1
        THEN
          v_note_4 := v_note_4 || 'НДФЛ удержан ст.213 НК РФ';
        ELSE
          v_note_4 := v_note_4 || 'НДФЛ не облагается';
        END IF;
      END IF;
    
      BEGIN
        SELECT pp.return_summ INTO v_return_sum FROM p_policy pp WHERE pp.policy_id = par_policy_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      v_note_4 := v_note_4 || '. Сумма ' || v_return_sum; --Чирков/Добавил/ 184788: FW: Назначение платежа в платежном требовании   
      v_note_4 := v_note_4 || ', НДС не облагается. ';
      --формирование строки
      IF length(v_note_1) + length(v_note_2) + length(v_note_3) + length(v_note_4) <= 210
      THEN
        v_note := v_note_3 || v_note_1 || v_note_2 || v_note_4;
      ELSE
        v_cnt := 210 - length(v_note_3) - length(v_note_1) - length(v_note_4);
      
        IF length(v_note_2) < v_cnt
        THEN
          v_note_2 := v_note_2;
        ELSIF v_cnt > 2
        THEN
          v_note_2 := substr(v_note_2, 1, (v_cnt - 2)) || '. ';
        ELSE
          v_note_2 := '';
        END IF;
        v_note := substr(v_note_3 || v_note_1 || v_note_2 || v_note_4, 1, 210);
      END IF;
      RETURN(v_note);
    
    END build_note;
  
    FUNCTION build_comment
    (
      par_policy_id  IN NUMBER
     ,par_fund_brief IN VARCHAR2
    ) RETURN VARCHAR2 AS
      v_doc_txt               VARCHAR2(2000);
      v_sum_redemption_sum    NUMBER;
      v_sum_add_invest_income NUMBER;
      v_sum_return_bonus_part NUMBER;
      v_total_fee_payment_sum NUMBER;
      v_debt_fee_fact         NUMBER;
      v_overpayment           NUMBER;
      v_admin_expenses        NUMBER;
      v_medo_cost             NUMBER;
    BEGIN
    
      -- I?eia?aiey
      BEGIN
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
              ,SUM(cd.return_bonus_part)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
              ,v_sum_return_bonus_part
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = par_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
      
        SELECT medo_cost
              ,pd.total_fee_payment_sum
              ,pd.debt_fee_fact
              ,pd.overpayment
              ,pd.admin_expenses
          INTO v_medo_cost
              ,v_total_fee_payment_sum
              ,v_debt_fee_fact
              ,v_overpayment
              ,v_admin_expenses
          FROM p_pol_decline pd
         WHERE p_policy_id = par_policy_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          /*      PKG.Show_Message( 'Ошибка создания платежного требования',
            'Ошибка по получению данных по прекращению ДС: ' || SQLERRM, 'MESSAGE' );
          RAISE Form_Trigger_Failure;
          */
      END;
    
      IF nvl(v_total_fee_payment_sum, 0) != 0
      THEN
        v_doc_txt := 'Общая сумма уплаченных взносов ' ||
                     to_char(v_total_fee_payment_sum, 'FM999G999G999G990D00') || ' ' || par_fund_brief ||
                     chr(10);
      END IF;
      IF nvl(v_sum_redemption_sum, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Выкупная сумма ' ||
                     to_char(v_sum_redemption_sum, 'FM999G999G999G990D00') || ' ' || par_fund_brief || ' ';
      END IF;
      IF nvl(v_sum_add_invest_income, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Доп. инвест доход ' ||
                     to_char(v_sum_add_invest_income, 'FM999G999G999G990D00') || ' ' || par_fund_brief || ' ';
      END IF;
      IF nvl(v_medo_cost, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Расходы на МедО ' || to_char(v_medo_cost, 'FM999G999G999G990D00') || ' ' ||
                     par_fund_brief || chr(10);
      END IF;
      --
      IF nvl(v_debt_fee_fact, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Недоплата фактическая ' ||
                     to_char(v_debt_fee_fact, 'FM999G999G999G990D00') || ' ' || par_fund_brief || ' ';
      END IF;
      IF nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Возврат части премии ' ||
                     to_char(v_sum_return_bonus_part, 'FM999G999G999G990D00') || ' ' || par_fund_brief || ' ';
      END IF;
      IF nvl(v_overpayment, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Переплата ' || to_char(v_overpayment, 'FM999G999G999G990D00') || ' ' ||
                     par_fund_brief || ' ';
      END IF;
      IF nvl(v_admin_expenses, 0) != 0
      THEN
        v_doc_txt := v_doc_txt || 'Админ. издержки ' ||
                     to_char(v_admin_expenses, 'FM999G999G999G990D00') || ' ' || par_fund_brief || ' ';
      END IF;
    
      RETURN v_doc_txt;
    END build_comment;
  BEGIN
    --получение данных по растожению
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
  
    SELECT nvl(pd.issuer_return_sum, 0) + nvl(pd.overpayment, 0) - nvl(v_debt_fee_sum, 0) -
           nvl(pd.medo_cost, 0) - nvl(pd.admin_expenses, 0) - nvl(pd.other_pol_sum, 0)
          ,pd.admin_expenses
          ,medo_cost
          ,debt_fee_fact
      INTO v_amount
          ,v_admin_exp
          ,v_medo_cost
          ,v_debt_fee_fact
      FROM p_pol_decline pd
     WHERE pd.p_policy_id = par_policy_id;
  
    SELECT doc_templ_id INTO v_doc_templ_id FROM doc_templ WHERE brief = 'PAYREQ';
    SELECT payment_templ_id
          ,payment_type_id
          ,payment_direct_id
      INTO v_payment_templ_id
          ,v_payment_type_id
          ,v_payment_direct_id
      FROM ac_payment_templ
     WHERE brief = 'PAYREQ';
  
    SELECT nvl(MAX(to_number(num)), 0) + 1
      INTO v_num
      FROM ven_document
     WHERE doc_templ_id = v_doc_templ_id
       AND trunc(reg_date, 'yyyy') >= trunc(SYSDATE, 'yyyy');
  
    SELECT id
          ,collection_method_id
      INTO v_payment_terms_id
          ,v_collection_method_id
      FROM t_payment_terms
     WHERE brief = 'Единовременно';
  
    SELECT f.fund_id
          ,f.brief fund_brief
          ,p.pol_num
          ,p.debt_summ
      INTO v_fund_id
          ,v_fund_brief
          ,v_pol_num
          ,v_debt_fee_sum
      FROM p_pol_header ph
          ,p_policy     p
          ,fund         f
     WHERE ph.policy_header_id = p.pol_header_id
       AND p.policy_id = par_policy_id
       AND ph.fund_id = f.fund_id;
  
    BEGIN
      SELECT vi.contact_id
            ,ct.brief
        INTO v_insurer_id
            ,v_insurer_type_brief
        FROM v_pol_issuer       vi
            ,ins.contact        c
            ,ins.t_contact_type ct
       WHERE policy_id = par_policy_id
         AND c.contact_id = vi.contact_id
         AND c.contact_type_id = ct.id;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не найден страхователь: ' || SQLERRM);
      WHEN too_many_rows THEN
        ex.raise('Найдено несколько страхователей: ' || SQLERRM);
      WHEN OTHERS THEN
        ex.raise('Ошибка определения страхователя: ' || SQLERRM);
    END;
  
    v_contact_id := nvl(par_contact_id, v_insurer_id);
  
    IF par_contact_bank_acc_id IS NULL
    THEN
      -- Определение реквизитов изменено согласно заявке 184567
      BEGIN
        SELECT id
              ,owner_contact_id
          INTO v_contact_bank_acc_id
              ,v_owner_contact_id
          FROM (SELECT ccba.id
                      ,ccba.owner_contact_id
                  FROM cn_contact_bank_acc  ccba
                      ,cn_document_bank_acc dacc
                      ,document             d
                      ,doc_status_ref       dsr
                      ,doc_status           ds
                 WHERE ccba.id = dacc.cn_contact_bank_acc_id
                   AND d.document_id = dacc.cn_document_bank_acc_id
                   AND d.doc_status_id = ds.doc_status_id
                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                   AND ccba.contact_id = v_contact_id
                   AND ccba.used_flag = 1
                   AND dsr.brief = 'ACTIVE'
                 ORDER BY ds.change_date DESC)
         WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          ex.raise('Не обнаружены банковские реквизиты получателя: ' || SQLERRM);
        WHEN too_many_rows THEN
          ex.raise('Найдено несколько банковских реквизитов получателя: ' || SQLERRM);
        WHEN OTHERS THEN
          ex.raise('Ошибка определения банковских реквизитов: ' || SQLERRM);
      END;
    ELSE
      --Определяем получателя 
      BEGIN
        SELECT ccba.id
              ,ccba.owner_contact_id
          INTO v_contact_bank_acc_id
              ,v_owner_contact_id
          FROM cn_contact_bank_acc ccba
         WHERE ccba.id = par_contact_bank_acc_id;
      EXCEPTION
        WHEN no_data_found THEN
          ex.raise('Не найден контакт получателя.');
        WHEN too_many_rows THEN
          ex.raise('Найдено несколько контактов получателя.' || SQLERRM);
        WHEN OTHERS THEN
          ex.raise('Ошибка определения контакта получателя ' || SQLERRM);
      END;
    END IF;
  
    --определяем тип получателя
    BEGIN
      SELECT ct.brief
        INTO v_owner_contact_type_brief
        FROM ins.contact        c
            ,ins.t_contact_type ct
       WHERE c.contact_type_id = ct.id
         AND c.contact_id = v_owner_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не найден тип получателя.');
      WHEN OTHERS THEN
        ex.raise('Ошибка определения типа получателя ' || SQLERRM);
    END;
  
    /*  327334: FW: возрат части премии /Чирков/*/
    IF v_insurer_type_brief = 'ФЛ'
       AND v_owner_contact_type_brief != 'ФЛ'
    THEN
      v_is_ndfl := 0;
    ELSIF v_insurer_id != v_owner_contact_id
          OR nvl(v_sum_add_invest_income, 0) != 0
    THEN
      v_is_ndfl := 1;
    ELSE
      v_is_ndfl := NULL;
    END IF;
  
    v_note := build_note(par_policy_id             => par_policy_id
                        ,par_sum_return_bonus_part => v_sum_return_bonus_part
                        ,par_admin_expenses        => v_admin_exp
                        ,par_medo_cost             => v_medo_cost
                        ,par_sum_redemption_sum    => v_sum_redemption_sum
                        ,par_sum_add_invest_income => v_sum_add_invest_income
                        ,par_debt_fee_fact         => v_debt_fee_fact
                        ,par_pol_num               => v_pol_num
                        ,par_is_ndfl               => v_is_ndfl);
  
    v_doc_txt := build_comment(par_policy_id, v_fund_brief);
  
    pkg_payment.create_payment(par_payment_templ_id     => v_payment_templ_id
                              ,par_amount               => v_amount
                              ,par_fund_id              => v_fund_id
                              ,par_rev_fund_id          => v_fund_id
                              ,par_contact_id           => v_contact_id
                              ,par_rate_date            => trunc(SYSDATE)
                              ,par_reg_date             => trunc(SYSDATE)
                              ,par_due_date             => trunc(SYSDATE)
                              ,par_grace_date           => trunc(SYSDATE)
                              ,par_num                  => v_num
                              ,par_payment_number       => v_num
                              ,par_payment_terms_id     => v_payment_terms_id
                              ,par_collection_method_id => v_collection_method_id
                              ,par_contact_bank_acc_id  => v_contact_bank_acc_id
                              ,par_note                 => v_note
                              ,par_doc_txt              => v_doc_txt
                              ,par_payment_id_out       => v_payment_id);
    --
    INSERT INTO ven_doc_doc (child_id, parent_id) VALUES (v_payment_id, par_policy_id);
  
    RETURN v_payment_id;
  END create_decline_payreq;

  /*
    Байтин А.
    Проверка при загрузке аннулирования
    Устанавливает текстовое значение для причины расторжения, ведущий ноль в БИК, если он отсутсвует
  */
  -- Переместил в пакет pkg_universal_loader. Изместьев.
  /*procedure check_annulation_row
  (
    par_load_file_rows_id     number
   ,par_status            out varchar2
   ,par_comment           out varchar2
  )
  is
    v_reason_name t_decline_reason.name%type;
  begin
    -- Находим причину расторжения с типом "Расторжение"
    begin
      select dr.name
        into v_reason_name
        from t_decline_reason dr
       where dr.t_decline_reason_id = (select to_number(lf.val_5)
                                         from load_file_rows lf
                                        where lf.load_file_rows_id = par_load_file_rows_id)
         and dr.brief in ('Неоплата первого взноса'
                          ,'Отказ Страховщика'
                          ,'Отказ страхователя от НУ'
                          ,'Решение суда (аннулирование)'
                          ,'Отказ Страхователя от договора'
                          );
      -- Если нашли, все ок
      par_status := pkg_load_file_to_table.get_checked;
      par_comment := null;
    exception
      when NO_DATA_FOUND then
        -- Если не нашли, все плохо
        par_status := pkg_load_file_to_table.get_error;
        par_comment := 'Не найдена причина расторжения по ИД';
    end;
    -- Запись причины расторжения, добавление ведущего 0 в БИК
    update load_file_rows lf
       set lf.val_8 = v_reason_name
          ,lf.val_3 = case
                        when not regexp_like(lf.val_3,'^0') then '0'||lf.val_3
                        else lf.val_3
                      end
     where lf.load_file_rows_id = par_load_file_rows_id;
  
  end check_annulation_row;*/

  /*
    Байтин А.
    Групповое аннулирование договоров, процедура загрузки
  */
  -- Переместил в пакет pkg_universal_loader. Изместьев.
  /*procedure annulate_list
  (
    par_load_file_rows_id number
  )
  is
    type t_file_row is record
    (
      ids        number
     ,bic        varchar2(20)
     ,account    varchar2(20)
     ,reason_id  number
     ,policy_num varchar2(1024)
     ,insured    varchar2(50)
    );
    v_file_row           t_file_row;
    v_policy_id          number;
    v_insured_id         number;
    v_product_conds_id   number;
    v_decline_reason_id  number;
    v_commission         number;
    v_new_policy_id      number;
    v_error_message      varchar2(250);
    v_prev_status        doc_status_ref.name%type;
    v_next_status        doc_status_ref.name%type;
    v_continue           boolean := true;
    v_to_req_query       boolean := false;
    v_pay_req_id         number;
    \* Снятие "галочки" со строки *\
    procedure set_not_checked
    (
      par_load_file_rows_id number
    )
    is
    begin
      update load_file_rows lf
         set lf.is_checked = 0
       where lf.load_file_rows_id = par_load_file_rows_id;
    end set_not_checked;
  
    \* Перевод статуса в Заявление на прекращение *\
    procedure find_policy_and_decline
    (
      par_ids           number
     ,par_policy_id     out number
     ,par_error_message out varchar2
     ,par_continue      out boolean
    )
    is
    begin
      select ph.last_ver_id
        into par_policy_id
        from p_pol_header ph
       where ph.ids = par_ids;
  
      begin
        doc.set_doc_status(p_doc_id       => par_policy_id
                          ,p_status_brief => 'QUIT_DECL');
        par_continue := true;
      exception
        when others then
          par_error_message := 'Невозможен перевод последней версии в статус "Заявление на прекращение"';
          par_continue := false;
      end;
    exception
      when NO_DATA_FOUND then
        par_error_message := 'Договор не распознан по идентификатору';
        par_continue := false;
    end find_policy_and_decline;
  
    \* Поиск застрахованного и платежных реквизитов *\
    procedure find_insured_and_req
    (
      par_policy_id         number
     ,par_insured           varchar2
     ,par_account           varchar2
     ,par_bic               varchar2
     ,par_insured_id    out number
     ,par_pay_req_id    out number
     ,par_error_message out varchar2
     ,par_continue      out boolean
     ,par_to_req_query  out boolean
    )
    is
      v_bank_id                 number;
      v_owner_id                contact.contact_id%type;
      v_can_create              boolean := true;
      v_bank_name               contact.obj_name_orig%type;
      v_cn_document_bank_acc_id number;
    begin
      par_to_req_query := false;
      par_continue := true;
      -- Если ФИО застрахованного указаны, поиск по ФИО
      if par_insured is not null then
        select pi.contact_id
          into par_insured_id
          from v_pol_issuer pi
         where pi.policy_id           = par_policy_id
           and upper(pi.contact_name) = upper(par_insured);
      else
        -- Иначе, застрахованный из договора
        select pi.contact_id
          into par_insured_id
          from v_pol_issuer pi
         where pi.policy_id = par_policy_id;
      end if;
      
      -- Байтин А.
      -- Заявка №191616
      if par_account is not null and par_bic is not null then
      -- Поиск активного реквизита
        begin
          select ba.id
            into par_pay_req_id
            from cn_contact_bank_acc  ba
                ,cn_document_bank_acc da
                ,document             dc
                ,doc_status_ref       dsr
                ,cn_contact_ident     ci
                ,t_id_type            it
           where ba.contact_id              = par_insured_id
             and ba.id                      = da.cn_contact_bank_acc_id
             and da.cn_document_bank_acc_id = dc.document_id
             and dc.doc_status_ref_id       = dsr.doc_status_ref_id
             and dsr.brief                  = 'ACTIVE'
             and ba.account_nr              = par_account
             and ba.bank_id                 = ci.contact_id
             and ci.id_type                 = it.id
             and it.brief                   = 'BIK'
             and ci.id_value                = par_bic
             -- Т.к. бывает несколько
             and rownum                     = 1;
        exception
          when NO_DATA_FOUND then
            begin
              -- Если не найден, реквизит создается
              -- Поиск банка по БИК
              select co.contact_id
                    ,co.obj_name_orig
                into v_bank_id
                    ,v_bank_name
                from contact        co
               where co.contact_id in (select cr.contact_id
                                         from cn_contact_role cr
                                             ,t_contact_role  tr
                                        where cr.role_id     = tr.id
                                          and tr.description = 'Банк'
                                      )
                 and co.contact_id in (select ci.contact_id
                                         from cn_contact_ident ci
                                             ,t_id_type it
                                        where ci.id_type  = it.id
                                          and it.brief    = 'BIK'
                                          and ci.id_value = par_bic)
                 -- Т.к. банков может быть много с одинаковым БИКом
                 and rownum = 1;
  
              -- Проверка счета на правильность заполнения
              pkg_contact.check_account_nr(par_account_nr    => par_account
                                          ,par_bank_id       => v_bank_id
                                          ,par_can_continue  => v_can_create
                                          ,par_error_message => par_error_message);
  
              -- Если все проверки успешны, создание реквизита
              if par_error_message is null then
                -- Необходимо найти правильного владельца счета
                begin
                  select c.contact_id
                    into v_owner_id
                    from cn_contact_bank_acc bac,
                         cn_document_bank_acc dac,
                         contact c
                   where bac.account_nr = par_account
                     and bac.bank_id    = v_bank_id
                     and bac.id = dac.cn_contact_bank_acc_id
                     and doc.get_doc_status_name(dac.cn_document_bank_acc_id) = 'Активный'
                     and nvl(bac.is_check_owner,0) = 1
                     and bac.contact_id            = c.contact_id
                     and rownum                    = 1;
                exception
                  when NO_DATA_FOUND then
                    v_owner_id := par_insured_id;
                end;
                -- Вставка
                pkg_contact.insert_account_nr(par_contact_id               => par_insured_id
                                             ,par_account_corr             => null
                                             ,par_account_nr               => par_account
                                             ,par_bank_account_currency_id => 122 --'RUR'
                                             ,par_bank_approval_date       => null
                                             ,par_bank_approval_end_date   => null
                                             ,par_bank_approval_reference  => null
                                             ,par_bank_id                  => v_bank_id
                                             ,par_bank_name                => v_bank_name
                                             ,par_bic_code                 => par_bic
                                             ,par_branch_id                => null
                                             ,par_branch_name              => null
                                             ,par_country_id               => null
                                             ,par_iban_reference           => null
                                             ,par_is_check_owner           => case
                                                                                when par_insured_id = v_owner_id then
                                                                                  1
                                                                                else 0
                                                                              end
                                             ,par_lic_code                 => null
                                             ,par_order_number             => null
                                             ,par_owner_contact_id         => v_owner_id
                                             ,par_remarks                  => null
                                             ,par_swift_code               => null
                                             ,par_used_flag                => 1
                                             ,par_cn_contact_bank_acc_id   => par_pay_req_id
                                             ,par_cn_document_bank_acc_id  => v_cn_document_bank_acc_id);
  
                doc.set_doc_status(p_doc_id       => v_cn_document_bank_acc_id
                                  ,p_status_brief => 'ACTIVE');
              else
                par_to_req_query := true;
              end if;
          exception
            when NO_DATA_FOUND then
              par_error_message := 'Не найден контакт с ролью "Банк" и проверяемым номером БИК';
              par_to_req_query := true;
          end;
        end;
      else
        par_to_req_query := true;
      end if;
    exception
      when NO_DATA_FOUND then
        par_error_message := 'ФИО страхователя найденного договора не совпадает с ФИО страхователя загрузочного файла';
        par_continue := false;
        par_to_req_query := false;
    end find_insured_and_req;
  
    \* Поиск причины расторжения *\
    function find_decline_reason
    (
      par_decline_reason_id number
    )
    return number
    is
      v_decline_reason_id number;
    begin
      select dr.t_decline_reason_id
        into v_decline_reason_id
        from t_decline_reason dr
       where dr.t_decline_reason_id = par_decline_reason_id;
      return v_decline_reason_id;
    exception
      when NO_DATA_FOUND then
        return null;
    end find_decline_reason;
  
    \* Поиск полисных условий *\
    function find_product_conds
    (
      par_policy_id number
    )
    return number
    is
      v_product_conds_id number;
    begin
      select pp.t_product_conds_id
        into v_product_conds_id
        from p_policy pp
       where pp.policy_id = par_policy_id;
  
      return v_product_conds_id;
    exception
      when NO_DATA_FOUND then
        return v_product_conds_id;
    end find_product_conds;
  
    \* Создание новой версии и доведение ее до статуса "К прекращению. Проверен"
       Затем создание платежного требования
    *\
    procedure create_policy_cancel
    (
      par_policy_id             number
     ,par_decline_reason_id     number
     ,par_commission            number
     ,par_product_conds_id      number
     ,par_payreq_contact_id     number
     ,par_payreq_id             number
     ,par_to_req_query          boolean
     ,par_new_policy_id     out number
     ,par_error_message     out varchar2
     ,par_continue          out boolean
    )
    is
      v_region_id  p_policy.region_id%type;
      v_result     number(1);
      v_payment_id number;
    begin
      begin
        par_new_policy_id := pkg_policy.new_policy_version(par_policy_id, null, 'TO_QUIT', null, sysdate);
      exception
        when others then
          null;
      end;
  
      if par_new_policy_id is not null then
        select pp.region_id
          into v_region_id
          from p_policy pp
         where pp.policy_id = par_policy_id;
  
        v_result := pkg_decline.policy_cancel(par_new_policy_id
                                             ,par_decline_reason_id
                                             ,pkg_decline.check_hkf(par_policy_id)
                                             ,pkg_decline.check_medo(par_policy_id)
                                             ,par_commission
                                             ,\*p_cover_admin*\0-- Чтобы ничего не делалось
                                             ,v_region_id
                                             ,par_product_conds_id);
  
        begin
          pkg_decline.policy_to_state_check_ready(par_policy_id => par_new_policy_id);
          begin
            doc.set_doc_status(par_new_policy_id,'TO_QUIT_CHECKED');
            update p_pol_decline pd
               set pd.issuer_return_date = null
             where pd.p_policy_id = par_new_policy_id;
            if par_to_req_query then
              doc.set_doc_status(par_new_policy_id,'QUIT_REQ_QUERY');
            else
              v_payment_id := pkg_decline.create_payreq(par_new_policy_id, par_payreq_contact_id, par_payreq_id);
            end if;
            par_continue := true;
          exception
            when others then
              par_continue := false;
              par_error_message := 'Невозможен перевод версии из статуса "К прекращению. Готов для проверки" в статус "К прекращению. Проверен".';
          end;
        exception
          when others then
            par_continue := false;
            par_error_message := 'Невозможен перевод версии из статуса "К прекращению" в статус "К прекращению. Готов для проверки".';
        end;
      else
        par_continue := false;
        par_error_message := 'Не удалось создать версию "К прекращению"';
      end if;
    end;
  
  begin
    savepoint before_annulate;
    begin
      select to_number(lf.val_2)
            ,lf.val_3
            ,lf.val_4
            ,to_number(lf.val_5)
            ,lf.val_6
            ,lf.val_7
        into v_file_row
        from load_file_rows lf
       where lf.load_file_rows_id = par_load_file_rows_id
         and lf.row_status        = pkg_load_file_to_table.get_checked;
    exception
      when NO_DATA_FOUND then
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => 'Строка не может быть загружена, т.к. не прошла проверку');
       v_continue := false;
    end;
    if v_continue then
      \* По значению атрибута «IDS» таблицы «GROUP_QUIT_FILE_ROW2» ищется ДС с равным значением атрибута «Идентификатор» *\
      find_policy_and_decline(par_ids           => v_file_row.ids
                             ,par_policy_id     => v_policy_id
                             ,par_error_message => v_error_message
                             ,par_continue      => v_continue
                             );
      if v_continue then
        \* Если нашли, поиск застрахованного/реквизитов, если реквизитов нет, создаем *\
        find_insured_and_req(par_policy_id     => v_policy_id
                            ,par_insured       => v_file_row.insured
                            ,par_account       => v_file_row.account
                            ,par_bic           => v_file_row.bic
                            ,par_insured_id    => v_insured_id
                            ,par_pay_req_id    => v_pay_req_id
                            ,par_error_message => v_error_message
                            ,par_continue      => v_continue
                            ,par_to_req_query  => v_to_req_query
                            );
        if v_continue then
          v_decline_reason_id := find_decline_reason(par_decline_reason_id => v_file_row.reason_id);
          if v_decline_reason_id is not null then
            v_product_conds_id := find_product_conds(par_policy_id => v_policy_id);
            if v_product_conds_id is not null then
              v_commission := pkg_decline.check_comiss(v_policy_id);
              if v_commission != 0 then
                create_policy_cancel(par_policy_id         => v_policy_id
                                    ,par_decline_reason_id => v_decline_reason_id
                                    ,par_commission        => v_commission
                                    ,par_product_conds_id  => v_product_conds_id
                                    ,par_payreq_contact_id => v_insured_id
                                    ,par_payreq_id         => v_pay_req_id
                                    ,par_to_req_query      => v_to_req_query
                                    ,par_new_policy_id     => v_new_policy_id
                                    ,par_error_message     => v_error_message
                                    ,par_continue          => v_continue
                                    );
                if v_continue then
                  update load_file_rows lf
                     set lf.ure_id = 283
                        ,lf.uro_id = v_new_policy_id
                        ,lf.is_checked = 1
                   where lf.load_file_rows_id = par_load_file_rows_id;
                  pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                       ,par_row_status        => pkg_load_file_to_table.get_loaded
                                                       ,par_row_comment       => v_error_message);
                else
                  rollback to before_annulate;
                  set_not_checked(par_load_file_rows_id);
                  pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                       ,par_row_status        => pkg_load_file_to_table.get_error
                                                       ,par_row_comment       => v_error_message);
                end if;
              else
                rollback to before_annulate;
                set_not_checked(par_load_file_rows_id);
                pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                     ,par_row_status        => pkg_load_file_to_table.get_error
                                                     ,par_row_comment       => 'Сумма комиссии равна 0');
              end if;
            else
              rollback to before_annulate;
              set_not_checked(par_load_file_rows_id);
              pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                   ,par_row_status        => pkg_load_file_to_table.get_error
                                                   ,par_row_comment       => 'Полисные условия не указаны в последней версии договора');
            end if;
          else
            rollback to before_annulate;
            set_not_checked(par_load_file_rows_id);
            pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                 ,par_row_status        => pkg_load_file_to_table.get_error
                                                 ,par_row_comment       => 'Указанной причины расторжения не существует');
          end if;
        else
          rollback to before_annulate;
          set_not_checked(par_load_file_rows_id);
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_row_comment       => v_error_message);
        end if;
      else
        rollback to before_annulate;
        set_not_checked(par_load_file_rows_id);
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_message);
      end if;
    end if;
  end annulate_list;*/

  /* sergey.ilyushkin 20/07/2012
  Процедура обработки - Поиск договоров для группового аннулирования */
  PROCEDURE find_annulate_list(par_load_file_rows_id NUMBER) IS
    v_policy_ent_id   NUMBER := NULL;
    v_policy_id       NUMBER := NULL;
    v_pol_num         VARCHAR2(50) := NULL;
    v_pol_issuer_name VARCHAR2(300) := NULL;
  BEGIN
    BEGIN
      SELECT ent_id INTO v_policy_ent_id FROM entity WHERE upper(SOURCE) = 'P_POLICY';
    EXCEPTION
      WHEN OTHERS THEN
        v_policy_ent_id := NULL;
    END;
  
    BEGIN
      SELECT pph.last_ver_id
            ,pph.num
            ,pi.contact_name
        INTO v_policy_id
            ,v_pol_num
            ,v_pol_issuer_name
        FROM ven_p_pol_header pph
            ,v_pol_issuer     pi
            ,load_file_rows   lfr
       WHERE pph.ids = lfr.val_1
         AND pi.policy_id = pph.last_ver_id
         AND lfr.load_file_rows_id = par_load_file_rows_id;
    
      UPDATE load_file_rows
         SET val_2      = v_pol_num
            ,val_3      = v_pol_issuer_name
            ,ure_id     = v_policy_ent_id
            ,uro_id     = v_policy_id
            ,is_checked = 1
       WHERE load_file_rows_id = par_load_file_rows_id;
    
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_row_comment       => 'Договор найден по ИДС');
    EXCEPTION
      WHEN no_data_found THEN
        v_policy_id       := NULL;
        v_pol_num         := NULL;
        v_pol_issuer_name := NULL;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => 'Договор не найден по ИДС');
    END;
  END find_annulate_list;

  /* Процедура округляет значения суммы по программам в версии прекращения договора
  * @autor Чирков В.Ю.
  * @param par_document_id - версия рассторжения
  */
  PROCEDURE round_cover_decline_sums(par_document_id NUMBER) IS
  BEGIN
    /* Округляем суммы  данных по программам прекращенияд договора, с перекидыванием копейки на 1-ую запись */
    FOR vr_cover_decline IN (SELECT --Возврат части премии
                              CASE
                                WHEN rn = 1 THEN
                                 ROUND(x.return_bonus_part, 2) + SUM(x.return_bonus_part)
                                 over(PARTITION BY x.p_pol_decline_id) -
                                 SUM(ROUND(x.return_bonus_part, 2))
                                 over(PARTITION BY x.p_pol_decline_id)
                                ELSE
                                 ROUND(x.return_bonus_part, 2)
                              END return_bonus_part_rnd
                              
                              --Начисленная премия к списанию этого года
                             ,CASE
                                WHEN rn = 1 THEN
                                 ROUND(x.bonus_off_current, 2) + SUM(x.bonus_off_current)
                                 over(PARTITION BY x.p_pol_decline_id) -
                                 SUM(ROUND(x.bonus_off_current, 2))
                                 over(PARTITION BY x.p_pol_decline_id)
                                ELSE
                                 ROUND(x.bonus_off_current, 2)
                              END bonus_off_current_rnd
                              
                              --Начисленная премия к списанию прошлых лет
                             ,CASE
                                WHEN rn = 1 THEN
                                 ROUND(x.bonus_off_prev, 2) + SUM(x.bonus_off_prev)
                                 over(PARTITION BY x.p_pol_decline_id) - SUM(ROUND(x.bonus_off_prev, 2))
                                 over(PARTITION BY x.p_pol_decline_id)
                                ELSE
                                 ROUND(x.bonus_off_prev, 2)
                              END bonus_off_prev_rnd
                              
                             ,x.p_cover_decline_id
                               FROM (SELECT rownum rn
                                           ,cd.return_bonus_part
                                           ,cd.bonus_off_current
                                           ,cd.bonus_off_prev
                                           ,cd.p_cover_decline_id
                                           ,pd.p_pol_decline_id
                                       FROM p_pol_decline   pd
                                           ,p_cover_decline cd
                                      WHERE pd.p_policy_id = par_document_id
                                        AND cd.p_pol_decline_id = pd.p_pol_decline_id) x
                             
                             )
    LOOP
      --обновляем значения на округленные
      UPDATE p_cover_decline cd
         SET cd.return_bonus_part = vr_cover_decline.return_bonus_part_rnd
            ,cd.bonus_off_current = vr_cover_decline.bonus_off_current_rnd
            ,cd.bonus_off_prev    = vr_cover_decline.bonus_off_prev_rnd
       WHERE cd.p_cover_decline_id = vr_cover_decline.p_cover_decline_id;
    END LOOP;
  END round_cover_decline_sums;

  /*
    Процедура на переходе версии ДС из статуса <Документ добавлен> в Статус <К прекращению>
    Аннулируются все виды документов - А7, ПД4, ППвх. Отвязанным платежам присваивается статус ручной обработки - расторжение, статус ЭР - условно-распознан.
  
    @author Пиядин А. 06.12.2013, 218940 Отвязка платежей после даты расторжения
    @param par_policy_id - ИД версии ДС
  */
  PROCEDURE policy_cancel_set_off_annulate(par_policy_id IN NUMBER) IS
    v_decline_date DATE;
    v_count NUMBER;
  
  BEGIN
  
   --Заявка 412697
    SELECT COUNT(*)
      INTO v_count
      FROM fv_pol_decline   fpd
          ,t_decline_reason tdr
     WHERE fpd.policy_id = par_policy_id
       AND tdr.t_decline_reason_id = fpd.decline_reason_id
       AND tdr.t_decline_type_id = (SELECT tdt.t_decline_type_id
                                      FROM t_decline_type tdt
                                     WHERE tdt.brief = 'Аннулирование');
    --                                 
    IF v_count = 0
    THEN
    BEGIN
      SELECT p.decline_date
        INTO v_decline_date
        FROM p_policy p
       WHERE 1 = 1
         AND p.policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_decline_date := NULL;
    END;
  
    IF v_decline_date IS NOT NULL
    THEN
      pkg_a7.annulated_payment(par_policy_id, v_decline_date);
      COMMIT;
    END IF;
    
    END IF;
  END policy_cancel_set_off_annulate;

END pkg_decline; 
/
