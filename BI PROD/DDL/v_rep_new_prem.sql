CREATE OR REPLACE FORCE VIEW V_REP_NEW_PREM AS
(
SELECT --apv.ag_perf_work_vol_id,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num,
       tct.DESCRIPTION leg_pos,
       apd.count_recruit_agent lev,
       apd.rl_vol_amt,
       apd.all_vol_amt,
       apd.ksp,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'WG_0510') work_group,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'RE_POL_0510') Renewal_ploicy,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'SS_0510') self_sale,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'LVL_0510') level_reach,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'KSP_0510') KSP_reach,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'ES_0510') Evol_sub,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PENROL_0510') Enrol_lead_sub,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PG_0510') Personal_group,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QOPS_0510') Qualitative_OPS,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QMOPS_0510') Q_male_OPS,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PEXEC_0510') Plan_reach,
       (SELECT asp.plan_value
         FROM ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       tp.DESCRIPTION product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM document d WHERE d.document_id=av.epg_payment) epg,
       (SELECT MAX(acp1.due_date) --После первого расчета можно будет заменить на payment_date
          FROM doc_set_off dso1,
               ac_payment acp1
         WHERE dso1.parent_doc_id = av.epg_payment
           AND acp1.payment_id = dso1.child_doc_id
           AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) payment_DATE,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       apv.vol_amount detail_amt,
       apv.vol_rate detail_rate,
       apv.vol_amount*apv.vol_rate detail_commis
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_rate_type art,
       ag_perf_work_vol apv,
       ag_volume av,
       ag_volume_type avt,
       ven_ag_contract_header ach,
       ven_ag_contract_header ach_s,
       contact cn_as,
       contact cn_a,
       department dep,
       t_sales_channel ts,
       ag_contract ac,
       ag_category_agent aca,
       t_contact_type tct,
       p_pol_header ph,
       t_product tp,
       t_prod_line_option tplo,
       t_payment_terms pt,
       p_policy pp,
       contact cn_i
 WHERE 1=1
/*   AND arh.num= '000209'
   AND ar.num = '1'*/
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','EGORNOVA')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav' and param_name = 'version_num')
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('WG_0510','SS_0510','RE_POL_0510','PG_0510') --,'LVL_0510')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
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
  -- AND ph.Ids = 1560167117

UNION ALL

SELECT --av.ag_volume_id,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num,
       tct.DESCRIPTION leg_pos,
       apd.count_recruit_agent lev,
       apd.rl_vol_amt,
       apd.all_vol_amt,
       apd.ksp,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
         WHERE apd1.ag_perfomed_work_act_id =  apw.ag_perfomed_work_act_id --
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'WG_0510') work_group,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'RE_POL_0510') Renewal_ploicy,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'SS_0510') self_sale,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'LVL_0510') level_reach,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'KSP_0510') KSP_reach,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'ES_0510') Evol_sub,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PENROL_0510') Enrol_lead_sub,
      (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PG_0510') Personal_group,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QOPS_0510') Qualitative_OPS,
       (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QMOPS_0510') Q_male_OPS,
      (SELECT apd1.summ
         FROM ag_perfom_work_det apd1,
              ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PEXEC_0510') Plan_reach,
       (SELECT asp.plan_value
         FROM ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       NULL product,
       NULL,
      --     apv.ag_perf_work_vol_id,
      --    av.ag_volume_id,
      --    anv.ag_npf_volume_det_id,
       anv.policy_num,
       anv.sign_date,
       anv.fio insuer,
       anv.assured_birf_date,
       anv.gender,
       NULL epg,
       NULL,
       NULL risk,
       NULL,
       NULL,
       NULL payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       apv.vol_amount detail_amt,
       apv.vol_rate detail_rate,
       apv.vol_amount*apv.vol_rate detail_commis
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_rate_type art,
       ag_perf_work_vol apv,
       ven_ag_contract_header ach_s,
       contact cn_as,
       ag_npf_volume_det anv,
       ag_volume av,
       ag_volume_type avt,
       ven_ag_contract_header ach,
       contact cn_a,
       department dep,
       t_sales_channel ts,
       ag_contract ac,
       ag_category_agent aca,
       t_contact_type tct
 WHERE 1=1
/*   AND arh.num= '000209'
   AND ar.num = '1'*/
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','EGORNOVA')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav' and param_name = 'version_num')
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('WG_0510','SS_0510','QMOPS_0510','QOPS_0510','PG_0510') --,'LVL_0510')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND av.ag_volume_id = anv.ag_volume_id
   AND avt.ag_volume_type_id = av.ag_volume_type_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ach.t_sales_channel_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos)
;

