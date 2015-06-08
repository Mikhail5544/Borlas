CREATE OR REPLACE PACKAGE pkg_mpos_payment_notice_dml IS

  FUNCTION get_record(par_mpos_payment_notice_id IN mpos_payment_notice.mpos_payment_notice_id%TYPE)
    RETURN mpos_payment_notice%ROWTYPE;

  PROCEDURE insert_record(par_record IN OUT ven_mpos_payment_notice%ROWTYPE);

  PROCEDURE insert_record
  (
    par_transaction_id           IN mpos_payment_notice.transaction_id%TYPE
   ,par_transaction_date         IN mpos_payment_notice.transaction_date%TYPE
   ,par_g_mpos_id                IN mpos_payment_notice.g_mpos_id%TYPE
   ,par_amount                   IN mpos_payment_notice.amount%TYPE
   ,par_t_payment_system_id      IN mpos_payment_notice.t_payment_system_id%TYPE
   ,par_policy_number            IN mpos_payment_notice.policy_number%TYPE
   ,par_policy_start_date        IN mpos_payment_notice.policy_start_date%TYPE
   ,par_t_mpos_payment_status_id IN mpos_payment_notice.t_mpos_payment_status_id%TYPE
   ,par_insured_name             IN mpos_payment_notice.insured_name%TYPE
   ,par_ins_premium              IN mpos_payment_notice.ins_premium%TYPE DEFAULT NULL
   ,par_payment_register_item_id IN mpos_payment_notice.payment_register_item_id%TYPE DEFAULT NULL
   ,par_product_name             IN mpos_payment_notice.product_name%TYPE DEFAULT NULL
   ,par_device_model             IN mpos_payment_notice.device_model%TYPE DEFAULT NULL
   ,par_device_name              IN mpos_payment_notice.device_name%TYPE DEFAULT NULL
   ,par_device_id                IN mpos_payment_notice.device_id%TYPE DEFAULT NULL
   ,par_card_number              IN mpos_payment_notice.card_number%TYPE DEFAULT NULL
   ,par_cliche                   IN mpos_payment_notice.cliche%TYPE DEFAULT NULL
   ,par_terminal_bank_id         IN mpos_payment_notice.terminal_bank_id%TYPE DEFAULT NULL
   ,par_rrn                      IN mpos_payment_notice.rrn%TYPE DEFAULT NULL
   ,par_description              IN mpos_payment_notice.description%TYPE DEFAULT NULL
   ,par_mpos_payment_notice_id   OUT mpos_payment_notice.mpos_payment_notice_id%TYPE
  );
  PROCEDURE update_record(par_record IN mpos_payment_notice%ROWTYPE);
  PROCEDURE delete_record(par_mpos_payment_notice_id IN mpos_payment_notice.mpos_payment_notice_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_mpos_payment_notice_dml IS

  FUNCTION get_record(par_mpos_payment_notice_id IN mpos_payment_notice.mpos_payment_notice_id%TYPE)
    RETURN mpos_payment_notice%ROWTYPE IS
    vr_record mpos_payment_notice%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM mpos_payment_notice
     WHERE mpos_payment_notice_id = par_mpos_payment_notice_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record(par_record IN OUT ven_mpos_payment_notice%ROWTYPE) IS
  BEGIN
    SELECT sq_mpos_payment_notice.nextval INTO par_record.mpos_payment_notice_id FROM dual;
  
    INSERT INTO ven_mpos_payment_notice VALUES par_record;
  END insert_record;

  PROCEDURE insert_record
  (
    par_transaction_id           IN mpos_payment_notice.transaction_id%TYPE
   ,par_transaction_date         IN mpos_payment_notice.transaction_date%TYPE
   ,par_g_mpos_id                IN mpos_payment_notice.g_mpos_id%TYPE
   ,par_amount                   IN mpos_payment_notice.amount%TYPE
   ,par_t_payment_system_id      IN mpos_payment_notice.t_payment_system_id%TYPE
   ,par_policy_number            IN mpos_payment_notice.policy_number%TYPE
   ,par_policy_start_date        IN mpos_payment_notice.policy_start_date%TYPE
   ,par_t_mpos_payment_status_id IN mpos_payment_notice.t_mpos_payment_status_id%TYPE
   ,par_insured_name             IN mpos_payment_notice.insured_name%TYPE
   ,par_ins_premium              IN mpos_payment_notice.ins_premium%TYPE DEFAULT NULL
   ,par_payment_register_item_id IN mpos_payment_notice.payment_register_item_id%TYPE DEFAULT NULL
   ,par_product_name             IN mpos_payment_notice.product_name%TYPE DEFAULT NULL
   ,par_device_model             IN mpos_payment_notice.device_model%TYPE DEFAULT NULL
   ,par_device_name              IN mpos_payment_notice.device_name%TYPE DEFAULT NULL
   ,par_device_id                IN mpos_payment_notice.device_id%TYPE DEFAULT NULL
   ,par_card_number              IN mpos_payment_notice.card_number%TYPE DEFAULT NULL
   ,par_cliche                   IN mpos_payment_notice.cliche%TYPE DEFAULT NULL
   ,par_terminal_bank_id         IN mpos_payment_notice.terminal_bank_id%TYPE DEFAULT NULL
   ,par_rrn                      IN mpos_payment_notice.rrn%TYPE DEFAULT NULL
   ,par_description              IN mpos_payment_notice.description%TYPE DEFAULT NULL
   ,par_mpos_payment_notice_id   OUT mpos_payment_notice.mpos_payment_notice_id%TYPE
  ) IS
  BEGIN
    SELECT sq_mpos_payment_notice.nextval INTO par_mpos_payment_notice_id FROM dual;
    INSERT INTO ven_mpos_payment_notice
      (mpos_payment_notice_id
      ,amount
      ,rrn
      ,terminal_bank_id
      ,cliche
      ,t_payment_system_id
      ,card_number
      ,device_id
      ,device_name
      ,device_model
      ,insured_name
      ,product_name
      ,policy_number
      ,policy_start_date
      ,ins_premium
      ,payment_register_item_id
      ,g_mpos_id
      ,transaction_id
      ,transaction_date
      ,t_mpos_payment_status_id
      ,description)
    VALUES
      (par_mpos_payment_notice_id
      ,par_amount
      ,par_rrn
      ,par_terminal_bank_id
      ,par_cliche
      ,par_t_payment_system_id
      ,par_card_number
      ,par_device_id
      ,par_device_name
      ,par_device_model
      ,par_insured_name
      ,par_product_name
      ,par_policy_number
      ,par_policy_start_date
      ,par_ins_premium
      ,par_payment_register_item_id
      ,par_g_mpos_id
      ,par_transaction_id
      ,par_transaction_date
      ,par_t_mpos_payment_status_id
      ,par_description);
  END insert_record;

  PROCEDURE update_record(par_record IN mpos_payment_notice%ROWTYPE) IS
  BEGIN
    UPDATE ven_mpos_payment_notice
       SET t_mpos_payment_status_id = par_record.t_mpos_payment_status_id
          ,description              = par_record.description
          ,rrn                      = par_record.rrn
          ,terminal_bank_id         = par_record.terminal_bank_id
          ,cliche                   = par_record.cliche
          ,t_payment_system_id      = par_record.t_payment_system_id
          ,card_number              = par_record.card_number
          ,device_id                = par_record.device_id
          ,device_name              = par_record.device_name
          ,device_model             = par_record.device_model
          ,insured_name             = par_record.insured_name
          ,product_name             = par_record.product_name
          ,policy_number            = par_record.policy_number
          ,ins_premium              = par_record.ins_premium
          ,payment_register_item_id = par_record.payment_register_item_id
          ,g_mpos_id                = par_record.g_mpos_id
          ,transaction_id           = par_record.transaction_id
          ,transaction_date         = par_record.transaction_date
          ,amount                   = par_record.amount
     WHERE mpos_payment_notice_id = par_record.mpos_payment_notice_id;
  END update_record;
  PROCEDURE delete_record(par_mpos_payment_notice_id IN mpos_payment_notice.mpos_payment_notice_id%TYPE) IS
  BEGIN
    DELETE FROM ven_mpos_payment_notice WHERE mpos_payment_notice_id = par_mpos_payment_notice_id;
  END delete_record;
END;
/
