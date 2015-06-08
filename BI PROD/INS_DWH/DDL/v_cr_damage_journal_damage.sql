create materialized view INS_DWH.V_CR_DAMAGE_JOURNAL_DAMAGE
refresh complete on demand
as
select * from ins.V_CR_DAMAGE_JOURNAL_DAMAGE;

