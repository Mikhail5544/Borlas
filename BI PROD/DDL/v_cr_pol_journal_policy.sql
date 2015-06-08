CREATE OR REPLACE FORCE VIEW V_CR_POL_JOURNAL_POLICY
(product_name, pol_ser, pol_num, issuer, phone, start_date, end_date, fund, fund_pay, ins_amount, premium, next_bill_date, paid_up_amount, loss_number, loss_amount, sales_channel, curator, confirm_date)
AS
SELECT pr.description, -- продукт
       pp.pol_ser, -- сери€
       pp.pol_num, -- номер
       ent.obj_name(c.ent_id,c.contact_id), -- страхователь
       pkg_contact.get_primary_tel(c.contact_id) PHONE, --контактный телефон
       ph.start_date, -- дата начала
       pp.end_date, -- дата окончани€
       f1.brief, -- валюта отв
       f2.brief, -- валюта расчетов
       pp.ins_amount, -- страх сумма
       pp.premium,-- стрх преми€
       (SELECT MIN(ac.due_date) next_bill
            FROM AC_PAYMENT ac, 
                 DOCUMENT d, 
                 DOC_TEMPL dt, 
                 DOC_DOC dd,
                 DOC_SET_OFF dso
            WHERE dd.parent_id = pp.policy_id AND ac.payment_id = dd.child_id
             AND d.document_id = ac.payment_id AND dt.doc_templ_id = d.doc_templ_id
             AND dt.brief = 'PAYMENT' 
             AND ac.payment_id = dso.parent_doc_id(+)
             AND dso.doc_set_off_id IS NULL
       ) NEXT_BILL_DATE,-- очередной счет
       pkg_payment.get_pay_pol_header_amount_pfa(TO_DATE('01.01.1900','dd.mm.yyyy'), TO_DATE('01.01.2100','dd.mm.yyyy'), ph.POLICY_HEADER_ID) PAID_UP_AMOUNT, -- оплачено по договору,
       pkg_claim.count_loss_by_prev(ph.POLICY_HEADER_ID) LOSS_NUMBER,-- количество убытков по договору
       NVL(
       (SELECT SUM(cc.payment_sum) summ
            FROM C_EVENT e1
             JOIN AS_ASSET ass ON ass.as_asset_id = e1.as_asset_id
             JOIN P_POLICY pp3 ON pp3.policy_id = ass.p_policy_id
             JOIN C_CLAIM_HEADER ch ON ch.c_event_id = e1.c_event_id
             JOIN C_CLAIM cc ON cc.c_claim_header_id  = ch.c_claim_header_id
            WHERE cc.seqno = (
                              SELECT MAX(cc1.seqno)
                              FROM C_CLAIM cc1
                              WHERE cc1.c_claim_header_id = ch.c_claim_header_id
                             )
            AND pp3.pol_header_id = ph.POLICY_HEADER_ID),0) LOSS_AMOUNT, -- сумма убытков
       sc.description, -- канал продаж,()
       ent.obj_name(c1.ent_id,c1.contact_id), -- куратор
       pp.confirm_date    -- дата вступлени€ в силу
FROM ven_p_pol_header ph
 JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id AND Doc.get_doc_status_name(pp.policy_id) != 'ѕроект'
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'—трахователь')
 JOIN ven_contact c1 ON c1.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,' уратор')
 JOIN ven_fund f1 ON f1.fund_id = ph.fund_id
 JOIN ven_fund f2 ON f2.fund_id = ph.fund_pay_id
 JOIN T_SALES_CHANNEL sc ON sc.ID = ph.sales_channel_id
;

