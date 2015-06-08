CREATE OR REPLACE PACKAGE PKG_CONTACT_INOUTPUT IS

  PROCEDURE INOUTPUT_LOAD_BLOB_TO_TABLE
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  FUNCTION LOAD_TO_DB_INOTPUT(p_load_id NUMBER) RETURN NUMBER;
  PROCEDURE UPDATE_COUNT
  (
    p_contact_id    NUMBER
   ,p_type_props_id NUMBER
   ,p_props_text    VARCHAR2
   ,p_status_id     NUMBER
  );

END PKG_CONTACT_INOUTPUT;
/
CREATE OR REPLACE PACKAGE BODY PKG_CONTACT_INOUTPUT IS

  PROCEDURE INOUTPUT_LOAD_BLOB_TO_TABLE
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values            PKG_LOAD_FILE_TO_TABLE.t_varay;
    v_blob_data          BLOB;
    v_blob_len           NUMBER;
    v_position           NUMBER;
    c_chunk_len          NUMBER := 1;
    v_line               VARCHAR2(32767) := NULL;
    v_line_num           NUMBER := 0;
    v_char               CHAR(1);
    v_raw_chunk          RAW(10000);
    v_inoutput_info_load inoutput_info_load%ROWTYPE;
  BEGIN
    SAVEPOINT Before_Load;
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
          va_values := PKG_LOAD_FILE_TO_TABLE.Str2Array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_inoutput_info_load := NULL;
            SELECT sq_inoutput_info_load.NEXTVAL
              INTO v_inoutput_info_load.inoutput_info_load_id
              FROM dual;
            v_inoutput_info_load.load_id := par_load_file_id;
            -- проход по полям
            FOR i IN va_values.FIRST .. va_values.LAST
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_inoutput_info_load.order_load := va_values(i);
                WHEN i = 2 THEN
                  v_inoutput_info_load.t_message_kind_name := va_values(i);
                WHEN i = 3 THEN
                  v_inoutput_info_load.t_message_type_name := va_values(i);
                WHEN i = 4 THEN
                  v_inoutput_info_load.t_message_state_name := va_values(i);
                WHEN i = 5 THEN
                  v_inoutput_info_load.receiver_contact_fio := va_values(i);
                WHEN i = 6 THEN
                  v_inoutput_info_load.receiver_contact_id := va_values(i);
                WHEN i = 7 THEN
                  v_inoutput_info_load.subj_message := va_values(i);
                WHEN i = 8 THEN
                  v_inoutput_info_load.reg_date := TO_DATE(va_values(i), 'DD.MM.YYYY HH24:MI:SS');
                WHEN i = 9 THEN
                  v_inoutput_info_load.pol_ids := va_values(i);
                WHEN i = 10 THEN
                  v_inoutput_info_load.contract_id := va_values(i);
                WHEN i = 11 THEN
                  v_inoutput_info_load.identity := va_values(i);
                WHEN i = 12 THEN
                  v_inoutput_info_load.t_message_props_name := va_values(i);
                WHEN i = 13 THEN
                  v_inoutput_info_load.props := va_values(i);
                WHEN i = 14 THEN
                  v_inoutput_info_load.reestr_num := va_values(i);
                WHEN i = 15 THEN
                  v_inoutput_info_load.initiator_send := va_values(i);
                WHEN i = 16 THEN
                  v_inoutput_info_load.send_date := TO_DATE(va_values(i), 'DD.MM.YYYY HH24:MI:SS');
                WHEN i = 17 THEN
                  v_inoutput_info_load.index_number := va_values(i);
                WHEN i = 18 THEN
                  v_inoutput_info_load.descript_message := va_values(i);
                WHEN i = 19 THEN
                  v_inoutput_info_load.note := va_values(i);
                ELSE
                  NULL;
              END CASE;
            END LOOP;
            INSERT INTO ins.ven_inoutput_info_load
              (inoutput_info_load_id
              ,load_id
              ,t_message_kind_name
              ,t_message_type_name
              ,t_message_state_name
              ,receiver_contact_fio
              ,receiver_contact_id
              ,subj_message
              ,reg_date
              ,pol_ids
              ,contract_id
              ,identity
              ,t_message_props_name
              ,props
              ,reestr_num
              ,initiator_send
              ,send_date
              ,index_number
              ,descript_message
              ,note
              ,order_load)
            VALUES
              (v_inoutput_info_load.inoutput_info_load_id
              ,v_inoutput_info_load.load_id
              ,v_inoutput_info_load.t_message_kind_name
              ,v_inoutput_info_load.t_message_type_name
              ,v_inoutput_info_load.t_message_state_name
              ,v_inoutput_info_load.receiver_contact_fio
              ,v_inoutput_info_load.receiver_contact_id
              ,v_inoutput_info_load.subj_message
              ,v_inoutput_info_load.reg_date
              ,v_inoutput_info_load.pol_ids
              ,v_inoutput_info_load.contract_id
              ,v_inoutput_info_load.identity
              ,v_inoutput_info_load.t_message_props_name
              ,v_inoutput_info_load.props
              ,v_inoutput_info_load.reestr_num
              ,v_inoutput_info_load.initiator_send
              ,v_inoutput_info_load.send_date
              ,v_inoutput_info_load.index_number
              ,v_inoutput_info_load.descript_message
              ,v_inoutput_info_load.note
              ,v_inoutput_info_load.order_load);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Before_Load;
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении INOUTPUT_LOAD_BLOB_TO_TABLE ' || SQLERRM);
  END INOUTPUT_LOAD_BLOB_TO_TABLE;

  FUNCTION LOAD_TO_DB_INOTPUT(p_load_id NUMBER) RETURN NUMBER IS
    v_result                    NUMBER := 0;
    is_exists_combination_state NUMBER;
    is_exists_combination_props NUMBER;
    is_exists_db                NUMBER;
    is_exists_identity          NUMBER;
    is_exists                   NUMBER;
    v_type_props_id             NUMBER;
    v_state_id                  NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO is_exists
      FROM DUAL
     WHERE EXISTS (SELECT NULL FROM ins.inoutput_info inf WHERE inf.load_id = p_load_id);
  
    IF is_exists > 0
    THEN
      RETURN 1;
    END IF;
  
    FOR cur IN (SELECT ld.inoutput_info_load_id
                      ,ld.t_message_kind_name
                      ,ld.t_message_type_name
                      ,ld.t_message_props_name
                      ,ld.t_message_state_name
                      ,ld.pol_ids
                      ,ld.contract_id
                      ,ld.receiver_contact_id
                      ,ld.identity
                      ,ld.subj_message
                      ,ld.reg_date
                      ,ld.props
                      ,ld.reestr_num
                      ,ld.index_number
                      ,ld.initiator_send
                      ,ld.descript_message
                      ,ld.note
                      ,ld.send_date
                      ,ld.load_id
                      ,ld.order_load
                  FROM ins.inoutput_info_load ld
                 WHERE ld.load_id = p_load_id
                 ORDER BY ld.order_load)
    LOOP
      SELECT COUNT(*)
        INTO is_exists_combination_state
        FROM DUAl
       WHERE EXISTS (SELECT NULL
                FROM ins.t_message_inoutput   tp
                    ,ins.t_message_kind       k
                    ,ins.t_message_type       t
                    ,ins.t_message_type_props pr
                    ,ins.t_message_state      st
               WHERE tp.t_message_kind_id = k.t_message_kind_id
                 AND tp.t_message_type_id = t.t_message_type_id
                 AND tp.t_message_props_id = pr.t_message_type_props_id
                 AND tp.t_message_state_id = st.t_message_state_id
                 AND UPPER(k.message_kind_name) = UPPER(cur.t_message_kind_name)
                 AND UPPER(t.message_type_name) = UPPER(cur.t_message_type_name)
                 AND UPPER(pr.message_props_name) = UPPER(cur.t_message_props_name)
                 AND UPPER(st.message_state_name) = UPPER(cur.t_message_state_name));
    
      /***********************************/
      IF is_exists_combination_state = 0
      THEN
        UPDATE ins.inoutput_info_load ld
           SET ld.state_load = 2
              ,ld.text_info  = 'Ошибка проверки контрольного сочетания атрибутов реквизита'
              ,ld.user_name  = USER
              ,ld.load_date  = SYSDATE
         WHERE ld.inoutput_info_load_id = cur.inoutput_info_load_id;
      ELSE
        SELECT COUNT(*)
          INTO is_exists_db
          FROM DUAL
         WHERE (EXISTS (SELECT NULL FROM p_pol_header ph WHERE ph.ids = cur.pol_ids) OR EXISTS
                (SELECT NULL
                   FROM ag_contract_header ach
                  WHERE ach.ag_contract_header_id = cur.contract_id));
        /***********************************/
        IF is_exists_db = 0
        THEN
          UPDATE ins.inoutput_info_load ld
             SET ld.state_load = 2
                ,ld.text_info  = 'Атрибуты реквизита или объекта не удалось идентифицировать в базе'
                ,ld.user_name  = USER
                ,ld.load_date  = SYSDATE
           WHERE ld.inoutput_info_load_id = cur.inoutput_info_load_id;
        ELSE
          SELECT COUNT(*)
            INTO is_exists_identity
            FROM DUAL
           WHERE EXISTS (SELECT NULL FROM ins.inoutput_info inf WHERE inf.identity = cur.identity);
        
          SELECT pr.t_message_type_props_id
            INTO v_type_props_id
            FROM ins.t_message_type_props pr
           WHERE UPPER(pr.message_props_name) = UPPER(cur.t_message_props_name);
          SELECT st.t_message_state_id
            INTO v_state_id
            FROM ins.t_message_state st
           WHERE UPPER(st.message_state_name) = UPPER(cur.t_message_state_name);
          /****************************************/
          IF is_exists_identity = 0
          THEN
            UPDATE ins.inoutput_info_load ld
               SET ld.state_load = 1
                  ,ld.text_info  = 'Запись добавлена'
                  ,ld.user_name  = USER
                  ,ld.load_date  = SYSDATE
             WHERE ld.inoutput_info_load_id = cur.inoutput_info_load_id;
            INSERT INTO ins.ven_inoutput_info
              (t_message_kind_id
              ,t_message_type_id
              ,receiver_contact_id
              ,subj_message
              ,reg_date
              ,pol_header_id
              ,ag_contract_header_id
              ,identity
              ,t_message_props_id
              ,props
              ,reestr_num
              ,initiator_send
              ,index_number
              ,descript_message
              ,note
              ,t_message_state_id
              ,send_date
              ,state_date
              ,user_name_loaded
              ,user_name_change
              ,load_id)
            VALUES
              ((SELECT k.t_message_kind_id
                 FROM ins.t_message_kind k
                WHERE UPPER(k.message_kind_name) = UPPER(cur.t_message_kind_name))
              ,(SELECT t.t_message_type_id
                 FROM ins.t_message_type t
                WHERE UPPER(t.message_type_name) = UPPER(cur.t_message_type_name))
              ,cur.receiver_contact_id
              ,cur.subj_message
              ,cur.reg_date
              ,(SELECT ph.policy_header_id FROM p_pol_header ph WHERE ph.ids = cur.pol_ids)
              ,cur.contract_id
              ,cur.identity
              ,(SELECT pr.t_message_type_props_id
                 FROM ins.t_message_type_props pr
                WHERE UPPER(pr.message_props_name) = UPPER(cur.t_message_props_name))
              ,cur.props
              ,cur.reestr_num
              ,cur.initiator_send
              ,cur.index_number
              ,cur.descript_message
              ,cur.note
              ,(SELECT st.t_message_state_id
                 FROM ins.t_message_state st
                WHERE UPPER(st.message_state_name) = UPPER(cur.t_message_state_name))
              ,cur.send_date
              ,SYSDATE
              ,USER
              ,USER
              ,cur.load_id);
          
            PKG_CONTACT_INOUTPUT.UPDATE_COUNT(cur.receiver_contact_id
                                             ,v_type_props_id
                                             ,cur.props
                                             ,v_state_id);
          ELSE
            SELECT COUNT(*)
              INTO is_exists_combination_props
              FROM DUAl
             WHERE EXISTS
             (SELECT NULL
                      FROM ins.t_message_inoutput   tp
                          ,ins.t_message_kind       k
                          ,ins.t_message_type       t
                          ,ins.t_message_type_props pr
                          ,ins.t_message_state      st
                     WHERE tp.t_message_kind_id = k.t_message_kind_id
                       AND tp.t_message_type_id = t.t_message_type_id
                       AND tp.t_message_props_id = pr.t_message_type_props_id
                       AND tp.t_message_state_id = st.t_message_state_id
                       AND UPPER(k.message_kind_name) = UPPER(cur.t_message_kind_name)
                       AND UPPER(t.message_type_name) = UPPER(cur.t_message_type_name)
                       AND UPPER(pr.message_props_name) = UPPER(cur.t_message_props_name));
            /*******************************************/
            IF is_exists_combination_props = 0
            THEN
              UPDATE ins.inoutput_info_load ld
                 SET ld.state_load = 2
                    ,ld.text_info  = 'Ошибка перезаписи'
                    ,ld.user_name  = USER
                    ,ld.load_date  = SYSDATE
               WHERE ld.inoutput_info_load_id = cur.inoutput_info_load_id;
            ELSE
              UPDATE ins.inoutput_info_load ld
                 SET ld.state_load = 1
                    ,ld.text_info  = 'Запись добавлена'
                    ,ld.user_name  = USER
                    ,ld.load_date  = SYSDATE
               WHERE ld.inoutput_info_load_id = cur.inoutput_info_load_id;
              UPDATE ins.inoutput_info inf
                 SET inf.state_date         = SYSDATE
                    ,inf.user_name_change   = USER
                    ,inf.t_message_state_id = v_state_id
               WHERE inf.identity = cur.identity;
              PKG_CONTACT_INOUTPUT.UPDATE_COUNT(cur.receiver_contact_id
                                               ,v_type_props_id
                                               ,cur.props
                                               ,v_state_id);
            END IF;
            /****************************************/
          END IF;
          /*******************************************/
        END IF;
        /**********************************/
      END IF;
      /************************************/
    END LOOP;
  
    RETURN v_result;
  
  END LOAD_TO_DB_INOTPUT;

  PROCEDURE UPDATE_COUNT
  (
    p_contact_id    NUMBER
   ,p_type_props_id NUMBER
   ,p_props_text    VARCHAR2
   ,p_status_id     NUMBER
  ) IS
    vp_props_brief VARCHAR2(50);
    --n NUMBER;
  BEGIN
  
    BEGIN
      SELECT pr.message_props_brief
        INTO vp_props_brief
        FROM ins.t_message_type_props pr
       WHERE pr.t_message_type_props_id = p_type_props_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vp_props_brief := 'X';
    END;
  
    CASE vp_props_brief
      WHEN 'ADDRESS' THEN
      
        FOR cur IN (SELECT adr.id
                          ,adr.field_count
                          ,adr.status
                      FROM ins.ven_cn_contact_address adr
                     WHERE adr.contact_id = p_contact_id
                       AND UPPER(REPLACE(pkg_contact.get_address_name(adr.adress_id), '"', '')) =
                           UPPER(REPLACE(p_props_text, '"', '')))
        LOOP
          UPDATE ven_cn_contact_address adrs
             SET adrs.status     =
                 (SELECT con.new_state
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count)
                ,adrs.field_count =
                 (SELECT con.new_value
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count)
           WHERE adrs.id = cur.id
             AND EXISTS (SELECT NULL
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count);
        END LOOP;
      
      WHEN 'TELEPHONE' THEN
      
        FOR cur IN (SELECT t.id
                          ,t.field_count
                          ,t.status
                      FROM ins.ven_cn_contact_telephone t
                     WHERE t.contact_id = p_contact_id
                       AND REPLACE(t.telephone_number, '-', '') = REPLACE(p_props_text, '-', ''))
        LOOP
          UPDATE ven_cn_contact_telephone tel
             SET tel.status     =
                 (SELECT con.new_state
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count)
                ,tel.field_count =
                 (SELECT con.new_value
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count)
           WHERE tel.id = cur.id
             AND EXISTS (SELECT NULL
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count);
          --n := sql%rowcount;
        END LOOP;
      
      WHEN 'EMAIL' THEN
      
        FOR cur IN (SELECT ml.id
                          ,ml.field_count
                          ,ml.status
                      FROM ins.ven_cn_contact_email ml
                     WHERE ml.contact_id = p_contact_id
                       AND UPPER(ml.email) = UPPER(p_props_text))
        LOOP
          UPDATE ven_cn_contact_email em
             SET em.status     =
                 (SELECT con.new_state
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count)
                ,em.field_count =
                 (SELECT con.new_value
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count)
           WHERE em.id = cur.id
             AND EXISTS (SELECT NULL
                    FROM ins.t_check_conformity con
                   WHERE con.t_props_id = p_type_props_id
                     AND con.t_state_id = p_status_id
                     AND con.actual_value = cur.field_count);
        END LOOP;
      
      ELSE
        NULL;
      
    END CASE;
  
  END UPDATE_COUNT;

END PKG_CONTACT_INOUTPUT;
/
