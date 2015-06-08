CREATE OR REPLACE FORCE VIEW V_REPORT_PREMIA_PREM_MENEDG AS
SELECT count(1) over() row_cnt,
agd.AGENT_REPORT_ID, pp.pol_ser || '-' || pp.pol_num pol_num, pi.contact_name strahov_name,
PKG_AGENT_1.get_agent_status_name_by_date(agch.ag_contract_header_id,pp.START_DATE) status_mng,
       ac.SUM_PREMIUM,
       ac.COMISSION_SUM,
       --get_first_pay_date(pp.policy_id) first_pay_date,
       ac.PRM_DATE_PAY first_pay_date,
       pt.DESCRIPTION pay_term,
       pp.NOTICE_DATE,
       ac.SGP,
       tp.DESCRIPTION product,
       vtct.BRIEF,
       c3.date_break,
       nvl(ac.IS_BREAK,0) IS_BREAK,
       plo.DESCRIPTION progr,
       vca.category_name status_name,
         GetManagerByDate(ava.date_end,c2.ag_contract_header_id) as strahov_name_mng,--правил Колганов 12.12.07
       --con2.NAME||' '||con2.FIRST_NAME||' '||con2.MIDDLE_NAME strahov_name_mng,
       decode(nvl(ac.SUM_PREMIUM,0),0,0,  ac.COMISSION_SUM * 100 / ac.SUM_PREMIUM) percent_st_prm,
       decode(CEIL (MONTHS_BETWEEN (NVL (get_first_pay_date(pp.policy_id), SYSDATE), ph.start_date) / 12),0,1,CEIL (MONTHS_BETWEEN (NVL (get_first_pay_date(pp.policy_id), SYSDATE), ph.start_date) / 12)) god,
       decode(CEIL (MONTHS_BETWEEN (NVL (pp.START_DATE, SYSDATE), NVL (c3.date_break, SYSDATE)) / 12),0,1,CEIL (MONTHS_BETWEEN (NVL (pp.START_DATE, SYSDATE), NVL (c3.date_break, SYSDATE)) / 12)) god_dest
FROM ven_p_policy pp
     JOIN ven_t_payment_terms pt ON  (pt.ID = pp.payment_term_id)
     JOIN ven_p_pol_header ph ON (ph.policy_header_id = pp.pol_header_id)
     JOIN ven_t_product tp ON (tp.product_id = ph.product_id)
     JOIN ven_agent_report_dav_ct ac ON (ac.policy_id = pp.policy_id)
     JOIN ven_agent_report_dav agd ON (agd.agent_report_dav_id = ac.agent_report_dav_id)
     JOIN ven_agent_report agr ON (agr.agent_report_id = agd.agent_report_id)
     join ven_ag_vedom_av ava on (ava.ag_vedom_av_id = agr.ag_vedom_av_id)--правил Колганов 12.12.07
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
     WHERE agd.agent_report_id = PKG_REP_UTILS2.iGetVal('P_AG_REP_ID') 
     and vtct.BRIEF = 'PREM_MENEDG'
;

