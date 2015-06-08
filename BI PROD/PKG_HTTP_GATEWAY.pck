CREATE OR REPLACE PACKAGE pkg_http_gateway IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 20.12.2011 15:08:21
  -- Purpose : Для передачи данных в Borlas через http
  /*
    Капля П.
    Универсальная процедура обработки запроса из b2b
  */
  PROCEDURE gate_action(data VARCHAR2);
  /*
    Байтин А.
    Расчет и возврат в B2B выкупных сумм
  */
  PROCEDURE get_cash_surrender(data VARCHAR2);

  /*
    Байтин А.
    Возврат в B2B структуры агентского дерева на указанную дату
  */
  PROCEDURE get_agent_tree(data VARCHAR2);

  /*
    Байтин А.
    Для проверки работоспособности mod_plsql
  */
  PROCEDURE test_mod_plsql;

  /*
    Байтин А.
    Проверка пароля
  */
  PROCEDURE execute_cabinet_action
  (
    key       VARCHAR2
   ,operation VARCHAR2
   ,data      VARCHAR2
  );

  /*
    Байтин А.
    Заявка 235330
    Возвращает в систему обучения данные по агентам
  */
  PROCEDURE get_first_agn_sales;

  /*
    Байтин А.
    
    Получение данных mPos процессинга 2can
  */
  PROCEDURE process_2can_request(data VARCHAR2);

  PROCEDURE process_acquiring
  (
    key       VARCHAR2
   ,operation VARCHAR2
   ,data      VARCHAR2
  );

  /* 
    Доброхотова И., октябрь, 2014
    Процедура для обмена данными с Навигатором
    
    Заявка 365198: Передача информации о РОО в Навигатор
    operation = "get_departments"   
  */
  PROCEDURE process_navigator
  (
    key       VARCHAR2
   ,operation VARCHAR2
   ,data      VARCHAR2
  );
END pkg_http_gateway;
/
CREATE OR REPLACE PACKAGE BODY pkg_http_gateway IS

  gc_pkg_name CONSTANT VARCHAR2(255) := 'pkg_http_gateway';

  PROCEDURE raise_htp_error
  (
    par_message_body VARCHAR2
   ,par_log_info     pkg_communication.typ_log_info DEFAULT NULL
  ) IS
    v_answer    JSON := JSON();
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
  
    vr_log_info := par_log_info;
  
    IF vr_log_info.operation_name IS NOT NULL
    THEN
      vr_log_info.operation_name := vr_log_info.operation_name || '_error';
    END IF;
  
    ROLLBACK;
    v_answer.put('status', 'ERROR');
    v_answer.put('error_text', par_message_body);
    pkg_communication.htp_lob_response(par_lob      => v_answer.to_char(FALSE)
                                      ,par_log_info => vr_log_info);
  END raise_htp_error;

  /*
    Капля П.
    Универсальная процедура обработки запроса из b2b
  */
  PROCEDURE gate_action(data VARCHAR2) IS
    v_obj            JSON;
    v_oper           VARCHAR2(255);
    v_key            VARCHAR2(32);
    v_data           JSON;
    v_converted_json CLOB;
    vc_proc_name CONSTANT VARCHAR2(255) := 'gate_action';
    v_log_info pkg_communication.typ_log_info;
  BEGIN
    dbms_output.disable;
    /*    insert into ven_B2B_JSON_CALL_LOG (call_function_name,call_stack)
    values ('gate_action',dbms_utility.format_call_stack);
    commit;*/
  
    IF pkg_integration.gv_debug
    THEN
    
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := 'UNKNOWN';
    END IF;
  
    BEGIN
      v_obj := JSON(data);
    EXCEPTION
      WHEN OTHERS THEN
        DECLARE
          v_res_obj JSON := JSON();
        BEGIN
          pkg_communication.log(par_log_info     => v_log_info
                               ,par_data         => data
                               ,par_request_type => 'REQUEST');
        
          v_res_obj.put('status', pkg_integration.gc_status_error);
          v_res_obj.put('error_text', 'Невозможно разобрать JSON!');
          pkg_communication.htp_lob_response(par_json => v_res_obj);
          RETURN;
        END;
    END;
  
    BEGIN
      v_oper := v_obj.get('operation').get_string;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    IF pkg_integration.gv_debug
    THEN
      v_log_info.operation_name := nvl(v_oper, 'NULL');
      dbms_lob.createtemporary(lob_loc => v_converted_json, cache => TRUE);
      v_obj.to_clob(buf => v_converted_json, spaces => TRUE);
    
      pkg_communication.log(par_log_info     => v_log_info
                           ,par_data         => v_converted_json
                           ,par_request_type => 'REQUEST');
    
    END IF;
  
    IF v_oper IS NULL
       OR NOT v_obj.exist('key')
       OR v_obj.get('key').get_type != 'string'
    THEN
      DECLARE
        v_res_obj JSON;
      BEGIN
        v_res_obj := JSON();
        v_res_obj.put('code', 0);
        v_res_obj.put('error_text'
                     ,'Отсутствует полу operation или поле неверного типа.');
        pkg_communication.htp_lob_response(par_json => v_res_obj, par_log_info => v_log_info);
      END;
      RETURN;
    END IF;
  
    v_key := v_obj.get('key').get_string;
  
    BEGIN
      pkg_integration.set_current_external_system(par_key => v_key);
    EXCEPTION
      WHEN OTHERS THEN
        -- Тут вообще надо 404 ошибку вызывать.
        RAISE;
    END;
  
    IF v_obj.exist('data')
    THEN
      v_data := JSON(v_obj.get('data'));
    END IF;
  
    --safety.set_curr_role(p_role_name => 'Разработчик');
  
    CASE v_oper
      WHEN 'calculate_policy' THEN
        pkg_integration.calculate_policy(v_data);
      WHEN 'update_info' THEN
        pkg_integration.update_policy_info(v_data);
      WHEN 'get_policy_info' THEN
        pkg_integration.get_policy_info(v_data);
      WHEN 'delete_policy' THEN
        pkg_integration.delete_policy(v_data);
      WHEN 'print_policy' THEN
        pkg_integration.print_policy_doc(v_data);
      WHEN 'set_status' THEN
        pkg_integration.set_policy_status(v_data);
      WHEN 'print_empty_policies' THEN
        pkg_integration.print_empty_policies(v_data);
      WHEN 'print_policy_form' THEN
        pkg_integration.print_policy_form(v_data);
      WHEN 'get_file' THEN
        pkg_integration.get_file(v_data);
      WHEN 'send_message' THEN
        pkg_integration.send_message(v_data);
      ELSE
        DECLARE
          v_res_obj JSON := JSON();
        BEGIN
          v_res_obj.put('status', pkg_integration.gc_status_error);
          v_res_obj.put('error_text'
                       ,'Не удалось определить процедуру к исполнению');
          pkg_communication.htp_lob_response(par_json => v_res_obj, par_log_info => v_log_info);
        END;
    END CASE;
  
  END gate_action;

  /*
    Байтин А.
    Расчет и возврат в B2B выкупных сумм
  */
  PROCEDURE get_cash_surrender(data VARCHAR2) IS
    v_obj             JSON;
    v_birth_date      DATE;
    v_product_brief   t_product.brief%TYPE;
    v_gender          VARCHAR2(1);
    v_prog_sums       pkg_borlas_b2b.t_prog_sums;
    v_fund            fund.brief%TYPE;
    v_period          NUMBER;
    v_array           JSON_LIST;
    v_res_obj         JSON;
    v_base_sum        NUMBER;
    v_is_credit       BOOLEAN;
    v_ag_contract_num document.num%TYPE;
    vc_proc_name CONSTANT VARCHAR2(255) := 'GET_CASH_SURRENDER';
    v_log_info pkg_communication.typ_log_info;
  BEGIN
    dbms_output.disable;
  
    IF pkg_integration.gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := vc_proc_name;
      pkg_communication.log(par_log_info     => v_log_info
                           ,par_data         => data
                           ,par_request_type => 'REQUEST');
    END IF;
  
    BEGIN
      v_obj := JSON(data);
      pkg_borlas_b2b.log_json_call(v_obj, 'get_cash_surrender');
    EXCEPTION
      WHEN OTHERS THEN
        v_res_obj := JSON();
        v_res_obj.put('error_text', 'Невозможно разобрать JSON!');
        pkg_borlas_b2b.log_json_call(v_obj
                                    ,'get_cash_surrender_error'
                                    ,SQLERRM || ', ' || dbms_utility.format_error_backtrace);
        htp.prn(v_res_obj.to_char(FALSE));
        RETURN;
    END;
    v_birth_date    := to_date(v_obj.get('birth_date').get_string, 'dd.mm.yyyy');
    v_product_brief := v_obj.get('product').get_string;
    v_gender        := v_obj.get('gender').get_string;
    IF v_obj.exist('fund')
    THEN
      v_fund := v_obj.get('fund').get_string;
    END IF;
  
    IF v_obj.exist('policy_period')
    THEN
      v_period := v_obj.get('policy_period').get_number;
    END IF;
    IF v_obj.exist('ag_contract_num')
    THEN
      v_ag_contract_num := v_obj.get('ag_contract_num').get_string;
    END IF;
  
    IF v_obj.exist('base_sum')
    THEN
      v_base_sum := v_obj.get('base_sum').get_number;
    END IF;
    IF v_obj.exist('is_credit')
    THEN
      v_is_credit := v_obj.get('is_credit').get_number = 1;
    END IF;
  
    IF v_obj.exist('programs')
    THEN
      v_array := JSON_LIST(v_obj.get('programs'));
      FOR v_idx IN 1 .. v_array.count
      LOOP
        v_prog_sums(JSON(v_array.get(v_idx)).get('program_brief').get_string) := JSON(v_array.get(v_idx)).get('sum')
                                                                                 .get_number;
      END LOOP;
    END IF;
  
    pkg_borlas_b2b.get_cash_surrender(par_birth_date      => v_birth_date
                                     ,par_gender          => v_gender
                                     ,par_product         => v_product_brief
                                     ,par_fund            => v_fund
                                     ,par_period          => v_period
                                     ,par_prog_sums       => v_prog_sums
                                     ,par_ag_contract_num => v_ag_contract_num
                                     ,par_base_sum        => v_base_sum
                                     ,par_is_credit       => v_is_credit);
    dbms_output.enable;
  END get_cash_surrender;

  /*
    Байтин А.
    Возврат в B2B структуры агентского дерева на указанную дату
  */
  PROCEDURE get_agent_tree(data VARCHAR2) IS
    v_date VARCHAR2(30);
    v_obj  JSON;
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    vr_log_info.source_pkg_name       := 'pkg_http_gateway';
    vr_log_info.source_procedure_name := 'get_agent_tree';
    pkg_communication.log(par_log_info => vr_log_info, par_data => data);
  
    BEGIN
      v_obj := JSON(data);
      pkg_borlas_b2b.log_json_call(v_obj, 'get_agent_tree');
    EXCEPTION
      WHEN OTHERS THEN
        v_obj := JSON();
        v_obj.put('error_text', 'Невозможно разобрать JSON!');
        pkg_borlas_b2b.log_json_call(v_obj
                                    ,'get_agent_tree_error'
                                    ,SQLERRM || ', ' || dbms_utility.format_error_backtrace);
        htp.prn(v_obj.to_char(FALSE));
        RETURN;
    END;
    v_date := v_obj.get('par_date').get_string;
  
    pkg_borlas_b2b.get_agent_tree(par_date => to_date(v_date, 'dd.mm.yyyy'));
  END get_agent_tree;

  /*
    Байтин А.
    Для проверки работоспособности mod_plsql
  */
  PROCEDURE test_mod_plsql IS
  BEGIN
    htp.prn('MOD PL/SQL is good and ready!');
  END test_mod_plsql;

  /*
    Байтин А.
    Личный кабинет
  */
  PROCEDURE execute_cabinet_action
  (
    key       VARCHAR2
   ,operation VARCHAR2
   ,data      VARCHAR2
  ) IS
  
    wrong_key       EXCEPTION;
    wrong_operation EXCEPTION;
    no_data         EXCEPTION;
  
    c_proc_name CONSTANT VARCHAR2(30) := 'execute_cabinet_action';
    v_request   JSON;
    v_response  JSON;
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    vr_log_info.source_pkg_name       := gc_pkg_name;
    vr_log_info.source_procedure_name := c_proc_name;
    vr_log_info.operation_name        := operation;
    pkg_communication.log(par_log_info => vr_log_info, par_data => data);
  
    IF data IS NULL
    THEN
      RAISE no_data;
    END IF;
  
    IF NOT
        pkg_external_system.check_key_for_system(par_md5 => key, par_system_brief => 'PERSONAL_PROFILE')
    THEN
      RAISE wrong_key;
    END IF;
  
    CASE operation
      WHEN 'login' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_AUTHENTIFICATION')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.check_password(par_request => v_request, par_response => v_response);
      WHEN 'update' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_UPDATE')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.set_email_and_pass(par_request => v_request, par_response => v_response);
      WHEN 'reset_pass' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_PWD_RESET')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.reset_password(par_request => v_request, par_response => v_response);
      WHEN 'calc_demo' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_CALC_DEMO')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.calc_demo_policy(par_request => v_request, par_response => v_response);
      WHEN 'investor_change' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_INVESTOR_CHANGE')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.get_cabinet_cover(par_request => v_request, par_response => v_response);
      WHEN 'confirm_public_flags' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_CONFIRM_PFLAGS')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.confirm_public_flags(par_request  => v_request
                                                 ,par_response => v_response);
      WHEN 'confirm_names' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_CONFIRM_NAMES')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.confirm_names(par_request => v_request, par_response => v_response);
      WHEN 'confirm_documents' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_CONFIRM_DOCS')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.confirm_documents(par_request => v_request, par_response => v_response);
      WHEN 'confirm_address' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_CONFIRM_ADDRESSES')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.confirm_address(par_request => v_request, par_response => v_response);
      WHEN 'confirm_actuality' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_CONFIRM_ACTUALITY')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.confirm_actuality(par_request => v_request, par_response => v_response);
      WHEN 'get_all_data' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_GET_ALL_DATA')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.get_all_data(par_request => v_request, par_response => v_response);
      WHEN 'bso_check' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'PROFILE_BSO_CHECK')
                                           ,par_data      => data
                                           ,par_json      => v_request);
        pkg_personal_profile.bso_check(par_request => v_request, par_response => v_response);
      ELSE
        RAISE wrong_operation;
    END CASE;
    pkg_communication.htp_lob_response(par_json => v_response, par_log_info => vr_log_info);
  EXCEPTION
    WHEN no_data THEN
      raise_htp_error('Отсутствуют данные в data');
    WHEN wrong_operation THEN
      raise_htp_error('Операция не поддерживается');
    WHEN wrong_key THEN
      raise_htp_error('Ключ не поддерживается');
    WHEN pkg_exchange_format.cant_parse THEN
      raise_htp_error('Невозможно разобрать data');
    WHEN OTHERS THEN
      raise_htp_error(SQLERRM);
  END execute_cabinet_action;

  /*
    Байтин А.
    Заявка 235330
    Возвращает в систему обучения данные по агентам
  */
  PROCEDURE get_first_agn_sales IS
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    vr_log_info.source_pkg_name       := 'pkg_http_gateway';
    vr_log_info.source_procedure_name := 'get_first_agn_sales';
    pkg_communication.log(par_log_info => vr_log_info, par_data => NULL);
  
    pkg_learning_system.get_first_agn_sales;
  END get_first_agn_sales;

  /*
    Байтин А.
    
    Получение данных mPos процессинга 2can
  */
  PROCEDURE process_2can_request(data VARCHAR2) IS
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    vr_log_info.source_pkg_name       := 'pkg_http_gateway';
    vr_log_info.source_procedure_name := 'process_2can_request';
    pkg_communication.log(par_log_info => vr_log_info, par_data => data);
  
    pkg_mpos.process_2can_request(par_request => data, par_commit => TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      owa_util.status_line(400, 'error occured while processing data', FALSE);
      owa_util.mime_header('text/plain', TRUE, 'UTF8');
      htp.prn(dbms_utility.format_error_stack);
  END process_2can_request;

  PROCEDURE process_acquiring
  (
    key       VARCHAR2
   ,operation VARCHAR2
   ,data      VARCHAR2
  ) IS
    no_key            EXCEPTION;
    no_operation      EXCEPTION;
    no_data           EXCEPTION;
    wrong_key         EXCEPTION;
    wrong_operation   EXCEPTION;
    json_parser_error EXCEPTION;
    parse_error       EXCEPTION;
    PRAGMA EXCEPTION_INIT(json_parser_error, -20101);
  
    v_request  JSON;
    v_response JSON;
  
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    vr_log_info.source_pkg_name       := 'pkg_http_gateway';
    vr_log_info.source_procedure_name := 'process_acquiring';
    vr_log_info.operation_name        := operation;
    pkg_communication.log(par_log_info => vr_log_info, par_data => data);
  
    IF key IS NULL
    THEN
      RAISE no_key;
    END IF;
    IF operation IS NULL
    THEN
      RAISE no_operation;
    END IF;
    IF data IS NULL
    THEN
      RAISE no_data;
    END IF;
  
    v_request := JSON(data);
  
    IF NOT pkg_external_system.check_key_for_system(par_md5 => key, par_system_brief => 'ACQUIRING')
    THEN
      RAISE wrong_key;
    END IF;
  
    CASE operation
      WHEN 'policy_check' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'ACQ_PAYMENT_CHECK_REQUEST')
                                           ,par_json      => v_request);
        pkg_acquiring.check_payment(par_request => v_request, par_response => v_response);
      WHEN 'payment' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'ACQ_PAYMENT_NOTICE_REQUEST')
                                           ,par_json      => v_request);
        pkg_acquiring.process_payment(par_request => v_request, par_response => v_response);
      WHEN 'day_closing' THEN
        pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'ACQ_DAY_CLOSING_REQUEST')
                                           ,par_json      => v_request);
        pkg_acquiring.close_business_day(par_request => v_request, par_response => v_response);
      ELSE
        RAISE wrong_operation;
    END CASE;
    vr_log_info.operation_name := vr_log_info.operation_name || '_response';
    pkg_communication.htp_lob_response(par_lob      => v_response.to_char(FALSE)
                                      ,par_log_info => vr_log_info);
  
  EXCEPTION
    WHEN no_key THEN
      raise_htp_error(par_message_body => 'Не указано значение параметра key'
                     ,par_log_info     => vr_log_info);
    WHEN no_operation THEN
      raise_htp_error(par_message_body => 'Не указано значение параметра operation'
                     ,par_log_info     => vr_log_info);
    WHEN no_data THEN
      raise_htp_error(par_message_body => 'Не указано значение параметра data'
                     ,par_log_info     => vr_log_info);
    WHEN wrong_key THEN
      raise_htp_error(par_message_body => 'Неправильное значение key'
                     ,par_log_info     => vr_log_info);
    WHEN wrong_operation THEN
      raise_htp_error(par_message_body => 'Неправильное значение operation'
                     ,par_log_info     => vr_log_info);
    WHEN json_parser_error THEN
      raise_htp_error(par_message_body => 'Неправильный формат JSON'
                     ,par_log_info     => vr_log_info);
    WHEN pkg_exchange_format.no_element THEN
      raise_htp_error(par_message_body => SQLERRM, par_log_info => vr_log_info);
    WHEN OTHERS THEN
      raise_htp_error(par_message_body => SQLERRM, par_log_info => vr_log_info);
  END process_acquiring;

  /* 
    Доброхотова И., октябрь, 2014
    Процедура для обмена данными с Навигатором
    
    Заявка 365198: Передача информации о РОО в Навигатор
    operation = "get_departments"   
  */
  PROCEDURE process_navigator
  (
    key       VARCHAR2
   ,operation VARCHAR2
   ,data      VARCHAR2
  ) IS
    no_key            EXCEPTION;
    no_operation      EXCEPTION;
    no_data           EXCEPTION;
    wrong_key         EXCEPTION;
    wrong_operation   EXCEPTION;
    json_parser_error EXCEPTION;
    parse_error       EXCEPTION;
    PRAGMA EXCEPTION_INIT(json_parser_error, -20101);
  
    v_request  JSON;
    v_response JSON;
  
    vr_log_info pkg_communication.typ_log_info;
  BEGIN
    vr_log_info.source_pkg_name       := 'pkg_http_gateway';
    vr_log_info.source_procedure_name := 'process_navigator';
    vr_log_info.operation_name        := operation;
    pkg_communication.log(par_log_info => vr_log_info, par_data => data);
  
    IF key IS NULL
    THEN
      RAISE no_key;
    END IF;
    IF operation IS NULL
    THEN
      RAISE no_operation;
    END IF;
  
    IF data IS NOT NULL
    THEN
      v_request := JSON(data);
    ELSIF operation NOT IN ('get_departments', 'get_careers')
    THEN
      RAISE no_data;
    END IF;
  
    --    v_request := JSON(data);
  
    IF NOT pkg_external_system.check_key_for_system(par_md5 => key, par_system_brief => 'NAVIGATOR')
    THEN
      RAISE wrong_key;
    END IF;
  
    CASE operation
      WHEN 'get_departments' THEN
        --  если бы была заполнена data, ее надо проверить на соответствие формату
        --      pkg_exchange_format.validate_format(par_format_id => pkg_t_exchange_format_dml.get_id_by_brief(par_brief => 'ACQ_PAYMENT_CHECK_REQUEST')
        --                                           ,par_json      => v_request);        
        pkg_navigator.get_departments(par_response => v_response);
      WHEN 'get_careers' THEN
        pkg_navigator.get_careers(par_request => v_request, par_response => v_response);
      ELSE
        RAISE wrong_operation;
    END CASE;
    vr_log_info.operation_name := vr_log_info.operation_name || '_response';
    pkg_communication.htp_lob_response(par_json => v_response);
  EXCEPTION
    WHEN no_key THEN
      raise_htp_error(par_message_body => 'Не указано значение параметра key'
                     ,par_log_info     => vr_log_info);
    WHEN no_operation THEN
      raise_htp_error(par_message_body => 'Не указано значение параметра operation'
                     ,par_log_info     => vr_log_info);
    WHEN no_data THEN
      raise_htp_error(par_message_body => 'Не указано значение параметра data'
                     ,par_log_info     => vr_log_info);
    WHEN wrong_key THEN
      raise_htp_error(par_message_body => 'Неправильное значение key'
                     ,par_log_info     => vr_log_info);
    WHEN wrong_operation THEN
      raise_htp_error(par_message_body => 'Неправильное значение operation'
                     ,par_log_info     => vr_log_info);
    WHEN json_parser_error THEN
      raise_htp_error(par_message_body => 'Неправильный формат JSON'
                     ,par_log_info     => vr_log_info);
    WHEN pkg_exchange_format.no_element THEN
      raise_htp_error(par_message_body => SQLERRM, par_log_info => vr_log_info);
    WHEN OTHERS THEN
      raise_htp_error(par_message_body => SQLERRM, par_log_info => vr_log_info);
  END process_navigator;

END pkg_http_gateway;
/