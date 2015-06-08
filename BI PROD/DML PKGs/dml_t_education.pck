CREATE OR REPLACE PACKAGE dml_t_education IS

  FUNCTION get_id_by_description
  (
    par_description    IN t_education.description%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_education.id%TYPE;

  FUNCTION get_record(par_id IN t_education.id%TYPE) RETURN t_education%ROWTYPE;

  PROCEDURE insert_record
  (
    par_description IN t_education.description%TYPE
   ,par_is_default  IN t_education.is_default%TYPE DEFAULT 0
  );

  PROCEDURE insert_record
  (
    par_description IN t_education.description%TYPE
   ,par_is_default  IN t_education.is_default%TYPE DEFAULT 0
   ,par_id          OUT t_education.id%TYPE
  );

  PROCEDURE update_record(par_record IN t_education%ROWTYPE);

  PROCEDURE delete_record(par_id IN t_education.id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_education IS

  FUNCTION get_id_by_description
  (
    par_description    IN t_education.description%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_education.id%TYPE IS
    v_id t_education.id%TYPE;
  BEGIN
    BEGIN
      SELECT id INTO v_id FROM t_education WHERE description = par_description;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Образование" по значению поля "Наименование": ' ||
                   par_description);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_description;

  FUNCTION get_record(par_id IN t_education.id%TYPE) RETURN t_education%ROWTYPE IS
    vr_record t_education%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_education WHERE id = par_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_description IN t_education.description%TYPE
   ,par_is_default  IN t_education.is_default%TYPE DEFAULT 0
  ) IS
    v_id t_education.id%TYPE;
  BEGIN
    insert_record(par_description => par_description
                 ,par_is_default  => par_is_default
                 ,par_id          => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_description IN t_education.description%TYPE
   ,par_is_default  IN t_education.is_default%TYPE DEFAULT 0
   ,par_id          OUT t_education.id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_education.nextval INTO par_id FROM dual;
    INSERT INTO t_education
      (id, is_default, description)
    VALUES
      (par_id, par_is_default, par_description);
  END insert_record;

  PROCEDURE update_record(par_record IN t_education%ROWTYPE) IS
  BEGIN
    UPDATE t_education
       SET description = par_record.description
          ,is_default  = par_record.is_default
     WHERE id = par_record.id;
  END update_record;

  PROCEDURE delete_record(par_id IN t_education.id%TYPE) IS
  BEGIN
    DELETE FROM t_education WHERE id = par_id;
  END delete_record;
END;
/
