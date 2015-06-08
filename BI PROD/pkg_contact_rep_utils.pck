CREATE OR REPLACE PACKAGE pkg_contact_rep_utils IS

  -- Author  : PAZUS
  -- Created : 10.11.2013 17:44:26
  -- Purpose : Набор функций для печати данных контакта

  SUBTYPE typ_mask IS VARCHAR2(1000);

  gc_mask_doc_type_description CONSTANT typ_mask := '<#TYPE_DESC>'; -- Тип документа
  gc_mask_doc_number           CONSTANT typ_mask := '<DOC_NUM>'; -- Номер документа
  gc_mask_doc_series           CONSTANT typ_mask := '<#DOC_SER>'; -- Серия документа
  gc_mask_doc_series_number    CONSTANT typ_mask := '<#DOC_SERNUM>'; -- Номер и сери документа через пробел
  gc_mask_doc_place_of_issue   CONSTANT typ_mask := '<#DOC_PLACE>'; -- Место выдачи документа
  gc_mask_doc_issue_date       CONSTANT typ_mask := '<#DOC_DATE>'; -- Дата выдачи документа
  gc_mask_doc_subdivision_code CONSTANT typ_mask := '<#SUBDIVISION_CODE>'; -- Код подразделения
  -- Стандартное написание для документа:
  -- Тип, серия номер, Выдан: место выдачи Дата: дата выдачи
  gc_defalt_doc_mask CONSTANT typ_mask := gc_mask_doc_type_description || ' ' ||
                                          gc_mask_doc_series_number || ' Выдан: ' ||
                                          gc_mask_doc_place_of_issue || ' Дата выдачи: ' ||
                                          gc_mask_doc_issue_date;

  gc_address_full              CONSTANT typ_mask := '<#ADDRESS_FULL>'; -- Полный адрес
  gc_address_name              CONSTANT typ_mask := '<#ADDRESS_NAME>'; -- Адрес по полю name из cn_address
  gc_address_type              CONSTANT typ_mask := '<#ADDRESS_TYPE>'; -- Тип адреса
  gc_address_no_zip            CONSTANT typ_mask := '<#ADDRESS_NO_ZIP>'; --Адрес без индекса
  gc_address_province          CONSTANT typ_mask := '<#ADDRESS_PROVINCE>'; --Регион/область
  gc_address_city              CONSTANT typ_mask := '<#ADDRESS_CITY>'; --Город/населенный пункт
  gc_address_street_with_house CONSTANT typ_mask := '<#ADDRESS_STREET_WITH_HOUSE>'; --Улица/дом/корпус/квартира/офис
  gc_address_zip               CONSTANT typ_mask := '<#ADDRESS_ZIP>'; --Индекс

  gc_mask_email       CONSTANT typ_mask := '<#EMAIL>'; -- email
  gc_mask_email_upper CONSTANT typ_mask := '<#EMAIL_UPPER>'; -- email заглавными буквами
  gc_mask_email_lower CONSTANT typ_mask := '<#EMAIL_LOWER>'; -- email строчными буквами

  gc_company_name    CONSTANT typ_mask := '<#NAME>'; --Название компании
  gc_company_address CONSTANT typ_mask := '<#ADDRESS>'; -- Адрес компании
  gc_company_phone   CONSTANT typ_mask := '<#PHONE>'; -- Телефон компании
  gc_company_fax     CONSTANT typ_mask := '<#FAX>'; -- Факс компании
  gc_company_okpo    CONSTANT typ_mask := '<#OKPO>'; -- ОКПО компании
  gc_company_ogrn    CONSTANT typ_mask := '<#OGRN>'; -- ИГРН компании
  gc_company_inn     CONSTANT typ_mask := '<#INN>'; -- ИНН компании
  gc_company_kpp     CONSTANT typ_mask := '<#KPP>'; -- КПП компании
  gc_company_rs      CONSTANT typ_mask := '<#RS>'; -- Расчетвый счет компании
  gc_company_bank    CONSTANT typ_mask := '<#BANK>'; -- Банк компании
  gc_company_city    CONSTANT typ_mask := '<#CITY>'; -- Город
  gc_company_bik     CONSTANT typ_mask := '<#BIK>'; -- БИК компании
  gc_company_ks      CONSTANT typ_mask := '<#KS>'; -- Корр. счет компании
  gc_company_license CONSTANT typ_mask := '<#LICENSE>'; -- Номер лицензии
  gc_company_website CONSTANT typ_mask := '<#WEBSITE>'; -- Сайт компании

  gc_company_default_billing CONSTANT typ_mask := '<#DEFAULT_BILLING_INFO>'; -- Банковская информация о компании
  gc_company_nameaddr        CONSTANT typ_mask := '<#DEFAULT_NAME_ADDR>'; -- Адрес компании
  gc_company_def_phones      CONSTANT typ_mask := '<#DEFAULT_PHONES>'; -- Телефоны компании
  gc_company_def_info        CONSTANT typ_mask := '<#DEFAULT_INFO>'; -- Полная информация о компании

  gc_bank_info_account_nr     CONSTANT typ_mask := '<#ACCOUNT_NR>'; -- № счета
  gc_bank_info_iban           CONSTANT typ_mask := '<#IBAN>'; -- ИБАН
  gc_bank_info_swift_code     CONSTANT typ_mask := '<#SWIFT_CODE>'; -- СВИФТ
  gc_bank_info_appr_ref       CONSTANT typ_mask := '<#APPROVAL_REFERENCE>'; -- Номер домициляции
  gc_bank_info_appr_date      CONSTANT typ_mask := '<#BANK_APPROVAL_DATE>'; -- Дата домициляции
  gc_bank_info_appr_end_date  CONSTANT typ_mask := '<#BANK_APPROVAL_END_DATE>'; -- Дата окончания домициляции
  gc_bank_info_bik            CONSTANT typ_mask := '<#BIK>'; -- Дата окончания домициляции
  gc_bank_info_account_corr   CONSTANT typ_mask := '<#ACCOUNT_CORR>'; -- № корреспондентского счета
  gc_bank_info_lic_code       CONSTANT typ_mask := '<#LIC_CODE>'; -- № лицевого счета
  gc_bank_info_place_of_issue CONSTANT typ_mask := '<#PLACE_OF_ISSUE>'; -- Место выдачи банковской карты
  gc_bank_info_bank_id        CONSTANT typ_mask := '<#BANK_ID>'; -- ИД Банка
  gc_bank_info_bank_name      CONSTANT typ_mask := '<#BANK_NAME>'; -- Название Банка

  /*
    Капля П.
    Получаем фамилию и инициалы по контакту
  */
  FUNCTION get_contact_fio_initials(par_contact_id contact.contact_id%TYPE)
    RETURN contact.obj_name_orig%TYPE;

  ---------------------
  ------ДОКУМЕНТЫ------
  ---------------------
  /*
    Капля П.
    Выбирает ИД последнего добавленного документа с типом с признаком "Идентифицирующий документ"
  */
  FUNCTION get_last_ident_doc_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_ident.table_id%TYPE;

  /*
    Капля П.
    Выбирает ИД последнего добавленного документа по типу
  */
  FUNCTION get_last_doc_by_type
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE;

  /**
  * Выбирает ИД документаm аналогично тому, как это делается в pkg_contact
  * Сортировка выбрана давольно странная, тем не менее это основная функция получения
  * документа контакта
  *  ORDER BY nvl(cn_contact_ident.is_default, 0) DESC
  *           ,t_id_type.sort_order
  *
  * @author Капля П.
  * @param par_contact_id ИД контакта
  * @return ИД объекта сущности Идентификатор контакта
  */
  FUNCTION get_primary_doc_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_ident.table_id%TYPE;

  /**
  * Получение ИД действующего идентифицирющего документа
  * Отбираются незаконченные документы, с лагом "идентифицирующий" на типе документа
  * Сначала сортируем по "Порядку сортировки" у типа документа,
  * потом по флагу Исользуется (is_used), потом по ИД сортировка по убыванию
  * @author Капля П.
  * @param par_contact_id ИД контакта
  * @return ИД объекта сущности Идентификатор контакта
  */
  FUNCTION get_active_ident_doc_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_ident.table_id%TYPE;

  /**
  * Получение ИД наиболее актуального документа указанного типа
  * @author Капля П.
  * @param par_contact_id ИД объекта сущности Контакт
  * @param par_doc_type_brief  Бриф типа документа
  * @return ИД объекта сущности Идентификатор контакта
  */
  FUNCTION get_most_active_doc_id
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE;

  /**
  * Получение ИД наиболее последнего документа указанного типа с призанком "Использующийся тип документа"
  * @author Капля П.
  * @param par_contact_id ИД объекта сущности Контакт
  * @param par_doc_type_brief  Бриф типа документа
  * @return ИД объекта сущности Идентификатор контакта
  */
  FUNCTION get_last_active_doc_id
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE;

  /*
    Капля П.
    Вывод форматированного по маске паспорта
    Форматирование с использованием глобальных констант, описанных в спецификации пакета
  */
  FUNCTION format_ident_doc_by_mask
  (
    par_contact_ident_doc_id cn_contact_ident.table_id%TYPE
   ,par_mask                 VARCHAR2
  ) RETURN VARCHAR2;

  ---------------------
  ------ТЕЛЕФОНЫ-------
  ---------------------
  /*
    Капля П.
    Выбираем последний добавленный действующий телефонный номер по типу, либо среди всех
  */
  FUNCTION get_last_active_phone_id
  (
    par_contact_id       contact.contact_id%TYPE
   ,par_phone_type_brief t_telephone_type.brief%TYPE DEFAULT NULL
  ) RETURN cn_contact_telephone.id%TYPE;

  /*
    Капля П.
    Выбираем телефон, отсортированный по приоритету типа телефона
    В рамках одного типа то более нового к более старому
  */
  FUNCTION get_primary_phone_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_telephone.id%TYPE;

  /*
    Капля П.
    Выбираем действующий телефон, отсортированный по приоритету типа телефона
    В рамках одного типа то более нового к более старому
  */
  FUNCTION get_active_primary_phone_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_telephone.id%TYPE;

  /*
    Капля П.
    Выбираем последний действующий телефон заданного типа
  */
  FUNCTION get_last_phone_id_by_type
  (
    par_contact_id           contact.contact_id%TYPE
   ,par_telephone_type_brief t_telephone_type.brief%TYPE
  ) RETURN cn_contact_telephone.id%TYPE;

  /*
    Капля П.
    Получаем телефон по ID.
    Если телефон из 10 цифр, то выводим с +(код страны), иначе просто выводим телефон
    Дописывая в начале и конце префикс и добавочный
  */
  FUNCTION get_phone_number_by_id(par_contact_phone_id cn_contact_telephone.id%TYPE) RETURN VARCHAR2;

  ---------------------
  --------АДРЕСА-------
  ---------------------

  /**
  * Получение максимального ИД адреса по умолчанию для контакта
  * @author Пиядин А.
  * @param par_contact_id - ИД контакта
  * @par_brief - бриф типа адреса
  * @return ИД адреса контакта
  */
  FUNCTION get_last_active_address_id
  (
    par_contact_id contact.contact_id%TYPE
   ,par_brief      t_address_type.brief%TYPE DEFAULT NULL
  ) RETURN cn_contact_address.id%TYPE;

  /**
  * Получение ИД адреса определенного типа для контакта
  * @author Чирков В.
  * @param par_contact_id - ИД контакта
  * @par_brief - бриф типа адреса
  * @return Ид адреса контакта
  */
  FUNCTION get_address_id_by_type
  (
    par_contact_id         contact.contact_id%TYPE
   ,par_address_type_brief t_address_type.brief%TYPE
  ) RETURN cn_contact_address.adress_id%TYPE;
  /*
    Капля П.
    Скопирован старый алгоритм определения почтового адреса
  */
  FUNCTION get_letters_address_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_address.adress_id%TYPE;

  /*
    Капля П.
    Получение адреса по id и маске
  */
  FUNCTION get_address_by_mask
  (
    par_contact_address_id cn_contact_address.id%TYPE
   ,par_mask               VARCHAR2
  ) RETURN cn_address.name%TYPE;

  /*
    Капля П.
    Получение адреса по id и маске по умолчанию
  */
  FUNCTION get_address(par_contact_address_id cn_contact_address.id%TYPE) RETURN cn_address.name%TYPE;

  ---------------------
  --------EMAIL--------
  ---------------------

  /**
  * Получение максимального действующего email контакта
  * @author Пиядин А.
  * @param par_contact_id - ИД контакта
  * @param par_description - тип адреса
  * @return ИД e-mail'а контакта
  */
  FUNCTION get_last_active_email_id
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_description t_email_type.description%TYPE DEFAULT NULL
  ) RETURN cn_contact_email.id%TYPE;

  /*
    Капля П.
    Получение значение email по id и маске
  */
  FUNCTION get_email_by_mask
  (
    par_contact_email_id cn_contact_email.id%TYPE
   ,par_mask             VARCHAR2
  ) RETURN cn_contact_email.email%TYPE;

  /*
    Капля П.
    Получение значения email по id
  */
  FUNCTION get_email(par_contact_email_id cn_contact_email.id%TYPE) RETURN cn_contact_email.email%TYPE;

  ------------------------------
  --------БАНКОВСКИЕ ДОК.-------
  ------------------------------

  /*
    Получение последней записи банковских реквизитов с установленным флагом Используется
    @author Капля П.
    @param par_contact_id ИД контакта
    @return ИД объекта сущности Банковский счет контакта
  */
  FUNCTION get_max_active_bank_acc_id(par_contact_id NUMBER) RETURN cn_contact_bank_acc.id%TYPE;

  /**
  * Получение наиболее актуальной записи банковских реквизитов
  * Сначала пытаемся найти среди записе с установленным флагом Используется, потом без флага
  * Внутри значения флага сортируем по ИД по убыванию
  * @author Капля П.
  * @param par_contact_id ИД контакта
  * @return ИД объекта сущности Банковский счет контакта
  */
  FUNCTION get_most_recent_bank_acc_id(par_contact_id NUMBER) RETURN cn_contact_bank_acc.id%TYPE;

  /**
  * Получение банковских реквизитов в соответствие с Маской
  * @author Капля П.
  * @param par_bank_acc_id ИД банковского реквизита
  * @param par_mask Макса для формирвоаиня итогового результата
  * @return Информация о банковском реквизити в соответствие с маской
  */
  FUNCTION get_bank_acc_by_mask
  (
    par_bank_acc_id cn_contact_bank_acc.id%TYPE
   ,par_mask        VARCHAR2
  ) RETURN VARCHAR2;

  ---------------------------------
  --------ИНФА СТРАХОВАТЕЛЯ--------
  ---------------------------------

  /*
    Капля П.
    Функция получает инфу о компании по маске.
  */
  FUNCTION get_insurer_info(par_mask VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END pkg_contact_rep_utils;
/
CREATE OR REPLACE PACKAGE BODY pkg_contact_rep_utils IS

  gc_pkg_name CONSTANT VARCHAR2(30) := 'PKG_CONTACT_REP_UTILS';

  SUBTYPE t_contact_id_full_number IS VARCHAR(1000);

  FUNCTION get_contact_fio_initials(par_contact_id contact.contact_id%TYPE)
    RETURN contact.obj_name_orig%TYPE IS
    v_fio_initials contact.obj_name_orig%TYPE;
    v_name         contact.name%TYPE;
    v_first_name   contact.first_name%TYPE;
    v_middle_name  contact.middle_name%TYPE;
  
    vc_proc_name CONSTANT VARCHAR2(30) := 'get_contact_fio_initials';
  BEGIN
    SELECT c.name
          ,first_name
          ,middle_name
      INTO v_name
          ,v_first_name
          ,v_middle_name
      FROM contact c
     WHERE c.contact_id = par_contact_id;
  
    v_fio_initials := v_name;
  
    IF v_first_name IS NOT NULL
    THEN
      v_fio_initials := v_fio_initials || ' ' || substr(v_first_name, 1, 1) || '.';
    END IF;
  
    IF v_middle_name IS NOT NULL
    THEN
      v_fio_initials := v_fio_initials || ' ' || substr(v_middle_name, 1, 1) || '.';
    END IF;
  
    RETURN v_fio_initials;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'В функцию ' || gc_pkg_name || '.' || vc_proc_name ||
                              ' передан несуществующий ИД контакта');
  END get_contact_fio_initials;

  ---------------------
  ------ДОКУМЕНТЫ------
  ---------------------
  /*
    Капля П.
    Выбирает ИД последнего добавленного документа с типом с признаком "Идентифицирующий документ"
  */
  FUNCTION get_last_ident_doc_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
  
    SELECT MAX(cci.table_id)
      INTO v_ident_doc_id
      FROM cn_contact_ident cci
          ,t_id_type        it
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = it.id
       AND it.is_identification_document = 1;
  
    RETURN v_ident_doc_id;
  
  END get_last_ident_doc_id;

  /*
    Капля П.
    Выбирает ИД последнего добавленного документа по типу
  */
  FUNCTION get_last_doc_by_type
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
    SELECT MAX(cci.table_id)
      INTO v_ident_doc_id
      FROM cn_contact_ident cci
          ,t_id_type        it
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = it.id
       AND it.brief = par_doc_type_brief;
  
    RETURN v_ident_doc_id;
  
  END get_last_doc_by_type;

  /*
    Капля П.
    Выбирает ИД документаm аналогично тому, как это делается в pkg_contact
    ORDER BY nvl(cn_contact_ident.is_default, 0) DESC
             ,t_id_type.sort_order
  */
  FUNCTION get_primary_doc_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
    SELECT MAX(cci.table_id) keep(dense_rank FIRST ORDER BY nvl(cci.is_default, 0) DESC, tit.sort_order)
      INTO v_ident_doc_id
      FROM cn_contact_ident cci
          ,t_id_type        tit
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = tit.id;
  
    RETURN v_ident_doc_id;
  
  END get_primary_doc_id;

  FUNCTION get_active_ident_doc_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
    SELECT MAX(cci.table_id) keep(dense_rank FIRST ORDER BY tit.sort_order, nvl(cci.is_used, 0) DESC)
      INTO v_ident_doc_id
      FROM cn_contact_ident cci
          ,t_id_type        tit
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = tit.id
       AND cci.termination_date IS NULL
       AND tit.is_identification_document = 1;
  
    RETURN v_ident_doc_id;
  
  END get_active_ident_doc_id;

  FUNCTION get_most_active_doc_id
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
    SELECT MAX(cci.table_id) keep(dense_rank FIRST ORDER BY cci.is_default DESC NULLS LAST)
      INTO v_ident_doc_id
      FROM cn_contact_ident cci
          ,t_id_type        it
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = it.id
       AND it.brief = par_doc_type_brief
       AND cci.termination_date IS NULL;
  
    RETURN v_ident_doc_id;
  
  END get_most_active_doc_id;

  FUNCTION get_last_active_doc_id
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
  
    SELECT MAX(cci.table_id)
      INTO v_ident_doc_id
      FROM cn_contact_ident cci
          ,t_id_type        it
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = it.id
       AND it.brief = par_doc_type_brief
       AND cci.is_used = 1
       AND cci.termination_date IS NULL;
  
    RETURN v_ident_doc_id;
  
  END get_last_active_doc_id;

  /*
    Капля П.
    Вывод форматированного по маске паспорта
    Форматирование с использованием глобальных констант, описанных в спецификации пакета
  */
  FUNCTION format_ident_doc_by_mask
  (
    par_contact_ident_doc_id cn_contact_ident.table_id%TYPE
   ,par_mask                 VARCHAR2
  ) RETURN VARCHAR2 IS
    v_ident_doc_string VARCHAR2(1500) := NULL;
    v_id_series_number t_contact_id_full_number;
    v_id_number        cn_contact_ident.id_value%TYPE;
    v_id_series        cn_contact_ident.serial_nr%TYPE;
    v_issue_date       cn_contact_ident.issue_date%TYPE;
    v_place_of_issue   cn_contact_ident.place_of_issue%TYPE;
    v_doc_type_name    t_id_type.description%TYPE;
    v_subdivision_code cn_contact_ident.subdivision_code%TYPE;
  BEGIN
    IF par_contact_ident_doc_id IS NOT NULL
    THEN
      SELECT decode(serial_nr, NULL, id_value, serial_nr || '-' || id_value)
            ,cci.id_value
            ,cci.serial_nr
            ,issue_date
            ,place_of_issue
            ,it.description
            ,cci.subdivision_code
        INTO v_id_series_number
            ,v_id_number
            ,v_id_series
            ,v_issue_date
            ,v_place_of_issue
            ,v_doc_type_name
            ,v_subdivision_code
        FROM cn_contact_ident cci
            ,t_id_type        it
       WHERE cci.table_id = par_contact_ident_doc_id
         AND cci.id_type = it.id;
    
      v_ident_doc_string := par_mask;
    
      v_ident_doc_string := REPLACE(v_ident_doc_string, gc_mask_doc_type_description, v_doc_type_name);
      v_ident_doc_string := REPLACE(v_ident_doc_string, gc_mask_doc_number, v_id_number);
      v_ident_doc_string := REPLACE(v_ident_doc_string, gc_mask_doc_series, v_id_series);
      v_ident_doc_string := REPLACE(v_ident_doc_string, gc_mask_doc_series_number, v_id_series_number);
      v_ident_doc_string := REPLACE(v_ident_doc_string, gc_mask_doc_place_of_issue, v_place_of_issue);
      v_ident_doc_string := REPLACE(v_ident_doc_string
                                   ,gc_mask_doc_issue_date
                                   ,to_char(v_issue_date, 'dd.mm.yyyy'));
      v_ident_doc_string := REPLACE(v_ident_doc_string
                                   ,gc_mask_doc_subdivision_code
                                   ,v_subdivision_code);
    END IF;
  
    RETURN v_ident_doc_string;
  
  END format_ident_doc_by_mask;

  ---------------------
  ------ТЕЛЕФОНЫ-------
  ---------------------
  /* 
    Капля П.
    Выбираем последний добавленный действующий телефонный номер по типу, либо среди всех 
  */
  FUNCTION get_last_active_phone_id
  (
    par_contact_id       contact.contact_id%TYPE
   ,par_phone_type_brief t_telephone_type.brief%TYPE DEFAULT NULL
  ) RETURN cn_contact_telephone.id%TYPE IS
    v_telephone_id cn_contact_telephone.id%TYPE;
  BEGIN
    IF par_phone_type_brief IS NOT NULL
    THEN
      SELECT MAX(cct.id)
        INTO v_telephone_id
        FROM cn_contact_telephone cct
            ,t_telephone_type     ttt
       WHERE cct.contact_id = par_contact_id
         AND cct.telephone_type = ttt.id
         AND ttt.brief = par_phone_type_brief
         AND cct.status = 1;
    ELSE
      SELECT MAX(cct.id)
        INTO v_telephone_id
        FROM cn_contact_telephone cct
       WHERE cct.contact_id = par_contact_id
         AND cct.status = 1;
    END IF;
    RETURN v_telephone_id;
  END get_last_active_phone_id;

  /* 
    Капля П.
    Выбираем телефон, отсортированный по приоритету типа телефона
    В рамках одного типа то более нового к более старому
  */
  FUNCTION get_primary_phone_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_telephone.id%TYPE IS
    v_telephone_id cn_contact_telephone.id%TYPE;
  BEGIN
    SELECT id
      INTO v_telephone_id
      FROM (SELECT cct.id
              FROM cn_contact_telephone cct
                  ,t_telephone_type     tt
             WHERE cct.telephone_type = tt.id
               AND cct.contact_id = par_contact_id
             ORDER BY cct.status    DESC NULLS LAST
                     ,tt.sort_order
                     ,cct.id        DESC)
     WHERE rownum = 1;
    RETURN v_telephone_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_primary_phone_id;

  /* 
    Капля П.
    Выбираем действующий телефон, отсортированный по приоритету типа телефона
    В рамках одного типа то более нового к более старому
  */
  FUNCTION get_active_primary_phone_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_telephone.id%TYPE IS
    v_telephone_id cn_contact_telephone.id%TYPE;
  BEGIN
    SELECT id
      INTO v_telephone_id
      FROM (SELECT cct.id
              FROM cn_contact_telephone cct
                  ,t_telephone_type     tt
             WHERE cct.telephone_type = tt.id
               AND cct.contact_id = par_contact_id
               AND cct.status = 1
             ORDER BY tt.sort_order
                     ,cct.id DESC)
     WHERE rownum = 1;
    RETURN v_telephone_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_active_primary_phone_id;

  /* 
    Капля П.
    Выбираем последний действующий телефон заданного типа 
  */
  FUNCTION get_last_phone_id_by_type
  (
    par_contact_id           contact.contact_id%TYPE
   ,par_telephone_type_brief t_telephone_type.brief%TYPE
  ) RETURN cn_contact_telephone.id%TYPE IS
    v_telephone_id cn_contact_telephone.id%TYPE;
  BEGIN
    SELECT id
      INTO v_telephone_id
      FROM (SELECT cct.id
              FROM cn_contact_telephone cct
                  ,t_telephone_type     tt
             WHERE cct.telephone_type = tt.id
               AND cct.contact_id = par_contact_id
               AND cct.status = 1
               AND tt.brief = par_telephone_type_brief
             ORDER BY cct.id DESC)
     WHERE rownum = 1;
    RETURN v_telephone_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_last_phone_id_by_type;

  /* 
    Капля П.
    Получаем телефон по ID.
    Если телефон из 10 цифр, то выводим с +(код страны), иначе просто выводим телефон
    Дописывая в начале и конце префикс и добавочный
  */
  FUNCTION get_phone_number_by_id(par_contact_phone_id cn_contact_telephone.id%TYPE) RETURN VARCHAR2 IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_PHONE_NUMBER_BY_ID';
    v_phone_number      cn_contact_telephone.telephone_number%TYPE;
    v_phone_number_pref cn_contact_telephone.telephone_prefix%TYPE;
    v_phone_number_ext  cn_contact_telephone.telephone_extension%TYPE;
    v_country_dail_code t_country_dial_code.description%TYPE;
  
    v_result_number VARCHAR2(255);
  
  BEGIN
    IF par_contact_phone_id IS NOT NULL
    THEN
      SELECT cct.telephone_number
            ,cct.telephone_prefix
            ,cct.telephone_extension
            ,cdc.description
        INTO v_phone_number
            ,v_phone_number_pref
            ,v_phone_number_ext
            ,v_country_dail_code
        FROM cn_contact_telephone cct
            ,t_country_dial_code  cdc
       WHERE cct.id = par_contact_phone_id
         AND cct.country_id = cdc.id(+);
    
      /*IF length(v_phone_number) = 10
      THEN
        v_result_number := '+' || v_country_dail_code;
      ELSE*/
      IF v_phone_number_pref IS NOT NULL
      THEN
        v_result_number := '(' || v_phone_number_pref || ')';
      END IF;
      --END IF;
      v_result_number := v_result_number || v_phone_number;
      IF v_phone_number_ext IS NOT NULL
      THEN
        v_result_number := v_result_number || '(доб. ' || v_phone_number_ext || ')';
      END IF;
    END IF;
  
    RETURN v_result_number;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'В функцию ' || vc_proc_name || ' передан несуществующий ID');
  END get_phone_number_by_id;

  /*
  -------------------------------------
  Работа с адресами
  -------------------------------------
  */
  /*
    @author Пиядин А.
    
    Получение максимального ИД адреса по умолчанию для контакта
    @param par_contact_id - ИД контакта
    @par_brief - бриф типа адреса
  */
  FUNCTION get_last_active_address_id
  (
    par_contact_id contact.contact_id%TYPE
   ,par_brief      t_address_type.brief%TYPE DEFAULT NULL
  ) RETURN cn_contact_address.id%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_LAST_ACTIVE_ADDRESS_ID';
    v_ret_val NUMBER;
  BEGIN
  
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_ADDRESS_ID'
                          ,par_trace_var_value => par_contact_id);
    pkg_trace.add_variable(par_trace_var_name => 'PAR_BRIEF', par_trace_var_value => par_brief);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    --333540 Перевод функций работы с адресами пакета pkg_contact_rep_utils с cn_address на cn_contact_address 
    SELECT MAX(ca.id)
      INTO v_ret_val
      FROM cn_contact_address ca
          ,t_address_type     tat
     WHERE ca.contact_id = par_contact_id
       AND ca.address_type = tat.id
       AND tat.brief = nvl(par_brief, tat.brief)
       AND ca.status = 1
       AND TRIM(pkg_contact.get_address_name(ca.adress_id)) IS NOT NULL;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_ret_val);
  
    RETURN v_ret_val;
  END get_last_active_address_id;

  /*  Получение ИД адреса определенного типа для контакта
  *  @author Чирков В.
  *  @param par_contact_id - ИД контакта
  *  @par_brief - бриф типа адреса
  */
  FUNCTION get_address_id_by_type
  (
    par_contact_id         contact.contact_id%TYPE
   ,par_address_type_brief t_address_type.brief%TYPE
  ) RETURN cn_contact_address.adress_id%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_LAST_ADDRESS_ID_BY_TYPE';
    v_ret_val NUMBER;
  BEGIN
  
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_ADDRESS_ID'
                          ,par_trace_var_value => par_contact_id);
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_ADDRESS_TYPE_BRIEF'
                          ,par_trace_var_value => par_address_type_brief);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    SELECT adress_id
      INTO v_ret_val
      FROM (SELECT ca.adress_id
              FROM cn_contact_address ca
                  ,ins.t_address_type tat
             WHERE ca.contact_id = par_contact_id
               AND ca.address_type = tat.id
               AND pkg_contact.get_address_name(ca.adress_id) IS NOT NULL
               AND tat.brief = par_address_type_brief
             ORDER BY ca.status      DESC
                     ,tat.sort_order ASC
                     ,ca.adress_id   DESC)
     WHERE rownum = 1;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_ret_val);
  
    RETURN v_ret_val;
  END get_address_id_by_type;

  /*
    Капля П.
    Скопирован старый алгоритм определения почтового адреса
  */
  FUNCTION get_letters_address_id(par_contact_id contact.contact_id%TYPE)
    RETURN cn_contact_address.adress_id%TYPE IS
    v_addr_orig cn_contact_address.id%TYPE;
  BEGIN
    SELECT *
      INTO v_addr_orig
      FROM (SELECT ca.id
              FROM cn_contact_address ca
                  ,ins.t_address_type tat
             WHERE ca.contact_id = par_contact_id
               AND ca.address_type = tat.id
               AND tat.sort_order BETWEEN 1 AND 9998
             ORDER BY ca.status      DESC
                     ,tat.sort_order ASC
                     ,ca.adress_id   DESC)
     WHERE rownum = 1;
  
    RETURN v_addr_orig;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_letters_address_id;

  /*
    Капля П.
    Получение адреса по id и маске
  */
  FUNCTION get_address_by_mask
  (
    par_contact_address_id cn_contact_address.id%TYPE
   ,par_mask               VARCHAR2
  ) RETURN cn_address.name%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_ADDRESS_BY_MASK';
    v_return_string VARCHAR2(4000) := par_mask;
    v_address_name  cn_address.name%TYPE;
    v_address_full  cn_address.name%TYPE;
    v_address_type  t_address_type.description%TYPE;
    v_address_id    cn_address.id%TYPE;
    v_province_name          cn_address.province_name%TYPE; --область
    v_city_name              cn_address.city_name%TYPE; --город
    v_district_name          cn_address.district_name%TYPE; --населенный пункт
    v_region_name            cn_address.region_name%TYPE; --район
    v_street_name_with_house VARCHAR2(4000); --Улица с номером дома и т.д.
    v_zip                    cn_address.zip%TYPE; --Индекс
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_ADDRESS_ID'
                          ,par_trace_var_value => par_contact_address_id);
    pkg_trace.add_variable(par_trace_var_name => 'PAR_MASK', par_trace_var_value => par_mask);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    assert_deprecated(par_mask IS NULL, 'Маска адреса не может быть пустой');
  
    SELECT at.description
          ,cca.adress_id
      INTO v_address_type
          ,v_address_id
      FROM cn_contact_address cca
          ,t_address_type     at
     WHERE cca.id = par_contact_address_id
       AND cca.address_type = at.id;
  
    SELECT ca.name
          ,pkg_contact.get_address_name(ca.id)
          ,ca.province_type || nvl2(ca.province_type, '. ', NULL) || ca.province_name
          ,ca.city_type || nvl2(ca.city_type, '. ', NULL) || ca.city_name
          ,ca.district_type || nvl2(ca.district_type, '. ', NULL) || ca.district_name
          ,ca.region_type || nvl2(ca.region_type, '. ', NULL) || ca.region_name
          ,substr(pkg_contact.get_address_name(NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,NULL
                                              ,ca.street_name
                                              ,ca.street_type
                                              ,ca.house_type
                                              ,ca.house_nr
                                              ,ca.block_number
                                              ,ca.box_number
                                              ,ca.appartment_nr
                                              ,ca.house_type)
                 ,3)
          ,ca.zip
      INTO v_address_name
          ,v_address_full
          ,v_province_name
          ,v_city_name
          ,v_district_name
          ,v_region_name
          ,v_street_name_with_house
          ,v_zip
      FROM cn_address ca
     WHERE connect_by_isleaf = 1
     START WITH id = v_address_id
    CONNECT BY PRIOR ca.id = ca.parent_addr_id;
  
    v_return_string := REPLACE(v_return_string, gc_address_full, v_address_full);
    v_return_string := REPLACE(v_return_string, gc_address_name, v_address_name);
    v_return_string := REPLACE(v_return_string, gc_address_type, v_address_type);
    v_return_string := REPLACE(v_return_string
                              ,gc_address_no_zip
                              ,regexp_replace(v_address_full, '^\d*,\s*')); --Адрес без индекса
    v_return_string := REPLACE(v_return_string, gc_address_province, v_province_name); --регион/область
    v_return_string := REPLACE(v_return_string, gc_address_city, nvl(v_city_name, v_district_name)); --город/населенный пункт
    v_return_string := REPLACE(v_return_string, gc_address_street_with_house, v_street_name_with_house); --Улица
    v_return_string := REPLACE(v_return_string, gc_address_zip, v_zip); --Индекс
  
    pkg_trace.trace_function_end(par_trace_obj_name    => vc_proc_name
                                ,par_trace_subobj_name => v_return_string);
  
    RETURN v_return_string;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_address_by_mask;

  /*
    Капля П.
    Получение адреса по id и маске по умолчанию
  */
  FUNCTION get_address(par_contact_address_id cn_contact_address.id%TYPE) RETURN cn_address.name%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_ADDRESS';
    v_address cn_address.name%TYPE;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_ADDRESS_ID'
                          ,par_trace_var_value => par_contact_address_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_address := get_address_by_mask(par_contact_address_id => par_contact_address_id
                                    ,par_mask               => gc_address_full);
  
    pkg_trace.trace_function_end(par_trace_obj_name    => vc_proc_name
                                ,par_trace_subobj_name => v_address);
  
    RETURN v_address;
  END get_address;

  /*
  -------------------------------------
  Работа с email'ами
  -------------------------------------
  */

  /*
    @author Пиядин А.
    
    Получение максимального действующего email контакта
    @param par_contact_id - ИД контакта
    @param par_description - тип адреса
  */
  FUNCTION get_last_active_email_id
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_description t_email_type.description%TYPE DEFAULT NULL
  ) RETURN cn_contact_email.id%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_LAST_ACTIVE_EMAIL_ID';
    v_email_id cn_contact_email.id%TYPE;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_ID'
                          ,par_trace_var_value => par_contact_id);
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_DESCRIPTION'
                          ,par_trace_var_value => par_description);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
    SELECT MAX(cce.id)
      INTO v_email_id
      FROM cn_contact_email cce
          ,t_email_type     tet
     WHERE cce.contact_id = par_contact_id
       AND tet.description = nvl(par_description, tet.description)
       AND cce.status = 1
       AND cce.email IS NOT NULL;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => vc_proc_name
                                ,par_trace_subobj_name => v_email_id);
  
    RETURN v_email_id;
  
  END get_last_active_email_id;

  /*
    Капля П.
    Получение значение email по id и маске
  */
  FUNCTION get_email_by_mask
  (
    par_contact_email_id cn_contact_email.id%TYPE
   ,par_mask             VARCHAR2
  ) RETURN cn_contact_email.email%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_EMAIL_BY_MASK';
    v_email         cn_contact_email.email%TYPE;
    v_result_string VARCHAR2(1000);
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_EMAIL_ID'
                          ,par_trace_var_value => par_contact_email_id);
    pkg_trace.add_variable(par_trace_var_name => 'PAR_MASK', par_trace_var_value => par_mask);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    assert_deprecated(par_mask IS NULL, 'Маска email может быть пустой');
  
    SELECT cce.email INTO v_email FROM cn_contact_email cce WHERE cce.id = par_contact_email_id;
  
    v_result_string := par_mask;
    v_result_string := REPLACE(v_result_string, gc_mask_email, v_email);
    v_result_string := REPLACE(v_result_string, gc_mask_email_lower, lower(v_email));
    v_result_string := REPLACE(v_result_string, gc_mask_email_upper, upper(v_email));
  
    pkg_trace.trace_function_end(par_trace_obj_name    => vc_proc_name
                                ,par_trace_subobj_name => v_result_string);
  
    RETURN v_result_string;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_email_by_mask;

  /*
    Капля П.
    Получение значения email по id
  */
  FUNCTION get_email(par_contact_email_id cn_contact_email.id%TYPE) RETURN cn_contact_email.email%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_EMAIL';
    v_result_string cn_contact_email.email%TYPE;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_CONTACT_EMAIL_ID'
                          ,par_trace_var_value => par_contact_email_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_result_string := get_email_by_mask(par_contact_email_id => par_contact_email_id
                                        ,par_mask             => gc_mask_email);
  
    pkg_trace.trace_function_end(par_trace_obj_name    => vc_proc_name
                                ,par_trace_subobj_name => v_result_string);
  
    RETURN v_result_string;
  END get_email;

  FUNCTION get_max_active_bank_acc_id(par_contact_id NUMBER) RETURN cn_contact_bank_acc.id%TYPE IS
    v_id cn_contact_bank_acc.id%TYPE;
  BEGIN
  
    SELECT MAX(c.id) keep(dense_rank FIRST ORDER BY c.id DESC)
      INTO v_id
      FROM cn_contact_bank_acc c
     WHERE c.contact_id = par_contact_id
       AND used_flag = 1;
  
    RETURN v_id;
  END get_max_active_bank_acc_id;

  FUNCTION get_most_recent_bank_acc_id(par_contact_id NUMBER) RETURN cn_contact_bank_acc.id%TYPE IS
    v_id cn_contact_bank_acc.id%TYPE;
  BEGIN
  
    SELECT MAX(c.id) keep(dense_rank FIRST ORDER BY used_flag DESC NULLS LAST, c.id DESC)
      INTO v_id
      FROM cn_contact_bank_acc c
     WHERE c.contact_id = par_contact_id;
  
    RETURN v_id;
  END get_most_recent_bank_acc_id;

  FUNCTION get_bank_acc_by_mask
  (
    par_bank_acc_id cn_contact_bank_acc.id%TYPE
   ,par_mask        VARCHAR2
  ) RETURN VARCHAR2 IS
    v_result VARCHAR2(4000);
  
    v_bank_acc dml_cn_contact_bank_acc.tt_cn_contact_bank_acc;
  BEGIN
    v_bank_acc := dml_cn_contact_bank_acc.get_record(par_bank_acc_id);
    v_result   := par_mask;
  
    v_result := REPLACE(v_result, gc_bank_info_account_nr, v_bank_acc.account_nr);
    v_result := REPLACE(v_result, gc_bank_info_iban, v_bank_acc.iban_reference);
    v_result := REPLACE(v_result, gc_bank_info_swift_code, v_bank_acc.swift_code);
    v_result := REPLACE(v_result, gc_bank_info_appr_ref, v_bank_acc.bank_approval_reference);
    v_result := REPLACE(v_result, gc_bank_info_appr_date, v_bank_acc.bank_approval_date);
    v_result := REPLACE(v_result, gc_bank_info_appr_end_date, v_bank_acc.bank_approval_end_date);
    v_result := REPLACE(v_result, gc_bank_info_bik, v_bank_acc.bic_code);
    v_result := REPLACE(v_result, gc_bank_info_account_corr, v_bank_acc.account_corr);
    v_result := REPLACE(v_result, gc_bank_info_lic_code, v_bank_acc.lic_code);
    v_result := REPLACE(v_result, gc_bank_info_place_of_issue, v_bank_acc.place_of_issue);
    v_result := REPLACE(v_result, gc_bank_info_bank_id, v_bank_acc.bank_id);
    v_result := REPLACE(v_result
                       ,gc_bank_info_bank_name
                       ,dml_contact.get_record(v_bank_acc.bank_id).obj_name_orig);
  
    RETURN v_result;
  
  END get_bank_acc_by_mask;

  /*
    Капля П.
    Функция получает инфу о компании по маске.
  */
  FUNCTION get_insurer_info(par_mask VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    v_insurer_info VARCHAR2(4000);
    v_company_name contact.obj_name_orig%TYPE;
    v_address      VARCHAR2(4000);
    v_phone        VARCHAR2(100) := 'Тел.: 8 (495) 981-29-81';
    v_fax          VARCHAR2(100) := 'Факс: 8 (495) 589-18-65/67';
    v_emails       VARCHAR2(1000);
    --По словам Танутерян телефон не существует
    --v_free_phone    VARCHAR2(100) := '8 800 200 54 33 (бесплатный номер)'; 
    v_website       VARCHAR2(100) := 'www.renlife.com';
    v_license       VARCHAR2(255) := 'Лицензия ФССНС № 397277 от 17.01.2006';
    v_okpo          VARCHAR2(50);
    v_ogrn          VARCHAR2(50);
    v_inn           VARCHAR2(50);
    v_kpp           VARCHAR2(50);
    v_account_umber VARCHAR2(100);
    v_bank_name     contact.obj_name_orig%TYPE;
    v_city          VARCHAR2(50) := 'г.Москва';
    v_bik           VARCHAR2(50);
    v_kor_account   VARCHAR2(100);
  
  BEGIN
  
    SELECT v.company_type || ' ' || v.company_name
          ,v.legal_address
          ,nvl2(TRIM(v.okpo), 'ОКПО ' || TRIM(v.okpo), NULL)
          ,nvl2(TRIM(v.ogrn), 'ОГРН ' || TRIM(v.ogrn), NULL)
          ,nvl2(TRIM(v.inn), 'ИНН ' || TRIM(v.inn), NULL)
          ,nvl2(TRIM(v.kpp), 'КПП ' || TRIM(v.kpp), NULL)
          ,nvl2(TRIM(v.account_number), 'P/C ' || TRIM(v.account_number), NULL)
          ,v.bank_name
          ,nvl2(TRIM(v.bik), 'БИК ' || TRIM(v.bik), NULL)
          ,nvl2(TRIM(v.cor_account), ' К/С  ' || TRIM(v.cor_account), NULL)
          ,v.emails
          ,nvl2(TRIM(v.licence_number) || TRIM(v.licence_date)
               ,'Лицензия ФССН ' || TRIM(v.licence_number) || ' от ' || TRIM(v.licence_date)
               ,NULL)
      INTO v_company_name
          ,v_address
          ,v_okpo
          ,v_ogrn
          ,v_inn
          ,v_kpp
          ,v_account_umber
          ,v_bank_name
          ,v_bik
          ,v_kor_account
          ,v_emails
          ,v_license
      FROM v_company_info v;
  
    v_insurer_info := nvl(par_mask, gc_company_def_info);
  
    v_insurer_info := REPLACE(v_insurer_info
                             ,gc_company_def_info
                             ,gc_company_nameaddr || ', ' || gc_company_def_phones || ', ' ||
                              gc_company_website || ', ' || gc_company_default_billing);
    v_insurer_info := REPLACE(v_insurer_info
                             ,gc_company_def_phones
                             ,gc_company_phone || ', ' || gc_company_fax);
    v_insurer_info := REPLACE(v_insurer_info
                             ,gc_company_nameaddr
                             ,gc_company_name || ', ' || gc_company_address);
    v_insurer_info := REPLACE(v_insurer_info
                             ,gc_company_default_billing
                             ,gc_company_inn || ', ' || gc_company_kpp || ', ' || gc_company_rs ||
                              ', В ' || gc_company_bank || ', ' || gc_company_city || ', ' ||
                              gc_company_bik || ', ' || gc_company_ks || ', ' || gc_company_license);
  
    v_insurer_info := REPLACE(v_insurer_info, gc_company_name, v_company_name);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_address, v_address);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_phone, v_phone);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_fax, v_fax);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_okpo, v_okpo);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_ogrn, v_ogrn);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_inn, v_inn);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_kpp, v_kpp);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_rs, v_account_umber);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_bank, v_bank_name);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_bik, v_bik);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_ks, v_kor_account);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_license, v_license);
    v_insurer_info := REPLACE(v_insurer_info, gc_mask_email, v_emails);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_website, v_website);
    v_insurer_info := REPLACE(v_insurer_info, gc_company_city, v_city);
  
    v_insurer_info := regexp_replace(v_insurer_info, ',\s+,', ', ');
  
    RETURN v_insurer_info;
  
  END get_insurer_info;

END pkg_contact_rep_utils; 
/
