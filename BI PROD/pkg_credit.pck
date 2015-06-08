CREATE OR REPLACE PACKAGE pkg_credit IS

  -- Author  : OPATSAN
  -- Created : 04.02.2008 14:19:14
  -- Purpose : расчет кредитного договора

  PROCEDURE calc_credit
  (
    p_credit_condition_id IN NUMBER
   ,p_is_first            IN NUMBER
  );

  PROCEDURE copy_schedule
  (
    p_old_pol_id IN NUMBER
   ,p_new_pol_id IN NUMBER
  );

  PROCEDURE update_credit_dates(p_pol_id IN NUMBER);

END pkg_credit;
/
CREATE OR REPLACE PACKAGE BODY pkg_credit IS

  PROCEDURE update_credit_schedule(p_credit_condition_id IN NUMBER) IS
    v_first_date DATE;
    v_last_date  DATE;
  BEGIN
    SELECT cc.first_period_end_date
          ,ADD_MONTHS(cc.first_period_end_date, cc.credit_period)
      INTO v_first_date
          ,v_last_date
      FROM credit_condition cc
     WHERE cc.credit_condition_id = p_credit_condition_id;
  
    DELETE FROM credit_schedule cs WHERE cs.credit_condition_id = p_credit_condition_id;
  
    INSERT INTO ven_credit_schedule
      (YEAR, payoff_date, percent_amount, main_credit_amount, rest_amount, credit_condition_id)
      SELECT c
            ,d
            ,SUM(percent_sum)
            ,SUM(credit_sum)
            ,r
            ,p_credit_condition_id
        FROM (SELECT q.*
                    ,MIN(payment_date) OVER(PARTITION BY c) d
                    ,MIN(rest_sum) OVER(PARTITION BY c) + SUM(credit_sum) OVER(PARTITION BY c) r
                FROM (SELECT TRUNC(MONTHS_BETWEEN(t.payment_date -
                                                  DECODE(t.payment_date, v_last_date, 1, 0)
                                                 ,v_first_date) / 12) + 1 c
                            ,t.*
                        FROM credit_payment t
                       WHERE t.credit_condition_id = p_credit_condition_id) q) q
       GROUP BY c
               ,r
               ,d;
  
    UPDATE credit_payment cp
       SET cp.YEAR = TRUNC(MONTHS_BETWEEN(cp.payment_date - DECODE(cp.payment_date, v_last_date, 1, 0)
                                         ,v_first_date) / 12) + 1
     WHERE cp.credit_condition_id = p_credit_condition_id;
  
  END;

  PROCEDURE calc_credit
  (
    p_credit_condition_id IN NUMBER
   ,p_is_first            IN NUMBER
  ) IS
  
    v_cond      credit_condition%ROWTYPE;
    v_prev_date DATE;
    v_curr_date DATE;
    v_last_date DATE;
    i           NUMBER := 1;
    v_osz       NUMBER;
    c           NUMBER;
    d           NUMBER;
    v_perc      NUMBER;
    v_pay_sum   NUMBER;
    v_pol_start DATE;
  
    FUNCTION dim(p_date IN DATE) RETURN NUMBER IS
    BEGIN
      RETURN ADD_MONTHS(TRUNC(p_date, 'yyyy'), 12) - TRUNC(p_date, 'yyyy');
    END;
  
  BEGIN
  
    SELECT *
      INTO v_cond
      FROM credit_condition cc
     WHERE cc.credit_condition_id = p_credit_condition_id;
  
    SELECT pp.start_date INTO v_pol_start FROM p_policy pp WHERE pp.policy_id = v_cond.policy_id;
  
    v_prev_date := v_cond.issue_date;
    v_curr_date := v_cond.first_period_end_date;
    v_last_date := ADD_MONTHS(v_curr_date, v_cond.credit_period);
    v_osz       := v_cond.amount;
    --v_perc      := v_cond.rate_after;
    v_pay_sum := ROUND(v_cond.fee, 2);
  
    -- opatsan
    -- bug 1556
    -- 2. При пересчете необходимо заново
    -- расчитывать текущий год и все полседующие
    -- (прошлые года не пересчитываются).
    -- 3. В алоритме расчета графика кредита
    -- закладываться на новое поле "ОСЗ на начало
    -- года" таблицы credit_condition.
    IF p_is_first <> 1
    THEN
      BEGIN
        -- находим первую дату следующего года
        SELECT MIN(d)
          INTO v_pol_start
          FROM (SELECT MIN(cp.payment_date) OVER(PARTITION BY cp.YEAR) d
                  FROM credit_payment cp
                 WHERE cp.credit_condition_id = v_cond.credit_condition_id)
         WHERE d >= v_pol_start;
      
        -- если она отличается от первого года
        IF v_pol_start > v_curr_date
        THEN
          i := i + 1;
          -- начинаем считать с нее
          v_curr_date := v_pol_start;
          -- предыдущая дата
          SELECT MAX(cp.payment_date)
            INTO v_prev_date
            FROM credit_payment cp
           WHERE cp.payment_date < v_curr_date
             AND cp.credit_condition_id = v_cond.credit_condition_id;
          -- ОСЗ
          v_osz := v_cond.osz_begin_year;
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          v_pol_start := NULL;
      END;
    END IF;
  
    DELETE FROM credit_payment cp
     WHERE credit_condition_id = p_credit_condition_id
       AND (cp.payment_date >= v_pol_start OR v_pol_start IS NULL);
  
    WHILE v_curr_date <= v_last_date
    LOOP
    
      IF NVL(v_cond.is_first_habitation, 0) = 0
      THEN
        v_perc := v_cond.rate_after;
      ELSIF NVL(v_cond.is_first_habitation, 0) = 1
            AND v_cond.deposit_reg_date IS NULL
      THEN
        v_perc := v_cond.rate_before;
      ELSIF NVL(v_cond.deposit_reg_date, v_curr_date - 1) < v_curr_date
      THEN
        v_perc := v_cond.rate_after;
      ELSE
        v_perc := v_cond.rate_before;
      END IF;
    
      c := NVL(ROUND(v_osz * v_perc / 100 *
                     ((LAST_DAY(v_prev_date) - v_prev_date) / dim(v_prev_date) +
                     (v_curr_date - TRUNC(v_curr_date, 'mm') + 1) / dim(v_curr_date))
                    ,2)
              ,0);
      DBMS_OUTPUT.PUT_LINE(v_prev_date || ' ' || v_curr_date || ' ' || c);
    
      IF i = 1
         AND v_cond.is_payed_in_first_period = 0
      THEN
        d := 0;
      ELSE
        d := v_pay_sum - c;
      END IF;
    
      IF v_curr_date = v_last_date
         OR d > v_osz
      THEN
        d := v_osz;
      END IF;
    
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_curr_date) || '  ' || TO_CHAR(c) || '  ' || TO_CHAR(d) || '  ' ||
                           TO_CHAR(c + d) || '  ' || TO_CHAR(v_osz - d));
    
      v_osz := v_osz - d;
    
      INSERT INTO credit_payment
        (credit_payment_id, credit_condition_id, payment_date, percent_sum, credit_sum, rest_sum)
      VALUES
        (sq_credit_payment.NEXTVAL, p_credit_condition_id, v_curr_date, c, d, v_osz);
    
      i           := i + 1;
      v_prev_date := v_curr_date;
      v_curr_date := ADD_MONTHS(v_curr_date, 1);
    END LOOP;
    update_credit_schedule(p_credit_condition_id);
  END;

  PROCEDURE copy_schedule
  (
    p_old_pol_id IN NUMBER
   ,p_new_pol_id IN NUMBER
  ) IS
    v_cred_cond_row credit_condition%ROWTYPE;
    v_old_id        NUMBER;
  BEGIN
  
    SELECT * INTO v_cred_cond_row FROM credit_condition cc WHERE cc.policy_id = p_old_pol_id;
  
    v_old_id := v_cred_cond_row.credit_condition_id;
  
    SELECT sq_credit_condition.NEXTVAL
          ,p_new_pol_id
      INTO v_cred_cond_row.credit_condition_id
          ,v_cred_cond_row.policy_id
      FROM dual;
  
    INSERT INTO credit_condition VALUES v_cred_cond_row;
  
    FOR r1 IN (SELECT * FROM ven_credit_schedule cs WHERE cs.credit_condition_id = v_old_id)
    LOOP
      r1.credit_schedule_id  := NULL;
      r1.credit_condition_id := v_cred_cond_row.credit_condition_id;
      INSERT INTO ven_credit_schedule VALUES r1;
    END LOOP;
  
    FOR r2 IN (SELECT * FROM ven_credit_payment WHERE credit_condition_id = v_old_id)
    LOOP
      r2.credit_payment_id   := NULL;
      r2.credit_condition_id := v_cred_cond_row.credit_condition_id;
      INSERT INTO ven_credit_payment VALUES r2;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE update_credit_dates(p_pol_id IN NUMBER) IS
    v_pol_Date DATE;
    v_cc_id    NUMBER;
    v_osz      NUMBER;
  BEGIN
    SELECT pp.start_date INTO v_pol_date FROM p_policy pp WHERE pp.policy_id = p_pol_id;
  
    -- находим первую дату следующего года
    SELECT MIN(d)
          ,credit_condition_id
      INTO v_pol_date
          ,v_cc_id
      FROM (SELECT MIN(cp.payment_date) OVER(PARTITION BY cp.YEAR) d
                  ,cc.credit_condition_id
              FROM credit_payment   cp
                  ,credit_condition cc
             WHERE cc.policy_id = p_pol_id
               AND cp.credit_condition_id = cc.credit_condition_id)
     WHERE d >= v_pol_date
     GROUP BY credit_condition_id;
  
    SELECT MIN(cp.rest_sum)
      INTO v_osz
      FROM credit_payment cp
     WHERE cp.credit_condition_id = v_cc_id
       AND cp.payment_date < v_pol_date;
  
    UPDATE credit_condition cc
       SET cc.osz_begin_year = NVL(v_osz, cc.amount)
     WHERE cc.credit_condition_id = v_cc_id;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

END pkg_credit;
/
