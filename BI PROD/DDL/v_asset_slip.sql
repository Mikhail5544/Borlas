create or replace force view v_asset_slip as
select aa.as_asset_id,
       pp.pol_ser,
       pp.pol_num,
       tat.name,
       ent.obj_name(aa.ent_id, aa.as_asset_id) asset_name,
       ent.obj_name(c.ent_id, c.contact_id) contact_name,
       (select count(*)
          from p_cover pc, tmp_num
         where pc.as_asset_id = aa.as_asset_id
           and pc.p_cover_id = num) c
  from ven_p_policy       pp,
       ven_as_asset       aa,
       ven_p_asset_header pah,
       ven_t_asset_type   tat,
       ven_contact        c
 where pp.policy_id in
       (select a.p_policy_id
          from ven_as_asset a, ven_p_cover c, tmp_num n
         where c.p_cover_id = n.num
           and c.as_asset_id = a.as_asset_id)
   and aa.p_policy_id = pp.policy_id
   and aa.p_asset_header_id = pah.p_asset_header_id
   and tat.t_asset_type_id = pah.t_asset_type_id
   and c.contact_id = aa.contact_id;

