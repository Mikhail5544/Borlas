create or replace force view quest_cmo_tablespace_property as
select
   a.database_id,
   a.capacity_object_id as tbsp_capacity_object_id,
   a.object_name as tablespace_name,
   b.object_type as tbsp_type,
   b.object_subtype as tbsp_subtype,
   quest_cmo_general_purpose.convert_size
      (cop_ini.property_value_num, cop_ini.value_unit, 'KB') as initial_extent,
   quest_cmo_general_purpose.convert_size
      (cop_blk.property_value_num, cop_blk.value_unit, 'KB') as block_size,
   quest_cmo_general_purpose.convert_size
      (cop_min.property_value_num, cop_min.value_unit, 'KB') as min_extlen,
   cop_ext.property_value_char as extent_management,
   cop_all.property_value_char as allocation_type,
   cop_ssm.property_value_char as segment_space_management,
   cop_con.property_value_char as contents,
   cop_big.property_value_char as bigfile,
   quest_cmo_general_purpose.convert_size
      (cop_ga.property_value_num, cop_ga.value_unit, 'KB') as growth_rate_alloc,
   quest_cmo_general_purpose.convert_size
      (cop_gt.property_value_num, cop_gt.value_unit, 'KB') as growth_rate_total
 from
   quest_cmo_capacity_object a,
   quest_cmo_object_type b,
   quest_cmo_capacity_object_prop cop_ini,
   quest_cmo_capacity_object_prop cop_blk,
   quest_cmo_capacity_object_prop cop_min,
   quest_cmo_capacity_object_prop cop_ext,
   quest_cmo_capacity_object_prop cop_all,
   quest_cmo_capacity_object_prop cop_ssm,
   quest_cmo_capacity_object_prop cop_con,
   quest_cmo_capacity_object_prop cop_big,
   quest_cmo_capacity_object_prop cop_ga,
   quest_cmo_capacity_object_prop cop_gt
 where
   b.object_type_code = a.object_type_code
   and b.object_type = 'TABLESPACE'
   and cop_ini.capacity_object_id (+) = a.capacity_object_id
   and cop_ini.cap_obj_prop_data_type (+) = 'TBSP INIEXT'
   and cop_blk.capacity_object_id (+) = a.capacity_object_id
   and cop_blk.cap_obj_prop_data_type (+) = 'TBSP BLKSIZ'
   and cop_min.capacity_object_id (+) = a.capacity_object_id
   and cop_min.cap_obj_prop_data_type (+) = 'TBSP MINEXTL'
   and cop_ext.capacity_object_id (+) = a.capacity_object_id
   and cop_ext.cap_obj_prop_data_type (+) = 'TBSP EXTMGMT'
   and cop_all.capacity_object_id (+) = a.capacity_object_id
   and cop_all.cap_obj_prop_data_type (+) = 'TBSP ALLOCTYP'
   and cop_ssm.capacity_object_id (+) = a.capacity_object_id
   and cop_ssm.cap_obj_prop_data_type (+) = 'TBSP SSM'
   and cop_con.capacity_object_id (+) = a.capacity_object_id
   and cop_con.cap_obj_prop_data_type (+) = 'TBSP CONT'
   and cop_big.capacity_object_id (+) = a.capacity_object_id
   and cop_big.cap_obj_prop_data_type (+) = 'TBSP BIGF'
   and cop_ga.capacity_object_id (+) = a.capacity_object_id
   and cop_ga.cap_obj_prop_data_type (+) = 'GROWTH RATE ALLOC'
   and cop_gt.capacity_object_id (+) = a.capacity_object_id
   and cop_gt.cap_obj_prop_data_type (+) = 'GROWTH RATE TOTAL';

