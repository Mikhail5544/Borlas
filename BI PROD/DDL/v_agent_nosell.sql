CREATE OR REPLACE VIEW INS.V_AGENT_NOSELL AS
select agent_name, sales_ch, department, leader_name, date_begin, start_date, tel_cont, tel_own, tel, round(sysdate - start_date,0) days
from (
select agent_name, sales_ch, department, leader_name, date_begin, max(start_date) start_date, nvl(tel_cont,'') tel_cont, nvl(tel_own,'') tel_own, nvl(tel_mob,'') tel
from (
select d.num ||' '||c.obj_name_orig agent_name,
       ch.description sales_ch,
       dep.name department,
       dl.num ||' '|| cl.obj_name_orig leader_name,
       agh.date_begin,
       anv.notice_date start_date,
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
from ins.ag_roll_header arh,
     ins.ag_roll ar,
     ins.ag_volume av,
     ins.ag_npf_volume_det anv,
     ins.ag_volume_type avt,
     ins.ag_contract_header agh,
     ins.document d,
     ins.ag_contract ag,
     ins.contact c,
     ins.t_sales_channel ch,
     ins.department dep,
     ins.ag_category_agent cat,
     ins.ag_contract agl,
     ins.ag_contract_header aghl,
     ins.contact cl, ins.document dl
where arh.ag_roll_header_id = ar.ag_roll_header_id
      and ar.ag_roll_id = av.ag_roll_id
      and av.ag_volume_type_id = avt.ag_volume_type_id
      and anv.ag_volume_id = av.ag_volume_id
      and av.ag_contract_header_id = agh.ag_contract_header_id
      and agh.ag_contract_header_id = ag.contract_id
      and nvl(agh.is_new,0) = 1
      and sysdate between ag.date_begin and ag.date_end
      and agh.agent_id = c.contact_id
      and agh.t_sales_channel_id = ch.id
      and ag.agency_id = dep.department_id
      and ag.category_id = cat.ag_category_agent_id
      and cat.category_name = 'Агент'
      and ins.doc.get_doc_status_brief(agh.ag_contract_header_id) = 'CURRENT'
      and agh.ag_contract_header_id = d.document_id
      and ag.contract_leader_id = agl.ag_contract_id(+)
      and agl.contract_id = aghl.ag_contract_header_id(+)
      and aghl.agent_id = cl.contact_id(+)
      and aghl.ag_contract_header_id = dl.document_id(+)
      
union

select d.num ||' '||c.obj_name_orig agent_name,
       ch.description sales_ch,
       dep.name department,
       dl.num ||' '|| cl.obj_name_orig leader_name,
       agh.date_begin,
       ph.start_date start_date,
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
from ins.ag_roll_header arh,
     ins.ag_roll ar,
     ins.ag_volume av,
     ins.ag_volume_type avt,
     ins.ag_contract_header agh,
     ins.document d,
     ins.ag_contract ag,
     ins.contact c,
     ins.t_sales_channel ch,
     ins.department dep,
     ins.ag_category_agent cat,
     ins.ag_contract agl,
     ins.ag_contract_header aghl,
     ins.contact cl, ins.document dl,
     ins.p_pol_header ph
where arh.ag_roll_header_id = ar.ag_roll_header_id
      and ar.ag_roll_id = av.ag_roll_id
      and av.ag_volume_type_id = avt.ag_volume_type_id
      and av.ag_contract_header_id = agh.ag_contract_header_id
      and agh.ag_contract_header_id = ag.contract_id
      and nvl(agh.is_new,0) = 1
      and sysdate between ag.date_begin and ag.date_end
      and agh.agent_id = c.contact_id
      and agh.t_sales_channel_id = ch.id
      and ag.agency_id = dep.department_id
      and ag.category_id = cat.ag_category_agent_id
      and cat.category_name = 'Агент'
      and ins.doc.get_doc_status_brief(agh.ag_contract_header_id) = 'CURRENT'
      and agh.ag_contract_header_id = d.document_id
      and ag.contract_leader_id = agl.ag_contract_id(+)
      and agl.contract_id = aghl.ag_contract_header_id(+)
      and aghl.agent_id = cl.contact_id(+)
      and aghl.ag_contract_header_id = dl.document_id(+)
      and av.policy_header_id = ph.policy_header_id
      and avt.brief = 'RL'
)
group by agent_name, sales_ch, department, leader_name, date_begin, nvl(tel_cont,''), nvl(tel_own,''), nvl(tel_mob,'')
)
where sysdate - start_date > (SELECT to_number(r.param_value)
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'agent_nosell'
                            AND r.param_name = 'num_days')
