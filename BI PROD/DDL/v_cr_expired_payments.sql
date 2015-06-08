CREATE OR REPLACE FORCE VIEW V_CR_EXPIRED_PAYMENTS
(pol_ser, pol_num, issuer_id, issuer, sch_num, amount, fund, due_date)
AS
SELECT
    pp.pol_ser,    --серия полиса
    pp.pol_num,    --номер полиса
    c.ent_id,      --ИД страхователя
    ent.obj_name(c.ent_id,c.contact_id), -- страхователь
    sch.num,       -- номер счета
    sch.amount,    -- сумма счета
    f.brief,       -- валюта счета
    sch.due_date   -- плановая дата поступления
FROM p_pol_header ph
 JOIN p_policy pp ON pp.pol_header_id = ph.policy_header_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'Страхователь')
 JOIN v_policy_payment_schedule sch ON sch.policy_id = pp.policy_id AND sch.due_date < SYSDATE
 JOIN ac_payment ap ON ap.payment_id = sch.document_id
 JOIN fund f ON ap.fund_id = f.fund_id
 LEFT JOIN doc_set_off dd ON dd.parent_doc_id = ap.payment_id AND dd.set_off_date <= SYSDATE
WHERE (dd.doc_set_off_id IS NULL  OR  dd.set_off_amount <> sch.amount)
;

