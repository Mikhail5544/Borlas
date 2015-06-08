CREATE OR REPLACE FORCE VIEW V_CR_CLIENT
(product_name, pol_ser, pol_num, issuer_id, issuer, fund, fynd_pay, premium_amount, premium_pay_amount, vozvr_pay_amount, damage_pay_amount, damage_declare_amount)
AS
SELECT pr.description, -- продукт
       pp.pol_ser, -- серия
       pp.pol_num, -- номер
       c.CONTACT_ID, -- ИД клиента
       ent.obj_name(c.ent_id,c.contact_id), -- страхователь - Клиент
       f1.brief, -- валюта отв
       f2.brief, -- валюта расчетов
       pp.premium, -- премия
       pkg_rep_utils.pay_prem_policy(pp.POLICY_ID), --получено премии
       NVL(pkg_payment.get_ph_ret_pay_amount(ph.policy_header_id, TO_DATE('01.01.1900','dd.mm.yyyy'), TO_DATE('01.01.2100','dd.mm.yyyy')),0) pay_summ_voz,--Выплаченные возвраты 
       pkg_payment.get_ph_claim_pay_amount(ph.policy_header_id, TO_DATE('01.01.1900','dd.mm.yyyy'), TO_DATE('01.01.2100','dd.mm.yyyy')) PAY_SUMM, -- выплаченные убытки
       NVL(pkg_claim.get_declare_sum(ph.policy_header_id,TO_DATE('01.01.2100','dd.mm.yyyy')),0) DEC_SUMM -- заявленные убытки    
 FROM ven_p_pol_header ph 
 JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'Страхователь')
 JOIN ven_fund f1 ON f1.fund_id = ph.fund_id
 JOIN ven_fund f2 ON f2.fund_id = ph.fund_pay_id
;

