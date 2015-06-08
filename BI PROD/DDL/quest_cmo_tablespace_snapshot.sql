create or replace force view quest_cmo_tablespace_snapshot as
select
   o.database_id,
   o.capacity_object_id as tbsp_capacity_object_id,
   o.object_name as tablespace_name,
   t.object_type as tbsp_type,
   t.object_subtype as tbsp_subtype,
   vts.snapshot_data_value_char as tbsp_status,
   s.snapshot_id, s.job_history_id,
   s.start_snapshot, s.end_snapshot,
   jh.start_time, jh.end_time
 from
    quest_cmo_capacity_object o, quest_cmo_object_type t,
    quest_cmo_object_snapshot s, quest_cmo_job_history jh,
    quest_cmo_snapshot_data_value vts
 where
   o.object_type_code = t.object_type_code
   and t.object_type = 'TABLESPACE'
   and s.capacity_object_id = o.capacity_object_id
   and jh.job_history_id = s.job_history_id
   and vts.snapshot_id(+) = s.snapshot_id
   and vts.snap_data_type(+) = 'TBSP STATUS';

