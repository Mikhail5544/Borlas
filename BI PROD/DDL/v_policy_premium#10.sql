create or replace force view v_policy_premium#10 as
select sum(case
             when nbrief = 'NEW' then
              nvl(premium,0)
             when brief = 'DELETED' then
              0
             when nbrief is null then
              nvl(premium,0)
             else
              0
             end) premium,
            pol_header_id
  from (select pc.t_prod_line_option_id,
               pp.pol_header_id,
               pc.premium,
               pp.version_num,
               sh.brief,
               lead(sh.brief) over (partition by pp.pol_header_id, pc.t_prod_line_option_id order by pp.pol_header_id, pp.version_num) nbrief
          from p_policy pp, as_asset aa, p_cover pc, status_hist sh
         where aa.p_policy_id = pp.policy_id
           and pc.as_asset_id = aa.as_asset_id
           and sh.status_hist_id = pc.status_hist_id)
group by pol_header_id;

