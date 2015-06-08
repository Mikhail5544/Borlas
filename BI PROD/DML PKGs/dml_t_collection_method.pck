CREATE OR REPLACE PACKAGE dml_t_collection_method IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_collection_method.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_collection_method.id%TYPE;

  FUNCTION get_record(par_id IN t_collection_method.id%TYPE) RETURN t_collection_method%ROWTYPE;

  PROCEDURE insert_record
  (
    par_description IN t_collection_method.description%TYPE
   ,par_brief       IN t_collection_method.brief%TYPE
   ,par_is_default  IN t_collection_method.is_default%TYPE DEFAULT 0
  );

  PROCEDURE insert_record(par_record IN OUT t_collection_method%ROWTYPE);

  PROCEDURE insert_record
  (
    par_description IN t_collection_method.description%TYPE
   ,par_brief       IN t_collection_method.brief%TYPE
   ,par_is_default  IN t_collection_method.is_default%TYPE DEFAULT 0
   ,par_id          OUT t_collection_method.id%TYPE
  );

  PROCEDURE update_record(par_record IN t_collection_method%ROWTYPE);

  PROCEDURE delete_record(par_id IN t_collection_method.id%TYPE);
END dml_t_collection_method;
/
CREATE OR REPLACE PACKAGE BODY dml_t_collection_method IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_collection_method.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_collection_method.id%TYPE IS
    v_id t_collection_method.id%TYPE;
  BEGIN
    BEGIN
      SELECT id INTO v_id FROM t_collection_method WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Способ оплаты" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_id IN t_collection_method.id%TYPE) RETURN t_collection_method%ROWTYPE IS
    vr_record t_collection_method%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_collection_method WHERE id = par_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_description IN t_collection_method.description%TYPE
   ,par_brief       IN t_collection_method.brief%TYPE
   ,par_is_default  IN t_collection_method.is_default%TYPE DEFAULT 0
  ) IS
    v_id t_collection_method.id%TYPE;
  BEGIN
    insert_record(par_description => par_description
                 ,par_brief       => par_brief
                 ,par_is_default  => par_is_default
                 ,par_id          => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT t_collection_method%ROWTYPE) IS
  BEGIN
    insert_record(par_description => par_record.description
                 ,par_brief       => par_record.brief
                 ,par_is_default  => par_record.is_default
                 ,par_id          => par_record.id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_description IN t_collection_method.description%TYPE
   ,par_brief       IN t_collection_method.brief%TYPE
   ,par_is_default  IN t_collection_method.is_default%TYPE DEFAULT 0
   ,par_id          OUT t_collection_method.id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_collection_method.nextval INTO par_id FROM dual;
    INSERT INTO t_collection_method
      (id, is_default, brief, description)
    VALUES
      (par_id, par_is_default, par_brief, par_description);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record(par_record IN t_collection_method%ROWTYPE) IS
  BEGIN
    UPDATE t_collection_method
       SET description = par_record.description
          ,is_default  = par_record.is_default
          ,brief       = par_record.brief
     WHERE id = par_record.id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record(par_id IN t_collection_method.id%TYPE) IS
  BEGIN
    DELETE FROM t_collection_method WHERE id = par_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;
END dml_t_collection_method;
/
