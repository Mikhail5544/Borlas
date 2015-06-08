CREATE OR REPLACE VIEW v_find_cover_detail AS
SELECT pha.product_id,
       pha.policy_id,
       (SELECT agh.date_begin
        FROM ins.ag_contract_header agh
        WHERE agh.ag_contract_header_id = pad.ag_contract_header_id) begin_ad_date,
       pha.start_date date_s,
       pha.payment_term_id pay_term,
       pha.doc_status_ref_id last_st,
       pha.ref_pp_id active_st,
       pha.fund_id fund,
       (SELECT MIN(ds1.start_date)
         FROM p_policy pp1,
              doc_status ds1
        WHERE pp1.pol_header_id = pha.policy_header_id
          AND pp1.policy_id = ds1.document_id
          AND ds1.doc_status_ref_id IN (91,2)) conclude_date,
       --ЭПГ
       epg.plan_date epg_date,
       epg.amount epg_amt,
       decode(pha.fund_id, 122, epg.amount,  epg.rev_amount) rev_amount,
       (SELECT nvl(sum(decode(dd_e.doc_doc_id, 
                              NULL, 
                              dso_e.set_off_child_amount, 
                              dso2_e.Set_Off_Child_Amount)),0)
          FROM doc_set_off dso_e,
               ac_payment acp_e,
               doc_doc dd_e,
               doc_set_off dso2_e
         WHERE dso_e.parent_doc_id = epg.payment_id
           AND acp_e.payment_id = dso_e.parent_doc_id
           AND dso_e.cancel_date IS NULL
           AND acp_e.payment_id = dd_e.parent_id (+)
           AND dd_e.child_id = dso2_e.parent_doc_id (+)
           AND dso2_e.cancel_date IS NULL) epg_payed,
       doc.get_doc_status_id(epg.payment_id) epg_st,
       epg_dso.set_off_child_amount epg_set_off,
       epg_pd.payment_templ_id epg_pd_type,
       --Платежный док
       decode(pha.fund_id, 122,epg_pd_copy.amount,epg_pd_copy.rev_amount) pd_copy_rev_amount,
       pd_dso.set_off_amount pd_dso_set_off_amount,
       doc.get_doc_status_id(epg_pd_copy.payment_id) pd_copy_stat,                              
       epg_pd.due_date payment_date,
       nvl(pp_pd.collection_metod_id, nvl(epg_pd_copy.collection_metod_id,epg_pd.collection_metod_id) ) pay_doc_cm,
       pha.fee,
       pha.ID tplo_id,
       t.trans_id,
       /**/
       CASE WHEN agh.is_new = 1 THEN
       (SELECT ch.description
        FROM ins.ag_contract ag,
             ins.t_sales_channel ch
        WHERE ag.contract_id = agh.ag_contract_header_id
          AND TO_DATE((SELECT r.param_value
                       FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'cov_det'
                       AND r.param_name = 'date_end'
                       )
                      ,'DD.MM.YYYY'
                      ) BETWEEN ag.date_begin AND ag.date_end
           AND ag.ag_sales_chn_id = ch.id
       )
       ELSE
       (SELECT ch.description
        FROM ins.t_sales_channel ch
        WHERE ch.id = agh.t_sales_channel_id
       )
       END ag_sales_ch,
       CASE WHEN agh.is_new = 1 THEN
       (SELECT dep.department_id
        FROM ins.ag_contract ag,
             ins.department dep
        WHERE ag.contract_id = agh.ag_contract_header_id
          AND TO_DATE((SELECT r.param_value
                       FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'cov_det'
                       AND r.param_name = 'date_end'
                       )
                      ,'DD.MM.YYYY'
                      ) BETWEEN ag.date_begin AND ag.date_end
           AND ag.agency_id = dep.department_id
       )  
       ELSE
       (SELECT dep.department_id
        FROM ins.department dep
        WHERE dep.department_id = agh.agency_id
       )  
       END ag_department_id,
       CASE WHEN agh.is_new = 1 THEN
       (SELECT cat.category_name
        FROM ins.ag_contract ag,
             ins.ag_category_agent cat
        WHERE ag.contract_id = agh.ag_contract_header_id
          AND TO_DATE((SELECT r.param_value
                       FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'cov_det'
                       AND r.param_name = 'date_end'
                       )
                      ,'DD.MM.YYYY'
                      ) BETWEEN ag.date_begin AND ag.date_end
           AND ag.category_id = cat.ag_category_agent_id
       )  
       ELSE
       (SELECT cat.category_name
        FROM ins.ag_contract ag,
             ins.ag_category_agent cat
        WHERE agh.last_ver_id = ag.ag_contract_id
          AND ag.category_id = cat.ag_category_agent_id
       )  
       END ag_category,
       pad.ag_contract_header_id,
       NULL ag_level,
       NULL rl_vol,
       NULL inv_vol,
       NULL ops_vol,
       NULL ops2_vol,
       NULL sofi_vol,
       NULL ksp,
       'Бриф премии' prem_detail,
       'Бриф типа объмов' vol_type,
       pad.ag_contract_header_id agent_ad_id,
       pha.prod_name product,
       pha.policy_header_id,
       'pol_num_ops' pol_num_ops,
       NULL sign_date_ops,
       epg.payment_id epg,
       nvl(pp_pd.payment_id ,epg_pd.payment_id) pay_doc,
       pha.p_cover_id,
       FLOOR(months_between(epg.plan_date,pha.start_date)/12)+1 pay_period,
       round(months_between(pha.end_date,pha.start_date)/12) ins_period,
       NULL nbv_coef,
       t.trans_amount trans_sum,
       NULL index_delta_sum,
       NULL detail_amt,
       NULL detail_rate,
       NULL detail_commis
  FROM (SELECT ph.policy_header_id,
               pp.policy_id,
               pc.p_cover_id,
               ph.start_date,
               pp.end_date,
               prod.description prod_name,
               pc.fee,
               tplo.id,
               ph.fund_id,
               d_ph.doc_status_ref_id,
               pp.payment_term_id,
               prod.product_id,
               d_pp.doc_status_ref_id ref_pp_id
        FROM ins.p_pol_header ph,
             ins.t_product prod,
             ins.document d_ph,
             ins.document d_pp,
             ins.ven_p_policy pp,
             ins.as_asset a,
             ins.p_cover pc,
             ins.t_prod_line_option tplo
       WHERE ph.policy_header_id = pp.pol_header_id
         AND ph.product_id = prod.product_id
         AND ph.product_id NOT IN (43620,43622,43625,45176,45177,45178)
         AND ph.sales_channel_id IN (12, 161, 121)
         AND a.p_policy_id = pp.policy_id
         AND pc.as_asset_id = a.as_asset_id
         AND pc.t_prod_line_option_id = tplo.ID
         AND ph.policy_id = d_pp.document_id
         AND tplo.description NOT IN ('Административные издержки')
         AND ph.last_ver_id = d_ph.document_id
         AND d_ph.doc_status_ref_id NOT IN (21, 10,188, -1, 187, 186, 185, 184,182,183)
         AND (ph.start_date < '26.08.2009'
             OR EXISTS (SELECT NULL
                          FROM ins.p_policy pp1,
                               ins.doc_status ds1
                         WHERE pp1.pol_header_id = ph.policy_header_id
                           AND pp1.policy_id = ds1.document_id
                           AND ds1.doc_status_ref_id IN (91,2,-1)
                           AND ds1.start_date <= TO_DATE((SELECT r.param_value
                                                          FROM ins_dwh.rep_param r
                                                          WHERE r.rep_name = 'cov_det'
                                                          AND r.param_name = 'date_end'
                                                          )
                                                         ,'DD.MM.YYYY'
                                                         )
                        )
             )
       ) pha,
       ins.p_policy_agent_doc pad,
       ins.ag_contract_header agh,
       ins.document d_pad,
       ins.doc_doc pp_dd,
       (SELECT epga.payment_id,
               epga.plan_date,
               epga.amount, 
               epga.rev_amount
        FROM ins.ven_ac_payment epga,
             ins.document d_epga
        WHERE epga.plan_date <= TO_DATE((SELECT r.param_value
                                        FROM ins_dwh.rep_param r
                                        WHERE r.rep_name = 'cov_det'
                                        AND r.param_name = 'date_end'
                                        )
                                       ,'DD.MM.YYYY'
                                       )
                               + 1
          AND epga.doc_templ_id = 4
          AND epga.payment_id = d_epga.document_id
          AND d_epga.doc_status_ref_id != 1
       ) epg,
       ins.doc_set_off epg_dso,
       (SELECT epg_pda.payment_id,
               epg_pda.due_date,
               epg_pda.collection_metod_id,
               epg_pda.payment_templ_id
        FROM ins.ac_payment epg_pda
        WHERE epg_pda.payment_templ_id IN (4983, 6277, 2, 16123, 16125)
       ) epg_pd,
       ins.doc_doc pd_dd,
       ins.ac_payment epg_pd_copy,
       ins.doc_set_off pd_dso,
       ins.oper o,
       (SELECT ta.trans_id,
               ta.oper_id,
               ta.obj_uro_id,
               ta.trans_amount
        FROM ins.trans ta
        WHERE ta.dt_account_id = 122) t,
       ins.ven_ac_payment pp_pd
 WHERE 1=1
   AND CASE WHEN epg_pd.due_date < pha.start_date 
            THEN pha.start_date 
       ELSE (SELECT MAX(acp1.due_date) 
               FROM ins.doc_set_off dso1,
                    ins.ac_payment acp1
              WHERE dso1.parent_doc_id = epg.payment_id
                AND acp1.payment_id = dso1.child_doc_id
                AND acp1.payment_templ_id IN (4983, 6277, 2, 16123, 16125)) 
       END BETWEEN pad.date_begin AND pad.date_end-1/24/3600
   AND pha.policy_header_id = pad.policy_header_id
   AND pad.ag_contract_header_id = agh.ag_contract_header_id
   AND pha.policy_id = pp_dd.parent_id
   AND pp_dd.child_id = epg.payment_id
   AND epg.payment_id = epg_dso.parent_doc_id
   AND epg_dso.child_doc_id = epg_pd.payment_id
   AND epg_pd.payment_id = pd_dd.parent_id (+)
   AND pd_dd.child_id = epg_pd_copy.payment_id (+)
   AND epg_pd_copy.payment_id = pd_dso.parent_doc_id (+)
   AND pd_dso.child_doc_id = pp_pd.payment_id (+)
   AND (o.document_id = pd_dso.doc_set_off_id
       OR o.document_id = epg_dso.doc_set_off_id)
   AND t.oper_id = o.oper_id
   AND pha.p_cover_id = t.obj_uro_id
   AND (pp_pd.payment_templ_id IN (2, 16123, 16125) 
        OR pp_pd.payment_templ_id IS NULL)
   AND pad.p_policy_agent_doc_id = d_pad.document_id
   AND d_pad.doc_status_ref_id != 161
   AND NOT EXISTS (SELECT NULL 
                     FROM ins.ag_volume av
                    WHERE av.trans_id = t.trans_id);
/**/
GRANT SELECT ON v_find_cover_detail TO INS_EUL;
GRANT SELECT ON v_find_cover_detail TO INS_READ;
