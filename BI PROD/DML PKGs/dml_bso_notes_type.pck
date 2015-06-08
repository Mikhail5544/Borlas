CREATE OR REPLACE PACKAGE dml_bso_notes_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN bso_notes_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_notes_type.bso_notes_type_id%TYPE;

  FUNCTION get_record(par_bso_notes_type_id IN bso_notes_type.bso_notes_type_id%TYPE)
    RETURN bso_notes_type%ROWTYPE;
  PROCEDURE insert_record
  (
    par_bso_hist_type_id IN bso_notes_type.bso_hist_type_id%TYPE
   ,par_notes            IN bso_notes_type.notes%TYPE
   ,par_brief            IN bso_notes_type.brief%TYPE
  );
  PROCEDURE insert_record
  (
    par_bso_hist_type_id  IN bso_notes_type.bso_hist_type_id%TYPE
   ,par_notes             IN bso_notes_type.notes%TYPE
   ,par_brief             IN bso_notes_type.brief%TYPE
   ,par_bso_notes_type_id OUT bso_notes_type.bso_notes_type_id%TYPE
  );
  PROCEDURE update_record(par_record IN bso_notes_type%ROWTYPE);
  PROCEDURE delete_record(par_bso_notes_type_id IN bso_notes_type.bso_notes_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_bso_notes_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN bso_notes_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_notes_type.bso_notes_type_id%TYPE IS
    v_id bso_notes_type.bso_notes_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT bso_notes_type_id INTO v_id FROM bso_notes_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена запись по значению поля "' || par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_bso_notes_type_id IN bso_notes_type.bso_notes_type_id%TYPE)
    RETURN bso_notes_type%ROWTYPE IS
    vr_record bso_notes_type%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM bso_notes_type WHERE bso_notes_type_id = par_bso_notes_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_bso_hist_type_id IN bso_notes_type.bso_hist_type_id%TYPE
   ,par_notes            IN bso_notes_type.notes%TYPE
   ,par_brief            IN bso_notes_type.brief%TYPE
  ) IS
    v_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE;
  BEGIN
    insert_record(par_bso_hist_type_id  => par_bso_hist_type_id
                 ,par_notes             => par_notes
                 ,par_brief             => par_brief
                 ,par_bso_notes_type_id => v_bso_notes_type_id);
  END insert_record;

  PROCEDURE insert_record
  (
    par_bso_hist_type_id  IN bso_notes_type.bso_hist_type_id%TYPE
   ,par_notes             IN bso_notes_type.notes%TYPE
   ,par_brief             IN bso_notes_type.brief%TYPE
   ,par_bso_notes_type_id OUT bso_notes_type.bso_notes_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_bso_notes_type.nextval INTO par_bso_notes_type_id FROM dual;
    INSERT INTO bso_notes_type
      (bso_notes_type_id, notes, brief, bso_hist_type_id)
    VALUES
      (par_bso_notes_type_id, par_notes, par_brief, par_bso_hist_type_id);
  END insert_record;

  PROCEDURE update_record(par_record IN bso_notes_type%ROWTYPE) IS
  BEGIN
    UPDATE bso_notes_type
       SET bso_hist_type_id = par_record.bso_hist_type_id
          ,notes            = par_record.notes
          ,brief            = par_record.brief
     WHERE bso_notes_type_id = par_record.bso_notes_type_id;
  END update_record;

  PROCEDURE delete_record(par_bso_notes_type_id IN bso_notes_type.bso_notes_type_id%TYPE) IS
  BEGIN
    DELETE FROM bso_notes_type WHERE bso_notes_type_id = par_bso_notes_type_id;
  END delete_record;
END;
/
