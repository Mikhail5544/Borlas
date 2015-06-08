CREATE OR REPLACE PACKAGE pkg_chat_message IS

  -- Author  : Aleksey Piyadin
  -- Created : 22.08.2014
  -- Purpose : Обмен сообщениями с B2B

  TYPE tr_error_report IS RECORD(
     ids               p_pol_header.ids%TYPE
    ,message_id        t_chat_message.t_chat_message_id%TYPE
    ,message_direction VARCHAR2(100)
    ,message_text      t_chat_message.message_text%TYPE
    ,file_name_list    VARCHAR2(4000)
    ,message_date      t_chat_message.create_date%TYPE
    ,error_text        t_chat_message_log.error_text%TYPE
    ,b2b_responce      t_chat_message_log.b2b_responce%TYPE
    ,error_user        t_chat_message_log.reg_user%TYPE
    ,error_date        t_chat_message_log.reg_date%TYPE);

  TYPE tt_error_report IS TABLE OF tr_error_report;

  /*
    Процедура подготовки очереди к передаче/приёму сообщений
  */
  PROCEDURE aq_prepare;

  /*
    Процедура извлечения сообщения из очереди
  */
  PROCEDURE chat_dequeue(par_correlation VARCHAR2 DEFAULT NULL);
  PROCEDURE chat_dequeue
  (
    CONTEXT  RAW
   ,reginfo  sys.aq$_reg_info
   ,descr    sys.aq$_descriptor
   ,payload  RAW
   ,payloadl NUMBER
  );

  /*
    Процедура постановки сообщения в очередь
  */
  PROCEDURE chat_enqueue(par_aq_chat_message tt_aq_chat_message);

  /*
    Пиядин А.
    Процедура помещает сообщение в очередь Advanced Queuing
    при отравке чат-сообщения из Борлас в B2B
  */
  PROCEDURE aq_put_message(par_chat_message_id t_chat_message.t_chat_message_id%TYPE);

  /*
    Функция возвращает максимальное число попыток передачи сообщения очереди
  */
  FUNCTION get_queue_max_retries RETURN NUMBER;

  /*
    Функция получения пользовательского отчета об ошибках
  */
  FUNCTION get_error_report RETURN tt_error_report
    PIPELINED;

  /*
    Процедура отправки письма с ошибками очереди
  */
  PROCEDURE send_error_report(par_t_chat_message_id t_chat_message.t_chat_message_id%TYPE DEFAULT NULL);

  /*
    Функция проверки прав доступа к чату
  */
  FUNCTION check_chat_access(par_ids NUMBER) RETURN BOOLEAN;

END pkg_chat_message;
/
CREATE OR REPLACE PACKAGE BODY pkg_chat_message IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  gc_b2b_api_url          CONSTANT VARCHAR2(50) := 'B2B_API';
  gc_b2b_api_key          CONSTANT VARCHAR2(50) := '18C84F0CCE4C57431EC573F91CCA6BD2';
  gc_queue_name           CONSTANT VARCHAR2(50) := 'INS.CHAT_MESSAGE_QUEUE';
  gc_exception_queue_name CONSTANT VARCHAR2(50) := 'INS.AQ$_AQ_CHAT_MESSAGE_E';
  gc_queue_max_retries    CONSTANT INTEGER := 5;
  gc_retry_delay          CONSTANT INTEGER := 5;
  gc_subscriber_name      CONSTANT VARCHAR2(50) := 'CHAT_MESSAGE_QUEUE_SUBSCR';

  -- Типы операций
  gc_oper_send_message  CONSTANT VARCHAR2(50) := 'send_message';
  gc_oper_get_file      CONSTANT VARCHAR2(50) := 'get_file';
  gc_oper_refr_pol_info CONSTANT VARCHAR2(50) := 'refresh_policy_info';

  gv_url t_b2b_props_vals.props_value%TYPE;

  -- Исключения
  ex_queue_already_exists        EXCEPTION;
  ex_queue_no_messages           EXCEPTION;
  ex_unknown_operation           EXCEPTION;
  ex_get_file_process_error      EXCEPTION;
  ex_send_msg_process_error      EXCEPTION;
  ex_refr_pol_info_process_error EXCEPTION;
  ex_queue_table_already_exists  EXCEPTION;

  -- Глобальные переменные
  gv_b2b_responce  VARCHAR2(4000);
  gv_b2b_file_id   NUMBER;
  gv_b2b_file_name VARCHAR2(2000);

  PRAGMA EXCEPTION_INIT(ex_queue_already_exists, -24006);
  PRAGMA EXCEPTION_INIT(ex_queue_table_already_exists, -24001);
  PRAGMA EXCEPTION_INIT(ex_queue_no_messages, -25228);

  /*
    Получение ИД лога по ИД сообщения чата
  */
  FUNCTION get_log_record_id(par_t_chat_message_id t_chat_message.t_chat_message_id%TYPE)
    RETURN t_chat_message_log.t_chat_message_log_id%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'get_log_record_id';
  
    v_result t_chat_message_log.t_chat_message_log_id%TYPE;
  BEGIN
    SELECT t_chat_message_log_id
      INTO v_result
      FROM t_chat_message_log
     WHERE t_chat_message_id = par_t_chat_message_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN too_many_rows THEN
      ex.raise(par_message => 'Ошибка выполнения процедуры ' || vc_proc_name ||
                              ': найдено несколько записей в логе ошибок по ИД сообщения');
  END get_log_record_id;

  /*
    Процедура записи ошибки в лог
  */
  PROCEDURE add_error_log
  (
    par_t_chat_message_id t_chat_message.t_chat_message_id%TYPE
   ,par_error_text        t_chat_message_log.error_text%TYPE
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_t_chat_message_log dml_t_chat_message_log.tt_t_chat_message_log;
  BEGIN
    v_t_chat_message_log := dml_t_chat_message_log.get_record(get_log_record_id(par_t_chat_message_id));
  
    IF v_t_chat_message_log.t_chat_message_log_id IS NULL
    THEN
      v_t_chat_message_log.queue_name        := gc_queue_name;
      v_t_chat_message_log.t_chat_message_id := par_t_chat_message_id;
      v_t_chat_message_log.repeat_num        := 1;
      v_t_chat_message_log.error_text        := par_error_text;
      v_t_chat_message_log.b2b_responce      := gv_b2b_responce;
      v_t_chat_message_log.reg_user          := USER;
      v_t_chat_message_log.reg_date          := SYSDATE;
      dml_t_chat_message_log.insert_record(v_t_chat_message_log);
    ELSE
      v_t_chat_message_log.repeat_num   := v_t_chat_message_log.repeat_num + 1;
      v_t_chat_message_log.error_text   := par_error_text;
      v_t_chat_message_log.b2b_responce := gv_b2b_responce;
      v_t_chat_message_log.reg_user     := USER;
      v_t_chat_message_log.reg_date     := SYSDATE;
      dml_t_chat_message_log.update_record(v_t_chat_message_log);
    END IF;
  
    COMMIT;
  END add_error_log;

  /*
    Процедура подготовки очереди к передаче/приёму сообщений
  */
  PROCEDURE aq_prepare IS
  BEGIN
    /* Попытка создать очередь */
  
    BEGIN
      dbms_aqadm.create_queue_table(queue_table        => 'aq_chat_message'
                                   ,queue_payload_type => 'tt_aq_chat_message'
                                   ,multiple_consumers => TRUE
                                   ,COMMENT            => 'Таблица чат сообщений B2B - Borlas');
    EXCEPTION
      WHEN ex_queue_table_already_exists THEN
        NULL;
    END;
  
    BEGIN
      dbms_aqadm.create_queue(queue_name  => gc_queue_name
                             ,queue_table => 'ins.aq_chat_message'
                             ,max_retries => gc_queue_max_retries
                             ,retry_delay => gc_retry_delay
                             ,auto_commit => TRUE);
    EXCEPTION
      WHEN ex_queue_already_exists THEN
        NULL;
    END;
  
    /* Запуск очереди */
    dbms_aqadm.start_queue(gc_queue_name);
    dbms_aqadm.start_queue(gc_exception_queue_name, FALSE, TRUE);
  END aq_prepare;

  /*
    Пиядин А.
    Процедура обработки сообщения типа get_file Advanced Queuing:
    Получение файла из B2B в Борлас
  */
  PROCEDURE aq_get_file_process(par_aq_chat_message tt_aq_chat_message) IS
    vc_oper_name CONSTANT pkg_trace.t_object_name := gc_oper_get_file;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'b2b_get_file';
  
    v_request          JSON := JSON();
    v_data             JSON := JSON();
    v_converted_json   CLOB;
    v_response         BLOB;
    v_stored_file_body dml_stored_files_body.tt_stored_files_body;
  
    v_log_info pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
    -- Включение UTF-8
    json_printer.ascii_output := TRUE;
  
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    /* Входные параметры */
    pkg_trace.add_variable(par_trace_var_name  => 'IDS'
                          ,par_trace_var_value => par_aq_chat_message.ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => par_aq_chat_message.b2b_policy_id);
    pkg_trace.add_variable(par_trace_var_name  => 'T_CHAT_MESSAGE_ID'
                          ,par_trace_var_value => par_aq_chat_message.t_chat_message_id);
    pkg_trace.add_variable(par_trace_var_name  => 'FILE_ID'
                          ,par_trace_var_value => par_aq_chat_message.file_list(1).file_id);
    pkg_trace.add_variable(par_trace_var_name  => 'FILE_NAME'
                          ,par_trace_var_value => par_aq_chat_message.file_list(1).file_name);
  
    /* Формируем JSON для запроса */
    v_request.put('key', gc_b2b_api_key);
    v_request.put('operation', par_aq_chat_message.operation);
    v_data.put('ids', par_aq_chat_message.ids);
    v_data.put('policy_id', par_aq_chat_message.b2b_policy_id);
    v_data.put('file_id', par_aq_chat_message.file_list(1).file_id);
    v_request.put(pkg_integration.gc_data_keyword, v_data);
  
    -- Определим глобальные переменные для отображения ошибки, если надо
    gv_b2b_file_id   := par_aq_chat_message.file_list(1).file_id;
    gv_b2b_file_name := par_aq_chat_message.file_list(1).file_name;
  
    dbms_lob.createtemporary(lob_loc => v_converted_json, cache => TRUE);
    v_request.to_clob(buf => v_converted_json, spaces => TRUE);
    v_converted_json := 'data=' || v_converted_json;
  
    v_log_info.source_pkg_name       := gc_pkg_name;
    v_log_info.source_procedure_name := vc_proc_name;
    v_log_info.operation_name        := vc_oper_name;
  
    BEGIN
      /* Параметры, используемые в запросе */
      pkg_trace.add_variable(par_trace_var_name => 'URL', par_trace_var_value => gv_url);
      pkg_trace.add_variable(par_trace_var_name  => 'REQUEST_JSON'
                            ,par_trace_var_value => v_converted_json);
    
      /* Запрос файла у B2B */
      v_response := pkg_communication.request_blob(par_url      => gv_url
                                                  ,par_send     => v_converted_json
                                                  ,par_log_info => v_log_info);
    
      IF v_response IS NOT NULL
      THEN
        v_stored_file_body.stored_fb        := v_response;
        v_stored_file_body.parent_uro_id    := par_aq_chat_message.t_chat_message_id;
        v_stored_file_body.parent_ure_id    := ents.id_by_brief('T_CHAT_MESSAGE');
        v_stored_file_body.file_origin_name := par_aq_chat_message.file_list(1).file_name;
        v_stored_file_body.file_stored_name := par_aq_chat_message.file_list(1).file_name;
        v_stored_file_body.note             := 'Вложение чата из B2B';
        v_stored_file_body.attach_date      := SYSDATE;
        dml_stored_files_body.insert_record(v_stored_file_body);
      ELSE
        DECLARE
          v_responce_c CLOB;
        BEGIN
          v_log_info.operation_name := vc_oper_name || '_ERROR_TEXT_REQ';
          v_responce_c              := pkg_communication.request(par_url      => gv_url
                                                                ,par_send     => v_converted_json
                                                                ,par_log_info => v_log_info);
          gv_b2b_responce           := v_responce_c;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        RAISE ex_get_file_process_error;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        trace('Передача не удалась');
        json_printer.ascii_output := FALSE;
        dbms_lob.freetemporary(v_converted_json);
        RAISE ex_get_file_process_error;
    END;
  
    -- Выключение UTF-8
    json_printer.ascii_output := FALSE;
  
    -- Очистка памяти
    dbms_lob.freetemporary(v_converted_json);
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END aq_get_file_process;

  /*
    Пиядин А.
    Процедура обработки сообщения типа send_message Advanced Queuing:
    Отправка сообщения из Борлас в B2B
  */
  PROCEDURE aq_send_message_process(par_aq_chat_message tt_aq_chat_message) IS
    vc_oper_name CONSTANT pkg_trace.t_object_name := gc_oper_send_message;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'b2b_send_message';
  
    v_request        JSON := JSON();
    v_data           JSON := JSON();
    v_converted_json CLOB;
    v_response       CLOB := NULL;
    v_json_response  JSON := JSON();
  
    v_log_info pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
    -- Включение UTF-8
    json_printer.ascii_output := TRUE;
  
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    /* Входные параметры */
    pkg_trace.add_variable(par_trace_var_name  => 'IDS'
                          ,par_trace_var_value => par_aq_chat_message.ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => par_aq_chat_message.b2b_policy_id);
    pkg_trace.add_variable(par_trace_var_name  => 'T_CHAT_MESSAGE_ID'
                          ,par_trace_var_value => par_aq_chat_message.t_chat_message_id);
    pkg_trace.add_variable(par_trace_var_name  => 'MESSAGE_TEXT'
                          ,par_trace_var_value => par_aq_chat_message.message_text);
  
    /* Формируем JSON для запроса */
    v_request.put('key', gc_b2b_api_key);
    v_request.put('operation', par_aq_chat_message.operation);
    v_data.put('ids', par_aq_chat_message.ids);
    v_data.put('policy_id', par_aq_chat_message.b2b_policy_id);
    v_data.put('message_text', par_aq_chat_message.message_text);
    DECLARE
      v_file_json_list JSON_LIST := JSON_LIST();
    BEGIN
      FOR i IN 1 .. par_aq_chat_message.file_list.count
      LOOP
        DECLARE
          v_file_json JSON := JSON();
        BEGIN
          v_file_json.put('file_id', par_aq_chat_message.file_list(i).file_id);
          v_file_json.put('file_name', par_aq_chat_message.file_list(i).file_name);
          v_file_json_list.append(v_file_json.to_json_value);
        
          pkg_trace.add_variable(par_trace_var_name  => 'FILE_ID[' || to_char(i) || ']'
                                ,par_trace_var_value => par_aq_chat_message.file_list(i).file_id);
          pkg_trace.add_variable(par_trace_var_name  => 'FILE_NAME[' || to_char(i) || ']'
                                ,par_trace_var_value => par_aq_chat_message.file_list(i).file_name);
        END;
      END LOOP;
    
      v_data.put('attachments', v_file_json_list);
    END;
  
    v_request.put(pkg_integration.gc_data_keyword, v_data);
  
    dbms_lob.createtemporary(lob_loc => v_converted_json, cache => TRUE);
    v_request.to_clob(buf => v_converted_json, spaces => TRUE);
    v_converted_json := 'data=' || v_converted_json;
  
    v_log_info.source_pkg_name       := gc_pkg_name;
    v_log_info.source_procedure_name := vc_proc_name;
    v_log_info.operation_name        := vc_oper_name;
  
    BEGIN
      /* Параметры, используемые в запросе */
      pkg_trace.add_variable(par_trace_var_name => 'URL', par_trace_var_value => gv_url);
      pkg_trace.add_variable(par_trace_var_name  => 'REQUEST_JSON'
                            ,par_trace_var_value => v_converted_json);
    
      /* Запрос к B2B */
      v_response      := pkg_communication.request(par_url      => gv_url
                                                  ,par_send     => v_converted_json
                                                  ,par_log_info => v_log_info);
      gv_b2b_responce := v_response;
    
      v_json_response := JSON(v_response);
      IF v_json_response.get(pkg_integration.gc_status_keyword)
       .get_string <> pkg_integration.gc_status_ok
      THEN
        RAISE ex_send_msg_process_error;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        trace('Передача не удалась');
        json_printer.ascii_output := FALSE;
        dbms_lob.freetemporary(v_converted_json);
        RAISE ex_send_msg_process_error;
    END;
  
    -- Выключение UTF-8
    json_printer.ascii_output := FALSE;
  
    -- Очистка памяти
    dbms_lob.freetemporary(v_converted_json);
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END aq_send_message_process;

  /*
    Пиядин А.
    Процедура обработки сообщения типа refresh_policy_info Advanced Queuing:
    Отправка сигнала обновления ДС из Борлас в B2B
  */
  PROCEDURE aq_refresh_policy_info(par_aq_chat_message tt_aq_chat_message) IS
    vc_oper_name CONSTANT pkg_trace.t_object_name := gc_oper_refr_pol_info;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'b2b_refresh_policy_info';
  
    v_request        JSON := JSON();
    v_data           JSON := JSON();
    v_converted_json CLOB;
    v_response       CLOB := NULL;
    v_json_response  JSON := JSON();
  
    v_log_info pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    /* Входные параметры */
    pkg_trace.add_variable(par_trace_var_name  => 'IDS'
                          ,par_trace_var_value => par_aq_chat_message.ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => par_aq_chat_message.b2b_policy_id);
  
    /* Формируем JSON для запроса */
    v_request.put('key', gc_b2b_api_key);
    v_request.put('operation', par_aq_chat_message.operation);
    v_data.put('ids', par_aq_chat_message.ids);
    v_data.put('policy_id', par_aq_chat_message.b2b_policy_id);
    v_request.put(pkg_integration.gc_data_keyword, v_data);
  
    dbms_lob.createtemporary(lob_loc => v_converted_json, cache => TRUE);
    v_request.to_clob(buf => v_converted_json, spaces => TRUE);
    v_converted_json := 'data=' || v_converted_json;
  
    v_log_info.source_pkg_name       := gc_pkg_name;
    v_log_info.source_procedure_name := vc_proc_name;
    v_log_info.operation_name        := vc_oper_name;
  
    BEGIN
      /* Параметры, используемые в запросе */
      pkg_trace.add_variable(par_trace_var_name => 'URL', par_trace_var_value => gv_url);
      pkg_trace.add_variable(par_trace_var_name  => 'REQUEST_JSON'
                            ,par_trace_var_value => v_converted_json);
    
      /* Запрос к B2B */
      v_response      := pkg_communication.request(par_url      => gv_url
                                                  ,par_send     => v_converted_json
                                                  ,par_log_info => v_log_info);
      gv_b2b_responce := v_response;
    
      v_json_response := JSON(v_response);
      IF v_json_response.get(pkg_integration.gc_status_keyword)
       .get_string <> pkg_integration.gc_status_ok
      THEN
        RAISE ex_refr_pol_info_process_error;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        trace('Передача не удалась');
        json_printer.ascii_output := FALSE;
        dbms_lob.freetemporary(v_converted_json);
        RAISE ex_refr_pol_info_process_error;
    END;
  
    -- Очистка памяти
    dbms_lob.freetemporary(v_converted_json);
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END aq_refresh_policy_info;

  /*
    Процедура извлечения сообщения из очереди
  */
  PROCEDURE chat_dequeue(par_correlation VARCHAR2 DEFAULT NULL) IS
    v_aq_chat_message tt_aq_chat_message;
  
    msg_properties   dbms_aq.message_properties_t;
    deq_options      dbms_aq.dequeue_options_t;
    msg_handle       RAW(16);
    v_tmp_message_id t_chat_message.t_chat_message_id%TYPE;
  
    /*
      Генерация псевдо сообщения
      Для регистрации ошибки в случае некорректной обработки refresh_policy_info
    */
    FUNCTION create_tmp_message(par_ids p_pol_header.ids%TYPE)
      RETURN t_chat_message.t_chat_message_id%TYPE IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_policy_header_id   p_pol_header.policy_header_id%TYPE;
      v_t_chat_message     dml_t_chat_message.tt_t_chat_message;
      v_t_chat_message_log dml_t_chat_message_log.tt_t_chat_message_log;
    BEGIN
      v_policy_header_id := pkg_policy.get_policy_header_by_ids(par_ids);
    
      SELECT MAX(m.t_chat_message_id)
        INTO v_t_chat_message.t_chat_message_id
        FROM t_chat_message m
       WHERE 1 = 1
         AND m.message_direction = 'OUT'
         AND m.parent_uro_id = v_policy_header_id
         AND m.parent_ure_id = ents.id_by_brief('P_POL_HEADER')
         AND m.message_text = 'Параметры договора обновлены';
    
      IF v_t_chat_message.t_chat_message_id IS NULL
      THEN
        v_t_chat_message.parent_uro_id     := v_policy_header_id;
        v_t_chat_message.parent_ure_id     := ents.id_by_brief('P_POL_HEADER');
        v_t_chat_message.message_direction := 'OUT';
        v_t_chat_message.message_text      := 'Параметры договора обновлены';
        dml_t_chat_message.insert_record(v_t_chat_message);
      ELSE
        /* Удаление существующего лога по сообщению */
        v_t_chat_message_log := dml_t_chat_message_log.get_record(get_log_record_id(v_t_chat_message.t_chat_message_id));
        IF v_t_chat_message_log.repeat_num > gc_queue_max_retries
        THEN
          dml_t_chat_message_log.delete_record(v_t_chat_message_log.t_chat_message_log_id);
        END IF;
      END IF;
      COMMIT;
    
      RETURN v_t_chat_message.t_chat_message_id;
    END create_tmp_message;
  
  BEGIN
    /* Опции dequeue */
    deq_options.navigation    := dbms_aq.first_message;
    deq_options.correlation   := par_correlation;
    deq_options.consumer_name := gc_subscriber_name;
    deq_options.wait          := dbms_aq.no_wait;
  
    dbms_aq.dequeue(queue_name         => gc_queue_name
                   ,dequeue_options    => deq_options
                   ,message_properties => msg_properties
                   ,payload            => v_aq_chat_message
                   ,msgid              => msg_handle);
  
    /* Обработка сообщения из очереди по типу операции */
    CASE v_aq_chat_message.operation
      WHEN gc_oper_send_message THEN
        aq_send_message_process(v_aq_chat_message);
      WHEN gc_oper_get_file THEN
        aq_get_file_process(v_aq_chat_message);
      WHEN gc_oper_refr_pol_info THEN
        aq_refresh_policy_info(v_aq_chat_message);
      ELSE
        RAISE ex_unknown_operation;
    END CASE;
  EXCEPTION
    WHEN ex_queue_no_messages THEN
      NULL;
    WHEN ex_unknown_operation THEN
      add_error_log(par_t_chat_message_id => v_aq_chat_message.t_chat_message_id
                   ,par_error_text        => 'Неизвестная операция "' || v_aq_chat_message.operation ||
                                             '" в очереди сообщений');
      RAISE;
    WHEN ex_get_file_process_error THEN
      add_error_log(par_t_chat_message_id => v_aq_chat_message.t_chat_message_id
                   ,par_error_text        => substr('Передача файла не удалась (b2b_file_id = ' ||
                                                    to_char(gv_b2b_file_id) || ', b2b_file_name = ' ||
                                                    gv_b2b_file_name || ')'
                                                   ,1
                                                   ,4000));
      RAISE;
    WHEN ex_send_msg_process_error THEN
      add_error_log(par_t_chat_message_id => v_aq_chat_message.t_chat_message_id
                   ,par_error_text        => 'Передача текстового сообщения не удалась');
      RAISE;
    WHEN ex_refr_pol_info_process_error THEN
      v_tmp_message_id := create_tmp_message(v_aq_chat_message.ids);
      add_error_log(par_t_chat_message_id => v_tmp_message_id
                   ,par_error_text        => 'Передача сигнала об изменении параметров договора не удалась');
      RAISE;
  END chat_dequeue;

  PROCEDURE chat_dequeue
  (
    CONTEXT  RAW
   ,reginfo  sys.aq$_reg_info
   ,descr    sys.aq$_descriptor
   ,payload  RAW
   ,payloadl NUMBER
  ) IS
    v_aq_chat_message tt_aq_chat_message;
  
    msg_properties   dbms_aq.message_properties_t;
    deq_options      dbms_aq.dequeue_options_t;
    msg_handle       RAW(16);
    v_tmp_message_id t_chat_message.t_chat_message_id%TYPE;
  
    /*
      Генерация псевдо сообщения
      Для регистрации ошибки в случае некорректной обработки refresh_policy_info
    */
    FUNCTION create_tmp_message(par_ids p_pol_header.ids%TYPE)
      RETURN t_chat_message.t_chat_message_id%TYPE IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_policy_header_id   p_pol_header.policy_header_id%TYPE;
      v_t_chat_message     dml_t_chat_message.tt_t_chat_message;
      v_t_chat_message_log dml_t_chat_message_log.tt_t_chat_message_log;
    BEGIN
      v_policy_header_id := pkg_policy.get_policy_header_by_ids(par_ids);
    
      SELECT MAX(m.t_chat_message_id)
        INTO v_t_chat_message.t_chat_message_id
        FROM t_chat_message m
       WHERE 1 = 1
         AND m.message_direction = 'OUT'
         AND m.parent_uro_id = v_policy_header_id
         AND m.parent_ure_id = ents.id_by_brief('P_POL_HEADER')
         AND m.message_text = 'Параметры договора обновлены';
    
      IF v_t_chat_message.t_chat_message_id IS NULL
      THEN
        v_t_chat_message.parent_uro_id     := v_policy_header_id;
        v_t_chat_message.parent_ure_id     := ents.id_by_brief('P_POL_HEADER');
        v_t_chat_message.message_direction := 'OUT';
        v_t_chat_message.message_text      := 'Параметры договора обновлены';
        dml_t_chat_message.insert_record(v_t_chat_message);
      ELSE
        /* Удаление существующего лога по сообщению */
        v_t_chat_message_log := dml_t_chat_message_log.get_record(get_log_record_id(v_t_chat_message.t_chat_message_id));
        IF v_t_chat_message_log.repeat_num > gc_queue_max_retries
        THEN
          dml_t_chat_message_log.delete_record(v_t_chat_message_log.t_chat_message_log_id);
        END IF;
      END IF;
      COMMIT;
    
      RETURN v_t_chat_message.t_chat_message_id;
    END create_tmp_message;
  
  BEGIN
  
    /* Опции dequeue */
    deq_options.msgid         := descr.msg_id;
    deq_options.consumer_name := descr.consumer_name;
  
    --raise_application_error(-20789,'test_raise');
  
    dbms_aq.dequeue(queue_name         => gc_queue_name
                   ,dequeue_options    => deq_options
                   ,message_properties => msg_properties
                   ,payload            => v_aq_chat_message
                   ,msgid              => msg_handle);
  
    /* Обработка сообщения из очереди по типу операции */
    CASE v_aq_chat_message.operation
      WHEN gc_oper_send_message THEN
        aq_send_message_process(v_aq_chat_message);
      WHEN gc_oper_get_file THEN
        aq_get_file_process(v_aq_chat_message);
      WHEN gc_oper_refr_pol_info THEN
        aq_refresh_policy_info(v_aq_chat_message);
      ELSE
        RAISE ex_unknown_operation;
    END CASE;
  
    -- auto_commit enabled
    --COMMIT;
  
  EXCEPTION
    WHEN ex_queue_no_messages THEN
      NULL;
    WHEN ex_unknown_operation THEN
      add_error_log(par_t_chat_message_id => v_aq_chat_message.t_chat_message_id
                   ,par_error_text        => 'Неизвестная операция "' || v_aq_chat_message.operation ||
                                             '" в очереди сообщений');
      RAISE;
    WHEN ex_get_file_process_error THEN
      add_error_log(par_t_chat_message_id => v_aq_chat_message.t_chat_message_id
                   ,par_error_text        => substr('Передача файла не удалась (b2b_file_id = ' ||
                                                    to_char(gv_b2b_file_id) || ', b2b_file_name = ' ||
                                                    gv_b2b_file_name || ')'
                                                   ,1
                                                   ,4000));
      RAISE;
    WHEN ex_send_msg_process_error THEN
      add_error_log(par_t_chat_message_id => v_aq_chat_message.t_chat_message_id
                   ,par_error_text        => 'Передача текстового сообщения не удалась');
      RAISE;
    WHEN ex_refr_pol_info_process_error THEN
      v_tmp_message_id := create_tmp_message(v_aq_chat_message.ids);
      add_error_log(par_t_chat_message_id => v_tmp_message_id
                   ,par_error_text        => 'Передача сигнала об изменении параметров договора не удалась');
      RAISE;
    
  END chat_dequeue;

  /*
  PROCEDURE dequeue_exception_queue IS
    v_aq_chat_message tt_aq_chat_message;
  
    msg_properties dbms_aq.message_properties_t;
    deq_options    dbms_aq.dequeue_options_t;
    msg_handle     RAW(16);
  BEGIN
  
    dbms_aq.dequeue_array(
    
    deq_options.msgid := descr.msg_id;
    deq_options.consumer_name := descr.consumer_name;
    deq_options.dequeue_mode := dbms_aq.browse;
  
    dbms_aq.dequeue(queue_name         => gc_exception_queue_name
                   ,dequeue_options    => deq_options
                   ,message_properties => msg_properties
                   ,payload            => v_aq_chat_message
                   ,msgid              => msg_handle);
  
  END dequeue_exception_msg;
  */

  /*
    Процедура постановки сообщения в очередь
  */
  PROCEDURE chat_enqueue(par_aq_chat_message tt_aq_chat_message) IS
    msg_properties  dbms_aq.message_properties_t;
    enqueue_options dbms_aq.enqueue_options_t;
    msg_handle      RAW(16);
  
    /*
      Джоб разовой отправки последнего сообщения из очереди
    */
    PROCEDURE once_dequeue_job IS
    BEGIN
      dbms_scheduler.create_job(job_name   => 'AQ_DEQUEUE_ONCE_' ||
                                              par_aq_chat_message.t_chat_message_id
                               ,job_type   => 'PLSQL_BLOCK'
                               ,job_action => 'BEGIN ins.pkg_chat_message.chat_dequeue(' ||
                                              to_char(par_aq_chat_message.t_chat_message_id) ||
                                              '); END;'
                               ,enabled    => TRUE
                               ,start_date => SYSDATE
                               ,auto_drop  => TRUE);
    END once_dequeue_job;
  
  BEGIN
    /* Опции enqueue */
    enqueue_options.visibility := dbms_aq.on_commit;
    msg_properties.correlation := to_char(par_aq_chat_message.t_chat_message_id);
  
    dbms_aq.enqueue(queue_name         => gc_queue_name
                   ,enqueue_options    => enqueue_options
                   ,message_properties => msg_properties
                   ,payload            => par_aq_chat_message
                   ,msgid              => msg_handle);
  
    --    ins.pkg_chat_message.chat_dequeue(to_char(par_aq_chat_message.t_chat_message_id));
  
  END chat_enqueue;

  /*
    Пиядин А.
    Процедура помещает сообщение в очередь Advanced Queuing
    при отравке чат-сообщения из Борлас в B2B
  */
  PROCEDURE aq_put_message(par_chat_message_id t_chat_message.t_chat_message_id%TYPE) IS
    v_aq_chat_message tt_aq_chat_message;
    v_tt_file_list    tt_file_list := tt_file_list();
    v_g_policy        dml_g_policy.tt_g_policy;
  BEGIN
    BEGIN
      SELECT gp.*
        INTO v_g_policy
        FROM g_policy       gp
            ,t_chat_message cm
       WHERE 1 = 1
         AND gp.p_pol_header_id = cm.parent_uro_id
         AND cm.parent_ure_id = ent.id_by_brief('P_POL_HEADER')
         AND gp.ids IS NOT NULL
         AND cm.t_chat_message_id = par_chat_message_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить запись в шлюзе по договору страхования.');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Не удалось однозначно определить запись в шлюзе по договору страхования.');
    END;
  
    FOR rec IN (SELECT rownum             rn
                      ,f.stored_files_id  file_id
                      ,f.file_origin_name file_name
                  FROM stored_files f
                 WHERE f.parent_uro_id = par_chat_message_id
                   AND f.parent_ure_id = ent.id_by_brief('T_CHAT_MESSAGE'))
    LOOP
      v_tt_file_list.extend;
      v_tt_file_list(v_tt_file_list.last) := t_file(rec.file_id, rec.file_name);
    END LOOP;
  
    v_aq_chat_message := tt_aq_chat_message(gc_oper_send_message -- operation
                                           ,v_g_policy.ids -- ids
                                           ,v_g_policy.policy_b2b_id -- b2b_policy_id
                                           ,par_chat_message_id -- t_chat_message_id
                                           ,dml_t_chat_message.get_record(par_chat_message_id)
                                            .message_text -- message_text
                                           ,v_tt_file_list -- file_list
                                            );
  
    /* Удаление существующего лога по сообщению */
    dml_t_chat_message_log.delete_record(get_log_record_id(par_chat_message_id));
  
    /* Постановка сообщения в очередь */
    chat_enqueue(v_aq_chat_message);
  
  END aq_put_message;

  /*
    Функция возвращает максимальное число попыток передачи сообщения очереди
  */
  FUNCTION get_queue_max_retries RETURN NUMBER IS
  BEGIN
    RETURN gc_queue_max_retries;
  END get_queue_max_retries;

  /*
    Функция получения пользовательского отчета об ошибках
  */
  FUNCTION get_error_report RETURN tt_error_report
    PIPELINED IS
  
    -- Получение списка файлов через запятую
    FUNCTION get_file_name_list(par_t_chat_message_id t_chat_message.t_chat_message_id%TYPE)
      RETURN VARCHAR2 IS
      v_file_names_array tt_one_col;
    BEGIN
      SELECT DISTINCT f.file_origin_name BULK COLLECT
        INTO v_file_names_array
        FROM stored_files f
       WHERE f.parent_uro_id = par_t_chat_message_id
         AND f.parent_ure_id = ents.id_by_brief('T_CHAT_MESSAGE');
    
      RETURN pkg_utils.get_aggregated_string(par_table => v_file_names_array, par_separator => ', ');
    END get_file_name_list;
  
  BEGIN
    FOR rec IN (SELECT ph.ids
                      ,m.t_chat_message_id message_id
                      ,CASE m.message_direction
                         WHEN 'IN' THEN
                          'B2B -> Borlas'
                         WHEN 'OUT' THEN
                          'Borlas -> B2B'
                       END message_direction
                      ,m.message_text
                      ,'' file_name_list
                      ,m.create_date message_date
                      ,l.error_text error_text
                      ,l.b2b_responce
                      ,CASE m.message_direction
                         WHEN 'IN' THEN
                          'B2B'
                         ELSE
                          l.reg_user
                       END error_user
                      ,l.reg_date error_date
                  FROM t_chat_message_log l
                      ,t_chat_message     m
                      ,p_pol_header       ph
                 WHERE 1 = 1
                   AND l.t_chat_message_id = m.t_chat_message_id
                   AND l.repeat_num >= pkg_chat_message.get_queue_max_retries
                   AND m.parent_uro_id = ph.policy_header_id
                   AND m.parent_ure_id = ents.id_by_brief('P_POL_HEADER'))
    LOOP
      rec.file_name_list := get_file_name_list(rec.message_id);
      PIPE ROW(rec);
    END LOOP;
  
    RETURN;
  END get_error_report;

  /*
    Процедура отправки письма с ошибками очереди
  */
  PROCEDURE send_error_report(par_t_chat_message_id t_chat_message.t_chat_message_id%TYPE DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_blob  BLOB;
    v_files pkg_email.t_files := pkg_email.t_files();
    v_text  VARCHAR2(4000);
  BEGIN
    IF par_t_chat_message_id IS NULL
    THEN
      --Создание документа
      ora_excel.new_document;
      ora_excel.add_sheet('Ошибки');
      ora_excel.query_to_sheet('select * from v_rep_chat_message_err order by message_id desc');
      ora_excel.save_to_blob(l_blob);
    
      v_text := 'См. вложение';
    
      v_files.extend(1);
      v_files(1).v_file := l_blob;
      v_files(1).v_file_name := 'Ошибки чата b2b-borlas.xlsx';
      v_files(1).v_file_type := 'application/excel';
    ELSE
      BEGIN
        SELECT substr('IDS: ' || v.ids || chr(10) || 'MESSAGE_ID: ' || v.message_id || chr(10) ||
                      'MESSAGE_DIRECTION: ' || v.message_direction || chr(10) || 'MESSAGE_TEXT: ' ||
                      v.message_text || chr(10) || 'FILE_NAME_LIST: ' || v.file_name_list || chr(10) ||
                      'MESSAGE_DATE: ' || v.message_date || chr(10) || 'ERROR_TEXT: ' || v.error_text ||
                      chr(10) || 'B2B_RESPONCE: ' || v.b2b_responce || chr(10) || 'ERROR_USER: ' ||
                      v.error_user || chr(10) || 'ERROR_DATE: ' || v.error_date
                     ,1
                     ,4000)
          INTO v_text
          FROM TABLE(pkg_chat_message.get_error_report) v
         WHERE v.message_id = par_t_chat_message_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          v_text := 'Обратитесь к Администратору';
      END;
    
      v_files := NULL;
    END IF;
  
    pkg_email.send_mail_with_attachment(par_to         => pkg_email.t_recipients('Pavel.Kaplya@Renlife.com')
                                       ,par_subject    => 'Ошибки при обмене чат сообщениями B2B <-> Borlas'
                                       ,par_text       => v_text
                                       ,par_attachment => v_files);
  END send_error_report;

  /*
    Функция проверки прав доступа к чату
  */
  FUNCTION check_chat_access(par_ids NUMBER) RETURN BOOLEAN IS
    v_g_policy_id g_policy.g_policy_id%TYPE;
  BEGIN
    SELECT g_policy_id INTO v_g_policy_id FROM g_policy WHERE ids = par_ids;
  
    RETURN safety.check_right_custom('B2B_CHAT_ACCESS') = 1;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN FALSE;
  END check_chat_access;

BEGIN
  gv_url := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => gc_b2b_api_url
                                            ,par_props_type_brief => 'URL');
END pkg_chat_message;
/
