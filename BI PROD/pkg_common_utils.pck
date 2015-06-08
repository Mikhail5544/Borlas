CREATE OR REPLACE PACKAGE pkg_common_utils IS
  /**
  * Пакет, содержащий константы общего назначения:
  *    - для пустых значений
  *    - true и false
  * @author Filipp Ganichev
  * @version 1.0
   */

  /**
  *  Пустое значение типа number
  */

  miss_num CONSTANT NUMBER := -1;

  /**
  *  Пустое значение типа varchar
  */

  miss_char CONSTANT VARCHAR2(1) := '~';

  /**
  *  Пустое значение типа date
  */

  miss_date CONSTANT DATE := to_date('01.01.1000', 'dd.MM.yyyy');

  /**
  *  Значение true
  */

  c_true CONSTANT NUMBER := 1;

  /**
  *  Значение false
  */

  c_false CONSTANT NUMBER := 0;

  /**
  *  Проверка на пустое значение переменной типа number
  *  @author Filipp Ganichev
  *  @p_value Значение переменной
  */

  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER;

  /**
  *  Проверка на пустое значение переменной типа varchar
  *  @author Filipp Ganichev
  *  @p_value Значение переменной
  */

  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER;

  /**
  *  Проверка на пустое значение переменной типа date
  *  @author Filipp Ganichev
  *  @p_value Значение переменной
  */

  FUNCTION is_empty(p_value DATE) RETURN NUMBER;

  /**
  *  Возвращает ИД периода
  *  @author V.Ustinov
  *  @p_period_value Значение периода
  *  @p_type_brief   Сокращение типа периода
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
                               ,'get_period_id: Не найден тип периода с сокращением "' ||
                                p_type_brief || '". Обратитесь к администратору.');
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
                               ,'get_period_id: Не найден период со значением "' ||
                                to_char(p_period_value) || '"/"' || p_type_brief ||
                                '". Обратитесь к администратору.');
    END;
    RETURN res;
  END;

END;
/
