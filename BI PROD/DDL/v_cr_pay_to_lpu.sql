create or replace force view v_cr_pay_to_lpu as
select t.contact_id,                                        --ИД ЛПУ
       decode(templ.brief,'PAYADVLPU','Предоплата','Факт') pay_type, --вид оплаты
       ent.obj_name('DOCUMENT',t1.payment_id) pay_num,              --номер счета
       t1.reg_date,                                         --дата регистрации счета(документа)
       dso.set_off_date,                                    --дата оплаты счета(дата зачета)
       null med_type,                                       --тип медицинской помощи
       dso.set_off_amount,                                  --сумма оплачена (сумма зачета)
       dso.note                                             --примечание
from ven_ac_payment t,
      ven_doc_set_off dso,
      ven_doc_doc dd,
      ven_ac_payment t1,
      ven_ac_payment_templ templ
where templ.payment_templ_id=t.payment_templ_id
and upper(templ.brief) in ('PAYADVLPU','PAYORDLPU')
and dso.parent_doc_id(+)=t.payment_id
and dd.child_id(+)=t.payment_id
and t1.payment_id(+)=dd.parent_id
;

