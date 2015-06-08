create or replace force view ins_dwh.v_nobank_account_agents as
select num_ag,sales_name,category_name,name_ag,nvl(tel_cont,'') tel_cont,
       nvl(tel_own,'') tel_own, nvl(tel_mob,'') tel,
       date_begin,depart,num_leader,stat_ag
from
(select ch.description sales_name,
       d.num num_ag,
       agh.date_begin,
       c.obj_name_orig name_ag,
       cat.category_name,
       dep.name depart,
       (select dl.num ||' '|| cl.obj_name_orig
        from ins.ag_contract agl,
             ins.ag_contract_header aghl,
             ins.document dl,
             ins.contact cl
        where agl.ag_contract_id = ag.contract_leader_id
              and agl.contract_id = aghl.ag_contract_header_id
              and aghl.ag_contract_header_id = dl.document_id
              and aghl.agent_id = cl.contact_id) num_leader,
       ins.doc.get_doc_status_name(agh.ag_contract_header_id) stat_ag,
       (select tel.telephone_prefix||' '||tel.telephone_number tel
       from ins.t_telephone_type tt,
            ins.cn_contact_telephone tel
       where tel.contact_id = c.contact_id
             and tt.id = tel.telephone_type
             and tt.description in ('Контактный телефон')
             and length(tel.telephone_number) > 3
             and rownum = 1
        ) tel_cont,
       (select tel.telephone_prefix||' '||tel.telephone_number tel
       from ins.t_telephone_type tt,
            ins.cn_contact_telephone tel
       where tel.contact_id = c.contact_id
             and tt.id = tel.telephone_type
             and tt.description in ('Личный телефон')
             and length(tel.telephone_number) > 3
             and rownum = 1
        ) tel_own,
       (select tel.telephone_prefix||' '||tel.telephone_number tel
       from ins.t_telephone_type tt,
            ins.cn_contact_telephone tel
       where tel.contact_id = c.contact_id
             and tt.id = tel.telephone_type
             and tt.description in ('Мобильный')
             and length(tel.telephone_number) > 3
             and rownum = 1
        ) tel_mob
from ins.ag_contract_header agh,
     ins.ag_contract ag,
     ins.document d,
     ins.contact c,
     ins.t_sales_channel ch,
     ins.department dep,
     ins.ag_category_agent cat
where agh.ag_contract_header_id = d.document_id
      and agh.agent_id = c.contact_id
      and ag.contract_id = agh.ag_contract_header_id
      and sysdate between ag.date_begin and ag.date_end
      and nvl(agh.is_new,0) = 1
      and ch.id = agh.t_sales_channel_id
      and dep.department_id = ag.agency_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.ag_contract_header_id not in
                    (select ach.ag_contract_header_id
                     from ins.ag_contract_header ach,
                          ins.ven_ag_bank_props b
                     where ach.ag_contract_header_id = b.ag_contract_header_id
                           and nvl(agh.is_new,0) = 1
                           and b.bank_id is not null
                     )
      and agh.ag_contract_header_id in (
              select agd.ag_contract_header_id
              from ins.ag_documents agd,
                   ins.ag_doc_type dt
              where agd.ag_contract_header_id = agh.ag_contract_header_id
                    and agd.ag_doc_type_id = dt.ag_doc_type_id
                    and dt.brief = 'NEW_AD'
                    and ins.doc.get_doc_status_name(agd.ag_documents_id) in ('Проверено в ЦО','В архиве ЦО')
      )
      and ins.doc.get_doc_status_name(agh.ag_contract_header_id) = 'Действующий'
);

