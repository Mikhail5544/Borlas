create materialized view INS_DWH.MV_CR_EXPIRED_PAYMENTS
build deferred
refresh force on demand
as
select
    pp.pol_ser,    --серия полиса
    pp.pol_num,    --номер полиса
    c.ent_id issuer_id,      --ИД страхователя
    ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- страхователь
    sch.num,       -- номер счета
    sch.amount,    -- сумма счета
    f.brief fund,       -- валюта счета
    sch.due_date   -- плановая дата поступления
from ins.p_pol_header ph
 join ins.p_policy pp on pp.pol_header_id = ph.policy_header_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = 'Страхователь'
 join ins.ven_contact c on c.contact_id = ppc.contact_id
 join ins.v_policy_payment_schedule sch on sch.policy_id = pp.policy_id and sch.due_date < sysdate
 join ins.ac_payment ap on ap.payment_id = sch.document_id
 join ins.fund f on ap.fund_id = f.fund_id
 left join ins.doc_set_off dd on dd.parent_doc_id = ap.payment_id and dd.set_off_date <= sysdate
where (dd.doc_set_off_id is null  or  dd.set_off_amount <> sch.amount);

