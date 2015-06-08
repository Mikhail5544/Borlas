create or replace force view ins_dwh.v_ag_with_stored_files as
select
       ins.ent.obj_name('CONTACT',ach.agent_id)     "��� ������",
       ach.num                                  "����� ��",
       ach.date_begin                           "���� ������ ��",
       ins.ent.obj_name('DEPARTMENT',ach.agency_id) "��������",
       a.file_origin_name "������������ ����",
       a.note             "����������",
       decode(ac.category_id, 2, '�����', 3, '��������', 4, '��������') "��������� ������",
       ins.pkg_renlife_utils.get_ag_stat_brief(ach.ag_contract_header_id, sysdate) "������ ������",
       ins.doc.get_doc_status_name(ach.ag_contract_header_id) "������ ��"
  from
       ins.ven_ag_contract_header ach,
       ins.t_sales_channel    ts,
       ins.ag_contract        ac,
       (select sf.parent_uro_id,
               sf.file_origin_name,
               sf.note
          from ins.stored_files sf,
               ins.entity       ent
         where sf.parent_ure_id = ent.ent_id
           and ent.brief = 'AG_CONTRACT_HEADER'
       )a
 where ts.id = ach.t_sales_channel_id
   and ts.brief = 'MLM' --���������
   and ac.ag_contract_id = ins.PKG_AGENT_1.GET_STATUS_BY_DATE(ach.ag_contract_header_id,sysdate)
   and a.parent_uro_id (+) = ach.ag_contract_header_id
   and ins.doc.get_doc_status_brief(ach.ag_contract_header_id) in ('CURRENT','PRINTED','NEW')
;

