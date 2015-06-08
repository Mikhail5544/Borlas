CREATE OR REPLACE FUNCTION fn_get_ins_pay_inc_ref
(
  par_pol_header_id IN p_pol_header.policy_header_id%TYPE
 ,par_start_date    IN DATE
 ,par_end_date      IN DATE
) RETURN NUMBER IS
  RESULT NUMBER;

  v_start_date     DATE;
  v_end_date       DATE;
  v_end_date_index DATE;
BEGIN
  v_start_date     := par_start_date;
  v_end_date       := par_end_date;
  v_end_date_index := ADD_MONTHS(par_start_date
                                ,FLOOR(MONTHS_BETWEEN(par_end_date + 1, par_start_date) / 12) * 12) - 1;
  SELECT ROUND(sum_amount + amount_rate, 2)
    INTO RESULT
    FROM (SELECT sum_amount
                ,ROUND(SUM(amount_k * avg_rate_k) over(), 2) amount_rate
            FROM (SELECT cbk.num_year
                        ,MAX(nvl(sum_amount, 0)) over() sum_amount
                        ,SUM(nvl(a.set_off_amount, 0)) over(ORDER BY cbk.num_year) amount_k
                        ,nvl(cbk.avg_rate, 0) avg_rate_k
                    FROM (SELECT DISTINCT SUM(set_off_amount) over(PARTITION BY k) set_off_amount
                                         ,sum_amount
                                         ,k
                            FROM (SELECT po.list_doc_date
                                        ,set_off_amount
                                        ,greatest(CEIL(MONTHS_BETWEEN(trunc(po.list_doc_date)
                                                                     ,v_start_date - 0.01) / 12)
                                                 ,1) k
                                        ,SUM(set_off_amount) over() AS sum_amount
                                    FROM v_policy_payment_schedule ps
                                        ,v_policy_payment_set_off  po
                                        ,p_policy_contact          pc
                                        ,t_contact_pol_role        cpr
                                   WHERE ps.pol_header_id = par_pol_header_id
                                     AND ps.doc_status_ref_name != 'Аннулирован'
                                     AND ps.document_id = po.main_doc_id
                                     AND po.list_doc_date <= v_end_date
                                     AND po.doc_status_ref_name != 'Аннулирован'
                                     AND ps.policy_id = pc.policy_id
                                     AND cpr.id = pc.contact_policy_role_id
                                     AND cpr.brief = 'Страхователь'
                                     AND ((pc.contact_id = ps.contact_id) OR
                                         (fn_check_double_contact(pc.contact_id, ps.contact_id) = 1))) b) a
                    FULL JOIN (SELECT AVG(rate_value) / 100 avg_rate
                                    ,num_year
                                FROM (SELECT r.rate_date
                                            ,r.rate_value
                                            ,CEIL((MONTHS_BETWEEN(r.rate_date, MIN(r.rate_date) over()) + 1) / 12) num_year
                                        FROM percent_rate r
                                       WHERE r.rate_date IN
                                             (SELECT trunc(ADD_MONTHS(v_start_date, LEVEL - 1), 'month')
                                                FROM dual
                                               START WITH v_start_date <= v_end_date_index
                                              CONNECT BY ADD_MONTHS(v_start_date, LEVEL - 1) <=
                                                         v_end_date_index))
                               GROUP BY num_year) cbk
                      ON cbk.num_year = a.k
                  --WHERE cbk.num_year(+) = a.k
                  ))
   WHERE rownum = 1;

  RETURN(RESULT);
END fn_get_ins_pay_inc_ref;
/
