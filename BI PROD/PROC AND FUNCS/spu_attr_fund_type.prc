create or replace procedure spu_attr_fund_type
( p_obj_id in number,
  p_fund_type_id in number,
  p_attr_id in number
)is
begin
  update attr_fund_type set
    fund_type_id = p_fund_type_id,
    attr_id = p_attr_id
  where attr_fund_type_id = p_obj_id;
end;
/

