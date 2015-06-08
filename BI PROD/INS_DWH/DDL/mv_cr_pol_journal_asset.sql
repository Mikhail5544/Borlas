create materialized view INS_DWH.MV_CR_POL_JOURNAL_ASSET
build deferred
refresh force on demand
as
select pr.description product_name, -- �������
       ph.policy_header_id, -- id ������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ph.start_date, -- ���� ������
       pp.end_date, -- ���� ���������
       f1.brief fund, -- ������ ���
       f2.brief fund_pay, -- ������ ��������,
       ins.ent.obj_name(ass.ent_id,ass.as_asset_id) asset_name, -- ������ �����������
       ass.ins_amount, -- ��������� �����
       ass.ins_premium premium, -- ��������� ������
       decode(dt.description,'���',dt.description,dt.description||','||dvt.description) deductible_type,-- ��� ��������
       ass.deductible_value, -- �������� ��������
       pp.confirm_date    -- ���� ���������� � ����
from ins.ven_p_pol_header ph
 join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.ven_fund f1 on f1.fund_id = ph.fund_id
 join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join ins.ven_as_asset ass on ass.p_policy_id = pp.policy_id
 left join ins.ven_t_deductible_type dt on dt.id = ass.t_deductible_type_id
 left join ins.ven_t_deduct_val_type dvt on dvt.id = ass.t_deduct_val_type_id;

