CREATE OR REPLACE PACKAGE PKG_XX_SCHEDULE_PREMIUM IS
  /**
  * Управление графиком по объектам ипотеки в разрезе рисков
  * @author A. Marchuk
  */
  /**
  */
  --
  TYPE r_schedule IS RECORD(
     as_asset_header_id NUMBER(15)
    ,schedule_num       NUMBER(4));
  --
  TYPE tbl_schedule IS TABLE OF r_schedule;
  --
  TYPE r_schedule_premium IS RECORD(
     AS_ASSET_HEADER_ID      NUMBER(15)
    ,YEAR                    NUMBER(3)
    ,PLO_ASSET_ID            NUMBER(15)
    ,PLO_ASSET_PERSON_ID     NUMBER(15)
    ,PLO_PERSON_ID           NUMBER(15)
    ,ASSET_PREMIUM           NUMBER
    ,ASSET_PERSON_PREMIUM    NUMBER
    ,PERSON_PREMIUM          NUMBER
    ,ASSET_TARIFF            NUMBER
    ,ASSET_PERSON_TARIFF     NUMBER
    ,PERSON_TARIFF           NUMBER
    ,ASSET_UNDER_COEF        NUMBER
    ,ASSET_PERSON_UNDER_COEF NUMBER
    ,PERSON_UNDER_COEF       NUMBER
    ,ASSET_OTHER_COEF        NUMBER
    ,ASSET_PERSON_OTHER_COEF NUMBER
    ,PERSON_OTHER_COEF       NUMBER);

  --
  TYPE tbl_schedule_premium IS TABLE OF r_schedule_premium;

  --
  TYPE r_policy_schedule_premium IS RECORD(
     POL_HEADER_ID        NUMBER(15)
    ,P_POLICY_ID          NUMBER(15)
    ,YEAR                 NUMBER(3)
    ,PLO_ASSET_ID         NUMBER(15)
    ,PLO_ASSET_PERSON_ID  NUMBER(15)
    ,PLO_PERSON_ID        NUMBER(15)
    ,ASSET_PREMIUM        NUMBER
    ,ASSET_PERSON_PREMIUM NUMBER
    ,PERSON_PREMIUM       NUMBER);

  TYPE tbl_policy_schedule_premium IS TABLE OF r_policy_schedule_premium;

  /**
  * Установить пакетную переменную
  * Используется для передачи в view V_ASSET_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */

  PROCEDURE set_as_asset_header_id(p_as_asset_header_id IN NUMBER);

  /**
  * Установить пакетную переменную
  * Используется для передачи в view V_ASSET_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */

  FUNCTION get_as_asset_header_id RETURN NUMBER;

  /**
  * Установить пакетную переменную
  * Используется для передачи в view V_ASSET_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */
  FUNCTION get_policy_id RETURN NUMBER;

  /**
  * Получить сформированный по годам график
  * Используется для view V_ASSET_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */

  FUNCTION get_schedule(p_as_asset_header_id IN NUMBER) RETURN tbl_schedule
    PIPELINED;

  /**
  * Получить сформированный по годам график
  * Используется для view V_POLICY_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */

  FUNCTION get_policy_schedule(p_p_policy_id IN NUMBER) RETURN tbl_schedule
    PIPELINED;
  /**
  * Получить сформированный по годам график с суммой премии
  * Используется для view V_ASSET_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */

  FUNCTION get_schedule_premium(p_as_asset_header_id IN NUMBER) RETURN tbl_schedule_premium
    PIPELINED;

  /**
  * Получить сформированный по годам график с суммой премии по полису
  * Используется для view V_POLICY_SCHEDULE_PREMIUM sp параметра
  * @author A. Marchuk
  * @param p_as_asset_id ид объекта
  */

  FUNCTION get_policy_schedule_premium(p_p_policy_id IN NUMBER) RETURN tbl_policy_schedule_premium
    PIPELINED;

  /**
  * Полный перерасчет графика для полиса
  * @author O.Patsan
  * @param par_policy_id ИД полиса
  */
  PROCEDURE recalc_schedule_all(par_policy_id IN NUMBER);

  PROCEDURE create_prolong(par_policy_id IN NUMBER);

  PROCEDURE delete_prolong(par_policy_id IN NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX_SCHEDULE_PREMIUM IS
  --
  p_p_as_asset_header_id NUMBER;
  --
  FUNCTION get_schedule(p_as_asset_header_id IN NUMBER) RETURN tbl_schedule
    PIPELINED IS
    l_year_number NUMBER(3);
    RESULT        r_schedule;
  BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(pp.end_date + 1, ph.start_date) / 12)
      INTO l_year_number
      FROM p_policy     pp
          ,as_asset     aa
          ,p_pol_header ph
     WHERE 1 = 1
       AND aa.p_asset_header_id = p_as_asset_header_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pp.policy_id = aa.p_policy_id
       AND ROWNUM = 1;
    FOR i IN 1 .. l_year_number
    LOOP
      result.as_asset_header_id := p_as_asset_header_id;
      result.schedule_num       := i;
      PIPE ROW(RESULT);
    END LOOP;
    RETURN;
  END;

  FUNCTION get_policy_schedule(p_p_policy_id IN NUMBER) RETURN tbl_schedule
    PIPELINED IS
    l_year_number NUMBER(3);
    RESULT        r_schedule;
  BEGIN
    SELECT CEIL(MONTHS_BETWEEN(pp.end_date + 1, ph.start_date) / 12)
      INTO l_year_number
      FROM p_policy     pp
          ,p_pol_header ph
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
    --
    FOR cur IN (SELECT DISTINCT aa.p_asset_header_id FROM as_asset aa WHERE p_policy_id = p_p_policy_id)
    LOOP
      FOR i IN 1 .. l_year_number
      LOOP
        result.as_asset_header_id := cur.p_asset_header_id;
        result.schedule_num       := i;
        PIPE ROW(RESULT);
      END LOOP;
    END LOOP;
    RETURN;
  END;

  FUNCTION get_schedule_premium(p_as_asset_header_id IN NUMBER) RETURN tbl_schedule_premium
    PIPELINED IS
    RESULT r_schedule_premium;
    CURSOR c_result IS
      SELECT sc.as_asset_header_id
            ,sc.schedule_num YEAR
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,plo.ID
                       ,NULL)) plo_asset_id
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,plo.ID
                       ,NULL)) plo_asset_person_id
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,plo.ID
                       ,NULL)) plo_person_id
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.PREMIUM, NULL)
                       ,NULL)) asset_premium
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.PREMIUM, NULL)
                       ,NULL)) asset_person_premium
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.PREMIUM, NULL)
                       ,NULL)) person_premium
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.tariff, NULL)
                       ,NULL)) asset_tariff
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.tariff, NULL)
                       ,NULL)) asset_person_tariff
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.tariff, NULL)
                       ,NULL)) person_tariff
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.under_coef, NULL)
                       ,NULL)) asset_under_coef
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.under_coef, NULL)
                       ,NULL)) asset_person_under_coef
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.under_coef, NULL)
                       ,NULL)) person_under_coef
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.other_coef, NULL)
                       ,NULL)) asset_other_coef
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.other_coef, NULL)
                       ,NULL)) asset_person_other_coef
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.other_coef, NULL)
                       ,NULL)) person_other_coef
        FROM (SELECT as_asset_header_id
                    ,schedule_num
                FROM TABLE(PKG_XX_SCHEDULE_PREMIUM.get_schedule(p_as_asset_header_id))
              UNION
              SELECT DISTINCT p_asset_header_id
                             ,YEAR schedule_num
                FROM SCHEDULE_PREMIUM sp
               WHERE sp.p_asset_header_id = p_as_asset_header_id) sc
            ,SCHEDULE_PREMIUM sp
            ,T_PROD_LINE_OPTION plo
            ,t_product_version pv
            ,t_product_ver_lob pvl
            ,t_product_line pl
            ,t_product_line_type plt
            ,t_as_type_prod_line atpl
            ,
             --   as_asset aa,
             p_asset_header pah
       WHERE 1 = 1
         AND sp.p_asset_header_id(+) = sc.as_asset_header_id
         AND sp.YEAR(+) = sc.schedule_num
            --     and aa.p_asset_header_id = sc.as_asset_header_id
         AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.visible_flag = 1
         AND pl.ID = atpl.product_line_id
         AND p_as_asset_header_id = pah.p_asset_header_id
         AND atpl.asset_common_type_id = pah.t_asset_type_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND plo.product_line_id(+) = pl.ID
         AND ((sp.T_PROD_LINE_OPTION_id IS NOT NULL AND plo.ID = sp.T_PROD_LINE_OPTION_id) OR
             (sp.T_PROD_LINE_OPTION_id IS NULL AND 1 = 1))
       GROUP BY sc.as_asset_header_id
               ,sc.schedule_num;
  BEGIN
    FOR cur IN c_result
    LOOP
      result.as_asset_header_id   := cur.as_asset_header_id;
      result.YEAR                 := cur.YEAR;
      result.plo_asset_id         := cur.plo_asset_id;
      result.plo_asset_person_id  := cur.plo_asset_person_id;
      result.plo_person_id        := cur.plo_person_id;
      result.asset_premium        := cur.asset_premium;
      result.asset_person_premium := cur.asset_person_premium;
      result.person_premium       := cur.person_premium;
    
      result.asset_tariff        := cur.asset_tariff;
      result.asset_person_tariff := cur.asset_person_tariff;
      result.person_tariff       := cur.person_tariff;
    
      result.asset_under_coef        := cur.asset_under_coef;
      result.asset_person_under_coef := cur.asset_person_under_coef;
      result.person_under_coef       := cur.person_under_coef;
    
      result.asset_other_coef        := cur.asset_other_coef;
      result.asset_person_other_coef := cur.asset_person_other_coef;
      result.person_other_coef       := cur.person_other_coef;
    
      PIPE ROW(RESULT);
    END LOOP;
    RETURN;
  
  END;

  FUNCTION get_policy_schedule_premium(p_p_policy_id IN NUMBER) RETURN tbl_policy_schedule_premium
    PIPELINED IS
    RESULT r_policy_schedule_premium;
    CURSOR c_result IS
      SELECT pp.pol_header_id
            ,pp.policy_id
            ,sc.schedule_num YEAR
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,plo.ID
                       ,NULL)) plo_asset_id
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,plo.ID
                       ,NULL)) plo_asset_person_id
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,plo.ID
                       ,NULL)) plo_person_id
            ,SUM(DECODE(plo.description
                       ,'ИМФЛ Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.PREMIUM, NULL)
                       ,NULL)) asset_premium
            ,SUM(DECODE(plo.description
                       ,'ФР Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.PREMIUM, NULL)
                       ,NULL)) asset_person_premium
            ,SUM(DECODE(plo.description
                       ,'НС Комплексное ипотечное страхование'
                       ,DECODE(plo.ID, sp.T_PROD_LINE_OPTION_id, sp.PREMIUM, NULL)
                       ,NULL)) person_premium
        FROM (SELECT as_asset_header_id
                    ,schedule_num
                FROM TABLE(PKG_XX_SCHEDULE_PREMIUM.get_policy_schedule(p_p_policy_id))
              UNION
              SELECT DISTINCT sp.p_asset_header_id
                             ,YEAR schedule_num
                FROM SCHEDULE_PREMIUM sp
                    ,AS_ASSET         aa
               WHERE aa.p_policy_id = p_p_policy_id
                 AND sp.p_asset_header_id = aa.p_asset_header_id) sc
            ,SCHEDULE_PREMIUM sp
            ,T_PROD_LINE_OPTION plo
            ,t_product_version pv
            ,t_product_ver_lob pvl
            ,t_product_line pl
            ,t_product_line_type plt
            ,t_as_type_prod_line atpl
            ,P_POLICY pp
            ,
             -- as_asset aa,
             p_asset_header pah
       WHERE 1 = 1
         AND sp.p_asset_header_id(+) = sc.as_asset_header_id
         AND sp.YEAR(+) = sc.schedule_num
            -- and aa.as_asset_id = sc.as_asset_id
         AND pp.policy_id = p_p_policy_id
         AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND pv.t_product_version_id = pvl.product_version_id
         AND pl.visible_flag = 1
         AND pl.ID = atpl.product_line_id
         AND sc.as_asset_header_id = pah.p_asset_header_id
         AND atpl.asset_common_type_id = pah.t_asset_type_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND plo.product_line_id(+) = pl.ID
         AND ((sp.T_PROD_LINE_OPTION_id IS NOT NULL AND plo.ID = sp.T_PROD_LINE_OPTION_id) OR
             (sp.T_PROD_LINE_OPTION_id IS NULL AND 1 = 1))
       GROUP BY pp.pol_header_id
               ,pp.policy_id
               ,sc.schedule_num;
  
  BEGIN
    FOR cur IN c_result
    LOOP
      result.pol_header_id        := cur.pol_header_id;
      result.p_policy_id          := cur.policy_id;
      result.YEAR                 := cur.YEAR;
      result.plo_asset_id         := cur.plo_asset_id;
      result.plo_asset_person_id  := cur.plo_asset_person_id;
      result.plo_person_id        := cur.plo_person_id;
      result.asset_premium        := cur.asset_premium;
      result.asset_person_premium := cur.asset_person_premium;
      result.person_premium       := cur.person_premium;
    
      PIPE ROW(RESULT);
    
    END LOOP;
    RETURN;
  
  END;

  PROCEDURE set_as_asset_header_id(p_as_asset_header_id IN NUMBER) IS
  BEGIN
    p_p_as_asset_header_id := p_as_asset_header_id;
  END;
  FUNCTION get_as_asset_header_id RETURN NUMBER IS
  BEGIN
    RETURN p_p_as_asset_header_id;
  END;
  --

  FUNCTION get_policy_id RETURN NUMBER IS
    RESULT NUMBER(15);
  BEGIN
    SELECT p_policy_id
      INTO RESULT
      FROM as_asset
     WHERE p_asset_header_id = p_p_as_asset_header_id
       AND ROWNUM = 1;
    RETURN RESULT;
  END;
  --

  PROCEDURE create_prolong(par_policy_id IN NUMBER) IS
    var_pol             p_policy%ROWTYPE;
    var_cur_pol_id      NUMBER := par_policy_id;
    var_id              NUMBER;
    i                   NUMBER;
    var_pol_ch_type     NUMBER;
    v_prolong_alg_brief VARCHAR2(30);
  BEGIN
    pkg_policy.flag_dont_check_status := 1;
    SELECT p.t_policy_change_type_id
      INTO var_pol_ch_type
      FROM t_policy_change_type p
     WHERE p.brief = 'Основные';
    BEGIN
      SELECT DISTINCT pa.brief
        INTO v_prolong_alg_brief
        FROM p_pol_header      ph
            ,p_policy          p
            ,t_product_ver_lob pvl
            ,t_product_line    pl
            ,t_product_version pv
            ,t_prolong_alg     pa
       WHERE p.policy_id = par_policy_id
         AND ph.policy_header_id = p.pol_header_id
         AND pv.product_id = ph.product_id
         AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
         AND pvl.product_version_id = pv.t_product_version_id
         AND pl.t_prolong_alg_id = pa.t_prolong_alg_id
         AND pl.is_avtoprolongation = 1;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Неверно заданы алгоритмы пролонгации на линиях продуктов');
    END;
    LOOP
      SELECT pp.* INTO var_pol FROM p_policy pp WHERE pp.policy_id = var_cur_pol_id;
    
      IF v_prolong_alg_brief = 'ResidueUnSeparate'
      THEN
        EXIT WHEN MONTHS_BETWEEN(var_pol.end_date + 1, var_pol.start_date) / 12 < 2;
      ELSE
        EXIT WHEN MONTHS_BETWEEN(var_pol.end_date + 1, var_pol.start_date) / 12 < 1;
      END IF;
      var_id := pkg_policy.new_policy_version(var_cur_pol_id);
      i      := pkg_policy.set_pol_version_order_num(var_id);
    
      UPDATE p_policy pp
         SET pp.start_date            = ADD_MONTHS(var_pol.start_date, 12)
            ,pp.confirm_date_addendum = ADD_MONTHS(var_pol.start_date, 12)
            ,pp.notice_date_addendum  = ADD_MONTHS(var_pol.start_date, 12)
            ,pp.t_pol_change_type_id  = var_pol_ch_type
       WHERE pp.policy_id = var_id;
    
      INSERT INTO p_pol_addendum_type
        (p_pol_addendum_type_id, p_policy_id, t_addendum_type_id)
        SELECT sq_p_pol_addendum_type.NEXTVAL
              ,var_id
              ,AT.t_addendum_type_id
          FROM t_addendum_type AT
         WHERE AT.brief = 'Автопролонгация';
    
      i := var_id;
    
      pkg_policy.update_policy_dates(i);
      var_cur_pol_id := var_id;
    END LOOP;
    pkg_policy.flag_dont_check_status := 0;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_policy.flag_dont_check_status := 0;
  END;

  PROCEDURE delete_prolong(par_policy_id IN NUMBER) IS
  BEGIN
    FOR rc IN (SELECT p2.policy_id
                 FROM p_policy p
                     ,p_policy p2
                WHERE p.policy_id = par_policy_id
                  AND p2.pol_header_id = p.pol_header_id
                  AND NVL(p.version_num, 0) < NVL(p2.version_num, 0))
    LOOP
      DELETE FROM p_policy pp WHERE pp.policy_id = rc.policy_id;
      DELETE FROM document d WHERE d.document_id = rc.policy_id;
    END LOOP;
  END;

  PROCEDURE recalc_schedule_all(par_policy_id IN NUMBER) IS
    var_start_date DATE;
    var_cover      p_cover%ROWTYPE;
    var_id         NUMBER;
    --var_old_id     number;
    --var_pol_id     number;
    --var_pol_date   date;
    var_under_coef NUMBER;
    var_other_coef NUMBER;
    var_product    VARCHAR2(30);
    var_ph_id      NUMBER;
    --var_credit_s   number;
    --var_debt_perc  number;
  
    var_last_policy NUMBER;
  
    FUNCTION get_coef
    (
      par_id   IN NUMBER
     ,is_under IN NUMBER
    ) RETURN NUMBER IS
      var_ret NUMBER := 1;
    BEGIN
      FOR rco IN (SELECT pcc.val
                    FROM p_cover_coef     pcc
                        ,t_prod_coef_type pct
                   WHERE pcc.p_cover_id = par_id
                     AND pcc.T_PROD_COEF_TYPE_ID = pct.T_PROD_COEF_TYPE_ID
                     AND ((pct.brief = 'PROPERTY_UNDERWRITER' AND is_under = 1) OR
                         ((pct.brief <> 'PROPERTY_UNDERWRITER' AND is_under <> 1))))
      LOOP
        var_ret := var_ret * NVL(rco.val, 0);
      END LOOP;
      RETURN var_ret;
    END;
  
  BEGIN
  
    SELECT ph.start_date
          ,tp.brief
          ,ph.policy_header_id
      INTO var_start_date
          ,var_product
          ,var_ph_id
      FROM p_policy     pp
          ,p_pol_header ph
          ,t_product    tp
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    IF var_product IN ('Автокаско-ВТБ24', 'Ипотека')
    THEN
    
      SELECT pp.policy_id
        INTO var_last_policy
        FROM p_policy pp
       WHERE pp.pol_header_id = var_ph_id
         AND NVL(pp.version_num, 0) IN
             (SELECT MAX(NVL(p.version_num, 0)) FROM p_policy p WHERE p.pol_header_id = var_ph_id);
    
      create_prolong(var_last_policy);
    
      DELETE FROM schedule_premium sp
       WHERE sp.p_asset_header_id IN
             (SELECT aa.p_asset_header_id FROM as_asset aa WHERE aa.p_policy_id = par_policy_id);
    
      -- цикл по году, асет-хедеру и риску
      FOR rc IN (SELECT DISTINCT t.as_asset_header_id
                                ,t.schedule_num
                                ,pc.t_prod_line_option_id
                   FROM TABLE(PKG_XX_SCHEDULE_PREMIUM.get_policy_schedule(par_policy_id)) t
                       ,as_asset aa
                       ,p_cover pc
                  WHERE pc.as_asset_id = aa.as_asset_id
                       --and t.schedule_num = 10 and t.as_asset_header_id = 10203
                    AND aa.p_asset_header_id = t.as_asset_header_id)
      LOOP
      
        SELECT sq_schedule_premium.NEXTVAL INTO var_id FROM dual;
      
        --если существует покрытие, то берем значения оттуда
        BEGIN
          SELECT pc.*
            INTO var_cover
            FROM p_cover  pc
                ,as_asset aa
           WHERE pc.start_date = ADD_MONTHS(var_start_date, (rc.schedule_num - 1) * 12)
             AND aa.p_asset_header_id = rc.as_asset_header_id
             AND aa.as_asset_id = pc.as_asset_id
             AND pc.t_prod_line_option_id = rc.t_prod_line_option_id;
          var_under_coef := get_coef(var_cover.p_cover_id, 1);
          var_other_coef := get_coef(var_cover.p_cover_id, 0);
        
          INSERT INTO schedule_prem_coef
            (schedule_prem_coef_id, schedule_premium_id, t_prod_coef_type_id, val)
            SELECT sq_schedule_prem_coef.NEXTVAL
                  ,var_id
                  ,pcc.t_prod_coef_type_id
                  ,pcc.val
              FROM p_cover_coef pcc
             WHERE pcc.p_cover_id = var_cover.p_cover_id;
        
          INSERT INTO schedule_premium
            (schedule_premium_id
            ,p_asset_header_id
            ,YEAR
            ,t_prod_line_option_id
            ,premium
            ,tariff
            ,under_coef
            ,other_coef
            ,ins_amount
            ,start_date
            ,end_date)
          VALUES
            (var_id
            ,rc.as_asset_header_id
            ,rc.schedule_num
            ,rc.t_prod_line_option_id
            ,var_cover.premium
            ,ROUND(var_cover.premium / var_cover.ins_amount * 100, 4)
            ,var_under_coef
            ,var_other_coef
            ,var_cover.ins_amount
            ,var_cover.start_date
            ,var_cover.end_date);
        EXCEPTION
          WHEN OTHERS THEN
            DELETE FROM schedule_prem_coef WHERE schedule_premium_id = var_id;
        END;
      
      END LOOP;
    END IF;
  
    delete_prolong(var_last_policy);
  END;

END;
/
