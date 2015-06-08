CREATE OR REPLACE PACKAGE pkg_exchange_format IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 11.11.2013 15:50:11
  -- Purpose : Пакет для проверки сообщений внешних сиситем.
  --           Использует настройки справочника "Форматы интеграции"

  -- Невозможно распарсить
  cant_parse_exception CONSTANT NUMBER := -20201;
  cant_parse EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_parse, -20201);

  -- Отсутствует обязательный элемент
  no_element_exception CONSTANT NUMBER := -20202;
  no_element EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_element, -20202);

  -- Отсутствует обязательный атрибут
  no_attribute_exception CONSTANT NUMBER := -20203;
  no_attribute EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_attribute, -20203);

  -- Формат не поддерживается
  format_not_supported_exception CONSTANT NUMBER := -20204;
  format_not_supported EXCEPTION;
  PRAGMA EXCEPTION_INIT(format_not_supported, -20204);

  -- Проверяемое значение пустое
  empty_data_exception CONSTANT NUMBER := -20205;
  empty_data EXCEPTION;
  PRAGMA EXCEPTION_INIT(empty_data, -20205);

  -- Настроенный формат не соответствует ожидаемому формату на выходе
  wrong_format_chosen_exception CONSTANT NUMBER := -20206;
  wrong_format_chosen EXCEPTION;
  PRAGMA EXCEPTION_INIT(wrong_format_chosen, -20206);

  gc_xml  CONSTANT t_exchange_format.format_type%TYPE := 0;
  gc_json CONSTANT t_exchange_format.format_type%TYPE := 1;

  /*
    Проверка соответствия формату
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
  );

  /*
    Проверка соответствия формату
    Сразу передается XMLTYPE
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_xml       xmltype
  );

  /*
    Проверка соответствия формату
    Сразу передается JSON
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_json      JSON
  );

  /*
    Проверка соответствия формату, возвращает JSON
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
   ,par_json      OUT JSON
  );

  /*
    Генерит формат из данных справочников
    Возвращает JSON
  */
  PROCEDURE make_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_json      OUT JSON
  );

  /*
    Генерит формат из данных справочников
    Возвращает XMLTYPE
  */
  PROCEDURE make_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_xml       OUT xmltype
  );

  /*
    Раскладывает JSON в справочники (не возвращает ID)
  */
  PROCEDURE store_format
  (
    par_brief                t_exchange_format.brief%TYPE
   ,par_name                 t_exchange_format.name%TYPE
   ,par_description          t_exchange_format.description%TYPE
   ,par_json                 JSON
   ,par_t_exchange_format_id OUT t_exchange_format.t_exchange_format_id%TYPE
  );

  /*
    Раскладывает JSON в справочники
  */
  PROCEDURE store_format
  (
    par_brief       t_exchange_format.brief%TYPE
   ,par_name        t_exchange_format.name%TYPE
   ,par_description t_exchange_format.description%TYPE
   ,par_json        JSON
  );
END pkg_exchange_format;
/
CREATE OR REPLACE PACKAGE BODY pkg_exchange_format IS

  /*
    Проверка атрибута
  */
  PROCEDURE validate_xml_attribute
  (
    par_element_xpath VARCHAR2
   ,par_element_name  VARCHAR2
   ,par_element_id    NUMBER
   ,par_xml           IN xmltype
  ) IS
  BEGIN
    -- Проверяем наличие обязательных аттрибутов
    FOR vr_attr IN (SELECT tr.name
                          ,tr.description
                      FROM t_exchange_format_attr tr
                     WHERE tr.is_mandatory = 1
                       AND tr.t_exchange_format_elem_id = par_element_id)
    LOOP
      IF par_xml.existsnode(par_element_xpath || '/@' || vr_attr.name) = 1
      THEN
        -- Здесь можно сделать проверку значения
        NULL;
      ELSE
        raise_application_error(no_attribute_exception
                               ,'Отсутствует атрибут "' || vr_attr.name || '" элемента "' ||
                                par_element_name || '"');
      END IF;
    END LOOP;
  END validate_xml_attribute;

  /*
    Проверка элемента XML
  */
  PROCEDURE validate_xml_element
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_xml       xmltype
  ) IS
  BEGIN
    FOR vr_elem IN (SELECT sys_connect_by_path(fe.name, '/') AS xpath
                          ,fe.name
                          ,fe.description
                          ,fe.t_exchange_format_elem_id
                      FROM t_exchange_format_elem fe
                     WHERE fe.is_mandatory = 1
                       AND fe.t_exchange_format_id = par_format_id
                     START WITH fe.parent_id IS NULL
                    CONNECT BY fe.parent_id = PRIOR fe.t_exchange_format_elem_id)
    LOOP
      IF par_xml.existsnode(vr_elem.xpath) = 1
      THEN
        -- Здесь можно сделать проверку значения
      
        -- Проверка атрибутов элемента
        validate_xml_attribute(par_element_xpath => vr_elem.xpath
                              ,par_element_name  => vr_elem.name
                              ,par_element_id    => vr_elem.t_exchange_format_elem_id
                              ,par_xml           => par_xml);
      ELSE
        raise_application_error(no_element_exception
                               ,'Отсутствует элемент "' || vr_elem.name || '" (' ||
                                vr_elem.description || ')');
      END IF;
    END LOOP;
  END validate_xml_element;

  /*
    Проверка элемента JSON
  */
  PROCEDURE validate_json_element
  (
    par_format_id     t_exchange_format.t_exchange_format_id%TYPE
   ,par_json          JSON
   ,par_start_elem_id t_exchange_format_elem.t_exchange_format_elem_id%TYPE DEFAULT NULL
  ) IS
    v_array   JSON_LIST;
    v_element json_value;
  BEGIN
    FOR vr_elem IN (SELECT fe.name
                          ,fe.description
                          ,fe.t_exchange_format_elem_id
                          ,CASE
                             WHEN EXISTS (SELECT *
                                     FROM t_exchange_format_elem elc
                                    WHERE elc.parent_id = fe.t_exchange_format_elem_id) THEN
                              1
                             ELSE
                              0
                           END AS have_children
                          ,fe.is_array
                          ,fe.is_value_mandatory
                      FROM t_exchange_format_elem fe
                     WHERE fe.is_mandatory = 1
                       AND fe.t_exchange_format_id = par_format_id
                       AND (fe.parent_id = par_start_elem_id OR
                           fe.parent_id IS NULL AND par_start_elem_id IS NULL))
    LOOP
      IF par_json.exist(vr_elem.name)
      THEN
        v_element := par_json.get(vr_elem.name);
        IF vr_elem.have_children = 1
        THEN
          IF vr_elem.is_array = 1
             AND v_element.is_array
          THEN
            -- Проверяем все элементы массива
            v_array := JSON_LIST(v_element);
            IF v_array.count > 0
            THEN
              FOR v_array_idx IN 1 .. v_array.count
              LOOP
                validate_json_element(par_format_id     => par_format_id
                                     ,par_json          => JSON(v_array.get(v_array_idx))
                                     ,par_start_elem_id => vr_elem.t_exchange_format_elem_id);
              END LOOP;
            ELSE
              ex.raise('Отсутствуют элементы массива ' || vr_elem.name);
            END IF;
          ELSIF vr_elem.is_array = 1
          THEN
            ex.raise('Элемент ' || vr_elem.name || ' должен быть массивом');
          END IF;
          IF vr_elem.is_array = 0
             AND v_element.is_object
          THEN
            validate_json_element(par_format_id     => par_format_id
                                 ,par_json          => JSON(v_element)
                                 ,par_start_elem_id => vr_elem.t_exchange_format_elem_id);
          ELSIF vr_elem.is_array = 0
          THEN
            ex.raise('Элемент ' || vr_elem.name || ' должен быть объектом');
          END IF;
        END IF;
        -- Проверяем наличие значения
        IF vr_elem.is_value_mandatory = 1
           AND v_element.is_null
        THEN
          ex.raise('Отсутствует значение для элемента "' || vr_elem.name || '" (' ||
                   nvl(vr_elem.description, 'нет описания') || ')');
        END IF;
      ELSE
        ex.raise('Отсутствует элемент "' || vr_elem.name || '" (' ||
                 nvl(vr_elem.description, 'нет описания') || ')'
                ,no_element_exception);
      END IF;
    END LOOP;
  END validate_json_element;

  /*
    Проверка формата XML с выходным параметром XMLTYPE
  */
  PROCEDURE validate_xml
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
   ,par_xml       OUT xmltype
  ) IS
    v_xml xmltype;
  BEGIN
    -- Парсим
    BEGIN
      v_xml   := xmltype(par_data);
      par_xml := v_xml;
    EXCEPTION
      WHEN pkg_oracle_exceptions.xmltype_parse_error THEN
        raise_application_error(cant_parse_exception, 'Невозможно разобрать xml');
    END;
    -- Проверяем наличие обязательных элементов и аттрибутов
    validate_xml_element(par_format_id, v_xml);
  END validate_xml;

  /*
    Проверка формата XML
  */
  PROCEDURE validate_xml
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
  ) IS
    v_xml xmltype;
  BEGIN
    validate_xml(par_format_id => par_format_id, par_data => par_data, par_xml => v_xml);
  END validate_xml;

  /*
    Проверка формата JSON с выходным параметром JSON
  */
  PROCEDURE validate_json
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
   ,par_json      OUT JSON
  ) IS
  BEGIN
    -- Парсим
    BEGIN
      par_json := JSON(par_data);
    EXCEPTION
      WHEN OTHERS THEN
        ex.raise('Невозможно разобрать JSON', cant_parse_exception);
    END;
    -- Проверяем наличие обязательных элементов и аттрибутов
    validate_json_element(par_format_id, par_json);
  END validate_json;

  /*
    Проверка формата JSON
  */
  PROCEDURE validate_json
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
  ) IS
    v_json JSON;
  BEGIN
    validate_json(par_format_id => par_format_id, par_data => par_data, par_json => v_json);
  END validate_json;

  /*
    Проверка соответствия формату, возвращает XMLTYPE
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
   ,par_xml       OUT xmltype
  ) IS
    vr_format t_exchange_format%ROWTYPE;
  BEGIN
    assert_deprecated(par_condition  => par_data IS NULL
          ,par_msg        => 'Проверяемые данные отсутствуют'
          ,par_error_code => empty_data_exception);
    -- Получаем запись
    vr_format := pkg_t_exchange_format_dml.get_record(par_t_exchange_format_id => par_format_id);
  
    -- Выбираем и запускаем валидатор формата
    CASE vr_format.format_type
      WHEN gc_xml THEN
        validate_xml(par_format_id => par_format_id, par_data => par_data, par_xml => par_xml);
      WHEN gc_json THEN
        ex.raise('Выбран неправильный формат, в настройках указан JSON, а на выходе ожидается XMLTYPE'
                ,wrong_format_chosen_exception);
      ELSE
        ex.raise('Формат данных не поддерживается'
                ,format_not_supported_exception);
    END CASE;
  END validate_format;

  /*
    Проверка соответствия формату, возвращает JSON
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
   ,par_json      OUT JSON
  ) IS
    vr_format t_exchange_format%ROWTYPE;
  BEGIN
    assert_deprecated(par_condition  => par_data IS NULL
          ,par_msg        => 'Проверяемые данные отсутствуют'
          ,par_error_code => empty_data_exception);
    -- Получаем запись
    vr_format := pkg_t_exchange_format_dml.get_record(par_t_exchange_format_id => par_format_id);
  
    -- Выбираем и запускаем валидатор формата
    CASE vr_format.format_type
      WHEN gc_xml THEN
        ex.raise('Выбран неправильный формат, в настройках указан XML, а на выходе ожидается JSON'
                ,wrong_format_chosen_exception);
      WHEN gc_json THEN
        validate_json(par_format_id => par_format_id, par_data => par_data, par_json => par_json);
      ELSE
        ex.raise('Формат данных не поддерживается'
                ,format_not_supported_exception);
    END CASE;
  END validate_format;

  /*
    Проверка соответствия формату
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_data      CLOB
  ) IS
    vr_format t_exchange_format%ROWTYPE;
  BEGIN
    assert_deprecated(par_condition  => par_data IS NULL
          ,par_msg        => 'Проверяемые данные отсутствуют'
          ,par_error_code => empty_data_exception);
    -- Получаем запись
    vr_format := pkg_t_exchange_format_dml.get_record(par_t_exchange_format_id => par_format_id);
  
    -- Выбираем и запускаем валидатор формата
    CASE vr_format.format_type
      WHEN gc_xml THEN
        validate_xml(par_format_id => par_format_id, par_data => par_data);
      WHEN gc_json THEN
        validate_json(par_format_id => par_format_id, par_data => par_data);
      ELSE
        ex.raise('Формат данных не поддерживается'
                ,format_not_supported_exception);
    END CASE;
  END validate_format;

  /*
    Проверка соответствия формату
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_xml       xmltype
  ) IS
  BEGIN
    assert_deprecated(par_condition  => par_xml IS NULL
          ,par_msg        => 'Проверяемые данные отсутствуют'
          ,par_error_code => empty_data_exception);
  
    -- Проверяем наличие обязательных элементов и аттрибутов
    validate_xml_element(par_format_id, par_xml);
  END validate_format;

  /*
    Проверка соответствия формату
  */
  PROCEDURE validate_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_json      JSON
  ) IS
  BEGIN
    assert_deprecated(par_condition  => par_json IS NULL
          ,par_msg        => 'Проверяемые данные отсутствуют'
          ,par_error_code => empty_data_exception);
  
    assert_deprecated(par_format_id IS NULL, 'ID формата не указан');
    -- Проверяем наличие обязательных элементов и аттрибутов
    validate_json_element(par_format_id => par_format_id, par_json => par_json);
  END validate_format;

  /*
    Добавление аттрибутов в элемент на основании справочных данных
  */
  PROCEDURE add_xml_attributes
  (
    par_element    xmldom.domelement
   ,par_element_id t_exchange_format_elem.t_exchange_format_elem_id%TYPE
  ) IS
  BEGIN
    FOR vr_attribute IN (SELECT ea.name
                           FROM t_exchange_format_attr ea
                          WHERE ea.t_exchange_format_elem_id = par_element_id)
    LOOP
      xmldom.setattribute(par_element, vr_attribute.name, '');
    END LOOP;
  END add_xml_attributes;

  /*
    Добавление дочерних элементов на основании справочных данных
  */
  PROCEDURE add_xml_children
  (
    par_parent_element_id t_exchange_format_elem.t_exchange_format_elem_id%TYPE
   ,par_document          xmldom.domdocument
   ,par_node              xmldom.domnode
  ) IS
    v_element xmldom.domelement;
    v_node    xmldom.domnode;
  BEGIN
    FOR vr_element IN (SELECT el.t_exchange_format_elem_id
                             ,el.name
                             ,CASE
                                WHEN EXISTS (SELECT *
                                        FROM t_exchange_format_elem elc
                                       WHERE elc.parent_id = el.t_exchange_format_elem_id) THEN
                                 1
                                ELSE
                                 0
                              END AS have_children
                         FROM t_exchange_format_elem el
                        WHERE el.parent_id = par_parent_element_id)
    LOOP
      v_element := xmldom.createelement(par_document, vr_element.name);
      v_node    := xmldom.appendchild(par_node, xmldom.makenode(v_element));
      add_xml_attributes(par_element    => v_element
                        ,par_element_id => vr_element.t_exchange_format_elem_id);
      IF vr_element.have_children = 1
      THEN
        add_xml_children(par_parent_element_id => vr_element.t_exchange_format_elem_id
                        ,par_document          => par_document
                        ,par_node              => v_node);
      END IF;
    
    END LOOP;
    NULL;
  END add_xml_children;

  /*
    Формирование XML на основании справочных данных
  */
  FUNCTION make_xml(par_format_id t_exchange_format.t_exchange_format_id%TYPE) RETURN xmltype IS
    v_document    xmldom.domdocument;
    v_main_node   xmldom.domnode;
    v_root_node   xmldom.domnode;
    v_root_elemet xmldom.domelement;
    item_text     xmldom.domtext;
  
    v_root_name  t_exchange_format_elem.name%TYPE;
    v_xml        xmltype;
    v_element_id t_exchange_format_elem.t_exchange_format_elem_id%TYPE;
  BEGIN
    -- Родительский элемент
    BEGIN
      SELECT el.name
            ,el.t_exchange_format_elem_id
        INTO v_root_name
            ,v_element_id
        FROM t_exchange_format_elem el
       WHERE el.t_exchange_format_id = par_format_id
         AND el.parent_id IS NULL;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не найден корневой элемент формата');
      WHEN too_many_rows THEN
        ex.raise('Найдено несколько корневых элементов');
    END;
    v_document    := xmldom.newdomdocument;
    v_main_node   := xmldom.makenode(v_document);
    v_root_elemet := xmldom.createelement(v_document, v_root_name);
    v_root_node   := xmldom.appendchild(v_main_node, xmldom.makenode(v_root_elemet));
    -- Аттрибуты родительского элемента
    add_xml_attributes(par_element => v_root_elemet, par_element_id => v_element_id);
    -- Дочерние элементы
    add_xml_children(par_parent_element_id => v_element_id
                    ,par_document          => v_document
                    ,par_node              => v_root_node);
  
    v_xml := xmldom.getxmltype(doc => v_document);
    xmldom.freedocument(v_document);
    RETURN v_xml;
  END make_xml;

  /*
    Возвращает дочерние элементы на основании справочных данных (JSON)
  */
  FUNCTION get_json_children(par_parent_element_id t_exchange_format_elem.t_exchange_format_elem_id%TYPE)
    RETURN JSON IS
    v_json  JSON := JSON();
    v_array JSON_LIST := JSON_LIST();
  BEGIN
    FOR vr_elements IN (SELECT el.t_exchange_format_elem_id
                              ,el.name
                              ,CASE
                                 WHEN EXISTS (SELECT *
                                         FROM t_exchange_format_elem elc
                                        WHERE elc.parent_id = el.t_exchange_format_elem_id) THEN
                                  1
                                 ELSE
                                  0
                               END AS have_children
                              ,el.is_array
                          FROM t_exchange_format_elem el
                         WHERE el.parent_id = par_parent_element_id)
    LOOP
      IF vr_elements.have_children = 0
      THEN
        v_json.put(vr_elements.name, '');
      ELSIF vr_elements.is_array = 1
      THEN
        v_array.append(get_json_children(vr_elements.t_exchange_format_elem_id).to_json_value);
        v_json.put(vr_elements.name, v_array);
      ELSE
        v_json.put(vr_elements.name, get_json_children(vr_elements.t_exchange_format_elem_id));
      END IF;
    END LOOP;
    RETURN v_json;
  END get_json_children;

  /*
    Формирует JSON на основании справочных данных
  */
  FUNCTION make_json(par_format_id t_exchange_format.t_exchange_format_id%TYPE) RETURN JSON IS
    v_json  JSON := JSON();
    v_array JSON_LIST := JSON_LIST();
  BEGIN
    -- Элементы верхнего уровня
    FOR vr_element IN (SELECT el.t_exchange_format_elem_id
                             ,el.name
                             ,CASE
                                WHEN EXISTS (SELECT *
                                        FROM t_exchange_format_elem elc
                                       WHERE elc.parent_id = el.t_exchange_format_elem_id) THEN
                                 1
                                ELSE
                                 0
                              END AS have_children
                             ,el.is_array
                         FROM t_exchange_format_elem el
                        WHERE el.t_exchange_format_id = par_format_id
                          AND el.parent_id IS NULL)
    LOOP
      IF vr_element.have_children = 0
      THEN
        v_json.put(vr_element.name, '');
      ELSIF vr_element.is_array = 1
      THEN
        v_array.append(get_json_children(vr_element.t_exchange_format_elem_id).to_json_value);
        v_json.put(vr_element.name, v_array);
      ELSE
        v_json.put(vr_element.name, get_json_children(vr_element.t_exchange_format_elem_id));
      END IF;
    END LOOP;
    RETURN v_json;
  END make_json;

  /*
    Генерит формат из данных справочников
    Возвращает JSON
  */
  PROCEDURE make_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_json      OUT JSON
  ) IS
    vr_format t_exchange_format%ROWTYPE;
  BEGIN
    assert_deprecated(par_condition => par_format_id IS NULL, par_msg => 'ID формата не указан');
    -- Получаем запись
    vr_format := pkg_t_exchange_format_dml.get_record(par_t_exchange_format_id => par_format_id);
  
    -- Выбираем и запускаем валидатор формата
    CASE vr_format.format_type
      WHEN gc_xml THEN
        ex.raise('Выбран неправильный формат, в настройках указан XML, а на выходе ожидается JSON'
                ,wrong_format_chosen_exception);
      WHEN gc_json THEN
        par_json := make_json(par_format_id => par_format_id);
      ELSE
        ex.raise('Формат данных не поддерживается'
                ,format_not_supported_exception);
    END CASE;
  END make_format;

  /*
    Генерит формат из данных справочников
    Возвращает XMLTYPE
  */
  PROCEDURE make_format
  (
    par_format_id t_exchange_format.t_exchange_format_id%TYPE
   ,par_xml       OUT xmltype
  ) IS
    vr_format t_exchange_format%ROWTYPE;
  BEGIN
    assert_deprecated(par_condition => par_format_id IS NULL, par_msg => 'ID формата не указан');
    -- Получаем запись
    vr_format := pkg_t_exchange_format_dml.get_record(par_t_exchange_format_id => par_format_id);
  
    -- Выбираем и запускаем валидатор формата
    CASE vr_format.format_type
      WHEN gc_xml THEN
        par_xml := make_xml(par_format_id => par_format_id);
      WHEN gc_json THEN
        ex.raise('Выбран неправильный формат, в настройках указан XML, а на выходе ожидается JSON'
                ,wrong_format_chosen_exception);
      ELSE
        ex.raise('Формат данных не поддерживается'
                ,format_not_supported_exception);
    END CASE;
  END make_format;

  /*
    Бежит по дочерним элементам и раскладывает их в справочник
  */
  PROCEDURE store_json_element
  (
    par_exchange_format_id      t_exchange_format.t_exchange_format_id%TYPE
   ,par_exchange_format_elem_id t_exchange_format_elem.t_exchange_format_elem_id%TYPE
   ,par_json_element            JSON
  ) IS
    v_keys         JSON_LIST;
    v_key          json_value;
    v_value        json_value;
    v_array        JSON_LIST;
    v_is_mandatory t_exchange_format_elem.is_mandatory%TYPE;
    v_is_array     t_exchange_format_elem.is_array%TYPE;
    v_element_id   t_exchange_format_elem.t_exchange_format_elem_id%TYPE;
  BEGIN
    v_keys := par_json_element.get_keys;
    FOR i IN 1 .. v_keys.count
    LOOP
      v_key          := v_keys.get(i);
      v_value        := par_json_element.get(i);
      v_is_mandatory := CASE
                          WHEN v_value.is_null THEN
                           0
                          ELSE
                           1
                        END;
      v_is_array := CASE
                      WHEN v_value.is_array THEN
                       1
                      ELSE
                       0
                    END;
      dml_t_exchange_format_elem.insert_record(par_t_exchange_format_id      => par_exchange_format_id
                                              ,par_name                      => v_key.get_string
                                              ,par_is_mandatory              => v_is_mandatory
                                              ,par_is_array                  => v_is_array
                                              ,par_description               => NULL
                                              ,par_parent_id                 => par_exchange_format_elem_id
                                              ,par_t_exchange_format_elem_id => v_element_id);
      IF v_value.is_object
      THEN
        -- Если объект, добавляем дочерние элементы
        store_json_element(par_exchange_format_id      => par_exchange_format_id
                          ,par_exchange_format_elem_id => v_element_id
                          ,par_json_element            => JSON(v_value));
      ELSIF v_value.is_array
      THEN
        -- Если массив, получаем первый элемент
        v_array := JSON_LIST(v_value);
        v_value := v_array.get(1);
        store_json_element(par_exchange_format_id      => par_exchange_format_id
                          ,par_exchange_format_elem_id => v_element_id
                          ,par_json_element            => JSON(v_value));
      END IF;
    END LOOP;
  END store_json_element;

  /*
    Раскладывает JSON в справочники
  */
  PROCEDURE store_format
  (
    par_brief                t_exchange_format.brief%TYPE
   ,par_name                 t_exchange_format.name%TYPE
   ,par_description          t_exchange_format.description%TYPE
   ,par_json                 JSON
   ,par_t_exchange_format_id OUT t_exchange_format.t_exchange_format_id%TYPE
  ) IS
  BEGIN
    pkg_t_exchange_format_dml.insert_record(par_brief                => par_brief
                                           ,par_name                 => par_name
                                           ,par_description          => par_description
                                           ,par_format_type          => gc_json
                                           ,par_t_exchange_format_id => par_t_exchange_format_id);
  
    store_json_element(par_exchange_format_id      => par_t_exchange_format_id
                      ,par_exchange_format_elem_id => NULL
                      ,par_json_element            => par_json);
  END store_format;

  /*
    Раскладывает JSON в справочники (не возвращает ID)
  */
  PROCEDURE store_format
  (
    par_brief       t_exchange_format.brief%TYPE
   ,par_name        t_exchange_format.name%TYPE
   ,par_description t_exchange_format.description%TYPE
   ,par_json        JSON
  ) IS
    v_exchange_format_id t_exchange_format.t_exchange_format_id%TYPE;
  BEGIN
    pkg_exchange_format.store_format(par_brief                => par_brief
                                    ,par_name                 => par_name
                                    ,par_description          => par_description
                                    ,par_json                 => par_json
                                    ,par_t_exchange_format_id => v_exchange_format_id);
  
  END store_format;

  /*
    Раскладывает XML в справочники
    (не реализовано)
  */
  PROCEDURE store_format
  (
    par_brief                t_exchange_format.brief%TYPE
   ,par_name                 t_exchange_format.name%TYPE
   ,par_description          t_exchange_format.description%TYPE
   ,par_xml                  xmltype
   ,par_t_exchange_format_id OUT t_exchange_format.t_exchange_format_id%TYPE
  ) IS
  BEGIN
    ex.raise('Не реализовано');
  END store_format;

END pkg_exchange_format; 
/
