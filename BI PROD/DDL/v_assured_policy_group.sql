create or replace force view v_assured_policy_group as
select decode(jj.pol_ser, null, jj.pol_num, jj.pol_ser || '-' || jj.pol_num) policy_number,
       jj.status_name,
       --aa.p_asset_header_id,
       --ass.assured_contact_id,
       jj.insurer_name,
       cc.name||' '||cc.first_name||' '||cc.middle_name as ins_name,
       per.date_of_birth,
       opt.description,
       jj.f_resp,
       pc.ins_amount,
       pc.premium

from v_policy_version_journal jj
     left join as_asset aa on (aa.p_policy_id = jj.policy_id)
     left join as_assured ass on (ass.as_assured_id = aa.as_asset_id)
     left join contact cc on (cc.contact_id = ass.assured_contact_id)
     left join cn_person per on (per.contact_id = cc.contact_id)
     left join p_cover pc on (pc.as_asset_id = aa.as_asset_id)
     left join t_prod_line_option opt on (opt.id = pc.t_prod_line_option_id)
where jj.policy_id = jj.active_policy_id
      and jj.pol_ser = 'GN'
;

