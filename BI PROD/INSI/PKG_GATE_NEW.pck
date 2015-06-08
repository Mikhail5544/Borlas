CREATE OR REPLACE PACKAGE insi.PKG_GATE_NEW IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 21.07.2011 9:21:30
  -- Purpose : Работа с шлюзовыми таблицами используя настроечные справочники
  TYPE tt_numbers IS TABLE OF NUMBER;

  /*
    Байтин А.
    Получение следующего ID из последовательности
  */
  FUNCTION get_line_id RETURN NUMBER;

  /*
    Байтин А.
    Добавление внешней БД в справочник баз данных
  */
  PROCEDURE add_remote_db
  (
    par_db_brief       VARCHAR2
   ,par_db_description VARCHAR2
  );
  /*
    Байтин А.
    Удаление внешней БД из справочника баз данных
  */
  PROCEDURE remove_remote_db(par_db_brief VARCHAR2);
  /*
    Байтин А.
    Добавление таблицы в справочник шлюзовых таблиц и создание связи с внешней БД
  */
  PROCEDURE add_table
  (
    par_db_brief        VARCHAR2
   ,par_obj_name        VARCHAR2
   ,par_tbl_description VARCHAR2
  );
  /*
    Байтин А.
    Исправление названия таблицы, как объекта БД, в справочнике шлюзовых таблиц
  */
  PROCEDURE change_table_name
  (
    par_old_obj_name VARCHAR2
   ,par_new_obj_name VARCHAR2
  );
  /*
    Байтин А.
    Исправление описания таблицы в справочнике шлюзовых таблиц
  */
  PROCEDURE change_table_desc
  (
    par_obj_name            VARCHAR2
   ,par_new_tbl_description VARCHAR2
  );
  /*
    Байтин А.
    Удаление таблицы из справочника шлюзовых таблиц
  */
  PROCEDURE remove_table(par_obj_name VARCHAR2);
  /*
    Байтин А.
    Удаление связи шлюзовой таблицы с внешней БД
  */
  PROCEDURE remove_table_from_db
  (
    par_db_brief VARCHAR2
   ,par_obj_name VARCHAR2
  );

  /*
    Байтин А.
    Получение списка ID БД для таблицы
  */
  FUNCTION get_db_for_table(par_tbl_obj_name VARCHAR2) RETURN tt_numbers
    PIPELINED;
  /*
    Веселуха Е.
    Обновление БИК Банков
  */
  PROCEDURE INSERT_UPDATE_BIK(par_import_date DATE DEFAULT TRUNC(SYSDATE));
  /*  Экспорт выплатной ведомости в 1С
      Веселуха Е.
      19.04.2013
      Параметр - ИД выплатной ведомости
  */
  PROCEDURE EXPORT_ROLL_PAY(par_roll_pay_header_id NUMBER);
  /*  Импорт данных по выплатам агентам из 1С
      Веселуха Е.
      24.04.2013
  */
  PROCEDURE IMPORT_ROLL_PAY;
END PKG_GATE_NEW;
/
CREATE OR REPLACE PACKAGE BODY insi.PKG_GATE_NEW IS

  /*
    Байтин А.
    Получение следующего ID из последовательности
  */
  FUNCTION get_line_id RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT sq_line_id.nextval INTO v_id FROM dual;
    RETURN v_id;
  END get_line_id;
  /*
    Байтин А.
    Добавление внешней БД в справочник баз данных
  */
  PROCEDURE add_remote_db
  (
    par_db_brief       VARCHAR2
   ,par_db_description VARCHAR2
  ) IS
    v_cnt         NUMBER;
    v_gate_dbs_id NUMBER;
  BEGIN
    IF par_db_brief IS NULL
    THEN
      raise_application_error(-20001
                             ,'Должно быть указано сокращенное наименование БД');
    END IF;
    IF par_db_description IS NULL
    THEN
      raise_application_error(-20001, 'Должно быть указано описание БД');
    END IF;
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM gate_dbs gd WHERE gd.brief = par_db_brief);
    IF v_cnt = 0
    THEN
      SELECT sq_gate_dbs.nextval INTO v_gate_dbs_id FROM dual;
      INSERT INTO gate_dbs
        (gate_dbs_id, brief, description)
      VALUES
        (v_gate_dbs_id, par_db_brief, par_db_description);
    ELSE
      raise_application_error(-20001
                             ,'Таблица с таким сокращенным наименованием существует');
    END IF;
  
  END add_remote_db;
  /*
    Байтин А.
    Удаление внешней БД из справочника баз данных
  */
  PROCEDURE remove_remote_db(par_db_brief VARCHAR2) IS
    v_cnt NUMBER;
  BEGIN
    IF par_db_brief IS NULL
    THEN
      raise_application_error(-20001
                             ,'Должно быть указано сокращенное наименование БД');
    END IF;
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM gate_dbs              gd
                  ,gate_dbs_tables_links tl
             WHERE gd.brief = par_db_brief
               AND gd.gate_dbs_id = tl.gate_dbs_id);
    IF v_cnt = 0
    THEN
      DELETE FROM gate_dbs gd WHERE gd.brief = par_db_brief;
      IF SQL%ROWCOUNT = 0
      THEN
        raise_application_error(-20001
                               ,'Не существует БД с таким сокращенным наименованием');
      END IF;
    ELSE
      raise_application_error(-20001
                             ,'Существует связь с таблицами, сначала удалите таблицу');
    END IF;
  END remove_remote_db;
  /*
    Байтин А.
    Добавление таблицы в справочник шлюзовых таблиц и создание связи с внешней БД
  */
  PROCEDURE add_table
  (
    par_db_brief        VARCHAR2
   ,par_obj_name        VARCHAR2
   ,par_tbl_description VARCHAR2
  ) IS
    v_cnt      NUMBER;
    v_table_id NUMBER;
    v_links_id NUMBER;
  BEGIN
    IF par_db_brief IS NULL
    THEN
      raise_application_error(-20001
                             ,'Должно быть указано сокращенное наименование БД');
    END IF;
    IF par_obj_name IS NULL
    THEN
      raise_application_error(-20001
                             ,'Должно быть указано оъектное наименование таблицы');
    END IF;
    IF par_tbl_description IS NULL
    THEN
      raise_application_error(-20001
                             ,'Должно быть указано описание таблицы');
    END IF;
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM gate_dbs gd WHERE gd.brief = par_db_brief);
    IF v_cnt = 0
    THEN
      raise_application_error(-20001
                             ,'Не существует БД с таким сокращенным наименованием');
    END IF;
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM user_tables ut WHERE ut.table_name = par_obj_name);
    IF v_cnt = 0
    THEN
      raise_application_error(-20001
                             ,'Таблицы БД с таким названием не существует, сначала создайте таблицу в схеме INSI');
    END IF;
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL FROM gate_tables gt WHERE gt.obj_name = par_obj_name);
    IF v_cnt = 0
    THEN
      SELECT sq_gate_tables.nextval INTO v_table_id FROM dual;
      INSERT INTO gate_tables gt
        (gate_tables_id, obj_name, description)
      VALUES
        (v_table_id, par_obj_name, par_tbl_description);
    ELSE
      SELECT gt.gate_tables_id INTO v_table_id FROM gate_tables gt WHERE gt.obj_name = par_obj_name;
    END IF;
    SELECT sq_gate_dbs_tables_links.nextval INTO v_links_id FROM dual;
    INSERT INTO gate_dbs_tables_links
      (gate_dbs_tables_link_id, gate_dbs_id, gate_tables_id)
    VALUES
      (v_links_id, (SELECT gd.gate_dbs_id FROM gate_dbs gd WHERE gd.brief = par_db_brief), v_table_id);
  END add_table;
  /*
    Байтин А.
    Исправление названия таблицы, как объекта БД, в справочнике шлюзовых таблиц
  */
  PROCEDURE change_table_name
  (
    par_old_obj_name VARCHAR2
   ,par_new_obj_name VARCHAR2
  ) IS
  BEGIN
    NULL;
  END change_table_name;
  /*
    Байтин А.
    Исправление описания таблицы в справочнике шлюзовых таблиц
  */
  PROCEDURE change_table_desc
  (
    par_obj_name            VARCHAR2
   ,par_new_tbl_description VARCHAR2
  ) IS
  BEGIN
    NULL;
  END change_table_desc;
  /*
    Байтин А.
    Удаление таблицы из справочника шлюзовых таблиц
  */
  PROCEDURE remove_table(par_obj_name VARCHAR2) IS
  BEGIN
    NULL;
  END remove_table;
  /*
    Байтин А.
    Удаление связи шлюзовой таблицы с внешней БД
  */
  PROCEDURE remove_table_from_db
  (
    par_db_brief VARCHAR2
   ,par_obj_name VARCHAR2
  ) IS
    v_gate_dbs_id NUMBER;
  BEGIN
    SELECT gd.gate_dbs_id INTO v_gate_dbs_id FROM insi.gate_dbs gd WHERE gd.brief = par_db_brief;
  
    DELETE FROM insi.gate_dbs_tables_links tl
     WHERE (tl.gate_dbs_id, tl.gate_tables_id) IN
           (SELECT v_gate_dbs_id
                  ,gt.gate_tables_id
              FROM insi.gate_tables gt
             WHERE gt.obj_name = par_obj_name);
    -- Удаление записей из шлюзовой таблицы (обязательно должно быть поле gate_dbs_id)
    EXECUTE IMMEDIATE 'delete from insi.' || par_obj_name || ' sd where sd.gate_dbs_id = :gate_dbs_id'
      USING IN v_gate_dbs_id;
  END remove_table_from_db;

  /*
    Байтин А.
    Получение списка ID БД для таблицы
  */
  FUNCTION get_db_for_table(par_tbl_obj_name VARCHAR2) RETURN tt_numbers
    PIPELINED IS
  BEGIN
    FOR vr_dbs IN (SELECT tl.gate_dbs_id
                     FROM gate_tables           gt
                         ,gate_dbs_tables_links tl
                    WHERE gt.obj_name = par_tbl_obj_name
                      AND gt.gate_tables_id = tl.gate_tables_id)
    LOOP
      PIPE ROW(vr_dbs.gate_dbs_id);
    END LOOP;
    RETURN;
  END get_db_for_table;
  /*
    Веселуха Е.
    Обновление БИК Банков
  */
  PROCEDURE INSERT_UPDATE_BIK(par_import_date DATE DEFAULT TRUNC(SYSDATE)) IS
    v_ct_id        NUMBER;
    v_contact_id   NUMBER;
    v_ident_id     NUMBER;
    v_type_bik_id  NUMBER;
    v_type_korr_id NUMBER;
    v_current_corr VARCHAR2(20);
    v_role_id      NUMBER;
    is_role        NUMBER;
    v_err_mes      VARCHAR2(2000) := '';
  BEGIN
  
    SELECT t.id INTO v_type_bik_id FROM ins.t_id_type t WHERE t.brief = 'BIK';
  
    SELECT t.id INTO v_type_korr_id FROM ins.t_id_type t WHERE t.brief = 'KORR';
  
    SELECT ct.id INTO v_ct_id FROM ins.t_contact_type ct WHERE ct.brief = 'КБ';
  
    SELECT cr.id INTO v_role_id FROM ins.t_contact_role cr WHERE cr.brief = 'BANK';
  
    /*Находим записи, которые не совпадают по БИК - добавляем*/
    FOR CUR_INS IN (SELECT ib.t_bik          v_bik
                          ,ib.t_name_bank    v_bank_name
                          ,ib.t_korr_account v_korr
                      FROM insi.t_import_bik ib
                     WHERE ib.t_state_date = par_import_date
                       AND NOT EXISTS (SELECT NULL
                              FROM ins.cn_contact_ident ci
                                  ,ins.contact          c
                                  ,ins.cn_contact_role  cnr
                             WHERE ci.id_type = v_type_bik_id
                               AND ci.id_value = ib.t_bik
                               AND ci.contact_id = c.contact_id
                               AND c.contact_id = cnr.contact_id
                               AND cnr.role_id = v_role_id))
    LOOP
      SAVEPOINT NO_CREATE_BANK;
      BEGIN
        v_contact_id := ins.pkg_contact.create_company(par_name            => cur_ins.v_bank_name
                                                      ,par_contact_type_id => v_ct_id);
        /*Добавим роль Банк*/
        SELECT COUNT(*)
          INTO is_role
          FROM ins.ven_cn_contact_role cc
         WHERE cc.contact_id = v_contact_id
           AND cc.role_id = v_role_id;
        IF is_role = 0
        THEN
          INSERT INTO ins.ven_cn_contact_role (contact_id, role_id) VALUES (v_contact_id, v_role_id);
        END IF;
        /*документ БИК*/
        v_ident_id := ins.pkg_contact.create_ident_document(par_contact_id    => v_contact_id
                                                           ,par_ident_type_id => v_type_bik_id
                                                           ,par_value         => cur_ins.v_bik
                                                           ,par_is_default    => 1
                                                           ,par_is_used       => 1);
        /*Документ Корр счет*/
        IF cur_ins.v_korr IS NOT NULL
        THEN
          v_ident_id := ins.pkg_contact.create_ident_document(par_contact_id    => v_contact_id
                                                             ,par_ident_type_id => v_type_korr_id
                                                             ,par_value         => cur_ins.v_korr
                                                             ,par_is_used       => 1);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO NO_CREATE_BANK;
          v_err_mes := 'Ошибка создания Банка и документов';
          INSERT INTO ins.ven_t_import_bik_history
            (t_bik, t_error_mess, t_korr_account, t_name_bank, t_state_date, t_state, t_contact_id)
          VALUES
            (cur_ins.v_bik, v_err_mes, cur_ins.v_korr, cur_ins.v_bank_name, par_import_date, 3, -1);
      END;
      INSERT INTO ins.ven_t_import_bik_history
        (t_bik, t_korr_account, t_name_bank, t_state_date, t_state, t_contact_id)
      VALUES
        (cur_ins.v_bik, cur_ins.v_korr, cur_ins.v_bank_name, par_import_date, 1, v_contact_id);
    END LOOP;
    /*Находим записи, которые совпадают по БИК - обновляем*/
    FOR CUR_UPD IN (SELECT ib.t_bik          v_bik
                          ,ib.t_name_bank    v_bank_name
                          ,ib.t_korr_account v_korr
                          ,c.contact_id
                      FROM insi.t_import_bik    ib
                          ,ins.cn_contact_ident cib
                          ,ins.contact          c
                          ,ins.cn_contact_role  cnr
                     WHERE ib.t_state_date = par_import_date
                       AND cib.id_value = ib.t_bik
                       AND cib.id_type = v_type_bik_id
                       AND cib.contact_id = c.contact_id
                       AND c.obj_name != UPPER(ib.t_name_bank)
                       AND c.contact_id = cnr.contact_id
                       AND cnr.role_id = v_role_id)
    LOOP
      SAVEPOINT NO_UPDATE_BANK;
      BEGIN
        UPDATE ins.contact c
           SET c.name          = UPPER(cur_upd.v_bank_name)
              ,c.obj_name      = UPPER(cur_upd.v_bank_name)
              ,c.obj_name_orig = cur_upd.v_bank_name
         WHERE c.contact_id = cur_upd.contact_id;
      
        BEGIN
          SELECT cic.id_value
            INTO v_current_corr
            FROM ins.cn_contact_ident cic
           WHERE cic.id_type = v_type_korr_id
             AND cic.contact_id = cur_upd.contact_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF cur_upd.v_korr IS NOT NULL
            THEN
              v_ident_id := ins.pkg_contact.create_ident_document(par_contact_id    => cur_upd.contact_id
                                                                 ,par_ident_type_id => v_type_korr_id
                                                                 ,par_value         => cur_upd.v_korr
                                                                 ,par_is_used       => 1);
            END IF;
          WHEN TOO_MANY_ROWS THEN
            IF cur_upd.v_korr IS NULL
            THEN
              DELETE FROM ins.cn_contact_ident ci
               WHERE ci.contact_id = cur_upd.contact_id
                 AND ci.id_type = v_type_korr_id;
            ELSE
              UPDATE ins.cn_contact_ident ci
                 SET ci.id_value = cur_upd.v_korr
               WHERE ci.contact_id = cur_upd.contact_id;
            END IF;
        END;
        IF v_current_corr != cur_upd.v_korr
           AND cur_upd.v_korr IS NOT NULL
        THEN
          UPDATE ins.cn_contact_ident ci
             SET ci.id_value = cur_upd.v_korr
           WHERE ci.contact_id = cur_upd.contact_id;
        ELSIF cur_upd.v_korr IS NULL
              AND v_current_corr IS NOT NULL
        THEN
          DELETE FROM ins.cn_contact_ident ci
           WHERE ci.contact_id = cur_upd.contact_id
             AND ci.id_type = v_type_korr_id;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO NO_UPDATE_BANK;
          v_err_mes := 'Ошибка обновления Банка и создания документов';
          INSERT INTO ins.ven_t_import_bik_history
            (t_bik, t_error_mess, t_korr_account, t_name_bank, t_state_date, t_state, t_contact_id)
          VALUES
            (cur_upd.v_bik, v_err_mes, cur_upd.v_korr, cur_upd.v_bank_name, par_import_date, 3, -1);
      END;
      INSERT INTO ins.ven_t_import_bik_history
        (t_bik, t_korr_account, t_name_bank, t_state_date, t_state, t_contact_id)
      VALUES
        (cur_upd.v_bik, cur_upd.v_korr, cur_upd.v_bank_name, par_import_date, 2, cur_upd.contact_id);
    END LOOP;
  
    /*Удаляем все записи из шлюза, которые Обработаны*/
    INSERT INTO ins.ven_t_import_bik_history
      (t_bik, t_korr_account, t_name_bank, t_state_date, t_state, t_contact_id)
      SELECT ib.t_bik
            ,ib.t_korr_account
            ,ib.t_name_bank
            ,ib.t_state_date
            ,0
            ,ide.contact_id
        FROM insi.t_import_bik    ib
            ,ins.cn_contact_ident ide
       WHERE ib.t_state_date = par_import_date
         AND ib.t_bik = ide.id_value
         AND ide.id_type = v_type_bik_id
         AND EXISTS (SELECT NULL
                FROM ins.cn_contact_role cnr
               WHERE cnr.contact_id = ide.contact_id
                 AND cnr.role_id = v_role_id)
         AND NOT EXISTS (SELECT NULL
                FROM ins.t_import_bik_history h
               WHERE h.t_state_date = ib.t_state_date
                 AND h.t_bik = ib.t_bik);
    DELETE FROM insi.t_import_bik ib WHERE ib.t_state_date = par_import_date;
  
    /**/
  
  END INSERT_UPDATE_BIK;
  /*  Экспорт выплатной ведомости в 1С
      Веселуха Е.
      19.04.2013
      Параметр - ИД выплатной ведомости
  */
  PROCEDURE EXPORT_ROLL_PAY(par_roll_pay_header_id NUMBER) IS
    v_type_prem   VARCHAR2(10);
    v_pay_company VARCHAR2(10);
    insert_rl     NUMBER;
    insert_npf    NUMBER;
  BEGIN
  
    INSERT INTO insi.t_export_pay_roll_detail
      (name_recipient
      ,num_ad
      ,contact_id
      ,pay_roll_act_id
      ,leg_pos
      ,rl_sum
      ,npf_sum
      ,sum_pay_life
      ,sum_pay_acc
      ,sum_pay_npf
      ,bik_bank
      ,rs_account
      ,lic_account
      ,bank_card
      ,pay_roll_header_id
      ,category_agent
      ,sales_channel_brief)
      SELECT DISTINCT c.obj_name_orig
                     ,agh.num
                     ,arpd.contact_id
                     ,agh.ag_contract_header_id || arpd.ag_roll_pay_header_id
                     , --ИД акта
                      tct.description
                     ,(SELECT NVL(SUM(ad.prem_sum), 0)
                         FROM ins.ag_roll_pay_detail ad
                        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
                          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
                          AND ad.vol_type_brief IN ('RL', 'FDep', 'INV')
                          AND ad.state_detail = 1) + arpd.other_prem_sum amount_rl
                     ,(SELECT NVL(SUM(ad.prem_sum), 0)
                         FROM ins.ag_roll_pay_detail ad
                        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
                          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
                          AND ad.vol_type_brief IN ('NPF', 'NPF02', 'NPF(MARK9)')
                          AND ad.state_detail = 1) amount_npf
                     ,(SELECT NVL(SUM(ad.prem_sum), 0)
                         FROM ins.ag_roll_pay_detail ad
                        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
                          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
                          AND ad.vol_type_brief IN ('RL', 'FDep', 'INV')
                          AND ad.ig_property = 1
                          AND ad.state_detail = 1) + arpd.other_prem_sum sum_pay_life
                     ,(SELECT NVL(SUM(ad.prem_sum), 0)
                         FROM ins.ag_roll_pay_detail ad
                        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
                          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
                          AND ad.vol_type_brief IN ('RL', 'FDep', 'INV')
                          AND ad.ig_property = 0
                          AND ad.state_detail = 1) sum_pay_acc
                     ,(SELECT NVL(SUM(ad.prem_sum), 0)
                         FROM ins.ag_roll_pay_detail ad
                        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
                          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
                          AND ad.vol_type_brief IN ('NPF', 'NPF02', 'NPF(MARK9)')
                          AND ad.state_detail = 1) sum_pay_npf
                     ,bp.bik_number
                     ,bp.account
                     ,DECODE(TRIM(bp.note), 'БК', '', bp.payment_props) lic_account
                     ,DECODE(TRIM(bp.note), 'БК', bp.payment_props, '') bk_account
                     ,arpd.ag_roll_pay_header_id
                     ,cat.category_name
                     ,ch.description sales_chnl
        FROM ins.ag_roll_pay_detail arpd
            ,ins.contact c
            ,ins.ven_ag_contract_header agh
            ,ins.t_contact_type tct
            ,(SELECT abp.*
                    ,ins.pkg_contact.get_ident_number(abp.bank_id, 'BIK') bik_number
                FROM ins.ag_bank_props abp
               WHERE abp.enable = 1) bp
            ,ins.ag_category_agent cat
            ,ins.t_sales_channel ch
       WHERE arpd.ag_roll_pay_header_id = par_roll_pay_header_id
         AND arpd.state_detail = 1
         AND arpd.contact_id = c.contact_id
         AND arpd.ag_contract_header_id = agh.ag_contract_header_id
         AND arpd.contact_type_id = tct.id
         AND agh.ag_contract_header_id = bp.ag_contract_header_id(+)
         AND arpd.ag_category_agent_id = cat.ag_category_agent_id
         AND arpd.ag_sales_channel_id = ch.id;
  
    INSERT INTO insi.t_export_pay_roll_header
      (pay_roll_header_id, export_date, pay_company)
      SELECT arph.ag_roll_pay_header_id
            ,TRUNC(SYSDATE)
            ,arph.company
        FROM ins.ag_roll_pay_header arph
       WHERE arph.ag_roll_pay_header_id = par_roll_pay_header_id;
  
  END EXPORT_ROLL_PAY;
  /*  Импорт данных по выплатам агентам из 1С
      Веселуха Е.
      24.04.2013
  */
  PROCEDURE IMPORT_ROLL_PAY IS
    v_status_brief        VARCHAR2(8) := 'PAYED_AG';
    v_status_date         DATE := SYSDATE;
    v_status_change_brief VARCHAR2(4) := 'AUTO';
    v_note                VARCHAR2(2000) := '';
    proc_name             VARCHAR2(15) := 'IMPORT_ROLL_PAY';
    pv_id                 NUMBER;
  BEGIN
    /*NULL;*/
    /*Получение номера реквеста для Выплатной*/
    UPDATE ins.ag_roll_pay_header arph
       SET arph.request_num =
           (SELECT TRIM(ap.request_number)
              FROM insi.t_export_pay_roll_header ap
             WHERE ap.pay_roll_header_id = arph.ag_roll_pay_header_id
               AND ap.is_processed = 1)
     WHERE EXISTS (SELECT NULL
              FROM insi.t_export_pay_roll_header iap
             WHERE iap.pay_roll_header_id = arph.ag_roll_pay_header_id
               AND iap.is_processed = 1);
    FOR cur_paid IN (SELECT arph.ag_roll_pay_header_id
                           ,d.num roll_pay_num
                       FROM ins.ag_roll_pay_header arph
                           ,ins.document           d
                           ,ins.doc_status_ref     rf
                      WHERE arph.request_num IS NOT NULL
                        AND arph.ag_roll_pay_header_id = d.document_id
                        AND d.doc_status_ref_id = rf.doc_status_ref_id
                        AND rf.brief = 'TO_PAY_AG'
                        AND EXISTS (SELECT NULL
                               FROM insi.t_export_pay_roll_header iap
                              WHERE iap.pay_roll_header_id = arph.ag_roll_pay_header_id
                                AND iap.is_processed = 1))
    LOOP
      v_note := 'Перевод выплатной ведомости ' || cur_paid.roll_pay_num ||
                ' на основании передачи данных из 1С';
      ins.doc.set_doc_status(p_doc_id                   => cur_paid.ag_roll_pay_header_id
                            ,p_status_brief             => v_status_brief
                            ,p_status_date              => v_status_date
                            ,p_status_change_type_brief => v_status_change_brief
                            ,p_note                     => v_note);
    END LOOP;
    /*Обновление сумм выплат, полученных из 1С*/
    FOR CUR IN (SELECT rp.pay_roll_act_id
                      ,rp.sum_payed
                      ,rp.date_payed
                      ,rp.sum_ndfl
                      ,NVL(rp.is_wrong_props, 0) is_wrong_props
                      ,rp.sum_esn
                  FROM insi.t_import_roll_pay rp)
    LOOP
      pv_id := cur.pay_roll_act_id;
      UPDATE ins.ag_roll_pay_detail dt
         SET (dt.amount_payed
            ,dt.date_payed
            ,dt.amount_ndfl
            ,dt.amount_esn
            ,dt.state_detail
            ,dt.date_processing) =
             (SELECT (dt.prem_sum / SUM(dt_.prem_sum)) * NVL(cur.sum_payed, 0)
                    ,cur.date_payed
                    ,(dt.prem_sum / SUM(dt_.prem_sum)) * NVL(cur.sum_ndfl, 0)
                    ,(dt.prem_sum / SUM(dt_.prem_sum)) * NVL(cur.sum_esn, 0)
                    ,2
                    ,SYSDATE
                FROM ins.ag_roll_pay_detail dt_
               WHERE dt_.ag_contract_header_id || dt_.ag_roll_pay_header_id =
                     dt.ag_contract_header_id || dt.ag_roll_pay_header_id)
       WHERE dt.ag_contract_header_id || dt.ag_roll_pay_header_id = cur.pay_roll_act_id
         AND NVL(dt.prem_sum, 0) != 0;
      /**/
      UPDATE ins.ag_roll_pay_detail dt
         SET (dt.amount_payed
            ,dt.date_payed
            ,dt.amount_ndfl
            ,dt.state_detail
            ,dt.date_processing
            ,dt.amount_esn) =
             (SELECT 0
                    ,cur.date_payed
                    ,0
                    ,3
                    ,SYSDATE
                    ,0
                FROM DUAL)
       WHERE dt.ag_contract_header_id || dt.ag_roll_pay_header_id = cur.pay_roll_act_id
         AND NVL(dt.prem_sum, 0) = 0;
    END LOOP;
    /**/
    DELETE FROM insi.t_export_pay_roll_detail de
     WHERE EXISTS (SELECT NULL
              FROM insi.t_export_pay_roll_header iap
             WHERE iap.pay_roll_header_id = de.pay_roll_header_id
               AND iap.is_processed = 1);
    DELETE FROM insi.t_export_pay_roll_header ap;
    DELETE FROM insi.t_import_roll_pay rp;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Ошибка при обновлении выплат в Борлас act_id = ' || pv_id);
  END;
END PKG_GATE_NEW;
/
