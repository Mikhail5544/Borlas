CREATE OR REPLACE PACKAGE pkg_tariff_calc_OLD IS

  /**
  * Пакет расчета тарифов универсальный
  * @author Budkova A.
  * @version 1
  */

  /**
  *Возвращает значение коэффициента по ИД тарифа
  * @author Budkova A.
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
  /**
  *Возвращает значение коэффициента по brief тарифа
  * @author Budkova A.
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

  /**
  * Возврашает значение коэффициента
  * @depricated - УСТАРЕВШАЯ ФУНКЦИЯ - не использовать! (Ivanov D.)
  * @author Budkova A.
  * @param
  * @return
  */
  FUNCTION calc_coeff_val
  (
    p_brief IN VARCHAR2
   ,p_num   IN NUMBER
   ,p_sc_1  IN NUMBER DEFAULT NULL
   ,p_sc_2  IN NUMBER DEFAULT NULL
   ,p_sc_3  IN NUMBER DEFAULT NULL
   ,p_sc_4  IN NUMBER DEFAULT NULL
   ,p_sc_5  IN NUMBER DEFAULT NULL
   ,p_sc_6  IN NUMBER DEFAULT NULL
   ,p_sc_7  IN NUMBER DEFAULT NULL
   ,p_sc_8  IN NUMBER DEFAULT NULL
   ,p_sc_9  IN NUMBER DEFAULT NULL
   ,p_sc_10 IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_attribut
  (
    p_ent_id  IN NUMBER
   , --Контекст
    p_obj_id  IN NUMBER
   ,p_attr_id IN NUMBER
  ) RETURN NUMBER;

END pkg_tariff_calc_OLD;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Tariff_Calc_old IS

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
    --DBMS_OUTPUT.PUT(' get_attribut '||p_ent_id||' '||p_obj_id||' '||p_attr_id);
  
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
    --DBMS_OUTPUT.PUT(' get_attribut v_at_brief '||v_at_brief||' v_tariff_id '||v_tariff_id);
  
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
      -- exception
      --  when others then
      --     DBMS_OUTPUT.PUT_LINE(sqlerrm);
    END;
    RETURN V_RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;

  /*  --Возвращает ИД коэффициента
    FUNCTION calc_coeff(p_id IN NUMBER,
                        p_num   IN NUMBER,
                        p_sc_1  IN NUMBER DEFAULT NULL,
                        p_sc_2  IN NUMBER DEFAULT NULL,
                        p_sc_3  IN NUMBER DEFAULT NULL,
                        p_sc_4  IN NUMBER DEFAULT NULL,
                        p_sc_5  IN NUMBER DEFAULT NULL,
                        p_sc_6  IN NUMBER DEFAULT NULL,
                        p_sc_7  IN NUMBER DEFAULT NULL,
                        p_sc_8  IN NUMBER DEFAULT NULL,
                        p_sc_9  IN NUMBER DEFAULT NULL,
                        p_sc_10  IN NUMBER DEFAULT NULL) RETURN NUMBER AS
      v_result NUMBER;
      v_c NUMBER;
    BEGIN
      
      IF p_num = 0 THEN
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
           IF v_c=1 THEN
              SELECT t.val
                INTO v_result
                FROM (SELECT pc.t_prod_coef_id val
                        FROM T_PROD_COEF_TYPE pct, T_PROD_COEF pc
                       WHERE pct.t_prod_coef_type_id = p_id
                         AND pc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                       ORDER BY pc.criteria_1 DESC) t
               WHERE ROWNUM = 1;
           ELSE NULL;
           END IF;
      ELSIF p_num = 1 THEN
  --@ 2007.06.12 Marchuk A. Исправлено по pct.comparator_1 = 2. До этого сравнения были неправильными
        SELECT t.val
          INTO v_result
          FROM (       
          SELECT pc.t_prod_coef_id val
                  FROM T_PROD_COEF_TYPE pct, T_PROD_COEF pc
                 WHERE pct.t_prod_coef_type_id = p_id
                   AND pc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                   AND ((pct.comparator_1 = 1 AND pc.criteria_1 = TO_NUMBER(p_sc_1))
                       OR ((pct.comparator_1 = 2 AND pc.criteria_1 <=(SELECT MIN(c.criteria_1)
                                                                 FROM T_PROD_COEF c
                                                                 WHERE c.t_prod_coef_type_id=pct.t_prod_coef_type_id
                                                                   AND c.criteria_1>=TO_NUMBER(p_sc_1)))
                          AND (pct.comparator_1 = 2 AND pc.criteria_1 >=TO_NUMBER(p_sc_1))
                        ))        
                 ORDER BY pc.criteria_1 DESC) t
         WHERE ROWNUM = 1;
   
      ELSIF p_num = 2 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         ( SELECT t.t_prod_coef_id
           FROM (
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   ) t
            ORDER BY t.criteria_1, t.criteria_2
          )tt
       WHERE ROWNUM = 1;
   
      ELSIF p_num = 3 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         ( SELECT t.t_prod_coef_id
           FROM (
                 SELECT *
                          FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                         WHERE pct1.t_prod_coef_type_id = p_id
                           AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                           AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                               (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                 INTERSECT
                 SELECT *
                          FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                         WHERE pct2.t_prod_coef_type_id = p_id
                           AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                          AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                              (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                 INTERSECT
                  SELECT *
                          FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                         WHERE pct3.t_prod_coef_type_id = p_id
                           AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                          AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                              (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                 ) t
              ORDER BY t.criteria_1, t.criteria_2, t.criteria_3
             )tt
           WHERE ROWNUM = 1 ;
   
      ELSIF p_num = 4 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id = p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = TO_NUMBER(p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= TO_NUMBER(p_sc_4)))
                   ) t
            ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4
         )tt
         WHERE ROWNUM = 1;
   
      ELSIF p_num = 5 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id = p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = TO_NUMBER(p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= TO_NUMBER(p_sc_4)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct5, T_PROD_COEF pc5
                           WHERE pct5.t_prod_coef_type_id = p_id
                             AND pc5.t_prod_coef_type_id = pct5.t_prod_coef_type_id
                            AND ((pct5.comparator_5 = 1 AND pc5.criteria_5 = TO_NUMBER(p_sc_5)) OR
                                (pct5.comparator_5 = 2 AND pc5.criteria_5 >= TO_NUMBER(p_sc_5)))
                   ) t
             ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4, t.criteria_5
          )tt
        WHERE ROWNUM = 1 ;
   
  
  --@ 2007.06.12 Marchuk A. Исправлено по pct3.comparator_3=(3-10). Ранее везде было указано pct(3-10).comparator_2 2.
  --  
      ELSIF p_num = 6 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = (p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= (p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = (p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= (p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = (p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= (p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id = p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = (p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= (p_sc_4)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct5, T_PROD_COEF pc5
                           WHERE pct5.t_prod_coef_type_id = p_id
                             AND pc5.t_prod_coef_type_id = pct5.t_prod_coef_type_id
                            AND ((pct5.comparator_5 = 1 AND pc5.criteria_5 = (p_sc_5)) OR
                                (pct5.comparator_5 = 2 AND pc5.criteria_5 >= (p_sc_5)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct6, T_PROD_COEF pc6
                           WHERE pct6.t_prod_coef_type_id = p_id
                             AND pc6.t_prod_coef_type_id = pct6.t_prod_coef_type_id
                            AND ((pct6.comparator_6 = 1 AND pc6.criteria_6 = (p_sc_6)) OR
                                (pct6.comparator_6 = 2 AND pc6.criteria_6 >= (p_sc_6)))
                   ) t
             ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4, t.criteria_5,t.criteria_6
          )tt
        WHERE ROWNUM = 1 ;
      ELSIF p_num = 7 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id = p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = TO_NUMBER(p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= TO_NUMBER(p_sc_4)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct5, T_PROD_COEF pc5
                           WHERE pct5.t_prod_coef_type_id = p_id
                             AND pc5.t_prod_coef_type_id = pct5.t_prod_coef_type_id
                            AND ((pct5.comparator_5 = 1 AND pc5.criteria_5 = TO_NUMBER(p_sc_5)) OR
                                (pct5.comparator_5 = 2 AND pc5.criteria_5 >= TO_NUMBER(p_sc_5)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct6, T_PROD_COEF pc6
                           WHERE pct6.t_prod_coef_type_id = p_id
                             AND pc6.t_prod_coef_type_id = pct6.t_prod_coef_type_id
                            AND ((pct6.comparator_6 = 1 AND pc6.criteria_6 = TO_NUMBER(p_sc_6)) OR
                                (pct6.comparator_6 = 2 AND pc6.criteria_6 >= TO_NUMBER(p_sc_6)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct7, T_PROD_COEF pc7
                           WHERE pct7.t_prod_coef_type_id = p_id
                             AND pc7.t_prod_coef_type_id = pct7.t_prod_coef_type_id
                            AND ((pct7.comparator_7 = 1 AND pc7.criteria_7 = TO_NUMBER(p_sc_7)) OR
                                (pct7.comparator_7 = 2 AND pc7.criteria_7 >= TO_NUMBER(p_sc_7)))
                   ) t
               ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4, t.criteria_5
                        ,t.criteria_6,t.criteria_7
          )tt
        WHERE ROWNUM = 1 ;
      ELSIF p_num = 8 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
   
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id = p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = TO_NUMBER(p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= TO_NUMBER(p_sc_4)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct5, T_PROD_COEF pc5
                           WHERE pct5.t_prod_coef_type_id = p_id
                             AND pc5.t_prod_coef_type_id = pct5.t_prod_coef_type_id
                            AND ((pct5.comparator_5 = 1 AND pc5.criteria_5 = TO_NUMBER(p_sc_5)) OR
                                (pct5.comparator_5 = 2 AND pc5.criteria_5 >= TO_NUMBER(p_sc_5)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct6, T_PROD_COEF pc6
                           WHERE pct6.t_prod_coef_type_id = p_id
                             AND pc6.t_prod_coef_type_id = pct6.t_prod_coef_type_id
                            AND ((pct6.comparator_6 = 1 AND pc6.criteria_6 = TO_NUMBER(p_sc_6)) OR
                                (pct6.comparator_6 = 2 AND pc6.criteria_6 >= TO_NUMBER(p_sc_6)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct7, T_PROD_COEF pc7
                           WHERE pct7.t_prod_coef_type_id = p_id
                             AND pc7.t_prod_coef_type_id = pct7.t_prod_coef_type_id
                            AND ((pct7.comparator_7 = 1 AND pc7.criteria_7 = TO_NUMBER(p_sc_7)) OR
                                (pct7.comparator_7 = 2 AND pc7.criteria_7 >= TO_NUMBER(p_sc_7)))
                    INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct8, T_PROD_COEF pc8
                           WHERE pct8.t_prod_coef_type_id = p_id
                             AND pc8.t_prod_coef_type_id = pct8.t_prod_coef_type_id
                            AND ((pct8.comparator_8 = 1 AND pc8.criteria_8 = TO_NUMBER(p_sc_8)) OR
                                (pct8.comparator_8 = 2 AND pc8.criteria_8 >= TO_NUMBER(p_sc_8)))
                   ) t
               ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4, t.criteria_5
                        ,t.criteria_6,t.criteria_7, t.criteria_8
          )tt
        WHERE ROWNUM = 1 ;
      ELSIF p_num = 9 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
   
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id= p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = TO_NUMBER(p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= TO_NUMBER(p_sc_4)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct5, T_PROD_COEF pc5
                           WHERE pct5.t_prod_coef_type_id = p_id
                             AND pc5.t_prod_coef_type_id = pct5.t_prod_coef_type_id
                            AND ((pct5.comparator_5 = 1 AND pc5.criteria_5 = TO_NUMBER(p_sc_5)) OR
                                (pct5.comparator_5 = 2 AND pc5.criteria_5 >= TO_NUMBER(p_sc_5)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct6, T_PROD_COEF pc6
                           WHERE pct6.t_prod_coef_type_id = p_id
                             AND pc6.t_prod_coef_type_id = pct6.t_prod_coef_type_id
                            AND ((pct6.comparator_6 = 1 AND pc6.criteria_6 = TO_NUMBER(p_sc_6)) OR
                                (pct6.comparator_6 = 2 AND pc6.criteria_6 >= TO_NUMBER(p_sc_6)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct7, T_PROD_COEF pc7
                           WHERE pct7.t_prod_coef_type_id = p_id
                             AND pc7.t_prod_coef_type_id = pct7.t_prod_coef_type_id
                            AND ((pct7.comparator_7 = 1 AND pc7.criteria_7 = TO_NUMBER(p_sc_7)) OR
                                (pct7.comparator_7 = 2 AND pc7.criteria_7 >= TO_NUMBER(p_sc_7)))
                    INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct8, T_PROD_COEF pc8
                           WHERE pct8.t_prod_coef_type_id = p_id
                             AND pc8.t_prod_coef_type_id = pct8.t_prod_coef_type_id
                            AND ((pct8.comparator_8 = 1 AND pc8.criteria_8 = TO_NUMBER(p_sc_8)) OR
                                (pct8.comparator_8 = 2 AND pc8.criteria_8 >= TO_NUMBER(p_sc_8)))
                    INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct9, T_PROD_COEF pc9
                           WHERE pct9.t_prod_coef_type_id = p_id
                             AND pc9.t_prod_coef_type_id = pct9.t_prod_coef_type_id
                            AND ((pct9.comparator_9 = 1 AND pc9.criteria_9 = TO_NUMBER(p_sc_9)) OR
                                (pct9.comparator_9 = 2 AND pc9.criteria_9 >= TO_NUMBER(p_sc_9)))
                   ) t
               ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4, t.criteria_5
                        ,t.criteria_6,t.criteria_7, t.criteria_8, t.criteria_9
          )tt
        WHERE ROWNUM = 1 ;
      ELSIF p_num = 10 THEN
       SELECT tt.t_prod_coef_id val
       INTO v_result
       FROM
         (  SELECT t.t_prod_coef_id
            FROM (
   
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct1, T_PROD_COEF pc1
                           WHERE pct1.t_prod_coef_type_id = p_id
                             AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                             AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = TO_NUMBER(p_sc_1)) OR
                                 (pct1.comparator_1 = 2 AND pc1.criteria_1 >= TO_NUMBER(p_sc_1)))
                   INTERSECT
                   SELECT *
                            FROM T_PROD_COEF_TYPE pct2, T_PROD_COEF pc2
                           WHERE pct2.t_prod_coef_type_id = p_id
                             AND pc2.t_prod_coef_type_id = pct2.t_prod_coef_type_id
                            AND ((pct2.comparator_2 = 1 AND pc2.criteria_2 = TO_NUMBER(p_sc_2)) OR
                                (pct2.comparator_2 = 2 AND pc2.criteria_2 >= TO_NUMBER(p_sc_2)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct3, T_PROD_COEF pc3
                           WHERE pct3.t_prod_coef_type_id = p_id
                             AND pc3.t_prod_coef_type_id = pct3.t_prod_coef_type_id
                            AND ((pct3.comparator_3 = 1 AND pc3.criteria_3 = TO_NUMBER(p_sc_3)) OR
                                (pct3.comparator_3 = 2 AND pc3.criteria_3 >= TO_NUMBER(p_sc_3)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct4, T_PROD_COEF pc4
                           WHERE pct4.t_prod_coef_type_id = p_id
                             AND pc4.t_prod_coef_type_id = pct4.t_prod_coef_type_id
                            AND ((pct4.comparator_4 = 1 AND pc4.criteria_4 = TO_NUMBER(p_sc_4)) OR
                                (pct4.comparator_4 = 2 AND pc4.criteria_4 >= TO_NUMBER(p_sc_4)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct5, T_PROD_COEF pc5
                           WHERE pct5.t_prod_coef_type_id = p_id
                             AND pc5.t_prod_coef_type_id = pct5.t_prod_coef_type_id
                            AND ((pct5.comparator_5 = 1 AND pc5.criteria_5 = TO_NUMBER(p_sc_5)) OR
                                (pct5.comparator_5 = 2 AND pc5.criteria_5 >= TO_NUMBER(p_sc_5)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct6, T_PROD_COEF pc6
                           WHERE pct6.t_prod_coef_type_id = p_id
                             AND pc6.t_prod_coef_type_id = pct6.t_prod_coef_type_id
                            AND ((pct6.comparator_6 = 1 AND pc6.criteria_6 = TO_NUMBER(p_sc_6)) OR
                                (pct6.comparator_6 = 2 AND pc6.criteria_6 >= TO_NUMBER(p_sc_6)))
                   INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct7, T_PROD_COEF pc7
                           WHERE pct7.t_prod_coef_type_id = p_id
                             AND pc7.t_prod_coef_type_id = pct7.t_prod_coef_type_id
                            AND ((pct7.comparator_7 = 1 AND pc7.criteria_7 = TO_NUMBER(p_sc_7)) OR
                                (pct7.comparator_7 = 2 AND pc7.criteria_7 >= TO_NUMBER(p_sc_7)))
                    INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct8, T_PROD_COEF pc8
                           WHERE pct8.t_prod_coef_type_id = p_id
                             AND pc8.t_prod_coef_type_id = pct8.t_prod_coef_type_id
                            AND ((pct8.comparator_8 = 1 AND pc8.criteria_8 = TO_NUMBER(p_sc_8)) OR
                                (pct8.comparator_8 = 2 AND pc8.criteria_8 >= TO_NUMBER(p_sc_8)))
                    INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct9, T_PROD_COEF pc9
                           WHERE pct9.t_prod_coef_type_id = p_id
                             AND pc9.t_prod_coef_type_id = pct9.t_prod_coef_type_id
                            AND ((pct9.comparator_9 = 1 AND pc9.criteria_9 = TO_NUMBER(p_sc_9)) OR
                                (pct9.comparator_9 = 2 AND pc9.criteria_9 >= TO_NUMBER(p_sc_9)))
                    INTERSECT
                    SELECT *
                            FROM T_PROD_COEF_TYPE pct10, T_PROD_COEF pc10
                           WHERE pct10.t_prod_coef_type_id = p_id
                             AND pc10.t_prod_coef_type_id = pct10.t_prod_coef_type_id
                            AND ((pct10.comparator_10 = 1 AND pc10.criteria_10 = TO_NUMBER(p_sc_10)) OR
                                (pct10.comparator_10 = 2 AND pc10.criteria_10 >= TO_NUMBER(p_sc_10)))
                   ) t
               ORDER BY t.criteria_1, t.criteria_2, t.criteria_3, t.criteria_4, t.criteria_5
                        ,t.criteria_6,t.criteria_7, t.criteria_8, t.criteria_9, t.criteria_10
          )tt
        WHERE ROWNUM = 1 ;
      ELSE
        RAISE_APPLICATION_ERROR(-20000,
                                'Ошибочное количество критериев поиска значения коэффициента.');
      END IF;
   
      RETURN v_result;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
      WHEN OTHERS THEN
        RAISE;
    END;*/

  --Возвращает ИД коэффициента
  FUNCTION calc_coeff
  (
    p_id    IN NUMBER
   ,p_num   IN NUMBER
   ,p_sc_1  IN NUMBER DEFAULT NULL
   ,p_sc_2  IN NUMBER DEFAULT NULL
   ,p_sc_3  IN NUMBER DEFAULT NULL
   ,p_sc_4  IN NUMBER DEFAULT NULL
   ,p_sc_5  IN NUMBER DEFAULT NULL
   ,p_sc_6  IN NUMBER DEFAULT NULL
   ,p_sc_7  IN NUMBER DEFAULT NULL
   ,p_sc_8  IN NUMBER DEFAULT NULL
   ,p_sc_9  IN NUMBER DEFAULT NULL
   ,p_sc_10 IN NUMBER DEFAULT NULL
  ) RETURN NUMBER AS
    v_result NUMBER;
    v_c      NUMBER;
  BEGIN
  
    IF p_num = 0
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
    ELSIF p_num = 1
    THEN
    
      SELECT t.val
        INTO v_result
        FROM (SELECT pc.t_prod_coef_id val
                FROM T_PROD_COEF_TYPE pct
                    ,T_PROD_COEF      pc
               WHERE pct.t_prod_coef_type_id = p_id
                 AND pc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                 AND ((pct.comparator_1 = 1 AND pc.criteria_1 = p_sc_1) OR
                     ((pct.comparator_1 = 2 AND
                     pc.criteria_1 <= (SELECT MIN(c.criteria_1)
                                            FROM T_PROD_COEF c
                                           WHERE c.t_prod_coef_type_id = pct.t_prod_coef_type_id
                                             AND c.criteria_1 >= p_sc_1)) AND
                     (pct.comparator_1 = 2 AND pc.criteria_1 >= p_sc_1)))
               ORDER BY pc.criteria_1 DESC) t
       WHERE ROWNUM = 1;
      --Каткевич А.Г. переписал запросы.
    ELSIF p_num = 2
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 3
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_4)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 4
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 5
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
                 AND ((pct1.comparator_5 = 1 AND pc1.criteria_5 = p_sc_5) OR
                     (pct1.comparator_5 = 2 AND pc1.criteria_5 >= p_sc_5))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4
                       ,pc1.criteria_5)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 6
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
                 AND ((pct1.comparator_5 = 1 AND pc1.criteria_5 = p_sc_5) OR
                     (pct1.comparator_5 = 2 AND pc1.criteria_5 >= p_sc_5))
                 AND ((pct1.comparator_6 = 1 AND pc1.criteria_6 = p_sc_6) OR
                     (pct1.comparator_6 = 2 AND pc1.criteria_6 >= p_sc_6))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4
                       ,pc1.criteria_5
                       ,pc1.criteria_6)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 7
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
                 AND ((pct1.comparator_5 = 1 AND pc1.criteria_5 = p_sc_5) OR
                     (pct1.comparator_5 = 2 AND pc1.criteria_5 >= p_sc_5))
                 AND ((pct1.comparator_6 = 1 AND pc1.criteria_6 = p_sc_6) OR
                     (pct1.comparator_6 = 2 AND pc1.criteria_6 >= p_sc_6))
                 AND ((pct1.comparator_7 = 1 AND pc1.criteria_7 = p_sc_7) OR
                     (pct1.comparator_7 = 2 AND pc1.criteria_7 >= p_sc_7))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4
                       ,pc1.criteria_5
                       ,pc1.criteria_6
                       ,pc1.criteria_7)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 8
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
                 AND ((pct1.comparator_5 = 1 AND pc1.criteria_5 = p_sc_5) OR
                     (pct1.comparator_5 = 2 AND pc1.criteria_5 >= p_sc_5))
                 AND ((pct1.comparator_6 = 1 AND pc1.criteria_6 = p_sc_6) OR
                     (pct1.comparator_6 = 2 AND pc1.criteria_6 >= p_sc_6))
                 AND ((pct1.comparator_7 = 1 AND pc1.criteria_7 = p_sc_7) OR
                     (pct1.comparator_7 = 2 AND pc1.criteria_7 >= p_sc_7))
                 AND ((pct1.comparator_8 = 1 AND pc1.criteria_8 = p_sc_8) OR
                     (pct1.comparator_8 = 2 AND pc1.criteria_8 >= p_sc_8))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4
                       ,pc1.criteria_5
                       ,pc1.criteria_6
                       ,pc1.criteria_7
                       ,pc1.criteria_8)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 9
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
                 AND ((pct1.comparator_5 = 1 AND pc1.criteria_5 = p_sc_5) OR
                     (pct1.comparator_5 = 2 AND pc1.criteria_5 >= p_sc_5))
                 AND ((pct1.comparator_6 = 1 AND pc1.criteria_6 = p_sc_6) OR
                     (pct1.comparator_6 = 2 AND pc1.criteria_6 >= p_sc_6))
                 AND ((pct1.comparator_7 = 1 AND pc1.criteria_7 = p_sc_7) OR
                     (pct1.comparator_7 = 2 AND pc1.criteria_7 >= p_sc_7))
                 AND ((pct1.comparator_8 = 1 AND pc1.criteria_8 = p_sc_8) OR
                     (pct1.comparator_8 = 2 AND pc1.criteria_8 >= p_sc_8))
                 AND ((pct1.comparator_9 = 1 AND pc1.criteria_9 = p_sc_9) OR
                     (pct1.comparator_9 = 2 AND pc1.criteria_9 >= p_sc_9))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4
                       ,pc1.criteria_5
                       ,pc1.criteria_6
                       ,pc1.criteria_7
                       ,pc1.criteria_8
                       ,pc1.criteria_9)
       WHERE ROWNUM = 1;
    
    ELSIF p_num = 10
    THEN
      SELECT t_prod_coef_id val
        INTO v_result
        FROM (SELECT t_prod_coef_id
                FROM T_PROD_COEF_TYPE pct1
                    ,T_PROD_COEF      pc1
               WHERE pct1.t_prod_coef_type_id = p_id
                 AND pc1.t_prod_coef_type_id = pct1.t_prod_coef_type_id
                 AND ((pct1.comparator_1 = 1 AND pc1.criteria_1 = p_sc_1) OR
                     (pct1.comparator_1 = 2 AND pc1.criteria_1 >= p_sc_1))
                 AND ((pct1.comparator_2 = 1 AND pc1.criteria_2 = p_sc_2) OR
                     (pct1.comparator_2 = 2 AND pc1.criteria_2 >= p_sc_2))
                 AND ((pct1.comparator_3 = 1 AND pc1.criteria_3 = p_sc_3) OR
                     (pct1.comparator_3 = 2 AND pc1.criteria_3 >= p_sc_3))
                 AND ((pct1.comparator_4 = 1 AND pc1.criteria_4 = p_sc_4) OR
                     (pct1.comparator_4 = 2 AND pc1.criteria_4 >= p_sc_4))
                 AND ((pct1.comparator_5 = 1 AND pc1.criteria_5 = p_sc_5) OR
                     (pct1.comparator_5 = 2 AND pc1.criteria_5 >= p_sc_5))
                 AND ((pct1.comparator_6 = 1 AND pc1.criteria_6 = p_sc_6) OR
                     (pct1.comparator_6 = 2 AND pc1.criteria_6 >= p_sc_6))
                 AND ((pct1.comparator_7 = 1 AND pc1.criteria_7 = p_sc_7) OR
                     (pct1.comparator_7 = 2 AND pc1.criteria_7 >= p_sc_7))
                 AND ((pct1.comparator_8 = 1 AND pc1.criteria_8 = p_sc_8) OR
                     (pct1.comparator_8 = 2 AND pc1.criteria_8 >= p_sc_8))
                 AND ((pct1.comparator_9 = 1 AND pc1.criteria_9 = p_sc_9) OR
                     (pct1.comparator_9 = 2 AND pc1.criteria_9 >= p_sc_9))
                 AND ((pct1.comparator_10 = 1 AND pc1.criteria_10 = p_sc_10) OR
                     (pct1.comparator_10 = 2 AND pc1.criteria_10 >= p_sc_10))
               ORDER BY pc1.criteria_1
                       ,pc1.criteria_2
                       ,pc1.criteria_3
                       ,pc1.criteria_4
                       ,pc1.criteria_5
                       ,pc1.criteria_6
                       ,pc1.criteria_7
                       ,pc1.criteria_8
                       ,pc1.criteria_9
                       ,pc1.criteria_10)
       WHERE ROWNUM = 1;
    
    ELSE
      RAISE_APPLICATION_ERROR(-20000
                             ,'Ошибочное количество критериев поиска значения коэффициента.');
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
    p_id    IN NUMBER
   ,p_num   IN NUMBER
   ,p_sc_1  IN NUMBER DEFAULT NULL
   ,p_sc_2  IN NUMBER DEFAULT NULL
   ,p_sc_3  IN NUMBER DEFAULT NULL
   ,p_sc_4  IN NUMBER DEFAULT NULL
   ,p_sc_5  IN NUMBER DEFAULT NULL
   ,p_sc_6  IN NUMBER DEFAULT NULL
   ,p_sc_7  IN NUMBER DEFAULT NULL
   ,p_sc_8  IN NUMBER DEFAULT NULL
   ,p_sc_9  IN NUMBER DEFAULT NULL
   ,p_sc_10 IN NUMBER DEFAULT NULL
  ) RETURN NUMBER AS
    v_result NUMBER;
    v_id     NUMBER;
  BEGIN
    v_id := calc_coeff(p_id
                      ,p_num
                      ,p_sc_1
                      ,p_sc_2
                      ,p_sc_3
                      ,p_sc_4
                      ,p_sc_5
                      ,p_sc_6
                      ,p_sc_7
                      ,p_sc_8
                      ,p_sc_9
                      ,p_sc_10);
  
    SELECT pc.val INTO v_result FROM T_PROD_COEF pc WHERE pc.t_prod_coef_id = v_id;
  
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- raise_application_error(-20013,
      --                         'Коэффициент тарифной ставки не задан. Тариф - '||p_brief||' Значения атрибутов:'||p_sc_1||' '||p_sc_2||' '||p_sc_3||' '||p_sc_4||' '||p_sc_5);
    
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  /**
  * Возврашает значение коэффициента
  * @depricated - УСТАРЕВШАЯ ФУНКЦИЯ - не использовать! (Ivanov D.)
  * @author Budkova A.
  * @param
  * @return
  */
  FUNCTION calc_coeff_val
  (
    p_brief IN VARCHAR2
   ,p_num   IN NUMBER
   ,p_sc_1  IN NUMBER DEFAULT NULL
   ,p_sc_2  IN NUMBER DEFAULT NULL
   ,p_sc_3  IN NUMBER DEFAULT NULL
   ,p_sc_4  IN NUMBER DEFAULT NULL
   ,p_sc_5  IN NUMBER DEFAULT NULL
   ,p_sc_6  IN NUMBER DEFAULT NULL
   ,p_sc_7  IN NUMBER DEFAULT NULL
   ,p_sc_8  IN NUMBER DEFAULT NULL
   ,p_sc_9  IN NUMBER DEFAULT NULL
   ,p_sc_10 IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_id     NUMBER;
  BEGIN
  
    --return 0;
  
    SELECT t.t_prod_coef_type_id INTO v_id FROM T_PROD_COEF_TYPE t WHERE t.brief = p_brief;
    v_result := calc_coeff_val(v_id
                              ,p_num
                              ,p_sc_1
                              ,p_sc_2
                              ,p_sc_3
                              ,p_sc_4
                              ,p_sc_5
                              ,p_sc_6
                              ,p_sc_7
                              ,p_sc_8
                              ,p_sc_9
                              ,p_sc_10);
    RETURN v_result;
  END;

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
    at_1               NUMBER;
    at_2               NUMBER;
    at_3               NUMBER;
    at_4               NUMBER;
    at_5               NUMBER;
    at_6               NUMBER;
    at_7               NUMBER;
    at_8               NUMBER;
    at_9               NUMBER;
    at_10              NUMBER;
    v_num              NUMBER;
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
    n                  INTEGER;
  BEGIN
    ---DBMS_OUTPUT.PUT_LINE(1);
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
  
    ---DBMS_OUTPUT.PUT_LINE(2);
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
    ---DBMS_OUTPUT.PUT_LINE(3);
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
      FROM T_PROD_COEF_TYPE t
     WHERE t.t_prod_coef_type_id = p_id;
  
    --Получаем значения атрибутов
    at_1  := get_attribut(p_ent_id, p_obj_id, f1);
    at_2  := get_attribut(p_ent_id, p_obj_id, f2);
    at_3  := get_attribut(p_ent_id, p_obj_id, f3);
    at_4  := get_attribut(p_ent_id, p_obj_id, f4);
    at_5  := get_attribut(p_ent_id, p_obj_id, f5);
    at_6  := get_attribut(p_ent_id, p_obj_id, f6);
    at_7  := get_attribut(p_ent_id, p_obj_id, f7);
    at_8  := get_attribut(p_ent_id, p_obj_id, f8);
    at_9  := get_attribut(p_ent_id, p_obj_id, f9);
    at_10 := get_attribut(p_ent_id, p_obj_id, f10);
  
    IF v_func_define_type = 'TABLE_OF_VALUES'
    THEN
      -- Получить ИД записи из таблицы значений атрибутов
      SELECT DECODE(at_1, NULL, 0, 1) + DECODE(at_2, NULL, 0, 1) + DECODE(at_3, NULL, 0, 1) +
             DECODE(at_4, NULL, 0, 1) + DECODE(at_5, NULL, 0, 1) + DECODE(at_6, NULL, 0, 1) +
             DECODE(at_7, NULL, 0, 1) + DECODE(at_8, NULL, 0, 1) + DECODE(at_9, NULL, 0, 1) +
             DECODE(at_10, NULL, 0, 1)
        INTO v_num
        FROM dual;
      v_result := calc_coeff_val(p_id
                                ,v_num
                                ,at_1
                                ,at_2
                                ,at_3
                                ,at_4
                                ,at_5
                                ,at_6
                                ,at_7
                                ,at_8
                                ,at_9
                                ,at_10);
    ELSIF v_func_define_type = 'PLSQL'
    THEN
      v_sql_parse := 'begin :v_res := ' || v_sql || '(';
      n           := 0;
      IF f1 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ':p1';
        n           := n + 1;
      END IF;
      IF f2 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p2';
        n           := n + 1;
      END IF;
      IF f3 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p3';
        n           := n + 1;
      END IF;
      IF f4 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p4';
        n           := n + 1;
      END IF;
      IF f5 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p5';
        n           := n + 1;
      END IF;
      IF f6 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p6';
        n           := n + 1;
      END IF;
      IF f7 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p7';
        n           := n + 1;
      END IF;
      IF f8 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p8';
        n           := n + 1;
      END IF;
      IF f9 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p9';
        n           := n + 1;
      END IF;
      IF f10 IS NOT NULL
      THEN
        v_sql_parse := v_sql_parse || ',:p10';
        n           := n + 1;
      END IF;
      IF n = 0
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
    
      IF n = 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p0', p_obj_id);
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p1', at_1);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p2', at_2);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p3', at_3);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p4', at_4);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p5', at_5);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p6', at_6);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p7', at_7);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p8', at_8);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p9', at_9);
        n := n - 1;
      END IF;
      IF n > 0
      THEN
        DBMS_SQL.BIND_VARIABLE(c, 'p10', at_10);
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
      --     WHEN OTHERS THEN dbms_output.put_line(SQLCODE ||'  '|| SQLERRM);RAISE;
  END;

  FUNCTION calc_fun
  (
    p_brief  IN VARCHAR2
   ,p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER AS
    v_result NUMBER;
    v_id     NUMBER;
  BEGIN
  
    --return 0;
  
    SELECT t.t_prod_coef_type_id INTO v_id FROM T_PROD_COEF_TYPE t WHERE t.brief = p_brief;
    v_result := calc_fun(v_id, p_ent_id, p_obj_id);
    RETURN v_result;
  END;

END Pkg_Tariff_Calc_old;
/
