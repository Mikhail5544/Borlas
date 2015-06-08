create or replace view v_form_info as
SELECT block_name
      ,item_name
      ,VALUE
  FROM TABLE(pkg_form_info_fmb.get_records);
