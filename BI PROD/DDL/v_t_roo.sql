create or replace view v_t_roo
as
select ro.t_roo_header_id
      ,ro.t_roo_id
      ,rh.roo_number
      ,ro.roo_name
      ,ro.organisation_tree_id as department_id
      ,sd.dept_name            as department_name
      ,nvl(ad.name,pkg_contact.get_address_name(ad.id)) as address
      ,ro.open_date
      ,nullif(ro.close_date,pkg_roo.get_default_end_date) as close_date
      ,ro.t_tap_header_id
      ,ta.tap_number
      ,case
         when ro.t_roo_id = rh.last_roo_id then
           1
         else
           0
       end as is_last_version
      ,ro.start_date
      ,ro.ver_num
      ,su.sys_user_name
  from ven_t_roo_header      rh
      ,ven_t_roo             ro
      ,ven_sales_dept_header sh
      ,ven_sales_dept        sd
      ,ven_cn_entity_address ea
      ,cn_address            ad
      ,ven_t_tap_header      th
      ,ven_t_tap	           ta
      ,sys_user              su
 where rh.t_roo_header_id      = ro.t_roo_header_id
   and ro.organisation_tree_id = sh.organisation_tree_id(+)
   and sh.last_sales_dept_id   = sd.sales_dept_id(+)
   and sd.ent_id               = ea.ure_id (+)
   and sd.sales_dept_id        = ea.uro_id (+)
   and ea.address_id           = ad.id (+)
   and ro.t_tap_header_id      = th.t_tap_header_id (+)
   and th.last_tap_id          = ta.t_tap_id (+)
   and ro.sys_user_id          = su.sys_user_id;
