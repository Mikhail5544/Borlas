CREATE OR REPLACE VIEW V_UNGROUP_OAV_RLP AS
SELECT DATE_BEGIN_AD
      ,AGENT_NUM
      ,AGENT_FIO
      ,SUM(detail_vol_amt) detail_vol_amt
      ,ROUND(SUM(vol_av),2) DETAIL_COMMIS
      ,AGENCY
      ,AG_PERFOMED_WORK_ACT_ID
      ,AG_ROLL_ID
      ,AG_CONTRACT_HEADER_ID
FROM
(
SELECT ar.ag_roll_id,
       dep.NAME agency,
       ach.date_begin date_begin_ad,
       ach.ag_contract_header_id,
       apw.ag_act_rlp_id ag_perfomed_work_act_id,
       d_ach.num agent_num,
       aca.category_name,
       cn.obj_name_orig agent_fio,
       apw.SUM act_commission,
       ph.Ids IDS,
       cn_ins.obj_name_orig Insuer,
       agv.date_begin policy_begin,
       agv.ins_period insurance_term,
       agv.epg_date,
       agv.pay_period pay_year,
       agv.epg_ammount,
       agv.payment_date,
       agv.nbv_coef,
       apv.vol_amount detail_vol_amt,
       apv.vol_rate detail_vol_rate,
       ins.acc.Get_Cross_Rate_By_Id(1
                                    ,ph.fund_id
                                    ,122
                                    ,agv.payment_date) * apv.vol_amount*apv.vol_rate detail_commis,
       apv.vol_sav vol_sav,
       ins.acc.Get_Cross_Rate_By_Id(1
                                   ,ph.fund_id
                                   ,122
                                   ,agv.payment_date) * apv.vol_amount*apv.vol_rate - apv.vol_sav vol_av
  FROM ins.ag_roll_header arh,
       ins.ag_roll_type agrt,
       ins.ag_roll ar,
       ins.ag_act_rlp apw,
       ins.ag_work_det_rlp apd,
       ins.ag_rate_type art,
       ins.ag_vol_rlp apv,
       ins.ag_volume_rlp agv,
       ins.ag_volume_type avt,
       ins.ag_contract_header ach,
       ins.document d_ach,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.department dep,
       ins.contact cn,
       ins.contact cn_ins,
       ins.p_pol_header ph
 WHERE 1=1
   AND arh.ag_roll_type_id = agrt.ag_roll_type_id
   AND agrt.brief = 'RLP_CALC'
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_act_rlp_id = apd.ag_act_rlp_id
   AND apd.ag_work_det_rlp_id = apv.ag_work_det_rlp_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_rlp_id = agv.ag_volume_rlp_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.category_id = aca.ag_category_agent_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('RL','INV','FDep')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND dep.department_id(+) = ac.agency_id
   AND ach.agent_id = cn.contact_id
   AND ach.ag_contract_header_id = d_ach.document_id
   AND agv.policy_header_id = ph.policy_header_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_ins.contact_id
   AND NVL(agv.is_future,0) = 0
)
GROUP BY DATE_BEGIN_AD
      ,AGENT_NUM
      ,AGENT_FIO
      ,AGENCY
      ,AG_PERFOMED_WORK_ACT_ID
      ,AG_ROLL_ID
      ,AG_CONTRACT_HEADER_ID;
   
grant select on INS.V_UNGROUP_OAV_RLP to INS_READ;
