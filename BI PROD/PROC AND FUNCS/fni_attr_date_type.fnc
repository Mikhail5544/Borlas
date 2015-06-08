create or replace function fni_attr_date_type
( p_obj_id in number,
  p_date_type_id in number,
  p_attr_id in number
) return number
is
  v_obj_id number;
begin
  if p_obj_id is null then
    select sq_attr_date_type.nextval into v_obj_id from dual;
  else
    v_obj_id := p_obj_id;
  end if;
  insert into attr_date_type(attr_date_type_id, ent_id, date_type_id, attr_id)
  values(v_obj_id, 312, p_date_type_id, p_attr_id);
  return(v_obj_id);
end;
/

