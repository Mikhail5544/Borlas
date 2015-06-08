CREATE OR REPLACE FORCE VIEW V_DECLINE_DETAILS AS
SELECT  a.p_policy_id policy_id,
   a.as_asset_id asset_id,
    ent.obj_name(a.ent_id, a.as_asset_id) asset_name,
  p.p_cover_id cover_id,
  pl.ID prod_line_id,
  pl.description prod_line_name,
  DECODE(plt.brief,'RECOMMENDED','ням','дно') prod_line_type,
  --decode(plt.brief,'RECOMMENDED',1,0) is_prod_line_main_flag,
  pol.start_date start_date,
  pol.end_date end_date,
  plo.ID prod_line_option_id,
  p.added_summ,
  p.payed_summ,
  p.debt_summ,
  p.return_summ,
  p.decline_summ,
    p.payed_summ - NVL(p.return_summ,0) - NVL(p.add_exp_sum,0) - NVL(p.ag_comm_sum,0) - NVL(p.payoff_sum,0) zsp_sum,
    p.add_exp_sum,
    p.ag_comm_sum,
    p.payoff_sum
 FROM
     AS_ASSET a,
  P_COVER p,
  T_PRODUCT_LINE pl,
  T_PROD_LINE_OPTION plo,
  T_PRODUCT_LINE_TYPE plt,
  P_POLICY pol
WHERE
   a.as_asset_id = p.as_asset_id
 AND a.p_policy_id = pol.policy_id
 AND p.T_PROD_LINE_OPTION_ID = plo.ID
 AND plo.PRODUCT_LINE_ID = pl.ID
 AND pl.PRODUCT_LINE_TYPE_ID = plt.PRODUCT_LINE_TYPE_ID(+)
;

