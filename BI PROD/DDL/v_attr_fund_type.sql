create or replace force view v_attr_fund_type as
select ast.attr_fund_type_id,
       ast.fund_type_id,
       ast.attr_id,
       st.name,
       e.brief || '.' || a.brief attr_brief
  from attr_fund_type ast, fund_type st, attr a, entity e
 where ast.fund_type_id = st.fund_type_id
   and a.attr_id = ast.attr_id
   and e.ent_id = a.ent_id;

