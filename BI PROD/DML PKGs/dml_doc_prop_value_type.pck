CREATE OR REPLACE PACKAGE dml_doc_prop_value_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN doc_prop_value_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN doc_prop_value_type.doc_prop_value_type_id%TYPE;

  FUNCTION get_record(par_doc_prop_value_type_id IN doc_prop_value_type.doc_prop_value_type_id%TYPE)
    RETURN doc_prop_value_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_brief IN doc_prop_value_type.brief%TYPE
   ,par_name  IN doc_prop_value_type.name%TYPE
  );

  PROCEDURE insert_record(par_record IN OUT doc_prop_value_type%ROWTYPE);

  PROCEDURE insert_record
  (
    par_brief                  IN doc_prop_value_type.brief%TYPE
   ,par_name                   IN doc_prop_value_type.name%TYPE
   ,par_doc_prop_value_type_id OUT doc_prop_value_type.doc_prop_value_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN doc_prop_value_type%ROWTYPE);

  PROCEDURE delete_record(par_doc_prop_value_type_id IN doc_prop_value_type.doc_prop_value_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_doc_prop_value_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN doc_prop_value_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN doc_prop_value_type.doc_prop_value_type_id%TYPE IS
    v_id doc_prop_value_type.doc_prop_value_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT doc_prop_value_type_id INTO v_id FROM doc_prop_value_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Справочник Тип значения доп. параметра документа" по значению поля "Бриф типа значения": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_doc_prop_value_type_id IN doc_prop_value_type.doc_prop_value_type_id%TYPE)
    RETURN doc_prop_value_type%ROWTYPE IS
    vr_record doc_prop_value_type%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM doc_prop_value_type
     WHERE doc_prop_value_type_id = par_doc_prop_value_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_brief IN doc_prop_value_type.brief%TYPE
   ,par_name  IN doc_prop_value_type.name%TYPE
  ) IS
    v_id doc_prop_value_type.doc_prop_value_type_id%TYPE;
  BEGIN
    insert_record(par_brief => par_brief, par_name => par_name, par_doc_prop_value_type_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT doc_prop_value_type%ROWTYPE) IS
    v_id doc_prop_value_type.doc_prop_value_type_id%TYPE;
  BEGIN
    insert_record(par_brief                  => par_record.brief
                 ,par_name                   => par_record.name
                 ,par_doc_prop_value_type_id => par_record.doc_prop_value_type_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_brief                  IN doc_prop_value_type.brief%TYPE
   ,par_name                   IN doc_prop_value_type.name%TYPE
   ,par_doc_prop_value_type_id OUT doc_prop_value_type.doc_prop_value_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_doc_prop_value_type.nextval INTO par_doc_prop_value_type_id FROM dual;
    INSERT INTO doc_prop_value_type
      (doc_prop_value_type_id, NAME, brief)
    VALUES
      (par_doc_prop_value_type_id, par_name, par_brief);
  END insert_record;

  PROCEDURE update_record(par_record IN doc_prop_value_type%ROWTYPE) IS
  BEGIN
    UPDATE doc_prop_value_type
       SET brief = par_record.brief
          ,NAME  = par_record.name
     WHERE doc_prop_value_type_id = par_record.doc_prop_value_type_id;
  END update_record;

  PROCEDURE delete_record(par_doc_prop_value_type_id IN doc_prop_value_type.doc_prop_value_type_id%TYPE) IS
  BEGIN
    DELETE FROM doc_prop_value_type WHERE doc_prop_value_type_id = par_doc_prop_value_type_id;
  END delete_record;
END;
/
