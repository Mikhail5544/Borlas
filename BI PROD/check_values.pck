CREATE OR REPLACE PACKAGE Check_values IS

  -- Author  : ABALASHOV
  -- Created : 13.12.2005 11:05:34
  -- Purpose : Check_values

  PROCEDURE check_100percent(p_pay_id NUMBER);
  PROCEDURE check_countpays
  (
    col      NUMBER
   ,p_pay_id NUMBER
  );

END Check_values;
/
CREATE OR REPLACE PACKAGE BODY Check_values IS

  PROCEDURE check_100percent(p_pay_id NUMBER) IS
    v_sum NUMBER;
  BEGIN
    SELECT SUM(payment_percent)
      INTO v_sum
      FROM ven_t_pay_term_details
     WHERE payment_term_id = p_pay_id;
    IF v_sum <> 100
    THEN
      raise_application_error(-20000
                             ,'Неверно заданы проценты.Сумма процентов должна равняться 100.');
    END IF;
  END;

  PROCEDURE check_countpays
  (
    col      NUMBER
   ,p_pay_id NUMBER
  ) IS
    v_sum NUMBER;
  BEGIN
    SELECT COUNT(pd.id) INTO v_sum FROM ven_t_pay_term_details pd WHERE payment_term_id = p_pay_id;
    IF col <> v_sum
    THEN
      raise_application_error(-20000
                             ,'Не верно указано число платежей в детализации.');
    END IF;
  END;

END Check_values;
/
