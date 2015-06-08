CREATE MATERIALIZED VIEW INS_DWH.FC_AG_PREM_MND_TOTAL
REFRESH COMPLETE ON DEMAND
AS
SELECT arh.num vedom,
       arh.date_begin,
       arh.date_end,
       art.NAME prem_detail_name,
       ph.Ids,
       sum(apv.vol_amount) detail_amt
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   /*AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'com_chk_prem'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'com_chk_prem'
                   AND r.param_name = 'ver_ved')*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('WG_0510','SS_0510','RE_POL_0510','PG_0510')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ach.t_sales_channel_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
  -- AND ach.num = '10105'
  -- AND ach.ag_contract_header_id = 21823524
   --AND ph.Ids = 1920165615
   and art.NAMe = 'Премия за работу группы'
group by arh.num,
       arh.date_begin,
       arh.date_end,
       art.NAMe,
       ph.Ids;

