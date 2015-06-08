CREATE OR REPLACE PACKAGE pkg_t_exchange_format_dml IS

  FUNCTION get_record(par_t_exchange_format_id IN t_exchange_format.t_exchange_format_id%TYPE)
    RETURN t_exchange_format%ROWTYPE;
  FUNCTION get_id_by_brief
  (
    par_brief          IN t_exchange_format.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_exchange_format.t_exchange_format_id%TYPE;
  PROCEDURE insert_record
  (
    par_brief                IN t_exchange_format.brief%TYPE
   ,par_name                 IN t_exchange_format.name%TYPE
   ,par_description          IN t_exchange_format.description%TYPE
   ,par_format_type          IN t_exchange_format.format_type%TYPE
   ,par_t_exchange_format_id OUT t_exchange_format.t_exchange_format_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_exchange_format%ROWTYPE);
  PROCEDURE delete_record(par_t_exchange_format_id IN t_exchange_format.t_exchange_format_id%TYPE);
END pkg_t_exchange_format_dml;
/
CREATE OR REPLACE PACKAGE BODY pkg_t_exchange_format_dml IS

  FUNCTION get_record(par_t_exchange_format_id IN t_exchange_format.t_exchange_format_id%TYPE)
    RETURN t_exchange_format%ROWTYPE IS
    vr_record t_exchange_format%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM t_exchange_format
     WHERE t_exchange_format_id = par_t_exchange_format_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_exchange_format.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_exchange_format.t_exchange_format_id%TYPE IS
    v_id t_exchange_format.t_exchange_format_id%TYPE;
  BEGIN
    BEGIN
      SELECT f.t_exchange_format_id INTO v_id FROM t_exchange_format f WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Ќе найден формат по краткому названию "' || par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  PROCEDURE insert_record
  (
    par_brief                IN t_exchange_format.brief%TYPE
   ,par_name                 IN t_exchange_format.name%TYPE
   ,par_description          IN t_exchange_format.description%TYPE
   ,par_format_type          IN t_exchange_format.format_type%TYPE
   ,par_t_exchange_format_id OUT t_exchange_format.t_exchange_format_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_exchange_format.nextval INTO par_t_exchange_format_id FROM dual;
    INSERT INTO t_exchange_format
      (t_exchange_format_id, description, format_type, NAME, brief)
    VALUES
      (par_t_exchange_format_id, par_description, par_format_type, par_name, par_brief);
  END insert_record;
  PROCEDURE update_record(par_record IN t_exchange_format%ROWTYPE) IS
  BEGIN
    UPDATE t_exchange_format
       SET NAME        = par_record.name
          ,brief       = par_record.brief
          ,format_type = par_record.format_type
          ,description = par_record.description
     WHERE t_exchange_format_id = par_record.t_exchange_format_id;
  END update_record;
  PROCEDURE delete_record(par_t_exchange_format_id IN t_exchange_format.t_exchange_format_id%TYPE) IS
  BEGIN
    DELETE FROM t_exchange_format WHERE t_exchange_format_id = par_t_exchange_format_id;
  END delete_record;
END pkg_t_exchange_format_dml;
/
