CREATE OR REPLACE PACKAGE pkg_prod_coef IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 11.06.2013 15:10:08
  -- Purpose : Пакет для работы с табличными функциями

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations

  gc_func_def_type_table_of_val CONSTANT func_define_type.brief%TYPE := 'TABLE_OF_VALUES';
  gc_func_def_type_constant     CONSTANT func_define_type.brief%TYPE := 'CONST';
  gc_func_def_type_plsql_func   CONSTANT func_define_type.brief%TYPE := 'PLSQL';
  gc_func_def_type_plsql_proc   CONSTANT func_define_type.brief%TYPE := 'PLSQL_PROCEDURE';

  gc_cr_netto_tariff_brief CONSTANT VARCHAR2(255) := 'PRD_CR_Netto_Tariff';
  gc_cr_tariff_brief       CONSTANT VARCHAR2(255) := 'PRD_CR_Tariff';
  gc_cr_loading_brief      CONSTANT VARCHAR2(255) := 'PRD_CR_Load';
  gc_cr_re_rate_brief      CONSTANT VARCHAR2(255) := 'PRD_CR_Re_rates';

  PROCEDURE add_cr_netto_tariff
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
   ,par_age_limit         NUMBER DEFAULT 64
  );

  PROCEDURE add_cr_tariff
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
   ,par_age_limit         NUMBER DEFAULT 64
  );

  PROCEDURE add_cr_load
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
  );

  PROCEDURE add_cr_re_rate
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
  );

  PROCEDURE add_cr_ins_sum_koef
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
   ,par_fund_brief        VARCHAR2 DEFAULT 'RUR'
  );

  PROCEDURE add_cr_ins_sum_limit
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
  );

  /* Добавление процедуры контроля продукта: контроль лимита СС*/
  PROCEDURE add_prod_cont_ins_amount_lim
  (
    par_product_brief t_product.brief%TYPE
   ,par_limit_from    NUMBER
   ,par_limit_to      NUMBER
   ,par_message       VARCHAR2
  );

  FUNCTION get_prod_coef_type_id_by_brief(par_brief VARCHAR2) RETURN NUMBER;
  FUNCTION get_prod_coef_type_id_by_name(par_name VARCHAR2) RETURN NUMBER;

  /*
  PROCEDURE create_prod_coef_type
  (
    par_name                   VARCHAR2
   ,par_brief                  VARCHAR2
   ,par_prod_coef_tariff_brief VARCHAR2 DEFAULT 'COMMON'
   ,par_func_type_brief        VARCHAR2 DEFAULT dml_func_define_type.gc_table_of_values
   ,par_sql                    VARCHAR2 DEFAULT NULL
   ,par_factor_1_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_1           VARCHAR2 DEFAULT NULL
   ,par_factor_2_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_2           VARCHAR2 DEFAULT NULL
   ,par_factor_3_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_3           VARCHAR2 DEFAULT NULL
   ,par_factor_4_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_4           VARCHAR2 DEFAULT NULL
   ,par_factor_5_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_5           VARCHAR2 DEFAULT NULL
   ,par_factor_6_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_6           VARCHAR2 DEFAULT NULL
   ,par_factor_7_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_7           VARCHAR2 DEFAULT NULL
   ,par_factor_8_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_8           VARCHAR2 DEFAULT NULL
   ,par_factor_9_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_9           VARCHAR2 DEFAULT NULL
   ,par_factor_10_brief        VARCHAR2 DEFAULT NULL
   ,par_comporator_10          VARCHAR2 DEFAULT NULL
   ,par_note                   VARCHAR2 DEFAULT NULL
   ,par_sub_func_brief         VARCHAR2 DEFAULT NULL
  );
  */

  PROCEDURE create_prod_coef_type
  (
    par_name                   VARCHAR2
   ,par_brief                  VARCHAR2
   ,par_sql                    VARCHAR2
   ,par_prod_coef_tariff_brief VARCHAR2 DEFAULT 'COMMON'
   ,par_func_type_brief        VARCHAR2 DEFAULT gc_func_def_type_plsql_func
   ,par_factor_1_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_2_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_3_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_4_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_5_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_6_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_7_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_8_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_9_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_10_brief        VARCHAR2 DEFAULT NULL
   ,par_note                   VARCHAR2 DEFAULT NULL
   ,par_sub_func_brief         VARCHAR2 DEFAULT NULL
  );

  PROCEDURE create_prod_coef_type
  (
    par_name                   VARCHAR2
   ,par_brief                  VARCHAR2
   ,par_prod_coef_tariff_brief VARCHAR2 DEFAULT 'COMMON'
   ,par_func_type_brief        VARCHAR2 DEFAULT gc_func_def_type_table_of_val
   ,par_factor_1_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_1           VARCHAR2 DEFAULT NULL
   ,par_factor_2_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_2           VARCHAR2 DEFAULT NULL
   ,par_factor_3_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_3           VARCHAR2 DEFAULT NULL
   ,par_factor_4_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_4           VARCHAR2 DEFAULT NULL
   ,par_factor_5_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_5           VARCHAR2 DEFAULT NULL
   ,par_factor_6_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_6           VARCHAR2 DEFAULT NULL
   ,par_factor_7_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_7           VARCHAR2 DEFAULT NULL
   ,par_factor_8_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_8           VARCHAR2 DEFAULT NULL
   ,par_factor_9_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_9           VARCHAR2 DEFAULT NULL
   ,par_factor_10_brief        VARCHAR2 DEFAULT NULL
   ,par_comporator_10          VARCHAR2 DEFAULT NULL
   ,par_note                   VARCHAR2 DEFAULT NULL
   ,par_sub_func_brief         VARCHAR2 DEFAULT NULL
  );

  /*
    Капля П.
    Добавление записи в табличные функции
  */
  PROCEDURE add_prod_coef
  (
    par_prod_coef_type_brief VARCHAR2
   ,par_value                NUMBER
   ,par_criteria_1           NUMBER DEFAULT NULL
   ,par_criteria_2           NUMBER DEFAULT NULL
   ,par_criteria_3           NUMBER DEFAULT NULL
   ,par_criteria_4           NUMBER DEFAULT NULL
   ,par_criteria_5           NUMBER DEFAULT NULL
   ,par_criteria_6           NUMBER DEFAULT NULL
   ,par_criteria_7           NUMBER DEFAULT NULL
   ,par_criteria_8           NUMBER DEFAULT NULL
   ,par_criteria_9           NUMBER DEFAULT NULL
   ,par_criteria_10          NUMBER DEFAULT NULL
  );
  PROCEDURE add_prod_coef
  (
    par_prod_coef_type_id NUMBER
   ,par_value             NUMBER
   ,par_criteria_1        NUMBER DEFAULT NULL
   ,par_criteria_2        NUMBER DEFAULT NULL
   ,par_criteria_3        NUMBER DEFAULT NULL
   ,par_criteria_4        NUMBER DEFAULT NULL
   ,par_criteria_5        NUMBER DEFAULT NULL
   ,par_criteria_6        NUMBER DEFAULT NULL
   ,par_criteria_7        NUMBER DEFAULT NULL
   ,par_criteria_8        NUMBER DEFAULT NULL
   ,par_criteria_9        NUMBER DEFAULT NULL
   ,par_criteria_10       NUMBER DEFAULT NULL
  );

END pkg_prod_coef;
/
CREATE OR REPLACE PACKAGE BODY pkg_prod_coef IS

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations

  -- Function and procedure implementations
  gc_infinity CONSTANT NUMBER := 1e35;

  PROCEDURE add_cr_netto_tariff
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
   ,par_age_limit         NUMBER DEFAULT 64
  ) IS
  BEGIN
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, criteria_1, criteria_2, val)
      SELECT pct.t_prod_coef_type_id
            ,pl.id
            ,par_age_limit
            ,par_value val
        FROM t_product_line    pl
            ,t_product_ver_lob pvl
            ,t_product_version pv
            ,t_product         p
            ,t_prod_coef_type  pct
       WHERE p.brief = par_product_brief
         AND pv.product_id = p.product_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pl.description = par_product_line_name
         AND pct.brief = gc_cr_netto_tariff_brief;
  
    IF SQL%ROWCOUNT = 0
       OR SQL%ROWCOUNT > 1
    THEN
      raise_application_error(-20001, 'Ошибка при вставке значения!');
    END IF;
  
  END add_cr_netto_tariff;

  PROCEDURE add_cr_tariff
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
   ,par_age_limit         NUMBER DEFAULT 64
  ) IS
  BEGIN
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, criteria_1, criteria_2, val)
      SELECT pct.t_prod_coef_type_id
            ,pl.id
            ,par_age_limit
            ,par_value val
        FROM t_product_line    pl
            ,t_product_ver_lob pvl
            ,t_product_version pv
            ,t_product         p
            ,t_prod_coef_type  pct
       WHERE p.brief = par_product_brief
         AND pv.product_id = p.product_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pl.description = par_product_line_name
         AND pct.brief = gc_cr_tariff_brief;
  
    IF SQL%ROWCOUNT = 0
       OR SQL%ROWCOUNT > 1
    THEN
      raise_application_error(-20001, 'Ошибка при вставке значения!');
    END IF;
  
  END add_cr_tariff;

  PROCEDURE add_cr_load
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
  ) IS
  BEGIN
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, criteria_1, val)
      SELECT pct.t_prod_coef_type_id
            ,pl.id
            ,par_value val
        FROM t_product_line    pl
            ,t_product_ver_lob pvl
            ,t_product_version pv
            ,t_product         p
            ,t_prod_coef_type  pct
       WHERE p.brief = par_product_brief
         AND pv.product_id = p.product_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pl.description = par_product_line_name
         AND pct.brief = gc_cr_loading_brief;
  
    IF SQL%ROWCOUNT = 0
       OR SQL%ROWCOUNT > 1
    THEN
      raise_application_error(-20001, 'Ошибка при вставке значения!');
    END IF;
  
  END add_cr_load;

  PROCEDURE add_cr_re_rate
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
  ) IS
    v_prod_coef_type_id NUMBER := get_prod_coef_type_id_by_brief(gc_cr_re_rate_brief);
  BEGIN
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, criteria_1, val)
      SELECT v_prod_coef_type_id
            ,pl.id
            ,par_value val
        FROM t_product_line    pl
            ,t_product_ver_lob pvl
            ,t_product_version pv
            ,t_product         p
       WHERE p.brief = par_product_brief
         AND pv.product_id = p.product_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pl.description = par_product_line_name;
    IF SQL%ROWCOUNT != 1
    THEN
      raise_application_error(-20001, 'Ошибка при вставке значения!');
    END IF;
  END;

  PROCEDURE add_cr_ins_sum_koef
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
   ,par_fund_brief        VARCHAR2 DEFAULT 'RUR'
  ) IS
  BEGIN
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, criteria_1, criteria_2, val)
      SELECT pct.t_prod_coef_type_id
            ,pl.id
            ,f.fund_id
            ,par_value val
        FROM t_product_line    pl
            ,t_product_ver_lob pvl
            ,t_product_version pv
            ,t_product         p
            ,fund              f
            ,t_prod_coef_type  pct
       WHERE p.brief = par_product_brief
         AND pv.product_id = p.product_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pl.description = par_product_line_name
         AND f.brief = par_fund_brief
         AND pct.brief = 'Ins_Sum_CR_Koef_table';
  
    IF SQL%ROWCOUNT = 0
       OR SQL%ROWCOUNT > 1
    THEN
      raise_application_error(-20001, 'Ошибка при вставке значения!');
    END IF;
  
  END add_cr_ins_sum_koef;

  PROCEDURE add_cr_ins_sum_limit
  (
    par_product_brief     VARCHAR2
   ,par_product_line_name VARCHAR2
   ,par_value             NUMBER
  ) IS
  BEGIN
    INSERT INTO ven_t_prod_coef
      (t_prod_coef_type_id, criteria_1, val)
      SELECT pct.t_prod_coef_type_id
            ,pl.id
            ,par_value val
        FROM t_product_line    pl
            ,t_product_ver_lob pvl
            ,t_product_version pv
            ,t_product         p
            ,t_prod_coef_type  pct
       WHERE p.brief = par_product_brief
         AND pv.product_id = p.product_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pl.description = par_product_line_name
         AND pct.brief = 'Ins_Sum_CR_limit';
  
    IF SQL%ROWCOUNT = 0
       OR SQL%ROWCOUNT > 1
    THEN
      raise_application_error(-20001, 'Ошибка при вставке значения!');
    END IF;
  
  END add_cr_ins_sum_limit;

  FUNCTION get_prod_coef_type_id_by_brief(par_brief VARCHAR2) RETURN NUMBER IS
    v_prod_coef_type_id NUMBER;
  BEGIN
    SELECT pct.t_prod_coef_type_id
      INTO v_prod_coef_type_id
      FROM t_prod_coef_type pct
     WHERE pct.brief = par_brief;
    RETURN v_prod_coef_type_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить функцию из справочника функций по брифу: ' ||
                              par_brief);
  END get_prod_coef_type_id_by_brief;

  FUNCTION get_prod_coef_type_id_by_name(par_name VARCHAR2) RETURN NUMBER IS
    v_prod_coef_type_id NUMBER;
  BEGIN
    SELECT pct.t_prod_coef_type_id
      INTO v_prod_coef_type_id
      FROM t_prod_coef_type pct
     WHERE pct.name = par_name;
    RETURN v_prod_coef_type_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить функцию из справочника функций по названию: ' ||
                              par_name);
  END get_prod_coef_type_id_by_name;

  PROCEDURE create_prod_coef_type
  (
    par_name                   VARCHAR2
   ,par_brief                  VARCHAR2
   ,par_prod_coef_tariff_brief VARCHAR2 DEFAULT 'COMMON'
   ,par_func_type_brief        VARCHAR2 DEFAULT gc_func_def_type_table_of_val
   ,par_sql                    VARCHAR2 DEFAULT NULL
   ,par_factor_1_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_1           VARCHAR2 DEFAULT NULL
   ,par_factor_2_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_2           VARCHAR2 DEFAULT NULL
   ,par_factor_3_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_3           VARCHAR2 DEFAULT NULL
   ,par_factor_4_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_4           VARCHAR2 DEFAULT NULL
   ,par_factor_5_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_5           VARCHAR2 DEFAULT NULL
   ,par_factor_6_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_6           VARCHAR2 DEFAULT NULL
   ,par_factor_7_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_7           VARCHAR2 DEFAULT NULL
   ,par_factor_8_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_8           VARCHAR2 DEFAULT NULL
   ,par_factor_9_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_9           VARCHAR2 DEFAULT NULL
   ,par_factor_10_brief        VARCHAR2 DEFAULT NULL
   ,par_comporator_10          VARCHAR2 DEFAULT NULL
   ,par_note                   VARCHAR2 DEFAULT NULL
   ,par_sub_func_brief         VARCHAR2 DEFAULT NULL
  ) IS
    v_tariff_id    NUMBER;
    v_func_type_id NUMBER;
    v_sub_func_id  t_prod_coef_type.t_prod_coef_type_id%TYPE;
  
    v_comp1  NUMBER;
    v_comp2  NUMBER;
    v_comp3  NUMBER;
    v_comp4  NUMBER;
    v_comp5  NUMBER;
    v_comp6  NUMBER;
    v_comp7  NUMBER;
    v_comp8  NUMBER;
    v_comp9  NUMBER;
    v_comp10 NUMBER;
  
    v_fact_1  NUMBER;
    v_fact_2  NUMBER;
    v_fact_3  NUMBER;
    v_fact_4  NUMBER;
    v_fact_5  NUMBER;
    v_fact_6  NUMBER;
    v_fact_7  NUMBER;
    v_fact_8  NUMBER;
    v_fact_9  NUMBER;
    v_fact_10 NUMBER;
  
    FUNCTION get_comporator_id(par_comporator VARCHAR2) RETURN NUMBER IS
      v_id NUMBER;
    BEGIN
      IF par_comporator IS NOT NULL
      THEN
        SELECT ct.comporator_id
          INTO v_id
          FROM t_comporator_type ct
         WHERE ct.comporator = par_comporator;
      END IF;
      RETURN v_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось найти знак сравнения по брифу - ' || par_comporator);
    END get_comporator_id;
  
    FUNCTION get_factor_id(par_factor_brief VARCHAR2) RETURN NUMBER IS
      v_id NUMBER;
    BEGIN
      IF par_factor_brief IS NOT NULL
      THEN
        v_id := dml_t_attribut.get_id_by_brief(par_brief => par_factor_brief);
      END IF;
      RETURN v_id;
    END get_factor_id;
  
  BEGIN
    assert_deprecated(par_func_type_brief IN
           (gc_func_def_type_plsql_func, gc_func_def_type_plsql_proc) AND
           (nvl(par_comporator_1, '=') != '=' OR nvl(par_comporator_2, '=') != '=' OR
           nvl(par_comporator_3, '=') != '=' OR nvl(par_comporator_4, '=') != '=' OR
           nvl(par_comporator_5, '=') != '=' OR nvl(par_comporator_6, '=') != '=' OR
           nvl(par_comporator_7, '=') != '=' OR nvl(par_comporator_8, '=') != '=' OR
           nvl(par_comporator_9, '=') != '=' OR nvl(par_comporator_10, '=') != '=')
          ,'Для PLSQL функций и процедур не может быть использован способ сравнения отличный от "="');
  
    v_tariff_id    := dml_t_prod_coef_tariff.get_id_by_brief(par_brief => par_prod_coef_tariff_brief);
    v_func_type_id := dml_func_define_type.get_id_by_brief(par_brief => par_func_type_brief);
  
    IF par_sub_func_brief IS NOT NULL
    THEN
      v_sub_func_id := dml_t_prod_coef_type.get_id_by_brief(par_sub_func_brief);
    END IF;
  
    v_comp1  := get_comporator_id(par_comporator_1);
    v_comp2  := get_comporator_id(par_comporator_2);
    v_comp3  := get_comporator_id(par_comporator_3);
    v_comp4  := get_comporator_id(par_comporator_4);
    v_comp5  := get_comporator_id(par_comporator_5);
    v_comp6  := get_comporator_id(par_comporator_6);
    v_comp7  := get_comporator_id(par_comporator_7);
    v_comp8  := get_comporator_id(par_comporator_8);
    v_comp9  := get_comporator_id(par_comporator_9);
    v_comp10 := get_comporator_id(par_comporator_10);
  
    v_fact_1  := get_factor_id(par_factor_1_brief);
    v_fact_2  := get_factor_id(par_factor_2_brief);
    v_fact_3  := get_factor_id(par_factor_3_brief);
    v_fact_4  := get_factor_id(par_factor_4_brief);
    v_fact_5  := get_factor_id(par_factor_5_brief);
    v_fact_6  := get_factor_id(par_factor_6_brief);
    v_fact_7  := get_factor_id(par_factor_7_brief);
    v_fact_8  := get_factor_id(par_factor_8_brief);
    v_fact_9  := get_factor_id(par_factor_9_brief);
    v_fact_10 := get_factor_id(par_factor_10_brief);
  
    dml_t_prod_coef_type.insert_record(par_name                    => par_name
                                      ,par_func_define_type_id     => v_func_type_id
                                      ,par_factor_1                => v_fact_1
                                      ,par_factor_2                => v_fact_2
                                      ,par_factor_3                => v_fact_3
                                      ,par_factor_4                => v_fact_4
                                      ,par_factor_5                => v_fact_5
                                      ,par_sub_t_prod_coef_type_id => v_sub_func_id
                                      ,par_brief                   => par_brief
                                      ,par_comparator_1            => v_comp1
                                      ,par_comparator_2            => v_comp2
                                      ,par_comparator_3            => v_comp3
                                      ,par_comparator_4            => v_comp4
                                      ,par_comparator_5            => v_comp5
                                      ,par_t_prod_coef_tariff_id   => v_tariff_id
                                      ,par_r_sql                   => par_sql
                                      ,par_factor_6                => v_fact_6
                                      ,par_factor_7                => v_fact_7
                                      ,par_factor_8                => v_fact_8
                                      ,par_factor_9                => v_fact_9
                                      ,par_factor_10               => v_fact_10
                                      ,par_comparator_6            => v_comp6
                                      ,par_comparator_7            => v_comp7
                                      ,par_comparator_8            => v_comp8
                                      ,par_comparator_9            => v_comp9
                                      ,par_comparator_10           => v_comp10
                                      ,par_note                    => par_note);
  
  END create_prod_coef_type;

  PROCEDURE create_prod_coef_type
  (
    par_name                   VARCHAR2
   ,par_brief                  VARCHAR2
   ,par_prod_coef_tariff_brief VARCHAR2 DEFAULT 'COMMON'
   ,par_func_type_brief        VARCHAR2 DEFAULT gc_func_def_type_table_of_val
   ,par_factor_1_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_1           VARCHAR2 DEFAULT NULL
   ,par_factor_2_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_2           VARCHAR2 DEFAULT NULL
   ,par_factor_3_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_3           VARCHAR2 DEFAULT NULL
   ,par_factor_4_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_4           VARCHAR2 DEFAULT NULL
   ,par_factor_5_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_5           VARCHAR2 DEFAULT NULL
   ,par_factor_6_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_6           VARCHAR2 DEFAULT NULL
   ,par_factor_7_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_7           VARCHAR2 DEFAULT NULL
   ,par_factor_8_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_8           VARCHAR2 DEFAULT NULL
   ,par_factor_9_brief         VARCHAR2 DEFAULT NULL
   ,par_comporator_9           VARCHAR2 DEFAULT NULL
   ,par_factor_10_brief        VARCHAR2 DEFAULT NULL
   ,par_comporator_10          VARCHAR2 DEFAULT NULL
   ,par_note                   VARCHAR2 DEFAULT NULL
   ,par_sub_func_brief         VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
    create_prod_coef_type(par_name                   => par_name
                         ,par_brief                  => par_brief
                         ,par_prod_coef_tariff_brief => par_prod_coef_tariff_brief
                         ,par_func_type_brief        => par_func_type_brief
                         ,par_sql                    => NULL
                         ,par_factor_1_brief         => par_factor_1_brief
                         ,par_comporator_1           => par_comporator_1
                         ,par_factor_2_brief         => par_factor_2_brief
                         ,par_comporator_2           => par_comporator_2
                         ,par_factor_3_brief         => par_factor_3_brief
                         ,par_comporator_3           => par_comporator_3
                         ,par_factor_4_brief         => par_factor_4_brief
                         ,par_comporator_4           => par_comporator_4
                         ,par_factor_5_brief         => par_factor_5_brief
                         ,par_comporator_5           => par_comporator_5
                         ,par_factor_6_brief         => par_factor_6_brief
                         ,par_comporator_6           => par_comporator_6
                         ,par_factor_7_brief         => par_factor_7_brief
                         ,par_comporator_7           => par_comporator_7
                         ,par_factor_8_brief         => par_factor_8_brief
                         ,par_comporator_8           => par_comporator_8
                         ,par_factor_9_brief         => par_factor_9_brief
                         ,par_comporator_9           => par_comporator_9
                         ,par_factor_10_brief        => par_factor_10_brief
                         ,par_comporator_10          => par_comporator_10
                         ,par_note                   => par_note
                         ,par_sub_func_brief         => par_sub_func_brief);
  END create_prod_coef_type;

  PROCEDURE create_prod_coef_type
  (
    par_name                   VARCHAR2
   ,par_brief                  VARCHAR2
   ,par_sql                    VARCHAR2
   ,par_prod_coef_tariff_brief VARCHAR2 DEFAULT 'COMMON'
   ,par_func_type_brief        VARCHAR2 DEFAULT gc_func_def_type_plsql_func
   ,par_factor_1_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_2_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_3_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_4_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_5_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_6_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_7_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_8_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_9_brief         VARCHAR2 DEFAULT NULL
   ,par_factor_10_brief        VARCHAR2 DEFAULT NULL
   ,par_note                   VARCHAR2 DEFAULT NULL
   ,par_sub_func_brief         VARCHAR2 DEFAULT NULL
  ) IS
    c_comporator CONSTANT t_comporator_type.comporator%TYPE := '=';
    v_comp_1  t_comporator_type.comporator%TYPE;
    v_comp_2  t_comporator_type.comporator%TYPE;
    v_comp_3  t_comporator_type.comporator%TYPE;
    v_comp_4  t_comporator_type.comporator%TYPE;
    v_comp_5  t_comporator_type.comporator%TYPE;
    v_comp_6  t_comporator_type.comporator%TYPE;
    v_comp_7  t_comporator_type.comporator%TYPE;
    v_comp_8  t_comporator_type.comporator%TYPE;
    v_comp_9  t_comporator_type.comporator%TYPE;
    v_comp_10 t_comporator_type.comporator%TYPE;
  
  BEGIN
    SELECT nvl2(par_factor_1_brief, c_comporator, NULL)
          ,nvl2(par_factor_2_brief, c_comporator, NULL)
          ,nvl2(par_factor_3_brief, c_comporator, NULL)
          ,nvl2(par_factor_4_brief, c_comporator, NULL)
          ,nvl2(par_factor_5_brief, c_comporator, NULL)
          ,nvl2(par_factor_6_brief, c_comporator, NULL)
          ,nvl2(par_factor_7_brief, c_comporator, NULL)
          ,nvl2(par_factor_8_brief, c_comporator, NULL)
          ,nvl2(par_factor_9_brief, c_comporator, NULL)
          ,nvl2(par_factor_10_brief, c_comporator, NULL)
      INTO v_comp_1
          ,v_comp_2
          ,v_comp_3
          ,v_comp_4
          ,v_comp_5
          ,v_comp_6
          ,v_comp_7
          ,v_comp_8
          ,v_comp_9
          ,v_comp_10
      FROM dual;
  
    create_prod_coef_type(par_name                   => par_name
                         ,par_brief                  => par_brief
                         ,par_prod_coef_tariff_brief => par_prod_coef_tariff_brief
                         ,par_func_type_brief        => par_func_type_brief
                         ,par_sql                    => par_sql
                         ,par_factor_1_brief         => par_factor_1_brief
                         ,par_factor_2_brief         => par_factor_2_brief
                         ,par_factor_3_brief         => par_factor_3_brief
                         ,par_factor_4_brief         => par_factor_4_brief
                         ,par_factor_5_brief         => par_factor_5_brief
                         ,par_factor_6_brief         => par_factor_6_brief
                         ,par_factor_7_brief         => par_factor_7_brief
                         ,par_factor_8_brief         => par_factor_8_brief
                         ,par_factor_9_brief         => par_factor_9_brief
                         ,par_factor_10_brief        => par_factor_10_brief
                         ,par_comporator_1           => v_comp_1
                         ,par_comporator_2           => v_comp_2
                         ,par_comporator_3           => v_comp_3
                         ,par_comporator_4           => v_comp_4
                         ,par_comporator_5           => v_comp_5
                         ,par_comporator_6           => v_comp_6
                         ,par_comporator_7           => v_comp_7
                         ,par_comporator_8           => v_comp_8
                         ,par_comporator_9           => v_comp_9
                         ,par_comporator_10          => v_comp_10
                         ,par_note                   => par_note
                         ,par_sub_func_brief         => par_sub_func_brief);
  END create_prod_coef_type;

  PROCEDURE add_prod_cont_ins_amount_lim
  (
    par_product_brief t_product.brief%TYPE
   ,par_limit_from    NUMBER
   ,par_limit_to      NUMBER
   ,par_message       VARCHAR2
  ) IS
    v_product_id t_product.product_id%TYPE;
    vc_prod_coef_type_brief CONSTANT t_prod_coef_type.brief%TYPE := 'PRODUCT_CONTROL_INS_AMOUNT_LIMIT';
    v_prod_coef_type_id t_prod_coef_type.t_prod_coef_type_id%TYPE;
  
    PROCEDURE check_prod_coef_exists
    (
      par_product_id        t_product.product_id%TYPE
     ,par_prod_coef_type_id t_prod_coef_type.t_prod_coef_type_id%TYPE
    ) IS
      v_dummy NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_dummy
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM t_prod_coef pc
               WHERE pc.t_prod_coef_type_id = par_prod_coef_type_id
                 AND pc.criteria_1 = par_product_id);
      IF v_dummy = 1
      THEN
        raise_application_error(-20001
                               ,'Запись в таблице t_prod_coef уже существует');
      END IF;
    
    END check_prod_coef_exists;
  
  BEGIN
    IF par_limit_from >= par_limit_to
    THEN
      raise_application_error(-20001
                             ,'Нижняя гарница лимита должа быть меньше верхней');
    END IF;
  
    v_product_id := pkg_products.get_product_id(par_product_brief => par_product_brief);
  
    v_prod_coef_type_id := pkg_prod_coef.get_prod_coef_type_id_by_brief(vc_prod_coef_type_brief);
  
    check_prod_coef_exists(par_product_id        => v_product_id
                          ,par_prod_coef_type_id => v_prod_coef_type_id);
  
    /* Вставляем сам лимит */
    IF par_limit_from IS NOT NULL
    THEN
      INSERT INTO ven_t_prod_coef
        (t_prod_coef_type_id, criteria_1, criteria_2, val)
      VALUES
        (v_prod_coef_type_id, v_product_id, par_limit_from, 0);
    END IF;
  
    IF par_limit_to IS NOT NULL
    THEN
      INSERT INTO ven_t_prod_coef
        (t_prod_coef_type_id, criteria_1, criteria_2, val)
      VALUES
        (v_prod_coef_type_id, v_product_id, par_limit_to, 1);
    
      INSERT INTO ven_t_prod_coef
        (t_prod_coef_type_id, criteria_1, criteria_2, val)
      VALUES
        (v_prod_coef_type_id, v_product_id, gc_infinity, 0);
    ELSE
      INSERT INTO ven_t_prod_coef
        (t_prod_coef_type_id, criteria_1, criteria_2, val)
      VALUES
        (v_prod_coef_type_id, v_product_id, gc_infinity, 1);
    END IF;
  
    /* Создаем проверку в продукте */
    BEGIN
      pkg_products.add_product_control_func(par_product_brief => par_product_brief
                                           ,par_func_brief    => vc_prod_coef_type_brief
                                           ,par_message       => par_message);
    EXCEPTION
      WHEN dup_val_on_index THEN
        raise_application_error(-20001, 'Данная проверка уже существует');
    END;
  
  END add_prod_cont_ins_amount_lim;

  /*
    Капля П.
    Добавление записи в табличные функции
  */
  PROCEDURE add_prod_coef
  (
    par_prod_coef_type_brief VARCHAR2
   ,par_value                NUMBER
   ,par_criteria_1           NUMBER DEFAULT NULL
   ,par_criteria_2           NUMBER DEFAULT NULL
   ,par_criteria_3           NUMBER DEFAULT NULL
   ,par_criteria_4           NUMBER DEFAULT NULL
   ,par_criteria_5           NUMBER DEFAULT NULL
   ,par_criteria_6           NUMBER DEFAULT NULL
   ,par_criteria_7           NUMBER DEFAULT NULL
   ,par_criteria_8           NUMBER DEFAULT NULL
   ,par_criteria_9           NUMBER DEFAULT NULL
   ,par_criteria_10          NUMBER DEFAULT NULL
  ) IS
    v_prod_coef_type_id t_prod_coef_type.t_prod_coef_type_id%TYPE;
  BEGIN
    assert_deprecated(par_prod_coef_type_brief IS NULL
          ,'Параметр par_prod_coef_type_brief не может быть пустым');
  
    v_prod_coef_type_id := get_prod_coef_type_id_by_brief(par_brief => par_prod_coef_type_brief);
  
    add_prod_coef(par_prod_coef_type_id => v_prod_coef_type_id
                 ,par_value             => par_value
                 ,par_criteria_1        => par_criteria_1
                 ,par_criteria_2        => par_criteria_2
                 ,par_criteria_3        => par_criteria_3
                 ,par_criteria_4        => par_criteria_4
                 ,par_criteria_5        => par_criteria_5
                 ,par_criteria_6        => par_criteria_6
                 ,par_criteria_7        => par_criteria_7
                 ,par_criteria_8        => par_criteria_8
                 ,par_criteria_9        => par_criteria_9
                 ,par_criteria_10       => par_criteria_10);
  END add_prod_coef;

  PROCEDURE add_prod_coef
  (
    par_prod_coef_type_id NUMBER
   ,par_value             NUMBER
   ,par_criteria_1        NUMBER DEFAULT NULL
   ,par_criteria_2        NUMBER DEFAULT NULL
   ,par_criteria_3        NUMBER DEFAULT NULL
   ,par_criteria_4        NUMBER DEFAULT NULL
   ,par_criteria_5        NUMBER DEFAULT NULL
   ,par_criteria_6        NUMBER DEFAULT NULL
   ,par_criteria_7        NUMBER DEFAULT NULL
   ,par_criteria_8        NUMBER DEFAULT NULL
   ,par_criteria_9        NUMBER DEFAULT NULL
   ,par_criteria_10       NUMBER DEFAULT NULL
  ) IS
    v_t_prod_coef_id t_prod_coef.t_prod_coef_id%TYPE;
  BEGIN
    assert_deprecated(par_prod_coef_type_id IS NULL
          ,'Параметр par_prod_coef_type_id не может быть пустым');
    SELECT sq_t_prod_coef.nextval INTO v_t_prod_coef_id FROM dual;
  
    INSERT INTO t_prod_coef
      (t_prod_coef_id
      ,t_prod_coef_type_id
      ,val
      ,criteria_1
      ,criteria_2
      ,criteria_3
      ,criteria_4
      ,criteria_5
      ,criteria_6
      ,criteria_7
      ,criteria_8
      ,criteria_9
      ,criteria_10)
    VALUES
      (v_t_prod_coef_id
      ,par_prod_coef_type_id
      ,par_value
      ,par_criteria_1
      ,par_criteria_2
      ,par_criteria_3
      ,par_criteria_4
      ,par_criteria_5
      ,par_criteria_6
      ,par_criteria_7
      ,par_criteria_8
      ,par_criteria_9
      ,par_criteria_10);
  END add_prod_coef;

BEGIN
  -- Initialization
  NULL;
END pkg_prod_coef; 
/
