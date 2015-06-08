CREATE OR REPLACE PACKAGE pkg_common_utils IS
  /**
  * �����, ���������� ��������� ������ ����������:
  *    - ��� ������ ��������
  *    - true � false
  * @author Filipp Ganichev
  * @version 1.0
   */

  /**
  *  ������ �������� ���� number
  */

  miss_num CONSTANT NUMBER := -1;

  /**
  *  ������ �������� ���� varchar
  */

  miss_char CONSTANT VARCHAR2(1) := '~';

  /**
  *  ������ �������� ���� date
  */

  miss_date CONSTANT DATE := to_date('01.01.1000', 'dd.MM.yyyy');

  /**
  *  �������� true
  */

  c_true CONSTANT NUMBER := 1;

  /**
  *  �������� false
  */

  c_false CONSTANT NUMBER := 0;

  /**
  *  �������� �� ������ �������� ���������� ���� number
  *  @author Filipp Ganichev
  *  @p_value �������� ����������
  */

  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER;

  /**
  *  �������� �� ������ �������� ���������� ���� varchar
  *  @author Filipp Ganichev
  *  @p_value �������� ����������
  */

  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER;

  /**
  *  �������� �� ������ �������� ���������� ���� date
  *  @author Filipp Ganichev
  *  @p_value �������� ����������
  */

  FUNCTION is_empty(p_value DATE) RETURN NUMBER;

  /**
  *  ���������� �� �������
  *  @author V.Ustinov
  *  @p_period_value �������� �������
  *  @p_type_brief   ���������� ���� �������
  */
  FUNCTION get_period_id
  (
    p_period_value NUMBER
   ,p_type_brief   VARCHAR2
  ) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_common_utils IS
  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_num
    THEN
      RETURN c_true;
    END IF;
    RETURN c_false;
  END;

  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_char
    THEN
      RETURN c_true;
    END IF;
    RETURN c_false;
  END;

  FUNCTION is_empty(p_value DATE) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_date
    THEN
      RETURN c_true;
    END IF;
    RETURN c_false;
  END;

  FUNCTION get_period_id
  (
    p_period_value NUMBER
   ,p_type_brief   VARCHAR2
  ) RETURN NUMBER IS
    l_type_id NUMBER;
    res       NUMBER;
  BEGIN
    BEGIN
      SELECT id INTO l_type_id FROM t_period_type WHERE brief = p_type_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20000
                               ,'get_period_id: �� ������ ��� ������� � ����������� "' ||
                                p_type_brief || '". ���������� � ��������������.');
    END;
    BEGIN
      SELECT id
        INTO res
        FROM t_period
       WHERE period_value = p_period_value
         AND period_type_id = l_type_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20000
                               ,'get_period_id: �� ������ ������ �� ��������� "' ||
                                to_char(p_period_value) || '"/"' || p_type_brief ||
                                '". ���������� � ��������������.');
    END;
    RETURN res;
  END;

END;
/
