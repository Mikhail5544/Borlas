CREATE OR REPLACE PACKAGE dml_rate_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN rate_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN rate_type.rate_type_id%TYPE;

  FUNCTION get_record(par_rate_type_id IN rate_type.rate_type_id%TYPE) RETURN rate_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name         IN rate_type.name%TYPE
   ,par_brief        IN rate_type.brief%TYPE
   ,par_is_default   IN rate_type.is_default%TYPE DEFAULT 0
   ,par_base_fund_id IN rate_type.base_fund_id%TYPE DEFAULT NULL
   ,par_exchange_id  IN rate_type.exchange_id%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record(par_record IN OUT rate_type%ROWTYPE);

  PROCEDURE insert_record
  (
    par_name         IN rate_type.name%TYPE
   ,par_brief        IN rate_type.brief%TYPE
   ,par_is_default   IN rate_type.is_default%TYPE DEFAULT 0
   ,par_base_fund_id IN rate_type.base_fund_id%TYPE DEFAULT NULL
   ,par_exchange_id  IN rate_type.exchange_id%TYPE DEFAULT NULL
   ,par_rate_type_id OUT rate_type.rate_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN rate_type%ROWTYPE);

  PROCEDURE delete_record(par_rate_type_id IN rate_type.rate_type_id%TYPE);
END dml_rate_type;
/
CREATE OR REPLACE PACKAGE BODY dml_rate_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN rate_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN rate_type.rate_type_id%TYPE IS
    v_id rate_type.rate_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT rate_type_id INTO v_id FROM rate_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Тип курса" по значению поля "Сокращение типа курса": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_rate_type_id IN rate_type.rate_type_id%TYPE) RETURN rate_type%ROWTYPE IS
    vr_record rate_type%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM rate_type WHERE rate_type_id = par_rate_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name         IN rate_type.name%TYPE
   ,par_brief        IN rate_type.brief%TYPE
   ,par_is_default   IN rate_type.is_default%TYPE DEFAULT 0
   ,par_base_fund_id IN rate_type.base_fund_id%TYPE DEFAULT NULL
   ,par_exchange_id  IN rate_type.exchange_id%TYPE DEFAULT NULL
  ) IS
    v_id rate_type.rate_type_id%TYPE;
  BEGIN
    insert_record(par_name         => par_name
                 ,par_brief        => par_brief
                 ,par_is_default   => par_is_default
                 ,par_base_fund_id => par_base_fund_id
                 ,par_exchange_id  => par_exchange_id
                 ,par_rate_type_id => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT rate_type%ROWTYPE) IS
  BEGIN
    insert_record(par_name         => par_record.name
                 ,par_brief        => par_record.brief
                 ,par_is_default   => par_record.is_default
                 ,par_base_fund_id => par_record.base_fund_id
                 ,par_exchange_id  => par_record.exchange_id
                 ,par_rate_type_id => par_record.rate_type_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name         IN rate_type.name%TYPE
   ,par_brief        IN rate_type.brief%TYPE
   ,par_is_default   IN rate_type.is_default%TYPE DEFAULT 0
   ,par_base_fund_id IN rate_type.base_fund_id%TYPE DEFAULT NULL
   ,par_exchange_id  IN rate_type.exchange_id%TYPE DEFAULT NULL
   ,par_rate_type_id OUT rate_type.rate_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_rate_type.nextval INTO par_rate_type_id FROM dual;
    INSERT INTO rate_type
      (rate_type_id, exchange_id, is_default, base_fund_id, NAME, brief)
    VALUES
      (par_rate_type_id, par_exchange_id, par_is_default, par_base_fund_id, par_name, par_brief);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record(par_record IN rate_type%ROWTYPE) IS
  BEGIN
    UPDATE rate_type
       SET NAME         = par_record.name
          ,brief        = par_record.brief
          ,is_default   = par_record.is_default
          ,base_fund_id = par_record.base_fund_id
          ,exchange_id  = par_record.exchange_id
     WHERE rate_type_id = par_record.rate_type_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record(par_rate_type_id IN rate_type.rate_type_id%TYPE) IS
  BEGIN
    DELETE FROM rate_type WHERE rate_type_id = par_rate_type_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;
END dml_rate_type;
/
