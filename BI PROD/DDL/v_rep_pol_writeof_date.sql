CREATE OR REPLACE VIEW ins.v_rep_pol_writeof_date AS

SELECT h.policy_header_id
      ,coalesce((SELECT s.start_date
                  FROM ins.acq_payment_template a
                      ,ins.document             d
                      ,ins.doc_status_ref       r
                      ,ins.doc_status           s
                 WHERE a.policy_header_id = h.policy_header_id
                   AND d.document_id = a.acq_payment_template_id
                   AND r.doc_status_ref_id = d.doc_status_ref_id
                   AND s.doc_status_id = d.doc_status_id
                   AND r.brief = 'CONFIRMED')
                
               ,(SELECT s.start_date
                  FROM ins.mpos_writeoff_form m
                      ,ins.document           d
                      ,ins.doc_status_ref     r
                      ,ins.doc_status         s
                 WHERE m.policy_header_id = h.policy_header_id
                   AND d.document_id = m.mpos_writeoff_form_id
                   AND r.doc_status_ref_id = d.doc_status_ref_id
                   AND s.doc_status_id = d.doc_status_id
                   AND r.brief IN ('CONFIRMED', 'CONFIRMED_NOT_SENT'))
                
               ,(SELECT s.start_date
                  FROM ins.dwo_notice        dn
                      ,ins.document          d
                      ,ins.doc_status_ref    r
                      ,ins.doc_status        s
                      ,ins.t_dwo_notice_type dnt
                 WHERE dn.policy_header_id = h.policy_header_id
                   AND d.document_id = dn.dwo_notice_id
                   AND r.doc_status_ref_id = d.doc_status_ref_id
                   AND s.doc_status_id = d.doc_status_id
                   AND dnt.t_dwo_notice_type_id = dn.notice_type_id
                   AND r.brief IN ('RECEIVED', 'REFINE_DETAILS')
                   AND dnt.brief = 'WRITEOFF')) writeof_date

  FROM ins.p_pol_header h
 --WHERE h.policy_header_id = 121553819
