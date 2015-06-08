CREATE OR REPLACE PACKAGE pkg_borlas_b2b IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 29.06.2011 13:56:53
  -- Purpose : Предназначен для обмена данными между системами Borlas и B2B
  --           Использует для передачи в B2B JSON следующего формата:
  --           {"key": "<строка>",
  --            "mode": "<строка>",
  --            "data": [{},{}]
  --           }
  --          , где key - ключ для корректной авторизации,
  --                mode - название процесса,
  --                data - массив данных.
  --
  --           Использует в качестве ответа от B2B строку JSON следующего формата:
  --           {"code": <число>,
  --            "operation": "<строка>",
  --            "error_text": "<строка>",
  --            "data": [{"code":<число>,"error_text":"<строка>","ключ":<значение>}]
  --           }
  --          , где cod - количество ошибок,
  --                operation - название процесса,
  --                error_text - текст ошибки
  --                data - сообщения об ошибке в разрезе переданных данных

  TYPE t_policy_values IS RECORD(
     product_id           p_pol_header.product_id%TYPE
    ,product_brief        t_product.brief%TYPE
    ,fund_id              p_pol_header.fund_id%TYPE
    ,fund_pay_id          p_pol_header.fund_pay_id%TYPE
    ,fund_brief           fund.brief%TYPE
    ,confirm_condition_id p_pol_header.confirm_condition_id%TYPE
    ,payment_term_id      p_policy.payment_term_id%TYPE
    ,is_periodical        t_payment_terms.is_periodical%TYPE
    ,period_id            p_policy.period_id%TYPE
    ,waiting_period_id    p_policy.waiting_period_id%TYPE
    ,discount_f_id        p_policy.discount_f_id%TYPE
    ,paymentoff_term_id   p_policy.paymentoff_term_id%TYPE
    ,privilege_period_id  p_policy.pol_privilege_period_id%TYPE
    ,work_group_id        as_assured.work_group_id%TYPE);

  TYPE t_prog_sums IS TABLE OF NUMBER INDEX BY t_prod_line_option.brief%TYPE;

  /*
    Байтин А.
    Осуществляет экспорт строки ТАП, результат передачи записывает в строку.

    par_tap_id - ИД записи справочника ТАП
  */
  PROCEDURE send_tap_row(par_tap_id NUMBER);
  /*
    Байтин А.
    Осуществляет экспорт строки ТАЦ, результат передачи записывает в строку.

    par_tac_id - ИД записи справочника ТАП
  */
  PROCEDURE send_tac_row(par_tac_id NUMBER);
  /*
    Байтин А.
    Передача продающего подразделения

    par_sales_dept_id - ИД записи версии продающего подразделения
  */

  PROCEDURE send_sales_dept_row(par_sales_dept_id NUMBER);

  /*
    Байтин А.
    Импорт дат продаж агентов
  */
  PROCEDURE import_agent_sales_dates;
  /*
    Байтин А. + Чирков В.
    Получение курса валют

    par_date - Дата курса
  */
  PROCEDURE get_rate
  (
    par_date DATE
   ,par_eur  OUT NUMBER
   ,par_usd  OUT NUMBER
  );

  /*
    Байтин А.
    Отправка данных по агенту
  */
  PROCEDURE import_agent_contract
  (
    par_ag_contract_header_id PLS_INTEGER
   ,v_oper                    PLS_INTEGER
   ,par_error                 OUT VARCHAR2
  );

  /*
     Байтин А.
     Получение ОПС и СОФИ
  */
  PROCEDURE get_ops_sofi_policy(par_operation_name VARCHAR2 -- Поддерживаемые значения: get_orders_ops, get_orders_sofi,
                                -- get_payments_sofi, get_payments_pfr
                               ,par_date DATE DEFAULT SYSDATE -- Дата, на которую получаются платежи ПФР
                                );

  /*
    Байтин А.
    Инициализация значений по умолчанию для договора

    Вынесена сюда для облегчения тестирования
  */
  FUNCTION init_policy_values(par_product_brief VARCHAR2) RETURN t_policy_values;
  /*
     Байтин А.
     Создание договоров Инвестор
     Возвращает true - были ошибки, false - не было

    Вынесена сюда для облегчения тестирования
  */
  PROCEDURE create_investor_policy
  (
    par_policy_values pkg_products.t_product_defaults
   ,par_response      IN OUT JSON_LIST
   ,par_was_errors    IN OUT BOOLEAN
  );

  /*
     Байтин А.
     Получение ДС
  */
  PROCEDURE get_policy;

  /*
    Байтин А.

    Расчет выкупных сумм и передача их в B2B для Альфабанка
    par_answer  - ответ в B2B
  */

  PROCEDURE get_cash_surrender
  (
    par_birth_date      DATE
   ,par_gender          VARCHAR2
   ,par_product         VARCHAR2
   ,par_fund            VARCHAR2
   ,par_period          NUMBER
   ,par_prog_sums       t_prog_sums
   ,par_base_sum        NUMBER
   ,par_is_credit       BOOLEAN
   ,par_ag_contract_num VARCHAR2
  );

  /*
    Байтин А.
    Возврат в B2B структуры агентского дерева на указанную дату
  */
  PROCEDURE get_agent_tree(par_date DATE);

  /*
  Капля П.
  Лог запросов из B2B
  */
  PROCEDURE log_json_call
  (
    p_obj_json      JSON
   ,p_func_name     VARCHAR2 DEFAULT NULL
   ,p_err_backtrace CLOB DEFAULT NULL
  );
  PROCEDURE log_json_call
  (
    p_obj_json_list JSON_LIST
   ,p_func_name     VARCHAR2 DEFAULT NULL
   ,p_err_backtrace CLOB DEFAULT NULL
  );
  PROCEDURE log_json_call
  (
    p_obj           CLOB
   ,p_func_name     VARCHAR2 DEFAULT NULL
   ,p_err_backtrace CLOB DEFAULT NULL
  );

  /** Функция возвращает значения свойств по типу операции и типу свойства
  *   Например вернуть значение URL для загрузки курсов Валют
  *   @autor Чирков В.Ю.
  *   @param par_oper_type_brief - сокр. наим. типа операции (например UPDATE_RATE)
  *   @param par_props_type_brief - сокр. наим. типа свойства (например URL)
  */
  FUNCTION get_b2b_props_val
  (
    par_oper_type_brief  t_b2b_props_oper.oper_brief%TYPE
   ,par_props_type_brief t_b2b_props_type.type_brief%TYPE
   ,par_raise_on_error   BOOLEAN DEFAULT TRUE
   ,par_database_name    VARCHAR DEFAULT sys.database_name
  ) RETURN VARCHAR2;

END pkg_borlas_b2b;
/
CREATE OR REPLACE PACKAGE BODY pkg_borlas_b2b IS

  gc_auth_key CONSTANT VARCHAR2(2000) := '195842589a578853e49d95c1a715df4e';
  --  gc_url           constant varchar2(255) := 'https://npf.renlife.com/gateway/borlas';
  --  gc_test_url      constant varchar2(255) := 'https://npf.pred.renlife.com/gateway/borlas';
  --  gc_open_test_url constant varchar2(255) := 'https://openbank.pred.renlife.com/gateway/borlas';
  --  gc_open_url      constant varchar2(255) := 'https://openbank.renlife.com/gateway/borlas';

  --  gv_url           varchar2(255);
  --  gv_open_url      varchar2(255);
  gv_wallet_path VARCHAR2(2000);

  gc_pkg_name VARCHAR2(255) := 'PKG_BORLAS_B2B';

  gv_debug BOOLEAN;

  /*Капля П.*/
  date_format_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(date_format_error, -1861);
  b2b_borlas_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(b2b_borlas_error, -20001);

  PROCEDURE log_json_call
  (
    p_obj           CLOB
   ,p_func_name     VARCHAR2 DEFAULT NULL
   ,p_err_backtrace CLOB DEFAULT NULL
  ) IS
    v_owner    VARCHAR2(60);
    v_name     VARCHAR2(60);
    v_line     NUMBER;
    v_caller_t VARCHAR2(100);
    v_str      VARCHAR2(220);
    v_old_val  BOOLEAN;
    v_test     NUMBER;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    BEGIN

      IF nvl(gv_debug, FALSE)
      THEN

        IF p_func_name IS NULL
        THEN
          owa_util.who_called_me(v_owner, v_name, v_line, v_caller_t);
          v_str := v_owner || '.' || v_name;
        ELSE
          v_str := p_func_name;
        END IF;

        BEGIN
          INSERT INTO ven_b2b_json_call_log
            (call_function_name, json_clob, reg_date, call_stack)
          VALUES
            (v_str, p_obj, SYSDATE, dbms_utility.format_call_stack);
        EXCEPTION
          WHEN OTHERS THEN
            INSERT INTO ven_b2b_json_call_log
              (call_function_name, reg_date, call_stack, error_backtrace)
            VALUES
              (v_str, SYSDATE, dbms_utility.format_call_stack, p_err_backtrace);
        END;
        COMMIT;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  END;

  PROCEDURE log_json_call
  (
    p_obj_json_list JSON_LIST
   ,p_func_name     VARCHAR2 DEFAULT NULL
   ,p_err_backtrace CLOB DEFAULT NULL
  ) IS
    buf       CLOB;
    v_old_val BOOLEAN;
  BEGIN
    v_old_val                 := json_printer.ascii_output;
    json_printer.ascii_output := FALSE;
    dbms_lob.createtemporary(lob_loc => buf, cache => TRUE);
    p_obj_json_list.to_clob(buf => buf, spaces => FALSE);

    log_json_call(buf, p_func_name, p_err_backtrace);

    dbms_lob.freetemporary(lob_loc => buf);
    json_printer.ascii_output := v_old_val;

  END;

  PROCEDURE log_json_call
  (
    p_obj_json      JSON
   ,p_func_name     VARCHAR2 DEFAULT NULL
   ,p_err_backtrace CLOB DEFAULT NULL
  ) IS
    buf       CLOB;
    v_old_val BOOLEAN;
  BEGIN
    v_old_val                 := json_printer.ascii_output;
    json_printer.ascii_output := FALSE;
    dbms_lob.createtemporary(lob_loc => buf, cache => TRUE);
    p_obj_json.to_clob(buf => buf, spaces => FALSE);

    log_json_call(buf, p_func_name, p_err_backtrace);

    dbms_lob.freetemporary(lob_loc => buf);
    json_printer.ascii_output := v_old_val;

  END;
  /*
    Байтин А.
    Добавляет массив данных в посылку, отправляет ее в B2B, получает ответ от B2B, преобразует ответ в объект JSON

    par_mode - название процесса
    par_data - массив с данными

    Возвращает ответ от B2B, преобразованный в объект JSON
  */
  FUNCTION json_conversation
  (
    par_mode      VARCHAR2
   ,par_data      JSON_LIST
   ,par_url       VARCHAR2 -- default gv_url
   ,par_proc_name VARCHAR2 DEFAULT NULL
  ) RETURN JSON IS
    v_proc_name VARCHAR2(255) := 'json_conversation';
    v_log_info  pkg_communication.typ_log_info;
    v_obj       JSON := JSON();
    v_answer    VARCHAR2(32767);
    v_log       JSON := JSON();
    v_clob      CLOB;
  BEGIN
    -- Включение UTF-8
    json_printer.ascii_output := TRUE;

    -- Формирование посылки
    v_obj.put('key', gc_auth_key);
    v_obj.put('mode', par_mode);
    v_obj.put('data', par_data);

    dbms_lob.createtemporary(lob_loc => v_clob, cache => TRUE);
    v_obj.to_clob(v_clob);
    v_clob := 'data=' || v_clob;

    IF nvl(gv_debug, FALSE)
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := nvl(par_proc_name, v_proc_name);
      v_log_info.operation_name        := par_mode;
    END IF;

    v_answer := pkg_communication.request(par_url          => par_url
                                         ,par_send         => v_clob
                                         ,par_content_type => 'application/x-www-form-urlencoded'
                                         ,par_log_info     => v_log_info);

    -- Отключение UTF-8
    json_printer.ascii_output := FALSE;
    RETURN JSON(v_answer);
  END json_conversation;

  /*
    Байтин А.
    Работает аналогично json_conversation, только с большим массивом данных, используя CLOB
  */
  FUNCTION json_lob_conversation
  (
    par_mode      VARCHAR2
   ,par_data      JSON_LIST
   ,par_url       VARCHAR2 -- default gv_url
   ,par_proc_name VARCHAR2 DEFAULT NULL
  ) RETURN JSON IS
    v_obj        JSON := JSON();
    v_send       CLOB;
    v_answer     CLOB;
    v_amt        NUMBER := 32767;
    v_offset     NUMBER := 1;
    v_send_str   VARCHAR2(32767);
    v_answer_str VARCHAR2(32767);
    v_req        utl_http.req;
    v_resp       utl_http.resp;
    v_log        JSON := JSON();
    v_proc_name  VARCHAR2(255) := 'json_lob_conversation';
    v_log_info   pkg_communication.typ_log_info;
  BEGIN
    -- Включение UTF-8
    json_printer.ascii_output := TRUE;

    -- Создаем временный CLOB
    dbms_lob.createtemporary(lob_loc => v_send, cache => TRUE);

    -- Формирование посылки
    v_obj.put('key', gc_auth_key);
    v_obj.put('mode', par_mode);
    v_obj.put('data', par_data);

    v_obj.to_clob(v_send);
    v_send := 'data=' || v_send;

    IF nvl(gv_debug, FALSE)
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := nvl(par_proc_name, v_proc_name);
      v_log_info.operation_name        := par_mode;
    END IF;

    v_answer := pkg_communication.request(par_url          => par_url
                                         ,par_send         => v_send
                                         ,par_content_type => 'application/x-www-form-urlencoded'
                                         ,par_log_info     => v_log_info);

    -- Отключение UTF-8
    json_printer.ascii_output := FALSE;
    RETURN JSON(v_answer);
  EXCEPTION
    WHEN OTHERS THEN
      -- Отключение UTF-8
      json_printer.ascii_output := FALSE;
      RAISE;
  END json_lob_conversation;

  /*
    Байтин А.

    Возвращает с помощью mod_plsql ответ в B2B
  */
  PROCEDURE htp_lob_response(par_lob CLOB) IS
    v_amt      NUMBER := 32767;
    v_offset   NUMBER := 1;
    v_send_str VARCHAR2(32767);
  BEGIN
    LOOP
      -- Чтение из CLOB данных и передача их в B2B
      dbms_lob.read(lob_loc => par_lob, amount => v_amt, offset => v_offset, buffer => v_send_str);
      htp.prn(v_send_str);
      v_offset := v_offset + v_amt;
      EXIT WHEN v_amt < 32767;
    END LOOP;
  END htp_lob_response;

  /*
    Байтин А.
    Осуществляет экспорт строки ТАП, результат передачи записывает в строку.

    par_tap_id - ИД записи справочника ТАП
  */
  PROCEDURE send_tap_row(par_tap_id NUMBER) IS
    v_data_element JSON := JSON();
    v_data_array   JSON_LIST := JSON_LIST();
    v_answer       JSON;
    v_error_text   VARCHAR2(250);
    v_status       NUMBER;

    v_tap_number  VARCHAR2(50);
    v_tap_address cn_address.name%TYPE;
    v_region      VARCHAR2(2);
    v_tac_number  VARCHAR2(50);
    v_url         VARCHAR2(255);
  BEGIN
    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'send_tap_row'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден URL для операции "send_tap_row"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько URL для операции "send_tap_row"');
    END;
    -- Получение данных по ТАП
    SELECT to_char(tt.tap_number, 'FM999999999909') AS tap_num
          ,nvl(ad.name, pkg_entity_address.get_address_name(ad.id)) AS address
          ,substr(ad.code, 1, 2) AS reg_code
          ,(SELECT to_char(tc.tac_number, 'FM999999999909')
              FROM ven_t_tac_to_tap ta
                  ,ven_t_tac        tc
             WHERE ta.t_tap_header_id = tt.t_tap_header_id
               AND ta.t_tac_id = tc.t_tac_id
               AND ta.end_date = TO_DATE('31.12.3000', 'dd.mm.yyyy')) AS tac_num
      INTO v_tap_number
          ,v_tap_address
          ,v_region
          ,v_tac_number
      FROM ven_t_tap             tt
          ,ven_sales_dept_header sh
          ,ven_sales_dept        sd
          ,cn_entity_address     ea
          ,cn_address            ad
           /*,t_province            pr*/
           -- Байтин А.
           -- Заявка 172119
           -- Добавлена связь с ПП через РОО
          ,(SELECT ro.organisation_tree_id
                  ,ro.t_tap_header_id
              FROM ven_t_roo_header rh
                  ,ven_t_roo        ro
             WHERE ro.t_roo_id = rh.last_roo_id) ro
     WHERE tt.t_tap_id = par_tap_id
       AND tt.t_tap_header_id = ro.t_tap_header_id
       AND ro.organisation_tree_id = sh.organisation_tree_id
          --and tt.organisation_tree_id = sh.organisation_tree_id
       AND sh.last_sales_dept_id = sd.sales_dept_id
       AND sd.ent_id = ea.ure_id
       AND sd.sales_dept_id = ea.uro_id
       AND ea.address_id = ad.id
    /*and ad.province_id          = pr.province_id (+)*/
    ;

    -- Запись полученных данных в объект JSON
    v_data_element.put('num', v_tap_number);
    v_data_element.put('address', v_tap_address);
    v_data_element.put('region', v_region);
    v_data_element.put('tac', v_tac_number);

    -- Добавление объекта в массив
    v_data_array.append(v_data_element.to_json_value);
    -- Обмен
    v_answer := json_conversation('tap_update', v_data_array, v_url);
    -- Если есть общая ошибка
    IF v_answer.get('cod').get_number > 0
    THEN
      v_error_text := v_answer.get('error_text').get_string;
      v_status     := -1;
    ELSIF v_answer.get('cod').get_number = 0
    THEN
      -- Получаем массив
      v_data_array   := JSON_LIST(v_answer.get('data'));
      v_data_element := JSON(v_data_array.get(1));
      v_status       := CASE v_data_element.get('cod').get_number
                          WHEN 0 THEN
                           1
                          ELSE
                           -1
                        END;
      v_error_text   := v_data_element.get('error_text').get_string;
    ELSE
      v_status     := 1;
      v_error_text := NULL;
    END IF;

    UPDATE ven_t_tap tt
       SET tt.send_status     = v_status
          ,tt.send_error_text = v_error_text
     WHERE tt.t_tap_id = par_tap_id;
    --    v_answer.print;
  EXCEPTION
    WHEN no_data_found THEN
      UPDATE ven_t_tap tt
         SET tt.send_status     = -1
            ,tt.send_error_text = 'Не удалось получить данные по ТАП. Возможно ТАП не связан с продающим подразделением.'
       WHERE tt.t_tap_id = par_tap_id;
  END send_tap_row;
  /*
    Байтин А.
    Осуществляет экспорт строки ТАЦ, результат передачи записывает в строку.

    par_tac_id - ИД записи справочника ТАП
  */
  PROCEDURE send_tac_row(par_tac_id NUMBER) IS
    v_data_element JSON := JSON();
    v_data_array   JSON_LIST := JSON_LIST();
    v_answer       JSON;
    v_error_text   VARCHAR2(250);
    v_status       NUMBER;
    v_tac_number   VARCHAR2(50);
    v_tac_name     ven_t_tac.tac_name%TYPE;
    v_url          VARCHAR2(255);
  BEGIN
    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'send_tac_row'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден URL для операции "send_sales_dept_row"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько URL для операции "send_sales_dept_row"');
    END;

    -- Получение данных по ТАЦ
    SELECT to_char(tt.tac_number, 'FM999999999909')
          ,tt.tac_name
      INTO v_tac_number
          ,v_tac_name
      FROM ven_t_tac tt
     WHERE tt.t_tac_id = par_tac_id;

    -- Запись полученных данных в объект JSON
    v_data_element.put('num', v_tac_number);
    v_data_element.put('name', v_tac_name);
    v_data_array.append(v_data_element.to_json_value);
    -- Обмен
    v_answer := json_conversation('tac_update', v_data_array, v_url);
    -- Если есть общая ошибка
    IF v_answer.get('cod').get_number > 0
    THEN
      v_error_text := v_answer.get('error_text').get_string;
      v_status     := -1;
    ELSIF v_answer.get('cod').get_number = 0
    THEN
      -- Получаем массив
      v_data_array   := JSON_LIST(v_answer.get('data'));
      v_data_element := JSON(v_data_array.get(1));
      v_status       := CASE v_data_element.get('cod').get_number
                          WHEN 0 THEN
                           1
                          ELSE
                           -1
                        END;
      v_error_text   := v_data_element.get('error_text').get_string;
    ELSE
      v_status     := 1;
      v_error_text := NULL;
    END IF;

    UPDATE ven_t_tac tt
       SET tt.send_status     = v_status
          ,tt.send_error_text = v_error_text
     WHERE tt.t_tac_id = par_tac_id;
    --    v_answer.print;
  EXCEPTION
    WHEN no_data_found THEN
      UPDATE ven_t_tac tt
         SET tt.send_status     = -1
            ,tt.send_error_text = 'Не удалось получить данные по ТАП. Возможно ТАП не связан с продающим подразделением'
       WHERE tt.t_tac_id = par_tac_id;
    WHEN too_many_rows THEN
      UPDATE ven_t_tac tt
         SET tt.send_status     = -1
            ,tt.send_error_text = 'Не удалось получить данные по ТАП. Ошибка уникальности связи ТАП с продающим подразделением'
       WHERE tt.t_tac_id = par_tac_id;
  END send_tac_row;

  /*
    Байтин А.
    Передача продающего подразделения

    par_sales_dept_id - ИД записи версии продающего подразделения
  */

  PROCEDURE send_sales_dept_row(par_sales_dept_id NUMBER) IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'send_sales_dept_row';
    v_data_element JSON := JSON();
    v_data_array   JSON_LIST := JSON_LIST();
    v_answer       JSON;
    v_error_text   VARCHAR2(250);
    v_status       NUMBER;

    v_universal_code VARCHAR2(4);
    v_dept_name      ven_sales_dept.dept_name%TYPE;
    v_tap_num        VARCHAR2(50);
    v_close_date     DATE;
    v_url            VARCHAR2(255);
  BEGIN
    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'send_sales_dept_row'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден URL для операции "send_sales_dept_row"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько URL для операции "send_sales_dept_row"');
    END;

    /* Получение данных по подразделению */
    BEGIN
      SELECT to_char(sh.universal_code, 'FM0009')
            ,sd.dept_name
            ,to_char(tp.tap_number, 'FM999999999909')
            ,sd.close_date
        INTO v_universal_code
            ,v_dept_name
            ,v_tap_num
            ,v_close_date
        FROM ven_sales_dept        sd
            ,ven_sales_dept_header sh
            ,ven_t_tap_header      th
            ,ven_t_tap             tp
       WHERE sd.sales_dept_id = par_sales_dept_id
         AND sd.sales_dept_header_id = sh.sales_dept_header_id
         AND sd.t_tap_header_id = th.t_tap_header_id
         AND th.last_tap_id = tp.t_tap_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найдено подразделение');
    END;
    -- Запись полученных данных в объект JSON
    v_data_element.put('num', v_universal_code);
    v_data_element.put('name', v_dept_name);
    v_data_element.put('tap', v_tap_num);
    v_data_element.put('close_date', v_close_date);
    v_data_array.append(v_data_element.to_json_value);
    -- Обмен
    v_answer := json_lob_conversation('dept_update', v_data_array, v_url, vc_proc_name);

    -- Если есть общая ошибка
    IF v_answer.get('cod').get_number > 0
    THEN
      v_error_text := v_answer.get('error_text').get_string;
      v_status     := -1;
    ELSIF v_answer.get('cod').get_number = 0
    THEN
      -- Получаем массив
      v_data_array   := JSON_LIST(v_answer.get('data'));
      v_data_element := JSON(v_data_array.get(1));
      v_status       := CASE v_data_element.get('cod').get_number
                          WHEN 0 THEN
                           1
                          ELSE
                           -1
                        END;
      v_error_text   := v_data_element.get('error_text').get_string;
    ELSE
      v_status     := 1;
      v_error_text := NULL;
    END IF;

    UPDATE ven_sales_dept tt
       SET tt.send_status     = v_status
          ,tt.send_error_text = v_error_text
     WHERE tt.sales_dept_id = par_sales_dept_id;
    --    v_answer.print;
  END send_sales_dept_row;

  /*
    Байтин А. + Чирков В.
    Получение курса валют

    par_date - Дата курса
  */

  PROCEDURE get_rate
  (
    par_date DATE
   ,par_eur  OUT NUMBER
   ,par_usd  OUT NUMBER
  ) IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'get_rate';
    v_data_element JSON := JSON();
    v_data_array   JSON_LIST := JSON_LIST();
    v_answer       JSON;
    v_date         DATE;
    v_url          VARCHAR2(255);
  BEGIN
    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'get_rate'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найден URL для операции "get_rate"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько URL для операции "get_rate"');
    END;
    par_eur := -1;
    par_usd := -1;
    v_data_element.put('date', par_date);
    v_data_array.append(v_data_element.to_json_value);
    v_answer := json_lob_conversation('get_kurs_valut', v_data_array, v_url, vc_proc_name);

    --нельзя получать дату курса за день, на который нет курса
    v_date := TO_DATE(v_answer.get('date').get_string, 'dd.mm.yyyy');
    IF trunc(v_date) = trunc(par_date)
    THEN
      IF v_answer.exist('data')
      THEN
        --если получили данные
        v_data_element := JSON(v_answer.get('data')); --получаем объект с данными
        IF (NOT v_data_element.get('dollar').get_number IS NULL)
           AND (NOT v_data_element.get('euro').get_number IS NULL)
        THEN
          par_usd := v_data_element.get('dollar').get_number; --получаем значение доллара
          par_eur := v_data_element.get('euro').get_number; --получаем значение евро
        END IF;
      END IF;
    END IF;
    ------------------
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'При получении курса валют возникла ошибка' || SQLERRM ||
                              '. error_text: ' || v_answer.get('error_text').get_string);
  END get_rate;

  /*
    Байтин А.
    Импорт дат продаж агентов
  */
  PROCEDURE import_agent_sales_dates IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'import_agent_sales_dates';
    vc_rowcount NUMBER := 200; -- Количество строк в посылке
    v_element   JSON;
    v_array     JSON_LIST := JSON_LIST();
    v_lob       CLOB;
    v_url       VARCHAR2(255);
    -- обработка результата
    PROCEDURE process_answer IS
      v_agent  agn_sales_ops.agent_num%TYPE;
      v_error  agn_sales_ops.error_text%TYPE;
      v_date   VARCHAR2(20);
      v_result agn_sales_ops.state%TYPE;
    BEGIN
      v_element := json_lob_conversation(par_mode      => 'get_last_date_sales_agents'
                                        ,par_data      => v_array
                                        ,par_url       => v_url
                                        ,par_proc_name => vc_proc_name);
      -- Если есть элемент 'data', преобразуем его в массив
      IF v_element.exist('data')
      THEN
        v_array := JSON_LIST(v_element.get('data'));
        -- Если количество элементов больше 0, обрабатываем результат
        IF v_array.count > 0
        THEN
          FOR i IN 1 .. v_array.count
          LOOP
            v_agent  := JSON(v_array.get(i)).get('agent_num').get_number;
            v_error  := JSON(v_array.get(i)).get('error_text').get_string;
            v_date   := JSON(v_array.get(i)).get('date').get_string;
            v_result := JSON(v_array.get(i)).get('cod').get_number;
            UPDATE agn_sales_ops ag
               SET ag.operation_date = SYSDATE
                  ,ag.error_text     = v_error
                  ,ag.state          = CASE v_result
                                         WHEN 1 THEN
                                          1
                                         ELSE
                                          99
                                       END
                  ,ag.sales_date     = TO_DATE(decode(v_date, '00.00.0000', '01.01.1900', v_date)
                                              ,'dd.mm.yyyy')
             WHERE ag.agent_num = v_agent;
          END LOOP;
        END IF;
      END IF;
      v_array := JSON_LIST();
    END process_answer;
  BEGIN
    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'import_agent_sales_dates'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден URL для операции "import_agent_sales_dates"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько URL для операции "import_agent_sales_dates"');
    END;

    dbms_lob.createtemporary(lob_loc => v_lob, cache => FALSE);
    -- Цикл по агентам
    FOR vr_agents IN (SELECT aso.agent_num
                            ,rownum rn
                        FROM agn_sales_ops aso
                      --                       where rownum <= 500
                      )
    LOOP
      -- Накапливаем агентов в массиве
      v_element := JSON();
      v_element.put('agent_num', vr_agents.agent_num);
      v_array.append(v_element.to_json_value);
      -- Если достигнуто нужное для передачи число агентов, передаем и получаем ответ
      IF MOD(vr_agents.rn, vc_rowcount) = 0
      THEN
        process_answer;
      END IF;
    END LOOP;
    -- Если вышли из цикла, но в массиве еще остались непереданные строки
    IF v_array.count > 0
    THEN
      process_answer;
    END IF;
  END;

  /**Процедура импорта данных по Агентскому договору в B2B
  * @autor Байтин А.
  * @param agn_gate_table_id - ИД записи из шлюзовой таблицы обмена даннми Агентского модуля с B2B
  */
  PROCEDURE import_agent_contract
  (
    par_ag_contract_header_id PLS_INTEGER
   ,v_oper                    PLS_INTEGER
   ,par_error                 OUT VARCHAR2
  ) IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'import_agent_contract';
    v_data_element JSON;
    v_data_array   JSON_LIST := JSON_LIST();
    v_answer       JSON;
    v_statement    VARCHAR2(2000);
    v_agent        agn_gate_table.agent_num%TYPE;
    v_error        agn_gate_table.error_text%TYPE;
    v_result       agn_gate_table.state%TYPE;
    v_url          VARCHAR2(255);

    v_tac_num        agn_tac.tac_num%TYPE;
    v_universal_code VARCHAR2(4);
    v_stat           PLS_INTEGER := 0;
    v_err            VARCHAR2(255);
    v_status         VARCHAR2(50);
    --v_oper              PLS_INTEGER;
    v_agn_gate_table_id agn_gate_table.agn_gate_table_id%TYPE;

    vr_agent agn_gate_table%ROWTYPE;

    PROCEDURE append_agn_gate_table IS
      PRAGMA AUTONOMOUS_TRANSACTION; -- прагма нужна чтобы данные обязательно добавились в шлюзовую таблицу
      -- даже при ошибке из вне
    BEGIN
      INSERT INTO agn_gate_table VALUES vr_agent;
      COMMIT;
    END;

  BEGIN
    -- Байтин А.
    -- Добавил универсальный код продающего подразделения
    BEGIN
      SELECT at.tac_num
            ,to_char(sh.universal_code, 'FM0009')
        INTO v_tac_num
            ,v_universal_code
        FROM ag_contract_header    ach
            ,department            dt
            ,organisation_tree     ot
            ,agn_tac               at
            ,ven_sales_dept_header sh
       WHERE ach.ag_contract_header_id = par_ag_contract_header_id
         AND ach.agency_id = dt.department_id
         AND at.agn_tac_id = ot.tac_id
         AND dt.org_tree_id = ot.organisation_tree_id
         AND ot.organisation_tree_id = sh.organisation_tree_id(+);
    EXCEPTION
      WHEN no_data_found THEN
        v_stat := 2;
        v_err  := 'Этому агентству не соответсвует ни один ТАП';
    END;

    /*v_status := doc.get_doc_status_brief(par_ag_contract_header_id);

    CASE
      WHEN v_status = 'CURRENT' THEN
        v_oper := 1;
        -- Байтин А.
        -- Добавил передачу отмененных как и расторгнутые
      WHEN v_status IN ('CANCEL', 'BREAK') THEN
        v_oper := 0;
      ELSE
        --RETURN;
        raise_application_error(-20001, 'у агента статус '||v_status);
    END CASE;
    */
    SELECT sq_agn_gate_table.nextval INTO v_agn_gate_table_id FROM dual;

    SELECT v_agn_gate_table_id
          ,ach.num
          ,ach_l.num
          ,ts.brief
          ,aac.category_name
          ,aac.brief
          ,doc.get_doc_status_name(ach.ag_contract_header_id, '31.12.2999')
          ,2
          ,'Ренессанс Жизнь'
          ,v_tac_num
          ,cn.name
          ,cn.first_name
          ,cn.middle_name
          ,d.name
          ,ach.date_begin
          ,cp.date_of_birth
          ,v_oper
          ,v_stat
          ,v_err
          ,v_universal_code
      INTO vr_agent.agn_gate_table_id
          ,vr_agent.agent_num
          ,vr_agent.leader_num
          ,vr_agent.sales_channel
          ,vr_agent.agent_cat
          ,vr_agent.agent_cat_brief
          ,vr_agent.ag_status
          ,vr_agent.company_id
          ,vr_agent.company_name
          ,vr_agent.tac_num
          ,vr_agent.last_name
          ,vr_agent.first_name
          ,vr_agent.middle_name
          ,vr_agent.agency
          ,vr_agent.contract_date
          ,vr_agent.birth_date
          ,vr_agent.enabled
          ,vr_agent.state
          ,vr_agent.error_text
          ,vr_agent.universal_code
      FROM ven_ag_contract_header ach
          ,ag_contract            ac
          ,ag_category_agent      aac
          ,t_sales_channel        ts
          ,ag_agent_tree          aat
          ,ven_ag_contract_header ach_l
          ,contact                cn
          ,cn_person              cp
          ,department             d
          ,organisation_tree      ot
          ,t_city                 ct
     WHERE ach.ag_contract_header_id = par_ag_contract_header_id
       AND ach.agent_id = cn.contact_id
       AND ach.last_ver_id = ac.ag_contract_id
       AND ts.id = ach.t_sales_channel_id
       AND aac.ag_category_agent_id = ac.category_id
       AND ach.ag_contract_header_id = aat.ag_contract_header_id(+)
       AND ach_l.ag_contract_header_id(+) = aat.ag_parent_header_id
       AND (SYSDATE BETWEEN aat.date_begin AND aat.date_end OR aat.ag_agent_tree_id IS NULL)
       AND cn.contact_id = cp.contact_id(+)
       AND ach.agency_id = d.department_id
       AND d.org_tree_id = ot.organisation_tree_id
       AND ot.city_id = ct.city_id(+);

    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'import_agent_contract'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        v_stat := 2;
        v_err  := 'Этому агентству не соответсвует ни один ТАП';
      WHEN too_many_rows THEN
        v_stat := 2;
        v_err  := 'Найдено несколько URL для операции "import_agent_contract"';
    END;

    v_data_element := JSON();
    v_data_element.put('agency', vr_agent.agency);
    v_data_element.put('agent_cat', vr_agent.agent_cat);
    v_data_element.put('agent_cat_brief', vr_agent.agent_cat_brief);
    v_data_element.put('agent_num', vr_agent.agent_num);
    v_data_element.put('ag_status', vr_agent.ag_status);
    v_data_element.put('birth_date', vr_agent.birth_date);
    v_data_element.put('company_id', vr_agent.company_id);
    v_data_element.put('company_name', vr_agent.company_name);
    v_data_element.put('contract_date', vr_agent.contract_date);
    v_data_element.put('enabled', vr_agent.enabled);
    v_data_element.put('first_name', vr_agent.first_name);
    v_data_element.put('last_name', vr_agent.last_name);
    v_data_element.put('leader_num', vr_agent.leader_num);
    v_data_element.put('middle_name', vr_agent.middle_name);
    v_data_element.put('sales_channel', vr_agent.sales_channel);
    v_data_element.put('tac_num', vr_agent.tac_num);
    v_data_element.put('universal_code', vr_agent.universal_code);
    v_data_array.append(v_data_element.to_json_value);

    --изменяем данные в шлюзовой таблице
    vr_agent.operation_stmnt := v_data_element.to_char(FALSE);
    vr_agent.operation_date  := SYSDATE;
    vr_agent.operation       := 'agent_update';
    --

    -- Обмен
    IF v_data_array.count > 0
    THEN
      v_answer := json_lob_conversation('agent_update', v_data_array, v_url, vc_proc_name);
      -- Если ошибка общая
      IF v_answer.get('error_text').get_string IS NOT NULL
      THEN
        v_result := v_answer.get('cod').get_number;
        --изменяем данные в шлюзовой таблице
        vr_agent.state := CASE v_result
                            WHEN 0 THEN
                             1
                            ELSE
                             99
                          END;

        vr_agent.error_text := v_answer.get('error_text').get_string;

      ELSE
        IF v_answer.exist('data')
        THEN
          v_data_array := JSON_LIST(v_answer.get('data'));
          -- Если количество элементов больше 0, обрабатываем результат
          IF v_data_array.count > 0
          THEN
            --в массиве один элемент
            FOR i IN 1 .. v_data_array.count
            LOOP
              v_agent  := JSON(v_data_array.get(i)).get('agent_num').get_number;
              v_error  := JSON(v_data_array.get(i)).get('error_text').get_string;
              v_result := JSON(v_data_array.get(i)).get('cod').get_number;

              vr_agent.state := CASE v_result
                                  WHEN 0 THEN
                                   1
                                  ELSE
                                   99
                                END;

              IF v_error IS NOT NULL
              THEN
                vr_agent.error_text := v_error;
              END IF;

            END LOOP;
          END IF;
        END IF;
      END IF;
    END IF;
    --    v_answer.print;

    par_error := vr_agent.error_text;

    --добавляем данные в шлюз
    append_agn_gate_table;

  END import_agent_contract;

  /*
     Байтин А.
     Получение ОПС и СОФИ

  */
  PROCEDURE get_ops_sofi_policy(par_operation_name VARCHAR2 -- Поддерживаемые значения: get_orders_ops, get_orders_sofi,
                                --                          get_payments_sofi, get_payments_pfr
                               ,par_date DATE DEFAULT SYSDATE -- Дата, на которую получаются платежи ПФР
                                ) IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'get_ops_sofi_policy';
    vr_person       etl.npf_person%ROWTYPE;
    vr_policy       etl.npf_ops_policy%ROWTYPE;
    vr_status       etl.npf_status_ref%ROWTYPE;
    vr_product      etl.npf_product%ROWTYPE;
    vr_payment_pfr  etl.npf_sofi_payments%ROWTYPE;
    vr_payment_sofi etl.npf_sofi%ROWTYPE;
    v_data_element  JSON;
    v_answer        JSON;
    v_person        JSON;
    v_policy        JSON;
    v_payment       JSON;
    v_data_array    JSON_LIST;

    v_response JSON_LIST := JSON_LIST();

    vc_limit CONSTANT NUMBER := 100;
    v_limit NUMBER := vc_limit;
    v_error VARCHAR2(500);

    v_url        VARCHAR2(255);
    v_was_errors BOOLEAN := FALSE;
    /*
      Байтин А.
      Добавление/изменение контакта в npf_person на основании полученных из B2B данных
    */
    PROCEDURE merge_npf_person(vr_person etl.npf_person%ROWTYPE) IS
    BEGIN
      IF vr_person.person_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан person_id!');
      END IF;
      MERGE INTO etl.npf_person pr
      USING (SELECT vr_person.person_id  AS person_id
                   ,vr_person.surname    AS surname
                   ,vr_person.name       AS NAME
                   ,vr_person.midname    AS midname
                   ,vr_person.gender     AS gender
                   ,vr_person.birth_date AS birth_date
                   ,vr_person.snils      AS snils
               FROM dual) src
      ON (pr.person_id = src.person_id)
      WHEN MATCHED THEN
        UPDATE
           SET pr.surname    = src.surname
              ,pr.name       = src.name
              ,pr.midname    = src.midname
              ,pr.gender     = src.gender
              ,pr.birth_date = src.birth_date
              ,pr.snils      = src.snils
      WHEN NOT MATCHED THEN
        INSERT
          (person_id, surname, NAME, midname, gender, birth_date, snils)
        VALUES
          (src.person_id, src.surname, src.name, src.midname, src.gender, src.birth_date, src.snils);
    END merge_npf_person;
    /*
      Байтин А.
      Добавление/изменение платежа СОФИ в get_payments_pfr на основании полученных из B2B данных
    */
    PROCEDURE merge_npf_sofi_payments(vr_sofi_payments etl.npf_sofi_payments%ROWTYPE) IS
    BEGIN
      IF vr_sofi_payments.person_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан person_id!');
      END IF;
      IF vr_sofi_payments.ag_contract_num IS NULL
      THEN
        raise_application_error(-20001, 'Не указан ag_contract_num!');
      END IF;
      IF vr_sofi_payments.payment_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан payment_id!');
      END IF;
      IF vr_sofi_payments.payment_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан pay_date!');
      END IF;
      IF vr_sofi_payments.payment_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан amount!');
      END IF;
      MERGE INTO etl.npf_sofi_payments pr
      USING (SELECT vr_sofi_payments.person_id       AS person_id
                   ,vr_sofi_payments.amount          AS amount
                   ,vr_sofi_payments.pay_date        AS pay_date
                   ,vr_sofi_payments.ag_contract_num AS ag_contract_num
                   ,vr_sofi_payments.payment_id      AS payment_id
               FROM dual) src
      ON (pr.payment_id = src.payment_id)
      WHEN MATCHED THEN
        UPDATE
           SET pr.amount          = src.amount
              ,pr.pay_date        = src.pay_date
              ,pr.ag_contract_num = src.ag_contract_num
              ,pr.person_id       = src.person_id
      WHEN NOT MATCHED THEN
        INSERT
          (payment_id, person_id, amount, pay_date, ag_contract_num)
        VALUES
          (src.payment_id, src.person_id, src.amount, src.pay_date, src.ag_contract_num);
    END merge_npf_sofi_payments;
    /*
      Байтин А.
      Добавление/изменение продукта в npf_product на основании полученных из B2B данных
    */
    PROCEDURE merge_npf_product(vr_product etl.npf_product%ROWTYPE) IS
    BEGIN
      IF vr_product.product_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан product_id!');
      END IF;
      MERGE INTO etl.npf_product pr
      USING (SELECT vr_product.product_id   AS product_id
                   ,vr_product.product_name AS product_name
               FROM dual) src
      ON (pr.product_id = src.product_id)
      WHEN MATCHED THEN
        UPDATE SET pr.product_name = src.product_name
      WHEN NOT MATCHED THEN
        INSERT (product_id, product_name) VALUES (src.product_id, src.product_name);
    END merge_npf_product;

    /*
      Байтин А.
      Добавление/изменение статуса в npf_status_ref на основании полученных из B2B данных
    */
    PROCEDURE merge_npf_status_ref(vr_status etl.npf_status_ref%ROWTYPE) IS
    BEGIN
      IF vr_status.status_ref_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан status_ref_id!');
      END IF;
      MERGE INTO etl.npf_status_ref pr
      USING (SELECT vr_status.status_ref_id AS status_ref_id
                   ,vr_status.status_name   AS status_name
               FROM dual) src
      ON (pr.status_ref_id = src.status_ref_id)
      WHEN MATCHED THEN
        UPDATE SET pr.status_name = src.status_name
      WHEN NOT MATCHED THEN
        INSERT (status_ref_id, status_name) VALUES (src.status_ref_id, src.status_name);
    END merge_npf_status_ref;

    /*
      Байтин А.
      Добавление/изменение полиса в npf_ops_policy на основании полученных из B2B данных
    */
    PROCEDURE merge_npf_policy(vr_policy etl.npf_ops_policy%ROWTYPE) IS
    BEGIN
      IF vr_policy.policy_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан policy_id!');
      END IF;
      MERGE INTO etl.npf_ops_policy pr
      USING (SELECT vr_policy.policy_id       AS policy_id
                   ,vr_policy.person_id       AS person_id
                   ,vr_policy.product_id      AS product_id
                   ,vr_policy.status_ref_id   AS status_ref_id
                   ,vr_policy.policy_num      AS policy_num
                   ,vr_policy.ag_contract_num AS ag_contract_num
                   ,vr_policy.sign_date       AS sign_date
                   ,vr_policy.notice_date     AS notice_date
                   ,vr_policy.ops_is_seh      AS ops_is_seh
                   ,vr_policy.kv_flag         AS kv_flag
                   ,vr_policy.status_comment  AS status_comment
                   ,vr_policy.created_at      AS created_at
               FROM dual) src
      ON (pr.policy_id = src.policy_id)
      WHEN MATCHED THEN
        UPDATE
           SET pr.person_id       = src.person_id
              ,pr.product_id      = src.product_id
              ,pr.status_ref_id   = src.status_ref_id
              ,pr.policy_num      = src.policy_num
              ,pr.ag_contract_num = src.ag_contract_num
              ,pr.sign_date       = src.sign_date
              ,pr.notice_date     = src.notice_date
              ,pr.ops_is_seh      = src.ops_is_seh
              ,pr.kv_flag         = src.kv_flag
              ,pr.status_comment  = src.status_comment
              ,pr.created_at      = src.created_at
      WHEN NOT MATCHED THEN
        INSERT
          (policy_id
          ,person_id
          ,product_id
          ,status_ref_id
          ,policy_num
          ,ag_contract_num
          ,sign_date
          ,notice_date
          ,ops_is_seh
          ,kv_flag
          ,status_comment
          ,created_at)
        VALUES
          (src.policy_id
          ,src.person_id
          ,src.product_id
          ,src.status_ref_id
          ,src.policy_num
          ,src.ag_contract_num
          ,src.sign_date
          ,src.notice_date
          ,src.ops_is_seh
          ,src.kv_flag
          ,src.status_comment
          ,src.created_at);
    END merge_npf_policy;
    /*
      Байтин А.
      Добавление/изменение платежа СОФИ в npf_sofi_payments на основании полученных из B2B данных
    */
    PROCEDURE merge_npf_sofi(vr_sofi etl.npf_sofi%ROWTYPE) IS
    BEGIN
      IF vr_sofi.person_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан person_id!');
      END IF;
      IF vr_sofi.ag_contract_num IS NULL
      THEN
        raise_application_error(-20001, 'Не указан ag_contract_num!');
      END IF;
      IF vr_sofi.payment_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан payment_id!');
      END IF;
      IF vr_sofi.payment_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан amount!');
      END IF;
      IF vr_sofi.payment_id IS NULL
      THEN
        raise_application_error(-20001, 'Не указан sofi_pay_date!');
      END IF;
      MERGE INTO etl.npf_sofi pr
      USING (SELECT vr_sofi.person_id       AS person_id
                   ,vr_sofi.ag_contract_num AS ag_contract_num
                   ,vr_sofi.amount          AS amount
                   ,vr_sofi.sofi_pay_date   AS sofi_pay_date
                   ,vr_sofi.payment_id      AS payment_id
               FROM dual) src
      ON (pr.payment_id = src.payment_id)
      WHEN MATCHED THEN
        UPDATE
           SET pr.ag_contract_num = src.ag_contract_num
              ,pr.amount          = src.amount
              ,pr.sofi_pay_date   = src.sofi_pay_date
              ,pr.person_id       = src.person_id
      WHEN NOT MATCHED THEN
        INSERT
          (payment_id, person_id, ag_contract_num, amount, sofi_pay_date)
        VALUES
          (src.payment_id, src.person_id, src.ag_contract_num, src.amount, src.sofi_pay_date);
    END merge_npf_sofi;
  BEGIN
    -- Проверка допустимых значений для par_operation_name
    IF par_operation_name NOT IN
       ('get_orders_ops', 'get_payments_sofi', 'get_orders_sofi', 'get_payments_pfr')
    THEN
      raise_application_error(-20001
                             ,'Указано недопустимое занчение параметра par_operation_name');
    END IF;

    -- Получение настроек
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_db   db
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND db.db_brief = sys.database_name
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND op.oper_brief = 'get_ops_sofi_policy'
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
         AND ty.type_brief = 'URL';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден URL для операции "get_ops_sofi_policy"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько URL для операции "get_ops_sofi_policy"');
    END;

    LOOP
      -- Запрос
      v_data_element := JSON();
      v_data_element.put('count_limit', vc_limit);
      IF par_operation_name = 'get_payments_pfr'
      THEN
        v_data_element.put('kvartal', to_number(to_char(par_date, 'Q')));
        v_data_element.put('year', extract(YEAR FROM par_date));
      END IF;
      v_data_array := JSON_LIST();
      v_data_array.append(v_data_element.to_json_value);
      v_answer := json_lob_conversation(par_operation_name, v_data_array, v_url, vc_proc_name);
      /*
      v_answer.print;
      return;
      */
      -- Разбор результата
      IF v_answer.get('error_text').get_string IS NOT NULL
      THEN
        -- Если общая ошибка делаем exception с текстом ошибки
        raise_application_error(-20001, v_answer.get('error_text').get_string);
      ELSE
        -- Количество записей
        v_limit := v_answer.get('cod').get_number;
        IF v_limit > 0
        THEN
          v_data_array := JSON_LIST(v_answer.get('data'));
          -- Если количество элементов больше 0, обрабатываем результат
          IF v_data_array.count > 0
          THEN
            v_response := JSON_LIST();
            FOR i IN 1 .. v_data_array.count
            LOOP
              BEGIN
                -- Данные по контакту
                IF JSON(v_data_array.get(i)).exist('person')
                THEN
                  v_person             := JSON(JSON(v_data_array.get(i)).get('person'));
                  vr_person.person_id  := v_person.get('person_id').get_number;
                  vr_person.surname    := v_person.get('surname').get_string;
                  vr_person.name       := v_person.get('name').get_string;
                  vr_person.midname    := v_person.get('midname').get_string;
                  vr_person.gender     := v_person.get('gender').get_number;
                  vr_person.birth_date := TO_DATE(v_person.get('birth_date').get_string, 'dd.mm.yyyy');
                  vr_person.snils      := v_person.get('snils').get_string;
                  -- Обновление/добавление контакта
                  merge_npf_person(vr_person);
                END IF;
                -- Данные по полису
                IF JSON(v_data_array.get(i)).exist('policy')
                THEN
                  v_policy := JSON(JSON(v_data_array.get(i)).get('policy'));

                  vr_policy.policy_id       := v_policy.get('policy_id').get_number;
                  vr_policy.person_id       := vr_person.person_id;
                  vr_policy.product_id      := v_policy.get('product_id').get_number;
                  vr_product.product_id     := vr_policy.product_id;
                  vr_product.product_name   := v_policy.get('product_name').get_string;
                  vr_policy.status_ref_id   := v_policy.get('status_ref_id').get_number;
                  vr_status.status_ref_id   := vr_policy.status_ref_id;
                  vr_status.status_name     := v_policy.get('status_name').get_string;
                  vr_policy.policy_num      := v_policy.get('policy_num').get_string;
                  vr_policy.ag_contract_num := v_policy.get('ag_contract_num').get_string;
                  vr_policy.sign_date       := TO_DATE(v_policy.get('sign_date').get_string
                                                      ,'dd.mm.yyyy');
                  vr_policy.notice_date     := TO_DATE(v_policy.get('notice_date').get_string
                                                      ,'dd.mm.yyyy');
                  IF v_policy.exist('status_comment')
                  THEN
                    vr_policy.status_comment := v_policy.get('status_comment').get_string;
                  ELSE
                    vr_policy.status_comment := NULL;
                  END IF;
                  IF v_policy.exist('ops_is_seh')
                  THEN
                    vr_policy.ops_is_seh := v_policy.get('ops_is_seh').get_number;
                  ELSE
                    vr_policy.ops_is_seh := NULL;
                  END IF;
                  IF v_policy.exist('kv_flag')
                  THEN
                    vr_policy.kv_flag := v_policy.get('kv_flag').get_number;
                  ELSE
                    vr_policy.kv_flag := NULL;
                  END IF;
                  IF v_policy.exist('created_at')
                  THEN
                    vr_policy.created_at := v_policy.get('created_at').get_string;
                  END IF;
                  merge_npf_product(vr_product);
                  merge_npf_status_ref(vr_status);
                  merge_npf_policy(vr_policy);
                END IF;
                -- Поступившие деньги по СОФИ
                IF JSON(v_data_array.get(i)).exist('payment')
                THEN
                  v_payment := JSON(JSON(v_data_array.get(i)).get('payment'));
                  IF par_operation_name = 'get_payments_pfr'
                  THEN
                    vr_payment_pfr.person_id       := vr_person.person_id;
                    vr_payment_pfr.payment_id      := to_number(v_payment.get('payment_id').get_string);
                    vr_payment_pfr.amount          := to_number(REPLACE(v_payment.get('amount')
                                                                        .get_string
                                                                       ,'.'
                                                                       ,',')
                                                               ,'FM9999999999999D99' /*,'NLS_NUMERIC_CHARACTERS = ''.,'''*/);
                    vr_payment_pfr.pay_date        := TO_DATE('01.' || lpad(to_number(v_payment.get('kvartal')
                                                                                      .get_string) * 3 - 2
                                                                           ,2
                                                                           ,'0') || '.' ||
                                                              to_number(v_payment.get('year')
                                                                        .get_string)
                                                             ,'dd.mm.yyyy');
                    vr_payment_pfr.ag_contract_num := vr_policy.ag_contract_num;
                    merge_npf_sofi_payments(vr_payment_pfr);
                  ELSIF par_operation_name = 'get_payments_sofi'
                  THEN
                    vr_payment_sofi.payment_id      := v_payment.get('payment_id').get_number;
                    vr_payment_sofi.person_id       := vr_person.person_id;
                    vr_payment_sofi.ag_contract_num := vr_policy.ag_contract_num;
                    vr_payment_sofi.amount          := to_number(REPLACE(v_payment.get('amount')
                                                                         .get_string
                                                                        ,'.'
                                                                        ,',')
                                                                ,'FM9999999999999D99' /*,'NLS_NUMERIC_CHARACTERS = ''.,'''*/);
                    vr_payment_sofi.sofi_pay_date   := TO_DATE(v_payment.get('pay_date').get_string
                                                              ,'dd.mm.yyyy');
                    merge_npf_sofi(vr_payment_sofi);
                  END IF;
                END IF;
                -- Накапливаем ошибки
                -- Для 'get_payments_pfr' ответ не требуется
                IF par_operation_name != 'get_payments_pfr'
                THEN
                  v_data_element := JSON();
                  v_data_element.put('cod', 1);
                  IF par_operation_name IN ('get_orders_ops', 'get_orders_sofi')
                  THEN
                    v_data_element.put('person_id', vr_person.person_id);
                    v_data_element.put('policy_id', vr_policy.policy_id);
                  ELSIF par_operation_name = 'get_payments_pfr'
                  THEN
                    v_data_element.put('payment_id', vr_payment_pfr.payment_id);
                  ELSIF par_operation_name = 'get_payments_sofi'
                  THEN
                    v_data_element.put('payment_id', vr_payment_sofi.payment_id);
                  END IF;
                  v_data_element.put('error_text', '');
                  v_response.append(v_data_element.to_json_value);
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  v_error := SQLERRM;
                  -- Накапливаем ошибки
                  -- Для 'get_payments_pfr' ответ не требуется
                  IF par_operation_name != 'get_payments_pfr'
                  THEN
                    v_data_element := JSON();
                    v_data_element.put('cod', 0);
                    IF par_operation_name IN ('get_orders_ops', 'get_orders_sofi')
                    THEN
                      v_data_element.put('person_id', vr_person.person_id);
                      v_data_element.put('policy_id', vr_policy.policy_id);
                    ELSIF par_operation_name = 'get_payments_pfr'
                    THEN
                      v_data_element.put('payment_id', vr_payment_pfr.payment_id);
                    ELSIF par_operation_name = 'get_payments_sofi'
                    THEN
                      v_data_element.put('payment_id', vr_payment_sofi.payment_id);
                    END IF;
                    v_data_element.put('error_text', v_error);
                    v_response.append(v_data_element.to_json_value);
                    v_was_errors := TRUE;
                  END IF;
              END;
            END LOOP;
            -- Для 'get_payments_pfr' ответ не требуется
            IF par_operation_name != 'get_payments_pfr'
            THEN
              --              v_response.print;
              v_answer := json_lob_conversation(par_operation_name || '_commit'
                                               ,v_response
                                               ,v_url
                                               ,vc_proc_name);
              --              v_answer.print;
            END IF;
          END IF;
        END IF;
      END IF;
      COMMIT;
      IF v_was_errors
      THEN
        raise_application_error(-20001
                               ,'При передаче данных обнаружены ошибки!');
      END IF;
      -- Выход, если количество записей меньше, чем запрашивали, выходим
      -- Также выходим, если операция - получение платежей ПФР
      EXIT WHEN v_limit < vc_limit OR par_operation_name = 'get_payments_pfr';
    END LOOP;
  END get_ops_sofi_policy;

  /*
    Байтин А.
    Инициализация значений по умолчанию для договора
  */
  FUNCTION init_policy_values(par_product_brief VARCHAR2) RETURN t_policy_values IS
    vr_policy_values t_policy_values;
  BEGIN
    BEGIN
      SELECT pr.product_id
        INTO vr_policy_values.product_id
        FROM t_product pr
       WHERE pr.brief = par_product_brief;
      vr_policy_values.product_brief := par_product_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден продукт "' || par_product_brief || '"!');
    END;

    BEGIN
      SELECT pc.currency_id
            ,fd.brief
        INTO vr_policy_values.fund_id
            ,vr_policy_values.fund_brief
        FROM t_prod_currency pc
            ,fund            fd
       WHERE pc.product_id = vr_policy_values.product_id
         AND pc.currency_id = fd.fund_id
         AND pc.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена валюта ответственности по умолчанию');
    END;

    BEGIN
      SELECT pc.currency_id
        INTO vr_policy_values.fund_pay_id
        FROM t_prod_pay_curr pc
       WHERE pc.product_id = vr_policy_values.product_id
         AND pc.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена валюта платежа по умолчанию');
    END;

    BEGIN
      SELECT cc.confirm_condition_id
        INTO vr_policy_values.confirm_condition_id
        FROM t_product_conf_cond cc
       WHERE cc.is_default = 1
         AND cc.product_id = vr_policy_values.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдено условие вступления в силу по умолчанию');
    END;

    BEGIN
      SELECT pt.payment_term_id
            ,te.is_periodical
        INTO vr_policy_values.payment_term_id
            ,vr_policy_values.is_periodical
        FROM t_prod_payment_terms pt
            ,t_payment_terms      te
       WHERE pt.product_id = vr_policy_values.product_id
         AND pt.is_default = 1
         AND pt.payment_term_id = te.id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип премии по умолчанию');
    END;

    BEGIN
      SELECT period_id
        INTO vr_policy_values.period_id
        FROM (SELECT pp.period_id
                FROM t_product_period  pp
                    ,t_period_use_type ut
               WHERE pp.product_id = vr_policy_values.product_id
                 AND pp.t_period_use_type_id = ut.t_period_use_type_id
                 AND ut.brief = 'Срок страхования'
                 AND (pp.is_default = 1 OR NOT EXISTS
                      (SELECT NULL
                         FROM t_product_period pp1
                        WHERE pp1.product_id = pp.product_id
                          AND pp1.id != pp.id
                          AND pp1.t_period_use_type_id = ut.t_period_use_type_id))
               ORDER BY pp.sort_order)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден период действия по умолчанию');
    END;

    BEGIN
      SELECT period_id
        INTO vr_policy_values.waiting_period_id
        FROM (SELECT pp.period_id
                FROM t_product_period  pp
                    ,t_period_use_type ut
               WHERE pp.product_id = vr_policy_values.product_id
                 AND pp.t_period_use_type_id = ut.t_period_use_type_id
                 AND ut.brief = 'Выжидательный'
                 AND (pp.is_default = 1 OR NOT EXISTS
                      (SELECT NULL
                         FROM t_product_period pp1
                        WHERE pp1.product_id = pp.product_id
                          AND pp1.id != pp.id
                          AND pp1.t_period_use_type_id = ut.t_period_use_type_id))
               ORDER BY pp.sort_order)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден выжидательный период по умолчанию');
    END;

    BEGIN
      SELECT period_id
        INTO vr_policy_values.privilege_period_id
        FROM (SELECT pp.period_id
                FROM t_product_period  pp
                    ,t_period_use_type ut
               WHERE pp.product_id = vr_policy_values.product_id
                 AND pp.t_period_use_type_id = ut.t_period_use_type_id
                 AND ut.brief = 'Льготный'
               ORDER BY pp.sort_order)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не найден льготный период');
    END;

    BEGIN
      SELECT discount_f_id
        INTO vr_policy_values.discount_f_id
        FROM discount_f
       WHERE brief = 'База';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена скидка по нагрузке "База"');
    END;

    BEGIN
      SELECT t_work_group_id
        INTO vr_policy_values.work_group_id
        FROM t_work_group
       WHERE description = '1 группа';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена группа профессий с названием "1 группа"');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько групп профессий с названием "1 группа"');
    END;

    RETURN vr_policy_values;
  END init_policy_values;

  /*
    Байтин А.
    Запись данных из B2B по полису в шлюзовую таблицу
  */

  PROCEDURE write_policy_gate_table
  (
    par_data_array JSON_LIST
   ,par_was_errors OUT BOOLEAN
  ) IS
    date_format_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(date_format_error, -1861);

    TYPE tt_t_beneficiaries IS TABLE OF p_policy_gate_bnf%ROWTYPE;
    TYPE tt_t_addresses IS TABLE OF p_policy_gate_adr%ROWTYPE;
    TYPE tt_t_phones IS TABLE OF p_policy_gate_phn%ROWTYPE;
    TYPE tt_t_addresses_prs IS TABLE OF tt_t_addresses INDEX BY VARCHAR2(5);
    TYPE tt_t_phones_prs IS TABLE OF tt_t_phones INDEX BY VARCHAR2(5);
    TYPE tt_prog_vals IS TABLE OF p_policy_gate_prg%ROWTYPE;
    TYPE tt_persons IS TABLE OF p_policy_gate_prs%ROWTYPE INDEX BY VARCHAR2(5);

    v_prog_vals          tt_prog_vals := tt_prog_vals();
    v_beneficiaries_vals tt_t_beneficiaries := tt_t_beneficiaries();
    v_person             JSON;
    v_policy             JSON;
    v_certificate        JSON;
    v_addresses          JSON_LIST;
    v_addresses_vals     tt_t_addresses_prs;
    v_phones             JSON_LIST;
    v_phones_vals        tt_t_phones_prs;
    v_beneficiaries      JSON_LIST;
    v_programs           JSON_LIST;
    v_person_vals        tt_persons;
    v_person_type        VARCHAR2(5);

    vr_pol_gate p_policy_gate%ROWTYPE;

    PROCEDURE put_error
    (
      par_value         IN OUT DATE
     ,par_error         IN OUT VARCHAR2
     ,par_param         VARCHAR2
     ,par_record_status IN OUT NUMBER
    ) IS
    BEGIN
      IF par_record_status = 2
      THEN
        par_value         := TO_DATE('01.01.1900', 'dd.mm.yyyy');
        par_error         := par_error || 'ошибка конвертации "' || par_param || '"';
        par_record_status := 1;
      END IF;
    END put_error;

    PROCEDURE put_error
    (
      par_value         IN OUT NUMBER
     ,par_error         IN OUT VARCHAR2
     ,par_param         VARCHAR2
     ,par_record_status IN OUT NUMBER
    ) IS
    BEGIN
      IF par_record_status = 2
      THEN
        par_value         := 0;
        par_error         := par_error || 'ошибка конвертации "' || par_param || '"';
        par_record_status := 1;
      END IF;
    END put_error;

  BEGIN
    par_was_errors := FALSE;
    FOR i IN 1 .. par_data_array.count
    LOOP
      SAVEPOINT before_write;
      BEGIN
        SELECT sq_p_policy_gate_openbank.nextval INTO vr_pol_gate.p_policy_gate_id FROM dual;
        vr_pol_gate.record_status := 2;
        vr_pol_gate.receive_date  := SYSDATE;
        vr_pol_gate.error_text    := NULL;
        -- Договор
        IF JSON(par_data_array.get(i)).exist('policy')
        THEN
          v_policy                           := JSON(JSON(par_data_array.get(i)).get('policy'));
          vr_pol_gate.policy_b2b_id          := v_policy.get('policy_id').get_number;
          vr_pol_gate.policy_product_brief   := v_policy.get('product_brief').get_string;
          vr_pol_gate.policy_b2b_policy_num  := v_policy.get('policy_num').get_string;
          vr_pol_gate.policy_ag_contract_num := v_policy.get('ag_contract_num').get_string;
          IF v_policy.exist('fund')
          THEN
            vr_pol_gate.policy_fund := v_policy.get('fund').get_string;
          END IF;
          IF v_policy.exist('policy_period')
          THEN
            vr_pol_gate.policy_period := v_policy.get('policy_period').get_number;
          END IF;
          BEGIN
            vr_pol_gate.policy_sign_date := TO_DATE(v_policy.get('sign_date').get_string, 'dd.mm.yyyy');
          EXCEPTION
            WHEN date_format_error THEN
              put_error(vr_pol_gate.policy_sign_date
                       ,vr_pol_gate.error_text
                       ,'sign_date'
                       ,vr_pol_gate.record_status);
          END;
          BEGIN
            vr_pol_gate.policy_reg_date := TO_DATE(v_policy.get('reg_date').get_string, 'dd.mm.yyyy');
          EXCEPTION
            WHEN date_format_error THEN
              put_error(vr_pol_gate.policy_reg_date
                       ,vr_pol_gate.error_text
                       ,'reg_date'
                       ,vr_pol_gate.record_status);
          END;
          BEGIN
            vr_pol_gate.policy_notice_date := TO_DATE(v_policy.get('notice_date').get_string
                                                     ,'dd.mm.yyyy');
          EXCEPTION
            WHEN date_format_error THEN
              put_error(vr_pol_gate.policy_notice_date
                       ,vr_pol_gate.error_text
                       ,'notice_date'
                       ,vr_pol_gate.record_status);
          END;
          BEGIN
            vr_pol_gate.policy_sum := to_number(v_policy.get('summa').get_string
                                               ,'FM9999999999999D99'
                                               ,'NLS_NUMERIC_CHARACTERS = ''.,''');
          EXCEPTION
            WHEN value_error THEN
              put_error(vr_pol_gate.policy_sum
                       ,vr_pol_gate.error_text
                       ,'summa'
                       ,vr_pol_gate.record_status);
          END;
          IF v_policy.exist('base_sum')
          THEN
            BEGIN
              vr_pol_gate.base_sum := to_number(v_policy.get('base_sum').get_string
                                               ,'FM9999999999999D99'
                                               ,'NLS_NUMERIC_CHARACTERS = ''.,''');
            EXCEPTION
              WHEN value_error THEN
                put_error(vr_pol_gate.base_sum
                         ,vr_pol_gate.error_text
                         ,'base_sum'
                         ,vr_pol_gate.record_status);
            END;
          END IF;
          IF v_policy.exist('is_credit')
          THEN
            BEGIN
              vr_pol_gate.is_credit := to_number(v_policy.get('is_credit').get_string
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
            EXCEPTION
              WHEN value_error THEN
                put_error(vr_pol_gate.is_credit
                         ,vr_pol_gate.error_text
                         ,'is_credit'
                         ,vr_pol_gate.record_status);
            END;
          END IF;
          -- Данные по страхователю и застрахованному
          IF v_policy.exist('persons')
          THEN
            FOR p IN 1 .. 2
            LOOP
              v_person_type := CASE p
                                 WHEN 1 THEN
                                  'ins'
                                 WHEN 2 THEN
                                  'zl'
                               END;

              v_phones_vals(v_person_type) := tt_t_phones();
              v_addresses_vals(v_person_type) := tt_t_addresses();

              IF JSON(v_policy.get('persons')).exist(v_person_type)
              THEN
                v_person := JSON(JSON(v_policy.get('persons')).get(v_person_type));
                SELECT sq_p_policy_gate_prs.nextval
                  INTO v_person_vals(v_person_type).p_policy_gate_prs_id
                  FROM dual;
                v_person_vals(v_person_type).p_policy_gate_id := vr_pol_gate.p_policy_gate_id;
                v_person_vals(v_person_type).person_type_brief := v_person_type;
                v_person_vals(v_person_type).person_id := v_person.get('person_id').get_number;
                v_person_vals(v_person_type).person_surname := v_person.get('surname').get_string;
                v_person_vals(v_person_type).person_name := v_person.get('name').get_string;
                v_person_vals(v_person_type).person_midname := v_person.get('midname').get_string;
                v_person_vals(v_person_type).person_gender := v_person.get('gender').get_string;
                IF v_person.exist('is_foreign')
                THEN
                  v_person_vals(v_person_type).is_foreign := v_person.get('is_foreign').get_number;
                ELSE
                  v_person_vals(v_person_type).is_foreign := 0;
                END IF;
                BEGIN
                  v_person_vals(v_person_type).person_birthdate := TO_DATE(v_person.get('birth_date')
                                                                           .get_string
                                                                          ,'dd.mm.yyyy');
                EXCEPTION
                  WHEN date_format_error THEN
                    put_error(v_person_vals(v_person_type).person_birthdate
                             ,vr_pol_gate.error_text
                             ,'birth_date'
                             ,vr_pol_gate.record_status);
                END;
                -- Адреса
                IF v_person.exist('addresses')
                THEN
                  v_addresses := JSON_LIST(v_person.get('addresses'));
                  v_addresses_vals(v_person_type).extend(v_addresses.count);

                  FOR a IN 1 .. v_addresses.count
                  LOOP
                    v_addresses_vals(v_person_type)(a).p_policy_gate_prs_id := v_person_vals(v_person_type)
                                                                               .p_policy_gate_prs_id;
                    v_addresses_vals(v_person_type)(a).zip := JSON(v_addresses.get(a)).get('zip')
                                                              .get_string;
                    IF JSON(v_addresses.get(a)).exist('kladr_code')
                    THEN
                      v_addresses_vals(v_person_type)(a).kladr_code := JSON(v_addresses.get(a)).get('kladr_code')
                                                                       .get_string;
                    END IF;
                    v_addresses_vals(v_person_type)(a).address := JSON(v_addresses.get(a)).get('address')
                                                                  .get_string;
                    v_addresses_vals(v_person_type)(a).address_type := JSON(v_addresses.get(a)).get('type')
                                                                       .get_string;
                  END LOOP addresses;
                ELSE
                  raise_application_error(-20001, 'Отсутствует блок addresses');
                END IF;
                -- Паспорт
                IF v_person.exist('certificate')
                THEN
                  v_certificate := JSON(v_person.get('certificate'));
                  IF v_certificate.exist('ser')
                  THEN
                    v_person_vals(v_person_type).pasport_series := v_certificate.get('ser').get_string;
                  END IF;
                  IF v_certificate.exist('num')
                  THEN
                    v_person_vals(v_person_type).pasport_number := v_certificate.get('num').get_string;
                  END IF;
                  IF v_certificate.exist('post')
                  THEN
                    v_person_vals(v_person_type).pasport_who := v_certificate.get('post').get_string;
                  END IF;
                  BEGIN
                    v_person_vals(v_person_type).pasport_when := TO_DATE(v_certificate.get('date')
                                                                         .get_string
                                                                        ,'dd.mm.yyyy');
                  EXCEPTION
                    WHEN date_format_error THEN
                      put_error(v_person_vals(v_person_type).pasport_when
                               ,vr_pol_gate.error_text
                               ,'date'
                               ,vr_pol_gate.record_status);
                  END;
                ELSE
                  raise_application_error(-20001, 'Отсутствует блок certificate');
                END IF;

                -- Телефоны
                IF v_person.exist('phones')
                THEN
                  v_phones := JSON_LIST(v_person.get('phones'));
                  v_phones_vals(v_person_type).extend(v_phones.count);
                  FOR p IN 1 .. v_phones.count
                  LOOP
                    v_phones_vals(v_person_type)(p).p_policy_gate_prs_id := v_person_vals(v_person_type)
                                                                            .p_policy_gate_prs_id;
                    v_phones_vals(v_person_type)(p).num := JSON(v_phones.get(p)).get('num').get_string;
                    v_phones_vals(v_person_type)(p).phone_type := JSON(v_phones.get(p)).get('type')
                                                                  .get_string;
                  END LOOP phones;
                END IF;

                -- Электронная почта
                IF v_person.exist('email')
                THEN
                  v_person_vals(v_person_type).email := v_person.get('email').get_string;
                END IF;
              ELSE
                raise_application_error(-20001, 'Отсутствует блок ' || v_person_type);
              END IF;
            END LOOP;
          ELSE
            raise_application_error(-20001, 'Отсутствует блок persons');
          END IF;
          -- Выгодоприобретатели
          IF v_policy.exist('assignees')
          THEN
            v_beneficiaries := JSON_LIST(v_policy.get('assignees'));
            v_beneficiaries_vals.extend(v_beneficiaries.count);

            FOR b IN 1 .. v_beneficiaries.count
            LOOP
              v_beneficiaries_vals(b).p_policy_gate_id := vr_pol_gate.p_policy_gate_id;
              v_beneficiaries_vals(b).surname := JSON(v_beneficiaries.get(b)).get('surname').get_string;
              v_beneficiaries_vals(b).first_name := JSON(v_beneficiaries.get(b)).get('name').get_string;
              v_beneficiaries_vals(b).midname := JSON(v_beneficiaries.get(b)).get('midname').get_string;
              v_beneficiaries_vals(b).relation := JSON(v_beneficiaries.get(b)).get('related')
                                                  .get_string;
              BEGIN
                v_beneficiaries_vals(b).birthdate := TO_DATE(JSON(v_beneficiaries.get(b)).get('birth_date')
                                                             .get_string
                                                            ,'dd.mm.yyyy');
              EXCEPTION
                WHEN date_format_error THEN
                  put_error(v_beneficiaries_vals(b).birthdate
                           ,vr_pol_gate.error_text
                           ,'birth_date'
                           ,vr_pol_gate.record_status);
              END;
              BEGIN
                v_beneficiaries_vals(b).part := JSON(v_beneficiaries.get(b)).get('share').get_number;
              EXCEPTION
                WHEN value_error THEN
                  put_error(v_beneficiaries_vals(b).part
                           ,vr_pol_gate.error_text
                           ,'share'
                           ,vr_pol_gate.record_status);
              END;
            END LOOP beneficiaries;
          END IF;
          -- Программы
          IF v_policy.exist('programs')
          THEN
            v_programs := JSON_LIST(v_policy.get('programs'));
            v_prog_vals.extend(v_programs.count);
            FOR p IN 1 .. v_programs.count
            LOOP
              v_prog_vals(p).p_policy_gate_id := vr_pol_gate.p_policy_gate_id;
              v_prog_vals(p).brief := JSON(v_programs.get(p)).get('brief').get_string;
              BEGIN
                v_prog_vals(p).proc := to_number(JSON(v_programs.get(p)).get('proc').get_string
                                                ,'FM9999999999999D99'
                                                ,'NLS_NUMERIC_CHARACTERS = ''.,''');
              EXCEPTION
                WHEN value_error THEN
                  put_error(v_prog_vals(p).proc
                           ,vr_pol_gate.error_text
                           ,'proc'
                           ,vr_pol_gate.record_status);
              END;
              BEGIN
                v_prog_vals(p).fee := to_number(JSON(v_programs.get(p)).get('fee').get_string
                                               ,'FM9999999999999D99'
                                               ,'NLS_NUMERIC_CHARACTERS = ''.,''');
              EXCEPTION
                WHEN value_error THEN
                  put_error(v_prog_vals(p).fee
                           ,vr_pol_gate.error_text
                           ,'fee'
                           ,vr_pol_gate.record_status);
              END;
              BEGIN
                v_prog_vals(p).ins_sum := to_number(JSON(v_programs.get(p)).get('ins_sum').get_string
                                                   ,'FM9999999999999D99'
                                                   ,'NLS_NUMERIC_CHARACTERS = ''.,''');
              EXCEPTION
                WHEN value_error THEN
                  put_error(v_prog_vals(p).ins_sum
                           ,vr_pol_gate.error_text
                           ,'ins_sum'
                           ,vr_pol_gate.record_status);
              END;
            END LOOP;
          ELSE
            raise_application_error(-20001, 'Отсутствует блок programs');
          END IF;
        ELSE
          raise_application_error(-20001, 'Отсутствует блок policy');
        END IF;

        INSERT INTO p_policy_gate VALUES vr_pol_gate;

        FORALL i IN v_beneficiaries_vals.first .. v_beneficiaries_vals.last
          INSERT INTO p_policy_gate_bnf VALUES v_beneficiaries_vals (i);

        FORALL i IN v_prog_vals.first .. v_prog_vals.last
          INSERT INTO p_policy_gate_prg VALUES v_prog_vals (i);

        FOR p IN 1 .. 2
        LOOP
          v_person_type := CASE p
                             WHEN 1 THEN
                              'ins'
                             WHEN 2 THEN
                              'zl'
                           END;
          INSERT INTO p_policy_gate_prs VALUES v_person_vals (v_person_type);

          FORALL i IN v_phones_vals(v_person_type).first .. v_phones_vals(v_person_type).last
            INSERT INTO p_policy_gate_phn VALUES v_phones_vals (v_person_type) (i);

          FORALL i IN v_addresses_vals(v_person_type).first .. v_addresses_vals(v_person_type).last
            INSERT INTO p_policy_gate_adr VALUES v_addresses_vals (v_person_type) (i);
        END LOOP;

        v_person_vals.delete;
        v_phones_vals.delete;
        v_addresses_vals.delete;
        v_beneficiaries_vals.delete;
        v_prog_vals.delete;
        IF NOT par_was_errors
           OR par_was_errors IS NULL
        THEN
          par_was_errors := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_write;
          vr_pol_gate.error_text    := SQLERRM;
          vr_pol_gate.record_status := 1;
          par_was_errors            := TRUE;
          INSERT INTO p_policy_gate VALUES vr_pol_gate;
          v_person_vals.delete;
          v_phones_vals.delete;
          v_addresses_vals.delete;
          v_beneficiaries_vals.delete;
          v_prog_vals.delete;
      END;
    END LOOP data_array;
  END write_policy_gate_table;

  /*
     Байтин А.
     Создание договоров Инвестор
     Возвращает true - были ошибки, false - не было
  */
  PROCEDURE create_investor_policy
  (
    par_policy_values pkg_products.t_product_defaults
   ,par_response      IN OUT JSON_LIST
   ,par_was_errors    IN OUT BOOLEAN
  ) IS
    TYPE tt_persons IS TABLE OF p_policy_gate_prs%ROWTYPE INDEX BY PLS_INTEGER;

    v_data_element JSON;

    v_policy_id               p_pol_header.policy_id%TYPE;
    v_sales_channel_id        p_pol_header.sales_channel_id%TYPE;
    v_agency_id               p_pol_header.agency_id%TYPE;
    v_region_id               p_policy.region_id%TYPE;
    v_assured_id              as_assured.as_assured_id%TYPE;
    v_ag_contract_header_id   ag_contract_header.ag_contract_header_id%TYPE;
    v_error                   VARCHAR2(2000);
    v_benef_contact_id        contact.contact_id%TYPE;
    v_beneficiary_id          as_beneficiary.as_beneficiary_id%TYPE;
    v_benef_gender_brief      t_gender.brief%TYPE;
    v_address                 cn_address.name%TYPE;
    v_end_date                p_policy.end_date%TYPE;
    v_fee_payment_term        p_policy.fee_payment_term%TYPE;
    v_cn_contact_telephone_id NUMBER;
    v_is_email_exists         NUMBER(1);
    v_email_id                NUMBER;
    v_persons                 tt_persons;
    v_count_persons           NUMBER(1);
    v_fund_id                 NUMBER;
    v_period_id               NUMBER;
    v_confirm_date            DATE;
    v_first_pay_date          DATE;
  BEGIN
    --par_response   := JSON_LIST();
    --par_was_errors := FALSE;
    FOR vr_gt IN (SELECT ROWID AS rid
                        ,gt.*
                    FROM p_policy_gate gt
                   WHERE gt.record_status = 2
                     AND gt.policy_product_brief = par_policy_values.product_brief)
    LOOP
      BEGIN
        SELECT ph.policy_header_id
          INTO vr_gt.p_pol_header_id
          FROM p_pol_header ph
              ,t_product    p
         WHERE (p.brief = vr_gt.policy_product_brief OR
               (vr_gt.policy_product_brief = 'Platinum_LA2_CityService' AND p.brief = 'Platinum_LA2'))
           AND ph.product_id = p.product_id
           AND EXISTS (SELECT NULL
                  FROM p_policy pp
                 WHERE pp.pol_num = vr_gt.policy_b2b_policy_num
                   AND pp.pol_header_id = ph.policy_header_id);

        vr_gt.record_status := 0;

        v_data_element := JSON();
        v_data_element.put('policy_id', vr_gt.policy_b2b_id);
        v_data_element.put('product_brief', vr_gt.policy_product_brief);
        v_data_element.put('error_text', '');
        par_response.append(v_data_element.to_json_value);

      EXCEPTION
        WHEN no_data_found THEN
          SAVEPOINT before_policy_insert;
          BEGIN
            -- Находим валюту
            IF par_policy_values.fund_brief != vr_gt.policy_fund
            THEN
              BEGIN
                SELECT fd.fund_id INTO v_fund_id FROM fund fd WHERE fd.brief = vr_gt.policy_fund;
              EXCEPTION
                WHEN no_data_found THEN
                  raise_application_error(-20001
                                         ,'Валюта с ISO-кодом "' || vr_gt.policy_fund ||
                                          '" не найдена в справочнике валют!');
              END;
            ELSE
              v_fund_id := par_policy_values.fund_id;
            END IF;

            -- Страхователь/застрахованный
            SELECT prs.* BULK COLLECT
              INTO v_persons
              FROM p_policy_gate_prs prs
             WHERE prs.p_policy_gate_id = vr_gt.p_policy_gate_id
               AND prs.person_type_brief IN ('ins', 'zl')
             ORDER BY CASE prs.person_type_brief
                        WHEN 'ins' THEN
                         0
                        WHEN 'zl' THEN
                         1
                      END;

            IF v_persons(1).person_id = v_persons(2).person_id
            THEN
              v_count_persons := 1;
            ELSE
              v_count_persons := 2;
            END IF;

            FOR v_prs_idx IN 1 .. v_count_persons
            LOOP
              -- находим адрес
              BEGIN
                SELECT address
                  INTO v_address
                  FROM (SELECT ad.address
                          FROM p_policy_gate_adr ad
                         WHERE ad.p_policy_gate_prs_id = v_persons(v_prs_idx).p_policy_gate_prs_id
                         ORDER BY decode(ad.address_type, 'fact', 0, 'const', 1, 2))
                 WHERE rownum = 1;
              EXCEPTION
                WHEN no_data_found THEN
                  NULL;
              END;
              IF v_persons(v_prs_idx).person_surname = 'ООО «Страховой и финансовый консультант»'
              THEN
                v_persons(v_prs_idx).contact_id := pkg_contact.create_company(par_name => v_persons(v_prs_idx)
                                                                                          .person_surname);
              ELSE
                v_persons(v_prs_idx).contact_id := pkg_contact.create_person_contact_rlu(p_last_name       => v_persons(v_prs_idx)
                                                                                                              .person_surname
                                                                                        ,p_first_name      => v_persons(v_prs_idx)
                                                                                                              .person_name
                                                                                        ,p_middle_name     => v_persons(v_prs_idx)
                                                                                                              .person_midname
                                                                                        ,p_birth_date      => v_persons(v_prs_idx)
                                                                                                              .person_birthdate
                                                                                        ,p_gender          => v_persons(v_prs_idx)
                                                                                                              .person_gender
                                                                                        ,p_pass_ser        => v_persons(v_prs_idx)
                                                                                                              .pasport_series
                                                                                        ,p_pass_num        => v_persons(v_prs_idx)
                                                                                                              .pasport_number
                                                                                        ,p_pass_issue_date => v_persons(v_prs_idx)
                                                                                                              .pasport_when
                                                                                        ,p_pass_issued_by  => v_persons(v_prs_idx)
                                                                                                              .pasport_who
                                                                                        ,p_address         => v_address);
              END IF;

              -- Добавляем телефоны
              FOR vr_phone IN (SELECT num
                                     ,type_id
                                     ,country_id
                                 FROM (SELECT regexp_replace(substr(regexp_substr(ph.num, '(\-\d+)+$')
                                                                   ,2)
                                                            ,'\D') AS num
                                             ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.brief = CASE ph.phone_type
                                                        WHEN 'mobile' THEN
                                                         'MOBIL'
                                                        WHEN 'home' THEN
                                                         'HOME'
                                                        WHEN 'work' THEN
                                                         'WORK'
                                                      END) AS type_id
                                             ,nvl((SELECT dc.id
                                                    FROM t_country_dial_code dc
                                                  -- Получаем код страны
                                                   WHERE dc.description =
                                                         REPLACE(regexp_replace(ph.num, '(\-\d+)+$')
                                                                ,'+')
                                                     AND rownum = 1)
                                                 ,(SELECT dc.id
                                                    FROM t_country_dial_code dc
                                                   WHERE dc.is_default = 1)) AS country_id
                                         FROM p_policy_gate_phn ph
                                        WHERE ph.p_policy_gate_prs_id = v_persons(v_prs_idx)
                                             .p_policy_gate_prs_id
                                          AND NOT EXISTS
                                        (SELECT NULL
                                                 FROM cn_contact_telephone ct
                                                WHERE ct.contact_id = v_persons(v_prs_idx).contact_id
                                                  AND ct.telephone_number =
                                                      regexp_replace(substr(regexp_substr(ph.num
                                                                                         ,'(\-\d+)+$')
                                                                           ,2)
                                                                    ,'\D')))
                                WHERE type_id IS NOT NULL
                                  AND num IS NOT NULL)
              LOOP
                v_cn_contact_telephone_id := pkg_contact.insert_phone(par_contact_id       => v_persons(v_prs_idx)
                                                                                              .contact_id
                                                                     ,par_telephone_type   => vr_phone.type_id
                                                                     ,par_telephone_number => vr_phone.num
                                                                     ,par_country_id       => vr_phone.country_id);
              END LOOP;

              -- Добавляем электронную почту
              IF v_persons(v_prs_idx).email IS NOT NULL
              THEN
                SELECT COUNT(1)
                  INTO v_is_email_exists
                  FROM dual
                 WHERE EXISTS (SELECT NULL
                          FROM cn_contact_email ce
                         WHERE ce.contact_id = v_persons(v_prs_idx).contact_id
                           AND ce.email = v_persons(v_prs_idx).email);
                IF v_is_email_exists = 0
                THEN
                  v_email_id := pkg_contact.insert_email(par_contact_id => v_persons(v_prs_idx)
                                                                           .contact_id
                                                        ,par_email      => v_persons(v_prs_idx).email
                                                        ,par_email_type => 363 /*Адрес рассылки*/);
                END IF;
              END IF;

              UPDATE contact co
                 SET co.note              = nvl(co.note
                                               ,'Загружен из B2B. Person_id: ' ||
                                                to_char(v_persons(v_prs_idx).person_id))
                    ,co.is_public_contact = v_persons(v_prs_idx).is_foreign
               WHERE co.contact_id = v_persons(v_prs_idx).contact_id;
            END LOOP;

            -- Чтобы потом сохранить тот же CONTACT_ID застрахованному
            IF v_count_persons = 1
            THEN
              v_persons(2).contact_id := v_persons(1).contact_id;
            END IF;

            BEGIN
              SELECT nvl(cn.ag_sales_chn_id, ch.t_sales_channel_id) -- для старого модуля сделан nvl
                    ,cn.agency_id
                    ,ot.province_id
                    ,ch.ag_contract_header_id
                INTO v_sales_channel_id
                    ,v_agency_id
                    ,v_region_id
                    ,v_ag_contract_header_id
                FROM ven_ag_contract_header ch
                    ,ag_contract            cn
                    ,department             dp
                    ,organisation_tree      ot
               WHERE ch.last_ver_id = cn.ag_contract_id
                 AND ch.num = vr_gt.policy_ag_contract_num
                 AND cn.agency_id = dp.department_id
                 AND dp.org_tree_id = ot.organisation_tree_id;
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20001
                                       ,'Не найдены канал продаж, агентство, регион у агента');
              WHEN too_many_rows THEN
                raise_application_error(-20001
                                       ,'Найдено несколько каналов, агентств, регионов у агента');
            END;

            v_period_id := par_policy_values.period_id;

            IF vr_gt.policy_period IS NULL
            THEN
              BEGIN
                SELECT CASE pt.brief
                         WHEN 'D' THEN
                          vr_gt.policy_sign_date + pd.period_value
                         WHEN 'M' THEN
                          ADD_MONTHS(vr_gt.policy_sign_date, pd.period_value)
                         WHEN 'Y' THEN
                          ADD_MONTHS(vr_gt.policy_sign_date, pd.period_value * 12)
                         WHEN 'Q' THEN
                          ADD_MONTHS(vr_gt.policy_sign_date, pd.period_value * 3)
                         ELSE
                          vr_gt.policy_sign_date + 1
                       END - INTERVAL '1' SECOND
                  INTO v_end_date
                  FROM t_period      pd
                      ,t_period_type pt
                 WHERE pd.id = v_period_id
                   AND pd.period_type_id = pt.id;

              EXCEPTION
                WHEN no_data_found THEN
                  raise_application_error(-20001
                                         ,'Не удалось получить дату окончания договора!');
              END;
            ELSE
              BEGIN
                SELECT pp.period_id
                      ,ADD_MONTHS(vr_gt.policy_sign_date, pd.period_value * 12) - INTERVAL '1' SECOND
                  INTO v_period_id
                      ,v_end_date
                  FROM t_product_period pp
                      ,t_period         pd
                      ,t_period_type    pt
                 WHERE pp.product_id = par_policy_values.product_id
                   AND pp.t_period_use_type_id = 1 /*Срок страхования*/
                   AND pp.period_id = pd.id
                   AND pd.period_type_id = pt.id
                   AND pd.period_value = vr_gt.policy_period
                   AND pt.brief = 'Y';

              EXCEPTION
                WHEN no_data_found THEN
                  BEGIN
                    -- Не очень круто, что сразу считаем, что передаются месяцы. Надо это обощить.
                    SELECT per.id
                          ,ADD_MONTHS(vr_gt.policy_sign_date, ROUND(vr_gt.policy_period * 12)) -
                           INTERVAL '1' SECOND
                      INTO v_period_id
                          ,v_end_date
                      FROM t_product_period  pp
                          ,t_period          per
                          ,t_period_type     pt
                          ,t_period_use_type put
                     WHERE pp.product_id = par_policy_values.product_id
                       AND pp.period_id = per.id
                       AND per.period_type_id = pt.id
                       AND pt.brief = 'O'
                       AND pp.t_period_use_type_id = put.t_period_use_type_id
                       AND put.brief = 'Срок страхования';

                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20001
                                             ,'Не найден срок страхования для "' ||
                                              to_number(vr_gt.policy_period) || '" лет');
                  END;

              END;
            END IF;

            v_fee_payment_term := CASE par_policy_values.is_periodical
                                    WHEN 0 THEN
                                     1
                                    ELSE
                                     CEIL(MONTHS_BETWEEN(v_end_date, vr_gt.policy_sign_date) / 12)
                                  END;

            IF vr_gt.policy_product_brief IN
               ('INVESTOR_LUMP_CALL_CENTRE', 'INVESTOR_LUMP_ALPHA', 'Platinum_LA2_CityService')
               OR vr_gt.policy_product_brief LIKE 'CR10%'
            THEN
              v_confirm_date := vr_gt.policy_sign_date;
            ELSE
              v_confirm_date := vr_gt.policy_reg_date;
            END IF;

            -- Добавление ДС
            vr_gt.p_pol_header_id := pkg_policy.create_policy_base(p_product_id           => par_policy_values.product_id
                                                                  ,p_sales_channel_id     => v_sales_channel_id
                                                                  ,p_agency_id            => v_agency_id
                                                                  ,p_fund_id              => v_fund_id
                                                                  ,p_fund_pay_id          => par_policy_values.fund_pay_id
                                                                  ,p_confirm_condition_id => par_policy_values.confirm_condition_id
                                                                  ,p_pol_ser              => NULL
                                                                  ,p_pol_num              => vr_gt.policy_b2b_policy_num
                                                                  ,p_notice_date          => vr_gt.policy_reg_date
                                                                  ,p_sign_date            => vr_gt.policy_reg_date
                                                                  ,p_confirm_date         => v_confirm_date
                                                                  ,p_start_date           => vr_gt.policy_sign_date
                                                                  ,p_end_date             => v_end_date
                                                                  ,p_first_pay_date       => vr_gt.policy_sign_date
                                                                  ,p_payment_term_id      => par_policy_values.payment_term_id
                                                                  ,p_period_id            => v_period_id
                                                                  ,p_issuer_id            => v_persons(1)
                                                                                             .contact_id -- Всегда страхователь
                                                                  ,p_fee_payment_term     => v_fee_payment_term
                                                                  ,p_fact_j               => NULL
                                                                  ,p_admin_cost           => 300
                                                                  ,p_is_group_flag        => 0
                                                                  ,p_notice_num           => vr_gt.policy_b2b_policy_num
                                                                  ,p_waiting_period_id    => par_policy_values.waiting_period_id
                                                                  ,p_region_id            => v_region_id
                                                                  ,p_discount_f_id        => par_policy_values.discount_f_id
                                                                  ,p_description          => 'Загружено из B2B. Policy_id: ' ||
                                                                                             to_char(vr_gt.policy_b2b_id)
                                                                  ,p_paymentoff_term_id   => par_policy_values.paymentoff_term_id
                                                                  ,p_ph_description       => 'Загружено из B2B. Policy_id: ' ||
                                                                                             to_char(vr_gt.policy_b2b_id)
                                                                  ,p_privilege_period     => par_policy_values.privilege_period_id
                                                                  ,p_base_sum             => vr_gt.base_sum
                                                                  ,p_is_credit            => vr_gt.is_credit);

            /* Получение ID версии */
            SELECT policy_id
              INTO v_policy_id
              FROM p_pol_header
             WHERE policy_header_id = vr_gt.p_pol_header_id;

            /* Добавляем агента по договору */
            pkg_renlife_utils.add_policy_agent_doc(par_policy_header_id      => vr_gt.p_pol_header_id
                                                  ,par_ag_contract_header_id => v_ag_contract_header_id);

            /* Установка даты окончания выжидательного периода */
            DECLARE
              v_waiting_period_end_date p_policy.waiting_period_end_date%TYPE;
              v_val                     ven_t_period.period_value%TYPE;
              v_name                    t_period_type.description%TYPE;
            BEGIN
              SELECT p.period_value
                    ,pt.description
                INTO v_val
                    ,v_name
                FROM t_period      p
                    ,t_period_type pt
               WHERE p.period_type_id = pt.id
                 AND p.id = par_policy_values.waiting_period_id;

              IF v_val IS NOT NULL
              THEN
                CASE v_name
                  WHEN 'Дни' THEN
                    v_waiting_period_end_date := vr_gt.policy_sign_date + v_val - 1;
                  WHEN 'Месяцы' THEN
                    v_waiting_period_end_date := ADD_MONTHS(vr_gt.policy_sign_date, v_val) - 1;
                  WHEN 'Годы' THEN
                    IF to_char(trunc(vr_gt.policy_sign_date), 'ddmm') = '2902'
                    THEN
                      v_waiting_period_end_date := ADD_MONTHS(vr_gt.policy_sign_date + 1, v_val * 12) - 1;
                    ELSE
                      v_waiting_period_end_date := ADD_MONTHS(vr_gt.policy_sign_date, v_val * 12) - 1;
                    END IF;
                  ELSE
                    NULL;
                END CASE;
              ELSE
                v_waiting_period_end_date := NULL;
              END IF;
              UPDATE p_policy pp
                 SET pp.waiting_period_end_date = v_waiting_period_end_date
               WHERE pp.policy_id = v_policy_id;
            END;

            /* Добавление застрахованного */
            v_assured_id := pkg_asset.create_as_assured(p_pol_id        => v_policy_id
                                                       ,p_contact_id    => v_persons(v_count_persons)
                                                                           .contact_id
                                                       ,p_work_group_id => par_policy_values.work_group_id);

            UPDATE as_assured se
               SET se.t_hobby_id =
                   (SELECT th.t_hobby_id FROM t_hobby th WHERE th.description = 'нет')
             WHERE se.as_assured_id = v_assured_id;

            pkg_asset.create_insuree_info(p_pol_id        => v_policy_id
                                         ,p_work_group_id => par_policy_values.work_group_id);

            FOR vr_ben IN (SELECT bnf.*
                             FROM p_policy_gate_bnf bnf
                            WHERE bnf.p_policy_gate_id = vr_gt.p_policy_gate_id)
            LOOP
              BEGIN
                SELECT crt.relationship_dsc
                      ,CASE crt.gender_id
                         WHEN 0 THEN
                          'F'
                         ELSE
                          'M'
                       END
                  INTO vr_ben.relation
                      ,v_benef_gender_brief
                  FROM t_contact_rel_type crt
                      ,t_contact_role     cr_benif
                      ,t_contact_role     cr_asset
                      ,cn_person          cp
                 WHERE crt.source_contact_role_id = cr_asset.id
                   AND crt.target_contact_role_id = cr_benif.id
                   AND cp.contact_id = v_persons(v_count_persons).contact_id
                   AND cr_asset.brief = 'ASSURED'
                   AND cr_benif.brief = 'BENEFICIARY'
                   AND upper(crt.relationship_dsc) = TRIM(upper(vr_ben.relation))
                   AND crt.target_gender_id = cp.gender
                   AND rownum = 1;
              EXCEPTION
                WHEN no_data_found THEN
                  vr_ben.relation      := 'Другой';
                  v_benef_gender_brief := 'F';
              END;
              v_benef_contact_id := pkg_contact.create_person_contact(p_last_name   => vr_ben.surname
                                                                     ,p_first_name  => vr_ben.first_name
                                                                     ,p_middle_name => vr_ben.midname
                                                                     ,p_birth_date  => vr_ben.birthdate
                                                                     ,p_gender      => v_benef_gender_brief);
              pkg_asset.add_beneficiary(par_asset_id          => v_assured_id
                                       ,par_contact_id        => v_benef_contact_id
                                       ,par_contact_rel_brief => vr_ben.relation
                                       ,par_value             => vr_ben.part
                                       ,par_value_type_brief  => 'percent'
                                       ,par_currency_brief    => 'RUR'
                                       ,par_beneficiary_id    => v_beneficiary_id);
            END LOOP;

            /* Добавялем покрытия по застрахованному */
            FOR rec IN (SELECT id
                              ,CASE
                                 WHEN lead(id) over(ORDER BY id) IS NULL THEN
                                  1
                                 ELSE
                                  0
                               END AS is_last
                              ,brutto_sum
                              ,ins_amount
                              ,description
                              ,ins_amount_round_rules_id
                          FROM (SELECT pl.id
                                      ,prg.fee                      AS brutto_sum
                                      ,prg.ins_sum                  AS ins_amount
                                      ,pl.description
                                      ,plt.brief
                                      ,pl.ins_amount_round_rules_id
                                  FROM t_product_version   pv
                                      ,t_product_ver_lob   pvl
                                      ,t_product_line      pl
                                      ,t_product_line_type plt
                                      ,t_prod_line_option  plo
                                      ,p_policy_gate_prg   prg
                                 WHERE pv.product_id = par_policy_values.product_id
                                   AND pv.t_product_version_id = pvl.product_version_id
                                   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                   AND pl.product_line_type_id = plt.product_line_type_id
                                   AND pl.id = plo.product_line_id
                                   AND plo.brief = prg.brief
                                   AND prg.p_policy_gate_id = vr_gt.p_policy_gate_id
                                UNION
                                SELECT pla.id
                                      ,0                             AS brutto_sum
                                      ,0                             AS ins_amount
                                      ,pla.description
                                      ,plta.brief
                                      ,pla.ins_amount_round_rules_id
                                  FROM t_product_version   pva
                                      ,t_product_ver_lob   pvla
                                      ,t_product_line      pla
                                      ,t_product_line_type plta
                                 WHERE pva.product_id = par_policy_values.product_id
                                   AND pva.t_product_version_id = pvla.product_version_id
                                   AND pvla.t_product_ver_lob_id = pla.product_ver_lob_id
                                   AND pla.product_line_type_id = plta.product_line_type_id
                                   AND plta.brief = 'MANDATORY'
                                   AND pla.skip_on_policy_creation = 0
                                   AND pla.description != 'Административные издержки'
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM t_product_version   pv
                                              ,t_product_ver_lob   pvl
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                              ,p_policy_gate_prg   prg
                                         WHERE pv.product_id = par_policy_values.product_id
                                           AND pv.t_product_version_id = pvl.product_version_id
                                           AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND plo.brief = prg.brief
                                           AND prg.p_policy_gate_id = vr_gt.p_policy_gate_id
                                           AND pl.id = pla.id)
                                /* Заявка №206111
                                UNION ALL
                                SELECT pl.id
                                      ,300            AS brutto_sum
                                      ,300            AS ins_amount
                                      ,pl.description
                                      ,plt.brief
                                  FROM t_product_version   pv
                                      ,t_product_ver_lob   pvl
                                      ,t_product_line      pl
                                      ,t_product_line_type plt
                                      ,t_prod_line_option  plo
                                 WHERE pv.product_id = par_policy_values.product_id
                                   AND pv.t_product_version_id = pvl.product_version_id
                                   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                   AND pl.product_line_type_id = plt.product_line_type_id
                                   AND pl.id = plo.product_line_id
                                   AND plo.brief IN ( --'Penalty',
                                                     'Adm_Cost_Life'
                                                    ,'Adm_Cost_Acc')*/
                                )
                         ORDER BY CASE brief
                                    WHEN 'RECOMMENDED' THEN
                                     0
                                    WHEN 'MANDATORY' THEN
                                     1
                                    WHEN 'OPTIONAL' THEN
                                     2
                                    ELSE
                                     100
                                  END)
            LOOP
              --Нужны и нулевые риски
              /*IF rec.brutto_sum != 0
              THEN*/
              /*Капля
              Клудж, чтобы не создавать покрытия по программам для нерезидентов и стариков (>51 года)
              */
              IF vr_gt.policy_product_brief != 'Platinum_LA2_CityService'
                 OR rec.description = 'Дожитие с возвратом взносов в случае смерти'
                 OR rec.brutto_sum > 0 /*(nvl(v_resident_flag, 0) = 0 AND v_insured_age < 51
                                                                                                                                                                                                                                                                              AND)*/
              THEN
                DECLARE
                  v_normrate   NUMBER;
                  v_loading    NUMBER;
                  v_netto      NUMBER;
                  v_brutto     NUMBER;
                  v_cover_id   p_cover.p_cover_id%TYPE;
                  v_ins_amount NUMBER;
                  v_exception  NUMBER;
                  v_age        NUMBER;
                BEGIN
                  /* Создаем покрытие */
                  v_cover_id := pkg_cover.cre_new_cover(v_assured_id, rec.id, rec.is_last = 1);
                  /* Нагрузка */
                  v_loading := pkg_cover.calc_loading(v_cover_id);
                  /* Норма доходности */
                  v_normrate := pkg_productlifeproperty.calc_normrate_value(v_cover_id);

                  SELECT pc.accum_period_end_age
                    INTO v_age
                    FROM p_cover pc
                   WHERE pc.p_cover_id = v_cover_id;

                  IF v_age IS NOT NULL
                  THEN
                    pkg_cover.set_cover_accum_period_end_age(p_p_cover_id => v_cover_id
                                                            ,p_age        => v_age);
                  END IF;

                  IF vr_gt.policy_product_brief = 'Platinum_LA2_CityService'
                  THEN
                    IF rec.description = 'Первичное диагностирование смертельно опасного заболевания'
                    THEN
                      UPDATE p_cover pc
                         SET is_handchange_amount  = 0
                            ,is_handchange_premium = 0
                            ,is_handchange_fee     = 0
                            ,is_handchange_tariff  = 0
                            ,normrate_value        = v_normrate
                            ,rvb_value             = v_loading
                            ,ins_amount            = 8500
                            ,premia_base_type      = 0
                            ,t_deductible_type_id  = 1
                            ,t_deduct_val_type_id  = 1
                            ,deductible_value      = 0
                       WHERE pc.p_cover_id = v_cover_id;

                      pkg_cover.update_cover_sum(v_cover_id);

                      IF rec.ins_amount != 8500
                      THEN
                        UPDATE p_cover pc
                           SET is_handchange_premium   = 1
                              ,is_handchange_fee       = 1
                              ,pc.is_handchange_amount = 1
                              ,pc.ins_amount           = rec.ins_amount
                         WHERE pc.p_cover_id = v_cover_id;
                      END IF;
                    ELSE
                      UPDATE p_cover pc
                         SET is_handchange_amount  = 0
                            ,is_handchange_premium = 0
                            ,is_handchange_fee     = 1
                            ,is_handchange_tariff  = 0
                            ,normrate_value        = v_normrate
                            ,rvb_value             = v_loading
                            ,fee                   = rec.brutto_sum
                            ,k_coef                = 0
                            ,k_coef_m              = 0
                            ,k_coef_nm             = 0
                            ,s_coef                = 0
                            ,s_coef_m              = 0
                            ,s_coef_nm             = 0
                            ,premia_base_type      = 1
                            ,t_deductible_type_id  = 1
                            ,t_deduct_val_type_id  = 1
                            ,deductible_value      = 0
                       WHERE pc.p_cover_id = v_cover_id;

                      pkg_cover.update_cover_sum(p_p_cover_id => v_cover_id);

                    END IF;
                  ELSE
                    UPDATE p_cover pc
                       SET is_handchange_amount  = 0
                          ,is_handchange_premium = 1
                          ,is_handchange_fee     = 1
                          ,is_handchange_tariff  = 0
                          ,normrate_value        = v_normrate
                          ,rvb_value             = v_loading
                          ,fee                   = rec.brutto_sum
                          ,k_coef                = 0
                          ,k_coef_m              = 0
                          ,k_coef_nm             = 0
                          ,s_coef                = 0
                          ,s_coef_m              = 0
                          ,s_coef_nm             = 0
                          ,premia_base_type      = 1
                          ,t_deductible_type_id  = 1
                          ,t_deduct_val_type_id  = 1
                          ,deductible_value      = 0
                     WHERE pc.p_cover_id = v_cover_id;

                    --v_netto := round(pkg_prdlifecalc.pepr_get_netto(p_cover_id => v_cover_id),5);
                    v_netto := ROUND(pkg_cover.calc_tariff_netto(p_p_cover_id => v_cover_id), 5);
                    UPDATE p_cover pc
                       SET netto_tariff = v_netto
                          ,tariff_netto = v_netto
                          ,premium      = rec.brutto_sum
                     WHERE pc.p_cover_id = v_cover_id;
                    v_brutto := pkg_cover.calc_tariff(p_p_cover_id => v_cover_id); --round(pkg_PrdLifeCalc.pepr_get_brutto(p_cover_id => v_cover_id),5);
                    UPDATE p_cover pc
                       SET tariff     = v_brutto
                          ,ins_amount = rec.ins_amount
                     WHERE pc.p_cover_id = v_cover_id;
                  END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                    raise_application_error(-20001
                                           ,'Ошибка подключения покрытия: ' || SQLERRM);
                END;
              END IF;
              /*END IF;*/
            END LOOP;

            -- Иногда дата начала застрахованного неверная
            UPDATE as_asset se
               SET se.start_date =
                   (SELECT MIN(pc.start_date) FROM p_cover pc WHERE pc.as_asset_id = se.as_asset_id)
             WHERE se.as_asset_id = v_assured_id;

            pkg_policy.update_policy_sum(p_p_policy_id => v_policy_id);

            /* БСО */
            DECLARE
              v_cnt              NUMBER(1);
              v_bso_id           bso.bso_id%TYPE;
              v_bso_hist_id      bso_hist.bso_hist_id%TYPE;
              v_bso_series_id    bso_series.bso_series_id%TYPE;
              v_bso_chars_in_num bso_series.chars_in_num%TYPE;

            BEGIN
              -- Найти БСО по серии и номеру
              BEGIN
                SELECT bs.bso_series_id
                      ,bs.chars_in_num
                  INTO v_bso_series_id
                      ,v_bso_chars_in_num
                  FROM bso_series bs
                 WHERE bs.series_num = to_number(substr(vr_gt.policy_b2b_policy_num, 1, 3));
              EXCEPTION
                WHEN no_data_found THEN
                  raise_application_error(-20001, 'Не найдена серия БСО');
              END;
              BEGIN
                SELECT b.bso_id
                  INTO v_bso_id
                  FROM bso b
                 WHERE b.bso_series_id = v_bso_series_id
                   AND b.num = substr(vr_gt.policy_b2b_policy_num, 4, v_bso_chars_in_num);
              EXCEPTION
                WHEN OTHERS THEN
                  raise_application_error(-20001
                                         ,'Не найден БСО по серии и номеру');
              END;

              -- Выполнить проверку: можно ли привязывать данный БСО?
              -- на дату заявления notice_date БСО в статусе "Передан"
              -- и на контакте, имеющем статус "Мат. ответственный"
              -- (поверка по каналу продажи "Банковский", не DSF и не SAS)
              SELECT COUNT(*)
                INTO v_cnt
                FROM dual
               WHERE EXISTS (SELECT NULL
                        FROM contact           c
                            ,bso               b
                            ,bso_hist          h
                            ,bso_hist_type     t
                            ,bso_series        ser
                            ,bso_type          tp
                            ,organisation_tree ot
                            ,employee          e
                            ,employee_hist     he
                       WHERE c.contact_id = h.contact_id
                         AND b.bso_hist_id = h.bso_hist_id
                         AND b.bso_id = h.bso_id
                         AND t.name = 'Передан'
                         AND h.hist_type_id = t.bso_hist_type_id
                         AND b.bso_series_id = ser.bso_series_id
                         AND ser.bso_type_id = tp.bso_type_id
                         AND b.bso_series_id = v_bso_series_id
                         AND b.bso_id = v_bso_id
                         AND e.organisation_id = ot.organisation_tree_id
                         AND he.employee_id = e.employee_id
                         AND e.contact_id = c.contact_id
                         AND he.date_hist = (SELECT MAX(ehlast.date_hist)
                                               FROM employee_hist ehlast
                                              WHERE ehlast.employee_id = e.employee_id
                                                AND ehlast.date_hist <= SYSDATE
                                                AND ehlast.is_kicked = 0)
                         AND nvl(he.is_brokeage, 0) = 1);
              IF v_cnt > 0
              THEN
                -- Прикрепить БСО к договору
                UPDATE bso
                   SET policy_id     = v_policy_id
                      ,pol_header_id = vr_gt.p_pol_header_id
                      ,is_pol_num    = 1
                 WHERE bso_id = v_bso_id;
                -- Добавить строку в bso_hist
                v_bso_hist_id := pkg_renlife_utils.create_bso_history(v_bso_id, v_policy_id);
                -- В bso поменять ссылку на последнюю строку bso_hist
                UPDATE bso SET bso_hist_id = v_bso_hist_id WHERE bso_id = v_bso_id;
              ELSE
                raise_application_error(-20001
                                       ,'БСО занят либо не в статусе Передан!');
              END IF;
            END;

            -- Заявка № 172292
            -- Заявка № 296390 - Введен новый статус, для некоторых продуктов реализован иной путь прохода по статусам
            DECLARE
              v_target_status_brief doc_status_ref.brief%TYPE;
            BEGIN

              IF par_policy_values.product_brief IN
                 ('InvestorALFA', 'Invest_in_future', 'INVESTOR_LUMP_ALPHA')
              THEN
                v_target_status_brief := 'WAITING_FOR_PAYMENT';
              ELSE
                v_target_status_brief := 'PASSED_TO_AGENT';
              END IF;

              doc.set_doc_status(p_doc_id       => v_policy_id
                                ,p_status_brief => v_target_status_brief
                                ,p_note         => 'Переведен в процессе импорта');
            END;

            v_data_element := JSON();
            v_data_element.put('policy_id', vr_gt.policy_b2b_id);
            v_data_element.put('product_brief', vr_gt.policy_product_brief);
            v_data_element.put('error_text', '');
            par_response.append(v_data_element.to_json_value);
            vr_gt.error_text    := NULL;
            vr_gt.record_status := 0;
            IF NOT par_was_errors
               OR par_was_errors IS NULL
            THEN
              par_was_errors := FALSE;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK TO before_policy_insert;
              v_error := SQLERRM;
              -- Накапливаем ошибки
              v_data_element := JSON();
              v_data_element.put('policy_id', vr_gt.policy_b2b_id);
              v_data_element.put('product_brief', vr_gt.policy_product_brief);
              v_data_element.put('error_text', v_error);
              par_response.append(v_data_element.to_json_value);
              vr_gt.error_text      := v_error;
              vr_gt.record_status   := 1;
              vr_gt.p_pol_header_id := NULL;
              par_was_errors        := TRUE;
          END;
          IF vr_gt.record_status != 1
          THEN
            FOR v_prs_idx IN v_persons.first .. v_persons.last
            LOOP
              UPDATE p_policy_gate_prs prs
                 SET prs.contact_id = v_persons(v_prs_idx).contact_id
               WHERE prs.p_policy_gate_prs_id = v_persons(v_prs_idx).p_policy_gate_prs_id;
            END LOOP;
          END IF;
      END;
      UPDATE p_policy_gate gt
         SET gt.error_text      = vr_gt.error_text
            ,gt.p_pol_header_id = vr_gt.p_pol_header_id
            ,gt.record_status   = vr_gt.record_status
       WHERE gt.rowid = vr_gt.rid;
    END LOOP;
  END create_investor_policy;

  /*
     Байтин А.
     Получение ДС
  */

  PROCEDURE get_policy IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'get_policy';
    v_data_element   JSON;
    v_answer         JSON;
    v_data_array     JSON_LIST;
    vr_policy_values pkg_products.t_product_defaults;
    v_write_result   BOOLEAN;
    --v_creation_result BOOLEAN;

    vc_limit CONSTANT NUMBER := 100;

    v_product_brief VARCHAR2(4000);
    v_url           VARCHAR2(255);
    v_mode          VARCHAR2(50);
  BEGIN
    FOR vr_oper IN (SELECT db.t_b2b_props_db_id
                          ,pv.props_value
                      FROM t_b2b_props_vals pv
                          ,t_b2b_props_oper op
                          ,t_b2b_props_db   db
                     WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
                       AND db.db_brief = sys.database_name
                       AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
                       AND op.oper_brief = 'get_policy_investor_operations'
                    --AND pv.props_value != 'get_policy_rusavto_autocredit'
                    --AND pv.props_value != 'get_policy_autocredit_rolf'
                    --and pv.props_value = 'get_policy_platinum_la2'
                    --and pv.props_value = 'get_policy_callcenter'
                    --and pv.props_value = 'get_policy_partner'
                    --and pv.props_value = 'get_policy_openbank'
                    )
    LOOP
      BEGIN
        BEGIN
          SELECT pv.props_value
            INTO v_url
            FROM t_b2b_props_vals pv
                ,t_b2b_props_oper op
                ,t_b2b_props_type ty
           WHERE pv.t_b2b_props_db_id = vr_oper.t_b2b_props_db_id
             AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
             AND op.oper_brief = vr_oper.props_value
             AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
             AND ty.type_brief = 'URL';
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'В настройках не указан URL для операции "' ||
                                    vr_oper.props_value || '"');
          WHEN too_many_rows THEN
            raise_application_error(-20001
                                   ,'В настройках указано несколько URL для операции "' ||
                                    vr_oper.props_value || '"');
        END;

        BEGIN
          SELECT pv.props_value
            INTO v_mode
            FROM t_b2b_props_vals pv
                ,t_b2b_props_oper op
                ,t_b2b_props_type ty
           WHERE pv.t_b2b_props_db_id = vr_oper.t_b2b_props_db_id
             AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
             AND op.oper_brief = vr_oper.props_value
             AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
             AND ty.type_brief = 'mode';
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'В настройках не указано название операции на стороне B2B для операции "' ||
                                    vr_oper.props_value || '"');
          WHEN too_many_rows THEN
            raise_application_error(-20001
                                   ,'В настройках указано несколько названий операций на стороне B2B для операции "' ||
                                    vr_oper.props_value || '"');
        END;

        --vr_policy_values := pkg_products.get_product_defaults(v_product_brief);
        LOOP
          v_data_element := JSON();
          v_data_element.put('count_limit', vc_limit);
          v_data_array := JSON_LIST();
          v_data_array.append(v_data_element.to_json_value);
          v_answer := json_lob_conversation(v_mode, v_data_array, v_url, vc_proc_name);
          --  v_answer.print;
          --  return;
          -- Разбор результата
          IF v_answer.get('error_text').get_string IS NOT NULL
          THEN
            -- Если общая ошибка делаем exception с текстом ошибки
            raise_application_error(-20001, v_answer.get('error_text').get_string);
          ELSE
            IF v_answer.exist('data')
            THEN
              v_data_array := JSON_LIST(v_answer.get('data'));
              -- Если количество элементов больше 0, обрабатываем результат
              IF v_data_array.count > 0
              THEN
                DECLARE
                  v_response        JSON_LIST := JSON_LIST();
                  v_creation_result BOOLEAN := FALSE;
                BEGIN
                  write_policy_gate_table(v_data_array, v_write_result);
                  -- Коммитим шлюз
                  COMMIT;
                  FOR prod_rec IN (SELECT pv.props_value product_brief
                                     FROM t_b2b_props_vals pv
                                         ,t_b2b_props_oper op
                                         ,t_b2b_props_type ty
                                    WHERE pv.t_b2b_props_db_id = vr_oper.t_b2b_props_db_id
                                      AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
                                      AND op.oper_brief = vr_oper.props_value
                                      AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
                                      AND ty.type_brief = 'product')
                  LOOP
                    vr_policy_values := pkg_products.get_product_defaults(prod_rec.product_brief);
                    create_investor_policy(vr_policy_values, v_response, v_creation_result);
                  END LOOP;
                  v_answer := json_lob_conversation(v_mode || '_commit'
                                                   ,v_response
                                                   ,v_url
                                                   ,vc_proc_name);
                  -- Если при создании договоров были ошибки, выходим, т.к. B2B начнет посылать их заново
                  IF v_creation_result
                     OR v_write_result
                  THEN
                    SELECT wm_concat(pv.props_value)
                      INTO v_product_brief
                      FROM t_b2b_props_vals pv
                          ,t_b2b_props_oper op
                          ,t_b2b_props_type ty
                     WHERE pv.t_b2b_props_db_id = vr_oper.t_b2b_props_db_id
                       AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
                       AND op.oper_brief = vr_oper.props_value
                       AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
                       AND ty.type_brief = 'product';

                    pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                                       ,par_subject => 'Ошибка получения инвесторов из B2B'
                                                       ,par_text    => 'Не создался договор по продукту: ' ||
                                                                       v_product_brief || chr(10) ||
                                                                       ' БД: ' || sys.database_name);
                    COMMIT;
                    EXIT;
                  END IF;
                  -- Коммитим каждую пачку
                  COMMIT;
                END;
              ELSE
                -- Если в data пусто, выходим из цикла
                EXIT;
              END IF;
            ELSE
              -- Если data отсутствует, выходим из цикла
              EXIT;
            END IF;
          END IF;
        END LOOP;
        -- Каждую операцию делаем commit;
        -- COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'URL(' || nvl(v_url, 'NULL') || ')' ||
                                  dbms_utility.format_error_stack);
      END;
    END LOOP;
  END get_policy;

  /*
    Байтин А.

    Расчет выкупных сумм и передача их в B2B
  */
  PROCEDURE get_cash_surrender
  (
    par_birth_date      DATE
   ,par_gender          VARCHAR2
   ,par_product         VARCHAR2
   ,par_fund            VARCHAR2
   ,par_period          NUMBER
   ,par_prog_sums       t_prog_sums
   ,par_base_sum        NUMBER
   ,par_is_credit       BOOLEAN
   ,par_ag_contract_num VARCHAR2
  ) IS
    v_proc_name CONSTANT VARCHAR2(255) := 'get_cash_surrender';
    v_pol_header_id         p_pol_header.policy_header_id%TYPE;
    v_policy_id             p_policy.policy_id%TYPE;
    v_product_id            p_pol_header.product_id%TYPE;
    v_sales_channel_id      p_pol_header.sales_channel_id%TYPE;
    v_agency_id             p_pol_header.agency_id%TYPE;
    v_fund_id               p_pol_header.fund_id%TYPE;
    v_fund_brief            fund.brief%TYPE;
    v_fund_pay_id           p_pol_header.fund_pay_id%TYPE;
    v_confirm_condition_id  p_pol_header.confirm_condition_id%TYPE;
    v_pol_ser               p_policy.pol_ser%TYPE;
    v_pol_num               p_policy.pol_num%TYPE;
    v_notice_num            p_policy.notice_num%TYPE;
    v_notice_date           p_policy.notice_date%TYPE;
    v_sign_date             p_policy.sign_date%TYPE;
    v_confirm_date          p_policy.confirm_date%TYPE;
    v_start_date            p_pol_header.start_date%TYPE;
    v_end_date              p_policy.end_date%TYPE;
    v_first_pay_date        p_policy.first_pay_date%TYPE;
    v_payment_term_id       p_policy.payment_term_id%TYPE;
    v_period_id             p_policy.period_id%TYPE;
    v_issuer_id             p_policy_contact.contact_id%TYPE;
    v_fee_payment_term      p_policy.fee_payment_term%TYPE;
    v_fact_j                p_policy.fact_j%TYPE;
    v_admin_cost            p_policy.admin_cost%TYPE;
    v_is_group_flag         p_policy.is_group_flag%TYPE;
    v_waiting_period_id     p_policy.waiting_period_id%TYPE;
    v_region_id             p_policy.region_id%TYPE;
    v_discount_f_id         p_policy.discount_f_id%TYPE;
    v_description           p_policy.description%TYPE;
    v_paymentoff_term_id    p_policy.paymentoff_term_id%TYPE;
    v_ph_description        p_pol_header.description%TYPE;
    v_privilege_period_id   p_policy.pol_privilege_period_id%TYPE;
    v_assured_id            as_assured.as_assured_id%TYPE;
    v_work_group_id         as_assured.work_group_id%TYPE;
    v_brutto_sum            p_cover.fee%TYPE;
    v_create_cover          BOOLEAN;
    v_ins_amount            NUMBER;
    v_today                 DATE;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_new_ins_amount        NUMBER;
    v_is_credit             NUMBER(1);

    /* Установка значений */
    PROCEDURE set_values
    (
      par_product              VARCHAR2
     ,par_birth_date           DATE
     ,par_gender               VARCHAR2
     ,par_product_id           OUT NUMBER
     ,par_sales_channel_id     OUT NUMBER
     ,par_agency_id            OUT NUMBER
     ,par_fund_id              OUT NUMBER
     ,par_fund_brief           OUT VARCHAR2
     ,par_fund_pay_id          OUT NUMBER
     ,par_confirm_condition_id OUT NUMBER
     ,par_pol_ser              OUT VARCHAR2
     ,par_pol_num              OUT VARCHAR2
     ,par_notice_date          OUT DATE
     ,par_sign_date            OUT DATE
     ,par_confirm_date         OUT DATE
     ,par_start_date           OUT DATE
     ,par_end_date             OUT DATE
     ,par_payment_term_id      OUT NUMBER
     ,par_period_id            OUT NUMBER
     ,par_issuer_id            OUT NUMBER
     ,par_fee_payment_term     OUT NUMBER
     ,par_first_pay_date       OUT DATE
     ,par_fact_j               OUT NUMBER
     ,par_admin_cost           OUT NUMBER
     ,par_is_group_flag        OUT NUMBER
     ,par_notice_num           OUT VARCHAR2
     ,par_waiting_period_id    OUT NUMBER
     ,par_region_id            OUT NUMBER
     ,par_discount_f_id        OUT NUMBER
     ,par_paymentoff_term_id   OUT NUMBER
     ,par_description          OUT VARCHAR2
     ,par_ph_description       OUT VARCHAR2
     ,par_privilege_period_id  OUT NUMBER
     ,par_work_group_id        OUT NUMBER
     ,par_today                OUT DATE
    ) IS
    BEGIN
      par_today := trunc(SYSDATE, 'dd') + CASE par_product
                     WHEN 'Invest_in_future' THEN
                      1
                     ELSE
                      0
                   END;
      BEGIN
        SELECT product_id INTO par_product_id FROM t_product WHERE brief = par_product;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найден продукт с кратким наименованием: "' || par_product || '"!');
      END;

      BEGIN
        SELECT pc.currency_id
              ,fd.brief
              ,pc.currency_id
          INTO par_fund_id
              ,par_fund_brief
              ,par_fund_pay_id
          FROM t_prod_currency pc
              ,fund            fd
         WHERE pc.product_id = par_product_id
           AND pc.currency_id = fd.fund_id
           AND pc.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена валюта ответственности по умолчанию!');
      END;

      BEGIN
        SELECT ch.sales_channel_id
          INTO par_sales_channel_id
          FROM t_prod_sales_chan ch
         WHERE ch.product_id = par_product_id
           AND ch.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указан канал продаж по умолчанию!');
      END;

      SELECT co.contact_id
        INTO par_issuer_id
        FROM contact co
       WHERE co.contact_id = 214247 --co.obj_name_orig = 'Test Test Test'
         AND rownum = 1;

      UPDATE cn_person cp
         SET cp.date_of_birth = par_birth_date
            ,cp.gender       =
             (SELECT id
                FROM t_gender
               WHERE brief = CASE par_gender
                       WHEN 'm' THEN
                        'MALE'
                       ELSE
                        'FEMALE'
                     END)
       WHERE cp.contact_id = par_issuer_id;

      BEGIN
        SELECT cc.confirm_condition_id
          INTO par_confirm_condition_id
          FROM t_product_conf_cond cc
         WHERE cc.product_id = par_product_id
           AND cc.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указано условие вступления в силу по умолчанию!');
      END;

      BEGIN
        SELECT pt.payment_term_id
          INTO par_payment_term_id
          FROM t_prod_payment_terms pt
         WHERE pt.product_id = par_product_id
           AND pt.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указана периодичность платежей по умолчанию!');
      END;

      SELECT dp.department_id
            ,ot.province_id
        INTO par_agency_id
            ,par_region_id
        FROM department        dp
            ,organisation_tree ot
       WHERE dp.code = 'Внеш'
         AND dp.org_tree_id = ot.organisation_tree_id;

      BEGIN
        SELECT pp.period_id
              ,CASE pt.brief
                 WHEN 'D' THEN
                  par_today + pd.period_value
                 WHEN 'M' THEN
                  ADD_MONTHS(par_today, pd.period_value)
                 WHEN 'Y' THEN
                  ADD_MONTHS(par_today, pd.period_value * 12)
                 WHEN 'Q' THEN
                  ADD_MONTHS(par_today, pd.period_value * 3)
                 ELSE
                  par_today + 1
               END - INTERVAL '1' SECOND
              ,pd.period_value
          INTO par_period_id
              ,par_end_date
              ,par_fee_payment_term
          FROM t_product_period pp
              ,t_period         pd
              ,t_period_type    pt
         WHERE pp.product_id = par_product_id
           AND pp.t_period_use_type_id = 1 /*Срок страхования*/
           AND pp.is_default = 1
           AND pp.period_id = pd.id
           AND pd.period_type_id = pt.id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указан срок страхования по умолчанию!');
      END;

      BEGIN
        SELECT pp.period_id
          INTO par_waiting_period_id
          FROM t_product_period pp
         WHERE pp.product_id = par_product_id
           AND pp.t_period_use_type_id = 2 /*Выжидательный*/
           AND pp.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указан выжидательный период по умолчанию!');
      END;

      BEGIN
        SELECT pp.period_id
          INTO par_privilege_period_id
          FROM t_product_period pp
         WHERE pp.product_id = par_product_id
           AND pp.t_period_use_type_id = 3 /*Льготный*/
           AND pp.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указан льготный период по умолчанию!');
      END;

      SELECT discount_f_id INTO par_discount_f_id FROM discount_f WHERE brief = 'База';

      BEGIN
        SELECT cp.payment_terms_id
          INTO par_paymentoff_term_id
          FROM t_prod_claim_payterm cp
         WHERE cp.product_id = par_product_id
           AND (cp.is_default = 1 OR NOT EXISTS
                (SELECT NULL
                   FROM t_prod_claim_payterm cp1
                  WHERE cp1.product_id = cp.product_id
                    AND cp1.t_prod_claim_payterm_id != cp.t_prod_claim_payterm_id));
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'В настройках продукта не указана периодичность выплат по умолчанию!');
      END;

      SELECT t_work_group_id
        INTO par_work_group_id
        FROM t_work_group
       WHERE description = '1 группа';

      par_pol_num     := '000000';
      par_pol_ser     := '147';
      par_notice_date := par_today;
      par_sign_date   := par_today;
      IF par_product IN ('INVESTOR_LUMP_CALL_CENTRE', 'INVESTOR_LUMP_ALPHA')
      THEN
        par_confirm_date   := par_today + 1;
        par_start_date     := par_today + 1;
        par_first_pay_date := par_today + 1;
      ELSE
        par_confirm_date   := par_today;
        par_start_date     := par_today;
        par_first_pay_date := par_today;
      END IF;
      par_fact_j         := NULL;
      par_admin_cost     := 300;
      par_is_group_flag  := 0;
      par_notice_num     := '000000';
      par_description    := 'Создано в процессе автоматического расчета. Должно быть удалено!';
      par_ph_description := 'Создано в процессе автоматического расчета. Должно быть удалено!';

    END set_values;

  BEGIN
    safety.set_curr_role(p_role_name => 'Администратор');

    set_values(par_product              => par_product
              ,par_birth_date           => par_birth_date
              ,par_gender               => par_gender
              ,par_product_id           => v_product_id
              ,par_sales_channel_id     => v_sales_channel_id
              ,par_agency_id            => v_agency_id
              ,par_fund_id              => v_fund_id
              ,par_fund_brief           => v_fund_brief
              ,par_fund_pay_id          => v_fund_pay_id
              ,par_confirm_condition_id => v_confirm_condition_id
              ,par_pol_ser              => v_pol_ser
              ,par_pol_num              => v_pol_num
              ,par_notice_date          => v_notice_date
              ,par_sign_date            => v_sign_date
              ,par_confirm_date         => v_confirm_date
              ,par_start_date           => v_start_date
              ,par_end_date             => v_end_date
              ,par_payment_term_id      => v_payment_term_id
              ,par_period_id            => v_period_id
              ,par_issuer_id            => v_issuer_id
              ,par_fee_payment_term     => v_fee_payment_term
              ,par_first_pay_date       => v_first_pay_date
              ,par_fact_j               => v_fact_j
              ,par_admin_cost           => v_admin_cost
              ,par_is_group_flag        => v_is_group_flag
              ,par_notice_num           => v_notice_num
              ,par_waiting_period_id    => v_waiting_period_id
              ,par_region_id            => v_region_id
              ,par_discount_f_id        => v_discount_f_id
              ,par_paymentoff_term_id   => v_paymentoff_term_id
              ,par_description          => v_description
              ,par_ph_description       => v_ph_description
              ,par_privilege_period_id  => v_privilege_period_id
              ,par_work_group_id        => v_work_group_id
              ,par_today                => v_today);

    IF par_product = 'Invest_in_future'
    THEN
      -- Проверка возраста
      IF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) < 18
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного менее 18-ти лет, договор не может быть заключен!');
      ELSIF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) > 65
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного на момент начала договора более 65-ти лет, договор не может быть заключен!');
      END IF;
    ELSIF par_product = 'InvestorALFA'
    THEN
      -- Байтин А. Заявка 169796
      IF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) < 18
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного менее 18-ти лет, договор не может быть заключен!');
      ELSIF trunc(MONTHS_BETWEEN(v_end_date, par_birth_date) / 12) > 65
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного на момент окончания более 65-ти лет, договор не может быть заключен!');
      END IF;
    ELSIF par_product = 'OPS_PLUS_3'
    THEN
      IF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) < 18
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного менее 18-ти лет, договор не может быть заключен!');
      ELSIF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) > 60
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного на момент начала договора более 60-ти лет, договор не может быть заключен!');
      END IF;
    ELSIF par_product = 'INVESTOR_LUMP_ALPHA'
    THEN
      IF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) < 18
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного менее 18-ти лет, договор не может быть заключен!');
      ELSIF trunc(MONTHS_BETWEEN(v_start_date, par_birth_date) / 12) > 80
      THEN
        raise_application_error(-20001
                               ,'Возраст застрахованного на момент окончания более 80-ти лет, договор не может быть заключен!');
      END IF;
    END IF;

    -- Находим валюту
    IF par_fund != v_fund_brief
    THEN
      BEGIN
        SELECT fd.fund_id INTO v_fund_id FROM fund fd WHERE fd.brief = par_fund;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Валюта с ISO-кодом "' || par_fund ||
                                  '" не найдена в справочнике валют!');
      END;
    END IF;
    -- Находим период
    IF par_period != v_fee_payment_term
       OR v_fee_payment_term IS NULL
    THEN
      BEGIN
        SELECT pp.period_id
              ,ADD_MONTHS(v_today, pd.period_value * 12) - INTERVAL '1' SECOND
              ,pd.period_value
          INTO v_period_id
              ,v_end_date
              ,v_fee_payment_term
          FROM t_product_period pp
              ,t_period         pd
              ,t_period_type    pt
         WHERE pp.product_id = v_product_id
           AND pp.t_period_use_type_id = 1 /*Срок страхования*/
           AND pp.period_id = pd.id
           AND pd.period_type_id = pt.id
           AND pd.period_value = par_period
           AND pt.brief = 'Y';
      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            SELECT per.id
                  ,ADD_MONTHS(v_today, ROUND(par_period * 12)) - INTERVAL '1' SECOND
              INTO v_period_id
                  ,v_end_date
              FROM t_product_period  pp
                  ,t_period          per
                  ,t_period_type     pt
                  ,t_period_use_type put
             WHERE pp.product_id = v_product_id
               AND pp.period_id = per.id
               AND per.period_type_id = pt.id
               AND pt.brief = 'O'
               AND pp.t_period_use_type_id = put.t_period_use_type_id
               AND put.brief = 'Срок страхования';

            v_fee_payment_term := CEIL(MONTHS_BETWEEN(v_end_date, v_today) / 12);
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'Не найден срок страхования для "' || to_number(par_period) ||
                                      '" лет');
          END;
      END;
    END IF;

    IF par_is_credit
    THEN
      v_is_credit := 1;
    END IF;

    /* Добавление ДС */
    v_pol_header_id := pkg_policy.create_policy_base(p_product_id           => v_product_id
                                                    ,p_sales_channel_id     => v_sales_channel_id
                                                    ,p_agency_id            => v_agency_id
                                                    ,p_fund_id              => v_fund_id
                                                    ,p_fund_pay_id          => v_fund_pay_id
                                                    ,p_confirm_condition_id => v_confirm_condition_id
                                                    ,p_pol_ser              => v_pol_ser
                                                    ,p_pol_num              => v_pol_num
                                                    ,p_notice_date          => v_notice_date
                                                    ,p_sign_date            => v_sign_date
                                                    ,p_confirm_date         => v_confirm_date
                                                    ,p_start_date           => v_start_date
                                                    ,p_end_date             => v_end_date
                                                    ,p_first_pay_date       => v_first_pay_date
                                                    ,p_payment_term_id      => v_payment_term_id
                                                    ,p_period_id            => v_period_id
                                                    ,p_issuer_id            => v_issuer_id
                                                    ,p_fee_payment_term     => v_fee_payment_term
                                                    ,p_fact_j               => v_fact_j
                                                    ,p_admin_cost           => v_admin_cost
                                                    ,p_is_group_flag        => v_is_group_flag
                                                    ,p_notice_num           => v_notice_num
                                                    ,p_waiting_period_id    => v_waiting_period_id
                                                    ,p_region_id            => v_region_id
                                                    ,p_discount_f_id        => v_discount_f_id
                                                    ,p_description          => v_description
                                                    ,p_paymentoff_term_id   => v_paymentoff_term_id
                                                    ,p_ph_description       => v_ph_description
                                                    ,p_privilege_period     => v_privilege_period_id
                                                    ,p_base_sum             => par_base_sum
                                                    ,p_is_credit            => v_is_credit);
    /* Получение ID версии */
    BEGIN
      SELECT ph.policy_id
        INTO v_policy_id
        FROM p_pol_header ph
       WHERE ph.policy_header_id = v_pol_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось получить ID версии договора страхования!');
    END;

    /* Добавляем агента по договору */
    BEGIN
      SELECT ac.ag_contract_header_id
        INTO v_ag_contract_header_id
        FROM ven_ag_contract_header ac
       WHERE ac.num = par_ag_contract_num;

      pkg_renlife_utils.add_policy_agent_doc(par_policy_header_id      => v_pol_header_id
                                            ,par_ag_contract_header_id => v_ag_contract_header_id);

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    /* Установка даты окончания выжидательного периода */
    DECLARE
      v_waiting_period_end_date p_policy.waiting_period_end_date%TYPE;
      v_val                     ven_t_period.period_value%TYPE;
      v_name                    t_period_type.description%TYPE;
    BEGIN
      SELECT p.period_value
            ,pt.description
        INTO v_val
            ,v_name
        FROM t_period      p
            ,t_period_type pt
       WHERE p.period_type_id = pt.id
         AND p.id = v_waiting_period_id;

      IF v_val IS NOT NULL
      THEN
        CASE v_name
          WHEN 'Дни' THEN
            v_waiting_period_end_date := v_start_date + v_val - 1;
          WHEN 'Месяцы' THEN
            v_waiting_period_end_date := ADD_MONTHS(v_start_date, v_val) - 1;
          WHEN 'Годы' THEN
            IF to_char(trunc(v_start_date), 'ddmm') = '2902'
            THEN
              v_waiting_period_end_date := ADD_MONTHS(v_start_date + 1, v_val * 12) - 1;
            ELSE
              v_waiting_period_end_date := ADD_MONTHS(v_start_date, v_val * 12) - 1;
            END IF;
          ELSE
            NULL;
        END CASE;
      ELSE
        v_waiting_period_end_date := NULL;
      END IF;
      UPDATE p_policy pp
         SET pp.waiting_period_end_date = v_waiting_period_end_date
       WHERE pp.policy_id = v_policy_id;
    END;

    /* Добавление застрахованного */
    v_assured_id := pkg_asset.create_as_assured(p_pol_id        => v_policy_id
                                               ,p_contact_id    => v_issuer_id
                                               ,p_work_group_id => v_work_group_id);

    UPDATE as_assured se
       SET se.t_hobby_id =
           (SELECT th.t_hobby_id FROM t_hobby th WHERE th.description = 'нет')
     WHERE se.as_assured_id = v_assured_id;

    pkg_asset.create_insuree_info(p_pol_id => v_policy_id, p_work_group_id => v_work_group_id);

    /* Добавялем покрытия по застрахованному */
    FOR rec IN (SELECT pl.id
                      ,CASE
                         WHEN lead(pl.id) over(ORDER BY pl.id) IS NULL THEN
                          1
                         ELSE
                          0
                       END AS is_last
                      ,plo.brief
                      ,pl.description
                      ,pl.ins_amount_round_rules_id
                  FROM t_product_version   pv
                      ,t_product_ver_lob   pvl
                      ,t_product_line      pl
                      ,t_prod_line_option  plo
                      ,t_product_line_type plt
                 WHERE pv.product_id = v_product_id
                   AND pv.t_product_version_id = pvl.product_version_id
                   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                   AND pl.product_line_type_id = plt.product_line_type_id
                   AND pl.id = plo.product_line_id
                   AND pl.skip_on_policy_creation = 0
                 ORDER BY CASE plt.brief
                            WHEN 'RECOMMENDED' THEN
                             0
                            WHEN 'MANDATORY' THEN
                             1
                            WHEN 'OPTIONAL' THEN
                             2
                            ELSE
                             100
                          END)
    LOOP
      IF par_base_sum IS NOT NULL
      THEN
        v_create_cover := TRUE;
      ELSIF rec.brief != 'Adm_Cost_Life'
      THEN
        BEGIN
          v_brutto_sum   := par_prog_sums(rec.brief);
          v_create_cover := TRUE;
        EXCEPTION
          WHEN no_data_found THEN
            -- Изменено при доработке для Platinum_LA2
            --raise_application_error(-20001, 'Не найдена сумма для программы "'||rec.brief||'"');
            v_create_cover := FALSE;
        END;
      ELSE
        v_brutto_sum := v_admin_cost;
      END IF;

      IF v_create_cover
      THEN
        DECLARE
          v_normrate NUMBER;
          v_loading  NUMBER;
          v_netto    NUMBER;
          v_brutto   NUMBER;
          v_age      NUMBER;
          v_cover_id p_cover.p_cover_id%TYPE;
        BEGIN
          /* Создаем покрытие */
          v_cover_id := pkg_cover.cre_new_cover(v_assured_id, rec.id, rec.is_last = 1);
          /* Нагрузка */
          v_loading := pkg_cover.calc_loading(v_cover_id);
          /* Норма доходности */
          v_normrate := pkg_productlifeproperty.calc_normrate_value(v_cover_id);

          SELECT pc.accum_period_end_age INTO v_age FROM p_cover pc WHERE pc.p_cover_id = v_cover_id;

          IF v_age IS NOT NULL
          THEN
            pkg_cover.set_cover_accum_period_end_age(p_p_cover_id => v_cover_id, p_age => v_age);
          END IF;

          IF par_base_sum IS NOT NULL
          THEN
            IF par_product LIKE 'CR10%'
            THEN
              UPDATE p_cover pc
                 SET normrate_value   = v_normrate
                    ,rvb_value        = v_loading
                    ,premia_base_type = 0
              --                    ,ins_amount       = v_ins_amount
               WHERE pc.p_cover_id = v_cover_id;
            END IF;

            pkg_cover.update_cover_sum(v_cover_id);

          ELSIF par_product = 'Platinum_LA2_CityService'
                AND rec.description = 'Первичное диагностирование смертельно опасного заболевания'
          THEN
            UPDATE p_cover pc
               SET is_handchange_amount  = 0
                  ,is_handchange_premium = 0
                  ,is_handchange_fee     = 0
                  ,is_handchange_tariff  = 0
                  ,normrate_value        = v_normrate
                  ,rvb_value             = v_loading
                  ,ins_amount            = 8500
                  ,k_coef                = 0
                  ,k_coef_m              = 0
                  ,k_coef_nm             = 0
                  ,s_coef                = 0
                  ,s_coef_m              = 0
                  ,s_coef_nm             = 0
                  ,premia_base_type      = 0
                  ,t_deductible_type_id  = 1
                  ,t_deduct_val_type_id  = 1
                  ,deductible_value      = 0
             WHERE pc.p_cover_id = v_cover_id;

            pkg_cover.update_cover_sum(v_cover_id);

            UPDATE p_cover pc
               SET is_handchange_premium = 1
                  ,is_handchange_fee     = 1
             WHERE pc.p_cover_id = v_cover_id;

          ELSE
            UPDATE p_cover pc
               SET is_handchange_amount  = 0
                  ,is_handchange_premium = 0
                  ,is_handchange_fee     = 0
                  ,is_handchange_tariff  = 0
                  ,normrate_value        = v_normrate
                  ,rvb_value             = v_loading
                  ,fee                   = v_brutto_sum
                  ,k_coef                = 0
                  ,k_coef_m              = 0
                  ,k_coef_nm             = 0
                  ,s_coef                = 0
                  ,s_coef_m              = 0
                  ,s_coef_nm             = 0
                  ,premia_base_type      = 1
                  ,t_deductible_type_id  = 1
                  ,t_deduct_val_type_id  = 1
                  ,deductible_value      = 0
             WHERE pc.p_cover_id = v_cover_id;

            v_netto := ROUND(pkg_cover.calc_tariff_netto(p_p_cover_id => v_cover_id), 5);
            UPDATE p_cover pc
               SET netto_tariff = v_netto
                  ,tariff_netto = v_netto
                  ,premium      = v_brutto_sum
             WHERE pc.p_cover_id = v_cover_id;
            v_brutto := pkg_cover.calc_tariff(p_p_cover_id => v_cover_id);
            IF rec.brief != 'Adm_Cost_Life'
            THEN
              v_ins_amount := pkg_round_rules.calculate(p_round_rules_id => rec.ins_amount_round_rules_id
                                                       ,p_value          => v_brutto_sum / v_brutto);
            ELSE
              v_ins_amount := v_admin_cost;
            END IF;
            UPDATE p_cover pc
               SET tariff     = v_brutto
                  ,ins_amount = nvl(ins_amount, v_ins_amount)
             WHERE pc.p_cover_id = v_cover_id;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20001
                                   ,'Ошибка подключения покрытия: ' || SQLERRM);
        END;
      END IF;
    END LOOP;

    IF par_product LIKE 'CR10%'
    THEN
      pkg_policy.update_policy_dates(p_pol_id => v_policy_id);
    END IF;

    /* сформировать ЭПГ */
    pkg_payment.set_policy_new_renlife(doc_id => v_policy_id);

    /* Резервы и выкупные суммы */
    pkg_pol_cash_surr_method.recalccashsurrmethod(p_policy_id => v_policy_id);

    IF par_product IN ('CR103_3', 'CR103_4', 'CR103_5_Renault')
    THEN
      pkg_products_control.policy_control(p_p_policy_id => v_policy_id);
    END IF;

    /* Получение выкупных сумм в json */
    DECLARE
      v_obj     JSON;
      v_res_obj JSON := JSON();
      v_array   JSON_LIST := JSON_LIST();
    BEGIN
      FOR vr_surr IN (SELECT cd.insurance_year_number
                            ,cd.insurance_year_number AS payment_number
                             -- Не помню зачем такое...
                            , --add_months(v_start_date,(insurance_year_number-1)*12) as start_cash_surr_date
                             cd.start_cash_surr_date
                            ,cd.end_cash_surr_date
                            ,ROUND(SUM(cd.value), 2) AS VALUE
                        FROM policy_cash_surr   cs
                            ,policy_cash_surr_d cd
                            ,t_lob_line         ll
                       WHERE cs.policy_id = v_policy_id
                         AND cs.policy_cash_surr_id = cd.policy_cash_surr_id
                         AND cs.t_lob_line_id = ll.t_lob_line_id
                      -- На помню, зачем это нужно, но вроде ничего не меняет...
                      -- А в случае с Platinum_LA2 только мешает
                      --and cd.end_cash_surr_date =  add_months(v_start_date-1,insurance_year_number*12)
                       GROUP BY cd.insurance_year_number
                               ,cd.start_cash_surr_date
                               ,cd.end_cash_surr_date)
      LOOP
        v_obj := JSON();
        v_obj.put('year', vr_surr.insurance_year_number);
        v_obj.put('payment', vr_surr.payment_number);
        v_obj.put('start', vr_surr.start_cash_surr_date);
        v_obj.put('end', vr_surr.end_cash_surr_date);
        v_obj.put('value', vr_surr.value);
        v_array.append(v_obj.to_json_value);
      END LOOP;

      IF v_array.count > 0
      THEN
        v_res_obj.put('surr_sums', v_array.to_json_value);
      END IF;

      v_array := JSON_LIST();
      FOR vr_rec IN (SELECT plo.description
                           ,plo.brief
                           ,pc.ins_amount
                           ,pc.premium
                           ,pc.fee
                       FROM p_cover            pc
                           ,as_asset           se
                           ,t_prod_line_option plo
                      WHERE se.p_policy_id = v_policy_id
                        AND se.as_asset_id = pc.as_asset_id
                        AND pc.t_prod_line_option_id = plo.id
                        AND plo.brief != 'Adm_Cost_Life')
      LOOP
        v_obj := JSON();
        v_obj.put('program', vr_rec.description);
        v_obj.put('prog_brief', vr_rec.brief);
        v_obj.put('ins_sum', vr_rec.ins_amount);
        v_obj.put('premium', vr_rec.premium);
        v_obj.put('fee', vr_rec.fee);
        v_array.append(v_obj.to_json_value);
      END LOOP;

      IF v_array.count > 0
      THEN
        v_res_obj.put('ins_sums', v_array.to_json_value);
        v_res_obj.put('code', 1);
      END IF;

      IF v_res_obj.count > 0
      THEN
        DECLARE
          v_answer   CLOB;
          v_log_info pkg_communication.typ_log_info;
        BEGIN
          IF gv_debug
          THEN
            v_log_info.source_pkg_name       := gc_pkg_name;
            v_log_info.source_procedure_name := v_proc_name;
            v_log_info.operation_name        := 'get_cash_surrender_answer';
          END IF;
          dbms_lob.createtemporary(lob_loc => v_answer, cache => FALSE);
          v_res_obj.to_clob(v_answer);
          pkg_communication.htp_lob_response(par_lob => v_answer, par_log_info => v_log_info);
        END;

      END IF;

    END;
    /* Откат изменений */
    ROLLBACK;
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_res_obj JSON := JSON();
        v_error   VARCHAR2(2000);
      BEGIN
        v_error := SQLERRM;
        v_res_obj.put('code', 0);
        v_res_obj.put('error_text', ltrim(v_error, 'ORA-20001: '));

        DECLARE
          v_answer   CLOB;
          v_log_info pkg_communication.typ_log_info;
        BEGIN
          IF gv_debug
          THEN
            v_log_info.source_pkg_name       := gc_pkg_name;
            v_log_info.source_procedure_name := v_proc_name;
            v_log_info.operation_name        := 'get_cash_surrender_error';
          END IF;
          dbms_lob.createtemporary(lob_loc => v_answer, cache => FALSE);
          v_res_obj.to_clob(v_answer);
          pkg_communication.htp_lob_response(par_lob => v_answer, par_log_info => v_log_info);
        END;

        ROLLBACK;
      END;
  END get_cash_surrender;

  /*
    Байтин А.
    Возврат в B2B структуры агентского дерева на указанную дату
  */
  PROCEDURE get_agent_tree(par_date DATE) IS
    v_amount      NUMBER := 2000;
    v_offset      NUMBER := 1;
    v_string_buff VARCHAR2(2000);
    v_obj         JSON;
    v_array       JSON_LIST := JSON_LIST();
    v_proc_name   VARCHAR2(255) := 'get_agent_tree';
  BEGIN
    -- Цикл по агентскому дереву
    -- отбираются САД со всеми статусами, кроме "Отменен", "Расторгнут" и "Проект" на дату, указанную в параметре
    FOR vr_tree IN (SELECT tr.agent_num
                          ,tr.parent_num
                          ,cat.brief         AS agent_cat
                          ,to_char(cp.date_of_birth, 'dd.mm.yyyy') AS agent_birth_date
                          ,co.obj_name_orig AS agent_fio
                          ,catp.brief        AS parent_cat
                          ,cop.obj_name_orig AS parent_fio
                          ,to_char(sdh.universal_code, 'FM0009') AS agent_universal_code
                          ,dep.name as department_name
                          ,sc.brief as sales_channel_brief
                          ,(SELECT ce.email
                              FROM cn_contact_email ce
                             WHERE ce.contact_id = co.contact_id
                               AND ce.email_type = 2 -- Рабочий
                               AND ce.status = 1 -- Действует
                               AND rownum = 1) AS agent_email
                      FROM (SELECT tr.header_id
                                  ,tr.parent_id
                                  ,tr.agent_num
                                  ,PRIOR agent_num AS parent_num
                              FROM (SELECT tr.ag_contract_header_id AS header_id
                                          ,tr.ag_parent_header_id AS parent_id
                                          ,dc.num AS agent_num
                                      FROM ag_agent_tree tr
                                          ,document      dc
                                          ,doc_templ     dt
                                     WHERE tr.ag_contract_header_id = dc.document_id
                                       AND doc.get_doc_status_brief(ag_contract_header_id, par_date) NOT IN
                                           ('BREAK', 'CANCEL', 'PROJECT')
                                       AND par_date BETWEEN tr.date_begin AND tr.date_end
                                       AND dc.doc_templ_id = dt.doc_templ_id
                                       AND dt.brief = 'AGN_CONTRACT_HEADER') tr
                             START WITH tr.parent_id IS NULL
                            CONNECT BY tr.parent_id = PRIOR tr.header_id) tr
                          ,ag_contract cn
                          ,ag_contract_header ch
                          ,contact co
                          ,cn_person cp
                          ,ag_contract cnp
                          ,ag_contract_header chp
                          ,contact cop
                          ,ag_category_agent cat
                          ,ag_category_agent catp
                          ,department dep
                          ,sales_dept_header sdh
                          ,t_sales_channel   sc
                     WHERE tr.header_id = cn.contract_id
                       AND cn.contract_id = ch.ag_contract_header_id
                       AND ch.agent_id = co.contact_id
                       AND co.contact_id = cp.contact_id
                       AND tr.parent_id = cnp.contract_id(+)
                       AND cnp.contract_id = chp.ag_contract_header_id(+)
                       AND chp.agent_id = cop.contact_id(+)
                       AND cn.category_id = cat.ag_category_agent_id
                       AND cnp.category_id = catp.ag_category_agent_id(+)
                       AND cn.agency_id = dep.department_id
                       AND dep.org_tree_id = sdh.organisation_tree_id(+)
                       AND ch.t_sales_channel_id = sc.id
                       AND par_date BETWEEN cn.date_begin AND cn.date_end
                       AND (tr.parent_id IS NULL OR par_date BETWEEN cnp.date_begin AND cnp.date_end))
    LOOP
      -- Формирования отдельного элемента JSON
      v_obj := JSON();
      v_obj.put('a_num', vr_tree.agent_num);
      v_obj.put('a_fio', vr_tree.agent_fio);
      v_obj.put('a_bdate', vr_tree.agent_birth_date);
      v_obj.put('a_email', vr_tree.agent_email);
      v_obj.put('a_agency', vr_tree.agent_universal_code);
      v_obj.put('a_chnl', vr_tree.sales_channel_brief);
      v_obj.put('a_dep', vr_tree.department_name);
      v_obj.put('p_num', vr_tree.parent_num);
      v_obj.put('a_cat', vr_tree.agent_cat);
      v_obj.put('p_cat', vr_tree.parent_cat);
      v_obj.put('p_fio', vr_tree.parent_fio);
      -- Запись элемента в массив JSON
      v_array.append(v_obj.to_json_value);
    END LOOP;
    -- Формирование итогового объекта JSON
    v_obj := JSON();
    v_obj.put('code', 1);
    v_obj.put('error_text', to_char(NULL));
    v_obj.put('agent_tree', v_array.to_json_value);
    -- Запись в CLOB
    DECLARE
      v_log_info pkg_communication.typ_log_info;
    BEGIN
      IF gv_debug
      THEN
        v_log_info.source_pkg_name       := gc_pkg_name;
        v_log_info.source_procedure_name := v_proc_name;
        v_log_info.operation_name        := 'get_agent_tree_answer';
      END IF;
      pkg_communication.htp_lob_response(par_json => v_obj, par_log_info => v_log_info);
    END;

  END get_agent_tree;

  /** Функция возвращает значения свойств по типу операции и типу свойства
  *   Например вернуть значение URL для загрузки курсов Валют
  *   @autor Чирков В.Ю.
  *   @param par_oper_type_brief - сокр. наим. типа операции (например UPDATE_RATE)
  *   @param par_props_type_brief - сокр. наим. типа свойства (например URL)
  */
  FUNCTION get_b2b_props_val
  (
    par_oper_type_brief  t_b2b_props_oper.oper_brief%TYPE
   ,par_props_type_brief t_b2b_props_type.type_brief%TYPE
   ,par_raise_on_error   BOOLEAN DEFAULT TRUE
   ,par_database_name    VARCHAR DEFAULT sys.database_name
  )

   RETURN VARCHAR2 IS
    v_props_val t_b2b_props_vals.props_value%TYPE;
  BEGIN
    BEGIN
      SELECT pv.props_value
        INTO v_props_val
        FROM t_b2b_props_db   db
            ,t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
            --params
         AND op.oper_brief = par_oper_type_brief
         AND ty.type_brief = par_props_type_brief
         AND db.db_brief = par_database_name;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдено ' || par_props_type_brief || ' для операции ' ||
                                  par_oper_type_brief);
        ELSE
          v_props_val := NULL;
        END IF;
      WHEN too_many_rows THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Найдено несколько ' || par_props_type_brief || ' для операции ' ||
                                  par_oper_type_brief);
        ELSE
          v_props_val := NULL;
        END IF;
    END;
    RETURN v_props_val;
  END get_b2b_props_val;

BEGIN
  BEGIN
    SELECT pv.props_value
      INTO gv_wallet_path
      FROM t_b2b_props_vals pv
          ,t_b2b_props_oper op
          ,t_b2b_props_db   db
          ,t_b2b_props_type ty
     WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
       AND db.db_brief = sys.database_name
       AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
       AND op.oper_brief = 'common'
       AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
       AND ty.type_brief = 'wallet_path';
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      SELECT ap.def_value_c INTO gv_wallet_path FROM app_param ap WHERE ap.brief = 'ORACLE_WALLET';
  END;
  DECLARE
    v_test NUMBER(1);
  BEGIN
    SELECT nvl(t.value, 0) INTO v_test FROM t_debug_config t WHERE t.brief = 'JSON_LOG';
    IF v_test = 1
       OR is_test_server() = 1
    THEN
      gv_debug := TRUE;
    ELSE
      gv_debug := FALSE;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      gv_debug := FALSE;
  END;
  utl_http.set_wallet(path => 'file:' || gv_wallet_path);
  -- Включение генерации ошибок в get_response
  utl_http.set_response_error_check(TRUE);
  -- Включение детализации ошибок
  utl_http.set_detailed_excp_support(TRUE);
  -- Таймаут 15 минут
  utl_http.set_transfer_timeout(900);
END pkg_borlas_b2b;
/
