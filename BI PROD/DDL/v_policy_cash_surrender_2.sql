CREATE OR REPLACE FORCE VIEW V_POLICY_CASH_SURRENDER_2 AS
SELECT   cs.policy_header_id, cs.policy_id, cs.reserve_id,
            cs.t_lob_line_id, cs.contact_id, cs.order_number,
            ADD_MONTHS (cs.insurance_year_date, -12) insurance_year_date,
            (cs.insurance_year_date - 1) end_insurance_year_date,
            cs.is_periodical,
            (CASE
                WHEN po.due_date IS NULL
                   THEN CASE
                          WHEN cs.is_periodical = 0
                             THEN ADD_MONTHS
                                         (ADD_MONTHS (cs.insurance_year_date,
                                                      -12
                                                     ),
                                          3 * (cs.payment_number - 1)
                                         )
                          ELSE TO_DATE (NULL)
                       END
                ELSE po.due_date
             END
            ) start_cash_surr_date,
            (CASE
                WHEN cs.is_periodical = 0
                   THEN   ADD_MONTHS (ADD_MONTHS (cs.insurance_year_date, -12),
                                      3 * (cs.payment_number)
                                     )
                        - 1
                ELSE NVL
                       (  LEAD (po.due_date) OVER (PARTITION BY cs.reserve_id ORDER BY cs.order_number)
                        - 1,
                        cs.insurance_year_date - 1
                       )
             END
            ) end_cash_surr_date,
            cs.insurance_year_number, cs.payment_number,
            GREATEST
               (  1
                -   0.02
                  * (  MAX (cs.insurance_year_number) OVER (PARTITION BY cs.reserve_id)
                     - cs.insurance_year_number
                    ),
                0.8
               ) ft,
            cs.number_of_payments, cs.p, cs.s, cs.PLAN, cs.tv_p, cs.tv_f,
            cs.tvz_p, cs.tvz_f, cs.tvs_p, cs.tvs_f, cs.tvexp_p, cs.tvexp_f
       FROM v_policy_payment_order po, ins.v_policy_cash_surrender cs
      WHERE 1 = 1 AND po.policy_id(+) = cs.policy_id AND po.payment_number(+) =
                                                               cs.order_number
   ORDER BY cs.insurance_year_date, cs.order_number;

