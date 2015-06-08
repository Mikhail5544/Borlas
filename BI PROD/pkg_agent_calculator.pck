CREATE OR REPLACE PACKAGE pkg_agent_calculator AS

  AG_ROLL_ID       NUMBER;
  JOB_ID           NUMBER;
  AgentPackageName VARCHAR2(255);

  PROCEDURE Calculate;

  PROCEDURE InsertInfo(p_notice NVARCHAR2);
  PROCEDURE InsertWarning(p_notice NVARCHAR2);
  PROCEDURE InsertError(p_notice NVARCHAR2);
  PROCEDURE ClearMessage;
  PROCEDURE InsertMessage
  (
    p_notice     NVARCHAR2
   ,p_type       NVARCHAR2
   ,p_ag_roll_id NUMBER
   ,p_job_id     NUMBER
  );
  PROCEDURE Progress
  (
    p_ag_roll_id NUMBER
   ,progress     NUMBER
  );
END pkg_agent_calculator;
/
CREATE OR REPLACE PACKAGE BODY pkg_agent_calculator AS

  PROCEDURE ClearMessage IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE DOCUMENT D SET D.NOTE = NULL WHERE D.DOCUMENT_ID = AG_ROLL_ID;
  
    COMMIT;
  
  END ClearMessage;

  PROCEDURE SetFinishDocument IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DOC.SET_DOC_STATUS(AG_ROLL_ID
                      ,'FINISH_CALCULATE'
                      ,SYSDATE
                      ,'AUTO'
                      ,'Автоматическое выставление статуса при расчете');
    COMMIT;
  END SetFinishDocument;

  PROCEDURE SetErrorDocument IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DOC.SET_DOC_STATUS(AG_ROLL_ID
                      ,'ERROR_CALCULATE'
                      ,SYSDATE
                      ,'AUTO'
                      ,'Автоматическое выставление статуса при расчете');
    COMMIT;
  END SetErrorDocument;

  PROCEDURE CallCalc IS
  BEGIN
  
    ClearMessage;
  
    InsertInfo('Начало калькуляции версии');
  
    EXECUTE IMMEDIATE 'BEGIN ' || AgentPackageName || '.Calc(:AG_ROLL_ID); END;'
      USING IN AG_ROLL_ID;
  
    --Проставляются флаги обновления DWH. --315708: элементы DWH комиссия
    UPDATE ins_dwh.meta_data dm
       SET dm.is_renew = 1
     WHERE dm.name_db_object IN ('fc_ag_commis_ksp_total', 'fc_ag_comiss_total','fc_ag_commis_det');
  
    InsertInfo('Успешное завершение калькуляции');
    SetFinishDocument;
    InsertInfo('Автоматическое выставление статуса при расчете');
    /* commit;
    SYS.DBMS_JOB.REMOVE(JOB_ID);*/
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      SetErrorDocument;
      InsertError(SQLERRM);
      InsertInfo('Аварийное завершение калькуляции');
      COMMIT;
      /*SYS.DBMS_JOB.REMOVE(JOB_ID);
      commit;*/
  END CallCalc;

  PROCEDURE Calculate IS
  BEGIN
    CallCalc;
  END Calculate;

  PROCEDURE InsertInfo(p_notice NVARCHAR2) IS
  BEGIN
    InsertMessage(p_notice, 'информация', AG_ROLL_ID, JOB_ID);
  END InsertInfo;

  PROCEDURE InsertWarning(p_notice NVARCHAR2) IS
  BEGIN
    InsertMessage(p_notice, 'внимание', AG_ROLL_ID, JOB_ID);
  END InsertWarning;

  PROCEDURE InsertError(p_notice NVARCHAR2) IS
  BEGIN
    InsertMessage(p_notice, 'ошибка', AG_ROLL_ID, JOB_ID);
  END InsertError;

  PROCEDURE Progress
  (
    p_ag_roll_id NUMBER
   ,progress     NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF progress = 0
    THEN
      UPDATE DOCUMENT D
         SET d.note = d.note || 'Выполнено   0%'
       WHERE D.DOCUMENT_ID = p_ag_roll_id;
    ELSE
      UPDATE DOCUMENT D
         SET d.note = substr(d.note, 1, LENGTH(d.note) - 7) || ' ' || to_char(progress, '999') || '%' ||
                      CHR(10)
       WHERE D.DOCUMENT_ID = p_ag_roll_id;
    END IF;
    COMMIT;
  END Progress;

  PROCEDURE InsertMessage
  (
    p_notice     NVARCHAR2
   ,p_type       NVARCHAR2
   ,p_ag_roll_id NUMBER
   ,p_job_id     NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE DOCUMENT D
       SET D.NOTE = D.NOTE || To_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS') || ' ' || p_type || ':' ||
                    p_notice || chr(10)
     WHERE D.DOCUMENT_ID = p_ag_roll_id;
    COMMIT;
  END InsertMessage;

END pkg_agent_calculator;
/
