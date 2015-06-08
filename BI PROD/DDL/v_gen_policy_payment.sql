create or replace force view v_gen_policy_payment as
select gp.gen_policy_id,
       gp.gen_policy_id document_id,
       gp.num,
       gp.payment_term_id,
       pt.description payment_term_desc,
       pt.collection_method_id,
       cm.description collection_method_desc,
       pt.number_of_payments,
       gp.first_pay_date,
       gp.fund_id,
       f.brief fund_brief,
       gp.fund_pay_id,
       fp.brief fund_pay_brief,
       sum(pp.premium_amount) premium_amount,
       sum(pp.plan_amount) plan_amount,
       sum(pp.calc_amount) calc_amount,
       sum(pp.to_pay_amount) to_pay_amount,
       sum(pp.pay_amount) pay_amount,
       sum(pp.ret_amount) ret_amount,
       sum(pp.plan_ret_amount) plan_ret_amount,
       sum(pp.calc_ret_amount) calc_ret_amount,
       sum(pp.to_pay_ret_amount) to_pay_ret_amount,
       sum(pp.ret_pay_amount) ret_pay_amount
from   ven_gen_policy gp,
       t_payment_terms pt,
       t_collection_method cm,
       doc_doc dd,
       v_policy_payment pp,
       fund f,
       fund fp
where  gp.payment_term_id = pt.id and
       pt.collection_method_id = cm.id and
       gp.gen_policy_id = dd.parent_id and
       dd.child_id = pp.document_id and
       gp.fund_id = f.fund_id and
       gp.fund_pay_id = fp.fund_id
group  by gp.gen_policy_id,
       gp.num,
       gp.payment_term_id,
       pt.description,
       pt.collection_method_id,
       cm.description,
       pt.number_of_payments,
       gp.first_pay_date,
       gp.fund_id,
       f.brief,
       gp.fund_pay_id,
       fp.brief;

