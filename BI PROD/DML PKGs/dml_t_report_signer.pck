CREATE OR REPLACE PACKAGE dml_t_report_signer IS

  FUNCTION get_record (par_t_report_signer_id IN T_REPORT_SIGNER.t_report_signer_id%TYPE) RETURN t_report_signer%ROWTYPE;

  PROCEDURE insert_record
  (
    par_t_signer_id IN T_REPORT_SIGNER.t_signer_id%TYPE
   ,par_report_id   IN T_REPORT_SIGNER.report_id%TYPE
  );

  PROCEDURE insert_record
  (
    par_t_signer_id        IN T_REPORT_SIGNER.t_signer_id%TYPE
   ,par_report_id          IN T_REPORT_SIGNER.report_id%TYPE
   ,par_t_report_signer_id OUT T_REPORT_SIGNER.t_report_signer_id%TYPE
  );

  PROCEDURE update_record
  (
   par_record IN t_report_signer%ROWTYPE
  );

  PROCEDURE delete_record
  (
    par_t_report_signer_id IN T_REPORT_SIGNER.t_report_signer_id%TYPE
  );
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_report_signer IS

  FUNCTION get_record (par_t_report_signer_id IN T_REPORT_SIGNER.t_report_signer_id%TYPE) RETURN t_report_signer%ROWTYPE
  IS
    vr_record t_report_signer%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_report_signer WHERE t_report_signer_id = par_t_report_signer_id;
    RETURN vr_record;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_t_signer_id IN T_REPORT_SIGNER.t_signer_id%TYPE
   ,par_report_id   IN T_REPORT_SIGNER.report_id%TYPE
  )
  IS
    v_id t_report_signer.t_report_signer_id%TYPE;
  BEGIN
    insert_record(par_t_signer_id => par_t_signer_id
                 ,par_report_id => par_report_id
                 ,par_t_report_signer_id => v_id);

  END insert_record;

  PROCEDURE insert_record
  (
    par_t_signer_id        IN T_REPORT_SIGNER.t_signer_id%TYPE
   ,par_report_id          IN T_REPORT_SIGNER.report_id%TYPE
   ,par_t_report_signer_id OUT T_REPORT_SIGNER.t_report_signer_id%TYPE
  )
  IS
  BEGIN
    SELECT sq_t_report_signer.nextval INTO par_t_report_signer_id FROM dual;
    INSERT INTO t_report_signer
      (t_report_signer_id
      ,report_id
      ,t_signer_id)
    VALUES
      (par_t_report_signer_id
      ,par_report_id
      ,par_t_signer_id);
  END insert_record;

  PROCEDURE update_record
  (
   par_record IN t_report_signer%ROWTYPE
  )
  IS
  BEGIN
    UPDATE t_report_signer
      SET t_signer_id = par_record.t_signer_id
         ,report_id = par_record.report_id
    WHERE t_report_signer_id = par_record.t_report_signer_id;
  END update_record;

  PROCEDURE delete_record
  (
    par_t_report_signer_id IN T_REPORT_SIGNER.t_report_signer_id%TYPE
  )
  IS
  BEGIN
    DELETE FROM t_report_signer
          WHERE t_report_signer_id = par_t_report_signer_id;
  END delete_record;
END;
/
