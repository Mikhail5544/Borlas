create or replace force view v_veselek_agent_60_days as
select distinct k.agent_name,
       k.dep,
       k.sales_chnl,
       k.status_name
from
(select /*pp.policy_header_id,
       pp.pol_ser||' '||pp.pol_num,
       pp.notice_num,*/
       ag.m_date,
       sysdate - ag.m_date as days,
       dep.name as dep,
       ch.description as sales_chnl,
       --st.name as policy_agent_status,
       cc.name||' '||cc.first_name||' '||cc.middle_name as agent_name,
       decode ( doc.get_doc_status_brief(d.document_id,ds.start_date),'BREAK',
                               doc.get_doc_status_name(d.document_id,sysdate),
                               doc.get_doc_status_name(d.document_id,ds.start_date) )status_name
from  (select max(ag.date_start) as m_date, ag.ag_contract_header_id
       from p_policy_agent ag
       group by ag.ag_contract_header_id) ag
     left join p_policy_agent ags on (ags.ag_contract_header_id = ag.ag_contract_header_id and ags.date_start = ag.m_date)
     left join v_policy_version_journal pp on (ags.policy_header_id = pp.policy_header_id)
     left join ag_contract_header ah on (ags.ag_contract_header_id = ah.ag_contract_header_id)
     join document d on d.document_id = ah.ag_contract_header_id
    join doc_status ds on (ds.document_id = d.document_id and ds.start_date in (select max(dd.start_date) from doc_status dd
                                                                               where dd.document_id=d.document_id) )
     left join contact cc on (cc.contact_id = ah.agent_id )
     left join department dep on ah.agency_id = dep.department_id
     left join policy_agent_status st on (ags.status_id = st.policy_agent_status_id)
     left join t_sales_channel ch on (ch.id = pp.sales_channel_id)
     left join ag_contract agc on (agc.ag_contract_id = ah.last_ver_id)

where pp.policy_id = pp.active_policy_id
      and agc.category_id in (1,2)
      and pp.status_name not in ('Отменен')
      and st.name not in ('ОТМЕНЕН','ОШИБКА')
      and sysdate - ag.m_date > 60
      and decode ( doc.get_doc_status_brief(d.document_id,ds.start_date),'BREAK',
                               doc.get_doc_status_name(d.document_id,sysdate),
                               doc.get_doc_status_name(d.document_id,ds.start_date) ) not in ('Расторгнут','Завершен','Отменен','Приостановлен','Закрыт')) k
     --and pp.notice_date between to_date('01-03-2008','dd-mm-yyyy') and to_date('31-03-2008','dd-mm-yyyy')



  /*select distinct ag.ag_contract_header_id,
       decode ( doc.get_doc_status_brief(d.document_id,ds.start_date),'BREAK',
                               doc.get_doc_status_name(d.document_id,sysdate),
                               doc.get_doc_status_name(d.document_id,ds.start_date) )status_name,
       c.name||' '||c.first_name||' '||c.middle_name as agent,
       ag.date_start
from (select max(ag.date_start) as max_d, ag.ag_contract_header_id
      from p_policy_agent ag
      group by ag.ag_contract_header_id) m
      left join p_policy_agent ag on (ag.ag_contract_header_id = m.ag_contract_header_id and ag.date_start = m.max_d)
      left join ag_contract_header h on (ag.ag_contract_header_id = h.ag_contract_header_id)
      left join contact c on (c.contact_id = h.agent_id)
      join document d on d.document_id = h.ag_contract_header_id
      join doc_status ds on (ds.document_id = d.document_id and ds.start_date in (select max(dd.start_date) from doc_status dd
                                                                               where dd.document_id=d.document_id) )
      left join v_policy_version_journal vv on (vv.policy_header_id = ag.policy_header_id)
where vv.policy_id = vv.active_policy_id
      and decode ( doc.get_doc_status_brief(d.document_id,ds.start_date),'BREAK',
                               doc.get_doc_status_name(d.document_id,sysdate),
                               doc.get_doc_status_name(d.document_id,ds.start_date) ) not in ('Расторгнут','Завершен','Приостановлен','Закрыт','Отменен')
      and sysdate - ag.date_start > 60*/
;

