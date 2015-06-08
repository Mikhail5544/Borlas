CREATE OR REPLACE VIEW V_MPOS_PAYMENT_NOT_PAYED AS
SELECT
/*
Неуспешные списания mPos (для отчета Дискаверер)
Черных М. 26.09.2014
*/

 pph.ids
,pi.contact_name
,pkg_policy.get_pol_sales_chn(pph.policy_header_id,'descr') as "Sales Chn"
,wf.amount
,pkg_agn_control.get_current_policy_agent_name(wf.policy_header_id) agent_name /*Действующий агент*/
,(SELECT t.name
    FROM t_kladr t
   WHERE t.t_kladr_id = pkg_policy.get_region_by_pol_header(wf.policy_header_id)) region_name /*Регион*/
,ws.start_date
,ws.end_date
  FROM ven_mpos_writeoff_sch ws
      ,doc_status_ref        dsr
      ,mpos_writeoff_form    wf
      ,p_pol_header          pph
      ,v_pol_issuer          pi
 WHERE ws.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief = 'NOT_WRITEDOFF' /*Не списано*/
   AND ws.mpos_writeoff_form_id = wf.mpos_writeoff_form_id
   AND wf.policy_header_id = pph.policy_header_id
   AND pph.policy_id = pi.policy_id;