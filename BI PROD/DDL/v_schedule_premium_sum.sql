create or replace force view v_schedule_premium_sum as
select sp.year,
       sp.t_prod_line_option_id,
       q.pol_header_id,
       sp.ins_amount,
       sp.p_asset_header_id,
       sp.premium,
       a.as_asset_id, 
       a.ent_id,
       sum(sp.premium)over(partition by q.pol_header_id, sp.year) total
  from schedule_premium sp
  join (select aa.p_asset_header_id, pp.pol_header_id
          from as_asset aa, p_policy pp
         where aa.p_policy_id = pp.policy_id
         group by aa.p_asset_header_id, pp.pol_header_id) q on q.p_asset_header_id =
                                                               sp.p_asset_header_id
  join (
  select 
         aa.as_asset_id, 
         aa.ent_id, 
         aa.p_asset_header_id,
         row_number()over(partition by aa.p_asset_header_id order by aa.as_asset_id) rn
  from As_Asset aa) a on a.rn = 1 and a.p_asset_header_id = q.p_asset_header_id;

