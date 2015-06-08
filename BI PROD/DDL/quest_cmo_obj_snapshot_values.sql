create or replace force view quest_cmo_obj_snapshot_values as
select
   o.database_id, o.capacity_object_id,
   o.owner, o.object_name, o.subname, t.object_type,
   t.object_subtype, o.container, s.snapshot_id,
   s.job_history_id, s.start_snapshot, s.end_snapshot,
   jh.start_time, jh.end_time,
   quest_cmo_general_purpose.convert_size
      (vu.snapshot_data_value_num, vu.value_unit, 'KB') as used,
   quest_cmo_general_purpose.convert_size
      (vh.snapshot_data_value_num, vh.value_unit, 'KB') as high_water_mark,
   quest_cmo_general_purpose.convert_size
      (va.snapshot_data_value_num, va.value_unit, 'KB') as allocated
 from
   quest_cmo_snapshot_data_value vu, quest_cmo_snapshot_data_value vh,
   quest_cmo_snapshot_data_value va,
   quest_cmo_object_snapshot s, quest_cmo_capacity_object o,
   quest_cmo_object_type t, quest_cmo_job_history jh
 where
   s.capacity_object_id = o.capacity_object_id
   and o.object_type_code = t.object_type_code
   and s.job_history_id = jh.job_history_id
   and vu.snapshot_id(+) = s.snapshot_id
   and vh.snapshot_id(+) = s.snapshot_id
   and va.snapshot_id(+) = s.snapshot_id
   and vu.snap_data_type(+) = 'USED'
   and vh.snap_data_type(+) = 'HWM'
   and va.snap_data_type(+) = 'ALLOC';

