create or replace force view v_t_product_curator as
select pc.t_product_curator_id, 
	   pc.organisation_tree_id, 
	   ot.NAME org_name, 
	   pc.department_id, 
	   d.NAME dep_name, 
	   pc.employee_id, 
	   fn_obj_name(c.ent_id, c.contact_id) emp_name, 
	   pc.is_default, 
	   pc.t_product_id, 
	   pc.ent_id, 
	   pc.filial_id, 
 	   pc.EXT_ID 
from t_product_curator pc,organisation_tree ot,department d,employee e,contact c 
where ot.organisation_tree_id(+)=pc.organisation_tree_id 
  and d.department_id(+)=pc.department_id 
  and e.employee_id(+)=pc.employee_id 
  and c.contact_id=e.contact_id;

