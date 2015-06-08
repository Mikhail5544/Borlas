CREATE OR REPLACE PACKAGE pkg_communication IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 27.05.2013 11:58:59
  -- Purpose : Пакет для отправки и получения HTTP запросов из внишних систем и В2В

  /*
    Статусы ответов
  */
  gc_ok    VARCHAR2(2) := 'OK';
  gc_error VARCHAR2(5) := 'ERROR';

  -- Public variable declarations
  is_debug BOOLEAN := FALSE;

  TYPE typ_log_info IS RECORD(
     source_pkg_name       t_pkg_comm_log.source_pkg_name%TYPE
    ,source_procedure_name t_pkg_comm_log.source_procedure_name%TYPE
    ,operation_name        t_pkg_comm_log.operation_name%TYPE);

  SUBTYPE t_header_key IS VARCHAR(255);
  SUBTYPE t_header_value IS VARCHAR(255);

  TYPE tt_headers IS TABLE OF t_header_value INDEX BY t_header_key;
  -- Public function and procedure declarations

  PROCEDURE log
  (
    par_log_info      typ_log_info
   ,par_data          CLOB
   ,par_url           VARCHAR2 DEFAULT NULL
   ,par_request_type  VARCHAR2 DEFAULT NULL
   ,par_reg_date      DATE DEFAULT SYSDATE
   ,par_error_message t_pkg_comm_log.error_message%TYPE DEFAULT NULL
   ,par_backtrace     t_pkg_comm_log.backtrace%TYPE DEFAULT NULL
  );

  FUNCTION request
  (
    par_url           VARCHAR2
   ,par_method        VARCHAR2 DEFAULT 'POST'
   ,par_send          CLOB DEFAULT NULL
   ,par_content_type  VARCHAR2 DEFAULT 'application/x-www-form-urlencoded'
   ,par_log_info      typ_log_info DEFAULT NULL
   ,par_add_headers        pkg_communication.tt_headers DEFAULT CAST(NULL AS
                                                                     pkg_communication.tt_headers)
   ,par_use_def_proxy BOOLEAN DEFAULT FALSE
   ,par_body_charset       VARCHAR2 DEFAULT NULL
  ) RETURN CLOB;

  FUNCTION request_blob
  (
    par_url           VARCHAR2
   ,par_method        VARCHAR2 DEFAULT 'POST'
   ,par_send          CLOB DEFAULT NULL
   ,par_content_type  VARCHAR2 DEFAULT 'application/x-www-form-urlencoded'
   ,par_log_info      typ_log_info DEFAULT NULL
   ,par_add_headers   pkg_communication.tt_headers DEFAULT CAST(NULL AS pkg_communication.tt_headers)
   ,par_use_def_proxy BOOLEAN DEFAULT FALSE
   ,par_body_charset  VARCHAR2 DEFAULT NULL
  ) RETURN BLOB;

  -- Процедура для ответа через mod_plsql
  PROCEDURE htp_lob_response
  (
    par_lob          CLOB
   ,par_log_info     typ_log_info DEFAULT NULL
   ,par_content_type VARCHAR2 DEFAULT 'text/html'
  );

  PROCEDURE htp_lob_response
  (
    par_json     JSON
   ,par_log_info typ_log_info DEFAULT NULL
  );

  PROCEDURE response_with_file
  (
    par_file         BLOB
   ,par_file_name    VARCHAR2
   ,par_content_type VARCHAR2 DEFAULT NULL
   ,par_log_info     typ_log_info DEFAULT NULL
  );

  /** Процедура очищает лог коммуникаций. 
  *   Сделано по заявке 338061
  *   @autor Чирков В. Ю.
  *   @param par_clear_date_before - дата очистки лога. Лог очищается от данных старше 30
  *   дней от этой даты.
  */
  PROCEDURE clear_pkg_comm_log(par_clear_date_before DATE DEFAULT trunc(SYSDATE));

END pkg_communication;
/
CREATE OR REPLACE PACKAGE BODY pkg_communication IS

  gv_wallet_path VARCHAR2(2000);
  gv_proxy       VARCHAR2(2000);

  gc_responsible_person_email CONSTANT pkg_email.t_recipients := pkg_email.t_recipients('pavel.kaplya@renlife.com');

  FUNCTION is_log_info_empty(par_log_info typ_log_info) RETURN BOOLEAN IS
  BEGIN
    RETURN par_log_info.source_pkg_name IS NULL AND par_log_info.source_procedure_name IS NULL AND par_log_info.operation_name IS NULL;
  END is_log_info_empty;

  PROCEDURE log
  (
    par_log_info      typ_log_info
   ,par_data          CLOB
   ,par_url           VARCHAR2 DEFAULT NULL
   ,par_request_type  VARCHAR2 DEFAULT NULL
   ,par_reg_date      DATE DEFAULT SYSDATE
   ,par_error_message t_pkg_comm_log.error_message%TYPE DEFAULT NULL
   ,par_backtrace     t_pkg_comm_log.backtrace%TYPE DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO t_pkg_comm_log
      (t_pkg_comm_log_id
      ,operation_name
      ,source_pkg_name
      ,source_procedure_name
      ,data
      ,regdate
      ,url
      ,request_type
      ,error_message
      ,backtrace)
    VALUES
      (sq_t_pkg_comm_log.nextval
      ,par_log_info.operation_name
      ,par_log_info.source_pkg_name
      ,par_log_info.source_procedure_name
      ,par_data
      ,nvl(par_reg_date, SYSDATE)
      ,par_url
      ,par_request_type
      ,substr(par_error_message, 1, 2000)
      ,substr(par_backtrace, 1, 4000));
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_email.send_mail_with_attachment(par_to            => gc_responsible_person_email
                                         ,par_subject       => 'Ошибка в процедур логирования пакета ' ||
                                                               $$PLSQL_UNIT
                                         ,par_text          => 'Error stack: ' ||
                                                               dbms_utility.format_error_stack ||
                                                               chr(13) || 'Error backtrace: ' ||
                                                               dbms_utility.format_error_backtrace ||
                                                               chr(13) || 'operation: ' ||
                                                               par_log_info.operation_name || chr(13) ||
                                                               'source_pkg_name: ' ||
                                                               par_log_info.source_pkg_name || chr(13) ||
                                                               'soure_procedure_name: ' ||
                                                               par_log_info.source_procedure_name ||
                                                               chr(13) || 'url: ' || par_url
                                         ,par_ignore_errors => TRUE);
      ROLLBACK;
      RAISE;
  END log;

  PROCEDURE htp_lob_response
  (
    par_lob          CLOB
   ,par_log_info     typ_log_info DEFAULT NULL
   ,par_content_type VARCHAR2 DEFAULT 'text/html'
  ) IS
    v_amt      NUMBER := 32767;
    v_offset   NUMBER := 1;
    v_send_str VARCHAR2(32767);
  BEGIN
    IF NOT is_log_info_empty(par_log_info)
    THEN
      log(par_log_info => par_log_info, par_data => par_lob);
    END IF;
    owa_util.mime_header(ccontent_type => par_content_type, bclose_header => TRUE);
    LOOP
      -- Чтение из CLOB данных и передача их
      dbms_lob.read(lob_loc => par_lob, amount => v_amt, offset => v_offset, buffer => v_send_str);
    
      htp.prn(v_send_str);
    
      v_offset := v_offset + v_amt;
      EXIT WHEN v_amt < 32767;
    END LOOP;
  END htp_lob_response;

  PROCEDURE htp_lob_response
  (
    par_json     JSON
   ,par_log_info typ_log_info DEFAULT NULL
  ) IS
    vc_json_content_type_name CONSTANT VARCHAR2(50) := 'text/html';
    v_clob     CLOB;
    v_log_clob CLOB;
  BEGIN
  
    IF NOT is_log_info_empty(par_log_info)
    THEN
      dbms_lob.createtemporary(lob_loc => v_log_clob, cache => TRUE);
      -- При логировании форматируем JSON для читабельности
      par_json.to_clob(buf => v_log_clob, spaces => TRUE);
      log(par_log_info => par_log_info, par_data => v_log_clob);
    
      dbms_lob.freetemporary(v_log_clob);
    END IF;
  
    dbms_lob.createtemporary(lob_loc => v_clob, cache => TRUE);
  
    par_json.to_clob(buf => v_clob);
  
    htp_lob_response(par_lob => v_clob, par_content_type => vc_json_content_type_name);
  
    dbms_lob.freetemporary(lob_loc => v_clob);
  END htp_lob_response;

  PROCEDURE response_with_file
  (
    par_file         BLOB
   ,par_file_name    VARCHAR2
   ,par_content_type VARCHAR2 DEFAULT NULL
   ,par_log_info     typ_log_info DEFAULT NULL
  ) IS
    v_mime_type VARCHAR2(50);
    v_extension VARCHAR2(50);
    v_file      BLOB;
  BEGIN
  
    IF NOT is_log_info_empty(par_log_info)
    THEN
      log(par_log_info => par_log_info, par_data => NULL);
    END IF;
  
    v_file := par_file;
  
    IF par_content_type IS NULL
    THEN
      v_extension := lower(regexp_substr(par_file_name, '\.\w+$'));
    
      CASE v_extension
        WHEN '.txt' THEN
          v_mime_type := 'text/plain';
        WHEN '.tif' THEN
          v_mime_type := 'image/tiff';
        WHEN '.csv' THEN
          v_mime_type := 'text/csv';
        WHEN '.doc' THEN
          v_mime_type := 'application/msword';
        WHEN '.docx' THEN
          v_mime_type := 'application/msword';
        WHEN '.xls' THEN
          v_mime_type := 'application/vnd.ms-excel';
        WHEN '.xlsx' THEN
          v_mime_type := 'application/vnd.ms-excel';
        WHEN '.jpg' THEN
          v_mime_type := 'image/jpeg';
        WHEN '.pdf' THEN
          v_mime_type := 'application/pdf';
        WHEN '.bmp' THEN
          v_mime_type := 'image/vnd.wap.wbmp';
        ELSE
          -- Этот дип - общий mime для произвольного файла
          v_mime_type := 'application/octet-stream';
      END CASE;
    ELSE
      v_mime_type := par_content_type;
    END IF;
  
    IF v_mime_type IS NOT NULL
    THEN
      owa_util.mime_header(ccontent_type => v_mime_type, bclose_header => FALSE);
    END IF;
  
    htp.p('Content-Disposition: attachment; filename="' ||
          utl_url.escape(par_file_name, FALSE, 'UTF-8') || '"');
    htp.p('Content-Length: ' || dbms_lob.getlength(par_file));
  
    wpg_docload.download_file(p_blob => v_file);
  
  END;

  PROCEDURE http_request
  (
    par_url           VARCHAR2
   ,par_method        VARCHAR2 DEFAULT 'POST'
   ,par_send          CLOB DEFAULT NULL
   ,par_content_type  VARCHAR2 DEFAULT 'application/x-www-form-urlencoded'
   ,par_log_info      typ_log_info DEFAULT NULL
   ,par_add_headers   pkg_communication.tt_headers DEFAULT CAST(NULL AS pkg_communication.tt_headers)
   ,par_use_def_proxy BOOLEAN := FALSE
   ,par_body_charset   VARCHAR2 DEFAULT NULL
   ,par_response_out  OUT utl_http.resp
  ) IS
    v_amt      NUMBER := 32767;
    v_offset   NUMBER := 1;
    v_send_str VARCHAR2(32767);
    v_req      utl_http.req;
    v_key      pkg_communication.t_header_key;
  BEGIN
    BEGIN
    
      IF NOT is_log_info_empty(par_log_info)
      THEN
        log(par_log_info     => par_log_info
           ,par_data         => par_send
           ,par_request_type => par_method
           ,par_url          => par_url);
      END IF;
    
      -- Начало запроса HTTP
      IF par_use_def_proxy
      THEN
        utl_http.set_proxy(proxy => gv_proxy);
      END IF;
    
      v_req := utl_http.begin_request(par_url, par_method, utl_http.http_version_1_1);
    
      IF par_body_charset IS NOT NULL
      THEN
        utl_http.set_body_charset(v_req, par_body_charset);
      END IF;
    
      IF par_method = 'POST'
      THEN
      
        IF par_content_type IS NOT NULL
        THEN
          utl_http.set_header(v_req, 'Content-Type', par_content_type);
        END IF;
      
        utl_http.set_header(v_req
                           ,'Content-Length'
                           ,dbms_lob.getlength(par_send) /*get_clob_length(par_send)*/);
        IF par_add_headers.count > 0
        THEN
          v_key := par_add_headers.first;
          WHILE v_key IS NOT NULL
          LOOP
            utl_http.set_header(v_req, v_key, par_add_headers(v_key));
            v_key := par_add_headers.next(v_key);
          END LOOP;
        END IF;
      END IF;
    
      -- Отсылка данных 
      IF par_send IS NOT NULL
      THEN
        LOOP
          -- Чтение из CLOB данных и передача
          dbms_lob.read(lob_loc => par_send
                       ,amount  => v_amt
                       ,offset  => v_offset
                       ,buffer  => v_send_str);
          utl_http.write_text(v_req, v_send_str);
          v_offset := v_offset + v_amt;
          EXIT WHEN v_amt < 32767;
        END LOOP;
      END IF;
    
      -- Получение ответа
      par_response_out := utl_http.get_response(v_req);
    
    EXCEPTION
      WHEN utl_http.bad_argument THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Передан неверный аргумент');
      WHEN utl_http.bad_url THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Неверный URL');
      WHEN utl_http.protocol_error THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Ошибка протокола HTTP');
      WHEN utl_http.unknown_scheme THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Неизвестная или не поддерживаемая схема URL');
      WHEN utl_http.header_not_found THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Заголовок HTTP не найден');
      WHEN utl_http.illegal_call THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Недопустимый вызов пакета UTL_HTTP при текущем состоянии HTTP запроса');
      WHEN utl_http.http_client_error THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. HTTP_CLIENT_ERROR exception (' ||
                                utl_http.get_detailed_sqlerrm || ')');
      WHEN utl_http.http_server_error THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. HTTP_SERVER_ERROR exception (' ||
                                utl_http.get_detailed_sqlerrm || ')');
      WHEN utl_http.too_many_requests THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Одновременно открыто слишком много запросов');
      WHEN utl_http.partial_multibyte_char THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. В конце ответа был обнаружен неполный многобитный символ, который не был полностью считан');
      WHEN utl_http.transfer_timeout THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Истекло время ожидания передачи данных');
      WHEN utl_http.request_failed THEN
        raise_application_error(-20001
                               ,'Ошибка передачи данных в B2B. Сбой HTTP запроса');
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF NOT is_log_info_empty(par_log_info)
      THEN
        DECLARE
          v_log_answer_info typ_log_info := par_log_info;
        BEGIN
          v_log_answer_info.operation_name := par_log_info.operation_name || '_error';
          log(par_log_info      => v_log_answer_info
             ,par_url           => par_url
             ,par_data          => NULL
             ,par_request_type  => NULL
             ,par_error_message => dbms_utility.format_error_stack
             ,par_backtrace     => dbms_utility.format_error_backtrace);
        END;
      END IF;
      RAISE;
  END http_request;

  FUNCTION request
  (
    par_url           VARCHAR2
   ,par_method        VARCHAR2 DEFAULT 'POST'
   ,par_send          CLOB DEFAULT NULL
   ,par_content_type  VARCHAR2 DEFAULT 'application/x-www-form-urlencoded'
   ,par_log_info      typ_log_info DEFAULT NULL
   ,par_add_headers        pkg_communication.tt_headers DEFAULT CAST(NULL AS
                                                                     pkg_communication.tt_headers)
   ,par_use_def_proxy BOOLEAN DEFAULT FALSE
   ,par_body_charset       VARCHAR2 DEFAULT NULL
  ) RETURN CLOB IS
    v_answer     CLOB;
    v_resp       utl_http.resp;
    v_answer_str VARCHAR2(32767);
  BEGIN
    -- Создаем временный CLOB
    dbms_lob.createtemporary(lob_loc => v_answer, cache => TRUE);
  
    http_request(par_url           => par_url
                ,par_method        => par_method
                ,par_send          => par_send
                ,par_content_type  => par_content_type
                ,par_log_info      => par_log_info
                ,par_add_headers   => par_add_headers
                ,par_use_def_proxy => par_use_def_proxy
                ,par_body_charset   => par_body_charset
                ,par_response_out  => v_resp);
  
    BEGIN
      LOOP
        utl_http.read_text(v_resp, v_answer_str, 32767);
        dbms_lob.writeappend(lob_loc => v_answer
                            ,amount  => length(v_answer_str)
                            ,buffer  => v_answer_str);
      END LOOP;
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        NULL;
    END;
  
    utl_http.end_response(v_resp);
  
    IF NOT is_log_info_empty(par_log_info)
    THEN
      DECLARE
        v_log_answer_info typ_log_info := par_log_info;
      BEGIN
        v_log_answer_info.operation_name := par_log_info.operation_name || '_answer';
        log(par_log_info => v_log_answer_info, par_data => v_answer, par_url => par_url);
      
      END;
    END IF;
  
    RETURN v_answer;
  END request;

  FUNCTION request_blob
  (
    par_url           VARCHAR2
   ,par_method        VARCHAR2 DEFAULT 'POST'
   ,par_send          CLOB DEFAULT NULL
   ,par_content_type  VARCHAR2 DEFAULT 'application/x-www-form-urlencoded'
   ,par_log_info      typ_log_info DEFAULT NULL
   ,par_add_headers   pkg_communication.tt_headers DEFAULT CAST(NULL AS pkg_communication.tt_headers)
   ,par_use_def_proxy BOOLEAN DEFAULT FALSE
   ,par_body_charset  VARCHAR2 DEFAULT NULL
  ) RETURN BLOB IS
    v_answer       BLOB;
    v_resp         utl_http.resp;
    v_content_type VARCHAR2(2000);
    v_answer_raw   RAW(512);
  BEGIN
    -- Создаем временный BLOB
    dbms_lob.createtemporary(lob_loc => v_answer, cache => TRUE);
  
    http_request(par_url           => par_url
                ,par_method        => par_method
                ,par_send          => par_send
                ,par_content_type  => par_content_type
                ,par_log_info      => par_log_info
                ,par_add_headers   => par_add_headers
                ,par_use_def_proxy => par_use_def_proxy
                ,par_body_charset  => par_body_charset
                ,par_response_out  => v_resp);
  
    -- Получение типа данных
    utl_http.get_header_by_name(r => v_resp, NAME => 'Content-Type', VALUE => v_content_type);
  
    IF v_content_type = 'application/octet-stream'
    THEN
      BEGIN
        LOOP
          utl_http.read_raw(v_resp, v_answer_raw);
          dbms_lob.append(dest_lob => v_answer, src_lob => v_answer_raw);
        END LOOP;
      EXCEPTION
        WHEN utl_http.end_of_body THEN
          NULL;
      END;
    ELSE
      v_answer := NULL;
    END IF;
  
    utl_http.end_response(v_resp);
  
    IF NOT is_log_info_empty(par_log_info)
    THEN
      DECLARE
        v_log_answer_info typ_log_info := par_log_info;
      BEGIN
        v_log_answer_info.operation_name := par_log_info.operation_name || '_answer';
        log(par_log_info => v_log_answer_info, par_data => NULL, par_url => par_url);
      
      END;
    END IF;
  
    RETURN v_answer;
  END request_blob;

  /** Процедура очищает лог коммуникаций. 
  *   Сделано по заявке 338061
  *   @autor Чирков В. Ю.
  *   @param par_clear_date_before - дата очистки лога. Лог очищается от данных старше 30
  *   дней от этой даты.
  */
  PROCEDURE clear_pkg_comm_log(par_clear_date_before DATE DEFAULT trunc(SYSDATE)) IS
  BEGIN
    DELETE FROM t_pkg_comm_log tmp WHERE par_clear_date_before - 30 > trunc(tmp.regdate);
  END clear_pkg_comm_log;

BEGIN
  -- Initialization
  SELECT ap.def_value_c INTO gv_wallet_path FROM app_param ap WHERE ap.brief = 'ORACLE_WALLET';
  SELECT ap.def_value_c INTO gv_proxy FROM app_param ap WHERE ap.brief = 'proxy';

  utl_http.set_wallet(path => 'file:' || gv_wallet_path);
  -- Включение генерации ошибок в get_response
  utl_http.set_response_error_check(TRUE);
  -- Включение детализации ошибок
  utl_http.set_detailed_excp_support(TRUE);
  -- Таймаут 15 минут
  utl_http.set_transfer_timeout(900);
END pkg_communication;
/
