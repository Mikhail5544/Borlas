CREATE OR REPLACE PACKAGE pkg_policy_quit IS
  ----========================================================================----
  -- Прекращение ДС
  ----========================================================================----
  -- Добавление новой записи в таблицу данных для расторжения
  PROCEDURE add_pol_decline(par_policy_id NUMBER);
  ----========================================================================----
  -- Добавление строк в таблицу "Прекращение договора. Данные по программам"
  PROCEDURE add_cover_decline(par_policy_id NUMBER);
  ----========================================================================----
  -- Заполнение строки таблицы в форме "Прекращение договора страхования"
  PROCEDURE fill_cover_decline_line
  (
    par_policy_id        NUMBER
   ,par_cover_decline_id NUMBER
   ,par_as_asset_id      NUMBER
   ,par_product_line_id  NUMBER
   ,par_decline_date     DATE
    -- Байтин А.
   ,par_product_conds VARCHAR2 DEFAULT NULL
  );
  ----========================================================================----
  -- Расчет расходов на МедО
  FUNCTION calc_medo_cost(par_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- *** Проверки при переводе статусов ***
  ----========================================================================----
  -- Проверка: в форме прекращения договора заполнены обязательные поля
  PROCEDURE not_null_control(par_policy_id NUMBER);
  ----========================================================================----
  -- Проверка: в форме прекращения договора "Итого к выплате" больше нуля
  PROCEDURE return_sum_greater_then_0(par_policy_id NUMBER);
  ----========================================================================----
  -- Проверка: заданы банковские реквизиты для страхователя
  PROCEDURE issuer_bank_acc_control(par_policy_id NUMBER);
  ----========================================================================----
  -- Проверка: Если в форме прекращения ДС заданы суммы по Доп. инвест доходу,
  -- должно быть заполнено поле "Сумма НДФЛ"
  PROCEDURE income_tax_sum_control(par_policy_id NUMBER);
  ----========================================================================----
  -- Проверка: Если в форме прекращения ДС "Итого к выплате" больше нуля,
  -- должна быть задана "Дата выплаты страхователю"
  PROCEDURE issuer_return_date_control(par_policy_id NUMBER);
  ----========================================================================----
  -- Общую проверку № 1 удалили
  ----========================================================================----
  -- Общая проверка № 2:
  -- "Сумма зачета на другой договор" <=
  -- ( "Итого к выплате" - Окр.до целых( 0,13 * "ДИД" ) )
  PROCEDURE return_sum_add_invest_income(par_policy_id NUMBER);
  ----========================================================================----
  -- Общая проверка № 3:
  -- Проверка соответствия причины расторжения и ненулевых полей.
  -- Если причина расторжения "Неоплата первого взноса" или "Отказ Страховщика"
  -- или "Отказ страхователя от НУ", то могут быть больше нуля только поля:
  -- "Возврат части премии", "Начисленная премия к списанию прошлых лет",
  -- "Начисленная премия к списанию этого года", "Расходы на МедО",
  -- "Недоплата по полису составляет", "Сумма зачета на другой договор",
  -- "В связи с досрочным прекращением Договора сумма к возврату Страхователю",
  -- "Итого к выплате"
  PROCEDURE reason_greater_then_0(par_policy_id NUMBER);
  ----========================================================================----
  -- Проверка: Если в форме прекращения ДС "НДФЛ" больше нуля,
  -- должна быть задана "Дата начисления НДФЛ"
  PROCEDURE income_tax_sum_date_control(par_policy_id NUMBER);
  ----========================================================================----
  -- ФИО текущего пользователя для отчетов о расторжении
  FUNCTION get_current_user_fio RETURN VARCHAR2;
  ----========================================================================----
  -- 1) Округление ВС, ДИД, возврат
  FUNCTION get_round_1(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- 2) Округление зачета в счет недоплаты
  FUNCTION get_round_2(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- 3) Округление зачета на новый договор:
  -- Полученная сумма прибавляется к максимальной сумме проводки по шаблонам:
  -- Зачет ВС (Зачет на другой  ДС), Зачтена выплата ДИД (Зачет на другой  ДС),
  -- Зачтена выплата возв (Зачет на другой  ДС).
  -- Алгоритм расчета: Округление зачета в счет другого договора =
  -- (значение поля "Сумма зачета на другой договор") -
  -- ? Шаблон "Зачет ВС (Зачет на другой  ДС)" -
  -- ? Шаблон "Зачтена выплата ДИД (Зачет на другой  ДС)" -
  -- ? Шаблон "Зачтена выплата возв (Зачет на другой  ДС)"
  PROCEDURE get_round_3
  (
    par_p_policy_id  IN NUMBER
   ,par_round_err    OUT NUMBER
   , -- ошибка округления
    par_template_num OUT NUMBER -- номер шаблона проводки, в сумме которой
    -- учтена ошибка округления
  );
  ----========================================================================----
  -- 4) Округления Переплата по договору
  FUNCTION get_round_4(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- Генерация корректирующих проводок
  PROCEDURE gen_fix_trans(par_p_trans_decline_id NUMBER);
  ----========================================================================----
  -- Удаление корректирующих проводок
  PROCEDURE del_fix_trans(par_p_trans_decline_id NUMBER);
  ----========================================================================----
  -- Причина расторжения ДС - в группе "Аннулирование"
  -- 1 - в группе, 0 - нет
  FUNCTION decline_reason_is_annul(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- Проверка: если причина расторжения ДС из группы "Аннулирование", то
  -- должны быть равны нулю:
  -- Выкупная сумма
  -- Доп. инвест доход
  -- Админ. расходы
  -- Недоплата удерживаема
  -- Недоплата фактическая
  -- Переплата
  -- (Чтобы не сформировались лишние проводки)
  PROCEDURE check_annul(par_p_policy NUMBER);
  ----========================================================================----
  -- Генерация первой группы основных проводок по прекращению ДС - по дате акта
  PROCEDURE gen_main_trans_group_1(par_p_policy_id NUMBER);
  ----========================================================================----
  -- Генерация второй группы основных проводок по прекращению ДС - остальные
  PROCEDURE gen_main_trans_group_2(par_p_policy_id NUMBER);
  ----========================================================================----
  -- Генерация проводок по зачету на другой договор
  PROCEDURE gen_trans_setoff(par_doc_id NUMBER);
  ----========================================================================----
  -- Удалить неоплаченные счета
  PROCEDURE delete_unpayed_acc(par_p_policy_id NUMBER);
  ----========================================================================----
  -- Проверка: в форме корректировки проводок не должено быть строк со статусом
  -- "Проект"
  PROCEDURE check_fix_trans_status(par_policy_id NUMBER);
  ----========================================================================----
  -- Удаление / сторнирование первой группы основных проводок по прекращению ДС -
  -- ( по дате акта )
  PROCEDURE del_main_trans_group_1(par_p_policy_id NUMBER);
  ----========================================================================----
  -- Удаление / сторнирование второй группы основных проводок по прекращению ДС -
  -- ( остальные )
  PROCEDURE del_main_trans_group_2(par_p_policy_id NUMBER);
  ----========================================================================----
  -- Функция возвращает программу ( риск ) для проводки
  FUNCTION get_trans_plo_desc(p_trans_id NUMBER) RETURN VARCHAR2;
  ----========================================================================----
  /*
    Байтин А.
    Проверка суммы сальдо по счетам: '22.05','22.01','22.05.01','22.05.02','22.05.11','22.05.31','22.05.33',
                                     '77.00.01','77.00.02','77.08.03','91.01','91.02','92.01'
    Если сальдо отличается от 0, выдается сообщение об этом, с указанием суммы

    par_policy_id - ИД версии ДС
  */
  --PROCEDURE check_saldo(par_policy_id NUMBER);

  /**
  * Прекращение ДС. Корректировка сальдо по договору
  * К прекращению. Готов для проверки - К прекращению. Проверен
  * Процедура определяет оставшееся сальдо по договору и создает проводки, чтобу избавиться от него
  * К сожалению таким образом мы никогда не знаем, был ли корректно расчитан договор т.к. всегда тупо
  * сводим сальдо в ноль
  * @author Капля П.
  * @param par_policy_id - ИД версии прекращения
  */
  PROCEDURE correct_saldo_on_quit(par_policy_id NUMBER);
  /*
    Байтин А.
    Проверка существования проводок по счетам 22.01, 22.05.01, 22.05.02 и выдача сообщения об ошибке,
    если такие проводки существуют.
    par_policy_id - ИД версии договора страхования
  */
  PROCEDURE check_accounts(par_policy_id NUMBER);
  /*
    Байтин А.
    Отмена закрытых корректируюих проводок, не связанных с проводками
    par_policy_id - ИД версии договора страхования
  */
  PROCEDURE cancel_corr_trans(par_policy_id NUMBER);
  /*
    Байтин А.
    Добавление корректирующей проводки

    par_pol_decline_id   - ИД данных по расторжению версии ДС
    par_p_cover_id       - ИД покрытия
    par_oper_templ_brief - Сокращение шаблона проводки
    par_doc_templ_brief  - Сокращение шаблона документа
    par_trans_sum        - Сумма проводки
    par_trans_date       - Дата проводки
    par_status_date      - Дата перевода статуса
    par_trans_id         - ИД созданной проводки (выходной)
  */
  PROCEDURE insert_corr_trans
  (
    par_pol_decline_id   NUMBER
   ,par_p_cover_id       NUMBER
   ,par_oper_templ_brief VARCHAR2
   ,par_doc_templ_brief  VARCHAR2
   ,par_trans_sum        NUMBER
   ,par_trans_date       DATE
   ,par_status_date      DATE DEFAULT SYSDATE
   ,par_trans_id         OUT NUMBER
  );

  /*
    Байтин А.
    Проверка наличия платежного требования при переводе ДС в статус "Прекращен. К выплате"
    par_p_policy_id - ID версии ДС
  */
  PROCEDURE check_payment_request(par_p_policy_id NUMBER);
  /**
   * Создание платежного требованния, если его нет (на переходе статусов "Прекращен. Первизиты получены"-"Прекращен. К выплате"
   * @author  Черных М. 30.1.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE create_payment_request(par_p_policy_id NUMBER);
  /*
    Байтин А.
    Формирование исходящего ПП при переводе документа в статус "Прекращен.К выплате"
    par_p_policy_id - ID версии ДС
  */
  PROCEDURE make_outgoing_bank_doc(par_p_policy_id NUMBER);

  /*
    Байтин А.
    Удаление ПП при переводе документа из статуса "Прекращен.К выплате" в статус "Прекращен. Реквизиты получены"
    par_p_policy_id - ID версии ДС
  */
  PROCEDURE delete_outgoing_bank_doc(par_p_policy_id NUMBER);

  /*
    Байтин А.

    Автоматическое создание корректирующих проводок при переводе документа
    из статуса "К прекращению. Готов для проверки" в статус "К прекращению. Проверен"

    par_policy_id - ИД версии договора
  */
  PROCEDURE make_correct_trans_auto(par_policy_id NUMBER);

  /**
   * Проверка наличия решения по делу
   * @author  Черных М. 28.1.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_claim(par_policy_id p_policy.policy_id%TYPE);

  /**
   * Проверка: наличие в истории перехода статусов есть переход «Прекращен. К выплате» - «Прекращен»
   * @author  Черных М. 28.1.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_was_quit_to_pay_status(par_policy_id p_policy.policy_id%TYPE);

  /**
   * Проверка: «Переплата» и значение поля «Недоплата фактическая» оба больше 0, то ошибка
   * @author  Черных М. 6.3.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_overpayment_and_debt(par_policy_id p_policy.policy_id%TYPE);

END pkg_policy_quit;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_quit IS
  ----========================================================================----
  -- Прекращение ДС
  ----========================================================================----
  -- Исключение, если не пройдена проверка для ДС с причиной расторжения из группы
  -- "Аннулирование"
  e_annul_check_failure EXCEPTION;
  ----========================================================================----
  -- Добавление новой записи в таблицу данных для расторжения
  -- Параметр: ИД объекта сущности Версия договора страхования
  PROCEDURE add_pol_decline(par_policy_id NUMBER) IS
  BEGIN
    INSERT INTO ven_p_pol_decline (p_policy_id) VALUES (par_policy_id);
    -- Установка текущей версии ДС
    UPDATE p_pol_header
       SET policy_id = par_policy_id
     WHERE policy_header_id = (SELECT pol_header_id FROM p_policy WHERE policy_id = par_policy_id);
  END add_pol_decline;
  ----========================================================================----
  -- Добавление строк в таблицу "Прекращение договора. Данные по программам"
  -- Параметр: ИД объекта сущности Версия договора страхования
  PROCEDURE add_cover_decline(par_policy_id NUMBER) IS
    v_prev_policy_id NUMBER;
    v_pol_decline_id NUMBER;
    CURSOR cover_curs(pcurs_policy_id NUMBER) IS
      SELECT fn_obj_name(a.ent_id, a.as_asset_id) asset_name
            ,pl.description cover_name
            ,a.as_asset_id
            ,pl.id t_product_line_id
            ,trunc(MONTHS_BETWEEN(trunc(c.end_date) + 1, trunc(c.start_date)) / 12, 2) cover_period
        FROM as_asset           a
            ,p_cover            c
            ,t_prod_line_option plo
            ,t_product_line     pl
       WHERE a.p_policy_id = pcurs_policy_id
         AND c.as_asset_id = a.as_asset_id
         AND c.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id
       ORDER BY a.as_asset_id
               ,pl.sort_order;
  BEGIN
    -- Найти предпоследнюю версию договора (последняя версия - со статусом
    -- "К прекращению")
    SELECT pp.prev_ver_id INTO v_prev_policy_id FROM p_policy pp WHERE policy_id = par_policy_id;

    -- Найти строку данных по расторжению версии ДС
    SELECT p_pol_decline_id
      INTO v_pol_decline_id
      FROM p_pol_decline
     WHERE p_policy_id = par_policy_id;
    -- Добавить строки в таблицу "Прекращение договора. Данные по программам"
    FOR curs_rec IN cover_curs(v_prev_policy_id)
    LOOP
      INSERT INTO ven_p_cover_decline
        (p_pol_decline_id, as_asset_id, t_product_line_id, cover_period)
      VALUES
        (v_pol_decline_id, curs_rec.as_asset_id, curs_rec.t_product_line_id, curs_rec.cover_period);
    END LOOP;
  END add_cover_decline;
  ----========================================================================----
  -- Заполнение строки таблицы в форме "Прекращение договора страхования"
  PROCEDURE fill_cover_decline_line
  (
    par_policy_id        NUMBER
   ,par_cover_decline_id NUMBER
   ,par_as_asset_id      NUMBER
   ,par_product_line_id  NUMBER
   ,par_decline_date     DATE
    -- Байтин А.
   ,par_product_conds VARCHAR2 DEFAULT NULL
  ) IS
    v_version_num    p_policy.version_num%TYPE;
    v_pol_header_id  NUMBER;
    v_prev_policy_id NUMBER;
    --
    v_redemption_sum      NUMBER;
    v_add_invest_income   NUMBER;
    v_return_bonus_part   NUMBER;
    v_bonus_off_prev      NUMBER;
    v_bonus_off_current   NUMBER;
    v_admin_expenses      NUMBER;
    v_underpayment_actual NUMBER;
    --
    v_line_desc t_product_line.description%TYPE;
    v_type_desc t_product_line_type.presentation_desc%TYPE;

    FUNCTION is_annulate(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_decline_type_brief t_decline_type.brief%TYPE;
    BEGIN
      SELECT dt.brief
        INTO v_decline_type_brief
        FROM p_policy         pp
            ,t_decline_reason dr
            ,t_decline_type   dt
       WHERE pp.policy_id = par_policy_id
         AND pp.decline_reason_id = dr.t_decline_reason_id
         AND dr.t_decline_type_id = dt.t_decline_type_id;

      RETURN v_decline_type_brief = 'Аннулирование';
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END is_annulate;
  BEGIN
    -- Найти предпоследнюю версию договора (последняя версия - со статусом
    -- "К прекращению")
    BEGIN
      SELECT version_num
            ,pol_header_id
            ,pp.prev_ver_id
        INTO v_version_num
            ,v_pol_header_id
            ,v_prev_policy_id
        FROM p_policy pp
       WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_prev_policy_id := NULL;
    END;
    -- *** Выкупная сумма
    IF v_prev_policy_id IS NOT NULL
    THEN
      BEGIN
        SELECT l.description       line_desc
              ,t.presentation_desc type_desc
          INTO v_line_desc
              ,v_type_desc
          FROM t_product_line      l
              ,t_product_line_type t
         WHERE l.product_line_type_id = t.product_line_type_id
           AND l.id = par_product_line_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_line_desc := NULL;
          v_type_desc := NULL;
      END;
    END IF;
    -- Если основная программа или программа ИНВЕСТ ...
    -- Выкупная рассчитывается только при расторжении
    IF (nvl(v_type_desc, '~') = 'ОСН' OR nvl(v_line_desc, '~') = 'ИНВЕСТ' OR
       nvl(v_line_desc, '~') = 'ИНВЕСТ2' OR nvl(v_line_desc, '~') = 'Сбалансированная' OR
       nvl(v_line_desc, '~') = 'Агрессивная' OR nvl(v_line_desc, '~') = 'Агрессивная плюс')
       AND v_prev_policy_id IS NOT NULL
       AND NOT is_annulate(par_policy_id => par_policy_id)
    THEN
      -- По предпоследней версии договора

      /**
       * Байтин А.
       * Если договор оформлен на ПУ «Общие условия страхования от 23.06.2006»,
       * «Общие условия страхования по прорамме "Гармония жизни" от 21.03.2005»,
       * «Правила страхования жизни от 30.06.2007»,
       * то Выкупная Сумма рассчитывается на дату согласно периоду (см.Таблицу Выкупных сумм),
       * на который приходится дата расторжения.
      */
      IF par_product_conds IN
         ('Общие условия страхования от 23.06.2006'
         ,'Правила страхования жизни от 30.06.2007'
         ,'Общие условия страхования по прорамме "Гармония жизни" от 21.03.2005'
         ,'ПУ "Семейный депозит" от 07.02.2008'
         ,'Полисные условия к программе страхования "Семейный Депозит от 02.06.2011"')
      THEN
        BEGIN
          SELECT csd.value
            INTO v_redemption_sum
            FROM -- Выкупные суммы
                 policy_cash_surr   cs
                ,policy_cash_surr_d csd
                ,t_product_line     pl
                 -- Прекращение
                ,p_pol_decline   pd
                ,p_cover_decline cd
                ,as_asset        et
           WHERE cs.policy_id = v_prev_policy_id
             AND cs.t_lob_line_id = pl.t_lob_line_id

             AND pd.p_pol_decline_id = cd.p_pol_decline_id
             AND cd.p_cover_decline_id = par_cover_decline_id
             AND cd.as_asset_id = et.as_asset_id
             AND cd.t_product_line_id = pl.id
             AND et.contact_id = cs.contact_id

             AND csd.policy_cash_surr_id = cs.policy_cash_surr_id
             AND par_decline_date BETWEEN csd.start_cash_surr_date AND csd.end_cash_surr_date

             AND rownum = 1; -- в выкупных суммах могут быть дубли, поэтому выбирается первая попавшаяся запись
          -- согласовано с Горбянской Еленой
        EXCEPTION
          WHEN no_data_found THEN
            v_redemption_sum := 0;
        END;
        /**
         * Байтин А.
         * Если договор оформлен на ПУ «Полисные условия к договору страхования жизни по программам страхования жизни
         * "Гармония жизни", "Семья", "Дети", "Будущее" от 01.04.2009»
         * и «Полисные условия к договору страхования жизни по программам страхования жизни
         * "Гармония жизни", "Семья", "Дети", "Будущее" от 09.11.2009»,
         * то Выкупная Сумма рассчитывается на дату согласно периоду,
         * на который приходится дата последнего оплаченного взноса или дате расторжения договора страхования,
         * в зависимости от того, какая из дат является более ранней.
        */
      ELSIF par_product_conds IN
            ('Полисные условия к договору страхования жизни по программам страхования жизни "Гармония жизни", "Семья", "Дети", "Будущее" от 01.04.2009'
            ,'Полисные условия к договору страхования жизни по программам страхования жизни "Гармония жизни", "Семья", "Дети", "Будущее" от 09.11.2009'
            ,'Полисные условия страхования жизни по программе «Инвестор» от 23.12.2013г.'
            ,'Полисные условия страхования жизни по программе "ИНВЕСТОР" от 17.03.2011'
            ,'Полисные условия страхования жизни по программе "ИНВЕСТОР" от 20.12.2011'
            ,'ПОЛИСНЫЕ УСЛОВИЯ СТРАХОВАНИЯ ЖИЗНИ ПО ПРОГРАММЕ «ИНВЕСТОР ПЛЮС»')
      THEN
        BEGIN
          SELECT csd.value
            INTO v_redemption_sum
            FROM -- Выкупные суммы
                 policy_cash_surr   cs
                ,policy_cash_surr_d csd
                ,t_product_line     pl
                 -- Прекращение
                ,p_pol_decline   pd
                ,p_cover_decline cd
                ,as_asset        et
           WHERE cs.policy_id = v_prev_policy_id
             AND cs.t_lob_line_id = pl.t_lob_line_id

             AND pd.p_pol_decline_id = cd.p_pol_decline_id
             AND cd.p_cover_decline_id = par_cover_decline_id
             AND cd.as_asset_id = et.as_asset_id
             AND cd.t_product_line_id = pl.id
             AND et.contact_id = cs.contact_id

             AND csd.policy_cash_surr_id = cs.policy_cash_surr_id
             AND (SELECT least(nvl(MAX(ac.due_date), par_decline_date), par_decline_date)
                    FROM p_policy         pp
                        ,doc_doc          dd
                        ,ac_payment       ac
                        ,ac_payment_templ pt
                   WHERE pp.pol_header_id = v_pol_header_id
                     AND dd.parent_id = pp.policy_id
                     AND dd.child_id = ac.payment_id
                     AND ac.payment_templ_id = pt.payment_templ_id
                     AND pt.brief = 'PAYMENT'
                     AND doc.get_doc_status_brief(ac.payment_id) = 'PAID') BETWEEN
                 csd.start_cash_surr_date AND csd.end_cash_surr_date
             AND rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            v_redemption_sum := 0;
        END;
      ELSE
        -- Байтин А.
        -- Если условия не выполняются, делаем старый запрос
        BEGIN
          SELECT csd.value
            INTO v_redemption_sum
            FROM ven_policy_cash_surr   cs
                ,ven_as_asset           aa
                ,ven_t_lob_line         ll
                ,t_product_ver_lob      pvl
                ,t_product_line         pl
                ,ven_policy_cash_surr_d csd
                ,
                 --
                 p_cover            pc
                ,t_prod_line_option opt
                ,t_product_line     pll
                ,ven_t_lob_line     bll
          --
           WHERE cs.policy_id = v_prev_policy_id
             AND cs.contact_id = aa.contact_id
             AND aa.as_asset_id = par_as_asset_id
             AND cs.t_lob_line_id = ll.t_lob_line_id
             AND ll.t_lob_id = pvl.lob_id
             AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
             AND pl.id = par_product_line_id
                --
             AND aa.as_asset_id = pc.as_asset_id
             AND pc.t_prod_line_option_id = opt.id
             AND opt.product_line_id = pll.id
             AND pll.t_lob_line_id = bll.t_lob_line_id
             AND bll.t_lob_line_id = ll.t_lob_line_id
             AND pl.id = pll.id
                --
             AND cs.policy_cash_surr_id = csd.policy_cash_surr_id
             AND csd.end_cash_surr_date =
                 (SELECT MAX(csd2.end_cash_surr_date)
                    FROM ven_policy_cash_surr_d csd2
                   WHERE csd2.policy_cash_surr_id = cs.policy_cash_surr_id
                     AND csd2.end_cash_surr_date <= par_decline_date);
        EXCEPTION
          WHEN OTHERS THEN
            v_redemption_sum := 0;
        END;
      END IF;
    ELSE
      v_redemption_sum := 0;
    END IF;
    -- *** Доп. инвест доход
    IF (nvl(v_type_desc, '~') = 'ОСН' OR nvl(v_line_desc, '~') = 'ИНВЕСТ' OR
       nvl(v_line_desc, '~') = 'ИНВЕСТ2' OR nvl(v_line_desc, '~') = 'Сбалансированная' OR
       nvl(v_line_desc, '~') = 'Агрессивная' OR nvl(v_line_desc, '~') = 'Агрессивная плюс')
       AND v_prev_policy_id IS NOT NULL
    THEN
      BEGIN
        SELECT aii.add_income_cur
          INTO v_add_invest_income
          FROM ven_p_add_invest_income aii
              ,ven_as_assured          aa
              ,contact                 c
         WHERE aii.pol_header_id = v_pol_header_id
           AND aii.t_product_line_id = par_product_line_id
           AND upper(c.name || ' ' || c.first_name || ' ' || c.middle_name) = aii.as_asset_name
           AND c.contact_id = aa.assured_contact_id
           AND aa.as_assured_id = par_as_asset_id
           AND aii.income_date = (SELECT MAX(aii2.income_date)
                                    FROM ven_p_add_invest_income aii2
                                        ,ven_as_assured          aa2
                                        ,contact                 c2
                                   WHERE aii2.income_date <= par_decline_date
                                     AND aii2.pol_header_id = v_pol_header_id
                                     AND aii2.t_product_line_id = par_product_line_id
                                     AND aii2.as_asset_name =
                                         upper(c2.name || ' ' || c2.first_name || ' ' || c2.middle_name)
                                     AND c2.contact_id = aa2.assured_contact_id
                                     AND aa2.as_assured_id = par_as_asset_id);
      EXCEPTION
        WHEN no_data_found THEN
          v_add_invest_income := 0;
      END;
    ELSE
      v_add_invest_income := 0;
    END IF;
    -- *** Возврат части премии
    v_return_bonus_part := 0;
    -- *** Начисленная премия к списанию прошлых лет
    v_bonus_off_prev := 0;
    -- *** Начисленная премия к списанию этого года
    v_bonus_off_current := 0;
    -- ***Недоплата фактическая
    v_underpayment_actual := 0;
    -- *** Административные издержки
    v_admin_expenses := 0;
    -- Байтин А.
    -- Добавил округление до 2-х знаков
    UPDATE p_cover_decline
       SET redemption_sum      = ROUND(v_redemption_sum, 2)
          ,add_invest_income   = ROUND(v_add_invest_income, 2)
          ,return_bonus_part   = ROUND(v_return_bonus_part, 2)
          ,bonus_off_prev      = ROUND(v_bonus_off_prev, 2)
          ,bonus_off_current   = ROUND(v_bonus_off_current, 2)
          ,admin_expenses      = ROUND(v_admin_expenses, 2)
          ,underpayment_actual = ROUND(v_underpayment_actual, 2)
     WHERE p_cover_decline_id = par_cover_decline_id;
    --EXCEPTION
    --WHEN others THEN
    --Raise_Application_Error( -20001, 'Ошибка Fill_Cover_Decline_Line: ' ||
    --SQLERRM );
  END fill_cover_decline_line;
  ----========================================================================----
  -- Расчет расходов на МедО
  FUNCTION calc_medo_cost(par_policy_id NUMBER) RETURN NUMBER IS
    v_medo_cost NUMBER;
  BEGIN
    SELECT SUM(exam_cost) INTO v_medo_cost FROM ven_as_assured WHERE p_policy_id = par_policy_id;
    RETURN(nvl(v_medo_cost, 0));
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка Calc_Medo_Cost: ' || SQLERRM);
  END calc_medo_cost;
  ----========================================================================----
  -- *** Проверки при переводе статусов ***
  ----========================================================================----
  -- Проверка: в форме прекращения договора заполнены обязательные поля
  PROCEDURE not_null_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_reg_code           NUMBER;
    v_t_product_conds_id NUMBER;
    v_decline_date       DATE;
    v_decline_reason_id  NUMBER;
    v_medo_cost          NUMBER;
    v_debt_fee_sum       NUMBER;
    v_act_date           DATE;
  BEGIN
    SELECT pd.reg_code
          ,pd.t_product_conds_id
          ,p.decline_date
          ,p.decline_reason_id
          ,pd.medo_cost
          ,p.debt_summ
          ,pd.act_date
      INTO v_reg_code
          ,v_t_product_conds_id
          ,v_decline_date
          ,v_decline_reason_id
          ,v_medo_cost
          ,v_debt_fee_sum
          ,v_act_date
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = pd.p_policy_id
       AND p.policy_id = par_policy_id;
    IF v_reg_code IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле "Код региона"';
      RAISE v_exeption;
    END IF;
    IF v_t_product_conds_id IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле "Полисные условия"';
      RAISE v_exeption;
    END IF;
    IF v_decline_date IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле "Дата расторжения ДС"';
      RAISE v_exeption;
    END IF;
    IF v_decline_reason_id IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле "Причина расторжения ДС"';
      RAISE v_exeption;
    END IF;
    IF v_medo_cost IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле "Расходы на МедО"';
      RAISE v_exeption;
    END IF;
    IF v_debt_fee_sum IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле ' || '"Недоплата по полису составляет"';
      RAISE v_exeption;
    END IF;
    IF v_act_date IS NULL
    THEN
      v_msg := 'В форме прекращения ДС не заполнено поле ' || '"Дата акта"';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Not_Null_Control: ' || SQLERRM);
  END not_null_control;
  ----========================================================================----
  -- Проверка: в форме прекращения договора "Итого к выплате" больше нуля
  PROCEDURE return_sum_greater_then_0(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_return_sum NUMBER;
  BEGIN
    SELECT p.return_summ INTO v_return_sum FROM p_policy p WHERE p.policy_id = par_policy_id;
    IF nvl(v_return_sum, 0) <= 0
    THEN
      v_msg := 'В форме прекращения ДС поле "Итого к выплате" должно быть больше 0';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Return_Sum_Greater_Then_0: ' || SQLERRM);
  END return_sum_greater_then_0;
  ----========================================================================----
  -- Проверка: заданы банковские реквизиты для страхователя
  PROCEDURE issuer_bank_acc_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_dummy CHAR(1);
  BEGIN
    BEGIN
      SELECT '1'
        INTO v_dummy
        FROM p_policy_contact        pc
            ,t_contact_pol_role      cpr
            ,ven_cn_contact_bank_acc acc
       WHERE pc.policy_id = par_policy_id
         AND cpr.brief = 'Страхователь'
         AND cpr.id = pc.contact_policy_role_id
         AND pc.contact_id = acc.contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_msg := 'Не заданы банковские реквизиты для страхователя';
        RAISE v_exeption;
      WHEN too_many_rows THEN
        NULL;
    END;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Issuer_Bank_Acc_Control: ' || SQLERRM);
  END issuer_bank_acc_control;
  ----========================================================================----
  -- Проверка: Если в форме прекращения ДС заданы суммы по Доп. инвест доходу,
  -- должно быть заполнено поле "Сумма НДФЛ"
  PROCEDURE income_tax_sum_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_income_tax_sum NUMBER;
  BEGIN
    BEGIN
      SELECT p.income_tax_sum
        INTO v_income_tax_sum
        FROM p_pol_decline p
       WHERE p.p_policy_id = par_policy_id
         AND EXISTS (SELECT '2'
                FROM p_cover_decline cd
                    ,p_pol_decline   pd
               WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                 AND pd.p_policy_id = par_policy_id
                 AND nvl(cd.add_invest_income, 0) > 0);
      IF v_income_tax_sum IS NULL
      THEN
        v_msg := 'Если в форме прекращения ДС заданы суммы по Доп. инвест доходу, ' ||
                 'должно быть заполнено поле "Сумма НДФЛ"';
        RAISE v_exeption;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Income_Tax_Sum_Control: ' || SQLERRM);
  END income_tax_sum_control;
  ----========================================================================----
  -- Проверка: Если в форме прекращения ДС "Итого к выплате" больше нуля,
  -- должна быть задана "Дата выплаты страхователю"
  PROCEDURE issuer_return_date_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_issuer_return_date DATE;
    v_return_sum         NUMBER;
  BEGIN
    SELECT pd.issuer_return_date
          ,p.return_summ
      INTO v_issuer_return_date
          ,v_return_sum
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_policy_id
       AND p.policy_id = pd.p_policy_id;
    IF nvl(v_return_sum, 0) > 0
       AND v_issuer_return_date IS NULL
    THEN
      v_msg := 'Если в форме прекращения ДС "Итого к выплате" больше нуля, ' ||
               'должна быть задана "Дата выплаты страхователю"';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Issuer_Return_Date_Control: ' || SQLERRM);
  END issuer_return_date_control;
  ----========================================================================----
  -- Общую проверку № 1 удалили
  ----========================================================================----
  -- Общая проверка № 2:
  -- "Сумма зачета на другой договор" <=
  -- ( "Итого к выплате" )
  PROCEDURE return_sum_add_invest_income(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_return_sum            NUMBER;
    v_other_pol_sum         NUMBER;
v_income_tax_sum number;
  BEGIN
    SELECT p.return_summ
          ,pd.other_pol_sum
					,pd.income_tax_sum
      INTO v_return_sum
          ,v_other_pol_sum
					,v_income_tax_sum
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_policy_id
       AND p.policy_id = pd.p_policy_id;

    IF nvl(v_other_pol_sum, 0) > greatest(nvl(v_return_sum, 0)-nvl(v_income_tax_sum,0),0)
    THEN
      v_msg := 'Должно быть: "Сумма зачета на другой договор" <= "Итого к выплате" - Сумма НДФЛ';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Return_Sum_Add_Invest_Income: ' || SQLERRM);
  END return_sum_add_invest_income;
  ----========================================================================----
  -- Общая проверка № 3:
  -- Проверка соответствия причины расторжения и ненулевых полей.
  -- Если причина расторжения "Неоплата первого взноса" или "Отказ Страховщика"
  -- или "Отказ страхователя от НУ", то могут быть больше нуля только поля:
  -- "Возврат части премии", "Начисленная премия к списанию прошлых лет",
  -- "Начисленная премия к списанию этого года", "Расходы на МедО",
  -- "Недоплата по полису составляет", "Сумма зачета на другой договор",
  -- "В связи с досрочным прекращением Договора сумма к возврату Страхователю",
  -- "Итого к выплате"
  PROCEDURE reason_greater_then_0(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_reason_brief          t_decline_reason.brief%TYPE;
    v_income_tax_sum        NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
  BEGIN
    BEGIN
      SELECT dr.brief
            ,pd.income_tax_sum
        INTO v_reason_brief
            ,v_income_tax_sum
        FROM ven_p_policy         p
            ,ven_t_decline_reason dr
            ,ven_p_pol_decline    pd
       WHERE p.decline_reason_id = dr.t_decline_reason_id
         AND p.policy_id = pd.p_policy_id
         AND p.policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_reason_brief := NULL;
    END;
    IF v_reason_brief IS NOT NULL
    THEN
      IF v_reason_brief IN ('Неоплата первого взноса'
                           ,'Отказ Страховщика'
                           ,'Отказ страхователя от НУ')
      THEN
        IF nvl(v_income_tax_sum, 0) > 0
        THEN
          v_msg := 'Если причина расторжения "' || v_reason_brief ||
                   '", то "Сумма НДФЛ" не может быть больше нуля.';
          RAISE v_exeption;
        END IF;
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = par_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
        IF nvl(v_sum_redemption_sum, 0) > 0
        THEN
          v_msg := 'Если причина расторжения "' || v_reason_brief ||
                   '", то "Выкупная сумма" не может быть больше нуля.';
          RAISE v_exeption;
        END IF;
        IF nvl(v_sum_add_invest_income, 0) > 0
        THEN
          v_msg := 'Если причина расторжения "' || v_reason_brief ||
                   '", то "Доп. инвест доход" не может быть больше нуля.';
          RAISE v_exeption;
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Reason_Greater_Then_0: ' || SQLERRM);
  END reason_greater_then_0;
  ----========================================================================----
  -- Проверка: Если в форме прекращения ДС "НДФЛ" больше нуля,
  -- должна быть задана "Дата начисления НДФЛ"
  PROCEDURE income_tax_sum_date_control(par_policy_id NUMBER) IS
    v_income_tax_sum  NUMBER;
    v_income_tax_date DATE;
    v_msg             VARCHAR2(500);
    v_exeption EXCEPTION;
  BEGIN
    BEGIN
      SELECT income_tax_sum
            ,income_tax_date
        INTO v_income_tax_sum
            ,v_income_tax_date
        FROM p_pol_decline
       WHERE p_policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_income_tax_sum := NULL;
    END;
    IF nvl(v_income_tax_sum, 0) > 0
       AND v_income_tax_date IS NULL
    THEN
      v_msg := 'Если НДФЛ больше нуля, должна быть задана дата начисления НДФЛ';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Income_Tax_Sum_Date_Control: ' || SQLERRM);
  END income_tax_sum_date_control;
  ----========================================================================----
  -- ФИО текущего пользователя для отчетов о расторжении
  FUNCTION get_current_user_fio RETURN VARCHAR2 IS
    v_name ven_sys_user.name%TYPE;
  BEGIN
    SELECT NAME
      INTO v_name
      FROM ven_sys_user
     WHERE sys_user_name = USER
       AND rownum = 1;
    RETURN(v_name);
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Current_User_FIO: ' || SQLERRM);
  END get_current_user_fio;
  ----========================================================================----
  -- Генерация корректирующих проводок
  PROCEDURE gen_fix_trans(par_p_trans_decline_id NUMBER) IS
    v_oper_templ_id NUMBER;
    v_trans_sum     NUMBER;
    v_oper_id       NUMBER;
    v_ent_id        NUMBER;
    v_p_cover_id    NUMBER;
  BEGIN
    SELECT oper_templ_id
          ,trans_sum
          ,p_cover_id
      INTO v_oper_templ_id
          ,v_trans_sum
          ,v_p_cover_id
      FROM ven_p_trans_decline
     WHERE p_trans_decline_id = par_p_trans_decline_id;
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'P_COVER';
    v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                             ,p_document_id       => par_p_trans_decline_id
                                             ,p_service_ent_id    => v_ent_id
                                             , -- NULL,
                                              p_service_obj_id    => v_p_cover_id
                                             , -- NULL,
                                              p_doc_status_ref_id => NULL
                                             ,p_is_accepted       => 1
                                             ,p_summ              => v_trans_sum
                                             ,p_source            => 'INS');
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Gen_Fix_Trans: ' || SQLERRM);
  END gen_fix_trans;
  ----========================================================================----
  -- Удаление корректирующих проводок
  PROCEDURE del_fix_trans(par_p_trans_decline_id NUMBER) IS
    CURSOR trans_curs(pcurs_p_trans_decline_id NUMBER) IS
      SELECT o.oper_id
            ,
             /*t.is_closed,*/pkg_period_closed.check_date_in_closed(t.trans_date) is_closed
            , --273031: Изменение триггера контроля закрытого периода /Чирков/
             t.trans_date
        FROM oper  o
            ,trans t
       WHERE o.document_id = pcurs_p_trans_decline_id
         AND t.oper_id = o.oper_id;
  BEGIN
    FOR trans_rec IN trans_curs(par_p_trans_decline_id)
    LOOP
      IF trans_rec.is_closed = 1
      THEN
        -- Сторнирование
        acc_new.storno_trans(trans_rec.oper_id);
      ELSE
        -- Удаление
        DELETE FROM oper WHERE oper_id = trans_rec.oper_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Del_Fix_Trans: ' || SQLERRM);
  END del_fix_trans;
  ----========================================================================----
  -- Процедура проставляет аналитики по сформированным проводкам
  PROCEDURE set_analytics
  (
    par_oper_id           NUMBER
   ,par_as_asset_id       NUMBER
   ,par_t_product_line_id NUMBER
  ) IS
    CURSOR trans_curs(pcurs_oper_id NUMBER) IS
      SELECT trans_id
            ,a1_dt_ure_id
            ,a1_dt_uro_id
            ,a1_ct_ure_id
            ,a1_ct_uro_id
            ,a2_dt_ure_id
            ,a2_dt_uro_id
            ,a2_ct_ure_id
            ,a2_ct_uro_id
            ,a3_dt_ure_id
            ,a3_dt_uro_id
            ,a3_ct_ure_id
            ,a3_ct_uro_id
            ,a4_dt_ure_id
            ,a4_dt_uro_id
            ,a4_ct_ure_id
            ,a4_ct_uro_id
            ,a5_dt_ure_id
            ,a5_dt_uro_id
            ,a5_ct_ure_id
            ,a5_ct_uro_id
        FROM trans
       WHERE oper_id = pcurs_oper_id;
    v_ent_id_contact            NUMBER;
    v_ent_id_p_policy           NUMBER;
    v_ent_id_p_asset_header     NUMBER;
    v_ent_id_p_cover            NUMBER;
    v_ent_id_t_prod_line_option NUMBER;
    v_t_prod_line_option_id     NUMBER;
    v_p_cover_id                NUMBER;
    v_p_asset_header_id         NUMBER;
  BEGIN
    /*SELECT ent_id INTO v_ent_id_CONTACT FROM entity
      WHERE brief = 'CONTACT'; -- Контакт
    SELECT ent_id INTO v_ent_id_P_POLICY FROM entity
      WHERE brief = 'P_POLICY'; -- Версия договора страхования */
    SELECT ent_id INTO v_ent_id_p_asset_header FROM entity WHERE brief = 'P_ASSET_HEADER'; -- Заголовок объекта страхования
    SELECT ent_id INTO v_ent_id_p_cover FROM entity WHERE brief = 'P_COVER'; -- Страховое покрытие
    SELECT ent_id INTO v_ent_id_t_prod_line_option FROM entity WHERE brief = 'T_PROD_LINE_OPTION'; -- Группа рисков по линии продукта
    SELECT id
      INTO v_t_prod_line_option_id
      FROM t_prod_line_option plo
     WHERE plo.product_line_id = par_t_product_line_id
       AND EXISTS (SELECT '1'
              FROM p_cover c
             WHERE c.t_prod_line_option_id = plo.id
               AND c.as_asset_id = par_as_asset_id);
    SELECT p_cover_id
      INTO v_p_cover_id
      FROM p_cover
     WHERE as_asset_id = par_as_asset_id
       AND t_prod_line_option_id = v_t_prod_line_option_id;
    SELECT p_asset_header_id
      INTO v_p_asset_header_id
      FROM as_asset
     WHERE as_asset_id = par_as_asset_id;
    FOR trans_rec IN trans_curs(par_oper_id)
    LOOP
      IF trans_rec.a1_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a1_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a2_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a3_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a4_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a5_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      IF trans_rec.a1_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a1_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a2_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a3_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a4_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a5_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      --
      IF trans_rec.a1_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a1_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a2_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a3_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a4_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a5_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      IF trans_rec.a1_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a1_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a2_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a3_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a4_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a5_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      ----
      IF trans_rec.a1_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a1_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a2_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a3_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a4_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a5_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      IF trans_rec.a1_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a1_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a2_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a3_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a4_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a5_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      END IF;
    END LOOP;
    --EXCEPTION
    --WHEN others THEN
    --Raise_Application_Error( -20001, 'Set_Analytics: ' || SQLERRM );
  END set_analytics;
  ----========================================================================----
  -- 1) Округление ВС, ДИД, возврат:
  -- Полученная сумма прибавляется к максимальной сумме проводки по шаблонам:
  -- Начисление выкупной суммы, Начисление дополнительного инвестиционного дохода,
  -- Начислен возврат СП при расторжении ДС.
  -- Алгоритм расчета: Округление ВС, ДИД, возврат = ((?Выкупная сумма + ?ДИД +
  -- ?Возврат части премии) значение полей по всем рискам) -
  -- (значение поля "МедО") - * Шаблон "Начисление выкупной суммы" -
  -- Шаблон "Начисление дополнительного инвестиционного дохода" -
  -- Шаблон "Начислен возврат СП при расторжении ДС"
  FUNCTION get_round_1(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return                NUMBER := 0;
    v_oper_id               NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( Начисление выкупной суммы )
    v_sum_4                 NUMBER := 0; -- SUM( Начисление дополнительного инвестиционного дохода )
    v_sum_5                 NUMBER := 0; -- SUM( Начислен возврат СП при расторжении ДС )
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    SELECT pd.medo_cost
      INTO v_medo_cost
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) != 0
    THEN
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 3 *** Начисление выкупной суммы 22.05.31 77.00.14
        v_sum   := nvl(cover_rec.redemption_sum, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
        -- 4 *** Начисление дополнительного инвестиционного дохода 22.05.33 77.00.14
        v_sum   := nvl(cover_rec.add_invest_income, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
        -- 5 *** Начислен возврат СП при расторжении ДС 22.05.11 77.00.13
        v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
      END LOOP;
      v_return := (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0)) - nvl(v_medo_cost, 0) - nvl(v_sum_3, 0) -- Начисление выкупной суммы
                  - nvl(v_sum_4, 0) -- Начисление ДИД
                  - nvl(v_sum_5, 0); -- Начислен возврат СП при расторжении ДС
    END IF;
    v_return := ROUND(nvl(v_return, 0), 2);
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_1: ' || SQLERRM);
  END get_round_1;
  ----========================================================================----
  -- 2) Округление зачета в счет недоплаты:
  -- Полученная сумма прибавляется к максимальной сумме проводки по шаблонам:
  -- Зачет ВС (Зачет на этот  ДС), Зачтена выплата ДИД (Зачет на этот  ДС),
  -- Зачтена выплата возв (Зачет на этот  ДС).
  -- Алгоритм расчета: Округление зачета в счет другого договора = (значение поля
  -- "Недоплата по полису составляет") - ? Шаблон "Зачет ВС (Зачет на этот  ДС)" -
  -- ? Шаблон "Зачтена выплата ДИД (Зачет на этот  ДС)" -
  -- ? Шаблон "Зачтена выплата возв (Зачет на этот  ДС)"
  FUNCTION get_round_2(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return                NUMBER := 0;
    v_oper_id               NUMBER;
    v_oper_templ_id         NUMBER;
    v_debt_summ             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_6                 NUMBER := 0; -- SUM( Зачет ВС )
    v_sum_7                 NUMBER := 0; -- SUM( Зачтена выплата ДИД )
    v_sum_8                 NUMBER := 0; -- SUM( Зачтена выплата возв )
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    SELECT p.debt_summ
      INTO v_debt_summ
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) != 0
    THEN
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 6 *** Зачет ВС 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.redemption_sum, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_6 := v_sum_6 + nvl(ROUND(v_sum, 2), 0);
        -- 7 *** Зачтена выплата ДИД 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.add_invest_income, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_7 := v_sum_7 + nvl(ROUND(v_sum, 2), 0);
        -- 8 *** Зачтена выплата возв 77.00.13 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.return_bonus_part, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_8 := v_sum_8 + nvl(ROUND(v_sum, 2), 0);
      END LOOP;
    ELSE
      v_sum_6 := 0;
      v_sum_7 := 0;
      v_sum_8 := 0;
    END IF;
    v_return := nvl(v_debt_summ, 0) -- Недоплата по полису составляет
                - nvl(v_sum_6, 0) -- Зачет ВС
                - nvl(v_sum_7, 0) -- Зачтена выплата ДИД
                - nvl(v_sum_8, 0); -- Зачтена выплата возв
    v_return := ROUND(nvl(v_return, 0), 2);
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_2: ' || SQLERRM);
  END get_round_2;
  ----========================================================================----
  -- 3) Округление зачета на новый договор:
  -- Полученная сумма прибавляется к максимальной сумме проводки по шаблонам:
  -- Зачет ВС (Зачет на другой  ДС), Зачтена выплата ДИД (Зачет на другой  ДС),
  -- Зачтена выплата возв (Зачет на другой  ДС).
  -- Алгоритм расчета: Округление зачета в счет другого договора =
  -- (значение поля "Сумма зачета на другой договор") -
  -- ? Шаблон "Зачет ВС (Зачет на другой  ДС)" -
  -- ? Шаблон "Зачтена выплата ДИД (Зачет на другой  ДС)" -
  -- ? Шаблон "Зачтена выплата возв (Зачет на другой  ДС)"
  PROCEDURE get_round_3
  (
    par_p_policy_id  IN NUMBER
   ,par_round_err    OUT NUMBER
   , -- ошибка округления
    par_template_num OUT NUMBER -- номер шаблона проводки, в сумме которой
    -- учтена ошибка округления (9, 10 или 11)
  ) IS
    v_other_pol_sum         NUMBER;
    v_oper_id               NUMBER;
    v_ent_id                NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( Начисление выкупной суммы )
    v_sum_4                 NUMBER := 0; -- SUM( Начисление дополнительного инвестиционного дохода )
    v_sum_5                 NUMBER := 0; -- SUM( Начислен возврат СП при расторжении ДС )
    v_sum_9                 NUMBER := 0; -- Зачет ВС (зачет на другой ДС)
    v_sum_10                NUMBER := 0; -- Зачтена выплата ДИД (зачет на другой ДС)
    v_sum_11                NUMBER := 0; -- Зачтена выплата возв (зачет на другой ДС)
    v_continue              BOOLEAN := TRUE;
    --
    v_round_err    NUMBER;
    v_max_sum      NUMBER := 0; -- максимальная сумма по проводкам
    v_template_num NUMBER;
    --
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    BEGIN
      SELECT pd.other_pol_sum
            ,pd.medo_cost
        INTO v_other_pol_sum
            ,v_medo_cost
        FROM p_pol_decline pd
       WHERE pd.p_policy_id = par_p_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_other_pol_sum := NULL;
        v_continue      := FALSE;
    END;
    IF nvl(v_other_pol_sum, 0) = 0
    THEN
      v_continue := FALSE;
    END IF;
    IF v_continue
    THEN
      BEGIN
        -- Данные по застрахованным и программам
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
              ,SUM(cd.return_bonus_part)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
              ,v_sum_return_bonus_part
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = par_p_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    IF v_continue
    THEN
      BEGIN
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) != 0
        THEN
          FOR cover_rec IN cover_curs(par_p_policy_id)
          LOOP
            -- 3 *** Начисление выкупной суммы 22.05.31 77.00.14
            v_sum   := nvl(cover_rec.redemption_sum, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
            -- 4 *** Начисление дополнительного инвестиционного дохода 22.05.33 77.00.14
            v_sum   := nvl(cover_rec.add_invest_income, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
            -- 5 *** Начислен возврат СП при расторжении ДС 22.05.11 77.00.13
            v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
          END LOOP;
        ELSE
          v_sum_3 := 0;
          v_sum_4 := 0;
          v_sum_5 := 0;
        END IF;
        -- 9 *** Зачет ВС (зачет на другой ДС) 77.00.14 77.08.03
        v_sum := nvl(v_other_pol_sum, 0) * v_sum_3 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          IF v_sum > v_max_sum
          THEN
            v_max_sum      := v_sum;
            v_template_num := 9;
          END IF;
          v_sum_9 := v_sum;
        END IF;
        -- 10 *** Зачтена выплата ДИД (зачет на другой ДС) 77.00.14 77.08.03
        v_sum := nvl(v_other_pol_sum, 0) * v_sum_4 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          IF v_sum > v_max_sum
          THEN
            v_max_sum      := v_sum;
            v_template_num := 10;
          END IF;
          v_sum_10 := v_sum;
        END IF;
        -- 11 *** Зачтена выплата возв (зачет на другой ДС) 77.00.13 77.08.03
        v_sum := nvl(v_other_pol_sum, 0) * v_sum_5 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          IF v_sum > v_max_sum
          THEN
            v_max_sum      := v_sum;
            v_template_num := 11;
          END IF;
          v_sum_11 := v_sum;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;

    IF v_continue
    THEN
      -- Расчет ошибки округления
      v_round_err      := nvl(v_other_pol_sum, 0) -- Сумма зачета на другой договор
                          - nvl(v_sum_9, 0) -- Зачет ВС (зачет на другой ДС)
                          - nvl(v_sum_10, 0) -- Зачтена выплата ДИД (зачет на другой ДС)
                          - nvl(v_sum_11, 0); -- Зачтена выплата возв (зачет на другой ДС)
      par_round_err    := v_round_err;
      par_template_num := v_template_num;
    ELSE
      par_round_err    := 0;
      par_template_num := NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_3: ' || SQLERRM);
  END get_round_3;
  ----========================================================================----
  -- 4) Округления Переплата по договору:
  -- Полученная сумма прибавляется к максимальной сумме проводки по шаблону:
  -- Переплата по договору.
  -- Алгоритм расчета: Округления Переплата по договору =
  -- (значение поля "Переплата по полису составляет") -
  -- ? Шаблон "Переплата по договору"
  FUNCTION get_round_4(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return                NUMBER := 0;
    v_oper_id               NUMBER;
    v_oper_templ_id         NUMBER;
    v_overpayment           NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_17                NUMBER := 0; -- SUM( Переплата по договору )
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
             -- Байтин А.
             -- Добавлен процент брутто-взноса от общей суммы брутто-взносов
            ,pc.fee / SUM(pc.fee) over() AS fee_coeff
        FROM p_cover_decline cd
            ,p_pol_decline   pd
             --
            ,p_cover            pc
            ,t_prod_line_option plo
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id
            --
         AND pc.as_asset_id = cd.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = cd.t_product_line_id;
  BEGIN
    SELECT pd.overpayment
      INTO v_overpayment
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    -- Байтин А.
    -- Изменен алгоритм получения шибки округления
    IF v_overpayment != 0
    THEN

      /*IF NVL( v_sum_redemption_sum, 0 ) + NVL( v_sum_add_invest_income, 0 ) +
      NVL( v_sum_return_bonus_part, 0 ) != 0 THEN*/
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 17 *** Переплата по договору 77.01.03 77.00.13
        /*v_sum := ( NVL( v_overpayment, 0 ) / ( NVL( v_sum_redemption_sum, 0 ) +
          NVL( v_sum_add_invest_income, 0 ) +  NVL( v_sum_return_bonus_part, 0 ) ) )
          * ( NVL( cover_rec.redemption_sum, 0 ) +
              NVL( cover_rec.add_invest_income, 0 ) +
              NVL( cover_rec.return_bonus_part, 0 ) );
        v_sum_17 := v_sum_17 + ROUND( NVL( v_sum, 0 ), 2 );*/
        v_sum_17 := v_sum_17 + ROUND(v_overpayment * cover_rec.fee_coeff, 2);
      END LOOP;
      v_return := nvl(v_overpayment, 0) -- Переплата по полису составляет
                  - nvl(v_sum_17, 0); -- Переплата по договору
    END IF;
    v_return := ROUND(nvl(v_return, 0), 2);
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_4: ' || SQLERRM);
  END get_round_4;
  ----========================================================================----
  -- Причина расторжения ДС - в группе "Аннулирование"
  -- 1 - в группе, 0 - нет
  FUNCTION decline_reason_is_annul(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return NUMBER(1);
    v_dummy  CHAR(1);
  BEGIN
    BEGIN
      SELECT '1'
        INTO v_dummy
        FROM p_policy         p
            ,t_decline_reason r
       WHERE p.policy_id = par_p_policy_id
         AND p.decline_reason_id = r.t_decline_reason_id
         AND r.t_decline_type_id =
             (SELECT t_decline_type_id FROM t_decline_type WHERE brief = 'Аннулирование');
      v_return := 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_return := 0;
    END;
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка Decline_Reason_Is_Annul: ' || SQLERRM);
  END decline_reason_is_annul;
  ----========================================================================----
  -- Проверка: если причина расторжения ДС из группы "Аннулирование", то
  -- должны быть равны нулю:
  -- Выкупная сумма
  -- Доп. инвест доход
  -- Админ. расходы
  -- Недоплата удерживаема
  -- Недоплата фактическая
  -- Переплата
  -- (Чтобы не сформировались лишние проводки)
  PROCEDURE check_annul(par_p_policy NUMBER) IS
    v_dummy CHAR(1);
    v_raise BOOLEAN := FALSE;
  BEGIN
    IF decline_reason_is_annul(par_p_policy) = 1
    THEN
      BEGIN
        SELECT '1'
          INTO v_dummy
          FROM p_policy        p
              ,p_pol_decline   pd
              ,p_cover_decline cd
         WHERE p.policy_id = par_p_policy
           AND p.policy_id = pd.p_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id
           AND (nvl(cd.redemption_sum, 0) != 0 OR nvl(cd.add_invest_income, 0) != 0 OR
               nvl(cd.admin_expenses, 0) != 0 OR nvl(p.debt_summ, 0) != 0 OR
               nvl(pd.debt_fee_fact, 0) != 0 OR nvl(pd.overpayment, 0) != 0);
        v_raise := TRUE;
      EXCEPTION
        WHEN too_many_rows THEN
          v_raise := TRUE;
        WHEN no_data_found THEN
          v_raise := FALSE;
      END;
      IF v_raise
      THEN
        RAISE e_annul_check_failure;
      END IF;
    END IF;
  END check_annul;
  ----========================================================================----
  -- Генерация первой группы основных проводок по прекращению ДС - по дате акта
  PROCEDURE gen_main_trans_group_1(par_p_policy_id NUMBER) IS
    -- p_cover_decline:
    -- p_pol_decline_id - ИД объекта сущности "Данные по расторжению версии ДС"';
    -- as_asset_id - ИД объекта сущности "Объект страхования"
    -- t_product_line_id - ИД объекта сущности "Линия страхового продукта"
    -- cover_period - Срок страхования
    -- redemption_sum - Выкупная сумма
    -- add_invest_income - Доп. инвест доход
    -- return_bonus_part - Возврат части премии
    -- bonus_off_prev - Начисленная премия к списанию прошлых лет
    -- bonus_off_current - Начисленная премия к списанию этого года
    -- admin_expenses - Административные издержки
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
             -- Байтин А.
             -- Добавлен процент брутто-взноса от общей суммы брутто-взносов
            ,pc.fee / SUM(pc.fee) over() AS fee_coeff
        FROM p_cover_decline cd
            ,p_pol_decline   pd
             --
            ,p_cover            pc
            ,t_prod_line_option plo
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id
            --
         AND pc.as_asset_id = cd.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = cd.t_product_line_id;
    v_oper_templ_id NUMBER;
    v_ent_id        NUMBER;
    v_oper_id       NUMBER;
    v_medo_cost     NUMBER;
    v_debt_summ     NUMBER;
    --  v_income_tax_sum        NUMBER;
    v_overpayment NUMBER;
    v_act_date    DATE;
    --
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( Начисление выкупной суммы )
    v_sum_4                 NUMBER := 0; -- SUM( Начисление дополнительного инвестиционного дохода )
    v_sum_5                 NUMBER := 0; -- SUM( Начислен возврат СП при расторжении ДС )
    v_sum_6                 NUMBER := 0; -- SUM( Зачет ВС )
    v_sum_7                 NUMBER := 0; -- SUM( Зачтена выплата ДИД )
    v_sum_8                 NUMBER := 0; -- SUM( Зачтена выплата возв )
    v_sum_16                NUMBER := 0; -- SUM( Удержание Адм расходов по программе Защита )
    v_sum_17                NUMBER := 0; -- SUM( Переплата по договору )
    --
    v_max_sum         NUMBER := 0; -- максимальная сумма по 3, 4, 5 проводкам
    v_max_sum_oper_id NUMBER; -- ИД операции, соответствующей максимальной сумме
    -- по 3, 4, 5 проводкам
    v_max_sum_2         NUMBER := 0; -- максимальная сумма по 6, 7, 8 проводкам
    v_max_sum_oper_id_2 NUMBER; -- ИД операции, соответствующей максимальной сумме
    -- по 6, 7, 8 проводкам
    v_max_sum_17         NUMBER := 0; -- максимальная сумма по 17 проводке
    v_max_sum_oper_id_17 NUMBER; -- ИД операции, соответствующей максимальной сумме
    -- по 17 проводке
    v_round_err_1       NUMBER; -- ошибка округления по 3, 4, 5 проводкам
    v_round_err_2       NUMBER; -- ошибка округления по 6, 7, 8 проводкам
    v_round_err_3       NUMBER; -- ошибка округления по 9, 10, 11 проводкам
    v_round_err         NUMBER; -- ошибка округления
    v_overpayment_round NUMBER; -- ошибка округления по переплате
    --
    v_template_num NUMBER; -- номер шаблона (3, 4 или 5) проводки,
    -- на которой зачтена первая ошибка округления
    v_template_num_2 NUMBER; -- номер шаблона (6, 7 или 8) проводки,
    -- на которой зачтена вторая ошибка округления
    v_template_num_3 NUMBER; -- номер шаблона (9, 10 или 11) проводки,
    -- на которой зачтена третья ошибка округления
    --
    v_oper_id_13 NUMBER; -- идентификатор операции по 13-ой проводке
    v_oper_id_14 NUMBER; -- идентификатор операции по 14-ой проводке
    --
    v_sum_9         NUMBER := 0; -- Зачет ВС (зачет на другой ДС)
    v_sum_10        NUMBER := 0; -- Зачтена выплата ДИД (зачет на другой ДС)
    v_sum_11        NUMBER := 0; -- Зачтена выплата возв (зачет на другой ДС)
    v_other_pol_sum NUMBER;
    --
    v_templ_name VARCHAR2(30); -- для выбора шаблона 5-ой проводки
    --------------------------------------------------------------------------------
    FUNCTION get_p_cover_id
    (
      par_asset_id        NUMBER
     ,par_product_line_id NUMBER
    ) RETURN NUMBER IS
      v_return NUMBER;
    BEGIN
      SELECT pc.p_cover_id
        INTO v_return
        FROM p_cover            pc
            ,t_prod_line_option plo
       WHERE pc.as_asset_id = par_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = par_product_line_id
         AND rownum = 1;
      RETURN(v_return);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(NULL);
    END get_p_cover_id;
    --------------------------------------------------------------------------------
    PROCEDURE run_template
    (
      par_oper_templ_brief VARCHAR2
     ,par_p_cover          NUMBER
    ) IS
      v_p_service_ent_id NUMBER;
      v_p_service_obj_id NUMBER;
    BEGIN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = par_oper_templ_brief;
      IF par_p_cover IS NULL
      THEN
        v_p_service_ent_id := v_ent_id;
        v_p_service_obj_id := par_p_policy_id;
      ELSE
        SELECT ent_id INTO v_p_service_ent_id FROM entity WHERE brief = 'P_COVER';
        v_p_service_obj_id := par_p_cover;
      END IF;
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                               ,p_document_id       => par_p_policy_id
                                               ,p_service_ent_id    => v_p_service_ent_id
                                               ,p_service_obj_id    => v_p_service_obj_id
                                               ,p_doc_status_ref_id => NULL
                                               ,p_is_accepted       => 1
                                               ,p_summ              => v_sum
                                               ,p_source            => 'INS');
      --EXCEPTION
      --WHEN others THEN
      --Raise_Application_Error( -20001, 'Run_Template: ' || SQLERRM );
    END run_template;
    --------------------------------------------------------------------------------
  BEGIN
    check_annul(par_p_policy_id);
    SELECT p.ent_id
          ,pd.medo_cost
          ,p.debt_summ
          , --pd.income_tax_sum,
           pd.overpayment
          ,pd.other_pol_sum
          ,pd.act_date
      INTO v_ent_id
          ,v_medo_cost
          ,v_debt_summ
          , --v_income_tax_sum,
           v_overpayment
          ,v_other_pol_sum
          ,v_act_date
      FROM ven_p_policy  p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    FOR cover_rec IN cover_curs(par_p_policy_id)
    LOOP
      -- 1 *** Корректировка Начисленной премии к списанию прошлых лет 91.02 77.01.01
      v_sum := ROUND(cover_rec.bonus_off_prev, 2);
      IF nvl(v_sum, 0) != 0
      THEN
        run_template('QUIT_MAIN_1'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
      END IF;
      -- 2 *** Сторно Начисленной премии к списанию текущего года 77.01.01 92.01
      v_sum := ROUND(-cover_rec.bonus_off_current, 2); -- с минусом
      IF nvl(v_sum, 0) != 0
      THEN
        run_template('QUIT_MAIN_2'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
      END IF;
      -- 3 *** Начисление выкупной суммы 22.05.31 77.00.14
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := nvl(cover_rec.redemption_sum, 0) -
                 (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_3 := v_sum_3 + v_sum;
          run_template('QUIT_MAIN_3'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
            v_template_num    := 3;
          END IF;
        END IF;
      END IF;
      -- 4 *** Начисление дополнительного инвестиционного дохода 22.05.33 77.00.14
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := nvl(cover_rec.add_invest_income, 0) -
                 (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_4 := v_sum_4 + v_sum;
          run_template('QUIT_MAIN_4'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
            v_template_num    := 4;
          END IF;
        END IF;
      END IF;
      -- 5 *** Начислен возврат СП при расторжении ДС 22.05.11 77.00.13
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := nvl(cover_rec.return_bonus_part, 0) -
                 (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_5 := v_sum_5 + v_sum;
          -- Если причина расторжения ДС из группы "Аннулирование", то для этой
          -- проводки выбирается специальный шаблон
          IF decline_reason_is_annul(par_p_policy_id) = 1
             AND nvl(v_act_date, to_date('01.01.1900', 'DD.MM.YYYY')) >=
             to_date('01.01.2011', 'DD.MM.YYYY')
          THEN
            v_templ_name := 'QUIT_MAIN_5_ANNUL';
          ELSE
            v_templ_name := 'QUIT_MAIN_5';
          END IF;
          run_template(v_templ_name
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
            v_template_num    := 5;
          END IF;
        END IF;
      END IF;
      -- 6 *** Зачет ВС 77.00.14 77.01.03
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := (nvl(v_debt_summ, 0) * nvl(cover_rec.redemption_sum, 0) /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                 nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_6 := v_sum_6 + v_sum;
          run_template('QUIT_MAIN_6'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum_2
          THEN
            v_max_sum_2         := v_sum;
            v_max_sum_oper_id_2 := v_oper_id;
            v_template_num_2    := 6;
          END IF;
        END IF;
      END IF;
      -- 7 *** Зачтена выплата ДИД 77.00.14 77.01.03
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := (nvl(v_debt_summ, 0) * nvl(cover_rec.add_invest_income, 0) /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                 nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_7 := v_sum_7 + v_sum;
          run_template('QUIT_MAIN_7'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum_2
          THEN
            v_max_sum_2         := v_sum;
            v_max_sum_oper_id_2 := v_oper_id;
            v_template_num_2    := 7;
          END IF;
        END IF;
      END IF;
      -- 8 *** Зачтена выплата возв 77.00.13 77.01.03
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := (nvl(v_debt_summ, 0) * nvl(cover_rec.return_bonus_part, 0) /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                 nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_8 := v_sum_8 + v_sum;
          run_template('QUIT_MAIN_8'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum_2
          THEN
            v_max_sum_2         := v_sum;
            v_max_sum_oper_id_2 := v_oper_id;
            v_template_num_2    := 8;
          END IF;
        END IF;
      END IF;
      -- 16 *** Удержание Адм расх по программе Защита 22.05.11 77.00.13
      v_sum := ROUND(-cover_rec.admin_expenses, 2); -- с минусом!
      IF nvl(v_sum, 0) != 0
      THEN
        v_sum_16 := v_sum_16 + v_sum;
        run_template('QUIT_MAIN_16'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
      END IF;
      -- 17 *** Переплата по договору 77.01.03 77.00.13
      -- Байтин А.
      -- Изменен алгоритм. Теперь сумма переплаты разносится пропорционально Брутто-взносу
      IF v_overpayment != 0
      THEN
        v_sum := ROUND(v_overpayment * cover_rec.fee_coeff, 2);
        run_template('QUIT_MAIN_17'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
        v_sum_17 := v_sum_17 + v_sum;
        IF v_sum > v_max_sum_17
        THEN
          v_max_sum_17         := v_sum;
          v_max_sum_oper_id_17 := v_oper_id;
        END IF;
      END IF;
      /*IF NVL( v_sum_redemption_sum, 0 ) + NVL( v_sum_add_invest_income, 0 ) +
            NVL( v_sum_return_bonus_part, 0 ) != 0 THEN
        v_sum := ( NVL( v_overpayment, 0 ) / ( NVL( v_sum_redemption_sum, 0 ) +
          NVL( v_sum_add_invest_income, 0 ) +  NVL( v_sum_return_bonus_part, 0 ) ) )
          * ( NVL( cover_rec.redemption_sum, 0 ) +
              NVL( cover_rec.add_invest_income, 0 ) +
              NVL( cover_rec.return_bonus_part, 0 ) );
        v_sum := ROUND( v_sum, 2 );
        IF NVL( v_sum, 0 ) != 0 THEN
          v_sum_17 := v_sum_17 + v_sum;
          Run_Template( 'QUIT_MAIN_17',
            Get_P_Cover_Id( cover_rec.as_asset_id, cover_rec.t_product_line_id ) );
          Set_Analytics( v_oper_id, cover_rec.as_asset_id,
            cover_rec.t_product_line_id );
          IF v_sum > v_max_sum_17 THEN
            v_max_sum_17 := v_sum;
            v_max_sum_oper_id_17 := v_oper_id;
          END IF;
        END IF;
      END IF;*/
    END LOOP;
    -- 13 *** Зачтена выплата ВС и ДИД 77.00.14 77.00.02
    -- 9 *** Зачет ВС (зачет на другой ДС) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_9 := nvl(v_other_pol_sum, 0) * v_sum_3 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_9 := ROUND(nvl(v_sum_9, 0), 2);
    -- 10 *** Зачтена выплата ДИД (зачет на другой ДС) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_10 := nvl(v_other_pol_sum, 0) * v_sum_4 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_10 := ROUND(nvl(v_sum_10, 0), 2);
    v_sum    := v_sum_3 -- + SUM( Начисление выкупной суммы )
                + v_sum_4 -- + SUM( Начисление дополнительного инвестиционного дохода )
                - v_sum_6 -- - SUM( Зачет ВС )
                - v_sum_7 -- - SUM( Зачтена выплата ДИД )
                - v_sum_9 -- - Зачет ВС (зачет на другой ДС)
                - v_sum_10; -- - Зачтена выплата ДИД (зачет на другой ДС)
    -- - Удержан НДФЛ -- ishch 31.01.2011 без НДФЛ
    -- - NVL( ROUND( v_income_tax_sum, 2 ), 0 );
    IF nvl(v_sum, 0) != 0
    THEN
      run_template('QUIT_MAIN_13', NULL);
      v_oper_id_13 := v_oper_id;
    END IF;
    -- 14 *** Зачтена выплата возв 2 77.00.13 77.00.02
    -- 11 *** Зачтена выплата возв (зачет на другой ДС) 77.00.13 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_11 := nvl(v_other_pol_sum, 0) * v_sum_5 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_11            := ROUND(nvl(v_sum_11, 0), 2);
    v_overpayment_round := nvl(get_round_4(par_p_policy_id), 0);
    v_sum               := v_sum_5 -- + Начислен возврат СП при расторжении ДС
                           - v_sum_8 -- - Зачтена выплата возв
                           - v_sum_11 -- Зачтена выплата возв (зачет на другой ДС)
                           + v_sum_16 -- Удержание Адм расходов по программе Защита
                           + v_sum_17 -- Переплата по договору
                           + v_overpayment_round; -- Округление переплаты по договору
    IF nvl(v_sum, 0) != 0
    THEN
      run_template('QUIT_MAIN_14', NULL);
      v_oper_id_14 := v_oper_id;
    END IF;
    -- Прибавление ошибки округления к максимальной сумме по 3, 4, 5 проводкам
    v_round_err_1 := nvl(get_round_1(par_p_policy_id), 0);
    IF v_max_sum_oper_id IS NOT NULL
       AND v_round_err_1 != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err_1
            ,acc_amount   = acc_amount + v_round_err_1
       WHERE oper_id = v_max_sum_oper_id;
    END IF;
    -- Прибавление ошибки округления к максимальной сумме по 6, 7, 8 проводкам
    v_round_err_2 := nvl(get_round_2(par_p_policy_id), 0);
    IF v_max_sum_oper_id_2 IS NOT NULL
       AND v_round_err_2 != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err_2
            ,acc_amount   = acc_amount + v_round_err_2
       WHERE oper_id = v_max_sum_oper_id_2;
    END IF;
    -- Прибавление ошибки округления к максимальной сумме по 17 проводке
    IF v_max_sum_oper_id_17 IS NOT NULL
    THEN
      v_round_err := nvl(get_round_4(par_p_policy_id), 0);
      IF v_round_err != 0
      THEN
        UPDATE trans
           SET trans_amount = trans_amount + v_round_err
              ,acc_amount   = acc_amount + v_round_err
         WHERE oper_id = v_max_sum_oper_id_17;
      END IF;
    END IF;
    get_round_3(par_p_policy_id, v_round_err_3, v_template_num_3);
    -- Прибавление ошибки округления к сумме 13 проводки:
    v_round_err := 0;
    IF v_round_err_1 != 0
       AND (nvl(v_template_num, 0) = 3 OR nvl(v_template_num, 0) = 4)
    THEN
      -- Если первая ошибка округления зачтена на 3-ей или 4-ой проводке -
      -- учитываем ее на 13-ой проводке
      v_round_err := v_round_err_1;
    END IF;
    IF v_round_err_2 != 0
       AND (nvl(v_template_num_2, 0) = 6 OR nvl(v_template_num_2, 0) = 7)
    THEN
      -- Если вторая ошибка округления зачтена на 6-ой или 7-ой проводке -
      -- учитываем ее на 13-ой проводке
      v_round_err := v_round_err - v_round_err_2;
    END IF;
    IF v_round_err_3 != 0
       AND (nvl(v_template_num_3, 0) = 9 OR nvl(v_template_num_3, 0) = 10)
    THEN
      -- Если третья ошибка округления зачтена на 9-ой или 10-ой проводке -
      -- учитываем ее на 13-ой проводке
      v_round_err := v_round_err - v_round_err_3;
    END IF;
    IF v_round_err != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err
            ,acc_amount   = acc_amount + v_round_err
       WHERE oper_id = v_oper_id_13;
    END IF;
    -- Прибавление ошибки округления к сумме 14 проводки:
    v_round_err := 0;
    IF v_round_err_1 != 0
       AND nvl(v_template_num, 0) = 5
    THEN
      -- Если первая ошибка округления зачтена на 5-ой проводке -
      -- учитываем ее на 14-ой проводке
      v_round_err := v_round_err_1;
    END IF;
    IF v_round_err_2 != 0
       AND nvl(v_template_num_2, 0) = 8
    THEN
      -- Если вторая ошибка округления зачтена на 8-ой проводке -
      -- учитываем ее на 14-ой проводке
      v_round_err := v_round_err - v_round_err_2;
    END IF;

    IF v_round_err_3 != 0
       AND nvl(v_template_num_3, 0) = 11
    THEN
      -- Если третья ошибка округления зачтена на 11-ой проводке -
      -- учитываем ее на 14-ой проводке
      v_round_err := v_round_err - v_round_err_3;
    END IF;
    IF v_round_err != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err
            ,acc_amount   = acc_amount + v_round_err
       WHERE oper_id = v_oper_id_14;
    END IF;
    -- Байтин А.
    -- Создание проводки по возмещению МедО
    IF v_medo_cost != 0
    THEN
      v_sum := v_medo_cost;
      run_template('QUIT_MAIN_19', NULL);
    END IF;
  EXCEPTION
    WHEN e_annul_check_failure THEN
      raise_application_error(-20001
                             ,'Для причины расторжения из группы "Аннулирование" должны быть ' ||
                              'равны нулю: ВС, ДИД, АДМ, Недоплата, Переплата');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Gen_Main_Trans_Group_1: ' || SQLERRM);
  END gen_main_trans_group_1;
  ----========================================================================----
  -- Генерация второй группы основных проводок по прекращению ДС - остальные
  PROCEDURE gen_main_trans_group_2(par_p_policy_id NUMBER) IS
    v_oper_id               NUMBER;
    v_ent_id                NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_debt_summ             NUMBER;
    v_income_tax_sum        NUMBER;
    v_overpayment           NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_admin_expenses        NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( Начисление выкупной суммы )
    v_sum_4                 NUMBER := 0; -- SUM( Начисление дополнительного инвестиционного дохода )
    v_sum_5                 NUMBER := 0; -- SUM( Начислен возврат СП при расторжении ДС )
    v_sum_6                 NUMBER := 0; -- SUM( Зачет ВС )
    v_sum_7                 NUMBER := 0; -- SUM( Зачтена выплата ДИД )
    v_sum_8                 NUMBER := 0; -- SUM( Зачтена выплата возв )
    v_sum_16                NUMBER := 0; -- SUM( Удержание Адм расходов по программе Защита )
    v_sum_17                NUMBER := 0; -- SUM( Переплата по договору )
    --
    v_sum_9         NUMBER;
    v_sum_10        NUMBER;
    v_sum_11        NUMBER;
    v_other_pol_sum NUMBER;
    --
    v_round_err         NUMBER;
    v_round_err_1       NUMBER;
    v_round_err_2       NUMBER;
    v_round_err_3       NUMBER;
    v_overpayment_round NUMBER; -- ошибка округления по переплате
    v_template_num_3    NUMBER;
    --
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    check_annul(par_p_policy_id);
    SELECT p.ent_id
          ,pd.medo_cost
          ,p.debt_summ
          ,pd.income_tax_sum
          ,pd.other_pol_sum
          ,pd.overpayment
      INTO v_ent_id
          ,v_medo_cost
          ,v_debt_summ
          ,v_income_tax_sum
          ,v_other_pol_sum
          ,v_overpayment
      FROM ven_p_policy  p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
           -- Байтин А.
          ,SUM(cd.admin_expenses)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
           --
          ,v_admin_expenses
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    -- 12 *** Удержан НДФЛ 77.00.14 68.02 Дата Начисления НДФЛ
    v_sum := ROUND(v_income_tax_sum, 2);
    IF nvl(v_sum, 0) != 0
    THEN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_12';
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                               ,p_document_id       => par_p_policy_id
                                               ,p_service_ent_id    => v_ent_id
                                               ,p_service_obj_id    => par_p_policy_id
                                               ,p_doc_status_ref_id => NULL
                                               ,p_is_accepted       => 1
                                               ,p_summ              => v_sum
                                               ,p_source            => 'INS');
    END IF;
    -- 15 *** Выплачено 77.00.02 51 Дата Выплаты
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) != 0
    THEN
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 3 *** Начисление выкупной суммы 22.05.31 77.00.14
        v_sum   := nvl(cover_rec.redemption_sum, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
        -- 4 *** Начисление дополнительного инвестиционного дохода 22.05.33 77.00.14
        v_sum   := nvl(cover_rec.add_invest_income, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
        -- 5 *** Начислен возврат СП при расторжении ДС 22.05.11 77.00.13
        v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
        -- 6 *** Зачет ВС 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.redemption_sum, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_6 := v_sum_6 + nvl(ROUND(v_sum, 2), 0);
        -- 7 *** Зачтена выплата ДИД 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.add_invest_income, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_7 := v_sum_7 + nvl(ROUND(v_sum, 2), 0);
        -- 8 *** Зачтена выплата возв 77.00.13 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.return_bonus_part, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_8 := v_sum_8 + nvl(ROUND(v_sum, 2), 0);
        -- 16 *** Удержание Адм расх по программе Защита 22.05.11 77.00.13
        v_sum    := ROUND(-cover_rec.admin_expenses, 2); -- с минусом!
        v_sum_16 := v_sum_16 + nvl(v_sum, 0);
        -- 17 *** Переплата по договору 77.01.03 77.00.13
        v_sum    := (nvl(v_overpayment, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0))) *
                    (nvl(cover_rec.redemption_sum, 0) + nvl(cover_rec.add_invest_income, 0) +
                    nvl(cover_rec.return_bonus_part, 0));
        v_sum_17 := v_sum_17 + nvl(ROUND(v_sum, 2), 0);
      END LOOP;
    ELSE
      v_sum_3  := 0;
      v_sum_4  := 0;
      v_sum_5  := 0;
      v_sum_6  := 0;
      v_sum_7  := 0;
      v_sum_8  := 0;
      v_sum_16 := 0;
      -- Байтин А.
      -- Если прочие суммы равны 0, переплата будет равна Итого к выплате
      --v_sum_17 := 0;
      v_sum_17 := (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0)) + nvl(v_overpayment, 0) - nvl(v_debt_summ, 0) -
                  nvl(v_medo_cost, 0) - nvl(v_admin_expenses, 0);

    END IF;
    -- 9 *** Зачет ВС (зачет на другой ДС) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_9 := nvl(v_other_pol_sum, 0) * v_sum_3 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_9 := ROUND(nvl(v_sum_9, 0), 2);
    -- 10 *** Зачтена выплата ДИД (зачет на другой ДС) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_10 := nvl(v_other_pol_sum, 0) * v_sum_4 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_10 := ROUND(nvl(v_sum_10, 0), 2);
    -- 11 *** Зачтена выплата возв (зачет на другой ДС) 77.00.13 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_11 := nvl(v_other_pol_sum, 0) * v_sum_5 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_11            := ROUND(nvl(v_sum_11, 0), 2);
    v_overpayment_round := nvl(get_round_4(par_p_policy_id), 0);
    v_sum               :=  -- *** Зачтена выплата ВС и ДИД (№13)
     v_sum_3 -- + SUM( Начисление выкупной суммы )
                           + v_sum_4 -- + SUM( Начисление дополнительного инвестиционного дохода )
                           - v_sum_6 -- - SUM( Зачет ВС )
                           - v_sum_7 -- - SUM( Зачтена выплата ДИД )
                           - v_sum_9 -- - Зачет ВС (зачет на другой ДС)
                           - v_sum_10 -- - Зачтена выплата ДИД (зачет на другой ДС)
                          -- - Удержан НДФЛ
                           - nvl(ROUND(v_income_tax_sum, 2), 0)
                          -- + *** Зачтена выплата возв 2 (№14)
                           + v_sum_5 -- + Начислен возврат СП при расторжении ДС
                           - v_sum_8 -- - Зачтена выплата возв
                           - v_sum_11 -- - Зачтена выплата возв (зачет на другой ДС)
                           + v_sum_16 -- + Удержание Адм расходов по программе Защита
                           + v_sum_17 -- + Переплата по договору
                           + v_overpayment_round; -- + Округление переплаты по договору
    IF ((v_sum_3 + v_sum_4 - v_sum_6 - v_sum_7 -- дополнительное условие
       - nvl(ROUND(v_income_tax_sum, 2), 0) - v_sum_9 - v_sum_10) > 0 OR
       ((v_sum_5 - v_sum_8 - v_sum_11 + v_sum_16 + v_sum_17 + v_overpayment_round) > 0))
    THEN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_15';
      -- Расчет ошибки округления
      v_round_err_1 := nvl(get_round_1(par_p_policy_id), 0);
      v_round_err_2 := nvl(get_round_2(par_p_policy_id), 0);
      get_round_3(par_p_policy_id, v_round_err_3, v_template_num_3);
      v_round_err := v_round_err_1 - v_round_err_2 - v_round_err_3;
      -- Сумма с учетом ошибки округления
      IF nvl(v_round_err, 0) != 0
      THEN
        v_sum := v_sum + v_round_err;
      END IF;
      IF nvl(v_sum, 0) != 0
      THEN
        v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                 ,p_document_id       => par_p_policy_id
                                                 ,p_service_ent_id    => v_ent_id
                                                 ,p_service_obj_id    => par_p_policy_id
                                                 ,p_doc_status_ref_id => NULL
                                                 ,p_is_accepted       => 1
                                                 ,p_summ              => v_sum
                                                 ,p_source            => 'INS');
      END IF;
    END IF;
    v_sum := -nvl(ROUND(v_income_tax_sum, 2), 0); -- - Удержан НДФЛ
    IF nvl(v_sum, 0) != 0
    THEN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_18';
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                               ,p_document_id       => par_p_policy_id
                                               ,p_service_ent_id    => v_ent_id
                                               ,p_service_obj_id    => par_p_policy_id
                                               ,p_doc_status_ref_id => NULL
                                               ,p_is_accepted       => 1
                                               ,p_summ              => v_sum
                                               ,p_source            => 'INS');
    END IF;
  EXCEPTION
    WHEN e_annul_check_failure THEN
      raise_application_error(-20001
                             ,'Для причины расторжения из группы "Аннулирование" должны быть ' ||
                              'равны нулю: ВС, ДИД, АДМ, Недоплата, Переплата');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Gen_Main_Trans_Group_2: ' || SQLERRM);
  END gen_main_trans_group_2;
  ----========================================================================----
  -- Генерация проводок по зачету на другой договор
  PROCEDURE gen_trans_setoff(par_doc_id NUMBER) IS
    v_policy_id             NUMBER;
    v_other_pol_sum         NUMBER;
    v_oper_id               NUMBER;
    v_ent_id                NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( Начисление выкупной суммы )
    v_sum_4                 NUMBER := 0; -- SUM( Начисление дополнительного инвестиционного дохода )
    v_sum_5                 NUMBER := 0; -- SUM( Начислен возврат СП при расторжении ДС )
    v_sum_9                 NUMBER := 0; -- Зачет ВС (зачет на другой ДС)
    v_sum_10                NUMBER := 0; -- Зачтена выплата ДИД (зачет на другой ДС)
    v_sum_11                NUMBER := 0; -- Зачтена выплата возв (зачет на другой ДС)
    v_continue              BOOLEAN := TRUE;
    --
    v_round_err       NUMBER;
    v_max_sum         NUMBER := 0; -- максимальная сумма по проводкам
    v_max_sum_oper_id NUMBER; -- ИД операции, соответствующей максимальной сумме
    --
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    SAVEPOINT gen_trans_setoff;
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'AC_PAYMENT';
    -- Найти версию ДС, к которой привязан зачет
    BEGIN
      SELECT dd.parent_id INTO v_policy_id FROM doc_doc dd WHERE dd.child_id = par_doc_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_continue := FALSE;
    END;
    check_annul(v_policy_id);
    -- Проводки генерятся только для зачета на другой договор при прекращении ДС:
    IF NOT
        doc.get_doc_status_brief(v_policy_id) IN ('TO_QUIT'
                                                 ,'TO_QUIT_CHECK_READY'
                                                 ,'TO_QUIT_CHECKED'
                                                 ,'QUIT_REQ_QUERY'
                                                 ,'QUIT_REQ_GET'
                                                 ,'QUIT_TO_PAY'
                                                 ,'QUIT')
    THEN
      v_continue := FALSE;
    END IF;
    -- *** Данные для проводок
    IF v_continue
    THEN
      BEGIN
        -- Сумма зачета
        SELECT SUM(a.amount) setoff_amount
          INTO v_other_pol_sum
          FROM ac_payment a
         WHERE a.payment_id = par_doc_id;
        IF nvl(v_other_pol_sum, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    IF v_continue
    THEN
      BEGIN
        -- Данные по прекращению ДС
        SELECT pd.medo_cost
          INTO v_medo_cost
          FROM ven_p_policy  p
              ,p_pol_decline pd
         WHERE p.policy_id = v_policy_id
           AND p.policy_id = pd.p_policy_id;
        -- Данные по застрахованным и программам
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
              ,SUM(cd.return_bonus_part)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
              ,v_sum_return_bonus_part
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = v_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    IF v_continue
    THEN
      BEGIN
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) != 0
        THEN
          FOR cover_rec IN cover_curs(v_policy_id)
          LOOP
            -- 3 *** Начисление выкупной суммы 22.05.31 77.00.14
            v_sum   := nvl(cover_rec.redemption_sum, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
            -- 4 *** Начисление дополнительного инвестиционного дохода 22.05.33 77.00.14
            v_sum   := nvl(cover_rec.add_invest_income, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
            -- 5 *** Начислен возврат СП при расторжении ДС 22.05.11 77.00.13
            v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
          END LOOP;
        ELSE
          v_sum_3 := 0;
          v_sum_4 := 0;
          v_sum_5 := 0;
        END IF;
        -- 9 *** Зачет ВС (зачет на другой ДС) 77.00.14 77.08.03
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
        THEN
          v_sum := nvl(v_other_pol_sum, 0) * v_sum_3 /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        END IF;
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_9';
          v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                   ,p_document_id       => par_doc_id
                                                   ,p_service_ent_id    => v_ent_id
                                                   ,p_service_obj_id    => par_doc_id
                                                   ,p_doc_status_ref_id => NULL
                                                   ,p_is_accepted       => 1
                                                   ,p_summ              => v_sum
                                                   ,p_source            => 'INS');
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
          END IF;
          v_sum_9 := v_sum;
        END IF;
        -- 10 *** Зачтена выплата ДИД (зачет на другой ДС) 77.00.14 77.08.03
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
        THEN
          v_sum := nvl(v_other_pol_sum, 0) * v_sum_4 /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        END IF;
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_10';
          v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                   ,p_document_id       => par_doc_id
                                                   ,p_service_ent_id    => v_ent_id
                                                   ,p_service_obj_id    => par_doc_id
                                                   ,p_doc_status_ref_id => NULL
                                                   ,p_is_accepted       => 1
                                                   ,p_summ              => v_sum
                                                   ,p_source            => 'INS');
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
          END IF;
          v_sum_10 := v_sum;
        END IF;
        -- 11 *** Зачтена выплата возв (зачет на другой ДС) 77.00.13 77.08.03
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
        THEN
          v_sum := nvl(v_other_pol_sum, 0) * v_sum_5 /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        END IF;
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_11';
          v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                   ,p_document_id       => par_doc_id
                                                   ,p_service_ent_id    => v_ent_id
                                                   ,p_service_obj_id    => par_doc_id
                                                   ,p_doc_status_ref_id => NULL
                                                   ,p_is_accepted       => 1
                                                   ,p_summ              => v_sum
                                                   ,p_source            => 'INS');
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
          END IF;
          v_sum_11 := v_sum;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    -- 3) Округление зачета на новый договор:
    -- Полученная сумма прибавляется к максимальной сумме проводки по шаблонам:
    -- Зачет ВС (Зачет на другой  ДС), Зачтена выплата ДИД (Зачет на другой  ДС),
    -- Зачтена выплата возв (Зачет на другой  ДС).
    -- Алгоритм расчета: Округление зачета в счет другого договора =
    -- (значение поля "Сумма зачета на другой договор") -
    -- ? Шаблон "Зачет ВС (Зачет на другой  ДС)" -
    -- ? Шаблон "Зачтена выплата ДИД (Зачет на другой  ДС)" -
    -- ? Шаблон "Зачтена выплата возв (Зачет на другой  ДС)"
    IF v_continue
    THEN
      -- Расчет ошибки округления
      v_round_err := nvl(v_other_pol_sum, 0) -- Сумма зачета на другой договор
                     - nvl(v_sum_9, 0) -- Зачет ВС (зачет на другой ДС)
                     - nvl(v_sum_10, 0) -- Зачтена выплата ДИД (зачет на другой ДС)
                     - nvl(v_sum_11, 0); -- Зачтена выплата возв (зачет на другой ДС)
      IF v_max_sum_oper_id IS NOT NULL
         AND v_round_err != 0
      THEN
        UPDATE trans
           SET trans_amount = trans_amount + v_round_err
              ,acc_amount   = acc_amount + v_round_err
         WHERE oper_id = v_max_sum_oper_id;
      END IF;
    END IF;
    IF NOT v_continue
    THEN
      ROLLBACK TO gen_trans_setoff;
    END IF;
  EXCEPTION
    WHEN e_annul_check_failure THEN
      raise_application_error(-20001
                             ,'Для причины расторжения из группы "Аннулирование" должны быть ' ||
                              'равны нулю: ВС, ДИД, АДМ, Недоплата, Переплата');
    WHEN OTHERS THEN
      ROLLBACK TO gen_trans_setoff;
      raise_application_error(-20001, 'Gen_Trans_Setoff: ' || SQLERRM);
  END gen_trans_setoff;
  ----========================================================================----
  -- Удалить неоплаченные счета
  PROCEDURE delete_unpayed_acc(par_p_policy_id NUMBER) IS
    v_deleted       NUMBER;
    v_pol_header_id NUMBER;
    v_decline_date  DATE;
    v_act_date      DATE;
    v_date          DATE;
  BEGIN
    SELECT p.pol_header_id
          ,p.decline_date
          ,pd.act_date
      INTO v_pol_header_id
          ,v_decline_date
          ,v_act_date
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = pd.p_policy_id
       AND p.policy_id = par_p_policy_id;
    IF decline_reason_is_annul(par_p_policy_id) = 1
    THEN
      v_date := v_act_date;
    ELSE
      v_date := v_decline_date;
    END IF;
    FOR rc IN (SELECT ap.payment_id
                     ,ap.amount
                     ,dt.brief
                 FROM p_policy       p
                     ,ven_ac_payment ap
                     ,doc_doc        dd
                     ,doc_templ      dt
                WHERE p.pol_header_id = v_pol_header_id
                  AND dd.child_id = ap.payment_id
                  AND dd.parent_id = p.policy_id
                  AND dt.doc_templ_id = ap.doc_templ_id
                  AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
                     -- 17.01.2011 ishch. Удаляются ЭПГ после даты расторжения,
                     -- т.е. с даты, следующей за датой расторжения
                     --AND ap.due_date > v_decline_date
                     -- 27.01.2011 ishch. Удаляются ЭПГ после даты акта
                     -- 28.01.2011 ishch. Для аннулирования - дата акта
                     -- для прекращения - дата прекращения
                  AND ap.due_date > v_date)
    LOOP
      v_deleted := pkg_payment.delete_payment(rc.payment_id, rc.brief, rc.amount);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Delete_Unpayed_Acc: ' || SQLERRM);
  END delete_unpayed_acc;
  ----========================================================================----
  -- Проверка: в форме корректировки проводок не должено быть строк со статусом
  -- "Проект"
  PROCEDURE check_fix_trans_status(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_num
      FROM p_pol_decline   pd
          ,p_trans_decline td
     WHERE pd.p_policy_id = par_policy_id
       AND pd.p_pol_decline_id = td.p_pol_decline_id
       AND doc.get_doc_status_brief(td.p_trans_decline_id, SYSDATE) = 'PROJECT';
    IF nvl(v_num, 0) > 0
    THEN
      v_msg := 'Для этого перехода в форме корректировки проводок ' ||
               'не должено быть строк со статусом "Проект"';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Check_Fix_Trans_Status: ' || SQLERRM);
  END check_fix_trans_status;
  ----========================================================================----
  -- Удаление / сторнирование первой группы основных проводок по прекращению ДС -
  -- ( по дате акта )
  PROCEDURE del_main_trans_group_1(par_p_policy_id NUMBER) IS
    CURSOR trans_curs(pcurs_p_policy_id NUMBER) IS
      SELECT o.oper_id
            ,
             --t.is_closed,
             pkg_period_closed.check_date_in_closed(t.trans_date) is_closed
            , --273031: Изменение триггера контроля закрытого периода /Чирков/
             t.trans_date
        FROM oper  o
            ,trans t
       WHERE o.document_id = pcurs_p_policy_id
         AND t.oper_id = o.oper_id
         AND o.oper_templ_id IN (SELECT oper_templ_id
                                   FROM oper_templ
                                  WHERE brief IN ('QUIT_MAIN_1'
                                                 , -- Корректировка Начисленной премии к списанию прошлых лет 91.02 77.01.01
                                                  'QUIT_MAIN_2'
                                                 , -- Сторно Начисленной премии к списанию текущего года 77.01.01 92.01
                                                  'QUIT_MAIN_3'
                                                 , -- Начисление выкупной суммы 22.05.31 77.00.14
                                                  'QUIT_MAIN_4'
                                                 , -- Начисление дополнительного инвестиционного дохода 22.05.33 77.00.14
                                                  'QUIT_MAIN_5'
                                                 , -- Начислен возврат СП при расторжении ДС 22.05.11 77.00.13
                                                  'QUIT_MAIN_5_ANNUL'
                                                 , -- Начислен возврат СП при расторжении ДС (для аннулирования) 77.01.01 77.00.13
                                                  'QUIT_MAIN_6'
                                                 , -- Зачет ВС 77.00.14 77.01.03
                                                  'QUIT_MAIN_7'
                                                 , -- Зачтена выплата ДИД 77.00.14 77.01.03
                                                  'QUIT_MAIN_8'
                                                 , -- Зачтена выплата возв 77.00.13 77.01.03
                                                  'QUIT_MAIN_16'
                                                 , -- Удержание Адм расх по программе Защита 22.05.11 77.00.13
                                                  'QUIT_MAIN_17'
                                                 , -- Переплата по договору 77.01.03 77.00.13
                                                  'QUIT_MAIN_13'
                                                 , -- Зачтена выплата ВС и ДИД 77.00.14 77.00.02
                                                  'QUIT_MAIN_14' -- Зачтена выплата возв 2 77.00.13 77.00.02
                                                  -- Байтин А.
                                                  -- Добавил новый шаблон
                                                 ,'QUIT_MAIN_19' -- Возмещение МедО 77.01.01 91.01.19
                                                  ))
            -- Исправил ошибку, когда уже сторнированные проводки сторнировались еще раз
         AND NOT EXISTS (SELECT NULL
                FROM trans tr
                    ,oper  op
               WHERE tr.oper_id = op.oper_id
                 AND op.document_id = o.document_id
                 AND tr.note = 'Сторно проводки: ' || to_char(t.trans_id));
  BEGIN
    -- Учитывается соотношение: одна операция - одна проводка
    FOR trans_rec IN trans_curs(par_p_policy_id)
    LOOP
      IF trans_rec.is_closed = 1
      THEN
        -- Сторнирование
        acc_new.storno_trans(trans_rec.oper_id);
      ELSE
        -- Удаление
        DELETE FROM oper WHERE oper_id = trans_rec.oper_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Del_Main_Trans_Group_1: ' || SQLERRM);
  END del_main_trans_group_1;
  ----========================================================================----
  -- Удаление / сторнирование второй группы основных проводок по прекращению ДС -
  -- ( остальные )
  PROCEDURE del_main_trans_group_2(par_p_policy_id NUMBER) IS
    CURSOR trans_curs(pcurs_p_policy_id NUMBER) IS
      SELECT o.oper_id
            ,
             --t.is_closed,
             pkg_period_closed.check_date_in_closed(t.trans_date) is_closed
            , --273031: Изменение триггера контроля закрытого периода /Чирков/
             t.trans_date
        FROM oper  o
            ,trans t
       WHERE o.document_id = pcurs_p_policy_id
         AND t.oper_id = o.oper_id
         AND o.oper_templ_id IN (SELECT oper_templ_id
                                   FROM oper_templ
                                  WHERE brief IN ('QUIT_MAIN_12'
                                                 , -- Удержан НДФЛ 77.00.14 68.02 Дата Начисления НДФЛ
                                                  'QUIT_MAIN_15'
                                                 , -- Выплачено 77.00.02 51 Дата Выплаты
                                                  'QUIT_MAIN_18' -- Промежуточная к оплате НДФЛ
                                                  ))
            -- Байтин А.
            -- Исправил ошибку, когда уже сторнированные проводки сторнировались еще раз
         AND NOT EXISTS (SELECT NULL
                FROM trans tr
                    ,oper  op
               WHERE tr.oper_id = op.oper_id
                 AND op.document_id = o.document_id
                 AND tr.note = 'Сторно проводки: ' || to_char(t.trans_id));
  BEGIN
    -- Учитывается соотношение: одна операция - одна проводка
    FOR trans_rec IN trans_curs(par_p_policy_id)
    LOOP
      IF trans_rec.is_closed = 1
      THEN
        -- Сторнирование
        acc_new.storno_trans(trans_rec.oper_id);
      ELSE
        -- Удаление
        DELETE FROM oper WHERE oper_id = trans_rec.oper_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Del_Main_Trans_Group_2: ' || SQLERRM);
  END del_main_trans_group_2;
  ----========================================================================----
  -- Функция возвращает программу ( риск ) для проводки
  FUNCTION get_trans_plo_desc(p_trans_id NUMBER) RETURN VARCHAR2 IS
    CURSOR trans_curs(pcurs_trans_id NUMBER) IS
      SELECT obj_ure_id
            ,obj_uro_id
            ,a1_dt_ure_id
            ,a1_dt_uro_id
            ,a1_ct_ure_id
            ,a1_ct_uro_id
            ,a2_dt_ure_id
            ,a2_dt_uro_id
            ,a2_ct_ure_id
            ,a2_ct_uro_id
            ,a3_dt_ure_id
            ,a3_dt_uro_id
            ,a3_ct_ure_id
            ,a3_ct_uro_id
            ,a4_dt_ure_id
            ,a4_dt_uro_id
            ,a4_ct_ure_id
            ,a4_ct_uro_id
            ,a5_dt_ure_id
            ,a5_dt_uro_id
            ,a5_ct_ure_id
            ,a5_ct_uro_id
        FROM trans
       WHERE trans_id = pcurs_trans_id;
    v_obj_ure_id   NUMBER;
    v_obj_uro_id   NUMBER;
    v_a1_dt_ure_id NUMBER;
    v_a1_dt_uro_id NUMBER;
    v_a1_ct_ure_id NUMBER;
    v_a1_ct_uro_id NUMBER;
    v_a2_dt_ure_id NUMBER;
    v_a2_dt_uro_id NUMBER;
    v_a2_ct_ure_id NUMBER;
    v_a2_ct_uro_id NUMBER;
    v_a3_dt_ure_id NUMBER;
    v_a3_dt_uro_id NUMBER;
    v_a3_ct_ure_id NUMBER;
    v_a3_ct_uro_id NUMBER;
    v_a4_dt_ure_id NUMBER;
    v_a4_dt_uro_id NUMBER;
    v_a4_ct_ure_id NUMBER;
    v_a4_ct_uro_id NUMBER;
    v_a5_dt_ure_id NUMBER;
    v_a5_dt_uro_id NUMBER;
    v_a5_ct_ure_id NUMBER;
    v_a5_ct_uro_id NUMBER;
    v_cover_ent_id NUMBER;
    v_plo_ent_id   NUMBER;
    v_cover_id     NUMBER;
    v_plo_id       NUMBER;
    v_return       VARCHAR2(255) := '';
  BEGIN
    SELECT ent_id INTO v_cover_ent_id FROM entity WHERE brief = 'P_COVER';
    SELECT ent_id INTO v_plo_ent_id FROM entity WHERE brief = 'T_PROD_LINE_OPTION';
    OPEN trans_curs(p_trans_id);
    FETCH trans_curs
      INTO v_obj_ure_id
          ,v_obj_uro_id
          ,v_a1_dt_ure_id
          ,v_a1_dt_uro_id
          ,v_a1_ct_ure_id
          ,v_a1_ct_uro_id
          ,v_a2_dt_ure_id
          ,v_a2_dt_uro_id
          ,v_a2_ct_ure_id
          ,v_a2_ct_uro_id
          ,v_a3_dt_ure_id
          ,v_a3_dt_uro_id
          ,v_a3_ct_ure_id
          ,v_a3_ct_uro_id
          ,v_a4_dt_ure_id
          ,v_a4_dt_uro_id
          ,v_a4_ct_ure_id
          ,v_a4_ct_uro_id
          ,v_a5_dt_ure_id
          ,v_a5_dt_uro_id
          ,v_a5_ct_ure_id
          ,v_a5_ct_uro_id;
    CLOSE trans_curs;
    IF v_obj_ure_id = v_cover_ent_id
       AND v_obj_uro_id IS NOT NULL
    THEN
      v_cover_id := v_obj_uro_id;
      --
    ELSIF v_a1_dt_ure_id = v_plo_ent_id
          AND v_a1_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a1_dt_uro_id;
    ELSIF v_a2_dt_ure_id = v_plo_ent_id
          AND v_a2_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a2_dt_uro_id;
    ELSIF v_a3_dt_ure_id = v_plo_ent_id
          AND v_a3_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a3_dt_uro_id;
    ELSIF v_a4_dt_ure_id = v_plo_ent_id
          AND v_a4_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a4_dt_uro_id;
    ELSIF v_a5_dt_ure_id = v_plo_ent_id
          AND v_a5_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a5_dt_uro_id;
      --
    ELSIF v_a1_ct_ure_id = v_plo_ent_id
          AND v_a1_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a1_ct_uro_id;
    ELSIF v_a2_ct_ure_id = v_plo_ent_id
          AND v_a2_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a2_ct_uro_id;
    ELSIF v_a3_ct_ure_id = v_plo_ent_id
          AND v_a3_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a3_ct_uro_id;
    ELSIF v_a4_ct_ure_id = v_plo_ent_id
          AND v_a4_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a4_ct_uro_id;
    ELSIF v_a5_ct_ure_id = v_plo_ent_id
          AND v_a5_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a5_ct_uro_id;
      --
    ELSIF v_a1_dt_ure_id = v_cover_ent_id
          AND v_a1_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a1_dt_uro_id;
    ELSIF v_a2_dt_ure_id = v_cover_ent_id
          AND v_a2_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a2_dt_uro_id;
    ELSIF v_a3_dt_ure_id = v_cover_ent_id
          AND v_a3_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a3_dt_uro_id;
    ELSIF v_a4_dt_ure_id = v_cover_ent_id
          AND v_a4_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a4_dt_uro_id;
    ELSIF v_a5_dt_ure_id = v_cover_ent_id
          AND v_a5_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a5_dt_uro_id;
      --
    ELSIF v_a1_ct_ure_id = v_cover_ent_id
          AND v_a1_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a1_ct_uro_id;
    ELSIF v_a2_ct_ure_id = v_cover_ent_id
          AND v_a2_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a2_ct_uro_id;
    ELSIF v_a3_ct_ure_id = v_cover_ent_id
          AND v_a3_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a3_ct_uro_id;
    ELSIF v_a4_ct_ure_id = v_cover_ent_id
          AND v_a4_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a4_ct_uro_id;
    ELSIF v_a5_ct_ure_id = v_cover_ent_id
          AND v_a5_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a5_ct_uro_id;
    END IF;
    IF v_plo_id IS NOT NULL
    THEN
      SELECT description INTO v_return FROM t_prod_line_option WHERE id = v_plo_id;
    ELSIF v_cover_id IS NOT NULL
    THEN
      SELECT plo.description
        INTO v_return
        FROM t_prod_line_option plo
            ,p_cover            c
       WHERE c.p_cover_id = v_cover_id
         AND c.t_prod_line_option_id = plo.id;
    END IF;
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);
  END get_trans_plo_desc;
  ----========================================================================----
  /*
    Байтин А.
    Проверка суммы сальдо по счетам: '22.05','22.01','22.05.01','22.05.02','22.05.11','22.05.31','22.05.33',
                                     '77.00.01','77.00.02','77.08.03','91.01','91.02','92.01'
    Если сальдо отличается от 0, выдается сообщение об этом, с указанием суммы
    В Borlas: "Прекращение ДС. Проверка сальдо"

    par_policy_id - ИД версии ДС
  */
  /*  PROCEDURE check_saldo(par_policy_id NUMBER) IS
      v_pol_header_id NUMBER;
      v_result        NUMBER;
    BEGIN
      SELECT pp.pol_header_id INTO v_pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;

      SELECT nvl(SUM(acc_amount), 0)
        INTO v_result
        FROM ( -- Проводки привязанные через риски
              SELECT tr.trans_amount AS acc_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND tr.obj_uro_id = pc.p_cover_id
                 AND tr.obj_ure_id = pc.ent_id
                 AND tr.dt_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id
              UNION ALL
              SELECT -tr.trans_amount AS acc_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND tr.obj_uro_id = pc.p_cover_id
                 AND tr.obj_ure_id = pc.ent_id
                 AND tr.ct_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id
              UNION ALL
              -- Проводки, привязанные через версию (прекращение)
              SELECT tr.trans_amount
                FROM trans    tr
                     ,p_policy p
                     ,account  ac
               WHERE p.pol_header_id = v_pol_header_id
                 AND tr.dt_account_id = ac.account_id
                 AND tr.obj_ure_id = 283
                 AND tr.obj_uro_id = p.policy_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
              UNION ALL
              SELECT -tr.trans_amount
                FROM trans    tr
                     ,p_policy p
                     ,account  ac
               WHERE p.pol_header_id = v_pol_header_id
                 AND tr.ct_account_id = ac.account_id
                 AND tr.obj_ure_id = 283
                 AND tr.obj_uro_id = p.policy_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
              UNION ALL
              -- Проводки, привязанные через ущерб
              SELECT tr.trans_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
                     ,c_damage   dm
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND pc.p_cover_id = dm.p_cover_id
                 AND tr.obj_uro_id = dm.c_damage_id
                 AND tr.obj_ure_id = dm.ent_id
                 AND tr.dt_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id
              UNION ALL
              SELECT -tr.trans_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
                     ,c_damage   dm
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND pc.p_cover_id = dm.p_cover_id
                 AND tr.obj_uro_id = dm.c_damage_id
                 AND tr.obj_ure_id = dm.ent_id
                 AND tr.ct_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id);
      IF v_result != 0
      THEN
        raise_application_error(-20001
                               ,'Сумма сальдо по счетам: 22.05,22.01,22.05.01,22.05.02,22.05.11,22.05.31,22.05.33' ||
                                ',77.00.01,77.00.02,77.08.03,91.01,91.02,92.01,91.01.19,77.07.01 равна ' ||
                                to_char(v_result));
      END IF;
    END check_saldo;
  */

  /**
  * Прекращение ДС. Корректировка сальдо по договору
  * К прекращению. Готов для проверки - К прекращению. Проверен
  * Процедура определяет оставшееся сальдо по договору и создает проводки, чтобу избавиться от него
  * К сожалению таким образом мы никогда не знаем, был ли корректно расчитан договор т.к. всегда тупо
  * сводим сальдо в ноль
  * @author Капля П.
  * @param par_policy_id - ИД версии прекращения
  */
  PROCEDURE correct_saldo_on_quit(par_policy_id NUMBER) IS
    v_pol_header_id     NUMBER;
    v_dummy             NUMBER;
    v_doc_status_ref_id NUMBER;
    v_amount            NUMBER;
    c_positive_saldo_ot_id CONSTANT NUMBER := dml_oper_templ.get_id_by_brief('Коррект.полож.прем.прошл.лет');
    c_negative_saldo_ot_id CONSTANT NUMBER := dml_oper_templ.get_id_by_brief('Коррект.отриц.прем.прошл.лет');
  BEGIN
    v_pol_header_id     := pkg_policy.get_policy_header_id(par_policy_id);
    v_doc_status_ref_id := doc.get_last_doc_status_ref_id(par_policy_id);

    -- В комментариях указаны ИД шаблонов. Знаками вопроса помечены ИД на тестовом сервере.
    -- Их в дальнейшем нужно будет заменить на нормальные
    FOR rec IN (SELECT MAX(pc.p_cover_id) p_cover_id
                      ,SUM(t.acc_amount *
                           -- Шаблоны, которые уменьшают начисление
                           CASE
                             WHEN tt.brief IN ('СтраховаяПремияОплачена' --44
                                              ,'УдержКВ' --47
                                              ,'СтраховаяПремияАвансОпл' --741
                                              ,'QUIT_MAIN_6' --810
                                              ,'QUIT_MAIN_7' --811
                                              ,'QUIT_MAIN_8' --812
                                              ,'QUIT_MAIN_5_ANNUL' --861
                                              --,'QUIT_MAIN_5' --809
                                               )

                              THEN
                              -1
                             ELSE
                              1
                           END *
                           -- Проводки хранятся с обратным знам, поэтому их надо привести к обратному знаку, чтобы правильно учеть
                           CASE
                             WHEN
                              tt.brief IN ('Storno.NachPrem' --782
                                          ,'QUIT_MAIN_1' --805
                                          ,'QUIT_FIX_33' --849
                                          ,'QUIT_MAIN_5_ANNUL' --861
                                          --,'QUIT_MAIN_5' --809
                                          ,'Прекращение.КоррНеоплПремПрошлыхЛет' --1037??
                                          ,'Прекращение.КоррНачПремНУНОБ' --1039??
                                           ) THEN
                              -1
                             ELSE
                              1
                           END) AS amount
                  FROM trans_templ  tt
                      ,trans        t
                      ,oper         o
                      ,oper_templ   ot
                      ,p_policy     pp
                      ,as_asset     aa
                      ,p_cover      pc
                      ,v_pol_issuer pi
                 WHERE (tt.brief IN ('QUIT_FIX_33' --849
                                    ,'QUIT_MAIN_1' --805
                                    ,'QUIT_MAIN_17 ' --821
                                    ,'QUIT_MAIN_2' --806
                                    --,'QUIT_MAIN_5' --809
                                    ,'QUIT_MAIN_5_ANNUL' --861
                                    ,'QUIT_MAIN_6' --810
                                    ,'QUIT_MAIN_7' --811
                                    ,'QUIT_MAIN_8' --812
                                    ,'Storno.NachPrem' --782
                                    ,'НачПремия' --21
                                    ,'НачПремияПрЛет ' --848
                                    ,'СтраховаяПремияАвансОпл' --741
                                    ,'УдержКВ' --47
                                    ,'Прекращение.КоррНеоплПремПрошлыхЛет' --1037??
                                    ,'Прекращение.КоррНеоплПремТекГода' --1038??
                                    ,'Прекращение.КоррНачПремНУНОБ' --1039??
                                     ) OR
                       tt.brief = 'СтраховаяПремияОплачена' --44
                       AND
                       t.dt_account_id = (SELECT a.account_id FROM account a WHERE a.num = '77.00.01') AND
                       t.ct_account_id = (SELECT a.account_id FROM account a WHERE a.num = '77.01.02'))
                   AND tt.trans_templ_id = t.trans_templ_id
                   AND t.oper_id = o.oper_id
                   AND o.oper_templ_id = ot.oper_templ_id
                   AND t.a5_ct_ure_id = 305
                   AND t.a5_ct_uro_id = pc.p_cover_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND aa.p_policy_id = pp.policy_id
                   AND pp.policy_id = pi.policy_id
                   AND pp.pol_header_id = v_pol_header_id
                 GROUP BY pc.t_prod_line_option_id
                         ,aa.p_asset_header_id)
    LOOP
      IF rec.amount < 0
      THEN
        --Дт 77.01.01 Кт 91.01
        v_dummy := acc_new.run_oper_by_template(c_negative_saldo_ot_id
                                               ,par_policy_id
                                               ,dml_p_cover.get_entity_id
                                               ,rec.p_cover_id
                                               ,v_doc_status_ref_id
                                               ,1
                                               ,rec.amount * -1);
      ELSIF rec.amount > 0
      THEN
        --Дт 91.02 Кт 77.01.01
        v_dummy := acc_new.run_oper_by_template(c_positive_saldo_ot_id
                                               ,par_policy_id
                                               ,dml_p_cover.get_entity_id
                                               ,rec.p_cover_id
                                               ,v_doc_status_ref_id
                                               ,1
                                               ,rec.amount);
      END IF;

    END LOOP;
  END correct_saldo_on_quit;
  /*
    Байтин А.
    Проверка существования проводок по счетам 22.01, 22.05.01, 22.05.02 и выдача сообщения об ошибке,
    если такие проводки существуют.
    par_policy_id - ИД версии договора страхования
  */
  PROCEDURE check_accounts(par_policy_id NUMBER) IS
    v_cnt           NUMBER;
    v_pol_header_id NUMBER;
    v_policy_ent_id NUMBER;
  BEGIN
    SELECT pp.pol_header_id INTO v_pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;

    BEGIN
      SELECT e.ent_id
        INTO v_policy_ent_id
        FROM entity e
       WHERE e.brief = 'P_POLICY'
         AND e.schema_name = 'INS';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Отсутствует запись с сокращенным наименованием "P_POLICY" в справочнике сущностей!');
    END;

    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS ( -- Проводки привязанные через риски
            SELECT tr.trans_amount AS acc_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND tr.obj_uro_id = pc.p_cover_id
               AND tr.obj_ure_id = pc.ent_id
               AND tr.dt_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id
            UNION ALL
            SELECT -tr.trans_amount AS acc_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND tr.obj_uro_id = pc.p_cover_id
               AND tr.obj_ure_id = pc.ent_id
               AND tr.ct_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id
            UNION ALL
            -- Проводки, привязанные через версию (прекращение)
            SELECT tr.trans_amount
              FROM trans    tr
                   ,p_policy p
                   ,account  ac
             WHERE p.pol_header_id = v_pol_header_id
               AND tr.dt_account_id = ac.account_id
               AND tr.obj_ure_id = v_policy_ent_id
               AND tr.obj_uro_id = p.policy_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
            UNION ALL
            SELECT -tr.trans_amount
              FROM trans    tr
                   ,p_policy p
                   ,account  ac
             WHERE p.pol_header_id = v_pol_header_id
               AND tr.ct_account_id = ac.account_id
               AND tr.obj_ure_id = v_policy_ent_id
               AND tr.obj_uro_id = p.policy_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
            UNION ALL
            -- Проводки, привязанные через ущерб
            SELECT tr.trans_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
                   ,c_damage   dm
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = dm.p_cover_id
               AND tr.obj_uro_id = dm.c_damage_id
               AND tr.obj_ure_id = dm.ent_id
               AND tr.dt_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id
            UNION ALL
            SELECT -tr.trans_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
                   ,c_damage   dm
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = dm.p_cover_id
               AND tr.obj_uro_id = dm.c_damage_id
               AND tr.obj_ure_id = dm.ent_id
               AND tr.ct_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id);

    -- Если найдены такие проводки, выводим ошибку
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'Существуют проводки по счетам 22.01, 22.05.01 и 22.05.02. Проверьте их корректность.');
    END IF;
  END check_accounts;

  /*
    Байтин А.
    Отмена закрытых корректируюих проводок--, не связанных с проводками
    par_policy_id - ИД версии договора страхования
  */
  PROCEDURE cancel_corr_trans(par_policy_id NUMBER) IS
    v_sysdate DATE := SYSDATE;
  BEGIN
    FOR r_trans IN (SELECT td.p_trans_decline_id
                      FROM p_trans_decline td
                          ,p_pol_decline   pd
                     WHERE td.p_pol_decline_id = pd.p_pol_decline_id
                       AND pd.p_policy_id = par_policy_id
                       AND doc.get_doc_status_brief(td.p_trans_decline_id) = 'CLOSE'
                    /*and not exists (select null
                       from oper op
                      where td.p_trans_decline_id = op.document_id
                    )*/
                    )
    LOOP
      doc.set_doc_status(r_trans.p_trans_decline_id, 'CANCEL', v_sysdate);
      v_sysdate := v_sysdate + INTERVAL '1' SECOND;
    END LOOP;
  END cancel_corr_trans;

  /*
    Байтин А.
    Добавление корректирующей проводки

    par_pol_decline_id   - ИД данных по расторжению версии ДС
    par_p_cover_id       - ИД покрытия
    par_oper_templ_brief - Сокращение шаблона проводки
    par_doc_templ_brief  - Сокращение шаблона документа
    par_trans_sum        - Сумма проводки
    par_trans_date       - Дата проводки
    par_status_date      - Дата перевода статуса
    par_trans_id         - ИД созданной проводки (выходной)
  */
  PROCEDURE insert_corr_trans
  (
    par_pol_decline_id   NUMBER
   ,par_p_cover_id       NUMBER
   ,par_oper_templ_brief VARCHAR2
   ,par_doc_templ_brief  VARCHAR2
   ,par_trans_sum        NUMBER
   ,par_trans_date       DATE
   ,par_status_date      DATE DEFAULT SYSDATE
   ,par_trans_id         OUT NUMBER
  ) IS
    v_oper_templ_id oper_templ.oper_templ_id%TYPE;
    v_doc_templ_id  doc_templ.doc_templ_id%TYPE;
  BEGIN
    IF par_trans_sum != 0
    THEN
      -- Получение ИД шаблона операции
      SELECT ot.oper_templ_id
        INTO v_oper_templ_id
        FROM oper_templ ot
       WHERE ot.brief = par_oper_templ_brief;

      -- Получение ИД шаблона документа
      SELECT doc_templ_id INTO v_doc_templ_id FROM doc_templ WHERE brief = par_doc_templ_brief;
      -- Добавление проводки
      SELECT sq_document.nextval INTO par_trans_id FROM dual;
      INSERT INTO ven_p_trans_decline
        (p_trans_decline_id
        ,p_pol_decline_id
        ,p_cover_id
        ,oper_templ_id
        ,trans_sum
        ,trans_date
        ,doc_templ_id)
      VALUES
        (par_trans_id
        ,par_pol_decline_id
        ,par_p_cover_id
        ,v_oper_templ_id
        ,par_trans_sum
        ,par_trans_date
        ,v_doc_templ_id);
      -- Изменение статуса на "Проект"
      doc.set_doc_status(par_trans_id, 'PROJECT', par_status_date);
    END IF;
  END insert_corr_trans;

  /*
    Байтин А.
    Проверка наличия платежного требования при переводе ДС в статус "Прекращен. К выплате"
    В Borlas: "Прекращение ДС. Проверка наличия платежного требования"
    par_p_policy_id - ID версии ДС
  */
  PROCEDURE check_payment_request(par_p_policy_id NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ac_payment       ac
                  ,ac_payment_templ act
                  ,document         doc
                  ,doc_templ        dt
                  ,doc_doc          dd
             WHERE dd.parent_id = par_p_policy_id
               AND ac.payment_id = dd.child_id
               AND ac.payment_id = doc.document_id
               AND doc.doc_templ_id = dt.doc_templ_id
               AND ac.payment_templ_id = act.payment_templ_id
               AND act.brief = 'PAYREQ'
               AND dt.brief = 'PAYREQ');
    IF v_cnt = 0
    THEN
      raise_application_error(-20001
                             ,'Не найдено ни одного платежного требования!');
    END IF;
  END check_payment_request;

  /**
   * Создание платежного требованния, если его нет (на переходе статусов "Прекращен. Первизиты получены"-"Прекращен. К выплате"
   * @author  Черных М. 30.1.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE create_payment_request(par_p_policy_id NUMBER) IS
    v_cnt        NUMBER;
    v_payment_id NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ac_payment       ac
                  ,ac_payment_templ act
                  ,document         doc
                  ,doc_templ        dt
                  ,doc_doc          dd
             WHERE dd.parent_id = par_p_policy_id
               AND ac.payment_id = dd.child_id
               AND ac.payment_id = doc.document_id
               AND doc.doc_templ_id = dt.doc_templ_id
               AND ac.payment_templ_id = act.payment_templ_id
               AND act.brief = 'PAYREQ'
               AND dt.brief = 'PAYREQ');
    IF v_cnt = 0
    THEN
      --формируем платежное требование
      v_payment_id := pkg_decline.create_decline_payreq(par_p_policy_id);

    END IF;
  END create_payment_request;

  /*
    Байтин А.
    Формирование исходящего ПП при переводе документа в статус "Прекращен.К выплате"
    В Borlas: "Прекращение ДС. Формирование исх. ПП"
    par_p_policy_id - ID версии ДС
  */
  PROCEDURE make_outgoing_bank_doc(par_p_policy_id NUMBER) IS
    v_next_num              document.num%TYPE;
    v_doc_date              DATE;
    v_redemption_sum_cur    NUMBER;
    v_add_invest_income_cur NUMBER;
    v_return_bonus_part_cur NUMBER;
    v_collection_method     t_collection_method.id%TYPE;
    v_contact_id            ac_payment.contact_id%TYPE;
    v_contact_bank_acc_id   ac_payment.contact_bank_acc_id%TYPE;
    v_fund_id               ac_payment.fund_id%TYPE;
    v_rev_rate              ac_payment.rev_rate%TYPE;
    v_rev_fund_id           ac_payment.rev_fund_id%TYPE;
    v_rate_type_id          rate_type.rate_type_id%TYPE;
    v_payment_templ_id      ac_payment_templ.payment_templ_id%TYPE;
    v_document_templ        doc_templ.doc_templ_id%TYPE;
    v_payment_terms_id      ac_payment.payment_terms_id%TYPE;
    v_payment_type_id       ac_payment.payment_type_id%TYPE;
    v_payment_direct_id     ac_payment.payment_direct_id%TYPE;
    v_note                  document.note%TYPE;
    v_payreq_note           document.note%TYPE;
    v_expense_date          DATE;
    v_expense_period        DATE;
    v_issuer_id             contact.contact_id%TYPE;
    v_owner_contact_id      contact.contact_id%TYPE;

    /* Добавление ППИ */
    PROCEDURE insert_payment
    (
      par_sum_cur      NUMBER
     ,par_note         VARCHAR2
     ,par_expense_code NUMBER
     ,par_payreq_note  VARCHAR2
    ) IS
      v_payment_id ac_payment.payment_id%TYPE;
    BEGIN
      /* ID платежа */
      SELECT sq_ac_payment.nextval INTO v_payment_id FROM dual;

      /* ППИ */
      INSERT INTO ven_ac_payment
        (payment_id
        ,doc_templ_id
        ,num
        ,reg_date
        ,amount
        ,collection_metod_id
        ,comm_amount
        ,company_bank_acc_id
        ,contact_id
        ,contact_bank_acc_id
        ,due_date
        ,fund_id
        ,grace_date
        ,is_agent
        ,payment_direct_id
        ,payment_number
        ,payment_templ_id
        ,payment_terms_id
        ,payment_type_id
        ,rev_amount
        ,rev_fund_id
        ,rev_rate
        ,rev_rate_type_id
        ,note)
      VALUES
        (v_payment_id
        ,v_document_templ
        ,to_char(v_next_num)
        ,v_doc_date
        ,par_sum_cur
        ,v_collection_method
        ,0
        ,24532 /* пока непонятно, ставим 26754595833811 в ЗАО "Райффайзенбанк" */
        ,v_contact_id
        ,v_contact_bank_acc_id
        ,v_doc_date
        ,v_fund_id
        ,v_doc_date
        ,0 /*не агентский платеж*/
        ,v_payment_direct_id
        ,1 /*номер платежа*/
        ,v_payment_templ_id
        ,v_payment_terms_id
        ,v_payment_type_id
        ,par_sum_cur * v_rev_rate
        ,v_rev_fund_id
        ,v_rev_rate
        ,CASE WHEN v_rev_rate != 1 THEN v_rate_type_id END /*ИД типа курса приведения, если курс = базовому, null*/
        ,par_note);

      /* Доп. инфо */
      INSERT INTO ac_payment_add_info
        (ac_payment_add_info_id, expense_code, expense_date, expense_period, responsibility_center)
      VALUES
        (v_payment_id, par_expense_code, v_expense_date, v_expense_period, 'Operations');

      /*
         Связь ДС и ППИ
         Важно, чтобы было до изменения статуса, т.к. при изменении нужна запись в doc_doc
      */
      INSERT INTO ven_doc_doc
        (child_amount, child_fund_id, child_id, parent_amount, parent_fund_id, parent_id)
      VALUES
        (par_sum_cur * v_rev_rate
        ,v_rev_fund_id
        ,v_payment_id
        ,par_sum_cur
        ,v_fund_id
        ,par_p_policy_id);

      /* Статус ППИ */

      doc.set_doc_status(v_payment_id
                        ,'NEW'
                        ,v_doc_date
                        ,'AUTO'
                        ,'создание документа');
      /*Закоментировано Чирков
      *171184: Замечания по тестированию автоматического создания
      *doc.set_doc_status(v_payment_id, 'TRANS', v_doc_date+interval '1' second, 'AUTO', 'автоматический перевод состояния');
      */

      --Чирков 183603 Добавить поле Назначение платежа в шлюзовую таблицу
      UPDATE insi.gate_payments_out g
         SET g.payment_purpose = par_payreq_note
       WHERE g.ac_payment_id = v_payment_id;
      --183603
    END insert_payment;

    FUNCTION is_contact_individual(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_individual t_contact_type.is_individual%TYPE;
    BEGIN
      SELECT ct.is_individual
        INTO v_is_individual
        FROM contact        co
            ,t_contact_type ct
       WHERE co.contact_id = par_contact_id
         AND co.contact_type_id = ct.id;

      RETURN v_is_individual = 1;

    END is_contact_individual;

    FUNCTION is_rf_docs_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_ident ci
                    ,t_id_type        ty
               WHERE ci.contact_id = par_contact_id
                 AND ci.id_type = ty.id
                 AND ty.brief IN ('PASS_RF')
                 AND ci.id_value IS NOT NULL
                 AND ci.serial_nr IS NOT NULL
                 AND ci.place_of_issue IS NOT NULL
                 AND ci.termination_date IS NULL);
      RETURN v_is_exists = 1;
    END is_rf_docs_exists;

    FUNCTION is_in_docs_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_ident ci
                    ,t_id_type        ty
               WHERE ci.contact_id = par_contact_id
                 AND ci.id_type = ty.id
                 AND ty.brief IN ('PASS_IN')
                 AND ci.id_value IS NOT NULL
                 AND ci.serial_nr IS NOT NULL
                 AND ci.place_of_issue IS NOT NULL
                 AND ci.termination_date IS NULL);
      RETURN v_is_exists = 1;
    END is_in_docs_exists;

    FUNCTION is_addresses_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_address ca
                    ,t_address_type     ta
                    ,cn_address         ad
               WHERE ca.contact_id = par_contact_id
                 AND ca.address_type = ta.id
                 AND ca.adress_id = ad.id
                 AND (ad.street_name IS NOT NULL AND ad.house_nr IS NOT NULL OR
                     nvl(length(ad.name), 0) > 30)
                 AND ca.status = 1
                 AND ta.brief IN ('CONST'
                                 ,'FK_CONST'
                                 ,'TEMPORARY'
                                 ,'FK_TEMPORARY'
                                 ,'FACT'
                                 ,'FK_FACT'
                                 ,'DOMADD'
                                 ,'FK_DOMADD'
                                 ,'LEGAL'
                                 ,'FK_LEGAL'));
      RETURN v_is_exists = 1;
    END is_addresses_exists;

    FUNCTION is_rf_addresses_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_address ca
                    ,t_address_type     ta
                    ,cn_address         ad
                    ,t_country          tc
               WHERE ca.contact_id = par_contact_id
                 AND ca.address_type = ta.id
                 AND ca.adress_id = ad.id
                 AND ad.country_id = tc.id
                 AND tc.alfa3 = 'RUS'
                 AND (ad.street_name IS NOT NULL AND ad.house_nr IS NOT NULL OR
                     nvl(length(ad.name), 0) > 30)
                 AND ca.status = 1
                 AND ta.brief IN ('CONST'
                                 ,'FK_CONST'
                                 ,'TEMPORARY'
                                 ,'FK_TEMPORARY'
                                 ,'FACT'
                                 ,'FK_FACT'
                                 ,'DOMADD'
                                 ,'FK_DOMADD'
                                 ,'LEGAL'
                                 ,'FK_LEGAL'));
      RETURN v_is_exists = 1;
    END is_rf_addresses_exists;

    FUNCTION is_contacts_related
    (
      par_contact_a_id contact.contact_id%TYPE
     ,par_contact_b_id contact.contact_id%TYPE
    ) RETURN BOOLEAN IS
      v_is_the_same        BOOLEAN := FALSE;
      v_is_relation_exists NUMBER(1) := 0;
    BEGIN
      IF par_contact_a_id = par_contact_b_id
      THEN
        v_is_the_same := TRUE;
      ELSE
        SELECT COUNT(1)
          INTO v_is_relation_exists
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM cn_contact_rel cr
                 WHERE cr.contact_id_a = par_contact_a_id
                   AND cr.contact_id_b = par_contact_b_id);
      END IF;
      RETURN v_is_the_same OR v_is_relation_exists = 1;
    END is_contacts_related;

  BEGIN
    /* Дата смены статуса, валюта, номер договора, страхователь */
    BEGIN
      SELECT trunc(ds.start_date, 'dd')
            ,ph.fund_id
            ,ph.fund_pay_id
            , 'Дог. ' || nvl2(pp.pol_ser, pp.pol_ser || '-', NULL) || pp.pol_num
             -- Байтин А.
             -- Заявка №140151
              || ' ' || co.name || ' ' || substr(co.first_name, 1, 1) || '.' ||
              substr(co.middle_name, 1, 1) || '.'
             --
            ,pi.contact_id
        INTO v_doc_date
            ,v_fund_id
            ,v_rev_fund_id
            ,v_note
            ,v_issuer_id
        FROM doc_status   ds
            ,p_policy     pp
            ,p_pol_header ph
             --
            ,v_pol_issuer pi
            ,contact      co
      --
       WHERE pp.policy_id = par_p_policy_id
         AND ds.document_id = pp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ds.doc_status_id = doc.get_last_doc_status_id(pp.policy_id)
            --
         AND pp.policy_id = pi.policy_id
         AND pi.contact_id = co.contact_id;
      --
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Невозможно получить версю договора!');
    END;

    /* Получение сумм */
    BEGIN
      SELECT src.redemption_sum_cur
            ,src.add_invest_income_cur
            ,src.return_bonus_part_cur + ROUND(nvl(src.state_duty, 0), 2) +
             ROUND(nvl(src.penalty, 0), 2) + ROUND(nvl(src.other_court_fees, 0), 2) +
             ROUND(nvl(src.borrowed_money_percent, 0), 2) + ROUND(nvl(src.moral_damage, 0), 2) +
             ROUND(nvl(src.service_fee, 0), 2)
        INTO v_redemption_sum_cur
            ,v_add_invest_income_cur
            ,v_return_bonus_part_cur
        FROM (SELECT ROUND(nvl(SUM(cd.redemption_sum), 0) - nvl(pd.debt_fee_fact, 0) +
                           nvl(pd.overpayment, 0) + nvl(SUM(cd.add_policy_surrender), 0)
                          ,2) redemption_sum_cur -- Выкупная сумма
                    ,ROUND(nvl(SUM(cd.add_invest_income), 0), 2) add_invest_income_cur -- ДИД
                    ,ROUND(nvl(SUM(cd.return_bonus_part), 0) - nvl(SUM(cd.admin_expenses), 0) -
                           nvl(pd.medo_cost, 0)
                          ,2) return_bonus_part_cur -- Возврат части премии
                    ,pd.state_duty
                    ,pd.penalty
                    ,pd.other_court_fees
                    ,pd.borrowed_money_percent
                    ,pd.moral_damage
                    ,pd.service_fee
        FROM p_pol_decline   pd
            ,p_cover_decline cd
       WHERE pd.p_policy_id = par_p_policy_id
         AND cd.p_pol_decline_id = pd.p_pol_decline_id
       GROUP BY pd.debt_fee_fact
               ,pd.overpayment
                       ,pd.medo_cost
                       ,pd.state_duty
                       ,pd.penalty
                       ,pd.other_court_fees
                       ,pd.borrowed_money_percent
                       ,pd.moral_damage
                       ,pd.service_fee) src;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Невозможно получить суммы для ПП! Возможно не создана версия прекращения.');
    END;

    /* Получение следующего номера */
    SELECT to_number(MAX(regexp_substr(doc.num, '\d+'))) + 1
      INTO v_next_num
      FROM document  doc
          ,doc_templ dt
     WHERE doc.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'ППИ';
    IF v_next_num IS NULL
    THEN
      raise_application_error(-20001
                             ,'Ошибка получения следующего номера!');
    END IF;

    /* Получение направления платежа */
    BEGIN
      SELECT pd.payment_direct_id
        INTO v_payment_direct_id
        FROM ac_payment_direct pd
       WHERE pd.brief = 'OUT';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден ID направления платежа с сокращением "OUT"! Проверьте существование направления платежа ("Исходящий") с сокарщением "OUT"!');
    END;

    /* Получение данных из ПТ (пока выбирается самое первое)*/
    BEGIN
      SELECT ac.contact_id
            ,ac.contact_bank_acc_id
            ,(SELECT ba.owner_contact_id
                FROM cn_contact_bank_acc ba
               WHERE ba.id = ac.contact_bank_acc_id) AS owner_contact_id
            ,doc.note --Чирков 183603 Добавить поле Назначение платежа в шлюзовую таблицу
      -- Байтин А.
      -- Заявка №140151
      --            ,v_note||' '||co.name||' '||substr(co.first_name,1,1)||'.'||substr(co.middle_name,1,1)||'.'
        INTO v_contact_id
            ,v_contact_bank_acc_id
            ,v_owner_contact_id
            ,v_payreq_note
        FROM ac_payment       ac
            ,ac_payment_templ act
            ,document         doc
            ,doc_templ        dt
            ,doc_doc          dd
      --            ,contact          co
       WHERE dd.parent_id = par_p_policy_id
         AND ac.payment_id = dd.child_id
         AND ac.payment_id = doc.document_id
         AND doc.doc_templ_id = dt.doc_templ_id
         AND ac.payment_templ_id = act.payment_templ_id
            --         and ac.contact_id       = co.contact_id
         AND act.brief = 'PAYREQ'
         AND dt.brief = 'PAYREQ'
         AND rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдено ни одного платежного требования, связанного с версией ДС!');
    END;

    /* ID шаблона ППИ */
    BEGIN
      SELECT pt.payment_templ_id
        INTO v_payment_templ_id
        FROM ac_payment_templ pt
       WHERE pt.brief = 'ППИ';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден ID шаблона платежа с сокращением "ППИ"! Проверьте существование шаблона платежа ("Платежное поручение исходящее") с сокарщением "ППИ"!');
    END;

    BEGIN
      SELECT dt.doc_templ_id INTO v_document_templ FROM doc_templ dt WHERE dt.brief = 'ППИ';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден ID шаблона документа с сокращением "ППИ"! Проверьте существование шаблона документа ("Платежное поручение исходящее") с сокарщением "ППИ"!');
    END;

    /* Условия рассрочки, у ППИ - Единовременно */
    BEGIN
      SELECT pt.id
        INTO v_payment_terms_id
        FROM t_payment_terms pt
       WHERE pt.brief = 'Единовременно';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден ID условия рассрочки платежа с сокращением "Единовременно"! Проверьте существование условия рассрочки платежа ("Единовременно") с сокарщением "Единовременно"!');
    END;

    /* Тип платежа - фактический*/
    BEGIN
      SELECT pt.payment_type_id
        INTO v_payment_type_id
        FROM ac_payment_type pt
       WHERE pt.brief = 'FACT';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден ID типа платежа с сокращением "FACT"! Проверьте существование типа платежа ("Фактический") с сокарщением "FACT"!');
    END;

    /* Способ оплаты */
    BEGIN
      SELECT cm.id INTO v_collection_method FROM t_collection_method cm WHERE cm.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден ID способа оплаты по умолчанию! Проверьте существование способа оплаты по умолчанию!');
    END;

    /* Период расхода - Первое число месяца от дата перевода Договора страхования в статус «К прекращению. К оплате» */
    v_expense_period := trunc(v_doc_date, 'mm');

    /* Дата расхода - Ближайший предстоящий вторник или четверг от Договора страхования в статус «К прекращению. К оплате» + 13 дней */
    SELECT MIN(day_date) + 14
      INTO v_expense_date
      FROM (SELECT to_char(v_doc_date + rownum - 1, 'D') AS day_num
                  ,v_doc_date + rownum - 1 AS day_date
              FROM dual
            CONNECT BY rownum <= 7)
     WHERE day_num IN ('2', '4');

    /* Добавление ППИ */
    IF v_redemption_sum_cur + v_add_invest_income_cur + v_return_bonus_part_cur > 0
    THEN
      /*
        Проверки перед созданием
        Заявка 353051
      */
      IF is_contact_individual(v_owner_contact_id)
      THEN
        IF NOT is_rf_docs_exists(v_owner_contact_id)
           AND NOT is_in_docs_exists(v_owner_contact_id)
        THEN
          ex.raise('Внимание! Для выплаты физическому лицу необходимо указать паспортные данные');
        END IF;
        IF (is_rf_docs_exists(v_owner_contact_id) AND NOT is_rf_addresses_exists(v_owner_contact_id))
           OR (is_in_docs_exists(v_owner_contact_id) AND NOT is_addresses_exists(v_owner_contact_id))
        THEN
          ex.raise('Внимание! Для выплаты физическому лицу необходимо указать адрес регистрации');
        END IF;
        IF NOT is_contacts_related(v_owner_contact_id, v_issuer_id)
        THEN
          ex.raise('Внимание! Для выплаты физическому лицу необходимо указать родственную связь с получателем');
        END IF;
      END IF;

      /* Тип курса по умолчанию */
      SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.is_default = 1;

      /* Курс */
      v_rev_rate := acc_new.get_rate_by_id(1, v_rev_fund_id, v_doc_date);
      -- Если валюта оплаты - рубли, проверяем валюту ответственности
      IF v_rev_rate = 1
      THEN
        v_rev_rate := acc_new.get_rate_by_id(1, v_fund_id, v_doc_date);
      END IF;
      /* Выкупная сумма */
      IF v_redemption_sum_cur != 0
      THEN
        insert_payment(v_redemption_sum_cur
                      ,v_note || ' (Выкупная сумма)'
                      ,50002
                      ,v_payreq_note);
        v_next_num := v_next_num + 1;
      END IF;
      /* ДИД */
      IF v_add_invest_income_cur != 0
      THEN
        insert_payment(v_add_invest_income_cur
                      ,v_note || ' (Доп. инвест. доход)'
                      ,50003
                      ,v_payreq_note);
        v_next_num := v_next_num + 1;
      END IF;
      /* Возврат части премии */
      IF v_return_bonus_part_cur > 0
      THEN
        insert_payment(v_return_bonus_part_cur
                      ,v_note || ' (Возврат части премии)'
                      ,50004
                      ,v_payreq_note);
      ELSIF v_return_bonus_part_cur < 0
      THEN
        raise_application_error(-20001
                               ,'Перевод статуса запрещен! Сумма к выплате меньше 0.');
      END IF;
    END IF;
  END make_outgoing_bank_doc;

  /*
    Байтин А.
    Удаление ПП при переводе документа из статуса "Прекращен.К выплате" в статус "Прекращен. Реквизиты получены"
    В Borlas: "Прекращение ДС. Удаление исх. ПП"
    par_p_policy_id - ID версии ДС
  */
  PROCEDURE delete_outgoing_bank_doc(par_p_policy_id NUMBER) IS
  BEGIN
    /* Цикл по связанным ППИ */
    FOR r_ids IN (SELECT c.doc_doc_id
                        ,ac.payment_id
                        ,doc.get_doc_status_brief(ac.payment_id) AS payment_status_brief
                    FROM doc_doc             c
                        ,ac_payment          ac
                        ,ac_payment_templ    apt
                        ,ac_payment_add_info ai
                        ,document            dc
                        ,doc_templ           dt
                   WHERE c.parent_id = par_p_policy_id
                     AND c.child_id = ac.payment_id
                     AND ac.payment_templ_id = apt.payment_templ_id
                     AND ac.payment_id = dc.document_id
                     AND dc.doc_templ_id = dt.doc_templ_id
                     AND ac.payment_id = ai.ac_payment_add_info_id
                     AND apt.brief = 'ППИ'
                     AND dt.brief = 'ППИ')
    LOOP
      /* Перевод статуса */
      IF r_ids.payment_status_brief = 'TRANS'
      THEN
        doc.set_doc_status(r_ids.payment_id, 'NEW', SYSDATE, 'AUTO');
      END IF;

      /* Удаление статуса */
      DELETE FROM ven_doc_status ds WHERE ds.document_id = r_ids.payment_id;

      /* Удаление связей */
      DELETE FROM ven_doc_doc dd WHERE dd.doc_doc_id = r_ids.doc_doc_id;

      /* Удаление доп. инфо */
      DELETE FROM ven_ac_payment_add_info ai WHERE ai.ac_payment_add_info_id = r_ids.payment_id;

      /* Удаление ППИ */
      DELETE FROM ven_ac_payment ap WHERE ap.payment_id = r_ids.payment_id;
    END LOOP;
  END delete_outgoing_bank_doc;

  /*
    Байтин А.

    Автоматическое создание корректирующих проводок при переводе документа
    из статуса "К прекращению. Готов для проверки" в статус "К прекращению. Проверен"

    par_policy_id - ИД версии договора

  */
  PROCEDURE make_correct_trans_auto(par_policy_id NUMBER) IS
    TYPE t_summs IS RECORD(
       vs    p_cover_decline.redemption_sum%TYPE
      ,vchp  p_cover_decline.return_bonus_part%TYPE
      ,n_div p_cover_decline.underpayment_actual%TYPE
      ,n_sum p_cover_decline.underpayment_actual%TYPE
      ,p     p_pol_decline.overpayment%TYPE
      ,ps    p_cover_decline.bonus_off_prev%TYPE
      ,did   p_cover_decline.add_invest_income%TYPE);
    v_summs            t_summs;
    v_pol_header_id    p_pol_header.policy_header_id%TYPE;
    v_cnt              NUMBER;
    v_pol_decline_id   p_pol_decline.p_pol_decline_id%TYPE;
    v_work_date        p_pol_decline.act_date%TYPE;
    v_sysdate          DATE := SYSDATE;
    v_rate             NUMBER;
    v_fund_id          NUMBER;
    v_fund_pay_id      NUMBER;
    v_policy_ent_id    entity.ent_id%TYPE;
    v_decline_date     DATE;
    v_curr_year_charge NUMBER;
    /*
      Создание корректирующих проводок
    */
    PROCEDURE make_corr_trans
    (
      par_prod_line_id NUMBER
     ,par_trans_sum    NUMBER
     ,par_trans_date   DATE
    ) IS
      v_cover_id      NUMBER;
      v_corr_trans_id p_trans_decline.p_trans_decline_id%TYPE;
    BEGIN
      -- Получение ИД покрытия
      -- ИД из последней версии
      BEGIN
        SELECT pc.p_cover_id
          INTO v_cover_id
          FROM p_cover            pc
              ,as_asset           se
              ,as_assured         su
              ,t_prod_line_option pl
         WHERE pc.as_asset_id = se.as_asset_id
           AND se.as_asset_id = su.as_assured_id
           AND pc.t_prod_line_option_id = pl.id
           AND pl.product_line_id = par_prod_line_id
           AND se.p_policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          -- Если нет из последней, то из ближайшей к последней
          BEGIN
            SELECT p_cover_id
              INTO v_cover_id
              FROM (SELECT /*+ INDEX_DESC(pp IX_P_POLICY_HEAD_VER_NUM_UK)*/
                     pc.p_cover_id
                      FROM p_policy           pp
                          ,p_cover            pc
                          ,as_asset           se
                          ,as_assured         su
                          ,t_prod_line_option pl
                     WHERE pc.as_asset_id = se.as_asset_id
                       AND se.as_asset_id = su.as_assured_id
                       AND se.p_policy_id = pp.policy_id
                       AND pc.t_prod_line_option_id = pl.id
                       AND pl.product_line_id = par_prod_line_id
                       AND pp.pol_header_id = v_pol_header_id
                       AND rownum = 1
                     ORDER BY pp.version_num DESC);
          EXCEPTION
            WHEN no_data_found THEN
              -- Если не нашли подходящий риск, выходим, т.к. непонятно, что делать
              NULL;
          END;
      END;

      v_sysdate := v_sysdate + INTERVAL '1' SECOND;
      -- Если сумма отрицательная
      IF par_trans_sum < 0
      THEN
        -- Получаем начисления в текущем году по документам текущего года
        SELECT nvl(SUM(trans_amount), 0)
          INTO v_curr_year_charge
          FROM (SELECT -- ЭПГ
                 tr.trans_amount
                  FROM trans              tr
                      ,oper               op
                      ,account            ac_cr
                      ,account            ac_dt
                      ,ac_payment         ap
                      ,doc_doc            dd
                      ,document           dc
                      ,doc_templ          dt
                      ,t_prod_line_option plo
                      ,p_policy           pp
                      ,p_pol_header       ph
                 WHERE tr.ct_account_id = ac_cr.account_id
                   AND ac_cr.num = '92.01'
                   AND tr.dt_account_id = ac_dt.account_id
                   AND ac_dt.num = '77.01.01'
                   AND tr.oper_id = op.oper_id
                   AND op.document_id = ap.payment_id
                   AND op.document_id = dc.document_id
                   AND dc.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND tr.a4_dt_uro_id = plo.id
                   AND plo.product_line_id = par_prod_line_id
                   AND dc.document_id = dd.child_id
                   AND dd.parent_id = pp.policy_id
                   AND trunc(ap.due_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND trunc(tr.trans_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.policy_header_id = v_pol_header_id
                UNION ALL
                SELECT -- ДС
                 tr.trans_amount
                  FROM trans              tr
                      ,oper               op
                      ,account            ac_cr
                      ,account            ac_dt
                      ,t_prod_line_option plo
                      ,p_policy           pp
                      ,p_pol_header       ph
                 WHERE tr.ct_account_id = ac_cr.account_id
                   AND ac_cr.num = '92.01'
                   AND tr.dt_account_id = ac_dt.account_id
                   AND ac_dt.num = '77.01.01'
                   AND tr.oper_id = op.oper_id
                   AND op.document_id = pp.policy_id
                   AND tr.a4_dt_uro_id = plo.id
                   AND plo.product_line_id = par_prod_line_id
                   AND trunc(pp.start_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND trunc(tr.trans_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.policy_header_id = v_pol_header_id);
        -- Если начисления + сумма корректировки < 0, то сумма проводки = отрицательная сумма начисления
        IF v_curr_year_charge + par_trans_sum < 0
        THEN
          v_curr_year_charge := -v_curr_year_charge;
          insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                           ,par_p_cover_id       => v_cover_id
                           ,par_oper_templ_brief => 'QUIT_FIX_28' -- Начисление/Сторно премии текущего периода
                           ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                           ,par_trans_sum        => v_curr_year_charge
                           ,par_trans_date       => par_trans_date
                           ,par_status_date      => v_sysdate
                           ,par_trans_id         => v_corr_trans_id);
          IF v_corr_trans_id IS NOT NULL
          THEN
            -- Установка статуса проводки "Закрыт"
            v_sysdate := v_sysdate + INTERVAL '1' SECOND;
            doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
          END IF;
        ELSIF par_trans_sum != 0
        THEN
          -- Иначе сумма проводки = корректировки
          v_curr_year_charge := par_trans_sum;
          insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                           ,par_p_cover_id       => v_cover_id
                           ,par_oper_templ_brief => 'QUIT_FIX_28' -- Начисление/Сторно премии текущего периода
                           ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                           ,par_trans_sum        => v_curr_year_charge
                           ,par_trans_date       => par_trans_date
                           ,par_status_date      => v_sysdate
                           ,par_trans_id         => v_corr_trans_id);
          IF v_corr_trans_id IS NOT NULL
          THEN
            -- Установка статуса проводки "Закрыт"
            v_sysdate := v_sysdate + INTERVAL '1' SECOND;
            doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
          END IF;
        END IF;
        IF v_curr_year_charge - par_trans_sum != 0
        THEN
          v_curr_year_charge := v_curr_year_charge - par_trans_sum;
          insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                           ,par_p_cover_id       => v_cover_id
                           ,par_oper_templ_brief => 'QUIT_MAIN_1' -- Корректировка Начисленной премии к списанию прошлых лет
                           ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                           ,par_trans_sum        => v_curr_year_charge
                           ,par_trans_date       => par_trans_date
                           ,par_status_date      => v_sysdate
                           ,par_trans_id         => v_corr_trans_id);
          IF v_corr_trans_id IS NOT NULL
          THEN
            -- Установка статуса проводки "Закрыт"
            v_sysdate := v_sysdate + INTERVAL '1' SECOND;
            doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
          END IF;
        END IF;
      ELSIF v_decline_date < trunc(v_sysdate, 'yyyy')
            AND par_trans_sum > 0
      THEN
        -- Если дата расторжения в прошлом году и сумма корректировки положительная
        insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                         ,par_p_cover_id       => v_cover_id
                         ,par_oper_templ_brief => 'QUIT_FIX_30' -- Начисление премии прошлых лет
                         ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                         ,par_trans_sum        => par_trans_sum
                         ,par_trans_date       => par_trans_date
                         ,par_status_date      => v_sysdate
                         ,par_trans_id         => v_corr_trans_id);
        IF v_corr_trans_id IS NOT NULL
        THEN
          -- Установка статуса проводки "Закрыт"
          v_sysdate := v_sysdate + INTERVAL '1' SECOND;
          doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
        END IF;
      ELSIF par_trans_sum != 0
      THEN
        -- Иначе просто проводка на сумму корректировки
        insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                         ,par_p_cover_id       => v_cover_id
                         ,par_oper_templ_brief => 'QUIT_FIX_28' -- Начисление/Сторно премии текущего периода
                         ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                         ,par_trans_sum        => par_trans_sum
                         ,par_trans_date       => par_trans_date
                         ,par_status_date      => v_sysdate
                         ,par_trans_id         => v_corr_trans_id);
        IF v_corr_trans_id IS NOT NULL
        THEN
          -- Установка статуса проводки "Закрыт"
          doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
        END IF;
      END IF;
    END;

    PROCEDURE calc_sum
    (
      par_value    NUMBER DEFAULT 0
     ,par_sum_kind NUMBER -- Вид суммы:
      -- 0 - Недоплата по рискам (по рискам), 10 - Недоплата (в целом),
      -- 1 - Премия к списанию (по рискам), 11 - Переплата (в целом)
      -- 2 - Недоплата (по рискам)+Премия к списанию (по рискам), 12 - Недоплата (в целом)+Премия к списанию (в целом)
      -- 3 - Прочие (по рискам), 13 - Прочие
      -- от указания параметра зависит, как будет распределяться сумма
     ,par_sum_sign NUMBER DEFAULT 1 -- Знак: 1 или -1
    ) IS
      TYPE t_ret_data IS RECORD(
         acc_amount      NUMBER
        ,contact_id      contact.contact_id%TYPE
        ,product_line_id t_product_line.id%TYPE);
      TYPE tt_ret_data IS TABLE OF t_ret_data;
      vr_corr_data tt_ret_data;
      vr_fact_data tt_ret_data;
    BEGIN
      -- Корректные начисления
      IF par_sum_kind >= 10
      THEN
        SELECT CASE
                 WHEN rownum = 1 THEN
                  tmp_amount + (correct_amount - SUM(tmp_amount) over())
                 ELSE
                  tmp_amount
               END AS acc_amount
              ,contact_id
              ,product_line_id
          BULK COLLECT
          INTO vr_corr_data
          FROM (SELECT acc_amount + CASE
                         WHEN acc_amount != 0 THEN
                          ROUND((acc_amount / SUM(acc_amount) over()) *
                                (v_rate * par_sum_sign * par_value)
                               ,2)
                         ELSE
                          0
                       END AS tmp_amount
                      ,SUM(acc_amount) over() + (v_rate * par_sum_sign * par_value) AS correct_amount
                      ,contact_id
                      ,product_line_id
                  FROM (SELECT SUM(acc_amount) AS acc_amount
                              ,contact_id
                              ,product_line_id
                          FROM (SELECT tr.trans_amount       AS acc_amount
                                      ,ur.assured_contact_id AS contact_id
                                      ,pl.product_line_id
                                  FROM p_policy           p
                                      ,as_asset           a
                                      ,as_assured         ur
                                      ,p_cover            pc
                                      ,t_prod_line_option pl
                                      ,trans              tr
                                      ,account            ac
                                 WHERE p.policy_id = a.p_policy_id
                                   AND a.as_asset_id = ur.as_assured_id
                                   AND a.as_asset_id = pc.as_asset_id
                                   AND tr.obj_uro_id = pc.p_cover_id
                                   AND tr.obj_ure_id = pc.ent_id
                                   AND pc.t_prod_line_option_id = pl.id
                                   AND tr.dt_account_id = ac.account_id
                                   AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                                   AND p.pol_header_id = v_pol_header_id
                                      -- Исключаем корректирующие проводки
                                   AND NOT EXISTS (SELECT NULL
                                          FROM p_trans_decline td
                                              ,oper            op
                                         WHERE td.p_trans_decline_id = op.document_id
                                           AND op.oper_id = tr.oper_id
                                           AND td.p_pol_decline_id = v_pol_decline_id)
                                      -- Исключаем проводки по прекращению
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM p_pol_decline pd
                                         WHERE pd.p_policy_id = p.policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id
                                        UNION ALL
                                        SELECT NULL
                                          FROM oper          op
                                              ,p_pol_decline pd
                                         WHERE op.oper_id = tr.oper_id
                                           AND op.document_id = pd.p_policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id)
                                UNION ALL
                                SELECT -tr.trans_amount      AS acc_amount
                                      ,ur.assured_contact_id AS contact_id
                                      ,pl.product_line_id
                                  FROM p_policy           p
                                      ,as_asset           a
                                      ,as_assured         ur
                                      ,p_cover            pc
                                      ,t_prod_line_option pl
                                      ,trans              tr
                                      ,account            ac
                                 WHERE p.policy_id = a.p_policy_id
                                   AND a.as_asset_id = ur.as_assured_id
                                   AND a.as_asset_id = pc.as_asset_id
                                   AND tr.obj_uro_id = pc.p_cover_id
                                   AND tr.obj_ure_id = pc.ent_id
                                   AND pc.t_prod_line_option_id = pl.id
                                   AND tr.ct_account_id = ac.account_id
                                   AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                                   AND p.pol_header_id = v_pol_header_id
                                      -- Исключаем корректирующие проводки
                                   AND NOT EXISTS (SELECT NULL
                                          FROM p_trans_decline td
                                              ,oper            op
                                         WHERE td.p_trans_decline_id = op.document_id
                                           AND op.oper_id = tr.oper_id
                                           AND td.p_pol_decline_id = v_pol_decline_id)
                                      -- Исключаем проводки по прекращению
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM p_pol_decline pd
                                         WHERE pd.p_policy_id = p.policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id
                                        UNION ALL
                                        SELECT NULL
                                          FROM oper          op
                                              ,p_pol_decline pd
                                         WHERE op.oper_id = tr.oper_id
                                           AND op.document_id = pd.p_policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id))
                         GROUP BY contact_id
                                 ,product_line_id))
        -- Сортировка для того, чтобы уменьшить количество циклов ниже
         ORDER BY product_line_id;
      ELSE
        SELECT acc_amount + CASE par_sum_kind
                 WHEN 0 THEN
                  v_rate * par_sum_sign * nvl(dc.underpayment_actual, 0)
                 WHEN 1 THEN
                  v_rate * par_sum_sign * nvl(dc.bonus_off_prev + dc.bonus_off_current, 0)
                 WHEN 2 THEN
                  v_rate * par_sum_sign *
                  nvl(dc.bonus_off_prev + dc.bonus_off_current + dc.underpayment_actual, 0)
                 ELSE
                  0
               END AS acc_amount
              ,mn.contact_id
              ,mn.product_line_id
          BULK COLLECT
          INTO vr_corr_data
          FROM (SELECT SUM(acc_amount) AS acc_amount
                      ,contact_id
                      ,product_line_id
                  FROM (SELECT tr.trans_amount       AS acc_amount
                              ,ur.assured_contact_id AS contact_id
                              ,pl.product_line_id
                          FROM p_policy           p
                              ,as_asset           a
                              ,as_assured         ur
                              ,p_cover            pc
                              ,t_prod_line_option pl
                              ,trans              tr
                              ,account            ac
                         WHERE p.policy_id = a.p_policy_id
                           AND a.as_asset_id = ur.as_assured_id
                           AND a.as_asset_id = pc.as_asset_id
                           AND tr.obj_uro_id = pc.p_cover_id
                           AND tr.obj_ure_id = pc.ent_id
                           AND pc.t_prod_line_option_id = pl.id
                           AND tr.dt_account_id = ac.account_id
                           AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                           AND p.pol_header_id = v_pol_header_id
                              -- Исключаем корректирующие проводки
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_trans_decline td
                                      ,oper            op
                                 WHERE td.p_trans_decline_id = op.document_id
                                   AND op.oper_id = tr.oper_id
                                   AND td.p_pol_decline_id = v_pol_decline_id)
                              -- Исключаем проводки по прекращению
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_pol_decline pd
                                 WHERE pd.p_policy_id = p.policy_id
                                   AND pd.p_pol_decline_id = v_pol_decline_id)
                        UNION ALL
                        SELECT -tr.trans_amount      AS acc_amount
                              ,ur.assured_contact_id AS contact_id
                              ,pl.product_line_id
                          FROM p_policy           p
                              ,as_asset           a
                              ,as_assured         ur
                              ,p_cover            pc
                              ,t_prod_line_option pl
                              ,trans              tr
                              ,account            ac
                         WHERE p.policy_id = a.p_policy_id
                           AND a.as_asset_id = ur.as_assured_id
                           AND a.as_asset_id = pc.as_asset_id
                           AND tr.obj_uro_id = pc.p_cover_id
                           AND tr.obj_ure_id = pc.ent_id
                           AND pc.t_prod_line_option_id = pl.id
                           AND tr.ct_account_id = ac.account_id
                           AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                           AND p.pol_header_id = v_pol_header_id
                              -- Исключаем корректирующие проводки текущей версии
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_trans_decline td
                                      ,oper            op
                                 WHERE td.p_trans_decline_id = op.document_id
                                   AND op.oper_id = tr.oper_id
                                   AND td.p_pol_decline_id = v_pol_decline_id)
                              -- Исключаем проводки по прекращению текущей версии
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_pol_decline pd
                                 WHERE pd.p_policy_id = p.policy_id
                                   AND pd.p_pol_decline_id = v_pol_decline_id))
                 GROUP BY contact_id
                         ,product_line_id) mn
              ,(SELECT su.assured_contact_id
                      ,cd.t_product_line_id
                      ,cd.underpayment_actual
                      ,cd.bonus_off_prev
                      ,cd.bonus_off_current
                  FROM p_cover_decline cd
                      ,p_pol_decline   pd
                      ,as_asset        se
                      ,as_assured      su
                 WHERE pd.p_policy_id = par_policy_id
                   AND pd.p_pol_decline_id = cd.p_pol_decline_id
                   AND cd.as_asset_id = se.as_asset_id
                   AND se.as_asset_id = su.as_assured_id) dc
         WHERE mn.contact_id = dc.assured_contact_id(+)
           AND mn.product_line_id = dc.t_product_line_id(+)
        -- Сортировка для того, чтобы уменьшить количество циклов ниже
         ORDER BY product_line_id;
      END IF;

      -- Фактические начисления для корректировки
      SELECT nvl(SUM(acc_amount), 0) AS acc_amount
            ,assured_contact_id
            ,product_line_id
        BULK COLLECT
        INTO vr_fact_data
      -- Расчет (92.01 + 91.01 - 91.02)
        FROM (SELECT CASE account_num
                       WHEN '91.02' THEN
                        -abs(SUM(acc_amount))
                       ELSE
                        abs(SUM(acc_amount))
                     END AS acc_amount
                    ,product_line_id
                    ,assured_contact_id
              -- Сальдо по счетам '92.01','91.01','91.02'
                FROM (SELECT tr.trans_amount       AS acc_amount
                            ,tr.oper_id
                            ,p.policy_id
                            ,ur.assured_contact_id
                            ,pl.product_line_id
                            ,ac.num                AS account_num
                        FROM p_policy           p
                            ,as_asset           a
                            ,as_assured         ur
                            ,p_cover            pc
                            ,t_prod_line_option pl
                            ,trans              tr
                            ,account            ac
                       WHERE p.policy_id = a.p_policy_id
                         AND a.as_asset_id = ur.as_assured_id
                         AND a.as_asset_id = pc.as_asset_id
                         AND tr.obj_uro_id = pc.p_cover_id
                         AND tr.obj_ure_id = pc.ent_id
                         AND pc.t_prod_line_option_id = pl.id
                         AND tr.dt_account_id = ac.account_id
                         AND ac.num IN ('92.01', '91.01', '91.02')
                         AND p.pol_header_id = v_pol_header_id
                      UNION ALL
                      SELECT -tr.trans_amount      AS acc_amount
                            ,tr.oper_id
                            ,p.policy_id
                            ,ur.assured_contact_id
                            ,pl.product_line_id
                            ,ac.num                AS account_num
                        FROM p_policy           p
                            ,as_asset           a
                            ,as_assured         ur
                            ,p_cover            pc
                            ,t_prod_line_option pl
                            ,trans              tr
                            ,account            ac
                       WHERE p.policy_id = a.p_policy_id
                         AND a.as_asset_id = ur.as_assured_id
                         AND a.as_asset_id = pc.as_asset_id
                         AND tr.obj_uro_id = pc.p_cover_id
                         AND tr.obj_ure_id = pc.ent_id
                         AND pc.t_prod_line_option_id = pl.id
                         AND tr.ct_account_id = ac.account_id
                         AND ac.num IN ('92.01', '91.01', '91.02')
                         AND p.pol_header_id = v_pol_header_id) mn
              -- Исключаем корректирующие проводки текущей версии
               WHERE NOT EXISTS (SELECT NULL
                        FROM p_trans_decline td
                            ,oper            op
                       WHERE td.p_trans_decline_id = op.document_id
                         AND op.oper_id = mn.oper_id
                         AND td.p_pol_decline_id = v_pol_decline_id)
                    -- Исключаем проводки по прекращению текущей версии
                 AND NOT EXISTS (SELECT NULL
                        FROM p_pol_decline pd
                       WHERE pd.p_policy_id = mn.policy_id
                         AND pd.p_pol_decline_id = v_pol_decline_id
                      UNION ALL
                      SELECT NULL
                        FROM oper          op
                            ,p_pol_decline pd
                       WHERE op.oper_id = mn.oper_id
                         AND op.document_id = pd.p_policy_id
                         AND pd.p_pol_decline_id = v_pol_decline_id)

               GROUP BY account_num
                       ,product_line_id
                       ,assured_contact_id)
       GROUP BY product_line_id
               ,assured_contact_id
      -- Сортировка для того, чтобы уменьшить количество циклов ниже
       ORDER BY product_line_id;
      -- Результат = Корректные начисления - фактические начисления для корректировки
      DECLARE
        v_found BOOLEAN;
      BEGIN
        -- Если есть и фактические начисления и корректные начисления
        IF vr_fact_data.count > 0
           AND vr_corr_data.count > 0
        THEN
          FOR v_f_idx IN vr_fact_data.first .. vr_fact_data.last
          LOOP
            v_found := FALSE;
            FOR v_c_idx IN vr_corr_data.first .. vr_corr_data.last
            LOOP
              IF vr_fact_data(v_f_idx)
               .contact_id = vr_corr_data(v_c_idx).contact_id
                  AND vr_fact_data(v_f_idx).product_line_id = vr_corr_data(v_c_idx).product_line_id
              THEN
                vr_corr_data(v_c_idx).acc_amount := vr_corr_data(v_c_idx)
                                                    .acc_amount - vr_fact_data(v_f_idx).acc_amount;
                v_found := TRUE;
                EXIT;
              END IF;
            END LOOP v_c_idx;
            IF NOT v_found
            THEN
              vr_corr_data.extend(1);
              vr_corr_data(vr_corr_data.last).acc_amount := -vr_fact_data(v_f_idx).acc_amount;
              vr_corr_data(vr_corr_data.last).product_line_id := vr_fact_data(v_f_idx).product_line_id;
              vr_corr_data(vr_corr_data.last).contact_id := vr_fact_data(v_f_idx).contact_id;
            END IF;
          END LOOP v_f_idx;
          -- Если только фактические начисления
        ELSIF vr_fact_data.count > 0
        THEN
          FOR v_f_idx IN vr_fact_data.first .. vr_fact_data.last
          LOOP
            vr_corr_data.extend(1);
            vr_corr_data(vr_corr_data.last).acc_amount := -vr_fact_data(v_f_idx).acc_amount;
            vr_corr_data(vr_corr_data.last).product_line_id := vr_fact_data(v_f_idx).product_line_id;
            vr_corr_data(vr_corr_data.last).contact_id := vr_fact_data(v_f_idx).contact_id;
          END LOOP v_f_idx;
        END IF;
      END;
      -- Цикл по результату
      IF vr_corr_data.count > 0
      THEN
        FOR v_c_idx IN vr_corr_data.first .. vr_corr_data.last
        LOOP
          IF vr_corr_data(v_c_idx).acc_amount != 0
          THEN
            make_corr_trans(par_prod_line_id => vr_corr_data(v_c_idx).product_line_id
                           ,par_trans_sum    => ROUND(vr_corr_data(v_c_idx).acc_amount / v_rate, 2)
                           ,par_trans_date   => v_work_date);
          END IF;
        END LOOP;
      END IF;
    END;
  BEGIN
    -- Получение общих данных
    SELECT ph.policy_header_id
          ,pd.p_pol_decline_id
          ,pd.act_date
          ,ph.fund_id
          ,ph.fund_pay_id
          ,decline_date
      INTO v_pol_header_id
          ,v_pol_decline_id
          ,v_work_date
          ,v_fund_id
          ,v_fund_pay_id
          ,v_decline_date
      FROM p_pol_header  ph
          ,p_policy      pp
          ,p_pol_decline pd
     WHERE pp.policy_id = par_policy_id
       AND pp.policy_id = pd.p_policy_id
       AND pp.pol_header_id = ph.policy_header_id;

    BEGIN
      SELECT e.ent_id
        INTO v_policy_ent_id
        FROM entity e
       WHERE e.brief = 'P_POLICY'
         AND e.schema_name = 'INS';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Отсутствует запись с сокращенным наименованием "P_POLICY" в справочнике сущностей!');
    END;
    -- Проверка на существование проводок со счетами 22.01, 22.05.01, 22.05.02

    check_accounts(par_policy_id);

    -- Не подлежат автоматической корректировке аннулируемые договоры, у которых причина расторжения:
    -- Отказ Страховщика
    -- Неоплата первого взноса
    -- Отказ Страхователя от НУ
    -- Решение суда (аннулирование)
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_decline_reason dr
                  ,p_policy         pp
             WHERE pp.policy_id = par_policy_id
               AND pp.decline_reason_id = dr.t_decline_reason_id
               AND dr.brief IN ('Отказ Страховщика'
                               ,'Неоплата первого взноса'
                               ,'Отказ страхователя от НУ'
                               ,'Решение суда (аннулирование)'
                               ,'Отказ Страхователя от договора'));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'Невозможно автоматически создать корректирующие проводки. Причина расторжения несовместима с данной возможностью.');
    END IF;

    -- Получение курса валюты
    v_rate := acc_new.get_rate_by_id(1, v_fund_pay_id, v_work_date);
    -- Если валюта оплаты - рубли, проверяем валюту ответственности
    IF v_rate = 1
    THEN
      v_rate := acc_new.get_rate_by_id(1, v_fund_id, v_work_date);
    END IF;

    -- Определение типа договора
    -- Получение сумм, по которым будет происходить идентификация
    BEGIN
      SELECT nvl(SUM(cd.redemption_sum), 0) AS vs -- (ВС) Выкупная сумма
            ,nvl(SUM(cd.return_bonus_part), 0) AS vchp -- (ВЧП) Возврат части премии
            ,nvl(SUM(cd.underpayment_actual), 0) AS n_div -- (Н) Недоплата фактическая (разбитая по рискам)
            ,nvl(pd.debt_fee_fact, 0) AS n_sum -- (Н) Недоплата фактическая (общая сумма)
            ,nvl(pd.overpayment, 0) AS p -- (П) Переплата
            ,nvl(SUM(cd.bonus_off_prev), 0) + nvl(SUM(cd.bonus_off_current), 0) AS ps -- (ПС) Премия к списанию
            ,nvl(SUM(cd.add_invest_income), 0) AS did -- ДИД Доп. инвест. доход
        INTO v_summs
        FROM p_policy        pp
            ,p_pol_decline   pd
            ,p_cover_decline cd
       WHERE pp.policy_id = par_policy_id
         AND pp.policy_id = pd.p_policy_id
         AND pd.p_pol_decline_id = cd.p_pol_decline_id
       GROUP BY pd.overpayment
               ,pd.debt_fee_fact;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось найти данные формы прекращения!');
    END;
    -- Тип договора и расчет сумм корректирующих проводок
    -- Тип договора 1
    -- ВС  | возврат ЧП (ВЧП) | ДИД    |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
    -- нет | нет              | нет    | есть         | нет           | есть                   | Н=ПС, ВС=0, ВЧП=0, ДИД=0
    IF v_summs.vs = 0
       AND v_summs.vchp = 0
       AND v_summs.did = 0
       AND v_summs.n_sum > 0
       AND v_summs.p = 0
       AND v_summs.ps > 0
       AND v_summs.n_sum = v_summs.ps
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- Тип договора 2
      -- ВС       | возврат ЧП (ВЧП) | ДИД      |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть         | нет/есть | нет          | нет           | есть                   | Любые значения
    ELSIF v_summs.n_sum = 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
    THEN
      calc_sum(par_sum_kind => 1);
      -- Тип договора 3
      -- ВС       | возврат ЧП (ВЧП) | ДИД      |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть         | нет/есть | есть         | нет           | нет                    |ВС+ВЧП+ДИД > Н
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps = 0
          AND v_summs.vs + v_summs.vchp + v_summs.did > v_summs.n_sum
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- Тип договора 4
      -- ВС       | возврат ЧП (ВЧП) | ДИД      |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть         | нет/есть | нет          | есть          | нет                    | Любые значения
    ELSIF v_summs.n_sum = 0
          AND v_summs.p > 0
          AND v_summs.ps = 0
    THEN
      calc_sum(par_value => v_summs.p, par_sum_kind => 11, par_sum_sign => -1);
      -- Тип договора 5 пока отсутствует
      -- Тип договора 6
      -- ВС  | возврат ЧП (ВЧП) | ДИД    |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет | нет              | нет    | есть         | нет           | есть                   | Н<ПС, ВС=0, ВЧП=0, ДИД=0
    ELSIF v_summs.vs = 0
          AND v_summs.vchp = 0
          AND v_summs.did = 0
          AND v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.n_sum < v_summs.ps
    THEN
      calc_sum(par_sum_kind => 1);
      -- Тип договора 7
      -- ВС       | возврат ЧП (ВЧП) | ДИД      |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть |  нет/есть         | нет/есть | есть         | нет           | есть                   |  Н - (ВС+ВЧП+ДИД) = ПС
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.n_sum - (v_summs.vs + v_summs.vchp + v_summs.did) = v_summs.ps
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- Тип договора 8
      -- ВС       | возврат ЧП (ВЧП) | ДИД      |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- есть/нет | есть/нет         | есть/нет |нет           | нет           | нет                    | ВС+ВЧП+ДИД>0
    ELSIF v_summs.n_sum = 0
          AND v_summs.p = 0
          AND v_summs.ps = 0
          AND v_summs.vs + v_summs.vchp + v_summs.did > 0
    THEN
      calc_sum(par_sum_kind => 10);
      -- Тип договора 9
      -- ВС       | возврат ЧП (ВЧП) | ДИД      |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть         | нет/есть | есть         | нет           | есть                   | ВС+ДИД+ВЧП>Н
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.vs + v_summs.vchp + v_summs.did > v_summs.n_sum
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum + v_summs.ps, par_sum_kind => 12);
      ELSE
        calc_sum(par_sum_kind => 2);
      END IF;
      -- Тип договора 10
      -- ВС       |возврат ЧП (ВЧП) | ДИД        |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть        | есть       | есть         | нет           | есть                   | Н - (ВС+ВЧП+ДИД-округл(ДИД*0,13;0)) = ПС
    ELSIF v_summs.did > 0
          AND v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.n_sum - (v_summs.vs + v_summs.vchp + v_summs.did - ROUND(v_summs.did * 0.13, 0)) =
          v_summs.ps
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- Тип договора 11
      -- ВС       |возврат ЧП (ВЧП) | ДИД        |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет      | нет             | нет        | нет          | нет           | нет                    | нет
    ELSIF v_summs.vs + v_summs.vchp + v_summs.did + v_summs.n_sum + v_summs.p + v_summs.ps = 0
    THEN
      calc_sum(par_sum_kind => 3);
      -- Тип договора 12
      -- ВС       |возврат ЧП (ВЧП) | ДИД        |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть        | нет/есть   | нет          |есть           | есть                   | нет
    ELSIF v_summs.n_sum = 0
          AND v_summs.p > 0
          AND v_summs.ps > 0
    THEN
      calc_sum(par_value => v_summs.n_sum + v_summs.ps - v_summs.p, par_sum_kind => 12);
      -- Тип договора 13
      -- ВС       |возврат ЧП (ВЧП) | ДИД        |Недоплата (Н) | Переплата (П) | Премия к списанию (ПС) | Соотношение факторов
      -- нет/есть | нет/есть        | нет/есть   | есть         | нет           | есть                   | "ВС+ДИД+ВЧП>0 Н - (ВС+ВЧП+ДИД-округл(ДИД*0,13;0)) < ПС"
      -- Для определния корректировок ПС определяется как ПС- Н + (ВС+ВЧП+ДИД-округл(ДИД*0,13;0))"
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.vs + v_summs.did + v_summs.vchp > 0
          AND v_summs.n_sum - (v_summs.vs + v_summs.vchp + v_summs.did - ROUND(v_summs.did * 0.13, 0)) <
          v_summs.ps
    THEN
      calc_sum(par_value    => v_summs.ps +
                               (v_summs.vs + v_summs.vchp + v_summs.did - ROUND(v_summs.did * 0.13, 0))
              ,par_sum_kind => 13);
    ELSE
      raise_application_error(-20001
                             ,'Невозможно автоматически создать корректирующие проводки. Договор не подходит под предопределенный тип договора!');
    END IF;
  END make_correct_trans_auto;
  /*
  отсутствует дело по риску «Смерть Застрахованного» в истории переходов статуса которого есть или статус «Передано на оплату» или статус «Отказано в выплате»
  @author  Черных М. 23.1.2015
  */
  FUNCTION claim_not_exists(par_policy_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM c_event        e
                  ,c_claim_header ch
                  ,as_asset       a
                  ,c_claim        c
                  ,p_pol_header   pph
                  ,p_policy       pp
                  ,t_peril        tp
             WHERE pph.policy_header_id = par_policy_header_id
               AND pp.pol_header_id = pph.policy_header_id
               AND pp.policy_id = a.p_policy_id
               AND e.as_asset_id = a.as_asset_id
               AND ch.c_event_id = e.c_event_id
               AND ch.c_claim_header_id = c.c_claim_header_id
               AND ch.peril_id = tp.id
               AND tp.description LIKE 'Смерть Застрахованного%'
               AND EXISTS (SELECT NULL
                      FROM doc_status     ds
                          ,doc_status_ref dsf
                     WHERE ds.document_id = c.c_claim_id
                       AND ds.doc_status_ref_id = dsf.doc_status_ref_id
                       AND dsf.brief IN ('REFUSE_PAY', 'FOR_PAY')));
    RETURN v_count = 0;
  END claim_not_exists;

  /**
   * Проверка наличия решения по делу
   * @author  Черных М. 28.1.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_claim(par_policy_id p_policy.policy_id%TYPE) IS
    vr_policy           dml_p_policy.tt_p_policy;
    vr_t_decline_reason dml_t_decline_reason.tt_t_decline_reason;
  BEGIN
    /*• Проверка наличия решения по делу. Если причина расторжения «Смерть застрахованного» и
    отсутствует дело по риску «Смерть Застрахованного» в истории переходов статуса которого есть или
     статус «Передано на оплату» или статус «Отказано в выплате», то показать ошибку «Решение УСВЭ не принято». */
    vr_policy           := dml_p_policy.get_record(par_policy_id => par_policy_id);
    vr_t_decline_reason := dml_t_decline_reason.get_record(par_t_decline_reason_id => vr_policy.decline_reason_id);

    IF vr_t_decline_reason.brief = 'Смерть Застрахованного'
       AND claim_not_exists(par_policy_header_id => vr_policy.pol_header_id)
    THEN
      ex.raise_custom('УСВЭ не принято');
    END IF;
  END check_claim;

  /**
   * Проверка: наличие в истории перехода статусов есть переход «Прекращен. К выплате» - «Прекращен»
   * @author  Черных М. 28.1.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_was_quit_to_pay_status(par_policy_id p_policy.policy_id%TYPE) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM doc_status     ds
                  ,doc_status_ref src
                  ,doc_status_ref dest
             WHERE ds.document_id = par_policy_id
               AND ds.src_doc_status_ref_id = src.doc_status_ref_id
               AND ds.doc_status_ref_id = dest.doc_status_ref_id
               AND src.brief = 'QUIT_TO_PAY'
               AND dest.brief = 'QUIT');
    IF v_count = 1
    THEN
      ex.raise_custom('Переход запрещен, т.к. был переход "Прекращен. К выплате"-"Прекращен"');
    END IF;
  END check_was_quit_to_pay_status;

  /**
   * Проверка: «Переплата» и значение поля «Недоплата фактическая» оба больше 0, то ошибка
   * @author  Черных М. 6.3.2015
   -- %param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_overpayment_and_debt(par_policy_id p_policy.policy_id%TYPE) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_pol_decline p
             WHERE p.p_policy_id = par_policy_id
               AND p.overpayment > 0
               AND p.debt_fee_fact > 0);
    IF v_count = 1
    THEN
      ex.raise_custom('И недоплата, и переплата больше нуля');
    END IF;

  END check_overpayment_and_debt;

END pkg_policy_quit;
/
