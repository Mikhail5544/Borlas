create or replace force view v_slip_payment as
select ds.document_id,
       ds.num,
       pt.collection_method_id,
       cm.description collection_method_desc,
       rs.payment_term_id,
       pt.description payment_term_desc,
       pt.number_of_payments,
       rs.first_pay_date,
       rsh.fund_id,
       f.brief fund_brief,
       rsh.fund_pay_id,
       fp.brief fund_pay_brief,
       rs.re_slip_id--,
      -- pkg_payment.get_last_premium_amount(ph.policy_header_id) premium_amount,
   --    pkg_payment.get_plan_amount(ph.policy_header_id) Plan_Amount,
  /*     (
         select nvl(sum(t.acc_amount),0)
         from   Trans t, Trans_Templ tt, p_policy tp
         where  t.trans_templ_id = tt.trans_templ_id and 
                tt.brief in ('«ач¬знос—трах', '«ач¬зносјг', '”держ ¬') and
                t.a2_ct_uro_id = tp.policy_id and
                tp.pol_header_id = ph.policy_header_id
       ) pay_amount,
       pkg_payment.get_last_ret_amount(ph.policy_header_id) ret_amount,
       pkg_payment.get_plan_ret_amount(ph.policy_header_id) plan_ret_amount,
       (
         select nvl(sum(t.acc_amount),0)
         from   Trans t, Trans_Templ tt, p_policy tp
         where  t.trans_templ_id = tt.trans_templ_id and 
                tt.brief in ('«ачт¬ыпл¬озвр') and
                t.a2_dt_uro_id = tp.policy_id and
                tp.pol_header_id = ph.policy_header_id
       ) ret_pay_amount,
       0 adv_amount,
       0 adv_off_amount,

       p.paymentoff_term_id*/

  from document            ds,
       re_slip_header      rsh,
       re_slip             rs,
       fund                f,
       fund                fp,
       t_payment_terms     pt,
       t_collection_method cm
 where ds.document_id = rs.re_slip_id
   and rsh.re_slip_header_id = rs.re_slip_header_id
   and rsh.fund_id = f.fund_id
   and rsh.fund_pay_id = fp.fund_id
   and rs.payment_term_id = pt.id
   and pt.collection_method_id = cm.id
;

