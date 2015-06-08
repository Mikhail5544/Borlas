CREATE OR REPLACE PACKAGE pkg_payment_11 IS
  FUNCTION policy_id_for_schedule(p_p_policy_id IN NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_payment_11 IS
  FUNCTION policy_id_for_schedule(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    v_policy_id      NUMBER;
    v_prev_policy_id NUMBER;
    v_status         VARCHAR(30);
    v_version_num    NUMBER;
    v_ret_val        NUMBER;
  BEGIN
  
    SELECT *
      INTO v_policy_id
          ,v_version_num
          ,v_status
          ,v_prev_policy_id
      FROM (SELECT t.policy_id
                  ,t.version_num
                  ,t.status
                  ,lead(t.policy_id, 1) OVER(ORDER BY t.version_num DESC)
              FROM (SELECT p.policy_id
                          ,p.version_num
                          ,Doc.get_last_doc_status_brief(p.policy_id) status
                      FROM P_POLICY p
                     WHERE p.pol_header_id =
                           (SELECT pol_header_id FROM p_policy pp WHERE policy_id = p_p_policy_id)) t
            --where t.status in ('NEW','PROJECT', 'CURRENT', 'BREAK')
             ORDER BY t.version_num DESC)
     WHERE ROWNUM = 1;
  
    IF v_status = 'INDEXATING'
    THEN
      v_ret_val := v_prev_policy_id;
    ELSE
      v_ret_val := p_p_policy_id;
    END IF;
  
    RETURN v_ret_val;
  END;
END;
/
