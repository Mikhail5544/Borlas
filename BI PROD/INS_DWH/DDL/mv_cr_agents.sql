create materialized view INS_DWH.MV_CR_AGENTS
refresh force on demand
as
select agch.ag_contract_header_id, -- �� ��������
       agc.ag_contract_id, --�� ���������� ��������
       agch.num, -- ����� ���������� ��������
       ins.ent.obj_name('CONTACT',agch.agent_id) as agent, --��� ������ ��� �������� �������
       d.name, -- ��������
       ins.ent.obj_name('CONTACT',agchLead.agent_id) as agent_leader,-- ������������ ������
       agch.date_begin, --���� ������ ��
      -- ���� ���������� �� (���� ������� ������, �����������, �������)
      pkg_rep_utils_ins11.get_ag_contract_end_date(agc.ag_contract_id) as end_date,
      ins.pkg_contact.get_birth_date(agch.agent_id) as birth_date, -- ���� �������� ������
      -- /*
      -- ���
      ins.pkg_contact.get_ident_seria(agch.agent_id,'INN')||
      ins.pkg_contact.get_ident_number(agch.agent_id,'INN')as INN,
      --*/
      -- /*
      -- ����� ����������� �������������
      ins.pkg_contact.get_ident_seria(agch.agent_id,'PENS')||
      ins.pkg_contact.get_ident_number(agch.agent_id,'PENS')as PENS,
      --*/
       decode(agc.leg_pos,1,'��','���') as is_pbul,-- ������� �����
       ins.doc.get_doc_status_name(agc.ag_contract_id) as doc_status,-- ������ ��������
       ins.ent.obj_name('CONTACT',agchRecr.agent_id) as agent_recruter, -- ��������
       ins.pkg_contact.get_address_name(ins.pkg_contact.get_address_by_brief(agch.agent_id,'CONST')) as const_address, -- ����� �� ��������
       ins.pkg_contact.get_address_name(ins.pkg_contact.get_address_by_brief(agch.agent_id,'POSTAL')) as post_address, -- ����� ��������
       decode(agCatAg.Brief,'BZ',decode(sCh.brief,'MLM','���','��'),'���') as is_outside, -- ������� �������� ������
       decode(agCatAg.Brief,null,null,decode (sCh.brief,'BR','��','���')) as is_broker, -- ������� �������
       ins.pkg_contact.get_phone_number(agc.ag_contract_id, 'HOME'),-- �������� �������
       ins.pkg_contact.get_phone_number(agc.ag_contract_id, 'MOB'),-- ��������� �������
       d.code,-- ������� (��� ��������)
       ins.pkg_contact.get_citizenry(agc.ag_contract_id), -- ����������� ������
       agCatAg.category_name, -- ��������� ������
       ins.pkg_contact.get_primary_doc(agc.ag_contract_id) as document, -- ��� ��������� ������
      -- /*
       -- ����� ��������� ������
      ins.pkg_contact.get_ident_seria(agch.agent_id, t.brief )||
      ins.pkg_contact.get_ident_number(agch.agent_id,t.brief) as doc_number,
      --*/
       ins.pkg_rep_utils.get_type_agent_code(agch.ag_contract_header_id) as type_ag_code,--��� ������ (���)
       ins.pkg_rep_utils.get_type_agent_name(agch.ag_contract_header_id)as type_ag_name,--��� ������
      -- ������ ������
      ins.pkg_agent_1.get_agent_status_name_by_date(agch.ag_contract_header_id,sysdate) as agent_status
from ins.ven_ag_contract_header agch
join ins.ven_ag_contract agc on agc.ag_contract_id = agch.last_ver_id
left join ins.ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
left join ins.ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
left join ins.ven_ag_contract agRecr on agRecr.ag_contract_id = agc.contract_recrut_id
left join ins.ven_ag_contract_header agchRecr on agchRecr.ag_contract_header_id = agRecr.contract_id
left join ins.ven_department d on d.department_id = agch.agency_id
left join ins.ven_t_sales_channel sCh on sCh.id = agch.t_sales_channel_id
left join ins.ven_ag_category_agent agCatAg on agCatAg.ag_category_agent_id = agc.category_id
left join ins.t_id_type t on t.description = ins.pkg_contact.get_primary_doc(agc.ag_contract_id);

