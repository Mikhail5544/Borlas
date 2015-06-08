CREATE OR REPLACE PACKAGE pkg_mpos_writeoff_cancel_dml IS

  FUNCTION get_record(par_mpos_writeoff_cancel_id IN mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE)
    RETURN mpos_writeoff_cancel%ROWTYPE;
  PROCEDURE insert_record
  (
    par_sys_user_id             IN mpos_writeoff_cancel.sys_user_id%TYPE
   ,par_income_date_co          IN mpos_writeoff_cancel.income_date_co%TYPE
   ,par_ids                     IN mpos_writeoff_cancel.ids%TYPE
   ,par_policy_header_id        IN mpos_writeoff_cancel.policy_header_id%TYPE DEFAULT NULL
   ,par_mpos_writeoff_form_id   IN mpos_writeoff_cancel.mpos_writeoff_form_id%TYPE DEFAULT NULL
   ,par_payment_notice_number   IN mpos_writeoff_cancel.payment_notice_number%TYPE DEFAULT NULL
   ,par_income_date_roo         IN mpos_writeoff_cancel.income_date_roo%TYPE DEFAULT NULL
   ,par_reg_date                IN document.reg_date%TYPE DEFAULT NULL
   ,par_note                    IN document.note%TYPE DEFAULT NULL
   ,par_mpos_writeoff_cancel_id OUT mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE
  );
  PROCEDURE update_record(par_record IN mpos_writeoff_cancel%ROWTYPE);
  PROCEDURE delete_record(par_mpos_writeoff_cancel_id IN mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE);

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_mpos_writeoff_cancel_dml IS

  FUNCTION get_record(par_mpos_writeoff_cancel_id IN mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE)
    RETURN mpos_writeoff_cancel%ROWTYPE IS
    vr_record mpos_writeoff_cancel%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM mpos_writeoff_cancel
     WHERE mpos_writeoff_cancel_id = par_mpos_writeoff_cancel_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_sys_user_id             IN mpos_writeoff_cancel.sys_user_id%TYPE
   ,par_income_date_co          IN mpos_writeoff_cancel.income_date_co%TYPE
   ,par_ids                     IN mpos_writeoff_cancel.ids%TYPE
   ,par_policy_header_id        IN mpos_writeoff_cancel.policy_header_id%TYPE DEFAULT NULL
   ,par_mpos_writeoff_form_id   IN mpos_writeoff_cancel.mpos_writeoff_form_id%TYPE DEFAULT NULL
   ,par_payment_notice_number   IN mpos_writeoff_cancel.payment_notice_number%TYPE DEFAULT NULL
   ,par_income_date_roo         IN mpos_writeoff_cancel.income_date_roo%TYPE DEFAULT NULL
   ,par_reg_date                IN document.reg_date%TYPE DEFAULT NULL
   ,par_note                    IN document.note%TYPE DEFAULT NULL
   ,par_mpos_writeoff_cancel_id OUT mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE
  ) IS
  BEGIN
    SELECT sq_mpos_writeoff_cancel.nextval INTO par_mpos_writeoff_cancel_id FROM dual;
    INSERT INTO ven_mpos_writeoff_cancel
      (mpos_writeoff_cancel_id
      ,income_date_co
      ,policy_header_id
      ,ids
      ,income_date_roo
      ,payment_notice_number
      ,mpos_writeoff_form_id
      ,sys_user_id
      ,reg_date
      ,note)
    VALUES
      (par_mpos_writeoff_cancel_id
      ,par_income_date_co
      ,par_policy_header_id
      ,par_ids
      ,par_income_date_roo
      ,par_payment_notice_number
      ,par_mpos_writeoff_form_id
      ,par_sys_user_id
      ,par_reg_date
      ,par_note);
  END insert_record;
  PROCEDURE update_record(par_record IN mpos_writeoff_cancel%ROWTYPE) IS
  BEGIN
    UPDATE mpos_writeoff_cancel
       SET income_date_co        = par_record.income_date_co
          ,policy_header_id      = par_record.policy_header_id
          ,sys_user_id           = par_record.sys_user_id
          ,income_date_roo       = par_record.income_date_roo
          ,payment_notice_number = par_record.payment_notice_number
          ,mpos_writeoff_form_id = par_record.mpos_writeoff_form_id
     WHERE mpos_writeoff_cancel_id = par_record.mpos_writeoff_cancel_id;
  END update_record;
  PROCEDURE delete_record(par_mpos_writeoff_cancel_id IN mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE) IS
  BEGIN
    DELETE FROM ven_mpos_writeoff_cancel WHERE mpos_writeoff_cancel_id = par_mpos_writeoff_cancel_id;
  END delete_record;

END;
/
