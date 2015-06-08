CREATE OR REPLACE PACKAGE pkg_prdlifenormrate IS

  FUNCTION INVESTOR_LUMP_ALPHA_get_value(par_cover_id NUMBER) RETURN NUMBER;

END pkg_prdlifenormrate;
/
CREATE OR REPLACE PACKAGE BODY pkg_prdlifenormrate IS

  FUNCTION INVESTOR_LUMP_ALPHA_get_value(par_cover_id NUMBER) RETURN NUMBER IS
    v_result        NUMBER;
    v_agent_num     document.num%TYPE;
    v_pol_header_id NUMBER;
  BEGIN
  
    SELECT pp.pol_header_id
      INTO v_pol_header_id
      FROM p_cover  pc
          ,as_asset aa
          ,p_policy pp
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    BEGIN
      SELECT num
        INTO v_agent_num
        FROM document
       WHERE document_id = pkg_agn_control.get_current_policy_agent(v_pol_header_id);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    CASE v_agent_num
      WHEN '44730' THEN
        v_result := 0.02;
      ELSE
        v_result := 0.001;
    END CASE;
    RETURN v_result;
  
  END;

BEGIN
  -- Initialization
  NULL;
END pkg_prdlifenormrate;
/
