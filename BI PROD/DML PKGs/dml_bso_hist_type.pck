CREATE OR REPLACE PACKAGE dml_bso_hist_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN bso_hist_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_hist_type.bso_hist_type_id%TYPE;

  FUNCTION get_record(par_bso_hist_type_id IN bso_hist_type.bso_hist_type_id%TYPE)
    RETURN bso_hist_type%ROWTYPE;
  PROCEDURE insert_record
  (
    par_name  IN bso_hist_type.name%TYPE
   ,par_brief IN bso_hist_type.brief%TYPE
  );
  PROCEDURE insert_record
  (
    par_name             IN bso_hist_type.name%TYPE
   ,par_brief            IN bso_hist_type.brief%TYPE
   ,par_bso_hist_type_id OUT bso_hist_type.bso_hist_type_id%TYPE
  );
  PROCEDURE update_record(par_record IN bso_hist_type%ROWTYPE);
  PROCEDURE delete_record(par_bso_hist_type_id IN bso_hist_type.bso_hist_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_bso_hist_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN bso_hist_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_hist_type.bso_hist_type_id%TYPE IS
    v_id bso_hist_type.bso_hist_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT bso_hist_type_id INTO v_id FROM bso_hist_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Вид состояния БСО" по значению поля "Обозначение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_bso_hist_type_id IN bso_hist_type.bso_hist_type_id%TYPE)
    RETURN bso_hist_type%ROWTYPE IS
    vr_record bso_hist_type%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM bso_hist_type WHERE bso_hist_type_id = par_bso_hist_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name  IN bso_hist_type.name%TYPE
   ,par_brief IN bso_hist_type.brief%TYPE
  ) IS
    v_id bso_hist_type.bso_hist_type_id%TYPE;
  BEGIN
    insert_record(par_name => par_name, par_brief => par_brief, par_bso_hist_type_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name             IN bso_hist_type.name%TYPE
   ,par_brief            IN bso_hist_type.brief%TYPE
   ,par_bso_hist_type_id OUT bso_hist_type.bso_hist_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_bso_hist_type.nextval INTO par_bso_hist_type_id FROM dual;
    INSERT INTO bso_hist_type
      (bso_hist_type_id, brief, NAME)
    VALUES
      (par_bso_hist_type_id, par_brief, par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN bso_hist_type%ROWTYPE) IS
  BEGIN
    UPDATE bso_hist_type
       SET NAME  = par_record.name
          ,brief = par_record.brief
     WHERE bso_hist_type_id = par_record.bso_hist_type_id;
  END update_record;

  PROCEDURE delete_record(par_bso_hist_type_id IN bso_hist_type.bso_hist_type_id%TYPE) IS
  BEGIN
    DELETE FROM bso_hist_type WHERE bso_hist_type_id = par_bso_hist_type_id;
  END delete_record;
END;
/
