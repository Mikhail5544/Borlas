create materialized view INS_DWH.V_CR_EXPIRED_PAYMENTS
build deferred
refresh force on demand
as
select * from ins.v_cr_expired_payments;

