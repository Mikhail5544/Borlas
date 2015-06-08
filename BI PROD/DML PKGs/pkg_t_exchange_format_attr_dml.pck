CREATE OR REPLACE PACKAGE pkg_t_exchange_format_attr_dml IS

  FUNCTION get_record(par_t_exchange_format_attr_id IN t_exchange_format_attr.t_exchange_format_attr_id%TYPE)
    RETURN t_exchange_format_attr%ROWTYPE;
  PROCEDURE insert_record
  (
    par_name                      IN t_exchange_format_attr.name%TYPE
   ,par_t_exchange_format_elem_id IN t_exchange_format_attr.t_exchange_format_elem_id%TYPE
   ,par_is_mandatory              IN t_exchange_format_attr.is_mandatory%TYPE DEFAULT 0
   ,par_description               IN t_exchange_format_attr.description%TYPE DEFAULT NULL
   ,par_t_exchange_format_attr_id OUT t_exchange_format_attr.t_exchange_format_attr_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_exchange_format_attr%ROWTYPE);
  PROCEDURE delete_record(par_t_exchange_format_attr_id IN t_exchange_format_attr.t_exchange_format_attr_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_t_exchange_format_attr_dml IS

  FUNCTION get_record(par_t_exchange_format_attr_id IN t_exchange_format_attr.t_exchange_format_attr_id%TYPE)
    RETURN t_exchange_format_attr%ROWTYPE IS
    vr_record t_exchange_format_attr%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM t_exchange_format_attr
     WHERE t_exchange_format_attr_id = par_t_exchange_format_attr_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;
  PROCEDURE insert_record
  (
    par_name                      IN t_exchange_format_attr.name%TYPE
   ,par_t_exchange_format_elem_id IN t_exchange_format_attr.t_exchange_format_elem_id%TYPE
   ,par_is_mandatory              IN t_exchange_format_attr.is_mandatory%TYPE DEFAULT 0
   ,par_description               IN t_exchange_format_attr.description%TYPE DEFAULT NULL
   ,par_t_exchange_format_attr_id OUT t_exchange_format_attr.t_exchange_format_attr_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_exchange_format_attr.nextval INTO par_t_exchange_format_attr_id FROM dual;
    INSERT INTO t_exchange_format_attr
      (t_exchange_format_attr_id, description, is_mandatory, t_exchange_format_elem_id, NAME)
    VALUES
      (par_t_exchange_format_attr_id
      ,par_description
      ,par_is_mandatory
      ,par_t_exchange_format_elem_id
      ,par_name);
  END insert_record;
  PROCEDURE update_record(par_record IN t_exchange_format_attr%ROWTYPE) IS
  BEGIN
    UPDATE t_exchange_format_attr
       SET t_exchange_format_elem_id = par_record.t_exchange_format_elem_id
          ,NAME                      = par_record.name
          ,is_mandatory              = par_record.is_mandatory
          ,description               = par_record.description
     WHERE t_exchange_format_attr_id = par_record.t_exchange_format_attr_id;
  END update_record;
  PROCEDURE delete_record(par_t_exchange_format_attr_id IN t_exchange_format_attr.t_exchange_format_attr_id%TYPE) IS
  BEGIN
    DELETE FROM t_exchange_format_attr
     WHERE t_exchange_format_attr_id = par_t_exchange_format_attr_id;
  END delete_record;
END;
/
