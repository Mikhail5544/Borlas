CREATE OR REPLACE PACKAGE pkg_calendar IS

  -- создать даты для календаря за период
  PROCEDURE create_days
  (
    p_start IN DATE
   ,p_end   IN DATE
  );

  -- последний рабочий день месяца
  FUNCTION last_day(p_date IN DATE) RETURN DATE;

  -- добавление рабочих дней к дате
  FUNCTION add_days
  (
    p_date IN DATE
   ,p_days IN NUMBER DEFAULT 1
  ) RETURN DATE;

END pkg_calendar;
/
CREATE OR REPLACE PACKAGE BODY pkg_calendar IS

  FUNCTION last_day(p_date IN DATE) RETURN DATE IS
  BEGIN
    FOR rc IN (SELECT MAX(od.calendar_date) v_date
                 FROM t_calendar od
                WHERE od.calendar_date <= last_day(p_date)
                  AND od.is_holiday = 0)
    LOOP
      RETURN rc.v_date;
    END LOOP;
    RETURN p_date;
  END;

  PROCEDURE create_days
  (
    p_start IN DATE
   ,p_end   IN DATE
  ) IS
    v_day DATE := trunc(p_start, 'dd');
  BEGIN
    WHILE v_day <= p_end
    LOOP
      BEGIN
        INSERT INTO t_calendar
          (t_calendar_id, calendar_date, is_holiday)
          SELECT sq_t_calendar.nextval
                ,v_day
                ,CASE
                   WHEN to_char(v_day, 'd') > 5 THEN
                    1
                   ELSE
                    0
                 END
            FROM dual;
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
      END;
      v_day := v_day + 1;
    END LOOP;
  END;

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
      SELECT calendar_date
        INTO v_res
        FROM (SELECT calendar_date
                    ,rownum rn
                FROM (SELECT t.calendar_date
                        FROM t_calendar t
                       WHERE t.calendar_date > p_date
                         AND t.is_holiday = 0
                       ORDER BY t.calendar_date))
       WHERE rn = p_days;
      RETURN v_res;
    END IF;
  END;

END pkg_calendar;
/
