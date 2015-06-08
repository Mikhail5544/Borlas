CREATE OR REPLACE FORCE VIEW V_RE_SLIP_DAMAGE AS
SELECT  DISTINCT 
  rsh.RE_SLIP_HEADER_ID
, rc.P_ASSET_HEADER_ID
, rc.T_PRODUCT_LINE_ID
FROM ven_re_slip_header rsh
   , ven_re_slip rs
   , ven_re_cover rc
   , as_asset aa
   , t_prod_line_option plo 
   , p_cover pc
   , ven_c_claim_header cch
   , ven_c_event ce
   , ven_c_claim cc
   , ven_c_damage cd
WHERE rs.re_slip_header_id = rsh.re_slip_header_id
  AND rc.re_slip_id = rs.re_slip_id
  AND plo.PRODUCT_LINE_ID = rc.T_PRODUCT_LINE_ID
  AND aa.P_ASSET_HEADER_ID = rc.P_ASSET_HEADER_ID
  AND pc.as_asset_id = aa.as_asset_id
  AND pc.T_PROD_LINE_OPTION_ID = plo.ID
  AND cch.P_COVER_ID = pc.P_COVER_ID
  AND ce.C_EVENT_ID = cch.C_EVENT_ID
  AND cc.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID
  AND cd.C_CLAIM_ID = cc.C_CLAIM_ID
  AND EXISTS ( 
     SELECT 2 
       FROM re_slip rs2
          , re_slip_header rsh2
       WHERE rs2.re_slip_header_id = rsh2.re_slip_header_id--!!!!!
       HAVING MIN(rs2.START_DATE) <= NVL(ce.event_date, ce.DATE_DECLARE)
          AND MAX(NVL(rs2.FACT_END_DATE, rs2.end_date)) >= NVL(ce.event_date, ce.DATE_DECLARE)
       GROUP BY rs2.re_slip_header_id)
;

