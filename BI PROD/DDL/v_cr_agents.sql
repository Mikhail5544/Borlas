create or replace force view v_cr_agents
(contract_header_id, ag_contract_id, contract_num, agent, agency, agent_leader, date_begin, end_date, birth_date, inn, pens, is_pbul, doc_status, agent_recruter, const_address, post_address, is_outside, is_broker, home_phone, mobil_phone, agency_kod, citizenry, agent_category, doc_type, doc_number, type_ag_code, type_ag_name, agent_st)
as
select agch.ag_contract_header_id, -- �� ��������
       agc.ag_contract_id, --�� ���������� ��������
       agch.num, -- ����� ���������� ��������
       ent.obj_name('CONTACT',agch.agent_id) as agent, --��� ������ ��� �������� �������
       d.name, -- ��������
       ent.obj_name('CONTACT',agchLead.agent_id) as agent_leader,-- ������������ ������
       agch.date_begin, --���� ������ ��
      -- ���� ���������� �� (���� ������� ������, �����������, �������)
      ins_dwh.pkg_rep_utils_ins11.get_ag_contract_end_date(agc.ag_contract_id) as end_date,
      pkg_contact.get_birth_date(agch.agent_id) as birth_date, -- ���� �������� ������
      -- /*
      -- ���
      pkg_contact.get_ident_seria(agch.agent_id,'INN')||
      pkg_contact.get_ident_number(agch.agent_id,'INN')as INN,
      --*/
      -- /*
      -- ����� ����������� �������������
      pkg_contact.get_ident_seria(agch.agent_id,'PENS')||
      pkg_contact.get_ident_number(agch.agent_id,'PENS')as PENS,
      --*/
       decode(agc.leg_pos,1,'��','���') as is_pbul,-- ������� �����
       doc.get_doc_status_name(agc.ag_contract_id) as doc_status,-- ������ ��������
       ent.obj_name('CONTACT',agchRecr.agent_id) as agent_recruter, -- ��������
       pkg_contact.get_address_name(pkg_contact.get_address_by_brief(agch.agent_id,'CONST')) as const_address, -- ����� �� ��������
       pkg_contact.get_address_name(pkg_contact.get_address_by_brief(agch.agent_id,'POSTAL')) as post_address, -- ����� ��������
       decode(agCatAg.Brief,'BZ',decode(sCh.brief,'MLM','���','��'),'���') as is_outside, -- ������� �������� ������
       decode(agCatAg.Brief,null,null,decode (sCh.brief,'BR','��','���')) as is_broker, -- ������� �������
       pkg_contact.get_phone_number(agc.ag_contract_id, 'HOME'),-- �������� �������
       pkg_contact.get_phone_number(agc.ag_contract_id, 'MOB'),-- ��������� �������
       d.code,-- ������� (��� ��������)
       pkg_contact.get_citizenry(agc.ag_contract_id), -- ����������� ������
       agCatAg.category_name, -- ��������� ������
       pkg_contact.get_primary_doc(agc.ag_contract_id) as document, -- ��� ��������� ������
      -- /*
       -- ����� ��������� ������
      pkg_contact.get_ident_seria(agch.agent_id, (select t.brief from ven_t_id_type t
       where t.description = pkg_contact.get_primary_doc(agc.ag_contract_id)) )||
      pkg_contact.get_ident_number(agch.agent_id,(select t.brief from ven_t_id_type t
      where t.description = pkg_contact.get_primary_doc(agc.ag_contract_id) )) as doc_number,
      --*/
       pkg_rep_utils.get_type_agent_code(agch.ag_contract_header_id) as type_ag_code,--��� ������ (���)
       pkg_rep_utils.get_type_agent_name(agch.ag_contract_header_id)as type_ag_name,--��� ������
      -- ������ ������
      pkg_agent_1.get_agent_status_name_by_date(agch.ag_contract_header_id,sysdate) as agent_status
from ven_ag_contract_header agch
join ven_ag_contract agc on agc.ag_contract_id = agch.last_ver_id
left join ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
left join ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
left join ven_ag_contract agRecr on agRecr.ag_contract_id = agc.contract_recrut_id
left join ven_ag_contract_header agchRecr on agchRecr.ag_contract_header_id = agRecr.contract_id
left join ven_department d on d.department_id = agch.agency_id
left join ven_t_sales_channel sCh on sCh.id = agch.t_sales_channel_id
left join ven_ag_category_agent agCatAg on agCatAg.ag_category_agent_id = agc.category_id
;

