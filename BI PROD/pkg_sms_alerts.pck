CREATE OR REPLACE PACKAGE pkg_sms_alerts IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 06.05.2013 15:17:37
  -- Purpose : Send and receive sms via MobileMoney Telecom

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations
  is_debug BOOLEAN := FALSE;

  gv_default_send_hour_from CONSTANT NUMBER := 12;
  gv_default_send_hour_to   CONSTANT NUMBER := 17;

  TYPE typ_element_attrs IS TABLE OF VARCHAR2(512) INDEX BY VARCHAR2(512);

  TYPE typ_element IS RECORD(
     NAME  VARCHAR2(256)
    ,attrs typ_element_attrs
    ,VALUE VARCHAR2(32767));

  TYPE typ_elem_list IS TABLE OF typ_element;

  TYPE typ_xml IS RECORD(
     method VARCHAR2(255)
    ,items  typ_elem_list);

  TYPE t_sms IS RECORD(
     msg_number      NUMBER
    ,ogirinator      VARCHAR2(255)
    ,phone_to        VARCHAR2(255)
    ,message         VARCHAR2(32767)
    ,send_date_time  DATE DEFAULT NULL -- Дата и время начала рассылки
    ,send_until_hour NUMBER DEFAULT NULL -- До какого часа необходимо послать
    ,sync_num        NUMBER DEFAULT NULL -- Идентификатор для синхронизации
    );
  TYPE t_sms_list IS TABLE OF t_sms;

  TYPE t_attr IS RECORD(
     attr_name  VARCHAR2(255)
    ,attr_value VARCHAR2(32767));

  TYPE t_attr_list IS TABLE OF t_attr;

  TYPE t_attr2 IS RECORD(
     attr_name  VARCHAR2(255)
    ,attr_value VARCHAR2(32767)
    ,tt         t_attr);
  TYPE t_attr2_list IS TABLE OF t_attr2;

  -- Public function and procedure declarations

  FUNCTION get_default_hour_from RETURN NUMBER;
  FUNCTION get_default_hour_to RETURN NUMBER;

  FUNCTION add_element_to_node
  (
    par_doc           dbms_xmldom.domdocument
   ,par_node          dbms_xmldom.domnode
   ,par_element_name  VARCHAR2
   ,par_element_value VARCHAR2 DEFAULT NULL
  ) RETURN dbms_xmldom.domelement;

  FUNCTION add_element_to_node
  (
    par_doc            dbms_xmldom.domdocument
   ,par_node           dbms_xmldom.domnode
   ,par_element_name   VARCHAR2
   ,par_element_value  VARCHAR2 DEFAULT NULL
   ,par_attribute_list typ_element_attrs
  ) RETURN dbms_xmldom.domelement;

  PROCEDURE create_xml_request
  (
    par_request      typ_xml
   ,par_doc          OUT dbms_xmldom.domdocument
   ,par_request_node OUT dbms_xmldom.domnode
  );

  PROCEDURE add_sms_to_xml
  (
    par_xml            IN OUT typ_xml
   ,par_phone_number   VARCHAR2
   ,par_sms_text       VARCHAR2
   ,par_num_message    NUMBER DEFAULT NULL
   ,par_originator     VARCHAR2 DEFAULT NULL
   ,par_send_date      DATE DEFAULT NULL
   ,par_send_hour_from NUMBER DEFAULT NULL
   ,par_send_hour_to   NUMBER DEFAULT NULL
   ,par_sync_id        NUMBER DEFAULT NULL
  );

  --Основная функция взаимодействия с провайдером с помощью XML
  FUNCTION post_request
  (
    par_request typ_xml
   ,par_url     VARCHAR2 DEFAULT NULL
  ) RETURN typ_xml;

  --Отправка СМС Напоминание ДО
  PROCEDURE send_sms_before
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  );

  --Отправка СМС Напоминание ПОСЛЕ
  PROCEDURE send_sms_after
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  );

  --Отправка СМС Запрос реквизитов
  PROCEDURE send_sms_decline
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  );

  --Отправка СМС Изменение агента
  PROCEDURE send_sms_change_agent
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  );

  --Отправка СМС Уведомление о поступлении средств (о разнесении платежей)
  PROCEDURE send_sms_payment_accepted
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_pp_start_date  DATE
   ,par_pp_end_date    DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  );

  -- Уведомление о снятии с прямого списания
  PROCEDURE send_sms_cancel_direct_writoff
  (
    par_date           DATE DEFAULT SYSDATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  );

  PROCEDURE send_all_sms_types(par_date DATE DEFAULT SYSDATE);

  PROCEDURE check_sms_status(par_force BOOLEAN DEFAULT FALSE);

  PROCEDURE check_balance;

  FUNCTION get_sms_before_text
  (
    par_name_product    VARCHAR2
   ,par_substr_ids      VARCHAR2
   ,par_end_date_header NUMBER
   ,par_child_amount    NUMBER
   ,par_set_off_amount  NUMBER
   ,par_parent_amount   NUMBER
   ,par_s1              NUMBER
   ,par_ids             NUMBER
   ,par_pol_end_date    DATE
   ,par_cur_brief       VARCHAR2
   ,par_st_ds           VARCHAR2
   ,par_coll_method     VARCHAR2
   ,par_sum_amount_idx  NUMBER
   ,par_sum_fee_idx     NUMBER
   ,par_plan_date       DATE
   ,par_amount_invest   NUMBER
  ) RETURN VARCHAR2;
END pkg_sms_alerts;
/
CREATE OR REPLACE PACKAGE BODY pkg_sms_alerts IS

  /*
  Структура запроса на отправку SMS
  
  Запрос: 
  <?xml version="1.0" encoding="utf-8"?>
  <request method="SendSMSFull">
    <login>login</login>
    <pwd>123456</pwd>
    <originator num_message="0">smsmm.ru</originator>
    <phone_to num_message="0">+79226221568</phone_to>
    <message num_message="0">Первое сообщение длинное очень, а посему быть ему разбитым на
    несколько частей, ибо в сотовых сетях размер одного сообщения ограничен</message>
    <from num_message="0">15</from>
    <to num_message="0">18</to>
    <date num_message="0">2009-08-31</date>
    <sync num_message="0">12</sync>
    <originator num_message="1">gege</originator>
    <phone_to num_message="1">+79226221566</phone_to>
    <message num_message="1">Второе сообщение</message>
    <sync num_message="1">13</sync>
  </request>
  
  Ответ:
  <?xml version="1.0" encoding="utf-8"?>
  <response method="SendSMSFull">
    <sms id="1267199920000080924" num_message="0" parts="2" />
    <msg num_message="0">Описание ошибки</msg>
  </response>
  */

  gv_login                  CONSTANT VARCHAR2(255) := 'skrenlife';
  gv_password               CONSTANT VARCHAR2(255) := '123456358';
  gv_default_originator     CONSTANT VARCHAR2(255) := 'RENAISSANCE';
  gv_default_subscriber     CONSTANT VARCHAR2(255) := '{NAME_SUBSCRIBER}';
  gv_default_add_subscriber CONSTANT VARCHAR2(255) := '{ADDITIONAL_SUBSCRIBER}';
  gv_namespaceuri           CONSTANT VARCHAR2(255) := 'http://www.w3.org/2001/XMLSchema';
  gv_default_root_tag       CONSTANT VARCHAR2(255) := 'request';
  gv_target_url             CONSTANT VARCHAR2(300) := 'gate.mobilmoney.ru';

  gv_debug        BOOLEAN := TRUE;
  gv_log_requests BOOLEAN := FALSE;
  --gv_debug_phone_number VARCHAR2(12) := '+79639985998';
  gv_debug_phone_number tt_one_col := tt_one_col('+79639985998'
                                                 /*,'9104225744'*/
                                                 
                                                 -----------
                                                 /*,'+79154917679'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ,'79154867142'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ,'79854581614'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ,'79268417808'*/
                                                 ------------
                                                 
                                                 /*,'79636513912'*/);
  gv_responsible_person VARCHAR2(255) := 'pavel.kaplya@renlife.com';
  gv_operation_name     VARCHAR2(4000);

  TYPE ref_cr IS REF CURSOR;

  FUNCTION get_default_hour_from RETURN NUMBER IS
  BEGIN
    RETURN gv_default_send_hour_from;
  END get_default_hour_from;
  FUNCTION get_default_hour_to RETURN NUMBER IS
  BEGIN
    RETURN gv_default_send_hour_to;
  END get_default_hour_to;

  FUNCTION format_phone_number(par_orig_phone_number VARCHAR2) RETURN VARCHAR2 IS
    v_orig_phone_number VARCHAR2(50);
    v_phone_number      VARCHAR2(50);
  BEGIN
    v_orig_phone_number := regexp_replace(srcstr => par_orig_phone_number, pattern => '[^[:digit:]]');
  
    IF length(v_orig_phone_number) = 10
    THEN
      v_phone_number := '+7' || v_orig_phone_number;
    ELSIF length(v_orig_phone_number) = 11
          AND substr(v_orig_phone_number, 1, 1) IN (7, 8)
    THEN
      v_phone_number := '+7' || substr(v_orig_phone_number, 2, 10);
    ELSIF length(v_orig_phone_number) = 7
    THEN
      v_phone_number := '+7985' || v_orig_phone_number;
    ELSE
      v_phone_number := v_orig_phone_number;
    END IF;
  
    RETURN v_phone_number;
  
  END format_phone_number;

  FUNCTION add_element_to_node
  (
    par_doc           dbms_xmldom.domdocument
   ,par_node          dbms_xmldom.domnode
   ,par_element_name  VARCHAR2
   ,par_element_value VARCHAR2 DEFAULT NULL
  ) RETURN dbms_xmldom.domelement IS
    v_element      dbms_xmldom.domelement;
    v_element_node dbms_xmldom.domnode;
    v_data         dbms_xmldom.domtext;
    v_data_node    dbms_xmldom.domnode;
  BEGIN
  
    v_element      := dbms_xmldom.createelement(doc => par_doc, tagname => par_element_name);
    v_element_node := dbms_xmldom.appendchild(n        => par_node
                                             ,newchild => dbms_xmldom.makenode(v_element));
  
    IF TRIM(par_element_value) IS NOT NULL
    THEN
      v_data      := dbms_xmldom.createtextnode(doc => par_doc, data => par_element_value);
      v_data_node := dbms_xmldom.appendchild(n        => v_element_node
                                            ,newchild => dbms_xmldom.makenode(v_data));
    END IF;
  
    RETURN v_element;
  END add_element_to_node;

  FUNCTION add_element_to_node
  (
    par_doc            dbms_xmldom.domdocument
   ,par_node           dbms_xmldom.domnode
   ,par_element_name   VARCHAR2
   ,par_element_value  VARCHAR2 DEFAULT NULL
   ,par_attribute_list typ_element_attrs
  ) RETURN dbms_xmldom.domelement IS
    v_element              dbms_xmldom.domelement;
    v_current_element_name VARCHAR2(512);
  BEGIN
  
    v_element := add_element_to_node(par_doc           => par_doc
                                    ,par_node          => par_node
                                    ,par_element_name  => par_element_name
                                    ,par_element_value => par_element_value);
  
    v_current_element_name := par_attribute_list.first;
    LOOP
      EXIT WHEN v_current_element_name IS NULL;
      dbms_xmldom.setattribute(elem     => v_element
                              ,NAME     => v_current_element_name
                              ,newvalue => par_attribute_list(v_current_element_name));
      v_current_element_name := par_attribute_list.next(v_current_element_name);
    END LOOP;
  
    RETURN v_element;
  END add_element_to_node;

  PROCEDURE create_xml_request
  (
    par_request      typ_xml
   ,par_doc          OUT dbms_xmldom.domdocument
   ,par_request_node OUT dbms_xmldom.domnode
  ) IS
    v_request_element dbms_xmldom.domelement;
    v_temp_element    dbms_xmldom.domelement;
    v_items           typ_elem_list;
  BEGIN
    -- Создаем спицификацию XML-документа
    par_doc := dbms_xmldom.createdocument(namespaceuri  => gv_namespaceuri
                                         ,qualifiedname => NULL
                                         ,doctype       => NULL);
    dbms_xmldom.setversion(doc => par_doc, version => '1.0" encoding="UTF-8');
  
    -- Создаем корневой элемент <request method="MethodName">
    v_request_element := dbms_xmldom.createelement(doc => par_doc, tagname => gv_default_root_tag);
  
    IF par_request.method IS NULL
    THEN
      raise_application_error(-20001
                             ,'Необходимо указать значение поля method.');
    END IF;
  
    dbms_xmldom.setattribute(elem     => v_request_element
                            ,NAME     => 'method'
                            ,newvalue => par_request.method);
    par_request_node := dbms_xmldom.appendchild(n        => dbms_xmldom.makenode(par_doc)
                                               ,newchild => dbms_xmldom.makenode(v_request_element));
  
    -- Записываем данные аутентификации                                              
    v_temp_element := add_element_to_node(par_doc           => par_doc
                                         ,par_node          => par_request_node
                                         ,par_element_name  => 'login'
                                         ,par_element_value => gv_login);
    v_temp_element := add_element_to_node(par_doc           => par_doc
                                         ,par_node          => par_request_node
                                         ,par_element_name  => 'pwd'
                                         ,par_element_value => gv_password);
  
    IF par_request.items IS NOT NULL
    THEN
    
      v_items := par_request.items;
      FOR i IN v_items.first .. v_items.last
      LOOP
        DECLARE
          v_element         typ_element;
          v_new_dom_element dbms_xmldom.domelement;
        BEGIN
          v_element         := v_items(i);
          v_new_dom_element := add_element_to_node(par_doc            => par_doc
                                                  ,par_node           => par_request_node
                                                  ,par_element_name   => v_element.name
                                                  ,par_element_value  => v_element.value
                                                  ,par_attribute_list => v_element.attrs);
        END;
      END LOOP;
    END IF;
  END create_xml_request;

  FUNCTION parse_xml_doc(par_doc dbms_xmldom.domdocument) RETURN typ_xml IS
    v_resp_root_element dbms_xmldom.domelement;
    v_resp_node_list    dbms_xmldom.domnodelist;
    v_res_xml           typ_xml;
  BEGIN
    -- Парсим XML, сохраняем результаты.
    v_resp_root_element := dbms_xmldom.getdocumentelement(doc => par_doc);
    v_res_xml.method    := dbms_xmldom.getattribute(elem => v_resp_root_element, NAME => 'method');
  
    v_resp_node_list := dbms_xmldom.getchildnodes(dbms_xmldom.makenode(v_resp_root_element));
  
    -- Парсим элементы ответа
    v_res_xml.items := typ_elem_list();
    v_res_xml.items.extend(dbms_xmldom.getlength(v_resp_node_list));
    FOR i IN 0 .. (dbms_xmldom.getlength(v_resp_node_list) - 1)
    LOOP
    
      DECLARE
        v_child          dbms_xmldom.domnode;
        v_attr           dbms_xmldom.domnode;
        v_named_node_map dbms_xmldom.domnamednodemap;
        v_element        typ_element;
      BEGIN
      
        v_child := dbms_xmldom.item(v_resp_node_list, i);
      
        v_element.name  := dbms_xmldom.getnodename(v_child);
        v_element.value := dbms_xmldom.getnodevalue(dbms_xmldom.getfirstchild(v_child));
      
        v_named_node_map := dbms_xmldom.getattributes(v_child);
        FOR j IN 0 .. (dbms_xmldom.getlength(v_named_node_map) - 1)
        LOOP
          DECLARE
            v_name  VARCHAR2(511);
            v_value VARCHAR2(4000);
          BEGIN
            v_attr := dbms_xmldom.item(nnm => v_named_node_map, idx => j);
            --v_element.attrs(dbms_xmldom.getNodeName(v_attr)) := dbms_xmldom.getNodeValue(v_attr);
            v_name := dbms_xmldom.getnodename(v_attr);
            v_value := dbms_xmldom.getnodevalue(v_attr);
            v_element.attrs(v_name) := v_value;
          END;
        
        END LOOP;
      
        v_res_xml.items(i + 1) := v_element;
      
      END;
    END LOOP;
  
    dbms_xmldom.freedocument(par_doc);
  
    RETURN v_res_xml;
  END parse_xml_doc;

  PROCEDURE add_sms_to_xml
  (
    par_xml            IN OUT typ_xml
   ,par_phone_number   VARCHAR2
   ,par_sms_text       VARCHAR2
   ,par_num_message    NUMBER DEFAULT NULL
   ,par_originator     VARCHAR2 DEFAULT NULL
   ,par_send_date      DATE DEFAULT NULL
   ,par_send_hour_from NUMBER DEFAULT NULL
   ,par_send_hour_to   NUMBER DEFAULT NULL
   ,par_sync_id        NUMBER DEFAULT NULL
  ) IS
    v_element typ_element;
    v_index   NUMBER;
  BEGIN
    IF par_xml.items IS NULL
    THEN
      par_xml.items := typ_elem_list();
      par_xml.items.extend(3);
      v_index := par_xml.items.first;
    ELSE
      v_index := par_xml.items.last;
    
      par_xml.items.extend(3);
      v_index := par_xml.items.next(v_index);
    END IF;
  
    -- Заполняем обязательные поля
    v_element.name := 'originator';
    v_element.value := nvl(par_originator, gv_default_originator);
    v_element.attrs('num_message') := par_num_message;
    par_xml.items(v_index) := v_element;
    v_index := par_xml.items.next(v_index);
  
    v_element.name := 'phone_to';
    v_element.value := par_phone_number;
    v_element.attrs('num_message') := par_num_message;
    par_xml.items(v_index) := v_element;
    v_index := par_xml.items.next(v_index);
  
    v_element.name := 'message';
    v_element.value := par_sms_text;
    v_element.attrs('num_message') := par_num_message;
    par_xml.items(v_index) := v_element;
  
    --Планировщик рассылки
    IF par_send_date IS NOT NULL
    THEN
      par_xml.items.extend(1);
      v_index := par_xml.items.next(v_index);
    
      v_element.name := 'date';
      v_element.value := to_char(par_send_date, 'YYYY-MM-DD');
      v_element.attrs('num_message') := par_num_message;
      par_xml.items(v_index) := v_element;
    END IF;
  
    IF par_send_hour_from IS NOT NULL
    THEN
      IF par_send_hour_from > 24
         OR par_send_hour_from < 0
      THEN
        raise_application_error(-20001
                               ,'Час отправки СМС не может быть отрицательным или больше 24.');
      END IF;
      par_xml.items.extend(1);
      v_index := par_xml.items.next(v_index);
    
      v_element.name := 'from';
      v_element.value := trunc(par_send_hour_from);
      v_element.attrs('num_message') := par_num_message;
      par_xml.items(v_index) := v_element;
    END IF;
  
    IF par_send_hour_to IS NOT NULL
    THEN
      IF par_send_hour_to > 24
         OR par_send_hour_to < 0
      THEN
        raise_application_error(-20001
                               ,'Час, до которого необходимо отправить СМС, не может быть отрицательным или больше 24.');
      END IF;
      par_xml.items.extend(1);
      v_index := par_xml.items.next(v_index);
    
      v_element.name := 'to';
      v_element.value := trunc(par_send_hour_to);
      v_element.attrs('num_message') := par_num_message;
      par_xml.items(v_index) := v_element;
    END IF;
  
    IF par_sync_id IS NOT NULL
    THEN
      par_xml.items.extend(1);
      v_index := par_xml.items.next(v_index);
    
      v_element.name := 'sync';
      v_element.value := trunc(par_send_hour_to);
      v_element.attrs('num_message') := par_num_message;
      par_xml.items(v_index) := v_element;
    END IF;
  
  END add_sms_to_xml;

  PROCEDURE convert_clob
  (
    par_clob     IN OUT CLOB
   ,par_encoding VARCHAR2
  ) IS
    l_no_of_pieces NUMBER := NULL;
    l_bufsize      NUMBER := 2000;
    l_string       VARCHAR2(10000) := NULL;
    l_start        NUMBER := 1;
    l_length       NUMBER := NULL;
    l_amount       NUMBER := NULL;
    v_new_clob     CLOB;
  BEGIN
    dbms_lob.createtemporary(lob_loc => v_new_clob, cache => TRUE);
    l_length       := dbms_lob.getlength(par_clob);
    l_no_of_pieces := trunc(l_length / l_bufsize) + sign(MOD(l_length, l_bufsize));
    FOR i IN 1 .. l_no_of_pieces
    LOOP
      l_amount   := least(l_bufsize, l_length - l_start + 1);
      l_string   := dbms_lob.substr(par_clob, l_amount, l_start);
      v_new_clob := v_new_clob || convert(l_string, par_encoding);
      l_start    := l_start + l_bufsize;
    END LOOP;
    dbms_lob.copy(dest_lob => par_clob
                 ,src_lob  => v_new_clob
                 ,amount   => dbms_lob.getlength(v_new_clob));
    dbms_lob.freetemporary(lob_loc => v_new_clob);
  END;

  FUNCTION post_request
  (
    par_request typ_xml
   ,par_url     VARCHAR2 DEFAULT NULL
  ) RETURN typ_xml IS
    v_doc       dbms_xmldom.domdocument;
    v_root_node dbms_xmldom.domnode;
    v_post      CLOB;
    v_answer    CLOB;
    v_log_info  pkg_communication.typ_log_info;
    v_proc_name VARCHAR2(255) := 'post_request';
  
    v_url t_b2b_props_vals.props_value%TYPE;
  BEGIN
    -- Создаем полноценный запрос виде XML-документа
    create_xml_request(par_request => par_request, par_doc => v_doc, par_request_node => v_root_node);
    dbms_lob.createtemporary(lob_loc => v_post, cache => TRUE);
  
    -- Конвертируем его в CLOB
    --dbms_lob.copy(dest_lob => v_post,src_lob => dbms_xmldom.getxmltype(v_doc).getClobVal(),amount => dbms_lob.getlength(dbms_xmldom.getxmltype(v_doc).getClobVal()));
    dbms_xmldom.writetoclob(doc => v_doc, cl => v_post);
    --v_post := dbms_xmldom.getxmltype(v_doc).getClobVal();
    IF gv_debug
    THEN
      DECLARE
        l_offset NUMBER := 1;
        v_str    VARCHAR2(32767);
      BEGIN
        dbms_output.put_line('------REQUEST--------');
        dbms_output.put_line('');
        LOOP
          EXIT WHEN l_offset > dbms_lob.getlength(v_post);
          v_str := dbms_lob.substr(lob_loc => v_post, amount => 255, offset => l_offset);
          dbms_output.put(v_str);
          l_offset := l_offset + 255;
        END LOOP;
        dbms_output.new_line;
      END;
    END IF;
  
    IF gv_log_requests
    THEN
      v_log_info.source_pkg_name       := 'pkg_sms_alerts';
      v_log_info.source_procedure_name := v_proc_name;
      v_log_info.operation_name        := gv_operation_name;
    END IF;
  
    --dbms_xmldom.writeToCLOB(doc => v_doc, cl => v_post, charset => gv_default_encoding);
    dbms_xmldom.freedocument(doc => v_doc);
  
    -- Отправляем запрос на сервер, получаем ответ в виде CLOB
    convert_clob(par_clob => v_post, par_encoding => 'UTF8');
  
    --Получаем URL
    v_url := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'SEND_SMS'
                                             ,par_props_type_brief => 'URL');
  
    v_answer := pkg_communication.request(par_send          => v_post
                                         ,par_url           => nvl(par_url, v_url)
                                         ,par_content_type  => 'text/plain; charset=windows-1251'
                                         ,par_log_info      => v_log_info
                                         ,par_use_def_proxy => TRUE);
  
    -- Конвертируем ответ в typ_xml, и возвращаем
    dbms_lob.freetemporary(v_post);
    IF gv_debug
    THEN
      DECLARE
        l_offset NUMBER := 1;
        v_str    VARCHAR2(32767);
      BEGIN
        dbms_output.put_line('------RESPONSE--------');
        dbms_output.put_line('');
        LOOP
          EXIT WHEN l_offset > dbms_lob.getlength(v_answer);
          v_str := dbms_lob.substr(lob_loc => v_answer, amount => 255, offset => l_offset);
          dbms_output.put(v_str);
          l_offset := l_offset + 255;
        END LOOP;
        dbms_output.new_line;
      END;
    END IF;
  
    RETURN parse_xml_doc(dbms_xmldom.newdomdocument(cl => v_answer));
  
  END post_request;

  PROCEDURE add_to_request_and_journal
  (
    par_request        IN OUT typ_xml
   ,par_phone_number   VARCHAR2
   ,par_subj_message   VARCHAR2
   ,par_sms_text       VARCHAR2
   ,par_num_message    NUMBER
   ,par_pol_header_id  NUMBER
   ,par_contact_id     NUMBER
   ,par_batch_id       NUMBER
   ,par_originator     VARCHAR2 DEFAULT gv_default_originator
   ,par_send_date      DATE DEFAULT NULL
   ,par_send_hour_from NUMBER DEFAULT NULL
   ,par_send_hour_to   NUMBER DEFAULT NULL
   ,par_sync_id        NUMBER DEFAULT NULL
  ) IS
    v_phone_number VARCHAR2(12);
  BEGIN
  
    v_phone_number := format_phone_number(par_phone_number);
  
    IF v_phone_number IS NOT NULL
    THEN
    
      INSERT INTO ven_inoutput_info
        (descript_message
        ,index_number
        ,initiator_send
        ,pol_header_id
        ,props
        ,receiver_contact_id
        ,reg_date
        ,state_date
        ,subj_message
        ,t_message_kind_id
        ,t_message_props_id
        ,t_message_state_id
        ,t_message_type_id
        ,user_name_change
        ,user_name_loaded
        ,t_sms_batch_id)
      VALUES
        (par_sms_text
        ,par_num_message
        ,'INS'
        ,par_pol_header_id
        ,v_phone_number --props
        ,par_contact_id
        ,trunc(SYSDATE) --reg_date
        ,SYSDATE --state_date
        ,par_subj_message --subj_message
        ,(SELECT t.t_message_kind_id FROM t_message_kind t WHERE t.message_kind_brief = 'OUTPUT')
        ,(SELECT t.t_message_type_props_id
           FROM t_message_type_props t
          WHERE t.message_props_brief = 'TELEPHONE')
        ,(SELECT t.t_message_state_id FROM t_message_state t WHERE t.message_state_brief = 'POSTED')
        ,(SELECT t.t_message_type_id FROM t_message_type t WHERE t.message_type_brief = 'SMS')
        ,'INS'
        ,'INS'
        ,par_batch_id);
    
      add_sms_to_xml(par_xml            => par_request
                    ,par_phone_number   => v_phone_number
                    ,par_sms_text       => par_sms_text
                    ,par_num_message    => par_num_message
                    ,par_originator     => nvl(par_originator, gv_default_originator)
                    ,par_send_date      => trunc(par_send_date)
                    ,par_send_hour_from => par_send_hour_from
                    ,par_send_hour_to   => par_send_hour_to
                    ,par_sync_id        => par_sync_id);
    
    END IF;
  
  END add_to_request_and_journal;

  PROCEDURE update_journal_posted_status
  (
    par_batch_id NUMBER
   ,par_response typ_xml
  ) IS
    v_post_error_state_id NUMBER;
  BEGIN
    SELECT t.t_message_state_id
      INTO v_post_error_state_id
      FROM t_message_state t
     WHERE t.message_state_brief = 'POST_ERROR';
  
    FOR i IN par_response.items.first .. par_response.items.last
    LOOP
      DECLARE
        v_element typ_element;
      BEGIN
        v_element := par_response.items(i);
        IF v_element.name = 'sms'
        THEN
          UPDATE inoutput_info t
             SET t.identity = v_element.attrs('id')
           WHERE t.t_sms_batch_id = par_batch_id
             AND t.index_number = v_element.attrs('num_message');
        
        ELSIF v_element.name = 'msg'
        THEN
        
          UPDATE inoutput_info t
             SET t.note               = v_element.value
                ,t.t_message_state_id = v_post_error_state_id
           WHERE t.t_sms_batch_id = par_batch_id
             AND t.index_number = v_element.attrs('num_message');
        
        END IF;
      END;
    
    END LOOP;
  END update_journal_posted_status;

  PROCEDURE process_sms_report
  (
    par_cursor         ref_cr
   ,par_subj_message   VARCHAR2 DEFAULT NULL
   ,par_originator     VARCHAR2 DEFAULT gv_default_originator
   ,par_send_hour_from NUMBER DEFAULT NULL
   ,par_send_hour_to   NUMBER DEFAULT NULL
  ) IS
    v_batch_id         NUMBER;
    v_request          typ_xml;
    v_response         typ_xml;
    v_tel              VARCHAR2(255);
    v_ids              p_pol_header.ids%TYPE;
    v_contact_id       contact.contact_id%TYPE;
    v_rownumber        NUMBER;
    v_text_field       VARCHAR2(32767);
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
  
  BEGIN
    v_request.method := 'SendSMSFull';
    SELECT sq_t_sms_batch.nextval INTO v_batch_id FROM dual;
  
    INSERT INTO ven_t_sms_batch
      (t_sms_batch_id, reg_date, subj_message)
    VALUES
      (v_batch_id, trunc(SYSDATE), par_subj_message);
  
    LOOP
      FETCH par_cursor
        INTO v_rownumber
            ,v_contact_id
            ,v_ids
            ,v_policy_header_id
            ,v_tel
            ,v_text_field;
    
      EXIT WHEN par_cursor%NOTFOUND OR(gv_debug AND par_cursor%ROWCOUNT > gv_debug_phone_number.count);
    
      IF gv_debug
      THEN
        v_tel := gv_debug_phone_number(v_rownumber);
      END IF;
    
      add_to_request_and_journal(par_request        => v_request
                                ,par_phone_number   => v_tel
                                ,par_subj_message   => par_subj_message
                                ,par_sms_text       => v_text_field
                                ,par_num_message    => v_rownumber
                                ,par_pol_header_id  => v_policy_header_id
                                ,par_contact_id     => v_contact_id
                                ,par_batch_id       => v_batch_id
                                ,par_originator     => nvl(par_originator, gv_default_originator)
                                ,par_send_hour_from => par_send_hour_from
                                ,par_send_hour_to   => par_send_hour_to);
    END LOOP;
  
    IF v_request.items IS NOT NULL
       AND v_request.items.count > 0
    THEN
      BEGIN
      
        v_response := post_request(par_request => v_request);
      
      EXCEPTION
        WHEN OTHERS THEN
          pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients(gv_responsible_person)
                                             ,par_subject => 'Ошибка взаимодействия с провайдером СМС'
                                             ,par_text    => 'Ошибка при отправке пула сообщений: ' ||
                                                             nvl(par_subj_message, 'NULL') || chr(10) ||
                                                             ' Ошибка: ' || SQLERRM);
          RAISE;
      END;
      update_journal_posted_status(par_batch_id => v_batch_id, par_response => v_response);
    ELSE
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients(gv_responsible_person)
                                         ,par_subject => 'Предупреждение! Взаимодействия с провайдером СМС'
                                         ,par_text    => 'СМС (тема: ' ||
                                                         nvl(par_subj_message, 'NULL') ||
                                                         ') отправлены не были т.к. отчет не выдал записи.');
    END IF;
  
  END process_sms_report;

  PROCEDURE send_sms_before
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  ) IS
    v_cursor             ref_cr;
    v_originator         VARCHAR2(255) := gv_default_originator;
    v_subj_message       VARCHAR2(1023) := 'смс до';
    v_write_param_result VARCHAR2(4000);
    v_test               VARCHAR2(255);
  BEGIN
  
    IF gv_debug
    THEN
      v_test := ' (ТЕСТ!)';
    END IF;
  
    IF par_start_date IS NULL
       OR par_end_date IS NULL
       OR par_start_date > par_end_date
    THEN
      raise_application_error(-20001
                             ,'Неверно заданы параметры вызова процедуры');
    END IF;
  
    gv_operation_name := 'send_sms_before';
  
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_before'
                                                                       ,p_param_name  => 'date_from'
                                                                       ,p_param_value => to_char(par_start_date
                                                                                                ,'DD.MM.YYYY'));
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_before'
                                                                       ,p_param_name  => 'date_to'
                                                                       ,p_param_value => to_char(par_end_date
                                                                                                ,'DD.MM.YYYY'));
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_before'
                                                                       ,p_param_name  => 'order_num'
                                                                       ,p_param_value => 1);
  
    OPEN v_cursor FOR
      SELECT rownum rn
            ,t.contact_id
            ,ids
            ,(SELECT policy_header_id FROM p_pol_header ph WHERE ph.ids = t.ids) policy_header_id
            ,tel
            ,text_field
        FROM v_sms_report_before t
       WHERE tel IS NOT NULL;
  
    BEGIN
      process_sms_report(par_cursor         => v_cursor
                        ,par_subj_message   => v_subj_message
                        ,par_originator     => v_originator
                        ,par_send_hour_from => par_send_hour_from
                        ,par_send_hour_to   => par_send_hour_to);
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE v_cursor;
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Yana.Tihonova@Renlife.com'
                                                                                 ,'Ekaterina.Kapralova@Renlife.com'
                                                                                 ,'Olga.Saveleva@Renlife.com'
                                                                                 ,'pavel.kaplya@renlife.com')
                                           ,par_subject => 'ОШИБКА - Реестр «СМС До»' || v_test
                                           ,par_text    => 'Во время отправки Реестра «СМС До» за период C ' ||
                                                           nvl(to_char(trunc(par_start_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' ПО ' ||
                                                           nvl(to_char(trunc(par_end_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' произошла ошибка. ' ||
                                                           chr(10) || 'Текст ошибки: ' || SQLERRM);
        RAISE;
    END;
    CLOSE v_cursor;
  
    pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Yana.Tihonova@Renlife.com'
                                                                             ,'Ekaterina.Kapralova@Renlife.com'
                                                                             ,'Olga.Saveleva@Renlife.com')
                                       ,par_cc      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                       ,par_subject => 'Реестр «СМС До»' || v_test
                                       ,par_text    => 'Реестр «СМС До» за период C ' ||
                                                       nvl(to_char(trunc(par_start_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' ПО ' ||
                                                       nvl(to_char(trunc(par_end_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' успешно отправлен провайдеру');
  
  END send_sms_before;

  PROCEDURE send_sms_after
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  ) IS
    v_cursor             ref_cr;
    v_originator         VARCHAR2(255) := gv_default_originator;
    v_subj_message       VARCHAR2(1023) := 'смс после';
    v_write_param_result VARCHAR2(4000);
    v_test               VARCHAR2(255);
  BEGIN
  
    IF gv_debug
    THEN
      v_test := ' (ТЕСТ!)';
    END IF;
  
    IF par_start_date IS NULL
       OR par_end_date IS NULL
       OR par_start_date > par_end_date
    THEN
      raise_application_error(-20001
                             ,'Неверно заданы параметры вызова процедуры');
    END IF;
  
    gv_operation_name := 'send_sms_after';
  
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_after'
                                                                       ,p_param_name  => 'date_from'
                                                                       ,p_param_value => to_char(par_start_date
                                                                                                ,'DD.MM.YYYY'));
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_after'
                                                                       ,p_param_name  => 'date_to'
                                                                       ,p_param_value => to_char(par_end_date
                                                                                                ,'DD.MM.YYYY'));
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_after'
                                                                       ,p_param_name  => 'order_num'
                                                                       ,p_param_value => 1);
  
    OPEN v_cursor FOR
      SELECT rownum rn
            ,t.contact_id
            ,ids
            ,(SELECT policy_header_id FROM p_pol_header ph WHERE ph.ids = t.ids) policy_header_id
            ,tel
            ,text_field
        FROM v_sms_report_after t
       WHERE tel IS NOT NULL;
  
    BEGIN
      process_sms_report(par_cursor         => v_cursor
                        ,par_subj_message   => v_subj_message
                        ,par_originator     => v_originator
                        ,par_send_hour_from => par_send_hour_from
                        ,par_send_hour_to   => par_send_hour_to);
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE v_cursor;
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Yana.Tihonova@Renlife.com'
                                                                                 ,'Ekaterina.Kapralova@Renlife.com'
                                                                                 ,'Olga.Saveleva@Renlife.com'
                                                                                 ,'pavel.kaplya@renlife.com')
                                           ,par_subject => 'ОШИБКА - Реестр «СМС После»' || v_test
                                           ,par_text    => 'Во время отправки Реестра «СМС После» за период C ' ||
                                                           nvl(to_char(trunc(par_start_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' ПО ' ||
                                                           nvl(to_char(trunc(par_end_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' произошла ошибка. ' ||
                                                           chr(10) || 'Текст ошибки: ' || SQLERRM);
        RAISE;
    END;
    CLOSE v_cursor;
  
    pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Yana.Tihonova@Renlife.com'
                                                                             ,'Ekaterina.Kapralova@Renlife.com'
                                                                             ,'Olga.Saveleva@Renlife.com')
                                       ,par_cc      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                       ,par_subject => 'Реестр «СМС После»' || v_test
                                       ,par_text    => 'Реестр «СМС После» за период C ' ||
                                                       nvl(to_char(trunc(par_start_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' ПО ' ||
                                                       nvl(to_char(trunc(par_end_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' успешно отправлен провайдеру');
  
  END send_sms_after;

  PROCEDURE send_sms_decline
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  ) IS
    v_cursor       ref_cr;
    v_originator   VARCHAR2(255) := gv_default_originator;
    v_subj_message VARCHAR2(1023) := 'Запрос реквизитов';
    v_test         VARCHAR2(255);
  BEGIN
  
    IF gv_debug
    THEN
      v_test := ' (ТЕСТ!)';
    END IF;
  
    gv_operation_name := 'send_sms_decline';
  
    OPEN v_cursor FOR
      SELECT rownum              rn
            ,pi.contact_id
            ,ph.ids
            ,ph.policy_header_id
            ,tel_number          tel
            ,text_sms            text_field
        FROM v_sms_report_decline t
            ,v_pol_issuer         pi
            ,p_pol_header         ph
       WHERE tel_number IS NOT NULL
         AND ph.ids = t.ids
         AND ph.policy_id = pi.policy_id
         AND pi.contact_name = t.holder
         AND t.act_date BETWEEN par_start_date AND par_end_date;
  
    BEGIN
      process_sms_report(par_cursor         => v_cursor
                        ,par_subj_message   => v_subj_message
                        ,par_originator     => v_originator
                        ,par_send_hour_from => par_send_hour_from
                        ,par_send_hour_to   => par_send_hour_to);
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE v_cursor;
        RAISE;
      
    END;
    CLOSE v_cursor;
  
  END send_sms_decline;

  PROCEDURE send_sms_change_agent
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  ) IS
    v_cursor             ref_cr;
    v_originator         VARCHAR2(255) := gv_default_originator;
    v_subj_message       VARCHAR2(1023) := 'Изменение агента';
    v_write_param_result VARCHAR2(4000);
    v_test               VARCHAR2(255);
  BEGIN
  
    IF gv_debug
    THEN
      v_test := ' (ТЕСТ!)';
    END IF;
  
    IF par_start_date IS NULL
       OR par_end_date IS NULL
       OR par_start_date > par_end_date
    THEN
      raise_application_error(-20001
                             ,'Неверно заданы параметры вызова процедуры');
    END IF;
  
    gv_operation_name := 'send_sms_change_agent';
  
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_agent'
                                                                       ,p_param_name  => 'date_from'
                                                                       ,p_param_value => to_char(par_start_date
                                                                                                ,'DD.MM.YYYY'));
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_write_param(p_report_name => 'sms_agent'
                                                                       ,p_param_name  => 'date_to'
                                                                       ,p_param_value => to_char(par_end_date
                                                                                                ,'DD.MM.YYYY'));
  
    OPEN v_cursor FOR
      SELECT rownum             rn
            ,t.contact_id
            ,t.ids
            ,t.policy_header_id
            ,t.tel_num          tel
            ,t.text             text_field
        FROM v_sms_change_agent t;
  
    BEGIN
      process_sms_report(par_cursor         => v_cursor
                        ,par_subj_message   => v_subj_message
                        ,par_originator     => v_originator
                        ,par_send_hour_from => par_send_hour_from
                        ,par_send_hour_to   => par_send_hour_to);
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE v_cursor;
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Yana.Tihonova@Renlife.com'
                                                                                 ,'Ekaterina.Kapralova@Renlife.com'
                                                                                 ,'Olga.Saveleva@Renlife.com'
                                                                                 ,'pavel.kaplya@renlife.com')
                                           ,par_subject => 'ОШИБКА - Реестр «Изменение агента»' ||
                                                           v_test
                                           ,par_text    => 'Во время отправки Реестра «Изменение агента» за период C ' ||
                                                           nvl(to_char(trunc(par_start_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' ПО ' ||
                                                           nvl(to_char(trunc(par_end_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' произошла ошибка. ' ||
                                                           chr(10) || 'Текст ошибки: ' || SQLERRM);
        RAISE;
    END;
    CLOSE v_cursor;
  
    pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Yana.Tihonova@Renlife.com'
                                                                             ,'Ekaterina.Kapralova@Renlife.com'
                                                                             ,'Olga.Saveleva@Renlife.com')
                                       ,par_cc      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                       ,par_subject => 'Реестр «Изменение агента»' || v_test
                                       ,par_text    => 'Реестр «Изменение агента» за период C ' ||
                                                       nvl(to_char(trunc(par_start_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' ПО ' ||
                                                       nvl(to_char(trunc(par_end_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' успешно отправлен провайдеру');
  
  END send_sms_change_agent;

  PROCEDURE send_sms_payment_accepted
  (
    par_start_date     DATE
   ,par_end_date       DATE
   ,par_pp_start_date  DATE
   ,par_pp_end_date    DATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  ) IS
    v_cursor             ref_cr;
    v_originator         VARCHAR2(255) := gv_default_originator;
    v_subj_message       VARCHAR2(1023) := 'Уведомление о поступлении денежных средств';
    v_write_param_result VARCHAR2(4000);
    v_test               VARCHAR2(255);
  BEGIN
  
    IF gv_debug
    THEN
      v_test := ' (ТЕСТ!)';
    END IF;
  
    IF par_start_date IS NULL
       OR par_end_date IS NULL
       OR par_start_date > par_end_date
       OR par_pp_start_date IS NULL
       OR par_pp_end_date IS NULL
       OR par_pp_start_date > par_pp_end_date
    THEN
      raise_application_error(-20001
                             ,'Неверно заданы параметры вызова процедуры');
    END IF;
  
    gv_operation_name := 'send_sms_payment_accepted';
  
    v_write_param_result := ins_dwh.pkg_renlife_rep_utils.f_get_period(p_report_type => 'for_sms_report_payment'
                                                                      ,p_startdate   => to_char(par_start_date
                                                                                               ,'DD.MM.YYYY')
                                                                      ,p_enddate     => to_char(par_end_date
                                                                                               ,'DD.MM.YYYY'));
  
    OPEN v_cursor FOR
      SELECT rownum              rn
            ,pi.contact_id
            ,t.ids
            ,ph.policy_header_id
            ,t.tel               tel
            ,t.text_field        text_field
        FROM v_sms_report_payment t
            ,p_pol_header         ph
            ,v_pol_issuer         pi
       WHERE t.ids = ph.ids
         AND t.tel IS NOT NULL
         AND ph.policy_id = pi.policy_id
         AND trunc(t.RECOGNIZE_DATA) BETWEEN par_pp_start_date AND par_pp_end_date;
  
    BEGIN
      process_sms_report(par_cursor         => v_cursor
                        ,par_subj_message   => v_subj_message
                        ,par_originator     => v_originator
                        ,par_send_hour_from => par_send_hour_from
                        ,par_send_hour_to   => par_send_hour_to);
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE v_cursor;
        pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Marina.Ivacheva@Renlife.com'
                                                                                 ,'Irina.Ugodnikova@Renlife.com'
                                                                                 ,'pavel.kaplya@renlife.com')
                                           ,par_subject => 'ОШИБКА - Реестр «Уведомление о поступлении денежных средств»' ||
                                                           v_test
                                           ,par_text    => 'Во время отправки Реестра СМС «Уведомление о поступлении денежных средств» за период C ' ||
                                                           nvl(to_char(trunc(par_start_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' ПО ' ||
                                                           nvl(to_char(trunc(par_end_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' (ПП С ' ||
                                                           nvl(to_char(trunc(par_pp_start_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ' ПО ' ||
                                                           nvl(to_char(trunc(par_pp_end_date)
                                                                      ,'DD.MM.YYYY')
                                                              ,'NULL') || ') произошла ошибка.' ||
                                                           chr(10) || 'Текст ошибки: ' || SQLERRM);
        RAISE;
      
    END;
    CLOSE v_cursor;
  
    pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('Marina.Ivacheva@Renlife.com'
                                                                             ,'Irina.Ugodnikova@Renlife.com')
                                       ,par_cc      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                       ,par_subject => 'Реестр «Уведомление о поступлении денежных средств»' ||
                                                       v_test
                                       ,par_text    => 'Реестр СМС «Уведомление о поступлении денежных средств» за период C ' ||
                                                       nvl(to_char(trunc(par_start_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' ПО ' ||
                                                       nvl(to_char(trunc(par_end_date), 'DD.MM.YYYY')
                                                          ,'NULL') || ' (ПП С ' ||
                                                       nvl(to_char(trunc(par_pp_start_date)
                                                                  ,'DD.MM.YYYY')
                                                          ,'NULL') || ' ПО ' ||
                                                       nvl(to_char(trunc(par_pp_end_date)
                                                                  ,'DD.MM.YYYY')
                                                          ,'NULL') || ') успешно отправлен провайдеру');
  
  END send_sms_payment_accepted;

  PROCEDURE send_sms_cancel_direct_writoff
  (
    par_date           DATE DEFAULT SYSDATE
   ,par_send_hour_from NUMBER DEFAULT gv_default_send_hour_from
   ,par_send_hour_to   NUMBER DEFAULT gv_default_send_hour_to
  ) IS
    v_cursor     ref_cr;
    v_date_start DATE;
    v_date_end   DATE;

    v_originator   VARCHAR2(255) := gv_default_originator;
    v_subj_message VARCHAR2(1023) := 'Уведомление о снятии договора с прямого списания';

    v_test VARCHAR2(255);
  BEGIN

    IF gv_debug
    THEN
      v_test := ' (ТЕСТ!)';
    END IF;

    v_date_start := trunc(par_date, 'iw') - 7;
    v_date_end   := v_date_start + 7 - INTERVAL '1' SECOND;

    OPEN v_cursor FOR
      WITH policies AS
       (SELECT dn.policy_header_id
          FROM dwo_notice dn
              ,document   dc
              ,doc_status ds
         WHERE dn.rejection_reason_id IN
               (SELECT mr.t_mpos_rejection_id FROM t_mpos_rejection mr WHERE mr.brief = 'DOUBLE_WRITEOFF')
           AND dn.dwo_notice_id = dc.document_id
           AND dc.doc_status_id = ds.doc_status_id
           AND ds.start_date BETWEEN v_date_start AND v_date_end),
      mpos_acq AS
       (SELECT 'Mpos' AS payment_tech
              ,dsw.start_date
              ,wf.policy_header_id
          FROM mpos_writeoff_form wf
              ,document           dcw
              ,doc_status         dsw
              ,doc_status_ref     dsrw
         WHERE wf.mpos_writeoff_form_id = dcw.document_id
           AND dcw.doc_status_id = dsw.doc_status_id
           AND dsw.doc_status_ref_id = dsrw.doc_status_ref_id
           AND dsrw.brief = 'CONFIRMED'
        UNION ALL
        SELECT 'интернет' AS payment_tech
              ,dsp.start_date
              ,pt.policy_header_id
          FROM acq_payment_template pt
              ,document             dcp
              ,doc_status           dsp
              ,doc_status_ref       dsrp
         WHERE pt.acq_payment_template_id = dcp.document_id
           AND dcp.doc_status_id = dsp.doc_status_id
           AND dsp.doc_status_ref_id = dsrp.doc_status_ref_id
           AND dsrp.brief = 'CONFIRMED')
      SELECT rownum
            ,contact_id
            ,ids
            ,policy_header_id
            ,tel
            ,text
        FROM (SELECT pi.contact_id
                    ,ph.ids
                    ,ph.policy_header_id
                    ,pkg_contact.get_telephone_number(pi.contact_id
                                                     ,(SELECT tt.id
                                                        FROM t_telephone_type tt
                                                       WHERE tt.description = 'Мобильный')) tel
                    ,'Уважаемый клиент, списание взносов по договору "' || to_char(ph.ids) || '" через ' ||
                     (SELECT MAX(payment_tech) keep(dense_rank FIRST ORDER BY start_date)
                        FROM mpos_acq ma
                       WHERE ma.policy_header_id = pl.policy_header_id) ||
                     ' подключено, ранее действовавшая услуга Прямое списание отменена. Ренессанс Жизнь, 88002005433' AS text
                FROM policies     pl
                    ,p_pol_header ph
                    ,v_pol_issuer pi
               WHERE pl.policy_header_id = ph.policy_header_id
                 AND ph.policy_id = pi.policy_id)
       WHERE trim(tel) IS NOT NULL;

    process_sms_report(par_cursor         => v_cursor
                      ,par_subj_message   => v_subj_message
                      ,par_originator     => v_originator
                      ,par_send_hour_from => par_send_hour_from
                      ,par_send_hour_to   => par_send_hour_to);
    CLOSE v_cursor;
  EXCEPTION
    WHEN OTHERS THEN
      CLOSE v_cursor;
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                         ,par_subject => 'ОШИБКА - ' || v_subj_message || v_test
                                         ,par_text    => 'Во время отправки ' || v_subj_message ||
                                                         ' за ' ||
                                                         nvl(to_char(trunc(par_date), 'DD.MM.YYYY')
                                                            ,'NULL') || ' произошла ошибка. ' || chr(10) ||
                                                         'Текст ошибки: ' || SQLERRM);
      RAISE;
  END send_sms_cancel_direct_writoff;

  PROCEDURE send_all_sms_types(par_date DATE DEFAULT SYSDATE) IS
    v_today         DATE := trunc(par_date);
    v_next_run_date DATE;
    v_run_today     NUMBER(1);
    v_last_work_day DATE;
  BEGIN
    assert_deprecated(par_date IS NULL, 'Параметр даты не указан');
  
    -- Запускаем только по рабочим дням
    SELECT decode(ch.t_type_day, 'Рабочий', 1, 0)
      INTO v_run_today
      FROM t_calendar_holiday ch
     WHERE ch.t_data_day = v_today;
  
    -- Пытаемся отправить СМС.
    -- Если будут ошибки, то переходим к следующему типу отправки смс.
    IF v_run_today = 1
       AND nvl(pkg_app_param.get_app_param_n(p_brief => 'ENABLE_SMS_JOBS'), 0) = 1
    THEN
      SELECT MIN(ch.t_data_day)
        INTO v_next_run_date
        FROM t_calendar_holiday ch
       WHERE ch.t_data_day > v_today
         AND ch.t_type_day = 'Рабочий';
    
      BEGIN
        send_sms_before(par_start_date => v_today + 1 /*to_date('05.06.2013', 'DD.MM.YYYY')*/
                       ,par_end_date   => v_next_run_date); /*to_date('05.06.2013', 'DD.MM.YYYY') */
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      BEGIN
        send_sms_after(par_start_date => v_today + 1 /*to_date('05.06.2013', 'DD.MM.YYYY') */
                      ,par_end_date   => v_next_run_date); /*to_date('05.06.2013', 'DD.MM.YYYY')*/
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      BEGIN
        send_sms_change_agent(par_start_date => v_today + 1 /*to_date('16.05.2013', 'DD.MM.YYYY')*/
                             ,par_end_date   => v_next_run_date); /* to_date('31.05.2013', 'DD.MM.YYYY')*/
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      --Находим последний рабочий день до сегодняшнего дня
      SELECT MAX(ch.t_data_day)
        INTO v_last_work_day
        FROM t_calendar_holiday ch
       WHERE ch.t_data_day < v_today
         AND ch.t_type_day = 'Рабочий';
    
      --v_last_work_day := to_date('30.05.2013', 'DD.MM.YYYY');
    
      BEGIN
        send_sms_payment_accepted(par_start_date    => v_last_work_day /*to_date('20.05.2013', 'DD.MM.YYYY')*/
                                 ,par_end_date      => v_today - 1 /*to_date('26.05.2013', 'DD.MM.YYYY')*/
                                 ,par_pp_start_date => v_last_work_day - 30 /*to_date('20.04.2013', 'DD.MM.YYYY')*/
                                 ,par_pp_end_date   => v_today - 1); /*to_date('20.05.2013', 'DD.MM.YYYY')*/
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      -- Проверяем, первый ли это рабочий день на этой неделе
      DECLARE
        v_first_work_day t_calendar_holiday.t_data_day%TYPE;
      BEGIN
        SELECT MIN(t.t_data_day)
          INTO v_first_work_day
          FROM t_calendar_holiday t
         WHERE t.t_type_day = 'Рабочий'
           AND t.t_data_day BETWEEN trunc(v_today, 'iw') AND trunc(v_today, 'dd');
      
        IF v_first_work_day = v_today
        THEN
          pkg_sms_alerts.send_sms_cancel_direct_writoff(par_date => v_today);
          COMMIT;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
    END IF;
  
    /*  
    -- СМС Запрос реквизитов отправляем 15 числа и в последний день месяца
    IF trunc(SYSDATE) = last_day(trunc(SYSDATE))
       OR extract(DAY FROM SYSDATE) = 15
    THEN
      IF trunc(SYSDATE) = last_day(trunc(SYSDATE))
      THEN
        v_next_run_date := trunc(SYSDATE) + 15;
      ELSE
        v_next_run_date := last_day(trunc(SYSDATE));
      END IF;
    
      send_sms_decline(par_start_date => trunc(SYSDATE) + 1, par_end_date => v_next_run_date);
      
    END IF;*/
  
  END send_all_sms_types;

  /*
  Капля П.
  @param par_sms_id_list - Спико ID СМС для проверки статуса
  
  Пример запроса:
  <?xml version="1.0" encoding="utf-8"?>
  <request method="CheckSMSFull">
    <login>login</login>
    <pwd>123456</pwd>
    <sms_id>1267199920544064825</sms_id>
    <sms_id>1267199920544064825</sms_id>
  </request>
  
  Пример ответа:
  <?xml version="1.0" encoding="utf-8"?>
  <response method="CheckSMSFull">
    <sms id="1267199920544064825" state_id="deliver" state_update="2010-03-09 21:07:51"/>
    <sms id="1267199920544064825" state_id="not_deliver" state_update="2010-03-09
    21:07:51"/>
  </response>
  */
  PROCEDURE check_sms_status(par_force BOOLEAN DEFAULT FALSE) IS
    v_request  typ_xml;
    v_response typ_xml;
    v_force    NUMBER(1);
    c_procedure_name CONSTANT VARCHAR2(30) := 'CHECK_SMS_STATUS';
  
  BEGIN
  
    gv_operation_name := c_procedure_name;
  
    --Заполняем ID-шниками из списка
    v_request.method := 'CheckSMSFull';
    v_request.items  := typ_elem_list();
  
    IF nvl(par_force, FALSE)
    THEN
      v_force := 1;
    ELSE
      v_force := 0;
    END IF;
  
    --Проходим по всем записям журнала информации, у которых статусы 'POSTED' или 'PARTLY_DELIVERED'
    --Проверку СМС можно проводить не чаще чем раз в 2 часа
    FOR rec IN (SELECT ii.identity
                  FROM inoutput_info   ii
                      ,t_message_state ms
                 WHERE ii.t_sms_batch_id IS NOT NULL
                   AND ii.t_message_state_id = ms.t_message_state_id
                   AND ms.message_state_brief IN ('POSTED', 'PARTLY_DELIVERED')
                   AND ii.identity IS NOT NULL
                   AND (SYSDATE - ii.state_date > 2 / 24 OR
                       (ms.message_state_brief = 'POSTED' AND v_force = 1)))
    LOOP
      DECLARE
        v_idx NUMBER;
      BEGIN
        v_request.items.extend(1);
        v_idx := v_request.items.last;
        v_request.items(v_idx).name := 'sms_id';
        v_request.items(v_idx).value := rec.identity;
      END;
    END LOOP;
  
    IF v_request.items.count > 0
    THEN
      -- Отправляем запрос, получаем ответ в виде XML
      v_response := post_request(par_request => v_request);
    
      IF v_response.method != 'ErrorSMS'
      THEN
        --Обновляем статусы в журнале Вх/Исх информации
        FOR i IN 1 .. v_response.items.count
        LOOP
          UPDATE inoutput_info ii
             SET ii.t_message_state_id =
                 (SELECT t_message_state_id
                    FROM t_message_state ms
                   WHERE ms.message_state_brief = CASE v_response.items(i).attrs('state_id')
                           WHEN 'deliver' THEN
                            'DELIVERED'
                           WHEN 'not_deliver' THEN
                            'NODELIVERED'
                           WHEN 'partly_deliver' THEN
                            'PARTLY_DELIVERED'
                         END)
                ,ii.state_date         = SYSDATE /*to_date(v_response.items(i).attrs('state_update')
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ,'YYYY-MM-DD HH24:MI:SS')*/
                ,ii.user_name_change   = USER
                ,ii.send_date          = CASE v_response.items(i).attrs('state_id')
                                           WHEN 'deliver' THEN
                                            to_date(v_response.items(i).attrs('state_update')
                                                   ,'YYYY-MM-DD HH24:MI:SS')
                                           ELSE
                                            NULL
                                         END
           WHERE ii.identity = v_response.items(i).attrs('id');
        END LOOP;
      ELSE
        DECLARE
          v_response_content CLOB;
          v_doc              dbms_xmldom.domdocument;
          v_root_node        dbms_xmldom.domnode;
        BEGIN
        
          dbms_lob.createtemporary(lob_loc => v_response_content, cache => TRUE);
        
          create_xml_request(par_request      => v_response
                            ,par_doc          => v_doc
                            ,par_request_node => v_root_node);
        
          dbms_xmldom.writetoclob(doc => v_doc, cl => v_response_content);
        
          pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients(gv_responsible_person)
                                             ,par_subject => 'Ошибка получения статусов СМС: ' ||
                                                             c_procedure_name
                                             ,par_text    => v_response_content);
        
          dbms_lob.freetemporary(v_response_content);
        END;
      END IF;
    END IF;
  
  END check_sms_status;

  PROCEDURE check_balance IS
    v_request  typ_xml;
    v_response typ_xml;
  BEGIN
  
    gv_operation_name := 'check_balance';
    v_request.method  := 'CheckBalance';
    v_response        := post_request(par_request => v_request);
    dbms_output.put_line(v_response.items(1).name || ' = ' || v_response.items(1).value);
  
  END check_balance;

  FUNCTION get_sms_before_text
  (
    par_name_product    VARCHAR2
   ,par_substr_ids      VARCHAR2
   ,par_end_date_header NUMBER
   ,par_child_amount    NUMBER
   ,par_set_off_amount  NUMBER
   ,par_parent_amount   NUMBER
   ,par_s1              NUMBER
   ,par_ids             NUMBER
   ,par_pol_end_date    DATE
   ,par_cur_brief       VARCHAR2
   ,par_st_ds           VARCHAR2
   ,par_coll_method     VARCHAR2
   ,par_sum_amount_idx  NUMBER
   ,par_sum_fee_idx     NUMBER
   ,par_plan_date       DATE
   ,par_amount_invest   NUMBER
  ) RETURN VARCHAR2 IS
    c_phone_num    CONSTANT VARCHAR2(15) := '(495) 981-2-981';
    c_company_name CONSTANT VARCHAR2(15) := 'Ренессанс Жизнь';
  
    v_text                       VARCHAR2(4000);
    v_pol_end_date_txt           VARCHAR2(10);
    v_pol_end_date_plus_year_txt VARCHAR2(10);
    v_ids_txt                    VARCHAR2(10);
    v_parent_amount_txt          VARCHAR2(15);
    v_sum_fee_idx_txt            VARCHAR2(15);
    v_sum_amount_idx_txt         VARCHAR2(15);
    v_delta_parent_amount        NUMBER;
    v_delta_parent_amount_txt    VARCHAR2(15);
    v_child_amount_nn            NUMBER;
    v_set_off_amount_nn          NUMBER;
    v_is_debt                    BOOLEAN;
    v_debt_amount                NUMBER;
    v_can_pay                    BOOLEAN;
    v_can_pay_through            VARCHAR2(35);
  BEGIN
    v_pol_end_date_txt           := par_pol_end_date;
    v_pol_end_date_plus_year_txt := to_char(ADD_MONTHS(par_pol_end_date, 12), 'DD.MM.YYYY');
    v_ids_txt                    := to_char(par_ids);
    v_parent_amount_txt          := to_char(nvl(par_parent_amount, 0), 'FM999999990D99');
    v_sum_fee_idx_txt            := to_char(par_sum_fee_idx, 'FM999999990D99');
    v_sum_amount_idx_txt         := to_char(par_sum_amount_idx, 'FM999999990D99');
    v_delta_parent_amount        := par_parent_amount - par_s1;
    v_delta_parent_amount_txt    := to_char(v_delta_parent_amount, 'FM999999990D99');
    v_child_amount_nn            := nvl(par_child_amount, 0);
    v_set_off_amount_nn          := nvl(par_set_off_amount, 0);
    v_is_debt                    := (v_child_amount_nn - v_set_off_amount_nn) > par_parent_amount;
    v_debt_amount                := v_child_amount_nn - v_set_off_amount_nn - v_delta_parent_amount;
    v_can_pay                    := (par_cur_brief = 'RUR' AND nvl(v_delta_parent_amount, 0) <= 15000) OR
                                    (par_cur_brief = 'EUR' AND nvl(v_delta_parent_amount, 0) <= 5000) OR
                                    (par_cur_brief = 'USD' AND nvl(v_delta_parent_amount, 0) <= 5000);
    v_can_pay_through            := 'Оплатить взнос можно через ВТБ 24.';
  
    v_text := CASE
                WHEN (((par_name_product = 'Защита APG' AND par_substr_ids = '156') OR
                     (par_name_product IN ('ОПС +', 'ОПС + (New)') AND par_substr_ids = '216')) AND
                     nvl(par_end_date_header, 0) = 1) THEN
                 CASE
                   WHEN CASE
                          WHEN v_is_debt THEN
                           v_debt_amount
                          ELSE
                           0
                        END = 0 THEN
                    'Уважаемый клиент, для продления действия договора страхования №' || v_ids_txt || ' до ' ||
                    v_pol_end_date_plus_year_txt || ' просим Вас оплатить ' || v_parent_amount_txt || ' к ' ||
                    v_pol_end_date_txt || '.' || v_can_pay_through || ' ' || c_company_name || ', ' || ' ' ||
                    c_phone_num
                   ELSE
                    'Уважаемый клиент, для продления действия договора страхования №' || v_ids_txt || ' до ' ||
                    v_pol_end_date_plus_year_txt || ' просим Вас оплатить ' || v_parent_amount_txt ||
                    ' и погасить задолженность ' || to_char(CASE
                                                              WHEN v_is_debt THEN
                                                               v_debt_amount
                                                              ELSE
                                                               0
                                                            END
                                                           ,'FM99999990D99') || ' ' || par_cur_brief ||
                    ' к ' || v_pol_end_date_txt || '.' || v_can_pay_through || ' ' || c_company_name || ', ' || ' ' ||
                    c_phone_num
                 END
                ELSE
                 CASE
                   WHEN par_st_ds = 'INDEXATING' THEN
                    CASE
                      WHEN par_coll_method = 'Прямое списание с карты' THEN
                       'Уважаемый клиент, предлагаем Вам увеличить итоговую сумму накоплений и страховую сумму по основной программе до ' ||
                       v_sum_amount_idx_txt || CASE
                         WHEN par_amount_invest IS NULL THEN
                          ''
                         ELSE
                          ' и и по программе Инвест ' || par_amount_invest
                       END ||
                       ' и, тем самым, защитить свои средства от инфляции, проиндексировав договор страхования №' ||
                       v_ids_txt ||
                       '. В случае согласия с проведением индексации, Вам необходимо оформить новое заявление на списание с карты на сумму ' ||
                       to_char(par_sum_fee_idx, 'FM99999990D99') || ' ' || par_cur_brief || '. ' ||
                       c_company_name || ', ' || c_phone_num
                      ELSE
                       CASE
                         WHEN CASE
                                WHEN v_is_debt THEN
                                 v_debt_amount
                                ELSE
                                 0
                              END = 0 THEN
                          'Уважаемый клиент, предлагаем Вам увеличить итоговую сумму накоплений и страховую сумму по основной программе до ' ||
                          v_sum_amount_idx_txt || ' ' || par_cur_brief || CASE
                            WHEN par_amount_invest IS NULL THEN
                             ''
                            ELSE
                             ' и и по программе Инвест ' || par_amount_invest || ' ' || par_cur_brief
                          END ||
                          ' и, тем самым, защитить свои средства от инфляции, проиндексировав договор страхования №' ||
                          v_ids_txt || '. В случае согласия с проведением индексации, Вам необходимо оплатить ' ||
                          v_sum_fee_idx_txt || ' ' || par_cur_brief || ' к ' ||
                          to_char(par_plan_date, 'dd.mm.yyyy') || '. ' || CASE
                            WHEN v_can_pay THEN
                             v_can_pay_through || ' '
                          END || c_company_name || ', ' || c_phone_num
                         ELSE
                          'Уважаемый клиент, предлагаем Вам увеличить итоговую сумму накоплений и страховую сумму по основной программе до ' ||
                          v_sum_amount_idx_txt || ' ' || par_cur_brief || CASE
                            WHEN par_amount_invest IS NULL THEN
                             ''
                            ELSE
                             ' и и по программе Инвест ' || par_amount_invest || ' ' || par_cur_brief
                          END ||
                          ' и, тем самым, защитить свои средства от инфляции, проиндексировав договор страхования №' ||
                          v_ids_txt || '. В случае согласия с проведением индексации, Вам необходимо оплатить ' ||
                          v_sum_fee_idx_txt || ' ' || par_cur_brief || ' и погасить задолженность ' ||
                          to_char(CASE
                                    WHEN v_is_debt THEN
                                     v_debt_amount
                                    ELSE
                                     0
                                  END
                                 ,'FM99999990D99') || ' ' || par_cur_brief || ' к ' ||
                          to_char(par_plan_date, 'dd.mm.yyyy') || '. ' || CASE
                            WHEN v_can_pay THEN
                             v_can_pay_through || ' '
                          END || c_company_name || ', ' || c_phone_num
                       END
                    END
                   ELSE
                    CASE
                      WHEN CASE
                             WHEN v_is_debt THEN
                              v_debt_amount
                             ELSE
                              0
                           END = 0 THEN
                       'Уважаемый клиент, в случае если Вы еще не внесли очередной платеж по договору страхования №' ||
                       v_ids_txt || ', напоминаем, что Ваш платеж составляет ' || v_delta_parent_amount_txt || ' ' ||
                       par_cur_brief || ', дата платежа ' || to_char(par_plan_date, 'dd.mm.yyyy') || ' ' || CASE
                         WHEN v_can_pay THEN
                          v_can_pay_through || ' '
                       END || c_company_name || ', ' || c_phone_num
                      ELSE
                       'Уважаемый клиент, в случае если Вы еще не внесли очередной платеж по договору страхования №' ||
                       v_ids_txt || ', напоминаем, что Ваш платеж составляет ' || v_delta_parent_amount_txt || ' ' ||
                       par_cur_brief || ', сумма задолженности составляет ' ||
                       to_char(CASE
                                 WHEN v_is_debt THEN
                                  v_debt_amount
                                 ELSE
                                  0
                               END
                              ,'FM99999990D99') || ' ' || par_cur_brief || ', дата платежа ' ||
                       to_char(par_plan_date, 'dd.mm.yyyy') || ' ' || CASE
                         WHEN v_can_pay THEN
                          v_can_pay_through || ' '
                       END || c_company_name || ', ' || c_phone_num
                    END
                 END
              END;
    RETURN v_text;
  END get_sms_before_text;

BEGIN
  DECLARE
    v_db_name  VARCHAR2(511);
    v_log_flag NUMBER(1);
  BEGIN
    -- Initialization
    SELECT ora_database_name INTO v_db_name FROM dual;
    IF v_db_name != 'BPROD01.RENLIFE.COM'
    THEN
      gv_debug := TRUE;
    ELSE
      gv_debug := FALSE;
    END IF;
  
    BEGIN
      SELECT nvl(t.value, 0) INTO v_log_flag FROM t_debug_config t WHERE t.brief = 'SMS_XML_LOG';
      IF v_log_flag = 1
         OR gv_debug
      THEN
        gv_log_requests := TRUE;
      ELSE
        gv_log_requests := FALSE;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        gv_log_requests := FALSE;
    END;
  
  END;

END pkg_sms_alerts; 
/
