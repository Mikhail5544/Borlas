CREATE OR REPLACE PACKAGE quest_cmo_job_synch IS
  PROCEDURE find(p_database_id NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_job_synch AS
  TYPE job_rec IS RECORD(
     JOB_ID              NUMBER
    ,JOB_HISTORY_ID      NUMBER
    ,DATABASE_ID         NUMBER
    ,CMO_DURATION        NUMBER
    ,CMO_LAST_START_DATE DATE
    ,CMO_NEXT_RUN_DATE   DATE
    ,CMO_STATUS          VARCHAR2(10)
    ,CMO_LAST_STATUS     VARCHAR2(10)
    ,ORA_LAST_STATUS     VARCHAR2(30)
    ,ORA_STATUS          VARCHAR2(15)
    ,ORA_NEXT_RUN_DATE   DATE
    , --TIMESTAMP WITH TIME ZONE,
    ORA_LAST_START_DATE DATE
    , -- TIMESTAMP(6) WITH TIME ZONE,
    ORACLE_JOB_NAME     VARCHAR2(30)
    ,ORA_SCHEDULE_TYPE   VARCHAR2(12)
    ,ORA_SCHEDULE_NAME   VARCHAR2(4000)
    ,ORA_SCHEDULE_LIMIT  INTERVAL DAY TO SECOND
    ,ORA_ENABLED         VARCHAR2(5)
    ,WIN_REPEAT_INTERVAL VARCHAR2(4000)
    ,WIN_NEXT_START_DATE DATE
    , -- TIMESTAMP WITH TIME ZONE,
    WIN_DURATION        INTERVAL DAY TO SECOND
    ,WIN_ENABLED         VARCHAR2(5));
  t_job              job_rec;
  dbms_compatibility VARCHAR2(100);
  db_version         VARCHAR2(100);

  --deleting current entries
  PROCEDURE delete_emergent
  (
    p_job_id      NUMBER
   ,p_database_id NUMBER
  ) IS
  
  BEGIN
    -- the first delete is necessary only if the there is no cascade on the FK
    DELETE FROM quest_cmo_emergent_issue_data
     WHERE emergent_issue_id IN
           (SELECT emergent_issue_id
              FROM QUEST_CMO_EMERGENT_ISSUE     i
                  ,QUEST_CMO_EMERGENT_ISSUE_MSG m
             WHERE i.associated_object_id = p_job_id
               AND i.database_id = p_database_id
               AND i.message_id = m.message_id
               AND m.message_code IN
                   ('NOCOLL', 'UNSCH-ORA', 'UNSCHED', 'WINEXP', 'ABRT', 'CANCL', 'SCHED-DISCR'));
  
    DELETE FROM QUEST_CMO_EMERGENT_ISSUE
     WHERE associated_object_id = p_job_id
       AND database_id = p_database_id
       AND message_id IN
           (SELECT message_id
              FROM QUEST_CMO_EMERGENT_ISSUE_MSG m
             WHERE m.message_code IN
                   ('NOCOLL', 'UNSCH-ORA', 'UNSCHED', 'WINEXP', 'ABRT', 'CANCL', 'SCHED-DISCR'));
  
  END delete_emergent;

  PROCEDURE check_discrepencies(ji job_rec) IS
    alert_code    VARCHAR2(20);
    n_msg_id      INTEGER;
    n_severity    INTEGER;
    issue_item_id NUMBER;
    no_coll_id    NUMBER;
    ora_sched_id  NUMBER;
    unsched_id    NUMBER;
    winexp_id     NUMBER;
    abort_id      NUMBER;
    cancel_id     NUMBER;
    synch_id      NUMBER;
  BEGIN
    delete_emergent(ji.job_id, ji.database_id);
    FOR c IN (SELECT MAX(decode(message_code, 'NOCOLL', message_id, 0)) AS no_coll_id
                    ,MAX(decode(message_code, 'UNSCH-ORA', message_id, 0)) AS ora_sched_id
                    ,MAX(decode(message_code, 'UNSCHED', message_id, 0)) AS unsched_id
                    ,MAX(decode(message_code, 'WINEXP', message_id, 0)) AS winexp_id
                    ,MAX(decode(message_code, 'ABRT', message_id, 0)) AS abort_id
                    ,MAX(decode(message_code, 'CANCL', message_id, 0)) AS cancel_id
                    ,MAX(decode(message_code, 'SCHED-DISCR', message_id, 0)) AS synch_id
                FROM QUEST_CMO_EMERGENT_ISSUE_MSG m
               WHERE m.message_code IN
                     ('NOCOLL', 'UNSCH-ORA', 'UNSCHED', 'WINEXP', 'ABRT', 'CANCL', 'SCHED-DISCR'))
    LOOP
      no_coll_id   := c.no_coll_id;
      ora_sched_id := c.ora_sched_id;
      unsched_id   := c.unsched_id;
      winexp_id    := c.winexp_id;
      abort_id     := c.abort_id;
      cancel_id    := c.cancel_id;
      synch_id     := c.synch_id;
    END LOOP;
    CASE
      WHEN ji.job_id IS NULL THEN
      
        alert_code := 'NO-COLL'; -- no collector specified for the DB
        n_msg_id   := no_coll_id;
      WHEN ji.oracle_job_name IS NULL
           AND ji.cmo_next_run_date IS NOT NULL THEN
        alert_code := 'UNSCH-ORA'; --  scheduled collecotr not in oracle queue
        n_msg_id   := ora_sched_id;
      WHEN ji.oracle_job_name IS NULL
           AND ji.cmo_next_run_date IS NULL THEN
        alert_code := 'UNSCHED'; ---job is unscheduled
        n_msg_id   := unsched_id;
      WHEN ji.cmo_last_status = 'WINEXP' THEN
        alert_code := 'WINEXP'; -- missed schedule window
        n_msg_id   := winexp_id;
      WHEN ji.cmo_last_status = 'ABRT' THEN
        alert_code := 'ABRT'; -- last run aborted
        n_msg_id   := abort_id;
      WHEN ji.cmo_last_status = 'CANCELED' THEN
        alert_code := 'CANCL'; -- last run canceled
        n_msg_id   := cancel_id;
      WHEN ji.cmo_next_run_date <> ji.ora_next_run_date THEN
        alert_code := 'SCHED-DISC'; -- schedule discrepency
        n_msg_id   := synch_id;
      ELSE
        RETURN;
    END CASE;
    n_severity := 2000;
  
    INSERT INTO QUEST_CMO_EMERGENT_ISSUE
      (database_id
      ,message_id
      ,severity_level
      ,message_type
      ,emergent_issue_date
      ,associated_object_id
      ,associated_object_type)
    VALUES
      (ji.database_id, n_msg_id, n_severity, 'MAINTENANCE', SYSDATE, ji.job_id, 'COLLECTION JOB')
    RETURNING emergent_issue_id INTO issue_item_id;
  
    IF n_msg_id IN (11, 16)
    THEN
      INSERT INTO quest_cmo_emergent_issue_data
        (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_char)
      VALUES
        ('ORA STATUS', issue_item_id, 'VC1000', ji.ora_status);
    
      INSERT INTO quest_cmo_emergent_issue_data
        (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_char)
      VALUES
        ('CMO STATUS', issue_item_id, 'VC1000', ji.cmo_last_status);
    
    END IF;
    INSERT INTO quest_cmo_emergent_issue_data
      (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_date)
    VALUES
      ('CMO NEXT DATE', issue_item_id, 'SECOND', ji.cmo_next_run_date);
  
    INSERT INTO quest_cmo_emergent_issue_data
      (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_date)
    VALUES
      ('ORA NEXT DATE', issue_item_id, 'SECOND', ji.ora_next_run_date);
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      COMMIT;
  END;

  PROCEDURE find(p_database_id NUMBER) IS
    str        VARCHAR2(4000);
    n_severity NUMBER;
    alert_code VARCHAR2(20);
    n_msg_id   NUMBER;
  
    TYPE rc IS REF CURSOR;
    lcur rc;
  BEGIN
  
    dbms_utility.db_version(db_version, dbms_compatibility);
    IF substr(db_version, 1, 1) = '1'
    THEN
      str := 'select cmo.job_id,
         cmo.job_history_id,
         cmo.database_id,
         Round(cmo.run_window_end - cmo.run_window_begin) * 1440 as cmo_duration,
         cmo.last_run_date,
         cmo.next_run_date as cmo_next_run_date ,
         null cmo_status,
         cmo.last_status as cmo_last_status,
         ora.last_status as ora_last_status,
         ora.state as ora_status ,
         to_date (to_char(ora.next_run_date, ''DD-MON-YYYY hh24:mi:ss''),''DD-MON-YYYY hh24:mi:ss'') as ora_next_run_date ,
         to_date(to_char(ora.last_start_date, ''DD-MON-YYYY hh24:mi:ss''),''DD-MON-YYYY hh24:mi:ss'') as ora_last_start_date,
         ora.job_name as oracle_job_name ,
         ora.schedule_type as ora_schedule_type ,
         ora.schedule_name as ora_schedule_name ,        
         ora.schedule_limit as ora_schedule_limit ,        
         ora.enabled as ora_enabled ,
         ora.win_repeat_interval as win_repeat_interval,
         ora.win_next_start_date as win_next_start_date,
         ora.win_duration as win_duration,
         ora.win_enabled as win_enabled        

         from         
         quest_cmo_job_info cmo,
           (select         
           job.job_name,        
           job.repeat_interval,        
           job.schedule_type,        
           job.schedule_name,        
           job.schedule_limit,        
           job.next_run_date,        
           job.enabled,
           job.state,
           job.last_start_date,
           win.start_date as win_start_date,
           win.repeat_interval as win_repeat_interval,
           win.next_start_date,job.next_run_date  as win_next_start_date,
           win.duration as win_duration,        
           win.enabled as win_enabled,
           (select status
                from all_scheduler_job_log
                where job_name = job.job_name
                and log_date = (select max(log_date) from all_scheduler_job_log where job_name = job.job_name ))
                as last_status
           from all_scheduler_windows win,  all_scheduler_jobs job
           where job.schedule_name = win.window_name(+)
           and job.job_name like         ''QUEST_CMO_%''
                ) ora
         where        
         ora.job_name(+) = ''QUEST_CMO_''||to_char(cmo.job_id)||''_''||to_char(cmo.schedule_id)';
    ELSE
      -- string for 9
      str := 'select cmo.job_id,
         cmo.job_history_id,
         cmo.database_id,
         Round(cmo.run_window_end - cmo.run_window_begin) * 1440 as cmo_duration,
         cmo.last_run_date,
         cmo.next_run_date as cmo_next_run_date ,
         null cmo_status,
         cmo.last_status as cmo_last_status,
         ora.last_status as ora_last_status,
         ora.state as ora_status ,
         to_date (to_char(ora.next_date, ''DD-MON-YYYY hh24:mi:ss''),''DD-MON-YYYY hh24:mi:ss'') as ora_next_run_date ,
         to_date(to_char(ora.last_date, ''DD-MON-YYYY hh24:mi:ss''),''DD-MON-YYYY hh24:mi:ss'') as ora_last_start_date,
         ora.job_name as oracle_job_name ,
         null  as ora_schedule_type ,
         null  as ora_schedule_name ,
         null  as ora_schedule_limit ,
         null as ora_enabled ,
         null as win_repeat_interval,
         null as win_next_start_date,
         null as win_duration,
         null as win_enabled
         from
         quest_cmo_job_info cmo,
           (select         
           SubStr(what,4,instr(what,''*/'') - 4) as job_name,
           null repeat_interval,
           null schedule_type,
           null schedule_name,
           null schedule_limit,
           job.next_date,
           null enabled,
           decode(jr.job,null,decode(job.next_date,null,''UNSCHEDULED'',''SCHEDULED''),''RUNNING'') state,
           job.last_date,
           decode(job.broken,''Y'',''BROKEN'',decode(job.last_date,null,null,''COMPLETED'')) as last_status
           from  dba_jobs job, dba_jobs_running jr
         where        
         jr.job (+) = job.job and job.what like ''/* QUEST_CMO_%'')ora
         where
         ora.job_name(+) = ''QUEST_CMO_''||to_char(cmo.job_id)||''_''||to_char(cmo.schedule_id)';
    
    END IF;
  
    IF p_database_id IS NOT NULL
    THEN
      str := str || 'and cmo.database_id  = ' || to_char(p_database_id);
    END IF;
    OPEN lcur FOR str;
    LOOP
      -- fetch lcur into cjob;
      FETCH lcur
        INTO t_job;
      IF lcur%NOTFOUND
      THEN
        EXIT;
      END IF;
      check_discrepencies(t_job);
    END LOOP;
    CLOSE lcur;
  
  END;

END;
/
