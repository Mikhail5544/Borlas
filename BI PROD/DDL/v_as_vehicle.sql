create or replace force view v_as_vehicle
(pol_num, product, vladelets, asset_vehicle, strahovatel, policy_id, asset_id, pol_header_id, version_num, strahovatel_status_id, strahovatel_status, amount, premium, fund, fund_id, product_brief, product_id)
as
select pol.num pol_num,
	   p.description,
	   con1.name || ' ' || con1.first_name || ' ' || con1.middle_name  vladelets,
	   ent.obj_name(veh.ent_id, veh.as_asset_id),
	   con2.name || ' ' || con2.first_name || ' ' || con2.middle_name  strahovatel,
	   pol.policy_id,
	   veh.as_asset_id,
	   pol.pol_header_id,
	   pol.version_num,
	   con2.t_contact_status_id,
	   ent.obj_name('T_CONTACT_STATUS', con2.t_contact_status_id),
	   pol.ins_amount,
	   pol.premium,
	   f.brief,
	   f.fund_id,
     p.brief,
     p.product_id
	   from ven_p_policy pol,
	   		ven_p_pol_header ph,
	   		ven_p_policy_contact pol_c,
			ven_as_asset veh,
			ven_contact con1,
			ven_contact con2,
			ven_fund f,
      ven_t_product p
		where	ph.policy_header_id = pol.pol_header_id and
				veh.p_policy_id = pol.policy_id and
				pol.policy_id = pol_c.policy_id and
         		(pol_c.contact_policy_role_id in (select cpr.id
                                       from ven_t_contact_pol_role cpr
                                       where cpr.description = 'Страхователь')) and
				veh.contact_id = con1.contact_id and
				pol_c.contact_id = con2.contact_id and
				ph.fund_id = f.fund_id(+) and
        p.product_id = ph.product_id;

