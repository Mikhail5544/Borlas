CREATE OR REPLACE PACKAGE PKG_RE_BORDERO_2 IS

  PROCEDURE Calculate(p_doc_id NUMBER);

  PROCEDURE JobCalculate(p_doc_id NUMBER);

  -- вешаем на статус создания пакета
  PROCEDURE CreateNewBordero(p_doc_id NUMBER);

  FUNCTION GetCalculateNo RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY PKG_RE_BORDERO_2 IS

  g_debug BOOLEAN := TRUE;

  g_CalculateNo NUMBER;

  PROCEDURE LOG
  (
    p_object_id IN NUMBER
   ,p_message   IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO RE_BORDERO_DEBUG
        (object_id, execution_date, operation_type, debug_message)
      VALUES
        (p_object_id, SYSDATE, 'PKG_RE_BORDERO_2', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE JobCalculate(p_doc_id NUMBER) IS
  
    --job_x number;
    sql_exec VARCHAR2(400);
  
  BEGIN
  
    LOG(p_doc_id, 'JOBCALCULATE ');
  
    sql_exec := 'begin 
                  UPDATE document d 
                     SET d.note = null
                   WHERE d.document_id =' || p_doc_id || '; ' || 'COMMIT; ' ||
                'PKG_RE_BORDERO_2.Calculate (' || p_doc_id || '); commit; end;';
  
    UPDATE document d
       SET d.note = 'В очереди на расчет ' || to_char(SYSDATE, 'DD.MM.YYYY HH24:Mi:SS')
     WHERE d.document_id = p_doc_id;
  
    pkg_scheduler.Run_scheduled('RE_BORDERO_CALC', sql_exec, 0);
  
    /*    SYS.DBMS_JOB.SUBMIT(job       => job_x,
                          what      => sql_exec,
                          next_date => sysdate,
                          no_parse  => FALSE);
    */
  END;

  PROCEDURE Calculate(p_doc_id NUMBER) AS
  
  BEGIN
  
    SELECT SQ_FILL_BORDERO.nextval INTO g_CalculateNo FROM DUAL;
  
    LOG(p_doc_id, 'CALCULATE ');
  
    FOR irec IN (SELECT r.*
                   FROM VEN_RE_BORDERO      r
                       ,VEN_RE_BORDERO_TYPE t
                  WHERE R.FLG_CALC = 1
                    AND R.RE_BORDERO_PACKAGE_ID = p_doc_id
                    AND T.RE_BORDERO_TYPE_ID = R.RE_BORDERO_TYPE_ID
                  ORDER BY T.PRIOR_CALC ASC)
    LOOP
    
      pkg_reins.fill_bordero(irec.RE_BORDERO_PACKAGE_ID, irec.RE_BORDERO_ID);
    
    END LOOP;
    --  Изменяем флаг после пересчета бордеро    
    UPDATE VEN_RE_BORDERO r
       SET FLG_CALC = 0
     WHERE R.FLG_CALC = 1
       AND R.RE_BORDERO_PACKAGE_ID = p_doc_id;
  
    DOC.SET_DOC_STATUS(p_doc_id, 'FINISH_CALCULATE', SYSDATE, 'AUTO');
  
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_err_msg VARCHAR2(4000) := SQLERRM;
      BEGIN
        UPDATE document d SET d.note = substr(v_err_msg, 0, 4000) WHERE d.document_id = p_doc_id;
        DOC.SET_DOC_STATUS(p_doc_id, 'ERROR_CALCULATE', SYSDATE, 'AUTO', SUBSTR(v_err_msg, 0, 250));
      END;
  END Calculate;

  PROCEDURE CreateNewBordero(p_doc_id NUMBER) AS
  
    rec_RE_BORDERO ven_RE_BORDERO%ROWTYPE;
  
    is_found NUMBER := 0;
  
  BEGIN
    LOG(p_doc_id, 'CREATENEWBORDERO');
  
    FOR irec IN (SELECT *
                   FROM RE_BORDERO_TYPE b
                  WHERE B.SHORT_NAME IS NOT NULL
                  ORDER BY RE_BORDERO_TYPE_ID)
    LOOP
    
      FOR irec2 IN (SELECT * FROM ven_fund v WHERE V.IS_ACTIVE = 1 ORDER BY code)
      LOOP
      
        is_found := 0;
      
        --          for irec3 in (
        --           select * from RE_BORDERO rb where 
        --               RB.RE_BORDERO_PACKAGE_ID =  p_doc_id
        --           and RB.FUND_ID = irec2.fund_id
        --           and RB.RE_BORDERO_TYPE_ID = irec.RE_BORDERO_TYPE_ID
        --          )
        --           loop
        --            
        --            is_found := 1;
        --           
        --          end loop;
      
        IF (is_found = 0)
        THEN
        
          log(1, 'is_found:= 0');
        
          rec_RE_BORDERO.DOC_TEMPL_ID := 221;
          --               rec_RE_BORDERO.NOTE := ;
          --               rec_RE_BORDERO.NUM := ;
          rec_RE_BORDERO.REG_DATE := SYSDATE;
          --               rec_RE_BORDERO.ACCEPT_DATE := ;
          rec_RE_BORDERO.BRUTTO_PREMIUM := 0;
          rec_RE_BORDERO.COMMISSION     := 0;
          rec_RE_BORDERO.DECLARED_SUM   := 0;
          rec_RE_BORDERO.FLG_CALC       := 1;
          --rec_RE_BORDERO.FLG_DATE_RATE := SYSDATE;
          rec_RE_BORDERO.FUND_ID               := irec2.fund_id;
          rec_RE_BORDERO.FUND_PAY_ID           := irec2.fund_id;
          rec_RE_BORDERO.IS_CALC               := 0;
          rec_RE_BORDERO.NETTO_PREMIUM         := 0;
          rec_RE_BORDERO.PAYMENT_SUM           := 0;
          rec_RE_BORDERO.RATE_TYPE_ID          := 1;
          rec_RE_BORDERO.RATE_VAL              := 0;
          rec_RE_BORDERO.REGRESS_SUM           := 0;
          rec_RE_BORDERO.RETURN_SUM            := 0;
          rec_RE_BORDERO.RE_BORDERO_PACKAGE_ID := p_doc_id;
          rec_RE_BORDERO.RE_BORDERO_TYPE_ID    := irec. RE_BORDERO_TYPE_ID;
        
          log(p_doc_id
             ,'CREATENEWBORDERO RE_BORDERO_PACKAGE_ID:= ' || rec_RE_BORDERO.RE_BORDERO_PACKAGE_ID ||
              ' BORDERO NAME ' || irec.name || ' RE_BORDERO_TYPE_ID ' ||
              rec_RE_BORDERO.RE_BORDERO_TYPE_ID || ' FUND_ID ' || rec_RE_BORDERO.FUND_ID);
        
          INSERT INTO ven_RE_BORDERO VALUES rec_RE_BORDERO;
        
          LOG(p_doc_id, 'CREATENEWBORDERO ADD BORDERO SUCCESFUL');
        
        END IF;
      
      END LOOP;
    
    END LOOP;
  
    LOG(p_doc_id, 'CREATENEWBORDERO RETURN');
  
  EXCEPTION
    WHEN OTHERS THEN
      log(1, SQLERRM);
      RAISE;
    
  END CreateNewBordero;

  FUNCTION GetCalculateNo RETURN NUMBER IS
  BEGIN
    RETURN g_CalculateNo;
  END;

END;
/
