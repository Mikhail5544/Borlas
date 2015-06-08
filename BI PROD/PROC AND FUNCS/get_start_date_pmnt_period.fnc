CREATE OR REPLACE FUNCTION Get_Start_Date_Pmnt_Period(p_first_date     IN DATE,
                                                                 p_months_diff    IN NUMBER,
                                                                 p_days_diff      IN NUMBER,
                                                                 p_period_num IN NUMBER)
  RETURN DATE IS

  v_r DATE;
  v_months_to_period_start_date NUMBER;
  s1                  VARCHAR2(30);

  s2                  VARCHAR2(30);
BEGIN


  SELECT p_months_diff * p_period_num INTO v_months_to_period_start_date FROM dual;
 -- dbms_output.put_line(last_day(p_first_date));
 -- dbms_output.put_line(add_months(last_day(p_first_date), -1) + 1);
  v_r := ADD_MONTHS(p_first_date, NVL(v_months_to_period_start_date, 0));

  IF (LAST_DAY(p_first_date) - (ADD_MONTHS(LAST_DAY(p_first_date), -1) + 1)) <
     (LAST_DAY(v_r) -
     (ADD_MONTHS(LAST_DAY(v_r), -1) + 1)) THEN
    s1 := TO_CHAR(p_first_date, 'ddmmyyyy');
    s2 := TO_CHAR(v_r, 'ddmmyyyy');

    v_r := TO_DATE(SUBSTR(s1, 1, 2) || SUBSTR(s2, 3, 6),
                                   'ddmmyyyy');

  END IF;
  v_r := v_r + NVL(p_days_diff, 0);

  --dbms_output.put_line(v_next_pay_due_date);

  RETURN(v_r);
END Get_Start_Date_Pmnt_Period;
/

