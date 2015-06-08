create or replace view v_t_tac_to_tap as
select cp.t_tac_to_tap_id
      ,cp.t_tac_id
      ,th.t_tap_header_id
      ,tt.tap_number
      ,cp.begin_date
      ,nullif(cp.end_date,pkg_tac.get_default_end_date) as end_date
      ,cp.is_main
  from ven_t_tac_to_tap  cp
      ,ven_t_tap_header  th
      ,ven_t_tap         tt
 where cp.t_tap_header_id = th.t_tap_header_id
   and th.last_tap_id   = tt.t_tap_id;
