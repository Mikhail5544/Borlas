CREATE OR REPLACE PACKAGE PKG_LOAD_SWINDLERS_CLOSED_FMB IS

  -- Author  : VESELEK
  -- Created : 22.03.2012 10:55:10
  -- Purpose : Загрузка списка мошенников

  FUNCTION Str2Array(p_str VARCHAR2) RETURN PKG_LOAD_FILE_TO_TABLE.t_varay;
  PROCEDURE LOAD_BLOB_TO_TABLE
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  PROCEDURE LOAD_TO_DB(p_load_file_id NUMBER);

END PKG_LOAD_SWINDLERS_CLOSED_FMB;
/
CREATE OR REPLACE PACKAGE BODY PKG_LOAD_SWINDLERS_CLOSED_FMB IS

  -- Функция разбра строки данных
  FUNCTION Str2Array(p_str VARCHAR2) RETURN PKG_LOAD_FILE_TO_TABLE.t_varay IS
    v_offset NUMBER := 1;
    v_length NUMBER := 0;
    va_res   PKG_LOAD_FILE_TO_TABLE.t_varay;
  BEGIN
    FOR i IN 1 .. 100
    LOOP
      v_length := INSTR(p_str, CHR(9), v_offset);
      IF v_length = 0
      THEN
        va_res(i) := TRIM(SUBSTR(p_str, v_offset));
        EXIT;
      ELSE
        va_res(i) := TRIM(SUBSTR(p_str, v_offset, v_length - v_offset));
      END IF;
      v_offset := v_length + 1;
    END LOOP;
    RETURN va_res;
  END Str2Array;

  PROCEDURE LOAD_BLOB_TO_TABLE
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values        PKG_LOAD_FILE_TO_TABLE.t_varay;
    v_blob_data      BLOB;
    v_blob_len       NUMBER;
    v_position       NUMBER;
    c_chunk_len      NUMBER := 1;
    v_line           VARCHAR2(32767) := NULL;
    v_line_num       NUMBER := 0;
    v_char           CHAR(1);
    v_raw_chunk      RAW(10000);
    v_load_swindlers LOAD_SWINDLERS_TMP%ROWTYPE;
    v_row_i          NUMBER;
  BEGIN
    SELECT file_blob INTO v_blob_data FROM TEMP_LOAD_BLOB WHERE session_id = par_id;
    v_blob_len := DBMS_LOB.GetLength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := DBMS_LOB.SubStr(v_blob_data, c_chunk_len, v_position);
      v_char      := CHR(PKG_LOAD_FILE_TO_TABLE.Hex2Dec(RawToHex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = CHR(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, CHR(10)), CHR(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := PKG_LOAD_SWINDLERS_CLOSED_FMB.Str2Array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_load_swindlers         := NULL;
            v_load_swindlers.load_id := par_load_file_id;
            SELECT sq_load_swindlers_tmp.NEXTVAL
              INTO v_load_swindlers.load_swindlers_tmp_id
              FROM dual;
            -- проход по полям
            FOR i IN va_values.FIRST .. va_values.LAST
            LOOP
              v_row_i := i;
              CASE
                WHEN i = 1 THEN
                  v_load_swindlers.field_number := va_values(i);
                WHEN i = 2 THEN
                  v_load_swindlers.terror := va_values(i);
                WHEN i = 3 THEN
                  v_load_swindlers.tu := va_values(i);
                WHEN i = 4 THEN
                  v_load_swindlers.nameu := va_values(i);
                WHEN i = 5 THEN
                  v_load_swindlers.descript := va_values(i);
                WHEN i = 6 THEN
                  v_load_swindlers.kodcr := va_values(i);
                WHEN i = 7 THEN
                  v_load_swindlers.kodcn := va_values(i);
                WHEN i = 8 THEN
                  v_load_swindlers.amr := va_values(i);
                WHEN i = 9 THEN
                  v_load_swindlers.adress := va_values(i);
                WHEN i = 10 THEN
                  v_load_swindlers.kd := va_values(i);
                WHEN i = 11 THEN
                  v_load_swindlers.sd := va_values(i);
                WHEN i = 12 THEN
                  v_load_swindlers.rg := va_values(i);
                WHEN i = 13 THEN
                  v_load_swindlers.nd := va_values(i);
                WHEN i = 14 THEN
                  v_load_swindlers.vd := va_values(i);
                WHEN i = 15 THEN
                  v_load_swindlers.gr := va_values(i);
                WHEN i = 16 THEN
                  v_load_swindlers.yr := va_values(i);
                WHEN i = 17 THEN
                  v_load_swindlers.mr := va_values(i);
                WHEN i = 18 THEN
                  v_load_swindlers.cb_date := va_values(i);
                WHEN i = 19 THEN
                  v_load_swindlers.ce_date := va_values(i);
                WHEN i = 20 THEN
                  v_load_swindlers.director := va_values(i);
                WHEN i = 21 THEN
                  v_load_swindlers.founder := va_values(i);
                WHEN i = 22 THEN
                  v_load_swindlers.row_id := va_values(i);
                WHEN i = 23 THEN
                  v_load_swindlers.terrtype := va_values(i);
                ELSE
                  NULL;
              END CASE;
            END LOOP;
            INSERT INTO INS.LOAD_SWINDLERS_TMP
              (field_number
              ,terror
              ,tu
              ,nameu
              ,descript
              ,kodcr
              ,kodcn
              ,amr
              ,adress
              ,kd
              ,sd
              ,rg
              ,nd
              ,vd
              ,gr
              ,yr
              ,mr
              ,cb_date
              ,ce_date
              ,director
              ,founder
              ,row_id
              ,terrtype
              ,load_id
              ,load_swindlers_tmp_id)
            VALUES
              (v_load_swindlers.field_number
              ,v_load_swindlers.terror
              ,v_load_swindlers.tu
              ,v_load_swindlers.nameu
              ,v_load_swindlers.descript
              ,v_load_swindlers.kodcr
              ,v_load_swindlers.kodcn
              ,v_load_swindlers.amr
              ,v_load_swindlers.adress
              ,v_load_swindlers.kd
              ,v_load_swindlers.sd
              ,v_load_swindlers.rg
              ,v_load_swindlers.nd
              ,v_load_swindlers.vd
              ,v_load_swindlers.gr
              ,v_load_swindlers.yr
              ,v_load_swindlers.mr
              ,v_load_swindlers.cb_date
              ,v_load_swindlers.ce_date
              ,v_load_swindlers.director
              ,v_load_swindlers.founder
              ,v_load_swindlers.row_id
              ,v_load_swindlers.terrtype
              ,v_load_swindlers.load_id
              ,v_load_swindlers.load_swindlers_tmp_id);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении LOAD_BLOB_TO_TABLE ' || 'row_id=' || v_row_i || '; ' ||
                              SQLERRM);
  END LOAD_BLOB_TO_TABLE;

  PROCEDURE LOAD_TO_DB(p_load_file_id NUMBER) IS
    res        NUMBER;
    par_row_id NUMBER;
  BEGIN
  
    FOR CUR IN (SELECT field_number
                      ,terror
                      ,TO_NUMBER(tu) tu
                      ,nameu
                      ,descript
                      ,kodcr
                      ,kodcn
                      ,amr
                      ,adress
                      ,kd
                      ,sd
                      ,rg
                      ,nd
                      ,vd
                      ,
                       -- TO_DATE(gr,'DD.MM.YYYY') gr, 
                       TO_DATE(regexp_substr(gr, '\d{2}\.\d{2}\.\d{4}'), 'dd.mm.yyyy') gr
                      ,yr
                      ,mr
                      ,TO_DATE(regexp_substr(cb_date, '\d{2}\.\d{2}\.\d{4}'), 'dd.mm.yyyy') cb_date
                      ,TO_DATE(regexp_substr(ce_date, '\d{2}\.\d{2}\.\d{4}'), 'dd.mm.yyyy') ce_date
                      ,director
                      ,founder
                      ,row_id
                      ,terrtype
                  FROM LOAD_SWINDLERS_TMP
                 WHERE load_id = p_load_file_id)
    LOOP
      par_row_id := CUR.Row_Id;
      BEGIN
        INSERT INTO etl.fms_terror_tmp tp
          (field_number
          ,terror
          ,tu
          ,nameu
          ,descript
          ,kodcr
          ,kodcn
          ,amr
          ,adress
          ,kd
          ,sd
          ,rg
          ,nd
          ,vd
          ,gr
          ,yr
          ,mr
          ,cb_date
          ,ce_date
          ,director
          ,founder
          ,row_id
          ,terrtype)
        VALUES
          (CUR.field_number
          ,CUR.terror
          ,CUR.tu
          ,CUR.nameu
          ,CUR.descript
          ,CUR.kodcr
          ,CUR.kodcn
          ,CUR.amr
          ,CUR.adress
          ,CUR.kd
          ,CUR.sd
          ,CUR.rg
          ,CUR.nd
          ,CUR.vd
          ,CUR.gr
          ,CUR.yr
          ,CUR.mr
          ,CUR.cb_date
          ,CUR.ce_date
          ,CUR.director
          ,CUR.founder
          ,CUR.row_id
          ,CUR.terrtype);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          UPDATE VEN_LOAD_SWINDLERS_TMP
             SET status       = 0
                ,note         = 'Данные не найдены - NO_DATA_FOUND'
                ,load_date_sw = SYSDATE
           WHERE ROW_ID = par_row_id;
          RAISE_APPLICATION_ERROR(-20001
                                 ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: Данные не найдены - ' ||
                                  SQLERRM);
        WHEN INVALID_NUMBER THEN
          UPDATE VEN_LOAD_SWINDLERS_TMP
             SET status       = 0
                ,note         = 'Возможно не верно значение, конвертация из текста в числовое значение - INVALID_NUMBER'
                ,load_date_sw = SYSDATE
           WHERE ROW_ID = par_row_id;
          RAISE_APPLICATION_ERROR(-20002
                                 ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: Возможно не верно значение, конвертация из текста в числовое значение - ' ||
                                  SQLERRM);
        WHEN VALUE_ERROR THEN
          UPDATE VEN_LOAD_SWINDLERS_TMP
             SET status       = 0
                ,note         = 'Возможно не верно значение, конвертация из текста в числовое значение - VALUE_ERROR'
                ,load_date_sw = SYSDATE
           WHERE ROW_ID = par_row_id;
          RAISE_APPLICATION_ERROR(-20003
                                 ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: Возможно не верно значение, конвертация из текста в числовое значение - ' ||
                                  SQLERRM);
        WHEN OTHERS THEN
          UPDATE VEN_LOAD_SWINDLERS_TMP
             SET status       = 0
                ,note         = 'Неизвестная ошибка - OTHERS'
                ,load_date_sw = SYSDATE
           WHERE ROW_ID = par_row_id;
          RAISE_APPLICATION_ERROR(-20004
                                 ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: ошибку надо найти - ' ||
                                  SQLERRM);
      END;
      UPDATE VEN_LOAD_SWINDLERS_TMP
         SET status       = 1
            ,note         = 'Успешно загружен, попал в таблицу для сравнения etl.fms_terror_tmp'
            ,load_date_sw = SYSDATE
       WHERE ROW_ID = par_row_id;
    END LOOP;
  
    res := PKG_CONTACT_FINMON.COMPARISON_TERROR;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: Данные не найдены - ' ||
                              SQLERRM);
    WHEN INVALID_NUMBER THEN
      RAISE_APPLICATION_ERROR(-20002
                             ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: Возможно не верно значение, конвертация из текста в числовое значение - ' ||
                              SQLERRM);
    WHEN VALUE_ERROR THEN
      RAISE_APPLICATION_ERROR(-20003
                             ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: Возможно не верно значение, конвертация из текста в числовое значение - ' ||
                              SQLERRM);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004
                             ,'процедура PKG_LOAD_SWINDLERS_CLOSED_FMB.LOAD_TO_DB: ошибку надо найти - ' ||
                              SQLERRM);
  END LOAD_TO_DB;

END PKG_LOAD_SWINDLERS_CLOSED_FMB;
/
