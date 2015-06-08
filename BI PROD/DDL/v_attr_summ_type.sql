create or replace force view v_attr_summ_type as
select ast.attr_summ_type_id,
       ast.summ_type_id,
       ast.attr_id,
       st.name,
       e.brief || '.' || a.brief attr_brief
  from attr_summ_type ast, summ_type st, attr a, entity e
 where ast.summ_type_id = st.summ_type_id
   and a.attr_id = ast.attr_id
   and e.ent_id = a.ent_id;

