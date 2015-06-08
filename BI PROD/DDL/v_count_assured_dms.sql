CREATE OR REPLACE FORCE VIEW V_COUNT_ASSURED_DMS AS
SELECT COUNT(aa.as_asset_id) count_a
     , pp.policy_id
     , pld.t_prod_line_dms_id 
FROM ven_as_asset aa
   , ven_p_policy pp
   , ven_p_cover pc
   , ven_t_prod_line_option plo
   , ven_t_prod_line_dms pld
   , status_hist sh
WHERE aa.p_policy_id = pp.policy_id
AND pc.as_asset_id = aa.as_asset_id
AND plo.ID = pc.t_prod_line_option_id
AND pld.t_prod_line_dms_id = plo.product_line_id
AND sh.BRIEF <> 'DELETED'
AND pc.STATUS_HIST_ID = sh.STATUS_HIST_ID
GROUP BY pp.policy_id, pld.t_prod_line_dms_id;

