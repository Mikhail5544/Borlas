CREATE OR REPLACE PACKAGE Pkg_New_Date_Job IS

  PROCEDURE new_date;
  PROCEDURE start_job;
  PROCEDURE stop_job;

END Pkg_New_Date_Job;
/
CREATE OR REPLACE PACKAGE BODY Pkg_New_Date_Job IS

  v_job_code VARCHAR2(2000) := 'begin Pkg_new_date_job.new_date; commit; end;';

  PROCEDURE start_job IS
    c NUMBER;
  BEGIN
    FOR rc IN (SELECT job FROM user_jobs j WHERE j.what = v_job_code)
    LOOP
      dbms_output.put_line('job already run');
      RETURN;
    END LOOP;
  
    dbms_job.submit(c, v_job_code, SYSDATE, 'trunc(sysdate+1)+1/24/60');
    COMMIT;
  END;

  PROCEDURE stop_job IS
  BEGIN
    FOR rc IN (SELECT job FROM user_jobs j WHERE j.what = v_job_code)
    LOOP
      dbms_job.remove(rc.job);
      COMMIT;
    END LOOP;
  END;

  PROCEDURE set_paym_setoff_acc_topay;
  PROCEDURE write_status
  (
    p_session_id NUMBER
   ,p_obj_id     NUMBER
   ,p_status     NUMBER
   ,p_type       VARCHAR2 DEFAULT NULL
   ,p_err        VARCHAR2 DEFAULT NULL
  );

  PROCEDURE new_date IS
  BEGIN
    set_paym_setoff_acc_topay;
  END;

  PROCEDURE set_paym_setoff_acc_topay IS
    v_date   DATE;
    v_ses_id VARCHAR2(100) := TO_CHAR(SYSDATE, 'DDMMYYHHMMSS');
  BEGIN
    v_date := TRUNC(SYSDATE, 'DD');
    FOR acp IN (SELECT ap.PAYMENT_ID
                  FROM VEN_AC_PAYMENT ap
                      ,P_POLICY       p
                      ,DOC_DOC        dd
                      ,DOC_TEMPL      dt
                 WHERE dt.BRIEF IN ('PAYMENT_SETOFF_ACC')
                      -- AND   Doc.get_doc_status_brief(ap.payment_id,v_date) ='NEW'
                   AND Doc.get_last_doc_status_brief(ap.payment_id) = 'NEW'
                   AND ap.REG_DATE < v_date
                   AND dd.CHILD_ID = ap.PAYMENT_ID
                   AND dd.PARENT_ID = p.POLICY_ID
                   AND ap.DOC_TEMPL_ID = dt.DOC_TEMPL_ID)
    LOOP
      SAVEPOINT sp;
      BEGIN
        write_status(v_ses_id
                    ,acp.payment_id
                    ,0
                    ,'Распоряжение на возврат по счету');
        Doc.set_doc_status(acp.payment_id, 'TO_PAY', v_date);
        write_status(v_ses_id
                    ,acp.payment_id
                    ,1
                    ,'Распоряжение на возврат по счету');
      EXCEPTION
        WHEN OTHERS THEN
          write_status(v_ses_id
                      ,acp.payment_id
                      ,3
                      ,'Распоряжение на возврат по счету'
                      ,SQLERRM);
          ROLLBACK TO sp;
      END;
    END LOOP;
    COMMIT;
  END;

  PROCEDURE write_status
  (
    p_session_id NUMBER
   ,p_obj_id     NUMBER
   ,p_status     NUMBER
   ,p_type       VARCHAR2 DEFAULT NULL
   ,p_err        VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE new_date_job_log
       SET status = p_status
          ,ptype  = p_type
          ,err    = p_err
     WHERE obj_id = p_obj_id
       AND session_id = p_session_id;
    IF SQL%ROWCOUNT = 0
    THEN
      INSERT INTO new_date_job_log
        (ID, session_id, obj_id, status, ptype, err)
      VALUES
        (sq_new_date_job_log.NEXTVAL, p_session_id, p_obj_id, p_status, p_type, p_err);
    END IF;
    COMMIT;
  END;
END Pkg_New_Date_Job;
/
