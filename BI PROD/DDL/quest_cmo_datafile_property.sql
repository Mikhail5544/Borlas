create or replace force view quest_cmo_datafile_property as
select
   a.database_id,
   a.container as tbsp_capacity_object_id,
   a.capacity_object_id as df_capacity_object_id,
   a.object_name as file_name,
   quest_cmo_general_purpose.extract_file_name (a.object_name) as short_file_name,
   b.object_type as df_type,
   b.object_subtype as df_subtype,
   cop_auto.property_value_char as autoextensible,
   quest_cmo_general_purpose.convert_size
      (cop_max.property_value_num, cop_max.value_unit, 'KB') as max_kbytes,
   quest_cmo_general_purpose.convert_size
      (cop_inc.property_value_num, cop_inc.value_unit, 'KB') as increment_by,
   quest_cmo_general_purpose.convert_size
      (cop_ga.property_value_num, cop_ga.value_unit, 'KB') as growth_rate_alloc,
   quest_cmo_general_purpose.convert_size
      (cop_gt.property_value_num, cop_gt.value_unit, 'KB') as growth_rate_total
 from
   quest_cmo_capacity_object a,
   quest_cmo_object_type b,
   quest_cmo_capacity_object_prop cop_auto,
   quest_cmo_capacity_object_prop cop_max,
   quest_cmo_capacity_object_prop cop_inc,
   quest_cmo_capacity_object_prop cop_ga,
   quest_cmo_capacity_object_prop cop_gt
 where
   b.object_type_code = a.object_type_code
   and b.object_type in ('DATAFILE', 'TEMPFILE')
   and cop_auto.capacity_object_id (+) = a.capacity_object_id
   and cop_auto.cap_obj_prop_data_type (+) = 'DF AUTOEXT'
   and cop_max.capacity_object_id (+) = a.capacity_object_id
   and cop_max.cap_obj_prop_data_type (+) = 'DF MAX'
   and cop_inc.capacity_object_id (+) = a.capacity_object_id
   and cop_inc.cap_obj_prop_data_type (+) = 'DF NEXT'
   and cop_ga.capacity_object_id (+) = a.capacity_object_id
   and cop_ga.cap_obj_prop_data_type (+) = 'GROWTH RATE ALLOC'
   and cop_gt.capacity_object_id (+) = a.capacity_object_id
   and cop_gt.cap_obj_prop_data_type (+) = 'GROWTH RATE TOTAL';

