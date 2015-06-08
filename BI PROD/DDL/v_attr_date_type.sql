create or replace force view v_attr_date_type as
select ast.attr_date_type_id,
       ast.date_type_id,
       ast.attr_id,
       st.name,
       e.brief || '.' || a.brief attr_brief
  from attr_date_type ast, date_type st, attr a, entity e
 where ast.date_type_id = st.date_type_id
   and a.attr_id = ast.attr_id
   and e.ent_id = a.ent_id;

