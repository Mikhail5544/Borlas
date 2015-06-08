CREATE OR REPLACE PACKAGE pkg_contact_finmon IS

  FUNCTION fon_fromlattocyr(p_char_lat VARCHAR2) RETURN VARCHAR2;
  FUNCTION fon_fromcyrtofon(p_char_cyr VARCHAR2) RETURN VARCHAR2;
  FUNCTION get_identify
  (
    p_contact_id    NUMBER
   ,p_ident_type    VARCHAR2
   ,p_part_passport NUMBER DEFAULT 0
   ,p_get_id        NUMBER DEFAULT 0
  ) RETURN VARCHAR2;
  PROCEDURE insert_update_contact_doc(p_contact_id NUMBER);
  PROCEDURE set_risk_level
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_obj_name_orig contact.obj_name_orig%TYPE
   ,par_risk_level    IN OUT t_risk_level.t_risk_level_id%TYPE
   ,par_pass_num      cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ser_num       cn_contact_ident.serial_nr%TYPE DEFAULT NULL
   ,par_okpo_num      cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ogrn_num      cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_inn_num       cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_table_ident   NUMBER DEFAULT 0
  );
  PROCEDURE set_risk_level
  (
    par_contact_id contact.contact_id%TYPE
   ,par_pass_num   cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ser_num    cn_contact_ident.serial_nr%TYPE DEFAULT NULL
   ,par_okpo_num   cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ogrn_num   cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_inn_num    cn_contact_ident.id_value%TYPE DEFAULT NULL
  );
  FUNCTION get_current_doc
  (
    p_contact_id    NUMBER
   ,p_ident_type    VARCHAR2
   ,p_part_passport NUMBER DEFAULT 0
  ) RETURN VARCHAR2;
  FUNCTION comparison_terror RETURN NUMBER;
  PROCEDURE check_pol_header(par_policy_id NUMBER);
  PROCEDURE load_list_terror(par_load_file_id NUMBER);

  /*
    Пиядин А. 301732 ТЗ Финмониторинг
  */
  PROCEDURE check_ag_contract(par_ag_contract_id ag_contract.ag_contract_id%TYPE);

END pkg_contact_finmon;
/
CREATE OR REPLACE PACKAGE BODY pkg_contact_finmon IS

  FUNCTION fon_fromlattocyr(p_char_lat VARCHAR2) RETURN VARCHAR2 IS
    p_result  VARCHAR2(2000);
    proc_name VARCHAR2(25) := 'FON_FROMLATTOCYR';
  BEGIN
  
    SELECT regexp_replace(
                          
                          translate(
                                    
                                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(upper(p_char_lat)
                                                                                           ,'ZH'
                                                                                           ,'Ж')
                                                                                   ,'SHCH'
                                                                                   ,'Щ')
                                                                           ,'CH'
                                                                           ,'Ч')
                                                                   ,'TS'
                                                                   ,'Ц')
                                                           ,'SH'
                                                           ,'Ш')
                                                   ,'YU'
                                                   ,'Ю')
                                           ,'YA'
                                           ,'Я')
                                   ,
                                    
                                    'AEIOUYBCDFGHJKLMNPQRSTVWXZ'
                                   ,'АИИАУЙПХТФХХШХЛМНПХРСТФФХС')
                         ,
                          
                          '[^A-Za-zА-Яа-я0-9]'
                          
                          )
    
      INTO p_result
      FROM dual;
  
    RETURN p_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  FUNCTION fon_fromcyrtofon(p_char_cyr VARCHAR2) RETURN VARCHAR2 IS
    p_result  VARCHAR2(2000);
    proc_name VARCHAR2(25) := 'FON_FROMCYRTOFON';
  BEGIN
  
    SELECT regexp_replace(translate(REPLACE(REPLACE(REPLACE(upper(p_char_cyr), 'Й', ''), 'Ъ', '')
                                           ,'Ь'
                                           ,'')
                                   ,
                                    
                                    'АБВГДЕЁЖЗИКЛМНОПРСТУФХЦЧШЩЫЭЮЯ'
                                   ,'АПФХТИИЖСИКЛМНАПРСТАФХЦЧШЩАИАА')
                         ,'(.)\1+'
                         ,'\1')
      INTO p_result
      FROM dual;
  
    RETURN p_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  FUNCTION get_identify
  (
    p_contact_id    NUMBER
   ,p_ident_type    VARCHAR2
   ,p_part_passport NUMBER DEFAULT 0
   ,p_get_id        NUMBER DEFAULT 0
  ) RETURN VARCHAR2 IS
    p_result   VARCHAR2(100);
    proc_name  VARCHAR2(25) := 'GET_IDENTIFY';
    p_max_date DATE;
  BEGIN
  
    SELECT MAX(ident.issue_date)
      INTO p_max_date
      FROM cn_contact_ident ident
          ,t_id_type        idtype
     WHERE ident.id_type = idtype.id
       AND idtype.description = p_ident_type
       AND ident.contact_id = p_contact_id;
  
    IF p_max_date IS NOT NULL
    THEN
      BEGIN
        SELECT CASE
                 WHEN p_get_id = 1 THEN
                  to_char(ii.table_id)
                 ELSE
                  decode(p_part_passport, 1, ii.serial_nr, ii.id_value)
               END
          INTO p_result
          FROM cn_contact_ident ii
              ,t_id_type        iit
         WHERE ii.contact_id = p_contact_id
           AND ii.id_type = iit.id
           AND iit.description = p_ident_type
           AND ii.issue_date =
               (SELECT MAX(ident.issue_date)
                  FROM cn_contact_ident ident
                      ,t_id_type        idtype
                 WHERE ident.id_type = idtype.id
                   AND idtype.description = p_ident_type
                   AND ident.contact_id = p_contact_id
                   AND (ident.is_default = 1 OR nvl(ident.is_default, 0) = 0))
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          p_result := '';
      END;
    ELSE
      BEGIN
        SELECT CASE
                 WHEN p_get_id = 1 THEN
                  to_char(ii.table_id)
                 ELSE
                  decode(p_part_passport, 1, ii.serial_nr, ii.id_value)
               END
          INTO p_result
          FROM cn_contact_ident ii
              ,t_id_type        iit
         WHERE ii.contact_id = p_contact_id
           AND ii.id_type = iit.id
           AND iit.description = p_ident_type
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          p_result := '';
      END;
    END IF;
  
    RETURN p_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' на контакте ' ||
                              to_char(p_contact_id) || ' ' || SQLERRM);
  END;

  PROCEDURE insert_update_contact_doc(p_contact_id NUMBER) IS
    proc_name          VARCHAR2(30) := 'INSERT_UPDATE_CONTACT_DOC';
    p_exists_contact   NUMBER;
    p_upd_field_number VARCHAR2(25);
    p_row_id           NUMBER;
    p_par_tu           NUMBER;
    p_contact_found    NUMBER := 0;
  BEGIN
  
    SELECT COUNT(*)
      INTO p_exists_contact
      FROM t_contact_doc_fon tcdf
     WHERE tcdf.contact_id = p_contact_id;
  
    IF p_exists_contact = 0
    THEN
      INSERT INTO ins.ven_t_contact_doc_fon
        (contact_id, fon_name, okpo, ogrn, pass_series, pass_num, nd, risk_level)
        SELECT cn.contact_id
              ,ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(cn.obj_name_orig))
              ,ins.pkg_contact_finmon.get_current_doc(cn.contact_id, 'ОКПО') okpo
              ,ins.pkg_contact_finmon.get_current_doc(cn.contact_id, 'ОГРН') ogrn
              ,ins.pkg_contact_finmon.get_current_doc(cn.contact_id
                                                     ,'Паспорт гражданина РФ'
                                                     ,1) pass_series
              ,ins.pkg_contact_finmon.get_current_doc(cn.contact_id
                                                     ,'Паспорт гражданина РФ') pass_num
              ,ins.pkg_contact_finmon.get_current_doc(cn.contact_id, 'ИНН') nd
              ,cn.risk_level
          FROM contact cn
         WHERE cn.contact_id = p_contact_id;
    ELSE
      UPDATE ins.ven_t_contact_doc_fon tcdf
         SET tcdf.fon_name    = ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr((SELECT c.obj_name_orig
                                                                                                                  FROM contact c
                                                                                                                 WHERE c.contact_id =
                                                                                                                       p_contact_id)))
            ,tcdf.okpo        = ins.pkg_contact_finmon.get_current_doc(p_contact_id, 'ОКПО')
            ,tcdf.ogrn        = ins.pkg_contact_finmon.get_current_doc(p_contact_id, 'ОГРН')
            ,tcdf.pass_series = ins.pkg_contact_finmon.get_current_doc(p_contact_id
                                                                      ,'Паспорт гражданина РФ'
                                                                      ,1)
            ,tcdf.pass_num    = ins.pkg_contact_finmon.get_current_doc(p_contact_id
                                                                      ,'Паспорт гражданина РФ')
            ,tcdf.nd          = ins.pkg_contact_finmon.get_current_doc(p_contact_id, 'ИНН')
            ,tcdf.risk_level =
             (SELECT c.risk_level FROM contact c WHERE c.contact_id = p_contact_id)
       WHERE tcdf.contact_id = p_contact_id;
    END IF;
  
    FOR cur IN (SELECT tcdf.contact_id
                  FROM ins.ven_t_contact_doc_fon tcdf
                 WHERE tcdf.contact_id = p_contact_id
                /*Заявка №286264*/
                /*AND (tcdf.risk_level =
                (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Terror') OR
                tcdf.risk_level =
                (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Swindler') OR
                                       NVL(tcdf.row_id, 0) = 0
                )*/
                )
    LOOP
    
      p_contact_found := 0;
      FOR cur_terr IN (SELECT ter.field_number
                             ,ter.row_id
                             ,ter.tu
                             ,tcdf.row_id tcdf_row_id
                         FROM ins.t_contact_doc_fon tcdf
                             ,ins.fms_terror        ter
                        WHERE (tcdf.fon_name = ter.fon_name OR tcdf.okpo = ter.okpo OR
                              tcdf.ogrn = ter.ogrn OR
                              (REPLACE(tcdf.pass_series, ' ') = REPLACE(ter.pass_series, ' ') AND
                              tcdf.pass_num = ter.pass_num) OR tcdf.nd = ter.inn)
                          AND tcdf.contact_id = cur.contact_id)
      LOOP
        p_contact_found := 1;
        IF cur_terr.tcdf_row_id != cur_terr.row_id
        THEN
          IF cur_terr.tu != -1
          THEN
            UPDATE ins.ven_t_contact_doc_fon tcdf
               SET tcdf.risk_level  =
                   (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Terror')
                  ,tcdf.field_number = cur_terr.field_number
                  ,tcdf.row_id       = cur_terr.row_id
             WHERE tcdf.contact_id = cur.contact_id;
            UPDATE contact c
               SET c.risk_level =
                   (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Terror')
             WHERE c.contact_id = cur.contact_id;
          ELSE
            UPDATE ins.ven_t_contact_doc_fon tcdf
               SET tcdf.risk_level  =
                   (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Swindler')
                  ,tcdf.field_number = cur_terr.field_number
                  ,tcdf.row_id       = cur_terr.row_id
             WHERE tcdf.contact_id = cur.contact_id;
            UPDATE contact c
               SET c.risk_level =
                   (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Swindler')
             WHERE c.contact_id = cur.contact_id;
          END IF;
        END IF;
      END LOOP;
      IF p_contact_found = 0
      THEN
        UPDATE ins.ven_t_contact_doc_fon tcdf
           SET tcdf.risk_level =
               (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Middle')
         WHERE tcdf.contact_id = cur.contact_id
           AND (tcdf.risk_level =
               (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Terror') OR
               tcdf.risk_level =
               (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Swindler'));
        UPDATE contact c
           SET c.risk_level =
               (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Middle')
         WHERE c.contact_id = cur.contact_id
           AND (c.risk_level =
               (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Terror') OR
               c.risk_level =
               (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.brief = 'Swindler'));
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' на контакте ' ||
                              to_char(p_contact_id) || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' на контакте ' ||
                              to_char(p_contact_id) || ' ' || SQLERRM);
  END;

  PROCEDURE set_risk_level
  (
    par_contact_id    contact.contact_id%TYPE
   ,par_obj_name_orig contact.obj_name_orig%TYPE
   ,par_risk_level    IN OUT t_risk_level.t_risk_level_id%TYPE
   ,par_pass_num      cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ser_num       cn_contact_ident.serial_nr%TYPE DEFAULT NULL
   ,par_okpo_num      cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ogrn_num      cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_inn_num       cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_table_ident   NUMBER DEFAULT 0
  ) IS
    proc_name             VARCHAR2(30) := 'SET_RISK_LEVEL';
    v_exists_contact      NUMBER(1);
    v_upd_field_number    VARCHAR2(25);
    v_row_id              NUMBER;
    v_par_tu              NUMBER;
    v_contact_found       BOOLEAN := FALSE;
    v_terror_risk_level   t_risk_level.t_risk_level_id%TYPE;
    v_swindler_risk_level t_risk_level.t_risk_level_id%TYPE;
    v_middle_risk_level   t_risk_level.t_risk_level_id%TYPE;
    v_exists_terror       NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO v_exists_contact
      FROM t_contact_doc_fon tcdf
     WHERE tcdf.contact_id = par_contact_id;
  
    BEGIN
      SELECT r.t_risk_level_id
        INTO v_terror_risk_level
        FROM ins.t_risk_level r
       WHERE r.brief = 'Terror';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден уровень риска с кратким названием "Terror"');
    END;
  
    BEGIN
      SELECT r.t_risk_level_id
        INTO v_swindler_risk_level
        FROM ins.t_risk_level r
       WHERE r.brief = 'Swindler';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден уровень риска с кратким названием "Swindler"');
    END;
  
    BEGIN
      SELECT r.t_risk_level_id
        INTO v_middle_risk_level
        FROM ins.t_risk_level r
       WHERE r.brief = 'Middle';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден уровень риска с кратким названием "Middle"');
    END;
  
    IF v_exists_contact = 0
    THEN
      IF par_table_ident = 1
      THEN
        INSERT INTO ins.ven_t_contact_doc_fon
          (contact_id, fon_name, okpo, ogrn, pass_series, pass_num, nd, risk_level)
        VALUES
          (par_contact_id
          ,ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(par_obj_name_orig))
          ,par_okpo_num
          ,par_ogrn_num
          ,par_ser_num
          ,par_pass_num
          ,par_inn_num
          ,par_risk_level);
      ELSE
        INSERT INTO ins.ven_t_contact_doc_fon
          (contact_id, fon_name, okpo, ogrn, pass_series, pass_num, nd, risk_level)
        VALUES
          (par_contact_id
          ,ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(par_obj_name_orig))
          ,ins.pkg_contact_finmon.get_current_doc(par_contact_id, 'ОКПО')
          ,ins.pkg_contact_finmon.get_current_doc(par_contact_id, 'ОГРН')
          ,ins.pkg_contact_finmon.get_current_doc(par_contact_id
                                                 ,'Паспорт гражданина РФ'
                                                 ,1)
          ,ins.pkg_contact_finmon.get_current_doc(par_contact_id
                                                 ,'Паспорт гражданина РФ')
          ,ins.pkg_contact_finmon.get_current_doc(par_contact_id, 'ИНН')
          ,par_risk_level);
      END IF;
    ELSE
      IF par_table_ident = 1
      THEN
        UPDATE ins.ven_t_contact_doc_fon tcdf
           SET tcdf.fon_name    = ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(par_obj_name_orig))
              ,tcdf.okpo        = par_okpo_num
              ,tcdf.ogrn        = par_ogrn_num
              ,tcdf.pass_series = par_ser_num
              ,tcdf.pass_num    = par_pass_num
              ,tcdf.nd          = par_inn_num
              ,tcdf.risk_level  = par_risk_level
         WHERE tcdf.contact_id = par_contact_id;
      ELSE
        UPDATE ins.ven_t_contact_doc_fon tcdf
           SET tcdf.fon_name    = ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(par_obj_name_orig))
              ,tcdf.okpo        = ins.pkg_contact_finmon.get_current_doc(par_contact_id, 'ОКПО')
              ,tcdf.ogrn        = ins.pkg_contact_finmon.get_current_doc(par_contact_id, 'ОГРН')
              ,tcdf.pass_series = ins.pkg_contact_finmon.get_current_doc(par_contact_id
                                                                        ,'Паспорт гражданина РФ'
                                                                        ,1)
              ,tcdf.pass_num    = ins.pkg_contact_finmon.get_current_doc(par_contact_id
                                                                        ,'Паспорт гражданина РФ')
              ,tcdf.nd          = ins.pkg_contact_finmon.get_current_doc(par_contact_id, 'ИНН')
              ,tcdf.risk_level  = par_risk_level
         WHERE tcdf.contact_id = par_contact_id;
      END IF;
    END IF;
  
    FOR cur_terr IN (SELECT ter.field_number
                           ,ter.row_id
                           ,ter.tu
                     /*Заявка №270523 - поле изжило себя*/
                     /*,tcdf.row_id tcdf_row_id*/
                       FROM ins.t_contact_doc_fon tcdf
                           ,ins.fms_terror        ter
                      WHERE (tcdf.fon_name = ter.fon_name OR tcdf.okpo = ter.okpo OR
                            tcdf.ogrn = ter.ogrn OR
                            (REPLACE(tcdf.pass_series, ' ') = REPLACE(ter.pass_series, ' ') AND
                            tcdf.pass_num = ter.pass_num) OR tcdf.nd = ter.inn)
                        AND tcdf.contact_id = par_contact_id
                        AND NOT EXISTS (SELECT NULL
                               FROM ins.t_contact_to_terror tr
                              WHERE tr.row_id = ter.row_id
                                AND tr.contact_id = tcdf.contact_id))
    LOOP
      v_contact_found := TRUE;
      INSERT INTO ins.ven_t_contact_to_terror
        (t_contact_to_terror_id, contact_id, row_id)
      VALUES
        (sq_t_contact_to_terror.nextval, par_contact_id, cur_terr.row_id);
      /*IF cur_terr.tcdf_row_id != cur_terr.row_id
         OR cur_terr.tcdf_row_id IS NULL
      THEN*/
      IF cur_terr.tu != -1
      THEN
        UPDATE ins.ven_t_contact_doc_fon tcdf
           SET tcdf.risk_level = v_terror_risk_level
        /*,tcdf.field_number = cur_terr.field_number
        ,tcdf.row_id       = cur_terr.row_id*/
         WHERE tcdf.contact_id = par_contact_id;
      
        par_risk_level := v_terror_risk_level;
      
      ELSE
        UPDATE ins.ven_t_contact_doc_fon tcdf
           SET tcdf.risk_level = v_swindler_risk_level
        /*,tcdf.field_number = cur_terr.field_number
        ,tcdf.row_id       = cur_terr.row_id*/
         WHERE tcdf.contact_id = par_contact_id;
      
        par_risk_level := v_swindler_risk_level;
      
      END IF;
      /*END IF;*/
    END LOOP;
    IF v_contact_found = FALSE
    THEN
      SELECT COUNT(1)
        INTO v_exists_terror
        FROM dual
       WHERE EXISTS (SELECT NULL FROM ins.t_contact_to_terror tr WHERE tr.contact_id = par_contact_id);
      UPDATE ins.ven_t_contact_doc_fon tcdf
         SET tcdf.risk_level = v_middle_risk_level
       WHERE tcdf.contact_id = par_contact_id
         AND (tcdf.risk_level = v_terror_risk_level OR tcdf.risk_level = v_swindler_risk_level)
         AND v_exists_terror = 0;
    
      IF par_risk_level IN (v_terror_risk_level, v_swindler_risk_level)
         AND v_exists_terror = 0
      THEN
        par_risk_level := v_middle_risk_level;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' на контакте ' ||
                              to_char(par_contact_id) || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' на контакте ' ||
                              to_char(par_contact_id) || ' ' || SQLERRM);
  END;

  PROCEDURE set_risk_level
  (
    par_contact_id contact.contact_id%TYPE
   ,par_pass_num   cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ser_num    cn_contact_ident.serial_nr%TYPE DEFAULT NULL
   ,par_okpo_num   cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_ogrn_num   cn_contact_ident.id_value%TYPE DEFAULT NULL
   ,par_inn_num    cn_contact_ident.id_value%TYPE DEFAULT NULL
  ) IS
    v_risk_level_id contact.risk_level%TYPE;
    v_obj_name_orig contact.obj_name_orig%TYPE;
  BEGIN
    BEGIN
      SELECT c.risk_level
            ,c.obj_name_orig
        INTO v_risk_level_id
            ,v_obj_name_orig
        FROM ins.contact c
       WHERE c.contact_id = par_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20003
                               ,'Данные не найдены при выполнении запроса процедуры set_risk_level: ' ||
                                SQLERRM);
    END;
  
    ins.pkg_contact_finmon.set_risk_level(par_contact_id
                                         ,v_obj_name_orig
                                         ,v_risk_level_id
                                         ,par_pass_num
                                         ,par_ser_num
                                         ,par_okpo_num
                                         ,par_ogrn_num
                                         ,par_inn_num
                                         ,1);
  
    UPDATE ins.contact c SET c.risk_level = v_risk_level_id WHERE c.contact_id = par_contact_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении set_risk_level: ' || SQLERRM);
  END;

  FUNCTION get_current_doc
  (
    p_contact_id    NUMBER
   ,p_ident_type    VARCHAR2
   ,p_part_passport NUMBER DEFAULT 0
  ) RETURN VARCHAR2 IS
    p_result  VARCHAR2(100);
    proc_name VARCHAR2(25) := 'GET_CURRENT_DOC';
  BEGIN
  
    BEGIN
      SELECT decode(p_part_passport, 1, ii.serial_nr, ii.id_value)
        INTO p_result
        FROM cn_contact_ident ii
            ,t_id_type        iit
       WHERE ii.contact_id = p_contact_id
         AND ii.id_type = iit.id
         AND iit.description = p_ident_type
      MINUS
      SELECT decode(p_part_passport, 1, ii.serial_nr, ii.id_value)
        FROM cn_contact_ident ii
            ,t_id_type        iit
       WHERE ii.contact_id = p_contact_id
         AND ii.id_type = iit.id
         AND iit.description = p_ident_type
         AND nvl(ii.is_used, 0) = 0;
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          SELECT decode(p_part_passport, 1, ii.serial_nr, ii.id_value)
            INTO p_result
            FROM cn_contact_ident ii
                ,t_id_type        iit
           WHERE ii.contact_id = p_contact_id
             AND ii.id_type = iit.id
             AND iit.description = p_ident_type
             AND rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            p_result := '';
        END;
      WHEN OTHERS THEN
        p_result := '';
    END;
  
    RETURN p_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' на контакте ' ||
                              to_char(p_contact_id) || ' ' || SQLERRM);
  END;

  FUNCTION comparison_terror RETURN NUMBER IS
    proc_name             VARCHAR2(25) := 'COMPARISON_TERROR';
    p_row_id              NUMBER;
    v_terror_risk_level   t_risk_level.t_risk_level_id%TYPE;
    v_swindler_risk_level t_risk_level.t_risk_level_id%TYPE;
    v_middle_risk_level   t_risk_level.t_risk_level_id%TYPE;
    
  BEGIN
  
    BEGIN
      SELECT r.t_risk_level_id
        INTO v_terror_risk_level
        FROM ins.t_risk_level r
       WHERE r.brief = 'Terror';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден уровень риска с кратким названием "Terror"');
    END;
  
    BEGIN
      SELECT r.t_risk_level_id
        INTO v_swindler_risk_level
        FROM ins.t_risk_level r
       WHERE r.brief = 'Swindler';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден уровень риска с кратким названием "Swindler"');
    END;
  
    BEGIN
      SELECT r.t_risk_level_id
        INTO v_middle_risk_level
        FROM ins.t_risk_level r
       WHERE r.brief = 'Middle';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден уровень риска с кратким названием "Middle"');
    END;
  
    FOR cur IN (SELECT tp.field_number
                      ,tp.terror
                      ,tp.tu
                      ,tp.nameu
                      ,tp.descript
                      ,tp.kodcr
                      ,tp.kodcn
                      ,tp.amr
                      ,tp.adress
                      ,tp.kd
                      ,tp.sd
                      ,tp.rg
                      ,tp.nd
                      ,tp.vd
                      ,tp.gr
                      ,tp.yr
                      ,tp.mr
                      ,tp.cb_date
                      ,tp.ce_date
                      ,tp.director
                      ,tp.founder
                      ,tp.row_id
                      ,tp.terrtype
                  FROM etl.fms_terror_tmp tp
                 WHERE tp.tu != 0)
    LOOP
    
      IF cur.ce_date IS NOT NULL
      THEN
        /*********************/
      
        UPDATE contact c
           SET c.risk_level = v_middle_risk_level
         WHERE c.contact_id IN
               (SELECT tr.contact_id FROM ins.t_contact_to_terror tr WHERE tr.row_id = cur.row_id)
           AND NOT EXISTS (SELECT NULL
                  FROM ins.t_contact_to_terror tra
                 WHERE tra.row_id != cur.row_id
                   AND tra.contact_id = c.contact_id);
      
        UPDATE t_contact_doc_fon tcdf
           SET tcdf.risk_level = v_middle_risk_level
        /*,tcdf.field_number = NULL
        ,tcdf.row_id       = NULL*/
         WHERE tcdf.contact_id IN
               (SELECT tr.contact_id FROM ins.t_contact_to_terror tr WHERE tr.row_id = cur.row_id)
           AND NOT EXISTS (SELECT NULL
                  FROM ins.t_contact_to_terror tra
                 WHERE tra.row_id != cur.row_id
                   AND tra.contact_id = tcdf.contact_id);
        DELETE FROM ins.fms_terror tr WHERE tr.row_id = cur.row_id;
        DELETE FROM ins.t_contact_to_terror t WHERE t.row_id = cur.row_id;
        /**********************/
      ELSE
        /**********************/
        BEGIN
          SELECT tr.row_id INTO p_row_id FROM ins.fms_terror tr WHERE tr.row_id = cur.row_id;
        EXCEPTION
          WHEN no_data_found THEN
            INSERT INTO ins.fms_terror
              (field_number
              ,terror
              ,tu
              ,descript
              ,kodcr
              ,kodcn
              ,amr
              ,adress
              ,kd
              ,okpo
              ,pass_series
              ,ogrn
              ,pass_num
              ,inn
              ,vd
              ,gr
              ,yr
              ,mr
              ,cb_date
              ,director
              ,founder
              ,row_id
              ,terrtype
              ,fon_name
              ,nameu
              ,status
              ,reg_date)
              SELECT tp.field_number
                    ,tp.terror
                    ,tp.tu
                    ,tp.descript
                    ,tp.kodcr
                    ,tp.kodcn
                    ,tp.amr
                    ,tp.adress
                    ,tp.kd
                    ,CASE
                       WHEN (tp.tu != 3 AND tp.tu != -1) THEN
                        tp.sd
                       ELSE
                        NULL
                     END
                    ,CASE
                       WHEN (tp.tu = 3 OR tp.tu = -1) THEN
                        REPLACE(tp.sd, ' ')
                       ELSE
                        NULL
                     END
                    ,CASE
                       WHEN (tp.tu != 3 AND tp.tu != -1) THEN
                        tp.rg
                       ELSE
                        NULL
                     END
                    ,CASE
                       WHEN (tp.tu = 3 OR tp.tu = -1) THEN
                        tp.rg
                       ELSE
                        NULL
                     END
                    ,tp.nd
                    ,tp.vd
                    ,tp.gr
                    ,tp.yr
                    ,tp.mr
                    ,tp.cb_date
                    ,tp.director
                    ,tp.founder
                    ,tp.row_id
                    ,tp.terrtype
                    ,ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(tp.nameu))
                    ,tp.nameu
                    ,1
                    ,SYSDATE
                FROM etl.fms_terror_tmp tp
               WHERE tp.row_id = cur.row_id;
          
        END;
        /**********************/
        IF p_row_id != 0
        THEN
        
          UPDATE ins.fms_terror ter
             SET ter.status   = 2
                ,ter.reg_date = SYSDATE
           WHERE ter.row_id =
                 (SELECT tmp_ter.row_id
                    FROM etl.fms_terror_tmp tmp_ter
                        ,ins.fms_terror     ter
                   WHERE tmp_ter.row_id = ter.row_id
                     AND tmp_ter.row_id = cur.row_id
                     AND tmp_ter.field_number = ter.field_number
                     AND nvl(tmp_ter.terror, 'X') = nvl(ter.terror, 'X')
                     AND tmp_ter.tu = ter.tu
                     AND nvl(tmp_ter.descript, 'X') = nvl(ter.descript, 'X')
                     AND nvl(tmp_ter.kodcr, 'X') = nvl(ter.kodcr, 'X')
                     AND nvl(tmp_ter.kodcn, 'X') = nvl(ter.kodcn, 'X')
                     AND nvl(tmp_ter.amr, 'X') = nvl(ter.amr, 'X')
                     AND nvl(tmp_ter.adress, 'X') = nvl(ter.adress, 'X')
                     AND nvl(tmp_ter.kd, 'X') = nvl(ter.kd, 'X')
                     AND nvl(tmp_ter.sd, 'X') = (CASE
                           WHEN (ter.tu != 3 AND ter.tu != -1) THEN
                            nvl(ter.okpo, 'X')
                           ELSE
                            nvl(ter.pass_series, 'X')
                         END)
                     AND nvl(tmp_ter.rg, 'X') = (CASE
                           WHEN (ter.tu != 3 AND ter.tu != -1) THEN
                            nvl(ter.ogrn, 'X')
                           ELSE
                            nvl(ter.pass_num, 'X')
                         END)
                     AND nvl(tmp_ter.nd, 'X') = nvl(ter.inn, 'X')
                     AND nvl(tmp_ter.vd, 'X') = nvl(ter.vd, 'X')
                     AND nvl(tmp_ter.gr, '01.01.1900') = nvl(ter.gr, '01.01.1900')
                     AND nvl(tmp_ter.yr, 'X') = nvl(ter.yr, 'X')
                     AND nvl(tmp_ter.mr, 'X') = nvl(ter.mr, 'X')
                     AND nvl(tmp_ter.cb_date, '01.01.1900') = nvl(ter.cb_date, '01.01.1900')
                     AND nvl(tmp_ter.director, 'X') = nvl(ter.director, 'X')
                     AND nvl(tmp_ter.founder, 'X') = nvl(ter.founder, 'X')
                     AND nvl(tmp_ter.terrtype, 'X') = nvl(ter.terrtype, 'X')
                     AND nvl(tmp_ter.nameu, 'X') = nvl(ter.nameu, 'X'));
          IF SQL%NOTFOUND
          THEN
            UPDATE ins.fms_terror
               SET field_number = cur.field_number
                  ,terror       = cur.terror
                  ,tu           = cur.tu
                  ,descript     = cur.descript
                  ,kodcr        = cur.kodcr
                  ,kodcn        = cur.kodcn
                  ,amr          = cur.amr
                  ,adress       = cur.adress
                  ,kd           = cur.kd
                  ,okpo = (CASE
                            WHEN (tu != 3 AND tu != -1) THEN
                             cur.sd
                            ELSE
                             NULL
                          END)
                  ,pass_series = (CASE
                                   WHEN (tu = 3 OR tu = -1) THEN
                                    REPLACE(cur.sd, ' ')
                                   ELSE
                                    NULL
                                 END)
                  ,ogrn = (CASE
                            WHEN (tu != 3 AND tu != -1) THEN
                             cur.rg
                            ELSE
                             NULL
                          END)
                  ,pass_num = (CASE
                                WHEN (tu = 3 OR tu = -1) THEN
                                 cur.rg
                                ELSE
                                 NULL
                              END)
                  ,inn          = cur.nd
                  ,vd           = cur.vd
                  ,gr           = cur.gr
                  ,yr           = cur.yr
                  ,mr           = cur.mr
                  ,cb_date      = cur.cb_date
                  ,director     = cur.director
                  ,founder      = cur.founder
                  ,terrtype     = cur.terrtype
                  ,fon_name     = ins.pkg_contact_finmon.fon_fromcyrtofon(ins.pkg_contact_finmon.fon_fromlattocyr(cur.nameu))
                  ,nameu        = cur.nameu
                  ,status       = 1
                  ,row_id       = cur.row_id
                  ,reg_date     = SYSDATE
             WHERE row_id = cur.row_id;
          END IF;
        END IF;
        /************************/
      END IF;
    
    END LOOP;
  
    /*EXECUTE IMMEDIATE 'TRUNCATE TABLE etl.fms_terror_tmp';*/
    etl.do_truncate;
  
    FOR upd IN (SELECT tcdf.contact_id
                      ,ter.field_number
                      ,ter.row_id
                      ,ter.tu
                  FROM ins.t_contact_doc_fon tcdf
                      ,ins.fms_terror        ter
                 WHERE (tcdf.fon_name = ter.fon_name OR tcdf.okpo = ter.okpo OR tcdf.ogrn = ter.ogrn OR
                       (tcdf.pass_series = ter.pass_series AND tcdf.pass_num = ter.pass_num) OR
                       tcdf.nd = ter.inn)
                   AND ter.status = 1)
    LOOP
      INSERT INTO ins.ven_t_contact_to_terror
        (t_contact_to_terror_id, contact_id, row_id)
        SELECT sq_t_contact_to_terror.nextval
              ,upd.contact_id
              ,upd.row_id
          FROM dual
         WHERE NOT EXISTS (SELECT NULL FROM ins.t_contact_to_terror ttc WHERE ttc.row_id = upd.row_id);
      IF upd.tu != -1
      THEN
        UPDATE ins.t_contact_doc_fon tcdf
           SET tcdf.risk_level = v_terror_risk_level
        /*,tcdf.field_number = upd.field_number
        ,tcdf.row_id       = upd.row_id*/
         WHERE tcdf.contact_id = upd.contact_id;
        UPDATE ins.contact c
           SET c.risk_level = v_terror_risk_level
         WHERE c.contact_id = upd.contact_id;
      ELSE
        UPDATE ins.t_contact_doc_fon tcdf
           SET tcdf.risk_level = v_swindler_risk_level
        /*,tcdf.field_number = upd.field_number
        ,tcdf.row_id       = upd.row_id*/
         WHERE tcdf.contact_id = upd.contact_id;
        UPDATE ins.contact c
           SET c.risk_level = v_swindler_risk_level
         WHERE c.contact_id = upd.contact_id;
      END IF;
    END LOOP;
  
    RETURN 1;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  PROCEDURE check_pol_header(par_policy_id NUMBER) IS
    proc_name VARCHAR2(25) := 'CHECK_POL_HEADER';
    no_check EXCEPTION;
    p_holder      VARCHAR2(254);
    p_buf         VARCHAR2(2000) := '';
    p_buf2        VARCHAR2(32767) := '';
    c_pol_contact NUMBER;
    cnt           NUMBER := 0;
    cnt2          NUMBER := 1;
    v_ids         p_pol_header.ids%TYPE;
  BEGIN
    BEGIN
      SELECT ph.ids
        INTO v_ids
        FROM p_policy     pp
            ,p_pol_header ph
        WHERE 1 = 1
          AND pp.pol_header_id = ph.policy_header_id
          AND pp.policy_id     = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_ids := NULL;
    END;
  
    BEGIN
      SELECT cpol.obj_name_orig
            ,cpol.contact_id
        INTO p_holder
            ,c_pol_contact
        FROM p_policy           pol
            ,p_policy_contact   ppc
            ,t_contact_pol_role polr
            ,contact            cpol
       WHERE pol.policy_id = par_policy_id
         AND polr.brief = 'Страхователь'
         AND ppc.policy_id = pol.policy_id
         AND ppc.contact_policy_role_id = polr.id
         AND cpol.contact_id = ppc.contact_id
         AND cpol.risk_level IN
             (SELECT r.t_risk_level_id
                FROM ins.t_risk_level r
               WHERE r.brief IN ('Terror', 'Unprofitable', 'Swindler'));
    EXCEPTION
      WHEN no_data_found THEN
        p_holder      := '';
        c_pol_contact := 0;
    END;
  
    IF c_pol_contact <> 0
    THEN
      p_buf := p_holder;
      cnt   := cnt + 1;
    END IF;
  
    FOR cur_isurer IN (SELECT cpol.obj_name_orig
                             ,nvl(cp.date_of_birth, to_char(cp.date_of_birth, 'dd.mm.yyyy')) dob
                         FROM p_policy   pol
                             ,as_asset   a
                             ,as_assured asr
                             ,contact    cpol
                             ,cn_person  cp
                        WHERE pol.policy_id = par_policy_id
                          AND cpol.contact_id = asr.assured_contact_id
                          AND pol.policy_id = a.p_policy_id
                          AND a.as_asset_id = asr.as_assured_id
                          AND cp.contact_id(+) = cpol.contact_id
                          AND cpol.risk_level IN
                              (SELECT r.t_risk_level_id
                                 FROM ins.t_risk_level r
                                WHERE r.brief IN ('Terror', 'Unprofitable', 'Swindler')))
    LOOP
      p_buf := p_buf || '; ' || cur_isurer.obj_name_orig;
      p_buf2 := p_buf2 || cnt2 || '. ' || 'ФИО: ' || cur_isurer.obj_name_orig || '; Дата рождения: ' ||
                cur_isurer.dob || chr(10) ||
                '----------------------------------------------------------------------------------------------------' ||
                chr(10);
      cnt   := cnt + 1;
      cnt2   := cnt2 + 1;
    END LOOP;
  
    FOR cur_benf IN (SELECT cpol.obj_name_orig
                           ,nvl(cp.date_of_birth, to_char(cp.date_of_birth, 'dd.mm.yyyy')) dob
                       FROM p_policy           pol
                           ,as_asset           a
                           ,ven_as_beneficiary ben
                           ,contact            cpol
                           ,cn_person          cp
                      WHERE pol.policy_id = par_policy_id
                        AND cpol.contact_id = ben.contact_id
                        AND pol.policy_id = a.p_policy_id
                        AND a.as_asset_id = ben.as_asset_id
                        AND cp.contact_id(+) = cpol.contact_id
                        AND cpol.risk_level IN
                            (SELECT r.t_risk_level_id
                               FROM ins.t_risk_level r
                              WHERE r.brief IN ('Terror', 'Unprofitable', 'Swindler')))
    LOOP
      p_buf := p_buf || '; ' || cur_benf.obj_name_orig;
      p_buf2 := p_buf2 || cnt2 || '. ' || 'ФИО: ' || cur_benf.obj_name_orig || '; Дата рождения: ' ||
                cur_benf.dob || chr(10) ||
                '----------------------------------------------------------------------------------------------------' ||
                chr(10);
      cnt   := cnt + 1;
      cnt2   := cnt2 + 1;
    END LOOP;
  
    IF cnt > 0
    THEN
      RAISE no_check;
    END IF;
  
  EXCEPTION
    WHEN no_check THEN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('115fz@Renlife.com')
                                         ,par_subject => 'Найдено совпадение с Черным списком (новый договор страхования)'
                                         ,par_text    => 'Добрый день!' || chr(10) ||
                                                         'При попытке перевести статус Договора страхования с ИДС №' ||
                                                         v_ids ||
                                                         ' было найдено совпадение с Черным списком ФМС:' ||
                                                         chr(10) || p_buf2);
    
      raise_application_error(-20001
                             ,'Клиент ' || p_buf ||
                              ' неблагонадежен, возможен переход в статус Нестандартный.');
    WHEN OTHERS THEN
      raise_application_error(-20002, 'Ошибка при выполнении ' || proc_name);
  END;

  PROCEDURE load_list_terror(par_load_file_id NUMBER) IS
    p_res NUMBER;
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
      SELECT lf.val_1
            ,lf.val_2
            ,lf.val_3
            ,lf.val_4
            ,lf.val_5
            ,lf.val_6
            ,lf.val_7
            ,lf.val_8
            ,lf.val_9
            ,lf.val_10
            ,lf.val_11
            ,lf.val_12
            ,lf.val_13
            ,lf.val_14
            ,lf.val_15
            ,lf.val_16
            ,lf.val_17
            ,lf.val_18
            ,lf.val_19
            ,lf.val_20
            ,lf.val_21
            ,lf.val_22
            ,lf.val_23
        FROM load_file_rows lf
       WHERE lf.load_file_id = par_load_file_id
         AND lf.is_checked = 1
         AND lf.row_status = pkg_load_file_to_table.get_checked;
  
    -- Обновление статуса обработанных записей на Успешно загружен
    UPDATE load_file_rows
       SET row_status = pkg_load_file_to_table.get_loaded
     WHERE load_file_id = par_load_file_id
       AND is_checked = 1
       AND row_status = pkg_load_file_to_table.get_checked;
  
    p_res := comparison_terror;
  
  END load_list_terror;

  /*
    Пиядин А. 301732 ТЗ Финмониторинг
  */
  PROCEDURE check_ag_contract(par_ag_contract_id ag_contract.ag_contract_id%TYPE) IS
    proc_name        VARCHAR2(25) := 'CHECK_AG_CONTRACT';
    v_ag_contract_id ag_contract.ag_contract_id%TYPE;
    v_ag_num         document.num%TYPE;
  BEGIN
    BEGIN
      SELECT ag.ag_contract_id
            ,d.num
        INTO v_ag_contract_id
            ,v_ag_num
        FROM ag_contract        ag
            ,ag_contract_header agh
            ,document           d
            ,contact            c
            ,t_risk_level       rl
      WHERE 1 = 1
        AND ag.ag_contract_id         = agh.last_ver_id
        AND agh.ag_contract_header_id = d.document_id
        AND agh.agent_id              = c.contact_id
        AND c.risk_level              = rl.t_risk_level_id
        AND rl.brief                  = 'Terror'
        AND ag.ag_contract_id         = par_ag_contract_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_ag_contract_id := NULL;
    END;
    
    IF v_ag_contract_id IS NOT NULL
    THEN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('115fz@Renlife.com')
                                         ,par_subject => 'Найдено совпадение с Черным списком (новый Агентский договор)'
                                         ,par_text    => 'Добрый день!' || chr(10) ||
                                                         'При попытке перевести статус Агентского договора с номером ' ||
                                                         v_ag_num ||
                                                         ' было найдено совпадение с Черным списком ФМС.');
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20002, 'Ошибка при выполнении ' || proc_name);
  END check_ag_contract;

END pkg_contact_finmon;
/