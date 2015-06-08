CREATE OR REPLACE PACKAGE dml_load_csv_group IS

  FUNCTION get_id_by_load_group_code
  (
    par_load_group_code IN load_csv_group.load_group_code%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN load_csv_group.load_csv_group_id%TYPE;

  FUNCTION get_record(par_load_csv_group_id IN load_csv_group.load_csv_group_id%TYPE)
    RETURN load_csv_group%ROWTYPE;
  PROCEDURE insert_record
  (
    par_load_group_name IN load_csv_group.load_group_name%TYPE
   ,par_load_group_code IN load_csv_group.load_group_code%TYPE
  );
  PROCEDURE insert_record
  (
    par_load_group_name   IN load_csv_group.load_group_name%TYPE
   ,par_load_group_code   IN load_csv_group.load_group_code%TYPE
   ,par_load_csv_group_id OUT load_csv_group.load_csv_group_id%TYPE
  );
  PROCEDURE update_record(par_record IN load_csv_group%ROWTYPE);
  PROCEDURE delete_record(par_load_csv_group_id IN load_csv_group.load_csv_group_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_load_csv_group IS

  FUNCTION get_id_by_load_group_code
  (
    par_load_group_code IN load_csv_group.load_group_code%TYPE
   ,par_raise_on_error  BOOLEAN DEFAULT TRUE
  ) RETURN load_csv_group.load_csv_group_id%TYPE IS
    v_id load_csv_group.load_csv_group_id%TYPE;
  BEGIN
    BEGIN
      SELECT load_csv_group_id
        INTO v_id
        FROM load_csv_group
       WHERE load_group_code = par_load_group_code;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена запись по значению поля "' || par_load_group_code || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_load_group_code;

  FUNCTION get_record(par_load_csv_group_id IN load_csv_group.load_csv_group_id%TYPE)
    RETURN load_csv_group%ROWTYPE IS
    vr_record load_csv_group%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM load_csv_group WHERE load_csv_group_id = par_load_csv_group_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;
	
  PROCEDURE insert_record
  (
    par_load_group_name IN load_csv_group.load_group_name%TYPE
   ,par_load_group_code IN load_csv_group.load_group_code%TYPE
  ) IS
    v_load_csv_group_id load_csv_group.load_csv_group_id%TYPE;
  BEGIN
    insert_record(par_load_group_name   => par_load_group_name
                 ,par_load_group_code   => par_load_group_code
                 ,par_load_csv_group_id => v_load_csv_group_id);
  END insert_record;
	
  PROCEDURE insert_record
  (
    par_load_group_name   IN load_csv_group.load_group_name%TYPE
   ,par_load_group_code   IN load_csv_group.load_group_code%TYPE
   ,par_load_csv_group_id OUT load_csv_group.load_csv_group_id%TYPE
  ) IS
  BEGIN
    SELECT sq_load_csv_group.nextval INTO par_load_csv_group_id FROM dual;
    INSERT INTO load_csv_group
      (load_csv_group_id, load_group_code, load_group_name)
    VALUES
      (par_load_csv_group_id, par_load_group_code, par_load_group_name);
  END insert_record;
	
  PROCEDURE update_record(par_record IN load_csv_group%ROWTYPE) IS
  BEGIN
    UPDATE load_csv_group
       SET load_group_name = par_record.load_group_name
          ,load_group_code = par_record.load_group_code
     WHERE load_csv_group_id = par_record.load_csv_group_id;
  END update_record;
	
  PROCEDURE delete_record(par_load_csv_group_id IN load_csv_group.load_csv_group_id%TYPE) IS
  BEGIN
    DELETE FROM load_csv_group WHERE load_csv_group_id = par_load_csv_group_id;
  END delete_record;
END;
/
