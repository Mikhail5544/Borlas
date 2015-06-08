create materialized view INS_DWH.MV_CR_CHECK_PAYMENTS
build deferred
refresh force on demand
as
select ins.ent.obj_name('DOCUMENT',ac.payment_id) as pay_number,--номер счета
       ac.reg_date as data_act,           --дата выставления счета (регистрации документа)
       ac.contact_id as lpu,         --ИД ЛПУ (плательщика-получателя)
       decode(upper(f.brief),'RUR',ac.rev_amount,ac.amount*ins.acc.Get_Cross_Rate_By_Brief(rt.rate_type_id,f1.brief,'RUR',ac.reg_date)) as summa,          --сумма
       apt.brief as brief               --тип документа
from ins.ven_ac_payment ac,
     ins.ven_ac_payment_templ apt,
     ins.ven_fund f,
     ins.ven_fund f1,
     ins.ven_rate_type rt
where apt.payment_templ_id=ac.payment_templ_id
      and upper(apt.brief) in ('ППИ','DMS_INV_LPU_SERV','WRITEOFFEXP')
      and f.fund_id=ac.rev_fund_id
      and rt.is_default=1
      and f1.fund_id=ac.fund_id;

