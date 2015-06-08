CREATE OR REPLACE FORCE VIEW V_CR_SALES_CHANNEL
(product_name, pol_ser_num, issuer, sales_channel, order_num, pay_date, pay_amount, pay_fund, amount, fund)
AS
SELECT pr.description, -- �������
    ent.obj_name('P_POLICY',ph.policy_id), -- �����-����� ��������
       ent.obj_name(c.ent_id,c.contact_id), -- ������������
    sc.description, -- ����� ������,
    ap.num, --(��� ����� ��/���)
       t.trans_date, -- ���� ������������� ��������
       t.trans_amount,  -- ����� ������
       f1.brief,        -- ������ ������
       t.acc_amount,    -- ����� ������ � ������ ���������������
       f2.brief -- ������ ���������������
FROM ven_trans t
  JOIN ven_trans_templ tt ON tt.trans_templ_id = t.trans_templ_id AND tt.brief = '�����������'
  JOIN oper o ON o.oper_id = t.oper_id
  JOIN doc_set_off d ON d.doc_set_off_id = o.document_id
  JOIN ven_ac_payment ap ON ap.payment_id = d.child_doc_id
  JOIN p_policy pp ON t.a2_ct_uro_id = pp.policy_id
  JOIN p_pol_header ph ON ph.policy_header_id = pp.pol_header_id
  JOIN ven_contact c ON c.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'������������')           
  JOIN ven_t_product pr ON pr.product_id = ph.product_id
  JOIN t_sales_channel sc ON sc.ID = ph.sales_channel_id
  JOIN fund f1 ON f1.fund_id = t.trans_fund_id
  JOIN fund f2 ON f2.fund_id = ph.fund_id
;

