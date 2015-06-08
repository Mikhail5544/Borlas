create materialized view INS_DWH.MV_CR_POL_JOURNAL_COVER
build deferred
refresh force on demand
as
select pr.description product_name, -- �������
       ph.policy_header_id policy_header_id, -- id ��������� ������
       ass.as_asset_id as_asset_id,  -- id ������� �����������
       pp.pol_ser pol_ser, -- �����
       pp.pol_num pol_num, -- �����
       ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- ������������
       ph.start_date start_date, -- ���� ������
       pp.end_date end_date, -- ���� ���������
       f1.brief fund, -- ������ ���
       f2.brief fund_pay, -- ������ ��������,
       ins.ent.obj_name(ass.ent_id,ass.as_asset_id) asset_name, -- ������ �����������
       plo.description ins_option, -- ����
       pc.ins_amount ins_amount, -- ��������� �����
       pc.premium premium, -- ��������� ������
       decode(dt.description,'���',dt.description,dt.description||','||dvt.description) deductible_type,-- ��� ��������
       pc.deductible_value deductible_value, -- �������� ��������
       pp.confirm_date confirm_date   -- ���� ���������� � ����
from ins.ven_p_pol_header ph
 join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '������������'
 join ins.ven_contact c on c.contact_id = ppc.contact_id
 join ins.ven_fund f1 on f1.fund_id = ph.fund_id
 join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join ins.ven_as_asset ass on ass.p_policy_id = pp.policy_id
 join ins.ven_p_cover pc on pc.as_asset_id = ass.as_asset_id
 join ins.ven_t_prod_line_option plo on plo.id = pc.t_prod_line_option_id
 join ins.ven_t_deductible_type dt on dt.id = pc.t_deductible_type_id
 join ins.ven_t_deduct_val_type dvt on dvt.id = pc.t_deduct_val_type_id;

