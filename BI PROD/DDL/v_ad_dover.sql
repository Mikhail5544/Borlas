CREATE OR REPLACE FORCE VIEW V_AD_DOVER AS
select ent.obj_name('CONTACT',ach.agent_id)     "��� ������",
       ach.num                                  "����� ��",
       doc.get_doc_status_name(ach.ag_contract_header_id) "������ ��",
       ent.obj_name('DEPARTMENT',ach.agency_id) "������",
       d.name                                  "��� ������������",
       d.date_start                           "������ �������� �����",
       d.date_end                             "��������� �������� �����"
  from ven_ag_contract_header ach,
       (select acd.ag_contract_header_id,
               dt.name,
               acd.date_start,
               acd.date_end
          from ag_contract_dover acd,
               t_dover_type      dt
         where dt.t_dover_type_id = acd.t_dover_type_id
         and acd.date_end <= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ad_dover' and param_name = 'start_date')
       )d
 where d.ag_contract_header_id (+) = ach.ag_contract_header_id
   and doc.get_doc_status_brief(ach.ag_contract_header_id) in ('CURRENT','PRINTED');

