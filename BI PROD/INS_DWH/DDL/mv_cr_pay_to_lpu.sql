create materialized view INS_DWH.MV_CR_PAY_TO_LPU
build deferred
refresh force on demand
as
select t.contact_id,                                        --ИД ЛПУ
       decode(templ.brief,'PAYADVLPU','Предоплата','Факт') pay_type, --вид оплаты
       ins.ent.obj_name('DOCUMENT',t1.payment_id) pay_num,              --номер счета
       t1.reg_date,                                         --дата регистрации счета(документа)
       dso.set_off_date,                                    --дата оплаты счета(дата зачета)
       cast(null as varchar2(2000)) med_type,                                       --тип медицинской помощи
       dso.set_off_amount,                                  --сумма оплачена (сумма зачета)
       dso.note                                             --примечание
from ins.ven_ac_payment t,
      ins.ven_doc_set_off dso,
      ins.ven_doc_doc dd,
      ins.ven_ac_payment t1,
      ins.ven_ac_payment_templ templ
where templ.payment_templ_id=t.payment_templ_id
and upper(templ.brief) in ('PAYADVLPU','PAYORDLPU')
and dso.parent_doc_id(+)=t.payment_id
and dd.child_id(+)=t.payment_id
and t1.payment_id(+)=dd.parent_id;

