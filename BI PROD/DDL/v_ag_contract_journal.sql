CREATE OR REPLACE FORCE VIEW V_AG_CONTRACT_JOURNAL AS
SELECT --/*+ FIRST_ROWS */
    ach.ag_contract_header_id,
    ac.ag_contract_id,
    ach.agency_id,
    ach.agent_id,
    ent.obj_name(c.ent_id,c.contact_id) agent_name,
    d.num,
    ach.num||'/'||ac.num num_ver,
    ach.date_begin,
    ach.date_break,
    ac.leg_pos,
    pkg_agent.get_end_contr(ach.ag_contract_header_id) date_end,
    decode ( doc.get_doc_status_brief(d.document_id,ds.start_date),'BREAK',
                               doc.get_doc_status_name(d.document_id,sysdate),
                               doc.get_doc_status_name(d.document_id,ds.start_date) ) status_name,--ds.start_date) )
    acat.sort_id category_sort,
    acat.category_name,
    acla.class_name,
    idet.id_value kod_agent,
    idet1.id_value kod_agency,
    ac.contract_leader_id,
    dep_ld.name dep_name_ld,
    ach2.agent_id as leader_id,
    ac.contract_recrut_id,
    ach3.agent_id recruit_id,
    ent.obj_name(c.ent_id,ach3.agent_id) recruit_name,
    ent.obj_name(c.ent_id,ach2.agent_id) leader_name,
    sch.description as sales_channel,
    dep.name dep_name
    from ven_ag_contract_header ach
    join ven_ag_contract ac on (ac.ag_contract_id=ach.last_ver_id)
    join ven_contact c on c.contact_id = ach.agent_id
    join ven_ag_category_agent acat on acat.ag_category_agent_id = ac.category_id
    join document d on d.document_id = ach.ag_contract_header_id
    join doc_status ds on (ds.document_id = d.document_id and ds.start_date in (select max(dd.start_date) from doc_status dd
                                                                               where dd.document_id=d.document_id) )
    left join ven_ag_class_agent acla on acla.ag_class_agent_id = ac.class_agent_id
    left join ven_department dep on (ach.agency_id=dep.department_id)
    left join ven_ag_contract ac_ld on (ac_ld.ag_contract_id=pkg_agent_1.find_last_ver_id(ac.contract_leader_id))
    left join ven_department dep_ld on (ac_ld.agency_id=dep_ld.department_id)
    left join ven_t_sales_channel sch on sch.id = ach.t_sales_channel_id
    left join (select aaa.contact_id, aaa.id_value from ven_cn_contact_ident aaa, ven_t_id_type t where aaa.id_type=t.id and t.brief='KOD') idet on idet.contact_id=ach.agent_id
   left join (select aaa1.contact_id, aaa1.id_value from ven_cn_contact_ident aaa1, ven_t_id_type t1 where aaa1.id_type=t1.id and t1.brief='KOD') idet1 on idet1.contact_id=ach.agency_id
    left join (select ac2.ag_contract_id, ch2.agent_id from ven_ag_contract ac2, ven_ag_contract_header ch2
               where ac2.contract_id=ch2.ag_contract_header_id) ach2 on ach2.ag_contract_id=ac.contract_leader_id
  left join (select ac3.ag_contract_id, ch3.agent_id from ven_ag_contract ac3, ven_ag_contract_header ch3
               where ac3.contract_id=ch3.ag_contract_header_id) ach3 on ach3.ag_contract_id=ac.contract_recrut_id
     where ach.ag_contract_templ_k=0
;

