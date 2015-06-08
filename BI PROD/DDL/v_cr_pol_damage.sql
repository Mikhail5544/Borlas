CREATE OR REPLACE FORCE VIEW V_CR_POL_DAMAGE
(product_name, pol_ser, pol_num, issuer, ins_amount, premium, fund, fund_pay, pay_summ, dec_summ, damageness)
AS
SELECT pr.description, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ent.obj_name(c.ent_id,c.contact_id), -- ������������
       NVL(pp.ins_amount,0), -- ��������� �����
       NVL(pp.premium,0), -- ������
       f1.brief,    -- ������ ���������������
       f2.brief,    -- ������ �������� 
       pkg_payment.get_ph_claim_pay_amount(ph.policy_header_id, TO_DATE('01.01.1900','dd.mm.yyyy'), TO_DATE('01.01.2100','dd.mm.yyyy')) PAY_SUMM, -- ����������� ������
       NVL(pkg_claim.get_declare_sum(ph.policy_header_id,TO_DATE('01.01.2100','dd.mm.yyyy')),0) DEC_SUMM, -- ���������� ������ 
       NVL(pkg_claim.unprofitableness(ph.policy_header_id),0) DAMAGENESS-- �����������
FROM ven_p_pol_header ph 
 JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'������������')
 JOIN ven_fund f1 ON f1.fund_id = ph.fund_id
 JOIN ven_fund f2 ON f2.fund_id = ph.fund_pay_id
;

