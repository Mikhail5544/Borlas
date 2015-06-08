create materialized view INS_DWH.DM_AG_CONTRACT_HEADER
refresh force on demand
as
select ah.ag_contract_header_id,
       ah.num,
       c.obj_name_orig agent_name,
       nvl(d.code || ' ' || d.name,'неопределено') agency_name,
       nvl(sh.description,'неопределено') sale_channel_name,
       ah.date_begin date_begin,
       ins.doc.get_doc_status_name(ac.ag_contract_id) status,
       nvl(ag_stat_hist.agent_category_name,'неопределено') agent_category_name,
       nvl(ag_stat_hist.agent_status_name,'неопределено') agent_status_name,
       case when leaders.obj_name_orig is null
        then 'неопределено'
       else leaders.num || ' ' || leaders.obj_name_orig
       end leader,
       ah.date_break date_break,
       business_date_begin_contracts.date_begin business_date_begin,
       nvl(agd_agent.doc_date,
       (
       select max(agd.doc_date)
        from ins.ag_documents agd,
             ins.ag_doc_type adt
        where agd.ag_doc_type_id = adt.ag_doc_type_id
              and adt.brief = 'NEW_AD'
              and agd.ag_contract_header_id = ah.ag_contract_header_id
              and ins.doc.get_doc_status_brief(agd.ag_documents_id) NOT IN ('CANCEL','PROJECT')
       )
         ) state_doc_ad
  from ins.ven_ag_contract_header ah,
       ins.ag_contract ac,
       ins.contact c,
       ins.department d,
       ins.t_sales_channel sh,
       (select t.*, cat.category_name agent_category_name, ag_stat.name agent_status_name
          from (select ash.ag_stat_hist_id,
                       ash.ag_contract_header_id,
                       ash.ag_stat_agent_id,
                       ash.ag_category_agent_id,
                       row_number() over(partition by ash.ag_contract_header_id order by ash.stat_date desc) n
                  from ins.ag_stat_hist ash) t,
               ins.ag_contract_header ah1,
               ins.ag_category_agent cat,
               ins.ag_stat_agent ag_stat
         where t.n = 1
           and t.ag_contract_header_id = ah1.ag_contract_header_id
           and t.ag_stat_agent_id = ag_stat.ag_stat_agent_id
           and t.ag_category_agent_id = cat.ag_category_agent_id
           and ah1.templ_brief is null) ag_stat_hist,
           (select ah_leader.last_ver_id, ah_leader.num, c_leader.obj_name_orig from ins.ven_ag_contract_header ah_leader,   ins.contact c_leader
           where ah_leader.agent_id = c_leader.contact_id ) leaders,

           -- вычисление бизнес даты начала: после ввода нового модуля и перезаключения договора с компанией агент не считается новым, если имеетс предыдущий договор
           (select t.ag_contract_header_id, t.prev_ag_contract_header_id, t.date_begin from (
              select ah.ag_contract_header_id, pah.ag_contract_header_id prev_ag_contract_header_id, decode(pah.ag_contract_header_id, null, ah.date_begin, pah.date_begin) date_begin, row_number() over(partition by ah.ag_contract_header_id order by pah.date_begin) rn from ins.ag_contract_header ah --where nvl(ah.is_new,0) = 1
               left outer join ins.ag_prev_dog pd on ah.ag_contract_header_id = pd.ag_contract_header_id
                           and pd.company = 'Реннесанс Жизнь'
                left outer join ins.ag_contract_header pah on pah.ag_contract_header_id = pd.ag_prev_header_id
                                                           and pah.agent_id = ah.agent_id
                ) t
              where t.rn=1 ) business_date_begin_contracts,
        (select agd.ag_contract_header_id,
                agd.doc_date
        from ins.ag_documents agd,
             ins.ag_doc_type adt,
             ins.ag_props_change apc,
             ins.ag_props_type apt
        where agd.ag_doc_type_id = adt.ag_doc_type_id
              and adt.brief = 'CAT_CHG'
              and apc.ag_documents_id = agd.ag_documents_id
              and apc.ag_props_type_id = apt.ag_props_type_id
              and apt.brief = 'CAT_PROP'
              and apc.new_value = '2'
              and ins.doc.get_doc_status_brief(agd.ag_documents_id) NOT IN ('CANCEL','PROJECT')
              ) agd_agent

 where ah.last_ver_id = ac.ag_contract_id
   and ah.agent_id = c.contact_id
   and ah.agency_id = d.department_id (+)
   and ah.t_sales_channel_id = sh.id (+)
   and ah.ag_contract_header_id = ag_stat_hist.ag_contract_header_id (+)
  and ac.contract_leader_id = leaders.last_ver_id (+)
   and ah.templ_brief is null
   and ah.ag_contract_header_id = business_date_begin_contracts.ag_contract_header_id
   and ah.ag_contract_header_id = agd_agent.ag_contract_header_id (+)
   union all
   select
       -1 ag_contract_header_id,
       '' num,
       'неопределено' agent_name,
       'неопределено' agency_name,
       'неопределено' sale_channel_name,
       null date_begin,
       'неопределено' status,
       'неопределено' agent_category_name,
       'неопределено' agent_status_name,
       'неопределено' leader,
       null date_break,
       null business_date_begin,
       null state_doc_ad
       from dual;

