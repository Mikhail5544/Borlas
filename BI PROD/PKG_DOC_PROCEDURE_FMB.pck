CREATE OR REPLACE PACKAGE PKG_DOC_PROCEDURE_FMB IS

  -- Author  : Чирков В.Ю.
  -- Created : 03.08.2012 13:55:15
  -- Purpose : Логика формы DOC_PROCEDURE.FMB
  PROCEDURE create_new_proc
  (
    par_name      VARCHAR2
   ,par_proc_name VARCHAR2
  );

END PKG_DOC_PROCEDURE_FMB;
/
CREATE OR REPLACE PACKAGE BODY PKG_DOC_PROCEDURE_FMB IS

  PROCEDURE create_new_proc
  (
    par_name      VARCHAR2
   ,par_proc_name VARCHAR2
  ) IS
  BEGIN
    INSERT INTO ven_doc_procedure (NAME, proc_name) VALUES (par_name, par_proc_name);
  END;

END PKG_DOC_PROCEDURE_FMB;
/
