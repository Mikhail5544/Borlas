create or replace function fn_max_id(p_tab in varchar2, p_id_col in varchar2) return number
as
  v_result number;
begin
  execute immediate 'select max(' || p_id_col || ') from ' || p_tab into v_result;
  return v_result;      
exception    
  when others then
    return -1;  
end;
/

