create or replace force view v_attr_an_type as
select aat.attr_analytic_type_id,
       aat.analytic_type_id,
       aat.attr_id,
       att.name,
       e.brief || '.' || a.brief attr_brief
  from attr_analytic_type aat, analytic_type att, attr a, entity e
 where aat.analytic_type_id = att.analytic_type_id
   and a.attr_id = aat.attr_id
   and e.ent_id = a.ent_id;

