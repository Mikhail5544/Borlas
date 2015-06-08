CREATE OR REPLACE FORCE VIEW V_POLICY_PAYMENT AS
SELECT dph.document_id,
       dph.num,
       pt.collection_method_id,
       cm.description collection_method_desc,
       p.payment_term_id,
       pt.description payment_term_desc,
       pt.number_of_payments,
       p.first_pay_date,
       ph.fund_id,
       f.brief fund_brief,
       ph.fund_pay_id,
       fp.brief fund_pay_brief,
       Pkg_Payment.get_last_premium_amount(ph.policy_header_id) premium_amount,
       Pkg_Payment.get_plan_amount(ph.policy_header_id) plan_amount,
       Pkg_Payment.get_calc_amount(ph.policy_header_id) calc_amount,
       Pkg_Payment.get_to_pay_amount(ph.policy_header_id) to_pay_amount,
       Pkg_Payment.get_pay_pol_header_amount_pfa(TO_DATE('01.01.1900','DD.MM.YYYY'), TO_DATE('01.01.3000','DD.MM.YYYY'), ph.policy_header_id) pay_amount,
       Pkg_Payment.get_last_ret_amount(ph.policy_header_id) ret_amount,
       Pkg_Payment.get_plan_ret_amount(ph.policy_header_id) plan_ret_amount,
       Pkg_Payment.get_calc_ret_amount(ph.policy_header_id) calc_ret_amount,
       Pkg_Payment.get_to_pay_ret_amount(ph.policy_header_id) to_pay_ret_amount,
       Pkg_Payment.get_ret_pay_pol_header_pfa(TO_DATE('01.01.1900','DD.MM.YYYY'), TO_DATE('01.01.3000','DD.MM.YYYY'), ph.policy_header_id) ret_pay_amount,
       0 adv_amount,
       0 adv_off_amount,
       p.policy_id,
       p.paymentoff_term_id,
       pto.description paymentoff_term_desc,
       pto.collection_method_id collectionoff_method_id,
       cmo.description collectionoff_method_desc,
       pto.number_of_payments numberoff_of_payments,
       p.decline_date decline_date,
     ph.policy_header_id
  FROM document            dph,
       p_pol_header        ph,
       p_policy            p,
       fund                f,
       fund                fp,
       t_payment_terms     pt,
       t_collection_method cm,
       t_payment_terms     pto,
       t_collection_method cmo
 WHERE dph.document_id = ph.policy_header_id
   AND ph.policy_id = p.policy_id
   AND ph.fund_id = f.fund_id
   AND ph.fund_pay_id = fp.fund_id
   AND p.payment_term_id = pt.id
   --AND pt.collection_method_id = cm.id
   AND p.collection_method_id = cm.id
   AND p.paymentoff_term_id = pto.id(+)
   AND pto.collection_method_id = cmo.id(+);
