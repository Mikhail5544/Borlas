CREATE OR REPLACE PACKAGE pkg_policy_stop IS

  PROCEDURE stop_policy(p_stop_date IN DATE DEFAULT SYSDATE);
  PROCEDURE start_job;
  PROCEDURE stop_job;

END pkg_policy_stop;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_stop IS

  v_job_code VARCHAR2(2000) := 'begin pkg_policy_stop.stop_policy; commit; end;';

  PROCEDURE start_job IS
    c NUMBER;
  BEGIN
    FOR rc IN (SELECT job FROM USER_JOBS j WHERE j.what = v_job_code)
    LOOP
      DBMS_OUTPUT.PUT_LINE('job already run');
      RETURN;
    END LOOP;
  
    DBMS_JOB.SUBMIT(c, v_job_code, SYSDATE, 'trunc(sysdate+1)+1/24/60');
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

  PROCEDURE stop_policy(p_stop_date IN DATE DEFAULT SYSDATE) IS
    v_status_id NUMBER;
    v_mode_id   NUMBER;
  BEGIN
  
    SELECT dsr.doc_status_ref_id
          ,sct.status_change_type_id
      INTO v_status_id
          ,v_mode_id
      FROM DOC_STATUS_REF     dsr
          ,STATUS_CHANGE_TYPE sct
     WHERE dsr.brief = 'STOPED'
       AND sct.brief = 'AUTO';
  
    FOR rc IN (SELECT p.policy_id
                     ,p.end_date
                 FROM P_POL_HEADER   ph
                     ,P_POLICY       p
                     ,DOC_STATUS     ds
                     ,DOC_STATUS_REF dsr
                     ,T_PRODUCT      tp
                WHERE ph.policy_id = p.policy_id
                  AND ph.product_id = tp.product_id
                  AND (tp.brief = 'ОСАГО' OR ents.client_id = 11)
                  AND p.end_date < TRUNC(NVL(p_stop_date, SYSDATE), 'dd')
                  AND ds.document_id = p.policy_id
                  AND ds.start_date = (SELECT MAX(dsm.start_date)
                                         FROM DOC_STATUS dsm
                                        WHERE dsm.document_id = p.policy_id)
                  AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                  AND dsr.brief = 'CURRENT')
    LOOP
      BEGIN
        doc.set_doc_status(rc.policy_id
                          ,v_status_id
                          ,rc.end_date
                          ,v_mode_id
                          ,'Автоматическая процедура завершения полиса');
      EXCEPTION
        WHEN OTHERS THEN
          -- todo
          -- some actions to report about mistakes when change status to stopped    
          DBMS_OUTPUT.PUT_LINE(SQLERRM);
      END;
    
    END LOOP;
  END;
END pkg_policy_stop;
/
