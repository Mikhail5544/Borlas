create materialized view INS_DWH.MV_ASSURED
refresh force on demand
as
select ph.policy_header_id
      ,ph.last_ver_id as policy_id
      ,su.assured_contact_id
      ,se.status_hist_id
      ,sh.name
      ,se.start_date
      ,se.end_date
      ,pe.date_of_death
  from ins.p_pol_header ph
      ,ins.as_asset     se
      ,ins.status_hist  sh
      ,ins.as_assured   su
      ,ins.cn_person    pe
 where ph.last_ver_id        = se.p_policy_id
   and se.as_asset_id        = su.as_assured_id
   and se.status_hist_id     = sh.status_hist_id
   and su.assured_contact_id = pe.contact_id;

