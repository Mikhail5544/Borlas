create or replace force view v_agent_payment as
select
  dch.document_id,
  dch.num,
  f.fund_id fund_id,
  f.brief fund_brief,
  fp.fund_id fund_pay_id,
  fp.brief fund_brief_pay,
  (
    select nvl(sum(arc.comission_sum), 0)
    from   agent_report_cont arc
    where  arc.agent_report_id = ar.agent_report_id
  ) payment_sum,
  0 calc_amount,
  0 hold_amount,
  0 Plan_Amount,
  0 to_Pay_amount,
  0 Pay_amount,
  pt.id payment_term_id,
  cm.description col_name,
  pt.description term_name,
  pt.number_of_payments nums,
  ar.report_date first_payment_date
from
  document dch,
  ven_agent_report ar,
  ven_t_payment_terms pt,
  ven_t_collection_method cm,
  fund f,
  fund fp
where
  dch.document_id = ar.agent_report_id and
  f.brief = 'RUR' and
  fp.brief = 'RUR' and
  pt.collection_method_id = cm.id and
  pt.description = 'Единовременно' and
  cm.description = 'Наличный расчет';

