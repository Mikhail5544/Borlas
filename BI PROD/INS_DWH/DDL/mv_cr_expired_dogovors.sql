create materialized view INS_DWH.MV_CR_EXPIRED_DOGOVORS
build deferred
refresh force on demand
as
select
    pp.pol_ser,    --серия полиса
    pp.pol_num,    --номер полиса
    pp.policy_id, -- ид версии договора
    pp.start_date, --дата начала договора
    pp.end_date,   --дата окончания
    ins.pkg_payment.get_calc_amount_policy(pp.policy_id) premium,--начисленная премия
    sch.num,       -- номер счета
    sch.amount,    -- сумма счета
    f1.brief f1,       -- валюта счета
    sch.grace_date,   -- оплатить до
    dd.set_off_date, -- дата зачета
    ph.description,   --примечание
    pp.pol_header_id, --id договора
    dd.set_off_amount,
    f2.brief f2          --дата ответственности
 from ins.p_pol_header ph,
     ins.p_policy pp,
     ins.v_policy_payment_schedule sch,
     ins.ac_payment ap,
     ins.fund f1,
     ins.fund f2,
     ins.doc_set_off dd
where pp.pol_header_id = ph.policy_header_id
 and sch.policy_id = pp.policy_id
 and ap.payment_id = sch.document_id
 and ap.fund_id = f1.fund_id
 and ph.fund_id = f2.fund_id
 and dd.parent_doc_id(+) = ap.payment_id
 and (dd.doc_set_off_id is null or  dd.set_off_amount <> sch.amount);

