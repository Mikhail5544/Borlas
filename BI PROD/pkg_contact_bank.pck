CREATE OR REPLACE PACKAGE pkg_contact_bank IS
  ----========================================================================----
  -- Загрузка/редактирование реквизитов банков
  ----========================================================================----
  -- Информация о пакете
  FUNCTION Get_Pkg_Info RETURN VARCHAR2;
  ----========================================================================----
  -- Обновление реквизитов банка
  /*PROCEDURE Update_Contact_Bank(
    par_contact_id NUMBER,
    par_bank_name  VARCHAR2,
    par_bic        VARCHAR2,
    par_corracc    VARCHAR2,
    par_country_id NUMBER,
    par_city_id    NUMBER,
    par_inn        VARCHAR2
    );
  ----========================================================================----
  */
  -- Добавление информации о банке (заведение нового контакта)
  PROCEDURE Insert_Contact_Bank
  (
    par_contact_id NUMBER
   ,par_bank_name  VARCHAR2
   ,par_bic        VARCHAR2
   ,par_corracc    VARCHAR2
   ,par_country_id NUMBER
   ,par_city_id    NUMBER
   ,par_inn        VARCHAR2
   ,par_note       VARCHAR2
  );
  /*
  ----========================================================================----
  -- Удаление банка
  PROCEDURE Delete_Contact_Bank( par_contact_id NUMBER );
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк файлов банковских реквизитов
     -- (cn_bank_req_file_row)
     -- Входные параметры: идентификатор из sq_temp_load_blob,
        -- идентификатор файла (load_file_id)
  PROCEDURE Load_BLOB_To_Table(
    par_id           NUMBER,
    par_load_file_id NUMBER
    );
  ----========================================================================----
  -- Загрузка/редактирование реквизитов одного банка по данным строки файла
  PROCEDURE Load_One_Bank(
    par_cn_bank_req_file_row_id NUMBER,
    par_city_name               VARCHAR2,
    par_bank_name               VARCHAR2,
    par_bic                     VARCHAR2,
    par_corracc                 VARCHAR2
    );
  ----========================================================================----
  FUNCTION Update_cn_bank_req_file_row(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER;
  ----========================================================================----
  FUNCTION Update_Kladr_Altnames(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER;
  PROCEDURE Load_Altnames(p_load_file_id NUMBER);
  FUNCTION Update_Kladr_Street(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER;
  PROCEDURE Load_Street(p_load_file_id NUMBER);
  FUNCTION Update_Kladr_Kladr(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER;
  PROCEDURE Load_Kladr_City(p_load_file_id NUMBER);
  PROCEDURE Load_Kladr_District(p_load_file_id NUMBER);
  PROCEDURE Load_Kladr_Region(p_load_file_id NUMBER);
  PROCEDURE Load_Kladr_Province(p_load_file_id NUMBER);*/
----========================================================================----
END PKG_CONTACT_BANK;
/
CREATE OR REPLACE PACKAGE BODY pkg_contact_bank IS
  ----========================================================================----
  -- Загрузка/редактирование реквизитов банков
  ----========================================================================----
  -- Информация о пакете
  FUNCTION Get_Pkg_Info RETURN VARCHAR2 IS
  BEGIN
    RETURN('Загрузка/редактирование реквизитов банков. Версия 1.0');
  END Get_Pkg_Info;
  ----========================================================================----
  -- Добавление/изменение значения реквизита
  FUNCTION Add_Change_Value
  (
    par_contact_id NUMBER
   ,par_req_code   VARCHAR2
   , -- код реквизита
    par_req_value  VARCHAR2 -- значение реквизита
  ) RETURN NUMBER IS
    CURSOR req_curs
    (
      pcurs_contact_id NUMBER
     ,pcurs_req_code   VARCHAR2
    ) IS
      SELECT cci.table_id
            ,cci.id_value
        FROM ven_cn_contact_ident cci
       WHERE cci.contact_id = pcurs_contact_id
         AND cci.country_id = (SELECT id FROM t_country WHERE description = 'Россия')
         AND cci.id_type = (SELECT id FROM t_id_type WHERE brief = pcurs_req_code);
    v_updated BOOLEAN := FALSE;
    v_return  NUMBER := 0;
  BEGIN
    FOR req_rec IN req_curs(par_contact_id, par_req_code)
    LOOP
      IF par_req_value IS NULL
      THEN
        DELETE FROM ven_cn_contact_ident WHERE table_id = req_rec.table_id;
        v_return := 1;
      ELSE
        IF NVL(req_rec.id_value, '~') != NVL(par_req_value, '~')
        THEN
          UPDATE ven_cn_contact_ident SET id_value = par_req_value WHERE table_id = req_rec.table_id;
          v_return := 1;
        ELSE
          v_return := 0;
        END IF;
      END IF;
      v_updated := TRUE;
    END LOOP;
    IF NOT v_updated
       AND par_req_value IS NOT NULL
    THEN
      INSERT INTO ven_cn_contact_ident
        (contact_id, country_id, id_type, id_value, issue_date)
      VALUES
        (par_contact_id
        ,(SELECT id FROM t_country WHERE description = 'Россия')
        ,(SELECT id FROM t_id_type WHERE brief = par_req_code)
        ,par_req_value
        ,SYSDATE);
      v_return := 1;
    END IF;
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20001, 'Add_Change_Value: ' || SQLERRM);
  END Add_Change_Value;
  ----========================================================================----
  -- Добавление/изменение адреса по умолчанию
  FUNCTION Add_Change_Address
  (
    par_contact_id NUMBER
   ,par_country_id NUMBER
   ,
    /*par_city_id    NUMBER*/par_city_name VARCHAR2
  ) RETURN NUMBER IS
    CURSOR addr_curs(pcurs_contact_id NUMBER) IS
      SELECT ca.id address_id
            ,ca.country_id
            , /*ca.city_id, ca.province_id,*/ca.city_name
            ,ca.code
            ,ca.province_name
        FROM cn_contact_address cca
            ,cn_address         ca
       WHERE cca.is_default = 1
         AND cca.adress_id = ca.id
         AND cca.contact_id = pcurs_contact_id;
    v_updated       BOOLEAN := FALSE;
    v_country_name  t_country.description%TYPE;
    v_city_name     t_city.city_name%TYPE;
    v_name          cn_address.name%TYPE;
    v_id            NUMBER;
    v_return        NUMBER := 0;
    v_city_id       NUMBER;
    v_country_id    NUMBER;
    v_province_name VARCHAR2(100);
    v_province_id   NUMBER;
  BEGIN
    FOR addr_rec IN addr_curs(par_contact_id)
    LOOP
      IF NVL(addr_rec.country_id, -1) != NVL(par_country_id, -1)
         AND par_country_id IS NOT NULL
      THEN
        UPDATE ven_cn_address SET country_id = par_country_id WHERE id = addr_rec.address_id;
        v_return := 1; -- обновлена только страна
      END IF;
      IF NOT par_city_name IN ('A', 'B')
      THEN
        IF NVL(addr_rec.city_name, 'X') != NVL(par_city_name, 'X')
        THEN
          UPDATE ven_cn_address SET city_name = par_city_name WHERE id = addr_rec.address_id;
          IF NVL(v_return, 0) = 1
          THEN
            v_return := 3; -- обновлены страна и город
          ELSE
            v_return := 2; -- обновлен только город
          END IF;
        END IF;
      ELSE
        IF par_city_name = 'A'
        THEN
          IF addr_rec.province_name = 'Москва'
          THEN
            UPDATE ven_cn_address SET city_name = 'Москва' WHERE id = addr_rec.address_id;
            IF NVL(v_return, 0) = 1
            THEN
              v_return := 3; -- обновлены страна и город
            ELSE
              v_return := 2; -- обновлен только город
            END IF;
          ELSE
            UPDATE ven_cn_address
               SET /*province_id = 88,*/ province_name = 'Москва'
                  ,city_name     = 'Москва'
             WHERE id = addr_rec.address_id;
            IF NVL(v_return, 0) = 1
            THEN
              v_return := 3; -- обновлены страна и город
            ELSE
              v_return := 2; -- обновлен только город
            END IF;
          END IF;
        ELSIF par_city_name = ('B')
        THEN
          IF addr_rec.province_name = 'Санкт-Петербург'
          THEN
            UPDATE ven_cn_address
               SET city_name = 'Санкт-Петербург'
             WHERE id = addr_rec.address_id;
            IF NVL(v_return, 0) = 1
            THEN
              v_return := 3; -- обновлены страна и город
            ELSE
              v_return := 2; -- обновлен только город
            END IF;
          ELSE
            UPDATE ven_cn_address
               SET /*province_id = 90,*/ province_name = 'Санкт-Петербург'
                  ,city_name     = 'Санкт-Петербург'
             WHERE id = addr_rec.address_id;
            IF NVL(v_return, 0) = 1
            THEN
              v_return := 3; -- обновлены страна и город
            ELSE
              v_return := 2; -- обновлен только город
            END IF;
          END IF;
        END IF;
      END IF;
      v_updated := TRUE;
    END LOOP;
    IF NOT v_updated
       AND (par_country_id IS NOT NULL OR par_city_name IS NOT NULL)
    THEN
      BEGIN
        SELECT description INTO v_country_name FROM t_country WHERE id = par_country_id;
        v_return := 1; -- обновлена только страна
      EXCEPTION
        WHEN OTHERS THEN
          v_country_name := '';
      END;
      IF par_city_name = 'A'
      THEN
        v_city_name     := 'Москва';
        v_city_id       := NULL;
        v_province_name := 'Москва';
        v_province_id   := 88;
      ELSIF par_city_name = ('B')
      THEN
        v_city_name     := 'Санкт-Петербург';
        v_city_id       := NULL;
        v_province_name := 'Санкт-Петербург';
        v_province_id   := 90;
      ELSE
        v_province_name := NULL;
        v_province_id   := NULL;
        BEGIN
          /*SELECT  city_name
            INTO  v_city_name
            FROM  t_city
            WHERE city_id = par_city_id;
          v_city_id := par_city_id;*/
          IF NVL(v_return, 0) = 1
          THEN
            v_return := 3; -- обновлены страна и город
          ELSE
            v_return := 2; -- обновлен только город
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            v_city_name := '';
            v_city_id   := NULL;
        END;
      END IF;
      v_name := v_country_name;
      IF par_city_name IS NOT NULL
      THEN
        IF v_name IS NOT NULL
        THEN
          v_name := v_name || ', ';
        END IF;
        v_name := v_name || par_city_name;
      END IF;
      IF par_country_id IS NULL
      THEN
        SELECT id INTO v_country_id FROM t_country WHERE description = 'Россия';
      ELSE
        v_country_id := par_country_id;
      END IF;
      SELECT sq_cn_address.NEXTVAL INTO v_id FROM dual;
      INSERT INTO ven_cn_address
        (id
        ,country_id
        , /*city_id, */NAME
        ,city_name
        ,
         /*province_id, */province_name)
      VALUES
        (v_id
        ,v_country_id
        , /*v_city_id,*/v_name
        ,v_city_name
        ,
         /*v_province_id,*/v_province_name);
      INSERT INTO ven_cn_contact_address
        (contact_id, address_type, adress_id, is_default)
      VALUES
        (par_contact_id, (SELECT id FROM t_address_type WHERE brief = 'LEGAL'), v_id, 1);
    END IF;
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20001, 'Add_Change_Address: ' || SQLERRM);
  END Add_Change_Address;
  ----========================================================================----

  /*
  -- Обновление реквизитов банка
  PROCEDURE Update_Contact_Bank(
    par_contact_id NUMBER,
    par_bank_name  VARCHAR2,
    par_bic        VARCHAR2,
    par_corracc    VARCHAR2,
    par_country_id NUMBER,
    par_city_id    NUMBER,
    par_inn        VARCHAR2
    ) IS
    CURSOR contact_curs(
      pcurs_contact_id NUMBER
      ) IS
      SELECT  contact_id, obj_name_orig
        FROM  contact
        WHERE contact_id = pcurs_contact_id;
    v_ret NUMBER;
  BEGIN
    FOR contact_rec IN contact_curs( par_contact_id ) LOOP
      IF NVL( contact_rec.obj_name_orig, '~' ) != NVL( par_bank_name, '~' ) THEN
        UPDATE  ven_contact
          SET   obj_name_orig = par_bank_name
          WHERE contact_id = contact_rec.contact_id;
      END IF;
    END LOOP;
    v_ret := Add_Change_Value( par_contact_id, 'BIK',  par_bic );
    v_ret := Add_Change_Value( par_contact_id, 'KORR', par_corracc );
    v_ret := Add_Change_Value( par_contact_id, 'INN',  par_inn );
    v_ret := Add_Change_Address( par_contact_id, par_country_id, par_city_id );
  EXCEPTION
    WHEN others THEN
      Raise_Application_Error( -20001, 'Update_Contact_Bank: ' || SQLERRM );
  END Update_Contact_Bank;
  ----========================================================================----
  */
  -- Добавление информации о банке (заведение нового контакта)
  PROCEDURE Insert_Contact_Bank
  (
    par_contact_id NUMBER
   ,par_bank_name  VARCHAR2
   ,par_bic        VARCHAR2
   ,par_corracc    VARCHAR2
   ,par_country_id NUMBER
   ,par_city_id    NUMBER
   ,par_inn        VARCHAR2
   ,par_note       VARCHAR2
  ) IS
    v_ret NUMBER;
  BEGIN
    INSERT INTO ven_contact
      (contact_id
      ,contact_type_id
      ,NAME
      ,obj_name
      ,obj_name_orig
      ,note
      ,resident_flag
      ,t_contact_status_id)
    VALUES
      (par_contact_id
      ,(SELECT id FROM t_contact_type WHERE brief = 'КБ')
      ,par_bank_name
      ,par_bank_name
      ,par_bank_name
      ,par_note
      ,1
      ,(SELECT t_contact_status_id FROM t_contact_status WHERE is_default = 1));
    v_ret := Add_Change_Value(par_contact_id, 'BIK', par_bic);
    v_ret := Add_Change_Value(par_contact_id, 'KORR', par_corracc);
    v_ret := Add_Change_Value(par_contact_id, 'INN', par_inn);
    v_ret := Add_Change_Address(par_contact_id, par_country_id, par_city_id);
    INSERT INTO ven_cn_contact_role
      (contact_id, role_id)
    VALUES
      (par_contact_id, (SELECT id FROM t_contact_role WHERE brief = 'BANK'));
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20001, 'Insert_Contact_Bank: ' || SQLERRM);
  END Insert_Contact_Bank;
  /*
  ----========================================================================----
  -- Удаление банка
  PROCEDURE Delete_Contact_Bank(
    par_contact_id NUMBER
    ) IS
  BEGIN
    DELETE FROM ven_contact
      WHERE contact_id = par_contact_id;
  EXCEPTION
    WHEN others THEN
      Raise_Application_Error( -20001,
        'Контакт не может быть удален, так как используется в системе. ' ||
           SQLERRM );
  END Delete_Contact_Bank;
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк файлов банковских реквизитов
     -- (cn_bank_req_file_row)
     -- Входные параметры: идентификатор из sq_temp_load_blob,
        -- идентификатор файла (load_file_id)
  PROCEDURE Load_BLOB_To_Table(
    par_id           NUMBER,
    par_load_file_id NUMBER
    ) IS
    va_values              PKG_LOAD_FILE_TO_TABLE.t_varay;
    v_blob_data            BLOB;
    v_blob_len             NUMBER;
    v_position             NUMBER;
    c_chunk_len            NUMBER := 1;
    v_line                 VARCHAR2( 32767 ) := NULL;
    v_line_num             NUMBER := 0;
    v_char                 CHAR(1);
    v_raw_chunk            RAW(10000);
    v_cn_bank_req_file_row cn_bank_req_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT Before_Load;
    SELECT  file_blob
      INTO  v_blob_data
      FROM  temp_load_blob
      WHERE session_id = par_id;
    v_blob_len := DBMS_LOB.GetLength( v_blob_data );
    v_position := 1;
    WHILE ( v_position <= v_blob_len ) LOOP
      v_raw_chunk := DBMS_LOB.SubStr( v_blob_data, c_chunk_len, v_position );
      v_char :=  CHR( PKG_LOAD_FILE_TO_TABLE.Hex2Dec( RawToHex( v_raw_chunk ) ) );
      v_line := v_line || v_char;
      v_position := v_position + c_chunk_len;
      IF v_char = CHR( 10 ) THEN
        v_line := REPLACE( REPLACE( v_line, CHR( 10 ) ), CHR( 13 ) );
        v_line_num := v_line_num + 1;
        IF v_line_num > 1 THEN -- строку заголовков столбцов не грузим
          va_values := PKG_LOAD_FILE_TO_TABLE.Str2Array( v_line ); -- разбиение
                                                                 -- строки на поля
          IF v_line IS NOT NULL THEN
            v_cn_bank_req_file_row := NULL;
            SELECT sq_cn_bank_req_file_row.NEXTVAL
              INTO v_cn_bank_req_file_row.cn_bank_req_file_row_id
              FROM dual;
            v_cn_bank_req_file_row.load_file_id := par_load_file_id;
            v_cn_bank_req_file_row.status := 0;
            -- проход по полям
            FOR i IN va_values.FIRST..va_values.LAST LOOP
              CASE
                -- 1-ый столбец не грузим
                WHEN i = 2 THEN -- gorod
                  v_cn_bank_req_file_row.city_name := va_values( i );
                -- 3-ый столбец не грузим
                WHEN i = 4 THEN
                  v_cn_bank_req_file_row.bank_name := va_values( i );
                -- 5-ый столбец не грузим
                WHEN i = 6 THEN
                  v_cn_bank_req_file_row.bic := va_values( i );
                WHEN i = 7 THEN
                  v_cn_bank_req_file_row.corracc := va_values( i );
                ELSE
                  NULL;
                \* Образцы загрузки дат и чисел
                WHEN i = 4 THEN
                  v_as_bordero_load.birth_date :=
                    TO_DATE( va_values( i ), 'DD.MM.YYYY' );
                WHEN i = 16 THEN
                  v_as_bordero_load.ins_sum :=
                    TO_NUMBER( TRANSLATE( va_values( i ), ',.', '..' ),
                      '9999999999.99');*\
              END CASE;
            END LOOP;
            -- Из названия банка убрать кавычки в начале и в конце строки
               -- и повторные кавычки в середине строки
            IF SUBSTR( v_cn_bank_req_file_row.bank_name, 1, 1 ) = '"' THEN
              v_cn_bank_req_file_row.bank_name :=
                SUBSTR( v_cn_bank_req_file_row.bank_name, 2 );
            END IF;
            IF SUBSTR( v_cn_bank_req_file_row.bank_name, -1, 1 ) = '"' THEN
              v_cn_bank_req_file_row.bank_name :=
                SUBSTR( v_cn_bank_req_file_row.bank_name, 1,
                  LENGTH( v_cn_bank_req_file_row.bank_name ) - 1 );
            END IF;
            v_cn_bank_req_file_row.bank_name :=
              REPLACE( v_cn_bank_req_file_row.bank_name, '""', '"' );
            INSERT INTO cn_bank_req_file_row( cn_bank_req_file_row_id,
                load_file_id,
                city_name,
                bank_name,
                bic,
                corracc,
                status )
              VALUES( v_cn_bank_req_file_row.cn_bank_req_file_row_id,
                v_cn_bank_req_file_row.load_file_id,
                v_cn_bank_req_file_row.city_name,
                v_cn_bank_req_file_row.bank_name,
                v_cn_bank_req_file_row.bic,
                v_cn_bank_req_file_row.corracc,
                v_cn_bank_req_file_row.status );
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN others THEN
    ROLLBACK TO Before_Load;
      RAISE_APPLICATION_ERROR(-20001,
        'Ошибка при выполнении Load_BLOB_To_Table ' || SQLERRM );
  END Load_BLOB_To_Table;
  ----========================================================================----
  -- Обновление реквизитов банка c заполнением поля информации записи,
     -- соответствующей строке файла ЦБ
  PROCEDURE Update_Contact_Bank_With_Info(
    par_cn_bank_req_file_row_id NUMBER,
    par_contact_id              NUMBER,
    par_bank_name               VARCHAR2,
    par_bic                     VARCHAR2,
    par_corracc                 VARCHAR2,
    par_country_id              NUMBER,
    par_city_id                 NUMBER
    ) IS
    CURSOR contact_curs(
      pcurs_contact_id NUMBER
      ) IS
      SELECT  contact_id, obj_name_orig, bic, corracc, inn, country_id,
              country_name, city_id, city_name
        FROM  v_contact_bank_list
        WHERE contact_id = pcurs_contact_id;
    v_ret  NUMBER;
    v_info VARCHAR2( 4000 );
  BEGIN
    FOR contact_rec IN contact_curs( par_contact_id ) LOOP
      IF NVL( contact_rec.obj_name_orig, '~' ) != NVL( par_bank_name, '~' ) THEN
        UPDATE  ven_contact
          SET   obj_name_orig = par_bank_name
          WHERE contact_id = contact_rec.contact_id;
        v_info := 'Обновлено название. Предыдущее: ' ||
          contact_rec.obj_name_orig || '. ';
      END IF;
      v_ret := Add_Change_Value( par_contact_id, 'BIK',  par_bic );
      IF v_ret = 1 THEN
        v_info := v_info || 'Обновлен БИК. Предыдущий: ' ||
          contact_rec.bic || '. ';
      END IF;
      v_ret := Add_Change_Value( par_contact_id, 'KORR', par_corracc );
      IF v_ret = 1 THEN
        v_info := v_info || 'Обновлен корр. счет. Предыдущий: ' ||
          contact_rec.corracc || '. ';
      END IF;
      -- v_ret := Add_Change_Value( par_contact_id, 'INN',  par_inn );
      v_ret := Add_Change_Address( par_contact_id, par_country_id,
        par_city_id );
      IF v_ret = 1 THEN
        v_info := v_info || 'Обновлена страна. Предыдущая: ' ||
          contact_rec.country_name || '. ';
      ELSIF v_ret = 2 THEN
        v_info := v_info || 'Обновлен город. Предыдущий: ' ||
          contact_rec.city_name || '. ';
      ELSIF v_ret = 3 THEN
        v_info := v_info || 'Обновлена страна и город. Предыдущие: ' ||
          contact_rec.country_name || ' ' || contact_rec.city_name || '. ';
      END IF;
    END LOOP;
    IF v_info IS NOT NULL THEN
      UPDATE  cn_bank_req_file_row
        SET   info      = v_info,
              status    = 2, -- загружено частично
              load_date = SYSDATE,
              user_name = USER
        WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
    ELSE
      UPDATE  cn_bank_req_file_row
        SET   info      = 'Обновление не потребовалось',
              status    = 3, -- загрузка не потребовалась
              load_date = SYSDATE,
              user_name = USER
        WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
    END IF;
  EXCEPTION
    WHEN others THEN
      v_info := SQLERRM;
      v_info := 'Ошибка: ' || v_info;
      UPDATE  cn_bank_req_file_row
        SET   info      = v_info,
              status    = ( -1 ),
              load_date = SYSDATE,
              user_name = USER
        WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
  END Update_Contact_Bank_With_Info;
  ----========================================================================----
  */ /*
-- Добавление информации о банке (заведение нового контакта)
   -- c заполнением поля информации записи, соответствующей строке файла ЦБ
PROCEDURE Insert_Contact_Bank_With_Info(
  par_cn_bank_req_file_row_id NUMBER,
  par_contact_id              NUMBER,
  par_bank_name               VARCHAR2,
  par_bic                     VARCHAR2,
  par_corracc                 VARCHAR2,
  par_country_id              NUMBER,
  par_city_id                 NUMBER,
  par_inn                     VARCHAR2,
  par_note                    VARCHAR2
  ) IS
  v_ret  NUMBER;
  v_info VARCHAR2( 4000 );
BEGIN
  INSERT INTO ven_contact( contact_id, contact_type_id,
      name, obj_name, obj_name_orig, note, resident_flag,
      t_contact_status_id )
    VALUES( par_contact_id, ( SELECT id FROM t_contact_type WHERE brief = 'КБ' ),
      par_bank_name, par_bank_name, par_bank_name, par_note, 1,
      ( SELECT t_contact_status_id FROM t_contact_status
         WHERE is_default = 1 ) );
  v_ret := Add_Change_Value( par_contact_id, 'BIK',  par_bic );
  v_ret := Add_Change_Value( par_contact_id, 'KORR', par_corracc );
  v_ret := Add_Change_Value( par_contact_id, 'INN',  par_inn );
  v_ret := Add_Change_Address( par_contact_id, par_country_id, par_city_id );
  INSERT INTO ven_cn_contact_role( contact_id, role_id )
    VALUES ( par_contact_id,
      ( SELECT id FROM t_contact_role WHERE brief = 'BANK' ) );
  UPDATE  cn_bank_req_file_row
    SET   info      = 'Загружено успешно',
          status    = 1,
          load_date = SYSDATE,
          user_name = USER
    WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
EXCEPTION
  WHEN others THEN
    v_info := SQLERRM;
    v_info := 'Ошибка: ' || v_info;
    UPDATE  cn_bank_req_file_row
      SET   info      = v_info,
            status    = ( -1 ),
            load_date = SYSDATE,
            user_name = USER
      WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
END Insert_Contact_Bank_With_Info;
*/
/*
----========================================================================----
FUNCTION Update_cn_bank_req_file_row(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER IS
v_result NUMBER := 0;
v_load_file_id NUMBER;
BEGIN

  SELECT sq_load_file.NEXTVAL INTO v_load_file_id FROM dual;
  INSERT INTO load_file( load_file_id, file_name, file_code )
    VALUES( v_load_file_id, par_file_name, 'BANK_REQ' );

 UPDATE cn_bank_req_file_row rc
  SET rc.load_file_id = v_load_file_id
 WHERE rc.load_file_id IS NULL;

 FOR cur IN (
  SELECT rc.cn_bank_req_file_row_id,
         rc.city_name,
         rc.bank_name,
         rc.bic,
         rc.corracc
  FROM cn_bank_req_file_row rc
  WHERE rc.load_file_id = v_load_file_id
 )
 LOOP
  pkg_contact_bank.Load_One_Bank(
  cur.cn_bank_req_file_row_id,
  cur.city_name,
  cur.bank_name,
  cur.bic,
  cur.corracc
  );
 END LOOP;
\*insert into tmp$_kladr_hist
values
(sysdate,'BANK');*\
 RETURN v_result;

END Update_cn_bank_req_file_row;
----========================================================================----
FUNCTION Update_Kladr_Kladr(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER IS
v_result NUMBER := 0;
v_load_file_id NUMBER;
BEGIN

  SELECT sq_load_file.NEXTVAL INTO v_load_file_id FROM dual;
  INSERT INTO load_file( load_file_id, file_name, file_code )
    VALUES( v_load_file_id, 'UPDATE_KLADR', 'KLADR_KLADR' );

 UPDATE kladr_kladr_file_row rc
  SET rc.load_file_id = v_load_file_id
 WHERE rc.load_file_id IS NULL;

 v_result := pkg_contact_bank.Update_Kladr_Altnames('UPDATE_ALTNAMES', 'KLADR_ALTNAMES');
 pkg_contact_bank.Load_Kladr_City(v_load_file_id);
 v_result := pkg_contact_bank.Update_Kladr_Street('UPDATE_STREET', 'KLADR_STREET');
 pkg_contact_bank.Load_Kladr_Region(v_load_file_id);
 pkg_contact_bank.Load_Kladr_Province(v_load_file_id);
 pkg_contact_bank.Load_Kladr_District(v_load_file_id);

\*insert into tmp$_kladr_hist
values
(sysdate,'KLADR_KLADR');*\

 RETURN v_result;

END Update_Kladr_Kladr;
----========================================================================----
PROCEDURE Load_Kladr_City(p_load_file_id NUMBER) IS
 CURSOR city_curs IS
    SELECT kladr_kladr_file_row_id, row_name, row_socr, row_code, row_index, row_ocatd
     FROM  kladr_kladr_file_row
     WHERE load_file_id = p_load_file_id
       AND row_socr IN ( SELECT description_short FROM t_city_type );
  v_id        NUMBER;
  v_info      VARCHAR2( 4000 );
  v_tmp       VARCHAR2( 4000 );
  v_city_name VARCHAR2( 255 );
  v_zip       VARCHAR2( 100 );
  v_ocatd     VARCHAR2( 100 );
BEGIN
  COMMIT;
  FOR city_rec IN city_curs LOOP
    v_info := '';
    BEGIN
      SELECT  city_id, city_name, zip, ocatd
        INTO  v_id, v_city_name, v_zip, v_ocatd
        FROM  t_city
        WHERE kladr_code_hist = city_rec.row_code;
      IF NVL( v_city_name, '~' ) != NVL( city_rec.row_name, '~' ) THEN
        UPDATE t_city
          SET  city_name = city_rec.row_name
          WHERE city_id = v_id;
        v_info := 'Обновлено название. Старое: ' || v_city_name || '. ';
      END IF;
      IF NVL( v_zip, '~' ) != NVL( city_rec.row_index, '~' ) THEN
        UPDATE t_city
          SET  zip = city_rec.row_index
          WHERE city_id = v_id;
        v_info := v_info || 'Обновлен индекс. Старый: ' || v_zip || '. ';
      END IF;
      IF NVL( v_ocatd, '~' ) != NVL( city_rec.row_ocatd, '~' ) THEN
        UPDATE t_city
          SET  ocatd = city_rec.row_ocatd
          WHERE city_id = v_id;
        v_info := v_info || 'Обновлен ОКАТД. Старый: ' || v_ocatd || '. ';
      END IF;
      IF v_info IS NOT NULL THEN
        UPDATE  kladr_kladr_file_row
          SET   status = 2,
                info   = v_info
          WHERE kladr_kladr_file_row_id = city_rec.kladr_kladr_file_row_id;
      ELSE
        v_info := 'Обработка не потребовалась';
        UPDATE  kladr_kladr_file_row
          SET   status = 3,
                info   = v_info
          WHERE kladr_kladr_file_row_id = city_rec.kladr_kladr_file_row_id;
      END IF;
      COMMIT;
    EXCEPTION
      WHEN no_data_found THEN
        v_info := NULL;
      WHEN others THEN
        v_tmp := SQLERRM;
        v_info := 'Ошибка t_city: ' || v_tmp;
        ROLLBACK;
        UPDATE  kladr_kladr_file_row
          SET   status = -1,
                info   = v_info
          WHERE kladr_kladr_file_row_id = city_rec.kladr_kladr_file_row_id;
        COMMIT;
    END;
    IF v_info IS NULL THEN
      INSERT INTO ven_t_city( city_name,
          city_type_id,
          kladr_code,
          kladr_code_parent, kladr_code_hist,
          zip, ocatd, is_default )
        VALUES( city_rec.row_name,
          ( SELECT city_type_id FROM t_city_type WHERE description_short = city_rec.row_socr ),
          SUBSTR( city_rec.row_code, 1, 11 ),
          SUBSTR( city_rec.row_code, 1, 5 ) || '000000', city_rec.row_code,
          city_rec.row_index, city_rec.row_ocatd, 0 );
      UPDATE  kladr_kladr_file_row
        SET   status = 1,
              info   = 'Загружено'
        WHERE kladr_kladr_file_row_id = city_rec.kladr_kladr_file_row_id;
      COMMIT;
    END IF;
  END LOOP;
END Load_Kladr_City;
----========================================================================----
PROCEDURE Load_Kladr_District(p_load_file_id NUMBER) IS
 CURSOR district_curs IS
    SELECT kladr_kladr_file_row_id, row_name, row_socr, row_code, row_index, row_ocatd
     FROM  kladr_kladr_file_row
     WHERE load_file_id = p_load_file_id
       AND row_socr IN ( SELECT description_short FROM t_district_type )
       AND status = 0;
  v_id        NUMBER;
  v_info      VARCHAR2( 4000 );
  v_tmp       VARCHAR2( 4000 );
  v_district_name VARCHAR2( 255 );
  v_zip       VARCHAR2( 100 );
  v_ocatd     VARCHAR2( 100 );
BEGIN
  COMMIT;
  FOR district_rec IN district_curs LOOP
    v_info := '';
    BEGIN
      SELECT  district_id, district_name, zip, ocatd
        INTO  v_id, v_district_name, v_zip, v_ocatd
        FROM  t_district
        WHERE kladr_code_hist = district_rec.row_code;
      IF NVL( v_district_name, '~' ) != NVL( district_rec.row_name, '~' ) THEN
        UPDATE t_district
          SET  district_name = district_rec.row_name
          WHERE district_id = v_id;
        v_info := 'Обновлено название. Старое: ' || v_district_name || '. ';
      END IF;
      IF NVL( v_zip, '~' ) != NVL( district_rec.row_index, '~' ) THEN
        UPDATE t_district
          SET  zip = district_rec.row_index
          WHERE district_id = v_id;
        v_info := v_info || 'Обновлен индекс. Старый: ' || v_zip || '. ';
      END IF;
      IF NVL( v_ocatd, '~' ) != NVL( district_rec.row_ocatd, '~' ) THEN
        UPDATE t_district
          SET  ocatd = district_rec.row_ocatd
          WHERE district_id = v_id;
        v_info := v_info || 'Обновлен ОКАТД. Старый: ' || v_ocatd || '. ';
      END IF;
      IF v_info IS NOT NULL THEN
        UPDATE  kladr_kladr_file_row
          SET   status = 2,
                info   = v_info
          WHERE kladr_kladr_file_row_id = district_rec.kladr_kladr_file_row_id;
      ELSE
        v_info := 'Обработка не потребовалась';
        UPDATE  kladr_kladr_file_row
          SET   status = 3,
                info   = v_info
          WHERE kladr_kladr_file_row_id = district_rec.kladr_kladr_file_row_id;
      END IF;
      COMMIT;
    EXCEPTION
      WHEN no_data_found THEN
        v_info := NULL;
      WHEN others THEN
        v_tmp := SQLERRM;
        v_info := 'Ошибка t_district: ' || v_tmp;
        ROLLBACK;
        UPDATE  kladr_kladr_file_row
          SET   status = -1,
                info   = v_info
          WHERE kladr_kladr_file_row_id = district_rec.kladr_kladr_file_row_id;
        COMMIT;
    END;
    IF v_info IS NULL THEN
      INSERT INTO ven_t_district( district_name,
          district_type_id,
          kladr_code,
          kladr_code_parent, kladr_code_hist,
          zip, ocatd, is_default )
        VALUES( district_rec.row_name,
          ( SELECT district_type_id FROM t_district_type WHERE description_short = district_rec.row_socr ),
          SUBSTR( district_rec.row_code, 1, 11 ),
          SUBSTR( district_rec.row_code, 1, 5 ) || '000000', district_rec.row_code,
          district_rec.row_index, district_rec.row_ocatd, 0 );
      UPDATE  kladr_kladr_file_row
        SET   status = 1,
              info   = 'Загружено'
        WHERE kladr_kladr_file_row_id = district_rec.kladr_kladr_file_row_id;
      COMMIT;
    END IF;
  END LOOP;
END Load_Kladr_District;
----========================================================================----
PROCEDURE Load_Kladr_Region(p_load_file_id NUMBER) IS
 CURSOR region_curs IS
    SELECT kladr_kladr_file_row_id, row_name, row_socr, row_code, row_index, row_ocatd
     FROM  kladr_kladr_file_row
     WHERE load_file_id = p_load_file_id
       AND row_socr IN ( SELECT description_short FROM t_region_type )
       AND status = 0;
  v_id        NUMBER;
  v_info      VARCHAR2( 4000 );
  v_tmp       VARCHAR2( 4000 );
  v_region_name VARCHAR2( 255 );
  v_zip       VARCHAR2( 100 );
  v_ocatd     VARCHAR2( 100 );
BEGIN
  COMMIT;
  FOR region_rec IN region_curs LOOP
    v_info := '';
    BEGIN
      SELECT  region_id, region_name, zip, ocatd
        INTO  v_id, v_region_name, v_zip, v_ocatd
        FROM  t_region
        WHERE kladr_code_hist = region_rec.row_code;
      IF NVL( v_region_name, '~' ) != NVL( region_rec.row_name, '~' ) THEN
        UPDATE t_region
          SET  region_name = region_rec.row_name
          WHERE region_id = v_id;
        v_info := 'Обновлено название. Старое: ' || v_region_name || '. ';
      END IF;
      IF NVL( v_zip, '~' ) != NVL( region_rec.row_index, '~' ) THEN
        UPDATE t_region
          SET  zip = region_rec.row_index
          WHERE region_id = v_id;
        v_info := v_info || 'Обновлен индекс. Старый: ' || v_zip || '. ';
      END IF;
      IF NVL( v_ocatd, '~' ) != NVL( region_rec.row_ocatd, '~' ) THEN
        UPDATE t_region
          SET  ocatd = region_rec.row_ocatd
          WHERE region_id = v_id;
        v_info := v_info || 'Обновлен ОКАТД. Старый: ' || v_ocatd || '. ';
      END IF;
      IF v_info IS NOT NULL THEN
        UPDATE  kladr_kladr_file_row
          SET   status = 2,
                info   = v_info
          WHERE kladr_kladr_file_row_id = region_rec.kladr_kladr_file_row_id;
      ELSE
        v_info := 'Обработка не потребовалась';
        UPDATE  kladr_kladr_file_row
          SET   status = 3,
                info   = v_info
          WHERE kladr_kladr_file_row_id = region_rec.kladr_kladr_file_row_id;
      END IF;
      COMMIT;
    EXCEPTION
      WHEN no_data_found THEN
        v_info := NULL;
      WHEN others THEN
        v_tmp := SQLERRM;
        v_info := 'Ошибка t_region: ' || v_tmp;
        ROLLBACK;
        UPDATE  kladr_kladr_file_row
          SET   status = -1,
                info   = v_info
          WHERE kladr_kladr_file_row_id = region_rec.kladr_kladr_file_row_id;
        COMMIT;
    END;
    IF v_info IS NULL THEN
      INSERT INTO ven_t_region( region_name,
          region_type_id,
          kladr_code,
          kladr_code_parent, kladr_code_hist,
          zip, ocatd, is_default )
        VALUES( region_rec.row_name,
          ( SELECT region_type_id FROM t_region_type WHERE description_short = region_rec.row_socr ),
          SUBSTR( region_rec.row_code, 1, 11 ),
          SUBSTR( region_rec.row_code, 1, 5 ) || '000000', region_rec.row_code,
          region_rec.row_index, region_rec.row_ocatd, 0 );
      UPDATE  kladr_kladr_file_row
        SET   status = 1,
              info   = 'Загружено'
        WHERE kladr_kladr_file_row_id = region_rec.kladr_kladr_file_row_id;
      COMMIT;
    END IF;
  END LOOP;
END Load_Kladr_Region;
----========================================================================----
PROCEDURE Load_Kladr_Province(p_load_file_id NUMBER) IS
  CURSOR province_curs IS
    SELECT kladr_kladr_file_row_id, row_name, row_socr, row_code, row_index, row_ocatd
     FROM  kladr_kladr_file_row
     WHERE load_file_id = p_load_file_id
       AND row_socr IN ( SELECT description_short FROM t_province_type )
       AND status = 0;
  v_id        NUMBER;
  v_info      VARCHAR2( 4000 );
  v_tmp       VARCHAR2( 4000 );
  v_province_name VARCHAR2( 255 );
  v_zip       VARCHAR2( 100 );
  v_ocatd     VARCHAR2( 100 );
BEGIN
  COMMIT;
  FOR province_rec IN province_curs LOOP
    v_info := '';
    BEGIN
      SELECT  province_id, province_name, zip, ocatd
        INTO  v_id, v_province_name, v_zip, v_ocatd
        FROM  t_province
        WHERE kladr_code_hist = province_rec.row_code;
      IF NVL( v_province_name, '~' ) != NVL( province_rec.row_name, '~' ) THEN
        UPDATE t_province
          SET  province_name = province_rec.row_name
          WHERE province_id = v_id;
        v_info := 'Обновлено название. Старое: ' || v_province_name || '. ';
      END IF;
      IF NVL( v_zip, '~' ) != NVL( province_rec.row_index, '~' ) THEN
        UPDATE t_province
          SET  zip = province_rec.row_index
          WHERE province_id = v_id;
        v_info := v_info || 'Обновлен индекс. Старый: ' || v_zip || '. ';
      END IF;
      IF NVL( v_ocatd, '~' ) != NVL( province_rec.row_ocatd, '~' ) THEN
        UPDATE t_province
          SET  ocatd = province_rec.row_ocatd
          WHERE province_id = v_id;
        v_info := v_info || 'Обновлен ОКАТД. Старый: ' || v_ocatd || '. ';
      END IF;
      IF v_info IS NOT NULL THEN
        UPDATE  kladr_kladr_file_row
          SET   status = 2,
                info   = v_info
          WHERE kladr_kladr_file_row_id = province_rec.kladr_kladr_file_row_id;
      ELSE
        v_info := 'Обработка не потребовалась';
        UPDATE  kladr_kladr_file_row
          SET   status = 3,
                info   = v_info
          WHERE kladr_kladr_file_row_id = province_rec.kladr_kladr_file_row_id;
      END IF;
      COMMIT;
    EXCEPTION
      WHEN no_data_found THEN
        v_info := NULL;
      WHEN others THEN
        v_tmp := SQLERRM;
        v_info := 'Ошибка t_province: ' || v_tmp;
        ROLLBACK;
        UPDATE  kladr_kladr_file_row
          SET   status = -1,
                info   = v_info
          WHERE kladr_kladr_file_row_id = province_rec.kladr_kladr_file_row_id;
        COMMIT;
    END;
    IF v_info IS NULL THEN
      INSERT INTO ven_t_province( province_name,
          province_type_id,
          kladr_code,
          kladr_code_parent, kladr_code_hist,
          zip, ocatd, is_default,
          country_id )
        VALUES( province_rec.row_name,
          ( SELECT province_type_id FROM t_province_type WHERE description_short = province_rec.row_socr ),
          SUBSTR( province_rec.row_code, 1, 11 ),
          SUBSTR( province_rec.row_code, 1, 5 ) || '000000', province_rec.row_code,
          province_rec.row_index, province_rec.row_ocatd, 0,
          ( SELECT id FROM t_country WHERE description = 'Россия' ) );
      UPDATE  kladr_kladr_file_row
        SET   status = 1,
              info   = 'Загружено'
        WHERE kladr_kladr_file_row_id = province_rec.kladr_kladr_file_row_id;
      COMMIT;
    END IF;
  END LOOP;
END Load_Kladr_Province;
----========================================================================----
FUNCTION Update_Kladr_Street(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER IS
v_result NUMBER := 0;
v_load_file_id NUMBER;
BEGIN

  SELECT sq_load_file.NEXTVAL INTO v_load_file_id FROM dual;
  INSERT INTO load_file( load_file_id, file_name, file_code )
    VALUES( v_load_file_id, par_file_name, par_file_code );

 UPDATE kladr_street_file_row rc
  SET rc.load_file_id = v_load_file_id
 WHERE rc.load_file_id IS NULL;

 pkg_contact_bank.Load_Street(v_load_file_id);

\*insert into tmp$_kladr_hist
values
(sysdate,'KLADR_STREET');*\

 RETURN v_result;

END Update_Kladr_Street;
----========================================================================----
PROCEDURE Load_Street(p_load_file_id NUMBER) IS
 CURSOR street_curs IS
    SELECT kladr_street_file_row_id, row_name, row_socr, row_code, row_index, row_ocatd
     FROM  kladr_street_file_row
     WHERE load_file_id = p_load_file_id;
  v_id          NUMBER;
  v_info        VARCHAR2( 4000 );
  v_tmp         VARCHAR2( 4000 );
  v_street_name VARCHAR2( 255 );
  v_zip         VARCHAR2( 100 );
  v_ocatd       VARCHAR2( 100 );
BEGIN
  COMMIT;
  FOR street_rec IN street_curs LOOP
    v_info := '';
    BEGIN
      SELECT  street_id, street_name, zip, ocatd
        INTO  v_id, v_street_name, v_zip, v_ocatd
        FROM  t_street
        WHERE kladr_code_hist = street_rec.row_code;
      IF NVL( v_street_name, '~' ) != NVL( street_rec.row_name, '~' ) THEN
        UPDATE t_street
          SET  street_name = street_rec.row_name
          WHERE street_id = v_id;
        v_info := 'Обновлено название. Старое: ' || v_street_name || '. ';
      END IF;
      IF NVL( v_zip, '~' ) != NVL( street_rec.row_index, '~' ) THEN
        UPDATE t_street
          SET  zip = street_rec.row_index
          WHERE street_id = v_id;
        v_info := v_info || 'Обновлен индекс. Старый: ' || v_zip || '. ';
      END IF;
      IF NVL( v_ocatd, '~' ) != NVL( street_rec.row_ocatd, '~' ) THEN
        UPDATE t_street
          SET  ocatd = street_rec.row_ocatd
          WHERE street_id = v_id;
        v_info := v_info || 'Обновлен ОКАТД. Старый: ' || v_ocatd || '. ';
      END IF;
      IF v_info IS NOT NULL THEN
        UPDATE  kladr_street_file_row
          SET   status = 2,
                info   = v_info
          WHERE kladr_street_file_row_id = street_rec.kladr_street_file_row_id;
      ELSE
        v_info := 'Обработка не потребовалась';
        UPDATE  kladr_street_file_row
          SET   status = 3,
                info   = v_info
          WHERE kladr_street_file_row_id = street_rec.kladr_street_file_row_id;
      END IF;
      COMMIT;
    EXCEPTION
      WHEN no_data_found THEN
        v_info := NULL;
      WHEN others THEN
        v_tmp := SQLERRM;
        v_info := 'Ошибка t_street: ' || v_tmp;
        ROLLBACK;
        UPDATE  kladr_street_file_row
          SET   status = -1,
                info   = v_info
          WHERE kladr_street_file_row_id = street_rec.kladr_street_file_row_id;
        COMMIT;
    END;
    IF v_info IS NULL THEN
      INSERT INTO ven_t_street( street_name,
          street_type_id,
          kladr_code,
          kladr_code_parent, kladr_code_hist,
          zip, ocatd, is_default )
        VALUES( street_rec.row_name,
          ( SELECT street_type_id FROM t_street_type WHERE description_short = street_rec.row_socr ),
          SUBSTR( street_rec.row_code, 1, 15 ),
          SUBSTR( street_rec.row_code, 1, 11 ) || '0000', street_rec.row_code,
          street_rec.row_index, street_rec.row_ocatd, 0 );
      UPDATE  kladr_street_file_row
        SET   status = 1,
              info   = 'Загружено'
        WHERE kladr_street_file_row_id = street_rec.kladr_street_file_row_id;
      COMMIT;
    END IF;
  END LOOP;
END Load_Street;
----========================================================================----
FUNCTION Update_Kladr_Altnames(par_file_name VARCHAR2, par_file_code VARCHAR2) RETURN NUMBER IS
v_result NUMBER := 0;
v_load_file_id NUMBER;
BEGIN

  SELECT sq_load_file.NEXTVAL INTO v_load_file_id FROM dual;
  INSERT INTO load_file( load_file_id, file_name, file_code )
    VALUES( v_load_file_id, par_file_name, par_file_code );

 UPDATE kladr_altnames_file_row rc
  SET rc.load_file_id = v_load_file_id
 WHERE rc.load_file_id IS NULL;

 pkg_contact_bank.Load_Altnames(v_load_file_id);

\*insert into tmp$_kladr_hist
values
(sysdate,'KLADR_ALTNAMES');*\

 RETURN v_result;

END Update_Kladr_Altnames;
----========================================================================----
PROCEDURE Load_Altnames(p_load_file_id NUMBER) IS
CURSOR alt_curs IS
    SELECT kladr_altnames_file_row_id, row_oldcode, row_newcode, row_level
     FROM  kladr_altnames_file_row
     WHERE load_file_id = p_load_file_id;
  v_info VARCHAR2( 4000 );
  v_tmp  VARCHAR2( 4000 );
  v_id   NUMBER;
BEGIN

  COMMIT;
  FOR alt_row IN alt_curs LOOP
    v_info := '';
    BEGIN
      SELECT  city_id
        INTO  v_id
        FROM  t_city
        WHERE kladr_code_hist = alt_row.row_oldcode;
      UPDATE  t_city
        SET   kladr_code = SUBSTR( alt_row.row_newcode, 1, 11 ),
              kladr_code_parent = SUBSTR( alt_row.row_newcode, 1, 5 ) || '000000',
              kladr_code_hist = alt_row.row_newcode
        WHERE city_id = v_id;
      v_info := 'Обновлена t_city, city_id = ' || TO_CHAR( v_id );
    EXCEPTION
      WHEN no_data_found THEN
        v_info := '';
      WHEN others THEN
        v_tmp := SQLERRM;
        v_tmp := 'Ошибка t_city: ' || v_tmp;
        ROLLBACK;
        UPDATE  kladr_altnames_file_row
          SET   status = -1,
                info   = v_tmp
          WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
        COMMIT;
    END;
    IF v_info IS NULL THEN
      BEGIN
        SELECT  street_id
          INTO  v_id
          FROM  t_street
          WHERE kladr_code_hist = alt_row.row_oldcode;
        UPDATE  t_street
          SET   kladr_code = SUBSTR( alt_row.row_newcode, 1, 11 ),
                kladr_code_parent = SUBSTR( alt_row.row_newcode, 1, 8 ) || '000',
                kladr_code_hist = alt_row.row_newcode
          WHERE street_id = v_id;
        v_info := 'Обновлена t_street, street_id = ' || TO_CHAR( v_id );
      EXCEPTION
        WHEN no_data_found THEN
          v_info := '';
        WHEN others THEN
          v_tmp := SQLERRM;
          v_tmp := 'Ошибка t_street: ' || v_tmp;
          ROLLBACK;
          UPDATE  kladr_altnames_file_row
            SET   status = -1,
                  info   = v_tmp
            WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
          COMMIT;
      END;
    END IF;
    IF v_info IS NULL THEN
      BEGIN
        SELECT  district_id
          INTO  v_id
          FROM  t_district
          WHERE kladr_code_hist = alt_row.row_oldcode;
        UPDATE  t_district
          SET   kladr_code = SUBSTR( alt_row.row_newcode, 1, 11 ),
                kladr_code_parent = SUBSTR( alt_row.row_newcode, 1, 8 ) || '000',
                kladr_code_hist = alt_row.row_newcode
          WHERE district_id = v_id;
        v_info := 'Обновлена t_district, district_id = ' || TO_CHAR( v_id );
      EXCEPTION
        WHEN no_data_found THEN
          v_info := '';
        WHEN others THEN
          v_tmp := SQLERRM;
          v_tmp := 'Ошибка t_district: ' || v_tmp;
          ROLLBACK;
          UPDATE  kladr_altnames_file_row
            SET   status = -1,
                  info   = v_tmp
            WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
          COMMIT;
      END;
    END IF;
    IF v_info IS NULL THEN
      BEGIN
        SELECT  region_id
          INTO  v_id
          FROM  t_region
          WHERE kladr_code_hist = alt_row.row_oldcode;
        UPDATE  t_region
          SET   kladr_code = SUBSTR( alt_row.row_newcode, 1, 11 ),
                kladr_code_parent = SUBSTR( alt_row.row_newcode, 1, 2 ) || '000000000',
                kladr_code_hist = alt_row.row_newcode
          WHERE region_id = v_id;
        v_info := 'Обновлена t_region, region_id = ' || TO_CHAR( v_id );
      EXCEPTION
        WHEN no_data_found THEN
          v_info := '';
        WHEN others THEN
          v_tmp := SQLERRM;
          v_tmp := 'Ошибка t_region: ' || v_tmp;
          ROLLBACK;
          UPDATE  kladr_altnames_file_row
            SET   status = -1,
                  info   = v_tmp
            WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
          COMMIT;
      END;
    END IF;
    IF v_info IS NULL THEN
      BEGIN
        SELECT  province_id
          INTO  v_id
          FROM  t_province
          WHERE kladr_code_hist = alt_row.row_oldcode;
        UPDATE  t_province
          SET   kladr_code = SUBSTR( alt_row.row_newcode, 1, 11 ),
                kladr_code_parent = '',
                kladr_code_hist = alt_row.row_newcode
          WHERE province_id = v_id;
        v_info := 'Обновлена t_province, province_id = ' || TO_CHAR( v_id );
      EXCEPTION
        WHEN no_data_found THEN
          v_info := '';
        WHEN others THEN
          v_tmp := SQLERRM;
          v_tmp := 'Ошибка t_province: ' || v_tmp;
          ROLLBACK;
          UPDATE  kladr_altnames_file_row
            SET   status = -1,
                  info   = v_tmp
            WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
          COMMIT;
      END;
    END IF;
    IF v_info IS NOT NULL THEN
      UPDATE  kladr_altnames_file_row
        SET   status = 1,
              info   = v_info
        WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
    ELSE
      UPDATE  kladr_altnames_file_row
       SET   status = 3,
             info   = 'Старый код КЛАДР не найден'
       WHERE kladr_altnames_file_row_id = alt_row.kladr_altnames_file_row_id;
    END IF;
    COMMIT;
   END LOOP;

END Load_Altnames;
----========================================================================----
-- Загрузка/редактирование реквизитов одного банка по данным строки файла
PROCEDURE Load_One_Bank(
  par_cn_bank_req_file_row_id NUMBER,
  par_city_name               VARCHAR2,
  par_bank_name               VARCHAR2,
  par_bic                     VARCHAR2,
  par_corracc                 VARCHAR2
  ) IS
  CURSOR bic_curs(
    pcurs_bic VARCHAR2
    ) IS
    SELECT  contact_id
      FROM  v_contact_bank_list
      WHERE bic = pcurs_bic;
  v_contact_id NUMBER := NULL;
  v_info       VARCHAR2( 4000 );
  e_error      EXCEPTION;
  v_country_id NUMBER;
  v_city_id    NUMBER;
BEGIN
  -- Поиск страны
  BEGIN
    SELECT  id
      INTO  v_country_id
      FROM  t_country
      WHERE description = 'Россия';
  EXCEPTION
    WHEN others THEN
      v_info := 'Не найдена страна Россия';
      RAISE e_error;
  END;
  -- Поиск города
  IF UPPER( par_city_name ) = 'МОСКВА' THEN
    v_city_id := 0;
  ELSIF UPPER( par_city_name ) = 'САНКТ-ПЕТЕРБУРГ' THEN
    v_city_id := ( -1 );
  ELSE
    BEGIN
      SELECT  city_id
        INTO  v_city_id
        FROM  t_city
        WHERE UPPER( city_name ) = UPPER( par_city_name )
          AND SUBSTR( kladr_code_hist, -2, 2 ) = '00';
    EXCEPTION
      WHEN no_data_found THEN
        v_info := 'Не найден город ' || par_city_name;
        RAISE e_error;
      WHEN too_many_rows THEN
        v_info := 'Найдено несколько городов ' || par_city_name;
        RAISE e_error;
      WHEN others THEN
        v_info := 'Ошибка при поиске города ' || par_city_name || ' ' ||
          SQLERRM;
        RAISE e_error;
    END;
  END IF;
  -- Поиск банка по БИК-у
  IF par_bic IS NOT NULL THEN
    OPEN bic_curs( par_bic );
    FETCH bic_curs INTO v_contact_id;
    IF bic_curs%NOTFOUND THEN
      v_contact_id := NULL;
    ELSIF NVL( bic_curs%ROWCOUNT, 0 ) > 1 THEN
      v_info := 'В БД найдено несколько банков с БИК ' || par_bic ;
      RAISE e_error;
    END IF;
    CLOSE bic_curs;
    IF v_contact_id IS NOT NULL THEN
      NULL;
    END IF;
  END IF;
  IF v_contact_id IS NOT NULL THEN
    Update_Contact_Bank_With_Info( par_cn_bank_req_file_row_id,
      v_contact_id, par_bank_name, par_bic, par_corracc, v_country_id,
      v_city_id );
  ELSE
    SELECT sq_contact.NEXTVAL INTO v_contact_id FROM dual;
    Insert_Contact_Bank_With_Info( par_cn_bank_req_file_row_id,
      v_contact_id, par_bank_name, par_bic, par_corracc,
      v_country_id, v_city_id, NULL\*par_inn*\, 'Загружено из файла ЦБ' );
  END IF;
EXCEPTION
  WHEN e_error THEN
    UPDATE  cn_bank_req_file_row
      SET   info = v_info,
            status = ( -1 )
      WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
  WHEN others THEN
    v_info := SQLERRM;
    v_info := 'Ошибка: ' || v_info;
    UPDATE  cn_bank_req_file_row
      SET   info = v_info,
            status = ( -1 )
      WHERE cn_bank_req_file_row_id = par_cn_bank_req_file_row_id;
END Load_One_Bank;*/
----========================================================================----
END PKG_CONTACT_BANK;
/
