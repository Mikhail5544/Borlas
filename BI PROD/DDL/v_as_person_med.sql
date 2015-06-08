create or replace force view v_as_person_med as
select pm.as_person_med_id,
         pm.p_asset_header_id,
         c.name || ' ' || c.first_name || ' ' || c.middle_name c_name,
         pm.card_num,
         pl.pol_ser || '-' || pl.pol_num policy_num,
         pm.card_date,
         pm.start_date,
         pm.end_date,
         ct.name || ' ' || ct.first_name || ' ' || ct.middle_name strahovatel,
         iv.name var_strah
  from ven_as_person_med    pm,
       ven_cn_person        p,
       ven_contact          c,
       ven_as_asset         a,
       ven_p_policy         pl,
       ven_p_policy_contact pc,
       ven_contact          ct,
       ven_dms_ins_var      iv
  where pm.contact_id = p.contact_id
    and pm.contact_id = c.contact_id
    and pm.as_person_med_id = a.as_asset_id
    and a.p_policy_id = pl.policy_id
    and (pl.policy_id = pc.policy_id and
         pc.contact_policy_role_id in (select cpr.id
                                       from ven_t_contact_pol_role cpr
                                       where cpr.description = 'Страхователь')
         )
    and pc.contact_id = ct.contact_id
    and iv.dms_ins_var_id = pm.dms_ins_var_id;

