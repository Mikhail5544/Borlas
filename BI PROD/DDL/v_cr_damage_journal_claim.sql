CREATE OR REPLACE FORCE VIEW V_CR_DAMAGE_JOURNAL_CLAIM
(product_name, pol_ser, pol_num, issuer, ins_amount, start_date, end_date, fund, fund_pay, event_date, event_type, notice_date, claim_date, prev_loss_amount)
AS
SELECT pr.description, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ent.obj_name(c.ent_id,c.contact_id), -- ������������
       NVL(pp.ins_amount,0), -- ��������� �����
       ph.start_date, -- ���� ������
       pp.end_date, -- ���� ���������
       f1.brief, -- ������ ���
       f2.brief, -- ������ ��������
       ce.event_date, -- ���� ���������� �������
       ct.description, -- ��� ���������� �������
       ce.date_declare, -- ���� ����������
       cc.claim_status_date, -- ���� ���������
       pkg_claim.get_declare_sum(ph.policy_header_id,cc.claim_status_date) -- ����� ���������� ������
FROM ven_p_pol_header ph 
 JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'������������')
 JOIN ven_fund f1 ON f1.fund_id = ph.fund_id
 JOIN ven_fund f2 ON f2.fund_id = ph.fund_pay_id
 JOIN as_asset ass ON ass.p_policy_id = pp.policy_id
 JOIN c_event ce ON ce.as_asset_id = ass.as_asset_id
 JOIN t_catastrophe_type ct ON ct.ID = ce.catastrophe_type_id
 JOIN c_claim_header ch ON ch.c_event_id = ce.c_event_id
 JOIN c_claim cc ON cc.c_claim_header_id = ch.c_claim_header_id AND cc.seqno = 1
WHERE cc.declare_sum > 0
;

