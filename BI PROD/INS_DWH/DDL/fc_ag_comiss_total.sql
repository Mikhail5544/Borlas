CREATE MATERIALIZED VIEW INS_DWH.FC_AG_COMISS_TOTAL
REFRESH COMPLETE ON DEMAND
AS
SELECT arh.date_begin,
           arh.date_end,
           art.NAME prem_type,
           sum(APD.SUMM) prem_sum,
           ach.num AD_NUM,
           cn.obj_name_orig "AGENT",
           aca.category_name agent_category,
           dep.NAME agency,
           ts.description "Sales_ch",
           cn_l.obj_name_orig Leader,
           aca_l.category_name Leader_cat,
           dep_l.NAME leader_agency
      FROM ins.ven_ag_roll_header   arh,
           ins.ag_roll_type         arot,
           ins.ag_roll              ar,
           ins.ag_perfomed_work_act apw,
           ins.ag_contract          ac,
           ins.ag_category_agent    aca,
           ins.department           dep,
           ins.ag_agent_tree        aat,
           ins.ag_contract_header   ach_l,
           ins.ag_contract          ac_l,
           ins.ag_category_agent    aca_l,
           ins.contact              cn_l,
           ins.department           dep_l,
           ins.ag_perfom_work_det   apd,
           ins.contact              cn,
           ins.ag_rate_type         art,
           ins.ven_ag_contract_header   ach,
           ins.t_sales_channel       ts
     WHERE 1 = 1
      -- AND arh.num IN ('000233','000234')
       AND ar.ag_roll_header_id = arh.ag_roll_header_id
       and arh.ag_roll_type_id = arot.ag_roll_type_id
       and arot.brief in ('OAV_0510','MnD_PREM')
       AND ar.ag_roll_id = apw.ag_roll_id
       AND apw.ag_contract_header_id = ach.ag_contract_header_id
       AND ach.ag_contract_header_id = aat.ag_contract_header_id
       AND aat.ag_parent_header_id = ach_l.ag_contract_header_id (+)
       and arh.date_end between aat.date_begin and aat.date_end
       AND ach_l.ag_contract_header_id = ac_l.contract_id (+)
       AND ach_l.agent_id = cn_l.contact_id (+)
       AND (arh.date_end BETWEEN ac_l.date_begin AND ac_l.date_end
           or ac_l.ag_contract_id is null)
       AND ac_l.agency_id = dep_l.department_id (+)
       AND ac_l.category_id = aca_l.ag_category_agent_id (+)
       AND ach.agent_id = cn.contact_id
       AND ac.agency_id = dep.department_id
       AND ac.category_id = aca.ag_category_agent_id
       AND apd.ag_rate_type_id = art.ag_rate_type_id
       AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND ac.contract_id = apw.ag_contract_header_id
       and ach.t_sales_channel_id = ts.id
       --AND apd.summ != 0
       AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   group by arh.date_begin,
           arh.date_end,
           ach.num,
           ts.description,
           art.NAME ,
           cn.obj_name_orig ,
           aca.category_name ,
           dep.NAME,
           cn_l.obj_name_orig ,
           aca_l.category_name ,
           dep_l.NAME;

