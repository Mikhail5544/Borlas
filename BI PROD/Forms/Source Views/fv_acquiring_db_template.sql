create or replace view fv_acquiring_db_template as
SELECT pt.acq_payment_template_id 
      ,dc.num
      ,dc.reg_date
      ,pt.fee
      ,pt.admin_expenses
      ,pt.issuer_name
      ,pt.pol_number
      ,tr.description as payment_terms
      ,dsr.name as status_name
      ,dsr.brief as status_brief
      ,ds.start_date
      ,pt.till
      ,mr.name as mpos_rejection_name
      ,CASE
         WHEN dsr.brief IN ('CANCEL', 'STOPED') THEN
          ds.change_date
       END as stop_cancel_change_date
      ,dsra.name as policy_status_name
      ,pkg_kladr.get_kladr_name_by_id(pkg_policy.get_region_by_pol_header(pt.policy_header_id)) as region_name
      ,pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id) as agent_name
      ,pt.acq_internet_payment_id 
      ,pt.policy_header_id
      ,pt.agreement_flag
      ,pt.ip_address
      ,pt.t_payment_terms_id
      ,pt.t_mpos_rejection_id
      ,pt.policy_start_date
      ,pt.policy_end_date
      ,pt.cell_phone
      ,f.brief currency_brief
      ,dc.note 
      ,pt.prolongation_flag
			,cast(null as varchar2(25)) as postal_address
  FROM acq_payment_template pt
      ,document             dc
      ,t_payment_terms      tr
      ,doc_status           ds
      ,doc_status_ref       dsr
      ,t_mpos_rejection     mr
      ,p_pol_header         ph
      ,doc_status_ref       dsra
      ,fund                 f
 WHERE pt.acq_payment_template_id = dc.document_id
   AND pt.t_payment_terms_id = tr.id(+)
   AND dc.doc_status_id = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND pt.t_mpos_rejection_id = mr.t_mpos_rejection_id(+)
   AND pt.policy_header_id = ph.policy_header_id(+)
   AND pt.current_status_ref_id = dsra.doc_status_ref_id(+)
   AND pt.pay_fund_id = f.fund_id(+)
   /*
   AND ((dsr.brief != 'PROJECT' AND :db_template_ctrl.chb_templ_project = 0) OR
       :db_template_ctrl.chb_templ_project = 1)
   AND dc.reg_date BETWEEN :db_template_ctrl.start_date AND :db_template_ctrl.end_date
   */
   ;
   grant select on fv_acquiring_db_template to ins_read;
