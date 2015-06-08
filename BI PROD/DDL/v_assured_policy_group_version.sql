create or replace force view v_assured_policy_group_version as
select
       pp.pol_ser,
       pp.pol_num policy_number,
       pp.version_num,
       doc.get_doc_status_name(pp.policy_id) ver_status,
       cins.obj_name_orig insurer_name,
       cc.name||' '||cc.first_name||' '||cc.middle_name as ins_name,
       per.date_of_birth,
       opt.description,
       f.brief,
       pc.fee,
       pc.ins_amount,
       pc.premium,
       pc.start_date,
       pc.end_date,
       sh.imaging "признак добавлени€/удалени€"


from p_policy pp
     left join as_asset aa on (aa.p_policy_id = pp.policy_id)
     left join as_assured ass on (ass.as_assured_id = aa.as_asset_id)
     left join contact cc on (cc.contact_id = ass.assured_contact_id)
     left join contact cins on (pkg_policy.get_policy_contact(pp.policy_id,'—трахователь') = cins.contact_id)
     left join cn_person per on (per.contact_id = cc.contact_id)
     left join p_cover pc on (pc.as_asset_id = aa.as_asset_id)
     left join t_prod_line_option opt on (opt.id = pc.t_prod_line_option_id)
     left join p_pol_header ph on (ph.policy_header_id = pp.pol_header_id)
     left join fund f on (f.fund_id = ph.fund_id)
     left join status_hist sh on (sh.status_hist_id = pc.status_hist_id)

where pp.pol_ser = 'GN';

