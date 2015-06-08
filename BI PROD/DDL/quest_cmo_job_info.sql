create or replace force view quest_cmo_job_info as
select
   cj.job_id as job_id,
   jlh.job_history_id,
   cj.job_type_code,
   cj.method_type_code,
   db.database_id,
   db.database_label,
   jsp.interval as interval_length,
   jsp.schedule_id as schedule_id,
   decode(jsp.disable_start_date,null,'YES','NO') as enabled,
   case
    when cj.job_id is not null
     then 'QUEST_CMO_' || to_char (cj.job_id) || '_' || to_char (jsp.schedule_id)
    else null
   end as job_name,
   jsp.next_scheduled_run as next_run_date,
   jlh.status_type_code as last_status,
   jlh.start_time as last_run_date,
   jsp.frequency_type_code,
   case
    when cj.job_id is not null
     then quest_cmo_get_calendar_string (jsp.schedule_id,
             jsp.frequency_type_code, jsp.interval, jsp.run_window_begin)
     else null
   end as schedule_string,
   jsp.start_date,
   jsp.end_date,
   jsp.run_window_begin,
   jsp.run_window_end,
   jsp.max_duration
 from
   quest_cmo_databases db,
   quest_cmo_collection_job cj,
   (select
       lh.job_id, lh.job_history_id, jh.start_time, jh.status_type_code
     from quest_cmo_job_history jh, quest_cmo_coll_job_last_run lh
     where lh.job_history_id = jh.job_history_id
   ) jlh,
   (select
       js.start_date, js.end_date, js.frequency_type_code,
       js.run_window_begin, js.run_window_end, js.max_duration,
       js.interval, js.next_scheduled_run, jcs.job_id, jcs.schedule_id, jcs.disable_start_date
     from
       quest_cmo_coll_job_sched jcs,
       quest_cmo_job_schedule js
     where jcs.schedule_id = js.schedule_id
   ) jsp
 where
   db.database_id = cj.database_id (+)
   and cj.job_id = jsp.job_id (+)
   and cj.job_id = jlh.job_id (+);

