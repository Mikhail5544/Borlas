CREATE OR REPLACE PACKAGE pkg_g_mpos_dml IS

  FUNCTION get_record(par_g_mpos_id IN g_mpos.g_mpos_id%TYPE) RETURN g_mpos%ROWTYPE;
  PROCEDURE insert_record(par_record IN OUT g_mpos%ROWTYPE);
  PROCEDURE insert_record
  (
    par_import_date         IN g_mpos.import_date%TYPE DEFAULT SYSDATE
   ,par_rrn                 IN g_mpos.rrn%TYPE DEFAULT NULL
   ,par_transaction_id      IN g_mpos.transaction_id%TYPE DEFAULT NULL
   ,par_transaction_date    IN g_mpos.transaction_date%TYPE DEFAULT NULL
   ,par_writeoff_frequency  IN g_mpos.writeoff_frequency%TYPE DEFAULT NULL
   ,par_amount              IN g_mpos.amount%TYPE DEFAULT NULL
   ,par_payment_status      IN g_mpos.payment_status%TYPE DEFAULT NULL
   ,par_transaction_init_id IN g_mpos.transaction_init_id%TYPE DEFAULT NULL
   ,par_writeoff_number     IN g_mpos.writeoff_number%TYPE DEFAULT NULL
   ,par_description         IN g_mpos.description%TYPE DEFAULT NULL
   ,par_ins_premium         IN g_mpos.ins_premium%TYPE DEFAULT NULL
   ,par_payment_system      IN g_mpos.payment_system%TYPE DEFAULT NULL
   ,par_terminal_bank_id    IN g_mpos.terminal_bank_id%TYPE DEFAULT NULL
   ,par_cliche              IN g_mpos.cliche%TYPE DEFAULT NULL
   ,par_card_number         IN g_mpos.card_number%TYPE DEFAULT NULL
   ,par_device_id           IN g_mpos.device_id%TYPE DEFAULT NULL
   ,par_device_name         IN g_mpos.device_name%TYPE DEFAULT NULL
   ,par_device_model        IN g_mpos.device_model%TYPE DEFAULT NULL
   ,par_insured_name        IN g_mpos.insured_name%TYPE DEFAULT NULL
   ,par_product_name        IN g_mpos.product_name%TYPE DEFAULT NULL
   ,par_policy_number       IN g_mpos.policy_number%TYPE DEFAULT NULL
   ,par_g_mpos_id           OUT g_mpos.g_mpos_id%TYPE
  );
  PROCEDURE update_record(par_record IN g_mpos%ROWTYPE);
  PROCEDURE delete_record(par_g_mpos_id IN g_mpos.g_mpos_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_g_mpos_dml IS

  FUNCTION get_record(par_g_mpos_id IN g_mpos.g_mpos_id%TYPE) RETURN g_mpos%ROWTYPE IS
    vr_record g_mpos%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM g_mpos WHERE g_mpos_id = par_g_mpos_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record(par_record IN OUT g_mpos%ROWTYPE) IS
  BEGIN
    SELECT sq_g_mpos.nextval INTO par_record.g_mpos_id FROM dual;
    INSERT INTO g_mpos VALUES par_record;
  END insert_record;

  PROCEDURE insert_record
  (
    par_import_date         IN g_mpos.import_date%TYPE DEFAULT SYSDATE
   ,par_rrn                 IN g_mpos.rrn%TYPE DEFAULT NULL
   ,par_transaction_id      IN g_mpos.transaction_id%TYPE DEFAULT NULL
   ,par_transaction_date    IN g_mpos.transaction_date%TYPE DEFAULT NULL
   ,par_writeoff_frequency  IN g_mpos.writeoff_frequency%TYPE DEFAULT NULL
   ,par_amount              IN g_mpos.amount%TYPE DEFAULT NULL
   ,par_payment_status      IN g_mpos.payment_status%TYPE DEFAULT NULL
   ,par_transaction_init_id IN g_mpos.transaction_init_id%TYPE DEFAULT NULL
   ,par_writeoff_number     IN g_mpos.writeoff_number%TYPE DEFAULT NULL
   ,par_description         IN g_mpos.description%TYPE DEFAULT NULL
   ,par_ins_premium         IN g_mpos.ins_premium%TYPE DEFAULT NULL
   ,par_payment_system      IN g_mpos.payment_system%TYPE DEFAULT NULL
   ,par_terminal_bank_id    IN g_mpos.terminal_bank_id%TYPE DEFAULT NULL
   ,par_cliche              IN g_mpos.cliche%TYPE DEFAULT NULL
   ,par_card_number         IN g_mpos.card_number%TYPE DEFAULT NULL
   ,par_device_id           IN g_mpos.device_id%TYPE DEFAULT NULL
   ,par_device_name         IN g_mpos.device_name%TYPE DEFAULT NULL
   ,par_device_model        IN g_mpos.device_model%TYPE DEFAULT NULL
   ,par_insured_name        IN g_mpos.insured_name%TYPE DEFAULT NULL
   ,par_product_name        IN g_mpos.product_name%TYPE DEFAULT NULL
   ,par_policy_number       IN g_mpos.policy_number%TYPE DEFAULT NULL
   ,par_g_mpos_id           OUT g_mpos.g_mpos_id%TYPE
  ) IS
  BEGIN
    SELECT sq_g_mpos.nextval INTO par_g_mpos_id FROM dual;
    INSERT INTO g_mpos
      (g_mpos_id
      ,transaction_id
      ,transaction_date
      ,writeoff_frequency
      ,amount
      ,payment_status
      ,transaction_init_id
      ,writeoff_number
      ,description
      ,rrn
      ,payment_system
      ,terminal_bank_id
      ,cliche
      ,card_number
      ,device_id
      ,device_name
      ,device_model
      ,insured_name
      ,product_name
      ,policy_number
      ,ins_premium
      ,import_date)
    VALUES
      (par_g_mpos_id
      ,par_transaction_id
      ,par_transaction_date
      ,par_writeoff_frequency
      ,par_amount
      ,par_payment_status
      ,par_transaction_init_id
      ,par_writeoff_number
      ,par_description
      ,par_rrn
      ,par_payment_system
      ,par_terminal_bank_id
      ,par_cliche
      ,par_card_number
      ,par_device_id
      ,par_device_name
      ,par_device_model
      ,par_insured_name
      ,par_product_name
      ,par_policy_number
      ,par_ins_premium
      ,par_import_date);
  END insert_record;
  PROCEDURE update_record(par_record IN g_mpos%ROWTYPE) IS
  BEGIN
    UPDATE g_mpos
       SET import_date         = par_record.import_date
          ,transaction_id      = par_record.transaction_id
          ,transaction_date    = par_record.transaction_date
          ,writeoff_frequency  = par_record.writeoff_frequency
          ,amount              = par_record.amount
          ,payment_status      = par_record.payment_status
          ,transaction_init_id = par_record.transaction_init_id
          ,writeoff_number     = par_record.writeoff_number
          ,description         = par_record.description
          ,rrn                 = par_record.rrn
          ,payment_system      = par_record.payment_system
          ,terminal_bank_id    = par_record.terminal_bank_id
          ,cliche              = par_record.cliche
          ,card_number         = par_record.card_number
          ,device_id           = par_record.device_id
          ,device_name         = par_record.device_name
          ,device_model        = par_record.device_model
          ,insured_name        = par_record.insured_name
          ,product_name        = par_record.product_name
          ,policy_number       = par_record.policy_number
          ,ins_premium         = par_record.ins_premium
     WHERE g_mpos_id = par_record.g_mpos_id;
  END update_record;
  PROCEDURE delete_record(par_g_mpos_id IN g_mpos.g_mpos_id%TYPE) IS
  BEGIN
    DELETE FROM g_mpos WHERE g_mpos_id = par_g_mpos_id;
  END delete_record;
END;
/
