CREATE OR REPLACE PACKAGE pkg_load_policies IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 21.12.2012 17:35:37
  -- Purpose : Пакет используется для загрузки договоров через универсальный загрузчик

  /*
  Капля П.
  Функция проверки корректности рассчитанной премии при заливке.
  
  Доброхотова И., июнь, 2014
  Добавлен параметр par_accept_dev
  */
  PROCEDURE premium_check
  (
    par_policy_id        p_policy.policy_id%TYPE
   ,par_original_premium NUMBER
   ,par_accept_dev       NUMBER DEFAULT 0
  );

  /*
    Байтин А.
    Загрузка договоров продукта Приоритет Инвест (единовременный Инвестор) Сбербанк
      brief: Priority_Invest(lump)
  */
  PROCEDURE load_sber(par_load_file_rows_id NUMBER);

  /*
  Капля П.
  Загрузка договоров группы продуктов "Уверенный старт"
  brief: STRONG_START%
  */
  PROCEDURE load_strong_start(par_load_file_rows_id NUMBER);

  PROCEDURE load_strong_start_rus(par_load_file_rows_id NUMBER);
  /* 
  Черных М.
  Загрузка договоров группы продуктов ХКФ
  23.05.2014
  */
  PROCEDURE load_hkf_92_10(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);
  PROCEDURE load_hkf_92_9(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);
  PROCEDURE load_hkf_92_8(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);
  PROCEDURE load_hkf_92_7(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);
  /* 
  Капля П.
  Загрузка договоров группы продуктов ХКФ Комплекс */
  PROCEDURE load_hkf_92_6(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);
  PROCEDURE load_hkf_92_5(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);
  PROCEDURE load_hkf_92_4(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE);

  /*
  Загрузка договоров группы продуктов Рольф кредитка
  */
  -- Пакет 1
  PROCEDURE load_rolf_cr_1(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_1_1(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_1_2(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_1_3(par_load_file_rows_id NUMBER);

  --Пакет 2
  PROCEDURE load_rolf_cr_2(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_2_1(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_2_2(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_2_3(par_load_file_rows_id NUMBER);

  -- Новые продукты РОЛЬФ
  PROCEDURE load_rolf_cr_3(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_4(par_load_file_rows_id NUMBER);
  PROCEDURE load_rolf_cr_5(par_load_file_rows_id NUMBER);

  -- Автодом
  PROCEDURE load_avtodom_1(par_load_file_rows_id NUMBER);
  PROCEDURE load_avtodom_2(par_load_file_rows_id NUMBER);

  --АйМаниБанк
  PROCEDURE load_imoney_bank(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);

  /*
    Пиядин А. 287320 Продукт МКБ
    Загрузка договоров по кредитным продуктам МКБ
  */
  PROCEDURE load_mkb(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);

  /*
    Пиядин А. 293800  Продукт Накта
    Загрузка договоров по кредитным продуктам Накта CR113
  */
  PROCEDURE load_nakta_cr113(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);

  /*
    Капля П. 332801  Продукт Семейная защита ХКФ
    Загрузка договоров по кредитным продуктам Семейная защита для ХКФ
  */
  PROCEDURE load_family_protection_hkf(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);

  /*
    Капля П. 332801  Продукт Семейная защита ХКФ
    Проверка договоров по кредитным продуктам Семейная защита для ХКФ
  */
  PROCEDURE check_family_protection_hkf
  (
    par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );

END pkg_load_policies;
/
CREATE OR REPLACE PACKAGE BODY pkg_load_policies IS

  TYPE t_contact_info IS RECORD(
     NAME               contact.name%TYPE
    ,first_name         contact.first_name%TYPE
    ,middle_name        contact.middle_name%TYPE
    ,birth_date         cn_person.date_of_birth%TYPE
    ,gender             VARCHAR2(50)
    ,is_public_contact  NUMBER(1)
    ,pass_ser           cn_contact_ident.id_value%TYPE
    ,pass_num           cn_contact_ident.serial_nr%TYPE
    ,pass_who           cn_contact_ident.place_of_issue%TYPE
    ,pass_when          cn_contact_ident.issue_date%TYPE
    ,pass_subdivision_code cn_contact_ident.subdivision_code%TYPE
    ,address            VARCHAR2(1000)
    ,address_type_brief t_address_type.brief%TYPE
    ,phone_numbers      VARCHAR2(1000)
    ,phone_type         t_telephone_type.brief%TYPE
    ,email              cn_contact_email.email%TYPE);

  PROCEDURE create_contact
  (
    par_contact_info   t_contact_info
   ,par_contact_id_out OUT contact.contact_id%TYPE
  ) IS
  
    v_contact    pkg_contact_object.t_person_object;
    vr_ident_doc pkg_contact_object.t_contact_id_doc_rec;
    vr_address   pkg_contact_object.t_contact_address_rec;
    vr_phone     pkg_contact_object.t_contact_phone_rec;
    vr_email     pkg_contact_object.t_contact_email_rec;
  
    v_splitted tt_one_col;
  
    vc_default_email_type         CONSTANT t_email_type.description%TYPE := 'Адрес рассылки';
    vc_bordero_phone_type_brief   CONSTANT t_telephone_type.brief%TYPE := 'BORDERO';
    vc_default_address_type_brief CONSTANT t_address_type.brief%TYPE := 'DOMADD';
  BEGIN
    v_contact.first_name        := par_contact_info.first_name;
    v_contact.middle_name       := par_contact_info.middle_name;
    v_contact.name              := par_contact_info.name;
    v_contact.date_of_birth     := par_contact_info.birth_date;
    v_contact.gender            := par_contact_info.gender;
    v_contact.is_public_contact := par_contact_info.is_public_contact;
  
    /* Добавляем паспорт */
    IF TRIM(par_contact_info.pass_num) IS NOT NULL
    THEN
      vr_ident_doc.id_value       := par_contact_info.pass_num;
      vr_ident_doc.series_nr      := par_contact_info.pass_ser;
      vr_ident_doc.issue_date     := par_contact_info.pass_when;
      vr_ident_doc.place_of_issue := par_contact_info.pass_who;
      vr_ident_doc.subdivision_code := par_contact_info.pass_subdivision_code;
    
      pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact
                                                 ,par_id_doc_rec     => vr_ident_doc);
    END IF;
  
    /* Добавляем телефон */
    IF TRIM(par_contact_info.phone_numbers) IS NOT NULL
    THEN
      v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_contact_info.phone_numbers)
                                                 ,par_separator => ';');
      FOR i IN 1 .. v_splitted.count
      LOOP
        vr_phone.phone_type_brief := nvl(par_contact_info.phone_type, vc_bordero_phone_type_brief);
        vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
      
        IF vr_phone.phone_number IS NOT NULL
        THEN
          pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact
                                                    ,par_phone_rec      => vr_phone);
        END IF;
      END LOOP;
    END IF;
  
    /* Добавляем адрес */
    IF TRIM(par_contact_info.address) IS NOT NULL
    THEN
      vr_address.address_type_brief := nvl(par_contact_info.address_type_brief
                                          ,vc_default_address_type_brief);
      vr_address.address            := TRIM(par_contact_info.address);
      pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact
                                                  ,par_address_rec    => vr_address);
    END IF;
  
    /* Добавляем email */
    IF TRIM(par_contact_info.email) IS NOT NULL
    THEN
      vr_email.email_type_desc := vc_default_email_type;
      vr_email.email           := par_contact_info.email;
    
      pkg_contact_object.add_email_rec_to_object(par_contact_object => v_contact
                                                ,par_email_rec      => vr_email);
    END IF;
  
    pkg_contact_object.process_person_object(par_person_obj => v_contact
                                            ,par_contact_id => par_contact_id_out);
  
  END create_contact;

  /*
  Капля П.
  Функция проверки корректности рассчитанной премии при заливке.
  
  Доброхотова И., июнь, 2014
  Добавлен параметр par_accept_dev
  */
  PROCEDURE premium_check
  (
    par_policy_id        p_policy.policy_id%TYPE
   ,par_original_premium NUMBER
   ,par_accept_dev       NUMBER DEFAULT 0
  ) IS
    v_result_premium NUMBER;
  BEGIN
    SELECT pp.premium INTO v_result_premium FROM p_policy pp WHERE pp.policy_id = par_policy_id;
  
    IF v_result_premium NOT BETWEEN par_original_premium - abs(par_accept_dev) AND
       par_original_premium + abs(par_accept_dev)
    THEN
      raise_application_error(-20001
                             ,'Исходная премия не равна полученной (' || v_result_premium || ')');
    END IF;
  
  END premium_check;

  /*
    Байтин А.
    Загрузка договоров продукта Приоритет Инвест ... Сбербанк
      brief: Priority_Invest(lump)
      brief: Priority_Invest(regular)
  
      Неизветен Агент
  */
  PROCEDURE load_sber(par_load_file_rows_id NUMBER) IS
    TYPE t_persons IS RECORD(
       person_type_brief VARCHAR2(30)
      ,contact_id        NUMBER
      ,person_id         NUMBER
      ,person_surname    VARCHAR2(50)
      ,person_name       VARCHAR2(50)
      ,person_midname    VARCHAR2(50)
      ,is_public_contact NUMBER(1)
      ,person_gender     VARCHAR2(1)
      ,person_birthdate  DATE
      ,pasport_series    VARCHAR2(50)
      ,pasport_number    VARCHAR2(50)
      ,pasport_who       VARCHAR2(255)
      ,pasport_when      DATE
      ,phone_1           VARCHAR2(30)
      ,phone_1_type      NUMBER
      ,phone_2           VARCHAR2(30)
      ,phone_2_type      NUMBER
      ,email             VARCHAR2(50)
      ,address           cn_address.name%TYPE);
    TYPE tt_persons IS TABLE OF t_persons;
  
    v_persons        tt_persons := tt_persons();
    vr_policy_values pkg_products.t_product_defaults;
    vr_file_row      load_file_rows%ROWTYPE;
  
    v_product_brief         VARCHAR2(30);
    v_count_persons         NUMBER(1);
    v_dial_code_id          NUMBER;
    v_is_phone_exists         NUMBER(1);
    v_is_email_exists         NUMBER(1);
    v_end_date              DATE;
    v_fee_payment_term      NUMBER;
    v_pol_header_id         NUMBER;
    v_policy_id             NUMBER;
    v_assured_id            NUMBER;
    v_sales_channel_id      NUMBER;
    v_agency_id             NUMBER;
    v_region_id             NUMBER;
    v_ag_contract_header_id NUMBER;
    v_cn_contact_telephone_id NUMBER;
    v_email_id                NUMBER;
    v_sign_date             DATE;
    v_error_msg             VARCHAR2(2000);
    v_bso_series_id           bso_series.bso_series_id%TYPE;
    v_bso_id                  bso.bso_id%TYPE;
  
    PROCEDURE create_person
    (
      par_contact_info   t_persons
     ,par_contact_id_out OUT contact.contact_id%TYPE
    ) IS
      v_contact    pkg_contact_object.t_person_object;
      vr_ident_doc pkg_contact_object.t_contact_id_doc_rec;
      vr_address   pkg_contact_object.t_contact_address_rec;
      vr_phone     pkg_contact_object.t_contact_phone_rec;
      vr_email     pkg_contact_object.t_contact_email_rec;
    
      vc_default_email_type         CONSTANT VARCHAR2(14) := 'Адрес рассылки';
      vc_bordero_phone_type_brief   CONSTANT t_telephone_type.brief%TYPE := 'BORDERO';
      vc_default_address_type_brief CONSTANT t_address_type.brief%TYPE := 'DOMADD';
    BEGIN
      v_contact.first_name        := par_contact_info.person_name;
      v_contact.middle_name       := par_contact_info.person_midname;
      v_contact.name              := par_contact_info.person_surname;
      v_contact.date_of_birth     := par_contact_info.person_birthdate;
      v_contact.gender            := par_contact_info.person_gender;
      v_contact.is_public_contact := par_contact_info.is_public_contact;
      v_contact.note              := 'Загрузка Сбербанка';
    
      /* Добавляем паспорт */
      IF TRIM(par_contact_info.pasport_number) IS NOT NULL
      THEN
        vr_ident_doc.id_value       := par_contact_info.pasport_number;
        vr_ident_doc.series_nr      := par_contact_info.pasport_series;
        vr_ident_doc.issue_date     := par_contact_info.pasport_when;
        vr_ident_doc.place_of_issue := par_contact_info.pasport_who;
      
        pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact
                                                   ,par_id_doc_rec     => vr_ident_doc);
      END IF;
    
      /* Добавляем телефон 1 */
      IF TRIM(par_contact_info.phone_1) IS NOT NULL
      THEN
        vr_phone.phone_type_brief := nvl(par_contact_info.phone_1_type, vc_bordero_phone_type_brief);
        vr_phone.phone_number     := par_contact_info.phone_1;
      
        pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact
                                                  ,par_phone_rec      => vr_phone);
      END IF;
    
      /* Добавляем телефон 2 */
      IF TRIM(par_contact_info.phone_2) IS NOT NULL
      THEN
        vr_phone.phone_type_brief := nvl(par_contact_info.phone_2_type, vc_bordero_phone_type_brief);
        vr_phone.phone_number     := par_contact_info.phone_2;
      
        pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact
                                                  ,par_phone_rec      => vr_phone);
      END IF;
    
      /* Добавляем адрес */
      IF TRIM(par_contact_info.address) IS NOT NULL
      THEN
        vr_address.address            := TRIM(par_contact_info.address);
        vr_address.address_type_brief := vc_default_address_type_brief;
        pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact
                                                    ,par_address_rec    => vr_address);
      END IF;
    
      /* Добавляем email */
      IF TRIM(par_contact_info.email) IS NOT NULL
      THEN
        vr_email.email_type_desc := vc_default_email_type;
        vr_email.email           := par_contact_info.email;
      
        pkg_contact_object.add_email_rec_to_object(par_contact_object => v_contact
                                                  ,par_email_rec      => vr_email);
      END IF;
    
      pkg_contact_object.process_person_object(par_person_obj => v_contact
                                              ,par_contact_id => par_contact_id_out);
    
    END create_person;
  BEGIN
    SAVEPOINT before_load;
    v_persons.extend(2);
  
    BEGIN
      SELECT lf.*
        INTO vr_file_row
        FROM load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найдена строка файла!');
    END;
  
    IF vr_file_row.val_34 = 'Единовременно'
    THEN
      v_product_brief := 'Priority_Invest(lump)';
    ELSE
      v_product_brief := 'Priority_Invest(regular)';
    END IF;
  
    -- Приводим телефоны в нормальный вид
    vr_file_row.val_12 := regexp_replace(vr_file_row.val_12, '\s|\-');
    vr_file_row.val_25 := regexp_replace(vr_file_row.val_25, '\s|\-');
  
    -- Дата подписания
    v_sign_date := to_date(vr_file_row.val_27, 'dd.mm.yyyy');
    -- Страхователь
    v_persons(1).person_surname := vr_file_row.val_1;
    v_persons(1).person_name := vr_file_row.val_2;
    v_persons(1).person_midname := vr_file_row.val_3;
    v_persons(1).person_birthdate := vr_file_row.val_4;
    v_persons(1).is_public_contact := CASE
                                        WHEN upper(vr_file_row.val_5) = 'ДА' THEN
                                         1
                                        ELSE
                                         0
                                      END;
    v_persons(1).person_gender := vr_file_row.val_6;
    v_persons(1).pasport_series := REPLACE(vr_file_row.val_7, ' ');
    v_persons(1).pasport_number := vr_file_row.val_8;
    v_persons(1).pasport_who := TRIM(REPLACE(vr_file_row.val_9, 'Выдан:'));
    v_persons(1).pasport_when := vr_file_row.val_10;
    v_persons(1).phone_1 := rtrim(regexp_substr(vr_file_row.val_12, '(\d|-)+(;|$)'), ';');
    v_persons(1).phone_2 := ltrim(regexp_substr(vr_file_row.val_12, ';(\d|-)+'), ';');
    -- Мобильные телефоны указаны с '8' вначале
    IF length(v_persons(1).phone_2) > 10
       AND v_persons(1).phone_2 LIKE '8%'
    THEN
      v_persons(1).phone_2 := substr(v_persons(1).phone_2, 2);
    END IF;
    v_persons(1).email := vr_file_row.val_13;
    v_persons(1).address := vr_file_row.val_11;
  
    -- Застрахованный
    v_persons(2).person_surname := vr_file_row.val_14;
    v_persons(2).person_name := vr_file_row.val_15;
    v_persons(2).person_midname := vr_file_row.val_16;
    v_persons(2).person_birthdate := vr_file_row.val_17;
    v_persons(2).is_public_contact := CASE
                                        WHEN upper(vr_file_row.val_18) = 'ДА' THEN
                                         1
                                        ELSE
                                         0
                                      END;
    v_persons(2).person_gender := vr_file_row.val_19;
    v_persons(2).pasport_series := REPLACE(vr_file_row.val_20, ' ');
    v_persons(2).pasport_number := vr_file_row.val_21;
    v_persons(2).pasport_who := TRIM(REPLACE(vr_file_row.val_22, 'Выдан:'));
    v_persons(2).pasport_when := vr_file_row.val_23;
    v_persons(2).phone_1 := rtrim(regexp_substr(vr_file_row.val_25, '(\d|-|\(|\))+(;|$)'), ';');
    v_persons(2).phone_2 := ltrim(regexp_substr(vr_file_row.val_25, ';(\d|-|\(|\))+'), ';');
    -- Мобильные телефоны указаны с '8' вначале
    IF length(v_persons(2).phone_2) > 10
       AND v_persons(2).phone_2 LIKE '8%'
    THEN
      v_persons(2).phone_2 := substr(v_persons(2).phone_2, 2);
    END IF;
    v_persons(2).address := vr_file_row.val_24;
  
    vr_policy_values := pkg_products.get_product_defaults(v_product_brief);
  
    BEGIN
      SELECT dc.id INTO v_dial_code_id FROM t_country_dial_code dc WHERE dc.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден код страны по умолчанию');
    END;
  
    BEGIN
      SELECT tt.id
            ,tt.id
        INTO v_persons(1).phone_1_type
            ,v_persons(2).phone_1_type
        FROM t_telephone_type tt
       WHERE tt.brief = 'HOME';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип телефона "Домашний"');
    END;
  
    BEGIN
      SELECT tt.id
            ,tt.id
        INTO v_persons(1).phone_2_type
            ,v_persons(2).phone_2_type
        FROM t_telephone_type tt
       WHERE tt.brief = 'MOBIL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип телефона "Домашний"');
    END;
  
    BEGIN
      SELECT nvl(cn.ag_sales_chn_id, ch.t_sales_channel_id) -- для старого модуля сделан nvl
            ,cn.agency_id
            ,ot.province_id
            ,ch.ag_contract_header_id
        INTO v_sales_channel_id
            ,v_agency_id
            ,v_region_id
            ,v_ag_contract_header_id
        FROM ven_ag_contract_header ch
            ,ag_contract            cn
            ,department             dp
            ,organisation_tree      ot
       WHERE ch.last_ver_id = cn.ag_contract_id
         AND ch.num = '45167 '  --'476349' изменено на 45167 по заявке 323590 /Чирков/
         AND cn.agency_id = dp.department_id
         AND dp.org_tree_id = ot.organisation_tree_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдены канал продаж, агентство, регион у агента');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько каналов, агентств, регионов у агента');
    END;
  
    BEGIN
      -- Страхователь/застрахованный
      -- Проверяем, является ли страхователь застрахованным
      IF upper(v_persons(1).person_surname) = upper(v_persons(2).person_surname)
         AND upper(v_persons(1).person_name) = upper(v_persons(2).person_name)
         AND upper(v_persons(1).person_midname) = upper(v_persons(2).person_midname)
         AND v_persons(1).person_birthdate = v_persons(2).person_birthdate
      THEN
        v_count_persons := 1;
      ELSE
        v_count_persons := 2;
      END IF;
    
      FOR v_prs_idx IN 1 .. v_count_persons
      LOOP
        create_person(par_contact_info   => v_persons(v_prs_idx)
                     ,par_contact_id_out => v_persons(v_prs_idx).contact_id);
      END LOOP;
    
      -- Чтобы потом сохранить тот же CONTACT_ID застрахованному
      IF v_count_persons = 1
      THEN
        v_persons(2).contact_id := v_persons(1).contact_id;
      END IF;
    
      -- vr_file_row.val_29 - дата окончания
      v_end_date := to_date(vr_file_row.val_29, 'dd.mm.yyyy') + 1 - INTERVAL '1' SECOND;
    
      v_fee_payment_term := CASE vr_policy_values.is_periodical
                              WHEN 0 THEN
                               1
                              ELSE
                               CEIL(MONTHS_BETWEEN(v_end_date, v_sign_date) / 12)
                            END;
      -- Добавление ДС
      v_pol_header_id := pkg_renlife_utils.policy_insert(p_product_id           => vr_policy_values.product_id
                                                        ,p_sales_channel_id     => v_sales_channel_id
                                                        ,p_agency_id            => v_agency_id
                                                        ,p_fund_id              => vr_policy_values.fund_id
                                                        ,p_fund_pay_id          => vr_policy_values.fund_pay_id
                                                        ,p_confirm_condition_id => vr_policy_values.confirm_condition_id
                                                        ,p_pol_ser              => NULL
                                                        ,p_pol_num              => vr_file_row.val_26 -- Номер договора
                                                        ,p_notice_date          => v_sign_date -- Дата подписания
                                                        ,p_sign_date            => to_date(vr_file_row.val_28
                                                                                          ,'dd.mm.yyyy') -- Дата начала договора
                                                        ,p_confirm_date         => to_date(vr_file_row.val_28
                                                                                          ,'dd.mm.yyyy') -- Дата начала договора
                                                        ,p_start_date           => to_date(vr_file_row.val_28
                                                                                          ,'dd.mm.yyyy') -- Дата начала договора
                                                        ,p_end_date             => v_end_date
                                                        ,p_first_pay_date       => to_date(vr_file_row.val_28
                                                                                          ,'dd.mm.yyyy') -- Дата начала договора
                                                        ,p_payment_term_id      => vr_policy_values.payment_term_id
                                                        ,p_period_id            => vr_policy_values.period_id
                                                        ,p_issuer_id            => v_persons(1)
                                                                                   .contact_id -- Всегда страхователь
                                                        ,p_fee_payment_term     => v_fee_payment_term
                                                        ,p_fact_j               => NULL
                                                        ,p_admin_cost           => 300
                                                        ,p_is_group_flag        => 0
                                                        ,p_notice_num           => vr_file_row.val_26 -- Номер договора
                                                        ,p_waiting_period_id    => vr_policy_values.waiting_period_id
                                                        ,p_region_id            => v_region_id
                                                        ,p_discount_f_id        => vr_policy_values.discount_f_id
                                                        ,p_description          => NULL
                                                        ,p_paymentoff_term_id   => vr_policy_values.paymentoff_term_id
                                                        ,p_ph_description       => NULL
                                                        ,p_privilege_period     => vr_policy_values.privilege_period_id);
    
      /* Получение ID версии */
      SELECT policy_id INTO v_policy_id FROM p_pol_header WHERE policy_header_id = v_pol_header_id;
    
      /* Установка даты окончания выжидательного периода */
      DECLARE
        v_waiting_period_end_date p_policy.waiting_period_end_date%TYPE;
        v_val                     ven_t_period.period_value%TYPE;
        v_name                    t_period_type.description%TYPE;
      BEGIN
        SELECT p.period_value
              ,pt.description
          INTO v_val
              ,v_name
          FROM t_period      p
              ,t_period_type pt
         WHERE p.period_type_id = pt.id
           AND p.id = vr_policy_values.waiting_period_id;
      
        IF v_val IS NOT NULL
        THEN
          CASE v_name
            WHEN 'Дни' THEN
              v_waiting_period_end_date := v_sign_date + v_val - 1;
            WHEN 'Месяцы' THEN
              v_waiting_period_end_date := ADD_MONTHS(v_sign_date, v_val) - 1;
            WHEN 'Годы' THEN
              IF to_char(trunc(v_sign_date), 'ddmm') = '2902'
              THEN
                v_waiting_period_end_date := ADD_MONTHS(v_sign_date + 1, v_val * 12) - 1;
              ELSE
                v_waiting_period_end_date := ADD_MONTHS(v_sign_date, v_val * 12) - 1;
              END IF;
            ELSE
              NULL;
          END CASE;
        ELSE
          v_waiting_period_end_date := NULL;
        END IF;
        UPDATE p_policy pp
           SET pp.waiting_period_end_date = v_waiting_period_end_date
         WHERE pp.policy_id = v_policy_id;
      END;
    
      /* Добавление застрахованного */
      v_assured_id := pkg_renlife_utils.create_as_assured(p_pol_id        => v_policy_id
                                                         ,p_contact_id    => v_persons(v_count_persons)
                                                                             .contact_id
                                                         ,p_work_group_id => vr_policy_values.work_group_id);
    
      UPDATE as_assured se
         SET se.t_hobby_id =
             (SELECT th.t_hobby_id FROM t_hobby th WHERE th.description = 'нет')
            ,se.is_get_prof = 1
       WHERE se.as_assured_id = v_assured_id;
    
      pkg_asset.create_insuree_info(p_pol_id        => v_policy_id
                                   ,p_work_group_id => vr_policy_values.work_group_id);
    
      DECLARE
        v_bnf_fio        VARCHAR2(50);
        v_bnf_birth_date DATE;
        v_bnf_relation   VARCHAR2(30);
        v_bnf_contact_id NUMBER;
        v_bnf_gender_id  NUMBER;
        v_beneficiary_id NUMBER;
        v_bnf_part       NUMBER;
      BEGIN
        FOR v_bnf_idx IN 1 .. 4
        LOOP
          CASE v_bnf_idx
            WHEN 1 THEN
              v_bnf_fio        := vr_file_row.val_35;
              v_bnf_birth_date := to_date(vr_file_row.val_36, 'dd.mm.yyyy');
              v_bnf_relation   := vr_file_row.val_37;
              v_bnf_part       := to_number(REPLACE(vr_file_row.val_38, '%'));
            WHEN 2 THEN
              v_bnf_fio        := vr_file_row.val_39;
              v_bnf_birth_date := to_date(vr_file_row.val_40, 'dd.mm.yyyy');
              v_bnf_relation   := vr_file_row.val_41;
              v_bnf_part       := to_number(REPLACE(vr_file_row.val_42, '%'));
            WHEN 3 THEN
              v_bnf_fio        := vr_file_row.val_43;
              v_bnf_birth_date := to_date(vr_file_row.val_44, 'dd.mm.yyyy');
              v_bnf_relation   := vr_file_row.val_45;
              v_bnf_part       := to_number(REPLACE(vr_file_row.val_46, '%'));
            WHEN 4 THEN
              v_bnf_fio        := vr_file_row.val_47;
              v_bnf_birth_date := to_date(vr_file_row.val_48, 'dd.mm.yyyy');
              v_bnf_relation   := vr_file_row.val_49;
              v_bnf_part       := to_number(REPLACE(vr_file_row.val_50, '%'));
          END CASE;
          IF v_bnf_fio IS NOT NULL
          THEN
            BEGIN
              SELECT rt.relationship_dsc
                    ,rt.gender_id
                INTO v_bnf_relation
                    ,v_bnf_gender_id
                FROM t_contact_rel_type rt
               WHERE upper(rt.relationship_dsc) = upper(v_bnf_relation)
                 AND rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                v_bnf_relation  := 'Другой';
                v_bnf_gender_id := 0;
            END;
          
            v_bnf_contact_id := pkg_renlife_utils.create_person_contact(p_last_name       => TRIM(regexp_substr(v_bnf_fio
                                                                                                               ,'^\w+\s'))
                                                                       ,p_first_name      => TRIM(regexp_substr(v_bnf_fio
                                                                                                               ,'\s\w+\s'))
                                                                       ,p_middle_name     => TRIM(regexp_substr(v_bnf_fio
                                                                                                               ,'\s\w+$'))
                                                                       ,p_birth_date      => v_bnf_birth_date
                                                                       ,p_gender          => v_bnf_gender_id
                                                                       ,p_pass_ser        => '0'
                                                                       ,p_pass_num        => '0'
                                                                       ,p_pass_issue_date => to_date('01.01.1900'
                                                                                                    ,'dd.mm.yyyy')
                                                                       ,p_pass_issued_by  => 'Информация о паспорте недоступна'
                                                                       ,p_address         => NULL
                                                                       ,p_contact_phone   => '0');
            v_beneficiary_id := NULL;
            pkg_asset.add_beneficiary(par_asset_id          => v_assured_id
                                     ,par_contact_id        => v_bnf_contact_id
                                     ,par_contact_rel_brief => v_bnf_relation
                                     ,par_value             => v_bnf_part
                                     ,par_value_type_brief  => 'percent'
                                     ,par_currency_brief    => 'RUR'
                                     ,par_beneficiary_id    => v_beneficiary_id);
          END IF;
        END LOOP;
      END;
      /* Добавялем покрытия по застрахованному */
      FOR rec IN (SELECT id
                        ,CASE
                           WHEN lead(id) over(ORDER BY id) IS NULL THEN
                            1
                           ELSE
                            0
                         END AS is_last
                        ,CASE vr_file_row.val_33
                           WHEN '0' THEN
                            prog_percent_0
                           WHEN '1' THEN
                            prog_percent_1
                           WHEN '2' THEN
                            prog_percent_2
                           WHEN '3' THEN
                            prog_percent_3
                         END AS prog_percent
                        ,brutto_sum
                        ,ins_amount
                    FROM (SELECT pl.id
                                ,to_number(vr_file_row.val_31
                                          ,'FM9999999999D99'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,''') AS brutto_sum
                                ,to_number(vr_file_row.val_30
                                          ,'FM9999999999D99'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,''') AS ins_amount
                                ,CASE plo.brief
                                   WHEN 'PEPR_A_PLUS' THEN
                                    0
                                   WHEN 'PEPR_A' THEN
                                    0.1
                                   WHEN 'PEPR_B' THEN
                                    0.9
                                 END AS prog_percent_0
                                ,CASE plo.brief
                                   WHEN 'PEPR_C' THEN
                                    0.1
                                   WHEN 'PEPR_A' THEN
                                    0.8
                                   WHEN 'PEPR_B' THEN
                                    0.1
                                 END AS prog_percent_1
                                ,CASE plo.brief
                                   WHEN 'PEPR_C' THEN
                                    0.1
                                   WHEN 'PEPR_A' THEN
                                    0.1
                                   WHEN 'PEPR_B' THEN
                                    0.8
                                 END AS prog_percent_2
                                ,CASE plo.brief
                                   WHEN 'PEPR_C' THEN
                                    0.8
                                   WHEN 'PEPR_A' THEN
                                    0.1
                                   WHEN 'PEPR_B' THEN
                                    0.1
                                 END AS prog_percent_3
                            FROM t_product_version   pv
                                ,t_product_ver_lob   pvl
                                ,t_product_line      pl
                                ,t_product_line_type plt
                                ,t_prod_line_option  plo
                           WHERE pv.product_id = vr_policy_values.product_id
                             AND pv.t_product_version_id = pvl.product_version_id
                             AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                             AND pl.product_line_type_id = plt.product_line_type_id
                             AND pl.id = plo.product_line_id
                             AND plo.brief != 'Adm_Cost_Life'
                             AND pl.skip_on_policy_creation = 0))
      LOOP
        DECLARE
          v_normrate NUMBER;
          v_loading  NUMBER;
          v_netto    NUMBER;
          v_brutto   NUMBER;
          v_cover_id p_cover.p_cover_id%TYPE;
        BEGIN
          /*IF rec.prog_percent != 0
          THEN*/
          /* Создаем покрытие */
          v_cover_id := pkg_cover.cre_new_cover(v_assured_id, rec.id, rec.is_last = 1);
          /* Нагрузка */
          v_loading := pkg_cover.calc_loading(v_cover_id);
          /* Норма доходности */
          v_normrate := pkg_productlifeproperty.calc_normrate_value(v_cover_id);
        
          UPDATE p_cover pc
             SET is_handchange_amount  = 0
                ,is_handchange_premium = 1
                ,is_handchange_fee     = 1
                ,is_handchange_tariff  = 0
                ,normrate_value        = v_normrate
                ,rvb_value             = v_loading
                ,fee                   = rec.brutto_sum * rec.prog_percent
                ,k_coef                = 0
                ,k_coef_m              = 0
                ,k_coef_nm             = 0
                ,s_coef                = 0
                ,s_coef_m              = 0
                ,s_coef_nm             = 0
                ,premia_base_type      = 1
                ,t_deductible_type_id  = 1
                ,t_deduct_val_type_id  = 1
                ,deductible_value      = 0
           WHERE pc.p_cover_id = v_cover_id;
        
          v_netto := ROUND(pkg_cover.calc_tariff_netto(p_p_cover_id => v_cover_id), 5);
          UPDATE p_cover pc
             SET netto_tariff = v_netto
                ,tariff_netto = v_netto
                ,premium      = rec.brutto_sum * rec.prog_percent
           WHERE pc.p_cover_id = v_cover_id;
          v_brutto := pkg_cover.calc_tariff(p_p_cover_id => v_cover_id);
          UPDATE p_cover pc
             SET tariff     = v_brutto
                ,ins_amount = rec.ins_amount * rec.prog_percent
           WHERE pc.p_cover_id = v_cover_id;
          /*END IF;*/
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20001
                                   ,'Ошибка подключения покрытия: ' || SQLERRM);
        END;
      END LOOP;
    
      -- Иногда дата начала застрахованного неверная
      UPDATE as_asset se
         SET se.start_date =
             (SELECT MIN(pc.start_date) FROM p_cover pc WHERE pc.as_asset_id = se.as_asset_id)
       WHERE se.as_asset_id = v_assured_id;
    
      pkg_policy.update_policy_sum(p_p_policy_id => v_policy_id);
      pkg_renlife_utils.add_policy_agent_doc(par_policy_header_id      => v_pol_header_id
                                            ,par_ag_contract_header_id => v_ag_contract_header_id);
    
      /* БСО */
      v_bso_series_id := dml_bso_series.get_id_by_series_num(to_number(substr(vr_file_row.val_26, 1, 3)));
      v_bso_id        := pkg_bso.find_bso_by_num(par_policy_id     => v_policy_id
                                                ,par_bso_num       => substr(vr_file_row.val_26, 4, 6)
                                                ,par_bso_series_id => v_bso_series_id);
    
      pkg_bso.attach_bso_to_policy(par_policy_id => v_policy_id, par_bso_id => v_bso_id);
    
    END;
  
    --/Чирков/ добавляем проверку на премию по ДС/302786: Универсальный загрузчик - расчет преми/
    premium_check(par_policy_id => v_policy_id, par_original_premium => vr_file_row.val_31);
    --           
  
    UPDATE load_file_rows lf
       SET lf.ure_id     = 282
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  
  EXCEPTION
    WHEN OTHERS THEN
      v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
      ROLLBACK TO before_load;
      UPDATE load_file_rows lf
         SET lf.is_checked = 0
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => v_error_msg);
    
  END load_sber;

  /*
  Капля П.
  Загрузка договоров группы продуктов "Уверенный старт"
  brief: STRONG_START%
  */
  PROCEDURE load_strong_start(par_load_file_rows_id NUMBER) IS
    TYPE t_contact_info IS RECORD(
       fio        VARCHAR2(300)
      ,birth_date DATE
      ,phone      VARCHAR2(50)
      ,gender     VARCHAR2(25)
      ,pass_ser   VARCHAR2(20)
      ,pass_num   VARCHAR2(30)
      ,pass_when  DATE
      ,pass_where VARCHAR2(200)
      ,address    VARCHAR2(500)
      ,email      VARCHAR2(150));
    TYPE t_r_insured_info IS RECORD(
       contact      t_contact_info
      ,insured_type VARCHAR2(25));
    TYPE t_r_benif_info IS RECORD(
       contact  t_contact_info
      ,programs VARCHAR2(50)
      ,part     NUMBER
      ,relation VARCHAR2(20));
    TYPE t_insured_info IS TABLE OF t_r_insured_info INDEX BY PLS_INTEGER;
    TYPE t_benif_info IS TABLE OF t_r_benif_info INDEX BY PLS_INTEGER;
    v_insurer_info t_contact_info;
  
    --v_insurer_type           VARCHAR2(25);  
    v_pol_num          VARCHAR2(20);
    v_program_type           VARCHAR2(50);
    v_payment_terms    VARCHAR2(50);
    v_sum_fee          NUMBER;
    v_first_payment_doc_date DATE;
    v_first_payment_doc_num  VARCHAR2(500);
    v_death_ns_ins_sum NUMBER;
    v_dis_ns_ins_sum         NUMBER;
    v_death_dtp_ins_sum      NUMBER;
    v_dis_dtp_ins_sum        NUMBER;
    v_break_burn_ins_sum     NUMBER;
    v_start_date       DATE;
  
    v_comment VARCHAR2(1000);
  
    v_row           load_file_rows%ROWTYPE;
    v_policy_values pkg_products.t_product_defaults;
    v_insured_count PLS_INTEGER := 0;
    v_benif_count   PLS_INTEGER := 0;
  
    v_insured_info t_insured_info;
    v_benif_info   t_benif_info;
  
    v_payment_terms_id      NUMBER;
    v_ag_contract_header_id NUMBER;
    v_agency_id             NUMBER;
    v_end_date              DATE;
  
    v_contact_id       NUMBER;
    v_sales_channel_id NUMBER;
    v_region_id        NUMBER;
    v_policy_id        NUMBER;
    v_bso_series_id    bso_series.bso_series_id%TYPE;
    v_bso_id           bso.bso_id%TYPE;
    v_pol_header_id    NUMBER;
    v_assured_id       NUMBER;
    --v_email_id         NUMBER;
    v_discount      NUMBER;
    v_partner       VARCHAR2(100);
    v_product_brief VARCHAR2(100);
  
    v_discount_id discount_f.discount_f_id%TYPE;
  
    PROCEDURE process_contact_info
    (
      par_contac_info    t_contact_info
     ,par_contact_id_out OUT contact.contact_id%TYPE
    ) IS
      v_contact_info pkg_contact_object.t_person_object;
      vr_ident_doc   pkg_contact_object.t_contact_id_doc_rec;
      vr_address     pkg_contact_object.t_contact_address_rec;
      v_phone_rec    pkg_contact_object.t_contact_phone_rec;
      v_email_rec    pkg_contact_object.t_contact_email_rec;
      vc_default_email_type CONSTANT VARCHAR2(14) := 'Адрес рассылки';
    BEGIN
      --формируем основную информацию по контакту            
      v_contact_info.name          := regexp_substr(par_contac_info.fio, '[^ ]+', 1, 1);
      v_contact_info.first_name    := regexp_substr(par_contac_info.fio, '[^ ]+', 1, 2);
      v_contact_info.middle_name   := regexp_substr(par_contac_info.fio, '[^ ]+', 1, 3);
      v_contact_info.gender        := par_contac_info.gender;
      v_contact_info.date_of_birth := par_contac_info.birth_date;
    
      --формируем информацию по паспорту      
      IF par_contac_info.pass_num IS NOT NULL
      THEN
        vr_ident_doc.series_nr      := par_contac_info.pass_ser;
        vr_ident_doc.id_value       := par_contac_info.pass_num;
        vr_ident_doc.issue_date     := par_contac_info.pass_when;
        vr_ident_doc.place_of_issue := par_contac_info.pass_where;
        pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_info
                                                   ,par_id_doc_rec     => vr_ident_doc);
      END IF;
    
      --формируем информацию об адресе                                     
      IF par_contac_info.address IS NOT NULL
      THEN
        vr_address.address := par_contac_info.address;
        pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_info
                                                    ,par_address_rec    => vr_address);
      END IF;
    
      --формируем информацию о телефоне
      IF regexp_replace(par_contac_info.phone, '[^0-9]+') IS NOT NULL
      THEN
        v_phone_rec.phone_type_brief := 'MOBIL';
        v_phone_rec.phone_number     := par_contac_info.phone;
        pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_info
                                                  ,par_phone_rec      => v_phone_rec);
      END IF;
    
      --формируем email
      IF par_contac_info.email IS NOT NULL
      THEN
        v_email_rec.email_type_desc := vc_default_email_type;
        v_email_rec.email           := lower(par_contac_info.email);
      
        pkg_contact_object.add_email_rec_to_object(par_contact_object => v_contact_info
                                                  ,par_email_rec      => v_email_rec);
      END IF;
      --создаем контакт из объекта
      pkg_contact_object.process_person_object(par_person_obj => v_contact_info
                                              ,par_contact_id => par_contact_id_out);
    
    END process_contact_info;
  
  BEGIN
  
    SAVEPOINT before_load;
    /*
    Записываем данные из строки иморта в понятные переменные
    */
    SELECT * INTO v_row FROM load_file_rows t WHERE t.load_file_rows_id = par_load_file_rows_id;
  
    BEGIN
      v_insurer_info.fio     := v_row.val_2;
      v_pol_num              := v_row.val_3;
      v_insurer_info.address := v_row.val_4;
      v_program_type         := v_row.val_5;
      v_payment_terms := v_row.val_6;
    
      v_sum_fee := to_number(v_row.val_8, 'FM9999999999D99', 'NLS_NUMERIC_CHARACTERS = ''.,''');
    
      /*      v_fee_brought_by_agent   := TO_NUMBER(v_row.val_11
      ,'FM9999999999D99'
      ,'NLS_NUMERIC_CHARACTERS = ''.,''');*/
      v_death_ns_ins_sum := to_number(v_row.val_14
                                     ,'FM999999999D99'
                                     ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_dis_ns_ins_sum     := to_number(v_row.val_15
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_death_dtp_ins_sum  := to_number(v_row.val_16
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_dis_dtp_ins_sum    := to_number(v_row.val_17
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_break_burn_ins_sum := to_number(v_row.val_18
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
    
      v_start_date := to_date(v_row.val_19 || '.' || v_row.val_20 || '.' || v_row.val_21, 'DD.MM.YYYY');
    
      --v_insurer_type       := v_row.val_22;
      v_insurer_info.birth_date := to_date(v_row.val_23, 'dd.mm.yyyy');
      v_insurer_info.gender     := v_row.val_24;
      v_insurer_info.phone      := v_row.val_25;
      v_insurer_info.email      := v_row.val_26;
      v_insurer_info.pass_ser   := v_row.val_27;
      v_insurer_info.pass_num   := v_row.val_28;
      v_insurer_info.pass_when  := to_date(v_row.val_29, 'dd.mm.yyyy');
      v_insurer_info.pass_where := v_row.val_30;
    
      IF v_row.val_31 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        v_insured_info(v_insured_count).contact.fio := v_row.val_31;
        v_insured_info(v_insured_count).contact.birth_date := to_date(v_row.val_32, 'dd.mm.yyyy');
        v_insured_info(v_insured_count).contact.phone := v_row.val_34;
        v_insured_info(v_insured_count).contact.gender := v_row.val_33;
        v_insured_info(v_insured_count).contact.pass_ser := v_row.val_35;
        v_insured_info(v_insured_count).contact.pass_num := v_row.val_36;
        v_insured_info(v_insured_count).contact.pass_when := to_date(v_row.val_37, 'dd.mm.yyyy');
        v_insured_info(v_insured_count).contact.pass_where := v_row.val_38;
        v_insured_info(v_insured_count).contact.address := v_row.val_39;
        v_insured_info(v_insured_count).insured_type := 'ASSET_PERSON';
      END IF;
    
      IF v_row.val_40 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        v_insured_info(v_insured_count).contact.fio := v_row.val_40;
        v_insured_info(v_insured_count).contact.birth_date := to_date(v_row.val_41, 'dd.mm.yyyy');
        v_insured_info(v_insured_count).contact.phone := v_row.val_42;
        v_insured_info(v_insured_count).contact.gender := v_row.val_43;
        v_insured_info(v_insured_count).contact.pass_ser := v_row.val_44;
        v_insured_info(v_insured_count).contact.pass_num := v_row.val_45;
        v_insured_info(v_insured_count).contact.pass_when := to_date(v_row.val_46, 'dd.mm.yyyy');
        v_insured_info(v_insured_count).contact.pass_where := v_row.val_47;
        v_insured_info(v_insured_count).contact.address := v_row.val_48;
        v_insured_info(v_insured_count).insured_type := 'ASSET_PERSON';
      END IF;
    
      /*Застрахованные дети*/
      IF v_row.val_49 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        v_insured_info(v_insured_count).contact.fio := v_row.val_49;
        v_insured_info(v_insured_count).contact.gender := v_row.val_50;
        v_insured_info(v_insured_count).contact.birth_date := to_date(v_row.val_51, 'dd.mm.yyyy');
        v_insured_info(v_insured_count).insured_type := 'ASSET_PERSON_CHILD';
      END IF;
      IF v_row.val_52 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        v_insured_info(v_insured_count).contact.fio := v_row.val_52;
        v_insured_info(v_insured_count).contact.gender := v_row.val_53;
        v_insured_info(v_insured_count).contact.birth_date := to_date(v_row.val_54, 'dd.mm.yyyy');
        v_insured_info(v_insured_count).insured_type := 'ASSET_PERSON_CHILD';
      END IF;
    
      /*
      Выгодоприобретатели
      */
      IF v_row.val_55 IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        v_benif_info(v_benif_count).contact.fio := v_row.val_55;
        v_benif_info(v_benif_count).contact.birth_date := to_date(v_row.val_56, 'dd.mm.yyyy');
        v_benif_info(v_benif_count).relation := v_row.val_57;
        v_benif_info(v_benif_count).programs := v_row.val_58;
        v_benif_info(v_benif_count).part := to_number(REPLACE(v_row.val_59, '%')
                                                     ,'FM9999999999D99'
                                                     ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      
      END IF;
      IF v_row.val_60 IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        v_benif_info(v_benif_count).contact.fio := v_row.val_60;
        v_benif_info(v_benif_count).contact.birth_date := to_date(v_row.val_61, 'dd.mm.yyyy');
        v_benif_info(v_benif_count).relation := v_row.val_62;
        v_benif_info(v_benif_count).programs := v_row.val_63;
        v_benif_info(v_benif_count).part := to_number(REPLACE(v_row.val_64, '%')
                                                     ,'FM9999999999D99'
                                                     ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      END IF;
    
      v_first_payment_doc_num  := v_row.val_65;
      v_first_payment_doc_date := to_date(v_row.val_66, 'dd.mm.yyyy');
    
      v_comment  := v_row.val_67;
      v_discount := v_row.val_68;
      v_partner  := v_row.val_69;
    
    END;
  
    IF v_insured_info.count > 1
    THEN
      CASE nvl(v_discount, 0)
        WHEN 5 THEN
          v_product_brief := 'STRONG_START_ROLF80_2';
        WHEN 10 THEN
          v_product_brief := 'STRONG_START_ROLF75_2';
        WHEN 15 THEN
          v_product_brief := 'STRONG_START_ROLF70_2';
        WHEN 40 THEN
          v_product_brief := 'STRONG_START_ROLF_2';
          v_discount_id   := pkg_products.get_discount_id(par_discount_brief => nvl(v_discount || '%'
                                                                                   ,'База'));
        ELSE
          IF upper(v_partner) LIKE ('%РОЛЬФ%')
          THEN
            v_product_brief := 'STRONG_START_ROLF85_2';
          ELSE
            v_product_brief := 'STRONG_START_2';
          END IF;
      END CASE;
    ELSE
      CASE nvl(v_discount, 0)
        WHEN 5 THEN
          v_product_brief := 'STRONG_START_ROLF80_1';
        WHEN 10 THEN
          v_product_brief := 'STRONG_START_ROLF75_1';
        WHEN 15 THEN
          v_product_brief := 'STRONG_START_ROLF70_1';
        WHEN 40 THEN
          v_product_brief := 'STRONG_START_ROLF_1';
          v_discount_id   := pkg_products.get_discount_id(par_discount_brief => nvl(v_discount || '%'
                                                                                   ,'База'));
        ELSE
          IF upper(v_partner) LIKE ('%РОЛЬФ%')
          THEN
            v_product_brief := 'STRONG_START_ROLF85_1';
          ELSE
            v_product_brief := 'STRONG_START_1';
          END IF;
      END CASE;
    END IF;
  
    v_policy_values := pkg_products.get_product_defaults(par_product_brief => v_product_brief);
  
    BEGIN
      SELECT p.id
        INTO v_payment_terms_id
        FROM t_payment_terms p
       WHERE p.description = v_payment_terms;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    IF v_payment_terms_id IS NOT NULL
       AND v_payment_terms_id != v_policy_values.payment_term_id
    THEN
      v_policy_values.payment_term_id := v_payment_terms_id;
    END IF;
  
    -- Находим информацию по агенту
    BEGIN
      SELECT nvl(cn.ag_sales_chn_id, ch.t_sales_channel_id) -- для старого модуля сделан nvl
            ,cn.agency_id
            ,ot.province_id
            ,ch.ag_contract_header_id
        INTO v_sales_channel_id
            ,v_agency_id
            ,v_region_id
            ,v_ag_contract_header_id
        FROM ven_ag_contract_header ch
            ,ag_contract            cn
            ,department             dp
            ,organisation_tree      ot
            ,contact                c
            ,doc_status_ref         dsr
       WHERE ch.last_ver_id = cn.ag_contract_id
         AND cn.agency_id = dp.department_id
         AND dp.org_tree_id = ot.organisation_tree_id
         AND ch.agent_id = c.contact_id
         AND nvl(ch.is_new, 0) = 1
         AND ch.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'CURRENT'
         AND c.obj_name_orig = v_partner; -- Определяем по названию партнера из бордеро
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдены канал продаж, агентство, регион у агента');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько каналов, агентств, регионов у агента');
    END;
  
    v_end_date := ADD_MONTHS(v_start_date, 12) - INTERVAL '1' SECOND;
  
    /*
    --Чирков/Комментарий по задаче 291609: FW: Ошибка при заливке файла в борлас/
    v_last_name   := regexp_substr(v_insurer_fio, '[^ ]+', 1, 1);
    v_first_name  := regexp_substr(v_insurer_fio, '[^ ]+', 1, 2);
    v_middle_name := regexp_substr(v_insurer_fio, '[^ ]+', 1, 3);
    
    v_contact_id := pkg_contact.create_person_contact_rlu(p_last_name       => v_last_name
                                                         ,p_first_name      => v_first_name
                                                         ,p_middle_name     => v_middle_name
                                                         ,p_birth_date      => v_insurer_birth_date
                                                         ,p_gender          => v_insurer_gender
                                                         ,p_pass_ser        => v_insurer_pass_ser
                                                         ,p_pass_num        => v_insurer_pass_num
                                                         ,p_pass_issue_date => v_insurer_pass_when
                                                         ,p_pass_issued_by  => v_insurer_pass_where
                                                         ,p_address         => v_insurer_addr
                                                         ,p_contact_phone   => regexp_replace(v_insurer_phone
                                                                                             ,'\s|\-'));
                                                                                             
    IF v_insurer_email IS NOT NULL
    THEN
      v_email_id := pkg_contact.insert_email(par_contact_id => v_contact_id
                                            ,par_email      => v_insurer_email
                                            ,par_email_type => 363);
    END IF;*/
    --Чирков /добавил 291609: FW: Ошибка при заливке файла в борлас/
    process_contact_info(v_insurer_info, v_contact_id);
    --
  
    v_pol_header_id := pkg_renlife_utils.policy_insert(p_product_id           => v_policy_values.product_id
                                                      ,p_sales_channel_id     => v_sales_channel_id
                                                      ,p_agency_id            => v_agency_id
                                                      ,p_fund_id              => v_policy_values.fund_id
                                                      ,p_fund_pay_id          => v_policy_values.fund_pay_id
                                                      ,p_confirm_condition_id => v_policy_values.confirm_condition_id
                                                      ,p_pol_ser              => ''
                                                      ,p_pol_num              => v_pol_num
                                                      ,p_notice_date          => v_start_date
                                                      ,p_sign_date            => v_start_date
                                                      ,p_confirm_date         => v_start_date
                                                      ,p_start_date           => v_start_date
                                                      ,p_end_date             => v_end_date
                                                      ,p_first_pay_date       => v_start_date
                                                      ,p_payment_term_id      => v_policy_values.payment_term_id
                                                      ,p_period_id            => v_policy_values.period_id
                                                      ,p_issuer_id            => v_contact_id -- Всегда страхователь
                                                      ,p_fee_payment_term     => 1
                                                      ,p_fact_j               => NULL
                                                      ,p_admin_cost           => 0
                                                      ,p_is_group_flag        => 0
                                                      ,p_notice_num           => v_pol_num
                                                      ,p_waiting_period_id    => v_policy_values.waiting_period_id
                                                      ,p_region_id            => v_region_id
                                                      ,p_discount_f_id        => nvl(v_discount_id
                                                                                    ,v_policy_values.discount_f_id)
                                                      ,p_description          => v_comment
                                                      ,p_paymentoff_term_id   => v_policy_values.paymentoff_term_id
                                                      ,p_ph_description       => v_comment
                                                      ,p_privilege_period     => v_policy_values.privilege_period_id);
  
    /* Получение ID версии */
    SELECT policy_id INTO v_policy_id FROM p_pol_header WHERE policy_header_id = v_pol_header_id;
  
    /* Установка даты окончания выжидательного периода */
    DECLARE
      v_waiting_period_end_date p_policy.waiting_period_end_date%TYPE;
      v_val                     ven_t_period.period_value%TYPE;
      v_name                    t_period_type.description%TYPE;
    BEGIN
      SELECT p.period_value
            ,pt.description
        INTO v_val
            ,v_name
        FROM t_period      p
            ,t_period_type pt
       WHERE p.period_type_id = pt.id
         AND p.id = v_policy_values.waiting_period_id;
    
      IF v_val IS NOT NULL
      THEN
        CASE v_name
          WHEN 'Дни' THEN
            v_waiting_period_end_date := v_start_date + v_val - 1;
          WHEN 'Месяцы' THEN
            v_waiting_period_end_date := ADD_MONTHS(v_start_date, v_val) - 1;
          WHEN 'Годы' THEN
            v_waiting_period_end_date := ADD_MONTHS(v_start_date, v_val * 12) - 1;
          ELSE
            NULL;
        END CASE;
      ELSE
        v_waiting_period_end_date := NULL;
      END IF;
      UPDATE p_policy pp
         SET pp.waiting_period_end_date = v_waiting_period_end_date
       WHERE pp.policy_id = v_policy_id;
    END;
  
    pkg_asset.create_insuree_info(p_pol_id => v_policy_id, p_work_group_id => NULL);
  
    FOR i IN 1 .. v_insured_info.count
    LOOP
      --291609: FW: Ошибка при заливке файла в борлас /Чирков/
      --изменил на универсальный механизм.       
      /*v_last_name   := regexp_substr(v_insured_info(i).fio, '[^ ]+', 1, 1);
      v_first_name  := regexp_substr(v_insured_info(i).fio, '[^ ]+', 1, 2);
      v_middle_name := regexp_substr(v_insured_info(i).fio, '[^ ]+', 1, 3);
      
      v_contact_id := pkg_contact.create_person_contact_rlu(p_last_name       => v_last_name
                                                           ,p_first_name      => v_first_name
                                                           ,p_middle_name     => v_middle_name
                                                           ,p_birth_date      => v_insured_info(i)
                                                                                 .birth_date
                                                           ,p_gender          => v_insured_info(i)
                                                                                 .gender
                                                           ,p_pass_ser        => nvl(v_insured_info(i)
                                                                                     .pass_ser
                                                                                    ,'0')
                                                           ,p_pass_num        => nvl(v_insured_info(i)
                                                                                     .pass_num
                                                                                    ,'0')
                                                           ,p_pass_issue_date => nvl(v_insured_info(i)
                                                                                     .pass_when
                                                                                    ,to_date('01.01.1900'
                                                                                            ,'dd.mm.yyyy'))
                                                           ,p_pass_issued_by  => nvl(v_insured_info(i)
                                                                                     .pass_where
                                                                                    ,'Информация о паспорте недоступна')
                                                           ,p_address         => v_insurer_addr
                                                           ,p_contact_phone   => regexp_replace(v_insurer_phone
                                                                                               ,'\s|\-'));
      */
      --Чирков /добавил 291609: FW: Ошибка при заливке файла в борлас/
      process_contact_info(v_insured_info(i).contact, v_contact_id);
      --       
    
      v_assured_id := pkg_asset.create_as_assured(p_pol_id        => v_policy_id
                                                 ,p_contact_id    => v_contact_id
                                                 ,p_work_group_id => NULL
                                                 ,p_asset_type    => v_insured_info(i).insured_type);
    
      FOR rec IN (SELECT pl.id
                        ,nvl2(lead(pl.id) over(ORDER BY pl.id), 0, 1) is_last
                        ,plt.product_line_type_id
                        ,ast.brief
                        ,plo.brief program_brief
                    FROM t_product_version   pv
                        ,t_product_ver_lob   pvl
                        ,t_product_line      pl
                        ,t_product_line_type plt
                        ,t_prod_line_option  plo
                        ,t_as_type_prod_line tat
                        ,t_asset_type        ast
                   WHERE pv.product_id = v_policy_values.product_id
                     AND pv.t_product_version_id = pvl.product_version_id
                     AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                     AND pl.product_line_type_id = plt.product_line_type_id
                     AND pl.id = plo.product_line_id
                     AND tat.product_line_id = pl.id
                     AND tat.asset_common_type_id = ast.t_asset_type_id
                     AND ast.brief = v_insured_info(i).insured_type
                     AND pl.skip_on_policy_creation = 0
                   ORDER BY CASE product_line_type_id
                              WHEN 2 THEN
                               -1
                              ELSE
                               product_line_type_id
                            END
                  --                    where brutto_sum != 0
                  )
      LOOP
        DECLARE
          v_normrate         NUMBER;
          v_loading          NUMBER;
          v_netto            NUMBER;
          v_brutto           NUMBER;
          v_cover_id         p_cover.p_cover_id%TYPE;
          v_cover_start_date DATE;
          v_cover_end_date   DATE;
          v_coef_calc_result NUMBER;
          v_ins_sum_coef     NUMBER;
          v_limit            NUMBER;
          v_ins_amount       NUMBER;
        BEGIN
        
          /* Создаем покрытие */
          v_cover_id := pkg_cover.cre_new_cover(v_assured_id, rec.id, rec.is_last = 1);
          /* Нагрузка */
          v_loading := pkg_cover.calc_loading(v_cover_id);
          /* Норма доходности */
          v_normrate         := pkg_productlifeproperty.calc_normrate_value(v_cover_id);
          v_coef_calc_result := pkg_tariff.calc_cover_coef(v_cover_id);
        
          /* Изменяем параметры покрытия, чтоыб правильно все рассчитать */
          IF v_product_brief LIKE 'STRONG_START_ROLF__'
          THEN
            v_ins_sum_coef := CASE
                                WHEN rec.program_brief IN ('AD', 'ADis') THEN
                                 1
                                WHEN rec.program_brief IN ('CrashDeath', 'CrashDis') THEN
                                 2
                                ELSE
                                 0.1
                              END;
            IF rec.brief != 'ASSET_PERSON'
            THEN
              v_ins_sum_coef := v_ins_sum_coef / 2;
            END IF;
          ELSE
            v_ins_sum_coef := pkg_tariff_calc.calc_coeff_val('Ins_Sum_CR_Koef_table'
                                                            ,t_number_type(rec.id
                                                                          ,v_policy_values.fund_id));
          
          END IF;
        
          v_limit := pkg_tariff_calc.calc_coeff_val('Ins_Sum_CR_limit'
                                                   ,t_number_type(rec.id, v_policy_values.fund_id));
        
          v_ins_amount := v_death_ns_ins_sum * nvl(v_ins_sum_coef, 1);
          IF v_limit IS NOT NULL
          THEN
            v_ins_amount := least(v_ins_amount, v_limit);
          END IF;
        
          UPDATE p_cover pc
             SET is_handchange_amount = 0
                ,normrate_value       = v_normrate
                ,rvb_value            = v_loading
                ,ins_amount           = v_ins_amount
                ,start_date           = v_start_date
                ,end_date             = v_end_date
                ,premia_base_type     = 0 -- Расчет от СС
           WHERE pc.p_cover_id = v_cover_id;
        
          /* Расчет покрытия */
          pkg_cover.update_cover_sum(p_p_cover_id => v_cover_id);
        
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20001
                                   ,'Ошибка подключения покрытия: ' || SQLERRM);
        END;
      END LOOP;
    
    END LOOP;
  
    FOR rec IN (SELECT as_asset_id
                      ,t.brief
                  FROM as_asset       aa
                      ,p_asset_header ah
                      ,t_asset_type   t
                 WHERE aa.p_policy_id = v_policy_id
                   AND aa.p_asset_header_id = ah.p_asset_header_id
                   AND ah.t_asset_type_id = t.t_asset_type_id)
    LOOP
      DECLARE
        v_bnf_relation   VARCHAR2(30);
        v_bnf_contact_id NUMBER;
        v_bnf_gender_id  NUMBER;
        v_beneficiary_id NUMBER;
      
        benif_error EXCEPTION;
        PRAGMA EXCEPTION_INIT(benif_error, -20001);
      BEGIN
        FOR i IN 1 .. v_benif_info.count
        LOOP
          IF (rec.brief = 'ASSET_PERSON' AND (v_benif_info(i).programs = 'Смерть застрахованного 1,2'))
             OR (rec.brief = 'ASSET_PERSON_CHILD' AND v_benif_info(i)
             .programs = 'Все риски застрахованного 3,4' AND
             v_policy_values.product_brief LIKE 'STRONG_START%2')
          THEN
            BEGIN
              SELECT rt.relationship_dsc
                    ,rt.gender_id
                INTO v_bnf_relation
                    ,v_bnf_gender_id
                FROM t_contact_rel_type rt
               WHERE upper(rt.relationship_dsc) = upper(v_benif_info(i).relation)
                 AND rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                v_bnf_relation  := 'Другой';
                v_bnf_gender_id := 0;
            END;
          
            --291609: FW: Ошибка при заливке файла в борлас/Чирков/
            --создаем контакт Выгодоприобретателя
            SELECT g.brief
              INTO v_benif_info(i).contact.gender
              FROM t_gender g
             WHERE g.id = v_bnf_gender_id;
          
            /*
            v_last_name   := regexp_substr(v_benif_info(i).fio, '[^ ]+', 1, 1);
            v_first_name  := regexp_substr(v_benif_info(i).fio, '[^ ]+', 1, 2);
            v_middle_name := regexp_substr(v_benif_info(i).fio, '[^ ]+', 1, 3);
            
            v_bnf_contact_id := pkg_contact.create_person_contact_rlu(p_last_name       => v_last_name
                                                                     ,p_first_name      => v_first_name
                                                                     ,p_middle_name     => v_middle_name
                                                                     ,p_birth_date      => v_benif_info(i)
                                                                                           .birth_date
                                                                     ,p_gender          => v_bnf_gender_id
                                                                     ,p_pass_ser        => '0'
                                                                     ,p_pass_num        => '0'
                                                                     ,p_pass_issue_date => to_date('01.01.1900'
                                                                                                  ,'dd.mm.yyyy')
                                                                     ,p_pass_issued_by  => 'Информация о паспорте недоступна');*/
            --изменил на универсальный механизм. Также по зявке 291609 была ошибка в том, 
            --что дата пасспорта проставлялась 01.01.1900 и эта дата была больше даты рождения контакта. Нужно было ставить NULL            
            --Чирков /добавил 291609: FW: Ошибка при заливке файла в борлас/
            process_contact_info(v_benif_info(i).contact, v_bnf_contact_id);
            --
          
            v_beneficiary_id := NULL;
          
            BEGIN
              pkg_asset.add_beneficiary(par_asset_id          => rec.as_asset_id
                                       ,par_contact_id        => v_bnf_contact_id
                                       ,par_contact_rel_brief => v_bnf_relation
                                       ,par_value             => v_benif_info(i).part
                                       ,par_value_type_brief  => 'percent'
                                       ,par_currency_brief    => 'RUR'
                                       ,par_beneficiary_id    => v_beneficiary_id);
            EXCEPTION
              WHEN benif_error THEN
                v_bnf_relation := 'Другой';
                pkg_asset.add_beneficiary(par_asset_id          => rec.as_asset_id
                                         ,par_contact_id        => v_bnf_contact_id
                                         ,par_contact_rel_brief => v_bnf_relation
                                         ,par_value             => v_benif_info(i).part
                                         ,par_value_type_brief  => 'percent'
                                         ,par_currency_brief    => 'RUR'
                                         ,par_beneficiary_id    => v_beneficiary_id);
            END;
          END IF;
        END LOOP;
      END;
    END LOOP;
  
    UPDATE as_asset se
       SET (se.start_date, se.end_date) =
           (SELECT MIN(pc.start_date)
                  ,MAX(pc.end_date)
              FROM p_cover pc
             WHERE pc.as_asset_id = se.as_asset_id)
     WHERE se.p_policy_id = v_policy_id;
  
    UPDATE as_assured aas
       SET aas.is_get_prof = 1
     WHERE aas.as_assured_id IN
           (SELECT aa.as_asset_id FROM as_asset aa WHERE aa.p_policy_id = v_policy_id);
  
    IF v_policy_values.product_brief LIKE '%STRONG_START%2'
       AND v_policy_values.product_brief != 'STRONG_START_ROLF_2'
    THEN
      DECLARE
        v_as_type_count   NUMBER;
        v_adult_type_id   NUMBER;
        v_child_type_id   NUMBER;
        v_s               NUMBER;
        v_c               NUMBER;
        v_s_p             NUMBER;
        v_temp_contact_id NUMBER;
        v_temp_assured_id NUMBER;
      BEGIN
        SELECT t.t_asset_type_id
          INTO v_adult_type_id
          FROM t_asset_type t
         WHERE t.brief = 'ASSET_PERSON';
      
        SELECT t.t_asset_type_id
          INTO v_child_type_id
          FROM t_asset_type t
         WHERE t.brief = 'ASSET_PERSON_CHILD';
      
        SELECT COUNT(*)
          INTO v_as_type_count
          FROM as_asset       aa
              ,p_asset_header ah
         WHERE aa.p_policy_id = v_policy_id
           AND aa.p_asset_header_id = ah.p_asset_header_id
           AND ah.t_asset_type_id = v_adult_type_id;
      
        UPDATE p_cover p
           SET p.ins_amount           = p.ins_amount / v_as_type_count
              ,p.fee                  = p.fee / v_as_type_count
              ,p.premium              = p.premium / v_as_type_count
              ,p.is_handchange_amount = 1
              ,p.is_handchange_fee    = 1
         WHERE p.as_asset_id IN (SELECT aa.as_asset_id
                                   FROM as_asset       aa
                                       ,p_asset_header ah
                                  WHERE aa.p_policy_id = v_policy_id
                                    AND aa.p_asset_header_id = ah.p_asset_header_id
                                    AND ah.t_asset_type_id = v_adult_type_id);
      
        SELECT COUNT(*)
          INTO v_as_type_count
          FROM as_asset       aa
              ,p_asset_header ah
         WHERE aa.p_policy_id = v_policy_id
           AND aa.p_asset_header_id = ah.p_asset_header_id
           AND ah.t_asset_type_id = v_child_type_id;
      
        IF v_as_type_count > 0
        THEN
          UPDATE p_cover p
             SET p.ins_amount           = p.ins_amount / v_as_type_count
                ,p.fee                  = p.fee / v_as_type_count
                ,p.premium              = p.premium / v_as_type_count
                ,p.is_handchange_amount = 1
                ,p.is_handchange_fee    = 1
           WHERE p.as_asset_id IN (SELECT aa.as_asset_id
                                     FROM as_asset       aa
                                         ,p_asset_header ah
                                    WHERE aa.p_policy_id = v_policy_id
                                      AND aa.p_asset_header_id = ah.p_asset_header_id
                                      AND ah.t_asset_type_id = v_child_type_id);
        ELSE
          --Рассчитываем текущий суммарный взнос по взрослым
          SELECT SUM(pc.fee)
                ,SUM(abs(pc.premium - pc.fee))
            INTO v_s
                ,v_s_p
            FROM p_cover        pc
                ,as_asset       aa
                ,p_asset_header ah
           WHERE aa.p_policy_id = v_policy_id
             AND pc.as_asset_id = aa.as_asset_id
             AND aa.p_asset_header_id = ah.p_asset_header_id
             AND ah.t_asset_type_id = v_adult_type_id;
        
          -- Создаем временного ребенка, чтобы правильно расчитать целевой суммарный взнос
          SAVEPOINT before_temp_child_creation;
        
          v_temp_contact_id := pkg_renlife_utils.create_person_contact(p_last_name       => 'Застрахованный Импорт'
                                                                      ,p_first_name      => 'Временный'
                                                                      ,p_middle_name     => v_pol_num
                                                                      ,p_birth_date      => ADD_MONTHS(trunc(SYSDATE)
                                                                                                      ,-12 * 12)
                                                                      ,p_gender          => 'М'
                                                                      ,p_pass_ser        => NULL
                                                                      ,p_pass_num        => NULL
                                                                      ,p_pass_issue_date => NULL
                                                                      ,p_pass_issued_by  => NULL);
        
          v_temp_assured_id := pkg_asset.create_as_assured(p_pol_id        => v_policy_id
                                                          ,p_contact_id    => v_temp_contact_id
                                                          ,p_work_group_id => NULL
                                                          ,p_asset_type    => 'ASSET_PERSON_CHILD');
        
          FOR rec IN (SELECT pl.id
                            ,nvl2(lead(pl.id) over(ORDER BY pl.id), 0, 1) is_last
                            ,plt.product_line_type_id
                        FROM t_product_version   pv
                            ,t_product_ver_lob   pvl
                            ,t_product_line      pl
                            ,t_product_line_type plt
                            ,t_prod_line_option  plo
                            ,t_as_type_prod_line tat
                            ,t_asset_type        ast
                       WHERE pv.product_id = v_policy_values.product_id
                         AND pv.t_product_version_id = pvl.product_version_id
                         AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                         AND pl.product_line_type_id = plt.product_line_type_id
                         AND pl.id = plo.product_line_id
                         AND tat.product_line_id = pl.id
                         AND tat.asset_common_type_id = ast.t_asset_type_id
                         AND ast.brief = 'ASSET_PERSON_CHILD'
                         AND pl.skip_on_policy_creation = 0
                       ORDER BY CASE product_line_type_id
                                  WHEN 2 THEN
                                   -1
                                  ELSE
                                   product_line_type_id
                                END)
          LOOP
            DECLARE
              v_normrate         NUMBER;
              v_loading          NUMBER;
              v_netto            NUMBER;
              v_brutto           NUMBER;
              v_cover_id         p_cover.p_cover_id%TYPE;
              v_cover_start_date DATE;
              v_cover_end_date   DATE;
              v_coef_calc_result NUMBER;
              v_ins_sum_coef     NUMBER;
              v_limit            NUMBER;
              v_ins_amount       NUMBER;
            BEGIN
            
              /* Создаем покрытие */
              v_cover_id := pkg_cover.cre_new_cover(v_temp_assured_id, rec.id, rec.is_last = 1);
              /* Нагрузка */
              v_loading := pkg_cover.calc_loading(v_cover_id);
              /* Норма доходности */
              v_normrate         := pkg_productlifeproperty.calc_normrate_value(v_cover_id);
              v_coef_calc_result := pkg_tariff.calc_cover_coef(v_cover_id);
            
              /* Изменяем параметры покрытия, чтоыб правильно все рассчитать */
              v_ins_sum_coef := pkg_tariff_calc.calc_coeff_val('Ins_Sum_CR_Koef_table'
                                                              ,t_number_type(rec.id
                                                                            ,v_policy_values.fund_id));
            
              v_limit := pkg_tariff_calc.calc_coeff_val('Ins_Sum_CR_limit'
                                                       ,t_number_type(rec.id, v_policy_values.fund_id));
            
              v_ins_amount := v_death_ns_ins_sum * nvl(v_ins_sum_coef, 1);
              IF v_limit IS NOT NULL
              THEN
                v_ins_amount := least(v_ins_amount, v_limit);
              END IF;
            
              UPDATE p_cover pc
                 SET is_handchange_amount = 0
                    ,normrate_value       = v_normrate
                    ,rvb_value            = v_loading
                    ,ins_amount           = v_ins_amount
                    ,start_date           = v_start_date
                    ,end_date             = v_end_date
                    ,premia_base_type     = 0 -- Расчет от СС
               WHERE pc.p_cover_id = v_cover_id;
            
              /* Расчет покрытия */
              pkg_cover.update_cover_sum(p_p_cover_id => v_cover_id);
            
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20001
                                       ,'Ошибка подключения покрытия: ' || SQLERRM);
            END;
          END LOOP;
        
          SELECT SUM(pc.fee)
                ,SUM(abs(pc.premium - pc.fee))
            INTO v_c
                ,v_s_p
            FROM p_cover        pc
                ,as_asset       aa
                ,p_asset_header ah
           WHERE aa.p_policy_id = v_policy_id
             AND pc.as_asset_id = aa.as_asset_id
             AND aa.p_asset_header_id = ah.p_asset_header_id
             AND ah.t_asset_type_id = v_child_type_id;
        
          ROLLBACK TO before_temp_child_creation;
        
          UPDATE p_cover p
             SET p.fee                  = p.fee * (v_s + v_c) / v_s
                ,p.premium              = p.premium * (v_s + v_c) / v_s
                ,p.is_handchange_amount = 1
                ,p.is_handchange_fee    = 1
           WHERE p.as_asset_id IN (SELECT aa.as_asset_id
                                     FROM as_asset       aa
                                         ,p_asset_header ah
                                    WHERE aa.p_policy_id = v_policy_id
                                      AND aa.p_asset_header_id = ah.p_asset_header_id
                                      AND ah.t_asset_type_id = v_adult_type_id);
        
        END IF;
      END;
    END IF;
  
    pkg_policy.update_policy_sum(p_p_policy_id => v_policy_id);
  
    pkg_renlife_utils.add_policy_agent_doc(par_policy_header_id      => v_pol_header_id
                                          ,par_ag_contract_header_id => v_ag_contract_header_id);
  
    v_bso_id := pkg_bso.find_bso_by_num(par_policy_id => v_policy_id
                                       ,par_bso_num   => substr(v_pol_num, 4, 6));
  
    pkg_bso.attach_bso_to_policy(par_policy_id => v_policy_id, par_bso_id => v_bso_id);
  
    --/Чирков/ добавляем проверку на премию по ДС/302786: Универсальный загрузчик - расчет преми/
    premium_check(par_policy_id => v_policy_id, par_original_premium => v_sum_fee);
    --    
  
    UPDATE load_file_rows lf
       SET lf.ure_id     = 282
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg VARCHAR2(4000);
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
        ROLLBACK TO before_load;
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_strong_start;

  PROCEDURE load_strong_start_rus(par_load_file_rows_id NUMBER) IS
  
    TYPE t_r_benif_info IS RECORD(
       contact_info t_contact_info
      ,programs     VARCHAR2(50)
      ,part         NUMBER
      ,relation     VARCHAR2(20));
  
    TYPE t_asset_info IS RECORD(
       contact_info     t_contact_info
      ,asset_type_brief t_asset_type.brief%TYPE);
  
    TYPE t_asset_info_array IS TABLE OF t_asset_info INDEX BY PLS_INTEGER;
    TYPE t_benif_info_array IS TABLE OF t_r_benif_info INDEX BY PLS_INTEGER;
  
    v_insuree_info t_contact_info;
    v_insured_info t_asset_info_array;
    v_benif_info   t_benif_info_array;
  
    v_pol_num    VARCHAR2(20);
    v_sum_fee    NUMBER;
    v_start_date DATE;
  
    v_comment VARCHAR2(1000);
  
    v_row           load_file_rows%ROWTYPE;
    v_policy_values pkg_products.t_product_defaults;
    v_insured_count PLS_INTEGER := 0;
    v_benif_count   PLS_INTEGER := 0;
  
    v_ag_contract_header_id NUMBER;
    v_agency_id             NUMBER;
    v_end_date              DATE;
  
    v_sales_channel_id   NUMBER;
    v_death_ns_ins_sum   NUMBER;
    v_region_id          NUMBER;
    v_policy_id          NUMBER;
    v_pol_header_id      NUMBER;
    v_discount           NUMBER;
    v_partner            VARCHAR2(100);
    v_product_brief      VARCHAR2(100);
    v_product_id         NUMBER;
    v_ag_contract_num    document.num%TYPE;
    v_insuree_contact_id NUMBER;
    v_assured_array      pkg_asset.t_assured_array := pkg_asset.t_assured_array();
  BEGIN
    SAVEPOINT before_load;
    /*
    Записываем данные из строки иморта в понятные переменные
    */
    SELECT * INTO v_row FROM load_file_rows t WHERE t.load_file_rows_id = par_load_file_rows_id;
  
    BEGIN
    
      v_insuree_info.name        := regexp_substr(v_row.val_2, '[^ ]+', 1, 1);
      v_insuree_info.first_name  := regexp_substr(v_row.val_2, '[^ ]+', 1, 2);
      v_insuree_info.middle_name := regexp_substr(v_row.val_2, '[^ ]+', 1, 3);
      v_insuree_info.address     := v_row.val_4;
    
      v_pol_num := v_row.val_3;
      --v_program_type  := v_row.val_5;
      --v_payment_terms := v_row.val_6;
    
      v_sum_fee := to_number(v_row.val_8, 'FM9999999999D99', 'NLS_NUMERIC_CHARACTERS = ''.,''');
    
      /*      v_fee_brought_by_agent   := TO_NUMBER(v_row.val_11
      ,'FM9999999999D99'
      ,'NLS_NUMERIC_CHARACTERS = ''.,''');*/
      v_death_ns_ins_sum := to_number(v_row.val_14
                                     ,'FM999999999D99'
                                     ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      /*v_dis_ns_ins_sum     := to_number(v_row.val_15
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_death_dtp_ins_sum  := to_number(v_row.val_16
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_dis_dtp_ins_sum    := to_number(v_row.val_17
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_break_burn_ins_sum := to_number(v_row.val_18
                                       ,'FM9999999999D99'
                                       ,'NLS_NUMERIC_CHARACTERS = ''.,''');*/
    
      v_start_date := to_date(v_row.val_19 || '.' || v_row.val_20 || '.' || v_row.val_21, 'DD.MM.YYYY');
    
      v_insuree_info.birth_date    := to_date(v_row.val_23, 'dd.mm.yyyy');
      v_insuree_info.gender        := v_row.val_24;
      v_insuree_info.phone_numbers := v_row.val_25;
      v_insuree_info.email         := v_row.val_26;
      v_insuree_info.pass_ser      := v_row.val_27;
      v_insuree_info.pass_num      := v_row.val_28;
      v_insuree_info.pass_when     := to_date(v_row.val_29, 'dd.mm.yyyy');
      v_insuree_info.pass_who      := v_row.val_30;
    
      IF v_row.val_31 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        DECLARE
          v_asset_info t_contact_info;
        BEGIN
          v_asset_info.name        := regexp_substr(v_row.val_31, '[^ ]+', 1, 1);
          v_asset_info.first_name  := regexp_substr(v_row.val_31, '[^ ]+', 1, 2);
          v_asset_info.middle_name := regexp_substr(v_row.val_31, '[^ ]+', 1, 3);
        
          v_asset_info.birth_date    := to_date(v_row.val_32, 'dd.mm.yyyy');
          v_asset_info.gender        := v_row.val_34;
          v_asset_info.phone_numbers := v_row.val_33;
          v_asset_info.pass_ser      := v_row.val_35;
          v_asset_info.pass_num      := v_row.val_36;
          v_asset_info.pass_when     := to_date(v_row.val_37, 'dd.mm.yyyy');
          v_asset_info.pass_who      := v_row.val_38;
          v_asset_info.address       := v_row.val_39;
        
          v_insured_info(v_insured_count).contact_info := v_asset_info;
          v_insured_info(v_insured_count).asset_type_brief := 'ASSET_PERSON';
        END;
      END IF;
    
      IF v_row.val_40 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        DECLARE
          v_asset_info t_contact_info;
        BEGIN
          v_asset_info.name        := regexp_substr(v_row.val_40, '[^ ]+', 1, 1);
          v_asset_info.first_name  := regexp_substr(v_row.val_40, '[^ ]+', 1, 2);
          v_asset_info.middle_name := regexp_substr(v_row.val_40, '[^ ]+', 1, 3);
        
          v_asset_info.birth_date    := to_date(v_row.val_41, 'dd.mm.yyyy');
          v_asset_info.phone_numbers := v_row.val_42;
          v_asset_info.gender        := v_row.val_43;
          v_asset_info.pass_ser      := v_row.val_44;
          v_asset_info.pass_num      := v_row.val_45;
          v_asset_info.pass_when     := to_date(v_row.val_46, 'dd.mm.yyyy');
          v_asset_info.pass_who      := v_row.val_47;
          v_asset_info.address       := v_row.val_48;
        
          v_insured_info(v_insured_count).contact_info := v_asset_info;
          v_insured_info(v_insured_count).asset_type_brief := 'ASSET_PERSON';
        END;
      END IF;
    
      /*Застрахованные дети*/
      IF v_row.val_49 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        DECLARE
          v_asset_info t_contact_info;
        BEGIN
          v_asset_info.name        := regexp_substr(v_row.val_49, '[^ ]+', 1, 1);
          v_asset_info.first_name  := regexp_substr(v_row.val_49, '[^ ]+', 1, 2);
          v_asset_info.middle_name := regexp_substr(v_row.val_49, '[^ ]+', 1, 3);
          v_asset_info.gender      := v_row.val_50;
          v_asset_info.birth_date  := to_date(v_row.val_51, 'dd.mm.yyyy');
        
          v_insured_info(v_insured_count).contact_info := v_asset_info;
          v_insured_info(v_insured_count).asset_type_brief := 'ASSET_PERSON_CHILD';
        END;
      END IF;
      IF v_row.val_52 IS NOT NULL
      THEN
        v_insured_count := v_insured_count + 1;
        DECLARE
          v_asset_info t_contact_info;
        BEGIN
          v_asset_info.name        := regexp_substr(v_row.val_52, '[^ ]+', 1, 1);
          v_asset_info.first_name  := regexp_substr(v_row.val_52, '[^ ]+', 1, 2);
          v_asset_info.middle_name := regexp_substr(v_row.val_52, '[^ ]+', 1, 3);
          v_asset_info.gender      := v_row.val_53;
          v_asset_info.birth_date  := to_date(v_row.val_54, 'dd.mm.yyyy');
        
          v_insured_info(v_insured_count).contact_info := v_asset_info;
          v_insured_info(v_insured_count).asset_type_brief := 'ASSET_PERSON_CHILD';
        END;
      END IF;
    
      /*
      Выгодоприобретатели
      */
      IF v_row.val_55 IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        DECLARE
          v_benif_contact_info t_contact_info;
        BEGIN
          v_benif_contact_info.name        := regexp_substr(v_row.val_55, '[^ ]+', 1, 1);
          v_benif_contact_info.first_name  := regexp_substr(v_row.val_55, '[^ ]+', 1, 2);
          v_benif_contact_info.middle_name := regexp_substr(v_row.val_55, '[^ ]+', 1, 3);
          v_benif_contact_info.birth_date  := to_date(v_row.val_56, 'dd.mm.yyyy');
        
          v_benif_info(v_benif_count).contact_info := v_benif_contact_info;
        END;
        v_benif_info(v_benif_count).relation := v_row.val_57;
        v_benif_info(v_benif_count).programs := v_row.val_58;
        v_benif_info(v_benif_count).part := to_number(REPLACE(v_row.val_59, '%')
                                                     ,'FM9999999999D99'
                                                     ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      END IF;
      IF v_row.val_60 IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        DECLARE
          v_benif_contact_info t_contact_info;
        BEGIN
          v_benif_contact_info.name        := regexp_substr(v_row.val_60, '[^ ]+', 1, 1);
          v_benif_contact_info.first_name  := regexp_substr(v_row.val_60, '[^ ]+', 1, 2);
          v_benif_contact_info.middle_name := regexp_substr(v_row.val_60, '[^ ]+', 1, 3);
          v_benif_contact_info.birth_date  := to_date(v_row.val_61, 'dd.mm.yyyy');
        
          v_benif_info(v_benif_count).contact_info := v_benif_contact_info;
        END;
        v_benif_info(v_benif_count).relation := v_row.val_62;
        v_benif_info(v_benif_count).programs := v_row.val_63;
        v_benif_info(v_benif_count).part := to_number(REPLACE(v_row.val_64, '%')
                                                     ,'FM9999999999D99'
                                                     ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      END IF;
    
      v_comment  := v_row.val_67;
      v_discount := v_row.val_68;
      v_partner  := v_row.val_69;
    
    END;
  
    IF v_insured_info.count > 1
    THEN
      v_product_brief := 'STRONG_START_RUS_2';
    ELSE
      v_product_brief := 'STRONG_START_RUS_1';
    END IF;
  
    SELECT product_id INTO v_product_id FROM t_product WHERE brief = v_product_brief;
  
    -- Находим информацию по агенту
    BEGIN
      SELECT nvl(cn.ag_sales_chn_id, ch.t_sales_channel_id) -- для старого модуля сделан nvl
            ,cn.agency_id
            ,ot.province_id
            ,ch.ag_contract_header_id
            ,ch.num
        INTO v_sales_channel_id
            ,v_agency_id
            ,v_region_id
            ,v_ag_contract_header_id
            ,v_ag_contract_num
        FROM ven_ag_contract_header ch
            ,ag_contract            cn
            ,department             dp
            ,organisation_tree      ot
            ,contact                c
            ,doc_status_ref         dsr
       WHERE ch.last_ver_id = cn.ag_contract_id
         AND cn.agency_id = dp.department_id
         AND dp.org_tree_id = ot.organisation_tree_id
         AND ch.agent_id = c.contact_id
         AND ch.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'CURRENT'
         AND c.obj_name_orig = v_partner; -- Определяем по названию партнера из бордеро
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдены канал продаж, агентство, регион у агента');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько каналов, агентств, регионов у агента');
    END;
  
    --    v_end_date := ADD_MONTHS(v_start_date, 12) - INTERVAL '1' SECOND;
  
    /* Создаем страхователя */
    create_contact(par_contact_info => v_insuree_info, par_contact_id_out => v_insuree_contact_id);
  
    /* Готовим застрахованного */
    v_assured_array.extend(v_insured_info.count);
    FOR i IN 1 .. v_insured_info.count
    LOOP
      DECLARE
        v_cover_array pkg_cover.t_cover_array := pkg_cover.t_cover_array();
        v_bnf_array   pkg_asset.t_beneficiary_array := pkg_asset.t_beneficiary_array();
      BEGIN
      
        create_contact(par_contact_info   => v_insured_info(i).contact_info
                      ,par_contact_id_out => v_assured_array(i).contact_id);
      
        v_assured_array(i).assured_type_brief := v_insured_info(i).asset_type_brief;
      
        DECLARE
          v_bnf_relation VARCHAR2(30);
          benif_error EXCEPTION;
          PRAGMA EXCEPTION_INIT(benif_error, -20001);
        BEGIN
          FOR i IN 1 .. v_benif_info.count
          LOOP
          
            IF (v_insured_info(i).asset_type_brief = 'ASSET_PERSON' AND
                (v_benif_info(i).programs = 'Смерть застрахованного 1,2'))
               OR (v_insured_info(i).asset_type_brief = 'ASSET_PERSON_CHILD' AND v_benif_info(i)
               .programs = 'Все риски застрахованного 3,4' AND
                v_policy_values.product_brief LIKE 'STRONG_START%2')
            THEN
              DECLARE
                v_bnf_rec pkg_asset.t_beneficiary_rec;
              BEGIN
                BEGIN
                  SELECT rt.relationship_dsc
                        ,rt.gender_id
                    INTO v_bnf_relation
                        ,v_benif_info(i).contact_info.gender
                    FROM t_contact_rel_type rt
                   WHERE upper(rt.relationship_dsc) = upper(v_benif_info(i).relation)
                     AND rownum = 1;
                EXCEPTION
                  WHEN no_data_found THEN
                    v_bnf_relation := 'Другой';
                    v_benif_info(i).contact_info.gender := 0;
                END;
              
                v_bnf_array.extend(1);
              
                create_contact(par_contact_info   => v_benif_info(i).contact_info
                              ,par_contact_id_out => v_bnf_rec.contact_id);
              
                v_bnf_rec.relation_name := v_bnf_relation;
                v_bnf_rec.part_value := v_benif_info(i).part;
                v_bnf_array(i) := v_bnf_rec;
              END;
            END IF;
          
          END LOOP;
        END;
        v_assured_array(i).benificiary_array := v_bnf_array;
        v_assured_array(i).cover_array := v_cover_array;
      END;
    END LOOP;
  
    pkg_policy.create_universal(par_product_brief      => v_product_brief
                               ,par_ag_num             => v_ag_contract_num
                               ,par_start_date         => v_start_date
                               ,par_end_date           => v_end_date
                               ,par_insuree_contact_id => v_insuree_contact_id
                               ,par_bso_number         => substr(v_pol_num, 4, 6)
                               ,par_assured_array      => v_assured_array
                               ,par_pol_num            => v_pol_num
                               ,par_base_sum           => v_death_ns_ins_sum
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
  
    --/Чирков/ добавляем проверку на премию по ДС/302786: Универсальный загрузчик - расчет преми/
    premium_check(par_policy_id => v_policy_id, par_original_premium => v_sum_fee);
    --                               
  
    UPDATE load_file_rows lf
       SET lf.ure_id     = 282
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg VARCHAR2(4000);
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
        ROLLBACK TO before_load;
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_strong_start_rus;

  PROCEDURE load_hkf
  (
    par_load_file_row_id load_file_rows.load_file_rows_id%TYPE
   ,par_product_brief    t_product.brief%TYPE
   ,par_ag_contract_num  ven_ag_contract_header.num%TYPE
   ,par_bso_series_num   bso_series.series_num%TYPE
   ,par_benif_contact_id contact.contact_id%TYPE
  ) IS
  
    TYPE t_policy_info IS RECORD(
       notice_num    p_policy.notice_num%TYPE
      ,notice_date   p_policy.notice_date%TYPE
      ,start_date    p_policy.start_date%TYPE
      ,end_date      p_policy.end_date%TYPE
      ,base_sum      p_policy.base_sum%TYPE
      ,total_premium p_policy.premium%TYPE
      ,fund_brief    fund.brief%TYPE);
  
    v_contact_info t_contact_info;
    v_contact_id   contact.contact_id%TYPE;
  
    v_policy_info   t_policy_info;
    v_policy_id     p_policy.policy_id%TYPE;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  
    v_bso_series_id bso_series.bso_series_id%TYPE;
    v_bso_number    bso.num%TYPE;
    v_agent_id      ag_contract_header.agent_id%TYPE;
  
    v_asset_array pkg_asset.t_assured_array;
  
    PROCEDURE process_row
    (
      par_load_file_row_id load_file_rows.load_file_rows_id%TYPE
     ,par_contact_info     OUT t_contact_info
     ,par_policy_info      OUT t_policy_info
    ) IS
      v_load_row load_file_rows%ROWTYPE;
    BEGIN
    
      SELECT * INTO v_load_row FROM load_file_rows l WHERE l.load_file_rows_id = par_load_file_row_id;
      -- Сохраняем инфу по контакту
      par_contact_info.name          := v_load_row.val_1;
      par_contact_info.first_name    := v_load_row.val_2;
      par_contact_info.middle_name   := v_load_row.val_3;
      par_contact_info.birth_date    := to_date(v_load_row.val_4, 'dd.mm.yyyy');
      par_contact_info.gender        := v_load_row.val_5;
      par_contact_info.pass_ser      := v_load_row.val_6;
      par_contact_info.pass_num      := v_load_row.val_7;
      par_contact_info.pass_who      := v_load_row.val_8;
      par_contact_info.pass_when     := to_date(v_load_row.val_9, 'dd.mm.yyyy');
      par_contact_info.address       := v_load_row.val_10;
      par_contact_info.phone_numbers := v_load_row.val_11;
    
      -- Сохраняем инфу по полису
      par_policy_info.notice_num    := v_load_row.val_12;
      par_policy_info.notice_date   := v_load_row.val_13;
      par_policy_info.start_date    := to_date(v_load_row.val_14, 'dd.mm.yyyy');
      par_policy_info.end_date      := to_date(v_load_row.val_15, 'dd.mm.yyyy');
      par_policy_info.base_sum      := v_load_row.val_16;
      par_policy_info.total_premium := v_load_row.val_17;
      par_policy_info.fund_brief    := v_load_row.val_18;
    
    END process_row;
  
    FUNCTION create_asset_array
    (
      par_contact_id             contact.contact_id%TYPE
     ,par_benificiary_contact_id contact.contact_id%TYPE
    ) RETURN pkg_asset.t_assured_array IS
      v_assured_rec pkg_asset.t_assured_rec;
      v_benif_rec   pkg_asset.t_beneficiary_rec;
    BEGIN
    
      v_assured_rec.contact_id := par_contact_id;
    
      IF par_benificiary_contact_id IS NOT NULL
      THEN
        v_benif_rec.contact_id          := par_benificiary_contact_id;
        v_benif_rec.relation_name       := 'Банк';
        v_benif_rec.part_value          := 100;
        v_assured_rec.benificiary_array := pkg_asset.t_beneficiary_array(v_benif_rec);
      END IF;
    
      RETURN pkg_asset.t_assured_array(v_assured_rec);
    
    END create_asset_array;
  
    FUNCTION get_agent_id_by_ag_header_num(par_ag_header_num ven_ag_contract_header.num%TYPE)
      RETURN ag_contract_header.agent_id%TYPE IS
      v_agent_id ag_contract_header.agent_id%TYPE;
    BEGIN
      SELECT agent_id INTO v_agent_id FROM ven_ag_contract_header ah WHERE ah.num = par_ag_header_num;
      RETURN v_agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить агента по номеру АД');
      
    END get_agent_id_by_ag_header_num;
  
  BEGIN
  
    SAVEPOINT before_load;
  
    process_row(par_load_file_row_id => par_load_file_row_id
               ,par_contact_info     => v_contact_info
               ,par_policy_info      => v_policy_info);
  
    create_contact(par_contact_info => v_contact_info, par_contact_id_out => v_contact_id);
  
    v_asset_array := create_asset_array(par_contact_id             => v_contact_id
                                       ,par_benificiary_contact_id => par_benif_contact_id);
  
    v_bso_series_id := pkg_bso.get_bso_series_id(par_bso_series_num => par_bso_series_num);
  
    v_agent_id := get_agent_id_by_ag_header_num(par_ag_header_num => par_ag_contract_num);
  
    v_bso_number := pkg_bso.gen_next_bso_number(par_bso_series_id => v_bso_series_id
                                               ,par_agent_id      => v_agent_id);
  
    pkg_policy.create_universal(par_product_brief      => par_product_brief
                               ,par_ag_num             => par_ag_contract_num
                               ,par_start_date         => v_policy_info.start_date
                               ,par_end_date           => v_policy_info.end_date - INTERVAL '1' SECOND
                               ,par_insuree_contact_id => v_contact_id
                               ,par_assured_array      => v_asset_array
                               ,par_pol_num            => v_policy_info.notice_num
                               ,par_notice_date        => v_policy_info.notice_date
                               ,par_notice_num         => v_policy_info.notice_num
                               ,par_bso_number         => v_bso_number
                               ,par_bso_series_id      => v_bso_series_id
                               ,par_base_sum           => v_policy_info.base_sum
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
  
    premium_check(par_policy_id => v_policy_id, par_original_premium => v_policy_info.total_premium);
  
    /* Помечаем договор, как успешно обработанный */
    UPDATE load_file_rows lf
       SET lf.ure_id     = ent.id_by_brief('P_POL_HEADER')
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_row_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_row_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg load_file_rows.row_comment%TYPE;
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
      
        ROLLBACK TO before_load;
      
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_row_id;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_row_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_hkf;

  PROCEDURE load_hkf_92_10(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_10'
            ,par_ag_contract_num  => '45174'
            ,par_bso_series_num   => 275
            ,par_benif_contact_id => NULL);
  END load_hkf_92_10;

  PROCEDURE load_hkf_92_9(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_9'
            ,par_ag_contract_num  => '45174'
            ,par_bso_series_num   => 274
            ,par_benif_contact_id => NULL);
  END load_hkf_92_9;

  PROCEDURE load_hkf_92_8(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_8'
            ,par_ag_contract_num  => '45174'
            ,par_bso_series_num   => 273
            ,par_benif_contact_id => NULL);
  END load_hkf_92_8;

  PROCEDURE load_hkf_92_7(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_7'
            ,par_ag_contract_num  => '45174'
            ,par_bso_series_num   => 272
            ,par_benif_contact_id => NULL);
  END load_hkf_92_7;

  PROCEDURE load_hkf_92_6(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_6'
            ,par_ag_contract_num  => '45175'
            ,par_bso_series_num   => 629
            ,par_benif_contact_id => NULL);
  END load_hkf_92_6;

  PROCEDURE load_hkf_92_5(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_5'
            ,par_ag_contract_num  => '46885'
            ,par_bso_series_num   => 524
            ,par_benif_contact_id => NULL);
  END load_hkf_92_5;

  PROCEDURE load_hkf_92_4(par_load_file_row_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    load_hkf(par_load_file_row_id => par_load_file_row_id
            ,par_product_brief    => 'CR92_4'
            ,par_ag_contract_num  => '46885'
            ,par_bso_series_num   => 523
            ,par_benif_contact_id => NULL);
  END load_hkf_92_4;

  PROCEDURE load_imoney_bank(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
  
    TYPE t_policy_info IS RECORD(
       notice_num    p_policy.notice_num%TYPE
      ,start_date    p_policy.start_date%TYPE
      ,end_date      p_policy.end_date%TYPE
      ,base_sum      p_policy.base_sum%TYPE
      ,total_premium p_policy.premium%TYPE);
  
    v_contact_info t_contact_info;
    v_contact_id   contact.contact_id%TYPE;
  
    v_policy_info   t_policy_info;
    v_policy_id     p_policy.policy_id%TYPE;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
    v_product_brief t_product.brief%TYPE;
  
    v_bso_series_id bso_series.bso_series_id%TYPE;
    v_bso_series_num CONSTANT bso_series.series_num%TYPE := 186;
    v_bso_number bso.num%TYPE;
    v_agent_id   ag_contract_header.agent_id%TYPE;
    v_ag_contract_num CONSTANT ven_ag_contract_header.num%TYPE := '47952';
  
    v_asset_array pkg_asset.t_assured_array;
  
    PROCEDURE process_row
    (
      par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE
     ,par_contact_info      OUT t_contact_info
     ,par_policy_info       OUT t_policy_info
    ) IS
      v_load_row load_file_rows%ROWTYPE;
    BEGIN
    
      SELECT *
        INTO v_load_row
        FROM load_file_rows l
       WHERE l.load_file_rows_id = par_load_file_rows_id;
    
      -- Сохраняем инфу по контакту
      par_contact_info.name        := v_load_row.val_2;
      par_contact_info.first_name  := v_load_row.val_3;
      par_contact_info.middle_name := v_load_row.val_4;
      par_contact_info.gender      := v_load_row.val_5;
      par_contact_info.birth_date  := to_date(v_load_row.val_6, 'dd.mm.yyyy');
    
      par_contact_info.pass_ser  := v_load_row.val_7;
      par_contact_info.pass_num  := v_load_row.val_8;
      par_contact_info.pass_when := to_date(v_load_row.val_9, 'dd.mm.yyyy');
      par_contact_info.pass_who  := v_load_row.val_10;
    
      par_contact_info.address := v_load_row.val_11;
    
      -- Сохраняем инфу по полису
      par_policy_info.notice_num    := v_load_row.val_1;
      par_policy_info.start_date    := to_date(v_load_row.val_12, 'dd.mm.yyyy');
      par_policy_info.end_date      := to_date(v_load_row.val_13, 'dd.mm.yyyy') - INTERVAL '1' SECOND;
      par_policy_info.base_sum      := to_number(v_load_row.val_14
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      par_policy_info.total_premium := to_number(v_load_row.val_15
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
    
    END process_row;
  
    FUNCTION create_asset_array
    (
      par_contact_id             contact.contact_id%TYPE
     ,par_benificiary_contact_id contact.contact_id%TYPE
    ) RETURN pkg_asset.t_assured_array IS
      v_assured_rec pkg_asset.t_assured_rec;
      v_benif_rec   pkg_asset.t_beneficiary_rec;
    BEGIN
    
      v_assured_rec.contact_id := par_contact_id;
    
      IF par_benificiary_contact_id IS NOT NULL
      THEN
        v_benif_rec.contact_id          := par_benificiary_contact_id;
        v_benif_rec.relation_name       := 'Банк';
        v_benif_rec.part_value          := 100;
        v_assured_rec.benificiary_array := pkg_asset.t_beneficiary_array(v_benif_rec);
      END IF;
    
      RETURN pkg_asset.t_assured_array(v_assured_rec);
    
    END create_asset_array;
  
    FUNCTION create_cover_array
    (
      par_product_brief t_product.brief%TYPE
     ,par_contact_info  t_contact_info
     ,par_start_date    DATE
     ,par_end_date      DATE
    ) RETURN pkg_cover.t_cover_array IS
      vr_cover_info  pkg_cover.t_cover_rec;
      va_covers      pkg_cover.t_cover_array := pkg_cover.t_cover_array();
      v_age_on_start PLS_INTEGER := MONTHS_BETWEEN(par_start_date, par_contact_info.birth_date) / 12;
      v_age_on_end   NUMBER := MONTHS_BETWEEN(par_end_date, par_contact_info.birth_date) / 12;
    BEGIN
      FOR vr_cover IN (SELECT plo.id AS prod_line_option_id
                             ,plo.brief
                             ,CASE
                                WHEN plo.brief IN ('Death_any', 'Dis_any', 'ATD') THEN
                                 66
                                WHEN plo.brief IN ('AD_66_71', 'ADis_66_71') THEN
                                 71
                                ELSE
                                 76
                              END AS cover_end_age
                             ,CASE
                                WHEN plo.brief IN ('Death_any', 'Dis_any', 'ATD') THEN
                                 18
                                WHEN plo.brief IN ('AD_66_71', 'ADis_66_71') THEN
                                 66
                                ELSE
                                 71
                              END AS cover_start_age
                         FROM v_prod_product_line ppl
                             ,t_prod_line_option  plo
                             ,t_product_line      pl
                             ,t_product_line_type plt
                        WHERE ppl.product_brief = par_product_brief
                          AND ppl.t_product_line_id = plo.product_line_id
                          AND ppl.t_product_line_id = pl.id
                          AND pl.product_line_type_id = plt.product_line_type_id
                          AND pl.skip_on_policy_creation = 0
                        ORDER BY plt.sort_order
                                ,pl.sort_order)
      LOOP
        IF v_age_on_start BETWEEN vr_cover.cover_start_age AND vr_cover.cover_end_age
           OR v_age_on_end BETWEEN vr_cover.cover_start_age AND vr_cover.cover_end_age
        THEN
          vr_cover_info.t_prod_line_opt_id := vr_cover.prod_line_option_id;
          vr_cover_info.start_date         := greatest(par_start_date
                                                      ,ADD_MONTHS(par_contact_info.birth_date
                                                                 ,vr_cover.cover_start_age * 12));
          vr_cover_info.end_date           := least(par_end_date
                                                   ,ADD_MONTHS(par_contact_info.birth_date
                                                              ,vr_cover.cover_end_age * 12) - INTERVAL '1'
                                                    SECOND);
          va_covers.extend;
          va_covers(va_covers.last) := vr_cover_info;
        END IF;
      END LOOP;
      IF va_covers.count = 0
      THEN
        raise_application_error(-20001
                               ,'Не удалось сформировать массив программ при создании договора');
      END IF;
    
      RETURN va_covers;
    
    END create_cover_array;
  
    FUNCTION get_agent_id_by_ag_header_num(par_ag_header_num ven_ag_contract_header.num%TYPE)
      RETURN ag_contract_header.agent_id%TYPE IS
      v_agent_id ag_contract_header.agent_id%TYPE;
    BEGIN
      SELECT agent_id INTO v_agent_id FROM ven_ag_contract_header ah WHERE ah.num = par_ag_header_num;
      RETURN v_agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить агента по номеру АД');
      
    END get_agent_id_by_ag_header_num;
  
  BEGIN
    SAVEPOINT before_load;
  
    process_row(par_load_file_rows_id => par_load_file_rows_id
               ,par_contact_info      => v_contact_info
               ,par_policy_info       => v_policy_info);
  
    IF v_policy_info.base_sum <= 400000
    THEN
      v_product_brief := 'CR111_1';
    ELSE
      v_product_brief := 'CR111_2';
    END IF;
  
    create_contact(par_contact_info => v_contact_info, par_contact_id_out => v_contact_id);
  
    v_agent_id := get_agent_id_by_ag_header_num(par_ag_header_num => v_ag_contract_num);
  
    v_asset_array := create_asset_array(par_contact_id             => v_contact_id
                                       ,par_benificiary_contact_id => v_agent_id);
  
    v_asset_array(1).cover_array := create_cover_array(par_product_brief => v_product_brief
                                                      ,par_contact_info  => v_contact_info
                                                      ,par_start_date    => v_policy_info.start_date
                                                      ,par_end_date      => v_policy_info.end_date);
  
    v_bso_series_id := pkg_bso.get_bso_series_id(par_bso_series_num => v_bso_series_num);
  
    v_bso_number := pkg_bso.gen_next_bso_number(par_bso_series_id => v_bso_series_id
                                               ,par_agent_id      => v_agent_id);
  
    pkg_policy.create_universal(par_product_brief      => v_product_brief
                               ,par_ag_num             => v_ag_contract_num
                               ,par_start_date         => v_policy_info.start_date
                               ,par_end_date           => v_policy_info.end_date
                               ,par_insuree_contact_id => v_contact_id
                               ,par_assured_array      => v_asset_array
                               ,par_pol_num            => v_policy_info.notice_num
                               ,par_notice_num         => v_policy_info.notice_num
                               ,par_bso_number         => v_bso_number
                               ,par_bso_series_id      => v_bso_series_id
                               ,par_base_sum           => v_policy_info.base_sum
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
  
    premium_check(par_policy_id => v_policy_id, par_original_premium => v_policy_info.total_premium);
  
    /* Помечаем договор, как успешно обработанный */
    UPDATE load_file_rows lf
       SET lf.ure_id     = ent.id_by_brief('P_POL_HEADER')
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg load_file_rows.row_comment%TYPE;
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
      
        ROLLBACK TO before_load;
      
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_imoney_bank;

  PROCEDURE load_credit_policy
  (
    par_load_file_rows_id NUMBER
   ,par_product_brief     VARCHAR2
   ,par_agent_num         ven_ag_contract_header.num%TYPE
  ) IS
  
    v_insuree_contact_info t_contact_info;
    v_assured_contact_info t_contact_info;
  
    v_pol_num           VARCHAR2(25);
    v_sign_date         DATE;
    v_start_date        DATE;
    v_end_date          DATE;
    v_ins_sum           NUMBER;
    v_fee               NUMBER;
    v_fund_brief        fund.brief%TYPE;
    v_payment_term_name VARCHAR2(50);
    v_benif_bank        VARCHAR2(255);
  
    v_row                load_file_rows%ROWTYPE;
    v_payment_terms_id   t_payment_terms.id%TYPE;
    v_fund_id            fund.fund_id%TYPE;
    v_insuree_contact_id contact.contact_id%TYPE;
    v_policy_id          p_policy.policy_id%TYPE;
    v_pol_header_id      p_pol_header.policy_header_id%TYPE;
    v_assured_array      pkg_asset.t_assured_array;
    v_bso_number         bso.num%TYPE;
  
    PROCEDURE create_assured_array
    (
      par_assured_info      t_contact_info
     ,par_benif_bank_name   VARCHAR2
     ,par_assured_array_out OUT pkg_asset.t_assured_array
    ) IS
      vr_assured     pkg_asset.t_assured_rec;
      vr_benificiary pkg_asset.t_beneficiary_rec;
    
      FUNCTION get_bank_contact_id_by_name(par_bank_name contact.obj_name_orig%TYPE)
        RETURN contact.contact_id%TYPE IS
        v_bank_contact_id contact.contact_id%TYPE;
      BEGIN
        SELECT contact_id
          INTO v_bank_contact_id
          FROM contact
         WHERE contact_id =
               (SELECT MAX(contact_id) FROM contact WHERE obj_name_orig = TRIM(par_bank_name));
      
        RETURN v_bank_contact_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не удалось найти контакт выгодоприобретателя для ' ||
                                  par_bank_name);
      END get_bank_contact_id_by_name;
    BEGIN
      /* Создаем контакт */
      create_contact(par_contact_info   => par_assured_info
                    ,par_contact_id_out => vr_assured.contact_id);
    
      /* Создаем выгодоприобретателя */
      vr_benificiary.contact_id      := get_bank_contact_id_by_name(par_benif_bank_name);
      vr_benificiary.relation_name   := 'Банк';
      vr_benificiary.part_type_brief := 'percent';
      vr_benificiary.part_value      := 100;
      vr_benificiary.currency_brief  := 'RUR';
    
      vr_assured.benificiary_array := pkg_asset.t_beneficiary_array(vr_benificiary);
    
      par_assured_array_out := pkg_asset.t_assured_array(vr_assured);
    END create_assured_array;
  
    PROCEDURE correct_premium
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_original_premium NUMBER
    ) IS
      v_total_premium p_policy.premium%TYPE;
    BEGIN
      SELECT nvl(SUM(pp.premium), 0)
        INTO v_total_premium
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
    
      IF v_total_premium != par_original_premium
      THEN
        -- Если корректировка менее 10 копеек, вешаем ее на основную программу, ставим по ней ручной ввод.
        IF abs(v_total_premium - par_original_premium) < 1.30
        THEN
        
          UPDATE p_cover pc
             SET pc.fee     = pc.fee - v_total_premium + par_original_premium
                ,pc.premium = pc.premium - v_total_premium + par_original_premium
           WHERE pc.p_cover_id = (SELECT p_cover_id
                                    FROM p_cover             pc1
                                        ,as_asset            aa
                                        ,t_prod_line_option  plo
                                        ,t_product_line      pl
                                        ,t_product_line_type plt
                                   WHERE aa.p_policy_id = par_policy_id
                                     AND pc1.as_asset_id = aa.as_asset_id
                                     AND pc1.t_prod_line_option_id = plo.id
                                     AND plo.product_line_id = pl.id
                                     AND pl.product_line_type_id = plt.product_line_type_id
                                     AND plt.brief = 'RECOMMENDED');
        
          UPDATE p_cover pc
             SET pc.is_handchange_fee     = 1
                ,pc.is_handchange_premium = 1
                ,pc.is_handchange_amount  = 1
           WHERE pc.p_cover_id IN (SELECT p_cover_id
                                     FROM p_cover  pc1
                                         ,as_asset aa
                                    WHERE aa.p_policy_id = par_policy_id
                                      AND pc1.as_asset_id = aa.as_asset_id);
        
          pkg_policy.update_policy_sum(p_p_policy_id => par_policy_id);
        
        END IF;
      END IF;
    END correct_premium;
  
    FUNCTION get_fund_id_by_brief(par_fund_brief fund.brief%TYPE) RETURN fund.fund_id%TYPE IS
      v_fund_id fund.fund_id%TYPE;
    BEGIN
      IF par_fund_brief IS NOT NULL
      THEN
        BEGIN
          SELECT fund_id INTO v_fund_id FROM fund f WHERE f.brief = par_fund_brief;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось определить валюту по брифу');
        END;
      END IF;
      RETURN v_fund_id;
    END get_fund_id_by_brief;
  
    FUNCTION get_payment_terms_by_desc(par_payment_terms_desc VARCHAR2) RETURN t_payment_terms.id%TYPE IS
      v_payment_terms_id t_payment_terms.id%TYPE;
    BEGIN
      IF par_payment_terms_desc IS NOT NULL
      THEN
        BEGIN
          SELECT pt.id
            INTO v_payment_terms_id
            FROM t_payment_terms pt
           WHERE pt.description = par_payment_terms_desc;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось определить переодичность оплаты по названию');
          WHEN too_many_rows THEN
            raise_application_error(-20001
                                   ,'Не удалось однозначно определить периодичность оплаты по названию');
        END;
      END IF;
      RETURN v_payment_terms_id;
    END get_payment_terms_by_desc;
  
  BEGIN
    SAVEPOINT before_load;
  
    SELECT * INTO v_row FROM load_file_rows t WHERE t.load_file_rows_id = par_load_file_rows_id;
  
    BEGIN
      /* Собираем информацию о страхователе */
      v_insuree_contact_info.name          := v_row.val_1;
      v_insuree_contact_info.first_name    := v_row.val_2;
      v_insuree_contact_info.middle_name   := v_row.val_3;
      v_insuree_contact_info.birth_date    := to_date(v_row.val_4, 'DD.MM.YYYY');
      v_insuree_contact_info.gender        := v_row.val_5;
      v_insuree_contact_info.pass_ser      := v_row.val_6;
      v_insuree_contact_info.pass_num      := v_row.val_7;
      v_insuree_contact_info.pass_who      := v_row.val_8;
      v_insuree_contact_info.pass_when     := to_date(v_row.val_9, 'DD.MM.YYYY');
      v_insuree_contact_info.address       := v_row.val_10;
      v_insuree_contact_info.phone_numbers := v_row.val_11;
      v_insuree_contact_info.email         := v_row.val_12;
    
      /* Собираем информацию о застрахованном */
      v_assured_contact_info.name          := v_row.val_13;
      v_assured_contact_info.first_name    := v_row.val_14;
      v_assured_contact_info.middle_name   := v_row.val_15;
      v_assured_contact_info.birth_date    := to_date(v_row.val_16, 'DD.MM.YYYY');
      v_assured_contact_info.gender        := v_row.val_17;
      v_assured_contact_info.pass_ser      := v_row.val_18;
      v_assured_contact_info.pass_num      := v_row.val_19;
      v_assured_contact_info.pass_who      := v_row.val_20;
      v_assured_contact_info.pass_when     := to_date(v_row.val_21, 'DD.MM.YYYY');
      v_assured_contact_info.address       := v_row.val_22;
      v_assured_contact_info.phone_numbers := v_row.val_23;
    
      /* Собираем параметры договора и дополнительную информацию */
      v_pol_num           := v_row.val_24;
      v_sign_date         := to_date(v_row.val_25, 'DD.MM.YYYY');
      v_start_date        := to_date(v_row.val_26, 'DD.MM.YYYY');
      v_end_date          := trunc(to_date(v_row.val_27, 'DD.MM.YYYY')) + 1 - INTERVAL '1' SECOND;
      v_ins_sum           := to_number(v_row.val_28
                                      ,'FM999999999D99'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_fee               := to_number(v_row.val_29
                                      ,'FM999999999D99'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_fund_brief        := v_row.val_30;
      v_payment_term_name := v_row.val_31;
    
      v_benif_bank := v_row.val_32;
    
      --v_relation_name := v_row.val_33;
      v_bso_number := substr(v_pol_num, 4, 6);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001
                               ,'Не удалось разобрать значения полей файла');
      
    END;
  
    /* Параметры договора из бордеро
    Параметры могут быть не указаны */
    v_payment_terms_id := get_payment_terms_by_desc(par_payment_terms_desc => v_payment_term_name);
    v_fund_id          := get_fund_id_by_brief(par_fund_brief => v_fund_brief);
  
    /* Создаем контакт страхователя */
    create_contact(par_contact_info   => v_insuree_contact_info
                  ,par_contact_id_out => v_insuree_contact_id);
  
    /* Создаем контакт застрахованного */
    create_assured_array(par_assured_info      => v_assured_contact_info
                        ,par_benif_bank_name   => v_benif_bank
                        ,par_assured_array_out => v_assured_array);
    /*
     Капля П.
     КОСТЫЛЬ МОЖНО БУДЕТ УБРАТЬ ПОСЛЕ 20.03.2014!!!
     ВРЕМЕННАЯ МЕРА ЧТОБЫ МОЖНО БЫЛО ЗАГРУЖАТЬ ДОГОВОРЫ КРЕДИТКИ РОЛЬФ!!!
    */
    IF par_product_brief IN ('CR103_3', 'CR103_4', 'CR103_5_Renault')
    THEN
      v_ins_sum := NULL;
    END IF;
    /* Формируем договор */
    pkg_policy.create_universal(par_product_brief      => par_product_brief
                               ,par_ag_num             => par_agent_num
                               ,par_start_date         => v_start_date
                               ,par_insuree_contact_id => v_insuree_contact_id
                               ,par_assured_array      => v_assured_array
                               ,par_end_date           => v_end_date
                               ,par_bso_number         => v_bso_number
                               ,par_base_sum           => v_ins_sum
                               ,par_is_credit          => 0
                               ,par_pol_num            => v_pol_num
                               ,par_confirm_date       => v_start_date
                               ,par_notice_date        => v_start_date
                               ,par_sign_date          => v_sign_date
                               ,par_notice_num         => v_pol_num
                               ,par_payment_term_id    => v_payment_terms_id
                               ,par_fund_id            => v_fund_id
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
  
    /*
     Капля П.
     КОСТЫЛЬ МОЖНО БУДЕТ УБРАТЬ ПОСЛЕ 20.03.2014!!!
     ВРЕМЕННАЯ МЕРА ЧТОБЫ МОЖНО БЫЛО ЗАГРУЖАТЬ ДОГОВОРЫ КРЕДИТКИ РОЛЬФ!!!
    */
    IF par_product_brief IN ('CR103_3', 'CR103_4', 'CR103_5_Renault')
    THEN
      UPDATE p_cover pc
         SET pc.ins_amount = to_number(v_row.val_28
                                      ,'FM999999999D99'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,''')
       WHERE pc.as_asset_id IN
             (SELECT aa.as_asset_id FROM as_asset aa WHERE aa.p_policy_id = v_policy_id);
      pkg_policy.update_policy_sum(p_p_policy_id => v_policy_id);
    END IF;
  
    /* Корректируем договор, чтобы суммаркая премия соответсвовала исходному значению из загрузочнго файла */
    correct_premium(par_policy_id => v_policy_id, par_original_premium => v_fee);
  
    --Чирков /добавлена проверка/308470: FW: Заявка Рольф
    IF par_product_brief NOT IN ('CR103_1'
                                ,'CR103_1.1'
                                ,'CR103_1.2'
                                ,'CR103_1.3'
                                ,'CR103_2'
                                ,'CR103_2.1'
                                ,'CR103_2.2'
                                ,'CR103_2.3')
    THEN
      --/Чирков/ добавляем проверку на премию по ДС/302786: Универсальный загрузчик - расчет преми/
      premium_check(par_policy_id => v_policy_id, par_original_premium => v_fee);
      -- 
    END IF;
  
    UPDATE load_file_rows lf
       SET lf.ure_id     = 282
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg VARCHAR2(4000);
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
        ROLLBACK TO before_load;
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_credit_policy;

  -- Продкуты группы Рольф
  -- Пакет 1
  PROCEDURE load_rolf_cr_1(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_1'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_1;
  PROCEDURE load_rolf_cr_1_1(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_1.1'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_1_1;
  PROCEDURE load_rolf_cr_1_2(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_1.2'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_1_2;
  PROCEDURE load_rolf_cr_1_3(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_1.3'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_1_3;

  --Пакет 2
  PROCEDURE load_rolf_cr_2(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_2'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_2;
  PROCEDURE load_rolf_cr_2_1(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_2.1'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_2_1;
  PROCEDURE load_rolf_cr_2_2(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_2.2'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_2_2;
  PROCEDURE load_rolf_cr_2_3(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_2.3'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_2_3;

  -- Новые продукты
  PROCEDURE load_rolf_cr_3(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_3'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_3;
  PROCEDURE load_rolf_cr_4(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_4'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_4;
  PROCEDURE load_rolf_cr_5(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR103_5_Renault'
                      ,par_agent_num         => '45161');
  END load_rolf_cr_5;

  --Авилон
  PROCEDURE load_avilon_1(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR105_1'
                      ,par_agent_num         => NULL);
  END load_avilon_1;
  PROCEDURE load_avilon_2(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR105_2'
                      ,par_agent_num         => NULL);
  END load_avilon_2;

  -- Автодом
  PROCEDURE load_avtodom_1(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR107_1'
                      ,par_agent_num         => '45155');
  END load_avtodom_1;

  PROCEDURE load_avtodom_2(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR107_2'
                      ,par_agent_num         => '45155');
  END load_avtodom_2;

  -- Авто-С
  PROCEDURE load_avto_s_1(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR108_1'
                      ,par_agent_num         => '44780');
  END load_avto_s_1;

  PROCEDURE load_avto_s_2(par_load_file_rows_id NUMBER) IS
  BEGIN
    load_credit_policy(par_load_file_rows_id => par_load_file_rows_id
                      ,par_product_brief     => 'CR108_2'
                      ,par_agent_num         => '44780');
  END load_avto_s_2;

  /*
    Пиядин А. 287320 Продукт МКБ
    Загрузка договоров по кредитным продуктам МКБ
  */
  PROCEDURE load_mkb(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
  
    TYPE t_policy_info IS RECORD(
       notice_num    p_policy.notice_num%TYPE
      ,notice_date   p_policy.notice_date%TYPE
      ,start_date    p_policy.start_date%TYPE
      ,end_date      p_policy.end_date%TYPE
      ,base_sum      p_policy.base_sum%TYPE
      ,total_premium p_policy.premium%TYPE);
  
    v_contact_info t_contact_info;
    v_contact_id   contact.contact_id%TYPE;
  
    v_policy_info   t_policy_info;
    v_policy_id     p_policy.policy_id%TYPE;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
    v_product_brief t_product.brief%TYPE;
  
    v_bso_series_id  bso_series.bso_series_id%TYPE;
    v_bso_series_num bso_series.series_num%TYPE;
    v_bso_number     bso.num%TYPE;
    v_agent_id       ag_contract_header.agent_id%TYPE;
    v_ag_contract_num CONSTANT ven_ag_contract_header.num%TYPE := '47355';
  
    v_asset_array pkg_asset.t_assured_array;
    v_delta_premium NUMBER;
    v_ins_amount    p_policy.ins_amount%TYPE;
    v_premium       p_policy.premium%TYPE;
  
    PROCEDURE process_row
    (
      par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE
     ,par_contact_info      OUT t_contact_info
     ,par_policy_info       OUT t_policy_info
     ,par_product_brief     OUT VARCHAR2
     ,par_bso_series_num    OUT NUMBER
    ) IS
      v_load_row load_file_rows%ROWTYPE;
    BEGIN
      SELECT *
        INTO v_load_row
        FROM load_file_rows l
       WHERE l.load_file_rows_id = par_load_file_rows_id;
    
      /*      -- Определяем бриф продукта
      CASE v_load_row.val_2
        WHEN 1 THEN
          par_product_brief  := 'CR109_1_1';
          par_bso_series_num := 175;
        WHEN 2 THEN
          par_product_brief  := 'CR109_1_2';
          par_bso_series_num := 175;
        WHEN 3 THEN
          par_product_brief  := 'CR109_1_3';
          par_bso_series_num := 175;
        WHEN 4 THEN
          par_product_brief  := 'CR109_1_4';
          par_bso_series_num := 175;
        WHEN 5 THEN
          par_product_brief  := 'CR109_1_5';
          par_bso_series_num := 175;
        WHEN 6 THEN
          par_product_brief  := 'CR109_1_6';
          par_bso_series_num := 175;
        WHEN 7 THEN
          par_product_brief  := 'CR109_1_7';
          par_bso_series_num := 175;
        WHEN 8 THEN
          par_product_brief  := 'CR109_2_1';
          par_bso_series_num := 176;
        WHEN 9 THEN
          par_product_brief  := 'CR109_2_2';
          par_bso_series_num := 176;
        WHEN 10 THEN
          par_product_brief  := 'CR109_2_3';
          par_bso_series_num := 176;
        WHEN 11 THEN
          par_product_brief  := 'CR109_2_4';
          par_bso_series_num := 176;
        ELSE
          par_product_brief  := 'CR109_1_1';
          par_bso_series_num := 175; -- Продукт и Серия БСО по умолчанию
      END CASE;
      */
      -- Сохраняем инфу по контакту
      par_contact_info.name        := v_load_row.val_3;
      par_contact_info.first_name  := v_load_row.val_4;
      par_contact_info.middle_name := v_load_row.val_5;
      par_contact_info.gender      := v_load_row.val_6;
      par_contact_info.birth_date  := to_date(v_load_row.val_7, 'dd.mm.yyyy');
    
      par_contact_info.pass_ser  := v_load_row.val_8;
      par_contact_info.pass_num  := v_load_row.val_9;
      par_contact_info.pass_who  := v_load_row.val_10;
      par_contact_info.pass_when := to_date(v_load_row.val_11, 'dd.mm.yyyy');
    
      par_contact_info.address := v_load_row.val_12;
    
      -- Сохраняем инфу по полису
      par_policy_info.notice_num    := v_load_row.val_1;
      par_policy_info.start_date    := to_date(v_load_row.val_13, 'dd.mm.yyyy');
      par_policy_info.end_date      := trunc(to_date(v_load_row.val_14, 'dd.mm.yyyy')) + 1 - INTERVAL '1'
                                       SECOND;
      par_policy_info.base_sum      := to_number(v_load_row.val_15
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      par_policy_info.total_premium := to_number(v_load_row.val_16
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      -- Определяем бриф продукта
      IF par_policy_info.start_date < to_date('01.05.2014', 'dd.mm.yyyy')
      THEN
        CASE v_load_row.val_2
          WHEN 1 THEN
            par_product_brief  := 'CR109_1_1';
            par_bso_series_num := 175;
          WHEN 2 THEN
            par_product_brief  := 'CR109_1_2';
            par_bso_series_num := 175;
          WHEN 3 THEN
            par_product_brief  := 'CR109_1_3';
            par_bso_series_num := 175;
          WHEN 4 THEN
            par_product_brief  := 'CR109_1_4';
            par_bso_series_num := 175;
          WHEN 5 THEN
            par_product_brief  := 'CR109_1_5';
            par_bso_series_num := 175;
          WHEN 6 THEN
            par_product_brief  := 'CR109_1_6';
            par_bso_series_num := 175;
          WHEN 7 THEN
            par_product_brief  := 'CR109_1_7';
            par_bso_series_num := 175;
          WHEN 8 THEN
            par_product_brief  := 'CR109_2_1';
            par_bso_series_num := 176;
          WHEN 9 THEN
            par_product_brief  := 'CR109_2_2';
            par_bso_series_num := 176;
          WHEN 10 THEN
            par_product_brief  := 'CR109_2_3';
            par_bso_series_num := 176;
          WHEN 11 THEN
            par_product_brief  := 'CR109_2_4';
            par_bso_series_num := 176;
          ELSE
            par_product_brief  := 'CR109_1_1';
            par_bso_series_num := 175; -- Продукт и Серия БСО по умолчанию
        END CASE;
      ELSE
        -- НОВЫЕ ПРОДУКТЫ С 01.05.2014
        CASE v_load_row.val_2
          WHEN 1 THEN
            par_product_brief  := 'CR109_1.8';
            par_bso_series_num := 175;
          WHEN 2 THEN
            par_product_brief  := 'CR109_1.9';
            par_bso_series_num := 175;
          WHEN 3 THEN
            par_product_brief  := 'CR109_1.10';
            par_bso_series_num := 175;
          WHEN 4 THEN
            par_product_brief  := 'CR109_1.11';
            par_bso_series_num := 175;
          WHEN 5 THEN
            par_product_brief  := 'CR109_1.12';
            par_bso_series_num := 175;
          WHEN 6 THEN
            par_product_brief  := 'CR109_1.13';
            par_bso_series_num := 175;
          WHEN 7 THEN
            par_product_brief  := 'CR109_1.14';
            par_bso_series_num := 175;
          WHEN 8 THEN
            par_product_brief  := 'CR109_2.5';
            par_bso_series_num := 176;
          WHEN 9 THEN
            par_product_brief  := 'CR109_2.6';
            par_bso_series_num := 176;
          WHEN 10 THEN
            par_product_brief  := 'CR109_2.7';
            par_bso_series_num := 176;
          WHEN 11 THEN
            par_product_brief  := 'CR109_2.8';
            par_bso_series_num := 176;
          WHEN 12 THEN
            par_product_brief  := 'CR109_2.9';
            par_bso_series_num := 176;
          WHEN 13 THEN
            par_product_brief  := 'CR109_2.10';
            par_bso_series_num := 176;
          ELSE
            par_product_brief  := 'CR109_1.8';
            par_bso_series_num := 175; -- Продукт и Серия БСО по умолчанию
        END CASE;
      END IF;
    
    END process_row;
  
    FUNCTION create_asset_array
    (
      par_contact_id             contact.contact_id%TYPE
     ,par_benificiary_contact_id contact.contact_id%TYPE
    ) RETURN pkg_asset.t_assured_array IS
      v_assured_rec pkg_asset.t_assured_rec;
      v_benif_rec   pkg_asset.t_beneficiary_rec;
    BEGIN
    
      v_assured_rec.contact_id := par_contact_id;
    
      IF par_benificiary_contact_id IS NOT NULL
      THEN
        v_benif_rec.contact_id          := par_benificiary_contact_id;
        v_benif_rec.relation_name       := 'Банк';
        v_benif_rec.part_value          := 100;
        v_assured_rec.benificiary_array := pkg_asset.t_beneficiary_array(v_benif_rec);
      END IF;
    
      RETURN pkg_asset.t_assured_array(v_assured_rec);
    
    END create_asset_array;
  
    FUNCTION get_agent_id_by_ag_header_num(par_ag_header_num ven_ag_contract_header.num%TYPE)
      RETURN ag_contract_header.agent_id%TYPE IS
      v_agent_id ag_contract_header.agent_id%TYPE;
    BEGIN
      SELECT agent_id INTO v_agent_id FROM ven_ag_contract_header ah WHERE ah.num = par_ag_header_num;
      RETURN v_agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить агента по номеру АД');
      
    END get_agent_id_by_ag_header_num;
  
  BEGIN
    SAVEPOINT before_load;
  
    process_row(par_load_file_rows_id => par_load_file_rows_id
               ,par_contact_info      => v_contact_info
               ,par_policy_info       => v_policy_info
               ,par_product_brief     => v_product_brief
               ,par_bso_series_num    => v_bso_series_num);
  
    create_contact(par_contact_info => v_contact_info, par_contact_id_out => v_contact_id);
  
    v_agent_id := get_agent_id_by_ag_header_num(par_ag_header_num => v_ag_contract_num);
  
    v_asset_array := create_asset_array(par_contact_id             => v_contact_id
                                       ,par_benificiary_contact_id => v_agent_id);
  
    v_bso_series_id := pkg_bso.get_bso_series_id(par_bso_series_num => v_bso_series_num);
  
    v_bso_number := substr(v_policy_info.notice_num, 4, 6);
  
    pkg_policy.create_universal(par_product_brief      => v_product_brief
                               ,par_ag_num             => v_ag_contract_num
                               ,par_start_date         => v_policy_info.start_date
                               ,par_end_date           => v_policy_info.end_date
                               ,par_insuree_contact_id => v_contact_id
                               ,par_assured_array      => v_asset_array
                               ,par_pol_num            => v_policy_info.notice_num
                               ,par_notice_num         => v_policy_info.notice_num
                               ,par_bso_number         => v_bso_number
                               ,par_bso_series_id      => v_bso_series_id
                               ,par_base_sum           => v_policy_info.base_sum
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
  
    --    premium_check(par_policy_id => v_policy_id, par_original_premium => v_policy_info.total_premium);
    IF v_policy_info.start_date < to_date('01.05.2014', 'dd.mm.yyyy')
    THEN
    premium_check(par_policy_id => v_policy_id, par_original_premium => v_policy_info.total_premium);
    ELSE
      premium_check(par_policy_id        => v_policy_id
                   ,par_original_premium => v_policy_info.total_premium
                   ,par_accept_dev       => 0.01);
    
      -- подгоняем к ошибке банка (если она есть)
      SELECT v_policy_info.total_premium - pp.premium
        INTO v_delta_premium
        FROM p_policy pp
       WHERE pp.policy_id = v_policy_id;
    
      IF v_delta_premium <> 0
      THEN
        MERGE INTO p_cover pc
        USING (SELECT p_cover_id
                     ,premium + CASE
                        WHEN row_number() over(ORDER BY prod_line_type_sort_order DESC) = 1 THEN
                         v_delta_premium
                        ELSE
                         0
                      END premium
                 FROM (SELECT pc.p_cover_id
                             ,pc.premium
                             ,plt.sort_order prod_line_type_sort_order
                         FROM as_asset            aa
                             ,p_cover             pc
                             ,t_prod_line_option  plo
                             ,t_product_line      pl
                             ,t_product_line_type plt
                        WHERE aa.p_policy_id = v_policy_id
                          AND aa.as_asset_id = pc.as_asset_id
                          AND pc.t_prod_line_option_id = plo.id
                          AND plo.product_line_id = pl.id
                          AND pl.product_line_type_id = plt.product_line_type_id
                          AND aa.status_hist_id IN
                              (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                          AND pc.status_hist_id IN
                              (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr))) pc2
        ON (pc.p_cover_id = pc2.p_cover_id)
        WHEN MATCHED THEN
          UPDATE
             SET pc.fee                  = pc2.premium
                ,pc.premium              = pc2.premium
                ,pc.is_handchange_amount = 1;
      
        pkg_policy.update_policy_sum(p_p_policy_id => v_policy_id
                                    ,p_premium     => v_premium
                                    ,p_ins_amount  => v_ins_amount);
      END IF;
    END IF;
  
    /* Помечаем договор, как успешно обработанный */
    UPDATE load_file_rows lf
       SET lf.ure_id     = ent.id_by_brief('P_POL_HEADER')
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg load_file_rows.row_comment%TYPE;
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
      
        ROLLBACK TO before_load;
      
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_mkb;

  /*
    Пиядин А. 293800  Продукт Накта
    Загрузка договоров по кредитным продуктам Накта CR113
  */
  PROCEDURE load_nakta_cr113(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
  
    TYPE t_policy_info IS RECORD(
       notice_num    p_policy.notice_num%TYPE
      ,notice_date   p_policy.notice_date%TYPE
      ,start_date    p_policy.start_date%TYPE
      ,end_date      p_policy.end_date%TYPE
      ,base_sum      p_policy.base_sum%TYPE
      ,total_premium p_policy.premium%TYPE);
  
    v_contact_info t_contact_info;
    v_contact_id   contact.contact_id%TYPE;
  
    v_policy_info   t_policy_info;
    v_policy_id     p_policy.policy_id%TYPE;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
    v_product_brief t_product.brief%TYPE;
  
    v_bso_series_id   bso_series.bso_series_id%TYPE;
    v_bso_series_num  bso_series.series_num%TYPE;
    v_bso_number      bso.num%TYPE;
    v_agent_id        ag_contract_header.agent_id%TYPE;
    v_ag_contract_num ven_ag_contract_header.num%TYPE;
  
    v_asset_array pkg_asset.t_assured_array;
  
    PROCEDURE process_row
    (
      par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE
     ,par_contact_info      OUT t_contact_info
     ,par_policy_info       OUT t_policy_info
     ,par_product_brief     OUT VARCHAR2
     ,par_bso_series_num    OUT NUMBER
    ) IS
      v_load_row load_file_rows%ROWTYPE;
    BEGIN
      SELECT *
        INTO v_load_row
        FROM load_file_rows l
       WHERE l.load_file_rows_id = par_load_file_rows_id;
    
      -- Определяем серию БСО
      par_bso_series_num := to_number(substr(v_load_row.val_1, 1, 3));
    
      -- Сохраняем инфу по контакту
      par_contact_info.name        := v_load_row.val_3;
      par_contact_info.first_name  := v_load_row.val_4;
      par_contact_info.middle_name := v_load_row.val_5;
      par_contact_info.gender      := v_load_row.val_6;
      par_contact_info.birth_date  := to_date(v_load_row.val_7, 'dd.mm.yyyy');
    
      par_contact_info.pass_ser  := v_load_row.val_8;
      par_contact_info.pass_num  := v_load_row.val_9;
      par_contact_info.pass_who  := v_load_row.val_10;
      par_contact_info.pass_when := to_date(v_load_row.val_11, 'dd.mm.yyyy');
    
      par_contact_info.address := v_load_row.val_12;
    
      -- Сохраняем инфу по полису
      par_policy_info.notice_num    := v_load_row.val_1;
      par_policy_info.start_date    := to_date(v_load_row.val_13, 'dd.mm.yyyy');
      par_policy_info.end_date      := trunc(to_date(v_load_row.val_14, 'dd.mm.yyyy')) + 1 - INTERVAL '1'
                                       SECOND;
      par_policy_info.base_sum      := to_number(v_load_row.val_15
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      par_policy_info.total_premium := to_number(v_load_row.val_16
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
    
      -- Определяем бриф продукта
      IF par_policy_info.start_date >= to_date('01.06.2014', 'dd.mm.rrrr') /*Старые номера, теперь соответствуют новым продуктам
              Черных М. 02.07.2014*/
      THEN
        CASE v_load_row.val_2
          WHEN 1 THEN
            par_product_brief := 'CR113_2.1';
          WHEN 2 THEN
            par_product_brief := 'CR113_2.3';
          ELSE
            par_product_brief := 'CR113_2.1'; -- Продукт и Серия БСО по умолчанию
        END CASE;
      ELSE
        CASE v_load_row.val_2
          WHEN 1 THEN
            par_product_brief := 'CR113_1_1';
          WHEN 2 THEN
            par_product_brief := 'CR113_1_2';
          WHEN 3 THEN
            par_product_brief := 'CR113_1_3';
          ELSE
            par_product_brief := 'CR113_1.1'; -- Продукт и Серия БСО по умолчанию
        END CASE;
      END IF;
    
    END process_row;
  
    FUNCTION create_asset_array
    (
      par_contact_id             contact.contact_id%TYPE
     ,par_benificiary_contact_id contact.contact_id%TYPE
    ) RETURN pkg_asset.t_assured_array IS
      v_assured_rec pkg_asset.t_assured_rec;
      v_benif_rec   pkg_asset.t_beneficiary_rec;
    BEGIN
    
      v_assured_rec.contact_id := par_contact_id;
    
      IF par_benificiary_contact_id IS NOT NULL
      THEN
        v_benif_rec.contact_id          := par_benificiary_contact_id;
        v_benif_rec.relation_name       := 'Банк';
        v_benif_rec.part_value          := 100;
        v_assured_rec.benificiary_array := pkg_asset.t_beneficiary_array(v_benif_rec);
      END IF;
    
      RETURN pkg_asset.t_assured_array(v_assured_rec);
    
    END create_asset_array;
  
    FUNCTION get_agent_id_by_ag_header_num(par_ag_header_num ven_ag_contract_header.num%TYPE)
      RETURN ag_contract_header.agent_id%TYPE IS
      v_agent_id ag_contract_header.agent_id%TYPE;
    BEGIN
      SELECT agent_id INTO v_agent_id FROM ven_ag_contract_header ah WHERE ah.num = par_ag_header_num;
      RETURN v_agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить агента по номеру АД');
      
    END get_agent_id_by_ag_header_num;
  
  BEGIN
    SAVEPOINT before_load;
  
    process_row(par_load_file_rows_id => par_load_file_rows_id
               ,par_contact_info      => v_contact_info
               ,par_policy_info       => v_policy_info
               ,par_product_brief     => v_product_brief
               ,par_bso_series_num    => v_bso_series_num);
  
    create_contact(par_contact_info => v_contact_info, par_contact_id_out => v_contact_id);
  
    /*
      «НАКТА-Кредит-Запад»   627              -- 48410
      «НАКТА-Кредит-Регионы»  628          -- 48411
      Агенство правовых технологий -  185    -- 47991
      Альянс кредит – 178                    -- 47754
    */
    -- Определяем агента по договору
    CASE v_bso_series_num
      WHEN 178 THEN
        v_ag_contract_num := 47754;
      WHEN 185 THEN
        v_ag_contract_num := 47991;
      WHEN 627 THEN
        v_ag_contract_num := 48410;
      WHEN 628 THEN
        v_ag_contract_num := 48411;
      ELSE
        v_ag_contract_num := 48411;
    END CASE;
    v_agent_id := get_agent_id_by_ag_header_num(par_ag_header_num => v_ag_contract_num);
  
    v_asset_array := create_asset_array(par_contact_id             => v_contact_id
                                       ,par_benificiary_contact_id => v_agent_id);
  
    v_bso_series_id := pkg_bso.get_bso_series_id(par_bso_series_num => v_bso_series_num);
  
    v_bso_number := substr(v_policy_info.notice_num, 4, 6);
  
    pkg_policy.create_universal(par_product_brief      => v_product_brief
                               ,par_ag_num             => v_ag_contract_num
                               ,par_start_date         => v_policy_info.start_date
                               ,par_end_date           => v_policy_info.end_date
                               ,par_insuree_contact_id => v_contact_id
                               ,par_assured_array      => v_asset_array
                               ,par_pol_num            => v_policy_info.notice_num
                               ,par_notice_num         => v_policy_info.notice_num
                               ,par_bso_number         => v_bso_number
                               ,par_bso_series_id      => v_bso_series_id
                               ,par_base_sum           => v_policy_info.base_sum
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
  
    premium_check(par_policy_id => v_policy_id, par_original_premium => v_policy_info.total_premium);
  
    /* Помечаем договор, как успешно обработанный */
    UPDATE load_file_rows lf
       SET lf.ure_id     = ent.id_by_brief('P_POL_HEADER')
          ,lf.uro_id     = v_pol_header_id
          ,lf.is_checked = 1
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен');
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg load_file_rows.row_comment%TYPE;
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
      
        ROLLBACK TO before_load;
      
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_nakta_cr113;

  /*
    Капля П. 332801  Продукт Семейная защита ХКФ
    Проверка договоров по кредитным продуктам Семейная защита для ХКФ
  */
  PROCEDURE check_family_protection_hkf
  (
    par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    TYPE t_policy_info IS RECORD(
       policy_id     p_policy.policy_id%TYPE
      ,pol_header_id p_policy.pol_header_id%TYPE
      ,pol_num       p_policy.pol_num%TYPE
      ,start_date    p_policy.start_date%TYPE
      ,sign_date     p_policy.sign_date%TYPE
      ,end_date      p_policy.end_date%TYPE
      ,period        NUMBER
      ,total_premium NUMBER
      ,ins_amount    NUMBER);
  
    v_insuree_info     t_contact_info;
    v_assured_info     t_contact_info;
    v_benificiary_info t_contact_info;
    v_policy_info      t_policy_info;
    v_benif_record     pkg_asset.t_beneficiary_rec;
  
    PROCEDURE process_row
    (
      par_load_file_rows_id        load_file_rows.load_file_rows_id%TYPE
     ,par_insuree_info_out         OUT t_contact_info
     ,par_assured_info_out         OUT t_contact_info
     ,par_benificiary_info_out     OUT t_contact_info
     ,par_policy_info_out          OUT t_policy_info
     ,par_benificiary_share_out    OUT NUMBER
     ,par_benificiary_relation_out OUT VARCHAR2
    ) IS
      v_row load_file_rows%ROWTYPE;
    BEGIN
      SELECT * INTO v_row FROM load_file_rows l WHERE l.load_file_rows_id = par_load_file_rows_id;
    
      par_policy_info_out.pol_num       := v_row.val_7;
      par_policy_info_out.start_date    := to_date(v_row.val_11, 'yyyy.mm.dd');
      par_policy_info_out.sign_date     := to_date(v_row.val_12, 'yyyy.mm.dd');
      par_policy_info_out.end_date      := to_date(v_row.val_13, 'yyyy.mm.dd');
      par_policy_info_out.period        := to_number(v_row.val_15);
      par_policy_info_out.total_premium := to_number(v_row.val_17);
      par_policy_info_out.ins_amount    := to_number(v_row.val_150);
    
      par_insuree_info_out.name        := v_row.val_40;
      par_insuree_info_out.first_name  := v_row.val_41;
      par_insuree_info_out.middle_name := v_row.val_42;
      par_insuree_info_out.gender      := CASE v_row.val_43
                                            WHEN 1 THEN
                                             'M'
                                            ELSE
                                             'F'
                                          END;
    
      par_insuree_info_out.birth_date            := to_date(v_row.val_44, 'yyyy.mm.dd');
      par_insuree_info_out.pass_ser              := substr(v_row.val_49, 1, 4);
      par_insuree_info_out.pass_num              := substr(v_row.val_49, 5);
      par_insuree_info_out.pass_who              := v_row.val_50;
      par_insuree_info_out.pass_subdivision_code := v_row.val_51;
      par_insuree_info_out.pass_when             := to_date(v_row.val_52, 'yyyy.mm.dd');
    
      par_insuree_info_out.address           := v_row.val_70;
      par_insuree_info_out.phone_numbers     := v_row.val_73;
      par_insuree_info_out.is_public_contact := v_row.val_77;
    
      IF v_row.val_22 = 1
      THEN
        par_assured_info_out := par_insuree_info_out;
      ELSE
        par_assured_info_out.name        := v_row.val_90;
        par_assured_info_out.first_name  := v_row.val_91;
        par_assured_info_out.middle_name := v_row.val_92;
        par_assured_info_out.gender      := CASE v_row.val_95
                                              WHEN 1 THEN
                                               'M'
                                              ELSE
                                               'F'
                                            END;
      
        par_assured_info_out.birth_date            := to_date(v_row.val_96, 'yyyy.mm.dd');
        par_assured_info_out.pass_ser              := substr(v_row.val_103, 1, 4);
        par_assured_info_out.pass_num              := substr(v_row.val_103, 5);
        par_assured_info_out.pass_who              := v_row.val_104;
        par_assured_info_out.pass_subdivision_code := v_row.val_105;
        par_assured_info_out.pass_when             := to_date(v_row.val_106, 'yyyy.mm.dd');
      
        par_assured_info_out.address       := v_row.val_118;
        par_assured_info_out.phone_numbers := v_row.val_121;
      END IF;
    
      par_benificiary_info_out.name        := v_row.val_126;
      par_benificiary_info_out.first_name  := v_row.val_127;
      par_benificiary_info_out.middle_name := v_row.val_128;
      par_benificiary_share_out            := v_row.val_130;
      par_benificiary_relation_out         := v_row.val_131;
    
    END process_row;
  
  BEGIN
  
    process_row(par_load_file_rows_id        => par_load_file_rows_id
               ,par_insuree_info_out         => v_insuree_info
               ,par_assured_info_out         => v_assured_info
               ,par_benificiary_info_out     => v_benificiary_info
               ,par_policy_info_out          => v_policy_info
               ,par_benificiary_share_out    => v_benif_record.part_value
               ,par_benificiary_relation_out => v_benif_record.relation_name);
  
    assert_deprecated(length(TRIM(v_policy_info.pol_num)) != 10
          ,'Длина номера договора должна быть 10 символов');
  
    assert_deprecated(v_policy_info.end_date != ADD_MONTHS(v_policy_info.start_date, 12) - 1
          ,'Разница дат начала и конца действия договора страхования должна быть 1 год - 1 день');
  
    assert_deprecated(v_policy_info.total_premium NOT IN (3000, 5000, 10000)
          ,'Суммарная премия должна быть 3000, 5000 или 10000');
  
    IF v_policy_info.total_premium = 3000
    THEN
      assert_deprecated(v_policy_info.ins_amount != 150000
            ,'Страховая сумма должна быть 150000');
    ELSIF v_policy_info.total_premium = 5000
    THEN
      assert_deprecated(v_policy_info.ins_amount != 250000
            ,'Страховая сумма должна быть 250000');
    ELSIF v_policy_info.total_premium = 10000
    THEN
      assert_deprecated(v_policy_info.ins_amount != 500000
            ,'Страховая сумма должна быть 500000');
    END IF;
  
    assert_deprecated(MONTHS_BETWEEN(v_policy_info.start_date, v_assured_info.birth_date) / 12 >= 65
          ,'Возраст застрахованного на дату начала должен быть меньше 65 лет');
  
    par_status  := pkg_load_file_to_table.get_checked;
    par_comment := NULL;
  
  EXCEPTION
    WHEN OTHERS THEN
      par_status  := pkg_load_file_to_table.get_error;
      par_comment := SQLERRM;
  END check_family_protection_hkf;

  /*
    Капля П. 332801  Продукт Семейная защита ХКФ
    Загрузка договоров по кредитным продуктам Семейная защита для ХКФ
  */
  PROCEDURE load_family_protection_hkf(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
    TYPE t_policy_info IS RECORD(
       policy_id     p_policy.policy_id%TYPE
      ,pol_header_id p_policy.pol_header_id%TYPE
      ,pol_num       p_policy.pol_num%TYPE
      ,start_date    p_policy.start_date%TYPE
      ,sign_date     p_policy.sign_date%TYPE
      ,end_date      p_policy.end_date%TYPE
      ,period        NUMBER
      ,total_premium NUMBER
      ,ins_amount    NUMBER);
    v_insuree_info     t_contact_info;
    v_assured_info     t_contact_info;
    v_benificiary_info t_contact_info;
  
    v_insuree_contact_id contact.contact_id%TYPE;
  
    v_assured_rec  pkg_asset.t_assured_rec;
    v_benif_record pkg_asset.t_beneficiary_rec;
  
    v_bso_series_id bso_series.bso_series_id%TYPE;
    v_bso_number    bso.num%TYPE;
  
    c_agent_num CONSTANT ven_ag_contract_header.num%TYPE := '53936';
  
    v_policy_info t_policy_info;
  
    PROCEDURE process_row
    (
      par_load_file_rows_id        load_file_rows.load_file_rows_id%TYPE
     ,par_insuree_info_out         OUT t_contact_info
     ,par_assured_info_out         OUT t_contact_info
     ,par_benificiary_info_out     OUT t_contact_info
     ,par_policy_info_out          OUT t_policy_info
     ,par_benificiary_share_out    OUT NUMBER
     ,par_benificiary_relation_out OUT VARCHAR2
    ) IS
      v_row load_file_rows%ROWTYPE;
    BEGIN
      SELECT * INTO v_row FROM load_file_rows l WHERE l.load_file_rows_id = par_load_file_rows_id;
    
      par_policy_info_out.pol_num       := v_row.val_7;
      par_policy_info_out.start_date    := to_date(v_row.val_11, 'yyyy.mm.dd');
      par_policy_info_out.sign_date     := to_date(v_row.val_12, 'yyyy.mm.dd');
      par_policy_info_out.end_date      := to_date(v_row.val_13, 'yyyy.mm.dd');
      par_policy_info_out.period        := to_number(v_row.val_15);
      par_policy_info_out.total_premium := to_number(v_row.val_17);
      par_policy_info_out.ins_amount    := to_number(v_row.val_150);
    
      par_insuree_info_out.name        := v_row.val_40;
      par_insuree_info_out.first_name  := v_row.val_41;
      par_insuree_info_out.middle_name := v_row.val_42;
      par_insuree_info_out.gender      := CASE v_row.val_43
                                            WHEN 1 THEN
                                             'M'
                                            ELSE
                                             'F'
                                          END;
    
      par_insuree_info_out.birth_date            := to_date(v_row.val_44, 'yyyy.mm.dd');
      par_insuree_info_out.pass_ser              := substr(v_row.val_49, 1, 4);
      par_insuree_info_out.pass_num              := substr(v_row.val_49, 5);
      par_insuree_info_out.pass_who              := v_row.val_50;
      par_insuree_info_out.pass_subdivision_code := v_row.val_51;
      par_insuree_info_out.pass_when             := to_date(v_row.val_52, 'yyyy.mm.dd');
    
      par_insuree_info_out.address           := v_row.val_70;
      par_insuree_info_out.phone_numbers     := v_row.val_73;
      par_insuree_info_out.is_public_contact := v_row.val_77;
    
      IF v_row.val_22 = 1
      THEN
        par_assured_info_out := par_insuree_info_out;
      ELSE
        par_assured_info_out.name        := v_row.val_90;
        par_assured_info_out.first_name  := v_row.val_91;
        par_assured_info_out.middle_name := v_row.val_92;
        par_assured_info_out.gender      := CASE v_row.val_95
                                              WHEN 1 THEN
                                               'M'
                                              ELSE
                                               'F'
                                            END;
      
        par_assured_info_out.birth_date            := to_date(v_row.val_96, 'yyyy.mm.dd');
        par_assured_info_out.pass_ser              := substr(v_row.val_103, 1, 4);
        par_assured_info_out.pass_num              := substr(v_row.val_103, 5);
        par_assured_info_out.pass_who              := v_row.val_104;
        par_assured_info_out.pass_subdivision_code := v_row.val_105;
        par_assured_info_out.pass_when             := to_date(v_row.val_106, 'yyyy.mm.dd');
      
        par_assured_info_out.address       := v_row.val_118;
        par_assured_info_out.phone_numbers := v_row.val_121;
      END IF;
    
      par_benificiary_info_out.name        := v_row.val_126;
      par_benificiary_info_out.first_name  := v_row.val_127;
      par_benificiary_info_out.middle_name := v_row.val_128;
      par_benificiary_share_out            := v_row.val_130;
      par_benificiary_relation_out         := v_row.val_131;
    
    END process_row;
  
  BEGIN
    SAVEPOINT before_load;
  
    process_row(par_load_file_rows_id        => par_load_file_rows_id
               ,par_insuree_info_out         => v_insuree_info
               ,par_assured_info_out         => v_assured_info
               ,par_benificiary_info_out     => v_benificiary_info
               ,par_policy_info_out          => v_policy_info
               ,par_benificiary_share_out    => v_benif_record.part_value
               ,par_benificiary_relation_out => v_benif_record.relation_name);
  
    v_bso_series_id := pkg_bso.get_bso_series_id(par_bso_series_num => substr(v_policy_info.pol_num
                                                                             ,1
                                                                             ,3));
    v_bso_number    := substr(v_policy_info.pol_num, 4, 6);
  
    create_contact(par_contact_info => v_insuree_info, par_contact_id_out => v_insuree_contact_id);
    create_contact(par_contact_info => v_assured_info, par_contact_id_out => v_assured_rec.contact_id);
  
    IF v_benificiary_info.name IS NOT NULL
    THEN
      create_contact(par_contact_info   => v_benificiary_info
                    ,par_contact_id_out => v_benif_record.contact_id);
      v_assured_rec.benificiary_array := pkg_asset.t_beneficiary_array(v_benif_record);
    END IF;
  
    pkg_policy.create_universal(par_product_brief      => 'FAMILY_PROTECTION_BANK'
                               ,par_ag_num             => c_agent_num
                               ,par_start_date         => v_policy_info.start_date
                               ,par_insuree_contact_id => v_insuree_contact_id
                               ,par_assured_array      => pkg_asset.t_assured_array(v_assured_rec)
                               ,par_end_date           => v_policy_info.end_date
                               ,par_bso_number         => v_bso_number
                               ,par_bso_series_id      => v_bso_series_id
                               ,par_base_sum           => v_policy_info.ins_amount
                               ,par_sign_date          => v_policy_info.sign_date
                               ,par_payment_term_id    => dml_t_payment_terms.get_id_by_brief('Единовременно')
                               ,par_policy_header_id   => v_policy_info.pol_header_id
                               ,par_policy_id          => v_policy_info.policy_id);
  
    premium_check(par_policy_id        => v_policy_info.policy_id
                 ,par_original_premium => v_policy_info.total_premium);
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => 'Договор добавлен'
                                         ,par_ure_id            => 282
                                         ,par_uro_id            => v_policy_info.pol_header_id
                                         ,par_is_checked        => pkg_load_file_to_table.get_checked);
  
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_error_msg load_file_rows.row_comment%TYPE;
      BEGIN
        v_error_msg := 'Ошибка при импорте: ' || SQLERRM;
      
        ROLLBACK TO before_load;
      
        UPDATE load_file_rows lf
           SET lf.is_checked = 0
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_msg);
      END;
  END load_family_protection_hkf;

END pkg_load_policies; 
/
