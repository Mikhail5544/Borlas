CREATE OR REPLACE PACKAGE Pkg_Period_Closed IS

  -- закрытие периода
  PROCEDURE close_period(par_period_id IN NUMBER);

  -- открытие периода
  PROCEDURE open_period(par_period_id IN NUMBER);

  -- проверка периода даты
  -- если период открыт, то возвращается заданная дата
  -- если закрыт, то первая дата из открытого периода
  FUNCTION check_closed_date(par_date IN DATE) RETURN DATE;
  
  /** Проверка нахождения даты в закрытом периоде
  *   Created by 273031: Изменение триггера контроля закрытого периода в
  *   @autor Чирков В.Ю.
  *   @param par_date - проверяемая дата
  */
  FUNCTION check_date_in_closed(par_date IN DATE) RETURN INT;  

  -- Возвращает дату закрытия периода, в который попадает переданная дата
  -- или NULL, если переданная дата не в закрытом периоде
  FUNCTION get_period_close_date(par_date IN DATE) RETURN DATE;

  -- Возвращают последнюю дату закрытия
  FUNCTION get_last_period_date RETURN DATE;

END Pkg_Period_Closed;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Period_Closed IS

  -- закрытие периода
  PROCEDURE close_period(par_period_id IN NUMBER) IS
    v_row t_period_closed%ROWTYPE;
  BEGIN
    -- выборка текущего периода
    SELECT * INTO v_row FROM t_period_closed WHERE t_period_closed_id = par_period_id;
  
    -- проверка на ранние открытые периоды
    FOR rc IN (SELECT t.*
                 FROM t_period_closed t
                WHERE t.period_date < v_row.period_date
                  AND t.is_closed = 0)
    LOOP
      RAISE_APPLICATION_ERROR(-20000
                             ,'Существуют ранние открытые периоды. Закрытие невозможно');
    END LOOP;
  
    -- установка флага "закрыт" у проводок
    UPDATE trans t
       SET t.is_closed = 1
     WHERE t.is_closed = 0
       AND t.doc_date < (v_row.period_date + 1);
  
  END;

  -- открытие периода
  PROCEDURE open_period(par_period_id IN NUMBER) IS
    v_row  t_period_closed%ROWTYPE;
    v_prev t_period_closed%ROWTYPE;
  BEGIN
    -- выборка текущего периода
    SELECT * INTO v_row FROM t_period_closed WHERE t_period_closed_id = par_period_id;
  
    -- проверка на поздние закрытые периоды
    FOR rc IN (SELECT t.*
                 FROM t_period_closed t
                WHERE t.period_date > v_row.period_date
                  AND t.is_closed = 1)
    LOOP
      RAISE_APPLICATION_ERROR(-20000
                             ,'Существуют поздние закрытые периоды. Открытие невозможно');
    END LOOP;
  
    -- проверка на дополнение данных за текущий период, после его закрытия
    FOR rc IN (SELECT *
                 FROM trans
                WHERE reg_date > v_row.close_date
                  AND doc_date < (v_row.period_date + 1))
    LOOP
      RAISE_APPLICATION_ERROR(-20000
                             ,'Существуют данные за текущий период, добавленные после его закрытия. Открытие периода невозможно');
    END LOOP;
  
    -- выборка предыдущего периода
    BEGIN
      SELECT *
        INTO v_prev
        FROM (SELECT *
                FROM t_period_closed p
               WHERE p.period_date < v_row.period_date
               ORDER BY period_date DESC)
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    -- установка флага "открыт" у проводок
    UPDATE trans t
       SET t.is_closed = 0
     WHERE t.is_closed = 1
       AND t.trans_date < (v_row.period_date + 1)
       AND (v_prev.period_date IS NULL OR t.trans_date > v_prev.period_date);
  
  END;

  FUNCTION get_period_close_date(par_date IN DATE) RETURN DATE IS
    v_closed_date DATE;
  BEGIN
  
    SELECT *
      INTO v_closed_date
      FROM (SELECT DECODE(NVL(p.is_closed, 0), 1, p.CLOSE_DATE, NULL)
              FROM t_period_closed p
             WHERE p.period_date >= par_date
             ORDER BY p.period_date)
     WHERE ROWNUM = 1;
  
    RETURN v_closed_date;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_last_period_date RETURN DATE IS
    v_period_date DATE;
  BEGIN
  
    SELECT *
      INTO v_period_date
      FROM (SELECT p.PERIOD_DATE
              FROM t_period_closed p
             WHERE p.is_closed = 1
             ORDER BY p.period_date DESC)
     WHERE ROWNUM = 1;
  
    RETURN v_period_date;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  -- проверка периода даты
  -- если период открыт, то возвращается заданная дата
  -- если закрыт, то первая дата из открытого периода
  FUNCTION check_closed_date(par_date IN DATE) RETURN DATE IS
    v_closed NUMBER;
    ret_val  DATE := par_date;
  BEGIN
    BEGIN
      -- определяется статус периода
      /*комментарий 273031: Изменение триггера контроля закрытого периода в
       SELECT is_closed
       INTO v_closed
       FROM (SELECT p.is_closed              
               FROM t_period_closed p
              WHERE p.period_date >= par_date
              ORDER BY p.period_date)
      WHERE ROWNUM = 1;
      */
      v_closed := check_date_in_closed(par_date); --добавлено 273031: Изменение триггера контроля закрытого периода в  
      -- если период закрыт, то определяется последний закрытый периоди и возвращается следующая дата
      IF v_closed = 1
      THEN      
        SELECT period_date + 1
          INTO ret_val
          FROM (SELECT p.period_date
                  FROM t_period_closed p
                 WHERE p.is_closed = 1
                 ORDER BY p.period_date DESC)
         WHERE ROWNUM = 1;
      END IF;
    
    EXCEPTION
      -- если период, в котором находится дата, не найден, то возвразается заданная дата
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    RETURN ret_val;
  END;

  /** Проверка нахождения даты в закрытом периоде
  *   Created by 273031: Изменение триггера контроля закрытого периода в
  *   @autor Чирков В.Ю.
  *   @param par_date - проверяемая дата
  */
  FUNCTION check_date_in_closed(par_date IN DATE) RETURN INT IS
    v_closed INT;
  BEGIN
    BEGIN
      SELECT is_closed
        INTO v_closed
        FROM (SELECT p.is_closed
                FROM t_period_closed p
               WHERE p.period_date >= par_date
               ORDER BY p.period_date)
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_closed := 0;
    END;
    RETURN v_closed;
  END;

END Pkg_Period_Closed;
/
