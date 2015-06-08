create or replace function fn_obj_list_sql_trans(p_analytic_type_id in number,
                                                 p_analytic_num     in number)
  return varchar2 is
  v_result varchar2(4000);
  v_sql    analytic_type.obj_list_sql%type;
  i        number;
begin
  begin
    select trim(at.obj_list_sql)
      into v_sql
      from analytic_type at
     where at.analytic_type_id = p_analytic_type_id;
    v_result := '';
    for i in 1 .. length(v_sql) loop
      if substr(v_sql, i, 1) <> '#' then
        v_result := v_result || substr(v_sql, i, 1);
      else
        v_result := v_result || trim(to_char(p_analytic_num));
      end if;
    end loop;
  exception
    when others then
      v_result := '';
  end;
  return v_result;
end;
/

