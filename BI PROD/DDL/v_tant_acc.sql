create or replace force view v_tant_acc as
select ts.RE_TANT_SCORE_ID
     , ap.payment_id
     , ap.NUM
     , dt.NAME
     , ap.AMOUNT
     , pkg_reins_payment.get_tant_set_off(ap.payment_id) doc_set_off
     , doc.get_doc_status_name(ap.payment_id) status
from re_tant_score ts
   , doc_doc dd
   , ven_ac_payment ap
   , doc_templ dt
where dd.parent_id = ts.RE_TANT_SCORE_ID
  and ap.PAYMENT_ID = dd.child_id
  and dt.doc_templ_id = ap.DOC_TEMPL_ID
  and upper(dt.BRIEF) = 'ACCPAYTANT'
  and ap.PAYMENT_NUMBER = 1;

