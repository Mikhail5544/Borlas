create or replace function fn_get_fund_type(p_ent_id    in number,
                                            p_obj_id    in number,
                                            p_fund_type in number) return number is
    ret_val   number;
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
           attr_fund_type aft
     where aft.fund_type_id = p_fund_type
       and aft.attr_id = q.attr_id;
  
    v_sql_str := acc_new.get_sql(v_attr);
  
    execute immediate v_sql_str
      using out ret_val, in p_obj_id;
  
    return ret_val;
  
   /*exception
    when others then
      dbms_output.put_line('Тип валюты:' || p_fund_type || ' ' || sqlerrm);
      return null;*/
  end;
/

