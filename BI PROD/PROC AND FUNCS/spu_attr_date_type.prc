create or replace procedure spu_attr_date_type
( p_obj_id in number,
  p_date_type_id in number,
  p_attr_id in number
)is
begin
  update attr_date_type set
    date_type_id = p_date_type_id,
    attr_id = p_attr_id
  where attr_date_type_id = p_obj_id;
end;
/

