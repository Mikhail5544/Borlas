CREATE OR REPLACE PACKAGE pkg_tariff_calc IS

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

  FUNCTION calc_coeff_val
  (
    p_brief IN VARCHAR2
   ,p_attrs t_number_type
  ) RETURN NUMBER;

  FUNCTION get_attribut
  (
    p_ent_id  IN NUMBER
   , --Контекст
    p_obj_id  IN NUMBER
   ,p_attr_id IN NUMBER
  ) RETURN NUMBER;

  PROCEDURE run_procedure
  (
    par_prodedure_id t_prod_coef_type.t_prod_coef_type_id%TYPE
   ,par_end_id       entity.ent_id%TYPE
   ,par_obj_id       NUMBER
  );

  PROCEDURE run_procedure
  (
    par_prodedure_brief t_prod_coef_type.brief%TYPE
   ,par_end_id          entity.ent_id%TYPE
   ,par_obj_id          NUMBER
  );

END pkg_tariff_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_tariff_calc IS

  TYPE tt_comporator_info IS RECORD(
     comporator t_comporator_type.comporator%TYPE
    ,order_type t_comporator_type.order_type%TYPE);
  TYPE tt_comporator_cache IS TABLE OF tt_comporator_info INDEX BY PLS_INTEGER;

  gv_comporator_cache tt_comporator_cache;

  SUBTYPE t_attribut_cache_index IS VARCHAR2(50);

  TYPE tt_attribut_info IS RECORD(
     attribut_source_brief t_attribut_source.brief%TYPE
    ,sql_source            t_attribut_entity.obj_list_sql%TYPE
    ,func_id               t_attribut.attr_tarif_id%TYPE);

  TYPE tt_attribut_cache IS TABLE OF tt_attribut_info INDEX BY t_attribut_cache_index;

  gv_attribute_cache tt_attribut_cache;

  FUNCTION get_attr_cache_index
  (
    par_attr_id   t_attribut.t_attribut_id%TYPE
   ,par_entity_id entity.ent_id%TYPE
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'A' || to_char(par_attr_id) || 'E' || to_char(par_entity_id);
  END get_attr_cache_index;

  FUNCTION get_cached_attribut
  (
    par_attr_id   t_attribut.t_attribut_id%TYPE
   ,par_entity_id entity.ent_id%TYPE
  ) RETURN tt_attribut_info IS
    v_attribut_info tt_attribut_info;
    v_cashe_index   t_attribut_cache_index;
  BEGIN
    v_cashe_index := get_attr_cache_index(par_attr_id, par_entity_id);
  
    BEGIN
      v_attribut_info := gv_attribute_cache(v_cashe_index);
    EXCEPTION
      WHEN no_data_found THEN
        SELECT s.brief
              ,(SELECT e.obj_list_sql
                 FROM t_attribut_entity e
                WHERE a.t_attribut_id = e.t_attribut_id
                  AND e.entity_id = par_entity_id)
              ,a.attr_tarif_id
          INTO v_attribut_info.attribut_source_brief
              ,v_attribut_info.sql_source
              ,v_attribut_info.func_id
          FROM t_attribut        a
              ,t_attribut_source s
         WHERE a.t_attribut_id = par_attr_id
           AND a.t_attribut_source_id = s.t_attribut_source_id;
      
        gv_attribute_cache(v_cashe_index) := v_attribut_info;
      
    END;
  
    RETURN v_attribut_info;
  END get_cached_attribut;

  FUNCTION get_attribut
  (
    p_ent_id  IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_attr_id IN NUMBER
  ) RETURN NUMBER AS
    c_attr_source_func    CONSTANT t_attribut_source.brief%TYPE := 'S_FUNC';
    c_attr_source_default CONSTANT t_attribut_source.brief%TYPE := 'S_DEFAULT';
    c_attr_source_ent     CONSTANT t_attribut_source.brief%TYPE := 'S_ENT';
    v_result        NUMBER;
    v_attribut_info tt_attribut_info;
  BEGIN
    IF p_attr_id IS NOT NULL
    THEN
    
      v_attribut_info := get_cached_attribut(par_attr_id => p_attr_id, par_entity_id => p_ent_id);
    
      CASE
        WHEN v_attribut_info.attribut_source_brief IN (c_attr_source_ent, c_attr_source_default)
             AND v_attribut_info.sql_source IS NOT NULL THEN
        
          BEGIN
            EXECUTE IMMEDIATE 'begin ' || v_attribut_info.sql_source || '; end;'
              USING OUT v_result, IN p_obj_id;
          EXCEPTION
            WHEN no_data_found THEN
              RETURN NULL;
          END;
        
        WHEN v_attribut_info.attribut_source_brief = c_attr_source_func
             AND v_attribut_info.func_id IS NOT NULL THEN
          v_result := calc_fun(v_attribut_info.func_id, p_ent_id, p_obj_id);
        ELSE
          NULL;
      END CASE;
    
    END IF;
  
    RETURN v_result;
  END get_attribut;

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
  
    TYPE comp_t IS TABLE OF t_comporator_type.comporator_id%TYPE INDEX BY PLS_INTEGER;
    v_comporator comp_t;
    v_sql        VARCHAR2(2000);
    v_sql2       VARCHAR2(1000);
    v_attr       VARCHAR2(20);
    -- Байтин А.
    v_cursor NUMBER;
    v_rows   NUMBER;
  
    FUNCTION get_sql_query_string RETURN VARCHAR2 IS
      v_sql_inner       VARCHAR2(3000);
      v_sql_outer       VARCHAR2(1000);
      v_comporator_info tt_comporator_info;
    BEGIN
      v_sql_inner := 'begin
            SELECT val
              into :val
              FROM (SELECT val
                      FROM T_PROD_COEF      pc
                     WHERE pc.t_prod_coef_type_id = :p_id';
    
      FOR r IN 1 .. p_attr_num
      LOOP
        v_comporator_info := gv_comporator_cache(v_comporator(r));
        v_sql_inner       := v_sql_inner || '
			AND :p_attr_' || to_char(r) || ' ' || v_comporator_info.comporator ||
                             ' pc.criteria_' || to_char(r);
        IF r = 1
        THEN
          v_sql_outer := ' 
                   ORDER BY ';
        ELSE
          v_sql_outer := v_sql_outer || ' ,';
        END IF;
        v_sql_outer := v_sql_outer || 'pc.criteria_' || to_char(r) || ' ' ||
                       v_comporator_info.order_type;
      END LOOP;
    
      RETURN v_sql_inner || v_sql_outer || ') where rownum=1;
                             exception when NO_DATA_FOUND then :val:=null;
                             end;';
    
    END get_sql_query_string;
  BEGIN
    --Получим     
    SELECT pct.comparator_1
          ,pct.comparator_2
          ,pct.comparator_3
          ,pct.comparator_4
          ,pct.comparator_5
          ,pct.comparator_6
          ,pct.comparator_7
          ,pct.comparator_8
          ,pct.comparator_9
          ,pct.comparator_10
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
      FROM t_prod_coef_type pct
     WHERE pct.t_prod_coef_type_id = p_id;
  
    BEGIN
      v_cursor := dbms_sql.open_cursor;
    
      v_sql := get_sql_query_string;
      dbms_sql.parse(v_cursor, v_sql, dbms_sql.native);
    
      dbms_sql.bind_variable(v_cursor, ':val', v_result);
      dbms_sql.bind_variable(v_cursor, ':p_id', p_id);
      FOR r IN 1 .. p_attr_num
      LOOP
        dbms_sql.bind_variable(v_cursor, ':p_attr_' || to_char(r), p_attrs(r));
      END LOOP;
    
      v_rows := dbms_sql.execute(v_cursor);
    
      dbms_sql.variable_value(v_cursor, ':val', v_result);
    
      dbms_sql.close_cursor(v_cursor);
    EXCEPTION
      WHEN OTHERS THEN
        IF dbms_sql.is_open(v_cursor)
        THEN
          dbms_sql.close_cursor(v_cursor);
        END IF;
        RAISE;
    END;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END calc_coeff;

  --Возвращает значение коэффициента
  FUNCTION calc_coeff_val
  (
    p_id       IN NUMBER
   ,p_attrs    attr_type
   ,p_attr_num NUMBER
  ) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    v_result := calc_coeff(p_id, p_attrs, p_attr_num);
  
    RETURN v_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END calc_coeff_val;

  FUNCTION calc_coeff_val
  (
    p_brief    IN VARCHAR2
   ,p_attrs    attr_type
   ,p_attr_num NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_id     NUMBER;
  BEGIN
  
    SELECT t.t_prod_coef_type_id INTO v_id FROM t_prod_coef_type t WHERE t.brief = p_brief;
  
    v_result := calc_coeff(v_id, p_attrs, p_attr_num);
  
    RETURN v_result;
  END calc_coeff_val;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.06.2009 10:40:47
  -- Purpose : Возвращает значение коэффициента - как параметр используя sql тип
  FUNCTION calc_coeff_val
  (
    p_brief IN VARCHAR2
   ,p_attrs t_number_type
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'calc_coeff_val';
    v_attrs   pkg_tariff_calc.attr_type;
    i         PLS_INTEGER;
  BEGIN
    FOR i IN 1 .. p_attrs.count
    LOOP
      v_attrs(i) := p_attrs(i);
    END LOOP;
  
    RESULT := pkg_tariff_calc.calc_coeff_val(p_brief, v_attrs, p_attrs.count);
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END;

  FUNCTION run
  (
    par_id                     t_prod_coef_type.t_prod_coef_type_id%TYPE
   ,par_ent_id                 entity.ent_id%TYPE
   ,par_obj_id                 NUMBER
   ,par_dunc_define_type_breif func_define_type.brief%TYPE
  ) RETURN NUMBER IS
    v_result    NUMBER;
    v_sql       t_prod_coef_type.r_sql%TYPE;
    v_sql_parse VARCHAR2(4000);
    attrs       attr_type;
    v_brief     t_prod_coef_type.brief%TYPE;
    v_attr_num  INTEGER;
    i           INTEGER;
    c           INTEGER;
    v_factors   t_number_type;
  BEGIN
    SELECT t.brief
          ,t.r_sql
          ,t_number_type(t.factor_1
                        ,t.factor_2
                        ,t.factor_3
                        ,t.factor_4
                        ,t.factor_5
                        ,t.factor_6
                        ,t.factor_7
                        ,t.factor_8
                        ,t.factor_9
                        ,t.factor_10)
          ,nvl2(t.factor_1, 1, 0) + nvl2(t.factor_2, 1, 0) + nvl2(t.factor_3, 1, 0) +
           nvl2(t.factor_4, 1, 0) + nvl2(t.factor_5, 1, 0) + nvl2(t.factor_6, 1, 0) +
           nvl2(t.factor_7, 1, 0) + nvl2(t.factor_8, 1, 0) + nvl2(t.factor_9, 1, 0) +
           nvl2(t.factor_10, 1, 0)
      INTO v_brief
          ,v_sql
          ,v_factors
          ,v_attr_num
      FROM t_prod_coef_type t
     WHERE t.t_prod_coef_type_id = par_id;
  
    IF par_dunc_define_type_breif = pkg_prod_coef.gc_func_def_type_constant
    THEN
      IF v_sql = 'NULL'
      THEN
        v_result := NULL;
      ELSE
        BEGIN
          v_result := to_number(v_sql
                               ,'99999999999999999999999999999D9999999999999999999999999999'
                               ,' NLS_NUMERIC_CHARACTERS = '',.'' ');
        EXCEPTION
          WHEN pkg_oracle_exceptions.invalid_number THEN
            v_result := to_number(v_sql
                                 ,'99999999999999999999999999999D9999999999999999999999999999'
                                 ,' NLS_NUMERIC_CHARACTERS = ''. '' ');
        END;
      
      END IF;
    ELSE
    
      --Получаем значения параметров функции
      FOR i IN 1 .. v_factors.count
      LOOP
        attrs(i) := get_attribut(par_ent_id, par_obj_id, v_factors(i));
      END LOOP;
    
      IF par_dunc_define_type_breif = pkg_prod_coef.gc_func_def_type_table_of_val
      THEN
        --Табличная функция
        v_result := calc_coeff(par_id, attrs, v_attr_num);
      
      ELSIF par_dunc_define_type_breif IN
            (pkg_prod_coef.gc_func_def_type_plsql_func, pkg_prod_coef.gc_func_def_type_plsql_proc)
      THEN
        BEGIN
        
          -- PLSQL Функция или процедура
          IF par_dunc_define_type_breif = pkg_prod_coef.gc_func_def_type_plsql_func
          THEN
            v_sql_parse := 'begin :v_res := ' || v_sql || '(';
          ELSE
            v_sql_parse := 'begin ' || v_sql || '(';
          END IF;
        
          FOR i IN 1 .. v_attr_num
          LOOP
            IF i = 1
            THEN
              v_sql_parse := v_sql_parse || ':p1';
            ELSE
              v_sql_parse := v_sql_parse || ',:p' || i;
            END IF;
          END LOOP;
        
          IF v_attr_num = 0
          THEN
            v_sql_parse := v_sql_parse || ':p0';
          END IF;
        
          v_sql_parse := v_sql_parse || '); end;';
        
          c := dbms_sql.open_cursor;
          BEGIN
            dbms_sql.parse(c, v_sql_parse, dbms_sql.native);
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20000
                                     ,'Ошибка синтаксического разбора PL\SQL функции ');
          END;
        
          FOR i IN 1 .. v_attr_num
          LOOP
            dbms_sql.bind_variable(c, 'p' || i, attrs(i));
          END LOOP;
        
          IF v_attr_num = 0
          THEN
            dbms_sql.bind_variable(c, 'p0', par_obj_id);
          END IF;
        
          IF par_dunc_define_type_breif = pkg_prod_coef.gc_func_def_type_plsql_func
          THEN
            dbms_sql.bind_variable(c, 'v_res', v_result);
          END IF;
        
          i := dbms_sql.execute(c);
          IF par_dunc_define_type_breif = pkg_prod_coef.gc_func_def_type_plsql_func
          THEN
            dbms_sql.variable_value(c, 'v_res', v_result);
          END IF;
          dbms_sql.close_cursor(c);
        EXCEPTION
          WHEN OTHERS THEN
            IF dbms_sql.is_open(c)
            THEN
              dbms_sql.close_cursor(c);
            END IF;
            RAISE;
        END;
      ELSE
        raise_application_error(-20000
                               ,'Неизвестный тип определения функции');
      END IF;
    END IF;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END run;

  FUNCTION calc_fun
  (
    p_id     IN NUMBER
   ,p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER AS
    v_result                 NUMBER;
    v_func_define_type_brief func_define_type.brief%TYPE;
    v_other                  t_prod_coef_type.sub_t_prod_coef_type_id%TYPE;
  BEGIN
    -- тип определения фукнции (константа - пока не сделано, табличная фукнция, pl\sql или правило)
    -- пока тип фукнции определеем по заданным полям
    SELECT ct.sub_t_prod_coef_type_id
          ,fdt.brief
      INTO v_other
          ,v_func_define_type_brief
      FROM t_prod_coef_type ct
          ,func_define_type fdt
     WHERE ct.t_prod_coef_type_id = p_id
       AND ct.func_define_type_id = fdt.func_define_type_id;
  
    assert_deprecated(v_func_define_type_brief = pkg_prod_coef.gc_func_def_type_plsql_proc
          ,'Не верный типа вызываемой функции');
  
    v_result := run(par_id                     => p_id
                   ,par_ent_id                 => p_ent_id
                   ,par_obj_id                 => p_obj_id
                   ,par_dunc_define_type_breif => v_func_define_type_brief);
  
    IF v_result IS NULL
       AND v_other IS NOT NULL
    THEN
      v_result := calc_fun(v_other, p_ent_id, p_obj_id);
    END IF;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
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
    v_id := dml_t_prod_coef_type.get_id_by_brief(par_brief => p_brief);
  
    v_result := calc_fun(v_id, p_ent_id, p_obj_id);
  
    RETURN v_result;
  
  END calc_fun;

  PROCEDURE run_procedure
  (
    par_prodedure_id t_prod_coef_type.t_prod_coef_type_id%TYPE
   ,par_end_id       entity.ent_id%TYPE
   ,par_obj_id       NUMBER
  ) IS
    v_dummy                  NUMBER;
    v_sql                    t_prod_coef_type.r_sql%TYPE;
    v_func_define_type_brief func_define_type.brief%TYPE;
  BEGIN
  
    SELECT ct.r_sql
          ,fdt.brief
      INTO v_sql
          ,v_func_define_type_brief
      FROM t_prod_coef_type ct
          ,func_define_type fdt
     WHERE ct.t_prod_coef_type_id = par_prodedure_id
       AND ct.func_define_type_id = fdt.func_define_type_id;
  
    assert_deprecated(v_func_define_type_brief != pkg_prod_coef.gc_func_def_type_plsql_proc
          ,'Не верный типа динамической процедуры');
    assert_deprecated(v_sql IS NULL
          ,'Должна быть указана процедура для вызова');
  
    v_dummy := run(par_id                     => par_prodedure_id
                  ,par_ent_id                 => par_end_id
                  ,par_obj_id                 => par_obj_id
                  ,par_dunc_define_type_breif => v_func_define_type_brief);
  
  END run_procedure;

  PROCEDURE run_procedure
  (
    par_prodedure_brief t_prod_coef_type.brief%TYPE
   ,par_end_id          entity.ent_id%TYPE
   ,par_obj_id          NUMBER
  ) IS
    v_prod_coef_type_id t_prod_coef_type.t_prod_coef_type_id%TYPE;
  BEGIN
    v_prod_coef_type_id := dml_t_prod_coef_type.get_id_by_brief(par_brief => par_prodedure_brief);
  
    run_procedure(par_prodedure_id => v_prod_coef_type_id
                 ,par_end_id       => par_end_id
                 ,par_obj_id       => par_obj_id);
  
  END run_procedure;

BEGIN
  FOR rec_comporator IN (SELECT ct.comporator_id
                               ,ct.comporator
                               ,ct.order_type
                           FROM t_comporator_type ct
                          ORDER BY ct.comporator_id)
  LOOP
    gv_comporator_cache(rec_comporator.comporator_id).comporator := rec_comporator.comporator;
    gv_comporator_cache(rec_comporator.comporator_id).order_type := rec_comporator.order_type;
  END LOOP;

END pkg_tariff_calc;
/
