create materialized view INS_DWH.V_CR_POL_DAMAGE
refresh complete on demand
as
select * from ins.V_CR_POL_DAMAGE;

