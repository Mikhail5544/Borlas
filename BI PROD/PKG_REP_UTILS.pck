CREATE OR REPLACE PACKAGE pkg_rep_utils AS
  /**
  * Функции для отчетов Discoverer и печатных форм
  * @author Kushenko S.
  * @version 1.0
  * @since 1.0
  * @headcom
  */

  gc_rep_type_procedure CONSTANT INT := 3;
  gc_rep_type_reports   CONSTANT INT := 2;
  gc_rep_type_jsp       CONSTANT INT := 7;

  /**
  * Запись для описания движения БСО
  */
  TYPE t_bso_in_out IS RECORD(
     n              NUMBER(10)
    ,nn             NUMBER(6)
    ,bso_type       VARCHAR2(150)
    ,in_quantity    NUMBER(6)
    ,in_num_start   VARCHAR2(150)
    ,in_num_end     VARCHAR2(150)
    ,in_reg_date    DATE
    ,out_quantity   NUMBER(6)
    ,out_num_start  VARCHAR2(150)
    ,out_num_end    VARCHAR2(150)
    ,out_reg_date   DATE
    ,out_bso_status VARCHAR2(150)
    ,rest_begin     NUMBER(8)
    ,rest_end       NUMBER(8)
    ,rest_change    NUMBER(8));

  /**
  * Сводная таблица движения БСО
  */
  TYPE tbl_bso_in_out IS TABLE OF t_bso_in_out;

  /**
  * Запись для описания БСО
  */
  TYPE t_bso IS RECORD(
     quantity   NUMBER(6)
    ,num_start  VARCHAR2(150)
    ,num_end    VARCHAR2(150)
    ,reg_date   DATE
    ,bso_status VARCHAR2(150));
  /**
  * Сводная таблица БСО
  */
  TYPE tbl_bso IS TABLE OF t_bso;

  /**
  *Запись и таблица для наименований страховых покрытий
  */
  TYPE rc_cvr IS RECORD(
     covername VARCHAR2(4000));
  TYPE tb_cvr IS TABLE OF VARCHAR2(4000);

  TYPE t_report IS RECORD(
     content_type VARCHAR2(255)
    ,file_name    VARCHAR2(1000)
    ,pages_count  NUMBER
    ,report_body  BLOB);

  FUNCTION get_pivot_bso_table
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_session_id NUMBER
  ) RETURN NUMBER;

  FUNCTION get_bso_rest_on_date
  (
    p_date        DATE
   ,p_bso_type_id NUMBER
  ) RETURN NUMBER;

  /**
  * Возвращает сумму(конкатенацию) строк селекта, через запятую
  * @author Kushenko S.
  * @param p_cursor курсор селекта
  * @return Сумма строк
  * Пример использования
  * SELECT pkg_rep_utils.concatenate_list(CURSOR(select t.description from t_color t)) as COLORS
  * FROM  dual
  */
  FUNCTION concatenate_list(p_cursor IN SYS_REFCURSOR) RETURN VARCHAR2;
  /**
  * Возращает подстроку длиной не более p_n из p_str, НЕ ДРОБЯ СЛОВА
  * @author Kushenko S.
  * @param p_str исходная строка
  * @param p_n ограничение по длине подстроки на выходе
  * @return Подстроку из p_str
  */
  FUNCTION hyphenation
  (
    p_str VARCHAR2
   ,p_n1  NUMBER
   ,p_n2  NUMBER DEFAULT 0
   ,p_n3  NUMBER DEFAULT 0
  ) RETURN VARCHAR2;
  /**
  * Возвращает ФИО, адреса и телефоны лиц причастных к страховому событию
  * (потерпевший, заявитель, водитель)
  * @author Kushenko S.
  * @param p_event_id ИД страхового события
  * @return Информацию по лицам, причастным к стр. событию
  */
  FUNCTION get_event_contacts_info(p_event_id IN NUMBER) RETURN VARCHAR2;
  /**
  * Возвращает ФИО, адреса и телефоны лиц причастных к страховому событию
  * (свидетель, виновник)
  * @author Kushenko S.
  * @param p_event_id ИД страхового события
  * @return Информацию по лицам, причастным к стр. событию
  */
  FUNCTION get_event_contacts_info_2(p_event_id IN NUMBER) RETURN VARCHAR2;
  /**
  * Возвращает был ли это Угон или Хищение
  * Применима только для группы рисков Автокаско
  * @author Kushenko S.
  * @param p_claim_head_id ИД заголовка претензии
  * @return       { 1 ----- Угон
  *                 2 ----- Ущерб }
  */
  FUNCTION is_hijacking(p_claim_header_id IN NUMBER) RETURN NUMBER;
  /**
  * Возвращает сумму и валюту заявленного убытка
  * @author Kushenko S.
  * @param p_claim_head_id ИД заголовка претензии
  * @return  c_claim.declare_sum || fund.brief
   */
  FUNCTION claim_sum_fund(p_claim_header_id IN NUMBER) RETURN VARCHAR2;
  /**
  * Возвращает сумму предыдущих выплат
  * примечание: За основу положена одноименная функция формы CLAIM
  * @autor Kushenko S.
  * @param p_claim_header_id ИД заголовка претензии
  * @return Сумма всех выплат
  */
  FUNCTION sum_pay_all(p_claim_header_id IN NUMBER) RETURN NUMBER;
  /**
  * Возвращает паспортные данные по ИД контакта
  * Для отчета "Страховой полис (авто)" (policy_auto)
  *                                       (policy_auto_vtb24)
  * @autor Kushenko S.
  * @param p_contac_id ИД контакта
  * @return Паспортные данные (серия, номер, кем и когда выдан)
  */
  FUNCTION passport_issuer(p_contact_id IN NUMBER) RETURN VARCHAR2;
  /**
  * Возвращает паспортные данные по ИД контакта
  * Для отчета "Страховой полис (авто)" (policy_auto)
  *                                       (policy_auto_vtb24)
  * @autor Kushenko S.
  * @param p_contact_id ИД контакта
  * @return Паспортные данные (серия, номер, кем и когда выдан)
  */
  FUNCTION passport_issuer_2(p_contact_id IN NUMBER) RETURN VARCHAR2;
  /**
  *Возвращает адрес регистрации(для физ. лиц) / адрес фактического
  *    нахождения (для юр. лиц)
  *Для отчета "Страховой полис (авто)" (policy_auto)
  * @autor Kushenko S.
  * @param p_contact_id (IN) ИД контакта
  *         p_cont_type (OUT) тип контакта
  * @return Адрес регистрации(для физ. лиц) / адрес фактического
  *    нахождения (для юр. лиц)
  */
  FUNCTION contact_addr
  (
    p_contact_id IN NUMBER
   ,p_cont_type  OUT VARCHAR2
  ) RETURN VARCHAR2;
  /**
  * Возвращает серию-номер Идентификатора контакта, по его типу и первичному ключу
  * Для отчета "Страховой полис (авто)" (policy_auto)
  * @autor Kushenko S.
  * @param p_contact_id (IN) Ид контакта
  *        p_doc_type (IN) Имя типа идентификатора контакта
  *                          в ВЕРХНЕМ РЕГИСТРЕ
  * @return Серия-номер Идентификатора контакта
  */
  FUNCTION doc_num
  (
    p_contact_id IN NUMBER
   ,p_doc_type   IN VARCHAR2
  ) RETURN VARCHAR2;
  /**
  * Возвращает номер телефона по ИД контакта (в порядке sort_order)
  * Для отчета "Страховой полис (авто)" (policy_auto)
  * @autor Kushenko S.
  * @param p_contact_id (IN) Ид контакта
  * @return Номер телефона или пустая строка
  */
  FUNCTION contact_phone(p_contact_id IN NUMBER) RETURN VARCHAR2;
  /**
  * Возвращает идентификатор адреса по ИД контакта (в порядке sort_order)
  * Для отчета "Полис накопительного страхования" (NacopPol)
  * @autor Sizon S.
  * @param p_contact_id (IN) Ид контакта
  * @return ID искомого адреса или NULL
  */
  FUNCTION contact_address(p_contact_id IN NUMBER) RETURN NUMBER;
  /**
  * Функция возвращает список телефонных номеров и их типов
  * Для отчета "Полис накопительного страхования" (NacopPol)
  * @author Sizon S.
  * @param par_contact_id ID Контакта
  * @return Строка, содержащая типы телефонов ":" телефонные номера с разделителем ","
  */
  FUNCTION get_telephones_with_typ(par_contact_id IN NUMBER) RETURN VARCHAR2;
  /**
  * Возвращает количество дней в льготном периоде полиса(в случае типа периода = 1)
  * Для отчета "Полис накопительного страхования" (NacopPol)
  * @autor Sizon S.
  * @param p_policy_id (IN) Ид полиса
  * @return количество дней или 0
  */
  FUNCTION days_from_grace_period(p_policy_id IN NUMBER) RETURN NUMBER;
  /**
  * Возвращает первый попавшийся e-mail по ИД контакта
  * Для отчета "Страховой полис (авто)" (policy_auto)
  * @autor Kushenko S.
  * @param p_contact_id (IN) Ид контакта
  * @return e_mail
  */
  FUNCTION contact_email(p_contact_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Возвращает имена противоугонных средств по ИД ТС
  * Для отчета "Страховой полис (авто)" (policy_auto)
  * @autor Kushenko S.
  * @param p_vehicle_id (IN) Ид ТС
  * @return Имя противоугонного средства
  */
  FUNCTION vehicle_at_device(p_vehicle_id IN NUMBER) RETURN VARCHAR2;
  /**
  * По полису возвращает оплаченную премию
  * В основе положена процедура pkg_payment.get_pol_pay_status (автор Пацан О.)
  * Для отчета ins_act_property.jsp
  * @author Kushenko S.
  * @param p_policy_id ИД полиса
  * @return Оплаченная премия
  */
  FUNCTION pay_prem_policy(p_policy_id IN NUMBER) RETURN NUMBER;
  /**
  * Вычисляет оплаченную сумму по ch.c_claim_header_id для всех претензий и дэмеджей
  *    для отчета "certificate_of_charge"
  * @autor Kushenko S.
  * @param ven_c_claim_header - ИД заголовка претензии
  * @return Оплаченная сумма по претензиям и дэмеджам
  */
  FUNCTION payed_by_claim(p_claim_header_id ven_c_claim_header.c_claim_header_id%TYPE) RETURN NUMBER;
  /**
  * Функция для вычислений итоговых значений для отчета "certificate_of_charge"
  * @autor Kushenko S.
  * @param p_pol_header - ИД договора страхования
  * @return Сумма зачтенных выплат контрагенту и выгодополучателю
  */
  FUNCTION coc_itogo_payed(p_pol_header_id NUMBER) RETURN NUMBER;
  /**
  * Функция для вычислений итоговых значений для отчета "certificate_of_charge"
  * @autor Kushenko S.
  * @param p_pol_header - ИД договора страхования
  * @return Сумма заявленных выплат
  */
  FUNCTION coc_itogo_declared(p_pol_header_id NUMBER) RETURN NUMBER;
  /**
  * Функция для вычислений итоговых значений для отчета "certificate_of_charge"
  * @autor Kushenko S.
  * @param p_pol_header - ИД договора страхования
  * @return Сумма отказа по выплатам
  */
  FUNCTION coc_itogo_rejected(p_pol_header_id NUMBER) RETURN NUMBER;
  /**
  * Приводит число к денежному формату xxx.xx с 2-мя знаками после запятой
  * так как round(xxx,2) обрезает нули
  * @autor Kushenko S.
  * @param p_n - неформатированное число
  * @return Число в денежном формате
  */
  FUNCTION to_money(p_n NUMBER) RETURN VARCHAR2;

  /**
  * Приводит число к денежному формату xxx xxx xxx,xx
  * с 2-мя знаками после запятой и разделителями разрядов
  * @autor VUstinov
  * @param p_n - неформатированное число
  * @return Число в денежном формате
  */
  FUNCTION to_money_sep(p_n NUMBER) RETURN VARCHAR2;
  FUNCTION to_money_sep4(p_n NUMBER) RETURN VARCHAR2;

  /**
  * Приводит название департиминта из вида 'xx-yy-zz Отдел продаж'
  * к следующему виду 'xx-yy-zz (Отдел продаж)'
  * @autor Kushenko S.
  * @param p_dep_name - название подразделения
  * @return - преобразованное название подразделения
  *  для отчетов по Актам БСО
  */
  FUNCTION bso_dep_name(p_dep_name IN ven_department.name%TYPE) RETURN ven_department.name%TYPE;

  /**
  * Удаляет отчет из системы
  * @param p_exe_name - exe-имя отчета
  */
  PROCEDURE unreg_report(p_exe_name rep_report.exe_name%TYPE);

  /**
  * Регистрирует отчет в системе. Позволяет регистрировать отчёты с одинаковым exe_name
  * @autor Alex Khomich
  * @param p_exe_name - exe-имя отчета,
  *        p_name - название отчета,
           p_parameters - параметры отчета,
           p_form - форма, к которой будет прикреплен отчет,
           p_rep_context - описание контекста,
           p_rep_type_id - тип отчета,
           p_datablock - дата блок, из которого будет виден отчет,
           unreg - удалять отчет с таким же exe-name, или нет
  */
  PROCEDURE reg_report
  (
    p_exe_name    rep_report.exe_name%TYPE
   ,p_name        rep_report.name%TYPE
   ,p_parameters  rep_report.parameters%TYPE DEFAULT NULL
   ,p_form        rep_context.form%TYPE DEFAULT NULL
   ,p_rep_context rep_context.rep_context%TYPE DEFAULT NULL
   ,p_rep_type_id rep_report.rep_type_id%TYPE
   ,p_datablock   rep_context.datablock%TYPE DEFAULT NULL
   ,unreg         BOOLEAN DEFAULT TRUE
   ,p_code        rep_report.code%TYPE DEFAULT NULL
   ,p_rep_templ_id rep_report.rep_templ_id%TYPE DEFAULT NULL
  );

  /**
  *  Возвращает сумму по новым или текущим ущербам
  *  @param p_claim_header_id - ИД заголовка претензии
  *  @return - Сумма ущербов
  */
  FUNCTION get_claim_head_paym_sum(p_claim_header_id NUMBER) RETURN NUMBER;

  /**
  *  Преобразование строки в параметрах в дату для отчетов в Discoverer
  *  @autor Chikashova O.
  *  @param str - параметр,
   *  @return - дата
  */

  FUNCTION param_to_date(str STRING) RETURN DATE;

  /**
  * Возвращает количество полностью оплаченных платежей
  *  @autor Mirovich M.
  *  @param pol_id - ид полиса,
  * @return - количество
  */
  FUNCTION get_col_payed_amount(pol_id NUMBER) RETURN NUMBER;

  /**
  * Возвращает количество полностью просроченных платежей
  *  @autor Mirovich M.
  *  @param pol_id - ид полиса,
  * @return - количество
  */
  FUNCTION get_col_un_payed_amount(pol_id NUMBER) RETURN NUMBER;

  /**
  *  Выбирает риски для программы и перечисляет их через запятую
  * для отчета Список застрахованных лиц ДМС
  *  @autor Kushenko S.
  *  @param p_prod_line_dms_id - ИД программы (базовой или ЛПУ)
  * @return - список рисков
  */
  FUNCTION peril_from_program_dms(p_prod_line_dms_id NUMBER) RETURN VARCHAR2;

  /**
   * Возвращает код периодичности оплаты платежей
   * @autor Mirovich M.
   * @param period - название периода оплаты
   * @return - числовой код
  */
  FUNCTION get_period_code(period VARCHAR2) RETURN NUMBER;

  /**
   * Возвращает административные издержки по договору
   * @autor Mirovich M.
   * @param pol_id - ид полиса
   * @return - административные издержки
  */
  FUNCTION get_admin_expenses(pol_id NUMBER) RETURN NUMBER;

  /**
   * Возвращает перечень программ по договору ( через запятую в виде строки)
   * @autor Mirovich M.
   * @param pol_id - ид полиса
   * @return - перечень программ
  */
  FUNCTION get_programm_list(pol_id NUMBER) RETURN VARCHAR2;

  /**
   * Возвращает дату ближайшего платежа
   * @autor Mirovich M.
   * @param pol_id - ид полиса
   * @return - дата платежа
  */
  FUNCTION get_min_date(pol_id NUMBER) RETURN DATE;

  /**
   * Возвращает сумму премии для платежа по дате
   * @autor Mirovich M.
   * @param pol_id - ид полиса
   * @param fdate - дата платежа
   * @return - сумма платежа
  */

  FUNCTION get_amount_for_date
  (
    pol_id NUMBER
   ,fdate  DATE
  ) RETURN NUMBER;
  /**
   * Возвращает код типа агента (для отчета по агентам и брокерам)
   * @autor Mirovich M.
   * @param p_agch_id- ид агентского договора
   * @return - код типа агента
  */
  FUNCTION get_type_agent_code(p_agch_id NUMBER) RETURN NUMBER;
  /**
   * Возвращает название типа агента (для отчета по агентам и брокерам)
   * @autor Mirovich M.
   * @param p_agch_id- ид агентского договора
   * @return - название типа агента
  */
  FUNCTION get_type_agent_name(p_agch_id NUMBER) RETURN VARCHAR2;
  /**
   * Возвращает признак, есть ли среди ущербов по делу мед экспертиза
   * @autor Mirovich M.
   * @param p_claim_id- ид версии претензии
   * @return - да или нет
  */
  FUNCTION get_med_expert(p_claim_id NUMBER) RETURN VARCHAR2;
  /**
   * Возвращает дату запроса документа СБ по делу
   * @autor Mirovich M.
   * @param p_claim_hed_id- ид заголовка претензии
   * @return - да или нет
  */
  FUNCTION get_claim_sb_request_date(p_claim_hed_id NUMBER) RETURN DATE;
  /**
   * Возвращает дату получения документа СБ по делу
   * @autor Mirovich M.
   * @param p_claim_hed_id- ид заголовка претензии
   * @return - да или нет
  */
  FUNCTION get_claim_sb_receipt_date(p_claim_hed_id NUMBER) RETURN DATE;
  /**
   * Возвращает дату получения документа СБ по делу
   * @autor Mirovich M.
   * @param p_dep_id- ид подразделения
   * @return - контактный телефон
  */
  FUNCTION get_department_phone(p_dep_id NUMBER) RETURN VARCHAR2;
  /**
   * Возвращает дату выплаты при расторжении договора
   * @autor Mirovich M.
   * @param p_pol_header_id - ид подразделения
   * @return - дата выплаты
  */
  FUNCTION get_decl_pay_date(p_pol_header_id NUMBER) RETURN DATE;

  /**
   * Возвращает дату первого заявления по договору
   * @autor Mirovich M.
   * @param p_pol_header_id - ид подразделения
   * @return - дата заявления
  */
  FUNCTION get_notice_date(p_pol_header_id NUMBER) RETURN DATE;

  /**
  * Вычисляем зачтенную сумму 'Копия A7' или 'Копия ПД4'
  * @author Kushenko S.
  * @param ac_payment_id ИД зачитываемого документа
  * @return Зачтенная сумма в валюте зачитываемого документа
  * @others Скоро функциия будет перенесена в другой пакет
  */
  FUNCTION a7pd4_copy_set_off_sum(p_ac_payment_id NUMBER) RETURN NUMBER;

  /**
  * Вычисляем порядковый номер Объекта страхования в Договоре Имущества'
  * @author Protsvetov E.
  * @param p_p_asset_header_id ИД заголовка застрахованного имущества
  * @param p_policy_id ИД договора
  * @return Порядковый номер
  * @others Отчёт по Договору страхования имущества
  */
  FUNCTION get_assured_order_number
  (
    p_p_asset_header_id NUMBER
   ,p_p_policy_id       NUMBER
  ) RETURN NUMBER;

  /**
  * Вычисляем количество объектов страхования в Договоре Имущества'
  * @author Protsvetov E.
  * @param p_policy_id ИД договора
  * @return Количество
  * @others Отчёт по Договору страхования имущества
  */
  FUNCTION get_assured_count(p_p_policy_id NUMBER) RETURN NUMBER;

  /**
  * Получение набора страховый покрытий по договору страхования имущества
  * @autor Protsvetov E.
  * @param p_policy_id ИД договора
  * @return Набор покрытий по договору
  * @others Отчёт по Договору страхования имущества
  */
  FUNCTION get_cvrs_of_pol(p_p_policy_id NUMBER) RETURN tb_cvr
    PIPELINED;

  /**
   * Возвращает самую раннюю из дат начала действия услуг
   * @autor Kazakevich T.
   * @param p_CONTRACT_LPU_VER_ID - код договора
   * @param p_contact_id - код ЛПУ
   * @return - дата
  */

  FUNCTION get_minim_date
  (
    p_contract_lpu_ver_id NUMBER
   ,p_contact_id          NUMBER
  ) RETURN DATE;

  /**
  * Возвращает агентство
  * @author Svarschik
  * @param p_p_policy_id
  */
  FUNCTION get_agency_to_pd4(p_p_policy_id NUMBER) RETURN VARCHAR2;
  /*
    Байтин А.
    Процедура генерации отчета в виду BLOB. Далее отчет может быть сохранен процедурой store_report либо обработан специальным обработчиком
  */
  PROCEDURE exec_report
  (
    par_report_id NUMBER
   ,par_report    OUT t_report
  );
  PROCEDURE exec_report
  (
    par_report_id    NUMBER
   ,par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_pages_count  OUT NUMBER
   ,par_report       OUT BLOB
  );

  PROCEDURE exec_procedure
  (
    par_procedure_name VARCHAR2
   ,par_content_type   OUT VARCHAR2
   ,par_file_name      OUT VARCHAR2
   ,par_report         OUT BLOB
  );
  /*
    Байтин А.
    Процедура для выполнения отчета в AS, с последующей записью результата во временную таблицу
    Перед выполнением необходимо сделать ins.repcore.set_context для установки параметров отчета
  
    Сделать на PROD:
    insert into ven_app_param vp
    (name, brief, def_value_c, param_type, app_param_group_id)
    values
    ('URL для авторизации в AS', 'AUTH_AS_URL', 'http://bidev.renlife.com:7777/sso/auth',0, 2)
  
  */
  PROCEDURE exec_and_store_report
  (
    par_report_id   NUMBER
   ,par_file_name   VARCHAR2
   ,par_parent_id   NUMBER
   ,par_document_id NUMBER
   ,par_order_num   VARCHAR2
   ,par_pages       NUMBER DEFAULT NULL
  );

  /**
   * Процедура для получения даты в родительном падеже
   * author Чирков В.
   * @param p_date дата приведения
  */
  FUNCTION date_to_genitive_case(p_date DATE) RETURN VARCHAR2;
  /*
   * Черных М.Г. 15.05.2014
   * Дата в родительном падеже (число в кавычках)
  */
  FUNCTION date_to_genitive_case_quotes(p_date DATE) RETURN VARCHAR2;
  PROCEDURE rla_act_second_fl_agent(par_ag_roll_id NUMBER);
  PROCEDURE rla_act_second_fl_trans(par_ag_roll_id NUMBER);
  PROCEDURE rla_act_second_fl_commiss(par_ag_roll_id NUMBER);
  PROCEDURE rla_act_second_fl_2089(par_ag_roll_id NUMBER);
  PROCEDURE rla_calculation_agent(par_ag_roll_id NUMBER);
  PROCEDURE rla_calculation_pol(par_ag_roll_id NUMBER);
  PROCEDURE rla_act_second_kvg_commiss(par_ag_roll_id NUMBER);

  /*
    Пиядин А. 301732 ТЗ Финмониторинг
    Функция возвращает id идентифицирующего документа в
    соответствии с требованиями отчета "Анкета финмониторинг"
  
    @ par_contact_id    - id контакта
    @ par_pol_sign_date - дата подписания ДС
  */
  FUNCTION get_finmon_ident_id
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_pol_sign_date p_policy.sign_date%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE;

  /*
    Капля П.С.
    23.05.2014
    Добавление подписанта в отчет
  */
  PROCEDURE register_signer_for_report
  (
    par_report_exe_name     rep_report.exe_name%TYPE
   ,par_signer_contact_name t_signer.contact_name%TYPE
  );
END pkg_rep_utils;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_utils AS

  FUNCTION concatenate_list(p_cursor IN SYS_REFCURSOR) RETURN VARCHAR2 IS
    l_return VARCHAR2(32767);
    l_temp   VARCHAR2(32767);
  BEGIN
    LOOP
      FETCH p_cursor
        INTO l_temp;
      EXIT WHEN p_cursor%NOTFOUND;
      l_return := l_return || ',' || l_temp;
    END LOOP;
    RETURN ltrim(l_return, ',');
  END;

  FUNCTION hyphenation
  (
    p_str VARCHAR2
   ,p_n1  NUMBER
   ,p_n2  NUMBER DEFAULT 0
   ,p_n3  NUMBER DEFAULT 0
  ) RETURN VARCHAR2 AS
    l   NUMBER; -- Для вычисления конечного вхождения символа переноса
    buf VARCHAR2(5000);
    p1  NUMBER;
    p2  NUMBER;
    p3  NUMBER;
    st  VARCHAR2(5000);
  BEGIN
    -- Слова можно переносить там где есть ПРОБЕЛ '-',',','.',':',';'
  
    p1  := p_n1 - 1; --Делаем запас на 1 символ
    st  := p_str;
    st  := rtrim(ltrim(st, ' ,.-:;'), ' ,.-:;'); --Чистим входящий параметр
    buf := substr(st, 1, p1);
    -- Хотим, чтобы ',','-' и т.п. не переносились на след строку, а оставались
    IF (substr(st, p1 + 1, 1)) IN ('-', ',', '.', ':', ';')
    THEN
      buf := substr(st, 1, p1 + 1);
    END IF;
  
    IF NOT (((substr(st, p1, 1)) IN (' ', '-', ',', '.', ':', ';')) OR
        ((substr(st, p1 + 1, 1)) IN (' ', '-', ',', '.', ':', ';')))
    THEN
      l := instr(buf, ' ', -1);
      IF l < instr(buf, ',', -1)
      THEN
        l := instr(buf, ',', -1);
      END IF;
      IF l < instr(buf, '.', -1)
      THEN
        l := instr(buf, '.', -1);
      END IF;
      IF l < instr(buf, '-', -1)
      THEN
        l := instr(buf, '-', -1);
      END IF;
      IF l < instr(buf, ':', -1)
      THEN
        l := instr(buf, ':', -1);
      END IF;
      IF l < instr(buf, ';', -1)
      THEN
        l := instr(buf, ';', -1);
      END IF;
      buf := substr(buf, 1, l - 1);
    END IF;
  
    IF p_n2 = 0
    THEN
      RETURN(buf);
    END IF;
  
    p2  := p_n2 - 1;
    l   := length(buf);
    st  := substr(st, l + 1, 5000);
    st  := rtrim(ltrim(st, ' ,.-:;'), ' ,.-:;'); --Чистим входящий параметр
    buf := substr(st, 1, p2);
    -- Хотим, чтобы ',','-' и т.п. не переносились на след строку, а оставались
    IF (substr(st, p2 + 1, 1)) IN ('-', ',', '.', ':', ';')
    THEN
      buf := substr(st, 1, p2 + 1);
    END IF;
  
    IF NOT (((substr(st, p2, 1)) IN (' ', '-', ',', '.', ':', ';')) OR
        ((substr(st, p2 + 1, 1)) IN (' ', '-', ',', '.', ':', ';')))
    THEN
      l := instr(buf, ' ', -1);
      IF l < instr(buf, ',', -1)
      THEN
        l := instr(buf, ',', -1);
      END IF;
      IF l < instr(buf, '.', -1)
      THEN
        l := instr(buf, '.', -1);
      END IF;
      IF l < instr(buf, '-', -1)
      THEN
        l := instr(buf, '-', -1);
      END IF;
      IF l < instr(buf, ':', -1)
      THEN
        l := instr(buf, ':', -1);
      END IF;
      IF l < instr(buf, ';', -1)
      THEN
        l := instr(buf, ';', -1);
      END IF;
      buf := substr(buf, 1, l - 1);
    END IF;
  
    IF p_n3 = 0
    THEN
      RETURN(buf);
    END IF;
  
    p3  := p_n3 - 1;
    l   := length(buf);
    st  := substr(st, l + 1, 5000);
    st  := rtrim(ltrim(st, ' ,.-:;'), ' ,.-:;'); --Чистим входящий параметр
    buf := substr(st, 1, p3);
    -- Хотим, чтобы ',','-' и т.п. не переносились на след строку, а оставались
    IF (substr(st, p3 + 1, 1)) IN ('-', ',', '.', ':', ';')
    THEN
      buf := substr(st, 1, p3 + 1);
    END IF;
  
    IF NOT (((substr(st, p3, 1)) IN (' ', '-', ',', '.', ':', ';')) OR
        ((substr(st, p3 + 1, 1)) IN (' ', '-', ',', '.', ':', ';')))
    THEN
      l := instr(buf, ' ', -1);
      IF l < instr(buf, ',', -1)
      THEN
        l := instr(buf, ',', -1);
      END IF;
      IF l < instr(buf, '.', -1)
      THEN
        l := instr(buf, '.', -1);
      END IF;
      IF l < instr(buf, '-', -1)
      THEN
        l := instr(buf, '-', -1);
      END IF;
      IF l < instr(buf, ':', -1)
      THEN
        l := instr(buf, ':', -1);
      END IF;
      IF l < instr(buf, ';', -1)
      THEN
        l := instr(buf, ';', -1);
      END IF;
      buf := substr(buf, 1, l - 1);
    END IF;
  
    RETURN(buf);
  
  END;

  FUNCTION get_event_contacts_info(p_event_id IN NUMBER) RETURN VARCHAR2 IS
    res VARCHAR2(2000);
    CURSOR curl IS
      SELECT c.short_name AS NAME
            ,decode(upper(TRIM(ecr.description))
                   ,'ВОДИТЕЛЬ, УПРАВЛЯВШИЙ ТС'
                   ,'Управлявший ТС'
                   ,ecr.description) AS rol
            ,(SELECT telephone_number
                FROM cn_contact_telephone ct
               WHERE ct.contact_id = c.contact_id
                 AND rownum = 1) AS telep
            ,
             
             (SELECT ad.city_name || ', ул.' || ad.street_name || ', д.' || ad.house_nr || ', кв.' ||
                     ad.appartment_nr
                FROM cn_address         ad
                    ,cn_contact_address ca
               WHERE ca.contact_id = c.contact_id
                 AND ca.adress_id = ad.id
                 AND rownum = 1) AS addr
        FROM ven_c_event_contact      ec
            ,ven_contact              c
            ,ven_c_event_contact_role ecr
      
       WHERE ec.c_event_id = p_event_id
         AND ec.cn_person_id = c.contact_id
         AND ecr.c_event_contact_role_id = ec.c_event_contact_role_id
         AND (upper(TRIM(ecr.description)) LIKE 'ПОТЕРПЕВШИЙ' OR
             upper(TRIM(ecr.description)) LIKE 'ЗАЯВИТЕЛЬ' OR
             upper(TRIM(ecr.description)) LIKE 'ВОДИТЕЛЬ, УПРАВЛЯВШИЙ ТС')
         AND NOT EXISTS
       (SELECT 1
                FROM ven_c_event_contact      ec1
                    ,ven_c_event_contact_role ecr1
               WHERE ec1.c_event_id = ec.c_event_id
                 AND ec1.c_event_contact_id > ec.c_event_contact_id
                 AND ec1.cn_person_id = ec.cn_person_id
                 AND ecr1.c_event_contact_role_id = ec1.c_event_contact_role_id
                 AND (upper(TRIM(ecr1.description)) LIKE 'ПОТЕРПЕВШИЙ' OR
                     upper(TRIM(ecr1.description)) LIKE 'ЗАЯВИТЕЛЬ' OR
                     upper(TRIM(ecr1.description)) LIKE 'ВОДИТЕЛЬ, УПРАВЛЯВШИЙ ТС'));
  BEGIN
    FOR rec IN curl
    LOOP
      res := res || rec.name || ' ' || rec.addr || ' ' || rec.telep || ' (' || rec.rol || '); ';
    END LOOP;
    --DBMS_OUTPUT.put_line(substr(res,1,160));
    RETURN substr(res, 1, 200);
  
  END;

  FUNCTION get_event_contacts_info_2(p_event_id IN NUMBER) RETURN VARCHAR2 IS
    res VARCHAR2(2000);
    CURSOR curl IS
      SELECT c.short_name AS NAME
            ,decode(upper(TRIM(ecr.description))
                   ,'ВОДИТЕЛЬ, УПРАВЛЯВШИЙ ТС'
                   ,'Управлявший ТС'
                   ,ecr.description) AS rol
            ,(SELECT telephone_number
                FROM cn_contact_telephone ct
               WHERE ct.contact_id = c.contact_id
                 AND rownum = 1) AS telep
            ,
             
             (SELECT ad.city_name || ', ул.' || ad.street_name || ', д.' || ad.house_nr || ', кв.' ||
                     ad.appartment_nr
                FROM cn_address         ad
                    ,cn_contact_address ca
               WHERE ca.contact_id = c.contact_id
                 AND ca.adress_id = ad.id
                 AND rownum = 1) AS addr
        FROM ven_c_event_contact      ec
            ,ven_contact              c
            ,ven_c_event_contact_role ecr
      
       WHERE ec.c_event_id = p_event_id
         AND ec.cn_person_id = c.contact_id
         AND ecr.c_event_contact_role_id = ec.c_event_contact_role_id
         AND (upper(TRIM(ecr.description)) LIKE 'СВИДЕТЕЛЬ' OR
             upper(TRIM(ecr.description)) LIKE 'ВИНОВНИК')
         AND NOT EXISTS (SELECT 1
                FROM ven_c_event_contact      ec1
                    ,ven_c_event_contact_role ecr1
               WHERE ec1.c_event_id = ec.c_event_id
                 AND ec1.c_event_contact_id > ec.c_event_contact_id
                 AND ec1.cn_person_id = ec.cn_person_id
                 AND ecr1.c_event_contact_role_id = ec1.c_event_contact_role_id
                 AND (upper(TRIM(ecr1.description)) LIKE 'СВИДЕТЕЛЬ' OR
                     upper(TRIM(ecr1.description)) LIKE 'ВИНОВНИК'));
  BEGIN
    FOR rec IN curl
    LOOP
      res := res || rec.name || ' ' || rec.addr || ' ' || rec.telep || ' (' || rec.rol || '); ';
    END LOOP;
    --DBMS_OUTPUT.put_line(substr(res,1,160));
    RETURN substr(res, 1, 200);
  
  END;

  -- УГОН 1
  -- УЩЕРБ 2
  FUNCTION is_hijacking(p_claim_header_id IN NUMBER) RETURN NUMBER IS
    buf NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO buf
      FROM c_damage       d
          ,c_claim        c
          ,c_claim_header ch
          ,t_damage_code  dc
     WHERE ch.c_claim_header_id = p_claim_header_id
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND d.c_claim_id = c.c_claim_id
       AND dc.id = d.t_damage_code_id
       AND NOT EXISTS (SELECT 1
              FROM c_claim c1
             WHERE c1.c_claim_header_id = c.c_claim_header_id
               AND c1.seqno > c.seqno)
       AND upper(TRIM(dc.description)) LIKE 'ХИЩЕНИЕ ТС%';
    IF buf > 0
    THEN
      buf := 1; -- Угон
    ELSE
      buf := 2; -- Ущерб
    END IF;
    RETURN buf;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 2;
  END; -- is_hijacking

  -- Сумма/валюта заявленного убытка
  FUNCTION claim_sum_fund(p_claim_header_id IN NUMBER) RETURN VARCHAR2 IS
    buf VARCHAR2(20);
  BEGIN
    SELECT c.declare_sum || '  ' || f.brief
      INTO buf
      FROM ven_c_claim        c
          ,ven_c_claim_header ch
          ,ven_p_policy       p
          ,ven_p_pol_header   ph
          ,ven_fund           f
     WHERE ch.c_claim_header_id = p_claim_header_id
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND ch.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND ph.fund_id = f.fund_id
       AND NOT EXISTS (SELECT 1
              FROM ven_c_claim c1
             WHERE c1.c_claim_header_id = c.c_claim_header_id
               AND c1.seqno > c.seqno);
  
    RETURN buf;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END; -- claim_sum_fund

  FUNCTION sum_pay_all(p_claim_header_id IN NUMBER) RETURN NUMBER IS
    -- За основу положена одноименная функция формы CLAIM
    s                 NUMBER;
    v_rt              ven_rate_type.rate_type_id%TYPE;
    ch_fund_id        ven_c_claim_header.fund_id%TYPE;
    ch_event_date     ven_c_event.event_date%TYPE;
    ch_as_asset_id    ven_c_claim_header.as_asset_id%TYPE;
    ch_prod_line_name ven_t_prod_line_option.description%TYPE;
  
  BEGIN
    SELECT r.rate_type_id INTO v_rt FROM ven_rate_type r WHERE r.brief = 'ЦБ';
  
    SELECT ch.fund_id
          ,e.event_date
          ,pl.description
          ,ch.as_asset_id
      INTO ch_fund_id
          ,ch_event_date
          ,ch_prod_line_name
          ,ch_as_asset_id
      FROM ven_c_claim_header     ch
          ,ven_c_event            e
          ,ven_p_cover            pc
          ,ven_t_prod_line_option pl
     WHERE ch.c_event_id = e.c_event_id
       AND ch.c_claim_header_id = p_claim_header_id
       AND ch.p_cover_id = pc.p_cover_id(+)
       AND pc.t_prod_line_option_id = pl.id(+);
  
    SELECT SUM(a)
      INTO s
      FROM (SELECT nvl(ROUND(acc.get_cross_rate_by_id(v_rt, d.damage_fund_id, ch_fund_id, ch_event_date) *
                             (nvl(SUM(d.declare_sum), 0) - nvl(SUM(d.deduct_sum), 0) -
                              nvl(SUM(d.decline_sum), 0))
                            ,2)
                      ,0) a
              FROM ven_c_claim_header     ch
                  ,ven_p_policy           p
                  ,ven_c_claim            c
                  ,ven_c_damage           d
                  ,ven_p_cover            pc
                  ,ven_as_asset           a
                  ,ven_t_prod_line_option plo
             WHERE ch.p_policy_id = p.policy_id
               AND c.c_claim_header_id = ch.c_claim_header_id
               AND d.c_claim_id = c.c_claim_id
               AND ch.p_cover_id = pc.p_cover_id(+)
               AND pc.t_prod_line_option_id = plo.id(+)
               AND a.as_asset_id = ch.as_asset_id
               AND ch.as_asset_id = ch_as_asset_id
               AND plo.description = ch_prod_line_name
               AND c.seqno = (SELECT MAX(cm.seqno)
                                FROM c_claim cm
                               WHERE cm.c_claim_header_id = ch.c_claim_header_id)
             GROUP BY d.damage_fund_id);
  
    RETURN s;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
    
  END;

  FUNCTION passport_issuer(p_contact_id IN NUMBER) RETURN VARCHAR2 AS
    l_buf VARCHAR2(200);
  BEGIN
    SELECT passport || issue
      INTO l_buf
      FROM (SELECT tid.description || decode(cci.serial_nr, NULL, ' ', ' серия ' || cci.serial_nr) ||
                   ' № ' || cci.id_value AS passport
                  ,tid.description AS description
                  ,decode(cci.place_of_issue
                         ,NULL
                         ,' '
                         ,' выдан: ' || to_char(cci.issue_date, 'dd.mm.yyyy') || ' ' ||
                          cci.place_of_issue) issue
              FROM cn_contact_ident cci
                  ,t_id_type        tid
             WHERE cci.id_type = tid.id
               AND p_contact_id = cci.contact_id
             ORDER BY nvl(cci.is_default, 0) DESC)
     WHERE rownum = 1;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END;

  FUNCTION passport_issuer_2(p_contact_id IN NUMBER) RETURN VARCHAR2 AS
    l_buf VARCHAR2(200);
  BEGIN
    SELECT passport || issue
      INTO l_buf
      FROM (SELECT decode(cci.serial_nr, NULL, ' ', ' Серия ' || cci.serial_nr) || ' № ' ||
                   cci.id_value AS passport
                  ,tid.description AS description
                  ,decode(cci.place_of_issue
                         ,NULL
                         ,' '
                         ,' Выдан ' || cci.place_of_issue || ' ,когда ' ||
                          to_char(cci.issue_date, 'dd.mm.yyyy') || 'г.') issue
              FROM cn_contact_ident cci
                  ,t_id_type        tid
             WHERE cci.id_type = tid.id
               AND p_contact_id = cci.contact_id
             ORDER BY nvl(cci.is_default, 0) DESC)
     WHERE rownum = 1;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END;

  FUNCTION contact_addr
  (
    p_contact_id IN NUMBER
   ,p_cont_type  OUT VARCHAR2
  ) RETURN VARCHAR2 AS
    buf VARCHAR2(255);
  BEGIN
    SELECT substr(address_name, 1, 255)
          ,brief
      INTO buf
          ,p_cont_type
      FROM (SELECT vcca.address_type_name ad_type
                  ,vcca.is_default AS is_default
                  ,ct.brief AS brief
                  ,decode(upper(vcca.address_type_name)
                         ,'АДРЕС ФАКТИЧЕСКОГО НАХОЖДЕНИЯ'
                         ,11 + decode(upper(ct.brief), 'ФЛ', 100, 0) - vcca.is_default * 10
                         ,'АДРЕС ПОСТОЯННОЙ РЕГИСТРАЦИИ'
                         ,12 + decode(upper(ct.brief), 'ФЛ', 0, 100) - vcca.is_default * 10
                         ,'АДРЕС ВРЕМЕННОЙ РЕГИСТРАЦИИ'
                         ,13 + decode(upper(ct.brief), 'ФЛ', 0, 100) - vcca.is_default * 10
                         ,1000 - vcca.is_default * 10) AS r
                  ,vcca.address_name AS address_name
              FROM v_cn_contact_address vcca
                  ,t_contact_type       ct
                  ,contact              c
             WHERE vcca.contact_id = p_contact_id
               AND c.contact_type_id = ct.id
               AND c.contact_id = vcca.contact_id
             ORDER BY r)
     WHERE rownum = 1;
    RETURN buf;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN ' ';
  END; --function

  FUNCTION doc_num
  (
    p_contact_id IN NUMBER
   ,p_doc_type   IN VARCHAR2
  ) RETURN VARCHAR2 AS
    l_buf VARCHAR2(30);
  BEGIN
    SELECT nvl(cci.serial_nr, '') || decode(cci.serial_nr, NULL, '', '-') || to_char(cci.id_value)
      INTO l_buf
      FROM cn_contact_ident cci
          ,t_id_type        tid
     WHERE upper(tid.description) LIKE p_doc_type
       AND cci.id_type = tid.id
       AND cci.contact_id = p_contact_id
       AND rownum = 1;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END;

  FUNCTION contact_phone(p_contact_id IN NUMBER) RETURN VARCHAR2 AS
    l_buf VARCHAR2(100);
  BEGIN
    SELECT decode(id, NULL, '', pkg_contact.get_telephone(id))
      INTO l_buf
      FROM (SELECT ct.id
              FROM cn_contact_telephone ct
                  ,t_telephone_type     tt
             WHERE ct.contact_id = p_contact_id
               AND ct.telephone_type = tt.id
             ORDER BY tt.sort_order)
     WHERE rownum = 1;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;

  FUNCTION contact_address(p_contact_id IN NUMBER) RETURN NUMBER AS
    l_buf NUMBER;
  BEGIN
    SELECT aid
      INTO l_buf
      FROM (SELECT ca.adress_id aid
              FROM cn_contact_address ca
                  ,t_address_type     tat
             WHERE ca.address_type = tat.id
               AND ca.contact_id = p_contact_id
             ORDER BY tat.sort_order)
     WHERE rownum < 2;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_telephones_with_typ(par_contact_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR c IS
      SELECT cct.*
            ,ttt.description
        FROM cn_contact_telephone cct
            ,t_telephone_type     ttt
       WHERE cct.contact_id = par_contact_id
         AND cct.telephone_type = ttt.id
       ORDER BY ttt.sort_order;
  
    v_count        NUMBER := 0;
    v_cct          c%ROWTYPE;
    v_phone_number VARCHAR2(1000) := '';
  BEGIN
    OPEN c;
    LOOP
      FETCH c
        INTO v_cct;
      EXIT WHEN c%NOTFOUND;
    
      v_count := v_count + 1;
    
      IF v_count > 1
      THEN
        v_phone_number := v_phone_number || ', ' || v_cct.description || ': +7' ||
                          pkg_contact.get_telephone(v_cct.id);
      ELSE
        v_phone_number := v_phone_number || v_cct.description || ': +7' ||
                          pkg_contact.get_telephone(v_cct.id);
      END IF;
    
    END LOOP;
    RETURN v_phone_number;
  END;

  FUNCTION days_from_grace_period(p_policy_id IN NUMBER) RETURN NUMBER AS
    l_buf NUMBER;
  BEGIN
  
    SELECT to_number(substr(tp.description, 1, instr(tp.description, ' ') - 1))
      INTO l_buf
      FROM ven_p_policy pp
      JOIN ven_t_period tp
        ON tp.id = pp.grace_period_id
     WHERE pp.policy_id = p_policy_id
       AND rownum < 2;
  
    IF l_buf IS NULL
    THEN
      l_buf := 0;
    END IF;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION contact_email(p_contact_id IN NUMBER) RETURN VARCHAR2 AS
    l_buf VARCHAR2(100);
  BEGIN
    SELECT email
      INTO l_buf
      FROM cn_contact_email ce
          ,t_email_type     et
     WHERE contact_id = p_contact_id
       AND ce.email_type = et.id
       AND rownum = 1;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;

  FUNCTION vehicle_at_device(p_vehicle_id IN NUMBER) RETURN VARCHAR2 AS
    buf VARCHAR(100) := '';
    CURSOR cur1 IS
      SELECT TRIM(REPLACE(ent.obj_name(atd.ent_id, atd.as_vehicle_at_device_id), chr(10), '')) AS at_name
        FROM as_vehicle_at_device atd
       WHERE atd.as_vehicle_id = p_vehicle_id
       ORDER BY atd.as_vehicle_at_device_id DESC;
  BEGIN
    /*
    TODO: owner="skushenko" created="11.10.2007"
    text="Проверить корректность работы функции для сигнализаций на отечественные! и иностранные машины"
    */
    FOR rec IN cur1
    LOOP
      buf := buf || rec.at_name || '; ';
    END LOOP;
  
    RETURN buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;

  FUNCTION pay_prem_policy(p_policy_id IN NUMBER) RETURN NUMBER AS
    buf1 NUMBER;
    buf2 NUMBER;
    buf3 NUMBER;
  BEGIN
  
    /**
    * По полису возвращает страховую сумму, премию и оплаченную премию
    * @author Patsan O.
    * @param par_pol_id ИД полиса
    * @param pr_ins_amount Страховая сумма
    * @param par_prem_amount Премия
    * @param par_pay_amount Оплаченная премия
    */
  
    pkg_payment.get_pol_pay_status(p_policy_id, buf1, buf2, buf3);
    RETURN buf3;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  FUNCTION payed_by_claim(p_claim_header_id ven_c_claim_header.c_claim_header_id%TYPE) RETURN NUMBER AS
    buf NUMBER;
  BEGIN
    SELECT nvl(SUM(tr.acc_amount), 0)
      INTO buf
      FROM ven_c_claim_header ch
          ,ven_c_claim        cc
          ,ven_c_damage       cd
          ,ven_trans          tr
          ,ven_trans_templ    tt
     WHERE ch.c_claim_header_id = p_claim_header_id
       AND cc.c_claim_header_id = ch.c_claim_header_id
       AND cd.c_claim_id = cc.c_claim_id
       AND tr.a5_dt_uro_id = cd.c_damage_id
       AND tt.trans_templ_id = tr.trans_templ_id
       AND tt.brief IN ('ЗачВыплКонтр', 'ЗачВыплВыгод');
  
    RETURN buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION coc_itogo_payed(p_pol_header_id NUMBER) RETURN NUMBER AS
    buf NUMBER;
  BEGIN
    SELECT SUM(tr.acc_amount * acc_new.get_cross_rate_by_brief(1, f.brief, 'RUR'))
      INTO buf
      FROM ven_c_claim_header ch
          ,c_event            ce
          ,t_catastrophe_type ct
          ,fund               f
          ,c_claim            cc
          ,c_damage           cd
          ,trans              tr
          ,trans_templ        tt
          ,p_pol_header       ph
          ,p_policy           p
          ,as_asset           a
     WHERE ce.c_event_id = ch.c_event_id
       AND ct.id = ce.catastrophe_type_id
       AND f.fund_id = ch.fund_id
       AND cc.c_claim_header_id = ch.c_claim_header_id
       AND cd.c_claim_id = cc.c_claim_id
       AND tr.a5_dt_uro_id = cd.c_damage_id
       AND tt.trans_templ_id = tr.trans_templ_id
       AND tt.brief IN ('ЗачВыплКонтр', 'ЗачВыплВыгод')
       AND p.pol_header_id = ph.policy_header_id
       AND a.p_policy_id = p.policy_id
       AND ce.as_asset_id = a.as_asset_id
       AND ph.policy_header_id = p_pol_header_id;
  
    RETURN nvl(buf, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
    
  END;

  FUNCTION coc_itogo_declared(p_pol_header_id NUMBER) RETURN NUMBER AS
    buf NUMBER;
  BEGIN
    SELECT SUM((sumv - pkg_rep_utils.payed_by_claim(c_claim_header_id)) *
               acc_new.get_cross_rate_by_brief(1, brief, 'RUR'))
      INTO buf
      FROM (SELECT ch.c_claim_header_id AS c_claim_header_id
                  ,MIN(ch.num) AS num
                  ,ct.description AS description
                  ,ch.is_criminal AS is_criminal
                  ,ch.is_regress AS is_regress
                  ,SUM(cc.declare_sum) AS sumv
                  ,f.brief AS brief
              FROM ven_c_claim_header ch
                  ,c_event            ce
                  ,t_catastrophe_type ct
                  ,fund               f
                  ,c_claim            cc
                  ,p_pol_header       ph
                  ,p_policy           p
                  ,as_asset           a
             WHERE ce.c_event_id = ch.c_event_id
               AND ct.id = ce.catastrophe_type_id
               AND f.fund_id = ch.fund_id
               AND cc.c_claim_header_id = ch.c_claim_header_id
               AND cc.seqno = (SELECT MAX(seqno)
                                 FROM c_claim cc2
                                WHERE cc2.c_claim_header_id = cc.c_claim_header_id)
               AND p.pol_header_id = ph.policy_header_id
               AND a.p_policy_id = p.policy_id
               AND ce.as_asset_id = a.as_asset_id
               AND ph.policy_header_id = p_pol_header_id
             GROUP BY ch.c_claim_header_id
                     ,ct.description
                     ,ch.is_criminal
                     ,ch.is_regress
                     ,f.brief
            HAVING nvl(SUM(cc.declare_sum), 0) > 0);
  
    RETURN nvl(buf, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION coc_itogo_rejected(p_pol_header_id NUMBER) RETURN NUMBER AS
    buf NUMBER;
  BEGIN
    SELECT SUM(cd.decline_sum * acc_new.get_cross_rate_by_brief(1, f.brief, 'RUR'))
      INTO buf
      FROM ven_c_claim_header ch
          ,c_event            ce
          ,t_catastrophe_type ct
          ,fund               f
          ,c_claim            cc
          ,c_damage           cd
          ,p_pol_header       ph
          ,p_policy           p
          ,as_asset           a
    
     WHERE ce.c_event_id = ch.c_event_id
       AND ct.id = ce.catastrophe_type_id
       AND f.fund_id = ch.fund_id
       AND cc.c_claim_header_id = ch.c_claim_header_id
       AND cd.c_claim_id = cc.c_claim_id
       AND cc.seqno =
           (SELECT MAX(seqno) FROM c_claim cc2 WHERE cc2.c_claim_header_id = cc.c_claim_header_id)
       AND p.pol_header_id = ph.policy_header_id
       AND a.p_policy_id = p.policy_id
       AND ce.as_asset_id = a.as_asset_id
       AND ph.policy_header_id = p_pol_header_id;
  
    RETURN nvl(buf, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION to_money(p_n NUMBER) RETURN VARCHAR2 AS
    buf VARCHAR2(20);
    num NUMBER;
  BEGIN
    IF p_n IS NULL
    THEN
      RETURN '0,00';
    END IF;
    num := ROUND(p_n, 2);
    buf := to_char(trunc(num));
    buf := buf || ',' || to_char(trunc(num * 10 - trunc(num) * 10));
    buf := buf || to_char(num * 100 - trunc(num * 10) * 10);
  
    RETURN buf;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION to_money_sep(p_n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN ltrim(to_char(p_n, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', '''));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION to_money_sep4(p_n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN ltrim(to_char(p_n, '999G999G999G999G999G999G990D9999', 'NLS_NUMERIC_CHARACTERS = '', '''));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Преобразует имя подразделения из вида 'xx-yy-zz Отдел закупок'
  -- к виду 'xx-yy-zz (Отдел закупок)'
  FUNCTION bso_dep_name(p_dep_name IN ven_department.name%TYPE) RETURN ven_department.name%TYPE AS
    v_dep_name ven_department.name%TYPE;
  BEGIN
    IF p_dep_name IS NULL
    THEN
      RETURN NULL;
    END IF;
    v_dep_name := substr(p_dep_name, 1, instr(p_dep_name, ' ') - 1) || ' (' ||
                  substr(p_dep_name, instr(p_dep_name, ' ') + 1, length(p_dep_name)) || ')';
    RETURN v_dep_name;
  END;

  PROCEDURE unreg_report(p_exe_name rep_report.exe_name%TYPE) AS
  BEGIN
    DELETE FROM ven_rep_context c
     WHERE c.rep_report_id IN
           (SELECT r.rep_report_id FROM ven_rep_report r WHERE exe_name LIKE p_exe_name);
    DELETE FROM ven_rep_report WHERE exe_name LIKE p_exe_name;
  END;

  PROCEDURE reg_report
  (
    p_exe_name    rep_report.exe_name%TYPE
   ,p_name        rep_report.name%TYPE
   ,p_parameters  rep_report.parameters%TYPE DEFAULT NULL
   ,p_form        rep_context.form%TYPE DEFAULT NULL
   ,p_rep_context rep_context.rep_context%TYPE DEFAULT NULL
   ,p_rep_type_id rep_report.rep_type_id%TYPE
   ,p_datablock   rep_context.datablock%TYPE DEFAULT NULL
   ,unreg         BOOLEAN DEFAULT TRUE
   ,p_code        rep_report.code%TYPE DEFAULT NULL
   ,p_rep_templ_id rep_report.rep_templ_id%TYPE DEFAULT NULL
  ) AS
    v_report_id rep_report.rep_report_id%TYPE;
  BEGIN
  
    /*
    TODO: owner="skushenko" created="14.02.2007"
    text="Настроить констрейн, на каскадное удаление контекста по внешнему ключу"
    */
    IF unreg
    THEN
      -- Удаляем отчеты и их контексты с таким же exe_name
      unreg_report(p_exe_name);
    END IF;
  
    -- Заносим данные об отчете в таблицу rep_report
    INSERT INTO ven_rep_report
      (exe_name, NAME, PARAMETERS, rep_type_id, code, rep_templ_id)
    VALUES
      (p_exe_name, p_name, p_parameters, p_rep_type_id, p_code, p_rep_templ_id);
    IF p_form IS NOT NULL
       OR TRIM(p_form) != ''
    THEN
      -- Выбираем ИДшник, полученный из последовательности
      SELECT sq_rep_report.currval INTO v_report_id FROM dual;
      -- Заносим данные о контексте в rep_context
      INSERT INTO ven_rep_context
        (datablock, form, rep_context, rep_report_id)
      VALUES
        (p_datablock, p_form, p_rep_context, v_report_id);
    END IF;
  
  END;

  --Замена 'СЕГОДНЯ' на текущую дату
  FUNCTION param_to_date(str STRING) RETURN DATE IS
    data DATE;
  BEGIN
    IF (upper(str) = 'СЕГОДНЯ')
    THEN
      data := SYSDATE;
    ELSE
      data := to_date(str, 'DD.MM.YYYY');
    END IF;
  
    RETURN(data);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SYSDATE;
  END;

  -- возвращает количество полностью оплаченных платежей
  FUNCTION get_col_payed_amount(pol_id NUMBER) RETURN NUMBER IS
    col NUMBER;
  BEGIN
    SELECT COUNT(dof.doc_set_off_id)
      INTO col
      FROM v_policy_payment_schedule sch
      LEFT JOIN ven_ac_payment ap
        ON ap.payment_id = sch.document_id
      LEFT JOIN ven_doc_set_off dof
        ON dof.parent_doc_id = ap.payment_id
     WHERE (dof.doc_set_off_id IS NULL OR dof.set_off_amount = sch.part_amount)
       AND sch.policy_id = pol_id
       AND sch.due_date <= SYSDATE;
    RETURN(col);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает количесто полностью просроченных платежей
  FUNCTION get_col_un_payed_amount(pol_id NUMBER) RETURN NUMBER IS
    col NUMBER;
  BEGIN
    SELECT COUNT(dof.doc_set_off_id)
      INTO col
      FROM v_policy_payment_schedule sch
      LEFT JOIN ven_ac_payment ap
        ON ap.payment_id = sch.document_id
      LEFT JOIN ven_doc_set_off dof
        ON dof.parent_doc_id = ap.payment_id
     WHERE (dof.doc_set_off_id IS NULL OR dof.set_off_amount < sch.part_amount)
       AND sch.policy_id = pol_id
       AND sch.due_date <= SYSDATE;
    RETURN(col);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_claim_head_paym_sum(p_claim_header_id NUMBER) RETURN NUMBER AS
    n1 NUMBER;
  
  BEGIN
    SELECT SUM(nvl(pkg_claim.f_d2(d.c_damage_id, d.payment_sum), 0))
      INTO n1
      FROM ven_c_damage    d
          ,ven_status_hist sh
     WHERE d.c_claim_id = pkg_claim.get_curr_claim(p_claim_header_id)
       AND d.status_hist_id = sh.status_hist_id
       AND sh.brief IN ('NEW', 'CURRENT');
    RETURN(n1);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  FUNCTION peril_from_program_dms(p_prod_line_dms_id NUMBER) RETURN VARCHAR2 AS
    buf VARCHAR2(1000) := '';
  BEGIN
    FOR i IN (SELECT a
                    ,rownum
                FROM (SELECT tp.description AS a
                        FROM ven_t_prod_line_dms       pld1
                            ,ven_t_prod_line_option    plo1
                            ,ven_t_prod_line_opt_peril plop
                            ,ven_t_peril               tp
                       WHERE plo1.product_line_id = pld1.t_prod_line_dms_id
                         AND plop.product_line_option_id = plo1.id
                         AND tp.id = plop.peril_id
                         AND pld1.t_prod_line_dms_id = p_prod_line_dms_id
                       ORDER BY tp.description))
    LOOP
      IF (i.rownum = 1)
      THEN
        buf := buf || i.a;
      ELSE
        buf := buf || ', ' || i.a;
      END IF;
    END LOOP;
  
    RETURN buf;
  END;

  -- Возвращает код периодичности оплаты платежей
  -- Специфическая функция для Ренессанса
  FUNCTION get_period_code(period VARCHAR2) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    res := CASE
             WHEN period = 'Единовременно' THEN
              0
             WHEN period = 'Ежегодно' THEN
              1
             WHEN period = 'Ежемесячно' THEN
              12
             WHEN period = 'Каждые 6 месяцев' THEN
              2
             WHEN instr(period, 'Квартальная рассрочка') > 0 THEN
              4
             WHEN period = 'Поквартально' THEN
              4
             WHEN period = 'Ежеквартально' THEN
              4
             WHEN instr(period, 'Полугодовая рассрочка') > 0 THEN
              2
             WHEN period = 'Раз в полгода' THEN
              2
             ELSE
              NULL
           END;
    RETURN(res);
  END;

  -- Возвращает административные издержки по договору
  FUNCTION get_admin_expenses(pol_id NUMBER) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    SELECT pcov.premium
      INTO res
      FROM ven_as_asset ass
      JOIN ven_p_cover pcov
        ON pcov.as_asset_id = ass.as_asset_id
      JOIN ven_t_prod_line_option tprlnop
        ON tprlnop.id = pcov.t_prod_line_option_id
      JOIN ven_t_product_line tprln
        ON tprln.id = tprlnop.product_line_id
     WHERE tprln.brief = 'ADMIN_EXPENCES'
       AND ass.p_policy_id = pol_id;
    RETURN(res);
  END;

  -- Функция вовращает перечень программ по договору (через запятую в виде строки)
  FUNCTION get_programm_list(pol_id NUMBER) RETURN VARCHAR2 IS
    res VARCHAR2(1000) := '';
  BEGIN
    FOR pr_rec IN (SELECT tprln.description
                     FROM ven_as_asset ass
                     JOIN ven_p_cover pcov
                       ON pcov.as_asset_id = ass.as_asset_id
                     JOIN ven_t_prod_line_option tprlnop
                       ON tprlnop.id = pcov.t_prod_line_option_id
                     JOIN ven_t_product_line tprln
                       ON tprln.id = tprlnop.product_line_id
                    WHERE ass.p_policy_id = pol_id)
    LOOP
      res := res || pr_rec.description || '; ';
    END LOOP;
    res := rtrim(TRIM(res), ';');
    RETURN(res);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает дату ближайшего платежа
  FUNCTION get_min_date(pol_id NUMBER) RETURN DATE IS
    res DATE;
  BEGIN
    SELECT MIN(shed.due_date)
      INTO res
      FROM v_policy_payment_schedule shed
     WHERE shed.policy_id = pol_id
       AND shed.due_date > SYSDATE;
    RETURN(to_date(to_char(res, 'dd.mm.yyyy'), 'dd.mm.yyyy'));
  END;

  -- Возвращает сумму премии для платежа по дате
  FUNCTION get_amount_for_date
  (
    pol_id NUMBER
   ,fdate  DATE
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    SELECT MIN(shed.part_amount)
      INTO res
      FROM v_policy_payment_schedule shed
     WHERE shed.policy_id = pol_id
       AND shed.due_date = fdate;
    RETURN(res);
  END;

  -- Возвращает код типа агента
  FUNCTION get_type_agent_code(p_agch_id NUMBER) RETURN NUMBER IS
    cat  VARCHAR2(100); -- категория
    ch   VARCHAR2(100); -- канал продаж
    code NUMBER;
  BEGIN
    SELECT sch.brief
          ,agcat.brief
      INTO ch
          ,cat
      FROM ven_ag_contract_header agch
      JOIN ven_t_sales_channel sch
        ON sch.id = agch.t_sales_channel_id
      JOIN ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN ag_category_agent agcat
        ON agcat.ag_category_agent_id = agc.category_id
     WHERE agch.ag_contract_header_id = p_agch_id;
  
    IF (ch = 'MLM' AND cat = 'AG')
    THEN
      code := 0; -- агент
    ELSE
      IF (ch = 'CC')
      THEN
        code := 1; -- сотрудник компании
      ELSE
        IF (ch != 'MLM' AND ch != 'CC')
        THEN
          code := 2; -- внешний агент
        ELSE
          IF (ch = 'MLM' AND cat = 'MN')
          THEN
            code := 3; --менеджер
          ELSE
            code := 4; -- прочее
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN(code);
  END;

  -- Возвращает тип агента
  FUNCTION get_type_agent_name(p_agch_id NUMBER) RETURN VARCHAR2 IS
    code NUMBER;
    NAME VARCHAR(100);
  BEGIN
    code := get_type_agent_code(p_agch_id);
  
    IF (code = 0)
    THEN
      NAME := 'Агент'; -- агент
    ELSE
      IF (code = 1)
      THEN
        NAME := 'Сотрудник Call-центра'; -- сотрудник компании
      ELSE
        IF (code = 2)
        THEN
          NAME := 'Внешний агент'; -- внешний агент
        ELSE
          IF (code = 3)
          THEN
            NAME := 'Менеджер'; --менеджер
          ELSE
            NAME := NULL; -- прочее
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN(NAME);
  END;

  -- Возвращает признак, есть ли мед экспертиза среди ущербов по делу
  FUNCTION get_med_expert(p_claim_id NUMBER) RETURN VARCHAR2 IS
    str VARCHAR2(5);
  BEGIN
    str := 'НЕТ';
    FOR rec_dam IN (SELECT dc.brief
                      FROM ven_c_damage      d
                          ,ven_t_damage_code dc
                     WHERE d.c_claim_id = p_claim_id
                       AND d.t_damage_code_id = dc.id)
    LOOP
      IF rec_dam.brief = 'MEDEXP'
      THEN
        str := 'ДА';
      END IF;
    END LOOP;
    RETURN(str);
  END;

  -- Возвращает дату запроса документа СБ по делу
  FUNCTION get_claim_sb_request_date(p_claim_hed_id NUMBER) RETURN DATE IS
    d DATE;
  BEGIN
    SELECT cd.request_date
      INTO d
      FROM ven_c_claim_issuer_doc cd
      JOIN ven_t_issuer_doc_type dt
        ON dt.t_issuer_doc_type_id = cd.t_issuer_doc_type_id
     WHERE cd.c_claim_header_id = p_claim_hed_id
       AND dt.brief = 'SB';
    RETURN(d);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает дату запроса документа СБ по делу
  FUNCTION get_claim_sb_receipt_date(p_claim_hed_id NUMBER) RETURN DATE IS
    d DATE;
  BEGIN
    SELECT cd.receipt_date
      INTO d
      FROM ven_c_claim_issuer_doc cd
      JOIN ven_t_issuer_doc_type dt
        ON dt.t_issuer_doc_type_id = cd.t_issuer_doc_type_id
     WHERE cd.c_claim_header_id = p_claim_hed_id
       AND dt.brief = 'SB';
    RETURN(d);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возврашает телефон подразделения
  FUNCTION get_department_phone(p_dep_id NUMBER) RETURN VARCHAR2 IS
    tel VARCHAR2(30);
  BEGIN
    SELECT pkg_contact.get_primary_tel(ot.company_id)
      INTO tel
      FROM department dep
      JOIN organisation_tree ot
        ON ot.organisation_tree_id = dep.org_tree_id
     WHERE dep.department_id = p_dep_id;
    RETURN(tel);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает дату выплаты при расторжении договора
  FUNCTION get_decl_pay_date(p_pol_header_id NUMBER) RETURN DATE IS
    d DATE;
  BEGIN
    SELECT MAX(dof.set_off_date)
      INTO d
      FROM ven_p_pol_header ph
      JOIN ven_p_policy pp
        ON ph.policy_id = pp.policy_id
      JOIN v_policy_payment_schedule sch
        ON sch.policy_id = pp.policy_id
      JOIN ven_ac_payment ap
        ON ap.payment_id = sch.document_id
      JOIN ven_doc_set_off dof
        ON dof.parent_doc_id = ap.payment_id
      JOIN ven_ac_payment_templ apt
        ON apt.payment_templ_id = ap.payment_templ_id
     WHERE apt.brief = 'PAYORDBACK'
       AND ph.policy_header_id = p_pol_header_id;
    RETURN d;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает дату первого заявления по договору
  FUNCTION get_notice_date(p_pol_header_id NUMBER) RETURN DATE IS
    d DATE;
  BEGIN
    SELECT pp.notice_date
      INTO d
      FROM ven_p_pol_header ph
      JOIN ven_p_policy pp
        ON pp.pol_header_id = ph.policy_header_id
     WHERE ph.policy_header_id = p_pol_header_id
       AND pp.version_num = 1;
    RETURN(d);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Для отчета ОС.Просроченные платежи
  FUNCTION a7pd4_copy_set_off_sum(p_ac_payment_id NUMBER) RETURN NUMBER AS
    v_sum NUMBER;
  BEGIN
    SELECT nvl(SUM(ds.set_off_amount), 0)
      INTO v_sum
      FROM doc_set_off ds
     WHERE ds.parent_doc_id = p_ac_payment_id
       AND ds.cancel_date IS NULL;
    RETURN v_sum;
  END;

  --Для отчёта Договора страхования имущества
  FUNCTION get_assured_order_number
  (
    p_p_asset_header_id NUMBER
   ,p_p_policy_id       NUMBER
  ) RETURN NUMBER IS
    v_ord NUMBER;
  BEGIN
    SELECT v.rn
      INTO v_ord
      FROM (SELECT row_number() over(ORDER BY ah.p_asset_header_id) rn
                  ,ah.p_asset_header_id
              FROM as_asset ass
              JOIN status_hist sh
                ON sh.status_hist_id = ass.status_hist_id
               AND sh.brief NOT IN ('DELETED')
              JOIN p_asset_header ah
                ON ah.p_asset_header_id = ass.p_asset_header_id
             WHERE 1 = 1
               AND ass.p_policy_id = p_p_policy_id) v
     WHERE v.p_asset_header_id = p_p_asset_header_id;
    RETURN v_ord;
  END;

  --Для отчёта Договора страхования имущества
  FUNCTION get_assured_count(p_p_policy_id NUMBER) RETURN NUMBER IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_cnt
      FROM as_asset ass
      JOIN status_hist sh
        ON sh.status_hist_id = ass.status_hist_id
       AND sh.brief NOT IN ('DELETED')
     WHERE 1 = 1
       AND ass.p_policy_id = p_p_policy_id;
    RETURN v_cnt;
  END;

  --Для отчёта Договора страхования имущества
  FUNCTION get_cvrs_of_pol(p_p_policy_id NUMBER) RETURN tb_cvr
    PIPELINED IS
    v_lst      tb_cvr := tb_cvr();
    cnt_of_res NUMBER;
  
    --возвращает список застрахованных объектов
    FUNCTION get_list_of_assured_by_cover(p_cover_name VARCHAR2) RETURN VARCHAR2 IS
      v_tmp VARCHAR2(1000);
    BEGIN
      FOR i IN (SELECT get_assured_order_number(ap.p_asset_header_id, ap.p_policy_id) rn
                  FROM ven_as_property ap
                  JOIN status_hist sh
                    ON sh.status_hist_id = ap.status_hist_id
                   AND sh.brief NOT IN ('DELETED')
                  JOIN p_cover pc
                    ON pc.as_asset_id = ap.as_property_id
                  JOIN t_prod_line_option plo
                    ON plo.id = pc.t_prod_line_option_id
                 WHERE 1 = 1
                   AND ap.p_policy_id = p_p_policy_id
                   AND ((p_cover_name = 'Пожара' AND plo.brief IN ('FLEXA', 'FIRE')) OR
                       (p_cover_name = 'Удара молнии, взрыва' AND
                       plo.brief IN ('FLEXA', 'THUNDERBOLT', 'GAS', 'DETONATION')) OR
                       (p_cover_name =
                       'Падения пилотируемого летательного аппарата или столкновения с ним, а также падения его частей или груза' AND
                       plo.brief IN ('FLEXA', 'PILOT')) OR
                       (p_cover_name = 'Бури, града' AND plo.brief IN ('NATURAL')) OR
                       (p_cover_name =
                       'Наводнения, землетрясения, вулканического извержения, просадки грунта, оползня, обвала, снежной лавины' AND
                       plo.brief IN ('NATURAL')) OR (p_cover_name =
                       'Аварии водопроводных, отопительных, противопожарных и канализационных систем, проникновения воды из соседних (чужих) помещений' AND
                       plo.brief IN ('WATER')) OR
                       (p_cover_name = 'Кражи со взломом, грабежа или разбоя' AND
                       plo.brief IN ('ILLEGAL')) OR (p_cover_name =
                       'Преднамеренных действий третьих лиц, направленных на повреждение застрахованного имущества' AND
                       plo.brief IN ('ILLEGAL')) OR
                       (p_cover_name = 'Боя стекол,витрин и зеркал' AND plo.brief IN ('GLASS')) OR
                       (p_cover_name = 'Внутреннего возгорания' AND plo.brief IN ('FIREIN')) OR
                       (p_cover_name = 'Непредвиденного отключения источников питания' AND
                       plo.brief IN ('POWEROFF')) OR
                       (p_cover_name = 'Взрывы различных устройств' AND plo.brief IN ('DETONATION')))
                 GROUP BY ap.p_asset_header_id
                         ,ap.p_policy_id
                 ORDER BY get_assured_order_number(ap.p_asset_header_id, ap.p_policy_id))
      LOOP
        IF v_tmp IS NULL
        THEN
          v_tmp := ' в п.1.1.' || i.rn;
        ELSE
          v_tmp := v_tmp || ', в п.1.1.' || i.rn;
        END IF;
      END LOOP;
    
      RETURN v_tmp;
    END;
  
    ------------------------
    FUNCTION get_count_of_assured_by_cover(p_cover_name VARCHAR2) RETURN NUMBER IS
      v_cnt NUMBER;
    BEGIN
      SELECT COUNT(DISTINCT ap.p_asset_header_id)
        INTO v_cnt
        FROM ven_as_property ap
        JOIN status_hist sh
          ON sh.status_hist_id = ap.status_hist_id
         AND sh.brief NOT IN ('DELETED')
        JOIN p_cover pc
          ON pc.as_asset_id = ap.as_property_id
        JOIN t_prod_line_option plo
          ON plo.id = pc.t_prod_line_option_id
       WHERE 1 = 1
         AND ap.p_policy_id = p_p_policy_id
         AND ((p_cover_name = 'Пожара' AND plo.brief IN ('FLEXA', 'FIRE')) OR
             (p_cover_name = 'Удара молнии, взрыва' AND
             plo.brief IN ('FLEXA', 'THUNDERBOLT', 'GAS', 'DETONATION')) OR
             (p_cover_name =
             'Падения пилотируемого летательного аппарата или столкновения с ним, а также падения его частей или груза' AND
             plo.brief IN ('FLEXA', 'PILOT')) OR
             (p_cover_name = 'Бури, града' AND plo.brief IN ('NATURAL')) OR (p_cover_name =
             'Наводнения, землетрясения, вулканического извержения, просадки грунта, оползня, обвала, снежной лавины' AND
             plo.brief IN ('NATURAL')) OR (p_cover_name =
             'Аварии водопроводных, отопительных, противопожарных и канализационных систем, проникновения воды из соседних (чужих) помещений' AND
             plo.brief IN ('WATER')) OR
             (p_cover_name = 'Кражи со взломом, грабежа или разбоя' AND plo.brief IN ('ILLEGAL')) OR
             (p_cover_name =
             'Преднамеренных действий третьих лиц, направленных на повреждение застрахованного имущества' AND
             plo.brief IN ('ILLEGAL')) OR
             (p_cover_name = 'Боя стекол,витрин и зеркал' AND plo.brief IN ('GLASS')) OR
             (p_cover_name = 'Внутреннего возгорания' AND plo.brief IN ('FIREIN')) OR
             (p_cover_name = 'Непредвиденного отключения источников питания' AND
             plo.brief IN ('POWEROFF')) OR
             (p_cover_name = 'Взрывы различных устройств' AND plo.brief IN ('DETONATION')));
    
      RETURN v_cnt;
    END;
  
  BEGIN
    v_lst.extend;
    v_lst(1) := 'Пожара';
    v_lst.extend;
    v_lst(2) := 'Удара молнии, взрыва';
    v_lst.extend;
    v_lst(3) := 'Падения пилотируемого летательного аппарата или столкновения с ним, а также падения его частей или груза';
    v_lst.extend;
    v_lst(4) := 'Бури, града';
    v_lst.extend;
    v_lst(5) := 'Наводнения, землетрясения, вулканического извержения, просадки грунта, оползня, обвала, снежной лавины';
    v_lst.extend;
    v_lst(6) := 'Аварии водопроводных, отопительных, противопожарных и канализационных систем, проникновения воды из соседних (чужих) помещений';
    v_lst.extend;
    v_lst(7) := 'Кражи со взломом, грабежа или разбоя';
    v_lst.extend;
    v_lst(8) := 'Преднамеренных действий третьих лиц, направленных на повреждение застрахованного имущества';
    v_lst.extend;
    v_lst(9) := 'Боя стекол,витрин и зеркал';
    v_lst.extend;
    v_lst(10) := 'Внутреннего возгорания';
    v_lst.extend;
    v_lst(11) := 'Непредвиденного отключения источников питания';
    v_lst.extend;
    v_lst(12) := 'Взрывы различных устройств';
  
    cnt_of_res := 1;
    FOR i IN v_lst.first .. v_lst.last
    LOOP
      CASE get_count_of_assured_by_cover(v_lst(i))
        WHEN 0 THEN
          NULL;
        WHEN get_assured_count(p_p_policy_id) THEN
          PIPE ROW(cnt_of_res || '. ' || v_lst(i));
          cnt_of_res := cnt_of_res + 1;
        ELSE
          PIPE ROW(cnt_of_res || '. ' || v_lst(i) ||
                   ' (действия данного пункта распространяются только на Имущество, указанное' ||
                   get_list_of_assured_by_cover(v_lst(i)) || ')');
          cnt_of_res := cnt_of_res + 1;
      END CASE;
    END LOOP;
    RETURN;
  END;

  -- возвращает самую раннюю из дат начала действия услуг
  FUNCTION get_minim_date
  (
    p_contract_lpu_ver_id NUMBER
   ,p_contact_id          NUMBER
  ) RETURN DATE IS
    res DATE;
  BEGIN
  
    SELECT *
      INTO res
      FROM (SELECT start_date
              FROM ven_dms_price vdp1
             WHERE vdp1.contract_lpu_ver_id = p_contract_lpu_ver_id
               AND vdp1.executor_id = p_contact_id
             ORDER BY vdp1.start_date)
     WHERE rownum < 2;
    RETURN(res);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  /*Каткевич А.Г. 16/09/2008 Функцию перенес из PKG_DISCOVERER
  --Добавил autonomus transation*/

  FUNCTION get_pivot_bso_table
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_session_id NUMBER
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    TYPE t_bso_in_out IS RECORD(
       n              NUMBER(10)
      ,nn             NUMBER(6)
      ,bso_type       VARCHAR2(150)
      ,in_quantity    NUMBER(6)
      ,in_num_start   VARCHAR2(150)
      ,in_num_end     VARCHAR2(150)
      ,in_reg_date    DATE
      ,out_quantity   NUMBER(6)
      ,out_num_start  VARCHAR2(150)
      ,out_num_end    VARCHAR2(150)
      ,out_reg_date   DATE
      ,out_bso_status VARCHAR2(150)
      ,rest_begin     NUMBER(8)
      ,rest_end       NUMBER(8)
      ,rest_change    NUMBER(8)
      ,session_id     NUMBER
      ,gen_date       DATE);
    l_rec         t_bso_in_out;
    l_rec_tot_tmp t_bso_in_out;
    CURSOR l_cur
    (
      v_start_date DATE
     ,v_end_date   DATE
    ) IS
      SELECT DISTINCT t.quantity_in
                     ,t.num_start_in
                     ,t.num_end_in
                     ,t.reg_date_in
                     ,t.quantity_out
                     ,t.num_start_out
                     ,t.num_end_out
                     ,t.reg_date_out
                     ,t.bso_status
                     ,t.tot_cnt_in
                     ,t.tot_cnt_out
                     ,t.bso_type_id
                     ,v.name
                     ,MAX(nvl(tot_cnt_out, 0) - nvl(tot_cnt_in, 0)) over(PARTITION BY t.bso_type_id) AS sgn
        FROM (SELECT rownum
                    ,t1.quantity quantity_in
                    ,t1.num_start num_start_in
                    ,t1.num_end num_end_in
                    ,t1.reg_date reg_date_in
                    ,t2.quantity quantity_out
                    ,t2.num_start num_start_out
                    ,t2.num_end num_end_out
                    ,t2.reg_date reg_date_out
                    ,t2.bso_status
                    ,t1.tot_cnt tot_cnt_in
                    ,t2.tot_cnt tot_cnt_out
                    ,nvl(t1.bso_type_id, t2.bso_type_id) bso_type_id
                FROM (SELECT rownum AS nn
                            ,bd.reg_date AS reg_date
                            ,bdc.num_start AS num_start
                            ,nvl(bdc.num_end, bdc.num_start) AS num_end
                            ,decode(bdc.num_end
                                   ,NULL
                                   ,1
                                   ,to_number(bdc.num_end) - to_number(bdc.num_start) + 1) AS quantity
                            ,COUNT(*) over(PARTITION BY bt.bso_type_id) AS tot_cnt
                            ,bt.bso_type_id AS bso_type_id
                        FROM ven_bso_document  bd
                            ,ven_doc_templ     dt
                            ,ven_bso_doc_cont  bdc
                            ,ven_bso_type      bt
                            ,ven_bso_series    bs
                            ,ven_bso_hist_type bht
                       WHERE bs.bso_type_id = bt.bso_type_id
                         AND bdc.bso_series_id = bs.bso_series_id
                         AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                         AND bdc.bso_document_id = bd.bso_document_id
                         AND dt.doc_templ_id = bd.doc_templ_id
                         AND dt.brief = 'НакладнаяБСО'
                         AND bd.reg_date BETWEEN v_start_date AND v_end_date) t1
                    ,(SELECT rownum AS nn
                            ,quantity
                            ,num_start
                            ,num_end
                            ,reg_date
                            ,bso_status
                            ,COUNT(*) over(PARTITION BY bso_type_id) AS tot_cnt
                            ,bso_type_id
                        FROM (SELECT COUNT(*) AS quantity
                                    ,MIN(a) AS num_start
                                    ,MAX(a) AS num_end
                                    ,MIN(hist_date) AS reg_date
                                    ,MIN(status) AS bso_status
                                    ,MIN(bso_type_id) AS bso_type_id
                                FROM (SELECT b.num AS a
                                            ,trunc(his.hist_date) AS hist_date
                                            ,ht.name AS status
                                            ,bs.bso_type_id AS bso_type_id
                                        FROM bso_hist      his
                                            ,bso           b
                                            ,bso_hist_type ht
                                            ,bso_series    bs
                                       WHERE his.bso_id = b.bso_id
                                         AND bs.bso_series_id = b.bso_series_id
                                         AND ht.bso_hist_type_id = his.hist_type_id
                                         AND his.num =
                                             (SELECT MAX(his2.num)
                                                FROM bso_hist      his2
                                                    ,bso_hist_type ht2
                                               WHERE his2.hist_date BETWEEN v_start_date AND v_end_date
                                                 AND his2.bso_id = his.bso_id
                                                 AND his2.hist_type_id = ht2.bso_hist_type_id
                                                 AND ht2.brief IN ('Использован'
                                                                  ,'Испорчен'
                                                                  ,'Утерян'
                                                                  ,'Устарел'
                                                                  ,'Списан'))
                                       ORDER BY trunc(his.hist_date)
                                               ,ht.brief
                                               ,to_number(b.num))
                               GROUP BY (to_number(a) - rownum)
                               ORDER BY reg_date
                                       ,bso_status
                                       ,num_start)) t2
               WHERE t1.nn(+) = t2.nn
                 AND t1.bso_type_id(+) = t2.bso_type_id
              UNION ALL
              SELECT rownum
                    ,t1.quantity quantity_in
                    ,t1.num_start num_start_in
                    ,t1.num_end num_end_in
                    ,t1.reg_date reg_date_in
                    ,t2.quantity quantity_out
                    ,t2.num_start num_start_out
                    ,t2.num_end num_end_out
                    ,t2.reg_date reg_date_out
                    ,t2.bso_status
                    ,t1.tot_cnt tot_cnt_in
                    ,t2.tot_cnt tot_cnt_out
                    ,nvl(t1.bso_type_id, t2.bso_type_id) bso_type_id
                FROM (SELECT rownum AS nn
                            ,bd.reg_date AS reg_date
                            ,bdc.num_start AS num_start
                            ,nvl(bdc.num_end, bdc.num_start) AS num_end
                            ,decode(bdc.num_end
                                   ,NULL
                                   ,1
                                   ,to_number(bdc.num_end) - to_number(bdc.num_start) + 1) AS quantity
                            ,COUNT(*) over(PARTITION BY bt.bso_type_id) AS tot_cnt
                            ,bt.bso_type_id AS bso_type_id
                        FROM ven_bso_document  bd
                            ,ven_doc_templ     dt
                            ,ven_bso_doc_cont  bdc
                            ,ven_bso_type      bt
                            ,ven_bso_series    bs
                            ,ven_bso_hist_type bht
                       WHERE bs.bso_type_id = bt.bso_type_id
                         AND bdc.bso_series_id = bs.bso_series_id
                         AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                         AND bdc.bso_document_id = bd.bso_document_id
                         AND dt.doc_templ_id = bd.doc_templ_id
                         AND dt.brief = 'НакладнаяБСО'
                         AND bd.reg_date BETWEEN v_start_date AND v_end_date) t1
                    ,(SELECT rownum AS nn
                            ,quantity
                            ,num_start
                            ,num_end
                            ,reg_date
                            ,bso_status
                            ,COUNT(*) over(PARTITION BY bso_type_id) AS tot_cnt
                            ,bso_type_id
                        FROM (SELECT COUNT(*) AS quantity
                                    ,MIN(a) AS num_start
                                    ,MAX(a) AS num_end
                                    ,MIN(hist_date) AS reg_date
                                    ,MIN(status) AS bso_status
                                    ,MIN(bso_type_id) AS bso_type_id
                                FROM (SELECT b.num AS a
                                            ,trunc(his.hist_date) AS hist_date
                                            ,ht.name AS status
                                            ,bs.bso_type_id AS bso_type_id
                                        FROM bso_hist      his
                                            ,bso           b
                                            ,bso_hist_type ht
                                            ,bso_series    bs
                                       WHERE his.bso_id = b.bso_id
                                         AND bs.bso_series_id = b.bso_series_id
                                         AND ht.bso_hist_type_id = his.hist_type_id
                                         AND his.num =
                                             (SELECT MAX(his2.num)
                                                FROM bso_hist      his2
                                                    ,bso_hist_type ht2
                                               WHERE his2.hist_date BETWEEN v_start_date AND v_end_date
                                                 AND his2.bso_id = his.bso_id
                                                 AND his2.hist_type_id = ht2.bso_hist_type_id
                                                 AND ht2.brief IN ('Использован'
                                                                  ,'Испорчен'
                                                                  ,'Утерян'
                                                                  ,'Устарел'
                                                                  ,'Списан'))
                                       ORDER BY trunc(his.hist_date)
                                               ,ht.brief
                                               ,to_number(b.num))
                               GROUP BY (to_number(a) - rownum)
                               ORDER BY reg_date
                                       ,bso_status
                                       ,num_start)) t2
               WHERE t1.nn = t2.nn(+)
                 AND t1.bso_type_id = t2.bso_type_id(+)) t
            ,ven_bso_type v
       WHERE t.bso_type_id = v.bso_type_id
       ORDER BY v.name
               ,nvl2(t.reg_date_in, 2, decode(sign(sgn), -1, 1, 0)) +
                nvl2(t.reg_date_out, 2, decode(sign(sgn), 1, 1, 0)) DESC
               ,t.reg_date_out
               ,t.reg_date_in
               ,t.num_start_out
               ,t.num_start_in;
  
    l_quantity_in  NUMBER(8);
    l_quantity_out NUMBER(8);
    l_tmp_n        NUMBER(8);
    l_tmp_nn       NUMBER(8);
    l_tmp_num      NUMBER(8);
    l_tmp_in       NUMBER(8);
    l_tmp_out      NUMBER(8);
    l_tmp_id       NUMBER(8);
    l_pred_id      NUMBER(8);
    l_tmp_name     VARCHAR2(150);
    l_pred_name    VARCHAR2(150);
    l_tmp_sgn      NUMBER(8);
  
    /* счетчики финального ИТОГО */
    l_fin_rb NUMBER(8);
    l_fin_iq NUMBER(8);
    l_fin_oq NUMBER(8);
    l_fin_re NUMBER(8);
    l_fin_rc NUMBER(8);
  
  BEGIN
    /* Чистим "временную" таблицу, удаляя данные текущей сессии и
    данные суточной давности*/
    DELETE FROM ins_dwh.bso_pivot_table_tmp b
     WHERE (SYSDATE - b.gen_date) > 1
        OR b.session_id = p_session_id;
    /* Инициализация счетчиков */
    l_tmp_n                  := 0;
    l_tmp_nn                 := 1; -- первый стартовый номер в группе
    l_fin_rb                 := 0;
    l_fin_iq                 := 0;
    l_fin_oq                 := 0;
    l_fin_re                 := 0;
    l_fin_rc                 := 0;
    l_rec.session_id         := p_session_id;
    l_rec.gen_date           := SYSDATE;
    l_rec_tot_tmp.session_id := p_session_id;
    l_rec_tot_tmp.gen_date   := SYSDATE;
    l_pred_id                := 0; -- несуществующий тип бланка на входе в цикл
  
    OPEN l_cur(p_start_date, p_end_date);
    LOOP
    
      /* Остатки */
      l_rec.rest_begin  := NULL;
      l_rec.rest_end    := NULL;
      l_rec.rest_change := NULL;
      l_tmp_n           := l_tmp_n + 1;
    
      FETCH l_cur
        INTO --l_rec.NN,
             l_rec.in_quantity
            ,l_rec.in_num_start
            ,l_rec.in_num_end
            ,l_rec.in_reg_date
            ,l_rec.out_quantity
            ,l_rec.out_num_start
            ,l_rec.out_num_end
            ,l_rec.out_reg_date
            ,l_rec.out_bso_status
            ,l_tmp_in
            ,l_tmp_out
            ,l_tmp_id
            ,l_tmp_name
            ,l_tmp_sgn;
    
      EXIT WHEN l_cur%NOTFOUND;
    
      l_rec.bso_type := NULL; /* Чтобы вид бланка выводился только на первой строке */
      IF l_tmp_id <> l_pred_id
      THEN
        IF l_pred_id > 0
        THEN
          /* меняется вид бланка - выводим промежуточный итог */
          -- Подсчет промежуточных итогов
          l_rec_tot_tmp.n              := l_tmp_n;
          l_tmp_n                      := l_tmp_n + 1;
          l_tmp_nn                     := l_tmp_nn + 1;
          l_rec_tot_tmp.nn             := l_tmp_nn;
          l_rec_tot_tmp.bso_type       := 'ИТОГО по ' || l_pred_name;
          l_rec_tot_tmp.rest_begin     := get_bso_rest_on_date(p_start_date, l_pred_id);
          l_rec_tot_tmp.in_quantity    := l_quantity_in;
          l_rec_tot_tmp.in_num_start   := NULL;
          l_rec_tot_tmp.in_num_end     := NULL;
          l_rec_tot_tmp.in_reg_date    := NULL;
          l_rec_tot_tmp.out_quantity   := l_quantity_out;
          l_rec_tot_tmp.out_num_start  := NULL;
          l_rec_tot_tmp.out_num_end    := NULL;
          l_rec_tot_tmp.out_reg_date   := NULL;
          l_rec_tot_tmp.rest_end       := nvl(l_rec_tot_tmp.rest_begin, 0) + l_quantity_in -
                                          l_quantity_out;
          l_rec_tot_tmp.out_bso_status := NULL;
          l_rec_tot_tmp.rest_change    := nvl(l_rec_tot_tmp.rest_end, 0) -
                                          nvl(l_rec_tot_tmp.rest_begin, 0);
        
          INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec_tot_tmp;
        
          IF (l_quantity_in + l_quantity_out) > 0
          THEN
            l_fin_rb := l_fin_rb + nvl(l_rec_tot_tmp.rest_begin, 0);
            l_fin_iq := l_fin_iq + nvl(l_rec_tot_tmp.in_quantity, 0);
            l_fin_oq := l_fin_oq + nvl(l_rec_tot_tmp.out_quantity, 0);
            l_fin_re := l_fin_re + nvl(l_rec_tot_tmp.rest_end, 0);
            l_fin_rc := l_fin_rc + nvl(l_rec_tot_tmp.rest_change, 0);
          END IF;
        END IF;
        l_rec.bso_type := l_tmp_name;
        l_quantity_in  := nvl(l_tmp_in, 0);
        l_quantity_out := nvl(l_tmp_out, 0);
        l_tmp_nn       := 1;
        l_pred_name    := l_tmp_name;
      ELSE
        l_tmp_nn := l_tmp_nn + 1;
      END IF;
      l_pred_id := l_tmp_id;
      l_rec.nn  := l_tmp_nn;
    
      l_rec.n := l_tmp_n; /*Глобальный счетчик по всем записям отчета*/
    
      -- INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
    
      l_quantity_in  := l_quantity_in + nvl(l_rec.in_quantity, 0); /* Итого кол-во по видам бланка*/
      l_quantity_out := l_quantity_out + nvl(l_rec.out_quantity, 0);
    
    END LOOP; -- Конец цикла по BSO_TYPE  (видам бланков)
    CLOSE l_cur;
    --последний промежуточный итог
    IF l_pred_id > 0
    THEN
      l_rec_tot_tmp.n              := l_tmp_n;
      l_tmp_n                      := l_tmp_n + 1;
      l_rec_tot_tmp.nn             := l_tmp_nn + 1;
      l_rec_tot_tmp.bso_type       := 'ИТОГО по ' || l_pred_name;
      l_rec_tot_tmp.rest_begin     := get_bso_rest_on_date(p_start_date, l_pred_id);
      l_rec_tot_tmp.in_quantity    := l_quantity_in;
      l_rec_tot_tmp.in_num_start   := NULL;
      l_rec_tot_tmp.in_num_end     := NULL;
      l_rec_tot_tmp.in_reg_date    := NULL;
      l_rec_tot_tmp.out_quantity   := l_quantity_out;
      l_rec_tot_tmp.out_num_start  := NULL;
      l_rec_tot_tmp.out_num_end    := NULL;
      l_rec_tot_tmp.out_reg_date   := NULL;
      l_rec_tot_tmp.rest_end       := nvl(l_rec_tot_tmp.rest_begin, 0) + l_quantity_in -
                                      l_quantity_out;
      l_rec_tot_tmp.out_bso_status := NULL;
      l_rec_tot_tmp.rest_change    := nvl(l_rec_tot_tmp.rest_end, 0) -
                                      nvl(l_rec_tot_tmp.rest_begin, 0);
    
      INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec_tot_tmp;
    
      IF (l_quantity_in + l_quantity_out) > 0
      THEN
        l_fin_rb := l_fin_rb + nvl(l_rec_tot_tmp.rest_begin, 0);
        l_fin_iq := l_fin_iq + nvl(l_rec_tot_tmp.in_quantity, 0);
        l_fin_oq := l_fin_oq + nvl(l_rec_tot_tmp.out_quantity, 0);
        l_fin_re := l_fin_re + nvl(l_rec_tot_tmp.rest_end, 0);
        l_fin_rc := l_fin_rc + nvl(l_rec_tot_tmp.rest_change, 0);
      END IF;
    END IF;
  
    -- Подсчет финального итога
    l_rec.n            := l_tmp_n;
    l_rec.nn           := NULL;
    l_rec.bso_type     := 'ИТОГО все бланки';
    l_rec.rest_begin   := l_fin_rb;
    l_rec.in_quantity  := l_fin_iq;
    l_rec.out_quantity := l_fin_oq;
    l_rec.rest_end     := l_fin_re;
    l_rec.rest_change  := l_fin_rc;
  
    l_rec.in_num_start   := NULL;
    l_rec.in_num_end     := NULL;
    l_rec.in_reg_date    := NULL;
    l_rec.out_num_start  := NULL;
    l_rec.out_num_end    := NULL;
    l_rec.out_reg_date   := NULL;
    l_rec.out_bso_status := NULL;
  
    INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
    COMMIT;
    RETURN 1;
  END;

  FUNCTION get_bso_rest_on_date
  (
    p_date        DATE
   ,p_bso_type_id NUMBER
  ) RETURN NUMBER IS
    buf NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO buf
      FROM bso_hist      his
          ,bso           b
          ,bso_hist_type ht
          ,bso_series    bs
     WHERE his.bso_id = b.bso_id
       AND bs.bso_series_id = b.bso_series_id
       AND bs.bso_type_id = p_bso_type_id
       AND ht.bso_hist_type_id = his.hist_type_id
       AND his.num =
           (SELECT MAX(his2.num)
              FROM bso_hist      his2
                  ,bso_hist_type ht2
             WHERE his2.hist_date < p_date
               AND his2.bso_id = his.bso_id
               AND his2.hist_type_id = ht2.bso_hist_type_id
               AND ht2.brief IN ('НеВыдан', 'Выдан', 'Зарезервирован'));
    RETURN buf;
  END;

  FUNCTION get_agency_to_pd4(p_p_policy_id NUMBER) RETURN VARCHAR2 IS
    res VARCHAR2(500);
  BEGIN
    SELECT MAX(pkg_policy.get_pol_agency_name(pol_header_id))
      INTO res
      FROM ven_p_policy
     WHERE policy_id = p_p_policy_id;
    RETURN res;
  END;

  /*
    Байтин А.
    Процедура для выполнения отчета в AS, с последующей записью результата во временную таблицу
    Перед выполнением необходимо сделать ins.repcore.set_context для установки параметров отчета
    После выполнения, соответственно repcore.clear_context.
  */
  PROCEDURE exec_webreport
  (
    par_rep_url      rep_type.url_name%TYPE
   ,par_rep_params   rep_report.parameters%TYPE
   ,par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_report       OUT BLOB
  ) IS
    v_rep_url  rep_type.url_name%TYPE;
    v_login    VARCHAR2(255);
    v_password VARCHAR2(255);
  
    v_req            utl_http.req;
    v_resp           utl_http.resp;
    v_session_id     VARCHAR2(2000);
    v_rep_location   VARCHAR2(2000);
    v_post           VARCHAR2(2000);
    v_answer         RAW(32767);
    v_content_dispos VARCHAR2(400);
  BEGIN
    IF par_rep_url IS NULL
    THEN
      raise_application_error(-20001
                             ,'Ссылка на отчет должна быть указана');
    END IF;
    -- Логин
    v_login := pkg_app_param.get_app_param_c('REPORTS_LOGIN');
  
    IF v_login IS NULL
    THEN
      raise_application_error(-20001
                             ,'Логин пользователя отчетов должен быть указан');
    END IF;
    -- Пароль
    BEGIN
      SELECT a1 INTO v_password FROM auto_reports.dummy;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Пароль для отчетов не найден');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько паролей для отчетов');
    END;
    IF v_password IS NULL
    THEN
      raise_application_error(-20001
                             ,'Пароль пользователя отчетов должен быть указан');
    END IF;
    -- формирование параметров
    v_rep_url := par_rep_url || ins.repcore.prepare_paremeters(par_rep_params);
    -- Установки для пакета UTL_HTTP
    utl_http.set_follow_redirect(10);
    utl_http.set_detailed_excp_support(TRUE);
    utl_http.set_transfer_timeout(900);
  
    -- Переход по ссылке
    v_req := utl_http.begin_request(v_rep_url, 'GET', utl_http.http_version_1_1);
    utl_http.set_persistent_conn_support(v_req, TRUE);
    utl_http.set_cookie_support(v_req, TRUE);
    -- Получение ответа
    v_resp := utl_http.get_response(v_req);
    -- Получение типа данных
    utl_http.get_header_by_name(r => v_resp, NAME => 'Content-Type', VALUE => par_content_type);
  
    BEGIN
      utl_http.get_header_by_name(r     => v_resp
                                 ,NAME  => 'Content-Disposition'
                                 ,VALUE => v_content_dispos);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    dbms_lob.createtemporary(lob_loc => par_report, cache => TRUE);
  
    BEGIN
      -- Читаем все во временный буфер
      LOOP
        utl_http.read_raw(r => v_resp, data => v_answer);
        dbms_lob.writeappend(lob_loc => par_report
                            ,amount  => dbms_lob.getlength(v_answer)
                            ,buffer  => v_answer);
      END LOOP;
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        NULL;
    END;
    utl_http.end_response(v_resp);
    -- Если это HTML, смотрим, не авторизация ли это
    IF par_content_type LIKE 'text/html%'
    THEN
      -- Ищем token, если нашли - это страница авторизации
      DECLARE
        v_amount NUMBER := 32767;
      BEGIN
        dbms_lob.read(lob_loc => par_report, amount => v_amount, offset => 1, buffer => v_answer);
      END;
      -- Страница авторизации должна поместиться в 32767
      v_session_id := TRIM(both '"' FROM regexp_substr(regexp_substr(utl_raw.cast_to_varchar2(v_answer)
                                                      ,'<INPUT TYPE="hidden"[^>]+NAME=("site2pstoretoken")[^>]+>')
                                        ,'"v1\.4.+"'));
      -- Если нашли token
      IF v_session_id IS NOT NULL
      THEN
        -- Строка для авторизации
        v_post := 'site2pstoretoken=' || v_session_id || chr(38) || 'ssousername=' || v_login ||
                  chr(38) || 'password=' || v_password;
        -- Запрос по URL для авторизации
        v_req := utl_http.begin_request(pkg_app_param.get_app_param_c('AUTH_AS_URL')
                                       ,'POST'
                                       ,utl_http.http_version_1_1);
        utl_http.set_persistent_conn_support(v_req, TRUE);
        utl_http.set_header(v_req, 'Content-Type', 'application/x-www-form-urlencoded');
        utl_http.set_header(v_req, 'Content-Length', length(v_post));
        utl_http.write_line(v_req, v_post);
        -- В ответе должен быть URL для перехода к отчету
        v_resp := utl_http.get_response(v_req);
        BEGIN
          utl_http.get_header_by_name(r => v_resp, NAME => 'Location', VALUE => v_rep_location);
          utl_http.end_response(v_resp);
          v_req  := utl_http.begin_request(v_rep_location, 'GET', utl_http.http_version_1_1);
          v_resp := utl_http.get_response(v_req);
          -- Получение типа данных
          utl_http.get_header_by_name(r => v_resp, NAME => 'Content-Type', VALUE => par_content_type);
          BEGIN
            utl_http.get_header_by_name(r     => v_resp
                                       ,NAME  => 'Content-Disposition'
                                       ,VALUE => v_content_dispos);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          -- Удаляем то, что было получено ранее
          dbms_lob.trim(lob_loc => par_report, newlen => 0);
          BEGIN
            LOOP
              utl_http.read_raw(r => v_resp, data => v_answer);
              dbms_lob.writeappend(lob_loc => par_report
                                  ,amount  => dbms_lob.getlength(v_answer)
                                  ,buffer  => v_answer);
            END LOOP;
          EXCEPTION
            WHEN utl_http.end_of_body THEN
              NULL;
          END;
          utl_http.end_response(v_resp);
        EXCEPTION
          WHEN utl_http.header_not_found THEN
            utl_http.end_response(v_resp);
            raise_application_error(-20001
                                   ,'Не найдена ссылка для перехода к отчету после проведения авторизации.');
        END;
      END IF;
    END IF;
  
    IF par_content_type NOT LIKE 'text/html%'
    
    THEN
      IF v_content_dispos IS NOT NULL
      THEN
        par_file_name := ltrim(rtrim(v_content_dispos, 'attachment;filename="'), '"');
      ELSE
        par_file_name := 'print_document.pdf';
      END IF;
    END IF;
  
  END exec_webreport;

  PROCEDURE exec_procedure
  (
    par_procedure_name VARCHAR2
   ,par_content_type   OUT VARCHAR2
   ,par_file_name      OUT VARCHAR2
   ,par_report         OUT BLOB
  ) IS
    v_sql VARCHAR2(500);
  BEGIN
    v_sql := 'begin ' || par_procedure_name ||
             '(:par_content_type, :par_file_name, :par_report); end;';
    EXECUTE IMMEDIATE v_sql
      USING OUT par_content_type, OUT par_file_name, OUT par_report;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Не удалось сформировать запрос из процедуры ' || par_procedure_name || ': ' ||
                              SQLERRM);
  END exec_procedure;

  PROCEDURE exec_report
  (
    par_report_id NUMBER
   ,par_report    OUT t_report
  ) IS
  
  BEGIN
    exec_report(par_report_id    => par_report_id
               ,par_content_type => par_report.content_type
               ,par_file_name    => par_report.file_name
               ,par_pages_count  => par_report.pages_count
               ,par_report       => par_report.report_body);
  END exec_report;

  PROCEDURE exec_report
  (
    par_report_id    NUMBER
   ,par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_pages_count  OUT NUMBER
   ,par_report       OUT BLOB
  ) IS
    v_rep_url_or_procedure rep_type.url_name%TYPE;
    v_rep_params           rep_report.parameters%TYPE;
    v_rep_type             rep_type.name%TYPE;
  
    FUNCTION get_pages_count
    (
      par_report       BLOB
     ,par_content_type VARCHAR2
     ,par_file_name    VARCHAR2
    ) RETURN NUMBER IS
      v_pages_count NUMBER;
    BEGIN
      IF par_content_type LIKE 'application/pdf%'
         OR upper(par_file_name) LIKE '%PDF'
      THEN
        SELECT regexp_substr(utl_raw.cast_to_varchar2(dbms_lob.substr(par_report
                                                                     ,dbms_lob.instr(par_report
                                                                                    ,utl_raw.cast_to_raw('>>')
                                                                                    ,dbms_lob.instr(par_report
                                                                                                   ,utl_raw.cast_to_raw('/Count'))) -
                                                                      dbms_lob.instr(par_report
                                                                                    ,utl_raw.cast_to_raw('/Count'))
                                                                     ,dbms_lob.instr(par_report
                                                                                    ,utl_raw.cast_to_raw('/Count'))))
                            ,'\d+')
          INTO v_pages_count
          FROM dual;
      END IF;
      RETURN v_pages_count;
    END get_pages_count;
  BEGIN
    BEGIN
      SELECT CASE rt.name
               WHEN 'WebReport' THEN
                ins.pkg_app_param.get_app_param_c('SITENAME') || rt.url_name ||
                ins.pkg_app_param.get_app_param_c('LDAP_RAD_NAME') || '/' || rr.exe_name || '?' ||
                ins.pkg_app_param.get_app_param_c('LDAP_RAD_NAME')
               WHEN 'Procedure' THEN
                rr.exe_name
               ELSE
                ins.pkg_app_param.get_app_param_c('SITENAME') || rt.url_name || rr.exe_name
             END
            ,rr.parameters
            ,rt.name
        INTO v_rep_url_or_procedure
            ,v_rep_params
            ,v_rep_type
        FROM rep_report rr
            ,rep_type   rt
       WHERE rt.rep_type_id = rr.rep_type_id
         AND rr.rep_report_id = par_report_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Отчет с ID ' || to_char(par_report_id) || ' не найден.');
    END;
  
    IF v_rep_type = 'Procedure'
    THEN
      --Установка контекста для отчетов с процедурами
      repcore.set_context('REP_REPORT_ID', par_report_id);
      exec_procedure(par_procedure_name => v_rep_url_or_procedure
                    ,par_content_type   => par_content_type
                    ,par_file_name      => par_file_name
                    ,par_report         => par_report);
    ELSE
      exec_webreport(par_rep_url      => v_rep_url_or_procedure
                    ,par_rep_params   => v_rep_params
                    ,par_content_type => par_content_type
                    ,par_file_name    => par_file_name
                    ,par_report       => par_report);
    END IF;
  
    par_pages_count := get_pages_count(par_report       => par_report
                                      ,par_content_type => par_content_type
                                      ,par_file_name    => par_file_name);
  
  END exec_report;

  PROCEDURE store_report
  (
    par_report_id    NUMBER
   ,par_report       BLOB
   ,par_file_name    VARCHAR2
   ,par_content_type VARCHAR2
   ,par_parent_id    NUMBER
   ,par_document_id  NUMBER
   ,par_order_num    VARCHAR2
   ,par_pages_count  NUMBER DEFAULT NULL
  ) IS
    v_report_body BLOB;
  BEGIN
  
    -- Вставка строки и возврат LOB-локатора
    INSERT INTO tmp_stored_reports
      (content_type
      ,report_body
      ,file_name
      ,parent_id
      ,document_id
      ,order_num
      ,pages_count
      ,rep_report_id)
    VALUES
      (par_content_type
      ,empty_blob()
      ,par_file_name
      ,par_parent_id
      ,par_document_id
      ,par_order_num
      ,par_pages_count
      ,par_report_id)
    RETURNING report_body INTO v_report_body;
    dbms_lob.open(v_report_body, dbms_lob.lob_readwrite);
  
    dbms_lob.copy(dest_lob => v_report_body
                 ,src_lob  => par_report
                 ,amount   => dbms_lob.getlength(par_report));
  
    dbms_lob.close(v_report_body);
  END store_report;

  PROCEDURE exec_and_store_report
  (
    par_report_id   NUMBER
   ,par_file_name   VARCHAR2
   ,par_parent_id   NUMBER
   ,par_document_id NUMBER
   ,par_order_num   VARCHAR2
   ,par_pages       NUMBER DEFAULT NULL
  ) IS
    v_content_type VARCHAR2(50);
    v_file_name    VARCHAR2(255);
    v_report_body  BLOB;
    v_pages_count  NUMBER;
  BEGIN
    exec_report(par_report_id    => par_report_id
               ,par_pages_count  => v_pages_count
               ,par_content_type => v_content_type
               ,par_file_name    => v_file_name
               ,par_report       => v_report_body);
  
    IF v_pages_count IS NULL
    THEN
      v_pages_count := par_pages;
    END IF;
  
    IF par_file_name IS NOT NULL
    THEN
      v_file_name := par_file_name;
    END IF;
  
    store_report(par_report_id    => par_report_id
                ,par_report       => v_report_body
                ,par_file_name    => v_file_name
                ,par_content_type => v_content_type
                ,par_parent_id    => par_parent_id
                ,par_document_id  => par_document_id
                ,par_order_num    => par_order_num
                ,par_pages_count  => v_pages_count);
  
  END exec_and_store_report;

  /*
   * Чирков В.
   * Процедура для получения даты в родительном падеже
  */
  FUNCTION date_to_genitive_case(p_date DATE) RETURN VARCHAR2 IS
    v_res VARCHAR2(20);
  BEGIN
    SELECT to_char(p_date, 'dd') || ' ' || CASE p_mm
             WHEN '01' THEN
              'Января'
             WHEN '02' THEN
              'Февраля'
             WHEN '03' THEN
              'Марта'
             WHEN '04' THEN
              'Апреля'
             WHEN '05' THEN
              'Мая'
             WHEN '06' THEN
              'Июня'
             WHEN '07' THEN
              'Июля'
             WHEN '08' THEN
              'Августа'
             WHEN '09' THEN
              'Сентября'
             WHEN '10' THEN
              'Октября'
             WHEN '11' THEN
              'Ноября'
             WHEN '12' THEN
              'Декабря'
           END || ' ' || to_char(p_date, 'yyyy')
      INTO v_res
      FROM (SELECT to_char(p_date, 'mm') p_mm FROM dual);
    RETURN v_res;
  END;

  /*
   * Черных М.Г. 15.05.2014
   * Дата в родительном падеже (число в кавычках)
  */
  FUNCTION date_to_genitive_case_quotes(p_date DATE) RETURN VARCHAR2 IS
    v_res VARCHAR2(20);
  BEGIN
    SELECT '«' || to_char(p_date, 'dd') || '»' || ' ' || CASE p_mm
             WHEN '01' THEN
              'января'
             WHEN '02' THEN
              'февраля'
             WHEN '03' THEN
              'марта'
             WHEN '04' THEN
              'апреля'
             WHEN '05' THEN
              'мая'
             WHEN '06' THEN
              'июня'
             WHEN '07' THEN
              'июля'
             WHEN '08' THEN
              'августа'
             WHEN '09' THEN
              'сентября'
             WHEN '10' THEN
              'октября'
             WHEN '11' THEN
              'ноября'
             WHEN '12' THEN
              'декабря'
           END || ' ' || to_char(p_date, 'yyyy')
      INTO v_res
      FROM (SELECT to_char(p_date, 'mm') p_mm FROM dual);
    RETURN v_res;
  END;
  /**/
  PROCEDURE rla_act_second_fl_agent(par_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(30) := 'RLA_ACT_SECOND_FL_AGENT';
  BEGIN
    DELETE FROM ins.rla_second_recruit;
    COMMIT;
    INSERT INTO ins.rla_second_recruit
      SELECT DISTINCT aghr.num recruit_num
                      --,LPAD(aghr.num, 6, '0') recruit_num
                     ,decode(ct.description, 'ПБОЮЛ', 'ИП ', '') || REPLACE(c.obj_name_orig, '"') recruit_name
                     ,ins.pkg_utils.date2genitive_case(aghr.date_begin) date_begin
                     ,c.contact_id
                     ,aghr.ag_contract_header_id
                     ,REPLACE(c.obj_name_orig, '"') orig_recruit_name
                     ,decode(ct.description, 'ПБОЮЛ', 'ИП ', '')
        FROM ins.ven_ag_contract_header agh
            ,ins.t_sales_channel        ch
            ,ins.ag_contract            ag
            ,ins.ag_contract            agr
            ,ins.ven_ag_contract_header aghr
            ,ins.ag_contract            aghr_ag
            ,ins.contact                c
            ,ins.t_contact_type         ct
       WHERE agh.t_sales_channel_id = ch.id
         AND ch.brief = 'RLA'
         AND agh.last_ver_id = ag.ag_contract_id
         AND ag.contract_recrut_id = agr.ag_contract_id
         AND agr.contract_id = aghr.ag_contract_header_id
         AND aghr.agent_id = c.contact_id
         AND aghr.num != '1'
         AND agr.leg_pos != 101
         AND aghr.ag_contract_header_id = aghr_ag.contract_id
         AND (SELECT nvl(rl.date_end, arh.date_end)
                FROM ins.ag_roll        rl
                    ,ins.ag_roll_header arh
               WHERE arh.ag_roll_header_id = rl.ag_roll_header_id
                 AND rl.ag_roll_id = par_ag_roll_id) BETWEEN aghr_ag.date_begin AND aghr_ag.date_end
         AND aghr_ag.leg_pos = ct.id
         AND EXISTS (SELECT NULL
                FROM ins.ag_perfomed_work_act act
                    ,ins.ag_perfom_work_det   det
                    ,ins.ag_perf_work_vol     vol
               WHERE act.ag_contract_header_id = agh.ag_contract_header_id
                 AND act.ag_roll_id = par_ag_roll_id
                 AND act.ag_perfomed_work_act_id = det.ag_perfomed_work_act_id
                 AND det.ag_perfom_work_det_id = vol.ag_perfom_work_det_id
                 AND agh.ag_contract_header_id IN
                     (SELECT ag.contract_id
                        FROM ins.ag_contract_header ach
                            ,ins.ag_contract        ag
                            ,ins.ag_contract        aga
                       WHERE ach.last_ver_id = ag.ag_contract_id
                         AND ag.contract_recrut_id = aga.ag_contract_id
                         AND aga.contract_id = aghr.ag_contract_header_id))
         AND EXISTS
       (SELECT NULL
                FROM ins.ag_roll              rl
                    ,ins.ag_roll_header       arh
                    ,ins.ag_perfomed_work_act act
               WHERE act.ag_roll_id = rl.ag_roll_id
                 AND arh.ag_roll_header_id = rl.ag_roll_header_id
                 AND rl.ag_roll_id = par_ag_roll_id
                 AND act.ag_contract_header_id IN (SELECT aga.contract_id
                                                     FROM ins.ag_contract_header agh
                                                         ,ins.ag_contract        ag
                                                         ,ins.ag_contract        aga
                                                    WHERE agh.last_ver_id = ag.ag_contract_id
                                                      AND aga.contract_recrut_id = ag.ag_contract_id
                                                      AND aga.contract_id = aghr.ag_contract_header_id
                                                   UNION
                                                   SELECT agl.contract_id
                                                     FROM ins.ag_contract_header agh
                                                         ,ins.ag_contract        ag
                                                         ,ins.ag_contract        aga
                                                         ,ins.ag_contract        agl
                                                    WHERE agh.last_ver_id = ag.ag_contract_id
                                                      AND aga.contract_recrut_id = ag.ag_contract_id
                                                      AND aga.contract_id = aghr.ag_contract_header_id
                                                      AND agl.contract_leader_id = aga.ag_contract_id
                                                   UNION
                                                   SELECT aghr.ag_contract_header_id
                                                     FROM dual));
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Ошибка формирования рекрутеров для акта.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Ошибка формирования рекрутеров для акта.');
  END rla_act_second_fl_agent;
  /**/
  PROCEDURE rla_act_second_fl_trans(par_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(30) := 'RLA_ACT_SECOND_FL_TRANS';
  BEGIN
    DELETE FROM ins.rla_second_trans;
    COMMIT;
    INSERT INTO ins.rla_second_trans
      SELECT product
            ,pol_num
            ,holder
            ,payment_date
            ,pay_period
            ,ROUND(SUM(trans_sum), 2)
            ,ag_contract_header_id
            ,epg_date
            ,ins_period
        FROM (SELECT DISTINCT decode(tp.description
                                    ,'Защита и накопление для банка Ситисервис'
                                    ,'Защита и накопление'
                                    ,'Platinum Life Active_2 СитиСервис'
                                    ,'Platinum Life Active'
                                    ,tp.description) product
                             ,' ' || pp.pol_num pol_num
                             ,cn_i.obj_name_orig holder
                             ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
                             ,av.pay_period
                             ,av.ins_period
                             ,av.trans_sum
                             ,rc.ag_contract_header_id
                             ,av.epg_date
                FROM ins.ven_ag_roll_header   arh
                    ,ins.ven_ag_roll          ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            av
                    ,ins.ag_volume_type       avt
                    ,ins.ag_contract_header   ach
                    ,ins.ag_contract_header   ach_s
                    ,ins.ag_contract_header   leader_ach
                    ,ins.ag_contract          leader_ac
                    ,ins.contact              cn_leader
                    ,ins.contact              cn_as
                    ,ins.contact              cn_a
                    ,ins.ag_contract          ac
                    ,ins.ag_category_agent    aca
                    ,ins.p_pol_header         ph
                    ,ins.t_product            tp
                    ,ins.p_policy             pp
                    ,ins.contact              cn_i
                    ,ins.rla_second_recruit   rc
               WHERE 1 = 1
                 AND tp.brief NOT IN
                     ('END', 'END_2', 'PEPR', 'PEPR_2', 'CHI', 'CHI_2', 'TERM', 'TERM_2')
                 AND ar.ag_roll_id = par_ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('RLA_PERSONAL_POL'
                                  ,'RLA_MANAG_STRUCTURE'
                                  ,'RLA_CONTRIB_YEARS'
                                  ,'RLA_VOLUME_GROUP')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ph.product_id = tp.product_id
                 AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                 AND ac.category_id = aca.ag_category_agent_id
                 AND cn_a.contact_id = ach.agent_id
                 AND ach.ag_contract_header_id IN
                     (SELECT ag.contract_id
                        FROM ins.ag_contract_header agh
                            ,ins.ag_contract        ag
                            ,ins.ag_contract        aga
                       WHERE agh.last_ver_id = ag.ag_contract_id
                         AND ag.contract_recrut_id = aga.ag_contract_id
                         AND aga.contract_id = rc.ag_contract_header_id)
              UNION ALL
              SELECT DISTINCT opt.description product
                             ,' ' || pp.pol_num pol_num
                             ,cn_i.obj_name_orig holder
                             ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
                             ,av.pay_period
                             ,av.ins_period
                             ,av.trans_sum
                             ,rc.ag_contract_header_id
                             ,av.epg_date
                FROM ins.ven_ag_roll_header   arh
                    ,ins.ven_ag_roll          ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            av
                    ,ins.ag_volume_type       avt
                    ,ins.ag_contract_header   ach
                    ,ins.ag_contract_header   ach_s
                    ,ins.ag_contract_header   leader_ach
                    ,ins.ag_contract          leader_ac
                    ,ins.contact              cn_leader
                    ,ins.contact              cn_as
                    ,ins.contact              cn_a
                    ,ins.ag_contract          ac
                    ,ins.ag_category_agent    aca
                    ,ins.p_pol_header         ph
                    ,ins.t_product            tp
                    ,ins.p_policy             pp
                    ,ins.contact              cn_i
                    ,ins.rla_second_recruit   rc
                    ,ins.t_prod_line_option   opt
               WHERE 1 = 1
                 AND tp.brief IN ('END', 'END_2', 'PEPR', 'PEPR_2', 'CHI', 'CHI_2', 'TERM', 'TERM_2')
                 AND ar.ag_roll_id = par_ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('RLA_PERSONAL_POL'
                                  ,'RLA_MANAG_STRUCTURE'
                                  ,'RLA_CONTRIB_YEARS'
                                  ,'RLA_VOLUME_GROUP')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ph.product_id = tp.product_id
                 AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                 AND ac.category_id = aca.ag_category_agent_id
                 AND cn_a.contact_id = ach.agent_id
                 AND av.t_prod_line_option_id = opt.id
                 AND ach.ag_contract_header_id IN
                     (SELECT ag.contract_id
                        FROM ins.ag_contract_header agh
                            ,ins.ag_contract        ag
                            ,ins.ag_contract        aga
                       WHERE agh.last_ver_id = ag.ag_contract_id
                         AND ag.contract_recrut_id = aga.ag_contract_id
                         AND aga.contract_id = rc.ag_contract_header_id))
       GROUP BY product
               ,pol_num
               ,holder
               ,payment_date
               ,pay_period
               ,ag_contract_header_id
               ,epg_date
               ,ins_period;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Ошибка формирования уплаченной страховой премии.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Ошибка формирования уплаченной страховой премии.');
  END rla_act_second_fl_trans;
  /**/
  PROCEDURE rla_act_second_fl_commiss(par_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(30) := 'RLA_ACT_SECOND_FL_COMMISS';
  BEGIN
    DELETE FROM ins.rla_second_commiss;
    COMMIT;
    /*Агент = Раздатчику, то договора по типу премии (Комиссионное вознаграждение
      за взносы последующих лет и Комиссионное вознаграждение за личное заключение ДС)
      формируются в п. 2.1 акта раздатчика
    */
    INSERT INTO ins.rla_second_commiss
      SELECT opt.description product
            ,' ' || pp.pol_num
            ,cn_i.obj_name_orig holder
            ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
            ,av.pay_period
            ,av.ins_period
            ,ROUND(SUM(apv.vol_units), 2) vol_amount
            ,apv.vol_amount vol_rate
            ,ROUND(SUM(apv.vol_amount * apv.vol_units * nvl(apv.vol_decrease, 1)), 2) detail_commiss
            ,ROUND(SUM(apv.vol_amount * apv.vol_units * apv.vol_rate * nvl(apv.vol_decrease, 1)), 2) kvl
            ,ROUND(SUM(av.trans_sum), 2) trans_sum
            ,rc.ag_contract_header_id
            ,ROUND(nvl(apv.vol_decrease, 1), 2) vol_decrease
            ,av.epg_date
        FROM ins.ag_roll_header       arh
            ,ins.ag_roll              ar
            ,ins.ag_perfomed_work_act apw
            ,ins.ag_perfom_work_det   apd
            ,ins.ag_rate_type         art
            ,ins.ag_perf_work_vol     apv
            ,ins.ag_volume            av
            ,ins.ag_volume_type       avt
            ,ins.ag_contract_header   ach
            ,ins.ag_contract_header   ach_s
            ,ins.ag_contract_header   leader_ach
            ,ins.ag_contract          leader_ac
            ,ins.contact              cn_leader
            ,ins.contact              cn_as
            ,ins.contact              cn_a
            ,ins.department           dep
            ,ins.t_sales_channel      ts
            ,ins.ag_contract          ac
            ,ins.ag_category_agent    aca
            ,ins.t_contact_type       tct
            ,ins.p_pol_header         ph
            ,ins.t_product            tp
            ,ins.p_policy             pp
            ,ins.contact              cn_i
            ,ins.rla_second_recruit   rc
            ,ins.t_prod_line_option   opt
       WHERE 1 = 1
         AND tp.brief IN ('END', 'END_2', 'PEPR', 'PEPR_2', 'CHI', 'CHI_2', 'TERM', 'TERM_2')
         AND ar.ag_roll_id = par_ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND art.brief IN ('RLA_CONTRIB_YEARS')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id
         AND av.ag_volume_type_id = avt.ag_volume_type_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND ph.policy_id = pp.policy_id
         AND ph.product_id = tp.product_id
         AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ac.ag_sales_chn_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND rc.ag_contract_header_id = ach_s.ag_contract_header_id
         AND opt.id = av.t_prod_line_option_id
         AND ach.ag_contract_header_id IN
             (SELECT ag.contract_id
                FROM ins.ag_contract_header agh
                    ,ins.ag_contract        ag
                    ,ins.ag_contract        aga
               WHERE agh.last_ver_id = ag.ag_contract_id
                 AND ag.contract_recrut_id = aga.ag_contract_id
                 AND aga.contract_id = rc.ag_contract_header_id)
       GROUP BY opt.description
               ,pp.pol_num
               ,cn_i.obj_name_orig
               ,av.payment_date_orig
               ,av.pay_period
               ,apv.vol_amount
               ,av.ins_period
               ,rc.ag_contract_header_id
               ,apv.vol_decrease
               ,av.epg_date
      UNION ALL
      SELECT decode(tp.description
                   ,'Защита и накопление для банка Ситисервис'
                   ,'Защита и накопление'
                   ,'Platinum Life Active_2 СитиСервис'
                   ,'Platinum Life Active'
                   ,tp.description) product
            ,' ' || pp.pol_num
            ,cn_i.obj_name_orig holder
            ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
            ,av.pay_period
            ,av.ins_period
            ,ROUND(SUM(apv.vol_units), 2) vol_amount
            ,apv.vol_amount vol_rate
            ,ROUND(SUM(apv.vol_amount * apv.vol_units * nvl(apv.vol_decrease, 1)), 2) detail_commiss
            ,ROUND(SUM(apv.vol_amount * apv.vol_units * apv.vol_rate * nvl(apv.vol_decrease, 1)), 2) kvl
            ,ROUND(SUM(av.trans_sum), 2) trans_sum
            ,rc.ag_contract_header_id
            ,ROUND(nvl(apv.vol_decrease, 1), 2) vol_decrease
            ,av.epg_date
        FROM ins.ag_roll_header       arh
            ,ins.ag_roll              ar
            ,ins.ag_perfomed_work_act apw
            ,ins.ag_perfom_work_det   apd
            ,ins.ag_rate_type         art
            ,ins.ag_perf_work_vol     apv
            ,ins.ag_volume            av
            ,ins.ag_volume_type       avt
            ,ins.ag_contract_header   ach
            ,ins.ag_contract_header   ach_s
            ,ins.ag_contract_header   leader_ach
            ,ins.ag_contract          leader_ac
            ,ins.contact              cn_leader
            ,ins.contact              cn_as
            ,ins.contact              cn_a
            ,ins.department           dep
            ,ins.t_sales_channel      ts
            ,ins.ag_contract          ac
            ,ins.ag_category_agent    aca
            ,ins.t_contact_type       tct
            ,ins.p_pol_header         ph
            ,ins.t_product            tp
            ,ins.p_policy             pp
            ,ins.contact              cn_i
            ,ins.rla_second_recruit   rc
       WHERE 1 = 1
         AND tp.brief NOT IN ('END', 'END_2', 'PEPR', 'PEPR_2', 'CHI', 'CHI_2', 'TERM', 'TERM_2')
         AND ar.ag_roll_id = par_ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND art.brief IN ('RLA_CONTRIB_YEARS')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id
         AND av.ag_volume_type_id = avt.ag_volume_type_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND ph.policy_id = pp.policy_id
         AND ph.product_id = tp.product_id
         AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ac.ag_sales_chn_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND rc.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach.ag_contract_header_id IN
             (SELECT ag.contract_id
                FROM ins.ag_contract_header agh
                    ,ins.ag_contract        ag
                    ,ins.ag_contract        aga
               WHERE agh.last_ver_id = ag.ag_contract_id
                 AND ag.contract_recrut_id = aga.ag_contract_id
                 AND aga.contract_id = rc.ag_contract_header_id)
       GROUP BY tp.description
               ,pp.pol_num
               ,cn_i.obj_name_orig
               ,av.payment_date_orig
               ,av.pay_period
               ,apv.vol_amount
               ,av.ins_period
               ,rc.ag_contract_header_id
               ,apv.vol_decrease
               ,av.epg_date
      /**/
      UNION ALL
      SELECT opt.description product
            ,' ' || pp.pol_num
            ,cn_i.obj_name_orig holder
            ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
            ,av.pay_period
            ,av.ins_period
            ,ROUND(SUM(apv.vol_amount), 2) vol_amount
            ,apv.vol_rate
            ,ROUND(SUM(apv.vol_amount * apv.vol_rate * nvl(apv.vol_decrease, 1)), 2) detail_commiss
            ,ROUND(SUM(apv.vol_amount * nvl(apv.vol_decrease, 1) * apv.vol_rate * (CASE av.pay_period
                         WHEN 1 THEN
                          100 / 100
                         WHEN 2 THEN
                          25 / 100
                         ELSE
                          10 / 100
                       END))
                  ,2) kvl
            ,ROUND(SUM(av.trans_sum), 2) trans_sum
            ,rc.ag_contract_header_id
            ,ROUND(nvl(apv.vol_decrease, 1), 2) vol_decrease
            ,av.epg_date
        FROM ins.ven_ag_roll_header   arh
            ,ins.ven_ag_roll          ar
            ,ins.ag_perfomed_work_act apw
            ,ins.ag_perfom_work_det   apd
            ,ins.ag_rate_type         art
            ,ins.ag_perf_work_vol     apv
            ,ins.ag_volume            av
            ,ins.ag_volume_type       avt
            ,ins.ag_contract_header   ach
            ,ins.ag_contract_header   ach_s
            ,ins.ag_contract_header   leader_ach
            ,ins.ag_contract          leader_ac
            ,ins.contact              cn_leader
            ,ins.contact              cn_as
            ,ins.contact              cn_a
            ,ins.department           dep
            ,ins.t_sales_channel      ts
            ,ins.ag_contract          ac
            ,ins.ag_category_agent    aca
            ,ins.t_contact_type       tct
            ,ins.p_pol_header         ph
            ,ins.t_product            tp
            ,ins.p_policy             pp
            ,ins.contact              cn_i
            ,ins.rla_second_recruit   rc
            ,ins.t_prod_line_option   opt
       WHERE 1 = 1
         AND tp.brief IN ('END', 'END_2', 'PEPR', 'PEPR_2', 'CHI', 'CHI_2', 'TERM', 'TERM_2')
         AND ar.ag_roll_id = par_ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND art.brief IN ('RLA_PERSONAL_POL')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id
         AND av.ag_volume_type_id = avt.ag_volume_type_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND ph.policy_id = pp.policy_id
         AND ph.product_id = tp.product_id
         AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ac.ag_sales_chn_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND rc.ag_contract_header_id = ach_s.ag_contract_header_id
         AND opt.id = av.t_prod_line_option_id
         AND ach.ag_contract_header_id IN
             (SELECT ag.contract_id
                FROM ins.ag_contract_header agh
                    ,ins.ag_contract        ag
                    ,ins.ag_contract        aga
               WHERE agh.last_ver_id = ag.ag_contract_id
                 AND ag.contract_recrut_id = aga.ag_contract_id
                 AND aga.contract_id = rc.ag_contract_header_id)
       GROUP BY opt.description
               ,pp.pol_num
               ,cn_i.obj_name_orig
               ,av.payment_date_orig
               ,av.pay_period
               ,apv.vol_rate
               ,av.ins_period
               ,rc.ag_contract_header_id
               ,apv.vol_decrease
               ,av.epg_date
      UNION ALL
      SELECT decode(tp.description
                   ,'Защита и накопление для банка Ситисервис'
                   ,'Защита и накопление'
                   ,'Platinum Life Active_2 СитиСервис'
                   ,'Platinum Life Active'
                   ,tp.description) product
            ,' ' || pp.pol_num
            ,cn_i.obj_name_orig holder
            ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
            ,av.pay_period
            ,av.ins_period
            ,ROUND(SUM(apv.vol_amount), 2) vol_amount
            ,apv.vol_rate
            ,ROUND(SUM(apv.vol_amount * apv.vol_rate * nvl(apv.vol_decrease, 1)), 2) detail_commiss
            ,ROUND(SUM(apv.vol_amount * nvl(apv.vol_decrease, 1) * apv.vol_rate * (CASE av.pay_period
                         WHEN 1 THEN
                          100 / 100
                         WHEN 2 THEN
                          25 / 100
                         ELSE
                          10 / 100
                       END))
                  ,2) kvl
            ,ROUND(SUM(av.trans_sum), 2) trans_sum
            ,rc.ag_contract_header_id
            ,ROUND(nvl(apv.vol_decrease, 1), 2) vol_decrease
            ,av.epg_date
        FROM ins.ven_ag_roll_header   arh
            ,ins.ven_ag_roll          ar
            ,ins.ag_perfomed_work_act apw
            ,ins.ag_perfom_work_det   apd
            ,ins.ag_rate_type         art
            ,ins.ag_perf_work_vol     apv
            ,ins.ag_volume            av
            ,ins.ag_volume_type       avt
            ,ins.ag_contract_header   ach
            ,ins.ag_contract_header   ach_s
            ,ins.ag_contract_header   leader_ach
            ,ins.ag_contract          leader_ac
            ,ins.contact              cn_leader
            ,ins.contact              cn_as
            ,ins.contact              cn_a
            ,ins.department           dep
            ,ins.t_sales_channel      ts
            ,ins.ag_contract          ac
            ,ins.ag_category_agent    aca
            ,ins.t_contact_type       tct
            ,ins.p_pol_header         ph
            ,ins.t_product            tp
            ,ins.p_policy             pp
            ,ins.contact              cn_i
            ,ins.rla_second_recruit   rc
       WHERE 1 = 1
         AND tp.brief NOT IN ('END', 'END_2', 'PEPR', 'PEPR_2', 'CHI', 'CHI_2', 'TERM', 'TERM_2')
         AND ar.ag_roll_id = par_ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND art.brief IN ('RLA_PERSONAL_POL')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id
         AND av.ag_volume_type_id = avt.ag_volume_type_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND ph.policy_id = pp.policy_id
         AND ph.product_id = tp.product_id
         AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ac.ag_sales_chn_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND rc.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach.ag_contract_header_id IN
             (SELECT ag.contract_id
                FROM ins.ag_contract_header agh
                    ,ins.ag_contract        ag
                    ,ins.ag_contract        aga
               WHERE agh.last_ver_id = ag.ag_contract_id
                 AND ag.contract_recrut_id = aga.ag_contract_id
                 AND aga.contract_id = rc.ag_contract_header_id)
       GROUP BY tp.description
               ,pp.pol_num
               ,cn_i.obj_name_orig
               ,av.payment_date_orig
               ,av.pay_period
               ,apv.vol_rate
               ,av.ins_period
               ,rc.ag_contract_header_id
               ,apv.vol_decrease
               ,av.epg_date;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Ошибка формирования КВ.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Ошибка формирования КВ.');
  END rla_act_second_fl_commiss;
  /**/
  /**/
  PROCEDURE rla_act_second_kvg_commiss(par_ag_roll_id NUMBER) IS
    proc_name                 VARCHAR2(30) := 'RLA_ACT_SECOND_KVG_COMMISS';
    v_roll_contract_header_id NUMBER;
    v_roll_header_id          NUMBER;
    v_contract_header_tar     NUMBER;
    v_header_tar              NUMBER;
  BEGIN
    DELETE FROM ins.rla_second_kvg;
    COMMIT;
    /*Агент = Раздатчику, при групповых продажах Тип премий (Комиссионное вознаграждение
      за руководство структурами) договора отправляются в п.2.2 акта раздатчика
    */
    INSERT INTO ins.rla_second_kvg
      (ag_contract_header_id, ag_header_id, ag_header_num, ag_header_name, vol_kvl, vol_kvg)
      SELECT header_id
            ,header_child_id
            ,agent_num
            ,agent_fio
            ,SUM(kvl)
            ,SUM(kvg)
        FROM (SELECT ach.ag_contract_header_id header_id
                    ,ach_s.ag_contract_header_id header_child_id
                    ,d.num agent_num
                    ,cn_as.obj_name_orig agent_fio
                    ,SUM(apv.vol_units) kvl
                    ,SUM(nvl(apv.vol_amount, 0) * nvl(apv.vol_rate, 0) * nvl(apv.vol_decrease, 1) *
                         apv.vol_units) kvg
                FROM ins.ag_roll_header       arh
                    ,ins.ag_roll              ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            av
                    ,ins.ag_volume_type       avt
                    ,ins.ag_contract_header   ach
                    ,ins.ag_contract_header   ach_s
                    ,ins.document             d
                    ,ins.ag_contract_header   leader_ach
                    ,ins.ag_contract          leader_ac
                    ,ins.contact              cn_leader
                    ,ins.contact              cn_as
                    ,ins.contact              cn_a
                    ,ins.ag_contract          ac
                    ,ins.p_pol_header         ph
                    ,ins.p_policy             pp
                    ,ins.rla_second_recruit   rc
               WHERE 1 = 1
                 AND ar.ag_roll_id = par_ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('RLA_MANAG_STRUCTURE')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND ach_s.ag_contract_header_id = d.document_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                 AND cn_a.contact_id = ach.agent_id
                 AND rc.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach.ag_contract_header_id IN
                     (SELECT ag.contract_id
                        FROM ins.ag_contract_header agh
                            ,ins.ag_contract        ag
                            ,ins.ag_contract        aga
                       WHERE agh.last_ver_id = ag.ag_contract_id
                         AND ag.contract_recrut_id = aga.ag_contract_id
                         AND aga.contract_id = rc.ag_contract_header_id)
               GROUP BY ach.ag_contract_header_id
                       ,ach_s.ag_contract_header_id
                       ,d.num
                       ,cn_as.obj_name_orig
              /*Агент не равно Раздатчику, то договора по типу премий (Комиссионное вознаграждение
                за взносы последующих лет, Комиссионное вознаграждение за личное заключение ДС и
                Комиссионное вознаграждение за руководство структурами) формируются в п.2.2 акта раздатчика
              */
              UNION ALL
              SELECT rc.ag_contract_header_id header_id
                    ,ach_s.ag_contract_header_id header_child_id
                    ,d.num
                    ,cn_as.obj_name_orig
                    ,SUM(apv.vol_units) kvl
                    ,SUM(nvl(apv.vol_amount, 0) * nvl(apv.vol_rate, 0) * nvl(apv.vol_decrease, 1) *
                         apv.vol_units) kvg
                FROM ins.ag_roll_header       arh
                    ,ins.ag_roll              ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            av
                    ,ins.ag_volume_type       avt
                    ,ins.ag_contract_header   ach
                    ,ins.ag_contract_header   ach_s
                    ,ins.document             d
                    ,ins.ag_contract_header   leader_ach
                    ,ins.ag_contract          leader_ac
                    ,ins.contact              cn_leader
                    ,ins.contact              cn_as
                    ,ins.contact              cn_a
                    ,ins.ag_contract          ac
                    ,ins.p_pol_header         ph
                    ,ins.p_policy             pp
                    ,ins.rla_second_recruit   rc
               WHERE 1 = 1
                 AND ar.ag_roll_id = par_ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('RLA_MANAG_STRUCTURE', 'RLA_CONTRIB_YEARS')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND ach_s.ag_contract_header_id = d.document_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                 AND cn_a.contact_id = ach.agent_id
                 AND rc.ag_contract_header_id != ach_s.ag_contract_header_id
                 AND ach.ag_contract_header_id IN
                     (SELECT ag.contract_id
                        FROM ins.ag_contract_header agh
                            ,ins.ag_contract        ag
                            ,ins.ag_contract        aga
                       WHERE agh.last_ver_id = ag.ag_contract_id
                         AND ag.contract_recrut_id = aga.ag_contract_id
                         AND aga.contract_id = rc.ag_contract_header_id)
               GROUP BY rc.ag_contract_header_id
                       ,ach_s.ag_contract_header_id
                       ,d.num
                       ,cn_as.obj_name_orig
              UNION ALL
              SELECT rc.ag_contract_header_id header_id
                    ,ach_s.ag_contract_header_id header_child_id
                    ,d.num
                    ,cn_as.obj_name_orig
                    ,SUM(nvl(apv.vol_units, 0)) kvl
                    ,SUM(nvl(apv.vol_amount, 0) * nvl(apv.vol_rate, 0) * nvl(apv.vol_decrease, 1)) kvg
                FROM ins.ag_roll_header       arh
                    ,ins.ag_roll              ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            av
                    ,ins.ag_volume_type       avt
                    ,ins.ag_contract_header   ach
                    ,ins.ag_contract_header   ach_s
                    ,ins.document             d
                    ,ins.ag_contract_header   leader_ach
                    ,ins.ag_contract          leader_ac
                    ,ins.contact              cn_leader
                    ,ins.contact              cn_as
                    ,ins.contact              cn_a
                    ,ins.ag_contract          ac
                    ,ins.p_pol_header         ph
                    ,ins.p_policy             pp
                    ,ins.rla_second_recruit   rc
               WHERE 1 = 1
                 AND ar.ag_roll_id = par_ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('RLA_PERSONAL_POL')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND ach_s.ag_contract_header_id = d.document_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                 AND cn_a.contact_id = ach.agent_id
                 AND rc.ag_contract_header_id != ach_s.ag_contract_header_id
                 AND ach.ag_contract_header_id IN
                     (SELECT ag.contract_id
                        FROM ins.ag_contract_header agh
                            ,ins.ag_contract        ag
                            ,ins.ag_contract        aga
                       WHERE agh.last_ver_id = ag.ag_contract_id
                         AND ag.contract_recrut_id = aga.ag_contract_id
                         AND aga.contract_id = rc.ag_contract_header_id)
               GROUP BY rc.ag_contract_header_id
                       ,ach_s.ag_contract_header_id
                       ,d.num
                       ,cn_as.obj_name_orig)
       WHERE header_child_id NOT IN
             (SELECT agh.ag_contract_header_id
                FROM ins.ven_ag_contract_header agh
                    ,ins.document               d
                    ,ins.doc_status_ref         rf
               WHERE agh.agent_id IN
                     (SELECT ach.agent_id FROM ins.ven_ag_contract_header ach WHERE ach.num = '47975')
                 AND agh.ag_contract_header_id = d.document_id
                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                 AND rf.brief = 'CURRENT'
                 AND agh.t_sales_channel_id IN
                     (SELECT ch.id FROM ins.t_sales_channel ch WHERE ch.brief = 'RLA')
                 AND agh.ag_contract_header_id =
                     (SELECT MAX(ag.ag_contract_header_id)
                        FROM ins.ag_contract_header ag
                       WHERE ag.agent_id = (SELECT acha.agent_id
                                              FROM ins.ven_ag_contract_header acha
                                             WHERE acha.num = '47975')))
       GROUP BY header_id
               ,header_child_id
               ,agent_num
               ,agent_fio;
    /**/
    FOR cur_head IN (SELECT DISTINCT kvg.ag_contract_header_id FROM ins.rla_second_kvg kvg)
    LOOP
      SELECT MAX(ur.ag_roll_id)
        INTO v_roll_contract_header_id
        FROM ins.ag_roll_units ur
       WHERE ur.ag_roll_id != par_ag_roll_id
         AND ur.ag_contract_header_id = cur_head.ag_contract_header_id;
      IF v_roll_contract_header_id IS NOT NULL
      THEN
        SELECT (SELECT MAX(pl.t_tariff)
                  FROM ins.t_career_plan pl
                 WHERE ur.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                   AND (ur.personal_units + ur.structural_units) BETWEEN pl.t_ce_from AND pl.t_ce_to)
          INTO v_contract_header_tar
          FROM ins.ag_roll_units ur
         WHERE ur.ag_roll_id = v_roll_contract_header_id
           AND ur.ag_contract_header_id = cur_head.ag_contract_header_id;
      ELSE
        SELECT (SELECT MAX(pl.t_tariff)
                  FROM ins.t_career_plan pl
                 WHERE agh.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                   AND agh.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to)
          INTO v_contract_header_tar
          FROM ins.ag_contract_header agh
         WHERE agh.ag_contract_header_id = cur_head.ag_contract_header_id;
      END IF;
      UPDATE ins.rla_second_kvg kvg
         SET kvg.ag_contract_header_tar = v_contract_header_tar
       WHERE kvg.ag_contract_header_id = cur_head.ag_contract_header_id;
    END LOOP;
    /*Для Мальшаковой константа = 660*/
    UPDATE ins.rla_second_kvg kvg
       SET kvg.ag_contract_header_tar = 660
     WHERE kvg.ag_contract_header_id IN /*(SELECT agh.ag_contract_header_id
                                                                                                                                                                                       FROM ins.ag_contract_header agh
                                                                                                                                                                                      WHERE agh.is_new = 1
                                                                                                                                                                                        AND agh.agent_id = 4008669)*/
           (SELECT agha.ag_contract_header_id
              FROM ins.ag_contract_header agha
             WHERE agha.agent_id IN
                   (SELECT acha.agent_id FROM ins.ven_ag_contract_header acha WHERE acha.num = '2089'));
    /**/
    FOR cur IN (SELECT DISTINCT kvg.ag_contract_header_id
                               ,kvg.ag_header_id
                               ,kvg.ag_contract_header_tar
                               ,kvg.ag_header_tar
                  FROM ins.rla_second_kvg kvg)
    LOOP
      SELECT MAX(ur.ag_roll_id)
        INTO v_roll_header_id
        FROM ins.ag_roll_units ur
       WHERE ur.ag_roll_id != par_ag_roll_id
         AND ur.ag_contract_header_id = cur.ag_header_id;
      IF v_roll_header_id IS NOT NULL
      THEN
        SELECT (SELECT MAX(pl.t_tariff)
                  FROM ins.t_career_plan pl
                 WHERE ur.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                   AND (ur.personal_units + ur.structural_units) BETWEEN pl.t_ce_from AND pl.t_ce_to)
          INTO v_header_tar
          FROM ins.ag_roll_units ur
         WHERE ur.ag_roll_id = v_roll_header_id
           AND ur.ag_contract_header_id = cur.ag_header_id;
      ELSE
        SELECT (SELECT MAX(pl.t_tariff)
                  FROM ins.t_career_plan pl
                 WHERE agh.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                   AND agh.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to)
          INTO v_header_tar
          FROM ins.ag_contract_header agh
         WHERE agh.ag_contract_header_id = cur.ag_header_id;
      END IF;
      /**/
      UPDATE ins.rla_second_kvg kvg
         SET kvg.ag_header_tar = v_header_tar
       WHERE kvg.ag_contract_header_id = cur.ag_contract_header_id
         AND kvg.ag_header_id = cur.ag_header_id;
    END LOOP;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Ошибка формирования КВГ.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Ошибка формирования КВГ.');
  END rla_act_second_kvg_commiss;
  /**/
  PROCEDURE rla_act_second_fl_2089(par_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(30) := 'RLA_ACT_SECOND_FL_2089';
  BEGIN
    DELETE FROM ins.rla_second_2089;
    COMMIT;
    INSERT INTO ins.rla_second_2089
      SELECT agent_num
            ,ag_fio
            ,SUM(detail_amt) detail_amt
            ,SUM(detail_commis) detail_commis
            ,ag_contract_header_id
        FROM (SELECT ts.description sales_ch
                    ,dep.name agency
                    ,aca.category_name
                    ,cn_as.obj_name_orig ag_fio
                    ,ach_s.num agent_num
                    ,ach.ag_contract_header_id
                    ,tct.description leg_pos
                    ,art.name prem_detail_name
                    ,avt.description vol_type
                    ,cn_as.obj_name_orig agent_fio
                    ,tp.description product
                    ,ph.ids
                    ,pp.pol_num
                    ,ph.start_date
                    ,cn_i.obj_name_orig insuer
                    ,NULL assured_birf_date
                    ,NULL gender
                    ,(SELECT num FROM ins.document d WHERE d.document_id = av.epg_payment) epg
                    ,av.payment_date
                    ,tplo.description risk
                    ,av.pay_period
                    ,av.ins_period
                    ,pt.description payment_term
                    ,av.nbv_coef
                    ,av.trans_sum
                    ,av.index_delta_sum
                    ,nvl(apv.vol_amount, 0) detail_amt
                    ,nvl(apv.vol_rate, 0) detail_rate
                    ,nvl(apv.vol_units, 0) detail_vol_units
                    ,apv.vol_amount * apv.vol_rate * nvl(apv.vol_decrease, 1) detail_commis
                    ,apv.ag_perf_work_vol_id
                    ,apd.ag_perfom_work_det_id
                FROM ins.ag_roll_header         arh
                    ,ins.ag_roll                ar
                    ,ins.ag_perfomed_work_act   apw
                    ,ins.ag_perfom_work_det     apd
                    ,ins.ag_rate_type           art
                    ,ins.ag_perf_work_vol       apv
                    ,ins.ag_volume              av
                    ,ins.ag_volume_type         avt
                    ,ins.ag_contract_header     ach
                    ,ins.document               d
                    ,ins.ven_ag_contract_header ach_s
                    ,ins.ag_contract_header     leader_ach
                    ,ins.ag_contract            leader_ac
                    ,ins.contact                cn_leader
                    ,ins.contact                cn_as
                    ,ins.contact                cn_a
                    ,ins.department             dep
                    ,ins.t_sales_channel        ts
                    ,ins.ag_contract            ac
                    ,ins.ag_category_agent      aca
                    ,ins.t_contact_type         tct
                    ,ins.p_pol_header           ph
                    ,ins.t_product              tp
                    ,ins.t_prod_line_option     tplo
                    ,ins.t_payment_terms        pt
                    ,ins.p_policy               pp
                    ,ins.contact                cn_i
               WHERE 1 = 1
                 AND ar.ag_roll_id = par_ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('RLA_VOLUME_GROUP')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ph.product_id = tp.product_id
                 AND tplo.id = av.t_prod_line_option_id
                 AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
                 AND ach.ag_contract_header_id = d.document_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                 AND ac.agency_id = dep.department_id
                 AND ac.ag_sales_chn_id = ts.id
                 AND ac.category_id = aca.ag_category_agent_id
                 AND cn_a.contact_id = ach.agent_id
                 AND tct.id = ac.leg_pos
                 AND pt.id = av.payment_term_id
                 AND ach_s.num IN ('2100', '47975'))
       GROUP BY ag_fio
               ,agent_num
               ,ag_contract_header_id;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name);
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END rla_act_second_fl_2089;
  /**/
  PROCEDURE rla_calculation_agent(par_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(30) := 'RLA_CALCULATION_AGENT';
  BEGIN
    DELETE FROM ins.rla_calc_agent;
    COMMIT;
    INSERT INTO ins.rla_calc_agent
      SELECT h.ag_contract_header_id
            ,d.num num_agent
            ,c.contact_id
            ,REPLACE(c.obj_name_orig, '"') fio_agent
            ,to_char(nvl(rl.date_end, rh.date_end), 'DD.MM.YYYY') date_rep
            ,to_char(h.date_begin, 'DD.MM.YYYY') date_begin
            ,REPLACE(dep.name, '"', '_') depart
            ,nvl(TRIM(substr(rl_d.note, 1, 10)), to_char(SYSDATE, 'DD.MM.YYYY')) report_date
            ,decode(ag.leg_pos
                   ,1
                   ,'ПБОЮЛ'
                   ,0
                   ,'Физическое лицо'
                   ,2
                   ,''
                   ,3
                   ,'Физическое лицо'
                   ,1030
                   ,'ПБОЮЛ'
                   ,101
                   ,'Юридическое лицо'
                   ,'Физическое лицо') leg_pos
            ,decode(ag.leg_pos, 101, 1, 0) flag_leg_pos
            ,ch.description sales_ch
            ,act.ag_perfomed_work_act_id
            ,rl.ag_roll_id
            ,rh.ag_roll_header_id
        FROM ins.ag_roll_header       rh
            ,ins.ag_roll              rl
            ,ins.document             rl_d
            ,ins.ag_roll_type         tr
            ,ins.ag_perfomed_work_act act
            ,ins.ag_perfom_work_det   det
            ,ins.ag_contract_header   h
            ,ins.document             d
            ,ins.t_sales_channel      ch
            ,ins.contact              c
            ,ins.ag_contract          ag
            ,ins.department           dep
            ,ins.ag_rate_type         rt
       WHERE rh.ag_roll_type_id = tr.ag_roll_type_id
         AND rh.ag_roll_header_id = rl.ag_roll_header_id
         AND act.ag_roll_id = rl.ag_roll_id
         AND rl.ag_roll_id = rl_d.document_id
         AND det.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id
         AND act.ag_contract_header_id = h.ag_contract_header_id
         AND h.ag_contract_header_id = ag.contract_id
         AND nvl(rh.date_end, rl.date_end) BETWEEN ag.date_begin AND ag.date_end
         AND h.ag_contract_header_id = d.document_id
         AND h.agent_id = c.contact_id
         AND h.t_sales_channel_id = ch.id(+)
         AND dep.department_id(+) = ag.agency_id
         AND det.ag_rate_type_id = rt.ag_rate_type_id
         AND rt.brief = 'GET_FIRST_RLA'
         AND rl.ag_roll_id = par_ag_roll_id
         AND det.summ != 0
         AND ch.brief IN ('RLA');
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Ошибка формирования списка агентов для РАСЧЕТ.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Ошибка формирования списка агентов для РАСЧЕТ.');
  END rla_calculation_agent;
  /**/
  PROCEDURE rla_calculation_pol(par_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(30) := 'RLA_CALCULATION_POL';
  BEGIN
    DELETE FROM ins.rla_calc_pol;
    COMMIT;
    INSERT INTO ins.rla_calc_pol
      SELECT pol.pol_num num_pol
            ,cont.obj_name_orig holder
            ,decode(prod.description
                   ,'Защита и накопление для банка Ситисервис'
                   ,'Защита и накопление'
                   ,'Platinum Life Active_2 СитиСервис'
                   ,'Platinum Life Active'
                   ,prod.description) product
            ,opt.description risk_name
            ,av.pay_period
            ,av.ins_period
            ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
            ,CASE
               WHEN nvl(vol.vol_amount, 0) > 0 THEN
                nvl(vol.vol_amount *
                    (tra.acc_amount / SUM(tra.acc_amount)
                     over(PARTITION BY opt.product_line_id
                         ,av.payment_date_orig
                         ,vol.vol_amount ORDER BY av.payment_date_orig))
                   ,0)
               ELSE
                0
             END prem_pay_number
            ,CASE
               WHEN nvl(vol.vol_amount, 0) < 0 THEN
                nvl(abs(vol.vol_amount *
                        (tra.acc_amount / SUM(tra.acc_amount)
                         over(PARTITION BY opt.product_line_id
                             ,av.payment_date_orig
                             ,vol.vol_amount ORDER BY av.payment_date_orig)))
                   ,0)
               ELSE
                0
             END prem_back
            ,to_char(ROUND(nvl(vol.vol_rate, 0), 2) * 100, '99999990D99') || '%' vol_rate
            ,CASE
               WHEN nvl(vol.vol_amount, 0) > 0 THEN
                (nvl(vol.vol_amount *
                     (tra.acc_amount / SUM(tra.acc_amount)
                      over(PARTITION BY opt.product_line_id
                          ,av.payment_date_orig
                          ,vol.vol_amount ORDER BY av.payment_date_orig))
                    ,0) * nvl(vol.vol_rate, 0))
               ELSE
                0
             END com_pay_number
            ,CASE
               WHEN nvl(vol.vol_amount, 0) < 0 THEN
                (nvl(abs(vol.vol_amount *
                         (tra.acc_amount / SUM(tra.acc_amount)
                          over(PARTITION BY opt.product_line_id
                              ,av.payment_date_orig
                              ,vol.vol_amount ORDER BY av.payment_date_orig)))
                    ,0) * nvl(vol.vol_rate, 0))
               ELSE
                0
             END com_back
            ,av.epg_date
            ,trm.description period_name
            ,CASE
               WHEN f.brief = 'RUR' THEN
                ''
               ELSE
                f.brief
             END fund_brief
            ,ph.ids
            ,acc.get_cross_rate_by_brief(1, 'RUR', f.brief, av.payment_date_orig) usd_rate
            ,tra.acc_rate
            ,tra.acc_amount
            ,TRIM(epg_pd.num) epg_pd_num
            ,tra.trans_amount
        FROM ins.ag_roll_header       rh
            ,ins.ag_roll              rl
            ,ins.ag_roll_type         tr
            ,ins.ag_perfomed_work_act act
            ,ins.ag_perfom_work_det   det
            ,ins.ag_rate_type         rt
            ,ins.ag_perf_work_vol     vol
            ,ins.ag_volume            av
            ,ins.p_pol_header         ph
            ,ins.document             d
            ,ins.t_contact_pol_role   cpr
            ,ins.p_policy_contact     pc
            ,ins.contact              cont
            ,ins.t_product            prod
            ,ins.t_prod_line_option   opt
            ,ins.p_policy             pol
            ,ins.t_payment_terms      trm
            ,ins.fund                 f
            ,
             /**/ins.doc_set_off    epg_dso
            ,ins.document       d_dso
            ,ins.doc_status_ref rf_dso
            ,ins.ven_ac_payment epg_pd
            ,ins.doc_doc        pd_dd
            ,ins.ac_payment     epg_pd_copy
            ,ins.doc_set_off    pd_dso
            ,ins.ac_payment     pp_pd
            ,ins.oper           o
            ,ins.trans          tra
       WHERE rh.ag_roll_header_id = rl.ag_roll_header_id
         AND rh.ag_roll_type_id = tr.ag_roll_type_id
         AND act.ag_roll_id(+) = rl.ag_roll_id
         AND det.ag_perfomed_work_act_id(+) = act.ag_perfomed_work_act_id
         AND det.ag_rate_type_id = rt.ag_rate_type_id
         AND rt.brief = 'GET_FIRST_RLA'
         AND vol.ag_perfom_work_det_id(+) = det.ag_perfom_work_det_id
         AND av.ag_volume_id(+) = vol.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id(+)
         AND ph.policy_header_id = d.document_id(+)
         AND cpr.brief = 'Страхователь'
         AND pc.policy_id = ph.policy_id
         AND pc.contact_policy_role_id = cpr.id
         AND ph.policy_id = pol.policy_id(+)
         AND pol.payment_term_id = trm.id(+)
         AND cont.contact_id(+) = pc.contact_id
         AND prod.product_id(+) = ph.product_id
         AND av.t_prod_line_option_id = opt.id(+)
         AND rl.ag_roll_id = par_ag_roll_id
            /**/
         AND av.epg_payment = epg_dso.parent_doc_id
         AND epg_dso.doc_set_off_id = d_dso.document_id
         AND d_dso.doc_status_ref_id = rf_dso.doc_status_ref_id
         AND rf_dso.brief != 'ANNULATED'
         AND epg_dso.child_doc_id = epg_pd.payment_id
         AND epg_pd.payment_id = pd_dd.parent_id(+)
         AND pd_dd.child_id = epg_pd_copy.payment_id(+)
         AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
         AND pd_dso.child_doc_id = pp_pd.payment_id(+)
         AND av.pd_payment = nvl(pp_pd.payment_id, epg_pd.payment_id)
         AND o.document_id = epg_dso.doc_set_off_id
         AND o.oper_id = tra.oper_id
         AND (tra.a4_ct_ure_id = 310 AND tra.a4_ct_uro_id = opt.id)
            /**/
         AND prod.brief IN ('PEPR'
                           ,'PEPR_2'
                           ,'PEPR_Old'
                           ,'END'
                           ,'END_2'
                           ,'END_Old'
                           ,'CHI'
                           ,'CHI_2'
                           ,'CHI_Old'
                           ,'TERM'
                           ,'TERM_2'
                           ,'TERM_Old')
         AND act.ag_perfomed_work_act_id IN
             (SELECT rlc.ag_perfomed_work_act_id
                FROM ins.rla_calc_agent rlc
               WHERE rlc.ag_roll_id = par_ag_roll_id)
         AND ph.fund_id = f.fund_id
      UNION ALL
      SELECT pol.pol_num num_pol
            ,cont.obj_name_orig holder
            ,decode(prod.description
                   ,'Защита и накопление для банка Ситисервис'
                   ,'Защита и накопление'
                   ,'Platinum Life Active_2 СитиСервис'
                   ,'Platinum Life Active'
                   ,prod.description) product
            ,decode(prod.description
                   ,'Защита и накопление для банка Ситисервис'
                   ,'Защита и накопление'
                   ,'Platinum Life Active_2 СитиСервис'
                   ,'Platinum Life Active'
                   ,prod.description) risk_name
            ,av.pay_period
            ,av.ins_period
            ,to_char(av.payment_date_orig, 'DD.MM.YYYY') payment_date
            ,SUM(CASE
                   WHEN nvl(vol.vol_amount, 0) > 0 THEN
                    nvl(vol.vol_amount, 0)
                   ELSE
                    0
                 END) prem_pay_number
            ,SUM(CASE
                   WHEN nvl(vol.vol_amount, 0) < 0 THEN
                    nvl(abs(vol.vol_amount), 0)
                   ELSE
                    0
                 END) prem_back
            ,to_char(ROUND(nvl(vol.vol_rate, 0), 2) * 100, '99999990D99') || '%' vol_rate
            ,SUM(CASE
                   WHEN nvl(vol.vol_amount, 0) > 0 THEN
                    (nvl(vol.vol_amount, 0) * nvl(vol.vol_rate, 0))
                   ELSE
                    0
                 END) com_pay_number
            ,SUM(CASE
                   WHEN nvl(vol.vol_amount, 0) < 0 THEN
                    (nvl(abs(vol.vol_amount), 0) * nvl(vol.vol_rate, 0))
                   ELSE
                    0
                 END) com_back
            ,av.epg_date
            ,trm.description period_name
            ,CASE
               WHEN f.brief = 'RUR' THEN
                ''
               ELSE
                f.brief
             END fund_brief
            ,ph.ids
            ,acc.get_cross_rate_by_brief(1, 'RUR', f.brief, av.payment_date_orig) usd_rate
            ,epg_dso.set_off_rate usd_rate_op
            ,epg_dso.set_off_amount usd_sum_op
            ,TRIM(epg_pd.num) epg_pd_num
            ,epg_dso.set_off_child_amount
        FROM ins.ag_roll_header       rh
            ,ins.ag_roll              rl
            ,ins.ag_roll_type         tr
            ,ins.ag_perfomed_work_act act
            ,ins.ag_perfom_work_det   det
            ,ins.ag_rate_type         rt
            ,ins.ag_perf_work_vol     vol
            ,ins.ag_volume            av
            ,ins.p_pol_header         ph
            ,ins.document             d
            ,ins.t_contact_pol_role   cpr
            ,ins.p_policy_contact     pc
            ,ins.contact              cont
            ,ins.t_product            prod
            ,ins.t_prod_line_option   opt
            ,ins.p_policy             pol
            ,ins.t_payment_terms      trm
            ,ins.fund                 f
            ,
             /**/ins.doc_set_off    epg_dso
            ,ins.document       d_dso
            ,ins.doc_status_ref rf_dso
            ,ins.ven_ac_payment epg_pd
            ,ins.doc_doc        pd_dd
            ,ins.ac_payment     epg_pd_copy
            ,ins.doc_set_off    pd_dso
            ,ins.ac_payment     pp_pd
       WHERE rh.ag_roll_header_id = rl.ag_roll_header_id
         AND rh.ag_roll_type_id = tr.ag_roll_type_id
         AND act.ag_roll_id(+) = rl.ag_roll_id
         AND det.ag_perfomed_work_act_id(+) = act.ag_perfomed_work_act_id
         AND det.ag_rate_type_id = rt.ag_rate_type_id
         AND rt.brief = 'GET_FIRST_RLA'
         AND vol.ag_perfom_work_det_id(+) = det.ag_perfom_work_det_id
         AND av.ag_volume_id(+) = vol.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id(+)
         AND ph.policy_header_id = d.document_id(+)
         AND cpr.brief = 'Страхователь'
         AND pc.policy_id = ph.policy_id
         AND pc.contact_policy_role_id = cpr.id
         AND ph.policy_id = pol.policy_id(+)
         AND pol.payment_term_id = trm.id(+)
         AND cont.contact_id(+) = pc.contact_id
         AND prod.product_id(+) = ph.product_id
         AND av.t_prod_line_option_id = opt.id(+)
         AND rl.ag_roll_id = par_ag_roll_id
            /**/
         AND av.epg_payment = epg_dso.parent_doc_id
         AND epg_dso.doc_set_off_id = d_dso.document_id
         AND d_dso.doc_status_ref_id = rf_dso.doc_status_ref_id
         AND rf_dso.brief != 'ANNULATED'
         AND epg_dso.child_doc_id = epg_pd.payment_id
         AND epg_pd.payment_id = pd_dd.parent_id(+)
         AND pd_dd.child_id = epg_pd_copy.payment_id(+)
         AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
         AND pd_dso.child_doc_id = pp_pd.payment_id(+)
         AND av.pd_payment = nvl(pp_pd.payment_id, epg_pd.payment_id)
            /**/
         AND prod.brief NOT IN ('PEPR'
                               ,'PEPR_2'
                               ,'PEPR_Old'
                               ,'END'
                               ,'END_2'
                               ,'END_Old'
                               ,'CHI'
                               ,'CHI_2'
                               ,'CHI_Old'
                               ,'TERM'
                               ,'TERM_2'
                               ,'TERM_Old')
         AND act.ag_perfomed_work_act_id IN
             (SELECT rlc.ag_perfomed_work_act_id
                FROM ins.rla_calc_agent rlc
               WHERE rlc.ag_roll_id = par_ag_roll_id)
         AND ph.fund_id = f.fund_id
       GROUP BY pol.pol_num
               ,cont.obj_name_orig
               ,prod.description
               ,av.pay_period
               ,av.ins_period
               ,av.payment_date_orig
               ,vol.vol_rate
               ,av.epg_date
               ,trm.description
               ,f.brief
               ,ph.ids
               ,epg_dso.set_off_rate
               ,epg_dso.set_off_amount
               ,epg_pd.num
               ,epg_dso.set_off_child_amount;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_forms_message.put_message('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Ошибка формирования списка полисов для РАСЧЕТА.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name ||
                              'Внимание! Ошибка формирования списка полисов для РАСЧЕТА.');
  END rla_calculation_pol;
  /**/

  /*
    Пиядин А. 301732 ТЗ Финмониторинг
    Функция возвращает id идентифицирующего документа в
    соответствии с требованиями отчета "Анкета финмониторинг"
  
    @ par_contact_id    - id контакта
    @ par_pol_sign_date - дата подписания ДС
  */
  FUNCTION get_finmon_ident_id
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_pol_sign_date p_policy.sign_date%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE IS
    v_date_of_birth cn_person.date_of_birth%TYPE;
    v_result        cn_contact_ident.table_id%TYPE := NULL;
  BEGIN
    SELECT nvl(cp.date_of_birth, SYSDATE)
      INTO v_date_of_birth
      FROM contact   c
          ,cn_person cp
     WHERE c.contact_id = cp.contact_id(+)
       AND c.contact_id = par_contact_id;
  
    CASE
      WHEN FLOOR(MONTHS_BETWEEN(par_pol_sign_date, v_date_of_birth) / 12) < 14 THEN
        v_result := coalesce(pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id, 'BIRTH_CERT')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id
                                                                       ,'BIRTH_CERT_IN')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id
                                                                       ,'RESIDENCE_PERMIT')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id
                                                                       ,'MIGRATION_CARD'));
      ELSE
        v_result := coalesce(pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id, 'PASS_RF')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id, 'PASS_SSSR')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id, 'PASS_IN')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id
                                                                       ,'RESIDENCE_PERMIT')
                            ,pkg_contact_rep_utils.get_last_doc_by_type(par_contact_id
                                                                       ,'MIGRATION_CARD'));
    END CASE;
  
    RETURN v_result;
  END get_finmon_ident_id;

  /*
    Капля П.С.
    23.05.2014
    Добавление подписанта в отчет
  */
  PROCEDURE register_signer_for_report
  (
    par_report_exe_name     rep_report.exe_name%TYPE
   ,par_signer_contact_name t_signer.contact_name%TYPE
  ) IS
    v_rep_report_id rep_report.rep_report_id%TYPE;
    v_signer_id     t_signer.t_signer_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_signer_id INTO v_signer_id FROM t_signer WHERE contact_name = par_signer_contact_name;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не удалось определить подписанта по имени: ' || par_signer_contact_name);
    END;
  
    -- ИД отчета
    BEGIN
      SELECT rep_report_id INTO v_rep_report_id FROM rep_report WHERE exe_name = par_report_exe_name;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не удалось определить отчет');
    END;
  
    dml_t_report_signer.insert_record(par_t_signer_id => v_signer_id
                                     ,par_report_id   => v_rep_report_id);
  END register_signer_for_report;

END;
/
