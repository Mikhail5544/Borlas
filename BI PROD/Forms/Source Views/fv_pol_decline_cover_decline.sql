create or replace view fv_pol_decline_cover_decline as
SELECT cd.cover_period
      ,cd.redemption_sum
      ,cd.add_invest_income
      ,cd.return_bonus_part
			,cd.add_policy_surrender
      ,cd.admin_expenses
      ,cd.bonus_off_prev
      ,cd.bonus_off_current
      ,cd.underpayment_actual
      ,cd.p_cover_decline_id
      ,cd.p_pol_decline_id
      ,cd.as_asset_id
      ,cd.t_product_line_id
      ,cd.unpayed_premium_previous
      ,cd.unpayed_premium_current
      ,cd.unpayed_premium_lp
      ,cd.unpayed_msfo_prem_correction
      ,cd.premium_msfo
      ,cd.overpayment
      ,cd.underpayment_previous
      ,cd.underpayment_current
      ,cd.underpayment_lp
      ,fn_obj_name(aa.ent_id, aa.as_asset_id) AS asset_name
      ,pl.description AS cover_name
  FROM p_cover_decline cd
      ,t_product_line  pl
      ,as_asset        aa
 WHERE cd.t_product_line_id = pl.id(+)
   AND cd.as_asset_id = aa.as_asset_id(+);
	
grant select on fv_pol_decline_cover_decline to ins_read;	
	
