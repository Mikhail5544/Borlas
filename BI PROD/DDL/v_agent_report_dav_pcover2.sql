CREATE OR REPLACE FORCE VIEW V_AGENT_REPORT_DAV_PCOVER2 AS
SELECT a.AGENT_REPORT_DAV_CT_ID, 
    a.AGENT_REPORT_DAV_ID, 
    a.SGP, 
    pp.num, 
    a.POLICY_ID, 
    PPAC.VAL_COM, 
    P_COVER.P_COVER_ID, 
    PPAC.P_POLICY_AGENT_COM_ID 
    FROM 
    AGENT_REPORT_DAV_CT a, 
    P_POLICY_AGENT_COM PPAC, 
    P_POLICY_AGENT PPA, 
    ven_P_POLICY PP, 
    T_PROD_LINE_OPTION TPLO, 
    /*�� ������� ������*/ 
    AS_ASSET, 
    P_COVER 
 WHERE --a.AGENT_REPORT_DAV_ID = 137553 
   PP.POLICY_ID = a.POLICY_ID 
 AND PPA.POLICY_HEADER_ID = PP.POL_HEADER_ID 
 AND PPAC.P_POLICY_AGENT_ID = PPA.P_POLICY_AGENT_ID 
 AND TPLO.PRODUCT_LINE_ID =  PPAC.T_PRODUCT_LINE_ID 
 AND AS_ASSET.P_POLICY_ID = a.POLICY_ID 
 AND AS_ASSET.AS_ASSET_ID = P_COVER.AS_ASSET_ID 
 AND P_COVER.T_PROD_LINE_OPTION_ID = TPLO.ID 
-- order by 1
;

