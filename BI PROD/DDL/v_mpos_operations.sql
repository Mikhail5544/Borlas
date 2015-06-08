create or replace view v_mpos_operations
as
SELECT pn.mpos_payment_notice_id AS obj_id
      ,'MPOS_PAYMENT_NOTICE' AS ent_brief
      ,pn.transaction_id
      ,pn.amount
      ,pn.transaction_date
      ,pn.description
      ,pn.rrn
      ,sy.t_payment_system_id
      ,sy.name AS payment_system
      ,pn.card_number
      ,pn.device_id
      ,pn.insured_name
      ,pn.policy_number
      ,(SELECT dp.name
          FROM p_pol_header       ph
              ,ag_contract_header ch
              ,ag_contract        ac
              ,department         dp
         WHERE to_char(ph.ids) = pn.policy_number
           AND ch.ag_contract_header_id = pkg_agn_control.get_current_policy_agent(ph.policy_header_id)
           AND ch.last_ver_id = ac.ag_contract_id
           AND ac.agency_id = dp.department_id
           AND rownum = 1) AS region_name
  FROM mpos_payment_notice   pn
      ,document              dc
      ,doc_status_ref        dsr
      ,t_mpos_payment_status ps
      ,t_payment_system      sy
 WHERE pn.mpos_payment_notice_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief = 'NEW'
   AND pn.t_mpos_payment_status_id = ps.t_mpos_payment_status_id
   AND ps.brief = 'COMPLETED'
   AND pn.t_payment_system_id = sy.t_payment_system_id
UNION ALL
SELECT wn.mpos_writeoff_notice_id AS obj_id
      ,'MPOS_WRITEOFF_NOTICE' AS ent_brief
      ,wn.transaction_id
      ,wn.amount
      ,wn.transaction_date
      ,wn.description
      ,wn.rrn
      ,sy.t_payment_system_id
      ,sy.name AS payment_system
      ,wn.card_number
      ,wn.device_id
      ,wf.insured_name
      ,wf.policy_number
      ,(SELECT dp.name
          FROM ag_contract_header ch
              ,ag_contract        ac
              ,department         dp
         WHERE ch.ag_contract_header_id = pkg_agn_control.get_current_policy_agent(wf.policy_header_id)
           AND ch.last_ver_id = ac.ag_contract_id
           AND ac.agency_id = dp.department_id
           AND rownum = 1) AS region_name
  FROM mpos_writeoff_notice wn
      ,document             dc
      ,doc_status_ref       dsr
      ,mpos_writeoff_form   wf
      ,t_payment_system     sy
 WHERE wn.mpos_writeoff_notice_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief = 'NEW'
   AND wn.mpos_writeoff_form_id = wf.mpos_writeoff_form_id
   AND wn.t_payment_system_id = sy.t_payment_system_id;

grant select on v_mpos_operations to INS_READ;
