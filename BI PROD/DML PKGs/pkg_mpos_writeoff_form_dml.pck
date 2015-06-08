CREATE OR REPLACE PACKAGE BODY pkg_mpos_writeoff_form_dml IS

  FUNCTION get_record(par_mpos_writeoff_form_id IN mpos_writeoff_form.mpos_writeoff_form_id%TYPE)
    RETURN mpos_writeoff_form%ROWTYPE IS
    vr_record mpos_writeoff_form%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM mpos_writeoff_form
     WHERE mpos_writeoff_form_id = par_mpos_writeoff_form_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  FUNCTION get_id_by_transaction_id
  (
    par_transaction_id IN mpos_writeoff_form.transaction_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE IS
    v_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
  BEGIN
    BEGIN
      SELECT f.mpos_writeoff_form_id
        INTO v_id
        FROM mpos_writeoff_form f
       WHERE transaction_id = par_transaction_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдено уведомление о создании периодического списания по идентификатору транзакции "' ||
                                  par_transaction_id || '"');
        ELSE
          v_id := NULL;
        END IF;
      WHEN too_many_rows THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Найдено несколько уведомлений о создании периодического списания по идентификатору транзакции "' ||
                                  par_transaction_id || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_transaction_id;

  FUNCTION get_transaction_id_by_id
  (
    par_mpos_writeoff_form_id IN mpos_writeoff_form.mpos_writeoff_form_id%TYPE
   ,par_raise_on_error        BOOLEAN DEFAULT TRUE
  ) RETURN mpos_writeoff_form.transaction_id%TYPE
  is
    v_id mpos_writeoff_form.transaction_id%TYPE;
  begin
    BEGIN
      SELECT f.transaction_id
        INTO v_id
        FROM mpos_writeoff_form f
       WHERE mpos_writeoff_form_id = par_mpos_writeoff_form_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдено уведомление о создании периодического списания по ИД "' ||
                                  par_mpos_writeoff_form_id || '"');
        ELSE
          v_id := NULL;
        END IF;
      WHEN too_many_rows THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Найдено несколько уведомлений о создании периодического списания по ИД "' ||
                                  par_mpos_writeoff_form_id || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  end get_transaction_id_by_id;

  PROCEDURE insert_record
  (
    par_t_payment_system_id      IN mpos_writeoff_form.t_payment_system_id%TYPE
   ,par_fund_id                  IN mpos_writeoff_form.fund_id%TYPE
   ,par_transaction_id           IN mpos_writeoff_form.transaction_id%TYPE
   ,par_t_payment_terms_id       IN mpos_writeoff_form.t_payment_terms_id%TYPE
   ,par_policy_number            IN mpos_writeoff_form.policy_number%TYPE
   ,par_transaction_date         IN mpos_writeoff_form.transaction_date%TYPE
   ,par_insured_name             IN mpos_writeoff_form.insured_name%TYPE
   ,par_t_mpos_payment_status_id IN mpos_writeoff_form.t_mpos_payment_status_id%TYPE
   ,par_amount                   IN mpos_writeoff_form.amount%TYPE
   ,par_policy_header_id         IN mpos_writeoff_form.policy_header_id%TYPE DEFAULT NULL
   ,par_ins_premium              IN mpos_writeoff_form.ins_premium%TYPE DEFAULT NULL
   ,par_ids_for_recognition      IN mpos_writeoff_form.ids_for_recognition%TYPE DEFAULT NULL
   ,par_product_name             IN mpos_writeoff_form.product_name%TYPE DEFAULT NULL
   ,par_device_model             IN mpos_writeoff_form.device_model%TYPE DEFAULT NULL
   ,par_device_name              IN mpos_writeoff_form.device_name%TYPE DEFAULT NULL
   ,par_device_id                IN mpos_writeoff_form.device_id%TYPE DEFAULT NULL
   ,par_card_number              IN mpos_writeoff_form.card_number%TYPE DEFAULT NULL
   ,par_cliche                   IN mpos_writeoff_form.cliche%TYPE DEFAULT NULL
   ,par_terminal_bank_id         IN mpos_writeoff_form.terminal_bank_id%TYPE DEFAULT NULL
   ,par_rrn                      IN mpos_writeoff_form.rrn%TYPE DEFAULT NULL
   ,par_description              IN mpos_writeoff_form.description%TYPE DEFAULT NULL
   ,par_g_mpos_id                IN mpos_writeoff_form.g_mpos_id%TYPE DEFAULT NULL
   ,par_t_mpos_rejection_id      IN mpos_writeoff_form.t_mpos_rejection_id%TYPE DEFAULT NULL
   ,par_mpos_writeoff_form_id    OUT mpos_writeoff_form.mpos_writeoff_form_id%TYPE
  ) IS
  BEGIN
    SELECT sq_mpos_writeoff_form.nextval INTO par_mpos_writeoff_form_id FROM dual;
    INSERT INTO ven_mpos_writeoff_form
      (mpos_writeoff_form_id
      ,t_payment_terms_id
      ,transaction_id
      ,transaction_date
      ,amount
      ,t_mpos_payment_status_id
      ,description
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
      ,ids_for_recognition
      ,policy_header_id
      ,fund_id
      ,ins_premium
      ,t_mpos_rejection_id
      ,g_mpos_id)
    VALUES
      (par_mpos_writeoff_form_id
      ,par_t_payment_terms_id
      ,par_transaction_id
      ,par_transaction_date
      ,par_amount
      ,par_t_mpos_payment_status_id
      ,par_description
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
      ,par_ids_for_recognition
      ,par_policy_header_id
      ,par_fund_id
      ,par_ins_premium
      ,par_t_mpos_rejection_id
      ,par_g_mpos_id);
  END insert_record;

  PROCEDURE update_record(par_record IN mpos_writeoff_form%ROWTYPE) IS
  BEGIN
    UPDATE mpos_writeoff_form
       SET t_payment_terms_id       = par_record.t_payment_terms_id
          ,transaction_id           = par_record.transaction_id
          ,transaction_date         = par_record.transaction_date
          ,amount                   = par_record.amount
          ,t_mpos_payment_status_id = par_record.t_mpos_payment_status_id
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
          ,ids_for_recognition      = par_record.ids_for_recognition
          ,policy_header_id         = par_record.policy_header_id
          ,fund_id                  = par_record.fund_id
          ,ins_premium              = par_record.ins_premium
          ,t_mpos_rejection_id      = par_record.t_mpos_rejection_id
          ,g_mpos_id                = par_record.g_mpos_id
     WHERE mpos_writeoff_form_id = par_record.mpos_writeoff_form_id;
  END update_record;

  PROCEDURE delete_record(par_mpos_writeoff_form_id IN mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
  BEGIN
    DELETE FROM mpos_writeoff_form WHERE mpos_writeoff_form_id = par_mpos_writeoff_form_id;
  END delete_record;

  PROCEDURE set_rejection_status
  (
    par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
   ,par_t_mpos_rejection_id   t_mpos_rejection.t_mpos_rejection_id%TYPE
  ) IS
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
          ,'Не указан ИД записи уведомления о создании ПС');
    assert_deprecated(par_t_mpos_rejection_id IS NULL
          ,'Не указан ИД записи справочника причин отказа');
  
    UPDATE mpos_writeoff_form wf
       SET wf.t_mpos_rejection_id = par_t_mpos_rejection_id
     WHERE wf.mpos_writeoff_form_id = par_mpos_writeoff_form_id;
  END set_rejection_status;

  PROCEDURE set_pol_header
  (
    par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
   ,par_policy_header_id mpos_writeoff_form.policy_header_id%TYPE
  ) IS
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
          ,'Не указан ИД записи уведомления о создании ПС');
    assert_deprecated(par_policy_header_id IS NULL
          ,'Не указан ИД договора страхования');
  
    UPDATE mpos_writeoff_form wf
       SET wf.policy_header_id = par_policy_header_id
     WHERE wf.mpos_writeoff_form_id = par_mpos_writeoff_form_id;
  END set_pol_header;
  
END; 
/
