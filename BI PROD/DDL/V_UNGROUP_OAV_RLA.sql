CREATE OR REPLACE VIEW V_UNGROUP_OAV_RLA AS
SELECT DATE_BEGIN_AD
      ,AGENT_NUM
      ,AGENT_FIO
      ,SUM(detail_vol_amt) detail_vol_amt
      ,SUM(DETAIL_COMMIS) DETAIL_COMMIS
      ,AGENCY
      ,AG_PERFOMED_WORK_ACT_ID
      ,AG_ROLL_ID
      ,AG_CONTRACT_HEADER_ID
FROM
(
SELECT ach.date_begin date_begin_ad,
       ach.num agent_num,
       cn.obj_name_orig agent_fio,
       apv.vol_amount detail_vol_amt,
       apv.vol_amount*apv.vol_rate detail_commis,
       dep.name agency,
       apw.ag_perfomed_work_act_id,
       ar.ag_roll_id,
       ach.ag_contract_header_id
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.department dep,
       ins.t_contact_type tct,
       ins.contact cn,
       ins.contact cn_ins,
       ins.p_pol_header ph,
       ins.p_policy pp,
       ins.t_product tp,
       ins.t_payment_terms pt,
       ins.fund f,
       ins.ac_payment_templ acpt,
       ins.document epg,
       ins.document pd,
       ins.trans t,
       ins.t_collection_method cm,
       ins.t_prod_line_option tplo
 WHERE 1=1
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_id = agv.ag_volume_id
   AND tct.ID = ac.leg_pos
   AND ac.contract_id = ach.ag_contract_header_id
   AND ts.ID (+) = ac.ag_sales_chn_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.category_id = aca.ag_category_agent_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('RL','INV','FDep')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND dep.department_id(+) = ac.agency_id
   AND ach.agent_id = cn.contact_id
   AND agv.policy_header_id = ph.policy_header_id
   AND ph.policy_id = pp.policy_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_ins.contact_id
   AND agv.payment_term_id = pt.ID
   AND epg.document_id = agv.epg_payment
   AND f.fund_id = agv.fund
   AND agv.pd_payment = pd.document_id
   AND acpt.payment_templ_id = agv.epg_pd_type
   AND cm.id = agv.pd_collection_method
   AND tplo.ID = agv.t_prod_line_option_id
   AND agv.trans_id = t.trans_id (+)
   AND tp.product_id = ph.product_id
)
GROUP BY DATE_BEGIN_AD
      ,AGENT_NUM
      ,AGENT_FIO
      ,AGENCY
      ,AG_PERFOMED_WORK_ACT_ID
      ,AG_ROLL_ID
      ,AG_CONTRACT_HEADER_ID;
      
GRANT SELECT ON INS.V_UNGROUP_OAV_RLA TO INS_READ;

