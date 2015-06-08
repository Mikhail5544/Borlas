CREATE OR REPLACE PACKAGE dml_load_csv_list IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN load_csv_list.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN load_csv_list.load_csv_list_id%TYPE;

  FUNCTION get_id_by_load_csv_name
  (
    par_load_csv_name  IN load_csv_list.load_csv_name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN load_csv_list.load_csv_list_id%TYPE;

  FUNCTION get_record(par_load_csv_list_id IN load_csv_list.load_csv_list_id%TYPE)
    RETURN load_csv_list%ROWTYPE;

  PROCEDURE insert_record
  (
    par_brief             IN load_csv_list.brief%TYPE
   ,par_load_csv_group_id IN load_csv_list.load_csv_group_id%TYPE
   ,par_load_csv_name     IN load_csv_list.load_csv_name%TYPE
   ,par_start_date        IN load_csv_list.start_date%TYPE DEFAULT SYSDATE
   ,par_is_group_process  IN load_csv_list.is_group_process%TYPE DEFAULT 0
   ,par_rows_in_header    IN load_csv_list.rows_in_header%TYPE DEFAULT 1
   ,par_check_procedure   IN load_csv_list.check_procedure%TYPE DEFAULT NULL
   ,par_load_procedure    IN load_csv_list.load_procedure%TYPE DEFAULT NULL
   ,par_end_date          IN load_csv_list.end_date%TYPE DEFAULT NULL
   ,par_delete_procedure  IN load_csv_list.delete_procedure%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record
  (
    par_brief             IN load_csv_list.brief%TYPE
   ,par_load_csv_group_id IN load_csv_list.load_csv_group_id%TYPE
   ,par_load_csv_name     IN load_csv_list.load_csv_name%TYPE
   ,par_start_date        IN load_csv_list.start_date%TYPE DEFAULT SYSDATE
   ,par_is_group_process  IN load_csv_list.is_group_process%TYPE DEFAULT 0
   ,par_rows_in_header    IN load_csv_list.rows_in_header%TYPE DEFAULT 1
   ,par_check_procedure   IN load_csv_list.check_procedure%TYPE DEFAULT NULL
   ,par_load_procedure    IN load_csv_list.load_procedure%TYPE DEFAULT NULL
   ,par_end_date          IN load_csv_list.end_date%TYPE DEFAULT NULL
   ,par_delete_procedure  IN load_csv_list.delete_procedure%TYPE DEFAULT NULL
   ,par_load_csv_list_id  OUT load_csv_list.load_csv_list_id%TYPE
  );
  PROCEDURE update_record(par_record IN load_csv_list%ROWTYPE);

  PROCEDURE delete_record(par_load_csv_list_id IN load_csv_list.load_csv_list_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_load_csv_list IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN load_csv_list.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN load_csv_list.load_csv_list_id%TYPE IS
    v_id load_csv_list.load_csv_list_id%TYPE;
  BEGIN
    BEGIN
      SELECT load_csv_list_id INTO v_id FROM load_csv_list WHERE brief = par_brief;
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

  FUNCTION get_id_by_load_csv_name
  (
    par_load_csv_name  IN load_csv_list.load_csv_name%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN load_csv_list.load_csv_list_id%TYPE IS
    v_id load_csv_list.load_csv_list_id%TYPE;
  BEGIN
    BEGIN
      SELECT load_csv_list_id INTO v_id FROM load_csv_list WHERE load_csv_name = par_load_csv_name;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена запись по значению поля "' || par_load_csv_name || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_load_csv_name;

  FUNCTION get_record(par_load_csv_list_id IN load_csv_list.load_csv_list_id%TYPE)
    RETURN load_csv_list%ROWTYPE IS
    vr_record load_csv_list%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM load_csv_list WHERE load_csv_list_id = par_load_csv_list_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_brief             IN load_csv_list.brief%TYPE
   ,par_load_csv_group_id IN load_csv_list.load_csv_group_id%TYPE
   ,par_load_csv_name     IN load_csv_list.load_csv_name%TYPE
   ,par_start_date        IN load_csv_list.start_date%TYPE DEFAULT SYSDATE
   ,par_is_group_process  IN load_csv_list.is_group_process%TYPE DEFAULT 0
   ,par_rows_in_header    IN load_csv_list.rows_in_header%TYPE DEFAULT 1
   ,par_check_procedure   IN load_csv_list.check_procedure%TYPE DEFAULT NULL
   ,par_load_procedure    IN load_csv_list.load_procedure%TYPE DEFAULT NULL
   ,par_end_date          IN load_csv_list.end_date%TYPE DEFAULT NULL
   ,par_delete_procedure  IN load_csv_list.delete_procedure%TYPE DEFAULT NULL
  ) IS
    v_load_csv_list_id load_csv_list.load_csv_list_id%TYPE;
  BEGIN
    insert_record(par_brief             => par_brief
                 ,par_load_csv_group_id => par_load_csv_group_id
                 ,par_load_csv_name     => par_load_csv_name
                 ,par_start_date        => par_start_date
                 ,par_is_group_process  => par_is_group_process
                 ,par_rows_in_header    => par_rows_in_header
                 ,par_check_procedure   => par_check_procedure
                 ,par_load_procedure    => par_load_procedure
                 ,par_end_date          => par_end_date
                 ,par_delete_procedure  => par_delete_procedure
                 ,par_load_csv_list_id  => v_load_csv_list_id);
  END insert_record;

  PROCEDURE insert_record
  (
    par_brief             IN load_csv_list.brief%TYPE
   ,par_load_csv_group_id IN load_csv_list.load_csv_group_id%TYPE
   ,par_load_csv_name     IN load_csv_list.load_csv_name%TYPE
   ,par_start_date        IN load_csv_list.start_date%TYPE DEFAULT SYSDATE
   ,par_is_group_process  IN load_csv_list.is_group_process%TYPE DEFAULT 0
   ,par_rows_in_header    IN load_csv_list.rows_in_header%TYPE DEFAULT 1
   ,par_check_procedure   IN load_csv_list.check_procedure%TYPE DEFAULT NULL
   ,par_load_procedure    IN load_csv_list.load_procedure%TYPE DEFAULT NULL
   ,par_end_date          IN load_csv_list.end_date%TYPE DEFAULT NULL
   ,par_delete_procedure  IN load_csv_list.delete_procedure%TYPE DEFAULT NULL
   ,par_load_csv_list_id  OUT load_csv_list.load_csv_list_id%TYPE
  ) IS
  BEGIN
    SELECT sq_load_csv_list.nextval INTO par_load_csv_list_id FROM dual;
    INSERT INTO load_csv_list
      (load_csv_list_id
      ,rows_in_header
      ,is_group_process
      ,load_csv_name
      ,load_csv_group_id
      ,start_date
      ,end_date
      ,check_procedure
      ,load_procedure
      ,delete_procedure
      ,brief)
    VALUES
      (par_load_csv_list_id
      ,par_rows_in_header
      ,par_is_group_process
      ,par_load_csv_name
      ,par_load_csv_group_id
      ,par_start_date
      ,par_end_date
      ,par_check_procedure
      ,par_load_procedure
      ,par_delete_procedure
      ,par_brief);
  END insert_record;

  PROCEDURE update_record(par_record IN load_csv_list%ROWTYPE) IS
  BEGIN
    UPDATE load_csv_list
       SET delete_procedure  = par_record.delete_procedure
          ,rows_in_header    = par_record.rows_in_header
          ,is_group_process  = par_record.is_group_process
          ,load_csv_name     = par_record.load_csv_name
          ,brief             = par_record.brief
          ,start_date        = par_record.start_date
          ,end_date          = par_record.end_date
          ,check_procedure   = par_record.check_procedure
          ,load_procedure    = par_record.load_procedure
          ,load_csv_group_id = par_record.load_csv_group_id
     WHERE load_csv_list_id = par_record.load_csv_list_id;
  END update_record;

  PROCEDURE delete_record(par_load_csv_list_id IN load_csv_list.load_csv_list_id%TYPE) IS
  BEGIN
    DELETE FROM load_csv_list WHERE load_csv_list_id = par_load_csv_list_id;
  END delete_record;
END;
/
