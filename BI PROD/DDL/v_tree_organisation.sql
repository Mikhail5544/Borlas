create or replace force view v_tree_organisation as
select -1 st, level x_level, t.name, '' icon, t.organisation_tree_id id
  from organisation_tree t
 start with t.parent_id is NULL
connect by prior t.organisation_tree_id = t.parent_id
 order siblings by t.name;

