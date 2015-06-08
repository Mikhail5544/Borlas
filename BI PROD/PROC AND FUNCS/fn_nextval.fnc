create or replace function fn_nextval
( p_sq_name in varchar2 -- Наименование последовательности
)
  return number
is
  v_result number;
begin
  execute immediate 'select ' || p_sq_name || '.nextval from dual' into v_result;
  return v_result;
end;
/

