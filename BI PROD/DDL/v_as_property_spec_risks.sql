create or replace force view v_as_property_spec_risks as
select p.as_property_id,
       p.p_policy_id,
       p.status_hist_id,
       p.p_asset_header_id,
       p.contact_id,
       ent.obj_name(ent.id_by_brief('CONTACT'), p.contact_id) contact,
       p.cn_address_id,
       ent.obj_name(ent.id_by_brief('CN_ADDRESS'), p.cn_address_id) cn_address,
       p.lodger_type_id,
       p.deduct_type_id,
       (select description from t_deductible_type where id = p.deduct_type_id)  deduct_type,
       p.deduct_type_value_id,
       (select description from t_deduct_val_type where id = p.deduct_type_value_id) deduct_type_value,
       p.deduct_value,
       p.t_object_type_spec_id,
       (select name from ven_t_object_type_spec where t_object_type_spec_id = p.t_object_type_spec_id) object_type_spec,
       (select f.brief
          from p_policy pp, fund f, p_pol_header ph
         where pp.policy_id = p.p_policy_id
           and f.fund_id = ph.fund_id
           and ph.policy_header_id = pp.pol_header_id) fund_brief,
        p.note,
        --p.ins_premium,
        p.ins_price,
        p.ins_amount,
        p.start_date, p.end_date, p.is_first_event
  from ven_as_property p
;

