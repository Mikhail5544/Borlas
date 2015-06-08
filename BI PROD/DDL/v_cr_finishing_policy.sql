CREATE OR REPLACE FORCE VIEW V_CR_FINISHING_POLICY
(product_name, pol_ser, pol_num, issuer, start_date, end_date)
AS
SELECT pr.description, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ent.obj_name(c.ent_id,c.contact_id), -- ������������
       ph.start_date, -- ���� ������
    pp.end_date -- ���� ���������
     FROM ven_p_pol_header ph 
 JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'������������')
ORDER BY pp.end_date, pp.pol_num
;

