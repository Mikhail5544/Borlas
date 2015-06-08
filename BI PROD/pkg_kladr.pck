CREATE OR REPLACE PACKAGE pkg_kladr IS
  /*
    Получить название региона по ID
  */
  FUNCTION get_kladr_name_by_id(par_kladr_id t_kladr.t_kladr_id%TYPE) RETURN t_kladr.name%TYPE;
  ----========================================================================----
  -- Загрузка справочника КЛАДР
  ----========================================================================----
  -- Информация о пакете
  FUNCTION get_pkg_info RETURN VARCHAR2;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_kladr_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE kladr_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  ----========================================================================----  
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_altnames_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE altnames_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  ----========================================================================---- 
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_doma_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE doma_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_socrbase_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE socrbase_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_street_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE street_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  ----========================================================================----
  /**************************/
  PROCEDURE send_email(par_report_date DATE);
  PROCEDURE parse_kladr_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  );
  PROCEDURE parse_street_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  );
  PROCEDURE parse_doma_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  );
  PROCEDURE parse_altnames_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  );
  PROCEDURE parse_socrbase_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  );
  PROCEDURE actual_kladr_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  );
  PROCEDURE actual_street_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  );
  PROCEDURE actual_doma_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  );
  PROCEDURE actual_altnames_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  );
  PROCEDURE actual_socrbase_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  );
  PROCEDURE actual_npindx_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  );
  PROCEDURE parse_npindex_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  );
  PROCEDURE actual_addr
  (
    par_date    DATE DEFAULT NULL
   ,p_adress_id NUMBER DEFAULT NULL
  );
  PROCEDURE actual_algorithm
  (
    p_type_adr      NUMBER /*0 - фактический, 1 - новый созданный фактический*/
   ,p_code_kladr    VARCHAR2
   ,p_house_num     VARCHAR2
   ,p_zip           VARCHAR2
   ,p_actual        NUMBER
   ,p_actual_date   DATE
   ,p_province_type VARCHAR2
   ,p_province_name VARCHAR2
   ,p_region_type   VARCHAR2
   ,p_region_name   VARCHAR2
   ,p_district_type VARCHAR2
   ,p_district_name VARCHAR2
   ,p_city_type     VARCHAR2
   ,p_city_name     VARCHAR2
   ,p_street_type   VARCHAR2
   ,p_street_name   VARCHAR2
   ,p_house_type    VARCHAR2
   ,p_adr_id        NUMBER
   ,p_date_actual   DATE
  );
  PROCEDURE compare_text_to_kladr
  (
    par_date_proc  DATE
   ,par_adr_id     NUMBER
   ,par_out_number OUT NUMBER
  );
  PROCEDURE ins_text_field(par_adr_id NUMBER);
  FUNCTION find_correct_index(par_adr_id NUMBER) RETURN VARCHAR2;
  PROCEDURE marking_address_kladr;
  PROCEDURE get_str_for_job;
  PROCEDURE auto_recognition_adr(p_adress_id NUMBER DEFAULT NULL);
  FUNCTION parse_houses_number(par_house_num VARCHAR2) RETURN VARCHAR2;
  FUNCTION create_fact_adr(par_adr_id NUMBER) RETURN NUMBER;

  /*       22.04.2013
           Веселуха Е.В.
           Присвоение признака актуальности
           на основе кодов КЛАДР
           Параметр: ИД адреса, по умолчанию = NULL
           для обновления группы адресов по определенному условию
  */
  PROCEDURE is_actual(par_addr_id NUMBER DEFAULT NULL);
  /*       22.04.2013
           Веселуха Е.В.
           Обновление адреса
           для повторного распознавания и актуализации
           Параметр: ИД адреса, по умолчанию = NULL
                     Дата распознавания
                     Признак - 0 - при наличии в старом значении адреса "корп"
                               1 - любого
  */
  PROCEDURE is_reold
  (
    par_addr_id       NUMBER DEFAULT NULL
   ,par_date_decompos DATE DEFAULT trunc(SYSDATE)
   ,par_update_all    NUMBER DEFAULT 0
  );
  /* 20.08.2013
     Веселуха Е.В.
     Функция посика актуального кода КЛАДР в ALTNAMES
     Параметры: код КЛАДР, уровень КЛАДР
  */
  FUNCTION get_altnames_code
  (
    par_code_kladr VARCHAR2
   ,par_level      NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;
  /***************************/
END pkg_kladr; 
/
CREATE OR REPLACE PACKAGE BODY pkg_kladr IS

  g_file_ext CONSTANT VARCHAR2(10) := '.xls';
  ----========================================================================----
  -- Загрузка справочника КЛАДР
  ----========================================================================----
  PROCEDURE log
  (
    p_message    IN VARCHAR2
   ,p_address_id IN NUMBER DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ins.t_error_recognition
      (t_error_recognition_id, t_message_date, t_message, cn_address_id)
    VALUES
      (sq_t_error_recognition.nextval, SYSDATE, substr(p_message, 1, 4000), p_address_id);
    IF p_address_id IS NOT NULL
    THEN
      DELETE FROM ins.set_str_for_job jb WHERE jb.cn_address_id = p_address_id;
      UPDATE ins.cn_address ca
         SET ca.decompos_permis = 1
            ,ca.note            = 'Ошибка при распознавании'
       WHERE ca.id = p_address_id;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /*
    Получить название региона по ID
  */
  FUNCTION get_kladr_name_by_id(par_kladr_id t_kladr.t_kladr_id%TYPE) RETURN t_kladr.name%TYPE IS
    v_kladr_name t_kladr.name%TYPE;
  BEGIN
    BEGIN
      SELECT kl.name INTO v_kladr_name FROM t_kladr kl WHERE kl.t_kladr_id = par_kladr_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN v_kladr_name;
  END get_kladr_name_by_id;
  ----========================================================================----
  -- Информация о пакете
  FUNCTION get_pkg_info RETURN VARCHAR2 IS
  BEGIN
    RETURN('Загрузка справочника КЛАДР. Версия 1.0');
  END get_pkg_info;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_kladr_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE kladr_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values              pkg_load_file_to_table.t_varay;
    v_blob_data            BLOB;
    v_blob_len             NUMBER;
    v_position             NUMBER;
    c_chunk_len            NUMBER := 1;
    v_line                 VARCHAR2(32767) := NULL;
    v_line_num             NUMBER := 0;
    v_char                 CHAR(1);
    v_raw_chunk            RAW(10000);
    v_kladr_kladr_file_row kladr_kladr_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT before_load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(pkg_load_file_to_table.hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := pkg_load_file_to_table.str2array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_kladr_kladr_file_row := NULL;
            SELECT sq_kladr_kladr_file_row.nextval
              INTO v_kladr_kladr_file_row.kladr_kladr_file_row_id
              FROM dual;
            v_kladr_kladr_file_row.load_file_id := par_load_file_id;
            v_kladr_kladr_file_row.status       := 0;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_kladr_kladr_file_row.row_name := va_values(i);
                WHEN i = 2 THEN
                  v_kladr_kladr_file_row.row_socr := va_values(i);
                WHEN i = 3 THEN
                  v_kladr_kladr_file_row.row_code := va_values(i);
                WHEN i = 4 THEN
                  v_kladr_kladr_file_row.row_index := va_values(i);
                WHEN i = 5 THEN
                  v_kladr_kladr_file_row.row_gninmb := va_values(i);
                WHEN i = 6 THEN
                  v_kladr_kladr_file_row.row_uno := va_values(i);
                WHEN i = 7 THEN
                  v_kladr_kladr_file_row.row_ocatd := va_values(i);
                WHEN i = 8 THEN
                  v_kladr_kladr_file_row.row_status := va_values(i);
                ELSE
                  NULL;
                  /* Образцы загрузки дат и чисел
                  WHEN i = 4 THEN
                    v_as_bordero_load.birth_date := 
                      TO_DATE( va_values( i ), 'DD.MM.YYYY' );
                  WHEN i = 16 THEN
                    v_as_bordero_load.ins_sum := 
                      TO_NUMBER( TRANSLATE( va_values( i ), ',.', '..' ), 
                        '9999999999.99');*/
              END CASE;
            END LOOP;
            -- Из названия убрать кавычки в начале и в конце строки
            -- и повторные кавычки в середине строки
            /*          IF SUBSTR( v_kladr_kladr_file_row.name, 1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 2 );
            END IF;
            IF SUBSTR( v_kladr_kladr_file_row.name, -1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 1, 
                  LENGTH( v_kladr_kladr_file_row.name ) - 1 );
            END IF;
            v_kladr_kladr_file_row.name := 
              REPLACE( v_kladr_kladr_file_row.name, '""', '"' ); */
            INSERT INTO kladr_kladr_file_row
              (kladr_kladr_file_row_id
              ,load_file_id
              ,row_name
              ,row_socr
              ,row_code
              ,row_index
              ,row_gninmb
              ,row_uno
              ,row_ocatd
              ,row_status
              ,status)
            VALUES
              (v_kladr_kladr_file_row.kladr_kladr_file_row_id
              ,v_kladr_kladr_file_row.load_file_id
              ,v_kladr_kladr_file_row.row_name
              ,v_kladr_kladr_file_row.row_socr
              ,v_kladr_kladr_file_row.row_code
              ,v_kladr_kladr_file_row.row_index
              ,v_kladr_kladr_file_row.row_gninmb
              ,v_kladr_kladr_file_row.row_uno
              ,v_kladr_kladr_file_row.row_ocatd
              ,v_kladr_kladr_file_row.row_status
              ,v_kladr_kladr_file_row.status);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,'Ошибка при выполнении KLADR_Load_BLOB_To_Table ' || SQLERRM);
  END kladr_load_blob_to_table;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_altnames_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE altnames_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values                 pkg_load_file_to_table.t_varay;
    v_blob_data               BLOB;
    v_blob_len                NUMBER;
    v_position                NUMBER;
    c_chunk_len               NUMBER := 1;
    v_line                    VARCHAR2(32767) := NULL;
    v_line_num                NUMBER := 0;
    v_char                    CHAR(1);
    v_raw_chunk               RAW(10000);
    v_kladr_altnames_file_row kladr_altnames_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT before_load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(pkg_load_file_to_table.hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := pkg_load_file_to_table.str2array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_kladr_altnames_file_row := NULL;
            SELECT sq_kladr_altnames_file_row.nextval
              INTO v_kladr_altnames_file_row.kladr_altnames_file_row_id
              FROM dual;
            v_kladr_altnames_file_row.load_file_id := par_load_file_id;
            v_kladr_altnames_file_row.status       := 0;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_kladr_altnames_file_row.row_oldcode := va_values(i);
                WHEN i = 2 THEN
                  v_kladr_altnames_file_row.row_newcode := va_values(i);
                WHEN i = 3 THEN
                  v_kladr_altnames_file_row.row_level := to_number(translate(va_values(i), ',.', '..')
                                                                  ,'9999999999');
                ELSE
                  NULL;
                  /* Образцы загрузки дат и чисел
                  WHEN i = 4 THEN
                    v_as_bordero_load.birth_date := 
                      TO_DATE( va_values( i ), 'DD.MM.YYYY' );
                  WHEN i = 16 THEN
                    v_as_bordero_load.ins_sum := 
                      TO_NUMBER( TRANSLATE( va_values( i ), ',.', '..' ), 
                        '9999999999.99');*/
              END CASE;
            END LOOP;
            -- Из названия убрать кавычки в начале и в конце строки
            -- и повторные кавычки в середине строки
            /*          IF SUBSTR( v_kladr_kladr_file_row.name, 1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 2 );
            END IF;
            IF SUBSTR( v_kladr_kladr_file_row.name, -1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 1, 
                  LENGTH( v_kladr_kladr_file_row.name ) - 1 );
            END IF;
            v_kladr_kladr_file_row.name := 
              REPLACE( v_kladr_kladr_file_row.name, '""', '"' ); */
            INSERT INTO kladr_altnames_file_row
              (kladr_altnames_file_row_id, load_file_id, row_oldcode, row_newcode, row_level, status)
            VALUES
              (v_kladr_altnames_file_row.kladr_altnames_file_row_id
              ,v_kladr_altnames_file_row.load_file_id
              ,v_kladr_altnames_file_row.row_oldcode
              ,v_kladr_altnames_file_row.row_newcode
              ,v_kladr_altnames_file_row.row_level
              ,v_kladr_altnames_file_row.status);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,'Ошибка при выполнении ALTNAMES_Load_BLOB_To_Table ' || SQLERRM);
  END altnames_load_blob_to_table;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_doma_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE doma_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values             pkg_load_file_to_table.t_varay;
    v_blob_data           BLOB;
    v_blob_len            NUMBER;
    v_position            NUMBER;
    c_chunk_len           NUMBER := 1;
    v_line                VARCHAR2(32767) := NULL;
    v_line_num            NUMBER := 0;
    v_char                CHAR(1);
    v_raw_chunk           RAW(10000);
    v_kladr_doma_file_row kladr_doma_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT before_load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(pkg_load_file_to_table.hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := pkg_load_file_to_table.str2array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_kladr_doma_file_row := NULL;
            SELECT sq_kladr_doma_file_row.nextval
              INTO v_kladr_doma_file_row.kladr_doma_file_row_id
              FROM dual;
            v_kladr_doma_file_row.load_file_id := par_load_file_id;
            v_kladr_doma_file_row.status       := 0;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_kladr_doma_file_row.row_name := va_values(i);
                WHEN i = 2 THEN
                  v_kladr_doma_file_row.row_korp := va_values(i);
                WHEN i = 3 THEN
                  v_kladr_doma_file_row.row_socr := va_values(i);
                WHEN i = 4 THEN
                  v_kladr_doma_file_row.row_code := va_values(i);
                WHEN i = 5 THEN
                  v_kladr_doma_file_row.row_index := va_values(i);
                WHEN i = 6 THEN
                  v_kladr_doma_file_row.row_gninmb := va_values(i);
                WHEN i = 7 THEN
                  v_kladr_doma_file_row.row_uno := va_values(i);
                WHEN i = 8 THEN
                  v_kladr_doma_file_row.row_ocatd := va_values(i);
                ELSE
                  NULL;
                  /* Образцы загрузки дат и чисел
                  WHEN i = 4 THEN
                    v_as_bordero_load.birth_date := 
                      TO_DATE( va_values( i ), 'DD.MM.YYYY' );
                  WHEN i = 16 THEN
                    v_as_bordero_load.ins_sum := 
                      TO_NUMBER( TRANSLATE( va_values( i ), ',.', '..' ), 
                        '9999999999.99');*/
              END CASE;
            END LOOP;
            -- Из названия убрать кавычки в начале и в конце строки
            -- и повторные кавычки в середине строки
            /*          IF SUBSTR( v_kladr_kladr_file_row.name, 1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 2 );
            END IF;
            IF SUBSTR( v_kladr_kladr_file_row.name, -1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 1, 
                  LENGTH( v_kladr_kladr_file_row.name ) - 1 );
            END IF;
            v_kladr_kladr_file_row.name := 
              REPLACE( v_kladr_kladr_file_row.name, '""', '"' ); */
            INSERT INTO kladr_doma_file_row
              (kladr_doma_file_row_id
              ,load_file_id
              ,row_name
              ,row_korp
              ,row_socr
              ,row_code
              ,row_index
              ,row_gninmb
              ,row_uno
              ,row_ocatd
              ,status)
            VALUES
              (v_kladr_doma_file_row.kladr_doma_file_row_id
              ,v_kladr_doma_file_row.load_file_id
              ,v_kladr_doma_file_row.row_name
              ,v_kladr_doma_file_row.row_korp
              ,v_kladr_doma_file_row.row_socr
              ,v_kladr_doma_file_row.row_code
              ,v_kladr_doma_file_row.row_index
              ,v_kladr_doma_file_row.row_gninmb
              ,v_kladr_doma_file_row.row_uno
              ,v_kladr_doma_file_row.row_ocatd
              ,v_kladr_doma_file_row.status);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,'Ошибка при выполнении DOMA_Load_BLOB_To_Table ' || SQLERRM);
  END doma_load_blob_to_table;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_socrbase_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE socrbase_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values                 pkg_load_file_to_table.t_varay;
    v_blob_data               BLOB;
    v_blob_len                NUMBER;
    v_position                NUMBER;
    c_chunk_len               NUMBER := 1;
    v_line                    VARCHAR2(32767) := NULL;
    v_line_num                NUMBER := 0;
    v_char                    CHAR(1);
    v_raw_chunk               RAW(10000);
    v_kladr_socrbase_file_row kladr_socrbase_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT before_load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(pkg_load_file_to_table.hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := pkg_load_file_to_table.str2array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_kladr_socrbase_file_row := NULL;
            SELECT sq_kladr_socrbase_file_row.nextval
              INTO v_kladr_socrbase_file_row.kladr_socrbase_file_row_id
              FROM dual;
            v_kladr_socrbase_file_row.load_file_id := par_load_file_id;
            v_kladr_socrbase_file_row.status       := 0;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_kladr_socrbase_file_row.row_level := to_number(translate(va_values(i), ',.', '..')
                                                                  ,'9999999999');
                WHEN i = 2 THEN
                  v_kladr_socrbase_file_row.row_scname := va_values(i);
                WHEN i = 3 THEN
                  v_kladr_socrbase_file_row.row_socrname := va_values(i);
                WHEN i = 4 THEN
                  v_kladr_socrbase_file_row.row_kod_t_st := to_number(translate(va_values(i)
                                                                               ,',.'
                                                                               ,'..')
                                                                     ,'9999999999');
                ELSE
                  NULL;
                  /* Образцы загрузки дат и чисел
                  WHEN i = 4 THEN
                    v_as_bordero_load.birth_date := 
                      TO_DATE( va_values( i ), 'DD.MM.YYYY' );
                  WHEN i = 16 THEN
                    v_as_bordero_load.ins_sum := 
                      TO_NUMBER( TRANSLATE( va_values( i ), ',.', '..' ), 
                        '9999999999.99');*/
              END CASE;
            END LOOP;
            -- Из названия убрать кавычки в начале и в конце строки
            -- и повторные кавычки в середине строки
            /*          IF SUBSTR( v_kladr_kladr_file_row.name, 1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 2 );
            END IF;
            IF SUBSTR( v_kladr_kladr_file_row.name, -1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 1, 
                  LENGTH( v_kladr_kladr_file_row.name ) - 1 );
            END IF;
            v_kladr_kladr_file_row.name := 
              REPLACE( v_kladr_kladr_file_row.name, '""', '"' ); */
            INSERT INTO kladr_socrbase_file_row
              (kladr_socrbase_file_row_id
              ,load_file_id
              ,row_level
              ,row_scname
              ,row_socrname
              ,row_kod_t_st
              ,status)
            VALUES
              (v_kladr_socrbase_file_row.kladr_socrbase_file_row_id
              ,v_kladr_socrbase_file_row.load_file_id
              ,v_kladr_socrbase_file_row.row_level
              ,v_kladr_socrbase_file_row.row_scname
              ,v_kladr_socrbase_file_row.row_socrname
              ,v_kladr_socrbase_file_row.row_kod_t_st
              ,v_kladr_socrbase_file_row.status);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,'Ошибка при выполнении SOCRBASE_Load_BLOB_To_Table ' || SQLERRM);
  END socrbase_load_blob_to_table;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк КЛАДР (kladr_street_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE street_load_blob_to_table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values               pkg_load_file_to_table.t_varay;
    v_blob_data             BLOB;
    v_blob_len              NUMBER;
    v_position              NUMBER;
    c_chunk_len             NUMBER := 1;
    v_line                  VARCHAR2(32767) := NULL;
    v_line_num              NUMBER := 0;
    v_char                  CHAR(1);
    v_raw_chunk             RAW(10000);
    v_kladr_street_file_row kladr_street_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT before_load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(pkg_load_file_to_table.hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := pkg_load_file_to_table.str2array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_kladr_street_file_row := NULL;
            SELECT sq_kladr_street_file_row.nextval
              INTO v_kladr_street_file_row.kladr_street_file_row_id
              FROM dual;
            v_kladr_street_file_row.load_file_id := par_load_file_id;
            v_kladr_street_file_row.status       := 0;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_kladr_street_file_row.row_name := va_values(i);
                WHEN i = 2 THEN
                  v_kladr_street_file_row.row_socr := va_values(i);
                WHEN i = 3 THEN
                  v_kladr_street_file_row.row_code := va_values(i);
                WHEN i = 4 THEN
                  v_kladr_street_file_row.row_index := va_values(i);
                WHEN i = 5 THEN
                  v_kladr_street_file_row.row_gninmb := va_values(i);
                WHEN i = 6 THEN
                  v_kladr_street_file_row.row_uno := va_values(i);
                WHEN i = 7 THEN
                  v_kladr_street_file_row.row_ocatd := va_values(i);
                ELSE
                  NULL;
                  /* Образцы загрузки дат и чисел
                  WHEN i = 4 THEN
                    v_as_bordero_load.birth_date := 
                      TO_DATE( va_values( i ), 'DD.MM.YYYY' );
                  WHEN i = 16 THEN
                    v_as_bordero_load.ins_sum := 
                      TO_NUMBER( TRANSLATE( va_values( i ), ',.', '..' ), 
                        '9999999999.99');*/
              END CASE;
            END LOOP;
            -- Из названия убрать кавычки в начале и в конце строки
            -- и повторные кавычки в середине строки
            /*          IF SUBSTR( v_kladr_kladr_file_row.name, 1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 2 );
            END IF;
            IF SUBSTR( v_kladr_kladr_file_row.name, -1, 1 ) = '"' THEN
              v_kladr_kladr_file_row.name := 
                SUBSTR( v_kladr_kladr_file_row.name, 1, 
                  LENGTH( v_kladr_kladr_file_row.name ) - 1 );
            END IF;
            v_kladr_kladr_file_row.name := 
              REPLACE( v_kladr_kladr_file_row.name, '""', '"' ); */
            INSERT INTO kladr_street_file_row
              (kladr_street_file_row_id
              ,load_file_id
              ,row_name
              ,row_socr
              ,row_code
              ,row_index
              ,row_gninmb
              ,row_uno
              ,row_ocatd
              ,status)
            VALUES
              (v_kladr_street_file_row.kladr_street_file_row_id
              ,v_kladr_street_file_row.load_file_id
              ,v_kladr_street_file_row.row_name
              ,v_kladr_street_file_row.row_socr
              ,v_kladr_street_file_row.row_code
              ,v_kladr_street_file_row.row_index
              ,v_kladr_street_file_row.row_gninmb
              ,v_kladr_street_file_row.row_uno
              ,v_kladr_street_file_row.row_ocatd
              ,v_kladr_street_file_row.status);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,'Ошибка при выполнении STREET_Load_BLOB_To_Table ' || SQLERRM);
  END street_load_blob_to_table;
  ----========================================================================----
  /*************************/
  PROCEDURE create_report
  (
    p_rep_date  DATE
   ,p_type_file VARCHAR2
   ,p_return    OUT NUMBER
  ) IS
  BEGIN
    IF p_type_file = 'UPDATE_KLADR'
    THEN
      INSERT INTO ins.tmp_kladr_chng
        SELECT ujk.change_date
              ,(SELECT su.sys_user_name FROM ins.sys_user su WHERE su.sys_user_id = ujk.user_id)
              ,ujk.table_name
              ,ujk.code
              ,ujk.old_value
              ,ujk.new_value
              ,decode(ujk.change_type
                     ,1
                     ,'Запись добавлена'
                     ,2
                     ,'Запись отредактирована'
                     ,3
                     ,'Запись удалена'
                     ,'Не определено')
              ,''
              ,'UPDATE_KLADR'
          FROM ins.update_journal_kladr ujk
         WHERE trunc(ujk.change_date) = trunc(p_rep_date - 1);
      IF SQL%ROWCOUNT > 0
      THEN
        p_return := 1;
      ELSE
        p_return := 0;
      END IF;
    ELSIF p_type_file = 'ACTUAL_ADR'
    THEN
      INSERT INTO ins.tmp_kladr_chng
        SELECT aja.change_date
              ,(SELECT su.sys_user_name FROM ins.sys_user su WHERE su.sys_user_id = aja.user_id)
              ,c.obj_name_orig
              ,''
              ,aja.old_value
              ,aja.new_value
              ,decode(aja.change_type
                     ,1
                     ,'Запись добавлена'
                     ,2
                     ,'Запись отредактирована'
                     ,3
                     ,'Запись удалена'
                     ,'Не определено')
              ,aja.note
              ,'ACTUAL_ADR'
          FROM ins.actual_journal_adr aja
              ,ins.cn_contact_address cca
              ,ins.contact            c
         WHERE trunc(aja.change_date) = trunc(p_rep_date - 1)
           AND aja.id_adress = cca.adress_id(+)
           AND cca.contact_id = c.contact_id(+);
      IF SQL%ROWCOUNT > 0
      THEN
        p_return := 1;
      ELSE
        p_return := 0;
      END IF;
    ELSE
      p_return := 0;
    END IF;
  END create_report;
  /******************************/
  PROCEDURE prepare_data_kladr(par_file IN OUT NOCOPY BLOB) IS
    v_row     VARCHAR2(2500);
    v_row_raw RAW(2500);
  BEGIN
    dbms_lob.trim(lob_loc => par_file, newlen => 0);
  
    v_row_raw := utl_raw.cast_to_raw('Дата изменения' || chr(9) || 'Пользователь' || chr(9) ||
                                     'Таблица' || chr(9) || 'Код' || chr(9) || 'Было' || chr(9) ||
                                     'Стало' || chr(9) || 'Тип изменений' || chr(9) || utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
    FOR cur IN (SELECT ch.change_date
                      ,ch.user_name
                      ,ch.cont_or_tbl_name
                      ,ch.code
                      ,ch.old_value
                      ,ch.new_value
                      ,ch.change_type
                  FROM ins.tmp_kladr_chng ch
                 WHERE ch.type_file = 'UPDATE_KLADR')
    LOOP
      v_row     := cur.change_date || chr(9) || cur.user_name || chr(9) || cur.cont_or_tbl_name ||
                   chr(9) || cur.code || chr(9) || cur.old_value || chr(9) || cur.new_value || chr(9) ||
                   cur.change_type || utl_tcp.crlf;
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END LOOP;
  
  END prepare_data_kladr;
  /******************************/
  PROCEDURE prepare_data_adr(par_file IN OUT NOCOPY BLOB) IS
    v_row     VARCHAR2(2500);
    v_row_raw RAW(2500);
  BEGIN
    dbms_lob.trim(lob_loc => par_file, newlen => 0);
  
    v_row_raw := utl_raw.cast_to_raw('Дата изменения' || chr(9) || 'Пользователь' || chr(9) ||
                                     'Контакт' || chr(9) || 'Было' || chr(9) || 'Стало' || chr(9) ||
                                     'Тип изменений' || chr(9) || 'Комментарий' || chr(9) ||
                                     utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
    FOR cur IN (SELECT ch.change_date
                      ,ch.user_name
                      ,ch.cont_or_tbl_name
                      ,ch.old_value
                      ,ch.new_value
                      ,ch.change_type
                      ,ch.note
                  FROM ins.tmp_kladr_chng ch
                 WHERE ch.type_file = 'ACTUAL_ADR')
    LOOP
      v_row     := cur.change_date || chr(9) || cur.user_name || chr(9) || cur.cont_or_tbl_name ||
                   chr(9) || cur.old_value || chr(9) || cur.new_value || chr(9) || cur.change_type ||
                   chr(9) || cur.note || utl_tcp.crlf;
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END LOOP;
  
  END prepare_data_adr;
  /***************************************/
  PROCEDURE send_email(par_report_date DATE) IS
    v_files       pkg_email.t_files := pkg_email.t_files();
    par_ret_kladr NUMBER;
    par_ret_adr   NUMBER;
  BEGIN
    DELETE FROM ins.tmp_kladr_chng;
    create_report(trunc(par_report_date), 'UPDATE_KLADR', par_ret_kladr);
    create_report(trunc(par_report_date), 'ACTUAL_ADR', par_ret_adr);
    IF par_ret_kladr = 1
       OR par_ret_adr = 1
    THEN
      v_files.extend(1);
      v_files(1).v_file_type := 'application/excel';
      dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
    END IF;
    IF par_ret_kladr = 1
    THEN
      prepare_data_kladr(par_file => v_files(1).v_file);
      IF dbms_lob.getlength(v_files(1).v_file) > 2000000
      THEN
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('ekaterina.veselukha@renlife.com'
                                                                                 ,'yana.tihonova@renlife.com'
                                                                                 ,'tatyana.gorshkova@renlife.com')
                                           ,par_subject => 'Изменения в журнале обновления КЛАДР'
                                           ,par_text    => 'Добрый день, ответственные сотрудники!' ||
                                                           utl_tcp.crlf ||
                                                           'В "Журнале обновления КЛАДР" обновилось большое количество записей, Вы можете увидеть их выгрузив отчет "ОС. Отчет - Журнал обновления КЛАДР" через DISCOVERER либо увидеть изменения отфильтровав "Журнал обновления справочника КЛАДР", доступный через интерфейс Борлас через пункт меню "Справочники". Данное письмо без вложения, т.к. существуют ограничения на размер письма.');
      ELSE
        v_files(1).v_file_name := 'Журнал обновления КЛАДР' || g_file_ext;
        pkg_email.send_mail_with_attachment(par_to         => pkg_email.t_recipients('ekaterina.veselukha@renlife.com'
                                                                                    ,'yana.tihonova@renlife.com'
                                                                                    ,'tatyana.gorshkova@renlife.com')
                                           ,par_subject    => 'Изменения в журнале обновления КЛАДР'
                                           ,par_text       => 'Добрый день, ответственные сотрудники!' ||
                                                              utl_tcp.crlf ||
                                                              'Во вложении отчет, который отражает следующее: если на начало дня D в "Журнале обновления Справочника КЛАДР" существуют записи со значением в поле "change_date", равным D-1, то ответственным пользователям должно быть направлено электронное письмо с указанием количества Изменений (добавления, изменения и удаления).'
                                           ,par_attachment => v_files);
      END IF;
    END IF;
    IF par_ret_adr = 1
    THEN
      prepare_data_adr(par_file => v_files(1).v_file);
      IF dbms_lob.getlength(v_files(1).v_file) > 2000000
      THEN
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('ekaterina.veselukha@renlife.com'
                                                                                 ,'yana.tihonova@renlife.com'
                                                                                 ,'tatyana.gorshkova@renlife.com')
                                           ,par_subject => 'Изменения в журнале актуализации адресов'
                                           ,par_text    => 'Добрый день, ответственные сотрудники!' ||
                                                           utl_tcp.crlf ||
                                                           'В "Журнале актуализации адресов" обновилось большое количество записей, Вы можете увидеть их выгрузив отчет "ОС. Отчет - Журнал актуализации адресов" через DISCOVERER либо увидеть изменения отфильтровав "Журнал актуализации адресов", доступный через интерфейс Борлас через пункт меню "Справочники". Данное письмо без вложения, т.к. существуют ограничения на размер письма.');
      ELSE
        v_files(1).v_file_name := 'Журнал актуализации адресов' || g_file_ext;
        pkg_email.send_mail_with_attachment(par_to         => pkg_email.t_recipients('ekaterina.veselukha@renlife.com'
                                                                                    ,'yana.tihonova@renlife.com'
                                                                                    ,'tatyana.gorshkova@renlife.com')
                                           ,par_subject    => 'Изменения в журнале актуализации адресов'
                                           ,par_text       => 'Добрый день, ответственные сотрудники!' ||
                                                              utl_tcp.crlf ||
                                                              'Во вложении отчет, который отражает следующее: если на начало дня D в "Журнале актуализации адресов" существуют записи со значением в поле "change_date", равным D-1, то ответственным пользователям должно быть направлено электронное письмо с указанием количества Контактов, в Адресах которых были произведены изменения, и количества ошибок возникших при автоматическом редактировании полей.'
                                           ,par_attachment => v_files);
      END IF;
    END IF;
    IF par_ret_kladr = 0
       AND par_ret_adr = 0
    THEN
      NULL;
    ELSE
      dbms_lob.freetemporary(v_files(1).v_file);
    END IF;
  END send_email;
  /**************************************/
  PROCEDURE parse_street_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  ) IS
    v_dbf    BLOB;
    v_fields pkg_dbf.t_fields_values;
    v_row    RAW(2000);
  
    TYPE t_buff IS TABLE OF t_street_orig%ROWTYPE;
    v_buff       t_buff := t_buff();
    v_i2         PLS_INTEGER := 1;
    sq_load_date VARCHAR2(10) := to_char(SYSDATE, 'DD.MM.YYYY');
  BEGIN
    dbms_application_info.set_client_info('PARSE_STREET_DBF');
    SELECT file_blob
      INTO v_dbf
      FROM temp_load_blob
     WHERE session_id = par_id
       AND file_name = par_file_name;
  
    pkg_dbf.load_header_info(par_dbf => v_dbf);
    IF pkg_dbf.get_row_count >= 1000
    THEN
      v_buff.extend(1000);
    ELSE
      v_buff.extend(pkg_dbf.get_row_count);
    END IF;
  
    FOR v_i IN 1 .. pkg_dbf.get_row_count
    LOOP
      v_row := pkg_dbf.get_row(par_row_number => v_i);
    
      v_fields := pkg_dbf.get_field_values(par_row => v_row);
      v_buff(v_i2).name := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(1).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).socr := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(2).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).code := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(3).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).pindex := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(4).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).gninmb := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(5).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).uno := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(6).v_char)
                                      ,'CL8MSWIN1251'
                                      ,'RU8PC866'));
      v_buff(v_i2).ocatd := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(7).v_char)
                                        ,'CL8MSWIN1251'
                                        ,'RU8PC866'));
      v_buff(v_i2).load_id := par_load_id;
      v_buff(v_i2).load_date := sq_load_date;
      v_buff(v_i2).load_name := par_file_name;
      v_buff(v_i2).is_actual := 0;
    
      IF v_i2 = 1000
      THEN
        FORALL i IN v_buff.first .. v_buff.last
          INSERT /*+ APPEND*/
          INTO t_street_orig
          VALUES v_buff
            (i);
        v_buff.delete;
        IF pkg_dbf.get_row_count - v_i < 1000
        THEN
          v_buff.extend(pkg_dbf.get_row_count - v_i);
        ELSE
          v_buff.extend(1000);
        END IF;
        v_i2 := 0;
      END IF;
      v_i2 := v_i2 + 1;
    END LOOP;
    FORALL v_i IN v_buff.first .. v_buff.last
      INSERT /*+ APPEND*/
      INTO t_street_orig
      VALUES v_buff
        (v_i);
  
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_STREET_ORIG', cascade => TRUE);
  
  END parse_street_dbf;
  /*******************************/
  PROCEDURE parse_kladr_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  ) IS
    v_dbf    BLOB;
    v_fields pkg_dbf.t_fields_values;
    v_row    RAW(2000);
  
    TYPE t_buff IS TABLE OF t_kladr_orig%ROWTYPE;
    v_buff       t_buff := t_buff();
    v_i2         PLS_INTEGER := 1;
    sq_load_date VARCHAR2(10) := to_char(SYSDATE, 'DD.MM.YYYY');
  BEGIN
    dbms_application_info.set_client_info('PARSE_KLADR_DBF');
    SELECT file_blob
      INTO v_dbf
      FROM temp_load_blob
     WHERE session_id = par_id
       AND file_name = par_file_name;
  
    pkg_dbf.load_header_info(par_dbf => v_dbf);
    IF pkg_dbf.get_row_count >= 1000
    THEN
      v_buff.extend(1000);
    ELSE
      v_buff.extend(pkg_dbf.get_row_count);
    END IF;
    /*dbms_output.put_line('pkg_dbf.get_row_count = '||pkg_dbf.get_row_count);*/
  
    FOR v_i IN 1 .. pkg_dbf.get_row_count
    LOOP
      v_row := pkg_dbf.get_row(par_row_number => v_i);
    
      v_fields := pkg_dbf.get_field_values(par_row => v_row);
      v_buff(v_i2).name := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(1).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).socr := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(2).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).code := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(3).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).pindex := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(4).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).gninmb := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(5).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).uno := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(6).v_char)
                                      ,'CL8MSWIN1251'
                                      ,'RU8PC866'));
      v_buff(v_i2).ocatd := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(7).v_char)
                                        ,'CL8MSWIN1251'
                                        ,'RU8PC866'));
      v_buff(v_i2).status := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(8).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).load_id := par_load_id;
      v_buff(v_i2).load_date := sq_load_date;
      v_buff(v_i2).load_name := par_file_name;
      v_buff(v_i2).is_actual := 0;
    
      IF v_i2 = 1000
      THEN
        FORALL i IN v_buff.first .. v_buff.last
          INSERT /*+ APPEND*/
          INTO t_kladr_orig
          VALUES v_buff
            (i);
        v_buff.delete;
        IF pkg_dbf.get_row_count - v_i < 1000
        THEN
          v_buff.extend(pkg_dbf.get_row_count - v_i);
        ELSE
          v_buff.extend(1000);
        END IF;
        v_i2 := 0;
      END IF;
      v_i2 := v_i2 + 1;
    END LOOP;
    FORALL v_i IN v_buff.first .. v_buff.last
      INSERT /*+ APPEND*/
      INTO t_kladr_orig
      VALUES v_buff
        (v_i);
  
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_KLADR_ORIG', cascade => TRUE);
  
  END parse_kladr_dbf;
  /************************************/
  PROCEDURE parse_doma_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  ) IS
    v_dbf    BLOB;
    v_fields pkg_dbf.t_fields_values;
    v_row    RAW(2000);
  
    TYPE t_buff IS TABLE OF t_doma_orig%ROWTYPE;
    v_buff       t_buff := t_buff();
    v_i2         PLS_INTEGER := 1;
    sq_load_date VARCHAR2(10) := to_char(SYSDATE, 'DD.MM.YYYY');
  BEGIN
    dbms_application_info.set_client_info('PARSE_DOMA_DBF');
    SELECT file_blob
      INTO v_dbf
      FROM temp_load_blob
     WHERE session_id = par_id
       AND file_name = par_file_name;
  
    pkg_dbf.load_header_info(par_dbf => v_dbf);
    IF pkg_dbf.get_row_count >= 1000
    THEN
      v_buff.extend(1000);
    ELSE
      v_buff.extend(pkg_dbf.get_row_count);
    END IF;
  
    FOR v_i IN 1 .. pkg_dbf.get_row_count
    LOOP
      v_row := pkg_dbf.get_row(par_row_number => v_i);
    
      v_fields := pkg_dbf.get_field_values(par_row => v_row);
      v_buff(v_i2).name := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(1).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).korp := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(2).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).socr := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(3).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).code := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(4).v_char)
                                       ,'CL8MSWIN1251'
                                       ,'RU8PC866'));
      v_buff(v_i2).pindex := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(5).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).gninmb := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(6).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).uno := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(7).v_char)
                                      ,'CL8MSWIN1251'
                                      ,'RU8PC866'));
      v_buff(v_i2).ocatd := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(8).v_char)
                                        ,'CL8MSWIN1251'
                                        ,'RU8PC866'));
      v_buff(v_i2).load_id := par_load_id;
      v_buff(v_i2).load_date := sq_load_date;
      v_buff(v_i2).load_name := par_file_name;
      v_buff(v_i2).is_actual := 0;
    
      IF v_i2 = 1000
      THEN
        FORALL i IN v_buff.first .. v_buff.last
          INSERT /*+ APPEND*/
          INTO t_doma_orig
          VALUES v_buff
            (i);
        v_buff.delete;
        IF pkg_dbf.get_row_count - v_i < 1000
        THEN
          v_buff.extend(pkg_dbf.get_row_count - v_i);
        ELSE
          v_buff.extend(1000);
        END IF;
        v_i2 := 0;
      END IF;
      v_i2 := v_i2 + 1;
    END LOOP;
    FORALL v_i IN v_buff.first .. v_buff.last
      INSERT /*+ APPEND*/
      INTO t_doma_orig
      VALUES v_buff
        (v_i);
  
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_DOMA_ORIG', cascade => TRUE);
  
    /**/
    /*UPDATE T_DOMA_ORIG org
    SET org.parse_name = pkg_kladr.PARSE_HOUSES_NUMBER(org.name)
    WHERE org.load_id = PAR_LOAD_ID;*/
    /**/
  
  END parse_doma_dbf;
  /***************************/
  PROCEDURE parse_altnames_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  ) IS
    v_dbf    BLOB;
    v_fields pkg_dbf.t_fields_values;
    v_row    RAW(2000);
  
    TYPE t_buff IS TABLE OF t_altnames_orig%ROWTYPE;
    v_buff       t_buff := t_buff();
    v_i2         PLS_INTEGER := 1;
    sq_load_date VARCHAR2(10) := to_char(SYSDATE, 'DD.MM.YYYY');
  BEGIN
    dbms_application_info.set_client_info('PARSE_ALTNAMES_DBF');
    SELECT file_blob
      INTO v_dbf
      FROM temp_load_blob
     WHERE session_id = par_id
       AND file_name = par_file_name;
  
    pkg_dbf.load_header_info(par_dbf => v_dbf);
    IF pkg_dbf.get_row_count >= 1000
    THEN
      v_buff.extend(1000);
    ELSE
      v_buff.extend(pkg_dbf.get_row_count);
    END IF;
  
    FOR v_i IN 1 .. pkg_dbf.get_row_count
    LOOP
      v_row := pkg_dbf.get_row(par_row_number => v_i);
    
      v_fields := pkg_dbf.get_field_values(par_row => v_row);
      v_buff(v_i2).oldcode := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(1).v_char)
                                          ,'CL8MSWIN1251'
                                          ,'RU8PC866'));
      v_buff(v_i2).newcode := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(2).v_char)
                                          ,'CL8MSWIN1251'
                                          ,'RU8PC866'));
      v_buff(v_i2).plevel := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(3).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).load_id := par_load_id;
      v_buff(v_i2).load_date := sq_load_date;
      v_buff(v_i2).load_name := par_file_name;
      v_buff(v_i2).is_actual := 0;
    
      IF v_i2 = 1000
      THEN
        FORALL i IN v_buff.first .. v_buff.last
          INSERT /*+ APPEND*/
          INTO t_altnames_orig
          VALUES v_buff
            (i);
        v_buff.delete;
        IF pkg_dbf.get_row_count - v_i < 1000
        THEN
          v_buff.extend(pkg_dbf.get_row_count - v_i);
        ELSE
          v_buff.extend(1000);
        END IF;
        v_i2 := 0;
      END IF;
      v_i2 := v_i2 + 1;
    END LOOP;
    FORALL v_i IN v_buff.first .. v_buff.last
      INSERT /*+ APPEND*/
      INTO t_altnames_orig
      VALUES v_buff
        (v_i);
  
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_ALTNAMES_ORIG', cascade => TRUE);
  
  END parse_altnames_dbf;
  /***************************/
  PROCEDURE parse_socrbase_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  ) IS
    v_dbf    BLOB;
    v_fields pkg_dbf.t_fields_values;
    v_row    RAW(2000);
  
    TYPE t_buff IS TABLE OF t_socrbase_orig%ROWTYPE;
    v_buff       t_buff := t_buff();
    v_i2         PLS_INTEGER := 1;
    sq_load_date VARCHAR2(10) := to_char(SYSDATE, 'DD.MM.YYYY');
  BEGIN
    dbms_application_info.set_client_info('PARSE_SOCRBASE_DBF');
    SELECT file_blob
      INTO v_dbf
      FROM temp_load_blob
     WHERE session_id = par_id
       AND file_name = par_file_name;
  
    pkg_dbf.load_header_info(par_dbf => v_dbf);
    IF pkg_dbf.get_row_count >= 1000
    THEN
      v_buff.extend(1000);
    ELSE
      v_buff.extend(pkg_dbf.get_row_count);
    END IF;
  
    FOR v_i IN 1 .. pkg_dbf.get_row_count
    LOOP
      v_row := pkg_dbf.get_row(par_row_number => v_i);
    
      v_fields := pkg_dbf.get_field_values(par_row => v_row);
      v_buff(v_i2).plevel := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(1).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).scname := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(2).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).socrname := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(3).v_char)
                                           ,'CL8MSWIN1251'
                                           ,'RU8PC866'));
      v_buff(v_i2).kod_t_st := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(4).v_char)
                                           ,'CL8MSWIN1251'
                                           ,'RU8PC866'));
      v_buff(v_i2).load_id := par_load_id;
      v_buff(v_i2).load_date := sq_load_date;
      v_buff(v_i2).load_name := par_file_name;
      v_buff(v_i2).is_actual := 0;
    
      IF v_i2 = 1000
      THEN
        FORALL i IN v_buff.first .. v_buff.last
          INSERT /*+ APPEND*/
          INTO t_socrbase_orig
          VALUES v_buff
            (i);
        v_buff.delete;
        IF pkg_dbf.get_row_count - v_i < 1000
        THEN
          v_buff.extend(pkg_dbf.get_row_count - v_i);
        ELSE
          v_buff.extend(1000);
        END IF;
        v_i2 := 0;
      END IF;
      v_i2 := v_i2 + 1;
    END LOOP;
    FORALL v_i IN v_buff.first .. v_buff.last
      INSERT /*+ APPEND*/
      INTO t_socrbase_orig
      VALUES v_buff
        (v_i);
  
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_SOCRBASE_ORIG', cascade => TRUE);
  
  END parse_socrbase_dbf;
  /***************************/
  PROCEDURE parse_npindex_dbf
  (
    par_id        NUMBER
   ,par_load_id   NUMBER
   ,par_file_name VARCHAR2
  ) IS
    v_dbf    BLOB;
    v_fields pkg_dbf.t_fields_values;
    v_row    RAW(2000);
  
    TYPE t_buff IS TABLE OF t_npindx_orig%ROWTYPE;
    v_buff       t_buff := t_buff();
    v_i2         PLS_INTEGER := 1;
    sq_load_date VARCHAR2(10) := to_char(SYSDATE, 'DD.MM.YYYY');
  BEGIN
    dbms_application_info.set_client_info('PARSE_NPINDEX_DBF');
    SELECT file_blob
      INTO v_dbf
      FROM temp_load_blob
     WHERE session_id = par_id
       AND file_name = par_file_name;
  
    pkg_dbf.load_header_info(par_dbf => v_dbf);
    IF pkg_dbf.get_row_count >= 1000
    THEN
      v_buff.extend(1000);
    ELSE
      v_buff.extend(pkg_dbf.get_row_count);
    END IF;
  
    FOR v_i IN 1 .. pkg_dbf.get_row_count
    LOOP
      v_row := pkg_dbf.get_row(par_row_number => v_i);
    
      v_fields := pkg_dbf.get_field_values(par_row => v_row);
      v_buff(v_i2).pindex := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(1).v_char)
                                         ,'CL8MSWIN1251'
                                         ,'RU8PC866'));
      v_buff(v_i2).pnindex := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(2).v_char)
                                          ,'CL8MSWIN1251'
                                          ,'RU8PC866'));
      v_buff(v_i2).nactdate := TRIM(convert(utl_raw.cast_to_varchar2(v_fields(11).v_char)
                                           ,'CL8MSWIN1251'
                                           ,'RU8PC866'));
      v_buff(v_i2).load_id := par_load_id;
      v_buff(v_i2).load_date := sq_load_date;
      v_buff(v_i2).load_name := par_file_name;
      v_buff(v_i2).is_actual := 0;
    
      IF v_i2 = 1000
      THEN
        FORALL i IN v_buff.first .. v_buff.last
          INSERT /*+ APPEND*/
          INTO t_npindx_orig
          VALUES v_buff
            (i);
        v_buff.delete;
        IF pkg_dbf.get_row_count - v_i < 1000
        THEN
          v_buff.extend(pkg_dbf.get_row_count - v_i);
        ELSE
          v_buff.extend(1000);
        END IF;
        v_i2 := 0;
      END IF;
      v_i2 := v_i2 + 1;
    END LOOP;
    FORALL v_i IN v_buff.first .. v_buff.last
      INSERT /*+ APPEND*/
      INTO t_npindx_orig
      VALUES v_buff
        (v_i);
  
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_NPINDX_ORIG', cascade => TRUE);
  
  END parse_npindex_dbf;
  /***************************/
  PROCEDURE actual_kladr_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  ) IS
    pv_cnt     NUMBER;
    v_continue BOOLEAN;
  BEGIN
    /**********************/
    dbms_application_info.set_client_info('Собираем статистику по T_KLADR');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_KLADR', cascade => TRUE);
    dbms_application_info.set_client_info('Собираем статистику по T_KLADR_ORIG');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_KLADR_ORIG', cascade => TRUE);
    /***step_1 step_4*******/
    dbms_application_info.set_client_info('Актуализация T_KLADR');
    SELECT COUNT(*)
      INTO pv_cnt
      FROM ins.t_kladr_orig ko
     WHERE ko.load_id = p_load_id
       AND ko.load_name = p_file_name
       AND ko.is_actual = 0;
    IF pv_cnt > 0
    THEN
      v_continue := TRUE;
    ELSE
      v_continue := FALSE;
    END IF;
    IF v_continue
    THEN
      /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                                 change_type,
                                                 code,
                                                 new_value,
                                                 old_value,
                                                 table_name,
                                                 user_id)
      SELECT TRUNC(SYSDATE),
               2,\*отредактирована*\
               ko.code,
               'Точное совпадение полей в T_KLADR: '||
               \*'Наименование '||*\ko.name||
               \*';Сокращение '||*\','||ko.socr||
               \*';Код '||*\','||ko.code||
               \*';Индекс '||*\','||ko.pindex||
               ','||ko.gninmb||
               ','||ko.uno||
               ','||ko.ocatd||
               \*';Статус '||*\','||ko.status||
               \*';Дата добавления '||*\','||kl.add_date||
               \*';Дата изменения '||*\','||kl.edit_date||
               \*';Дата актуализации'||*\','||TRUNC(P_ACTUAL_DATE)||
               \*';Нет в КЛАДР '||*\','||kl.not_in_kladr,
               \*'Наименование '||*\kl.name||
               \*';Сокращение '||*\','||kl.socr||
               \*';Код '||*\','||kl.code||
               \*';Индекс '||*\','||kl.pindex||
               ','||kl.gninmb||
               ','||kl.uno||
               ','||kl.ocatd||
               \*';Статус '||*\','||kl.status||
               \*';Дата добавления '||*\','||kl.add_date||
               \*';Дата изменения '||*\','||kl.edit_date||
               \*';Дата актуализации '||*\','||kl.actual_date||
               \*';Нет в КЛАДР '||*\','||kl.not_in_kladr,
               'T_KLADR',
               (SELECT us.sys_user_id
               FROM ins.sys_user us
               WHERE us.sys_user_name = USER)
        FROM ins.t_kladr kl,
             ins.t_kladr_orig ko
        WHERE ko.code = kl.code
          AND ko.load_id = P_LOAD_ID
          AND ko.load_name = P_FILE_NAME
          AND ko.is_actual = 0
          AND kl.name = ko.name
          AND kl.socr = ko.socr
          AND NVL(kl.pindex,'X') = NVL(ko.pindex,'X')
          AND NVL(kl.gninmb,'X') = NVL(ko.gninmb,'X')
          AND NVL(kl.uno,'X') = NVL(ko.uno,'X')
          AND NVL(kl.ocatd,'X') = NVL(ko.ocatd,'X')
          AND kl.status = ko.status;*/
    
      UPDATE ins.t_kladr kld
         SET kld.actual_date = trunc(p_actual_date)
       WHERE EXISTS (SELECT NULL
                FROM ins.t_kladr_orig ko
               WHERE kld.name = ko.name
                 AND kld.socr = ko.socr
                 AND kld.code = ko.code
                 AND nvl(kld.pindex, 'X') = nvl(ko.pindex, 'X')
                 AND nvl(kld.gninmb, 'X') = nvl(ko.gninmb, 'X')
                 AND nvl(kld.uno, 'X') = nvl(ko.uno, 'X')
                 AND nvl(kld.ocatd, 'X') = nvl(ko.ocatd, 'X')
                 AND kld.status = ko.status
                 AND ko.load_id = p_load_id
                 AND ko.load_name = p_file_name
                 AND ko.is_actual = 0);
    
      IF SQL%ROWCOUNT < pv_cnt
      THEN
        /***step_5*******/
        INSERT INTO ins.ven_update_journal_kladr
          (change_date, change_type, code, new_value, old_value, table_name, user_id)
          SELECT trunc(SYSDATE)
                ,2
                , /*отредактирована*/ko.code
                , 'Совпадение кодов КЛАДР в T_KLADR: ' ||
                 /*'Наименование '||*/
                  ko.name ||
                 /*';Сокращение '||*/
                  ',' || ko.socr ||
                 /*';Код '||*/
                  ',' || ko.code ||
                 /*';Индекс '||*/
                  ',' || ko.pindex || ',' || ko.gninmb || ',' || ko.uno || ',' || ko.ocatd ||
                 /*';Статус '||*/
                  ',' || ko.status ||
                 /*';Дата добавления '||*/
                  ',' || kl.add_date ||
                 /*';Дата изменения '||*/
                  ',' || trunc(SYSDATE) ||
                 /*';Дата актуализации'||*/
                  ',' || trunc(p_actual_date) ||
                 /*';Нет в КЛАДР '||*/
                  ',' || kl.not_in_kladr
                ,kl.name || ',' || kl.socr || ',' || kl.code || ',' || kl.pindex || ',' || kl.gninmb || ',' ||
                 kl.uno || ',' || kl.ocatd || ',' || kl.status || ',' || kl.add_date || ',' ||
                 kl.edit_date || ',' || kl.actual_date || ',' || kl.not_in_kladr
                ,'T_KLADR'
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.t_kladr      kl
                ,ins.t_kladr_orig ko
           WHERE ko.code = kl.code
             AND ko.load_id = p_load_id
             AND ko.load_name = p_file_name
             AND ko.is_actual = 0
             AND (kl.name != ko.name OR kl.socr != ko.socr OR kl.code != ko.code OR
                 nvl(kl.pindex, 'X') != nvl(ko.pindex, 'X') OR
                 nvl(kl.gninmb, 'X') != nvl(ko.gninmb, 'X') OR nvl(kl.uno, 'X') != nvl(ko.uno, 'X') OR
                 nvl(kl.ocatd, 'X') != nvl(ko.ocatd, 'X') OR kl.status != ko.status);
        /***step_2 step_4*******/
        UPDATE ins.t_kladr kl
           SET (kl.code
              ,kl.name
              ,kl.socr
              ,kl.pindex
              ,kl.gninmb
              ,kl.uno
              ,kl.status
              ,kl.ocatd
              ,kl.edit_date
              ,kl.actual_date) =
               (SELECT ko.code
                      ,ko.name
                      ,ko.socr
                      ,ko.pindex
                      ,ko.gninmb
                      ,ko.uno
                      ,ko.status
                      ,ko.ocatd
                      ,trunc(SYSDATE)
                      ,trunc(p_actual_date)
                  FROM ins.t_kladr_orig ko
                 WHERE kl.code = ko.code
                   AND ko.load_id = p_load_id
                   AND ko.load_name = p_file_name
                   AND ko.is_actual = 0
                   AND (kl.name != ko.name OR kl.socr != ko.socr OR kl.code != ko.code OR
                       nvl(kl.pindex, 'X') != nvl(ko.pindex, 'X') OR
                       nvl(kl.gninmb, 'X') != nvl(ko.gninmb, 'X') OR
                       nvl(kl.uno, 'X') != nvl(ko.uno, 'X') OR
                       nvl(kl.ocatd, 'X') != nvl(ko.ocatd, 'X') OR kl.status != ko.status))
         WHERE EXISTS
         (SELECT NULL
                  FROM ins.t_kladr_orig kod
                 WHERE kl.code = kod.code
                   AND kod.load_id = p_load_id
                   AND kod.load_name = p_file_name
                   AND kod.is_actual = 0
                   AND (kl.name != kod.name OR kl.socr != kod.socr OR
                       nvl(kl.pindex, 'X') != nvl(kod.pindex, 'X') OR
                       nvl(kl.gninmb, 'X') != nvl(kod.gninmb, 'X') OR
                       nvl(kl.uno, 'X') != nvl(kod.uno, 'X') OR
                       nvl(kl.ocatd, 'X') != nvl(kod.ocatd, 'X') OR kl.status != kod.status));
        /***step_3 step_4*******/
        INSERT ALL INTO ins.t_kladr
          (t_kladr_id
          ,ent_id
          ,add_date
          ,NAME
          ,socr
          ,code
          ,pindex
          ,gninmb
          ,uno
          ,ocatd
          ,status
          ,actual_date)
        VALUES
          (sq_t_kladr.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'T_KLADR')
          ,trunc(SYSDATE)
          ,NAME
          ,socr
          ,code
          ,pindex
          ,gninmb
          ,uno
          ,ocatd
          ,status
          ,trunc(p_actual_date)) INTO ins.update_journal_kladr
          (update_journal_kladr_id
          ,ent_id
          ,change_date
          ,change_type
          ,code
          ,new_value
          ,old_value
          ,table_name
          ,user_id)
        VALUES
          (sq_update_journal_kladr.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'UPDATE_JOURNAL_KLADR')
          ,trunc(SYSDATE)
          ,1
          , /*добавлена*/code
          ,'Новые записи КЛАДР в T_KLADR: ' || NAME || ',' || socr || ',' || code || ',' || pindex || ',' ||
           gninmb || ',' || uno || ',' || ocatd || ',' || status || ',' || trunc(SYSDATE) || ',' ||
           trunc(p_actual_date)
          ,''
          ,'T_KLADR'
          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER))
          SELECT trunc(SYSDATE)
                ,ko.name
                ,ko.socr
                ,ko.code
                ,ko.pindex
                ,ko.gninmb
                ,ko.uno
                ,ko.ocatd
                ,ko.status
                ,trunc(p_actual_date)
                ,ko.load_date
            FROM ins.t_kladr_orig ko
           WHERE NOT EXISTS (SELECT NULL FROM ins.t_kladr kl WHERE kl.code = ko.code)
             AND ko.load_id = p_load_id
             AND ko.load_name = p_file_name
             AND ko.is_actual = 0;
        /*INSERT INTO ins.ven_t_kladr (add_date, 
                                    name,
                                    socr,
                                    code,
                                    pindex, 
                                    gninmb, 
                                    uno,
                                    ocatd, 
                                    status,
                                    actual_date
                                    )
        SELECT SYSDATE,
               ko.name, 
               ko.socr, 
               ko.code, 
               ko.pindex, 
               ko.gninmb, 
               ko.uno, 
               ko.ocatd, 
               ko.status,
               P_ACTUAL_DATE
        FROM ins.t_kladr_orig ko
        WHERE NOT EXISTS (SELECT NULL
                          FROM ins.t_kladr kl
                          WHERE kl.code = ko.code)
          AND ko.load_id = P_LOAD_ID
          AND ko.load_name = P_FILE_NAME;
        n := SQL%ROWCOUNT;
        \***step_5*******\
        INSERT INTO ins.ven_update_journal_kladr (change_date,
                                               change_type,
                                               code,
                                               new_value,
                                               old_value,
                                               table_name,
                                               user_id)
         SELECT SYSDATE,
                1,\*добавлена*\
                ko.code, 
                'Наименование '||ko.name||
                ';Сокращение '||ko.socr||
                ';Код '||ko.code||
                ';Индекс '||ko.pindex||
                ';Статус '||ko.status||
                ';Дата загрузки'||ko.load_date,
                '', 
                'T_KLADR',
                (SELECT us.sys_user_id
                 FROM ins.sys_user us
                 WHERE us.sys_user_name = USER)
         FROM ins.t_kladr_orig ko
         WHERE NOT EXISTS (SELECT NULL
                           FROM ins.t_kladr kl
                           WHERE kl.code = ko.code)
           AND ko.load_id = P_LOAD_ID
           AND ko.load_name = P_FILE_NAME;*/
      END IF;
      /*************************/
      INSERT INTO ins.ven_update_journal_kladr
        (change_date, change_type, code, new_value, old_value, table_name, user_id)
        SELECT trunc(SYSDATE)
              ,2
              , /*отредактирована*/ko.code
              ,'Обновление дат редактирования и актуализации в T_KLADR: ' || ko.name || ',' ||
               ko.socr || ',' || ko.code || ',' || ko.pindex || ',' || ko.gninmb || ',' || ko.uno || ',' ||
               ko.ocatd || ',' || ko.status || ',' || ko.add_date || ',' || trunc(SYSDATE) || ',' ||
               trunc(p_actual_date) || ',1'
              ,ko.name || ',' || ko.socr || ',' || ko.code || ',' || ko.pindex || ',' || ko.gninmb || ',' ||
               ko.uno || ',' || ko.ocatd || ',' || ko.status || ',' || ko.add_date || ',' ||
               ko.edit_date || ',' || ko.actual_date || ',' || ko.not_in_kladr
              ,'T_KLADR'
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.t_kladr ko
         WHERE nvl(trunc(ko.actual_date), '01.01.1900') < trunc(p_actual_date)
           AND ko.not_in_kladr = 0;
    
      UPDATE ins.t_kladr ko
         SET ko.not_in_kladr = 1
            ,ko.edit_date    = trunc(SYSDATE)
            ,ko.actual_date  = trunc(p_actual_date)
       WHERE nvl(trunc(ko.actual_date), '01.01.1900') < trunc(p_actual_date);
    
      UPDATE ins.t_kladr_orig ko
         SET ko.is_actual = 1
       WHERE ko.load_id = p_load_id
         AND ko.load_name = p_file_name
         AND ko.is_actual = 0;
    
      DELETE FROM ins.t_kladr t
       WHERE t.t_kladr_id NOT IN (SELECT MIN(kl.t_kladr_id)
                                    FROM ins.t_kladr kl
                                   GROUP BY kl.name
                                           ,kl.socr
                                           ,kl.code);
      /*********************/
      dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_KLADR', cascade => TRUE);
      /*********************/
    END IF;
  
  END actual_kladr_to_db;
  /******************************************************************************/
  PROCEDURE actual_street_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  ) IS
    pv_cnt     NUMBER;
    v_continue BOOLEAN;
  BEGIN
    /**********************/
    dbms_application_info.set_client_info('Собираем статистику по T_STREET');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_STREET', cascade => TRUE);
    dbms_application_info.set_client_info('Собираем статистику по T_STREET_ORIG');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_STREET_ORIG', cascade => TRUE);
    /************************/
    dbms_application_info.set_client_info('Актуализация T_STREET');
    SELECT COUNT(*)
      INTO pv_cnt
      FROM ins.t_street_orig so
     WHERE so.load_id = p_load_id
       AND so.load_name = p_file_name
       AND so.is_actual = 0;
    IF pv_cnt > 0
    THEN
      v_continue := TRUE;
    ELSE
      v_continue := FALSE;
    END IF;
    /***step_1 step_4*******/
    IF v_continue
    THEN
      /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                                change_type,
                                                code,
                                                new_value,
                                                old_value,
                                                table_name,
                                                user_id)
      SELECT TRUNC(SYSDATE),
             2,\*отредактирована*\
             sto.code,
             'Точное совпадение полей в T_STREET: '||
             sto.name||
             ','||sto.socr||
             ','||sto.code||
             ','||sto.pindex||
             ','||sto.gninmb||
             ','||sto.uno||
             ','||sto.ocatd||
             ','||st.add_date||
             ','||st.edit_date||
             ','||TRUNC(P_ACTUAL_DATE)||
             ','||st.not_in_kladr,
             st.name||
             ','||st.socr||
             ','||st.code||
             ','||st.pindex||
             ','||st.gninmb||
             ','||st.uno||
             ','||st.ocatd||
             ','||st.add_date||
             ','||st.edit_date||
             ','||st.actual_date||
             ','||st.not_in_kladr,
             'T_STREET',
             (SELECT us.sys_user_id
             FROM ins.sys_user us
             WHERE us.sys_user_name = USER)
      FROM ins.t_street st,
           ins.t_street_orig sto
      WHERE sto.code = st.code
        AND sto.load_id = P_LOAD_ID
        AND sto.load_name = P_FILE_NAME
        AND sto.is_actual = 0
        AND st.name = sto.name
        AND st.socr = sto.socr
        AND NVL(st.pindex,'X') = NVL(sto.pindex,'X')
        AND NVL(st.gninmb,'X') = NVL(sto.gninmb,'X')
        AND NVL(st.uno,'X') = NVL(sto.uno,'X')
        AND NVL(st.ocatd,'X') = NVL(sto.ocatd,'X');*/
    
      UPDATE ins.t_street std
         SET std.actual_date = trunc(p_actual_date)
       WHERE EXISTS (SELECT NULL
                FROM ins.t_street_orig so
               WHERE std.name = so.name
                 AND std.socr = so.socr
                 AND std.code = so.code
                 AND nvl(std.pindex, 'X') = nvl(so.pindex, 'X')
                 AND nvl(std.gninmb, 'X') = nvl(so.gninmb, 'X')
                 AND nvl(std.uno, 'X') = nvl(so.uno, 'X')
                 AND nvl(std.ocatd, 'X') = nvl(so.ocatd, 'X')
                 AND so.load_id = p_load_id
                 AND so.load_name = p_file_name
                 AND so.is_actual = 0);
    
      IF SQL%ROWCOUNT < pv_cnt
      THEN
        /***step_5*******/
        INSERT INTO ins.ven_update_journal_kladr
          (change_date, change_type, code, new_value, old_value, table_name, user_id)
          SELECT trunc(SYSDATE)
                ,2
                , /*отредактирована*/sto.code
                ,'Совпадение кодов КЛАДР в T_STREET: ' || sto.name || ',' || sto.socr || ',' ||
                 sto.code || ',' || sto.pindex || ',' || sto.gninmb || ',' || sto.uno || ',' ||
                 sto.ocatd || ',' || st.add_date || ',' || trunc(SYSDATE) || ',' ||
                 trunc(p_actual_date) || ',' || st.not_in_kladr
                ,st.name || ',' || st.socr || ',' || st.code || ',' || st.pindex || ',' || st.gninmb || ',' ||
                 st.uno || ',' || st.ocatd || ',' || st.add_date || ',' || st.edit_date || ',' ||
                 st.actual_date || ',' || st.not_in_kladr
                ,'T_STREET'
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.t_street      st
                ,ins.t_street_orig sto
           WHERE sto.code = st.code
             AND sto.load_id = p_load_id
             AND sto.load_name = p_file_name
             AND sto.is_actual = 0
             AND (st.name != sto.name OR st.socr != sto.socr OR
                 nvl(st.pindex, 'X') != nvl(sto.pindex, 'X') OR
                 nvl(st.gninmb, 'X') != nvl(sto.gninmb, 'X') OR nvl(st.uno, 'X') != nvl(sto.uno, 'X') OR
                 nvl(st.ocatd, 'X') != nvl(sto.ocatd, 'X'));
        /***step_2 step_4*******/
        UPDATE ins.t_street st
           SET (st.code
              ,st.name
              ,st.socr
              ,st.pindex
              ,st.gninmb
              ,st.uno
              ,st.ocatd
              ,st.edit_date
              ,st.actual_date) =
               (SELECT so.code
                      ,so.name
                      ,so.socr
                      ,so.pindex
                      ,so.gninmb
                      ,so.uno
                      ,so.ocatd
                      ,trunc(SYSDATE)
                      ,p_actual_date
                  FROM ins.t_street_orig so
                 WHERE st.code = so.code
                   AND so.load_id = p_load_id
                   AND so.load_name = p_file_name
                   AND so.is_actual = 0
                   AND (st.name != so.name OR st.socr != so.socr OR
                       nvl(st.pindex, 'X') != nvl(so.pindex, 'X') OR
                       nvl(st.gninmb, 'X') != nvl(so.gninmb, 'X') OR
                       nvl(st.uno, 'X') != nvl(so.uno, 'X') OR
                       nvl(st.ocatd, 'X') != nvl(so.ocatd, 'X')))
         WHERE EXISTS (SELECT NULL
                  FROM ins.t_street_orig sod
                 WHERE st.code = sod.code
                   AND sod.load_id = p_load_id
                   AND sod.load_name = p_file_name
                   AND sod.is_actual = 0
                   AND (st.name != sod.name OR st.socr != sod.socr OR
                       nvl(st.pindex, 'X') != nvl(sod.pindex, 'X') OR
                       nvl(st.gninmb, 'X') != nvl(sod.gninmb, 'X') OR
                       nvl(st.uno, 'X') != nvl(sod.uno, 'X') OR
                       nvl(st.ocatd, 'X') != nvl(sod.ocatd, 'X')));
        /***step_3 step_4*******/
        INSERT ALL INTO ins.t_street
          (street_id, ent_id, add_date, NAME, socr, code, pindex, gninmb, uno, ocatd, actual_date)
        VALUES
          (sq_t_street.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'T_STREET')
          ,trunc(SYSDATE)
          ,NAME
          ,socr
          ,code
          ,pindex
          ,gninmb
          ,uno
          ,ocatd
          ,trunc(p_actual_date)) INTO ins.update_journal_kladr
          (update_journal_kladr_id
          ,ent_id
          ,change_date
          ,change_type
          ,code
          ,new_value
          ,old_value
          ,table_name
          ,user_id)
        VALUES
          (sq_update_journal_kladr.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'UPDATE_JOURNAL_KLADR')
          ,trunc(SYSDATE)
          ,1
          , /*добавлена*/code
          ,'Добавление новых записей в T_STREET: ' || NAME || ',' || socr || ',' || code || ',' ||
           pindex || ',' || gninmb || ',' || uno || ',' || ocatd || ',' || trunc(SYSDATE) || ',' ||
           trunc(p_actual_date)
          ,''
          ,'T_STREET'
          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER))
          SELECT SYSDATE
                ,sto.name
                ,sto.socr
                ,sto.code
                ,sto.pindex
                ,sto.gninmb
                ,sto.uno
                ,sto.ocatd
                ,trunc(p_actual_date)
                ,sto.load_date
            FROM ins.t_street_orig sto
           WHERE NOT EXISTS (SELECT NULL FROM ins.t_street st WHERE st.code = sto.code)
             AND sto.load_id = p_load_id
             AND sto.load_name = p_file_name
             AND sto.is_actual = 0;
        /***step_5*******/
        /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                              change_type,
                                              code,
                                              new_value,
                                              old_value,
                                              table_name,
                                              user_id)
        SELECT SYSDATE,
               1,\*добавлена*\
               sto.code,
               'Наименование '||sto.name||
               ';Сокращение '||sto.socr||
               ';Код '||sto.code||
               ';Индекс '||sto.pindex||
               ';Дата загрузки'||sto.load_date,
               '', 
               'T_STREET',
               (SELECT us.sys_user_id
                FROM ins.sys_user us
                WHERE us.sys_user_name = USER)
        FROM ins.t_street_orig sto
        WHERE NOT EXISTS (SELECT NULL
                         FROM ins.t_street st
                         WHERE st.code = sto.code)
          AND sto.load_id = P_LOAD_ID
          AND sto.load_name = P_FILE_NAME;*/
      END IF;
      /*************************/
      INSERT INTO ins.ven_update_journal_kladr
        (change_date, change_type, code, new_value, old_value, table_name, user_id)
        SELECT trunc(SYSDATE)
              ,2
              , /*отредактирована*/so.code
              ,'Обновление дат редактирования и актуализации в T_STREET: ' || so.name || ',' ||
               so.socr || ',' || so.code || ',' || so.pindex || ',' || so.gninmb || ',' || so.uno || ',' ||
               so.ocatd || ',' || so.add_date || ',' || trunc(SYSDATE) || ',' || trunc(p_actual_date) || ',1'
              ,so.name || ',' || so.socr || ',' || so.code || ',' || so.pindex || ',' || so.gninmb || ',' ||
               so.uno || ',' || so.ocatd || ',' || so.add_date || ',' || so.edit_date || ',' ||
               so.actual_date || ',0'
              ,'T_STREET'
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.t_street so
         WHERE trunc(so.actual_date) < trunc(p_actual_date)
           AND so.not_in_kladr = 0;
      UPDATE ins.t_street so
         SET so.not_in_kladr = 1
            ,so.edit_date    = trunc(SYSDATE)
            ,so.actual_date  = trunc(p_actual_date)
       WHERE nvl(trunc(so.actual_date), '01.01.1900') < trunc(p_actual_date);
    
      UPDATE ins.t_street_orig so
         SET so.is_actual = 1
       WHERE so.load_id = p_load_id
         AND so.load_name = p_file_name
         AND so.is_actual = 0;
    
      DELETE FROM ins.t_street st
       WHERE st.street_id NOT IN (SELECT MIN(sta.street_id)
                                    FROM ins.t_street sta
                                   GROUP BY sta.name
                                           ,sta.socr
                                           ,sta.code);
    END IF;
  
  END actual_street_to_db;
  /***********************************************************************************************/
  PROCEDURE actual_altnames_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  ) IS
    pv_cnt     NUMBER;
    v_continue BOOLEAN;
  BEGIN
    /**********************/
    dbms_application_info.set_client_info('Собираем статистику по T_ALTNAMES');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_ALTNAMES', cascade => TRUE);
    /**********************/
    dbms_application_info.set_client_info('Актуализация T_ALTNAMES');
    SELECT COUNT(*)
      INTO pv_cnt
      FROM ins.t_altnames_orig aoo
     WHERE aoo.load_id = p_load_id
       AND aoo.load_name = p_file_name
       AND aoo.is_actual = 0;
    IF pv_cnt > 0
    THEN
      v_continue := TRUE;
    ELSE
      v_continue := FALSE;
    END IF;
    /***step_1 step_4*******/
    IF v_continue
    THEN
      /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                                change_type,
                                                code,
                                                new_value,
                                                old_value,
                                                table_name,
                                                user_id)
      SELECT TRUNC(SYSDATE),
             2,\*отредактирована*\
             stt.oldcode,
             'Полное совпадение в T_ALT: '||
             stt.oldcode||
             ','||stt.newcode||
             ','||stt.plevel||
             ','||t.add_date||
             ','||t.edit_date||
             ','||TRUNC(P_ACTUAL_DATE)||
             ','||t.not_in_kladr,
             t.oldcode||
             ','||t.newcode||
             ','||t.plevel||
             ','||t.add_date||
             ','||t.edit_date||
             ','||t.actual_date||
             ','||t.not_in_kladr,
             'T_ALT',
             (SELECT us.sys_user_id
             FROM ins.sys_user us
             WHERE us.sys_user_name = USER)
      FROM ins.t_altnames t,
           ins.t_altnames_orig stt
      WHERE stt.oldcode = t.oldcode
        AND stt.load_id = P_LOAD_ID
        AND stt.load_name = P_FILE_NAME
        AND stt.is_actual = 0
        AND t.newcode = stt.newcode
        AND t.plevel = stt.plevel;*/
    
      UPDATE ins.t_altnames ta
         SET ta.actual_date = trunc(p_actual_date)
       WHERE EXISTS (SELECT NULL
                FROM ins.t_altnames_orig aoo
               WHERE ta.oldcode = aoo.oldcode
                 AND ta.newcode = aoo.newcode
                 AND ta.plevel = aoo.plevel
                 AND aoo.load_id = p_load_id
                 AND aoo.load_name = p_file_name
                 AND aoo.is_actual = 0);
    
      IF SQL%ROWCOUNT < pv_cnt
      THEN
        /***step_5*******/
        INSERT INTO ins.ven_update_journal_kladr
          (change_date, change_type, code, new_value, old_value, table_name, user_id)
          SELECT trunc(SYSDATE)
                ,2
                , /*отредактирована*/stt.oldcode
                ,'Совпадение кодов КЛАДР в T_ALT: ' || stt.oldcode || ',' || stt.newcode || ',' ||
                 stt.plevel || ',' || t.add_date || ',' || trunc(SYSDATE) || ',' ||
                 trunc(p_actual_date) || ',' || t.not_in_kladr
                ,t.oldcode || ',' || t.newcode || ',' || t.plevel || ',' || t.add_date || ',' ||
                 t.edit_date || ',' || t.actual_date || ',' || t.not_in_kladr
                ,'T_ALT'
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.t_altnames      t
                ,ins.t_altnames_orig stt
           WHERE stt.oldcode = t.oldcode
             AND stt.load_id = p_load_id
             AND stt.load_name = p_file_name
             AND stt.is_actual = 0
             AND (t.newcode != stt.newcode OR t.plevel != stt.plevel);
        /***step_2 step_4*******/
        UPDATE ins.t_altnames ta
           SET (ta.oldcode, ta.newcode, ta.plevel, ta.edit_date, ta.actual_date) =
               (SELECT tp.oldcode
                      ,tp.newcode
                      ,tp.plevel
                      ,trunc(SYSDATE)
                      ,p_actual_date
                  FROM ins.t_altnames_orig tp
                 WHERE tp.oldcode = ta.oldcode
                   AND tp.load_id = p_load_id
                   AND tp.load_name = p_file_name
                   AND tp.is_actual = 0
                   AND (ta.newcode != tp.newcode OR ta.plevel != tp.plevel)
                   AND rownum = 1)
         WHERE EXISTS (SELECT NULL
                  FROM ins.t_altnames_orig tod
                 WHERE tod.oldcode = ta.oldcode
                   AND tod.load_id = p_load_id
                   AND tod.load_name = p_file_name
                   AND tod.is_actual = 0
                   AND (ta.newcode != tod.newcode OR ta.plevel != tod.plevel));
        /***step_3 step_4*******/
        INSERT ALL INTO ins.t_altnames
          (t_altnames_id, ent_id, add_date, oldcode, newcode, plevel, actual_date)
        VALUES
          (sq_t_altnames.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'T_ALTNAMES')
          ,trunc(SYSDATE)
          ,oldcode
          ,newcode
          ,plevel
          ,trunc(p_actual_date)) INTO ins.update_journal_kladr
          (update_journal_kladr_id
          ,ent_id
          ,change_date
          ,change_type
          ,code
          ,new_value
          ,old_value
          ,table_name
          ,user_id)
        VALUES
          (sq_update_journal_kladr.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'UPDATE_JOURNAL_KLADR')
          ,trunc(SYSDATE)
          ,1
          , /*добавлена*/oldcode
          ,'Новые записи КЛАДР в T_ALT: ' || oldcode || ',' || newcode || ',' || plevel || ',' ||
           trunc(SYSDATE) || ',' || trunc(p_actual_date)
          ,''
          ,'T_ALT'
          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER))
          SELECT trunc(SYSDATE)
                ,ato.oldcode
                ,ato.newcode
                ,ato.plevel
                ,trunc(p_actual_date)
                ,ato.load_date
            FROM ins.t_altnames_orig ato
           WHERE NOT EXISTS (SELECT NULL FROM ins.t_altnames at WHERE at.oldcode = ato.oldcode)
             AND ato.load_id = p_load_id
             AND ato.load_name = p_file_name
             AND ato.is_actual = 0;
        /***step_5*******/
        /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                              change_type,
                                              code,
                                              new_value,
                                              old_value,
                                              table_name,
                                              user_id)
        SELECT SYSDATE,
               1,\*добавлена*\
               ato.oldcode,
               'Старый Код '||ato.oldcode||
               ';Новый Код '||ato.newcode||
               ';Уровень '||ato.plevel||
               ';Дата загрузки'||ato.load_date,
               '', 
               'T_ALT',
               (SELECT us.sys_user_id
                FROM ins.sys_user us
                WHERE us.sys_user_name = USER)
        FROM ins.t_altnames_orig ato
        WHERE NOT EXISTS (SELECT NULL
                          FROM ins.t_altnames at
                          WHERE at.oldcode = ato.oldcode)
          AND ato.load_id = P_LOAD_ID
          AND ato.load_name = P_FILE_NAME;*/
      END IF;
      /*************************/
      INSERT INTO ins.ven_update_journal_kladr
        (change_date, change_type, code, new_value, old_value, table_name, user_id)
        SELECT trunc(SYSDATE)
              ,2
              , /*отредактирована*/ta.oldcode
              ,'Обновление дат редактирования и актуализации в T_ALT: ' || ta.oldcode || ',' ||
               ta.newcode || ',' || ta.plevel || ',' || ta.add_date || ',' || trunc(SYSDATE) || ',' ||
               trunc(p_actual_date) || ',1'
              ,ta.oldcode || ',' || ta.newcode || ',' || ta.plevel || ',' || ta.add_date || ',' ||
               ta.edit_date || ',' || ta.actual_date || ',' || ta.not_in_kladr
              ,'T_ALT'
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.t_altnames ta
         WHERE trunc(ta.actual_date) < trunc(p_actual_date)
           AND ta.not_in_kladr = 0;
    
      UPDATE ins.t_altnames_orig ato
         SET ato.is_actual = 1
       WHERE ato.load_id = p_load_id
         AND ato.load_name = p_file_name
         AND ato.is_actual = 0;
    
      UPDATE ins.t_altnames ta
         SET ta.not_in_kladr = 1
            ,ta.edit_date    = trunc(SYSDATE)
            ,ta.actual_date  = trunc(p_actual_date)
       WHERE nvl(trunc(ta.actual_date), '01.01.1900') < trunc(p_actual_date);
    
    END IF;
  
  END actual_altnames_to_db;
  /***********************************************************************************************/
  PROCEDURE actual_doma_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  ) IS
    pv_cnt     NUMBER;
    v_continue BOOLEAN;
  BEGIN
    /**********************/
    dbms_application_info.set_client_info('Собираем статистику по T_DOMA');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_DOMA', cascade => TRUE);
    dbms_application_info.set_client_info('Собираем статистику по T_DOMA_ORIG');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_DOMA_ORIG', cascade => TRUE);
    /***********************/
    dbms_application_info.set_client_info('Актуализация T_DOMA');
    SELECT COUNT(*)
      INTO pv_cnt
      FROM ins.t_doma_orig do
     WHERE do.load_id = p_load_id
       AND do.load_name = p_file_name
       AND do.is_actual = 0;
    IF pv_cnt > 0
    THEN
      v_continue := TRUE;
    ELSE
      v_continue := FALSE;
    END IF;
    /***step_1 step_4*******/
    IF v_continue
    THEN
      /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                                change_type,
                                                code,
                                                new_value,
                                                old_value,
                                                table_name,
                                                user_id)
      SELECT TRUNC(SYSDATE),
             2,\*отредактирована*\
             ddo.code,
             'Полное совпадение в T_DOMA: '||
             ddo.name||
             ','||ddo.socr||
             ','||ddo.korp||
             ','||ddo.code||
             ','||ddo.pindex||
             ','||ddo.gninmb||
             ','||ddo.uno||
             ','||ddo.ocatd||
             ','||do.add_date||
             ','||do.edit_date||
             ','||TRUNC(P_ACTUAL_DATE)||
             ','||do.not_in_kladr,
             do.name||
             ','||do.socr||
             ','||do.korp||
             ','||do.code||
             ','||do.pindex||
             ','||do.gninmb||
             ','||do.uno||
             ','||do.ocatd||
             ','||do.add_date||
             ','||do.edit_date||
             ','||do.actual_date||
             ','||do.not_in_kladr,
             'T_DOMA',
             (SELECT us.sys_user_id
             FROM ins.sys_user us
             WHERE us.sys_user_name = USER)
      FROM ins.t_doma do,
           ins.t_doma_orig ddo
      WHERE ddo.code = do.code
        AND ddo.load_id = P_LOAD_ID
        AND ddo.load_name = P_FILE_NAME
        AND ddo.is_actual = 0
        AND do.name = ddo.name
        AND do.socr = ddo.socr
        AND NVL(do.korp,'X') = NVL(ddo.korp,'X')
        AND NVL(do.pindex,'X') = NVL(ddo.pindex,'X')
        AND NVL(do.gninmb,'X') = NVL(ddo.gninmb,'X')
        AND NVL(do.uno,'X') = NVL(ddo.uno,'X')
        AND NVL(do.ocatd,'X') = NVL(ddo.ocatd,'X');*/
    
      UPDATE ins.t_doma dod
         SET dod.actual_date = trunc(p_actual_date)
       WHERE EXISTS (SELECT NULL
                FROM ins.t_doma_orig do
               WHERE dod.name = do.name
                 AND dod.socr = do.socr
                 AND dod.code = do.code
                 AND nvl(dod.korp, 'X') = nvl(do.korp, 'X')
                 AND nvl(dod.pindex, 'X') = nvl(do.pindex, 'X')
                 AND nvl(dod.gninmb, 'X') = nvl(do.gninmb, 'X')
                 AND nvl(dod.uno, 'X') = nvl(do.uno, 'X')
                 AND nvl(dod.ocatd, 'X') = nvl(do.ocatd, 'X')
                 AND do.load_id = p_load_id
                 AND do.load_name = p_file_name
                 AND do.is_actual = 0);
    
      IF SQL%ROWCOUNT < pv_cnt
      THEN
        /***step_5*******/
        INSERT INTO ins.ven_update_journal_kladr
          (change_date, change_type, code, new_value, old_value, table_name, user_id)
          SELECT trunc(SYSDATE)
                ,2
                , /*отредактирована*/ddo.code
                ,'Совпадение по кодам КЛАДР в T_DOMA: ' || ddo.name || ',' || ddo.socr || ',' ||
                 ddo.korp || ',' || ddo.code || ',' || ddo.pindex || ',' || ddo.gninmb || ',' ||
                 ddo.uno || ',' || ddo.ocatd || ',' || do.add_date || ',' || trunc(SYSDATE) || ',' ||
                 trunc(p_actual_date) || ',' || do.not_in_kladr
                ,do.name || ',' || do.socr || ',' || do.korp || ',' || do.code || ',' || do.pindex || ',' ||
                 do.gninmb || ',' || do.uno || ',' || do.ocatd || ',' || do.add_date || ',' ||
                 do.edit_date || ',' || do.actual_date || ',' || do.not_in_kladr
                ,'T_DOMA'
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.t_doma      do
                ,ins.t_doma_orig ddo
           WHERE ddo.code = do.code
             AND ddo.load_id = p_load_id
             AND ddo.load_name = p_file_name
             AND ddo.is_actual = 0
             AND (do.name != ddo.name OR do.socr != ddo.socr OR
                 nvl(do.korp, 'X') != nvl(ddo.korp, 'X') OR
                 nvl(do.pindex, 'X') != nvl(ddo.pindex, 'X') OR
                 nvl(do.gninmb, 'X') != nvl(ddo.gninmb, 'X') OR nvl(do.uno, 'X') != nvl(ddo.uno, 'X') OR
                 nvl(do.ocatd, 'X') != nvl(ddo.ocatd, 'X'));
        /***step_2 step_4*******/
        UPDATE ins.t_doma do
           SET (do.code
              ,do.korp
              ,do.name
              ,do.socr
              ,do.pindex
              ,do.gninmb
              ,do.uno
              ,do.ocatd
              ,do.edit_date
              ,do.actual_date
              ,do.parse_name) =
               (SELECT dod.code
                      ,dod.korp
                      ,dod.name
                      ,dod.socr
                      ,dod.pindex
                      ,dod.gninmb
                      ,dod.uno
                      ,dod.ocatd
                      ,trunc(SYSDATE)
                      ,trunc(p_actual_date)
                      ,dod.parse_name
                  FROM ins.t_doma_orig dod
                 WHERE dod.code = do.code
                   AND dod.load_id = p_load_id
                   AND dod.load_name = p_file_name
                   AND dod.is_actual = 0
                   AND (do.name != dod.name OR do.socr != dod.socr OR
                       nvl(do.korp, 'X') != nvl(dod.korp, 'X') OR
                       nvl(do.pindex, 'X') != nvl(dod.pindex, 'X') OR
                       nvl(do.gninmb, 'X') != nvl(dod.gninmb, 'X') OR
                       nvl(do.uno, 'X') != nvl(dod.uno, 'X') OR
                       nvl(do.ocatd, 'X') != nvl(dod.ocatd, 'X')))
         WHERE EXISTS (SELECT NULL
                  FROM ins.t_doma_orig od
                 WHERE od.code = do.code
                   AND od.load_id = p_load_id
                   AND od.load_name = p_file_name
                   AND od.is_actual = 0
                   AND (do.name != od.name OR do.socr != od.socr OR
                       nvl(do.korp, 'X') != nvl(od.korp, 'X') OR
                       nvl(do.pindex, 'X') != nvl(od.pindex, 'X') OR
                       nvl(do.gninmb, 'X') != nvl(od.gninmb, 'X') OR
                       nvl(do.uno, 'X') != nvl(od.uno, 'X') OR
                       nvl(do.ocatd, 'X') != nvl(od.ocatd, 'X')));
        /***step_3 step_4*******/
        INSERT ALL INTO ins.t_doma
          (t_doma_id
          ,ent_id
          ,add_date
          ,NAME
          ,korp
          ,socr
          ,code
          ,pindex
          ,gninmb
          ,uno
          ,ocatd
          ,actual_date
          ,parse_name)
        VALUES
          (sq_t_doma.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'T_DOMA')
          ,trunc(SYSDATE)
          ,NAME
          ,korp
          ,socr
          ,code
          ,pindex
          ,gninmb
          ,uno
          ,ocatd
          ,trunc(p_actual_date)
          ,parse_name) INTO ins.update_journal_kladr
          (update_journal_kladr_id
          ,ent_id
          ,change_date
          ,change_type
          ,code
          ,new_value
          ,old_value
          ,table_name
          ,user_id)
        
        VALUES
          (sq_update_journal_kladr.nextval
          ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'UPDATE_JOURNAL_KLADR')
          ,trunc(SYSDATE)
          ,1
          , /*добавлена*/code
          ,'Добавление новых записей в T_DOMA: ' || NAME || ',' || socr || ',' || korp || ',' || code || ',' ||
           pindex || ',' || gninmb || ',' || uno || ',' || ocatd || ',' || trunc(SYSDATE) || ',' ||
           trunc(p_actual_date)
          ,''
          ,'T_DOMA'
          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER))
          SELECT trunc(SYSDATE)
                ,ddo.name
                ,ddo.korp
                ,ddo.socr
                ,ddo.code
                ,ddo.pindex
                ,ddo.gninmb
                ,ddo.uno
                ,ddo.ocatd
                ,trunc(p_actual_date)
                ,ddo.parse_name
                ,ddo.load_date
            FROM ins.t_doma_orig ddo
           WHERE NOT EXISTS (SELECT NULL FROM ins.t_doma do WHERE do.code = ddo.code)
             AND ddo.load_id = p_load_id
             AND ddo.load_name = p_file_name
             AND ddo.is_actual = 0;
        /***step_5*******/
        /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                              change_type,
                                              code,
                                              new_value,
                                              old_value,
                                              table_name,
                                              user_id)
        SELECT SYSDATE,
               1,\*добавлена*\
               ddo.code,
               'Наименование '||ddo.name||
               ';Сокращение '||ddo.socr||
               ';Корпус '||ddo.korp||
               ';Индекс '||ddo.pindex||
               ';Код '||ddo.code||
               ';Дата загрузки'||ddo.load_date,
               '', 
               'T_DOMA',
               (SELECT us.sys_user_id
                FROM ins.sys_user us
                WHERE us.sys_user_name = USER)
        FROM ins.t_doma_orig ddo
        WHERE NOT EXISTS (SELECT NULL
                          FROM ins.t_doma do
                          WHERE do.code = ddo.code)
          AND ddo.load_id = P_LOAD_ID
          AND ddo.load_name = P_FILE_NAME;*/
      END IF;
      /*************************/
      INSERT INTO ins.ven_update_journal_kladr
        (change_date, change_type, code, new_value, old_value, table_name, user_id)
        SELECT trunc(SYSDATE)
              ,2
              , /*отредактирована*/do.code
              ,'Обновление дат редактирования и актуализации в T_DOMA: ' || do.name || ',' || do.socr || ',' ||
               do.korp || ',' || do.code || ',' || do.pindex || ',' || do.gninmb || ',' || do.uno || ',' ||
               do.ocatd || ',' || do.add_date || ',' || trunc(SYSDATE) || ',' || trunc(p_actual_date) || ',1'
              ,do.name || ',' || do.socr || ',' || do.korp || ',' || do.code || ',' || do.pindex || ',' ||
               do.gninmb || ',' || do.uno || ',' || do.ocatd || ',' || do.add_date || ',' ||
               do.edit_date || ',' || do.actual_date || ',' || do.not_in_kladr
              ,'T_DOMA'
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.t_doma do
         WHERE trunc(do.actual_date) < trunc(p_actual_date)
           AND do.not_in_kladr = 0;
    
      UPDATE ins.t_doma_orig do
         SET do.is_actual = 1
       WHERE do.load_id = p_load_id
         AND do.load_name = p_file_name
         AND do.is_actual = 0;
    
      UPDATE ins.t_doma do
         SET do.not_in_kladr = 1
            ,do.edit_date    = trunc(SYSDATE)
            ,do.actual_date  = trunc(p_actual_date)
       WHERE nvl(trunc(do.actual_date), '01.01.1900') < trunc(p_actual_date);
    
    END IF;
  
  END actual_doma_to_db;
  /***********************************************************************************************/
  PROCEDURE actual_socrbase_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  ) IS
  BEGIN
    /**********************/
    dbms_application_info.set_client_info('Собираем статистику по T_SOCRBASE');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_SOCRBASE', cascade => TRUE);
    /***********************/
    dbms_application_info.set_client_info('Актуализация T_SOCRBASE');
    FOR cur IN (SELECT so.plevel
                      ,so.scname
                      ,so.socrname
                      ,so.kod_t_st
                      ,so.load_date
                  FROM ins.t_socrbase_orig so
                 WHERE so.load_id = p_load_id
                   AND so.load_name = p_file_name
                   AND so.is_actual = 0
                
                )
    LOOP
      /***step_1 step_4*******/
      /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                                change_type,
                                                code,
                                                new_value,
                                                old_value,
                                                table_name,
                                                user_id)
      SELECT TRUNC(SYSDATE),
             2,\*отредактирована*\
             cur.kod_t_st,
             'Полное совпадение в T_SOCR: '||
             cur.plevel||
             ','||cur.scname||
             ','||cur.socrname||
             ','||cur.kod_t_st||
             ','||ts.add_date||
             ','||ts.edit_date||
             ','||TRUNC(P_ACTUAL_DATE)||
             ','||ts.not_in_kladr,
             ts.plevel||
             ','||ts.scname||
             ','||ts.socrname||
             ','||ts.kod_t_st||
             ','||ts.add_date||
             ','||ts.edit_date||
             ','||ts.actual_date||
             ','||ts.not_in_kladr,
             'T_SOCR',
             (SELECT us.sys_user_id
             FROM ins.sys_user us
             WHERE us.sys_user_name = USER)
      FROM ins.t_socrbase ts
      WHERE ts.plevel = cur.plevel
        AND ts.scname = cur.scname
        AND ts.socrname = cur.socrname
        AND ts.kod_t_st = cur.kod_t_st;*/
    
      UPDATE ins.t_socrbase ts
         SET ts.actual_date = trunc(p_actual_date)
       WHERE ts.plevel = cur.plevel
         AND ts.scname = cur.scname
         AND ts.socrname = cur.socrname
         AND ts.kod_t_st = cur.kod_t_st;
    
      /***step_5*******/
      INSERT INTO ins.ven_update_journal_kladr
        (change_date, change_type, code, new_value, old_value, table_name, user_id)
        SELECT trunc(SYSDATE)
              ,2
              , /*отредактирована*/cur.kod_t_st
              ,'Совпадение по кодам КЛАДР в T_SOCR: ' || cur.plevel || ',' || cur.scname || ',' ||
               cur.socrname || ',' || cur.kod_t_st || ',' || ts.add_date || ',' || trunc(SYSDATE) || ',' ||
               trunc(p_actual_date) || ',' || ts.not_in_kladr
              ,ts.plevel || ',' || ts.scname || ',' || ts.socrname || ',' || ts.kod_t_st || ',' ||
               ts.add_date || ',' || ts.edit_date || ',' || ts.actual_date || ',' || ts.not_in_kladr
              ,'T_SOCR'
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.t_socrbase ts
         WHERE ts.kod_t_st = cur.kod_t_st
           AND (ts.plevel != cur.plevel OR ts.scname != cur.scname OR ts.socrname != cur.socrname);
      /***step_2 step_4*******/
      UPDATE ins.t_socrbase ts
         SET ts.plevel      = cur.plevel
            ,ts.scname      = cur.scname
            ,ts.socrname    = cur.socrname
            ,ts.kod_t_st    = cur.kod_t_st
            ,ts.edit_date   = trunc(SYSDATE)
            ,ts.actual_date = trunc(p_actual_date)
       WHERE ts.kod_t_st = cur.kod_t_st
         AND (ts.plevel != cur.plevel OR ts.scname != cur.scname OR ts.socrname != cur.socrname);
    END LOOP;
    /***step_3 step_4*******/
    INSERT ALL INTO ins.t_socrbase
      (t_socrbase_id, ent_id, add_date, plevel, scname, socrname, kod_t_st, actual_date)
    VALUES
      (sq_t_socrbase.nextval
      ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'T_SOCRBASE')
      ,trunc(SYSDATE)
      ,plevel
      ,scname
      ,socrname
      ,kod_t_st
      ,trunc(p_actual_date)) INTO ins.update_journal_kladr
      (update_journal_kladr_id
      ,ent_id
      ,change_date
      ,change_type
      ,code
      ,new_value
      ,old_value
      ,table_name
      ,user_id)
    
    VALUES
      (sq_update_journal_kladr.nextval
      ,(SELECT e.ent_id FROM ins.entity e WHERE e.brief = 'UPDATE_JOURNAL_KLADR')
      ,trunc(SYSDATE)
      ,1
      , /*добавлена*/kod_t_st
      ,'Добавление новых записей в T_SOCR: ' || plevel || ',' || scname || ',' || socrname || ',' ||
       kod_t_st || ',' || trunc(SYSDATE) || ',' || trunc(p_actual_date)
      ,''
      ,'T_SOCR'
      ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER))
      SELECT tso.plevel   plevel
            ,tso.scname   scname
            ,tso.socrname socrname
            ,tso.kod_t_st kod_t_st
        FROM ins.t_socrbase_orig tso
       WHERE NOT EXISTS (SELECT NULL
                FROM ins.t_socrbase ts
               WHERE ts.kod_t_st = tso.kod_t_st
                 AND ts.plevel = tso.plevel
                 AND ts.scname = tso.scname
                 AND ts.socrname = tso.socrname);
  
    /*************************/
    INSERT INTO ins.ven_update_journal_kladr
      (change_date, change_type, code, new_value, old_value, table_name, user_id)
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/ts.kod_t_st
            ,'Обновление дат редактирования и актуализации в T_SOCR: ' || ts.plevel || ',' ||
             ts.scname || ',' || ts.socrname || ',' || ts.kod_t_st || ',' || ts.add_date || ',' ||
             trunc(SYSDATE) || ',' || trunc(p_actual_date) || ',1'
            ,ts.plevel || ',' || ts.scname || ',' || ts.socrname || ',' || ts.kod_t_st || ',' ||
             ts.add_date || ',' || ts.edit_date || ',' || ts.actual_date || ',' || ts.not_in_kladr
            ,'T_SOCR'
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.t_socrbase ts
       WHERE trunc(ts.actual_date) < trunc(p_actual_date)
         AND ts.not_in_kladr = 0;
  
    UPDATE ins.t_socrbase_orig so
       SET so.is_actual = 1
     WHERE so.load_id = p_load_id
       AND so.load_name = p_file_name
       AND so.is_actual = 0;
  
    UPDATE ins.t_socrbase ts
       SET ts.not_in_kladr = 1
          ,ts.edit_date    = trunc(SYSDATE)
          ,ts.actual_date  = trunc(p_actual_date)
     WHERE nvl(trunc(ts.actual_date), '01.01.1900') < trunc(p_actual_date);
  
  END actual_socrbase_to_db;
  /***********************************************************************************************/
  PROCEDURE actual_npindx_to_db
  (
    p_load_id     NUMBER
   ,p_file_name   VARCHAR2
   ,p_actual_date DATE
  ) IS
  BEGIN
  
    /*******************/
    dbms_application_info.set_client_info('Собираем статистику по T_NPINDX');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'T_NPINDX', cascade => TRUE);
    /******************/
    dbms_application_info.set_client_info('Актуализация T_NPINDX');
    FOR cur IN (SELECT tn.pindex
                      ,tn.pnindex
                      ,tn.nactdate
                      ,tn.load_date /*,
                                                                                                                    tn.nopsname, 
                                                                                                                    tn.nopstype, 
                                                                                                                    tn.nopssubm, 
                                                                                                                    tn.nregion, 
                                                                                                                    tn.nautonom, 
                                                                                                                    tn.narea, 
                                                                                                                    tn.ncity, 
                                                                                                                    tn.ncity1,
                                                                                                                    tn.npindexold*/
                  FROM ins.t_npindx_orig tn
                 WHERE tn.load_id = p_load_id
                   AND tn.load_name = p_file_name
                   AND tn.is_actual = 0)
    LOOP
      /*INSERT INTO ins.ven_update_journal_kladr (change_date,
                                                change_type,
                                                code,
                                                new_value,
                                                old_value,
                                                table_name,
                                                user_id)
      SELECT TRUNC(SYSDATE),
             2,\*отредактирована*\
             cur.pindex,
             'Полное совпадение в T_NPINDX: '||
             \*'Измененный (удаленны) почтовый индекс '||*\cur.pindex||
             \*';Обновленное (добавленное) значение почтового индекса '*\','||cur.pnindex||
             \*';Дата обновления информации об объекте почтовой связи '*\','||cur.nactdate||
             ','||tno.add_date||
             ','||tno.edit_date||
             ','||TRUNC(P_ACTUAL_DATE),
             tno.pindex||
             ','||tno.pnindex||
             ','||tno.nactdate||
             ','||tno.add_date||
             ','||tno.edit_date||
             ','||tno.actual_date,
             'T_NPINDX',
             (SELECT us.sys_user_id
             FROM ins.sys_user us
             WHERE us.sys_user_name = USER)
      FROM ins.t_npindx tno
      WHERE tno.pindex = cur.pindex 
        AND tno.pnindex = cur.pnindex
        AND NVL(tno.nactdate,'01.01.1900') = NVL(cur.nactdate,'01.01.1900');*/
    
      UPDATE ins.t_npindx tno
         SET tno.actual_date = trunc(p_actual_date)
            ,tno.edit_date   = trunc(SYSDATE)
       WHERE tno.pindex = cur.pindex
         AND tno.pnindex = cur.pnindex
         AND nvl(tno.nactdate, '01.01.1900') = nvl(cur.nactdate, '01.01.1900');
    
      IF SQL%ROWCOUNT = 0
      THEN
        INSERT INTO ins.ven_t_npindx
          (add_date, nactdate, pindex, pnindex, actual_date)
        VALUES
          (trunc(SYSDATE), cur.nactdate, cur.pindex, cur.pnindex, trunc(p_actual_date));
        INSERT INTO ins.ven_update_journal_kladr
          (change_date, change_type, code, new_value, old_value, table_name, user_id)
        VALUES
          (trunc(SYSDATE)
          ,1
          , /*добавлена*/cur.pindex
          ,'Добавление новых записей в T_NPINDX: ' || cur.pindex || ',' || cur.pnindex || ',' ||
           cur.nactdate || ',' || trunc(SYSDATE) || ',' || trunc(p_actual_date)
          ,''
          ,'T_NPINDX'
          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER));
      END IF;
    END LOOP;
  
    UPDATE ins.t_npindx_orig tn
       SET tn.is_actual = 1
     WHERE tn.load_id = p_load_id
       AND tn.load_name = p_file_name
       AND tn.is_actual = 0;
  
  END actual_npindx_to_db;
  /**********************************************************************************/
  PROCEDURE marking_address_kladr IS
  
  BEGIN
    /********************/
    dbms_application_info.set_client_info('Собираем статистику по ACTUAL_JOURNAL_ADR');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'ACTUAL_JOURNAL_ADR', cascade => TRUE);
    /******KLADR*********/
    dbms_application_info.set_client_info('Маркировка T_KLADR');
    INSERT INTO ins.ven_actual_journal_adr
      (change_date, change_type, id_adress, new_value, old_value, user_id)
    
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/cac.id
            ,
             /*'Актульность: '||*/'0' || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' ||
             cac.region_name || ',' || cac.city_type || ',' || cac.city_name || ',' ||
             cac.district_type || ',' || cac.district_name || ',' ||
             cac.street_type || ',' || cac.street_name || ',' || cac.house_type || ',' ||
             cac.house_nr
            ,cac.actual || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' || cac.region_name || ',' ||
             cac.city_type || ',' || cac.city_name || ',' || cac.district_type || ',' ||
             cac.district_name || ',' || cac.street_type || ',' || cac.street_name || ',' ||
             cac.house_type || ',' || cac.house_nr
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.cn_address cac
            ,ins.t_kladr    tk
       WHERE cac.code = tk.code
         AND cac.actual = 1
         AND trunc(tk.edit_date) = trunc(SYSDATE);
  
    UPDATE ins.cn_address ca
       SET ca.actual = 0
     WHERE EXISTS (SELECT NULL
              FROM ins.t_kladr tk
             WHERE ca.code = tk.code
               AND trunc(tk.edit_date) = trunc(SYSDATE))
       AND ca.actual = 1;
    /****STREET****************/
    dbms_application_info.set_client_info('Маркировка T_STREET');
    INSERT INTO ins.ven_actual_journal_adr
      (change_date, change_type, id_adress, new_value, old_value, user_id)
    
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/cac.id
            ,
             /*'Актульность: '||*/'0' || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' ||
             cac.region_name || ',' || cac.city_type || ',' || cac.city_name || ',' ||
             cac.district_type || ',' || cac.district_name || ',' ||
             cac.street_type || ',' || cac.street_name || ',' || cac.house_type || ',' ||
             cac.house_nr
            ,cac.actual || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' || cac.region_name || ',' ||
             cac.city_type || ',' || cac.city_name || ',' || cac.district_type || ',' ||
             cac.district_name || ',' || cac.street_type || ',' || cac.street_name || ',' ||
             cac.house_type || ',' || cac.house_nr
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.cn_address cac
            ,ins.t_street   st
       WHERE cac.code = st.code
         AND cac.actual = 1
         AND trunc(st.edit_date) = trunc(SYSDATE);
  
    UPDATE ins.cn_address ca
       SET ca.actual = 0
     WHERE EXISTS (SELECT NULL
              FROM ins.t_street st
             WHERE ca.code = st.code
               AND trunc(st.edit_date) = trunc(SYSDATE))
       AND ca.actual = 1;
  
    /*******DOMA****************/
    dbms_application_info.set_client_info('Маркировка T_DOMA');
    INSERT INTO ins.ven_actual_journal_adr
      (change_date, change_type, id_adress, new_value, old_value, user_id)
    
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/cac.id
            ,
             /*'Актульность: '||*/'0' || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' ||
             cac.region_name || ',' || cac.city_type || ',' || cac.city_name || ',' ||
             cac.district_type || ',' || cac.district_name || ',' ||
             cac.street_type || ',' || cac.street_name || ',' || cac.house_type || ',' ||
             cac.house_nr
            ,cac.actual || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' || cac.region_name || ',' ||
             cac.city_type || ',' || cac.city_name || ',' || cac.district_type || ',' ||
             cac.district_name || ',' || cac.street_type || ',' || cac.street_name || ',' ||
             cac.house_type || ',' || cac.house_nr
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.cn_address cac
            ,ins.t_doma     td
       WHERE cac.code = td.code
         AND cac.actual = 1
         AND trunc(td.edit_date) = trunc(SYSDATE);
  
    UPDATE ins.cn_address ca
       SET ca.actual = 0
     WHERE EXISTS (SELECT NULL
              FROM ins.t_doma td
             WHERE ca.code = td.code
               AND trunc(td.edit_date) = trunc(SYSDATE))
       AND ca.actual = 1;
  
    /*****ALTNAMES*********/
    dbms_application_info.set_client_info('Маркировка T_ALTNAMES');
    INSERT INTO ins.ven_actual_journal_adr
      (change_date, change_type, id_adress, new_value, old_value, user_id)
    
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/cac.id
            ,
             /*'Актульность: '||*/'0' || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ', ' ||
             cac.province_name || ',' || cac.region_type || ',' ||
             cac.region_name || ',' || cac.city_type || ',' || cac.city_name || ',' ||
             cac.district_type || ',' || cac.district_name || ',' ||
             cac.street_type || ',' || cac.street_name || ',' || cac.house_type || ',' ||
             cac.house_nr
            ,cac.actual || ',' || cac.code || ',' || cac.zip || ';Тип региона ' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' || cac.region_name || ',' ||
             cac.city_type || ',' || cac.city_name || ',' || cac.district_type || ',' ||
             cac.district_name || ',' || cac.street_type || ',' || cac.street_name || ',' ||
             cac.house_type || ',' || cac.house_nr
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.cn_address cac
            ,ins.t_altnames at
       WHERE cac.code = at.oldcode
         AND cac.actual = 1
         AND trunc(at.edit_date) = trunc(SYSDATE);
  
    UPDATE ins.cn_address ca
       SET ca.actual = 0
     WHERE EXISTS (SELECT NULL
              FROM ins.t_altnames at
             WHERE ca.code = at.oldcode
               AND trunc(at.edit_date) = trunc(SYSDATE))
       AND ca.actual = 1;
  
    /*****ALTNAMES********/
    INSERT INTO ins.ven_actual_journal_adr
      (change_date, change_type, id_adress, new_value, old_value, user_id)
    
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/cac.id
            ,
             /*'Актульность: '||*/'0' || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' ||
             cac.region_name || ',' || cac.city_type || ',' || cac.city_name || ',' ||
             cac.district_type || ',' || cac.district_name || ',' ||
             cac.street_type || ',' || cac.street_name || ',' || cac.house_type || ',' ||
             cac.house_nr
            ,cac.actual || ',' || cac.code || ',' || cac.zip || ';,' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' || cac.region_name || ',' ||
             cac.city_type || ',' || cac.city_name || ',' || cac.district_type || ',' ||
             cac.district_name || ',' || cac.street_type || ',' || cac.street_name || ',' ||
             cac.house_type || ',' || cac.house_nr
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.cn_address cac
            ,ins.t_altnames at
       WHERE cac.code = at.oldcode
         AND cac.actual = 1
         AND trunc(at.add_date) = trunc(SYSDATE);
  
    UPDATE ins.cn_address ca
       SET ca.actual = 0
     WHERE EXISTS (SELECT NULL
              FROM ins.t_altnames at
             WHERE ca.code = at.oldcode
               AND trunc(at.add_date) = trunc(SYSDATE))
       AND ca.actual = 1;
  
    /*****NPINDX*******************/
    dbms_application_info.set_client_info('Маркировка T_NPINDX');
    INSERT INTO ins.ven_actual_journal_adr
      (change_date, change_type, id_adress, new_value, old_value, user_id)
    
      SELECT trunc(SYSDATE)
            ,2
            , /*отредактирована*/cac.id
            ,
             /*'Актульность: '||*/'0' || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' ||
             cac.region_name || ',' || cac.city_type || ',' || cac.city_name || ',' ||
             cac.district_type || ',' || cac.district_name || ',' ||
             cac.street_type || ',' || cac.street_name || ',' || cac.house_type || ',' ||
             cac.house_nr
            ,cac.actual || ',' || cac.code || ',' || cac.zip || ',' || cac.province_type || ',' ||
             cac.province_name || ',' || cac.region_type || ',' || cac.region_name || ',' ||
             cac.city_type || ',' || cac.city_name || ',' || cac.district_type || ',' ||
             cac.district_name || ',' || cac.street_type || ',' || cac.street_name || ',' ||
             cac.house_type || ',' || cac.house_nr
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.cn_address cac
            ,ins.t_npindx   tn
       WHERE cac.actual = 1
         AND nvl(tn.pindex, 'X') = nvl(cac.zip, 'X')
         AND trunc(tn.add_date) = trunc(SYSDATE);
  
    UPDATE ins.cn_address cac
       SET cac.actual = 0
     WHERE EXISTS (SELECT NULL
              FROM ins.t_npindx tn
             WHERE nvl(tn.pindex, 'X') = nvl(cac.zip, 'X')
               AND trunc(tn.add_date) = trunc(SYSDATE))
       AND cac.actual = 1;
  
    /************************/
    dbms_application_info.set_client_info('Маркировка. Установка признака NOT_IN_KLADR');
    INSERT INTO ins.ven_update_journal_kladr
      (change_date, change_type, code, old_value, table_name, user_id)
      SELECT trunc(SYSDATE)
            ,3
            , /*удалена*/kl.code
            ,kl.name || ',' || kl.socr || ',' || kl.code || ',' || kl.pindex || ',' || kl.gninmb || ',' ||
             kl.uno || ',' || kl.ocatd || ',' || kl.status || ',' || kl.add_date || ',' ||
             kl.edit_date || ',' || kl.not_in_kladr
            ,'T_KLADR'
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.t_kladr kl
       WHERE nvl(kl.not_in_kladr, 0) = 1;
  
    DELETE FROM ins.t_kladr kl WHERE nvl(kl.not_in_kladr, 0) = 1;
    /**/
    INSERT INTO ins.ven_update_journal_kladr
      (change_date, change_type, code, old_value, table_name, user_id)
      SELECT trunc(SYSDATE)
            ,3
            , /*удалена*/st.code
            ,st.name || ',' || st.socr || ',' || st.code || ',' || st.pindex || ',' || st.gninmb || ',' ||
             st.uno || ',' || st.ocatd || ',' || st.add_date || ',' || st.edit_date || ',' ||
             st.not_in_kladr
            ,'T_STREET'
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.t_street st
       WHERE nvl(st.not_in_kladr, 0) = 1;
  
    DELETE FROM ins.t_street st WHERE nvl(st.not_in_kladr, 0) = 1;
    /**/
    INSERT INTO ins.ven_update_journal_kladr
      (change_date, change_type, code, old_value, table_name, user_id)
      SELECT trunc(SYSDATE)
            ,3
            , /*удалена*/td.code
            ,td.name || ',' || td.socr || ',' || td.korp || ',' || td.code || ',' || td.pindex || ',' ||
             td.gninmb || ',' || td.uno || ',' || td.ocatd || ',' || td.add_date || ',' ||
             td.edit_date || ',' || td.not_in_kladr
            ,'T_DOMA'
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.t_doma td
       WHERE nvl(td.not_in_kladr, 0) = 1;
  
    DELETE FROM ins.t_doma td WHERE nvl(td.not_in_kladr, 0) = 1;
    /**/
    INSERT INTO ins.ven_update_journal_kladr
      (change_date, change_type, code, old_value, table_name, user_id)
      SELECT trunc(SYSDATE)
            ,3
            , /*удалена*/at.oldcode
            ,at.oldcode || ',' || at.newcode || ',' || at.plevel || ',' || at.add_date || ',' ||
             at.edit_date || ',' || at.not_in_kladr
            ,'T_ALT'
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.t_altnames at
       WHERE nvl(at.not_in_kladr, 0) = 1;
  
    DELETE FROM ins.t_altnames at WHERE nvl(at.not_in_kladr, 0) = 1;
    /**/
    INSERT INTO ins.ven_update_journal_kladr
      (change_date, change_type, code, old_value, table_name, user_id)
      SELECT trunc(SYSDATE)
            ,3
            , /*удалена*/sc.scname
            ,sc.socrname || ',' || sc.scname || ',' || sc.plevel || ',' || sc.kod_t_st || ',' ||
             sc.add_date || ',' || sc.edit_date || ',' || sc.not_in_kladr
            ,'T_SOCR'
            ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
        FROM ins.t_socrbase sc
       WHERE nvl(sc.not_in_kladr, 0) = 1;
  
    DELETE FROM ins.t_socrbase sc WHERE nvl(sc.not_in_kladr, 0) = 1;
    /**/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении MARKING_ADDRESS_KLADR ' || SQLERRM);
  END marking_address_kladr;
  /*********************************************************/
  /*Процедура Актуализация адресов
   Фактических
   Не Фактических
  */
  PROCEDURE actual_addr
  (
    par_date    DATE DEFAULT NULL
   ,p_adress_id NUMBER DEFAULT NULL
  ) IS
    v_adr_id_new  NUMBER;
    var_adr_id    NUMBER;
    v_is_commit   NUMBER := 0;
    v_for_update  NUMBER := 0;
    v_actual_date DATE;
  BEGIN
    IF par_date IS NULL
    THEN
      SELECT nvl(MAX(jkl.change_date), SYSDATE) INTO v_actual_date FROM ins.update_journal_kladr jkl;
    ELSE
      v_actual_date := par_date;
    END IF;
    /********************/
    /*dbms_application_info.set_client_info('Собираем статистику по ACTUAL_JOURNAL_ADR и CN_ADDRESS');
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'ACTUAL_JOURNAL_ADR', cascade => TRUE);
    dbms_stats.gather_table_stats(ownname => 'INS', tabname => 'CN_ADDRESS', cascade => TRUE);*/
    /******для не фактических адресов, у которых есть фактический, созданный на основании данного*********/
    dbms_application_info.set_client_info('Обновление даты актуальности в CN_ADDRESS');
    UPDATE ins.cn_address ca
       SET ca.actual_date = trunc(v_actual_date)
     WHERE EXISTS (SELECT NULL
              FROM ins.cn_contact_address cca
                  ,ins.t_address_type     tat
             WHERE ca.id = cca.adress_id
               AND cca.address_type = tat.id
               AND tat.brief NOT LIKE 'FK%'
               AND EXISTS
             (SELECT NULL FROM ins.cn_address caa WHERE caa.parent_addr_id = cca.adress_id))
       AND ((ca.actual = 0 OR ca.code IS NOT NULL) AND
           nvl(ca.actual_date, '01.01.1900') <
           nvl((SELECT MAX(uk.change_date) FROM ins.update_journal_kladr uk), '01.01.1900'))
       AND (p_adress_id IS NULL OR (p_adress_id IS NOT NULL AND ca.id = p_adress_id));
    COMMIT;
    /*****для фактических****************/
    dbms_application_info.set_client_info('Обновление Фактических');
    FOR cur IN (SELECT ca.id adr_id
                      ,ca.code
                      ,REPLACE(ca.house_nr, '\', '/') house_nr
                      ,ca.zip
                      ,ca.actual
                      ,ca.actual_date
                      ,ca.province_type
                      ,ca.province_name
                      ,ca.region_type
                      ,ca.region_name
                      ,ca.district_type
                      ,ca.district_name
                      ,ca.city_type
                      ,ca.city_name
                      ,ca.street_type
                      ,ca.street_name
                      ,ca.house_type
                  FROM ins.cn_address         ca
                      ,ins.cn_contact_address cca
                      ,ins.t_address_type     tat
                 WHERE (ca.actual = 0 OR
                       nvl(ca.actual_date, '01.01.1900') <=
                       nvl((SELECT MAX(uk.change_date) FROM ins.update_journal_kladr uk), '01.01.1900'))
                   AND ca.id = cca.adress_id
                   AND cca.address_type = tat.id
                   AND tat.brief LIKE 'FK%'
                   AND ca.decompos_permis = 1
                   AND ((p_adress_id IS NULL AND rownum <= 100) OR
                       (p_adress_id IS NOT NULL AND ca.id = p_adress_id))
                )
    LOOP
      BEGIN
        SELECT 1 INTO v_for_update FROM ins.cn_address ca WHERE ca.id = cur.adr_id FOR UPDATE;
      EXCEPTION
        WHEN no_data_found THEN
          v_for_update := 0;
      END;
      IF v_for_update != 0
      THEN
        v_is_commit := v_is_commit + 1;
        var_adr_id  := cur.adr_id;
        actual_algorithm(0
                        ,cur.code
                        ,cur.house_nr
                        ,cur.zip
                        ,cur.actual
                        ,cur.actual_date
                        ,cur.province_type
                        ,cur.province_name
                        ,cur.region_type
                        ,cur.region_name
                        ,cur.district_type
                        ,cur.district_name
                        ,cur.city_type
                        ,cur.city_name
                        ,cur.street_type
                        ,cur.street_name
                        ,cur.house_type
                        ,cur.adr_id
                        ,v_actual_date);
        IF v_is_commit = 100
        THEN
          COMMIT;
          v_is_commit := 0;
        END IF;
      END IF;
    END LOOP;
    COMMIT;
    v_is_commit := 0;
    /*****для не фактических****************/
    dbms_application_info.set_client_info('Обновление НЕ фактических');
    FOR cur IN (SELECT ca.id adr_id
                      ,ca.code
                      ,REPLACE(ca.house_nr, '\', '/') house_nr
                      ,ca.zip
                      ,ca.actual
                      ,ca.actual_date
                      ,ca.province_type
                      ,ca.province_name
                      ,ca.region_type
                      ,ca.region_name
                      ,ca.district_type
                      ,ca.district_name
                      ,ca.city_type
                      ,ca.city_name
                      ,ca.street_type
                      ,ca.street_name
                      ,ca.house_type
                  FROM ins.cn_address         ca
                      ,ins.cn_contact_address cca
                      ,ins.t_address_type     tat
                 WHERE (ca.actual = 0 OR nvl(ca.actual_date, to_date('01.01.1900', 'dd.mm.yyyy')) <=
                       (SELECT MAX(uk.change_date) FROM ins.update_journal_kladr uk))
                   AND ca.id = cca.adress_id
                   AND cca.address_type = tat.id
                   AND tat.brief NOT LIKE 'FK%'
                   AND ca.decompos_permis = 1
                   AND NOT EXISTS
                 (SELECT NULL FROM ins.cn_address caa WHERE caa.parent_addr_id = ca.id)
                   AND ((p_adress_id IS NULL AND rownum <= 100) OR
                       (p_adress_id IS NOT NULL AND ca.id = p_adress_id))
                )
    LOOP
      BEGIN
        SELECT 1 INTO v_for_update FROM ins.cn_address ca WHERE ca.id = cur.adr_id FOR UPDATE;
      EXCEPTION
        WHEN no_data_found THEN
          v_for_update := 0;
      END;
      IF v_for_update != 0
      THEN
        v_is_commit  := v_is_commit + 1;
        var_adr_id   := cur.adr_id;
        v_adr_id_new := pkg_kladr.create_fact_adr(cur.adr_id);
        UPDATE ins.cn_address ca SET ca.fact_addr_id = v_adr_id_new WHERE ca.id = cur.adr_id;
        /**/
        INSERT INTO ins.ven_actual_journal_adr
          (change_date, change_type, id_adress, new_value, note, old_value, user_id)
          SELECT trunc(SYSDATE)
                ,1
                , /*добавлена*/ca.id
                ,cur.actual || ',' || cur.actual_date || ',' || nvl(cur.code, 'NULL') || ',' ||
                 nvl(cur.zip, 'NULL') || ',' || nvl(cur.province_type, 'NULL') || ',' ||
                 nvl(cur.province_name, 'NULL') || ',' || nvl(cur.region_type, 'NULL') || ',' ||
                 nvl(cur.region_name, 'NULL') || ',' || nvl(cur.city_type, 'NULL') || ',' ||
                 nvl(cur.city_name, 'NULL') || ',' || nvl(cur.district_type, 'NULL') || ',' ||
                 nvl(cur.district_name, 'NULL') || ',' || nvl(cur.street_type, 'NULL') || ',' ||
                 nvl(cur.street_name, 'NULL') || ',' || nvl(cur.house_type, 'NULL') || ',' ||
                 nvl(cur.house_nr, 'NULL')
                ,'Ошибок нет'
                ,NULL
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.cn_address ca
           WHERE ca.id = v_adr_id_new;
        /**/
        /*****для фактических****************/
        dbms_application_info.set_client_info('Обновление созданного фактического');
        actual_algorithm(1
                        ,cur.code
                        ,cur.house_nr
                        ,cur.zip
                        ,cur.actual
                        ,cur.actual_date
                        ,cur.province_type
                        ,cur.province_name
                        ,cur.region_type
                        ,cur.region_name
                        ,cur.district_type
                        ,cur.district_name
                        ,cur.city_type
                        ,cur.city_name
                        ,cur.street_type
                        ,cur.street_name
                        ,cur.house_type
                        ,v_adr_id_new
                        ,v_actual_date);
        UPDATE ins.cn_address ca
           SET ca.name = ins.pkg_contact.get_address_name(ca.zip
                                                         ,(SELECT ctr.description
                                                            FROM ins.t_country ctr
                                                           WHERE ctr.id = ca.country_id)
                                                         ,ca.region_name
                                                         ,ca.region_type
                                                         ,ca.province_name
                                                         ,ca.province_type
                                                         ,ca.district_type
                                                         ,ca.district_name
                                                         ,ca.city_type
                                                         ,ca.city_name
                                                         ,ca.street_name
                                                         ,ca.street_type
                                                         ,ca.building_name
                                                         ,ca.house_nr
                                                         ,ca.block_number
                                                         ,ca.box_number
                                                         ,substr(ca.appartment_nr, 1, 9)
                                                         ,ca.house_type)
         WHERE ca.id = v_adr_id_new
           AND ca.code IS NOT NULL;
        /**/
        IF v_is_commit = 100
        THEN
          COMMIT;
          v_is_commit := 0;
        END IF;
      END IF;
    END LOOP;
    /*******************/
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ACTUAL_ADDR ' || SQLERRM || '; VAR_ADR_ID = ' ||
                              var_adr_id);
    
  END actual_addr;
  /*********************************************************/
  PROCEDURE actual_algorithm
  (
    p_type_adr      NUMBER /*0 - фактический, 1 - новый созданный фактический*/
   ,p_code_kladr    VARCHAR2
   ,p_house_num     VARCHAR2
   ,p_zip           VARCHAR2
   ,p_actual        NUMBER
   ,p_actual_date   DATE
   ,p_province_type VARCHAR2
   ,p_province_name VARCHAR2
   ,p_region_type   VARCHAR2
   ,p_region_name   VARCHAR2
   ,p_district_type VARCHAR2
   ,p_district_name VARCHAR2
   ,p_city_type     VARCHAR2
   ,p_city_name     VARCHAR2
   ,p_street_type   VARCHAR2
   ,p_street_name   VARCHAR2
   ,p_house_type    VARCHAR2
   ,p_adr_id        NUMBER
   ,p_date_actual   DATE
  ) IS
    v_out_number  NUMBER := 0;
    v_code        VARCHAR2(25);
    v_new_code    VARCHAR2(25);
    v_exists_code NUMBER := 0;
    v_exists_str  NUMBER;
    v_indx        VARCHAR2(25);
    v_continue    BOOLEAN := TRUE;
    v_length_code NUMBER;
    var_adr_id    NUMBER;
    v_level       NUMBER;
    v_lvladr      NUMBER;
    v_street_code VARCHAR2(250);
    v_region_code VARCHAR2(250);
    v_distr_code  VARCHAR2(250);
    v_city_code   VARCHAR2(250);
    PROCEDURE calc_length_code_17
    (
      p_p_code          VARCHAR2
     ,p_p_adr_id        NUMBER
     ,p_p_date_actual   DATE
     ,p_p_house_num     VARCHAR2
     ,p_p_zip           VARCHAR2
     ,p_p_actual        NUMBER
     ,p_p_actual_date   DATE
     ,p_p_province_type VARCHAR2
     ,p_p_province_name VARCHAR2
     ,p_p_region_type   VARCHAR2
     ,p_p_region_name   VARCHAR2
     ,p_p_district_type VARCHAR2
     ,p_p_district_name VARCHAR2
     ,p_p_city_type     VARCHAR2
     ,p_p_city_name     VARCHAR2
     ,p_p_street_type   VARCHAR2
     ,p_p_street_name   VARCHAR2
     ,p_p_house_type    VARCHAR2
     ,p_p_type_adr      NUMBER
    );
    PROCEDURE calc_length_code_13
    (
      p_p_code          VARCHAR2
     ,p_p_adr_id        NUMBER
     ,p_p_date_actual   DATE
     ,p_p_house_num     VARCHAR2
     ,p_p_zip           VARCHAR2
     ,p_p_actual        NUMBER
     ,p_p_actual_date   DATE
     ,p_p_province_type VARCHAR2
     ,p_p_province_name VARCHAR2
     ,p_p_region_type   VARCHAR2
     ,p_p_region_name   VARCHAR2
     ,p_p_district_type VARCHAR2
     ,p_p_district_name VARCHAR2
     ,p_p_city_type     VARCHAR2
     ,p_p_city_name     VARCHAR2
     ,p_p_street_type   VARCHAR2
     ,p_p_street_name   VARCHAR2
     ,p_p_house_type    VARCHAR2
     ,p_p_type_adr      NUMBER
    ) IS
      v_exists_code    NUMBER := 0;
      v_new_code       VARCHAR2(25);
      v_continue       BOOLEAN := TRUE;
      v_code           VARCHAR2(25);
      v_indx           VARCHAR2(25);
      v_exit_procedure BOOLEAN := FALSE;
    BEGIN
      BEGIN
        /*SELECT 1
             ,kl.code
         INTO v_exists_code
             ,v_new_code
         FROM ins.t_kladr    kl
             ,ins.cn_address ca
        WHERE ca.id = p_p_adr_id
          AND kl.code = ca.code;*/
        SELECT 1
              ,kl.code
          INTO v_exists_code
              ,v_new_code
          FROM ins.t_kladr kl
         WHERE kl.code = p_p_code;
      EXCEPTION
        WHEN no_data_found THEN
          v_exists_code := 0;
          v_new_code    := '';
      END;
      IF v_exists_code = 1
      THEN
        v_continue := TRUE;
      ELSE
        v_continue := FALSE;
        v_new_code := ins.pkg_kladr.get_altnames_code(p_p_code);
        SELECT length(v_new_code) INTO v_length_code FROM dual;
        /*если код 5 или 6 уровня*/
        IF v_length_code >= 17
        THEN
          calc_length_code_17(v_new_code
                             ,p_p_adr_id
                             ,p_p_date_actual
                             ,p_p_house_num
                             ,p_p_zip
                             ,p_p_actual
                             ,p_p_actual_date
                             ,p_p_province_type
                             ,p_p_province_name
                             ,p_p_region_type
                             ,p_p_region_name
                             ,p_p_district_type
                             ,p_p_district_name
                             ,p_p_city_type
                             ,p_p_city_name
                             ,p_p_street_type
                             ,p_p_street_name
                             ,p_p_house_type
                             ,p_p_type_adr);
          v_exit_procedure := TRUE;
        ELSE
          v_exit_procedure := FALSE;
        END IF;
      
        IF v_new_code IS NOT NULL
        THEN
          v_exists_code := 1;
        ELSE
          v_exists_code := 0;
          v_new_code    := '';
        END IF;
        IF v_exists_code = 1
        THEN
          v_continue := TRUE;
        ELSE
          /*если искомый код 4 уровня*/
          IF substr(p_p_code, 9, 3) != '000'
          THEN
            BEGIN
              SELECT 1
                    ,substr(alt.newcode, 1, 11) || substr(p_p_code, 12)
                INTO v_exists_code
                    ,v_new_code
                FROM ins.t_altnames alt
               WHERE alt.oldcode = substr(p_p_code, 1, 11) || '00';
            EXCEPTION
              WHEN no_data_found THEN
                v_exists_code := 0;
                v_new_code    := '';
            END;
            IF v_exists_code = 1
            THEN
              v_continue := TRUE;
            ELSE
              v_continue := FALSE;
            END IF;
            IF v_continue = FALSE THEN
              BEGIN
                SELECT 1
                      ,substr(alt.newcode, 1, 8) || substr(p_p_code, 9)
                  INTO v_exists_code
                      ,v_new_code
                  FROM ins.t_altnames alt
                 WHERE alt.oldcode = substr(p_p_code, 1, 8) || '00000';
              EXCEPTION
                WHEN no_data_found THEN
                  v_exists_code := 0;
                  v_new_code    := '';
              END;
              IF v_exists_code = 1
              THEN
                v_continue := TRUE;
              ELSE
                v_continue := FALSE;
              END IF;
            END IF;
            IF v_continue = FALSE THEN
              BEGIN
                SELECT 1
                      ,substr(alt.newcode, 1, 5) || substr(p_p_code, 6)
                  INTO v_exists_code
                      ,v_new_code
                  FROM ins.t_altnames alt
                 WHERE alt.oldcode = substr(p_p_code, 1, 5) || '00000000';
              EXCEPTION
                WHEN no_data_found THEN
                  v_exists_code := 0;
                  v_new_code    := '';
              END;
              IF v_exists_code = 1
              THEN
                v_continue := TRUE;
              ELSE
                v_continue := FALSE;
              END IF;
            END IF;
            IF v_continue = FALSE THEN
              BEGIN
                SELECT 1
                      ,substr(alt.newcode, 1, 2) || substr(p_p_code, 3)
                  INTO v_exists_code
                      ,v_new_code
                  FROM ins.t_altnames alt
                 WHERE alt.oldcode = substr(p_p_code, 1, 2) || '00000000000';
              EXCEPTION
                WHEN no_data_found THEN
                  v_exists_code := 0;
                  v_new_code    := '';
              END;
              IF v_exists_code = 1
              THEN
                v_continue := TRUE;
              ELSE
                v_continue := FALSE;
              END IF;
            END IF;
            
            /*\*если в искомом коде 4 уровня указан код 3-го уровня*\
            IF substr(p_p_code, 6, 3) != '000'
            THEN
              BEGIN
                SELECT 1
                      ,substr(alt.newcode, 1, 8) || substr(p_p_code, 9)
                  INTO v_exists_code
                      ,v_new_code
                  FROM ins.t_altnames alt
                 WHERE alt.oldcode = substr(p_p_code, 1, 8) || '00000';
              EXCEPTION
                WHEN no_data_found THEN
                  v_exists_code := 0;
                  v_new_code    := '';
              END;
              IF v_exists_code = 1
              THEN
                v_continue := TRUE;
              ELSE
                v_continue := FALSE;
              END IF;
            ELSE
              \*если в искомом коде 4 уровня указан код 2-го уровня*\
              IF substr(p_p_code, 3, 3) != '000'
                 AND substr(p_p_code, 6, 3) = '000'
              THEN
                BEGIN
                  SELECT 1
                        ,substr(alt.newcode, 1, 5) || substr(p_p_code, 6)
                    INTO v_exists_code
                        ,v_new_code
                    FROM ins.t_altnames alt
                   WHERE alt.oldcode = substr(p_p_code, 1, 5) || '00000000';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_exists_code := 0;
                    v_new_code    := '';
                END;
                IF v_exists_code = 1
                THEN
                  v_continue := TRUE;
                ELSE
                  v_continue := FALSE;
                END IF;
              ELSE
                \*шаг 37*\
                BEGIN
                  SELECT 1
                        ,substr(alt.newcode, 1, 2) || substr(p_p_code, 3)
                    INTO v_exists_code
                        ,v_new_code
                    FROM ins.t_altnames alt
                   WHERE alt.oldcode = substr(p_p_code, 1, 2) || '00000000000';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_exists_code := 0;
                    v_new_code    := '';
                END;
                IF v_exists_code = 1
                THEN
                  v_continue := TRUE;
                ELSE
                  v_continue := FALSE;
                END IF;
              END IF;
            END IF;*/
          ELSE
            /*если искомый код 3 уровня*/
            IF substr(p_p_code, 9, 3) = '000'
               AND substr(p_p_code, 6, 3) != '000'
            THEN
              BEGIN
                SELECT 1
                      ,substr(alt.newcode, 1, 8) || substr(p_p_code, 9)
                  INTO v_exists_code
                      ,v_new_code
                  FROM ins.t_altnames alt
                 WHERE alt.oldcode = substr(p_p_code, 1, 8) || '00000';
              EXCEPTION
                WHEN no_data_found THEN
                  v_exists_code := 0;
                  v_new_code    := '';
              END;
              IF v_exists_code = 1
              THEN
                v_continue := TRUE;
              ELSE
                v_continue := FALSE;
              END IF;
              /*если в искомом коде 3 уровня указан код 2-го уровня*/
              /*IF substr(p_p_code, 3, 3) != '000'
              THEN
                BEGIN
                  SELECT 1
                        ,substr(alt.newcode, 1, 5) || substr(p_p_code, 6)
                    INTO v_exists_code
                        ,v_new_code
                    FROM ins.t_altnames alt
                   WHERE alt.oldcode = substr(p_p_code, 1, 5) || '00000000';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_exists_code := 0;
                    v_new_code    := '';
                END;
                IF v_exists_code = 1
                THEN
                  v_continue := TRUE;
                ELSE
                  v_continue := FALSE;
                END IF;
              ELSE
                \*шаг 37*\
                BEGIN
                  SELECT 1
                        ,substr(alt.newcode, 1, 2) || substr(p_p_code, 3)
                    INTO v_exists_code
                        ,v_new_code
                    FROM ins.t_altnames alt
                   WHERE alt.oldcode = substr(p_p_code, 1, 2) || '00000000000';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_exists_code := 0;
                    v_new_code    := '';
                END;
                IF v_exists_code = 1
                THEN
                  v_continue := TRUE;
                ELSE
                  v_continue := FALSE;
                END IF;
              END IF;*/
            ELSE
              /*если искомый код 2 уровня*/
              IF substr(p_p_code, 6, 6) = '000000'
                 AND substr(p_p_code, 3, 3) != '000'
              THEN
                /*шаг 37*/
                BEGIN
                  SELECT 1
                        ,substr(alt.newcode, 1, 2) || substr(p_p_code, 3)
                    INTO v_exists_code
                        ,v_new_code
                    FROM ins.t_altnames alt
                   WHERE alt.oldcode = substr(p_p_code, 1, 2) || '00000000000';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_exists_code := 0;
                    v_new_code    := '';
                END;
                IF v_exists_code = 1
                THEN
                  v_continue := TRUE;
                ELSE
                  v_continue := FALSE;
                END IF;
              ELSE
                /*шаг 41, 42*/
                UPDATE ins.cn_address ca
                   SET ca.actual_date = trunc(p_p_date_actual)
                 WHERE ca.id = p_p_adr_id;
                INSERT INTO ins.ven_actual_journal_adr
                  (change_date, change_type, id_adress, new_value, note, old_value, user_id)
                  SELECT trunc(SYSDATE)
                        ,2
                        , /*изменена*/ca.id
                        ,ca.actual || ',' || ca.actual_date || ',' || nvl(ca.code, 'NULL') || ',' ||
                         nvl(ca.zip, 'NULL') || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                         nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                         nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                         nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                         nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                         nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                         nvl(ca.house_nr, 'NULL')
                        ,'Ошибок нет'
                        ,p_p_actual || ',' || p_p_actual_date || ',' || nvl(p_p_code, 'NULL') || ',' ||
                         nvl(p_p_zip, 'NULL') || ',' || nvl(p_p_province_type, 'NULL') || ',' ||
                         nvl(p_p_province_name, 'NULL') || ',' || nvl(p_p_region_type, 'NULL') || ',' ||
                         nvl(p_p_region_name, 'NULL') || ',' || nvl(p_p_city_type, 'NULL') || ',' ||
                         nvl(p_p_city_name, 'NULL') || ',' || nvl(p_p_district_type, 'NULL') || ',' ||
                         nvl(p_p_district_name, 'NULL') || ',' || nvl(p_p_street_type, 'NULL') || ',' ||
                         nvl(p_p_street_name, 'NULL') || ',' || nvl(p_p_house_type, 'NULL') || ',' ||
                         nvl(p_p_house_num, 'NULL')
                        ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
                    FROM ins.cn_address ca
                   WHERE ca.id = p_p_adr_id;
                v_continue := FALSE;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    
      IF v_continue
         AND NOT v_exit_procedure
      THEN
        /*street*/
        /*begin
        SELECT st.name||'-'||st.code
        INTO v_street_code
          FROM ins.t_street   st
              ,ins.t_socrbase socr
         WHERE st.code LIKE substr(v_new_code, 1, 15) || '%'
           AND substr(v_new_code, 12, 4) != '0000'
           AND st.socr = socr.scname
           AND substr(st.code, 16, 2) = '00'
           AND socr.plevel = 5
           AND substr(st.code, -2) =
               (SELECT lpad(to_char(MIN(to_number(substr(sta.code, -2)))), 2, '0')
                  FROM ins.t_street   sta
                      ,ins.t_socrbase s
                 WHERE sta.code LIKE substr(v_new_code, 1, 15) || '%'
                   AND substr(v_new_code, 12, 4) != '0000'
                   AND sta.socr = s.scname
                   AND s.plevel = 5
                   AND substr(sta.code, 16, 2) = '00'
                   AND substr(sta.code, -2) != '99')
            AND EXISTS (SELECT NULL
                  FROM ins.t_street   st
                      ,ins.t_socrbase socr
                 WHERE st.code LIKE substr(v_new_code, 1, 15) || '%'
                   AND st.socr = socr.scname
                   AND substr(v_new_code, 12, 4) != '0000'
                   AND substr(st.code, 16, 2) = '00'
                   AND socr.plevel = 5
                   AND substr(st.code, -2) != '99');
         exception when others then
           v_street_code := '';
         end;*/
        BEGIN
          UPDATE ins.cn_address ca
             SET (ca.street_name, ca.street_type, ca.code_kladr_street, ca.index_street) =
                 (SELECT st.name
                        ,st.socr
                        ,st.code
                        ,st.pindex
                    FROM ins.t_street   st
                        ,ins.t_socrbase socr
                   WHERE st.code LIKE substr(v_new_code, 1, 15) || '%'
                     AND substr(v_new_code, 12, 4) != '0000'
                     AND st.socr = socr.scname
                     AND substr(st.code, 16, 2) = '00'
                     AND socr.plevel = 5
                     AND substr(st.code, -2) =
                         (SELECT lpad(to_char(MIN(to_number(substr(sta.code, -2)))), 2, '0')
                            FROM ins.t_street   sta
                                ,ins.t_socrbase s
                           WHERE sta.code LIKE substr(v_new_code, 1, 15) || '%'
                             AND substr(v_new_code, 12, 4) != '0000'
                             AND sta.socr = s.scname
                             AND s.plevel = 5
                             AND substr(sta.code, 16, 2) = '00'
                             AND substr(sta.code, -2) != '99'))
           WHERE ca.id = p_p_adr_id
             AND EXISTS (SELECT NULL
                    FROM ins.t_street   st
                        ,ins.t_socrbase socr
                   WHERE st.code LIKE substr(v_new_code, 1, 15) || '%'
                     AND st.socr = socr.scname
                     AND substr(v_new_code, 12, 4) != '0000'
                     AND substr(st.code, 16, 2) = '00'
                     AND socr.plevel = 5
                     AND substr(st.code, -2) != '99');
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ins.cn_address ca
               SET ca.street_name       = NULL
                  ,ca.street_type       = NULL
                  ,ca.code_kladr_street = NULL
                  ,ca.index_street      = NULL
             WHERE ca.id = p_p_adr_id;
        END;
        IF SQL%ROWCOUNT = 0
        THEN
          UPDATE ins.cn_address ca
             SET ca.street_name       = NULL
                ,ca.street_type       = NULL
                ,ca.code_kladr_street = NULL
                ,ca.index_street      = NULL
           WHERE ca.id = p_p_adr_id;
        END IF;
        /*district*/
        /*begin
        SELECT kl.name||'-'||kl.code
        INTO v_distr_code
          FROM ins.t_kladr    kl
              ,ins.t_socrbase socr
         WHERE kl.code LIKE substr(v_new_code, 1, 11) || '%'
           AND substr(v_new_code, 9, 3) != '000'
           AND kl.socr = socr.scname
           AND socr.plevel = 4
           AND substr(kl.code, -2) =
               (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                  FROM ins.t_kladr    kla
                      ,ins.t_socrbase s
                 WHERE kl.code LIKE substr(v_new_code, 1, 11) || '%'
                   AND substr(v_new_code, 9, 3) != '000'
                   AND kla.socr = s.scname
                   AND s.plevel = 4
                   AND substr(kla.code, -2) != '99');
        exception when others then
           v_distr_code := '';
         end;*/
        BEGIN
          UPDATE ins.cn_address ca
             SET (ca.district_name, ca.district_type, ca.code_kladr_distr, ca.index_distr) =
                 (SELECT kl.name
                        ,kl.socr
                        ,kl.code
                        ,kl.pindex
                    FROM ins.t_kladr    kl
                        ,ins.t_socrbase socr
                   WHERE kl.code LIKE substr(v_new_code, 1, 11) || '%'
                     AND substr(v_new_code, 9, 3) != '000'
                     AND kl.socr = socr.scname
                     AND socr.plevel = 4
                     AND substr(kl.code, -2) =
                         (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                            FROM ins.t_kladr    kla
                                ,ins.t_socrbase s
                           WHERE kl.code LIKE substr(v_new_code, 1, 11) || '%'
                             AND substr(v_new_code, 9, 3) != '000'
                             AND kla.socr = s.scname
                             AND s.plevel = 4
                             AND substr(kla.code, -2) != '99'))
           WHERE ca.id = p_p_adr_id
             AND EXISTS (SELECT NULL
                    FROM ins.t_kladr    kl
                        ,ins.t_socrbase socr
                   WHERE kl.code LIKE substr(v_new_code, 1, 11) || '%'
                     AND kl.socr = socr.scname
                     AND substr(v_new_code, 9, 3) != '000'
                     AND socr.plevel = 4
                     AND substr(kl.code, -2) != '99');
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ins.cn_address ca
               SET ca.district_name    = NULL
                  ,ca.district_type    = NULL
                  ,ca.code_kladr_distr = NULL
                  ,ca.index_distr      = NULL
             WHERE ca.id = p_p_adr_id;
        END;
        IF SQL%ROWCOUNT = 0
        THEN
          UPDATE ins.cn_address ca
             SET ca.district_name    = NULL
                ,ca.district_type    = NULL
                ,ca.code_kladr_distr = NULL
                ,ca.index_distr      = NULL
           WHERE ca.id = p_p_adr_id;
        END IF;
        /*city*/
        /*begin
        SELECT kl.name||'-'||kl.code
        INTO v_city_code
          FROM ins.t_kladr    kl
              ,ins.t_socrbase socr
         WHERE kl.code LIKE substr(v_new_code, 1, 9) || '%'
           AND substr(v_new_code, 6, 3) != '000'
           AND kl.code LIKE '________000%'
           AND kl.socr = socr.scname
           AND socr.plevel = 3
           AND substr(kl.code, -2) =
               (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                  FROM ins.t_kladr    kla
                      ,ins.t_socrbase s
                 WHERE kla.code LIKE substr(v_new_code, 1, 9) || '%'
                   AND substr(v_new_code, 6, 3) != '000'
                   AND kla.code LIKE '________000%'
                   AND kla.socr = s.scname
                   AND s.plevel = 3
                   AND substr(kla.code, -2) != '99');
        exception when others then
           v_city_code := '';
         end;*/
        BEGIN
          UPDATE ins.cn_address ca
             SET (ca.city_name, ca.city_type, ca.code_kladr_city, ca.index_city) =
                 (SELECT kl.name
                        ,kl.socr
                        ,kl.code
                        ,kl.pindex
                    FROM ins.t_kladr    kl
                        ,ins.t_socrbase socr
                   WHERE kl.code LIKE substr(v_new_code, 1, 8) || '%'
                     AND substr(v_new_code, 6, 3) != '000'
                     AND kl.code LIKE '________000%'
                     AND kl.socr = socr.scname
                     AND socr.plevel = 3
                     AND substr(kl.code, -2) =
                         (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                            FROM ins.t_kladr    kla
                                ,ins.t_socrbase s
                           WHERE kla.code LIKE substr(v_new_code, 1, 8) || '%'
                             AND substr(v_new_code, 6, 3) != '000'
                             AND kla.code LIKE '________000%'
                             AND kla.socr = s.scname
                             AND s.plevel = 3
                             AND substr(kla.code, -2) != '99'))
           WHERE ca.id = p_p_adr_id
             AND EXISTS (SELECT NULL
                    FROM ins.t_kladr    kl
                        ,ins.t_socrbase socr
                   WHERE substr(kl.code, 1, 8) = substr(v_new_code, 1, 8)
                     AND substr(v_new_code, 6, 3) != '000'
                     AND substr(kl.code, 9, 3) = '000'
                     AND kl.socr = socr.scname
                     AND socr.plevel = 3
                     AND substr(kl.code, -2) != '99');
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ins.cn_address ca
               SET ca.city_name       = NULL
                  ,ca.city_type       = NULL
                  ,ca.code_kladr_city = NULL
                  ,ca.index_city      = NULL
             WHERE ca.id = p_p_adr_id;
        END;
        IF SQL%ROWCOUNT = 0
        THEN
          UPDATE ins.cn_address ca
             SET ca.city_name       = NULL
                ,ca.city_type       = NULL
                ,ca.code_kladr_city = NULL
                ,ca.index_city      = NULL
           WHERE ca.id = p_p_adr_id;
        END IF;
        /*region*/
        /*begin
        SELECT kl.name||'-'||kl.code
        INTO v_region_code
          FROM ins.t_kladr    kl
              ,ins.t_socrbase socr
         WHERE kl.code LIKE substr(v_new_code, 1, 5) || '%'
           AND substr(v_new_code, 3, 3) != '000'
           AND kl.code LIKE '_____000000%'
           AND kl.socr = socr.scname
           AND socr.plevel = 2
           AND substr(kl.code, -2) =
               (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                  FROM ins.t_kladr    kla
                      ,ins.t_socrbase s
                 WHERE kla.code LIKE substr(v_new_code, 1, 5) || '%'
                   AND substr(v_new_code, 3, 3) != '000'
                   AND kla.code LIKE '_____000000%'
                   AND kla.socr = s.scname
                   AND s.plevel = 2
                   AND substr(kla.code, -2) != '99');
        exception when others then
           v_region_code := '';
         end;*/
        BEGIN
          UPDATE ins.cn_address ca
             SET (ca.region_name, ca.region_type, ca.code_kladr_region, ca.index_region) =
                 (SELECT kl.name
                        ,kl.socr
                        ,kl.code
                        ,kl.pindex
                    FROM ins.t_kladr    kl
                        ,ins.t_socrbase socr
                   WHERE kl.code LIKE substr(v_new_code, 1, 5) || '%'
                     AND substr(v_new_code, 3, 3) != '000'
                     AND kl.code LIKE '_____000000%'
                     AND kl.socr = socr.scname
                     AND socr.plevel = 2
                     AND substr(kl.code, -2) =
                         (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                            FROM ins.t_kladr    kla
                                ,ins.t_socrbase s
                           WHERE kla.code LIKE substr(v_new_code, 1, 5) || '%'
                             AND substr(v_new_code, 3, 3) != '000'
                             AND kla.code LIKE '_____000000%'
                             AND kla.socr = s.scname
                             AND s.plevel = 2
                             AND substr(kla.code, -2) != '99'))
           WHERE ca.id = p_p_adr_id
             AND EXISTS (SELECT NULL
                    FROM ins.t_kladr    kl
                        ,ins.t_socrbase socr
                   WHERE kl.code LIKE substr(v_new_code, 1, 5) || '%'
                     AND substr(v_new_code, 3, 3) != '000'
                     AND kl.code LIKE '_____000000%'
                     AND kl.socr = socr.scname
                     AND socr.plevel = 2
                     AND substr(kl.code, -2) != '99');
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ins.cn_address ca
               SET ca.region_name       = NULL
                  ,ca.region_type       = NULL
                  ,ca.code_kladr_region = NULL
                  ,ca.index_region      = NULL
             WHERE ca.id = p_p_adr_id;
        END;
        IF SQL%ROWCOUNT = 0
        THEN
          UPDATE ins.cn_address ca
             SET ca.region_name       = NULL
                ,ca.region_type       = NULL
                ,ca.code_kladr_region = NULL
                ,ca.index_region      = NULL
           WHERE ca.id = p_p_adr_id;
        END IF;
        /*province*/
        UPDATE ins.cn_address ca
           SET (ca.province_name
              ,ca.province_type
              ,ca.code_kladr_province
              ,ca.index_province
              ,ca.region_code) =
               (SELECT kl.name
                      ,kl.socr
                      ,kl.code
                      ,kl.pindex
                      ,substr(kl.code, 1, 2)
                  FROM ins.t_kladr    kl
                      ,ins.t_socrbase socr
                 WHERE substr(kl.code, 1, 2) = substr(v_new_code, 1, 2)
                   AND kl.socr = socr.scname
                   AND kl.code LIKE '__00000000000'
                   AND socr.plevel = 1)
         WHERE ca.id = p_p_adr_id
           AND EXISTS (SELECT NULL
                  FROM ins.t_kladr    kl
                      ,ins.t_socrbase socr
                 WHERE substr(kl.code, 1, 2) = substr(v_new_code, 1, 2)
                   AND kl.socr = socr.scname
                   AND kl.code LIKE '__00000000000'
                   AND socr.plevel = 1);
        UPDATE ins.cn_address ca
           SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                   ,ca.code_kladr_distr)
                                               ,ca.code_kladr_city)
                                           ,ca.code_kladr_region)
                                       ,ca.code_kladr_province)
                                   ,ca.code)
              ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma
                                                              ,ca.code_kladr_street)
                                                          ,ca.code_kladr_distr)
                                                      ,ca.code_kladr_city)
                                                  ,ca.code_kladr_region)
                                              ,ca.code_kladr_province)
                                          ,'00')
                                      ,1
                                      ,2)
              ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street)
                                                   ,ca.index_distr)
                                               ,ca.index_city)
                                           ,ca.index_region)
                                       ,ca.index_province)
                                   ,ca.zip)
         WHERE ca.id = p_p_adr_id;
        
        pkg_kladr.compare_text_to_kladr(p_p_date_actual, p_p_adr_id, v_out_number);
        IF p_p_type_adr = 1
        THEN
          pkg_kladr.ins_text_field(p_p_adr_id);
          /**/
          IF nvl(p_house_num, 'X') != 'X'
          THEN
            /*если есть номер дома*/
            SELECT COUNT(*)
              INTO v_exists_str
              FROM ins.t_street st
             WHERE (st.code LIKE '%51' OR st.code LIKE '%99')
               AND st.code LIKE rpad(v_code, 15, '0') || '__'
               AND trunc(st.add_date) = p_p_date_actual;
            /*пропущен шаг 20, т.к. нет алгоритма в ТЗ*/
            /*чейто мне стало непонятно зачем этот IF*/
            IF v_exists_str = 0
            THEN
            
              UPDATE ins.t_doma og
                 SET og.parse_name = ins.pkg_kladr.parse_houses_number(og.name)
               WHERE og.code LIKE substr(TRIM(rpad(v_new_code, 15, '0')), 1, 15) || '%'
                 AND og.parse_name IS NULL;
            
              UPDATE ins.cn_address ca
                 SET (ca.house_nr, ca.house_type, ca.code_kladr_doma, ca.index_doma, ca.code, ca.zip) =
                     (SELECT p_p_house_num
                            ,td.socr
                            ,td.code
                            ,td.pindex
                            ,td.code
                            ,td.pindex
                        FROM ins.t_doma td
                       WHERE (regexp_instr(UPPER(td.parse_name)
                                          ,'(^|,)' ||
                                           regexp_substr(TRIM(UPPER(p_p_house_num)), '\d+.*|\d+\.*') ||
                                           '(,|$)') != 0 OR UPPER(td.parse_name) = TRIM(UPPER(p_p_house_num)))
                         AND td.code LIKE substr(TRIM(rpad(v_new_code, 15, '0')), 1, 15) || '%'
                         AND substr(td.code, -2) != '99'
                         AND substr(td.code, -2) =
                             (SELECT lpad(to_char(MAX(to_number(substr(tda.code, -2)))), 2, '0')
                                FROM ins.t_doma tda
                               WHERE (regexp_instr(UPPER(tda.parse_name)
                                                  ,'(^|,)' ||
                                                   regexp_substr(TRIM(UPPER(p_p_house_num)), '\d+.*|\d+\.*') ||
                                                   '(,|$)') != 0 OR
                                     UPPER(tda.parse_name) = TRIM(UPPER(p_p_house_num)))
                                 AND tda.code LIKE substr(TRIM(rpad(v_new_code, 15, '0')), 1, 15) || '%'))
               WHERE ca.id = p_p_adr_id
                 AND EXISTS
               (SELECT NULL
                        FROM ins.t_doma td
                       WHERE (regexp_instr(UPPER(td.parse_name)
                                          ,'(^|,)' ||
                                           regexp_substr(TRIM(UPPER(p_p_house_num)), '\d+.*|\d+\.*') ||
                                           '(,|$)') != 0 OR UPPER(td.parse_name) = TRIM(UPPER(p_p_house_num)))
                         AND td.code LIKE substr(TRIM(rpad(v_new_code, 15, '0')), 1, 15) || '%');
            END IF;
          END IF;
          /**/
        END IF;
        /**/
        SELECT CASE
                 WHEN length(ca.code) = 19 THEN
                  6
                 WHEN length(ca.code) = 17 THEN
                  5
                 WHEN (length(ca.code) = 13 AND substr(ca.code, 9, 3) != '000') THEN
                  4
                 WHEN (length(ca.code) = 13 AND substr(ca.code, 6, 3) != '000' AND
                      substr(ca.code, 9, 3) = '000') THEN
                  3
                 WHEN (length(ca.code) = 13 AND substr(ca.code, 6, 6) = '000000' AND
                      substr(ca.code, 3, 3) != '000') THEN
                  2
                 ELSE
                  1
               END
              ,CASE
                 WHEN ca.house_nr IS NOT NULL THEN
                  6
                 WHEN ca.house_nr IS NULL
                      AND ca.street_name IS NOT NULL THEN
                  5
                 WHEN ca.street_name IS NULL
                      AND ca.district_name IS NOT NULL THEN
                  4
                 WHEN ca.district_name IS NULL
                      AND ca.city_name IS NOT NULL THEN
                  3
                 WHEN ca.city_name IS NULL
                      AND ca.region_name IS NOT NULL THEN
                  2
                 WHEN ca.region_name IS NULL
                      AND ca.province_name IS NOT NULL THEN
                  1
                 ELSE
                  0
               END
          INTO v_level
              ,v_lvladr
          FROM ins.cn_address ca
         WHERE ca.id = p_p_adr_id;
        /**/
        v_indx := nvl(pkg_kladr.find_correct_index(p_p_adr_id), 'X');
        IF v_level < v_lvladr
        THEN
          UPDATE ins.cn_address ca
             SET ca.zip        =
                 (CASE
                   WHEN v_indx = 'X' THEN
                    ca.zip
                   ELSE
                    v_indx
                 END)
                ,ca.actual      = 0
                ,ca.actual_date = trunc(p_p_date_actual)
           WHERE ca.id = p_p_adr_id;
        ELSE
          UPDATE ins.cn_address ca
             SET ca.zip = (CASE
                            WHEN v_indx = 'X' THEN
                             ca.zip
                            ELSE
                             v_indx
                          END)
                ,ca.actual      = 1
                ,ca.actual_date = trunc(p_p_date_actual)
           WHERE ca.id = p_p_adr_id;
        END IF;
        INSERT INTO ins.ven_actual_journal_adr
          (change_date, change_type, id_adress, new_value, note, old_value, user_id)
          SELECT trunc(SYSDATE)
                ,2
                , /*изменена*/ca.id
                ,ca.actual || ',' || ca.actual_date || ',' || nvl(ca.code, 'NULL') || ',' ||
                 nvl(ca.zip, 'NULL') || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                 nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                 nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                 nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                 nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                 nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                 nvl(ca.house_nr, 'NULL')
                ,'Ошибок нет'
                ,p_p_actual || ',' || p_p_actual_date || ',' || nvl(p_p_code, 'NULL') || ',' ||
                 nvl(p_p_zip, 'NULL') || ',' || nvl(p_p_province_type, 'NULL') || ',' ||
                 nvl(p_p_province_name, 'NULL') || ',' || nvl(p_p_region_type, 'NULL') || ',' ||
                 nvl(p_p_region_name, 'NULL') || ',' || nvl(p_p_city_type, 'NULL') || ',' ||
                 nvl(p_p_city_name, 'NULL') || ',' || nvl(p_p_district_type, 'NULL') || ',' ||
                 nvl(p_p_district_name, 'NULL') || ',' || nvl(p_p_street_type, 'NULL') || ',' ||
                 nvl(p_p_street_name, 'NULL') || ',' || nvl(p_p_house_type, 'NULL') || ',' ||
                 nvl(p_p_house_num, 'NULL')
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.cn_address ca
           WHERE ca.id = p_p_adr_id;
      END IF;
    END;
  
    PROCEDURE calc_length_code_17
    (
      p_p_code          VARCHAR2
     ,p_p_adr_id        NUMBER
     ,p_p_date_actual   DATE
     ,p_p_house_num     VARCHAR2
     ,p_p_zip           VARCHAR2
     ,p_p_actual        NUMBER
     ,p_p_actual_date   DATE
     ,p_p_province_type VARCHAR2
     ,p_p_province_name VARCHAR2
     ,p_p_region_type   VARCHAR2
     ,p_p_region_name   VARCHAR2
     ,p_p_district_type VARCHAR2
     ,p_p_district_name VARCHAR2
     ,p_p_city_type     VARCHAR2
     ,p_p_city_name     VARCHAR2
     ,p_p_street_type   VARCHAR2
     ,p_p_street_name   VARCHAR2
     ,p_p_house_type    VARCHAR2
     ,p_p_type_adr      NUMBER
    ) IS
      v_exists_code    NUMBER := 0;
      v_new_code       VARCHAR2(25);
      v_continue       BOOLEAN := TRUE;
      v_code           VARCHAR2(25);
      v_indx           VARCHAR2(25);
      v_length_code    NUMBER;
      v_exit_procedure BOOLEAN := FALSE;
    BEGIN
      BEGIN
        SELECT 1
              ,st.code
          INTO v_exists_code
              ,v_new_code
          FROM ins.t_street st
         WHERE st.code = p_p_code;
      EXCEPTION
        WHEN no_data_found THEN
          v_exists_code := 0;
          v_new_code    := '';
      END;
      IF v_exists_code = 1
      THEN
        v_continue := TRUE;
      ELSE
        v_continue := FALSE;
      
        v_new_code := ins.pkg_kladr.get_altnames_code(p_p_code);
        SELECT length(v_new_code) INTO v_length_code FROM dual;
        /*если код 1,2,3,4 уровня*/
        IF nvl(v_length_code, 0) < 17
        THEN
          calc_length_code_13(nvl(v_new_code, p_p_code)
                             ,p_p_adr_id
                             ,p_p_date_actual
                             ,p_p_house_num
                             ,p_p_zip
                             ,p_p_actual
                             ,p_p_actual_date
                             ,p_p_province_type
                             ,p_p_province_name
                             ,p_p_region_type
                             ,p_p_region_name
                             ,p_p_district_type
                             ,p_p_district_name
                             ,p_p_city_type
                             ,p_p_city_name
                             ,p_p_street_type
                             ,p_p_street_name
                             ,p_p_house_type
                             ,p_p_type_adr);
          v_exit_procedure := TRUE;
        ELSE
          v_exit_procedure := FALSE;
        END IF;
      
        IF v_new_code IS NOT NULL
        THEN
          v_exists_code := 1;
        ELSE
          v_exists_code := 0;
          v_new_code    := '';
        END IF;
        IF v_exists_code = 1
        THEN
          v_continue := TRUE;
        ELSE
          v_continue := FALSE;
          BEGIN
            SELECT 1
                  ,substr(alt.newcode, 1, 11) || substr(p_p_code, 12)
              INTO v_exists_code
                  ,v_new_code
              FROM ins.t_altnames alt
             WHERE substr(alt.oldcode, 1, 15) = substr(p_p_code, 1, 11) || '0000'
               AND substr(v_code, 9, 3) != '000';
          EXCEPTION
            WHEN no_data_found THEN
              v_exists_code := 0;
              v_new_code    := '';
          END;
          IF v_exists_code = 1
          THEN
            v_continue := TRUE;
          ELSE
            v_continue := FALSE;
            BEGIN
              SELECT 1
                    ,substr(alt.newcode, 1, 8) || substr(p_p_code, 9)
                INTO v_exists_code
                    ,v_new_code
                FROM ins.t_altnames alt
               WHERE substr(alt.oldcode, 1, 15) = substr(p_p_code, 1, 8) || '0000000'
                 AND substr(v_code, 6, 3) != '000';
            EXCEPTION
              WHEN no_data_found THEN
                v_exists_code := 0;
                v_new_code    := '';
            END;
            IF v_exists_code = 1
            THEN
              v_continue := TRUE;
            ELSE
              v_continue := FALSE;
              BEGIN
                SELECT 1
                      ,substr(alt.newcode, 1, 5) || substr(p_p_code, 6)
                  INTO v_exists_code
                      ,v_new_code
                  FROM ins.t_altnames alt
                 WHERE substr(alt.oldcode, 1, 15) = substr(p_p_code, 1, 5) || '0000000000'
                   AND substr(v_code, 3, 3) != '000';
              EXCEPTION
                WHEN no_data_found THEN
                  v_exists_code := 0;
                  v_new_code    := '';
              END;
              IF v_exists_code = 1
              THEN
                v_continue := TRUE;
              ELSE
                v_continue := FALSE;
                BEGIN
                  SELECT 1
                        ,substr(alt.newcode, 1, 2) || substr(p_p_code, 3)
                    INTO v_exists_code
                        ,v_new_code
                    FROM ins.t_altnames alt
                   WHERE substr(alt.oldcode, 1, 15) = substr(p_p_code, 1, 2) || '0000000000000'
                     AND substr(v_code, 1, 2) != '00';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_exists_code := 0;
                    v_new_code    := '';
                END;
                IF v_exists_code = 1
                THEN
                  v_continue := TRUE;
                ELSE
                  v_continue := FALSE;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    
      IF v_continue
         AND NOT v_exit_procedure
      THEN
        /**/
        BEGIN
          SELECT 1
                ,st.code
            INTO v_exists_code
                ,v_code
            FROM ins.t_street st
           WHERE st.code = v_new_code;
        EXCEPTION
          WHEN no_data_found THEN
            v_continue := FALSE;
          
            v_code := ins.pkg_kladr.get_altnames_code(v_new_code, 5);
            IF v_code IS NOT NULL
            THEN
              v_exists_code := 1;
              v_continue    := TRUE;
            ELSE
              v_exists_code := 0;
              v_code        := '';
            END IF;
        END;
        UPDATE ins.cn_address adr SET adr.code = v_code WHERE adr.id = p_p_adr_id;
        /**/
        pkg_kladr.ins_text_field(p_p_adr_id);
        IF nvl(p_house_num, 'X') != 'X'
        THEN
          /*если есть номер дома*/
          SELECT COUNT(*)
            INTO v_exists_str
            FROM ins.t_street st
           WHERE (st.code LIKE '%51' OR st.code LIKE '%99')
             AND st.code LIKE rpad(v_code, 15, '0') || '__'
             AND trunc(st.add_date) = p_p_date_actual;
          /*пропущен шаг 20, т.к. нет алгоритма в ТЗ*/
          /*чейто мне стало непонятно зачем этот IF*/
          IF v_exists_str = 0
             AND v_continue
          THEN
          
            UPDATE ins.t_doma og
               SET og.parse_name = ins.pkg_kladr.parse_houses_number(og.name)
             WHERE og.code LIKE substr(TRIM(rpad(v_code, 15, '0')), 1, 15) || '%'
               AND og.parse_name IS NULL;
          
            UPDATE ins.cn_address ca
               SET (ca.house_nr, ca.house_type, ca.code_kladr_doma, ca.index_doma, ca.code, ca.zip) =
                   (SELECT p_p_house_num
                          ,td.socr
                          ,td.code
                          ,td.pindex
                          ,td.code
                          ,td.pindex
                      FROM ins.t_doma td
                     WHERE (regexp_instr(UPPER(td.parse_name)
                                        ,'(^|,)' || regexp_substr(TRIM(UPPER(p_p_house_num)), '\d+.*|\d+\.*') ||
                                         '(,|$)') != 0 OR UPPER(td.parse_name) = TRIM(UPPER(p_p_house_num)))
                       AND td.code LIKE substr(TRIM(rpad(v_code, 15, '0')), 1, 15) || '%'
                       AND substr(td.code, -2) != '99'
                       AND substr(td.code, -2) =
                           (SELECT lpad(to_char(MAX(to_number(substr(tda.code, -2)))), 2, '0')
                              FROM ins.t_doma tda
                             WHERE (regexp_instr(UPPER(tda.parse_name)
                                                ,'(^|,)' ||
                                                 regexp_substr(TRIM(UPPER(p_p_house_num)), '\d+.*|\d+\.*') ||
                                                 '(,|$)') != 0 OR UPPER(tda.parse_name) = TRIM(UPPER(p_p_house_num)))
                               AND tda.code LIKE substr(TRIM(rpad(v_code, 15, '0')), 1, 15) || '%'))
             WHERE ca.id = p_p_adr_id
               AND EXISTS
             (SELECT NULL
                      FROM ins.t_doma td
                     WHERE (regexp_instr(UPPER(td.parse_name)
                                        ,'(^|,)' || regexp_substr(TRIM(UPPER(p_p_house_num)), '\d+.*|\d+\.*') ||
                                         '(,|$)') != 0 OR UPPER(td.parse_name) = TRIM(UPPER(p_p_house_num)))
                       AND td.code LIKE substr(TRIM(rpad(v_code, 15, '0')), 1, 15) || '%');
          END IF;
        END IF;
        /**/
        UPDATE ins.cn_address ca
           SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                   ,ca.code_kladr_distr)
                                               ,ca.code_kladr_city)
                                           ,ca.code_kladr_region)
                                       ,ca.code_kladr_province)
                                   ,ca.code)
              ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma
                                                              ,ca.code_kladr_street)
                                                          ,ca.code_kladr_distr)
                                                      ,ca.code_kladr_city)
                                                  ,ca.code_kladr_region)
                                              ,ca.code_kladr_province)
                                          ,'00')
                                      ,1
                                      ,2)
              ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street)
                                                   ,ca.index_distr)
                                               ,ca.index_city)
                                           ,ca.index_region)
                                       ,ca.index_province)
                                   ,ca.zip)
         WHERE ca.id = p_p_adr_id;
        /**/
        v_indx := nvl(pkg_kladr.find_correct_index(p_p_adr_id), 'X');
        UPDATE ins.cn_address ca
           SET ca.zip = (CASE
                          WHEN v_indx = 'X' THEN
                           ca.zip
                          ELSE
                           v_indx
                        END)
              ,ca.actual = (CASE
                             WHEN ca.code_kladr_doma IS NULL
                                  AND ca.house_nr IS NOT NULL THEN
                              0
                             ELSE
                              1
                           END)
              ,ca.actual_date = trunc(p_p_date_actual)
         WHERE ca.id = p_p_adr_id;
        INSERT INTO ins.ven_actual_journal_adr
          (change_date, change_type, id_adress, new_value, note, old_value, user_id)
          SELECT trunc(SYSDATE)
                ,2
                , /*изменена*/ca.id
                ,
                 /*'Актульность: '||*/ca.actual || ',' || ca.actual_date || ',' ||
                 nvl(ca.code, 'NULL') || ',' || nvl(ca.zip, 'NULL') || ',' ||
                 nvl(ca.province_type, 'NULL') || ',' ||
                 nvl(ca.province_name, 'NULL') || ',' ||
                 nvl(ca.region_type, 'NULL') || ',' ||
                 nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                 nvl(ca.city_name, 'NULL') || ',' ||
                 nvl(ca.district_type, 'NULL') || ',' ||
                 nvl(ca.district_name, 'NULL') || ',' ||
                 nvl(ca.street_type, 'NULL') || ',' ||
                 nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                 nvl(ca.house_nr, 'NULL')
                ,'Ошибок нет'
                ,p_p_actual || ',' || p_p_actual_date || ',' || nvl(p_p_code, 'NULL') || ',' ||
                 nvl(p_p_zip, 'NULL') || ',' || nvl(p_p_province_type, 'NULL') || ',' ||
                 nvl(p_p_province_name, 'NULL') || ',' || nvl(p_p_region_type, 'NULL') || ',' ||
                 nvl(p_p_region_name, 'NULL') || ',' || nvl(p_p_city_type, 'NULL') || ',' ||
                 nvl(p_p_city_name, 'NULL') || ',' || nvl(p_p_district_type, 'NULL') || ',' ||
                 nvl(p_p_district_name, 'NULL') || ',' || nvl(p_p_street_type, 'NULL') || ',' ||
                 nvl(p_p_street_name, 'NULL') || ',' || nvl(p_p_house_type, 'NULL') || ',' ||
                 nvl(p_p_house_num, 'NULL')
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.cn_address ca
           WHERE ca.id = p_p_adr_id;
      
      END IF;
    
    END;
  
  BEGIN
    var_adr_id := p_adr_id;
    IF p_code_kladr IS NULL
    THEN
      pkg_kladr.compare_text_to_kladr(p_date_actual, p_adr_id, v_out_number);
    END IF;
    IF (v_out_number = 1 OR p_code_kladr IS NOT NULL)
    THEN
      SELECT length(ca.code)
            ,CASE
               WHEN length(ca.code) = 19 THEN
                substr(ca.code, 1, 15) || '00'
               ELSE
                ca.code
             END
        INTO v_length_code
            ,v_code
        FROM ins.cn_address ca
       WHERE ca.id = p_adr_id;
      /*если код 6 или 5 уровня*/
      IF nvl(v_length_code, 0) >= 17
      THEN
        calc_length_code_17(v_code
                           ,p_adr_id
                           ,p_date_actual
                           ,p_house_num
                           ,p_zip
                           ,p_actual
                           ,p_actual_date
                           ,p_province_type
                           ,p_province_name
                           ,p_region_type
                           ,p_region_name
                           ,p_district_type
                           ,p_district_name
                           ,p_city_type
                           ,p_city_name
                           ,p_street_type
                           ,p_street_name
                           ,p_house_type
                           ,p_type_adr);
      ELSE
        /*если код кладр 1,2,3,4 уровня*/
        calc_length_code_13(v_code
                           ,p_adr_id
                           ,p_date_actual
                           ,p_house_num
                           ,p_zip
                           ,p_actual
                           ,p_actual_date
                           ,p_province_type
                           ,p_province_name
                           ,p_region_type
                           ,p_region_name
                           ,p_district_type
                           ,p_district_name
                           ,p_city_type
                           ,p_city_name
                           ,p_street_type
                           ,p_street_name
                           ,p_house_type
                           ,p_type_adr);
      END IF;
    ELSE
      UPDATE ins.cn_address ca SET ca.actual_date = trunc(p_date_actual) WHERE ca.id = p_adr_id;
      INSERT INTO ins.ven_actual_journal_adr
        (change_date, change_type, id_adress, new_value, note, old_value, user_id)
        SELECT trunc(SYSDATE)
              ,2
              , /*изменена*/ca.id
              ,ca.actual || ',' || ca.actual_date || ',' || nvl(ca.code, 'NULL') || ',' ||
               nvl(ca.zip, 'NULL') || ',' || nvl(ca.province_type, 'NULL') || ',' ||
               nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
               nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
               nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
               nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
               nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
               nvl(ca.house_nr, 'NULL')
              ,'Ошибок нет, но КОД КЛАДР не найден'
              ,p_actual || ',' || p_actual_date || ',' || nvl(p_code_kladr, 'NULL') || ',' ||
               nvl(p_zip, 'NULL') || ',' || nvl(p_province_type, 'NULL') || ',' ||
               nvl(p_province_name, 'NULL') || ',' || nvl(p_region_type, 'NULL') || ',' ||
               nvl(p_region_name, 'NULL') || ',' || nvl(p_city_type, 'NULL') || ',' ||
               nvl(p_city_name, 'NULL') || ',' || nvl(p_district_type, 'NULL') || ',' ||
               nvl(p_district_name, 'NULL') || ',' || nvl(p_street_type, 'NULL') || ',' ||
               nvl(p_street_name, 'NULL') || ',' || nvl(p_house_type, 'NULL') || ',' ||
               nvl(p_house_num, 'NULL')
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.cn_address ca
         WHERE ca.id = p_adr_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении actual_algorithm ' || SQLERRM ||
                              '; VAR_ADR_ID = ' || var_adr_id);
  END actual_algorithm;
  /*********************************************************/
  FUNCTION create_fact_adr(par_adr_id NUMBER) RETURN NUMBER IS
    v_sq_adr     NUMBER;
    v_contact_id NUMBER;
    v_brief      VARCHAR2(60);
  BEGIN
  
    SELECT cca.contact_id
          ,tat.brief
      INTO v_contact_id
          ,v_brief
      FROM ins.cn_contact_address cca
          ,ins.t_address_type     tat
     WHERE cca.adress_id = par_adr_id
       AND tat.id = cca.address_type;
  
    SELECT sq_cn_address.nextval INTO v_sq_adr FROM dual;
    INSERT INTO ven_cn_address
      (id
      ,appartment_nr
      ,block_number
      ,box_number
      ,building_name
      ,city_name
      ,country_id
      ,district_name
      ,house_nr
      ,NAME
      ,province_name
      ,region_name
      ,street_name
      ,zip
      ,code
      ,actual
      ,actual_date
      ,decompos_date
      ,street_type
      ,city_type
      ,district_type
      ,region_type
      ,house_type
      ,province_type
      ,parent_addr_id
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
      ,index_doma)
      SELECT v_sq_adr
            ,substr(ca.appartment_nr, 1, 9) appartment_nr
            ,ca.block_number
            ,ca.box_number
            ,ca.building_name
            ,ca.city_name
            ,ca.country_id
            ,ca.district_name
            ,ca.house_nr
            ,ca.name
            ,ca.province_name
            ,ca.region_name
            ,ca.street_name
            ,ca.zip
            ,ca.code
            ,ca.actual
            ,ca.actual_date
            ,ca.decompos_date
            ,ca.street_type
            ,ca.city_type
            ,ca.district_type
            ,ca.region_type
            ,ca.house_type
            ,ca.province_type
            ,ca.id
            ,ca.decompos_permis
            ,ca.code_kladr_province
            ,ca.code_kladr_region
            ,ca.code_kladr_city
            ,ca.code_kladr_distr
            ,ca.code_kladr_street
            ,ca.code_kladr_doma
            ,ca.index_province
            ,ca.index_region
            ,ca.index_city
            ,ca.index_distr
            ,ca.index_street
            ,ca.index_doma
        FROM ins.cn_address ca
       WHERE ca.id = par_adr_id;
  
    INSERT INTO ins.ven_cn_contact_address
      (address_type, adress_id, contact_id, is_default, status)
    VALUES
      ((SELECT atr.id FROM ins.t_address_type atr WHERE atr.brief = 'FK_' || v_brief)
      ,v_sq_adr
      ,v_contact_id
      ,0
      ,1);
  
    /*COMMIT;*/
    RETURN v_sq_adr;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении CREATE_FACT_ADR ' || SQLERRM);
  END create_fact_adr;
  /*********************************************************/
  /*110277,127979,127851,3753*/
  PROCEDURE compare_text_to_kladr
  (
    par_date_proc  DATE
   ,par_adr_id     NUMBER
   ,par_out_number OUT NUMBER
  ) IS
    p_is_proc  NUMBER;
    p_cur_code VARCHAR2(25);
  BEGIN
    par_out_number := 0;
    DELETE FROM tmpl_save_code;
  
    SELECT COUNT(*)
      INTO p_is_proc
      FROM ins.cn_address ca
     WHERE ca.id = par_adr_id
       AND (ca.zip IS NOT NULL OR ca.district_type IS NOT NULL OR ca.district_name IS NOT NULL OR
           ca.region_type IS NOT NULL OR ca.region_name IS NOT NULL OR ca.province_type IS NOT NULL OR
           ca.province_name IS NOT NULL OR ca.city_type IS NOT NULL OR ca.city_name IS NOT NULL OR
           ca.street_type IS NOT NULL OR ca.street_name IS NOT NULL OR ca.house_type IS NOT NULL OR
           ca.house_nr IS NOT NULL);
    IF p_is_proc > 0
    THEN
      SELECT ca.code INTO p_cur_code FROM ins.cn_address ca WHERE ca.id = par_adr_id;
      /***region_name IS NULL***********/
      INSERT INTO ins.ven_actual_journal_adr
        (change_date, change_type, id_adress, new_value, note, old_value, user_id)
        SELECT SYSDATE
              ,1
              , /*добавлена*/ca.id
              ,
               /*'Дата актуальности: '||*/to_char(par_date_proc, 'DD.MM.YYYY') || ',' ||
               nvl(ca.code, 'NULL') || ',' || nvl(ca.province_type, 'NULL') || ',' ||
               nvl(ca.province_name, 'NULL') || ',' ||
               nvl(ca.region_type, 'NULL') || ',' ||
               nvl(ca.region_name, 'NULL') || ',' ||
               nvl(ca.city_type, 'NULL') || ',' ||
               nvl(ca.city_name, 'NULL') || ',' ||
               nvl(ca.district_type, 'NULL') || ',' ||
               nvl(ca.district_name, 'NULL') || ',' ||
               nvl(ca.street_type, 'NULL') || ',' ||
               nvl(ca.street_name, 'NULL') || ',' ||
               nvl(ca.house_type, 'NULL') || ',' ||
               nvl(ca.house_nr, 'NULL')
              ,'Не указан регион 1-ого уровня'
              ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
               nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
               nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
               nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
               nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
               nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
               nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.cn_address ca
         WHERE ca.code IS NULL
           AND ca.province_name IS NULL
           AND ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.actual_date = par_date_proc
       WHERE ca.code IS NULL
         AND ca.province_name IS NULL
         AND ca.id = par_adr_id;
      /*****************/
      INSERT INTO ins.ven_actual_journal_adr
        (change_date, change_type, id_adress, new_value, note, old_value, user_id)
        SELECT SYSDATE
              ,1
              , /*добавлена*/ca.id
              ,
               /*'Дата актуальности: '||*/to_char(par_date_proc, 'DD.MM.YYYY') || ',' ||
               nvl(ca.code, 'NULL') || ',' || nvl(ca.province_type, 'NULL') || ',' ||
               nvl(ca.province_name, 'NULL') || ',' ||
               nvl(ca.region_type, 'NULL') || ',' ||
               nvl(ca.region_name, 'NULL') || ',' ||
               nvl(ca.city_type, 'NULL') || ',' ||
               nvl(ca.city_name, 'NULL') || ',' ||
               nvl(ca.district_type, 'NULL') || ',' ||
               nvl(ca.district_name, 'NULL') || ',' ||
               nvl(ca.street_type, 'NULL') || ',' ||
               nvl(ca.street_name, 'NULL') || ',' ||
               nvl(ca.house_type, 'NULL') || ',' ||
               nvl(ca.house_nr, 'NULL')
              ,'Некорректно указан регион 1-ого уровня: ' || ca.region_type || '/' || ca.region_name
              ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
               nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
               nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
               nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
               nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
               nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
               nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
              ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
          FROM ins.cn_address ca
         WHERE ca.id = par_adr_id
           AND NOT EXISTS (SELECT NULL
                  FROM ins.t_kladr kl
                 WHERE kl.code LIKE '__000000000__'
                   AND upper(kl.name) = upper(ca.province_name)
                   AND upper(kl.socr) = upper(ca.province_type));
      UPDATE ins.cn_address ca
         SET ca.actual_date = par_date_proc
       WHERE ca.id = par_adr_id
         AND NOT EXISTS (SELECT NULL
                FROM ins.t_kladr kl
               WHERE kl.code LIKE '__000000000__'
                 AND upper(kl.name) = upper(ca.province_name)
                 AND upper(kl.socr) = upper(ca.province_type));
    
      /*****создаем записи 1 уровня***********/
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, old_code, pindex)
        SELECT kl.code
              ,ca.id
              ,1
              ,ca.code
              ,kl.pindex
          FROM ins.cn_address ca
              ,ins.t_kladr    kl
         WHERE ca.id = par_adr_id
           AND upper(kl.name) = upper(ca.province_name)
           AND upper(kl.socr) = upper(ca.province_type)
           AND kl.code LIKE '__000000000__'
           AND to_number(substr(kl.code, -2)) =
               (SELECT to_number(MIN(substr(kla.code, -2)))
                  FROM ins.t_kladr kla
                 WHERE kla.code LIKE '__000000000__'
                   AND upper(kla.name) = upper(ca.province_name)
                   AND upper(kla.socr) = upper(ca.province_type))
           AND substr(kl.code, -2) NOT IN ('99', '51');
      /*****создаем записи 2 уровня***************/
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, old_code, pindex)
        SELECT kl.code
              ,ca.id
              ,2
              ,ca.code
              ,kl.pindex
          FROM ins.cn_address     ca
              ,ins.t_kladr        kl
              ,ins.tmpl_save_code tmp
         WHERE ca.id = par_adr_id
           AND upper(kl.name) = upper(ca.region_name)
           AND upper(kl.socr) = upper(ca.region_type)
           AND tmp.adr_id = ca.id
           AND tmp.plevel = 1
           AND kl.code LIKE '_____000000__'
           AND substr(tmp.code, 1, 2) = substr(kl.code, 1, 2)
           AND to_number(substr(kl.code, -2)) =
               (SELECT to_number(MIN(substr(kla.code, -2)))
                  FROM ins.t_kladr kla
                 WHERE kla.code LIKE '_____000000__'
                   AND upper(kla.name) = upper(ca.region_name)
                   AND upper(kla.socr) = upper(ca.region_type)
                   AND substr(kl.code, 1, 2) = substr(kla.code, 1, 2))
           AND substr(kl.code, -2) NOT IN ('99', '51');
      IF SQL%ROWCOUNT = 0
         OR SQL%ROWCOUNT > 1
      THEN
        DELETE FROM tmpl_save_code
         WHERE plevel = 2
           AND adr_id = par_adr_id;
        INSERT INTO tmpl_save_code
          (code, adr_id, plevel, old_code, pindex)
          SELECT tmp.code
                ,ca.id
                ,2
                ,ca.code
                ,tmp.pindex
            FROM ins.cn_address     ca
                ,ins.tmpl_save_code tmp
           WHERE ca.id = par_adr_id
             AND tmp.adr_id = ca.id
             AND tmp.plevel = 1;
      END IF;
      /*******создаем записи 3 уровня**********/
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, old_code, pindex)
        SELECT kl.code
              ,ca.id
              ,3
              ,ca.code
              ,kl.pindex
          FROM ins.cn_address     ca
              ,ins.t_kladr        kl
              ,ins.tmpl_save_code tmp
         WHERE ca.id = par_adr_id
           AND upper(kl.name) = upper(ca.city_name)
           AND upper(kl.socr) = upper(ca.city_type)
           AND tmp.adr_id = ca.id
           AND tmp.plevel = 2
           AND kl.code LIKE '________000__'
           AND substr(tmp.code, 1, 5) = substr(kl.code, 1, 5)
           AND to_number(substr(kl.code, -2)) =
               (SELECT to_number(MIN(substr(kla.code, -2)))
                  FROM ins.t_kladr kla
                 WHERE kla.code LIKE '________000__'
                   AND upper(kla.name) = upper(ca.city_name)
                   AND upper(kla.socr) = upper(ca.city_type)
                   AND substr(kl.code, 1, 5) = substr(kla.code, 1, 5))
           AND substr(kl.code, -2) NOT IN ('99', '51');
      IF SQL%ROWCOUNT = 0
         OR SQL%ROWCOUNT > 1
      THEN
        DELETE FROM tmpl_save_code
         WHERE plevel = 3
           AND adr_id = par_adr_id;
        INSERT INTO tmpl_save_code
          (code, adr_id, plevel, old_code, pindex)
          SELECT tmp.code
                ,ca.id
                ,3
                ,ca.code
                ,tmp.pindex
            FROM ins.cn_address     ca
                ,ins.tmpl_save_code tmp
           WHERE ca.id = par_adr_id
             AND tmp.adr_id = ca.id
             AND tmp.plevel = 2;
      END IF;
      /********создаем записи 4 уровня******************/
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, old_code, pindex)
        SELECT kl.code
              ,ca.id
              ,4
              ,ca.code
              ,kl.pindex
          FROM ins.cn_address     ca
              ,ins.t_kladr        kl
              ,ins.tmpl_save_code tmp
         WHERE ca.id = par_adr_id
           AND upper(kl.name) = upper(ca.district_name)
           AND upper(kl.socr) = upper(ca.district_type)
           AND tmp.adr_id = ca.id
           AND tmp.plevel = 3
           AND kl.code LIKE substr(tmp.code, 1, 8) || '%'
           AND substr(kl.code, -2) =
               (SELECT lpad(to_char(MIN(to_number(substr(kla.code, -2)))), 2, '0')
                  FROM ins.t_kladr kla
                 WHERE kla.code LIKE substr(kl.code, 1, 8) || '%'
                   AND upper(kla.name) = upper(ca.district_name)
                   AND upper(kla.socr) = upper(ca.district_type))
           AND substr(kl.code, -2) NOT IN ('99', '51');
      IF SQL%ROWCOUNT = 0
         OR SQL%ROWCOUNT > 1
      THEN
        DELETE FROM tmpl_save_code
         WHERE plevel = 4
           AND adr_id = par_adr_id;
        INSERT INTO tmpl_save_code
          (code, adr_id, plevel, old_code, pindex)
          SELECT tmp.code
                ,ca.id
                ,4
                ,ca.code
                ,tmp.pindex
            FROM ins.cn_address     ca
                ,ins.tmpl_save_code tmp
           WHERE ca.id = par_adr_id
             AND tmp.adr_id = ca.id
             AND tmp.plevel = 3;
      END IF;
      /*********создаем записи 5 уровня******************/
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, old_code, pindex)
        SELECT CASE
                 WHEN length(st.code) != 17 THEN
                  substr(st.code, 1, 11) || '000000'
                 ELSE
                  st.code
               END code
              ,ca.id
              ,5
              ,ca.code
              ,st.pindex
          FROM ins.cn_address     ca
              ,ins.t_street       st
              ,ins.tmpl_save_code tmp
         WHERE ca.id = par_adr_id
           AND upper(st.name) = upper(ca.street_name)
           AND upper(st.socr) = upper(ca.street_type)
           AND tmp.adr_id = ca.id
           AND tmp.plevel = 4
           AND st.code LIKE substr(tmp.code, 1, 11) || '%'
           AND substr(st.code, -2) IN
               (SELECT lpad(to_char(MIN(to_number(substr(sta.code, -2)))), 2, '0')
                  FROM ins.t_street sta
                 WHERE sta.code LIKE substr(st.code, 1, 11) || '%'
                   AND upper(sta.name) = upper(ca.street_name)
                   AND upper(sta.socr) = upper(ca.street_type))
           AND substr(st.code, -2) NOT IN ('99', '51');
      IF SQL%ROWCOUNT = 0
         OR SQL%ROWCOUNT > 1
      THEN
        DELETE FROM tmpl_save_code
         WHERE plevel = 5
           AND adr_id = par_adr_id;
        INSERT INTO tmpl_save_code
          (code, adr_id, plevel, old_code, pindex)
          SELECT tmp.code
                ,ca.id
                ,5
                ,ca.code
                ,tmp.pindex
            FROM ins.cn_address     ca
                ,ins.tmpl_save_code tmp
           WHERE ca.id = par_adr_id
             AND tmp.adr_id = ca.id
             AND tmp.plevel = 4;
      END IF;
      /**********создаем записи 6 уровня*****************/
      UPDATE ins.t_doma og
         SET og.parse_name = ins.pkg_kladr.parse_houses_number(og.name)
       WHERE og.rowid IN (SELECT og_.rowid
                            FROM ins.tmpl_save_code tmp
                                ,ins.t_doma         og_
                           WHERE og_.code LIKE substr(TRIM(rpad(tmp.code, 15, '0')), 1, 15) || '%'
                             AND tmp.plevel = 5
                             AND tmp.adr_id = par_adr_id
                             AND og_.parse_name IS NULL);
    
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, old_code, pindex)
        SELECT td.code
              ,ca.id
              ,6
              ,ca.code
              ,td.pindex
          FROM ins.cn_address     ca
              ,ins.t_doma         td
              ,ins.tmpl_save_code tmp
         WHERE ca.id = par_adr_id
           AND (upper(td.parse_name) = upper(REPLACE(ca.house_nr, '\', '/')) OR
               regexp_instr(upper(td.parse_name)
                            ,'(^|,)' ||
                             regexp_substr(TRIM(REPLACE(UPPER(ca.house_nr), '\', '/')), '\d+.*|\d+\.*') ||
                             '(,|$)') != 0)
           AND upper(td.socr) = upper(ca.house_type) /*OR ca.house_type IS NULL*/
              /**/
           AND substr(td.code, -2) =
               (SELECT lpad(to_char(MAX(to_number(substr(tda.code, -2)))), 2, '0')
                  FROM ins.t_doma tda
                 WHERE (regexp_instr(UPPER(tda.parse_name)
                                    ,'(^|,)' ||
                                     regexp_substr(TRIM(REPLACE(UPPER(ca.house_nr), '\', '/')), '\d+.*|\d+\.*') ||
                                     '(,|$)') != 0 OR
                       UPPER(tda.parse_name) = TRIM(REPLACE(UPPER(ca.house_nr), '\', '/')))
                   AND tda.code LIKE substr(TRIM(rpad(tmp.code, 15, '0')), 1, 15) || '%')
              /**/
           AND tmp.adr_id = ca.id
           AND tmp.plevel = 5
           AND td.code LIKE substr(rpad(tmp.code, 15, '0'), 1, 15) || '%'
           AND substr(td.code, -2) NOT IN ('99', '51');
      /******обработка массива данных*****************/
      UPDATE ins.cn_address ca
         SET (ca.code, ca.code_kladr_doma, ca.index_doma) =
             (SELECT tmp.code
                    ,tmp.code
                    ,tmp.pindex
                FROM ins.tmpl_save_code tmp
               WHERE tmp.adr_id = ca.id
                 AND tmp.plevel = 6)
       WHERE ca.id = par_adr_id
         AND EXISTS (SELECT NULL
                FROM ins.tmpl_save_code tmp
               WHERE tmp.adr_id = ca.id
                 AND tmp.plevel = 6);
      IF SQL%ROWCOUNT != 1
      THEN
        UPDATE ins.cn_address ca
           SET (ca.code, ca.code_kladr_street, ca.index_street) =
               (SELECT tmp.code
                      ,tmp.code
                      ,tmp.pindex
                  FROM ins.tmpl_save_code tmp
                 WHERE tmp.adr_id = ca.id
                   AND tmp.plevel = 5)
         WHERE ca.id = par_adr_id
           AND EXISTS (SELECT NULL
                  FROM ins.tmpl_save_code tmp
                 WHERE tmp.adr_id = ca.id
                   AND tmp.plevel = 5);
        IF SQL%ROWCOUNT != 1
        THEN
          UPDATE ins.cn_address ca
             SET (ca.code, ca.code_kladr_distr, ca.index_distr) =
                 (SELECT tmp.code
                        ,tmp.code
                        ,tmp.pindex
                    FROM ins.tmpl_save_code tmp
                   WHERE tmp.adr_id = ca.id
                     AND tmp.plevel = 4)
           WHERE ca.id = par_adr_id
             AND EXISTS (SELECT NULL
                    FROM ins.tmpl_save_code tmp
                   WHERE tmp.adr_id = ca.id
                     AND tmp.plevel = 4);
          IF SQL%ROWCOUNT != 1
          THEN
            UPDATE ins.cn_address ca
               SET (ca.code, ca.code_kladr_city, ca.index_city) =
                   (SELECT tmp.code
                          ,tmp.code
                          ,tmp.pindex
                      FROM ins.tmpl_save_code tmp
                     WHERE tmp.adr_id = ca.id
                       AND tmp.plevel = 3)
             WHERE ca.id = par_adr_id
               AND EXISTS (SELECT NULL
                      FROM ins.tmpl_save_code tmp
                     WHERE tmp.adr_id = ca.id
                       AND tmp.plevel = 3);
            IF SQL%ROWCOUNT != 1
            THEN
              UPDATE ins.cn_address ca
                 SET (ca.code, ca.code_kladr_region, ca.index_region) =
                     (SELECT tmp.code
                            ,tmp.code
                            ,tmp.pindex
                        FROM ins.tmpl_save_code tmp
                       WHERE tmp.adr_id = ca.id
                         AND tmp.plevel = 2)
               WHERE ca.id = par_adr_id
                 AND EXISTS (SELECT NULL
                        FROM ins.tmpl_save_code tmp
                       WHERE tmp.adr_id = ca.id
                         AND tmp.plevel = 2);
              IF SQL%ROWCOUNT != 1
              THEN
                UPDATE ins.cn_address ca
                   SET (ca.code, ca.code_kladr_province, ca.index_province, ca.region_code) =
                       (SELECT tmp.code
                              ,tmp.code
                              ,tmp.pindex
                              ,substr(nvl(tmp.code, '00'), 1, 2)
                          FROM ins.tmpl_save_code tmp
                         WHERE tmp.adr_id = ca.id
                           AND tmp.plevel = 1
                           AND to_number(substr(tmp.code, -2)) =
                               (SELECT to_number(MAX(substr(tt.code, -2)))
                                  FROM ins.tmpl_save_code tt
                                 WHERE tt.adr_id = par_adr_id
                                   AND tt.plevel = 1))
                 WHERE ca.id = par_adr_id
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code tmp
                         WHERE tmp.adr_id = ca.id
                           AND tmp.plevel = 1);
                IF SQL%ROWCOUNT != 1
                THEN
                  INSERT INTO ins.ven_actual_journal_adr
                    (change_date, change_type, id_adress, new_value, note, old_value, user_id)
                    SELECT SYSDATE
                          ,1
                          , /*добавлена*/ca.id
                          ,
                           /*'Дата актуальности: '||*/to_char(par_date_proc, 'DD.MM.YYYY') || ',' ||
                           nvl(ca.code, 'NULL') || ',' ||
                           nvl(ca.province_type, 'NULL') || ',' ||
                           nvl(ca.province_name, 'NULL') || ',' ||
                           nvl(ca.region_type, 'NULL') || ',' ||
                           nvl(ca.region_name, 'NULL') || ',' ||
                           nvl(ca.city_type, 'NULL') || ',' ||
                           nvl(ca.city_name, 'NULL') || ',' ||
                           nvl(ca.district_type, 'NULL') || ',' ||
                           nvl(ca.district_name, 'NULL') || ',' ||
                           nvl(ca.street_type, 'NULL') || ',' ||
                           nvl(ca.street_name, 'NULL') || ',' ||
                           nvl(ca.house_type, 'NULL') || ',' ||
                           nvl(ca.house_nr, 'NULL')
                          ,'Не удалось определить код КЛАДР региона 1 ого уровня: ' ||
                           nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL')
                          ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
                           nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
                           nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
                           nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
                           nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
                           nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
                           nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
                          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
                      FROM ins.cn_address ca
                     WHERE ca.id = par_adr_id;
                  UPDATE ins.cn_address ca
                     SET ca.actual_date = par_date_proc
                   WHERE ca.id = par_adr_id;
                ELSE
                  INSERT INTO ins.ven_actual_journal_adr
                    (change_date, change_type, id_adress, new_value, note, old_value, user_id)
                    SELECT SYSDATE
                          ,1
                          , /*добавлена*/ca.id
                          ,
                           /*'Дата актуальности: '||*/to_char(par_date_proc, 'DD.MM.YYYY') || ',' ||
                           nvl(ca.code, 'NULL') || ',' ||
                           nvl(ca.province_type, 'NULL') || ',' ||
                           nvl(ca.province_name, 'NULL') || ',' ||
                           nvl(ca.region_type, 'NULL') || ',' ||
                           nvl(ca.region_name, 'NULL') || ',' ||
                           nvl(ca.city_type, 'NULL') || ',' ||
                           nvl(ca.city_name, 'NULL') || ',' ||
                           nvl(ca.district_type, 'NULL') || ',' ||
                           nvl(ca.district_name, 'NULL') || ',' ||
                           nvl(ca.street_type, 'NULL') || ',' ||
                           nvl(ca.street_name, 'NULL') || ',' ||
                           nvl(ca.house_type, 'NULL') || ',' ||
                           nvl(ca.house_nr, 'NULL')
                          ,'Ошибок нет'
                          ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' ||
                           (SELECT tmp.old_code
                              FROM ins.tmpl_save_code tmp
                             WHERE tmp.adr_id = ca.id
                               AND tmp.plevel = 6
                               AND rownum = 1) || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                           nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                           nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                           nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                           nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                           nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                           nvl(ca.house_nr, 'NULL')
                          ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
                      FROM ins.cn_address ca
                     WHERE ca.id = par_adr_id
                       AND ca.code != p_cur_code;
                  UPDATE ins.cn_address ca
                     SET ca.actual_date = par_date_proc
                   WHERE ca.id = par_adr_id;
                  BEGIN
                    SELECT 1
                      INTO par_out_number
                      FROM dual
                     WHERE EXISTS (SELECT NULL
                              FROM ins.cn_address ca
                             WHERE ca.code IS NOT NULL
                               AND ca.id = par_adr_id);
                  EXCEPTION
                    WHEN no_data_found THEN
                      par_out_number := 0;
                  END;
                END IF;
              ELSE
                INSERT INTO ins.ven_actual_journal_adr
                  (change_date, change_type, id_adress, new_value, note, old_value, user_id)
                  SELECT SYSDATE
                        ,1
                        , /*добавлена*/ca.id
                        ,to_char(par_date_proc, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
                         nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
                         nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
                         nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
                         nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
                         nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
                         nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
                        ,'Ошибок нет'
                        ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' ||
                         (SELECT tmp.old_code
                            FROM ins.tmpl_save_code tmp
                           WHERE tmp.adr_id = ca.id
                             AND tmp.plevel = 5
                             AND rownum = 1) || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                         nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                         nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                         nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                         nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                         nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                         nvl(ca.house_nr, 'NULL')
                        ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
                    FROM ins.cn_address ca
                   WHERE ca.id = par_adr_id
                     AND ca.code != p_cur_code;
                UPDATE ins.cn_address ca SET ca.actual_date = par_date_proc WHERE ca.id = par_adr_id;
                BEGIN
                  SELECT 1
                    INTO par_out_number
                    FROM dual
                   WHERE EXISTS (SELECT NULL
                            FROM ins.cn_address ca
                           WHERE ca.code IS NOT NULL
                             AND ca.id = par_adr_id);
                EXCEPTION
                  WHEN no_data_found THEN
                    par_out_number := 0;
                END;
              END IF;
            ELSE
              INSERT INTO ins.ven_actual_journal_adr
                (change_date, change_type, id_adress, new_value, note, old_value, user_id)
                SELECT SYSDATE
                      ,1
                      , /*добавлена*/ca.id
                      ,to_char(par_date_proc, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
                       nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
                       nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
                       nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
                       nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
                       nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
                       nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
                      ,'Ошибок нет'
                      ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' ||
                       (SELECT tmp.old_code
                          FROM ins.tmpl_save_code tmp
                         WHERE tmp.adr_id = ca.id
                           AND tmp.plevel = 4
                           AND rownum = 1) || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                       nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                       nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                       nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                       nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                       nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                       nvl(ca.house_nr, 'NULL')
                      ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
                  FROM ins.cn_address ca
                 WHERE ca.id = par_adr_id
                   AND ca.code != p_cur_code;
              UPDATE ins.cn_address ca SET ca.actual_date = par_date_proc WHERE ca.id = par_adr_id;
              BEGIN
                SELECT 1
                  INTO par_out_number
                  FROM dual
                 WHERE EXISTS (SELECT NULL
                          FROM ins.cn_address ca
                         WHERE ca.code IS NOT NULL
                           AND ca.id = par_adr_id);
              EXCEPTION
                WHEN no_data_found THEN
                  par_out_number := 0;
              END;
            END IF;
          ELSE
            INSERT INTO ins.ven_actual_journal_adr
              (change_date, change_type, id_adress, new_value, note, old_value, user_id)
              SELECT SYSDATE
                    ,1
                    , /*добавлена*/ca.id
                    ,to_char(par_date_proc, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
                     nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
                     nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
                     nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
                     nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
                     nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
                     nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
                    ,'Ошибок нет'
                    ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' ||
                     (SELECT tmp.old_code
                        FROM ins.tmpl_save_code tmp
                       WHERE tmp.adr_id = ca.id
                         AND tmp.plevel = 3
                         AND rownum = 1) || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                     nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                     nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                     nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                     nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                     nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                     nvl(ca.house_nr, 'NULL')
                    ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
                FROM ins.cn_address ca
               WHERE ca.id = par_adr_id
                 AND ca.code != p_cur_code;
            UPDATE ins.cn_address ca SET ca.actual_date = par_date_proc WHERE ca.id = par_adr_id;
            BEGIN
              SELECT 1
                INTO par_out_number
                FROM dual
               WHERE EXISTS (SELECT NULL
                        FROM ins.cn_address ca
                       WHERE ca.code IS NOT NULL
                         AND ca.id = par_adr_id);
            EXCEPTION
              WHEN no_data_found THEN
                par_out_number := 0;
            END;
          END IF;
        ELSE
          INSERT INTO ins.ven_actual_journal_adr
            (change_date, change_type, id_adress, new_value, note, old_value, user_id)
            SELECT SYSDATE
                  ,1
                  , /*добавлена*/ca.id
                  ,to_char(par_date_proc, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
                   nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
                   nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
                   nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
                   nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
                   nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
                   nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
                  ,'Ошибок нет'
                  ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' ||
                   (SELECT tmp.old_code
                      FROM ins.tmpl_save_code tmp
                     WHERE tmp.adr_id = ca.id
                       AND tmp.plevel = 2
                       AND rownum = 1) || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                   nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                   nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                   nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                   nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                   nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                   nvl(ca.house_nr, 'NULL')
                  ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
              FROM ins.cn_address ca
             WHERE ca.id = par_adr_id
               AND ca.code != p_cur_code;
          UPDATE ins.cn_address ca SET ca.actual_date = par_date_proc WHERE ca.id = par_adr_id;
          BEGIN
            SELECT 1
              INTO par_out_number
              FROM dual
             WHERE EXISTS (SELECT NULL
                      FROM ins.cn_address ca
                     WHERE ca.code IS NOT NULL
                       AND ca.id = par_adr_id);
          EXCEPTION
            WHEN no_data_found THEN
              par_out_number := 0;
          END;
        END IF;
      ELSE
        INSERT INTO ins.ven_actual_journal_adr
          (change_date, change_type, id_adress, new_value, note, old_value, user_id)
          SELECT SYSDATE
                ,1
                , /*добавлена*/ca.id
                ,to_char(par_date_proc, 'DD.MM.YYYY') || ',' || nvl(ca.code, 'NULL') || ',' ||
                 nvl(ca.province_type, 'NULL') || ',' || nvl(ca.province_name, 'NULL') || ',' ||
                 nvl(ca.region_type, 'NULL') || ',' || nvl(ca.region_name, 'NULL') || ',' ||
                 nvl(ca.city_type, 'NULL') || ',' || nvl(ca.city_name, 'NULL') || ',' ||
                 nvl(ca.district_type, 'NULL') || ',' || nvl(ca.district_name, 'NULL') || ',' ||
                 nvl(ca.street_type, 'NULL') || ',' || nvl(ca.street_name, 'NULL') || ',' ||
                 nvl(ca.house_type, 'NULL') || ',' || nvl(ca.house_nr, 'NULL')
                ,'Ошибок нет'
                ,to_char(ca.actual_date, 'DD.MM.YYYY') || ',' ||
                 (SELECT tmp.old_code
                    FROM ins.tmpl_save_code tmp
                   WHERE tmp.adr_id = ca.id
                     AND tmp.plevel = 1) || ',' || nvl(ca.province_type, 'NULL') || ',' ||
                 nvl(ca.province_name, 'NULL') || ',' || nvl(ca.region_type, 'NULL') || ',' ||
                 nvl(ca.region_name, 'NULL') || ',' || nvl(ca.city_type, 'NULL') || ',' ||
                 nvl(ca.city_name, 'NULL') || ',' || nvl(ca.district_type, 'NULL') || ',' ||
                 nvl(ca.district_name, 'NULL') || ',' || nvl(ca.street_type, 'NULL') || ',' ||
                 nvl(ca.street_name, 'NULL') || ',' || nvl(ca.house_type, 'NULL') || ',' ||
                 nvl(ca.house_nr, 'NULL')
                ,(SELECT us.sys_user_id FROM ins.sys_user us WHERE us.sys_user_name = USER)
            FROM ins.cn_address ca
           WHERE ca.id = par_adr_id
             AND ca.code != p_cur_code;
        UPDATE ins.cn_address ca SET ca.actual_date = par_date_proc WHERE ca.id = par_adr_id;
        BEGIN
          SELECT 1
            INTO par_out_number
            FROM dual
           WHERE EXISTS (SELECT NULL
                    FROM ins.cn_address ca
                   WHERE ca.code IS NOT NULL
                     AND ca.id = par_adr_id);
        EXCEPTION
          WHEN no_data_found THEN
            par_out_number := 0;
        END;
      END IF;
      /*********************************/
    END IF;
  EXCEPTION
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении COMPARE_TEXT_TO_KLADR: PAR_ADR_ID = ' ||
                              par_adr_id || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении COMPARE_TEXT_TO_KLADR: PAR_ADR_ID = ' ||
                              par_adr_id || ' ' || SQLERRM);
  END compare_text_to_kladr;
  /*********************************************************/
  PROCEDURE ins_text_field(par_adr_id NUMBER) IS
    v_level NUMBER;
  BEGIN
  
    SELECT CASE
             WHEN length(ca.code) = 19 THEN
              6
             WHEN length(ca.code) = 17 THEN
              5
             WHEN (length(ca.code) = 13 AND substr(ca.code, 9, 3) != '000') THEN
              4
             WHEN (length(ca.code) = 13 AND substr(ca.code, 6, 3) != '000' AND
                  substr(ca.code, 9, 3) = '000') THEN
              3
             WHEN (length(ca.code) = 13 AND substr(ca.code, 6, 6) = '000000' AND
                  substr(ca.code, 3, 3) != '000') THEN
              2
             ELSE
              1
           END
      INTO v_level
      FROM ins.cn_address ca
     WHERE ca.id = par_adr_id;
  
    IF v_level = 6
    THEN
      /*если код 6 уровня и фасет 5-ого не равен "0000"*/
      UPDATE ins.cn_address ca
         SET (ca.street_type
            ,ca.street_name
            ,
              /*ca.code,*/ca.code_kladr_street
            ,ca.index_street) =
             (SELECT st.socr
                    ,st.name
                    , /*st.code,*/st.code
                    ,st.pindex
                FROM ins.t_street st
               WHERE substr(ca.code, 1, 17) = st.code
                 AND substr(st.code, 18, 2) = '00')
       WHERE ca.id = par_adr_id
         AND length(ca.code) = 19
         AND substr(ca.code, 12, 4) != '0000'
         AND EXISTS (SELECT NULL
                FROM ins.t_street st
               WHERE substr(ca.code, 1, 17) = st.code
                 AND substr(st.code, 18, 2) = '00');
      /*если фасет 5-ого равен "0000"*/
      UPDATE ins.cn_address ca
         SET ca.street_type       = NULL
            ,ca.street_name       = NULL
            ,ca.code_kladr_street = NULL
            ,ca.index_street      = NULL
       WHERE ca.id = par_adr_id
         AND length(ca.code) = 19
         AND substr(ca.code, 12, 4) = '0000';
      /*если фасет 4-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.district_name
            ,ca.district_type
            ,
              /*ca.code,*/ca.code_kladr_distr
            ,ca.index_distr) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 11) = substr(ca.code, 1, 11)
                 AND kl.socr = sc.scname
                 AND substr(kl.code, 9, 3) != '000'
                 AND sc.plevel = 4
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 9, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 11) = substr(ca.code, 1, 11)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 4
                 AND substr(kl.code, 9, 3) != '000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 4-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.district_name    = NULL
            ,ca.district_type    = NULL
            ,ca.code_kladr_distr = NULL
            ,ca.index_distr      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 9, 3) = '000';
      /*если фасет 3-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.city_name
            ,ca.city_type
            ,
              /*ca.code,*/ca.code_kladr_city
            ,ca.index_city) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 8) = substr(ca.code, 1, 8)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND substr(kl.code, 6, 3) != '000'
                 AND substr(kl.code, 9, 3) = '000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 8) = substr(ca.code, 1, 8)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND substr(kl.code, 6, 3) != '000'
                 AND substr(kl.code, 9, 3) = '000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 3-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.city_name       = NULL
            ,ca.city_type       = NULL
            ,ca.code_kladr_city = NULL
            ,ca.index_city      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) = '000';
      /*если фасет 2-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.region_name
            ,ca.region_type
            ,
              /*ca.code,*/ca.code_kladr_region
            ,ca.index_region) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 2-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.region_name       = NULL
            ,ca.region_type       = NULL
            ,ca.code_kladr_region = NULL
            ,ca.index_region      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) = '000';
      /**/
      UPDATE ins.cn_address ca
         SET (ca.province_name
            ,ca.province_type
            ,
              /*ca.code,*/ca.code_kladr_province
            ,ca.index_province) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 1, 2) != '00'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                 ,ca.code_kladr_distr)
                                             ,ca.code_kladr_city)
                                         ,ca.code_kladr_region)
                                     ,ca.code_kladr_province)
                                 ,ca.code)
            ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                        ,ca.code_kladr_distr)
                                                    ,ca.code_kladr_city)
                                                ,ca.code_kladr_region)
                                            ,ca.code_kladr_province)
                                        ,'00')
                                    ,1
                                    ,2)
            ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street), ca.index_distr)
                                             ,ca.index_city)
                                         ,ca.index_region)
                                     ,ca.index_province)
                                 ,ca.zip)
       WHERE ca.id = par_adr_id;
      /**/
    ELSIF v_level = 5
    THEN
      UPDATE ins.cn_address ca
         SET (ca.street_type
            ,ca.street_name
            ,
              /*ca.code,*/ca.code_kladr_street
            ,ca.index_street) =
             (SELECT st.socr
                    ,st.name
                    , /*st.code,*/st.code
                    ,st.pindex
                FROM ins.t_street st
               WHERE ca.code = st.code
                 AND substr(st.code, 16, 2) = '00')
       WHERE ca.id = par_adr_id
         AND length(ca.code) = 17
         AND EXISTS (SELECT NULL
                FROM ins.t_street st
               WHERE ca.code = st.code
                 AND substr(st.code, 16, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.street_name       = NULL
            ,ca.street_type       = NULL
            ,ca.code_kladr_street = NULL
            ,ca.index_street      = NULL
       WHERE ca.id = par_adr_id
         AND length(ca.code) = 17
         AND NOT EXISTS (SELECT NULL FROM ins.t_street st WHERE ca.code = st.code);
      /*если фасет 4-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.district_name
            ,ca.district_type
            ,
              /*ca.code,*/ca.code_kladr_distr
            ,ca.index_distr) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 11) = substr(ca.code, 1, 11)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 4
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 9, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 11) = substr(ca.code, 1, 11)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 4
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 4-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.district_name    = NULL
            ,ca.district_type    = NULL
            ,ca.code_kladr_distr = NULL
            ,ca.index_distr      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 9, 3) = '000';
      /*если фасет 3-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.city_name, ca.city_type, ca.code_kladr_city, ca.index_city) =
             (SELECT kl.name
                    ,kl.socr
                    ,kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE kl.code LIKE substr(ca.code, 1, 8) || '%'
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND kl.code NOT LIKE '_____000%'
                 AND kl.code LIKE '________000__'
                 AND kl.code LIKE '___________00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE kl.code LIKE substr(ca.code, 1, 8) || '%'
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND kl.code NOT LIKE '_____000%'
                 AND kl.code LIKE '________000__'
                 AND kl.code LIKE '___________00');
      /*если фасет 3-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.city_name       = NULL
            ,ca.city_type       = NULL
            ,ca.code_kladr_city = NULL
            ,ca.index_city      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) = '000';
      /*если фасет 2-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.region_name
            ,ca.region_type
            ,
              /*ca.code,*/ca.code_kladr_region
            ,ca.index_region) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 2-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.region_name       = NULL
            ,ca.region_type       = NULL
            ,ca.code_kladr_region = NULL
            ,ca.index_region      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) = '000';
      /**/
      UPDATE ins.cn_address ca
         SET (ca.province_name
            ,ca.province_type
            ,
              /*ca.code,*/ca.code_kladr_province
            ,ca.index_province) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE kl.code LIKE substr(ca.code, 1, 2) || '%'
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND kl.code NOT LIKE '00%'
                 AND kl.code LIKE '__000000000%'
                 AND kl.code LIKE '___________00')
       WHERE ca.id = par_adr_id
         AND ca.code NOT LIKE '00%'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE kl.code LIKE substr(ca.code, 1, 2) || '%'
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND kl.code NOT LIKE '00%'
                 AND kl.code LIKE '__000000000%'
                 AND kl.code LIKE '___________00');
      UPDATE ins.cn_address ca
         SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                 ,ca.code_kladr_distr)
                                             ,ca.code_kladr_city)
                                         ,ca.code_kladr_region)
                                     ,ca.code_kladr_province)
                                 ,ca.code)
            ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                        ,ca.code_kladr_distr)
                                                    ,ca.code_kladr_city)
                                                ,ca.code_kladr_region)
                                            ,ca.code_kladr_province)
                                        ,'00')
                                    ,1
                                    ,2)
            ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street), ca.index_distr)
                                             ,ca.index_city)
                                         ,ca.index_region)
                                     ,ca.index_province)
                                 ,ca.zip)
       WHERE ca.id = par_adr_id;
      /**/
    ELSIF v_level = 4
    THEN
      UPDATE ins.cn_address ca
         SET ca.street_name       = NULL
            ,ca.street_type       = NULL
            ,ca.code_kladr_street = NULL
            ,ca.index_street      = NULL
       WHERE ca.id = par_adr_id;
      /**/
      UPDATE ins.cn_address ca
         SET (ca.district_type
            ,ca.district_name
            ,
              /*ca.code,*/ca.code_kladr_distr
            ,ca.index_distr) =
             (SELECT kl.socr
                    ,kl.name
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(ca.code, 1, 11) = substr(kl.code, 1, 11)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 4
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 9, 3) != '000'
         AND length(ca.code) = 13
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(ca.code, 1, 11) = substr(kl.code, 1, 11)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 4
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.district_name    = NULL
            ,ca.district_type    = NULL
            ,ca.code_kladr_distr = NULL
            ,ca.index_distr      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 9, 3) = '000';
      /*если фасет 3-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.city_name
            ,ca.city_type
            ,
              /*ca.code,*/ca.code_kladr_city
            ,ca.index_city) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 8) = substr(ca.code, 1, 8)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND substr(kl.code, 6, 3) != '000'
                 AND substr(kl.code, 9, 3) = '000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 8) = substr(ca.code, 1, 8)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND substr(kl.code, 6, 3) != '000'
                 AND substr(kl.code, 9, 3) = '000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 3-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.city_name       = NULL
            ,ca.city_type       = NULL
            ,ca.code_kladr_city = NULL
            ,ca.index_city      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) = '000';
      /*если фасет 2-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.region_name
            ,ca.region_type
            ,
              /*ca.code,*/ca.code_kladr_region
            ,ca.index_region) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 2-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.region_name       = NULL
            ,ca.region_type       = NULL
            ,ca.code_kladr_region = NULL
            ,ca.index_region      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) = '000';
      /**/
      UPDATE ins.cn_address ca
         SET (ca.province_name
            ,ca.province_type
            ,
              /*ca.code,*/ca.code_kladr_province
            ,ca.index_province) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 1, 2) != '00'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                 ,ca.code_kladr_distr)
                                             ,ca.code_kladr_city)
                                         ,ca.code_kladr_region)
                                     ,ca.code_kladr_province)
                                 ,ca.code)
            ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                        ,ca.code_kladr_distr)
                                                    ,ca.code_kladr_city)
                                                ,ca.code_kladr_region)
                                            ,ca.code_kladr_province)
                                        ,'00')
                                    ,1
                                    ,2)
            ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street), ca.index_distr)
                                             ,ca.index_city)
                                         ,ca.index_region)
                                     ,ca.index_province)
                                 ,ca.zip)
       WHERE ca.id = par_adr_id;
      /**/
    ELSIF v_level = 3
    THEN
      UPDATE ins.cn_address ca
         SET ca.street_name       = NULL
            ,ca.street_type       = NULL
            ,ca.code_kladr_street = NULL
            ,ca.index_street      = NULL
       WHERE ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.district_name    = NULL
            ,ca.district_type    = NULL
            ,ca.code_kladr_distr = NULL
            ,ca.index_distr      = NULL
       WHERE ca.id = par_adr_id;
      /**/
      UPDATE ins.cn_address ca
         SET (ca.city_name
            ,ca.city_type
            ,
              /*ca.code,*/ca.code_kladr_city
            ,ca.index_city) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(ca.code, 1, 8) = substr(kl.code, 1, 8)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND substr(kl.code, 6, 3) != '000'
                 AND substr(kl.code, 9, 3) = '000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) != '000'
         AND length(ca.code) = 13
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(ca.code, 1, 8) = substr(kl.code, 1, 8)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 3
                 AND substr(kl.code, 6, 3) != '000'
                 AND substr(kl.code, 9, 3) = '000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.city_name       = NULL
            ,ca.city_type       = NULL
            ,ca.code_kladr_city = NULL
            ,ca.index_city      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 6, 3) = '000';
      /*если фасет 2-ого не равен "000"*/
      UPDATE ins.cn_address ca
         SET (ca.region_name
            ,ca.region_type
            ,
              /*ca.code,*/ca.code_kladr_region
            ,ca.index_region) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00');
      /*если фасет 2-ого равен "000"*/
      UPDATE ins.cn_address ca
         SET ca.region_name       = NULL
            ,ca.region_type       = NULL
            ,ca.code_kladr_region = NULL
            ,ca.index_region      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) = '000';
      /**/
      UPDATE ins.cn_address ca
         SET (ca.province_name
            ,ca.province_type
            ,
              /*ca.code,*/ca.code_kladr_province
            ,ca.index_province) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 1, 2) != '00'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                 ,ca.code_kladr_distr)
                                             ,ca.code_kladr_city)
                                         ,ca.code_kladr_region)
                                     ,ca.code_kladr_province)
                                 ,ca.code)
            ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                        ,ca.code_kladr_distr)
                                                    ,ca.code_kladr_city)
                                                ,ca.code_kladr_region)
                                            ,ca.code_kladr_province)
                                        ,'00')
                                    ,1
                                    ,2)
            ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street), ca.index_distr)
                                             ,ca.index_city)
                                         ,ca.index_region)
                                     ,ca.index_province)
                                 ,ca.zip)
       WHERE ca.id = par_adr_id;
      /**/
    ELSIF v_level = 2
    THEN
      UPDATE ins.cn_address ca
         SET ca.street_name       = NULL
            ,ca.street_type       = NULL
            ,ca.code_kladr_street = NULL
            ,ca.index_street      = NULL
       WHERE ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.city_name       = NULL
            ,ca.city_type       = NULL
            ,ca.code_kladr_city = NULL
            ,ca.index_city      = NULL
       WHERE ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.district_name    = NULL
            ,ca.district_type    = NULL
            ,ca.code_kladr_distr = NULL
            ,ca.index_distr      = NULL
       WHERE ca.id = par_adr_id;
      /**/
      UPDATE ins.cn_address ca
         SET (ca.region_name
            ,ca.region_type
            ,
              /*ca.code,*/ca.code_kladr_region
            ,ca.index_region) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) != '000'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 5) = substr(ca.code, 1, 5)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 2
                 AND substr(kl.code, 3, 3) != '000'
                 AND substr(kl.code, 6, 6) = '000000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.region_name       = NULL
            ,ca.region_type       = NULL
            ,ca.code_kladr_region = NULL
            ,ca.index_region      = NULL
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 3, 3) = '000';
      /**/
      UPDATE ins.cn_address ca
         SET (ca.province_name
            ,ca.province_type
            ,
              /*ca.code,*/ca.code_kladr_province
            ,ca.index_province) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 1, 2) != '00'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                 ,ca.code_kladr_distr)
                                             ,ca.code_kladr_city)
                                         ,ca.code_kladr_region)
                                     ,ca.code_kladr_province)
                                 ,ca.code)
            ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                        ,ca.code_kladr_distr)
                                                    ,ca.code_kladr_city)
                                                ,ca.code_kladr_region)
                                            ,ca.code_kladr_province)
                                        ,'00')
                                    ,1
                                    ,2)
            ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street), ca.index_distr)
                                             ,ca.index_city)
                                         ,ca.index_region)
                                     ,ca.index_province)
                                 ,ca.zip)
       WHERE ca.id = par_adr_id;
    ELSE
      UPDATE ins.cn_address ca
         SET ca.street_name       = NULL
            ,ca.street_type       = NULL
            ,ca.code_kladr_street = NULL
            ,ca.index_street      = NULL
       WHERE ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.city_name       = NULL
            ,ca.city_type       = NULL
            ,ca.code_kladr_city = NULL
            ,ca.index_city      = NULL
       WHERE ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.district_name    = NULL
            ,ca.district_type    = NULL
            ,ca.code_kladr_distr = NULL
            ,ca.index_distr      = NULL
       WHERE ca.id = par_adr_id;
      UPDATE ins.cn_address ca
         SET ca.region_name       = NULL
            ,ca.region_type       = NULL
            ,ca.code_kladr_region = NULL
            ,ca.index_region      = NULL
       WHERE ca.id = par_adr_id;
      /**/
      UPDATE ins.cn_address ca
         SET (ca.province_name
            ,ca.province_type
            ,
              /*ca.code,*/ca.code_kladr_province
            ,ca.index_province) =
             (SELECT kl.name
                    ,kl.socr
                    , /*kl.code,*/kl.code
                    ,kl.pindex
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00')
       WHERE ca.id = par_adr_id
         AND substr(ca.code, 1, 2) != '00'
         AND EXISTS (SELECT NULL
                FROM ins.t_kladr    kl
                    ,ins.t_socrbase sc
               WHERE substr(kl.code, 1, 2) = substr(ca.code, 1, 2)
                 AND kl.socr = sc.scname
                 AND sc.plevel = 1
                 AND substr(kl.code, 1, 2) != '00'
                 AND substr(kl.code, 3, 9) = '000000000'
                 AND substr(kl.code, 12, 2) = '00');
      UPDATE ins.cn_address ca
         SET ca.code        = nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                 ,ca.code_kladr_distr)
                                             ,ca.code_kladr_city)
                                         ,ca.code_kladr_region)
                                     ,ca.code_kladr_province)
                                 ,ca.code)
            ,ca.region_code = substr(nvl(nvl(nvl(nvl(nvl(nvl(ca.code_kladr_doma, ca.code_kladr_street)
                                                        ,ca.code_kladr_distr)
                                                    ,ca.code_kladr_city)
                                                ,ca.code_kladr_region)
                                            ,ca.code_kladr_province)
                                        ,'00')
                                    ,1
                                    ,2)
            ,ca.zip         = nvl(nvl(nvl(nvl(nvl(nvl(ca.index_doma, ca.index_street), ca.index_distr)
                                             ,ca.index_city)
                                         ,ca.index_region)
                                     ,ca.index_province)
                                 ,ca.zip)
       WHERE ca.id = par_adr_id;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении INS_TEXT_FIELD ' || SQLERRM);
    
  END ins_text_field;
  /*******************************************************/
  FUNCTION find_correct_index(par_adr_id NUMBER) RETURN VARCHAR2 IS
    v_res   VARCHAR2(25);
    v_index VARCHAR2(25);
  BEGIN
    FOR cur IN (SELECT p_code
                      ,p_tbl
                  FROM (SELECT ca.code p_code
                              ,6 p_level
                              ,'T_DOMA' p_tbl /*6*/
                          FROM ins.cn_address ca
                         WHERE ca.id = par_adr_id
                           AND length(ca.code) = 19
                           AND ca.zip IS NOT NULL
                        UNION
                        SELECT substr(ca.code, 1, 15) || '00' p_code
                              ,5 p_level
                              ,'T_STREET' p_tbl /*5*/
                          FROM ins.cn_address ca
                         WHERE ca.id = par_adr_id
                           AND length(ca.code) = 17
                           AND ca.zip IS NOT NULL
                        UNION
                        SELECT substr(ca.code, 1, 11) || '00' p_code
                              ,4 p_level
                              ,'T_KLADR' p_tbl /*4*/
                          FROM ins.cn_address ca
                         WHERE ca.id = par_adr_id
                           AND ca.code IS NOT NULL
                           AND ca.zip IS NOT NULL
                        UNION
                        SELECT substr(ca.code, 1, 8) || '00000' p_code
                              ,3 p_level
                              ,'T_KLADR' p_tbl /*3*/
                          FROM ins.cn_address ca
                         WHERE ca.id = par_adr_id
                           AND ca.zip IS NOT NULL
                           AND ca.code IS NOT NULL
                        UNION
                        SELECT substr(ca.code, 1, 5) || '00000000' p_code
                              ,2 p_level
                              ,'T_KLADR' p_tbl /*2*/
                          FROM ins.cn_address ca
                         WHERE ca.id = par_adr_id
                           AND ca.zip IS NOT NULL
                           AND ca.code IS NOT NULL
                        UNION
                        SELECT substr(ca.code, 1, 2) || '00000000000' p_code
                              ,1 p_level
                              ,'T_KLADR' p_tbl /*1*/
                          FROM ins.cn_address ca
                         WHERE ca.id = par_adr_id
                           AND ca.zip IS NOT NULL
                           AND ca.code IS NOT NULL)
                 ORDER BY p_level DESC)
    LOOP
      IF cur.p_tbl = 'T_DOMA'
      THEN
        BEGIN
          SELECT dt.pindex
            INTO v_index
            FROM ins.t_doma dt
           WHERE dt.code = cur.p_code
             AND substr(dt.code, -2) != '99';
        EXCEPTION
          WHEN no_data_found THEN
            v_index := 'X';
        END;
      END IF;
      IF cur.p_tbl = 'T_STREET'
      THEN
        BEGIN
          SELECT st.pindex
            INTO v_index
            FROM ins.t_street st
           WHERE st.code = cur.p_code
             AND substr(st.code, -2) != '99';
        EXCEPTION
          WHEN no_data_found THEN
            v_index := 'X';
        END;
      END IF;
      IF cur.p_tbl = 'T_KLADR'
      THEN
        BEGIN
          SELECT kl.pindex
            INTO v_index
            FROM ins.t_kladr kl
           WHERE kl.code = cur.p_code
             AND substr(kl.code, -2) != '99'
          /*AND ROWNUM = 1*/
          ;
        EXCEPTION
          WHEN no_data_found THEN
            v_index := 'X';
        END;
      END IF;
      IF SQL%ROWCOUNT != 0
      THEN
        EXIT;
      END IF;
    END LOOP;
  
    BEGIN
      SELECT ind.pnindex
        INTO v_res
        FROM ins.t_npindx ind
       WHERE nvl(ind.pindex, 'X') = v_index
         AND nvl(ind.pnindex, 'X') != 'X'
         AND nvl(ind.pindex, 'X') != 'X';
    EXCEPTION
      WHEN no_data_found THEN
        v_res := 'X';
    END;
  
    IF v_res != 'X'
    THEN
      RETURN v_res;
    ELSE
      RETURN v_index;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении FIND_CORRECT_INDEX PAR_ADR_ID = ' || par_adr_id || '; ' ||
                              SQLERRM);
    
  END find_correct_index;
  /*******************************************************/
  PROCEDURE get_str_for_job IS
  BEGIN
  
    DELETE FROM ins.set_str_for_job jb
     WHERE EXISTS (SELECT NULL
              FROM ins.cn_address ca
             WHERE ca.actual = 1
               AND ca.id = jb.cn_address_id
               AND nvl(ca.decompos_permis, 0) = 1);
    COMMIT;
    INSERT INTO ins.set_str_for_job
      (SELECT ca.id adr_id
             ,ca.decompos_permis
         FROM ins.cn_address ca
        WHERE nvl(ca.decompos_date, to_date('01.01.1899', 'dd.mm.yyyy')) <
              (SELECT nvl(MAX(uj.change_date), to_date('01.01.1900', 'dd.mm.yyyy'))
                 FROM ins.update_journal_kladr uj)
          AND ca.street_name IS NULL
          AND ca.code IS NULL
          AND ca.zip IS NULL
          AND ca.district_type IS NULL
          AND ca.district_name IS NULL
          AND ca.region_type IS NULL
          AND ca.region_name IS NULL
          AND ca.province_type IS NULL
          AND ca.province_name IS NULL
          AND ca.city_type IS NULL
          AND ca.city_name IS NULL
          AND ca.street_type IS NULL
          AND ca.house_nr IS NULL
          AND ca.appartment_nr IS NULL
          AND length(ca.name) - length(REPLACE(ca.name, ',')) >= 3
          AND nvl(ca.decompos_permis, 0) = 0
          AND rownum <= 100
       /*AND ca.id IN (6028649,6031321)*/
       UNION ALL
       SELECT ca.id adr_id
             ,ca.decompos_permis
         FROM ins.cn_address ca
        WHERE nvl(ca.decompos_date, '01.01.1899') <
              (SELECT nvl(MAX(uj.change_date), to_date('01.01.1900', 'dd.mm.yyyy'))
                 FROM ins.update_journal_kladr uj)
          AND ca.street_name IS NULL
          AND ca.code IS NULL
          AND ca.zip IS NULL
          AND ca.district_type IS NULL
          AND ca.district_name IS NULL
          AND ca.region_type IS NULL
          AND ca.region_name IS NULL
          AND ca.province_type IS NULL
          AND ca.province_name IS NULL
          AND ca.city_type IS NULL
          AND ca.city_name IS NULL
          AND ca.street_type IS NULL
          AND ca.house_nr IS NULL
          AND ca.appartment_nr IS NULL
          AND length(ca.name) - length(REPLACE(ca.name, ',')) = 0
          AND TRIM(ca.name) IS NOT NULL
          AND nvl(ca.decompos_permis, 0) = 0
          AND rownum <= 100
       /*AND ca.id IN (6028649,6031321)*/
       );
  
    IF SQL%ROWCOUNT != 0
    THEN
      ins.pkg_kladr.auto_recognition_adr;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_STR_FOR_JOB; ' || SQLERRM);
  END get_str_for_job;
  /*******************************************************/
  /*Процедура распознования адреса*/
  PROCEDURE auto_recognition_adr(p_adress_id NUMBER DEFAULT NULL) IS
    TYPE tt_house_rowids IS TABLE OF UROWID;
    TYPE tt_house_numbers IS TABLE OF t_doma.parse_name%TYPE;
  
    v_continue       BOOLEAN := TRUE;
    pv_code_5level   NUMBER;
    pv_code_4level   NUMBER;
    pv_code_3level   NUMBER;
    pv_code_2level   NUMBER;
    pv_code_1level   NUMBER;
    pv_error         NUMBER;
    vt_house_rowids  tt_house_rowids;
    vt_house_numbers tt_house_numbers;
  
    tv_addresses t_number_type;
  BEGIN
    SAVEPOINT auto_recognition_adr_beg;
    -- Отбираем записи для распознавания
    SELECT ca.id adr_id BULK COLLECT
      INTO tv_addresses
      FROM ins.cn_address ca
     WHERE (ca.decompos_date IS NULL OR
           ca.decompos_date < (SELECT MAX(uj.change_date) FROM ins.update_journal_kladr uj))
       AND ca.street_name IS NULL
       AND ca.code IS NULL
       AND ca.zip IS NULL
       AND ca.district_type IS NULL
       AND ca.district_name IS NULL
       AND ca.region_type IS NULL
       AND ca.region_name IS NULL
       AND ca.province_type IS NULL
       AND ca.province_name IS NULL
       AND ca.city_type IS NULL
       AND ca.city_name IS NULL
       AND ca.street_type IS NULL
       AND ca.house_nr IS NULL
       AND ca.appartment_nr IS NULL
       AND (length(ca.name) - length(REPLACE(ca.name, ',')) >= 3 OR
           length(ca.name) - length(REPLACE(ca.name, ',')) = 0)
       AND ca.decompos_permis = 0
       AND ((ca.id = p_adress_id AND p_adress_id IS NOT NULL) OR
           (p_adress_id IS NULL AND rownum <= 500))
    -- Блокируем от изменений другими сессиями
       FOR UPDATE;
  
    DELETE FROM tmpl_adr_name;
    DELETE FROM tmpl_save_code;
    FOR cur IN (SELECT pkg_utils.get_splitted_string(TRIM(regexp_replace(REPLACE(REPLACE(upper(ca.name)
                                                                                        ,'.'
                                                                                        ,' ')
                                                                                ,'Россия')
                                                                        ,'( )\1+'
                                                                        ,'\1'))
                                                    ,',') tbl
                      ,ca.id adr_id
                      ,ca.rowid AS rid
                      ,ca.name adr_name
                  FROM ins.cn_address ca
                 WHERE ca.id IN (SELECT column_value FROM TABLE(tv_addresses))
                   AND length(ca.name) - length(REPLACE(ca.name, ',')) >= 3
                UNION ALL
                SELECT pkg_utils.get_splitted_string(regexp_substr(ca.name, '^\d{6}') || ',' ||
                                                     TRIM(regexp_replace(REPLACE(REPLACE((
                                                                                         
                                                                                          regexp_replace(regexp_replace(substr(REPLACE(REPLACE(TRIM(REPLACE(TRIM(regexp_replace(TRIM(regexp_replace(REPLACE(upper(ca.name)
                                                                                                                                                                                                           ,'.'
                                                                                                                                                                                                           ,'. ')
                                                                                                                                                                                                   ,'( )\1+'
                                                                                                                                                                                                   ,'\1'))
                                                                                                                                                                               ,'^\d+'))
                                                                                                                                                           ,'РОССИЯ'))
                                                                                                                                              ,' КВ.'
                                                                                                                                              ,',КВ.')
                                                                                                                                      ,' Д.'
                                                                                                                                      ,',Д.')
                                                                                                                              ,1
                                                                                                                              ,regexp_instr(REPLACE(REPLACE(TRIM(REPLACE(TRIM(regexp_replace(TRIM(regexp_replace(REPLACE(upper(ca.name)
                                                                                                                                                                                                                        ,'.'
                                                                                                                                                                                                                        ,'. ')
                                                                                                                                                                                                                ,'( )\1+'
                                                                                                                                                                                                                ,'\1'))
                                                                                                                                                                                            ,'^\d+'))
                                                                                                                                                                        ,'РОССИЯ'))
                                                                                                                                                           ,' КВ.'
                                                                                                                                                           ,',КВ.')
                                                                                                                                                   ,' Д.'
                                                                                                                                                   ,',Д.')
                                                                                                                                           ,',|$'))
                                                                                                                       ,'((\s)(\S)+)(\s)'
                                                                                                                       ,'\1,') ||
                                                                                                         substr(REPLACE(REPLACE(TRIM(REPLACE(TRIM(regexp_replace(TRIM(regexp_replace(REPLACE(upper(ca.name)
                                                                                                                                                                                            ,'.'
                                                                                                                                                                                            ,'. ')
                                                                                                                                                                                    ,'( )\1+'
                                                                                                                                                                                    ,'\1'))
                                                                                                                                                                ,'^\d+'))
                                                                                                                                            ,'РОССИЯ'))
                                                                                                                               ,' КВ.'
                                                                                                                               ,',КВ.')
                                                                                                                       ,' Д.'
                                                                                                                       ,',Д.')
                                                                                                               ,regexp_instr(REPLACE(REPLACE(TRIM(REPLACE(TRIM(regexp_replace(TRIM(regexp_replace(REPLACE(upper(ca.name)
                                                                                                                                                                                                         ,'.'
                                                                                                                                                                                                         ,'. ')
                                                                                                                                                                                                 ,'( )\1+'
                                                                                                                                                                                                 ,'\1'))
                                                                                                                                                                             ,'^\d+'))
                                                                                                                                                         ,'РОССИЯ'))
                                                                                                                                            ,' КВ.'
                                                                                                                                            ,',КВ.')
                                                                                                                                    ,' Д.'
                                                                                                                                    ,',Д.')
                                                                                                                            ,',|$'))
                                                                                                        ,'(,)\1+'
                                                                                                        ,'\1')
                                                                                         
                                                                                         )
                                                                                        ,'.'
                                                                                        ,' ')
                                                                                ,'Россия')
                                                                        ,'( )\1+'
                                                                        ,'\1'))
                                                    ,',') tbl
                      ,ca.id adr_id
                      ,ca.rowid AS rid
                      ,ca.name adr_name
                  FROM ins.cn_address ca
                 WHERE ca.id IN (SELECT column_value FROM TABLE(tv_addresses))
                   AND length(ca.name) - length(REPLACE(ca.name, ',')) = 0
                   AND TRIM(ca.name) IS NOT NULL)
    LOOP
      SAVEPOINT begin_rec;
      BEGIN
        UPDATE ins.cn_address ca
           SET ca.decompos_date   = SYSDATE
              ,ca.decompos_permis = 1
              ,ca.name_old        = ca.name
         WHERE ca.rowid = cur.rid;
        /**/
        IF regexp_like(cur.adr_name, '[A-Za-z]')
        THEN
          v_continue := FALSE;
        ELSE
          v_continue := TRUE;
        END IF;
        /**/
        IF v_continue
        THEN
          IF cur.tbl.count > 0
             AND cur.tbl.count <= 7
          THEN
            /**/
            FOR i IN cur.tbl.first .. cur.tbl.last
            LOOP
              INSERT INTO tmpl_adr_name
                (adr_id, adr_num, adr_text)
              VALUES
                (cur.adr_id, i, cur.tbl(i));
            END LOOP;
            /**/
          END IF;
          /**/
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO begin_rec;
          log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Первый цикл обработки адреса.'
             ,cur.adr_id);
      END;
    END LOOP;
  
    BEGIN
      UPDATE /*+ USE_HASH (ca ta)*/ ins.cn_address ca
         SET ca.zip =
             (SELECT substr(t.adr_text, 1, 6)
                FROM tmpl_adr_name t
               WHERE t.adr_id = ca.id
                 AND regexp_like(t.adr_text, '^\d{6}'))
       WHERE EXISTS (SELECT NULL
                FROM tmpl_adr_name ta
               WHERE ta.adr_id = ca.id
                 AND regexp_like(ta.adr_text, '^\d{6}'));
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление индекса.');
    END;
  
    DELETE FROM tmpl_adr_name t WHERE regexp_like(t.adr_text, '^\d{6}');
  
    BEGIN
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, name_obj, socr_obj, pindex)
        SELECT /*+ LEADING (kl t)*/
         kl.code
        ,t.adr_id
        ,1
        ,kl.name
        ,kl.socr
        ,kl.pindex
          FROM (SELECT /*+ NO_MERGE */
                 kl.code
                ,kl.name
                ,kl.socr
                ,sc.socrname
                ,upper(kl.name) || ' ' || upper(kl.socr) name_socr
                ,upper(kl.socr) || ' ' || upper(kl.name) socr_name
                ,upper(kl.name) allname
                ,upper(kl.name) || ' ' || upper(sc.socrname) name_socrname
                ,upper(sc.socrname) || ' ' || upper(kl.name) socrname_name
                ,kl.pindex
                  FROM ins.t_kladr kl
                      ,(SELECT tsc.socrname
                              ,tsc.scname
                          FROM ins.t_socrbase tsc
                         WHERE tsc.plevel = 1) sc
                 WHERE kl.code LIKE '__000000000__'
                   AND kl.socr = sc.scname(+)) kl
              ,(SELECT /*+ NO_MERGE */
                 t.adr_id
                ,t.adr_text
                  FROM tmpl_adr_name t
                 WHERE NOT EXISTS (SELECT /*+ HASH_AJ*/
                         NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.plevel = 1
                           AND sv.adr_id = t.adr_id)) t
         WHERE kl.name_socr = TRIM(t.adr_text)
            OR kl.socr_name = TRIM(t.adr_text)
            OR kl.allname = TRIM(t.adr_text)
            OR kl.name_socrname = TRIM(t.adr_text)
            OR kl.socrname_name = TRIM(t.adr_text);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление таблицы для plevel = 1');
    END;
  
    BEGIN
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, name_obj, socr_obj, pindex)
        WITH kladr AS
         (SELECT kl.code
                ,kl.name
                ,kl.socr
                ,upper(kl.name) || ' ' || upper(kl.socr) name_socr
                ,upper(kl.socr) || ' ' || upper(kl.name) socr_name
                ,upper(kl.name) allname
                ,upper(kl.name) || ' ' || upper(sc.socrname) name_socrname
                ,upper(sc.socrname) || ' ' || upper(kl.name) socrname_name
                ,kl.pindex
            FROM ins.t_kladr kl
                ,(SELECT tsc.socrname
                        ,tsc.scname
                    FROM ins.t_socrbase tsc
                   WHERE tsc.plevel = 2) sc
           WHERE (kl.code LIKE '_____000000__' AND substr(kl.code, 3, 3) != '000')
             AND kl.socr = sc.scname(+)
             AND substr(kl.code, -2) != '99'),
        adr AS
         (SELECT t.adr_text
                ,t.adr_id
                ,substr(sv.code, 1, 2) AS sv_code
            FROM tmpl_adr_name      t
                ,ins.tmpl_save_code sv
           WHERE sv.adr_id = t.adr_id
             AND sv.plevel = 1)
        SELECT kl.code
              ,t.adr_id
              ,2
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socr = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,2
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socr_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,2
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.allname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,2
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socrname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,2
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socrname_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%';
    
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, pindex)
        SELECT sv.code
              ,sv.adr_id
              ,2
              ,sv.pindex
          FROM ins.tmpl_save_code sv
         WHERE sv.plevel = 1
           AND NOT EXISTS (SELECT NULL
                  FROM ins.tmpl_save_code sva
                 WHERE sva.plevel = 2
                   AND sva.adr_id = sv.adr_id
                   AND rownum = 1)
           AND EXISTS (SELECT NULL FROM tmpl_adr_name ta WHERE ta.adr_id = sv.adr_id);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление таблицы для plevel = 2');
    END;
  
    BEGIN
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, name_obj, socr_obj, pindex)
        WITH kladr AS
         (SELECT kl.code
                ,kl.name
                ,kl.socr
                ,upper(kl.name) || ' ' || upper(kl.socr) name_socr
                ,upper(kl.socr) || ' ' || upper(kl.name) socr_name
                ,upper(kl.name) allname
                ,upper(kl.name) || ' ' || upper(sc.socrname) name_socrname
                ,upper(sc.socrname) || ' ' || upper(kl.name) socrname_name
                ,kl.pindex
            FROM ins.t_kladr kl
                ,(SELECT tsc.socrname
                        ,tsc.scname
                    FROM ins.t_socrbase tsc
                   WHERE tsc.plevel = 3) sc
           WHERE (kl.code LIKE '________000__' AND substr(kl.code, 6, 3) != '000')
             AND kl.socr = sc.scname(+)
             AND substr(kl.code, -2) != '99'),
        adr AS
         (SELECT t.adr_text
                ,t.adr_id
                ,substr(sv.code, 1, 5) AS sv_code
            FROM tmpl_adr_name      t
                ,ins.tmpl_save_code sv
           WHERE sv.adr_id = t.adr_id
             AND sv.plevel = 2)
        SELECT kl.code
              ,t.adr_id
              ,3
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socr = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,3
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socr_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,3
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.allname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,3
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socrname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,3
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socrname_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%';
    
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, pindex)
        SELECT sv.code
              ,sv.adr_id
              ,3
              ,sv.pindex
          FROM ins.tmpl_save_code sv
         WHERE sv.plevel = 2
           AND NOT EXISTS (SELECT NULL
                  FROM ins.tmpl_save_code sva
                 WHERE sva.plevel = 3
                   AND sva.adr_id = sv.adr_id
                   AND rownum = 1)
           AND EXISTS (SELECT NULL FROM tmpl_adr_name ta WHERE ta.adr_id = sv.adr_id);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление таблицы для plevel = 3');
    END;
  
    BEGIN
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, name_obj, socr_obj, pindex)
        WITH kladr AS
         (SELECT kl.code
                ,kl.name
                ,kl.socr
                ,upper(kl.name) || ' ' || upper(kl.socr) name_socr
                ,upper(kl.socr) || ' ' || upper(kl.name) socr_name
                ,upper(kl.name) allname
                ,upper(kl.name) || ' ' || upper(sc.socrname) name_socrname
                ,upper(sc.socrname) || ' ' || upper(kl.name) socrname_name
                ,kl.pindex
            FROM ins.t_kladr kl
                ,(SELECT tsc.socrname
                        ,tsc.scname
                    FROM ins.t_socrbase tsc
                   WHERE tsc.plevel = 4) sc
           WHERE substr(kl.code, 9, 3) != '000'
             AND kl.socr = sc.scname(+)
             AND substr(kl.code, -2) != '99'),
        adr AS
         (SELECT t.adr_text
                ,t.adr_id
                ,substr(sv.code, 1, 8) sv_code
            FROM tmpl_adr_name      t
                ,ins.tmpl_save_code sv
           WHERE sv.adr_id = t.adr_id
             AND sv.plevel = 3)
        SELECT kl.code
              ,t.adr_id
              ,4
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socr = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,4
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socr_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,4
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.allname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,4
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socrname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,4
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socrname_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%';
    
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, pindex)
        SELECT sv.code
              ,sv.adr_id
              ,4
              ,sv.pindex
          FROM ins.tmpl_save_code sv
         WHERE sv.plevel = 3
           AND NOT EXISTS (SELECT NULL
                  FROM ins.tmpl_save_code sva
                 WHERE sva.plevel = 4
                   AND sva.adr_id = sv.adr_id
                   AND rownum = 1)
           AND EXISTS (SELECT NULL FROM tmpl_adr_name ta WHERE ta.adr_id = sv.adr_id);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление таблицы для plevel = 4');
    END;
  
    BEGIN
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, name_obj, socr_obj, pindex)
        WITH kladr AS
         (SELECT /*+ INLINE */
           st.code
          ,st.name
          ,st.socr
          ,upper(st.name) || ' ' || upper(st.socr) name_socr
          ,upper(st.socr) || ' ' || upper(st.name) socr_name
          ,upper(st.name) allname
          ,upper(st.name) || ' ' || upper(sc.socrname) name_socrname
          ,upper(sc.socrname) || ' ' || upper(st.name) socrname_name
          ,st.pindex
            FROM ins.t_street st
                ,(SELECT tsc.socrname
                        ,tsc.scname
                    FROM ins.t_socrbase tsc
                   WHERE tsc.plevel = 5) sc
           WHERE st.code NOT LIKE '___________0000%'
             AND st.socr = sc.scname(+)
             AND st.code NOT LIKE '%99'),
        adr AS
         (SELECT t.adr_text
                ,t.adr_id
                ,substr(sv.code, 1, 11) sv_code
            FROM tmpl_adr_name      t
                ,ins.tmpl_save_code sv
           WHERE sv.adr_id = t.adr_id
             AND sv.plevel = 4)
        SELECT kl.code
              ,t.adr_id
              ,5
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socr = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,5
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socr_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,5
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.allname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,5
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.name_socrname = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%'
        UNION ALL
        SELECT kl.code
              ,t.adr_id
              ,5
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE kl.socrname_name = TRIM(t.adr_text)
           AND kl.code LIKE t.sv_code || '%';
    
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, pindex)
        SELECT sv.code
              ,sv.adr_id
              ,5
              ,sv.pindex
          FROM ins.tmpl_save_code sv
         WHERE sv.plevel = 4
           AND NOT EXISTS (SELECT NULL
                  FROM ins.tmpl_save_code sva
                 WHERE sva.plevel = 5
                   AND sva.adr_id = sv.adr_id
                   AND rownum = 1)
           AND EXISTS (SELECT NULL FROM tmpl_adr_name ta WHERE ta.adr_id = sv.adr_id);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление таблицы для plevel = 5');
    END;
  
    BEGIN
      SELECT DISTINCT og_.rowid
                     ,ins.pkg_kladr.parse_houses_number(og_.name) BULK COLLECT
        INTO vt_house_rowids
            ,vt_house_numbers
        FROM ins.t_doma         og_
            ,tmpl_adr_name      t
            ,ins.tmpl_save_code sv
       WHERE sv.adr_id = t.adr_id
         AND sv.plevel = 5
         AND og_.code LIKE substr(TRIM(sv.code), 1, 15) || '%'
         AND og_.parse_name IS NULL;
    
      FORALL v_idx IN vt_house_numbers.first .. vt_house_numbers.last
        UPDATE ins.t_doma og
           SET og.parse_name = vt_house_numbers(v_idx)
         WHERE og.rowid = vt_house_rowids(v_idx);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Парсинг PARSE_HOUSES_NUMBER');
    END;
  
    BEGIN
      INSERT INTO tmpl_save_code
        (code, adr_id, plevel, name_obj, socr_obj, pindex)
        WITH kladr AS
         (SELECT td.code
                ,td.name
                ,td.socr
                ,upper(td.parse_name) parse_name
                ,td.pindex
            FROM ins.t_doma td),
        adr AS
         (SELECT /*+ LEADING (t sv)*/
           REPLACE(t.adr_text, '\', '/') ||
           (SELECT regexp_replace(ta.adr_text, '(ОРП|\.|\s|,)+')
              FROM tmpl_adr_name ta
             WHERE ta.adr_id = t.adr_id
               AND regexp_like(upper(ta.adr_text), '(^\s?КОРП.{0,2}(\d|\w)+)')) adr_text
          ,t.adr_id
          ,substr(sv.code, 1, 15) sv_code
            FROM tmpl_adr_name      t
                ,ins.tmpl_save_code sv
           WHERE sv.adr_id = t.adr_id
             AND sv.plevel = 5
             AND (CASE
                   WHEN length(sv.code) > 13 THEN
                    substr(sv.code, 12, 4)
                   ELSE
                    substr(sv.code, 9, 3)
                 END) != (CASE
                   WHEN length(sv.code) > 13 THEN
                    '0000'
                   ELSE
                    '000'
                 END)
             AND (regexp_instr(TRIM(t.adr_text), '^[дД].\d+\w+') != 0 OR
                 regexp_instr(TRIM(t.adr_text), '^[дД].\d+') != 0 OR
                 regexp_instr(TRIM(t.adr_text), '\d+\w.[дД]$') != 0 OR
                 regexp_instr(TRIM(t.adr_text), '(\d+\w.\дом$)|(\d+\w.\ДОМ$)') != 0 OR
                 regexp_instr(TRIM(t.adr_text), '(^ДОМ.\d+\w+)|(^дом.\d+\w+)') != 0 OR
                 regexp_instr(TRIM(t.adr_text), '(^ДОМ.\d+)|(^дом.\d+)') != 0 OR
                 regexp_instr(TRIM(t.adr_text), '\D') = 0))
        SELECT kl.code
              ,t.adr_id
              ,6
              ,kl.name
              ,kl.socr
              ,kl.pindex
          FROM kladr kl
              ,adr   t
         WHERE (regexp_instr(kl.parse_name
                            ,'(^|,)' || regexp_substr(TRIM(t.adr_text), '\d+.*|\d+\.*') || '(,|$)') != 0 OR
               kl.parse_name = TRIM(t.adr_text))
           AND kl.code LIKE t.sv_code || '%'
           AND substr(kl.code, -2) =
               (SELECT lpad(to_char(MAX(to_number(substr(tda.code, -2)))), 2, '0')
                  FROM ins.t_doma tda
                 WHERE (regexp_instr(upper(tda.parse_name)
                                    ,'(^|,)' || regexp_substr(TRIM(t.adr_text), '\d+.*|\d+\.*') ||
                                     '(,|$)') != 0 OR upper(tda.parse_name) = TRIM(t.adr_text))
                   AND tda.code LIKE t.sv_code || '%');
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление таблицы для plevel = 6');
    END;
  
    BEGIN
      UPDATE ins.cn_address ca
         SET (ca.house_nr, ca.house_type, ca.code, ca.code_kladr_doma, ca.index_doma) =
             (SELECT regexp_substr(TRIM(REPLACE(ta.adr_text, '\', '/'))
                                  ,'(\w+\d+\/\d+\w+\d+)|(\w+\d+\/\d+\w+)|(\w+\d+\/\d+)|(\d+\/\d+\w+)|(\d+\/\d+)|(\w+\d+\w+)|(\d+)|(\w+\d+)|(\d+\w+)') ||
                     (SELECT regexp_replace(tat.adr_text, '(ОРП|\.|\s|,)+')
                        FROM tmpl_adr_name tat
                       WHERE ta.adr_id = tat.adr_id
                         AND regexp_like(upper(tat.adr_text), '(^\s?КОРП.{0,2}(\d|\w)+)'))
                     /*sv.name_obj*/
                    ,'ДОМ'
                    ,sv.code
                    ,sv.code
                    ,sv.pindex
                FROM ins.tmpl_save_code sv
                    ,tmpl_adr_name      ta
               WHERE sv.adr_id = ta.adr_id
                 AND sv.adr_id = ca.id
                 AND sv.plevel = 6
                 AND rownum = 1
                 AND (regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/')), '^[дД].\d+\w+') != 0 OR
                     regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/')), '^[дД].\d+') != 0 OR
                     regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/')), '\d+\w.[дД]$') != 0 OR
                     regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/'))
                                  ,'(\d+\w.\дом$)|(\d+\w.\ДОМ$)') != 0 OR
                     regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/'))
                                  ,'(^ДОМ.\d+\w+)|(^дом.\d+\w+)') != 0 OR
                     regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/')), '(^ДОМ.\d+)|(^дом.\d+)') != 0 OR
                     regexp_instr(TRIM(REPLACE(ta.adr_text, '\', '/')), '\D') = 0))
       WHERE EXISTS (SELECT NULL
                FROM ins.tmpl_save_code s
               WHERE ca.id = s.adr_id
                 AND s.plevel = 6);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление значения дома.');
    END;
  
    BEGIN
      UPDATE ins.cn_address ca
         SET ca.appartment_nr =
             (SELECT substr(TRIM(REPLACE(ta.adr_text, '\', '/')), 1, 9)
                FROM tmpl_adr_name ta
               WHERE ca.id = ta.adr_id
                 AND regexp_instr(REPLACE(ta.adr_text, '\', '/')
                                 ,'^В/Ч.\d+\w+|^В Ч.\d+\w+|^ВОЕННАЯ ЧАСТЬ .\d+\w+|\d+.\В/Ч$|\d+\В/Ч\d+') != 0)
       WHERE EXISTS
       (SELECT NULL
                FROM tmpl_adr_name t
               WHERE ca.id = t.adr_id
                 AND regexp_instr(REPLACE(t.adr_text, '\', '/')
                                 ,'^В/Ч.\d+\w+|^В Ч.\d+\w+|^ВОЕННАЯ ЧАСТЬ .\d+\w+|\d+.\В/Ч$|\d+\В/Ч\d+') != 0);
      UPDATE ins.cn_address ca
         SET ca.appartment_nr =
             (SELECT substr(regexp_substr(TRIM(REPLACE(ta.adr_text, '\', '/')), '\d+'), 1, 9)
                FROM tmpl_adr_name ta
               WHERE ca.id = ta.adr_id
                 AND regexp_instr(upper(TRIM(REPLACE(ta.adr_text, '\', '/')))
                                 ,'^КВ. \d+|^КВ.\d+|^КВ. \d+\w+|^КВ.\d+\w+|^К В.\d+\w+|\d+.\К/В$|\d+\К/В\d+') != 0)
       WHERE EXISTS
       (SELECT NULL
                FROM tmpl_adr_name t
               WHERE ca.id = t.adr_id
                 AND regexp_instr(upper(TRIM(REPLACE(t.adr_text, '\', '/')))
                                 ,'^КВ. \d+|^КВ.\d+|^КВ. \d+\w+|^КВ.\d+\w+|^К В.\d+\w+|\d+.\К/В$|\d+\К/В\d+') != 0);
    EXCEPTION
      WHEN OTHERS THEN
        log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Обновление значения квартиры.');
    END;
  
    FOR cr IN (SELECT adr_id
                     ,plevel
                     ,old_code
                     ,name_obj
                     ,socr_obj
                     ,pindex
                     ,lead(adr_id) over(ORDER BY adr_id, plevel) sled_adr_id
                 FROM tmpl_save_code
                ORDER BY adr_id
                        ,plevel)
    LOOP
      SAVEPOINT last_rec; --pv_mess := 'Ошибка при выполнении AUTO_RECOGNITION_ADR; Третий цикл обработки адреса; pv_adr_id = '||pv_adr_id;
      BEGIN
        IF cr.sled_adr_id != cr.adr_id
           OR cr.sled_adr_id IS NULL
        THEN
          v_continue := TRUE;
          /*шаг 39*/
          SELECT COUNT(*)
            INTO pv_code_5level
            FROM ins.tmpl_save_code sv
           WHERE sv.adr_id = cr.adr_id
             AND sv.plevel = 5
             AND substr(sv.code, -2) = '00';
          /*если 5 уровня с актульностью 00 больше одного кода, чистим адрес*/
          IF pv_code_5level > 1
          THEN
            UPDATE ins.cn_address ca
               SET ca.street_name         = NULL
                  ,ca.street_type         = NULL
                  ,ca.code                = NULL
                  ,ca.city_name           = NULL
                  ,ca.city_type           = NULL
                  ,ca.district_name       = NULL
                  ,ca.district_type       = NULL
                  ,ca.province_name       = NULL
                  ,ca.province_type       = NULL
                  ,ca.region_name         = NULL
                  ,ca.region_type         = NULL
                  ,ca.house_nr            = NULL
                  ,ca.house_type          = NULL
                  ,ca.appartment_nr       = NULL
                  ,ca.code_kladr_province = NULL
                  ,ca.code_kladr_region   = NULL
                  ,ca.code_kladr_city     = NULL
                  ,ca.code_kladr_distr    = NULL
                  ,ca.code_kladr_street   = NULL
                  ,ca.code_kladr_doma     = NULL
                  ,ca.index_province      = NULL
                  ,ca.index_region        = NULL
                  ,ca.index_city          = NULL
                  ,ca.index_distr         = NULL
                  ,ca.index_street        = NULL
                  ,ca.index_doma          = NULL
             WHERE ca.id = cr.adr_id;
            v_continue := FALSE;
            /*если 5 уровня с актульностью 00*/
          ELSIF pv_code_5level = 1
          THEN
            UPDATE ins.cn_address ca
               SET (ca.street_name, ca.street_type) =
                   (SELECT sv.name_obj
                          ,sv.socr_obj
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = cr.adr_id
                       AND sv.plevel = 5
                       AND substr(sv.code, -2) = '00')
             WHERE ca.id = cr.adr_id
               AND EXISTS (SELECT NULL
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = ca.id
                       AND sv.plevel = 5
                       AND substr(sv.code, -2) = '00');
            /**/
            UPDATE ins.cn_address ca
               SET (ca.code_kladr_street, ca.index_street) =
                   (SELECT sv.code
                          ,sv.pindex
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = cr.adr_id
                       AND sv.plevel = 5
                       AND substr(sv.code, -2) = '00'
                       AND sv.name_obj IS NOT NULL)
             WHERE ca.id = cr.adr_id
               AND EXISTS (SELECT NULL
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = ca.id
                       AND sv.plevel = 5
                       AND substr(sv.code, -2) = '00'
                       AND sv.name_obj IS NOT NULL);
            /**/
            UPDATE ins.cn_address ca
               SET ca.code =
                   (SELECT sv.code
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = cr.adr_id
                       AND sv.plevel = 5
                       AND substr(sv.code, -2) = '00')
             WHERE ca.id = cr.adr_id
               AND ca.code IS NULL
               AND EXISTS (SELECT NULL
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = ca.id
                       AND sv.plevel = 5
                       AND substr(sv.code, -2) = '00');
            /*если 5 уровня с актульностью 00 нет*/
          ELSE
            SELECT COUNT(*)
              INTO pv_code_5level
              FROM ins.tmpl_save_code sv
             WHERE sv.adr_id = cr.adr_id
               AND sv.plevel = 5
               AND substr(sv.code, -2) != '00';
            /*если 5 уровня с актульностью != 00*/
            IF pv_code_5level != 0
            THEN
              SELECT COUNT(*)
                INTO pv_error
                FROM ins.tmpl_save_code sv
               WHERE sv.adr_id = cr.adr_id
                 AND sv.plevel = 5
                 AND substr(sv.code, -2) != '00'
                 AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                     lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                              FROM ins.tmpl_save_code sva
                                             WHERE sva.adr_id = cr.adr_id
                                               AND sva.plevel = 5))
                                   ,2
                                   ,'0');
              IF pv_error = 1
              THEN
                UPDATE ins.cn_address ca
                   SET (ca.street_name, ca.street_type) =
                       (SELECT sv.name_obj
                              ,sv.socr_obj
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = cr.adr_id
                           AND sv.plevel = 5
                           AND substr(sv.code, -2) != '00'
                           AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                               lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                        FROM ins.tmpl_save_code sva
                                                       WHERE sva.adr_id = cr.adr_id
                                                         AND sva.plevel = 5))
                                             ,2
                                             ,'0'))
                 WHERE ca.id = cr.adr_id
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = ca.id
                           AND sv.plevel = 5
                           AND substr(sv.code, -2) != '00');
                /**/
                UPDATE ins.cn_address ca
                   SET (ca.code_kladr_street, ca.index_street) =
                       (SELECT sv.code
                              ,sv.pindex
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = cr.adr_id
                           AND sv.plevel = 5
                           AND substr(sv.code, -2) != '00'
                           AND sv.name_obj IS NOT NULL
                           AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                               lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                        FROM ins.tmpl_save_code sva
                                                       WHERE sva.adr_id = cr.adr_id
                                                         AND sva.plevel = 5))
                                             ,2
                                             ,'0'))
                 WHERE ca.id = cr.adr_id
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = ca.id
                           AND sv.plevel = 5
                           AND substr(sv.code, -2) != '00'
                           AND sv.name_obj IS NOT NULL);
                /**/
                UPDATE ins.cn_address ca
                   SET ca.code =
                       (SELECT sv.code
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = cr.adr_id
                           AND sv.plevel = 5
                           AND substr(sv.code, -2) != '00'
                           AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                               lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                        FROM ins.tmpl_save_code sva
                                                       WHERE sva.adr_id = cr.adr_id
                                                         AND sva.plevel = 5))
                                             ,2
                                             ,'0'))
                 WHERE ca.id = cr.adr_id
                   AND ca.code IS NULL
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = ca.id
                           AND sv.plevel = 5
                           AND substr(sv.code, -2) != '00');
              END IF;
            END IF;
          END IF;
          /*шаг 47*/
          IF v_continue
          THEN
            SELECT COUNT(*)
              INTO pv_code_4level
              FROM ins.tmpl_save_code sv
             WHERE sv.adr_id = cr.adr_id
               AND sv.plevel = 4
               AND substr(sv.code, -2) = '00';
            /*если 4 уровня с актульностью 00 больше одного кода, чистим адрес*/
            IF pv_code_4level > 1
            THEN
              UPDATE ins.cn_address ca
                 SET ca.street_name         = NULL
                    ,ca.street_type         = NULL
                    ,ca.code                = NULL
                    ,ca.city_name           = NULL
                    ,ca.city_type           = NULL
                    ,ca.district_name       = NULL
                    ,ca.district_type       = NULL
                    ,ca.province_name       = NULL
                    ,ca.province_type       = NULL
                    ,ca.region_name         = NULL
                    ,ca.region_type         = NULL
                    ,ca.house_nr            = NULL
                    ,ca.house_type          = NULL
                    ,ca.appartment_nr       = NULL
                    ,ca.code_kladr_province = NULL
                    ,ca.code_kladr_region   = NULL
                    ,ca.code_kladr_city     = NULL
                    ,ca.code_kladr_distr    = NULL
                    ,ca.code_kladr_street   = NULL
                    ,ca.code_kladr_doma     = NULL
                    ,ca.index_province      = NULL
                    ,ca.index_region        = NULL
                    ,ca.index_city          = NULL
                    ,ca.index_distr         = NULL
                    ,ca.index_street        = NULL
                    ,ca.index_doma          = NULL
               WHERE ca.id = cr.adr_id;
              v_continue := FALSE;
              /*если 4 уровня с актульностью 00*/
            ELSIF pv_code_4level = 1
            THEN
              UPDATE ins.cn_address ca
                 SET (ca.district_name, ca.district_type) =
                     (SELECT sv.name_obj
                            ,sv.socr_obj
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = cr.adr_id
                         AND sv.plevel = 4
                         AND substr(sv.code, -2) = '00')
               WHERE ca.id = cr.adr_id
                 AND EXISTS (SELECT NULL
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = ca.id
                         AND sv.plevel = 4
                         AND substr(sv.code, -2) = '00');
              /**/
              UPDATE ins.cn_address ca
                 SET (ca.code_kladr_distr, ca.index_distr) =
                     (SELECT sv.code
                            ,sv.pindex
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = cr.adr_id
                         AND sv.plevel = 4
                         AND substr(sv.code, -2) = '00'
                         AND sv.name_obj IS NOT NULL)
               WHERE ca.id = cr.adr_id
                 AND EXISTS (SELECT NULL
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = ca.id
                         AND sv.plevel = 4
                         AND substr(sv.code, -2) = '00'
                         AND sv.name_obj IS NOT NULL);
              /**/
              UPDATE ins.cn_address ca
                 SET ca.code =
                     (SELECT sv.code
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = cr.adr_id
                         AND sv.plevel = 4
                         AND substr(sv.code, -2) = '00')
               WHERE ca.id = cr.adr_id
                 AND ca.code IS NULL
                 AND EXISTS (SELECT NULL
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = ca.id
                         AND sv.plevel = 4
                         AND substr(sv.code, -2) = '00');
              /*если 4 уровня с актульностью 00 нет*/
            ELSE
              SELECT COUNT(*)
                INTO pv_code_4level
                FROM ins.tmpl_save_code sv
               WHERE sv.adr_id = cr.adr_id
                 AND sv.plevel = 4
                 AND substr(sv.code, -2) != '00';
              /*если 4 уровня с актульностью != 00*/
              IF pv_code_4level != 0
              THEN
                SELECT COUNT(*)
                  INTO pv_error
                  FROM ins.tmpl_save_code sv
                 WHERE sv.adr_id = cr.adr_id
                   AND sv.plevel = 4
                   AND substr(sv.code, -2) != '00'
                   AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                       lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                FROM ins.tmpl_save_code sva
                                               WHERE sva.adr_id = cr.adr_id
                                                 AND sva.plevel = 4))
                                     ,2
                                     ,'0');
                IF pv_error = 1
                THEN
                  UPDATE ins.cn_address ca
                     SET (ca.district_name, ca.district_type) =
                         (SELECT sv.name_obj
                                ,sv.socr_obj
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = cr.adr_id
                             AND sv.plevel = 4
                             AND substr(sv.code, -2) != '00'
                             AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                 lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                          FROM ins.tmpl_save_code sva
                                                         WHERE sva.adr_id = cr.adr_id
                                                           AND sva.plevel = 4))
                                               ,2
                                               ,'0'))
                   WHERE ca.id = cr.adr_id
                     AND EXISTS (SELECT NULL
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = ca.id
                             AND sv.plevel = 4
                             AND substr(sv.code, -2) != '00');
                  /**/
                  UPDATE ins.cn_address ca
                     SET (ca.code_kladr_distr, ca.index_distr) =
                         (SELECT sv.code
                                ,sv.pindex
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = cr.adr_id
                             AND sv.plevel = 4
                             AND substr(sv.code, -2) != '00'
                             AND sv.name_obj IS NOT NULL
                             AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                 lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                          FROM ins.tmpl_save_code sva
                                                         WHERE sva.adr_id = cr.adr_id
                                                           AND sva.plevel = 4))
                                               ,2
                                               ,'0'))
                   WHERE ca.id = cr.adr_id
                     AND EXISTS (SELECT NULL
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = ca.id
                             AND sv.plevel = 4
                             AND substr(sv.code, -2) != '00'
                             AND sv.name_obj IS NOT NULL);
                  /**/
                  UPDATE ins.cn_address ca
                     SET ca.code =
                         (SELECT sv.code
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = cr.adr_id
                             AND sv.plevel = 4
                             AND substr(sv.code, -2) != '00'
                             AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                 lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                          FROM ins.tmpl_save_code sva
                                                         WHERE sva.adr_id = cr.adr_id
                                                           AND sva.plevel = 4))
                                               ,2
                                               ,'0'))
                   WHERE ca.id = cr.adr_id
                     AND ca.code IS NULL
                     AND EXISTS (SELECT NULL
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = ca.id
                             AND sv.plevel = 4
                             AND substr(sv.code, -2) != '00');
                END IF;
              END IF;
            END IF;
            /*шаг 56*/
            IF v_continue
            THEN
              SELECT COUNT(*)
                INTO pv_code_3level
                FROM ins.tmpl_save_code sv
               WHERE sv.adr_id = cr.adr_id
                 AND sv.plevel = 3
                 AND substr(sv.code, -2) = '00';
              /*если 3 уровня с актульностью 00 больше одного кода, чистим адрес*/
              IF pv_code_3level > 1
              THEN
                UPDATE ins.cn_address ca
                   SET ca.street_name         = NULL
                      ,ca.street_type         = NULL
                      ,ca.code                = NULL
                      ,ca.city_name           = NULL
                      ,ca.city_type           = NULL
                      ,ca.district_name       = NULL
                      ,ca.district_type       = NULL
                      ,ca.province_name       = NULL
                      ,ca.province_type       = NULL
                      ,ca.region_name         = NULL
                      ,ca.region_type         = NULL
                      ,ca.house_nr            = NULL
                      ,ca.house_type          = NULL
                      ,ca.appartment_nr       = NULL
                      ,ca.code_kladr_province = NULL
                      ,ca.code_kladr_region   = NULL
                      ,ca.code_kladr_city     = NULL
                      ,ca.code_kladr_distr    = NULL
                      ,ca.code_kladr_street   = NULL
                      ,ca.code_kladr_doma     = NULL
                      ,ca.index_province      = NULL
                      ,ca.index_region        = NULL
                      ,ca.index_city          = NULL
                      ,ca.index_distr         = NULL
                      ,ca.index_street        = NULL
                      ,ca.index_doma          = NULL
                 WHERE ca.id = cr.adr_id;
                v_continue := FALSE;
                /*если 3 уровня с актульностью 00*/
              ELSIF pv_code_3level = 1
              THEN
                UPDATE ins.cn_address ca
                   SET (ca.city_name, ca.city_type) =
                       (SELECT sv.name_obj
                              ,sv.socr_obj
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = cr.adr_id
                           AND sv.plevel = 3
                           AND substr(sv.code, -2) = '00')
                 WHERE ca.id = cr.adr_id
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = ca.id
                           AND sv.plevel = 3
                           AND substr(sv.code, -2) = '00');
                /**/
                UPDATE ins.cn_address ca
                   SET (ca.code_kladr_city, ca.index_city) =
                       (SELECT sv.code
                              ,sv.pindex
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = cr.adr_id
                           AND sv.plevel = 3
                           AND substr(sv.code, -2) = '00'
                           AND sv.name_obj IS NOT NULL)
                 WHERE ca.id = cr.adr_id
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = ca.id
                           AND sv.plevel = 3
                           AND substr(sv.code, -2) = '00'
                           AND sv.name_obj IS NOT NULL);
                /**/
                UPDATE ins.cn_address ca
                   SET ca.code =
                       (SELECT sv.code
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = cr.adr_id
                           AND sv.plevel = 3
                           AND substr(sv.code, -2) = '00')
                 WHERE ca.id = cr.adr_id
                   AND ca.code IS NULL
                   AND EXISTS (SELECT NULL
                          FROM ins.tmpl_save_code sv
                         WHERE sv.adr_id = ca.id
                           AND sv.plevel = 3
                           AND substr(sv.code, -2) = '00');
                /*если 3 уровня с актульностью 00 нет*/
              ELSE
                SELECT COUNT(*)
                  INTO pv_code_3level
                  FROM ins.tmpl_save_code sv
                 WHERE sv.adr_id = cr.adr_id
                   AND sv.plevel = 3
                   AND substr(sv.code, -2) != '00';
                /*если 3 уровня с актульностью != 00*/
                IF pv_code_3level != 0
                THEN
                  SELECT COUNT(*)
                    INTO pv_error
                    FROM ins.tmpl_save_code sv
                   WHERE sv.adr_id = cr.adr_id
                     AND sv.plevel = 3
                     AND substr(sv.code, -2) != '00'
                     AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                         lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                  FROM ins.tmpl_save_code sva
                                                 WHERE sva.adr_id = cr.adr_id
                                                   AND sva.plevel = 3))
                                       ,2
                                       ,'0');
                  IF pv_error = 1
                  THEN
                    UPDATE ins.cn_address ca
                       SET (ca.city_name, ca.city_type) =
                           (SELECT sv.name_obj
                                  ,sv.socr_obj
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = cr.adr_id
                               AND sv.plevel = 3
                               AND substr(sv.code, -2) != '00'
                               AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                   lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                            FROM ins.tmpl_save_code sva
                                                           WHERE sva.adr_id = cr.adr_id
                                                             AND sva.plevel = 3))
                                                 ,2
                                                 ,'0'))
                     WHERE ca.id = cr.adr_id
                       AND EXISTS (SELECT NULL
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = ca.id
                               AND sv.plevel = 3
                               AND substr(sv.code, -2) != '00');
                    /**/
                    UPDATE ins.cn_address ca
                       SET (ca.code_kladr_city, ca.index_city) =
                           (SELECT sv.code
                                  ,sv.pindex
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = cr.adr_id
                               AND sv.plevel = 3
                               AND substr(sv.code, -2) != '00'
                               AND sv.name_obj IS NOT NULL
                               AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                   lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                            FROM ins.tmpl_save_code sva
                                                           WHERE sva.adr_id = cr.adr_id
                                                             AND sva.plevel = 3))
                                                 ,2
                                                 ,'0'))
                     WHERE ca.id = cr.adr_id
                       AND EXISTS (SELECT NULL
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = ca.id
                               AND sv.plevel = 3
                               AND substr(sv.code, -2) != '00'
                               AND sv.name_obj IS NOT NULL);
                    /**/
                    UPDATE ins.cn_address ca
                       SET ca.code =
                           (SELECT sv.code
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = cr.adr_id
                               AND sv.plevel = 3
                               AND substr(sv.code, -2) != '00'
                               AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                   lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                            FROM ins.tmpl_save_code sva
                                                           WHERE sva.adr_id = cr.adr_id
                                                             AND sva.plevel = 3))
                                                 ,2
                                                 ,'0'))
                     WHERE ca.id = cr.adr_id
                       AND ca.code IS NULL
                       AND EXISTS (SELECT NULL
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = ca.id
                               AND sv.plevel = 3
                               AND substr(sv.code, -2) != '00');
                  END IF;
                END IF;
              END IF;
              /*шаг 63*/
              IF v_continue
              THEN
                SELECT COUNT(*)
                  INTO pv_code_2level
                  FROM ins.tmpl_save_code sv
                 WHERE sv.adr_id = cr.adr_id
                   AND sv.plevel = 2
                   AND substr(sv.code, -2) = '00';
                /*если 2 уровня с актульностью 00 больше одного кода, чистим адрес*/
                IF pv_code_2level > 1
                THEN
                  UPDATE ins.cn_address ca
                     SET ca.street_name         = NULL
                        ,ca.street_type         = NULL
                        ,ca.code                = NULL
                        ,ca.city_name           = NULL
                        ,ca.city_type           = NULL
                        ,ca.district_name       = NULL
                        ,ca.district_type       = NULL
                        ,ca.province_name       = NULL
                        ,ca.province_type       = NULL
                        ,ca.region_name         = NULL
                        ,ca.region_type         = NULL
                        ,ca.house_nr            = NULL
                        ,ca.house_type          = NULL
                        ,ca.appartment_nr       = NULL
                        ,ca.code_kladr_province = NULL
                        ,ca.code_kladr_region   = NULL
                        ,ca.code_kladr_city     = NULL
                        ,ca.code_kladr_distr    = NULL
                        ,ca.code_kladr_street   = NULL
                        ,ca.code_kladr_doma     = NULL
                        ,ca.index_province      = NULL
                        ,ca.index_region        = NULL
                        ,ca.index_city          = NULL
                        ,ca.index_distr         = NULL
                        ,ca.index_street        = NULL
                        ,ca.index_doma          = NULL
                   WHERE ca.id = cr.adr_id;
                  v_continue := FALSE;
                  /*если 2 уровня с актульностью 00*/
                ELSIF pv_code_2level = 1
                THEN
                  UPDATE ins.cn_address ca
                     SET (ca.region_name, ca.region_type) =
                         (SELECT sv.name_obj
                                ,sv.socr_obj
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = cr.adr_id
                             AND sv.plevel = 2
                             AND substr(sv.code, -2) = '00')
                   WHERE ca.id = cr.adr_id
                     AND EXISTS (SELECT NULL
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = ca.id
                             AND sv.plevel = 2
                             AND substr(sv.code, -2) = '00');
                  /**/
                  UPDATE ins.cn_address ca
                     SET (ca.code_kladr_region, ca.index_region) =
                         (SELECT sv.code
                                ,sv.pindex
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = cr.adr_id
                             AND sv.plevel = 2
                             AND substr(sv.code, -2) = '00'
                             AND sv.name_obj IS NOT NULL)
                   WHERE ca.id = cr.adr_id
                     AND EXISTS (SELECT NULL
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = ca.id
                             AND sv.plevel = 2
                             AND substr(sv.code, -2) = '00'
                             AND sv.name_obj IS NOT NULL);
                  /**/
                  UPDATE ins.cn_address ca
                     SET ca.code =
                         (SELECT sv.code
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = cr.adr_id
                             AND sv.plevel = 2
                             AND substr(sv.code, -2) = '00')
                   WHERE ca.id = cr.adr_id
                     AND ca.code IS NULL
                     AND EXISTS (SELECT NULL
                            FROM ins.tmpl_save_code sv
                           WHERE sv.adr_id = ca.id
                             AND sv.plevel = 2
                             AND substr(sv.code, -2) = '00');
                  /*если 2 уровня с актульностью 00 нет*/
                ELSE
                  SELECT COUNT(*)
                    INTO pv_code_2level
                    FROM ins.tmpl_save_code sv
                   WHERE sv.adr_id = cr.adr_id
                     AND sv.plevel = 2
                     AND substr(sv.code, -2) != '00';
                  /*если 2 уровня с актульностью != 00*/
                  IF pv_code_2level != 0
                  THEN
                    SELECT COUNT(*)
                      INTO pv_error
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = cr.adr_id
                       AND sv.plevel = 2
                       AND substr(sv.code, -2) != '00'
                       AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                           lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                    FROM ins.tmpl_save_code sva
                                                   WHERE sva.adr_id = cr.adr_id
                                                     AND sva.plevel = 2))
                                         ,2
                                         ,'0');
                    IF pv_error = 1
                    THEN
                      UPDATE ins.cn_address ca
                         SET (ca.region_name, ca.region_type) =
                             (SELECT sv.name_obj
                                    ,sv.socr_obj
                                FROM ins.tmpl_save_code sv
                               WHERE sv.adr_id = cr.adr_id
                                 AND sv.plevel = 2
                                 AND substr(sv.code, -2) != '00'
                                 AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                     lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                              FROM ins.tmpl_save_code sva
                                                             WHERE sva.adr_id = cr.adr_id
                                                               AND sva.plevel = 2))
                                                   ,2
                                                   ,'0'))
                       WHERE ca.id = cr.adr_id
                         AND EXISTS (SELECT NULL
                                FROM ins.tmpl_save_code sv
                               WHERE sv.adr_id = ca.id
                                 AND sv.plevel = 2
                                 AND substr(sv.code, -2) != '00');
                      /**/
                      UPDATE ins.cn_address ca
                         SET (ca.code_kladr_region, ca.index_region) =
                             (SELECT sv.code
                                    ,sv.pindex
                                FROM ins.tmpl_save_code sv
                               WHERE sv.adr_id = cr.adr_id
                                 AND sv.plevel = 2
                                 AND substr(sv.code, -2) != '00'
                                 AND sv.name_obj IS NOT NULL
                                 AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                     lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                              FROM ins.tmpl_save_code sva
                                                             WHERE sva.adr_id = cr.adr_id
                                                               AND sva.plevel = 2))
                                                   ,2
                                                   ,'0'))
                       WHERE ca.id = cr.adr_id
                         AND EXISTS (SELECT NULL
                                FROM ins.tmpl_save_code sv
                               WHERE sv.adr_id = ca.id
                                 AND sv.plevel = 2
                                 AND substr(sv.code, -2) != '00'
                                 AND sv.name_obj IS NOT NULL);
                      /**/
                      UPDATE ins.cn_address ca
                         SET ca.code =
                             (SELECT sv.code
                                FROM ins.tmpl_save_code sv
                               WHERE sv.adr_id = cr.adr_id
                                 AND sv.plevel = 2
                                 AND substr(sv.code, -2) != '00'
                                 AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                     lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                              FROM ins.tmpl_save_code sva
                                                             WHERE sva.adr_id = cr.adr_id
                                                               AND sva.plevel = 2))
                                                   ,2
                                                   ,'0'))
                       WHERE ca.id = cr.adr_id
                         AND ca.code IS NULL
                         AND EXISTS (SELECT NULL
                                FROM ins.tmpl_save_code sv
                               WHERE sv.adr_id = ca.id
                                 AND sv.plevel = 2
                                 AND substr(sv.code, -2) != '00');
                    END IF;
                  END IF;
                END IF;
                /*шаг 71*/
                IF v_continue
                THEN
                  SELECT COUNT(*)
                    INTO pv_code_1level
                    FROM ins.tmpl_save_code sv
                   WHERE sv.adr_id = cr.adr_id
                     AND sv.plevel = 1
                     AND substr(sv.code, -2) = '00';
                  /*если 1 уровня с актульностью 00 больше одного кода, чистим адрес*/
                  IF pv_code_1level > 1
                  THEN
                    UPDATE ins.cn_address ca
                       SET ca.street_name         = NULL
                          ,ca.street_type         = NULL
                          ,ca.code                = NULL
                          ,ca.city_name           = NULL
                          ,ca.city_type           = NULL
                          ,ca.district_name       = NULL
                          ,ca.district_type       = NULL
                          ,ca.province_name       = NULL
                          ,ca.province_type       = NULL
                          ,ca.region_name         = NULL
                          ,ca.region_type         = NULL
                          ,ca.house_nr            = NULL
                          ,ca.house_type          = NULL
                          ,ca.appartment_nr       = NULL
                          ,ca.code_kladr_province = NULL
                          ,ca.code_kladr_region   = NULL
                          ,ca.code_kladr_city     = NULL
                          ,ca.code_kladr_distr    = NULL
                          ,ca.code_kladr_street   = NULL
                          ,ca.code_kladr_doma     = NULL
                          ,ca.index_province      = NULL
                          ,ca.index_region        = NULL
                          ,ca.index_city          = NULL
                          ,ca.index_distr         = NULL
                          ,ca.index_street        = NULL
                          ,ca.index_doma          = NULL
                     WHERE ca.id = cr.adr_id;
                    v_continue := FALSE;
                    /*если 1 уровня с актульностью 00*/
                  ELSIF pv_code_1level = 1
                  THEN
                    UPDATE ins.cn_address ca
                       SET (ca.province_name, ca.province_type) =
                           (SELECT sv.name_obj
                                  ,sv.socr_obj
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = cr.adr_id
                               AND sv.plevel = 1
                               AND substr(sv.code, -2) = '00')
                     WHERE ca.id = cr.adr_id
                       AND EXISTS (SELECT NULL
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = ca.id
                               AND sv.plevel = 1
                               AND substr(sv.code, -2) = '00');
                    /**/
                    UPDATE ins.cn_address ca
                       SET (ca.code_kladr_province, ca.index_province, ca.region_code) =
                           (SELECT sv.code
                                  ,sv.pindex
                                  ,substr(sv.code, 1, 2)
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = cr.adr_id
                               AND sv.plevel = 1
                               AND substr(sv.code, -2) = '00'
                               AND sv.name_obj IS NOT NULL)
                     WHERE ca.id = cr.adr_id
                       AND EXISTS (SELECT NULL
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = ca.id
                               AND sv.plevel = 1
                               AND substr(sv.code, -2) = '00'
                               AND sv.name_obj IS NOT NULL);
                    /**/
                    UPDATE ins.cn_address ca
                       SET ca.code =
                           (SELECT sv.code
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = cr.adr_id
                               AND sv.plevel = 1
                               AND substr(sv.code, -2) = '00')
                     WHERE ca.id = cr.adr_id
                       AND ca.code IS NULL
                       AND EXISTS (SELECT NULL
                              FROM ins.tmpl_save_code sv
                             WHERE sv.adr_id = ca.id
                               AND sv.plevel = 1
                               AND substr(sv.code, -2) = '00');
                    /*если 1 уровня с актульностью 00 нет*/
                  ELSE
                    SELECT COUNT(*)
                      INTO pv_code_1level
                      FROM ins.tmpl_save_code sv
                     WHERE sv.adr_id = cr.adr_id
                       AND sv.plevel = 1
                       AND substr(sv.code, -2) != '00';
                    /*если 1 уровня с актульностью != 00*/
                    IF pv_code_1level != 0
                    THEN
                      SELECT COUNT(*)
                        INTO pv_error
                        FROM ins.tmpl_save_code sv
                       WHERE sv.adr_id = cr.adr_id
                         AND sv.plevel = 1
                         AND substr(sv.code, -2) != '00'
                         AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                             lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                      FROM ins.tmpl_save_code sva
                                                     WHERE sva.adr_id = cr.adr_id
                                                       AND sva.plevel = 1))
                                           ,2
                                           ,'0');
                      IF pv_error = 1
                      THEN
                        UPDATE ins.cn_address ca
                           SET (ca.province_name, ca.province_type) =
                               (SELECT sv.name_obj
                                      ,sv.socr_obj
                                  FROM ins.tmpl_save_code sv
                                 WHERE sv.adr_id = cr.adr_id
                                   AND sv.plevel = 1
                                   AND substr(sv.code, -2) != '00'
                                   AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                       lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                                FROM ins.tmpl_save_code sva
                                                               WHERE sva.adr_id = cr.adr_id
                                                                 AND sva.plevel = 1))
                                                     ,2
                                                     ,'0'))
                         WHERE ca.id = cr.adr_id
                           AND EXISTS (SELECT NULL
                                  FROM ins.tmpl_save_code sv
                                 WHERE sv.adr_id = ca.id
                                   AND sv.plevel = 1
                                   AND substr(sv.code, -2) != '00');
                        /**/
                        UPDATE ins.cn_address ca
                           SET (ca.code_kladr_province, ca.index_province) =
                               (SELECT sv.code
                                      ,sv.pindex
                                  FROM ins.tmpl_save_code sv
                                 WHERE sv.adr_id = cr.adr_id
                                   AND sv.plevel = 1
                                   AND substr(sv.code, -2) != '00'
                                   AND sv.name_obj IS NOT NULL
                                   AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                       lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                                FROM ins.tmpl_save_code sva
                                                               WHERE sva.adr_id = cr.adr_id
                                                                 AND sva.plevel = 1))
                                                     ,2
                                                     ,'0'))
                         WHERE ca.id = cr.adr_id
                           AND EXISTS (SELECT NULL
                                  FROM ins.tmpl_save_code sv
                                 WHERE sv.adr_id = ca.id
                                   AND sv.plevel = 1
                                   AND substr(sv.code, -2) != '00'
                                   AND sv.name_obj IS NOT NULL);
                        /**/
                        UPDATE ins.cn_address ca
                           SET ca.code =
                               (SELECT sv.code
                                  FROM ins.tmpl_save_code sv
                                 WHERE sv.adr_id = cr.adr_id
                                   AND sv.plevel = 1
                                   AND substr(sv.code, -2) != '00'
                                   AND sv.code = substr(sv.code, 1, length(sv.code) - 2) ||
                                       lpad(to_char((SELECT MAX(to_number(substr(sva.code, -2)))
                                                                FROM ins.tmpl_save_code sva
                                                               WHERE sva.adr_id = cr.adr_id
                                                                 AND sva.plevel = 1))
                                                     ,2
                                                     ,'0'))
                         WHERE ca.id = cr.adr_id
                           AND ca.code IS NULL
                           AND EXISTS (SELECT NULL
                                  FROM ins.tmpl_save_code sv
                                 WHERE sv.adr_id = ca.id
                                   AND sv.plevel = 1
                                   AND substr(sv.code, -2) != '00');
                      END IF;
                    END IF;
                  END IF;
                END IF;
                /**/
              END IF;
              /**/
            END IF;
            /**/
          END IF;
          /**/
          UPDATE ins.cn_address ca
             SET ca.name = ins.pkg_contact.get_address_name(ca.zip
                                                           ,(SELECT ctr.description
                                                              FROM ins.t_country ctr
                                                             WHERE ctr.id = ca.country_id)
                                                           ,ca.region_name
                                                           ,ca.region_type
                                                           ,ca.province_name
                                                           ,ca.province_type
                                                           ,ca.district_type
                                                           ,ca.district_name
                                                           ,ca.city_type
                                                           ,ca.city_name
                                                           ,ca.street_name
                                                           ,ca.street_type
                                                           ,ca.building_name
                                                           ,ca.house_nr
                                                           ,ca.block_number
                                                           ,ca.box_number
                                                           ,substr(ca.appartment_nr, 1, 9)
                                                           ,ca.house_type)
           WHERE ca.id = cr.adr_id
             AND ca.code IS NOT NULL;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO last_rec;
          log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Распознавание.'
             ,cr.adr_id);
      END;
      /*Присвоение признака актуальности мимо основной процедуры актуализации*/
      ins.pkg_kladr.is_actual(cr.adr_id);
    END LOOP;
    tv_addresses.delete;
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      tv_addresses.delete;
      ROLLBACK TO auto_recognition_adr_beg;
      log('Ошибка при выполнении AUTO_RECOGNITION_ADR; Неизвестная ошибка.');
      /*RAISE_APPLICATION_ERROR(-20001,'Ошибка при выполнении AUTO_RECOGNITION_ADR pv_adr_id = ' || pv_adr_id || '; ' ||SQLERRM);*/
  END;
  /*******************************************************/

  FUNCTION parse_houses_number(par_house_num VARCHAR2) RETURN VARCHAR2 IS
    v_result tt_one_col;
    v_buf    VARCHAR2(4000) := '';
    x1       NUMBER;
    x2       NUMBER;
  BEGIN
    --DELETE FROM TMPL_ADR_NAME_PARSE;
  
    SELECT pkg_utils.get_splitted_string(TRIM(par_house_num), ',') tbl INTO v_result FROM dual;
    /*FOR i IN v_result.first .. v_result.last
    LOOP
      INSERT INTO TMPL_ADR_NAME_PARSE (ADR_TEXT) VALUES (v_result(i));
    END LOOP;*/
  
    FOR cur IN (SELECT REPLACE(column_value, '9999', '999') adr_text FROM TABLE(v_result))
    LOOP
      IF (instr(cur.adr_text, '-') = 0 OR
         (instr(cur.adr_text, '-') != 0 AND regexp_instr(cur.adr_text, '[НЧ]') = 0 AND
         regexp_instr(cur.adr_text, '[A-Z]|[a-z]|[А-Я]|[а-я]|[\_*/]') != 0))
      THEN
        v_buf := v_buf || (CASE
                   WHEN v_buf IS NOT NULL THEN
                    ','
                   ELSE
                    ''
                 END) || cur.adr_text;
      ELSE
        IF instr(cur.adr_text, 'Н') != 0
        THEN
          x1 := to_number(regexp_substr(cur.adr_text, '\d+'));
          x2 := to_number(regexp_substr(cur.adr_text, '\d+', 1, 2));
          FOR i IN x1 .. x2
          LOOP
            IF MOD(i, 2) != 0
            THEN
              v_buf := v_buf || (CASE
                         WHEN v_buf IS NOT NULL THEN
                          ','
                         ELSE
                          ''
                       END) || i;
            END IF;
          END LOOP;
        END IF;
        IF instr(cur.adr_text, 'Ч') != 0
        THEN
          x1 := to_number(regexp_substr(cur.adr_text, '\d+'));
          x2 := to_number(regexp_substr(cur.adr_text, '\d+', 1, 2));
          FOR i IN x1 .. x2
          LOOP
            IF MOD(i, 2) = 0
            THEN
              v_buf := v_buf || (CASE
                         WHEN v_buf IS NOT NULL THEN
                          ','
                         ELSE
                          ''
                       END) || i;
            END IF;
          END LOOP;
        END IF;
        IF (instr(cur.adr_text, 'Ч') = 0 AND instr(cur.adr_text, 'Н') = 0)
        THEN
          x1 := to_number(regexp_substr(cur.adr_text, '\d+'));
          x2 := to_number(regexp_substr(cur.adr_text, '\d+$'));
          FOR i IN regexp_substr(cur.adr_text, '\d+') .. regexp_substr(cur.adr_text, '\d+$')
          LOOP
            v_buf := v_buf || (CASE
                       WHEN v_buf IS NOT NULL THEN
                        ','
                       ELSE
                        ''
                     END) || i;
          END LOOP;
        END IF;
      END IF;
    END LOOP;
  
    RETURN v_buf;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении PARSE_HOUSES_NUMBER ' || SQLERRM);
    
  END parse_houses_number;
  /****************************************************/
  /*       22.04.2013
           Веселуха Е.В.
           Присвоение признака актуальности
           на основе кодов КЛАДР
           Параметр: ИД адреса, по умолчанию = NULL
           для обновления группы адресов по определенному условию
  */
  PROCEDURE is_actual(par_addr_id NUMBER DEFAULT NULL) IS
  BEGIN
    IF par_addr_id IS NOT NULL
    THEN
      UPDATE ins.cn_address ca
         SET ca.actual      = 1
            ,ca.actual_date = trunc(SYSDATE)
       WHERE ca.decompos_permis = 1
         AND ca.decompos_date IS NOT NULL
         AND ca.id = par_addr_id
         AND ca.actual = 0
            /*Код КЛАДР 1-ого уровня*/
         AND ((ca.code_kladr_province IS NOT NULL AND substr(ca.code_kladr_province, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_province
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_province IS NULL)
            /*Код КЛАДР 2-ого уровня*/
         AND ((ca.code_kladr_region IS NOT NULL AND substr(ca.code_kladr_region, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_province
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_region IS NULL)
            /*Код КЛАДР 3-ого уровня*/
         AND ((ca.code_kladr_city IS NOT NULL AND substr(ca.code_kladr_city, -2) = '00' AND NOT EXISTS
              (SELECT NULL
                  FROM ins.update_journal_kladr jk
                 WHERE jk.code = ca.code_kladr_province
                   AND jk.change_date >= ca.decompos_date
                   AND TRIM(substr(REPLACE(jk.old_value
                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                  ,1
                                  ,instr(REPLACE(jk.old_value
                                                ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                        ,','
                                        ,1
                                        ,4) - 1)) !=
                       TRIM(substr(REPLACE(jk.new_value
                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                  ,1
                                  ,instr(REPLACE(jk.new_value
                                                ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                        ,','
                                        ,1
                                        ,4) - 1))
                   AND instr(TRIM(jk.new_value)
                            ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_city IS NULL)
            /*Код КЛАДР 4-ого уровня*/
         AND ((ca.code_kladr_distr IS NOT NULL AND substr(ca.code_kladr_distr, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_province
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_distr IS NULL)
            /*Код КЛАДР 5-ого уровня*/
         AND ((ca.code_kladr_street IS NOT NULL AND substr(ca.code_kladr_street, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_street
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_STREET: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_STREET: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_STREET: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_STREET: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_STREET: ') != 0)) OR
             ca.code_kladr_street IS NULL)
            /*Если указан индекс*/
         AND ((ca.zip IS NOT NULL AND NOT EXISTS
              (SELECT NULL
                  FROM ins.t_npindx idx
                 WHERE idx.pindex = ca.zip
                   AND nvl(idx.nactdate, idx.add_date) >= ca.decompos_date)) OR ca.zip IS NULL)
            /*Существует хотя бы один Код КЛАДР*/
         AND (ca.code_kladr_province IS NOT NULL OR ca.code_kladr_region IS NOT NULL OR
             ca.code_kladr_city IS NOT NULL OR ca.code_kladr_distr IS NOT NULL OR
             ca.code_kladr_street IS NOT NULL);
    ELSE
      UPDATE ins.cn_address ca
         SET ca.actual      = 1
            ,ca.actual_date = trunc(SYSDATE)
       WHERE ca.decompos_permis = 1
         AND ca.decompos_date IS NOT NULL
         AND ca.actual = 0
            /*Код КЛАДР 1-ого уровня*/
         AND ((ca.code_kladr_province IS NOT NULL AND substr(ca.code_kladr_province, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_province
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_province IS NULL)
            /*Код КЛАДР 2-ого уровня*/
         AND ((ca.code_kladr_region IS NOT NULL AND substr(ca.code_kladr_region, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_province
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_region IS NULL)
            /*Код КЛАДР 3-ого уровня*/
         AND ((ca.code_kladr_city IS NOT NULL AND substr(ca.code_kladr_city, -2) = '00' AND NOT EXISTS
              (SELECT NULL
                  FROM ins.update_journal_kladr jk
                 WHERE jk.code = ca.code_kladr_province
                   AND jk.change_date >= ca.decompos_date
                   AND TRIM(substr(REPLACE(jk.old_value
                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                  ,1
                                  ,instr(REPLACE(jk.old_value
                                                ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                        ,','
                                        ,1
                                        ,4) - 1)) !=
                       TRIM(substr(REPLACE(jk.new_value
                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                  ,1
                                  ,instr(REPLACE(jk.new_value
                                                ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                        ,','
                                        ,1
                                        ,4) - 1))
                   AND instr(TRIM(jk.new_value)
                            ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_city IS NULL)
            /*Код КЛАДР 4-ого уровня*/
         AND ((ca.code_kladr_distr IS NOT NULL AND substr(ca.code_kladr_distr, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_province
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_KLADR: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_KLADR: ') != 0)) OR
             ca.code_kladr_distr IS NULL)
            /*Код КЛАДР 5-ого уровня*/
         AND ((ca.code_kladr_street IS NOT NULL AND substr(ca.code_kladr_street, -2) = '00' AND
             NOT EXISTS (SELECT NULL
                            FROM ins.update_journal_kladr jk
                           WHERE jk.code = ca.code_kladr_street
                             AND jk.change_date >= ca.decompos_date
                             AND TRIM(substr(REPLACE(jk.old_value
                                                    ,'Совпадение кодов КЛАДР в T_STREET: ')
                                            ,1
                                            ,instr(REPLACE(jk.old_value
                                                          ,'Совпадение кодов КЛАДР в T_STREET: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1)) !=
                                 TRIM(substr(REPLACE(jk.new_value
                                                    ,'Совпадение кодов КЛАДР в T_STREET: ')
                                            ,1
                                            ,instr(REPLACE(jk.new_value
                                                          ,'Совпадение кодов КЛАДР в T_STREET: ')
                                                  ,','
                                                  ,1
                                                  ,4) - 1))
                             AND instr(TRIM(jk.new_value)
                                      ,'Совпадение кодов КЛАДР в T_STREET: ') != 0)) OR
             ca.code_kladr_street IS NULL)
            /*Если указан индекс*/
         AND ((ca.zip IS NOT NULL AND NOT EXISTS
              (SELECT NULL
                  FROM ins.t_npindx idx
                 WHERE idx.pindex = ca.zip
                   AND nvl(idx.nactdate, idx.add_date) >= ca.decompos_date)) OR ca.zip IS NULL)
            /*Существует хотя бы один Код КЛАДР*/
         AND (ca.code_kladr_province IS NOT NULL OR ca.code_kladr_region IS NOT NULL OR
             ca.code_kladr_city IS NOT NULL OR ca.code_kladr_distr IS NOT NULL OR
             ca.code_kladr_street IS NOT NULL);
    END IF;
  END is_actual;
  /****************************************************/
  /*       22.04.2013
           Веселуха Е.В.
           Обновление адреса
           для повторного распознавания и актуализации
           Параметр: ИД адреса, по умолчанию = NULL
                     Дата распознавания
                     Признак - 0 - при наличии в старом значении адреса "корп"
                               1 - любого
  */
  PROCEDURE is_reold
  (
    par_addr_id       NUMBER DEFAULT NULL
   ,par_date_decompos DATE DEFAULT trunc(SYSDATE)
   ,par_update_all    NUMBER DEFAULT 0
  ) IS
  BEGIN
    /*Удаление связи контакт-адрес*/
    DELETE FROM ins.cn_contact_address a
     WHERE a.adress_id IN
           (SELECT cn.id
              FROM ins.cn_address cn
             WHERE cn.parent_addr_id IS NOT NULL
               AND EXISTS
             (SELECT NULL
                      FROM ins.cn_address cac
                     WHERE ((cac.decompos_date >= par_date_decompos AND cac.house_type IS NULL) OR
                           ((cac.name_old IS NOT NULL AND
                           regexp_like(upper(cac.name_old), '(,\s?КОРП.{0,2}(\d|\w)+)') AND
                           cac.name != cac.name_old AND par_update_all = 0) OR par_update_all = 1))
                       AND (cac.id = par_addr_id OR par_addr_id IS NULL)
                       AND cac.parent_addr_id IS NULL
                       AND cac.id = cn.parent_addr_id));
    /*Удаление, связанных фактических*/
    DELETE FROM ins.cn_address cn
     WHERE cn.parent_addr_id IS NOT NULL
       AND EXISTS
     (SELECT NULL
              FROM ins.cn_address cac
             WHERE ((cac.decompos_date >= par_date_decompos AND cac.house_type IS NULL) OR
                   ((cac.name_old IS NOT NULL AND
                   regexp_like(upper(cac.name_old), '(,\s?КОРП.{0,2}(\d|\w)+)') AND
                   cac.name != cac.name_old AND par_update_all = 0) OR par_update_all = 1))
               AND (cac.id = par_addr_id OR par_addr_id IS NULL)
               AND cac.parent_addr_id IS NULL
               AND cac.id = cn.parent_addr_id);
    /*Обновление родительского*/
    UPDATE ins.cn_address ca
       SET ca.name                = ca.name_old
          ,ca.actual_date         = NULL
          ,ca.decompos_date       = NULL
          ,ca.actual              = 0
          ,ca.decompos_permis     = 0
          ,ca.zip                 = NULL
          ,ca.province_name       = NULL
          ,ca.province_type       = NULL
          ,ca.region_name         = NULL
          ,ca.region_code         = NULL
          ,ca.region_type         = NULL
          ,ca.district_name       = NULL
          ,ca.district_type       = NULL
          ,ca.street_name         = NULL
          ,ca.street_type         = NULL
          ,ca.city_name           = NULL
          ,ca.city_type           = NULL
          ,ca.house_nr            = NULL
          ,ca.house_type          = NULL
          ,ca.code                = NULL
          ,ca.appartment_nr       = NULL
          ,ca.code_kladr_province = NULL
          ,ca.index_province      = NULL
          ,ca.code_kladr_region   = NULL
          ,ca.index_region        = NULL
          ,ca.code_kladr_city     = NULL
          ,ca.index_city          = NULL
          ,ca.code_kladr_distr    = NULL
          ,ca.index_distr         = NULL
          ,ca.code_kladr_street   = NULL
          ,ca.index_street        = NULL
          ,ca.code_kladr_doma     = NULL
          ,ca.index_doma          = NULL
          ,ca.fact_addr_id        = NULL
     WHERE ((ca.decompos_date >= par_date_decompos AND ca.house_type IS NULL) OR
           ((ca.name_old IS NOT NULL AND
           regexp_like(upper(ca.name_old), '(,\s?КОРП.{0,2}(\d|\w)+)') AND ca.name != ca.name_old AND
           par_update_all = 0) OR par_update_all = 1))
       AND (ca.id = par_addr_id OR par_addr_id IS NULL)
       AND ca.parent_addr_id IS NULL;
  
  END is_reold;
  /****************************************************/
  /* 20.08.2013
     Веселуха Е.В.
     Функция посика актуального кода КЛАДР в ALTNAMES
     Параметры: код КЛАДР, уровень КЛАДР
  */
  FUNCTION get_altnames_code
  (
    par_code_kladr VARCHAR2
   ,par_level      NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
    RESULT VARCHAR2(19);
  BEGIN
  
    BEGIN
      SELECT newcode
        INTO RESULT
        FROM (SELECT newcode
                    ,lvl
                FROM (SELECT ta.newcode
                            ,LEVEL lvl
                        FROM ins.t_altnames ta
                       WHERE (ta.plevel = par_level OR par_level IS NULL)
                       START WITH ta.oldcode = par_code_kladr
                      CONNECT BY ta.oldcode = PRIOR ta.newcode)
               ORDER BY lvl DESC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_ALTNAMES_CODE ' || SQLERRM);
  END get_altnames_code;
  /****************************************************/
END pkg_kladr; 
/
