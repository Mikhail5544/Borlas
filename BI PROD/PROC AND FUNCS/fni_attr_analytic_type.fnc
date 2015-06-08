create or replace function fni_attr_analytic_type
( p_obj_id in number,
  p_analytic_type_id in number,
  p_attr_id in number
) return number
is
  v_obj_id number;
begin
  if p_obj_id is null then
    select sq_attr_analytic_type.nextval into v_obj_id from dual;
  else
    v_obj_id := p_obj_id;
  end if;
  insert into attr_analytic_type(attr_analytic_type_id, ent_id, analytic_type_id, attr_id)
  values(v_obj_id, 314, p_analytic_type_id, p_attr_id);
  return(v_obj_id);
end;
/

