create or replace view ins_dwh.v_reserves_vs_profit_lstpol as
SELECT /*+ INDEX(ds PK_DOC_STATUS)*/
 pp.policy_id
,pp.pol_header_id
,pp.decline_date
,pp.decline_reason_id
,tdr.name             AS decline_reason_name
,dsr.name             AS status_name
,ds.start_date        AS status_start_date
  FROM ins.p_policy         pp
      ,ins.t_decline_reason tdr
      ,ins.document         dc
      ,ins.doc_status       ds
      ,ins.doc_status_ref   dsr
      ,ins.p_pol_header     ph
      ,ins.t_product        pr
 WHERE pp.decline_reason_id = tdr.t_decline_reason_id(+)
   AND pp.policy_id = dc.document_id
   AND dc.doc_status_id = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ph.last_ver_id = pp.policy_id
   AND ph.product_id = pr.product_id;
