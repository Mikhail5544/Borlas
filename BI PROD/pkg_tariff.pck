CREATE OR REPLACE PACKAGE pkg_tariff IS

  /**
  * Пакет расчета тарифов для страхования
  * @author Alexander Kalabukhov,Balashov
  * @version 1.0.0.1
  * @date 02.02.2007
  * @changes * calc_tariff_casco_damage -- Корректировка расчета премии (Кущенко С.)
             * calc_tarif_mul_casco     -- Корректировка перерасчета премии (Кущенко С.)
  
  */

  /**
  * Возврашает значение коэффициента
  * @author Alexander Kalabukhov
  * @param
  * @return
  */
  FUNCTION calc_tariff(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возврашает значение тарифа.
  * Рассчитывает значения всех коэффициентов тарифной ставки по
  * покрытию. Записывает значения коэффициентов в p_cover_coef.
  * Рассчитвает значение тарифа по покрытию
  * @author Alexander Kalabukhov
  * @param p_cover_id ИД покрытия
  * @return значение тарифа
  */

  -- Flexa
  FUNCTION calc_tariff_property_flexa(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- Flexa для продукта ИЮЛ - нетиповой
  FUNCTION calc_tariff_pr_flexa_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- Flexa в случае ручного ввода для типового продукта
  FUNCTION recalc_tariff_flexa_type(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- Flexa в случае ручного ввода для НЕтипового продукта
  FUNCTION recalc_tariff_flexa_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- стекла - ручной ввод
  FUNCTION recalc_tariff_glass_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- Прочие риски для имущства
  FUNCTION calc_tariff_property_other(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- Прочие риски для имущства Нетиповой продукт
  FUNCTION calc_tariff_pr_other_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- спецтехника:пакет рисков
  FUNCTION calc_tariff_property_sm_pack(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- спецтехника:аварии
  FUNCTION calc_tariff_property_sm_avar(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- спецриски
  FUNCTION calc_tariff_property_srisks(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- стекла для типового
  FUNCTION calc_tariff_property_glass(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- стекла для нетипового
  FUNCTION calc_tariff_pr_glass_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER;

  -- получение произвольного коэффициента, заданного для FLEXA
  FUNCTION get_coef_from_flexa
  (
    p_p_cover_id IN NUMBER
   ,risk_name    VARCHAR2
  ) RETURN NUMBER;
  -- получение коэффициента по рискам для июл - нетиповой по стеклам
  FUNCTION get_class_risk_flexa(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- полученеи андеррайтерского коэффициента, заданного ддя FLEXA
  FUNCTION get_underr_flexa(p_p_cover_id IN NUMBER) RETURN NUMBER;

  --//////////////////////////////////////////////////////////
  --............................ИПОТЕКА
  --/////////////////////////////////////////////////////////
  -- расчет тарифа с базовой ставкой и андеррайтерским коэффициентом
  FUNCTION calc_tarif_mg_base_underr
  (
    p_p_cover_id IN NUMBER
   ,p_coef       VARCHAR2
  ) RETURN NUMBER;

  -- расчет тарифа "НС комплексное ипотечное страхование"
  FUNCTION calc_tarif_mg_ns(p_p_cover_id IN NUMBER) RETURN NUMBER;

  -- расчет тарифа "ИМФЛ комплексное ипотечное страхование"
  FUNCTION calc_tarif_mg_property(p_p_cover_id IN NUMBER) RETURN NUMBER;
  -- расчет тарифа "ФР комплексное ипотечное страхование"
  FUNCTION calc_tarif_mg_titul(p_p_cover_id IN NUMBER) RETURN NUMBER;

  -- получаем андеррайтерский коэффициент из предыдущей версии договора
  FUNCTION get_coef_from_prev_version
  (
    p_p_cover_id IN NUMBER
   ,risk_name    IN VARCHAR2
  ) RETURN NUMBER;

  -- получаем коэффициент за конструктив для нетипового продукта
  FUNCTION get_constract_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER;

  -- получаем андеррайтерский коэффициент из предыдущей версии
  FUNCTION get_underr_mg(p_p_cover_id IN NUMBER) RETURN NUMBER;

  FUNCTION get_underr_35(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION get_underr_91(p_p_cover_id IN NUMBER) RETURN NUMBER;

  --//////////////////////////////////////////////////////////
  --............................ОСАГО
  --/////////////////////////////////////////////////////////
  FUNCTION calc_tariff_osago(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION recalc_tariff_osago(p_p_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION calc_tariff_casco_damage
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION calc_tariff_casco_liability
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION calc_tariff_casco_acces
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION calc_tariff_casco_ns
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION recalc_tariff_casco(p_p_cover_id IN NUMBER) RETURN NUMBER;

  FUNCTION calc_tariff_life(p_p_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Возвращает произведение коэффициентов по каверу
  * @author Patsan O.
  * @param par_cover_id ИД ковера
  * @return Произведение коэффициентов
  */
  --
  FUNCTION calc_tarif_mul(par_cover_id IN NUMBER) RETURN NUMBER;
  FUNCTION calc_tarif_mul_casco
  (
    par_cover_id IN NUMBER
   ,d_recalc     IN DATE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION calc_tarif_mul_life(p_p_cover_id IN NUMBER) RETURN NUMBER;

  FUNCTION get_casco_gr(veh_id IN NUMBER) RETURN NUMBER;

  /*is_p_car возвращает 1 если тип автомобиля "легковой" и 0 в противном случае*/
  FUNCTION is_p_car(p_p_cover_id IN INTEGER) RETURN INTEGER;

  /**
  * Функция расчета коэффициентов, определенных в продукте для данного покрытия.
  * По заданному покрытию находятся зарегистрированные в продукте коэффициенты
  * тарифной ставки t_prod_line_coef. Для каждого коэффициента тарифной ставки
  * t_prod_coef_type выполняется расчет его значения @see pkg_tarif_calc.
  * @param p_p_cover_id ид покрытия
  * @returm произведение рассчитанных коээфициентов pkg_tariff_calc.calc_function
  * @author Denis Ivanov
  * @param
  */
  FUNCTION calc_cover_coef(p_p_cover_id IN NUMBER) RETURN NUMBER;
  PROCEDURE copy_tariff
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );
  FUNCTION max_coef_driver(p_p_cover_id IN INTEGER) RETURN NUMBER;

  FUNCTION get_tariff_casco(p_c NUMBER) RETURN NUMBER;
  FUNCTION get_prev_prem(p_c NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_tariff IS

  v_p_cover p_cover%ROWTYPE;

  g_debug BOOLEAN := FALSE;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO p_cover_debug
        (p_cover_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_TARIFF', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  -- регистрация коэффициента
  PROCEDURE reg_coeff
  (
    p_p_cover_id IN NUMBER
   ,p_brief      IN VARCHAR2
   ,p_val        IN NUMBER
   ,p_is_damage  IN NUMBER DEFAULT 0
  ) AS
    v_n                    NUMBER;
    v_m                    NUMBER;
    v_default_val          NUMBER;
    v_val                  NUMBER;
    v_is_handchange_amount NUMBER;
  BEGIN
  
    log(p_p_cover_id, 'REG_COEFF ' || p_brief || ' ' || p_val);
  
    SELECT tpct.t_prod_coef_type_id
          ,plc.t_prod_line_coef_id
          ,is_handchange_amount
      INTO v_n
          ,v_m
          ,v_is_handchange_amount
      FROM t_prod_coef_type   tpct
          ,p_cover            pc
          ,t_prod_line_option plo
          ,t_prod_line_coef   plc
     WHERE tpct.brief = p_brief
       AND pc.p_cover_id = p_p_cover_id
       AND pc.t_prod_line_option_id = plo.id
       AND plc.t_product_line_id = plo.product_line_id
       AND plc.t_prod_coef_type_id = tpct.t_prod_coef_type_id;
  
    UPDATE ven_p_cover_coef
       SET val         = decode(is_handchange_coef, 0, p_val, val)
          ,default_val = p_val
     WHERE p_cover_id = p_p_cover_id
       AND t_prod_coef_type_id = v_n
       AND is_damage = p_is_damage;
  
    IF SQL%ROWCOUNT = 0
    THEN
    
      INSERT INTO ven_p_cover_coef
        (p_cover_id
        ,t_prod_coef_type_id
        ,val
        ,default_val
        ,t_prod_line_coef_id
        ,is_handchange_coef
        ,is_damage)
      VALUES
        (p_p_cover_id, v_n, p_val, p_val, v_m, 0, p_is_damage);
    END IF;
  
  EXCEPTION
  
    WHEN no_data_found THEN
      raise_application_error(-20100
                             ,'Для продукта не задан коэффициэнт тарифа: ' || p_brief);
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE update_default_val
  (
    p_c_c   NUMBER
   ,def_val NUMBER
  ) AS
  BEGIN
    UPDATE p_cover_coef pcc SET pcc.default_val = def_val WHERE pcc.p_cover_coef_id = p_c_c;
  END;

  FUNCTION calc_cover_coef(p_p_cover_id IN NUMBER) RETURN NUMBER IS
  
    v_coef_val     NUMBER;
    v_cover_ent_id NUMBER;
    v_res          NUMBER;
    v_message      VARCHAR2(2000);
  
  BEGIN
    v_res          := NULL;
    v_cover_ent_id := ent.get_obj_ent_id(ent.id_by_brief('P_COVER'), p_p_cover_id);
  
    dbms_output.put_line('Поиск зарегистрированных коэффициентов....');
    FOR rec IN (SELECT tpct.t_prod_coef_type_id
                      ,tpct.brief
                  FROM t_prod_coef_type   tpct
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_prod_line_coef   plc
                 WHERE pc.p_cover_id = p_p_cover_id
                   AND pc.t_prod_line_option_id = plo.id
                   AND plc.t_product_line_id = plo.product_line_id
                   AND plc.t_prod_coef_type_id = tpct.t_prod_coef_type_id
                   AND plc.is_disabled = 0)
    LOOP
    
      BEGIN
        dbms_output.put_line(' tpct.t_prod_coef_type_id ' || rec.t_prod_coef_type_id);
        v_coef_val := pkg_tariff_calc.calc_fun(rec.t_prod_coef_type_id, v_cover_ent_id, p_p_cover_id);
        dbms_output.put_line(' Получено значение  ' || v_coef_val);
        dbms_output.put_line(' Начинаем регистрацию коэффициента ');
        reg_coeff(p_p_cover_id, rec.brief, v_coef_val);
        dbms_output.put_line(' Закончили регистрацию коэффициента ');
      EXCEPTION
        WHEN OTHERS THEN
          v_message := SQLERRM;
          v_message := substr(v_message, 1, 252);
          dbms_output.put_line(v_message);
      END;
    END LOOP;
    v_res := calc_tarif_mul(p_p_cover_id);
    RETURN v_res;
  END;

  FUNCTION calc_tariff(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
    v        VARCHAR2(4000);
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    IF v_p_cover.is_handchange_amount = 1
    THEN
      RETURN calc_tarif_mul(p_p_cover_id);
    END IF;
  
    SELECT pl.description
      INTO v
      FROM ven_p_cover            pc
          ,ven_t_prod_line_option plo
          ,ven_t_product_line     pl
     WHERE pc.p_cover_id = p_p_cover_id
       AND plo.id = pc.t_prod_line_option_id
       AND pl.id = plo.product_line_id;
    IF v = 'ОСАГО'
    THEN
      v_result := calc_tariff_osago(p_p_cover_id);
    END IF;
  
    RETURN v_result;
  END;

  -- произведение коэффициентов по каверу
  FUNCTION calc_tarif_mul(par_cover_id IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
    summ  NUMBER;
    prog  VARCHAR2(1000);
    prod  VARCHAR2(1000);
    bt_1  NUMBER;
    tp    VARCHAR2(1000);
  BEGIN
    v_res := 1;
  
    SELECT pc.ins_amount
          ,plo.description
          ,pr.brief
      INTO summ
          ,prog
          ,prod
      FROM p_cover pc
      JOIN t_prod_line_option plo
        ON plo.id = pc.t_prod_line_option_id
      JOIN as_asset ass
        ON ass.as_asset_id = pc.as_asset_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
      JOIN t_product pr
        ON pr.product_id = ph.product_id
     WHERE pc.p_cover_id = par_cover_id;
  
    FOR v_c IN (SELECT pcc.val FROM p_cover_coef pcc WHERE pcc.p_cover_id = par_cover_id)
    LOOP
      v_res := v_res * v_c.val;
    END LOOP;
  
    IF prog = 'Дополнительное оборудование'
       AND prod = 'Автокаско-ВТБ24'
    THEN
      SELECT pcc.val
            ,tct.brief
        INTO bt_1
            ,tp
        FROM p_cover_coef pcc
        JOIN t_prod_coef_type tct
          ON tct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
       WHERE tct.brief IN ('PREV_PREM_COVER', 'CASCO_TARIFF')
         AND pcc.p_cover_id = par_cover_id;
    
      FOR cur IN (SELECT pcc.val
                    FROM ven_p_cover_coef pcc
                    JOIN t_prod_coef_type tct
                      ON tct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                   WHERE pcc.p_cover_id = par_cover_id
                     AND tct.brief NOT IN ('PREV_PREM_COVER', 'CASCO_TARIFF'))
      LOOP
        bt_1 := bt_1 * cur.val;
      END LOOP;
    
      IF tp = 'PREV_PREM_COVER'
      THEN
        RETURN ROUND(bt_1 * 100 / summ, 2);
      ELSE
        RETURN bt_1;
      END IF;
    
    END IF;
    RETURN v_res;
  END;

  -- произведение коэффициентов по каверу

  FUNCTION calc_tarif_mul_life(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    v_res := 1;
    FOR v_c IN (SELECT pcc.val FROM p_cover_coef pcc WHERE pcc.p_cover_id = p_p_cover_id)
    LOOP
      v_res := v_res * v_c.val;
    END LOOP;
    RETURN v_res;
  END;

  FUNCTION calc_tarif_mul_casco
  (
    par_cover_id IN NUMBER
   ,d_recalc     IN DATE DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT NUMBER;
    bt_1   NUMBER;
    bt_2   NUMBER;
    k_supp NUMBER;
  BEGIN
  
    FOR cur IN (SELECT tct.brief
                      ,pcc.val
                  FROM p_cover_coef pcc
                  JOIN t_prod_coef_type tct
                    ON tct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                 WHERE tct.brief IN
                       ('CASCO_DAMAGE_BASE_TARIFF', 'CASCO_STEAL_BASE_TARIFF', 'CASCO_TARIFF')
                   AND pcc.p_cover_id = par_cover_id)
    LOOP
      IF cur.brief = 'CASCO_DAMAGE_BASE_TARIFF'
      THEN
        bt_2 := cur.val;
      ELSIF cur.brief = 'CASCO_TARIFF'
      THEN
        bt_2 := cur.val;
      ELSE
        bt_1 := cur.val;
      END IF;
    END LOOP;
  
    FOR cur IN (SELECT tct.brief nam
                      ,pcc.val
                  FROM ven_p_cover_coef pcc
                  JOIN t_prod_coef_type tct
                    ON tct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                 WHERE pcc.p_cover_id = par_cover_id
                   AND tct.brief NOT IN
                       ('CASCO_DAMAGE_BASE_TARIFF', 'CASCO_STEAL_BASE_TARIFF', 'CASCO_DAMAGE_SUPPORT'))
    LOOP
      CASE
        WHEN cur.nam IN ('DURATION'
                        ,'CASCO_DAMAGE_K3'
                        ,'CASCO_DAMAGE_K6'
                        ,'CASCO_DAMAGE_K7'
                        ,'CASCO_DAMAGE_K8'
                        ,'CASCO_DAMAGE_K9'
                        ,'CASCO_DAMAGE_K10'
                        ,'CASCO_DAMAGE_K10_1'
                        ,'CASCO_DAMAGE_K13'
                        ,'CASCO_DAMAGE_K14'
                        ,'CASCO_DAMAGE_K15'
                        ,'CASCO_COEF_35'
                        ,'CASCO_COEF_91') THEN
          bt_1 := bt_1 * cur.val;
          bt_2 := bt_2 * cur.val;
        WHEN cur.nam = 'CASCO_DAMAGE_K12' THEN
          bt_1 := bt_1 * cur.val;
        
        WHEN cur.nam IN ('CASCO_DAMAGE_K1'
                        ,'CASCO_DAMAGE_K2'
                        ,'CASCO_DAMAGE_K4'
                        ,'CASCO_DAMAGE_K5'
                        ,'CASCO_DAMAGE_K11'
                        ,'CASCO_COEF_NEXT_YEAR') THEN
          bt_2 := bt_2 * cur.val;
      END CASE;
    END LOOP;
    RESULT := (bt_1 + bt_2);
  
    /*  select nvl(pcc.val,0)
    into k_supp
    from ven_p_cover_coef pcc
     join t_prod_coef_type tct on tct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
    where pcc.p_cover_id = par_cover_id
      and tct.brief ='CASCO_DAMAGE_SUPPORT';
    result :=result+nvl(k_supp,0);*/
  
    RETURN RESULT;
  END;

  FUNCTION calc_tariff_property_flexa(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  
    b_b        NUMBER;
    b_c        NUMBER;
    k_ws       NUMBER;
    k_con      NUMBER;
    k_spr      NUMBER;
    k_risk     NUMBER;
    k_srok     NUMBER;
    k_pboul    NUMBER;
    k_pkg      NUMBER;
    k_nolosses NUMBER;
    k_tpaynent NUMBER;
    k_underr   NUMBER;
    ap_id      NUMBER;
  
    sum_con     NUMBER; -- сумма по содержимому
    sum_not_con NUMBER; -- сумма по коробке
  
    p_ws    NUMBER;
    p_spr   NUMBER;
    p_act   VARCHAR(24);
    p_h_id  NUMBER;
    p_s_id  NUMBER;
    p_srok  VARCHAR(24);
    p_datas DATE;
    p_datae DATE;
    p_pr    VARCHAR2(100);
  
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT ap.is_warehouse
          ,ap.is_has_sprinkler
          ,ap.act_type_code
          ,ap.t_warehouse_height_id
          ,ap.t_warehouse_space_id
          ,tp.description
          ,pp.start_date
          ,pp.end_date
          ,ap.as_property_id
          ,pr.brief
      INTO p_ws
          ,p_spr
          ,p_act
          ,p_h_id
          ,p_s_id
          ,p_srok
          ,p_datas
          ,p_datae
          ,ap_id
          ,p_pr
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = ap.p_policy_id
     INNER JOIN ven_t_period tp
        ON tp.id = pp.period_id
     INNER JOIN ven_p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     INNER JOIN ven_t_product pr
        ON ph.product_id = pr.product_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    IF p_pr LIKE 'ИЮЛ-Типовой%'
    THEN
      -- !!!! расчитываем переменные
    
      sum_con     := 0;
      sum_not_con := 0;
      FOR cur IN (SELECT nvl(ap.is_contents, 0) c
                        ,SUM(ap.ins_sum) summ
                    FROM as_property_stuff ap
                   WHERE ap.as_property_id = ap_id
                   GROUP BY ap.is_contents)
      LOOP
        CASE cur.c
          WHEN 1 THEN
            sum_con := cur.summ; -- содер
          ELSE
            sum_not_con := cur.summ; --коробка
        END CASE;
      END LOOP;
      -- ставка по зданию   
      b_b := pkg_tariff_calc.calc_fun('PROPERTY_BASE_BUILD', v_p_cover.ent_id, p_p_cover_id);
      --ставка по содержимому
      b_c := pkg_tariff_calc.calc_fun('PROPERTY_BASE_CONTENTS', v_p_cover.ent_id, p_p_cover_id);
      -- значение коэффициента за размеры склада
      IF (p_ws = 1)
      THEN
        k_ws := pkg_tariff_calc.calc_fun('PROPERTY_WAREHOUSE_SIZE', v_p_cover.ent_id, p_p_cover_id);
        IF (p_act IN ('9730', '9740', '9750') -- степень риска выше средней
           AND (k_ws >= 1.5) -- коэффициент за размеры склада
           )
        THEN
          k_ws := k_ws * 1.5;
        END IF;
      ELSE
        k_ws := 1;
      END IF;
      -- значение коэффициента за конструктив
      k_con := pkg_tariff_calc.calc_fun('PROPERTY_CONSTRUCT', v_p_cover.ent_id, p_p_cover_id);
      -- наличие спринклера
      k_spr := pkg_tariff_calc.calc_fun('PROPERTY_SPRINKLER', v_p_cover.ent_id, p_p_cover_id);
      -- наличие опасных видов деятельности
      k_risk := pkg_tariff_calc.calc_fun('PROPERTY_RISKY_WORK', v_p_cover.ent_id, p_p_cover_id);
      -- срок страхования
    
      IF (CEIL(MONTHS_BETWEEN(p_datae, p_datas)) > 12)
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(p_datae, p_datas)) / 12, 5);
      ELSE
        k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
      END IF;
      -- безубыточность
      k_nolosses := nvl(pkg_tariff_calc.calc_fun('PROPERTY_NO_LOSSES', v_p_cover.ent_id, p_p_cover_id)
                       ,1);
      -- порядок выплат
      k_tpaynent := nvl(pkg_tariff_calc.calc_fun('PROPERTY_TYPE_PAYMENT'
                                                ,v_p_cover.ent_id
                                                ,p_p_cover_id)
                       ,1);
      -- андеррайтерский
      k_underr := nvl(pkg_tariff_calc.calc_fun('PROPERTY_UNDERWRITER', v_p_cover.ent_id, p_p_cover_id)
                     ,1);
      -- ПБОЮЛ
      k_pboul := nvl(pkg_tariff_calc.calc_fun('PROPERTY_IS_PBOUL', v_p_cover.ent_id, p_p_cover_id), 1);
      -- ПАКЕТ
      k_pkg := pkg_tariff_calc.calc_fun('PROPERTY_PACKAGE', v_p_cover.ent_id, p_p_cover_id);
    
      -- !!! если ручной ввод
      IF v_p_cover.is_handchange_amount = 1
      THEN
        FOR coef IN (SELECT pcc.p_cover_coef_id
                           ,pct.brief
                       FROM p_cover_coef pcc
                       JOIN t_prod_coef_type pct
                         ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                      WHERE pcc.p_cover_id = p_p_cover_id)
        LOOP
          -- !!! обновление коэффициентов
          CASE coef.brief
            WHEN 'PROPERTY_BASE_BUILD' THEN
              update_default_val(coef.p_cover_coef_id, b_b);
            WHEN 'PROPERTY_BASE_CONTENTS' THEN
              update_default_val(coef.p_cover_coef_id, b_c);
            WHEN 'PROPERTY_WAREHOUSE_SIZE' THEN
              update_default_val(coef.p_cover_coef_id, k_ws);
            WHEN 'PROPERTY_CONSTRUCT' THEN
              update_default_val(coef.p_cover_coef_id, k_con);
            WHEN 'PROPERTY_SPRINKLER' THEN
              update_default_val(coef.p_cover_coef_id, k_spr);
            WHEN 'PROPERTY_RISKY_WORK' THEN
              update_default_val(coef.p_cover_coef_id, k_risk);
            WHEN 'DURATION' THEN
              update_default_val(coef.p_cover_coef_id, k_srok);
            WHEN 'PROPERTY_NO_LOSSES' THEN
              update_default_val(coef.p_cover_coef_id, k_nolosses);
            WHEN 'PROPERTY_TYPE_PAYMENT' THEN
              update_default_val(coef.p_cover_coef_id, k_tpaynent);
            WHEN 'PROPERTY_UNDERWRITER' THEN
              update_default_val(coef.p_cover_coef_id, k_underr);
            WHEN 'PROPERTY_IS_PBOUL' THEN
              update_default_val(coef.p_cover_coef_id, k_pboul);
            WHEN 'PROPERTY_PACKAGE' THEN
              update_default_val(coef.p_cover_coef_id, k_pkg);
          END CASE;
        END LOOP;
        RETURN recalc_tariff_flexa_type(p_p_cover_id);
      ELSE
        v_result := ROUND((b_b * sum_not_con + b_c * sum_con) * k_ws * k_con * k_spr * k_risk * k_srok *
                          k_nolosses * k_tpaynent * k_underr * k_pboul * k_pkg / 100
                         ,2);
      
        -- !!! регистрируем переменные
        reg_coeff(p_p_cover_id, 'PROPERTY_BASE_BUILD', b_b); -- базовый тариф по здания
        reg_coeff(p_p_cover_id, 'PROPERTY_BASE_CONTENTS', b_c); -- базовый тариф по содержимому
        reg_coeff(p_p_cover_id, 'PROPERTY_WAREHOUSE_SIZE', k_ws); -- значение коэффициента за размеры склада
        reg_coeff(p_p_cover_id, 'PROPERTY_CONSTRUCT', k_con); -- значение коэффициента за конструктив
        reg_coeff(p_p_cover_id, 'PROPERTY_SPRINKLER', k_spr); -- наличие спринклера
        reg_coeff(p_p_cover_id, 'PROPERTY_RISKY_WORK', k_risk); -- наличие опасных видов деятельности
        reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- срок страхования
        reg_coeff(p_p_cover_id, 'PROPERTY_NO_LOSSES', k_nolosses); -- значение коэффициента за безубыточность
        reg_coeff(p_p_cover_id, 'PROPERTY_TYPE_PAYMENT', k_tpaynent); -- значение коэффициента за порядок выплаты
        reg_coeff(p_p_cover_id, 'PROPERTY_UNDERWRITER', k_underr); -- андеррайтерский коэффициент
        reg_coeff(p_p_cover_id, 'PROPERTY_IS_PBOUL', k_pboul); -- значение коэффициента за ПБОЮЛ
        reg_coeff(p_p_cover_id, 'PROPERTY_PACKAGE', k_pkg); -- значение коэффициента за порядок выплаты
      END IF;
    ELSE
      -- если продукт Нетиповой
      v_result := calc_tariff_pr_flexa_untyped(p_p_cover_id);
    END IF;
    RETURN v_result;
  END;

  FUNCTION calc_tariff_pr_flexa_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  
    b_b           NUMBER; -- базовая ставка
    k_ws          NUMBER; -- коэффициент за размер склада
    k_con         NUMBER; -- коэффициент за конструктив
    k_upp         NUMBER; -- надбавки
    k_down        NUMBER; -- скидки
    k_srok        NUMBER; -- за срок страхования
    k_nolosses    NUMBER; -- за безубыточность
    k_tpaynent    NUMBER; -- за порядок выплат
    k_underr      NUMBER; -- коэффициент андеррайтера
    k_f_fighting  NUMBER; -- коэффициент за меры пожаротушения
    k_f_detection NUMBER; -- коэффициент за меры пожарного оповещения
    k_pml         NUMBER; -- коэффициент за PML
    k_deduct      NUMBER; -- коэффициент за франшизу
    k_risk        NUMBER; -- коэфициент за категорию риска
    ap_id         NUMBER;
  
    sum_not_con NUMBER; -- сумма по коробке
  
    p_ws    NUMBER;
    p_act   VARCHAR(24);
    p_h_id  NUMBER;
    p_s_id  NUMBER;
    p_srok  VARCHAR(24);
    p_datas DATE;
    p_datae DATE;
    p_pr    VARCHAR2(100);
  
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT ap.is_warehouse
          ,ap.act_type_code
          ,ap.t_warehouse_height_id
          ,ap.t_warehouse_space_id
          ,tp.description
          ,pp.start_date
          ,pp.end_date
          ,ap.as_property_id
          ,pr.brief
      INTO p_ws
          ,p_act
          ,p_h_id
          ,p_s_id
          ,p_srok
          ,p_datas
          ,p_datae
          ,ap_id
          ,p_pr
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = ap.p_policy_id
     INNER JOIN ven_t_period tp
        ON tp.id = pp.period_id
     INNER JOIN ven_p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     INNER JOIN ven_t_product pr
        ON ph.product_id = pr.product_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    -- !!! вычисляем переменные
    sum_not_con := 0;
    SELECT SUM(ap.ins_sum) summ
      INTO sum_not_con
      FROM as_property_stuff ap
     WHERE ap.as_property_id = ap_id;
  
    -- базовая ставка по зданию
    b_b := pkg_tariff_calc.calc_fun('PROPERTY_BASE_BUILD', v_p_cover.ent_id, p_p_cover_id);
  
    -- значение коэффициента за размеры склада
    IF (p_ws = 1)
    THEN
      k_ws := pkg_tariff_calc.calc_fun('PROPERTY_WAREHOUSE_SIZE', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      k_ws := 1;
    END IF;
  
    -- значение коэффициента за конструктив
    k_con := pkg_tariff_calc.calc_fun('PROPERTY_CONSTRUCT_UNT', v_p_cover.ent_id, p_p_cover_id);
    -- срок страхования
    IF (CEIL(MONTHS_BETWEEN(p_datae, p_datas)) > 12)
    THEN
      k_srok := ROUND(CEIL(MONTHS_BETWEEN(p_datae, p_datas)) / 12, 5);
    ELSE
      k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
  
    -- значение коэффициента по надбавкам
    k_upp := pkg_tariff_calc.calc_fun('PROPERTY_LOADINGS', v_p_cover.ent_id, p_p_cover_id);
  
    -- значение коэффициента по скидкам
    k_down := pkg_tariff_calc.calc_fun('PROPERTY_DISCOUNTS', v_p_cover.ent_id, p_p_cover_id);
  
    -- значение коэффициента по мерам пожартушения
    k_f_fighting := pkg_tariff_calc.calc_fun('PROPERTY_MER_FIRE', v_p_cover.ent_id, p_p_cover_id);
  
    -- значение коэффициента по системам пожарооповещения
    k_f_detection := pkg_tariff_calc.calc_fun('PROPERTY_NOT_FIRE', v_p_cover.ent_id, p_p_cover_id);
    -- значение коэффициента за PML
    k_pml := pkg_tariff_calc.calc_fun('PROPERTY_PML', v_p_cover.ent_id, p_p_cover_id);
    -- значение коэффициента за франшизу
    k_deduct := nvl(pkg_tariff_calc.calc_fun('PROPERTY_DEDUCT_UNTYPED', v_p_cover.ent_id, p_p_cover_id)
                   ,1);
    -- значение коэффициента за безубыточность
    k_nolosses := nvl(pkg_tariff_calc.calc_fun('PROPERTY_NO_LOSSES_UNTYPED'
                                              ,v_p_cover.ent_id
                                              ,p_p_cover_id)
                     ,1);
    -- коэффициента за категорию риска
    k_risk := pkg_tariff_calc.calc_fun('PROPERTY_RISC_CLASS', v_p_cover.ent_id, p_p_cover_id);
    -- за порядок выплат
    k_tpaynent := nvl(pkg_tariff_calc.calc_fun('PROPERTY_TYPE_PAYMENT_UNTYPED'
                                              ,v_p_cover.ent_id
                                              ,p_p_cover_id)
                     ,1);
    -- андеррайтерский коэффициент 
    k_underr := pkg_tariff_calc.calc_fun('PROPERTY_UNDERWRITER', v_p_cover.ent_id, p_p_cover_id);
  
    -- !!! если ручной ввод  
    IF v_p_cover.is_handchange_amount = 1
    THEN
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        -- !!! обновление коэффициентов
        CASE coef.brief
          WHEN 'PROPERTY_BASE_BUILD' THEN
            update_default_val(coef.p_cover_coef_id, b_b);
          WHEN 'PROPERTY_WAREHOUSE_SIZE' THEN
            update_default_val(coef.p_cover_coef_id, k_ws);
          WHEN 'PROPERTY_CONSTRUCT_UNT' THEN
            update_default_val(coef.p_cover_coef_id, k_con);
          WHEN 'DURATION' THEN
            update_default_val(coef.p_cover_coef_id, k_srok);
          
          WHEN 'PROPERTY_LOADINGS' THEN
            update_default_val(coef.p_cover_coef_id, k_upp);
          WHEN 'PROPERTY_DISCOUNTS' THEN
            update_default_val(coef.p_cover_coef_id, k_down);
          WHEN 'PROPERTY_MER_FIRE' THEN
            update_default_val(coef.p_cover_coef_id, k_f_fighting);
          WHEN 'PROPERTY_NOT_FIRE' THEN
            update_default_val(coef.p_cover_coef_id, k_f_detection);
          WHEN 'PROPERTY_PML' THEN
            update_default_val(coef.p_cover_coef_id, k_pml);
          WHEN 'PROPERTY_DEDUCT_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, k_deduct);
          WHEN 'PROPERTY_NO_LOSSES_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, k_nolosses);
          WHEN 'PROPERTY_TYPE_PAYMENT_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, k_tpaynent);
          WHEN 'PROPERTY_UNDERWRITER' THEN
            update_default_val(coef.p_cover_coef_id, k_underr);
          WHEN 'PROPERTY_RISC_CLASS' THEN
            update_default_val(coef.p_cover_coef_id, k_risk);
        END CASE;
      END LOOP;
      RETURN recalc_tariff_flexa_untyped(p_p_cover_id);
    ELSE
    
      -- !!! вычисляем результат 
      v_result := ROUND((b_b * sum_not_con * k_ws * k_con * k_srok * k_nolosses * k_tpaynent * k_pml *
                        k_deduct / 100) * (k_underr + k_risk - 1) * (k_upp + k_down - 1) *
                        (1 - (least((2 - k_f_fighting - k_f_detection), 0.75)))
                       ,2);
    
      -- !!! регистрируем коэффициенты
      reg_coeff(p_p_cover_id, 'PROPERTY_BASE_BUILD', b_b); -- базовый тариф по здания
      reg_coeff(p_p_cover_id, 'PROPERTY_WAREHOUSE_SIZE', k_ws); -- значение коэффициента за размеры склада
      reg_coeff(p_p_cover_id, 'PROPERTY_CONSTRUCT_UNT', k_con); -- значение коэффициента за конструктив
      reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- срок страхования
      reg_coeff(p_p_cover_id, 'PROPERTY_LOADINGS', k_upp); -- значение коэффициента по надбавкам
      reg_coeff(p_p_cover_id, 'PROPERTY_DISCOUNTS', k_down); -- значение коэффициента по скидкам
      reg_coeff(p_p_cover_id, 'PROPERTY_MER_FIRE', k_f_fighting); -- значение коэффициента по мерам пожартушения
      reg_coeff(p_p_cover_id, 'PROPERTY_NOT_FIRE', k_f_detection); -- значение коэффициента по системам пожарооповещения
      reg_coeff(p_p_cover_id, 'PROPERTY_PML', k_pml); -- значение коэффициента за PML
      reg_coeff(p_p_cover_id, 'PROPERTY_DEDUCT_UNTYPED', k_deduct); -- значение коэффициента за франшизу
      reg_coeff(p_p_cover_id, 'PROPERTY_NO_LOSSES_UNTYPED', k_nolosses); -- значение коэффициента за безубыточность
      reg_coeff(p_p_cover_id, 'PROPERTY_RISC_CLASS', k_risk); -- коэффициент за категорию риска
      reg_coeff(p_p_cover_id, 'PROPERTY_TYPE_PAYMENT_UNTYPED', k_tpaynent); -- значение коэффициента за порядок выплаты
      reg_coeff(p_p_cover_id, 'PROPERTY_UNDERWRITER', k_underr); -- андеррайтерский коэффициент
    END IF;
    RETURN v_result;
  END;

  -- прочие риски
  FUNCTION calc_tariff_property_other(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER;
    b_b         NUMBER;
    b_c         NUMBER;
    koef_deduct NUMBER;
    k_srok      NUMBER;
    k_pboul     NUMBER;
    k_pkg       NUMBER;
    k_nolosses  NUMBER;
    k_tpaynent  NUMBER;
    k_underr    NUMBER;
    p_datas     DATE;
    p_datae     DATE;
    p_pr        VARCHAR2(100);
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pp.start_date
          ,pp.end_date
          ,pr.brief
      INTO p_datas
          ,p_datae
          ,p_pr
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = ap.p_policy_id
     INNER JOIN ven_p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     INNER JOIN ven_t_product pr
        ON ph.product_id = pr.product_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    IF p_pr LIKE 'ИЮЛ-Типовой%'
    THEN
      -- !!! расчитываем переменные
    
      -- базовая ставка по зданию
      b_b := pkg_tariff_calc.calc_fun('PROPERTY_OTHER_RISK_BUILD', v_p_cover.ent_id, p_p_cover_id);
    
      -- базовая ставка по содержимому
      b_c := pkg_tariff_calc.calc_fun('PROPERTY_OTHER_RISK_CONTENTS', v_p_cover.ent_id, p_p_cover_id);
      -- коэффициент за франшизу
      koef_deduct := pkg_tariff_calc.calc_fun('PROPERTY_DEDUCT_OTHER_RISK'
                                             ,v_p_cover.ent_id
                                             ,p_p_cover_id);
      -- срок страхования
      IF (CEIL(MONTHS_BETWEEN(p_datae, p_datas)) > 12)
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(p_datae, p_datas)) / 12, 5);
      ELSE
        k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
      END IF;
      -- за безубыточность
      k_nolosses := nvl(pkg_tariff_calc.calc_fun('PROPERTY_NO_LOSSES', v_p_cover.ent_id, p_p_cover_id)
                       ,1);
      -- порядок выплат
      k_tpaynent := nvl(pkg_tariff_calc.calc_fun('PROPERTY_TYPE_PAYMENT'
                                                ,v_p_cover.ent_id
                                                ,p_p_cover_id)
                       ,1);
      -- андеррайтерский коэффициент
      k_underr := nvl(pkg_tariff_calc.calc_fun('PROPERTY_UNDERR_OTHER', v_p_cover.ent_id, p_p_cover_id)
                     ,1);
      -- ПБОЮЛ
      k_pboul := nvl(pkg_tariff_calc.calc_fun('PROPERTY_IS_PBOUL', v_p_cover.ent_id, p_p_cover_id), 1);
      -- ПАКЕТ
      k_pkg := pkg_tariff_calc.calc_fun('PROPERTY_PACKAGE', v_p_cover.ent_id, p_p_cover_id);
    
      -- !!! если ручной ввод
      IF v_p_cover.is_handchange_amount = 1
      THEN
        FOR coef IN (SELECT pcc.p_cover_coef_id
                           ,pct.brief
                       FROM p_cover_coef pcc
                       JOIN t_prod_coef_type pct
                         ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                      WHERE pcc.p_cover_id = p_p_cover_id)
        LOOP
          -- !!! обновление коэффициентов
          CASE coef.brief
            WHEN 'PROPERTY_OTHER_RISK_BUILD' THEN
              update_default_val(coef.p_cover_coef_id, b_b);
            WHEN 'PROPERTY_OTHER_RISK_CONTENTS' THEN
              update_default_val(coef.p_cover_coef_id, b_c);
            WHEN 'PROPERTY_DEDUCT_OTHER_RISK' THEN
              update_default_val(coef.p_cover_coef_id, koef_deduct);
            WHEN 'DURATION' THEN
              update_default_val(coef.p_cover_coef_id, k_srok);
            WHEN 'PROPERTY_NO_LOSSES' THEN
              update_default_val(coef.p_cover_coef_id, k_nolosses);
            WHEN 'PROPERTY_TYPE_PAYMENT' THEN
              update_default_val(coef.p_cover_coef_id, k_tpaynent);
            WHEN 'PROPERTY_UNDERR_OTHER' THEN
              update_default_val(coef.p_cover_coef_id, k_underr);
            WHEN 'PROPERTY_IS_PBOUL' THEN
              update_default_val(coef.p_cover_coef_id, k_pboul);
            WHEN 'PROPERTY_PACKAGE' THEN
              update_default_val(coef.p_cover_coef_id, k_pkg);
          END CASE;
        END LOOP;
        RETURN recalc_tariff_flexa_type(p_p_cover_id);
      ELSE
        -- !!! вычисляем результат
        v_result := 0;
        FOR cur IN (SELECT SUM(aps.ins_sum) summ
                          ,aps.is_contents
                      FROM p_cover pc
                      JOIN as_property ap
                        ON ap.as_property_id = pc.as_asset_id
                      LEFT JOIN as_property_stuff aps
                        ON aps.as_property_id = ap.as_property_id
                     WHERE pc.p_cover_id = p_p_cover_id
                     GROUP BY aps.is_contents)
        LOOP
          CASE cur.is_contents
            WHEN 1 THEN
              v_result := v_result + cur.summ * b_c / 100;
            ELSE
              v_result := v_result + cur.summ * b_b / 100;
          END CASE;
        END LOOP;
        v_result := v_result * koef_deduct * k_srok * k_nolosses * k_tpaynent * k_underr * k_pboul *
                    k_pkg;
      
        -- !!! регистрируем коэффициенты
        reg_coeff(p_p_cover_id, 'PROPERTY_OTHER_RISK_BUILD', b_b); -- базовый тариф по здания
        reg_coeff(p_p_cover_id, 'PROPERTY_OTHER_RISK_CONTENTS', b_c); -- базовый тариф по содержимому
        reg_coeff(p_p_cover_id, 'PROPERTY_DEDUCT_OTHER_RISK', koef_deduct); -- коэффициент за франшизу
        reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- срок страхования
        reg_coeff(p_p_cover_id, 'PROPERTY_NO_LOSSES', k_nolosses); -- значение коэффициента за безубыточность
        reg_coeff(p_p_cover_id, 'PROPERTY_TYPE_PAYMENT', k_tpaynent); -- значение коэффициента за порядок выплаты
        reg_coeff(p_p_cover_id, 'PROPERTY_UNDERR_OTHER', k_underr); -- андеррайтерский коэффициент
        reg_coeff(p_p_cover_id, 'PROPERTY_IS_PBOUL', k_pboul); -- значение коэффициента за ПБОЮЛ
        reg_coeff(p_p_cover_id, 'PROPERTY_PACKAGE', k_pkg); -- значение коэффициента за порядок выплаты
      END IF;
    
    ELSE
      -- если продукт Нетиповой
      v_result := calc_tariff_pr_other_untyped(p_p_cover_id);
    END IF;
    RETURN v_result;
  END;

  -- прочие риски для нетипового объекта
  FUNCTION calc_tariff_pr_other_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER; -- премия
    b_b         NUMBER; -- базовая ставка
    koef_deduct NUMBER; -- коэффициент за франшизу
    k_tpaynent  NUMBER; -- за порядок выплат
    k_srok      NUMBER; -- за срок страхования
    k_risk      NUMBER; -- коэффициент за категорию риска
    k_underr    NUMBER; -- андеррайтерский коэффициент
    p_datas     DATE;
    p_datae     DATE;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pp.start_date
          ,pp.end_date
      INTO p_datas
          ,p_datae
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = ap.p_policy_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    -- !!! расчитываем переменные
  
    -- базовая ставка
    b_b := pkg_tariff_calc.calc_fun('PROPERTY_BASE_OTHER_UNTYPED', v_p_cover.ent_id, p_p_cover_id);
    -- франшиза
    koef_deduct := pkg_tariff_calc.calc_fun('PROPERTY_DEDUCT_OTHER_UNTYPED'
                                           ,v_p_cover.ent_id
                                           ,p_p_cover_id);
    -- срок страхования
    IF (CEIL(MONTHS_BETWEEN(p_datae, p_datas)) > 12)
    THEN
      k_srok := ROUND(CEIL(MONTHS_BETWEEN(p_datae, p_datas)) / 12, 5);
    ELSE
      k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
    -- за порядок выплат
    k_tpaynent := nvl(pkg_tariff_calc.calc_fun('PROPERTY_TYPE_PAYMENT_UNTYPED'
                                              ,v_p_cover.ent_id
                                              ,p_p_cover_id)
                     ,1);
    -- коэффициента за категорию риска
    k_risk := pkg_tariff_calc.calc_fun('PROPERTY_RISC_CLASS', v_p_cover.ent_id, p_p_cover_id);
    -- андеррайтерский коэффициент
    k_underr := nvl(pkg_tariff_calc.calc_fun('PROPERTY_UNDERR_OTHER', v_p_cover.ent_id, p_p_cover_id)
                   ,1);
  
    -- !!! если ручной ввод  
    IF v_p_cover.is_handchange_amount = 1
    THEN
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        -- !!! обновление коэффициентов
        CASE coef.brief
          WHEN 'PROPERTY_BASE_OTHER_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, b_b);
          WHEN 'DURATION' THEN
            update_default_val(coef.p_cover_coef_id, k_srok);
          WHEN 'PROPERTY_DEDUCT_OTHER_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, koef_deduct);
          WHEN 'PROPERTY_TYPE_PAYMENT_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, k_tpaynent);
          WHEN 'PROPERTY_UNDERR_OTHER' THEN
            update_default_val(coef.p_cover_coef_id, k_underr);
          WHEN 'PROPERTY_RISC_CLASS' THEN
            update_default_val(coef.p_cover_coef_id, k_risk);
        END CASE;
      END LOOP;
      RETURN recalc_tariff_flexa_untyped(p_p_cover_id);
    ELSE
      -- !!! вычисляем результат
      v_result := 0;
      SELECT SUM(aps.ins_sum) summ
        INTO v_result
        FROM p_cover pc
        LEFT JOIN as_property_stuff aps
          ON aps.as_property_id = v_p_cover.as_asset_id
       WHERE pc.p_cover_id = p_p_cover_id;
    
      v_result := v_result * b_b / 100 * koef_deduct * (k_risk + k_underr - 1);
    
      -- !!! регистрируем коэффициенты
      reg_coeff(p_p_cover_id, 'PROPERTY_BASE_OTHER_UNTYPED', b_b); -- базовый тариф по здания
      reg_coeff(p_p_cover_id, 'PROPERTY_DEDUCT_OTHER_UNTYPED', koef_deduct); -- коэффициент за франшизу
      reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- срок страхования
      reg_coeff(p_p_cover_id, 'PROPERTY_TYPE_PAYMENT_UNTYPED', k_tpaynent); -- значение коэффициента за порядок выплаты
      reg_coeff(p_p_cover_id, 'PROPERTY_RISC_CLASS', k_risk); -- коэффициент за категорию риска
      reg_coeff(p_p_cover_id, 'PROPERTY_UNDERR_OTHER', k_underr); -- андеррайтерский коэффициент
    END IF;
    RETURN v_result;
  END;

  FUNCTION calc_tariff_property_glass(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER;
    b           NUMBER;
    k_srok      NUMBER;
    k_underr    NUMBER;
    p_pr        VARCHAR2(100);
    sum_not_con NUMBER;
    ap_id       NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pr.brief
          ,ap.as_property_id
          ,ap.ins_amount
      INTO p_pr
          ,ap_id
          ,sum_not_con
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = ap.p_policy_id
     INNER JOIN ven_p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     INNER JOIN ven_t_product pr
        ON ph.product_id = pr.product_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    IF p_pr = 'ИЮЛ-Типовой'
    THEN
    
      -- !!! расчитывем переменные
    
      -- базовая ставка
      b := pkg_tariff_calc.calc_fun('PROPERTY_BT_GLASS', v_p_cover.ent_id, p_p_cover_id);
      --срок страхования
      IF (CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) > 12)
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
      ELSE
        k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
      END IF;
      -- андеррайтерский коэффициент
      k_underr := nvl(pkg_tariff_calc.calc_fun('PROPERTY_UNDERR_OTHER', v_p_cover.ent_id, p_p_cover_id)
                     ,1);
    
      -- !!! если ручной ввод
      IF v_p_cover.is_handchange_amount = 1
      THEN
        FOR coef IN (SELECT pcc.p_cover_coef_id
                           ,pct.brief
                       FROM p_cover_coef pcc
                       JOIN t_prod_coef_type pct
                         ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                      WHERE pcc.p_cover_id = p_p_cover_id)
        LOOP
          -- !!! обновление коэффициентов
          CASE coef.brief
            WHEN 'PROPERTY_BT_GLASS' THEN
              update_default_val(coef.p_cover_coef_id, b);
            WHEN 'DURATION' THEN
              update_default_val(coef.p_cover_coef_id, k_srok);
            WHEN 'PROPERTY_UNDERR_OTHER' THEN
              update_default_val(coef.p_cover_coef_id, k_underr);
          END CASE;
        END LOOP;
        RETURN sum_not_con * calc_tarif_mul(p_p_cover_id) / 100;
      ELSE
        -- !!! вычисляем результат
        v_result := ROUND(sum_not_con * b / 100 * k_srok * k_underr, 2);
      
        -- !!! регистрируем коэффициенты
        reg_coeff(p_p_cover_id, 'PROPERTY_BT_GLASS', b); -- базовый тариф за стекла
        reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- коэффициент за срок страхования
        reg_coeff(p_p_cover_id, 'PROPERTY_UNDERR_OTHER', k_underr); -- андеррайтерский коэффициент
      END IF;
    
    ELSE
      -- если продукт Нетиповой
      v_result := calc_tariff_pr_glass_untyped(p_p_cover_id);
    END IF;
    RETURN v_result;
  END;

  FUNCTION calc_tariff_pr_glass_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER;
    b           NUMBER;
    k_risk      NUMBER;
    k_underr    NUMBER;
    k_srok      NUMBER;
    k_tpaynent  NUMBER;
    p_datas     DATE;
    p_datae     DATE;
    sum_not_con NUMBER;
    ap_id       NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pp.start_date
          ,pp.end_date
          ,ap.as_property_id
          ,ap.ins_amount
      INTO p_datas
          ,p_datae
          ,ap_id
          ,sum_not_con
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = ap.p_policy_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    --!!! расчитываем переменные
  
    -- базовый коэффициент по стеклам
    b := pkg_tariff_calc.calc_fun('PROPERTY_BT_GLASS', v_p_cover.ent_id, p_p_cover_id);
    -- срок страхования
    IF (CEIL(MONTHS_BETWEEN(p_datae, p_datas)) > 12)
    THEN
      k_srok := ROUND(CEIL(MONTHS_BETWEEN(p_datae, p_datas)) / 12, 5);
    ELSE
      k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
    -- за порядок выплат
    k_tpaynent := nvl(pkg_tariff_calc.calc_fun('PROPERTY_TYPE_PAYMENT_UNTYPED'
                                              ,v_p_cover.ent_id
                                              ,p_p_cover_id)
                     ,1);
    -- коэффициента за категорию риска
    k_risk := pkg_tariff_calc.calc_fun('PROPERTY_RISK_CLASS_UNTYPED', v_p_cover.ent_id, p_p_cover_id);
    -- андеррайтерский коэффициент
    k_underr := nvl(pkg_tariff_calc.calc_fun('PROPERTY_UNDERR_OTHER', v_p_cover.ent_id, p_p_cover_id)
                   ,1);
    -- !!! если ручной ввод
    IF v_p_cover.is_handchange_amount = 1
    THEN
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        -- !!! обновление коэффициентов
        CASE coef.brief
          WHEN 'PROPERTY_BT_GLASS' THEN
            update_default_val(coef.p_cover_coef_id, b);
          WHEN 'DURATION' THEN
            update_default_val(coef.p_cover_coef_id, k_srok);
          WHEN 'PROPERTY_UNDERR_OTHER' THEN
            update_default_val(coef.p_cover_coef_id, k_underr);
          WHEN 'PROPERTY_TYPE_PAYMENT_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, k_tpaynent);
          WHEN 'PROPERTY_RISK_CLASS_UNTYPED' THEN
            update_default_val(coef.p_cover_coef_id, k_risk);
        END CASE;
      END LOOP;
      RETURN recalc_tariff_glass_untyped(p_p_cover_id);
    ELSE
      -- !!! вычисляем результат
      v_result := ROUND(sum_not_con * b / 100 * k_srok * k_tpaynent * (k_underr + k_risk - 1), 2);
    
      -- !!! регистрируем коэффициенты
      reg_coeff(p_p_cover_id, 'PROPERTY_BT_GLASS', b); -- базовый тариф за стекла
      reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- срок страхования
      reg_coeff(p_p_cover_id, 'PROPERTY_TYPE_PAYMENT_UNTYPED', k_tpaynent); -- значение коэффициента за порядок выплаты
      reg_coeff(p_p_cover_id, 'PROPERTY_RISK_CLASS_UNTYPED', k_risk); -- коэффициент за категорию риска
      reg_coeff(p_p_cover_id, 'PROPERTY_UNDERR_OTHER', k_underr); -- андеррайтерский коэффициент
    END IF;
    RETURN v_result;
  END;

  -- для ручного ввода при расчете Flexa типовой
  FUNCTION recalc_tariff_flexa_type(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER;
    sum_con     NUMBER; -- сумма по содержимому
    sum_not_con NUMBER; -- сумма по коробке
    v_res       NUMBER;
  
    b_b NUMBER;
    b_c NUMBER;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    sum_con     := 0;
    sum_not_con := 0;
    FOR cur IN (SELECT nvl(ap.is_contents, 0) c
                      ,SUM(ap.ins_sum) summ
                  FROM as_property_stuff ap
                 WHERE ap.as_property_id = v_p_cover.as_asset_id
                 GROUP BY ap.is_contents)
    LOOP
      CASE cur.c
        WHEN 1 THEN
          sum_con := cur.summ; -- содер
        ELSE
          sum_not_con := cur.summ; --коробка
      END CASE;
    END LOOP;
  
    SELECT SUM(pcc.val)
      INTO b_b
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief IN ('PROPERTY_BASE_BUILD', 'PROPERTY_OTHER_RISK_BUILD');
  
    SELECT nvl(SUM(pcc.val), 0)
      INTO b_c
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief IN ('PROPERTY_BASE_CONTENTS', 'PROPERTY_OTHER_RISK_CONTENTS');
  
    v_res := 1;
    FOR v_c IN (SELECT pcc.val
                  FROM p_cover_coef pcc
                  JOIN t_prod_coef_type pct
                    ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                 WHERE pcc.p_cover_id = p_p_cover_id
                   AND pct.brief NOT IN ('PROPERTY_BASE_BUILD'
                                        ,'PROPERTY_BASE_CONTENTS'
                                        ,'PROPERTY_OTHER_RISK_BUILD'
                                        ,'PROPERTY_OTHER_RISK_CONTENTS'))
    LOOP
      v_res := v_res * v_c.val;
    END LOOP;
  
    v_result := ROUND((b_b * sum_not_con + b_c * sum_con) * v_res / 100, 2);
    RETURN v_result;
  END;

  -- для ручного ввода при расчете Flexa НЕтиповой
  FUNCTION recalc_tariff_flexa_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER;
    sum_not_con NUMBER; -- сумма по коробке
    v_res       NUMBER; --  результирующий коэффициент
  
    k_corr  NUMBER; -- корректировка (надбавка - скидка)
    k_fire  NUMBER; -- коэффициент по пожарам
    k_final NUMBER; -- финальные корректировки (за риск и андеррайтер)
  
    b_b    NUMBER;
    p_prog VARCHAR2(250);
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pl.description
      INTO p_prog
      FROM p_cover p
      JOIN t_prod_line_option plo
        ON p.t_prod_line_option_id = plo.id
      JOIN t_product_line pl
        ON pl.id = plo.product_line_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    sum_not_con := 0;
    SELECT SUM(ap.ins_sum) summ
      INTO sum_not_con
      FROM as_property_stuff ap
     WHERE ap.as_property_id = v_p_cover.as_asset_id;
  
    SELECT SUM(pcc.val)
      INTO b_b
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief IN ('PROPERTY_BASE_BUILD', 'PROPERTY_BASE_OTHER_UNTYPED', 'PROPERTY_BT_GLASS');
  
    SELECT nvl(SUM(pcc.val), 2)
      INTO k_final
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief IN ('PROPERTY_RISC_CLASS', 'PROPERTY_UNDERWRITER', 'PROPERTY_UNDERR_OTHER');
  
    v_res := 1;
    FOR v_c IN (SELECT pcc.val
                  FROM p_cover_coef pcc
                  JOIN t_prod_coef_type pct
                    ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                 WHERE pcc.p_cover_id = p_p_cover_id
                   AND pct.brief NOT IN ('PROPERTY_BASE_BUILD'
                                        ,'PROPERTY_BASE_OTHER_UNTYPED'
                                        ,'PROPERTY_BT_GLASS'
                                        ,'PROPERTY_LOADINGS'
                                        ,'PROPERTY_DISCOUNTS'
                                        ,'PROPERTY_MER_FIRE'
                                        ,'PROPERTY_NOT_FIRE'
                                        ,'PROPERTY_RISC_CLASS'
                                        ,'PROPERTY_UNDERWRITER'
                                        ,'PROPERTY_UNDERR_OTHER'))
    LOOP
      v_res := v_res * v_c.val;
    END LOOP;
  
    IF TRIM(upper(p_prog)) = 'FLEXA'
    THEN
      SELECT nvl(SUM(pcc.val), 2)
        INTO k_corr
        FROM p_cover_coef pcc
        JOIN t_prod_coef_type pct
          ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
       WHERE pcc.p_cover_id = p_p_cover_id
         AND pct.brief IN ('PROPERTY_LOADINGS', 'PROPERTY_DISCOUNTS');
    
      SELECT nvl(SUM(pcc.val), 2)
        INTO k_fire
        FROM p_cover_coef pcc
        JOIN t_prod_coef_type pct
          ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
       WHERE pcc.p_cover_id = p_p_cover_id
         AND pct.brief IN ('PROPERTY_MER_FIRE', 'PROPERTY_NOT_FIRE');
    
      v_result := ROUND((b_b * sum_not_con * v_res / 100) * (k_final - 1) * (k_corr - 1) *
                        (1 - (least((2 - k_fire), 0.75)))
                       ,2);
    ELSE
      v_result := ROUND((b_b * sum_not_con * v_res * (k_final - 1) / 100), 2);
    END IF;
    RETURN v_result;
  END;

  -- для ручного ввода при расчете Flexa НЕтиповой
  FUNCTION recalc_tariff_glass_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result    NUMBER;
    v_res       NUMBER; --  результирующий коэффициент
    k_final     NUMBER; -- финальные корректировки (за риск и андеррайтер)
    sum_not_con NUMBER;
    ap_id       NUMBER;
    b_b         NUMBER;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT ap.as_property_id
          ,ap.ins_amount
      INTO ap_id
          ,sum_not_con
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT SUM(pcc.val)
      INTO b_b
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief IN ('PROPERTY_BT_GLASS');
  
    SELECT nvl(SUM(pcc.val), 2)
      INTO k_final
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief IN ('PROPERTY_RISK_CLASS_UNTYPED', 'PROPERTY_UNDERR_OTHER');
  
    v_res := 1;
    FOR v_c IN (SELECT pcc.val
                  FROM p_cover_coef pcc
                  JOIN t_prod_coef_type pct
                    ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                 WHERE pcc.p_cover_id = p_p_cover_id
                   AND pct.brief NOT IN
                       ('PROPERTY_BT_GLASS', 'PROPERTY_RISK_CLASS_UNTYPED', 'PROPERTY_UNDERR_OTHER'))
    LOOP
      v_res := v_res * v_c.val;
    END LOOP;
  
    v_result := ROUND((sum_not_con * b_b / 100 * v_res * (k_final - 1)), 2);
    RETURN v_result;
  END;

  -- получаем коэффициент для расчета тарифа из программы FLEXA
  FUNCTION get_coef_from_flexa
  (
    p_p_cover_id IN NUMBER
   ,risk_name    VARCHAR2
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем киэффициента за категорию риска
    -- для программы Flexa по тому же договору
    SELECT nvl(pcc.val, 1)
      INTO res
      FROM ven_p_cover p
     INNER JOIN ven_as_property ap
        ON ap.as_property_id = p.as_asset_id
     INNER JOIN ven_as_property ap1
        ON ap1.p_policy_id = ap.p_policy_id
     INNER JOIN ven_p_asset_header ah
        ON ah.p_asset_header_id = ap1.p_asset_header_id
     INNER JOIN t_asset_type att
        ON att.t_asset_type_id = ah.t_asset_type_id
      LEFT JOIN ven_p_cover p1
        ON ap1.as_property_id = p1.as_asset_id
      LEFT JOIN ven_t_prod_line_option plo
        ON p1.t_prod_line_option_id = plo.id
      LEFT JOIN ven_t_product_line pln
        ON pln.id = plo.product_line_id
      LEFT JOIN ven_p_cover_coef pcc
        ON pcc.p_cover_id = p1.p_cover_id
      LEFT JOIN ven_t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE p.p_cover_id = p_p_cover_id
       AND nvl(att.brief, 'PROPERTY') = 'PROPERTY'
       AND nvl(pln.description, 'FLEXA') = 'FLEXA'
       AND nvl(pct.brief, risk_name) = risk_name
       AND rownum = 1;
    RETURN nvl(res, 1);
  END;

  -- получаем коэффициент а категорию риска для расчета тарифа
  -- используется для ИЮЛ - нетиповой, программа "бой стекол, зеркал"
  FUNCTION get_class_risk_flexa(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем киэффициента за категорию риска
    -- для программы Flexa по тому же договору
    res := get_coef_from_flexa(p_p_cover_id, 'PROPERTY_RISC_CLASS');
    RETURN nvl(res, 1);
  END;

  -- получаем андеррайтерский коэффициент заданный во FLEXA
  FUNCTION get_underr_flexa(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем андеррайтерский киэффициент
    -- для программы Flexa по тому же договору
    res := get_coef_from_flexa(p_p_cover_id, 'PROPERTY_UNDERWRITER');
    RETURN nvl(res, 1);
  END;

  -- получаем коэффициент за конструктив для нетипового продукта
  FUNCTION get_constract_untyped(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  
  BEGIN
    SELECT CASE
             WHEN bc.code IN ('1а', '1б') THEN
              1
             WHEN bc.code IN ('2', '3') THEN
              1.1
             WHEN bc.code IN ('4', '5') THEN
              0.45 / ins.pkg_tariff.get_coef_from_flexa(p_p_cover_id, 'PROPERTY_BASE_BUILD')
           END
      INTO res
      FROM p_cover p
      JOIN as_asset ass
        ON ass.as_asset_id = p.as_asset_id
      JOIN as_property ap
        ON ap.as_property_id = ass.as_asset_id
      JOIN t_build_construct bc
        ON ap.t_build_construct_id = bc.t_build_construct_id
     WHERE p_cover_id = p_p_cover_id;
    RETURN nvl(res, 1);
  END;
  FUNCTION calc_tariff_property_sm_pack(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
    b        NUMBER;
    k_fr     NUMBER;
    k_ar     NUMBER;
    k_srok   NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    b := pkg_tariff_calc.calc_fun('PROPERTY_INSSUM_SPEC_MACH', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_INSSUM_SPEC_MACH', b); -- базовый тариф за пакет
  
    k_fr := nvl(pkg_tariff_calc.calc_fun('PROPERTY_DEDUCT_SPEC_MACH', v_p_cover.ent_id, p_p_cover_id)
               ,1);
    reg_coeff(p_p_cover_id, 'PROPERTY_DEDUCT_SPEC_MACH', k_fr); -- коэффициент за франшизу
  
    k_ar := pkg_tariff_calc.calc_fun('PROPERTY_AREA_SPEC_MACH', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_AREA_SPEC_MACH', k_ar); -- коэффициент за территорию
  
    IF (CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) > 12)
    THEN
      k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
    ELSE
      k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
    reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- коэффициент за срок страхования
  
    v_result := b * k_fr * k_ar * k_srok;
    RETURN v_result;
  END;

  FUNCTION calc_tariff_property_sm_avar(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
    b        NUMBER;
    k_fr     NUMBER;
    k_ar     NUMBER;
    k_srok   NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    b := pkg_tariff_calc.calc_fun('PROPERTY_AVARIA', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_AVARIA', b); -- базовый тариф за аварию
  
    k_fr := pkg_tariff_calc.calc_fun('PROPERTY_DEDUCT_SPEC_MACH', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_DEDUCT_SPEC_MACH', k_fr); -- коэффициент за франшизу
  
    k_ar := pkg_tariff_calc.calc_fun('PROPERTY_AREA_SPEC_MACH', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_AREA_SPEC_MACH', k_ar); -- коэффициент за территорию
  
    IF (CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) > 12)
    THEN
      k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
    ELSE
      k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
    reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- коэффициент за срок страхования
  
    v_result := b * k_fr * k_ar * k_srok;
  
    RETURN v_result;
  END;

  FUNCTION calc_tariff_property_srisks(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
    b        NUMBER;
    k_srok   NUMBER;
    k_insam  NUMBER;
    k_ded    NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    b := nvl(pkg_tariff_calc.calc_fun('PROPERTY_BT_SR', v_p_cover.ent_id, p_p_cover_id), 0);
    reg_coeff(p_p_cover_id, 'PROPERTY_BT_SR', b); -- базовый тариф за спецриск
  
    k_insam := pkg_tariff_calc.calc_fun('PROPERTY_INSAMOUNT_SR', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_INSAMOUNT_SR', k_insam); -- коэффициент за значение страховой суммы
  
    k_ded := pkg_tariff_calc.calc_fun('PROPERTY_DEDUCT_SR', v_p_cover.ent_id, p_p_cover_id);
    reg_coeff(p_p_cover_id, 'PROPERTY_DEDUCT_SR', k_ded); -- коэффициент за значение страховой суммы
  
    IF (CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) > 12)
    THEN
      k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
    ELSE
      k_srok := nvl(pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
    reg_coeff(p_p_cover_id, 'DURATION', k_srok); -- коэффициент за срок страхования
  
    v_result := b * k_insam * k_ded * k_srok;
  
    RETURN v_result;
  END;

  --////////////////////////////////////////////////////////////
  -- ////////////////////////// ИПОТЕКА
  --////////////////////////////////////////////////////////////

  --- Функция расчета страхового тарифа с базовой ставкой и андеррайтерским коэфициентом
  FUNCTION calc_tarif_mg_base_underr
  (
    p_p_cover_id IN NUMBER
   ,p_coef       VARCHAR2
  ) RETURN NUMBER AS
    v_result NUMBER;
    b        NUMBER;
    k_underr NUMBER;
    summ     NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT ass.ins_amount
      INTO summ
      FROM ven_p_cover p
     INNER JOIN ven_as_asset ass
        ON ass.as_asset_id = p.as_asset_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    -- !!! расчитываем переменные 
    b := nvl(pkg_tariff_calc.calc_fun(p_coef, v_p_cover.ent_id, p_p_cover_id), 1);
    -- андеррайтерский коэффициент
    k_underr := nvl(pkg_tariff_calc.calc_fun('MG_UNDERR', v_p_cover.ent_id, p_p_cover_id), 1);
    -- !!! если ручной ввод
    IF v_p_cover.is_handchange_amount = 1
    THEN
      FOR coeff IN (SELECT pcc.p_cover_coef_id
                          ,pct.brief
                      FROM p_cover_coef pcc
                      JOIN t_prod_coef_type pct
                        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                     WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        -- !!! обновление коэффициентов
        CASE coeff.brief
          WHEN p_coef THEN
            update_default_val(coeff.p_cover_coef_id, b);
          WHEN 'MG_UNDERR' THEN
            update_default_val(coeff.p_cover_coef_id, k_underr);
        END CASE;
      END LOOP;
      RETURN summ * calc_tarif_mul(p_p_cover_id) / 100;
    ELSE
      -- !!! вычисляем результат
      v_result := ROUND(summ * b / 100 * k_underr, 2);
    
      -- !!! регистрируем коэффициенты
      reg_coeff(p_p_cover_id, p_coef, b); -- базовый тариф
      reg_coeff(p_p_cover_id, 'MG_UNDERR', k_underr); -- андеррайтерский коэффициент
    END IF;
    RETURN v_result;
  END;

  -- расчет премии для "НС комплексное ипотечное страхование"
  FUNCTION calc_tarif_mg_ns(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  
  BEGIN
    v_result := calc_tarif_mg_base_underr(p_p_cover_id, 'MG_BASE_NS');
    RETURN v_result;
  END;

  -- расчет премии для "ИМФЛ комплексное ипотечное страхование"
  FUNCTION calc_tarif_mg_property(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    v_result := calc_tarif_mg_base_underr(p_p_cover_id, 'MG_BASE_PROPERTY');
    RETURN v_result;
  END;

  -- расчет премии для "ФР комплексное ипотечное страхование"
  FUNCTION calc_tarif_mg_titul(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    v_result := calc_tarif_mg_base_underr(p_p_cover_id, 'MG_BASE_TITUL');
    RETURN v_result;
  END;

  -- получаем произвольный коэффициент из предыдущей версии договора
  FUNCTION get_coef_from_prev_version
  (
    p_p_cover_id IN NUMBER
   ,risk_name    IN VARCHAR2
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем андеррайтерский коэффициент из предыдущей версии договора
    SELECT nvl(prev.val, 1)
      INTO res
      FROM ven_p_cover p2 -- oae
      JOIN ven_t_prod_line_option plo2
        ON p2.t_prod_line_option_id = plo2.id
      JOIN ven_as_asset ass2
        ON ass2.as_asset_id = p2.as_asset_id
      JOIN ven_p_asset_header pah2
        ON pah2.p_asset_header_id = ass2.p_asset_header_id
      JOIN ven_p_policy pp2
        ON pp2.policy_id = ass2.p_policy_id
      LEFT JOIN (SELECT p1.pol_header_id
                       ,p1.version_num
                       ,a1.p_asset_header_id
                       ,pc1.t_prod_line_option_id
                       ,pcc1.val
                   FROM p_policy p1
                   JOIN as_asset a1
                     ON a1.p_policy_id = p1.policy_id
                   JOIN p_cover pc1
                     ON pc1.as_asset_id = a1.as_asset_id
                   JOIN t_prod_line_option plo1
                     ON plo1.id = pc1.t_prod_line_option_id
                   JOIN t_product_line pl1
                     ON pl1.id = plo1.product_line_id
                   JOIN p_cover_coef pcc1
                     ON pcc1.p_cover_id = pc1.p_cover_id
                   JOIN t_prod_coef_type pct1
                     ON pct1.t_prod_coef_type_id = pcc1.t_prod_coef_type_id
                  WHERE pct1.brief = risk_name) prev
        ON prev.pol_header_id = pp2.pol_header_id
       AND prev.version_num = pp2.version_num - 1
       AND prev.p_asset_header_id = ass2.p_asset_header_id
       AND prev.t_prod_line_option_id = plo2.id
     WHERE p2.p_cover_id = p_p_cover_id
       AND rownum = 1;
  
    /*
      select nvl(pcc1.val,1)
      into res
    from ven_p_cover p2
        join ven_t_prod_line_option plo2 on p2.t_prod_line_option_id = plo2.id
        join ven_as_asset ass2 on ass2.as_asset_id = p2.as_asset_id
        join ven_p_asset_header pah2 on pah2.p_asset_header_id = ass2.p_asset_header_id
        join ven_p_policy pp2 on pp2.policy_id = ass2.p_policy_id
        left join ven_p_policy pp1 on pp1.pol_header_id = pp2.pol_header_id  and pp1.version_num = pp2.version_num -1
        left join ven_as_asset ass1 on ass1.p_policy_id = pp1.policy_id
        left join ven_p_asset_header pah1 on pah1.p_asset_header_id = ass1.p_asset_header_id and pah1.p_asset_header_id = pah2.p_asset_header_id
        left join ven_p_cover p1 on p1.as_asset_id = ass1.as_asset_id
        left join ven_t_prod_line_option plo1 on p1.t_prod_line_option_id = plo1.id and plo2.brief = plo1.brief
        left join ven_t_product_line pln1 on pln1.id = plo1.product_line_id
        left join ven_p_cover_coef pcc1 on pcc1.p_cover_id = p1.p_cover_id
        left join ven_t_prod_coef_type pct1 on pct1.t_prod_coef_type_id = pcc1.t_prod_coef_type_id and nvl(pct1.brief,risk_name) = risk_name
    where p2.p_cover_id = p_p_cover_id
         and rownum = 1;
         */
    RETURN nvl(res, 1);
  END;

  -- получаем андеррайтерский коэффициент из предыдущей версии
  FUNCTION get_underr_mg(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем андеррайтерский киэффициент
    -- для программы Flexa по тому же договору
    res := get_coef_from_prev_version(p_p_cover_id, 'MG_UNDERR');
    RETURN nvl(res, 1);
  END;

  -- получаем андеррайтерский коэффициент из предыдущей версии
  FUNCTION get_underr_35(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем андеррайтерский киэффициент
    -- для программы Flexa по тому же договору
    res := get_coef_from_prev_version(p_p_cover_id, 'CASCO_COEF_35');
    RETURN nvl(res, 1);
  END;

  -- получаем андеррайтерский коэффициент из предыдущей версии
  FUNCTION get_underr_91(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    -- запрашиваем андеррайтерский киэффициент
    -- для программы Flexa по тому же договору
    res := get_coef_from_prev_version(p_p_cover_id, 'CASCO_COEF_91');
    RETURN nvl(res, 1);
  END;

  --////////////////////////////////////////////////////////////
  -- ////////////////////////// ОСАГО
  --////////////////////////////////////////////////////////////
  FUNCTION calc_tariff_osago(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result           NUMBER;
    v_tvt_brief        VARCHAR2(30);
    v_tvu_brief        VARCHAR2(30);
    v_is_individual    NUMBER(1);
    v_is_ind           NUMBER(1);
    v_is_driver_no_lim NUMBER(1);
    v_is_violation     NUMBER(1);
    v_is_reg           NUMBER(1);
    v_is_sng           NUMBER(1);
    v_is_for           NUMBER(1);
    v_period           VARCHAR2(30);
  
    k_tb  NUMBER;
    k_kt  NUMBER;
    k_kbm NUMBER;
    k_kvs NUMBER;
    k_ko  NUMBER;
    k_km  NUMBER;
    k_ks  NUMBER;
    k_kp  NUMBER;
    k_kn  NUMBER;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    IF v_p_cover.is_handchange_amount = 1
    THEN
      RETURN calc_tarif_mul(p_p_cover_id);
    END IF;
  
    SELECT vt.brief
          ,vu.brief
          ,ct.is_individual
          ,ct1.is_individual
          ,av.is_driver_no_lim
          ,av.is_violation
          ,av.is_foreing_reg
          ,av.is_sng_reg
          ,av.is_to_reg
          ,per.description
    
      INTO v_tvt_brief
          , -- тип ТС
           v_tvu_brief
          , -- цель использования ТС
           v_is_individual
          , -- тип собственника ТС (ФЛ или ЮЛ)
           v_is_ind
          , -- тип страхователя ТС (ФЛ или ЮЛ)
           v_is_driver_no_lim
          , -- признак ограниченности допущенных к управлению
           v_is_violation
          ,v_is_for
          , -- зарегистрировано в иностранном государстве
           v_is_sng
          , -- зарегистрировано в Белоруссия, Украина, Казахстан
           v_is_reg
          , -- следует к месте регистрации
           v_period -- срок страхования
      FROM ven_p_cover pc
     INNER JOIN ven_as_vehicle av
        ON pc.as_asset_id = av.as_vehicle_id
     INNER JOIN ven_p_policy pp
        ON pp.policy_id = av.p_policy_id
     INNER JOIN ven_t_period per
        ON per.id = pp.period_id
     INNER JOIN ven_p_policy_contact ppc
        ON ppc.policy_id = pp.policy_id
       AND ppc.contact_policy_role_id = 6
     INNER JOIN contact c1
        ON c1.contact_id = ppc.contact_id
     INNER JOIN t_contact_type ct1
        ON ct1.id = c1.contact_type_id
     INNER JOIN t_vehicle_type vt
        ON vt.t_vehicle_type_id = av.t_vehicle_type_id
     INNER JOIN t_vehicle_usage vu
        ON vu.t_vehicle_usage_id = av.t_vehicle_usage_id
     INNER JOIN contact c
        ON c.contact_id = av.contact_id
     INNER JOIN t_contact_type ct
        ON ct.id = c.contact_type_id
     WHERE pc.p_cover_id = p_p_cover_id;
  
    -- Базовый тариф: цель использования и тип ТС
    IF (v_tvu_brief = 'TAXI')
    THEN
      k_tb := pkg_tariff_calc.calc_fun('OSAGO_USAGE', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      IF v_tvt_brief = 'CAR'
      THEN
        k_tb := pkg_tariff_calc.calc_fun('OSAGO_BASE_CAR', v_p_cover.ent_id, p_p_cover_id);
      ELSIF v_tvt_brief = 'BUS'
      THEN
        k_tb := pkg_tariff_calc.calc_fun('OSAGO_BASE_BUS', v_p_cover.ent_id, p_p_cover_id);
      ELSIF v_tvt_brief = 'TRUCK'
      THEN
        k_tb := pkg_tariff_calc.calc_fun('OSAGO_BASE_TRUCK', v_p_cover.ent_id, p_p_cover_id);
      ELSE
        k_tb := pkg_tariff_calc.calc_fun('OSAGO_BASE', v_p_cover.ent_id, p_p_cover_id);
      END IF;
    END IF;
  
    -- территория использования
    IF (v_is_for = 1 AND v_is_sng = 1)
    THEN
      k_kt := 1; -- зарегистрировано в СНГ
    ELSIF v_is_for = 1
          AND v_is_sng = 0
    THEN
      k_kt := 2; -- зарегистрировано в ин гос-ве
    ELSIF v_is_reg = 1
    THEN
      k_kt := 1; -- следует к месту регистрации
    ELSE
      k_kt := pkg_tariff_calc.calc_fun('OSAGO_AREA', v_p_cover.ent_id, p_p_cover_id);
    END IF;
  
    -- КБМ
    IF (v_is_for = 1 OR v_is_reg = 1)
    THEN
      k_kbm := 1; -- зарегистрировано в ин гос-ве или следует к месту регистрации
    ELSIF v_tvt_brief LIKE '%TRAILER'
    THEN
      k_kbm := 1; -- для всех прицепов
    ELSIF v_period != '12 месяцев'
    THEN
      k_kbm := 1; -- срок страхование != 1 году
    ELSE
      k_kbm := pkg_tariff_calc.calc_fun('OSAGO_KBM', v_p_cover.ent_id, p_p_cover_id);
    END IF;
  
    -- количество допущенных к управлению
    IF (v_is_individual = 1 AND v_is_ind = 1 AND v_is_driver_no_lim = 0)
    THEN
      k_ko := 1; -- если страхователь и собственние - ФЛ и ограничение на допущенных
    ELSIF v_tvt_brief LIKE '%TRAILER'
    THEN
      k_ko := 1; -- для всех прицепов
    ELSIF (v_is_individual = 0 AND v_is_for = 1 AND v_is_sng = 0)
    THEN
      k_ko := 1.5; -- зарегистрировано в ин гос-ве и ЮЛ
    ELSE
      k_ko := pkg_tariff_calc.calc_fun('OSAGO_IS_DRIVER_NO_LIM', v_p_cover.ent_id, p_p_cover_id);
    END IF;
  
    -- возраст и стаж допущенных к управлению
    IF v_tvt_brief LIKE '%TRAILER'
    THEN
      k_kvs := 1; -- для всех прицепов
      -- elsif (v_is_reg = 1) then
      --  k_Kvs := 1; -- для следует к месту регистрации
    ELSIF (v_is_individual = 1 AND v_is_for = 1 AND v_is_sng = 1)
    THEN
      k_kvs := 1; -- зарегистрировано в СНГ и ФЛ
    ELSIF (v_is_individual = 1 AND v_is_for = 1 AND v_is_sng = 0)
    THEN
      k_kvs := 1.3; -- зарегистрировано в ин гос-ве и ФЛ
    ELSIF (v_is_individual = 0 OR v_is_ind = 0)
    THEN
      k_kvs := 1; -- для ЮЛ
    ELSIF (v_is_individual = 1 AND v_is_driver_no_lim = 1)
    THEN
      k_kvs := 1; -- для ФЛ и нет ограничения на допущенных
    ELSE
      k_kvs := nvl(pkg_tariff_calc.calc_fun('OSAGO_Max_Coef_Driver', v_p_cover.ent_id, p_p_cover_id)
                  ,1);
      /*      select max(pkg_tariff_calc.calc_fun('OSAGO_AGE_AND_EXPERIENCE', pc.ent_id,pc.p_cover_id))
      into k_Kvs
      from ven_p_cover pc
      inner join ven_as_vehicle av on pc.as_asset_id = av.as_vehicle_id
      inner join ven_as_vehicle_driver avd on avd.as_vehicle_id = av.as_vehicle_id
      inner join as_asset aa on aa.as_asset_id = avd.as_vehicle_id
      where pc.p_cover_id = p_p_cover_id;*/
    END IF;
    dbms_output.put_line(k_kvs);
  
    -- мощность ТС
    k_km := pkg_tariff_calc.calc_fun('OSAGO_POWER_HP', v_p_cover.ent_id, p_p_cover_id);
  
    -- период сезонного использования
    --if (v_is_individual = 0 or v_is_ind = 0 or v_period != '12 месяцев') then
    -- если страхователь и собственние -ЮЛ и Срок страхования != 1 году
    IF v_period != '12 месяцев'
    THEN
      k_ks := 1; -- Срок страхования != 1 году
    ELSIF v_is_for = 1
          OR v_is_reg = 1
    THEN
      k_ks := 1; -- следует к месту регистрации
    ELSE
      k_ks := pkg_tariff_calc.calc_fun('OSAGO_PERIOD_OF_USE', v_p_cover.ent_id, p_p_cover_id);
    END IF;
  
    --срок страхования
    k_kp := pkg_tariff_calc.calc_fun('OSAGO_TERM', v_p_cover.ent_id, p_p_cover_id);
    -- нарушения
    k_kn := pkg_tariff_calc.calc_fun('OSAGO_IS_VIOLATION', v_p_cover.ent_id, p_p_cover_id);
  
    reg_coeff(p_p_cover_id, 'OSAGO_BASE', k_tb);
    reg_coeff(p_p_cover_id, 'OSAGO_AREA', k_kt);
    reg_coeff(p_p_cover_id, 'OSAGO_KBM', k_kbm);
    reg_coeff(p_p_cover_id, 'OSAGO_Max_Coef_Driver', k_kvs);
    reg_coeff(p_p_cover_id, 'OSAGO_IS_DRIVER_NO_LIM', k_ko);
    reg_coeff(p_p_cover_id, 'OSAGO_POWER_HP', k_km);
    reg_coeff(p_p_cover_id, 'OSAGO_PERIOD_OF_USE', k_ks);
    reg_coeff(p_p_cover_id, 'OSAGO_TERM', k_kp);
    reg_coeff(p_p_cover_id, 'OSAGO_IS_VIOLATION', k_kn);
  
    v_result := k_tb * k_kt * k_kbm * k_kvs * k_ko * k_km * k_ks * k_kp * k_kn;
  
    IF v_is_violation = 1
    THEN
      IF (v_result > k_tb * 5 * k_kt)
      THEN
        v_result := k_tb * 5 * k_kt;
      END IF;
    ELSE
      IF (v_result > k_tb * 3 * k_kt)
      THEN
        v_result := k_tb * 3 * k_kt;
      END IF;
    END IF;
  
    RETURN v_result;
  END;

  FUNCTION recalc_tariff_osago(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    p_h   NUMBER;
    av    NUMBER;
    pp_sd DATE;
    v_n   NUMBER;
    dn    NUMBER;
  
    d_s1 DATE;
    d_s2 DATE;
    d_e1 DATE;
    d_e2 DATE;
  
    prem_new NUMBER;
    prem_old NUMBER;
    kc_new   NUMBER;
  
    i     NUMBER;
    zsp   NUMBER;
    dn_pr NUMBER;
  BEGIN
  
    SELECT pp.pol_header_id
          ,av.as_asset_id
          ,pp.start_date
          ,pp.version_num
          ,pc.old_premium
          ,trunc(SUM(ap.end_date - ap.start_date + 1))
      INTO p_h
          ,av
          ,pp_sd
          ,v_n
          ,prem_old
          ,dn
      FROM p_cover pc
      JOIN as_asset av
        ON av.as_asset_id = pc.as_asset_id
      JOIN as_asset_per ap
        ON ap.as_asset_id = av.as_asset_id
      JOIN p_policy pp
        ON pp.policy_id = av.p_policy_id
     WHERE pc.p_cover_id = p_p_cover_id
     GROUP BY pp.pol_header_id
             ,av.as_asset_id
             ,pp.start_date
             ,pp.version_num
             ,pc.old_premium;
  
    FOR per IN (SELECT ap.as_asset_per_id
                      ,ap.start_date
                      ,ap.end_date
                  FROM as_asset_per ap
                 WHERE ap.as_asset_id = av
                 ORDER BY ap.start_date)
    LOOP
      IF d_s1 IS NULL
      THEN
        d_s1 := per.start_date;
        d_e1 := per.end_date;
      ELSE
        d_s2 := per.start_date;
        d_e2 := per.end_date;
      END IF;
    END LOOP;
  
    -- рассчитаем новую премия из обновленных условий
    prem_new := pkg_tariff.calc_tariff_osago(p_p_cover_id);
    UPDATE p_cover pc SET pc.premium_all_srok = prem_new WHERE pc.p_cover_id = p_p_cover_id;
    dbms_output.put_line('prem_new: ' || prem_new);
  
    -- вычислим коэффициент за срок страхования
    SELECT pcc.val
      INTO kc_new
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_id = p_p_cover_id
       AND pct.brief = 'OSAGO_PERIOD_OF_USE';
    dbms_output.put_line('kc_new: ' || kc_new);
    dbms_output.put_line('dn: ' || dn);
  
    --return prem_new;
    IF (v_n = 1)
    THEN
      -- если первая версия, то возвращаем премию
      RETURN prem_new;
    ELSE
      -- рассчитаем ЗСП
      zsp := 0;
      FOR ds IN (SELECT pp_all.policy_id
                       ,pc_all.premium_all_srok
                       ,pcc_all.val
                       ,pp_all.version_num
                       ,pp_all.start_date
                       ,nvl(pp_all_next.start_date - 1, pp_all.end_date) end_date
                       ,av_all.as_vehicle_id
                   FROM p_policy pp_all
                   JOIN ven_as_vehicle av_all
                     ON av_all.p_policy_id = pp_all.policy_id
                   JOIN p_cover pc_all
                     ON pc_all.as_asset_id = av_all.as_vehicle_id
                   JOIN p_cover_coef pcc_all
                     ON pcc_all.p_cover_id = pc_all.p_cover_id
                   JOIN t_prod_coef_type pct_all
                     ON pct_all.t_prod_coef_type_id = pcc_all.t_prod_coef_type_id
                    AND pct_all.brief = 'OSAGO_PERIOD_OF_USE'
                   LEFT JOIN p_policy pp_all_next
                     ON pp_all_next.pol_header_id = pp_all.pol_header_id
                    AND pp_all_next.version_num = pp_all.version_num + 1
                    AND pp_all_next.version_num <= v_n
                  WHERE pp_all.pol_header_id = p_h
                    AND pp_all.version_num <= v_n
                  ORDER BY pp_all.version_num)
      LOOP
      
        dn_pr := 0;
      
        FOR i IN 1 .. 2
        LOOP
          IF (i = 1)
          THEN
            IF (d_e1 >= ds.start_date)
            THEN
              IF (d_e1 <= ds.end_date)
              THEN
                IF (d_s1 <= ds.start_date)
                THEN
                  dn_pr := dn_pr + d_e1 - ds.start_date + 1;
                ELSE
                  dn_pr := dn_pr + d_e1 - d_s1 + 1;
                END IF;
              ELSE
                IF (d_s1 <= ds.start_date)
                THEN
                  dn_pr := dn_pr + ds.end_date - ds.start_date + 1;
                ELSIF (d_s1 <= ds.end_date)
                THEN
                  dn_pr := dn_pr + ds.end_date - d_s1 + 1;
                END IF;
              END IF;
            END IF;
          ELSE
            IF (d_e2 >= ds.start_date)
            THEN
              IF (d_e2 <= ds.end_date)
              THEN
                IF (d_s2 <= ds.start_date)
                THEN
                  dn_pr := dn_pr + d_e2 - ds.start_date + 1;
                ELSE
                  dn_pr := dn_pr + d_e2 - d_s2 + 1;
                END IF;
              ELSE
                IF (d_s2 <= ds.start_date)
                THEN
                  dn_pr := dn_pr + ds.end_date - ds.start_date + 1;
                ELSIF (d_s2 <= ds.end_date)
                THEN
                  dn_pr := dn_pr + ds.end_date - d_s2 + 1;
                END IF;
              END IF;
            END IF;
          END IF;
        END LOOP;
      
        dn_pr := trunc(dn_pr);
        dbms_output.put_line('dn_pr: ' || dn_pr);
        IF (ds.version_num <> v_n)
        THEN
          zsp := zsp + ROUND(dn_pr * ds.premium_all_srok * kc_new / (dn * ds.val), 2);
        ELSE
          prem_new := ROUND(dn_pr * prem_new / dn, 2);
        END IF;
        dbms_output.put_line('zsp: ' || zsp);
      END LOOP;
      dbms_output.put_line('prem_new: ' || prem_new);
      dbms_output.put_line('zsp: ' || zsp);
      prem_new := prem_new + zsp;
    
      IF prem_new < prem_old
      THEN
        prem_new := prem_new + ROUND(0.23 * (prem_old - prem_new), 2);
      END IF;
    
    END IF;
    RETURN prem_new;
  
  END;

  FUNCTION calc_tariff_life(p_p_cover_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
    v_coef   NUMBER;
  BEGIN
    v_coef   := 1;
    v_result := 1;
    FOR v_c IN (SELECT ct.brief
                  FROM t_prod_coef_type   ct
                      ,t_prod_line_coef   lc
                      ,t_prod_line_option lo
                      ,p_cover            c
                 WHERE ct.t_prod_coef_type_id = lc.t_prod_coef_type_id
                   AND lo.product_line_id = lc.t_product_line_id
                   AND c.t_prod_line_option_id = lo.id
                   AND c.p_cover_id = p_p_cover_id)
    LOOP
      reg_coeff(p_p_cover_id, v_c.brief, v_coef);
      v_result := v_coef * v_result;
    END LOOP;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      v_result := 0;
      RETURN v_result;
  END;

  FUNCTION calc_tariff_casco_damage
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER AS
    v_result           NUMBER;
    v_as_vehicle_id    NUMBER;
    v_str_type         NUMBER;
    v_is_driver_no_lim NUMBER(1);
    v_plo              VARCHAR(55);
    v_prev_comp        VARCHAR(55);
    v_prev_ph_id       NUMBER;
    v_is_new           NUMBER(1);
    v_otech            NUMBER; -- стоимость
    v_prem             NUMBER;
    v_pc_inc_amount    NUMBER; -- стоимость
    v_payterm          VARCHAR2(255);
    v_is_pss1          NUMBER;
    v_is_pss2          NUMBER;
    v_singa            NUMBER;
    v_douba            NUMBER;
    v_bt85             NUMBER;
    v_bt84             NUMBER;
    v_bt71             NUMBER;
    v_fund             VARCHAR2(55);
    v_gr               NUMBER;
    v_prod             VARCHAR2(33);
    prem               NUMBER;
    fix_rate           NUMBER;
    bt_1               NUMBER; -- Хищение
    bt_2               NUMBER; -- Ущерб
    k1                 NUMBER;
    k2                 NUMBER;
    k3                 NUMBER;
    k4                 NUMBER;
    k5                 NUMBER;
    k6                 NUMBER;
    k7                 NUMBER;
    k8                 NUMBER;
    k9                 NUMBER;
    k10                NUMBER;
    k10_1              NUMBER;
    k11                NUMBER;
    k12                NUMBER;
    k13                NUMBER;
    k14                NUMBER;
    k35                NUMBER;
    k91                NUMBER;
    k_srok             NUMBER;
    k_popr             NUMBER;
    pc_dam             NUMBER;
    is_pr              NUMBER;
    ins_year           NUMBER;
    k_supp             NUMBER;
  
  BEGIN
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    /*
        delete from p_cover_coef pcc
        where pcc.p_cover_id = p_p_cover_id;
    */
    -- риск
    SELECT av.as_vehicle_id
          , -- ид объекта страхования
           tct.is_individual
          , --- тип стр-ля
           av.is_driver_no_lim
          , -- допущенные к управлению
           plo.description
          , -- программа
           ph.prev_policy_company
          , -- пред страховая компания
           ph.prev_pol_header_id
          , -- ид предыдущего договора
           ph.is_new
          , -- новый или пролонгированный договор
           vm.is_national_mark
          , -- отеч ТС или иномарка
           av.ins_price
          , -- стоимость
           pc.premium
          , -- премия
           f.brief
          , -- валюта ответственности по договору
           pt.description
          , --условие рассрочки,
           pr.brief
          , -- продукт
           prev.p_cover_id
          ,nvl(add_ver.is_prol, 0)
          ,pp.fix_rate
          ,CEIL(MONTHS_BETWEEN(pp.start_date + 1, ph.start_date))
      INTO v_as_vehicle_id
          , -- ид объекта страхования
           v_str_type
          , -- тип стр-ля
           v_is_driver_no_lim
          , -- допущенные к управлению
           v_plo
          , -- программв
           v_prev_comp
          , -- пред страховая компания
           v_prev_ph_id
          , -- ид предыдущего договора
           v_is_new
          , -- новый или пролонгированный договор
           v_otech
          , -- отеч ТС или иномарка
           v_pc_inc_amount
          , -- стоимость
           v_prem
          , -- премия
           v_fund
          , --валюта ответственности по договору
           v_payterm
          , --условие рассрочки
           v_prod
          ,pc_dam
          , -- ид покрыьтия Автокаско по предудущей версии
           is_pr
          ,fix_rate
          ,ins_year
      FROM ven_p_cover pc
     INNER JOIN ven_t_prod_line_option plo
        ON plo.id = pc.t_prod_line_option_id
     INNER JOIN ven_as_vehicle av
        ON pc.as_asset_id = av.as_vehicle_id
     INNER JOIN ven_t_vehicle_mark vm
        ON vm.t_vehicle_mark_id = av.t_vehicle_mark_id
     INNER JOIN p_policy pp
        ON pp.policy_id = av.p_policy_id
      LEFT JOIN (SELECT pp_pr.pol_header_id
                       ,pp_pr.version_num
                       ,pc.p_cover_id
                   FROM p_policy pp_pr
                   JOIN as_asset ass
                     ON ass.p_policy_id = pp_pr.policy_id
                   JOIN p_cover pc
                     ON pc.as_asset_id = ass.as_asset_id
                   JOIN t_prod_line_option plo
                     ON plo.id = pc.t_prod_line_option_id
                  WHERE plo.description = 'Автокаско') prev
        ON prev.pol_header_id = pp.pol_header_id
       AND prev.version_num = pp.version_num - 1
     INNER JOIN t_payment_terms pt
        ON pt.id = pp.payment_term_id
     INNER JOIN p_pol_header ph
        ON pp.pol_header_id = ph.policy_header_id
     INNER JOIN t_product pr
        ON pr.product_id = ph.product_id
     INNER JOIN fund f
        ON f.fund_id = ph.fund_id
     INNER JOIN p_policy_contact ppc
        ON ppc.policy_id = pp.policy_id
     INNER JOIN t_contact_pol_role cr
        ON cr.id = ppc.contact_policy_role_id
     INNER JOIN contact c
        ON c.contact_id = ppc.contact_id
     INNER JOIN t_contact_type tct
        ON tct.id = c.contact_type_id
      LEFT JOIN (SELECT pat.p_policy_id
                       ,COUNT(pat.p_pol_addendum_type_id) is_prol
                   FROM p_pol_addendum_type pat
                   JOIN t_addendum_type at
                     ON at.t_addendum_type_id = pat.t_addendum_type_id
                  WHERE at.brief = 'Автопролонгация'
                  GROUP BY pat.p_policy_id) add_ver
        ON pp.policy_id = add_ver.p_policy_id
     WHERE pc.p_cover_id = p_p_cover_id
       AND cr.brief = 'Страхователь';
  
    v_gr := get_casco_gr(v_as_vehicle_id);
    dbms_output.put_line(v_gr);
  
    -- Базовый тариф
    IF (v_plo = 'Автокаско')
    THEN
      -- автокаско
      bt_1 := pkg_tariff_calc.calc_fun('CASCO_STEAL_BASE_TARIFF', v_p_cover.ent_id, p_p_cover_id);
      bt_2 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_BASE_TARIFF', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      -- ущерб
      bt_1 := 0;
      bt_2 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_BASE_TARIFF', v_p_cover.ent_id, p_p_cover_id);
    END IF;
  
    -- если коэффициенты не вычислились ( для Автокредита-24) - берем с предыдущей версии
    IF is_pr > 0
       OR (v_prod = 'Автокаско-ВТБ24' AND ins_year > 1)
    THEN
      bt_2 := pkg_tariff_calc.calc_fun('PREV_PREM_COVER', v_p_cover.ent_id, p_p_cover_id);
    END IF;
    dbms_output.put_line('bt_1 ' || bt_1);
    dbms_output.put_line('bt_2 ' || bt_2);
  
    --k1: Количество  лиц, допущенных  к  управлению
    k1 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K1', v_p_cover.ent_id, p_p_cover_id), 1);
    /*    if (v_str_type = 1) then -- для страхователей ФЛ
          k1 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K1',v_p_cover.ent_id,p_p_cover_id);
        else
          k1 := 1;
          k2 := 1;
        end if;
    */
    dbms_output.put_line('k1 ' || k1);
  
    --k2: Стаж  вождения  лиц,  допущенных  к управлению
    IF (v_is_driver_no_lim = 0)
    THEN
      SELECT MAX(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K2', avd.ent_id, avd.as_vehicle_driver_id))
        INTO k2
        FROM ven_p_cover pc
       INNER JOIN ven_as_vehicle av
          ON pc.as_asset_id = av.as_vehicle_id
       INNER JOIN ven_as_vehicle_driver avd
          ON avd.as_vehicle_id = av.as_vehicle_id
       WHERE pc.p_cover_id = p_p_cover_id;
    ELSE
      k2 := 1;
    END IF;
    dbms_output.put_line('k2 ' || k2);
  
    -- k3: Переход  из другой  страховой компании
    IF (v_prev_comp IS NOT NULL AND v_prev_ph_id IS NULL)
    THEN
      k3 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K3', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      k3 := 1;
    END IF;
    dbms_output.put_line('k3 ' || k3);
  
    -- k4: Пролонгация предыдущего годового Полиса
    IF (v_prev_comp IS NOT NULL AND v_is_new = 0 AND v_prev_ph_id IS NOT NULL)
    THEN
      k4 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K4', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      k4 := 1;
    END IF;
    dbms_output.put_line('k4 ' || k4);
  
    -- k5: Форма  возмещения   ущерба
    k5 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K5', v_p_cover.ent_id, p_p_cover_id), 1);
    dbms_output.put_line('k5 ' || k5);
  
    -- k6: Установлена  безусловная  франшиза
    IF (v_fund = 'USD')
    THEN
      k6 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K6', v_p_cover.ent_id, p_p_cover_id), 1);
    ELSE
      k6 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K6', v_p_cover.ent_id, p_p_cover_id), 1);
    END IF;
    dbms_output.put_line('k6 ' || k6);
  
    -- k8: Применение рассрочки страхового взноса
    k8 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K8', v_p_cover.ent_id, p_p_cover_id), 1);
    dbms_output.put_line('k8 ' || k8);
  
    -- k9: Программа "До   первого  страхового  события"
  
    -- k9 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K9',v_p_cover.ent_id,p_p_cover_id),1);
  
    -- k10: Агентский  коэффициент
    k10   := 1;
    k10_1 := 1;
  
    -- k11: Страхование автомобилей с правым рулем
    k11 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K11', v_p_cover.ent_id, p_p_cover_id), 1);
  
    -- k12: Наличие противоугонных систем
    k12 := 1;
    IF (v_otech = 1)
    THEN
      k12 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K12', v_p_cover.ent_id, p_p_cover_id), 1);
    ELSE
      FOR s IN (SELECT mat.t_group_at_device_id
                      ,tgd.name                 group_name
                      ,mat.name                 model_name
                  FROM p_cover pc
                  JOIN as_vehicle av
                    ON av.as_vehicle_id = pc.as_asset_id
                  JOIN as_vehicle_at_device avd
                    ON avd.as_vehicle_id = av.as_vehicle_id
                  JOIN ven_t_model_at_device mat
                    ON mat.t_model_at_device_id = avd.t_model_at_device_id
                  JOIN ven_t_group_at_device tgd
                    ON tgd.t_group_at_device_id = mat.t_group_at_device_id
                 WHERE pc.p_cover_id = p_p_cover_id)
      LOOP
        IF (s.group_name = 'ПСС 1')
        THEN
          v_is_pss1 := 1;
        ELSIF (s.group_name = 'ПСС 2')
        THEN
          v_is_pss2 := 1;
        ELSIF (s.model_name = 'Single A')
        THEN
          v_singa := 1;
        ELSIF (s.model_name = 'Double A')
        THEN
          v_douba := 1;
        ELSIF (s.model_name = 'BT-85')
        THEN
          v_bt85 := 1;
        ELSIF (s.model_name = 'BT-84')
        THEN
          v_bt84 := 1;
        ELSIF (s.model_name = 'BT-71')
        THEN
          v_bt71 := 1;
        ELSE
          NULL;
        END IF;
      END LOOP;
      IF (v_pc_inc_amount <= 40000 OR v_gr IN (7, 17, 18))
      THEN
        CASE
          WHEN v_is_pss1 = 1
               AND (v_singa = 1 OR v_douba = 1) THEN
            k12 := 0.25;
          WHEN v_is_pss2 = 1
               AND (v_singa = 1 OR v_douba = 1) THEN
            k12 := 0.45;
          WHEN (v_singa = 1 OR v_douba = 1)
               AND v_bt85 = 1 THEN
            k12 := 0.2;
          WHEN (v_singa = 1 OR v_douba = 1)
               AND v_bt84 = 1 THEN
            k12 := 0.25;
          WHEN (v_singa = 1 OR v_douba = 1)
               AND v_bt71 = 1 THEN
            k12 := 0.30;
          WHEN v_is_pss1 = 1 THEN
            k12 := 0.15;
          WHEN v_is_pss2 = 1 THEN
            k12 := 0.3;
          WHEN v_singa = 1 THEN
            k12 := 0.4;
          WHEN v_douba = 1 THEN
            k12 := 0.35;
          WHEN v_bt85 = 1 THEN
            k12 := 0.35;
          WHEN v_bt84 = 1 THEN
            k12 := 0.4;
          WHEN v_bt71 = 1 THEN
            k12 := 0.6;
          ELSE
            NULL;
        END CASE;
      ELSE
        CASE
          WHEN v_is_pss1 = 1
               AND (v_singa = 1 OR v_douba = 1) THEN
            k12 := 0.25;
          WHEN v_is_pss2 = 1
               AND (v_singa = 1 OR v_douba = 1) THEN
            k12 := 0.45;
          WHEN (v_singa = 1 OR v_douba = 1)
               AND v_bt85 = 1 THEN
            k12 := 0.45;
          WHEN (v_singa = 1 OR v_douba = 1)
               AND v_bt84 = 1 THEN
            k12 := 0.5;
          WHEN (v_singa = 1 OR v_douba = 1)
               AND v_bt71 = 1 THEN
            k12 := 0.55;
          WHEN v_is_pss1 = 1 THEN
            k12 := 0.3;
          WHEN v_is_pss2 = 1 THEN
            k12 := 0.55;
          WHEN v_singa = 1 THEN
            k12 := 0.7;
          WHEN v_douba = 1 THEN
            k12 := 0.6;
          WHEN v_bt85 = 1 THEN
            k12 := 0.6;
          WHEN v_bt84 = 1 THEN
            k12 := 0.7;
          WHEN v_bt71 = 1 THEN
            k12 := 0.9;
          ELSE
            NULL;
        END CASE;
      END IF;
    END IF;
    dbms_output.put_line('k12 ' || k12);
  
    -- k13: Семейный коэффициент
    k13 := 1;
  
    -- k14: Региональный коэффициент
    k14 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K14', v_p_cover.ent_id, p_p_cover_id), 1);
  
    -- k35: Поправочный коэффициент
    k35 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_35', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k91: Региональный коэффициент
    k91 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_91', v_p_cover.ent_id, p_p_cover_id), 1);
  
    -- Поправочный коэффициент за год страхования
    k_popr := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_NEXT_YEAR', v_p_cover.ent_id, p_p_cover_id), 1);
  
    k_srok := p_srok;
  
    IF (p_srok IS NULL)
    THEN
      k_srok := pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id);
      IF k_srok IS NULL
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
      END IF;
      IF (k_srok < 1)
      THEN
        IF (k2 < 1)
        THEN
          k2 := 1;
        END IF;
        k3 := 1;
        IF (k4 < 1)
        THEN
          k4 := 1;
        END IF;
        IF (k5 < 1)
        THEN
          k5 := 1;
        END IF;
        k6 := 1;
        IF (k_srok < 0.7)
        THEN
          k9 := 1;
        END IF;
        k10 := 1;
        k12 := 1;
        k13 := 1;
        k14 := 1;
      END IF;
    END IF;
  
    v_result := bt_1 * k3 * k6 * k8 * /*k9 **/
                k10 * k10_1 * k12 * k13 * k14 * k_srok + -- хищение
                bt_2 * k1 * k2 * k3 * k4 * k5 * k6 * k8 * /*k9 **/
                k10 * k10_1 * k11 * k13 * k14 * k_srok; -- ущерб
  
    -- k7: За  единовременный  взнос по Договору
    k7 := 1;
    IF v_prod != 'Автокаско-Стандартный'
    THEN
      v_result := bt_1 * k12 * k14 * k_popr + -- хищение
                  bt_2 * k1 * k2 * k14 * k_popr; -- ущерб
    ELSE
      IF (v_payterm = 'Единовременно' AND k_srok >= 1)
      THEN
        IF (v_fund = 'USD')
        THEN
          prem := nvl(v_prem, ROUND(v_pc_inc_amount * v_result, 2));
        ELSE
          prem := ROUND(nvl(v_prem, ROUND(v_pc_inc_amount * v_result / 100, 2)) / (fix_rate), 2);
        END IF;
      
        /*    if (v_fund = 'USD') then
           prem := nvl(v_prem, v_pc_inc_amount) * v_result;
        else
           prem := nvl(v_prem, v_pc_inc_amount) * v_result *
                   acc_new.Get_Cross_Rate_By_Brief(2,v_fund,'USD',v_p_cover.start_date);
        end if;*/
        IF prem > 1500
        THEN
          k7 := 0.97;
        END IF;
        IF prem > 3000
        THEN
          k7 := 0.95;
        END IF;
      END IF;
    END IF;
    dbms_output.put_line('k7 ' || k7);
  
    k_supp := nvl(ROUND(fix_rate * pkg_tariff_calc.calc_fun('CASCO_DAMAGE_SUPPORT'
                                                           ,v_p_cover.ent_id
                                                           ,p_p_cover_id)
                       ,2)
                 ,0);
  
    dbms_output.put_line('k_supp ' || k_supp);
  
    IF v_p_cover.is_handchange_amount = 1
    THEN
    
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        CASE coef.brief
          WHEN 'CASCO_COEF_35' THEN
            update_default_val(coef.p_cover_coef_id, k35);
          WHEN 'CASCO_COEF_91' THEN
            update_default_val(coef.p_cover_coef_id, k91);
          WHEN 'CASCO_COEF_NEXT_YEAR' THEN
            update_default_val(coef.p_cover_coef_id, k_popr);
          WHEN 'DURATION' THEN
            update_default_val(coef.p_cover_coef_id, k_srok);
          WHEN 'PREV_PREM_COVER' THEN
            update_default_val(coef.p_cover_coef_id, bt_2);
          WHEN 'CASCO_STEAL_BASE_TARIFF' THEN
            update_default_val(coef.p_cover_coef_id, bt_1);
          WHEN 'CASCO_DAMAGE_BASE_TARIFF' THEN
            update_default_val(coef.p_cover_coef_id, bt_2);
          WHEN 'CASCO_DAMAGE_K1' THEN
            update_default_val(coef.p_cover_coef_id, k1);
          WHEN 'CASCO_DAMAGE_K2' THEN
            update_default_val(coef.p_cover_coef_id, k2);
          WHEN 'CASCO_DAMAGE_K3' THEN
            update_default_val(coef.p_cover_coef_id, k3);
          WHEN 'CASCO_DAMAGE_K4' THEN
            update_default_val(coef.p_cover_coef_id, k4);
          WHEN 'CASCO_DAMAGE_K5' THEN
            update_default_val(coef.p_cover_coef_id, k5);
          WHEN 'CASCO_DAMAGE_K6' THEN
            update_default_val(coef.p_cover_coef_id, k6);
          WHEN 'CASCO_DAMAGE_K7' THEN
            update_default_val(coef.p_cover_coef_id, k7);
          WHEN 'CASCO_DAMAGE_K8' THEN
            update_default_val(coef.p_cover_coef_id, k8);
          WHEN 'CASCO_DAMAGE_K9' THEN
            update_default_val(coef.p_cover_coef_id, k9);
          WHEN 'CASCO_DAMAGE_K10' THEN
            update_default_val(coef.p_cover_coef_id, k10);
          WHEN 'CASCO_DAMAGE_K10_1' THEN
            update_default_val(coef.p_cover_coef_id, k10_1);
          WHEN 'CASCO_DAMAGE_K11' THEN
            update_default_val(coef.p_cover_coef_id, k11);
          WHEN 'CASCO_DAMAGE_K12' THEN
            update_default_val(coef.p_cover_coef_id, k12);
          WHEN 'CASCO_DAMAGE_K13' THEN
            update_default_val(coef.p_cover_coef_id, k13);
          WHEN 'CASCO_DAMAGE_K14' THEN
            update_default_val(coef.p_cover_coef_id, k14);
          WHEN 'CASCO_DAMAGE_K15' THEN
            update_default_val(coef.p_cover_coef_id, 1);
          WHEN 'CASCO_DAMAGE_SUPPORT' THEN
            update_default_val(coef.p_cover_coef_id, k_supp);
        END CASE;
      END LOOP;
      RETURN calc_tarif_mul_casco(p_p_cover_id);
    
    ELSE
      reg_coeff(p_p_cover_id, 'CASCO_COEF_35', k35);
      reg_coeff(p_p_cover_id, 'CASCO_COEF_91', k91);
    
      IF v_prod = 'Автокаско-ВТБ24'
      THEN
        reg_coeff(p_p_cover_id, 'CASCO_COEF_NEXT_YEAR', k_popr);
        reg_coeff(p_p_cover_id, 'DURATION', k_srok);
        IF is_pr > 0
           OR ins_year > 1
        THEN
          reg_coeff(p_p_cover_id, 'PREV_PREM_COVER', bt_2);
          IF is_pr > 0
          THEN
            v_result := bt_2 * k_popr * k_srok * 100 / v_pc_inc_amount;
          ELSE
            v_result := bt_2 * k_srok * 100 / v_pc_inc_amount;
          END IF;
        ELSE
          IF (v_plo = 'Автокаско')
          THEN
            reg_coeff(p_p_cover_id, 'CASCO_STEAL_BASE_TARIFF', bt_1);
          END IF;
          reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_BASE_TARIFF', bt_2);
          reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K1', k1);
          reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K2', k2);
          reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K12', k12);
          reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K14', k14);
          reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K15', 1);
          v_result := (bt_2 * k1 * k2 + bt_1 * k12) * k14 * k_srok;
        END IF;
      
      ELSE
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_SUPPORT', k_supp);
        IF (v_plo = 'Автокаско')
        THEN
          reg_coeff(p_p_cover_id, 'CASCO_STEAL_BASE_TARIFF', bt_1);
        END IF;
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_BASE_TARIFF', bt_2);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K1', k1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K2', k2);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K12', k12);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K14', k14);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K15', 1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K3', k3);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K4', k4);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K5', k5);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K6', k6);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K7', k7);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K8', k8);
        -- reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K9', k9);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10', k10);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10_1', k10_1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K11', k11);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K13', k13);
        reg_coeff(p_p_cover_id, 'DURATION', k_srok);
        v_result := bt_1 * k3 * k6 * k7 * k8 * /*k9 **/
                    k10 * k10_1 * k12 * k13 * k14 * k_srok + -- хищение
                    bt_2 * k1 * k2 * k3 * k4 * k5 * k6 * k7 * k8 * /*k9 **/
                    k10 * k10_1 * k11 * k13 * k14 * k_srok; -- ущерб
      
      END IF;
    END IF;
  
    RETURN v_result;
  
  END;

  FUNCTION calc_tariff_casco_liability
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER AS
    v_result NUMBER;
  
    v_str_type         NUMBER;
    v_is_driver_no_lim NUMBER(1);
  
    bt     NUMBER;
    k1     NUMBER;
    k2     NUMBER;
    k8     NUMBER;
    k9     NUMBER;
    k10    NUMBER;
    k10_1  NUMBER;
    k11    NUMBER;
    k13    NUMBER;
    k14    NUMBER;
    k35    NUMBER;
    k91    NUMBER;
    k_srok NUMBER;
    v_prod VARCHAR2(55);
  
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pr.brief
      INTO v_prod
      FROM p_cover pc
      JOIN as_asset ass
        ON ass.as_asset_id = pc.as_asset_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
      JOIN t_product pr
        ON pr.product_id = ph.product_id
     WHERE pc.p_cover_id = p_p_cover_id;
  
    /*  if v_p_cover.IS_HANDCHANGE_AMOUNT = 1 then
      return calc_tarif_mul(p_p_cover_id);
    end if;*/
  
    /*   delete from p_cover_coef pcc
       where pcc.p_cover_id  = p_p_cover_id;
    */
  
    -- риск
    SELECT tct.is_individual
          , --- тип стр-ля
           av.is_driver_no_lim
      INTO v_str_type
          , -- тип стр-ля
           v_is_driver_no_lim
      FROM ven_p_cover pc
     INNER JOIN ven_as_vehicle av
        ON pc.as_asset_id = av.as_vehicle_id
     INNER JOIN p_policy pp
        ON pp.policy_id = av.p_policy_id
     INNER JOIN p_pol_header ph
        ON pp.pol_header_id = ph.policy_header_id
     INNER JOIN p_policy_contact ppc
        ON ppc.policy_id = pp.policy_id
     INNER JOIN t_contact_pol_role cr
        ON cr.id = ppc.contact_policy_role_id
     INNER JOIN contact c
        ON c.contact_id = ppc.contact_id
     INNER JOIN t_contact_type tct
        ON tct.id = c.contact_type_id
     WHERE pc.p_cover_id = p_p_cover_id
       AND cr.brief = 'Страхователь';
  
    -- Базовый тариф
    bt := nvl(pkg_tariff_calc.calc_fun('CASCO_LIABILITY_BASE_TARRIFS', v_p_cover.ent_id, p_p_cover_id)
             ,1);
  
    --k1: Количество  лиц, допущенных  к  управлению
    IF (v_str_type = 1)
    THEN
      -- для страхователей ФЛ
      k1 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K1', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      k1 := 1;
      k2 := 1;
    END IF;
  
    --k2: Стаж  вождения  лиц,  допущенных  к управлению
    IF (v_is_driver_no_lim = 0)
    THEN
      SELECT MAX(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K2', avd.ent_id, avd.as_vehicle_driver_id))
        INTO k2
        FROM ven_p_cover pc
       INNER JOIN ven_as_vehicle av
          ON pc.as_asset_id = av.as_vehicle_id
       INNER JOIN ven_as_vehicle_driver avd
          ON avd.as_vehicle_id = av.as_vehicle_id
       WHERE pc.p_cover_id = p_p_cover_id;
    ELSE
      k2 := 1;
    END IF;
  
    -- k8: Применение рассрочки страхового взноса
    k8 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K8', v_p_cover.ent_id, p_p_cover_id), 1);
  
    -- k9: Программа "До   первого  страхового  события"
    -- k9 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K9', v_p_cover.ent_id,p_p_cover_id),1);
  
    -- k10: Агентский  коэффициент
    k10   := 1;
    k10_1 := 1;
  
    -- k11: Страхование автомобилей с правым рулем
    k11 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K11', v_p_cover.ent_id, p_p_cover_id);
  
    -- k13: Семейный коэффициент
    k13 := 1;
  
    -- k14: Региональный коэффициент
    k14 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K14', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k35: Поправочный коэффициент
    k35 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_35', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k91: Региональный коэффициент
    k91 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_91', v_p_cover.ent_id, p_p_cover_id), 1);
  
    k_srok := p_srok;
    IF (p_srok IS NULL)
    THEN
      k_srok := pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id);
      IF k_srok IS NULL
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
      END IF;
      IF (k_srok < 1)
      THEN
        IF (k2 < 1)
        THEN
          k2 := 1;
        END IF;
        IF (k_srok < 0.7)
        THEN
          k9 := 1;
        END IF;
        k10 := 1;
        k13 := 1;
        k14 := 1;
      END IF;
    END IF;
  
    IF v_p_cover.is_handchange_amount = 1
    THEN
    
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
      
        IF coef.brief = 'CASCO_COEF_35'
        THEN
          update_default_val(coef.p_cover_coef_id, k35);
        ELSIF coef.brief = 'CASCO_COEF_91'
        THEN
          update_default_val(coef.p_cover_coef_id, k91);
        ELSIF coef.brief = 'CASCO_LIABILITY_BASE_TARRIFS'
        THEN
          update_default_val(coef.p_cover_coef_id, bt);
        ELSIF coef.brief = 'DURATION'
        THEN
          update_default_val(coef.p_cover_coef_id, k_srok);
        ELSIF coef.brief = 'CASCO_DAMAGE_K1'
        THEN
          update_default_val(coef.p_cover_coef_id, k1);
        ELSIF coef.brief = 'CASCO_DAMAGE_K2'
        THEN
          update_default_val(coef.p_cover_coef_id, k2);
        ELSIF coef.brief = 'CASCO_DAMAGE_K8'
        THEN
          update_default_val(coef.p_cover_coef_id, k8);
        ELSIF coef.brief = 'CASCO_DAMAGE_K10'
        THEN
          update_default_val(coef.p_cover_coef_id, k10);
        ELSIF coef.brief = 'CASCO_DAMAGE_K10_1'
        THEN
          update_default_val(coef.p_cover_coef_id, k10_1);
        ELSIF coef.brief = 'CASCO_DAMAGE_K11'
        THEN
          update_default_val(coef.p_cover_coef_id, k11);
        ELSIF coef.brief = 'CASCO_DAMAGE_K13'
        THEN
          update_default_val(coef.p_cover_coef_id, k13);
        ELSIF coef.brief = 'CASCO_DAMAGE_K14'
        THEN
          update_default_val(coef.p_cover_coef_id, k14);
        ELSIF coef.brief = 'CASCO_DAMAGE_K15'
        THEN
          update_default_val(coef.p_cover_coef_id, 1);
        END IF;
      END LOOP;
    
      RETURN calc_tarif_mul(p_p_cover_id);
    ELSE
      v_result := bt * k1 * k2 * k14 * k_srok;
      reg_coeff(p_p_cover_id, 'CASCO_COEF_35', k35);
      reg_coeff(p_p_cover_id, 'CASCO_COEF_91', k91);
      reg_coeff(p_p_cover_id, 'CASCO_LIABILITY_BASE_TARRIFS', bt);
      reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K1', k1);
      reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K2', k2);
      reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K14', k14);
      reg_coeff(p_p_cover_id, 'DURATION', k_srok);
      IF v_prod = 'Автокаско-Стандартный'
      THEN
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K8', k8);
        --  reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K9', k9);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10', k10);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10_1', k10_1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K11', k11);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K13', k13);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K15', 1);
        v_result := bt * k1 * k2 * k8 * /*k9 **/
                    k10 * k10_1 * k11 * k13 * k14 * k_srok * k35 * k91;
      END IF;
      RETURN v_result;
    END IF;
  
  END;

  FUNCTION calc_tariff_casco_acces
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER AS
    v_result NUMBER;
  
    bt       NUMBER;
    k8       NUMBER;
    k9       NUMBER;
    k10      NUMBER;
    k10_1    NUMBER;
    k13      NUMBER;
    k14      NUMBER;
    k35      NUMBER;
    k91      NUMBER;
    k_srok   NUMBER;
    k_popr   NUMBER;
    v_prod   VARCHAR2(55);
    v_pc_dam NUMBER;
    v_ver    NUMBER;
    v_price  NUMBER;
    is_pr    NUMBER;
    ins_year NUMBER;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    /*    if v_p_cover.IS_HANDCHANGE_AMOUNT = 1 then
      return calc_tarif_mul(p_p_cover_id);
    end if;*/
    /*
       delete from p_cover_coef pcc
       where pcc.p_cover_id  = p_p_cover_id;
    */
  
    SELECT pr.brief
          ,pc_dam.p_cover_id
          ,pp.version_num
          ,st.price
          ,nvl(add_ver.is_prol, 0)
          ,CEIL(MONTHS_BETWEEN(pp.start_date + 1, ph.start_date))
      INTO v_prod
          ,v_pc_dam
          ,v_ver
          ,v_price
          ,is_pr
          ,ins_year
      FROM p_cover pc
      JOIN as_asset ass
        ON ass.as_asset_id = pc.as_asset_id
      JOIN (SELECT avs.as_vehicle_id
                  ,SUM(avs.price) price
              FROM as_vehicle_stuff avs
             GROUP BY avs.as_vehicle_id) st
        ON st.as_vehicle_id = ass.as_asset_id
      JOIN p_cover pc_dam
        ON pc_dam.as_asset_id = ass.as_asset_id
      JOIN t_prod_line_option plo
        ON plo.id = pc_dam.t_prod_line_option_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      LEFT JOIN (SELECT pat.p_policy_id
                       ,COUNT(pat.p_pol_addendum_type_id) is_prol
                   FROM p_pol_addendum_type pat
                   JOIN t_addendum_type at
                     ON at.t_addendum_type_id = pat.t_addendum_type_id
                  WHERE at.brief = 'Автопролонгация'
                  GROUP BY pat.p_policy_id) add_ver
        ON pp.policy_id = add_ver.p_policy_id
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
      JOIN t_product pr
        ON pr.product_id = ph.product_id
     WHERE pc.p_cover_id = p_p_cover_id
       AND plo.description IN ('Автокаско', 'Ущерб');
    --Базовый тариф
  
    IF v_prod = 'Автокаско-Стандартный'
    THEN
      bt := pkg_tariff_calc.calc_fun('CASCO_ACCESSORIES', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      IF v_ver = 1
         OR ins_year = 1
      THEN
        bt := pkg_tariff_calc.calc_fun('CASCO_TARIFF', v_p_cover.ent_id, v_pc_dam) * 100;
      ELSE
        bt := pkg_tariff_calc.calc_fun('PREV_PREM_COVER', v_p_cover.ent_id, p_p_cover_id);
      END IF;
    END IF;
  
    -- k8: Применение рассрочки страхового взноса
    k8 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K8', v_p_cover.ent_id, p_p_cover_id), 1);
  
    -- k9: Программа "До   первого  страхового  события"
    -- k9 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K9',v_p_cover.ent_id,p_p_cover_id),1);
  
    -- k10: Агентский  коэффициент
    k10   := 1;
    k10_1 := 1;
    -- k13: Семейный коэффициент
    k13 := 1;
  
    -- k14: Региональный коэффициент
    k14 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K14', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k35: Поправочный коэффициент
    k35 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_35', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k91: Региональный коэффициент
    k91 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_91', v_p_cover.ent_id, p_p_cover_id), 1);
    -- Поправочный коэффициент за год страхования
    k_popr := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_NEXT_YEAR', v_p_cover.ent_id, p_p_cover_id), 1);
  
    k_srok := p_srok;
    IF (p_srok IS NULL)
    THEN
      k_srok := pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id);
      IF k_srok IS NULL
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
      END IF;
      IF (k_srok < 1)
      THEN
        IF (k_srok < 0.7)
        THEN
          k9 := 1;
        END IF;
        k10 := 1;
        k13 := 1;
        k14 := 1;
      END IF;
    END IF;
  
    v_result := bt;
    dbms_output.put_line(v_price);
    dbms_output.put_line(bt);
    dbms_output.put_line(bt);
  
    IF v_p_cover.is_handchange_amount = 1
    THEN
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        IF coef.brief = 'CASCO_COEF_35'
        THEN
          update_default_val(coef.p_cover_coef_id, k35);
        ELSIF coef.brief = 'CASCO_COEF_91'
        THEN
          update_default_val(coef.p_cover_coef_id, k91);
        ELSIF coef.brief = 'CASCO_ACCESSORIES'
        THEN
          update_default_val(coef.p_cover_coef_id, bt);
        ELSIF coef.brief = 'PREV_PREM_COVER'
        THEN
          update_default_val(coef.p_cover_coef_id, bt);
        ELSIF coef.brief = 'CASCO_COEF_NEXT_YEAR'
        THEN
          update_default_val(coef.p_cover_coef_id, k_popr);
        ELSIF coef.brief = 'DURATION'
        THEN
          update_default_val(coef.p_cover_coef_id, k_srok);
        ELSIF coef.brief = 'CASCO_DAMAGE_K8'
        THEN
          update_default_val(coef.p_cover_coef_id, k8);
        ELSIF coef.brief = 'CASCO_DAMAGE_K10'
        THEN
          update_default_val(coef.p_cover_coef_id, k10);
        ELSIF coef.brief = 'CASCO_DAMAGE_K10_1'
        THEN
          update_default_val(coef.p_cover_coef_id, k10_1);
        ELSIF coef.brief = 'CASCO_DAMAGE_K13'
        THEN
          update_default_val(coef.p_cover_coef_id, k13);
        ELSIF coef.brief = 'CASCO_DAMAGE_K14'
        THEN
          update_default_val(coef.p_cover_coef_id, k14);
        ELSIF coef.brief = 'CASCO_DAMAGE_K15'
        THEN
          update_default_val(coef.p_cover_coef_id, 1);
        END IF;
      END LOOP;
      RETURN calc_tarif_mul(p_p_cover_id);
    ELSE
    
      reg_coeff(p_p_cover_id, 'CASCO_COEF_35', k35);
      reg_coeff(p_p_cover_id, 'CASCO_COEF_91', k91);
      reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K15', 1);
      reg_coeff(p_p_cover_id, 'DURATION', k_srok);
      IF v_prod = 'Автокаско-Стандартный'
      THEN
        reg_coeff(p_p_cover_id, 'CASCO_ACCESSORIES', bt);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K8', k8);
        --reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K9', k9);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10', k10);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10_1', k10_1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K13', k13);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K14', k14);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K15', 1);
        v_result := bt * k8 * /*k9 **/
                    k10 * k13 * k14 * k_srok;
      ELSE
        IF v_ver = 1
           OR ins_year = 1
        THEN
          reg_coeff(p_p_cover_id, 'CASCO_TARIFF', bt);
        ELSE
          reg_coeff(p_p_cover_id, 'PREV_PREM_COVER', bt);
          reg_coeff(p_p_cover_id, 'CASCO_COEF_NEXT_YEAR', k_popr);
          IF is_pr > 0
          THEN
            v_result := bt * k_popr * k_srok * 100 / v_price;
          ELSE
            v_result := v_p_cover.tariff * 100;
          END IF;
        END IF;
      END IF;
    END IF;
  
    RETURN v_result;
  
  END;

  FUNCTION calc_tariff_casco_ns
  (
    p_p_cover_id IN NUMBER
   ,p_srok       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER AS
    v_result           NUMBER;
    v_str_type         NUMBER;
    v_is_driver_no_lim NUMBER(1);
  
    bt     NUMBER;
    k1     NUMBER;
    k2     NUMBER;
    k8     NUMBER;
    k9     NUMBER;
    k10    NUMBER;
    k10_1  NUMBER;
    k11    NUMBER;
    k13    NUMBER;
    k14    NUMBER;
    k35    NUMBER;
    k91    NUMBER;
    k_srok NUMBER;
    v_prod VARCHAR2(55);
  
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT pr.brief
      INTO v_prod
      FROM p_cover pc
      JOIN as_asset ass
        ON ass.as_asset_id = pc.as_asset_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
      JOIN t_product pr
        ON pr.product_id = ph.product_id
     WHERE pc.p_cover_id = p_p_cover_id;
  
    /*  if v_p_cover.IS_HANDCHANGE_AMOUNT = 1 then
      return calc_tarif_mul(p_p_cover_id);
    end if;*/
  
    /*
       delete from p_cover_coef pcc
       where pcc.p_cover_id  = p_p_cover_id;
    */
  
    -- риск
    SELECT tct.is_individual
          , --- тип стр-ля
           av.is_driver_no_lim
      INTO v_str_type
          ,v_is_driver_no_lim
      FROM ven_p_cover pc
     INNER JOIN ven_as_vehicle av
        ON pc.as_asset_id = av.as_vehicle_id
     INNER JOIN p_policy pp
        ON pp.policy_id = av.p_policy_id
     INNER JOIN p_pol_header ph
        ON pp.pol_header_id = ph.policy_header_id
     INNER JOIN p_policy_contact ppc
        ON ppc.policy_id = pp.policy_id
     INNER JOIN t_contact_pol_role cr
        ON cr.id = ppc.contact_policy_role_id
     INNER JOIN contact c
        ON c.contact_id = ppc.contact_id
     INNER JOIN t_contact_type tct
        ON tct.id = c.contact_type_id
     WHERE pc.p_cover_id = p_p_cover_id
       AND cr.brief = 'Страхователь';
  
    --Базовый тариф
    bt := pkg_tariff_calc.calc_fun('CASCO_NC_PAUSHALNAY', v_p_cover.ent_id, v_p_cover.p_cover_id);
    --  dbms_output.put_line(bt);
    --  dbms_output.put_line(v_p_cover.ent_id);
    --  dbms_output.put_line(v_p_cover.p_cover_id);
  
    --k1: Количество  лиц, допущенных  к  управлению
    IF (v_str_type = 1)
    THEN
      -- для страхователей ФЛ
      k1 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K1', v_p_cover.ent_id, p_p_cover_id);
    ELSE
      k1 := 1;
      k2 := 1;
    END IF;
  
    --k2: Стаж  вождения  лиц,  допущенных  к управлению
    IF (v_is_driver_no_lim = 0)
    THEN
      SELECT MAX(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K2', avd.ent_id, avd.as_vehicle_driver_id))
        INTO k2
        FROM ven_p_cover pc
       INNER JOIN ven_as_vehicle av
          ON pc.as_asset_id = av.as_vehicle_id
       INNER JOIN ven_as_vehicle_driver avd
          ON avd.as_vehicle_id = av.as_vehicle_id
       WHERE pc.p_cover_id = p_p_cover_id;
    ELSE
      k2 := 1;
    END IF;
  
    -- k8: Применение рассрочки страхового взноса
    k8 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K8', v_p_cover.ent_id, p_p_cover_id), 1);
  
    -- k9: Программа "До   первого  страхового  события"
    -- k9 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K9',v_p_cover.ent_id,p_p_cover_id),1);
  
    -- k10: Агентский  коэффициент
    k10   := 1;
    k10_1 := 1;
    -- k11: Страхование автомобилей с правым рулем
    k11 := pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K11', v_p_cover.ent_id, p_p_cover_id);
  
    -- k13: Семейный коэффициент
    k13 := 1;
  
    -- k14: Региональный коэффициент
    k14 := nvl(pkg_tariff_calc.calc_fun('CASCO_DAMAGE_K14', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k35: Поправочный коэффициент
    k35 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_35', v_p_cover.ent_id, p_p_cover_id), 1);
    -- k91: Региональный коэффициент
    k91 := nvl(pkg_tariff_calc.calc_fun('CASCO_COEF_91', v_p_cover.ent_id, p_p_cover_id), 1);
  
    k_srok := p_srok;
    IF (p_srok IS NULL)
    THEN
      k_srok := pkg_tariff_calc.calc_fun('DURATION', v_p_cover.ent_id, p_p_cover_id);
      IF k_srok IS NULL
      THEN
        k_srok := ROUND(CEIL(MONTHS_BETWEEN(v_p_cover.end_date, v_p_cover.start_date)) / 12, 5);
      END IF;
      IF (k_srok < 1)
      THEN
        IF (k2 < 1)
        THEN
          k2 := 1;
        END IF;
        IF (k_srok < 0.7)
        THEN
          k9 := 1;
        END IF;
        k10 := 1;
        k13 := 1;
        k14 := 1;
      END IF;
    END IF;
  
    IF v_p_cover.is_handchange_amount = 1
    THEN
      FOR coef IN (SELECT pcc.p_cover_coef_id
                         ,pct.brief
                     FROM p_cover_coef pcc
                     JOIN t_prod_coef_type pct
                       ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                    WHERE pcc.p_cover_id = p_p_cover_id)
      LOOP
        IF coef.brief = 'CASCO_COEF_35'
        THEN
          update_default_val(coef.p_cover_coef_id, k35);
        ELSIF coef.brief = 'CASCO_COEF_91'
        THEN
          update_default_val(coef.p_cover_coef_id, k91);
        ELSIF coef.brief = 'CASCO_NC_PAUSHALNAY'
        THEN
          update_default_val(coef.p_cover_coef_id, bt);
        ELSIF coef.brief = 'DURATION'
        THEN
          update_default_val(coef.p_cover_coef_id, k_srok);
        ELSIF coef.brief = 'CASCO_DAMAGE_K8'
        THEN
          update_default_val(coef.p_cover_coef_id, k8);
        ELSIF coef.brief = 'CASCO_DAMAGE_K10'
        THEN
          update_default_val(coef.p_cover_coef_id, k10);
        ELSIF coef.brief = 'CASCO_DAMAGE_K10_1'
        THEN
          update_default_val(coef.p_cover_coef_id, k10_1);
        ELSIF coef.brief = 'CASCO_DAMAGE_K13'
        THEN
          update_default_val(coef.p_cover_coef_id, k13);
        ELSIF coef.brief = 'CASCO_DAMAGE_K15'
        THEN
          update_default_val(coef.p_cover_coef_id, 1);
        END IF;
      END LOOP;
      RETURN calc_tarif_mul(p_p_cover_id);
    ELSE
      v_result := bt * k14 * k_srok;
      reg_coeff(p_p_cover_id, 'CASCO_NC_PAUSHALNAY', bt);
      reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K14', k14);
      reg_coeff(p_p_cover_id, 'DURATION', k_srok);
      reg_coeff(p_p_cover_id, 'CASCO_COEF_35', k35);
      reg_coeff(p_p_cover_id, 'CASCO_COEF_91', k91);
      IF v_prod = 'Автокаско-Стандартный'
      THEN
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K1', k1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K2', k2);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K8', k8);
        --reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K9', k9);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10', k10);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K10_1', k10_1);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K11', k11);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K13', k13);
        reg_coeff(p_p_cover_id, 'CASCO_DAMAGE_K15', 1);
        v_result := bt * k1 * k2 * k8 * /*k9 **/
                    k10 * k11 * k13 * k14 * k_srok;
      END IF;
      RETURN v_result;
    END IF;
  
  END;

  FUNCTION recalc_tariff_casco(p_p_cover_id IN NUMBER) RETURN NUMBER AS
  
    v_plo   VARCHAR2(255);
    v_st_br VARCHAR2(255);
    v_srok  NUMBER;
  BEGIN
  
    SELECT * INTO v_p_cover FROM p_cover p WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT plo.description
      INTO v_plo
      FROM p_cover p
      JOIN t_prod_line_option plo
        ON plo.id = p.t_prod_line_option_id
     WHERE p.p_cover_id = p_p_cover_id;
  
    SELECT sh.brief
      INTO v_st_br
      FROM status_hist sh
     WHERE sh.status_hist_id = v_p_cover.status_hist_id;
  
    IF (v_st_br = 'NEW')
    THEN
      CASE v_plo
        WHEN 'Ущерб' THEN
          RETURN calc_tariff_casco_damage(p_p_cover_id);
        WHEN 'Автокаско' THEN
          RETURN calc_tariff_casco_damage(p_p_cover_id);
        WHEN 'Дополнительное оборудование' THEN
          RETURN calc_tariff_casco_acces(p_p_cover_id);
        WHEN 'Гражданская ответственность' THEN
          RETURN calc_tariff_casco_liability(p_p_cover_id);
        WHEN 'Несчастные случаи' THEN
          RETURN calc_tariff_casco_ns(p_p_cover_id);
      END CASE;
    ELSIF (v_st_br = 'CURRENT')
    THEN
      SELECT nvl(pcc.val, 1)
        INTO v_srok
        FROM p_cover_coef pcc
        JOIN t_prod_coef_type pct
          ON pcc.t_prod_coef_type_id = pct.t_prod_coef_type_id
         AND pct.brief = 'DURATION'
       WHERE pcc.p_cover_id = p_p_cover_id;
      CASE v_plo
        WHEN 'Ущерб' THEN
          RETURN calc_tariff_casco_damage(p_p_cover_id, v_srok);
        WHEN 'Автокаско' THEN
          RETURN calc_tariff_casco_damage(p_p_cover_id, v_srok);
        WHEN 'Дополнительное оборудование' THEN
          RETURN calc_tariff_casco_acces(p_p_cover_id, v_srok);
        WHEN 'Гражданская ответственность' THEN
          RETURN calc_tariff_casco_liability(p_p_cover_id, v_srok);
        WHEN 'Несчастные случаи' THEN
          RETURN calc_tariff_casco_ns(p_p_cover_id, v_srok);
      END CASE;
    ELSE
      NULL;
    END IF;
  END;

  FUNCTION get_casco_gr(veh_id IN NUMBER) RETURN NUMBER AS
    v_result NUMBER;
  
    marka   VARCHAR2(255);
    model   VARCHAR2(255);
    type_ts VARCHAR2(255);
    nat     NUMBER;
  BEGIN
    SELECT upper(vm.name)
          ,upper(vmm.name)
          ,vt.brief
          ,vm.is_national_mark
      INTO marka
          ,model
          ,type_ts
          ,nat
      FROM as_vehicle v
      JOIN t_vehicle_mark vm
        ON vm.t_vehicle_mark_id = v.t_vehicle_mark_id
      JOIN t_main_model vmm
        ON vmm.t_main_model_id = v.t_main_model_id
      JOIN t_vehicle_type vt
        ON vt.t_vehicle_type_id = v.t_vehicle_type_id
     WHERE v.as_vehicle_id = veh_id;
  
    IF (nat = 1)
    THEN
      CASE
        WHEN (marka = 'ВАЗ' AND (model = '2104' OR model = '2105' OR model = '2106' OR model = '2107'))
             OR (marka = 'ГАЗ') THEN
          v_result := 1;
        
        WHEN marka = 'ВАЗ'
             AND
             (model = '2108' OR model = '2109' OR model = '21099' OR model = '2113' OR model = '2114' OR
             model = '2115' OR model = '2120' OR model = '2121' OR model = '2131') THEN
          v_result := 2;
        
        WHEN marka = 'ВАЗ'
             AND
             (model = '2110' OR model = '2111' OR model = '2112' OR model = '2123' OR model = '1118') THEN
          v_result := 3;
        
        WHEN marka = 'УАЗ'
             OR marka = 'ИЖ'
             OR marka = 'ОКА' THEN
          v_result := 4;
        
        WHEN type_ts = 'MICROBUS' THEN
          v_result := 5;
        
        WHEN type_ts LIKE 'BUS%'
             OR type_ts LIKE 'TRUCK%' THEN
          v_result := 6;
        
        WHEN type_ts = 'CAR_TRAILER_C' THEN
          v_result := 8;
        
        WHEN type_ts = 'TRUCK_TRAILER_C' THEN
          v_result := 9;
        
        ELSE
          v_result := 1;
      END CASE;
    ELSE
      CASE
        WHEN (marka = 'HYUNDAI' OR marka = 'KIA' OR marka = 'DAEWOO' OR marka = 'SSANG YONG' OR
             (marka = 'CHEVROLET' AND model IN ('LANOS', 'LACETTI', 'AVEO', 'SPARK'))) THEN
          v_result := 1;
        WHEN (marka = 'OPEL' OR marka = 'FORD' OR marka = 'NISSAN' OR marka = 'SAAB' OR
             marka = 'ALFA-ROMEO' OR marka = 'SEAT' OR marka = 'SKODA' OR marka = 'PEUGEOT' OR
             marka = 'CITROEN' OR marka = 'FIAT' OR marka = 'SUZUKI' OR marka = 'ISUZU') THEN
          v_result := 2;
        WHEN (marka = 'PLYMOUTH' OR marka = 'PONTIAC' OR
             (marka = 'CHEVROLET' AND model NOT IN ('LANOS', 'LACETTI', 'AVEO', 'SPARK')) OR
             marka = 'BUICK' OR marka = 'JEEP' OR marka = 'CADILLAC' OR marka = 'DODGE' OR
             marka = 'LINCOLN' OR marka = 'ACURA') THEN
          v_result := 3;
        WHEN (marka = 'VOLVO' AND
             substr(model, 1, 3) IN ('S40', 'S60', 'S80', 'V40', 'V50', 'C30', 'C70', 'S90')) THEN
          v_result := 4;
        WHEN (marka = 'VOLVO' AND
             (substr(model, 1, 3) IN ('V70', 'V90') OR substr(model, 1, 4) IN ('XC70', 'XC90'))) THEN
          v_result := 5;
        WHEN (marka = 'HONDA' AND substr(model, 1, 6) = 'ACCORD') THEN
          v_result := 7;
        WHEN (marka = 'HONDA' AND model IN ('CR-V', 'HR-V ')) THEN
          v_result := 8;
        WHEN (marka = 'MITSUBISHI' OR marka = 'MAZDA' OR marka = 'RENAULT' OR marka = 'HONDA') THEN
          v_result := 6;
        
        WHEN (marka = 'VOLKSWAGEN' AND model = 'PASSAT') THEN
          v_result := 10;
        WHEN (marka = 'VOLKSWAGEN' AND (model = 'LUPO' OR model = 'POLO' OR model = 'POINTER')) THEN
          v_result := 11;
        WHEN (marka = 'VOLKSWAGEN' AND substr(model, 1, 4) IN ('BORA', 'GOLF', 'POINTER')) THEN
          v_result := 12;
        WHEN (marka = 'VOLKSWAGEN' AND model = 'PHAETON') THEN
          v_result := 13;
        WHEN (marka = 'VOLKSWAGEN' AND model = 'TOUAREG') THEN
          v_result := 14;
        WHEN (marka = 'VOLKSWAGEN') THEN
          v_result := 9;
        WHEN (marka = 'LEXUS' AND substr(model, 1, 2) NOT IN ('GX', 'RX', 'LX ') AND
             type_ts LIKE 'CAR%') THEN
          v_result := 15;
        WHEN (marka = 'TOYOTA' AND (substr(model, 1, 7) = 'COROLLA' OR substr(model, 1, 5) = 'AURIS')) THEN
          v_result := 16;
        WHEN (marka = 'TOYOTA' AND substr(model, 1, 7) = 'AVENSIS') THEN
          v_result := 17;
        WHEN (marka = 'TOYOTA' AND (substr(model, 1, 5) IN ('CAMRY', 'RAV 4'))) THEN
          v_result := 18;
        
        WHEN (marka = 'TOYOTA' AND substr(model, 1, 12) = 'LAND CRUISER')
             OR (marka = 'LEXUS' AND substr(model, 1, 2) IN ('RX', 'LX', 'GX')) THEN
          v_result := 19;
        WHEN marka = 'TOYOTA' THEN
          v_result := 20;
        WHEN ((marka = 'BMW' AND substr(model, 1, 1) IN ('1', '3')) OR
             (marka = 'MERCEDES' AND model = 'A-KLASSE')) THEN
          v_result := 21;
        WHEN (marka = 'AUDI' AND substr(model, 1, 2) IN ('A2', 'A3', 'A4', 'TT')) THEN
          v_result := 22;
        WHEN (marka = 'AUDI' AND (substr(model, 1, 2) IN ('A6', 'S6') OR model = 'ALLROAD')) THEN
          v_result := 23;
        WHEN (marka = 'AUDI' AND substr(model, 1, 2) IN ('A8', 'S8', 'Q7')) THEN
          v_result := 24;
        WHEN (marka = 'BMW' AND substr(model, 1, 2) IN ('X3')) THEN
          v_result := 25;
        WHEN (marka = 'BMW' AND substr(model, 1, 1) IN ('5')) THEN
          v_result := 26;
        WHEN (marka = 'MERCEDES' AND substr(model, 1, 8) = 'E-KLASSE') THEN
          v_result := 27;
        WHEN (marka = 'MERCEDES' AND (substr(model, 1, 3) IN ('CLK', 'SLK') OR model IN ('C-KLASSE'))) THEN
          v_result := 28;
        WHEN ((marka = 'BMW' AND (substr(model, 1, 1) IN ('6', '7', 'M') OR model IN ('Z3', 'Z4'))) OR
             (marka = 'MERCEDES' AND
             (substr(model, 1, 2) IN ('CL', 'SL') OR substr(model, 1, 8) = 'S-KLASSE'))) THEN
          v_result := 29;
        WHEN ((marka = 'BMW' AND substr(model, 1, 2) IN ('X5')) OR
             (marka = 'MERCEDES' AND model IN ('G-MODELL', 'M-KLASSE'))) THEN
          v_result := 30;
        WHEN (marka = 'LAND ROVER' OR (marka = 'HUMMER' AND model IN ('H2', 'H1')) OR
             (marka = 'ACURA' AND model = 'MDX') OR (marka = 'INFINITI' AND model IN ('FX', 'QX')) OR
             marka = 'DEVENDER' OR marka = 'DISCAVERER' OR marka = 'FRELANDER' OR
             marka = 'RANGE ROVER') THEN
          v_result := 31;
        WHEN type_ts LIKE 'CAR%' THEN
          v_result := 32;
        WHEN (marka = 'PORSCHE' AND model = 'CAYENNE') THEN
          v_result := 33;
        WHEN ((marka = 'PORSCHE' AND type_ts LIKE 'CAR%') OR marka = 'JAGUAR') THEN
          v_result := 34;
        WHEN type_ts = 'MICROBUS' THEN
          v_result := 36;
        WHEN type_ts IN ('TRUCK_C', 'BUS_C') THEN
          v_result := 37;
        WHEN type_ts LIKE '%TRAILER%' THEN
          v_result := 38;
        ELSE
          v_result := 1;
      END CASE;
    END IF;
    RETURN v_result;
  END;

  PROCEDURE copy_tariff
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    /* sergey.ilyushkin 17/09/2012 RT 161629
     Добавил в процедуру копирования флаг ручной установки тарифа
    */
  BEGIN
    INSERT INTO p_cover_coef
      (p_cover_coef_id
      ,val
      ,p_cover_id
      ,t_prod_coef_type_id
      ,ent_id
      ,filial_id
      ,t_prod_line_coef_id
      ,ext_id
      ,is_damage
      ,default_val
      ,is_handchange_coef)
      SELECT sq_p_cover_coef.nextval
            ,tt.val
            ,p_new_id
            ,tt.t_prod_coef_type_id
            ,tt.ent_id
            ,tt.filial_id
            ,tt.t_prod_line_coef_id
            ,tt.ext_id
            ,tt.is_damage
            ,tt.default_val
            ,tt.is_handchange_coef
        FROM p_cover_coef tt
            ,t_prod_line_coef lc
       WHERE tt.p_cover_id = p_old_id
         AND tt.t_prod_line_coef_id = lc.t_prod_line_coef_id
         AND lc.is_disabled = 0;
  END;

  FUNCTION is_p_car(p_p_cover_id IN INTEGER) RETURN INTEGER IS
    RESULT INTEGER;
  BEGIN
    /*возвращает 1 если тип автомобиля легковой и 0 в противном случае */
    SELECT (CASE v_type
             WHEN 'CAR' THEN
              1
             ELSE
              0
           END) AS attr_id
      INTO RESULT
      FROM (SELECT vt.brief AS v_type
              FROM ven_p_cover pc
             INNER JOIN ven_as_vehicle av
                ON pc.as_asset_id = av.as_vehicle_id
             INNER JOIN t_vehicle_type vt
                ON vt.t_vehicle_type_id = av.t_vehicle_type_id
             WHERE pc.p_cover_id = p_p_cover_id);
  
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
  END is_p_car;

  FUNCTION max_coef_driver(p_p_cover_id IN INTEGER) RETURN NUMBER IS
    RESULT NUMBER;
    k      NUMBER;
  BEGIN
  
    RESULT := 0;
    SELECT av.is_driver_no_lim
      INTO RESULT
      FROM p_cover pc
      JOIN ven_as_vehicle av
        ON pc.as_asset_id = av.as_vehicle_id
     WHERE pc.p_cover_id = p_p_cover_id;
  
    IF (RESULT = 1)
    THEN
      RETURN RESULT;
    ELSE
      FOR cur_vod IN (SELECT avd.ent_id
                            ,avd.as_vehicle_driver_id
                        FROM p_cover pc
                        JOIN ven_as_vehicle av
                          ON av.as_vehicle_id = pc.as_asset_id
                        JOIN ven_as_vehicle_driver avd
                          ON avd.as_vehicle_id = av.as_vehicle_id
                       WHERE pc.p_cover_id = p_p_cover_id)
      LOOP
      
        k := pkg_tariff_calc.calc_fun('OSAGO_AGE_AND_EXPERIENCE'
                                     ,cur_vod.ent_id
                                     ,cur_vod.as_vehicle_driver_id);
        IF k > RESULT
        THEN
          RESULT := k;
        END IF;
      END LOOP;
    END IF;
    RETURN RESULT;
  END max_coef_driver;

  FUNCTION get_tariff_casco(p_c NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT pc.tariff / 100 INTO RESULT FROM p_cover pc WHERE pc.p_cover_id = p_c;
    RETURN RESULT;
  END;

  FUNCTION get_prev_prem(p_c NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT pc_pr.premium
      INTO RESULT
      FROM p_cover pc
      JOIN as_asset ass
        ON ass.as_asset_id = pc.as_asset_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN p_policy pp_pr
        ON pp_pr.pol_header_id = pp.pol_header_id
       AND pp_pr.version_num = pp.version_num - 1
      JOIN as_asset ass_pr
        ON ass_pr.p_policy_id = pp_pr.policy_id
       AND ass_pr.p_asset_header_id = ass.p_asset_header_id
      JOIN p_cover pc_pr
        ON pc_pr.as_asset_id = ass_pr.as_asset_id
       AND pc_pr.t_prod_line_option_id = pc.t_prod_line_option_id
     WHERE pc.p_cover_id = p_c;
    RETURN RESULT;
  END;

END;
/
