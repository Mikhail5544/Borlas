create or replace force view v_org_tree_childs_table as
select column_value
  from table(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id));

