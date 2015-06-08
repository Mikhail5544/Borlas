create or replace procedure quest_cmo_run_collection(p_database_id number,p_job_id in  number,  isCMOjob varchar2 default 'N', isRunNow varchar2 default 'N') is
   d_next_run_date timestamp with  time zone;
   s_database_label varchar2(100);
   this_job_history_id number;
   d_start_time date ;
   s_error_msg varchar2(300 byte);
   this_schedule_id number;
   s_step varchar2(100);
   e_failure_to_write exception;
   e_win_expired  exception;
   actual_end_time date;
   l_job_id number;
begin
    
    d_start_time := sysdate ;
    s_step := ' at initialization';
    IF p_job_id is null then
       for cjob in (select job_id from quest_cmo_collection_job
                     where database_id = p_database_id and rownum <2)
       loop
          l_job_id := cjob.job_id;
       end loop;
     else
       l_job_id := p_job_id;
     end if;
    begin
       insert into quest_cmo_job_history (job_id, start_time, status_type_code)
       values (l_job_id, d_start_time,'EXEC')
       returning job_history_id into this_job_history_id ;
       commit;
    exception when others then raise e_failure_to_write;
    end;
    select database_label into s_database_label from quest_cmo_databases where database_id = p_database_id;

    IF (isCMOJob = 'Y') and (isRunNow = 'N' )then
       for c in (select run_window_end, j.schedule_id
       from quest_cmo_coll_job_sched s,  quest_cmo_job_schedule j
       where s.job_id = p_job_id
       and s.schedule_id = j.schedule_id)
       loop
          this_schedule_id := c.schedule_id;
          if c.run_window_end is not null then
             actual_end_time := to_date(to_char(sysdate,'yyyy/mm/dd') ||' '|| to_char(c.run_window_end,'HH24:mi:ss'),'yyyy/mm/dd hh24:mi:ss');
          end if;
       end loop;
       IF actual_end_time < sysdate then
          raise e_win_expired;
       end if;
    END IF;
    s_step := ' at aggregator';
    quest_cmo_aggregator.datafile_aggregator
         (p_database_id ,
          this_job_history_id) ;
    s_step := ' at tbsp growth calc';
    quest_cmo_calc_growth.all_tbsp_regression(p_database_id);

    s_step := ' at datafile growth calc';
    quest_cmo_calc_growth.all_datafile_regression(p_database_id);
    s_step := ' at emergents';
    for c in (select 
              sum (decode ( preference_data_type, 'FAIL-DATE THRESH', preference_value_num,0)) fail_date_threshold,
              sum (decode ( preference_data_type, 'PCT-FREE THRESH', preference_value_num,0)) percent_free_threshold,
              sum (decode ( preference_data_type, 'TBSP-FULL THRESH', preference_value_num,0)) tbsp_full_threshold,
              sum (decode ( preference_data_type, 'FAIL-CRITICAL THRESH', preference_value_num,0)) fail_critical_threshold,
              sum (decode ( preference_data_type, 'NO-FAIL THRESH', preference_value_num,0)) no_fail_date_threshold 
              from
              quest_cmo_preference_data d,
              quest_cmo_preference_set s,
              quest_cmo_preference_set_xref x,
              quest_cmo_preferences p
              where s.preference_set_name = 'EMERGENT ISSUE THRESHOLDS'
              and d.preference_set_id = s.preference_set_id
              and p.preference_name = 'DEFAULT SYSTEM-WIDE'
              and p.preference_id = x.preference_id
              and s.preference_set_id = x.preference_set_id
              and preference_data_type in ( 'FAIL-DATE THRESH', 'PCT-FREE THRESH', 'TBSP-FULL THRESH', 'FAIL-CRITICAL THRESH',  'NO-FAIL THRESH') )
      loop
         quest_cmo_emergents.find_dbfile_alerts (p_database_id => p_database_id,
                       p_pct_threshold => c.percent_free_threshold,
                       p_next_fail_threshold => c.fail_date_threshold,
                       p_max_fail_threshold => c.no_fail_date_threshold,
                       p_tbsp_full_threshold => c.tbsp_full_threshold,
                       p_critical_fail_date => c.fail_critical_threshold) ;
      end loop;
    s_step := ' at finalization';
      if  isCMOjob = 'N' then
         update quest_cmo_job_history
            set status_type_code = 'COMP',
            end_time = sysdate 
            where job_history_id =  this_job_history_id;
      else
            if quest_cmo_schedule_util.oracle_version = 9 then
               d_next_run_date := quest_cmo_schedule_util.get_next_start_date(p_job_id);
            else
               quest_cmo_schedule_util.get_next_start_date(p_job_id, this_schedule_id , d_next_run_date);
            end if;
            update quest_cmo_job_history
            set status_type_code = 'COMP',
            end_time = sysdate
            where job_history_id = this_job_history_id;

            update quest_cmo_job_schedule
            set next_scheduled_run = d_next_run_date
            where schedule_id = this_schedule_id;
  

      end if;
      commit;
      return ;
EXCEPTION
   when e_failure_to_write then raise;
   when e_win_expired then
      update quest_cmo_job_history
      set status_type_code = 'WINEXP',
      end_time = null 
      where job_history_id = this_job_history_id;
   when others then
   begin
      s_error_msg :=  substrb(SQLERRM,1,200) || s_step;
      if sqlcode = -1013 then
         update quest_cmo_job_history
         set status_type_code = 'CANCL',
         end_time = sysdate,
         JOB_ERROR_LONG_DESCRIPTION = 'Canceled by user'
         where job_history_id = this_job_history_id;
      else
         update quest_cmo_job_history
         set status_type_code = 'ABRT',
         end_time = sysdate,
         JOB_ERROR_LONG_DESCRIPTION = s_error_msg
         where job_history_id = this_job_history_id;
       end if;
      
      IF isCMOjob = 'Y' then

         if quest_cmo_schedule_util.oracle_version = 9 then
            d_next_run_date := quest_cmo_schedule_util.get_next_start_date(p_job_id);
         else
            quest_cmo_schedule_util.get_next_start_date(p_job_id, this_schedule_id , d_next_run_date);
         end if;

         update quest_cmo_job_schedule
         set next_scheduled_run = d_next_run_date
         where schedule_id = this_schedule_id;
      end if;
    commit;
   end;
end quest_cmo_run_collection;
/

