CREATE OR REPLACE VIEW V_INTEGRATION_POLICY_COMPARE AS
SELECT /*+ USE_NL(pc cs cd) */
 ph.policy_header_id
,at.brief asset_type_brief
,plo.brief prod_line_option_brief
,pc.fee
,pc.ins_amount
,pc.premium
,pc.tariff
,pc.rvb_value loading
,pc.tariff_netto
,CASE
   WHEN EXISTS (SELECT NULL
           FROM p_cover_coef pcc
          WHERE pcc.p_cover_id = pc.p_cover_id
            AND pcc.val = 0) THEN
    0
   ELSE
    (SELECT exp(SUM(ln(pcc.val))) FROM p_cover_coef pcc WHERE pcc.p_cover_id = pc.p_cover_id)
 END coefs_product
,cd.payment_number payment
,cd.insurance_year_number YEAR
,ROUND(cd.value, 2) surr_sum_value
  FROM p_pol_header       ph
      ,as_asset           aa
      ,p_cover            pc
      ,p_asset_header     ah
      ,t_asset_type       at
      ,t_prod_line_option plo
      ,policy_cash_surr   cs
      ,policy_cash_surr_d cd
 WHERE aa.p_policy_id = ph.policy_id
   AND aa.p_asset_header_id = ah.p_asset_header_id
   AND ah.t_asset_type_id = at.t_asset_type_id
   AND pc.as_asset_id = aa.as_asset_id
   AND pc.t_prod_line_option_id = plo.id
   AND pc.p_cover_id = cs.p_cover_id(+)
   AND cs.policy_cash_surr_id = cd.policy_cash_surr_id(+);
grant
  SELECT ON v_integration_policy_compare TO ins_read;
