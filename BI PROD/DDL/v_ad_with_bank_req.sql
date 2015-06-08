create or replace force view v_ad_with_bank_req as
select ach.num "����� ��",
       ent.obj_name('CONTACT',ach.agent_id) "��� ������",
       ent.obj_name('DEPARTMENT',ach.agency_id) "���������",
       ach.date_begin "���� ������ ��",
       cb.bank_name    "����",
       cb.account_nr   "��������� ����",
       cb.account_corr "����������������� ����",
       cci.serial_nr      "����� ��",
       cci.id_value       "� ��������� ���������",
       ent.obj_name('T_COUNTRY',cci.country_id) "������",
       cci.place_of_issue "�����",
       cci.issue_date     "���� ������"

  from ven_ag_contract_header ach,
       cn_contact_bank_acc    cb,
       cn_contact_ident   cci,
       t_id_type          it
 where doc.get_doc_status_brief(ach.ag_contract_header_id) in ('PRINTED','CURRENT')
   and cb.contact_id = ach.agent_id
   and cci.contact_id = ach.agent_id
   and it.id = cci.id_type
   and it.description = '��������� ���������';

