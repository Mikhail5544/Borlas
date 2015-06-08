create or replace force view quest_cmo_datafile_snapshot as
select
   o.database_id,
   o.capacity_object_id as df_capacity_object_id,
   o.object_name as file_name,
   quest_cmo_general_purpose.extract_file_name (o.object_name) as short_file_name,
   t.object_type as df_type,
   t.object_subtype as df_subtype,
   o2.capacity_object_id as tbsp_capacity_object_id,
   o2.object_name as tablespace_name,
   t2.object_type as tbsp_type,
   t2.object_subtype as tbsp_subtype,
   vts.snapshot_data_value_char as tbsp_status,
   s.snapshot_id, s.job_history_id,
   s.start_snapshot, s.end_snapshot,
   jh.start_time, jh.end_time,
   quest_cmo_general_purpose.convert_size
      (vt.snapshot_data_value_num, vt.value_unit, 'KB') as total_amt,
   quest_cmo_general_purpose.convert_size
      (vu.snapshot_data_value_num, vu.value_unit, 'KB') as usable_amt,
   quest_cmo_general_purpose.convert_size
      (va.snapshot_data_value_num, va.value_unit, 'KB') as allocated_amt,
   quest_cmo_general_purpose.convert_size
      (vf.snapshot_data_value_num, vf.value_unit, 'KB') as free_amt,
   quest_cmo_general_purpose.convert_size
      (vhbn.snapshot_data_value_num, vhbn.value_unit, 'KB') as high_block_number,
   quest_cmo_general_purpose.convert_size
      (vd.snapshot_data_value_num, vd.value_unit, 'KB') as data_amt,
   quest_cmo_general_purpose.convert_size
      (vi.snapshot_data_value_num, vi.value_unit, 'KB') as indx_amt,
   quest_cmo_general_purpose.convert_size
      (vun.snapshot_data_value_num, vun.value_unit, 'KB') as undo_amt,
   quest_cmo_general_purpose.convert_size
      (vtmp.snapshot_data_value_num, vtmp.value_unit, 'KB') as temp_amt,
   quest_cmo_general_purpose.convert_size
      (vo.snapshot_data_value_num, vo.value_unit, 'KB') as other_amt
 from
   quest_cmo_capacity_object o, quest_cmo_object_type t,
   quest_cmo_capacity_object o2, quest_cmo_object_type t2,
   quest_cmo_object_snapshot s, quest_cmo_job_history jh,
   quest_cmo_snapshot_data_value vt, quest_cmo_snapshot_data_value vu,
   quest_cmo_snapshot_data_value va, quest_cmo_snapshot_data_value vf,
   quest_cmo_snapshot_data_value vhbn, quest_cmo_snapshot_data_value vd,
   quest_cmo_snapshot_data_value vi, quest_cmo_snapshot_data_value vun,
   quest_cmo_snapshot_data_value vtmp, quest_cmo_snapshot_data_value vo,
   quest_cmo_object_snapshot s2, quest_cmo_snapshot_data_value vts
 where
   o.object_type_code = t.object_type_code
   and t.object_type in ('DATAFILE', 'TEMPFILE')
   and o.container = o2.capacity_object_id
   and o2.object_type_code = t2.object_type_code
   and s.capacity_object_id = o.capacity_object_id
   and jh.job_history_id = s.job_history_id
   and vt.snapshot_id(+) = s.snapshot_id
   and vt.snap_data_type(+) = 'ALLOC'
   and vu.snapshot_id(+) = s.snapshot_id
   and vu.snap_data_type(+) = 'USABLE'
   and va.snapshot_id(+) = s.snapshot_id
   and va.snap_data_type(+) = 'USED'
   and vf.snapshot_id(+) = s.snapshot_id
   and vf.snap_data_type(+) = 'DF FREE'
   and vhbn.snapshot_id(+) = s.snapshot_id
   and vhbn.snap_data_type(+) = 'HWM'
   and vd.snapshot_id(+) = s.snapshot_id
   and vd.snap_data_type(+) = 'DF ALLOC DATA'
   and vi.snapshot_id(+) = s.snapshot_id
   and vi.snap_data_type(+) = 'DF ALLOC INDX'
   and vun.snapshot_id(+) = s.snapshot_id
   and vun.snap_data_type(+) = 'DF ALLOC UNDO'
   and vtmp.snapshot_id(+) = s.snapshot_id
   and vtmp.snap_data_type(+) = 'DF ALLOC TEMP'
   and vo.snapshot_id(+) = s.snapshot_id
   and vo.snap_data_type(+) = 'DF ALLOC OTHER'
   and s2.capacity_object_id = o2.capacity_object_id
   and s2.job_history_id = jh.job_history_id
   and vts.snapshot_id(+) = s2.snapshot_id
   and vts.snap_data_type(+) = 'TBSP STATUS';

