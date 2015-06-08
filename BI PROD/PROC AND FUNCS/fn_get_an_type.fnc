create or replace function fn_get_an_type(p_ent_id in number,
                                          p_obj_id in number,
                                          p_an_type        in number)
  return number AUTHID CURRENT_USER is
  ret_val   number;
  v_attr    attr%rowtype;
  v_sql_str varchar2(4000);
begin

  -- атрибут объекта учета в типе аналитики
  select q.*
    into v_attr
    from (select a.*
            from (select e.ent_id, e.name
                    from entity e
                   start with e.ent_id = p_ent_id
                  connect by prior e.parent_id = e.ent_id) t
           inner join attr a on a.ent_id = t.ent_id) q,
         ven_attr_analytic_type aat
   where aat.analytic_type_id = p_an_type
     and aat.attr_id = q.attr_id;

  -- значение атрибута объекта учета
  v_sql_str := acc_new.get_sql(v_attr);

  execute immediate v_sql_str
    using out ret_val, in p_obj_id;

  return ret_val;
  /*
  exception
    when others then
      --      dbms_output.put_line('Тип аналитики:' || p_an_type || ' ' || sqlerrm);
      return null;
   */
end;
/

