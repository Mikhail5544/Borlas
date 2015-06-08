CREATE OR REPLACE VIEW V_POLICY_ACTIVE_COVERS AS
SELECT pp.policy_id
      ,pp.version_num
      ,pp.pol_header_id
      ,aa.as_asset_id
      ,aa.p_asset_header_id
      ,aa.ins_amount               asset_ins_amount
      ,aa.fee                      asset_fee
      ,aa.start_date               asset_start_date
      ,aa.end_date                 asset_end_date
      ,aa.ins_premium              asset_premium
      ,pl.id                       product_line_id
      ,pl.description              product_line_desc
      ,pl.public_description
      ,plo.id                      prod_line_option_id
      ,plo.description             prod_line_option_desc
      ,plo.brief                   prod_line_option_brief
      ,pc.p_cover_id
      ,pc.start_date               cover_start_date
      ,pc.end_date                 cover_end_date
      ,pc.ins_amount
      ,pc.premium
      ,pc.tariff
      ,pc.fee
      ,pc.rvb_value
      ,pc.k_coef
      ,pc.s_coef
      ,pc.premia_base_type
      ,pc.normrate_value
      ,pc.k_coef_m
      ,pc.k_coef_nm
      ,pc.s_coef_m
      ,pc.s_coef_nm
      ,pc.tariff_netto
      ,pc.is_handchange_amount
      ,pc.is_handchange_premium
      ,pc.is_handchange_tariff
      ,pc.is_handchange_deduct
      ,pc.is_handchange_ins_amount
      ,pc.is_handchange_k_coef_nm
      ,pc.is_handchange_s_coef_nm
			,pl.fee_round_rules_id
			,pl.ins_amount_round_rules_id
      ,pl.product_line_type_id
  FROM p_policy           pp
      ,as_asset           aa
      ,p_cover            pc
      ,t_prod_line_option plo
      ,t_product_line     pl
 WHERE pp.policy_id = aa.p_policy_id
   AND aa.as_asset_id = pc.as_asset_id
   AND pc.t_prod_line_option_id = plo.id
   AND plo.product_line_id = pl.id
   AND aa.status_hist_id IN (pkg_cover.get_status_hist_id_new, pkg_cover.get_status_hist_id_curr)
   AND pc.status_hist_id IN (pkg_cover.get_status_hist_id_new, pkg_cover.get_status_hist_id_curr);
