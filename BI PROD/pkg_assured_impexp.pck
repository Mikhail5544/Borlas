CREATE OR REPLACE PACKAGE pkg_assured_impexp IS
  -- Проверка загружаемой записи
  PROCEDURE check_rec
  (
    v_tmp         IN OUT as_person_med_tmp%ROWTYPE
   ,par_policy_id IN NUMBER
   ,p_session_id  NUMBER
  );

  -- Загрузка списка застрахованных из текстового файла во временную таблицу
  PROCEDURE Load_As_Assured
  (
    p_file_name   VARCHAR2
   ,par_policy_id NUMBER
  );

  -- Сохранение прейскуранта из временной таблицы в базу
  PROCEDURE Save_As_Assured
  (
    par_policy_id   NUMBER
   ,p_asset_type_id NUMBER
   ,p_session_id    NUMBER
  );

  /**
  * Процедура дополнения данными промежуточную таблицу
  * @author Процветов Е.
  * @param P_SESSION_ID Идентификатор XML-файла
  * @param P_POLICY_ID Идентификатор договора страхования
  */
  PROCEDURE update_as_assured
  (
    p_session_id NUMBER
   ,p_policy_id  NUMBER
  );

END PKG_ASSURED_IMPEXP;
/
CREATE OR REPLACE PACKAGE BODY pkg_assured_impexp IS

  -- папка для загрузки
  --c_input_folder constant varchar2(255) := 'DMS_PRICE_LOAD';
  c_input_folder CONSTANT VARCHAR2(400) := pkg_app_param.get_app_param_c('DMSPRICELOAD');

  -- Проверка загружаемой записи
  PROCEDURE check_rec
  (
    v_tmp         IN OUT as_person_med_tmp%ROWTYPE
   ,par_policy_id IN NUMBER
   ,p_session_id  NUMBER
  ) IS
    v_id       NUMBER;
    v_min_date DATE;
    v_max_date DATE;
    v_temp_num NUMBER;
  BEGIN
    --обработка прочитанных данных
    --Проверить сроки
    BEGIN
      SELECT p.start_date
            ,p.end_date
        INTO v_min_date
            ,v_max_date
        FROM p_policy p
       WHERE p.policy_id = par_policy_id;
      IF v_tmp.start_date > v_tmp.end_date
      THEN
        v_tmp.is_error   := 1;
        v_tmp.error_text := v_tmp.error_text || ';Дата начала больше даты окончания';
      END IF;
      IF v_tmp.start_date < v_min_date
         OR v_tmp.end_date > v_max_date
      THEN
        v_tmp.is_error   := 1;
        v_tmp.error_text := v_tmp.error_text ||
                            ';Срок прикрепления выходит за рамки действия договора';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_tmp.is_error   := 1;
        v_tmp.error_text := v_tmp.error_text || ';Неизвестная ошибка';
    END;
    --проверить вариант (изменил Д.Сыровецкий)
    BEGIN
      /*(select t.t_prod_line_dms_id
      into v_tmp.dms_ins_var_id
      from t_prod_line_dms t
      where t.code = v_tmp.dms_ins_var_num
        and t.p_policy_id = par_policy_id;*/
      --        dbms_output.put_line('3_'||v_tmp.dms_ins_var_num);
      /**/
      IF v_tmp.dms_ins_var_num IS NOT NULL
      THEN
        SELECT t_prod_line_dms_id
          INTO v_tmp.dms_ins_var_id
          FROM ven_t_prod_line_dms pld
         WHERE pld.code = v_tmp.dms_ins_var_num
           AND pld.p_policy_id = par_policy_id;
        /**/
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        --v_tmp.is_error := 0;
        v_tmp.error_text := v_tmp.error_text || ';Не найден вариант';
    END;
    --Найти группу здоровья
    IF TRIM(v_tmp.dms_health_group_brief) IS NOT NULL
    THEN
    
      BEGIN
        SELECT t.dms_health_group_id
          INTO v_tmp.dms_health_group_id
          FROM dms_health_group t
         WHERE t.brief = v_tmp.dms_health_group_brief;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_error   := 1;
          v_tmp.error_text := v_tmp.error_text || ';Не найдена группа здоровья';
      END;
    
    END IF;
    --Найти возрастную группу
    IF TRIM(v_tmp.dms_age_range_name) IS NOT NULL
    THEN
    
      BEGIN
        SELECT t.dms_age_range_id
          INTO v_tmp.dms_age_range_id
          FROM dms_age_range t
         WHERE t.name = v_tmp.dms_age_range_name;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_error   := 1;
          v_tmp.error_text := v_tmp.error_text || ';Не найдена возрастная группа';
      END;
    
    END IF;
    --Найти вид отношения к страхователю
    IF TRIM(v_tmp.dms_ins_rel_type_name) IS NOT NULL
    THEN
    
      BEGIN
        SELECT t.dms_ins_rel_type_id
          INTO v_tmp.dms_ins_rel_type_id
          FROM dms_ins_rel_type t
         WHERE t.name = v_tmp.dms_ins_rel_type_name;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_error   := 1;
          v_tmp.error_text := v_tmp.error_text || ';Не найден вид отношения к страхователю';
      END;
    
    END IF;
    --найти физическое лицо
    BEGIN
      SELECT t.contact_id
        INTO v_tmp.contact_id
        FROM ven_contact   t
            ,ven_cn_person cp
       WHERE t.contact_id = cp.contact_id
         AND upper(TRIM(t.name)) = upper(TRIM(v_tmp.name))
         AND upper(TRIM(t.first_name)) = upper(TRIM(v_tmp.first_name))
         AND upper(TRIM(t.middle_name)) = upper(TRIM(v_tmp.middle_name))
         AND cp.date_of_birth = v_tmp.birth_date;
    EXCEPTION
      WHEN OTHERS THEN
        v_tmp.is_contact_add := 1;
        IF v_tmp.address IS NOT NULL
        THEN
          v_tmp.is_address_add := 1;
        END IF;
        IF v_tmp.home_phone_number IS NOT NULL
        THEN
          v_tmp.is_home_phone_add := 1;
        END IF;
        IF v_tmp.work_phone_number IS NOT NULL
        THEN
          v_tmp.is_work_phone_add := 1;
        END IF;
        IF v_tmp.doc_num IS NOT NULL
        THEN
          v_tmp.is_doc_add := 1;
        END IF;
    END;
    --найти застрахованного в данном договоре
    BEGIN
    
      --если bso_num пустой, то нужно поискать по ФИО и ДР
      IF TRIM(v_tmp.bso_num) || ' ' = ' '
      THEN
        BEGIN
          SELECT aa.card_date
            INTO v_tmp.bso_num
            FROM ven_as_assured aa
                ,contact        c
                ,cn_person      cp
           WHERE aa.ASSURED_CONTACT_ID = c.CONTACT_ID
             AND cp.CONTACT_ID = c.CONTACT_ID
             AND c.name = v_tmp.name
             AND c.MIDDLE_NAME = v_tmp.MIDDLE_NAME
             AND c.first_name = v_tmp.first_name
             AND trunc(cp.DATE_OF_BIRTH, 'dd') = trunc(v_tmp.birth_date, 'dd');
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.bso_num := pkg_dms.get_pol_num(par_policy_id, p_session_id);
        END;
      END IF;
    
      SELECT t.as_assured_id
        INTO v_tmp.as_asset_id
        FROM ven_as_assured t
       WHERE t.p_policy_id = par_policy_id
         AND t.card_num = v_tmp.bso_num
         AND t.status_hist_id <> 3;
    EXCEPTION
      WHEN OTHERS THEN
        v_tmp.is_asset_add := 1;
    END;
    --проверить необходимость изменения параметров застрахованного
    IF v_tmp.as_asset_id IS NOT NULL
       AND v_tmp.is_error = 0
    THEN
      BEGIN
        SELECT apm.as_person_med_id
          INTO v_id
          FROM ven_as_person_med apm
              ,dms_health_group  dhg
              ,dms_age_range     dar
              ,dms_ins_var       div
         WHERE apm.office = v_tmp.office
           AND apm.department = v_tmp.department
           AND apm.dms_health_group_id = dhg.dms_health_group_id
           AND apm.dms_age_range_id = dar.dms_age_range_id
           AND apm.dms_ins_var_id = div.dms_ins_var_id
           AND dhg.brief = v_tmp.dms_health_group_brief
           AND dar.name = v_tmp.dms_age_range_name
           AND div.name = v_tmp.dms_ins_var_num;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_asset_change := 1;
      END;
    END IF;
    --проверить соответствие найденного ФЛ застрахованному
    IF v_tmp.contact_id IS NOT NULL
       AND v_tmp.as_asset_id IS NOT NULL
    THEN
      BEGIN
        SELECT apm.as_assured_id
          INTO v_id
          FROM ven_as_assured apm
         WHERE apm.as_assured_id = v_tmp.as_asset_id
           AND apm.assured_contact_id = v_tmp.contact_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_error   := 1;
          v_tmp.error_text := v_tmp.error_text || ';Несоответствие застрахованного номеру полиса';
      END;
    END IF;
    --проверить наличие в базе адреса
    IF v_tmp.contact_id IS NOT NULL
       AND v_tmp.is_error = 0
       AND v_tmp.address IS NOT NULL
    THEN
      BEGIN
        SELECT ca.id
          INTO v_tmp.cn_address_id
          FROM cn_contact_address cca
              ,cn_address         ca
         WHERE cca.contact_id = v_tmp.contact_id
           AND cca.adress_id = ca.id;
        BEGIN
          SELECT ca.id
            INTO v_id
            FROM cn_address ca
           WHERE ca.id = v_tmp.cn_address_id
             AND ca.name = v_tmp.address;
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.is_address_change := 1;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_address_add := 1;
      END;
    END IF;
    --проверить наличие в базе домашнего телефона
    IF v_tmp.contact_id IS NOT NULL
       AND v_tmp.is_error = 0
       AND v_tmp.home_phone_number IS NOT NULL
    THEN
      BEGIN
        SELECT cct.id
          INTO v_tmp.home_phone_id
          FROM cn_contact_telephone cct
              ,t_telephone_type     ttt
         WHERE cct.contact_id = v_tmp.contact_id
           AND cct.telephone_type = ttt.id
           AND ttt.description = 'Домашний телефон';
        BEGIN
          SELECT cct.id
            INTO v_id
            FROM cn_contact_telephone cct
           WHERE cct.id = v_tmp.home_phone_id
             AND cct.telephone_number = v_tmp.home_phone_number;
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.is_home_phone_change := 1;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_home_phone_add := 1;
      END;
    END IF;
    --проверить наличие в базе рабочего телефона
    IF v_tmp.contact_id IS NOT NULL
       AND v_tmp.is_error = 0
       AND v_tmp.work_phone_number IS NOT NULL
    THEN
      BEGIN
        SELECT cct.id
          INTO v_tmp.work_phone_id
          FROM cn_contact_telephone cct
              ,t_telephone_type     ttt
         WHERE cct.contact_id = v_tmp.contact_id
           AND cct.telephone_type = ttt.id
           AND ttt.description = 'Рабочий телефон';
        BEGIN
          SELECT cct.id
            INTO v_id
            FROM cn_contact_telephone cct
           WHERE cct.id = v_tmp.work_phone_id
             AND cct.telephone_number = v_tmp.work_phone_number;
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.is_work_phone_change := 1;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_work_phone_add := 1;
      END;
    END IF;
    --проверить наличие в базе документа (добавил Д.Сыровецкий)
    IF v_tmp.contact_id IS NOT NULL
       AND v_tmp.is_error = 0
       AND v_tmp.doc_num IS NOT NULL
    THEN
      BEGIN
        SELECT ci.table_id
          INTO v_temp_num
          FROM cn_contact_ident ci
              ,t_country        c
         WHERE ci.contact_id = v_tmp.contact_id
           AND ci.id_type = v_tmp.t_id_type_id
           AND c.alfa3 = 'RUS'
           AND ci.country_id = c.id;
      
        BEGIN
          SELECT ci.table_id
            INTO v_temp_num
            FROM cn_contact_ident ci
           WHERE ci.table_id = v_temp_num
             AND ci.ID_VALUE = v_tmp.doc_num
             AND ci.serial_nr = v_tmp.doc_ser
             AND ISSUE_DATE = v_tmp.doc_issue_date
             AND PLACE_OF_ISSUE = v_tmp.doc_issue_who;
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.is_work_phone_change := 1;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_work_phone_add := 1;
      END;
    END IF;
  
  END;

  FUNCTION get_gender(p_middle_name IN VARCHAR2) RETURN NUMBER IS
    v_ret_val   NUMBER := NULL;
    v_last_char CHAR(1);
    CURSOR cur_gender(p_discription IN VARCHAR2) IS
      SELECT tg.id FROM ven_t_gender tg WHERE upper(tg.description) = upper(p_discription);
  BEGIN
    IF p_middle_name IS NOT NULL
    THEN
      v_last_char := substr(upper(p_middle_name), length(p_middle_name), 1);
      IF v_last_char = 'Ч'
      THEN
        OPEN cur_gender('Мужской');
      ELSE
        OPEN cur_gender('Женский');
      END IF;
      FETCH cur_gender
        INTO v_ret_val;
      IF cur_gender%NOTFOUND
      THEN
        v_ret_val := 1;
      END IF;
    END IF;
    RETURN(v_ret_val);
  END;

  /**********************************************************************************/

  PROCEDURE update_as_assured
  (
    p_session_id NUMBER
   ,p_policy_id  NUMBER
  ) IS
    v_policy     ven_p_policy%ROWTYPE;
    v_pol_header ven_p_pol_header%ROWTYPE;
  BEGIN
    SELECT * INTO v_policy FROM ven_p_policy t WHERE t.policy_id = p_policy_id;
  
    SELECT *
      INTO v_pol_header
      FROM ven_p_pol_header t
     WHERE t.policy_header_id = v_policy.pol_header_id;
  
    FOR i IN (SELECT * FROM AS_PERSON_MED_TMP WHERE session_id = p_session_id ORDER BY row_id)
    LOOP
    
      IF i.start_date IS NULL
      THEN
        i.start_date := v_policy.start_date;
      END IF;
    
      IF i.end_date IS NULL
      THEN
        i.end_date := v_policy.end_date;
      END IF;
    
      i.gender := get_gender(i.middle_name);
    
      SELECT nvl((SELECT tit1.id FROM ven_t_id_type tit1 WHERE tit1.description = i.t_id_type_name)
                ,(SELECT tit2.id FROM ven_t_id_type tit2 WHERE tit2.brief = 'PASS_RF'))
        INTO i.T_ID_TYPE_ID
        FROM dual;
    
      -- проверить запись
      --dbms_output.put_line('step_1');
      check_rec(i, p_policy_id, p_session_id);
    
      --записать во временную таблицу
      i.error_text := TRIM(i.error_text);
    
      --dbms_output.put_line('2_'||v_tmp.error_text);
      DELETE FROM AS_PERSON_MED_TMP apm
       WHERE apm.session_id = i.session_id
         AND apm.row_id = i.row_id;
    
      --dbms_output.put_line('3_'||v_tmp.error_text);
      INSERT INTO as_person_med_tmp VALUES i;
      --dbms_output.put_line('step_4');
    END LOOP;
  END;

  /**********************************************************************************/

  -- Загрузка списка застрахованных из текстового файла во временную таблицу
  PROCEDURE Load_As_Assured
  (
    p_file_name   VARCHAR2
   ,par_policy_id NUMBER
  ) IS
    g_hFile      utl_file.file_type;
    s            VARCHAR2(4000);
    s1           VARCHAR2(255);
    v_Count      NUMBER;
    i            INTEGER;
    f            INTEGER;
    j            INTEGER;
    v_tmp        as_person_med_tmp%ROWTYPE;
    v_policy     ven_p_policy%ROWTYPE;
    v_pol_header ven_p_pol_header%ROWTYPE;
    v_id         NUMBER;
  BEGIN
    DELETE FROM as_person_med_tmp;
    BEGIN
      g_hFile := utl_file.fopen(c_input_folder, p_file_name, 'r');
      v_Count := 0;
      SELECT * INTO v_policy FROM ven_p_policy t WHERE t.policy_id = par_policy_id;
      SELECT *
        INTO v_pol_header
        FROM ven_p_pol_header t
       WHERE t.policy_header_id = v_policy.pol_header_id;
      LOOP
        BEGIN
          v_Count := v_Count + 1;
          utl_file.get_line(g_hFile, s, 4000);
          s := TRIM(s);
          BEGIN
            IF length(TRIM(s)) > 0
               AND v_Count > 1
            THEN
              f                            := 0;
              j                            := 0;
              v_tmp.dms_health_group_brief := NULL;
              v_tmp.bso_num                := NULL;
              v_tmp.name                   := NULL;
              v_tmp.first_name             := NULL;
              v_tmp.middle_name            := NULL;
              v_tmp.birth_date             := NULL;
              v_tmp.dms_ins_var_num        := NULL;
              v_tmp.coeff                  := NULL;
              v_tmp.dms_age_range_name     := NULL;
              v_tmp.address                := NULL;
              v_tmp.home_phone_number      := NULL;
              v_tmp.work_phone_number      := NULL;
              v_tmp.office                 := NULL;
              v_tmp.department             := NULL;
              v_tmp.start_date             := NULL;
              v_tmp.end_date               := NULL;
              v_tmp.dms_ins_rel_type_name  := NULL;
              v_tmp.as_asset_id            := NULL;
              v_tmp.contact_id             := NULL;
              v_tmp.cn_address_id          := NULL;
              v_tmp.home_phone_id          := NULL;
              v_tmp.work_phone_id          := NULL;
              v_tmp.is_asset_add           := 0;
              v_tmp.is_asset_change        := 0;
              v_tmp.is_contact_add         := 0;
              v_tmp.is_contact_change      := 0;
              v_tmp.is_address_add         := 0;
              v_tmp.is_address_change      := 0;
              v_tmp.is_home_phone_add      := 0;
              v_tmp.is_home_phone_change   := 0;
              v_tmp.is_work_phone_add      := 0;
              v_tmp.is_work_phone_change   := 0;
              v_tmp.is_error               := 0;
              v_tmp.is_doc_add             := 0;
              v_tmp.is_doc_change          := 0;
              v_tmp.error_text             := ' ';
              v_tmp.dms_health_group_id    := NULL;
              v_tmp.dms_ins_var_id         := NULL;
              v_tmp.dms_age_range_id       := NULL;
              v_tmp.dms_ins_rel_type_id    := NULL;
              v_tmp.note                   := NULL;
              v_tmp.gender                 := NULL;
              v_tmp.t_id_type_id           := NULL;
              v_tmp.t_id_type_name         := NULL;
              v_tmp.doc_ser                := NULL;
              v_tmp.doc_num                := NULL;
              v_tmp.doc_issue_date         := NULL;
              v_tmp.doc_issue_who          := NULL;
              LOOP
                IF s IS NULL
                THEN
                  i := 0;
                ELSE
                  i := instr(s, ';');
                END IF;
                IF i = 0
                THEN
                  s1 := s;
                  s  := NULL;
                  f  := 1;
                  j  := j + 1;
                ELSE
                  IF i > 1
                  THEN
                    s1 := substr(s, 1, i - 1);
                    s  := substr(s, i + 1, length(s) - i);
                    j  := j + 1;
                  ELSE
                    IF length(s) = 1
                    THEN
                      s  := NULL;
                      s1 := NULL;
                      j  := j + 1;
                    ELSE
                      s1 := NULL;
                      s  := substr(s, 2, length(s) - 1);
                      j  := j + 1;
                    END IF;
                  END IF;
                END IF;
                s1 := TRIM(s1);
                CASE j
                  WHEN 1 THEN
                    v_tmp.dms_health_group_brief := s1;
                  WHEN 2 THEN
                    v_tmp.bso_num := s1;
                  WHEN 3 THEN
                    v_tmp.name := s1;
                  WHEN 4 THEN
                    v_tmp.first_name := s1;
                  WHEN 5 THEN
                    v_tmp.middle_name := s1;
                    v_tmp.gender      := get_gender(s1);
                  WHEN 6 THEN
                    v_tmp.birth_date := to_date(s1, 'dd.mm.yyyy');
                  WHEN 7 THEN
                    v_tmp.dms_ins_var_num := s1;
                  WHEN 8 THEN
                    v_tmp.coeff := to_number(s1);
                  WHEN 9 THEN
                    v_tmp.dms_age_range_name := s1;
                  WHEN 10 THEN
                    v_tmp.address := s1;
                  WHEN 11 THEN
                    v_tmp.home_phone_number := s1;
                  WHEN 12 THEN
                    v_tmp.work_phone_number := s1;
                  WHEN 13 THEN
                    v_tmp.office := s1;
                  WHEN 14 THEN
                    v_tmp.department := s1;
                  WHEN 15 THEN
                    IF s1 IS NOT NULL
                    THEN
                      v_tmp.start_date := to_date(s1, 'dd.mm.yyyy');
                    ELSE
                      v_tmp.start_date := v_policy.start_date;
                    END IF;
                  WHEN 16 THEN
                    IF s1 IS NOT NULL
                    THEN
                      v_tmp.end_date := to_date(s1, 'dd.mm.yyyy');
                    ELSE
                      v_tmp.end_date := v_policy.end_date;
                    END IF;
                  WHEN 17 THEN
                    v_tmp.dms_ins_rel_type_name := nvl(s1, 'Сотрудники');
                    --when 18 then Здесь нужна загрузка сотрудника для родственников
                  WHEN 19 THEN
                    v_tmp.note := s1;
                  WHEN 20 THEN
                    SELECT id
                          ,description
                      INTO v_tmp.t_id_type_id
                          ,v_tmp.t_id_type_name
                      FROM ven_t_id_type
                     WHERE brief = 'PASS_RF';
                  
                    IF s1 IS NOT NULL
                    THEN
                      BEGIN
                        SELECT id INTO v_tmp.t_id_type_id FROM ven_t_id_type WHERE description = s1;
                        v_tmp.t_id_type_name := s1;
                      EXCEPTION
                        WHEN OTHERS THEN
                          NULL;
                      END;
                    END IF;
                  
                  WHEN 21 THEN
                    v_tmp.doc_ser := s1;
                  WHEN 22 THEN
                    v_tmp.doc_num := s1;
                  WHEN 23 THEN
                    IF s1 IS NOT NULL
                    THEN
                      v_tmp.doc_issue_date := to_date(s1, 'dd.mm.yyyy');
                    END IF;
                  WHEN 24 THEN
                    v_tmp.doc_issue_who := s1;
                  ELSE
                    NULL;
                END CASE;
                IF f = 1
                THEN
                  EXIT;
                END IF;
              END LOOP;
              -- проверить запись
              --dbms_output.put_line('step_1');
              check_rec(v_tmp
                       ,par_policy_id
                       , /*оставлено для совместимости*/1);
              --записать во временную таблицу
              v_tmp.error_text := TRIM(v_tmp.error_text);
              --dbms_output.put_line('2_'||v_tmp.error_text);
              INSERT INTO as_person_med_tmp VALUES v_tmp;
              --dbms_output.put_line('step_3');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        EXCEPTION
          WHEN OTHERS THEN
            EXIT;
        END;
      END LOOP;
      utl_file.fclose(g_hFile);
      SELECT COUNT(*) INTO v_Count FROM as_person_med_tmp t WHERE t.is_address_add = 1;
      dbms_output.put_line(v_Count);
    EXCEPTION
      WHEN OTHERS THEN
        --dbms_output.put_line(sqlerrm);
        dbms_output.put_line('Файл "' || p_file_name || '" не найден!');
    END;
  END;

  -- Сохранение прейскуранта из временной таблицы в базу
  PROCEDURE Save_As_Assured
  (
    par_policy_id   NUMBER
   ,p_asset_type_id NUMBER
   ,p_session_id    NUMBER
  ) IS
    CURSOR c IS
      SELECT *
        FROM as_person_med_tmp t
       WHERE t.is_error = 0
         AND t.session_id = p_session_id;
  
    CURSOR cur_cover(p_asset_id NUMBER) IS
      SELECT pc.p_cover_id FROM ven_p_cover pc WHERE pc.as_asset_id = p_asset_id;
    v_tmp               as_person_med_tmp%ROWTYPE;
    v_contact_id        NUMBER;
    v_contact_type_id   NUMBER;
    v_contact_status_id NUMBER;
    v_address_id        NUMBER;
    v_country_id        NUMBER;
    v_address_type_id   NUMBER;
    v_home_type_id      NUMBER;
    v_work_type_id      NUMBER;
    v_asset_header_id   NUMBER;
    v_asset_id          NUMBER;
    v_policy            ven_p_policy%ROWTYPE;
    v_dms_ins_var       dms_ins_var%ROWTYPE;
    v_insurer_id        NUMBER;
    v_asset_ent_id      NUMBER;
    v_dial_code_id      NUMBER;
    i                   NUMBER;
  BEGIN
    SELECT MAX(ct.id)
      INTO v_contact_type_id
      FROM t_contact_type ct
     WHERE ct.brief = 'ФЛ'
       AND ct.is_default = 1;
    SELECT MAX(cs.t_contact_status_id)
      INTO v_contact_status_id
      FROM t_contact_status cs
     WHERE cs.is_default = 1;
    SELECT MAX(c.id) INTO v_country_id FROM t_country c WHERE c.is_default = 1;
    SELECT MAX(c.id) INTO v_dial_code_id FROM t_country_dial_code c WHERE c.is_default = 1;
    SELECT MAX(tat.id) INTO v_address_type_id FROM t_address_type tat WHERE tat.is_default = 1;
    SELECT MAX(ttt.id) INTO v_home_type_id FROM t_telephone_type ttt WHERE ttt.brief = 'HOME';
    SELECT MAX(ttt.id) INTO v_work_type_id FROM t_telephone_type ttt WHERE ttt.brief = 'WORK';
    SELECT * INTO v_policy FROM ven_p_policy t WHERE t.policy_id = par_policy_id;
    SELECT MAX(pc.contact_id)
      INTO v_insurer_id
      FROM p_policy_contact   pc
          ,t_contact_pol_role tpr
     WHERE pc.policy_id = par_policy_id
       AND tpr.id = pc.contact_policy_role_id
       AND tpr.brief = 'Страхователь';
    SELECT e.ent_id INTO v_asset_ent_id FROM entity e WHERE e.brief = 'AS_ASSURED';
    pkg_renlife_utils.tmp_log_writer(par_policy_id || ' ' || p_asset_type_id || ' ' || p_session_id);
  
    OPEN c;
    LOOP
      FETCH c
        INTO v_tmp;
      EXIT WHEN c%NOTFOUND;
    
      --добавить контакт
      IF v_tmp.is_contact_add = 1
      THEN
        SELECT sq_contact.nextval INTO v_contact_id FROM dual;
        INSERT INTO contact c
          (c.contact_id
          ,c.name
          ,c.first_name
          ,c.middle_name
          ,c.contact_type_id
          ,c.short_name
          ,c.t_contact_status_id)
        VALUES
          (v_contact_id
          ,v_tmp.name
          ,v_tmp.first_name
          ,v_tmp.middle_name
          ,v_contact_type_id
          ,v_tmp.name || ' ' || upper(substr(v_tmp.first_name, 1, 1)) || '.' ||
           upper(substr(v_tmp.middle_name, 1, 1)) || '.'
          ,v_contact_status_id);
        INSERT INTO cn_person cp
          (cp.contact_id, cp.date_of_birth, cp.gender)
        VALUES
          (v_contact_id, v_tmp.birth_date, v_tmp.gender);
      ELSE
        v_contact_id := v_tmp.contact_id;
      END IF;
    
      --добавить/изменить адрес
      IF v_tmp.is_address_add = 1
      THEN
        SELECT sq_cn_address.nextval INTO v_address_id FROM dual;
        INSERT INTO cn_address ca
          (ca.id, ca.country_id, ca.name)
        VALUES
          (v_address_id, v_country_id, v_tmp.address);
        INSERT INTO cn_contact_address cca
          (cca.id, cca.contact_id, cca.address_type, cca.adress_id, cca.is_default)
        VALUES
          (sq_cn_contact_address.nextval, v_contact_id, v_address_type_id, v_address_id, 1);
      ELSE
        IF v_tmp.is_address_change = 1
        THEN
          UPDATE cn_address ca SET ca.name = v_tmp.address WHERE ca.id = v_tmp.cn_address_id;
        END IF;
      END IF;
      --добавить/изменить домашний телефон
      IF v_tmp.is_home_phone_add = 1
      THEN
        INSERT INTO cn_contact_telephone cct
          (cct.id, cct.contact_id, cct.telephone_type, cct.telephone_number, cct.country_id)
        VALUES
          (sq_cn_contact_telephone.nextval
          ,v_contact_id
          ,v_home_type_id
          ,v_tmp.home_phone_number
          ,v_dial_code_id);
      ELSE
        IF v_tmp.is_home_phone_change = 1
        THEN
          UPDATE cn_contact_telephone cct
             SET cct.telephone_number = v_tmp.home_phone_number
           WHERE cct.id = v_tmp.home_phone_id;
        END IF;
      END IF;
      --добавить/изменить рабочий телефон
      IF v_tmp.is_work_phone_add = 1
      THEN
        INSERT INTO cn_contact_telephone cct
          (cct.id, cct.contact_id, cct.telephone_type, cct.telephone_number, cct.country_id)
        VALUES
          (sq_cn_contact_telephone.nextval
          ,v_contact_id
          ,v_work_type_id
          ,v_tmp.work_phone_number
          ,v_dial_code_id);
      ELSE
        IF v_tmp.is_work_phone_change = 1
        THEN
          UPDATE cn_contact_telephone cct
             SET cct.telephone_number = v_tmp.work_phone_number
           WHERE cct.id = v_tmp.work_phone_id;
        END IF;
      END IF;
    
      --добавить/изменить документ (добавил Д.Сыровецкий)
      IF v_tmp.is_doc_add = 1
      THEN
        INSERT INTO cn_contact_ident ci
          (ci.table_id
          ,ci.contact_id
          ,ci.id_type
          ,ci.id_value
          ,ci.SERIAL_NR
          ,ci.country_id
          ,ci.ISSUE_DATE
          ,ci.PLACE_OF_ISSUE)
        VALUES
          (sq_cn_contact_ident.nextval
          ,v_contact_id
          ,v_tmp.t_id_type_id
          ,v_tmp.doc_num
          ,v_tmp.doc_ser
          ,v_country_id
          ,v_tmp.doc_issue_date
          ,v_tmp.doc_issue_who);
      ELSE
        IF v_tmp.is_doc_change = 1
        THEN
          UPDATE cn_contact_ident ci
             SET ci.id_value       = v_tmp.doc_num
                ,ci.SERIAL_NR      = v_tmp.doc_ser
                ,ci.ISSUE_DATE     = v_tmp.doc_issue_date
                ,ci.PLACE_OF_ISSUE = v_tmp.doc_issue_who
           WHERE ci.contact_id = v_contact_id
             AND ci.id_type = v_tmp.t_id_type_id
             AND ci.country_id = v_country_id;
        END IF;
      END IF;
    
      --добавить/изменить данные по застрахованному
      IF v_tmp.is_asset_add = 1
         OR v_tmp.is_asset_change = 1
      THEN
        SELECT sq_p_asset_header.nextval INTO v_asset_header_id FROM dual;
        INSERT INTO p_asset_header pah
          (pah.p_asset_header_id, pah.t_asset_type_id)
        VALUES
          (v_asset_header_id, p_asset_type_id);
        SELECT sq_as_asset.nextval INTO v_asset_id FROM dual;
        INSERT INTO as_asset aa
          (aa.as_asset_id
          ,aa.p_asset_header_id
          ,aa.ent_id
          ,aa.status_hist_id
          ,aa.p_policy_id
          ,aa.ins_amount
          ,aa.ins_premium
          ,aa.contact_id
          ,aa.start_date
          ,aa.end_date
          ,aa.ins_var_id
          ,aa.note)
        VALUES
          (v_asset_id
          ,v_asset_header_id
          ,v_asset_ent_id
          ,1
          ,par_policy_id
          ,0
          ,0
          ,v_insurer_id
          ,v_tmp.start_date
          ,v_tmp.end_date
          ,v_tmp.dms_ins_var_id
          ,v_tmp.note);
      
        INSERT INTO as_assured aaa
          (aaa.as_assured_id
          ,aaa.assured_contact_id
          ,aaa.dms_health_group_id
          ,aaa.dms_age_range_id
          ,aaa.dms_ins_rel_type_id
          ,aaa.t_territory_id
          ,aaa.card_num
          ,aaa.insured_age
          ,aaa.office
          ,aaa.department)
        VALUES
          (v_asset_id
          ,v_contact_id
          ,v_tmp.dms_health_group_id
          ,v_tmp.dms_age_range_id
          ,v_tmp.dms_ins_rel_type_id
          ,(SELECT tt.t_territory_id FROM t_territory tt WHERE tt.is_default = 1)
          ,v_tmp.bso_num
          ,TRUNC(MONTHS_BETWEEN(SYSDATE, v_tmp.birth_date) / 12)
          ,v_tmp.office
          ,v_tmp.department);
      
        IF v_tmp.is_asset_change = 1
        THEN
          UPDATE as_asset aa
             SET aa.status_hist_id = 3
                ,aa.end_date       = v_tmp.start_date - 1
           WHERE aa.as_asset_id = v_tmp.as_asset_id;
          v_asset_id := v_tmp.as_asset_id;
        END IF;
      
        FOR c_cover IN cur_cover(v_asset_id)
        LOOP
          pkg_cover.exclude_cover(c_cover.p_cover_id);
        END LOOP;
        pkg_cover.inc_mandatory_covers_by_asset(v_asset_id);
      
      END IF;
    
    END LOOP;
    CLOSE c;
  END;

END PKG_ASSURED_IMPEXP;
/
