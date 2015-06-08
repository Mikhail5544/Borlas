create or replace force view v_cr_pol_journal_policy_year
(police_id, product_name, pol_ser, pol_num, contract_num, notice_num, fio_assur_obj, start_date, end_date, agent_id, agent_liader, agensy, period, payment_number, premium, due_date, fund, fund_pay)
as
select pp.policy_id, -- id ������
       pr.description, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       pp.num, -- ����� ��������
       pp.notice_num,-- ����� ���������
       ent.obj_name('CONTACT',assur.assured_contact_id) as assured,-- ��������������
       ph.start_date, -- ���� ������ �������� ��������
       pp.end_date, -- ���� ��������� �������� ��������
       ent.obj_name('CONTACT',agch.agent_id) as agent,-- ��� ������
       ent.obj_name('CONTACT',agchLead.agent_id) as agent_lead,-- ��� ������������ ������
       d.name,-- ��������
       tpt.description,-- �������������
       ap.payment_number,-- id ��������� �������
       sch.part_amount,-- ������ ������
       sch.due_date, -- ���� �������
       f1.brief, -- ������ ��������������
       f2.brief -- ������ ��������
from ven_p_pol_header ph
   join ven_p_policy pp on pp.policy_id = ph.policy_id
   --/* ������
   left join ven_p_policy_agent ppag on ppag.policy_header_id = ph.policy_header_id
   left join ven_ag_contract_header agch on agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ven_department d on d.department_id = agch.agency_id
   left join ven_ag_contract agc on agch.last_ver_id = agc.ag_contract_id
   left join ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
left join ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
 left join ven_policy_agent_status pAgSt on pAgSt.policy_agent_status_id = ppag.status_id
   --*/
   join ven_t_product pr on pr.product_id = ph.product_id
   join ven_fund f1 on f1.fund_id = ph.fund_id
   join ven_fund f2 on f2.fund_id = ph.fund_pay_id
   join ven_as_asset ass on ass.p_policy_id = pp.policy_id
   join ven_t_payment_terms tpt on tpt.id = pp.payment_term_id
   join v_policy_payment_schedule sch on sch.policy_id = pp.policy_id
   join ven_ac_payment ap on ap.payment_id = sch.document_id
   join ven_as_assured assur on assur.as_assured_id = ass.as_asset_id
   where  nvl(pAgSt.brief,'CURRENT') = 'CURRENT'
    order by pp.policy_id
  --call ents_bi.grant_to_eul('ALL')
;

