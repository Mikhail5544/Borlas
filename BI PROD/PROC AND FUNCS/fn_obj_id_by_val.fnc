create or replace function fn_obj_id_by_val(p_ent_brief in varchar2, p_val in varchar2) return number
is
  res number;
  v_source varchar2(30);
  v_id_name varchar2(30);
  v_col_name varchar2(30);
  v_ent_name varchar2(200);
  v_ent_id number(6);
begin
  select e.source, e.id_name, e.name, e.ent_id 
  into v_source, v_id_name, v_ent_name, v_ent_id
  from entity e,
       attr a,
       attr_type aty
  where e.brief = p_ent_brief 
        and a.ent_id = e.ent_id
        and aty.attr_type_id = a.attr_type_id
        and aty.brief = 'OI';

  begin
    select a.col_name into v_col_name
    from attr a
    where a.is_key = 1
          and a.ent_id in ( select e.ent_id
                            from entity e
                            start with e.ent_id = v_ent_id
                            connect by e.ent_id = prior e.parent_id
                          );
  exception
    when no_data_found then
      raise_application_error(-20000, 'obj_id_by_val. ' || 'Не определено ключевое поле на сущности "' || v_ent_name || '".');
    when too_many_rows then
      raise_application_error(-20000, 'obj_id_by_val. ' || 'Количество ключевых полей на сущности "' || v_ent_name || '"больше одного.');
  end;
     
  execute immediate 'select ' || v_id_name || ' from ven_' || v_source || ' where ' || v_col_name || ' = ''' || p_val || '''' into res;
  return res;
exception
    when no_data_found then
      return null;
    when too_many_rows then
      raise_application_error(-20000, 'obj_id_by_val. ' || 'Неверно определено ключевое поле на сущности "' || v_ent_name || '".');
end;
/

