create or replace force view v_policy_payment_order as
select
    row_number() over(partition by pol_header_id order by a.due_date) payment_number
  , pp.pol_header_id
  , ph.start_date
  , a.payment_id
  , pp.policy_id
  , a.due_date
  from
    document d
  , ac_payment a
  , doc_templ dt
  , doc_doc dd
  , p_pol_header ph
  , p_policy pp
  where 1=1
    and ph.policy_header_id = pp.pol_header_id
    and dd.parent_id = pp.policy_id
    and d.document_id = dd.child_id
    and a.payment_id = d.document_id 
    and d.doc_templ_id = dt.doc_templ_id
    and dt.brief = 'PAYMENT';

