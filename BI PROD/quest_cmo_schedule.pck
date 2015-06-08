CREATE OR REPLACE PACKAGE quest_cmo_schedule AS
  PROCEDURE create_df_program;
  PROCEDURE submit_job(p_job_id NUMBER);
  PROCEDURE submit_DF_job(p_job_id NUMBER);
  PROCEDURE reschedule_job(p_job_id NUMBER);
  PROCEDURE unschedule_job(p_job_id NUMBER);
  PROCEDURE disable_job(p_job_id NUMBER);
  PROCEDURE enable_job(p_job_id NUMBER);
  PROCEDURE start_job
  (
    p_job_id      NUMBER
   ,p_schedule_id NUMBER
  );
END;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_schedule AS

  TYPE job_info_typ IS RECORD(
     job_name        VARCHAR2(30)
    ,job_type_code   quest_cmo_job_info.job_type_code%TYPE
    ,database_id     quest_cmo_job_info.database_id%TYPE
    ,database_label  quest_cmo_job_info.database_label%TYPE
    ,start_date      quest_cmo_job_info.start_date%TYPE
    ,schedule_string VARCHAR2(2000)
    ,schedule_type   VARCHAR2(10)
    ,schedule_id     quest_cmo_job_info.schedule_id%TYPE
    ,duration        NUMBER);

  PROCEDURE get_job_properties
  (
    p_job_id NUMBER
   ,job_prop OUT job_info_typ
  ) IS
  
  BEGIN
    FOR c IN (SELECT job_name
                    ,job_type_code
                    ,database_id
                    ,database_label
                    ,schedule_id
                    ,start_date
                    ,ROUND((end_date - start_date) * 1440) AS schedule_window_length
                    ,schedule_string
                    ,decode(SubStr(frequency_type_code, 1, 1)
                           ,'D'
                           ,'DAILY'
                           ,'W'
                           ,'WEEKLY'
                           ,'M'
                           ,'MONTHLY') schedule_type
                    ,run_window_begin
                    ,ROUND((run_window_end - run_window_begin) * 1440) AS run_window_length
                    ,job_history_id
                FROM quest_cmo_job_info
               WHERE job_id = p_job_id)
    LOOP
      job_prop.job_name        := c.job_name;
      job_prop.job_type_code   := c.job_type_code;
      job_prop.database_id     := c.database_id;
      job_prop.database_label  := c.database_label;
      job_prop.start_date      := c.start_date;
      job_prop.schedule_string := c.schedule_string;
      job_prop.schedule_type   := c.schedule_type;
      job_prop.schedule_id     := c.schedule_id;
      job_prop.duration        := c.run_window_length;
    
    END LOOP;
  END;

  PROCEDURE unschedule_job(p_job_id NUMBER) IS
    jp job_info_typ;
  
  BEGIN
    get_job_properties(p_job_id, jp);
    dbms_scheduler.Drop_job(jp.job_name);
  
    --update  quest_cmo_job_schedule
    --set NEXT_SCHEDULED_RUN = null
    -- where schedule_id = jp.schedule_id;
    UPDATE quest_cmo_collection_job SET method_type_code = NULL WHERE job_id = p_job_id;
    COMMIT;
  END;

  FUNCTION check_program_existence RETURN BOOLEAN IS
    prog_exist BOOLEAN;
  BEGIN
    FOR c IN (SELECT COUNT(*) programs
                FROM dba_scheduler_programs
               WHERE program_name = 'QUEST_CMO_DF_COLLECTION')
    LOOP
      prog_exist := c.programs > 0;
    END LOOP;
    RETURN prog_exist;
  END;

  --changes oracle schedule property  of anexisiting collection job.
  --uses the schedule in CMO schedule tables
  PROCEDURE reschedule_job(p_job_id NUMBER) IS
    jp              job_info_typ;
    d_next_run_date TIMESTAMP WITH TIME ZONE;
  BEGIN
  
    IF check_program_existence = FALSE
    THEN
      create_df_program;
    END IF;
  
    FOR c IN (SELECT COUNT(*) jobs FROM dba_scheduler_jobs WHERE job_name = jp.job_name)
    LOOP
      IF c.jobs = 0
      THEN
        submit_df_job(p_job_id);
        RETURN;
      END IF;
    END LOOP;
    get_job_properties(p_job_id, jp);
    IF jp.schedule_type NOT IN ('W', 'S')
    THEN
      -- predifined window or schedule, currently not implemented
      BEGIN
        DBMS_SCHEDULER.EVALUATE_CALENDAR_STRING(start_date        => jp.start_date
                                               ,calendar_string   => jp.schedule_string
                                               ,return_date_after => systimestamp
                                               ,next_run_date     => d_next_run_date);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20009, 'Validation of the schedule failed');
      END;
      DBMS_SCHEDULER.SET_ATTRIBUTE(jp.job_name, 'start_date', jp.start_date);
      DBMS_SCHEDULER.SET_ATTRIBUTE(jp.job_name, 'calendar_string', jp.schedule_string);
      --  DBMS_SCHEDULER.SET_ATTRIBUTE( jp.job_name, attribute => 'schedule_limit',
      --                                            value => numtodsinterval(jp.duration, 'minute'));
      UPDATE quest_cmo_job_schedule
         SET next_scheduled_run = d_next_run_date
       WHERE schedule_id = jp.schedule_id;
      COMMIT;
    END IF;
  END reschedule_job;

  PROCEDURE create_df_program IS
  BEGIN
    DBMS_SCHEDULER.CREATE_PROGRAM(program_name        => 'QUEST_CMO_DF_COLLECTION'
                                 ,program_type        => 'STORED_PROCEDURE'
                                 ,program_action      => 'quest_cmo_run_collection'
                                 ,number_of_arguments => 3
                                 ,enabled             => FALSE
                                 ,comments            => 'n');
  
    DBMS_SCHEDULER.define_program_argument(program_name      => 'QUEST_CMO_DF_COLLECTION'
                                          ,argument_position => 1
                                          ,argument_name     => 'p_database_id'
                                          ,argument_type     => 'number'
                                          ,out_argument      => FALSE);
  
    DBMS_SCHEDULER.define_program_argument(program_name      => 'QUEST_CMO_DF_COLLECTION'
                                          ,argument_position => 2
                                          ,argument_name     => 'p_job_id'
                                          ,argument_type     => 'number'
                                          ,out_argument      => FALSE);
  
    DBMS_SCHEDULER.define_program_argument(program_name      => 'QUEST_CMO_DF_COLLECTION'
                                          ,argument_position => 3
                                          ,argument_name     => 'isCMOjob'
                                          ,argument_type     => 'VARCHAR2'
                                          ,out_argument      => FALSE);
    DBMS_SCHEDULER.ENABLE(NAME => 'QUEST_CMO_DF_COLLECTION');
  END create_df_program;

  PROCEDURE submit_job(p_job_id NUMBER) IS
    jp job_info_typ;
  BEGIN
    get_job_properties(p_job_id, jp);
  
    IF check_program_existence = FALSE
    THEN
      create_df_program;
    END IF;
    IF jp.job_type_code = 'COLL-DBFILE'
    THEN
      FOR c IN (SELECT j.job_name
                  FROM user_scheduler_jobs j
                 WHERE job_name LIKE 'QUEST_CMO_' || to_char(p_job_id) || '_%')
      LOOP
        dbms_scheduler.drop_job(c.job_name);
      
        UPDATE quest_cmo_coll_job_sched
           SET disable_start_date = NULL
              ,disable_end_date   = NULL
         WHERE job_id = p_job_id
           AND schedule_id = jp.schedule_id;
      
        UPDATE quest_cmo_collection_job SET method_type_code = NULL WHERE job_id = p_job_id;
      
        COMMIT;
      END LOOP;
      submit_DF_job(p_job_id);
    END IF;
  END;

  PROCEDURE submit_DF_job(p_job_id NUMBER) IS
    jp job_info_typ;
  BEGIN
    get_job_properties(p_job_id, jp);
    IF jp.schedule_type IN ('S', 'W')
    THEN
      DBMS_SCHEDULER.CREATE_JOB(job_name      => jp.job_name
                               ,program_name  => 'QUEST_CMO_DF_COLLECTION'
                               ,schedule_name => jp.schedule_string
                               ,enabled       => FALSE
                               ,comments      => 'datafile collection for database ' ||
                                                 jp.database_label);
    ELSE
      --inline schedule
      DBMS_SCHEDULER.CREATE_JOB(job_name        => jp.job_name
                               ,program_name    => 'QUEST_CMO_DF_COLLECTION'
                               ,repeat_interval => jp.schedule_string
                               ,start_date      => jp.start_date
                               ,enabled         => FALSE
                               ,comments        => 'datafile collection for database_id ' ||
                                                   jp.database_label);
      --      IF jp.duration is not null then
      --         dbms_scheduler.set_attribute( name =>  jp.job_name,
      --                                       attribute => 'schedule_limit',
      --                                       value => numtodsinterval(jp.duration, 'minute'));
      --     END IF;
    END IF;
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(job_name          => jp.job_name
                                         ,argument_position => 1
                                         ,argument_value    => jp.database_id);
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(job_name          => jp.job_name
                                         ,argument_position => 2
                                         ,argument_value    => p_job_id);
  
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(job_name          => jp.job_name
                                         ,argument_position => 3
                                         ,argument_value    => 'Y');
    DBMS_SCHEDULER.ENABLE(NAME => jp.job_name);
    UPDATE quest_cmo_job_schedule
       SET next_scheduled_run =
           (SELECT next_run_date FROM dba_scheduler_jobs WHERE job_name = jp.job_name)
     WHERE schedule_id = jp.schedule_id;
    UPDATE quest_cmo_collection_job SET method_type_code = 'ORA-SCHED' WHERE job_id = p_job_id;
    COMMIT;
    --returning job_id_history into i_job_id_history;
  END submit_df_job;

  PROCEDURE disable_job(p_job_id NUMBER) IS
    i INTEGER := 0;
  BEGIN
    FOR c IN (SELECT schedule_id
                    ,ora.job_name
                FROM quest_cmo_coll_job_sched s
                    ,dba_scheduler_jobs       ora
               WHERE s.job_id = p_job_id
                 AND ora.job_name LIKE
                     'QUEST\_CMO\_' || to_char(s.job_id) || '\_' || to_char(s.schedule_id) ESCAPE '\')
    LOOP
      i := 1;
      dbms_scheduler.disable(c.job_name);
    END LOOP;
    UPDATE quest_cmo_coll_job_sched SET disable_start_date = SYSDATE WHERE job_id = p_job_id;
    COMMIT;
  END;

  PROCEDURE enable_job(p_job_id NUMBER) IS
    i INTEGER := 0;
  BEGIN
    FOR c IN (SELECT schedule_id
                    ,ora.job_name
                FROM quest_cmo_coll_job_sched s
                    ,dba_scheduler_jobs       ora
               WHERE s.job_id = p_job_id
                 AND ora.job_name LIKE
                     'QUEST\_CMO\_' || to_char(s.job_id) || '\_' || to_char(s.schedule_id) ESCAPE '\')
    LOOP
      i := 1;
      dbms_scheduler.enable(c.job_name);
    END LOOP;
    UPDATE quest_cmo_coll_job_sched SET disable_start_date = NULL WHERE job_id = p_job_id;
    COMMIT;
  END;

  PROCEDURE start_job
  (
    p_job_id      NUMBER
   ,p_schedule_id NUMBER
  ) IS
  BEGIN
    FOR c IN (SELECT database_id
                    ,method_type_code
                FROM quest_cmo_collection_job
               WHERE job_id = p_job_id
                 AND rownum < 2)
    LOOP
      IF Upper(c.method_type_code) = 'EXTERNAL'
      THEN
        quest_cmo_run_collection(c.database_id, NULL);
      ELSE
        dbms_scheduler.run_job('QUEST_CMO_' || p_job_id || '_' || p_schedule_id);
      END IF;
    END LOOP;
  
  END;
END;
/
