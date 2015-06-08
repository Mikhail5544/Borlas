CREATE OR REPLACE PACKAGE dml_bso_hist IS

  FUNCTION get_record(par_bso_hist_id IN bso_hist.bso_hist_id%TYPE) RETURN bso_hist%ROWTYPE;

  PROCEDURE insert_record
  (
    par_bso_id            IN bso_hist.bso_id%TYPE
   ,par_hist_date         IN bso_hist.hist_date%TYPE
   ,par_hist_type_id      IN bso_hist.hist_type_id%TYPE
   ,par_bso_doc_cont_id   IN bso_hist.bso_doc_cont_id%TYPE
   ,par_num               IN bso_hist.num%TYPE DEFAULT 1
   ,par_contact_id        IN bso_hist.contact_id%TYPE DEFAULT NULL
   ,par_department_id     IN bso_hist.department_id%TYPE DEFAULT NULL
   ,par_bso_notes_type_id IN bso_hist.bso_notes_type_id%TYPE DEFAULT NULL
   ,par_reg_date          IN bso_hist.reg_date%TYPE DEFAULT SYSDATE
  );

  PROCEDURE insert_record
  (
    par_bso_id            IN bso_hist.bso_id%TYPE
   ,par_hist_date         IN bso_hist.hist_date%TYPE
   ,par_hist_type_id      IN bso_hist.hist_type_id%TYPE
   ,par_bso_doc_cont_id   IN bso_hist.bso_doc_cont_id%TYPE
   ,par_num               IN bso_hist.num%TYPE DEFAULT 1
   ,par_contact_id        IN bso_hist.contact_id%TYPE DEFAULT NULL
   ,par_department_id     IN bso_hist.department_id%TYPE DEFAULT NULL
   ,par_bso_notes_type_id IN bso_hist.bso_notes_type_id%TYPE DEFAULT NULL
   ,par_reg_date          IN bso_hist.reg_date%TYPE DEFAULT SYSDATE
   ,par_bso_hist_id       OUT bso_hist.bso_hist_id%TYPE
  );

  PROCEDURE update_record(par_record IN bso_hist%ROWTYPE);

  PROCEDURE delete_record(par_bso_hist_id IN bso_hist.bso_hist_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_bso_hist IS

  FUNCTION get_record(par_bso_hist_id IN bso_hist.bso_hist_id%TYPE) RETURN bso_hist%ROWTYPE IS
    vr_record bso_hist%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM bso_hist WHERE bso_hist_id = par_bso_hist_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_bso_id            IN bso_hist.bso_id%TYPE
   ,par_hist_date         IN bso_hist.hist_date%TYPE
   ,par_hist_type_id      IN bso_hist.hist_type_id%TYPE
   ,par_bso_doc_cont_id   IN bso_hist.bso_doc_cont_id%TYPE
   ,par_num               IN bso_hist.num%TYPE DEFAULT 1
   ,par_contact_id        IN bso_hist.contact_id%TYPE DEFAULT NULL
   ,par_department_id     IN bso_hist.department_id%TYPE DEFAULT NULL
   ,par_bso_notes_type_id IN bso_hist.bso_notes_type_id%TYPE DEFAULT NULL
   ,par_reg_date          IN bso_hist.reg_date%TYPE DEFAULT SYSDATE
  ) IS
    v_id bso_hist.bso_hist_id%TYPE;
  BEGIN
    insert_record(par_bso_id            => par_bso_id
                 ,par_hist_date         => par_hist_date
                 ,par_hist_type_id      => par_hist_type_id
                 ,par_bso_doc_cont_id   => par_bso_doc_cont_id
                 ,par_num               => par_num
                 ,par_contact_id        => par_contact_id
                 ,par_department_id     => par_department_id
                 ,par_bso_notes_type_id => par_bso_notes_type_id
                 ,par_reg_date          => par_reg_date
                 ,par_bso_hist_id       => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_bso_id            IN bso_hist.bso_id%TYPE
   ,par_hist_date         IN bso_hist.hist_date%TYPE
   ,par_hist_type_id      IN bso_hist.hist_type_id%TYPE
   ,par_bso_doc_cont_id   IN bso_hist.bso_doc_cont_id%TYPE
   ,par_num               IN bso_hist.num%TYPE DEFAULT 1
   ,par_contact_id        IN bso_hist.contact_id%TYPE DEFAULT NULL
   ,par_department_id     IN bso_hist.department_id%TYPE DEFAULT NULL
   ,par_bso_notes_type_id IN bso_hist.bso_notes_type_id%TYPE DEFAULT NULL
   ,par_reg_date          IN bso_hist.reg_date%TYPE DEFAULT SYSDATE
   ,par_bso_hist_id       OUT bso_hist.bso_hist_id%TYPE
  ) IS
  BEGIN
    SELECT sq_bso_hist.nextval INTO par_bso_hist_id FROM dual;
    INSERT INTO bso_hist
      (bso_hist_id
      ,hist_date
      ,contact_id
      ,reg_date
      ,num
      ,bso_doc_cont_id
      ,department_id
      ,bso_notes_type_id
      ,bso_id
      ,hist_type_id)
    VALUES
      (par_bso_hist_id
      ,par_hist_date
      ,par_contact_id
      ,par_reg_date
      ,par_num
      ,par_bso_doc_cont_id
      ,par_department_id
      ,par_bso_notes_type_id
      ,par_bso_id
      ,par_hist_type_id);
  END insert_record;

  PROCEDURE update_record(par_record IN bso_hist%ROWTYPE) IS
  BEGIN
    UPDATE bso_hist
       SET bso_id            = par_record.bso_id
          ,hist_date         = par_record.hist_date
          ,contact_id        = par_record.contact_id
          ,hist_type_id      = par_record.hist_type_id
          ,num               = par_record.num
          ,bso_doc_cont_id   = par_record.bso_doc_cont_id
          ,department_id     = par_record.department_id
          ,bso_notes_type_id = par_record.bso_notes_type_id
          ,reg_date          = par_record.reg_date
     WHERE bso_hist_id = par_record.bso_hist_id;
  END update_record;

  PROCEDURE delete_record(par_bso_hist_id IN bso_hist.bso_hist_id%TYPE) IS
  BEGIN
    DELETE FROM bso_hist WHERE bso_hist_id = par_bso_hist_id;
  END delete_record;
END;
/
