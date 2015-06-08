CREATE OR REPLACE PACKAGE pkg_t_product_ext_system_dml IS

  FUNCTION get_record(par_t_product_ext_system_id IN t_product_ext_system.t_product_ext_system_id%TYPE)
    RETURN t_product_ext_system%ROWTYPE;

  PROCEDURE insert_record
  (
    par_product_id              IN t_product_ext_system.product_id%TYPE
   ,par_t_external_system_id    IN t_product_ext_system.t_external_system_id%TYPE
   ,par_t_product_ext_system_id OUT t_product_ext_system.t_product_ext_system_id%TYPE
  );
	
  PROCEDURE insert_record
  (
    par_product_id           IN t_product_ext_system.product_id%TYPE
   ,par_t_external_system_id IN t_product_ext_system.t_external_system_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_product_ext_system%ROWTYPE);

  PROCEDURE delete_record(par_t_product_ext_system_id IN t_product_ext_system.t_product_ext_system_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_t_product_ext_system_dml IS

  FUNCTION get_record(par_t_product_ext_system_id IN t_product_ext_system.t_product_ext_system_id%TYPE)
    RETURN t_product_ext_system%ROWTYPE IS
    vr_record t_product_ext_system%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM t_product_ext_system
     WHERE t_product_ext_system_id = par_t_product_ext_system_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_product_id              IN t_product_ext_system.product_id%TYPE
   ,par_t_external_system_id    IN t_product_ext_system.t_external_system_id%TYPE
   ,par_t_product_ext_system_id OUT t_product_ext_system.t_product_ext_system_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_product_ext_system.nextval INTO par_t_product_ext_system_id FROM dual;
    INSERT INTO t_product_ext_system
      (t_product_ext_system_id, t_external_system_id, product_id)
    VALUES
      (par_t_product_ext_system_id, par_t_external_system_id, par_product_id);
  EXCEPTION
    WHEN dup_val_on_index THEN
      raise_application_error(-20001
                             ,'Ќарушено ограничение уникальности');
  END insert_record;

  PROCEDURE insert_record
  (
    par_product_id           IN t_product_ext_system.product_id%TYPE
   ,par_t_external_system_id IN t_product_ext_system.t_external_system_id%TYPE
  ) IS
    v_t_product_ext_system_id t_product_ext_system.t_product_ext_system_id%TYPE;
  BEGIN
    insert_record(par_product_id              => par_product_id
                 ,par_t_external_system_id    => par_t_external_system_id
                 ,par_t_product_ext_system_id => v_t_product_ext_system_id);
  END insert_record;

  PROCEDURE update_record(par_record IN t_product_ext_system%ROWTYPE) IS
  BEGIN
    UPDATE t_product_ext_system
       SET product_id           = par_record.product_id
          ,t_external_system_id = par_record.t_external_system_id
     WHERE t_product_ext_system_id = par_record.t_product_ext_system_id;
  END update_record;

  PROCEDURE delete_record(par_t_product_ext_system_id IN t_product_ext_system.t_product_ext_system_id%TYPE) IS
  BEGIN
    DELETE FROM t_product_ext_system WHERE t_product_ext_system_id = par_t_product_ext_system_id;
  END delete_record;
END;
/
