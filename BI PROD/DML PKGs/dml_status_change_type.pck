CREATE OR REPLACE PACKAGE dml_status_change_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN status_change_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN status_change_type.status_change_type_id%TYPE;

  FUNCTION get_record(par_status_change_type_id IN status_change_type.status_change_type_id%TYPE)
    RETURN status_change_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name  IN status_change_type.name%TYPE
   ,par_brief IN status_change_type.brief%TYPE
  );

  PROCEDURE insert_record
  (
    par_name                  IN status_change_type.name%TYPE
   ,par_brief                 IN status_change_type.brief%TYPE
   ,par_status_change_type_id OUT status_change_type.status_change_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN status_change_type%ROWTYPE);

  PROCEDURE delete_record(par_status_change_type_id IN status_change_type.status_change_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_status_change_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN status_change_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN status_change_type.status_change_type_id%TYPE IS
    v_id status_change_type.status_change_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT status_change_type_id INTO v_id FROM status_change_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Тип изменения статуса" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_status_change_type_id IN status_change_type.status_change_type_id%TYPE)
    RETURN status_change_type%ROWTYPE IS
    vr_record status_change_type%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM status_change_type
     WHERE status_change_type_id = par_status_change_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name  IN status_change_type.name%TYPE
   ,par_brief IN status_change_type.brief%TYPE
  ) IS
    v_id status_change_type.status_change_type_id%TYPE;
  BEGIN
    insert_record(par_name => par_name, par_brief => par_brief, par_status_change_type_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                  IN status_change_type.name%TYPE
   ,par_brief                 IN status_change_type.brief%TYPE
   ,par_status_change_type_id OUT status_change_type.status_change_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_status_change_type.nextval INTO par_status_change_type_id FROM dual;
    INSERT INTO status_change_type
      (status_change_type_id, brief, NAME)
    VALUES
      (par_status_change_type_id, par_brief, par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN status_change_type%ROWTYPE) IS
  BEGIN
    UPDATE status_change_type
       SET NAME  = par_record.name
          ,brief = par_record.brief
     WHERE status_change_type_id = par_record.status_change_type_id;
  END update_record;

  PROCEDURE delete_record(par_status_change_type_id IN status_change_type.status_change_type_id%TYPE) IS
  BEGIN
    DELETE FROM status_change_type WHERE status_change_type_id = par_status_change_type_id;
  END delete_record;
END;
/
