create or replace force view v_ag_template_journal as
select
    ach.ag_contract_header_id,
    ac.ag_contract_id,
    ach.agency_id,
    ach.templ_name,
    ach.TEMPL_BRIEF,
    d.num,
    --ach.num||'/'||ac.num num_ver,
    ach.date_begin,
    d.reg_date,
    --pkg_agent.get_status_contr_activ_name(ach.ag_contract_header_id) status_name,
    acat.sort_id category_sort,
    acat.category_name,
    acla.class_name,
    ac.contract_leader_id,
    ach.ag_contract_templ_k,
    sch.description as sales_channel
    from ven_ag_contract_header ach
    left join ven_ag_contract ac on pkg_agent.get_status_contr_activ_id(ach.ag_contract_header_id) = ac.ag_contract_id
    left join ven_ag_category_agent acat on acat.ag_category_agent_id = ac.category_id
    left join ven_ag_class_agent acla on acla.ag_class_agent_id = ac.class_agent_id
    join document d on d.document_id = ach.ag_contract_header_id
    left join ven_t_sales_channel sch on sch.id = ach.t_sales_channel_id
    left join (select ac2.ag_contract_id, ch2.agent_id from ven_ag_contract ac2, ven_ag_contract_header ch2
               where ac2.contract_id=ch2.ag_contract_header_id) ach2 on ach2.ag_contract_id=ac.contract_leader_id
    where ach.ag_contract_templ_k > 0
    order by ach.templ_name
;

