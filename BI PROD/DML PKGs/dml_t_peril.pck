CREATE OR REPLACE PACKAGE dml_t_peril IS

  FUNCTION get_record(par_id IN t_peril.id%TYPE) RETURN t_peril%ROWTYPE;
  PROCEDURE insert_record
  (
    par_description        IN t_peril.description%TYPE
   ,par_is_default         IN t_peril.is_default%TYPE DEFAULT 0
   ,par_is_dms_code        IN t_peril.is_dms_code%TYPE DEFAULT 0
   ,par_insurance_group_id IN t_peril.insurance_group_id%TYPE DEFAULT NULL
   ,par_descr_eng          IN t_peril.descr_eng%TYPE DEFAULT NULL
   ,par_brief              IN t_peril.brief%TYPE DEFAULT NULL
   ,par_sort_order         IN t_peril.sort_order%TYPE DEFAULT NULL
  );
  PROCEDURE insert_record
  (
    par_description        IN t_peril.description%TYPE
   ,par_is_default         IN t_peril.is_default%TYPE DEFAULT 0
   ,par_is_dms_code        IN t_peril.is_dms_code%TYPE DEFAULT 0
   ,par_insurance_group_id IN t_peril.insurance_group_id%TYPE DEFAULT NULL
   ,par_descr_eng          IN t_peril.descr_eng%TYPE DEFAULT NULL
   ,par_brief              IN t_peril.brief%TYPE DEFAULT NULL
   ,par_sort_order         IN t_peril.sort_order%TYPE DEFAULT NULL
   ,par_id                 OUT t_peril.id%TYPE
  );
  PROCEDURE update_record(par_record IN t_peril%ROWTYPE);
  PROCEDURE delete_record(par_id IN t_peril.id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_peril IS

  FUNCTION get_record(par_id IN t_peril.id%TYPE) RETURN t_peril%ROWTYPE IS
    vr_record t_peril%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_peril WHERE id = par_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_description        IN t_peril.description%TYPE
   ,par_is_default         IN t_peril.is_default%TYPE DEFAULT 0
   ,par_is_dms_code        IN t_peril.is_dms_code%TYPE DEFAULT 0
   ,par_insurance_group_id IN t_peril.insurance_group_id%TYPE DEFAULT NULL
   ,par_descr_eng          IN t_peril.descr_eng%TYPE DEFAULT NULL
   ,par_brief              IN t_peril.brief%TYPE DEFAULT NULL
   ,par_sort_order         IN t_peril.sort_order%TYPE DEFAULT NULL
  ) IS
    v_id t_peril.id%TYPE;
  BEGIN
    insert_record(par_description        => par_description
                 ,par_is_default         => par_is_default
                 ,par_is_dms_code        => par_is_dms_code
                 ,par_insurance_group_id => par_insurance_group_id
                 ,par_descr_eng          => par_descr_eng
                 ,par_brief              => par_brief
                 ,par_sort_order         => par_sort_order
                 ,par_id                 => v_id);
  END insert_record;

  PROCEDURE insert_record
  (
    par_description        IN t_peril.description%TYPE
   ,par_is_default         IN t_peril.is_default%TYPE DEFAULT 0
   ,par_is_dms_code        IN t_peril.is_dms_code%TYPE DEFAULT 0
   ,par_insurance_group_id IN t_peril.insurance_group_id%TYPE DEFAULT NULL
   ,par_descr_eng          IN t_peril.descr_eng%TYPE DEFAULT NULL
   ,par_brief              IN t_peril.brief%TYPE DEFAULT NULL
   ,par_sort_order         IN t_peril.sort_order%TYPE DEFAULT NULL
   ,par_id                 OUT t_peril.id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_peril.nextval INTO par_id FROM dual;
    INSERT INTO t_peril
      (id, is_default, sort_order, descr_eng, is_dms_code, brief, description, insurance_group_id)
    VALUES
      (par_id
      ,par_is_default
      ,par_sort_order
      ,par_descr_eng
      ,par_is_dms_code
      ,par_brief
      ,par_description
      ,par_insurance_group_id);
  END insert_record;

  PROCEDURE update_record(par_record IN t_peril%ROWTYPE) IS
  BEGIN
    UPDATE t_peril
       SET description        = par_record.description
          ,is_default         = par_record.is_default
          ,insurance_group_id = par_record.insurance_group_id
          ,descr_eng          = par_record.descr_eng
          ,is_dms_code        = par_record.is_dms_code
          ,brief              = par_record.brief
          ,sort_order         = par_record.sort_order
     WHERE id = par_record.id;
  END update_record;

  PROCEDURE delete_record(par_id IN t_peril.id%TYPE) IS
  BEGIN
    DELETE FROM t_peril WHERE id = par_id;
  END delete_record;
END;
/
