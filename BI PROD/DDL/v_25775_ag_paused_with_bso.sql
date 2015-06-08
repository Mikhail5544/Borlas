create or replace force view v_25775_ag_paused_with_bso as
select a.dep_name as "Агентство",
       a.num      as "Номер АД",
--       a.ag_stat  as "Статус АД",
       a.obj_name_orig as "ФИО агента",
       a.category_name as "Категория",
       doc.get_doc_status_name(ag_contract_id) "Статус АД",
       a.bso_type_name as "Тип БСО",
       sum(a1) as "Количество Выданных",
       sum(a2) as "Количество Переданных",
       sum(a3) as "Количество Не Выданных"
 from (
select
       dep.name dep_name,
       ac.ag_contract_id,
       ach.num,
       doc.get_doc_status_name(ach.ag_contract_header_id) ag_stat,
       c.obj_name_orig,
       aca.category_name,
       bt.name bso_type_name,
       case when bht.brief = 'Выдан' then 1 else 0 end a1,
       case when bht.brief = 'Передан' then 1 else 0 end a2,
       case when bht.brief = 'НеВыдан' then 1 else 0 end a3
  from
       contact         c,
       bso             b,
       bso_hist        bh,
       bso_type        bt,
       bso_series      bs,
       bso_hist_type   bht,
       ven_ag_contract_header ach,
       ag_contract            ac,
       ag_category_agent      aca,
       department             dep
 where
       bh.bso_hist_id  = b.bso_hist_id
   AND bh.hist_type_id = bht.bso_hist_type_id
   AND b.bso_series_id = bs.bso_series_id
   AND bt.bso_type_id  = bs.bso_type_id
   and bh.contact_id = c.contact_id
   and ach.agent_id  = c.contact_id
   and dep.department_id = ach.agency_id
   and PKG_AGENT_1.GET_STATUS_BY_DATE(ACH.AG_CONTRACT_HEADER_ID,sysdate) = AC.AG_CONTRACT_ID
   and aca.ag_category_agent_id = ac.category_id
   and bht.brief in ('Выдан','Передан','НеВыдан')
   and doc.get_doc_status_name(ac.ag_contract_id) = 'Приостановлен'
   --and ach.ag_contract_header_id = 6765558
   )a
group by a.dep_name,
         a.num,
         a.ag_stat,
         a.obj_name_orig,
         a.category_name,
         a.bso_type_name,
         ag_contract_id
order by a.dep_name,
         a.obj_name_orig,
         a.bso_type_name

--select * from v_agent_tree_h
;

