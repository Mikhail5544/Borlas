create materialized view INS_DWH.PRE_AG_COMPLETE_POLICY
refresh force on demand
as
select a.DATE_POLICY accept_date,  -- дата начала действия договора (по А7 или по ПД4), это не start_date!
    SUM(a.SGP_AMOUNT) as sgp_amount, -- сумма СГП агента на дату
    count(*) as sgp_policy_count, -- количесвто договоров на дату
       a.AG_CONTRACT_HEADER_ID ag_contract_header_id-- хедар агенсткого довговора
from
ins.AG_ALL_AGENT_SGP a
group by a.AG_CONTRACT_HEADER_ID,a.DATE_POLICY;

