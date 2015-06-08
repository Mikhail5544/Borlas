CREATE OR REPLACE PACKAGE PKG_DBF IS

  -- Author  : Байтин А.
  -- Created : 22.03.2012 23:04:14
  -- Purpose : Предназначен для работы с DBF

  -- Описание поля
  TYPE t_field_desc IS RECORD(
     v_name VARCHAR2(12) -- Название поля
    ,v_type VARCHAR2(1) -- Тип поля: C - строка, N - число, F - число с плавающей точкой
    -- L - логическое значение (Может быть Y,y,T,t,N,n,F,f (Yes,True,Not,False)
    -- D - дата (DDMMYYYY)
    ,v_length    INTEGER -- Размер поля
    ,v_precision INTEGER -- Точность значения для чисел
    );
  -- Массив с описанием полей
  TYPE t_fields_desc IS TABLE OF t_field_desc;
  -- Значение поля
  TYPE t_field_value IS RECORD(
     v_char    RAW(254)
    ,v_number  NUMBER
    ,v_boolean BOOLEAN
    ,v_date    DATE);
  -- Массив значений для записи (числовой индекс в порядке расположения в файле)
  TYPE t_fields_values IS TABLE OF t_field_value;
  -- Массив значений для записи (строковый индекс - названия полей)
  TYPE t_fields_named_values IS TABLE OF t_field_value INDEX BY VARCHAR2(12);

  type_not_supported EXCEPTION;
  type_not_supported_num CONSTANT NUMBER := -20010;
  PRAGMA EXCEPTION_INIT(type_not_supported, -20010);

  header_not_loaded EXCEPTION;
  header_not_loaded_num CONSTANT NUMBER := -20015;
  PRAGMA EXCEPTION_INIT(header_not_loaded, -20015);
  /*
    Загрузка данных о заголовке
  
    Должна выполняться каждый раз перед загрузкой файла
  */
  PROCEDURE load_header_info(par_dbf BLOB);

  /*
    Возвращает количество строк
  */
  FUNCTION get_row_count RETURN PLS_INTEGER;

  /*
    Возвращает дату последнего обновления файла
  */
  FUNCTION get_last_update_date RETURN DATE;

  /*
    Возвращает описание полей с числовым индексом
  */
  FUNCTION get_fields_desc RETURN t_fields_desc;

  /*
    Возвращает строку
    
    par_row_number - номер записи
  */
  FUNCTION get_row(par_row_number NUMBER) RETURN RAW;

  /*
    Возвращает строки в виде таблицы с числовым индексом
    
    par_row - запись DBF-файла
  */
  FUNCTION get_field_values(par_row RAW) RETURN t_fields_values;

  /*
    Возвращает строки в виде таблицы с названиями полей
    
    par_row - запись DBF-файла
  */
  FUNCTION get_field_named_values(par_row RAW) RETURN t_fields_named_values;

END PKG_DBF;
/
CREATE OR REPLACE PACKAGE BODY PKG_DBF IS

  /*
    Смещения и длины в заголовке DBF
  */
  -- Количество строк
  gc_row_count_offset CONSTANT NUMBER(1) := 5;
  gc_row_count_amount CONSTANT NUMBER(1) := 3;
  -- Длина записи
  gc_row_length_offset CONSTANT NUMBER(2) := 11;
  gc_row_length_amount CONSTANT NUMBER(1) := 2;
  -- Заголовок DBF
  gc_header_length_offset CONSTANT NUMBER(1) := 9;
  gc_header_length_amount CONSTANT NUMBER(1) := 2;
  -- Заголовок без описания полей
  gc_small_header_length CONSTANT NUMBER(2) := 32;
  -- Длина описания одного поля
  gc_field_desc_length CONSTANT NUMBER(2) := 32;
  -- Год последнего изменения
  gc_year_offset CONSTANT NUMBER(1) := 2;
  gc_year_amount CONSTANT NUMBER(1) := 1;
  -- Месяц последнего изменения
  gc_month_offset CONSTANT NUMBER(1) := 3;
  gc_month_amount CONSTANT NUMBER(1) := 1;
  -- День последнего изменения
  gc_day_offset CONSTANT NUMBER(1) := 4;
  gc_day_amount CONSTANT NUMBER(1) := 1;

  /*
    Смещения в описании полей
  */
  -- Название поля
  gc_name_offset CONSTANT NUMBER(1) := 1;
  gc_name_amount CONSTANT NUMBER(2) := 11;
  -- Тип поля
  gc_type_offset CONSTANT NUMBER(2) := 12;
  gc_type_amount CONSTANT NUMBER(1) := 1;
  -- Длина поля
  gc_length_offset CONSTANT NUMBER(2) := 17;
  gc_length_amount CONSTANT NUMBER(1) := 1;
  -- Точность поля
  gc_precision_offset CONSTANT NUMBER(2) := 18;
  gc_precision_amount CONSTANT NUMBER(1) := 1;

  /*
    Сохраненные значения параметров файла
  */
  -- Длина заголовка
  gv_header_length PLS_INTEGER;
  -- Заголовок
  gv_header RAW(2000);
  -- Дата последнего обновления
  gv_last_update_date DATE;
  -- Количество записей
  gv_row_count PLS_INTEGER;
  -- Длина записи
  gv_row_length PLS_INTEGER;
  -- Структура
  gv_fields_desc t_fields_desc;
  -- DBF-файл
  gv_dbf BLOB;

  /*
    Дополнительные общие параметры
  */
  gv_replace_to_comma      NUMBER(1); -- Необходимо заменить точку на запятую в числе
  gv_is_header_info_loaded BOOLEAN := FALSE; -- Загружена ли инфолрмация заголовка

  /*
    Возвращает количество строк
  */
  -- Public
  FUNCTION get_row_count RETURN PLS_INTEGER IS
  BEGIN
    IF NOT gv_is_header_info_loaded
    THEN
      raise_application_error(header_not_loaded_num
                             ,'Заголовок не загружен, используйте load_header_info()');
    END IF;
    RETURN gv_row_count;
  END;
  -- Private
  FUNCTION get_row_count(par_header RAW) RETURN PLS_INTEGER IS
  BEGIN
    RETURN to_number(RAWTOHEX(utl_raw.reverse(utl_raw.substr(par_header
                                                            ,gc_row_count_offset
                                                            ,gc_row_count_amount)))
                    ,'XXXXXX');
  END;

  /*
    Возвращает длину строки
  */
  FUNCTION get_row_length(par_header RAW) RETURN PLS_INTEGER IS
  BEGIN
    RETURN to_number(RAWTOHEX(utl_raw.reverse(utl_raw.substr(par_header
                                                            ,gc_row_length_offset
                                                            ,gc_row_length_amount)))
                    ,'XXXXXX');
  END;

  /*
    Возвращает дату последнего обновления файла
  */
  -- Public
  FUNCTION get_last_update_date RETURN DATE IS
  BEGIN
    IF NOT gv_is_header_info_loaded
    THEN
      raise_application_error(header_not_loaded_num
                             ,'Заголовок не загружен, используйте load_header_info()');
    END IF;
    RETURN gv_last_update_date;
  END;
  -- Private
  FUNCTION get_last_update_date(par_header RAW) RETURN DATE IS
  BEGIN
    RETURN to_date(SUBSTR(to_char(to_number(RAWTOHEX(utl_raw.substr(par_header
                                                                   ,gc_year_offset
                                                                   ,gc_year_amount))
                                           ,'XX'))
                         ,1
                         ,2) || to_char(to_number(RAWTOHEX(utl_raw.substr(par_header
                                                                         ,gc_month_offset
                                                                         ,gc_month_amount))
                                                 ,'XX')
                                       ,'FM09') ||
                   to_char(to_number(RAWTOHEX(utl_raw.substr(par_header, gc_day_offset, gc_day_amount))
                                    ,'XX'))
                  ,'rrmmdd');
  END;

  /*
    Возвращает размер заголовка файла
  */
  FUNCTION get_header_length(par_dbf BLOB) RETURN NUMBER IS
  BEGIN
    RETURN to_number(RAWTOHEX(utl_raw.reverse(dbms_lob.substr(par_dbf
                                                             ,gc_header_length_amount
                                                             ,gc_header_length_offset)))
                    ,'XXXXXX');
  END;

  /*
    Возвращает заголовок
  */
  FUNCTION get_header
  (
    par_dbf           BLOB
   ,par_header_length NUMBER
  ) RETURN RAW IS
  BEGIN
    RETURN dbms_lob.substr(par_dbf, par_header_length, 1);
  END;

  /*
    Возвращает описание полей с числовым индексом
  */
  -- Public
  FUNCTION get_fields_desc RETURN t_fields_desc IS
  BEGIN
    IF NOT gv_is_header_info_loaded
    THEN
      raise_application_error(header_not_loaded_num
                             ,'Заголовок не загружен, используйте load_header_info()');
    END IF;
    RETURN gv_fields_desc;
  END;
  -- Private
  FUNCTION get_fields_desc(par_header RAW) RETURN t_fields_desc IS
    v_fields_count PLS_INTEGER;
    v_fields       t_fields_desc := t_fields_desc();
  BEGIN
    -- Подсчет количества полей
    -- (Длина заголовка-Символ окончания заголовка - Длина заголовка без описания полей) / Длина описания поля
    v_fields_count := (gv_header_length - 1 - gc_small_header_length) / gc_field_desc_length;
    v_fields.extend(v_fields_count);
    -- Заполнение значений
    FOR v_i IN 1 .. v_fields_count
    LOOP
      v_fields(v_i).v_name := TRIM(trailing chr(0) FROM utl_raw.cast_to_varchar2(utl_raw.substr(par_header
                                                                          ,gc_name_offset -- Смещение названия
                                                                           + gc_field_desc_length * v_i
                                                                          ,gc_name_amount -- Кол-во символов в названии
                                                                           )));
      -- Дальше все аналогично
      v_fields(v_i).v_type := utl_raw.cast_to_varchar2(utl_raw.substr(par_header
                                                                     ,gc_type_offset +
                                                                      gc_field_desc_length * v_i
                                                                     ,gc_type_amount));
      v_fields(v_i).v_length := to_number(rawtohex(utl_raw.substr(par_header
                                                                 ,gc_length_offset +
                                                                  gc_field_desc_length * v_i
                                                                 ,gc_length_amount))
                                         ,'XX');
      v_fields(v_i).v_precision := to_number(rawtohex(utl_raw.substr(par_header
                                                                    ,gc_precision_offset +
                                                                     gc_field_desc_length * v_i
                                                                    ,gc_precision_amount))
                                            ,'XX');
    END LOOP;
    RETURN v_fields;
  END;

  /*
    Возвращает строку
    
    par_row_number - номер записи
  */
  FUNCTION get_row(par_row_number NUMBER) RETURN RAW IS
  BEGIN
    RETURN dbms_lob.substr(lob_loc => gv_dbf
                          ,amount  => gv_row_length
                           
                          ,offset => (gv_header_length + 1) -- Длина заголовка + 1 завершающий символ 0x0D
                                     + ((gv_row_length) * (par_row_number - 1)) + 1 -- символ в строке: статус строки
                           );
  END;

  /*
    Возвращает строки в виде таблицы с числовым индексом
    
    par_row - запись DBF-файла
  */
  FUNCTION get_field_values(par_row RAW) RETURN t_fields_values IS
    v_fields   t_fields_values := t_fields_values();
    v_offset   PLS_INTEGER := 1;
    v_bool_str VARCHAR2(1);
    v_numb_str VARCHAR2(20);
    v_date_str VARCHAR2(8);
  BEGIN
    IF NOT gv_is_header_info_loaded
    THEN
      raise_application_error(header_not_loaded_num
                             ,'Заголовок не загружен, используйте load_header_info()');
    END IF;
    v_fields.extend(gv_fields_desc.count);
    -- Цикл по полям
    FOR v_i IN 1 .. gv_fields_desc.count
    LOOP
      CASE
      -- Строка
        WHEN gv_fields_desc(v_i).v_type = 'C' THEN
          v_fields(v_i).v_char := utl_raw.substr(par_row, v_offset, gv_fields_desc(v_i).v_length);
          -- Число
        WHEN gv_fields_desc(v_i).v_type IN ('N', 'F') THEN
          v_numb_str := utl_raw.cast_to_varchar2(utl_raw.substr(par_row
                                                               ,v_offset
                                                               ,gv_fields_desc(v_i).v_length));
          IF gv_replace_to_comma = 1
          THEN
            v_fields(v_i).v_number := to_number(REPLACE(v_numb_str, '.', ','));
          ELSE
            v_fields(v_i).v_number := to_number(v_numb_str);
          END IF;
          -- Логическое значение
        WHEN gv_fields_desc(v_i).v_type = 'L' THEN
          v_bool_str := upper(utl_raw.cast_to_varchar2(utl_raw.substr(par_row
                                                                     ,v_offset
                                                                     ,gv_fields_desc(v_i).v_length)));
          IF v_bool_str IN ('Y', 'T')
          THEN
            v_fields(v_i).v_boolean := TRUE;
          ELSIF v_bool_str IN ('N', 'F')
          THEN
            v_fields(v_i).v_boolean := TRUE;
          ELSE
            v_fields(v_i).v_boolean := NULL;
          END IF;
          -- Дата
        WHEN gv_fields_desc(v_i).v_type = 'D' THEN
          v_date_str := utl_raw.cast_to_varchar2(utl_raw.substr(par_row
                                                               ,v_offset
                                                               ,gv_fields_desc(v_i).v_length));
          v_fields(v_i).v_date := to_date(substr(v_date_str, 1, 4) || substr(v_date_str, 5, 2) ||
                                          substr(v_date_str, 7, 2)
                                         ,'yyyymmdd');
        ELSE
          raise_application_error(type_not_supported_num
                                 , 'Тип "' || gv_fields_desc(v_i).v_type || '", используемый в поле "' || gv_fields_desc(v_i)
                                  .v_name || '", не поддерживается!');
      END CASE;
      v_offset := v_offset + gv_fields_desc(v_i).v_length;
    END LOOP;
    RETURN v_fields;
  END;

  /*
    Возвращает строки в виде таблицы с названиями полей
    
    par_row - запись DBF-файла
  */
  FUNCTION get_field_named_values(par_row RAW) RETURN t_fields_named_values IS
    v_fields_values       t_fields_values;
    v_fields_named_values t_fields_named_values;
  BEGIN
    IF NOT gv_is_header_info_loaded
    THEN
      raise_application_error(header_not_loaded_num
                             ,'Заголовок не загружен, используйте load_header_info()');
    END IF;
    v_fields_values := get_field_values(par_row => par_row);
    FOR v_i IN 1 .. v_fields_values.count
    LOOP
      CASE
        WHEN gv_fields_desc(v_i).v_type = 'C' THEN
          v_fields_named_values(gv_fields_desc(v_i).v_name).v_char := v_fields_values(v_i).v_char;
        WHEN gv_fields_desc(v_i).v_type IN ('N', 'F') THEN
          v_fields_named_values(gv_fields_desc(v_i).v_name).v_number := v_fields_values(v_i).v_number;
        WHEN gv_fields_desc(v_i).v_type = 'L' THEN
          v_fields_named_values(gv_fields_desc(v_i).v_name).v_boolean := v_fields_values(v_i).v_boolean;
        WHEN gv_fields_desc(v_i).v_type = 'D' THEN
          v_fields_named_values(gv_fields_desc(v_i).v_name).v_date := v_fields_values(v_i).v_date;
        ELSE
          raise_application_error(type_not_supported_num
                                 , 'Тип "' || gv_fields_desc(v_i).v_type || '", используемый в поле "' || gv_fields_desc(v_i)
                                  .v_name || '", не поддерживается!');
      END CASE;
    END LOOP;
    RETURN v_fields_named_values;
  END;

  /*
    Готовит всю информацию о файле
  */
  PROCEDURE load_header_info(par_dbf BLOB) IS
  BEGIN
    gv_dbf := par_dbf;
    -- Размер заголовка
    gv_header_length := get_header_length(par_dbf => par_dbf);
    -- Заголовок
    gv_header := get_header(par_dbf => par_dbf, par_header_length => gv_header_length);
    -- Дата последнего изменения
    gv_last_update_date := get_last_update_date(par_header => gv_header);
    -- Количество записей
    gv_row_count := get_row_count(par_header => gv_header);
    -- Размер записей
    gv_row_length := get_row_length(par_header => gv_header);
    -- Структура таблицы
    gv_fields_desc := get_fields_desc(par_header => gv_header);
  
    gv_is_header_info_loaded := TRUE;
  END;
BEGIN
  SELECT CASE substr(VALUE, 1, 1)
           WHEN ',' THEN
            1
           ELSE
            0
         END
    INTO gv_replace_to_comma
    FROM NLS_SESSION_PARAMETERS
   WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
END PKG_DBF;
/
