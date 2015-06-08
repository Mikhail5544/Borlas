CREATE OR REPLACE PACKAGE PKG_COMMISS_FRM IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 29.07.2012 23:14:07
  -- Purpose : Бизнес логика формы COMMISS.FMB

  /*
    Получение значений для item'ов DB_CT_VAL.VALUENAME_*
  */
  FUNCTION get_valuename
  (
    par_coef_type_id NUMBER
   ,par_factor_num   NUMBER
   ,par_object_id    NUMBER
  ) RETURN VARCHAR2;

END PKG_COMMISS_FRM;
/
CREATE OR REPLACE PACKAGE BODY PKG_COMMISS_FRM IS

  /*
    Получение значений для item'ов DB_CT_VAL.VALUENAME_*
  */
  FUNCTION get_valuename
  (
    par_coef_type_id NUMBER
   ,par_factor_num   NUMBER
   ,par_object_id    NUMBER
  ) RETURN VARCHAR2 IS
    v_desc         VARCHAR2(255);
    v_sql          t_attribut.obj_list_sql%TYPE;
    v_attribute_id t_attribut.t_attribut_id%TYPE;
  BEGIN
    SELECT CASE par_factor_num
             WHEN 1 THEN
              ct.factor_1
             WHEN 2 THEN
              ct.factor_2
             WHEN 3 THEN
              ct.factor_3
             WHEN 4 THEN
              ct.factor_4
             WHEN 5 THEN
              ct.factor_5
             WHEN 6 THEN
              ct.factor_6
             WHEN 7 THEN
              ct.factor_7
             WHEN 8 THEN
              ct.factor_8
             WHEN 9 THEN
              ct.factor_9
             WHEN 10 THEN
              ct.factor_10
           END
      INTO v_attribute_id
      FROM t_prod_coef_type ct
     WHERE ct.t_prod_coef_type_id = par_coef_type_id;
  
    IF v_attribute_id IS NOT NULL
       AND par_object_id IS NOT NULL
    THEN
      BEGIN
        SELECT 'select substr(V_NAME,1,255) from (' || ta.obj_list_sql || ') where V_ID = :obj_id'
          INTO v_sql
          FROM t_attribut ta
         WHERE ta.t_attribut_id = v_attribute_id
           AND ta.obj_list_sql IS NOT NULL;
        BEGIN
          EXECUTE IMMEDIATE v_sql
            INTO v_desc
            USING IN par_object_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_desc := NULL;
          WHEN TOO_MANY_ROWS THEN
            v_desc := 'Найдено несколько значений';
        END;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_desc := 'Не найден аргумент функции или отсутсвует запрос';
        WHEN OTHERS THEN
          IF SQLCODE = -900
          THEN
            v_desc := 'Неправильный запрос';
          ELSIF SQLCODE = -904
          THEN
            v_desc := 'В запросе отсутствует поле V_ID';
          ELSE
            v_desc := substr(SQLERRM, 1, 255);
          END IF;
      END;
    END IF;
    RETURN v_desc;
  END get_valuename;
END PKG_COMMISS_FRM;
/
