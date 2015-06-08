create materialized view INS_DWH.DM_AGENCY
refresh force on demand
as
select d.department_id agency_id,
       d.name,
       d.code,
       agency_dir.num dir_num,
       agency_dir.dir_name,
       city.city_name
  from ins.department d,
  (select ac.agency_id from ins.ag_contract ac group by ac.agency_id) t
       /*(select t.organisation_tree_id, level l
          from ins.organisation_tree t
         start with t.parent_id is null
        connect by prior t.organisation_tree_id = t.parent_id) org_tree,
       */
       ,
       (select *
          from (select ah.agency_id,
                       ah.ag_contract_header_id,
                       ah.num,
                       c.obj_name dir_name,
                       row_number() over(partition by ah.agency_id order by ah.ag_contract_header_id) rn
                  from ins.ven_ag_contract_header ah,
                       ins.ag_contract            ac,
                       ins.ag_category_agent      cat,
                       ins.contact                c
                 where ah.last_ver_id = ac.ag_contract_id
                   and ac.category_id = cat.ag_category_agent_id
                   and cat.brief = 'DR'
                   and ins.doc.get_doc_status_brief(ac.ag_contract_id) not in
                       ('BREAK', 'CANCEL', 'PROJECT', 'REVISION', 'CLOSE',
                        'ANNULATED', 'STOP')
                   and ah.agent_id = c.contact_id) ah1
         where ah1.rn = 1) agency_dir -- директора агентств
         , mm_agency_city mm
         , dm_t_city city

 where 1=1
 --d.org_tree_id = org_tree.organisation_tree_id
      -- только подразделения, относящиеся ко второму уровню в дереве структура организации
 --  and org_tree.l = 2
   and d.department_id = agency_dir.agency_id(+)
   and  d.department_id = t.agency_id
   and d.department_id = mm.agency_id (+)
   and mm.t_city_id = city.t_city_id (+)

   union all
   select
       -1 agency_id,
       'неопределено' name,
       'неопределено' code,
       'неопределено' dir_num,
       'неопределено' dir_name,
       'неопределено' city_name
        from dual;

