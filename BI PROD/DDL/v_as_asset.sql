create or replace force view v_as_asset as
select
  a.as_asset_id,
  a.ent_id,
  a.p_policy_id,
  a.p_asset_header_id,
  a.status_hist_id,
  a.contact_id,
  ent.obj_name(ent.id_by_brief('CONTACT'), a.contact_id) contact,
  a.name,
  a.note,
  a.start_date,
  a.end_date
from ven_as_asset a;

