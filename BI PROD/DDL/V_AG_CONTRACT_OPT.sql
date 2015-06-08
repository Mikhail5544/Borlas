CREATE OR REPLACE VIEW V_AG_CONTRACT_OPT AS
SELECT --/*+ FIRST_ROWS */
    ach.ag_contract_header_id,
    ac.ag_contract_id,
    ach.agency_id,
    ach.agent_id,
    --ent.obj_name(c.ent_id,c.contact_id) agent_name,
    c.obj_name_orig agent_name,
    d.num,
    ach.date_begin,
    ach.date_break,
    ac.leg_pos,
    pkg_agent.get_end_contr(ach.ag_contract_header_id) date_end,
    decode ( doc.get_doc_status_brief(d.document_id,ds.start_date),'BREAK',
                               doc.get_doc_status_name(d.document_id,sysdate),
                               doc.get_doc_status_name(d.document_id,ds.start_date) ) status_name,--ds.start_date) )
    acat.category_name,

    sch.description as sales_channel,
    dep.name dep_name
from ag_contract_header ach
    join ag_contract ac on (ac.ag_contract_id=ach.last_ver_id)
    join contact c on c.contact_id = ach.agent_id
    join ag_category_agent acat on acat.ag_category_agent_id = ac.category_id
    join document d on d.document_id = ach.ag_contract_header_id
    join doc_status ds on (ds.document_id = d.document_id and ds.start_date in (select max(dd.start_date) from doc_status dd
                                                                               where dd.document_id=d.document_id) )
    left join department dep on (ach.agency_id=dep.department_id)
    left join t_sales_channel sch on sch.id = ach.t_sales_channel_id

     where ach.ag_contract_templ_k=0
       AND nvl(ach.Is_New,0) = 0
;
