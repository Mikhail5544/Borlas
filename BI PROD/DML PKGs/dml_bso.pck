CREATE OR REPLACE PACKAGE dml_bso IS

  FUNCTION get_entity_id RETURN entity.ent_id%TYPE;

  FUNCTION get_record(par_bso_id IN bso.bso_id%TYPE) RETURN bso%ROWTYPE;

  PROCEDURE insert_record
  (
    par_bso_series_id IN bso.bso_series_id%TYPE
   ,par_num           IN bso.num%TYPE
   ,par_bso_hist_id   IN bso.bso_hist_id%TYPE DEFAULT NULL
   ,par_pol_header_id IN bso.pol_header_id%TYPE DEFAULT NULL
   ,par_policy_id     IN bso.policy_id%TYPE DEFAULT NULL
   ,par_document_id   IN bso.document_id%TYPE DEFAULT NULL
   ,par_hist_type_id  IN bso.hist_type_id%TYPE DEFAULT NULL
   ,par_contact_id    IN bso.contact_id%TYPE DEFAULT NULL
   ,par_is_pol_num    IN bso.is_pol_num%TYPE DEFAULT 0
  );

  PROCEDURE insert_record(par_record IN OUT bso%ROWTYPE);

  PROCEDURE insert_record
  (
    par_bso_series_id IN bso.bso_series_id%TYPE
   ,par_num           IN bso.num%TYPE
   ,par_bso_hist_id   IN bso.bso_hist_id%TYPE DEFAULT NULL
   ,par_pol_header_id IN bso.pol_header_id%TYPE DEFAULT NULL
   ,par_policy_id     IN bso.policy_id%TYPE DEFAULT NULL
   ,par_document_id   IN bso.document_id%TYPE DEFAULT NULL
   ,par_hist_type_id  IN bso.hist_type_id%TYPE DEFAULT NULL
   ,par_contact_id    IN bso.contact_id%TYPE DEFAULT NULL
   ,par_is_pol_num    IN bso.is_pol_num%TYPE DEFAULT 0
   ,par_bso_id        OUT bso.bso_id%TYPE
  );

  PROCEDURE update_record(par_record IN bso%ROWTYPE);

  PROCEDURE delete_record(par_bso_id IN bso.bso_id%TYPE);

  PROCEDURE lock_record(par_bso_id IN bso.bso_id%TYPE);
END dml_bso;
/
CREATE OR REPLACE PACKAGE BODY dml_bso IS

  gc_entity_id CONSTANT entity.ent_id%TYPE := ent.id_by_brief('BSO');

  FUNCTION get_entity_id RETURN entity.ent_id%TYPE IS
  BEGIN
    RETURN gc_entity_id;
  END get_entity_id;

  FUNCTION get_record(par_bso_id IN bso.bso_id%TYPE) RETURN bso%ROWTYPE IS
    vr_record bso%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM bso WHERE bso_id = par_bso_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_bso_series_id IN bso.bso_series_id%TYPE
   ,par_num           IN bso.num%TYPE
   ,par_bso_hist_id   IN bso.bso_hist_id%TYPE DEFAULT NULL
   ,par_pol_header_id IN bso.pol_header_id%TYPE DEFAULT NULL
   ,par_policy_id     IN bso.policy_id%TYPE DEFAULT NULL
   ,par_document_id   IN bso.document_id%TYPE DEFAULT NULL
   ,par_hist_type_id  IN bso.hist_type_id%TYPE DEFAULT NULL
   ,par_contact_id    IN bso.contact_id%TYPE DEFAULT NULL
   ,par_is_pol_num    IN bso.is_pol_num%TYPE DEFAULT 0
  ) IS
    v_id bso.bso_id%TYPE;
  BEGIN
    insert_record(par_bso_series_id => par_bso_series_id
                 ,par_num           => par_num
                 ,par_bso_hist_id   => par_bso_hist_id
                 ,par_pol_header_id => par_pol_header_id
                 ,par_policy_id     => par_policy_id
                 ,par_document_id   => par_document_id
                 ,par_hist_type_id  => par_hist_type_id
                 ,par_contact_id    => par_contact_id
                 ,par_is_pol_num    => par_is_pol_num
                 ,par_bso_id        => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT bso%ROWTYPE) IS
  BEGIN
    insert_record(par_bso_series_id => par_record.bso_series_id
                 ,par_num           => par_record.num
                 ,par_bso_hist_id   => par_record.bso_hist_id
                 ,par_pol_header_id => par_record.pol_header_id
                 ,par_policy_id     => par_record.policy_id
                 ,par_document_id   => par_record.document_id
                 ,par_hist_type_id  => par_record.hist_type_id
                 ,par_contact_id    => par_record.contact_id
                 ,par_is_pol_num    => par_record.is_pol_num
                 ,par_bso_id        => par_record.bso_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_bso_series_id IN bso.bso_series_id%TYPE
   ,par_num           IN bso.num%TYPE
   ,par_bso_hist_id   IN bso.bso_hist_id%TYPE DEFAULT NULL
   ,par_pol_header_id IN bso.pol_header_id%TYPE DEFAULT NULL
   ,par_policy_id     IN bso.policy_id%TYPE DEFAULT NULL
   ,par_document_id   IN bso.document_id%TYPE DEFAULT NULL
   ,par_hist_type_id  IN bso.hist_type_id%TYPE DEFAULT NULL
   ,par_contact_id    IN bso.contact_id%TYPE DEFAULT NULL
   ,par_is_pol_num    IN bso.is_pol_num%TYPE DEFAULT 0
   ,par_bso_id        OUT bso.bso_id%TYPE
  ) IS
  BEGIN
    SELECT sq_bso.nextval INTO par_bso_id FROM dual;
    INSERT INTO bso
      (bso_id
      ,contact_id
      ,bso_series_id
      ,document_id
      ,bso_hist_id
      ,pol_header_id
      ,is_pol_num
      ,policy_id
      ,hist_type_id
      ,num)
    VALUES
      (par_bso_id
      ,par_contact_id
      ,par_bso_series_id
      ,par_document_id
      ,par_bso_hist_id
      ,par_pol_header_id
      ,par_is_pol_num
      ,par_policy_id
      ,par_hist_type_id
      ,par_num);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record(par_record IN bso%ROWTYPE) IS
  BEGIN
    UPDATE bso
       SET hist_type_id  = par_record.hist_type_id
          ,contact_id    = par_record.contact_id
          ,bso_series_id = par_record.bso_series_id
          ,num           = par_record.num
          ,bso_hist_id   = par_record.bso_hist_id
          ,pol_header_id = par_record.pol_header_id
          ,is_pol_num    = par_record.is_pol_num
          ,policy_id     = par_record.policy_id
          ,document_id   = par_record.document_id
     WHERE bso_id = par_record.bso_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record(par_bso_id IN bso.bso_id%TYPE) IS
  BEGIN
    DELETE FROM bso WHERE bso_id = par_bso_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;

  PROCEDURE lock_record(par_bso_id IN bso.bso_id%TYPE) IS
    v_dummy bso.bso_id%TYPE;
  BEGIN
  
    assert(par_bso_id IS NULL
          ,'Запись для блокировки должна быть указана');
  
    SELECT bso_id INTO v_dummy FROM bso WHERE bso_id = par_bso_id FOR UPDATE NOWAIT;
  EXCEPTION
    WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
      ex.raise('Не удалось заблонировать запись в таблице "БСО "');
    WHEN no_data_found THEN
      ex.raise('Не удалось найти запись для блокировки в таблице "БСО "');
    WHEN OTHERS THEN
      ex.raise;
  END lock_record;
END dml_bso;
/
