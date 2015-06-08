CREATE OR REPLACE FORCE VIEW V_REPORT_PREMIA_GR_MNG_0 AS
SELECT 
         GetManagerByDate(ava.date_end,c2.ag_contract_header_id) as strahov_name
FROM ven_p_policy pp
     JOIN ven_t_payment_terms pt ON  (pt.ID = pp.payment_term_id)
     JOIN ven_p_pol_header ph ON (ph.policy_header_id = pp.pol_header_id)
     JOIN ven_t_product tp ON (tp.product_id = ph.product_id)
     JOIN ven_agent_report_dav_ct ac ON (ac.policy_id = pp.policy_id)
     JOIN ven_agent_report_dav agd ON (agd.agent_report_dav_id = ac.agent_report_dav_id)
     JOIN ven_agent_report agr ON (agr.agent_report_id = agd.agent_report_id)
     join ven_ag_vedom_av ava on (ava.ag_vedom_av_id = agr.ag_vedom_av_id)
     JOIN V_T_PROD_COEF_TYPE vtct ON (vtct.T_PROD_COEF_TYPE_ID = agd.PROD_COEF_TYPE_ID)
     JOIN v_pol_issuer pi ON (pi.policy_id = ac.policy_id)
     join ven_ag_contract_header c2 ON (nvl(ac.child_ag_ch_id,ac.RECR_AG_CH_ID) = c2.ag_contract_header_id)
     join ven_contact con2 on (c2.agent_id = con2.contact_id)
     LEFT OUTER JOIN P_POLICY_AGENT_COM pac ON (ac.p_policy_agent_com_id =pac.p_policy_agent_com_id)
     LEFT OUTER JOIN ven_t_prod_line_option plo ON (pac.t_product_line_id=plo.product_line_id)
     JOIN ven_ag_contract_header agch  ON (agch.ag_contract_header_id = agr.AG_CONTRACT_H_ID)
     LEFT OUTER JOIN ven_ag_category_agent vca
      ON (vca.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agch.AG_CONTRACT_HEADER_ID, ph.START_DATE ) )
     LEFT OUTER JOIN ven_ag_contract_header c3 ON (agr.AG_CONTRACT_H_ID = c3.ag_contract_header_id and doc.get_doc_status_brief(c3.ag_contract_header_id,c3.date_break)='BREAK')
  WHERE agd.agent_report_id =  PKG_REP_UTILS2.iGetVal('P_AG_REP_ID') and
  not exists (select 1 from dual where pkg_agent_sub.GetIdManagerByDate(ava.date_end,c2.ag_contract_header_id) = agr.AG_CONTRACT_H_ID)
     and vtct.BRIEF = 'опл'
     and nvl(ac.IS_BREAK,0) = 0
group by GetManagerByDate(ava.date_end,c2.ag_contract_header_id);

