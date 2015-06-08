CREATE OR REPLACE PACKAGE dml_load_csv_settings IS

  FUNCTION get_record(par_load_csv_settings_id IN load_csv_settings.load_csv_settings_id%TYPE)
    RETURN load_csv_settings%ROWTYPE;

  PROCEDURE insert_record
  (
    par_data_type        IN load_csv_settings.data_type%TYPE
   ,par_num              IN load_csv_settings.num%TYPE
   ,par_mandatory        IN load_csv_settings.mandatory%TYPE
   ,par_load_csv_list_id IN load_csv_settings.load_csv_list_id%TYPE
   ,par_column_name      IN load_csv_settings.column_name%TYPE
   ,par_data_length      IN load_csv_settings.data_length%TYPE DEFAULT NULL
   ,par_data_precision   IN load_csv_settings.data_precision%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record
  (
    par_data_type            IN load_csv_settings.data_type%TYPE
   ,par_num                  IN load_csv_settings.num%TYPE
   ,par_mandatory            IN load_csv_settings.mandatory%TYPE
   ,par_load_csv_list_id     IN load_csv_settings.load_csv_list_id%TYPE
   ,par_column_name          IN load_csv_settings.column_name%TYPE
   ,par_data_length          IN load_csv_settings.data_length%TYPE DEFAULT NULL
   ,par_data_precision       IN load_csv_settings.data_precision%TYPE DEFAULT NULL
   ,par_load_csv_settings_id OUT load_csv_settings.load_csv_settings_id%TYPE
  );

  PROCEDURE update_record(par_record IN load_csv_settings%ROWTYPE);

  PROCEDURE delete_record(par_load_csv_settings_id IN load_csv_settings.load_csv_settings_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_load_csv_settings IS

  FUNCTION get_record(par_load_csv_settings_id IN load_csv_settings.load_csv_settings_id%TYPE)
    RETURN load_csv_settings%ROWTYPE IS
    vr_record load_csv_settings%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM load_csv_settings
     WHERE load_csv_settings_id = par_load_csv_settings_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_data_type        IN load_csv_settings.data_type%TYPE
   ,par_num              IN load_csv_settings.num%TYPE
   ,par_mandatory        IN load_csv_settings.mandatory%TYPE
   ,par_load_csv_list_id IN load_csv_settings.load_csv_list_id%TYPE
   ,par_column_name      IN load_csv_settings.column_name%TYPE
   ,par_data_length      IN load_csv_settings.data_length%TYPE DEFAULT NULL
   ,par_data_precision   IN load_csv_settings.data_precision%TYPE DEFAULT NULL
  ) IS
    v_load_csv_settings_id load_csv_settings.load_csv_settings_id%TYPE;
  BEGIN
    insert_record(par_data_type            => par_data_type
                 ,par_num                  => par_num
                 ,par_mandatory            => par_mandatory
                 ,par_load_csv_list_id     => par_load_csv_list_id
                 ,par_column_name          => par_column_name
                 ,par_data_length          => par_data_length
                 ,par_data_precision       => par_data_precision
                 ,par_load_csv_settings_id => v_load_csv_settings_id);
  END insert_record;

  PROCEDURE insert_record
  (
    par_data_type            IN load_csv_settings.data_type%TYPE
   ,par_num                  IN load_csv_settings.num%TYPE
   ,par_mandatory            IN load_csv_settings.mandatory%TYPE
   ,par_load_csv_list_id     IN load_csv_settings.load_csv_list_id%TYPE
   ,par_column_name          IN load_csv_settings.column_name%TYPE
   ,par_data_length          IN load_csv_settings.data_length%TYPE DEFAULT NULL
   ,par_data_precision       IN load_csv_settings.data_precision%TYPE DEFAULT NULL
   ,par_load_csv_settings_id OUT load_csv_settings.load_csv_settings_id%TYPE
  ) IS
  BEGIN
    SELECT sq_load_csv_settings.nextval INTO par_load_csv_settings_id FROM dual;
    INSERT INTO load_csv_settings
      (load_csv_settings_id
      ,column_name
      ,mandatory
      ,data_length
      ,data_precision
      ,num
      ,load_csv_list_id
      ,data_type)
    VALUES
      (par_load_csv_settings_id
      ,par_column_name
      ,par_mandatory
      ,par_data_length
      ,par_data_precision
      ,par_num
      ,par_load_csv_list_id
      ,par_data_type);
  END insert_record;

  PROCEDURE update_record(par_record IN load_csv_settings%ROWTYPE) IS
  BEGIN
    UPDATE load_csv_settings
       SET load_csv_list_id = par_record.load_csv_list_id
          ,column_name      = par_record.column_name
          ,data_type        = par_record.data_type
          ,data_length      = par_record.data_length
          ,data_precision   = par_record.data_precision
          ,num              = par_record.num
          ,mandatory        = par_record.mandatory
     WHERE load_csv_settings_id = par_record.load_csv_settings_id;
  END update_record;

  PROCEDURE delete_record(par_load_csv_settings_id IN load_csv_settings.load_csv_settings_id%TYPE) IS
  BEGIN
    DELETE FROM load_csv_settings WHERE load_csv_settings_id = par_load_csv_settings_id;
  END delete_record;
END;
/
