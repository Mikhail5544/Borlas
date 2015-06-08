CREATE OR REPLACE PACKAGE dml_bso_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN bso_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_type.bso_type_id%TYPE;

  FUNCTION get_record(par_bso_type_id IN bso_type.bso_type_id%TYPE) RETURN bso_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name       IN bso_type.name%TYPE
   ,par_brief      IN bso_type.brief%TYPE
   ,par_kind_brief IN bso_type.kind_brief%TYPE DEFAULT NULL
   ,par_check_mo   IN bso_type.check_mo%TYPE DEFAULT 0
   ,par_check_ac   IN bso_type.check_ac%TYPE DEFAULT 0
  );

  PROCEDURE insert_record
  (
    par_name        IN bso_type.name%TYPE
   ,par_brief       IN bso_type.brief%TYPE
   ,par_kind_brief  IN bso_type.kind_brief%TYPE DEFAULT NULL
   ,par_check_mo    IN bso_type.check_mo%TYPE DEFAULT 0
   ,par_check_ac    IN bso_type.check_ac%TYPE DEFAULT 0
   ,par_bso_type_id OUT bso_type.bso_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN bso_type%ROWTYPE);

  PROCEDURE delete_record(par_bso_type_id IN bso_type.bso_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_bso_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN bso_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_type.bso_type_id%TYPE IS
    v_id bso_type.bso_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT bso_type_id INTO v_id FROM bso_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Вид бланка строгой отчетности" по значению поля "Обозначение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_bso_type_id IN bso_type.bso_type_id%TYPE) RETURN bso_type%ROWTYPE IS
    vr_record bso_type%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM bso_type WHERE bso_type_id = par_bso_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name       IN bso_type.name%TYPE
   ,par_brief      IN bso_type.brief%TYPE
   ,par_kind_brief IN bso_type.kind_brief%TYPE DEFAULT NULL
   ,par_check_mo   IN bso_type.check_mo%TYPE DEFAULT 0
   ,par_check_ac   IN bso_type.check_ac%TYPE DEFAULT 0
  ) IS
    v_id bso_type.bso_type_id%TYPE;
  BEGIN
    insert_record(par_name        => par_name
                 ,par_brief       => par_brief
                 ,par_kind_brief  => par_kind_brief
                 ,par_check_mo    => par_check_mo
                 ,par_check_ac    => par_check_ac
                 ,par_bso_type_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name        IN bso_type.name%TYPE
   ,par_brief       IN bso_type.brief%TYPE
   ,par_kind_brief  IN bso_type.kind_brief%TYPE DEFAULT NULL
   ,par_check_mo    IN bso_type.check_mo%TYPE DEFAULT 0
   ,par_check_ac    IN bso_type.check_ac%TYPE DEFAULT 0
   ,par_bso_type_id OUT bso_type.bso_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_bso_type.nextval INTO par_bso_type_id FROM dual;
    INSERT INTO bso_type
      (bso_type_id, check_ac, kind_brief, check_mo, NAME, brief)
    VALUES
      (par_bso_type_id, par_check_ac, par_kind_brief, par_check_mo, par_name, par_brief);
  END insert_record;

  PROCEDURE update_record(par_record IN bso_type%ROWTYPE) IS
  BEGIN
    UPDATE bso_type
       SET NAME       = par_record.name
          ,brief      = par_record.brief
          ,kind_brief = par_record.kind_brief
          ,check_mo   = par_record.check_mo
          ,check_ac   = par_record.check_ac
     WHERE bso_type_id = par_record.bso_type_id;
  END update_record;

  PROCEDURE delete_record(par_bso_type_id IN bso_type.bso_type_id%TYPE) IS
  BEGIN
    DELETE FROM bso_type WHERE bso_type_id = par_bso_type_id;
  END delete_record;
END;
/
