CREATE OR REPLACE PACKAGE pkg_autoprolong IS

  PROCEDURE stop_job;
  PROCEDURE start_job;
  PROCEDURE start_autoprolong(p_Date IN DATE DEFAULT SYSDATE);

END pkg_autoprolong;
/
CREATE OR REPLACE PACKAGE BODY pkg_autoprolong IS

  v_job_code VARCHAR2(100) := 'begin pkg_autoprolong.start_autoprolong; commit; end;';

  PROCEDURE start_job IS
    c NUMBER;
  BEGIN
    FOR rc IN (SELECT job FROM USER_JOBS j WHERE j.what = v_job_code)
    LOOP
      DBMS_OUTPUT.PUT_LINE('job already run');
      RETURN;
    END LOOP;
  
    DBMS_JOB.SUBMIT(c, v_job_code, SYSDATE, 'trunc(sysdate+1)');
    COMMIT;
  END;

  PROCEDURE stop_job IS
  BEGIN
    FOR rc IN (SELECT job FROM USER_JOBS j WHERE j.what = v_job_code)
    LOOP
      DBMS_JOB.REMOVE(rc.job);
      COMMIT;
    END LOOP;
  END;

  PROCEDURE start_autoprolong(p_Date IN DATE DEFAULT SYSDATE) IS
    v_new_id NUMBER;
    v_date   DATE := TRUNC(p_date, 'dd');
    c        NUMBER;
  BEGIN
    FOR rc IN (SELECT aa.p_policy_id
                     ,ph.policy_header_id
                 FROM P_COVER            pc
                     ,T_PROD_LINE_OPTION plo
                     ,T_PRODUCT_LINE     pl
                     ,AS_ASSET           aa
                     ,P_POL_HEADER       ph
                WHERE pc.end_date >= v_date
                  AND pc.end_date < v_date + 1
                  AND aa.as_asset_id = pc.as_asset_id
                  AND pl.ID = plo.product_line_id
                  AND plo.ID = pc.t_prod_line_option_id
                  AND pl.is_avtoprolongation = 1
                  AND aa.p_policy_id = ph.policy_id
                GROUP BY aa.p_policy_id
                        ,ph.policy_header_id)
    LOOP
    
      SELECT COUNT(*)
        INTO c
        FROM P_POLICY            pp
            ,P_POL_ADDENDUM_TYPE pat
            ,T_ADDENDUM_TYPE     ATT
       WHERE pp.pol_header_id = rc.policy_header_id
         AND pp.start_date = v_date + 1
         AND pat.p_policy_id = pp.policy_id
         AND att.t_addendum_type_id = pat.t_addendum_type_id
         AND att.brief = 'Автопролонгация';
    
      IF c = 0
      THEN
        BEGIN
          SAVEPOINT start_loop;
          v_new_id := pkg_policy.new_policy_version(rc.p_policy_id);
        
          UPDATE P_POLICY pp
             SET pp.start_date            = v_date + 1
                ,pp.confirm_date_addendum = v_date + 1
           WHERE pp.policy_id = v_new_id;
        
          INSERT INTO ven_p_pol_addendum_type
            (p_policy_id, t_addendum_type_id)
            SELECT v_new_id
                  ,t.t_addendum_type_id
              FROM T_ADDENDUM_TYPE t
             WHERE t.description = 'Автопролонгация';
        
          pkg_policy.update_policy_dates(v_new_id);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO SAVEPOINT start_loop;
        END;
      END IF;
    END LOOP;
  END;

END pkg_autoprolong;
/
