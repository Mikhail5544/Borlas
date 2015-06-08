create or replace procedure sp_rc(p_cmd in varchar2) as
  x number;
begin
  x := fn_run_cmd_str(p_cmd);
  if (x <> 0) then
    dbms_output.put_line(x);
  end if;
end;
/

