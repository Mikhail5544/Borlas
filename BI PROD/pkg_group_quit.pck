CREATE OR REPLACE PACKAGE pkg_group_quit IS
  ----========================================================================----
  -- Пакет группового прекращения договоров
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк файлов
  -- (group_quit_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE Load_BLOB_To_Table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  ----========================================================================----
  -- Процедура прекращения ДС по данным соответствующего файла
  PROCEDURE Quit_Policy
  (
    par_pol_num             VARCHAR2
   ,par_ids                 NUMBER
   ,par_issuer_name         VARCHAR2
   ,par_start_date          DATE
   ,par_pay_term_name       VARCHAR2
   ,par_fund_brief          VARCHAR2
   ,par_rate_act_date       NUMBER
   ,par_rate_return_date    NUMBER
   ,par_region_name         VARCHAR2
   ,par_product_conds_desc  VARCHAR2
   ,par_decline_date        DATE
   ,par_decline_reason_name VARCHAR2
   ,par_debt_fee_sum        NUMBER
   ,par_debt_fee_fact       NUMBER
   ,par_medo_cost           NUMBER
   ,par_overpayment         NUMBER
  );
  ----========================================================================----  
END PKG_GROUP_QUIT;
/
CREATE OR REPLACE PACKAGE BODY pkg_group_quit IS
  ----========================================================================----
  -- Пакет группового прекращения договоров
  ----========================================================================----
  -- Загрузк файла из BLOB-а в таблицу строк файлов
  -- (group_quit_file_row)
  -- Входные параметры: идентификатор из sq_temp_load_blob,
  -- идентификатор файла (load_file_id)
  PROCEDURE Load_BLOB_To_Table
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  ) IS
    va_values             PKG_LOAD_FILE_TO_TABLE.t_varay;
    v_blob_data           BLOB;
    v_blob_len            NUMBER;
    v_position            NUMBER;
    c_chunk_len           NUMBER := 1;
    v_line                VARCHAR2(32767) := NULL;
    v_line_num            NUMBER := 0;
    v_char                CHAR(1);
    v_raw_chunk           RAW(10000);
    v_group_quit_file_row group_quit_file_row%ROWTYPE;
  BEGIN
    SAVEPOINT Before_Load;
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
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
            v_group_quit_file_row := NULL;
            SELECT sq_group_quit_file_row.NEXTVAL
              INTO v_group_quit_file_row.group_quit_file_row_id
              FROM dual;
            v_group_quit_file_row.load_file_id := par_load_file_id;
            v_group_quit_file_row.status       := 0;
            -- проход по полям
            FOR i IN va_values.FIRST .. va_values.LAST
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_group_quit_file_row.pol_num := va_values(i);
                WHEN i = 2 THEN
                  v_group_quit_file_row.ids := TO_NUMBER(TRANSLATE(va_values(i), ',.', '..')
                                                        ,'9999999999');
                WHEN i = 3 THEN
                  v_group_quit_file_row.issuer_name := va_values(i);
                WHEN i = 4 THEN
                  v_group_quit_file_row.start_date := TO_DATE(va_values(i), 'DD.MM.YYYY');
                WHEN i = 5 THEN
                  v_group_quit_file_row.pay_term_name := va_values(i);
                WHEN i = 6 THEN
                  v_group_quit_file_row.fund_brief := va_values(i);
                WHEN i = 7 THEN
                  v_group_quit_file_row.rate_act_date := TO_NUMBER(TRANSLATE(va_values(i), ',.', '..')
                                                                  ,'9999999999.99');
                WHEN i = 8 THEN
                  v_group_quit_file_row.rate_return_date := TO_NUMBER(TRANSLATE(va_values(i)
                                                                               ,',.'
                                                                               ,'..')
                                                                     ,'9999999999.99');
                WHEN i = 9 THEN
                  v_group_quit_file_row.region_name := va_values(i);
                WHEN i = 10 THEN
                  v_group_quit_file_row.product_conds_desc := va_values(i);
                WHEN i = 11 THEN
                  v_group_quit_file_row.decline_date := TO_DATE(va_values(i), 'DD.MM.YYYY');
                WHEN i = 12 THEN
                  v_group_quit_file_row.decline_reason_name := va_values(i);
                  -- 13-ый столбец не грузим    
              -- 14-ый столбец не грузим  
                WHEN i = 15 THEN
                  v_group_quit_file_row.debt_fee_sum := TO_NUMBER(TRANSLATE(va_values(i), ',.', '..')
                                                                 ,'9999999999.99');
                WHEN i = 16 THEN
                  v_group_quit_file_row.debt_fee_fact := TO_NUMBER(TRANSLATE(va_values(i), ',.', '..')
                                                                  ,'9999999999.99');
                WHEN i = 17 THEN
                  v_group_quit_file_row.medo_cost := TO_NUMBER(TRANSLATE(va_values(i), ',.', '..')
                                                              ,'9999999999.99');
                WHEN i = 18 THEN
                  v_group_quit_file_row.overpayment := TO_NUMBER(TRANSLATE(va_values(i), ',.', '..')
                                                                ,'9999999999.99');
                ELSE
                  NULL;
              END CASE;
            END LOOP;
            INSERT INTO group_quit_file_row
              (group_quit_file_row_id
              ,load_file_id
              ,pol_num
              ,ids
              ,issuer_name
              ,start_date
              ,pay_term_name
              ,fund_brief
              ,rate_act_date
              ,rate_return_date
              ,region_name
              ,product_conds_desc
              ,decline_date
              ,decline_reason_name
              ,debt_fee_sum
              ,debt_fee_fact
              ,medo_cost
              ,overpayment
              ,status
              ,load_date
              ,user_name)
            VALUES
              (v_group_quit_file_row.group_quit_file_row_id
              ,v_group_quit_file_row.load_file_id
              ,v_group_quit_file_row.pol_num
              ,v_group_quit_file_row.ids
              ,v_group_quit_file_row.issuer_name
              ,v_group_quit_file_row.start_date
              ,v_group_quit_file_row.pay_term_name
              ,v_group_quit_file_row.fund_brief
              ,v_group_quit_file_row.rate_act_date
              ,v_group_quit_file_row.rate_return_date
              ,v_group_quit_file_row.region_name
              ,v_group_quit_file_row.product_conds_desc
              ,v_group_quit_file_row.decline_date
              ,v_group_quit_file_row.decline_reason_name
              ,v_group_quit_file_row.debt_fee_sum
              ,v_group_quit_file_row.debt_fee_fact
              ,v_group_quit_file_row.medo_cost
              ,v_group_quit_file_row.overpayment
              ,v_group_quit_file_row.status
              ,SYSDATE
              ,USER);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
    --EXCEPTION
    --  WHEN others THEN
    --  ROLLBACK TO Before_Load;
    --    RAISE_APPLICATION_ERROR(-20001, 
    --      'Ошибка при выполнении Load_BLOB_To_Table ' || SQLERRM );        
  END Load_BLOB_To_Table;
  ----========================================================================----
  -- Процедура прекращения ДС по данным соответствующего файла
  PROCEDURE Quit_Policy
  (
    par_pol_num             VARCHAR2
   ,par_ids                 NUMBER
   ,par_issuer_name         VARCHAR2
   ,par_start_date          DATE
   ,par_pay_term_name       VARCHAR2
   ,par_fund_brief          VARCHAR2
   ,par_rate_act_date       NUMBER
   ,par_rate_return_date    NUMBER
   ,par_region_name         VARCHAR2
   ,par_product_conds_desc  VARCHAR2
   ,par_decline_date        DATE
   ,par_decline_reason_name VARCHAR2
   ,par_debt_fee_sum        NUMBER
   ,par_debt_fee_fact       NUMBER
   ,par_medo_cost           NUMBER
   ,par_overpayment         NUMBER
  ) IS
    v_pol_header_id         NUMBER;
    v_last_policy_id        NUMBER;
    v_quit_policy_id        NUMBER;
    v_ret                   NUMBER;
    v_pol_decline_id        NUMBER;
    v_product_conds_id      NUMBER;
    v_product_id            NUMBER;
    v_decline_reason_id     NUMBER;
    v_reg_code              NUMBER;
    v_issuer_return_sum     NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_return_summ           NUMBER;
    CURSOR cover_curs(pcurs_pol_decline_id NUMBER) IS
      SELECT cd.p_cover_decline_id
            ,cd.as_asset_id
            ,cd.t_product_line_id
        FROM p_cover_decline cd
       WHERE cd.p_pol_decline_id = pcurs_pol_decline_id;
  BEGIN
    -- ID заголовка договора
    BEGIN
      SELECT ph.policy_header_id
            ,product_id
        INTO v_pol_header_id
            ,v_product_id
        FROM p_pol_header ph
       WHERE ph.ids = par_ids;
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найден договор с ИДС ' || TO_CHAR(par_ids));
      WHEN too_many_rows THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Найдено несколько договоров с ИДС ' ||
                                TO_CHAR(par_ids));
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_pol_header_id): ' || SQLERRM);
    END;
    -- ID последней версии договора
    BEGIN
      SELECT p.policy_id
        INTO v_last_policy_id
        FROM p_policy p
       WHERE p.pol_header_id = v_pol_header_id
         AND p.version_num = (SELECT MAX(p2.version_num)
                                FROM ins.p_policy       p2
                                    ,ins.document       d
                                    ,ins.doc_status_ref rf
                               WHERE p2.pol_header_id = v_pol_header_id
                                 AND p2.policy_id = d.document_id
                                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                                 AND rf.brief != 'CANCEL');
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найден ID последней версии договора');
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_last_policy_id): ' || SQLERRM);
    END;
    BEGIN
      IF DOC.Get_Doc_Status_Brief(v_last_policy_id) = 'INDEXATING'
      THEN
        -- "Индексация"
        DOC.Set_Doc_Status(v_last_policy_id, 'NEW', SYSDATE - (2 / (24 * 60 * 60))); -- "Новый"
        DOC.Set_Doc_Status(v_last_policy_id, 'CURRENT', SYSDATE - (1 / (24 * 60 * 60))); -- "Действующий"
        /*ELSIF DOC.Get_Doc_Status_Brief( v_last_policy_id ) = 
          'PASSED_TO_AGENT' THEN -- "Передано Агенту" 
        DOC.Set_Doc_Status( v_last_policy_id, 'PRINTED', 
          SYSDATE - ( 2 / ( 24 * 60 * 60 ) ) ); -- "Напечатан"
        DOC.Set_Doc_Status( v_last_policy_id, 'CURRENT', 
          SYSDATE - ( 1 / ( 24 * 60 * 60 ) ) ); -- "Действующий"   */
      ELSIF DOC.Get_Doc_Status_Brief(v_last_policy_id) = 'CONCLUDED'
      THEN
        -- "Договор подписан" 
        DOC.Set_Doc_Status(v_last_policy_id, 'CURRENT', SYSDATE - (1 / (24 * 60 * 60))); -- "Действующий" 
      ELSIF DOC.Get_Doc_Status_Brief(v_last_policy_id) = 'STOPED'
      THEN
        -- "Завершен" 
        DOC.Set_Doc_Status(v_last_policy_id, 'CURRENT', SYSDATE - (1 / (24 * 60 * 60))); -- "Действующий"    
      ELSIF DOC.Get_Doc_Status_Brief(v_last_policy_id) = 'PROJECT'
      THEN
        -- "Проект"
        DOC.Set_Doc_Status(v_last_policy_id, 'NEW', SYSDATE - (2 / (24 * 60 * 60))); -- "Новый"
        DOC.Set_Doc_Status(v_last_policy_id, 'CURRENT', SYSDATE - (1 / (24 * 60 * 60))); -- "Действующий"   
        --Чирков 178310: групповое расторжение договоров    
      ELSIF DOC.Get_Doc_Status_Brief(v_last_policy_id) = 'PASSED_TO_AGENT'
      THEN
        -- "Передано Агенту" 
        DOC.Set_Doc_Status(v_last_policy_id, 'CONCLUDED', SYSDATE - (2 / (24 * 60 * 60))); --Договор подписан       
        DOC.Set_Doc_Status(v_last_policy_id, 'CURRENT', SYSDATE - (1 / (24 * 60 * 60))); -- "Действующий"          
        -------------------------------------------    
      END IF;
      DOC.Set_Doc_Status(v_last_policy_id, 'QUIT_DECL'); -- "Заявление 
      --  на прекращение"
      --EXCEPTION
      --WHEN others THEN  
      --Raise_Application_Error( -20001, 
      --'Ошибка Quit_Policy (Set_Doc_Status): ' || SQLERRM );   
    END;
    -- новая версия в статусе "К прекращению":
    v_ret := PKG_POLICY.New_Policy_Version(v_last_policy_id, NULL, 'TO_QUIT');
    -- ID прекращаемой версии договора
    BEGIN
      SELECT p.policy_id
        INTO v_quit_policy_id
        FROM p_policy p
       WHERE p.pol_header_id = v_pol_header_id
         AND p.version_num = (SELECT MAX(p2.version_num)
                                FROM ins.p_policy       p2
                                    ,ins.document       d
                                    ,ins.doc_status_ref rf
                               WHERE p2.pol_header_id = v_pol_header_id
                                 AND p2.policy_id = d.document_id
                                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                                 AND rf.brief != 'CANCEL');
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найден ID прекращаемой версии договора');
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_quit_policy_id): ' || SQLERRM);
    END;
    -- Добавить новую запись в таблицу данных для расторжения
    BEGIN
      PKG_POLICY_QUIT.Add_Pol_Decline(v_quit_policy_id);
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (Add_Pol_Decline): ' || SQLERRM);
    END;
    -- Добавить строки в таблицу "Прекращение договора. Данные по программам"
    BEGIN
      PKG_POLICY_QUIT.Add_Cover_Decline(v_quit_policy_id);
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (Add_Cover_Decline): ' || SQLERRM);
    END;
    -- Найти p_pol_decline_id
    BEGIN
      SELECT pd.p_pol_decline_id
        INTO v_pol_decline_id
        FROM p_pol_decline pd
       WHERE pd.p_policy_id = v_quit_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найдено p_pol_decline_id');
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_pol_decline_id): ' || SQLERRM);
    END;
    -- Полисные условия
    BEGIN
      SELECT pc.t_policyform_product_id /*t_product_conds_id*/
        INTO v_product_conds_id
        FROM t_policyform_product pc
            , /*t_product_conds*/t_policy_form        f
       WHERE pc.t_policy_form_id = f.t_policy_form_id
         AND REPLACE(REPLACE(REPLACE(TRIM(f.t_policy_form_name), '"', ''), '«', ''), '»', '') =
             REPLACE(REPLACE(REPLACE(TRIM(par_product_conds_desc), '"', ''), '«', ''), '»', '')
         AND pc.t_product_id = v_product_id;
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найдены полисные условия');
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_product_conds_id): ' || SQLERRM);
    END;
    -- Причина расторжения ДС
    BEGIN
      SELECT t_decline_reason_id
        INTO v_decline_reason_id
        FROM t_decline_reason
       WHERE NAME = par_decline_reason_name;
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найдена причина расторжения ДС');
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_product_conds_id): ' || SQLERRM);
    END;
    -- Заполнение таблицы по застрахованным/программам
    BEGIN
      FOR cover_rec IN cover_curs(v_pol_decline_id)
      LOOP
        PKG_POLICY_QUIT.Fill_Cover_Decline_Line(v_quit_policy_id
                                               ,cover_rec.p_cover_decline_id
                                               ,cover_rec.as_asset_id
                                               ,cover_rec.t_product_line_id
                                               ,par_decline_date);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy (Fill_Cover_Decline_Line): ' || SQLERRM);
    END;
    BEGIN
      SELECT SUM(redemption_sum)
            ,SUM(add_invest_income)
            ,SUM(return_bonus_part)
        INTO v_sum_redemption_sum
            ,v_sum_add_invest_income
            ,v_sum_return_bonus_part
        FROM p_cover_decline
       WHERE p_pol_decline_id = v_pol_decline_id;
      v_issuer_return_sum := NVL(v_sum_redemption_sum, 0) + NVL(v_sum_add_invest_income, 0) +
                             NVL(v_sum_return_bonus_part, 0);
      v_return_summ       := NVL(v_issuer_return_sum, 0) + NVL(par_overpayment, 0) -
                             NVL(par_debt_fee_sum, 0) - NVL(par_medo_cost, 0);
      -- - NVL( :DB_DECLINE.admin_expenses, 0 )
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (v_issuer_return_sum): ' || SQLERRM);
    END;
    BEGIN
      SELECT reg_code INTO v_reg_code FROM organisation_tree WHERE NAME = par_region_name;
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy: Не найден код региона');
      WHEN too_many_rows THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy:  код региона');
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (reg_code): ' || SQLERRM);
    END;
    -- Заполнение других данных по расторжению
    BEGIN
      UPDATE p_policy
         SET decline_date      = par_decline_date
            ,debt_summ         = par_debt_fee_sum
            ,decline_reason_id = v_decline_reason_id
            ,return_summ       = v_return_summ
       WHERE policy_id = v_quit_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(-20001, 'Ошибка Quit_Policy (UPDATE p_policy): ' || SQLERRM);
    END;
    IF NVL(SQL%ROWCOUNT, 0) = 0
    THEN
      Raise_Application_Error(-20001
                             ,'Ошибка Quit_Policy (UPDATE p_policy): Не обновлены данные');
    END IF;
    BEGIN
      UPDATE p_pol_decline
         SET t_product_conds_id = v_product_conds_id
            ,debt_fee_fact      = par_debt_fee_fact
            ,medo_cost          = par_medo_cost
            ,overpayment        = par_overpayment
            ,reg_code           = v_reg_code
            ,issuer_return_sum  = v_issuer_return_sum
            ,act_date           = TRUNC(SYSDATE)
       WHERE p_pol_decline_id = v_pol_decline_id;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(-20001
                               ,'Ошибка Quit_Policy (UPDATE p_pol_decline): ' || SQLERRM);
    END;
    IF NVL(SQL%ROWCOUNT, 0) = 0
    THEN
      Raise_Application_Error(-20001
                             ,'Ошибка Quit_Policy (UPDATE p_pol_decline): Не обновлены данные');
    END IF;
  END Quit_Policy;
  ----========================================================================----
END PKG_GROUP_QUIT;
/
