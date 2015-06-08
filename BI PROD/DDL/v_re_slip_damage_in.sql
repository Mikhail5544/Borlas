CREATE OR REPLACE FORCE VIEW V_RE_SLIP_DAMAGE_IN AS
SELECT  DISTINCT
  rsh.RE_SLIP_HEADER_ID
, rc.P_ASSET_HEADER_ID
, rc.T_PRODUCT_LINE_ID
FROM ven_re_slip_header rsh
   , ven_re_slip rs
   , ven_re_cover rc
WHERE rs.re_slip_header_id = rsh.re_slip_header_id
  AND rc.re_slip_id = rs.re_slip_id
  AND rsh.IS_IN = 1;

