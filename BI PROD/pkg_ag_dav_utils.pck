CREATE OR REPLACE PACKAGE Pkg_Ag_DAV_UTILS IS
  PROCEDURE dav_razmaz(doc_id IN NUMBER);
END Pkg_Ag_DAV_UTILS;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Ag_DAV_UTILS IS
  PROCEDURE dav_razmaz(doc_id IN NUMBER) IS
  
    CURSOR cur_ag_report(cv_doc_id NUMBER) IS
      SELECT t.BRIEF
        FROM AGENT_REPORT AR
            ,T_AG_AV      T
       WHERE ar.T_AG_AV_ID = T.T_AG_AV_ID
         AND ar.AGENT_REPORT_ID = cv_doc_id;
  
    rec_ag_report cur_ag_report%ROWTYPE;
  
  BEGIN
  
    OPEN cur_ag_report(doc_id);
    FETCH cur_ag_report
      INTO rec_ag_report;
  
    CLOSE cur_ag_report;
  
    IF (rec_ag_report.BRIEF <> 'ДАВ')
    THEN
      RETURN;
    END IF;
  
    /*удаляем старое размазывание*/
    DELETE FROM VEN_AGENT_REPORT_CONT v WHERE v.AGENT_REPORT_ID = doc_id;
  
    INSERT INTO VEN_AGENT_REPORT_CONT
      (AGENT_REPORT_CONT_ID
      ,COMISSION_SUM
      ,AGENT_REPORT_ID
      ,IS_DEDUCT
      ,EXT_ID
      ,P_POLICY_AGENT_COM_ID
      ,TRANS_ID
      ,AG_TYPE_RATE_VALUE_ID
      ,PART_AGENT
      ,SAV
      ,POLICY_ID
      ,DATE_PAY
      ,SUM_PREMIUM
      ,SUM_RETURN
      ,METHOD_PAYMENT
      ,PROD_LINE_OPTION_ID
      ,P_COVER_ID)
      SELECT --sum (DAV_BY_PCOVER) over (partition by AGENT_REPORT_DAV_ID) as DAV_BY_PCOVER_SUMM, /*контрольная сумма*/
       sq_AGENT_REPORT_CONT.NEXTVAL
      ,DAV_BY_PCOVER AS COMISSION_SUM
      , /*деньги*/AGENT_REPORT_ID
      ,0
      ,NULL
      ,P_POLICY_AGENT_COM_ID AS P_POLICY_AGENT_COM_ID
      ,NULL
      ,(SELECT T.AG_TYPE_RATE_VALUE_ID FROM AG_TYPE_RATE_VALUE T WHERE T.BRIEF = 'ABSOL') AS AG_TYPE_RATE_VALUE_ID
      ,NULL
      ,PERCENT AS SAV
      , /*процент*/POLICY_ID AS POLICY_ID
      , /*договор*/NULL
      ,NULL
      ,NULL
      ,NULL
      ,T_PROD_LINE_OPTION_ID AS PROD_LINE_OPTION_ID
      ,P_COVER_ID AS P_COVER_ID /*покрытие*/
        FROM (SELECT a.AGENT_REPORT_DAV_ID
                    ,A.AGENT_REPORT_ID
                    ,PP.POLICY_ID
                    ,PC.P_COVER_ID
                    ,PC.T_PROD_LINE_OPTION_ID
                    ,ROUND((a.PREMIUM / A.S) * 100, 2) AS PERCENT
                    ,(CASE rn
                       WHEN 1 THEN
                        ROUND((a.PREMIUM / A.S) * a.COMISSION_SUM, 2) + a.COMISSION_SUM -
                        SUM(ROUND((a.PREMIUM / A.S) * a.COMISSION_SUM, 2))
                        OVER(PARTITION BY a.AGENT_REPORT_DAV_ID)
                       ELSE
                        ROUND((a.PREMIUM / A.S) * a.COMISSION_SUM, 2)
                     END) AS DAV_BY_PCOVER
                    ,a.COMISSION_SUM AS DAV_SUM
                    ,a.s AS SUM_P_COVER_PREMIUM
                    ,a.P_POLICY_AGENT_COM_ID AS P_POLICY_AGENT_COM_ID
                FROM (SELECT ROWNUM AS rn
                            ,pc.PREMIUM
                            ,SUM(pc.PREMIUM) OVER(PARTITION BY AD.COMISSION_SUM) AS S
                            ,AD.COMISSION_SUM
                            ,a.POLICY_ID
                            ,a.P_COVER_ID
                            ,a.AGENT_REPORT_DAV_ID
                            ,AD.AGENT_REPORT_ID
                            ,a.P_POLICY_AGENT_COM_ID
                        FROM v_agent_report_dav_pcover2 a
                            ,p_cover                    pc
                            ,AGENT_REPORT_DAV_CT        ADC
                            ,VEN_AGENT_REPORT_DAV       AD
                       WHERE AD.agent_report_id = doc_id -- вставляем тут! что бы быстро работало
                         AND a.p_cover_id = pc.p_cover_id
                         AND ADC.AGENT_REPORT_DAV_CT_ID = a.AGENT_REPORT_DAV_CT_ID
                         AND AD.AGENT_REPORT_DAV_ID = a.agent_report_dav_id) A
                    ,P_COVER PC
                    ,P_POLICY PP
               WHERE PC.P_COVER_ID = a.P_COVER_ID
                 AND PP.POLICY_ID = a.POLICY_ID
               ORDER BY pc.T_PROD_LINE_OPTION_ID) B;
    --where B.agent_report_dav_id = p_agent_dav_id;
  
  END dav_razmaz;
END Pkg_Ag_DAV_UTILS;
/
