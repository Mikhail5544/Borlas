CREATE OR REPLACE PACKAGE Pkg_Period_Closed IS

  -- �������� �������
  PROCEDURE close_period(par_period_id IN NUMBER);

  -- �������� �������
  PROCEDURE open_period(par_period_id IN NUMBER);

  -- �������� ������� ����
  -- ���� ������ ������, �� ������������ �������� ����
  -- ���� ������, �� ������ ���� �� ��������� �������
  FUNCTION check_closed_date(par_date IN DATE) RETURN DATE;
  
  /** �������� ���������� ���� � �������� �������
  *   Created by 273031: ��������� �������� �������� ��������� ������� �
  *   @autor ������ �.�.
  *   @param par_date - ����������� ����
  */
  FUNCTION check_date_in_closed(par_date IN DATE) RETURN INT;  

  -- ���������� ���� �������� �������, � ������� �������� ���������� ����
  -- ��� NULL, ���� ���������� ���� �� � �������� �������
  FUNCTION get_period_close_date(par_date IN DATE) RETURN DATE;

  -- ���������� ��������� ���� ��������
  FUNCTION get_last_period_date RETURN DATE;

END Pkg_Period_Closed;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Period_Closed IS

  -- �������� �������
  PROCEDURE close_period(par_period_id IN NUMBER) IS
    v_row t_period_closed%ROWTYPE;
  BEGIN
    -- ������� �������� �������
    SELECT * INTO v_row FROM t_period_closed WHERE t_period_closed_id = par_period_id;
  
    -- �������� �� ������ �������� �������
    FOR rc IN (SELECT t.*
                 FROM t_period_closed t
                WHERE t.period_date < v_row.period_date
                  AND t.is_closed = 0)
    LOOP
      RAISE_APPLICATION_ERROR(-20000
                             ,'���������� ������ �������� �������. �������� ����������');
    END LOOP;
  
    -- ��������� ����� "������" � ��������
    UPDATE trans t
       SET t.is_closed = 1
     WHERE t.is_closed = 0
       AND t.doc_date < (v_row.period_date + 1);
  
  END;

  -- �������� �������
  PROCEDURE open_period(par_period_id IN NUMBER) IS
    v_row  t_period_closed%ROWTYPE;
    v_prev t_period_closed%ROWTYPE;
  BEGIN
    -- ������� �������� �������
    SELECT * INTO v_row FROM t_period_closed WHERE t_period_closed_id = par_period_id;
  
    -- �������� �� ������� �������� �������
    FOR rc IN (SELECT t.*
                 FROM t_period_closed t
                WHERE t.period_date > v_row.period_date
                  AND t.is_closed = 1)
    LOOP
      RAISE_APPLICATION_ERROR(-20000
                             ,'���������� ������� �������� �������. �������� ����������');
    END LOOP;
  
    -- �������� �� ���������� ������ �� ������� ������, ����� ��� ��������
    FOR rc IN (SELECT *
                 FROM trans
                WHERE reg_date > v_row.close_date
                  AND doc_date < (v_row.period_date + 1))
    LOOP
      RAISE_APPLICATION_ERROR(-20000
                             ,'���������� ������ �� ������� ������, ����������� ����� ��� ��������. �������� ������� ����������');
    END LOOP;
  
    -- ������� ����������� �������
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
  
    -- ��������� ����� "������" � ��������
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

  -- �������� ������� ����
  -- ���� ������ ������, �� ������������ �������� ����
  -- ���� ������, �� ������ ���� �� ��������� �������
  FUNCTION check_closed_date(par_date IN DATE) RETURN DATE IS
    v_closed NUMBER;
    ret_val  DATE := par_date;
  BEGIN
    BEGIN
      -- ������������ ������ �������
      /*����������� 273031: ��������� �������� �������� ��������� ������� �
       SELECT is_closed
       INTO v_closed
       FROM (SELECT p.is_closed              
               FROM t_period_closed p
              WHERE p.period_date >= par_date
              ORDER BY p.period_date)
      WHERE ROWNUM = 1;
      */
      v_closed := check_date_in_closed(par_date); --��������� 273031: ��������� �������� �������� ��������� ������� �  
      -- ���� ������ ������, �� ������������ ��������� �������� ������� � ������������ ��������� ����
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
      -- ���� ������, � ������� ��������� ����, �� ������, �� ������������ �������� ����
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    RETURN ret_val;
  END;

  /** �������� ���������� ���� � �������� �������
  *   Created by 273031: ��������� �������� �������� ��������� ������� �
  *   @autor ������ �.�.
  *   @param par_date - ����������� ����
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
