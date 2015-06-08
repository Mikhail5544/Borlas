CREATE OR REPLACE PACKAGE pkg_load_file_to_table IS
  gc_column_type_date     CONSTANT load_csv_settings.data_type%TYPE := 'DATE';
  gc_column_type_varchar2 CONSTANT load_csv_settings.data_type%TYPE := 'VARCHAR2';
  gc_column_type_number   CONSTANT load_csv_settings.data_type%TYPE := 'NUMBER';

  ex_priority_conflicts_found EXCEPTION;
  ex_type_conflicts_found     EXCEPTION;
  ex_load_not_have_permission EXCEPTION;

  ----========================================================================----
  -- Общие процедуры и функции для загрузки файла в таблицу БД через BLOB
  ----========================================================================----
  TYPE t_varay IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  ----========================================================================----
  FUNCTION get_checked RETURN NUMBER;

  FUNCTION get_error RETURN NUMBER;

  FUNCTION get_nc_error RETURN NUMBER;

  FUNCTION get_not_loaded RETURN NUMBER;

  FUNCTION get_loaded RETURN NUMBER;

  FUNCTION get_part_loaded RETURN NUMBER;

  FUNCTION get_not_need_to_load RETURN NUMBER;

  FUNCTION get_max_column_count RETURN NUMBER;

  /*
    Получение приоритета для разбора конфликта при одинаком наименовании поля файла и поля файла параметров
    Если параметр не передан, используется занчение для текущего файла в кэше
  */
  FUNCTION get_conflict_priority(par_load_file_id load_file.load_file_id%TYPE DEFAULT NULL)
    RETURN load_csv_opt.conflict_priority%TYPE;

  /*
    Капля П.
    Получение кэша текущей строки
  */
  FUNCTION get_file_row_cache RETURN load_file_rows%ROWTYPE;

  /*
    Капля П.
    Получение кэша настроек для текщего файла
    Убрано из спецификации.
    Правильно спроектированные внешние процедуры не должны обращаться к кэшу напрямую.
    Если необходимо получение значения из кэша - можно написать функцию,
    но вероятнее всего это следствае плохого архитектурного решения.
  */
  --FUNCTION get_file_settings_cache RETURN t_load_file_settings_cache;

  /*
    Капля П.
    Получение числа строк файла
  */
  FUNCTION get_file_row_count(par_load_file_id load_file.load_file_id%TYPE) RETURN NUMBER;

  /*
    Капля П.
    Получение максимального номера столбца для текущего файла
  */
  FUNCTION get_csv_settings_max_col_num RETURN load_csv_settings.num%TYPE;

  PROCEDURE set_row_not_checked(par_load_file_rows_id NUMBER);

  PROCEDURE set_row_checked(par_load_file_rows_id NUMBER);

  -- Получить идентификатор из sq_temp_load_blob
  FUNCTION get_next_id RETURN NUMBER;
  ----========================================================================----
  -- Процедура создания строки во временной таблице для последующей загрузки в нее
  -- файла данных
  -- Параметр: идентификатор файла из sq_cn_bank_req_file
  PROCEDURE create_blob_temp_rec
  (
    par_id        NUMBER
   ,par_file_name VARCHAR2 DEFAULT 'Пусто'
  );
  ----========================================================================----
  -- Функция разбра строки данных
  FUNCTION str2array(p_str VARCHAR2) RETURN t_varay;
  ----========================================================================----
  -- Перевод 16-ричного значения в 10-ричное
  FUNCTION hex2dec(par_hexval IN CHAR) RETURN NUMBER;
  ----========================================================================----
  -- Описание статуса обработки строки файла по значению
  FUNCTION get_status_desc(par_status NUMBER) RETURN VARCHAR2;
  ----========================================================================----
  -- Создание новой строки в таблице загружаемых файлов
  -- Входные параметры: имя файла и код файла
  -- Результат: идентификатор файла (load_file_id)
  FUNCTION create_load_file_record
  (
    par_file_name         VARCHAR2
   ,par_file_code         VARCHAR2
   ,par_load_csv_list_id  NUMBER DEFAULT NULL
   ,par_actual_load_kladr DATE DEFAULT NULL
  ) RETURN NUMBER;
  ----========================================================================----

  /* sergey.ilyushkin   06/06/2012
    Парсинг BLOB в таблицу строк
    @param par_id - ИД сессии
    @param par_load_file_id - ИД файла
  */
  PROCEDURE parsing_clob
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );

  /* sergey.ilyushkin   06/06/2012
    Стандартная проверка загруженных строк
    1. Соответствие типов и размеров данных
    @param par_current_row - ИД текущей строки
  */
  --  procedure Standard_Check_Row(par_current_row number);
  /*
    Байтин А.
  
    Групповая проверка записей
  */
  PROCEDURE full_check_group(par_load_file_id NUMBER);

  /* sergey.ilyushkin   18/06/2012
    Динамический вызов всех (стандарт + пользовательские) процедур проверки
    загруженной строки
    @param par_Load_File_Rows_ID - ИД строки
  */
  PROCEDURE full_check_row(par_load_file_rows_id NUMBER);

  /*
    Капля П.
    Валидация заполнения полей хедера
  */
  PROCEDURE full_check_header
  (
    par_load_file_id load_file.load_file_id%TYPE
   ,par_row_status   OUT load_file_rows.row_status%TYPE
  );

  /*
    Байтин А.
    Групповая загрузка строк
  */
  PROCEDURE load_rows_group(par_load_file_id NUMBER);
  /* sergey.ilyushkin   18/06/2012
    Динамический вызов процедуры обработки загруженной строки
    @param par_Load_File_Rows_ID - ИД строки
  */
  PROCEDURE load_row(par_load_file_rows_id NUMBER);

  /*
    Байтин А.
    Запуск процедуры удаления строк таблицы перед загрузкой
    @param par_load_csv_list_id - ИД настройки
  */
  PROCEDURE delete_from_table(par_load_csv_list_id NUMBER);

  /*
    Капля П.
    Установка статуса и комментария по всем строкам файла
    Есть возможность управлять тем, будут ли проставлены данные по всем или только по незагруенным стркоам
  */
  PROCEDURE set_all_file_rows_status
  (
    par_load_file_id           load_file.load_file_id%TYPE
   ,par_status                 load_file_rows.row_status%TYPE
   ,par_comment                load_file_rows.row_comment%TYPE
   ,par_update_only_not_loaded BOOLEAN DEFAULT TRUE
  );
  PROCEDURE set_current_file_rows_status
  (
    par_status                 load_file_rows.row_status%TYPE
   ,par_comment                load_file_rows.row_comment%TYPE
   ,par_update_only_not_loaded BOOLEAN DEFAULT TRUE
  );

  /* Установка статуса выбранной строки
  @param par_Load_File_Rows_ID - ИД строки
  @param par_Row_Status - Новый статус строки
  @param par_Row_Comment - Описание текущего состояния строки
  @param par_Row_Status_CE - Описание критической ошибки
  @param par_ure_id - Ид сущности результата, связанного с данной записью
  @param par_uro_id - Ид объекта результата, связанного с данной записью
  */
  PROCEDURE set_row_status
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        NUMBER
   ,par_row_comment       VARCHAR2 DEFAULT NULL
   ,par_ure_id            NUMBER DEFAULT NULL
   ,par_uro_id            NUMBER DEFAULT NULL
   ,par_is_checked        NUMBER DEFAULT NULL
  );

  /*
    Капля П.
    Установка статуса текущей закэшированной строки
    @param par_Row_Status - Новый статус строки
    @param par_Row_Comment - Описание текущего состояния строки
    @param par_Row_Status_CE - Описание критической ошибки
    @param par_ure_id - Ид сущности результата, связанного с данной записью
    @param par_uro_id - Ид объекта результата, связанного с данной записью
  */
  PROCEDURE set_current_row_status
  (
    par_row_status  NUMBER
   ,par_row_comment VARCHAR2 DEFAULT NULL
   ,par_ure_id      NUMBER DEFAULT NULL
   ,par_uro_id      NUMBER DEFAULT NULL
   ,par_is_checked  NUMBER DEFAULT NULL
  );

  /*
    Байтин А.
    Добавление пакета настроек для загрузки из CSV
  */
  PROCEDURE insert_csv_list
  (
    par_load_csv_group_id NUMBER -- ИД группы загрузки
   ,par_brief             VARCHAR2 -- Краткое обозначение
   ,par_load_csv_name     VARCHAR2 -- Наименование пакета настроек
   ,par_check_procedure   VARCHAR2 DEFAULT NULL -- Имя пакетной процедуры для проверки записей
   ,par_load_procedure    VARCHAR2 DEFAULT NULL -- Имя пакетной процедуры для загрузки в рабочие таблицы
   ,par_start_date        DATE DEFAULT trunc(SYSDATE) -- Дата начала действия настроек
   ,par_end_date          DATE DEFAULT NULL -- Дата окончания действия настроек
   ,par_rows_in_header    NUMBER DEFAULT NULL -- Количество строк заголовка таблицы
   ,par_is_group_process  NUMBER DEFAULT NULL -- Флаг группового процесса
   ,par_delete_procedure  VARCHAR2 DEFAULT NULL -- процедура удаления
   ,par_delimiter         load_csv_list.delimiter%TYPE DEFAULT ';' -- разделитель
   ,par_call_form         load_csv_list.call_form%TYPE DEFAULT NULL -- форма для вызова по даблклику строки в Универсальном загрузчике
   ,par_call_form_par     load_csv_list.call_form_par%TYPE DEFAULT NULL -- параметр для указания при вызова формы
   ,par_load_csv_list_id  OUT NUMBER -- ИД добавленной записи
  );

  /**
  * Капля П.
  * Функция добавления столбца при настройке нового типа файла в Универсальном загрузчике
  * Позволят добавлять столец как в конец, так и в середину, двигая остальные столбцы
  */
  PROCEDURE insert_csv_file_column
  (
    par_load_csv_list_id       NUMBER
   ,par_column_name            VARCHAR2
   ,par_brief                  VARCHAR2 DEFAULT NULL
   ,par_data_type              VARCHAR2
   ,par_column_num             NUMBER DEFAULT NULL
   ,par_data_length            NUMBER DEFAULT NULL
   ,par_mandatory              NUMBER DEFAULT 0
   ,par_format                 VARCHAR2 DEFAULT NULL
   ,par_nls_numeric_characters VARCHAR2 DEFAULT NULL
   ,par_load_csv_settings_id   OUT NUMBER
  );

  PROCEDURE insert_csv_file_column
  (
    par_load_csv_list_id       NUMBER
   ,par_column_name            VARCHAR2
   ,par_brief                  VARCHAR2 DEFAULT NULL
   ,par_data_type              VARCHAR2
   ,par_column_num             NUMBER DEFAULT NULL
   ,par_data_length            NUMBER DEFAULT NULL
   ,par_mandatory              NUMBER DEFAULT 0
   ,par_format                 VARCHAR2 DEFAULT NULL
   ,par_nls_numeric_characters VARCHAR2 DEFAULT NULL
  );

  PROCEDURE insert_standard_column
  (
    par_load_csv_list_brief load_csv_list.brief%TYPE
   ,par_column_brief        load_csv_brief_proc.brief%TYPE
   ,par_column_num          load_csv_settings.num%TYPE DEFAULT NULL
   ,par_mandatory           NUMBER DEFAULT 0
   ,par_format              VARCHAR2 DEFAULT NULL
  );

  /**
  * Капля П.
  * Функция удаляет столбец из настройки типа файла в Универсальном загрузчике
  * Позволят удалять столбец, смещая столбцы, идущие за ним
  */
  PROCEDURE delete_csv_file_column
  (
    par_load_csv_settings_id NUMBER
   ,par_load_csv_list_id     NUMBER
   ,par_column_name          VARCHAR2
  );

  /*
    Капля П.
    Валидация содержимого заголовка файла
  */
  PROCEDURE standard_check_header
  (
    par_load_file_id load_file.load_file_id%TYPE
   ,par_row_status   OUT load_file_rows.row_status%TYPE
   ,par_row_comment  OUT load_file_rows.row_comment%TYPE
  );

  /*PROCEDURE standard_check_row
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  );*/

  /*
    Капля П.
  * Функция добавления столбца при настройке формата парсинга заголовка
  * нового типа файла в Универсальном загрузчике
  * Позволят добавлять столец как в конец, так и в середину, двигая остальные столбцы
  */
  PROCEDURE insert_csv_file_header_column
  (
    par_load_csv_list_brief VARCHAR2
   ,par_column_name         VARCHAR2
   ,par_brief               VARCHAR2
   ,par_column_num          load_csv_header_settings.num%TYPE
   ,par_row_num             load_csv_header_settings.row_num%TYPE DEFAULT 1
   ,par_data_type           VARCHAR2 DEFAULT 'VARCHAR2'
   ,par_data_length         NUMBER DEFAULT NULL
   ,par_mandatory           NUMBER DEFAULT 0
   ,par_format              VARCHAR2 DEFAULT NULL
  );

  PROCEDURE insert_csv_file_header_column
  (
    par_load_csv_list_id NUMBER
   ,par_column_name      VARCHAR2
   ,par_brief            VARCHAR2
   ,par_column_num       load_csv_header_settings.num%TYPE
   ,par_row_num          load_csv_header_settings.row_num%TYPE DEFAULT 1
   ,par_data_type        VARCHAR2 DEFAULT 'VARCHAR2'
   ,par_data_length      NUMBER DEFAULT NULL
   ,par_mandatory        NUMBER DEFAULT 0
   ,par_format           VARCHAR2 DEFAULT NULL
  );

  PROCEDURE insert_csv_file_header_column
  (
    par_load_csv_list_id          NUMBER
   ,par_column_name               VARCHAR2
   ,par_brief                     VARCHAR2
   ,par_column_num                load_csv_header_settings.num%TYPE
   ,par_row_num                   load_csv_header_settings.row_num%TYPE DEFAULT 1
   ,par_data_type                 VARCHAR2 DEFAULT 'VARCHAR2'
   ,par_data_length               NUMBER DEFAULT NULL
   ,par_mandatory                 NUMBER DEFAULT 0
   ,par_format                    VARCHAR2 DEFAULT NULL
   ,par_load_csv_head_settings_id OUT NUMBER
  );

  /*
    Капля П.
    Копирование шаблона парсинга строки заголовка CSV-файла
  */
  PROCEDURE copy_load_csv_header_settings
  (
    par_src_load_scv_list_brief  VARCHAR2
   ,par_dest_load_csv_list_brief VARCHAR2
  );
  PROCEDURE copy_load_csv_header_settings
  (
    par_src_load_scv_list_id  load_csv_list.load_csv_list_id%TYPE
   ,par_dest_load_csv_list_id load_csv_list.load_csv_list_id%TYPE
  );

  PROCEDURE copy_load_csv_settings
  (
    par_src_load_scv_list_brief  VARCHAR2
   ,par_dest_load_csv_list_brief VARCHAR2
  );

  PROCEDURE copy_load_csv_settings
  (
    par_src_load_scv_list_id  load_csv_list.load_csv_list_id%TYPE
   ,par_dest_load_csv_list_id load_csv_list.load_csv_list_id%TYPE
  );

  PROCEDURE copy_load_csv_list
  (
    par_src_load_scv_list_brief load_csv_list.brief%TYPE
   ,par_new_name                load_csv_list.load_csv_name%TYPE
   ,par_new_brief               load_csv_list.brief%TYPE
  );
  PROCEDURE copy_load_csv_list(par_src_load_scv_list_brief load_csv_list.brief%TYPE);

  /*
    Пиядин А.
    Функция возвращает комментарий записи
  */
  FUNCTION get_row_comment(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) RETURN VARCHAR2;

  /*
    Капля П.
    Инициализация работы с файлом
    При этом заполняется кеш настроек для файла, заполняется массив маппинга столбцов и описание заголовка
    Также загружается значение параметров загрузки
  */
  PROCEDURE init_file(par_load_file_id load_file.load_file_id%TYPE);

  /*
    Капля П.
    Кешируем текущую строчку, с которой будем в дальнейшем работать.
    Необходимо для применения функций получения значений по брифу
  */
  PROCEDURE cache_row(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);
  PROCEDURE cache_row(par_rowid UROWID);
  PROCEDURE cache_row(par_record load_file_rows%ROWTYPE);

  /*\*
    Капля П.
    Получение номера колонки по брифу столбца
  *\
  FUNCTION get_column_num_by_brief(par_column_brief load_csv_settings.brief%TYPE)
    RETURN load_csv_settings.num%TYPE;
  
  \*
    Капля П.
    Получение значения столбца текущей закешированной строки по брифу колонки
  *\
  FUNCTION get_row_value_by_column_brief
  (
    par_column_brief     load_csv_settings.brief%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN load_file_rows.val_1%TYPE;
  
  \*
    Капля П.
    Получение значения столбца текущей закешированной строки по номеру столбца
  *\
  FUNCTION get_row_value_by_column_num
  (
    par_column_num       load_csv_settings.num%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN load_file_rows.val_1%TYPE;
  
  \*
    Капля П.
    Получение значения параметра для текущего правила загрузки и выбранного набора параметров
  *\
  FUNCTION get_parameter_value
  (
    par_option_brief   load_csv_opt_set.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT FALSE
  ) RETURN load_csv_opt_set.value%TYPE;*/

  /*
    Капля П.
    Получение значения параметра заголовка теукщего файла по брифу
  */
  FUNCTION get_file_header_param_string
  (
    par_parameter_brief load_csv_header_settings.brief%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN load_file_header_params.value%TYPE;
  FUNCTION get_file_header_param_number
  (
    par_parameter_brief load_csv_header_settings.brief%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER;
  FUNCTION get_file_header_param_date
  (
    par_parameter_brief load_csv_header_settings.brief%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN DATE;

  /*
    Капля П.
    Получение занчения из строки файли или набора дополнительных параметров по брифу в соответствие с приоритетом разрешения конфликтов
    При получение значения не проверяется соответствие типов тому, что описано в настройке шаблона (load_csv_load)
  */
  FUNCTION get_value_by_brief
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;

  FUNCTION get_value_string
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;
  FUNCTION get_value_date
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN DATE;
  FUNCTION get_value_number
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  /*
    Капля П.
    Процеряка наличия конфликтов в описании шаблона загрузки
  */
  PROCEDURE check_conflicts(par_load_file_id load_file.load_file_id%TYPE);

  /*
    Пиядин А.
    Проуедура проверки прав
  */
  PROCEDURE check_rights
  (
    par_load_file_id load_file.load_file_id%TYPE
   ,par_right_brief  safety_right.brief%TYPE
  );

  /*
    Пиядин А.
    Возвращает текущий порядковый номер в Журнале диагностики для текущего загружаемого файла
  */
  FUNCTION get_current_log_load_order_num RETURN load_file_row_log.load_order_num%TYPE;

END pkg_load_file_to_table; 
/
CREATE OR REPLACE PACKAGE BODY pkg_load_file_to_table IS
  ----========================================================================----
  -- Общие процедуры и функции для загрузки файла в таблицу БД через BLOB
  ----========================================================================----
  TYPE t_setting_summary IS RECORD(
     num                    load_csv_settings.num%TYPE
    ,column_name            load_csv_settings.column_name%TYPE
    ,data_type              load_csv_settings.data_type%TYPE
    ,mandatory              load_csv_settings.mandatory%TYPE
    ,format                 load_csv_settings.format%TYPE
    ,nls_numeric_characters load_csv_settings.nls_numeric_characters%TYPE);

  TYPE tt_column_papping IS TABLE OF t_setting_summary INDEX BY load_csv_settings.brief%TYPE;

  TYPE t_option_summary IS RECORD(
     VALUE       load_csv_opt_set.value%TYPE
    ,data_type   load_csv_opt_set.data_type%TYPE
    ,column_name load_csv_opt_set.column_name%TYPE);

  TYPE tt_option_cache IS TABLE OF t_option_summary INDEX BY load_csv_opt_set.brief%TYPE;

  TYPE t_header_param_summary IS RECORD(
     column_name            load_csv_header_settings.column_name%TYPE
    ,VALUE                  load_file_header_params.value%TYPE
    ,data_type              load_csv_header_settings.data_type%TYPE
    ,data_length            load_csv_header_settings.data_length%TYPE
    ,mandatory              load_csv_header_settings.mandatory%TYPE
    ,format                 load_csv_header_settings.format%TYPE
    ,nls_numeric_characters load_csv_header_settings.nls_numeric_characters%TYPE);

  TYPE tt_header_param_cache IS TABLE OF t_header_param_summary INDEX BY load_csv_header_settings.brief%TYPE;

  TYPE t_load_file_settings_cache IS RECORD(
     load_file_id     load_file.load_file_id%TYPE
    ,load_csv_list_id load_csv_list.load_csv_list_id%TYPE
    ,load_csv_opt_id  load_csv_opt.load_csv_opt_id%TYPE
    ,load_procedure   load_csv_list.load_procedure%TYPE
    ,check_procedure  load_csv_list.check_procedure%TYPE
    --,delete_procedure       load_csv_list.delete_procedure%type
    ,conflict_priority      load_csv_opt.conflict_priority%TYPE
    ,column_papping         tt_column_papping
    ,PARAMETERS             tt_option_cache
    ,file_header_parameters tt_header_param_cache
    ,log_load_order_num     load_file_row_log.load_order_num%TYPE);

  c_error            CONSTANT NUMBER(1) := -1;
  c_not_loaded       CONSTANT NUMBER(1) := 0;
  c_loaded           CONSTANT NUMBER(1) := 1;
  c_part_loaded      CONSTANT NUMBER(1) := 2;
  c_not_need_to_load CONSTANT NUMBER(1) := 3;
  c_checked          CONSTANT NUMBER(1) := 4;
  c_nc_error         CONSTANT NUMBER(1) := -2; -- non critical error

  gc_conflict_disallowed CONSTANT load_csv_opt.conflict_priority%TYPE := 0;

  gc_default_date_format   CONSTANT load_csv_settings.format%TYPE := 'dd.mm.yyyy';
  gc_default_number_format CONSTANT load_csv_settings.format%TYPE := '99999999999999999999999999999D99999999999999999999999999999';
  gc_default_nls_num_char  CONSTANT load_csv_settings.nls_numeric_characters%TYPE := '.,';

  gc_max_column_count CONSTANT INTEGER := 300;

  day_of_month_error EXCEPTION;
  date_format_error  EXCEPTION;
  not_a_numeric_char EXCEPTION;
  proc_dont_exists   EXCEPTION;

  gv_load_file_row_cache      load_file_rows%ROWTYPE;
  gv_load_file_settings_cache t_load_file_settings_cache;

  PRAGMA EXCEPTION_INIT(day_of_month_error, -1847);
  PRAGMA EXCEPTION_INIT(date_format_error, -1861);
  PRAGMA EXCEPTION_INIT(not_a_numeric_char, -1858);
  PRAGMA EXCEPTION_INIT(proc_dont_exists, -06550);

  FUNCTION get_checked RETURN NUMBER IS
  BEGIN
    RETURN c_checked;
  END;

  FUNCTION get_error RETURN NUMBER IS
  BEGIN
    RETURN c_error;
  END;

  FUNCTION get_nc_error RETURN NUMBER IS
  BEGIN
    RETURN c_nc_error;
  END;

  FUNCTION get_not_loaded RETURN NUMBER IS
  BEGIN
    RETURN c_not_loaded;
  END;

  FUNCTION get_loaded RETURN NUMBER IS
  BEGIN
    RETURN c_loaded;
  END;

  FUNCTION get_part_loaded RETURN NUMBER IS
  BEGIN
    RETURN c_part_loaded;
  END;

  FUNCTION get_not_need_to_load RETURN NUMBER IS
  BEGIN
    RETURN c_not_need_to_load;
  END;

  FUNCTION get_max_column_count RETURN NUMBER IS
  BEGIN
    RETURN gc_max_column_count;
  END get_max_column_count;

  FUNCTION get_file_row_cache RETURN load_file_rows%ROWTYPE IS
  BEGIN
    RETURN gv_load_file_row_cache;
  END get_file_row_cache;

  FUNCTION get_conflict_priority(par_load_file_id load_file.load_file_id%TYPE DEFAULT NULL)
    RETURN load_csv_opt.conflict_priority%TYPE IS
    v_conflict_priority load_csv_opt.conflict_priority%TYPE;
  BEGIN
    IF par_load_file_id IS NULL
    THEN
      v_conflict_priority := gv_load_file_settings_cache.conflict_priority;
    ELSE
      BEGIN
        SELECT lco.conflict_priority
          INTO v_conflict_priority
          FROM load_file    lf
              ,load_csv_opt lco
         WHERE 1 = 1
           AND lf.load_csv_opt_id = lco.load_csv_opt_id
           AND lf.load_file_id = par_load_file_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_conflict_priority := NULL;
      END;
    END IF;
    RETURN v_conflict_priority;
  END get_conflict_priority;

  -- Получить идентификатор из sq_temp_load_blob
  FUNCTION get_next_id RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT sq_temp_load_blob.nextval INTO v_id FROM dual;
    RETURN(v_id);
  END get_next_id;

  FUNCTION convert_to_number
  (
    par_value        VARCHAR2
   ,par_format       VARCHAR2 DEFAULT gc_default_number_format
   ,par_nls_num_char VARCHAR2 DEFAULT gc_default_nls_num_char
  ) RETURN NUMBER IS
    v_value NUMBER;
  BEGIN
    v_value := to_number(REPLACE(TRIM(par_value), ',', '.')
                        ,nvl(par_format, gc_default_number_format)
                        ,'NLS_NUMERIC_CHARACTERS = ''' ||
                         nvl(par_nls_num_char, gc_default_nls_num_char) || '''');
  
    RETURN v_value;
  END convert_to_number;

  /*
    Капля П.
    Получение максимального номера столбца для текущего файла
  */
  FUNCTION get_csv_settings_max_col_num RETURN load_csv_settings.num%TYPE IS
    v_max_num load_csv_settings.num%TYPE;
  BEGIN
    SELECT MAX(num)
      INTO v_max_num
      FROM load_csv_settings l
     WHERE l.load_csv_list_id = gv_load_file_settings_cache.load_csv_list_id;
  
    RETURN v_max_num;
  END get_csv_settings_max_col_num;

  FUNCTION get_file_settings_cache RETURN t_load_file_settings_cache IS
  BEGIN
    RETURN gv_load_file_settings_cache;
  END get_file_settings_cache;

  FUNCTION get_file_row_count(par_load_file_id load_file.load_file_id%TYPE) RETURN NUMBER IS
    v_count     NUMBER;
    v_load_file dml_load_file.tt_load_file;
  BEGIN
    v_load_file := dml_load_file.get_record(par_load_file_id);
    IF v_load_file.load_file_id IS NOT NULL
    THEN
      SELECT COUNT(*)
        INTO v_count
        FROM load_file_rows l
       WHERE l.load_file_id = v_load_file.load_file_id;
    END IF;
    RETURN v_count;
  END get_file_row_count;

  PROCEDURE set_row_not_checked(par_load_file_rows_id NUMBER) IS
  BEGIN
    UPDATE load_file_rows lf SET lf.is_checked = 0 WHERE lf.load_file_rows_id = par_load_file_rows_id;
  END set_row_not_checked;

  PROCEDURE set_row_checked(par_load_file_rows_id NUMBER) IS
  BEGIN
    UPDATE load_file_rows lf SET lf.is_checked = 1 WHERE lf.load_file_rows_id = par_load_file_rows_id;
  END set_row_checked;

  --function get_current_row

  /* sergey.ilyushkin   06/06/2012
    Конвертация загруженного BLOB в CLOB
    @param par_session_id - ИД сессии
  */
  PROCEDURE convert_blob_to_clob(par_session_id NUMBER) IS
    v_blob BLOB;
    v_clob CLOB;
  
    ilen     INTEGER := dbms_lob.lobmaxsize;
    isrcoffs INTEGER := 1;
    idstoffs INTEGER := 1;
    ilang    INTEGER := dbms_lob.default_lang_ctx;
    iwarn    INTEGER;
  BEGIN
    SELECT file_blob INTO v_blob FROM temp_load_blob WHERE session_id = par_session_id FOR UPDATE;
  
    dbms_lob.createtemporary(v_clob, TRUE);
    dbms_lob.converttoclob(v_clob
                          ,v_blob
                          ,ilen
                          ,isrcoffs
                          ,idstoffs
                          ,dbms_lob.default_csid
                          ,ilang
                          ,iwarn);
    UPDATE temp_load_blob SET file_clob = v_clob WHERE session_id = par_session_id;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  ----========================================================================----
  -- Процедура создания строки во временной таблице для последующей загрузки в нее
  -- файла данных
  -- Параметр: идентификатор файла из sq_temp_load_blob
  PROCEDURE create_blob_temp_rec
  (
    par_id        NUMBER
   ,par_file_name VARCHAR2 DEFAULT 'Пусто'
  ) IS
  BEGIN
    DELETE FROM temp_load_blob WHERE session_id = par_id;
    INSERT INTO temp_load_blob (session_id, file_name) VALUES (par_id, par_file_name);
    COMMIT;
  END create_blob_temp_rec;
  ----========================================================================----
  -- Функция разбра строки данных
  FUNCTION str2array(p_str VARCHAR2) RETURN t_varay IS
    v_offset NUMBER := 1;
    v_length NUMBER := 0;
    va_res   t_varay;
  BEGIN
    FOR i IN 1 .. gc_max_column_count
    LOOP
      v_length := instr(p_str, ';', v_offset);
      IF v_length = 0
      THEN
        va_res(i) := TRIM(substr(p_str, v_offset));
        EXIT;
      ELSE
        va_res(i) := TRIM(substr(p_str, v_offset, v_length - v_offset));
      END IF;
      v_offset := v_length + 1;
    END LOOP;
    RETURN va_res;
  END str2array;
  ----========================================================================----
  -- Перевод 16-ричного значения в 10-ричное
  FUNCTION hex2dec(par_hexval IN CHAR) RETURN NUMBER IS
    v_digits            NUMBER;
    v_result            NUMBER := 0;
    v_current_digit     CHAR(1);
    v_current_digit_dec NUMBER;
  BEGIN
    v_digits := length(par_hexval);
    FOR i IN 1 .. v_digits
    LOOP
      v_current_digit := substr(par_hexval, i, 1);
      IF v_current_digit IN ('A', 'B', 'C', 'D', 'E', 'F')
      THEN
        v_current_digit_dec := ascii(v_current_digit) - ascii('A') + 10;
      ELSE
        v_current_digit_dec := to_number(v_current_digit);
      END IF;
      v_result := (v_result * 16) + v_current_digit_dec;
    END LOOP;
    RETURN(v_result);
  END hex2dec;
  ----========================================================================----
  -- Описание статуса обработки строки файла по значению
  FUNCTION get_status_desc(par_status NUMBER) RETURN VARCHAR2 IS
    v_return VARCHAR2(100);
  BEGIN
    CASE par_status
      WHEN c_not_loaded THEN
        v_return := 'Не обработано';
      WHEN c_loaded THEN
        v_return := 'Обработано';
      WHEN c_part_loaded THEN
        v_return := 'Обработано частично';
      WHEN c_not_need_to_load THEN
        v_return := 'Обработка не потребовалась';
      WHEN c_error THEN
        v_return := 'Ошибка';
      WHEN c_checked THEN
        v_return := 'Проверено';
      WHEN c_nc_error THEN
        v_return := 'Некритичная ошибка';
      ELSE
        v_return := NULL;
    END CASE;
    RETURN(v_return);
  END get_status_desc;
  ----========================================================================----
  -- Создание новой строки в таблице загружаемых файлов
  -- Входные параметры: имя файла и код файла
  -- Результат: идентификатор файла (load_file_id)
  FUNCTION create_load_file_record
  (
    par_file_name         VARCHAR2
   ,par_file_code         VARCHAR2
   ,par_load_csv_list_id  NUMBER DEFAULT NULL
   ,par_actual_load_kladr DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_load_file_id NUMBER;
    v_opt_id       NUMBER;
  BEGIN
    -- Сразу выбираем набор параметров, если он единственный
  BEGIN
      SELECT MIN(t.load_csv_opt_id)
        INTO v_opt_id
        FROM load_csv_opt t
       WHERE t.load_csv_list_id = par_load_csv_list_id
       GROUP BY t.load_csv_list_id
      HAVING COUNT(*) = 1;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    dml_load_file.insert_record(par_file_code         => par_file_code
                               ,par_file_name         => par_file_name
                               ,par_load_csv_list_id  => par_load_csv_list_id
                               ,par_actual_date_kladr => par_actual_load_kladr
                               ,par_load_csv_opt_id   => v_opt_id
                               ,par_load_file_id      => v_load_file_id);
  
    RETURN(v_load_file_id);
  END create_load_file_record;

  /*
    Капля П.
    Получение значения столбца текущей закешированной строки по номеру столбца
  */
  FUNCTION get_row_value_by_column_num
  (
    par_column_num       load_csv_settings.num%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN load_file_rows.val_1%TYPE IS
    v_value load_file_rows.val_1%TYPE;
  BEGIN
    assert_deprecated(gv_load_file_settings_cache.load_file_id IS NULL
          ,'Для использования функции получения значения столбца текущая строка должна быть закеширована.');
    assert_deprecated(par_column_num IS NULL, 'Номер столбца не может быть пуст');
    assert_deprecated(par_column_num > get_max_column_count
          ,'Столбец ' || par_column_num || ' не предусмотрен форматом файла');
  
    IF par_load_file_row_id IS NULL
    THEN
      EXECUTE IMMEDIATE 'begin :val := pkg_load_file_to_table.get_file_row_cache().val_' ||
                        par_column_num || '; end;'
        USING OUT v_value;
    ELSE
      BEGIN
        EXECUTE IMMEDIATE 'select val_' || par_column_num ||
                          ' from load_file_rows l where l.load_file_rows_id = :p1'
          INTO v_value
          USING par_load_file_row_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  
    RETURN v_value;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_load_logging.set_critical_error(par_load_file_rows_id    => nvl(par_load_file_row_id
                                                                         ,gv_load_file_row_cache.load_file_rows_id)
                                         ,par_load_order_num       => gv_load_file_settings_cache.log_load_order_num
                                         ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                         ,par_log_msg              => 'Не удалось получить значение столбца (' ||
                                                                      par_column_num ||
                                                                      ') текущей строки загружаемого файла'
                                         ,par_load_stage           => pkg_load_logging.get_check_single);
      RETURN NULL;
  END get_row_value_by_column_num;

  /*
    Капля П.
    Получение номера колонки по брифу столбца
  */
  FUNCTION get_column_num_by_brief(par_column_brief load_csv_settings.brief%TYPE)
    RETURN load_csv_settings.num%TYPE IS
  BEGIN
    RETURN gv_load_file_settings_cache.column_papping(upper(par_column_brief)).num;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не удалось определить номер столбца по брифу ' || par_column_brief);
  END get_column_num_by_brief;

  /*
    Капля П.
    Получение значения столбца текущей закешированной строки по брифу колонки
  */
  FUNCTION get_row_value_by_column_brief
  (
    par_column_brief     load_csv_settings.brief%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN load_file_rows.val_1%TYPE IS
    v_column_num load_csv_settings.num%TYPE;
    v_result     load_file_rows.val_1%TYPE;
  BEGIN
    BEGIN
      v_column_num := get_column_num_by_brief(upper(par_column_brief));
    EXCEPTION
      WHEN ex.no_data_found THEN
        NULL;
    END;
  
    IF v_column_num IS NOT NULL
    THEN
      v_result := get_row_value_by_column_num(v_column_num, par_load_file_row_id);
    END IF;
  
    RETURN v_result;
  END get_row_value_by_column_brief;

  ----========================================================================----

  /* sergey.ilyushkin   06/06/2012
    Разбор строки с разделителями в массив
    @param par_line - Строка для парсинга
    @return массив отдельных полей
  */
  FUNCTION str_to_array
  (
    par_line          VARCHAR2
   ,par_columns_count NUMBER
   ,par_delimiter     VARCHAR2
  ) RETURN t_varay IS
    v_retval           t_varay;
    v_line             VARCHAR2(32767) := NULL;
    v_regexp_template  VARCHAR2(500) := '(("[^"]*")|([^;]*))(;|$)'; --Старый '(^"[^"]+|;"[^"]+)|(^[^;]+|;[^;]+)|;' не берет первый пустой столбец
    v_regexp_delimiter VARCHAR2(20);
  BEGIN
    v_retval.delete;
    IF (par_line IS NULL)
       OR (length(REPLACE(par_line, par_delimiter)) = 0)
    THEN
      RETURN CAST(NULL AS t_varay);
    END IF;
  
    IF instr('|^[].${}*()\+?<>', par_delimiter) > 0 /*символы, которые экранируются*/
    THEN
      v_regexp_delimiter := '\' || par_delimiter;
    ELSE
      v_regexp_delimiter := par_delimiter;
    END IF;
  
    IF par_delimiter != ';'
    THEN
      v_regexp_template := '(("[^"]*")|([^' || par_delimiter || ']*))(' || v_regexp_delimiter || '|$)';
    END IF;
  
    --Убираем кавычки в начале и в конце строки, в середине кавычки отсутствуют
    SELECT nvl(substr(regexp_substr(REPLACE(REPLACE(par_line, chr(10), ''), chr(13), ''), '^"[^"]+"$')
                     ,2
                     ,length(par_line) - 2)
              ,par_line)
      INTO v_line
      FROM dual;
  
    FOR v_idx IN 1 .. par_columns_count
    LOOP
      /*1. Заменяем две двойные кавычки на стрелочку, чтобы разбиралась
      "   ""ООО Привет""   " -> "   ††ООО Привет††   "
        2. Заменяем две одинарные кавычки на 4, чтобы в результате осталось 2
        ''ООО Привет'' -> ''''ООО Привет'''' (в таблице load_file_rows.val_= ''ООО Привет'')
        Логика шаблона регулярки '(("[^"]*")|([^;]*))(;|$)':
          1) значением является 0 или более символов, заключенных в кавычки (где внутри нет кавычек), которые заканчиваются ; или концом строки
          2) значением является 0 или более символов, которые заканчиваются ; или концом строки
      
        3. Убираем ; в конце, которая остается после работы регулярки
        4. Заменяем обратно стрелочки на кавычки
        5. Убираем новую строку chr(10) и возврат каретки chr(13)
      */
      v_retval(v_idx) := rtrim(rtrim(REPLACE(rtrim(regexp_substr(REPLACE(REPLACE(v_line
                                                                                             ,'""'
                                                                                             ,chr(134))
                                                                                     ,''''
                                                                                     ,'''''')
                                                                             ,v_regexp_template
                                                                             ,1
                                                                             ,v_idx)
                                                  ,par_delimiter)
                                            ,chr(134)
                                            ,'"')
                                    ,chr(10))
                              ,chr(13));
    END LOOP;
  
    RETURN v_retval;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('1_'||sqlerrm);
      v_retval.delete;
      RETURN CAST(NULL AS t_varay);
  END str_to_array;

  /* sergey.ilyushkin   06/06/2012
    Парсинг BLOB в таблицу строк
    @param par_id - ИД сессии
    @param par_load_file_id - ИД файла
  */
  PROCEDURE parsing_clob
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    v_clob_data        CLOB;
    v_str_count        NUMBER := 0;
    v_clob_len         NUMBER := 0;
    v_old_pos          NUMBER := 0;
    v_new_pos          NUMBER := 0;
    v_line             VARCHAR2(32767) := NULL;
    va_values          t_varay;
    vt_columns         t_varay;
    v_base_sql_str     VARCHAR2(32767) := NULL;
    v_sql_str          VARCHAR2(32767) := NULL;
    v_rows_in_header   load_csv_list.rows_in_header%TYPE;
    v_load_csv_list_id NUMBER;
    v_delimiter        load_csv_list.delimiter%TYPE;
  
    PROCEDURE fill_load_file_header_params
    (
      par_load_file_id load_file.load_file_id%TYPE
     ,par_delimiter    load_csv_list.delimiter%TYPE
    ) IS
      v_old_pos PLS_INTEGER := 0;
      v_new_pos PLS_INTEGER := 0;
      v_line    VARCHAR2(32767);
      va_values t_varay;
    BEGIN
      FOR rec_line IN (SELECT t.row_num
                             ,COUNT(*) AS params_in_row_count
                         FROM load_csv_header_settings t
                        WHERE t.load_csv_list_id = v_load_csv_list_id
                        GROUP BY t.row_num
                        ORDER BY t.row_num)
      LOOP
        v_new_pos := dbms_lob.instr(v_clob_data, chr(10), v_old_pos + 1);
      
        v_line := dbms_lob.substr(v_clob_data, v_new_pos - v_old_pos, v_old_pos + 1);
      
        va_values.delete;
        va_values := str_to_array(v_line, rec_line.params_in_row_count, par_delimiter);
      
        v_old_pos := v_new_pos;
      
        FOR rec_col IN (SELECT t.*
                          FROM load_csv_header_settings t
                         WHERE t.load_csv_list_id = v_load_csv_list_id
                           AND t.row_num = rec_line.row_num
                         ORDER BY t.num)
        LOOP
          dml_load_file_header_params.insert_record(par_load_file_id               => par_load_file_id
                                                   ,par_load_csv_header_setting_id => rec_col.load_csv_header_settings_id
                                                   ,par_value                      => va_values(rec_col.num));
        END LOOP;
      END LOOP;
    
    END fill_load_file_header_params;
  BEGIN
    convert_blob_to_clob(par_id);
    SAVEPOINT before_load;
  
    BEGIN
      SELECT file_clob INTO v_clob_data FROM temp_load_blob WHERE session_id = par_id FOR UPDATE;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    /*
      Байтин А.
      Получаем количество строк заголовка из настроек
    */
    SELECT cl.rows_in_header
          ,cl.load_csv_list_id
          ,cl.delimiter
      INTO v_rows_in_header
          ,v_load_csv_list_id
          ,v_delimiter
      FROM load_csv_list cl
          ,load_file     lf
     WHERE lf.load_file_id = par_load_file_id
       AND lf.load_csv_list_id = cl.load_csv_list_id;
  
    SELECT cs.column_name BULK COLLECT
      INTO vt_columns
      FROM load_csv_settings cs
          ,(SELECT LEVEL num
              FROM dual
            CONNECT BY LEVEL <= (SELECT MAX(num)
                                   FROM load_csv_settings cs2
                                  WHERE cs2.load_csv_list_id = v_load_csv_list_id)) d
     WHERE cs.load_csv_list_id(+) = v_load_csv_list_id
       AND d.num = cs.num(+);
  
    v_clob_len := dbms_lob.getlength(v_clob_data);
  
    IF v_clob_len > 0
    THEN
      v_str_count := 1;
    
      fill_load_file_header_params(par_load_file_id => par_load_file_id, par_delimiter => v_delimiter);
    
      -- Исключаем заголовок
      IF v_rows_in_header > 0
      THEN
        v_old_pos := dbms_lob.instr(v_clob_data, chr(10), 1, v_rows_in_header);
      END IF;
    
      LOOP
        EXIT WHEN(v_new_pos >= v_clob_len);
        v_new_pos := dbms_lob.instr(v_clob_data, chr(10), v_old_pos + 1);
        IF v_new_pos > 0
        THEN
          v_line := dbms_lob.substr(v_clob_data, v_new_pos - v_old_pos, v_old_pos + 1);
          va_values.delete;
          va_values := str_to_array(v_line, vt_columns.count, v_delimiter);
        
          IF v_str_count = 1
          THEN
            v_base_sql_str := 'insert into LOAD_FILE_ROWS (LOAD_FILE_ROWS_ID, LOAD_FILE_ID, ROW_STATUS, IS_CHECKED';
            FOR i IN 1 .. vt_columns.count
            LOOP
              v_base_sql_str := v_base_sql_str || ', VAL_' || i;
            END LOOP;
            v_base_sql_str := v_base_sql_str || ') (select SQ_LOAD_FILE_ROWS.nextval, ' ||
                              par_load_file_id || ', 0, 1';
          END IF;
        
          v_sql_str := NULL;
          FOR i IN 1 .. vt_columns.count
          LOOP
            v_sql_str := v_sql_str || ', ''' || va_values(i) || '''';
          END LOOP;
          v_sql_str := v_base_sql_str || v_sql_str || ' from dual)';
          BEGIN
            EXECUTE IMMEDIATE v_sql_str;
            COMMIT;
            --dbms_output.put_line('OK '||v_SQL_Str);
          EXCEPTION
            WHEN OTHERS THEN
              --dbms_output.put_line('ERR '||v_SQL_Str);
              --dbms_output.put_line(SQLERRM);
              NULL;
          END;
        ELSE
          v_new_pos := v_clob_len;
        END IF;
        v_str_count := v_str_count + 1;
        v_old_pos   := v_new_pos;
      END LOOP;
    END IF;
    va_values.delete;
  END parsing_clob;

  /* Проверка одного значения */
  PROCEDURE check_single_value
  (
    par_value          VARCHAR2
   ,par_column_name    VARCHAR2
   ,par_data_type      VARCHAR2
   ,par_data_length    NUMBER
   ,par_mandatory      NUMBER
   ,par_format         VARCHAR2
   ,par_nls_num_char   VARCHAR2
   ,par_data_precision NUMBER DEFAULT NULL
   ,par_row_status     OUT load_file_rows.row_status%TYPE
   ,par_row_comment    OUT load_file_rows.row_comment%TYPE
  ) IS
    v_check_number NUMBER;
    v_check_date   DATE;
  BEGIN
    par_row_status := get_checked;
    IF par_mandatory = 1
       AND par_value IS NULL
    THEN
      par_row_status  := c_error;
      par_row_comment := 'Значение в поле "' || par_column_name || '" должно быть обязательно указано';
      IF gv_load_file_row_cache.load_file_rows_id IS NOT NULL
      THEN
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_row_cache.load_file_rows_id
                                           ,par_load_order_num       => gv_load_file_settings_cache.log_load_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                           ,par_log_msg              => par_row_comment
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      ELSE
        ex.raise(par_row_comment);
      END IF;
    END IF;
    IF par_row_status != c_error
       AND par_value IS NOT NULL
    THEN
      CASE par_data_type
        WHEN 'VARCHAR2' THEN
          IF length(par_value) > par_data_length
          THEN
            par_row_status  := c_error;
            par_row_comment := 'Значение "' || par_value || '" в поле "' || par_column_name ||
                               '" превышает допустимое количество символов: ' ||
                               to_char(length(par_value));
            IF gv_load_file_row_cache.load_file_rows_id IS NOT NULL
            THEN
              pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_row_cache.load_file_rows_id
                                                 ,par_load_order_num       => gv_load_file_settings_cache.log_load_order_num
                                                 ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                                 ,par_log_msg              => par_row_comment
                                                 ,par_load_stage           => pkg_load_logging.get_check_single);
            ELSE
              ex.raise(par_row_comment);
            END IF;
          END IF;
        WHEN 'NUMBER' THEN
          BEGIN
            v_check_number := convert_to_number(par_value        => par_value
                                               ,par_format       => par_format
                                               ,par_nls_num_char => par_nls_num_char);
          
          EXCEPTION
            WHEN value_error THEN
              par_row_status  := c_error;
              par_row_comment := 'Значение "' || par_value || '" в поле "' || par_column_name ||
                                 '" не является числом';
              IF gv_load_file_row_cache.load_file_rows_id IS NOT NULL
              THEN
                pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_row_cache.load_file_rows_id
                                                   ,par_load_order_num       => gv_load_file_settings_cache.log_load_order_num
                                                   ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                                   ,par_log_msg              => par_row_comment
                                                   ,par_load_stage           => pkg_load_logging.get_check_single);
              ELSE
                ex.raise(par_row_comment);
              END IF;
          END;
        WHEN 'DATE' THEN
          BEGIN
            v_check_date := to_date(par_value, nvl(par_format, gc_default_date_format));
          EXCEPTION
            WHEN date_format_error
                 OR day_of_month_error
                 OR not_a_numeric_char
                 OR pkg_oracle_exceptions.date_format_pic_ends THEN
              par_row_status  := c_error;
              par_row_comment := 'Значение "' || par_value || '" в поле "' || par_column_name ||
                                 '" не является датой в формате "' ||
                                 nvl(par_format, gc_default_date_format) || '"';
              IF gv_load_file_row_cache.load_file_rows_id IS NOT NULL
              THEN
                pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_row_cache.load_file_rows_id
                                                   ,par_load_order_num       => gv_load_file_settings_cache.log_load_order_num
                                                   ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                                   ,par_log_msg              => par_row_comment
                                                   ,par_load_stage           => pkg_load_logging.get_check_single);
              ELSE
                ex.raise(par_row_comment);
              END IF;
          END;
      END CASE;
    END IF;
  END check_single_value;

  /*
    Капля П.
    Валидация содержимого заголовка файла
  */
  PROCEDURE standard_check_header
  (
    par_load_file_id load_file.load_file_id%TYPE
   ,par_row_status   OUT load_file_rows.row_status%TYPE
   ,par_row_comment  OUT load_file_rows.row_comment%TYPE
  ) IS
    v_value       load_file_header_params.value%TYPE;
    v_row_status  load_file_rows.row_status%TYPE := c_checked;
    v_row_comment load_file_rows.row_comment%TYPE := NULL;
  
  BEGIN
    FOR rec IN (SELECT *
                  FROM load_csv_header_settings t
                 WHERE t.load_csv_list_id = gv_load_file_settings_cache.load_csv_list_id)
    LOOP
      v_value := get_file_header_param_string(par_parameter_brief => rec.brief);
    
      check_single_value(par_value        => v_value
                        ,par_column_name  => rec.column_name
                        ,par_data_type    => rec.data_type
                        ,par_data_length  => rec.data_length
                        ,par_mandatory    => rec.mandatory
                        ,par_format       => rec.format
                        ,par_nls_num_char => rec.nls_numeric_characters
                        ,par_row_status   => par_row_status
                        ,par_row_comment  => par_row_comment);
      IF par_row_status = c_error
      THEN
        v_row_status  := par_row_status;
        v_row_comment := par_row_comment;
      END IF;
    END LOOP;
  
    par_row_status  := v_row_status;
    par_row_comment := nvl(v_row_comment, par_row_comment);
  END standard_check_header;

  /* sergey.ilyushkin   06/06/2012
    Стандартная проверка загруженных строк
    1. Соответствие типов и размеров данных
    @param par_current_row - ИД текущей строки
  */
  PROCEDURE standard_check_row
  (
    par_row_status  OUT load_file_rows.row_status%TYPE
   ,par_row_comment OUT load_file_rows.row_comment%TYPE
  ) IS
    TYPE t_settings IS TABLE OF load_csv_settings%ROWTYPE;
  
    v_settings    t_settings;
    v_value       load_file_rows.val_1%TYPE;
    v_row_status  load_file_rows.row_status%TYPE := c_checked;
    v_row_comment load_file_rows.row_comment%TYPE := NULL;
  
  BEGIN
    SELECT t.* BULK COLLECT
      INTO v_settings
      FROM load_csv_settings t
     WHERE t.load_csv_list_id IN
           (SELECT lf.load_csv_list_id
              FROM load_file lf
             WHERE lf.load_file_id = gv_load_file_row_cache.load_file_id);
  
    FOR vr_set IN v_settings.first .. v_settings.last
    LOOP
      v_value := get_row_value_by_column_num(par_column_num => v_settings(vr_set).num);
    
      check_single_value(par_value          => v_value
                        ,par_column_name    => v_settings(vr_set).column_name
                        ,par_data_type      => v_settings(vr_set).data_type
                        ,par_data_length    => v_settings(vr_set).data_length
                        ,par_data_precision => v_settings(vr_set).data_precision
                        ,par_mandatory      => v_settings(vr_set).mandatory
                        ,par_format         => v_settings(vr_set).format
                        ,par_nls_num_char   => v_settings(vr_set).nls_numeric_characters
                        ,par_row_status     => par_row_status
                        ,par_row_comment    => par_row_comment);
      IF par_row_status = c_error
      THEN
        v_row_status  := par_row_status;
        v_row_comment := par_row_comment;
      END IF;
    END LOOP;
  
    par_row_status  := v_row_status;
    par_row_comment := nvl(v_row_comment, par_row_comment);
  END standard_check_row;

  /*
    Байтин А.
  
    Групповая проверка записей
  */
  PROCEDURE full_check_group(par_load_file_id NUMBER) IS
    v_row_status  load_file_rows.row_status%TYPE;
    v_row_comment load_file_rows.row_comment%TYPE;
  BEGIN
  
    init_file(par_load_file_id => par_load_file_id);
  
    check_conflicts(par_load_file_id => par_load_file_id);
  
    standard_check_header(par_load_file_id => par_load_file_id
                         ,par_row_status   => v_row_status
                         ,par_row_comment  => v_row_comment);
  
    IF v_row_status = c_error
    THEN
      set_current_file_rows_status(par_status => v_row_status, par_comment => v_row_comment);
    ELSE
      FOR vr_rows IN (SELECT lfr.rowid
                        FROM load_file_rows lfr
                       WHERE lfr.load_file_id = par_load_file_id
                         AND lfr.row_status NOT IN (get_checked, get_loaded, get_part_loaded))
      LOOP
        cache_row(vr_rows.rowid);
      
        standard_check_row(v_row_status, v_row_comment);
        set_current_row_status(par_row_status => v_row_status, par_row_comment => v_row_comment);
      END LOOP;
    END IF;
  
    IF gv_load_file_settings_cache.check_procedure IS NOT NULL
    THEN
      BEGIN
        EXECUTE IMMEDIATE 'begin ' || gv_load_file_settings_cache.check_procedure ||
                          '(:par_file_id); end;'
          USING IN par_load_file_id;
      EXCEPTION
        WHEN proc_dont_exists THEN
          raise_application_error(-20001
                                 ,'Процедура проверки "' ||
                                  gv_load_file_settings_cache.check_procedure || '" отсутствует в БД');
      END;
    END IF;
  EXCEPTION
    WHEN pkg_load_file_to_table.ex_priority_conflicts_found
         OR pkg_load_file_to_table.ex_type_conflicts_found THEN
      -- если не прошли проверку на наличие конфликтов - дальнейшие проверки бессмыслены
      NULL;
  END full_check_group;

  /* sergey.ilyushkin   18/06/2012
    Динамический вызов всех (стандарт + пользовательские) процедур проверки
    загруженной строки
    @param par_Load_File_Rows_ID - ИД строки
  */
  PROCEDURE full_check_row(par_load_file_rows_id NUMBER) IS
    v_row_status  load_file_rows.row_status%TYPE;
    v_row_comment load_file_rows.row_comment%TYPE;
  BEGIN
    cache_row(par_load_file_rows_id);
    -- Байтин А.
    -- Сделал так, чтобы проверка процедурой выполнялась только после успешной стандартной проверки
    standard_check_row(v_row_status, v_row_comment);
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => v_row_status
                                         ,par_row_comment       => v_row_comment);
  
    IF gv_load_file_settings_cache.check_procedure IS NOT NULL
    THEN
      BEGIN
        EXECUTE IMMEDIATE 'begin ' || gv_load_file_settings_cache.check_procedure ||
                          '(:par_id, :par_status, :par_comment); end;'
          USING IN par_load_file_rows_id, OUT v_row_status, OUT v_row_comment;
      
      EXCEPTION
        WHEN proc_dont_exists THEN
          raise_application_error(-20001
                                 ,'Процедура проверки "' ||
                                  gv_load_file_settings_cache.check_procedure || '" отсутствует в БД');
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => v_row_status
                                         ,par_row_comment       => v_row_comment
                                         ,par_is_checked        => CASE
                                                                     WHEN v_row_status = c_checked THEN
                                                                      1
                                                                     ELSE
                                                                      0
                                                                   END);
  
  END full_check_row;

  /*
    Капля П.
    Валидация заполнения полей хедера
  */
  PROCEDURE full_check_header
  (
    par_load_file_id load_file.load_file_id%TYPE
   ,par_row_status   OUT load_file_rows.row_status%TYPE
  ) IS
    v_row_comment load_file_rows.row_comment%TYPE;
  BEGIN
  
    standard_check_header(par_load_file_id => par_load_file_id
                         ,par_row_status   => par_row_status
                         ,par_row_comment  => v_row_comment);
  
    IF par_row_status = c_error
    THEN
      set_current_file_rows_status(par_status => par_row_status, par_comment => v_row_comment);
    END IF;
  
  END full_check_header;

  PROCEDURE check_conflicts(par_load_file_id load_file.load_file_id%TYPE) IS
    v_brief_names              VARCHAR2(4000);
    v_datatype_conflicts_brief VARCHAR2(4000);
  
    FUNCTION get_conflict_column_names RETURN VARCHAR2 IS
      v_brief_names VARCHAR2(4000);
    BEGIN
      SELECT wm_concat(lcos.column_name)
        INTO v_brief_names
        FROM load_file         lf
            ,load_csv_settings lcs
            ,load_csv_opt      lco
            ,load_csv_opt_set  lcos
       WHERE lf.load_csv_list_id = lcs.load_csv_list_id
         AND lf.load_csv_list_id = lco.load_csv_list_id
         AND lco.load_csv_opt_id = lcos.load_csv_opt_id
         AND lcs.brief = lcos.brief
         AND lf.load_file_id = par_load_file_id;
      RETURN v_brief_names;
    END get_conflict_column_names;
  
    FUNCTION check_config_datatype_conflict RETURN VARCHAR2 IS
      v_brief_names VARCHAR2(4000);
    BEGIN
      SELECT wm_concat(lcos.column_name)
        INTO v_brief_names
        FROM load_file         lf
            ,load_csv_settings lcs
            ,load_csv_opt      lco
            ,load_csv_opt_set  lcos
       WHERE lf.load_csv_list_id = lcs.load_csv_list_id
         AND lf.load_csv_list_id = lco.load_csv_list_id
         AND lco.load_csv_opt_id = lcos.load_csv_opt_id
         AND lcs.brief = lcos.brief
         AND lf.load_file_id = par_load_file_id
         AND lcs.data_type != lcos.data_type;
      RETURN v_brief_names;
    END;
  
  BEGIN
    v_datatype_conflicts_brief := check_config_datatype_conflict;
  
    IF v_datatype_conflicts_brief IS NULL
    THEN
    
      -- Проверка на наличие конфликтов, если они не допустимы
      IF gv_load_file_settings_cache.conflict_priority = gc_conflict_disallowed
      THEN
        v_brief_names := get_conflict_column_names();
      
        IF v_brief_names IS NOT NULL
        THEN
        
          set_current_file_rows_status(par_status  => c_error
                                      ,par_comment => 'Внимание! Для полей (' || v_brief_names ||
                                                      ') выявлен конфликт с выбранным набором дополнительных параметров, загрузка недопустима.');
        
          RAISE ex_priority_conflicts_found;
        END IF;
      END IF;
    ELSE
      set_current_file_rows_status(par_status  => c_error
                                  ,par_comment => 'Внимание! Для полей (' || v_brief_names ||
                                                  ') выявлен конфликт типов данных между дополнительными параметрами и настройками столбцов, загрузка недопустима.');
    
      RAISE ex_type_conflicts_found;
    END IF;
  
  END check_conflicts;

  /*
    Байтин А.
    Групповая загрузка строк
  */
  PROCEDURE load_rows_group(par_load_file_id NUMBER) IS
  BEGIN
  
    init_file(par_load_file_id => par_load_file_id);
  
    IF gv_load_file_settings_cache.load_procedure IS NOT NULL
    THEN
      BEGIN
        EXECUTE IMMEDIATE 'begin ' || gv_load_file_settings_cache.load_procedure ||
                          '(:par_file_id); end;'
          USING IN par_load_file_id;
      EXCEPTION
        WHEN proc_dont_exists THEN
          raise_application_error(-20001
                                 ,'Процедура проверки "' ||
                                  gv_load_file_settings_cache.load_procedure || '" отсутствует в БД');
      END;
    END IF;
  
  END load_rows_group;

  /* sergey.ilyushkin   18/06/2012
    Динамический вызов процедуры обработки загруженной строки
    @param par_Load_File_Rows_ID - ИД строки
  */
  PROCEDURE load_row(par_load_file_rows_id NUMBER) IS
  BEGIN
    cache_row(par_load_file_rows_id => par_load_file_rows_id);
  
    IF gv_load_file_settings_cache.load_procedure IS NOT NULL
    THEN
      BEGIN
        EXECUTE IMMEDIATE 'begin ' || gv_load_file_settings_cache.load_procedure ||
                          '(:par_load_file_rows_id); end;'
          USING IN par_load_file_rows_id;
      EXCEPTION
        WHEN proc_dont_exists THEN
          raise_application_error(-20001
                                 ,'Процедура проверки "' ||
                                  gv_load_file_settings_cache.load_procedure || '" отсутствует в БД');
      END;
    END IF;
  END load_row;

  /*
    Байтин А.
    Запуск процедуры удаления строк таблицы перед загрузкой
    @param par_load_csv_list_id - ИД настройки
  */
  PROCEDURE delete_from_table(par_load_csv_list_id NUMBER) IS
    v_delete_procedure load_csv_list.delete_procedure%TYPE;
  BEGIN
  
    SELECT cl.delete_procedure
      INTO v_delete_procedure
      FROM load_csv_list cl
     WHERE cl.load_csv_list_id = par_load_csv_list_id;
  
    IF v_delete_procedure IS NOT NULL
    THEN
      BEGIN
        EXECUTE IMMEDIATE 'begin ' || v_delete_procedure || '(' || par_load_csv_list_id || '); end;';
      EXCEPTION
        WHEN proc_dont_exists THEN
          raise_application_error(-20001
                                 ,'Процедура удаления "' || v_delete_procedure ||
                                  '" отсутствует в БД');
      END;
    END IF;
  END delete_from_table;

  /*
    Капля П.
    Установка статуса и комментария по всем строкам файла
    Есть возможность управлять тем, будут ли проставлены данные по всем или только по незагруенным стркоам
  */
  PROCEDURE set_all_file_rows_status
  (
    par_load_file_id           load_file.load_file_id%TYPE
   ,par_status                 load_file_rows.row_status%TYPE
   ,par_comment                load_file_rows.row_comment%TYPE
   ,par_update_only_not_loaded BOOLEAN DEFAULT TRUE
  ) IS
  BEGIN
    IF par_update_only_not_loaded
    THEN
      UPDATE load_file_rows
         SET row_status  = par_status
            ,row_comment = par_comment
       WHERE load_file_id = par_load_file_id
         AND row_status NOT IN (get_loaded, get_part_loaded);
    ELSE
      UPDATE load_file_rows
         SET row_status  = par_status
            ,row_comment = par_comment
       WHERE load_file_id = par_load_file_id;
    END IF;
  END set_all_file_rows_status;

  PROCEDURE set_current_file_rows_status
  (
    par_status                 load_file_rows.row_status%TYPE
   ,par_comment                load_file_rows.row_comment%TYPE
   ,par_update_only_not_loaded BOOLEAN DEFAULT TRUE
  ) IS
  BEGIN
    set_all_file_rows_status(par_load_file_id           => gv_load_file_settings_cache.load_file_id
                            ,par_status                 => par_status
                            ,par_comment                => par_comment
                            ,par_update_only_not_loaded => par_update_only_not_loaded);
  END set_current_file_rows_status;

  /* Установка статуса выбранной строки
  @param par_Load_File_Rows_ID - ИД строки
  @param par_Row_Status - Новый статус строки
  @param par_Row_Comment - Описание текущего состояния строки
  */
  PROCEDURE set_row_status
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        NUMBER
   ,par_row_comment       VARCHAR2 DEFAULT NULL
   ,par_ure_id            NUMBER DEFAULT NULL
   ,par_uro_id            NUMBER DEFAULT NULL
   ,par_is_checked        NUMBER DEFAULT NULL
  ) IS
    v_load_file_rows dml_load_file_rows.tt_load_file_rows;
  BEGIN
    v_load_file_rows := dml_load_file_rows.get_record(par_load_file_rows_id);
  
    v_load_file_rows.row_status  := par_row_status;
    v_load_file_rows.row_comment := par_row_comment;
    v_load_file_rows.ure_id      := nvl(par_ure_id, v_load_file_rows.ure_id);
    v_load_file_rows.uro_id      := nvl(par_uro_id, v_load_file_rows.uro_id);
    v_load_file_rows.is_checked  := nvl(v_load_file_rows.is_checked, par_is_checked);
  
    dml_load_file_rows.update_record(v_load_file_rows);
  END set_row_status;

  PROCEDURE set_current_row_status
  (
    par_row_status  NUMBER
   ,par_row_comment VARCHAR2 DEFAULT NULL
   ,par_ure_id      NUMBER DEFAULT NULL
   ,par_uro_id      NUMBER DEFAULT NULL
   ,par_is_checked  NUMBER DEFAULT NULL
  ) IS
  BEGIN
    set_row_status(par_load_file_rows_id => gv_load_file_row_cache.load_file_rows_id
                  ,par_row_status        => par_row_status
                  ,par_row_comment       => par_row_comment
                  ,par_ure_id            => par_ure_id
                  ,par_uro_id            => par_uro_id
                  ,par_is_checked        => par_is_checked);
  END set_current_row_status;

  /*
    Байтин А.
    Добавление пакета настроек для загрузки из CSV
  */
  PROCEDURE insert_csv_list
  (
    par_load_csv_group_id NUMBER -- ИД группы загрузки
   ,par_brief             VARCHAR2 -- Краткое обозначение
   ,par_load_csv_name     VARCHAR2 -- Наименование пакета настроек
   ,par_check_procedure   VARCHAR2 DEFAULT NULL -- Имя пакетной процедуры для проверки записей
   ,par_load_procedure    VARCHAR2 DEFAULT NULL -- Имя пакетной процедуры для загрузки в рабочие таблицы
   ,par_start_date        DATE DEFAULT trunc(SYSDATE) -- Дата начала действия настроек
   ,par_end_date          DATE DEFAULT NULL -- Дата окончания действия настроек
   ,par_rows_in_header    NUMBER DEFAULT NULL -- Количество строк заголовка таблицы
   ,par_is_group_process  NUMBER DEFAULT NULL -- Флаг группового процесса
   ,par_delete_procedure  VARCHAR2 DEFAULT NULL -- процедура удаления
   ,par_delimiter         load_csv_list.delimiter%TYPE DEFAULT ';' -- разделитель
   ,par_call_form         load_csv_list.call_form%TYPE DEFAULT NULL -- форма для вызова по даблклику строки в Универсальном загрузчике
   ,par_call_form_par     load_csv_list.call_form_par%TYPE DEFAULT NULL -- параметр для указания при вызова формы
   ,par_load_csv_list_id  OUT NUMBER -- ИД добавленной записи
  ) IS
  BEGIN
    dml_load_csv_list.insert_record(par_load_csv_name     => par_load_csv_name
                                   ,par_brief             => par_brief
                                   ,par_load_csv_group_id => par_load_csv_group_id
                                   ,par_start_date        => par_start_date
                                   ,par_rows_in_header    => par_rows_in_header
                                   ,par_is_group_process  => par_is_group_process
                                   ,par_end_date          => par_end_date
                                   ,par_check_procedure   => par_check_procedure
                                   ,par_load_procedure    => par_load_procedure
                                   ,par_delete_procedure  => par_delete_procedure
                                   ,par_delimiter         => par_delimiter
                                   ,par_call_form         => par_call_form
                                   ,par_call_form_par     => par_call_form_par
                                   ,par_load_csv_list_id  => par_load_csv_list_id);
  END insert_csv_list;

  PROCEDURE check_data_type(par_data_type VARCHAR2) IS
  BEGIN
    assert_deprecated(upper(par_data_type) NOT IN
           (gc_column_type_varchar2, gc_column_type_date, gc_column_type_number)
          ,'Не верный тип данных поля');
  END check_data_type;

  PROCEDURE insert_csv_file_column
  (
    par_load_csv_list_id       NUMBER
   ,par_column_name            VARCHAR2
   ,par_brief                  VARCHAR2 DEFAULT NULL
   ,par_data_type              VARCHAR2
   ,par_column_num             NUMBER DEFAULT NULL
   ,par_data_length            NUMBER DEFAULT NULL
   ,par_mandatory              NUMBER DEFAULT 0
   ,par_format                 VARCHAR2 DEFAULT NULL
   ,par_nls_numeric_characters VARCHAR2 DEFAULT NULL
   ,par_load_csv_settings_id   OUT NUMBER
  ) IS
    v_num     load_csv_settings.num%TYPE;
    v_max_num load_csv_settings.num%TYPE;
  BEGIN
    check_data_type(par_data_type => par_data_type);
  
    SELECT nvl(MAX(num), 0)
      INTO v_max_num
      FROM load_csv_settings t
     WHERE t.load_csv_list_id = par_load_csv_list_id;
  
    IF par_column_num IS NOT NULL
       AND par_column_num <= v_max_num
    THEN
      UPDATE load_csv_settings t
         SET t.num = t.num + 1
       WHERE t.load_csv_list_id = par_load_csv_list_id
         AND t.num >= par_column_num;
      v_num := par_column_num;
    ELSIF par_column_num IS NULL
    THEN
      v_num := v_max_num + 1;
    ELSE
      v_num := par_column_num;
    END IF;
  
    dml_load_csv_settings.insert_record(par_load_csv_list_id       => par_load_csv_list_id
                                       ,par_column_name            => par_column_name
                                       ,par_data_type              => upper(par_data_type)
                                       ,par_num                    => v_num
                                       ,par_mandatory              => par_mandatory
                                       ,par_data_length            => par_data_length
                                       ,par_brief                  => par_brief
                                       ,par_format                 => par_format
                                       ,par_nls_numeric_characters => par_nls_numeric_characters
                                       ,par_load_csv_settings_id   => par_load_csv_settings_id);
  
  END insert_csv_file_column;

  PROCEDURE insert_csv_file_column
  (
    par_load_csv_list_id       NUMBER
   ,par_column_name            VARCHAR2
   ,par_brief                  VARCHAR2 DEFAULT NULL
   ,par_data_type              VARCHAR2
   ,par_column_num             NUMBER DEFAULT NULL
   ,par_data_length            NUMBER DEFAULT NULL
   ,par_mandatory              NUMBER DEFAULT 0
   ,par_format                 VARCHAR2 DEFAULT NULL
   ,par_nls_numeric_characters VARCHAR2 DEFAULT NULL
  ) IS
    v_dummy NUMBER;
  BEGIN
    insert_csv_file_column(par_load_csv_list_id       => par_load_csv_list_id
                          ,par_column_name            => par_column_name
                          ,par_brief                  => par_brief
                          ,par_data_type              => par_data_type
                          ,par_column_num             => par_column_num
                          ,par_data_length            => par_data_length
                          ,par_mandatory              => par_mandatory
                          ,par_format                 => par_format
                          ,par_nls_numeric_characters => par_nls_numeric_characters
                          ,par_load_csv_settings_id   => v_dummy);
  END insert_csv_file_column;

  PROCEDURE insert_standard_column
  (
    par_load_csv_list_brief load_csv_list.brief%TYPE
   ,par_column_brief        load_csv_brief_proc.brief%TYPE
   ,par_column_num          load_csv_settings.num%TYPE DEFAULT NULL
   ,par_mandatory           NUMBER DEFAULT 0
   ,par_format              VARCHAR2 DEFAULT NULL
  ) IS
    v_load_csv_brief_proc dml_load_csv_brief_proc.tt_load_csv_brief_proc;
    v_load_csv_list_id    load_csv_list.load_csv_list_id%TYPE;
  BEGIN
  
    v_load_csv_list_id    := dml_load_csv_list.get_id_by_brief(par_brief => par_load_csv_list_brief);
    v_load_csv_brief_proc := dml_load_csv_brief_proc.get_rec_by_brief(par_brief => par_column_brief);
  
    insert_csv_file_column(par_load_csv_list_id => v_load_csv_list_id
                          ,par_column_name      => v_load_csv_brief_proc.description
                          ,par_brief            => v_load_csv_brief_proc.brief
                          ,par_data_type        => v_load_csv_brief_proc.data_type
                          ,par_column_num       => par_column_num
                          ,par_data_length      => v_load_csv_brief_proc.data_length
                          ,par_mandatory        => par_mandatory
                          ,par_format           => par_format);
  END insert_standard_column;

  PROCEDURE delete_csv_file_column
  (
    par_load_csv_settings_id NUMBER
   ,par_load_csv_list_id     NUMBER
   ,par_column_name          VARCHAR2
  ) IS
  BEGIN
    UPDATE load_csv_settings lcs
       SET lcs.num = lcs.num - 1
     WHERE lcs.load_csv_list_id = par_load_csv_list_id
       AND lcs.num > (SELECT num
                        FROM load_csv_settings lcs2
                       WHERE lcs2.load_csv_settings_id = par_load_csv_settings_id);
  
    DELETE FROM load_csv_settings WHERE load_csv_settings_id = par_load_csv_settings_id;
  END delete_csv_file_column;

  PROCEDURE insert_csv_file_header_column
  (
    par_load_csv_list_id          NUMBER
   ,par_column_name               VARCHAR2
   ,par_brief                     VARCHAR2
   ,par_column_num                load_csv_header_settings.num%TYPE
   ,par_row_num                   load_csv_header_settings.row_num%TYPE DEFAULT 1
   ,par_data_type                 VARCHAR2 DEFAULT 'VARCHAR2'
   ,par_data_length               NUMBER DEFAULT NULL
   ,par_mandatory                 NUMBER DEFAULT 0
   ,par_format                    VARCHAR2 DEFAULT NULL
   ,par_load_csv_head_settings_id OUT NUMBER
  ) IS
    v_num     load_csv_header_settings.num%TYPE;
    v_max_num load_csv_header_settings.num%TYPE;
  BEGIN
    check_data_type(par_data_type => par_data_type);
  
    SELECT nvl(MAX(num), 0)
      INTO v_max_num
      FROM load_csv_header_settings t
     WHERE t.load_csv_list_id = par_load_csv_list_id;
  
    IF par_column_num IS NOT NULL
       AND par_column_num <= v_max_num
    THEN
      UPDATE load_csv_settings t
         SET t.num = t.num + 1
       WHERE t.load_csv_list_id = par_load_csv_list_id
         AND t.num >= par_column_num;
      v_num := par_column_num;
    ELSIF par_column_num IS NULL
    THEN
      v_num := v_max_num + 1;
    ELSE
      v_num := par_column_num;
    END IF;
  
    dml_load_csv_header_settings.insert_record(par_load_csv_list_id => par_load_csv_list_id
                                              ,par_column_name      => par_column_name
                                              ,par_brief            => par_brief
                                              ,par_data_type        => par_data_type
                                              ,par_num              => v_num
                                              ,par_row_num          => par_row_num
                                              ,par_mandatory        => par_mandatory
                                              ,par_data_length      => par_data_length
                                              ,par_format           => par_format);
  
  END insert_csv_file_header_column;

  PROCEDURE insert_csv_file_header_column
  (
    par_load_csv_list_id NUMBER
   ,par_column_name      VARCHAR2
   ,par_brief            VARCHAR2
   ,par_column_num       load_csv_header_settings.num%TYPE
   ,par_row_num          load_csv_header_settings.row_num%TYPE DEFAULT 1
   ,par_data_type        VARCHAR2 DEFAULT 'VARCHAR2'
   ,par_data_length      NUMBER DEFAULT NULL
   ,par_mandatory        NUMBER DEFAULT 0
   ,par_format           VARCHAR2 DEFAULT NULL
  ) IS
    v_dummy NUMBER;
  BEGIN
    insert_csv_file_header_column(par_load_csv_list_id          => par_load_csv_list_id
                                 ,par_column_name               => par_column_name
                                 ,par_brief                     => par_brief
                                 ,par_data_type                 => par_data_type
                                 ,par_column_num                => par_column_num
                                 ,par_row_num                   => par_row_num
                                 ,par_data_length               => par_data_length
                                 ,par_mandatory                 => par_mandatory
                                 ,par_format                    => par_format
                                 ,par_load_csv_head_settings_id => v_dummy);
  END insert_csv_file_header_column;

  PROCEDURE insert_csv_file_header_column
  (
    par_load_csv_list_brief VARCHAR2
   ,par_column_name         VARCHAR2
   ,par_brief               VARCHAR2
   ,par_column_num          load_csv_header_settings.num%TYPE
   ,par_row_num             load_csv_header_settings.row_num%TYPE DEFAULT 1
   ,par_data_type           VARCHAR2 DEFAULT 'VARCHAR2'
   ,par_data_length         NUMBER DEFAULT NULL
   ,par_mandatory           NUMBER DEFAULT 0
   ,par_format              VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
    insert_csv_file_header_column(par_load_csv_list_id => dml_load_csv_list.get_id_by_brief(par_load_csv_list_brief)
                                 ,par_column_name      => par_column_name
                                 ,par_brief            => par_brief
                                 ,par_data_type        => par_data_type
                                 ,par_column_num       => par_column_num
                                 ,par_data_length      => par_data_length
                                 ,par_mandatory        => par_mandatory
                                 ,par_format           => par_format);
  END insert_csv_file_header_column;

  PROCEDURE copy_load_csv_header_settings
  (
    par_src_load_scv_list_brief  VARCHAR2
   ,par_dest_load_csv_list_brief VARCHAR2
  ) IS
    v_src_load_csv_list_id  NUMBER;
    v_dest_load_csv_list_id NUMBER;
  BEGIN
    v_src_load_csv_list_id  := dml_load_csv_list.get_id_by_brief(par_brief => par_src_load_scv_list_brief);
    v_dest_load_csv_list_id := dml_load_csv_list.get_id_by_brief(par_brief => par_dest_load_csv_list_brief);
  
    copy_load_csv_header_settings(par_src_load_scv_list_id  => v_src_load_csv_list_id
                                 ,par_dest_load_csv_list_id => v_dest_load_csv_list_id);
  END copy_load_csv_header_settings;

  PROCEDURE copy_load_csv_header_settings
  (
    par_src_load_scv_list_id  load_csv_list.load_csv_list_id%TYPE
   ,par_dest_load_csv_list_id load_csv_list.load_csv_list_id%TYPE
  ) IS
  BEGIN
  
    FOR rec IN (SELECT *
                  FROM load_csv_header_settings t
                 WHERE t.load_csv_list_id = par_src_load_scv_list_id
                 ORDER BY t.row_num
                         ,num)
    LOOP
      rec.load_csv_list_id := par_dest_load_csv_list_id;
      dml_load_csv_header_settings.insert_record(par_record => rec);
    END LOOP;
  
  END copy_load_csv_header_settings;

  PROCEDURE copy_load_csv_settings
  (
    par_src_load_scv_list_brief  VARCHAR2
   ,par_dest_load_csv_list_brief VARCHAR2
  ) IS
    v_src_load_csv_list_id  NUMBER;
    v_dest_load_csv_list_id NUMBER;
  BEGIN
    v_src_load_csv_list_id  := dml_load_csv_list.get_id_by_brief(par_brief => par_src_load_scv_list_brief);
    v_dest_load_csv_list_id := dml_load_csv_list.get_id_by_brief(par_brief => par_dest_load_csv_list_brief);
  
    copy_load_csv_settings(par_src_load_scv_list_id  => v_src_load_csv_list_id
                          ,par_dest_load_csv_list_id => v_dest_load_csv_list_id);
  
  END copy_load_csv_settings;

  PROCEDURE copy_load_csv_settings
  (
    par_src_load_scv_list_id  load_csv_list.load_csv_list_id%TYPE
   ,par_dest_load_csv_list_id load_csv_list.load_csv_list_id%TYPE
  ) IS
    v_dump dml_load_csv_settings.typ_nested_table;
  BEGIN
  
    SELECT * BULK COLLECT
      INTO v_dump
      FROM load_csv_settings t
     WHERE t.load_csv_list_id = par_src_load_scv_list_id;
  
    FOR i IN 1 .. v_dump.count
    LOOP
      v_dump(i).load_csv_list_id := par_dest_load_csv_list_id;
    END LOOP;
  
    dml_load_csv_settings.insert_record_list(par_record_list => v_dump);
  
  END copy_load_csv_settings;

  PROCEDURE copy_load_csv_list
  (
    par_src_load_scv_list_brief load_csv_list.brief%TYPE
   ,par_new_name                load_csv_list.load_csv_name%TYPE
   ,par_new_brief               load_csv_list.brief%TYPE
  ) IS
    v_src_load_csv_list_id load_csv_list.load_csv_list_id%TYPE;
    v_load_csv_list        dml_load_csv_list.tt_load_csv_list;
    v_load_csv_opt         dml_load_csv_opt.tt_load_csv_opt;
    va_load_csv_opt_set    dml_load_csv_opt_set.typ_nested_table;
  BEGIN
  
    v_load_csv_list        := dml_load_csv_list.get_rec_by_brief(par_src_load_scv_list_brief);
    v_src_load_csv_list_id := v_load_csv_list.load_csv_list_id;
  
    v_load_csv_list.load_csv_name := par_new_name;
    v_load_csv_list.brief         := par_new_brief;
  
    dml_load_csv_list.insert_record(par_record => v_load_csv_list);
  
    copy_load_csv_settings(par_src_load_scv_list_id  => v_src_load_csv_list_id
                          ,par_dest_load_csv_list_id => v_load_csv_list.load_csv_list_id);
  
    copy_load_csv_header_settings(par_src_load_scv_list_id  => v_src_load_csv_list_id
                                 ,par_dest_load_csv_list_id => v_load_csv_list.load_csv_list_id);
  
    FOR cur IN (SELECT * FROM ven_load_csv_opt WHERE load_csv_list_id = v_src_load_csv_list_id)
    LOOP
    
      v_load_csv_opt                  := dml_load_csv_opt.get_record(cur.load_csv_opt_id);
      v_load_csv_opt.load_csv_list_id := v_load_csv_list.load_csv_list_id;
    
      dml_load_csv_opt.insert_record(par_record => v_load_csv_opt);
    
      SELECT * BULK COLLECT
        INTO va_load_csv_opt_set
        FROM load_csv_opt_set t
       WHERE t.load_csv_opt_id = cur.load_csv_opt_id;
    
      FOR i IN 1 .. va_load_csv_opt_set.count
      LOOP
        va_load_csv_opt_set(i).load_csv_opt_id := v_load_csv_opt.load_csv_opt_id;
      END LOOP;
    
      dml_load_csv_opt_set.insert_record_list(par_record_list => va_load_csv_opt_set);
    
    END LOOP;
  
  END copy_load_csv_list;

  PROCEDURE copy_load_csv_list(par_src_load_scv_list_brief load_csv_list.brief%TYPE) IS
    v_cnt           NUMBER;
    v_load_csv_list dml_load_csv_list.tt_load_csv_list;
  BEGIN
    v_load_csv_list := dml_load_csv_list.get_rec_by_brief(par_src_load_scv_list_brief);
  
    SELECT COUNT(*) INTO v_cnt FROM load_csv_list WHERE brief LIKE par_src_load_scv_list_brief || '%';
  
    v_load_csv_list.load_csv_name := v_load_csv_list.load_csv_name || '_копия_' || v_cnt;
    v_load_csv_list.brief         := v_load_csv_list.brief || '_copy_' || v_cnt;
  
    copy_load_csv_list(par_src_load_scv_list_brief => par_src_load_scv_list_brief
                      ,par_new_name                => v_load_csv_list.load_csv_name
                      ,par_new_brief               => v_load_csv_list.brief);
  
  END copy_load_csv_list;

  /*
    Пиядин А.
    Функция возвращает комментарий записи
  */
  FUNCTION get_row_comment(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) RETURN VARCHAR2 IS
    v_load_file_rows dml_load_file_rows.tt_load_file_rows;
    v_max_log_id     load_file_row_log.load_file_row_log_id%TYPE;
    v_log_msg        VARCHAR2(4000) := NULL;
  BEGIN
    v_load_file_rows := dml_load_file_rows.get_record(par_load_file_rows_id);
  
    v_max_log_id := pkg_load_logging.get_max_log_id(par_load_file_rows_id);
    IF v_max_log_id IS NOT NULL
    THEN
      v_log_msg := substr(pkg_load_logging.get_log_row_status_desc(v_max_log_id) || ': ' ||
                          pkg_load_logging.get_log_msg(v_max_log_id)
                         ,1
                         ,4000);
    END IF;
  
    RETURN nvl(v_load_file_rows.row_comment, v_log_msg);
  END get_row_comment;

  /*
    Капля П.
    Инициализация работы с файлом
    При этом заполняется кеш настроек для файла, заполняется массив маппинга столбцов и описание заголовка
    Также загружается значение параметров загрузки
  */
  PROCEDURE init_file(par_load_file_id load_file.load_file_id%TYPE) IS
  
    PROCEDURE fill_csv_settings_cache IS
    BEGIN
      FOR rec IN (SELECT *
                      FROM load_csv_settings lcs
                     WHERE lcs.load_csv_list_id = gv_load_file_settings_cache.load_csv_list_id
                       AND lcs.brief IS NOT NULL
                     ORDER BY lcs.num)
        LOOP
          gv_load_file_settings_cache.column_papping(rec.brief).num := rec.num;
          gv_load_file_settings_cache.column_papping(rec.brief).data_type := rec.data_type;
          gv_load_file_settings_cache.column_papping(rec.brief).mandatory := rec.mandatory;
          gv_load_file_settings_cache.column_papping(rec.brief).format := rec.format;
          gv_load_file_settings_cache.column_papping(rec.brief).column_name := rec.column_name;
          gv_load_file_settings_cache.column_papping(rec.brief).nls_numeric_characters := rec.nls_numeric_characters;
        END LOOP;
    END fill_csv_settings_cache;
  
    PROCEDURE fill_csv_opt_value_cache IS
    BEGIN
      IF gv_load_file_settings_cache.load_csv_opt_id IS NOT NULL
      THEN
        FOR rec IN (SELECT *
                      FROM load_csv_opt_set lcos
                     WHERE lcos.load_csv_opt_id = gv_load_file_settings_cache.load_csv_opt_id)
        LOOP
          gv_load_file_settings_cache.parameters(rec.brief).value := rec.value;
          gv_load_file_settings_cache.parameters(rec.brief).data_type := rec.data_type;
          gv_load_file_settings_cache.parameters(rec.brief).column_name := rec.column_name;
        END LOOP;
      END IF;
    END fill_csv_opt_value_cache;
  
    PROCEDURE fill_file_header_param_cache IS
    BEGIN
      FOR rec IN (SELECT lchs.brief
                        ,lfhp.value
                        ,lchs.column_name
                        ,lchs.data_type
                        ,lchs.data_length
                        ,lchs.mandatory
                        ,lchs.format
                        ,lchs.nls_numeric_characters
                    FROM load_file_header_params  lfhp
                        ,load_csv_header_settings lchs
                   WHERE lfhp.load_file_id = gv_load_file_settings_cache.load_file_id
                     AND lfhp.load_csv_header_settings_id = lchs.load_csv_header_settings_id)
      LOOP
        gv_load_file_settings_cache.file_header_parameters(rec.brief).value := rec.value;
        gv_load_file_settings_cache.file_header_parameters(rec.brief).column_name := rec.column_name;
        gv_load_file_settings_cache.file_header_parameters(rec.brief).data_type := rec.data_type;
        gv_load_file_settings_cache.file_header_parameters(rec.brief).data_length := rec.data_length;
        gv_load_file_settings_cache.file_header_parameters(rec.brief).mandatory := rec.mandatory;
        gv_load_file_settings_cache.file_header_parameters(rec.brief).format := rec.format;
        gv_load_file_settings_cache.file_header_parameters(rec.brief).nls_numeric_characters := rec.nls_numeric_characters;
      
      END LOOP;
    END fill_file_header_param_cache;
  
  BEGIN
  
    -- Очищаем кэш
    gv_load_file_settings_cache.column_papping.delete;
    gv_load_file_settings_cache.parameters.delete;
    gv_load_file_settings_cache.file_header_parameters.delete;
  
    -- Заполняем кэш общими данными
    SELECT t.load_file_id
          ,t.load_csv_list_id
          ,t.load_csv_opt_id
          ,l.load_procedure
          ,l.check_procedure
           --,l.delete_procedure
          ,(SELECT o.conflict_priority FROM load_csv_opt o WHERE t.load_csv_opt_id = o.load_csv_opt_id)
      INTO gv_load_file_settings_cache.load_file_id
          ,gv_load_file_settings_cache.load_csv_list_id
          ,gv_load_file_settings_cache.load_csv_opt_id
          ,gv_load_file_settings_cache.load_procedure
          ,gv_load_file_settings_cache.check_procedure
           --,gv_load_file_settings_cache.delete_procedure
          ,gv_load_file_settings_cache.conflict_priority
      FROM load_file     t
          ,load_csv_list l
     WHERE t.load_file_id = par_load_file_id
       AND t.load_csv_list_id = l.load_csv_list_id;
  
    -- Заполняем массив заголовков столбцов файла
    fill_csv_settings_cache;
  
    -- Заполняем массив набора параметров
    fill_csv_opt_value_cache;
  
    -- Заполняем массив значений параметров из заголовка текущего файла
    fill_file_header_param_cache;
  
    gv_load_file_settings_cache.log_load_order_num := pkg_load_logging.get_max_log_order_num(par_load_file_id) + 1;
  
  END init_file;

  /*
    Капля П.
    Кешируем текущую строчку, с которой будем в дальнейшем работать.
    Необходимо для применения функций получения значений по брифу
  */
  PROCEDURE cache_row(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
  BEGIN
    gv_load_file_row_cache := dml_load_file_rows.get_record(par_load_file_rows_id => par_load_file_rows_id);
  END cache_row;

  PROCEDURE cache_row(par_rowid UROWID) IS
  BEGIN
    gv_load_file_row_cache := dml_load_file_rows.get_rec_by_rowid(par_rowid          => par_rowid
                                                                 ,par_raise_on_error => TRUE);
  END cache_row;

  PROCEDURE cache_row(par_record load_file_rows%ROWTYPE) IS
  BEGIN
    gv_load_file_row_cache := par_record;
  END cache_row;

  /*
    Капля П.
    Получение значения параметра для текущего правила загрузки и выбранного набора параметров
  */
  FUNCTION get_parameter_value
  (
    par_option_brief   load_csv_opt_set.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT FALSE
  ) RETURN load_csv_opt_set.value%TYPE IS
    v_value load_csv_opt_set.value%TYPE;
  BEGIN
    assert_deprecated(gv_load_file_settings_cache.load_file_id IS NULL
          ,'Обрабатываей файл должен быть инициализирован');
    BEGIN
      v_value := gv_load_file_settings_cache.parameters(upper(par_option_brief)).value;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не удалось определить параметр по брифу ' || par_option_brief);
        END IF;
    END;
    RETURN v_value;
  END get_parameter_value;

  FUNCTION get_option_value_string
  (
    par_option_brief   load_csv_opt_set.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT FALSE
  ) RETURN VARCHAR2 IS
    v_varchar_value load_file_rows.val_1%TYPE;
  BEGIN
    v_varchar_value := get_parameter_value(par_option_brief, par_raise_on_error);
  
    RETURN v_varchar_value;
  
  END get_option_value_string;

  FUNCTION get_option_value_date
  (
    par_option_brief   load_csv_opt_set.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT FALSE
  ) RETURN DATE IS
    v_varchar_value load_file_rows.val_1%TYPE;
    v_value         DATE := NULL;
  BEGIN
    v_varchar_value := get_parameter_value(par_option_brief, par_raise_on_error);
  
    IF v_varchar_value IS NOT NULL
    THEN
      assert_deprecated(gv_load_file_settings_cache.parameters(upper(par_option_brief))
             .data_type != pkg_load_file_to_table.gc_column_type_date
            , 'Невозможно получить значение параметра ' || par_option_brief || '(' || gv_load_file_settings_cache.parameters(upper(par_option_brief))
             .data_type || ') в формате даты');
    
      BEGIN
        v_value := to_date(TRIM(v_varchar_value), gc_default_date_format);
      EXCEPTION
        WHEN date_format_error
             OR day_of_month_error
             OR not_a_numeric_char
             OR pkg_oracle_exceptions.date_format_pic_ends THEN
          ex.raise('Значение параметра "' || par_option_brief || '" не является датой');
      END;
    END IF;
  
    RETURN v_value;
  
  END get_option_value_date;

  FUNCTION get_option_value_number
  (
    par_option_brief   load_csv_opt_set.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT FALSE
  ) RETURN NUMBER IS
    v_varchar_value load_file_rows.val_1%TYPE;
    v_value         NUMBER := NULL;
  BEGIN
    v_varchar_value := get_parameter_value(par_option_brief, par_raise_on_error);
  
    IF v_varchar_value IS NOT NULL
    THEN
      assert_deprecated(gv_load_file_settings_cache.parameters(upper(par_option_brief))
             .data_type != pkg_load_file_to_table.gc_column_type_number
            , 'Невозможно получить значение параметра ' || par_option_brief || '(' || gv_load_file_settings_cache.parameters(upper(par_option_brief))
             .data_type || ') в формате числа');
    
      BEGIN
        v_value := convert_to_number(TRIM(v_varchar_value));
      EXCEPTION
        WHEN invalid_number THEN
          ex.raise('Значение параметра "' || par_option_brief || '" не является числом');
      END;
    END IF;
  
    RETURN v_value;
  
  END get_option_value_number;

  FUNCTION get_row_value_string
  (
    par_column_brief     load_csv_settings.brief%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_varchar_value load_file_rows.val_1%TYPE;
  BEGIN
    v_varchar_value := get_row_value_by_column_brief(par_column_brief     => par_column_brief
                                                    ,par_load_file_row_id => par_load_file_row_id);
  
    RETURN v_varchar_value;
  
  END get_row_value_string;

  FUNCTION get_row_value_date
  (
    par_column_brief     load_csv_settings.brief%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN DATE IS
    v_varchar_value load_file_rows.val_1%TYPE;
    v_value         DATE := NULL;
  BEGIN
    v_varchar_value := get_row_value_by_column_brief(par_column_brief     => par_column_brief
                                                    ,par_load_file_row_id => par_load_file_row_id);
  
    IF v_varchar_value IS NOT NULL
    THEN
      assert_deprecated(gv_load_file_settings_cache.column_papping(upper(par_column_brief))
             .data_type != pkg_load_file_to_table.gc_column_type_date
            , 'Невозможно получить значение поля ' || gv_load_file_settings_cache.column_papping(upper(par_column_brief))
             .column_name || '(' || gv_load_file_settings_cache.column_papping(upper(par_column_brief))
             .data_type || ') в формате строки');
    
        v_value := to_date(TRIM(v_varchar_value)
                        ,nvl(gv_load_file_settings_cache.column_papping(upper(par_column_brief)).format
                              ,gc_default_date_format));
    END IF;
  
    RETURN v_value;
  
  END get_row_value_date;

  FUNCTION get_row_value_number
  (
    par_column_brief     load_csv_settings.brief%TYPE
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN NUMBER IS
    v_varchar_value load_file_rows.val_1%TYPE;
    v_value         NUMBER := NULL;
    v_format        load_csv_settings.format%TYPE;
    v_nls_settings  load_csv_settings.nls_numeric_characters%TYPE;
  BEGIN
    v_varchar_value := get_row_value_by_column_brief(par_column_brief     => par_column_brief
                                                    ,par_load_file_row_id => par_load_file_row_id);
  
    IF v_varchar_value IS NOT NULL
    THEN
      assert_deprecated(gv_load_file_settings_cache.column_papping(upper(par_column_brief))
             .data_type != pkg_load_file_to_table.gc_column_type_number
            , 'Невозможно получить значение поля ' || gv_load_file_settings_cache.column_papping(upper(par_column_brief))
             .column_name || '(' || gv_load_file_settings_cache.column_papping(upper(par_column_brief))
             .data_type || ') в формате числа');
    
      v_format       := gv_load_file_settings_cache.column_papping(upper(par_column_brief)).format;
      v_nls_settings := gv_load_file_settings_cache.column_papping(upper(par_column_brief))
                        .nls_numeric_characters;
    
        v_value := convert_to_number(TRIM(v_varchar_value), v_format, v_nls_settings);
    END IF;
  
    RETURN v_value;
  
  END get_row_value_number;

  FUNCTION get_value_string
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_value load_file_rows.val_1%TYPE;
  BEGIN
    IF get_conflict_priority = 1
    THEN
      v_value := get_option_value_string(par_option_brief => par_brief);
    
      IF v_value IS NULL
      THEN
        v_value := get_row_value_string(par_column_brief     => par_brief
                                       ,par_load_file_row_id => par_load_file_row_id);
      END IF;
    
    ELSE
    
      v_value := get_row_value_string(par_column_brief     => par_brief
                                     ,par_load_file_row_id => par_load_file_row_id);
      IF v_value IS NULL
      THEN
        v_value := get_option_value_string(par_option_brief => par_brief);
      END IF;
    END IF;
  
    RETURN v_value;
  END get_value_string;

  FUNCTION get_value_date
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN DATE IS
    v_value DATE;
  BEGIN
    IF get_conflict_priority = 1
    THEN
      v_value := get_option_value_date(par_option_brief => par_brief);
    
      IF v_value IS NULL
      THEN
        v_value := get_row_value_date(par_column_brief     => par_brief
                                     ,par_load_file_row_id => par_load_file_row_id);
      END IF;
    
    ELSE
    
      v_value := get_row_value_date(par_column_brief     => par_brief
                                   ,par_load_file_row_id => par_load_file_row_id);
      IF v_value IS NULL
      THEN
        v_value := get_option_value_date(par_option_brief => par_brief);
      END IF;
    END IF;
  
    RETURN v_value;
  END get_value_date;

  FUNCTION get_value_number
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN NUMBER IS
    v_value NUMBER;
  BEGIN
    IF get_conflict_priority = 1
    THEN
      v_value := get_option_value_number(par_option_brief => par_brief);
    
      IF v_value IS NULL
      THEN
        v_value := get_row_value_number(par_column_brief     => par_brief
                                       ,par_load_file_row_id => par_load_file_row_id);
      END IF;
    
    ELSE
    
      v_value := get_row_value_number(par_column_brief     => par_brief
                                     ,par_load_file_row_id => par_load_file_row_id);
      IF v_value IS NULL
      THEN
        v_value := get_option_value_number(par_option_brief => par_brief);
      END IF;
    END IF;
  
    RETURN v_value;
  END get_value_number;

  /*
    Капля П.
    получение значения параметра заголовка теукщего файла по брифу
  */
  FUNCTION get_file_header_param_string
  (
    par_parameter_brief load_csv_header_settings.brief%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN load_file_header_params.value%TYPE IS
    v_value load_file_header_params.value%TYPE;
  BEGIN
    v_value := gv_load_file_settings_cache.file_header_parameters(upper(par_parameter_brief)).value;
    RETURN v_value;
  EXCEPTION
    WHEN no_data_found THEN
      IF nvl(par_raise_on_error, TRUE)
      THEN
        ex.raise('Не удалось определить параметр из заголовка файла по брифу ' || par_parameter_brief);
      END IF;
  END get_file_header_param_string;

  FUNCTION get_file_header_param_number
  (
    par_parameter_brief load_csv_header_settings.brief%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER IS
    v_original_value load_file_header_params.value%TYPE;
    v_value          NUMBER;
    v_format         load_csv_header_settings.format%TYPE;
    v_nls_settings   load_csv_header_settings.nls_numeric_characters%TYPE;
  BEGIN
    v_original_value := get_file_header_param_string(par_parameter_brief => par_parameter_brief
                                                    ,par_raise_on_error  => par_raise_on_error);
  
    assert_deprecated(gv_load_file_settings_cache.column_papping(upper(par_parameter_brief))
           .data_type != pkg_load_file_to_table.gc_column_type_number
          , 'Невозможно получить значение поля заголовка ' || gv_load_file_settings_cache.column_papping(upper(par_parameter_brief))
           .column_name || '(' || gv_load_file_settings_cache.column_papping(upper(par_parameter_brief))
           .data_type || ') в формате числа');
  
    v_format       := gv_load_file_settings_cache.file_header_parameters(upper(par_parameter_brief))
                      .format;
    v_nls_settings := gv_load_file_settings_cache.file_header_parameters(upper(par_parameter_brief))
                      .nls_numeric_characters;
  
    BEGIN
      v_value := convert_to_number(TRIM(v_original_value), v_format, v_nls_settings);
    EXCEPTION
      WHEN invalid_number THEN
        ex.raise('Значение "' || v_original_value || '" в поле "' || par_parameter_brief ||
                 '" не является числом');
    END;
  
    RETURN v_value;
  
  END get_file_header_param_number;

  FUNCTION get_file_header_param_date
  (
    par_parameter_brief load_csv_header_settings.brief%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN DATE IS
    v_original_value load_file_header_params.value%TYPE;
    v_value          DATE;
  BEGIN
    v_original_value := get_file_header_param_string(par_parameter_brief => par_parameter_brief
                                                    ,par_raise_on_error  => par_raise_on_error);
  
    assert_deprecated(gv_load_file_settings_cache.column_papping(upper(par_parameter_brief))
           .data_type != pkg_load_file_to_table.gc_column_type_date
          , 'Невозможно получить значение поля ' || gv_load_file_settings_cache.column_papping(upper(par_parameter_brief))
           .column_name || '(' || gv_load_file_settings_cache.column_papping(upper(par_parameter_brief))
           .data_type || ') в формате даты');
  
    BEGIN
      v_value := to_date(TRIM(v_original_value)
                        ,gv_load_file_settings_cache.file_header_parameters(upper(par_parameter_brief))
                         .format);
    EXCEPTION
      WHEN date_format_error
           OR day_of_month_error
           OR not_a_numeric_char
           OR pkg_oracle_exceptions.date_format_pic_ends THEN
        ex.raise('Значение "' || v_original_value || '" в поле "' || par_parameter_brief ||
                 '" не является датой');
    END;
  
    RETURN v_value;
  END get_file_header_param_date;

  /*
    Капля П.
    Получение занчения из строки файли или набора дополнительных параметров по брифу в соответствие с приоритетом разрешения конфликтов
  */
  FUNCTION get_value_by_brief
  (
    par_brief            VARCHAR2
   ,par_load_file_row_id load_file_rows.load_file_rows_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_value load_file_rows.val_1%TYPE;
  BEGIN
    IF get_conflict_priority = 1
    THEN
    
      v_value := get_parameter_value(par_option_brief => upper(par_brief));
      IF v_value IS NULL
      THEN
        v_value := get_row_value_by_column_brief(par_column_brief     => upper(par_brief)
                                                ,par_load_file_row_id => par_load_file_row_id);
      END IF;
    
    ELSE
    
      v_value := get_row_value_by_column_brief(par_column_brief     => upper(par_brief)
                                              ,par_load_file_row_id => par_load_file_row_id);
      IF v_value IS NULL
      THEN
        v_value := get_parameter_value(par_option_brief => upper(par_brief));
      END IF;
    
    END IF;
  
    RETURN v_value;
  END get_value_by_brief;

  /*
    Пиядин А.
    Проуедура проверки прав
  */
  PROCEDURE check_rights
  (
    par_load_file_id load_file.load_file_id%TYPE
   ,par_right_brief  safety_right.brief%TYPE
  ) IS
  BEGIN
    IF safety.check_right_custom(p_obj_id => par_right_brief) <> 1
    THEN
      UPDATE load_file_rows
         SET row_status  = pkg_load_file_to_table.get_error
            ,row_comment = 'Проверка прав доступа'
       WHERE 1 = 1
         AND load_file_id = par_load_file_id
         AND row_status NOT IN (get_loaded, get_part_loaded);
    
      RAISE ex_load_not_have_permission;
    END IF;
  END;

  /*
    Пиядин А.
    Возвращает текущий порядковый номер в Журнале диагностики для текущего загружаемого файла
  */
  FUNCTION get_current_log_load_order_num RETURN load_file_row_log.load_order_num%TYPE IS
  BEGIN
    RETURN gv_load_file_settings_cache.log_load_order_num;
  END get_current_log_load_order_num;

END pkg_load_file_to_table; 
/
