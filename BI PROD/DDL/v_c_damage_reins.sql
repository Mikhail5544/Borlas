CREATE OR REPLACE FORCE VIEW V_C_DAMAGE_REINS AS
SELECT cd.c_damage_id
     , rd.re_damage_id
     , rd.re_claim_id
     , rc.re_cover_id
     , rc.p_cover_id
     , cc.c_claim_id
     , cch.c_claim_header_id
     , rs.re_slip_header_id
FROM ven_c_claim_header cch
   , ven_c_claim cc
   , ven_c_damage cd
   , ven_re_cover rc
   , ven_re_damage rd
   , ven_p_cover pc
   , t_prod_line_option plo
   , as_asset aa
   , re_slip rs
WHERE cc.c_claim_header_id = cch.c_claim_header_id
  AND cd.c_claim_id = cc.c_claim_id
  AND pc.p_cover_id = cch.p_cover_id
  AND plo.ID = pc.T_PROD_LINE_OPTION_ID
  AND aa.as_asset_id = pc.as_asset_id
  AND rc.T_PRODUCT_LINE_ID = plo.PRODUCT_LINE_ID
  AND rc.P_ASSET_HEADER_ID = aa.P_ASSET_HEADER_ID
  AND rs.re_slip_id = rc.re_slip_id
  AND cd.c_damage_id = rd.damage_id
  AND rd.RE_COVER_ID = rc.re_cover_id;

