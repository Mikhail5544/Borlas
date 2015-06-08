CREATE OR REPLACE FORCE VIEW V_RE_RESERVE AS
SELECT r.ID reserve_id
     , pc.p_cover_id
     , r.p_asset_header_id
     , pl.ID product_line_id
     , rv.insurance_year_date start_date
     , ADD_MONTHS(rv.insurance_year_date, 12)-1/(24*60*60) end_date
     , rv.insurance_year_number
     , rv.reserve_date
     , rv.tv_f
     , rv.TV_P_RE
FROM reserve.r_reserve r
   , reserve.r_reserve_value rv
   , p_policy pp
   , as_asset aa
   , p_cover pc
   , t_prod_line_option plo
   , t_product_line pl
WHERE pp.policy_id = r.policy_id
  AND aa.p_policy_id = pp.policy_id
  AND aa.p_asset_header_id = r.p_asset_header_id
  AND pc.as_asset_id = aa.as_asset_id
  AND plo.ID = pc.t_prod_line_option_id
  AND pl.ID = plo.product_line_id
  AND pl.ID = r.t_product_line_id
  AND rv.reserve_id = r.ID
ORDER BY pl.ID;

