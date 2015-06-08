CREATE OR REPLACE PACKAGE PKG_AC_PAYMENT_CHECK_DEL IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 19.07.2013 15:06:05
  -- Purpose : Проверка корректности удаления записей из AC_PAYMENT
  --           Создан для ловли ошибки, когда из AC_PAYMENT записи удаляются,
  --           а в DOCUMENT остаются.

  /* Байтин А.
  
     Добавление ID из таблицы AC_PAYMENT в коллекцию при удалении записи из таблицы AC_PAYMENT
     Выполняется в триггере after delete row-level на таблице AC_PAYMENT
  */
  PROCEDURE append_payment(par_payment_id NUMBER);
  
  /** @autor Чирков В.Ю.   
   *  Очищение коллекции при удалении из таблицы document
   */
  procedure clean_deleted_payments;

  /* Байтин А.
  
     Проверка наличия записей в таблице DOCUMENT после удаления записи(-ей) из AC_PAYMENT
     Выполняется в триггере after delete statement-level на таблице AC_PAYMENT
  */
  PROCEDURE check_document;
END PKG_AC_PAYMENT_CHECK_DEL; 
/
CREATE OR REPLACE PACKAGE BODY PKG_AC_PAYMENT_CHECK_DEL IS

  gv_deleted_payments t_number_type := t_number_type();

  PROCEDURE append_payment(par_payment_id NUMBER) IS
  BEGIN
    gv_deleted_payments.extend(1);
    gv_deleted_payments(gv_deleted_payments.count) := par_payment_id;
  END append_payment;
  
  procedure clean_deleted_payments
    IS
  BEGIN
    gv_deleted_payments.delete;    
  END clean_deleted_payments;

  PROCEDURE check_document IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM document dc
     WHERE dc.document_id IN (SELECT column_value FROM TABLE(gv_deleted_payments));
    IF v_cnt > 0
    THEN
      gv_deleted_payments.delete;
      raise_application_error(-20001
                             ,'При удалении платежа не была удалена запись из таблицы документов. Пожалуйста, сообщите разработчикам!');
    END IF;
    gv_deleted_payments.delete;
  END;

END PKG_AC_PAYMENT_CHECK_DEL; 
/
