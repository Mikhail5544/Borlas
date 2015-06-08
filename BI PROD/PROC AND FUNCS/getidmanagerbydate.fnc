CREATE OR REPLACE FUNCTION GetIdManagerByDate (p_date date, p_ag_header number) RETURN number  IS
  res_proc number;
  BEGIN

select
acc.contract_id into res_proc 
from  (
 SELECT NVL (ag.contract_leader_id, ag.ag_contract_id) res
  FROM (SELECT a.ag_contract_id
          FROM (SELECT MAX (ac.ag_contract_id) OVER (PARTITION BY ac.contract_id) m,
                       ac.ag_contract_id
                  FROM ag_contract ac
                 WHERE ac.date_begin <=p_date
     and ac.CONTRACT_ID = p_ag_header
     ) a
         WHERE a.m = a.ag_contract_id) b,
       ag_contract ag
 WHERE b.ag_contract_id = ag.ag_contract_id ) C,
 AG_CONTRACT acc
 where acc.AG_CONTRACT_ID = c.res; 				
 
 return res_proc;
END GetIdManagerByDate;
/

