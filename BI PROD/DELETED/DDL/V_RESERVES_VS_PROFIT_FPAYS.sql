create or replace view ins_dwh.v_reserves_vs_profit_fpays
as
  SELECT min(ap.plan_date) as fist_to_pay_date
        ,ph.policy_header_id
    FROM ins.p_policy       pp
        ,ins.doc_doc        dd
        ,ins.ac_payment     ap
         ,(select /*+ NO_MERGE */
                  d.document_id
             from ins.document       d
                 ,ins.doc_status_ref dsr
                 ,ins.doc_templ      dt
            where d.doc_status_ref_id = dsr.doc_status_ref_id
              AND d.doc_templ_id      = dt.doc_templ_id
              AND dt.brief            = 'PAYMENT'
              AND dsr.brief           = 'TO_PAY'
          ) ch
         ,ins.p_pol_header ph
         ,ins.t_product pr
   WHERE pp.policy_id = dd.parent_id
     and dd.child_id  = ap.payment_id
     and dd.child_id  = ch.document_id
     and ins.pkg_payment.get_set_off_amount(ap.payment_id, ph.policy_header_id,NULL) = 0
     AND ph.policy_header_id = pp.pol_header_id
     AND ph.product_id = pr.product_id
     AND ((ins_dwh.pkg_reserves_vs_profit.get_mode = 0
           and pr.brief not in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
           and pp.is_group_flag = 0
          )or
          (ins_dwh.pkg_reserves_vs_profit.get_mode = 1
           and pr.brief in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
          )or
          (ins_dwh.pkg_reserves_vs_profit.get_mode = 2
           and pp.is_group_flag = 1
          )
         )
   group by ph.policy_header_id;
