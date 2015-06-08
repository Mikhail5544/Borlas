CREATE OR REPLACE PACKAGE quest_cmo_schedule_util IS
  oracle_version NUMBER := 10;
  TYPE t_ref_cursor IS REF CURSOR;
  FUNCTION get_next_start_date(p_job_id INTEGER) RETURN DATE; -- for version 9 compatibily
  PROCEDURE get_next_start_date
  (
    p_job_id        NUMBER
   ,p_schedule_id   OUT NUMBER
   ,p_next_run_date OUT TIMESTAMP WITH TIME ZONE
  );
  FUNCTION description_by_job_id(p_job_id NUMBER) RETURN VARCHAR2;

  FUNCTION description_by_schedule_id(p_schedule_id NUMBER) RETURN VARCHAR2;
  PROCEDURE get_job_schedule
  (
    tref          OUT t_ref_cursor
   ,p_database_id NUMBER DEFAULT NULL
   ,p_job_id      NUMBER DEFAULT NULL
   ,p_schedule_id NUMBER DEFAULT NULL
   ,p_overview    BOOLEAN DEFAULT FALSE
  );
  PROCEDURE check_aborted;
END;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_schedule_util IS

  PROCEDURE get_next_start_date
  (
    p_job_id        NUMBER
   ,p_schedule_id   OUT NUMBER
   ,p_next_run_date OUT TIMESTAMP WITH TIME ZONE
  ) IS
  BEGIN
    FOR c IN (SELECT c.start_date
                    ,c.schedule_string
                    ,c.last_run_date
                    ,c.schedule_id
                FROM quest_cmo_job_info c
               WHERE job_id = p_job_id)
    LOOP
    
      p_schedule_id := c.schedule_id;
      DBMS_SCHEDULER.EVALUATE_CALENDAR_STRING(start_date        => c.start_date
                                             ,calendar_string   => c.schedule_string
                                             ,return_date_after => systimestamp
                                             ,next_run_date     => p_next_run_date);
    
    END LOOP;
  
  END;

  FUNCTION get_month_day_week_string
  (
    p_schedule_id NUMBER
   ,p_day_type    VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 AS
    day_str VARCHAR2(120);
  BEGIN
    FOR c2 IN (SELECT day_of_week
                     ,week_of_month
                 FROM quest_cmo_schedule_run_days d
                WHERE schedule_id = p_schedule_id
                ORDER BY week_of_month
                        ,day_of_week)
    LOOP
      day_str := day_str || CASE c2.week_of_month
                   WHEN 5 THEN
                    'last '
                   WHEN 1 THEN
                    '1st '
                   WHEN 2 THEN
                    '2nd '
                   WHEN 3 THEN
                    '3rd '
                   WHEN 4 THEN
                    '4th '
                 END;
      IF p_day_type IS NULL
      THEN
        day_str := day_str || CASE c2.day_of_week
                     WHEN 1 THEN
                      'Monday' || ', '
                     WHEN 2 THEN
                      'Tuesday' || ', '
                     WHEN 3 THEN
                      'Wednesday' || ', '
                     WHEN 4 THEN
                      'Thursday' || ', '
                     WHEN 5 THEN
                      'Friday' || ', '
                     WHEN 6 THEN
                      'Saturday' || ', '
                     WHEN 7 THEN
                      'Sunday' || ', '
                   END;
      END IF;
    END LOOP;
    IF p_day_type IS NOT NULL
    THEN
      day_str := day_str || ' ' || p_day_type || ' of the month';
    END IF;
    RETURN day_str;
  END;

  FUNCTION get_next_start_date(p_job_id INTEGER) RETURN DATE IS
  BEGIN
    RETURN NULL;
  END;

  FUNCTION get_day_of_month_string(p_schedule_id NUMBER) RETURN VARCHAR2 AS
    day_str VARCHAR2(120);
  BEGIN
    FOR c2 IN (SELECT day_of_month
                 FROM quest_cmo_schedule_run_days
                WHERE schedule_id = p_schedule_id
                ORDER BY day_of_month)
    LOOP
      day_str := day_str || CASE c2.day_of_month
                   WHEN 32 THEN
                    'last day' || ', '
                   WHEN 1 THEN
                    '1st' || ', '
                   WHEN 21 THEN
                    '21st' || ', '
                   WHEN 31 THEN
                    '31st' || ', '
                   WHEN 2 THEN
                    '2nd' || ', '
                   WHEN 22 THEN
                    '22nd' || ', '
                   ELSE
                    to_char(c2.day_of_month) || 'th' || ', '
                 END;
    END LOOP;
    RETURN day_str;
  END;

  FUNCTION get_day_of_week_string(p_schedule_id NUMBER) RETURN VARCHAR2 AS
    day_str VARCHAR2(120);
  BEGIN
    FOR c2 IN (SELECT day_of_week
                 FROM quest_cmo_schedule_run_days d
                WHERE schedule_id = p_schedule_id
                ORDER BY week_of_month)
    LOOP
      day_str := day_str || CASE c2.day_of_week
                   WHEN 1 THEN
                    'Monday' || ', '
                   WHEN 2 THEN
                    'Tuesday' || ', '
                   WHEN 3 THEN
                    'Wednesday' || ', '
                   WHEN 4 THEN
                    'Thursday' || ', '
                   WHEN 5 THEN
                    'Friday' || ', '
                   WHEN 6 THEN
                    'Saturday' || ', '
                   WHEN 7 THEN
                    'Sunday' || ', '
                 END;
    
    END LOOP;
  
    RETURN day_str;
  END;

  FUNCTION description_by_job_id(p_job_id NUMBER) RETURN VARCHAR2 IS
    str VARCHAR2(1000);
  BEGIN
    FOR c3 IN (SELECT schedule_id FROM quest_cmo_coll_job_sched j WHERE j.job_id = p_job_id)
    LOOP
      str := description_by_schedule_id(c3.schedule_id);
    END LOOP;
    RETURN str;
  END description_by_job_id;

  FUNCTION description_by_schedule_id(p_schedule_id NUMBER) RETURN VARCHAR2 IS
    str VARCHAR2(500);
  BEGIN
    FOR c1 IN (SELECT frequency_type_code
                     ,INTERVAL
                     ,run_window_begin
                     ,schedule_id
                 FROM quest_cmo_job_schedule s
                WHERE s.schedule_id = p_schedule_id)
    LOOP
      CASE
        WHEN c1.frequency_type_code = 'MONTH-DTOM' THEN
          str := 'Every ' || to_char(c1.interval) || ' month(s) on the  ' ||
                 get_day_of_month_string(c1.schedule_id);
        WHEN c1.frequency_type_code = 'MONTH-DOW' THEN
          str := 'Every ' || to_char(c1.interval) || ' month(s) on the ' ||
                 get_month_day_week_string(c1.schedule_id);
        WHEN c1.frequency_type_code LIKE 'DAY%' THEN
          str := 'Every ' || to_char(c1.interval) || ' day(s)';
        WHEN c1.frequency_type_code = 'WEEK-FIXED' THEN
          str := 'Every ' || to_char(c1.interval) || ' week(s)';
        WHEN c1.frequency_type_code = 'WEEK-DOW' THEN
          str := 'Every ' || to_char(c1.interval) || ' week(s) on ' ||
                 get_day_of_week_string(c1.schedule_id);
        WHEN c1.frequency_type_code = 'MONTH-WKDAY' THEN
          str := 'Every ' || to_char(c1.interval) || ' month(s) on ' ||
                 get_month_day_week_string(c1.schedule_id, 'weekday');
        WHEN c1.frequency_type_code = 'MONTH-WKEND' THEN
          str := 'Every ' || to_char(c1.interval) || ' month(s) on ' ||
                 get_month_day_week_string(c1.schedule_id, 'weekend day');
        
      END CASE;
      str := str || ' at ' || to_char(c1.run_window_begin, 'HH:MI AM', 'nls_date_language = english');
    END LOOP;
    RETURN str;
  END description_by_schedule_id;

  PROCEDURE get_job_schedule
  (
    tref          OUT t_ref_cursor
   ,p_database_id NUMBER DEFAULT NULL
   ,p_job_id      NUMBER DEFAULT NULL
   ,p_schedule_id NUMBER DEFAULT NULL
   ,p_overview    BOOLEAN DEFAULT FALSE
  ) IS
  
    str VARCHAR2(4000);
  BEGIN
    check_aborted;
    str := 'select job_id,
         job_history_id,
         method_type_code,
         database_id,
         database_label,
         interval_length,
         schedule_id,
         cmo.next_run_date,
         case nvl(method_type_code,''-1'')
            when ''EXTERNAL''  then 0
            when ''-1'' then 1
            else
               case
                  when   cmo.enabled = ''NO'' then 3
                  when cmo.method_type_code is null then 1
                  when ora.enabled = ''FALSE'' and cmo.ENABLED = ''YES'' then 2
                  else
                     case
                        when decode(cmo.next_run_date,null ,- 1,0) = -1 then   1
                        when cmo.next_run_date < sysdate then 2
                        when decode(ora.next_run_date,null ,- 1,0) = -1 then   1
                        else
                           case
                              when  abs(to_date (to_char(ora.next_run_date,''yyyy/mm/dd hh24:mi:ss''),''yyyy/mm/dd hh24:mi:ss'') -
                                       to_date (to_char(cmo.next_run_date,''yyyy/mm/dd hh24:mi:ss''),''yyyy/mm/dd hh24:mi:ss'') ) > .01
                                           then 2
                              when    abs(to_date (to_char(ora.next_run_date,''yyyy/mm/dd hh24:mi:ss''),''yyyy/mm/dd hh24:mi:ss'') -
                                       to_date (to_char(cmo.next_run_date,''yyyy/mm/dd hh24:mi:ss''),''yyyy/mm/dd hh24:mi:ss'') ) < .01
                                           then 4
                               else 2
                           end
                     end
               end
         end as current_status,
         case last_status
            when ''ABRT'' then 1
            when ''WINEXP'' then 2
            when ''RUNEXP'' then 3
            when ''CANCL'' then 4
            when ''EXEC'' then 5
            when ''COMP'' then 6
         end  as last_status,
         last_run_date,
         frequency_type_code,     ';
    IF p_overview
    THEN
      str := str || '              ora.next_run_date oracle_next_date, ';
    ELSE
      str := str || '       quest_cmo_schedule_util.description_by_schedule_id(schedule_id) ,';
    END IF;
    str := str ||
           '         cmo.start_date,
         cmo.end_date,
         run_window_begin,
         run_window_end,
         max_duration
        from quest_cmo_job_info cmo,  dba_scheduler_jobs ora
        where ora.job_name(+) = ''QUEST_CMO_'' || cmo.job_id ||''_'' || cmo.schedule_id';
  
    IF p_database_id IS NOT NULL
    THEN
      str := str || '  and database_id = ' || to_char(p_database_id);
    END IF;
    IF p_job_id IS NOT NULL
    THEN
      str := str || '  and job_id = ' || to_char(p_job_id);
    END IF;
    IF p_schedule_id IS NOT NULL
    THEN
      str := str || ' and schedule_id = ' || to_char(p_schedule_id);
    END IF;
    IF p_overview
    THEN
      str := 'select * from (' || str ||
             ' ) where last_status in (1,2,3,4) or current_status in (1,2)';
    END IF;
    OPEN tref FOR str;
  END;
  PROCEDURE check_aborted IS
  BEGIN
    FOR c IN (SELECT job_id
                    ,schedule_id
                    ,job_history_id
                    ,ora.job_name
                FROM quest_cmo_job_info cmo
                    ,(SELECT job_name
                        FROM dba_scheduler_jobs ora
                       WHERE job_name || '.' || owner NOT IN
                             (SELECT job_name || '.' || owner FROM dba_scheduler_running_jobs jr)) ora
               WHERE ora.job_name LIKE '/* QUEST_CMO_' || to_char(cmo.job_id) || '_' ||
                     to_char(nvl(cmo.schedule_id, -1)) || '*/%'
                 AND method_type_code <> 'EXTERNAL'
                 AND last_status = 'EXEC')
    LOOP
      UPDATE quest_cmo_job_history
         SET STATUS_TYPE_CODE           = 'ABRT'
            ,JOB_ERROR_LONG_DESCRIPTION = 'Unknown'
       WHERE job_history_id = c.job_history_id
         AND STATUS_TYPE_CODE = 'EXEC';
    END LOOP;
    COMMIT;
  END;

END;
/
