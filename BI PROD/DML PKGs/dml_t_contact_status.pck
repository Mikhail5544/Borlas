CREATE OR REPLACE PACKAGE dml_t_contact_status IS

  FUNCTION get_id_by_name
  (
    par_name           IN t_contact_status.name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_contact_status.t_contact_status_id%TYPE;

  FUNCTION get_record(par_t_contact_status_id IN t_contact_status.t_contact_status_id%TYPE)
    RETURN t_contact_status%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name        IN t_contact_status.name%TYPE
   ,par_is_default  IN t_contact_status.is_default%TYPE DEFAULT 0
   ,par_description IN t_contact_status.description%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record
  (
    par_name                IN t_contact_status.name%TYPE
   ,par_is_default          IN t_contact_status.is_default%TYPE DEFAULT 0
   ,par_description         IN t_contact_status.description%TYPE DEFAULT NULL
   ,par_t_contact_status_id OUT t_contact_status.t_contact_status_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_contact_status%ROWTYPE);

  PROCEDURE delete_record(par_t_contact_status_id IN t_contact_status.t_contact_status_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_contact_status IS

  FUNCTION get_id_by_name
  (
    par_name           IN t_contact_status.name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_contact_status.t_contact_status_id%TYPE IS
    v_id t_contact_status.t_contact_status_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_contact_status_id INTO v_id FROM t_contact_status WHERE NAME = par_name;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Статус контакта" по значению поля "Наименование": ' ||
                   par_name);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_name;

  FUNCTION get_record(par_t_contact_status_id IN t_contact_status.t_contact_status_id%TYPE)
    RETURN t_contact_status%ROWTYPE IS
    vr_record t_contact_status%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_contact_status WHERE t_contact_status_id = par_t_contact_status_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name        IN t_contact_status.name%TYPE
   ,par_is_default  IN t_contact_status.is_default%TYPE DEFAULT 0
   ,par_description IN t_contact_status.description%TYPE DEFAULT NULL
  ) IS
    v_id t_contact_status.t_contact_status_id%TYPE;
  BEGIN
    insert_record(par_name                => par_name
                 ,par_is_default          => par_is_default
                 ,par_description         => par_description
                 ,par_t_contact_status_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                IN t_contact_status.name%TYPE
   ,par_is_default          IN t_contact_status.is_default%TYPE DEFAULT 0
   ,par_description         IN t_contact_status.description%TYPE DEFAULT NULL
   ,par_t_contact_status_id OUT t_contact_status.t_contact_status_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_contact_status.nextval INTO par_t_contact_status_id FROM dual;
    INSERT INTO t_contact_status
      (t_contact_status_id, is_default, description, NAME)
    VALUES
      (par_t_contact_status_id, par_is_default, par_description, par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN t_contact_status%ROWTYPE) IS
  BEGIN
    UPDATE t_contact_status
       SET NAME        = par_record.name
          ,is_default  = par_record.is_default
          ,description = par_record.description
     WHERE t_contact_status_id = par_record.t_contact_status_id;
  END update_record;

  PROCEDURE delete_record(par_t_contact_status_id IN t_contact_status.t_contact_status_id%TYPE) IS
  BEGIN
    DELETE FROM t_contact_status WHERE t_contact_status_id = par_t_contact_status_id;
  END delete_record;
END;
/
