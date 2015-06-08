create or replace view v_agent_tap_report as
SELECT 
 agh.num
,c.obj_name_orig name_agent
,ins.pkg_readonly.get_doc_status_name(agh.ag_contract_header_id) state
,dep.name department
,tac.tac_num
,tac.tac_name
,ch.description sales_ch
,tap_tac.tac_number
  FROM ins.ven_ag_contract_header agh
      ,ins.contact c
      ,ins.ag_contract ag
      ,ins.t_sales_channel ch
      ,ins.department dep
      ,ins.ven_organisation_tree tr
      ,ins.agn_tac tac
      ,(SELECT th_.agn_tac_id, cp_.t_tac_id, tac_.tac_number
          FROM ven_t_tac_to_tap cp_
              ,ven_t_tap_header th_
              ,ven_t_tap        tt_
              ,t_tac            tac_
         WHERE cp_.t_tap_header_id = th_.t_tap_header_id
           AND th_.last_tap_id = tt_.t_tap_id
           AND nullif(cp_.end_date, pkg_tac.get_default_end_date) IS NULL
           and cp_.t_tac_id = tac_.t_tac_id   
        ) tap_tac
 WHERE agh.agent_id = c.contact_id
   AND agh.ag_contract_header_id = ag.contract_id
   AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
   AND ag.agency_id = dep.department_id(+)
   AND ag.ag_sales_chn_id = ch.id
   AND NVL(agh.is_new, 0) = 1
   AND tr.organisation_tree_id(+) = dep.org_tree_id
   AND tr.tac_id = tac.agn_tac_id(+)
   AND tac.agn_tac_id = tap_tac.agn_tac_id(+)
      
