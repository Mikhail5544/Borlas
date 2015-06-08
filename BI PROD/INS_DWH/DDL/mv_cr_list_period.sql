create materialized view INS_DWH.MV_CR_LIST_PERIOD
build deferred
refresh force on demand
as
select pt.id, pt.description from ins.ven_t_payment_terms pt;

