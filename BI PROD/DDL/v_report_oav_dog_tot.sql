CREATE OR REPLACE FORCE VIEW V_REPORT_OAV_DOG_TOT AS
SELECT count(1) over() row_cnt_tot,
ac.AGENT_REPORT_ID, pp.pol_ser || '-' || pp.pol_num pol_num, pi.contact_name strahov_name,
       plo.description progr,ac.sav stavka,
       decode(CEIL (MONTHS_BETWEEN (NVL (ac.date_pay, SYSDATE), ph.start_date) / 12),0,1,CEIL (MONTHS_BETWEEN (NVL (ac.date_pay, SYSDATE), ph.start_date) / 12)) god,
       drd.reg_date date_pay, nvl(ac.sum_premium,0) sum_premium, nvl(ac.comission_sum,0) comission_sum, ac.PART_AGENT,
       decode(vca.category_name,'Агент',agent_status.status_name,'CAB2') status_name
FROM ven_p_policy pp
     JOIN ven_p_pol_header ph ON (ph.policy_header_id = pp.pol_header_id)
     JOIN ven_t_product tp ON (tp.product_id = ph.product_id)
     JOIN ven_agent_report_cont ac ON (ac.policy_id = pp.policy_id)
     JOIN v_pol_issuer pi ON (pi.policy_id = ac.policy_id)
     JOIN ven_trans tr ON (tr.trans_id = ac.trans_id AND tr.a2_ct_uro_id = pp.policy_id)
     JOIN oper o ON (o.oper_id = tr.oper_id)
     JOIN doc_set_off dso ON (dso.doc_set_off_id = o.document_id)
     join document drd on (dso.child_doc_id = drd.document_id)--правил Колганов 10.12.2007
     JOIN ven_ac_payment ap ON (ap.payment_id = dso.child_doc_id)
     JOIN ven_t_prod_line_option plo ON (plo.ID = tr.a4_ct_uro_id)
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
     WHERE ac.agent_report_id = PKG_REP_UTILS2.iGetVal('P_AG_REP_ID')
;

