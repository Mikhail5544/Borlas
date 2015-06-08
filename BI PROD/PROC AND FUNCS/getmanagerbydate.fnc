CREATE OR REPLACE FUNCTION GetManagerByDate(p_date      date,
                                            p_ag_header number)
  RETURN VARCHAR2 IS
  res_proc CONTACT%ROWTYPE;
BEGIN
  select CON.*
    into res_proc
    from (/*SELECT NVL(ag.contract_leader_id, ag.ag_contract_id) res
            FROM (SELECT a.ag_contract_id
                    FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m,
                                 ac.ag_contract_id
                            FROM ag_contract ac
                           WHERE ac.date_begin < p_date
                             and ac.CONTRACT_ID = p_ag_header) a
                   WHERE a.m = a.ag_contract_id) b,
                 ag_contract ag
           WHERE b.ag_contract_id = ag.ag_contract_id*/
           
          SELECT NVL(ag.contract_leader_id, ag.ag_contract_id) res
          from  ag_contract ag
          where ag.contract_id = p_ag_header and
                ag.date_begin in ( select max( ag1.date_begin )
                                     from ag_contract ag1
                                    where ag1.contract_id = ag.contract_id and
                                          ag1.date_begin < p_date)
          
                     
           
           ) C,
         AG_CONTRACT_HEADER AG_C,
         AG_CONTRACT AGG,
         CONTACT CON
   where AGG.AG_CONTRACT_ID = C.res
     and AG_C.AG_CONTRACT_HEADER_ID = AGG.CONTRACT_ID
     and CON.CONTACT_ID = AG_C.AGENT_ID
     and rownum = 1;
  return res_proc.NAME || ' ' || res_proc.FIRST_NAME || ' ' || res_proc.MIDDLE_NAME;
END GetManagerByDate;
/

