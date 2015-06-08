create or replace force view t_brand_company as
select
       c.contact_id
  from contact c
 where c.contact_id = pkg_app_param.get_app_param_u('WHOAMI');

