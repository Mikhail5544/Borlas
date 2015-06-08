CREATE OR REPLACE PACKAGE PKG_DOC_SET_OFF IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 19.02.2013 17:21:45
  -- Purpose : Для работы с документами зачета

  /*
    Байтин А.
    Добавление документа зачета в таблицу
  */
  PROCEDURE insert_doc_set_off
  (
    par_reg_date              document.reg_date%TYPE
   ,par_child_doc_id          doc_set_off.child_doc_id%TYPE
   ,par_parent_doc_id         doc_set_off.parent_doc_id%TYPE
   ,par_pay_registry_item     doc_set_off.pay_registry_item%TYPE
   ,par_set_off_amount        doc_set_off.set_off_amount%TYPE
   ,par_set_off_child_amount  doc_set_off.set_off_child_amount%TYPE
   ,par_set_off_child_fund_id doc_set_off.set_off_child_fund_id%TYPE
   ,par_set_off_date          doc_set_off.set_off_date%TYPE
   ,par_set_off_fund_id       doc_set_off.set_off_fund_id%TYPE
   ,par_set_off_rate          doc_set_off.set_off_rate%TYPE
   ,par_num                   document.num%TYPE DEFAULT NULL
   ,par_ndfl_tax              doc_set_off.ndfl_tax%TYPE DEFAULT NULL
   ,par_cancel_date           doc_set_off.cancel_date%TYPE DEFAULT NULL
   ,par_note                  document.note%TYPE DEFAULT NULL
   ,par_doc_set_off_id        OUT doc_set_off.doc_set_off_id%TYPE
  );
  /* Байтин А.
    Создание документа зачета
  */
  PROCEDURE create_doc_set_off
  (
    par_parent_id            NUMBER
   ,par_child_id             NUMBER
   ,par_set_off_amount       NUMBER
   ,par_set_off_child_amount NUMBER
   ,par_pay_registry_item_id NUMBER DEFAULT NULL
   ,par_doc_set_off_id       OUT NUMBER
  );

END PKG_DOC_SET_OFF;
/
CREATE OR REPLACE PACKAGE BODY PKG_DOC_SET_OFF IS

  gc_package_name CONSTANT VARCHAR2(30) := 'PKG_DOC_SET_OFF';

  /*
    Байтин А.
    Добавление документа зачета в таблицу
  */
  PROCEDURE insert_doc_set_off
  (
    par_reg_date              document.reg_date%TYPE
   ,par_child_doc_id          doc_set_off.child_doc_id%TYPE
   ,par_parent_doc_id         doc_set_off.parent_doc_id%TYPE
   ,par_pay_registry_item     doc_set_off.pay_registry_item%TYPE
   ,par_set_off_amount        doc_set_off.set_off_amount%TYPE
   ,par_set_off_child_amount  doc_set_off.set_off_child_amount%TYPE
   ,par_set_off_child_fund_id doc_set_off.set_off_child_fund_id%TYPE
   ,par_set_off_date          doc_set_off.set_off_date%TYPE
   ,par_set_off_fund_id       doc_set_off.set_off_fund_id%TYPE
   ,par_set_off_rate          doc_set_off.set_off_rate%TYPE
   ,par_num                   document.num%TYPE DEFAULT NULL
   ,par_ndfl_tax              doc_set_off.ndfl_tax%TYPE DEFAULT NULL
   ,par_cancel_date           doc_set_off.cancel_date%TYPE DEFAULT NULL
   ,par_note                  document.note%TYPE DEFAULT NULL
   ,par_doc_set_off_id        OUT doc_set_off.doc_set_off_id%TYPE
  ) IS
    c_procedure_name CONSTANT VARCHAR2(30) := 'insert_doc_set_off';
  BEGIN
    SELECT sq_doc_set_off.nextval INTO par_doc_set_off_id FROM dual;
  
    INSERT INTO ven_doc_set_off dso
      (doc_set_off_id
      ,note
      ,num
      ,reg_date
      ,cancel_date
      ,child_doc_id
      ,ndfl_tax
      ,parent_doc_id
      ,pay_registry_item
      ,set_off_amount
      ,set_off_child_amount
      ,set_off_child_fund_id
      ,set_off_date
      ,set_off_fund_id
      ,set_off_rate)
    VALUES
      (par_doc_set_off_id
      ,par_note
      ,nvl(par_num, to_char(par_doc_set_off_id))
      ,par_reg_date
      ,par_cancel_date
      ,par_child_doc_id
      ,par_ndfl_tax
      ,par_parent_doc_id
      ,par_pay_registry_item
      ,par_set_off_amount
      ,par_set_off_child_amount
      ,par_set_off_child_fund_id
      ,par_set_off_date
      ,par_set_off_fund_id
      ,par_set_off_rate);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Нарушена уникальность при добавлении документа зачета (' ||
                              gc_package_name || '.' || c_procedure_name || ')');
    WHEN PKG_ORACLE_EXCEPTIONS.CANT_INSERT_NULL THEN
      raise_application_error(-20001
                             ,'Невозможно вставить значение NULL при добавлении документа зачета (' ||
                              gc_package_name || '.' || c_procedure_name || ')');
    WHEN PKG_ORACLE_EXCEPTIONS.CHECK_VIOLATED THEN
      raise_application_error(-20001
                             ,'Ошибка ограничения проверки при добавлении документа зачета (' ||
                              gc_package_name || '.' || c_procedure_name || ')');
    WHEN PKG_ORACLE_EXCEPTIONS.PARENT_KEY_NOT_FOUND THEN
      raise_application_error(-20001
                             ,'Ошибка ограничения внешнего ключа при добавлении документа зачета (' ||
                              gc_package_name || '.' || c_procedure_name || ')');
  END insert_doc_set_off;

  /* Байтин А.
    Создание документа зачета
  */
  PROCEDURE create_doc_set_off
  (
    par_parent_id            NUMBER
   ,par_child_id             NUMBER
   ,par_set_off_amount       NUMBER
   ,par_set_off_child_amount NUMBER
   ,par_pay_registry_item_id NUMBER DEFAULT NULL
   ,par_doc_set_off_id       OUT NUMBER
  ) IS
    v_fund_id      fund.fund_id%TYPE;
    v_set_off_date doc_set_off.set_off_date%TYPE;
    v_rev_fund_id  doc_set_off.set_off_fund_id%TYPE;
    v_rev_rate     doc_set_off.set_off_rate%TYPE;
  BEGIN
    SELECT ac.fund_id
          ,ac.rev_fund_id
          ,ac.rev_rate
          ,greatest(ac.reg_date, ac.due_date)
      INTO v_fund_id
          ,v_rev_fund_id
          ,v_rev_rate
          ,v_set_off_date
      FROM ven_ac_payment ac
     WHERE ac.payment_id = par_child_id;
  
    pkg_doc_set_off.insert_doc_set_off(par_reg_date              => v_set_off_date
                                      ,par_child_doc_id          => par_child_id
                                      ,par_parent_doc_id         => par_parent_id
                                      ,par_pay_registry_item     => par_pay_registry_item_id
                                      ,par_set_off_amount        => par_set_off_amount
                                      ,par_set_off_child_amount  => par_set_off_child_amount
                                      ,par_set_off_child_fund_id => v_fund_id
                                      ,par_set_off_date          => v_set_off_date
                                      ,par_set_off_fund_id       => v_rev_fund_id
                                      ,par_set_off_rate          => v_rev_rate
                                      ,par_doc_set_off_id        => par_doc_set_off_id);
  END create_doc_set_off;

END PKG_DOC_SET_OFF;
/
