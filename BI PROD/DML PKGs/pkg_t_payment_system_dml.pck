CREATE OR REPLACE PACKAGE pkg_t_payment_system_dml IS

  FUNCTION get_record(par_t_payment_system_id IN t_payment_system.t_payment_system_id%TYPE)
    RETURN t_payment_system%ROWTYPE;

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_payment_system.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_payment_system.t_payment_system_id%TYPE;

  FUNCTION get_id_by_ext_name
  (
    par_ext_name          IN t_payment_system.ext_name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_payment_system.t_payment_system_id%TYPE;

  PROCEDURE insert_record
  (
    par_name                IN t_payment_system.name%TYPE
   ,par_brief               IN t_payment_system.brief%TYPE
   ,par_t_payment_system_id OUT t_payment_system.t_payment_system_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_payment_system%ROWTYPE);
  PROCEDURE delete_record(par_t_payment_system_id IN t_payment_system.t_payment_system_id%TYPE);
END; 
/
CREATE OR REPLACE PACKAGE BODY pkg_t_payment_system_dml IS

  FUNCTION get_record(par_t_payment_system_id IN t_payment_system.t_payment_system_id%TYPE)
    RETURN t_payment_system%ROWTYPE IS
    vr_record t_payment_system%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_payment_system WHERE t_payment_system_id = par_t_payment_system_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_payment_system.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_payment_system.t_payment_system_id%TYPE IS
    v_id t_payment_system.t_payment_system_id%TYPE;
  BEGIN
    BEGIN
      SELECT f.t_payment_system_id INTO v_id FROM t_payment_system f WHERE f.brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена платежная система по краткому названию "' || par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_id_by_ext_name
  (
    par_ext_name          IN t_payment_system.ext_name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_payment_system.t_payment_system_id%TYPE IS
    v_id t_payment_system.t_payment_system_id%TYPE;
  BEGIN
    BEGIN
      SELECT f.t_payment_system_id INTO v_id FROM t_payment_system f WHERE f.ext_name = par_ext_name;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена платежная система по названию внешней системы "' || par_ext_name || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_ext_name;

  PROCEDURE insert_record
  (
    par_name                IN t_payment_system.name%TYPE
   ,par_brief               IN t_payment_system.brief%TYPE
   ,par_t_payment_system_id OUT t_payment_system.t_payment_system_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_payment_system.nextval INTO par_t_payment_system_id FROM dual;
    INSERT INTO t_payment_system
      (t_payment_system_id, brief, NAME)
    VALUES
      (par_t_payment_system_id, par_brief, par_name);
  END insert_record;
  PROCEDURE update_record(par_record IN t_payment_system%ROWTYPE) IS
  BEGIN
    UPDATE t_payment_system
       SET NAME  = par_record.name
          ,brief = par_record.brief
     WHERE t_payment_system_id = par_record.t_payment_system_id;
  END update_record;
  PROCEDURE delete_record(par_t_payment_system_id IN t_payment_system.t_payment_system_id%TYPE) IS
  BEGIN
    DELETE FROM t_payment_system WHERE t_payment_system_id = par_t_payment_system_id;
  END delete_record;
END; 
/
