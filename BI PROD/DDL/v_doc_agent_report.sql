create or replace force view v_doc_agent_report as
select
    ar.agent_report_id,
    ar.num agent_report_num,
    ach.ag_contract_header_id,
    ach.num ag_contract_num,
    c.contact_id,
    c.obj_name_orig contact_name,
    ar.report_date,
    (
     select nvl(sum(arc.comission_sum), 0)
     from   ven_agent_report_cont arc
     where  arc.agent_report_id = ar.agent_report_id
    ) comission_sum
  from
    ven_agent_report ar,
    ven_ag_contract_header ach,
    ven_contact c,
    ven_department d
  where ar.ag_contract_h_id = ach.ag_contract_header_id
    and ach.agent_id = c.contact_id
    and ach.agency_id =  d.department_id
    and d.org_tree_id in (
      select column_value from table(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id))
    );

