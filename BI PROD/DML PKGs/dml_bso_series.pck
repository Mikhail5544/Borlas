CREATE OR REPLACE PACKAGE dml_bso_series IS

  FUNCTION get_id_by_series_num
  (
    par_series_num     IN bso_series.series_num%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_series.bso_series_id%TYPE;

  FUNCTION get_record(par_bso_series_id IN bso_series.bso_series_id%TYPE) RETURN bso_series%ROWTYPE;

  PROCEDURE insert_record
  (
    par_bso_type_id         IN bso_series.bso_type_id%TYPE
   ,par_is_default          IN bso_series.is_default%TYPE DEFAULT 0
   ,par_series_name         IN bso_series.series_name%TYPE DEFAULT NULL
   ,par_chars_in_num        IN bso_series.chars_in_num%TYPE DEFAULT NULL
   ,par_series_num          IN bso_series.series_num%TYPE DEFAULT NULL
   ,par_t_product_conds_id  IN bso_series.t_product_conds_id%TYPE DEFAULT NULL
   ,par_proposal_valid_days IN bso_series.proposal_valid_days%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record
  (
    par_bso_type_id         IN bso_series.bso_type_id%TYPE
   ,par_is_default          IN bso_series.is_default%TYPE DEFAULT 0
   ,par_series_name         IN bso_series.series_name%TYPE DEFAULT NULL
   ,par_chars_in_num        IN bso_series.chars_in_num%TYPE DEFAULT NULL
   ,par_series_num          IN bso_series.series_num%TYPE DEFAULT NULL
   ,par_t_product_conds_id  IN bso_series.t_product_conds_id%TYPE DEFAULT NULL
   ,par_proposal_valid_days IN bso_series.proposal_valid_days%TYPE DEFAULT NULL
   ,par_bso_series_id       OUT bso_series.bso_series_id%TYPE
  );

  PROCEDURE update_record(par_record IN bso_series%ROWTYPE);

  PROCEDURE delete_record(par_bso_series_id IN bso_series.bso_series_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_bso_series IS

  FUNCTION get_id_by_series_num
  (
    par_series_num     IN bso_series.series_num%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN bso_series.bso_series_id%TYPE IS
    v_id bso_series.bso_series_id%TYPE;
  BEGIN
    BEGIN
      SELECT bso_series_id INTO v_id FROM bso_series WHERE series_num = par_series_num;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Серия БСО" по значению поля "Числовая серия": ' ||
                   par_series_num);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_series_num;

  FUNCTION get_record(par_bso_series_id IN bso_series.bso_series_id%TYPE) RETURN bso_series%ROWTYPE IS
    vr_record bso_series%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM bso_series WHERE bso_series_id = par_bso_series_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_bso_type_id         IN bso_series.bso_type_id%TYPE
   ,par_is_default          IN bso_series.is_default%TYPE DEFAULT 0
   ,par_series_name         IN bso_series.series_name%TYPE DEFAULT NULL
   ,par_chars_in_num        IN bso_series.chars_in_num%TYPE DEFAULT NULL
   ,par_series_num          IN bso_series.series_num%TYPE DEFAULT NULL
   ,par_t_product_conds_id  IN bso_series.t_product_conds_id%TYPE DEFAULT NULL
   ,par_proposal_valid_days IN bso_series.proposal_valid_days%TYPE DEFAULT NULL
  ) IS
    v_id bso_series.bso_series_id%TYPE;
  BEGIN
    insert_record(par_bso_type_id         => par_bso_type_id
                 ,par_is_default          => par_is_default
                 ,par_series_name         => par_series_name
                 ,par_chars_in_num        => par_chars_in_num
                 ,par_series_num          => par_series_num
                 ,par_t_product_conds_id  => par_t_product_conds_id
                 ,par_proposal_valid_days => par_proposal_valid_days
                 ,par_bso_series_id       => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_bso_type_id         IN bso_series.bso_type_id%TYPE
   ,par_is_default          IN bso_series.is_default%TYPE DEFAULT 0
   ,par_series_name         IN bso_series.series_name%TYPE DEFAULT NULL
   ,par_chars_in_num        IN bso_series.chars_in_num%TYPE DEFAULT NULL
   ,par_series_num          IN bso_series.series_num%TYPE DEFAULT NULL
   ,par_t_product_conds_id  IN bso_series.t_product_conds_id%TYPE DEFAULT NULL
   ,par_proposal_valid_days IN bso_series.proposal_valid_days%TYPE DEFAULT NULL
   ,par_bso_series_id       OUT bso_series.bso_series_id%TYPE
  ) IS
  BEGIN
    SELECT sq_bso_series.nextval INTO par_bso_series_id FROM dual;
    INSERT INTO bso_series
      (bso_series_id
      ,bso_type_id
      ,t_product_conds_id
      ,is_default
      ,chars_in_num
      ,series_num
      ,proposal_valid_days
      ,series_name)
    VALUES
      (par_bso_series_id
      ,par_bso_type_id
      ,par_t_product_conds_id
      ,par_is_default
      ,par_chars_in_num
      ,par_series_num
      ,par_proposal_valid_days
      ,par_series_name);
  END insert_record;

  PROCEDURE update_record(par_record IN bso_series%ROWTYPE) IS
  BEGIN
    UPDATE bso_series
       SET proposal_valid_days = par_record.proposal_valid_days
          ,bso_type_id         = par_record.bso_type_id
          ,series_name         = par_record.series_name
          ,is_default          = par_record.is_default
          ,chars_in_num        = par_record.chars_in_num
          ,series_num          = par_record.series_num
          ,t_product_conds_id  = par_record.t_product_conds_id
     WHERE bso_series_id = par_record.bso_series_id;
  END update_record;

  PROCEDURE delete_record(par_bso_series_id IN bso_series.bso_series_id%TYPE) IS
  BEGIN
    DELETE FROM bso_series WHERE bso_series_id = par_bso_series_id;
  END delete_record;
END;
/
