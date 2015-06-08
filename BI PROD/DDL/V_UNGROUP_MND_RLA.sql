CREATE OR REPLACE VIEW V_UNGROUP_MND_RLA AS
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
SELECT ag_fio agent_fio,
       agent_num,
       (vol_amount * vol_rate * vol_units) detail_vol_amt,
       (vol_amount * vol_rate * vol_units * vol_decrease) DETAIL_COMMIS,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency 
FROM
(
SELECT ag_fio,
       agent_num,
       prem_detail_name,
       product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       CASE WHEN vol_rate = -1 THEN 1 ELSE vol_rate END vol_rate,
       SUM(vol_units) vol_units,
       vol_decrease,
       epg_date,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency
FROM
(
SELECT arh.ag_roll_header_id,
       ar.ag_roll_id,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       ach.date_begin date_begin_ad,
       ach.ag_contract_header_id,
       apw.ag_perfomed_work_act_id,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_rate,0) vol_rate,
       NVL(apv.vol_units,0) vol_units,
       NVL(apv.vol_amount,0) vol_amount,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date
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
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_MANAG_STRUCTURE','RLA_CONTRIB_YEARS')
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
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
)
GROUP BY ag_fio,
       agent_num,
       prem_detail_name,
       product,
       Ids,
       pol_num,
       insuer,
       epg,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       vol_rate,
       vol_decrease,
       epg_date,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency
)
UNION ALL
SELECT ag_fio agent_fio,
       agent_num,
       SUM(detail_commis) detail_vol_amt,
       SUM(detail_commis) * vol_decrease detail_commis,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency
FROM
(
SELECT arh.ag_roll_header_id,
       ar.ag_roll_id,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       ach.date_begin date_begin_ad,
       ach.ag_contract_header_id,
       apw.ag_perfomed_work_act_id,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_amount,0) detail_amt,
       NVL(apv.vol_rate,0) detail_rate,
       NVL(apv.vol_units,0) detail_vol_units,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.vol_amount*apv.vol_rate detail_commis,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date
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
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_PERSONAL_POL')
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
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
)
GROUP BY ag_fio,
       agent_num,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency,
       vol_decrease
/*RLA_VOLUME_GROUP*/
UNION ALL
SELECT ag_fio agent_fio,
       agent_num,
       SUM(detail_commis) detail_vol_amt,
       SUM(detail_commis) detail_commis,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency
FROM
(
SELECT arh.ag_roll_header_id,
       ar.ag_roll_id,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       ach.date_begin date_begin_ad,
       ach.ag_contract_header_id,
       apw.ag_perfomed_work_act_id,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_amount,0) detail_amt,
       NVL(apv.vol_rate,0) detail_rate,
       NVL(apv.vol_units,0) detail_vol_units,
       apv.vol_amount*apv.vol_rate*NVL(apv.vol_decrease,1) detail_commis,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date
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
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_VOLUME_GROUP')
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
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
)
GROUP BY ag_fio,
       agent_num,
       date_begin_ad,
       ag_roll_id,
       ag_contract_header_id,
       ag_perfomed_work_act_id,
       agency
)
GROUP BY DATE_BEGIN_AD
      ,AGENT_NUM
      ,AGENT_FIO
      ,AGENCY
      ,AG_PERFOMED_WORK_ACT_ID
      ,AG_ROLL_ID
      ,AG_CONTRACT_HEADER_ID;
