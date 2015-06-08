CREATE OR REPLACE PACKAGE pkg_t_mpos_rejection_dml IS

  FUNCTION get_record(par_t_mpos_rejection_id IN t_mpos_rejection.t_mpos_rejection_id%TYPE)
    RETURN t_mpos_rejection%ROWTYPE;
  
  FUNCTION get_id_by_brief
  (
    par_brief          IN t_mpos_rejection.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_mpos_rejection.t_mpos_rejection_id%TYPE;

  PROCEDURE insert_record
  (
    par_name                IN t_mpos_rejection.name%TYPE
   ,par_brief               IN t_mpos_rejection.brief%TYPE
   ,par_t_mpos_rejection_id OUT t_mpos_rejection.t_mpos_rejection_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_mpos_rejection%ROWTYPE);
  PROCEDURE delete_record(par_t_mpos_rejection_id IN t_mpos_rejection.t_mpos_rejection_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_t_mpos_rejection_dml IS

  FUNCTION get_record(par_t_mpos_rejection_id IN t_mpos_rejection.t_mpos_rejection_id%TYPE)
    RETURN t_mpos_rejection%ROWTYPE IS
    vr_record t_mpos_rejection%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_mpos_rejection WHERE t_mpos_rejection_id = par_t_mpos_rejection_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_mpos_rejection.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_mpos_rejection.t_mpos_rejection_id%TYPE IS
    v_id t_mpos_rejection.t_mpos_rejection_id%TYPE;
  BEGIN
    BEGIN
      SELECT f.t_mpos_rejection_id INTO v_id FROM t_mpos_rejection f WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Ќе найдена причина отказа по краткому названию "' || par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  PROCEDURE insert_record
  (
    par_name                IN t_mpos_rejection.name%TYPE
   ,par_brief               IN t_mpos_rejection.brief%TYPE
   ,par_t_mpos_rejection_id OUT t_mpos_rejection.t_mpos_rejection_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_mpos_rejection.nextval INTO par_t_mpos_rejection_id FROM dual;
    INSERT INTO t_mpos_rejection
      (t_mpos_rejection_id, brief, NAME)
    VALUES
      (par_t_mpos_rejection_id, par_brief, par_name);
  END insert_record;
  PROCEDURE update_record(par_record IN t_mpos_rejection%ROWTYPE) IS
  BEGIN
    UPDATE t_mpos_rejection
       SET NAME  = par_record.name
          ,brief = par_record.brief
     WHERE t_mpos_rejection_id = par_record.t_mpos_rejection_id;
  END update_record;
  PROCEDURE delete_record(par_t_mpos_rejection_id IN t_mpos_rejection.t_mpos_rejection_id%TYPE) IS
  BEGIN
    DELETE FROM t_mpos_rejection WHERE t_mpos_rejection_id = par_t_mpos_rejection_id;
  END delete_record;
END;
/
