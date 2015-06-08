CREATE OR REPLACE FUNCTION get_first_pay_date(p_policy_id NUMBER) RETURN DATE AS
  pay_date DATE;
  BEGIN

    for cur in ( SELECT cp.due_date
    FROM DOCUMENT d, DOC_TEMPL dt, DOC_DOC dd, P_POLICY p, DOC_STATUS ds, DOC_STATUS_REF dsr, doc_set_off dso, document cd, ac_payment cp
    WHERE d.doc_templ_id = dt.doc_templ_id
    AND dt.brief = 'PAYMENT'
    AND dd.child_id = d.document_id
    AND dd.parent_id = p.policy_id
    AND ds.document_id = d.document_id
    AND  ds.start_date = (SELECT MAX(dss.start_date) FROM DOC_STATUS dss WHERE  dss.document_id = d.document_id)
    AND dsr.doc_status_ref_id = ds.doc_status_ref_id
    and dso.parent_doc_id = d.document_id
    and dso.child_doc_id = cd.document_id
    and cd.document_id = cp.payment_id
    and policy_id = p_policy_id 
    order by cp.due_date asc) loop
      pay_date := cur.due_date;
      exit;
    end loop;

   RETURN pay_date;
   EXCEPTION WHEN OTHERS THEN RETURN NULL;
  END;
/

