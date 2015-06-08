CREATE OR REPLACE TRIGGER tr_doc_property_aiu
  AFTER INSERT OR UPDATE ON doc_property
  FOR EACH ROW
DECLARE
  v_exists           NUMBER(1);
  v_parent_ent_id    doc_property_type.ent_id%TYPE;
  v_value_type_brief doc_prop_value_type.brief%TYPE;
BEGIN

  -- Проверка, что свойство доступно для данного документа
  SELECT COUNT(*)
    INTO v_exists
    FROM dual
   WHERE EXISTS (SELECT NULL
            FROM doc_property_type dpt
                ,document            d
           WHERE dpt.doc_templ_id = d.doc_templ_id
             AND d.document_id = :new.document_id
             AND dpt.doc_property_type_id = :new.doc_property_type_id);

  IF v_exists = 0
  THEN
    raise_application_error(-20010
                           ,'Свойство документа не доступно для данного шаблона документа');
  END IF;

  
  SELECT pct.ent_id
        ,dpvt.brief
    INTO v_parent_ent_id
        ,v_value_type_brief
    FROM doc_property_type   pct
        ,doc_prop_value_type dpvt
   WHERE pct.doc_property_type_id = :new.doc_property_type_id
     AND pct.doc_prop_value_type_id = dpvt.doc_prop_value_type_id;

  -- Проверка на соответствие типа свойства 
  CASE v_value_type_brief
    WHEN 'NUMBER' THEN
      assert_deprecated(:new.value_num IS NULL
            ,'Числовое значение свойства документа должно быть заполнено'
            ,20010);
    WHEN 'STRING' THEN
      assert_deprecated(:new.value_char IS NULL
            ,'Строковое значение свойства документа должно быть заполнено'
            ,20010);
    WHEN 'DATE' THEN
      assert_deprecated(:new.value_date IS NULL
            ,'Значение свойства документа с типом дата должно быть заполнено'
            ,20010);
    WHEN 'ENTITY_OBJECT' THEN
      assert_deprecated(:new.value_obj_id IS NULL
            ,'У свойства документа должно быть заполнено значение иднтификатора объекта сущности'
            ,20010);
    ELSE
      raise_application_error(-20010
                            ,'Для типа свойства документа указан не верный тип значения');
  END CASE;

  -- Проверка совпадения указанной ent_id
  IF v_parent_ent_id != :new.value_ent_id
  THEN
    raise_application_error(-20010, 'Не верное значение ent_id');
  END IF;

  -- Проверка 
  IF :new.value_obj_id IS NOT NULL
     AND
     NOT ent.check_ent_obj_exists(par_ent_id => :new.value_ent_id, par_obj_id => :new.value_obj_id)
  THEN
    raise_application_error(-20010
                           ,'В сущности ' || ent.name_by_id(p_ent_id => :new.value_ent_id) ||
                            ' не существует объекта с ИД ' || :new.value_obj_id);
  END IF;

END tr_doc_property_aiu; 
/
