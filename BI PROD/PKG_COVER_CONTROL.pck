CREATE OR REPLACE PACKAGE pkg_cover_control IS

  ex_precreation_cover_control EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_precreation_cover_control, -20100);

  -- Author  : Marchuk A.
  -- Created : 16.04.2008
  -- Purpose : Утилиты для контроля продукта в контексте бизнес процессов

  PROCEDURE cover_control(p_p_cover_id IN NUMBER);

  PROCEDURE policy_cover_control
  (
    par_p_policy_id           p_policy.policy_id%TYPE
   ,par_is_underwriting_check t_product_line_limit.is_underwriting_check%TYPE DEFAULT NULL
  );

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_cover_ctrl_inc_underwr(par_policy_id p_policy.policy_id%TYPE);

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    НЕ установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_cover_ctrl_exc_underwr(par_policy_id p_policy.policy_id%TYPE);

  /*
    Капля П.
    Предварительный контроль покрытий, функция может быть использована в SQL
  */
  FUNCTION precreation_cover_control
  (
    par_asset_id        NUMBER
   ,par_product_line_id NUMBER
  ) RETURN NUMBER;
  /*
    Капля П.
    Предварительный контроль покрытий. При ошибке выводит текст ошибки из настройки продукта.
  */
  PROCEDURE precreation_cover_control
  (
    par_asset_id        NUMBER
   ,par_product_line_id NUMBER
  );

  /*
    Капля П.
    Функция контроля возможности добавления периода для покрытия
  */
  FUNCTION check_cover_period_control
  (
    par_asset_id NUMBER
   ,par_func_id  NUMBER
  ) RETURN NUMBER;

  FUNCTION ins_sum_limit_ad_50(par_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION ins_sum_limit_ad_75(par_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION ins_sum_limit_ad_100(par_p_cover_id NUMBER) RETURN NUMBER;

  /**
  Капля П.
  Функция проверки возраста застрахованного от 18 до 60 лет.
  */
  FUNCTION assured_age_18_60(par_age NUMBER) RETURN NUMBER;

  /**
  Капля П.
  Функция проверки возраста застрахованного от 0 до 16 лет.
  */
  FUNCTION assured_age_0_16(par_age NUMBER) RETURN NUMBER;

  /*
  Капля П.
  Проверка, что СС по покрытию меньше или равна СС по основной программе
  */
  FUNCTION check_ins_amount_by_main(par_cover_id NUMBER) RETURN NUMBER;

  /*
  Капля П.
  Проверка пола и возроста застрахованного по программе онкология Семья 2, Гармония 2, Будущее 2
  */
  FUNCTION female_oncology_age_gender(par_cover_id NUMBER) RETURN NUMBER;

  /**
  * Проверка наличия обеих дополнительных программ продукта Наследие 2
  * @author Капля П.
  * @param par_cover_id - ИД покрытия для проверки 
  * @return NUMBER - результат проверки
  */
  FUNCTION check_nasledie_optional_lines(par_cover_id NUMBER) RETURN NUMBER;

END pkg_cover_control;
/
CREATE OR REPLACE PACKAGE BODY pkg_cover_control IS

  -- Author  : Marchuk A.
  -- Created : 16.04.2008
  -- Purpose : Утилиты для контроля покрытий в контексте бизнес процессов

  /*
   * Проверка договора на соответствие правилам продукта
   * @author Marchuk A.
   * @param p_c_claim_id      ИД версии договора страхования
  */

  PROCEDURE cover_control(p_p_cover_id IN NUMBER) IS
    CURSOR c_limit_func IS
      SELECT pl.id
            ,ct.name
            ,pcl.limit_func_id
        FROM t_prod_coef_type     ct
            ,t_product_line_limit pcl
            ,t_product_line       pl
            ,t_prod_line_option   plo
            ,p_cover              pc
       WHERE 1 = 1
         AND pc.p_cover_id = p_p_cover_id
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND pcl.t_product_line_id = pl.id
         AND ct.t_prod_coef_type_id = pcl.limit_func_id
       ORDER BY pcl.sort_order NULLS LAST;
    RESULT NUMBER;
  BEGIN
    FOR cur IN c_limit_func
    LOOP
      BEGIN
        RESULT := pkg_tariff_calc.calc_fun(cur.limit_func_id, ent.id_by_brief('P_COVER'), p_p_cover_id);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'При выполнении процедуры проверки "' || cur.name ||
                                  '" произошла ошибка ');
      END;
    END LOOP;
  END cover_control;

  -- Author  : Ilya Slezin
  -- Created : 29.03.2010
  -- Purpose : Функция контроля покрытий по ДС
  PROCEDURE policy_cover_control
  (
    par_p_policy_id           p_policy.policy_id%TYPE
   ,par_is_underwriting_check t_product_line_limit.is_underwriting_check%TYPE DEFAULT NULL
  ) IS
    CURSOR c_limit_func IS
      SELECT pc.p_cover_id
            ,plo.description plo_name
            ,pl.id
            ,ct.name
            ,pcl.limit_func_id
            ,pcl.message
        FROM t_prod_coef_type     ct
            ,t_product_line_limit pcl
            ,t_product_line       pl
            ,t_prod_line_option   plo
            ,p_cover              pc
            ,status_hist          shp
            ,as_asset             aa
            ,status_hist          sha
       WHERE 1 = 1
         AND aa.p_policy_id = par_p_policy_id
         AND pc.as_asset_id = aa.as_asset_id
         AND sha.status_hist_id = aa.status_hist_id
         AND sha.brief <> 'DELETED'
         AND shp.status_hist_id = pc.status_hist_id
         AND shp.brief <> 'DELETED'
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND pcl.t_product_line_id = pl.id
         AND ct.t_prod_coef_type_id = pcl.limit_func_id
         AND pcl.is_underwriting_check = nvl(par_is_underwriting_check, pcl.is_underwriting_check)
       ORDER BY pcl.sort_order NULLS LAST;
    RESULT NUMBER;
    v_msg  VARCHAR2(500);
  BEGIN
    -- Проверка должна выполняться только если версия является первой неотмененной
    --    IF par_p_policy_id = pkg_policy.get_first_uncanceled_version(dml_p_policy.get_record(par_p_policy_id).pol_header_id)
    --    THEN
    FOR cur IN c_limit_func
    LOOP
      BEGIN
        RESULT := pkg_tariff_calc.calc_fun(cur.limit_func_id
                                          ,ent.id_by_brief('P_COVER')
                                          ,cur.p_cover_id);
        IF RESULT = 0
        THEN
          IF cur.message IS NOT NULL
          THEN
            v_msg := cur.message;
          ELSE
            v_msg := 'Не пройден контроль покрытия по программе "' || cur.plo_name || '".';
          END IF;
          raise_application_error(-20002, v_msg);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'При выполнении процедуры проверки ' || CASE WHEN
                                  par_is_underwriting_check = 1 THEN ' в процессе Андеррайтинга ' ELSE ''
                                  END || '"' || cur.name || '" произошла ошибка ' || SQLERRM);
      END;
    END LOOP;
    --    END IF;
  END policy_cover_control;

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_cover_ctrl_inc_underwr(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    IF par_policy_id =
       pkg_policy.get_first_uncanceled_version(dml_p_policy.get_record(par_policy_id).pol_header_id)
    THEN
      policy_cover_control(par_policy_id, 1);
    END IF;
  END policy_cover_ctrl_inc_underwr;

  /*
    Пиядин А.
    Веб-андеррайтинг: контроль только по проверкам, для которых
    НЕ установлен флаг "Проверка на андеррайтинге"
  */
  PROCEDURE policy_cover_ctrl_exc_underwr(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    policy_cover_control(par_policy_id, 0);
  END policy_cover_ctrl_exc_underwr;

  FUNCTION precreation_cover_control
  (
    par_asset_id        NUMBER
   ,par_product_line_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    precreation_cover_control(par_asset_id        => par_asset_id
                             ,par_product_line_id => par_product_line_id);
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  PROCEDURE precreation_cover_control
  (
    par_asset_id        NUMBER
   ,par_product_line_id NUMBER
  ) IS
    v_result            NUMBER;
    v_product_line_name t_product_line.description%TYPE;
    v_ent_id            NUMBER := ents.id_by_brief('AS_ASSET');
    v_error_msg         VARCHAR2(2000);
  BEGIN
    BEGIN
      SELECT description
        INTO v_product_line_name
        FROM t_product_line pl
       WHERE pl.id = par_product_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось найти программу в продукте');
    END;
  
    v_error_msg := 'Не пройден предварительный контроль покрытий по программе ' || v_product_line_name;
  
    FOR control_rec IN (SELECT pl.limit_func_id
                              ,pl.message
                              ,pct.name
                          FROM t_product_line_limit pl
                              ,t_prod_coef_type     pct
                         WHERE pl.t_product_line_id = par_product_line_id
                           AND pl.limit_func_id = pct.t_prod_coef_type_id
                           AND pl.is_precreation_check = 1
                         ORDER BY pl.sort_order)
    LOOP
      BEGIN
        v_result := pkg_tariff_calc.calc_fun(p_id     => control_rec.limit_func_id
                                            ,p_ent_id => v_ent_id
                                            ,p_obj_id => par_asset_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_result := 0;
      END;
    
      IF v_result != 1
      THEN
      
        IF control_rec.message IS NOT NULL
        THEN
          v_error_msg := v_error_msg || ': ' || control_rec.message;
        END IF;
        --cover_precreation_check
        raise_application_error(-20100, v_error_msg);
      END IF;
    
    END LOOP;
  END precreation_cover_control;

  /*
    Капля П.
    Функция контроля возможности добавления периода для покрытия
  */
  FUNCTION check_cover_period_control
  (
    par_asset_id NUMBER
   ,par_func_id  NUMBER
  ) RETURN NUMBER IS
    v_ent_id      NUMBER := ents.id_by_brief('AS_ASSET');
    v_func_result NUMBER;
  BEGIN
    IF par_func_id IS NOT NULL
    THEN
    
      v_func_result := pkg_tariff_calc.calc_fun(p_id     => par_func_id
                                               ,p_ent_id => v_ent_id
                                               ,p_obj_id => par_asset_id);
      IF v_func_result != 1
      THEN
        v_func_result := 0;
      END IF;
    
    ELSE
      v_func_result := 1;
    END IF;
  
    RETURN v_func_result;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'В функции контроля возможности добавления периода по покрытию произошла ошибка: ' ||
                              SQLERRM);
  END check_cover_period_control;

  -- Author  : Ilya Slezin
  -- Created : 30.03.2010
  -- Purpose : Лимит СС 50% от Смерти НС
  FUNCTION ins_sum_limit_ad_50(par_p_cover_id NUMBER) RETURN NUMBER IS
    proc_name       VARCHAR2(50) := 'ins_sum_limit_AD_50';
    v_ins_amount_ad NUMBER := 0;
    v_ins_amount    NUMBER := 0;
    lim             NUMBER := 0.5;
    RESULT          NUMBER;
  BEGIN
  
    SELECT pcad.ins_amount
          ,pc.ins_amount
      INTO v_ins_amount_ad
          ,v_ins_amount
      FROM p_cover            pc
          ,t_prod_line_option plo
          ,as_asset           aa
          ,p_policy           p
          ,p_cover            pcad
          ,status_hist        shp
          ,t_product_line     pl
          ,t_prod_line_option pload
          ,t_lob_line         ll
     WHERE 1 = 1
       AND pc.p_cover_id = par_p_cover_id
       AND plo.id = pc.t_prod_line_option_id
       AND aa.as_asset_id = pc.as_asset_id
       AND p.policy_id = aa.p_policy_id
       AND pcad.as_asset_id = aa.as_asset_id
       AND shp.status_hist_id = pcad.status_hist_id
       AND shp.brief <> 'DELETED'
       AND pload.id = pcad.t_prod_line_option_id
       AND pl.id = pload.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief = 'AD'; ---Смерть НС у этого застрахованного
  
    IF v_ins_amount_ad * lim < v_ins_amount
    THEN
      RESULT := 0;
    ELSE
      RESULT := 1;
    END IF;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ins_sum_limit_ad_50;

  -- Author  : Ilya Slezin
  -- Created : 30.03.2010
  -- Purpose : Лимит СС 75% от Смерти НС
  FUNCTION ins_sum_limit_ad_75(par_p_cover_id NUMBER) RETURN NUMBER IS
    proc_name       VARCHAR2(50) := 'ins_sum_limit_AD_75';
    v_ins_amount_ad NUMBER := 0;
    v_ins_amount    NUMBER := 0;
    lim             NUMBER := 0.75;
    RESULT          NUMBER;
  BEGIN
  
    SELECT pcad.ins_amount
          ,pc.ins_amount
      INTO v_ins_amount_ad
          ,v_ins_amount
      FROM p_cover            pc
          ,t_prod_line_option plo
          ,as_asset           aa
          ,p_policy           p
          ,p_cover            pcad
          ,status_hist        shp
          ,t_product_line     pl
          ,t_prod_line_option pload
          ,t_lob_line         ll
     WHERE 1 = 1
       AND pc.p_cover_id = par_p_cover_id
       AND plo.id = pc.t_prod_line_option_id
       AND aa.as_asset_id = pc.as_asset_id
       AND p.policy_id = aa.p_policy_id
       AND pcad.as_asset_id = aa.as_asset_id
       AND shp.status_hist_id = pcad.status_hist_id
       AND shp.brief <> 'DELETED'
       AND pload.id = pcad.t_prod_line_option_id
       AND pl.id = pload.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief = 'AD'; ---Смерть НС у этого застрахованного
  
    IF CEIL(v_ins_amount_ad * lim) < v_ins_amount
    THEN
      RESULT := 0;
    ELSE
      RESULT := 1;
    END IF;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ins_sum_limit_ad_75;

  -- Author  : Ilya Slezin
  -- Created : 30.03.2010
  -- Purpose : Лимит СС 100% от Смерти НС
  FUNCTION ins_sum_limit_ad_100(par_p_cover_id NUMBER) RETURN NUMBER IS
    proc_name       VARCHAR2(50) := 'ins_sum_limit_AD_100';
    v_ins_amount_ad NUMBER := 0;
    v_ins_amount    NUMBER := 0;
    lim             NUMBER := 1;
    RESULT          NUMBER;
  BEGIN
  
    SELECT pcad.ins_amount
          ,pc.ins_amount
      INTO v_ins_amount_ad
          ,v_ins_amount
      FROM p_cover            pc
          ,t_prod_line_option plo
          ,as_asset           aa
          ,p_policy           p
          ,p_cover            pcad
          ,status_hist        shp
          ,t_product_line     pl
          ,t_prod_line_option pload
          ,t_lob_line         ll
     WHERE 1 = 1
       AND pc.p_cover_id = par_p_cover_id
       AND plo.id = pc.t_prod_line_option_id
       AND aa.as_asset_id = pc.as_asset_id
       AND p.policy_id = aa.p_policy_id
       AND pcad.as_asset_id = aa.as_asset_id
       AND shp.status_hist_id = pcad.status_hist_id
       AND shp.brief <> 'DELETED'
       AND pload.id = pcad.t_prod_line_option_id
       AND pl.id = pload.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND ll.brief = 'AD'; ---Смерть НС у этого застрахованного
  
    IF v_ins_amount_ad * lim < v_ins_amount
    THEN
      RESULT := 0;
    ELSE
      RESULT := 1;
    END IF;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ins_sum_limit_ad_100;

  FUNCTION assured_age_18_60(par_age NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(50) := 'assured_age_18_60';
  BEGIN
    IF nvl(par_age, 0) BETWEEN 18 AND 60
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END assured_age_18_60;

  FUNCTION assured_age_0_16(par_age NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(50) := 'assured_age_0_16';
  BEGIN
    IF nvl(par_age, 0) BETWEEN 0 AND 16
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END assured_age_0_16;

  FUNCTION female_oncology_age_gender(par_cover_id NUMBER) RETURN NUMBER IS
    v_age          NUMBER;
    v_gender_brief t_gender.brief%TYPE;
  BEGIN
  
    SELECT CEIL(MONTHS_BETWEEN(ph.start_date, c.date_of_birth) / 12)
          ,(SELECT brief FROM t_gender g WHERE g.id = c.gender) gender_brief
      INTO v_age
          ,v_gender_brief
      FROM p_cover      pc
          ,as_asset     aa
          ,as_assured   aas
          ,cn_person    c
          ,p_policy     pp
          ,p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.as_asset_id = aas.as_assured_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND aas.assured_contact_id = c.contact_id;
  
    IF v_gender_brief = 'MALE'
    THEN
      RETURN 0;
      /*raise_application_error(-20001
      ,'Программа не доступна для застрахованных мужского пола');*/
    END IF;
  
    IF v_age > 55
    THEN
      RETURN 0;
      /*raise_application_error(-20001
      ,'Программа не доступна для женщин старше 55 лет на дату начала действия ДС');*/
    END IF;
    RETURN 1;
  
  END female_oncology_age_gender;

  FUNCTION check_ins_amount_by_main(par_cover_id NUMBER) RETURN NUMBER IS
    v_ins_amount      NUMBER;
    v_main_ins_amount NUMBER;
    v_as_asset_id     NUMBER;
  BEGIN
    SELECT nvl(ins_amount, 0)
          ,pc.as_asset_id
      INTO v_ins_amount
          ,v_as_asset_id
      FROM p_cover pc
     WHERE pc.p_cover_id = par_cover_id;
  
    SELECT nvl(MAX(pc.ins_amount), 0)
      INTO v_main_ins_amount
      FROM p_cover             pc
          ,t_prod_line_option  plo
          ,t_product_line      pl
          ,t_product_line_type plt
     WHERE pc.as_asset_id = v_as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND plo.product_line_id = pl.id
       AND pl.product_line_type_id = plt.product_line_type_id
       AND plt.brief = 'RECOMMENDED';
  
    IF v_ins_amount > v_main_ins_amount
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  
  END check_ins_amount_by_main;

  /**
  * Проверка наличия обеих дополнительных программ продукта Наследие 2
  * @author Капля П.
  * @param par_cover_id - ИД покрытия для проверки 
  * @return NUMBER - результат проверки
  */
  FUNCTION check_nasledie_optional_lines(par_cover_id NUMBER) RETURN NUMBER IS
    v_result NUMBER := 0;
    v_cnt    NUMBER;
  BEGIN
    /*    SELECT COUNT(*)
     INTO v_cnt
     FROM p_cover             pc
         ,p_cover             pc2
         ,t_prod_line_option  plo
         ,v_prod_product_line ppl
    WHERE pc.p_cover_id = par_cover_id
      AND pc.as_asset_id = pc2.as_asset_id
      AND pc2.t_prod_line_option_id = plo.id
      AND ppl.t_product_line_id = plo.product_line_id
      AND pc.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
      AND pc2.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
      AND ((plo.brief IN ('ANY_1_GR', 'WOP') AND
          ppl.product_brief IN ('Nasledie_2', 'Nasledie_2_HKF')) OR
          (plo.brief IN ('ADis', 'WOP') AND ppl.product_brief = 'Nasledie_2_retail'));*/
    SELECT COUNT(*)
      INTO v_cnt
      FROM p_cover             pc
          ,p_cover             pc2
          ,t_prod_line_option  plo
          ,t_product_line      pl
          ,t_product_line_type plt
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = pc2.as_asset_id
       AND pc2.t_prod_line_option_id = plo.id
       AND pl.id = plo.product_line_id
       AND pc.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
       AND pc2.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
       AND pl.product_line_type_id = plt.product_line_type_id
       AND plt.brief IN ('OPTIONAL');
  
    IF v_cnt = 2
    THEN
      v_result := 1;
    END IF;
  
    RETURN v_result;
  
  END check_nasledie_optional_lines;

END pkg_cover_control;
/
