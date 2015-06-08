create or replace view fv_pol_decline_payreq as
SELECT ap.reg_date
      ,ap.num
      ,ap.amount
      ,dd.parent_id as policy_id
      ,ap.payment_id
      ,ap.contact_id
      ,(SELECT obj_name_orig FROM contact c WHERE c.contact_id = ap.contact_id) AS beneficiary_name
  FROM ven_ac_payment   ap
      ,doc_doc          dd
      ,ac_payment_templ apt
      ,doc_templ        dt
 WHERE ap.payment_id = dd.child_id
   AND ap.payment_templ_id = apt.payment_templ_id
   AND apt.brief = 'PAYREQ'
   AND ap.doc_templ_id = dt.doc_templ_id
   AND dt.brief = 'PAYREQ';
	 
grant select on fv_pol_decline_payreq to ins_read;
