create or replace force view v_claim_payment as
select
  dch.document_id,
  dch.num,
  ch.fund_id fund_id,
  f.brief fund_brief,
  ch.fund_pay_id fund_pay_id,
  fp.brief fund_brief_pay,
  pkg_claim_payment.get_claim_payment_sum(c.c_claim_id) payment_sum,
  pkg_claim_payment.get_claim_charge_sum(c.c_claim_id) charge_sum,
  pkg_claim_payment.get_claim_plan_sum(c.c_claim_id) Plan_Amount,
  pkg_claim_payment.get_claim_topay_sum(c.c_claim_id) Topay_Amount,
  pkg_claim_payment.get_claim_pay_sum(c.c_claim_id) Pay_amount,
  ch.payment_term_id payment_term_id,
  cm.description col_name,
  pt.description term_name,
  pt.number_of_payments nums,
  c.c_claim_id,
  ch.first_payment_date,
  rod.t_rate_on_date_id,
  rod.name rate_on_date,
  rod.brief rate_on_date_brief
from
  document dch,
  ven_c_claim_header ch,
  ven_t_payment_terms      pt,
  ven_t_collection_method  cm,
  fund f,
  fund fp,
  ven_c_claim c,
  t_rate_on_date rod
where
  dch.document_id = ch.c_claim_header_id and
  ch.fund_id = f.fund_id and
  ch.fund_pay_id = fp.fund_id(+) and
  ch.payment_term_id = pt.id and
  pt.collection_method_id = cm.id and
  ch.rate_on_date_id = rod.t_rate_on_date_id(+) and
  c.c_claim_header_id = ch.c_claim_header_id
  --and doc.get_doc_status_brief(c.c_claim_id, GREATEST(SYSDATE, claim_status_date)) in ('CLOSE','REGULATE','CLAIM_IN_REGULATE','FOR_PAY')
;

