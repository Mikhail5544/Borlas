create or replace force view v_cr_pol_journal_cover
(product_name, policy_header_id, as_asset_id, pol_ser, pol_num, issuer, start_date, end_date, fund, fund_pay, asset_name, ins_option, ins_amount, premium, deductible_type, deductible_value, confirm_date)
as
select pr.description, -- �������
       ph.policy_header_id, -- id ��������� ������
       ass.as_asset_id,  -- id ������� �����������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ent.obj_name(c.ent_id,c.contact_id), -- ������������
       ph.start_date, -- ���� ������
       pp.end_date, -- ���� ���������
       f1.brief, -- ������ ���
       f2.brief, -- ������ ��������,
       ent.obj_name(ass.ent_id,ass.as_asset_id), -- ������ �����������
       plo.description, -- ����
       pc.ins_amount, -- ��������� �����
       pc.premium, -- ��������� ������
       decode(dt.description,'���',dt.description,dt.description||','||dvt.description),-- ��� ��������
       pc.deductible_value, -- �������� ��������
       pp.confirm_date    -- ���� ���������� � ����
from ven_p_pol_header ph 
 join ven_p_policy pp on pp.policy_id = ph.policy_id
 join ven_t_product pr on pr.product_id = ph.product_id
 join ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '������������'
 join ven_contact c on c.contact_id = ppc.contact_id
 join ven_fund f1 on f1.fund_id = ph.fund_id
 join ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join ven_as_asset ass on ass.p_policy_id = pp.policy_id
 join ven_p_cover pc on pc.as_asset_id = ass.as_asset_id
 join ven_t_prod_line_option plo on plo.id = pc.t_prod_line_option_id
 join ven_t_deductible_type dt on dt.id = pc.t_deductible_type_id
 join ven_t_deduct_val_type dvt on dvt.id = pc.t_deduct_val_type_id
;

