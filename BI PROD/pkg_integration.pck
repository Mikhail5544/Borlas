CREATE OR REPLACE PACKAGE pkg_integration IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 02.08.2013 15:12:30
  -- Purpose : Новый механизм интеграции

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  gv_debug BOOLEAN;
  gc_status_keyword CONSTANT VARCHAR2(50) := 'status';
  gc_data_keyword   CONSTANT VARCHAR2(50) := 'data';
  gc_status_ok      CONSTANT VARCHAR2(50) := 'OK';
  gc_status_error   CONSTANT VARCHAR2(50) := 'ERROR';

  gc_b2b_api_url CONSTANT VARCHAR2(50) := 'B2B_API';
  gc_b2b_api_key CONSTANT VARCHAR2(50) := '18C84F0CCE4C57431EC573F91CCA6BD2';

  gc_report_code_policy       CONSTANT rep_report.code%TYPE := 'POLICY';
  gc_report_code_policyform   CONSTANT rep_report.code%TYPE := 'POLICYFORM';
  gc_report_code_empty_policy CONSTANT rep_report.code%TYPE := 'EMPTY_POLICY';

  TYPE tt_contacts IS TABLE OF g_contact%ROWTYPE;
  TYPE tt_beneficiaries IS TABLE OF g_beneficiary%ROWTYPE;
  TYPE tt_addresses IS TABLE OF g_address%ROWTYPE;
  TYPE tt_phones IS TABLE OF g_phone%ROWTYPE;
  TYPE tt_ident_docs IS TABLE OF g_ident_doc%ROWTYPE;
  TYPE tt_programs IS TABLE OF g_program%ROWTYPE;

  -- Установки текущей внешней системы
  PROCEDURE set_current_external_system(par_key VARCHAR2);

  /*
  Капля П.
  Создаем договор, используя информацию из шлюза
  */
  PROCEDURE create_policy_from_gate
  (
    par_g_policy_id      g_policy.g_policy_id%TYPE
   ,par_policy_header_id OUT p_pol_header.policy_header_id%TYPE
   ,par_policy_id        OUT p_policy.policy_id%TYPE
  );
  PROCEDURE calculate_policy(par_data_json JSON);

  /*
  Капля П.
  Заполняем инфу по договору страхования
  */
  PROCEDURE update_policy_info(par_data_json JSON);

  /*
  Капля П.
  Удаление неподтвержденных ДС
  */
  PROCEDURE delete_policy(par_data JSON);

  /*
  Капля П.
  Процедура получения текущих статусов для списка договоров
  */
  PROCEDURE get_policy_status(par_data JSON);

  /*
  Капля П.
  Процедура перевода статусов для ДС
  */
  PROCEDURE set_policy_status(par_data JSON);

  /*
  Капля П.
  Процедура печати ДС
  */
  PROCEDURE print_policy_doc(par_data JSON);

  /*
    Author  : PAVEL.KAPLYA
    Created : 18.04.2014 15:06:38
    Purpose : Печать незаполненных полисов
  */
  PROCEDURE print_empty_policies(par_data JSON);

  /*
    Капля П.
    Печать Полисных условий.
    На момент создания (05.05.2014) использовалась только для печати ПУ, 
    когда договора еще не существует. Необходимо для реализации полисов продукта FAMILY_PROETCTION для SGI    
  */
  PROCEDURE print_policy_form(par_data JSON);

  /*
  Капля П.
  Процедура снятия флага "Временный" с документов, телфонов, адресов и почтовых адресов контактов
  Продедура должна выполняться при подписании договора страхования
  */
  PROCEDURE confirm_contacts_info_on_sign(par_policy_id NUMBER);

  /*
    Капля П.
    Удаление договоров, находящихся в статус Ожидает подтверждения из В2В более 30 дней
  */
  PROCEDURE delete_unapproved_policies_job(par_date DATE DEFAULT SYSDATE);

  /*
  Мизинов Г.В.
  Пометка договора в шлюзовой таблице как удаленного при его отмене
  */

  PROCEDURE mark_canceled_policy_as_del(par_policy_id ins.p_policy.policy_id%TYPE);

  /*
    Пиядин А.
    Получение JSON по версии ДС (Версия + Страхователь + Застрахованные с программами, выгодоприобретателями и выкупными)
  */
  PROCEDURE get_policy_info(par_data_json JSON);

  /*
    Пиядин А.
    Процедура которая отправляет в B2B сигнал об изменении параметров договора
  */
  PROCEDURE refresh_policy_info(par_policy_id p_policy.policy_id%TYPE);

  /*
    Пиядин А.
    Процедура отправки файла в B2B
  */
  PROCEDURE get_file(par_data JSON);

  /*
    Пиядин А.
    Процедура получения сообщения из B2B
  */
  PROCEDURE send_message(par_data JSON);

END pkg_integration;
/
CREATE OR REPLACE PACKAGE BODY pkg_integration IS

  SUBTYPE t_json_field IS VARCHAR2(255);

  gc_pkg_name                 CONSTANT VARCHAR2(255) := 'PKG_INTEGRATION';
  gc_responsible_person_email CONSTANT VARCHAR2(255) := 'pavel.kaplya@renlife.com';

  -- Временный контакт Взрослый
  gc_default_birth_date CONSTANT DATE := ADD_MONTHS(trunc(SYSDATE, 'YEAR') + 1, -30 * 12);
  -- Временный контакт Ребенов
  gc_default_birth_date_child CONSTANT DATE := ADD_MONTHS(trunc(SYSDATE, 'YEAR') + 1, -12 * 12);
  gc_default_gender           CONSTANT VARCHAR2(1) := 'm';

  gv_current_external_system_id t_external_system.t_external_system_id%TYPE;

  /* Типы контактов в шлюзе */
  gc_insuree_contact_type CONSTANT g_contact.contact_type%TYPE := 0; -- Страхователь
  gc_assured_contact_type CONSTANT g_contact.contact_type%TYPE := 1; -- Застрахованный
  gc_benif_contact_type   CONSTANT g_contact.contact_type%TYPE := 2; -- Выгодоприобретатель

  /* Основные поля JSON'ов */
  gc_error_text_keyword CONSTANT t_json_field := 'error_text';
  gc_error_code_keyword CONSTANT t_json_field := 'error_code';

  --gv_debug BOOLEAN;
  gc_param_brief CONSTANT app_param.brief%TYPE := 'B2B_DELETE_UNSIGNED_POLICIES';

  b2b_borlas_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(b2b_borlas_error, -20001);

  -- Функция определения хобби по названию
  FUNCTION get_hobby(par_hobby_desc VARCHAR2) RETURN t_hobby.t_hobby_id%TYPE IS
    v_hobby_id t_hobby.t_hobby_id%TYPE;
  BEGIN
    IF par_hobby_desc IS NOT NULL
    THEN
      v_hobby_id := pkg_assured_query.get_hobby_by_desc(par_hobby_desc         => par_hobby_desc
                                                       ,par_raise_on_not_found => TRUE);
    END IF;
    RETURN v_hobby_id;
  END get_hobby;

  -- Функция определения группы профессий по брифу
  FUNCTION get_work_group(par_work_group_brief VARCHAR2) RETURN t_work_group.t_work_group_id%TYPE IS
    v_work_group_id t_work_group.t_work_group_id%TYPE;
  BEGIN
    IF par_work_group_brief IS NOT NULL
    THEN
      v_work_group_id := pkg_assured_query.get_work_group_by_brief(par_work_group_brief   => par_work_group_brief
                                                                  ,par_raise_on_not_found => TRUE);
    END IF;
    RETURN v_work_group_id;
  END get_work_group;

  -- Функция определения хобби по названию
  FUNCTION get_profession(par_profession_desc VARCHAR2) RETURN t_profession.id%TYPE IS
    v_professioin_id t_profession.id%TYPE;
  BEGIN
    IF par_profession_desc IS NOT NULL
    THEN
      v_professioin_id := pkg_assured_query.get_profession_by_desc(par_profession_desc    => par_profession_desc
                                                                  ,par_raise_on_not_found => TRUE);
    
    END IF;
    RETURN v_professioin_id;
  END get_profession;

  FUNCTION get_gate_record_by_ids
  (
    par_ids           NUMBER
   ,par_b2b_policy_id NUMBER DEFAULT NULL
  ) RETURN g_policy%ROWTYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_GATE_RECORD_BY_IDS';
    vr_policy g_policy%ROWTYPE;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => par_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => par_b2b_policy_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    BEGIN
      trace('Поиск записи в шлюзе среди не удаленных');
      SELECT p.*
        INTO vr_policy
        FROM g_policy p
       WHERE p.ids = par_ids
         AND nvl(p.is_deleted, 0) = 0
         AND (par_b2b_policy_id IS NULL OR p.policy_b2b_id = par_b2b_policy_id);
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          trace('Поиск записи в шлюзе среди удаленных');
          SELECT p.*
            INTO vr_policy
            FROM g_policy p
           WHERE p.note = par_ids
             AND p.is_deleted = 1
             AND p.policy_b2b_id = par_b2b_policy_id
             AND rownum = 1;
        
          raise_application_error(-20001
                                 ,'Договор был удален т.к. не был подтвержден в течение ' ||
                                  pkg_app_param.get_app_param_n(p_brief => gc_param_brief) ||
                                  ' дней.');
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось найти договор в шлюзе по ИДС');
        END;
      
    END;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name);
  
    RETURN vr_policy;
  
  EXCEPTION
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'Не удалось однозначно идентифицировать запись из шлюза');
  END get_gate_record_by_ids;

  -- Функция поиска договора страхования в шлюзе по IDS
  FUNCTION get_policy_from_gate_by_ids
  (
    par_ids           NUMBER
   ,par_b2b_policy_id NUMBER DEFAULT NULL
  ) RETURN p_pol_header.policy_header_id%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_POLICY_FROM_GATE_BY_IDS';
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  
  BEGIN
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => par_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => par_b2b_policy_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_pol_header_id := get_gate_record_by_ids(par_ids, par_b2b_policy_id).p_pol_header_id;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_pol_header_id);
  
    RETURN v_pol_header_id;
  
  END get_policy_from_gate_by_ids;

  -- Получение брифа продукта по договору
  FUNCTION get_product_brief(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN t_product.brief%TYPE IS
    v_product_brief t_product.brief%TYPE;
  BEGIN
    SELECT p.brief
      INTO v_product_brief
      FROM p_pol_header ph
          ,t_product    p
     WHERE ph.policy_header_id = par_policy_header_id
       AND ph.product_id = p.product_id;
  
    RETURN v_product_brief;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить продукта для договора');
  END get_product_brief;

  -- Функция отправки соощения об ошибке
  PROCEDURE error_response
  (
    par_proc_name      VARCHAR2
   ,par_operation_name VARCHAR2 DEFAULT NULL
   ,par_error_text     VARCHAR2 DEFAULT NULL
   ,par_error_code     VARCHAR2 DEFAULT NULL
  ) IS
    v_res_obj       JSON := JSON();
    v_error_text    VARCHAR2(4000);
    v_response_clob CLOB;
    v_log_info      pkg_communication.typ_log_info;
  BEGIN
    --v_res_obj.put('policy_id', vr_gt.policy_b2b_id);
    v_res_obj.put(gc_status_keyword, gc_status_error);
  
    v_error_text := regexp_replace(srcstr => nvl(par_error_text, SQLERRM), pattern => '^ORA-(\d){5}: ');
    v_res_obj.put(gc_error_text_keyword, 'Борлас: ' || v_error_text);
  
    IF par_error_code IS NOT NULL
    THEN
      v_res_obj.put(gc_error_code_keyword, par_error_code);
    END IF;
  
    IF gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := par_proc_name;
      v_log_info.operation_name        := upper(nvl(par_operation_name, par_proc_name)) || '_ERROR';
    END IF;
  
    dbms_lob.createtemporary(lob_loc => v_response_clob, cache => TRUE);
    v_res_obj.to_clob(v_response_clob);
    pkg_communication.htp_lob_response(par_lob => v_response_clob, par_log_info => v_log_info);
    dbms_lob.freetemporary(v_response_clob);
  
  END error_response;

  -- Проверка доступа к продукту по ключу внешней системы
  PROCEDURE check_access_by_product(par_product_brief t_product.brief%TYPE) IS
    v_found NUMBER(1);
  BEGIN
    SELECT COUNT(*)
      INTO v_found
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_product_ext_system t
                  ,t_product            p
             WHERE p.brief = par_product_brief
               AND p.product_id = t.product_id
               AND t.t_external_system_id = gv_current_external_system_id);
  
    IF v_found = 0
    THEN
      raise_application_error(-20001, 'Нет доступа');
    END IF;
  END check_access_by_product;

  --Проверка доступа к договору
  PROCEDURE check_access_to_policy(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
    v_product_brief t_product.brief%TYPE;
  BEGIN
    v_product_brief := get_product_brief(par_policy_header_id => par_pol_header_id);
    check_access_by_product(par_product_brief => v_product_brief);
  END check_access_to_policy;

  -- Функция определения контакта агента по номеру АД
  FUNCTION get_agent(par_ag_contact_num VARCHAR2) RETURN contact.contact_id%TYPE IS
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
  END get_agent;

  -- Установки текущей внешней системы
  PROCEDURE set_current_external_system(par_key VARCHAR2) IS
  BEGIN
    SELECT t.t_external_system_id
      INTO gv_current_external_system_id
      FROM t_external_system t
     WHERE pkg_utils.get_md5_string(t.pass_code) = upper(par_key);
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, 'Внешняя система не найдена');
  END set_current_external_system;

  PROCEDURE get_doc_properties_from_gate
  (
    par_g_policy_id g_policy.g_policy_id%TYPE
   ,par_properties  OUT pkg_doc_properties.tt_doc_property
  ) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_DOC_PROPERTIES_FROM_GATE';
    v_property_rec pkg_doc_properties.t_doc_property;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'par_g_policy_id'
                          ,par_trace_var_value => par_g_policy_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    par_properties := pkg_doc_properties.tt_doc_property();
  
    FOR rec IN (SELECT * FROM g_policy_property pp WHERE pp.g_policy_id = par_g_policy_id)
    LOOP
      pkg_trace.add_variable(par_trace_var_name  => 'rec.property_brief'
                            ,par_trace_var_value => rec.property_brief);
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => 'Добавление свойства');
    
      v_property_rec.property_type_brief := rec.property_brief;
      v_property_rec.value_char          := rec.value_char;
      v_property_rec.value_num           := rec.value_num;
      v_property_rec.value_date          := rec.value_date;
    
      par_properties.extend;
      par_properties(par_properties.last) := v_property_rec;
    END LOOP;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END get_doc_properties_from_gate;

  /*
    Капля П.
    Запись данных из B2B по полису в шлюзовую таблицу
  */
  FUNCTION save_policy_to_gate(par_data JSON) RETURN NUMBER IS
    TYPE tt_contacts IS TABLE OF ven_g_contact%ROWTYPE;
    TYPE tt_beneficiaries IS TABLE OF ven_g_beneficiary%ROWTYPE;
    TYPE tt_addresses IS TABLE OF ven_g_address%ROWTYPE;
    TYPE tt_phones IS TABLE OF ven_g_phone%ROWTYPE;
    TYPE tt_ident_docs IS TABLE OF ven_g_ident_doc%ROWTYPE;
    TYPE tt_programs IS TABLE OF ven_g_program%ROWTYPE;
    TYPE tt_properties IS TABLE OF g_policy_property%ROWTYPE;
    TYPE tt_citizenships IS TABLE OF g_contact_add_citizenship%ROWTYPE;
    TYPE tt_residencies IS TABLE OF g_contact_residency%ROWTYPE;
  
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'SAVE_POLICY_TO_GATE';
  
    v_policy JSON;
  
    v_contacts      tt_contacts := tt_contacts();
    v_beneficiaries tt_beneficiaries := tt_beneficiaries();
    v_addresses     tt_addresses := tt_addresses();
    v_phones        tt_phones := tt_phones();
    v_ident_docs    tt_ident_docs := tt_ident_docs();
    v_citizenthips  tt_citizenships := tt_citizenships();
    v_residencies   tt_residencies := tt_residencies();
    v_programs      tt_programs := tt_programs();
    v_properties    tt_properties := tt_properties();
  
    vr_pol_gate ven_g_policy%ROWTYPE;
  
    PROCEDURE put_json_value
    (
      par_data            JSON
     ,par_field           VARCHAR2
     ,par_value           IN OUT NUMBER
     ,par_disallow_change BOOLEAN DEFAULT TRUE
    ) IS
      v_new_value NUMBER;
    BEGIN
      IF par_data.exist(par_field)
      THEN
      
        v_new_value := par_data.get(par_field).get_number;
      
        IF par_value IS NOT NULL
           AND (v_new_value != par_value OR v_new_value IS NULL)
           AND par_disallow_change
        THEN
          vr_pol_gate.record_status := 1;
          IF vr_pol_gate.error_text IS NOT NULL
          THEN
            vr_pol_gate.error_text := vr_pol_gate.error_text || ' ';
          END IF;
          vr_pol_gate.error_text := vr_pol_gate.error_text || 'Значение поля ' || par_field ||
                                    ' отлично от имеющегося.';
        
        ELSE
          par_value := v_new_value;
        END IF;
      
      END IF;
    END put_json_value;
  
    PROCEDURE put_json_value
    (
      par_data            JSON
     ,par_field           VARCHAR2
     ,par_value           IN OUT VARCHAR2
     ,par_disallow_change BOOLEAN DEFAULT TRUE
    ) IS
      v_new_value VARCHAR2(4000);
    BEGIN
      IF par_data.exist(par_field)
      THEN
      
        v_new_value := TRIM(par_data.get(par_field).get_string);
      
        IF par_value IS NOT NULL
           AND (v_new_value != par_value OR v_new_value IS NULL)
           AND par_disallow_change
        THEN
          vr_pol_gate.record_status := 1;
          IF vr_pol_gate.error_text IS NOT NULL
          THEN
            vr_pol_gate.error_text := vr_pol_gate.error_text || ' ';
          END IF;
          vr_pol_gate.error_text := vr_pol_gate.error_text || 'Значение поля ' || par_field ||
                                    ' отлично от имеющегося.';
        ELSE
          par_value := v_new_value;
        END IF;
      
      END IF;
    END put_json_value;
  
    PROCEDURE put_json_value
    (
      par_data            JSON
     ,par_field           VARCHAR2
     ,par_value           IN OUT DATE
     ,par_disallow_change BOOLEAN DEFAULT TRUE
    ) IS
      v_new_value DATE;
    BEGIN
      IF par_data.exist(par_field)
      THEN
      
        v_new_value := par_data.get(par_field).get_date('dd.mm.yyyy');
      
        IF par_value IS NOT NULL
           AND (v_new_value != par_value OR v_new_value IS NULL)
           AND par_disallow_change
        THEN
          vr_pol_gate.record_status := 1;
          IF vr_pol_gate.error_text IS NOT NULL
          THEN
            vr_pol_gate.error_text := vr_pol_gate.error_text || ' ';
          END IF;
          vr_pol_gate.error_text := vr_pol_gate.error_text || 'Значение поля ' || par_field ||
                                    ' отлично от имеющегося.';
        ELSE
          par_value := v_new_value;
        END IF;
      
      END IF;
    END put_json_value;
  
    PROCEDURE process_person
    (
      par_person       JSON
     ,par_contact_type g_contact.contact_type%TYPE
    ) IS
      v_contact_rec ven_g_contact%ROWTYPE;
    BEGIN
    
      /*IF NOT par_person.exist('person_id')
      THEN
        raise_application_error(-20001, 'Отсутствует поле person_id');
      END IF;*/
    
      -- Записываем то, что было передано нам в JSON
      put_json_value(par_person, 'person_id', v_contact_rec.b2b_person_id);
      v_contact_rec.contact_type := par_contact_type;
      put_json_value(par_person, 'asset_id', v_contact_rec.as_asset_header_id);
    
      BEGIN
        SELECT *
          INTO v_contact_rec
          FROM ven_g_contact t
         WHERE t.g_policy_id = vr_pol_gate.g_policy_id
           AND t.contact_type = par_contact_type
           AND (t.as_asset_header_id = v_contact_rec.as_asset_header_id OR
               v_contact_rec.as_asset_header_id IS NULL);
        /*           AND (par_contact_type != gc_benif_contact_type OR t.as_asset_header_id = v_contact_rec.as_asset_header_id)*/
      EXCEPTION
        WHEN no_data_found THEN
          SELECT sq_g_contact.nextval INTO v_contact_rec.g_contact_id FROM dual;
          v_contact_rec.g_policy_id  := vr_pol_gate.g_policy_id;
          v_contact_rec.contact_type := par_contact_type;
      END;
    
      -- Повторно записываем инфу из JSON, чтобы довнести недостающие данные.
      put_json_value(par_person, 'person_id', v_contact_rec.b2b_person_id, FALSE);
      put_json_value(par_person, 'gender', v_contact_rec.gender, FALSE);
      put_json_value(par_person, 'birth_date', v_contact_rec.birth_date, FALSE);
      put_json_value(par_person, 'is_company', v_contact_rec.is_company, FALSE);
      put_json_value(par_person, 'work_group', v_contact_rec.work_group_brief, FALSE);
      put_json_value(par_person, 'profession', v_contact_rec.profession, FALSE);
      put_json_value(par_person, 'hobby', v_contact_rec.hobby, FALSE);
      put_json_value(par_person, 'is_foreign', v_contact_rec.is_foreign, FALSE);
      put_json_value(par_person, 'is_public', v_contact_rec.is_public, FALSE);
      put_json_value(par_person, 'is_rpdl', v_contact_rec.is_rpdl, FALSE);
      put_json_value(par_person, 'category_brief', v_contact_rec.insured_category_brief, FALSE);
      put_json_value(par_person, 'country_birth_alpha3', v_contact_rec.country_birth_alpha3, FALSE);
    
      put_json_value(par_person, 'surname', v_contact_rec.name, FALSE);
      put_json_value(par_person, 'company_name', v_contact_rec.company_name, FALSE);
      put_json_value(par_person, 'name', v_contact_rec.first_name, FALSE);
      put_json_value(par_person, 'midname', v_contact_rec.middle_name, FALSE);
      put_json_value(par_person, 'email', v_contact_rec.email, FALSE);
    
      put_json_value(par_person
                    ,'has_additional_citizenship'
                    ,v_contact_rec.has_additional_citizenship
                    ,FALSE);
      put_json_value(par_person, 'has_foreign_residency', v_contact_rec.has_foreign_residency, FALSE);
    
      IF par_contact_type = gc_assured_contact_type
      THEN
        put_json_value(par_person, 'insured_type', v_contact_rec.asset_type_brief, FALSE);
      END IF;
    
      -- Адреса
      IF par_person.exist('addresses')
      THEN
        DECLARE
          v_adr_index      PLS_INTEGER := v_addresses.count;
          v_addresses_json JSON_LIST := JSON_LIST(par_person.get('addresses'));
        BEGIN
          v_addresses.extend(v_addresses_json.count);
        
          FOR i IN 1 .. v_addresses_json.count
          LOOP
            DECLARE
              v_address_rec ven_g_address%ROWTYPE;
              v_adr         JSON := JSON(v_addresses_json.get(i));
            BEGIN
              SELECT sq_g_address.nextval INTO v_address_rec.g_address_id FROM dual;
              v_address_rec.g_contact_id := v_contact_rec.g_contact_id;
            
              put_json_value(v_adr, 'zip', v_address_rec.zip);
              put_json_value(v_adr, 'kladr_code', v_address_rec.kladr_code);
              put_json_value(v_adr, 'address', v_address_rec.address);
              put_json_value(v_adr, 'type', v_address_rec.address_type_brief);
            
              v_addresses(v_adr_index + i) := v_address_rec;
            END;
          END LOOP addresses;
        END;
      END IF;
      -- Паспорт
      IF par_person.exist('certificates')
      THEN
        DECLARE
          v_ident_docs_json_list JSON_LIST := JSON_LIST(par_person.get('certificates'));
          v_ident_doc_index      PLS_INTEGER := v_ident_docs.count;
        BEGIN
          v_ident_docs.extend(v_ident_docs_json_list.count);
        
          FOR i IN 1 .. v_ident_docs_json_list.count
          LOOP
            DECLARE
              v_ident_doc_rec  ven_g_ident_doc%ROWTYPE;
              v_ident_doc_json JSON := JSON(v_ident_docs_json_list.get(i));
            BEGIN
              SELECT sq_g_ident_doc.nextval INTO v_ident_doc_rec.g_ident_doc_id FROM dual;
              v_ident_doc_rec.g_contact_id := v_contact_rec.g_contact_id;
            
              put_json_value(v_ident_doc_json, 'ser', v_ident_doc_rec.series);
              put_json_value(v_ident_doc_json, 'num', v_ident_doc_rec.num);
              put_json_value(v_ident_doc_json, 'post', v_ident_doc_rec.who_posted);
              put_json_value(v_ident_doc_json, 'date', v_ident_doc_rec.when_posted);
              put_json_value(v_ident_doc_json, 'type', v_ident_doc_rec.doc_type_brief);
            
              v_ident_docs(v_ident_doc_index + i) := v_ident_doc_rec;
            END;
          
          END LOOP;
        END;
      END IF;
    
      -- Телефоны
      IF par_person.exist('phones')
      THEN
        DECLARE
          v_phn_index        PLS_INTEGER := v_phones.count;
          v_phones_json_list JSON_LIST := JSON_LIST(par_person.get('phones'));
        BEGIN
          v_phones.extend(v_phones_json_list.count);
        
          FOR p IN 1 .. v_phones_json_list.count
          LOOP
            DECLARE
              v_phone_rec ven_g_phone%ROWTYPE;
              v_phn       JSON := JSON(v_phones_json_list.get(p));
            BEGIN
              SELECT sq_g_phone.nextval INTO v_phone_rec.g_phone_id FROM dual;
              v_phone_rec.g_contact_id := v_contact_rec.g_contact_id;
            
              put_json_value(v_phn, 'num', v_phone_rec.phone_number);
              put_json_value(v_phn, 'type', v_phone_rec.phone_type_brief);
            
              v_phones(v_phn_index + p) := v_phone_rec;
            END;
          END LOOP phones;
        END;
      END IF;
    
      -- Дополнительные Гражданства
      IF par_person.exist('citizenships')
      THEN
        DECLARE
          v_citizenship_json_list JSON_LIST := JSON_LIST(par_person.get('citizenships'));
          v_citizenship_index     PLS_INTEGER := v_citizenthips.count;
        BEGIN
          v_citizenthips.extend(v_citizenship_json_list.count);
        
          FOR c IN 1 .. v_citizenship_json_list.count
          LOOP
            DECLARE
              v_cit_rec g_contact_add_citizenship%ROWTYPE;
            BEGIN
              SELECT sq_g_contact_add_citizenship.nextval INTO v_cit_rec.id FROM dual;
            
              v_cit_rec.g_contact_id   := v_contact_rec.g_contact_id;
              v_cit_rec.country_alpha3 := v_citizenship_json_list.get(c).get_string;
            
              v_citizenthips(v_citizenship_index + c) := v_cit_rec;
            END;
          END LOOP citizenships;
        END;
      END IF;
    
      -- Дополнительные Виды на жительства
      IF par_person.exist('residencies')
      THEN
        DECLARE
          v_residency_json_list JSON_LIST := JSON_LIST(par_person.get('residencies'));
          v_residency_index     PLS_INTEGER := v_residencies.count;
        BEGIN
          v_residencies.extend(v_residency_json_list.count);
        
          FOR r IN 1 .. v_residency_json_list.count
          LOOP
            DECLARE
              v_res_rec g_contact_residency%ROWTYPE;
            BEGIN
            
              SELECT sq_g_contact_residency.nextval INTO v_res_rec.id FROM dual;
            
              v_res_rec.g_contact_id   := v_contact_rec.g_contact_id;
              v_res_rec.country_alpha3 := v_residency_json_list.get(r).get_string;
            
              v_residencies(v_residency_index + r) := v_res_rec;
            END;
          END LOOP residencies;
        END;
      END IF;
    
      -- Программы контактов типа "Застрахованный"
      IF par_contact_type = gc_assured_contact_type
      THEN
        -- Застрахованный 
        IF par_person.exist('programs')
        THEN
          DECLARE
            v_programs_json_list JSON_LIST := JSON_LIST(par_person.get('programs'));
            v_programs_index     PLS_INTEGER := v_programs.count;
          BEGIN
            v_programs.extend(v_programs_json_list.count);
            FOR p IN 1 .. v_programs_json_list.count
            LOOP
              DECLARE
                v_prog     JSON := JSON(v_programs_json_list.get(p));
                v_prog_rec ven_g_program%ROWTYPE;
              BEGIN
                SELECT sq_g_program.nextval INTO v_prog_rec.g_program_id FROM dual;
                v_prog_rec.g_contact_id := v_contact_rec.g_contact_id;
              
                put_json_value(v_prog, 'program_brief', v_prog_rec.program_brief);
                put_json_value(v_prog, 'fee', v_prog_rec.fee);
                put_json_value(v_prog, 'ins_amount', v_prog_rec.ins_amount);
                put_json_value(v_prog, 'premia_base_type', v_prog_rec.premia_base_type);
                put_json_value(v_prog, 'proc', v_prog_rec.proc);
                v_programs(v_programs_index + p) := v_prog_rec;
              END;
            END LOOP;
          END;
        END IF;
      
        -- Выгодоприобретатели
        IF par_person.exist('assignees')
        THEN
          DECLARE
            v_bnf_json_list  JSON_LIST := JSON_LIST(par_person.get('assignees'));
            v_bnf_base_index PLS_INTEGER := v_beneficiaries.count;
          BEGIN
            v_beneficiaries.extend(v_bnf_json_list.count);
          
            FOR b IN 1 .. v_bnf_json_list.count
            LOOP
              DECLARE
                v_bnf_rec  ven_g_beneficiary%ROWTYPE;
                v_bnf_json JSON := JSON(v_bnf_json_list.get(b));
              BEGIN
              
                SELECT sq_g_beneficiary.nextval INTO v_bnf_rec.g_beneficiary_id FROM dual;
                v_bnf_rec.g_insured_contact_id := v_contact_rec.g_contact_id;
              
                put_json_value(v_bnf_json, 'related', v_bnf_rec.related_desc);
                put_json_value(v_bnf_json, 'share', v_bnf_rec.share_value);
                put_json_value(v_bnf_json, 'share_type_brief', v_bnf_rec.share_type_brief);
              
                process_person(v_bnf_json, gc_benif_contact_type);
              
                v_bnf_rec.g_benif_contact_id := v_contacts(v_contacts.last).g_contact_id;
              
                v_beneficiaries(v_bnf_base_index + b) := v_bnf_rec;
              
              END;
            END LOOP beneficiaries;
          END;
        END IF;
      
      END IF;
    
      v_contacts.extend(1);
      v_contacts(v_contacts.last) := v_contact_rec;
    
    END process_person;
  
    PROCEDURE construct_properties_array(par_properties JSON_LIST) IS
      v_property_json JSON;
      v_value         json_value;
    BEGIN
      FOR i IN 1 .. par_properties.count
      LOOP
        DECLARE
          v_property g_policy_property%ROWTYPE;
        BEGIN
          v_property_json := JSON(par_properties.get(i));
        
          assert_deprecated(NOT v_property_json.exist('property_brief')
                           ,'У элемента массива свойств договора отсутствует поле property_brief');
          assert_deprecated(NOT v_property_json.exist('value')
                           ,'У элемента массива свойств договора отсутствует поле value');
        
          v_property.g_policy_id := vr_pol_gate.g_policy_id;
          put_json_value(v_property_json, 'property_brief', v_property.property_brief);
        
          v_value := v_property_json.get('value');
          CASE v_value.get_type
            WHEN 'number' THEN
              v_property.value_num := v_value.get_number;
            WHEN 'string' THEN
              BEGIN
                v_property.value_date := to_date(v_value.get_string, 'dd.mm.yyyy');
              EXCEPTION
                WHEN OTHERS THEN
                  v_property.value_char := v_value.get_string;
              END;
          END CASE;
        
          v_properties.extend;
          v_properties(v_properties.last) := v_property;
        END;
      END LOOP;
    END construct_properties_array;
  BEGIN
  
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    SAVEPOINT before_write;
    -- Договор
    IF NOT par_data.exist('policy')
    THEN
      raise_application_error(-20001, 'Отсутствует блок policy');
    END IF;
  
    v_policy := JSON(par_data.get('policy'));
  
    IF v_policy.exist('ids')
    THEN
      BEGIN
      
        SELECT g.*
          INTO vr_pol_gate
          FROM ven_g_policy g
         WHERE g.ids = v_policy.get('ids').get_number
           AND nvl(g.is_deleted, 0) = 0;
      
        IF v_policy.exist('policy_id')
        THEN
          vr_pol_gate.policy_b2b_id := v_policy.get('policy_id').get_number;
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не удалось найти запись в шлюзе по ИДС');
          --SELECT sq_g_policy.nextval INTO vr_pol_gate.p_policy_gate_id FROM dual;
      END;
    ELSE
      SELECT sq_g_policy.nextval INTO vr_pol_gate.g_policy_id FROM dual;
    END IF;
  
    vr_pol_gate.record_status := 2;
    put_json_value(v_policy, 'product_brief', vr_pol_gate.product_brief);
  
    check_access_by_product(vr_pol_gate.product_brief);
  
    put_json_value(v_policy, 'ag_contract_num', vr_pol_gate.ag_contract_num);
    put_json_value(v_policy, 'fund', vr_pol_gate.fund_brief);
    put_json_value(v_policy, 'payment_terms', vr_pol_gate.payment_terms_brief);
    put_json_value(v_policy, 'policy_period', vr_pol_gate.policy_period);
    put_json_value(v_policy, 'bso_series', vr_pol_gate.bso_series);
    put_json_value(v_policy, 'first_payment_date', vr_pol_gate.first_payment_date);
    put_json_value(v_policy, 'base_sum', vr_pol_gate.base_sum);
    put_json_value(v_policy, 'is_credit', vr_pol_gate.is_credit);
    put_json_value(v_policy, 'discount_brief', vr_pol_gate.discount_brief);
    put_json_value(v_policy, 'credit_account_number', vr_pol_gate.credit_account_number);
    put_json_value(v_policy, 'policy_id', vr_pol_gate.policy_b2b_id);
    put_json_value(v_policy, 'bso_number', vr_pol_gate.bso_number);
  
    put_json_value(v_policy, 'start_date', vr_pol_gate.start_date, FALSE);
    put_json_value(v_policy, 'sign_date', vr_pol_gate.policy_sign_date, FALSE);
    put_json_value(v_policy, 'notice_date', vr_pol_gate.policy_notice_date, FALSE);
  
    put_json_value(v_policy, 'is_declaration_signed', vr_pol_gate.is_declaration_signed);
  
    IF v_policy.exist('additional_properties')
    THEN
      construct_properties_array(JSON_LIST(v_policy.get('additional_properties')));
    END IF;
  
    -- Данные по страхователю 
    IF par_data.exist('insuree')
       AND NOT par_data.get('insuree').is_null
    THEN
    
      process_person(JSON(par_data.get('insuree')), gc_insuree_contact_type);
    
    END IF;
    -- Данные по Застрахованным 
    IF par_data.exist('insured')
       AND NOT par_data.get('insured').is_null
    THEN
      DECLARE
        v_prs_json_list JSON_LIST := JSON_LIST(par_data.get('insured'));
      BEGIN
        --Очищаем всех выгодоприобретателей
        DELETE FROM g_contact c
         WHERE c.g_policy_id = vr_pol_gate.g_policy_id
           AND c.contact_type = gc_benif_contact_type;
      
        FOR i IN 1 .. v_prs_json_list.count
        LOOP
          process_person(JSON(v_prs_json_list.get(i)), gc_assured_contact_type);
        END LOOP;
      END;
    ELSE
      process_person(JSON(), gc_assured_contact_type);
    END IF;
  
    IF vr_pol_gate.p_pol_header_id IS NOT NULL
    THEN
      UPDATE g_policy g
         SET g.p_pol_header_id = vr_pol_gate.p_pol_header_id
            ,g.policy_b2b_id   = vr_pol_gate.policy_b2b_id
            ,g.product_brief   = vr_pol_gate.product_brief
            ,g.policy_num      = vr_pol_gate.policy_num
            ,g.ag_contract_num = vr_pol_gate.ag_contract_num
             --,g.receive_date        = vr_pol_gate.receive_date --doublecheck!
            ,g.policy_sign_date    = vr_pol_gate.policy_sign_date
            ,g.policy_notice_date  = vr_pol_gate.policy_notice_date
            ,g.error_text          = vr_pol_gate.error_text
            ,g.fund_brief          = vr_pol_gate.fund_brief
            ,g.policy_period       = vr_pol_gate.policy_period
            ,g.ids                 = vr_pol_gate.ids
            ,g.start_date          = vr_pol_gate.start_date
            ,g.first_payment_date  = vr_pol_gate.first_payment_date
            ,g.bso_series          = vr_pol_gate.bso_series
            ,g.note                = vr_pol_gate.note
            ,g.discount_brief      = vr_pol_gate.discount_brief
            ,g.payment_terms_brief = vr_pol_gate.payment_terms_brief
      --,g.policy_end_date          = vr_pol_gate.policy_end_date
       WHERE g.g_policy_id = vr_pol_gate.g_policy_id;
    ELSE
      vr_pol_gate.receive_date := SYSDATE;
      INSERT INTO ven_g_policy VALUES vr_pol_gate;
    END IF;
  
    IF v_contacts.count > 0
    THEN
      FOR i IN v_contacts.first .. v_contacts.last
      LOOP
        DECLARE
          v_count NUMBER;
        BEGIN
          SELECT COUNT(*)
            INTO v_count
            FROM dual
           WHERE EXISTS
           (SELECT NULL FROM g_contact c WHERE c.g_contact_id = v_contacts(i).g_contact_id);
          /*c.g_policy_id = vr_pol_gate.g_policy_id
          AND c.b2b_person_id = v_contacts(i).b2b_person_id*/
        
          IF v_count = 0
          THEN
            INSERT INTO ven_g_contact VALUES v_contacts (i);
          ELSE
            UPDATE g_contact c
               SET c.b2b_person_id              = v_contacts(i).b2b_person_id
                  ,c.name                       = v_contacts(i).name
                  ,c.first_name                 = v_contacts(i).first_name
                  ,c.middle_name                = v_contacts(i).middle_name
                  ,c.birth_date                 = v_contacts(i).birth_date
                  ,c.gender                     = v_contacts(i).gender
                  ,c.contact_type               = v_contacts(i).contact_type
                  ,c.is_company                 = v_contacts(i).is_company
                  ,c.work_group_brief           = v_contacts(i).work_group_brief
                  ,c.profession                 = v_contacts(i).profession
                  ,c.hobby                      = v_contacts(i).hobby
                  ,c.is_foreign                 = v_contacts(i).is_foreign
                  ,c.is_public                  = v_contacts(i).is_public
                  ,c.insured_category_brief     = v_contacts(i).insured_category_brief
                  ,c.email                      = v_contacts(i).email
                  ,c.country_birth_alpha3       = v_contacts(i).country_birth_alpha3
                  ,c.is_rpdl                    = v_contacts(i).is_rpdl
                  ,c.has_additional_citizenship = v_contacts(i).has_additional_citizenship
                  ,c.has_foreign_residency      = v_contacts(i).has_foreign_residency
             WHERE c.g_contact_id = v_contacts(i).g_contact_id;
          END IF;
        END;
      END LOOP;
    
      -- Добавляем программы только при первичном заведении договора. При дальнейшем обновлении инфы программы не изменяются.
      IF vr_pol_gate.p_pol_header_id IS NULL
         AND v_programs.count > 0
      THEN
        FORALL i IN v_programs.first .. v_programs.last
          INSERT INTO ven_g_program VALUES v_programs (i);
      END IF;
    
      DELETE FROM g_phone t
       WHERE t.g_contact_id IN
             (SELECT g_contact_id FROM g_contact c WHERE c.g_policy_id = vr_pol_gate.g_policy_id);
    
      DELETE FROM g_ident_doc t
       WHERE t.g_contact_id IN
             (SELECT g_contact_id FROM g_contact c WHERE c.g_policy_id = vr_pol_gate.g_policy_id);
    
      DELETE FROM g_beneficiary t
       WHERE t.g_insured_contact_id IN
             (SELECT g_contact_id FROM g_contact c WHERE c.g_policy_id = vr_pol_gate.g_policy_id);
    
      DELETE FROM g_address t
       WHERE t.g_contact_id IN
             (SELECT g_contact_id FROM g_contact c WHERE c.g_policy_id = vr_pol_gate.g_policy_id);
    
      DELETE FROM g_contact_add_citizenship t
       WHERE t.g_contact_id IN
             (SELECT g_contact_id FROM g_contact c WHERE c.g_policy_id = vr_pol_gate.g_policy_id);
    
      DELETE FROM g_contact_residency t
       WHERE t.g_contact_id IN
             (SELECT g_contact_id FROM g_contact c WHERE c.g_policy_id = vr_pol_gate.g_policy_id);
    
      IF v_phones.count > 0
      THEN
        FORALL i IN v_phones.first .. v_phones.last
          INSERT INTO ven_g_phone VALUES v_phones (i);
      END IF;
    
      IF v_ident_docs.count > 0
      THEN
        FORALL i IN v_ident_docs.first .. v_ident_docs.last
          INSERT INTO ven_g_ident_doc VALUES v_ident_docs (i);
      END IF;
    
      IF v_beneficiaries.count > 0
      THEN
        FORALL i IN v_beneficiaries.first .. v_beneficiaries.last
          INSERT INTO ven_g_beneficiary VALUES v_beneficiaries (i);
      END IF;
    
      IF v_addresses.count > 0
      THEN
        FORALL i IN v_addresses.first .. v_addresses.last
          INSERT INTO ven_g_address VALUES v_addresses (i);
      END IF;
    
      IF v_citizenthips.count > 0
      THEN
        FORALL i IN 1 .. v_citizenthips.count
          INSERT INTO g_contact_add_citizenship VALUES v_citizenthips (i);
      END IF;
    
      IF v_residencies.count > 0
      THEN
        FORALL i IN 1 .. v_residencies.count
          INSERT INTO g_contact_residency VALUES v_residencies (i);
      END IF;
    
      IF v_properties.count > 0
      THEN
        DELETE FROM g_policy_property gpp WHERE gpp.g_policy_id = vr_pol_gate.g_policy_id;
        FORALL i IN v_properties.first .. v_properties.last
          INSERT INTO g_policy_property VALUES v_properties (i);
      END IF;
    
    END IF;
  
    -- Очистка кэша
    v_contacts.delete;
    v_phones.delete;
    v_addresses.delete;
    v_ident_docs.delete;
    v_beneficiaries.delete;
    v_programs.delete;
    v_properties.delete;
    v_citizenthips.delete;
    v_residencies.delete;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => vr_pol_gate.g_policy_id);
  
    RETURN vr_pol_gate.g_policy_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_write;
      vr_pol_gate.error_text    := SQLERRM;
      vr_pol_gate.record_status := 1;
      IF vr_pol_gate.ids IS NOT NULL
      THEN
        UPDATE g_policy g
           SET g.error_text    = vr_pol_gate.error_text
              ,g.record_status = vr_pol_gate.record_status
         WHERE g_policy_id = vr_pol_gate.g_policy_id;
      ELSE
        INSERT INTO ven_g_policy VALUES vr_pol_gate;
      END IF;
      raise_application_error(-20001
                             ,'При обработке запроса и записи в шлюз произошла ошибка  ' ||
                              vr_pol_gate.error_text);
    
  END save_policy_to_gate;

  /*
  Капля П.
  Создаем договор, используя информацию из шлюза
  */
  PROCEDURE create_policy_from_gate
  (
    par_g_policy_id      g_policy.g_policy_id%TYPE
   ,par_policy_header_id OUT p_pol_header.policy_header_id%TYPE
   ,par_policy_id        OUT p_policy.policy_id%TYPE
  ) IS
    vc_proc_name      CONSTANT pkg_trace.t_object_name := 'CREATE_POLICY_FROM_GATE';
    vc_policy_comment CONSTANT p_policy.description%TYPE := 'Загружено из B2B.';
  
    TYPE t_policy_params IS RECORD(
       fund_id               fund.fund_id%TYPE
      ,period_id             t_period.id%TYPE
      ,payment_terms_id      t_payment_terms.id%TYPE
      ,bso_series_id         bso_series.bso_series_id%TYPE
      ,ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE
      ,notice_num            p_policy.notice_num%TYPE);
  
    v_assured_array       pkg_asset.t_assured_array;
    v_policy_params       t_policy_params;
    v_policy_values       pkg_products.t_product_defaults;
    v_policy_rec          g_policy%ROWTYPE;
    v_notice_num          p_policy.notice_num%TYPE;
    v_end_date            p_policy.end_date%TYPE;
    v_start_date          p_pol_header.start_date%TYPE;
    v_contact_id          contact.contact_id%TYPE;
    v_agent_id            ag_contract_header.agent_id%TYPE;
    v_insuree_contact_rec g_contact%ROWTYPE;
    v_policy_properties   pkg_doc_properties.tt_doc_property;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
    -- Функция создания временного контакта
    FUNCTION create_dummy_contact
    (
      par_birth_date        DATE
     ,par_gender            VARCHAR2
     ,par_unique_id         NUMBER
     ,par_contact_number    NUMBER
     ,par_is_company        NUMBER
     ,par_is_public_contact NUMBER
     ,par_is_rpdl           NUMBER
     ,par_is_foreign        NUMBER
    ) RETURN contact.contact_id%TYPE IS
      v_contact_id     contact.contact_id%TYPE;
      v_contact_object pkg_contact_object.t_person_object;
    BEGIN
      IF nvl(par_is_company, 0) = 0
      THEN
        v_contact_object.name          := 'Временный';
        v_contact_object.first_name    := 'Контакт';
        v_contact_object.middle_name   := par_unique_id || '-' || par_contact_number;
        v_contact_object.date_of_birth := par_birth_date;
        v_contact_object.gender        := par_gender;
        v_contact_object.note          := 'Временный контакт застрахованного для B2B.';
      
        v_contact_object.is_public_contact := par_is_public_contact;
        v_contact_object.is_rpdl           := par_is_rpdl;
        v_contact_object.resident_flag     := CASE nvl(par_is_foreign, 0)
                                                WHEN 1 THEN
                                                 0
                                                ELSE
                                                 1
                                              END;
      
        pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                ,par_contact_id => v_contact_id);
      ELSE
        v_contact_id := pkg_contact.create_company(par_name => 'Временный контакт ЮрЛица-' ||
                                                               par_unique_id || '-' ||
                                                               par_contact_number);
      END IF;
      RETURN v_contact_id;
    END create_dummy_contact;
  
    -- Функция заполнения массива застрахованных для передачи в универсальную процедуру создания договора
    FUNCTION create_assured_array RETURN pkg_asset.t_assured_array IS
      v_assured_array pkg_asset.t_assured_array := pkg_asset.t_assured_array();
    BEGIN
      FOR assured_cur IN (SELECT p.*
                                ,rownum rn
                                ,pp.credit_account_number
                            FROM g_contact p
                                ,g_policy  pp
                           WHERE p.g_policy_id = v_policy_rec.g_policy_id
                             AND p.g_policy_id = pp.g_policy_id
                             AND p.contact_type = gc_assured_contact_type)
      LOOP
        DECLARE
          v_assured_rec pkg_asset.t_assured_rec;
        BEGIN
          -- Создаем взрослого/ребенка в зависимости от типа застрахованного
          -- Для страхователя поле NULL
          IF assured_cur.asset_type_brief = 'ASSET_PERSON_CHILD'
          THEN
            v_assured_rec.contact_id := create_dummy_contact(par_birth_date        => nvl(assured_cur.birth_date
                                                                                         ,gc_default_birth_date_child)
                                                            ,par_gender            => nvl(assured_cur.gender
                                                                                         ,gc_default_gender)
                                                            ,par_unique_id         => v_policy_rec.g_policy_id
                                                            ,par_contact_number    => assured_cur.rn
                                                            ,par_is_company        => assured_cur.is_company
                                                            ,par_is_public_contact => assured_cur.is_public
                                                            ,par_is_rpdl           => assured_cur.is_rpdl
                                                            ,par_is_foreign        => assured_cur.is_foreign);
          ELSE
            v_assured_rec.contact_id := create_dummy_contact(par_birth_date        => nvl(assured_cur.birth_date
                                                                                         ,gc_default_birth_date)
                                                            ,par_gender            => nvl(assured_cur.gender
                                                                                         ,gc_default_gender)
                                                            ,par_unique_id         => v_policy_rec.g_policy_id
                                                            ,par_contact_number    => assured_cur.rn
                                                            ,par_is_company        => assured_cur.is_company
                                                            ,par_is_public_contact => assured_cur.is_public
                                                            ,par_is_rpdl           => assured_cur.is_rpdl
                                                            ,par_is_foreign        => assured_cur.is_foreign);
          END IF;
        
          -- Проставление флага "Резидент"
          UPDATE contact
             SET resident_flag = CASE nvl(assured_cur.is_foreign, 0)
                                   WHEN 1 THEN
                                    0
                                   ELSE
                                    1
                                 END
           WHERE contact_id = v_assured_rec.contact_id;
        
          -- Заполняем дополнительную инфу по контакту (для страхователя/застрахованного)
          v_assured_rec.assured_type_brief := nvl(assured_cur.asset_type_brief
                                                 ,v_assured_rec.assured_type_brief);
        
          v_assured_rec.hobby_id              := get_hobby(assured_cur.hobby);
          v_assured_rec.work_group_id         := get_work_group(assured_cur.work_group_brief);
          v_assured_rec.profession_id         := get_profession(assured_cur.profession);
          v_assured_rec.credit_account_number := assured_cur.credit_account_number;
          --v_assured_rec.category_id   := get_category(assured_cur.insured_category_brief);
        
          -- Собираем пассив информации о покрытиях
          FOR prg_cur IN (SELECT * FROM g_program p WHERE p.g_contact_id = assured_cur.g_contact_id)
          LOOP
            DECLARE
              v_cover_rec pkg_cover.t_cover_rec;
            BEGIN
              v_cover_rec.t_prod_line_opt_brief := prg_cur.program_brief;
              v_cover_rec.fee                   := prg_cur.fee;
              v_cover_rec.ins_amount            := prg_cur.ins_amount;
              v_cover_rec.premia_base_type      := prg_cur.premia_base_type;
              v_cover_rec.proc                  := prg_cur.proc;
            
              -- TODO: Доделать разбивку через поле prg_cur.proc
              IF v_assured_rec.cover_array IS NULL
              THEN
                v_assured_rec.cover_array := pkg_cover.t_cover_array(v_cover_rec);
              ELSE
                v_assured_rec.cover_array.extend(1);
                v_assured_rec.cover_array(v_assured_rec.cover_array.last) := v_cover_rec;
              END IF;
            END;
          END LOOP programs;
        
          UPDATE g_contact c
             SET c.borlas_contact_id = v_assured_rec.contact_id
           WHERE c.g_contact_id = assured_cur.g_contact_id;
        
          v_assured_array.extend(1);
          v_assured_array(v_assured_array.last) := v_assured_rec;
        END;
      END LOOP assured;
    
      IF v_assured_array.count > 0
      THEN
        RETURN v_assured_array;
      ELSE
        RETURN NULL;
      END IF;
    END create_assured_array;
  
    -- Функция определения серии БСО по номеру и ПУ
    FUNCTION get_bso_series_id
    (
      par_product_id NUMBER
     ,par_start_date DATE
     ,par_agent_id   NUMBER
    ) RETURN bso_series.bso_series_id%TYPE IS
      v_bso_series_id bso_series.bso_series_id%TYPE;
    BEGIN
      /*
      TODO: owner="Pazus" category="Optimize" priority="2 - Medium" created="29.09.2013"
      text="Заменить на реализация с использованием функции pkg_bso, после того как она будет установлена на PROD"
      */
      BEGIN
        SELECT bs.bso_series_id
          INTO v_bso_series_id
          FROM bso_series           bs
              ,t_policy_form        pf
              ,t_product_bso_types  pbt
              ,t_policyform_product pp
         WHERE pbt.bso_type_id = bs.bso_type_id
           AND pbt.t_product_id = par_product_id
           AND pp.t_product_id = pbt.t_product_id
           AND pp.t_policy_form_id = pf.t_policy_form_id
           AND trunc(par_start_date) BETWEEN pp.start_date AND pp.end_date
           AND (bs.t_product_conds_id IS NULL OR bs.t_product_conds_id = pf.t_policy_form_id);
      
      EXCEPTION
        WHEN too_many_rows THEN
          SELECT bs.bso_series_id
            INTO v_bso_series_id
            FROM bso_series           bs
                ,t_policy_form        pf
                ,t_product_bso_types  pbt
                ,t_policyform_product pp
           WHERE pbt.bso_type_id = bs.bso_type_id
             AND pbt.t_product_id = par_product_id
             AND pp.t_product_id = pbt.t_product_id
             AND pp.t_policy_form_id = pf.t_policy_form_id
             AND trunc(par_start_date) BETWEEN pp.start_date AND pp.end_date
             AND (bs.t_product_conds_id IS NULL OR bs.t_product_conds_id = pf.t_policy_form_id)
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
        raise_application_error(-20001
                               ,'Не удалось определить серию БСО по продукту и агенту.');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Не удалось однозначно определить серию БСО по продукту и агенту.');
    END;
  
    -- Функция определения переодичности оплаты по брифу
    FUNCTION get_payment_term
    (
      par_payment_term_brief VARCHAR2
     ,par_product_id         NUMBER
    ) RETURN t_payment_terms.id%TYPE IS
      v_payment_terms_id t_payment_terms.id%TYPE;
      v_exists           NUMBER(1);
    BEGIN
      IF par_payment_term_brief IS NOT NULL
      THEN
        v_payment_terms_id := dml_t_payment_terms.get_id_by_brief(par_payment_term_brief);
      
        SELECT COUNT(*)
          INTO v_exists
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM t_prod_payment_terms ppt
                 WHERE ppt.product_id = par_product_id
                   AND ppt.payment_term_id = v_payment_terms_id);
      
        IF v_exists = 0
        THEN
          ex.raise(par_message => 'Для данного продукта недоступна выбранная переодичность оплаты'
                  ,par_sqlcode => ex.c_no_data_found);
        END IF;
      END IF;
      RETURN v_payment_terms_id;
    END get_payment_term;
  
    -- Функция определения валюты по договору для продукта по брифу
    FUNCTION get_fund
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
        raise_application_error(-20001
                               ,'Для данного продукта недоступна выбранная валюта оплаты');
    END get_fund;
  
    -- Функция определения скидки по брифу
    FUNCTION get_discount(par_discount_brief VARCHAR2) RETURN discount_f.discount_f_id%TYPE IS
      v_discount_id discount_f.discount_f_id%TYPE;
    BEGIN
      IF par_discount_brief IS NOT NULL
      THEN
        BEGIN
          SELECT d.discount_f_id
            INTO v_discount_id
            FROM discount_f d
           WHERE d.brief = par_discount_brief;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось найти скидку с брифом "' || par_discount_brief ||
                                    '" в справочнике скидок');
        END;
      END IF;
      RETURN v_discount_id;
    END get_discount;
  
    PROCEDURE actualize_gate_record
    (
      par_g_policy_id g_policy.g_policy_id%TYPE
     ,par_policy_id   p_policy.policy_id%TYPE
    ) IS
      v_policy_rec g_policy%ROWTYPE;
    BEGIN
      SELECT pp.pol_num
            ,ph.policy_header_id
            ,ph.ids
        INTO v_policy_rec.policy_num
            ,v_policy_rec.p_pol_header_id
            ,v_policy_rec.ids
        FROM p_policy     pp
            ,p_pol_header ph
       WHERE pp.policy_id = par_policy_id
         AND ph.policy_header_id = pp.pol_header_id;
    
      UPDATE g_policy g
         SET g.p_pol_header_id = v_policy_rec.p_pol_header_id
            ,g.error_text      = NULL
            ,g.record_status   = 0
            ,g.ids             = v_policy_rec.ids
            ,g.policy_num      = v_policy_rec.policy_num
       WHERE g.g_policy_id = par_g_policy_id;
    
      FOR assured_rec IN (SELECT aa.p_asset_header_id
                                ,aas.assured_contact_id
                            FROM as_asset   aa
                                ,as_assured aas
                           WHERE aa.p_policy_id = par_policy_id
                             AND aa.as_asset_id = aas.as_assured_id)
      LOOP
        UPDATE g_contact c
           SET c.as_asset_header_id = assured_rec.p_asset_header_id
         WHERE c.g_policy_id = par_g_policy_id
           AND c.borlas_contact_id = assured_rec.assured_contact_id
           AND c.contact_type = gc_assured_contact_type;
      
        IF SQL%ROWCOUNT = 0
        THEN
          raise_application_error(-20001
                                 ,'Не удалось найти застрахованного в договоре для записи иденитфикатора в шлюз');
        END IF;
      END LOOP;
    END actualize_gate_record;
  
  BEGIN
    --Trace begin
    pkg_trace.add_variable(par_trace_var_name  => 'G_POLICY_ID'
                          ,par_trace_var_value => par_g_policy_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    BEGIN
      SELECT * INTO v_policy_rec FROM g_policy g WHERE g.g_policy_id = par_g_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось найти полис в шлюзе при заведении договора');
    END;
  
    pkg_trace.add_variable(par_trace_var_name  => 'PRODUCT_BRIEF'
                          ,par_trace_var_value => v_policy_rec.product_brief);
    pkg_trace.add_variable(par_trace_var_name  => 'AG_CONTRACT_NUM'
                          ,par_trace_var_value => v_policy_rec.ag_contract_num);
    pkg_trace.add_variable(par_trace_var_name  => 'BSO_SERIES'
                          ,par_trace_var_value => v_policy_rec.bso_series);
    pkg_trace.add_variable(par_trace_var_name  => 'START_DATE'
                          ,par_trace_var_value => v_policy_rec.start_date);
    pkg_trace.add_variable(par_trace_var_name  => 'FUND_BRIEF'
                          ,par_trace_var_value => v_policy_rec.fund_brief);
    pkg_trace.add_variable(par_trace_var_name  => 'POLICY_PERIOD'
                          ,par_trace_var_value => v_policy_rec.policy_period);
    pkg_trace.add_variable(par_trace_var_name  => 'BASE_SUM'
                          ,par_trace_var_value => v_policy_rec.base_sum);
    pkg_trace.add_variable(par_trace_var_name  => 'IS_CREDIT'
                          ,par_trace_var_value => v_policy_rec.is_credit);
    pkg_trace.add_variable(par_trace_var_name  => 'DISCOUNT_BRIEF'
                          ,par_trace_var_value => v_policy_rec.discount_brief);
    pkg_trace.add_variable(par_trace_var_name  => 'PAYMENT_TERMS_BRIEF'
                          ,par_trace_var_value => v_policy_rec.payment_terms_brief);
    trace('Обработка записи в шлюзе');
  
    -- Собираем параметры продукта по умолчанию
    trace('Определение настроек продукта по умолчанию');
    v_policy_values := pkg_products.get_product_defaults(par_product_brief => v_policy_rec.product_brief);
  
    -- Определяем дату начала договора
    v_start_date := coalesce(v_policy_rec.start_date
                            ,pkg_policy.get_start_date_by_conf_conds(par_product_id     => v_policy_values.product_id
                                                                    ,par_sign_date      => v_policy_rec.policy_sign_date
                                                                    ,par_first_pay_date => v_policy_rec.first_payment_date)
                            ,trunc(SYSDATE) + 1);
  
    -- Переопределяем параметры по умолчанию значениями из шлюза, если таковые есть.
    v_policy_params.fund_id          := nvl(get_fund(v_policy_rec.fund_brief
                                                    ,v_policy_values.product_id)
                                           ,v_policy_values.fund_id);
    v_policy_params.payment_terms_id := nvl(get_payment_term(v_policy_rec.payment_terms_brief
                                                            ,v_policy_values.product_id)
                                           ,v_policy_values.payment_term_id);
    v_agent_id                       := get_agent(v_policy_rec.ag_contract_num);
  
    IF v_policy_rec.bso_series IS NOT NULL
    THEN
      v_policy_params.bso_series_id := pkg_bso.get_bso_series_id(v_policy_rec.bso_series);
    ELSE
      v_policy_params.bso_series_id := get_bso_series_id(v_policy_values.product_id
                                                        ,v_start_date
                                                        ,v_agent_id);
    END IF;
  
    -- Генерируем номер договора
    IF v_policy_rec.bso_number IS NOT NULL
    THEN
      IF length(v_policy_rec.bso_number) IN (9, 10)
      THEN
        IF v_policy_rec.bso_series IS NOT NULL
           AND v_policy_rec.bso_series != substr(v_policy_rec.bso_number, 1, 3)
        THEN
          ex.raise(par_message => 'Конфликт серии БСО. В номере договора указана серия БСО отличная, от серии переданной в соответствующем поле'
                  ,par_sqlcode => ex.c_custom_error);
        END IF;
      
        v_policy_rec.bso_series       := substr(v_policy_rec.bso_number, 1, 3);
        v_policy_params.bso_series_id := pkg_bso.get_bso_series_id(v_policy_rec.bso_series);
        v_policy_params.notice_num    := substr(v_policy_rec.bso_number, 4, 6);
      ELSE
        v_policy_params.notice_num := v_policy_rec.bso_number;
      END IF;
    ELSE
      v_policy_params.notice_num := pkg_bso.gen_next_bso_number(v_policy_params.bso_series_id
                                                               ,v_agent_id);
    END IF;
  
    -- Определяем период страхования и дату окончания действия ДС
    IF v_policy_rec.policy_period IS NOT NULL
    THEN
      pkg_products.get_period_by_months_amount(par_product_id => v_policy_values.product_id
                                              ,par_months     => v_policy_rec.policy_period
                                              ,par_start_date => v_start_date
                                              ,par_end_date   => v_end_date --out param
                                              ,par_period_id  => v_policy_params.period_id); --out param
    END IF;
  
    -- Вытаскиываем инфу по страхователю из шлюза
    BEGIN
      SELECT *
        INTO v_insuree_contact_rec
        FROM g_contact c
       WHERE c.g_policy_id = v_policy_rec.g_policy_id
         AND c.contact_type = gc_insuree_contact_type; -- Страхователь
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько страхователей по договору!');
    END;
  
    -- Создаем временного страхователя
    trace('Создание временного контакта страхователя');
    v_insuree_contact_rec.borlas_contact_id := create_dummy_contact(par_birth_date        => nvl(v_insuree_contact_rec.birth_date
                                                                                                ,gc_default_birth_date)
                                                                   ,par_gender            => nvl(v_insuree_contact_rec.gender
                                                                                                ,gc_default_gender)
                                                                   ,par_unique_id         => v_policy_rec.g_policy_id
                                                                   ,par_contact_number    => 0
                                                                   ,par_is_company        => v_insuree_contact_rec.is_company
                                                                   ,par_is_public_contact => v_insuree_contact_rec.is_public
                                                                   ,par_is_rpdl           => v_insuree_contact_rec.is_rpdl
                                                                   ,par_is_foreign        => v_insuree_contact_rec.is_foreign);
  
    -- Собираем инфу о застрахованных и покрытиях из шлюза
    trace('Создание массива застрахованных и выгодоприобретателей');
    v_assured_array := create_assured_array;
  
    -- Собираем из шлюза свойства договора
    get_doc_properties_from_gate(par_g_policy_id => par_g_policy_id
                                ,par_properties  => v_policy_properties);
  
    -- Создаем договор
    trace('Создание договора страхования');
    pkg_policy.create_universal(par_product_brief      => v_policy_rec.product_brief
                               ,par_ag_num             => v_policy_rec.ag_contract_num
                               ,par_start_date         => v_start_date
                               ,par_insuree_contact_id => v_insuree_contact_rec.borlas_contact_id
                               ,par_ins_hobby_id       => get_hobby(v_insuree_contact_rec.hobby)
                               ,par_ins_work_group_id  => get_work_group(v_insuree_contact_rec.work_group_brief)
                               ,par_ins_profession_id  => get_profession(v_insuree_contact_rec.profession)
                               ,par_assured_array      => v_assured_array
                               ,par_end_date           => v_end_date
                               ,par_bso_number         => v_policy_params.notice_num
                               ,par_bso_series_id      => v_policy_params.bso_series_id
                               ,par_pol_num            => v_policy_params.notice_num
                               ,par_pol_ser            => v_policy_rec.bso_series
                               ,par_period_id          => v_policy_params.period_id
                               ,par_fund_id            => v_policy_params.fund_id
                               ,par_confirm_date       => v_policy_rec.policy_sign_date
                               ,par_notice_date        => v_policy_rec.policy_notice_date
                               ,par_sign_date          => v_policy_rec.policy_sign_date
                               ,par_payment_term_id    => v_policy_params.payment_terms_id
                               ,par_discount_f_id      => get_discount(v_policy_rec.discount_brief)
                               ,par_notice_num         => v_notice_num
                               ,par_comment            => vc_policy_comment
                               ,par_ph_comment         => vc_policy_comment
                               ,par_base_sum           => v_policy_rec.base_sum
                               ,par_is_credit          => v_policy_rec.is_credit
                               ,par_doc_properties     => v_policy_properties
                               ,par_policy_header_id   => par_policy_header_id
                               ,par_policy_id          => par_policy_id
                                --,par_waiting_period_id   =>
                                --,par_privilege_period_id =>
                                --,par_confirm_conds_id    => 
                                --,par_region_id           =>
                                );
  
    -- Переводим в статус "B2B рассчитан"
    trace('Перевод договора в статус "B2B рассчитан"');
    doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'B2B_CALCULATED');
  
    IF v_policy_rec.is_declaration_signed = 0
    THEN
      SAVEPOINT before_underwriting;
      trace('Перевод договора в статус "Нестандратный" (не подписана декларация)');
      doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'NONSTANDARD');
    ELSE
      BEGIN
        SAVEPOINT before_underwriting;
        trace('Перевод договора в статус "Ожидает подтверждения из B2B"');
        doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'B2B_PENDING');
      EXCEPTION
        WHEN OTHERS THEN
          trace('Ошибка перевода договора в статус "Ожидает подтверждения из B2B": ' || SQLERRM);
          ROLLBACK TO before_underwriting;
          doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'NONSTANDARD');
      END;
    END IF;
    -- Отражаем сделанные изменения в шлюзовой таблице
    trace('Отражаем сделанные изменения в шлюзовой таблице');
    actualize_gate_record(par_g_policy_id => v_policy_rec.g_policy_id, par_policy_id => par_policy_id);
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END create_policy_from_gate;

  /*
    Капля П.
    Процедура обрабатывает JSON, создает по нему договор и отсылает ответ во внешнюю систему
  */
  PROCEDURE calculate_policy(par_data_json JSON) IS
  
    vc_proc_name CONSTANT VARCHAR2(255) := 'CALCULATE_POLICY';
  
    v_g_policy_id      g_policy.g_policy_id%TYPE;
    v_policy_id        p_policy.policy_id%TYPE;
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
    v_policy_num       p_policy.pol_num%TYPE;
    v_ids              p_pol_header.ids%TYPE;
    v_status_brief     doc_status_ref.brief%TYPE;
    v_start_date       p_pol_header.start_date%TYPE;
    v_end_date         p_policy.end_date%TYPE;
    v_premium_sum      p_policy.premium%TYPE;
    v_ins_amount       p_policy.ins_amount%TYPE;
    v_total_fee        NUMBER;
  
    v_response     JSON := JSON();
    v_data         JSON := JSON();
    v_policy       JSON := JSON();
    v_insured_list JSON_LIST := JSON_LIST();
    v_log_info     pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    SAVEPOINT before_policy_insert;
  
    BEGIN
    
      -- Записываем данные в шлюз
      v_g_policy_id := save_policy_to_gate(par_data_json);
    
      -- Trace v_g_policy_id
      pkg_trace.add_variable(par_trace_var_name  => 'G_POLICY_ID'
                            ,par_trace_var_value => v_g_policy_id);
      trace('Договор сохранен в шлюзе');
    
      -- Обработка записи из шлюза
      create_policy_from_gate(par_g_policy_id      => v_g_policy_id
                             ,par_policy_header_id => v_policy_header_id
                             ,par_policy_id        => v_policy_id);
    
      -- Trace calculation done
      pkg_trace.add_variable(par_trace_var_name  => 'POLICY_HEADER_ID'
                            ,par_trace_var_value => v_policy_header_id);
      pkg_trace.add_variable(par_trace_var_name => 'POLICY_ID', par_trace_var_value => v_policy_id);
      trace('Договор рассчитан');
    
      /* Собираем ответ */
      BEGIN
      
        -- Собираем информацию по договору для формирования ответа
        SELECT pp.pol_num
              ,pp.premium
              ,ph.start_date
              ,trunc(pp.end_date)
              ,ph.ids
              ,doc.get_doc_status_brief(pp.policy_id)
              ,pp.ins_amount
              ,(SELECT nvl(SUM(aa.fee), 0) FROM as_asset aa WHERE aa.p_policy_id = pp.policy_id)
          INTO v_policy_num
              ,v_premium_sum
              ,v_start_date
              ,v_end_date
              ,v_ids
              ,v_status_brief
              ,v_ins_amount
              ,v_total_fee
          FROM p_policy     pp
              ,p_pol_header ph
         WHERE pp.policy_id = v_policy_id
           AND pp.pol_header_id = ph.policy_header_id;
      
        v_policy.put('ids', v_ids);
        v_policy.put('policy_header_id', v_policy_header_id);
        v_policy.put('status_brief', v_status_brief);
        v_policy.put('policy_num', v_policy_num);
        v_policy.put('total_premium', v_premium_sum);
        v_policy.put('total_fee', v_total_fee);
        v_policy.put('ins_amount', v_ins_amount);
        v_policy.put('start_date', v_start_date);
        v_policy.put('end_date', v_end_date);
        v_data.put('policy', v_policy);
      
        FOR vr_rec IN (SELECT at.brief asset_type_brief
                             ,aa.p_asset_header_id
                             ,aa.as_asset_id
                             ,aas.assured_contact_id
                             ,aa.ins_amount
                             ,aa.fee
                             ,aa.ins_premium
                         FROM as_asset       aa
                             ,as_assured     aas
                             ,p_asset_header ah
                             ,t_asset_type   at
                        WHERE aa.p_policy_id = v_policy_id
                          AND aa.p_asset_header_id = ah.p_asset_header_id
                          AND ah.t_asset_type_id = at.t_asset_type_id
                          AND aa.as_asset_id = aas.as_assured_id
                        ORDER BY aa.as_asset_id)
        LOOP
          DECLARE
            v_insured_json  JSON := JSON();
            v_programs_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR prg_rec IN (SELECT pl.description
                                  ,plo.brief
                                  ,plt.presentation_desc
                                  ,pc.fee fee
                                  ,pc.ins_amount ins_amount
                                  ,pc.premium premium
                                  ,trunc(pc.start_date) start_date
                                  ,trunc(pc.end_date) end_date
                              FROM p_cover             pc
                                  ,t_prod_line_option  plo
                                  ,t_product_line      pl
                                  ,t_product_line_type plt
                             WHERE pc.as_asset_id = vr_rec.as_asset_id
                               AND pc.t_prod_line_option_id = plo.id
                               AND plo.product_line_id = pl.id
                               AND pl.product_line_type_id = plt.product_line_type_id
                             ORDER BY plt.sort_order
                                     ,pl.sort_order)
            LOOP
              DECLARE
                v_program_json JSON := JSON();
              BEGIN
                v_program_json.put('program_name', prg_rec.description);
                v_program_json.put('program_brief', prg_rec.brief);
                v_program_json.put('program_type', prg_rec.presentation_desc);
                v_program_json.put('fee', prg_rec.fee);
                v_program_json.put('premium', prg_rec.premium);
                v_program_json.put('ins_amount', prg_rec.ins_amount);
                v_program_json.put('start_date', prg_rec.start_date);
                v_program_json.put('end_date', prg_rec.end_date);
                v_programs_list.append(v_program_json.to_json_value);
              END;
            
            END LOOP;
          
            IF v_programs_list.count = 0
            THEN
              raise_application_error(-20001
                                     ,'Не удалось сформировать список рисков по договору');
            END IF;
          
            v_insured_json.put('asset_id', vr_rec.p_asset_header_id);
            v_insured_json.put('insured_type', vr_rec.asset_type_brief);
            v_insured_json.put('fee', vr_rec.fee);
            v_insured_json.put('ins_amount', vr_rec.ins_amount);
            v_insured_json.put('premium', vr_rec.ins_premium);
            v_insured_json.put('programs', v_programs_list);
            v_insured_list.append(v_insured_json.to_json_value);
          
          END;
        END LOOP;
      
        v_data.put('insured', v_insured_list);
        v_response.put(gc_status_keyword, gc_status_ok);
        v_response.put(gc_data_keyword, v_data);
      
        IF gv_debug
        THEN
          v_log_info.source_pkg_name       := gc_pkg_name;
          v_log_info.source_procedure_name := vc_proc_name;
          v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
        END IF;
      
        -- Trace calculation done
        trace('Ответ сформирован');
      
        pkg_communication.htp_lob_response(par_json => v_response, par_log_info => v_log_info);
      
      EXCEPTION
        WHEN b2b_borlas_error THEN
          RAISE;
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'Ошибка подготовки и отправки ответного json в B2B (' || SQLERRM || ')');
      END;
    
      pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
    EXCEPTION
      WHEN OTHERS THEN
        trace('ОШИБКА: ' || SQLERRM);
        error_response(vc_proc_name);
        ROLLBACK TO before_policy_insert;
    END;
  END calculate_policy;

  /*
  Капля П.
  Заполняем инфу по договору страхования
  */
  PROCEDURE update_policy_info(par_data_json JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'UPDATE_POLICY_INFO';
  
    v_policy_gate_id   g_policy.g_policy_id%TYPE;
    v_policy_rec       g_policy%ROWTYPE;
    v_policy_id        p_policy.policy_id%TYPE;
    v_insuree_info_rec g_contact%ROWTYPE;
  
    v_contacts_to_delete t_number_type := t_number_type();
  
    v_properties pkg_doc_properties.tt_doc_property;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
    -- Процедура сохранения исходного состояния договора страхования
    PROCEDURE create_policy_savepoint IS
    BEGIN
      DELETE FROM tmp$_g_cover_info;
      INSERT INTO tmp$_g_cover_info
        (prod_line_option_brief
        ,fee
        ,ins_amount
        ,premium
        ,tariff
        ,loading
        ,tariff_netto
        ,coefs_product
        ,payment
        ,YEAR
        ,surr_sum_value
        ,asset_type_brief)
        SELECT prod_line_option_brief
              ,fee
              ,ins_amount
              ,premium
              ,tariff
              ,loading
              ,tariff_netto
              ,coefs_product
              ,payment
              ,YEAR
              ,surr_sum_value
              ,asset_type_brief
          FROM v_integration_policy_compare t
         WHERE t.policy_header_id = v_policy_rec.p_pol_header_id;
    
    END create_policy_savepoint;
  
    -- Процедура сравнения обновленного состояния договора страхования с исходным
    PROCEDURE compare_policy IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM ((SELECT prod_line_option_brief
                     ,fee
                     ,ins_amount
                     ,premium
                     ,tariff
                     ,loading
                     ,tariff_netto
                     ,coefs_product
                     ,payment
                     ,YEAR
                     ,surr_sum_value
                     ,asset_type_brief
                 FROM tmp$_g_cover_info
               MINUS
               SELECT prod_line_option_brief
                     ,fee
                     ,ins_amount
                     ,premium
                     ,tariff
                     ,loading
                     ,tariff_netto
                     ,coefs_product
                     ,payment
                     ,YEAR
                     ,surr_sum_value
                     ,asset_type_brief
                 FROM v_integration_policy_compare t
                WHERE t.policy_header_id = v_policy_rec.p_pol_header_id) UNION ALL
              (SELECT prod_line_option_brief
                     ,fee
                     ,ins_amount
                     ,premium
                     ,tariff
                     ,loading
                     ,tariff_netto
                     ,coefs_product
                     ,payment
                     ,YEAR
                     ,surr_sum_value
                     ,asset_type_brief
                 FROM v_integration_policy_compare t
                WHERE t.policy_header_id = v_policy_rec.p_pol_header_id
               MINUS
               SELECT prod_line_option_brief
                     ,fee
                     ,ins_amount
                     ,premium
                     ,tariff
                     ,loading
                     ,tariff_netto
                     ,coefs_product
                     ,payment
                     ,YEAR
                     ,surr_sum_value
                     ,asset_type_brief
                 FROM tmp$_g_cover_info));
    
      IF v_count > 0
      THEN
        raise_application_error(-20001
                               ,'Расчет договора изменился. Необходимо создать договора заново.');
      END IF;
    
    END compare_policy;
  
    -- Функция получения ИД типа документа (паспорта и тп)
    FUNCTION get_id_type_id(par_id_type_brief VARCHAR2) RETURN t_id_type.id%TYPE IS
      v_ident_doc_type_id t_id_type.id%TYPE;
    BEGIN
      BEGIN
        SELECT t.id INTO v_ident_doc_type_id FROM t_id_type t WHERE t.brief = par_id_type_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не удалось найти тип документа по брифу: ' || par_id_type_brief);
      END;
    
      RETURN v_ident_doc_type_id;
    END get_id_type_id;
  
    PROCEDURE clear_temp_contacts_and_data(par_g_policy_id g_contact.g_policy_id%TYPE) IS
      v_borlas_contact_id t_number_type;
    BEGIN
      SELECT c.borlas_contact_id
        BULK COLLECT
        INTO v_borlas_contact_id
        FROM g_contact c
       WHERE c.g_policy_id = par_g_policy_id;
    
      /*
      forall i in va_borlas_contact_id.first..va_borlas_contact_id.last 
      DELETE FROM cn_contact_ident cci
       WHERE cci.contact_id = va_borlas_contact_id(i)
         AND cci.is_temp = 1;
         */
    
      FORALL i IN v_borlas_contact_id.first .. v_borlas_contact_id.last
        DELETE FROM cn_contact_telephone cct
         WHERE cct.contact_id = v_borlas_contact_id(i)
           AND cct.is_temp = 1;
    
      FORALL i IN v_borlas_contact_id.first .. v_borlas_contact_id.last
        DELETE FROM cn_contact_address cca
         WHERE cca.contact_id = v_borlas_contact_id(i)
           AND cca.is_temp = 1;
    
      FORALL i IN v_borlas_contact_id.first .. v_borlas_contact_id.last
        DELETE FROM cn_contact_email cce
         WHERE cce.contact_id = v_borlas_contact_id(i)
           AND cce.is_temp = 1;
    
      UPDATE g_contact c SET c.borlas_contact_id = NULL WHERE c.g_policy_id = par_g_policy_id;
    
    END clear_temp_contacts_and_data;
  
    -- Функция обновления инфы о контакте исползуя запись из шлюза
    -- Поле borlas_contact_id обновляется в ходе выполнения функции
    -- Если старый контакт был временным или нигде не используется (испльзуем стандартную проверку из pkg_contact)
    -- то записываем contact_id такого контакта в буффер для последующего удаления
    PROCEDURE update_contact_info(par_contact_info IN OUT g_contact%ROWTYPE) IS
      v_new_contact_id contact.contact_id%TYPE;
      v_contact_object pkg_contact_object.t_person_object;
    BEGIN
      IF par_contact_info.is_company = 1
      THEN
        -- Простой поиск Юр.Лица.
        v_new_contact_id := pkg_contact.create_company(par_name => nvl(par_contact_info.company_name
                                                                      ,par_contact_info.name));
      ELSE
        /* Смотирм есть ли контакт с таким ФИО+ДР среди зконтакто из шлюза для этого договора.
        Если найдем - будем его использовать, это позволит не создавать пустых выгодоприобретателей например. */
        BEGIN
          SELECT c.borlas_contact_id
            INTO v_new_contact_id
            FROM g_contact c
           WHERE c.g_policy_id = par_contact_info.g_policy_id
             AND c.g_contact_id != par_contact_info.g_contact_id
             AND c.borlas_contact_id IS NOT NULL
             AND upper(c.name) = TRIM(upper(par_contact_info.name))
             AND upper(c.first_name) = TRIM(upper(par_contact_info.first_name))
             AND upper(c.middle_name) = TRIM(upper(par_contact_info.middle_name))
             AND c.birth_date = par_contact_info.birth_date
           GROUP BY c.borlas_contact_id;
        
          -- Если нашли - формируем объектное представление этого контакта
          BEGIN
            v_contact_object := pkg_contact_object.person_object_from_contact(v_new_contact_id);
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20001
                                     ,'Не удалось сформировать объектное представление контакта по ИД контакта: ' ||
                                      SQLERRM);
          END;
        EXCEPTION
          WHEN no_data_found
               OR too_many_rows THEN
            v_contact_object.name          := TRIM(par_contact_info.name);
            v_contact_object.first_name    := TRIM(par_contact_info.first_name);
            v_contact_object.middle_name   := TRIM(par_contact_info.middle_name);
            v_contact_object.date_of_birth := par_contact_info.birth_date;
            v_contact_object.gender        := par_contact_info.gender;
        END;
      
        v_contact_object.country_birth_alpha3       := nvl(par_contact_info.country_birth_alpha3
                                                          ,v_contact_object.country_birth_alpha3);
        v_contact_object.is_public_contact          := nvl(par_contact_info.is_public
                                                          ,v_contact_object.is_public_contact);
        v_contact_object.is_rpdl                    := nvl(par_contact_info.is_rpdl
                                                          ,v_contact_object.is_rpdl);
        v_contact_object.resident_flag              := nvl(CASE par_contact_info.is_foreign
                                                             WHEN 1 THEN
                                                              0
                                                             WHEN 0 THEN
                                                              1
                                                             ELSE
                                                              NULL
                                                           END
                                                          ,v_contact_object.resident_flag);
        v_contact_object.has_additional_citizenship := par_contact_info.has_additional_citizenship;
        v_contact_object.has_foreign_residency      := par_contact_info.has_foreign_residency;
      
        -- Создаем документы контакта из шлюза
        FOR ident_doc_cur IN (SELECT d.*
                                FROM g_ident_doc d
                               WHERE d.g_contact_id = par_contact_info.g_contact_id)
        LOOP
          DECLARE
            v_id_doc_rec pkg_contact_object.t_contact_id_doc_rec;
          BEGIN
            v_id_doc_rec.id_doc_type_brief := ident_doc_cur.doc_type_brief;
            v_id_doc_rec.id_value          := ident_doc_cur.num;
            v_id_doc_rec.series_nr         := ident_doc_cur.series;
            v_id_doc_rec.issue_date        := ident_doc_cur.when_posted;
            v_id_doc_rec.place_of_issue    := ident_doc_cur.who_posted;
            v_id_doc_rec.is_temp           := 1;
            v_id_doc_rec.is_used           := 1;
          
            pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                       ,par_id_doc_rec     => v_id_doc_rec);
          
          END;
        
        END LOOP;
      
        FOR phones_cur IN (SELECT *
                             FROM ins.g_phone ph
                            WHERE ph.g_contact_id = par_contact_info.g_contact_id
                              AND regexp_replace(ph.phone_number, '[^0-9]+') IS NOT NULL)
        LOOP
          DECLARE
            v_phone_rec pkg_contact_object.t_contact_phone_rec;
          BEGIN
            v_phone_rec.phone_type_brief := phones_cur.phone_type_brief;
            v_phone_rec.phone_number     := regexp_replace(phones_cur.phone_number, '[^0-9]+');
            v_phone_rec.status           := 1;
            v_phone_rec.is_temp          := 1;
          
            pkg_contact_object.add_phone_rec_to_object(par_contact_object => v_contact_object
                                                      ,par_phone_rec      => v_phone_rec);
          
          END;
        END LOOP;
      
        FOR address_cur IN (SELECT *
                              FROM ins.g_address ad
                             WHERE ad.g_contact_id = par_contact_info.g_contact_id
                               AND TRIM(ad.address) IS NOT NULL)
        LOOP
          DECLARE
            v_adderss_string VARCHAR2(4000);
            v_address_rec    pkg_contact_object.t_contact_address_rec;
          BEGIN
            IF address_cur.zip IS NOT NULL
            THEN
              v_adderss_string := address_cur.zip || ', ';
            END IF;
            v_adderss_string := v_adderss_string || address_cur.address;
          
            v_address_rec.address_type_brief := address_cur.address_type_brief;
            v_address_rec.address            := v_adderss_string;
            v_address_rec.is_temp            := 1;
          
            pkg_contact_object.add_address_rec_to_object(par_contact_object => v_contact_object
                                                        ,par_address_rec    => v_address_rec);
          END;
        
        END LOOP;
      
        IF TRIM(par_contact_info.email) IS NOT NULL
        THEN
          DECLARE
            v_email_rec pkg_contact_object.t_contact_email_rec;
            vc_default_email_type CONSTANT VARCHAR2(14) := 'Адрес рассылки';
          BEGIN
            v_email_rec.email_type_desc := vc_default_email_type;
            v_email_rec.email           := lower(par_contact_info.email);
            v_email_rec.status          := 1;
            v_email_rec.is_temp         := 1;
          
            pkg_contact_object.add_email_rec_to_object(par_contact_object => v_contact_object
                                                      ,par_email_rec      => v_email_rec);
          
          END;
        END IF;
      
        FOR rec_citizenship IN (SELECT t.country_alpha3
                                  FROM g_contact_add_citizenship t
                                 WHERE t.g_contact_id = par_contact_info.g_contact_id)
        LOOP
          DECLARE
            v_country pkg_contact_object.t_contact_country_rec;
          BEGIN
            v_country.country_alpha3 := rec_citizenship.country_alpha3;
            pkg_contact_object.add_additional_citizenship(par_contact_object  => v_contact_object
                                                         ,par_citizenship_rec => v_country);
          END;
        END LOOP citizenship;
      
        FOR rec_residency IN (SELECT t.country_alpha3
                                FROM g_contact_residency t
                               WHERE t.g_contact_id = par_contact_info.g_contact_id)
        LOOP
          DECLARE
            v_country pkg_contact_object.t_contact_country_rec;
          BEGIN
            v_country.country_alpha3 := rec_residency.country_alpha3;
            pkg_contact_object.add_residency_rec_to_object(par_contact_object => v_contact_object
                                                          ,par_residency_rec  => v_country);
          END;
        END LOOP residency;
      
        pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                                ,par_contact_id => v_new_contact_id);
      END IF;
    
      par_contact_info.borlas_contact_id := v_new_contact_id;
    
      UPDATE g_contact c
         SET c.borlas_contact_id = par_contact_info.borlas_contact_id
       WHERE c.g_contact_id = par_contact_info.g_contact_id;
    
    END update_contact_info;
  
    -- Процедура удаления контактов по ИД из буффера
    PROCEDURE delete_contacts_from_buffer IS
      v_contact_id NUMBER;
    BEGIN
      IF v_contacts_to_delete.count > 0
      THEN
        FOR i IN v_contacts_to_delete.first .. v_contacts_to_delete.last
        LOOP
          v_contact_id := v_contacts_to_delete(i);
          DECLARE
            v_deletable NUMBER := 0;
            v_msg       VARCHAR2(2000);
          BEGIN
            pkg_contact.prepare_for_delete(p_contact_id => v_contact_id
                                          ,p_res        => v_deletable
                                          ,p_mess       => v_msg);
            IF v_deletable = 1
            THEN
              DELETE FROM ven_contact c WHERE c.contact_id = v_contact_id;
            END IF;
          END;
        END LOOP;
      END IF;
    END delete_contacts_from_buffer;
  
    -- Процедура проверки неизменности числа и состава застрахованных по договору
    PROCEDURE check_assured_setup_changed
    (
      par_policy_id      p_policy.policy_id%TYPE
     ,par_gate_record_id g_policy.g_policy_id%TYPE
    ) IS
      vc_default_asset_type CONSTANT t_asset_type.brief%TYPE := 'ASSET_PERSON';
      v_change_detected NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_change_detected
        FROM dual
       WHERE EXISTS((SELECT c.as_asset_header_id
                           ,nvl(c.asset_type_brief, vc_default_asset_type) asset_type_brief
                       FROM g_contact c
                      WHERE c.contact_type = gc_assured_contact_type
                        AND c.g_policy_id = par_gate_record_id
                     MINUS
                     SELECT aa.p_asset_header_id
                           ,at.brief
                       FROM as_asset       aa
                           ,p_asset_header ah
                           ,t_asset_type   at
                      WHERE aa.p_policy_id = par_policy_id
                        AND aa.p_asset_header_id = ah.p_asset_header_id
                        AND ah.t_asset_type_id = at.t_asset_type_id) UNION ALL
                    (SELECT aa.p_asset_header_id
                           ,at.brief
                       FROM as_asset       aa
                           ,p_asset_header ah
                           ,t_asset_type   at
                      WHERE aa.p_policy_id = par_policy_id
                        AND aa.p_asset_header_id = ah.p_asset_header_id
                        AND ah.t_asset_type_id = at.t_asset_type_id
                     MINUS
                     SELECT c.as_asset_header_id
                           ,nvl(c.asset_type_brief, vc_default_asset_type) asset_type_brief
                       FROM g_contact c
                      WHERE c.contact_type = gc_assured_contact_type
                        AND c.g_policy_id = par_gate_record_id));
      IF v_change_detected > 0
      THEN
        raise_application_error(-20001
                               ,'Изменилось число и состав застрахованных');
      END IF;
    END check_assured_setup_changed;
  
    PROCEDURE clear_benificiaries(par_policy_id p_policy.policy_id%TYPE) IS
    BEGIN
    
      SELECT t.contact_id
        BULK COLLECT
        INTO v_contacts_to_delete
        FROM as_beneficiary t
            ,as_asset       aa
       WHERE t.as_asset_id = aa.as_asset_id
         AND aa.p_policy_id = par_policy_id;
    
      DELETE FROM ven_as_beneficiary t
       WHERE t.as_asset_id IN
             (SELECT aa.as_asset_id FROM as_asset aa WHERE aa.p_policy_id = par_policy_id);
    
    END clear_benificiaries;
  
    PROCEDURE change_insuree
    (
      par_policy_id        p_policy.policy_id%TYPE
     ,par_insuree_info_rec g_contact%ROWTYPE
    ) IS
      v_old_insuree_contact_id contact.contact_id%TYPE;
    BEGIN
    
      SELECT pi.contact_id
        INTO v_old_insuree_contact_id
        FROM v_pol_issuer pi
       WHERE pi.policy_id = par_policy_id;
    
      IF v_old_insuree_contact_id != par_insuree_info_rec.borlas_contact_id
      THEN
        v_contacts_to_delete.extend(1);
        v_contacts_to_delete(v_contacts_to_delete.last) := v_old_insuree_contact_id;
      END IF;
    
      -- Перевязываем версию на новый контакт
      UPDATE p_policy_contact pc
         SET pc.contact_id = par_insuree_info_rec.borlas_contact_id
       WHERE pc.policy_id = par_policy_id
         AND pc.contact_policy_role_id =
             (SELECT cpr.id FROM t_contact_pol_role cpr WHERE cpr.brief = 'Страхователь');
    
      -- Перевязываем контакт владельца на объектах ДС
      UPDATE as_asset aa
         SET aa.contact_id = par_insuree_info_rec.borlas_contact_id
       WHERE aa.p_policy_id = par_policy_id;
    
      -- Перевязываем контрагента на ЭПГ
      UPDATE ac_payment ap
         SET ap.contact_id = par_insuree_info_rec.borlas_contact_id
       WHERE ap.payment_id IN (SELECT dd.child_id FROM doc_doc dd WHERE dd.parent_id = par_policy_id);
    
      -- Заполняем дополнительную инфу по страхователю
      pkg_asset.create_insuree_info(p_pol_id        => par_policy_id
                                   ,p_work_group_id => get_work_group(par_insuree_info_rec.work_group_brief)
                                   ,p_hobby_id      => get_hobby(par_insuree_info_rec.hobby)
                                   ,p_profession_id => get_profession(par_insuree_info_rec.profession));
    
    END change_insuree;
  
    PROCEDURE change_assured
    (
      par_as_asset_id as_asset.as_asset_id%TYPE
     ,par_assured_rec g_contact%ROWTYPE
    ) IS
      v_old_assured_contact_id contact.contact_id%TYPE;
      v_profession_id          NUMBER;
      v_hobby_id               NUMBER;
      v_work_group_id          NUMBER;
    BEGIN
    
      SELECT aa.assured_contact_id
        INTO v_old_assured_contact_id
        FROM as_assured aa
       WHERE aa.as_assured_id = par_as_asset_id;
    
      IF v_old_assured_contact_id != par_assured_rec.borlas_contact_id
      THEN
        v_contacts_to_delete.extend(1);
        v_contacts_to_delete(v_contacts_to_delete.last) := v_old_assured_contact_id;
      END IF;
    
      v_profession_id := get_profession(par_assured_rec.profession);
      v_hobby_id      := get_hobby(par_assured_rec.hobby);
      v_work_group_id := get_work_group(par_assured_rec.work_group_brief);
    
      UPDATE as_assured aa
         SET aa.t_profession_id    = v_profession_id
            ,aa.t_hobby_id         = v_hobby_id
            ,aa.work_group_id      = v_work_group_id
            ,aa.assured_contact_id = par_assured_rec.borlas_contact_id
       WHERE aa.as_assured_id = par_as_asset_id;
    
    END change_assured;
  
  BEGIN
  
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    SAVEPOINT before_policy_insert;
  
    -- Загружаем информацию в шлюз
    v_policy_gate_id := save_policy_to_gate(par_data_json);
  
    -- Trace v_g_policy_id
    pkg_trace.add_variable(par_trace_var_name  => 'G_POLICY_ID'
                          ,par_trace_var_value => v_policy_gate_id);
    pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                   ,par_trace_subobj_name => vc_proc_name
                   ,par_message           => 'Договор сохранен в шлюзе');
  
    -- Получаем информацию по полису из шлюза
    BEGIN
      SELECT * INTO v_policy_rec FROM g_policy g WHERE g.g_policy_id = v_policy_gate_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось найти полис в шлюзе при заведении договора');
    END;
  
    v_policy_id := pkg_policy.get_curr_policy(p_pol_header_id => v_policy_rec.p_pol_header_id);
  
    -- Блокируем договор
    trace(par_message => 'Блокируем договор страхования на время обновления данных');
  
    pkg_policy.policy_lock(p_pol_id => v_policy_id);
  
    -- Создаем снимок договора (все его суммы, тарифы и выкупные)
    -- После того как изменим договор мы сравним получившиеся данные с исходными, чтобы проверить, чтоы расчет не изменился
    trace(par_message => 'Создаем слепок договора до изменений');
    create_policy_savepoint;
  
    -- Находим разницу в числе и составе застрахованных в вновьпереданных и исходных данных
    trace(par_message => 'Проверка произойдет ли в результате отработки процедуры изменение числа/состава застрахованных');
    check_assured_setup_changed(par_policy_id      => v_policy_id
                               ,par_gate_record_id => v_policy_rec.g_policy_id);
  
    -- Удаляем адреса, телефоны и почту с флагом "временный" контактов договора
    trace(par_message => 'Очистка временных данных контактов');
    clear_temp_contacts_and_data(par_g_policy_id => v_policy_rec.g_policy_id);
  
    -- Очищаем список имеющихся выгодоприобретателей по договору
    -- Вызов этой операции нельзя переносить ниже первого обращения к v_contacts_to_delete
    trace(par_message => 'Очистка набора выгодоприобретателей');
    clear_benificiaries(par_policy_id => v_policy_id);
  
    -- Очистка свойств договора
    trace(par_message => 'Очистка свойств договора');
    pkg_doc_properties.delete_doc_properties(par_document_id => v_policy_id);
  
    trace(par_message => 'Добавление свойств договора');
    get_doc_properties_from_gate(par_g_policy_id => v_policy_rec.g_policy_id
                                ,par_properties  => v_properties);
    pkg_doc_properties.add_properties_to_document(par_document_id        => v_policy_id
                                                 ,par_doc_property_array => v_properties);
  
    -- Собираем инфу по страхователю из шлюза  
    SELECT *
      INTO v_insuree_info_rec
      FROM g_contact c
     WHERE c.g_policy_id = v_policy_rec.g_policy_id
       AND c.contact_type = gc_insuree_contact_type;
  
    --Обновляем данные контакта страхователя
    trace(par_message => 'Обновление данных страхователя');
    update_contact_info(v_insuree_info_rec);
    change_insuree(par_policy_id => v_policy_id, par_insuree_info_rec => v_insuree_info_rec);
  
    -- обрабатываем список застрахованных
    FOR asset_cur IN (SELECT aa.as_asset_id
                            ,aa.p_asset_header_id
                            ,aas.assured_contact_id
                        FROM as_asset   aa
                            ,as_assured aas
                       WHERE aa.p_policy_id = v_policy_id
                         AND aa.as_asset_id = aas.as_assured_id)
    LOOP
      DECLARE
        v_contact_rec g_contact%ROWTYPE;
      BEGIN
        -- Берем инфу по застрахованному из шлюза
        BEGIN
          SELECT *
            INTO v_contact_rec
            FROM g_contact c
           WHERE c.as_asset_header_id = asset_cur.p_asset_header_id
             AND c.contact_type = gc_assured_contact_type
             AND c.g_policy_id = v_policy_rec.g_policy_id;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Для застрахованного в договоре нет соответствующей записи в шлюзе. Необходимо создать договор заново.');
        END;
      
        -- Обновляем данные контакта
        pkg_trace.add_variable(par_trace_var_name  => 'ASSURED_NAME'
                              ,par_trace_var_value => TRIM(v_contact_rec.name ||
                                                           v_contact_rec.first_name ||
                                                           v_contact_rec.middle_name));
        trace(par_message => 'Обновление данных застрахованного');
        update_contact_info(v_contact_rec);
        -- Обновляем данные застрахованного в договоре
        change_assured(par_as_asset_id => asset_cur.as_asset_id, par_assured_rec => v_contact_rec);
      
        -- Добавляем выгодоприобретателей
        FOR benif_cur IN (SELECT b.*
                            FROM g_contact     c
                                ,g_beneficiary b
                           WHERE c.g_contact_id = b.g_benif_contact_id
                             AND b.g_insured_contact_id = v_contact_rec.g_contact_id)
        LOOP
          DECLARE
            v_befen_contact_rec g_contact%ROWTYPE;
            v_beneficiary_id    NUMBER;
          BEGIN
          
            -- Выбираем инфу по выгодоприобретателю из шлюза
            SELECT *
              INTO v_befen_contact_rec
              FROM g_contact c
             WHERE c.g_contact_id = benif_cur.g_benif_contact_id
               AND c.contact_type = gc_benif_contact_type;
          
            -- Обновляем инфу в соответствие с записью в шлюзе
            pkg_trace.add_variable(par_trace_var_name  => 'ASSURED_NAME'
                                  ,par_trace_var_value => TRIM(v_contact_rec.name ||
                                                               v_contact_rec.first_name ||
                                                               v_contact_rec.middle_name));
            pkg_trace.add_variable(par_trace_var_name  => 'BENIFICIARY_NAME'
                                  ,par_trace_var_value => TRIM(v_befen_contact_rec.name ||
                                                               v_befen_contact_rec.first_name ||
                                                               v_befen_contact_rec.middle_name));
            trace(par_message => 'Добавление выгодоприобретателя');
            update_contact_info(v_befen_contact_rec);
          
            pkg_asset.add_beneficiary(par_asset_id          => asset_cur.as_asset_id
                                     ,par_contact_id        => v_befen_contact_rec.borlas_contact_id
                                     ,par_value             => benif_cur.share_value
                                     ,par_value_type_brief  => nvl(benif_cur.share_type_brief
                                                                  ,'percent') -- Заготовка на будущее
                                     ,par_contact_rel_brief => benif_cur.related_desc
                                     ,par_beneficiary_id    => v_beneficiary_id);
          
          END;
        END LOOP;
      
      END;
    
    END LOOP;
  
    -- Обновляем дату начала договора страхования
    UPDATE p_policy pp
       SET pp.start_date     = v_policy_rec.start_date
          ,pp.sign_date      = nvl(v_policy_rec.policy_sign_date, v_policy_rec.start_date)
          ,pp.first_pay_date = nvl(v_policy_rec.first_payment_date, v_policy_rec.start_date)
     WHERE pp.policy_id = v_policy_id;
  
    UPDATE p_pol_header ph
       SET ph.start_date = v_policy_rec.start_date
     WHERE ph.policy_header_id = v_policy_rec.p_pol_header_id;
  
    -- Пересчитываем договор
    trace('Пересчет договора страхования');
    pkg_policy.update_policy_dates(p_pol_id => v_policy_id);
  
    -- Сравниваем с исходным состоянием договора
    -- сли изменились параметры покрытий или выкупные суммы - выдаем ошибку  
    trace('Сравнение расчитанного договора с исходным слепком');
    compare_policy;
  
    -- Удаляем временные контакты из буффера
    delete_contacts_from_buffer;
  
    -- Делаем повторную проверку корректности договора
    trace('Контроль по продукту и контроль по покрытию по обновленному договору');
    pkg_products_control.policy_control_exc_underwr(v_policy_id);
    pkg_cover_control.policy_cover_ctrl_exc_underwr(v_policy_id);
  
    -- Собираем ответ
    trace('Формирование ответа на запрос на обновление данных контакто по договору');
    DECLARE
      v_response      JSON := JSON();
      v_insuree       JSON := JSON();
      v_data          JSON := JSON();
      v_insured_list  JSON_LIST := JSON_LIST();
      v_response_clob CLOB;
      v_log_info      pkg_communication.typ_log_info;
    BEGIN
      v_insuree.put('person_id', v_insuree_info_rec.b2b_person_id);
      v_insuree.put('borlas_contact_id', v_insuree_info_rec.borlas_contact_id);
      v_data.put('insuree', v_insuree);
    
      FOR asset_rec IN (SELECT c.b2b_person_id
                              ,c.borlas_contact_id
                              ,c.g_contact_id
                              ,c.as_asset_header_id
                          FROM g_contact c
                         WHERE c.g_policy_id = v_policy_rec.g_policy_id
                           AND c.contact_type = gc_assured_contact_type)
      LOOP
        DECLARE
          v_insured    JSON := JSON();
          v_benen_list JSON_LIST := JSON_LIST();
        BEGIN
          v_insured.put('person_id', asset_rec.b2b_person_id);
          v_insured.put('borlas_contact_id', asset_rec.borlas_contact_id);
          v_insured.put('asset_id', asset_rec.as_asset_header_id);
        
          FOR ben_rec IN (SELECT c.b2b_person_id
                                ,c.borlas_contact_id
                            FROM g_contact     c
                                ,g_beneficiary b
                           WHERE c.g_contact_id = b.g_benif_contact_id
                             AND b.g_insured_contact_id = asset_rec.g_contact_id)
          LOOP
            DECLARE
              v_benef JSON := JSON();
            BEGIN
              v_benef.put('person_id', ben_rec.b2b_person_id);
              v_benef.put('borlas_contact_id', ben_rec.borlas_contact_id);
              v_benen_list.append(v_benef.to_json_value);
            
            END;
          END LOOP;
        
          IF v_benen_list.count > 0
          THEN
            v_insured.put('assignees', v_benen_list);
          END IF;
        
          v_insured_list.append(v_insured.to_json_value);
        
        END;
      
      END LOOP;
    
      v_data.put('insured', v_insured_list);
      v_response.put(gc_status_keyword, gc_status_ok);
      v_response.put(gc_data_keyword, v_data);
    
      dbms_lob.createtemporary(lob_loc => v_response_clob, cache => TRUE);
      v_response.to_clob(v_response_clob);
    
      IF gv_debug
      THEN
        v_log_info.source_pkg_name       := gc_pkg_name;
        v_log_info.source_procedure_name := vc_proc_name;
        v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
      END IF;
    
      pkg_communication.htp_lob_response(par_lob => v_response_clob, par_log_info => v_log_info);
    END;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
      ROLLBACK TO before_policy_insert;
  END update_policy_info;

  /*
  Капля П.
  Удаление неподтвержденных ДС
  */
  PROCEDURE delete_policy(par_pol_header_id NUMBER) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'DELETE_POLICY';
    v_policy_id           p_pol_header.policy_id%TYPE;
    v_ids                 p_pol_header.ids%TYPE;
    v_policy_status_brief doc_status_ref.brief%TYPE;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    SELECT ids INTO v_ids FROM p_pol_header ph WHERE ph.policy_header_id = par_pol_header_id;
  
    v_policy_id := pkg_policy.get_last_version(p_pol_header_id => par_pol_header_id);
  
    -- Удаляем временные и отменяем действующие договора
    -- Темповые данные контактов (с флагом is_temp) не удаляем - контакт может использоваться в других договорах
    v_policy_status_brief := doc.get_last_doc_status_brief(v_policy_id);
  
    pkg_trace.add_variable(par_trace_var_name => 'POLICY_ID', par_trace_var_value => v_policy_id);
    pkg_trace.add_variable(par_trace_var_name  => 'POLICY_STATUS_BRIEF'
                          ,par_trace_var_value => v_policy_status_brief);
    trace('Проверка текущего статуса версии ДС');
  
    IF v_policy_status_brief IN ('B2B_CALCULATED', 'B2B_PENDING')
    THEN
      BEGIN
        trace('Удаление ДС');
        SAVEPOINT before_delete;
        pkg_bso.unlink_bso_policy(p_pol_header_id => par_pol_header_id);
      
        UPDATE g_policy p
           SET p.note          = to_char(v_ids)
              ,p.ids           = NULL
              ,p.record_status = 3
              ,p.is_deleted    = 1
         WHERE p.p_pol_header_id = par_pol_header_id;
      
        pkg_policy.delete_policy_now(par_policy_header_id => par_pol_header_id);
      EXCEPTION
        WHEN OTHERS THEN
          trace('Не удалось удалить, откатываем и пытаемся отменить ДС');
          ROLLBACK TO before_delete;
          doc.set_doc_status(v_policy_id, 'CANCEL');
      END;
    
    ELSE
      trace('Отмена ДС');
      doc.set_doc_status(v_policy_id, 'CANCEL');
    END IF;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  END delete_policy;

  /*
  Капля П.
  Удаление неподтвержденных ДС
  */
  PROCEDURE delete_policy(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'DELETE_POLICY';
  
    v_ids           NUMBER;
    v_b2b_policy_id NUMBER;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  
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
  
    v_ids := par_data.get('ids').get_number;
    IF par_data.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data.get('policy_id').get_number;
    END IF;
  
    -- Ищем договор в шлюзе   
    pkg_trace.add_variable(par_trace_var_name => 'IDS_FROM_JSON', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
    trace('Поиск договора в шлюзе');
  
    v_pol_header_id := get_policy_from_gate_by_ids(par_ids           => v_ids
                                                  ,par_b2b_policy_id => v_b2b_policy_id);
  
    -- Проверка прав доступа к договору для данной внешней системы
    check_access_to_policy(par_pol_header_id => v_pol_header_id);
  
    delete_policy(par_pol_header_id => v_pol_header_id);
  
    trace('Формирование ответа на запрос на удаление');
    DECLARE
      v_response      JSON := JSON();
      v_response_clob CLOB;
      v_log_info      pkg_communication.typ_log_info;
    BEGIN
    
      v_response.put(gc_status_keyword, gc_status_ok);
      v_response.put(gc_data_keyword, JSON());
    
      -- Формируем ответ
      dbms_lob.createtemporary(lob_loc => v_response_clob, cache => TRUE);
    
      v_response.to_clob(v_response_clob);
    
      IF gv_debug
      THEN
        v_log_info.source_pkg_name       := gc_pkg_name;
        v_log_info.source_procedure_name := vc_proc_name;
        v_log_info.operation_name        := upper(vc_proc_name) || '_RESPONSE';
      END IF;
    
      pkg_communication.htp_lob_response(par_lob => v_response_clob, par_log_info => v_log_info);
    END;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
      ROLLBACK;
  END delete_policy;

  /*
  Капля П.
  Процедура получения текущих статусов для списка договоров
  */
  PROCEDURE get_policy_status(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_POLICY_STATUS';
  
    v_ids           NUMBER;
    v_b2b_policy_id NUMBER;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
    v_policy_id     p_policy.policy_id%TYPE;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  BEGIN
  
    -- Trace end
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    v_ids := par_data.get('ids').get_string;
    IF par_data.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data.get('policy_id').get_number;
    END IF;
  
    -- Ищем договор в шлюзе   
    pkg_trace.add_variable(par_trace_var_name => 'IDS_FROM_JSON', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
    trace('Поиск договора в шлюзе');
  
    v_pol_header_id := get_policy_from_gate_by_ids(par_ids           => v_ids
                                                  ,par_b2b_policy_id => v_b2b_policy_id);
  
    check_access_to_policy(par_pol_header_id => v_pol_header_id);
  
    v_policy_id := pkg_policy.get_curr_policy(p_pol_header_id => v_pol_header_id);
  
    DECLARE
      v_response JSON := JSON();
      v_log_info pkg_communication.typ_log_info;
    BEGIN
      v_response.put('status_name', doc.get_doc_status_name(v_policy_id));
      v_response.put('status_brief', doc.get_doc_status_brief(v_policy_id));
    
      IF gv_debug
      THEN
        v_log_info.source_pkg_name := gc_pkg_name;
      
        v_log_info.source_procedure_name := vc_proc_name;
        v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
      END IF;
    
      pkg_communication.htp_lob_response(par_json => v_response, par_log_info => v_log_info);
    END;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
      ROLLBACK;
  END get_policy_status;

  /* 
    Капля П.
    Функция маппинга статусов В2В и статусов Борлас
    Необходимо реализовать нехардкодную реализацию
  */
  FUNCTION get_mapped_status_brief
  (
    par_policy_header_id      NUMBER
   ,par_original_status_brief VARCHAR2
  ) RETURN doc_status_ref.brief%TYPE IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_MAPPED_STATUS_BRIEF';
    v_mapped_status_brief   doc_status_ref.brief%TYPE;
    v_product_brief         t_product.brief%TYPE;
    v_original_status_breif doc_status_ref.brief%TYPE;
  
    FUNCTION get_product_brief_by_pol_head(par_policy_header_id NUMBER) RETURN t_product.brief%TYPE IS
      v_product_brief t_product.brief%TYPE;
    BEGIN
      SELECT p.brief
        INTO v_product_brief
        FROM t_product    p
            ,p_pol_header ph
       WHERE ph.policy_header_id = par_policy_header_id
         AND ph.product_id = p.product_id;
      RETURN v_product_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить продукт по заголовку договора страхования');
    END get_product_brief_by_pol_head;
  BEGIN
  
    -- Trace begin
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_product_brief := get_product_brief_by_pol_head(par_policy_header_id => par_policy_header_id);
  
    v_original_status_breif := CASE par_original_status_brief
                                 WHEN 'PASSED_TO_AGENT' THEN
                                  'SIGNED'
                                 ELSE
                                  par_original_status_brief
                               END;
  
    IF v_original_status_breif = 'SIGNED'
    THEN
    
      IF pkg_product_category.is_product_in_category(par_product_brief       => v_product_brief
                                                    ,par_category_type_brief => 'INTEGRATION_SIGNED_STATUS'
                                                    ,par_category_brief      => 'WAITING_FOR_PAYMENT')
      THEN
        v_mapped_status_brief := 'WAITING_FOR_PAYMENT';
      ELSE
        v_mapped_status_brief := 'PASSED_TO_AGENT';
      END IF;
    ELSE
      v_mapped_status_brief := v_original_status_breif;
    END IF;
  
    -- Trace end
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_mapped_status_brief);
  
    RETURN v_mapped_status_brief;
  END get_mapped_status_brief;

  /*
  Капля П.
  Процедура перевода статусов для ДС
  */
  PROCEDURE set_policy_status(par_data JSON) IS
  
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'SET_POLICY_STATUS';
  
    v_ids                 NUMBER;
    v_b2b_policy_id       NUMBER;
    v_status_brief        VARCHAR2(255);
    v_policy_id           p_policy.policy_id%TYPE;
    v_policy_header_id    p_pol_header.policy_header_id%TYPE;
    v_target_status_brief doc_status_ref.brief%TYPE;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
    PROCEDURE check_status_exists(par_status_brief VARCHAR2) IS
    BEGIN
    
      IF par_status_brief NOT IN ('CANCEL', 'PASSED_TO_AGENT', 'SIGNED')
      THEN
        raise_application_error(-20001
                               ,'Не удалось определить статус по брифу - ' || par_status_brief);
      END IF;
    
    END;
  BEGIN
  
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    /* Разбираем запрос */
    v_ids := par_data.get('ids').get_number;
    IF par_data.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data.get('policy_id').get_number;
    END IF;
    v_status_brief := par_data.get('status_brief').get_string;
  
    /* Проверяем существует ли статус */
    pkg_trace.add_variable(par_trace_var_name  => 'STATUS_BRIEF'
                          ,par_trace_var_value => v_status_brief);
    trace('Проверка существования статуса');
    check_status_exists(v_status_brief);
  
    /* Находим договор в шлюзе */
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
    trace('Поиск договора в шлюзе');
  
    v_policy_header_id := get_policy_from_gate_by_ids(par_ids           => v_ids
                                                     ,par_b2b_policy_id => v_b2b_policy_id);
  
    /* Проверяем доступ внешней системы к договору */
    check_access_to_policy(par_pol_header_id => v_policy_header_id);
  
    trace('Получение текущей версии ДС');
    v_policy_id := pkg_policy.get_curr_policy(p_pol_header_id => v_policy_header_id);
  
    /* Устанавливаем статус */
    trace('Перевод статуса ДС');
    v_target_status_brief := get_mapped_status_brief(par_policy_header_id      => v_policy_header_id
                                                    ,par_original_status_brief => v_status_brief);
    doc.set_doc_status(p_doc_id => v_policy_id, p_status_brief => v_target_status_brief);
  
    /* Формируем ответ */
    trace('Формируем ответ на запрос на перевод статуса ДС');
    DECLARE
      v_response      JSON := JSON();
      v_response_clob CLOB;
      v_log_info      pkg_communication.typ_log_info;
    BEGIN
    
      v_response.put(gc_status_keyword, gc_status_ok);
      v_response.put(gc_data_keyword, JSON());
    
      dbms_lob.createtemporary(lob_loc => v_response_clob, cache => TRUE);
    
      v_response.to_clob(v_response_clob);
    
      IF gv_debug
      THEN
        v_log_info.source_pkg_name       := gc_pkg_name;
        v_log_info.source_procedure_name := vc_proc_name;
        v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
      END IF;
    
      pkg_communication.htp_lob_response(par_lob => v_response_clob, par_log_info => v_log_info);
    END;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
      ROLLBACK;
  END set_policy_status;

  FUNCTION get_report_id_by_code(par_code_brief ve_reports_by_context.code%TYPE)
    RETURN ve_reports_by_context.rep_report_id%TYPE IS
    v_rep_report_id ve_reports_by_context.rep_report_id%TYPE;
  BEGIN
    SELECT t.rep_report_id
      INTO v_rep_report_id
      FROM ve_reports_by_context t
     WHERE t.code = par_code_brief;
  
    RETURN v_rep_report_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не удалось найти печатную форму для договора');
    WHEN too_many_rows THEN
      ex.raise('Найдено несколько печатных форм для договора, необходимо конкретезировать.');
  END get_report_id_by_code;

  /*
  Капля П.
  Процедура печати ДС
  */
  PROCEDURE print_policy_doc(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'print_policy_doc';
  
    v_ids              NUMBER;
    v_doc_brief        VARCHAR2(255);
    v_b2b_policy_id    NUMBER;
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
    v_rep_report_id    ve_reports_by_context.rep_report_id%TYPE;
    v_content_type     VARCHAR2(255);
    v_file_name        VARCHAR2(1000);
    v_pages_count      NUMBER;
    v_report_body      BLOB;
    v_log_info         pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
    PROCEDURE set_rep_context(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_version_num        p_policy.version_num%TYPE;
      v_product_brief      t_product.brief%TYPE;
      v_asset_id           as_asset.as_asset_id%TYPE;
      v_insuree_contact_id v_pol_issuer.contact_id%TYPE;
      v_mailing            p_policy.mailing%TYPE;
      v_is_group_flag      p_policy.is_group_flag%TYPE;
      v_asset_header_id    as_asset.p_asset_header_id%TYPE;
      v_status_brief       doc_status_ref.brief%TYPE;
      v_status_description doc_status_ref.name%TYPE;
      v_policy_id          p_pol_header.policy_id%TYPE;
    BEGIN
      SELECT pp.version_num
            ,pli.contact_id
            ,pp.mailing
            ,pp.is_group_flag
            ,aa.p_asset_header_id
            ,doc.get_last_doc_status_name(pp.policy_id)
            ,doc.get_last_doc_status_brief(pp.policy_id)
            ,aa.as_asset_id
            ,ph.policy_id
            ,pr.brief
        INTO v_version_num
            ,v_insuree_contact_id
            ,v_mailing
            ,v_is_group_flag
            ,v_asset_header_id
            ,v_status_description
            ,v_status_brief
            ,v_asset_id
            ,v_policy_id
            ,v_product_brief
        FROM p_policy     pp
            ,as_asset     aa
            ,v_pol_issuer pli
            ,p_pol_header ph
            ,t_product    pr
       WHERE ph.policy_header_id = par_pol_header_id
         AND pp.policy_id = ph.policy_id
         AND aa.p_policy_id = pp.policy_id
         AND pli.policy_id = pp.policy_id
         AND ph.product_id = pr.product_id
         AND aa.as_asset_id =
             (SELECT MIN(as_asset_id) FROM as_asset aa2 WHERE aa2.p_policy_id = aa.p_policy_id);
    
      ins.repcore.set_context('BRIEF', v_product_brief);
      ins.repcore.set_context('POL_HEADER_ID', to_char(par_pol_header_id));
      ins.repcore.set_context('P_POLICY_ID2', to_char(v_policy_id));
      ins.repcore.set_context('VERSION', to_char(v_version_num));
      ins.repcore.set_context('OWN_CONTACT', to_char(v_insuree_contact_id));
      ins.repcore.set_context('IS_AUTO_IDX', to_char(v_mailing));
      ins.repcore.set_context('IS_GROUP_FLAG', to_char(v_is_group_flag));
      ins.repcore.set_context('ASSET_HEADER', to_char(v_asset_header_id));
      ins.repcore.set_context('STATUS', v_status_description);
      ins.repcore.set_context('POL_ID', to_char(v_policy_id));
      ins.repcore.set_context('STATUS_BRIEF', v_status_brief);
      ins.repcore.set_context('PREV_POLICY_BRIEF', pkg_policy.get_prev_ver_status_brief(v_policy_id));
      ins.repcore.set_context('PREV_STATUS_BRIEF', pkg_policy.get_prev_status_brief(v_policy_id));
      ins.repcore.set_context('ASSET_ID', to_char(v_asset_id));
    
      ins.repcore.set_interface_context('POLICY', 'VERSION', 'POLICY_STATUS');
    END set_rep_context;
  
  BEGIN
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    v_ids := par_data.get('ids').get_number;
  
    IF par_data.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data.get('policy_id').get_number;
    END IF;
  
    IF par_data.exist('doc_brief')
    THEN
      v_doc_brief := par_data.get('doc_brief').get_string;
    ELSE
      ex.raise(par_message => 'Не задан тип документа для печати'
              ,par_sqlcode => ex.c_no_data_found);
    END IF;
  
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
    pkg_trace.add_variable(par_trace_var_name => 'DOC_BRIEF', par_trace_var_value => v_doc_brief);
    trace('JSON разобран');
  
    v_policy_header_id := get_policy_from_gate_by_ids(par_ids           => v_ids
                                                     ,par_b2b_policy_id => v_b2b_policy_id);
  
    /* Проверяем имеет ли данный клиент доступ к данному продукту */
    check_access_to_policy(par_pol_header_id => v_policy_header_id);
  
    /* Проверка на наличие договора в Журнале технических работ */
    IF pkg_journal_tech_work_fmb.policy_in_tech_journal(par_pol_header_id => v_policy_header_id) > 0
    THEN
      raise_application_error(-20001
                             ,'Печать заблокирована! ДС находится на рассмотрении в СБ или ЮУ.');
    END IF;
  
    /* Устанавливаем контекст, прописываем параметры отчета */
    trace('Установка REP_CONTEXT');
    set_rep_context(par_pol_header_id => v_policy_header_id);
  
    v_rep_report_id := get_report_id_by_code(par_code_brief => v_doc_brief);
  
    /* Формируем отчет */
    trace('Формирование печатной формы');
    pkg_rep_utils.exec_report(par_report_id    => v_rep_report_id
                             ,par_content_type => v_content_type
                             ,par_file_name    => v_file_name
                             ,par_pages_count  => v_pages_count
                             ,par_report       => v_report_body);
  
    /* Прибираем за собой */
    ins.repcore.clear_context;
  
    /* Отправляем файл */
    trace('Отсылка файла');
    IF gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
    END IF;
  
    pkg_communication.response_with_file(par_file         => v_report_body
                                        ,par_file_name    => v_file_name
                                        ,par_content_type => v_content_type
                                        ,par_log_info     => v_log_info);
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      ins.repcore.clear_context;
      error_response(vc_proc_name);
  END print_policy_doc;

  -- Author  : PAVEL.KAPLYA
  -- Created : 18.04.2014 15:06:38
  -- Purpose : Печать незаполненных полисов
  PROCEDURE print_empty_policies(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('PRINT_EMPTY_POLICY');
  
    v_product_brief      t_product.brief%TYPE;
    v_ag_contract_num    VARCHAR2(50);
    v_doc_brief          VARCHAR2(255);
    v_rep_report_id      ve_reports_by_context.rep_report_id%TYPE;
    v_number_of_copies   PLS_INTEGER := 1;
    v_number_of_policies PLS_INTEGER := 1;
    v_bso_series         bso_series.series_num%TYPE;
    v_report             pkg_rep_utils.t_report;
    v_bso_series_id      bso_series.bso_series_id%TYPE;
    v_product_id         t_product.product_id%TYPE;
    v_payment_terms      VARCHAR2(1000);
    v_fund_brief         VARCHAR2(1000);
  
    v_log_info pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
  BEGIN
  
    SAVEPOINT before_insert_bso_to_temp;
  
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    IF par_data.exist('product_brief')
    THEN
      v_product_brief := par_data.get('product_brief').get_string;
    ELSE
      ex.raise(par_message => 'Не задан бриф продукта'
              ,par_sqlcode => ex.c_no_data_found);
    END IF;
  
    IF par_data.exist('ag_contract_num')
    THEN
      v_ag_contract_num := par_data.get('ag_contract_num').get_string;
    ELSE
      ex.raise(par_message => 'Не задан номер АД продукта'
              ,par_sqlcode => ex.c_no_data_found);
    END IF;
  
    IF par_data.exist('doc_brief')
    THEN
      v_doc_brief := par_data.get('doc_brief').get_string;
    ELSE
      v_doc_brief := 'POLICY';
    END IF;
  
    IF par_data.exist('number_of_policies')
    THEN
      v_number_of_policies := par_data.get('number_of_policies').get_number;
    END IF;
  
    IF par_data.exist('number_of_copies')
    THEN
      v_number_of_copies := par_data.get('number_of_copies').get_number;
    END IF;
  
    IF par_data.exist('bso_series')
    THEN
      v_bso_series := par_data.get('bso_series').get_number;
    END IF;
  
    IF par_data.exist('payment_terms')
    THEN
      v_payment_terms := par_data.get('payment_terms').get_string;
    END IF;
  
    IF par_data.exist('fund')
    THEN
      v_fund_brief := par_data.get('fund').get_string;
    END IF;
  
    trace('Установка REP_CONTEXT');
    repcore.clear_context;
  
    repcore.set_interface_context('POLICY', 'VERSION', 'POLICY_STATUS');
  
    v_product_id := dml_t_product.get_id_by_brief(par_brief => v_product_brief);
  
    IF v_bso_series IS NOT NULL
    THEN
      v_bso_series_id := dml_bso_series.get_id_by_series_num(par_series_num => v_bso_series);
    ELSE
      v_bso_series_id := pkg_products.get_default_bso_series(par_product_id => v_product_id);
    END IF;
  
    pkg_trace.add_variable(par_trace_var_name  => 'v_bso_series_id'
                          ,par_trace_var_value => v_bso_series_id);
    trace('Определена серия БСО');
  
    pkg_bso.create_empty_bso_pool(par_bso_series_id     => v_bso_series_id
                                 ,par_to_generate_count => v_number_of_policies
                                 ,par_agent_id          => get_agent(v_ag_contract_num));
  
    trace('БСО для передачи записаны в временную таблицу. Переведены статусы отобранных БСО');
  
    -- Прописываем контекст
    repcore.set_context('BRIEF', v_product_brief);
    repcore.set_context('PRINT_EMPTY', 1);
    repcore.set_context('PAYMENT_TERMS', v_payment_terms);
    repcore.set_context('NUMBER_OF_COPIES', v_number_of_copies);
    repcore.set_context('POL_HEADER_ID', NULL);
    repcore.set_context('P_POLICY_ID2', NULL);
    repcore.set_context('VERSION', NULL);
    repcore.set_context('OWN_CONTACT', NULL);
    repcore.set_context('IS_AUTO_IDX', NULL);
    repcore.set_context('IS_GROUP_FLAG', NULL);
    repcore.set_context('ASSET_HEADER', NULL);
    repcore.set_context('STATUS', NULL);
    repcore.set_context('POL_ID', NULL);
    repcore.set_context('STATUS_BRIEF', NULL);
    repcore.set_context('PREV_POLICY_BRIEF', NULL);
    repcore.set_context('PREV_STATUS_BRIEF', NULL);
    repcore.set_context('ASSET_ID', NULL);
    repcore.set_context('FUND', v_fund_brief);
  
    v_rep_report_id := get_report_id_by_code(par_code_brief => v_doc_brief);
  
    trace('Формирование печатной формы');
    pkg_rep_utils.exec_report(par_report_id => v_rep_report_id, par_report => v_report);
  
    IF v_report.report_body IS NULL
    THEN
      ex.raise(par_message => 'Не удалось сформировать файл.'
              ,par_sqlcode => ex.c_custom_error);
    END IF;
  
    /* Прибираем за собой */
    ins.repcore.clear_context;
  
    /* Отправляем файл */
    trace('Отсылка файла');
    IF gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
    END IF;
  
    pkg_communication.response_with_file(par_file         => v_report.report_body
                                        ,par_file_name    => v_report.file_name
                                        ,par_content_type => v_report.content_type
                                        ,par_log_info     => v_log_info);
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      ins.repcore.clear_context;
      ROLLBACK TO before_insert_bso_to_temp;
      error_response(vc_proc_name);
  END print_empty_policies;

  /*
    Капля П.
    Печать Полисных условий.
    На момент создания (05.05.2014) использовалась только для печати ПУ, 
    когда договора еще не существует. Необходимо для реализации полисов продукта FAMILY_PROETCTION для SGI    
  */
  PROCEDURE print_policy_form(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('PRINT_POLICY_FORM');
  
    v_product_brief         t_product.brief%TYPE;
    v_bso_series            NUMBER;
    v_product_id            t_product.product_id%TYPE;
    v_bso_series_id         bso_series.bso_series_id%TYPE;
    v_policyform_product_id t_policyform_product.t_policyform_product_id%TYPE;
    v_report                pkg_rep_utils.t_report;
    v_log_info              pkg_communication.typ_log_info;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  
    FUNCTION get_policyform_product_id
    (
      par_product_id    t_product.product_id%TYPE
     ,par_bso_series_id bso_series.bso_series_id%TYPE
    ) RETURN t_policyform_product.t_policyform_product_id%TYPE IS
      v_policyform_product_id t_policyform_product.t_policyform_product_id%TYPE;
    BEGIN
      SELECT pp.t_policyform_product_id
        INTO v_policyform_product_id
        FROM t_policyform_product pp
            ,bso_series           bs
       WHERE pp.t_product_id = par_product_id
         AND bs.t_product_conds_id = pp.t_policy_form_id
         AND bs.bso_series_id = par_bso_series_id;
    
      RETURN v_policyform_product_id;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не удалось определить ПУ по продукту и серии БСО');
    END get_policyform_product_id;
  
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    -- Парсим JSON 
    IF par_data.exist('product_brief')
    THEN
      v_product_brief := par_data.get('product_brief').get_string;
    ELSE
      ex.raise(par_message => 'Не задан бриф продукта'
              ,par_sqlcode => ex.c_no_data_found);
    END IF;
  
    IF par_data.exist('bso_series')
    THEN
      v_bso_series := par_data.get('bso_series').get_number;
    END IF;
  
    -- Определяем ИДшники по данным из JSON
    v_product_id := dml_t_product.get_id_by_brief(v_product_brief);
  
    IF v_bso_series IS NOT NULL
    THEN
      v_bso_series_id := dml_bso_series.get_id_by_series_num(par_series_num => v_bso_series);
    ELSE
      v_bso_series_id := pkg_products.get_default_bso_series(par_product_id => v_product_id);
    END IF;
  
    pkg_trace.add_variable(par_trace_var_name  => 'v_bso_series_id'
                          ,par_trace_var_value => v_bso_series_id);
    trace('Определена серия БСО');
  
    -- Определяем ПУ для печати
    v_policyform_product_id := get_policyform_product_id(par_product_id    => v_product_id
                                                        ,par_bso_series_id => v_bso_series_id);
  
    -- Формирование БЛОБа
    pkg_policyform_product.get_policyform_product_pdf(par_policyform_product_id => v_policyform_product_id
                                                     ,par_report                => v_report);
  
    -- Отправляем файл
    trace('Отсылка файла');
    IF gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
    END IF;
  
    pkg_communication.response_with_file(par_file         => v_report.report_body
                                        ,par_file_name    => v_report.file_name
                                        ,par_content_type => v_report.content_type
                                        ,par_log_info     => v_log_info);
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      ins.repcore.clear_context;
      error_response(vc_proc_name);
  END print_policy_form;

  /*
  Капля П.
  Процедура снятия флага "Временный" с документов, телфонов, адресов и почтовых адресов контактов
  Продедура должна выполняться при подписании договора страхования
  */
  PROCEDURE confirm_contacts_info_on_sign(par_policy_id NUMBER) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'CONFIRM_CONTACTS_INFO_ON_SIGN';
    v_contact_list t_number_type := t_number_type();
  BEGIN
  
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    -- Собираем все контакты по договору
    SELECT contact_id
      BULK COLLECT
      INTO v_contact_list
      FROM (SELECT pi.contact_id
              FROM v_pol_issuer pi
             WHERE pi.policy_id = par_policy_id
            UNION
            SELECT aas.assured_contact_id contact_id
              FROM ven_as_assured aas
             WHERE aas.p_policy_id = par_policy_id
            UNION
            SELECT b.contact_id
              FROM as_asset       aa
                  ,as_beneficiary b
             WHERE aa.p_policy_id = par_policy_id
               AND aa.as_asset_id = b.as_asset_id);
  
    -- Снимаем галку "Временный контакт"
    -- Капля П.
    -- Исправил старую багу, когда не сбрасывались статусы инфы контактов
    FORALL i IN v_contact_list.first .. v_contact_list.last
      UPDATE cn_contact_ident cci
         SET cci.is_temp = NULL
       WHERE cci.contact_id = v_contact_list(i)
         AND cci.is_temp = 1;
  
    FORALL i IN v_contact_list.first .. v_contact_list.last
      UPDATE cn_contact_ident cci
         SET cci.is_temp = NULL
       WHERE cci.contact_id = v_contact_list(i)
         AND cci.is_temp = 1;
  
    FORALL i IN v_contact_list.first .. v_contact_list.last
      UPDATE cn_contact_telephone cct
         SET cct.is_temp = NULL
       WHERE cct.contact_id = v_contact_list(i)
         AND cct.is_temp = 1;
  
    FORALL i IN v_contact_list.first .. v_contact_list.last
      UPDATE cn_contact_address cca
         SET cca.is_temp = NULL
       WHERE cca.contact_id = v_contact_list(i)
         AND cca.is_temp = 1;
  
    FORALL i IN v_contact_list.first .. v_contact_list.last
      UPDATE cn_contact_email cce
         SET cce.is_temp = NULL
       WHERE cce.contact_id = v_contact_list(i)
         AND cce.is_temp = 1;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Не удалось снять флаг "Временный" с записей контактов договора.');
  END confirm_contacts_info_on_sign;

  PROCEDURE delete_unapproved_policies_job(par_date DATE DEFAULT SYSDATE) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'DELETE_UNAPPROVED_POLICIES_JOB';
    v_check_date DATE := trunc(par_date);
  
    TYPE tt_undeleted_policies IS TABLE OF p_pol_header.policy_header_id%TYPE;
  
    v_total_policy_count   NUMBER;
    v_undeleted_policy_ids tt_undeleted_policies := tt_undeleted_policies();
    v_message_text         VARCHAR2(32767);
  
    --c_param_brief CONSTANT app_param.brief%TYPE := 'B2B_DELETE_UNSIGNED_POLICIES';
  
    v_period_length NUMBER;
  
  BEGIN
  
    -- Trace begin
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    v_period_length := pkg_app_param.get_app_param_n(p_brief => gc_param_brief);
  
    FOR policy_rec IN (SELECT /*+ USE_NL(d, ds, ph)*/
                        d.document_id
                       ,ph.policy_header_id
                       ,ph.ids
                       ,COUNT(1) over() cnt
                         FROM document       d
                             ,doc_status_ref dsr
                             ,p_pol_header   ph
                             ,doc_status     ds
                        WHERE ph.last_ver_id = d.document_id
                          AND d.doc_status_ref_id = dsr.doc_status_ref_id
                          AND dsr.brief IN ('B2B_CALCULATED', 'B2B_PENDING')
                          AND d.doc_status_id = ds.doc_status_id
                          AND ds.start_date < v_check_date - v_period_length)
    LOOP
      BEGIN
        pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => policy_rec.ids);
        pkg_trace.add_variable(par_trace_var_name  => 'POLICY_HEADER_Id'
                              ,par_trace_var_value => policy_rec.policy_header_id);
        pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                       ,par_trace_subobj_name => vc_proc_name
                       ,par_message           => 'Удаление договора');
      
        IF v_total_policy_count IS NULL
        THEN
          v_total_policy_count := policy_rec.cnt;
        END IF;
      
        SAVEPOINT before_policy_delete;
        delete_policy(par_pol_header_id => policy_rec.policy_header_id);
        --COMMIT;
      
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_policy_delete;
        
          pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => policy_rec.ids);
          pkg_trace.add_variable(par_trace_var_name  => 'POLICY_HEADER_Id'
                                ,par_trace_var_value => policy_rec.policy_header_id);
          pkg_trace.add_variable(par_trace_var_name => 'SQLERRM', par_trace_var_value => SQLERRM);
          pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => vc_proc_name
                         ,par_message           => 'Не удалось удалить договор');
        
          v_undeleted_policy_ids.extend;
          v_undeleted_policy_ids(v_undeleted_policy_ids.last) := policy_rec.policy_header_id;
        
      END;
    END LOOP;
  
    IF v_undeleted_policy_ids.count > 0
    THEN
      v_message_text := 'Номера неудаленных договоров: ';
      FOR i IN v_undeleted_policy_ids.first .. v_undeleted_policy_ids.last
      LOOP
        v_message_text := v_message_text || chr(10) || v_undeleted_policy_ids(i);
      END LOOP;
    
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients(gc_responsible_person_email)
                                         ,par_subject => 'Ошибка удаления неподтвержденных договоров интеграции'
                                         ,par_text    => v_message_text);
      v_undeleted_policy_ids.delete;
    END IF;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  END delete_unapproved_policies_job;
  /*
    Мизинов Г.В.
    Процедура пометки договора в шлюзовой таблице как удаленного при его отмене
  */
  PROCEDURE mark_canceled_policy_as_del(par_policy_id ins.p_policy.policy_id%TYPE) AS
    v_pol_header_id ins.p_pol_header.policy_header_id%TYPE;
    v_ids           ins.p_pol_header.ids%TYPE;
  BEGIN
    BEGIN
      SELECT g.p_pol_header_id
            ,g.ids
        INTO v_pol_header_id
            ,v_ids
        FROM ins.p_policy pp
            ,ins.g_policy g
       WHERE pp.policy_id = par_policy_id
         AND g.p_pol_header_id = pp.pol_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
    IF NOT pkg_policy.is_pol_header_canceled(v_pol_header_id)
    THEN
      UPDATE g_policy g
         SET g.is_deleted = 1
            ,g.note       = v_ids
            ,g.ids        = ''
       WHERE g.p_pol_header_id = v_pol_header_id;
    END IF;
  END mark_canceled_policy_as_del;
  /*
    Пиядин А.
    Получение JSON по версии ДС (Версия + Страхователь + Застрахованные с программами, выгодоприобретателями и выкупными)
  */
  PROCEDURE get_policy_info(par_data_json JSON) IS
    vc_proc_name CONSTANT VARCHAR2(255) := 'GET_POLICY_INFO';
  
    v_ids             NUMBER;
    v_b2b_policy_id   NUMBER;
    vr_g_policy       g_policy%ROWTYPE;
    gv_policy_id      p_policy.policy_id%TYPE;
    gv_b2b_policy_id  g_policy.policy_b2b_id%TYPE;
    gv_g_policy_id    g_policy.g_policy_id%TYPE;
    gv_g_contact_type g_contact.contact_type%TYPE;
    gv_b2b_contact_id g_contact.b2b_person_id%TYPE;
    gv_g_contact_id   g_contact.g_contact_id%TYPE;
  
    v_data     JSON := JSON();
    v_response JSON := JSON();
    v_log_info pkg_communication.typ_log_info;
  
    -- Курсор по застрахованным
    CURSOR cur_insured IS
      SELECT au.assured_contact_id
            ,at.brief
        FROM as_asset       aa
            ,as_assured     au
            ,p_asset_header ah
            ,t_asset_type   at
       WHERE 1 = 1
         AND aa.as_asset_id = au.as_assured_id
         AND aa.p_asset_header_id = ah.p_asset_header_id
         AND ah.t_asset_type_id = at.t_asset_type_id
         AND aa.p_policy_id = gv_policy_id
       ORDER BY aa.as_asset_id;
  
    -- NUMBER
    PROCEDURE put_json_value
    (
      par_json  IN OUT JSON
     ,par_key   VARCHAR2
     ,par_value NUMBER
    ) IS
    BEGIN
      IF par_value IS NOT NULL
      THEN
        par_json.put(par_key, par_value);
      END IF;
    END put_json_value;
  
    -- DATE
    PROCEDURE put_json_value
    (
      par_json  IN OUT JSON
     ,par_key   VARCHAR2
     ,par_value DATE
    ) IS
    BEGIN
      IF par_value IS NOT NULL
      THEN
        par_json.put(par_key, trunc(par_value));
      END IF;
    END put_json_value;
  
    -- STRING
    PROCEDURE put_json_value
    (
      par_json  IN OUT JSON
     ,par_key   VARCHAR2
     ,par_value VARCHAR2
    ) IS
    BEGIN
      IF par_value IS NOT NULL
      THEN
        par_json.put(par_key, TRIM(par_value));
      END IF;
    END put_json_value;
  
    -- JSON по версии ДС
    FUNCTION get_policy_json(par_policy_id p_policy.policy_id%TYPE) RETURN JSON IS
      v_p_policy      dml_p_policy.tt_p_policy;
      v_p_pol_header  dml_p_pol_header.tt_p_pol_header;
      va_doc_property pkg_doc_properties.tt_doc_property;
    
      v_result JSON := JSON();
    
      -- Получение суммарного взноса по ИД версии ДС
      FUNCTION get_total_fee(par_policy_id p_policy.policy_id%TYPE) RETURN NUMBER IS
        v_result NUMBER;
      BEGIN
        SELECT nvl(SUM(aa.fee), 0)
          INTO v_result
          FROM as_asset aa
         WHERE aa.p_policy_id = par_policy_id;
      
        RETURN v_result;
      END get_total_fee;
    
      -- Получение брифа продукта по ИД
      FUNCTION get_product_brief(par_product_id t_product.product_id%TYPE) RETURN t_product.brief%TYPE IS
        v_result t_product.brief%TYPE;
      BEGIN
        SELECT brief INTO v_result FROM t_product WHERE product_id = par_product_id;
      
        RETURN v_result;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_product_brief;
    
      -- Получение номера агентского договора по ИД заголовка ДС
      FUNCTION get_agent_num(par_policy_header_id p_pol_header.policy_header_id%TYPE)
        RETURN document.num%TYPE IS
        v_result document.num%TYPE;
      BEGIN
        SELECT ah.num
          INTO v_result
          FROM ven_ag_contract_header ah
         WHERE ah.ag_contract_header_id =
               pkg_agn_control.get_current_policy_agent(par_policy_header_id);
      
        RETURN v_result;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_agent_num;
    
      -- Получение брифа периодичности оплаты по ИД
      FUNCTION get_payment_term_brief(par_payment_term_id p_policy.payment_term_id%TYPE)
        RETURN t_payment_terms.brief%TYPE IS
        v_result t_payment_terms.brief%TYPE;
      BEGIN
        SELECT brief INTO v_result FROM t_payment_terms WHERE id = par_payment_term_id;
      
        RETURN v_result;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_payment_term_brief;
    
      -- Получение брифа валюты по ИД
      FUNCTION get_fund_brief(par_fund_id fund.fund_id%TYPE) RETURN fund.brief%TYPE IS
        v_result fund.brief%TYPE;
      BEGIN
        SELECT brief INTO v_result FROM fund WHERE fund_id = par_fund_id;
      
        RETURN v_result;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_fund_brief;
    
      -- Получение брифа скидки по ИД
      FUNCTION get_discount_brief(par_discount_id discount_f.discount_f_id%TYPE)
        RETURN discount_f.brief%TYPE IS
        v_result discount_f.brief%TYPE;
      BEGIN
        SELECT brief INTO v_result FROM discount_f WHERE discount_f_id = par_discount_id;
      
        RETURN v_result;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_discount_brief;
    
      -- Получение количества месяцев между датами
      FUNCTION get_period_in_months
      (
        par_start_date p_pol_header.start_date%TYPE
       ,par_end_date   p_policy.end_date%TYPE
      ) RETURN NUMBER IS
        v_result NUMBER;
      BEGIN
        SELECT FLOOR((MONTHS_BETWEEN(par_end_date + 1, par_start_date))) INTO v_result FROM dual;
      
        RETURN v_result;
      END get_period_in_months;
    
    BEGIN
      v_p_policy      := dml_p_policy.get_record(par_policy_id);
      v_p_pol_header  := dml_p_pol_header.get_record(v_p_policy.pol_header_id);
      va_doc_property := pkg_doc_properties.get_document_properties(par_policy_id);
    
      put_json_value(v_result, 'policy_id', gv_b2b_policy_id);
      put_json_value(v_result, 'borlas_policy_id', par_policy_id);
      put_json_value(v_result, 'ids', v_p_pol_header.ids);
      put_json_value(v_result, 'status_brief', doc.get_doc_status_brief(v_p_pol_header.policy_id));
      put_json_value(v_result
                    ,'status_uncancel_brief'
                    ,doc.get_doc_status_brief(v_p_pol_header.max_uncancelled_policy_id));
      put_json_value(v_result, 'policy_num', v_p_policy.pol_num);
      put_json_value(v_result, 'total_premium', v_p_policy.premium);
      put_json_value(v_result, 'total_fee', get_total_fee(par_policy_id));
      put_json_value(v_result, 'ins_amount', v_p_policy.ins_amount);
      put_json_value(v_result, 'start_date', v_p_pol_header.start_date);
      put_json_value(v_result, 'end_date', trunc(v_p_policy.end_date));
      put_json_value(v_result, 'sign_date', v_p_policy.notice_date);
      put_json_value(v_result, 'notice_date', v_p_policy.end_date);
      put_json_value(v_result, 'first_payment_date', v_p_policy.first_pay_date);
    
      put_json_value(v_result, 'product_brief', get_product_brief(v_p_pol_header.product_id));
      put_json_value(v_result, 'ag_contract_num', get_agent_num(v_p_policy.pol_header_id));
      put_json_value(v_result
                    ,'policy_period'
                    ,get_period_in_months(v_p_pol_header.start_date, v_p_policy.end_date));
      put_json_value(v_result, 'fund', get_fund_brief(v_p_pol_header.fund_id));
      put_json_value(v_result, 'payment_terms', get_payment_term_brief(v_p_policy.payment_term_id));
      put_json_value(v_result, 'base_sum', v_p_policy.base_sum);
      put_json_value(v_result, 'is_credit', v_p_policy.is_credit);
      put_json_value(v_result, 'discount_brief', get_discount_brief(v_p_policy.discount_f_id));
    
      IF va_doc_property.count <> 0
      THEN
        DECLARE
          v_doc_property_list JSON_LIST := JSON_LIST();
        BEGIN
          FOR i IN va_doc_property.first .. va_doc_property.last
          LOOP
            DECLARE
              v_doc_property JSON := JSON();
            BEGIN
              put_json_value(v_doc_property, 'property_brief', va_doc_property(i).property_type_brief);
              put_json_value(v_doc_property
                            ,'value'
                            ,coalesce(va_doc_property(i).value_char
                                     ,to_char(va_doc_property(i).value_num)
                                     ,to_char(va_doc_property(i).value_date, 'dd.mm.yyyy')));
              v_doc_property_list.append(v_doc_property.to_json_value);
            END;
          END LOOP;
        
          v_result.put('additional_properties', v_doc_property_list);
        END;
      END IF;
    
      RETURN v_result;
    END get_policy_json;
  
    -- JSON по Контакту
    FUNCTION get_contact_json
    (
      par_contact_id   contact.contact_id%TYPE
     ,par_contact_type t_asset_type.brief%TYPE DEFAULT NULL
    ) RETURN JSON IS
      v_work_group_desc t_work_group.description%TYPE := NULL;
      v_hobby_desc      t_hobby.description%TYPE := NULL;
      v_profession_desc t_profession.description%TYPE := NULL;
    
      v_result JSON := JSON();
    
      -- Курсор по ассетам
      CURSOR cur_as_asset(par_contact_id contact.contact_id%TYPE) IS
        SELECT aa.as_asset_id
              ,aa.p_asset_header_id
              ,aas.credit_account_number
              ,aa.ins_amount
              ,aa.fee
              ,aa.ins_premium
          FROM as_asset       aa
              ,as_assured     aas
              ,p_asset_header ah
         WHERE 1 = 1
           AND aa.p_asset_header_id = ah.p_asset_header_id
           AND aa.as_asset_id = aas.as_assured_id
           AND aa.p_policy_id = gv_policy_id
           AND aas.assured_contact_id = par_contact_id;
    
      -- Курсор по страховым программам
      CURSOR cur_program(par_as_asset as_asset.as_asset_id%TYPE) IS
        SELECT pl.description
              ,plo.brief
              ,plt.presentation_desc
              ,pc.fee                fee
              ,pc.ins_amount
              ,pc.premium            premium
              ,pc.start_date
              ,pc.end_date
              ,pc.premia_base_type
              ,plt.brief             plt_brief
              ,ll.t_lob_line_id
          FROM p_cover             pc
              ,t_prod_line_option  plo
              ,t_product_line      pl
              ,t_product_line_type plt
              ,t_lob_line          ll
         WHERE 1 = 1
           AND pc.t_prod_line_option_id = plo.id
           AND plo.product_line_id = pl.id
           AND pl.product_line_type_id = plt.product_line_type_id
           AND pl.t_lob_line_id = ll.t_lob_line_id
           AND pc.as_asset_id = par_as_asset
         ORDER BY plt.sort_order
                 ,pl.sort_order;
    
      -- Курсор по выкупным суммам
      CURSOR cur_surrender
      (
        par_lob_line_id             t_lob_line.t_lob_line_id%TYPE
       ,par_product_line_type_brief t_product_line_type.brief%TYPE
      ) IS
        SELECT MONTHS_BETWEEN(d.insurance_year_date, ph.start_date) / 12 + 1 ins_year_formula
              ,row_number() over(ORDER BY d.start_cash_surr_date) period_number
              ,d.start_cash_surr_date AS period_start
              ,d.end_cash_surr_date AS period_end
              ,ROUND(d.value, 2) AS VALUE
          FROM policy_cash_surr   p
              ,policy_cash_surr_d d
              ,p_pol_header       ph
         WHERE 1 = 1
           AND p.policy_cash_surr_id = d.policy_cash_surr_id
           AND p.pol_header_id = ph.policy_header_id
           AND p.t_lob_line_id = par_lob_line_id
           AND par_product_line_type_brief = 'RECOMMENDED'
           AND p.policy_id = gv_policy_id
         ORDER BY d.start_cash_surr_date;
    
      -- Курсор по выгодоприобретателям
      CURSOR cur_benefic(par_as_asset_id as_asset.as_asset_id%TYPE) IS
        SELECT ab.contact_id
              ,crt.relationship_dsc
              ,ab.value
              ,pt.brief
          FROM as_beneficiary     ab
              ,t_path_type        pt
              ,cn_contact_rel     ccr
              ,t_contact_rel_type crt
         WHERE 1 = 1
           AND ab.value_type_id = pt.t_path_type_id
           AND ab.cn_contact_rel_id = ccr.id
           AND ccr.relationship_type = crt.id
           AND ab.as_asset_id = par_as_asset_id;
    
      PROCEDURE get_main_info
      (
        par_json       IN OUT JSON
       ,par_contact_id contact.contact_id%TYPE
      ) IS
        v_contact_object pkg_contact_object.t_person_object;
      
        -- Определение B2B-го contact_id
        PROCEDURE get_b2b_contact_id(par_contact_id contact.contact_id%TYPE) IS
        BEGIN
          SELECT *
            INTO gv_g_contact_id
                ,gv_b2b_contact_id
            FROM (SELECT g_contact_id
                        ,b2b_person_id
                    FROM g_contact
                   WHERE 1 = 1
                     AND g_policy_id = gv_g_policy_id
                     AND contact_type = gv_g_contact_type
                     AND borlas_contact_id = par_contact_id
                   ORDER BY g_contact_id DESC)
           WHERE rownum = 1;
        
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'Не удалось найти запись в шлюзе по Контакту');
        END get_b2b_contact_id;
      
        FUNCTION is_company_contact(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
          par_json NUMBER;
        BEGIN
          SELECT CASE
                   WHEN ct.ext_id = 'ФизЛицо'
                        AND ct.brief = 'ФЛ' THEN
                    0
                   ELSE
                    1
                 END is_company
            INTO par_json
            FROM contact        c
                ,t_contact_type ct
           WHERE 1 = 1
             AND c.contact_type_id = ct.id
             AND c.contact_id = par_contact_id;
        
          RETURN par_json = 1;
        EXCEPTION
          WHEN no_data_found THEN
            RETURN FALSE;
        END is_company_contact;
      
      BEGIN
        get_b2b_contact_id(par_contact_id);
        v_contact_object := pkg_contact_object.person_object_from_contact(par_contact_id);
      
        put_json_value(par_json, 'person_id', gv_b2b_contact_id);
        put_json_value(par_json, 'borlas_contact_id', par_contact_id);
        put_json_value(par_json, 'surname', v_contact_object.name);
        put_json_value(par_json, 'name', v_contact_object.first_name);
        put_json_value(par_json, 'midname', v_contact_object.middle_name);
        put_json_value(par_json, 'gender', lower(substr(v_contact_object.gender, 1, 1)));
        put_json_value(par_json, 'birth_date', v_contact_object.date_of_birth);
      
        IF is_company_contact(par_contact_id)
        THEN
          put_json_value(par_json, 'company_name', v_contact_object.name);
          put_json_value(par_json, 'is_company', 1);
        ELSE
          put_json_value(par_json, 'is_company', 0);
        END IF;
      
        put_json_value(par_json, 'is_foreign', v_contact_object.resident_flag);
        put_json_value(par_json, 'is_public', v_contact_object.is_public_contact);
        put_json_value(par_json, 'is_rpdl', v_contact_object.is_rpdl);
        put_json_value(par_json, 'country_birth_alpha3', v_contact_object.country_birth_alpha3);
        put_json_value(par_json
                      ,'email'
                      ,pkg_contact_rep_utils.get_email(pkg_contact_rep_utils.get_last_active_email_id(par_contact_id)));
      
        -- Адреса
        IF v_contact_object.address_array.count <> 0
        THEN
          DECLARE
            v_address_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR i IN v_contact_object.address_array.first .. v_contact_object.address_array.last
            LOOP
              DECLARE
                v_address JSON := JSON();
              BEGIN
                put_json_value(v_address, 'address', v_contact_object.address_array(i).address);
                put_json_value(v_address
                              ,'type'
                              ,lower(v_contact_object.address_array(i).address_type_brief));
                v_address_list.append(v_address.to_json_value);
              END;
            END LOOP;
          
            par_json.put('addresses', v_address_list);
          END;
        END IF;
      
        -- Документы
        IF v_contact_object.id_doc_array.count <> 0
        THEN
          DECLARE
            v_doc_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR i IN v_contact_object.id_doc_array.first .. v_contact_object.id_doc_array.last
            LOOP
              DECLARE
                v_doc JSON := JSON();
              BEGIN
                put_json_value(v_doc, 'ser', v_contact_object.id_doc_array(i).series_nr);
                put_json_value(v_doc, 'num', v_contact_object.id_doc_array(i).id_value);
                put_json_value(v_doc, 'post', v_contact_object.id_doc_array(i).place_of_issue);
                put_json_value(v_doc, 'date', v_contact_object.id_doc_array(i).issue_date);
                put_json_value(v_doc, 'type', v_contact_object.id_doc_array(i).id_doc_type_brief);
                v_doc_list.append(v_doc.to_json_value);
              END;
            END LOOP;
          
            par_json.put('certificates', v_doc_list);
          END;
        END IF;
      
        -- Телефоны
        IF v_contact_object.phone_array.count <> 0
        THEN
          DECLARE
            v_phone_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR i IN v_contact_object.phone_array.first .. v_contact_object.phone_array.last
            LOOP
              DECLARE
                v_phone JSON := JSON();
              BEGIN
                put_json_value(v_phone, 'num', v_contact_object.phone_array(i).phone_number);
                put_json_value(v_phone, 'type', v_contact_object.phone_array(i).phone_type_brief);
                v_phone_list.append(v_phone.to_json_value);
              END;
            END LOOP;
          
            par_json.put('phones', v_phone_list);
          END;
        END IF;
      
        -- Доп. гражданства
        IF v_contact_object.additional_citizenship.count <> 0
        THEN
          put_json_value(par_json, 'has_additional_citizenship', 1);
          DECLARE
            v_citizenship_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR i IN v_contact_object.additional_citizenship.first .. v_contact_object.additional_citizenship.last
            LOOP
              v_citizenship_list.append(v_contact_object.additional_citizenship(i).country_alpha3);
            END LOOP;
          
            par_json.put('citizenships', v_citizenship_list);
          END;
        ELSE
          put_json_value(par_json, 'has_additional_citizenship', 0);
        END IF;
      
        -- Вид на жительство
        IF v_contact_object.residency_country_list.count <> 0
        THEN
          put_json_value(par_json, 'has_foreign_residency', 1);
          DECLARE
            v_residency_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR i IN v_contact_object.residency_country_list.first .. v_contact_object.residency_country_list.last
            LOOP
              v_residency_list.append(v_contact_object.residency_country_list(i).country_alpha3);
            END LOOP;
          
            par_json.put('residencies', v_residency_list);
          END;
        ELSE
          put_json_value(par_json, 'has_foreign_residency', 0);
        END IF;
      END get_main_info;
    
      PROCEDURE get_work_hobby_proffesion IS
      BEGIN
        IF par_contact_type = 'ASSET_INSUREE_PERSON'
        THEN
          SELECT w.description
                ,h.description
                ,p.description
            INTO v_work_group_desc
                ,v_hobby_desc
                ,v_profession_desc
            FROM as_insured   a
                ,t_work_group w
                ,t_hobby      h
                ,t_profession p
           WHERE 1 = 1
             AND a.work_group_id = w.t_work_group_id(+)
             AND a.t_hobby_id = h.t_hobby_id(+)
             AND a.t_profession_id = p.id(+)
             AND a.insured_contact_id = par_contact_id
             AND a.policy_id = gv_policy_id;
        ELSIF par_contact_type LIKE 'ASSET_PERSON%'
        THEN
          SELECT w.description
                ,h.description
                ,p.description
            INTO v_work_group_desc
                ,v_hobby_desc
                ,v_profession_desc
            FROM as_assured   a
                ,as_asset     aa
                ,t_work_group w
                ,t_hobby      h
                ,t_profession p
           WHERE 1 = 1
             AND a.as_assured_id = aa.as_asset_id
             AND a.work_group_id = w.t_work_group_id(+)
             AND a.t_hobby_id = h.t_hobby_id(+)
             AND a.t_profession_id = p.id(+)
             AND a.assured_contact_id = par_contact_id
             AND aa.p_policy_id = gv_policy_id;
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END get_work_hobby_proffesion;
    
    BEGIN
      get_main_info(v_result, par_contact_id);
    
      get_work_hobby_proffesion;
      put_json_value(v_result, 'work_group', v_work_group_desc);
      put_json_value(v_result, 'hobby', v_hobby_desc);
      put_json_value(v_result, 'profession', v_profession_desc);
    
      -- Застрахованный
      IF par_contact_type IN ('ASSET_PERSON', 'ASSET_PERSON_ADULT', 'ASSET_PERSON_CHILD')
      THEN
        FOR asset_rec IN cur_as_asset(par_contact_id)
        LOOP
          put_json_value(v_result, 'asset_id', asset_rec.p_asset_header_id);
          put_json_value(v_result, 'insured_type', par_contact_type);
          put_json_value(v_result, 'credit_account_number', asset_rec.credit_account_number);
          put_json_value(v_result, 'fee', asset_rec.fee);
          put_json_value(v_result, 'ins_amount', asset_rec.ins_amount);
          put_json_value(v_result, 'premium', asset_rec.ins_premium);
        
          -- Программы
          DECLARE
            v_programs_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR prg_rec IN cur_program(asset_rec.as_asset_id)
            LOOP
              DECLARE
                v_program_json JSON := JSON();
              BEGIN
                put_json_value(v_program_json, 'program_name', prg_rec.description);
                put_json_value(v_program_json, 'program_brief', prg_rec.brief);
                put_json_value(v_program_json, 'program_type', prg_rec.presentation_desc);
                put_json_value(v_program_json, 'fee', prg_rec.fee);
                put_json_value(v_program_json, 'premium', prg_rec.premium);
                put_json_value(v_program_json, 'ins_amount', prg_rec.ins_amount);
                put_json_value(v_program_json, 'start_date', prg_rec.start_date);
                put_json_value(v_program_json, 'end_date', prg_rec.end_date);
                put_json_value(v_program_json, 'premia_base_type', prg_rec.premia_base_type);
              
                DECLARE
                  v_surr_list JSON_LIST := JSON_LIST();
                BEGIN
                  FOR surr_rec IN cur_surrender(prg_rec.t_lob_line_id, prg_rec.plt_brief)
                  LOOP
                    DECLARE
                      v_surr_json JSON := JSON();
                    BEGIN
                      put_json_value(v_surr_json, 'year', surr_rec.ins_year_formula);
                      put_json_value(v_surr_json, 'payment', surr_rec.period_number);
                      put_json_value(v_surr_json, 'start', surr_rec.period_start);
                      put_json_value(v_surr_json, 'end', surr_rec.period_end);
                      put_json_value(v_surr_json, 'value', surr_rec.value);
                      v_surr_list.append(v_surr_json.to_json_value);
                    END;
                  END LOOP;
                
                  IF v_surr_list.count <> 0
                  THEN
                    v_program_json.put('surr_sums', v_surr_list);
                  END IF;
                END; -- Конец. Выкупные
              
                v_programs_list.append(v_program_json.to_json_value);
              END; -- Конец. Программы
            END LOOP;
          
            v_result.put('programs', v_programs_list);
          END;
        
          -- Выгодоприобретатели
          DECLARE
            v_benefic_list JSON_LIST := JSON_LIST();
          BEGIN
            FOR ben_rec IN cur_benefic(asset_rec.as_asset_id)
            LOOP
              DECLARE
                v_benefic_json JSON := JSON();
              BEGIN
                gv_g_contact_type := gc_benif_contact_type;
                put_json_value(v_benefic_json, 'related', ben_rec.relationship_dsc);
                put_json_value(v_benefic_json, 'share', ben_rec.value);
                put_json_value(v_benefic_json, 'share_type_brief', ben_rec.brief);
                get_main_info(v_benefic_json, ben_rec.contact_id);
              
                v_benefic_list.append(v_benefic_json.to_json_value);
              END;
            END LOOP;
          
            IF v_benefic_list.count <> 0
            THEN
              v_result.put('assignees', v_benefic_list);
            END IF;
          END;
        END LOOP;
      END IF;
    
      RETURN v_result;
    END get_contact_json;
  
  BEGIN
  
    v_ids := par_data_json.get('ids').get_number;
    IF par_data_json.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data_json.get('policy_id').get_string;
    END IF;
  
    vr_g_policy := get_gate_record_by_ids(v_ids, v_b2b_policy_id);
  
    gv_policy_id     := dml_p_pol_header.get_record(vr_g_policy.p_pol_header_id)
                        .max_uncancelled_policy_id;
    gv_g_policy_id   := vr_g_policy.g_policy_id;
    gv_b2b_policy_id := vr_g_policy.policy_b2b_id;
  
    -- Версия ДС
    v_data.put('policy', get_policy_json(gv_policy_id));
  
    -- Страхователь
    gv_g_contact_type := gc_insuree_contact_type;
    v_data.put('insuree'
              ,get_contact_json(pkg_policy.get_policy_contact(gv_policy_id
                                                             ,'Страхователь')
                               ,'ASSET_INSUREE_PERSON'));
  
    -- Застрахованные
    DECLARE
      v_insured_list JSON_LIST := JSON_LIST();
    BEGIN
      FOR insured_rec IN cur_insured
      LOOP
        gv_g_contact_type := gc_assured_contact_type;
        v_insured_list.append(get_contact_json(insured_rec.assured_contact_id, insured_rec.brief)
                              .to_json_value);
      END LOOP;
    
      IF v_insured_list.count <> 0
      THEN
        v_data.put('insured', v_insured_list);
      END IF;
    END;
  
    IF gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
    END IF;
  
    v_response.put(gc_status_keyword, gc_status_ok);
    v_response.put(gc_data_keyword, v_data);
  
    pkg_communication.htp_lob_response(par_json => v_response, par_log_info => v_log_info);
  EXCEPTION
    WHEN OTHERS THEN
      error_response(vc_proc_name);
  END get_policy_info;

  /*
    Пиядин А.
    Процедура которая отправляет в B2B сигнал об изменении параметров договора
  */
  PROCEDURE refresh_policy_info(par_policy_id p_policy.policy_id%TYPE) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'refresh_policy_info';
  
    v_b2b_policy_id   g_policy.policy_b2b_id%TYPE;
    v_ids             g_policy.ids%TYPE;
    v_aq_chat_message tt_aq_chat_message;
  
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
  
    /* Поиск договора страхования в шлюзе */
    SELECT gp.ids
          ,gp.policy_b2b_id
      INTO v_ids
          ,v_b2b_policy_id
      FROM p_policy     pp
          ,p_pol_header ph
          ,g_policy     gp
     WHERE 1 = 1
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.ids = gp.ids
       AND pp.policy_id = par_policy_id;
  
    pkg_trace.add_variable(par_trace_var_name  => 'PAR_POLICY_ID'
                          ,par_trace_var_value => par_policy_id);
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
  
    /* Проверяем имеет ли данный клиент доступ к данному продукту */
    --    check_access_to_policy(par_pol_header_id => pkg_policy.get_policy_header_by_ids(v_ids));
  
    v_aq_chat_message := tt_aq_chat_message('refresh_policy_info' -- operation
                                           ,v_ids -- ids
                                           ,v_b2b_policy_id -- b2b_policy_id
                                           ,NULL -- t_chat_message_id
                                           ,NULL -- message_text
                                           ,NULL -- file_list
                                            );
    /* Постановка сообщения в очередь */
    pkg_chat_message.chat_enqueue(v_aq_chat_message);
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN no_data_found THEN
      -- Если договора нет в шлюзе, то информацию в б2б обновлять не надо
      NULL;
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
  END refresh_policy_info;

  /*
    Пиядин А.
    Процедура отправки файла в B2B
  */
  PROCEDURE get_file(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'get_file';
  
    v_ids               p_pol_header.ids%TYPE;
    v_b2b_policy_id     g_policy.policy_b2b_id%TYPE;
    v_file_id           stored_files.stored_files_id%TYPE;
    v_policy_header_id  p_pol_header.policy_header_id%TYPE;
    v_stored_files_body dml_stored_files_body.tt_stored_files_body;
    v_log_info          pkg_communication.typ_log_info;
  
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
  
    /* Разбор JSON */
    v_ids := par_data.get('ids').get_number;
  
    IF par_data.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data.get('policy_id').get_number;
    END IF;
  
    IF par_data.exist('file_id')
    THEN
      v_file_id := par_data.get('file_id').get_string;
    ELSE
      ex.raise(par_message => 'Не указан ИД файла', par_sqlcode => ex.c_no_data_found);
    END IF;
  
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
    pkg_trace.add_variable(par_trace_var_name => 'FILE_ID', par_trace_var_value => v_file_id);
    trace('JSON разобран');
  
    v_policy_header_id := get_policy_from_gate_by_ids(par_ids           => v_ids
                                                     ,par_b2b_policy_id => v_b2b_policy_id);
  
    /* Проверяем имеет ли данный клиент доступ к данному продукту */
    check_access_to_policy(par_pol_header_id => v_policy_header_id);
  
    /* Получение информации по файлу для передачи */
    trace('Получение информации по файлу');
    v_stored_files_body := dml_stored_files_body.get_record(v_file_id);
    IF v_stored_files_body.stored_files_body_id IS NULL
    THEN
      ex.raise(par_message => 'Файл (file_id = ' || to_char(v_file_id) || ') не существует'
              ,par_sqlcode => ex.c_no_data_found);
    ELSIF v_stored_files_body.stored_fb IS NULL
    THEN
      ex.raise(par_message => 'У файла (file_id = ' || to_char(v_file_id) ||
                              ') отсутствует содержимое'
              ,par_sqlcode => ex.c_no_data_found);
    END IF;
  
    /* Отправляем файл */
    trace('Отправка файла');
    IF gv_debug
    THEN
      v_log_info.source_pkg_name       := gc_pkg_name;
      v_log_info.source_procedure_name := vc_proc_name;
      v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
    END IF;
  
    pkg_communication.response_with_file(par_file      => v_stored_files_body.stored_fb
                                        ,par_file_name => v_stored_files_body.file_origin_name
                                        ,par_log_info  => v_log_info);
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
  END get_file;

  /*
    Пиядин А.
    Процедура получения сообщения из B2B
  */
  PROCEDURE send_message(par_data JSON) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'send_message';
  
    v_ids              p_pol_header.ids%TYPE;
    v_b2b_policy_id    g_policy.policy_b2b_id%TYPE;
    v_message_text     t_chat_message.message_text%TYPE;
    v_file_list        tt_file_list := tt_file_list();
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
    v_t_chat_message   dml_t_chat_message.tt_t_chat_message;
    v_log_info         pkg_communication.typ_log_info;
  
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
  
    /* Разбор JSON */
    v_ids := par_data.get('ids').get_number;
  
    IF par_data.exist('policy_id')
    THEN
      v_b2b_policy_id := par_data.get('policy_id').get_number;
    END IF;
  
    IF par_data.exist('message_text')
    THEN
      v_message_text := par_data.get('message_text').get_string;
    END IF;
  
    pkg_trace.add_variable(par_trace_var_name => 'IDS', par_trace_var_value => v_ids);
    pkg_trace.add_variable(par_trace_var_name  => 'B2B_POLICY_ID'
                          ,par_trace_var_value => v_b2b_policy_id);
    pkg_trace.add_variable(par_trace_var_name  => 'MESSAGE_TEXT'
                          ,par_trace_var_value => v_message_text);
  
    IF par_data.exist('attachments')
    THEN
      DECLARE
        v_file_json_list JSON_LIST := JSON_LIST(par_data.get('attachments'));
        v_file_index     PLS_INTEGER := v_file_list.count;
      BEGIN
        v_file_list.extend(v_file_json_list.count);
        FOR i IN 1 .. v_file_json_list.count
        LOOP
          DECLARE
            v_file      t_file;
            v_file_json JSON := JSON(v_file_json_list.get(i));
          BEGIN
            v_file := t_file(v_file_json.get('file_id').get_number
                            ,v_file_json.get('file_name').get_string);
          
            v_file_list(v_file_index + i) := v_file;
          
            pkg_trace.add_variable(par_trace_var_name  => 'FILE_ID[' || to_char(v_file_index + i) || ']'
                                  ,par_trace_var_value => v_file.file_id);
            pkg_trace.add_variable(par_trace_var_name  => 'FILE_NAME[' || to_char(v_file_index + i) || ']'
                                  ,par_trace_var_value => v_file.file_name);
          END;
        END LOOP;
      END;
    END IF;
    trace('JSON разобран');
  
    v_policy_header_id := get_policy_from_gate_by_ids(par_ids           => v_ids
                                                     ,par_b2b_policy_id => v_b2b_policy_id);
  
    /* Проверяем имеет ли данный клиент доступ к данному продукту */
    check_access_to_policy(par_pol_header_id => v_policy_header_id);
  
    /* Сохранение сообщения в Борлас */
    v_t_chat_message.parent_uro_id := v_policy_header_id;
    v_t_chat_message.parent_ure_id := ents.id_by_brief('P_POL_HEADER');
    v_t_chat_message.message_text  := v_message_text;
    dml_t_chat_message.insert_record(v_t_chat_message);
  
    /* Добавляем в Advanced Queuing сообщения для принятия файлов из B2B */
    IF par_data.exist('attachments')
    THEN
      FOR i IN v_file_list.first .. v_file_list.last
      LOOP
        DECLARE
          v_aq_chat_message tt_aq_chat_message;
        BEGIN
          v_aq_chat_message := tt_aq_chat_message('get_file' -- operation
                                                 ,v_ids -- ids
                                                 ,v_b2b_policy_id -- b2b_policy_id
                                                 ,v_t_chat_message.t_chat_message_id -- t_chat_message_id
                                                 ,NULL -- message_text
                                                 ,tt_file_list(t_file(v_file_list(i).file_id
                                                                     ,v_file_list(i).file_name)) -- file_list
                                                  );
          /* Постановка сообщения в очередь */
          pkg_chat_message.chat_enqueue(v_aq_chat_message);
        END;
      END LOOP;
    END IF;
  
    /*
       Отправка уведомления на e-mail о непрочитанном входящем сообщении
    */
    DECLARE
      v_recipients pkg_email.t_recipients;
    BEGIN
      -- Коллеги согласились, что на тестовом сервере им все равно будет отправляться письмо
      -- на этот ящик т.к. в теме будет указано, что это тестовое письмо
      -- Подтверждено Титовым О. 20.05.2015
      v_recipients := pkg_email.t_recipients('underwriting@renlife.com');
    
      pkg_email.send_mail_with_attachment(par_to            => v_recipients
                                         ,par_subject       => 'Веб-андеррайтинг: непрочитанное сообщение по дог. ' ||
                                                               v_ids
                                         ,par_text          => 'Внимание!' || chr(10) ||
                                                               'По договору ' || v_ids ||
                                                               ' имеется непрочитанное сообщение с текстом: "' ||
                                                               chr(10) || v_message_text || '"'
                                         ,par_ignore_errors => TRUE);
    END;
  
    /* Формируем ответ */
    trace('Формируем ответ приём сообщения');
    DECLARE
      v_response      JSON := JSON();
      v_response_clob CLOB;
      v_log_info      pkg_communication.typ_log_info;
    BEGIN
    
      v_response.put(gc_status_keyword, gc_status_ok);
      v_response.put(gc_data_keyword, JSON());
    
      dbms_lob.createtemporary(lob_loc => v_response_clob, cache => TRUE);
    
      v_response.to_clob(v_response_clob);
    
      IF gv_debug
      THEN
        v_log_info.source_pkg_name       := gc_pkg_name;
        v_log_info.source_procedure_name := vc_proc_name;
        v_log_info.operation_name        := vc_proc_name || '_RESPONSE';
      END IF;
    
      pkg_communication.htp_lob_response(par_lob => v_response_clob, par_log_info => v_log_info);
    
      -- Очистка памяти
      dbms_lob.freetemporary(v_response_clob);
    END;
  
    -- Trace end
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      trace('ОШИБКА: ' || SQLERRM);
      error_response(vc_proc_name);
  END send_message;

BEGIN
  DECLARE
    v_test NUMBER(1);
  BEGIN
    BEGIN
      SELECT nvl(t.value, 0) INTO v_test FROM t_debug_config t WHERE t.brief = 'LOG_INTEGRATION';
    EXCEPTION
      WHEN no_data_found THEN
        v_test := 0;
    END;
  
    gv_debug := (v_test = 1 OR is_test_server() = 1);
  END;

  IF safety.get_curr_role_name IS NULL
  THEN
    safety.set_curr_role(p_role_name => 'Разработчик');
  END IF;
END pkg_integration;
/
