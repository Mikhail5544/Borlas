create or replace view v_t_tap as
select tt.t_tap_header_id
      ,tt.t_tap_id
      ,tt.tap_number
      ,tt.open_date
      ,tt.ent_id
      ,nullif(tt.close_date,pkg_tap.get_default_end_date) as close_date
      ,ro.roo_number
      ,ro.t_roo_header_id
      ,case
         when tt.t_tap_id = th.last_tap_id then
           1
         else
           0
       end as is_last_version
      ,tt.start_date
      ,case tt.send_status
         when  0 then 'Не экспортировалось'
         when  1 then 'Экспортировано'
         when -1 then 'Не экспортировано'
       end as send_status_text
      ,tt.send_error_text
      ,su.sys_user_name
  from ven_t_tap_header      th
      ,ven_t_tap             tt
      ,sys_user              su
      ,(select rh.t_roo_header_id
              ,rh.roo_number
              ,ro.t_tap_header_id
          from ven_t_roo_header rh
              ,ven_t_roo        ro
         where ro.t_roo_id = rh.last_roo_id
       ) ro
 where th.t_tap_header_id = tt.t_tap_header_id
   and tt.sys_user_id     = su.sys_user_id
   and tt.t_tap_header_id = ro.t_tap_header_id (+);
