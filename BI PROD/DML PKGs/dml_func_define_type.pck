CREATE OR REPLACE PACKAGE dml_func_define_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN func_define_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN func_define_type.func_define_type_id%TYPE;

  FUNCTION get_record(par_func_define_type_id IN func_define_type.func_define_type_id%TYPE)
    RETURN func_define_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name       IN func_define_type.name%TYPE
   ,par_brief      IN func_define_type.brief%TYPE
   ,par_is_default IN func_define_type.is_default%TYPE DEFAULT 0
  );

  PROCEDURE insert_record
  (
    par_name                IN func_define_type.name%TYPE
   ,par_brief               IN func_define_type.brief%TYPE
   ,par_is_default          IN func_define_type.is_default%TYPE DEFAULT 0
   ,par_func_define_type_id OUT func_define_type.func_define_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN func_define_type%ROWTYPE);

  PROCEDURE delete_record(par_func_define_type_id IN func_define_type.func_define_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_func_define_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN func_define_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN func_define_type.func_define_type_id%TYPE IS
    v_id func_define_type.func_define_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT func_define_type_id INTO v_id FROM func_define_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Тип определения фукнции" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_func_define_type_id IN func_define_type.func_define_type_id%TYPE)
    RETURN func_define_type%ROWTYPE IS
    vr_record func_define_type%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM func_define_type WHERE func_define_type_id = par_func_define_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name       IN func_define_type.name%TYPE
   ,par_brief      IN func_define_type.brief%TYPE
   ,par_is_default IN func_define_type.is_default%TYPE DEFAULT 0
  ) IS
    v_id func_define_type.func_define_type_id%TYPE;
  BEGIN
    insert_record(par_name                => par_name
                 ,par_brief               => par_brief
                 ,par_is_default          => par_is_default
                 ,par_func_define_type_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                IN func_define_type.name%TYPE
   ,par_brief               IN func_define_type.brief%TYPE
   ,par_is_default          IN func_define_type.is_default%TYPE DEFAULT 0
   ,par_func_define_type_id OUT func_define_type.func_define_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_func_define_type.nextval INTO par_func_define_type_id FROM dual;
    INSERT INTO func_define_type
      (func_define_type_id, brief, is_default, NAME)
    VALUES
      (par_func_define_type_id, par_brief, par_is_default, par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN func_define_type%ROWTYPE) IS
  BEGIN
    UPDATE func_define_type
       SET NAME       = par_record.name
          ,brief      = par_record.brief
          ,is_default = par_record.is_default
     WHERE func_define_type_id = par_record.func_define_type_id;
  END update_record;

  PROCEDURE delete_record(par_func_define_type_id IN func_define_type.func_define_type_id%TYPE) IS
  BEGIN
    DELETE FROM func_define_type WHERE func_define_type_id = par_func_define_type_id;
  END delete_record;
END;
/
