CREATE OR REPLACE PACKAGE dml_t_prod_coef_tariff IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_prod_coef_tariff.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE;

  FUNCTION get_record(par_t_prod_coef_tariff_id IN t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE)
    RETURN t_prod_coef_tariff%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name  IN t_prod_coef_tariff.name%TYPE
   ,par_brief IN t_prod_coef_tariff.brief%TYPE
  );

  PROCEDURE insert_record
  (
    par_name                  IN t_prod_coef_tariff.name%TYPE
   ,par_brief                 IN t_prod_coef_tariff.brief%TYPE
   ,par_t_prod_coef_tariff_id OUT t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_prod_coef_tariff%ROWTYPE);

  PROCEDURE delete_record(par_t_prod_coef_tariff_id IN t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_prod_coef_tariff IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_prod_coef_tariff.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE IS
    v_id t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_prod_coef_tariff_id INTO v_id FROM t_prod_coef_tariff WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Назначение функции распределения" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_t_prod_coef_tariff_id IN t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE)
    RETURN t_prod_coef_tariff%ROWTYPE IS
    vr_record t_prod_coef_tariff%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM t_prod_coef_tariff
     WHERE t_prod_coef_tariff_id = par_t_prod_coef_tariff_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name  IN t_prod_coef_tariff.name%TYPE
   ,par_brief IN t_prod_coef_tariff.brief%TYPE
  ) IS
    v_id t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE;
  BEGIN
    insert_record(par_name => par_name, par_brief => par_brief, par_t_prod_coef_tariff_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                  IN t_prod_coef_tariff.name%TYPE
   ,par_brief                 IN t_prod_coef_tariff.brief%TYPE
   ,par_t_prod_coef_tariff_id OUT t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_prod_coef_tariff.nextval INTO par_t_prod_coef_tariff_id FROM dual;
    INSERT INTO t_prod_coef_tariff
      (t_prod_coef_tariff_id, brief, NAME)
    VALUES
      (par_t_prod_coef_tariff_id, par_brief, par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN t_prod_coef_tariff%ROWTYPE) IS
  BEGIN
    UPDATE t_prod_coef_tariff
       SET NAME  = par_record.name
          ,brief = par_record.brief
     WHERE t_prod_coef_tariff_id = par_record.t_prod_coef_tariff_id;
  END update_record;

  PROCEDURE delete_record(par_t_prod_coef_tariff_id IN t_prod_coef_tariff.t_prod_coef_tariff_id%TYPE) IS
  BEGIN
    DELETE FROM t_prod_coef_tariff WHERE t_prod_coef_tariff_id = par_t_prod_coef_tariff_id;
  END delete_record;
END;
/
