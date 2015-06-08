create or replace force view v_for_prolong_corp as
select policy_header_id,
       policy_id,
       ids,
       insurer,
       date_of_birth,
       gender,
       name_opt,
       trim(to_char(ins_amount,'999G999G999G999G990D00')) ins_amount,
       trim(to_char(premium,'999G999G999G999G990D00')) premium,
       trim(to_char(prem_policy,'999G999G999G999G990D00')) prem_policy,
       currency,
       risk_start_date,
       risk_end_date,
       start_date,
       end_date,
       department,
       cch_num,
       opt_to,
       damage_code,
       trim(to_char(round((nvl(amount,0)) * (case when amount > 0 then ((nvl(paym,0) - nvl(decl,0)) * rate / amount) else 0 end),2),'999G999G999G999G990D00')) sum_predp,
       trim(to_char(pkg_renlife_utils.ret_amount_claim(c_event_id, c_claim_header_id, 'В') +
             pkg_renlife_utils.ret_amount_claim(c_event_id, c_claim_header_id, 'З'),'999G999G999G999G990D00')) sum_vipl,
       nvl(to_char(pkg_renlife_utils.ret_sod_claim(c_claim_header_id),'dd.mm.yyyy'),'-') date_of_vipl,
       nvl(doc.get_last_doc_status_name(active_claim_id),'-') last_status
from
(
select ph.policy_header_id,
       pp.policy_id,
       to_char(ph.ids) ids,
       c.obj_name_orig insurer,
       per.date_of_birth,
       decode(per.gender,1,'М',0,'Ж','') gender,
       opt.description name_opt,
       pc.ins_amount,
       pc.premium,
       (select sum(pc.premium)
        from as_asset a,
             p_cover pc,
             status_hist ht
        where a.p_policy_id = pp.policy_id
              and a.as_asset_id = pc.as_asset_id
              and pc.status_hist_id = ht.status_hist_id
              and ht.brief <> 'DELETED') prem_policy,
       f.brief currency,
       pc.start_date risk_start_date,
       pc.end_date risk_end_date,
       ph.start_date,
       pp.end_date,
       nvl(dep.name,'-') department,
       nvl(cch.num,'-') cch_num,
       nvl(tp.description,'-') opt_to,

       nvl(pc.ins_amount,0) amount,
       nvl(dmg.decline_sum,0) decl,
       nvl(dmg.declare_sum,0) paym,
       nvl(acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,cch.declare_date),1) rate,
       cch.c_claim_header_id,
       e.c_event_id,
       cch.active_claim_id,
       tdc.description damage_code
from p_pol_header ph
     join fund f on (f.fund_id = ph.fund_id)
     join p_policy pp on (pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id))
     join as_asset a on (pp.policy_id = a.p_policy_id)
     join as_assured ass on (a.as_asset_id = ass.as_assured_id)
     join p_cover pc on (a.as_asset_id = pc.as_asset_id)
     join status_hist sth on (sth.status_hist_id = pc.status_hist_id
      and sth.brief <> 'DELETED')
     join t_prod_line_option opt on (pc.t_prod_line_option_id = opt.id)
     join contact c on (ass.assured_contact_id = c.contact_id)
     join cn_person per on (per.contact_id = c.contact_id)
     left join department dep on (ph.agency_id = dep.department_id)
     left join t_sales_channel ch on (ch.id = ph.sales_channel_id
      and ch.description = 'Корпоративный')
     left join ven_c_claim_header cch on (cch.p_policy_id = pp.policy_id
      and pc.p_cover_id = cch.p_cover_id)
     left join c_event e on (e.c_event_id = cch.c_event_id)
     left join t_peril tp on (cch.peril_id = tp.id)
     left join c_damage dmg on (dmg.p_cover_id = pc.p_cover_id and cch.active_claim_id = dmg.c_claim_id and dmg.status_hist_id <> 3)
     left join t_damage_code tdc on (dmg.t_damage_code_id = tdc.id)
     left join fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
      );

