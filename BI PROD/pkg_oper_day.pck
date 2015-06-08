CREATE OR REPLACE PACKAGE pkg_oper_day IS

  FUNCTION add_days
  (
    p_date IN DATE
   ,p_days IN NUMBER DEFAULT 1
  ) RETURN DATE;

END pkg_oper_day;
/
CREATE OR REPLACE PACKAGE BODY pkg_oper_day IS

  FUNCTION add_days
  (
    p_date IN DATE
   ,p_days IN NUMBER DEFAULT 1
  ) RETURN DATE IS
    v_res DATE;
  BEGIN
    IF p_days = 0
    THEN
      RETURN p_date;
    ELSE
      /*    select oper_date
       into v_res
       from (select oper_date, rownum rn
               from (select t.oper_date
                       from oper_day t
                      where t.oper_date > p_date
                        and t.is_holiday = 0
                      order by t.oper_date))
      where rn = p_days; */
      RETURN p_date + p_days;
    END IF;
  END;

END pkg_oper_day;
/
