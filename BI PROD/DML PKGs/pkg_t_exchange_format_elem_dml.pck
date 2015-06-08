CREATE OR REPLACE PACKAGE pkg_t_exchange_format_elem_dml IS

  FUNCTION get_record(par_t_exchange_format_elem_id IN t_exchange_format_elem.t_exchange_format_elem_id%TYPE)
    RETURN t_exchange_format_elem%ROWTYPE;
  PROCEDURE insert_record
  (
    par_t_exchange_format_id      IN t_exchange_format_elem.t_exchange_format_id%TYPE
   ,par_name                      IN t_exchange_format_elem.name%TYPE
   ,par_is_mandatory              IN t_exchange_format_elem.is_mandatory%TYPE DEFAULT 0
   ,par_description               IN t_exchange_format_elem.description%TYPE DEFAULT NULL
   ,par_parent_id                 IN t_exchange_format_elem.parent_id%TYPE DEFAULT NULL
   ,par_t_exchange_format_elem_id OUT t_exchange_format_elem.t_exchange_format_elem_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_exchange_format_elem%ROWTYPE);
  PROCEDURE delete_record(par_t_exchange_format_elem_id IN t_exchange_format_elem.t_exchange_format_elem_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_t_exchange_format_elem_dml IS

  FUNCTION get_record(par_t_exchange_format_elem_id IN t_exchange_format_elem.t_exchange_format_elem_id%TYPE)
    RETURN t_exchange_format_elem%ROWTYPE IS
    vr_record t_exchange_format_elem%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM t_exchange_format_elem
     WHERE t_exchange_format_elem_id = par_t_exchange_format_elem_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;
  PROCEDURE insert_record
  (
    par_t_exchange_format_id      IN t_exchange_format_elem.t_exchange_format_id%TYPE
   ,par_name                      IN t_exchange_format_elem.name%TYPE
   ,par_is_mandatory              IN t_exchange_format_elem.is_mandatory%TYPE DEFAULT 0
   ,par_description               IN t_exchange_format_elem.description%TYPE DEFAULT NULL
   ,par_parent_id                 IN t_exchange_format_elem.parent_id%TYPE DEFAULT NULL
   ,par_t_exchange_format_elem_id OUT t_exchange_format_elem.t_exchange_format_elem_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_exchange_format_elem.nextval INTO par_t_exchange_format_elem_id FROM dual;
    INSERT INTO t_exchange_format_elem
      (t_exchange_format_elem_id, description, NAME, is_mandatory, parent_id, t_exchange_format_id)
    VALUES
      (par_t_exchange_format_elem_id
      ,par_description
      ,par_name
      ,par_is_mandatory
      ,par_parent_id
      ,par_t_exchange_format_id);
  END insert_record;
  PROCEDURE update_record(par_record IN t_exchange_format_elem%ROWTYPE) IS
  BEGIN
    UPDATE t_exchange_format_elem
       SET parent_id            = par_record.parent_id
          ,t_exchange_format_id = par_record.t_exchange_format_id
          ,NAME                 = par_record.name
          ,is_mandatory         = par_record.is_mandatory
          ,description          = par_record.description
     WHERE t_exchange_format_elem_id = par_record.t_exchange_format_elem_id;
  END update_record;
  PROCEDURE delete_record(par_t_exchange_format_elem_id IN t_exchange_format_elem.t_exchange_format_elem_id%TYPE) IS
  BEGIN
    DELETE FROM t_exchange_format_elem
     WHERE t_exchange_format_elem_id = par_t_exchange_format_elem_id;
  END delete_record;
END;
/
