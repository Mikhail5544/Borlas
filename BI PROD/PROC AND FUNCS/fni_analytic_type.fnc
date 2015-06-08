create or replace function fni_analytic_type
( p_obj_id in number,
  p_name in varchar2,
  p_brief in varchar2,
  p_analytic_ent_id in number,
  p_obj_list_sql in varchar2,
  p_obj_list_sql_view in varchar2,
  p_is_acc_link in number
    default 0,
  p_parent_an_type_id in number
) return number
is
  v_obj_id number;
begin
  if p_obj_id is null then
    select sq_analytic_type.nextval into v_obj_id from dual;
  else
    v_obj_id := p_obj_id;
  end if;
  insert into analytic_type(analytic_type_id, ent_id, name, brief, analytic_ent_id, obj_list_sql, obj_list_sql_view, is_acc_link, parent_an_type_id)
  values(v_obj_id, 310, p_name, p_brief, p_analytic_ent_id, p_obj_list_sql, p_obj_list_sql_view, p_is_acc_link, p_parent_an_type_id);
  return(v_obj_id);
end;
/

