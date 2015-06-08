create or replace force view quest_cmo_emerg_issue_values as
select
   e.emergent_issue_id, e.database_id, db.database_label,
   m.message_code, e.message_type,
   s.severity_level_description as severity_level_desc,
   e.associated_object_id as capacity_object_id,
   o.owner, o.object_name,
   e.associated_object_type as associated_object_type,
   objt.object_type as object_type,
   o.object_name as tablespace_name,
   dn1.emergent_issue_data_type as number_data_type1,
   quest_cmo_general_purpose.convert_size
      (dn1.emergent_issue_value_num, dn1.value_unit, 'KB') as value_num1,
   dn2.emergent_issue_data_type as number_data_type2,
   quest_cmo_general_purpose.convert_size
      (dn2.emergent_issue_value_num, dn2.value_unit, 'KB') as value_num2,
   dd.emergent_issue_data_type as date_data_type,
   dd.emergent_issue_value_date as value_date
 from
   quest_cmo_emergent_issue e,
   quest_cmo_databases db,
   quest_cmo_emergent_issue_msg m,
   quest_cmo_emergent_issue_sev s,
   quest_cmo_emergent_issue_data dn1,
   quest_cmo_emergent_issue_data dn2,
   quest_cmo_emergent_issue_data dd,
   quest_cmo_emerg_iss_dtyp dtn1,
   quest_cmo_emerg_iss_dtyp dtn2,
   quest_cmo_emerg_iss_dtyp dtd,
   quest_cmo_capacity_object o,
   quest_cmo_object_type objt
 where
   e.associated_object_type = 'CAPACITY OBJECT'
   and m.message_id = e.message_id
   and s.severity_level = e.severity_level
   and db.database_id = e.database_id
   and dn1.emergent_issue_id  = e.emergent_issue_id
   and dn1.emergent_issue_data_type = dtn1.emergent_issue_data_type
   and dtn1.item_data_type = 'NUMBER'
   and dn2.emergent_issue_id  = e.emergent_issue_id
   and dn2.emergent_issue_data_type = dtn2.emergent_issue_data_type
   and dtn2.item_data_type = 'NUMBER'
   and dn1.emergent_issue_data_item_id < dn2.emergent_issue_data_item_id
   and dd.emergent_issue_id  = e.emergent_issue_id
   and dd.emergent_issue_data_type = dtd.emergent_issue_data_type
   and dtd.item_data_type = 'DATE'
   and o.capacity_object_id = e.associated_object_id
   and o.object_type_code = objt.object_type_code
   and objt.object_type = 'TABLESPACE';

