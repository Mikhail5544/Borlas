CREATE OR REPLACE PACKAGE pkg_t_decline_reason_dml IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_decline_reason.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_decline_reason.t_decline_reason_id%TYPE;

  FUNCTION get_record(par_t_decline_reason_id IN t_decline_reason.t_decline_reason_id%TYPE)
    RETURN t_decline_reason%ROWTYPE;
  PROCEDURE insert_record
  (
    par_brief               IN t_decline_reason.brief%TYPE
   ,par_name                IN t_decline_reason.name%TYPE
   ,par_short_name          IN t_decline_reason.short_name%TYPE DEFAULT NULL
   ,par_t_decline_type_id   IN t_decline_reason.t_decline_type_id%TYPE DEFAULT NULL
   ,par_t_decline_party_id  IN t_decline_reason.t_decline_party_id%TYPE DEFAULT NULL
   ,par_t_decline_reason_id OUT t_decline_reason.t_decline_reason_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_decline_reason%ROWTYPE);
  PROCEDURE delete_record(par_t_decline_reason_id IN t_decline_reason.t_decline_reason_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_t_decline_reason_dml IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_decline_reason.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_decline_reason.t_decline_reason_id%TYPE IS
    v_id t_decline_reason.t_decline_reason_id%TYPE;
  BEGIN
    BEGIN
      SELECT f.t_decline_reason_id INTO v_id FROM t_decline_reason f WHERE f.brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена причина расторжения по краткому названию "' ||
                                  par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_t_decline_reason_id IN t_decline_reason.t_decline_reason_id%TYPE)
    RETURN t_decline_reason%ROWTYPE IS
    vr_record t_decline_reason%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_decline_reason WHERE t_decline_reason_id = par_t_decline_reason_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;
  PROCEDURE insert_record
  (
    par_brief               IN t_decline_reason.brief%TYPE
   ,par_name                IN t_decline_reason.name%TYPE
   ,par_short_name          IN t_decline_reason.short_name%TYPE DEFAULT NULL
   ,par_t_decline_type_id   IN t_decline_reason.t_decline_type_id%TYPE DEFAULT NULL
   ,par_t_decline_party_id  IN t_decline_reason.t_decline_party_id%TYPE DEFAULT NULL
   ,par_t_decline_reason_id OUT t_decline_reason.t_decline_reason_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_decline_reason.nextval INTO par_t_decline_reason_id FROM dual;
    INSERT INTO t_decline_reason
      (t_decline_reason_id, short_name, t_decline_type_id, t_decline_party_id, NAME, brief)
    VALUES
      (par_t_decline_reason_id
      ,par_short_name
      ,par_t_decline_type_id
      ,par_t_decline_party_id
      ,par_name
      ,par_brief);
  END insert_record;
  PROCEDURE update_record(par_record IN t_decline_reason%ROWTYPE) IS
  BEGIN
    UPDATE t_decline_reason
       SET NAME               = par_record.name
          ,brief              = par_record.brief
          ,t_decline_type_id  = par_record.t_decline_type_id
          ,t_decline_party_id = par_record.t_decline_party_id
          ,short_name         = par_record.short_name
     WHERE t_decline_reason_id = par_record.t_decline_reason_id;
  END update_record;
  PROCEDURE delete_record(par_t_decline_reason_id IN t_decline_reason.t_decline_reason_id%TYPE) IS
  BEGIN
    DELETE FROM t_decline_reason WHERE t_decline_reason_id = par_t_decline_reason_id;
  END delete_record;
END;
/
