CREATE OR REPLACE PACKAGE pkg_doc_properties IS

  -- Author  : Капля П.
  -- Created : 20.03.2014 20:52:48
  -- Purpose : 

  TYPE t_doc_property IS RECORD(
     property_type_brief doc_property_type.brief%TYPE
    ,value_char          doc_property.value_char%TYPE
    ,value_num           doc_property.value_num%TYPE
    ,value_date          doc_property.value_date%TYPE
    ,value_ent_id        doc_property.value_ent_id%TYPE
    ,value_obj_id        doc_property.value_obj_id%TYPE);

  TYPE tt_doc_property IS TABLE OF t_doc_property;

  /*
    Капля П.
    Процедура создания типа свойства для шаблона документа
  */
  PROCEDURE create_property_type
  (
    par_doc_templ_brief           doc_templ.brief%TYPE
   ,par_doc_prop_value_type_brief doc_prop_value_type.brief%TYPE
   ,par_name                      doc_property_type.name%TYPE
   ,par_brief                     doc_property_type.brief%TYPE
   ,par_ent_id                    doc_property_type.ent_id%TYPE DEFAULT NULL
  );

  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_value               doc_property.value_char%TYPE
  );
  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_value            doc_property.value_char%TYPE
  );
  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_value               NUMBER
  );
  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_value            NUMBER
  );
  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_value               DATE
  );
  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_value            DATE
  );
  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_ent_id              entity.ent_id%TYPE
   ,par_obj_id              NUMBER
  );
  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_ent_id           entity.ent_id%TYPE
   ,par_obj_id           NUMBER
  );

  PROCEDURE add_properties_to_document
  (
    par_document_id        document.document_id%TYPE
   ,par_doc_property_array tt_doc_property
  );

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:46:35
  -- Purpose : Удаление всех свойств документа
  PROCEDURE delete_doc_properties(par_document_id IN document.document_id%TYPE);

  FUNCTION get_document_properties(par_document_id document.document_id%TYPE) RETURN tt_doc_property;

  -- Author  : PAVEL.KAPLYA
  -- Created : 24.03.2014 12:03:00
  -- Purpose : Проверка существует ли свойство у документа
  FUNCTION check_proeprty_exists
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN BOOLEAN;
  FUNCTION check_proeprty_exists
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN BOOLEAN;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 19:05:08
  -- Purpose : Получаем запись свойства для документа
  FUNCTION get_record
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property%ROWTYPE;
  FUNCTION get_record
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property%ROWTYPE;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:52:00
  -- Purpose : Получение числового значения свойства документа
  FUNCTION get_number
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property.value_num%TYPE;
  FUNCTION get_number
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property.value_num%TYPE;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:52:00
  -- Purpose : Получение строкового значения свойства документа
  FUNCTION get_string
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property.value_char%TYPE;
  FUNCTION get_string
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property.value_char%TYPE;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:52:00
  -- Purpose : Получение значения типа даты свойства документа
  FUNCTION get_date
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property.value_date%TYPE;
  FUNCTION get_date
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property.value_date%TYPE;

  /*
    Капля П.
    Копирование свойств между документами
  */
  PROCEDURE copy_document_properties
  (
    par_old_document_id document.document_id%TYPE
   ,par_new_document_id document.document_id%TYPE
  );

END pkg_doc_properties;
/
CREATE OR REPLACE PACKAGE BODY pkg_doc_properties IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'PKG_DOC_PROPERTIES';
	
  FUNCTION get_doc_property_type_id
  (
    par_doc_templ_id   IN doc_property_type.doc_templ_id%TYPE
   ,par_brief          IN doc_property_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN doc_property_type.doc_property_type_id%TYPE IS
    v_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT doc_property_type_id
        INTO v_id
        FROM doc_property_type
       WHERE doc_templ_id = par_doc_templ_id
         AND brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не определить тип свойства документа по шаблону "' ||
                                  par_doc_templ_id || '" и брифу "' || par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_doc_property_type_id;	

  PROCEDURE create_property_type
  (
    par_doc_templ_brief           doc_templ.brief%TYPE
   ,par_doc_prop_value_type_brief doc_prop_value_type.brief%TYPE
   ,par_name                      doc_property_type.name%TYPE
   ,par_brief                     doc_property_type.brief%TYPE
   ,par_ent_id                    doc_property_type.ent_id%TYPE DEFAULT NULL
  ) IS
    v_doc_templ_id           doc_templ.doc_templ_id%TYPE;
    v_doc_prop_value_type_id doc_prop_value_type.doc_prop_value_type_id%TYPE;
  BEGIN
    assert_deprecated(par_doc_templ_brief IS NULL
          ,'Бриф шаблона документа должен быть заполнен');
    assert_deprecated(par_doc_prop_value_type_brief IS NULL
          ,'Бриф типа сайоства документа должен быть заполнен');
    assert_deprecated(par_doc_prop_value_type_brief = 'ENTITY_OBJECT' AND par_ent_id IS NULL
          ,'Для свойства документа типа ссылки на объект необходимо задать ИД сущности');
  
    v_doc_templ_id           := doc.templ_id_by_brief(par_doc_templ_brief);
    v_doc_prop_value_type_id := dml_doc_prop_value_type.get_id_by_brief(par_doc_prop_value_type_brief);
  
    dml_doc_property_type.insert_record(par_doc_templ_id           => v_doc_templ_id
                                       ,par_doc_prop_value_type_id => v_doc_prop_value_type_id
                                       ,par_name                   => par_name
                                       ,par_brief                  => par_brief);
  
  END create_property_type;

  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_value               doc_property.value_char%TYPE
  ) IS
    v_doc_templ_id     doc_templ.doc_templ_id%TYPE;
    v_property_type_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    SELECT d.doc_templ_id INTO v_doc_templ_id FROM document d WHERE d.document_id = par_document_id;
  
    v_property_type_id := get_doc_property_type_id(par_doc_templ_id => v_doc_templ_id
                                                                            ,par_brief        => par_property_type_brief);
  
    add_property_to_document(par_document_id      => par_document_id
                            ,par_property_type_id => v_property_type_id
                            ,par_value            => par_value);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_value            doc_property.value_char%TYPE
  ) IS
  BEGIN
    dml_doc_property.insert_record(par_document_id          => par_document_id
                                  ,par_doc_property_type_id => par_property_type_id
                                  ,par_value_char           => par_value);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_value               NUMBER
  ) IS
    v_doc_templ_id     doc_templ.doc_templ_id%TYPE := doc.get_doc_templ_id(par_document_id => par_document_id);
    v_property_type_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    v_property_type_id := get_doc_property_type_id(par_doc_templ_id => v_doc_templ_id
                                                                            ,par_brief        => par_property_type_brief);
  
    add_property_to_document(par_document_id      => par_document_id
                            ,par_property_type_id => v_property_type_id
                            ,par_value            => par_value);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_value            NUMBER
  ) IS
  BEGIN
    dml_doc_property.insert_record(par_document_id          => par_document_id
                                  ,par_doc_property_type_id => par_property_type_id
                                  ,par_value_num            => par_value);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_value               DATE
  ) IS
    v_doc_templ_id     doc_templ.doc_templ_id%TYPE := doc.get_doc_templ_id(par_document_id => par_document_id);
    v_property_type_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    v_property_type_id := get_doc_property_type_id(par_doc_templ_id => v_doc_templ_id
                                                                            ,par_brief        => par_property_type_brief);
  
    add_property_to_document(par_document_id      => par_document_id
                            ,par_property_type_id => v_property_type_id
                            ,par_value            => par_value);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_value            DATE
  ) IS
  BEGIN
    dml_doc_property.insert_record(par_document_id          => par_document_id
                                  ,par_doc_property_type_id => par_property_type_id
                                  ,par_value_date           => par_value);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id         document.document_id%TYPE
   ,par_property_type_brief doc_property_type.brief%TYPE
   ,par_ent_id              entity.ent_id%TYPE
   ,par_obj_id              NUMBER
  ) IS
    v_doc_templ_id     doc_templ.doc_templ_id%TYPE := doc.get_doc_templ_id(par_document_id => par_document_id);
    v_property_type_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    v_property_type_id := get_doc_property_type_id(par_doc_templ_id => v_doc_templ_id
                                                                            ,par_brief        => par_property_type_brief);
  
    add_property_to_document(par_document_id      => par_document_id
                            ,par_property_type_id => v_property_type_id
                            ,par_ent_id           => par_ent_id
                            ,par_obj_id           => par_obj_id);
  END add_property_to_document;

  PROCEDURE add_property_to_document
  (
    par_document_id      document.document_id%TYPE
   ,par_property_type_id doc_property_type.doc_property_type_id%TYPE
   ,par_ent_id           entity.ent_id%TYPE
   ,par_obj_id           NUMBER
  ) IS
  BEGIN
    dml_doc_property.insert_record(par_document_id          => par_document_id
                                  ,par_doc_property_type_id => par_property_type_id
                                  ,par_value_ent_id         => par_ent_id
                                  ,par_value_obj_id         => par_obj_id);
  END add_property_to_document;

  PROCEDURE add_properties_to_document
  (
    par_document_id        document.document_id%TYPE
   ,par_doc_property_array tt_doc_property
  ) IS
    v_doc_templ_id     doc_templ.doc_templ_id%TYPE := doc.get_doc_templ_id(par_document_id => par_document_id);
    v_property_type_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    IF par_doc_property_array.count > 0
    THEN
      FOR i IN par_doc_property_array.first .. par_doc_property_array.last
      LOOP
        v_property_type_id := get_doc_property_type_id(par_doc_templ_id => v_doc_templ_id
                                                                                ,par_brief        => par_doc_property_array(i)
                                                                                                     .property_type_brief);
        dml_doc_property.insert_record(par_document_id          => par_document_id
                                      ,par_doc_property_type_id => v_property_type_id
                                      ,par_value_char           => par_doc_property_array(i).value_char
                                      ,par_value_num            => par_doc_property_array(i).value_num
                                      ,par_value_date           => par_doc_property_array(i).value_date
                                      ,par_value_ent_id         => par_doc_property_array(i)
                                                                   .value_ent_id
                                      ,par_value_obj_id         => par_doc_property_array(i)
                                                                   .value_obj_id);
      END LOOP;
    END IF;
  END add_properties_to_document;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:46:35
  -- Purpose : Удаление всех свойств документа
  PROCEDURE delete_doc_properties(par_document_id IN document.document_id%TYPE) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('delete_doc_properties');
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
    DELETE FROM doc_property dp WHERE dp.document_id = par_document_id;
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END delete_doc_properties;

  FUNCTION get_document_properties(par_document_id document.document_id%TYPE) RETURN tt_doc_property IS
    v_doc_properties tt_doc_property := tt_doc_property();
    v_doc_propery    t_doc_property;
  BEGIN
    FOR rec IN (SELECT dpt.brief
                      ,dp.value_char
                      ,dp.value_num
                      ,dp.value_date
                      ,dp.value_ent_id
                      ,dp.value_obj_id
                  FROM doc_property      dp
                      ,doc_property_type dpt
                 WHERE dp.document_id = par_document_id
                   AND dp.doc_property_type_id = dpt.doc_property_type_id)
    LOOP
      v_doc_propery.property_type_brief := rec.brief;
      v_doc_propery.value_char          := rec.value_char;
      v_doc_propery.value_num           := rec.value_num;
      v_doc_propery.value_date          := rec.value_date;
      v_doc_propery.value_ent_id        := rec.value_ent_id;
      v_doc_propery.value_obj_id        := rec.value_obj_id;
    
      v_doc_properties.extend;
      v_doc_properties(v_doc_properties.last) := v_doc_propery;
    END LOOP;
  
    RETURN v_doc_properties;
  END get_document_properties;
  -- Author  : PAVEL.KAPLYA
  -- Created : 24.03.2014 12:03:00
  -- Purpose : Проверка существует ли свойство у документа
  FUNCTION check_proeprty_exists
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN BOOLEAN IS
    v_result BOOLEAN;
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('check_proeprty_exists');
    v_property_rec doc_property%ROWTYPE;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_property_rec := get_record(par_document_id          => par_document_id
                                ,par_doc_property_type_id => par_doc_property_type_id);
    v_result       := v_property_rec.doc_property_id IS NOT NULL;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name);
    RETURN(v_result);
  END check_proeprty_exists;

  -- Author  : PAVEL.KAPLYA
  -- Created : 24.03.2014 12:03:00
  -- Purpose : Проверка существует ли свойство у документа
  FUNCTION check_proeprty_exists
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN BOOLEAN IS
    v_result BOOLEAN;
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('check_proeprty_exists');
    v_property_rec doc_property%ROWTYPE;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_property_rec := get_record(par_document_id             => par_document_id
                                ,par_doc_property_type_brief => par_doc_property_type_brief);
    v_result       := v_property_rec.doc_property_id IS NOT NULL;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name);
    RETURN(v_result);
  END check_proeprty_exists;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 19:05:08
  -- Purpose : Получаем запись свойства для документа
  FUNCTION get_record
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property%ROWTYPE IS
    v_result doc_property%ROWTYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('get_record');
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    BEGIN
      SELECT *
        INTO v_result
        FROM doc_property dp
       WHERE dp.document_id = par_document_id
         AND dp.doc_property_type_id = par_doc_property_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name);
    RETURN(v_result);
  END get_record;

  FUNCTION get_record
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property%ROWTYPE IS
    v_result doc_property%ROWTYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := upper('get_record');
    v_doc_templ_id     doc_templ.doc_templ_id%TYPE;
    v_property_type_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_doc_templ_id     := doc.get_doc_templ_id(par_document_id => par_document_id);
    v_property_type_id := get_doc_property_type_id(par_doc_templ_id   => v_doc_templ_id
                                                                            ,par_brief          => par_doc_property_type_brief
                                                                            ,par_raise_on_error => FALSE);
  
    v_result := get_record(par_document_id          => par_document_id
                          ,par_doc_property_type_id => v_property_type_id);
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name);
    RETURN(v_result);
  
  END get_record;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:52:00
  -- Purpose : Получение числового значения свойства документа
  FUNCTION get_number
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property.value_num%TYPE IS
    v_result doc_property.value_num%TYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_NUMBER';
    v_record doc_property%ROWTYPE;
  BEGIN
  
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_record := get_record(par_document_id             => par_document_id
                          ,par_doc_property_type_brief => par_doc_property_type_brief);
  
    v_result := v_record.value_num;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN(v_result);
  END get_number;

  FUNCTION get_number
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property.value_num%TYPE IS
    v_result doc_property.value_num%TYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_NUMBER';
    v_record doc_property%ROWTYPE;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_record := get_record(par_document_id          => par_document_id
                          ,par_doc_property_type_id => par_doc_property_type_id);
  
    v_result := v_record.value_num;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN(v_result);
  END get_number;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:52:00
  -- Purpose : Получение строкового значения свойства документа
  FUNCTION get_string
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property.value_char%TYPE IS
    v_result doc_property.value_char%TYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_STRING';
    v_record doc_property%ROWTYPE;
  BEGIN
  
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_record := get_record(par_document_id             => par_document_id
                          ,par_doc_property_type_brief => par_doc_property_type_brief);
  
    v_result := v_record.value_char;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN(v_result);
  END get_string;

  FUNCTION get_string
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property.value_char%TYPE IS
    v_result doc_property.value_char%TYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_STRING';
    v_record doc_property%ROWTYPE;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_record := get_record(par_document_id          => par_document_id
                          ,par_doc_property_type_id => par_doc_property_type_id);
  
    v_result := v_record.value_char;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN(v_result);
  END get_string;

  -- Author  : PAVEL.KAPLYA
  -- Created : 21.03.2014 18:52:00
  -- Purpose : Получение значения типа даты свойства документа
  FUNCTION get_date
  (
    par_document_id             document.document_id%TYPE
   ,par_doc_property_type_brief doc_property_type.brief%TYPE
  ) RETURN doc_property.value_date%TYPE IS
    v_result doc_property.value_date%TYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_DATE';
    v_record doc_property%ROWTYPE;
  BEGIN
  
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_record := get_record(par_document_id             => par_document_id
                          ,par_doc_property_type_brief => par_doc_property_type_brief);
  
    v_result := v_record.value_date;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN(v_result);
  END get_date;

  FUNCTION get_date
  (
    par_document_id          document.document_id%TYPE
   ,par_doc_property_type_id doc_property_type.doc_property_type_id%TYPE
  ) RETURN doc_property.value_date%TYPE IS
    v_result doc_property.value_date%TYPE;
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'GET_DATE';
    v_record doc_property%ROWTYPE;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => vc_proc_name);
  
    v_record := get_record(par_document_id          => par_document_id
                          ,par_doc_property_type_id => par_doc_property_type_id);
  
    v_result := v_record.value_date;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => vc_proc_name
                                ,par_result_value      => v_result);
    RETURN(v_result);
  END get_date;

  PROCEDURE copy_document_properties
  (
    par_old_document_id document.document_id%TYPE
   ,par_new_document_id document.document_id%TYPE
  ) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'COPY_DOCUMENT_PROPERTIES';
    v_doc_properies pkg_doc_properties.tt_doc_property;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'par_old_document_id'
                          ,par_trace_var_value => par_old_document_id);
    pkg_trace.add_variable(par_trace_var_name  => 'par_new_document_id'
                          ,par_trace_var_value => par_new_document_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    assert_deprecated(par_old_document_id = par_new_document_id
          ,'Невозможно скопировать свойства документа в самого себя');
    assert_deprecated(doc.get_doc_templ_id(par_old_document_id) != doc.get_doc_templ_id(par_new_document_id)
          ,'Документы должны быть одного шаблона для копирования свойств между ними');
  
    v_doc_properies := pkg_doc_properties.get_document_properties(par_document_id => par_old_document_id);
  
    pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                   ,par_trace_subobj_name => vc_proc_name
                   ,par_message           => 'Добавление свойств в новый документ');
  
    pkg_doc_properties.add_properties_to_document(par_document_id        => par_new_document_id
                                                 ,par_doc_property_array => v_doc_properies);
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END copy_document_properties;

END pkg_doc_properties; 
/
