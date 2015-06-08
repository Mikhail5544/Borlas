CREATE OR REPLACE PACKAGE PKG_AC_PAYMENT_CHECK_DEL IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 19.07.2013 15:06:05
  -- Purpose : �������� ������������ �������� ������� �� AC_PAYMENT
  --           ������ ��� ����� ������, ����� �� AC_PAYMENT ������ ���������,
  --           � � DOCUMENT ��������.

  /* ������ �.
  
     ���������� ID �� ������� AC_PAYMENT � ��������� ��� �������� ������ �� ������� AC_PAYMENT
     ����������� � �������� after delete row-level �� ������� AC_PAYMENT
  */
  PROCEDURE append_payment(par_payment_id NUMBER);
  
  /** @autor ������ �.�.   
   *  �������� ��������� ��� �������� �� ������� document
   */
  procedure clean_deleted_payments;

  /* ������ �.
  
     �������� ������� ������� � ������� DOCUMENT ����� �������� ������(-��) �� AC_PAYMENT
     ����������� � �������� after delete statement-level �� ������� AC_PAYMENT
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
                             ,'��� �������� ������� �� ���� ������� ������ �� ������� ����������. ����������, �������� �������������!');
    END IF;
    gv_deleted_payments.delete;
  END;

END PKG_AC_PAYMENT_CHECK_DEL; 
/
