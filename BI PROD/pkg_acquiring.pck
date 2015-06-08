CREATE OR REPLACE PACKAGE pkg_acquiring IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 28.05.2014 16:27:13
  -- Purpose : Функционал интернет-эквайринга

  /*Поиск шаблона платежа для ДС на переходе статуса ДС из "Новый" в "Проект"*/
  PROCEDURE find_payment_template_4_policy(par_pololicy_id p_policy.policy_id%TYPE);
  /*Регистрация платежа*/
  PROCEDURE check_payment
  (
    par_request  IN JSON
   ,par_response OUT JSON
  );

  /* Уведомление о платеже */
  PROCEDURE process_payment
  (
    par_request  IN JSON
   ,par_response OUT JSON
  );

  /*
    Предварительный расчет графика списания
    Черных М. 10.09.2014
  */
  PROCEDURE precalc_payment_schedule
  (
    par_payment_template_id      IN acq_payment_template.acq_payment_template_id%TYPE
   ,par_base_date                IN DATE
   ,par_pol_end_date             IN DATE := NULL
   ,par_prolongation_flag        IN acq_payment_template.prolongation_flag%TYPE
   ,par_payment_count_out        OUT NUMBER
   ,par_first_operation_date_out OUT DATE
  );

  PROCEDURE create_payment_schedule(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE);

  /*
    Передача ЭГС на списание
    Выполняется джобом ночью
  */
  PROCEDURE pass_to_writeoff_at_night;
  /*
    Передача ЭГС на списание
    Выполняется джобом утром
  */
  PROCEDURE pass_to_writeoff_at_morning;
  /* Проверка статуса действия ДС
     Выполняется ночью джобом
  */
  PROCEDURE stop_payment_templates;

  /* 2.4.6. Создание новой версии «Пролонгация»
    При создании новой версии договора страхования, если тип изменений равен
    «Автопролонгация», и для договора страхования существует документ
    «Шаблон платежа» в статусе «Подтвержден», то:
      Изменять значение поля «Срок действия списания» в шаблоне на «Срок действия договора страхования»;
      Сформировать запрос к Сайту «Редактирование шаблона платежа»
      Сформировать новые элементы графиков списания
  
    Выполняется на переходе статусов ДС
    Переходы статусов уточняются.
  */
  PROCEDURE change_payment_template(par_policy_id p_policy.policy_id%TYPE);

  /*
  2.4.7.  Привязка платежа для пролонгации.
  При изменении значения поля «Статус ручной обработки» на «Разнесен»,
  если существует ЭГС с типом «Пролонгация» равным «Да»,
  который ссылается на ЭРП, то:
    Если Шаблон платежа, на который ссылается ЭГС, находится в статусе «Подтвержден»,
    то перевести его в статус «Завершен» с указанием причины отказа «Пролонгация».
    Создать новый Шаблон платежа.
    Сформировать запрос к Сайту «Редактирование шаблона платежа».
  */
  PROCEDURE prolongate_template(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE);

  PROCEDURE make_payment(par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE);

  PROCEDURE send_payment
  (
    par_fee          IN acq_writeoff_sch.amount%TYPE
   ,par_template_num document.num%TYPE
   ,par_till         acq_payment_template.till%TYPE
   ,par_policy_num   VARCHAR2
   ,par_response     OUT JSON
  );

  PROCEDURE load_registry_detail
  (
    par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE
   ,par_file_id         temp_load_blob.session_id%TYPE
  );

  PROCEDURE update_registry_vals(par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE);

  /*
    Обработка детализации реестра ОМС
  */
  PROCEDURE process_registry(par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE);

  FUNCTION get_confirmed_templ_by_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN acq_payment_template.acq_payment_template_id%TYPE;

  /*
  Заявление об отказе от рекуррентных платежей
  «Новый» - «Подтвержден»
  Шаблон платежа, сохраненный в Заявлении об отказе от регулярного списания,
  находящееся в статусе  «Подтвержден»,  переводится в статус «Завершен»,
  значение поля «Причина отказа» заполняется значением «7 – Заявление клиента»
  */
  PROCEDURE stop_template_by_client_notice(par_cancel_notice_id acq_cancel_notice.acq_cancel_notice_id%TYPE);

  /*
  Заявление об отказе от рекуррентных платежей
  «Подтвержден» - «Отменен»
  Перевод соответствующего Шаблона платежа из статуса «Завершен» в статус «Подтвержден»
  */
  PROCEDURE confirm_template_from_notice(par_cancel_notice_id acq_cancel_notice.acq_cancel_notice_id%TYPE);

  /*
   Шаблон платежей
   «Подтвержден» - «Завершен»
   Если существует ЭГС в статусе «Новый» или «На списание»,
   то перевести их в статус «Отменен»
  */
  PROCEDURE cancel_schedule_by_template(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE);
  /*
    График списания
    «На списание» - «Не списано»
    Шаблон платежа, на который ссылается ЭГС, перевести в статус «Завершен» с указанием причины отказа «Отказ банка»
  */
  PROCEDURE stop_template_by_schedule(par_writeoff_sch_id acq_writeoff_sch.acq_writeoff_sch_id%TYPE);

  /*
    График списания
    «Новый» - «На списание»
    1.  Создавать новый документ типа «Интернет платеж» в статусе «Проект»
    2.  Созданный документ перевести из статуса «Проект» в статус «На списание»
  */
  PROCEDURE create_payment_by_schedule(par_writeoff_sch_id acq_writeoff_sch.acq_writeoff_sch_id%TYPE);

  /*
    Шаблон платежа
    "Проект" - "Подтвержден"
    Установка текущего статуса активной версии шаблону
  */
  PROCEDURE set_policy_status_to_template(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE);

  /*
    Удаление шаблонов, зависших в статусе "Проект", на дату
    Выполняется джобом раз в неделю
  */
  PROCEDURE delete_project_templates(par_from_date DATE);
  /*
  2.4.11. Ежедневная обработке Реестров ОМС.
  Ежедневно, в 22:00, запускать процедуру автоматической обработки загруженных ранее
  Реестров ОМС:
    Для всех документов «Реестр ОМС» в статусе «Загружен» или «Не обработан»
    осуществлять переход в статус «Обработан»
  */
  PROCEDURE process_registry_by_job;

  /*Удаление шаблона платежа и графиков списания*/
  PROCEDURE delete_payment_template(par_acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE);

  -- Author  : Гаргонов Д.А.
  -- Purpose : 372104: Интернет - эквайринг шаблон в статусе "Проект"
  -- Comment : Отменяет шаблон, в случае двойного списания.
  --           Выполняется на переходе статусов шаблона ACQ_PAYMENT_TEMPLATE.
  PROCEDURE check_dw_on_templ_confirm(par_acq_payment_template_id NUMBER);

  /**
  * При переходе статуса Интеренет платежа из "Списан" в "Новый" перевести элемент графика списания, 
  * на который ссылается Интернет платеж в статус «Списано»
  * @author Черных М.
  * @param par_internet_payment_id ИД интернет платежа
  */
  PROCEDURE set_writeoff_sch_stat_writeoff(par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE);

  /**
  * При переходе статуса из "Не списано" в "Отменен" перевести элемент графика списания, на который ссылается Интернет платеж в статус «Отменен», 
  * если значение реквизита «Прекращение списания» 
  * таблицы «Расшифровка кодов ответ (RESULT_CODE)» для ошибки, указанной в поле «RESULT_CODE» равно 1
  * @author Черных М.
  * @param par_internet_payment_id ИД интернет платежа
  */
  PROCEDURE set_writeoff_sch_stat_cancel(par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE);

  /*
  Проверить, что для каждой записи таблицы «Детализация Реестра ОМС»
  в статусе «Новый» для текущего Реестра ОМС существует документ
  «Интернет платеж» в статусе «Новый», у которого значения полей «Номер карты»,
  «Сумма операции» и «Дата операции» в формате «ДД.ММ.ГГГГ»
  совпадают с аналогичными значениями таблицы Детализация Реестра ОМС».
  */

  PROCEDURE check_registry(par_oms_registry_id NUMBER);

  /**
  * Процедура закрытия бизнес дня относительно последнего закрытия
  * Процедура используется при ручном выполнении закрытия дня
  * @author Капля П.
  * @param par_operation_count - Число операций в ЛК с последнего закрытия
  * @param par_operation_sum   - Сумма операций в ЛК с последнего закрытия
  * @param par_closing_day_id  - ИД записи закрытия
  */
  PROCEDURE close_business_day
  (
    par_operation_count INTEGER
   ,par_operation_sum   NUMBER
   ,par_closing_day_id  OUT NUMBER
  );
  /**
  * Процедура закрытия бизнес дня относительно последнего закрытия
  * @author Капля П.
  * @param par_date - дата и время закрытия
  */
  PROCEDURE close_business_day
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /**
  * Процедура отправки отчета о
  */
  PROCEDURE send_payment_report(par_date DATE DEFAULT trunc(SYSDATE));

  /**
  * Григорьев Ю.А. Поиск ДС для шаблонов платежа в статусе "Новый"
  */
  PROCEDURE find_policy_4_payment_template;

END pkg_acquiring;
/
CREATE OR REPLACE PACKAGE BODY pkg_acquiring IS

  SUBTYPE t_payment_type IS NUMBER(1);
  gc_ok                       CONSTANT VARCHAR2(2) := 'OK';
  gc_error                    CONSTANT VARCHAR2(5) := 'ERROR';
  gc_single                   CONSTANT t_payment_type := 1; -- Единовременный
  gc_primary_recurrent        CONSTANT t_payment_type := 2; -- Первичный рекуррентный
  gc_next_recurrent           CONSTANT t_payment_type := 3; -- Повторный рекуррентный
  gc_default_privilege_period CONSTANT NUMBER := 30; --Льготный период по умолчанию 30 дней
  gc_project_queue_name       CONSTANT VARCHAR2(50) := 'queue_project_pmnt'; --Очередь для платежей в статусе "Проект"
  gc_writeoff_queue_name      CONSTANT VARCHAR2(50) := 'queue_writeoff_pmnt'; --Очередь для платежей в статусе "Списан"
  gc_not_writeoff_queue_name  CONSTANT VARCHAR2(50) := 'queue_not_writeoff_pmnt'; --Очередь для платежей в статусе "Не списан"

  gc_rate_type_cb_id CONSTANT NUMBER := dml_rate_type.get_id_by_brief('ЦБ');
  gc_fund_rur_id     CONSTANT NUMBER := dml_fund.get_id_by_brief('RUR');

  gc_acq_pt_repeat_recurrent_id CONSTANT NUMBER := dml_t_acq_payment_type.get_id_by_brief('REPEATED_RECURRENT');
  gc_dt_acq_internet_payment_id CONSTANT NUMBER := dml_doc_templ.get_id_by_brief('ACQ_INTERNET_PAYMENT');

  gc_dsr_to_writeoff_id     CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('TO_WRITEOFF');
  gc_dsr_writedoff_id       CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('WRITEDOFF');
  gc_dsr_not_writedoff_id   CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('NOT_WRITEDOFF');
  gc_dsr_not_on_writeoff_id CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('NOT_ON_WRITEOFF');
  gc_dsr_new_id             CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('NEW');
  gc_dsr_loaded_id          CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('LOADED');

  gc_failure_responsable_prs CONSTANT pkg_email.t_recipients := pkg_email.t_recipients('pavel.kaplya@renlife.com');

  /*Структура для ответа сайту*/
  TYPE t_response IS RECORD(
     status                    VARCHAR2(5) /*Статус - ОК или не ОК*/
    ,errors                    VARCHAR2(2000) /*Список ошибок*/
    ,payment_type              NUMBER(1) /*Тип платежа (1-единовр., 2-первичный рекурентный, 3-повторный рекурентный)*/
    ,template_num              document.num%TYPE /*Номер шаблона для регулярных списаний*/
    ,period                    DATE /*Срок действия списания*/
    ,pol_header_id             p_pol_header.policy_header_id%TYPE /*ИД найденного договора*/
    ,fee_rur                   acq_internet_payment.amount%TYPE /*Сумма платежа в рублях*/
    ,adm_cost_rur              acq_payment_template.admin_expenses%TYPE /*админ. издержки в рублях*/
    ,payment_count             NUMBER /*Количество регулярных платежей для Договора оферты*/
    ,first_operation_date      DATE /*Дата первой операции*/
    ,payment_terms_description t_payment_terms.description%TYPE /*Наименовние периодичности оплаты по ДС*/
    ,payment_terms_brief       t_payment_terms.brief%TYPE /*БРИФ Периодичность оплаты по ДС*/);
  /*Структура для запроса от сайта*/
  TYPE t_request IS RECORD(
     pol_header_id  p_pol_header.policy_header_id%TYPE /*ИД договора из личного кабинета*/
    ,pol_number     p_policy.pol_num%TYPE /*номер заявления - 9 символов, номер ДС - 10*/
    ,fio            contact.obj_name%TYPE /*ФИО страхователя*/
    ,fee            acq_payment_template.fee%TYPE /*Взнос в валюте договора*/
    ,currency       fund.brief%TYPE /*Валюта*/
    ,is_agreed      NUMBER(1) --Флаг согласия на регулярные списания
    ,admin_exp      acq_payment_template.admin_expenses%TYPE /*Админ.издержки*/
    ,ip             acq_payment_template.ip_address%TYPE /*IP адрес плательщика*/
    ,grace_date     acq_payment_template.grace_date%TYPE /*Дата ЭСП (срок платежа)*/
    ,ac_payment_id  ac_payment.payment_id%TYPE /*ИД элемента плана графика (ЭПГ)*/
    ,payment_terms  t_payment_terms.description%TYPE --Периодичность списания
    ,postal_address acq_payment_template.postal_address%TYPE /*Почтовый адрес для корреспонденции*/
    ,pol_start_date acq_payment_template.policy_start_date%TYPE /*Дата начала действия ДС*/
    ,pol_end_date   acq_payment_template.policy_end_date%TYPE /*Дата окончания действия ДС*/
    ,cell_phone     acq_payment_template.cell_phone%TYPE /*Мобильник плательщика*/);

  gc_subscriber_name CONSTANT VARCHAR2(100) := 'ACQUIRING_SUBSCRIBER';
  ex_queue_no_messages EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_queue_no_messages, -25228);

  /*Конкатенация ошибок*/
  PROCEDURE put_error
  (
    par_error       VARCHAR2
   ,par_error_stack IN OUT VARCHAR2
  ) IS
  BEGIN
    IF par_error_stack IS NULL
    THEN
      par_error_stack := par_error;
    ELSE
      par_error_stack := par_error_stack || chr(10) || par_error;
    END IF;
  END put_error;

  /* Определение текущего операционного дня */
  FUNCTION get_current_business_day RETURN NUMBER IS
    v_acq_daily_closing_id NUMBER;
  BEGIN
    SELECT t.acq_daily_closing_id
      INTO v_acq_daily_closing_id
      FROM acq_daily_closing t
     WHERE decode(t.state, 0, 0, NULL) = 0;
  
    RETURN v_acq_daily_closing_id;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не удалось определить текущий бизнес день для закрытия');
  END get_current_business_day;

  /*Проверка правильности брутто-взноса*/
  FUNCTION is_fee_correct
  (
    par_fee               p_cover.fee%TYPE
   ,par_active_version_id p_policy.policy_id%TYPE
   ,par_last_version_id   p_policy.policy_id%TYPE
   ,par_date              ac_payment.due_date%TYPE --Дата графика
   ,par_only_fee          OUT p_cover.fee%TYPE --Брутто взнос без админ издержек для сохранения в шаблон
  ) RETURN BOOLEAN IS
    v_is_correct BOOLEAN;
    --Является ли дата годовщиной
    FUNCTION is_anniversary
    (
      par_policy_id p_policy.policy_id%TYPE
     ,par_date      DATE
    ) RETURN BOOLEAN IS
      v_is_anniversary NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO v_is_anniversary
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_header pph
                    ,p_policy     pp
               WHERE pp.pol_header_id = pph.policy_header_id
                 AND pp.policy_id = par_policy_id
                 AND to_char(pph.start_date, 'ddmm') = to_char(par_date, 'ddmm'));
      RETURN v_is_anniversary = 1;
    END is_anniversary;
  
  BEGIN
    v_is_correct := FALSE;
    /*
      брутто взнос по активной версии равен размеру страхового взноса.
      или брутто взнос по активной версии за минусом административных издержек
      равен размеру страхового взноса;
      или брутто взнос по последней версии ДС в статусе «Индексация»
      за минусом административных издержек и административных издержек на восстановление,
      если они есть равен размеру страхового взноса
    */
    IF doc.get_doc_status_brief(par_last_version_id) != 'INDEXATING'
    THEN
      IF par_fee = nvl(pkg_policy.get_policy_fee(par_policy_id          => par_active_version_id
                                                ,par_include_admin_cost => is_anniversary(par_policy_id => par_active_version_id
                                                                                         ,par_date      => par_date) /*В годовщину включаем Админ. издержки*/
                                                ,par_round_to           => 2)
                      ,0)
      THEN
        par_only_fee := pkg_policy.get_policy_fee(par_policy_id          => par_active_version_id
                                                 ,par_include_admin_cost => FALSE
                                                 ,par_round_to           => 2);
        v_is_correct := TRUE;
      END IF;
      -- Если индексация
    ELSE
      /*Взнос совпадает с взносом по последней верии (версия индексации)*/
      IF par_fee = nvl(pkg_policy.get_policy_fee(par_policy_id          => par_last_version_id
                                                ,par_include_admin_cost => is_anniversary(par_policy_id => par_active_version_id
                                                                                         ,par_date      => par_date) /*В годовщину включаем Админ. издержки*/
                                                ,par_round_to           => 2)
                      ,0)
      THEN
        par_only_fee := pkg_policy.get_policy_fee(par_policy_id          => par_last_version_id
                                                 ,par_include_admin_cost => FALSE
                                                 ,par_round_to           => 2);
        v_is_correct := TRUE;
      END IF;
      /*Взнос совпадает с текущей версией*/
      IF par_fee = nvl(pkg_policy.get_policy_fee(par_policy_id          => par_active_version_id
                                                ,par_include_admin_cost => is_anniversary(par_policy_id => par_active_version_id
                                                                                         ,par_date      => par_date) /*В годовщину включаем Админ. издержки*/
                                                ,par_round_to           => 2)
                      ,0)
      THEN
        par_only_fee := pkg_policy.get_policy_fee(par_policy_id          => par_active_version_id
                                                 ,par_include_admin_cost => FALSE
                                                 ,par_round_to           => 2);
        v_is_correct := TRUE;
      END IF;
    END IF;
  
    RETURN v_is_correct;
  END is_fee_correct;

  /*Поиск шаблона платежа для ДС на переходе статуса ДС из "Новый" в "Проект"*/
  PROCEDURE find_payment_template_4_policy(par_pololicy_id p_policy.policy_id%TYPE) IS
  
    v_error_text              VARCHAR2(4000);
    vr_pol_header             dml_p_pol_header.tt_p_pol_header;
    vr_p_policy               dml_p_policy.tt_p_policy;
    v_insured_fio             contact.obj_name_orig%TYPE;
    v_acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
    v_only_fee                p_cover.fee%TYPE;
  
    v_is_ok BOOLEAN := TRUE;
    /*Проверка, что это первая неотмененная версия ДС*/
    FUNCTION is_first_uncencelled_policy
    (
      par_p_pol_header NUMBER
     ,par_p_policy     NUMBER
    ) RETURN BOOLEAN IS
    BEGIN
      RETURN pkg_policy.get_first_uncanceled_version(par_p_pol_header) = par_p_policy;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -20001 /*Ошибка, что не найдена первая неотмененная версия*/
        THEN
          NULL;
        ELSE
          RAISE;
        END IF;
    END is_first_uncencelled_policy;
  
    /*Проверка совпадения периодичности при переходе статуса «Новый» в статус «Подтвержден» для шаблона платежа*/
    FUNCTION is_payment_terms_correct(par_acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE)
      RETURN BOOLEAN IS
      v_result                BOOLEAN;
      vr_acq_payment_template dml_acq_payment_template.tt_acq_payment_template;
      /*Найти периодичность списания в активной версии ДС*/
      FUNCTION get_active_policy_pay_term_id(par_policy_header_id p_pol_header.policy_header_id%TYPE)
        RETURN t_payment_terms.id%TYPE IS
        v_active_pol_payment_term_id t_payment_terms.id%TYPE;
      BEGIN
        SELECT pp.payment_term_id
          INTO v_active_pol_payment_term_id
          FROM p_pol_header pph
              ,p_policy     pp
         WHERE pph.policy_header_id = par_policy_header_id
           AND pph.policy_id = pp.policy_id;
        RETURN v_active_pol_payment_term_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_active_policy_pay_term_id;
    
    BEGIN
      vr_acq_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id);
    
      IF vr_acq_payment_template.t_payment_terms_id =
         get_active_policy_pay_term_id(vr_acq_payment_template.policy_header_id)
      THEN
        v_result := TRUE;
      ELSE
        v_result := FALSE;
      END IF;
    
      RETURN v_result;
    END is_payment_terms_correct;
  
    /*Проверка совпадения брутто взноса при переходе статуса «Новый» в статус «Подтвержден» для шаблона платежа*/
    FUNCTION is_template_fee_correct(par_acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE)
      RETURN BOOLEAN IS
      vr_acq_payment_template dml_acq_payment_template.tt_acq_payment_template;
      vr_pol_header           dml_p_pol_header.tt_p_pol_header;
      v_result                BOOLEAN;
    
    BEGIN
      vr_acq_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id);
    
      vr_pol_header := dml_p_pol_header.get_record(vr_acq_payment_template.policy_header_id);
    
      v_result := is_fee_correct(par_fee               => vr_acq_payment_template.fee
                                ,par_active_version_id => vr_pol_header.policy_id
                                ,par_last_version_id   => vr_pol_header.last_ver_id
                                ,par_date              => vr_pol_header.start_date
                                ,par_only_fee          => v_only_fee);
    
      RETURN v_result;
    END is_template_fee_correct;
  
    /*Подобрать шаблон платежа по ИДС и ФИО*/
    FUNCTION find_template_by_ids_and_fio
    (
      par_ids p_pol_header.ids%TYPE
     ,par_fio contact.obj_name_orig%TYPE
    ) RETURN acq_payment_template.acq_payment_template_id%TYPE IS
      v_acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
    BEGIN
    
      SELECT pt.acq_payment_template_id
        INTO v_acq_payment_template_id
        FROM ven_acq_payment_template pt
       WHERE pt.pol_number = substr(par_ids, 1, 9)
         AND upper(pt.issuer_name) = upper(par_fio)
         AND pt.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('NEW');
    
      RETURN v_acq_payment_template_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
      WHEN too_many_rows THEN
        ex.raise('Подобрано несколько шаблонов регулярных платежей для ИДС=' || par_ids || ', ФИО ' ||
                 par_fio);
    END find_template_by_ids_and_fio;
  BEGIN
    vr_p_policy := dml_p_policy.get_record(par_pololicy_id);
  
    /*Для первой неотмененной версии ищем шаблон для регулярных платежей*/
    IF is_first_uncencelled_policy(par_p_pol_header => vr_p_policy.pol_header_id
                                  ,par_p_policy     => vr_p_policy.policy_id)
    THEN
      v_insured_fio := pkg_contact.get_contact_name_by_id(par_contact_id     => pkg_policy.get_policy_holder_id(p_policy_id => par_pololicy_id)
                                                         ,par_raise_on_error => FALSE);
    
      vr_pol_header := dml_p_pol_header.get_record(vr_p_policy.pol_header_id);
    
      v_acq_payment_template_id := find_template_by_ids_and_fio(par_ids => vr_pol_header.ids
                                                               ,par_fio => v_insured_fio);
    
      IF v_acq_payment_template_id IS NOT NULL
      THEN
        /*Указываем ссылку на ДС в шаблоне*/
        UPDATE acq_payment_template t
           SET t.policy_header_id = vr_pol_header.policy_header_id
         WHERE t.acq_payment_template_id = v_acq_payment_template_id;
      
        --Выполняем проверки
        IF NOT is_payment_terms_correct(v_acq_payment_template_id)
        THEN
          v_is_ok := FALSE;
          put_error('Периодичность договора не соответствует периодичности Заявления'
                   ,v_error_text);
        END IF;
      
        IF NOT is_template_fee_correct(v_acq_payment_template_id)
        THEN
          v_is_ok := FALSE;
          put_error('Размер страхового взноса указан неверно, невозможно создать регулярное списание'
                   ,v_error_text);
        END IF;
      
        IF v_is_ok
        THEN
          /*Шаблон становится подтвержденным, т.к. нашли ДС для него*/
          doc.set_doc_status(v_acq_payment_template_id, 'CONFIRMED');
        ELSE
          /*Ошибки пишем в примечание*/
          UPDATE ven_acq_payment_template pt
             SET pt.note = v_error_text
           WHERE pt.acq_payment_template_id = v_acq_payment_template_id;
          /*Доработка*/
          doc.set_doc_status(v_acq_payment_template_id, 'REVISION');
        END IF;
      END IF; --Конец если найден Шаблон платежа
    END IF; --Конец  Для первой неотмененной версии ищем шаблон для регулярных платежей
  
  END find_payment_template_4_policy;

  /*Признак пролонгации в зависимости от привязки БСО к продуктам, по которым предусмотрена пролонгация*/
  FUNCTION can_prolongate_by_bso(par_pol_num p_policy.pol_num%TYPE) RETURN BOOLEAN IS
    v_is_prolongation NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_is_prolongation
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM bso_series           bs
                  ,t_policy_form        tf
                  ,t_policyform_product tpp
                  ,t_product            tp
             WHERE bs.series_num = substr(par_pol_num, 1, 3) /*Первые 3 символа номера - серия БСО*/
               AND bs.t_product_conds_id = tf.t_policy_form_id
               AND tf.t_policy_form_id = tpp.t_policy_form_id
               AND tpp.t_product_id = tp.product_id
               AND tp.is_prolongation = 1 /*Для пролонгации*/
            );
    RETURN v_is_prolongation = 1;
  END can_prolongate_by_bso;

  /**Признак пролонгации ДС*/
  FUNCTION can_prolongate(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
    v_is_prolongation t_product.is_prolongation%TYPE;
  BEGIN
  
    SELECT pr.is_prolongation
      INTO v_is_prolongation
      FROM p_pol_header ph
          ,t_product    pr
     WHERE ph.product_id = pr.product_id
       AND ph.policy_header_id = par_pol_header_id;
  
    RETURN v_is_prolongation = 1;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN FALSE;
  END can_prolongate;

  /*Получить ИД периодичности оплаты по описанию*/
  FUNCTION get_payment_terms_id_by_desc(par_description t_payment_terms.description%TYPE)
    RETURN t_payment_terms.id%TYPE IS
    v_payment_terms_id t_payment_terms.id%TYPE;
  BEGIN
    v_payment_terms_id := dml_t_payment_terms.get_id_by_description(par_description    => par_description
                                                                   ,par_raise_on_error => FALSE);
  
    RETURN v_payment_terms_id;
  END get_payment_terms_id_by_desc;

  /*Номер шаблона из последовательности*/
  FUNCTION get_acq_templ_num RETURN document.num%TYPE IS
    v_num document.num%TYPE;
  BEGIN
    SELECT to_char(sq_acq_payment_template_num.nextval) INTO v_num FROM dual;
    RETURN v_num;
  END get_acq_templ_num;

  /*Проверка корректности данных в запросе от сайта*/
  PROCEDURE verify_request_data(par_data JSON) IS
    l_is_exists                 NUMBER;
    v_payment_terms_brief       t_payment_terms.brief%TYPE;
    v_payment_terms_description t_payment_terms.description%TYPE;
  BEGIN
    assert_deprecated(par_data.get('pol_header_id')
                      .get_number IS NULL AND par_data.get('pol_num').get_string IS NULL
                     ,'Должен быть указан номер договора или его ID');
  
    assert_deprecated(TRIM(par_data.get('fio').get_string) IS NULL
                     ,'Должно быть указано ФИО');
  
    assert_deprecated(par_data.get('fee').get_number IS NULL
                     ,'Должен быть указан взнос');
    assert_deprecated(par_data.get('fee').get_number <= 0
                     ,'Взнос должен быть больше нуля');
  
    assert_deprecated(par_data.get('currency').get_string IS NULL
                     ,'Валюта должна быть указана');
  
    assert_deprecated(par_data.get('is_agreed').get_number IS NULL
                     ,'Должен быть указан флаг согласия');
    assert_deprecated(par_data.get('is_agreed').get_number NOT IN (0, 1)
                     ,'Флаг согласия должен быть равен 0 или 1');
    assert_deprecated(par_data.get('ip').get_number NOT IN (0, 1)
                     ,'Не указан IP клиента');
  
    IF par_data.exist('payment_terms_brief')
    THEN
      v_payment_terms_brief := par_data.get('payment_terms_brief').get_string;
      SELECT COUNT(*)
        INTO l_is_exists
        FROM dual
       WHERE EXISTS
       (SELECT NULL FROM t_payment_terms t WHERE t.brief = nvl(v_payment_terms_brief, t.brief));
      assert_deprecated(l_is_exists = 0
                       ,'Некорректная периодичность оплаты (БРИФ): ' || v_payment_terms_brief);
    END IF;
  
    IF par_data.exist('payment_terms')
    THEN
      v_payment_terms_description := par_data.get('payment_terms').get_string;
      SELECT COUNT(*)
        INTO l_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM t_payment_terms t
               WHERE t.description = nvl(v_payment_terms_description, t.description));
      assert_deprecated(l_is_exists = 0
                       ,'Некорректное наименование периодичности оплаты: ' ||
                        v_payment_terms_description);
    END IF;
  END verify_request_data;

  /*Ответ сайту*/
  FUNCTION make_response(par_response t_response) RETURN JSON IS
    v_result JSON := JSON();
  BEGIN
    v_result.put('status', par_response.status);
    v_result.put('error_text', par_response.errors);
    v_result.put('payment_type', par_response.payment_type);
    v_result.put('rec_pmnt_id', par_response.template_num);
    v_result.put('act_period', par_response.period);
    v_result.put('pol_header_id', par_response.pol_header_id);
  
    v_result.put('fee_rur', par_response.fee_rur);
    v_result.put('adm_cost_rur', par_response.adm_cost_rur);
    v_result.put('payment_count', par_response.payment_count);
    v_result.put('first_operation_date', par_response.first_operation_date);
    v_result.put('payment_terms', par_response.payment_terms_description);
    v_result.put('payment_terms_brief', par_response.payment_terms_brief);
  
    RETURN v_result;
  END make_response;

  /*Перевести платеж в рубли*/
  FUNCTION fee_to_rur
  (
    par_amount      acq_internet_payment.amount%TYPE
   ,par_currency_id NUMBER
   ,par_date        DATE := SYSDATE
  ) RETURN acq_internet_payment.amount%TYPE IS
    v_fee_rur acq_internet_payment.amount%TYPE;
  BEGIN
  
    assert_deprecated(par_currency_id IS NULL, 'Валюта должна быть задана');
  
    IF par_currency_id = gc_fund_rur_id
    THEN
      v_fee_rur := par_amount;
    ELSE
      v_fee_rur := ROUND(par_amount *
                         acc_new.get_rate_by_id(gc_rate_type_cb_id, par_currency_id, par_date)
                        ,2);
    END IF;
    RETURN v_fee_rur;
  END fee_to_rur;

  FUNCTION fee_to_rur
  (
    par_amount   acq_internet_payment.amount%TYPE
   ,par_currency fund.brief%TYPE
   ,par_date     DATE := SYSDATE
  ) RETURN acq_internet_payment.amount%TYPE IS
    v_fee_rur acq_internet_payment.amount%TYPE;
    v_fund_id NUMBER;
  BEGIN
  
    assert_deprecated(par_currency IS NULL, 'Валюта должна быть задана');
  
    v_fund_id := dml_fund.get_id_by_brief(upper(par_currency));
  
    RETURN fee_to_rur(par_amount => par_amount, par_currency_id => v_fund_id, par_date => par_date);
  END fee_to_rur;

  /*Заполнение структуры данных по данным от сайта*/
  FUNCTION init_data_from_request(par_request JSON) RETURN t_request IS
    vr_resust t_request;
  BEGIN
  
    vr_resust.pol_header_id := par_request.get('pol_header_id').get_string;
    vr_resust.pol_number    := par_request.get('pol_num').get_string;
    vr_resust.fio           := par_request.get('fio').get_string;
    vr_resust.currency      := upper(par_request.get('currency').get_string);
    vr_resust.is_agreed     := par_request.get('is_agreed').get_number;
    vr_resust.fee           := par_request.get('fee').get_number;
    vr_resust.ac_payment_id := par_request.get('payment_id').get_number;
    vr_resust.grace_date    := to_date(par_request.get('grace_date').get_string, 'dd.mm.yyyy');
    IF par_request.exist('payment_terms_brief')
    THEN
      vr_resust.payment_terms := par_request.get('payment_terms_brief').get_string;
    END IF;
    IF par_request.exist('adm_cost')
    THEN
      vr_resust.admin_exp := par_request.get('adm_cost').get_number;
    END IF;
    IF par_request.exist('ip')
    THEN
      vr_resust.ip := par_request.get('ip').get_string;
    END IF;
    IF par_request.exist('pol_start_date')
    THEN
      vr_resust.pol_start_date := to_date(par_request.get('pol_start_date').get_string, 'dd.mm.yyyy');
    END IF;
    IF par_request.exist('pol_end_date')
    THEN
      vr_resust.pol_end_date := to_date(par_request.get('pol_end_date').get_string, 'dd.mm.yyyy');
    END IF;
    IF par_request.exist('postal_address')
    THEN
      vr_resust.postal_address := par_request.get('postal_address').get_string;
    END IF;
    IF par_request.exist('cell_phone')
    THEN
      vr_resust.cell_phone := par_request.get('cell_phone').get_string;
    END IF;
  
    RETURN vr_resust;
  END init_data_from_request;

  /*Оплата по ИД Договора страхования (при запросе из Личного кабинета)*/
  PROCEDURE payment_by_pol_header_id
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
    vr_active_policy           dml_p_policy.tt_p_policy;
    vr_pol_header              p_pol_header%ROWTYPE;
    vr_request                 t_request; --Запрос
    vr_response                t_response; --Ответ сайту
    v_act_version_status_brief doc_status_ref.brief%TYPE;
    v_debt                     ac_payment.amount%TYPE;
    v_paid_amount              ac_payment.amount%TYPE;
    v_admin_exp_from_policy    acq_payment_template.admin_expenses%TYPE := 0;
    v_templ_num                document.num%TYPE; --Номер шаблона
    v_acq_payment_template_id  ac_payment.payment_templ_id%TYPE;
    v_payment_count            NUMBER; --Количество платежей
    v_first_operation_date     DATE; --Дата первого платежа
    vr_t_payment_terms         dml_t_payment_terms.tt_t_payment_terms;
    vr_epg                     dml_ac_payment.tt_ac_payment;
    v_epg_id                   ac_payment.payment_id%TYPE;
    v_only_fee                 p_cover.fee%TYPE;
  
    /*Данный платеж единовременный*/
    FUNCTION is_single_payment
    (
      par_is_agree        NUMBER
     ,par_payment_term_id t_payment_terms.id%TYPE
     ,par_pol_header_id   p_pol_header.policy_header_id%TYPE
    ) RETURN BOOLEAN IS
      vr_payment_term dml_t_payment_terms.tt_t_payment_terms;
    BEGIN
      vr_payment_term := dml_t_payment_terms.get_record(par_payment_term_id);
      RETURN par_is_agree = 0 /*Нет согласия на регулярные списания*/
      OR(vr_payment_term.brief = 'Единовременно' AND NOT can_prolongate(par_pol_header_id)) /*Единоврменный при отсутсвии флага пролонгации*/
      ;
    END is_single_payment;
  
    /*Проверка версии ДС, что он не отменен и т.д.*/
    FUNCTION is_valid_version_status(par_status_brief doc_status_ref.brief%TYPE) RETURN BOOLEAN IS
    BEGIN
      RETURN par_status_brief NOT IN('CANCEL'
                                    ,'QUIT'
                                    ,'QUIT_DECL'
                                    ,'QUIT_REQ_GET'
                                    ,'QUIT_REQ_QUERY'
                                    ,'QUIT_TO_PAY'
                                    ,'READY_TO_CANCEL'
                                    ,'STOPED'
                                    ,'TO_QUIT'
                                    ,'TO_QUIT_CHECKED'
                                    ,'TO_QUIT_CHECK_READY');
    END is_valid_version_status;
  
    /*Проверка страхователя*/
    FUNCTION is_valid_issuer
    (
      par_active_version_id p_policy.policy_id%TYPE
     ,par_issuer_name       contact.obj_name%TYPE
    ) RETURN BOOLEAN IS
      v_pol_issuer_name contact.obj_name%TYPE;
    BEGIN
      SELECT upper(pi.contact_name)
        INTO v_pol_issuer_name
        FROM v_pol_issuer pi
       WHERE pi.policy_id = par_active_version_id;
    
      RETURN v_pol_issuer_name = upper(par_issuer_name);
    END is_valid_issuer;
  
    /*Проверка существования ДС*/
    FUNCTION is_exists_policy(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM p_pol_header ph
       WHERE ph.policy_header_id = par_pol_header_id;
    
      RETURN v_is_exists = 1;
    END is_exists_policy;
  
    FUNCTION is_single_terms(par_payment_terms_id t_payment_terms.id%TYPE) RETURN BOOLEAN IS
      v_payment_terms_brief t_payment_terms.brief%TYPE;
    BEGIN
      SELECT pt.brief
        INTO v_payment_terms_brief
        FROM t_payment_terms pt
       WHERE pt.id = par_payment_terms_id;
      RETURN v_payment_terms_brief = 'Единовременно';
    END is_single_terms;
  
    FUNCTION is_exists_template(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM acq_payment_template pt
                    ,document             dc
                    ,doc_status_ref       dsr
               WHERE pt.policy_header_id = par_pol_header_id
                 AND pt.acq_payment_template_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CONFIRMED');
      RETURN v_is_exists = 1;
    END is_exists_template;
  
    FUNCTION get_payment_amount(par_ac_payment_id ac_payment.payment_id%TYPE)
      RETURN ac_payment.amount%TYPE IS
      v_amount ac_payment.amount%TYPE;
    BEGIN
      BEGIN
        SELECT ac.amount INTO v_amount FROM ac_payment ac WHERE ac.payment_id = par_ac_payment_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      RETURN v_amount;
    END;
  
    /*Найти шаблон в статусе "Проект"*/
    FUNCTION find_template_by_pol_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
      RETURN acq_payment_template.acq_payment_template_id%TYPE IS
      v_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
    BEGIN
      BEGIN
        SELECT pt.acq_payment_template_id
          INTO v_payment_template_id
          FROM acq_payment_template pt
              ,document             dc
              ,doc_status_ref       dsr
         WHERE pt.policy_header_id = par_pol_header_id
           AND pt.acq_payment_template_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'PROJECT';
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
        WHEN too_many_rows THEN
          NULL;
      END;
      RETURN v_payment_template_id;
    END find_template_by_pol_header;
  
    /*Подбор ЭПГ*/
    FUNCTION get_epg(par_policy_header_id p_pol_header.policy_header_id%TYPE)
      RETURN ac_payment.payment_id%TYPE IS
      v_payment_id ac_payment.payment_id%TYPE;
    BEGIN
      SELECT MIN(ap.payment_id)
        INTO v_payment_id
        FROM p_pol_header pph
            ,doc_doc      dd
            ,ac_payment   ap
            ,document     dc
       WHERE pph.policy_header_id = par_policy_header_id
         AND dd.parent_id = pph.policy_id
         AND dd.child_id = ap.payment_id
         AND ap.payment_id = dc.document_id
         AND dc.doc_status_ref_id IN
             (dml_doc_status_ref.get_id_by_brief('NEW'), dml_doc_status_ref.get_id_by_brief('TO_PAY'));
      RETURN v_payment_id;
    END get_epg;
  
  BEGIN
    /*Инициалицация данных по запросу от сайта*/
    vr_request := init_data_from_request(par_request => par_request);
  
    vr_pol_header      := pkg_policy.get_header_record(par_policy_header_id => vr_request.pol_header_id
                                                      ,par_raise_on_error   => FALSE);
    vr_response.status := gc_ok;
    /* Нашли ДС, все ок */
    IF vr_pol_header.policy_header_id IS NOT NULL
    THEN
    
      vr_active_policy := dml_p_policy.get_record(par_policy_id => vr_pol_header.policy_id);
    
      /*Если это единовременный платеж, то возвращаем ответ*/
      IF is_single_payment(vr_request.is_agreed
                          ,vr_active_policy.payment_term_id
                          ,vr_pol_header.policy_header_id)
      THEN
      
        vr_response.status       := gc_ok;
        vr_response.payment_type := gc_single;
        /*Переводим платеж в рубли для банка*/
        vr_response.fee_rur := fee_to_rur(par_amount   => vr_request.fee
                                         ,par_currency => vr_request.currency);
      ELSE
        /* Если для договора страхования найден
        хотя бы один шаблон платежа в статусе "Подтвержден" */
        IF is_exists_template(par_pol_header_id => vr_pol_header.policy_header_id)
        THEN
          vr_response.status := gc_error;
          put_error('Списание по договору страхования уже осуществляется'
                   ,vr_response.errors);
        ELSE
        
          v_act_version_status_brief := doc.get_doc_status_brief(doc_id => vr_active_policy.policy_id);
          /* Проверка действия ДС */
          IF NOT is_valid_version_status(par_status_brief => v_act_version_status_brief)
          THEN
            vr_response.status := gc_error;
            put_error('Договор не действует', vr_response.errors);
          END IF;
        
          /* Проверка валюты */
          IF vr_pol_header.fund_id != dml_fund.get_id_by_brief(vr_request.currency)
          THEN
            vr_response.status := gc_error;
            put_error('Валюта договора не соответствует указанной валюте. Невозможно сформировать регулярное списание'
                     ,vr_response.errors);
          END IF;
        
          /*Если Дата ЭПГ (срок платежа - grace_date) из ЛК пустой, значит происходит оплата с сайта и нужно подбирать ЭПГ*/
          IF vr_request.grace_date IS NULL
          THEN
            v_epg_id := get_epg(par_policy_header_id => vr_pol_header.policy_header_id);
            vr_epg   := dml_ac_payment.get_record(par_payment_id => v_epg_id);
            /*Заполняем данные запроса от сайта найденной ЭПГ для выполнения проверок*/
            vr_request.ac_payment_id := v_epg_id;
            vr_request.grace_date    := vr_epg.grace_date;
          ELSE
            vr_epg := dml_ac_payment.get_record(par_payment_id => vr_request.ac_payment_id);
          END IF;
          /*Конец Если Дата ЭПГ (срок платежа - grace_date) из ЛК пустой, значит происходит оплата с сайта и нужно подбирать ЭПГ*/
        
          IF NOT is_fee_correct(par_fee               => vr_request.fee
                               ,par_active_version_id => vr_pol_header.policy_id
                               ,par_last_version_id   => vr_pol_header.last_ver_id
                               ,par_date              => vr_epg.due_date /*Дата графика для определения годовщины*/
                               ,par_only_fee          => v_only_fee)
          THEN
            vr_response.status := gc_error;
            put_error('Размер страхового взноса указан неверно, невозможно создать регулярное списание'
                     ,vr_response.errors);
          END IF;
        
          v_paid_amount := nvl(ins.pkg_payment.get_set_off_amount(vr_request.ac_payment_id
                                                                 ,vr_pol_header.policy_header_id
                                                                 ,NULL)
                              ,0);
          /* Если дата платежа из ЛК < текущей, нужно получить сумму задолженности и сругаться*/
          IF vr_request.grace_date < SYSDATE
          THEN
            v_debt             := get_payment_amount(par_ac_payment_id => vr_request.ac_payment_id) -
                                  v_paid_amount;
            vr_response.status := gc_error;
            put_error('Невозможно создать регулярное списание, т.к. имеется просроченная задолженность в размере ' ||
                      to_char(v_debt)
                     ,vr_response.errors);
          END IF;
        
          IF v_paid_amount > 0
          THEN
            vr_response.status := gc_error;
            put_error('Невозможно создать регулярное списание, т.к. имеется частичная оплата по взносу в размере ' ||
                      to_char(v_paid_amount) || '. Необходимо оплатить взнос полностью.'
                     ,vr_response.errors);
          END IF;
        
          IF vr_response.status = gc_ok
          THEN
            /* Если не было ошибок, формируем шаблон платежа */
            v_admin_exp_from_policy := pkg_policy.get_admin_cost_fee(p_pol_id => vr_active_policy.policy_id);
          
            v_templ_num := get_acq_templ_num;
          
            v_acq_payment_template_id := find_template_by_pol_header(par_pol_header_id => vr_pol_header.policy_header_id);
            /*Если был шаблон в статусе "Прокт, то удаляем"*/
            -- Мизинов Г.В. заявка №372104
            /*     IF v_acq_payment_template_id IS NOT NULL
            THEN
              dml_acq_payment_template.delete_record(par_acq_payment_template_id => v_acq_payment_template_id);
            END IF;*/
          
            /*Создаем шаблон платежа для регулярных списаний в статусе "Проект"*/
            dml_acq_payment_template.insert_record(par_pol_number              => vr_request.pol_number
                                                  ,par_issuer_name             => vr_request.fio
                                                  ,par_fee                     => v_only_fee --Взнос без админ издержек из ДС
                                                  ,par_agreement_flag          => vr_request.is_agreed
                                                  ,par_ip_address              => vr_request.ip
                                                  ,par_grace_date              => vr_request.grace_date --Дата ЭПГ (срок платежа - grace_date) -Либо приходит из ЛК, или заполняется подобранной ЭПГ
                                                  ,par_till                    => last_day(trunc(vr_active_policy.end_date
                                                                                                ,'dd'))
                                                  ,par_prolongation_flag       => 0
                                                  ,par_doc_templ_id            => doc.templ_id_by_brief('ACQ_PAYMENT_TEMPLATE')
                                                  ,par_reg_date                => SYSDATE
                                                  ,par_num                     => v_templ_num
                                                  ,par_admin_expenses          => v_admin_exp_from_policy
                                                  ,par_policy_header_id        => vr_pol_header.policy_header_id
                                                  ,par_t_payment_terms_id      => vr_active_policy.payment_term_id
                                                  ,par_pay_fund_id             => dml_fund.get_id_by_brief(vr_request.currency)
                                                  ,par_acq_payment_template_id => v_acq_payment_template_id);
          
            doc.set_doc_status(p_doc_id => v_acq_payment_template_id, p_status_brief => 'PROJECT');
            --Периодичность оплаты для передачи сайту
            vr_t_payment_terms := dml_t_payment_terms.get_record(par_id => vr_active_policy.payment_term_id);
          
            /*Предварительный расчет графика списания*/
            precalc_payment_schedule(par_payment_template_id      => v_acq_payment_template_id
                                    ,par_base_date                => vr_request.grace_date
                                    ,par_pol_end_date             => NULL
                                    ,par_prolongation_flag        => CASE
                                                                       WHEN can_prolongate_by_bso(vr_request.pol_number) THEN
                                                                        1
                                                                       ELSE
                                                                        0
                                                                     END
                                    ,par_payment_count_out        => v_payment_count
                                    ,par_first_operation_date_out => v_first_operation_date);
            /* Говорим, что все ок */
            vr_response.status                    := gc_ok;
            vr_response.payment_type              := gc_primary_recurrent;
            vr_response.pol_header_id             := vr_pol_header.policy_header_id;
            vr_response.period                    := last_day(trunc(vr_active_policy.end_date, 'dd'));
            vr_response.fee_rur                   := fee_to_rur(par_amount   => vr_request.fee
                                                               ,par_currency => vr_request.currency
                                                               ,par_date     => SYSDATE);
            vr_response.adm_cost_rur              := fee_to_rur(par_amount   => v_admin_exp_from_policy
                                                               ,par_currency => vr_request.currency
                                                               ,par_date     => SYSDATE);
            vr_response.template_num              := v_templ_num;
            vr_response.payment_count             := v_payment_count;
            vr_response.first_operation_date      := v_first_operation_date;
            vr_response.payment_terms_brief       := vr_t_payment_terms.brief;
            vr_response.payment_terms_description := vr_t_payment_terms.description;
          END IF; --Конец все проверки пройдены, создан шаблон в статусе "Проект"
        END IF; --Конец регулярное списание уже осуществляется
      END IF; --Конец если не единовременный платеж
    
    ELSE
      vr_response.status := gc_error;
      put_error('Договор не найден по идентификатору'
               ,vr_response.errors);
    END IF; --Конец если ДС не найден по ИД
  
    par_response := make_response(par_response => vr_response);
  END payment_by_pol_header_id;

  /*Оплата по номеру заявления - 9-ти значный номер*/
  PROCEDURE payment_by_notice_num
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
    v_pol_header_id              p_pol_header.policy_header_id%TYPE;
    vr_request                   t_request; --Запрос
    vr_response                  t_response; --Ответ сайту
    v_acq_payment_template_id    acq_payment_template.acq_payment_template_id%TYPE;
    v_admin_exp_from_policy      acq_payment_template.admin_expenses%TYPE := 0;
    v_payment_count              NUMBER; --Количество платежей
    v_first_operation_date       DATE; --Дата первого платежа
    v_templ_num                  document.num%TYPE;
    v_request_with_pol_header_id JSON := JSON();
    vr_t_payment_terms           dml_t_payment_terms.tt_t_payment_terms; --периодичность платежей
  
    /*Поиск ДС по первым 9 символам ИДС и ФИО страхователя*/
    FUNCTION get_pol_header_id_by_ids_num
    (
      par_num VARCHAR2
     ,par_fio VARCHAR2
    ) RETURN p_pol_header.policy_header_id%TYPE IS
      v_pol_header_id p_pol_header.policy_header_id%TYPE;
    BEGIN
      SELECT pph.policy_header_id
        INTO v_pol_header_id
        FROM p_pol_header     pph
            ,p_policy_contact pc
            ,contact          cn
       WHERE substr(ids, 1, 9) = par_num
         AND pc.policy_id = pph.policy_id
         AND pc.contact_id = cn.contact_id
         AND pc.contact_policy_role_id = 6 /*Страхователь*/
         AND cn.obj_name = upper(par_fio);
    
      RETURN v_pol_header_id;
    
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        RETURN NULL;
    END get_pol_header_id_by_ids_num;
  
    /*Поиск ДС по номеру ДС и ФИО страхователя*/
    FUNCTION get_pol_header_id_by_pol_num
    (
      par_num VARCHAR2
     ,par_fio VARCHAR2
    ) RETURN p_pol_header.policy_header_id%TYPE IS
      v_pol_header_id p_pol_header.policy_header_id%TYPE;
    BEGIN
      SELECT pp.pol_header_id
        INTO v_pol_header_id
        FROM p_policy         pp
            ,p_policy_contact pc
            ,contact          cn
       WHERE pp.pol_num = par_num
         AND pc.policy_id = pp.policy_id
         AND pc.contact_id = cn.contact_id
         AND pc.contact_policy_role_id = 6 /*Страхователь*/
         AND cn.obj_name = upper(par_fio);
    
      RETURN v_pol_header_id;
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        RETURN NULL;
    END get_pol_header_id_by_pol_num;
  
    /*Найти шаблон в статусе "Проект"*/
    FUNCTION find_template_by_pol_num
    (
      par_pol_num p_policy.pol_num%TYPE
     ,par_fio     contact.obj_name_orig%TYPE
    ) RETURN acq_payment_template.acq_payment_template_id%TYPE IS
      v_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
    BEGIN
      BEGIN
        SELECT pt.acq_payment_template_id
          INTO v_payment_template_id
          FROM acq_payment_template pt
              ,document             dc
              ,doc_status_ref       dsr
         WHERE pt.pol_number = par_pol_num
           AND upper(pt.issuer_name) = upper(par_fio)
           AND pt.acq_payment_template_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'PROJECT';
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          NULL;
      END;
      RETURN v_payment_template_id;
    END find_template_by_pol_num;
  
    /*Проверка наличия шаблона в статусе "Подтвержден"*/
    FUNCTION is_exist_confirmed_template
    (
      par_pol_num          p_policy.pol_num%TYPE
     ,par_fio              contact.obj_name_orig%TYPE
     ,par_payment_terms_id t_payment_terms.id%TYPE
    ) RETURN BOOLEAN IS
      v_is_exists NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM acq_payment_template pt
                    ,document             dc
                    ,doc_status_ref       dsr
               WHERE pt.pol_number = par_pol_num
                 AND upper(pt.issuer_name) = upper(par_fio)
                 AND pt.t_payment_terms_id = par_payment_terms_id
                 AND pt.acq_payment_template_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief IN ('CONFIRMED', 'NEW'));
      RETURN v_is_exists = 1;
    END is_exist_confirmed_template;
  
    /*Проверка, переодичность оплаты не должна быть "Еженедельно" или "Ежедневно"*/
    FUNCTION is_unacceptable_periodicity(par_payment_terms_id t_payment_terms.id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ins.t_payment_terms t
               WHERE t.brief IN ('DAILY', 'WEEKLY')
                 AND t.id = par_payment_terms_id);
      RETURN v_is_exists = 1;
    END is_unacceptable_periodicity;
  
  BEGIN
    /*Заполняем структуру данными из запроса от сайта*/
    vr_request         := init_data_from_request(par_request => par_request);
    vr_response.status := gc_ok;
    /*Поиск в ИДС*/
    v_pol_header_id := get_pol_header_id_by_ids_num(par_num => vr_request.pol_number
                                                   ,par_fio => vr_request.fio);
    /*Поиск по номеру договора*/
    IF v_pol_header_id IS NULL
    THEN
      v_pol_header_id := get_pol_header_id_by_pol_num(par_num => vr_request.pol_number
                                                     ,par_fio => vr_request.fio);
    END IF;
  
    /*Договор страхования не найден*/
    IF v_pol_header_id IS NULL
    THEN
      /*Проверяем наличие шаблона в статусе "Подтвержден"*/
      IF is_exist_confirmed_template(par_pol_num          => vr_request.pol_number
                                    ,par_fio              => vr_request.fio
                                    ,par_payment_terms_id => dml_t_payment_terms.get_id_by_brief(vr_request.payment_terms))
      THEN
        vr_response.status := gc_error;
        put_error('Списание по договору страхования уже осуществляется'
                 ,vr_response.errors);
      END IF;
    
      vr_t_payment_terms := dml_t_payment_terms.get_rec_by_brief(par_brief          => vr_request.payment_terms
                                                                ,par_raise_on_error => FALSE);
    
      IF is_unacceptable_periodicity(vr_t_payment_terms.id)
      THEN
        vr_response.status := gc_error;
        --ex.raise_custom(par_message => 'Переодичность оплаты не может быть "Ежедневно" или "Еженедельно".');
        put_error('Переодичность оплаты не может быть "Ежедневно" или "Еженедельно".'
                 ,vr_response.errors);
      END IF;
    
      IF vr_response.status = gc_ok
      THEN
        /* Если не было ошибок, формируем шаблон платежа */
        v_templ_num               := get_acq_templ_num;
        v_acq_payment_template_id := find_template_by_pol_num(par_pol_num => vr_request.pol_number
                                                             ,par_fio     => vr_request.fio);
        /*Если был шаблон в статусе "Проект, то удаляем"*/
        /*        IF v_acq_payment_template_id IS NOT NULL
        THEN
          dml_acq_payment_template.delete_record(par_acq_payment_template_id => v_acq_payment_template_id);
        END IF;*/
      
        vr_t_payment_terms := dml_t_payment_terms.get_rec_by_brief(par_brief          => vr_request.payment_terms
                                                                  ,par_raise_on_error => FALSE);
        /*Регистрируем шаблон в статусе "Проект"*/
        dml_acq_payment_template.insert_record(par_pol_number              => vr_request.pol_number
                                              ,par_issuer_name             => vr_request.fio
                                              ,par_fee                     => vr_request.fee -
                                                                              nvl(vr_request.admin_exp
                                                                                 ,0) /*Страховой взнос в валюте договора за минусом админ. издержек*/
                                              ,par_agreement_flag          => vr_request.is_agreed
                                              ,par_ip_address              => vr_request.ip
                                              ,par_grace_date              => vr_request.pol_start_date +
                                                                              gc_default_privilege_period /*Срок платежа (Срок платежа по графику "Дата начала ДС"+Льготный период)*/
                                              ,par_till                    => vr_request.pol_end_date /*Дата действия списания*/
                                              ,par_prolongation_flag       => 0
                                              ,par_doc_templ_id            => doc.templ_id_by_brief('ACQ_PAYMENT_TEMPLATE')
                                              ,par_pay_fund_id             => dml_fund.get_id_by_brief(vr_request.currency) --Валюта платежа
                                              ,par_reg_date                => SYSDATE
                                              ,par_num                     => v_templ_num
                                              ,par_admin_expenses          => vr_request.admin_exp
                                              ,par_policy_header_id        => v_pol_header_id
                                              ,par_t_payment_terms_id      => vr_t_payment_terms.id
                                              ,par_policy_start_date       => vr_request.pol_start_date
                                              ,par_policy_end_date         => vr_request.pol_end_date
                                              ,par_postal_address          => vr_request.postal_address
                                              ,par_cell_phone              => vr_request.cell_phone
                                              ,par_acq_payment_template_id => v_acq_payment_template_id);
      
        doc.set_doc_status(p_doc_id => v_acq_payment_template_id, p_status_brief => 'PROJECT');
        /*Предварительный расчет графика списания*/
        precalc_payment_schedule(par_payment_template_id      => v_acq_payment_template_id
                                ,par_base_date                => vr_request.pol_start_date +
                                                                 gc_default_privilege_period /*Срок платежа (Срок платежа по графику "Дата начала ДС"+Льготный период)*/
                                ,par_pol_end_date             => vr_request.pol_end_date
                                ,par_prolongation_flag        => CASE
                                                                   WHEN can_prolongate_by_bso(vr_request.pol_number) THEN
                                                                    1
                                                                   ELSE
                                                                    0
                                                                 END
                                ,par_payment_count_out        => v_payment_count
                                ,par_first_operation_date_out => v_first_operation_date);
        /*Формируем ответ сайту*/
        /* Говорим, что все ок */
        vr_response.status       := gc_ok;
        vr_response.payment_type := gc_primary_recurrent;
        --vr_response.period       := last_day(trunc(vr_active_policy.end_date, 'dd'));
        vr_response.template_num              := v_templ_num;
        vr_response.fee_rur                   := fee_to_rur(vr_request.fee, vr_request.currency);
        vr_response.adm_cost_rur              := fee_to_rur(vr_request.admin_exp, vr_request.currency);
        vr_response.payment_count             := v_payment_count;
        vr_response.first_operation_date      := v_first_operation_date;
        vr_response.payment_terms_brief       := vr_t_payment_terms.brief;
        vr_response.payment_terms_description := vr_t_payment_terms.description;
        vr_response.period                    := vr_request.pol_end_date;
      END IF; --Конец проверки шаблона в статусе "Подтвержден"
      /*Формируем JSON для сайта из record*/
      par_response := make_response(par_response => vr_response);
    ELSE
      /*ДС найден*/
      v_request_with_pol_header_id := par_request;
      v_request_with_pol_header_id.put(pair_name => 'pol_header_id', pair_value => v_pol_header_id);
      payment_by_pol_header_id(par_request  => v_request_with_pol_header_id
                              ,par_response => par_response);
    END IF; --Конец ДС не найден
  
  END payment_by_notice_num;

  /*Оплата по номеру Договора страхования 10 знаков*/
  PROCEDURE payment_by_policy_num
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
    v_pol_header_id              p_pol_header.policy_header_id%TYPE;
    vr_request                   t_request; --Запрос
    vr_response                  t_response; --Ответ сайту
    v_request_with_pol_header_id JSON := JSON();
  
    /*Поиск ДС по  ИДС и ФИО страхователя*/
    FUNCTION get_pol_header_id_by_ids_num
    (
      par_num VARCHAR2
     ,par_fio VARCHAR2
    ) RETURN p_pol_header.policy_header_id%TYPE IS
      v_pol_header_id p_pol_header.policy_header_id%TYPE;
    BEGIN
      SELECT pph.policy_header_id
        INTO v_pol_header_id
        FROM p_pol_header     pph
            ,p_policy_contact pc
            ,contact          cn
       WHERE pph.ids = par_num
         AND pc.policy_id = pph.policy_id
         AND pc.contact_id = cn.contact_id
         AND pc.contact_policy_role_id = 6 /*Страхователь*/
         AND cn.obj_name = upper(par_fio);
      RETURN v_pol_header_id;
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        RETURN NULL;
    END get_pol_header_id_by_ids_num;
  BEGIN
    /*Заполняем структуру данными из запроса от сайта*/
    vr_request := init_data_from_request(par_request => par_request);
    /*Поиск в ИДС*/
    v_pol_header_id := get_pol_header_id_by_ids_num(par_num => vr_request.pol_number
                                                   ,par_fio => vr_request.fio);
    IF v_pol_header_id IS NULL
    THEN
      /*Формируем ответ*/
      vr_response.status := gc_error;
      put_error('Невозможно зарегистрировать регулярное списание, так как договор страхования не найден. Проверьте номер договора страхования и ФИО Страхователя'
               ,vr_response.errors);
      /*Формируем JSON для сайта из record*/
      par_response := make_response(par_response => vr_response);
    ELSE
      /*ДС найден*/
      v_request_with_pol_header_id := par_request;
      v_request_with_pol_header_id.put(pair_name => 'pol_header_id', pair_value => v_pol_header_id);
      payment_by_pol_header_id(par_request  => v_request_with_pol_header_id
                              ,par_response => par_response);
    END IF; --Конец если не нашли ДС
  END payment_by_policy_num;

  /*Единовременный платеж с сайта*/
  PROCEDURE payment_once
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
    vr_request  t_request; --Запрос
    vr_response t_response; --Ответ сайту
  
  BEGIN
    /*Инициалицация данных по запросу от сайта*/
    vr_request := init_data_from_request(par_request => par_request);
  
    vr_response.status       := gc_ok;
    vr_response.payment_type := gc_single;
    /*Переводим платеж в рубли для банка*/
    vr_response.fee_rur := fee_to_rur(par_amount   => vr_request.fee
                                     ,par_currency => vr_request.currency);
    par_response        := make_response(par_response => vr_response);
  END payment_once;

  /* Регистрация платежа / проверка возможности проведения платежа */
  PROCEDURE check_payment
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
    v_pol_number_length NUMBER; --Кол-во символов в номере ДС
    v_pol_header_id     p_pol_header.policy_header_id%TYPE;
    v_pol_number        p_policy.pol_num%TYPE;
    v_is_agreed         NUMBER(1); --Признак согласия на регулярные списания
  BEGIN
    /* Проверяем полноту и корректность данных запроса */
    verify_request_data(par_data => par_request);
  
    v_pol_header_id := par_request.get('pol_header_id').get_string;
    v_pol_number    := trim(par_request.get('pol_num').get_string);
    v_is_agreed     := par_request.get('is_agreed').get_string;
  
    /*Обработка запроса на оплату из личного кабинета*/
    IF v_pol_header_id IS NOT NULL
    THEN
      /*Оплата по ИД договора страхования*/
      payment_by_pol_header_id(par_request => par_request, par_response => par_response);
      /*Обработка оплаты по номеру заявления или по номеру договора*/
    ELSIF v_pol_number IS NOT NULL
    THEN
			
      IF NOT regexp_like(v_pol_number, '^\d{9,10}$')
      THEN
        ex.raise('Номер договора может содержать только 9 или 10 цифр.');
      END IF;
		
      IF v_is_agreed = 1 /*Регулярное списание*/
      THEN
        /*В зависимости от количества символов в номере - это будет заявление (9 символов) или ДС (10 символов)*/
        v_pol_number_length := length(v_pol_number);
        CASE v_pol_number_length
          WHEN 9 THEN
            payment_by_notice_num(par_request => par_request, par_response => par_response);
          WHEN 10 THEN
            payment_by_policy_num(par_request => par_request, par_response => par_response);
          ELSE
            ex.raise('Не предусмотрена оплата по номеру документа, где количество символов равно ' ||
                     v_pol_number_length);
        END CASE;
      ELSE
        payment_once(par_request => par_request, par_response => par_response); --Единоразовый платеж с сайта
      END IF; --Конец регулярное списание или нет
    END IF; --конец есть ИД договора
  
  END check_payment;

  /* Получение уведомления о платеже */
  PROCEDURE process_payment
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
  
    TYPE t_response IS RECORD(
       operation VARCHAR2(20)
      ,status    VARCHAR2(5)
      ,errors    VARCHAR2(2000));
  
    vr_response t_response;
  
    v_payment_type            t_payment_type;
    v_payment_type_id         t_acq_payment_type.t_acq_payment_type_id%TYPE;
    v_acq_status_result_id    t_acq_status_result.t_acq_status_result_id%TYPE;
    v_acq_status_result_ps_id t_acq_status_result_ps.t_acq_status_result_ps_id%TYPE;
    v_t_acq_result_code_id    t_acq_result_code.t_acq_result_code_id%TYPE;
    v_acq_status_3dsecure_id  t_acq_status_3dsecure.t_acq_status_3dsecure_id%TYPE;
    v_pol_header_id           p_pol_header.policy_header_id%TYPE;
    v_fio                     contact.obj_name%TYPE;
    v_pol_number              p_policy.pol_num%TYPE;
    v_rrn                     acq_internet_payment.rrn%TYPE;
    v_approval_code           acq_internet_payment.approval_code%TYPE;
    v_card_number             acq_internet_payment.card_number%TYPE;
    v_mrch_transaction_id     acq_internet_payment.mrch_transaction_id%TYPE;
    v_email                   acq_internet_payment.email%TYPE;
    v_bank_trans_id           acq_internet_payment.bank_transaction_id%TYPE;
    v_acq_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE;
    v_result_brief            t_acq_status_result.brief%TYPE;
    v_result_ps_brief         t_acq_status_result_ps.brief%TYPE;
    v_3dsecure_brief          t_acq_status_3dsecure.brief%TYPE;
    v_trans_date              acq_internet_payment.transaction_date%TYPE;
    v_expiry_date             acq_payment_template.till%TYPE;
    v_payment_template_num    document.num%TYPE;
    v_payment_template_id     acq_payment_template.acq_payment_template_id%TYPE;
    vr_acq_payment_template   dml_acq_payment_template.tt_acq_payment_template;
    --v_acq_writeoff_sch_id     acq_writeoff_sch.acq_writeoff_sch_id%TYPE;
    v_result_code t_acq_result_code.result_code%TYPE;
    --vr_acq_result_code        dml_t_acq_result_code.tt_t_acq_result_code;
    --vr_acq_internet_payment   dml_acq_internet_payment.tt_acq_internet_payment;
  
    v_fee acq_internet_payment.amount%TYPE;
  
    FUNCTION make_response(par_response t_response) RETURN JSON IS
      v_result JSON := JSON();
    BEGIN
      v_result.put('operation', par_response.operation);
      v_result.put('status', par_response.status);
      v_result.put('error_text', par_response.errors);
    
      RETURN v_result;
    END make_response;
  
    PROCEDURE put_error
    (
      par_error       VARCHAR2
     ,par_error_stack IN OUT VARCHAR2
    ) IS
    BEGIN
      IF par_error_stack IS NULL
      THEN
        par_error_stack := par_error;
      ELSE
        par_error_stack := par_error_stack || chr(10) || par_error;
      END IF;
    END put_error;
  
    FUNCTION find_writeoff_schedule(par_template_num document.num%TYPE)
      RETURN acq_writeoff_sch.acq_writeoff_sch_id%TYPE IS
      v_schedule_id acq_writeoff_sch.acq_writeoff_sch_id%TYPE;
    BEGIN
      SELECT MIN(sc.acq_writeoff_sch_id)
        INTO v_schedule_id
        FROM acq_writeoff_sch     sc
            ,document             dc
            ,doc_status_ref       dsr
            ,acq_payment_template pt
            ,document             dct
            ,doc_status_ref       dsrt
       WHERE sc.acq_writeoff_sch_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'TO_WRITEOFF'
         AND sc.acq_payment_template_id = pt.acq_payment_template_id
         AND dc.num = par_template_num
         AND pt.acq_payment_template_id = dct.document_id
         AND dct.doc_status_ref_id = dsrt.doc_status_ref_id
         AND dsrt.brief = 'CONFIRMED';
      RETURN v_schedule_id;
    END find_writeoff_schedule;
  
    FUNCTION find_acq_internet_payment(par_acq_writeoff_sch_id acq_writeoff_sch.acq_writeoff_sch_id%TYPE)
      RETURN acq_internet_payment.acq_internet_payment_id%TYPE IS
      v_payment_id acq_internet_payment.acq_internet_payment_id%TYPE;
    BEGIN
      BEGIN
        SELECT ip.acq_internet_payment_id
          INTO v_payment_id
          FROM acq_internet_payment ip
              ,document             dc
              ,doc_status_ref       dsr
         WHERE ip.acq_internet_payment_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'TO_WRITEOFF'
           AND ip.acq_writeoff_sch_id = par_acq_writeoff_sch_id;
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          v_payment_id := NULL;
      END;
      RETURN v_payment_id;
    END find_acq_internet_payment;
  
    FUNCTION get_template_id_by_num(par_num document.num%TYPE)
      RETURN acq_payment_template.acq_payment_template_id%TYPE IS
      v_template_id acq_payment_template.acq_payment_template_id%TYPE;
    BEGIN
      BEGIN
        SELECT pt.acq_payment_template_id
          INTO v_template_id
          FROM acq_payment_template pt
              ,document             dc
         WHERE pt.acq_payment_template_id = dc.document_id
           AND dc.num = par_num;
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          NULL;
      END;
      RETURN v_template_id;
    END get_template_id_by_num;
  
  BEGIN
    vr_response.status    := gc_ok;
    vr_response.operation := 'payment';
  
    v_payment_type         := par_request.get('payment_type').get_number;
    v_payment_template_num := par_request.get('rec_pmnt_id').get_string;
    v_pol_header_id        := par_request.get('pol_header_id').get_number;
    v_fee                  := par_request.get('fee').get_number;
    v_fio                  := par_request.get('fio').get_string;
    v_pol_number           := trim(par_request.get('pol_num').get_string);
    v_rrn                  := par_request.get('rrn').get_number;
    v_approval_code        := par_request.get('approval_code').get_number;
    v_card_number          := par_request.get('card_number').get_string;
    v_mrch_transaction_id  := par_request.get('mrch_trans_id').get_string;
    v_email                := par_request.get('email').get_string;
    v_bank_trans_id        := par_request.get('trans_id').get_string;
    v_result_brief         := par_request.get('result').get_string;
    v_result_ps_brief      := par_request.get('result_ps').get_string;
    v_result_code          := par_request.get('result_code').get_string;
    v_3dsecure_brief       := par_request.get('3dsecure').get_string;
    v_trans_date           := to_date(par_request.get('trans_date').get_string
                                     ,'dd.mm.yyyy hh24:mi:ss');
    v_expiry_date          := last_day(to_date(par_request.get('rec_pmnt_expiry').get_string, 'mmrr'));
  
    v_acq_status_result_id    := dml_t_acq_status_result.get_id_by_brief(par_brief => v_result_brief);
    v_acq_status_result_ps_id := dml_t_acq_status_result_ps.get_id_by_brief(par_brief => v_result_ps_brief);
    -- При результате DECLINE и TIMEOUT может не быть result_code
    IF v_result_code IS NOT NULL
    THEN
      v_t_acq_result_code_id := dml_t_acq_result_code.get_id_by_result_code(par_result_code => v_result_code);
    END IF;
    v_acq_status_3dsecure_id := dml_t_acq_status_3dsecure.get_id_by_brief(par_brief => v_3dsecure_brief);
  
    IF v_payment_type IN (gc_single, gc_primary_recurrent)
    THEN
      v_payment_type_id := dml_t_acq_payment_type.get_id_by_brief(par_brief => CASE v_payment_type
                                                                                 WHEN 1 THEN
                                                                                  'SINGLE'
                                                                                 WHEN 2 THEN
                                                                                  'PRIMARY_RECURRENT'
                                                                               END);
      IF NOT regexp_like(v_pol_number, '^\d{9,10}$')
      THEN
        vr_response.status := gc_error;
        put_error('Номер договора может содержать только 9 или 10 цифр.',vr_response.errors);
      END IF;
    
      IF vr_response.status = gc_ok
         AND v_payment_type = gc_primary_recurrent
      THEN
        IF v_result_ps_brief = 'FINISHED'
        THEN
          v_payment_template_id := get_template_id_by_num(par_num => v_payment_template_num);
          IF v_payment_template_id IS NULL
          THEN
            vr_response.status := gc_error;
            put_error('Не найден шаблон с номером "' || v_payment_template_num || '"'
                     ,vr_response.errors);
          ELSE
            vr_acq_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => v_payment_template_id);
            /*Если есть ссылка на ДС, то шаблон в статус "Подтвержден"*/
            IF vr_acq_payment_template.policy_header_id IS NOT NULL
            THEN
              vr_acq_payment_template.till        := v_expiry_date;
              vr_acq_payment_template.card_number := v_card_number;
              dml_acq_payment_template.update_record(par_record => vr_acq_payment_template);
              doc.set_doc_status(p_doc_id => v_payment_template_id, p_status_brief => 'CONFIRMED');
            ELSE
              /*Нет ссылки на ДС, шаблон в статус "Новый" (платеж по номеру заявлния)*/
              vr_acq_payment_template.till        := v_expiry_date;
              vr_acq_payment_template.card_number := v_card_number;
              dml_acq_payment_template.update_record(par_record => vr_acq_payment_template);
              doc.set_doc_status(p_doc_id => v_payment_template_id, p_status_brief => 'NEW');
            END IF; --Конец если есть ссылка в шаблоне на ДС
          END IF;
        ELSE
          v_payment_template_id := get_template_id_by_num(par_num => v_payment_template_num);
          IF v_payment_template_id IS NULL
          THEN
            vr_response.status := gc_error;
            put_error('Не найден шаблон с номером "' || v_payment_template_num || '"'
                     ,vr_response.errors);
          ELSE
            vr_acq_payment_template                         := dml_acq_payment_template.get_record(par_acq_payment_template_id => v_payment_template_id);
            vr_acq_payment_template.acq_internet_payment_id := v_acq_internet_payment_id;
            vr_acq_payment_template.t_mpos_rejection_id     := pkg_t_mpos_rejection_dml.get_id_by_brief('BANK_REJECTION');
            vr_acq_payment_template.till                    := v_expiry_date;
            vr_acq_payment_template.card_number             := v_card_number;
            dml_acq_payment_template.update_record(par_record => vr_acq_payment_template);
            doc.set_doc_status(p_doc_id => v_payment_template_id, p_status_brief => 'CANCEL');
          END IF;
        END IF;
      END IF;
    
      IF vr_response.status = gc_ok
      THEN
        dml_acq_internet_payment.insert_record(par_acq_payment_type_id       => v_payment_type_id
                                              ,par_amount                    => v_fee
                                              ,par_t_acq_status_result_id    => v_acq_status_result_id
                                              ,par_t_acq_status_result_ps_id => v_acq_status_result_ps_id
                                              ,par_t_acq_result_code_id      => v_t_acq_result_code_id
                                              ,par_doc_templ_id              => doc.templ_id_by_brief('ACQ_INTERNET_PAYMENT')
                                              ,par_reg_date                  => SYSDATE
                                              ,par_policy_header_id          => v_pol_header_id
                                              ,par_issuer_name               => v_fio
                                              ,par_policy_num                => v_pol_number
                                              ,par_email                     => v_email
                                              ,par_bank_transaction_id       => v_bank_trans_id
                                              ,par_acq_payment_template_id   => v_payment_template_id
                                              ,par_t_acq_status_3dsecure_id  => v_acq_status_3dsecure_id
                                              ,par_rrn                       => v_rrn
                                              ,par_approval_code             => v_approval_code
                                              ,par_card_number               => v_card_number
                                              ,par_mrch_transaction_id       => v_mrch_transaction_id
                                              ,par_transaction_date          => v_trans_date
                                              ,par_closing_day_id            => get_current_business_day()
                                              ,par_acq_internet_payment_id   => v_acq_internet_payment_id);
        IF v_result_ps_brief = 'FINISHED'
        THEN
          /*
          Если значение реквизита «Результат транзакции в интерпретации платежного сервера»
          запроса «Уведомление о совершенном платеже» равен «FINISHED»,
          то создать новый документ «Интернет платеж» в статусе «Новый»*/
          doc.set_doc_status(p_doc_id => v_acq_internet_payment_id, p_status_brief => 'NEW');
        ELSE
          /*
          Если значение реквизита «Результат транзакции в интерпретации платежного сервера»
          запроса «Уведомление о совершенном платеже» не равен «FINISHED» */
          doc.set_doc_status(p_doc_id => v_acq_internet_payment_id, p_status_brief => 'CANCEL');
        END IF;
      
        vr_response.status := gc_ok;
      END IF;
    END IF; --Конец если единовоременный или первичный рекурентный платеж
    par_response := make_response(par_response => vr_response);
  END process_payment;

  /*
    Предварительный расчет графика списания
    Черных М. 10.09.2014
  */
  PROCEDURE precalc_payment_schedule
  (
    par_payment_template_id      IN acq_payment_template.acq_payment_template_id%TYPE
   ,par_base_date                IN DATE
   ,par_pol_end_date             IN DATE := NULL
   ,par_prolongation_flag        IN acq_payment_template.prolongation_flag%TYPE
   ,par_payment_count_out        OUT NUMBER
   ,par_first_operation_date_out OUT DATE
  ) IS
    v_start_date          acq_writeoff_sch.start_date%TYPE;
    v_end_date_base       acq_writeoff_sch.end_date%TYPE;
    v_end_date            acq_writeoff_sch.end_date%TYPE;
    v_date_diff           NUMBER;
    vr_payment_template   dml_acq_payment_template.tt_acq_payment_template;
    vr_payment_terms      dml_t_payment_terms.tt_t_payment_terms;
    vr_pol_header         dml_p_pol_header.tt_p_pol_header;
    v_writeoff_sch_id     acq_writeoff_sch.acq_writeoff_sch_id%TYPE;
    v_pol_start_date      p_pol_header.start_date%TYPE;
    v_pol_end_date        p_policy.end_date%TYPE;
    v_amount              acq_writeoff_sch.amount%TYPE;
    v_doc_templ_id        doc_templ.doc_templ_id%TYPE;
    vr_period_info        pkg_period.t_period_info;
    v_privelege_period_id p_policy.pol_privilege_period_id%TYPE;
    v_initial_start_date  DATE;
    v_offset              PLS_INTEGER := 1;
    v_period_length       INTEGER;
    v_new_end_date_base   DATE;
  
    FUNCTION annual_in_period
    (
      par_pol_start_date p_pol_header.start_date%TYPE
     ,par_period_start   DATE
     ,par_period_end     DATE
    ) RETURN BOOLEAN IS
      v_annuals_in_period NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_annuals_in_period
        FROM (SELECT to_date(to_char(par_pol_start_date, 'ddmm') ||
                             to_char(extract(YEAR FROM par_period_end))
                            ,'ddmmyyyy') AS start_date
                FROM dual
              CONNECT BY rownum <=
                         (extract(YEAR FROM par_period_end) + 1) - extract(YEAR FROM par_period_start))
       WHERE start_date BETWEEN par_period_start AND par_period_end;
    
      RETURN v_annuals_in_period > 0;
    END annual_in_period;
  
    /*Дата начала и конца уже существующих графиков*/
    PROCEDURE receive_start_and_end_dates
    (
      par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE
     ,par_start_date          OUT acq_writeoff_sch.start_date%TYPE
     ,par_end_date            OUT acq_writeoff_sch.end_date%TYPE
    ) IS
    BEGIN
      SELECT ws.start_date
            ,ws.end_date
        INTO par_start_date
            ,par_end_date
        FROM acq_writeoff_sch ws
       WHERE ws.acq_writeoff_sch_id IN (SELECT MAX(ws.acq_writeoff_sch_id)
                                          FROM acq_writeoff_sch ws
                                              ,document         dc
                                              ,doc_status_ref   dsr
                                         WHERE ws.acq_payment_template_id = par_payment_template_id
                                           AND ws.acq_writeoff_sch_id = dc.document_id
                                           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                           AND dsr.brief != 'CANCEL');
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END receive_start_and_end_dates;
  
    /*Информация по ДС*/
    PROCEDURE get_policy_info
    (
      par_pol_header_id       p_pol_header.policy_header_id%TYPE
     ,par_start_date          OUT p_pol_header.start_date%TYPE
     ,par_end_date            OUT p_policy.end_date%TYPE
     ,par_privelege_period_id OUT p_policy.pol_privilege_period_id%TYPE
    ) IS
    BEGIN
      SELECT ph.start_date
            ,pp.end_date
            ,pp.pol_privilege_period_id
        INTO par_start_date
            ,par_end_date
            ,par_privelege_period_id
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE ph.policy_header_id = par_pol_header_id
         AND ph.max_uncancelled_policy_id = pp.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        /*   ex.raise('Договор страхования с ID заголовка: ' || nvl(to_char(par_pol_header_id), 'null') ||
        ' не найден');*/
        par_start_date          := vr_payment_template.policy_start_date;
        par_end_date            := vr_payment_template.policy_end_date;
        par_privelege_period_id := 1483; /*30 дней*/
    END get_policy_info;
  
    /*Дата следующего платежа*/
    FUNCTION get_initial_start_date(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE)
      RETURN DATE IS
      v_date DATE;
    BEGIN
      SELECT MAX(ws.start_date) keep(dense_rank FIRST ORDER BY ws.acq_writeoff_sch_id)
        INTO v_date
        FROM acq_writeoff_sch ws
            ,document         dc
            ,doc_status_ref   dsr
       WHERE ws.acq_payment_template_id = par_payment_template_id
         AND ws.acq_writeoff_sch_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief != 'CANCEL';
      RETURN v_date;
    END get_initial_start_date;
  
  BEGIN
  
    v_doc_templ_id := doc.templ_id_by_brief('ACQ_WRITEOFF_SCH');
    /*Шаблон платежа*/
    vr_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => par_payment_template_id);
    /*Информация по ДС*/
    get_policy_info(par_pol_header_id       => vr_payment_template.policy_header_id
                   ,par_start_date          => v_pol_start_date
                   ,par_end_date            => v_pol_end_date
                   ,par_privelege_period_id => v_privelege_period_id);
    /*Льготный период*/
    vr_period_info := pkg_period.get_period_info(par_period_id => v_privelege_period_id);
    /*Дата начала и конца уже существующих графиков*/
    receive_start_and_end_dates(par_payment_template_id => par_payment_template_id
                               ,par_start_date          => v_start_date
                               ,par_end_date            => v_end_date);
    /*Периодичность оплаты*/
    vr_payment_terms := dml_t_payment_terms.get_record(vr_payment_template.t_payment_terms_id);
  
    -- Получаем дату (start_date) первой записи графика
    v_initial_start_date := get_initial_start_date(par_payment_template_id);
  
    --Периодичность платеже в месяцах
    v_period_length := 12 / vr_payment_terms.number_of_payments;
  
    -- Расчет первой базовой зады, для расчета даты окончания
    v_end_date_base := pkg_period.add_period(par_value             => -vr_period_info.period.period_value
                                            ,par_period_type_brief => vr_period_info.period_type.brief
                                            ,par_date              => par_base_date /*vr_payment_template.grace_date*/); --По ТЗ базовая дата из параметра
  
    /* Если для выбранного «Шаблона платежа» не существует ни одного ЭГС
    в статусе отличном от «Отменен», то создать ЭГС в статусе «Новый» */
    IF v_initial_start_date IS NULL
    THEN
      v_initial_start_date := trunc(vr_payment_template.reg_date, 'dd');
    ELSE
      v_offset := ROUND(MONTHS_BETWEEN(v_start_date, v_initial_start_date)) / v_period_length + 1;
    END IF;
  
    v_start_date := ADD_MONTHS(v_initial_start_date, v_offset * v_period_length);
  
    v_new_end_date_base := ADD_MONTHS(v_end_date_base, v_offset * v_period_length);
  
    v_end_date                   := least(vr_payment_template.till
                                         ,pkg_period.add_period(par_period_info => vr_period_info
                                                               ,par_date        => v_new_end_date_base)
                                         ,v_pol_end_date);
    par_first_operation_date_out := v_start_date;
    /* Формирование графиков */
    LOOP
      /* Если полученная дата меньше чем значение поля «Срок действия списания» Шаблона */
      EXIT WHEN v_start_date >= least(vr_payment_template.till, v_pol_end_date) OR v_new_end_date_base > least(vr_payment_template.till
                                                                                                              ,v_pol_end_date);
    
      IF annual_in_period(v_pol_start_date, v_start_date, v_end_date)
      THEN
        v_amount := vr_payment_template.fee + vr_payment_template.admin_expenses;
      ELSE
        v_amount := vr_payment_template.fee;
      END IF;
      /* Если дата окончания получилась меньше даты начала, ошибка */
      IF v_end_date < v_start_date
      THEN
        ex.raise(par_message => 'Ошибка формирования графика. Дата окончания меньше даты начала.');
      END IF;
    
      par_payment_count_out := nvl(par_payment_count_out, 0) + 1;
    
      /* Вычислить значение «Дата начала периода списания» для следующего ЭГС */
      v_offset     := v_offset + 1;
      v_start_date := ADD_MONTHS(v_initial_start_date, v_offset * v_period_length);
    
      v_new_end_date_base := ADD_MONTHS(v_end_date_base, v_offset * v_period_length);
    
      v_end_date := least(vr_payment_template.till
                         ,pkg_period.add_period(par_period_info => vr_period_info
                                               ,par_date        => v_new_end_date_base)
                         ,v_pol_end_date);
    END LOOP;
  
    IF can_prolongate(par_pol_header_id => vr_payment_template.policy_header_id)
       AND v_new_end_date_base > v_pol_end_date
    THEN
      par_payment_count_out := nvl(par_payment_count_out, 0) + 1;
    END IF;
  END precalc_payment_schedule;

  /*
    Байтин А.
    Создание графика списания.
    Шаблон платежа, переходы: "Новый" - "Подтвержден", "Завершен" - "Подтвержден"
  */
  PROCEDURE create_payment_schedule(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE) IS
    v_start_date          acq_writeoff_sch.start_date%TYPE;
    v_end_date_base       acq_writeoff_sch.end_date%TYPE;
    v_end_date            acq_writeoff_sch.end_date%TYPE;
    v_date_diff           NUMBER;
    vr_payment_template   dml_acq_payment_template.tt_acq_payment_template;
    vr_payment_terms      dml_t_payment_terms.tt_t_payment_terms;
    vr_pol_header         dml_p_pol_header.tt_p_pol_header;
    v_writeoff_sch_id     acq_writeoff_sch.acq_writeoff_sch_id%TYPE;
    v_pol_start_date      p_pol_header.start_date%TYPE;
    v_pol_end_date        p_policy.end_date%TYPE;
    v_amount              acq_writeoff_sch.amount%TYPE;
    v_doc_templ_id        doc_templ.doc_templ_id%TYPE;
    vr_period_info        pkg_period.t_period_info;
    v_privelege_period_id p_policy.pol_privilege_period_id%TYPE;
    v_initial_start_date  DATE;
    v_offset              PLS_INTEGER := 1;
    v_period_length       INTEGER;
    v_new_end_date_base   DATE;
  
    FUNCTION annual_in_period
    (
      par_pol_start_date p_pol_header.start_date%TYPE
     ,par_period_start   DATE
     ,par_period_end     DATE
    ) RETURN BOOLEAN IS
      v_annuals_in_period NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_annuals_in_period
        FROM (SELECT to_date(to_char(par_pol_start_date, 'ddmm') ||
                             to_char(extract(YEAR FROM par_period_end))
                            ,'ddmmyyyy') AS start_date
                FROM dual
              CONNECT BY rownum <=
                         (extract(YEAR FROM par_period_end) + 1) - extract(YEAR FROM par_period_start))
       WHERE start_date BETWEEN par_period_start AND par_period_end;
    
      RETURN v_annuals_in_period > 0;
    END annual_in_period;
  
    /*Дата начала и конца уже существующих графиков*/
    PROCEDURE receive_start_and_end_dates
    (
      par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE
     ,par_start_date          OUT acq_writeoff_sch.start_date%TYPE
     ,par_end_date            OUT acq_writeoff_sch.end_date%TYPE
    ) IS
    BEGIN
      SELECT ws.start_date
            ,ws.end_date
        INTO par_start_date
            ,par_end_date
        FROM acq_writeoff_sch ws
       WHERE ws.acq_writeoff_sch_id IN (SELECT MAX(ws.acq_writeoff_sch_id)
                                          FROM acq_writeoff_sch ws
                                              ,document         dc
                                              ,doc_status_ref   dsr
                                         WHERE ws.acq_payment_template_id = par_payment_template_id
                                           AND ws.acq_writeoff_sch_id = dc.document_id
                                           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                           AND dsr.brief != 'CANCEL');
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END receive_start_and_end_dates;
  
    /*Информация по ДС*/
    PROCEDURE get_policy_info
    (
      par_pol_header_id       p_pol_header.policy_header_id%TYPE
     ,par_start_date          OUT p_pol_header.start_date%TYPE
     ,par_end_date            OUT p_policy.end_date%TYPE
     ,par_privelege_period_id OUT p_policy.pol_privilege_period_id%TYPE
    ) IS
    BEGIN
      SELECT ph.start_date
            ,pp.end_date
            ,pp.pol_privilege_period_id
        INTO par_start_date
            ,par_end_date
            ,par_privelege_period_id
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE ph.policy_header_id = par_pol_header_id
         AND ph.max_uncancelled_policy_id = pp.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        /*   ex.raise('Договор страхования с ID заголовка: ' || nvl(to_char(par_pol_header_id), 'null') ||
        ' не найден');*/
        par_start_date          := vr_payment_template.policy_start_date;
        par_end_date            := vr_payment_template.policy_end_date;
        par_privelege_period_id := 1483; /*30 дней*/
    END get_policy_info;
  
    /*Дата следующего платежа*/
    FUNCTION get_initial_start_date(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE)
      RETURN DATE IS
      v_date DATE;
    BEGIN
      SELECT MAX(ws.start_date) keep(dense_rank LAST ORDER BY ws.acq_writeoff_sch_id)
        INTO v_date
        FROM acq_writeoff_sch ws
            ,document         dc
            ,doc_status_ref   dsr
       WHERE ws.acq_payment_template_id = par_payment_template_id
         AND ws.acq_writeoff_sch_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief != 'CANCEL';
      RETURN v_date;
    END get_initial_start_date;
  
    /*Существует ЭГС пролонгации*/
    FUNCTION is_prolongation_sch(par_acq_payment_template_id NUMBER) RETURN BOOLEAN IS
      v_is_prolongation_sch NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO v_is_prolongation_sch
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ins.acq_writeoff_sch sch
                    ,ins.document         d
                    ,ins.doc_status_ref   dsr
               WHERE d.document_id = sch.acq_writeoff_sch_id
                    
                 AND dsr.doc_status_ref_id = d.doc_status_ref_id
                 AND dsr.brief != 'CANCEL'
                 AND sch.prolongation_flag = 1
                 AND sch.acq_payment_template_id = par_acq_payment_template_id);
      RETURN v_is_prolongation_sch != 0;
    END is_prolongation_sch;
  
  BEGIN
  
    v_doc_templ_id := doc.templ_id_by_brief('ACQ_WRITEOFF_SCH');
    /*Шаблон платежа*/
    vr_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => par_payment_template_id);
    /*Информация по ДС*/
    get_policy_info(par_pol_header_id       => vr_payment_template.policy_header_id
                   ,par_start_date          => v_pol_start_date
                   ,par_end_date            => v_pol_end_date
                   ,par_privelege_period_id => v_privelege_period_id);
    /*Льготный период*/
    vr_period_info := pkg_period.get_period_info(par_period_id => v_privelege_period_id);
    /*Дата начала и конца уже существующих графиков*/
    receive_start_and_end_dates(par_payment_template_id => par_payment_template_id
                               ,par_start_date          => v_start_date
                               ,par_end_date            => v_end_date);
    /*Периодичность оплаты*/
    vr_payment_terms := dml_t_payment_terms.get_record(vr_payment_template.t_payment_terms_id);
  
    IF vr_payment_terms.brief IN ('WEEKLY', 'DAILY')
    THEN
      ex.raise_custom('Периодичность ' || vr_payment_terms.description || ' не поддерживается');
    END IF;
  
    -- Получаем дату (start_date) первой записи графика
    v_initial_start_date := get_initial_start_date(par_payment_template_id);
  
    --Периодичность платеже в месяцах
    v_period_length := 12 / vr_payment_terms.number_of_payments;
  
    -- Расчет первой базовой зады, для расчета даты окончания
    v_end_date_base := pkg_period.add_period(par_value             => -vr_period_info.period.period_value
                                            ,par_period_type_brief => vr_period_info.period_type.brief
                                            ,par_date              => vr_payment_template.grace_date);
    /* Если для выбранного «Шаблона платежа» не существует ни одного ЭГС
    в статусе отличном от «Отменен», то создать ЭГС в статусе «Новый» */
    IF v_initial_start_date IS NULL
    THEN
      v_initial_start_date := trunc(vr_payment_template.reg_date, 'dd');
    ELSE
      v_offset := ROUND(MONTHS_BETWEEN(v_initial_start_date, trunc(vr_payment_template.reg_date, 'dd'))) /
                  v_period_length + 1;
    END IF;
  
    v_start_date := ADD_MONTHS(trunc(vr_payment_template.reg_date, 'dd'), v_offset * v_period_length);
  
    v_new_end_date_base := ADD_MONTHS(v_end_date_base, v_offset * v_period_length);
  
    v_end_date := least(vr_payment_template.till
                       ,pkg_period.add_period(par_period_info => vr_period_info
                                             ,par_date        => v_new_end_date_base)
                       ,v_pol_end_date);
  
    /* Формирование графиков */
    LOOP
      /* Если полученная дата меньше чем значение поля «Срок действия списания» Шаблона */
      EXIT WHEN v_start_date > least(vr_payment_template.till, v_pol_end_date) OR v_new_end_date_base > v_pol_end_date;
    
      IF annual_in_period(v_pol_start_date, v_start_date, v_end_date)
      THEN
        v_amount := vr_payment_template.fee + vr_payment_template.admin_expenses;
      ELSE
        v_amount := vr_payment_template.fee;
      END IF;
      /* Если дата окончания получилась меньше даты начала, ошибка */
      IF v_end_date < v_start_date
      THEN
        ex.raise(par_message => 'Ошибка формирования графика. Дата окончания меньше даты начала.');
      END IF;
    
      dml_acq_writeoff_sch.insert_record(par_acq_payment_template_id => par_payment_template_id
                                        ,par_start_date              => v_start_date
                                        ,par_end_date                => trunc(v_end_date, 'dd')
                                        ,par_amount                  => v_amount
                                        ,par_prolongation_flag       => 0
                                        ,par_doc_templ_id            => v_doc_templ_id
                                        ,par_acq_writeoff_sch_id     => v_writeoff_sch_id);
      doc.set_doc_status(p_doc_id => v_writeoff_sch_id, p_status_brief => 'NEW');
    
      /* Вычислить значение «Дата начала периода списания» для следующего ЭГС */
      v_offset     := v_offset + 1;
      v_start_date := ADD_MONTHS(trunc(vr_payment_template.reg_date, 'dd'), v_offset * v_period_length);
    
      v_new_end_date_base := ADD_MONTHS(v_end_date_base, v_offset * v_period_length);
    
      v_end_date := least(vr_payment_template.till
                         ,pkg_period.add_period(par_period_info => vr_period_info
                                               ,par_date        => v_new_end_date_base)
                         ,v_pol_end_date);
    END LOOP;
  
    IF can_prolongate(par_pol_header_id => vr_payment_template.policy_header_id)
       AND v_new_end_date_base > v_pol_end_date
       AND NOT is_prolongation_sch(vr_payment_template.acq_payment_template_id)
    THEN
      v_start_date := ROUND(v_pol_end_date) - 30;
      v_end_date   := v_pol_end_date;
    
      IF annual_in_period(v_pol_start_date, v_start_date, v_end_date)
      THEN
        v_amount := vr_payment_template.fee + vr_payment_template.admin_expenses;
      ELSE
        v_amount := vr_payment_template.fee;
      END IF;
      dml_acq_writeoff_sch.insert_record(par_acq_payment_template_id => par_payment_template_id
                                        ,par_start_date              => v_start_date
                                        ,par_end_date                => trunc(v_end_date, 'dd')
                                        ,par_amount                  => v_amount
                                        ,par_prolongation_flag       => 1
                                        ,par_doc_templ_id            => v_doc_templ_id
                                        ,par_acq_writeoff_sch_id     => v_writeoff_sch_id);
      doc.set_doc_status(p_doc_id => v_writeoff_sch_id, p_status_brief => 'NEW');
    END IF;
  END create_payment_schedule;

  /*
    Передача ЭГС на списание
    Выполняется джобом ночью
  */
  PROCEDURE pass_to_writeoff_at_night IS
  BEGIN
    /* Все ЭГС, значение поля «Дата начала периода списания» которых равно текущей дате
    и статус которых равен «Новый», переводить в статус «На списание» */
    -- Добавил сортировку т.к. возможна ситуация:
    -- ежемесячная форма оплаты, у парня не было денег оплатить, а мы все пытаемся списать и к списанию уже попадают более ондого ЭГС
    -- Сначала нужно стараться списать по наиболее старому
    FOR vr_sched IN (SELECT wc.acq_writeoff_sch_id
                       FROM acq_writeoff_sch wc
                           ,document         dc
                           ,doc_status_ref   dsr
                      WHERE wc.acq_writeoff_sch_id = dc.document_id
                        AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                        AND dsr.brief = 'NEW'
                        AND wc.start_date <= trunc(SYSDATE)
                      ORDER BY wc.start_date)
    LOOP
      BEGIN
        SAVEPOINT before_to_writeoff;
        IF doc.get_last_doc_status_brief(vr_sched.acq_writeoff_sch_id) = 'NEW'
        THEN
          doc.set_doc_status(p_doc_id       => vr_sched.acq_writeoff_sch_id
                            ,p_status_brief => 'TO_WRITEOFF');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_to_writeoff;
          pkg_email.send_mail_with_attachment(par_to            => gc_failure_responsable_prs
                                             ,par_subject       => CASE
                                                                     WHEN is_test_server = 1 THEN
                                                                      'ТЕСТ'
                                                                     ELSE
                                                                      NULL
                                                                   END ||
                                                                   'Ошибка процедуры pass_to_writeoff_at_night: TO_WRITEOFF'
                                             ,par_text          => 'Не удалось обработать график списания: ' ||
                                                                   vr_sched.acq_writeoff_sch_id || chr(13) ||
                                                                   chr(13) || 'Error stack: ' || chr(13) ||
                                                                   chr(13) || dbms_utility.format_error_stack ||
                                                                   'Error backtrce: ' || chr(13) || chr(13) ||
                                                                   dbms_utility.format_error_backtrace
                                             ,par_ignore_errors => TRUE);
      END;
    END LOOP;
  
    /* Все ЭГС в статусе «На списание», дата окончания периода списания которых
    меньше текущей даты, переводить в статус «Не списано»*/
    FOR vr_sched IN (SELECT wc.acq_writeoff_sch_id
                       FROM acq_writeoff_sch wc
                           ,document         dc
                           ,doc_status_ref   dsr
                      WHERE wc.acq_writeoff_sch_id = dc.document_id
                        AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                        AND dsr.brief = 'TO_WRITEOFF'
                        AND wc.end_date < trunc(SYSDATE))
    LOOP
    
      BEGIN
        SAVEPOINT before_not_writedoff;
        doc.set_doc_status(p_doc_id       => vr_sched.acq_writeoff_sch_id
                          ,p_status_brief => 'NOT_WRITEDOFF');
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_not_writedoff;
          -- т.к. есть вероятность свалиться у отправки письма, пришлось написать обаботку для бехопасности
          pkg_email.send_mail_with_attachment(par_to            => gc_failure_responsable_prs
                                             ,par_subject       => CASE
                                                                     WHEN is_test_server = 1 THEN
                                                                      'ТЕСТ'
                                                                     ELSE
                                                                      NULL
                                                                   END ||
                                                                   'Ошибка процедуры pass_to_writeoff_at_night: NOT_WRITEDOFF'
                                             ,par_text          => 'Не удалось обработать график списания: ' ||
                                                                   vr_sched.acq_writeoff_sch_id || chr(13) ||
                                                                   chr(13) || 'Error stack: ' || chr(13) ||
                                                                   chr(13) || dbms_utility.format_error_stack ||
                                                                   'Error backtrce: ' || chr(13) || chr(13) ||
                                                                   dbms_utility.format_error_backtrace
                                             ,par_ignore_errors => TRUE);
      END;
    END LOOP;
  END pass_to_writeoff_at_night;

  /*
    Передача ЭГС на списание
    Выполняется джобом утром
  */
  PROCEDURE pass_to_writeoff_at_morning IS
  BEGIN
  
    FOR vr_sched IN (SELECT wc.acq_writeoff_sch_id
                       FROM acq_writeoff_sch     wc
                           ,document             dc
                           ,acq_payment_template pt
                      WHERE wc.acq_writeoff_sch_id = dc.document_id
                        AND dc.doc_status_ref_id = gc_dsr_to_writeoff_id
                        AND wc.acq_payment_template_id = pt.acq_payment_template_id
                        AND NOT EXISTS (SELECT NULL
                               FROM ven_acq_internet_payment ip
                              WHERE ip.acq_writeoff_sch_id = wc.acq_writeoff_sch_id
                                AND ip.doc_status_ref_id = gc_dsr_writedoff_id))
    LOOP
      BEGIN
        SAVEPOINT before_writeoff;
        IF doc.get_last_doc_status_ref_id(vr_sched.acq_writeoff_sch_id) = gc_dsr_to_writeoff_id
        THEN
          /*Переводим валютные платежи в рубли на момент оплаты*/
          create_payment_by_schedule(par_writeoff_sch_id => vr_sched.acq_writeoff_sch_id);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_writeoff;
          pkg_email.send_mail_with_attachment(par_to            => gc_failure_responsable_prs
                                             ,par_subject       => 'Ошибка процедуры pass_to_writeoff_at_morning'
                                             ,par_text          => 'Не удалось обработать график списания: ' ||
                                                                   vr_sched.acq_writeoff_sch_id ||
                                                                   chr(13) || chr(13) ||
                                                                   'Error stack: ' || chr(13) ||
                                                                   chr(13) ||
                                                                   dbms_utility.format_error_stack ||
                                                                   'Error backtrce: ' || chr(13) ||
                                                                   chr(13) ||
                                                                   dbms_utility.format_error_backtrace
                                             ,par_ignore_errors => TRUE);
      END;
    
    END LOOP;
  END pass_to_writeoff_at_morning;

  /*
    Запрос Редактирование шаблона платежа
      Номер шаблона
      ФИО Страхователя
      Номер ДС
      IP адрес клиента
      Срок действия списания
  */
  -- Алла сказала убрать т.к. что бы мы ни сказали банку, 
  -- он всегда ставит датой окончания срок действия карты  
  /*
  PROCEDURE edit_template(par_payment_template dml_acq_payment_template.tt_acq_payment_template) IS
    --v_request  JSON := JSON();
    v_response JSON;
  BEGIN
    send_payment(par_fee          => 0
                ,par_template_num => par_payment_template.num
                ,par_till         => par_payment_template.till
                ,par_policy_num   => par_payment_template.pol_number
                ,par_response     => v_response);
  END edit_template;
  */

  /* 2.4.6. Создание новой версии «Пролонгация»
    При создании новой версии договора страхования, если тип изменений равен
    «Автопролонгация», и для договора страхования существует документ
    «Шаблон платежа» в статусе «Подтвержден», то:
      Изменять значение поля «Срок действия списания» в шаблоне на «Срок действия договора страхования»;
      Сформировать запрос к Сайту «Редактирование шаблона платежа»
      Сформировать новые элементы графиков списания
  
    Выполняется на переходе статусов ДС
    Переходы статусов уточняются.
  */
  PROCEDURE change_payment_template(par_policy_id p_policy.policy_id%TYPE) IS
    vr_policy             dml_p_policy.tt_p_policy;
    vr_template           dml_acq_payment_template.tt_acq_payment_template;
    v_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
  
    FUNCTION is_addendum_autoprolong(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_is_addendum_autoprolong NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_addendum_autoprolong
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_addendum_type pt
                    ,t_addendum_type     tt
               WHERE pt.p_policy_id = par_policy_id
                 AND pt.t_addendum_type_id = tt.t_addendum_type_id
                 AND tt.brief = 'Автопролонгация');
      RETURN v_is_addendum_autoprolong = 1;
    END is_addendum_autoprolong;
  
    FUNCTION get_confirmed_template_id(par_pol_header_id p_pol_header.policy_header_id%TYPE)
      RETURN acq_payment_template.acq_payment_template_id%TYPE IS
      v_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
    BEGIN
      BEGIN
        SELECT pt.acq_payment_template_id
          INTO v_payment_template_id
          FROM acq_payment_template pt
              ,document             dc
              ,doc_status_ref       dsr
         WHERE pt.policy_header_id = par_pol_header_id
           AND pt.acq_payment_template_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'CONFIRMED';
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
        WHEN too_many_rows THEN
          ex.raise(par_message => 'Найдено несколько шаблонов в статусе "Подтвержден"');
      END;
      RETURN v_payment_template_id;
    END get_confirmed_template_id;
  
  BEGIN
    vr_policy := dml_p_policy.get_record(par_policy_id => par_policy_id);
    -- Проверка типа изменений в ДС
    IF is_addendum_autoprolong(par_policy_id)
    THEN
      -- Если тип изменений Автопролонгация, ищем шаблон платежа
      v_payment_template_id := get_confirmed_template_id(par_pol_header_id => vr_policy.pol_header_id);
      IF v_payment_template_id IS NOT NULL
      THEN
        /** Алла сказала, что можно не отправлять в банк изменение срока действи яшаблона
        т.к. банк все равно опирается на срок действия карты, а делать или не делать списание
        говорим ему мы.
        vr_template      := dml_acq_payment_template.get_record(par_acq_payment_template_id => v_payment_template_id);
        
        vr_template.till := last_day(trunc(vr_policy.end_date, 'dd'));
        dml_acq_payment_template.update_record(vr_template);
        
        -- Выполняем запрос к сайту
        edit_template(par_payment_template => vr_template);
        */
      
        -- Формируем новые элементы ГС
        create_payment_schedule(par_payment_template_id => v_payment_template_id);
      END IF;
    END IF;
  END change_payment_template;

  /*
  2.4.7.  Привязка платежа для пролонгации.
  При изменении значения поля «Статус ручной обработки» на «Разнесен»,
  если существует ЭГС с типом «Пролонгация» равным «Да»,
  который ссылается на ЭРП, то:
    Если Шаблон платежа, на который ссылается ЭГС, находится в статусе «Подтвержден»,
    то перевести его в статус «Завершен» с указанием причины отказа «Пролонгация».
    Создать новый Шаблон платежа.
    Сформировать запрос к Сайту «Редактирование шаблона платежа».
  */
  PROCEDURE prolongate_template(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE) IS
    v_current_template_id    acq_payment_template.acq_payment_template_id%TYPE;
    vr_payment_register_item dml_payment_register_item.tt_payment_register_item;
    vr_cur_template          dml_acq_payment_template.tt_acq_payment_template;
    vr_new_template          dml_acq_payment_template.tt_acq_payment_template;
  
    FUNCTION get_current_template_id(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE)
      RETURN acq_payment_template.acq_payment_template_id%TYPE IS
      v_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
    BEGIN
      BEGIN
        SELECT sc.acq_payment_template_id
          INTO v_payment_template_id
          FROM acq_writeoff_sch     sc
              ,acq_internet_payment ip
         WHERE ip.payment_register_item_id = par_payment_register_item_id
           AND ip.acq_writeoff_sch_id = sc.acq_writeoff_sch_id
           AND sc.prolongation_flag = 1;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      RETURN v_payment_template_id;
    END get_current_template_id;
  
    FUNCTION find_pol_header_by_regitem(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE)
      RETURN p_pol_header.policy_header_id%TYPE IS
      v_pol_header_id p_pol_header.policy_header_id%TYPE;
    BEGIN
      BEGIN
        SELECT ph1.policy_header_id
          INTO v_pol_header_id
          FROM ac_payment   acp_epg
              ,doc_doc      dd1
              ,p_policy     pp1
              ,p_pol_header ph1
              ,doc_set_off  dso
         WHERE acp_epg.payment_id = dd1.child_id
           AND dd1.parent_id = pp1.policy_id
           AND pp1.pol_header_id = ph1.policy_header_id
           AND dso.parent_doc_id = acp_epg.payment_id
           AND dso.pay_registry_item = par_payment_register_item_id;
      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            --Ветка когда реестр разнесен с ПП на копию А7/ПД4
            SELECT ph2.policy_header_id
              INTO v_pol_header_id
              FROM document     acp_a7
                  ,doc_doc      dd2_1
                  ,doc_set_off  dso2
                  ,ac_payment   epg2
                  ,doc_doc      dd2
                  ,p_policy     pp2
                  ,p_pol_header ph2
                  ,doc_set_off  dso
             WHERE acp_a7.doc_templ_id IN (6432, 6533, 23095)
               AND acp_a7.document_id = dd2_1.child_id
               AND dd2_1.parent_id = dso2.child_doc_id
               AND dso2.parent_doc_id = epg2.payment_id
               AND epg2.payment_id = dd2.child_id
               AND dd2.parent_id = pp2.policy_id
               AND pp2.pol_header_id = ph2.policy_header_id
               AND acp_a7.document_id = dso.parent_doc_id
               AND dso.pay_registry_item = par_payment_register_item_id;
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
        
      END;
      RETURN v_pol_header_id;
    END find_pol_header_by_regitem;
  
    FUNCTION get_policy_end_date(par_pol_header_id p_pol_header.policy_header_id%TYPE)
      RETURN p_policy.end_date%TYPE IS
      v_end_date p_policy.end_date%TYPE;
    BEGIN
      BEGIN
        SELECT trunc(pp.end_date, 'dd')
          INTO v_end_date
          FROM p_pol_header ph
              ,p_policy     pp
         WHERE ph.policy_header_id = par_pol_header_id
           AND ph.max_uncancelled_policy_id = pp.policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          ex.raise('Ошибка получения срока действия списания, не найдена последняя неотмененная версия ДС');
      END;
      RETURN v_end_date;
    END get_policy_end_date;
  
  BEGIN
    vr_payment_register_item := dml_payment_register_item.get_record(par_payment_register_item_id => par_payment_register_item_id);
    v_current_template_id    := get_current_template_id(par_payment_register_item_id => par_payment_register_item_id);
    IF v_current_template_id IS NOT NULL
    THEN
      IF doc.get_doc_status_brief(doc_id => v_current_template_id) = 'CONFIRMED'
      THEN
        vr_cur_template                     := dml_acq_payment_template.get_record(par_acq_payment_template_id => v_current_template_id);
        vr_cur_template.t_mpos_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief => 'PROLONGATION');
        dml_acq_payment_template.update_record(par_record => vr_cur_template);
        doc.set_doc_status(p_doc_id => v_current_template_id, p_status_brief => 'STOPED');
      ELSE
        ex.raise(par_message => 'Шаблон платежа не находится в статусе "Подтвержден"');
      END IF;
    
      vr_new_template                     := vr_cur_template;
      vr_new_template.pol_number          := vr_payment_register_item.pol_num;
      vr_new_template.policy_header_id    := find_pol_header_by_regitem(par_payment_register_item_id);
      vr_new_template.till                := get_policy_end_date(par_pol_header_id => vr_new_template.policy_header_id);
      vr_new_template.reg_date            := SYSDATE;
      vr_new_template.t_mpos_rejection_id := NULL;
      vr_new_template.prolongation_flag   := 1;
      vr_new_template.doc_status_id       := NULL;
      vr_new_template.doc_status_ref_id   := NULL;
    
      dml_acq_payment_template.insert_record(par_record => vr_new_template);
      doc.set_doc_status(p_doc_id       => vr_new_template.acq_payment_template_id
                        ,p_status_brief => 'PROJECT');
      doc.set_doc_status(p_doc_id       => vr_new_template.acq_payment_template_id
                        ,p_status_brief => 'CONFIRMED');
      -- Алла сказала убрать т.к. что бы мы ни сказали банку, 
      -- он всегда ставит датой окончания срок действия карты                        
      --edit_template(par_payment_template => vr_new_template);
    END IF;
  END prolongate_template;

  /*
  2.4.11. Ежедневная обработке Реестров ОМС.
  Ежедневно, в 22:00, запускать процедуру автоматической обработки загруженных ранее
  Реестров ОМС:
    Для всех документов «Реестр ОМС» в статусе «Загружен» или «Не обработан»
    осуществлять переход в статус «Обработан»
  */
  PROCEDURE process_registry_by_job IS
  BEGIN
    FOR vr_reg IN (SELECT rg.acq_oms_registry_id
                     FROM acq_oms_registry rg
                         ,document         dc
                         ,doc_status_ref   dsr
                    WHERE rg.acq_oms_registry_id = dc.document_id
                      AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                      AND dsr.brief IN ('LOADED', 'NOT_PROCESSED'))
    LOOP
      doc.set_doc_status(p_doc_id => vr_reg.acq_oms_registry_id, p_status_brief => 'PROCESSED');
    END LOOP;
  END process_registry_by_job;

  PROCEDURE set_rejection_reason
  (
    par_template_id acq_payment_template.acq_payment_template_id%TYPE
   ,par_reason_id   t_mpos_rejection.t_mpos_rejection_id%TYPE
  ) IS
  BEGIN
    UPDATE acq_payment_template pt
       SET pt.t_mpos_rejection_id = par_reason_id
     WHERE pt.acq_payment_template_id = par_template_id;
  END set_rejection_reason;

  /* Проверка статуса действия ДС и срока действия списания. 
     Выполняется ночью джобом
  */
  PROCEDURE stop_payment_templates IS
    v_reason_policy_break_id   t_mpos_rejection.t_mpos_rejection_id%TYPE;
    v_reason_policy_expired_id t_mpos_rejection.t_mpos_rejection_id%TYPE;
    v_reason_notice_expired_id t_mpos_rejection.t_mpos_rejection_id%TYPE;
  BEGIN
    /*Для всех Шаблонов платежей в статусе «Подтвержден»:
      1. Проверяем срок действия списания, если истёк то завершаем.
      2. Если активная версия Договора страхования, на который ссылается
      Уведомление о создании периодического списания
      находится в одном из статусов:
        Отменен;
        Прекращен;
        Готовится к расторжению;
        Заявление на прекращение;
        К прекращению;
        К прекращению. Готов для проверки;
        К прекращению. Проверен;
        Прекращен. Запрос реквизитов;
        Прекращен. Реквизиты получены;
        Прекращен. К выплате;
        Восстановление,
      то соответствующий Шаблон платежа принимает статус «Завершен»,
      Причина отказа «Расторжение договора»
      Заявление об отказе от регулярного списания, в статусе «Новый»,
      которое ссылается на Шаблон платежа, принимает статус «Отменен».
    
      Если активная версия находится в статусе «Завершен», то соответствующий
      Шаблон платежа принимает статус «Завершен» с причиной отказа
      «Срок действия договора истек».
    */
    v_reason_policy_break_id   := pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief => 'POLICY_BREAK');
    v_reason_policy_expired_id := pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief => 'POLICY_EXPIRED');
    v_reason_notice_expired_id := pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief => 'NOTICE_EXPIRED');
  
    FOR vr_rec IN (SELECT pt.acq_payment_template_id
                     FROM acq_payment_template pt
                         ,document             d
                         ,doc_status_ref       dsr
                    WHERE d.document_id = pt.acq_payment_template_id
                      AND dsr.doc_status_ref_id = d.doc_status_ref_id
                      AND dsr.brief = 'CONFIRMED'
                      AND pt.till < trunc(SYSDATE))
    LOOP
      doc.set_doc_status(p_doc_id => vr_rec.acq_payment_template_id, p_status_brief => 'STOPED');
      set_rejection_reason(par_template_id => vr_rec.acq_payment_template_id
                          ,par_reason_id   => v_reason_notice_expired_id);
    END LOOP;
  
    FOR vr_rec IN (SELECT pt.acq_payment_template_id
                         ,(SELECT cn.acq_cancel_notice_id
                             FROM acq_cancel_notice cn
                                 ,document          dcn
                                 ,doc_status_ref    dsrn
                            WHERE cn.acq_payment_template_id = pt.acq_payment_template_id
                              AND cn.acq_cancel_notice_id = dcn.document_id
                              AND dcn.doc_status_ref_id = dsrn.doc_status_ref_id
                              AND dsrn.brief = 'NEW') AS cancel_notice_id
                         ,dsrp.brief AS policy_status_brief
                         ,CASE dsrp.brief
                            WHEN 'STOPED' THEN
                             v_reason_policy_expired_id
                            ELSE
                             v_reason_policy_break_id
                          END AS reason_id
                     FROM acq_payment_template pt
                         ,document             dc
                         ,doc_status_ref       dsr
                         ,p_pol_header         ph
                         ,document             dcp
                         ,doc_status_ref       dsrp
                    WHERE pt.acq_payment_template_id = dc.document_id
                      AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                      AND dsr.brief = 'CONFIRMED'
                      AND pt.policy_header_id = ph.policy_header_id
                      AND ph.policy_id = dcp.document_id
                      AND dcp.doc_status_ref_id = dsrp.doc_status_ref_id
                      AND dsrp.brief IN ('RECOVER'
                                        ,'READY_TO_CANCEL'
                                        ,'QUIT_DECL'
                                        ,'TO_QUIT'
                                        ,'TO_QUIT_CHECK_READY'
                                        ,'TO_QUIT_CHECKED'
                                        ,'CANCEL'
                                        ,'QUIT'
                                        ,'QUIT_REQ_QUERY'
                                        ,'QUIT_REQ_GET'
                                        ,'QUIT_TO_PAY'
                                        ,'STOPED'))
    LOOP
      set_rejection_reason(par_template_id => vr_rec.acq_payment_template_id
                          ,par_reason_id   => vr_rec.reason_id);
      doc.set_doc_status(p_doc_id => vr_rec.acq_payment_template_id, p_status_brief => 'STOPED');
      IF vr_rec.cancel_notice_id IS NOT NULL
         AND vr_rec.policy_status_brief != 'STOPED'
      THEN
        doc.set_doc_status(p_doc_id => vr_rec.cancel_notice_id, p_status_brief => 'CANCELED');
      END IF;
    END LOOP;
  END stop_payment_templates;

  PROCEDURE send_payment
  (
    par_fee          IN acq_writeoff_sch.amount%TYPE
   ,par_template_num document.num%TYPE
   ,par_till         acq_payment_template.till%TYPE
   ,par_policy_num   VARCHAR2
   ,par_response     OUT JSON
  ) IS
    v_data    JSON := JSON();
    v_request VARCHAR2(2000);
    c_key       CONSTANT VARCHAR2(255) := '9cd52974d914695d3bcef830e1f8af01';
    c_operation CONSTANT VARCHAR2(30) := 'repeat_payment';
    v_url      VARCHAR2(255);
    v_response CLOB;
    --v_json_response JSON;
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    v_url := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'RECURRENT_PAYMENT'
                                             ,par_props_type_brief => 'URL');
  
    v_request := 'key=' || c_key || '&';
    v_request := v_request || 'operation=' || c_operation || '&';
  
    v_data.put('order_fee', par_fee);
    v_data.put('order_fee_rur', par_fee);
    v_data.put('rec_pmnt_id', par_template_num);
    v_data.put('act_period', par_till);
    v_data.put('policy_num', par_policy_num);
  
    v_request                         := v_request || 'data=' || v_data.to_char(FALSE);
    vr_log_info.source_pkg_name       := 'pkg_acquiring';
    vr_log_info.source_procedure_name := 'send_payment';
    vr_log_info.operation_name        := 'repeat_payment';
    v_response                        := pkg_communication.request(par_url      => v_url
                                                                  ,par_send     => v_request
                                                                  ,par_log_info => vr_log_info);
    par_response                      := JSON(v_response);
    dbms_lob.freetemporary(lob_loc => v_response);
  END;

  /*
    Отправка запроса на списание в Шлюз
    Интернет платеж
    Переход статусов "Проект" - "На списание"
  */
  PROCEDURE make_payment(par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE) IS
    v_rrn            acq_internet_payment.rrn%TYPE;
    v_approval_code  acq_internet_payment.approval_code%TYPE;
    v_result_brief   t_acq_status_result.brief%TYPE;
    v_result_code    t_acq_result_code.result_code%TYPE;
    vr_result_code   dml_t_acq_result_code.tt_t_acq_result_code;
    vr_payment       dml_acq_internet_payment.tt_acq_internet_payment;
    vr_schedule      dml_acq_writeoff_sch.tt_acq_writeoff_sch;
    vr_template      dml_acq_payment_template.tt_acq_payment_template;
    v_result_id      t_acq_status_result.t_acq_status_result_id%TYPE;
    v_result_code_id t_acq_result_code.t_acq_result_code_id%TYPE;
    v_response       JSON;
    v_status         VARCHAR2(20);
  BEGIN
    vr_payment  := dml_acq_internet_payment.get_record(par_acq_internet_payment_id => par_internet_payment_id
                                                      ,par_lock_record             => TRUE);
    vr_schedule := dml_acq_writeoff_sch.get_record(par_acq_writeoff_sch_id => vr_payment.acq_writeoff_sch_id);
    vr_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => vr_schedule.acq_payment_template_id);
  
    SAVEPOINT before_writeoff;
  
    send_payment(par_fee          => vr_payment.amount
                ,par_template_num => vr_template.num
                ,par_till         => vr_template.till
                ,par_policy_num   => vr_template.pol_number
                ,par_response     => v_response);
  
    IF v_response.exist('status')
    THEN
      v_status        := v_response.get('status').get_string;
      vr_payment.note := v_response.get('message').get_string;
    ELSE
      v_status        := gc_error;
      vr_payment.note := 'Ответ не получен или отсутствует поле status';
    END IF;
  
    IF v_status = gc_ok
    THEN
    
      v_rrn           := v_response.get('rrn').get_number;
      v_approval_code := v_response.get('approval_code').get_number;
      v_result_brief  := v_response.get('result').get_string;
      v_result_code   := v_response.get('result_code').get_string;
      v_result_id     := dml_t_acq_status_result.get_id_by_brief(v_result_brief);
    
      -- При результате DECLINE и TIMEOUT может не быть result_code
      IF v_result_code IS NOT NULL
      THEN
        v_result_code_id := dml_t_acq_result_code.get_id_by_result_code(v_result_code);
      END IF;
    
      IF v_response.exist('trans_id')
      THEN
        vr_payment.bank_transaction_id := v_response.get('trans_id').get_string;
      END IF;
    
      /*
        Документ типа «Интернет платеж» в статусе «На списании»,
        который ссылается на подобранный ЭГС
      */
      -- Обновляем только то, чего не было
      vr_payment.t_acq_status_result_id := nvl(v_result_id, vr_payment.t_acq_status_result_id);
      vr_payment.t_acq_result_code_id   := nvl(v_result_code_id, vr_payment.t_acq_result_code_id);
      vr_payment.rrn                    := nvl(v_rrn, vr_payment.rrn);
      vr_payment.approval_code          := nvl(v_approval_code, vr_payment.approval_code);
      vr_payment.transaction_date       := SYSDATE;
      dml_acq_internet_payment.update_record(par_record => vr_payment);
      IF v_result_code = '000'
      THEN
        /*
          Если значение «result_code» = 000, то перевести документ в статус «Списано» и 
          поместить его в очередь «Интернет платеж в статусе «Списан».
          Записать полученные данные в соответствующие поля таблицы «Интернет платеж»
          и найденный ЭГС  перевести из статуса «На списание» в статус «Списано»
          
          Перевод статуса ставит индернет платеж в очередь (AQ_INTERNET_PAYMENT) на обработку.
          Обработчик уже будет анализировать, что нужно сделать с ЭГС в результате данного списания.
        */
        doc.set_doc_status(p_doc_id    => vr_payment.acq_internet_payment_id
                          ,p_status_id => gc_dsr_writedoff_id);
      ELSE
        /*
          Если деньги списаны не были, Интернет платеж переводится в статус "Не списано"
          Если значение реквизита «Прекращение списания» таблицы
          «Расшифровка кодов ответ (RESULT_CODE)» для ошибки, указанной в поле «RESULT_CODE» равно 1,
          то найденный ЭГС перевести в статус «Не списано», в поле «ИД платежа» Шаблона,
          на который ссылается найденных ЭГС заполнить значением ИД записи таблицы Интернет платеж
          Далее отменяется шаблон и все его ЭГС
          
          Важно, что таким образом неудачное списание в рамках одного ЭГС может привести 
          к смене статусов остальных ЭГС. Это может привести к ошибке, если какой-то еще ЭГС данного шаблона 
          был отобрана для обработки т.к. находился на тот момент в подходящем статусе, но, когда дайте до него очередь,
          он уже будет в неподходящем статусе и может свалиться на переходе.          
        */
        doc.set_doc_status(p_doc_id    => vr_payment.acq_internet_payment_id
                          ,p_status_id => gc_dsr_not_writedoff_id);
      END IF;
    ELSE
      /*
        В случае системных ошибок переводи интернет платеж в статус "Не на списании"
      */
      dml_acq_internet_payment.update_record(par_record => vr_payment);
      doc.set_doc_status(p_doc_id    => par_internet_payment_id
                        ,p_status_id => gc_dsr_not_on_writeoff_id);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      -- В случае ошибки
      ROLLBACK TO before_writeoff;
    
      vr_payment.note := substr(dbms_utility.format_error_stack, 1, 4000);
      dml_acq_internet_payment.update_record(par_record => vr_payment);
    
      doc.set_doc_status(p_doc_id    => par_internet_payment_id
                        ,p_status_id => gc_dsr_not_on_writeoff_id);
  END make_payment;

  PROCEDURE load_registry_detail
  (
    par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE
   ,par_file_id         temp_load_blob.session_id%TYPE
  ) IS
    v_line         VARCHAR2(2000);
    v_blob         BLOB;
    v_clob         CLOB;
    v_lang_context NUMBER := dbms_lob.default_lang_ctx;
    v_dest_offset  NUMBER := 1;
    v_src_offset   NUMBER := 1;
    v_warning      NUMBER;
    v_row_idx      NUMBER := 0; -- Пропускаем заголовок
    vt_line        tt_one_col;
  
  BEGIN
    SELECT file_blob INTO v_blob FROM temp_load_blob WHERE session_id = par_file_id;
  
    dbms_lob.createtemporary(lob_loc => v_clob, cache => TRUE);
    dbms_lob.converttoclob(dest_lob     => v_clob
                          ,src_blob     => v_blob
                          ,amount       => dbms_lob.lobmaxsize
                          ,dest_offset  => v_dest_offset
                          ,src_offset   => v_src_offset
                          ,blob_csid    => dbms_lob.default_csid
                          ,lang_context => v_lang_context
                          ,warning      => v_warning);
    LOOP
      v_row_idx := v_row_idx + 1;
      v_line    := pkg_csv.get_row(par_csv => v_clob, par_row_number => v_row_idx);
      EXIT WHEN v_line IS NULL;
    
      vt_line := pkg_csv.csv_string_to_array(par_line => v_line, par_columns_count => 11);
    
      dml_acq_oms_registry_det.insert_record(par_acq_oms_registry_id => par_oms_registry_id
                                            ,par_operation_date      => to_date(vt_line(1)
                                                                               ,'dd.mm.yyyy')
                                            ,par_card_number         => vt_line(6)
                                            ,par_operation_amount    => to_number(vt_line(7)
                                                                                 ,'FM99999999999.0099')
                                            ,par_commission_amount   => to_number(vt_line(8)
                                                                                 ,'FM99999999999.0099')
                                            ,par_payment_amount      => to_number(vt_line(9)
                                                                                 ,'FM99999999999.0099')
                                            ,par_payment_date        => to_date(vt_line(11)
                                                                               ,'dd.mm.yyyy')
                                            ,par_currency            => vt_line(10));
    END LOOP;
    dbms_lob.freetemporary(lob_loc => v_clob);
  END load_registry_detail;

  PROCEDURE update_registry_vals(par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE) IS
    v_operation_amount   acq_oms_registry_det.operation_amount%TYPE;
    v_payment_date_count NUMBER;
    v_payment_date       acq_oms_registry_det.payment_date%TYPE;
  BEGIN
    SELECT nvl(SUM(rd.operation_amount), 0)
          ,COUNT(DISTINCT rd.payment_date)
      INTO v_operation_amount
          ,v_payment_date_count
      FROM acq_oms_registry_det rd
     WHERE rd.acq_oms_registry_id = par_oms_registry_id;
  
    IF v_payment_date_count = 1
    THEN
      SELECT rd.payment_date
        INTO v_payment_date
        FROM acq_oms_registry_det rd
       WHERE rd.acq_oms_registry_id = par_oms_registry_id
         AND rownum = 1;
    END IF;
  
    UPDATE acq_oms_registry rg
       SET rg.payment_amount = v_operation_amount
          ,rg.payment_date   = v_payment_date
     WHERE rg.acq_oms_registry_id = par_oms_registry_id;
  
    IF v_payment_date_count = 1
    THEN
      doc.set_doc_status(p_doc_id => par_oms_registry_id, p_status_brief => 'LOADED');
    ELSE
      UPDATE acq_oms_registry_det rd
         SET rd.status = 2
       WHERE rd.acq_oms_registry_id = par_oms_registry_id;
    
      doc.set_doc_status(p_doc_id => par_oms_registry_id, p_status_brief => 'NOT_LOADED');
    END IF;
  END update_registry_vals;

  /*
    Обработка детализации реестра ОМС
  */
  PROCEDURE process_registry(par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE) IS
    c_currency CONSTANT fund.brief%TYPE := 'RUR';
  
    vr_registry           dml_acq_oms_registry.tt_acq_oms_registry;
    v_register_item_id    payment_register_item.payment_register_item_id%TYPE;
    v_payments_count_flag NUMBER(1);
    v_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE;
    --v_single_type_id       t_acq_payment_type.t_acq_payment_type_id%TYPE;
    --v_primary_type_id      t_acq_payment_type.t_acq_payment_type_id%TYPE;
    v_commission_percent   t_commission_rules.commission_rate%TYPE;
    v_collection_method_id t_collection_method.id%TYPE;
  
    FUNCTION get_commission_percent(par_ac_payment_id ac_payment.payment_id%TYPE)
      RETURN t_commission_rules.commission_rate%TYPE IS
      v_com_percent t_commission_rules.commission_rate%TYPE;
    BEGIN
      BEGIN
        SELECT cr.commission_rate / 100
          INTO v_com_percent
          FROM t_commission_rules cr
              ,ac_payment         ac
         WHERE ac.payment_id = par_ac_payment_id
           AND cr.t_commission_rules_id = ac.t_commission_rules_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_com_percent := 0;
      END;
      RETURN v_com_percent;
    END get_commission_percent;
  
    PROCEDURE find_ac_payment
    (
      par_payment_date        acq_oms_registry.payment_date%TYPE
     ,par_amount              acq_oms_registry.payment_amount%TYPE
     ,par_ac_payment          OUT ac_payment.payment_id%TYPE
     ,par_commission_percent  OUT t_commission_rules.commission_rate%TYPE
     ,par_payments_count_flag OUT NUMBER
    ) IS
    BEGIN
      BEGIN
        SELECT ac.payment_id
              ,nvl(cr.commission_rate / 100, 0)
          INTO par_ac_payment
              ,par_commission_percent
          FROM ac_payment         ac
              ,document           dc
              ,doc_templ          dt
              ,doc_status_ref     dsr
              ,t_commission_rules cr
         WHERE ac.payment_id = dc.document_id
           AND dc.doc_templ_id = dt.doc_templ_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND ac.t_commission_rules_id = cr.t_commission_rules_id(+)
           AND dt.brief = 'ПП'
           AND dsr.brief = 'TRANS'
           AND ac.due_date = par_payment_date
           AND ac.amount = par_amount;
      
        par_payments_count_flag := 1;
      EXCEPTION
        WHEN no_data_found THEN
          par_payments_count_flag := 0;
        WHEN too_many_rows THEN
          par_payments_count_flag := 2;
      END;
    END find_ac_payment;
  
    FUNCTION exists_unlinked(par_oms_registry_id acq_oms_registry.acq_oms_registry_id%TYPE)
      RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM acq_oms_registry_det dt
               WHERE dt.acq_oms_registry_id = par_oms_registry_id
                 AND dt.acq_internet_payment_id IS NULL);
      RETURN v_is_exists = 1;
    END exists_unlinked;
  
    FUNCTION find_internet_payment
    (
      par_card_number      acq_oms_registry_det.card_number%TYPE
     ,par_operation_amount acq_oms_registry_det.operation_amount%TYPE
     ,par_operation_date   acq_oms_registry_det.operation_date%TYPE
     ,par_registry_id      acq_oms_registry.acq_oms_registry_id%TYPE
    ) RETURN acq_internet_payment.acq_internet_payment_id%TYPE IS
      v_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE;
    BEGIN
      SELECT MAX(ip.acq_internet_payment_id)
        INTO v_internet_payment_id
        FROM acq_internet_payment ip
            ,document             dc
            ,doc_status_ref       dsr
       WHERE ip.acq_internet_payment_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'NEW'
            -- т.к. форматы карт не совпадают
         AND /*substr(ip.card_number, 1, 1) || */
             substr(ip.card_number, -4, 4) =
            /*substr(par_card_number, 1, 1) || */
             substr(par_card_number, -4, 4)
         AND ip.amount = par_operation_amount
         AND trunc(ip.transaction_date) = par_operation_date
         AND NOT EXISTS (SELECT NULL
                FROM acq_oms_registry_det dt
               WHERE dt.acq_oms_registry_id = par_registry_id
                 AND dt.acq_internet_payment_id = ip.acq_internet_payment_id);
      RETURN v_internet_payment_id;
    END find_internet_payment;
  
    PROCEDURE set_payment_to_detail
    (
      par_registry_det_id     acq_oms_registry_det.acq_oms_registry_det_id%TYPE
     ,par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE
    ) IS
    BEGIN
      UPDATE acq_oms_registry_det rd
         SET rd.acq_internet_payment_id = par_internet_payment_id
       WHERE rd.acq_oms_registry_det_id = par_registry_det_id;
    END set_payment_to_detail;
  
    PROCEDURE set_registry_det_loaded(par_registry_det_id acq_oms_registry_det.acq_oms_registry_det_id%TYPE) IS
      c_loaded CONSTANT acq_oms_registry_det.status%TYPE := 1;
    BEGIN
      UPDATE acq_oms_registry_det rd
         SET rd.status = c_loaded
       WHERE rd.acq_oms_registry_det_id = par_registry_det_id;
    END set_registry_det_loaded;
  
    PROCEDURE set_internet_payment_item
    (
      par_internet_payment_id      acq_internet_payment.acq_internet_payment_id%TYPE
     ,par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
    ) IS
    BEGIN
      UPDATE acq_internet_payment ip
         SET ip.payment_register_item_id = par_payment_register_item_id
       WHERE ip.acq_internet_payment_id = par_internet_payment_id;
    END set_internet_payment_item;
  
  BEGIN
    IF doc.get_doc_status_brief(par_oms_registry_id) IN ('LOADED', 'NOT_PROCESSED')
    THEN
      SAVEPOINT before_process;
      vr_registry := dml_acq_oms_registry.get_record(par_acq_oms_registry_id => par_oms_registry_id);
      /*1.  Если значение поля Реестра ОМС «ИД ППВх» пустое*/
      IF vr_registry.ac_payment_id IS NULL
      THEN
        /*2.  Подобрать документ ППВх в статусе «Проведен» у которого Дата ППВх и
        Сумма ППВх совпадает с соответствующими полями записи таблицы «Реестр ОМС» */
        find_ac_payment(par_payment_date        => vr_registry.payment_date
                       ,par_amount              => vr_registry.payment_amount
                       ,par_ac_payment          => vr_registry.ac_payment_id
                       ,par_commission_percent  => v_commission_percent
                       ,par_payments_count_flag => v_payments_count_flag);
        IF v_payments_count_flag = 0
        THEN
          /* 3. Если ППВх не найдено, то перевести Реестр ОМС в статус «Не обработан» и
          в поле «Комментарий» Реестра указать ошибку «По сумме и дате не найдено ППВх» */
          vr_registry.note := 'По сумме и дате не найдено ППВх';
          dml_acq_oms_registry.update_record(vr_registry);
          doc.set_doc_status(p_doc_id => par_oms_registry_id, p_status_brief => 'NOT_PROCESSED');
        ELSIF v_payments_count_flag = 2
        THEN
          /* 4. Если найдено более одного ППВх, то перевести Реестр ОМС в статус
          «Не обработан» и в поле «Комментарий» Реестра указать ошибку
          «По сумме и дате найдено более одного ППВх» */
          vr_registry.note          := 'По сумме и дате найдено более одного ППВх';
          vr_registry.ac_payment_id := NULL;
          dml_acq_oms_registry.update_record(vr_registry);
          doc.set_doc_status(p_doc_id => par_oms_registry_id, p_status_brief => 'NOT_PROCESSED');
        END IF;
      ELSE
        v_commission_percent := get_commission_percent(vr_registry.ac_payment_id);
      END IF;
      IF vr_registry.ac_payment_id IS NOT NULL
      THEN
        -- Удаляем временный элемент реестра
        pkg_payment_register.del_register(p_payment_id              => vr_registry.ac_payment_id
                                         ,par_create_dummy_register => FALSE);
        /* 5. Если найдено только одно ППВх, то в поле «ИД ППВх» Реестра ОМС
        сохранить ссылку на найденный документ */
      
        /* 6. Проверить, что для каждой записи таблицы «Детализация Реестра ОМС»
        в статусе «Новый» для текущего Реестра ОМС существует документ
        «Интернет платеж» в статусе «Новый», у которого значения полей «Номер карты»,
        «Сумма операции» и «Дата операции» в формате «ДД.ММ.ГГГГ»
        совпадают с аналогичными значениями таблицы Детализация Реестра ОМС».
        Если найдено более одной записи, то брать запись с минимальным ИД. */
        -- Сначала находим и связываем
        FOR vr_det IN (SELECT dt.acq_oms_registry_det_id
                             ,dt.card_number
                             ,dt.operation_amount
                             ,dt.operation_date
                         FROM acq_oms_registry_det dt
                        WHERE dt.acq_oms_registry_id = par_oms_registry_id
                          AND dt.acq_internet_payment_id IS NULL)
        LOOP
          v_internet_payment_id := find_internet_payment(par_card_number      => vr_det.card_number
                                                        ,par_operation_amount => vr_det.operation_amount
                                                        ,par_operation_date   => vr_det.operation_date
                                                        ,par_registry_id      => par_oms_registry_id);
          set_payment_to_detail(par_registry_det_id     => vr_det.acq_oms_registry_det_id
                               ,par_internet_payment_id => v_internet_payment_id);
        END LOOP;
        -- Проверяем, чтобы не было несвязанных записей
        -- Заранее проверять замороченно, т.к. может получиться ситуация,
        -- где один платеж может подходить для двух записей детализации
        -- либо наоборот - несколько платежей на одну запись детализации
        IF NOT exists_unlinked(par_oms_registry_id => par_oms_registry_id)
        THEN
          v_collection_method_id := dml_t_collection_method.get_id_by_brief('Интернет Эквайринг');
          -- Теперь создаем ЭР и переводим статусы
          FOR vr_det IN (SELECT mn.card_number
                               ,mn.operation_amount
                               ,mn.operation_date
                               ,mn.policy_num
                               ,mn.issuer_name
                               ,mn.transaction_date
                               ,mn.acq_internet_payment_id
                               ,max_uncancelled_policy_id
                               ,(SELECT kl.name
                                   FROM p_policy pp
                                       ,t_kladr  kl
                                  WHERE pp.policy_id = mn.max_uncancelled_policy_id
                                    AND pp.region_id = kl.t_kladr_id) AS region_name
                               ,mn.acq_oms_registry_det_id
                               ,mn.ids
                           FROM (SELECT dt.card_number
                                       ,dt.operation_amount
                                       ,dt.operation_date
                                       ,ip.policy_num
                                       ,ip.issuer_name
                                       ,(SELECT ph.max_uncancelled_policy_id
                                           FROM p_pol_header ph
                                          WHERE ph.policy_header_id = ip.policy_header_id) AS max_uncancelled_policy_id
                                       ,ip.transaction_date
                                       ,ip.acq_internet_payment_id
                                       ,dt.acq_oms_registry_det_id
                                       ,(SELECT ph.ids
                                           FROM p_pol_header ph
                                          WHERE ph.policy_header_id = ip.policy_header_id) ids
                                   FROM acq_oms_registry_det dt
                                       ,acq_internet_payment ip
                                  WHERE dt.acq_oms_registry_id = par_oms_registry_id
                                    AND dt.acq_internet_payment_id = ip.acq_internet_payment_id) mn)
          LOOP
            -- Сформировать ЭРП
            v_register_item_id := NULL;
            pkg_payment_register.insert_register_item(par_register_item_id     => v_register_item_id
                                                     ,par_ac_payment_id        => vr_registry.ac_payment_id
                                                     ,par_payment_sum          => vr_det.operation_amount
                                                     ,par_payment_currency     => c_currency
                                                     ,par_pol_num              => vr_det.policy_num
                                                     ,par_payer_fio            => vr_det.issuer_name
                                                     ,par_payment_data         => vr_det.transaction_date
                                                     ,par_payment_purpose      => vr_det.policy_num || ' ' ||
                                                                                  vr_det.issuer_name
                                                     ,par_doc_num              => to_char(vr_det.acq_internet_payment_id)
                                                     ,par_territory            => vr_det.region_name
                                                     ,par_commission           => ROUND(vr_det.operation_amount *
                                                                                        v_commission_percent
                                                                                       ,2)
                                                     ,par_commission_currency  => c_currency
                                                     ,par_status               => 0
                                                     ,par_is_dummy             => 0
                                                     ,par_set_off_state        => 21
                                                     ,par_ids                  => vr_det.ids
                                                     ,par_collection_method_id => v_collection_method_id);
            -- Перевести Уведомление из статуса «Новый» в статус «Загружен»
            doc.set_doc_status(p_doc_id => vr_det.acq_internet_payment_id, p_status_brief => 'LOADED');
            set_registry_det_loaded(par_registry_det_id => vr_det.acq_oms_registry_det_id);
            set_internet_payment_item(par_internet_payment_id      => vr_det.acq_internet_payment_id
                                     ,par_payment_register_item_id => v_register_item_id);
          END LOOP;
          /* Проверяем */
          /* 8. перевести Реестр ОМС
          в статус «Обработан», в поле «Комментарий» указать значение «Успешно обработан» */
          vr_registry.note := 'Успешно обработан';
          dml_acq_oms_registry.update_record(vr_registry);
          doc.set_doc_status(p_doc_id => par_oms_registry_id, p_status_brief => 'PROCESSED');
        ELSE
          /* 10.  Если уведомления не были подобраны для каждой записи в детализации,
          то Реестр ОМС перевести в статус «Не обработан», в поле «Комментарий» указать
          значение «Сумма подобранных Уведомлений не равна сумме платежа Реестра ОМС» */
        
          -- Откатываем изменения
          ROLLBACK TO before_process;
          -- Устанавливаем статусы
          vr_registry.note := 'Сумма созданных ЭРП не равна сумме ППВх';
          dml_acq_oms_registry.update_record(vr_registry);
          doc.set_doc_status(p_doc_id => par_oms_registry_id, p_status_brief => 'NOT_PROCESSED');
        END IF;
      END IF;
    END IF;
  END process_registry;

  FUNCTION get_confirmed_templ_by_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN acq_payment_template.acq_payment_template_id%TYPE IS
    v_payment_template_id acq_payment_template.acq_payment_template_id%TYPE;
  BEGIN
    BEGIN
      SELECT pt.acq_payment_template_id
        INTO v_payment_template_id
        FROM acq_payment_template pt
            ,document             dc
            ,doc_status_ref       dsr
       WHERE pt.policy_header_id = par_pol_header_id
         AND pt.acq_payment_template_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'CONFIRMED';
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        NULL;
    END;
    RETURN v_payment_template_id;
  END get_confirmed_templ_by_header;

  /*
  Заявление об отказе от рекуррентных платежей
  «Новый» - «Подтвержден»
  Шаблон платежа, сохраненный в Заявлении об отказе от регулярного списания,
  находящееся в статусе  «Подтвержден»,  переводится в статус «Завершен»,
  значение поля «Причина отказа» заполняется значением «7 – Заявление клиента»
  */
  PROCEDURE stop_template_by_client_notice(par_cancel_notice_id acq_cancel_notice.acq_cancel_notice_id%TYPE) IS
    vr_cancel_notice    dml_acq_cancel_notice.tt_acq_cancel_notice;
    vr_payment_template dml_acq_payment_template.tt_acq_payment_template;
  BEGIN
    vr_cancel_notice    := dml_acq_cancel_notice.get_record(par_acq_cancel_notice_id => par_cancel_notice_id);
    vr_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => vr_cancel_notice.acq_payment_template_id);
    IF doc.get_doc_status_brief(vr_cancel_notice.acq_payment_template_id) = 'CONFIRMED'
    THEN
      vr_payment_template.t_mpos_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief => 'PAYER_REJECTION');
      dml_acq_payment_template.update_record(par_record => vr_payment_template);
      doc.set_doc_status(p_doc_id       => vr_payment_template.acq_payment_template_id
                        ,p_status_brief => 'STOPED');
    END IF;
  END stop_template_by_client_notice;

  /*
    Заявление об отказе от рекуррентных платежей
    «Подтвержден» - «Отменен»
    Перевод соответствующего Шаблона платежа из статуса «Завершен» в статус «Подтвержден»
  */
  PROCEDURE confirm_template_from_notice(par_cancel_notice_id acq_cancel_notice.acq_cancel_notice_id%TYPE) IS
    vr_cancel_notice dml_acq_cancel_notice.tt_acq_cancel_notice;
  BEGIN
    vr_cancel_notice := dml_acq_cancel_notice.get_record(par_acq_cancel_notice_id => par_cancel_notice_id);
    doc.set_doc_status(p_doc_id       => vr_cancel_notice.acq_payment_template_id
                      ,p_status_brief => 'CONFIRMED');
  END confirm_template_from_notice;

  /*
   Шаблон платежей
   «Подтвержден» - «Завершен»
   Если существует ЭГС в статусе «Новый» или «На списание»,
   то перевести их в статус «Отменен»
  */
  PROCEDURE cancel_schedule_by_template(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE) IS
  BEGIN
    FOR vr_sch IN (SELECT sc.acq_writeoff_sch_id
                     FROM acq_writeoff_sch sc
                         ,document         dc
                         ,doc_status_ref   dsr
                    WHERE sc.acq_payment_template_id = par_payment_template_id
                      AND sc.acq_writeoff_sch_id = dc.document_id
                      AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                      AND dsr.brief IN ('NEW', 'TO_WRITEOFF'))
    LOOP
      doc.set_doc_status(p_doc_id => vr_sch.acq_writeoff_sch_id, p_status_brief => 'CANCEL');
    END LOOP;
  END cancel_schedule_by_template;

  /*
    График списания
    «На списание» - «Не списано»
    Шаблон платежа, на который ссылается ЭГС, перевести в статус «Завершен» с указанием причины отказа «Отказ банка»
  */
  PROCEDURE stop_template_by_schedule(par_writeoff_sch_id acq_writeoff_sch.acq_writeoff_sch_id%TYPE) IS
    vr_writeoff_sch dml_acq_writeoff_sch.tt_acq_writeoff_sch;
  BEGIN
    vr_writeoff_sch := dml_acq_writeoff_sch.get_record(par_writeoff_sch_id);
    set_rejection_reason(par_template_id => vr_writeoff_sch.acq_payment_template_id
                        ,par_reason_id   => pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief => 'BANK_REJECTION'));
    doc.set_doc_status(p_doc_id       => vr_writeoff_sch.acq_payment_template_id
                      ,p_status_brief => 'STOPED');
  END stop_template_by_schedule;

  /*
    График списания
    «Новый» - «На списание»
    1.  Создавать новый документ типа «Интернет платеж» в статусе «Проект»
    2.  Созданный документ перевести из статуса «Проект» в статус «На списание»
  */
  PROCEDURE create_payment_by_schedule(par_writeoff_sch_id acq_writeoff_sch.acq_writeoff_sch_id%TYPE) IS
    vr_writeoff_sch       dml_acq_writeoff_sch.tt_acq_writeoff_sch;
    vr_payment_template   dml_acq_payment_template.tt_acq_payment_template;
    v_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE;
    v_amount              NUMBER;
  BEGIN
    vr_writeoff_sch     := dml_acq_writeoff_sch.get_record(par_acq_writeoff_sch_id => par_writeoff_sch_id);
    vr_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => vr_writeoff_sch.acq_payment_template_id);
  
    -- Для валютных договоров, которые оплачиваются в рублях
    v_amount := fee_to_rur(par_amount      => vr_writeoff_sch.amount
                          ,par_currency_id => vr_payment_template.pay_fund_id
                          ,par_date        => SYSDATE);
  
    dml_acq_internet_payment.insert_record(par_acq_payment_type_id     => gc_acq_pt_repeat_recurrent_id
                                          ,par_acq_writeoff_sch_id     => par_writeoff_sch_id
                                          ,par_doc_templ_id            => gc_dt_acq_internet_payment_id
                                          ,par_amount                  => v_amount
                                          ,par_acq_payment_template_id => vr_writeoff_sch.acq_payment_template_id
                                          ,par_transaction_date        => trunc(SYSDATE, 'dd')
                                          ,par_card_number             => vr_payment_template.card_number
                                          ,par_issuer_name             => vr_payment_template.issuer_name
                                          ,par_policy_num              => vr_payment_template.pol_number
                                          ,par_policy_header_id        => vr_payment_template.policy_header_id
                                          ,par_closing_day_id          => get_current_business_day()
                                          ,par_acq_internet_payment_id => v_internet_payment_id);
  
    doc.set_doc_status(p_doc_id => v_internet_payment_id, p_status_brief => 'PROJECT');
    doc.set_doc_status(p_doc_id => v_internet_payment_id, p_status_brief => 'TO_WRITEOFF');
  
  END create_payment_by_schedule;

  /*
    Шаблон платежа
    "Проект" - "Подтвержден"
    Установка текущего статуса активной версии шаблону
  */
  PROCEDURE set_policy_status_to_template(par_payment_template_id acq_payment_template.acq_payment_template_id%TYPE) IS
    vr_payment_template dml_acq_payment_template.tt_acq_payment_template;
    v_policy_status_id  doc_status_ref.doc_status_ref_id%TYPE;
    FUNCTION get_active_policy_status(par_pol_header_id p_pol_header.policy_header_id%TYPE)
      RETURN doc_status_ref.doc_status_ref_id%TYPE IS
      v_pol_status_ref_id doc_status_ref.doc_status_ref_id%TYPE;
    BEGIN
      BEGIN
        SELECT dc.doc_status_ref_id
          INTO v_pol_status_ref_id
          FROM p_pol_header ph
              ,document     dc
         WHERE ph.policy_header_id = par_pol_header_id
           AND ph.policy_id = dc.document_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      RETURN v_pol_status_ref_id;
    END get_active_policy_status;
    PROCEDURE set_pol_status_to_template
    (
      par_template_id      acq_payment_template.acq_payment_template_id%TYPE
     ,par_policy_status_id doc_status_ref.doc_status_ref_id%TYPE
    ) IS
    BEGIN
      UPDATE acq_payment_template pt
         SET pt.current_status_ref_id = par_policy_status_id
       WHERE pt.acq_payment_template_id = par_template_id;
    END set_pol_status_to_template;
  
  BEGIN
    vr_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => par_payment_template_id);
    v_policy_status_id  := get_active_policy_status(par_pol_header_id => vr_payment_template.policy_header_id);
    set_pol_status_to_template(par_template_id      => vr_payment_template.acq_payment_template_id
                              ,par_policy_status_id => v_policy_status_id);
  END set_policy_status_to_template;

  -- Удаление зависших шаблонов в проекте
  PROCEDURE delete_project_templates(par_from_date DATE) IS
  BEGIN
    FOR vr_tmpl IN (SELECT pt.acq_payment_template_id
                      FROM acq_payment_template pt
                          ,document             dc
                          ,doc_status_ref       dsr
                     WHERE pt.acq_payment_template_id = dc.document_id
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief = 'PROJECT'
                       AND dc.reg_date <= par_from_date)
    LOOP
      dml_acq_payment_template.delete_record(vr_tmpl.acq_payment_template_id);
    END LOOP;
  END delete_project_templates;

  /*Удаление шаблона платежа и графиков списания*/
  PROCEDURE delete_payment_template(par_acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE) IS
  BEGIN
    DELETE FROM ven_acq_writeoff_sch sch
     WHERE sch.acq_payment_template_id = par_acq_payment_template_id;
    DELETE FROM ven_acq_payment_template pt
     WHERE pt.acq_payment_template_id = par_acq_payment_template_id;
  END delete_payment_template;

  -- Author  : Гаргонов Д.А.
  -- Purpose : 372104: Интернет - эквайринг шаблон в статусе "Проект"
  -- Comment : Отменяет шаблон, в случае двойного списания.
  --           Выполняется на переходе статусов шаблона ACQ_PAYMENT_TEMPLATE.

  PROCEDURE check_dw_on_templ_confirm(par_acq_payment_template_id NUMBER) IS
    v_rec_acq_payment_template dml_acq_payment_template.tt_acq_payment_template;
  
    FUNCTION is_exist_confirmed_template_ph(par_pol_header_id NUMBER) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM acq_payment_template pt
                    ,document             dc
                    ,doc_status_ref       dsr
               WHERE pt.policy_header_id = par_pol_header_id
                 AND pt.acq_payment_template_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND pt.acq_payment_template_id != par_acq_payment_template_id
                 AND dsr.brief = 'CONFIRMED');
      RETURN v_is_exists = 1;
    END is_exist_confirmed_template_ph;
    FUNCTION is_exist_confirmed_template
    (
      par_pol_num          p_policy.pol_num%TYPE
     ,par_fio              contact.obj_name_orig%TYPE
     ,par_payment_terms_id t_payment_terms.id%TYPE
    ) RETURN BOOLEAN IS
      v_is_exists NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM acq_payment_template pt
                    ,document             dc
                    ,doc_status_ref       dsr
               WHERE pt.pol_number = par_pol_num
                 AND upper(pt.issuer_name) = upper(par_fio)
                 AND pt.t_payment_terms_id = par_payment_terms_id
                 AND pt.acq_payment_template_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND pt.acq_payment_template_id != par_acq_payment_template_id
                 AND dsr.brief IN ('CONFIRMED', 'NEW'));
      RETURN v_is_exists = 1;
    END is_exist_confirmed_template;
    PROCEDURE cancel_template IS
    BEGIN
      v_rec_acq_payment_template.t_mpos_rejection_id := dml_t_mpos_rejection.get_id_by_brief('DOUBLE_WRITEOFF');
      dml_acq_payment_template.update_record(par_record => v_rec_acq_payment_template);
      doc.set_doc_status(p_doc_id => par_acq_payment_template_id, p_status_brief => 'CANCEL');
    END;
  
  BEGIN
    v_rec_acq_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => par_acq_payment_template_id);
  
    IF v_rec_acq_payment_template.policy_header_id IS NOT NULL
    THEN
      --Если у шаблона есть policy_header_id
      IF is_exist_confirmed_template_ph(par_pol_header_id => v_rec_acq_payment_template.policy_header_id)
      THEN
        cancel_template();
      END IF;
    ELSE
      --Без policy_header_id
      IF is_exist_confirmed_template(v_rec_acq_payment_template.pol_number
                                    ,v_rec_acq_payment_template.issuer_name
                                    ,v_rec_acq_payment_template.t_payment_terms_id)
      THEN
        cancel_template();
      END IF;
    END IF;
  END check_dw_on_templ_confirm;

  /*При переходе статуса Интеренет платежа из "Списан" в "Новый" перевести элемент графика списания, 
  на который ссылается Интернет платеж в статус «Списано»*/
  PROCEDURE set_writeoff_sch_stat_writeoff(par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE) IS
    vr_acq_internet_payment dml_acq_internet_payment.tt_acq_internet_payment;
  BEGIN
  
    vr_acq_internet_payment := dml_acq_internet_payment.get_record(par_acq_internet_payment_id => par_internet_payment_id);
    doc.set_doc_status(p_doc_id       => vr_acq_internet_payment.acq_writeoff_sch_id
                      ,p_status_brief => 'WRITEDOFF');
  
  END set_writeoff_sch_stat_writeoff;

  /*При переходе статуса из "Не списано" в "Отменен" перевести элемент графика списания, на который ссылается Интернет платеж в статус «Отменен», 
  если значение реквизита «Прекращение списания» 
  таблицы «Расшифровка кодов ответ (RESULT_CODE)» для ошибки, указанной в поле «RESULT_CODE» равно 1*/
  PROCEDURE set_writeoff_sch_stat_cancel(par_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE) IS
    vr_acq_internet_payment dml_acq_internet_payment.tt_acq_internet_payment;
    vr_t_acq_result_code    dml_t_acq_result_code.tt_t_acq_result_code;
  BEGIN
    vr_acq_internet_payment := dml_acq_internet_payment.get_record(par_acq_internet_payment_id => par_internet_payment_id);
    vr_t_acq_result_code    := dml_t_acq_result_code.get_record(vr_acq_internet_payment.t_acq_result_code_id);
  
    /*Если флаг "Прекращения списания" стоит, то ЭГС в отменен*/
    IF vr_t_acq_result_code.stop_writeoff_flag = 1
    THEN
      doc.set_doc_status(p_doc_id       => vr_acq_internet_payment.acq_writeoff_sch_id
                        ,p_status_brief => 'CANCEL');
    END IF;
  
  END set_writeoff_sch_stat_cancel;

  /*
  Проверить, что для каждой записи таблицы «Детализация Реестра ОМС»
  в статусе «Новый» для текущего Реестра ОМС существует документ
  «Интернет платеж» в статусе «Новый», у которого значения полей «Номер карты»,
  «Сумма операции» и «Дата операции» в формате «ДД.ММ.ГГГГ»
  совпадают с аналогичными значениями таблицы Детализация Реестра ОМС».
  */
  PROCEDURE check_registry(par_oms_registry_id NUMBER) IS
  
    v_id                  t_number_type := t_number_type();
    v_internet_payment_id ins.acq_internet_payment.acq_internet_payment_id%TYPE;
  
    FUNCTION find_internet_payment
    (
      par_card_number      acq_oms_registry_det.card_number%TYPE
     ,par_operation_amount acq_oms_registry_det.operation_amount%TYPE
     ,par_operation_date   acq_oms_registry_det.operation_date%TYPE
     ,par_registry_id      acq_oms_registry.acq_oms_registry_id%TYPE
    ) RETURN acq_internet_payment.acq_internet_payment_id%TYPE IS
      v_internet_payment_id acq_internet_payment.acq_internet_payment_id%TYPE;
    BEGIN
      SELECT MAX(ip.acq_internet_payment_id)
        INTO v_internet_payment_id
        FROM acq_internet_payment ip
            ,document             dc
            ,doc_status_ref       dsr
       WHERE ip.acq_internet_payment_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'NEW'
            -- т.к. форматы карт не совпадают проверяем послдние 4 символа.
         AND substr(ip.card_number, -4, 4) = substr(par_card_number, -4, 4)
         AND ip.amount = par_operation_amount
         AND trunc(ip.transaction_date) = par_operation_date
         AND ip.acq_internet_payment_id NOT IN (SELECT column_value FROM TABLE(v_id));
      RETURN v_internet_payment_id;
    END find_internet_payment;
  
    PROCEDURE set_detail
    (
      par_registry_det_id NUMBER
     ,par_is_valid        NUMBER
    ) IS
    BEGIN
      UPDATE acq_oms_registry_det rd
         SET rd.is_valid_det = par_is_valid
       WHERE rd.acq_oms_registry_det_id = par_registry_det_id;
    END set_detail;
  
  BEGIN
    -- Сначала находим и связываем
    FOR vr_det IN (SELECT dt.acq_oms_registry_det_id
                         ,dt.card_number
                         ,dt.operation_amount
                         ,dt.operation_date
                     FROM acq_oms_registry_det dt
                    WHERE dt.acq_oms_registry_id = par_oms_registry_id
                      AND dt.acq_internet_payment_id IS NULL)
    LOOP
      v_internet_payment_id := find_internet_payment(par_card_number      => vr_det.card_number
                                                    ,par_operation_amount => vr_det.operation_amount
                                                    ,par_operation_date   => vr_det.operation_date
                                                    ,par_registry_id      => par_oms_registry_id);
      IF v_internet_payment_id IS NULL
      THEN
        --Ставим признак что элемент детализации не верен
        set_detail(par_registry_det_id => vr_det.acq_oms_registry_det_id, par_is_valid => 0);
      ELSE
        --Ставим признак что элемент детализации корректен
        set_detail(par_registry_det_id => vr_det.acq_oms_registry_det_id, par_is_valid => 1);
        --Добавляем ид платежа в список, что бы не найти его ещё раз.
        v_id.extend(1);
        v_id(v_id.last) := v_internet_payment_id;
      END IF;
    END LOOP;
  
    v_id.delete;
  
  END check_registry;

  /**
  * Процедура закрытия бизнес дня относительно последнего закрытия
  * @author Капля П.
  * @param par_operation_count - Число операций в ЛК с последнего закрытия
  * @param par_operation_sum   - Сумма операций в ЛК с последнего закрытия
  * @param par_closing_day_id  - ИД записи закрытия
  */
  PROCEDURE close_business_day
  (
    par_operation_count INTEGER
   ,par_operation_sum   NUMBER
   ,par_closing_day_id  OUT NUMBER
  ) IS
    v_acq_daily_closing     dml_acq_daily_closing.tt_acq_daily_closing;
    v_prev_closing_day_date DATE;
  
    -- Собираем статистику за день по данным Борласа
    PROCEDURE fill_borlas_count_and_summ
    (
      par_closing_day_id NUMBER
     ,par_count          OUT INTEGER
     ,par_amount         OUT NUMBER
    ) IS
    BEGIN
      SELECT COUNT(*)
            ,nvl(SUM(ip.amount), 0)
        INTO par_count
            ,par_amount
        FROM ven_acq_internet_payment ip
       WHERE ip.doc_status_ref_id IN (gc_dsr_new_id, gc_dsr_loaded_id)
         AND ip.closing_day_id = par_closing_day_id;
    END fill_borlas_count_and_summ;
  
    PROCEDURE start_new_business_day IS
    BEGIN
      dml_acq_daily_closing.insert_record(par_state => 0);
    END start_new_business_day;
  BEGIN
  
    v_acq_daily_closing := dml_acq_daily_closing.get_record(par_acq_daily_closing_id => get_current_business_day
                                                           ,par_lock_record          => TRUE);
  
    v_acq_daily_closing.closing_date := SYSDATE;
  
    v_acq_daily_closing.lk_operation_count  := par_operation_count;
    v_acq_daily_closing.lk_operation_amount := par_operation_sum;
  
    -- Собираем сумму и число относящихся к текущему дню интернет платежей
    fill_borlas_count_and_summ(par_closing_day_id => v_acq_daily_closing.acq_daily_closing_id
                              ,par_count          => v_acq_daily_closing.borlas_operation_count
                              ,par_amount         => v_acq_daily_closing.borlas_operation_amount);
  
    IF v_acq_daily_closing.lk_operation_count = v_acq_daily_closing.borlas_operation_count
       AND v_acq_daily_closing.lk_operation_amount = v_acq_daily_closing.borlas_operation_amount
    THEN
      v_acq_daily_closing.state := 1;
    ELSE
      v_acq_daily_closing.state := 2;
    END IF;
  
    dml_acq_daily_closing.update_record(v_acq_daily_closing);
  
    start_new_business_day;
  
    par_closing_day_id := v_acq_daily_closing.acq_daily_closing_id;
  END close_business_day;

  /**
  * Процедура закрытия бизнес дня
  * @author Капля П.
  */
  PROCEDURE close_business_day
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_operation_count   INTEGER;
    v_operation_sum     NUMBER;
    v_closing_date_id   NUMBER;
    v_acq_daily_closing dml_acq_daily_closing.tt_acq_daily_closing;
  BEGIN
  
    v_operation_count := par_request.get('operation_count').get_number;
    v_operation_sum   := par_request.get('operation_sum').get_number;
  
    close_business_day(par_operation_count => v_operation_count
                      ,par_operation_sum   => v_operation_sum
                      ,par_closing_day_id  => v_closing_date_id);
  
    v_acq_daily_closing := dml_acq_daily_closing.get_record(v_closing_date_id);
  
    IF nvl(v_acq_daily_closing.state, 2) = 2
    THEN
      pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients('Sergey.Kryukov@Renlife.com'
                                                                                     ,'Alla.Salahova@Renlife.com'
                                                                                     ,'Pavel.Kaplya@Renlife.com')
                                         ,par_subject       => 'Расхожедния при закрытии дня'
                                         , par_text          => 'Количество операций по ЛК: ' ||
                                                                v_acq_daily_closing.lk_operation_count || '
Количество операций по Борласу: ' ||
                                                                v_acq_daily_closing.borlas_operation_count || '

Сумма операций по ЛК: ' ||
                                                                v_acq_daily_closing.lk_operation_amount || '
Сумма операций по Борласу: ' ||
                                                                v_acq_daily_closing.borlas_operation_amount
                                         ,par_ignore_errors => TRUE);
    END IF;
  
    par_response := JSON();
  
    par_response.put('status', pkg_communication.gc_ok);
    par_response.put('borlas_operation_count', v_acq_daily_closing.borlas_operation_count);
    par_response.put('borlas_operation_sum', v_acq_daily_closing.borlas_operation_amount);
    par_response.put('daily_closing_id', v_acq_daily_closing.acq_daily_closing_id);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
    
      pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients('Sergey.Kryukov@Renlife.com'
                                                                                     ,'Alla.Salahova@Renlife.com'
                                                                                     ,'Pavel.Kaplya@Renlife.com')
                                         ,par_subject       => 'ОШИБКА при закрытии дня'
                                         ,par_text          => 'Stack: ' ||
                                                               dbms_utility.format_error_stack ||
                                                               chr(13) || ' Backtrace: ' ||
                                                               dbms_utility.format_error_backtrace
                                         ,par_ignore_errors => TRUE);
    
      par_response := JSON();
      par_response.put('status', pkg_communication.gc_error);
      par_response.put('message'
                      ,'Stack: ' || dbms_utility.format_error_stack || '; Backtrace: ' ||
                       dbms_utility.format_error_backtrace);
  END close_business_day;

  PROCEDURE send_payment_report(par_date DATE DEFAULT trunc(SYSDATE)) IS
    v_sql        VARCHAR2(4000);
    i            BINARY_INTEGER;
    v_recipients pkg_email.t_recipients DEFAULT pkg_email.t_recipients('alla.salahova@renlife.com'
                                                                      ,'pavel.kaplya@renlife.com');
    v_file       pkg_email.t_file;
  BEGIN
    v_sql := q'{SELECT ip.acq_internet_payment_id
      ,ip.num                     internet_payment_num
      ,ip.reg_date                internet_payment_regdate
      ,ip.amount
      ,ip.approval_code
      ,ip.bank_transaction_id
      ,ip.card_number
      ,ip.issuer_name
      ,ip.policy_header_id
      ,ip.policy_num
      ,ip.rrn
      ,ip.transaction_date
      ,ip.note
      ,dsr1.name                  internet_payment_status
      ,rc.result_code
      ,rc.desc_ru_full
      ,rc.stop_writeoff_flag
      ,sc.acq_writeoff_sch_id
      ,sc.reg_date                writeoff_sch_regdate
      ,sc.num                     writeoff_sch_num
      ,sc.amount                  writeoff_sch_amount
      ,sc.start_date              writeoff_sch_start_date
      ,sc.end_date                writeoff_sch_end_date
      ,sc.prolongation_flag
      ,dsr2.name                  writeoff_sch_status
      ,pt.acq_payment_template_id
      ,pt.num                     payment_template_num
      ,dsr3.name                  payment_template_status
  FROM ven_acq_internet_payment ip
      ,ven_acq_writeoff_sch     sc
      ,ven_acq_payment_template pt
      ,doc_status_ref           dsr1
      ,doc_status_ref           dsr2
      ,doc_status_ref           dsr3
      ,t_acq_result_code        rc
 WHERE trunc(ip.reg_date) = to_date('}' || to_char(trunc(par_date), 'dd.mm.yyyy') ||
             q'{','dd.mm.yyyy')
   AND ip.acq_writeoff_sch_id = sc.acq_writeoff_sch_id
   AND sc.acq_payment_template_id = pt.acq_payment_template_id
   AND ip.doc_status_ref_id = dsr1.doc_status_ref_id
   AND sc.doc_status_ref_id = dsr2.doc_status_ref_id
   AND pt.doc_status_ref_id = dsr3.doc_status_ref_id
   AND ip.t_acq_result_code_id = rc.t_acq_result_code_id}';
  
    ora_excel.new_document;
    ora_excel.add_sheet('Отчет');
    ora_excel.query_to_sheet(query => v_sql, show_column_names => TRUE);
  
    ora_excel.add_sheet('Запрос');
    ora_excel.add_row;
    ora_excel.set_cell_value(NAME => 'A', VALUE => v_sql);
  
    ora_excel.save_to_blob(blob_file => v_file.v_file);
  
    ora_excel.close_document;
  
    v_file.v_file_name := 'Отчет.xlsx';
    v_file.v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_file.v_file_name);
  
    pkg_email.send_mail_with_attachment(par_to         => v_recipients
                                       ,par_subject    => 'Отчет о рекурентных платежах от ' ||
                                                          to_char(par_date, 'dd.mm.yyyy')
                                       ,par_text       => NULL
                                       ,par_attachment => pkg_email.t_files(v_file));
  
  END send_payment_report;

  /**
  * Поиск ДС для шаблона платежа в статусе "Новый"
  */
  PROCEDURE find_policy_4_payment_template IS
    vr_acq_payment_template dml_acq_payment_template.tt_acq_payment_template;
    v_error_text            VARCHAR2(4000);
  
    v_is_ok BOOLEAN;
  
    c_double_rejection_id NUMBER := dml_t_mpos_rejection.get_id_by_brief('DOUBLE_WRITEOFF');
  
    /*Проверка существования другого шаблона платежа в статусе «Подтвержден» для данного ДС*/
    FUNCTION is_template_already_exist(par_pol_header_id p_pol_header.policy_header_id%TYPE)
      RETURN BOOLEAN IS
      v_acq_payment_template_num NUMBER;
    BEGIN
      SELECT nvl(COUNT(*), 0)
        INTO v_acq_payment_template_num
        FROM ven_acq_payment_template pt
       WHERE pt.policy_header_id = par_pol_header_id
         AND pt.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('CONFIRMED');
    
      RETURN v_acq_payment_template_num > 0; --найден хотя бы один
    
    END is_template_already_exist;
  
    /*Проверка совпадения брутто взноса при переходе статуса «Новый» в статус «Подтвержден» для шаблона платежа*/
    FUNCTION is_template_fee_correct
    (
      par_policy_header_id NUMBER
     ,par_template_fee     NUMBER
    ) RETURN BOOLEAN IS
      vr_pol_header dml_p_pol_header.tt_p_pol_header;
      v_only_fee    p_cover.fee%TYPE;
      v_result      BOOLEAN;
    BEGIN
    
      vr_pol_header := dml_p_pol_header.get_record(par_policy_header_id);
    
      v_result := is_fee_correct(par_fee               => par_template_fee
                                ,par_active_version_id => vr_pol_header.policy_id
                                ,par_last_version_id   => vr_pol_header.last_ver_id
                                ,par_date              => vr_pol_header.start_date
                                ,par_only_fee          => v_only_fee);
    
      RETURN v_result;
    END is_template_fee_correct;
  
  BEGIN
  
    FOR rec IN (SELECT pt.acq_payment_template_id
                      ,pp.payment_term_id policy_payment_terms
                      ,ph.policy_header_id
                  FROM ven_acq_payment_template pt
                      ,p_policy                 pp
                      ,p_pol_header             ph
                      ,v_pol_issuer             vpi
                 WHERE substr(to_char(ph.ids), 1, 9) = pt.pol_number
                   AND pt.policy_header_id IS NULL
                   AND ph.policy_id = vpi.policy_id
                   AND ph.policy_id = pp.policy_id
                   AND doc.get_doc_status_brief(pt.acq_payment_template_id) = 'NEW'
                   AND doc.get_doc_status_brief(ph.policy_id) NOT IN ('NEW', 'CANCEL')
                   AND REPLACE(upper(pt.issuer_name), 'Ё', 'Е') =
                       REPLACE(upper(vpi.contact_name), 'Ё', 'Е')
                --and pt.acq_payment_template_id=119916827
                )
    LOOP
    
      vr_acq_payment_template := dml_acq_payment_template.get_record(par_acq_payment_template_id => rec.acq_payment_template_id
                                                                    ,par_lock_record             => TRUE);
    
      /*Указываем ссылку на ДС в шаблоне*/
      vr_acq_payment_template.policy_header_id := rec.policy_header_id;
    
      IF is_template_already_exist(rec.policy_header_id)
      THEN
        vr_acq_payment_template.t_mpos_rejection_id := c_double_rejection_id;
      
        dml_acq_payment_template.update_acq_payment_template(vr_acq_payment_template);
      
        doc.set_doc_status(p_doc_id       => vr_acq_payment_template.acq_payment_template_id
                          ,p_status_brief => 'CANCEL'
                          ,p_note         => 'JOB: Поиск ДС для шаблона платежа в статусе "Новый"');
      ELSE
        v_is_ok := TRUE;
      
        --Выполняем проверки
        IF vr_acq_payment_template.t_payment_terms_id != rec.policy_payment_terms
        --NOT is_payment_terms_correct(rec.acq_payment_template_id)
        THEN
          v_is_ok := FALSE;
          put_error('Периодичность договора не соответствует периодичности Заявления'
                   ,vr_acq_payment_template.note);
        END IF;
      
        IF NOT is_template_fee_correct(rec.policy_header_id, vr_acq_payment_template.fee)
        THEN
          v_is_ok := FALSE;
          put_error('Размер страхового взноса указан неверно, невозможно создать регулярное списание'
                   ,vr_acq_payment_template.note);
        END IF;
      
        dml_acq_payment_template.update_record(vr_acq_payment_template);
      
        IF v_is_ok
        THEN
          doc.set_doc_status(p_doc_id       => vr_acq_payment_template.acq_payment_template_id
                            ,p_status_brief => 'CONFIRMED'
                            ,p_note         => 'JOB: Поиск ДС для шаблона платежа в статусе "Новый"');
        ELSE
          doc.set_doc_status(p_doc_id       => vr_acq_payment_template.acq_payment_template_id
                            ,p_status_brief => 'REVISION'
                            ,p_note         => 'JOB: Поиск ДС для шаблона платежа в статусе "Новый"');
        END IF;
      END IF;
    
    END LOOP;
  END find_policy_4_payment_template;

END pkg_acquiring;
/
