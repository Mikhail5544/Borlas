CREATE OR REPLACE PACKAGE dml_t_attribut_source IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_attribut_source.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_attribut_source.t_attribut_source_id%TYPE;

  FUNCTION get_id_by_name
  (
    par_name           IN t_attribut_source.name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_attribut_source.t_attribut_source_id%TYPE;

  FUNCTION get_record(par_t_attribut_source_id IN t_attribut_source.t_attribut_source_id%TYPE)
    RETURN t_attribut_source%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name  IN t_attribut_source.name%TYPE
   ,par_brief IN t_attribut_source.brief%TYPE
  );

  PROCEDURE insert_record
  (
    par_name                 IN t_attribut_source.name%TYPE
   ,par_brief                IN t_attribut_source.brief%TYPE
   ,par_t_attribut_source_id OUT t_attribut_source.t_attribut_source_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_attribut_source%ROWTYPE);

  PROCEDURE delete_record(par_t_attribut_source_id IN t_attribut_source.t_attribut_source_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_attribut_source IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_attribut_source.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_attribut_source.t_attribut_source_id%TYPE IS
    v_id t_attribut_source.t_attribut_source_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_attribut_source_id INTO v_id FROM t_attribut_source WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Источник атрибутов" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_id_by_name
  (
    par_name           IN t_attribut_source.name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_attribut_source.t_attribut_source_id%TYPE IS
    v_id t_attribut_source.t_attribut_source_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_attribut_source_id INTO v_id FROM t_attribut_source WHERE NAME = par_name;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Источник атрибутов" по значению поля "Наименование": ' ||
                   par_name);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_name;

  FUNCTION get_record(par_t_attribut_source_id IN t_attribut_source.t_attribut_source_id%TYPE)
    RETURN t_attribut_source%ROWTYPE IS
    vr_record t_attribut_source%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM t_attribut_source
     WHERE t_attribut_source_id = par_t_attribut_source_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name  IN t_attribut_source.name%TYPE
   ,par_brief IN t_attribut_source.brief%TYPE
  ) IS
    v_id t_attribut_source.t_attribut_source_id%TYPE;
  BEGIN
    insert_record(par_name => par_name, par_brief => par_brief, par_t_attribut_source_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                 IN t_attribut_source.name%TYPE
   ,par_brief                IN t_attribut_source.brief%TYPE
   ,par_t_attribut_source_id OUT t_attribut_source.t_attribut_source_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_attribut_source.nextval INTO par_t_attribut_source_id FROM dual;
    INSERT INTO t_attribut_source
      (t_attribut_source_id, brief, NAME)
    VALUES
      (par_t_attribut_source_id, par_brief, par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN t_attribut_source%ROWTYPE) IS
  BEGIN
    UPDATE t_attribut_source
       SET NAME  = par_record.name
          ,brief = par_record.brief
     WHERE t_attribut_source_id = par_record.t_attribut_source_id;
  END update_record;

  PROCEDURE delete_record(par_t_attribut_source_id IN t_attribut_source.t_attribut_source_id%TYPE) IS
  BEGIN
    DELETE FROM t_attribut_source WHERE t_attribut_source_id = par_t_attribut_source_id;
  END delete_record;
END;
/
