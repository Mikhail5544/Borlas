CREATE OR REPLACE FORCE VIEW V_CR_CLIENT
(product_name, pol_ser, pol_num, issuer_id, issuer, fund, fynd_pay, premium_amount, premium_pay_amount, vozvr_pay_amount, damage_pay_amount, damage_declare_amount)
AS
SELECT pr.description, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       c.CONTACT_ID, -- �� �������
       ent.obj_name(c.ent_id,c.contact_id), -- ������������ - ������
       f1.brief, -- ������ ���
       f2.brief, -- ������ ��������
       pp.premium, -- ������
       pkg_rep_utils.pay_prem_policy(pp.POLICY_ID), --�������� ������
       NVL(pkg_payment.get_ph_ret_pay_amount(ph.policy_header_id, TO_DATE('01.01.1900','dd.mm.yyyy'), TO_DATE('01.01.2100','dd.mm.yyyy')),0) pay_summ_voz,--����������� �������� 
       pkg_payment.get_ph_claim_pay_amount(ph.policy_header_id, TO_DATE('01.01.1900','dd.mm.yyyy'), TO_DATE('01.01.2100','dd.mm.yyyy')) PAY_SUMM, -- ����������� ������
       NVL(pkg_claim.get_declare_sum(ph.policy_header_id,TO_DATE('01.01.2100','dd.mm.yyyy')),0) DEC_SUMM -- ���������� ������    
 FROM ven_p_pol_header ph 
 JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'������������')
 JOIN ven_fund f1 ON f1.fund_id = ph.fund_id
 JOIN ven_fund f2 ON f2.fund_id = ph.fund_pay_id
;

