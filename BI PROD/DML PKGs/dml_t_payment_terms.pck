CREATE OR REPLACE PACKAGE dml_t_payment_terms IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_payment_terms.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_payment_terms.id%TYPE;

  FUNCTION get_record(par_id IN t_payment_terms.id%TYPE) RETURN t_payment_terms%ROWTYPE;

  PROCEDURE insert_record
  (
    par_number_of_payments   IN t_payment_terms.number_of_payments%TYPE
   ,par_description          IN t_payment_terms.description%TYPE
   ,par_collection_method_id IN t_payment_terms.collection_method_id%TYPE
   ,par_brief                IN t_payment_terms.brief%TYPE
   ,par_is_default           IN t_payment_terms.is_default%TYPE DEFAULT 0
   ,par_is_periodical        IN t_payment_terms.is_periodical%TYPE DEFAULT 1
   ,par_percentage           IN t_payment_terms.percentage%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record(par_record IN OUT t_payment_terms%ROWTYPE);

  PROCEDURE insert_record
  (
    par_number_of_payments   IN t_payment_terms.number_of_payments%TYPE
   ,par_description          IN t_payment_terms.description%TYPE
   ,par_collection_method_id IN t_payment_terms.collection_method_id%TYPE
   ,par_brief                IN t_payment_terms.brief%TYPE
   ,par_is_default           IN t_payment_terms.is_default%TYPE DEFAULT 0
   ,par_is_periodical        IN t_payment_terms.is_periodical%TYPE DEFAULT 1
   ,par_percentage           IN t_payment_terms.percentage%TYPE DEFAULT NULL
   ,par_id                   OUT t_payment_terms.id%TYPE
  );

  PROCEDURE update_record(par_record IN t_payment_terms%ROWTYPE);

  PROCEDURE delete_record(par_id IN t_payment_terms.id%TYPE);
END dml_t_payment_terms;
/
CREATE OR REPLACE PACKAGE BODY dml_t_payment_terms IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_payment_terms.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_payment_terms.id%TYPE IS
    v_id t_payment_terms.id%TYPE;
  BEGIN
    BEGIN
      SELECT id INTO v_id FROM t_payment_terms WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Условие рассрочки платежа" по значению поля "Краткий идентификатор вида рассрочки": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_id IN t_payment_terms.id%TYPE) RETURN t_payment_terms%ROWTYPE IS
    vr_record t_payment_terms%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_payment_terms WHERE id = par_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_number_of_payments   IN t_payment_terms.number_of_payments%TYPE
   ,par_description          IN t_payment_terms.description%TYPE
   ,par_collection_method_id IN t_payment_terms.collection_method_id%TYPE
   ,par_brief                IN t_payment_terms.brief%TYPE
   ,par_is_default           IN t_payment_terms.is_default%TYPE DEFAULT 0
   ,par_is_periodical        IN t_payment_terms.is_periodical%TYPE DEFAULT 1
   ,par_percentage           IN t_payment_terms.percentage%TYPE DEFAULT NULL
  ) IS
    v_id t_payment_terms.id%TYPE;
  BEGIN
    insert_record(par_number_of_payments   => par_number_of_payments
                 ,par_description          => par_description
                 ,par_collection_method_id => par_collection_method_id
                 ,par_brief                => par_brief
                 ,par_is_default           => par_is_default
                 ,par_is_periodical        => par_is_periodical
                 ,par_percentage           => par_percentage
                 ,par_id                   => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT t_payment_terms%ROWTYPE) IS
  BEGIN
    insert_record(par_number_of_payments   => par_record.number_of_payments
                 ,par_description          => par_record.description
                 ,par_collection_method_id => par_record.collection_method_id
                 ,par_brief                => par_record.brief
                 ,par_is_default           => par_record.is_default
                 ,par_is_periodical        => par_record.is_periodical
                 ,par_percentage           => par_record.percentage
                 ,par_id                   => par_record.id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_number_of_payments   IN t_payment_terms.number_of_payments%TYPE
   ,par_description          IN t_payment_terms.description%TYPE
   ,par_collection_method_id IN t_payment_terms.collection_method_id%TYPE
   ,par_brief                IN t_payment_terms.brief%TYPE
   ,par_is_default           IN t_payment_terms.is_default%TYPE DEFAULT 0
   ,par_is_periodical        IN t_payment_terms.is_periodical%TYPE DEFAULT 1
   ,par_percentage           IN t_payment_terms.percentage%TYPE DEFAULT NULL
   ,par_id                   OUT t_payment_terms.id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_payment_terms.nextval INTO par_id FROM dual;
    INSERT INTO t_payment_terms
      (id
      ,description
      ,brief
      ,collection_method_id
      ,percentage
      ,is_periodical
      ,number_of_payments
      ,is_default)
    VALUES
      (par_id
      ,par_description
      ,par_brief
      ,par_collection_method_id
      ,par_percentage
      ,par_is_periodical
      ,par_number_of_payments
      ,par_is_default);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record(par_record IN t_payment_terms%ROWTYPE) IS
  BEGIN
    UPDATE t_payment_terms
       SET number_of_payments   = par_record.number_of_payments
          ,description          = par_record.description
          ,is_default           = par_record.is_default
          ,collection_method_id = par_record.collection_method_id
          ,percentage           = par_record.percentage
          ,is_periodical        = par_record.is_periodical
          ,brief                = par_record.brief
     WHERE id = par_record.id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record(par_id IN t_payment_terms.id%TYPE) IS
  BEGIN
    DELETE FROM t_payment_terms WHERE id = par_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;
END dml_t_payment_terms;
/
