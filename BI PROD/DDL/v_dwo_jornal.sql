CREATE OR REPLACE VIEW v_dwo_jornal AS
SELECT ph.ids
      ,pi.contact_name
      ,dn.dwo_notice_id
      ,dsrn.name
      ,dsn.start_date
      ,wf.mpos_status
      ,wf.mpos_writeoff_form_id
      ,wf.mpos_start_date
      ,pt.acq_payment_template_id
      ,pt.acq_start_date
  FROM dwo_notice dn
      ,document dcn
      ,doc_status dsn
      ,doc_status_ref dsrn
      ,(SELECT wf.mpos_writeoff_form_id
              ,wf.policy_header_id
              ,dsw.start_date mpos_start_date
              ,dsrw.name mpos_status
              ,dsrw.doc_status_ref_id 
          FROM mpos_writeoff_form wf
              ,document           dcw
              ,doc_status         dsw
              ,doc_status_ref     dsrw
         WHERE wf.mpos_writeoff_form_id = dcw.document_id
           AND dcw.doc_status_id = dsw.doc_status_id
           AND dsw.doc_status_ref_id = dsrw.doc_status_ref_id
           AND dsrw.brief IN ('CONFIRMED', '')) wf
       
      ,(SELECT pt.policy_header_id
              ,pt.acq_payment_template_id
              ,dsp.start_date acq_start_date
              ,dsrp.doc_status_ref_id
          FROM acq_payment_template pt
              ,document             dcp
              ,doc_status           dsp
              ,doc_status_ref       dsrp
         WHERE pt.acq_payment_template_id = dcp.document_id
           AND dcp.doc_status_id = dsp.doc_status_id
           AND dsp.doc_status_ref_id = dsrp.doc_status_ref_id
           AND dsrp.brief = 'CONFIRMED') pt
      ,p_pol_header ph
      ,v_pol_issuer pi
 WHERE dn.dwo_notice_id = dcn.document_id
   AND dcn.doc_status_id = dsn.doc_status_id
   AND dsn.doc_status_ref_id = dsrn.doc_status_ref_id
      
   AND dn.policy_header_id = wf.policy_header_id(+)
      
   AND dn.policy_header_id = pt.policy_header_id(+)
      
   AND (wf.doc_status_ref_id IS NOT NULL OR pt.doc_status_ref_id IS NOT NULL)
      
   AND dn.policy_header_id = ph.policy_header_id
   AND ph.policy_id = pi.policy_id;
