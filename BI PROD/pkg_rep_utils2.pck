CREATE OR REPLACE PACKAGE PKG_REP_UTILS2 AS
  /**
  * Функции для отчетов Discoverer и печатных форм
  * @author Surovtsev S.
  * @version 2.0
  * @since 1.0 - PKG_REP_UTILS
  * @headcom
  */

  TYPE tagList_name_of_int IS TABLE OF VARCHAR2(30);
  TYPE tagList_of_int IS TABLE OF INT;

  TYPE tagList_name_of_date IS TABLE OF VARCHAR2(30);
  TYPE tagList_of_date IS TABLE OF DATE;

  List_of_int      tagList_of_int := tagList_of_int();
  List_name_of_int tagList_name_of_int := tagList_name_of_int();

  List_of_date      tagList_of_date := tagList_of_date();
  List_name_of_date tagList_name_of_date := tagList_name_of_date();

  /**
  * добавляет параметр типа int 
  * @author Surovtsev A.I.
  * @param p_str имя параметра
  * @param p_val значение параметра
  */
  PROCEDURE iSetVal
  (
    p_str VARCHAR2
   ,p_val INT
  );

  /**
  * добавляет параметр типа date 
  * @author Surovtsev A.I.
  * @param p_str имя параметра
  * @param p_val значение параметра
  */
  PROCEDURE dSetVal
  (
    p_str VARCHAR2
   ,p_val DATE
  );

  /**
  * извлекает параметр типа date 
  * @author Surovtsev A.I.
  * @param p_str имя параметра
  */
  FUNCTION dGetVal(p_str VARCHAR2) RETURN DATE;

  /**
  * не реализована  
  * @author Surovtsev A.I.
  * @param p_str имя параметра
  */
  FUNCTION vGetVal(p_str VARCHAR2) RETURN VARCHAR2;

  /**
  * извлекает параметр типа int
  * @author Surovtsev A.I.
  * @param p_str имя параметра
  */
  FUNCTION iGetVal(p_str VARCHAR2) RETURN INT;

END PKG_REP_UTILS2;
/
CREATE OR REPLACE PACKAGE BODY PKG_REP_UTILS2 AS

  PROCEDURE InsertIVal
  (
    p_str VARCHAR2
   ,p_val INT
  ) IS
  BEGIN
  
    list_of_int.EXTEND;
    list_of_int(list_of_int.COUNT) := p_val;
  
    list_name_of_int.EXTEND;
    list_name_of_int(list_name_of_int.COUNT) := p_str;
  
  END InsertIVal;

  PROCEDURE InsertDVal
  (
    p_str VARCHAR2
   ,p_val DATE
  ) IS
  BEGIN
  
    list_of_date.EXTEND;
    list_of_date(list_of_date.COUNT) := p_val;
  
    list_name_of_date.EXTEND;
    list_name_of_date(list_name_of_date.COUNT) := p_str;
  
  END InsertDVal;

  PROCEDURE dSetVal
  (
    p_str VARCHAR2
   ,p_val DATE
  ) IS
  BEGIN
    IF (list_name_of_date.COUNT != 0)
    THEN
      FOR i IN 1 .. list_name_of_date.COUNT
      LOOP
        IF (p_str = list_name_of_date(i))
        THEN
          list_of_date(i) := p_val;
          RETURN;
        END IF;
      END LOOP;
    END IF;
    InsertDVal(p_str, p_val);
  END dSetVal;

  PROCEDURE iSetVal
  (
    p_str VARCHAR2
   ,p_val INT
  ) IS
  BEGIN
    IF (list_name_of_int.COUNT != 0)
    THEN
      FOR i IN 1 .. list_name_of_int.COUNT
      LOOP
        IF (p_str = list_name_of_int(i))
        THEN
          list_of_int(i) := p_val;
          RETURN;
        END IF;
      END LOOP;
    END IF;
    InsertIVal(p_str, p_val);
  END iSetVal;

  FUNCTION vGetVal(p_str VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN 's';
  END vGetVal;

  FUNCTION iGetVal(p_str VARCHAR2) RETURN INT IS
  BEGIN
    FOR i IN 1 .. list_name_of_int.COUNT
    LOOP
      IF (p_str = list_name_of_int(i))
      THEN
        RETURN list_of_int(i);
      END IF;
    END LOOP;
    RETURN - 1;
  END iGetVal;

  FUNCTION dGetVal(p_str VARCHAR2) RETURN DATE IS
  BEGIN
    FOR i IN 1 .. list_name_of_date.COUNT
    LOOP
      IF (p_str = list_name_of_date(i))
      THEN
        RETURN list_of_date(i);
      END IF;
    END LOOP;
    RETURN SYSDATE;
  END dGetVal;

/*
function check_payment_set_off(p_ac_payment_id number) return number
as
 v_sum number;
begin
  select nvl(sum(ds.set_off_amount),0)
  into v_sum  
  from doc_set_off ds
  where ds.parent_doc_id = p_ac_payment_id
    and ds.cancel_date is null;
return v_sum;  
end;
 */
END PKG_REP_UTILS2;
/
