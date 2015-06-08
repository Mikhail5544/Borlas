create or replace view V_MPOS_WRITEOFF_FORM
as
SELECT wc.mpos_writeoff_form_id
      ,wc.transaction_date
      ,wc.amount
      ,wc.insured_name
      ,wc.description
      ,wc.policy_number
      ,ps.name AS payment_system_name
      ,pt.description AS payment_terms_name
      ,dsrc.name AS mpos_writeoff_form
      ,dsc.start_date AS status_start_date
      ,wc.transaction_id
      ,mr.name AS rejection_name
      ,CASE
         WHEN dsrc.brief IN ('CANCEL', 'CANCEL_NOT_SENT', 'STOPED', 'STOPED_NOT_SENT') THEN
          dsc.start_date
       END AS rejection_date
      ,wc.cliche
      ,wc.device_id
      ,wc.device_name
      ,wc.device_model
      ,wc.ids_for_recognition
      ,ph.start_date AS policy_start_date
      ,dsr.name AS las_ver_status_name
      ,mp.name AS payment_status_name
      ,wc.rrn
      ,wc.card_number
      ,kl.name AS region_name
      ,pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id) AS agent_name
      ,dcc.reg_date
      ,dsrc.brief
      ,wc.t_payment_terms_id
      ,wc.t_mpos_payment_status_id
      ,wc.terminal_bank_id
      ,wc.t_payment_system_id
      ,wc.product_name
      ,wc.policy_header_id
      ,wc.fund_id
      ,wc.ins_premium
      ,wc.t_mpos_rejection_id
      ,wc.g_mpos_id
  FROM mpos_writeoff_form    wc
      ,p_pol_header          ph
      ,p_policy              pp
      ,t_kladr               kl
      ,document              dc
      ,doc_status_ref        dsr
      ,t_payment_terms       pt
      ,t_payment_system      ps
      ,document              dcc
      ,doc_status            dsc
      ,doc_status_ref        dsrc
      ,t_mpos_rejection      mr
      ,t_mpos_payment_status mp
 WHERE wc.policy_header_id = ph.policy_header_id(+)
   AND ph.last_ver_id = pp.policy_id(+)
   AND pp.region_id = kl.t_kladr_id(+)
   AND pp.policy_id = dc.document_id(+)
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id(+)
   AND wc.t_payment_terms_id = pt.id
   AND wc.t_payment_system_id = ps.t_payment_system_id
   AND wc.mpos_writeoff_form_id = dcc.document_id
   AND wc.t_mpos_rejection_id = mr.t_mpos_rejection_id(+)
   AND dcc.doc_status_id = dsc.doc_status_id
   AND dsc.doc_status_ref_id = dsrc.doc_status_ref_id
   AND wc.t_mpos_payment_status_id = mp.t_mpos_payment_status_id;

grant
  SELECT ON v_mpos_operations TO ins_read;
