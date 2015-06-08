create or replace function fn_get_date_type(p_ent_id    in number,
                                            p_obj_id    in number,
                                            p_date_type in number)
  return date AUTHID CURRENT_USER is 
  ret_val date;
  v_attr    attr%rowtype;
  v_sql_str varchar2(4000);
begin

  select q.*
    into v_attr
    from (select a.*
            from attr a
           inner join attr_type aty on aty.attr_type_id = a.attr_type_id
                                   and aty.brief = 'OI'
           where a.ent_id = p_ent_id
          union all
          select a.*
            from (select e.ent_id, e.name
                    from entity e
                   start with e.ent_id = p_ent_id
                  connect by prior e.parent_id = e.ent_id) t
           inner join attr a on a.ent_id = t.ent_id
           inner join attr_type aty on aty.attr_type_id = a.attr_type_id
                                   and aty.brief in ('F', 'R', 'UR', 'C')) q,
         ven_attr_date_type adt
   where adt.date_type_id = p_date_type
     and adt.attr_id = q.attr_id;

  v_sql_str := acc_new.get_sql(v_attr);

  execute immediate v_sql_str
    using out ret_val, in p_obj_id;

  return ret_val;

 /* exception
    when others then
      dbms_output.put_line('“ип даты:' || p_date_type || ' ' || sqlerrm);
      return null;
 */     
end;
/

