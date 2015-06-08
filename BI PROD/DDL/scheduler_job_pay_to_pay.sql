DECLARE

v_count PLS_INTEGER;

v_f_count PLS_INTEGER:=0;

BEGIN

dbms_output.DISABLE;

FOR r IN (

SELECT acp.amount, acp.payment_id, COUNT(acp.payment_id) OVER (PARTITION BY 1) cntm

  FROM p_policy pp,

       p_pol_header ph,

       doc_doc dd,

       ven_ac_payment acp,

       doc_templ acpt

WHERE ph.policy_header_id = pp.pol_header_id

   AND pp.policy_id = dd.parent_id

   AND dd.child_id = acp.payment_id

   AND acp.doc_templ_id = acpt.doc_templ_id

   AND acpt.brief = 'PAYMENT'

   AND doc.get_doc_status_brief(acp.payment_id) = 'NEW'

   AND acp.plan_date <= SYSDATE

   AND doc.get_doc_status_brief(pp.policy_id)<>'PROJECT'

   AND doc.get_doc_status_brief(ph.policy_id) not in ('BREAK','CANCEL')
   AND pkg_policy.get_last_version_status(ph.policy_header_id) NOT IN ('Готовится к расторжению')
   /*AND NOT EXISTS (SELECT 1

                     FROM p_policy pp1

                    WHERE pp1.pol_header_id = ph.policy_header_id

                      AND doc.get_doc_status_brief(pp1.policy_id)='READY_TO_CANCEL')*/
  --AND ph.policy_header_id = 12625338                

   --and rownum=1

 

) LOOP

v_count:=r.cnt;

BEGIN

SAVEPOINT before_set;

doc.set_doc_status(p_doc_id => r.payment_id,

                   p_status_brief =>  'TO_PAY',

                   p_note => 'Автоматический перевод ЭПГ к оплате');

 

COMMIT;

EXCEPTION

WHEN OTHERS THEN

v_f_count:=v_f_count+1;

ROLLBACK TO SAVEPOINT before_set;

END;

END LOOP;

pkg_renlife_utils.tmp_log_writer('TP Перевод ЭПГ завершен всего ЭПГ: '||v_count||' не удалось перевести: '||v_f_count);

END;
