CREATE OR REPLACE PACKAGE pkg_tariff_calc_new IS

  /*
  * Пакет расчета тарифов универсальный
  * Переписал оригинальный пакет Каткевич А.Г. 24/02/2008
  * @version 2
  */

  TYPE attr_type IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  /*
  *Возвращает значение коэффициента по ИД тарифа
  * @param p_id ИД тарифа
  * @param p_ent_id ИД сущности Контекста
  * @param p_obj_id ИД объекта сущности Контекста
  * @return Значение ИД Таблицы значений атрибутов
  */
  FUNCTION calc_fun
  (
    p_id     IN NUMBER
   ,p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER;
  /*
  *Возвращает значение коэффициента по brief тарифа
  * @param p_brief ИД тарифа
  * @param p_ent_id ИД сущности Контекста
  * @param p_obj_id ИД объекта сущности Контекста
  * @return Значение ИД Таблицы значений атрибутов
  */
  FUNCTION calc_fun
  (
    p_brief  IN VARCHAR2
   ,p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER;
  /*
  * Возврашает значение коэффициента
  */
  FUNCTION calc_coeff_val
  (
    p_brief    IN VARCHAR2
   ,p_attrs    attr_type
   ,p_attr_num NUMBER
  ) RETURN NUMBER;

  FUNCTION get_attribut
  (
    p_ent_id  IN NUMBER
   , --Контекст
    p_obj_id  IN NUMBER
   ,p_attr_id IN NUMBER
  ) RETURN NUMBER;

END pkg_tariff_calc_new;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Tariff_Calc_new IS

  FUNCTION get_attribut
  (
    p_ent_id  IN NUMBER
   , --Контекст
    p_obj_id  IN NUMBER
   ,p_attr_id IN NUMBER
  ) RETURN NUMBER AS
    v_at_brief  VARCHAR2(100);
    v_result    NUMBER;
    v_s         VARCHAR2(4000);
    v_tariff_id NUMBER;
  BEGIN
  
    v_tariff_id := utils.get_null(pkg_payment.tariff_calc_cache, 'TARIFF_GETATTR_TARIFID' || p_attr_id);
    v_at_brief  := utils.get_null(pkg_payment.tariff_calc_cache, 'TARIFF_GETATTR_ATBRIEF' || p_attr_id);
    IF (v_tariff_id IS NULL)
       AND (v_at_brief IS NULL)
    THEN
      SELECT s.brief
            ,a.attr_tarif_id
        INTO v_at_brief
            ,v_tariff_id
        FROM T_ATTRIBUT        a
            ,T_ATTRIBUT_SOURCE s
       WHERE a.t_attribut_id = p_attr_id
         AND a.t_attribut_source_id = s.t_attribut_source_id;
      pkg_payment.tariff_calc_cache('TARIFF_GETATTR_TARIFID' || p_attr_id) := v_tariff_id;
      pkg_payment.tariff_calc_cache('TARIFF_GETATTR_ATBRIEF' || p_attr_id) := v_at_brief;
    END IF;
  
    BEGIN
      CASE
        WHEN v_at_brief = 'S_ENT' THEN
          SELECT e.obj_list_sql
            INTO v_s
            FROM T_ATTRIBUT_ENTITY e
           WHERE e.t_attribut_id = p_attr_id
             AND e.entity_id = p_ent_id;
          EXECUTE IMMEDIATE 'Begin ' || v_s || '; end;'
            USING OUT v_result, IN p_obj_id;
        WHEN v_at_brief = 'S_DEFAULT' THEN
          v_s := utils.get_null(pkg_payment.tariff_calc_cache
                               ,'TARIFF_GETATTR_VS_' || p_ent_id || ' ' || p_attr_id);
          IF v_s IS NULL
          THEN
            SELECT e.obj_list_sql
              INTO v_s
              FROM T_ATTRIBUT_ENTITY e
             WHERE e.t_attribut_id = p_attr_id
               AND e.entity_id = p_ent_id;
            pkg_payment.tariff_calc_cache('TARIFF_GETATTR_VS_' || p_ent_id || ' ' || p_attr_id) := v_s;
          END IF;
          EXECUTE IMMEDIATE 'Begin ' || v_s || '; end;'
            USING OUT v_result, IN p_obj_id;
        
        WHEN v_at_brief = 'S_FUNC' THEN
          v_result := calc_fun(v_tariff_id, p_ent_id, p_obj_id);
        ELSE
          NULL;
      END CASE;
    END;
    RETURN V_RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;

  --Возвращает ИД коэффициента
  FUNCTION calc_coeff
  (
    p_id       IN NUMBER
   ,p_attrs    attr_type
   ,p_attr_num NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    r        NUMBER;
    v_c      NUMBER;
    TYPE comp_t IS TABLE OF VARCHAR2(2) INDEX BY PLS_INTEGER;
    v_comporator comp_t;
    v_sql        VARCHAR2(2000);
    v_sql2       VARCHAR2(1000);
    v_attr       VARCHAR2(20);
  BEGIN
    --Получим     
    SELECT (SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_1)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_2)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_3)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_4)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_5)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_6)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_7)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_8)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_9)
          ,(SELECT comporator FROM t_comporator_type WHERE comporator_id = pct.comparator_10)
      INTO v_comporator(1)
          ,v_comporator(2)
          ,v_comporator(3)
          ,v_comporator(4)
          ,v_comporator(5)
          ,v_comporator(6)
          ,v_comporator(7)
          ,v_comporator(8)
          ,v_comporator(9)
          ,v_comporator(10)
      FROM T_PROD_COEF_TYPE pct
     WHERE pct.t_prod_coef_type_id = p_id;
  
    v_sql := 'begin
            SELECT val
              into :val
              FROM (SELECT val
                      FROM T_PROD_COEF_TYPE pct,
                           T_PROD_COEF      pc                    
                     WHERE pct.t_prod_coef_type_id =' || p_id || '
                       AND pc.t_prod_coef_type_id = pct.t_prod_coef_type_id';
  
    FOR r IN 1 .. p_attr_num
    LOOP
      IF p_attrs(r) IS NULL
      THEN
        v_attr := 'NULL';
      ELSE
        v_attr := p_attrs(r);
      END IF;
      v_sql := v_sql || '
      AND pc.criteria_' || r || ' ' || v_comporator(r) || v_attr;
      IF r = 1
      THEN
        v_sql2 := ' 
                   ORDER BY pc.criteria_1';
      ELSE
        v_sql2 := v_sql2 || ' ,pc.criteria_' || r;
      END IF;
    END LOOP;
    v_sql := v_sql || v_sql2 || ') where rownum=1;
                             end;';
  
    EXECUTE IMMEDIATE v_sql
      USING OUT v_result;
  
    IF p_attr_num = 0
    THEN
      SELECT COUNT(*)
        INTO v_c
        FROM T_PROD_COEF_TYPE pc
       WHERE pc.factor_1 IS NULL
         AND pc.factor_2 IS NULL
         AND pc.factor_3 IS NULL
         AND pc.factor_4 IS NULL
         AND pc.factor_5 IS NULL
         AND pc.factor_6 IS NULL
         AND pc.factor_7 IS NULL
         AND pc.factor_8 IS NULL
         AND pc.factor_9 IS NULL
         AND pc.factor_10 IS NULL
         AND pc.t_prod_coef_type_id = p_id;
      IF v_c = 1
      THEN
        SELECT t.val
          INTO v_result
          FROM (SELECT pc.t_prod_coef_id val
                  FROM T_PROD_COEF_TYPE pct
                      ,T_PROD_COEF      pc
                 WHERE pct.t_prod_coef_type_id = p_id
                   AND pc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                 ORDER BY pc.criteria_1 DESC) t
         WHERE ROWNUM = 1;
      ELSE
        NULL;
      END IF;
    END IF;
  
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  --Возвращает значение коэффициента
  FUNCTION calc_coeff_val
  (
    p_id       IN NUMBER
   ,P_attrs    attr_type
   ,p_attr_num NUMBER
  ) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    v_result := calc_coeff(p_id, P_attrs, p_attr_num);
  
    RETURN v_result;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END calc_coeff_val;

  FUNCTION calc_coeff_val
  (
    p_brief    IN VARCHAR2
   ,P_attrs    attr_type
   ,p_attr_num NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_id     NUMBER;
  BEGIN
  
    SELECT t.t_prod_coef_type_id INTO v_id FROM T_PROD_COEF_TYPE t WHERE t.brief = p_brief;
  
    v_result := calc_coeff(v_id, P_attrs, p_attr_num);
  
    RETURN v_result;
  END calc_coeff_val;

  FUNCTION calc_fun
  (
    p_id     IN NUMBER
   ,p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER AS
    v_result           NUMBER;
    v_sql              VARCHAR2(1000);
    v_sql_parse        VARCHAR2(1000);
    v_func_define_type VARCHAR2(30);
    v_other            NUMBER;
    v_brief            VARCHAR2(30);
    attrs              attr_type;
    v_attr_num         NUMBER;
    f1                 NUMBER;
    f2                 NUMBER;
    f3                 NUMBER;
    f4                 NUMBER;
    f5                 NUMBER;
    f6                 NUMBER;
    f7                 NUMBER;
    f8                 NUMBER;
    f9                 NUMBER;
    f10                NUMBER;
    i                  INTEGER;
    c                  INTEGER;
  BEGIN
    -- тип определения фукнции (константа - пока не сделано, табличная фукнция, pl\sql или правило)
    -- пока тип фукнции определеем по заданным полям
    SELECT ct.r_sql
          ,ct.sub_t_prod_coef_type_id
          ,fdt.brief
      INTO v_sql
          ,v_other
          ,v_func_define_type
      FROM T_PROD_COEF_TYPE ct
          ,FUNC_DEFINE_TYPE fdt
     WHERE ct.t_prod_coef_type_id = p_id
       AND ct.func_define_type_id = fdt.func_define_type_id;
  
    IF v_func_define_type = 'CONST'
    THEN
      IF v_sql = 'NULL'
      THEN
        RETURN NULL;
      ELSE
        BEGIN
          v_result := v_sql;
        EXCEPTION
          WHEN OTHERS THEN
            v_result := TO_NUMBER(v_sql, '999999D99999999999', ' NLS_NUMERIC_CHARACTERS = '',.'' ');
        END;
      
        RETURN v_result;
      
      END IF;
    END IF;
  
    --Оперделяем типы параметров функции
    SELECT t.brief
          ,t.factor_1
          ,t.factor_2
          ,t.factor_3
          ,t.factor_4
          ,t.factor_5
          ,t.factor_6
          ,t.factor_7
          ,t.factor_8
          ,t.factor_9
          ,t.factor_10
          ,NVL2(t.factor_1, 1, 0) + NVL2(t.factor_2, 1, 0) + NVL2(t.factor_3, 1, 0) +
           NVL2(t.factor_4, 1, 0) + NVL2(t.factor_5, 1, 0) + NVL2(t.factor_6, 1, 0) +
           NVL2(t.factor_7, 1, 0) + NVL2(t.factor_8, 1, 0) + NVL2(t.factor_9, 1, 0) +
           NVL2(t.factor_10, 1, 0)
      INTO v_brief
          ,f1
          ,f2
          ,f3
          ,f4
          ,f5
          ,f6
          ,f7
          ,f8
          ,f9
          ,f10
          ,v_attr_num
      FROM T_PROD_COEF_TYPE t
     WHERE t.t_prod_coef_type_id = p_id;
  
    --Получаем значения параметров функции
    attrs(1) := get_attribut(p_ent_id, p_obj_id, f1);
    attrs(2) := get_attribut(p_ent_id, p_obj_id, f2);
    attrs(3) := get_attribut(p_ent_id, p_obj_id, f3);
    attrs(4) := get_attribut(p_ent_id, p_obj_id, f4);
    attrs(5) := get_attribut(p_ent_id, p_obj_id, f5);
    attrs(6) := get_attribut(p_ent_id, p_obj_id, f6);
    attrs(7) := get_attribut(p_ent_id, p_obj_id, f7);
    attrs(8) := get_attribut(p_ent_id, p_obj_id, f8);
    attrs(9) := get_attribut(p_ent_id, p_obj_id, f9);
    attrs(10) := get_attribut(p_ent_id, p_obj_id, f10);
  
    IF v_func_define_type = 'TABLE_OF_VALUES'
    THEN
    
      v_result := calc_coeff(p_id, attrs, v_attr_num);
    
    ELSIF v_func_define_type = 'PLSQL'
    THEN
      v_sql_parse := 'begin :v_res := ' || v_sql || '(';
    
      FOR i IN 1 .. v_attr_num
      LOOP
        IF i = 1
        THEN
          v_sql_parse := v_sql_parse || ':p1';
        ELSE
          v_sql_parse := v_sql_parse || ',:p' || i;
        END IF;
      END LOOP;
      IF attrs.COUNT = 0
      THEN
        v_sql_parse := v_sql_parse || ':p0';
      END IF;
    
      v_sql_parse := v_sql_parse || '); end;';
    
      c := DBMS_SQL.OPEN_CURSOR;
      BEGIN
        DBMS_SQL.PARSE(c, v_sql_parse, dbms_sql.native);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Ошибка синтаксического разбора PL\SQL функции ');
      END;
    
      FOR i IN 1 .. v_attr_num
      LOOP
        DBMS_SQL.BIND_VARIABLE(c, 'p' || i, attrs(i));
      END LOOP;
      IF attrs.COUNT = 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p0', p_obj_id);
      END IF;
      DBMS_SQL.BIND_VARIABLE(c, 'v_res', v_result);
    
      BEGIN
        i := DBMS_SQL.EXECUTE(c);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_SQL.CLOSE_CURSOR(c);
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Ошибка вычисления PL\SQL функции ' || i);
      END;
      DBMS_SQL.VARIABLE_VALUE(c, 'v_res', v_result);
      DBMS_SQL.CLOSE_CURSOR(c);
    ELSE
      RAISE_APPLICATION_ERROR(-20000
                             ,'Неизвестный тип определения функции');
    END IF;
  
    IF v_result IS NULL
       AND v_other IS NOT NULL
    THEN
      v_result := calc_fun(v_other, p_ent_id, p_obj_id);
    ELSE
      NULL;
    END IF;
  
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END calc_fun;

  FUNCTION calc_fun
  (
    p_brief  IN VARCHAR2
   ,p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER AS
    v_result NUMBER;
    v_id     NUMBER;
  BEGIN
  
    SELECT t.t_prod_coef_type_id INTO v_id FROM T_PROD_COEF_TYPE t WHERE t.brief = p_brief;
    v_result := calc_fun(v_id, p_ent_id, p_obj_id);
    RETURN v_result;
  END calc_fun;

END Pkg_Tariff_Calc_NEW;
/
