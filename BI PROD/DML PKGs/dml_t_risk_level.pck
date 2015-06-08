CREATE OR REPLACE PACKAGE dml_t_risk_level IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_risk_level.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_risk_level.t_risk_level_id%TYPE;

  FUNCTION get_record(par_t_risk_level_id IN t_risk_level.t_risk_level_id%TYPE)
    RETURN t_risk_level%ROWTYPE;

  PROCEDURE insert_record
  (
    par_description IN t_risk_level.description%TYPE DEFAULT NULL
   ,par_brief       IN t_risk_level.brief%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record
  (
    par_description     IN t_risk_level.description%TYPE DEFAULT NULL
   ,par_brief           IN t_risk_level.brief%TYPE DEFAULT NULL
   ,par_t_risk_level_id OUT t_risk_level.t_risk_level_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_risk_level%ROWTYPE);

  PROCEDURE delete_record(par_t_risk_level_id IN t_risk_level.t_risk_level_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_risk_level IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_risk_level.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_risk_level.t_risk_level_id%TYPE IS
    v_id t_risk_level.t_risk_level_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_risk_level_id INTO v_id FROM t_risk_level WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Уровень риска" по значению поля "Сокращенное описание уровня риска": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_t_risk_level_id IN t_risk_level.t_risk_level_id%TYPE)
    RETURN t_risk_level%ROWTYPE IS
    vr_record t_risk_level%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_risk_level WHERE t_risk_level_id = par_t_risk_level_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_description IN t_risk_level.description%TYPE DEFAULT NULL
   ,par_brief       IN t_risk_level.brief%TYPE DEFAULT NULL
  ) IS
    v_id t_risk_level.t_risk_level_id%TYPE;
  BEGIN
    insert_record(par_description     => par_description
                 ,par_brief           => par_brief
                 ,par_t_risk_level_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_description     IN t_risk_level.description%TYPE DEFAULT NULL
   ,par_brief           IN t_risk_level.brief%TYPE DEFAULT NULL
   ,par_t_risk_level_id OUT t_risk_level.t_risk_level_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_risk_level.nextval INTO par_t_risk_level_id FROM dual;
    INSERT INTO t_risk_level
      (t_risk_level_id, brief, description)
    VALUES
      (par_t_risk_level_id, par_brief, par_description);
  END insert_record;

  PROCEDURE update_record(par_record IN t_risk_level%ROWTYPE) IS
  BEGIN
    UPDATE t_risk_level
       SET description = par_record.description
          ,brief       = par_record.brief
     WHERE t_risk_level_id = par_record.t_risk_level_id;
  END update_record;

  PROCEDURE delete_record(par_t_risk_level_id IN t_risk_level.t_risk_level_id%TYPE) IS
  BEGIN
    DELETE FROM t_risk_level WHERE t_risk_level_id = par_t_risk_level_id;
  END delete_record;
END;
/
