CREATE OR REPLACE PACKAGE pkg_barcode IS

  -- Author  : ALEKSEY.PIYADIN
  -- Created : 15.04.2014
  -- Purpose : 239416 ФТ по штрих-кодированию

  /*
    Вычисление контрольной суммы для уникального идентификатора (предполагается YYYYYYYYYS)
  */
  FUNCTION get_inn_control_num(par_number NUMBER) RETURN NUMBER;

  /*
    Возвращает минимальный ИД идентифицирующего документа по типу par_doc_type_brief и
    признаку использования par_is_used для контакта par_contact_id
  */

  FUNCTION get_min_doc_by_type
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE DEFAULT NULL
   ,par_is_used        cn_contact_ident.is_used%TYPE DEFAULT NULL
  ) RETURN cn_contact_ident.table_id%TYPE;

  /*
    Возвращает Серию + Номер идентифицирующего документа по правилам 239416 ФТ по штрих-кодированию
  */
  FUNCTION get_doc_string(par_contact_id contact.contact_id%TYPE) RETURN VARCHAR2;

  /*
    Генерирует контрольную сумму по алгоритму Adler-32
  */
  FUNCTION get_adler32_control_sum(par_string VARCHAR2) RETURN NUMBER;

  /*
    Генерирует контрольную сумму по алгоритму Adler-32 в рамках штрих-кодирования
  */
  FUNCTION get_control_sum(par_policy_id p_policy.policy_id%TYPE DEFAULT NULL) RETURN VARCHAR2;

  /*
    Функция получения bso_id по policy_id
  */
  FUNCTION get_bso_id_by_policy_id(par_policy_id p_policy.policy_id%TYPE) RETURN bso.bso_id%TYPE;

  /*
    Функция формирования штрих-кода по bso_id или policy_id
  */
  FUNCTION get_barcode
  (
    par_bso_id    bso.bso_id%TYPE DEFAULT NULL
   ,par_policy_id p_policy.policy_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;

  /*
    Процедура пересчета штрих-кода на переходе статусов ДС
  */
  PROCEDURE policy_barcode_refresh(par_policy_id p_policy.policy_id%TYPE);

  /*
    Процедура формирования штрих-кода при создании БСО
  */
  PROCEDURE bso_barcode_create(par_bso_id bso.bso_id%TYPE);

  /*
    Процедура распознавания штрих-кода
  */
  PROCEDURE recognize_barcode
  (
    par_barcode_num     IN VARCHAR2
   ,par_session_id      IN t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
   ,par_status_out      OUT t_barcode_scan_hist.session_status_id%TYPE
   ,par_document_id_out OUT NUMBER
  );

  /*
    Функция начала сессии сканирования
  */
  FUNCTION scan_session_start RETURN t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE;

  /*
    Процедура окончания сессии сканирования
  */
  PROCEDURE scan_session_end(par_session_id t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE);

  /*
    Процедура сохранения результата перевода статуса по ДС
  */
  PROCEDURE set_change_status_msg
  (
    par_session_id        t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
   ,par_change_status_msg t_barcode_scan_hist.change_status_msg%TYPE
  );

  /*
    Процедура формирования записи в таблице «Реквизиты штрих кода»
  */
  PROCEDURE set_barcode_rekv
  (
    par_bso_id      bso.bso_id%TYPE
   ,par_policy_id   p_policy.policy_id%TYPE
   ,par_barcode_num bso.barcode_num%TYPE
  );

  /*
    Процедура перевода статуса договора страхования
  */
  PROCEDURE change_policy_status
  (
    par_session_id             IN t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
   ,par_policy_id              IN p_policy.policy_id%TYPE
   ,par_src_doc_status_ref_id  IN doc_status_ref.doc_status_ref_id%TYPE
   ,par_dest_doc_status_ref_id IN doc_status_ref.doc_status_ref_id%TYPE
   ,par_change_status_msg      OUT t_barcode_scan_hist.change_status_msg%TYPE
  );

END pkg_barcode;
/
CREATE OR REPLACE PACKAGE BODY pkg_barcode IS
  /*
    Вычисление контрольной суммы для уникального идентификатора (предполагается YYYYYYYYYS)
  */
  FUNCTION get_inn_control_num(par_number NUMBER) RETURN NUMBER IS
    v_control_num NUMBER(10) := 0;
  BEGIN
    v_control_num := v_control_num + to_number(substr(par_number, 1, 1)) * 2;
    v_control_num := v_control_num + to_number(substr(par_number, 2, 1)) * 4;
    v_control_num := v_control_num + to_number(substr(par_number, 3, 1)) * 10;
    v_control_num := v_control_num + to_number(substr(par_number, 4, 1)) * 3;
    v_control_num := v_control_num + to_number(substr(par_number, 5, 1)) * 5;
    v_control_num := v_control_num + to_number(substr(par_number, 6, 1)) * 9;
    v_control_num := v_control_num + to_number(substr(par_number, 7, 1)) * 4;
    v_control_num := v_control_num + to_number(substr(par_number, 8, 1)) * 6;
    v_control_num := v_control_num + to_number(substr(par_number, 9, 1)) * 8;
    v_control_num := MOD(v_control_num, 11);
    v_control_num := MOD(v_control_num, 10);

    RETURN v_control_num;
  END get_inn_control_num;

  /*
    Возвращает минимальный ИД идентифицирующего документа по типу par_doc_type_brief и
    признаку использования par_is_used для контакта par_contact_id
  */
  FUNCTION get_min_doc_by_type
  (
    par_contact_id     contact.contact_id%TYPE
   ,par_doc_type_brief t_id_type.brief%TYPE DEFAULT NULL
   ,par_is_used        cn_contact_ident.is_used%TYPE DEFAULT NULL
  ) RETURN cn_contact_ident.table_id%TYPE IS
    v_ident_doc_id cn_contact_ident.table_id%TYPE;
  BEGIN
    SELECT MIN(ci.table_id)
      INTO v_ident_doc_id
      FROM cn_contact_ident ci
          ,t_id_type        it
     WHERE ci.contact_id = par_contact_id
       AND ci.id_type = it.id
       AND it.brief = nvl(par_doc_type_brief, it.brief)
       AND ci.is_used = nvl(par_is_used, ci.is_used);

    RETURN v_ident_doc_id;
  END get_min_doc_by_type;

  /*
    Возвращает Серию + Номер идентифицирующего документа по правилам 239416 ФТ по штрих-кодированию
  */
  FUNCTION get_doc_string(par_contact_id contact.contact_id%TYPE) RETURN VARCHAR2 IS
    v_doc_str VARCHAR2(500);
  BEGIN
    SELECT ci.serial_nr || ci.id_value
      INTO v_doc_str
      FROM cn_contact_ident ci
     WHERE ci.table_id = (SELECT CASE
                                   WHEN ct.ext_id = 'ФизЛицо'
                                        AND ct.brief = 'ФЛ' THEN
                                    coalesce(get_min_doc_by_type(par_contact_id, 'PASS_RF', 1)
                                            ,get_min_doc_by_type(par_contact_id, 'PASS_SSSR', 1)
                                            ,get_min_doc_by_type(par_contact_id, 'PASS_IN', 1)
                                            ,get_min_doc_by_type(par_contact_id, 'BIRTH_CERT', 1)
                                            ,get_min_doc_by_type(par_contact_id))
                                   ELSE
                                    coalesce(get_min_doc_by_type(par_contact_id, 'INN', 1)
                                            ,get_min_doc_by_type(par_contact_id, 'INN'))
                                 END
                            FROM contact        c
                                ,t_contact_type ct
                           WHERE 1 = 1
                             AND c.contact_type_id = ct.id(+)
                             AND c.contact_id = par_contact_id);

    RETURN v_doc_str;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_doc_string;

  /*
    Генерирует контрольную сумму по алгоритму Adler-32
  */
  FUNCTION get_adler32_control_sum(par_string VARCHAR2) RETURN NUMBER IS
    v_sum_a  NUMBER := 1;
    v_sum_b  NUMBER := 0;
    v_result NUMBER;
  BEGIN
    FOR i IN 1 .. length(par_string)
    LOOP
      v_sum_a := v_sum_a + ascii(substr(par_string, i, 1));
      v_sum_b := v_sum_b + v_sum_a;
    END LOOP;

    v_sum_a  := MOD(v_sum_a, 65532);
    v_sum_b  := MOD(v_sum_b, 65532);
    v_result := MOD(v_sum_a + v_sum_b, 10000);

    RETURN v_result;
  END get_adler32_control_sum;

  /*
    Генерирует контрольную сумму по алгоритму Adler-32 в рамках штрих-кодирования
  */
  FUNCTION get_control_sum(par_policy_id p_policy.policy_id%TYPE DEFAULT NULL) RETURN VARCHAR2 IS
    v_result VARCHAR2(4);

    /*
      Генерирует строку на вход алгоритма Adler-32
    */
    FUNCTION get_adler32_string(par_policy_id p_policy.policy_id%TYPE) RETURN VARCHAR2 IS
      v_policy_num p_policy.pol_num%TYPE;
      v_start_date p_pol_header.start_date%TYPE;
      v_end_date   p_policy.end_date%TYPE;
      v_ins_amount p_policy.ins_amount%TYPE;
      v_premium    p_policy.premium%TYPE;
      v_fund       fund.brief%TYPE;
      v_cover      VARCHAR2(4000);
      v_insured    VARCHAR2(4000);
      v_assured    VARCHAR2(4000);

    BEGIN
      SELECT nvl(pp.pol_num, ph.ids)
            ,ph.start_date
            ,pp.end_date
            ,pp.ins_amount
            ,pp.premium
            ,f.brief
        INTO v_policy_num
            ,v_start_date
            ,v_end_date
            ,v_ins_amount
            ,v_premium
            ,v_fund
        FROM p_policy     pp
            ,p_pol_header ph
            ,fund         f
       WHERE 1 = 1
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.fund_id = f.fund_id
         AND pp.policy_id = par_policy_id;

      FOR cur_cover IN (SELECT plo.description
                              ,pc.fee
                          FROM as_asset           ass
                              ,p_cover            pc
                              ,t_prod_line_option plo
                         WHERE 1 = 1
                           AND ass.as_asset_id = pc.p_cover_id
                           AND pc.t_prod_line_option_id = plo.id
                           AND ass.p_policy_id = par_policy_id
                         ORDER BY plo.id)
      LOOP
        v_cover := v_cover || cur_cover.description || cur_cover.fee;
      END LOOP;

      SELECT c.obj_name_orig || to_char(cp.date_of_birth, 'dd.mm.yyyy') ||
             get_doc_string(c.contact_id)
        INTO v_insured
        FROM as_insured ai
            ,contact    c
            ,cn_person  cp
       WHERE 1 = 1
         AND ai.insured_contact_id = c.contact_id
         AND c.contact_id = cp.contact_id
         AND ai.policy_id = par_policy_id;

      FOR cur_assured IN (SELECT c.obj_name_orig || to_char(cp.date_of_birth, 'dd.mm.yyyy') ||
                                 get_doc_string(c.contact_id) assured
                            FROM as_asset   ass
                                ,as_assured asu
                                ,contact    c
                                ,cn_person  cp
                           WHERE 1 = 1
                             AND ass.as_asset_id = asu.as_assured_id
                             AND asu.assured_contact_id = c.contact_id
                             AND c.contact_id = cp.contact_id
                             AND ass.p_policy_id = par_policy_id
                           ORDER BY c.contact_id)
      LOOP
        v_assured := v_assured || cur_assured.assured;
      END LOOP;

      RETURN REPLACE(v_policy_num || to_char(v_start_date, 'dd.mm.yyyy') ||
                     to_char(v_end_date, 'dd.mm.yyyy') || v_ins_amount || v_premium || v_cover ||
                     v_fund || v_insured || v_assured
                    ,','
                    ,'.');
    END get_adler32_string;

  BEGIN
    IF par_policy_id IS NULL
    THEN
      v_result := '0000';
    ELSE
      v_result := lpad(get_adler32_control_sum(get_adler32_string(par_policy_id)), 4, '0');
    END IF;

    RETURN v_result;
  END get_control_sum;

  /*
    Функция получения bso_id по policy_id
  */
  FUNCTION get_bso_id_by_policy_id(par_policy_id p_policy.policy_id%TYPE) RETURN bso.bso_id%TYPE IS
    v_bso_id bso.bso_id%TYPE;
    v_flags  NUMBER;
    v_count  NUMBER;
  BEGIN
    SELECT *
      INTO v_bso_id
          ,v_flags
          ,v_count
      FROM (SELECT b.bso_id
                  ,SUM(nvl(b.is_pol_num, 0)) over() flags
                  ,COUNT(*) over() cnt
              FROM bso           b
                  ,bso_series    bs
                  ,bso_type      bt
                  ,bso_hist      bh
                  ,bso_hist_type bht
                  ,p_policy      pp
             WHERE 1 = 1
               AND b.bso_series_id = bs.bso_series_id
               AND bs.bso_type_id = bt.bso_type_id
               AND b.bso_hist_id = bh.bso_hist_id
               AND bh.hist_type_id = bht.bso_hist_type_id
               AND b.pol_header_id = pp.pol_header_id
               AND bt.kind_brief IN ('Заявление', 'Полис')
               AND bht.brief NOT IN ('Испорчен')
               AND pp.policy_id = par_policy_id
             ORDER BY b.is_pol_num DESC)
     WHERE rownum = 1;

    IF v_count = 1
       OR v_flags = 1
    THEN
      RETURN v_bso_id;
    ELSIF v_count > 1
          AND v_flags = 0
    THEN
      --Несколько строк и ни одного флага не выставлено
      raise_application_error(-20001
                             ,'Не выставлен флаг "Использовать как номер договора" ни у одного БСО!');
    ELSIF v_count > 1
          AND v_flags > 1
    THEN
      -- Выставлен флаг "Использовать как номер договора" сразу у нескольких БСО
      SELECT b.bso_id
        INTO v_bso_id
        FROM bso           b
            ,bso_series    bs
            ,bso_type      bt
            ,bso_hist      bh
            ,bso_hist_type bht
            ,p_policy      pp
            ,p_pol_header  ph
       WHERE 1 = 1
         AND b.bso_series_id = bs.bso_series_id
         AND bs.bso_type_id = bt.bso_type_id
         AND b.bso_hist_id = bh.bso_hist_id
         AND bh.hist_type_id = bht.bso_hist_type_id
         AND b.pol_header_id = pp.pol_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND bt.kind_brief IN ('Заявление', 'Полис')
         AND bht.brief NOT IN ('Испорчен')
         AND ph.ids LIKE '%' || b.num || '%'
         AND pp.policy_id = par_policy_id;

      RETURN v_bso_id;
    ELSE
      RAISE no_data_found;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Нет ни одного БСО для формирования штрих-кода!');
  END get_bso_id_by_policy_id;

  /*
    Функция формирования штрих-кода по bso_id или policy_id
  */
  FUNCTION get_barcode
  (
    par_bso_id    bso.bso_id%TYPE DEFAULT NULL
   ,par_policy_id p_policy.policy_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_result VARCHAR2(19);
  BEGIN
    SELECT CASE bt.kind_brief
             WHEN 'Полис' THEN
              '01'
             WHEN 'Заявление' THEN
              '02'
             WHEN 'Квитанция' THEN
              '03'
           END || CASE bs.chars_in_num
             WHEN 6 THEN
              bs.series_num || b.num ||
              pkg_barcode.get_inn_control_num(to_number(bs.series_num || b.num))
             ELSE
              bs.series_num || b.num
           END || lpad(nvl(pp.version_num, '0'), 3, '0') || pkg_barcode.get_control_sum(par_policy_id)
      INTO v_result
      FROM bso        b
          ,bso_series bs
          ,bso_type   bt
          ,p_policy   pp
     WHERE 1 = 1
       AND b.bso_series_id = bs.bso_series_id
       AND bs.bso_type_id = bt.bso_type_id
       AND b.pol_header_id = pp.pol_header_id(+)
       AND pp.policy_id(+) = par_policy_id
       AND b.bso_id = CASE
             WHEN par_policy_id IS NULL THEN
              par_bso_id
             ELSE
              get_bso_id_by_policy_id(par_policy_id)
           END;

    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Нет ни одного БСО для формирования штрих-кода!');
    WHEN too_many_rows THEN
      raise_application_error(-20002
                             ,'Найдено несколько БСО для формирования штрих-кода!');
  END get_barcode;

  /*
    Процедура проверки уникальности штрих-кода
  */
  PROCEDURE check_barcode_unique
  (
    par_bso_id      bso.bso_id%TYPE
   ,par_barcode_num bso.barcode_num%TYPE
  ) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT 1
              FROM bso
             WHERE barcode_num = par_barcode_num
               AND bso_id <> par_bso_id);

    IF v_count > 0
    THEN
      raise_application_error(-20001
                             ,'Штрих-код используется, необходима проверка исходных данных!');
    END IF;
  END check_barcode_unique;

  /*
    Процедура формирования записи в таблице «Реквизиты штрих кода»
  */
  PROCEDURE set_barcode_rekv
  (
    par_bso_id      bso.bso_id%TYPE
   ,par_policy_id   p_policy.policy_id%TYPE
   ,par_barcode_num bso.barcode_num%TYPE
  ) IS
  BEGIN
    MERGE INTO t_barcode trg
    USING (SELECT par_bso_id bso_id
                 ,par_policy_id policy_id
                 ,substr(par_barcode_num, 16, 4) check_sum
             FROM dual) src
    ON (trg.bso_id = src.bso_id)
    WHEN MATCHED THEN
      UPDATE
         SET trg.check_sum = src.check_sum
            ,trg.policy_id = src.policy_id
    WHEN NOT MATCHED THEN
      INSERT
        (t_barcode_id, bso_id, policy_id, check_sum, sys_user_id)
      VALUES
        (sq_t_barcode.nextval
        ,src.bso_id
        ,src.policy_id
        ,src.check_sum
        ,nvl((SELECT sys_user_id FROM sys_user WHERE sys_user_name = USER)
            ,(SELECT sys_user_id FROM sys_user WHERE sys_user_name = 'AUTO_REPORTS')));
  END set_barcode_rekv;

  /*
    Процедура пересчета штрих-кода на переходе статусов ДС
  */
  PROCEDURE policy_barcode_refresh(par_policy_id p_policy.policy_id%TYPE) IS
    c_proc_name CONSTANT VARCHAR2(100) := 'pkg_barcode.policy_barcode_refresh';

    v_bso_id              bso.bso_id%TYPE;
    v_bso         dml_bso.tt_bso;
    v_old_barcode bso.barcode_num%TYPE;
  
    FUNCTION bso_type_for_barcod_exists(par_policy_id NUMBER) RETURN BOOLEAN IS
      v_is_need_barcode_refresh NUMBER;
    BEGIN
    
      SELECT COUNT(1)
        INTO v_is_need_barcode_refresh
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy                p
                    ,p_pol_header            ph
                    ,t_product               pr
                    ,bso_type                t
                    ,ins.t_product_bso_types pb
               WHERE ph.policy_header_id = p.pol_header_id
                 AND pr.product_id = ph.product_id
                 AND p.policy_id = par_policy_id
                 AND pb.t_product_id = pr.product_id
                 AND t.bso_type_id = pb.bso_type_id
                 AND t.is_barcode_generate = 1);
    
      RETURN v_is_need_barcode_refresh > 0;
    
    END bso_type_for_barcod_exists;
  
    FUNCTION is_barcode_refreshment_needed(par_bso_series_id NUMBER) RETURN BOOLEAN IS
    v_is_printing_house   bso_type.is_printing_house%TYPE;
    v_is_barcode_generate bso_type.is_barcode_generate%TYPE;
  BEGIN
    SELECT bt.is_printing_house
          ,bt.is_barcode_generate
      INTO v_is_printing_house
          ,v_is_barcode_generate
        FROM bso_series bs
          ,bso_type   bt
       WHERE bs.bso_series_id = par_bso_series_id
         AND bs.bso_type_id = bt.bso_type_id;
    
      RETURN v_is_printing_house = 0 AND v_is_barcode_generate = 1;
    END is_barcode_refreshment_needed;
  BEGIN
    IF bso_type_for_barcod_exists(par_policy_id)
    THEN
    
      v_bso_id := get_bso_id_by_policy_id(par_policy_id);
      v_bso    := dml_bso.get_record(par_bso_id => v_bso_id, par_lock_record => TRUE);

    -- Если штрих-код надо формировать и бланк полиса печатается в Типографии, то обновляем штрих-код
      IF is_barcode_refreshment_needed(v_bso.bso_series_id)
    THEN

        v_old_barcode := v_bso.barcode_num;

        v_bso.barcode_num := get_barcode(NULL, par_policy_id);

        IF nvl(v_old_barcode, 0) <> v_bso.barcode_num
      THEN
        -- Апдейт штрих-кода
          dml_bso.update_record(v_bso);
        -- Запись в таблицу "Реквизиты штрих кода"
          set_barcode_rekv(v_bso.bso_id, par_policy_id, v_bso.barcode_num);
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise('Ошибка выполнения процедуры ' || c_proc_name || ': ' ||
               ex.get_ora_trimmed_errmsg(SQLERRM));
  END policy_barcode_refresh;

  /*
    Процедура формирования штрих-кода при создании БСО
  */
  PROCEDURE bso_barcode_create(par_bso_id bso.bso_id%TYPE) IS
    v_proc_name VARCHAR2(100) := 'pkg_barcode.bso_barcode_create';

    v_is_barcode_generate bso_type.is_barcode_generate%TYPE;
    v_barcode             bso.barcode_num%TYPE;
  BEGIN
    SELECT bt.is_barcode_generate
      INTO v_is_barcode_generate
      FROM bso        b
          ,bso_series bs
          ,bso_type   bt
     WHERE 1 = 1
       AND b.bso_series_id = bs.bso_series_id
       AND bs.bso_type_id = bt.bso_type_id
       AND b.bso_id = par_bso_id;

    IF v_is_barcode_generate = 1
    THEN
      v_barcode := get_barcode(par_bso_id, NULL);

      -- Проверка уникальности
      check_barcode_unique(par_bso_id, v_barcode);
      -- Апдейт штрих-кода
      UPDATE bso SET barcode_num = v_barcode WHERE bso_id = par_bso_id;
      -- Запись в таблицу "Реквизиты штрих кода"
      set_barcode_rekv(par_bso_id, NULL, v_barcode);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ощибка выполнения процедуры ' || v_proc_name ||
                              '. Штрих-код для БСО не сформирован!');
  END bso_barcode_create;

  /*
    Процедура распознавания штрих-кода
  */
  PROCEDURE recognize_barcode
  (
    par_barcode_num     IN VARCHAR2
   ,par_session_id      IN t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
   ,par_status_out      OUT t_barcode_scan_hist.session_status_id%TYPE
   ,par_document_id_out OUT NUMBER
  ) IS

    v_status      NUMBER;
    v_bso_id      bso.bso_id%TYPE;
    v_document_id NUMBER := NULL;

    /*
      Процедура проверки корректности считанного штрих-кода
    */
    FUNCTION check_barcode_format(par_barcode_num bso.barcode_num%TYPE) RETURN NUMBER IS
      v_check_number NUMBER;
      v_result       NUMBER := 1;
    BEGIN
      BEGIN
        v_check_number := to_number(par_barcode_num);

      EXCEPTION
        WHEN value_error THEN
          v_result := 0;
      END;

      IF length(par_barcode_num) NOT IN (18, 19)
      THEN
        v_result := 0;
      END IF;

      RETURN v_result;
    END check_barcode_format;

    /*
      Процедура проверки существования штрих-кода
    */
    FUNCTION check_barcode_exists(par_barcode_num bso.barcode_num%TYPE) RETURN bso.bso_id%TYPE IS
      v_bso_id bso.bso_id%TYPE;
    BEGIN
      SELECT bso_id INTO v_bso_id FROM bso WHERE barcode_num = par_barcode_num;

      RETURN v_bso_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 0;
    END check_barcode_exists;

    /*
      Процедура записи истории сканирования
    */
    PROCEDURE set_barcode_sess_hist
    (
      par_barcode_num VARCHAR2
     ,par_session_id  t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
     ,par_status      t_barcode_scan_hist.session_status_id%TYPE
     ,par_bso_id      bso.bso_id%TYPE
    ) IS
      v_max_hist_id t_barcode_scan_hist.t_barcode_scan_hist_id%TYPE;
      v_old_barcode t_barcode_scan_hist.barcode_num%TYPE := '0';
    BEGIN
      SELECT MAX(t_barcode_scan_hist_id)
        INTO v_max_hist_id
        FROM t_barcode_scan_hist
       WHERE t_barcode_scan_sessn_id = par_session_id;

      IF v_max_hist_id IS NOT NULL
      THEN
        SELECT barcode_num
          INTO v_old_barcode
          FROM t_barcode_scan_hist
         WHERE t_barcode_scan_hist_id = v_max_hist_id;
      END IF;

      IF nvl(v_old_barcode, 0) <> par_barcode_num
      THEN
        INSERT INTO ven_t_barcode_scan_hist
          (t_barcode_scan_sessn_id, barcode_num, session_status_id, bso_id)
        VALUES
          (par_session_id, par_barcode_num, par_status, par_bso_id);
        COMMIT;
      END IF;
    END set_barcode_sess_hist;

  BEGIN
    -- 3 – «Ошибка сканирования»
    v_status := check_barcode_format(par_barcode_num);
    IF v_status = 0
    THEN
      v_status := 2;
      -- Запись истории
      set_barcode_sess_hist(par_barcode_num, par_session_id, v_status, NULL);
    ELSE
      -- 2 – «Документ не найден»
      v_bso_id := check_barcode_exists(par_barcode_num);
      IF v_bso_id = 0
      THEN
        v_status := 1;
        -- Запись истории
        set_barcode_sess_hist(par_barcode_num, par_session_id, v_status, NULL);
      ELSE
        -- 1 – «Успешно»
        -- Запись истории
        set_barcode_sess_hist(par_barcode_num, par_session_id, 0, v_bso_id);
        v_status := 0;

        BEGIN
          SELECT policy_id INTO v_document_id FROM t_barcode WHERE bso_id = v_bso_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_document_id := NULL;
        END;

      END IF;
    END IF;

    par_status_out      := v_status;
    par_document_id_out := v_document_id;
  END recognize_barcode;

  /*
    Функция начала сессии сканирования
  */
  FUNCTION scan_session_start RETURN t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE IS
    v_session_id t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE;
  BEGIN
    SELECT sq_t_barcode_scan_sessn.nextval INTO v_session_id FROM dual;

    INSERT INTO t_barcode_scan_sessn
      (t_barcode_scan_sessn_id, sys_user_id)
    VALUES
      (v_session_id, (SELECT sys_user_id FROM sys_user WHERE sys_user_name = USER));
    COMMIT;

    RETURN v_session_id;
  END scan_session_start;

  /*
    Процедура окончания сессии сканирования
  */
  PROCEDURE scan_session_end(par_session_id t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE) IS
  BEGIN
    UPDATE t_barcode_scan_sessn SET end_date = SYSDATE WHERE t_barcode_scan_sessn_id = par_session_id;
    COMMIT;
  END scan_session_end;

  /*
    Процедура сохранения результата перевода статуса по ДС
  */
  PROCEDURE set_change_status_msg
  (
    par_session_id        t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
   ,par_change_status_msg t_barcode_scan_hist.change_status_msg%TYPE
  ) IS
    v_max_hist_id t_barcode_scan_hist.t_barcode_scan_hist_id%TYPE;
  BEGIN
    SELECT MAX(t_barcode_scan_hist_id)
      INTO v_max_hist_id
      FROM t_barcode_scan_hist
     WHERE t_barcode_scan_sessn_id = par_session_id;

    UPDATE t_barcode_scan_hist
       SET change_status_msg = par_change_status_msg
     WHERE t_barcode_scan_hist_id = v_max_hist_id;
  END;

  /*
    Процедура перевода статуса договора страхования
  */
  PROCEDURE change_policy_status
  (
    par_session_id             IN t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
   ,par_policy_id              IN p_policy.policy_id%TYPE
   ,par_src_doc_status_ref_id  IN doc_status_ref.doc_status_ref_id%TYPE
   ,par_dest_doc_status_ref_id IN doc_status_ref.doc_status_ref_id%TYPE
   ,par_change_status_msg      OUT t_barcode_scan_hist.change_status_msg%TYPE
  ) IS
    v_current_status_id doc_status_ref.doc_status_ref_id%TYPE;

    /*
      Процедура записи исходного и конечного статуса ДС в сессию сканирования
    */
    PROCEDURE set_session_pol_status
    (
      par_session_id             t_barcode_scan_sessn.t_barcode_scan_sessn_id%TYPE
     ,par_src_doc_status_ref_id  IN doc_status_ref.doc_status_ref_id%TYPE
     ,par_dest_doc_status_ref_id IN doc_status_ref.doc_status_ref_id%TYPE
    ) IS
    BEGIN
      UPDATE t_barcode_scan_sessn bss
         SET src_doc_status_ref_id  = par_src_doc_status_ref_id
            ,dest_doc_status_ref_id = par_dest_doc_status_ref_id
       WHERE t_barcode_scan_sessn_id = par_session_id;

      COMMIT;
    END set_session_pol_status;

  BEGIN
    v_current_status_id := doc.get_doc_status_id(par_policy_id);
    IF v_current_status_id IS NULL
    THEN
      par_change_status_msg := 'Не удалось определить статус активной версии ДС';
    ELSE
      IF v_current_status_id <> par_src_doc_status_ref_id
      THEN
        par_change_status_msg := 'Статус найденного договора "' ||
                                 doc.get_doc_status_name(par_policy_id) ||
                                 '" не совпадает с заданным начальным статусом';
      ELSE
        set_session_pol_status(par_session_id, par_src_doc_status_ref_id, par_dest_doc_status_ref_id);
        doc.set_doc_status(par_policy_id, par_dest_doc_status_ref_id);
        par_change_status_msg := 'Успешно';
      END IF;
    END IF;

    set_change_status_msg(par_session_id, par_change_status_msg);
  EXCEPTION
    WHEN OTHERS THEN
      par_change_status_msg := SQLERRM;
      set_change_status_msg(par_session_id, par_change_status_msg);
  END change_policy_status;

END pkg_barcode;
/