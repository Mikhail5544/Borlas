CREATE OR REPLACE PACKAGE dml_t_policy_form IS

  FUNCTION get_record(par_t_policy_form_id IN t_policy_form.t_policy_form_id%TYPE)
    RETURN t_policy_form%ROWTYPE;
  FUNCTION get_record_by_brief(par_t_policy_form_brief IN t_policy_form.t_policy_form_brief%TYPE)
    RETURN t_policy_form%ROWTYPE;
  FUNCTION id_by_brief
  (
    par_t_policy_form_brief IN t_policy_form.t_policy_form_brief%TYPE
   ,par_raise_on_error      BOOLEAN DEFAULT TRUE
  ) RETURN t_policy_form.t_policy_form_id%TYPE;
  PROCEDURE insert_record
  (
    par_t_policy_form_name       IN t_policy_form.t_policy_form_name%TYPE
   ,par_t_policy_form_short_name IN t_policy_form.t_policy_form_short_name%TYPE DEFAULT NULL
   ,par_t_policy_form_brief      IN t_policy_form.t_policy_form_brief%TYPE DEFAULT NULL
   ,par_t_policy_form_id         OUT t_policy_form.t_policy_form_id%TYPE
  );
  PROCEDURE insert_record
  (
    par_t_policy_form_name       IN t_policy_form.t_policy_form_name%TYPE
   ,par_t_policy_form_short_name IN t_policy_form.t_policy_form_short_name%TYPE DEFAULT NULL
   ,par_t_policy_form_brief      IN t_policy_form.t_policy_form_brief%TYPE DEFAULT NULL
  );
  PROCEDURE update_record(par_record IN t_policy_form%ROWTYPE);
  PROCEDURE delete_record(par_t_policy_form_id IN t_policy_form.t_policy_form_id%TYPE);
END dml_t_policy_form;
/
CREATE OR REPLACE PACKAGE BODY dml_t_policy_form IS

  FUNCTION get_record(par_t_policy_form_id IN t_policy_form.t_policy_form_id%TYPE)
    RETURN t_policy_form%ROWTYPE IS
    vr_record t_policy_form%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_policy_form WHERE t_policy_form_id = par_t_policy_form_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  FUNCTION get_record_by_brief(par_t_policy_form_brief IN t_policy_form.t_policy_form_brief%TYPE)
    RETURN t_policy_form%ROWTYPE IS
    vr_record t_policy_form%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_policy_form WHERE t_policy_form_brief = par_t_policy_form_brief;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record_by_brief;

  FUNCTION id_by_brief
  (
    par_t_policy_form_brief IN t_policy_form.t_policy_form_brief%TYPE
   ,par_raise_on_error      BOOLEAN DEFAULT TRUE
  ) RETURN t_policy_form.t_policy_form_id%TYPE IS
    v_id t_policy_form.t_policy_form_id%TYPE;
  BEGIN
    SELECT t_policy_form_id
      INTO v_id
      FROM t_policy_form
     WHERE t_policy_form_brief = par_t_policy_form_brief;
    RETURN v_id;
  EXCEPTION
    WHEN no_data_found THEN
      IF par_raise_on_error
      THEN
        RAISE;
      ELSE
        RETURN NULL;
      END IF;
  END id_by_brief;

  PROCEDURE insert_record
  (
    par_t_policy_form_name       IN t_policy_form.t_policy_form_name%TYPE
   ,par_t_policy_form_short_name IN t_policy_form.t_policy_form_short_name%TYPE DEFAULT NULL
   ,par_t_policy_form_brief      IN t_policy_form.t_policy_form_brief%TYPE DEFAULT NULL
   ,par_t_policy_form_id         OUT t_policy_form.t_policy_form_id%TYPE
  ) IS
    v_brief t_policy_form.t_policy_form_brief%TYPE := par_t_policy_form_brief;
  BEGIN
  
    SELECT sq_t_policy_form.nextval INTO par_t_policy_form_id FROM dual;
  
    IF v_brief IS NULL
    THEN
      v_brief := 'CONDS_' || par_t_policy_form_id;
    END IF;
  
    INSERT INTO t_policy_form
      (t_policy_form_id, t_policy_form_brief, t_policy_form_short_name, t_policy_form_name)
    VALUES
      (par_t_policy_form_id, v_brief, par_t_policy_form_short_name, par_t_policy_form_name);
  END insert_record;

  PROCEDURE insert_record
  (
    par_t_policy_form_name       IN t_policy_form.t_policy_form_name%TYPE
   ,par_t_policy_form_short_name IN t_policy_form.t_policy_form_short_name%TYPE DEFAULT NULL
   ,par_t_policy_form_brief      IN t_policy_form.t_policy_form_brief%TYPE DEFAULT NULL
  ) IS
    v_t_policy_form_id t_policy_form.t_policy_form_id%TYPE;
  BEGIN
    insert_record(par_t_policy_form_name       => par_t_policy_form_name
                 ,par_t_policy_form_short_name => par_t_policy_form_short_name
                 ,par_t_policy_form_brief      => par_t_policy_form_brief
                 ,par_t_policy_form_id         => v_t_policy_form_id);
  END insert_record;

  PROCEDURE update_record(par_record IN t_policy_form%ROWTYPE) IS
  BEGIN
    UPDATE t_policy_form
       SET t_policy_form_name       = par_record.t_policy_form_name
          ,t_policy_form_brief      = par_record.t_policy_form_brief
          ,t_policy_form_short_name = par_record.t_policy_form_short_name
     WHERE t_policy_form_id = par_record.t_policy_form_id;
  END update_record;

  PROCEDURE delete_record(par_t_policy_form_id IN t_policy_form.t_policy_form_id%TYPE) IS
  BEGIN
    DELETE FROM t_policy_form WHERE t_policy_form_id = par_t_policy_form_id;
  END delete_record;
END dml_t_policy_form;
/
