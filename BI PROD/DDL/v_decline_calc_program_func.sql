CREATE OR REPLACE VIEW V_DECLINE_CALC_PROGRAM_FUNC
AS
SELECT cp.t_decline_calc_program_id
      ,cp.t_decline_calc_policy_id
      ,cp.t_product_line_id
      ,cp.policy_surr_existence
      ,pl.description AS product_line_name
      ,cp.policy_surrender
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.policy_surrender) AS policy_surrender_name
      ,cp.add_policy_surrender
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.add_policy_surrender) AS add_policy_surrender_name
      ,cp.did
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.did) AS did_name
      ,cp.vchp
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.vchp) AS vchp_name
      ,cp.rvd_by_risk
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.rvd_by_risk) AS rvd_by_risk_name
      ,cp.underpayment_previous
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.underpayment_previous) AS underpayment_prev_name
      ,cp.underpayment_current
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.underpayment_current) AS underpayment_current_name
      ,cp.underpayment_lp
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.underpayment_lp) AS underpayment_lp_name
      ,cp.underpayment_fact
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.underpayment_fact) AS underpayment_fact_name
      ,cp.premium_previous
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.premium_previous) AS premium_previous_name
      ,cp.premium_current
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.premium_current) AS premium_current_name
      ,cp.premium_msfo
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.premium_msfo) AS premium_msfo_name
      ,cp.unpayed_premium_previous
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.unpayed_premium_previous) AS unpayed_premium_prev_name
      ,cp.unpayed_premium_current
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.unpayed_premium_current) AS unpayed_premium_curr_name
      ,cp.unpayed_premium_lp
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.unpayed_premium_lp) AS unpayed_premium_lp_name
      ,cp.unpayed_msfo_prem_correction
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.unpayed_msfo_prem_correction) AS unpayed_msfo_prem_corr_name
      ,cp.overpayment
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.overpayment) AS overpayment_name
  FROM t_decline_calc_program cp
      ,t_product_line pl
 WHERE cp.t_product_line_id = pl.id(+);
GRANT SELECT ON V_DECLINE_CALC_PROGRAM_FUNC TO INS_READ;
