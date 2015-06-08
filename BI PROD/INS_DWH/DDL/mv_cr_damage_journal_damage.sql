create materialized view INS_DWH.MV_CR_DAMAGE_JOURNAL_DAMAGE
build deferred
refresh force on demand
as
select pr.description product_name, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- ������������
       ph.start_date, -- ���� ������
       pp.end_date, -- ���� ���������
       f1.brief fund, -- ������ ���
       f2.brief fund_pay, -- ������ ��������
       ce.event_date, -- ���� ���������� �������
       ct.description event_type, -- ��� ���������� �������
       tdc.description damage_type, -- ��� ������
       cd.declare_sum, -- �������� ������
       f3.brief damage_fund -- ������ ������
from ins.ven_p_pol_header ph
 join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '������������'
 join ins.ven_contact c on c.contact_id = ppc.contact_id
 join ins.ven_fund f1 on f1.fund_id = ph.fund_id
 join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join ins.as_asset ass on ass.p_policy_id = pp.policy_id
 join ins.c_event ce on ce.as_asset_id = ass.as_asset_id
 join ins.t_catastrophe_type ct on ct.id = ce.catastrophe_type_id
 join ins.c_claim_header ch on ch.c_event_id = ce.c_event_id
 join ins.c_claim cc on cc.c_claim_header_id = ch.c_claim_header_id
 join ins.c_damage cd on cd.c_claim_id = cc.c_claim_id
 join ins.t_damage_code tdc on tdc.id = cd.t_damage_code_id
 join ins.ven_fund f3 on f3.fund_id = cd.damage_fund_id
where cc.seqno = (
                  select max(cc1.seqno)
                  from ins.c_claim cc1
                  where cc1.c_claim_header_id = ch.c_claim_header_id
                 );

