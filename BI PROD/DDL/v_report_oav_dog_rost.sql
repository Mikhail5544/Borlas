CREATE OR REPLACE FORCE VIEW V_REPORT_OAV_DOG_ROST AS
SELECT count(1) over() rost_row_cnt,
ac.agent_report_id, pp.pol_ser || '-' || pp.pol_num pol_num,
       pi.contact_name strahov_name, plo.description progr,
       ac.PART_AGENT,       
       decode(CEIL (MONTHS_BETWEEN (NVL (ac.date_pay, SYSDATE), ph.start_date) / 12),0,1,CEIL (MONTHS_BETWEEN (NVL (ac.date_pay, SYSDATE), ph.start_date) / 12)) god,
       ac.comission_sum, ac.sum_return, 
       decode(vca.category_name,'Агент',agent_status.status_name,'CAB2') status_name
  FROM ven_agent_report_cont ac 
       JOIN ven_trans tr ON (tr.trans_id =  ac.trans_id)
       JOIN oper o ON (o.oper_id = tr.oper_id)
       JOIN doc_set_off dso ON (dso.doc_set_off_id = o.document_id )
       JOIN ven_ac_payment ap ON (ap.payment_id = dso.child_doc_id)
       JOIN ven_p_policy pp ON (pp.policy_id = ac.policy_id)
       JOIN ven_p_pol_header ph ON (ph.policy_id = ac.policy_id)
       JOIN ven_t_product tp ON (tp.product_id = ph.product_id)
       JOIN ven_as_asset ass ON (ass.p_policy_id = ph.policy_id)
       JOIN ven_p_cover pc ON (pc.as_asset_id = ass.as_asset_id)
       JOIN ven_t_prod_line_option plo ON (plo.ID = pc.t_prod_line_option_id)
       JOIN v_pol_issuer pi ON (pi.policy_id = ac.policy_id)
     JOIN ven_agent_report agr ON (agr.AGENT_REPORT_ID = ac.AGENT_REPORT_ID )
     LEFT OUTER JOIN ven_ag_category_agent vca 
          ON (vca.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agr.ag_contract_h_id, pp.NOTICE_DATE ) )
       LEFT JOIN
      (SELECT CASE sa.brief
                  WHEN 'Совмест' THEN 'CAB1'
                  WHEN 'Конс' THEN 'CAB1' 
                  WHEN 'ФинКонс' THEN 'CAB2'
                  WHEN 'ВедКонс' THEN 'CAB3'
                  WHEN 'ФинСов' THEN 'CAB4'
                  ELSE 'CAB2'
               END status_name,       
               sh.ag_stat_hist_id
          FROM ven_ag_stat_hist sh,
               ven_ag_category_agent ac,
               ven_ag_stat_agent sa
         WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
           AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
           AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)) agent_status
       ON (agent_status.ag_stat_hist_id =
              pkg_agent_1.get_agent_status_by_date(agr.ag_contract_h_id,pp.NOTICE_DATE)
          )
 WHERE NVL (ac.sum_return, 0) <> 0 and ac.agent_report_id = PKG_REP_UTILS2.iGetVal('P_AG_REP_ID');

