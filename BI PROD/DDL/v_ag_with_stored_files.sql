create or replace force view v_ag_with_stored_files as
select
       ent.obj_name('CONTACT',ach.agent_id)     "ФИО Агента",
       ach.num                                  "Номер АД",
       ach.date_begin                           "Дата начала АД",
       ent.obj_name('DEPARTMENT',ach.agency_id) "Агентсво",
       a.file_origin_name "Прикреплённый файл",
       a.note             "Примечание",
       decode(ac.category_id, 2, 'Агент', 3, 'Менеджер', 4, 'Директор') "Категория Агента",
       pkg_renlife_utils.get_ag_stat_brief(ach.ag_contract_header_id, sysdate) "Статус Агента",
       doc.get_doc_status_name(ach.ag_contract_header_id) "Статус АД"
  from
       ven_ag_contract_header ach,
       t_sales_channel    ts,
       ag_contract        ac,
       (select sf.parent_uro_id,
               sf.file_origin_name,
               sf.note
          from stored_files sf,
               entity       ent
         where sf.parent_ure_id = ent.ent_id
           and ent.brief = 'AG_CONTRACT_HEADER'
       )a
 where ts.id = ach.t_sales_channel_id
   and ts.description = 'Агентский'
   and ac.ag_contract_id = PKG_AGENT_1.GET_STATUS_BY_DATE(ach.ag_contract_header_id,sysdate)
   and a.parent_uro_id (+) = ach.ag_contract_header_id
   and doc.get_doc_status_brief(ach.ag_contract_header_id) in ('CURRENT','PRINTED','NEW');

