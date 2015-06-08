create or replace view v_commission_check_prem as
SELECT --apv.ag_perf_work_vol_id,
       arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       cn_leader.obj_name_orig leader_fio,
       apw.ag_level,
       apw.volumes.get_volume(1) rl_vol,
       apw.volumes.get_volume(2) ops_vol,
       apw.volumes.get_volume(3) sofi_vol,
       apw.volumes.get_volume(5) sofi_pay_vol,
       apw.ag_ksp ksp,
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'WG_0510') work_group,
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'RE_POL_0510') Renewal_ploicy,            
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'SS_0510') self_sale,
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'LVL_0510') level_reach,                
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'KSP_0510') KSP_reach,  
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'ES_0510') Evol_sub, 
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PENROL_0510') Enrol_sub,           
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PG_0510') Personal_group, 
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QOPS_0510') Qualitative_OPS,        
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QMOPS_0510') Q_male_OPS,                        
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PEXEC_0510') Plan_reach, 
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'Active_agent_0510') Active_agents,
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'Exec_plan_GRS') Exec_plan_GRS,                           
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'Policy_commiss_GRS') Policy_commiss_GRS,
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'OAV_GRS') Self_sale_GRS, 
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
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
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       (SELECT MAX(acp1.due_date) --После первого расчета можно будет заменить на payment_date
          FROM ins.doc_set_off dso1,
               ins.ac_payment acp1
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
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'com_chk_prem'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'com_chk_prem'
                   AND r.param_name = 'ver_ved')
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('WG_0510','SS_0510','RE_POL_0510','PG_0510') --,'Exec_plan_GRS','Policy_commiss_GRS') --,'LVL_0510')
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
  -- AND ph.Ids = 1560167117

UNION ALL

SELECT --av.ag_volume_id,
       arh.num vedom,
       ar.num vedom_ver,       
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       cn_leader.obj_name_orig leader_fio,       
       apw.ag_level,
       apw.volumes.get_volume(1) rl_vol,
       apw.volumes.get_volume(2) ops_vol,
       apw.volumes.get_volume(3) sofi_vol,
       apw.volumes.get_volume(5) sofi_pay_vol,
       apw.ag_ksp ksp,
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
         WHERE apd1.ag_perfomed_work_act_id =  apw.ag_perfomed_work_act_id --
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'WG_0510') work_group,
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'RE_POL_0510') Renewal_ploicy,            
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'SS_0510') self_sale,
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'LVL_0510') level_reach,                
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'KSP_0510') KSP_reach,  
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'ES_0510') Evol_sub, 
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PENROL_0510') Enrol_sub,                
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PG_0510') Personal_group, 
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QOPS_0510') Qualitative_OPS,        
       (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'QMOPS_0510') Q_male_OPS,                    
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'PEXEC_0510') Plan_reach, 
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'Active_agent_0510') Plan_reach, 
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'Exec_plan_GRS') Exec_plan_GRS,   
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'Policy_commiss_GRS') Policy_commiss_GRS,
      (SELECT apd1.summ
         FROM ins.ag_perfom_work_det apd1,
              ins.ag_rate_type art1
        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
          AND art1.brief = 'OAV_GRS') Self_sale_GRS,          
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND ASp.plan_type = 1        
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
       anv.snils,
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
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ven_ag_contract_header ach_s,
       ins.contact cn_as,       
       ins.ag_npf_volume_det anv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'com_chk_prem'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'com_chk_prem'
                   AND r.param_name = 'ver_ved')
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)   
   AND art.brief IN ('WG_0510','SS_0510','QMOPS_0510','QOPS_0510','PG_0510','Policy_commiss_GRS','OAV_GRS','FAKE_Sofi_prem_0510') --,'LVL_0510')
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
   AND tct.id = ac.leg_pos
 --  AND ach.num = '10295'




