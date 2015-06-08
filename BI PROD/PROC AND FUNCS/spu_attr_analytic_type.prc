create or replace procedure spu_attr_analytic_type
( p_obj_id in number,
  p_analytic_type_id in number,
  p_attr_id in number
)is
begin
  update attr_analytic_type set
    analytic_type_id = p_analytic_type_id,
    attr_id = p_attr_id
  where attr_analytic_type_id = p_obj_id;
end;
/

