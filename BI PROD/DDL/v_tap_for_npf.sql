create or replace force view v_tap_for_npf as
select dh.num,
       c.obj_name_orig name_agent,
       (select rf.name from ins.doc_status_ref rf where rf.doc_status_ref_id = dh.doc_status_ref_id) state,
       dep.name department,
       tac.tac_num,
       tac.tac_name,
       ch.description sales_ch
from ins.ag_contract_header agh,
     ins.document dh,
     ins.contact c,
     ins.ag_contract ag,
     ins.t_sales_channel ch,
     ins.department dep,
     ins.ven_organisation_tree tr,
     ins.agn_tac tac
where agh.agent_id = c.contact_id
      and agh.ag_contract_header_id = ag.contract_id
      and sysdate between ag.date_begin and ag.date_end
      and ag.agency_id = dep.department_id(+)
      and ag.ag_sales_chn_id = ch.id
      and NVL(agh.is_new,0) = 1
      and tr.organisation_tree_id(+) = dep.org_tree_id
      and tr.tac_id = tac.agn_tac_id(+)
      and agh.ag_contract_header_id = dh.document_id;

