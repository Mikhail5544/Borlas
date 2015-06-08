CREATE OR REPLACE PACKAGE pkg_validate_doc IS

  -- Author  : RKUDRYAVCEV
  -- Created : 11.09.2007 16:40:17
  -- Purpose : Проверка документов при исполнении

  --------------------------------------------------
  --
  -- Проверка испорления Распоряжений на выплату:
  -- Должен быть заполнен Рсч Получателя
  --
  --------------------------------------------------
  PROCEDURE validate_ac_payment(p_document_id ins.document.document_id%TYPE);

END pkg_validate_doc;
/
CREATE OR REPLACE PACKAGE BODY pkg_validate_doc IS
  --------------------------------------------------
  --
  -- Проверка испорления Распоряжений на выплату:
  -- Должен быть заполнен Рсч Получателя
  --
  --------------------------------------------------
  PROCEDURE validate_ac_payment(p_document_id ins.document.document_id%TYPE) IS
    var_ac_payment ins.ac_payment%ROWTYPE;
  BEGIN
    -- проверка
    BEGIN
      SELECT p.* INTO var_ac_payment FROM ins.ac_payment p WHERE p.payment_id = p_document_id;
    EXCEPTION
      WHEN no_data_found THEN
        -- нет такого документа
        raise_application_error(-20100
                               ,'Документ с ID:' || NVL(p_document_id, '<null>') ||
                                ' не Распоряжение на вылату. Ошибка настройки');
      
    END;
  
    -- проверим заполнение Рсч Получателя
  
    IF var_ac_payment.contact_bank_acc_id IS NULL
    THEN
    
      raise_application_error(-20100
                             ,'Необходимо указать Расчетный счет получателя');
    
    END IF;
  
  END validate_ac_payment;
END pkg_validate_doc;
/
