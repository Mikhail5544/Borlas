CREATE OR REPLACE FORCE VIEW V_ISRECRUTCALCBYDATE AS
SELECT c.max_day FROM ( 
    SELECT 
     MAX (c_day) AS max_day, 
     b.contract_leader_id 
    FROM 
    (SELECT 
        (CASE A.day_count 
        WHEN 0 THEN  day_count_to_current_date 
        ELSE A.day_count 
        END 
      )  AS c_day, 
     A.*  FROM ( 
        SELECT   ( 
                   FIRST_VALUE (a.date_begin) OVER (ORDER BY a.date_begin DESC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) 
                 - 
                 a.date_begin 
                 ) AS day_count, 
           ( 
             PKG_REP_UTILS2.dGetVal('cv_date')  - 
                   a.date_begin 
                 ) AS day_count_to_current_date, 
                    ag_lead.contract_id AS contract_leader_id, 
              a.ag_contract_id, 
                    a.date_begin 
               FROM ag_contract a, AG_CONTRACT ag_lead 
              WHERE a.contract_id = PKG_REP_UTILS2.iGetVal('cv_ag_header_agent') 
              AND ag_lead.AG_CONTRACT_ID = a.contract_leader_id 
              ) A 
    ) B GROUP BY b.contract_leader_id ) C 
    WHERE c.contract_leader_id = PKG_REP_UTILS2.iGetVal('cv_ag_header_lead');

