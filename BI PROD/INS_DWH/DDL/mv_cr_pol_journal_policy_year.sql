create materialized view INS_DWH.MV_CR_POL_JOURNAL_POLICY_YEAR
build deferred
refresh force on demand
as
select pp.policy_id police_id, -- id ������
       pr.description product_name, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       pp.num contract_num, -- ����� ��������
       pp.notice_num,-- ����� ���������
       ins.ent.obj_name('CONTACT',assur.assured_contact_id) as fio_assur_obj,-- ��������������
       ph.start_date, -- ���� ������ �������� ��������
       pp.end_date, -- ���� ��������� �������� ��������
       ins.ent.obj_name('CONTACT',agch.agent_id) as agent_id,-- ��� ������
       ins.ent.obj_name('CONTACT',agchLead.agent_id) as agent_liader,-- ��� ������������ ������
       d.name agensy,-- ��������
       tpt.description period,-- �������������
       ap.payment_number,-- id ��������� �������
       sch.part_amount premium,-- ������ ������
       sch.due_date, -- ���� �������
       f1.brief fund, -- ������ ��������������
       f2.brief fund_pay-- ������ ��������
from ins.ven_p_pol_header ph
   join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
   --/* ������
   left join ins.ven_p_policy_agent ppag on ppag.policy_header_id = ph.policy_header_id
   left join ins.ven_ag_contract_header agch on agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ins.ven_department d on d.department_id = agch.agency_id
   left join ins.ven_ag_contract agc on agch.last_ver_id = agc.ag_contract_id
   left join ins.ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
left join ins.ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
 left join ins.ven_policy_agent_status pAgSt on pAgSt.policy_agent_status_id = ppag.status_id
   --*/
   join ins.ven_t_product pr on pr.product_id = ph.product_id
   join ins.ven_fund f1 on f1.fund_id = ph.fund_id
   join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
   join ins.ven_as_asset ass on ass.p_policy_id = pp.policy_id
   join ins.ven_t_payment_terms tpt on tpt.id = pp.payment_term_id
   join ins.v_policy_payment_schedule sch on sch.policy_id = pp.policy_id
   join ins.ven_ac_payment ap on ap.payment_id = sch.document_id
   join ins.ven_as_assured assur on assur.as_assured_id = ass.as_asset_id
   where  nvl(pAgSt.brief,'CURRENT') = 'CURRENT';

