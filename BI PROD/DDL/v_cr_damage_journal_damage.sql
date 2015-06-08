create or replace force view v_cr_damage_journal_damage
(product_name, pol_ser, pol_num, issuer, start_date, end_date, fund, fund_pay, event_date, event_type, damage_type, declare_sum, damage_fund)
as
select pr.description, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ent.obj_name(c.ent_id,c.contact_id), -- ������������
       ph.start_date, -- ���� ������
       pp.end_date, -- ���� ���������
       f1.brief, -- ������ ���
       f2.brief, -- ������ ��������
       ce.event_date, -- ���� ���������� �������
       ct.description, -- ��� ���������� �������
       tdc.description, -- ��� ������
       cd.declare_sum, -- �������� ������
       f3.brief -- ������ ������
from ven_p_pol_header ph 
 join ven_p_policy pp on pp.policy_id = ph.policy_id
 join ven_t_product pr on pr.product_id = ph.product_id
 join ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '������������'
 join ven_contact c on c.contact_id = ppc.contact_id
 join ven_fund f1 on f1.fund_id = ph.fund_id
 join ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join as_asset ass on ass.p_policy_id = pp.policy_id
 join c_event ce on ce.as_asset_id = ass.as_asset_id
 join t_catastrophe_type ct on ct.id = ce.catastrophe_type_id
 join c_claim_header ch on ch.c_event_id = ce.c_event_id
 join c_claim cc on cc.c_claim_header_id = ch.c_claim_header_id 
 join c_damage cd on cd.c_claim_id = cc.c_claim_id
 join t_damage_code tdc on tdc.id = cd.t_damage_code_id
 join ven_fund f3 on f3.fund_id = cd.damage_fund_id
where cc.seqno = (
                  select max(cc1.seqno)
                  from c_claim cc1 
                  where cc1.c_claim_header_id = ch.c_claim_header_id
                 ) 
order by pp.pol_num,ce.event_date
;

