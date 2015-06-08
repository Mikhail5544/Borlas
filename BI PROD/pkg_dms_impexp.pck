CREATE OR REPLACE PACKAGE pkg_dms_impexp IS

  g_asset_type_id NUMBER;

  -- Сохранение прейскуранта из временной таблицы в базу
  PROCEDURE Save_DMS_Price
  (
    p_contract_lpu_ver_id NUMBER
   ,p_fund_id             NUMBER
   ,p_start_date          DATE
   ,p_end_date            DATE
   ,
    --p_dms_aid_type_id number,
    p_executor_id NUMBER
   ,p_sid         NUMBER
  );
  -- Загрузка данных реестра из файла
  PROCEDURE load_c_service_med
  (
    p_file_name       VARCHAR2
   ,p_dms_serv_reg_id NUMBER
   ,p_session_id      NUMBER
  );
  --дополнение и проверка данных
  PROCEDURE update_c_service_med
  (
    p_session_id      NUMBER
   ,p_dms_serv_reg_id NUMBER
  );
  -- Перенос данных реестра из временной таблицы в основную
  FUNCTION save_c_service_med
  (
    p_dms_serv_reg_id NUMBER
   ,p_session_id      NUMBER
  ) RETURN NUMBER;

  FUNCTION check_date_all
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_start_date          IN DATE
   ,p_end_date            IN DATE
   ,err_mess              IN OUT VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_serv_reg_session_id RETURN NUMBER;

  PROCEDURE delete_old_price(p_contract_lpu_ver_id IN NUMBER);

  /**
  * Процедура дополнения данными промежуточную таблицу
  * @author Процветов Е.
  * @param P_SESSION_ID Идентификатор XML-файла
  * @param P_POLICY_ID Идентификатор договора страхования
  */
  PROCEDURE update_as_assured
  (
    p_session_id       NUMBER
   ,p_policy_id        NUMBER
   ,p_prod_line_dms_id NUMBER DEFAULT NULL
   ,p_action           NUMBER DEFAULT 0
  );

  -- Проверка загружаемой записи
  PROCEDURE check_rec
  (
    v_tmp              IN OUT as_person_med_tmp%ROWTYPE
   ,par_policy_id      IN NUMBER
   ,p_session_id       NUMBER
   ,p_prod_line_dms_id NUMBER DEFAULT NULL
   ,p_action           NUMBER DEFAULT 0
  );

  FUNCTION new_asset
  (
    p_tmp        IN as_person_med_tmp%ROWTYPE
   ,p_action     IN NUMBER DEFAULT 0
   ,p_policy_id  IN NUMBER DEFAULT NULL
   ,p_asset_id   IN NUMBER DEFAULT NULL
   ,p_contact_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  -- Сохранение прейскуранта из временной таблицы в базу
  PROCEDURE Save_As_Assured
  (
    par_policy_id   NUMBER
   ,p_asset_type_id NUMBER
   ,p_session_id    NUMBER
   ,p_action        NUMBER DEFAULT 0
  );

  PROCEDURE insert_into_tab(p_tmp IN as_person_med_tmp%ROWTYPE);

END PKG_DMS_IMPEXP;
/
CREATE OR REPLACE PACKAGE BODY pkg_dms_impexp IS

  -- папка для загрузки
  c_input_folder CONSTANT VARCHAR2(255) := pkg_app_param.get_app_param_c('DMSPRICELOAD');

  --type t_hash_of_aid_type is table of number index by dms_aid_type.brief%type;
  --type t_refcursor is ref cursor;

  -- Проверка правильности указания сроков действия услуг при загрузке
  FUNCTION check_date_all
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_start_date          IN DATE
   ,p_end_date            IN DATE
   ,err_mess              IN OUT VARCHAR2
  ) RETURN BOOLEAN IS
    v_start_date      DATE;
    v_end_date        DATE;
    v_contract_lpu_id NUMBER;
  
  BEGIN
    BEGIN
      SELECT clv.start_date
            ,clv.end_date
            ,clv.CONTRACT_LPU_ID
        INTO v_start_date
            ,v_end_date
            ,v_contract_lpu_id
        FROM ven_contract_lpu_ver clv
       WHERE clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
    
      SELECT MIN(start_date)
        INTO v_start_date
        FROM contract_lpu_ver
       WHERE CONTRACT_LPU_ID = v_contract_lpu_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        err_mess := 'Невозможно определить сроки действия договора';
        RETURN(FALSE);
    END;
  
    IF TRUNC(p_start_date) > TRUNC(p_end_date)
    THEN
      err_mess := 'Дата окончания действия услуг не может быть меньше даты начала действия';
      RETURN(FALSE);
    END IF;
  
    IF NVL(pkg_app_param.GET_APP_PARAM_N('DMS_PRICE_STRONG'), 1) = 1
    THEN
    
      IF TRUNC(p_start_date) < TRUNC(v_start_date)
      THEN
        err_mess := 'Дата начала действия услуг не может быть меньше даты начала действия договора - ' ||
                    TO_CHAR(v_start_date, 'DD.MM.YYYY');
        RETURN(FALSE);
      END IF;
    
      IF TRUNC(p_end_date) > TRUNC(v_end_date)
      THEN
        err_mess := 'Дата окончания действия услуг не может быть больше даты окончания действия версии договора - ' ||
                    TO_CHAR(v_start_date, 'DD.MM.YYYY');
        RETURN(FALSE);
      END IF;
    END IF;
  
    err_mess := NULL;
    RETURN(TRUE);
  END check_date_all;

  -- Загрузка прейскуранта из временной таблицы в основную
  PROCEDURE Save_DMS_Price
  (
    p_contract_lpu_ver_id NUMBER
   ,p_fund_id             NUMBER
   ,p_start_date          DATE
   ,p_end_date            DATE
   ,
    --p_dms_aid_type_id number,
    p_executor_id NUMBER
   ,p_sid         NUMBER
  ) IS
    price_rec dms_price%ROWTYPE;
    tmp_rec   dms_price_tmp%ROWTYPE;
    v_ent_id  NUMBER;
    v_msg     VARCHAR2(2000);
    v_code    NUMBER;
    v_price   NUMBER;
  
    v_st_del NUMBER;
    v_st_new NUMBER;
    v_st_cur NUMBER;
    PROCEDURE add_new_price(tmp_rec IN dms_price_tmp%ROWTYPE) IS
      v_price NUMBER;
    BEGIN
      BEGIN
        v_price := TO_NUMBER(tmp_rec.price);
      EXCEPTION
        WHEN OTHERS THEN
          v_price := 0.00;
      END;
      SELECT sq_dms_price.NEXTVAL INTO price_rec.dms_price_id FROM dual;
      price_rec.ent_id              := v_ent_id;
      price_rec.contract_lpu_ver_id := p_contract_lpu_ver_id;
      price_rec.code                := tmp_rec.code;
      price_rec.NAME                := tmp_rec.NAME;
      price_rec.fund_id             := p_fund_id;
      price_rec.start_date          := p_start_date;
      price_rec.end_date            := p_end_date;
      price_rec.amount              := v_price;
      price_rec.dms_aid_type_id     := tmp_rec.dms_aid_type_id;
      price_rec.status_hist_id      := V_ST_CUR;
      price_rec.executor_id         := p_executor_id;
      price_rec.is_not_ins          := NVL(tmp_rec.is_not_ins, 0);
      price_rec.is_not_med          := NVL(tmp_rec.is_not_med, 0);
      INSERT INTO dms_price VALUES price_rec;
    END;
  BEGIN
  
    SELECT STATUS_HIST_ID INTO v_st_new FROM status_hist WHERE brief = 'NEW';
    SELECT STATUS_HIST_ID INTO v_st_CUR FROM status_hist WHERE brief = 'CURRENT';
    SELECT STATUS_HIST_ID INTO v_st_DEL FROM status_hist WHERE brief = 'DELETED';
  
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'DMS_PRICE';
  
    FOR tmp_rec IN (SELECT * FROM dms_price_tmp WHERE session_id = p_sid)
    --(1)
    LOOP
      BEGIN
        --ищем запись по коду
        SELECT *
          INTO price_rec
          FROM dms_price p
         WHERE p.code = tmp_rec.code
              --and p.executor_id = p_executor_id
           AND p.CONTRACT_LPU_VER_ID = p_contract_lpu_ver_id
           AND ROWNUM = 1
           AND status_hist_id <> V_ST_DEL --не удален
         ORDER BY p.start_date DESC;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          price_rec.dms_price_id := NULL;
      END;
    
      BEGIN
        --ищем запись по наименованию
        IF price_rec.dms_price_id IS NULL
        THEN
          SELECT *
            INTO price_rec
            FROM dms_price p
           WHERE UPPER(p.NAME) = UPPER(tmp_rec.NAME)
             AND p.CONTRACT_LPU_VER_ID = p_contract_lpu_ver_id
             AND ROWNUM = 1
             AND status_hist_id <> V_ST_DEL --не удален
           ORDER BY p.start_date DESC;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          price_rec.dms_price_id := NULL;
      END;
    
      BEGIN
        v_price := TO_NUMBER(tmp_rec.price);
      EXCEPTION
        WHEN OTHERS THEN
          v_price := 0.00;
      END;
    
      --(2)
      IF price_rec.dms_price_id IS NULL
      THEN
        --не нашли запись, добавить
        add_new_price(tmp_rec);
      ELSE
        --(3)
        IF price_rec.start_date <= p_start_date
        THEN
          --закрыть запись
          UPDATE dms_price p
             SET p.end_date       = p_start_date - 1
                ,p.status_hist_id = V_ST_DEL --удален
           WHERE p.dms_price_id = price_rec.dms_price_id;
        
          IF tmp_rec.is_not_ins IS NULL
          THEN
            tmp_rec.is_not_ins := price_rec.is_not_ins;
          END IF;
        
          IF tmp_rec.is_not_med IS NULL
          THEN
            tmp_rec.is_not_med := price_rec.is_not_med;
          END IF;
        
          IF tmp_rec.dms_aid_type_id IS NULL
          THEN
            tmp_rec.dms_aid_type_id := price_rec.dms_aid_type_id;
          END IF;
        
          --добавить новую
          add_new_price(tmp_rec);
        ELSE
          --обновить запись
        
          UPDATE dms_price p
             SET p.start_date      = p_start_date
                ,p.end_date        = p_end_date
                ,p.status_hist_id  = V_ST_CUR
                , --действующий
                 p.NAME            = tmp_rec.NAME
                ,p.amount          = TO_NUMBER(NVL(tmp_rec.price, 0.00))
                ,p.dms_aid_type_id = tmp_rec.dms_aid_type_id
                ,p.is_not_ins      = NVL(tmp_rec.is_not_ins, 0)
                ,p.is_not_med      = NVL(tmp_rec.is_not_med, 0)
           WHERE p.dms_price_id = price_rec.dms_price_id;
        END IF; --(/3)
      END IF; --(/2)
    END LOOP; --(/1)
    COMMIT;
  END Save_DMS_Price;

  -- Загрузка данных реестра из файла
  PROCEDURE load_c_service_med
  (
    p_file_name       VARCHAR2
   ,p_dms_serv_reg_id NUMBER
   ,p_session_id      NUMBER
  ) IS
    g_hFile  UTL_FILE.FILE_TYPE;
    s        VARCHAR2(4000);
    s1       VARCHAR2(255);
    s_last   VARCHAR2(100);
    s_first  VARCHAR2(100);
    s_middle VARCHAR2(100);
    v_Count  NUMBER;
    i        INTEGER;
    f        INTEGER;
    j        INTEGER;
    v_csm    c_service_med_tmp%ROWTYPE;
  
    v_error_flg NUMBER := 0;
    v_error_txt VARCHAR2(2000) := '';
  BEGIN
    BEGIN
      g_hFile := UTL_FILE.FOPEN(c_input_folder, p_file_name, 'r');
    
      v_Count := 0;
      LOOP
        BEGIN
          v_Count := v_Count + 1;
          UTL_FILE.GET_LINE(g_hFile, s, 4000);
          s           := TRIM(s);
          v_error_flg := 0;
          v_error_txt := '';
          BEGIN
            IF LENGTH(TRIM(s)) > 0
               AND v_Count > 1
            THEN
              f                            := 0;
              j                            := 0;
              v_csm.service_date           := NULL;
              v_csm.bso_num                := NULL;
              v_csm.count_plan             := NULL;
              v_csm.amount_plan            := NULL;
              v_csm.service_name           := NULL;
              v_csm.service_code           := NULL;
              v_csm.as_assured_last_name   := NULL;
              v_csm.as_assured_first_name  := NULL;
              v_csm.as_assured_middle_name := NULL;
              v_csm.card_num               := NULL;
              v_csm.dms_mkb_name           := NULL;
              v_csm.doctor_name            := NULL;
              v_csm.service_price          := NULL;
              LOOP
                IF s IS NULL
                THEN
                  i := 0;
                ELSE
                  i := INSTR(s, ';');
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
                    s1 := SUBSTR(s, 1, i - 1);
                    s  := SUBSTR(s, i + 1, LENGTH(s) - i);
                    j  := j + 1;
                  ELSE
                    IF LENGTH(s) = 1
                    THEN
                      s  := NULL;
                      s1 := NULL;
                      j  := j + 1;
                    ELSE
                      s1 := NULL;
                      s  := SUBSTR(s, 2, LENGTH(s) - 1);
                      j  := j + 1;
                    END IF;
                  END IF;
                END IF;
                --dbms_output.put_line(to_char(j) || ':' || s1);
                CASE j
                  WHEN 1 THEN
                    BEGIN
                      v_csm.service_date := TO_DATE(s1, 'dd.mm.yyyy');
                    EXCEPTION
                      WHEN OTHERS THEN
                        v_error_flg := 1;
                        v_error_txt := v_error_txt || 'Ошибка формата данных; ';
                    END;
                  
                  WHEN 2 THEN
                    v_csm.bso_num := s1;
                  WHEN 3 THEN
                    BEGIN
                      v_csm.count_plan := TO_NUMBER(s1);
                    EXCEPTION
                      WHEN OTHERS THEN
                        v_error_flg := 1;
                        v_error_txt := v_error_txt || 'Неверное кол-во услуг; ';
                    END;
                  WHEN 4 THEN
                    BEGIN
                      v_csm.amount_plan := TO_NUMBER(s1);
                    EXCEPTION
                      WHEN OTHERS THEN
                        v_error_flg := 1;
                        v_error_txt := v_error_txt || 'Неверная заявленная сумма; ';
                    END;
                  WHEN 5 THEN
                    v_csm.service_name := s1;
                  WHEN 6 THEN
                    v_csm.service_code := s1;
                  WHEN 7 THEN
                    BEGIN
                      v_csm.as_assured_last_name := pkg_contact.get_fio_fmt(s1, 1);
                      BEGIN
                        v_csm.as_assured_first_name := pkg_contact.get_fio_fmt(s1, 2);
                        BEGIN
                          v_csm.as_assured_middle_name := pkg_contact.get_fio_fmt(s1, 3);
                        EXCEPTION
                          WHEN OTHERS THEN
                            v_error_flg := 1;
                            v_error_txt := v_error_txt || 'Не удалось получить отчество; ';
                        END;
                      EXCEPTION
                        WHEN OTHERS THEN
                          v_error_flg := 1;
                          v_error_txt := v_error_txt || 'Не удалось получить имя; ';
                      END;
                    EXCEPTION
                      WHEN OTHERS THEN
                        v_error_flg := 1;
                        v_error_txt := v_error_txt || 'Не удалось получить фамилию; ';
                    END;
                  
                  WHEN 8 THEN
                    v_csm.as_assured_last_name := s1;
                  WHEN 9 THEN
                    v_csm.as_assured_first_name := s1;
                  WHEN 10 THEN
                    v_csm.as_assured_middle_name := s1;
                  WHEN 11 THEN
                    v_csm.card_num := s1;
                  WHEN 12 THEN
                    v_csm.dms_mkb_name := s1;
                  WHEN 13 THEN
                    v_csm.doctor_name := s1;
                  WHEN 14 THEN
                    v_csm.service_price := s1;
                  ELSE
                    NULL;
                END CASE;
                IF f = 1
                THEN
                  EXIT;
                END IF;
              END LOOP;
            
              BEGIN
                INSERT INTO c_service_med_tmp
                  (c_service_med_tmp_id
                  ,dms_serv_reg_id
                  ,as_assured_first_name
                  ,as_assured_middle_name
                  ,as_assured_last_name
                  ,card_num
                  ,bso_num
                  ,service_code
                  ,service_name
                  ,service_price
                  ,dms_mkb_name
                  ,service_date
                  ,count_plan
                  ,amount_plan
                  ,doctor_name
                  ,session_id
                  ,is_error
                  ,error_note)
                VALUES
                  (sq_c_service_med_tmp.NEXTVAL
                  ,p_dms_serv_reg_id
                  ,v_csm.as_assured_first_name
                  ,v_csm.as_assured_middle_name
                  ,v_csm.as_assured_last_name
                  ,v_csm.card_num
                  ,v_csm.bso_num
                  ,v_csm.service_code
                  ,v_csm.service_name
                  ,v_csm.service_price
                  ,v_csm.dms_mkb_name
                  ,v_csm.service_date
                  ,v_csm.count_plan
                  ,v_csm.amount_plan
                  ,v_csm.doctor_name
                  ,p_session_id
                  ,v_error_flg
                  ,v_error_txt);
                COMMIT;
              
                --select sq_c_service_med.nextval into v_csm.c_service_med_id from dual;
                --v_csm.dms_serv_reg_id := p_dms_serv_reg_id;
                --select e.ent_id into v_csm.ent_id from entity e where e.brief = 'C_SERVICE_MED';
                --v_csm.is_not_med := 0;
                --v_csm.is_tech_check := 0;
                --v_csm.is_med_check := 0;
                --dbms_output.put_line('APPEND!!!');
                --begin
                --  insert into c_service_med values v_csm;
              EXCEPTION
                WHEN OTHERS THEN
                  DBMS_OUTPUT.PUT_LINE(SQLERRM);
              END;
              --end if;
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
      UTL_FILE.FCLOSE(g_hFile);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Файл "' || p_file_name || '" не найден!');
    END;
    DBMS_OUTPUT.PUT_LINE(v_Count);
  END;

  PROCEDURE update_c_service_med
  (
    p_session_id      NUMBER
   ,p_dms_serv_reg_id NUMBER
  ) IS
  
    v_error_txt VARCHAR2(4000) := NULL;
    v_error_flg NUMBER := 0;
  
  BEGIN
    UPDATE c_service_med_tmp sm
       SET sm.DMS_SERV_REG_ID = p_dms_serv_reg_id
     WHERE sm.SESSION_ID = p_session_id;
  
    FOR cur IN (SELECT * FROM c_service_med_tmp WHERE session_id = p_session_id)
    LOOP
      IF cur.as_assured_last_name IS NULL
         AND cur.fio IS NOT NULL
      THEN
        BEGIN
          cur.as_assured_last_name := pkg_contact.get_fio_fmt(cur.fio, 1);
        EXCEPTION
          WHEN OTHERS THEN
            v_error_flg := 1;
            v_error_txt := v_error_txt || 'Не удалось получить фамилию; ';
        END;
      END IF;
    
      IF cur.as_assured_first_name IS NULL
         AND cur.fio IS NOT NULL
      THEN
        BEGIN
          cur.as_assured_first_name := pkg_contact.get_fio_fmt(cur.fio, 2);
        EXCEPTION
          WHEN OTHERS THEN
            v_error_flg := 1;
            v_error_txt := v_error_txt || 'Не удалось получить итя; ';
        END;
      END IF;
    
      IF cur.as_assured_middle_name IS NULL
         AND cur.fio IS NOT NULL
      THEN
        BEGIN
          cur.as_assured_middle_name := pkg_contact.get_fio_fmt(cur.fio, 3);
        EXCEPTION
          WHEN OTHERS THEN
            v_error_flg := 1;
            v_error_txt := v_error_txt || ' Не удалось получить отчество; ';
        END;
      END IF;
    
      UPDATE c_service_med_tmp sm
         SET sm.ERROR_NOTE = v_error_txt
            ,sm.IS_ERROR   = v_error_flg
       WHERE c_service_med_tmp_id = cur.c_service_med_tmp_id;
    
    END LOOP;
  END;

  -- Перенос данных реестра из временной таблицы в основную
  FUNCTION save_c_service_med
  (
    p_dms_serv_reg_id NUMBER
   ,p_session_id      NUMBER
  ) RETURN NUMBER IS
    v_ret_val  NUMBER;
    v_mkb_id   NUMBER;
    v_mkb_name VARCHAR2(2000);
    v_mkb_code VARCHAR2(100);
  
    CURSOR cur_tmp_rec IS
      SELECT csmt.c_service_med_tmp_id
        FROM c_service_med_tmp csmt
       WHERE csmt.session_id = p_session_id;
  
    CURSOR cur_mkb IS
      SELECT dm.dms_mkb_id
            ,dm.NAME
        FROM ven_dms_mkb dm
       WHERE UPPER(dm.code) = UPPER(v_mkb_code);
    tmp_rec  c_service_med_tmp%ROWTYPE;
    serv_rec c_service_med%ROWTYPE;
  BEGIN
    v_ret_val := 0;
    FOR c_rec IN cur_tmp_rec
    LOOP
      SELECT *
        INTO tmp_rec
        FROM c_service_med_tmp
       WHERE c_service_med_tmp_id = c_rec.c_service_med_tmp_id;
      v_mkb_code := tmp_rec.dms_mkb_name;
      OPEN cur_mkb;
      FETCH cur_mkb
        INTO v_mkb_id
            ,v_mkb_name;
      IF cur_mkb%NOTFOUND
      THEN
        v_mkb_id   := NULL;
        v_mkb_name := NULL;
      END IF;
      CLOSE cur_mkb;
    
      --begin
      INSERT INTO c_service_med csm
        (csm.c_service_med_id
        ,csm.dms_serv_reg_id
        ,csm.service_date
        ,csm.amount_plan
        ,csm.service_code
        ,csm.count_plan
        ,csm.card_num
        ,csm.as_assured_first_name
        ,csm.service_name
        ,csm.bso_num
        ,csm.doctor_name
        ,csm.is_not_med
        ,csm.is_tech_check
        ,csm.is_med_check
        ,csm.as_assured_middle_name
        ,csm.as_assured_last_name
        ,csm.service_price
        ,csm.is_not_ins
        ,csm.is_tech_manual
        ,csm.dms_mkb_id
        ,csm.dms_mkb_name)
      VALUES
        (sq_c_service_med.NEXTVAL
        ,p_dms_serv_reg_id
        ,tmp_rec.service_date
        ,tmp_rec.amount_plan
        ,tmp_rec.service_code
        ,tmp_rec.count_plan
        ,tmp_rec.card_num
        ,tmp_rec.as_assured_first_name
        ,tmp_rec.service_name
        ,tmp_rec.bso_num
        ,tmp_rec.doctor_name
        ,NVL(tmp_rec.is_not_med, 0)
        ,0
        ,0
        ,tmp_rec.as_assured_middle_name
        ,tmp_rec.as_assured_last_name
        ,tmp_rec.service_price
        ,NVL(tmp_rec.is_not_ins, 0)
        ,0
        ,v_mkb_id
        ,v_mkb_name);
      --exception
    --  when others then
    --    v_ret_val := 1;
    --    exit;
    --end;        
    END LOOP;
    RETURN(v_ret_val);
  END;

  FUNCTION get_serv_reg_session_id RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
    SELECT sq_c_service_med_tmp.NEXTVAL INTO v_ret_val FROM dual;
    RETURN(v_ret_val);
  END;

  PROCEDURE delete_old_price(p_contract_lpu_ver_id IN NUMBER) IS
  
    v_st_del NUMBER;
  
  BEGIN
  
    SELECT STATUS_HIST_ID INTO v_st_DEL FROM status_hist WHERE brief = 'DELETED';
  
    UPDATE dms_price p
       SET p.status_hist_id = V_ST_DEL
     WHERE p.CONTRACT_LPU_VER_ID = p_contract_lpu_ver_id;
  END;

  -- Проверка загружаемой записи
  PROCEDURE check_rec
  (
    v_tmp              IN OUT as_person_med_tmp%ROWTYPE
   ,par_policy_id      IN NUMBER
   ,p_session_id       NUMBER
   ,p_prod_line_dms_id NUMBER DEFAULT NULL
   ,p_action           NUMBER DEFAULT 0
  ) IS
    v_id            NUMBER;
    v_min_date      DATE;
    v_max_date      DATE;
    v_temp_num      NUMBER;
    v_pol_header_id NUMBER;
  BEGIN
    --обработка прочитанных данных
    --Проверить сроки
  
    v_tmp.is_error   := 0;
    v_tmp.error_text := '';
  
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
      IF v_tmp.dms_ins_var_num IS NOT NULL
      THEN
        SELECT t_prod_line_dms_id
          INTO v_tmp.dms_ins_var_id
          FROM ven_t_prod_line_dms pld
         WHERE pld.num_product = v_tmp.dms_ins_var_num
           AND pld.p_policy_id = par_policy_id
           AND ROWNUM = 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    BEGIN
      IF v_tmp.dms_ins_var_id IS NULL
      THEN
        SELECT t_prod_line_dms_id
          INTO v_tmp.dms_ins_var_id
          FROM ven_t_prod_line_dms pld
         WHERE pld.code = v_tmp.dms_ins_var_num
           AND pld.p_policy_id = par_policy_id
           AND ROWNUM = 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_tmp.error_text := v_tmp.error_text || ';Не найден вариант';
        IF p_action IN (1, 2)
        THEN
          v_tmp.is_error := 1;
        END IF;
    END;
  
    IF p_prod_line_dms_id IS NOT NULL
    THEN
      SELECT pld.CODE
            ,pld.T_PROD_LINE_DMS_ID
        INTO v_tmp.dms_ins_var_num
            ,v_tmp.dms_ins_var_id
        FROM t_prod_line_dms pld
       WHERE pld.T_PROD_LINE_DMS_ID = p_prod_line_dms_id;
    END IF;
  
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
         WHERE t.NAME = v_tmp.dms_age_range_name;
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
         WHERE t.NAME = v_tmp.dms_ins_rel_type_name;
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
         AND UPPER(TRIM(t.NAME)) = UPPER(TRIM(v_tmp.NAME))
         AND UPPER(TRIM(t.first_name)) = UPPER(TRIM(v_tmp.first_name))
         AND UPPER(TRIM(t.middle_name)) = UPPER(TRIM(v_tmp.middle_name))
         AND cp.date_of_birth = v_tmp.birth_date;
    EXCEPTION
      WHEN OTHERS THEN
        IF p_action IN (1)
        THEN
        
          v_tmp.is_error   := 1;
          v_tmp.error_text := v_tmp.error_text || ';Не найдено физическое лицо';
        
        ELSE
        
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
        END IF;
    END;
  
    IF v_tmp.is_error = 0
       AND p_action = 2
       AND v_tmp.asset_change_id IS NULL
    THEN
      v_tmp.is_error   := 1;
      v_tmp.error_text := v_tmp.error_text || ';Не найдено физическое лицо на замену';
    END IF;
  
    --найти застрахованного в данном договоре
    BEGIN
    
      --если bso_num пустой, то нужно поискать по ФИО и ДР
      IF TRIM(v_tmp.bso_num) || ' ' = ' '
      THEN
        SELECT pp.POL_HEADER_ID
          INTO v_pol_header_id
          FROM p_policy pp
         WHERE pp.POLICY_ID = par_policy_id;
      
        BEGIN
          SELECT aas.card_num
            INTO v_tmp.bso_num
            FROM ven_as_assured aas
                ,as_asset       aa
                ,p_policy       pp
                ,contact        c
                ,cn_person      cp
           WHERE aas.ASSURED_CONTACT_ID = c.CONTACT_ID
             AND pp.POL_HEADER_ID = v_pol_header_id
             AND aa.P_POLICY_ID = pp.POLICY_ID
             AND aas.as_assured_id = aa.as_asset_id
             AND cp.CONTACT_ID = c.CONTACT_ID
             AND c.NAME = v_tmp.NAME
             AND c.MIDDLE_NAME = v_tmp.MIDDLE_NAME
             AND c.first_name = v_tmp.first_name
             AND TRUNC(cp.DATE_OF_BIRTH, 'dd') = TRUNC(v_tmp.birth_date, 'dd')
             AND ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.bso_num := pkg_dms.get_pol_num(par_policy_id, p_session_id);
        END;
      
        IF TRIM(v_tmp.bso_num) || ' ' = ' '
        THEN
          v_tmp.bso_num := pkg_dms.get_pol_num(par_policy_id, p_session_id);
        END IF;
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
  
    IF p_action IN (1)
       AND v_tmp.as_asset_id IS NULL
    THEN
      v_tmp.is_error   := 1;
      v_tmp.error_text := v_tmp.error_text || ';Не найден застрахованный';
    END IF;
  
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
           AND dar.NAME = v_tmp.dms_age_range_name
           AND div.NAME = v_tmp.dms_ins_var_num;
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
        WHEN NO_DATA_FOUND THEN
          v_tmp.is_error   := 1;
          v_tmp.error_text := v_tmp.error_text || ';Несоответствие застрахованного номеру полиса';
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  
    --проверить наличие в базе адреса
    IF v_tmp.contact_id IS NOT NULL
       AND v_tmp.is_error = 0
       AND v_tmp.address IS NOT NULL
    THEN
      BEGIN
        SELECT ca.ID
          INTO v_tmp.cn_address_id
          FROM cn_contact_address cca
              ,cn_address         ca
         WHERE cca.contact_id = v_tmp.contact_id
           AND cca.adress_id = ca.ID;
        BEGIN
          SELECT ca.ID
            INTO v_id
            FROM cn_address ca
           WHERE ca.ID = v_tmp.cn_address_id
             AND ca.NAME = v_tmp.address;
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
        SELECT cct.ID
          INTO v_tmp.home_phone_id
          FROM cn_contact_telephone cct
              ,t_telephone_type     ttt
         WHERE cct.contact_id = v_tmp.contact_id
           AND cct.telephone_type = ttt.ID
           AND ttt.description = 'Домашний телефон';
        BEGIN
          SELECT cct.ID
            INTO v_id
            FROM cn_contact_telephone cct
           WHERE cct.ID = v_tmp.home_phone_id
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
        SELECT cct.ID
          INTO v_tmp.work_phone_id
          FROM cn_contact_telephone cct
              ,t_telephone_type     ttt
         WHERE cct.contact_id = v_tmp.contact_id
           AND cct.telephone_type = ttt.ID
           AND ttt.description = 'Рабочий телефон';
        BEGIN
          SELECT cct.ID
            INTO v_id
            FROM cn_contact_telephone cct
           WHERE cct.ID = v_tmp.work_phone_id
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
         WHERE ci.contact_id = v_tmp.contact_id
           AND ci.id_type = v_tmp.t_id_type_id;
      
        BEGIN
          SELECT ci.table_id
            INTO v_temp_num
            FROM cn_contact_ident ci
           WHERE ci.contact_id = v_tmp.contact_id
             AND ci.id_type = v_tmp.t_id_type_id
             AND UPPER(ci.ID_VALUE) = UPPER(v_tmp.doc_num)
             AND UPPER(ci.serial_nr) = UPPER(v_tmp.doc_ser)
             AND ISSUE_DATE = v_tmp.doc_issue_date
             AND UPPER(PLACE_OF_ISSUE) = UPPER(v_tmp.doc_issue_who);
        EXCEPTION
          WHEN OTHERS THEN
            v_tmp.is_doc_change := 1;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          v_tmp.is_doc_add := 1;
      END;
    
    END IF;
  
  END;

  FUNCTION get_gender(p_middle_name IN VARCHAR2) RETURN NUMBER IS
    v_ret_val   NUMBER := NULL;
    v_last_char CHAR(1);
    CURSOR cur_gender(p_discription IN VARCHAR2) IS
      SELECT tg.ID FROM ven_t_gender tg WHERE UPPER(tg.description) = UPPER(p_discription);
  BEGIN
    IF p_middle_name IS NOT NULL
    THEN
      v_last_char := SUBSTR(UPPER(p_middle_name), LENGTH(p_middle_name), 1);
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
    p_session_id       NUMBER
   ,p_policy_id        NUMBER
   ,p_prod_line_dms_id NUMBER DEFAULT NULL
   ,p_action           NUMBER DEFAULT 0
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
    
      SELECT NVL((SELECT tit1.ID FROM ven_t_id_type tit1 WHERE tit1.description = i.t_id_type_name)
                ,(SELECT tit2.ID FROM ven_t_id_type tit2 WHERE tit2.brief = 'PASS_RF'))
        INTO i.T_ID_TYPE_ID
        FROM dual;
    
      -- проверить запись
      --dbms_output.put_line('step_1');
      check_rec(i, p_policy_id, p_session_id, p_prod_line_dms_id, p_action);
    
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

  FUNCTION new_asset
  (
    p_tmp        IN as_person_med_tmp%ROWTYPE
   ,p_action     IN NUMBER DEFAULT 0
   ,p_policy_id  IN NUMBER DEFAULT NULL
   ,p_asset_id   IN NUMBER DEFAULT NULL
   ,p_contact_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
  
    /* p_action
    0 - insert new
    1 - update assured
    2 - create new from p_asset_id
    */
    v_asset_id        NUMBER;
    v_asset_header_id NUMBER;
    v_insurer_id      NUMBER;
    v_asset_ent_id    NUMBER;
  
    v_st_id NUMBER;
  BEGIN
  
    SELECT MAX(pc.contact_id)
      INTO v_insurer_id
      FROM p_policy_contact   pc
          ,t_contact_pol_role tpr
     WHERE pc.policy_id = p_policy_id
       AND tpr.ID = pc.contact_policy_role_id
       AND tpr.brief = 'Страхователь';
  
    SELECT e.ent_id INTO v_asset_ent_id FROM entity e WHERE e.brief = 'AS_ASSURED';
  
    IF p_action IN (0, 2)
    THEN
    
      SELECT sq_as_asset.NEXTVAL INTO v_asset_id FROM dual;
    
      IF p_action = 0
      THEN
        -- нужно добавить новый ассет
        SELECT sq_p_asset_header.NEXTVAL INTO v_asset_header_id FROM dual;
      
        INSERT INTO p_asset_header pah
          (pah.p_asset_header_id, pah.t_asset_type_id)
        VALUES
          (v_asset_header_id, g_asset_type_id);
      
      ELSIF p_action = 2
      THEN
      
        -- нужно создать новую версию существующего
        SELECT aa.P_ASSET_HEADER_ID
          INTO v_asset_header_id
          FROM as_asset aa
         WHERE as_asset_id = p_asset_id;
      
        SELECT status_hist_id INTO v_st_id FROM status_hist WHERE brief = 'DELETED';
      
        UPDATE as_asset aa
           SET aa.status_hist_id = v_st_id
              ,aa.end_date       = p_tmp.start_date - 1
         WHERE aa.as_asset_id = p_asset_id;
      
      END IF;
    
      SELECT status_hist_id INTO v_st_id FROM status_hist WHERE brief = 'NEW';
    
      --информация по застрахованному    
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
        ,v_st_id
        ,p_policy_id
        ,0
        ,0
        ,v_insurer_id
        ,p_tmp.start_date
        ,p_tmp.end_date
        ,p_tmp.dms_ins_var_id
        ,p_tmp.note);
    
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
        ,aaa.department
        ,aaa.gender
        ,aaa.card_date)
      VALUES
        (v_asset_id
        ,p_contact_id
        ,p_tmp.dms_health_group_id
        ,p_tmp.dms_age_range_id
        ,p_tmp.dms_ins_rel_type_id
        ,(SELECT tt.t_territory_id FROM t_territory tt WHERE tt.is_default = 1)
        ,p_tmp.bso_num
        ,TRUNC(MONTHS_BETWEEN(SYSDATE, p_tmp.birth_date) / 12)
        ,p_tmp.office
        ,p_tmp.department
        ,p_tmp.gender
        ,p_tmp.start_date);
    
    ELSIF p_action = 1
    THEN
      --обновление инфы по застрахованному
      v_asset_id := p_asset_id;
    
      UPDATE as_assured aaa
         SET aaa.assured_contact_id  = p_contact_id
            ,aaa.dms_health_group_id = p_tmp.dms_health_group_id
            ,aaa.dms_age_range_id    = p_tmp.dms_age_range_id
            ,aaa.dms_ins_rel_type_id = p_tmp.dms_ins_rel_type_id
            ,aaa.t_territory_id     =
             (SELECT tt.t_territory_id FROM t_territory tt WHERE tt.is_default = 1)
            ,aaa.card_num            = p_tmp.bso_num
            ,aaa.insured_age         = TRUNC(MONTHS_BETWEEN(SYSDATE, p_tmp.birth_date) / 12)
            ,aaa.office              = p_tmp.office
            ,aaa.department          = p_tmp.department
            ,aaa.gender              = p_tmp.gender
            ,aaa.card_date           = p_tmp.start_date
       WHERE aaa.as_assured_id = v_asset_id;
    END IF;
  
    RETURN v_asset_id;
  END;

  -- Сохранение прейскуранта из временной таблицы в базу
  PROCEDURE Save_As_Assured
  (
    par_policy_id   NUMBER
   ,p_asset_type_id NUMBER
   ,p_session_id    NUMBER
   ,p_action        NUMBER DEFAULT 0
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
    v_dial_code_id      NUMBER;
  
    v_temp_count     NUMBER;
    v_t_prod_line_id NUMBER;
  
    i NUMBER;
  BEGIN
  
    IF p_asset_type_id IS NOT NULL
    THEN
      g_asset_type_id := p_asset_type_id;
    END IF;
  
    SELECT MAX(ct.ID)
      INTO v_contact_type_id
      FROM t_contact_type ct
     WHERE ct.brief = 'ФЛ'
       AND ct.is_default = 1;
    SELECT MAX(cs.t_contact_status_id)
      INTO v_contact_status_id
      FROM t_contact_status cs
     WHERE cs.is_default = 1;
    SELECT MAX(c.ID) INTO v_country_id FROM t_country c WHERE c.is_default = 1;
    SELECT MAX(c.ID) INTO v_dial_code_id FROM t_country_dial_code c WHERE c.is_default = 1;
    SELECT MAX(tat.ID) INTO v_address_type_id FROM t_address_type tat WHERE tat.is_default = 1;
    SELECT MAX(ttt.ID) INTO v_home_type_id FROM t_telephone_type ttt WHERE ttt.brief = 'HOME';
    SELECT MAX(ttt.ID) INTO v_work_type_id FROM t_telephone_type ttt WHERE ttt.brief = 'WORK';
    SELECT * INTO v_policy FROM ven_p_policy t WHERE t.policy_id = par_policy_id;
  
    pkg_renlife_utils.tmp_log_writer(par_policy_id || ' ' || p_asset_type_id || ' ' || p_session_id);
    OPEN c;
  
    LOOP
      FETCH c
        INTO v_tmp;
      EXIT WHEN c%NOTFOUND;
    
      IF v_tmp.as_asset_id IS NOT NULL
         AND v_tmp.dms_ins_var_id IS NOT NULL
         AND p_action = 1
      THEN
      
        FOR cur IN (SELECT pc.p_cover_id
                      FROM p_cover            pc
                          ,t_prod_line_option plo
                     WHERE pc.AS_ASSET_ID = v_tmp.as_asset_id
                       AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                       AND plo.PRODUCT_LINE_ID = v_tmp.dms_ins_var_id)
        LOOP
          pkg_cover.EXCLUDE_COVER(cur.p_cover_id);
        END LOOP;
      END IF;
    
      IF p_action = 2
         AND v_tmp.dms_ins_var_id IS NOT NULL
         AND v_tmp.asset_change_id IS NOT NULL
      THEN
        --pkg_asset.exclude_as_asset(par_policy_id, v_tmp.as_asset_id);
        FOR cur IN (SELECT pc.p_cover_id
                      FROM p_cover            pc
                          ,t_prod_line_option plo
                     WHERE pc.AS_ASSET_ID = v_tmp.asset_change_id
                       AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                       AND plo.PRODUCT_LINE_ID = v_tmp.dms_ins_var_id)
        LOOP
          pkg_cover.EXCLUDE_COVER(cur.p_cover_id);
        END LOOP;
      END IF;
    
      IF p_action IN (0, 2)
      THEN
      
        --добавить контакт
        IF v_tmp.is_contact_add = 1
        THEN
          SELECT sq_contact.NEXTVAL INTO v_contact_id FROM dual;
          INSERT INTO contact c
            (c.contact_id
            ,c.NAME
            ,c.first_name
            ,c.middle_name
            ,c.contact_type_id
            ,c.short_name
            ,c.t_contact_status_id)
          VALUES
            (v_contact_id
            ,v_tmp.NAME
            ,v_tmp.first_name
            ,v_tmp.middle_name
            ,v_contact_type_id
            ,v_tmp.NAME || ' ' || UPPER(SUBSTR(v_tmp.first_name, 1, 1)) || '.' ||
             UPPER(SUBSTR(v_tmp.middle_name, 1, 1)) || '.'
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
          SELECT sq_cn_address.NEXTVAL INTO v_address_id FROM dual;
          INSERT INTO cn_address ca
            (ca.ID, ca.country_id, ca.NAME)
          VALUES
            (v_address_id, v_country_id, v_tmp.address);
          INSERT INTO cn_contact_address cca
            (cca.ID, cca.contact_id, cca.address_type, cca.adress_id, cca.is_default)
          VALUES
            (sq_cn_contact_address.NEXTVAL, v_contact_id, v_address_type_id, v_address_id, 1);
        ELSE
          IF v_tmp.is_address_change = 1
          THEN
            UPDATE cn_address ca SET ca.NAME = v_tmp.address WHERE ca.ID = v_tmp.cn_address_id;
          END IF;
        END IF;
        --добавить/изменить домашний телефон
        IF v_tmp.is_home_phone_add = 1
           AND TRIM(v_tmp.home_phone_number) || ' ' <> ' '
        THEN
          INSERT INTO cn_contact_telephone cct
            (cct.ID, cct.contact_id, cct.telephone_type, cct.telephone_number, cct.country_id)
          VALUES
            (sq_cn_contact_telephone.NEXTVAL
            ,v_contact_id
            ,v_home_type_id
            ,v_tmp.home_phone_number
            ,v_dial_code_id);
        ELSE
          IF v_tmp.is_home_phone_change = 1
             AND TRIM(v_tmp.home_phone_number) || ' ' <> ' '
          THEN
            UPDATE cn_contact_telephone cct
               SET cct.telephone_number = v_tmp.home_phone_number
             WHERE cct.ID = v_tmp.home_phone_id;
          END IF;
        END IF;
        --добавить/изменить рабочий телефон
        IF v_tmp.is_work_phone_add = 1
           AND TRIM(v_tmp.work_phone_number) || ' ' <> ' '
        THEN
          INSERT INTO cn_contact_telephone cct
            (cct.ID, cct.contact_id, cct.telephone_type, cct.telephone_number, cct.country_id)
          VALUES
            (sq_cn_contact_telephone.NEXTVAL
            ,v_contact_id
            ,v_work_type_id
            ,v_tmp.work_phone_number
            ,v_dial_code_id);
        ELSE
          IF v_tmp.is_work_phone_change = 1
             AND TRIM(v_tmp.work_phone_number) || ' ' <> ' '
          THEN
            UPDATE cn_contact_telephone cct
               SET cct.telephone_number = v_tmp.work_phone_number
             WHERE cct.ID = v_tmp.work_phone_id;
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
            (sq_cn_contact_ident.NEXTVAL
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
        
          v_asset_id := NULL;
        
          -- если добавляется новый застрахованный, 
          -- то нужно проверить наличие ваканисий по программе
          IF v_tmp.dms_ins_var_id IS NOT NULL
             AND v_tmp.is_asset_add = 1
          THEN
            v_asset_id := pkg_dms_vacation.GET_FREE_VACATION(v_tmp.dms_ins_var_id);
          END IF;
        
          IF v_asset_id IS NULL
             AND v_tmp.as_asset_id IS NULL
          THEN
          
            --создаем нового застрахованного
            v_asset_id := new_asset(v_tmp, 0, par_policy_id, NULL, v_contact_id);
          
            --подключаем программу
            IF v_tmp.dms_ins_var_id IS NOT NULL
            THEN
              --подключаем программу указанную
              v_temp_count := pkg_cover.INCLUDE_COVER(v_asset_id, v_Tmp.dms_ins_var_id);
            ELSE
              -- кажется - программа по умолчанию
              pkg_cover.inc_mandatory_covers_by_asset(v_asset_id);
            END IF;
          
          ELSIF v_asset_id IS NOT NULL
                AND v_tmp.as_asset_id IS NULL
          THEN
            -- нашли вакансию для застрахованного
            -- нужно обновить данные по застрахованному
            v_asset_id := new_asset(v_tmp, 1, NULL, v_asset_id, v_contact_id);
          
          ELSE
            --(v_tmp.as_asset_id is not null)
          
            --нужно обновить застрахованного
            v_tmp.is_asset_change := 1;
          
          END IF;
        
          IF v_tmp.is_asset_change = 1
          THEN
          
            -- обновляем информацию о застрахованном          
            v_asset_id := new_asset(v_tmp, 1, NULL, v_tmp.as_asset_id, v_contact_id);
          
            v_temp_count := 0;
          
            --ищет подключенные программы
            FOR cur IN (SELECT plo.PRODUCT_LINE_ID
                              ,pc.P_COVER_ID
                              ,pc.as_asset_id
                              ,aa.P_POLICY_ID
                          FROM p_cover            pc
                              ,t_prod_line_option plo
                              ,as_asset           aa
                         WHERE plo.ID = pc.T_PROD_LINE_OPTION_ID
                           AND aa.AS_ASSET_ID = pc.AS_ASSET_ID
                           AND pc.AS_ASSET_ID = v_tmp.as_asset_id)
            LOOP
              --хоть одну программу нашли
              v_temp_count := 1;
            
              IF NVL(v_tmp.dms_ins_var_id, -3) = cur.product_line_id
              THEN
                --программы совпадают, ничего не делаем
                NULL;
              ELSE
                -- нужно отключить старую программу
                pkg_cover.exclude_cover(cur.p_cover_id);
                -- создаем новую версию ассета из старого
                v_asset_id := new_asset(v_tmp, 2, cur.p_policy_id, cur.as_asset_id, v_contact_id);
              
                -- подключаем программу
                IF v_tmp.dms_ins_var_id IS NULL
                THEN
                  pkg_cover.inc_mandatory_covers_by_asset(v_asset_id);
                ELSE
                  v_asset_id := pkg_cover.INCLUDE_COVER(v_asset_id, v_tmp.dms_ins_var_id);
                END IF;
              
              END IF;
            
            END LOOP;
          
            IF v_temp_count = 0
            THEN
              -- у застрахованного не было подключенных программ
              -- нужно ему ее подключить
              IF v_tmp.dms_ins_var_id IS NULL
              THEN
                pkg_cover.inc_mandatory_covers_by_asset(v_asset_id);
              ELSE
                v_asset_id := pkg_cover.INCLUDE_COVER(v_asset_id, v_tmp.dms_ins_var_id);
              END IF;
            END IF;
          END IF;
        
        END IF; -- v_tmp.is_asset_add = 1 or v_tmp.is_asset_change = 1
      
      END IF; -- p_action in (0,2)
    
    END LOOP;
    CLOSE c;
  END;

  PROCEDURE insert_into_tab(p_tmp IN as_person_med_tmp%ROWTYPE) IS
  BEGIN
    INSERT INTO as_person_med_tmp VALUES p_tmp;
  END;

END PKG_DMS_IMPEXP;
-- End of DDL Script for Package INS.PKG_DMS_IMPEXP
/
