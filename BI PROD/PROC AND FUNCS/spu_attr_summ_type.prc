create or replace procedure spu_attr_summ_type
( p_obj_id in number,
  p_summ_type_id in number,
  p_attr_id in number
)is
begin
  update attr_summ_type set
    summ_type_id = p_summ_type_id,
    attr_id = p_attr_id
  where attr_summ_type_id = p_obj_id;
end;
/

