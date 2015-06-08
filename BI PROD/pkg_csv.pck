CREATE OR REPLACE PACKAGE pkg_csv IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 13.05.2014 23:02:54
  -- Purpose : Работа с CSV

  gc_without_header         CONSTANT NUMBER(1) := 0;
  gc_header_from_selectlist CONSTANT NUMBER(1) := 1;
  gc_header_from_parameter  CONSTANT NUMBER(1) := 2;

  /*
    Формирует CSV в качестве результата запроса
    par_select        - Запрос
    par_header_option - Вид заголовка:
                          0 - Нет заголовка, 1 - заголовок из полей запроса
                          2 - заголовок из параметра
    par_columns       - Список полей, если не указан, список полей берется из запроса
    par_csv           - Файл в формате CSV
  */
  PROCEDURE select_to_csv
  (
    par_select        IN VARCHAR2
   ,par_header_option IN NUMBER
   ,par_header        tt_one_col DEFAULT tt_one_col()
   ,par_row_count     OUT PLS_INTEGER
   ,par_csv           IN OUT CLOB
  );
  PROCEDURE select_to_csv
  (
    par_select        IN VARCHAR2
   ,par_header_option IN NUMBER
   ,par_header        tt_one_col DEFAULT tt_one_col()
   ,par_csv           IN OUT CLOB
  );

  FUNCTION csv_string_to_array
  (
    par_line          VARCHAR2
   ,par_columns_count NUMBER
  ) RETURN tt_one_col;

  FUNCTION get_row
  (
    par_csv        CLOB
   ,par_row_number NUMBER
  ) RETURN VARCHAR2;

  /* Новая строка */
  PROCEDURE write_row(par_csv IN OUT CLOB);

  /* Добавить значение ячейки */
  PROCEDURE add_value(par_value VARCHAR2);
END pkg_csv;
/
CREATE OR REPLACE PACKAGE BODY pkg_csv IS

  gc_separator CONSTANT VARCHAR2(1) := ';';
  gc_new_line  CONSTANT VARCHAR2(2) := chr(13) || chr(10);
  /* Переменная разделитель используется в кастомной процедуре формирования файла */
  gv_columns_fixed BOOLEAN := FALSE;
  gv_value_index   PLS_INTEGER := 0;
  gv_line          tt_one_col := tt_one_col();

  /*
    Формирует CSV в качестве результата запроса
    Формирует CSV в качестве результата запроса
    par_select        - Запрос
    par_header_option - Вид заголовка:
                          0 - Нет заголовка, 1 - заголовок из полей запроса
                          2 - заголовок из параметра
    par_columns       - Список полей, если не указан, список полей берется из запроса
    par_csv           - Файл в формате CSV
  */
  PROCEDURE select_to_csv
  (
    par_select        IN VARCHAR2
   ,par_header_option IN NUMBER
   ,par_header        tt_one_col DEFAULT tt_one_col()
   ,par_row_count     OUT PLS_INTEGER
   ,par_csv           IN OUT CLOB
  ) IS
    c_number   CONSTANT BINARY_INTEGER := 2;
    c_varchar2 CONSTANT BINARY_INTEGER := 1;
    c_date     CONSTANT BINARY_INTEGER := 12;
  
    c_date_mask CONSTANT VARCHAR2(10) := 'dd.mm.yyyy';
  
    v_cursor_id    NUMBER;
    v_column_count NUMBER;
    v_dummy_count  NUMBER;
    v_columns      dbms_sql.desc_tab;
  
    v_row          VARCHAR2(32767);
    v_number_value NUMBER;
    v_vc2_value    VARCHAR2(4000);
    v_date_value   DATE;
  BEGIN
    assert_deprecated(TRIM(par_select) IS NULL
          ,'Не указан запрос для формирования файла');
    assert_deprecated(par_header_option NOT IN (0, 1, 2) OR par_header_option IS NULL
          ,'Значение параметра "Вид заголовка" неверно!');
    -- Если заголовок из списка полей, должен быть указан список
    assert_deprecated(par_header_option = gc_header_from_parameter AND
           (par_header IS NULL OR par_header.count = 0)
          ,'Ожидается список полей заголовка в качестве параметра');
  
    v_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(c => v_cursor_id, STATEMENT => par_select, language_flag => dbms_sql.native);
    dbms_sql.describe_columns(c => v_cursor_id, col_cnt => v_column_count, desc_t => v_columns);
  
    -- Если передано значение для заголовка, проверяем,
    -- чтобы количество столбцов совпадало с количеством элементов заголовка
    assert_deprecated(par_header IS NOT NULL AND par_header.count > 0 AND par_header.count != v_column_count
          ,'Количество значений для заголовка таблицы не совпадает с количеством полей в запросе');
    -- Очистка файла на случай, если в нем что-то было
    dbms_lob.trim(lob_loc => par_csv, newlen => 0);
    -- Заголовок
    FOR v_idx IN v_columns.first .. v_columns.last
    LOOP
      IF par_header_option = gc_header_from_parameter
      THEN
        v_row := v_row || par_header(v_idx) || gc_separator;
      ELSIF par_header_option = gc_header_from_selectlist
      THEN
        v_row := v_row || v_columns(v_idx).col_name || gc_separator;
      END IF;
      -- Определяем переменные для значений различных типов
      IF v_columns(v_idx).col_type = c_number
      THEN
        dbms_sql.define_column(c => v_cursor_id, position => v_idx, column => v_number_value);
      ELSIF v_columns(v_idx).col_type = c_varchar2
      THEN
        dbms_sql.define_column(c           => v_cursor_id
                              ,position    => v_idx
                              ,column      => v_vc2_value
                              ,column_size => 4000);
      ELSIF v_columns(v_idx).col_type = c_date
      THEN
        dbms_sql.define_column(c => v_cursor_id, position => v_idx, column => v_date_value);
      ELSE
        raise_application_error(-20001
                               ,'Тип данных поля "' || v_columns(v_idx).col_name ||
                                '" не поддерживается');
      END IF;
    END LOOP;
    IF par_header_option IN (gc_header_from_selectlist, gc_header_from_parameter)
    THEN
      v_row := regexp_replace(v_row, gc_separator || '{1}$');
      dbms_lob.writeappend(lob_loc => par_csv, amount => length(v_row), buffer => v_row);
      v_row := gc_new_line;
    END IF;
    v_dummy_count := dbms_sql.execute(c => v_cursor_id);
    par_row_count := 0;
    -- Тело
    WHILE dbms_sql.fetch_rows(c => v_cursor_id) > 0
    LOOP
      par_row_count := par_row_count + 1;
      FOR v_idx IN v_columns.first .. v_columns.last
      LOOP
        IF v_columns(v_idx).col_type = c_number
        THEN
          dbms_sql.column_value(c => v_cursor_id, position => v_idx, VALUE => v_number_value);
          v_row := v_row || to_char(v_number_value) || gc_separator;
        ELSIF v_columns(v_idx).col_type = c_varchar2
        THEN
          dbms_sql.column_value(c => v_cursor_id, position => v_idx, VALUE => v_vc2_value);
          IF regexp_like(v_vc2_value, '["' || gc_separator || ']')
          THEN
            v_vc2_value := '"' || v_vc2_value || '"';
          END IF;
          v_row := v_row || v_vc2_value || gc_separator;
        ELSIF v_columns(v_idx).col_type = c_date
        THEN
          dbms_sql.column_value(c => v_cursor_id, position => v_idx, VALUE => v_date_value);
          v_row := v_row || to_char(v_date_value, c_date_mask) || gc_separator;
        END IF;
      END LOOP;
      v_row := regexp_replace(v_row, gc_separator || '{1}$');
      dbms_lob.writeappend(lob_loc => par_csv, amount => length(v_row), buffer => v_row);
      v_row := gc_new_line;
    END LOOP;
  
    IF dbms_sql.is_open(c => v_cursor_id)
    THEN
      dbms_sql.close_cursor(c => v_cursor_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_sql.is_open(c => v_cursor_id)
      THEN
        dbms_sql.close_cursor(c => v_cursor_id);
      END IF;
      RAISE;
  END select_to_csv;

  PROCEDURE select_to_csv
  (
    par_select        IN VARCHAR2
   ,par_header_option IN NUMBER
   ,par_header        tt_one_col DEFAULT tt_one_col()
   ,par_csv           IN OUT CLOB
  ) IS
    v_row_count PLS_INTEGER;
  BEGIN
    select_to_csv(par_select        => par_select
                 ,par_header_option => par_header_option
                 ,par_header        => par_header
                 ,par_row_count     => v_row_count
                 ,par_csv           => par_csv);
  END select_to_csv;

  FUNCTION csv_string_to_array
  (
    par_line          VARCHAR2
   ,par_columns_count NUMBER
  ) RETURN tt_one_col IS
    v_retval tt_one_col := tt_one_col();
  BEGIN
    IF (par_line IS NULL)
       OR (length(REPLACE(par_line, ';')) = 0)
    THEN
      RETURN NULL;
    END IF;
    v_retval.extend(par_columns_count);
    FOR v_idx IN 1 .. par_columns_count
    LOOP
      v_retval(v_idx) := rtrim(rtrim(REPLACE(TRIM(both '"' FROM ltrim(REPLACE(regexp_substr(REPLACE(par_line
                                                                                     ,'""'
                                                                                     ,chr(134))
                                                                             ,'(^"[^"]+|;"[^"]+)|(^[^;]+|;[^;]+)|;'
                                                                             ,1
                                                                             ,v_idx)
                                                               ,chr(134) || '"'
                                                               ,'"' || chr(134))
                                                       ,';'))
                                            ,chr(134)
                                            ,'"')
                                    ,chr(13))
                              ,chr(10));
    END LOOP;
  
    RETURN v_retval;
  END csv_string_to_array;

  FUNCTION get_row
  (
    par_csv        CLOB
   ,par_row_number NUMBER
  ) RETURN VARCHAR2 IS
    v_start_pos NUMBER;
    v_end_pos   NUMBER;
  BEGIN
    IF par_row_number > 1
    THEN
      v_start_pos := dbms_lob.instr(lob_loc => par_csv, pattern => chr(10), nth => par_row_number - 1) + 1;
    ELSE
      v_start_pos := 1;
    END IF;
    v_end_pos := dbms_lob.instr(lob_loc => par_csv, pattern => chr(10), nth => par_row_number);
    RETURN dbms_lob.substr(lob_loc => par_csv
                          ,amount  => v_end_pos - v_start_pos
                          ,offset  => v_start_pos);
  END get_row;

  PROCEDURE write_row(par_csv IN OUT CLOB) IS
    v_row VARCHAR2(32767);
  BEGIN
    FOR v_idx IN 1 .. gv_line.count
    LOOP
      -- Добавляем разделитель (отсутствует, если это первое значение в файле или новая строка)
      IF v_idx > 1
      THEN
        gv_line(v_idx) := gc_separator || gv_line(v_idx);
      END IF;
      v_row := v_row || gv_line(v_idx);
      gv_line(v_idx) := NULL;
    END LOOP;
    v_row := v_row || gc_new_line;
    dbms_lob.writeappend(lob_loc => par_csv, amount => length(v_row), buffer => v_row);
    gv_columns_fixed := TRUE;
    gv_value_index   := 0;
  END write_row;

  PROCEDURE add_value(par_value VARCHAR2) IS
  BEGIN
    gv_value_index := gv_value_index + 1;
    IF NOT gv_columns_fixed
    THEN
      gv_line.extend(1);
    ELSIF gv_value_index > gv_line.count
    THEN
      ex.raise('Значение не может быть добавлено, превышено количество столбцов таблицы');
    END IF;
    gv_line(gv_value_index) := par_value;
    IF gv_line(gv_value_index) LIKE '%"%'
    THEN
      gv_line(gv_value_index) := REPLACE(gv_line(gv_value_index), '"', '""');
    END IF;
    -- Если есть кавычки или разделитель, берем значение в кавычки
    IF gv_line(gv_value_index) LIKE '%"%'
       OR gv_line(gv_value_index) LIKE '%' || gc_separator || '%'
    THEN
      gv_line(gv_value_index) := '"' || gv_line(gv_value_index) || '"';
    END IF;
  END add_value;
END pkg_csv; 
/
