CREATE OR REPLACE PACKAGE pkg_contact_object IS

  -- Author  : PAZUS
  -- Created : 10.11.2013 0:24:47
  -- Purpose : Пакет работы с контактом к с объектом. В пакете реализованы осносные механизмы мерджа и комплексной идентификации контакта

  /**
  Капля П.
  Объектная реализация программного создания контакта
  */
  /* Документ контакта */
  TYPE t_contact_id_doc_rec IS RECORD(
     id_doc_type_brief t_id_type.brief%TYPE DEFAULT 'PASS_RF'
    ,id_value          cn_contact_ident.id_value%TYPE
    ,series_nr         cn_contact_ident.serial_nr%TYPE
    ,issue_date        cn_contact_ident.issue_date%TYPE
    ,place_of_issue    cn_contact_ident.place_of_issue%TYPE
    ,is_default        cn_contact_ident.is_default%TYPE DEFAULT 1
    ,country_desc      t_country.description%TYPE DEFAULT 'Россия'
    ,country_alpha3    t_country.alfa3%TYPE
    ,subdivision_code  cn_contact_ident.subdivision_code%TYPE DEFAULT NULL
    ,is_used           cn_contact_ident.is_used%TYPE DEFAULT 1
    ,is_temp           cn_contact_ident.is_temp%TYPE
    ,termination_date  cn_contact_ident.termination_date%TYPE);

  /* Адрес контакта */
  TYPE t_contact_address_rec IS RECORD(
     address_type_brief t_address_type.brief%TYPE DEFAULT 'DOMADD'
    ,is_default         cn_contact_address.is_default%TYPE DEFAULT 1
    ,address            VARCHAR2(4000)
    ,country_desc       t_country.description%TYPE DEFAULT 'Россия'
    ,country_alpha3     t_country.alfa3%TYPE
    ,is_temp            cn_contact_address.is_temp%TYPE);

  /* Телефоны контакта */
  TYPE t_contact_phone_rec IS RECORD(
     phone_type_brief t_telephone_type.brief%TYPE DEFAULT 'HOME'
    ,phone_prefix     cn_contact_telephone.telephone_prefix%TYPE
    ,phone_extension  cn_contact_telephone.telephone_extension%TYPE
    ,phone_number     cn_contact_telephone.telephone_number%TYPE
    ,country_desc     t_country.description%TYPE DEFAULT 'Россия'
    ,country_alpha3   t_country.alfa3%TYPE
    ,status           cn_contact_telephone.status%TYPE DEFAULT 1
    ,control          cn_contact_telephone.control%TYPE
    ,is_temp          cn_contact_telephone.is_temp%TYPE);

  /* Банковские счета контакта */
  TYPE t_contact_bank_acc_rec IS RECORD(
     bank_name                   cn_contact_bank_acc.bank_name%TYPE
    ,branch_name                 cn_contact_bank_acc.branch_name%TYPE
    ,account_nr                  cn_contact_bank_acc.account_nr%TYPE
    ,bic_code                    cn_contact_bank_acc.bic_code%TYPE
    ,country_desc                t_country.description%TYPE DEFAULT 'Россия'
    ,country_alpha3              t_country.alfa3%TYPE
    ,bank_account_currency_brief fund.brief%TYPE
    ,iban_reference              cn_contact_bank_acc.iban_reference%TYPE
    ,swift_code                  cn_contact_bank_acc.swift_code%TYPE
    ,account_corr                cn_contact_bank_acc.account_corr%TYPE
    ,lic_code                    cn_contact_bank_acc.lic_code%TYPE
    ,owner_contact_id            cn_contact_bank_acc.owner_contact_id%TYPE
    ,is_check_owner              cn_contact_bank_acc.is_check_owner%TYPE
    ,place_of_issue              VARCHAR2(4000)
    ,used_flag                   cn_contact_bank_acc.used_flag%TYPE
    ,remarks                     cn_contact_bank_acc.remarks%TYPE
    ,bank_approval_reference     cn_contact_bank_acc.bank_approval_reference%TYPE
    ,bank_approval_date          cn_contact_bank_acc.bank_approval_date%TYPE
    ,bank_approval_end_date      cn_contact_bank_acc.bank_approval_end_date%TYPE
    ,order_number                cn_contact_bank_acc.order_number%TYPE
    ,is_temp                     cn_contact_bank_acc.is_temp%TYPE);

  /* E-mail'ы контакта */
  TYPE t_contact_email_rec IS RECORD(
     email           cn_contact_email.email%TYPE
    ,email_type_desc t_email_type.description%TYPE DEFAULT 'Адрес рассылки'
    ,status          cn_contact_email.status%TYPE
    ,is_temp         cn_contact_email.is_temp%TYPE);

  /* Дополнительные гражданства и виды на жительство контакта в других странах */
  TYPE t_contact_country_rec IS RECORD(
     country_name   t_country.description%TYPE
    ,country_alpha3 t_country.alfa3%TYPE);

  /* Мессивы записей */
  TYPE tt_contact_id_doc IS TABLE OF t_contact_id_doc_rec;
  TYPE tt_contact_address IS TABLE OF t_contact_address_rec;
  TYPE tt_contact_phone IS TABLE OF t_contact_phone_rec;
  TYPE tt_contact_bank_acc IS TABLE OF t_contact_bank_acc_rec;
  TYPE tt_contact_email IS TABLE OF t_contact_email_rec;
  TYPE tt_contact_country_list IS TABLE OF t_contact_country_rec;

  /* Объект контакта для ФЛ */
  TYPE t_person_object IS RECORD(
     NAME                       contact.name%TYPE
    ,first_name                 contact.first_name%TYPE
    ,middle_name                contact.middle_name%TYPE
    ,latin_name                 contact.latin_name%TYPE
    ,contact_type_brief         t_contact_type.brief%TYPE DEFAULT 'ФЛ'
    ,date_of_birth              DATE
    ,gender                     VARCHAR2(25)
    ,pers_acc                   contact.pers_acc%TYPE
    ,risk_level_brief           t_risk_level.brief%TYPE DEFAULT 'Middle'
    ,contact_status_name        t_contact_status.name%TYPE DEFAULT 'Обычный'
    ,family_status_desc         t_family_status.description%TYPE
    ,profession_desc            t_profession.description%TYPE
    ,education_desc             t_education.description%TYPE
    ,country_birth_name         t_country.description%TYPE DEFAULT 'Россия'
    ,country_birth_alpha3       t_country.alfa3%TYPE
    ,title_desc                 t_title.description%TYPE
    ,children_count             cn_person.childrens%TYPE
    ,adult_children_count       cn_person.adult_children%TYPE
    ,standing                   cn_person.standing%TYPE
    ,hobby_desc                 t_hobby.description%TYPE
    ,is_smoker                  NUMBER(1)
    ,work_place                 cn_person.work_place%TYPE
    ,post                       cn_person.post%TYPE
    ,no_standard_name           cn_person.no_standart_name%TYPE
    ,place_of_birth             cn_person.place_of_birth%TYPE
    ,resident_flag              contact.resident_flag%TYPE
    ,is_public_contact          NUMBER(1) DEFAULT 0
    ,is_rpdl                    cn_person.is_in_list%TYPE
    ,has_additional_citizenship cn_person.has_additional_citizenship%TYPE
    ,has_foreign_residency      cn_person.has_foreign_residency%TYPE
    ,date_of_death              cn_person.date_of_death%TYPE
    ,profile_login              contact.profile_login%TYPE
    ,profile_pass               contact.profile_pass%TYPE
    ,note                       contact.note%TYPE
    ,id_doc_array               tt_contact_id_doc
    ,address_array              tt_contact_address
    ,phone_array                tt_contact_phone
    ,bank_acc_array             tt_contact_bank_acc
    ,email_array                tt_contact_email
    ,additional_citizenship     tt_contact_country_list
    ,residency_country_list     tt_contact_country_list);

  /* Объект контакта для ЮЛ */
  TYPE t_company_object IS RECORD(
     NAME               contact.name%TYPE
    ,short_name         contact.short_name%TYPE
    ,contact_type_brief t_contact_type.brief%TYPE DEFAULT 'ЮЛ'
    ,pers_acc           contact.pers_acc%TYPE
    ,risk_level         contact.risk_level%TYPE DEFAULT 2
    ,activity_type_desc t_act_type_code.description%TYPE
    ,web_site           cn_company.web_site%TYPE
    ,turnover           cn_company.turnover%TYPE
    ,currency_brief     fund.brief%TYPE
    ,established_date   DATE
    ,financial_rating   cn_company.financial_rating%TYPE
    ,turnover_year      cn_company.turnover_year%TYPE
    ,end_date_activity  cn_company.end_date_activity%TYPE
    ,activity_remark    cn_company.activity_remark%TYPE
    ,boss_contact_id    NUMBER
    ,worker_count       cn_company.workers_count%TYPE
    ,resident_flag      contact.resident_flag%TYPE DEFAULT 1
    ,is_public_contact  NUMBER(1)
    ,id_doc_array       tt_contact_id_doc
    ,address_array      tt_contact_address
    ,phone_array        tt_contact_phone
    ,bank_acc_array     tt_contact_bank_acc
    ,email_array        tt_contact_email);

  /* Pipelined functions для работы с объектной реализацией */
  FUNCTION get_current_contact_id_docs RETURN tt_contact_id_doc
    PIPELINED;
  FUNCTION get_current_contact_addresses RETURN tt_contact_address
    PIPELINED;
  FUNCTION get_current_contact_phones RETURN tt_contact_phone
    PIPELINED;
  FUNCTION get_current_contact_bank_accs RETURN tt_contact_bank_acc
    PIPELINED;
  FUNCTION get_current_contact_emails RETURN tt_contact_email
    PIPELINED;

  ----------------
  -- Структурно-оринтированная реализация работы с контактами
  ----------------
  -- Создает объект по contact_id
  FUNCTION person_object_from_contact(par_contact_id contact.contact_id%TYPE) RETURN t_person_object;
  -- Создает контакт из объекта
  --FUNCTION create_person_from_object(par_person_obj t_person_object) RETURN contact.contact_id%TYPE;
  PROCEDURE process_person_object
  (
    par_person_obj t_person_object
   ,par_contact_id IN OUT contact.contact_id%TYPE
  );

  PROCEDURE create_person_from_object
  (
    par_person_object t_person_object
   ,par_contact_id    OUT contact.contact_id%TYPE
  );

  ----------------
  -- Процедуры заполнения массивов объекта физлица
  ----------------

  /*
    Капля П.С.
    18.11.2013
    Добавление строки документа в объект
  */
  PROCEDURE add_id_doc_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_id_doc_rec     t_contact_id_doc_rec
  );

  /*
    Капля П.С.
    18.11.2013
    Добавление адреса в объект
  */
  PROCEDURE add_address_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_address_rec    t_contact_address_rec
  );

  /*
    Капля П.С.
    18.11.2013
    Добавление телефона в объект
  */
  PROCEDURE add_phone_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_phone_rec      t_contact_phone_rec
  );

  /*
    Капля П.С.
    18.11.2013
    Добавление банковского реквизита в объект
  */
  PROCEDURE add_bank_acc_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_bank_acc_rec   t_contact_bank_acc_rec
  );

  /*
    Капля П.С.
    18.11.2013
    Добавление электронной почты в объект
  */
  PROCEDURE add_email_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_email_rec      t_contact_email_rec
  );

  /*
    Капля П.
    08.08.2014
    Процедура добавления сведений о другом гражданстве
  */
  PROCEDURE add_additional_citizenship
  (
    par_contact_object  IN OUT NOCOPY t_person_object
   ,par_citizenship_rec t_contact_country_rec
  );

  /*
    Капля П.
    08.08.2014
    Процедура добавления вида на жительства
  */
  PROCEDURE add_residency_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_residency_rec  t_contact_country_rec
  );

  ----------------
  -- Процедуры объединения массивов данных контакта
  -- Документы, адреса, телефоны, email'ы и банковские реквизиты
  ----------------
  -- Объединяем данные о документах у объекта с данными контакта в базе
  /*
  -- Закомментировано т.е. не предполагается использовать извне
  PROCEDURE merge_id_doc_into_contact
  (
    par_contact_id contact.contact_id%TYPE
   ,par_id_doc_rec t_contact_id_doc_rec
  );
  PROCEDURE merge_id_doc_into_contact
  (
    par_contact_id   contact.contact_id%TYPE
   ,par_id_doc_array tt_contact_id_doc
  );

  -- Объединяем данные об адресах у объекта с данными контакта в базе
  PROCEDURE merge_address_into_contact
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_address_rec t_contact_address_rec
  );
  PROCEDURE merge_address_into_contact
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_address_array tt_contact_address
  );

  -- Объединяем данные о телефонах у объекта с данными контакта в базе
  PROCEDURE merge_phone_into_contact
  (
    par_contact_id contact.contact_id%TYPE
   ,par_phone_rec  t_contact_phone_rec
  );
  PROCEDURE merge_phone_into_contact
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_phone_array tt_contact_phone
  );

  -- Объединяем данные об e-mail'ах у объекта с данными контакта в базе
  PROCEDURE merge_email_into_contact
  (
    par_contact_id contact.contact_id%TYPE
   ,par_email_rec  t_contact_email_rec
  );
  PROCEDURE merge_email_into_contact
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_email_array tt_contact_email
  );
  */
  -- Функции генерации массивов данных контакта

  FUNCTION get_contact_id_doc_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_id_doc;
  FUNCTION get_contact_telephone_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_phone;
  FUNCTION get_contact_address_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_address;
  FUNCTION get_contact_bank_acc_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_bank_acc;
  FUNCTION get_contact_email_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_email;
  FUNCTION get_contact_add_citizenship(par_contact_id contact.contact_id%TYPE)
    RETURN tt_contact_country_list;
  FUNCTION get_contact_residency(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_country_list;

END pkg_contact_object;
/
CREATE OR REPLACE PACKAGE BODY pkg_contact_object IS

  /* Глобальные переменные для использования в pipelined functions */
  gv_current_person_obj  t_person_object;
  gv_current_company_obj t_company_object;
  gc_phone_replace_symbols CONSTANT VARCHAR2(255) := '[^0-9]+';

  /* Получение страны по названию */
  FUNCTION get_country_id
  (
    par_country_desc   t_country.description%TYPE
   ,par_country_alpha3 t_country.alfa3%TYPE
  ) RETURN t_country.id%TYPE IS
    v_country_id t_country.id%TYPE;
  BEGIN
    IF par_country_alpha3 IS NOT NULL
    THEN
      v_country_id := pkg_country.get_country_id_by_alpha3(par_country_alpha3 => par_country_alpha3);
    ELSIF par_country_desc IS NOT NULL
    THEN
      v_country_id := pkg_country.get_country_id_by_desc(par_country_desctiption => par_country_desc);
    END IF;
  
    RETURN v_country_id;
  END get_country_id;

  /* Очистка глобальных переменных. 
  Когда работаем с новым контактом, сначала надо очистить старый текущий контакт */
  PROCEDURE clear_global_object_variables IS
    v_empty_person  t_person_object;
    v_empty_copmany t_company_object;
  BEGIN
    gv_current_person_obj  := v_empty_person;
    gv_current_company_obj := v_empty_copmany;
  END clear_global_object_variables;

  /* Pipelined functions для работы с объектом контакта */
  FUNCTION get_current_contact_id_docs RETURN tt_contact_id_doc
    PIPELINED IS
  BEGIN
    IF gv_current_person_obj.id_doc_array IS NOT NULL
       AND gv_current_person_obj.id_doc_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_person_obj.id_doc_array.first .. gv_current_person_obj.id_doc_array.last
      LOOP
        PIPE ROW(gv_current_person_obj.id_doc_array(v_idx));
      END LOOP;
    
    ELSIF gv_current_person_obj.id_doc_array IS NOT NULL
          AND gv_current_company_obj.id_doc_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_company_obj.id_doc_array.first .. gv_current_company_obj.id_doc_array.last
      LOOP
        PIPE ROW(gv_current_company_obj.id_doc_array(v_idx));
      END LOOP;
    
    END IF;
  
    RETURN;
  END get_current_contact_id_docs;

  FUNCTION get_current_contact_addresses RETURN tt_contact_address
    PIPELINED IS
  BEGIN
    IF gv_current_person_obj.address_array IS NOT NULL
       AND gv_current_person_obj.address_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_person_obj.address_array.first .. gv_current_person_obj.address_array.last
      LOOP
        PIPE ROW(gv_current_person_obj.address_array(v_idx));
      END LOOP;
    
    ELSIF gv_current_company_obj.address_array IS NOT NULL
          AND gv_current_company_obj.address_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_company_obj.address_array.first .. gv_current_company_obj.address_array.last
      LOOP
        PIPE ROW(gv_current_company_obj.address_array(v_idx));
      END LOOP;
    
    END IF;
  
    RETURN;
  END get_current_contact_addresses;

  FUNCTION get_current_contact_phones RETURN tt_contact_phone
    PIPELINED IS
  BEGIN
    IF gv_current_person_obj.phone_array IS NOT NULL
       AND gv_current_person_obj.phone_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_person_obj.phone_array.first .. gv_current_person_obj.phone_array.last
      LOOP
        PIPE ROW(gv_current_person_obj.phone_array(v_idx));
      END LOOP;
    
    ELSIF gv_current_company_obj.phone_array IS NOT NULL
          AND gv_current_company_obj.phone_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_company_obj.phone_array.first .. gv_current_company_obj.phone_array.last
      LOOP
        PIPE ROW(gv_current_company_obj.phone_array(v_idx));
      END LOOP;
    
    END IF;
  
    RETURN;
  END get_current_contact_phones;

  FUNCTION get_current_contact_bank_accs RETURN tt_contact_bank_acc
    PIPELINED IS
  BEGIN
    IF gv_current_person_obj.bank_acc_array IS NOT NULL
       AND gv_current_person_obj.bank_acc_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_person_obj.bank_acc_array.first .. gv_current_person_obj.bank_acc_array.last
      LOOP
        PIPE ROW(gv_current_person_obj.bank_acc_array(v_idx));
      END LOOP;
    
    ELSIF gv_current_company_obj.bank_acc_array IS NOT NULL
          AND gv_current_company_obj.bank_acc_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_company_obj.bank_acc_array.first .. gv_current_company_obj.bank_acc_array.last
      LOOP
        PIPE ROW(gv_current_company_obj.bank_acc_array(v_idx));
      END LOOP;
    
    END IF;
  
    RETURN;
  END get_current_contact_bank_accs;

  FUNCTION get_current_contact_emails RETURN tt_contact_email
    PIPELINED IS
  BEGIN
  
    IF gv_current_person_obj.email_array IS NOT NULL
       AND gv_current_person_obj.email_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_person_obj.email_array.first .. gv_current_person_obj.email_array.last
      LOOP
        PIPE ROW(gv_current_person_obj.email_array(v_idx));
      END LOOP;
    
    ELSIF gv_current_company_obj.email_array IS NOT NULL
          AND gv_current_company_obj.email_array.count > 0
    THEN
    
      FOR v_idx IN gv_current_company_obj.email_array.first .. gv_current_company_obj.email_array.last
      LOOP
        PIPE ROW(gv_current_company_obj.email_array(v_idx));
      END LOOP;
    
    END IF;
  
    RETURN;
  END get_current_contact_emails;

  /*
    Объединяем данные о документах у объекта с данными контакта в базе
  */
  PROCEDURE merge_id_doc_into_contact
  (
    par_contact_id contact.contact_id%TYPE
   ,par_id_doc_rec t_contact_id_doc_rec
  ) IS
  
    v_id_doc_id      cn_contact_ident.table_id%TYPE;
    v_id_doc_type_id t_id_type.id%TYPE;
  
    -- Валидация записи о документе
    PROCEDURE validate(par_id_doc_rec t_contact_id_doc_rec) IS
    BEGIN
      assert_deprecated(TRIM(par_id_doc_rec.id_value) IS NULL
            ,'Номер документа не может быть пуст');
      assert_deprecated(par_id_doc_rec.id_doc_type_brief IS NULL
            ,'Бриф типа документа не может быть пуст');
    END validate;
  
    --Получение типа документа по брифу
    FUNCTION get_id_doc_type_id(par_id_doc_type_brief t_id_type.brief%TYPE) RETURN t_id_type.id%TYPE IS
      v_id_doc_type_id t_id_type.id%TYPE;
    BEGIN
      SELECT id INTO v_id_doc_type_id FROM t_id_type t WHERE t.brief = par_id_doc_type_brief;
      RETURN v_id_doc_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить тип документа по брифу "' ||
                                nvl(par_id_doc_type_brief, 'NULL') || '"');
    END get_id_doc_type_id;
  
  BEGIN
  
    validate(par_id_doc_rec);
  
    v_id_doc_type_id := get_id_doc_type_id(par_id_doc_rec.id_doc_type_brief);
  
    -- Пытаемся найти документ. Поиск происзводится стандартными методами. На момент написания - по серии, номеру, дате выдачи и типу документа
    v_id_doc_id := pkg_contact.find_ident_document(par_contact_id    => par_contact_id
                                                  ,par_ident_type_id => v_id_doc_type_id
                                                  ,par_value         => TRIM(par_id_doc_rec.id_value)
                                                  ,par_series        => TRIM(par_id_doc_rec.series_nr)
                                                  ,par_issue_date    => par_id_doc_rec.issue_date);
  
    -- Обновляем место выдачи документа, если нашли
    IF v_id_doc_id IS NOT NULL
    THEN
      UPDATE cn_contact_ident cci
         SET cci.place_of_issue   = nvl(cci.place_of_issue, par_id_doc_rec.place_of_issue)
            ,cci.is_used          = nvl(cci.is_used,par_id_doc_rec.is_used)
            ,cci.is_default       = nvl(cci.is_default,par_id_doc_rec.is_default)
            ,cci.is_temp          = nvl(cci.is_temp,par_id_doc_rec.is_temp)
            ,cci.subdivision_code = nvl(cci.subdivision_code, par_id_doc_rec.subdivision_code)
       WHERE cci.table_id = v_id_doc_id;
    ELSE
      -- Добавляем документ контакту, если не нашли
      v_id_doc_id := pkg_contact.create_ident_document(par_contact_id       => par_contact_id
                                                      ,par_ident_type_id    => v_id_doc_type_id
                                                      ,par_value            => par_id_doc_rec.id_value
                                                      ,par_series           => par_id_doc_rec.series_nr
                                                      ,par_issue_date       => par_id_doc_rec.issue_date
                                                      ,par_issue_place      => par_id_doc_rec
                                                                              .place_of_issue
                                                      ,par_is_default       => par_id_doc_rec.is_default
                                                      ,par_subdivision_code => par_id_doc_rec.subdivision_code
                                                      ,par_is_used          => par_id_doc_rec.is_used
                                                      ,par_is_temp          => par_id_doc_rec.is_temp
                                                      ,par_termination_date => par_id_doc_rec.termination_date);
    END IF;
  
  END merge_id_doc_into_contact;

  PROCEDURE merge_id_doc_into_contact
  (
    par_contact_id   contact.contact_id%TYPE
   ,par_id_doc_array tt_contact_id_doc
  ) IS
  BEGIN
    IF par_id_doc_array IS NOT NULL
       AND par_id_doc_array.count > 0
    THEN
      FOR i IN par_id_doc_array.first .. par_id_doc_array.last
      LOOP
        merge_id_doc_into_contact(par_contact_id => par_contact_id
                                  
                                 ,par_id_doc_rec => par_id_doc_array(i));
      END LOOP;
    END IF;
  END merge_id_doc_into_contact;

  /*
    Объединяем данные об адресах у объекта с данными контакта в базе
  */
  PROCEDURE merge_address_into_contact
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_address_rec t_contact_address_rec
  ) IS
    v_country_id t_country.id%TYPE := get_country_id(par_address_rec.country_desc
                                                    ,par_address_rec.country_alpha3);
  
    -- Процедура валидации переданного содержимого
    PROCEDURE validate(par_address_rec t_contact_address_rec) IS
    BEGIN
      assert_deprecated(par_address_rec.address IS NULL, 'Адрес не может быть пуст');
      assert_deprecated(par_address_rec.address_type_brief IS NULL
            ,'Бриф типа адреса не может быть пуст');
    END validate;
  
    -- Получения типа адреса по брифу
    FUNCTION get_address_type_id(par_address_type_brief VARCHAR2) RETURN t_address_type.id%TYPE IS
      v_address_type_id t_address_type.id%TYPE;
    BEGIN
      BEGIN
        SELECT id
          INTO v_address_type_id
          FROM t_address_type at
         WHERE at.brief = par_address_type_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Неудалось определить тип адреса по брифу "' ||
                                  nvl(par_address_type_brief, 'NULL') || '"');
      END;
      RETURN v_address_type_id;
    END get_address_type_id;
  BEGIN
  
    validate(par_address_rec);
  
    -- Функция не тупо инсертит, а пытается обновить адрес, если таковой есть.
    pkg_contact.insert_address(p_contact_id         => par_contact_id
                              ,p_address            => par_address_rec.address
                              ,p_address_type_brief => par_address_rec.address_type_brief
                              ,p_country_id         => v_country_id
                              ,p_is_default         => par_address_rec.is_default
                              ,p_is_temp            => par_address_rec.is_temp);
  
  END merge_address_into_contact;

  PROCEDURE merge_address_into_contact
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_address_array tt_contact_address
  ) IS
  BEGIN
    IF par_address_array IS NOT NULL
       AND par_address_array.count > 0
    THEN
      FOR i IN par_address_array.first .. par_address_array.last
      LOOP
        merge_address_into_contact(par_contact_id  => par_contact_id
                                  ,par_address_rec => par_address_array(i));
      END LOOP;
    END IF;
  END merge_address_into_contact;

  /*
    Объединяем данные о телефонах у объекта с данными контакта в базе
  */
  PROCEDURE merge_phone_into_contact
  (
    par_contact_id contact.contact_id%TYPE
   ,par_phone_rec  t_contact_phone_rec
  ) IS
  
    v_phone_existance_check NUMBER(1);
    v_country_dail_code_id  t_country_dial_code.id%TYPE;
    v_phone_type_id         t_telephone_type.id%TYPE;
    v_phone_number          cn_contact_telephone.telephone_number%TYPE;
    v_dummy                 NUMBER;
  
    -- Валидация
    PROCEDURE validate(par_phone_rec t_contact_phone_rec) IS
    BEGIN
      assert_deprecated(par_phone_rec.phone_type_brief IS NULL
            ,'Тип телефонного номера не может быть пуст');
    END validate;
  
    -- Получение телефонного кода страны
    FUNCTION get_country_dail_code_id(par_country_desc t_country.description%TYPE)
      RETURN t_country_dial_code.id%TYPE IS
      v_dail_code_id t_country_dial_code.id%TYPE;
    BEGIN
      SELECT cdc.id
        INTO v_dail_code_id
        FROM t_country           c
            ,t_country_dial_code cdc
       WHERE c.description = par_country_desc
         AND c.id = cdc.country_id;
      RETURN v_dail_code_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить телефонный код для страны "' ||
                                nvl(par_country_desc, 'NULL') || '"');
    END get_country_dail_code_id;
  
    -- Получение типа телефона
    FUNCTION get_phone_type_id(par_phone_type_brief t_telephone_type.brief%TYPE)
      RETURN t_telephone_type.id%TYPE IS
      v_phone_type_id t_telephone_type.id%TYPE;
    BEGIN
      SELECT tt.id
        INTO v_phone_type_id
        FROM t_telephone_type tt
       WHERE tt.brief = par_phone_type_brief;
      RETURN v_phone_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить тип телефона по брифу "' ||
                                nvl(par_phone_type_brief, 'NULL') || '"');
    END get_phone_type_id;
  BEGIN
  
    -- Допустим мы собрали объект из имеющегося контакта, у него могут быть уже пустые телефоны.
    -- необходимо исключить их из мерджа чтобы не дублировать бесконечно
    v_phone_number := regexp_replace(par_phone_rec.phone_number, gc_phone_replace_symbols);
    IF v_phone_number IS NOT NULL
    THEN
    
      validate(par_phone_rec);
    
      v_country_dail_code_id := get_country_dail_code_id(par_phone_rec.country_desc);
      v_phone_type_id        := get_phone_type_id(par_phone_rec.phone_type_brief);
    
      SELECT COUNT(*)
        INTO v_phone_existance_check
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM cn_contact_telephone cct
               WHERE cct.contact_id = par_contact_id
                 AND cct.telephone_type = v_phone_type_id
                 AND regexp_replace(cct.telephone_number, gc_phone_replace_symbols) = v_phone_number);
    
      -- Добавляем телефон, если такого еще нет. Сравниваем только по цифрам.
      IF v_phone_existance_check = 0
      THEN
      
        v_dummy := pkg_contact.insert_phone(par_contact_id          => par_contact_id
                                           ,par_telephone_type      => v_phone_type_id
                                           ,par_telephone_number    => par_phone_rec.phone_number
                                           ,par_telephone_prefix    => par_phone_rec.phone_prefix
                                           ,par_country_id          => v_country_dail_code_id
                                           ,par_telephone_extension => par_phone_rec.phone_extension
                                           ,par_control             => par_phone_rec.control
                                           ,par_status              => par_phone_rec.status
                                           ,par_is_temp             => par_phone_rec.is_temp);
      END IF;
    END IF;
  
  END merge_phone_into_contact;

  PROCEDURE merge_phone_into_contact
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_phone_array tt_contact_phone
  ) IS
  BEGIN
    IF par_phone_array IS NOT NULL
       AND par_phone_array.count > 0
    THEN
      FOR i IN par_phone_array.first .. par_phone_array.last
      LOOP
        merge_phone_into_contact(par_contact_id => par_contact_id
                                ,par_phone_rec  => par_phone_array(i));
      END LOOP;
    END IF;
  END merge_phone_into_contact;
  /*
    Объединяем данные банковских данных у объекта с данными контакта в базе
  */
  /*
  TODO: owner="pavel.kaplya" category="Finish" created="10.11.2013"
  text="Необходимо обговорить с аналитиками и реализовать merge bank account
  На данный момент нет мерджа как такового, просто добавление данных"
  */
  PROCEDURE merge_bank_acc_into_contact
  (
    par_contact_id   contact.contact_id%TYPE
   ,par_bank_acc_rec t_contact_bank_acc_rec
  ) IS
  
    vr_bank_acc              t_contact_bank_acc_rec := par_bank_acc_rec;
    v_bank_id                contact.contact_id%TYPE;
    v_branch_id              contact.contact_id%TYPE;
    v_fund_id                fund.fund_id%TYPE;
    v_country_id             t_country.id%TYPE;
    v_cn_contact_bank_acc_id cn_contact_bank_acc.id%TYPE;
    v_cn_document_bank_acc   cn_document_bank_acc.cn_document_bank_acc_id%TYPE;
  
    -- Валидация
    PROCEDURE validate(par_bank_acc_rec t_contact_bank_acc_rec) IS
    BEGIN
      NULL;
    END validate;
  
    -- Получение контакта банка
    FUNCTION get_bank_id(par_bank_name VARCHAR2) RETURN contact.contact_id%TYPE IS
      v_bank_id contact.contact_id%TYPE;
    BEGIN
      BEGIN
        SELECT contact_id
          INTO v_bank_id
          FROM contact c
         WHERE c.obj_name = upper(par_bank_name)
           AND EXISTS (SELECT NULL
                  FROM cn_contact_role v
                      ,t_contact_role  t
                 WHERE v.role_id = t.id
                   AND t.brief = 'BANK'
                   AND v.contact_id = c.contact_id);
      
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'По названию банка не удалось найти соответствующий контакт');
        WHEN too_many_rows THEN
          raise_application_error(-20001
                                 ,'по названию найдено несколько контактов банков');
      END;
    
      RETURN v_bank_id;
    
    END get_bank_id;
  
    -- Получение контакта подразделения банка
    FUNCTION get_branch_id(par_branch_name VARCHAR2) RETURN contact.contact_id%TYPE IS
      v_branch_id contact.contact_id%TYPE;
    BEGIN
      IF par_branch_name IS NOT NULL
      THEN
        BEGIN
          SELECT contact_id
            INTO v_branch_id
            FROM contact c
           WHERE c.obj_name = upper(par_branch_name)
             AND EXISTS (SELECT NULL
                    FROM cn_contact_role v
                        ,t_contact_role  t
                   WHERE v.role_id = t.id
                     AND t.brief = 'BANK_BRANCH'
                     AND v.contact_id = c.contact_id);
        
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'По названию отделения банка не удалось найти соответствующий контакт');
          WHEN too_many_rows THEN
            raise_application_error(-20001
                                   ,'по названию найдено несколько контактов отделений банков');
        END;
      END IF;
      /*TODO: сделать поиск отделения банка по имени*/
      RETURN v_branch_id;
    END get_branch_id;
  
    FUNCTION bank_acc_exists
    (
      par_contact_id   contact.contact_id%TYPE
     ,par_account_nr   cn_contact_bank_acc.account_nr%TYPE
     ,par_lic_code     cn_contact_bank_acc.lic_code%TYPE
     ,par_account_corr cn_contact_bank_acc.account_corr%TYPE
    ) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_bank_acc  bac
                    ,cn_document_bank_acc dac
                    ,document             dc
                    ,doc_status_ref       dsr
               WHERE bac.contact_id = par_contact_id
                 AND bac.account_nr = par_account_nr
                 AND (lnnvl(bac.lic_code != par_lic_code) OR
                     lnnvl(bac.account_corr != par_account_corr))
                 AND bac.id = dac.cn_contact_bank_acc_id
                 AND dac.cn_document_bank_acc_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.name != 'CANCEL');
    
      RETURN v_is_exists = 1;
    
    END bank_acc_exists;
  
  BEGIN
  
    validate(par_bank_acc_rec);
  
    IF NOT bank_acc_exists(par_contact_id   => par_contact_id
                          ,par_account_nr   => vr_bank_acc.account_nr
                          ,par_lic_code     => vr_bank_acc.lic_code
                          ,par_account_corr => vr_bank_acc.account_corr)
    THEN
    
      v_bank_id    := get_bank_id(vr_bank_acc.bank_name);
      v_branch_id  := get_branch_id(vr_bank_acc.branch_name);
      v_fund_id    := pkg_fund_dml.get_id_by_brief(vr_bank_acc.bank_account_currency_brief);
      v_country_id := get_country_id(vr_bank_acc.country_desc, vr_bank_acc.country_alpha3);
    
      /*
        Сейчас нет нормального способа работы с банковскими реквизитами, нет явных ограничений уникальности.
        Делаем пока через обработку исключения, но в дальнейшем эту процедуру нужно модернизировать.
      */
      BEGIN
        pkg_contact.insert_account_nr(par_account_corr             => vr_bank_acc.account_corr
                                     ,par_account_nr               => vr_bank_acc.account_nr
                                     ,par_bank_account_currency_id => v_fund_id
                                     ,par_bank_approval_date       => vr_bank_acc.bank_approval_date
                                     ,par_bank_approval_end_date   => vr_bank_acc.bank_approval_end_date
                                     ,par_bank_approval_reference  => vr_bank_acc.bank_approval_reference
                                     ,par_bank_id                  => v_bank_id
                                     ,par_bank_name                => vr_bank_acc.bank_name
                                     ,par_bic_code                 => vr_bank_acc.bic_code
                                     ,par_branch_id                => v_branch_id
                                     ,par_branch_name              => vr_bank_acc.branch_name
                                     ,par_contact_id               => par_contact_id
                                     ,par_country_id               => v_country_id
                                     ,par_iban_reference           => vr_bank_acc.iban_reference
                                     ,par_is_check_owner           => vr_bank_acc.is_check_owner
                                     ,par_lic_code                 => vr_bank_acc.lic_code
                                     ,par_order_number             => vr_bank_acc.order_number
                                     ,par_owner_contact_id         => vr_bank_acc.owner_contact_id
                                     ,par_remarks                  => vr_bank_acc.remarks
                                     ,par_swift_code               => vr_bank_acc.swift_code
                                     ,par_used_flag                => vr_bank_acc.used_flag
                                     ,par_cn_contact_bank_acc_id   => v_cn_contact_bank_acc_id
                                     ,par_cn_document_bank_acc_id  => v_cn_document_bank_acc);
      EXCEPTION
        WHEN ex.too_many_rows THEN
          NULL;
      END;
    END IF;
  
  END merge_bank_acc_into_contact;

  PROCEDURE merge_bank_acc_into_contact
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_bank_acc_array tt_contact_bank_acc
  ) IS
  BEGIN
    IF par_bank_acc_array IS NOT NULL
       AND par_bank_acc_array.count > 0
    THEN
      FOR i IN par_bank_acc_array.first .. par_bank_acc_array.last
      LOOP
        merge_bank_acc_into_contact(par_contact_id   => par_contact_id
                                   ,par_bank_acc_rec => par_bank_acc_array(i));
      END LOOP;
    END IF;
  END merge_bank_acc_into_contact;
  /*
    Объединяем данные об e-mail'ах у объекта с данными контакта в базе
  */
  PROCEDURE merge_email_into_contact
  (
    par_contact_id contact.contact_id%TYPE
   ,par_email_rec  t_contact_email_rec
  ) IS
    v_email_existance_check NUMBER(1);
    v_dummy                 NUMBER;
  
    -- Валидация
    PROCEDURE validate(par_email_rec t_contact_email_rec) IS
    BEGIN
      assert_deprecated(TRIM(par_email_rec.email) IS NULL, 'e-mail не может быть пустым');
      assert_deprecated(par_email_rec.email_type_desc IS NULL
            ,'Тип e-mail''а не может быть пустым');
    END validate;
  BEGIN
  
    validate(par_email_rec);
  
    SELECT COUNT(*)
      INTO v_email_existance_check
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM cn_contact_email cce
                  ,t_email_type     et
             WHERE et.id = cce.email_type
               AND cce.contact_id = par_contact_id
               AND upper(et.description) = TRIM(upper(par_email_rec.email_type_desc))
               AND upper(cce.email) = TRIM(upper(par_email_rec.email)));
  
    -- Если не нашли такой email - добавляем. Возможно нужно продумать механизм обновления
    IF v_email_existance_check = 0
    THEN
      v_dummy := pkg_contact.insert_email(par_contact_id => par_contact_id
                                         ,par_email      => par_email_rec.email
                                         ,par_email_type => par_email_rec.email_type_desc
                                         ,par_status     => par_email_rec.status
                                         ,par_is_temp    => par_email_rec.is_temp);
    END IF;
  
  END merge_email_into_contact;

  PROCEDURE merge_email_into_contact
  (
    par_contact_id  contact.contact_id%TYPE
   ,par_email_array tt_contact_email
  ) IS
  BEGIN
  
    IF par_email_array IS NOT NULL
       AND par_email_array.count > 0
    THEN
      FOR i IN par_email_array.first .. par_email_array.last
      LOOP
        merge_email_into_contact(par_contact_id => par_contact_id
                                ,par_email_rec  => par_email_array(i));
      END LOOP;
    END IF;
  
  END merge_email_into_contact;

  PROCEDURE delete_add_citizenships(par_contact_id NUMBER) IS
  BEGIN
    DELETE FROM cn_contact_add_citizenship ccac WHERE ccac.contact_id = par_contact_id;
  END delete_add_citizenships;

  PROCEDURE delete_residencies(par_contact_id NUMBER) IS
  BEGIN
    DELETE FROM cn_contact_residency ccr WHERE ccr.contact_id = par_contact_id;
  END delete_residencies;

  /*
    Процедура добавления дополнительных гражданств
  */
  PROCEDURE update_additional_citiz
  (
    par_contact_id       contact.contact_id%TYPE
   ,par_citizenship_list tt_contact_country_list
  ) IS
    va_contact_add_citizenship dml_cn_contact_add_citizenship.typ_associative_array;
    v_country_id               NUMBER;
  
    FUNCTION check_exists(par_country_id NUMBER) RETURN BOOLEAN IS
      v_exists BOOLEAN := FALSE;
      v_index  PLS_INTEGER := va_contact_add_citizenship.first;
    BEGIN
      WHILE v_index IS NOT NULL
      LOOP
        IF va_contact_add_citizenship(v_index).country_id = par_country_id
        THEN
          v_exists := TRUE;
          EXIT;
        END IF;
        v_index := va_contact_add_citizenship.next(v_index);
      END LOOP;
      RETURN v_exists;
    END check_exists;
  BEGIN
    IF par_citizenship_list IS NOT NULL
       AND par_citizenship_list.count > 0
    THEN
      delete_add_citizenships(par_contact_id);
    
      FOR i IN par_citizenship_list.first .. par_citizenship_list.last
      LOOP
        v_country_id := get_country_id(par_citizenship_list(i).country_name
                                      ,par_citizenship_list(i).country_alpha3);
        IF NOT check_exists(v_country_id)
        THEN
          va_contact_add_citizenship(i).contact_id := par_contact_id;
          va_contact_add_citizenship(i).country_id := v_country_id;
        END IF;
      END LOOP;
    
      dml_cn_contact_add_citizenship.insert_record_list(va_contact_add_citizenship);
    END IF;
  END update_additional_citiz;

  /*
    Процедура добавления видов на жительство в других государствах
  */
  PROCEDURE update_residency
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_residency_list tt_contact_country_list
  ) IS
    va_contact_residency dml_cn_contact_residency.typ_associative_array;
    v_country_id         NUMBER;
  
    FUNCTION check_exists(par_country_id NUMBER) RETURN BOOLEAN IS
      v_exists BOOLEAN := FALSE;
      v_index  PLS_INTEGER := va_contact_residency.first;
    BEGIN
      WHILE v_index IS NOT NULL
      LOOP
        IF va_contact_residency(v_index).country_id = par_country_id
        THEN
          v_exists := TRUE;
          EXIT;
        END IF;
        v_index := va_contact_residency.next(v_index);
      END LOOP;
      RETURN v_exists;
    END check_exists;
  BEGIN
    IF par_residency_list IS NOT NULL
       AND par_residency_list.count > 0
    THEN
      delete_residencies(par_contact_id);
    
      FOR i IN par_residency_list.first .. par_residency_list.last
      LOOP
        v_country_id := get_country_id(par_residency_list(i).country_name
                                      ,par_residency_list(i).country_alpha3);
      
        IF NOT check_exists(v_country_id)
        THEN
          va_contact_residency(i).contact_id := par_contact_id;
          va_contact_residency(i).country_id := v_country_id;
        END IF;
      END LOOP;
    
      dml_cn_contact_residency.insert_record_list(va_contact_residency);
    END IF;
  END update_residency;

  /*
    Процедура создание контакта из объекта
  */
  PROCEDURE create_person_from_object
  (
    par_person_object t_person_object
   ,par_contact_id    OUT contact.contact_id%TYPE
  ) IS
  BEGIN
  
    process_person_object(par_person_obj => par_person_object, par_contact_id => par_contact_id);
  
  END create_person_from_object;

  PROCEDURE process_person_object
  (
    par_person_obj t_person_object
   ,par_contact_id IN OUT contact.contact_id%TYPE
  ) IS
  
    -- Устанавливаем в качестве текущего объекта переданный. 
    -- Текущий объект используется в pipelined функциях
    PROCEDURE set_current_object(par_person_obj t_person_object) IS
    BEGIN
      clear_global_object_variables;
      gv_current_person_obj := par_person_obj;
    END set_current_object;
  
    -- Валидация
    PROCEDURE validate_contact_object(par_person_obj t_person_object) IS
    BEGIN
      assert_deprecated(TRIM(par_person_obj.name) IS NULL
            ,'Фамилия контакта не может быть пустой');
      assert_deprecated(TRIM(par_person_obj.gender) IS NULL
            ,'Пол контакта не может быть пустым');
      assert_deprecated(par_person_obj.date_of_birth IS NULL
            ,'День рождения контакта должен быть указан');
    
      IF nvl(par_person_obj.has_additional_citizenship, 0) = 0
         AND par_person_obj.additional_citizenship IS NOT NULL
         AND par_person_obj.additional_citizenship.count > 0
      THEN
        ex.raise_custom('У контакта должен быть выставлен признак наличия гражданств других государств');
      ELSIF par_person_obj.has_additional_citizenship = 1
            AND (par_person_obj.additional_citizenship IS NULL OR
            par_person_obj.additional_citizenship.count = 0)
      THEN
        ex.raise_custom('У контакта не должен быть выставлен признак наличия гражданств других государств');
      END IF;
    
      IF nvl(par_person_obj.has_foreign_residency, 0) = 0
         AND par_person_obj.residency_country_list IS NOT NULL
         AND par_person_obj.residency_country_list.count > 0
      THEN
        ex.raise_custom('У контакта должен быть выставлен признак наличия вида на жительство в других государствах');
      ELSIF par_person_obj.has_foreign_residency = 1
            AND (par_person_obj.residency_country_list IS NULL AND
            par_person_obj.residency_country_list.count = 0)
      THEN
        ex.raise_custom('У контакта не должен быть выставлен признак наличия вида на жительство в других государствах');
      END IF;
    END validate_contact_object;
  
    -- Определение ИД типа контакта по брифу
    FUNCTION get_contact_type_id(par_contact_type_brief VARCHAR2) RETURN t_contact_type.id%TYPE IS
      v_contact_type_id t_contact_type.id%TYPE;
    BEGIN
      BEGIN
        SELECT MAX(id)
          INTO v_contact_type_id
          FROM t_contact_type ct
         WHERE ct.brief = par_contact_type_brief
           AND ct.upper_level_id IS NOT NULL;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не удалось определить тип контакта по брифу');
      END;
      RETURN v_contact_type_id;
    END get_contact_type_id;
    -- Определение ИД семейного положения
    FUNCTION get_family_status_id(par_family_status_desc VARCHAR2) RETURN t_family_status.id%TYPE IS
      v_family_status_id t_family_status.id%TYPE;
    BEGIN
      IF par_family_status_desc IS NOT NULL
      THEN
        v_family_status_id := dml_t_family_status.get_id_by_description(par_family_status_desc);
      END IF;
      RETURN v_family_status_id;
    END get_family_status_id;
    -- Определение ИД профессии
    FUNCTION get_profession_id(par_profession_desc VARCHAR2) RETURN t_profession.id%TYPE IS
      v_profession_id t_profession.id%TYPE;
    BEGIN
      IF par_profession_desc IS NOT NULL
      THEN
        BEGIN
          SELECT id
            INTO v_profession_id
            FROM t_profession p
           WHERE p.description = par_profession_desc;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось определить профессию по названию');
          WHEN too_many_rows THEN
            raise_application_error(-20001
                                   ,'Найдено несколько профессий по названию');
        END;
      END IF;
      RETURN v_profession_id;
    END get_profession_id;
    -- Определение ИД образования
    FUNCTION get_education_id(par_education_desc VARCHAR2) RETURN t_education.id%TYPE IS
      v_education_id t_education.id%TYPE;
    BEGIN
      IF par_education_desc IS NOT NULL
      THEN
        v_education_id := dml_t_education.get_id_by_description(par_education_desc);
      END IF;
      RETURN v_education_id;
    END get_education_id;
    -- Определение ИД обращения
    FUNCTION get_title_id(par_title_desc VARCHAR2) RETURN t_title.id%TYPE IS
      v_title_id t_title.id%TYPE;
    BEGIN
      IF par_title_desc IS NOT NULL
      THEN
        BEGIN
          SELECT id INTO v_title_id FROM t_title t WHERE t.description = par_title_desc;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001, 'Не найдено обращение');
          WHEN too_many_rows THEN
            raise_application_error(-20001, 'Найдено несколько обращений');
        END;
      END IF;
      RETURN v_title_id;
    END get_title_id;
    -- Определение ИД хобби
    FUNCTION get_hobby_id(par_hobby_desc VARCHAR2) RETURN t_hobby.t_hobby_id%TYPE IS
      v_hobby_id t_hobby.t_hobby_id%TYPE;
    BEGIN
      IF par_hobby_desc IS NOT NULL
      THEN
        BEGIN
          SELECT t_hobby_id INTO v_hobby_id FROM t_hobby h WHERE h.description = par_hobby_desc;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось определить хобби по названию');
          WHEN too_many_rows THEN
            raise_application_error(-20001
                                   ,'Найдено неколько хобби по названию');
        END;
      END IF;
      RETURN v_hobby_id;
    END get_hobby_id;
  
    -- Комплексный поиск контакта
    FUNCTION find_person(par_person_obj t_person_object) RETURN contact.contact_id%TYPE IS
      v_person_id                  contact.contact_id%TYPE;
      v_search_string              contact.obj_name%TYPE;
      v_ident_doc_exists_in_object NUMBER(1);
      v_gender_id                  NUMBER;
    BEGIN
      SELECT upper(par_person_obj.name ||
                   decode(par_person_obj.first_name, NULL, '', ' ' || par_person_obj.first_name) ||
                   decode(par_person_obj.middle_name, NULL, '', ' ' || par_person_obj.middle_name))
        INTO v_search_string
        FROM dual;
    
      v_gender_id := pkg_contact.get_gender_id_by_brief(par_person_obj.gender);
    
      -- Проверяем наличие идентифицирующих документов у контакта, чтобы определить методику поиска
      -- Пытаемся найти по ФИО+Д.Р. или плюс идентифицирующий документ, если такой есть.
      -- Если найдено несколько - выбираем последнего, кто был страхователем по договору
      SELECT COUNT(*)
        INTO v_ident_doc_exists_in_object
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM TABLE(pkg_contact_object.get_current_contact_id_docs) t
                    ,t_id_type t
               WHERE t.id_doc_type_brief = t.brief
                 AND t.is_identification_document = 1
                 AND t.id_value IS NOT NULL);
    
      BEGIN
        IF v_ident_doc_exists_in_object = 0
        THEN
          SELECT contact_id
            INTO v_person_id
            FROM (SELECT c.contact_id
                    FROM ven_cn_person c
                   WHERE c.obj_name = v_search_string
                     AND c.date_of_birth = par_person_obj.date_of_birth
                     AND c.gender = v_gender_id
                     AND nvl(c.is_public_contact, 0) = nvl(par_person_obj.is_public_contact, 0)
                     AND nvl(c.is_in_list, 0) = nvl(par_person_obj.is_rpdl, 0)
                   ORDER BY CASE
                              WHEN NOT EXISTS (SELECT NULL
                                      FROM cn_contact_ident cci
                                     WHERE cci.contact_id = c.contact_id) THEN
                               0
                              ELSE
                               1
                            END ASC)
           WHERE rownum = 1;
        ELSE
          WITH current_contact_ident AS
           (SELECT /*+materialize cardinality(5)*/
             *
              FROM TABLE(pkg_contact_object.get_current_contact_id_docs))
          SELECT c.contact_id
            INTO v_person_id
            FROM ven_cn_person c
           WHERE c.obj_name = v_search_string
             AND c.date_of_birth = par_person_obj.date_of_birth
             AND c.gender = v_gender_id
             AND nvl(c.is_public_contact, 0) = nvl(par_person_obj.is_public_contact, 0)
             AND nvl(c.is_in_list, 0) = nvl(par_person_obj.is_rpdl, 0)
             AND EXISTS (SELECT NULL
                    FROM cn_contact_ident ci
                        ,t_id_type idt
                        ,current_contact_ident t
                   WHERE c.contact_id = ci.contact_id
                     AND ci.id_type = idt.id
                     AND idt.is_identification_document = 1
                     AND t.id_doc_type_brief = idt.brief
                     AND t.id_value = ci.id_value
                     AND decode(ci.serial_nr, t.series_nr, 1, 0) = 1
                     AND t.issue_date = ci.issue_date);
        END IF;
      
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
        WHEN too_many_rows THEN
          /*
          414068: ХКФ CR92 15.5.2015 Черных М. Выдавалось сообщение too_many_rows (ORA-01422) из функции pkg_contact_object.get_current_contact_id_docs
          переписано через +materialize
          */
          SELECT con.contact_id
            INTO v_person_id
            FROM (WITH current_contact_ident AS (SELECT /*+materialize cardinality(5)*/
                                                  *
                                                   FROM TABLE(pkg_contact_object.get_current_contact_id_docs))
                   SELECT p.contact_id
                        ,ph.start_date
                    FROM contact      c
                        ,cn_person    p
                        ,v_pol_issuer vpi
                        ,p_policy     pp
                        ,p_pol_header ph
                   WHERE c.contact_id = p.contact_id
                     AND c.obj_name = v_search_string
                     AND p.date_of_birth = par_person_obj.date_of_birth
                     AND p.gender = v_gender_id
                     AND nvl(c.is_public_contact, 0) = nvl(par_person_obj.is_public_contact, 0)
                     AND nvl(p.is_in_list, 0) = nvl(par_person_obj.is_rpdl, 0)
                     AND EXISTS (SELECT NULL
                            FROM cn_contact_ident ci
                                ,t_id_type it
                                 ,current_contact_ident t
                           WHERE ci.contact_id = p.contact_id
                             AND ci.id_type = it.id
                             AND it.is_identification_document = 1
                             AND it.brief = t.id_doc_type_brief
                             AND decode(ci.serial_nr, t.series_nr, 1, 0) = 1
                             AND ci.id_value = t.id_value
                             AND ci.issue_date = t.issue_date)
                     AND vpi.contact_id(+) = c.contact_id
                     AND pp.policy_id(+) = vpi.policy_id
                     AND ph.policy_header_id(+) = pp.pol_header_id
                   ORDER BY ph.start_date DESC) con
           WHERE rownum = 1;
      END;
      RETURN v_person_id;
    END find_person;
  
    -- Процедура создания контакта из объекта
    PROCEDURE create_person
    (
      par_person_obj     t_person_object
     ,par_contact_id_out OUT contact.contact_id%TYPE
    ) IS
      v_contact_status_id t_contact_status.t_contact_status_id%TYPE;
      v_contact_type_id   t_contact_type.id%TYPE;
      v_gender_id         t_gender.id%TYPE;
      v_family_status_id  t_family_status.id%TYPE;
      v_profession_id     t_profession.id%TYPE;
      v_education_id      t_education.id%TYPE;
      v_country_birth_id  t_country.id%TYPE;
      v_title_id          t_title.id%TYPE;
      v_hobby_id          t_hobby.t_hobby_id%TYPE;
      v_risk_level_id     t_risk_level.t_risk_level_id%TYPE;
    
    BEGIN
      SELECT sq_contact.nextval INTO par_contact_id_out FROM dual;
    
      v_contact_status_id := dml_t_contact_status.get_id_by_name(par_person_obj.contact_status_name);
      v_contact_type_id   := get_contact_type_id(par_person_obj.contact_type_brief);
      v_gender_id         := pkg_contact.get_gender_id_by_brief(par_person_obj.gender);
      v_family_status_id  := get_family_status_id(par_person_obj.family_status_desc);
      v_profession_id     := get_profession_id(par_person_obj.profession_desc);
      v_education_id      := get_education_id(par_person_obj.education_desc);
      v_country_birth_id  := get_country_id(par_person_obj.country_birth_name
                                           ,par_person_obj.country_birth_alpha3);
      v_title_id          := get_title_id(par_person_obj.title_desc);
      v_hobby_id          := get_hobby_id(par_person_obj.hobby_desc);
      v_risk_level_id     := dml_t_risk_level.get_id_by_brief(par_person_obj.risk_level_brief);
    
      INSERT INTO ven_cn_person
        (contact_id
        ,contact_type_id
        ,t_contact_status_id
        ,NAME
        ,first_name
        ,middle_name
        ,latin_name
        ,date_of_birth
        ,gender
        ,pers_acc
        ,risk_level
        ,family_status
        ,profession
        ,education
        ,country_birth
        ,title
        ,childrens
        ,adult_children
        ,standing
        ,hobby_id
        ,smoke_id
        ,work_place
        ,post
        ,no_standart_name
        ,place_of_birth
        ,resident_flag
        ,is_public_contact
        ,is_in_list
        ,date_of_death
        ,note
        ,has_additional_citizenship
        ,has_foreign_residency
        ,profile_login
        ,profile_pass)
      VALUES
        (par_contact_id_out
        ,v_contact_type_id
        ,v_contact_status_id
        ,par_person_obj.name
        ,par_person_obj.first_name
        ,par_person_obj.middle_name
        ,par_person_obj.latin_name
        ,par_person_obj.date_of_birth
        ,v_gender_id
        ,par_person_obj.pers_acc
        ,v_risk_level_id
        ,v_family_status_id
        ,v_profession_id
        ,v_education_id
        ,v_country_birth_id
        ,v_title_id
        ,par_person_obj.children_count
        ,par_person_obj.adult_children_count
        ,par_person_obj.standing
        ,v_hobby_id
        ,par_person_obj.is_smoker
        ,par_person_obj.work_place
        ,par_person_obj.post
        ,par_person_obj.no_standard_name
        ,par_person_obj.place_of_birth
        ,nvl(par_person_obj.resident_flag, 1)
        ,par_person_obj.is_public_contact
        ,par_person_obj.is_rpdl
        ,par_person_obj.date_of_death
        ,par_person_obj.note
        ,par_person_obj.has_additional_citizenship
        ,par_person_obj.has_foreign_residency
        ,par_person_obj.profile_login
        ,par_person_obj.profile_pass);
    
    END create_person;
  
    PROCEDURE update_person
    (
      par_person_obj t_person_object
     ,par_contact_id contact.contact_id%TYPE
    ) IS
      v_country_birth_id  t_country.id%TYPE;
      v_contact_status_id t_contact_status.t_contact_status_id%TYPE;
      v_contact_type_id   t_contact_type.id%TYPE;
      v_gender_id         t_gender.id%TYPE;
      v_family_status_id  t_family_status.id%TYPE;
      v_profession_id     t_profession.id%TYPE;
      v_education_id      t_education.id%TYPE;
      v_title_id          t_title.id%TYPE;
      v_hobby_id          t_hobby.t_hobby_id%TYPE;
      v_risk_level_id     t_risk_level.t_risk_level_id%TYPE;
    BEGIN
    
      v_country_birth_id := get_country_id(par_person_obj.country_birth_name
                                          ,par_person_obj.country_birth_alpha3);
    
      v_contact_status_id := dml_t_contact_status.get_id_by_name(par_person_obj.contact_status_name);
      v_contact_type_id   := get_contact_type_id(par_person_obj.contact_type_brief);
      v_gender_id         := pkg_contact.get_gender_id_by_brief(par_person_obj.gender);
      v_family_status_id  := get_family_status_id(par_person_obj.family_status_desc);
      v_profession_id     := get_profession_id(par_person_obj.profession_desc);
      v_education_id      := get_education_id(par_person_obj.education_desc);
      v_title_id          := get_title_id(par_person_obj.title_desc);
      v_hobby_id          := get_hobby_id(par_person_obj.hobby_desc);
      v_risk_level_id     := dml_t_risk_level.get_id_by_brief(par_person_obj.risk_level_brief);
    
      UPDATE contact c
         SET c.name                = nvl(c.name, par_person_obj.name)
            ,c.first_name          = nvl(c.first_name, par_person_obj.first_name)
            ,c.middle_name         = nvl(c.middle_name, par_person_obj.middle_name)
            ,c.contact_type_id     = nvl(c.contact_type_id, v_contact_type_id)
            ,c.latin_name          = nvl(c.latin_name, par_person_obj.latin_name)
            ,c.resident_flag       = nvl(c.resident_flag, par_person_obj.resident_flag)
            ,c.t_contact_status_id = nvl(c.t_contact_status_id, v_contact_status_id)
            ,c.pers_acc            = nvl(c.pers_acc, par_person_obj.pers_acc)
            ,c.risk_level          = nvl(c.risk_level, v_risk_level_id)
            ,c.is_public_contact   = nvl(c.is_public_contact, par_person_obj.is_public_contact)
       WHERE c.contact_id = par_contact_id;
    
      UPDATE cn_person c
         SET c.date_of_birth    = nvl(c.date_of_birth, par_person_obj.date_of_birth)
            ,c.gender           = nvl(c.gender, v_gender_id)
            ,c.family_status    = nvl(c.family_status, v_family_status_id)
            ,c.profession       = nvl(c.profession, v_profession_id)
            ,c.education        = nvl(c.education, v_education_id)
            ,c.country_birth    = nvl(c.country_birth, v_country_birth_id)
            ,c.title            = nvl(c.title, v_title_id)
            ,c.childrens        = nvl(c.childrens, par_person_obj.children_count)
            ,c.adult_children   = nvl(c.adult_children, par_person_obj.adult_children_count)
            ,c.date_of_death    = nvl(c.date_of_death, par_person_obj.date_of_death)
            ,c.standing         = nvl(c.standing, par_person_obj.standing)
            ,c.hobby_id         = nvl(c.hobby_id, v_hobby_id)
            ,c.smoke_id         = nvl(c.smoke_id, par_person_obj.is_smoker)
            ,c.work_place       = nvl(c.work_place, par_person_obj.work_place)
            ,c.post             = nvl(c.post, par_person_obj.post)
            ,c.no_standart_name = nvl(c.no_standart_name, par_person_obj.no_standard_name)
            ,c.place_of_birth   = nvl(c.place_of_birth, par_person_obj.place_of_birth)
            ,c.is_in_list       = nvl(c.is_in_list, par_person_obj.is_rpdl)  
            ,c.has_additional_citizenship = nvl(c.has_additional_citizenship
                                               ,par_person_obj.has_additional_citizenship)
            ,c.has_foreign_residency      = nvl(c.has_foreign_residency
                                               ,par_person_obj.has_foreign_residency)
       WHERE c.contact_id = par_contact_id;
    
    END update_person;
  
  BEGIN
    validate_contact_object(par_person_obj);
    -- Записываем в global variable, чтобы потом пользовать из pipelined functions
    set_current_object(par_person_obj);
  
    -- Пытаемся найти контакт, если заведомо не знаем его
    IF par_contact_id IS NULL
    THEN
      par_contact_id := find_person(par_person_obj);
    END IF;
  
    -- Если контакт не найден - создаем новый контакт из переданного объекта
    IF par_contact_id IS NULL
    THEN
      create_person(par_person_obj => par_person_obj, par_contact_id_out => par_contact_id);
    ELSE
      update_person(par_person_obj => par_person_obj, par_contact_id => par_contact_id);
    END IF;
  
    -- Заполняем информацию о паспортах, контакта, телефонах, и тд.
    merge_id_doc_into_contact(par_contact_id   => par_contact_id
                             ,par_id_doc_array => par_person_obj.id_doc_array);
    merge_address_into_contact(par_contact_id    => par_contact_id
                              ,par_address_array => par_person_obj.address_array);
    merge_phone_into_contact(par_contact_id  => par_contact_id
                            ,par_phone_array => par_person_obj.phone_array);
    merge_bank_acc_into_contact(par_contact_id     => par_contact_id
                               ,par_bank_acc_array => par_person_obj.bank_acc_array);
    merge_email_into_contact(par_contact_id  => par_contact_id
                            ,par_email_array => par_person_obj.email_array);
  
    /*
    TODO: owner="Pavel.Kaplya" category="Fix" created="14.08.2014"
    text="Здесь необходимо продумать как эти действия должны сочитаться 
          с проставлением соответствующего флага у контакта.
          Сейчас, к примеру, если сначала указано гражданство, а потом список очищен, 
          то у контакта он не удалится.
          Предолженное решение - временное и на скорую руку"
    */
    IF par_person_obj.has_additional_citizenship = 1
    THEN
      update_additional_citiz(par_contact_id       => par_contact_id
                             ,par_citizenship_list => par_person_obj.additional_citizenship);
    ELSIF par_person_obj.has_additional_citizenship = 0
    THEN
      delete_add_citizenships(par_contact_id => par_contact_id);
    END IF;
  
    IF par_person_obj.has_foreign_residency = 1
    THEN
      update_residency(par_contact_id     => par_contact_id
                      ,par_residency_list => par_person_obj.residency_country_list);
    ELSIF par_person_obj.has_foreign_residency = 0
    THEN
      delete_residencies(par_contact_id => par_contact_id);
    END IF;
  
  END process_person_object;

  /*
    Капля П.
    10.11.2013
    Получение массива идентифицирующих документов по контакту из базы
  */
  FUNCTION get_contact_id_doc_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_id_doc IS
    va_id_docs tt_contact_id_doc;
  BEGIN
    SELECT it.brief
          ,cci.id_value
          ,cci.serial_nr
          ,cci.issue_date
          ,cci.place_of_issue
          ,cci.is_default
          ,c.description
          ,c.alfa3
          ,cci.subdivision_code
          ,cci.is_used
          ,cci.is_temp
          ,cci.termination_date BULK COLLECT
      INTO va_id_docs
      FROM cn_contact_ident cci
          ,t_id_type        it
          ,t_country        c
     WHERE cci.contact_id = par_contact_id
       AND TRIM(cci.id_value) IS NOT NULL
       AND cci.id_type = it.id(+)
       AND cci.country_id = c.id(+);
  
    RETURN va_id_docs;
  
  END get_contact_id_doc_array;

  /*
    Капля П.
    10.11.2013
    Получение массива телефонов по контакту из базы
  */
  FUNCTION get_contact_telephone_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_phone IS
    va_telephones tt_contact_phone;
  BEGIN
    SELECT ttt.brief
          ,cct.telephone_prefix
          ,cct.telephone_extension
          ,cct.telephone_number
          ,(SELECT c.description
              FROM t_country           c
                  ,t_country_dial_code cdc
             WHERE c.id = cdc.country_id
               AND cct.country_id = cdc.id) country_desc
          ,(SELECT c.alfa3
              FROM t_country           c
                  ,t_country_dial_code cdc
             WHERE c.id = cdc.country_id
               AND cct.country_id = cdc.id) country_alpha3
          ,cct.status
          ,cct.control
          ,cct.is_temp BULK COLLECT
      INTO va_telephones
      FROM cn_contact_telephone cct
          ,t_telephone_type     ttt
     WHERE cct.contact_id = par_contact_id
       AND cct.telephone_type = ttt.id(+)
       AND regexp_replace(cct.telephone_number, gc_phone_replace_symbols) IS NOT NULL;
  
    RETURN va_telephones;
  
  END get_contact_telephone_array;
  /*
    Капля П.
    10.11.2013
    Получение массива адресов по контакту из базы
  */
  FUNCTION get_contact_address_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_address IS
    va_addresses tt_contact_address;
  BEGIN
    SELECT at.brief
          ,cca.is_default
          ,pkg_contact.get_address_name(ca.id)
          ,(SELECT c.description FROM t_country c WHERE c.id = ca.country_id) country_desc
          ,(SELECT c.alfa3 FROM t_country c WHERE c.id = ca.country_id) country_alpha3
          ,cca.is_temp BULK COLLECT
      INTO va_addresses
      FROM cn_contact_address cca
          ,cn_address         ca
          ,t_address_type     at
     WHERE cca.contact_id = par_contact_id
       AND cca.adress_id = ca.id(+)
       AND cca.address_type = at.id(+)
       AND pkg_contact.get_address_name(ca.id) IS NOT NULL;
  
    RETURN va_addresses;
  
  END get_contact_address_array;
  /*
    Капля П.
    10.11.2013
    Получение массива банковских реквизитов по контакту из базы
  */
  FUNCTION get_contact_bank_acc_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_bank_acc IS
    va_bank_accounts tt_contact_bank_acc;
  BEGIN
    SELECT (SELECT obj_name_orig FROM contact b WHERE b.contact_id = cba.bank_id) bank_name
          ,branch_name
          ,account_nr
          ,bic_code
          ,c.description
          ,c.alfa3
          ,f.brief
          ,iban_reference
          ,swift_code
          ,account_corr
          ,lic_code
          ,owner_contact_id
          ,is_check_owner
          ,cba.place_of_issue
          ,cba.used_flag
          ,cba.remarks
          ,cba.bank_approval_reference
          ,cba.bank_approval_date
          ,cba.bank_approval_end_date
          ,cba.order_number
          ,cba.is_temp BULK COLLECT
      INTO va_bank_accounts
      FROM cn_contact_bank_acc cba
          ,t_country           c
          ,fund                f
     WHERE cba.contact_id = par_contact_id
       AND cba.country_id = c.id(+)
       AND cba.bank_account_currency_id = f.fund_id(+);
  
    RETURN va_bank_accounts;
  
  END get_contact_bank_acc_array;

  /*
    Капля П.
    10.11.2013
    Получение массива e-mail адресов по контакту из базы
  */
  FUNCTION get_contact_email_array(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_email IS
    va_emails tt_contact_email;
  BEGIN
    SELECT cce.email
          ,et.description
          ,cce.status
          ,cce.is_temp BULK COLLECT
      INTO va_emails
      FROM cn_contact_email cce
          ,t_email_type     et
     WHERE cce.contact_id = par_contact_id
       AND cce.email_type = et.id(+)
       AND TRIM(cce.email) IS NOT NULL;
  
    RETURN va_emails;
  
  END get_contact_email_array;

  /*
    Капля П.
    08.08.2014
    Получение массива дополнительных гражданств по контакту из базы
  */
  FUNCTION get_contact_add_citizenship(par_contact_id contact.contact_id%TYPE)
    RETURN tt_contact_country_list IS
    va_countries tt_contact_country_list;
  BEGIN
    SELECT c.description
          ,c.alfa3 BULK COLLECT
      INTO va_countries
      FROM cn_contact_add_citizenship ccac
          ,t_country                  c
     WHERE ccac.contact_id = par_contact_id
       AND ccac.country_id = c.id;
  
    RETURN va_countries;
  
  END get_contact_add_citizenship;

  /*
    Капля П.
    08.08.2014
    Получение массива дополнительных гражданств по контакту из базы
  */
  FUNCTION get_contact_residency(par_contact_id contact.contact_id%TYPE) RETURN tt_contact_country_list IS
    va_countries tt_contact_country_list;
  BEGIN
    SELECT c.description
          ,c.alfa3 BULK COLLECT
      INTO va_countries
      FROM cn_contact_residency ccr
          ,t_country            c
     WHERE ccr.contact_id = par_contact_id
       AND ccr.country_id = c.id;
  
    RETURN va_countries;
  
  END get_contact_residency;

  /*
    Капля П.С.
    18.11.2013
    Добавление строки документа в объект
  */
  PROCEDURE add_id_doc_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_id_doc_rec     t_contact_id_doc_rec
  ) IS
  BEGIN
    IF par_contact_object.id_doc_array IS NULL
    THEN
      par_contact_object.id_doc_array := tt_contact_id_doc(par_id_doc_rec);
    ELSE
      -- Только один документ должен быть с флагом "Используется"
      FOR i IN 1 .. par_contact_object.id_doc_array.count()
      LOOP
        IF par_contact_object.id_doc_array(i).id_doc_type_brief = par_id_doc_rec.id_doc_type_brief
            AND par_contact_object.id_doc_array(i).is_used = 1
        THEN
          par_contact_object.id_doc_array(i).is_used := 0;
        END IF;
      END LOOP;
    
      par_contact_object.id_doc_array.extend(1);
      par_contact_object.id_doc_array(par_contact_object.id_doc_array.last) := par_id_doc_rec;
    END IF;
  END add_id_doc_rec_to_object;

  /*
    Капля П.С.
    18.11.2013
    Добавление адреса в объект
  */
  PROCEDURE add_address_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_address_rec    t_contact_address_rec
  ) IS
  BEGIN
    assert_deprecated(TRIM(par_address_rec.address) IS NULL, 'Адрес не может быть пустым');
  
    IF par_contact_object.address_array IS NULL
    THEN
      par_contact_object.address_array := tt_contact_address(par_address_rec);
    ELSE
      par_contact_object.address_array.extend(1);
      par_contact_object.address_array(par_contact_object.address_array.last) := par_address_rec;
    END IF;
  END add_address_rec_to_object;

  /*
    Капля П.С.
    18.11.2013
    Добавление телефона в объект
  */
  PROCEDURE add_phone_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_phone_rec      t_contact_phone_rec
  ) IS
  BEGIN
  
    assert_deprecated(regexp_replace(par_phone_rec.phone_number, gc_phone_replace_symbols) IS NULL
          ,'Телефон не может быть пуст');
  
    IF par_contact_object.phone_array IS NULL
    THEN
      par_contact_object.phone_array := tt_contact_phone(par_phone_rec);
    ELSE
      par_contact_object.phone_array.extend(1);
      par_contact_object.phone_array(par_contact_object.phone_array.last) := par_phone_rec;
    END IF;
  END add_phone_rec_to_object;

  /*
    Капля П.С.
    18.11.2013
    Добавление банковского реквизита в объект
  */
  PROCEDURE add_bank_acc_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_bank_acc_rec   t_contact_bank_acc_rec
  ) IS
  BEGIN
    IF par_contact_object.bank_acc_array IS NULL
    THEN
      par_contact_object.bank_acc_array := tt_contact_bank_acc(par_bank_acc_rec);
    ELSE
      par_contact_object.bank_acc_array.extend(1);
      par_contact_object.bank_acc_array(par_contact_object.bank_acc_array.last) := par_bank_acc_rec;
    END IF;
  END add_bank_acc_rec_to_object;

  /*
    Капля П.С.
    18.11.2013
    Добавление электронной почты в объект
  */
  PROCEDURE add_email_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_email_rec      t_contact_email_rec
  ) IS
  BEGIN
    assert_deprecated(TRIM(par_email_rec.email) IS NULL, 'Email не может быть пуст');
  
    IF par_contact_object.email_array IS NULL
    THEN
      par_contact_object.email_array := tt_contact_email(par_email_rec);
    ELSE
      par_contact_object.email_array.extend(1);
      par_contact_object.email_array(par_contact_object.email_array.last) := par_email_rec;
    END IF;
  END add_email_rec_to_object;

  PROCEDURE add_additional_citizenship
  (
    par_contact_object  IN OUT NOCOPY t_person_object
   ,par_citizenship_rec t_contact_country_rec
  ) IS
  BEGIN
    assert_deprecated(TRIM(par_citizenship_rec.country_alpha3) IS NULL AND
           TRIM(par_citizenship_rec.country_name) IS NULL
          ,'Страна дополнительного гражданства должна быть заполнена');
  
    IF par_contact_object.additional_citizenship IS NULL
    THEN
      par_contact_object.additional_citizenship := tt_contact_country_list(par_citizenship_rec);
    ELSE
      par_contact_object.additional_citizenship.extend;
      par_contact_object.additional_citizenship(par_contact_object.additional_citizenship.last) := par_citizenship_rec;
    END IF;
  
  END add_additional_citizenship;

  PROCEDURE add_residency_rec_to_object
  (
    par_contact_object IN OUT NOCOPY t_person_object
   ,par_residency_rec  t_contact_country_rec
  ) IS
  BEGIN
    assert_deprecated(TRIM(par_residency_rec.country_alpha3) IS NULL AND
           TRIM(par_residency_rec.country_name) IS NULL
          ,'Страна дополнительного гражданства должна быть заполнена');
  
    IF par_contact_object.residency_country_list IS NULL
    THEN
      par_contact_object.residency_country_list := tt_contact_country_list(par_residency_rec);
    ELSE
      par_contact_object.residency_country_list.extend;
      par_contact_object.residency_country_list(par_contact_object.residency_country_list.last) := par_residency_rec;
    END IF;
  
  END add_residency_rec_to_object;

  /*
    Капля П.
    10.11.2013
    Получение объекта контакта по контакту из базы
  */
  FUNCTION person_object_from_contact(par_contact_id contact.contact_id%TYPE) RETURN t_person_object IS
    v_person_object t_person_object;
  BEGIN
    /* Собираем информацию с контакта */
    BEGIN
      SELECT c.name
            ,c.first_name
            ,c.middle_name
            ,c.latin_name
            ,(SELECT cs.name
                FROM t_contact_status cs
               WHERE cs.t_contact_status_id = c.t_contact_status_id) contact_status_name
            ,(SELECT ct.brief FROM t_contact_type ct WHERE ct.id = c.contact_type_id) contact_type_brief
            ,cp.date_of_birth
            ,(SELECT brief FROM t_gender g WHERE g.id = cp.gender) gender
            ,c.pers_acc
            ,(SELECT r.brief FROM t_risk_level r WHERE r.t_risk_level_id = c.risk_level) risk_level_brief
            ,(SELECT fs.description FROM t_family_status fs WHERE fs.id = cp.family_status) family_status_desc
            ,(SELECT p.description FROM t_profession p WHERE p.id = cp.profession) profession_desc
            ,(SELECT e.description FROM t_education e WHERE e.id = cp.education) education_desc
            ,(SELECT co.description FROM t_country co WHERE co.id = cp.country_birth) country_birth_name
            ,(SELECT tt.description FROM t_title tt WHERE tt.id = cp.title) title_desc
            ,cp.childrens
            ,cp.adult_children
            ,cp.standing
            ,(SELECT h.description FROM t_hobby h WHERE h.t_hobby_id = cp.hobby_id) hobby_desc
            ,cp.smoke_id
            ,cp.work_place
            ,cp.post
            ,cp.no_standart_name
            ,cp.place_of_birth
            ,c.resident_flag
            ,c.is_public_contact
            ,cp.is_in_list
            ,cp.date_of_death
            ,c.profile_login
            ,c.profile_pass
            ,c.note
            ,cp.has_additional_citizenship
            ,cp.has_foreign_residency
        INTO v_person_object.name
            ,v_person_object.first_name
            ,v_person_object.middle_name
            ,v_person_object.latin_name
            ,v_person_object.contact_status_name
            ,v_person_object.contact_type_brief
            ,v_person_object.date_of_birth
            ,v_person_object.gender
            ,v_person_object.pers_acc
            ,v_person_object.risk_level_brief
            ,v_person_object.family_status_desc
            ,v_person_object.profession_desc
            ,v_person_object.education_desc
            ,v_person_object.country_birth_name
            ,v_person_object.title_desc
            ,v_person_object.children_count
            ,v_person_object.adult_children_count
            ,v_person_object.standing
            ,v_person_object.hobby_desc
            ,v_person_object.is_smoker
            ,v_person_object.work_place
            ,v_person_object.post
            ,v_person_object.no_standard_name
            ,v_person_object.place_of_birth
            ,v_person_object.resident_flag
            ,v_person_object.is_public_contact
            ,v_person_object.is_rpdl
            ,v_person_object.date_of_death
            ,v_person_object.profile_login
            ,v_person_object.profile_pass
            ,v_person_object.note
            ,v_person_object.has_additional_citizenship
            ,v_person_object.has_foreign_residency
        FROM contact   c
            ,cn_person cp
       WHERE c.contact_id = par_contact_id
         AND c.contact_id = cp.contact_id(+);
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не удалось найти физ. лицо по ИД');
    END;
  
    /* Собираем документы контакта */
    v_person_object.id_doc_array := get_contact_id_doc_array(par_contact_id => par_contact_id);
    /* Собираем адреса контакта */
    v_person_object.address_array := get_contact_address_array(par_contact_id => par_contact_id);
    /* Собираем телефоны контакта */
    v_person_object.phone_array := get_contact_telephone_array(par_contact_id => par_contact_id);
    /* Собираем банковские счета */
    v_person_object.bank_acc_array := get_contact_bank_acc_array(par_contact_id => par_contact_id);
    /* Собираем email'ы */
    v_person_object.email_array := get_contact_email_array(par_contact_id => par_contact_id);
    /* Собираем дополнительные гражданства */
    v_person_object.additional_citizenship := get_contact_add_citizenship(par_contact_id => par_contact_id);
    /* Собираем виды на жительства в других странах */
    v_person_object.residency_country_list := get_contact_residency(par_contact_id => par_contact_id);
  
    RETURN v_person_object;
  
  END person_object_from_contact;

BEGIN
  -- Initialization
  NULL;
END pkg_contact_object; 
/
