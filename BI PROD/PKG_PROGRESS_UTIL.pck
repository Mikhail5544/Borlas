CREATE OR REPLACE PACKAGE PKG_PROGRESS_UTIL IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.08.2010 15:57:04
  -- Purpose : Используется для отслеживания длительных процессов

  PROCEDURE SET_PROGRESS_PERCENT
  (
    p_proc_name VARCHAR2
   ,p_doc_id    PLS_INTEGER
   ,p_progress  NUMBER
  );
  FUNCTION GET_PROGRESS_PERCENT
  (
    p_proc_name VARCHAR2
   ,p_doc_id    PLS_INTEGER
  ) RETURN NUMBER;

END PKG_PROGRESS_UTIL;
/
CREATE OR REPLACE PACKAGE BODY PKG_PROGRESS_UTIL IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.08.2010 15:58:30
  -- Purpose : Указывает процент выполнения процесса
  PROCEDURE SET_PROGRESS_PERCENT
  (
    p_proc_name VARCHAR2
   ,p_doc_id    PLS_INTEGER
   ,p_progress  NUMBER
  ) IS
    proc_name VARCHAR2(25) := 'SET_PROGRESS_PERCENT';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  
    MERGE INTO progress_log pl
    USING (SELECT p_proc_name pn
                 ,p_doc_id pd
                 ,ROUND(p_progress, 2) progr
             FROM dual) P
    ON (p.pd = pl.proc_id AND p.pn = pl.proc_type_name)
    WHEN MATCHED THEN
      UPDATE SET pl.progress = p.progr
    WHEN NOT MATCHED THEN
      INSERT (pl.proc_id, pl.proc_type_name, pl.progress) VALUES (p.pd, p.pn, p.progr);
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END SET_PROGRESS_PERCENT;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.08.2010 16:01:04
  -- Purpose : Получает процент выполнения процесса
  FUNCTION GET_PROGRESS_PERCENT
  (
    p_proc_name VARCHAR2
   ,p_doc_id    PLS_INTEGER
  ) RETURN NUMBER IS
    v_progress NUMBER;
    proc_name  VARCHAR2(25) := 'GET_PROGRESS_PERCENT';
  BEGIN
  
    SELECT pl.progress
      INTO v_progress
      FROM progress_log pl
     WHERE pl.proc_type_name = p_proc_name
       AND pl.proc_id = p_doc_id;
  
    RETURN(v_progress);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END GET_PROGRESS_PERCENT;

BEGIN
  -- Initialization
  NULL; --<STATEMENT>;
END PKG_PROGRESS_UTIL;
/
