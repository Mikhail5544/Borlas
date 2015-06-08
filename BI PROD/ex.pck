CREATE OR REPLACE PACKAGE ex IS

  TYPE typ_bulkex_varchar_index IS RECORD(
     collection_index VARCHAR2(32767)
    ,ERROR_CODE       INTEGER
    ,error_msg        VARCHAR2(4000)
    ,parsed_msg       VARCHAR2(32767));

  TYPE typ_bulkex_integer_index IS RECORD(
     collection_index PLS_INTEGER
    ,ERROR_CODE       INTEGER
    ,error_msg        VARCHAR2(4000)
    ,parsed_msg       VARCHAR2(32767));

  TYPE typ_bulk_ex_list_by_integer IS TABLE OF typ_bulkex_integer_index;
  TYPE typ_bulk_ex_list_by_varchar IS TABLE OF typ_bulkex_varchar_index;

  c_exception_not_predefined    CONSTANT PLS_INTEGER := -20100;
  c_no_data_found               CONSTANT PLS_INTEGER := -20101;
  c_too_many_rows               CONSTANT PLS_INTEGER := -20102;
  c_dup_val_on_index            CONSTANT PLS_INTEGER := -20103;
  c_value_error                 CONSTANT PLS_INTEGER := -20104;
  c_zero_divide                 CONSTANT PLS_INTEGER := -20105;
  c_subscript_beyond_count      CONSTANT PLS_INTEGER := -20106;
  c_subscript_outside_limit     CONSTANT PLS_INTEGER := -20107;
  c_cant_insert_null            CONSTANT PLS_INTEGER := -20108;
  c_cant_update_to_null         CONSTANT PLS_INTEGER := -20109;
  c_check_violated              CONSTANT PLS_INTEGER := -20110;
  c_parent_key_not_found        CONSTANT PLS_INTEGER := -20111;
  c_year_in_date_out_of_range   CONSTANT PLS_INTEGER := -20112;
  c_value_larger_than_precision CONSTANT PLS_INTEGER := -20113;
  c_resource_busy_nowait        CONSTANT PLS_INTEGER := -20114;
  c_collection_is_null          CONSTANT PLS_INTEGER := -20115;
  c_cursor_already_open         CONSTANT PLS_INTEGER := -20116;
  c_invalid_number              CONSTANT PLS_INTEGER := -20117;
  c_invalid_cursor              CONSTANT PLS_INTEGER := -20118;
  c_access_into_null            CONSTANT PLS_INTEGER := -20119;
  c_case_not_found              CONSTANT PLS_INTEGER := -20120;
  c_self_is_null                CONSTANT PLS_INTEGER := -20121;
  c_rowtype_mismatch            CONSTANT PLS_INTEGER := -20122;
  c_xmltype_parse_error         CONSTANT PLS_INTEGER := -20123;
  c_timeout_on_resource         CONSTANT PLS_INTEGER := -20124;
  c_login_denied                CONSTANT PLS_INTEGER := -20125;
  c_not_logged_on               CONSTANT PLS_INTEGER := -20126;
  c_program_error               CONSTANT PLS_INTEGER := -20127;
  c_storage_error               CONSTANT PLS_INTEGER := -20128;
  c_sys_invalid_rowid           CONSTANT PLS_INTEGER := -20129;
  c_bulk_dml_error              CONSTANT PLS_INTEGER := -20130;
  c_literal_does_not_match_form CONSTANT PLS_INTEGER := -20131;
  c_not_a_numeric_char          CONSTANT PLS_INTEGER := -20132;
  c_proc_func_doesnt_exists     CONSTANT PLS_INTEGER := -20133;
  c_date_format_pic_ends        CONSTANT PLS_INTEGER := -20134;
  c_child_record_found          CONSTANT PLS_INTEGER := -20135;
  c_value_too_large_for_column  CONSTANT PLS_INTEGER := -20135;
  c_custom_error                CONSTANT PLS_INTEGER := -20001;

  -- Данные не найдены
  exception_not_predefined EXCEPTION;
  PRAGMA EXCEPTION_INIT(exception_not_predefined, -20100);

  custom_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(custom_error, -20001);

  no_data_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_data_found, -20101);

  too_many_rows EXCEPTION;
  PRAGMA EXCEPTION_INIT(too_many_rows, -20102);

  dup_val_on_index EXCEPTION;
  PRAGMA EXCEPTION_INIT(dup_val_on_index, -20103);

  value_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(value_error, -20104);

  zero_divide EXCEPTION;
  PRAGMA EXCEPTION_INIT(zero_divide, -20105);

  subscript_beyond_count EXCEPTION;
  PRAGMA EXCEPTION_INIT(subscript_beyond_count, -20106);

  subscript_outside_limit EXCEPTION;
  PRAGMA EXCEPTION_INIT(subscript_outside_limit, -20107);

  -- Невозможно вставить NULL
  cant_insert_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_insert_null, -20108);

  -- Невозможно заменить на NULL
  cant_update_to_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_update_to_null, -20109);

  -- Нарушено ограничение CHECK
  check_violated EXCEPTION;
  PRAGMA EXCEPTION_INIT(check_violated, -20110);

  -- Нарушено ограничение FOREIGN KEY (parent key not found)
  parent_key_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(parent_key_not_found, -20111);

  -- Год в дате должен быть между -4713 и +9999
  year_in_date_out_of_range EXCEPTION;
  PRAGMA EXCEPTION_INIT(year_in_date_out_of_range, -20112);

  -- Значение превышает предусмотренную полем точность
  value_larger_than_precision EXCEPTION;
  PRAGMA EXCEPTION_INIT(value_larger_than_precision, -20113);

  -- Попытка залочить уже залоченную запись с NOWAIT
  resource_busy_nowait EXCEPTION;
  PRAGMA EXCEPTION_INIT(resource_busy_nowait, -20114);

  collection_is_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(collection_is_null, -20115);

  cursor_already_open EXCEPTION;
  PRAGMA EXCEPTION_INIT(cursor_already_open, -20116);

  invalid_number EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_number, -20117);

  invalid_cursor EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_cursor, -20118);

  access_into_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(access_into_null, -20119);

  case_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(case_not_found, -20120);

  self_is_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(self_is_null, -20121);

  rowtype_mismatch EXCEPTION;
  PRAGMA EXCEPTION_INIT(rowtype_mismatch, -20122);

  -- Ошибка при парсинге XML конструктором XMLTYPE
  xmltype_parse_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(xmltype_parse_error, -20123);

  timeout_on_resource EXCEPTION;
  PRAGMA EXCEPTION_INIT(timeout_on_resource, -20124);

  login_denied EXCEPTION;
  PRAGMA EXCEPTION_INIT(login_denied, -20125);

  not_logged_on EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_logged_on, -20126);

  program_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(program_error, -20127);

  storage_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(storage_error, -20128);

  sys_invalid_rowid EXCEPTION;
  PRAGMA EXCEPTION_INIT(sys_invalid_rowid, -20129);

  bulk_dml EXCEPTION;
  PRAGMA EXCEPTION_INIT(bulk_dml, -20130);

  literal_does_not_match_format EXCEPTION;
  PRAGMA EXCEPTION_INIT(literal_does_not_match_format, -20131);

  not_a_numeric_char EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_a_numeric_char, -20132);

  proc_func_doesnt_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(proc_func_doesnt_exists, -20133);

  date_format_pic_ends EXCEPTION;
  PRAGMA EXCEPTION_INIT(date_format_pic_ends, -20134);

  child_record_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(child_record_found, -20135);

  value_too_large_for_column EXCEPTION;
  PRAGMA EXCEPTION_INIT(value_too_large_for_column, -20135);

  FUNCTION get_column_comment
  (
    par_owner       VARCHAR2
   ,par_table_name  VARCHAR2
   ,par_column_name VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_table_comment
  (
    par_owner      VARCHAR2
   ,par_table_name VARCHAR2
  ) RETURN VARCHAR2;

  /*
  Вынес для теста
  */
  /*
  FUNCTION parse_oracle_sqlerrm
  (
    par_sql_code      INTEGER
   ,par_error_message VARCHAR2
  ) RETURN VARCHAR2;
  */

  /*
    Капля П.
    Основная процедура генерации ошибки
    Процедура переопределяет стандартные Оракловые ошибки и рейзит вместо них типизированные объявленные в пакете
    Также процедура
  */
  PROCEDURE RAISE
  (
    par_message             VARCHAR2 DEFAULT NULL
   ,par_sqlcode             PLS_INTEGER DEFAULT NULL
   ,par_put_on_top_of_stack BOOLEAN DEFAULT FALSE
  );

  /*
    Капля П.
    Процедура raise ошибки c_custom_error (-20001) кодом
  */
  PROCEDURE raise_custom
  (
    par_message             VARCHAR2
   ,par_put_on_top_of_stack BOOLEAN DEFAULT FALSE
  );
  /*
    Капля П.
    Функция удаления ORA-##### из начала текста ошибки
  */
  FUNCTION get_ora_trimmed_errmsg(par_string VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_beautify_error_message RETURN BOOLEAN;
  PROCEDURE set_beautify_error_message(par_beautify BOOLEAN);

  PROCEDURE process_bulk_exceptions(par_exception_summary OUT typ_bulk_ex_list_by_integer);
  PROCEDURE process_bulk_exceptions(par_exception_summary OUT typ_bulk_ex_list_by_varchar);

END ex;
/
CREATE OR REPLACE PACKAGE BODY ex IS

  TYPE t_error_code_mapping IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  SUBTYPE t_error_message IS VARCHAR2(2048);
  gv_error_code_mapping t_error_code_mapping;

  gv_beautify_error_message BOOLEAN := TRUE;

  gc_comment_separator CONSTANT VARCHAR2(1) := '|';

  /*
    Капля П.
    Функция удаления ORA-##### из начала текста ошибки
  */
  FUNCTION get_ora_trimmed_errmsg(par_string VARCHAR2) RETURN VARCHAR2 IS
    v_trimmed_string t_error_message;
    c_pattern CONSTANT VARCHAR2(255) := '^(ORA)-?[[:digit:]]{1,5}:\s';
  BEGIN
    v_trimmed_string := regexp_replace(par_string, c_pattern);
    RETURN v_trimmed_string;
  END get_ora_trimmed_errmsg;

  FUNCTION get_column_comment
  (
    par_owner       VARCHAR2
   ,par_table_name  VARCHAR2
   ,par_column_name VARCHAR2
  ) RETURN VARCHAR2 IS
    v_comment all_col_comments.comments%TYPE;
  BEGIN
    BEGIN
      SELECT nvl(regexp_substr(t.comments, '[^' || gc_comment_separator || ']+'), t.column_name)
        INTO v_comment
        FROM all_col_comments t
       WHERE t.table_name = upper(par_table_name)
         AND t.column_name = upper(par_column_name)
         AND t.owner = upper(par_owner);
    EXCEPTION
      WHEN standard.no_data_found THEN
        v_comment := upper(par_column_name);
    END;
    RETURN v_comment;
  END get_column_comment;

  FUNCTION get_table_comment
  (
    par_owner      VARCHAR2
   ,par_table_name VARCHAR2
  ) RETURN VARCHAR2 IS
    v_table_comment all_tab_comments.comments%TYPE;
  BEGIN
    BEGIN
      SELECT nvl(regexp_substr(t.comments, '[^' || gc_comment_separator || ']+')
                ,upper(par_table_name))
        INTO v_table_comment
        FROM all_tab_comments t
       WHERE t.owner = upper(par_owner)
         AND t.table_name = upper(par_table_name);
    EXCEPTION
      WHEN standard.no_data_found THEN
        v_table_comment := upper(par_table_name);
    END;
    RETURN v_table_comment;
  END get_table_comment;

  /*
    Капля П.
    Процедура получения из изначального текста ошибки владельца и названия объекта
    Работает со строками формата 
    ORA-00001: нарушено ограничение уникальности (INS.PK_T_TELEPHONE_TYPE)
  */
  PROCEDURE parse_object_owner_name_field
  (
    par_message    t_error_message
   ,par_owner_out  OUT VARCHAR2
   ,par_object_out OUT VARCHAR2
   ,par_field_out  OUT VARCHAR2
  ) IS
    c_main_pattern    CONSTANT VARCHAR2(20) := '\([A-z0-9_."]+\)';
    c_replace_pattern CONSTANT VARCHAR2(10) := '[()"]';
    v_full_constraint_name VARCHAR2(255);
    v_objects              tt_one_col;
  BEGIN
    v_full_constraint_name := regexp_replace(regexp_substr(par_message, c_main_pattern)
                                            ,c_replace_pattern);
  
    v_objects := pkg_utils.get_splitted_string(par_string    => v_full_constraint_name
                                              ,par_separator => '.');
    IF v_objects.count > 0
    THEN
      par_owner_out := v_objects(1);
      IF v_objects.count > 1
      THEN
        par_object_out := v_objects(2);
        IF v_objects.count > 2
        THEN
          par_field_out := v_objects(3);
        END IF;
      END IF;
    END IF;
  
  END parse_object_owner_name_field;

  PROCEDURE parse_object_owner_name
  (
    par_message    t_error_message
   ,par_owner_out  OUT VARCHAR2
   ,par_object_out OUT VARCHAR2
  ) IS
    v_field_out VARCHAR2(30);
  BEGIN
  
    parse_object_owner_name_field(par_message, par_owner_out, par_object_out, v_field_out);
  
  END parse_object_owner_name;

  /*
    Капля П.
    Процедура формирования текста ошибки при нарушении уникальности
    ORA-00001: нарушено ограничение уникальности (INS.PK_T_TELEPHONE_TYPE)
  */
  FUNCTION parse_dup_val_on_index(par_message t_error_message) RETURN t_error_message IS
    v_parsed_message t_error_message;
  
    v_owner           user_cons_columns.owner%TYPE;
    v_constraint_name user_cons_columns.constraint_name%TYPE;
  
    v_table_comment    all_tab_comments.comments%TYPE;
    v_columns_comments tt_one_col;
  BEGIN
    parse_object_owner_name(par_message    => par_message
                           ,par_owner_out  => v_owner
                           ,par_object_out => v_constraint_name);
  
    BEGIN
      WITH cons AS
       (SELECT cc.table_name
              ,cc.column_name
              ,cc.owner
          FROM all_cons_columns cc
         WHERE cc.owner = v_owner
           AND cc.constraint_name = v_constraint_name)
      SELECT get_table_comment(cc.owner, cc.table_name)
            ,CAST(MULTISET
                  (SELECT get_column_comment(c.owner, c.table_name, c.column_name) FROM cons c) AS
                  tt_one_col)
        INTO v_table_comment
            ,v_columns_comments
        FROM cons cc
       GROUP BY cc.owner
               ,cc.table_name;
    EXCEPTION
      WHEN standard.no_data_found THEN
        WITH cons AS
         (SELECT cc.table_name
                ,cc.column_name
                ,cc.table_owner AS owner
            FROM all_ind_columns cc
           WHERE cc.index_owner = v_owner
             AND cc.index_name = v_constraint_name)
        SELECT get_table_comment(cc.owner, cc.table_name)
              ,CAST(MULTISET
                    (SELECT get_column_comment(c.owner, c.table_name, c.column_name) FROM cons c) AS
                    tt_one_col)
          INTO v_table_comment
              ,v_columns_comments
          FROM cons cc
         GROUP BY cc.owner
                 ,cc.table_name;
    END;
  
    IF v_columns_comments.count > 1
    THEN
      v_parsed_message := 'Нарушено ограничение уникальности полей ';
    ELSE
      v_parsed_message := 'Нарушено ограничение уникальности поля ';
    END IF;
    v_parsed_message := v_parsed_message || '"' ||
                        pkg_utils.get_aggregated_string(v_columns_comments, ', ') || '"' ||
                        ' таблицы ' || '"' || v_table_comment || '"';
  
    RETURN v_parsed_message;
  END parse_dup_val_on_index;

  /*
    Капля П.
    Процедура формирования текста ошибки при нарушении констрейнта
  */
  FUNCTION parse_check_violated(par_message t_error_message) RETURN t_error_message IS
    v_parsed_message t_error_message;
  
    v_owner           user_cons_columns.owner%TYPE;
    v_constraint_name user_cons_columns.constraint_name%TYPE;
  BEGIN
    parse_object_owner_name(par_message    => par_message
                           ,par_owner_out  => v_owner
                           ,par_object_out => v_constraint_name);
  
    v_parsed_message := 'Нарушено ограничение целостности (' || v_owner || '.' || v_constraint_name || ')';
    RETURN v_parsed_message;
  END parse_check_violated;

  /*
    Капля П.
    Формирование текста ошибки на нарушение целостности по внешнему ключу    
    ORA-02291: нарушено ограничение целостности (INS.FK_T_TASK_ITEM_TASK) - исходный ключ не найден
  */
  FUNCTION parse_parent_key_not_found(par_message t_error_message) RETURN t_error_message IS
    v_parsed_message t_error_message;
  
    v_owner           all_constraints.owner%TYPE;
    v_constraint_name all_constraints.constraint_name%TYPE;
    v_table_name      all_constraints.table_name%TYPE;
  
    v_table_comment all_tab_comments.comments%TYPE;
  
  BEGIN
    parse_object_owner_name(par_message    => par_message
                           ,par_owner_out  => v_owner
                           ,par_object_out => v_constraint_name);
  
    SELECT cc2.owner
          ,cc2.table_name
      INTO v_owner
          ,v_table_name
      FROM all_constraints cc
          ,all_constraints cc2
     WHERE cc.owner = v_owner
       AND cc.constraint_name = v_constraint_name
       AND cc2.owner = cc.r_owner
       AND cc2.constraint_name = cc.r_constraint_name;
  
    v_table_comment := get_table_comment(par_owner => v_owner, par_table_name => v_table_name);
  
    v_parsed_message := 'Не найдена родительская запись в таблице "' || v_table_comment || '"';
  
    RETURN v_parsed_message;
  
  END parse_parent_key_not_found;

  /*
    Капля П.
    Процедура формирования текста ошибки на cant_insert_null, cant_update_null
  */
  FUNCTION parse_cant_insertupdate_null(par_message t_error_message) RETURN t_error_message IS
    v_parsed_message t_error_message;
    v_owner          all_tab_columns.owner%TYPE;
    v_table_name     all_tab_columns.table_name%TYPE;
    v_column_name    all_tab_columns.column_name%TYPE;
    v_table_comment  all_tab_comments.comments%TYPE;
    v_column_comment all_col_comments.comments%TYPE;
  BEGIN
    parse_object_owner_name_field(par_message, v_owner, v_table_name, v_column_name);
  
    v_table_comment  := get_table_comment(v_owner, v_table_name);
    v_column_comment := get_column_comment(v_owner, v_table_name, v_column_name);
  
    v_parsed_message := 'Невозможно вставить пустое значение в поле "' || v_column_comment ||
                        '" таблицы "' || v_table_comment || '"';
  
    RETURN v_parsed_message;
  END parse_cant_insertupdate_null;

  /*
    Капля П.
    Процедура формирования ошибки no_data_found
  */
  FUNCTION parse_no_data_found(par_message t_error_message) RETURN t_error_message IS
    v_parsed_message t_error_message;
  BEGIN
    v_parsed_message := 'Данные не найдены';
  
    RETURN v_parsed_message;
  END parse_no_data_found;

  FUNCTION parse_too_many_rows(par_message t_error_message) RETURN t_error_message IS
    v_parsed_message t_error_message;
  BEGIN
    v_parsed_message := 'Точная выборка вернула больше одной строки';
  
    RETURN v_parsed_message;
  END parse_too_many_rows;

  /*
    Капля П.
    Процедура формирования красивого текста ошибки
  */
  FUNCTION parse_oracle_sqlerrm
  (
    par_sql_code      INTEGER
   ,par_error_message VARCHAR2
  ) RETURN VARCHAR2 IS
    v_errm t_error_message;
  BEGIN
  
    -- Определяем тип ошибки и пытаемся сформировать красивую ошибку
    v_errm := CASE par_sql_code
                WHEN pkg_oracle_exceptions.c_dup_val_on_index THEN
                 parse_dup_val_on_index(par_error_message)
                WHEN pkg_oracle_exceptions.c_check_violated THEN
                 parse_check_violated(par_error_message)
                WHEN pkg_oracle_exceptions.c_parent_key_not_found THEN
                 parse_parent_key_not_found(par_error_message)
                WHEN pkg_oracle_exceptions.c_no_data_found THEN
                 parse_no_data_found(par_error_message)
                WHEN pkg_oracle_exceptions.c_no_data_found2 THEN
                 parse_no_data_found(par_error_message)
                WHEN pkg_oracle_exceptions.c_too_many_rows THEN
                 parse_too_many_rows(par_error_message)
                WHEN pkg_oracle_exceptions.c_cant_insert_null THEN
                 parse_cant_insertupdate_null(par_error_message)
                WHEN pkg_oracle_exceptions.c_cant_update_to_null THEN
                 parse_cant_insertupdate_null(par_error_message)
                ELSE
                 get_ora_trimmed_errmsg(par_error_message)
              END;
  
    RETURN v_errm;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END parse_oracle_sqlerrm;

  /*
    Капля П.
    Основная процедура генерации ошибки
    Процедура переопределяет стандартные Оракловые ошибки и рейзит вместо них типизированные объявленные в пакете
    Также процедура 
  */
  PROCEDURE RAISE
  (
    par_message             VARCHAR2 DEFAULT NULL
   ,par_sqlcode             PLS_INTEGER DEFAULT NULL
   ,par_put_on_top_of_stack BOOLEAN DEFAULT FALSE
  ) IS
    v_new_error_code PLS_INTEGER;
    v_message        t_error_message;
    v_sql_code       INTEGER;
    v_orig_sql_code  INTEGER;
  
    FUNCTION is_oracle_exception(par_sqlcode INTEGER) RETURN BOOLEAN IS
    BEGIN
      RETURN par_sqlcode NOT BETWEEN - 20999 AND - 20000;
    END is_oracle_exception;
  BEGIN
    v_message := nvl(par_message, get_ora_trimmed_errmsg(SQLERRM));
  
    IF SQLCODE != 0
    THEN
      v_sql_code := SQLCODE;
    END IF;
  
    IF par_message IS NOT NULL
    THEN
      v_message := par_message;
    ELSE
      -- Если ошибка Оракловая и установлен флаг формирования красивой ошибки - формируем ее
      -- Флаг можно отключать при пакетной работе с данными
      IF is_oracle_exception(v_sql_code)
         AND gv_beautify_error_message
      THEN
        v_message := parse_oracle_sqlerrm(v_sql_code, SQLERRM);
      ELSE
        v_message := get_ora_trimmed_errmsg(SQLERRM);
      END IF;
    END IF;
  
    v_orig_sql_code := coalesce(par_sqlcode, v_sql_code, c_custom_error);
  
    BEGIN
      v_new_error_code := gv_error_code_mapping(v_orig_sql_code);
    EXCEPTION
      WHEN standard.no_data_found THEN
        IF is_oracle_exception(v_orig_sql_code)
        THEN
          -- Если ошибка оракловая не предусмотрена даным пакетом, мы не сможем ее ререйзнуть
          -- поэтому валимся таким образом
          v_new_error_code := c_exception_not_predefined;
          v_message        := 'Ошибка ORA-' || v_orig_sql_code || ' не предусмотрена в пакете ex.';
        ELSE
          -- Если это пользовательская ошибка и ей нет аналога в пакете, то просто ререйзим ее
          v_new_error_code := v_orig_sql_code;
        END IF;
    END;
  
    raise_application_error(v_new_error_code, v_message, par_put_on_top_of_stack);
  END RAISE;

  /*
    Капля П.
    Процедура raise ошибки c_custom_error (-20001) кодом
  */
  PROCEDURE raise_custom
  (
    par_message             VARCHAR2
   ,par_put_on_top_of_stack BOOLEAN DEFAULT FALSE
  ) IS
  BEGIN
    ex.raise(par_message             => par_message
            ,par_sqlcode             => ex.c_custom_error
            ,par_put_on_top_of_stack => par_put_on_top_of_stack);
  END raise_custom;

  FUNCTION get_beautify_error_message RETURN BOOLEAN IS
  BEGIN
    RETURN gv_beautify_error_message;
  END get_beautify_error_message;

  PROCEDURE set_beautify_error_message(par_beautify BOOLEAN) IS
  BEGIN
    gv_beautify_error_message := par_beautify;
  END set_beautify_error_message;

  PROCEDURE process_bulk_exceptions(par_exception_summary OUT typ_bulk_ex_list_by_integer) IS
    v_single_error_summary typ_bulkex_integer_index;
  BEGIN
    IF SQL%bulk_exceptions.count > 0
    THEN
      par_exception_summary := typ_bulk_ex_list_by_integer();
      FOR i IN 1 .. SQL%bulk_exceptions.count
      LOOP
        v_single_error_summary.collection_index := SQL%BULK_EXCEPTIONS(i).error_index;
        v_single_error_summary.error_code       := SQL%BULK_EXCEPTIONS(i).error_code;
        v_single_error_summary.error_msg        := SQLERRM(-v_single_error_summary.error_code);
        v_single_error_summary.parsed_msg       := parse_oracle_sqlerrm(v_single_error_summary.error_code
                                                                       ,v_single_error_summary.error_msg);
        par_exception_summary.extend;
        par_exception_summary(par_exception_summary.last) := v_single_error_summary;
      
      END LOOP;
    END IF;
  END process_bulk_exceptions;

  PROCEDURE process_bulk_exceptions(par_exception_summary OUT typ_bulk_ex_list_by_varchar) IS
    v_single_error_summary typ_bulkex_varchar_index;
  BEGIN
    IF SQL%bulk_exceptions.count > 0
    THEN
      par_exception_summary := typ_bulk_ex_list_by_varchar();
      FOR i IN 1 .. SQL%bulk_exceptions.count
      LOOP
        v_single_error_summary.collection_index := SQL%BULK_EXCEPTIONS(i).error_index;
        v_single_error_summary.error_code       := SQL%BULK_EXCEPTIONS(i).error_code;
        v_single_error_summary.error_msg        := SQLERRM(-v_single_error_summary.error_code);
        v_single_error_summary.parsed_msg       := parse_oracle_sqlerrm(v_single_error_summary.error_code
                                                                       ,v_single_error_summary.error_msg);
        par_exception_summary.extend;
        par_exception_summary(par_exception_summary.last) := v_single_error_summary;
      
      END LOOP;
    END IF;
  END process_bulk_exceptions;

BEGIN
  DECLARE
    v_key PLS_INTEGER;
  BEGIN
  
    -- CUSTOM ERROR
    gv_error_code_mapping(c_custom_error) := c_custom_error;
  
    -- Данные не найдены
    -- no_data_found EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_no_data_found) := c_no_data_found;
    gv_error_code_mapping(pkg_oracle_exceptions.c_no_data_found2) := c_no_data_found;
  
    --too_many_rows EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_too_many_rows) := c_too_many_rows;
  
    --dup_val_on_index EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_dup_val_on_index) := c_dup_val_on_index;
  
    --value_error EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_value_error) := c_value_error;
  
    --zero_divide EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_zero_divide) := c_zero_divide;
  
    --subscript_beyond_count EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_subscript_beyond_count) := c_subscript_beyond_count;
  
    --subscript_outside_limit EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_subscript_outside_limit) := c_subscript_outside_limit;
  
    -- Невозможно вставить NULL
    --cant_insert_null EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_cant_insert_null) := c_cant_insert_null;
  
    -- Невозможно заменить на NULL
    --cant_update_to_null EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_cant_update_to_null) := c_cant_update_to_null;
  
    -- Нарушено ограничение CHECK
    --check_violated EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_check_violated) := c_check_violated;
  
    -- Нарушено ограничение FOREIGN KEY (parent key not found)
    --parent_key_not_found EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_parent_key_not_found) := c_parent_key_not_found;
  
    -- Год в дате должен быть между -4713 и +9999
    --year_in_date_out_of_range EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_year_in_date_out_of_range) := c_year_in_date_out_of_range;
  
    -- Значение превышает предусмотренную полем точность
    --value_larger_than_precision EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_value_larger_than_precision) := c_value_larger_than_precision;
  
    -- Попытка залочить уже залоченную запись с NOWAIT
    --resource_busy_nowait EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_resource_busy_nowait) := c_resource_busy_nowait;
  
    --collection_is_null EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_collection_is_null) := c_collection_is_null;
  
    --cursor_already_open EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_cursor_already_open) := c_cursor_already_open;
  
    --invalid_number EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_invalid_number) := c_invalid_number;
  
    --invalid_cursor EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_invalid_cursor) := c_invalid_cursor;
  
    --access_into_null EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_access_into_null) := c_access_into_null;
  
    --case_not_found EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_case_not_found) := c_case_not_found;
  
    --self_is_null EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_self_is_null) := c_self_is_null;
  
    --rowtype_mismatch EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_rowtype_mismatch) := c_rowtype_mismatch;
  
    -- Ошибка при парсинге XML конструктором XMLTYPE
    --xmltype_parse_error EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_xmltype_parse_error) := c_xmltype_parse_error;
  
    --timeout_on_resource EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_timeout_on_resource) := c_timeout_on_resource;
  
    --login_denied EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_login_denied) := c_login_denied;
  
    --not_logged_on EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_not_logged_on) := c_not_logged_on;
  
    --program_error EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_program_error) := c_program_error;
  
    --storage_error EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_storage_error) := c_storage_error;
  
    --sys_invalid_rowid EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_sys_invalid_rowid) := c_sys_invalid_rowid;
  
    --bulk_dml EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_bulk_dml) := c_bulk_dml_error;
  
    --exception_not_predefined EXCEPTION;
    gv_error_code_mapping(c_exception_not_predefined) := c_exception_not_predefined;
  
    --child_record_found EXCEPTION;
    gv_error_code_mapping(pkg_oracle_exceptions.c_child_record_found) := c_child_record_found;
  
    v_key := gv_error_code_mapping.first;
  
    LOOP
      EXIT WHEN v_key IS NULL;
      IF NOT gv_error_code_mapping.exists(gv_error_code_mapping(v_key))
      THEN
        gv_error_code_mapping(gv_error_code_mapping(v_key)) := gv_error_code_mapping(v_key);
      END IF;
      v_key := gv_error_code_mapping.next(v_key);
    END LOOP;
  
  END;
END; 
/
