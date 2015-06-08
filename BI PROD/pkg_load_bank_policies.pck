CREATE OR REPLACE PACKAGE pkg_load_bank_policies IS

  -- Author  : Пиядин А.
  -- Created : 16.07.2014
  -- Purpose : 223809 Проект ФТ по договорам кредитного страхования

  /*
    Процедура проверки данных
  */
  PROCEDURE check_load_bank_policy(par_load_file_id load_file.load_file_id%TYPE);

  /*
    Процедура загрузки данных
  */
  PROCEDURE load_bank_policy(par_load_file_id load_file.load_file_id%TYPE);

END pkg_load_bank_policies;
/
CREATE OR REPLACE PACKAGE BODY pkg_load_bank_policies IS

  PROCEDURE check_load_bank_policy(par_load_file_id load_file.load_file_id%TYPE) IS
    gv_log_order_num NUMBER;
  
    -- Процедура проверки критичных ошибок с БСО
    FUNCTION check_bso_critical_errors(par_load_file_id load_file.load_file_id%TYPE) RETURN NUMBER IS
      bso_series load_file_rows.val_1%TYPE := NULL;
      v_agent    load_file_rows.val_1%TYPE := NULL;
    
      c_dummy_bso_holder_name contact.obj_name_orig%TYPE := 'Владелец Фиктивных Бсо';
      v_dummy_contact_id      contact.contact_id%TYPE := NULL;
      v_agent_id              contact.contact_id%TYPE;
      v_bso_free_cnt          NUMBER;
      v_bso_num_cnt           NUMBER;
    
      e_bso_free_not_exists EXCEPTION;
      e_bso_free_used       EXCEPTION;
    
      -- Функция определения контакта агента по номеру АД
      FUNCTION get_agent_id(par_ag_contact_num VARCHAR2) RETURN contact.contact_id%TYPE IS
        v_agent_contact_id contact.contact_id%TYPE;
      BEGIN
        BEGIN
          SELECT agent_id
            INTO v_agent_contact_id
            FROM ven_ag_contract_header ah
                ,doc_status_ref         dsr
           WHERE num = par_ag_contact_num
             AND ah.doc_status_ref_id = dsr.doc_status_ref_id
             AND ah.is_new = 1
             AND dsr.brief = 'CURRENT';
          RETURN v_agent_contact_id;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось определить агента по номеру: ' ||
                                    nvl(par_ag_contact_num, 'NULL'));
        END;
      END get_agent_id;
    
    BEGIN
      BEGIN
        SELECT contact_id
          INTO v_dummy_contact_id
          FROM contact c
         WHERE c.obj_name_orig = c_dummy_bso_holder_name;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      /*
        14.2 Если значение в данном поле равно значению «NO NUM», то в БД существует кол-во БСО в статусе «Передан»
             равное кол-ву записей в таблице, с серией, равной значению параметра «серия БСО» правила загрузки.
      */
      FOR cur IN (SELECT COUNT(*) bso_num_cnt
                        ,pkg_load_file_to_table.get_value_by_brief('BSO_SERIES', lfr.load_file_rows_id) bso_series
                        ,pkg_load_file_to_table.get_value_by_brief('AGENT', lfr.load_file_rows_id) AGENT
                    FROM load_file_rows lfr
                   WHERE 1 = 1
                     AND lfr.load_file_id = par_load_file_id
                     AND lfr.row_status IN (pkg_load_file_to_table.get_checked
                                           ,pkg_load_file_to_table.get_error
                                           ,pkg_load_file_to_table.get_nc_error)
                     AND pkg_load_file_to_table.get_value_by_brief('BSO_NUM', lfr.load_file_rows_id) =
                         'NO NUM'
                   GROUP BY pkg_load_file_to_table.get_value_by_brief('BSO_SERIES'
                                                                     ,lfr.load_file_rows_id)
                           ,pkg_load_file_to_table.get_value_by_brief('AGENT', lfr.load_file_rows_id))
      LOOP
        bso_series    := cur.bso_series;
        v_agent       := cur.agent;
        v_bso_num_cnt := cur.bso_num_cnt;
      
        IF cur.agent IS NOT NULL
        THEN
          v_agent_id := get_agent_id(cur.agent);
        END IF;
      
        SELECT COUNT(*) /*+leading (bs, bht, b) use_nl(bs, bht, b) */
          INTO v_bso_free_cnt
          FROM bso           b
              ,bso_series    bs
              ,bso_hist_type bht
         WHERE b.bso_series_id = bs.bso_series_id
           AND bs.series_num = to_number(cur.bso_series)
           AND b.contact_id IN (v_agent_id, v_dummy_contact_id)
           AND b.hist_type_id = bht.bso_hist_type_id
           AND bht.brief = 'Передан';
      
        IF v_bso_free_cnt = 0
        THEN
          RAISE e_bso_free_used;
        END IF;
      
        IF cur.bso_num_cnt > v_bso_free_cnt
        THEN
          RAISE e_bso_free_not_exists;
        END IF;
      END LOOP;
    
      RETURN 1;
    
    EXCEPTION
      WHEN e_bso_free_used THEN
        FOR cur_rows IN (SELECT lfr.load_file_rows_id
                           FROM load_file_rows lfr
                          WHERE lfr.load_file_id = par_load_file_id
                            AND lfr.row_status IN
                                (pkg_load_file_to_table.get_checked
                                ,pkg_load_file_to_table.get_error
                                ,pkg_load_file_to_table.get_nc_error))
        LOOP
          pkg_load_logging.set_critical_error(par_load_file_rows_id => cur_rows.load_file_rows_id
                                              
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FREE_BSO_EXISTS')
                                             ,par_log_msg              => 'В БД отсутствует свободный БСО с серией ' ||
                                                                          nvl(bso_series, 'NULL') ||
                                                                          ' для агента ' ||
                                                                          nvl(v_agent, 'NULL')
                                             ,par_load_stage           => pkg_load_logging.get_check_group);
        END LOOP;
        RETURN 0;
      
      WHEN e_bso_free_not_exists THEN
        FOR cur_rows IN (SELECT lfr.load_file_rows_id
                           FROM load_file_rows lfr
                          WHERE lfr.load_file_id = par_load_file_id
                            AND lfr.row_status IN
                                (pkg_load_file_to_table.get_checked
                                ,pkg_load_file_to_table.get_error
                                ,pkg_load_file_to_table.get_nc_error))
        LOOP
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => cur_rows.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FREE_BSO_EXISTS')
                                             ,par_log_msg              => 'В БД отсутствует свободный БСО с серией ' ||
                                                                          bso_series || ' (свободно ' ||
                                                                          v_bso_free_cnt ||
                                                                          ', требуется ' ||
                                                                          v_bso_num_cnt || ')'
                                             ,par_load_stage           => pkg_load_logging.get_check_group);
        END LOOP;
        RETURN 0;
    END check_bso_critical_errors;
  
    -- Процедура проверки критичных условий
    PROCEDURE critical_errors_check(par_file_row load_file_rows%ROWTYPE) IS
      v_continue        NUMBER := 1;
      v_doc_type        load_file_rows.val_1%TYPE := NULL;
      v_doc_ser         load_file_rows.val_1%TYPE := NULL;
      v_doc_num         load_file_rows.val_1%TYPE := NULL;
      v_doc_issued_by   load_file_rows.val_1%TYPE := NULL;
      v_doc_issued_date DATE;
      v_birth_date      DATE;
      v_address         load_file_rows.val_1%TYPE := NULL;
      v_telephone       load_file_rows.val_1%TYPE := NULL;
      v_policy_num      load_file_rows.val_1%TYPE := NULL;
      v_product         load_file_rows.val_1%TYPE := NULL;
      v_bso_num         load_file_rows.val_1%TYPE := NULL;
      v_bso_series      load_file_rows.val_1%TYPE := NULL;
      v_signing_date    DATE;
      v_start_date      DATE;
      v_end_date        DATE;
      v_name            load_file_rows.val_1%TYPE := NULL;
      v_first_name      load_file_rows.val_1%TYPE := NULL;
      v_middle_name     load_file_rows.val_1%TYPE := NULL;
      v_ins_sum         load_file_rows.val_1%TYPE := NULL;
      v_ins_prem        load_file_rows.val_1%TYPE := NULL;
      v_currency        load_file_rows.val_1%TYPE := NULL;
      v_credit_num      load_file_rows.val_1%TYPE := NULL;
    
      id_mask VARCHAR2(255);
      sn_mask VARCHAR2(255);
    
      /*
        Проверка 4.1 Значение в данном поле меньше текущей даты
      */
      PROCEDURE check_date_future
      (
        par_date        DATE
       ,par_column_name VARCHAR2
      ) IS
      BEGIN
        IF par_date IS NOT NULL
        THEN
          IF par_date > SYSDATE
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                               ,par_log_msg              => 'В поле «' ||
                                                                            par_column_name ||
                                                                            '» указана дата в будущем: ' ||
                                                                            to_char(par_date
                                                                                   ,'DD.MM.YYYY')
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_date_future;
    
      /*
        Проверка 4.2 «Текущая дата - Значение в данном поле» – значение должно быть меньше 100 лет
      */
      PROCEDURE check_date_eld
      (
        par_date        DATE
       ,par_column_name VARCHAR2
      ) IS
      BEGIN
        IF par_date IS NOT NULL
        THEN
          IF FLOOR(MONTHS_BETWEEN(SYSDATE, par_date) / 12) >= 100
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                               ,par_log_msg              => 'В поле «' ||
                                                                            par_column_name ||
                                                                            '» указана дата в прошлом более 100 лет: ' ||
                                                                            to_char(par_date
                                                                                   ,'DD.MM.YYYY')
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_date_eld;
    
      /*
        Проверка 6.1 Значение, указанное в данном поле, существует в справочнике типов документов
      */
      PROCEDURE check_identity_doc_type_exists
      (
        par_doc_type    VARCHAR2
       ,par_sn_mask_out OUT VARCHAR2
       ,par_id_mask_out OUT VARCHAR2
      ) IS
        e_doc_type_not_exists EXCEPTION;
        v_continue NUMBER := 1;
      BEGIN
        IF par_doc_type IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1 FROM t_id_type WHERE brief = par_doc_type);
        
          IF v_continue = 0
          THEN
            RAISE e_doc_type_not_exists;
          END IF;
        END IF;
      
        IF par_doc_type IS NOT NULL
        THEN
          BEGIN
            SELECT tf.serial_nr_mask
                  ,tf.id_value_mask
              INTO par_sn_mask_out
                  ,par_id_mask_out
              FROM t_id_type        t
                  ,t_id_type_format tf
             WHERE t.brief = par_doc_type
               AND tf.t_id_type_format_id = t.id_type_format_id;
          EXCEPTION
            WHEN no_data_found THEN
              RAISE e_doc_type_not_exists;
          END;
        END IF;
      
      EXCEPTION
        WHEN e_doc_type_not_exists THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                             ,par_log_msg              => 'В поле «Документ» указано несуществующее значение «' ||
                                                                          par_doc_type || '»'
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
      END check_identity_doc_type_exists;
    
      /*
        Проверка 7.1 Если в данном поле указано какое-либо значение, оно должно соответствовать требованиям типовой
        проверки серии вида документа указанного в поле с брифом doc_type
      */
      PROCEDURE check_doc_serial_format
      (
        par_doc_type      VARCHAR2
       ,par_serial        VARCHAR2
       ,par_serial_format VARCHAR2
      ) IS
        e_doc_ser_format EXCEPTION;
        v_continue NUMBER := 1;
        err_txt    VARCHAR2(255);
      BEGIN
        IF par_doc_type IS NOT NULL
           AND par_serial IS NOT NULL
        THEN
          pkg_contact.validate_from_mask(par_serial, par_serial_format, v_continue, err_txt);
          IF v_continue = 0
          THEN
            RAISE e_doc_ser_format;
          END IF;
        
          IF par_doc_type = 'PASS_RF'
          THEN
            SELECT COUNT(*)
              INTO v_continue
              FROM t_desc_codepass p
             WHERE p.code_pass = substr(par_serial, 1, 2);
          
            IF v_continue = 0
            THEN
              RAISE e_doc_ser_format;
            END IF;
          END IF;
        END IF;
      
      EXCEPTION
        WHEN e_doc_ser_format THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                             ,par_log_msg              => 'В поле «Серия документа» указано некорректное значение: «' ||
                                                                          par_serial || '»'
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
      END check_doc_serial_format;
    
      /*
        Проверка 8.1 Если в данном поле указано какое-либо значение, оно должно соответствовать требованиям типовой
        проверки номера вида документа указанного в поле с брифом doc_type
      */
      PROCEDURE check_doc_num_format
      (
        par_doc_type   VARCHAR2
       ,par_num        VARCHAR2
       ,par_num_format VARCHAR2
      ) IS
        v_continue NUMBER := 1;
        err_txt    VARCHAR2(255);
      BEGIN
        IF par_doc_type IS NOT NULL
           AND par_num IS NOT NULL
        THEN
          pkg_contact.validate_from_mask(par_num, par_num_format, v_continue, err_txt);
          IF v_continue = 0
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                               ,par_log_msg              => 'В поле «Номер документа» указано некорректное значение: «' ||
                                                                            par_num || '»'
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_doc_num_format;
    
      /*
        Процедура проверки наличия латинских символов в тексте
      */
      PROCEDURE check_latin_letters_exists
      (
        par_text        VARCHAR2
       ,par_column_name VARCHAR2
      ) IS
      BEGIN
        IF par_text IS NOT NULL
           AND TRIM(upper(par_text)) <>
           TRIM(translate(upper(par_text), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', ' '))
        THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_LATIN_LETTERS_EXISTS')
                                             ,par_log_msg              => 'В поле «' ||
                                                                          par_column_name ||
                                                                          '» присутствуют латинские символы (' ||
                                                                          par_text || ')'
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
        END IF;
      END check_latin_letters_exists;
    
      /*
        Проверка 10.3 Если в данном поле указано какое-либо значение, то: значение в данном поле должно быть
        больше или равно значению в поле с брифом birth_date + 14 лет
      */
      PROCEDURE check_doc_issue_date_vs_birth
      (
        par_doc_issue_date DATE
       ,par_birth_date     DATE
      ) IS
      BEGIN
        IF par_doc_issue_date IS NOT NULL
        THEN
          IF par_birth_date IS NOT NULL
             AND FLOOR(MONTHS_BETWEEN(par_doc_issue_date, par_birth_date) / 12) < 14
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                               ,par_log_msg              => 'Паспорт не выдается лицу не достигшему 14 лет'
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_doc_issue_date_vs_birth;
    
      /*
        Проверка 12.1 Если какое-либо значение в данном поле указано, то: в данном поле существует 10 или более цифровых символов
      */
      PROCEDURE check_telephone_format(par_telephone_num VARCHAR2) IS
      BEGIN
        IF par_telephone_num IS NOT NULL
           AND
           (nvl(length(TRIM(translate(upper(par_telephone_num)
                                     ,'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ- '
                                     ,' ')))
               ,0) < 10 OR TRIM(translate(upper(par_telephone_num)
                                          ,'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ- '
                                          ,' ')) <> TRIM(par_telephone_num))
        THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                             ,par_log_msg              => 'В поле «Телефон» должно быть указано только 10 цифр (' ||
                                                                          par_telephone_num || ')'
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
        END IF;
      END check_telephone_format;
    
      /*
        Проверка 13.1 В БД отсутствуют ДС с номером ДС, равным значению в данном поле и Продуктом,
        указанным в параметре «Продукт» и статусом активной версии отличным от отменен.
      */
      PROCEDURE check_product_pol_num_unique
      (
        par_product VARCHAR2
       ,par_pol_num VARCHAR2
      ) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_pol_num IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1
                    FROM p_policy     pp
                        ,p_pol_header ph
                        ,t_product    pr
                   WHERE 1 = 1
                     AND pp.pol_header_id = ph.policy_header_id
                     AND ph.product_id = pr.product_id
                     AND pp.pol_num = par_pol_num
                     AND pr.brief = nvl(par_product, pr.brief));
          IF v_continue > 0
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_UNIQUE')
                                               ,par_log_msg              => 'В БД уже существует ДС с таким же номером ДС (' ||
                                                                            par_pol_num ||
                                                                            ') и продуктом (' ||
                                                                            par_product || ')'
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_product_pol_num_unique;
    
      /*
        Проверка 14.1 Значение в данном поле соответствует маске «NNNNNN» (но не равно «000000») или равно значению «NO NUM»
      */
      PROCEDURE check_bso_num(par_bso_num VARCHAR2) IS
      BEGIN
        IF par_bso_num IS NOT NULL
           AND NOT ((par_bso_num = regexp_substr(par_bso_num, '^[0-9]{6}') AND par_bso_num <> '000000') OR
            par_bso_num = 'NO NUM')
        THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                             ,par_log_msg              => 'В поле «Номер БСО» указано неверное значение: (' ||
                                                                          par_bso_num || ')'
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
        END IF;
      END check_bso_num;
    
      /*
        Проверка 14.3 Если значение в данном поле не равно значению «NO NUM», то в БД существует БСО с серией, равной
        значению параметра «серия БСО» и номером, равным значению в данном поле
      */
      PROCEDURE check_bso_exists
      (
        par_bso_num    VARCHAR2
       ,par_bso_series VARCHAR2
      ) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_bso_num IS NOT NULL
           AND par_bso_num <> 'NO NUM'
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1
                    FROM bso        b
                        ,bso_series bs
                   WHERE 1 = 1
                     AND b.bso_series_id = bs.bso_series_id
                     AND b.num = par_bso_num
                     AND bs.series_num = to_number(par_bso_series));
        
          IF v_continue = 0
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_BSO_EXISTS')
                                               ,par_log_msg              => 'В БД отсутствует БСО с серией ' ||
                                                                            par_bso_series ||
                                                                            ' и номером ' ||
                                                                            nvl(par_bso_num, 'NULL')
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_bso_exists;
    
      /*
        Проверка 14.4 Если удовлетворяется предыдущее условие, то в БД существует БСО в статусе «Передан» с серией, равной
        значению параметра «серия БСО» и номером, равным значению в данном поле
      */
      PROCEDURE check_bso_used
      (
        par_bso_num    VARCHAR2
       ,par_bso_series VARCHAR2
      ) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_bso_num IS NOT NULL
           AND par_bso_num <> 'NO NUM'
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1
                    FROM bso        b
                        ,bso_series bs
                   WHERE 1 = 1
                     AND b.bso_series_id = bs.bso_series_id
                     AND b.num = par_bso_num
                     AND bs.series_num = to_number(par_bso_series));
        
          IF v_continue <> 0
          THEN
            SELECT COUNT(*)
              INTO v_continue
              FROM dual
             WHERE EXISTS (SELECT 1
                      FROM bso           b
                          ,bso_series    bs
                          ,bso_hist_type ht
                     WHERE 1 = 1
                       AND b.bso_series_id = bs.bso_series_id
                       AND b.hist_type_id = ht.bso_hist_type_id
                       AND ht.brief = 'Передан'
                       AND b.num = par_bso_num
                       AND bs.series_num = to_number(par_bso_series));
          
            IF v_continue = 0
            THEN
              pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                                 ,par_load_order_num       => gv_log_order_num
                                                 ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FREE_BSO_EXISTS')
                                                 ,par_log_msg              => 'В БД отсутствует свободный БСО с серией ' ||
                                                                              par_bso_series ||
                                                                              ' и номером ' ||
                                                                              par_bso_num
                                                 ,par_load_stage           => pkg_load_logging.get_check_single);
            END IF;
          END IF;
        END IF;
      END check_bso_used;
    
      /*
        Проверка превышения первой даты по сравнению со второй
      */
      PROCEDURE check_date1_grater_than_date2
      (
        par_date1        DATE
       ,par_date2        DATE
       ,par_column1_name VARCHAR2
       ,par_column2_name VARCHAR2
      ) IS
      BEGIN
        IF par_date1 IS NOT NULL
           AND par_date2 IS NOT NULL
        THEN
          IF par_date1 > par_date2
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                               ,par_log_msg              => 'В поле «' ||
                                                                            par_column1_name ||
                                                                            '» указана дата ' ||
                                                                            to_char(par_date1
                                                                                   ,'DD.MM.YYYY') ||
                                                                            ', которая позже даты в поле «' ||
                                                                            par_column2_name || '» ' ||
                                                                            to_char(par_date2
                                                                                   ,'DD.MM.YYYY')
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_date1_grater_than_date2;
    
      /*
        Проверка неортрицательного значения
      */
      PROCEDURE check_negative_value
      (
        par_value       VARCHAR2
       ,par_column_name VARCHAR2
      ) IS
      BEGIN
        IF par_value IS NOT NULL
           AND to_number(REPLACE(REPLACE(par_value, ' '), ',', '.')
                        ,'9999999999999D9999999999999'
                        ,'NLS_NUMERIC_CHARACTERS = ''.,''') <= 0
        THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                             ,par_log_msg              => 'В поле «' ||
                                                                          par_column_name ||
                                                                          '» указано значение (' ||
                                                                          par_value ||
                                                                          '), которое меньше или равно 0'
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
        END IF;
      END check_negative_value;
    
      /*
        Проверка 20.1 В таблице «Справочник валют» существует запись со значением в поле «Символьный код», равным значению данного поля
      */
      PROCEDURE check_currency_exists(par_currency_brief VARCHAR2) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_currency_brief IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1 FROM fund WHERE brief = par_currency_brief);
          IF v_continue = 0
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                               ,par_log_msg              => 'В поле «Валюта» указан код валюты (' ||
                                                                            par_currency_brief ||
                                                                            '), отсутствующий в Справочнике валют'
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_currency_exists;
    
      /*
        Проверка 21.1 Если в данном поле указано значение, то: в данном файле-источнике не существует
        строк с идентичными значениями в данном поле.
      */
      PROCEDURE check_column_value_doubles
      (
        par_value        VARCHAR2
       ,par_column_brief VARCHAR2
       ,par_column_name  VARCHAR2
      ) IS
        v_load_file_rows dml_load_file_rows.tt_load_file_rows;
        v_continue       NUMBER := 1;
      BEGIN
        IF par_value IS NOT NULL
        THEN
          v_load_file_rows := dml_load_file_rows.get_record(par_file_row.load_file_rows_id);
        
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS
           (SELECT 1
                    FROM load_file_rows
                   WHERE 1 = 1
                     AND load_file_id = v_load_file_rows.load_file_id
                     AND load_file_rows_id <> par_file_row.load_file_rows_id
                     AND row_status IN (pkg_load_file_to_table.get_checked
                                       ,pkg_load_file_to_table.get_error
                                       ,pkg_load_file_to_table.get_nc_error)
                     AND pkg_load_file_to_table.get_value_by_brief(par_column_brief, load_file_rows_id) =
                         par_value);
          IF v_continue > 0
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_COLUMN_DOUBLE_VALUE')
                                               ,par_log_msg              => 'В данном файле существует запись с таким же значением поля «' ||
                                                                            par_column_name || '»: «' ||
                                                                            par_value || '»'
                                               ,par_load_stage           => pkg_load_logging.get_check_group);
          END IF;
        END IF;
      END check_column_value_doubles;
    
      /*
        Проверка 21.2 В БД отсутствуют ДС с номером КД, равным значению в данном поле и Продуктом,
        указанным в параметре «Продукт»
      */
      PROCEDURE check_product_cred_num_unique
      (
        par_product    VARCHAR2
       ,par_credit_num VARCHAR2
      ) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_credit_num IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1
                    FROM p_pol_header ph
                        ,as_asset     ass
                        ,as_assured   asu
                        ,t_product    pr
                   WHERE 1 = 1
                     AND ph.product_id = pr.product_id
                     AND ph.policy_id = ass.p_policy_id
                     AND ass.as_asset_id = asu.as_assured_id
                     AND asu.credit_account_number = par_credit_num
                     AND pr.brief = nvl(par_product, pr.brief));
        
          IF v_continue > 0
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_UNIQUE')
                                               ,par_log_msg              => 'В БД уже существует ДС с таким же номером КД (' ||
                                                                            par_credit_num ||
                                                                            ') и Продуктом (' ||
                                                                            par_product || ')'
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_product_cred_num_unique;
    
      /*
        Проверка 22.1 Сумма всех значений равна 100
      */
      PROCEDURE check_benefic_percent IS
        v_continue NUMBER := 0;
      BEGIN
        pkg_load_file_to_table.cache_row(par_file_row.load_file_rows_id);
        IF pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_NAME') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_NAME') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_NAME') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_NAME') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_CONTACT_ID') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_CONTACT_ID') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_CONTACT_ID') IS NOT NULL
           OR pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_CONTACT_ID') IS NOT NULL
        THEN
          FOR cur_ben_perc IN (SELECT 'BENEFICIARY' || LEVEL || '_PERCENT' brief
                                 FROM dual
                               CONNECT BY LEVEL <= 4)
          LOOP
            v_continue := v_continue + nvl(to_number(pkg_load_file_to_table.get_value_by_brief(cur_ben_perc.brief))
                                          ,0);
          END LOOP;
        
          IF v_continue <> 100
          THEN
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_TOTAL_PERCENT')
                                               ,par_log_msg              => 'Для выгодоприобретателей допустимым значением доли является 100%. В загружаемых данных (' ||
                                                                            v_continue || ').'
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_benefic_percent;
    
    BEGIN
      FOR cur_doc_issue IN (SELECT 'INSUREE_DOC_TYPE' brief_doc_type
                                  ,'INSUREE_DOC_SER' brief_doc_ser
                                  ,'INSUREE_DOC_NUM' brief_doc_num
                                  ,'INSUREE_DOC_ISSUED_BY' brief_doc_issued_by
                                  ,'INSUREE_DOC_ISSUED_DATE' brief_doc_issued_date
                                  ,'INSUREE_BIRTH_DATE' brief_birth_date
                              FROM dual
                            UNION
                            SELECT 'ASSURED_DOC_TYPE'
                                  ,'ASSURED_DOC_SER'
                                  ,'ASSURED_DOC_NUM'
                                  ,'ASSURED_DOC_ISSUED_BY'
                                  ,'ASSURED_DOC_ISSUED_DATE'
                                  ,'ASSURED_BIRTH_DATE'
                              FROM dual
                            UNION
                            SELECT 'BENEFICIARY' || LEVEL || '_DOC_TYPE'
                                  ,'BENEFICIARY' || LEVEL || '_DOC_SER'
                                  ,'BENEFICIARY' || LEVEL || '_DOC_NUM'
                                  ,'BENEFICIARY' || LEVEL || '_DOC_ISSUED_BY'
                                  ,'BENEFICIARY' || LEVEL || '_DOC_ISSUED_DATE'
                                  ,'BENEFICIARY' || LEVEL || '_BIRTH_DATE'
                              FROM dual
                            CONNECT BY LEVEL <= 4)
      LOOP
        v_doc_type        := pkg_load_file_to_table.get_value_by_brief(cur_doc_issue.brief_doc_type);
        v_doc_ser         := pkg_load_file_to_table.get_value_by_brief(cur_doc_issue.brief_doc_ser);
        v_doc_num         := pkg_load_file_to_table.get_value_by_brief(cur_doc_issue.brief_doc_num);
        v_doc_issued_by   := pkg_load_file_to_table.get_value_by_brief(cur_doc_issue.brief_doc_issued_by);
        v_doc_issued_date := pkg_load_file_to_table.get_value_date(cur_doc_issue.brief_doc_issued_date);
        v_birth_date      := pkg_load_file_to_table.get_value_date(cur_doc_issue.brief_birth_date);
      
        -- Проверка даты
        -- 4.1
        check_date_future(par_date => v_birth_date, par_column_name => 'Дата рождения');
      
        -- 4.2
        check_date_eld(par_date => v_birth_date, par_column_name => 'Дата рождения');
      
        -- 6.1
        check_identity_doc_type_exists(par_doc_type    => v_doc_type
                                      ,par_sn_mask_out => sn_mask
                                      ,par_id_mask_out => id_mask);
      
        -- 7.1
        check_doc_serial_format(par_doc_type      => v_doc_type
                               ,par_serial        => v_doc_ser
                               ,par_serial_format => sn_mask);
      
        -- 8.1
        check_doc_num_format(par_doc_type   => v_doc_type
                            ,par_num        => v_doc_num
                            ,par_num_format => id_mask);
      
        -- 9.1
        check_latin_letters_exists(par_text        => v_doc_issued_by
                                  ,par_column_name => 'Документ выдан');
      
        -- 10.2
        check_date_future(par_date        => v_doc_issued_date
                         ,par_column_name => 'Дата выдачи документа');
      
        -- 10.2
        check_doc_issue_date_vs_birth(par_doc_issue_date => v_doc_issued_date
                                     ,par_birth_date     => v_birth_date);
      END LOOP;
    
      FOR cur_address IN (SELECT 'INSUREE_PERSON_ADDRES' brief
                            FROM dual
                          UNION
                          SELECT 'ASSURED_PERSON_ADDRES'
                            FROM dual
                          UNION
                          SELECT 'BENEFICIARY' || LEVEL || '_PERSON_ADDRES'
                            FROM dual
                          CONNECT BY LEVEL <= 4)
      LOOP
        v_address := pkg_load_file_to_table.get_value_by_brief(cur_address.brief);
        -- 11.1
        check_latin_letters_exists(par_text => v_address, par_column_name => 'Адрес');
      END LOOP;
    
      FOR cur_telephone IN (SELECT 'INSUREE_PERSON_TELEPHONE' brief
                              FROM dual
                            UNION
                            SELECT 'ASSURED_PERSON_TELEPHONE'
                              FROM dual
                            UNION
                            SELECT 'BENEFICIARY' || LEVEL || '_PERSON_TELEPHONE'
                              FROM dual
                            CONNECT BY LEVEL <= 4)
      LOOP
        v_telephone := pkg_load_file_to_table.get_value_by_brief(cur_telephone.brief);
        -- 12.1
        check_telephone_format(par_telephone_num => v_telephone);
      END LOOP;
    
      v_policy_num := pkg_load_file_to_table.get_value_by_brief('POLICY_NUM');
      v_product    := pkg_load_file_to_table.get_value_by_brief('PRODUCT');
    
      -- 13.1
      check_product_pol_num_unique(par_product => v_product, par_pol_num => v_policy_num);
    
      v_bso_num := pkg_load_file_to_table.get_value_by_brief('BSO_NUM');
    
      -- 14.1
      check_bso_num(par_bso_num => v_bso_num);
    
      v_bso_series := pkg_load_file_to_table.get_value_by_brief('BSO_SERIES');
    
      -- 14.3
      check_bso_exists(par_bso_num => v_bso_num, par_bso_series => v_bso_series);
    
      -- 14.4
      check_bso_used(par_bso_num => v_bso_num, par_bso_series => v_bso_series);
    
      v_signing_date := pkg_load_file_to_table.get_value_date('SIGNING_DATE');
    
      -- 15.1
      check_date_future(par_date        => v_signing_date
                       ,par_column_name => 'Дата подписания');
    
      v_start_date := pkg_load_file_to_table.get_value_date('START_DATE');
      v_end_date   := pkg_load_file_to_table.get_value_date('END_DATE');
    
      -- 16.1
      check_date_future(par_date => v_start_date, par_column_name => 'Дата начала');
    
      -- 16.2
      check_date1_grater_than_date2(par_date1        => v_start_date
                                   ,par_date2        => v_end_date
                                   ,par_column1_name => 'Дата начала'
                                   ,par_column2_name => 'Дата окончания');
      IF v_start_date IS NOT NULL
      THEN
        FOR cur_doc_issue IN (SELECT 'INSUREE_DOC_ISSUED_DATE' brief
                                FROM dual
                              UNION
                              SELECT 'ASSURED_DOC_ISSUED_DATE'
                                FROM dual
                              UNION
                              SELECT 'BENEFICIARY' || LEVEL || '_DOC_ISSUED_DATE'
                                FROM dual
                              CONNECT BY LEVEL <= 4)
        LOOP
          v_doc_issued_date := pkg_load_file_to_table.get_value_date(cur_doc_issue.brief);
        
          -- 16.3
          check_date1_grater_than_date2(par_date1        => v_doc_issued_date
                                       ,par_date2        => v_start_date
                                       ,par_column1_name => 'Документ выдан'
                                       ,par_column2_name => 'Дата начала');
        
        END LOOP;
      END IF;
    
      -- 17.1
      check_date_eld(par_date => v_end_date, par_column_name => 'Дата окончания');
    
      /*
         19.2 В файле-источнике отсутствуют записи с такими же значениями в полях с брифом:
              name_first, name, middle_name, birth_date, doc_type, doc_ser, doc_num, policy_num, ins_sum
      */
      v_ins_sum := pkg_load_file_to_table.get_value_by_brief('INS_SUM');
      FOR cur IN (SELECT 'INSUREE_' brief
                    FROM dual
                  UNION ALL
                  SELECT 'ASSURED_'
                    FROM dual
                  UNION ALL
                  SELECT 'BENEFICIARY' || LEVEL || '_'
                    FROM dual
                  CONNECT BY LEVEL <= 4)
      LOOP
        v_name        := pkg_load_file_to_table.get_value_by_brief(cur.brief || 'NAME');
        v_first_name  := pkg_load_file_to_table.get_value_by_brief(cur.brief || 'NAME_FIRST');
        v_middle_name := pkg_load_file_to_table.get_value_by_brief(cur.brief || 'MIDDLE_NAME');
        v_birth_date  := pkg_load_file_to_table.get_value_date(cur.brief || 'BIRTH_DATE');
        v_doc_type    := pkg_load_file_to_table.get_value_by_brief(cur.brief || 'DOC_TYPE');
        v_doc_ser     := pkg_load_file_to_table.get_value_by_brief(cur.brief || 'DOC_SER');
        v_doc_num     := pkg_load_file_to_table.get_value_by_brief(cur.brief || 'DOC_NUM');
      
        SELECT COUNT(*)
          INTO v_continue
          FROM dual
         WHERE EXISTS
         (SELECT 1
                  FROM load_file_rows fr
                 WHERE 1 = 1
                   AND fr.load_file_id = par_file_row.load_file_id
                   AND fr.load_file_rows_id <> par_file_row.load_file_rows_id
                   AND pkg_load_file_to_table.get_value_by_brief(cur.brief || 'NAME'
                                                                ,fr.load_file_rows_id) = v_name
                   AND pkg_load_file_to_table.get_value_by_brief(cur.brief || 'NAME_FIRST'
                                                                ,fr.load_file_rows_id) = v_first_name
                   AND pkg_load_file_to_table.get_value_by_brief(cur.brief || 'MIDDLE_NAME'
                                                                ,fr.load_file_rows_id) = v_middle_name
                   AND pkg_load_file_to_table.get_value_date(cur.brief || 'BIRTH_DATE'
                                                            ,fr.load_file_rows_id) = v_birth_date
                   AND pkg_load_file_to_table.get_value_by_brief(cur.brief || 'DOC_TYPE'
                                                                ,fr.load_file_rows_id) = v_doc_type
                   AND pkg_load_file_to_table.get_value_by_brief(cur.brief || 'DOC_SER'
                                                                ,fr.load_file_rows_id) = v_doc_ser
                   AND pkg_load_file_to_table.get_value_by_brief(cur.brief || 'DOC_NUM'
                                                                ,fr.load_file_rows_id) = v_doc_num
                   AND pkg_load_file_to_table.get_value_by_brief('POLICY_NUM', fr.load_file_rows_id) =
                       v_policy_num
                   AND pkg_load_file_to_table.get_value_by_brief('INS_SUM', fr.load_file_rows_id) =
                       v_ins_sum);
        IF v_continue > 0
        THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_POL_NUM_DOUBLES')
                                             ,par_log_msg              => 'В файле-источнике есть записи о ДС с таким же номером (' ||
                                                                          v_policy_num ||
                                                                          '), таким же Застрахованным (' ||
                                                                          v_name || ' ' ||
                                                                          v_first_name || ' ' ||
                                                                          v_middle_name || ' ' ||
                                                                          to_char(v_birth_date
                                                                                 ,'DD.MM.YYYY') || ' ' ||
                                                                          v_doc_type || ' ' ||
                                                                          v_doc_ser || ' ' ||
                                                                          v_doc_num ||
                                                                          ') с такой же страховой суммой (' ||
                                                                          v_ins_sum || ')'
                                             ,par_load_stage           => pkg_load_logging.get_check_group);
        END IF;
      END LOOP; -- 19.2
    
      v_ins_prem := pkg_load_file_to_table.get_value_by_brief('INS_PREM');
      -- 18.1
      check_negative_value(par_value       => v_ins_sum
                          ,par_column_name => '«Страховая сумма»');
      -- 19.1
      check_negative_value(par_value       => v_ins_prem
                          ,par_column_name => '«Страховая премия»');
    
      -- 20.1
      v_currency := pkg_load_file_to_table.get_value_by_brief('CURRENCY');
      check_currency_exists(par_currency_brief => v_currency);
    
      -- 21.1
      v_credit_num := pkg_load_file_to_table.get_value_by_brief('CREDIT_NUM');
      check_column_value_doubles(par_value        => v_credit_num
                                ,par_column_brief => 'CREDIT_NUM'
                                ,par_column_name  => 'Номер КД');
    
      -- 22.2
      check_product_cred_num_unique(par_product => v_product, par_credit_num => v_credit_num);
    
      -- 22.1
      check_benefic_percent;
    
      /*
      EXCEPTION
        WHEN OTHERS THEN
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('UNDEFINED_GROUP')
                                             ,par_log_msg              => SQLERRM
                                             ,par_load_stage           => pkg_load_logging.get_check_single);
                                             */
    END critical_errors_check;
  
    -- Процедура проверки некритичных условий
    PROCEDURE non_critical_errors_check(par_file_row load_file_rows%ROWTYPE) IS
      v_gender      load_file_rows.val_1%TYPE := NULL;
      v_first_name  load_file_rows.val_1%TYPE := NULL;
      v_middle_name load_file_rows.val_1%TYPE := NULL;
    
      /*
        Проверка 2.2 Существует запись в таблице «Справочник имён» со значением в поле «Имя»,
        равным значению данного поля
      */
      PROCEDURE check_name_exists(par_first_name VARCHAR2) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_first_name IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS
           (SELECT 1 FROM t_cont_first_name WHERE upper(first_name) = upper(TRIM(par_first_name)));
        
          IF v_continue = 0
          THEN
            pkg_load_logging.set_non_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                                   ,par_load_order_num       => gv_log_order_num
                                                   ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                                   ,par_log_msg              => 'В поле «Имя» указано имя ' ||
                                                                                par_first_name ||
                                                                                ', отсутствующее в Справочнике имён'
                                                   ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_name_exists;
    
      /*
        Проверка 3.1 Существует запись в таблице «Справочник отчеств» со значением в поле «Отчество»,
        равным значению данного поля
      */
      PROCEDURE check_middle_name_exists(par_middle_name VARCHAR2) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_middle_name IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1
                    FROM t_cont_middle_name
                   WHERE upper(middle_name) = upper(TRIM(par_middle_name)));
          IF v_continue = 0
          THEN
            pkg_load_logging.set_non_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                                   ,par_load_order_num       => gv_log_order_num
                                                   ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                                   ,par_log_msg              => 'В поле «Отчество» указано отчество ' ||
                                                                                par_middle_name ||
                                                                                ', отсутствующее в Справочнике отчеств'
                                                   ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_middle_name_exists;
    
      /*
        Проверки
        5.1 Если указано какое-либо значение в поле с брифом middle_name и последние символы
            в этом значении «ич» или «оглы», то: значение в данном поле «м»
        5.2 Если указано какое-либо значение в поле middle_name и последние символы
            в этом значении «на» или «кызы», то: значение в данном поле «ж»
        5.3 Если указано какое-либо значение в поле middle_name и последние символы
            в этом значении не «ич», «оглы», «на» и «кызы», то:
              а) Существует запись в таблице «Справочник имён» со значением в поле «Имя»,
                 равным значению поля с брифом name_first, или
      */
      PROCEDURE check_middle_name_gender
      (
        par_middle_name VARCHAR2
       ,par_gender      VARCHAR2
      ) IS
        v_continue NUMBER := 1;
      BEGIN
      
        IF par_middle_name IS NOT NULL
        THEN
          -- начало 5.1, 5.2
          IF substr(upper(par_middle_name), length(par_middle_name) - 1, 2) = 'ИЧ'
             OR substr(upper(par_middle_name), length(par_middle_name) - 3, 4) = 'ОГЛЫ'
             OR substr(upper(par_middle_name), length(par_middle_name) - 1, 2) = 'НА'
             OR substr(upper(par_middle_name), length(par_middle_name) - 3, 4) = 'КЫЗЫ'
          THEN
            IF (lower(par_gender) = 'м' AND
               NOT (substr(upper(par_middle_name), length(par_middle_name) - 1, 2) = 'ИЧ' OR
                substr(upper(par_middle_name), length(par_middle_name) - 3, 4) = 'ОГЛЫ'))
               OR (lower(par_gender) = 'ж' AND
               NOT (substr(upper(par_middle_name), length(par_middle_name) - 1, 2) = 'НА' OR
                substr(upper(par_middle_name), length(par_middle_name) - 3, 4) = 'КЫЗЫ'))
            THEN
              pkg_load_logging.set_non_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                                     ,par_load_order_num       => gv_log_order_num
                                                     ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                                     ,par_log_msg              => 'В поле «Пол» указан пол (' ||
                                                                                  par_gender ||
                                                                                  '), не соответствующий ' || CASE
                                                                                   lower(par_gender)
                                                                                    WHEN 'м' THEN
                                                                                     'мужскому'
                                                                                    WHEN 'м' THEN
                                                                                     'женскому'
                                                                                  END || ' отчеству ' ||
                                                                                  par_middle_name
                                                     ,par_load_stage           => pkg_load_logging.get_check_single);
            END IF; -- конец 5.1, 5.2
          ELSE
            SELECT COUNT(*) -- начало 5.3 а)
              INTO v_continue
              FROM dual
             WHERE EXISTS (SELECT 1
                      FROM t_cont_middle_name
                     WHERE upper(middle_name) = upper(TRIM(par_middle_name))
                       AND gender_id = CASE lower(par_gender)
                             WHEN 'ж' THEN
                              0
                             WHEN 'м' THEN
                              1
                           END);
            IF v_continue = 0
            THEN
              pkg_load_logging.set_non_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                                     ,par_load_order_num       => gv_log_order_num
                                                     ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                                     ,par_log_msg              => 'В поле «Пол» указан пол (' ||
                                                                                  par_gender ||
                                                                                  '), не соответствующий отчеству ' ||
                                                                                  par_middle_name
                                                     ,par_load_stage           => pkg_load_logging.get_check_single);
            END IF; -- конец 5.3 а)
          END IF;
        
        END IF; -- конец 5.1, 5.2, 5.3 а)
      END check_middle_name_gender;
    
      /*
        Проверка 5.3 Если указано какое-либо значение в поле middle_name и последние символы
        в этом значении не «ич», «оглы», «на» и «кызы», то:
          б) Существует запись в таблице «Справочник отчеств» со значением в поле «Отчество»,
             равным значению поля с брифом middle_name
      */
      PROCEDURE check_first_name_gender
      (
        par_first_name VARCHAR2
       ,par_gender     VARCHAR2
      ) IS
        v_continue NUMBER := 1;
      BEGIN
        IF par_first_name IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_continue
            FROM dual
           WHERE EXISTS (SELECT 1
                    FROM t_cont_first_name
                   WHERE upper(first_name) = upper(TRIM(par_first_name))
                     AND gender_id = CASE lower(par_gender)
                           WHEN 'ж' THEN
                            0
                           WHEN 'м' THEN
                            1
                         END);
          IF v_continue = 0
          THEN
            pkg_load_logging.set_non_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                                   ,par_load_order_num       => gv_log_order_num
                                                   ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                                   ,par_log_msg              => 'В поле «Пол» указан пол (' ||
                                                                                par_gender ||
                                                                                '), не соответствующий имени ' ||
                                                                                par_first_name
                                                   ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END check_first_name_gender;
    
    BEGIN
      FOR cur_gender IN (SELECT 'INSUREE_GENDER' brief_gender
                               ,'INSUREE_NAME_FIRST' brief_name
                               ,'INSUREE_MIDDLE_NAME' brief_mid_name
                           FROM dual
                         UNION
                         SELECT 'ASSURED_GENDER'
                               ,'ASSURED_NAME_FIRST'
                               ,'ASSURED_MIDDLE_NAME'
                           FROM dual
                         UNION
                         SELECT 'BENEFICIARY' || LEVEL || '_GENDER'
                               ,'BENEFICIARY' || LEVEL || '_NAME_FIRST'
                               ,'BENEFICIARY' || LEVEL || '_MIDDLE_NAME'
                           FROM dual
                         CONNECT BY LEVEL <= 4)
      LOOP
        v_gender      := TRIM(pkg_load_file_to_table.get_value_by_brief(cur_gender.brief_gender));
        v_first_name  := pkg_load_file_to_table.get_value_by_brief(cur_gender.brief_name);
        v_middle_name := pkg_load_file_to_table.get_value_by_brief(cur_gender.brief_mid_name);
      
        -- 2.2
        check_name_exists(par_first_name => v_first_name);
      
        -- 3.1
        check_middle_name_exists(par_middle_name => v_middle_name);
      
        -- 5.1, 5.2, 5.3 а)
        check_middle_name_gender(par_middle_name => v_middle_name, par_gender => v_gender);
      
        -- 5.3 б)
        check_first_name_gender(par_first_name => v_first_name, par_gender => v_gender);
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        pkg_load_logging.set_non_critical_error(par_load_file_rows_id    => par_file_row.load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('UNDEFINED_GROUP')
                                               ,par_log_msg              => SQLERRM
                                               ,par_load_stage           => pkg_load_logging.get_check_single);
      
    END non_critical_errors_check;
  
  BEGIN
    /*
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Rustam.Ahtyamov@Renlife.com')
                                           ,par_subject => 'Начали в ' ||
                                                           to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS')
                                           ,par_text    => 'Начало проверки');
    */
    -- Проверка прав
    pkg_load_file_to_table.check_rights(par_load_file_id => par_load_file_id
                                       ,par_right_brief  => 'LOAD_BANK_POLICY');
  
    pkg_load_file_to_table.init_file(par_load_file_id => par_load_file_id);
  
    gv_log_order_num := pkg_load_file_to_table.get_current_log_load_order_num;
  
    -- Конфликт брифов
    pkg_load_file_to_table.check_conflicts(par_load_file_id);
  
    -- Проверка критичных ошибок БСО
    IF check_bso_critical_errors(par_load_file_id) = 1
    THEN
      FOR cur_file_row IN (SELECT *
                             FROM load_file_rows
                            WHERE 1 = 1
                              AND row_status IN (pkg_load_file_to_table.get_checked
                                                ,pkg_load_file_to_table.get_error
                                                ,pkg_load_file_to_table.get_nc_error)
                              AND load_file_id = par_load_file_id)
      LOOP
        pkg_load_file_to_table.cache_row(cur_file_row.load_file_rows_id);
        -- Очистка журнала диагностики по загружаемой записи
        pkg_load_logging.clear_log_by_row_id(cur_file_row.load_file_rows_id);
        -- Проверка некритичных ошибок
        non_critical_errors_check(cur_file_row);
        -- Проверка критичных ошибок
        critical_errors_check(cur_file_row);
      END LOOP;
    END IF;
    /*  
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Rustam.Ahtyamov@Renlife.com')
                                           ,par_subject => 'Закончили в ' ||
                                                           to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS')
                                           ,par_text    => 'Окончание проверки');
    */
  EXCEPTION
    WHEN pkg_load_file_to_table.ex_priority_conflicts_found THEN
      NULL;
    WHEN pkg_load_file_to_table.ex_load_not_have_permission THEN
      NULL;
  END check_load_bank_policy;

  PROCEDURE load_bank_policy(par_load_file_id load_file.load_file_id%TYPE) IS
    ex_get_agent_id                EXCEPTION;
    ex_get_row_values              EXCEPTION;
    ex_process_insuree_contact     EXCEPTION;
    ex_process_assured_contact     EXCEPTION;
    ex_process_benefic_contact     EXCEPTION;
    ex_get_fund_id                 EXCEPTION;
    ex_get_bso_series_id_not_found EXCEPTION;
    ex_get_bso_series_id_too_many  EXCEPTION;
    ex_get_bso_series_num          EXCEPTION;
    ex_gen_next_bso_number         EXCEPTION;
    ex_get_payment_term_id         EXCEPTION;
    ex_get_payment_off_term_id     EXCEPTION;
    ex_get_waiting_period_id       EXCEPTION;
    ex_get_confirm_conds_id        EXCEPTION;
    ex_create_universal            EXCEPTION;
    ex_premium_check               EXCEPTION;
    ex_change_status               EXCEPTION;
  
    -- ИД загружаемой строки
    gv_load_file_rows_id load_file_rows.load_file_rows_id%TYPE;
  
    -- Порядковый номер журнала диагностики
    gv_log_order_num NUMBER;
  
    -- Имя загружаемого файла (добавляется в комменты)
    gv_file_name load_file.file_name%TYPE;
  
    -- Значения настроек продукта по умолчанию
    v_product_defaults pkg_products.t_product_defaults;
  
    -- Массив застрахованных
    v_asset_array pkg_asset.t_assured_array;
  
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
    v_policy_id        p_policy.policy_id%TYPE;
    v_period_id                p_policy.period_id%TYPE;
  
    -- Тип данных для создания ДС через pkg_policy.create_universal
    TYPE typ_policy_settings IS RECORD(
       fund_id            fund.fund_id%TYPE
      ,period_id          t_period.id%TYPE
      ,payment_terms_id   t_payment_terms.id%TYPE
      ,paymentoff_term_id t_payment_terms.id%TYPE
      ,waiting_period_id  t_period.id%TYPE
      ,confirm_conds_id   t_confirm_condition.id%TYPE
      ,bso_series_id      bso_series.bso_series_id%TYPE
      ,agent_id           ag_contract_header.agent_id%TYPE);
  
    v_policy_settings typ_policy_settings;
  
    -- Тип содержит набор полей, описывающий контакта в загружаемом файле (Страхователь / Застрахованный / Бенефициар)
    TYPE typ_contact IS RECORD(
       contact_id       contact.contact_id%TYPE
      ,name_first       contact.first_name%TYPE
      ,NAME             contact.name%TYPE
      ,middle_name      contact.middle_name%TYPE
      ,birth_date       cn_person.date_of_birth%TYPE
      ,gender           t_gender.brief%TYPE
      ,fpo              contact.is_public_contact%TYPE
      ,resident         contact.resident_flag%TYPE
      ,doc_type         t_id_type.brief%TYPE
      ,doc_ser          cn_contact_ident.serial_nr%TYPE
      ,doc_num          cn_contact_ident.id_value%TYPE
      ,doc_issued_by    cn_contact_ident.place_of_issue%TYPE
      ,doc_issued_date  cn_contact_ident.issue_date%TYPE
      ,person_addres    cn_address.name%TYPE
      ,person_telephone cn_contact_telephone.telephone_number%TYPE
      ,relation_type    t_contact_rel_type.relationship_dsc%TYPE
      ,percent          as_beneficiary.value%TYPE);
  
    -- Тип содержит набор полей, описывающий ДС в загружаемом файле
    TYPE typ_policy IS RECORD(
       policy_num           p_policy.pol_num%TYPE
      ,bso_series           VARCHAR2(30)
      , --bso_series.series_name%TYPE               ,
      bso_num              bso.num%TYPE
      ,signing_date         p_policy.sign_date%TYPE
      ,start_date           p_policy.start_date%TYPE
      ,end_date             p_policy.end_date%TYPE
      ,ins_sum              p_policy.ins_amount%TYPE
      ,ins_prem             p_policy.premium%TYPE
      ,currency             fund.brief%TYPE
      ,credit_num           as_assured.credit_account_number%TYPE
      ,paymentoff_term_name t_payment_terms.brief%TYPE
      ,waiting_period_name  t_period.description%TYPE
      ,pay_term_name        t_payment_terms.brief%TYPE
      ,coll_meth_name       t_collection_method.brief%TYPE
      ,period_name          t_period.description%TYPE
      ,period_num           t_period.period_value%TYPE
      ,period_type          t_period_type.brief%TYPE
      ,conf_cond_name       t_confirm_condition.brief%TYPE
      ,product              t_product.brief%TYPE
      ,AGENT                ven_ag_contract_header.num%TYPE
      ,status_target        doc_status_ref.brief%TYPE
      ,end_date_correct     VARCHAR2(50)
      ,payment_sum          ac_payment.amount%TYPE);
  
    -- Тип данные для хранения значений полей загружаемой строки csv-файла
    TYPE typ_load_row IS RECORD(
       t_insuree      typ_contact
      ,t_assured      typ_contact
      ,t_beneficiary1 typ_contact
      ,t_beneficiary2 typ_contact
      ,t_beneficiary3 typ_contact
      ,t_beneficiary4 typ_contact
      ,t_policy       typ_policy);
  
    v_load_row typ_load_row;
  
    -- Функция определения контакта агента по номеру АД
    FUNCTION get_agent_id(par_ag_contact_num VARCHAR2) RETURN contact.contact_id%TYPE IS
      v_agent_contact_id contact.contact_id%TYPE;
    BEGIN
      SELECT agent_id
        INTO v_agent_contact_id
        FROM ven_ag_contract_header ah
            ,doc_status_ref         dsr
       WHERE num = par_ag_contact_num
         AND ah.doc_status_ref_id = dsr.doc_status_ref_id
         AND ah.is_new = 1
         AND dsr.brief = 'CURRENT';
    
      RETURN v_agent_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_agent_id;
    END get_agent_id;
  
    -- Функция возвращает значения загружаемой строки, разложенные по брифам
    FUNCTION get_row_values RETURN typ_load_row IS
      v_load_row typ_load_row := NULL;
    BEGIN
      -- Страхователь
      v_load_row.t_insuree.contact_id       := pkg_load_file_to_table.get_value_by_brief('INSUREE_CONTACT_ID');
      v_load_row.t_insuree.name_first       := TRIM(pkg_load_file_to_table.get_value_by_brief('INSUREE_NAME_FIRST'));
      v_load_row.t_insuree.name             := TRIM(pkg_load_file_to_table.get_value_by_brief('INSUREE_NAME'));
      v_load_row.t_insuree.middle_name      := TRIM(pkg_load_file_to_table.get_value_by_brief('INSUREE_MIDDLE_NAME'));
      v_load_row.t_insuree.birth_date       := pkg_load_file_to_table.get_value_by_brief('INSUREE_BIRTH_DATE');
      v_load_row.t_insuree.gender           := pkg_load_file_to_table.get_value_by_brief('INSUREE_GENDER');
      v_load_row.t_insuree.fpo              := pkg_load_file_to_table.get_value_by_brief('INSUREE_FPO');
      v_load_row.t_insuree.resident         := pkg_load_file_to_table.get_value_by_brief('INSUREE_RESIDENT');
      v_load_row.t_insuree.doc_type         := pkg_load_file_to_table.get_value_by_brief('INSUREE_DOC_TYPE');
      v_load_row.t_insuree.doc_ser          := pkg_load_file_to_table.get_value_by_brief('INSUREE_DOC_SER');
      v_load_row.t_insuree.doc_num          := pkg_load_file_to_table.get_value_by_brief('INSUREE_DOC_NUM');
      v_load_row.t_insuree.doc_issued_by    := pkg_load_file_to_table.get_value_by_brief('INSUREE_DOC_ISSUED_BY');
      v_load_row.t_insuree.doc_issued_date  := pkg_load_file_to_table.get_value_by_brief('INSUREE_DOC_ISSUED_DATE');
      v_load_row.t_insuree.person_addres    := pkg_load_file_to_table.get_value_by_brief('INSUREE_PERSON_ADDRES');
      v_load_row.t_insuree.person_telephone := pkg_load_file_to_table.get_value_by_brief('INSUREE_PERSON_TELEPHONE');
    
      -- ЗАСТРАХОВАННЫЙ
      v_load_row.t_assured.contact_id       := pkg_load_file_to_table.get_value_by_brief('ASSURED_CONTACT_ID');
      v_load_row.t_assured.name_first       := TRIM(pkg_load_file_to_table.get_value_by_brief('ASSURED_NAME_FIRST'));
      v_load_row.t_assured.name             := TRIM(pkg_load_file_to_table.get_value_by_brief('ASSURED_NAME'));
      v_load_row.t_assured.middle_name      := TRIM(pkg_load_file_to_table.get_value_by_brief('ASSURED_MIDDLE_NAME'));
      v_load_row.t_assured.birth_date       := pkg_load_file_to_table.get_value_by_brief('ASSURED_BIRTH_DATE');
      v_load_row.t_assured.gender           := pkg_load_file_to_table.get_value_by_brief('ASSURED_GENDER');
      v_load_row.t_assured.fpo              := pkg_load_file_to_table.get_value_by_brief('ASSURED_FPO');
      v_load_row.t_assured.resident         := pkg_load_file_to_table.get_value_by_brief('ASSURED_RESIDENT');
      v_load_row.t_assured.doc_type         := pkg_load_file_to_table.get_value_by_brief('ASSURED_DOC_TYPE');
      v_load_row.t_assured.doc_ser          := pkg_load_file_to_table.get_value_by_brief('ASSURED_DOC_SER');
      v_load_row.t_assured.doc_num          := pkg_load_file_to_table.get_value_by_brief('ASSURED_DOC_NUM');
      v_load_row.t_assured.doc_issued_by    := pkg_load_file_to_table.get_value_by_brief('ASSURED_DOC_ISSUED_BY');
      v_load_row.t_assured.doc_issued_date  := pkg_load_file_to_table.get_value_by_brief('ASSURED_DOC_ISSUED_DATE');
      v_load_row.t_assured.person_addres    := pkg_load_file_to_table.get_value_by_brief('ASSURED_PERSON_ADDRES');
      v_load_row.t_assured.person_telephone := pkg_load_file_to_table.get_value_by_brief('ASSURED_PERSON_TELEPHONE');
    
      -- БЕНЕФИЦИАР 1
      v_load_row.t_beneficiary1.contact_id       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_CONTACT_ID');
      v_load_row.t_beneficiary1.name_first       := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_NAME_FIRST'));
      v_load_row.t_beneficiary1.name             := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_NAME'));
      v_load_row.t_beneficiary1.middle_name      := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_MIDDLE_NAME'));
      v_load_row.t_beneficiary1.birth_date       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_BIRTH_DATE');
      v_load_row.t_beneficiary1.gender           := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_GENDER');
      v_load_row.t_beneficiary1.fpo              := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_FPO');
      v_load_row.t_beneficiary1.resident         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_RESIDENT');
      v_load_row.t_beneficiary1.doc_type         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_DOC_TYPE');
      v_load_row.t_beneficiary1.doc_ser          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_DOC_SER');
      v_load_row.t_beneficiary1.doc_num          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_DOC_NUM');
      v_load_row.t_beneficiary1.doc_issued_by    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_DOC_ISSUED_BY');
      v_load_row.t_beneficiary1.doc_issued_date  := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_DOC_ISSUED_DATE');
      v_load_row.t_beneficiary1.person_addres    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_PERSON_ADDRES');
      v_load_row.t_beneficiary1.person_telephone := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_PERSON_TELEPHONE');
      v_load_row.t_beneficiary1.relation_type    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_RELATION_TYPE');
      v_load_row.t_beneficiary1.percent          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY1_PERCENT');
    
      -- БЕНЕФИЦИАР 2
      v_load_row.t_beneficiary2.contact_id       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_CONTACT_ID');
      v_load_row.t_beneficiary2.name_first       := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_NAME_FIRST'));
      v_load_row.t_beneficiary2.name             := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_NAME'));
      v_load_row.t_beneficiary2.middle_name      := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_MIDDLE_NAME'));
      v_load_row.t_beneficiary2.birth_date       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_BIRTH_DATE');
      v_load_row.t_beneficiary2.gender           := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_GENDER');
      v_load_row.t_beneficiary2.fpo              := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_FPO');
      v_load_row.t_beneficiary2.resident         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_RESIDENT');
      v_load_row.t_beneficiary2.doc_type         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_DOC_TYPE');
      v_load_row.t_beneficiary2.doc_ser          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_DOC_SER');
      v_load_row.t_beneficiary2.doc_num          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_DOC_NUM');
      v_load_row.t_beneficiary2.doc_issued_by    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_DOC_ISSUED_BY');
      v_load_row.t_beneficiary2.doc_issued_date  := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_DOC_ISSUED_DATE');
      v_load_row.t_beneficiary2.person_addres    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_PERSON_ADDRES');
      v_load_row.t_beneficiary2.person_telephone := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_PERSON_TELEPHONE');
      v_load_row.t_beneficiary2.relation_type    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_RELATION_TYPE');
      v_load_row.t_beneficiary2.percent          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY2_PERCENT');
    
      -- БЕНЕФИЦИАР 3
      v_load_row.t_beneficiary3.contact_id       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_CONTACT_ID');
      v_load_row.t_beneficiary3.name_first       := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_NAME_FIRST'));
      v_load_row.t_beneficiary3.name             := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_NAME'));
      v_load_row.t_beneficiary3.middle_name      := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_MIDDLE_NAME'));
      v_load_row.t_beneficiary3.birth_date       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_BIRTH_DATE');
      v_load_row.t_beneficiary3.gender           := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_GENDER');
      v_load_row.t_beneficiary3.fpo              := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_FPO');
      v_load_row.t_beneficiary3.resident         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_RESIDENT');
      v_load_row.t_beneficiary3.doc_type         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_DOC_TYPE');
      v_load_row.t_beneficiary3.doc_ser          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_DOC_SER');
      v_load_row.t_beneficiary3.doc_num          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_DOC_NUM');
      v_load_row.t_beneficiary3.doc_issued_by    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_DOC_ISSUED_BY');
      v_load_row.t_beneficiary3.doc_issued_date  := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_DOC_ISSUED_DATE');
      v_load_row.t_beneficiary3.person_addres    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_PERSON_ADDRES');
      v_load_row.t_beneficiary3.person_telephone := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_PERSON_TELEPHONE');
      v_load_row.t_beneficiary3.relation_type    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_RELATION_TYPE');
      v_load_row.t_beneficiary3.percent          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY3_PERCENT');
    
      -- БЕНЕФИЦИАР 4
      v_load_row.t_beneficiary4.contact_id       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_CONTACT_ID');
      v_load_row.t_beneficiary4.name_first       := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_NAME_FIRST'));
      v_load_row.t_beneficiary4.name             := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_NAME'));
      v_load_row.t_beneficiary4.middle_name      := TRIM(pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_MIDDLE_NAME'));
      v_load_row.t_beneficiary4.birth_date       := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_BIRTH_DATE');
      v_load_row.t_beneficiary4.gender           := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_GENDER');
      v_load_row.t_beneficiary4.fpo              := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_FPO');
      v_load_row.t_beneficiary4.resident         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_RESIDENT');
      v_load_row.t_beneficiary4.doc_type         := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_DOC_TYPE');
      v_load_row.t_beneficiary4.doc_ser          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_DOC_SER');
      v_load_row.t_beneficiary4.doc_num          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_DOC_NUM');
      v_load_row.t_beneficiary4.doc_issued_by    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_DOC_ISSUED_BY');
      v_load_row.t_beneficiary4.doc_issued_date  := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_DOC_ISSUED_DATE');
      v_load_row.t_beneficiary4.person_addres    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_PERSON_ADDRES');
      v_load_row.t_beneficiary4.person_telephone := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_PERSON_TELEPHONE');
      v_load_row.t_beneficiary4.relation_type    := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_RELATION_TYPE');
      v_load_row.t_beneficiary4.percent          := pkg_load_file_to_table.get_value_by_brief('BENEFICIARY4_PERCENT');
    
      -- ПАРАМЕТРЫ ДС
      v_load_row.t_policy.policy_num           := pkg_load_file_to_table.get_value_by_brief('POLICY_NUM');
      v_load_row.t_policy.bso_series           := pkg_load_file_to_table.get_value_by_brief('BSO_SERIES');
      v_load_row.t_policy.bso_num              := pkg_load_file_to_table.get_value_by_brief('BSO_NUM');
      v_load_row.t_policy.signing_date         := pkg_load_file_to_table.get_value_by_brief('SIGNING_DATE');
      v_load_row.t_policy.start_date           := pkg_load_file_to_table.get_value_by_brief('START_DATE');
      v_load_row.t_policy.end_date             := pkg_load_file_to_table.get_value_by_brief('END_DATE');
      v_load_row.t_policy.ins_sum              := to_number(REPLACE(pkg_load_file_to_table.get_value_by_brief('INS_SUM')
                                                                   ,','
                                                                   ,'.')
                                                           ,'9999999999999D9999999999999'
                                                           ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_load_row.t_policy.ins_prem             := to_number(REPLACE(pkg_load_file_to_table.get_value_by_brief('INS_PREM')
                                                                   ,','
                                                                   ,'.')
                                                           ,'9999999999999D9999999999999'
                                                           ,'NLS_NUMERIC_CHARACTERS = ''.,''');
      v_load_row.t_policy.currency             := pkg_load_file_to_table.get_value_by_brief('CURRENCY');
      v_load_row.t_policy.credit_num           := pkg_load_file_to_table.get_value_by_brief('CREDIT_NUM');
      v_load_row.t_policy.paymentoff_term_name := pkg_load_file_to_table.get_value_by_brief('PAYMENTOFF_TERM_NAME');
      v_load_row.t_policy.waiting_period_name  := pkg_load_file_to_table.get_value_by_brief('WAITING_PERIOD_NAME');
      v_load_row.t_policy.pay_term_name        := pkg_load_file_to_table.get_value_by_brief('PAY_TERM_NAME');
      v_load_row.t_policy.coll_meth_name       := pkg_load_file_to_table.get_value_by_brief('COLL_METH_NAME');
      v_load_row.t_policy.period_name          := pkg_load_file_to_table.get_value_by_brief('PERIOD_NAME');
      v_load_row.t_policy.period_num           := pkg_load_file_to_table.get_value_by_brief('PERIOD_NUM');
      v_load_row.t_policy.period_type          := pkg_load_file_to_table.get_value_by_brief('PERIOD_TYPE');
      v_load_row.t_policy.conf_cond_name       := pkg_load_file_to_table.get_value_by_brief('CONF_COND_NAME');
      v_load_row.t_policy.product              := pkg_load_file_to_table.get_value_by_brief('PRODUCT');
      v_load_row.t_policy.agent                := pkg_load_file_to_table.get_value_by_brief('AGENT');
      v_load_row.t_policy.status_target        := pkg_load_file_to_table.get_value_by_brief('STATUS_TARGET');
      v_load_row.t_policy.end_date_correct     := pkg_load_file_to_table.get_value_by_brief('POLICY_END_DATE_CALC_ALGORITHM');
      v_load_row.t_policy.payment_sum          := pkg_load_file_to_table.get_value_by_brief('PAYMENT_SUM');
    
      RETURN v_load_row;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ex_get_row_values;
    END get_row_values;
  
    -- Функция возвращает имя загружаемого файла
    FUNCTION get_file_name(par_load_file_id load_file.load_file_id%TYPE) RETURN load_file.file_name%TYPE IS
      v_file_name load_file.file_name%TYPE;
    BEGIN
      SELECT file_name INTO v_file_name FROM load_file WHERE load_file_id = par_load_file_id;
    
      RETURN v_file_name;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END get_file_name;
  
    -- Функция создает / обновляет контакты в рамках загружаемой строки
    PROCEDURE process_contact
    (
      par_load_row     typ_load_row
     ,par_load_row_out OUT typ_load_row
    ) IS
      v_contact_object pkg_contact_object.t_person_object;
      vr_ident_doc     pkg_contact_object.t_contact_id_doc_rec;
      vr_address       pkg_contact_object.t_contact_address_rec;
      vr_phone         pkg_contact_object.t_contact_phone_rec;
    
      v_splitted tt_one_col;
    
      vc_bordero_phone_type_brief   CONSTANT t_telephone_type.brief%TYPE := 'BORDERO';
      vc_default_address_type_brief CONSTANT t_address_type.brief%TYPE := 'DOMADD';
    
      -- Функция преобразует пол в ID
      FUNCTION get_gender_id(par_gender VARCHAR2) RETURN t_gender.id%TYPE IS
      BEGIN
        CASE lower(TRIM(par_gender))
          WHEN 'ж' THEN
            RETURN 0;
          WHEN 'м' THEN
            RETURN 1;
          ELSE
            RETURN NULL;
        END CASE;
      END;
    
    BEGIN
      par_load_row_out := par_load_row;
    
      ----------------------
      -- Страхователь
      BEGIN
        IF par_load_row.t_insuree.name IS NOT NULL
        THEN
          v_contact_object.name              := par_load_row.t_insuree.name;
          v_contact_object.first_name        := par_load_row.t_insuree.name_first;
          v_contact_object.middle_name       := par_load_row.t_insuree.middle_name;
          v_contact_object.date_of_birth     := par_load_row.t_insuree.birth_date;
          v_contact_object.gender            := get_gender_id(par_load_row.t_insuree.gender);
          v_contact_object.is_public_contact := par_load_row.t_insuree.fpo;
          v_contact_object.resident_flag     := par_load_row.t_insuree.resident;
          v_contact_object.note              := gv_file_name;
          -- Паспорт
          IF TRIM(par_load_row.t_insuree.doc_num) IS NOT NULL
          THEN
            vr_ident_doc.id_doc_type_brief := par_load_row.t_insuree.doc_type;
            vr_ident_doc.id_value          := par_load_row.t_insuree.doc_num;
            vr_ident_doc.series_nr         := par_load_row.t_insuree.doc_ser;
            vr_ident_doc.place_of_issue    := par_load_row.t_insuree.doc_issued_by;
            vr_ident_doc.issue_date        := par_load_row.t_insuree.doc_issued_date;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => vr_ident_doc);
          END IF;
          -- Адрес
          IF TRIM(par_load_row.t_insuree.person_addres) IS NOT NULL
          THEN
            vr_address.address_type_brief := vc_default_address_type_brief;
            vr_address.address            := TRIM(par_load_row.t_insuree.person_addres);
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => vr_address);
          END IF;
          -- Телефоны
          IF TRIM(par_load_row.t_insuree.person_telephone) IS NOT NULL
          THEN
            v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_load_row.t_insuree.person_telephone)
                                                       ,par_separator => ';');
            FOR i IN 1 .. v_splitted.count
            LOOP
              vr_phone.phone_type_brief := vc_bordero_phone_type_brief;
              vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
            
              IF vr_phone.phone_number IS NOT NULL
              THEN
                pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_phone_rec      => vr_phone);
              END IF;
            END LOOP;
          END IF;
        
          pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                  ,par_contact_id => par_load_row_out.t_insuree.contact_id);
        END IF; -- конец Страхователь
      EXCEPTION
        WHEN OTHERS THEN
          RAISE ex_process_insuree_contact;
      END;
    
      ----------------------
      -- Застрахованный
      BEGIN
        IF par_load_row.t_assured.name IS NOT NULL
        THEN
          v_contact_object                   := NULL;
          v_contact_object.name              := par_load_row.t_assured.name;
          v_contact_object.first_name        := par_load_row.t_assured.name_first;
          v_contact_object.middle_name       := par_load_row.t_assured.middle_name;
          v_contact_object.date_of_birth     := par_load_row.t_assured.birth_date;
          v_contact_object.gender            := get_gender_id(par_load_row.t_assured.gender);
          v_contact_object.is_public_contact := par_load_row.t_assured.fpo;
          v_contact_object.resident_flag     := par_load_row.t_assured.resident;
          v_contact_object.note              := gv_file_name;
          -- Паспорт
          IF TRIM(par_load_row.t_assured.doc_num) IS NOT NULL
          THEN
            vr_ident_doc.id_doc_type_brief := par_load_row.t_assured.doc_type;
            vr_ident_doc.id_value          := par_load_row.t_assured.doc_num;
            vr_ident_doc.series_nr         := par_load_row.t_assured.doc_ser;
            vr_ident_doc.place_of_issue    := par_load_row.t_assured.doc_issued_by;
            vr_ident_doc.issue_date        := par_load_row.t_assured.doc_issued_date;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => vr_ident_doc);
          END IF;
          -- Адрес
          IF TRIM(par_load_row.t_assured.person_addres) IS NOT NULL
          THEN
            vr_address.address_type_brief := nvl(par_load_row.t_assured.person_addres
                                                ,vc_default_address_type_brief);
            vr_address.address            := TRIM(par_load_row.t_assured.person_addres);
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => vr_address);
          END IF;
          -- Телефоны
          IF TRIM(par_load_row.t_assured.person_telephone) IS NOT NULL
          THEN
            v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_load_row.t_assured.person_telephone)
                                                       ,par_separator => ';');
            FOR i IN 1 .. v_splitted.count
            LOOP
              vr_phone.phone_type_brief := nvl(par_load_row.t_assured.person_telephone
                                              ,vc_bordero_phone_type_brief);
              vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
            
              IF vr_phone.phone_number IS NOT NULL
              THEN
                pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_phone_rec      => vr_phone);
              END IF;
            END LOOP;
          END IF;
        
          pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                  ,par_contact_id => par_load_row_out.t_assured.contact_id);
        END IF; -- конец Застрахованный
      EXCEPTION
        WHEN OTHERS THEN
          RAISE ex_process_assured_contact;
      END;
    
      ----------------------
      BEGIN
        -- Бенефициар 1
        IF par_load_row.t_beneficiary1.name IS NOT NULL
        THEN
          v_contact_object                   := NULL;
          v_contact_object.name              := par_load_row.t_beneficiary1.name;
          v_contact_object.first_name        := par_load_row.t_beneficiary1.name_first;
          v_contact_object.middle_name       := par_load_row.t_beneficiary1.middle_name;
          v_contact_object.date_of_birth     := par_load_row.t_beneficiary1.birth_date;
          v_contact_object.gender            := get_gender_id(par_load_row.t_beneficiary1.gender);
          v_contact_object.is_public_contact := par_load_row.t_beneficiary1.fpo;
          v_contact_object.resident_flag     := par_load_row.t_beneficiary1.resident;
          v_contact_object.note              := gv_file_name;
          -- Паспорт
          IF TRIM(par_load_row.t_beneficiary1.doc_num) IS NOT NULL
          THEN
            vr_ident_doc.id_doc_type_brief := par_load_row.t_beneficiary1.doc_type;
            vr_ident_doc.id_value          := par_load_row.t_beneficiary1.doc_num;
            vr_ident_doc.series_nr         := par_load_row.t_beneficiary1.doc_ser;
            vr_ident_doc.place_of_issue    := par_load_row.t_beneficiary1.doc_issued_by;
            vr_ident_doc.issue_date        := par_load_row.t_beneficiary1.doc_issued_date;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => vr_ident_doc);
          END IF;
          -- Адрес
          IF TRIM(par_load_row.t_beneficiary1.person_addres) IS NOT NULL
          THEN
            vr_address.address_type_brief := vc_default_address_type_brief;
            vr_address.address            := TRIM(par_load_row.t_beneficiary1.person_addres);
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => vr_address);
          END IF;
          -- Телефоны
          IF TRIM(par_load_row.t_beneficiary1.person_telephone) IS NOT NULL
          THEN
            v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_load_row.t_beneficiary1.person_telephone)
                                                       ,par_separator => ';');
            FOR i IN 1 .. v_splitted.count
            LOOP
              vr_phone.phone_type_brief := nvl(par_load_row.t_beneficiary1.person_telephone
                                              ,vc_bordero_phone_type_brief);
              vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
            
              IF vr_phone.phone_number IS NOT NULL
              THEN
                pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_phone_rec      => vr_phone);
              END IF;
            END LOOP;
          END IF;
        
          pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                  ,par_contact_id => par_load_row_out.t_beneficiary1.contact_id);
        END IF; -- конец Бенефициар 1
      
        ----------------------
        -- Бенефициар 2
        IF par_load_row.t_beneficiary2.name IS NOT NULL
        THEN
          v_contact_object                   := NULL;
          v_contact_object.name              := par_load_row.t_beneficiary2.name;
          v_contact_object.first_name        := par_load_row.t_beneficiary2.name_first;
          v_contact_object.middle_name       := par_load_row.t_beneficiary2.middle_name;
          v_contact_object.date_of_birth     := par_load_row.t_beneficiary2.birth_date;
          v_contact_object.gender            := get_gender_id(par_load_row.t_beneficiary2.gender);
          v_contact_object.is_public_contact := par_load_row.t_beneficiary2.fpo;
          v_contact_object.resident_flag     := par_load_row.t_beneficiary2.resident;
          v_contact_object.note              := gv_file_name;
          -- Паспорт
          IF TRIM(par_load_row.t_beneficiary2.doc_num) IS NOT NULL
          THEN
            vr_ident_doc.id_doc_type_brief := par_load_row.t_beneficiary2.doc_type;
            vr_ident_doc.id_value          := par_load_row.t_beneficiary2.doc_num;
            vr_ident_doc.series_nr         := par_load_row.t_beneficiary2.doc_ser;
            vr_ident_doc.place_of_issue    := par_load_row.t_beneficiary2.doc_issued_by;
            vr_ident_doc.issue_date        := par_load_row.t_beneficiary2.doc_issued_date;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => vr_ident_doc);
          END IF;
          -- Адрес
          IF TRIM(par_load_row.t_beneficiary2.person_addres) IS NOT NULL
          THEN
            vr_address.address_type_brief := vc_default_address_type_brief;
            vr_address.address            := TRIM(par_load_row.t_beneficiary2.person_addres);
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => vr_address);
          END IF;
          -- Телефоны
          IF TRIM(par_load_row.t_beneficiary2.person_telephone) IS NOT NULL
          THEN
            v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_load_row.t_beneficiary2.person_telephone)
                                                       ,par_separator => ';');
            FOR i IN 1 .. v_splitted.count
            LOOP
              vr_phone.phone_type_brief := nvl(par_load_row.t_beneficiary2.person_telephone
                                              ,vc_bordero_phone_type_brief);
              vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
            
              IF vr_phone.phone_number IS NOT NULL
              THEN
                pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_phone_rec      => vr_phone);
              END IF;
            END LOOP;
          END IF;
        
          pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                  ,par_contact_id => par_load_row_out.t_beneficiary2.contact_id);
        END IF; -- конец Бенефициар 2
      
        ----------------------
        -- Бенефициар 3
        IF par_load_row.t_beneficiary3.name IS NOT NULL
        THEN
          v_contact_object                   := NULL;
          v_contact_object.name              := par_load_row.t_beneficiary3.name;
          v_contact_object.first_name        := par_load_row.t_beneficiary3.name_first;
          v_contact_object.middle_name       := par_load_row.t_beneficiary3.middle_name;
          v_contact_object.date_of_birth     := par_load_row.t_beneficiary3.birth_date;
          v_contact_object.gender            := get_gender_id(par_load_row.t_beneficiary3.gender);
          v_contact_object.is_public_contact := par_load_row.t_beneficiary3.fpo;
          v_contact_object.resident_flag     := par_load_row.t_beneficiary3.resident;
          v_contact_object.note              := gv_file_name;
          -- Паспорт
          IF TRIM(par_load_row.t_beneficiary3.doc_num) IS NOT NULL
          THEN
            vr_ident_doc.id_doc_type_brief := par_load_row.t_beneficiary3.doc_type;
            vr_ident_doc.id_value          := par_load_row.t_beneficiary3.doc_num;
            vr_ident_doc.series_nr         := par_load_row.t_beneficiary3.doc_ser;
            vr_ident_doc.place_of_issue    := par_load_row.t_beneficiary3.doc_issued_by;
            vr_ident_doc.issue_date        := par_load_row.t_beneficiary3.doc_issued_date;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => vr_ident_doc);
          END IF;
          -- Адрес
          IF TRIM(par_load_row.t_beneficiary3.person_addres) IS NOT NULL
          THEN
            vr_address.address_type_brief := vc_default_address_type_brief;
            vr_address.address            := TRIM(par_load_row.t_beneficiary3.person_addres);
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => vr_address);
          END IF;
          -- Телефоны
          IF TRIM(par_load_row.t_beneficiary3.person_telephone) IS NOT NULL
          THEN
            v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_load_row.t_beneficiary3.person_telephone)
                                                       ,par_separator => ';');
            FOR i IN 1 .. v_splitted.count
            LOOP
              vr_phone.phone_type_brief := nvl(par_load_row.t_beneficiary3.person_telephone
                                              ,vc_bordero_phone_type_brief);
              vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
            
              IF vr_phone.phone_number IS NOT NULL
              THEN
                pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_phone_rec      => vr_phone);
              END IF;
            END LOOP;
          END IF;
        
          pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                  ,par_contact_id => par_load_row_out.t_beneficiary3.contact_id);
        END IF; -- конец Бенефициар 3
      
        ----------------------
        -- Бенефициар 4
        IF par_load_row.t_beneficiary4.name IS NOT NULL
        THEN
          v_contact_object                   := NULL;
          v_contact_object.name              := par_load_row.t_beneficiary4.name;
          v_contact_object.first_name        := par_load_row.t_beneficiary4.name_first;
          v_contact_object.middle_name       := par_load_row.t_beneficiary4.middle_name;
          v_contact_object.date_of_birth     := par_load_row.t_beneficiary4.birth_date;
          v_contact_object.gender            := get_gender_id(par_load_row.t_beneficiary4.gender);
          v_contact_object.is_public_contact := par_load_row.t_beneficiary4.fpo;
          v_contact_object.resident_flag     := par_load_row.t_beneficiary4.resident;
          v_contact_object.note              := gv_file_name;
          -- Паспорт
          IF TRIM(par_load_row.t_beneficiary4.doc_num) IS NOT NULL
          THEN
            vr_ident_doc.id_doc_type_brief := par_load_row.t_beneficiary4.doc_type;
            vr_ident_doc.id_value          := par_load_row.t_beneficiary4.doc_num;
            vr_ident_doc.series_nr         := par_load_row.t_beneficiary4.doc_ser;
            vr_ident_doc.place_of_issue    := par_load_row.t_beneficiary4.doc_issued_by;
            vr_ident_doc.issue_date        := par_load_row.t_beneficiary4.doc_issued_date;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => vr_ident_doc);
          END IF;
          -- Адрес
          IF TRIM(par_load_row.t_beneficiary4.person_addres) IS NOT NULL
          THEN
            vr_address.address_type_brief := vc_default_address_type_brief;
            vr_address.address            := TRIM(par_load_row.t_beneficiary4.person_addres);
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => vr_address);
          END IF;
          -- Телефоны
          IF TRIM(par_load_row.t_beneficiary4.person_telephone) IS NOT NULL
          THEN
            v_splitted := pkg_utils.get_splitted_string(par_string    => TRIM(par_load_row.t_beneficiary4.person_telephone)
                                                       ,par_separator => ';');
            FOR i IN 1 .. v_splitted.count
            LOOP
              vr_phone.phone_type_brief := nvl(par_load_row.t_beneficiary4.person_telephone
                                              ,vc_bordero_phone_type_brief);
              vr_phone.phone_number     := regexp_replace(TRIM(v_splitted(i)), '\s|\-');
            
              IF vr_phone.phone_number IS NOT NULL
              THEN
                pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_phone_rec      => vr_phone);
              END IF;
            END LOOP;
          END IF;
        
          pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                  ,par_contact_id => par_load_row_out.t_beneficiary4.contact_id);
        END IF; -- конец Бенефициар 4
      EXCEPTION
        WHEN OTHERS THEN
          RAISE ex_process_benefic_contact;
      END;
    
    END process_contact;
  
    -- Функция определения валюты по договору для продукта по брифу
    FUNCTION get_fund_id
    (
      par_fund_brief VARCHAR2
     ,par_product_id NUMBER
    ) RETURN fund.fund_id%TYPE IS
      v_fund_id fund.fund_id%TYPE;
    BEGIN
      IF par_fund_brief IS NOT NULL
      THEN
        SELECT fund_id
          INTO v_fund_id
          FROM fund            f
              ,t_prod_currency pc
         WHERE pc.product_id = par_product_id
           AND pc.currency_id = f.fund_id
           AND f.brief = par_fund_brief;
      END IF;
      RETURN v_fund_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_fund_id;
    END get_fund_id;
  
    -- Функция определения серии БСО по номеру и ПУ
    FUNCTION get_bso_series_id
    (
      par_product_id NUMBER
     ,par_start_date DATE
     ,par_agent_id   NUMBER
    ) RETURN bso_series.bso_series_id%TYPE IS
      v_bso_series_id bso_series.bso_series_id%TYPE;
    BEGIN
      BEGIN
        SELECT bs.bso_series_id
          INTO v_bso_series_id
          FROM bso_series           bs
              ,t_policy_form        pf
              ,t_product_bso_types  pbt
              ,t_policyform_product pp
         WHERE bs.t_product_conds_id = pf.t_policy_form_id
           AND pbt.bso_type_id = bs.bso_type_id
           AND pbt.t_product_id = par_product_id
           AND pp.t_product_id = pbt.t_product_id
           AND pp.t_policy_form_id = pf.t_policy_form_id
           AND trunc(par_start_date) BETWEEN pp.start_date AND pp.end_date;
      
      EXCEPTION
        WHEN too_many_rows THEN
          SELECT bs.bso_series_id
            INTO v_bso_series_id
            FROM bso_series           bs
                ,t_policy_form        pf
                ,t_product_bso_types  pbt
                ,t_policyform_product pp
           WHERE bs.t_product_conds_id = pf.t_policy_form_id
             AND pbt.bso_type_id = bs.bso_type_id
             AND pbt.t_product_id = par_product_id
             AND pp.t_product_id = pbt.t_product_id
             AND pp.t_policy_form_id = pf.t_policy_form_id
             AND trunc(par_start_date) BETWEEN pp.start_date AND pp.end_date
             AND EXISTS (SELECT NULL
                    FROM bso           b
                        ,bso_hist_type ht
                   WHERE b.bso_series_id = bs.bso_series_id
                     AND b.hist_type_id = ht.bso_hist_type_id
                     AND ht.brief = 'Передан'
                     AND b.contact_id = par_agent_id);
      END;
      RETURN v_bso_series_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_bso_series_id_not_found;
      WHEN too_many_rows THEN
        RAISE ex_get_bso_series_id_too_many;
    END get_bso_series_id;
  
    -- Функция определения серии БСО по номеру и ПУ
    FUNCTION get_bso_series_num(par_bso_series_id NUMBER) RETURN bso_series.series_num%TYPE IS
      v_bso_series_num bso_series.series_num%TYPE;
    BEGIN
      SELECT series_num INTO v_bso_series_num FROM bso_series WHERE bso_series_id = par_bso_series_id;
    
      RETURN v_bso_series_num;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_bso_series_num;
    END get_bso_series_num;
  
    -- Функция определения периодичности оплаты по брифу
    FUNCTION get_payment_term_id
    (
      par_payment_term_brief VARCHAR2
     ,par_product_id         NUMBER
    ) RETURN t_payment_terms.id%TYPE IS
      v_payment_terms_id t_payment_terms.id%TYPE;
    BEGIN
      IF par_payment_term_brief IS NOT NULL
      THEN
        SELECT DISTINCT pt.id
          INTO v_payment_terms_id
          FROM t_payment_terms      pt
              ,t_prod_payment_terms ppt
         WHERE ppt.product_id = par_product_id
           AND ppt.payment_term_id = pt.id
           AND pt.brief = par_payment_term_brief;
      END IF;
    
      RETURN v_payment_terms_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_payment_term_id;
    END get_payment_term_id;
  
    -- Функция определения периодичности выплаты по брифу
    FUNCTION get_payment_off_term_id
    (
      par_paymentoff_term_brief VARCHAR2
     ,par_product_id            NUMBER
    ) RETURN t_payment_terms.id%TYPE IS
      v_payment_off_terms_id t_payment_terms.id%TYPE;
    BEGIN
      IF par_paymentoff_term_brief IS NOT NULL
      THEN
        SELECT DISTINCT pt.id
          INTO v_payment_off_terms_id
          FROM t_payment_terms      pt
              ,t_prod_claim_payterm ppt
         WHERE pt.id = ppt.payment_terms_id
           AND ppt.product_id = par_product_id
           AND pt.brief = par_paymentoff_term_brief;
      END IF;
    
      RETURN v_payment_off_terms_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_payment_off_term_id;
    END get_payment_off_term_id;
  
    -- Функция определения выжидательного периода по дескрипшену
    FUNCTION get_waiting_period_id
    (
      par_waiting_period_desc VARCHAR2
     ,par_product_id          NUMBER
    ) RETURN t_period.id%TYPE IS
      v_waiting_period_id t_period.id%TYPE;
    BEGIN
      IF par_waiting_period_desc IS NOT NULL
      THEN
        SELECT DISTINCT p.id
          INTO v_waiting_period_id
          FROM t_period          p
              ,t_product_period  pp
              ,t_period_use_type ut
         WHERE pp.period_id = p.id
           AND pp.t_period_use_type_id = ut.t_period_use_type_id
           AND pp.product_id = par_product_id
           AND p.description = par_waiting_period_desc
           AND ut.brief = 'Выжидательный';
      END IF;
      RETURN v_waiting_period_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_waiting_period_id;
    END get_waiting_period_id;
  
    -- Функция определения условий вступления в силу по брифу
    FUNCTION get_confirm_conds_id
    (
      par_confirm_conds_brief VARCHAR2
     ,par_product_id          NUMBER
    ) RETURN t_confirm_condition.id%TYPE IS
      v_confirm_conds_id t_confirm_condition.id%TYPE;
    BEGIN
      IF par_confirm_conds_brief IS NOT NULL
      THEN
        SELECT DISTINCT cc.id
          INTO v_confirm_conds_id
          FROM t_confirm_condition cc
              ,t_product_conf_cond pcc
         WHERE pcc.product_id = par_product_id
           AND pcc.confirm_condition_id = cc.id
           AND pcc.is_default = 1;
      END IF;
    
      RETURN v_confirm_conds_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE ex_get_confirm_conds_id;
    END get_confirm_conds_id;
  
    -- Функция формирования массива бенефициаров по застрахованному
    FUNCTION create_asset_array(par_load_row typ_load_row) RETURN pkg_asset.t_assured_array IS
      v_assured_rec pkg_asset.t_assured_rec;
      v_benif_array pkg_asset.t_beneficiary_array := pkg_asset.t_beneficiary_array();
      v_benif_rec   pkg_asset.t_beneficiary_rec;
      v_benif_count NUMBER := 0;
    BEGIN
      v_assured_rec.contact_id := nvl(par_load_row.t_assured.contact_id
                                     ,par_load_row.t_insuree.contact_id);
    
      IF par_load_row.t_beneficiary1.contact_id IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        v_benif_array.extend(1);
        v_benif_rec.contact_id := par_load_row.t_beneficiary1.contact_id;
        v_benif_rec.relation_name := par_load_row.t_beneficiary1.relation_type;
        v_benif_rec.part_value := par_load_row.t_beneficiary1.percent;
        v_benif_array(v_benif_count) := v_benif_rec;
      END IF;
    
      IF par_load_row.t_beneficiary2.contact_id IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        v_benif_array.extend(1);
        v_benif_rec.contact_id := par_load_row.t_beneficiary1.contact_id;
        v_benif_rec.relation_name := par_load_row.t_beneficiary1.relation_type;
        v_benif_rec.part_value := par_load_row.t_beneficiary1.percent;
        v_benif_array(v_benif_count) := v_benif_rec;
      END IF;
    
      IF par_load_row.t_beneficiary3.contact_id IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        v_benif_array.extend(1);
        v_benif_rec.contact_id := par_load_row.t_beneficiary1.contact_id;
        v_benif_rec.relation_name := par_load_row.t_beneficiary1.relation_type;
        v_benif_rec.part_value := par_load_row.t_beneficiary1.percent;
        v_benif_array(v_benif_count) := v_benif_rec;
      END IF;
    
      IF par_load_row.t_beneficiary4.contact_id IS NOT NULL
      THEN
        v_benif_count := v_benif_count + 1;
        v_benif_array.extend(1);
        v_benif_rec.contact_id := par_load_row.t_beneficiary1.contact_id;
        v_benif_rec.relation_name := par_load_row.t_beneficiary1.relation_type;
        v_benif_rec.part_value := par_load_row.t_beneficiary1.percent;
        v_benif_array(v_benif_count) := v_benif_rec;
      END IF;
    
      v_assured_rec.benificiary_array := v_benif_array;
      RETURN pkg_asset.t_assured_array(v_assured_rec);
    END create_asset_array;
  
    PROCEDURE load_policy(v_load_row IN OUT NOCOPY typ_load_row) IS
    BEGIN
      SAVEPOINT before_load;
    
      -- Корректируем дату окончания ДС
      CASE v_load_row.t_policy.end_date_correct
        WHEN 'MINUS_SECOND' THEN
          v_load_row.t_policy.end_date := trunc(v_load_row.t_policy.end_date) - INTERVAL '1' SECOND;
        WHEN 'CEIL_TO_DAY_END' THEN
          v_load_row.t_policy.end_date := trunc(v_load_row.t_policy.end_date) + 1 - INTERVAL '1'
                                          SECOND;
        ELSE
          NULL;
      END CASE;
    
      -- Получаем параметры продукта по умолчанию
      v_product_defaults := pkg_products.get_product_defaults(par_product_brief => v_load_row.t_policy.product);
    
      -- Переопределяем параметры по умолчанию значениями из csv
      v_policy_settings.fund_id            := nvl(get_fund_id(v_load_row.t_policy.currency
                                                             ,v_product_defaults.product_id)
                                                 ,v_product_defaults.fund_id);
      v_policy_settings.payment_terms_id   := nvl(get_payment_term_id(v_load_row.t_policy.pay_term_name
                                                                     ,v_product_defaults.product_id)
                                                 ,v_product_defaults.payment_term_id);
      v_policy_settings.paymentoff_term_id := nvl(get_payment_off_term_id(v_load_row.t_policy.paymentoff_term_name
                                                                         ,v_product_defaults.product_id)
                                                 ,v_product_defaults.paymentoff_term_id);
      v_policy_settings.waiting_period_id  := nvl(get_waiting_period_id(v_load_row.t_policy.waiting_period_name
                                                                       ,v_product_defaults.product_id)
                                                 ,v_product_defaults.waiting_period_id);
      v_policy_settings.confirm_conds_id   := nvl(get_confirm_conds_id(v_load_row.t_policy.conf_cond_name
                                                                      ,v_product_defaults.product_id)
                                                 ,v_product_defaults.confirm_condition_id);
      v_policy_settings.agent_id           := get_agent_id(v_load_row.t_policy.agent);
    
      IF v_load_row.t_policy.bso_series IS NOT NULL
      THEN
        v_policy_settings.bso_series_id := pkg_bso.get_bso_series_id(v_load_row.t_policy.bso_series);
      ELSE
        v_policy_settings.bso_series_id := get_bso_series_id(v_product_defaults.product_id
                                                            ,DATE '1900-01-01' -- v_start_date
                                                            ,v_policy_settings.agent_id);
        v_load_row.t_policy.bso_series  := get_bso_series_num(v_policy_settings.bso_series_id);
      END IF;
    
      -- Генерируем номер БСО
      IF v_load_row.t_policy.bso_num IS NULL
         AND v_load_row.t_policy.policy_num IS NOT NULL
      THEN
        v_load_row.t_policy.bso_num := substr(v_load_row.t_policy.policy_num, 4, 6);
      ELSIF v_load_row.t_policy.bso_num = 'NO NUM'
            OR v_load_row.t_policy.bso_num IS NULL
      THEN
        BEGIN
          v_load_row.t_policy.bso_num := pkg_bso.gen_next_bso_number(v_policy_settings.bso_series_id
                                                                    ,v_policy_settings.agent_id);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE ex_gen_next_bso_number;
        END;
      END IF;
    
      -- Номер договора
      IF v_load_row.t_policy.policy_num IS NULL
      THEN
        v_load_row.t_policy.policy_num := v_load_row.t_policy.bso_series ||
                                          v_load_row.t_policy.bso_num;
      END IF;
    
      -- Создаем страхователя, застрахованного, Создаем бенефициаров
      process_contact(par_load_row => v_load_row, par_load_row_out => v_load_row);
    
      -- Массив застрахованных
      v_asset_array := create_asset_array(v_load_row);
    
      --Находим период ДС из доп. параметров 8.10.2014
      IF v_load_row.t_policy.period_name IS NOT NULL
      THEN
        v_period_id := dml_t_period.get_id_by_description(par_description => v_load_row.t_policy.period_name);
      END IF;
    
      -- Создаем договор
      BEGIN
        pkg_policy.create_universal(par_product_brief      => v_load_row.t_policy.product
                                   ,par_ag_num             => v_load_row.t_policy.agent
                                   ,par_start_date         => v_load_row.t_policy.start_date
                                   ,par_insuree_contact_id => to_number(v_load_row.t_insuree.contact_id)
                                   ,par_assured_array      => v_asset_array
                                   ,par_end_date           => v_load_row.t_policy.end_date
                                   ,par_bso_number         => v_load_row.t_policy.bso_num
                                   ,par_bso_series_id      => v_policy_settings.bso_series_id
                                   ,par_pol_num            => v_load_row.t_policy.policy_num
                                   ,par_pol_ser            => v_load_row.t_policy.bso_series
                                   ,par_fund_id            => v_policy_settings.fund_id
                  --  #368278: FW: договор ХКБ               --,par_confirm_date       => v_load_row.t_policy.signing_date
                                   ,par_notice_date          => v_load_row.t_policy.signing_date
                                   ,par_payment_term_id    => v_policy_settings.payment_terms_id
                                   ,par_paymentoff_term_id => v_policy_settings.paymentoff_term_id
                                   ,par_waiting_period_id  => v_policy_settings.waiting_period_id
                                   ,par_confirm_conds_id   => v_policy_settings.confirm_conds_id
                                   ,par_base_sum           => v_load_row.t_policy.ins_sum
                                   ,par_comment            => gv_file_name
                                   ,par_ph_comment         => gv_file_name
                                   ,par_policy_header_id   => v_policy_header_id
                                   ,par_policy_id          => v_policy_id
                                   ,par_period_id          => v_period_id);
      EXCEPTION
        WHEN OTHERS THEN
          DECLARE
            v_error_msg load_file_rows.row_comment%TYPE;
          BEGIN
            v_error_msg := SQLERRM;
            ROLLBACK TO before_load;
            pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                               ,par_load_order_num       => gv_log_order_num
                                               ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_CREATE_UNIVERSAL')
                                               ,par_log_msg              => 'Нарушение целостности при попытке создания договора страхования: ' ||
                                                                            v_error_msg
                                               ,par_load_stage           => pkg_load_logging.get_process);
          END;
          RAISE ex_create_universal;
      END;
    
      -- Проверка премии по договору
      IF v_load_row.t_policy.ins_prem IS NOT NULL
      THEN
        BEGIN
          pkg_load_policies.premium_check(par_policy_id        => v_policy_id
                                         ,par_original_premium => v_load_row.t_policy.ins_prem);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE ex_premium_check;
        END;
      END IF;
    
      -- Обновление номера кредитного договора
      UPDATE as_assured
         SET credit_account_number = v_load_row.t_policy.credit_num
       WHERE as_assured_id = (SELECT as_asset_id FROM as_asset WHERE p_policy_id = v_policy_id)
         AND assured_contact_id =
             nvl(v_load_row.t_assured.contact_id, v_load_row.t_insuree.contact_id);
    
      BEGIN
        SAVEPOINT before_change_status;
      
        -- Статус строки = Обработан
        IF pkg_load_file_to_table.get_file_row_cache()
         .row_status <> pkg_load_file_to_table.get_nc_error
        THEN
          IF v_load_row.t_policy.status_target IS NULL
          THEN
            pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_part_loaded
                                                         ,par_row_comment => 'Договор добавлен, целевой статус не определен');
          ELSE
            -- Обновление статуса
            IF upper(v_load_row.t_policy.status_target) = upper('Передано агенту')
            THEN
              doc.set_doc_status(v_policy_id, 'PASSED_TO_AGENT');
            
              pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_loaded
                                                           ,par_row_comment => 'Договор добавлен');
            ELSIF v_load_row.t_policy.status_target = 'Договор подписан'
            THEN
              doc.set_doc_status(v_policy_id, 'PASSED_TO_AGENT');
              doc.set_doc_status(v_policy_id, 'CONCLUDED');
            
              pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_loaded
                                                           ,par_row_comment => 'Договор добавлен');
            ELSE
              doc.set_doc_status(v_policy_id, 'CREDIT_REVISION');
            
              pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_part_loaded
                                                           ,par_row_comment => 'Договор добавлен, не определена цепочка перехода в целевой статус "' ||
                                                                               v_load_row.t_policy.status_target || '"');
            END IF;
          
          END IF;
        ELSE
          doc.set_doc_status(v_policy_id, 'CREDIT_REVISION');
          pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_part_loaded
                                                       ,par_row_comment => 'Договор добавлен, по результатам предварительной проверки требуется доработка');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          DECLARE
            v_error_msg load_file_rows.row_comment%TYPE;
          BEGIN
            v_error_msg := SQLERRM;
            ROLLBACK TO before_change_status;
            doc.set_doc_status(v_policy_id, 'CREDIT_REVISION');
            pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_part_loaded
                                                         ,par_row_comment => 'Договор добавлен, целевой статус не достигнут: ' ||
                                                                             v_error_msg);
            pkg_load_logging.add_error(par_load_file_rows_id    => gv_load_file_rows_id
                                      ,par_load_order_num       => gv_log_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_STATUS_CHANGE')
                                      ,par_log_msg              => 'Договор добавлен, целевой статус не достигнут: ' ||
                                                                   v_error_msg
                                      ,log_row_status           => pkg_load_file_to_table.get_nc_error
                                      ,par_load_stage           => pkg_load_logging.get_process);
          END;
          RAISE ex_change_status;
      END;
    
    EXCEPTION
      WHEN ex_get_agent_id THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_AGENT_EXISTS')
                                           ,par_log_msg              => 'Не удалось определить агента по договору'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_get_row_values THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                           ,par_log_msg              => 'Не удалось разобрать значения полей файла'
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      WHEN ex_process_insuree_contact THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_CONTACT_PROCESS')
                                           ,par_log_msg              => 'Не удалось добавить информацию по страхователю'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_process_assured_contact THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_CONTACT_PROCESS')
                                           ,par_log_msg              => 'Не удалось добавить информацию по застрахованному'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_process_benefic_contact THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_CONTACT_PROCESS')
                                           ,par_log_msg              => 'Не удалось добавить информацию по бенефициару'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_get_fund_id THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_PRODUCT_SETTINGS')
                                           ,par_log_msg              => 'Для данного продукта недоступна выбранная валюта оплаты'
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      WHEN ex_get_bso_series_id_not_found THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_BSO_ISSUE')
                                           ,par_log_msg              => 'Не удалось определить серию БСО по продукту и агенту'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_get_bso_series_id_too_many THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_BSO_ISSUE')
                                           ,par_log_msg              => 'Не удалось однозначно определить серию БСО по продукту и агентуу'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_get_bso_series_num THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_BSO_ISSUE')
                                           ,par_log_msg              => 'Не удалось определить номер серии БСО по идентификатору'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_gen_next_bso_number THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_BSO_ISSUE')
                                           ,par_log_msg              => 'Не удалось сгенерировать номер свободного БСО'
                                           ,par_load_stage           => pkg_load_logging.get_process);
      WHEN ex_get_payment_term_id THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_PRODUCT_SETTINGS')
                                           ,par_log_msg              => 'Для данного продукта недоступна выбранная периодичность оплаты'
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      WHEN ex_get_payment_off_term_id THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_PRODUCT_SETTINGS')
                                           ,par_log_msg              => 'Для данного продукта недоступна выбранная периодичность выплаты'
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      WHEN ex_get_waiting_period_id THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_PRODUCT_SETTINGS')
                                           ,par_log_msg              => 'Для данного продукта недоступен выбранный выжидательный период'
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      WHEN ex_get_confirm_conds_id THEN
        ROLLBACK TO before_load;
        pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                           ,par_load_order_num       => gv_log_order_num
                                           ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_PRODUCT_SETTINGS')
                                           ,par_log_msg              => 'Для данного продукта недоступны выбранные условия вступления в силу'
                                           ,par_load_stage           => pkg_load_logging.get_check_single);
      WHEN ex_create_universal THEN
        NULL;
      WHEN ex_premium_check THEN
        DECLARE
          v_result_premium NUMBER;
        BEGIN
          SELECT premium INTO v_result_premium FROM p_policy WHERE policy_id = v_policy_id;
          ROLLBACK TO before_load;
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_PREMIUM')
                                             ,par_log_msg              => 'Исходная премия не равна полученной (' ||
                                                                          v_result_premium || ')'
                                             ,par_load_stage           => pkg_load_logging.get_process_commit);
        END;
      WHEN ex_change_status THEN
        NULL;
      WHEN OTHERS THEN
        DECLARE
          v_error_msg load_file_rows.row_comment%TYPE;
        BEGIN
          v_error_msg := SQLERRM;
          ROLLBACK TO before_load;
          pkg_load_logging.set_critical_error(par_load_file_rows_id    => gv_load_file_rows_id
                                             ,par_load_order_num       => gv_log_order_num
                                             ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('UNDEFINED_GROUP')
                                             ,par_log_msg              => 'Ошибка в процессе создания договора. Договор не загружен: ' ||
                                                                          v_error_msg
                                             ,par_load_stage           => pkg_load_logging.get_process);
        END;
    END load_policy;
  
    --    procedure
  
  BEGIN
    pkg_load_file_to_table.init_file(par_load_file_id => par_load_file_id);
  
    gv_file_name     := get_file_name(par_load_file_id);
    gv_log_order_num := pkg_load_file_to_table.get_current_log_load_order_num;
  
    FOR cur_file_row IN (SELECT *
                           FROM load_file_rows
                          WHERE 1 = 1
                            AND row_status IN (pkg_load_file_to_table.get_checked
                                              ,pkg_load_file_to_table.get_nc_error)
                            AND load_file_id = par_load_file_id)
    LOOP
      gv_load_file_rows_id := cur_file_row.load_file_rows_id;
      v_policy_id          := NULL;
    
      pkg_load_file_to_table.cache_row(gv_load_file_rows_id);
    
      v_load_row := get_row_values;
    
      -- Загружаем договор страхования
      load_policy(v_load_row => v_load_row);
    
    END LOOP; -- конец цикл по всем строкам файла
  END load_bank_policy;

END pkg_load_bank_policies;
/
