CREATE OR REPLACE VIEW V_DECLINE_CALC_POLICY_FUNC
AS
SELECT cp.t_decline_calc_policy_id
      ,cp.t_policyform_product_id
      ,cp.t_decline_reason_id
      ,dr.name AS DECLINE_REASON_NAME
      ,cp.rvd_percent
      ,cp.additional_condition
      ,cp.court_costs
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.court_costs) AS court_costs_name
      ,cp.early_termination_return_sum
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.early_termination_return_sum) AS early_term_return_sum_name
      ,cp.underpayment_from_payment
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.underpayment_from_payment) AS underpayment_from_payment_name
      ,cp.fact_underpayment
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.fact_underpayment) AS fact_underpayment_name
      ,cp.medo_costs
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.medo_costs) AS medo_costs_name
      ,cp.ndfl
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.ndfl) AS ndfl_name
      ,cp.total
      ,(SELECT dm.name FROM t_decline_method dm WHERE dm.t_decline_method_id = cp.total) AS total_name
  FROM t_decline_calc_policy cp
      ,t_decline_reason      dr
 WHERE cp.t_decline_reason_id = dr.t_decline_reason_id;
GRANT SELECT ON V_DECLINE_CALC_POLICY_FUNC TO INS_READ;
