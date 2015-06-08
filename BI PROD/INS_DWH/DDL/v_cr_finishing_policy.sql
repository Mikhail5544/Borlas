create materialized view INS_DWH.V_CR_FINISHING_POLICY
refresh complete on demand
as
select * from ins.V_CR_FINISHING_POLICY;

