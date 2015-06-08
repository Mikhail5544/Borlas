create or replace force view v_report_prem_mened_bonus as
select distinct nvl(davct.bonus_all,0) bonus_all, nvl(davct.bonus_new,0) bonus_new
  from ven_agent_report_dav agdav
       JOIN V_T_PROD_COEF_TYPE vtct ON (vtct.T_PROD_COEF_TYPE_ID = agdav.PROD_COEF_TYPE_ID and vtct.BRIEF = 'PREM_MENEDG')
       JOIN ven_agent_report_dav_ct davct  ON (davct.agent_report_dav_id = agdav.agent_report_dav_id)
 where agent_report_id = PKG_REP_UTILS2.iGetVal('P_AG_REP_ID') and rownum=1;

