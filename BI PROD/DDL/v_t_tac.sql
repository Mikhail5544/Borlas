create or replace view v_t_tac as
select tc.t_tac_header_id
      ,tc.t_tac_id
      ,tc.tac_number
      ,tc.tac_name
      ,tc.agreement_num
      ,tc.agreement_date
      ,tc.open_date
      ,tc.ent_id
      ,tc.t_tap_header_id
      ,tp.tap_number
      ,case
         when tc.t_tac_id = ch.last_tac_id then
           1
         else
           0
       end as is_last_version
      ,tc.start_date
      ,nullif(tc.close_date,pkg_tac.get_default_end_date) as close_date
      ,case tc.send_status
         when  0 then 'Не экспортировалось'
         when  1 then 'Экспортировано'
         when -1 then 'Не экспортировано'
       end as send_status_text
      ,tc.send_error_text
      ,su.sys_user_name
  from ven_t_tac             tc
      ,ven_t_tac_header      ch
      ,ven_t_tap_header      th
      ,ven_t_tap             tp
      ,sys_user              su
 where ch.t_tac_header_id = tc.t_tac_header_id
   and tc.t_tap_header_id = th.t_tap_header_id
   and th.last_tap_id     = tp.t_tap_id
   and tc.sys_user_id     = su.sys_user_id;
