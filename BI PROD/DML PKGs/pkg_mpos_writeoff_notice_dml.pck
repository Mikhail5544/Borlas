CREATE OR REPLACE PACKAGE pkg_mpos_writeoff_notice_dml IS

  FUNCTION get_record (par_mpos_writeoff_notice_id IN mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE) RETURN mpos_writeoff_notice%ROWTYPE;
  PROCEDURE insert_record
  (
    par_transaction_date         IN mpos_writeoff_notice.transaction_date%TYPE
   ,par_transaction_id           IN mpos_writeoff_notice.transaction_id%TYPE
   ,par_t_payment_system_id      IN mpos_writeoff_notice.t_payment_system_id%TYPE
   ,par_writeoff_number          IN mpos_writeoff_notice.writeoff_number%TYPE
   ,par_amount                   IN mpos_writeoff_notice.amount%TYPE
   ,par_cliche                   IN mpos_writeoff_notice.cliche%TYPE DEFAULT NULL
   ,par_g_mpos_id                IN mpos_writeoff_notice.g_mpos_id%TYPE DEFAULT NULL
   ,par_rrn                      IN mpos_writeoff_notice.rrn%TYPE DEFAULT NULL
   ,par_description              IN mpos_writeoff_notice.description%TYPE DEFAULT NULL
   ,par_terminal_bank_id         IN mpos_writeoff_notice.terminal_bank_id%TYPE DEFAULT NULL
   ,par_card_number              IN mpos_writeoff_notice.card_number%TYPE DEFAULT NULL
   ,par_device_id                IN mpos_writeoff_notice.device_id%TYPE DEFAULT NULL
   ,par_device_name              IN mpos_writeoff_notice.device_name%TYPE DEFAULT NULL
   ,par_device_model             IN mpos_writeoff_notice.device_model%TYPE DEFAULT NULL
   ,par_mpos_writeoff_form_id    IN mpos_writeoff_notice.mpos_writeoff_form_id%TYPE DEFAULT NULL
   ,par_payment_register_item_id IN mpos_writeoff_notice.payment_register_item_id%TYPE DEFAULT NULL
   ,par_note                     IN document.note%TYPE DEFAULT NULL
   ,par_mpos_writeoff_notice_id  OUT mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  );
  PROCEDURE update_record
  (
   par_record IN ven_mpos_writeoff_notice%ROWTYPE
  );
  PROCEDURE delete_record
  (
    par_mpos_writeoff_notice_id IN mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  );
END; 
/
CREATE OR REPLACE PACKAGE BODY pkg_mpos_writeoff_notice_dml IS

  FUNCTION get_record (par_mpos_writeoff_notice_id IN mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE)
    RETURN mpos_writeoff_notice%ROWTYPE
  IS
    vr_record mpos_writeoff_notice%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM mpos_writeoff_notice WHERE mpos_writeoff_notice_id = par_mpos_writeoff_notice_id;
    RETURN vr_record;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END get_record;
  PROCEDURE insert_record
  (
    par_transaction_date         IN mpos_writeoff_notice.transaction_date%TYPE
   ,par_transaction_id           IN mpos_writeoff_notice.transaction_id%TYPE
   ,par_t_payment_system_id      IN mpos_writeoff_notice.t_payment_system_id%TYPE
   ,par_writeoff_number          IN mpos_writeoff_notice.writeoff_number%TYPE
   ,par_amount                   IN mpos_writeoff_notice.amount%TYPE
   ,par_cliche                   IN mpos_writeoff_notice.cliche%TYPE DEFAULT NULL
   ,par_g_mpos_id                IN mpos_writeoff_notice.g_mpos_id%TYPE DEFAULT NULL
   ,par_rrn                      IN mpos_writeoff_notice.rrn%TYPE DEFAULT NULL
   ,par_description              IN mpos_writeoff_notice.description%TYPE DEFAULT NULL
   ,par_terminal_bank_id         IN mpos_writeoff_notice.terminal_bank_id%TYPE DEFAULT NULL
   ,par_card_number              IN mpos_writeoff_notice.card_number%TYPE DEFAULT NULL
   ,par_device_id                IN mpos_writeoff_notice.device_id%TYPE DEFAULT NULL
   ,par_device_name              IN mpos_writeoff_notice.device_name%TYPE DEFAULT NULL
   ,par_device_model             IN mpos_writeoff_notice.device_model%TYPE DEFAULT NULL
   ,par_mpos_writeoff_form_id    IN mpos_writeoff_notice.mpos_writeoff_form_id%TYPE DEFAULT NULL
   ,par_payment_register_item_id IN mpos_writeoff_notice.payment_register_item_id%TYPE DEFAULT NULL
   ,par_note                     IN document.note%TYPE DEFAULT NULL
   ,par_mpos_writeoff_notice_id  OUT mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  )
  IS
  BEGIN
    SELECT sq_mpos_writeoff_notice.nextval INTO par_mpos_writeoff_notice_id FROM dual;
    INSERT INTO ven_mpos_writeoff_notice
      (mpos_writeoff_notice_id
      ,transaction_id
      ,transaction_date
      ,writeoff_number
      ,amount
      ,description
      ,rrn
      ,terminal_bank_id
      ,cliche
      ,t_payment_system_id
      ,card_number
      ,device_id
      ,device_name
      ,device_model
      ,mpos_writeoff_form_id
      ,payment_register_item_id
      ,note
      ,g_mpos_id)
    VALUES
      (par_mpos_writeoff_notice_id
      ,par_transaction_id
      ,par_transaction_date
      ,par_writeoff_number
      ,par_amount
      ,par_description
      ,par_rrn
      ,par_terminal_bank_id
      ,par_cliche
      ,par_t_payment_system_id
      ,par_card_number
      ,par_device_id
      ,par_device_name
      ,par_device_model
      ,par_mpos_writeoff_form_id
      ,par_payment_register_item_id
      ,par_note
      ,par_g_mpos_id);
  END insert_record;
  PROCEDURE update_record
  (
   par_record IN ven_mpos_writeoff_notice%ROWTYPE
  )
  IS
  BEGIN
    UPDATE ven_mpos_writeoff_notice
      SET transaction_id = par_record.transaction_id
         ,transaction_date = par_record.transaction_date
         ,writeoff_number = par_record.writeoff_number
         ,amount = par_record.amount
         ,description = par_record.description
         ,rrn = par_record.rrn
         ,terminal_bank_id = par_record.terminal_bank_id
         ,cliche = par_record.cliche
         ,t_payment_system_id = par_record.t_payment_system_id
         ,card_number = par_record.card_number
         ,device_id = par_record.device_id
         ,device_name = par_record.device_name
         ,device_model = par_record.device_model
         ,mpos_writeoff_form_id = par_record.mpos_writeoff_form_id
         ,payment_register_item_id = par_record.payment_register_item_id
         ,note = par_record.note
         ,g_mpos_id = par_record.g_mpos_id
    WHERE mpos_writeoff_notice_id = par_record.mpos_writeoff_notice_id;
  END update_record;
  PROCEDURE delete_record
  (
    par_mpos_writeoff_notice_id IN mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  )
  IS
  BEGIN
    DELETE FROM mpos_writeoff_notice
          WHERE mpos_writeoff_notice_id = par_mpos_writeoff_notice_id;
  END delete_record;
END; 
/
