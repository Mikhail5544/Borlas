create or replace view v_ksp_vol_check as
SELECT ts.DESCRIPTION sch,
       dep.NAME agency,
       ach_r.num ad_num,
       cn_a_r.obj_name_orig ag_fio,
       aca.category_name ag_cat,
       ach.num policy_ad_num,
       cn_a.obj_name_orig policy_ag_fio,
       tp.DESCRIPTION product,
       pp.pol_num,
       ph.Ids,
       cn_i.obj_name_orig insurer_fio,
       ph.start_date,
       CASE WHEN ins.doc.get_doc_status_brief(ins.pkg_policy.get_last_version(PH.Policy_Header_Id)) = 'READY_TO_CANCEL' 
            THEN (SELECT pp1.start_date 
                   FROM ins.p_policy pp1 
                  WHERE pp1.policy_id =  ins.pkg_policy.get_last_version(PH.Policy_Header_Id))
       END Decline_Date,       
       --doc.get_status_date(pkg_policy.get_last_version(PH.Policy_Header_Id),'READY_TO_CANCEL') Decline_Date,
       ins.doc.get_doc_status_name(ins.pkg_policy.get_last_version(PH.Policy_Header_Id)) last_stat,
       f.NAME fund,
       pt.DESCRIPTION pay_term,
       (SELECT SUM(pc.fee)
         FROM ins.as_asset ass,
              ins.p_cover  pc
        WHERE ass.p_policy_id = pp.policy_id
          AND ass.as_asset_id = pc.as_asset_id
          AND pc.status_hist_id <> 3)
        * ins.acc.Get_Cross_Rate_By_Id(1, ph.fund_id, 122, ph.start_date) fee,         
       akd.fee_expected,
       akd.fee_count,      
       akd.cash_recived,
       round(SUM(akd.cash_recived) OVER (PARTITION BY ach_r.ag_contract_header_id)/
       SUM(akd.fee_expected) OVER (PARTITION BY ach_r.ag_contract_header_id)*100,2) KSP,
       akd.ksp_per_begin,
       akd.ksp_per_end
      -- FLOOR((MONTHS_BETWEEN(akd.ksp_per_end-30,akd.ksp_per_begin)+0.001)/12*pt.number_of_payments+1) fc
  FROM ins.ven_ag_roll_header arh,
       ins.ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_ksp ak,
       ins.ag_ksp_det akd,
       ins.p_pol_header ph,
       ins.p_policy pp,
       ins.department dep,
       ins.ag_contract ac,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_r,
       ins.t_sales_channel ts,
       ins.t_product tp,
       ins.contact cn_i,
       ins.contact cn_a,
       ins.contact cn_a_r,
       ins.fund f,
       ins.ag_category_agent aca,
       ins.t_payment_terms pt
 WHERE 1=1
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND Ar.Ag_Roll_Id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id =  ak.document
   AND ak.ag_ksp_id = akd.ag_ksp_id
   AND arh.num = LPAD((SELECT r.param_value
                       FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'ksp_vol_chk'
                         AND r.param_name = 'num_ved'),6,'0')
   AND ach.ag_contract_header_id= akd.policy_agent
   AND apw.ag_contract_header_id = ach_r.ag_contract_header_id
   AND ach_r.ag_contract_header_id = ac.contract_id
   AND apw.date_calc BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND aca.sort_id < 6
   AND aca.ag_category_agent_id = ac.category_id
   AND ts.ID = ach_r.t_sales_channel_id
   AND akd.policy_header_id = ph.policy_header_id
   AND ph.policy_header_id = pp.pol_header_id
   AND pp.version_num = (SELECT MAX(pp_v2.version_num)
                           FROM ins.p_policy pp_v2
                          WHERE pp_v2.pol_header_id = ph.policy_header_id
                            AND pp_v2.start_date =
                                (SELECT MIN(pp_v3.start_date)
                                   FROM ins.p_policy pp_v3
                                  WHERE pp_v3.pol_header_id = ph.policy_header_id))
   AND tp.product_id = ph.product_id
   AND pt.ID = pp.payment_term_id
   AND ph.fund_id = f.fund_id
   AND cn_a.contact_id = ach.agent_id
   AND cn_a_r.contact_id = ach_r.agent_id
   AND cn_i.contact_id = ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь')
 