CREATE OR REPLACE PACKAGE pkg_contact IS
  /*
  * Работа с сущностью Контакт - создание физлица, адреса, поиск телефона, индекса, склонение ФИО и т.д.
  * @author Процветов Е.
  * @version 1
  * @headcom
  */

  /*
  * Код ошибки - найдено несколько контактов
  * @author vustinov
  */
  errc_plural_contacts INTEGER := -20901;

  /*
  * Обьявление внутренних типов
  * используется в функции get_essential_list
  * @author Сизон С.
  */
  TYPE v_company_info_row IS RECORD(
     company_type      VARCHAR2(50)
    ,company_name      VARCHAR2(300)
    ,kpp               VARCHAR2(50)
    ,inn               VARCHAR2(50)
    ,bik               VARCHAR2(50)
    ,bank_name         VARCHAR2(300)
    ,account_number    VARCHAR2(30)
    ,account_corr      VARCHAR2(30)
    ,b_kor_account     VARCHAR2(50)
    ,b_bic             VARCHAR2(50)
    ,b_okpo            VARCHAR2(50)
    ,b_ogrn            VARCHAR2(50)
    ,legal_address     VARCHAR2(300)
    ,fact_address      VARCHAR2(300)
    ,postal_address    VARCHAR2(300)
    ,phone             VARCHAR2(50)
    ,fax               VARCHAR2(50)
    ,licence_number    VARCHAR2(50)
    ,licence_date      DATE
    ,chief_name        VARCHAR(300)
    ,bank_company_type VARCHAR2(50));

  /**/
  TYPE t_check_change IS TABLE OF ven_cn_contact_bank_acc%ROWTYPE INDEX BY PLS_INTEGER;
  v_check_change t_check_change;
  /**/

  TYPE v_company_info_table IS TABLE OF v_company_info_row;
  /*
  Проверка корректности лицевого счета
  30.09.2014 Черных М.
  -- %param par_lic_code  Номер лицевого счета
  */
  FUNCTION is_lic_code_correct(par_lic_code cn_contact_bank_acc.lic_code%TYPE) RETURN BOOLEAN;
  /*
  Проверка корректности расчетного счета
  30.09.2014 Черных М.
  -- %param par_account_nr  Номер расчетного счета
  */
  FUNCTION is_account_nr_correct(par_account_nr cn_contact_bank_acc.account_nr%TYPE) RETURN BOOLEAN;
  /*
  Капля П.
  Функции добавления связи между контактами
  */
  PROCEDURE add_contacts_relation
  (
    par_contact_a_id   contact.contact_id%TYPE
   ,par_contact_b_id   contact.contact_id%TYPE
   ,par_rel_type_id    t_contact_rel_type.id%TYPE
   ,par_remark         cn_contact_rel.remarks%TYPE DEFAULT NULL
   ,par_is_disabled    cn_contact_rel.is_disabled%TYPE DEFAULT 0
   ,par_contact_rel_id OUT cn_contact_rel.id%TYPE
  );

  PROCEDURE add_contacts_relation
  (
    par_contact_a_id   contact.contact_id%TYPE
   ,par_contact_b_id   contact.contact_id%TYPE
   ,par_rel_type_brief t_contact_rel_type.brief%TYPE
   ,par_remark         cn_contact_rel.remarks%TYPE DEFAULT NULL
   ,par_is_disabled    cn_contact_rel.is_disabled%TYPE DEFAULT 0
   ,par_contact_rel_id OUT cn_contact_rel.id%TYPE
  );

  PROCEDURE add_contacts_relation
  (
    par_contact_a_id   contact.contact_id%TYPE
   ,par_contact_b_id   contact.contact_id%TYPE
   ,par_rel_type_brief t_contact_rel_type.brief%TYPE
   ,par_remark         cn_contact_rel.remarks%TYPE DEFAULT NULL
   ,par_is_disabled    cn_contact_rel.is_disabled%TYPE DEFAULT 0
  );

  /**
  * Функция возвращает адрес в виде строки
  * @author Процветов Е.
  * @param p_id Идентификатор (ID) записи в таблице CN_ADDRESS
  * @return Строка адреса
  */
  FUNCTION get_address_name(p_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает адрес в виде строки
  * @author Процветов Е.
  * @param v_adr v_cn_address Параметр типа "запись", содержащий данные конкретной записи из таблицы CN_ADDRESS
  * @return Строка адреса
  */
  FUNCTION get_address_name(v_adr v_cn_address%ROWTYPE) RETURN VARCHAR2;

  /**
  * Функция возвращает адрес в виде строки
  * @author Процветов Е.
  * @param zip Индекс
  * @param country_name Наименование объекта сущности Страна
  * @param region_name Наименование объекта сущности Район
  * @param region_type_name Наименование типа объекта сущности Район
  * @param province_name Наименование объекта сущности Область
  * @param province_type_name Наименование типа объекта сущности Область
  * @param district_type_name Наименование типа объекта сущности Населённый Пункт
  * @param district_name Наименование объекта сущности Населённый Пункт
  * @param city_type_name Наименование типа объекта сущности Город
  * @param city_name Наименование объекта сущности Город
  * @param street_name Наименование объекта сущности Улица
  * @param street_type_name Наименование типа объекта сущности Улица
  * @param building_name Наименование типа объекта сущности Строение
  * @param house_nr Номер дома
  * @param block_number Номер блока
  * @param box_number Номер бокса
  * @param appartment_nr Номер аппартаментов
  * @return Строка адреса
  */
  FUNCTION get_address_name
  (
    zip                VARCHAR2
   ,country_name       VARCHAR2
   ,region_name        VARCHAR2
   ,region_type_name   VARCHAR2
   ,province_name      VARCHAR2
   ,province_type_name VARCHAR2
   ,district_type_name VARCHAR2
   ,district_name      VARCHAR2
   ,city_type_name     VARCHAR2
   ,city_name          VARCHAR2
   ,street_name        VARCHAR2
   ,street_type_name   VARCHAR2
   ,building_name      VARCHAR2
   ,house_nr           VARCHAR2
   ,block_number       VARCHAR2
   ,box_number         VARCHAR2
   ,appartment_nr      VARCHAR2
   ,house_type         VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Процедура добавляет в таблицы CN_ADDRESS (Адрес) и CN_CONTACT_ADDRESS (Адрес Контакта) новые записи
  * @author Процветов Е.
  * @param a_id ID объекта сущности Адрес Контакта
  * @param addr_id ID объекта сущности Адрес
  * @param contact_id ID объекта сущности Контакт
  * @param a_country_id ID объекта сущности Страна
  * @param a_province_id ID объекта сущности Область
  * @param a_province_name Наименование объекта сущности Область
  * @param a_region_id ID объекта сущности Район
  * @param a_region_name Наименование объекта сущности Район
  * @param a_city_id ID объекта сущности Город
  * @param a_city_name Наименование объекта сущности Город
  * @param a_district_id ID объекта сущности Населённый Пункт
  * @param a_district_name Наименование объекта сущности Населённый Пункт
  * @param a_district_type_id ID объекта сущности Тип Населённого Пункта
  * @param a_street_id ID объекта сущности Улица
  * @param a_street_name Наименование объекта сущности Улица
  * @param a_zip Индекс
  * @param a_house_nr Номер дома
  * @param a_block_nr Номер блока
  * @param a_appartment_nr Номер аппартаментов
  * @param a_addr_type ID объекта сущности Тип Адреса
  * @param a_is_default Адрес по умолчанию
  */
  PROCEDURE contact_addr_insert
  (
    a_id                  NUMBER
   ,addr_id               NUMBER
   ,contact_id            NUMBER
   ,a_country_id          NUMBER
   ,a_province_type       VARCHAR2
   ,a_province_name       VARCHAR2
   ,a_region_type         VARCHAR2
   ,a_region_name         VARCHAR2
   ,a_city_type           VARCHAR2
   ,a_city_name           VARCHAR2
   ,a_district_type       VARCHAR2
   ,a_district_name       VARCHAR2
   ,a_street_type         VARCHAR2
   ,a_street_name         VARCHAR2
   ,a_zip                 VARCHAR2
   ,a_house_nr            VARCHAR2
   ,a_block_nr            VARCHAR2
   ,a_appartment_nr       VARCHAR2
   ,a_addr_type           NUMBER
   ,a_is_default          NUMBER DEFAULT 1
   ,a_region_code         VARCHAR2
   ,a_house_type          VARCHAR2
   ,a_actual              NUMBER
   ,a_actual_date         DATE
   ,a_decompos_permis     NUMBER
   ,a_code_kladr_province VARCHAR2
   ,a_code_kladr_region   VARCHAR2
   ,a_code_kladr_city     VARCHAR2
   ,a_code_kladr_distr    VARCHAR2
   ,a_code_kladr_street   VARCHAR2
   ,a_code_kladr_doma     VARCHAR2
   ,a_index_province      VARCHAR2
   ,a_index_region        VARCHAR2
   ,a_index_city          VARCHAR2
   ,a_index_distr         VARCHAR2
   ,a_index_street        VARCHAR2
   ,a_index_doma          VARCHAR2
   ,a_code                VARCHAR2
   ,par_status            NUMBER
  );

  /**
  * Процедура обновляет данные в конкретных записях таблиц CN_ADDRESS (Адрес) и CN_CONTACT_ADDRESS (Адрес Контакта)
  * @author Процветов Е.
  * @param a_id ID объекта сущности Адрес Контакта
  * @param addr_id ID объекта сущности Адрес
  * @param a_country_id ID объекта сущности Страна
  * @param a_province_id ID объекта сущности Область
  * @param a_province_name Наименование объекта сущности Область
  * @param a_region_id ID объекта сущности Район
  * @param a_region_name Наименование объекта сущности Район
  * @param a_city_id ID объекта сущности Город
  * @param a_city_name Наименование объекта сущности Город
  * @param a_district_id ID объекта сущности Населённый Пункт
  * @param a_district_name Наименование объекта сущности Населённый Пункт
  * @param a_district_type_id ID объекта сущности Тип Населённого Пункта
  * @param a_street_id ID объекта сущности Улица
  * @param a_street_name Наименование объекта сущности Улица
  * @param a_zip Индекс
  * @param a_house_nr Номер дома
  * @param a_block_nr Номер блока
  * @param a_appartment_nr Номер аппартаментов
  * @param a_addr_type ID объекта сущности Тип Адреса
  * @param a_is_default Адрес по умолчанию
  */
  PROCEDURE contact_addr_update
  (
    a_id                  NUMBER
   ,addr_id               NUMBER
   ,a_country_id          NUMBER
   ,a_province_type       VARCHAR2
   ,a_province_name       VARCHAR2
   ,a_region_type         VARCHAR2
   ,a_region_name         VARCHAR2
   ,a_city_type           VARCHAR2
   ,a_city_name           VARCHAR2
   ,a_district_type       VARCHAR2
   ,a_district_name       VARCHAR2
   ,a_street_type         VARCHAR2
   ,a_street_name         VARCHAR2
   ,a_zip                 VARCHAR2
   ,a_house_nr            VARCHAR2
   ,a_block_nr            VARCHAR2
   ,a_appartment_nr       VARCHAR2
   ,a_addr_type           NUMBER
   ,a_is_default          NUMBER DEFAULT 1
   ,a_region_code         VARCHAR2
   ,a_house_type          VARCHAR2
   ,a_actual              NUMBER
   ,a_actual_date         DATE
   ,a_decompos_permis     NUMBER
   ,a_code_kladr_province VARCHAR2
   ,a_code_kladr_region   VARCHAR2
   ,a_code_kladr_city     VARCHAR2
   ,a_code_kladr_distr    VARCHAR2
   ,a_code_kladr_street   VARCHAR2
   ,a_code_kladr_doma     VARCHAR2
   ,a_index_province      VARCHAR2
   ,a_index_region        VARCHAR2
   ,a_index_city          VARCHAR2
   ,a_index_distr         VARCHAR2
   ,a_index_street        VARCHAR2
   ,a_index_doma          VARCHAR2
   ,a_code                VARCHAR2
   ,par_status            NUMBER
  );

  /**
  * Процедура удаляет из таблицы CN_CONTACT_ADDRESS (Адрес Контакта) конкретную запись
  * @author Процветов Е.
  * @param a_id ID объекта сущности Адрес Контакта
  */
  PROCEDURE contact_addr_del(a_id NUMBER);

  /**
  * Процедура блокирует возможность редактирования конкретных записей в таблицах CN_ADDRESS (Адрес) и CN_CONTACT_ADDRESS (Адрес Контакта)
  * @author Процветов Е.
  * @param a_id ID объекта сущности Адрес
  * @param ca_id ID объекта сущности Адрес Контакта
  */
  PROCEDURE contact_addr_lock
  (
    a_id  NUMBER
   ,ca_id NUMBER
  );

  /**
  * Получить адрес идентификации контакта в системе
  * @author Иванов Д.
  * @param p_cn_contact_id ид контакта
  * @return ИД адреса индентификации контакта
  */
  FUNCTION get_primary_address(p_cn_contact_id NUMBER) RETURN NUMBER;

  /**
  * Получить объект сущности Адрес по Типу Адреса
  * @author Кущенко С.
  * @param p_cn_contact_id ID Контакта
  * @param p_brief Код BRIEF объекта сущности Тап Адреса
  * @return ID объекта сущности Адрес
  */
  FUNCTION get_address_by_brief
  (
    p_cn_contact_id NUMBER
   ,p_brief         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Функция возвращает реквизиты организации,
  * включая реквизиты банка,
  * используемые в "шапках" договоров
  * @author Сизон С.
  * @param p_contact_id ID Контакта
  * @return реквизиты организации в виде таблицы (аналог v_company_info)
  */
  FUNCTION get_essential_list(p_contact_id IN NUMBER) RETURN v_company_info_table
    PIPELINED;

  /**
  * Функция возвращает реквизиты организации
  * @author Будкова А.
  * @param p_contact_id ID Контакта
  * @return реквизиты организации
  */
  FUNCTION get_essential(p_contact_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает реквизиты банка
  * @author Будкова А.
  * @param p_contact_id ID Контакта
  * @return Реквизиты банка
  */
  FUNCTION get_bank_essential(p_contact_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает телефонный номер или список телефонных номеров
  * @author Будкова А.
  * @param par_contact_id ID Контакта
  * @param phone_type_name Наименование объекта сущности Тип Телефона
  * @return Строка, содержащая телефонные номера с разделителем ","
  */
  FUNCTION get_contact_telephones
  (
    par_contact_id  VARCHAR
   ,phone_type_name VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR;

  /**
  * Функция возвращает телефонный номер по его ID
  * @author Будкова А.
  * @param p_id ID объекта сущности Телефоны Контакта
  * @return Строка, содержащая телефонный номер
  */
  FUNCTION get_telephone(p_id cn_contact_telephone.id%TYPE) RETURN VARCHAR2;

  /**
  * Функция возвращает одну из частей ФИО:
  * <br> 1 - Фамилия,
  * <br> 2 - Имя
  * <br> 3 - Отчество
  * <br> 4 - Фамилия И. О.
  * <br> 5 - И. О. Фамилия
  * <br> 6 - Имя Отчество Фамилия
  * @author Noname
  * @param str Строка, содержащая Фамилию Имя Отчество
  * @param num Тип результата функции
  * @return Строка, содержащая телефонный номер
  */
  FUNCTION get_fio_fmt
  (
    str VARCHAR2
   ,num NUMBER
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает начальную букву пола М/Ж или пустую строку
  * @author Noname
  * @param p_middle_name Отчество
  * @return Строка, содержащая букву пола М/Ж
  */
  FUNCTION get_sex_char(p_middle_name IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Функция возвращает ID пола контакта (T_GENDER.GENDER_ID)
  * @author Kushenko S.
  * @param p_contact_id ИД контакта
  * @return ID пола контакта
  */
  FUNCTION get_sex_id(p_contact_id IN NUMBER) RETURN NUMBER;

  /**
  Функция позвращает ID пола по различным вариантам брифа
  @author Капля П.
  @param brief - Бриф для расшифровки
  @return ID пола
  */
  FUNCTION get_gender_id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER;
  /**
  * Функция возвращает склонённое ФИО
  * @author Noname
  * @param p_fio_str ID Контакта
  * @param p_case Начальная буква падежа
  * @return Строка, содержащая склонённое ФИО
  */
  FUNCTION get_fio_case
  (
    p_fio_str IN NUMBER
   ,p_case    IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает склонённое ФИО
  * @author Noname
  * @param p_fio_str Строка вида Фамилия Имя Отчество
  * @param p_case Начальная буква падежа
  * @return Строка, содержащая склонённое ФИО
  */
  FUNCTION get_fio_case
  (
    p_fio_str IN VARCHAR2
   ,p_case    IN VARCHAR2
   ,p_seq     IN VARCHAR2 DEFAULT NULL
   ,p_sex     IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /* 
  Капля П.
  Получаем ИД типа связи между контактами, возвращает null если связи нет.
   */
  FUNCTION get_rel_type_between_contacts
  (
    par_contact_a_id contact.contact_id%TYPE
   ,par_contact_b_id contact.contact_id%TYPE
  ) RETURN cn_contact_rel.relationship_type%TYPE;

  /**
  * Функция возращает имя связанного контакта
  * @autor Кущенко С.
  * @param p_contact_id ID Контакта,
  * @param p_rel_type Тип связи ('GM' - Генеральный деректор,'CM' - Главный врач)
  * @return ID связанного контакта
  */
  FUNCTION get_rel_contact_id
  (
    p_contact_id NUMBER
   ,p_rel_type   ven_t_contact_rel_type.brief%TYPE
  ) RETURN NUMBER;
  /**
  * Функция возращает описание связи двух контактов
  * Кем приходится p_contact_id_b по отношению к p_contact_id_a
  * @autor Кущенко С.
  * @param p_contact_id_a ID Контакта
  * @param p_contact_id_b ID Контакта
  * @return связь двух контактов (t_contact_rel_type.relationship_dsc)
  */
  FUNCTION get_rel_description
  (
    p_contact_id_a IN NUMBER
   ,p_contact_id_b IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает Примечание для связи двух контактов
  * @autor Процветов Е.
  * @param p_contact_id_a ID Контакта
  * @param p_contact_id_b ID Контакта
  * @param p_rel_brief Код связи
  * @return Примечание
  */
  FUNCTION get_rel_note
  (
    p_contact_id_a IN NUMBER
   ,p_contact_id_b IN NUMBER
   ,p_rel_brief    ven_t_contact_rel_type.brief%TYPE
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает наименование региона Адреса.
  * <br> Функция возвращает город, если не задана область, край, республика.
  * <br> Если не заданы ни город, ни область, край, республика, то возвращается страна
  * @author Иванов Д.
  * @param p_cn_address_id ID объекта сущности Адрес
  * @return Строка, содержащая наименование объекта сущности Адрес
  */
  FUNCTION get_address_region(p_cn_address_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возращает данные о документе идентифицирующем физическое лицо: Возвращает докуметн с
  * <br> наивысшим T_ID_TYPE.SORT_ORDER
  * @autor Хомич А.
  * @param p_contact_id ID Контакта
  * @return Строка информации о документе
  */
  FUNCTION get_primary_doc(p_contact_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция возращает данные о документе идентифицирующем физическое лицо
  * <br> формат вывода отличается от get_primary_doc
  * @autor В.Устинов.
  * @param p_contact_id ID Контакта
  * @return Строка информации о документе
  */
  FUNCTION get_primary_doc_2(p_contact_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция позвращает документ по типу по контакту
  * @author Капля П.
  * @param par_contact_id ID контакта
  * @return Номер документа
  */
  FUNCTION get_contact_ident_doc_by_type
  (
    par_contact_id           contact.contact_id%TYPE
   ,par_ident_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.id_value%TYPE;

  /**
  * Функция возращает контактный телефон. Возвращается телефон с наивысшим T_TELEPHONE_TYPE.SORT_ORDER
  * @autor Хомич А.
  * @param p_contact_id ID Контакта
  * @return Строка, содержащая телефонный номер
  */
  FUNCTION get_primary_tel(p_contact_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает признак, что контакт - физическое лицо
  * @author Капля П.
  * @param par_contact_id ID Контакта
  * @return 1 - физлицо, 0 - юрлицо
  */
  FUNCTION get_is_individual(par_contact_id contact.contact_id%TYPE)
    RETURN t_contact_type.is_individual%TYPE;

  /**
  * Процедура проверяет соответствие введённого значения установленной маске
  * @author Процветов Е.
  * @param p_value Введённое значение
  * @param m_value Установленная маска
  * @param p_result Результат выполнения 0/1 - ошибка/успех
  * @param p_err_txt Текст сообщения об ошибке
  */
  PROCEDURE validate_from_mask
  (
    p_value   IN VARCHAR2
   ,p_mask    IN VARCHAR2
   ,p_result  OUT NUMBER
   ,p_err_txt OUT VARCHAR2
  );

  /**
  * Функция проверяет уникальность введённых данных по контакту
  * @author Процветов Е.
  * @param p_contact_id ИД контакта
  * @param p_is_individual статус ИП
  * @param p_name Фамилия/Наименование
  * @param p_first_name Имя
  * @param p_middle_name Отчество
  * @param p_date_of_birth Дата рождения
  * @param p_id_value Номер ИНН
  * @return Статус уникальности: 1 - уникальный, 0 - данные уже имеются в БД
  */
  FUNCTION is_unique_contact
  (
    p_contact_id    IN NUMBER
   ,p_is_individual IN NUMBER
   ,p_resident_flag IN NUMBER
   ,p_name          IN VARCHAR2
   ,p_first_name    IN VARCHAR2
   ,p_middle_name   IN VARCHAR2
   ,p_date_of_birth IN DATE
   ,p_id_value      IN VARCHAR2
  ) RETURN NUMBER;

  /**
  * Процедура проверяет возможность удаления Контакта
  * @author Процветов Е.
  * @param p_contact_id ID контакта
  * @param p_res Результат выполнения 0/1 - не готов/готов
  * @param p_mess Сообщение содержащее таблицы, в которых есть записи связанные с текущим контактом
  */
  PROCEDURE prepare_for_delete
  (
    p_contact_id IN NUMBER
   ,p_res        OUT NUMBER
   ,p_mess       OUT VARCHAR2
  );

  /**
  * Функция возвращающая код КЛАДР для Контакта
  * @author Процветов Е.
  * @param p_contact_id ИД контакта
  * @return Код КЛАДР
  */
  FUNCTION get_contact_kladr(p_contact_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращающая Индекс
  * @author Процветов Е.
  * @param p_contact_id ИД контакта
  * @return Индекс
  */
  FUNCTION get_primary_zip(p_contact_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращающая 'ЮЛ' или 'ФЛ' в зависимости от типа контакта
  * @author Кущенко С.
  * @param p_contact_id ИД контакта
  * @return Возвращает сокращённый код (BRIEF) объекта сущности Тип Контакта
  */
  FUNCTION get_brief_contact_type_prior(p_contact_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращающая Индекс
  * @author Noname
  * @param par_address ИД объекта сущности Адрес
  * @return Индекс
  */
  FUNCTION get_index(par_address IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращающая Код КЛАДР
  * @author Процветов Е.
  * @param par_address ИД объекта сущности Адрес
  * @return Строка Кода КЛАДР
  */
  FUNCTION get_kladr(par_address IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращающая дату Идентификатора контакта
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @param p_id_type_brief Brief Идентификатора
  * @return Дата идентификатора
  */
  FUNCTION get_ident_date
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN DATE;

  /**
  * Функция возвращающая номер Идентификатора контакта
  * @author Процветов Е.
  * @param p_contact_id ID Контакта
  * @param p_id_type_brief Brief Идентификатора
  * @return Строка номера Идентификатора
  */
  FUNCTION get_ident_number
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает место выдачи Идентификатора контакта
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @param p_id_type_brief Brief Идентификатора
  * @return место выдачи Идентификатора контакта
  */
  FUNCTION get_ident_place
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN VARCHAR2;
  /**
  * Функция возвращающая серию Идентификатора контакта
  * @author Процветов Е.
  * @param p_contact_id ИД контакта
  * @param p_id_type_brief Brief Идентификатора
  * @return Строка серии Идентификатора
  */
  FUNCTION get_ident_seria
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает день рождения контакта
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @return Дата рождения Контакта
  */
  FUNCTION get_birth_date(p_contact_id IN NUMBER) RETURN DATE;

  /**
  * Функция возвращает форматированный телефон контакта по типу телефона
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @param p_telephone_type_brief BRIEF типа Телефона
  * @return форматированный номер телефона
  */
  FUNCTION get_phone_number
  (
    p_contact_id           NUMBER
   ,p_telephone_type_brief t_telephone_type.brief%TYPE
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает гражданство контакта
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @return Строка гражданства Контакта
  */
  FUNCTION get_citizenry(p_contact_id NUMBER) RETURN VARCHAR2;
  /**
  * Функция возвращает профессию контакта
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @return Профессия контакта (T_PROFESSION.DESCRIPTION)
  */

  FUNCTION get_profession(p_contact_id NUMBER) RETURN VARCHAR2;
  /**
  * Функция стаж контакта
  * @author Кущенко С.
  * @param p_contact_id ID Контакта
  * @return Стаж котакта (год заполенный в CN_PERSON или год выдачи вод. Удостов)
  */

  FUNCTION get_standing(p_contact_id NUMBER) RETURN NUMBER;
  /**
  * Функция ищет физлицо по ФИО и паспортным данным
  * @author Капля П.
  * @param p_first_name Фамилия
  * @param p_middle_name Имя
  * @param p_last_name Отчество
  * @param p_birth_date Дата рождения
  * @param p_gender Пол
  * @param p_pass_ser Серия документа, удостоверяющего личность
  * @param p_pass_num Номер документа, удостоверяющего личность
  * @param p_pass_issue_date Дата выдачи документа, удостоверяющего личность
  * @param p_pass_issued_by Кем выдан документ, удостоверяющий личность
  * @return ID объекта сущности Физическое Лицо
  */
  FUNCTION find_person_contact
  (
    p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_last_name       VARCHAR2
   ,p_birth_date      DATE
   ,p_pass_ser        VARCHAR2 DEFAULT NULL
   ,p_pass_num        VARCHAR2 DEFAULT NULL
   ,p_pass_issue_date DATE DEFAULT NULL
   ,p_pass_issued_by  VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;
  /**
  * Функция создаёт новое Физлицо или же обновляет данные по существующему
  * @author Noname
  * @param p_first_name Фамилия
  * @param p_middle_name Имя
  * @param p_last_name Отчество
  * @param p_birth_date Дата рождения
  * @param p_gender Пол
  * @param p_pass_ser Серия документа, удостоверяющего личность
  * @param p_pass_num Номер документа, удостоверяющего личность
  * @param p_pass_issue_date Дата выдачи документа, удостоверяющего личность
  * @param p_pass_issued_by Кем выдан документ, удостоверяющий личность
  * @param p_country_id ID страны, выдавшей документ
  * @param p_note   Комментарий
  * @return ID объекта сущности Физическое Лицо
  */
  FUNCTION create_person_contact
  (
    p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_last_name       VARCHAR2
   ,p_birth_date      DATE
   ,p_gender          VARCHAR2
   ,p_pass_ser        VARCHAR2 DEFAULT NULL
   ,p_pass_num        VARCHAR2 DEFAULT NULL
   ,p_pass_issue_date DATE DEFAULT NULL
   ,p_pass_issued_by  VARCHAR2 DEFAULT NULL
   ,p_country_id      NUMBER DEFAULT NULL
   ,p_note            VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;
  /**
  * Проверка есть ли соответствующая роль у контакта, добавляемого в качестве контакта по полису
  * и добавление роли если ее нет
  * @author Ф.Ганичев
  * @param p_contact_id - Id контакта
  * @param p_role_id - Id роли по полису
  * @param p_pass_issued_by Кем выдан документ, удостоверяющий личность
  */
  PROCEDURE check_add_contact_role
  (
    p_contact_id NUMBER
   ,p_role_id    NUMBER
  );

  /**
  * Проверка есть ли соответствующая роль у контакта добавление роли если ее нет
  * @author Чикашова
  * @param p_contact_id - Id контакта
  * @param p_role_brief - Brief роли
  */
  PROCEDURE check_contact_role
  (
    p_contact_id NUMBER
   ,p_role_brief VARCHAR2
  );

  /**
  * Проверка есть ли роль "Агент" у контакта,
  * добавление роли "Агент" если ее нет
  * @author Shidlovskaya
  * @param p_contact_id - Id контакта
  */
  PROCEDURE check_add_agent_role(p_contact_id NUMBER);

  /**
  * Функция вывода всех реквизитов контакта через запятую для печатных форм
  * @author Protsvetov E.
  * @param p_contact_id ID Контакта
  * @param p_inn ИНН
  * @param p_okpo ОКПО
  * @param p_kpp КПП
  * @param p_okfs ОКФС
  * @param p_okopf ОКОПФ
  * @param p_okato ОКАТО
  * @param p_okogu ОКОГУ
  * @param p_okved ОКВЭД
  * @param p_rs Р/с
  * @param p_ks К/с
  * @param p_bik БИК
  * @return строка реквизитами
  */
  FUNCTION get_rekv
  (
    p_contact_id NUMBER
   ,p_inn        NUMBER DEFAULT 1
   ,p_okpo       NUMBER DEFAULT 1
   ,p_kpp        NUMBER DEFAULT 1
   ,p_okfs       NUMBER DEFAULT 1
   ,p_okopf      NUMBER DEFAULT 1
   ,p_okato      NUMBER DEFAULT 1
   ,p_okogu      NUMBER DEFAULT 1
   ,p_okved      NUMBER DEFAULT 1
   ,p_rs         NUMBER DEFAULT 1
   ,p_ks         NUMBER DEFAULT 1
   ,p_bik        NUMBER DEFAULT 1
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает emale контакта
  * @author Protsvetov E.
  * @param p_contact_id ID Контакта
  * @return emale
  */
  FUNCTION get_emales(p_contact_id NUMBER) RETURN VARCHAR2;

  /**
  * Функция возвращает все контактные телефоны контакта
  * @author Protsvetov E.
  * @param p_contact_id ID Контакта
  * @return телефоны
  */
  FUNCTION get_phones(p_contact_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_post
  (
    p_contact_id NUMBER
   ,p_padezh     VARCHAR2
  ) RETURN VARCHAR2;

  v_issuer_contact_role_id  NUMBER;
  v_benef_contact_role_id   NUMBER;
  v_assured_contact_role_id NUMBER;

  v_issuer_contact_pol_role_id  NUMBER;
  v_benef_contact_pol_role_id   NUMBER;
  v_assured_contact_pol_role_id NUMBER;
  FUNCTION check_department
  (
    p_contact_id NUMBER
   ,p_policy_id  NUMBER
   ,p_dep_id     NUMBER
  ) RETURN NUMBER;

  /**
  *Порядок расчета контрольного ключа в номере лицевого счета
  *12.08.2011
  * Веселуха
  */
  FUNCTION check_control_account
  (
    p_bank_contact_id NUMBER
   ,p_num_account     VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION check_control_inn(p_num_inn VARCHAR2) RETURN VARCHAR2;
  FUNCTION check_control_snils(p_num_snils VARCHAR2) RETURN VARCHAR2;
  /*
    Байтин А.
    Осуществление проверок расчетного счета
  
    Возвращает два параметра:
    par_can_continue: true - можно продолжать с выводом предупреждения в случае наличия сообщения, false - нельзя продолжать
    par_error_message - сообщение, в случае ошибки
  */
  PROCEDURE check_account_nr
  (
    par_account_nr    VARCHAR2
   ,par_bank_id       NUMBER
   ,par_can_continue  OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  );

  /*
    Байтин А.
    
    Проверка расчетного счета по методике для РКЦ
  */
  PROCEDURE check_account_nr_rkc
  (
    par_account       VARCHAR2
   ,par_bik           VARCHAR2
   ,par_can_continue  OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  );
  /*
    Байтин А.
    Добавление расчетного счета
  */
  PROCEDURE insert_account_nr
  (
    par_account_corr             VARCHAR2
   ,par_account_nr               VARCHAR2
   ,par_bank_account_currency_id NUMBER
   ,par_bank_approval_date       DATE
   ,par_bank_approval_end_date   DATE
   ,par_bank_approval_reference  VARCHAR2
   ,par_bank_id                  NUMBER
   ,par_bank_name                VARCHAR2
   ,par_bic_code                 VARCHAR2
   ,par_branch_id                NUMBER
   ,par_branch_name              VARCHAR2
   ,par_contact_id               NUMBER
   ,par_country_id               NUMBER
   ,par_iban_reference           VARCHAR2
   ,par_is_check_owner           NUMBER
   ,par_lic_code                 VARCHAR2
   ,par_order_number             NUMBER
   ,par_owner_contact_id         NUMBER
   ,par_remarks                  VARCHAR2
   ,par_swift_code               VARCHAR2
   ,par_used_flag                NUMBER
   ,par_cn_contact_bank_acc_id   IN OUT NUMBER
   ,par_cn_document_bank_acc_id  OUT NUMBER
  );
  FUNCTION check_control_corr
  (
    p_bank_bik    VARCHAR2
   ,p_num_account VARCHAR2
  ) RETURN VARCHAR2;
  PROCEDURE cancel_check_owner(p_doc_id NUMBER);
  PROCEDURE set_role_contact(p_document_id NUMBER);
  FUNCTION get_telephone_number
  (
    par_contact_id NUMBER
   ,par_type_tel   NUMBER
  ) RETURN VARCHAR2;
  FUNCTION get_telephone_state
  (
    par_contact_id NUMBER
   ,par_type_tel   NUMBER
  ) RETURN VARCHAR2;
  FUNCTION get_ltrs_address(p_cn_contact_id NUMBER) RETURN NUMBER;
  --FUNCTION SET_GET_HISTORY(p_contact_id NUMBER, p_set_get NUMBER DEFAULT 1) RETURN t_check_change;

  /* Функция возвращает id дополинтельного документа по контакту
  * @Autor Чирков В. Ю.
  * @param p_contact_id - id контакта
  * @param p_doc_type_brief - тип документа
  */
  FUNCTION get_contact_document_id
  (
    p_contact_id     NUMBER
   ,p_doc_type_brief VARCHAR2
  ) RETURN NUMBER;

  /* Функция возвращает id банковского документа по контакту
  * @Autor Чирков В. Ю.
  * @param par_contact_id - id контакта
  */
  FUNCTION get_primary_banc_acc(par_contact_id NUMBER) RETURN NUMBER;
  /*
    Байтин А.
    
    Добавление телефона контакту
  */
  FUNCTION insert_phone
  (
    par_contact_id          NUMBER
   ,par_telephone_type      NUMBER
   ,par_telephone_number    VARCHAR2
   ,par_telephone_prefix    VARCHAR2 DEFAULT NULL
   ,par_country_id          NUMBER DEFAULT 1
   ,par_telephone_extension VARCHAR2 DEFAULT NULL
   ,par_remarks             VARCHAR2 DEFAULT NULL
   ,par_telephone_prefix_id NUMBER DEFAULT NULL
   ,par_control             NUMBER DEFAULT 0
   ,par_status              NUMBER DEFAULT 1
   ,par_field_count         NUMBER DEFAULT 0
   ,par_is_temp             NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /*
    Байтин А.
    
    Перегруженный вариант, без использования ID и с проверками
  */
  FUNCTION insert_phone
  (
    par_contact_id          NUMBER
   ,par_telephone_type      VARCHAR2
   ,par_telephone_number    VARCHAR2
   ,par_telephone_prefix    VARCHAR2 DEFAULT NULL
   ,par_country             VARCHAR2 DEFAULT 'Россия'
   ,par_telephone_extension VARCHAR2 DEFAULT NULL
   ,par_remarks             VARCHAR2 DEFAULT NULL
   ,par_telephone_prefix_id NUMBER DEFAULT NULL
   ,par_control             NUMBER DEFAULT 0
   ,par_status              NUMBER DEFAULT 1
   ,par_field_count         NUMBER DEFAULT 0
   ,par_is_temp             NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /*
    Байтин А.
    
    Добавление телефона контакту
  */
  FUNCTION insert_email
  (
    par_contact_id  NUMBER
   ,par_email       VARCHAR2
   ,par_email_type  NUMBER
   ,par_field_count NUMBER DEFAULT 1
   ,par_status      NUMBER DEFAULT 0
   ,par_is_temp     NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /*
    Байтин А.
    
    Перегруженный вариант, без использования ID и с проверками
  */
  FUNCTION insert_email
  (
    par_contact_id  NUMBER
   ,par_email       VARCHAR2
   ,par_email_type  VARCHAR2
   ,par_field_count NUMBER DEFAULT 1
   ,par_status      NUMBER DEFAULT 0
   ,par_is_temp     NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE set_contact_contacts
  (
    par_contact_id        NUMBER
   ,par_address           VARCHAR2
   ,par_contact_telephone VARCHAR2 DEFAULT NULL
   ,par_country_id        NUMBER DEFAULT NULL
  );

  FUNCTION create_person_contact_rlu
  (
    p_last_name       VARCHAR2
   ,p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_birth_date      DATE
   ,p_gender          VARCHAR2
   ,p_pass_ser        VARCHAR2 DEFAULT NULL
   ,p_pass_num        VARCHAR2 DEFAULT NULL
   ,p_pass_issue_date DATE DEFAULT NULL
   ,p_pass_issued_by  VARCHAR2 DEFAULT NULL
   ,p_address         VARCHAR2 DEFAULT NULL
   ,p_contact_phone   VARCHAR2 DEFAULT NULL
   ,p_country_id      NUMBER DEFAULT NULL
   ,p_note            VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  /*
  Капля П.С.
  Процедура добавления адреса к контакту
  */
  PROCEDURE insert_address
  (
    p_contact_id         NUMBER
   ,p_address            VARCHAR2
   ,p_address_type_brief VARCHAR2 DEFAULT 'DOMADD'
   ,p_country_id         NUMBER DEFAULT NULL
   ,p_is_default         NUMBER DEFAULT 1
   ,p_is_temp            NUMBER DEFAULT NULL
  );

  /*
  Капля П.С.
  Процедура создания Юр. Лица
  Модифицирована 10.04.2013 Веселуха Е.
  par_risk_level        VARCHAR2 DEFAULT Средний уровень риска = 2
  Добавлен par_contact_type_id Тип контакта, DEFAULT Юр лицо = 101
  */
  FUNCTION create_company
  (
    par_name              VARCHAR2
   ,par_short_name        VARCHAR2 DEFAULT NULL
   ,par_risk_level        VARCHAR2 DEFAULT 2
   ,par_resident_flag     NUMBER DEFAULT 1
   ,par_web_site          VARCHAR2 DEFAULT NULL
   ,par_dms_lpu_gl_fio    VARCHAR2 DEFAULT NULL -- ФИО руководителя
   ,par_company_status_id NUMBER DEFAULT NULL
   ,par_contact_type_id   NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /*
      Создание идентифицирующего документа
      Веселуха Е. 10.04.2013
  */
  FUNCTION create_ident_document
  (
    par_contact_id       NUMBER
   ,par_ident_type_id    NUMBER
   ,par_value            VARCHAR2
   ,par_series           VARCHAR2 DEFAULT NULL
   ,par_issue_date       DATE DEFAULT NULL
   ,par_issue_place      VARCHAR2 DEFAULT NULL
   ,par_is_default       NUMBER DEFAULT 0
   ,par_termination_date DATE DEFAULT NULL
   ,par_is_used          NUMBER DEFAULT 1
   ,par_subdivision_code VARCHAR2 DEFAULT NULL
   ,par_country_id       NUMBER DEFAULT NULL
   ,par_is_temp          NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /*
      Поиск идентифицирующего документа
      Капля П. 05.08.2013
  */
  FUNCTION find_ident_document
  (
    par_contact_id    NUMBER
   ,par_ident_type_id NUMBER
   ,par_value         VARCHAR2
   ,par_series        VARCHAR2 DEFAULT NULL
   ,par_issue_date    DATE DEFAULT NULL
  ) RETURN NUMBER;

  /*
    @author Байтин А.
  
    Получение имени контакта по ID
    @param par_contact_id - ИД контакта
    @param par_raise_on_error - TRUE: возвращать ошибку; FALSE: нет
  
    @return Имя контакта
  */
  FUNCTION get_contact_name_by_id
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN contact.obj_name_orig%TYPE;

  /*
    Капля П.
    Получение возраста контакта на указанную дату
    Возраст - число полных лет на дату. Если возраст менее одного года, 
    то возвращается дробное число с округлением в сторону нуля (trunc) до сотых долей 
    
    @param paR_contact_id - ИД контакта
    @param par_date - Дата, на которую нужно получить возраст
  */
  FUNCTION get_age_by_date
  (
    par_contact_id contact.contact_id%TYPE
   ,par_date       DATE
  ) RETURN NUMBER;

  /*
    Мизинов Г.В.
    Проверка использования указанного логина другими контактами. Возвращает false,
    если таких контактов нет и true, если логин уже кем-либо используется
    @param paR_contact_id - ИД контакта
    @param par_login - искомый логин
  */
  FUNCTION check_lk_login_exists
  (
    par_contact_id ins.contact.contact_id%TYPE
   ,par_login      ins.contact.profile_login%TYPE
  ) RETURN BOOLEAN;

END pkg_contact;
/
CREATE OR REPLACE PACKAGE BODY pkg_contact IS

  /*
  Проверка корректности лицевого счета
  30.09.2014 Черных М.
  -- %param par_lic_code  Номер лицевого счета
  */
  FUNCTION is_lic_code_correct(par_lic_code cn_contact_bank_acc.lic_code%TYPE) RETURN BOOLEAN IS
  BEGIN
    /*
    Допустимы 20 цифр, 20 цифр/еще символы (примеры: 12345678901234567890, 12345678901234567890/20
    12345678901234567890/ - недопустим
    */
    RETURN regexp_like(par_lic_code, '(^\d{20}$)|(^\d{20}\/.+$)');
  END is_lic_code_correct;

  /*
  Проверка корректности расчетного счета
  30.09.2014 Черных М.
  -- %param par_account_nr  Номер расчетного счета
  */
  FUNCTION is_account_nr_correct(par_account_nr cn_contact_bank_acc.account_nr%TYPE) RETURN BOOLEAN IS
  BEGIN
    /*
    Допустимы 20 цифр, 20 цифр/еще символы (примеры: 12345678901234567890, 12345678901234567890/20
    12345678901234567890/ - недопустим
    */
    RETURN regexp_like(par_account_nr, '(^\d{20}$)|(^\d{20}\/.+$)');
  END is_account_nr_correct;

  PROCEDURE add_contacts_relation
  (
    par_contact_a_id   contact.contact_id%TYPE
   ,par_contact_b_id   contact.contact_id%TYPE
   ,par_rel_type_id    t_contact_rel_type.id%TYPE
   ,par_remark         cn_contact_rel.remarks%TYPE DEFAULT NULL
   ,par_is_disabled    cn_contact_rel.is_disabled%TYPE DEFAULT 0
   ,par_contact_rel_id OUT cn_contact_rel.id%TYPE
  ) IS
  BEGIN
    assert_deprecated(par_contact_a_id IS NULL OR par_contact_b_id IS NULL
          ,'Контакт для связи не может быть пустым');
    assert_deprecated(par_rel_type_id IS NULL
          ,'Тип связи контактов не может быть пустым');
  
    SELECT sq_cn_contact_rel.nextval INTO par_contact_rel_id FROM dual;
  
    INSERT INTO ven_cn_contact_rel
      (id, contact_id_a, contact_id_b, relationship_type, remarks, is_disabled)
    VALUES
      (par_contact_rel_id
      ,par_contact_a_id
      ,par_contact_b_id
      ,par_rel_type_id
      ,par_remark
      ,par_is_disabled);
  
  EXCEPTION
    WHEN dup_val_on_index THEN
      DECLARE
        v_contact_a_name contact.obj_name_orig%TYPE;
        v_contact_b_name contact.obj_name_orig%TYPE;
      BEGIN
        SELECT c1.obj_name_orig
              ,c2.obj_name_orig
          INTO v_contact_a_name
              ,v_contact_b_name
          FROM contact c1
              ,contact c2
         WHERE c1.contact_id = par_contact_a_id
           AND c2.contact_id = par_contact_b_id;
        raise_application_error(-20001
                               ,'Для контактов ' || v_contact_a_name || ' и ' || v_contact_b_name ||
                                'уже есть связь.');
      END;
  END add_contacts_relation;

  PROCEDURE add_contacts_relation
  (
    par_contact_a_id   contact.contact_id%TYPE
   ,par_contact_b_id   contact.contact_id%TYPE
   ,par_rel_type_brief t_contact_rel_type.brief%TYPE
   ,par_remark         cn_contact_rel.remarks%TYPE DEFAULT NULL
   ,par_is_disabled    cn_contact_rel.is_disabled%TYPE DEFAULT 0
   ,par_contact_rel_id OUT cn_contact_rel.id%TYPE
  ) IS
    v_rel_type_id t_contact_rel_type.id%TYPE;
  BEGIN
    assert_deprecated(par_rel_type_brief IS NULL, 'Бриф типа связи не может быть NULL');
  
    BEGIN
      SELECT id INTO v_rel_type_id FROM t_contact_rel_type crt WHERE crt.brief = par_rel_type_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить тип связи контактов по брифу ' ||
                                par_rel_type_brief);
    END;
  
    add_contacts_relation(par_contact_a_id   => par_contact_a_id
                         ,par_contact_b_id   => par_contact_b_id
                         ,par_rel_type_id    => v_rel_type_id
                         ,par_remark         => par_remark
                         ,par_is_disabled    => par_is_disabled
                         ,par_contact_rel_id => par_contact_rel_id);
  END add_contacts_relation;

  PROCEDURE add_contacts_relation
  (
    par_contact_a_id   contact.contact_id%TYPE
   ,par_contact_b_id   contact.contact_id%TYPE
   ,par_rel_type_brief t_contact_rel_type.brief%TYPE
   ,par_remark         cn_contact_rel.remarks%TYPE DEFAULT NULL
   ,par_is_disabled    cn_contact_rel.is_disabled%TYPE DEFAULT 0
  ) IS
    v_contact_rel_id cn_contact_rel.id%TYPE;
  BEGIN
    add_contacts_relation(par_contact_a_id   => par_contact_a_id
                         ,par_contact_b_id   => par_contact_b_id
                         ,par_rel_type_brief => par_rel_type_brief
                         ,par_remark         => par_remark
                         ,par_is_disabled    => par_is_disabled
                         ,par_contact_rel_id => v_contact_rel_id);
  END add_contacts_relation;

  FUNCTION get_address_name
  (
    zip                VARCHAR2
   ,country_name       VARCHAR2
   ,region_name        VARCHAR2
   ,region_type_name   VARCHAR2
   ,province_name      VARCHAR2
   ,province_type_name VARCHAR2
   ,district_type_name VARCHAR2
   ,district_name      VARCHAR2
   ,city_type_name     VARCHAR2
   ,city_name          VARCHAR2
   ,street_name        VARCHAR2
   ,street_type_name   VARCHAR2
   ,building_name      VARCHAR2
   ,house_nr           VARCHAR2
   ,block_number       VARCHAR2
   ,box_number         VARCHAR2
   ,appartment_nr      VARCHAR2
   ,house_type         VARCHAR2
  ) RETURN VARCHAR2 IS
    ret_val VARCHAR2(4000);
  BEGIN
  
    IF province_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      IF province_type_name IS NOT NULL
      THEN
        IF province_type_name = 'г'
        THEN
          ret_val := ret_val || province_type_name || '. ' || province_name;
        ELSE
          ret_val := ret_val || province_name || ' ' || province_type_name || '.';
        END IF;
      ELSE
        ret_val := ret_val || province_name;
      END IF;
      ret_val := ret_val || ',';
    END IF;
  
    IF region_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      IF region_type_name IS NOT NULL
      THEN
        ret_val := ret_val || region_type_name || '. ';
      END IF;
      ret_val := ret_val || region_name || ',';
    END IF;
  
    IF district_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      IF district_type_name IS NOT NULL
      THEN
        ret_val := ret_val || district_type_name || '. ';
      END IF;
      ret_val := ret_val || district_name || ',';
    END IF;
  
    IF city_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      IF city_type_name IS NOT NULL
      THEN
        ret_val := ret_val || city_type_name || '. ';
      END IF;
      ret_val := ret_val || city_name || ',';
    END IF;
  
    IF street_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      IF street_type_name IS NOT NULL
      THEN
        ret_val := ret_val || street_type_name || '. ';
      END IF;
      ret_val := ret_val || street_name || ',';
    END IF;
  
    IF house_nr IS NOT NULL
    THEN
      ret_val := ret_val || ' д.' || house_nr || ',';
    END IF;
  
    IF block_number IS NOT NULL
    THEN
      ret_val := ret_val || ' ' || block_number || ',';
    END IF;
  
    IF appartment_nr IS NOT NULL
    THEN
      ret_val := ret_val || ' кв./оф.' || appartment_nr || ',';
    END IF;
  
    ret_val := rtrim(ret_val, ',');
  
    IF ret_val IS NOT NULL
    THEN
      ret_val := country_name || ', ' || ltrim(ret_val);
      IF zip IS NOT NULL
      THEN
        ret_val := zip || ', ' || ret_val;
      END IF;
    END IF;
  
    RETURN ret_val;
  END;

  FUNCTION get_address_name(v_adr v_cn_address%ROWTYPE) RETURN VARCHAR2 IS
    district_type_name_short VARCHAR(10);
    region_type_name_short   VARCHAR(10);
  BEGIN
    /*IF v_adr.district_type_id IS NOT NULL THEN
      BEGIN
        SELECT DESCRIPTION_SHORT
          INTO district_type_name_short
          FROM t_district_type
         WHERE t_district_type.district_type_id = v_adr.district_type_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN NULL;
      END;
    END IF;
    
    IF v_adr.region_id IS NOT NULL THEN
       BEGIN
        SELECT DESCRIPTION_SHORT
          INTO region_type_name_short
          FROM t_region,t_region_type
         WHERE t_region.region_id = v_adr.region_id
           AND t_region_type.REGION_TYPE_ID=t_region.REGION_TYPE_ID;
       EXCEPTION
        WHEN NO_DATA_FOUND
        THEN NULL;
       END;
    END IF;*/
  
    RETURN nvl(get_address_name(v_adr.zip
                               ,v_adr.country_name
                               ,v_adr.region_name
                               ,v_adr.region_type
                               ,v_adr.province_name
                               ,v_adr.province_type
                               ,v_adr.district_type
                               ,v_adr.district_name
                               ,v_adr.city_type
                               ,v_adr.city_name
                               ,v_adr.street_name
                               ,v_adr.street_type
                               ,v_adr.building_name
                               ,v_adr.house_nr
                               ,v_adr.block_number
                               ,v_adr.box_number
                               ,v_adr.appartment_nr
                               ,v_adr.house_type)
              ,v_adr.name);
  END;
  FUNCTION get_address_name(p_id NUMBER) RETURN VARCHAR2 IS
    v_adr v_cn_address%ROWTYPE;
  BEGIN
    BEGIN
      SELECT v.* INTO v_adr FROM v_cn_address v WHERE v.id = p_id;
      RETURN get_address_name(v_adr);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END;

  /**/
  PROCEDURE contact_addr_insert
  (
    a_id                  NUMBER
   ,addr_id               NUMBER
   ,contact_id            NUMBER
   ,a_country_id          NUMBER
   ,a_province_type       VARCHAR2
   ,a_province_name       VARCHAR2
   ,a_region_type         VARCHAR2
   ,a_region_name         VARCHAR2
   ,a_city_type           VARCHAR2
   ,a_city_name           VARCHAR2
   ,a_district_type       VARCHAR2
   ,a_district_name       VARCHAR2
   ,a_street_type         VARCHAR2
   ,a_street_name         VARCHAR2
   ,a_zip                 VARCHAR2
   ,a_house_nr            VARCHAR2
   ,a_block_nr            VARCHAR2
   ,a_appartment_nr       VARCHAR2
   ,a_addr_type           NUMBER
   ,a_is_default          NUMBER DEFAULT 1
   ,a_region_code         VARCHAR2
   ,a_house_type          VARCHAR2
   ,a_actual              NUMBER
   ,a_actual_date         DATE
   ,a_decompos_permis     NUMBER
   ,a_code_kladr_province VARCHAR2
   ,a_code_kladr_region   VARCHAR2
   ,a_code_kladr_city     VARCHAR2
   ,a_code_kladr_distr    VARCHAR2
   ,a_code_kladr_street   VARCHAR2
   ,a_code_kladr_doma     VARCHAR2
   ,a_index_province      VARCHAR2
   ,a_index_region        VARCHAR2
   ,a_index_city          VARCHAR2
   ,a_index_distr         VARCHAR2
   ,a_index_street        VARCHAR2
   ,a_index_doma          VARCHAR2
   ,a_code                VARCHAR2
   ,par_status            NUMBER
  ) IS
  
  BEGIN
    INSERT INTO cn_address
      (id
      ,country_id
      ,province_type
      ,province_name
      ,region_type
      ,region_name
      ,city_type
      ,city_name
      ,district_type
      ,district_name
      ,street_type
      ,street_name
      ,zip
      ,house_nr
      ,block_number
      ,appartment_nr
      ,region_code
      ,house_type
      ,actual
      ,actual_date
      ,decompos_permis
      ,code_kladr_province
      ,code_kladr_region
      ,code_kladr_city
      ,code_kladr_distr
      ,code_kladr_street
      ,code_kladr_doma
      ,index_province
      ,index_region
      ,index_city
      ,index_distr
      ,index_street
      ,index_doma
      ,code
      ,NAME)
    VALUES
      (addr_id
      ,a_country_id
      ,a_province_type
      ,a_province_name
      ,a_region_type
      ,a_region_name
      ,a_city_type
      ,a_city_name
      ,a_district_type
      ,a_district_name
      ,a_street_type
      ,a_street_name
      ,a_zip
      ,a_house_nr
      ,a_block_nr
      ,a_appartment_nr
      ,a_region_code
      ,a_house_type
      ,a_actual
      ,a_actual_date
      ,a_decompos_permis
      ,a_code_kladr_province
      ,a_code_kladr_region
      ,a_code_kladr_city
      ,a_code_kladr_distr
      ,a_code_kladr_street
      ,a_code_kladr_doma
      ,a_index_province
      ,a_index_region
      ,a_index_city
      ,a_index_distr
      ,a_index_street
      ,a_index_doma
      ,a_code
      ,ins.pkg_contact.get_address_name(a_zip
                                       ,(SELECT tc.description
                                          FROM ins.t_country tc
                                         WHERE tc.id = a_country_id)
                                       ,a_region_name
                                       ,a_region_type
                                       ,a_province_name
                                       ,a_province_type
                                       ,a_district_type
                                       ,a_district_name
                                       ,a_city_type
                                       ,a_city_name
                                       ,a_street_name
                                       ,a_street_type
                                       ,NULL
                                       ,a_house_nr
                                       ,a_block_nr
                                       ,NULL
                                       ,a_appartment_nr
                                       ,a_house_type));
    INSERT INTO cn_contact_address
      (id, adress_id, contact_id, address_type, is_default)
    VALUES
      (a_id, addr_id, contact_id, a_addr_type, a_is_default);
  END;
  /**/

  /*  PROCEDURE contact_addr_insert(a_id               NUMBER,
                                  addr_id            NUMBER,
                                  contact_id         NUMBER,
                                  a_country_id       NUMBER,
                                  a_province_id      NUMBER,
                                  a_province_name    VARCHAR2,
                                  a_region_id        NUMBER,
                                  a_region_name      VARCHAR2,
                                  a_city_id          NUMBER,
                                  a_city_name        VARCHAR2,
                                  a_district_id      NUMBER,
                                  a_district_name    VARCHAR2,
                                  a_district_type_id NUMBER,
                                  a_street_id        NUMBER,
                                  a_street_name      VARCHAR2,
                                  a_zip              VARCHAR2,
                                  a_house_nr         VARCHAR2,
                                  a_block_nr         VARCHAR2,
                                  a_appartment_nr    VARCHAR2,
                                  a_addr_type        NUMBER,
                                  a_is_default       NUMBER DEFAULT 1,
                                  a_region_code      VARCHAR2
                                  -- Байтин А. Заявка 184819
                                 ,par_status         number) IS
  
    BEGIN
      INSERT INTO cn_address
        (ID,
         country_id,
         province_id,
         province_name,
         region_id,
         region_name,
         city_id,
         city_name,
         district_id,
         district_name,
         district_type_id,
         street_id,
         street_name,
         zip,
         house_nr,
         block_number,
         appartment_nr,
         region_code)
      VALUES
        (addr_id,
         a_country_id,
         a_province_id,
         a_province_name,
         a_region_id,
         a_region_name,
         a_city_id,
         a_city_name,
         a_district_id,
         a_district_name,
         a_district_type_id,
         a_street_id,
         a_street_name,
         a_zip,
         a_house_nr,
         a_block_nr,
         a_appartment_nr,
         a_region_code);
      INSERT INTO cn_contact_address
        (ID, adress_id, contact_id, address_type, is_default, status)
      VALUES
        (a_id, addr_id, contact_id, a_addr_type, a_is_default, par_status);
    END;
  */
  PROCEDURE contact_addr_update
  (
    a_id                  NUMBER
   ,addr_id               NUMBER
   ,a_country_id          NUMBER
   ,a_province_type       VARCHAR2
   ,a_province_name       VARCHAR2
   ,a_region_type         VARCHAR2
   ,a_region_name         VARCHAR2
   ,a_city_type           VARCHAR2
   ,a_city_name           VARCHAR2
   ,a_district_type       VARCHAR2
   ,a_district_name       VARCHAR2
   ,a_street_type         VARCHAR2
   ,a_street_name         VARCHAR2
   ,a_zip                 VARCHAR2
   ,a_house_nr            VARCHAR2
   ,a_block_nr            VARCHAR2
   ,a_appartment_nr       VARCHAR2
   ,a_addr_type           NUMBER
   ,a_is_default          NUMBER DEFAULT 1
   ,a_region_code         VARCHAR2
   ,a_house_type          VARCHAR2
   ,a_actual              NUMBER
   ,a_actual_date         DATE
   ,a_decompos_permis     NUMBER
   ,a_code_kladr_province VARCHAR2
   ,a_code_kladr_region   VARCHAR2
   ,a_code_kladr_city     VARCHAR2
   ,a_code_kladr_distr    VARCHAR2
   ,a_code_kladr_street   VARCHAR2
   ,a_code_kladr_doma     VARCHAR2
   ,a_index_province      VARCHAR2
   ,a_index_region        VARCHAR2
   ,a_index_city          VARCHAR2
   ,a_index_distr         VARCHAR2
   ,a_index_street        VARCHAR2
   ,a_index_doma          VARCHAR2
   ,a_code                VARCHAR2
   ,par_status            NUMBER
  ) IS
  BEGIN
    UPDATE cn_contact_address
       SET (address_type, status) =
           (SELECT a_addr_type
                  ,par_status
              FROM dual)
     WHERE cn_contact_address.id = a_id;
  
    UPDATE cn_contact_address cca
       SET (cca.address_type, cca.status) =
           (SELECT ta.id
                  ,par_status
              FROM t_address_type ta
             WHERE ta.brief LIKE a_addr_type || '%Фактический по КЛАДР%')
     WHERE EXISTS (SELECT NULL
              FROM ins.cn_address caa
             WHERE caa.parent_addr_id = addr_id
               AND caa.id = cca.adress_id);
    UPDATE cn_address
       SET (country_id
          ,province_type
          ,province_name
          ,region_type
          ,region_name
          ,city_type
          ,city_name
          ,district_type
          ,district_name
          ,street_type
          ,street_name
          ,zip
          ,house_nr
          ,block_number
          ,appartment_nr
          ,region_code
          ,house_type
          ,actual
          ,actual_date
          ,decompos_permis
          ,code_kladr_province
          ,code_kladr_region
          ,code_kladr_city
          ,code_kladr_distr
          ,code_kladr_street
          ,code_kladr_doma
          ,index_province
          ,index_region
          ,index_city
          ,index_distr
          ,index_street
          ,index_doma
          ,code
          ,NAME) =
           (SELECT a_country_id
                  ,a_province_type
                  ,a_province_name
                  ,a_region_type
                  ,a_region_name
                  ,a_city_type
                  ,a_city_name
                  ,a_district_type
                  ,a_district_name
                  ,a_street_type
                  ,a_street_name
                  ,a_zip
                  ,a_house_nr
                  ,a_block_nr
                  ,a_appartment_nr
                  ,a_region_code
                  ,a_house_type
                  ,a_actual
                  ,a_actual_date
                  ,a_decompos_permis
                  ,a_code_kladr_province
                  ,a_code_kladr_region
                  ,a_code_kladr_city
                  ,a_code_kladr_distr
                  ,a_code_kladr_street
                  ,a_code_kladr_doma
                  ,a_index_province
                  ,a_index_region
                  ,a_index_city
                  ,a_index_distr
                  ,a_index_street
                  ,a_index_doma
                  ,a_code
                  ,ins.pkg_contact.get_address_name(a_zip
                                                   ,(SELECT tc.description
                                                      FROM ins.t_country tc
                                                     WHERE tc.id = a_country_id)
                                                   ,a_region_name
                                                   ,a_region_type
                                                   ,a_province_name
                                                   ,a_province_type
                                                   ,a_district_type
                                                   ,a_district_name
                                                   ,a_city_type
                                                   ,a_city_name
                                                   ,a_street_name
                                                   ,a_street_type
                                                   ,NULL
                                                   ,a_house_nr
                                                   ,a_block_nr
                                                   ,NULL
                                                   ,a_appartment_nr
                                                   ,a_house_type)
              FROM dual)
     WHERE cn_address.id = addr_id;
  
  END;

  FUNCTION findlikeaddress
  (
    first_name   VARCHAR
   ,middle_name  VARCHAR
   ,lastname     VARCHAR
   ,country_id   NUMBER
   ,country_name VARCHAR
   ,city_id      NUMBER
   ,city_name    VARCHAR
   ,street_id    NUMBER
   ,street_name  VARCHAR
   ,contact_id   OUT NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN NULL;
  END;

  FUNCTION get_contact_telephones
  (
    par_contact_id  VARCHAR
   ,phone_type_name VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR IS
    CURSOR c IS
      SELECT cct.*
        FROM cn_contact_telephone cct
            ,t_telephone_type     ttt
       WHERE cct.contact_id = par_contact_id
         AND cct.telephone_type = ttt.id
         AND nvl(ttt.description, '~') = nvl(phone_type_name, '~');
  
    v_count        NUMBER := 0;
    v_cct          c%ROWTYPE;
    v_phone_number VARCHAR2(255);
  BEGIN
    OPEN c;
    LOOP
      FETCH c
        INTO v_cct;
      EXIT WHEN c%NOTFOUND;
    
      v_count := v_count + 1;
    
      IF v_count > 1
      THEN
        v_phone_number := ', ' || get_telephone(v_cct.id);
      ELSE
        v_phone_number := get_telephone(v_cct.id);
      END IF;
    
    END LOOP;
    RETURN v_phone_number;
  END;

  FUNCTION get_telephone(p_id cn_contact_telephone.id%TYPE) RETURN VARCHAR2 IS
    CURSOR c IS
      SELECT * FROM cn_contact_telephone WHERE id = p_id;
  
    v_cct c%ROWTYPE;
  
    v_phone_number VARCHAR2(255);
  BEGIN
    OPEN c;
    LOOP
      FETCH c
        INTO v_cct;
      EXIT WHEN c%NOTFOUND;
    
      IF v_cct.telephone_prefix IS NOT NULL
      THEN
        v_phone_number := v_phone_number || '(' || v_cct.telephone_prefix || ')';
      END IF;
      v_phone_number := v_phone_number || v_cct.telephone_number;
      IF v_cct.telephone_extension IS NOT NULL
      THEN
        v_phone_number := v_phone_number || '(доб.' || v_cct.telephone_extension || ')';
      END IF;
    END LOOP;
    CLOSE c;
    RETURN v_phone_number;
  END;

  FUNCTION getmainaddress(cont_id NUMBER) RETURN NUMBER IS
    id_addr NUMBER := NULL;
  BEGIN
    /*    begin
      select adress_id
        into id_addr
        from (select cn_contact_address.adress_id adress_id
                from cn_contact_address
               where cn_contact_address.contact_id = cont_id)
       where rownum = 1;
    exception
      when others then
        return null;
    end;*/
    RETURN id_addr;
  END;

  PROCEDURE contact_addr_del(a_id NUMBER) IS
    v_address_id NUMBER;
  BEGIN
  
    DELETE FROM cn_contact_address
     WHERE cn_contact_address.id = a_id
    RETURNING adress_id INTO v_address_id;
    DELETE FROM ins.cn_address ca WHERE ca.id = v_address_id;
  
  END;

  PROCEDURE contact_addr_lock
  (
    a_id  NUMBER
   ,ca_id NUMBER
  ) IS
    id NUMBER;
  BEGIN
    SELECT cn_contact_address.id
      INTO id
      FROM cn_contact_address
     WHERE cn_contact_address.id = ca_id
       FOR UPDATE NOWAIT;
    SELECT cn_address.id INTO id FROM cn_address WHERE cn_address.id = a_id FOR UPDATE NOWAIT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Запись уже заблокирована. Редактирование невозможно');
    
  END;

  FUNCTION get_primary_address(p_cn_contact_id NUMBER) RETURN NUMBER IS
    v_ret_val   NUMBER;
    v_addr_orig NUMBER;
    v_addr_fact NUMBER;
  BEGIN
    SELECT *
      INTO v_addr_orig
      FROM (SELECT ca.adress_id
              FROM cn_contact_address ca
                  ,ins.t_address_type tat
             WHERE ca.contact_id = p_cn_contact_id
               AND ca.address_type = tat.id
               AND tat.sort_order BETWEEN 1 AND 9998
             ORDER BY ca.status      DESC
                     ,tat.sort_order ASC
                     ,ca.adress_id   DESC)
     WHERE rownum = 1;
  
    BEGIN
      SELECT cac.id INTO v_addr_fact FROM ins.cn_address cac WHERE cac.parent_addr_id = v_addr_orig;
    EXCEPTION
      WHEN no_data_found THEN
        v_ret_val := v_addr_orig;
    END;
  
    IF v_ret_val IS NULL
       AND v_addr_orig IS NULL
    THEN
      RETURN NULL;
    ELSE
      RETURN nvl(v_ret_val, v_addr_fact);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_address_by_brief
  (
    p_cn_contact_id NUMBER
   ,p_brief         VARCHAR2
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
    SELECT adress_id
      INTO v_ret_val
      FROM (SELECT ca.adress_id
      FROM ven_cn_contact_address ca
          ,ven_t_address_type     tat
     WHERE ca.contact_id = p_cn_contact_id
       AND ca.address_type = tat.id
       AND tat.brief = p_brief
             ORDER BY nvl(ca.is_default, 0) DESC)
     WHERE rownum = 1;
    RETURN v_ret_val;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_address_by_brief;
  /*
      changed by Alex khomich
     WHERE clause for first select was changed:
          pkg_app_param.get_app_param_u('WHOAMI') was replaced with p_contact_id
          ad.is_default = 1 was added to avoid multiple address selection
          rownum = 1 was added to avoid multiple record selection
  */

  FUNCTION get_essential_list(p_contact_id IN NUMBER) RETURN v_company_info_table
    PIPELINED IS
    varv_company_info_row v_company_info_row;
  BEGIN
    FOR temp_cur IN (SELECT CASE e.brief
                              WHEN 'ФЛ' THEN
                               ' '
                              WHEN 'ЮЛ' THEN
                               ' '
                              ELSE
                               e.brief
                            END AS company_type
                           ,ent.obj_name(ent.id_by_brief('CONTACT'), c.contact_id) AS company_name
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('KPP')
                                   AND cci.contact_id = c.contact_id
                                   AND rownum = 1)
                               ,' ') AS kpp
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('INN')
                                   AND cci.contact_id = c.contact_id
                                   AND rownum = 1)
                               ,' ') AS inn
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('BIK')
                                   AND cci.contact_id = c.contact_id
                                   AND rownum = 1)
                               ,' ') AS bik
                           ,nvl(ent.obj_name(ent.id_by_brief('CONTACT'), ccba.bank_id), ' ') AS bank_name
                           ,ccba.account_nr AS account_number
                           ,ccba.account_corr AS account_corr
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('KORR')
                                   AND cci.contact_id = ccba.bank_id
                                   AND rownum = 1)
                               ,' ') AS b_kor_account
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('BIK')
                                   AND cci.contact_id = ccba.bank_id
                                   AND rownum = 1)
                               ,' ') AS b_bic
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('OKPO')
                                   AND cci.contact_id = ccba.bank_id
                                   AND rownum = 1)
                               ,'') AS b_okpo
                           ,nvl((SELECT CASE cci.serial_nr
                                         WHEN NULL THEN
                                          cci.id_value
                                         ELSE
                                          cci.serial_nr || ' ' || cci.id_value
                                       END AS company_bank_req
                                  FROM ven_cn_contact_ident cci
                                      ,ven_t_id_type        it
                                 WHERE cci.id_type = it.id
                                   AND it.brief IN ('OGRN')
                                   AND cci.contact_id = ccba.bank_id
                                   AND rownum = 1)
                               ,'') AS b_ogrn
                           ,nvl((SELECT ent.obj_name(cca.ent_id, cca.id)
                                  FROM ven_cn_contact_address cca
                                      ,ven_t_address_type     tat
                                 WHERE cca.contact_id = c.contact_id
                                   AND tat.brief = 'LEGAL'
                                   AND tat.id = cca.address_type
                                   AND rownum = 1)
                               ,' ') AS legal_address
                           ,nvl((SELECT ent.obj_name(cca.ent_id, cca.id)
                                  FROM ven_cn_contact_address cca
                                      ,ven_t_address_type     tat
                                 WHERE cca.contact_id = c.contact_id
                                   AND tat.brief = 'FACT'
                                   AND tat.id = cca.address_type
                                   AND rownum = 1)
                               ,' ') AS fact_address
                           ,nvl((SELECT ent.obj_name(cca.ent_id, cca.id) AS address
                                  FROM ven_cn_contact_address cca
                                      ,ven_t_address_type     tat
                                 WHERE cca.contact_id = c.contact_id
                                   AND tat.brief = 'POSTAL'
                                   AND tat.id = cca.address_type
                                   AND rownum = 1)
                               ,' ') AS postal_address
                           ,nvl(pkg_contact.get_phone_number(c.contact_id, 'WORK')
                               ,pkg_contact.get_phone_number(c.contact_id, 'CONT')) AS phone
                           ,pkg_contact.get_phone_number(c.contact_id, 'FAX') AS fax
                           ,CASE cci.serial_nr
                              WHEN NULL THEN
                               cci.id_value
                              ELSE
                               cci.serial_nr || ' ' || cci.id_value
                            END AS licence_number
                           ,cci.issue_date AS licence_date
                           ,nvl((SELECT ent.obj_name(ent.id_by_brief('CONTACT'), v.contact_id_a)
                                  FROM ven_cn_contact_rel v
                                      ,t_contact_rel_type t
                                 WHERE v.contact_id_b = c.contact_id
                                   AND v.relationship_type = t.reverse_relationship_type
                                   AND upper(t.brief) = upper('GM'))
                               ,' ') AS chief_name
                           ,CASE bct.brief
                              WHEN 'ЮЛ' THEN
                               ' '
                              ELSE
                               bct.brief
                            END AS bank_company_type
                       FROM ven_contact             c
                           ,ven_t_contact_type      e
                           ,ven_t_contact_type      ep
                           ,ven_cn_contact_bank_acc ccba
                           ,ven_t_contact_type      bct
                           ,ven_contact             bc
                           ,ven_cn_contact_ident    cci
                           ,ven_t_id_type           it
                      WHERE c.contact_type_id = e.id
                        AND e.upper_level_id = ep.id
                        AND ep.brief = 'ЮЛ'
                        AND bc.contact_id(+) = ccba.bank_id
                        AND bct.id(+) = bc.contact_type_id
                        AND ccba.contact_id(+) = c.contact_id
                        AND c.contact_id = p_contact_id
                        AND cci.contact_id(+) = c.contact_id
                        AND cci.id_type = it.id(+)
                        AND it.brief(+) = 'LICENCE'
                        AND rownum = 1)
    LOOP
      varv_company_info_row.company_type      := temp_cur.company_type;
      varv_company_info_row.company_name      := temp_cur.company_name;
      varv_company_info_row.kpp               := temp_cur.kpp;
      varv_company_info_row.inn               := temp_cur.inn;
      varv_company_info_row.bik               := temp_cur.bik;
      varv_company_info_row.bank_name         := temp_cur.bank_name;
      varv_company_info_row.account_number    := temp_cur.account_number;
      varv_company_info_row.account_corr      := temp_cur.account_corr;
      varv_company_info_row.b_kor_account     := temp_cur.b_kor_account;
      varv_company_info_row.b_bic             := temp_cur.b_bic;
      varv_company_info_row.b_okpo            := temp_cur.b_okpo;
      varv_company_info_row.b_ogrn            := temp_cur.b_ogrn;
      varv_company_info_row.legal_address     := temp_cur.legal_address;
      varv_company_info_row.fact_address      := temp_cur.fact_address;
      varv_company_info_row.postal_address    := temp_cur.postal_address;
      varv_company_info_row.phone             := temp_cur.phone;
      varv_company_info_row.fax               := temp_cur.fax;
      varv_company_info_row.licence_number    := temp_cur.licence_number;
      varv_company_info_row.licence_date      := temp_cur.licence_date;
      varv_company_info_row.chief_name        := temp_cur.chief_name;
      varv_company_info_row.bank_company_type := temp_cur.bank_company_type;
      PIPE ROW(varv_company_info_row);
    END LOOP;
    RETURN;
  END;

  FUNCTION get_essential(p_contact_id IN NUMBER) RETURN VARCHAR2 IS
    v_organ        VARCHAR2(150);
    v_contact_name VARCHAR2(150);
    v_contact_addr VARCHAR2(500);
    v_cont_inn     NUMBER;
    v_cont_kpp     NUMBER;
    v_cont_pc      NUMBER;
    v_bank_name    VARCHAR2(100);
    v_bank_filial  VARCHAR2(100);
    v_bank_kc      NUMBER;
    v_bank_bik     NUMBER;
    v_bank_tel     VARCHAR2(15);
    v_bank_faks    VARCHAR2(10);
    v_bank_id      NUMBER;
    v_res          VARCHAR2(1000);
  BEGIN
    SELECT ct.description
          ,ent.obj_name(c.ent_id, c.contact_id) contact_name
          ,nvl(v.name, pkg_contact.get_address_name(ad.adress_id)) address_name
          ,
           /*ad.address_name,*/ccba.account_nr pc
          ,ccba.bank_id
          ,ent.obj_name(c.ent_id, ccba.bank_id) bank_name
          ,ccba.branch_name
          ,(SELECT '(' || tel.telephone_prefix || ')' || ' ' || tel.telephone_number
             FROM ven_cn_contact_telephone tel
                 ,ven_t_telephone_type     tt
            WHERE tel.telephone_type = tt.id
              AND tel.contact_id = v_bank_id
              AND lower(tt.description) LIKE '%рабоч%' || '%телефон%'
              AND rownum = 1)
          ,(SELECT tel2.telephone_number
             FROM ven_cn_contact_telephone tel2
                 ,ven_t_telephone_type     tt2
            WHERE tel2.telephone_type = tt2.id
              AND tel2.contact_id = v_bank_id
              AND lower(tt2.description) LIKE '%факс%'
              AND rownum = 1)
      INTO v_organ
          ,v_contact_name
          ,v_contact_addr
          ,v_cont_pc
          ,v_bank_id
          ,v_bank_name
          ,v_bank_filial
          ,v_bank_tel
          ,v_bank_faks
      FROM ven_t_contact_type      ct
          ,cn_contact_address      ad
          ,ven_cn_contact_bank_acc ccba
          ,ven_contact             c
          ,ins.cn_address          v
     WHERE ccba.contact_id = c.contact_id
       AND c.contact_type_id = ct.id
       AND ad.contact_id = c.contact_id
       AND ad.is_default = 1
       AND ad.adress_id = v.id
       AND c.contact_id = p_contact_id;
  
    FOR v_r IN (SELECT tel.telephone_prefix
                      ,tel.telephone_number
                      ,lower(tt.description) des
                  FROM ven_cn_contact_telephone tel
                      ,ven_t_telephone_type     tt
                 WHERE tel.telephone_type = tt.id
                   AND tel.contact_id = v_bank_id)
    LOOP
      IF v_r.des LIKE '%рабоч%' || '%телефон%'
      THEN
        v_bank_tel := '(' || v_r.telephone_prefix || ')' || ' ' || v_r.telephone_number;
      END IF;
      IF v_r.des LIKE '%факс%'
      THEN
        v_bank_faks := v_r.telephone_number;
      END IF;
    END LOOP;
  
    SELECT SUM(CASE
                 WHEN (ty.description = 'КПП' AND ide.contact_id = p_contact_id) THEN
                  ide.id_value
               END)
          ,SUM(CASE
                 WHEN (ty.description = 'ИНН' AND ide.contact_id = p_contact_id) THEN
                  ide.id_value
               END)
          ,SUM(CASE
                 WHEN (ty.description = 'Кор.счет' AND ide.contact_id = v_bank_id) THEN
                  ide.id_value
               END)
          ,SUM(CASE
                 WHEN (ty.description = 'БИК' AND ide.contact_id = v_bank_id) THEN
                  ide.id_value
               END)
      INTO v_cont_inn
          ,v_cont_kpp
          ,v_bank_kc
          ,v_bank_bik
      FROM ven_cn_contact_ident ide
          ,ven_t_id_type        ty
     WHERE ide.id_type = ty.id;
  
    v_res := v_organ || ' ' || v_contact_name || ' ' || chr(10) || v_contact_addr || chr(10) ||
             ' ИНН ' || v_cont_inn || ', КПП ' || v_cont_kpp || chr(10) || 'Р/с ' || v_cont_pc ||
             chr(10) || 'в ' || v_bank_name || ' ' || v_bank_filial || chr(10) || 'к/с ' || v_bank_kc ||
             ', БИК ' || v_bank_bik || chr(10) || 'Тел.:' || v_bank_tel || '  Факс: ' || v_bank_faks;
  
    RETURN v_res;
  END;

  FUNCTION get_bank_essential(p_contact_id IN NUMBER) RETURN VARCHAR2 IS
    v VARCHAR2(200);
  BEGIN
  
    SELECT inn || ', ' || kpp || ', ' || 'Р/c ' || bank.account_nr || ' В ' || bank.bank_name ||
           ' г.Москва, ' || bik || ', ' || kor
      INTO v
      FROM (SELECT 'ИНН ' || SUM(CASE
                                   WHEN (ty.description = 'ИНН' AND ide.contact_id = p_contact_id) THEN
                                    ide.id_value
                                 END) inn
                  ,'КПП ' || SUM(CASE
                                   WHEN (ty.description = 'КПП' AND ide.contact_id = p_contact_id) THEN
                                    ide.id_value
                                 END) kpp
                  ,'БИК ' || SUM(CASE
                                   WHEN (ty.description = 'БИК' AND
                                        ide.contact_id = (SELECT ccba.bank_id
                                                             FROM ven_cn_contact_bank_acc ccba
                                                            WHERE ccba.contact_id = p_contact_id
                                                              AND rownum = 1)) THEN
                                    ide.id_value
                                 END) bik
                  ,'К/C ' || SUM(CASE
                                   WHEN (ty.description = 'Кор.счет' AND
                                        ide.contact_id = (SELECT ccba.bank_id
                                                             FROM ven_cn_contact_bank_acc ccba
                                                            WHERE ccba.contact_id = p_contact_id
                                                              AND rownum = 1)) THEN
                                    ide.id_value
                                 END) kor
            
              FROM ven_cn_contact_ident ide
                  ,ven_t_id_type        ty
             WHERE ide.id_type = ty.id)
          ,(SELECT *
              FROM ven_cn_contact_bank_acc ccba
             WHERE ccba.contact_id = p_contact_id
               AND rownum = 1) bank
     WHERE rownum = 1;
    RETURN v;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  -- основная функция склонения
  FUNCTION snp_case
  (
    p_fio     IN VARCHAR2
   ,p_padzh   IN VARCHAR2
   ,p_fio_fmt IN VARCHAR2 DEFAULT 'ФИО'
   ,p_sex     IN VARCHAR2 DEFAULT NULL -- пол 'ж'|'Ж'|'м'|'М'
  ) RETURN VARCHAR2 -- вывод в нужном падеже
   IS
    l_pdzh_chr VARCHAR2(1);
    l_pdzh     PLS_INTEGER;
    l_sex      VARCHAR2(1) := substr(ltrim(lower(p_sex)), 1, 1);
    l_tailchr  VARCHAR2(1);
    l_nmlen    NUMBER(2, 0);
    l_ul       VARCHAR2(1) := 'N';
    l_uf       VARCHAR2(1) := 'N';
    l_um       VARCHAR2(1) := 'N';
    l_name_s   VARCHAR2(80);
    l_name_n   VARCHAR2(80) := NULL;
    l_name_p   VARCHAR2(80) := NULL;
    l_fio      VARCHAR2(500);
    l_fname    VARCHAR2(80);
    l_mname    VARCHAR2(80);
    l_fullname VARCHAR2(500) := ltrim(rtrim(p_fio, ' -'), ' -');
    l_pos      PLS_INTEGER;
    l_fio_fmt  VARCHAR2(3) := nvl(upper(substr(ltrim(p_fio_fmt), 1, 3)), 'ФИО');
    --
    FUNCTION single_space
    (
      p_data VARCHAR2
     ,p_dv   VARCHAR2 DEFAULT ' '
    ) RETURN VARCHAR2 IS
      v_str VARCHAR2(2000) := p_data;
    BEGIN
      WHILE instr(v_str, p_dv || p_dv) > 0
      LOOP
        v_str := REPLACE(v_str, p_dv || p_dv, p_dv);
      END LOOP;
      RETURN v_str;
    END single_space;
    --
    FUNCTION term_cmp
    (
      s IN VARCHAR2
     ,t IN VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
      IF nvl(length(s), 0) < nvl(length(t), 0)
      THEN
        RETURN FALSE;
      END IF;
      IF substr(lower(s), -length(t)) = t
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END term_cmp;
    --
    PROCEDURE chng
    (
      s     IN OUT VARCHAR2
     ,n     IN NUMBER
     ,pzrod IN VARCHAR2
     ,pzdat IN VARCHAR2
     ,pzvin IN VARCHAR2
     ,pztvo IN VARCHAR2
     ,pzpre IN VARCHAR2
    ) IS
    BEGIN
      IF l_pdzh = 1
      THEN
        NULL;
      ELSE
        SELECT substr(s, 1, length(s) - n) ||
               decode(l_pdzh, 2, pzrod, 3, pzdat, 4, pzvin, 5, pztvo, 6, pzpre)
          INTO s
          FROM dual;
      END IF;
    END chng;
    --
    PROCEDURE prep
    (
      fnm  IN OUT VARCHAR2
     ,lfm2 IN OUT VARCHAR2
    ) IS
      pp VARCHAR2(1) := substr(lfm2, 1, 1);
      nm VARCHAR2(80);
    BEGIN
      l_pos := instr(fnm, ' ');
      IF l_pos > 0
      THEN
        nm    := substr(fnm, 1, l_pos - 1);
        fnm   := ltrim(substr(fnm, l_pos + 1));
        l_pos := instr(fnm, ' ');
      ELSE
        nm  := fnm;
        fnm := NULL;
      END IF;
      IF pp = 'Ф'
      THEN
        l_name_s := nm;
        lfm2     := REPLACE(lfm2, 'Ф');
      ELSIF pp = 'И'
      THEN
        l_fname := nm;
        lfm2    := REPLACE(lfm2, 'И');
      ELSIF pp = 'О'
      THEN
        l_mname := nm;
        lfm2    := REPLACE(lfm2, 'О');
      END IF;
    END;
    --
  BEGIN
    -- snp_case()
    l_fullname := REPLACE(REPLACE(single_space(l_fullname), ' -', '-'), '- ', '-');
    IF l_fullname IS NULL
    THEN
      RETURN p_fio;
    END IF;
    IF substr(l_fio_fmt, 1, 1) NOT IN ('Ф', 'И', 'О')
    THEN
      RETURN p_fio;
    END IF;
    IF nvl(substr(l_fio_fmt, 2, 1), 'Ф') NOT IN ('Ф', 'И', 'О')
    THEN
      RETURN p_fio;
    END IF;
    IF nvl(substr(l_fio_fmt, 3, 1), 'Ф') NOT IN ('Ф', 'И', 'О')
    THEN
      RETURN p_fio;
    END IF;
    -- оглы, кызы:
    IF lower(ltrim(rtrim(l_fullname))) LIKE '%оглы%'
       AND length(l_fullname) > 4
    THEN
      l_name_p   := substr(l_fullname, instr(lower(l_fullname), 'оглы'), 4);
      l_fullname := REPLACE(REPLACE(REPLACE(REPLACE(l_fullname, 'оглы', NULL), 'Оглы', NULL)
                                   ,'ОГЛЫ'
                                   ,NULL)
                           ,'  '
                           ,' ');
      l_sex      := nvl(l_sex, 'м');
    ELSIF lower(ltrim(rtrim(l_fullname))) LIKE '%кызы%'
          AND length(l_fullname) > 4
    THEN
      l_name_p   := substr(l_fullname, instr(lower(l_fullname), 'кызы'), 4);
      l_fullname := REPLACE(REPLACE(REPLACE(REPLACE(l_fullname, 'кызы', NULL), 'Кызы', NULL)
                                   ,'КЫЗЫ'
                                   ,NULL)
                           ,'  '
                           ,' ');
      l_sex      := nvl(l_sex, 'ж');
    END IF;
    LOOP
      IF l_fullname IS NOT NULL
      THEN
        prep(l_fullname, l_fio_fmt);
      ELSE
        EXIT;
      END IF;
    END LOOP;
    l_nmlen    := nvl(length(l_name_s), 0);
    l_pdzh_chr := upper(substr(p_padzh, 1, 1));
    SELECT decode(l_pdzh_chr, 'И', 1, 'Р', 2, 'Д', 3, 'В', 4, 'Т', 5, 'П', 6, 0)
      INTO l_pdzh
      FROM dual;
    IF l_pdzh = 0
    THEN
      BEGIN
        l_pdzh := to_number(l_pdzh_chr);
      EXCEPTION
        WHEN OTHERS THEN
          RETURN p_fio;
      END;
    END IF;
    IF nvl(l_sex, 'z') NOT IN ('м', 'ж')
    THEN
      -- если пол не определен,
      -- то пробуем определить его по отчеству:
      IF l_mname IS NOT NULL
         AND (upper(substr(l_mname, -1)) = 'Ч' OR lower(l_name_p) LIKE 'оглы')
      THEN
        l_sex := 'м';
      ELSE
        l_sex := 'ж';
      END IF;
    END IF;
    IF l_name_s IS NOT NULL
    THEN
      -- фамилия
      IF upper(l_name_s) = l_name_s
      THEN
        l_ul := 'Y';
      END IF;
      -- Предусмотрим обработку сдвоенной фамилии:
      IF instr(l_name_s, '-') > 0
         AND lower(l_name_s) NOT LIKE 'тер-%'
      THEN
        l_name_n := substr(l_name_s, 1, instr(l_name_s, '-') - 1) || ' ' || l_fname || ' ' || l_mname;
        l_fio    := snp_case(l_name_n, p_padzh, 'ФИО', l_sex);
        l_name_n := substr(l_fio, 1, instr(l_fio, ' ') - 1) || '-';
        l_name_s := substr(l_name_s, instr(l_name_s, '-') + 1);
      END IF;
      l_tailchr := lower(substr(l_name_s, -1));
      IF l_sex = 'м'
      THEN
        -- мужчины
        IF l_tailchr NOT IN ('о', 'е', 'у', 'ю', 'и', 'э', 'ы')
        THEN
          IF l_tailchr = 'в'
          THEN
            chng(l_name_s, 0, 'а', 'у', 'а', 'ым', 'е');
          ELSIF l_tailchr = 'н'
                AND term_cmp(l_name_s, 'ин')
          THEN
            chng(l_name_s, 0, 'а', 'у', 'а', 'ым', 'е');
          ELSIF l_tailchr = 'ц'
                AND term_cmp(l_name_s, 'ец')
          THEN
            IF l_nmlen > 3
               AND substr(l_name_s, -3) IN ('аец', 'еец', 'иец', 'оец', 'уец')
            THEN
              chng(l_name_s, 2, 'йца', 'йцу', 'йца', 'йцем', 'йце');
            ELSIF l_nmlen > 3
                  AND lower(substr(l_name_s, -3)) IN
                  ('тец', 'бец', 'вец', 'мец', 'нец', 'рец', 'сец')
                  AND lower(substr(l_name_s, -4, 1)) IN
                  ('а', 'е', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я', 'ё')
            THEN
              chng(l_name_s, 2, 'ца', 'цу', 'ца', 'цом', 'це');
            ELSIF l_nmlen > 3
                  AND lower(substr(l_name_s, -3)) = 'лец'
            THEN
              chng(l_name_s, 2, 'ьца', 'ьцу', 'ьца', 'ьцом', 'ьце');
            ELSE
              chng(l_name_s, 0, 'а', 'у', 'а', 'ом', 'е');
            END IF;
          ELSIF l_tailchr = 'х'
                AND (term_cmp(l_name_s, 'их') OR term_cmp(l_name_s, 'ых'))
          THEN
            chng(l_name_s, 0, NULL, NULL, NULL, NULL, NULL);
          ELSIF l_tailchr IN ('б'
                             ,'г'
                             ,'д'
                             ,'ж'
                             ,'з'
                             ,'л'
                             ,'м'
                             ,'н'
                             ,'п'
                             ,'р'
                             ,'с'
                             ,'т'
                             ,'ф'
                             ,'х'
                             ,'ц'
                             ,'ч'
                             ,'ш'
                             ,'щ')
          THEN
            chng(l_name_s, 0, 'а', 'у', 'а', 'ом', 'е');
          ELSIF l_tailchr = 'я'
                AND NOT (term_cmp(l_name_s, 'ия') OR term_cmp(l_name_s, 'ая'))
          THEN
            chng(l_name_s, 1, 'и', 'е', 'ю', 'ей', 'е');
          ELSIF l_tailchr = 'а'
                AND NOT (term_cmp(l_name_s, 'иа') OR term_cmp(l_name_s, 'уа'))
          THEN
            chng(l_name_s, 1, 'и', 'е', 'у', 'ой', 'е');
          ELSIF l_tailchr = 'ь'
          THEN
            chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF l_tailchr = 'к'
          THEN
            IF l_nmlen > 4
               AND term_cmp(l_name_s, 'ок')
            THEN
              chng(l_name_s, 2, 'ка', 'ку', 'ка', 'ком', 'ке');
            ELSIF l_nmlen > 4
                  AND (term_cmp(l_name_s, 'лек') OR term_cmp(l_name_s, 'рек'))
            THEN
              chng(l_name_s, 2, 'ька', 'ьку', 'ька', 'ьком', 'ьке');
            ELSE
              chng(l_name_s, 0, 'а', 'у', 'а', 'ом', 'е');
            END IF;
          ELSIF l_tailchr = 'й'
          THEN
            IF l_nmlen > 4
            THEN
              IF (term_cmp(l_name_s, 'кий') OR term_cmp(l_name_s, 'кий'))
              THEN
                chng(l_name_s, 2, 'ого', 'ому', 'ого', 'им', 'ом');
              ELSIF term_cmp(l_name_s, 'ой')
              THEN
                chng(l_name_s, 2, 'ого', 'ому', 'ого', 'им', 'ом');
              ELSIF term_cmp(l_name_s, 'ый')
              THEN
                chng(l_name_s, 2, 'ого', 'ому', 'ого', 'ым', 'ом');
              ELSIF lower(substr(l_name_s, -3)) IN ('рий'
                                                   ,'жий'
                                                   ,'лий'
                                                   ,'вий'
                                                   ,'дий'
                                                   ,'бий'
                                                   ,'гий'
                                                   ,'зий'
                                                   ,'мий'
                                                   ,'ний'
                                                   ,'пий'
                                                   ,'сий'
                                                   ,'фий'
                                                   ,'хий')
              THEN
                chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'и');
              ELSIF term_cmp(l_name_s, 'ий')
              THEN
                chng(l_name_s, 2, 'его', 'ему', 'его', 'им', 'им');
              ELSE
                chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'е');
              END IF;
            ELSE
              chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'е');
            END IF;
          END IF;
        END IF;
      ELSIF l_sex = 'ж'
      THEN
        -- женщины
        IF lower(substr(l_name_s, -3)) IN ('ова', 'ева', 'ына', 'ина', 'ена')
        THEN
          chng(l_name_s, 1, 'ой', 'ой', 'у', 'ой', 'ой');
        ELSIF term_cmp(l_name_s, 'ая')
              AND lower(substr(l_name_s, -3, 1)) IN ('ц')
        THEN
          chng(l_name_s, 2, 'ей', 'ей', 'ую', 'ей', 'ей');
        ELSIF term_cmp(l_name_s, 'ая')
        THEN
          chng(l_name_s, 2, 'ой', 'ой', 'ую', 'ой', 'ой');
        ELSIF term_cmp(l_name_s, 'ля')
              OR term_cmp(l_name_s, 'ня')
        THEN
          chng(l_name_s, 1, 'и', 'е', 'ю', 'ей', 'е');
        ELSIF term_cmp(l_name_s, 'а')
              AND lower(substr(l_name_s, -2, 1)) IN ('д')
        THEN
          chng(l_name_s, 1, 'ы', 'е', 'у', 'ой', 'е');
        END IF;
      END IF;
    END IF;
    IF l_fname IS NOT NULL
    THEN
      -- имя
      IF upper(l_fname) = l_fname
      THEN
        l_uf := 'Y';
      END IF;
      l_tailchr := lower(substr(l_fname, -1));
      IF l_sex = 'м'
      THEN
        -- мужчины
        IF l_tailchr NOT IN ('е', 'и', 'у')
        THEN
          IF upper(l_fname) = 'ЛЕВ'
          THEN
            chng(l_fname, 2, 'ьва', 'ьву', 'ьва', 'ьвом', 'ьве');
          ELSIF l_tailchr IN ('б'
                             ,'в'
                             ,'г'
                             ,'д'
                             ,'з'
                             ,'ж'
                             ,'к'
                             ,'м'
                             ,'н'
                             ,'п'
                             ,'р'
                             ,'с'
                             ,'т'
                             ,'ф'
                             ,'х'
                             ,'ц'
                             ,'ч'
                             ,'ш'
                             ,'щ')
          THEN
            chng(l_fname, 0, 'а', 'у', 'а', 'ом', 'е');
          ELSIF l_tailchr = 'а'
          THEN
            chng(l_fname, 1, 'ы', 'е', 'у', 'ой', 'е');
          ELSIF l_tailchr = 'о'
          THEN
            chng(l_fname, 1, 'а', 'у', 'а', 'ом', 'е');
          ELSIF l_tailchr = 'я'
          THEN
            IF term_cmp(l_fname, 'ья')
            THEN
              chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
            ELSIF term_cmp(l_fname, 'ия')
            THEN
              chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
            ELSE
              chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
            END IF;
          ELSIF l_tailchr = 'й'
          THEN
            IF term_cmp(l_fname, 'ай')
            THEN
              chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'е');
            ELSE
              IF term_cmp(l_fname, 'ей')
              THEN
                chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'е');
              ELSE
                chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'и');
              END IF;
            END IF;
          ELSIF l_tailchr = 'ь'
          THEN
            chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF l_tailchr = 'л'
          THEN
            IF term_cmp(l_fname, 'авел')
            THEN
              chng(l_fname, 2, 'ла', 'лу', 'ла', 'лом', 'ле');
            ELSE
              chng(l_fname, 0, 'а', 'у', 'а', 'ом', 'е');
            END IF;
          END IF;
        END IF;
      ELSIF l_sex = 'ж'
      THEN
        -- женщины
        IF l_tailchr = 'а'
           AND nvl(length(l_fname), 0) > 1
        THEN
          IF lower(substr(l_fname, -2)) IN ('га', 'ха', 'ка', 'ша', 'ча', 'ща', 'жа')
          THEN
            chng(l_fname, 1, 'и', 'е', 'у', 'ой', 'е');
          ELSE
            chng(l_fname, 1, 'ы', 'е', 'у', 'ой', 'е');
          END IF;
        ELSIF l_tailchr = 'я'
              AND nvl(length(l_fname), 0) > 1
        THEN
          IF term_cmp(l_fname, 'ия')
             AND lower(substr(l_fname, -4)) IN ('ьфия')
          THEN
            chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
          ELSIF term_cmp(l_fname, 'ия')
          THEN
            chng(l_fname, 1, 'и', 'и', 'ю', 'ей', 'и');
          ELSE
            chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
          END IF;
        ELSIF l_tailchr = 'ь'
        THEN
          IF term_cmp(l_fname, 'вь')
          THEN
            chng(l_fname, 1, 'и', 'и', 'ь', 'ью', 'и');
          ELSE
            chng(l_fname, 1, 'и', 'и', 'ь', 'ью', 'ье');
          END IF;
        END IF;
      END IF;
    END IF;
    IF l_mname IS NOT NULL
    THEN
      -- отчество
      IF upper(l_mname) = l_mname
      THEN
        l_um := 'Y';
      END IF;
      l_tailchr := lower(substr(l_mname, -1));
      IF l_sex = 'м'
      THEN
        -- мужчины
        IF l_tailchr = 'ч'
        THEN
          chng(l_mname, 0, 'а', 'у', 'а', 'ем', 'е');
        END IF;
      ELSIF l_sex = 'ж'
      THEN
        -- женщины
        IF l_tailchr = 'а'
           AND length(l_mname) <> 1
        THEN
          chng(l_mname, 1, 'ы', 'е', 'у', 'ой', 'е');
        END IF;
      END IF;
    END IF;
    -- окончательная конкатенация
    l_fio_fmt := nvl(upper(substr(ltrim(p_fio_fmt), 1, 3)), 'ФИО'); -- м.б. рекурсия...
    l_pos     := 1;
    LOOP
      IF l_pos > 1
      THEN
        l_fullname := l_fullname || ' ';
      END IF;
      SELECT l_fullname ||
             decode(substr(l_fio_fmt, l_pos, 1)
                   ,'Ф'
                   ,decode(l_ul, 'Y', upper(l_name_n || l_name_s), l_name_n || l_name_s)
                   ,'И'
                   ,decode(l_uf, 'Y', upper(l_fname), l_fname)
                   ,'О'
                   ,decode(l_um
                          ,'Y'
                          ,upper(REPLACE(REPLACE(l_mname, 'оглы', NULL), 'кызы', NULL) ||
                                 decode(instr(l_mname, '-'), 0, ' ', NULL) || l_name_p)
                          ,REPLACE(REPLACE(l_mname, 'оглы', NULL), 'кызы', NULL) ||
                           decode(instr(l_mname, '-'), 0, ' ', NULL) || l_name_p))
        INTO l_fullname
        FROM dual;
      l_pos := l_pos + 1;
      IF l_pos > nvl(length(l_fio_fmt), 0)
      THEN
        EXIT;
      END IF;
    END LOOP;
    RETURN nvl(ltrim(rtrim(l_fullname, ' -'), ' -'), ltrim(rtrim(single_space(p_fio), ' -'), ' -'));
  END snp_case;

  -- возвращает склоненное ФИО
  FUNCTION get_fio_case
  (
    p_fio_str IN NUMBER
   , -- ИД контакта
    p_case    IN VARCHAR2
  ) -- падеж в виде буквы:
    -- и|И - именительный
    -- p|Р - родительный и т.д.
    -- или цифры:
    -- 1 - именительный
    -- 2 - родительный и т.д.
   RETURN VARCHAR2 IS
    v_ret_val   VARCHAR2(500);
    v_sex       CHAR(1) := NULL;
    v_type_cont VARCHAR2(250);
    v_fio       VARCHAR2(500) := NULL;
    CURSOR cur_find IS
      SELECT c.name || ' ' || c.first_name || ' ' || c.middle_name fio
            ,get_sex_char(c.middle_name) sex
        FROM ven_contact c
       WHERE c.contact_id = p_fio_str;
  BEGIN
  
    BEGIN
      SELECT tc.description
        INTO v_type_cont
        FROM t_contact_type tc
            ,contact        cpol
       WHERE cpol.contact_id = p_fio_str
         AND tc.id = cpol.contact_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_type_cont := 'Физическое лицо';
    END;
  
    IF v_type_cont <> 'Физическое лицо'
    THEN
    
      SELECT c.obj_name_orig INTO v_ret_val FROM contact c WHERE c.contact_id = p_fio_str;
    
    ELSE
    
      OPEN cur_find;
      FETCH cur_find
        INTO v_fio
            ,v_sex;
      IF cur_find%NOTFOUND
      THEN
        v_fio := NULL;
        v_sex := NULL;
      END IF;
      CLOSE cur_find;
    
      IF v_fio IS NULL
      THEN
        v_ret_val := NULL;
      ELSE
        v_ret_val := snp_case(v_fio, p_case, 'ФИО', v_sex);
      END IF;
    
    END IF;
  
    RETURN(v_ret_val);
  END;

  FUNCTION get_fio_case
  (
    p_fio_str IN VARCHAR2
   , -- строка ФИО вида: Фамилия Имя Отчество
    p_case    IN VARCHAR2
   , -- падеж в виде буквы:
    -- и|И - именительный
    -- p|Р - родительный и т.д.
    -- или цифры:
    -- 1 - именительный
    -- 2 - родительный и т.д.
    p_seq IN VARCHAR2 DEFAULT NULL
   ,p_sex IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(500);
    v_sex     CHAR(1) := NULL;
  BEGIN
    v_sex := nvl(p_sex, get_sex_char(get_fio_fmt(p_fio_str, 3)));
    IF v_sex IS NOT NULL
    THEN
      v_ret_val := snp_case(p_fio_str, p_case, nvl(p_seq, 'ФИО'), v_sex);
    ELSE
      v_ret_val := p_fio_str;
    END IF;
    RETURN(v_ret_val);
  END;

  --------------------------------------------------------------------------------
  -- возращает одну из частей ФИО, в зависимости от параметра num
  -- 1 - Фамилия
  -- 2 - Имя
  -- 3 - Отчество и все осталное.
  -- 4 - Фамилия И. О.
  -- 5 - И. О. Фамилия
  -- 6 - Имя Отчество Фамилия
  FUNCTION get_fio_fmt
  (
    str VARCHAR2
   ,num NUMBER
  ) RETURN VARCHAR2 IS
    TYPE t_f_i_o IS VARRAY(3) OF VARCHAR2(255);
    res         t_f_i_o := t_f_i_o();
    first_name  VARCHAR2(60);
    second_name VARCHAR2(60);
    surname     VARCHAR2(60);
    str1        VARCHAR2(1021);
    str2        VARCHAR2(1021);
    str3        VARCHAR2(1021);
    i           NUMBER;
    j           NUMBER;
  BEGIN
    IF (str IS NULL)
       OR (length(str) >= 55)
    THEN
      RETURN str;
    END IF;
  
    str1 := str;
    j    := 1;
    res  := t_f_i_o('', '', '');
    LOOP
      str2 := TRIM(str1);
      i    := instr(str2, ' ');
      --   res.extend;
      IF i = 0
         OR j = 3
      THEN
        res(j) := str1;
      ELSE
        res(j) := substr(str2, 1, i);
        str1 := TRIM(substr(str2, i));
      END IF;
      EXIT WHEN i = 0 OR j = 3;
      j := j + 1;
    END LOOP;
    surname     := res(1);
    first_name  := res(2);
    second_name := res(3);
    res.delete;
    res := NULL;
    RETURN CASE WHEN num = 1 THEN surname WHEN num = 2 THEN first_name WHEN num = 3 THEN second_name WHEN num = 4 THEN initcap(surname) || ' ' || upper(substr(first_name
                                                                                                                                                              ,1
                                                                                                                                                              ,1)) || '. ' || upper(substr(second_name
                                                                                                                                                                                          ,1
                                                                                                                                                                                          ,1)) || '. ' WHEN num = 5 THEN upper(substr(first_name
                                                                                                                                                                                                                                     ,1
                                                                                                                                                                                                                                     ,1)) || '. ' || upper(substr(second_name
                                                                                                                                                                                                                                                                 ,1
                                                                                                                                                                                                                                                                 ,1)) || '. ' || initcap(surname) WHEN num = 6 THEN first_name || ' ' || second_name || ' ' || surname ELSE '' --res(1)||res(2)||res(3)
    END;
  END;

  -- возвращает начальную букву пола М/Ж, если пол определен или пустую строку
  -- входной параметр - Отчество
  FUNCTION get_sex_char(p_middle_name IN VARCHAR2) RETURN VARCHAR2 IS
    v_last_char CHAR(1);
  BEGIN
    IF p_middle_name IS NULL
       OR p_middle_name = ''
    THEN
      RETURN(NULL);
    END IF;
    v_last_char := upper(substr(p_middle_name, length(p_middle_name)));
    IF v_last_char = 'Ч'
    THEN
      RETURN('М');
    ELSE
      RETURN('Ж');
    END IF;
  END;

  -- Возвращает id пола
  FUNCTION get_sex_id(p_contact_id IN NUMBER) RETURN NUMBER AS
    buf NUMBER;
  BEGIN
    SELECT p.gender INTO buf FROM cn_person p WHERE p.contact_id = p_contact_id;
    RETURN(buf);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_gender_id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER AS
    v_gender_id t_gender.id%TYPE;
    v_brief     t_gender.brief%TYPE;
  BEGIN
    IF upper(p_brief) IN ('М', 'МУЖ', 'МУЖСКОЙ', 'M', 'MALE', '1')
    THEN
      v_brief := 'MALE';
    ELSIF upper(p_brief) IN ('Ж', 'ЖЕН', 'ЖЕНСКИЙ', 'F', 'FEMALE', '0')
    THEN
      v_brief := 'FEMALE';
    END IF;
  
    SELECT id INTO v_gender_id FROM t_gender WHERE brief = v_brief;
  
    RETURN v_gender_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  -- возвращает ид связанного контакта, если такой связи нет - null
  -- входной параметр - ид контакта, тип сявязи ('GM' - Генеральный деректор,'CM' - Главный врач,...)
  FUNCTION get_rel_contact_id
  (
    p_contact_id NUMBER
   ,p_rel_type   ven_t_contact_rel_type.brief%TYPE
  ) RETURN NUMBER IS
    buf NUMBER;
  BEGIN
    SELECT v.contact_id_a
      INTO buf
      FROM ven_cn_contact_rel     v
          ,ven_t_contact_rel_type t
     WHERE v.contact_id_b = p_contact_id
       AND v.relationship_type = t.reverse_relationship_type
       AND upper(t.brief) = upper(p_rel_type);
  
    RETURN(buf);
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_rel_description
  (
    p_contact_id_a IN NUMBER
   ,p_contact_id_b IN NUMBER
  ) RETURN VARCHAR2 IS
    buf VARCHAR2(255);
  BEGIN
    SELECT ct.relationship_dsc
      INTO buf
      FROM cn_contact_rel     cr
          ,t_contact_rel_type ct
     WHERE cr.contact_id_a = p_contact_id_a
       AND cr.contact_id_b = p_contact_id_b
       AND ct.id = cr.relationship_type
       AND rownum = 1;
    RETURN buf;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_rel_note
  (
    p_contact_id_a IN NUMBER
   ,p_contact_id_b IN NUMBER
   ,p_rel_brief    ven_t_contact_rel_type.brief%TYPE
  ) RETURN VARCHAR2 IS
    str VARCHAR2(4000);
  BEGIN
    SELECT cr.remarks
      INTO str
      FROM cn_contact_rel cr
      JOIN t_contact_rel_type ct
        ON ct.id = cr.relationship_type
     WHERE 1 = 1
       AND cr.contact_id_a = p_contact_id_a
       AND cr.contact_id_b = p_contact_id_b
       AND ct.brief = p_rel_brief;
    RETURN str;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  /* 
  Капля П.
  Получаем ИД типа связи между контактами, возвращает null если связи нет.
   */
  FUNCTION get_rel_type_between_contacts
  (
    par_contact_a_id contact.contact_id%TYPE
   ,par_contact_b_id contact.contact_id%TYPE
  ) RETURN cn_contact_rel.relationship_type%TYPE IS
    v_rel_type_id cn_contact_rel.relationship_type%TYPE;
  BEGIN
    BEGIN
      SELECT ccr.relationship_type
        INTO v_rel_type_id
        FROM cn_contact_rel ccr
       WHERE ccr.contact_id_a = par_contact_a_id
         AND ccr.contact_id_b = par_contact_b_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN v_rel_type_id;
  END get_rel_type_between_contacts;

  FUNCTION get_address_region(p_cn_address_id IN NUMBER) RETURN VARCHAR2 IS
    v_res VARCHAR2(100);
  BEGIN
    SELECT nvl2(nvl2(a.province_name, a.province_name, a.city_name)
               ,nvl2(a.province_name, a.province_name, a.city_name)
               ,cntr.description)
      INTO v_res
      FROM cn_address a
          ,t_country  cntr
     WHERE a.country_id = cntr.id
       AND a.id = p_cn_address_id;
    RETURN v_res;
  END;

  FUNCTION get_primary_doc(p_contact_id NUMBER) RETURN VARCHAR2 IS
    CURSOR doc_n IS
      SELECT tit.description doc_desc
            ,decode(nvl(cci.serial_nr, '@'), '@', cci.id_value, cci.serial_nr || '-' || cci.id_value) doc_ser_num
            ,cci.place_of_issue
            ,cci.issue_date
        FROM ven_cn_person        vcp
            ,ven_cn_contact_ident cci
            ,ven_t_id_type        tit
       WHERE vcp.contact_id = p_contact_id
         AND vcp.contact_id = cci.contact_id
         AND cci.id_type = tit.id
       ORDER BY nvl(cci.is_default, 0) DESC
               ,tit.sort_order;
  
    doc_n_var doc_n%ROWTYPE;
    ret_val   VARCHAR2(1500);
  BEGIN
    ret_val := 'ret';
  
    OPEN doc_n;
  
    FETCH doc_n
      INTO doc_n_var;
  
    IF doc_n%NOTFOUND
    THEN
      ret_val := '';
    ELSE
      ret_val := doc_n_var.doc_desc || '  Номер: ' || doc_n_var.doc_ser_num || '  Выдан: ';
    
      IF doc_n_var.place_of_issue IS NOT NULL
      THEN
        ret_val := ret_val || doc_n_var.place_of_issue;
      ELSE
        ret_val := ret_val || '';
      END IF;
    
      ret_val := ret_val || ' Дата выдачи: ';
    
      IF doc_n_var.issue_date IS NOT NULL
      THEN
        ret_val := ret_val || to_char(doc_n_var.issue_date, 'DD.MM.YYYY');
      ELSE
        ret_val := ret_val || '';
      END IF;
    END IF;
  
    CLOSE doc_n;
  
    RETURN ret_val;
  END;

  FUNCTION get_primary_doc_2(p_contact_id NUMBER) RETURN VARCHAR2 IS
    res VARCHAR2(512);
  BEGIN
    SELECT VALUE
      INTO res
      FROM (SELECT decode(tit.description
                         ,'Паспорт гражданина РФ'
                         ,'паспорт'
                         ,tit.description) || ': ' ||
                   decode(nvl(cci.serial_nr, '@')
                         ,'@'
                         ,cci.id_value
                         ,cci.serial_nr || ' ' || cci.id_value) || ' Выдан ' || cci.place_of_issue || ', ' ||
                   to_char(cci.issue_date, 'dd.mm.yyyy') AS VALUE
              FROM ven_cn_person        vcp
                  ,ven_cn_contact_ident cci
                  ,ven_t_id_type        tit
             WHERE vcp.contact_id = p_contact_id
               AND vcp.contact_id = cci.contact_id
               AND cci.id_type = tit.id
               AND tit.description <> 'ИНН'
             ORDER BY nvl(cci.is_default, 0) DESC
                     ,tit.sort_order)
     WHERE rownum = 1;
    RETURN res;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;

  FUNCTION get_contact_ident_doc_by_type
  (
    par_contact_id           contact.contact_id%TYPE
   ,par_ident_doc_type_brief t_id_type.brief%TYPE
  ) RETURN cn_contact_ident.id_value%TYPE IS
    v_id_value cn_contact_ident.id_value%TYPE;
  BEGIN
    SELECT id_value
      INTO v_id_value
      FROM (SELECT cci.id_value
              FROM cn_contact_ident cci
                  ,t_id_type        it
             WHERE cci.contact_id = par_contact_id
               AND cci.id_type = it.id
               AND it.brief = par_ident_doc_type_brief
             ORDER BY nvl(cci.is_default, 0) DESC
                     ,it.sort_order)
     WHERE rownum < 2;
  
    RETURN v_id_value;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN '';
  END get_contact_ident_doc_by_type;

  FUNCTION get_primary_tel(p_contact_id NUMBER) RETURN VARCHAR2 IS
    CURSOR phone IS
      SELECT vcct.*
        FROM ven_cn_contact_telephone vcct
            ,ven_t_telephone_type     ttype
       WHERE vcct.telephone_type = ttype.id
         AND vcct.contact_id = p_contact_id
       ORDER BY ttype.sort_order;
  
    phone_var phone%ROWTYPE;
    ret_val   VARCHAR2(255);
  BEGIN
    OPEN phone;
  
    FETCH phone
      INTO phone_var;
  
    IF phone%NOTFOUND
    THEN
      ret_val := '';
    ELSE
      IF phone_var.telephone_prefix IS NOT NULL
      THEN
        ret_val := ret_val || '(' || phone_var.telephone_prefix || ')';
      END IF;
    
      ret_val := ret_val || phone_var.telephone_number;
    
      IF phone_var.telephone_extension IS NOT NULL
      THEN
        ret_val := ret_val || '(доб.' || phone_var.telephone_extension || ')';
      END IF;
    END IF;
  
    CLOSE phone;
  
    RETURN ret_val;
  END;

  FUNCTION get_is_individual(par_contact_id contact.contact_id%TYPE)
    RETURN t_contact_type.is_individual%TYPE IS
    v_is_individual t_contact_type.is_individual%TYPE;
  BEGIN
    SELECT ct.is_individual
      INTO v_is_individual
      FROM contact        c
          ,t_contact_type ct
     WHERE c.contact_id = par_contact_id
       AND c.contact_type_id = ct.id;
  
    RETURN v_is_individual;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'У контакта указан не верный тип контакта');
  END get_is_individual;

  PROCEDURE validate_from_mask
  (
    p_value   IN VARCHAR2
   ,p_mask    IN VARCHAR2
   ,p_result  OUT NUMBER
   ,p_err_txt OUT VARCHAR2
  ) IS
    mask_cnt   NUMBER(3);
    is_fm      BOOLEAN := FALSE;
    err_txt    VARCHAR2(255);
    v_tmp      VARCHAR2(1);
    m_tmp      VARCHAR2(1);
    n_tmp      NUMBER(1);
    value_oper VARCHAR2(255);
    mask_oper  VARCHAR2(255);
    my_error EXCEPTION;
  BEGIN
    value_oper := p_value;
    IF p_mask IS NOT NULL
       AND length(p_mask) > 0
    THEN
      IF upper(substr(p_mask, 1, 2)) = 'FM'
      THEN
        mask_oper := upper(substr(p_mask, 3));
        is_fm     := TRUE;
      ELSE
        mask_oper := upper(p_mask);
      END IF;
    
      mask_cnt := length(mask_oper);
    
      --проверка на соответствие символов
      IF is_fm
      THEN
        IF length(p_value) > mask_cnt
        THEN
          p_err_txt := 'Количество символов должно быть не более ' || mask_cnt;
          RAISE my_error;
        END IF;
      
      ELSE
        IF length(p_value) != mask_cnt
        THEN
          p_err_txt := 'Количество символов должно быть равным ' || mask_cnt;
          RAISE my_error;
        END IF;
      END IF;
    
      --dbms_output.PUT_LINE(mask_cnt);
    
      FOR i IN 1 .. mask_cnt
      LOOP
        v_tmp := substr(value_oper, i, 1);
        m_tmp := substr(mask_oper, i, 1);
        --dbms_output.PUT_LINE(i||'.'||v_tmp);
        --dbms_output.PUT_LINE(i||'.'||m_tmp);
        CASE m_tmp
          WHEN 'A' THEN
            BEGIN
              n_tmp := to_number(v_tmp);
              RAISE my_error;
            EXCEPTION
              WHEN value_error THEN
                NULL;
              WHEN my_error THEN
                p_err_txt := 'Введённое значение должно соответствовать маске ''' || mask_oper ||
                             ''',где' || chr(10) || 'X - любые символы,' || chr(10) ||
                             'A - только буквы,' || chr(10) || '0 - только цифры';
                RAISE my_error;
            END;
          WHEN 'X' THEN
            NULL;
          WHEN '0' THEN
            BEGIN
              n_tmp := to_number(v_tmp);
            EXCEPTION
              WHEN value_error THEN
                p_err_txt := 'Введённое значение должно соответствовать маске ''' || mask_oper ||
                             ''',где' || chr(10) || 'X - любые символы,' || chr(10) ||
                             'A - только буквы,' || chr(10) || '0 - только цифры';
                RAISE my_error;
            END;
          WHEN '9' THEN
            BEGIN
              n_tmp := to_number(v_tmp);
            EXCEPTION
              WHEN invalid_number THEN
                p_err_txt := 'Введённое значение должно соответствовать маске ''' || mask_oper ||
                             ''',где' || chr(10) || 'X - любые символы,' || chr(10) ||
                             'A - только буквы,' || chr(10) || '0 - только цифры';
                RAISE my_error;
            END;
          ELSE
            IF v_tmp != m_tmp
            THEN
              p_err_txt := 'Введённое значение должно соответствовать маске ''' || mask_oper ||
                           ''',где' || chr(10) || 'X - любые символы,' || chr(10) ||
                           'A - только буквы,' || chr(10) || '0 - только цифры';
              RAISE my_error;
            END IF;
        END CASE;
      
      END LOOP;
    END IF;
    p_result := 1;
  EXCEPTION
    WHEN my_error THEN
      p_result := 0;
  END validate_from_mask;

  FUNCTION is_unique_contact
  (
    p_contact_id    IN NUMBER
   ,p_is_individual IN NUMBER
   ,p_resident_flag IN NUMBER
   ,p_name          IN VARCHAR2
   ,p_first_name    IN VARCHAR2
   ,p_middle_name   IN VARCHAR2
   ,p_date_of_birth IN DATE
   ,p_id_value      IN VARCHAR2
  ) RETURN NUMBER IS
    cnt NUMBER(3);
  BEGIN
  
    DELETE FROM t_unic_contact;
  
    FOR cur IN (
                
                SELECT c.contact_id cont_id
                       ,c.name contact_name
                       ,c.first_name contact_first_name
                       ,c.middle_name contact_middle_name
                       ,(SELECT per.gender FROM cn_person per WHERE per.contact_id = c.contact_id) contact_gender
                       ,pkg_contact.get_primary_doc(c.contact_id) contact_doc_num
                  FROM ven_contact        c
                       ,ven_t_contact_type ct
                 WHERE c.contact_id IS NULL
                    OR c.contact_id != p_contact_id
                   AND c.contact_type_id = ct.id
                   AND c.name = p_name
                   AND ct.is_individual = p_is_individual
                   AND ((p_is_individual = 1 AND c.first_name = p_first_name AND
                       c.middle_name = p_middle_name AND EXISTS
                        (SELECT 1
                            FROM ven_cn_person vcp
                           WHERE vcp.contact_id = c.contact_id
                             AND vcp.date_of_birth = p_date_of_birth)) OR
                       (p_is_individual = 0 AND
                       ((p_resident_flag = 1 AND c.resident_flag = p_resident_flag AND EXISTS
                        (SELECT 1
                              FROM ven_cn_contact_ident cci
                                  ,ven_t_id_type        it
                             WHERE cci.contact_id = c.contact_id
                               AND cci.id_value = p_id_value
                               AND it.id = cci.id_type
                               AND it.brief = 'INN')) OR p_resident_flag = 0 OR
                       p_resident_flag IS NULL)))
                
                )
    LOOP
    
      INSERT INTO t_unic_contact
        (contact_id, NAME, first_name, middle_name, gender, doc_num)
      VALUES
        (cur.cont_id
        ,cur.contact_first_name
        ,cur.contact_name
        ,cur.contact_middle_name
        ,cur.contact_gender
        ,cur.contact_doc_num);
    
    END LOOP;
  
    SELECT COUNT(*)
      INTO cnt
      FROM ven_contact        c
          ,ven_t_contact_type ct
     WHERE c.contact_id IS NULL
        OR c.contact_id != p_contact_id
       AND c.contact_type_id = ct.id
       AND c.name = p_name
       AND ct.is_individual = p_is_individual
       AND ((p_is_individual = 1 AND c.first_name = p_first_name AND c.middle_name = p_middle_name AND
           EXISTS (SELECT 1
                      FROM ven_cn_person vcp
                     WHERE vcp.contact_id = c.contact_id
                       AND vcp.date_of_birth = p_date_of_birth)) OR
           (p_is_individual = 0 AND
           ((p_resident_flag = 1 AND c.resident_flag = p_resident_flag AND EXISTS
            (SELECT 1
                  FROM ven_cn_contact_ident cci
                      ,ven_t_id_type        it
                 WHERE cci.contact_id = c.contact_id
                   AND cci.id_value = p_id_value
                   AND it.id = cci.id_type
                   AND it.brief = 'INN')) OR p_resident_flag = 0 OR p_resident_flag IS NULL)));
  
    IF cnt = 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 2;
  END is_unique_contact;

  PROCEDURE prepare_for_delete
  (
    p_contact_id IN NUMBER
   ,p_res        OUT NUMBER
   ,p_mess       OUT VARCHAR2
  ) IS
  BEGIN
    p_res := 1;
    FOR cur IN (SELECT ac.table_name
                      ,acc.column_name
                      ,e.name
                      ,coc.comments
                  FROM all_constraints  ac
                      ,all_cons_columns acc
                      ,entity           e
                      ,all_col_comments coc
                 WHERE ac.owner = 'INS'
                   AND ac.constraint_type = 'R'
                   AND ac.r_constraint_name = 'PK_CONTACT'
                   AND ac.status = 'ENABLED'
                   AND acc.constraint_name = ac.constraint_name
                   AND acc.owner = ac.owner
                   AND acc.table_name = ac.table_name
                   AND e.brief = ac.table_name
                   AND coc.owner = ac.owner
                   AND coc.table_name = ac.table_name
                   AND coc.column_name = acc.column_name
                   AND ac.table_name NOT IN ('CN_CONTACT_ROLE'
                                            ,'CN_CONTACT_BANK_ACC'
                                            ,'CN_CONTACT_IDENT'
                                            ,'CN_CONTACT_EMAIL'
                                            ,'CN_CONTACT_TELEPHONE'
                                            ,'CN_CONTACT_ADDRESS'
                                            ,'CN_PERSON'
                                            ,'CN_COMPANY'))
    LOOP
      DECLARE
        res NUMBER := 0;
      BEGIN
        EXECUTE IMMEDIATE 'select count(*) from ' || cur.table_name || ' where ' || cur.column_name || '=' ||
                          p_contact_id
          INTO res;
        IF res > 0
        THEN
          IF p_res = 1
          THEN
            p_mess := 'Контакт не может быть удалён, т.к. привязан к следующим сущностям:';
            p_res  := 0;
          END IF;
          p_mess := p_mess || chr(10) || '- ' || cur.name || ' (' || cur.comments || ', ' ||
                    cur.table_name || ');';
        END IF;
      END;
    END LOOP;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END prepare_for_delete;

  FUNCTION get_contact_kladr(p_contact_id IN NUMBER) RETURN VARCHAR2 IS
    /*p_province NUMBER;
    p_region   NUMBER;
    p_city     NUMBER;
    p_district NUMBER;*/
    p_kladr VARCHAR2(25);
  BEGIN
  
    SELECT a.code /*a.district_id,a.city_id,a.region_id,a.province_id*/
      INTO p_kladr /*p_district, p_city, p_region, p_province*/
      FROM ven_cn_address a
     WHERE a.id = get_primary_address(p_contact_id);
  
    /*IF p_district IS NOT NULL
    THEN
      SELECT d.KLADR_CODE
        INTO p_kladr
        FROM ven_t_district d
       WHERE d.DISTRICT_ID=p_district;
    ELSIF p_city IS NOT NULL
    THEN
      SELECT с.KLADR_CODE
        INTO p_kladr
        FROM ven_t_city с
       WHERE с.city_ID=p_city;
    ELSIF p_region IS NOT NULL
    THEN
      SELECT r.KLADR_CODE
        INTO p_kladr
        FROM ven_t_region r
       WHERE r.region_ID=p_region;
    ELSIF p_province IS NOT NULL
    THEN
      SELECT p.KLADR_CODE
        INTO p_kladr
        FROM ven_t_province p
       WHERE p.province_ID=p_province;
    ELSE RETURN NULL;
    END IF;*/
    RETURN p_kladr;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_contact_kladr;

  FUNCTION get_primary_zip(p_contact_id IN NUMBER) RETURN VARCHAR2 IS
    p_zip VARCHAR2(9);
  BEGIN
    SELECT a.zip INTO p_zip FROM ven_cn_address a WHERE a.id = get_primary_address(p_contact_id);
    RETURN p_zip;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_primary_zip;

  FUNCTION get_brief_contact_type_prior(p_contact_id NUMBER) RETURN VARCHAR2 AS
    buf VARCHAR(2);
  BEGIN
    SELECT brief
      INTO buf
      FROM ven_t_contact_type
     WHERE rownum = 1
       AND brief IN ('ФЛ', 'ЮЛ')
     START WITH id = (SELECT c.contact_type_id FROM contact c WHERE c.contact_id = p_contact_id)
    CONNECT BY id = PRIOR upper_level_id;
    RETURN buf;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN '';
  END get_brief_contact_type_prior;

  FUNCTION get_kladr(par_address IN NUMBER) RETURN VARCHAR2 IS
    ret_val   VARCHAR2(11);
    row_adres ven_cn_address%ROWTYPE;
  BEGIN
    SELECT a.* INTO row_adres FROM ven_cn_address a WHERE a.id = par_address;
  
    /*IF row_adres.district_id IS NOT NULL
    THEN
      SELECT d.KLADR_CODE
        INTO ret_val
        FROM ven_t_district d
       WHERE d.DISTRICT_ID= row_adres.district_id;
    ELSIF row_adres.city_id IS NOT NULL
    THEN
      SELECT с.KLADR_CODE
        INTO ret_val
        FROM ven_t_city с
       WHERE с.city_ID=row_adres.city_id;
    ELSIF row_adres.region_id IS NOT NULL
    THEN
      SELECT r.KLADR_CODE
        INTO ret_val
        FROM ven_t_region r
       WHERE r.region_ID=row_adres.region_id;
    ELSIF row_adres.province_id IS NOT NULL
    THEN
      SELECT p.KLADR_CODE
        INTO ret_val
        FROM ven_t_province p
       WHERE p.province_ID=row_adres.province_id;
    ELSE RETURN NULL;
    END IF;*/
    RETURN ret_val;
  END;

  FUNCTION get_index(par_address IN NUMBER) RETURN VARCHAR2 IS
    row_adres ven_cn_address%ROWTYPE;
  BEGIN
  
    SELECT a.* INTO row_adres FROM ven_cn_address a WHERE a.id = par_address;
  
    RETURN row_adres.zip;
  EXCEPTION
    /*Добавлен обработчик 19.05.2014 Черных М.Г.*/
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_ident_date
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN DATE IS
    p_num DATE;
  BEGIN
    SELECT cci.issue_date
      INTO p_num
      FROM ven_cn_contact_ident cci
      JOIN t_id_type tit
        ON tit.id = cci.id_type
       AND tit.brief LIKE p_id_type_brief
     WHERE cci.contact_id = p_contact_id
       AND rownum = 1;
    RETURN p_num;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_ident_date;

  FUNCTION get_ident_number
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN VARCHAR2 IS
    p_num VARCHAR2(50);
  BEGIN
    SELECT cci.id_value
      INTO p_num
      FROM ven_cn_contact_ident cci
      JOIN t_id_type tit
        ON tit.id = cci.id_type
       AND tit.brief LIKE p_id_type_brief
     WHERE cci.contact_id = p_contact_id
       AND rownum = 1;
    RETURN p_num;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_ident_number;

  FUNCTION get_ident_place
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN VARCHAR2 IS
    p_seria VARCHAR2(255);
  BEGIN
    SELECT cci.place_of_issue
      INTO p_seria
      FROM ven_cn_contact_ident cci
      JOIN t_id_type tit
        ON tit.id = cci.id_type
       AND tit.brief LIKE p_id_type_brief
     WHERE cci.contact_id = p_contact_id
       AND rownum = 1;
    RETURN p_seria;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_ident_place;

  FUNCTION get_ident_seria
  (
    p_contact_id    NUMBER
   ,p_id_type_brief VARCHAR2
  ) RETURN VARCHAR2 IS
    p_seria VARCHAR2(50);
  BEGIN
    SELECT cci.serial_nr
      INTO p_seria
      FROM ven_cn_contact_ident cci
      JOIN t_id_type tit
        ON tit.id = cci.id_type
       AND tit.brief LIKE p_id_type_brief
     WHERE cci.contact_id = p_contact_id
       AND rownum = 1;
    RETURN p_seria;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_ident_seria;

  FUNCTION get_birth_date(p_contact_id IN NUMBER) RETURN DATE AS
    l_buf DATE;
  BEGIN
    SELECT p.date_of_birth INTO l_buf FROM ven_cn_person p WHERE p.contact_id = p_contact_id;
  
    RETURN l_buf;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_birth_date;

  FUNCTION get_phone_number
  (
    p_contact_id           NUMBER
   ,p_telephone_type_brief t_telephone_type.brief%TYPE
  ) RETURN VARCHAR2 IS
    buf NUMBER;
  BEGIN
    SELECT ct.id
      INTO buf
      FROM cn_contact_telephone ct
          ,t_telephone_type     tt
     WHERE ct.telephone_type = tt.id
       AND ct.contact_id = p_contact_id
       AND tt.brief = p_telephone_type_brief
       AND rownum < 2;
  
    RETURN get_telephone(buf);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_phone_number;

  FUNCTION get_citizenry(p_contact_id NUMBER) RETURN VARCHAR2 IS
    buf VARCHAR2(255);
  BEGIN
    SELECT c.description
      INTO buf
      FROM ven_cn_person p
          ,ven_t_country c
     WHERE p.country_birth = c.id
       AND p.contact_id = p_contact_id
       AND rownum = 1;
  
    RETURN buf;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_citizenry;

  FUNCTION get_profession(p_contact_id NUMBER) RETURN VARCHAR2 IS
    buf VARCHAR2(255);
  BEGIN
    SELECT f.description
      INTO buf
      FROM ven_cn_person    p
          ,ven_t_profession f
     WHERE p.profession = f.id
       AND p.contact_id = p_contact_id
       AND rownum = 1;
  
    RETURN buf;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_profession;

  FUNCTION get_standing(p_contact_id NUMBER) RETURN NUMBER IS
    y NUMBER(4);
  BEGIN
    SELECT p.standing INTO y FROM cn_person p WHERE p.contact_id = p_contact_id;
  
    IF y IS NULL
    THEN
      SELECT to_number(to_char(cci.issue_date, 'yyyy'))
        INTO y
        FROM ven_cn_contact_ident cci
        JOIN t_id_type tit
          ON tit.id = cci.id_type
         AND tit.brief LIKE 'VOD_UDOS'
       WHERE cci.contact_id = p_contact_id
         AND rownum = 1;
    END IF;
    RETURN y;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_standing;

  FUNCTION find_person_contact
  (
    p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_last_name       VARCHAR2
   ,p_birth_date      DATE
   ,p_pass_ser        VARCHAR2 DEFAULT NULL
   ,p_pass_num        VARCHAR2 DEFAULT NULL
   ,p_pass_issue_date DATE DEFAULT NULL
   ,p_pass_issued_by  VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_contact_search_name contact.obj_name%TYPE;
    v_person_id           contact.contact_id%TYPE;
  
    FUNCTION get_person_id
    (
      par_search_string   VARCHAR2
     ,par_birth_date      DATE
     ,par_pass_ser        VARCHAR2 DEFAULT NULL
     ,par_pass_num        VARCHAR2 DEFAULT NULL
     ,par_pass_issue_date DATE DEFAULT NULL
    ) RETURN contact.contact_id%TYPE IS
      v_contact_id contact.contact_id%TYPE;
    BEGIN
      IF p_pass_num IS NOT NULL
      THEN
        SELECT p.contact_id
          INTO v_contact_id
          FROM contact   c
              ,cn_person p
         WHERE c.contact_id = p.contact_id
           AND c.obj_name = par_search_string
           AND p.date_of_birth = par_birth_date
           AND EXISTS (SELECT NULL
                  FROM cn_contact_ident ci
                      ,t_id_type        it
                 WHERE ci.contact_id = p.contact_id
                   AND ci.id_type = it.id
                   AND it.brief IN ('PASS_RF', 'PASS_SSSR', 'PASS_IN')
                   AND ci.serial_nr = par_pass_ser
                   AND ci.id_value = par_pass_num
                   AND ci.issue_date = par_pass_issue_date);
      ELSE
        SELECT p.contact_id
          INTO v_contact_id
          FROM contact   c
              ,cn_person p
         WHERE c.contact_id = p.contact_id
           AND c.obj_name = par_search_string
           AND p.date_of_birth = par_birth_date;
      END IF;
      RETURN v_contact_id;
    END get_person_id;
  
  BEGIN
  
    /* 
    Пытаемся определить контакт:
    Сначала ищем по ФИО и дню рождения
    Если нашли несколько - ищем по ФИО, дню рожедния и паспорту
    Если снова нашли несколько - ищем по ФИО, дню рожедния и паспорту и выбираем того, 
         у кого наиболее свежий договор, по которому он является Страхователем
    */
  
    SELECT upper(p_last_name || decode(p_first_name, NULL, '', ' ' || p_first_name) ||
                 decode(p_middle_name, NULL, '', ' ' || p_middle_name))
      INTO v_contact_search_name
      FROM dual;
  
    BEGIN
      IF p_pass_num IS NULL
      THEN
        BEGIN
          v_person_id := get_person_id(par_search_string => v_contact_search_name
                                      ,par_birth_date    => p_birth_date);
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
          WHEN too_many_rows THEN
            raise_application_error(errc_plural_contacts
                                   ,'В системе несколько контактов с одинаковыми ФИО и датой рождения: ' ||
                                    v_contact_search_name);
        END;
      ELSE
        v_person_id := get_person_id(par_search_string   => v_contact_search_name
                                    ,par_birth_date      => p_birth_date
                                    ,par_pass_ser        => p_pass_ser
                                    ,par_pass_num        => p_pass_num
                                    ,par_pass_issue_date => p_pass_issue_date);
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        BEGIN
          SELECT con.contact_id
            INTO v_person_id
            FROM (SELECT p.contact_id
                        ,ph.start_date
                    FROM contact          c
                        ,cn_person        p
                        ,cn_contact_ident ci
                        ,t_id_type        it
                        ,v_pol_issuer     vpi
                        ,p_policy         pp
                        ,p_pol_header     ph
                   WHERE c.contact_id = p.contact_id
                        /*
                        TODO: owner="pavel.kaplya" category="Test" priority="2 - Medium" created="26.10.2013"
                        text="До внедрения механизма интеграции при проверке по паспорту не было проверки по имени и ДР.
                              Возможно это внесет какие-то коррективы в работу поиска"
                        */
                     AND c.obj_name = v_contact_search_name
                     AND p.date_of_birth = p_birth_date
                     AND EXISTS (SELECT NULL
                            FROM cn_contact_ident ci
                                ,t_id_type        it
                           WHERE ci.contact_id = p.contact_id
                             AND ci.id_type = it.id
                             AND it.brief IN ('PASS_RF', 'PASS_SSSR', 'PASS_IN')
                             AND ci.serial_nr = p_pass_ser
                             AND ci.id_value = p_pass_num
                             AND ci.issue_date = p_pass_issue_date)
                     AND vpi.contact_id(+) = c.contact_id
                     AND pp.policy_id(+) = vpi.policy_id
                     AND ph.policy_header_id(+) = pp.pol_header_id
                   ORDER BY ph.start_date DESC) con
           WHERE rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(errc_plural_contacts
                                   ,'В системе несколько контактов с одинаковыми ФИО (' ||
                                    v_contact_search_name ||
                                    '), датой рождения и данными паспорта, но ни один из них не является страхователем в договорах страхвоания');
        END;
    END;
    RETURN v_person_id;
  END find_person_contact;

  FUNCTION create_person_contact
  (
    p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_last_name       VARCHAR2
   ,p_birth_date      DATE
   ,p_gender          VARCHAR2
   ,p_pass_ser        VARCHAR2 DEFAULT NULL
   ,p_pass_num        VARCHAR2 DEFAULT NULL
   ,p_pass_issue_date DATE DEFAULT NULL
   ,p_pass_issued_by  VARCHAR2 DEFAULT NULL
   ,p_country_id      NUMBER DEFAULT NULL
   ,p_note            VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_contact_search_name VARCHAR2(4000);
    v_person_id           NUMBER;
    v_ct_id               NUMBER;
    v_contact_status_id   NUMBER;
    v_gender_id           NUMBER;
    v_country_id          NUMBER;
    v_doc_type_id         NUMBER;
    v_ident_doc_id        NUMBER;
  BEGIN
  
    assert_deprecated(par_condition => p_birth_date IS NULL
          ,par_msg       => 'Не задан день рождения контакта');
    assert_deprecated(par_condition => p_gender IS NULL, par_msg => 'Не задан пол контакта');
  
    v_person_id := find_person_contact(p_first_name      => p_first_name
                                      ,p_middle_name     => p_middle_name
                                      ,p_last_name       => p_last_name
                                      ,p_birth_date      => p_birth_date
                                      ,p_pass_ser        => p_pass_ser
                                      ,p_pass_num        => p_pass_num
                                      ,p_pass_issue_date => p_pass_issue_date
                                      ,p_pass_issued_by  => p_pass_issued_by);
    -- TODO: Если контакт найден, обновить его данные
  
    IF v_person_id IS NOT NULL
    THEN
    
      IF p_pass_num IS NOT NULL
      THEN
        BEGIN
          SELECT ci.table_id
            INTO v_ident_doc_id
            FROM cn_contact_ident ci
                ,t_id_type        it
           WHERE ci.contact_id = v_person_id
             AND ci.id_type = it.id
             AND it.brief IN ('PASS_RF', 'PASS_SSSR', 'PASS_IN')
             AND ci.serial_nr = p_pass_ser
             AND decode(ci.id_value, p_pass_num, 1, 0) = 1
             AND decode(ci.issue_date, p_pass_issue_date, 1, 0) = 1;
        EXCEPTION
          WHEN no_data_found THEN
          
            SELECT id INTO v_doc_type_id FROM t_id_type WHERE brief = 'PASS_RF';
          
            v_ident_doc_id := create_ident_document(par_contact_id    => v_person_id
                                                   ,par_ident_type_id => v_doc_type_id
                                                   ,par_value         => p_pass_num
                                                   ,par_series        => p_pass_ser
                                                   ,par_issue_date    => p_pass_issue_date
                                                   ,par_issue_place   => p_pass_issued_by
                                                   ,par_country_id    => p_country_id
                                                   ,par_is_used       => 1
                                                   ,par_is_default    => 1);
          WHEN too_many_rows THEN
            NULL;
        END;
      END IF;
    
      RETURN v_person_id;
    ELSE
      SELECT sq_contact.nextval INTO v_person_id FROM dual;
    END IF;
  
    -- Получаю данные справочников: Тип контакта, статус контакта, пол, страна, тип документа
  
    SELECT id
      INTO v_ct_id
      FROM (SELECT id
              FROM t_contact_type
             WHERE brief = 'ФЛ'
               AND upper_level_id IS NOT NULL)
     WHERE rownum < 2;
  
    SELECT t_contact_status_id
      INTO v_contact_status_id
      FROM t_contact_status
     WHERE NAME = 'Обычный';
  
    v_gender_id := get_gender_id_by_brief(p_gender);
  
    INSERT INTO ven_cn_person
      (contact_id
      ,date_of_birth
      ,gender
      ,NAME
      ,first_name
      ,middle_name
      ,contact_type_id
      ,t_contact_status_id
      ,note)
    VALUES
      (v_person_id
      ,p_birth_date
      ,v_gender_id
      ,p_last_name
      ,p_first_name
      ,p_middle_name
      ,v_ct_id
      ,v_contact_status_id
      ,p_note);
  
    IF p_pass_ser IS NOT NULL
       OR p_pass_num IS NOT NULL
    THEN
      SELECT id INTO v_doc_type_id FROM t_id_type WHERE brief = 'PASS_RF';
    
      v_ident_doc_id := create_ident_document(par_contact_id    => v_person_id
                                             ,par_ident_type_id => v_doc_type_id
                                             ,par_value         => p_pass_num
                                             ,par_series        => p_pass_ser
                                             ,par_issue_date    => p_pass_issue_date
                                             ,par_issue_place   => p_pass_issued_by
                                             ,par_country_id    => p_country_id
                                             ,par_is_used       => 1
                                             ,par_is_default    => 1);
    END IF;
  
    RETURN v_person_id;
  END;

  PROCEDURE cancel_check_owner(p_doc_id NUMBER) IS
    p_bank_acc_id NUMBER;
  BEGIN
  
    BEGIN
      SELECT d.cn_contact_bank_acc_id
        INTO p_bank_acc_id
        FROM cn_document_bank_acc d
       WHERE d.cn_document_bank_acc_id = p_doc_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_bank_acc_id := 0;
    END;
  
    UPDATE cn_contact_bank_acc ac
       SET ac.is_check_owner   = 0
          ,ac.owner_contact_id = NULL
     WHERE ac.id = p_bank_acc_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20100
                             ,'Ошибка выполнения процедуры cancel_payment');
  END;

  PROCEDURE check_add_contact_role
  (
    p_contact_id NUMBER
   ,p_role_id    NUMBER
  ) IS
    v_role_brief      VARCHAR2(100);
    v_contact_role_id NUMBER;
  BEGIN
    SELECT brief INTO v_role_brief FROM t_contact_pol_role WHERE id = p_role_id;
  
    CASE v_role_brief
      WHEN 'Страхователь' THEN
        v_contact_role_id := v_issuer_contact_role_id;
      WHEN 'Выгодоприобретатель' THEN
        v_contact_role_id := v_benef_contact_role_id;
      WHEN 'Застрахованное лицо' THEN
        v_contact_role_id := v_assured_contact_role_id;
      ELSE
        NULL;
    END CASE;
  
    IF v_contact_role_id IS NOT NULL
    THEN
      BEGIN
        SELECT role_id
          INTO v_contact_role_id
          FROM cn_contact_role
         WHERE contact_id = p_contact_id
           AND role_id = v_contact_role_id;
      EXCEPTION
        WHEN no_data_found THEN
          INSERT INTO ven_cn_contact_role
            (role_id, contact_id)
          VALUES
            (v_contact_role_id, p_contact_id);
        
        WHEN too_many_rows THEN
          DELETE FROM ven_cn_contact_role
           WHERE contact_id = p_contact_id
             AND role_id = v_contact_role_id
             AND id <> (SELECT MIN(id)
                          FROM cn_contact_role
                         WHERE contact_id = p_contact_id
                           AND role_id = v_contact_role_id);
      END;
    END IF;
  END;

  PROCEDURE check_contact_role
  (
    p_contact_id NUMBER
   ,p_role_brief VARCHAR2
  ) IS
    v_role_id         NUMBER;
    v_contact_role_id NUMBER;
  BEGIN
    SELECT id INTO v_role_id FROM t_contact_role WHERE brief = p_role_brief;
    BEGIN
      SELECT role_id
        INTO v_contact_role_id
        FROM cn_contact_role
       WHERE contact_id = p_contact_id
         AND role_id = v_role_id;
    EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO ven_cn_contact_role (role_id, contact_id) VALUES (v_role_id, p_contact_id);
      WHEN too_many_rows THEN
        DELETE FROM ven_cn_contact_role
         WHERE contact_id = p_contact_id
           AND role_id = v_role_id
           AND id <> (SELECT MIN(id)
                        FROM cn_contact_role
                       WHERE contact_id = p_contact_id
                         AND role_id = v_role_id);
    END;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20100, 'Не найдена заданная роль');
  END;

  PROCEDURE check_add_agent_role(p_contact_id NUMBER) IS
    v_role_id         NUMBER;
    v_rez             NUMBER := 0;
    v_contact_role_id NUMBER;
  BEGIN
  
    SELECT t.id INTO v_role_id FROM ven_t_contact_role t WHERE t.brief = 'AGENT';
  
    BEGIN
      SELECT role_id
        INTO v_contact_role_id
        FROM ven_cn_contact_role cr
       WHERE cr.contact_id = p_contact_id
         AND cr.role_id = v_role_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO ven_cn_contact_role (contact_id, role_id) VALUES (p_contact_id, v_role_id);
      WHEN OTHERS THEN
        NULL;
    END;
  
  END;

  FUNCTION get_rekv
  (
    p_contact_id NUMBER
   ,p_inn        NUMBER DEFAULT 1
   ,p_okpo       NUMBER DEFAULT 1
   ,p_kpp        NUMBER DEFAULT 1
   ,p_okfs       NUMBER DEFAULT 1
   ,p_okopf      NUMBER DEFAULT 1
   ,p_okato      NUMBER DEFAULT 1
   ,p_okogu      NUMBER DEFAULT 1
   ,p_okved      NUMBER DEFAULT 1
   ,p_rs         NUMBER DEFAULT 1
   ,p_ks         NUMBER DEFAULT 1
   ,p_bik        NUMBER DEFAULT 1
  ) RETURN VARCHAR2 IS
    v_str VARCHAR2(32000);
    v_tmp VARCHAR2(32000);
  BEGIN
    IF p_inn = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'INN') ||
               pkg_contact.get_ident_number(p_contact_id, 'INN');
      SELECT nvl2(v_tmp, 'ИНН ' || v_tmp, v_str) INTO v_str FROM dual;
      v_tmp := NULL;
    END IF;
  
    IF p_okpo = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'OKPO') ||
               pkg_contact.get_ident_number(p_contact_id, 'OKPO');
      SELECT nvl2(v_tmp
                 ,nvl2(v_str, v_str || ', ' || 'ОКПО ' || v_tmp, 'ОКПО ' || v_tmp)
                 ,v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    IF p_kpp = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'KPP') ||
               pkg_contact.get_ident_number(p_contact_id, 'KPP');
      SELECT nvl2(v_tmp, nvl2(v_str, v_str || ', ' || 'КПП ' || v_tmp, 'КПП ' || v_tmp), v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    /*консультация*/
    IF p_okfs = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'OKFS') ||
               pkg_contact.get_ident_number(p_contact_id, 'OKFS');
      SELECT nvl2(v_tmp
                 ,nvl2(v_str, v_str || ', ' || 'ОКФС ' || v_tmp, 'ОКФС ' || v_tmp)
                 ,v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    IF p_okopf = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'OKOPF') ||
               pkg_contact.get_ident_number(p_contact_id, 'OKOPF');
      SELECT nvl2(v_tmp
                 ,nvl2(v_str, v_str || ', ' || 'ОКОПФ ' || v_tmp, 'ОКОПФ ' || v_tmp)
                 ,v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    IF p_okato = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'OKATO') ||
               pkg_contact.get_ident_number(p_contact_id, 'OKATO');
      SELECT nvl2(v_tmp
                 ,nvl2(v_str, v_str || ', ' || 'ОКАТО ' || v_tmp, 'ОКАТО ' || v_tmp)
                 ,v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    IF p_okogu = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'OKOGU') ||
               pkg_contact.get_ident_number(p_contact_id, 'OKOGU');
      SELECT nvl2(v_tmp
                 ,nvl2(v_str, v_str || ', ' || 'ОКОГУ ' || v_tmp, 'ОКОГУ ' || v_tmp)
                 ,v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    IF p_okved = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'OKVED') ||
               pkg_contact.get_ident_number(p_contact_id, 'OKVED');
      SELECT nvl2(v_tmp
                 ,nvl2(v_str, v_str || ', ' || 'ОКВЭД ' || v_tmp, 'ОКВЭД ' || v_tmp)
                 ,v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
    /*Консультация*/
  
    IF p_rs = 1
    THEN
      FOR rec_bank IN (SELECT * FROM ven_cn_contact_bank_acc cba WHERE cba.contact_id = p_contact_id)
      LOOP
        v_tmp := 'р/счёт ' || rec_bank.account_nr || ' в ' || rec_bank.bank_name;
        IF rec_bank.account_corr IS NOT NULL
        THEN
          v_tmp := v_tmp || ' к/с ' || rec_bank.account_corr;
        END IF;
        IF v_str IS NOT NULL
        THEN
          v_str := v_str || ', ' || v_tmp;
        ELSE
          v_str := v_tmp;
        END IF;
      END LOOP;
      v_tmp := NULL;
    END IF;
  
    IF p_bik = 1
    THEN
      v_tmp := pkg_contact.get_ident_seria(p_contact_id, 'BIK') ||
               pkg_contact.get_ident_number(p_contact_id, 'BIK');
      SELECT nvl2(v_tmp, nvl2(v_str, v_str || ', ' || 'БИК ' || v_tmp, 'БИК ' || v_tmp), v_str)
        INTO v_str
        FROM dual;
      v_tmp := NULL;
    END IF;
  
    RETURN v_str;
  END;

  FUNCTION get_emales(p_contact_id NUMBER) RETURN VARCHAR2 IS
    v_str VARCHAR2(32000);
  BEGIN
    FOR rec_mail IN (SELECT *
                       FROM ven_cn_contact_email cce
                       JOIN ven_t_email_type tet
                         ON tet.id = cce.email_type
                      WHERE cce.contact_id = p_contact_id
                      ORDER BY tet.sort_order)
    LOOP
      IF v_str IS NULL
      THEN
        v_str := rec_mail.email;
      ELSE
        v_str := v_str || ', ' || rec_mail.email;
      END IF;
    END LOOP;
    RETURN v_str;
  END;

  FUNCTION get_phones(p_contact_id NUMBER) RETURN VARCHAR2 IS
    v_str VARCHAR2(32000);
  BEGIN
    FOR rec_phones IN (SELECT *
                         FROM ven_cn_contact_telephone ct
                         JOIN ven_t_telephone_type tt
                           ON tt.id = ct.telephone_type
                          AND tt.brief IN ('T1', 'T2', 'T3', 'T4')
                        WHERE ct.contact_id = p_contact_id
                        ORDER BY tt.sort_order)
    LOOP
      IF v_str IS NULL
      THEN
        v_str := rec_phones.telephone_number;
      ELSE
        v_str := v_str || ', ' || rec_phones.telephone_number;
      END IF;
    END LOOP;
    RETURN v_str;
  END;

  FUNCTION get_post
  (
    p_contact_id NUMBER
   ,p_padezh     VARCHAR2
  ) RETURN VARCHAR2 IS
    v_post VARCHAR2(500);
  BEGIN
    BEGIN
      SELECT post
        INTO v_post
        FROM (SELECT *
                FROM (SELECT p.contact_id
                            ,pkg_utils.post_declination(p.post, p_padezh) post
                        FROM ven_cn_person p
                      UNION ALL
                      SELECT contact_id
                            ,pkg_utils.post_declination(appointment, p_padezh) || ' ' ||
                             lower(substr(dep_name, 1, 1)) || substr(dep_name, 2) post
                        FROM (SELECT e.contact_id
                                    ,eh.appointment
                                    ,pkg_utils.post_declination(decode(substr(NAME
                                                                             ,1
                                                                             ,instr(NAME, ' ') - 1)
                                                                      ,code
                                                                      ,substr(NAME, instr(NAME, ' ') + 1)
                                                                      ,NAME)
                                                               ,'Р') dep_name
                                    ,d.code
                                FROM ven_employee_hist eh
                                    ,ven_employee      e
                                    ,ven_department    d
                               WHERE e.employee_id = eh.employee_id
                                 AND d.department_id = eh.department_id))
               WHERE contact_id = p_contact_id
                 AND post IS NOT NULL)
       WHERE rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        v_post := NULL;
    END;
    RETURN v_post;
  END;

  FUNCTION check_department
  (
    p_contact_id NUMBER
   ,p_policy_id  NUMBER
   ,p_dep_id     NUMBER
  ) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    SELECT 1
      INTO v_res
      FROM dual
     WHERE p_dep_id IN (SELECT eh.department_id
                          FROM p_policy_contact   pc
                              ,t_contact_pol_role cpr
                              ,contact            c
                              ,employee           e
                              ,employee_hist      eh
                         WHERE cpr.brief = 'Куратор'
                           AND cpr.id = pc.contact_policy_role_id
                           AND c.contact_id = pc.contact_id
                           AND e.contact_id = p_contact_id
                           AND eh.employee_id = e.employee_id
                           AND pc.policy_id = p_policy_id
                           AND eh.date_hist = (SELECT MAX(ehlast.date_hist)
                                                 FROM employee_hist ehlast
                                                WHERE ehlast.employee_id = e.employee_id
                                                  AND ehlast.date_hist <= SYSDATE
                                                  AND ehlast.is_kicked = 0));
    RETURN v_res;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  FUNCTION check_control_account
  (
    p_bank_contact_id NUMBER
   ,p_num_account     VARCHAR2
  ) RETURN VARCHAR2 IS
    v_res         VARCHAR2(2);
    v_koef        VARCHAR2(23) := '71371371371371371371371';
    v_id_value    VARCHAR2(30);
    p_bik         VARCHAR2(3);
    p_4           NUMBER;
    v_num_account VARCHAR2(20);
    v_first_twenty_characters VARCHAR2(20);
  BEGIN
  
    BEGIN
      SELECT cci.id_value
        INTO v_id_value
        FROM cn_contact_ident cci
            ,t_id_type        idb
       WHERE 1 = 1
         AND cci.contact_id = p_bank_contact_id --837782
         AND cci.id_type = idb.id
         AND idb.brief = 'BIK'
         AND rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_id_value := 'X';
    END;
  
    IF v_id_value <> 'X'
    THEN
      SELECT substr(v_id_value, 7, 3) INTO p_bik FROM dual;
    ELSE
      RETURN 'X';
    END IF;
  
    /*Заявка 351037 проверять контрольное число по первым 20 символам, т.к. может быть 12345678901234567890/20 например
     01.10.2014 Черных М.
    */
    v_first_twenty_characters := substr(p_num_account, 1, 20);

    IF length(v_first_twenty_characters) = 20
    THEN
      v_num_account := substr(v_first_twenty_characters, 1, 8) || '0' ||
                       substr(v_first_twenty_characters, 10, 20);
      SELECT substr(substr(v_koef, 1, 1) * substr(p_bik, 1, 1)
                   ,length(substr(v_koef, 1, 1) * substr(p_bik, 1, 1))
                   ,1) + substr(substr(v_koef, 2, 1) * substr(p_bik, 2, 1)
                               ,length(substr(v_koef, 2, 1) * substr(p_bik, 2, 1))
                               ,1) + substr(substr(v_koef, 3, 1) * substr(p_bik, 3, 1)
                                           ,length(substr(v_koef, 3, 1) * substr(p_bik, 3, 1))
                                           ,1) +
             substr(substr(v_koef, 4, 1) * substr(v_num_account, 1, 1)
                   ,length(substr(v_koef, 4, 1) * substr(v_num_account, 1, 1))
                   ,1) + substr(substr(v_koef, 5, 1) * substr(v_num_account, 2, 1)
                               ,length(substr(v_koef, 5, 1) * substr(v_num_account, 2, 1))
                               ,1) + substr(substr(v_koef, 6, 1) * substr(v_num_account, 3, 1)
                                           ,length(substr(v_koef, 6, 1) * substr(v_num_account, 3, 1))
                                           ,1) +
             substr(substr(v_koef, 7, 1) * substr(v_num_account, 4, 1)
                   ,length(substr(v_koef, 7, 1) * substr(v_num_account, 4, 1))
                   ,1) + substr(substr(v_koef, 8, 1) * substr(v_num_account, 5, 1)
                               ,length(substr(v_koef, 8, 1) * substr(v_num_account, 5, 1))
                               ,1) + substr(substr(v_koef, 9, 1) * substr(v_num_account, 6, 1)
                                           ,length(substr(v_koef, 9, 1) * substr(v_num_account, 6, 1))
                                           ,1) +
             substr(substr(v_koef, 10, 1) * substr(v_num_account, 7, 1)
                   ,length(substr(v_koef, 10, 1) * substr(v_num_account, 7, 1))
                   ,1) + substr(substr(v_koef, 11, 1) * substr(v_num_account, 8, 1)
                               ,length(substr(v_koef, 11, 1) * substr(v_num_account, 8, 1))
                               ,1) + substr(substr(v_koef, 12, 1) * substr(v_num_account, 9, 1)
                                           ,length(substr(v_koef, 12, 1) * substr(v_num_account, 9, 1))
                                           ,1) +
             substr(substr(v_koef, 13, 1) * substr(v_num_account, 10, 1)
                   ,length(substr(v_koef, 13, 1) * substr(v_num_account, 10, 1))
                   ,1) + substr(substr(v_koef, 14, 1) * substr(v_num_account, 11, 1)
                               ,length(substr(v_koef, 14, 1) * substr(v_num_account, 11, 1))
                               ,1) +
             substr(substr(v_koef, 15, 1) * substr(v_num_account, 12, 1)
                   ,length(substr(v_koef, 15, 1) * substr(v_num_account, 12, 1))
                   ,1) + substr(substr(v_koef, 16, 1) * substr(v_num_account, 13, 1)
                               ,length(substr(v_koef, 16, 1) * substr(v_num_account, 13, 1))
                               ,1) +
             substr(substr(v_koef, 17, 1) * substr(v_num_account, 14, 1)
                   ,length(substr(v_koef, 17, 1) * substr(v_num_account, 14, 1))
                   ,1) + substr(substr(v_koef, 18, 1) * substr(v_num_account, 15, 1)
                               ,length(substr(v_koef, 18, 1) * substr(v_num_account, 15, 1))
                               ,1) +
             substr(substr(v_koef, 19, 1) * substr(v_num_account, 16, 1)
                   ,length(substr(v_koef, 19, 1) * substr(v_num_account, 16, 1))
                   ,1) + substr(substr(v_koef, 20, 1) * substr(v_num_account, 17, 1)
                               ,length(substr(v_koef, 20, 1) * substr(v_num_account, 17, 1))
                               ,1) +
             substr(substr(v_koef, 21, 1) * substr(v_num_account, 18, 1)
                   ,length(substr(v_koef, 21, 1) * substr(v_num_account, 18, 1))
                   ,1) + substr(substr(v_koef, 22, 1) * substr(v_num_account, 19, 1)
                               ,length(substr(v_koef, 22, 1) * substr(v_num_account, 19, 1))
                               ,1) +
             substr(substr(v_koef, 23, 1) * substr(v_num_account, 20, 1)
                   ,length(substr(v_koef, 23, 1) * substr(v_num_account, 20, 1))
                   ,1)
        INTO p_4
        FROM dual;
    
      /*SELECT
      SUBSTR(SUBSTR(TO_CHAR(p_4),LENGTH(TO_CHAR(p_4)),1),LENGTH(SUBSTR(TO_CHAR(p_4),LENGTH(TO_CHAR(p_4)),1)),1)
      INTO v_res
      FROM DUAL;*/
    
      SELECT substr(to_char(to_number(substr(to_char(p_4), length(to_char(p_4)), 1)) * 3)
                   ,length(to_char(to_number(substr(to_char(p_4), length(to_char(p_4)), 1)) * 3))
                   ,1)
        INTO v_res
        FROM dual;
    
    ELSE
      RETURN 'X';
    END IF;
  
    RETURN v_res;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'X';
  END;

  /*
    Байтин А.
    Осуществление проверок расчетного счета
  
    Возвращает два параметра:
    par_can_continue: true - можно продолжать с выводом предупреждения в случае наличия сообщения, false - нельзя продолжать
    par_error_message - сообщение, в случае ошибки
  */
  PROCEDURE check_account_nr
  (
    par_account_nr    VARCHAR2
   ,par_bank_id       NUMBER
   ,par_can_continue  OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  ) IS
    v_have_right NUMBER(1);
    v_cnt        NUMBER(1);
  BEGIN
    par_can_continue := TRUE;
    v_have_right     := safety.check_right_custom('PAYM_DETAIL_WITHOUT_RESTRICTION');
  
    -- Проверка на количество символов
    IF /*length(par_account_nr) != 20*/
     NOT is_account_nr_correct(par_account_nr)
    THEN
      IF v_have_right = 0
      THEN
        par_error_message := 'Количество цифр в расчетном счете должно быть равным 20 или 20 цифр / символы';
        par_can_continue  := FALSE;
      ELSE
        par_error_message := 'Количество цифр в расчетном счете должно быть равным 20 или 20 цифр / символы';
        par_can_continue  := TRUE;
      END IF;
    END IF;
  
    IF par_can_continue
       AND v_have_right = 0
    THEN
      /*      -- Проверка на наличие символов, не являющихся цифрами
      IF regexp_like(par_account_nr, '\D')
      THEN
        par_error_message := 'Введённое значение расчетного счета должно состоять только из цифр';
        par_can_continue  := FALSE;
      END IF;
      */
      IF par_can_continue
         AND substr(par_account_nr, 6, 3) NOT IN ('810', '643')
      THEN
        par_error_message := 'Валюта расчетного счета - начиная с шестого три символа: возможны 810 или 643.';
        par_can_continue  := FALSE;
      END IF;
    END IF;
  
    IF par_can_continue
    THEN
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM t_desc_account da
               WHERE da.num_account = substr(par_account_nr, 1, 5)
                 AND da.state_account = 'Активный'
                 AND da.type_account = 1);
      IF v_cnt = 0
      THEN
        IF v_have_right = 0
        THEN
          par_error_message := 'Номер расчетного счета - начиная с первого пять символов: значения ' ||
                               substr(par_account_nr, 1, 5) || ' нет в справочнике счетов.';
          par_can_continue  := FALSE;
        ELSE
          par_error_message := 'Номер расчетного счета - начиная с первого пять символов: значения ' ||
                               substr(par_account_nr, 1, 5) || ' нет в справочнике счетов.';
          par_can_continue  := TRUE;
        END IF;
      END IF;
    END IF;
  
    IF par_can_continue
       AND
       pkg_contact.check_control_account(par_bank_id, par_account_nr) != substr(par_account_nr, 9, 1)
    THEN
      IF v_have_right = 0
      THEN
        par_error_message := 'Контрольное число расчетного счета - начиная с девятого один символ: значение ' ||
                             substr(par_account_nr, 9, 1) || ' не является контрольным.';
        par_can_continue  := FALSE;
      ELSE
        par_error_message := 'Контрольное число расчетного счета - начиная с девятого один символ: значение ' ||
                             substr(par_account_nr, 9, 1) || ' не является контрольным.';
        par_can_continue  := TRUE;
      END IF;
    END IF;
  END check_account_nr;

  /*
    Байтин А.
    
    Проверка расчетного счета по методике для РКЦ
  */
  PROCEDURE check_account_nr_rkc
  (
    par_account       VARCHAR2
   ,par_bik           VARCHAR2
   ,par_can_continue  OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  ) IS
  
    v_current_number NUMBER(2);
    v_result_sum     NUMBER(3) := 0;
    v_rcc            VARCHAR2(3);
    v_new_account    VARCHAR2(23);
  BEGIN
    par_can_continue := FALSE;
    IF regexp_like(par_account, '^\d+$')
       OR regexp_like(par_bik, '^\d+$')
    THEN
      IF length(par_account) != 20
      THEN
        par_can_continue  := TRUE;
        par_error_message := 'Количество символов в расчетном счете должно быть равным 20';
      ELSIF length(par_bik) != 9
      THEN
        par_can_continue  := TRUE;
        par_error_message := 'Количество символов в БИК должно быть равным 9';
      ELSE
        --1. Выделяется  условный  номер  РКЦ - 005 (5 - 6 разряды БИК, дополненные слева нулем).
        v_rcc := '0' || substr(par_bik, 5, 2);
        --2. В номере лицевого счета приравнивается нулю значение контрольного ключа (К = 0) - девятый символ.
        v_new_account := v_rcc || substr(par_account, 1, 8) || '0' || substr(par_account, 10);
        --3. Определяется произведение каждого разряда условного номера РКЦ и номера лицевого счета на соответствующий весовой коэффициент.
        FOR i IN 1 .. length(v_new_account)
        LOOP
          v_current_number := to_number(substr(v_new_account, i, 1));
          IF MOD(i + 1, 3) = 0
          THEN
            --v_current_number := v_current_number * 1;
            NULL;
          ELSIF MOD(i, 3) = 0
          THEN
            v_current_number := v_current_number * 3;
          ELSE
            v_current_number := v_current_number * 7;
          END IF;
          --4. Вычисляется сумма младших разрядов полученных произведений
          v_result_sum := v_result_sum + to_number(substr(to_char(v_current_number), -1, 1));
        END LOOP;
        --5. Младший разряд вычисленной суммы умножается на 3
        v_result_sum := to_number(substr(to_char(v_result_sum), -1, 1)) * 3;
        --Младший разряд полученного произведения принимается в качестве значения контрольного ключа.
        v_new_account := substr(par_account, 1, 8) || substr(to_char(v_result_sum), -1, 1) ||
                         substr(par_account, 10);
        IF v_new_account != par_account
        THEN
          par_can_continue  := TRUE;
          par_error_message := 'Контрольное число расчетного счета введено неправильно!';
        END IF;
      END IF;
    ELSE
      par_can_continue  := TRUE;
      par_error_message := 'Расчетный счет и БИК должны состоять только из цифр';
    END IF;
  END check_account_nr_rkc;

  /*
    Байтин А.
  
    Добавление расчетного счета
  */
  PROCEDURE insert_account_nr
  (
    par_account_corr             VARCHAR2
   ,par_account_nr               VARCHAR2
   ,par_bank_account_currency_id NUMBER
   ,par_bank_approval_date       DATE
   ,par_bank_approval_end_date   DATE
   ,par_bank_approval_reference  VARCHAR2
   ,par_bank_id                  NUMBER
   ,par_bank_name                VARCHAR2
   ,par_bic_code                 VARCHAR2
   ,par_branch_id                NUMBER
   ,par_branch_name              VARCHAR2
   ,par_contact_id               NUMBER
   ,par_country_id               NUMBER
   ,par_iban_reference           VARCHAR2
   ,par_is_check_owner           NUMBER
   ,par_lic_code                 VARCHAR2
   ,par_order_number             NUMBER
   ,par_owner_contact_id         NUMBER
   ,par_remarks                  VARCHAR2
   ,par_swift_code               VARCHAR2
   ,par_used_flag                NUMBER
   ,par_cn_contact_bank_acc_id   IN OUT NUMBER
   ,par_cn_document_bank_acc_id  OUT NUMBER
  ) IS
    PROCEDURE uniсity_check
    (
      par_contact_id   NUMBER
     ,par_bank_id      NUMBER
     ,par_lic_code     VARCHAR2
     ,par_account_corr VARCHAR2
    ) IS
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
                 AND bac.bank_id = par_bank_id
                 AND bac.account_nr = par_account_nr
                 AND (bac.lic_code = par_lic_code OR bac.account_corr = par_account_corr)
                 AND bac.id = dac.cn_contact_bank_acc_id
                 AND dac.cn_document_bank_acc_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.name != 'CANCEL');
      IF v_is_exists = 1
      THEN
        ex.raise(par_message => 'Нарушение уникальности: банк, номер счета, лицевой счет / банковская карта'
                ,par_sqlcode => ex.c_too_many_rows);
      END IF;
    END uniсity_check;
  BEGIN
  
    uniсity_check(par_contact_id   => par_contact_id
                 ,par_bank_id      => par_bank_id
                 ,par_lic_code     => par_lic_code
                 ,par_account_corr => par_account_corr);
  
    IF par_cn_contact_bank_acc_id IS NULL
    THEN
      SELECT sq_cn_contact_bank_acc.nextval INTO par_cn_contact_bank_acc_id FROM dual;
    END IF;
    INSERT INTO ven_cn_contact_bank_acc
      (id
      ,account_corr
      ,account_nr
      ,bank_account_currency_id
      ,bank_approval_date
      ,bank_approval_end_date
      ,bank_approval_reference
      ,bank_id
      ,bank_name
      ,bic_code
      ,branch_id
      ,branch_name
      ,contact_id
      ,country_id
      ,iban_reference
      ,is_check_owner
      ,lic_code
      ,order_number
      ,owner_contact_id
      ,remarks
      ,swift_code
      ,used_flag)
    VALUES
      (par_cn_contact_bank_acc_id
      ,par_account_corr
      ,par_account_nr
      ,par_bank_account_currency_id
      ,par_bank_approval_date
      ,par_bank_approval_end_date
      ,par_bank_approval_reference
      ,par_bank_id
      ,par_bank_name
      ,par_bic_code
      ,par_branch_id
      ,par_branch_name
      ,par_contact_id
      ,par_country_id
      ,par_iban_reference
      ,par_is_check_owner
      ,par_lic_code
      ,par_order_number
      ,par_owner_contact_id
      ,par_remarks
      ,par_swift_code
      ,par_used_flag);
  
    SELECT sq_document.nextval INTO par_cn_document_bank_acc_id FROM dual;
  
    INSERT INTO ven_cn_document_bank_acc
      (cn_document_bank_acc_id, cn_contact_bank_acc_id)
    VALUES
      (par_cn_document_bank_acc_id, par_cn_contact_bank_acc_id);
  
    doc.set_doc_status(par_cn_document_bank_acc_id, 'PROJECT');
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_account_nr;

  FUNCTION check_control_corr
  (
    p_bank_bik    VARCHAR2
   ,p_num_account VARCHAR2
  ) RETURN VARCHAR2 IS
    v_res         VARCHAR2(2);
    v_koef        VARCHAR2(23) := '71371371371371371371371';
    v_id_value    VARCHAR2(30);
    p_bik         VARCHAR2(3);
    p_4           NUMBER;
    v_num_account VARCHAR2(20);
  BEGIN
  
    BEGIN
      SELECT '0' || substr(p_bank_bik, 5, 2) INTO p_bik FROM dual;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 'X';
    END;
  
    IF length(p_num_account) = 20
    THEN
      v_num_account := substr(p_num_account, 1, 8) || '0' || substr(p_num_account, 10, 20);
      SELECT substr(substr(v_koef, 1, 1) * substr(p_bik, 1, 1)
                   ,length(substr(v_koef, 1, 1) * substr(p_bik, 1, 1))
                   ,1) + substr(substr(v_koef, 2, 1) * substr(p_bik, 2, 1)
                               ,length(substr(v_koef, 2, 1) * substr(p_bik, 2, 1))
                               ,1) + substr(substr(v_koef, 3, 1) * substr(p_bik, 3, 1)
                                           ,length(substr(v_koef, 3, 1) * substr(p_bik, 3, 1))
                                           ,1) +
             substr(substr(v_koef, 4, 1) * substr(v_num_account, 1, 1)
                   ,length(substr(v_koef, 4, 1) * substr(v_num_account, 1, 1))
                   ,1) + substr(substr(v_koef, 5, 1) * substr(v_num_account, 2, 1)
                               ,length(substr(v_koef, 5, 1) * substr(v_num_account, 2, 1))
                               ,1) + substr(substr(v_koef, 6, 1) * substr(v_num_account, 3, 1)
                                           ,length(substr(v_koef, 6, 1) * substr(v_num_account, 3, 1))
                                           ,1) +
             substr(substr(v_koef, 7, 1) * substr(v_num_account, 4, 1)
                   ,length(substr(v_koef, 7, 1) * substr(v_num_account, 4, 1))
                   ,1) + substr(substr(v_koef, 8, 1) * substr(v_num_account, 5, 1)
                               ,length(substr(v_koef, 8, 1) * substr(v_num_account, 5, 1))
                               ,1) + substr(substr(v_koef, 9, 1) * substr(v_num_account, 6, 1)
                                           ,length(substr(v_koef, 9, 1) * substr(v_num_account, 6, 1))
                                           ,1) +
             substr(substr(v_koef, 10, 1) * substr(v_num_account, 7, 1)
                   ,length(substr(v_koef, 10, 1) * substr(v_num_account, 7, 1))
                   ,1) + substr(substr(v_koef, 11, 1) * substr(v_num_account, 8, 1)
                               ,length(substr(v_koef, 11, 1) * substr(v_num_account, 8, 1))
                               ,1) + substr(substr(v_koef, 12, 1) * substr(v_num_account, 9, 1)
                                           ,length(substr(v_koef, 12, 1) * substr(v_num_account, 9, 1))
                                           ,1) +
             substr(substr(v_koef, 13, 1) * substr(v_num_account, 10, 1)
                   ,length(substr(v_koef, 13, 1) * substr(v_num_account, 10, 1))
                   ,1) + substr(substr(v_koef, 14, 1) * substr(v_num_account, 11, 1)
                               ,length(substr(v_koef, 14, 1) * substr(v_num_account, 11, 1))
                               ,1) +
             substr(substr(v_koef, 15, 1) * substr(v_num_account, 12, 1)
                   ,length(substr(v_koef, 15, 1) * substr(v_num_account, 12, 1))
                   ,1) + substr(substr(v_koef, 16, 1) * substr(v_num_account, 13, 1)
                               ,length(substr(v_koef, 16, 1) * substr(v_num_account, 13, 1))
                               ,1) +
             substr(substr(v_koef, 17, 1) * substr(v_num_account, 14, 1)
                   ,length(substr(v_koef, 17, 1) * substr(v_num_account, 14, 1))
                   ,1) + substr(substr(v_koef, 18, 1) * substr(v_num_account, 15, 1)
                               ,length(substr(v_koef, 18, 1) * substr(v_num_account, 15, 1))
                               ,1) +
             substr(substr(v_koef, 19, 1) * substr(v_num_account, 16, 1)
                   ,length(substr(v_koef, 19, 1) * substr(v_num_account, 16, 1))
                   ,1) + substr(substr(v_koef, 20, 1) * substr(v_num_account, 17, 1)
                               ,length(substr(v_koef, 20, 1) * substr(v_num_account, 17, 1))
                               ,1) +
             substr(substr(v_koef, 21, 1) * substr(v_num_account, 18, 1)
                   ,length(substr(v_koef, 21, 1) * substr(v_num_account, 18, 1))
                   ,1) + substr(substr(v_koef, 22, 1) * substr(v_num_account, 19, 1)
                               ,length(substr(v_koef, 22, 1) * substr(v_num_account, 19, 1))
                               ,1) +
             substr(substr(v_koef, 23, 1) * substr(v_num_account, 20, 1)
                   ,length(substr(v_koef, 23, 1) * substr(v_num_account, 20, 1))
                   ,1)
        INTO p_4
        FROM dual;
    
      SELECT substr(to_char(to_number(substr(to_char(p_4), length(to_char(p_4)), 1)) * 3)
                   ,length(to_char(to_number(substr(to_char(p_4), length(to_char(p_4)), 1)) * 3))
                   ,1)
        INTO v_res
        FROM dual;
    
    ELSE
      RETURN 'X';
    END IF;
  
    RETURN v_res;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'X';
  END;

  FUNCTION check_control_snils(p_num_snils VARCHAR2) RETURN VARCHAR2 IS
    v_res    VARCHAR2(2);
    v_koef   VARCHAR2(9) := '987654321';
    p_step_1 VARCHAR2(5);
    p_step_2 NUMBER;
    p_step_3 NUMBER;
    p_step_4 NUMBER;
    p_step_5 NUMBER;
    p_step_6 NUMBER;
    p_step_7 NUMBER;
    p_step_8 NUMBER;
    p_step_9 NUMBER;
  BEGIN
    IF to_number(substr(p_num_snils, 1, 3)) >= 1
       AND to_number(substr(p_num_snils, 1, 3)) <= 998
    THEN
      SELECT substr(p_num_snils, 1, 1) * substr(v_koef, 1, 1) +
             substr(p_num_snils, 2, 1) * substr(v_koef, 2, 1) +
             substr(p_num_snils, 3, 1) * substr(v_koef, 3, 1) +
             substr(p_num_snils, 4, 1) * substr(v_koef, 4, 1) +
             substr(p_num_snils, 5, 1) * substr(v_koef, 5, 1) +
             substr(p_num_snils, 6, 1) * substr(v_koef, 6, 1) +
             substr(p_num_snils, 7, 1) * substr(v_koef, 7, 1) +
             substr(p_num_snils, 8, 1) * substr(v_koef, 8, 1) +
             substr(p_num_snils, 9, 1) * substr(v_koef, 9, 1)
        INTO p_step_1
        FROM dual;
      WHILE to_number(p_step_1) > 101 --OR TO_NUMBER(p_step_1) = 100 OR TO_NUMBER(p_step_1) = 101
      LOOP
        SELECT trunc(to_number(p_step_1) / 101) INTO p_step_2 FROM dual;
        SELECT to_number(p_step_1) - (p_step_2 * 101) INTO p_step_1 FROM dual;
      END LOOP;
      IF to_number(p_step_1) < 100
         AND to_number(p_step_1) > 9
      THEN
        RETURN p_step_1;
      ELSIF to_number(p_step_1) < 10
      THEN
        RETURN '0' || p_step_1;
      ELSIF to_number(p_step_1) = 100
            OR to_number(p_step_1) = 101
      THEN
        RETURN '00';
      ELSE
        RETURN p_step_1;
      END IF;
    
      /*
      IF TO_NUMBER(p_step_1) < 100 THEN
       RETURN p_step_1;
      ELSIF TO_NUMBER(p_step_1) = 100 OR TO_NUMBER(p_step_1) = 101 THEN
       RETURN '00';
      ELSE
       SELECT TRUNC(TO_NUMBER(p_step_1) / 101)
       INTO p_step_2
       FROM DUAL;
       SELECT TO_NUMBER(p_step_1) - p_step_2
       INTO p_step_3
       FROM DUAL;
        IF p_step_3 < 100 THEN
         RETURN TO_CHAR(p_step_3);
        ELSIF p_step_3 = 100 OR p_step_3 = 101 THEN
         RETURN '00';
        ELSE
           SELECT TRUNC(TO_NUMBER(p_step_3) / 101)
           INTO p_step_4
           FROM DUAL;
           SELECT TO_NUMBER(p_step_3) - p_step_4
           INTO p_step_5
           FROM DUAL;
           IF p_step_5 < 100 THEN
             RETURN TO_CHAR(p_step_5);
            ELSIF p_step_5 = 100 OR p_step_5 = 101 THEN
             RETURN '00';
            ELSE
             SELECT TRUNC(TO_NUMBER(p_step_5) / 101)
             INTO p_step_6
             FROM DUAL;
             SELECT TO_NUMBER(p_step_5) - p_step_6
             INTO p_step_7
             FROM DUAL;
             IF p_step_7 < 100 THEN
               RETURN TO_CHAR(p_step_7);
              ELSIF p_step_7 = 100 OR p_step_7 = 101 THEN
               RETURN '00';
              ELSE
                 SELECT TRUNC(TO_NUMBER(p_step_7) / 101)
                 INTO p_step_8
                 FROM DUAL;
                 SELECT TO_NUMBER(p_step_7) - p_step_8
                 INTO p_step_9
                 FROM DUAL;
                 IF p_step_9 < 100 THEN
                   RETURN TO_CHAR(p_step_9);
                  ELSIF p_step_9 = 100 OR p_step_9 = 101 THEN
                   RETURN '00';
                  ELSE
                   RETURN TO_CHAR(p_step_9);
                 END IF;
              END IF;
           END IF;
        END IF;
      END IF;*/
    ELSE
      RETURN 'X';
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'X';
  END;

  FUNCTION check_control_inn(p_num_inn VARCHAR2) RETURN VARCHAR2 IS
    v_res    VARCHAR2(2);
    v_koef_1 VARCHAR2(11) := '72410359468';
    v_koef_2 VARCHAR2(12) := '372410359468';
    v_koef_3 VARCHAR2(10) := '2410359468';
    p_len    NUMBER;
    p_step_1 VARCHAR2(5);
    p_step_2 NUMBER;
    p_step_3 NUMBER;
    p_step_4 VARCHAR2(5);
    p_step_5 NUMBER;
    p_step_6 NUMBER;
  BEGIN
  
    IF nvl(p_num_inn, 'X') = 'X'
    THEN
      RETURN 'X';
    ELSE
    
      SELECT length(p_num_inn) INTO p_len FROM dual;
    
      CASE p_len
        WHEN 10 THEN
          SELECT substr(p_num_inn, 1, 1) * substr(v_koef_3, 1, 1) +
                 substr(p_num_inn, 2, 1) * substr(v_koef_3, 2, 1) +
                 substr(p_num_inn, 3, 1) * substr(v_koef_3, 3, 2) +
                 substr(p_num_inn, 4, 1) * substr(v_koef_3, 5, 1) +
                 substr(p_num_inn, 5, 1) * substr(v_koef_3, 6, 1) +
                 substr(p_num_inn, 6, 1) * substr(v_koef_3, 7, 1) +
                 substr(p_num_inn, 7, 1) * substr(v_koef_3, 8, 1) +
                 substr(p_num_inn, 8, 1) * substr(v_koef_3, 9, 1) +
                 substr(p_num_inn, 9, 1) * substr(v_koef_3, 10, 1)
            INTO p_step_1
            FROM dual;
          SELECT trunc(to_number(p_step_1) / 11) INTO p_step_2 FROM dual;
          SELECT to_number(p_step_1) - (p_step_2 * 11) INTO p_step_3 FROM dual;
        
          IF p_step_3 = 10
          THEN
            RETURN '0';
          ELSE
            RETURN to_char(p_step_3);
          END IF;
        WHEN 12 THEN
          SELECT substr(p_num_inn, 1, 1) * substr(v_koef_1, 1, 1) +
                 substr(p_num_inn, 2, 1) * substr(v_koef_1, 2, 1) +
                 substr(p_num_inn, 3, 1) * substr(v_koef_1, 3, 1) +
                 substr(p_num_inn, 4, 1) * substr(v_koef_1, 4, 2) +
                 substr(p_num_inn, 5, 1) * substr(v_koef_1, 6, 1) +
                 substr(p_num_inn, 6, 1) * substr(v_koef_1, 7, 1) +
                 substr(p_num_inn, 7, 1) * substr(v_koef_1, 8, 1) +
                 substr(p_num_inn, 8, 1) * substr(v_koef_1, 9, 1) +
                 substr(p_num_inn, 9, 1) * substr(v_koef_1, 10, 1) +
                 substr(p_num_inn, 10, 1) * substr(v_koef_1, 11, 1)
            INTO p_step_1
            FROM dual;
          SELECT trunc(to_number(p_step_1) / 11) INTO p_step_2 FROM dual;
          SELECT to_number(p_step_1) - (p_step_2 * 11) INTO p_step_3 FROM dual;
          IF p_step_3 = 10
          THEN
            p_step_3 := 0;
          END IF;
        
          SELECT substr(p_num_inn, 1, 1) * substr(v_koef_2, 1, 1) +
                 substr(p_num_inn, 2, 1) * substr(v_koef_2, 2, 1) +
                 substr(p_num_inn, 3, 1) * substr(v_koef_2, 3, 1) +
                 substr(p_num_inn, 4, 1) * substr(v_koef_2, 4, 1) +
                 substr(p_num_inn, 5, 1) * substr(v_koef_2, 5, 2) +
                 substr(p_num_inn, 6, 1) * substr(v_koef_2, 7, 1) +
                 substr(p_num_inn, 7, 1) * substr(v_koef_2, 8, 1) +
                 substr(p_num_inn, 8, 1) * substr(v_koef_2, 9, 1) +
                 substr(p_num_inn, 9, 1) * substr(v_koef_2, 10, 1) +
                 substr(p_num_inn, 10, 1) * substr(v_koef_2, 11, 1) +
                 substr(p_num_inn, 11, 1) * substr(v_koef_2, 12, 1)
            INTO p_step_4
            FROM dual;
          SELECT trunc(to_number(p_step_4) / 11) INTO p_step_5 FROM dual;
          SELECT to_number(p_step_4) - (p_step_5 * 11) INTO p_step_6 FROM dual;
        
          IF p_step_6 = 10
          THEN
            RETURN to_char(p_step_3) || '0';
          ELSE
            RETURN to_char(p_step_3) || to_char(p_step_6);
          END IF;
        ELSE
          RETURN 'X';
      END CASE;
    
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'X';
  END;

  PROCEDURE set_role_contact(p_document_id NUMBER) IS
    v_type_doc VARCHAR2(25);
    v_role_cnt NUMBER;
    v_role_id  NUMBER;
    no_role EXCEPTION;
    v_name       VARCHAR2(255);
    v_contact_id NUMBER;
  BEGIN
  
    BEGIN
      SELECT r.id INTO v_role_id FROM t_contact_role r WHERE r.description = 'Заявитель';
    EXCEPTION
      WHEN no_data_found THEN
        v_role_id := 0;
    END;
  
    IF v_role_id = 0
    THEN
      RAISE no_role;
    END IF;
  
    BEGIN
      SELECT dt.brief
        INTO v_type_doc
        FROM document  d
            ,doc_templ dt
       WHERE d.document_id = p_document_id
         AND d.doc_templ_id = dt.doc_templ_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_type_doc := 'X';
    END;
  
    IF v_type_doc = 'ПретензияСС'
    THEN
    
      BEGIN
        SELECT c.obj_name_orig
              ,c.contact_id
          INTO v_name
              ,v_contact_id
          FROM ven_c_claim_header ch
              ,
               --ven_c_declarant_role   dr, ----Чирков удаление старых связей заявителей
               ven_p_policy        p
              ,ven_c_event         e
              ,ven_c_event_contact ec
              ,c_declarants        cd
              , ----Чирков удаление старых связей заявителей
               ven_contact         c
         WHERE --ch.declarant_role_id = dr.c_declarant_role_id ----Чирков удаление старых связей заявителей     
         ch.p_policy_id = p.policy_id
         AND ch.c_event_id = e.c_event_id
        ----Чирков удаление старых связей заявителей
        --AND ch.declarant_id = ec.c_event_contact_id
         AND cd.c_claim_header_id = ch.c_claim_header_id
         AND cd.declarant_id = ec.c_event_contact_id
         AND cd.c_declarants_id =
         (SELECT MAX(cd_1.c_declarants_id)
            FROM c_declarants cd_1
           WHERE cd_1.c_claim_header_id = cd.c_claim_header_id)
        --end_Чирков удаление старых связей заявителей          
        
         AND ec.cn_person_id = c.contact_id
         AND ch.active_claim_id = p_document_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_name       := '';
          v_contact_id := 0;
      END;
    
      SELECT COUNT(*)
        INTO v_role_cnt
        FROM cn_contact_role cr
            ,t_contact_role  r
       WHERE cr.role_id = r.id
         AND r.description = 'Заявитель'
         AND cr.contact_id = v_contact_id;
    
      IF v_contact_id > 0
         AND v_role_cnt = 0
      THEN
        INSERT INTO cn_contact_role
          (contact_id, role_id, id)
        VALUES
          (v_contact_id, v_role_id, sq_cn_contact_role.nextval);
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_role THEN
      NULL; --RAISE_APPLICATION_ERROR(-20001,'Не найдена Роль - Заявитель');
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION get_telephone_number
  (
    par_contact_id NUMBER
   ,par_type_tel   NUMBER
  ) RETURN VARCHAR2 IS
    RESULT VARCHAR2(15);
  BEGIN
  
    SELECT tel.telephone_number tel
      INTO RESULT
      FROM ins.t_telephone_type     tt
          ,ins.cn_contact_telephone tel
     WHERE tel.contact_id = par_contact_id
       AND tt.id = tel.telephone_type
       AND tt.id = par_type_tel
       AND length(tel.telephone_number) > 3
       AND tel.control = 0
       AND tel.status = 1
       AND rownum = 1
     ORDER BY tel.status DESC
             ,tel.id     ASC;
  
    RETURN RESULT;
  
  END get_telephone_number;

  FUNCTION get_telephone_state
  (
    par_contact_id NUMBER
   ,par_type_tel   NUMBER
  ) RETURN VARCHAR2 IS
    RESULT VARCHAR2(15);
  BEGIN
  
    SELECT decode(tel.status
                 ,1
                 ,'Действует'
                 ,0
                 ,'Не Действует'
                 ,'Не определен')
      INTO RESULT
      FROM ins.t_telephone_type     tt
          ,ins.cn_contact_telephone tel
     WHERE tel.contact_id = par_contact_id
       AND tt.id = tel.telephone_type
       AND tt.id = par_type_tel
       AND length(tel.telephone_number) > 3
       AND tel.control = 0
       AND tel.status = 1
       AND rownum = 1
     ORDER BY tel.status DESC
             ,tel.id     ASC;
  
    RETURN RESULT;
  
  END get_telephone_state;

  FUNCTION get_ltrs_address(p_cn_contact_id NUMBER) RETURN NUMBER IS
    v_ret_val   NUMBER;
    v_addr_orig NUMBER;
    v_addr_fact NUMBER;
  BEGIN
    SELECT *
      INTO v_addr_orig
      FROM (SELECT ca.adress_id
              FROM cn_contact_address ca
                  ,ins.t_address_type tat
             WHERE ca.contact_id = p_cn_contact_id
               AND ca.address_type = tat.id
               AND tat.sort_order BETWEEN 1 AND 9998
             ORDER BY ca.status      DESC
                     ,tat.sort_order ASC
                     ,ca.adress_id   DESC)
     WHERE rownum = 1;
    BEGIN
      SELECT cac.id INTO v_addr_fact FROM ins.cn_address cac WHERE cac.parent_addr_id = v_addr_orig;
    EXCEPTION
      WHEN no_data_found THEN
        v_ret_val := v_addr_orig;
    END;
  
    IF v_ret_val IS NULL
       AND v_addr_orig IS NULL
    THEN
      RETURN NULL;
    ELSE
      RETURN nvl(v_ret_val, v_addr_fact);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /* Функция возвращает id дополинтельного документа по контакту
  * @Autor Чирков В. Ю.
  * @param p_contact_id - id контакта
  * @param p_doc_type_brief - тип документа
  */
  FUNCTION get_contact_document_id
  (
    p_contact_id     NUMBER
   ,p_doc_type_brief VARCHAR2
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
    SELECT table_id
      INTO v_ret_val
      FROM (SELECT cci_in.table_id
                  ,cci_in.contact_id
                  ,cci_in.id_value
              FROM ins.cn_contact_ident cci_in
                  ,ins.t_id_type        tit
             WHERE cci_in.id_type = tit.id
               AND tit.brief = p_doc_type_brief
               AND cci_in.contact_id = p_contact_id
             ORDER BY cci_in.is_used DESC NULLS LAST) x
     WHERE rownum = 1;
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_contact_document_id;

  /* Функция возвращает id банковского документа по контакту
  * @Autor Чирков В. Ю.
  * @param par_contact_id - id контакта
  */
  FUNCTION get_primary_banc_acc(par_contact_id NUMBER) RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
    SELECT x.id
      INTO v_ret_val
      FROM (SELECT bc.id
              FROM ins.cn_contact_bank_acc bc
             WHERE bc.contact_id = par_contact_id
             ORDER BY bc.used_flag
                     ,bc.id DESC NULLS LAST) x
     WHERE rownum = 1;
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_primary_banc_acc;
  /*
    Байтин А.
    
    Добавление телефона контакту
  */
  FUNCTION insert_phone
  (
    par_contact_id          NUMBER
   ,par_telephone_type      NUMBER
   ,par_telephone_number    VARCHAR2
   ,par_telephone_prefix    VARCHAR2 DEFAULT NULL
   ,par_country_id          NUMBER DEFAULT 1
   ,par_telephone_extension VARCHAR2 DEFAULT NULL
   ,par_remarks             VARCHAR2 DEFAULT NULL
   ,par_telephone_prefix_id NUMBER DEFAULT NULL
   ,par_control             NUMBER DEFAULT 0
   ,par_status              NUMBER DEFAULT 1
   ,par_field_count         NUMBER DEFAULT 0
   ,par_is_temp             NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT sq_cn_contact_telephone.nextval INTO v_id FROM dual;
  
    INSERT INTO ven_cn_contact_telephone
      (id
      ,contact_id
      ,telephone_type
      ,telephone_number
      ,country_id
      ,control
      ,status
      ,field_count
      ,remarks
      ,telephone_extension
      ,telephone_prefix
      ,telephone_prefix_id
      ,is_temp)
    VALUES
      (v_id
      ,par_contact_id
      ,par_telephone_type
      ,par_telephone_number
      ,par_country_id
      ,par_control
      ,par_status
      ,par_field_count
      ,par_remarks
      ,par_telephone_extension
      ,par_telephone_prefix
      ,par_telephone_prefix_id
      ,par_is_temp);
  
    RETURN v_id;
  END insert_phone;

  /*
    Байтин А.
    
    Перегруженный вариант, без использования ID и с проверками
  */
  FUNCTION insert_phone
  (
    par_contact_id          NUMBER
   ,par_telephone_type      VARCHAR2
   ,par_telephone_number    VARCHAR2
   ,par_telephone_prefix    VARCHAR2 DEFAULT NULL
   ,par_country             VARCHAR2 DEFAULT 'Россия'
   ,par_telephone_extension VARCHAR2 DEFAULT NULL
   ,par_remarks             VARCHAR2 DEFAULT NULL
   ,par_telephone_prefix_id NUMBER DEFAULT NULL
   ,par_control             NUMBER DEFAULT 0
   ,par_status              NUMBER DEFAULT 1
   ,par_field_count         NUMBER DEFAULT 0
   ,par_is_temp             NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_country_id        NUMBER;
    v_country_dial_id   NUMBER;
    v_telephone_type_id NUMBER;
  BEGIN
    -- Проверки
    IF par_contact_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание ID контакта обязательно при добавлении телефона!');
    END IF;
  
    IF par_telephone_type IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание типа телефона обязательно при добавлении телефона!');
    END IF;
  
    IF par_telephone_number IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание номера телефона обязательно при добавлении телефона!');
    END IF;
  
    IF par_control IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание признака "хорошего" телефона обязательно при добавлении телефона!');
    END IF;
  
    IF par_country IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание страны обязательно при добавлении телефона!');
    END IF;
  
    IF par_control NOT IN (0, 1)
    THEN
      raise_application_error(-20001
                             ,'Признак "хорошего" телефона должен иметь значение 0 или 1!');
    END IF;
  
    IF par_status NOT IN (0, 1)
       OR par_status IS NULL
    THEN
      raise_application_error(-20001
                             ,'Статус телефона должен иметь значение 0 или 1!');
    END IF;
  
    IF par_field_count NOT IN (0, 1, 2)
       OR par_field_count IS NULL
    THEN
      raise_application_error(-20001
                             ,'Счетчик обращений к телефону должен иметь значение 0,1 или 2!');
    END IF;
  
    -- Разыменовывание
    BEGIN
      SELECT tc.id INTO v_country_id FROM t_country tc WHERE tc.description = par_country;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найдена страна "' || par_country || '"!');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Страна "' || par_country ||
                                '" встречается в справочнике стран несколько раз!');
    END;
    BEGIN
      SELECT dc.id
        INTO v_country_dial_id
        FROM t_country_dial_code dc
       WHERE dc.country_id = v_country_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена страна "' || par_country || '" с ID "' || v_country_id ||
                                '" в справочнике кодов дозвона стран!');
    END;
  
    BEGIN
      SELECT tt.id
        INTO v_telephone_type_id
        FROM t_telephone_type tt
       WHERE tt.brief = par_telephone_type;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип телефона "' || par_telephone_type ||
                                '" в справочнике типов телефона!');
    END;
  
    -- Вставка
    RETURN pkg_contact.insert_phone(par_contact_id          => par_contact_id
                                   ,par_telephone_type      => v_telephone_type_id
                                   ,par_telephone_number    => par_telephone_number
                                   ,par_telephone_prefix    => par_telephone_prefix
                                   ,par_country_id          => v_country_dial_id --v_country_id
                                   ,par_telephone_extension => par_telephone_extension
                                   ,par_remarks             => par_remarks
                                   ,par_telephone_prefix_id => par_telephone_prefix_id
                                   ,par_control             => par_control
                                   ,par_status              => par_status
                                   ,par_field_count         => par_field_count
                                   ,par_is_temp             => par_is_temp);
  END insert_phone;

  /*
    Байтин А.
    
    Добавление телефона контакту
  */
  FUNCTION insert_email
  (
    par_contact_id  NUMBER
   ,par_email       VARCHAR2
   ,par_email_type  NUMBER
   ,par_field_count NUMBER DEFAULT 1
   ,par_status      NUMBER DEFAULT 0
   ,par_is_temp     NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT sq_cn_contact_email.nextval INTO v_id FROM dual;
  
    INSERT INTO ven_cn_contact_email
      (contact_id, email, email_type, status, field_count, is_temp)
    VALUES
      (par_contact_id, par_email, par_email_type, par_status, par_field_count, par_is_temp);
    RETURN v_id;
  END insert_email;

  /*
    Байтин А.
    
    Перегруженный вариант, без использования ID и с проверками
  */
  FUNCTION insert_email
  (
    par_contact_id  NUMBER
   ,par_email       VARCHAR2
   ,par_email_type  VARCHAR2
   ,par_field_count NUMBER DEFAULT 1
   ,par_status      NUMBER DEFAULT 0
   ,par_is_temp     NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_email_type_id NUMBER;
  BEGIN
    -- Проверки
    IF par_contact_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание ID контакта обязательно при добавлении адреса электронной почты!');
    END IF;
  
    IF par_email IS NULL
    THEN
      raise_application_error(-20001
                             ,'Указание адреса обязательно при добавлении адреса электронной почты!');
    END IF;
  
    IF par_status NOT IN (0, 1)
       OR par_status IS NULL
    THEN
      raise_application_error(-20001
                             ,'Статус адреса электронной почты должен иметь значение 0 или 1!');
    END IF;
  
    IF par_field_count NOT IN (0, 1)
       OR par_field_count IS NULL
    THEN
      raise_application_error(-20001
                             ,'Счетчик обращений к адресу электронной почты должен иметь значение 0 или 1!');
    END IF;
  
    -- Разыменовывание
    BEGIN
      SELECT et.id INTO v_email_type_id FROM t_email_type et WHERE et.description = par_email_type;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип адреса электронной почты "' || par_email_type || '"!');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Тип адреса электронной почты "' || par_email_type ||
                                '" встречается в справочнике несколько раз!');
    END;
  
    RETURN pkg_contact.insert_email(par_contact_id  => par_contact_id
                                   ,par_email       => par_email
                                   ,par_email_type  => v_email_type_id
                                   ,par_field_count => par_field_count
                                   ,par_status      => par_status
                                   ,par_is_temp     => par_is_temp);
  END insert_email;

  PROCEDURE set_contact_contacts
  (
    par_contact_id        NUMBER
   ,par_address           VARCHAR2
   ,par_contact_telephone VARCHAR2 DEFAULT NULL
   ,par_country_id        NUMBER DEFAULT NULL
  ) IS
    v_address_id            NUMBER;
    v_address_type_id       NUMBER;
    v_dial_code_id          NUMBER;
    v_contact_phone_id      NUMBER;
    v_contact_phone_type_id NUMBER;
    v_country_id            NUMBER;
  BEGIN
    /*Получим данные из справочников: ид кода страны, тип адреса, тип телефона*/
  
    SELECT id
      INTO v_dial_code_id
      FROM (SELECT id
              FROM t_country_dial_code
             WHERE is_default = 1
               AND rownum = 1
            UNION ALL
            SELECT NULL
              FROM dual
             ORDER BY 1)
     WHERE rownum = 1;
  
    /* SELECT id into v_address_type_id
       FROM (select id from t_address_type where is_default = 1 AND ROWNUM=1 UNION ALL SELECT NULL FROM dual ORDER BY 1)
      WHERE ROWNUM=1;
    
     SELECT id into v_contact_phone_type_id
       FROM (select id from t_telephone_type where brief = 'CONT' AND ROWNUM=1 UNION ALL SELECT NULL FROM dual ORDER BY 1)
      WHERE ROWNUM=1;
    */
    SELECT id
      INTO v_address_type_id
      FROM (SELECT id
              FROM t_address_type at
             WHERE upper(at.brief) = 'DOMADD' /* Поскряков заявка 156973 */ /* is_default = 1 */
               AND rownum = 1
            UNION ALL
            SELECT NULL
              FROM dual
             ORDER BY 1)
     WHERE rownum = 1;
  
    SELECT id
      INTO v_contact_phone_type_id
      FROM (SELECT id
              FROM t_telephone_type
             WHERE brief = 'MOBIL'
               AND rownum = 1
            UNION ALL
            SELECT NULL
              FROM dual
             ORDER BY 1)
     WHERE rownum = 1;
  
    /*Проверим есть ли уже у контакта адресс*/
    IF par_address IS NOT NULL
    THEN
      BEGIN
        SELECT id
          INTO v_address_id
          FROM (SELECT adress_id id
                  FROM cn_contact_address
                 WHERE contact_id = par_contact_id
                   AND address_type = v_address_type_id)
         WHERE rownum = 1;
      
        UPDATE ins.cn_address c
           SET c.country_id          = nvl(par_country_id, c.country_id)
              ,c.name                = par_address
              ,c.decompos_permis     = 0
              ,c.decompos_date       = NULL
              ,c.street_name         = NULL
              ,c.street_type         = NULL
              ,c.code                = NULL
              ,c.zip                 = NULL
              ,c.district_type       = NULL
              ,c.district_name       = NULL
              ,c.region_type         = NULL
              ,c.region_name         = NULL
              ,c.province_type       = NULL
              ,c.province_name       = NULL
              ,c.city_type           = NULL
              ,c.city_name           = NULL
              ,c.appartment_nr       = NULL
              ,c.house_nr            = NULL
              ,c.house_type          = NULL
              ,c.actual              = 0
              ,c.code_kladr_province = NULL
              ,c.code_kladr_region   = NULL
              ,c.code_kladr_city     = NULL
              ,c.code_kladr_distr    = NULL
              ,c.code_kladr_street   = NULL
              ,c.code_kladr_doma     = NULL
              ,c.index_province      = NULL
              ,c.index_region        = NULL
              ,c.index_city          = NULL
              ,c.index_distr         = NULL
              ,c.index_street        = NULL
              ,c.index_doma          = NULL
         WHERE c.id = v_address_id
           AND TRIM(c.name) != TRIM(par_address);
        IF SQL%ROWCOUNT != 0
        THEN
          UPDATE ins.cn_address c
             SET c.country_id          = nvl(par_country_id, c.country_id)
                ,c.name                = par_address
                ,c.decompos_permis     = 0
                ,c.decompos_date       = NULL
                ,c.street_name         = NULL
                ,c.street_type         = NULL
                ,c.code                = NULL
                ,c.zip                 = NULL
                ,c.district_type       = NULL
                ,c.district_name       = NULL
                ,c.region_type         = NULL
                ,c.region_name         = NULL
                ,c.province_type       = NULL
                ,c.province_name       = NULL
                ,c.city_type           = NULL
                ,c.city_name           = NULL
                ,c.appartment_nr       = NULL
                ,c.house_nr            = NULL
                ,c.house_type          = NULL
                ,c.actual              = 0
                ,c.code_kladr_province = NULL
                ,c.code_kladr_region   = NULL
                ,c.code_kladr_city     = NULL
                ,c.code_kladr_distr    = NULL
                ,c.code_kladr_street   = NULL
                ,c.code_kladr_doma     = NULL
                ,c.index_province      = NULL
                ,c.index_region        = NULL
                ,c.index_city          = NULL
                ,c.index_distr         = NULL
                ,c.index_street        = NULL
                ,c.index_doma          = NULL
           WHERE c.parent_addr_id = v_address_id;
        END IF;
      
      EXCEPTION
        WHEN no_data_found THEN
          /*У контакта нет адреса - заведем*/
          SELECT sq_cn_address.nextval INTO v_address_id FROM dual;
          -- Байтин А.
          -- Добавил получение страны по умолчанию. Иначе добавление адреса вызывало ошибку.
          IF par_country_id IS NULL
          THEN
            BEGIN
              SELECT id INTO v_country_id FROM t_country WHERE is_default = 1;
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20100
                                       ,'Не задана страна по-умолчанию');
              WHEN too_many_rows THEN
                raise_application_error(-20100
                                       ,'Задано более одной страны по-умолчанию');
            END;
          END IF;
          INSERT INTO cn_address ca
            (ca.id, ca.country_id, ca.name, ca.decompos_permis)
          VALUES
            (v_address_id, nvl(par_country_id, v_country_id), par_address, 0);
        
          INSERT INTO cn_contact_address cca
            (cca.id, cca.contact_id, cca.address_type, cca.adress_id, cca.is_default)
          VALUES
            (sq_cn_contact_address.nextval, par_contact_id, v_address_type_id, v_address_id, 1);
        
      END;
    END IF;
  
    /*Проверим есть ли уже у контакта контактный телефон "простите за каламбур" © =)*/
    -- Байтин А.
    -- Убрал добавление телефона в случае, когда номера нет...
    IF par_contact_telephone IS NOT NULL
    THEN
      BEGIN
        SELECT id
          INTO v_contact_phone_id
          FROM (SELECT id
                  FROM cn_contact_telephone
                 WHERE contact_id = par_contact_id
                   AND telephone_type = v_contact_phone_type_id)
         WHERE rownum = 1;
      
        UPDATE cn_contact_telephone
           SET telephone_number = nvl(par_contact_telephone, ' ')
         WHERE id = v_contact_phone_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          /*У контакта нет телефона - заведем*/
          SELECT sq_cn_address.nextval INTO v_address_id FROM dual;
        
          INSERT INTO cn_contact_telephone cct
            (cct.id, cct.contact_id, cct.telephone_type, cct.telephone_number, cct.country_id)
          VALUES
            (sq_cn_contact_telephone.nextval
            ,par_contact_id
            ,v_contact_phone_type_id
            ,nvl(par_contact_telephone, ' ')
            ,v_dial_code_id);
      END;
    END IF;
  END;

  FUNCTION create_person_contact_rlu
  (
    p_last_name       VARCHAR2
   ,p_first_name      VARCHAR2
   ,p_middle_name     VARCHAR2
   ,p_birth_date      DATE
   ,p_gender          VARCHAR2
   ,p_pass_ser        VARCHAR2 DEFAULT NULL
   ,p_pass_num        VARCHAR2 DEFAULT NULL
   ,p_pass_issue_date DATE DEFAULT NULL
   ,p_pass_issued_by  VARCHAR2 DEFAULT NULL
   ,p_address         VARCHAR2 DEFAULT NULL
   ,p_contact_phone   VARCHAR2 DEFAULT NULL
   ,p_country_id      NUMBER DEFAULT NULL
   ,p_note            VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_person_id         NUMBER;
    v_ct_id             NUMBER;
    v_contact_status_id NUMBER;
    v_gender_id         NUMBER;
    v_country_id        NUMBER;
    v_doc_type_id       NUMBER;
  BEGIN
  
    v_person_id := create_person_contact(p_first_name      => p_first_name
                                        ,p_middle_name     => p_middle_name
                                        ,p_last_name       => p_last_name
                                        ,p_birth_date      => p_birth_date
                                        ,p_gender          => p_gender
                                        ,p_pass_ser        => p_pass_ser
                                        ,p_pass_num        => p_pass_num
                                        ,p_pass_issue_date => p_pass_issue_date
                                        ,p_pass_issued_by  => p_pass_issued_by
                                        ,p_country_id      => p_country_id
                                        ,p_note            => p_note);
    set_contact_contacts(v_person_id, p_address, p_contact_phone);
  
    RETURN v_person_id;
  
  END create_person_contact_rlu;

  PROCEDURE insert_address
  (
    p_contact_id         NUMBER
   ,p_address            VARCHAR2
   ,p_address_type_brief VARCHAR2 DEFAULT 'DOMADD'
   ,p_country_id         NUMBER DEFAULT NULL
   ,p_is_default         NUMBER DEFAULT 1
   ,p_is_temp            NUMBER DEFAULT NULL
  ) IS
    v_address_type_id NUMBER;
    v_address_id      NUMBER;
    v_country_id      NUMBER;
  BEGIN
  
    SELECT id
      INTO v_address_type_id
      FROM (SELECT id
              FROM t_address_type at
             WHERE upper(at.brief) = upper(p_address_type_brief) /* Поскряков заявка 156973 */ /* is_default = 1 */
               AND rownum = 1
            UNION ALL
            SELECT NULL
              FROM dual
             ORDER BY 1)
     WHERE rownum = 1;
  
    BEGIN
      SELECT id
        INTO v_address_id
        FROM (SELECT adress_id id
                FROM cn_contact_address
               WHERE contact_id = p_contact_id
                 AND address_type = v_address_type_id)
       WHERE rownum = 1;
    
      pkg_address.update_address(p_address_id => v_address_id
                                ,p_address    => p_address
                                ,p_country_id => p_country_id);
    EXCEPTION
      WHEN no_data_found THEN
        v_address_id := pkg_address.insert_adress(p_address => p_address, p_country_id => p_country_id);
      
        INSERT INTO cn_contact_address cca
          (cca.id, cca.contact_id, cca.address_type, cca.adress_id, cca.is_default, cca.is_temp)
        VALUES
          (sq_cn_contact_address.nextval
          ,p_contact_id
          ,v_address_type_id
          ,v_address_id
          ,p_is_default
          ,p_is_temp);
    END;
  END insert_address;
  /*
      Модифицирована 10.04.2013 Веселуха Е.
      par_risk_level        VARCHAR2 DEFAULT Средний уровень риска = 2
      Добавлен par_contact_type_id Тип контакта, по умолчанию Юр лицо = 101
  */
  FUNCTION create_company
  (
    par_name              VARCHAR2
   ,par_short_name        VARCHAR2 DEFAULT NULL
   ,par_risk_level        VARCHAR2 DEFAULT 2
   ,par_resident_flag     NUMBER DEFAULT 1
   ,par_web_site          VARCHAR2 DEFAULT NULL
   ,par_dms_lpu_gl_fio    VARCHAR2 DEFAULT NULL -- ФИО руководителя
   ,par_company_status_id NUMBER DEFAULT NULL
   ,par_contact_type_id   NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_ct_id             NUMBER;
    v_contact_status_id NUMBER;
    v_contact_id        NUMBER;
  BEGIN
    IF par_name IS NULL
    THEN
      raise_application_error(-20001, 'Передано пустое Название Юр. лица');
    END IF;
  
    -- Это очень плохо! Необходимо определиться с алгоритмом поиска контактов ЮрЛиц!!!
    SELECT MIN(contact_id)
      INTO v_contact_id
      FROM contact        c
          ,t_contact_type ct
     WHERE c.obj_name = TRIM(upper(par_name))
       AND c.contact_type_id = ct.id
       AND ct.brief != 'ФЛ';
  
    IF v_contact_id IS NULL
    THEN
      IF par_contact_type_id IS NULL
      THEN
        SELECT id
          INTO v_ct_id
          FROM (SELECT id FROM t_contact_type WHERE brief = 'ЮЛ')
         WHERE rownum < 2;
      ELSE
        v_ct_id := par_contact_type_id;
      END IF;
    
      IF par_company_status_id IS NULL
      THEN
        SELECT t_contact_status_id
          INTO v_contact_status_id
          FROM t_contact_status
         WHERE NAME = 'Обычный';
      ELSE
        v_contact_status_id := par_company_status_id;
      END IF;
    
      SELECT sq_contact.nextval INTO v_contact_id FROM dual;
    
      INSERT INTO ven_cn_company
        (contact_id
        ,NAME
        ,short_name
        ,contact_type_id
        ,risk_level
        ,resident_flag
        ,web_site
        ,dms_lpu_gl_fio
        ,t_contact_status_id)
      VALUES
        (v_contact_id
        ,par_name
        ,nvl(par_short_name, par_name)
        ,v_ct_id
        ,par_risk_level
        ,nvl(par_resident_flag, 1)
        ,par_web_site
        ,par_dms_lpu_gl_fio
        ,v_contact_status_id);
    END IF;
  
    RETURN v_contact_id;
  
  END create_company;

  /*
      Создание идентифицирующего документа
      Веселуха Е. 10.04.2013
  */
  FUNCTION create_ident_document
  (
    par_contact_id       NUMBER
   ,par_ident_type_id    NUMBER
   ,par_value            VARCHAR2
   ,par_series           VARCHAR2 DEFAULT NULL
   ,par_issue_date       DATE DEFAULT NULL
   ,par_issue_place      VARCHAR2 DEFAULT NULL
   ,par_is_default       NUMBER DEFAULT 0
   ,par_termination_date DATE DEFAULT NULL
   ,par_is_used          NUMBER DEFAULT 1
   ,par_subdivision_code VARCHAR2 DEFAULT NULL
   ,par_country_id       NUMBER DEFAULT NULL
   ,par_is_temp          NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_ident_id   NUMBER;
    v_country_id NUMBER;
  
    PROCEDURE check_ident_doc_issue_date
    (
      par_contact_id    contact.contact_id%TYPE
     ,par_issue_date    cn_contact_ident.issue_date%TYPE
     ,par_ident_type_id NUMBER
    ) IS
      v_id_type_brief t_id_type.brief%TYPE;
      v_date_of_birth cn_person.date_of_birth%TYPE;
    BEGIN
      IF par_issue_date IS NOT NULL
      THEN
        BEGIN
          SELECT it.brief INTO v_id_type_brief FROM t_id_type it WHERE it.id = par_ident_type_id;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось определить тип документа контакта по ИД: ' ||
                                    par_ident_type_id);
        END;
      
        BEGIN
          SELECT cp.date_of_birth
            INTO v_date_of_birth
            FROM cn_person cp
           WHERE cp.contact_id = par_contact_id;
        
          IF par_issue_date < v_date_of_birth
          THEN
            raise_application_error(-20001
                                   ,'Дата выдачи документа не может быть меньше даты рождения контакта.');
          ELSIF v_id_type_brief IN ('PASS_RF')
                AND par_issue_date < ADD_MONTHS(v_date_of_birth, 12 * 14)
          THEN
            raise_application_error(-20001
                                   ,'Дата выдачи паспорта не может быть раньше достижения контактом 14 лет.');
          END IF;
        
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      
      END IF;
    END check_ident_doc_issue_date;
  
  BEGIN
  
    check_ident_doc_issue_date(par_contact_id    => par_contact_id
                              ,par_issue_date    => par_issue_date
                              ,par_ident_type_id => par_ident_type_id);
  
    SELECT sq_cn_contact_ident.nextval INTO v_ident_id FROM dual;
  
    IF par_country_id IS NULL
    THEN
      SELECT id INTO v_country_id FROM t_country tc WHERE tc.description = 'Россия';
    ELSE
      v_country_id := par_country_id;
    END IF;
  
    INSERT INTO ins.ven_cn_contact_ident
      (table_id
      ,contact_id
      ,country_id
      ,id_type
      ,id_value
      ,is_default
      ,issue_date
      ,is_used
      ,place_of_issue
      ,serial_nr
      ,subdivision_code
      ,termination_date
      ,tmp_table_id
      ,is_temp)
    VALUES
      (v_ident_id
      ,par_contact_id
      ,v_country_id
      ,par_ident_type_id
      ,par_value
      ,par_is_default
      ,par_issue_date
      ,par_is_used
      ,par_issue_place
      ,par_series
      ,par_subdivision_code
      ,par_termination_date
      ,v_ident_id
      ,par_is_temp);
  
    RETURN v_ident_id;
  
  END create_ident_document;

  FUNCTION find_ident_document
  (
    par_contact_id    NUMBER
   ,par_ident_type_id NUMBER
   ,par_value         VARCHAR2
   ,par_series        VARCHAR2 DEFAULT NULL
   ,par_issue_date    DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_ident_id cn_contact_ident.table_id%TYPE;
  BEGIN
    SELECT MAX(cci.table_id)
      INTO v_ident_id
      FROM cn_contact_ident cci
     WHERE cci.contact_id = par_contact_id
       AND cci.id_type = par_ident_type_id
       AND cci.id_value = par_value
       AND decode(cci.serial_nr, par_series, 1, 0) = 1
       AND decode(cci.issue_date, par_issue_date, 1, 0) = 1;
  
    RETURN v_ident_id;
  
  END find_ident_document;
  /*FUNCTION SET_GET_HISTORY(p_contact_id NUMBER, p_set_get NUMBER DEFAULT 1) RETURN t_check_change IS
  \*
  p_set_get - 1 записываем данные в переменную, 2 - возвращаем данные
  *\
  i NUMBER := 0;
  v_contact_id NUMBER;
  
  BEGIN
       
       \*FOR cur IN (
        SELECT acc.id, acc.account_nr,acc.lic_code,acc.account_corr
        FROM ven_cn_contact_bank_acc acc
        WHERE acc.contact_id = 226008
      ) LOOP
        i:=v_check_change.COUNT+1;
        v_check_change(i).id := cur.id;
        v_check_change(i).account_nr := cur.account_nr;
        v_check_change(i).lic_code := cur.lic_code;
        v_check_change(i).account_corr := cur.account_corr;
      END LOOP;*\
  
     IF p_set_get = 1 THEN
     
      SELECT *
       bulk collect into v_check_change
       FROM ven_cn_contact_bank_acc acc
      WHERE acc.contact_id = p_contact_id;
      
     ELSE
     
      NULL;
      
     END IF;
  
   RETURN v_check_change;
  
  END;*/

  /*
    @author Байтин А.
  
    Получение имени контакта по ID
    @param par_contact_id - ИД контакта
    @param par_raise_on_error - TRUE: возвращать ошибку; FALSE: нет
  
    @return Имя контакта
  */
  FUNCTION get_contact_name_by_id
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN contact.obj_name_orig%TYPE IS
    v_contact_name contact.obj_name_orig%TYPE;
  BEGIN
    assert_deprecated(par_contact_id IS NULL, 'ИД контакта не указан');
    BEGIN
      SELECT co.obj_name_orig
        INTO v_contact_name
        FROM contact co
       WHERE co.contact_id = par_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найден контакт по указанному ИД');
        ELSE
          v_contact_name := NULL;
        END IF;
    END;
  
    RETURN v_contact_name;
  END get_contact_name_by_id;

  FUNCTION get_age_by_date
  (
    par_contact_id contact.contact_id%TYPE
   ,par_date       DATE
  ) RETURN NUMBER IS
    v_age      NUMBER;
    v_real_age NUMBER;
  BEGIN
    SELECT MONTHS_BETWEEN(par_date, cp.date_of_birth) / 12
      INTO v_real_age
      FROM cn_person cp
     WHERE cp.contact_id = par_contact_id;
  
    IF v_real_age > 1
    THEN
      v_age := trunc(v_real_age);
    ELSE
      v_age := trunc(v_real_age * 100) / 100;
    END IF;
    RETURN v_age;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_age_by_date;

  /*
    Мизинов Г.В.
    Проверка использования указанного логина другими контактами. Возвращает false,
    если таких контактов нет и true, если логин уже кем-либо используется
    @param paR_contact_id - ИД контакта
    @param par_login - искомый логин
  */
  FUNCTION check_lk_login_exists
  (
    par_contact_id ins.contact.contact_id%TYPE
   ,par_login      ins.contact.profile_login%TYPE
  ) RETURN BOOLEAN IS
    v_profile_login_exists number;
  BEGIN
    SELECT COUNT(1)
      INTO v_profile_login_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_contact v
             WHERE v.profile_login = par_login
               AND v.contact_id != par_contact_id);
    RETURN v_profile_login_exists > 0;
  END check_lk_login_exists;

BEGIN

  SELECT id INTO v_issuer_contact_role_id FROM t_contact_role WHERE brief = 'ISSUER';

  SELECT id INTO v_benef_contact_role_id FROM t_contact_role WHERE brief = 'BENEFICIARY';

  SELECT id INTO v_assured_contact_role_id FROM t_contact_role WHERE brief = 'ASSURED';

  SELECT id
    INTO v_issuer_contact_pol_role_id
    FROM t_contact_pol_role
   WHERE brief = 'Страхователь';

  SELECT id
    INTO v_benef_contact_pol_role_id
    FROM t_contact_pol_role
   WHERE brief = 'Выгодоприобретатель';

  SELECT id
    INTO v_assured_contact_pol_role_id
    FROM t_contact_pol_role
   WHERE brief = 'Застрахованное лицо';

END pkg_contact; 
/
