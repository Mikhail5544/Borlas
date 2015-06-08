create materialized view INS_DWH.V_CR_SALES_CHANNEL
refresh complete on demand
as
select * from ins.V_CR_SALES_CHANNEL;

