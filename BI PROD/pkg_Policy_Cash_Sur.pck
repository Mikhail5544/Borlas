CREATE OR REPLACE PACKAGE pkg_policy_cash_sur IS
  /**
  * Алгоритмы для вариантов страхования жизни
  * @author Ivanov D.
  * @version Reserve For Life 1.1
  * @since 1.1
  * @headcom
  */
  --
  TYPE r_schedule IS RECORD(
     schedule_num        NUMBER(4)
    ,start_schedule_date DATE
    ,end_schedule_date   DATE
    
    );
  --
  TYPE tbl_schedule IS TABLE OF r_schedule;
  --
  TYPE r_cash_surrender IS RECORD(
     policy_header_id      NUMBER
    ,policy_id             NUMBER
    ,t_lob_line_id         NUMBER
    ,contact_id            NUMBER
    ,insurance_year_date   DATE
    ,start_cash_surr_date  DATE
    ,end_cash_surr_date    DATE
    ,insurance_year_number NUMBER
    ,payment_number        NUMBER
    ,is_history            NUMBER(1)
    ,VALUE                 NUMBER
    ,ft                    NUMBER
    ,ins_amount            NUMBER
    ,cv                    NUMBER
    ,product_line_id       NUMBER
    ,reserve_value         policy_cash_surr_d.reserve_value%TYPE);

  --
  TYPE tbl_cash_surrender IS TABLE OF r_cash_surrender INDEX BY BINARY_INTEGER;
  --

  TYPE tbl_dest IS TABLE OF policy_cash_surr_d%ROWTYPE INDEX BY BINARY_INTEGER;

  --g_header_start_date DATE;

  /**
  *  @Author Marchuk A.
  * Функция расчета графика выкупных сумм
  * @param p_policy_id ИД версии договора
  * @param p_brief Краткое название графика оплаты страхового договора
  * @param p_start_date Дата начала действия
  * @param p_year Количество лет действия
  */

  FUNCTION get_schedule
  (
    p_p_policy_id IN NUMBER
   ,p_brief       VARCHAR2
   ,p_start_date  IN DATE
   ,p_year        IN NUMBER
  ) RETURN tbl_schedule
    PIPELINED;

  /*
  FUNCTION get_year_date
  (
    p_date                IN DATE
   ,p_t                   IN NUMBER
   ,par_header_start_date DATE DEFAULT g_header_start_date
  ) RETURN DATE;
  */

  /**
  *  @Author Marchuk A.
  * Процедура расчета и сохранения выкупных сумм по ИД версии полиса
  * @param p_policy_id ИД версии полиса
  */
  PROCEDURE calc_cash_surrender(p_p_policy_id IN NUMBER);

  /**
  *  @Author Marchuk A.
  * Процедура удаления всех расчитанных выкупных сумм по договору
  * @param p_policy_id ИД версии полиса
  */

  PROCEDURE drop_cash_surrender
  (
    p_p_policy_id   IN NUMBER
   ,p_contact_id    IN NUMBER
   ,p_t_lob_line_id IN NUMBER
  );

  PROCEDURE drop_cash_surrender(p_p_policy_id IN NUMBER);

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД версии полиса И ИД застрахованного
  * @param p_policy_id ID версии полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value
  (
    p_policy_id  IN NUMBER
   ,p_contact_id IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER;

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД версии полиса И ИД застрахованного и ИД страховой программы
  * @param p_policy_id ID версии полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_t_lob_line_id ИД страховой программы
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value
  (
    p_policy_id     IN NUMBER
   ,p_contact_id    IN NUMBER
   ,p_t_lob_line_id IN NUMBER
   ,p_date          IN DATE
  ) RETURN NUMBER;
  FUNCTION get_value_c_mine
  (
    p_p_cover_id IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER;
  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД покрытия
  * @param p_p_cover_id ИД страхового покрытия
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value_c
  (
    p_p_cover_id IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER;

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД полиса И ИД застрахованного
  * @param p_policy_header_id ID полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value_h
  (
    p_policy_header_id IN NUMBER
   ,p_contact_id       IN NUMBER
   ,p_date             IN DATE
  ) RETURN NUMBER;

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД полиса И ИД застрахованного и ИД страховой программы
  * @param p_policy_header_id ID полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_t_lob_line_id ИД страховой программы
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value_h
  (
    p_policy_header_id IN NUMBER
   ,p_contact_id       IN NUMBER
   ,p_t_lob_line_id    IN NUMBER
   ,p_date             IN DATE
  ) RETURN NUMBER;
  --
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_cash_sur AS

  g_debug             BOOLEAN := FALSE;
  g_header_start_date DATE;
  g_policy_header_id  NUMBER;
  g_asset_header_id   NUMBER;
  g_brief             VARCHAR2(30);

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  ex_cash_surr_d_cal_failure EXCEPTION;

  TYPE typ_policy_info IS RECORD(
     poilcy_id                  p_policy.policy_id%TYPE
    ,policy_header_id           p_pol_header.policy_header_id%TYPE
    ,is_periodical              t_payment_terms.is_periodical%TYPE
    ,payment_terms_brief        t_payment_terms.brief%TYPE
    ,number_of_payments         t_payment_terms.number_of_payments%TYPE
    ,header_start_date          p_pol_header.start_date%TYPE
    ,start_date                 DATE
    ,version_num                p_policy.version_num%TYPE
    ,period_year                NUMBER
    ,period_year_fh             NUMBER
    ,policy_year_on_cover_start NUMBER
    ,product_id                 t_product.product_id%TYPE
    ,product_brief              t_product.brief%TYPE);

  CURSOR c_schedule(par_policy_info typ_policy_info) IS
    SELECT rownum rn
          ,schedule_num
          ,start_schedule_date
          ,end_schedule_date
          ,trunc(MONTHS_BETWEEN(start_schedule_date, par_policy_info.header_start_date) / 12) AS insurance_year_number
      FROM TABLE(pkg_policy_cash_surrender.get_schedule(par_policy_info.poilcy_id
                                                       ,par_policy_info.payment_terms_brief
                                                       ,par_policy_info.start_date
                                                       ,par_policy_info.period_year));

  SUBTYPE typ_schedule IS c_schedule%ROWTYPE;

  PROCEDURE log
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO policy_cash_surrender_debug
        (p_policy_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_policy_id, SYSDATE, 'INS.POLICY_CASH_SURRENDER_DEBUG', substr(p_message, 1, 4000));
    
      COMMIT;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /*
    Капля П.
    01.08.2014
    Функция получения базовой информации о договоре, необходимой для расчета
    Сделано на остоне Инвестора, вероятно требует дополнения
  */
  FUNCTION get_policy_info
  (
    par_policy_id NUMBER
   ,par_cover_id  NUMBER
  ) RETURN typ_policy_info IS
    v_policy_info typ_policy_info;
  BEGIN
    SELECT pp.policy_id
          ,ph.policy_header_id
          ,pt.is_periodical
          ,pt.brief
          ,pt.number_of_payments
          ,ph.start_date header_start_date
          ,trunc(pp.start_date) start_date
          ,pp.version_num
          ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
          ,ROUND(MONTHS_BETWEEN(pc.start_date, ph.start_date) / 12, 2) + 1 policy_year_on_cover_start
          ,p.product_id
          ,p.brief
      INTO v_policy_info
      FROM t_payment_terms pt
          ,p_pol_header    ph
          ,t_product       p
          ,p_policy        pp
          ,p_cover         pc
     WHERE 1 = 1
       AND pp.policy_id = par_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id
       AND ph.product_id = p.product_id
       AND pc.p_cover_id = par_cover_id;
  
    RETURN v_policy_info;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN CAST(NULL AS typ_policy_info);
  END get_policy_info;

  /**
  *  @Author Marchuk A.
  * ППроцедура сохранения выкупных сумм в БД сумм
  * @param resultset PL/SQL таблица с данными расчета
  */

  FUNCTION get_schedule
  (
    p_p_policy_id IN NUMBER
   ,p_brief       VARCHAR2
   ,p_start_date  IN DATE
   ,p_year        IN NUMBER
  ) RETURN tbl_schedule
    PIPELINED IS
    v_schedule_num           NUMBER;
    v_prev_header_start_date DATE;
    v_end_date               DATE;
    v_cur_start_date         DATE;
    v_year_date              DATE;
    p_per_year               NUMBER;
    RESULT                   r_schedule;
  BEGIN
    IF p_brief = 'Единовременно'
       OR p_brief = 'EVERY_QUARTER'
    THEN
      v_end_date := ADD_MONTHS(p_start_date, 12 * p_year);
    
      FOR j IN 1 .. p_year
      LOOP
        v_year_date := ADD_MONTHS(p_start_date, 12 * (j - 1));
        IF j = 1
        THEN
          v_schedule_num := 1;
        
          result.schedule_num        := v_schedule_num;
          result.start_schedule_date := p_start_date;
          result.end_schedule_date   := ADD_MONTHS(v_year_date, 3) - 1;
          PIPE ROW(RESULT);
        ELSE
          v_schedule_num := v_schedule_num + 1;
        
          result.schedule_num        := v_schedule_num;
          result.start_schedule_date := ADD_MONTHS(v_year_date, 0);
          result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 3) - 1;
          --
          PIPE ROW(RESULT);
          --
        END IF;
        IF j = p_year + 1
        THEN
          EXIT;
        END IF;
        --    Второй квартал
        v_schedule_num             := v_schedule_num + 1;
        result.schedule_num        := v_schedule_num;
        result.start_schedule_date := ADD_MONTHS(v_year_date, 3);
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 3) - 1;
      
        PIPE ROW(RESULT);
      
        --    Третий квартал
        v_schedule_num             := v_schedule_num + 1;
        result.schedule_num        := v_schedule_num;
        result.start_schedule_date := ADD_MONTHS(v_year_date, 6);
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 3) - 1;
      
        PIPE ROW(RESULT);
      
        --    Четвертый квартал
        v_schedule_num             := v_schedule_num + 1;
        result.schedule_num        := v_schedule_num;
        result.start_schedule_date := ADD_MONTHS(v_year_date, 9);
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 3) - 1;
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'EVERY_YEAR'
    THEN
    
      FOR j IN 1 .. (p_year)
      LOOP
      
        result.schedule_num        := j;
        result.start_schedule_date := ADD_MONTHS(p_start_date, 12 * (j - 1));
        IF j = (p_year + 1)
        THEN
          result.end_schedule_date := result.start_schedule_date;
        ELSE
          result.end_schedule_date := ADD_MONTHS(p_start_date, 12 * (j)) - 1;
        END IF;
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'HALF_YEAR'
    THEN
    
      FOR j IN 1 .. (p_year)
      LOOP
      
        result.schedule_num        := j;
        result.start_schedule_date := ADD_MONTHS(p_start_date, 12 * (j - 1));
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 6) - 1;
      
        PIPE ROW(RESULT);
      
        result.start_schedule_date := result.end_schedule_date + 1;
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 6) - 1;
      
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'MONTHLY'
    THEN
    
      SELECT trunc(MONTHS_BETWEEN(pp.start_date, ph.start_date) / 12) period_year
        INTO p_per_year
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE 1 = 1
         AND pp.policy_id = p_p_policy_id
         AND ph.policy_header_id = pp.pol_header_id;
    
      v_end_date := ADD_MONTHS(p_start_date, 12 * (p_year - p_per_year)) - 1;
      FOR i IN /*(SELECT ROWNUM schedule_num,
                                                                                                                                                                                                                     plan_date,
                                                                                                                                                                                                                     NVL (lead (plan_date - 1) OVER (ORDER BY plan_date), v_end_date)
                                                                                                                                                                                                                FROM (SELECT plan_date
                                                                                                                                                                                                                        FROM v_policy_payment_schedule
                                                                                                                                                                                                                       WHERE 1=1
                                                                                                                                                                                                                         AND policy_id = p_p_policy_id
                                                                                                                                                                                                                       ORDER BY grace_date)*/
      
       (SELECT rownum schedule_num
              ,plan_date
              ,nvl(lead(plan_date - 1) over(ORDER BY plan_date), v_end_date)
          FROM (SELECT plan_date
                  FROM ven_ac_payment epg
                      ,doc_doc        dd
                      ,p_policy       pp1
                      ,p_policy       pp
                      ,doc_templ      dt
                 WHERE 1 = 1
                   AND epg.payment_id = dd.child_id
                   AND dd.parent_id = pp1.policy_id
                   AND pp1.pol_header_id = pp.pol_header_id
                   AND pp.policy_id = p_p_policy_id
                   AND epg.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND doc.get_doc_status_brief(epg.payment_id) NOT IN ('ANNULATED')
                   AND epg.plan_date >=
                       (SELECT pp.start_date FROM p_policy pp2 WHERE pp2.policy_id = p_p_policy_id)
                 ORDER BY grace_date))
      LOOP
        PIPE ROW(i);
      END LOOP;
    
    ELSE
    
      v_end_date := ADD_MONTHS(p_start_date, 12 * (p_year)) - 1;
      FOR i IN (SELECT rownum schedule_num
                      ,due_date
                      ,nvl(lead(due_date - 1) over(ORDER BY due_date), v_end_date)
                  FROM (SELECT due_date
                          FROM v_policy_payment_schedule
                         WHERE 1 = 1
                           AND policy_id = p_p_policy_id
                         ORDER BY grace_date))
      LOOP
        PIPE ROW(i);
      END LOOP;
    END IF;
    RETURN;
  END;

  /**
  *  @Author Marchuk A.
  * Функция расчета показателя Ft
  * @param p_n срок действия покрытия
  * @param p_t количество лет с момента начала действия договора
  * @param p_is_one_payment Признак единовременной оплаты
  */

  FUNCTION ft
  (
    p_policy_id      IN NUMBER
   ,p_p_cover_id     IN NUMBER
   ,p_n              IN NUMBER
   ,p_t              IN NUMBER
   ,p_is_one_payment IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT             NUMBER;
    l_method           NUMBER;
    l_n                NUMBER;
    l_t                NUMBER;
    l_pause_start_date DATE;
    l_pause_end_date   DATE;
    --
    l_fh_year   NUMBER;
    l_lob_brief VARCHAR2(100);
    p_prod_flag NUMBER;
    v_is_invest NUMBER;
  
    FUNCTION document_a RETURN NUMBER IS
      RESULT NUMBER;
    BEGIN
      log(p_policy_id, 'DOCUMENT_A');
      RESULT := greatest(1 - 0.02 * (l_n - p_t), 0.8);
      RETURN RESULT;
    END;
  
    FUNCTION document_b RETURN NUMBER IS
      RESULT NUMBER;
    
      l_t_1 NUMBER;
      l_t_2 NUMBER;
      l_t_3 NUMBER;
    BEGIN
    
      log(p_policy_id, 'DOCUMENT_B');
    
      IF l_lob_brief IN ('INVEST2', 'INVEST')
      THEN
        l_t_1 := 0;
        l_t_2 := 0;
        l_t_3 := 1;
      ELSE
        l_t_1 := 0;
        l_t_2 := 2;
        l_t_3 := 3;
      END IF;
    
      log(p_policy_id
         ,'DOCUMENT_B l_lob_brief ' || l_lob_brief || ' l_t_1 ' || l_t_1 || ' l_t_2 ' || l_t_2 ||
          ' l_t_3 ' || l_t_3);
    
      IF nvl(p_is_one_payment, 0) = 1
      THEN
        /* Единовременный взнос. формула ТЗ номер 4 */
      
        /* Внимание ! В формуле пришлось написать (p_t + 1), т.к. не совсем понятно,к ак в единовременном
        считается годовщина. Однако, такая подстановка выдает результат, совпадающий с тестовым
        
        */
      
        RESULT := 0.8 + 0.18 * (l_t - 1) / (l_n - 1);
      
      ELSE
      
        IF p_n >= 10
        THEN
          /* Периодический взнос. Срок страхования от 10 лет */
        
          log(p_policy_id
             ,'DOCUMENT_B Периодический взнос. Срок страхования от 10 лет t=' || l_t || ' n ' || l_n);
          /*
            Данная часть кода расчитывает Ft в зависимости от годовщины и срока действия.
            При включении услуги фин каникулы значение годовщины и срока корректируется
          */
        
          IF l_t BETWEEN l_t_1 AND l_t_2
          THEN
            RESULT := 0;
          ELSIF l_t BETWEEN l_t_3 AND trunc(0.7 * l_n)
          THEN
            RESULT := 0.25 + (l_t - l_t_3) * 0.6 / (trunc(0.7 * l_n) - l_t_3);
          ELSE
            RESULT := 0.85 + 0.13 * (l_t - 0.7 * l_n) / (0.3 * l_n);
          END IF;
        ELSE
          log(p_policy_id
             ,'DOCUMENT_B периодический взнос. Срок страхования менее 10 лет t=' || l_t || ' n ' || l_n);
          /* Периодический взнос. Срок страхования менее 10 лет */
          --result := 0.25 + 0.75 * (p_t - 1)/9;
          -- Байтин А.
          -- Вернул Инвестор. заявка (127125)
          BEGIN
            SELECT decode(upper(prod.brief)
                         ,'INVESTORPLUS'
                         ,1
                         ,'INVESTOR'
                         ,1
                         ,'INVESTORALFA'
                         ,1
                         ,'PRIORITY_INVEST(LUMP)'
                         ,1
                         ,'PRIORITY_INVEST(REGULAR)'
                         ,1
                         ,0)
              INTO p_prod_flag
              FROM p_policy     pp
                  ,p_pol_header ph
                  ,t_product    prod
             WHERE pp.policy_id = p_policy_id
               AND pp.pol_header_id = ph.policy_header_id
               AND ph.product_id = prod.product_id;
          EXCEPTION
            WHEN no_data_found THEN
              p_prod_flag := 0;
          END;
        
          IF p_prod_flag = 1
          THEN
            RESULT := 1;
          ELSE
          
            IF l_t BETWEEN l_t_1 AND l_t_2
            THEN
              RESULT := 0;
            ELSE
              RESULT := 0.25 + 0.75 * (l_t - l_t_3) / 9;
            END IF;
          
          END IF;
        
        END IF;
      END IF;
    
      RETURN RESULT;
    END;
  
  BEGIN
    log(p_policy_id, 'FT BRIEF ' || g_brief || ' p_t ' || p_t);
  
    /*для Инвест используем методику 2*/
    SELECT COUNT(*)
      INTO v_is_invest
      FROM ins.p_cover            pc
          ,ins.t_prod_line_option opt
     WHERE pc.t_prod_line_option_id = opt.id
       AND opt.description IN ('ИНВЕСТ', 'ИНВЕСТ2', 'ИНВЕСТ2_1')
       AND pc.p_cover_id = p_p_cover_id;
    /**/
    IF g_brief = 'PEPR_INVEST_RESERVE'
       OR v_is_invest > 0
    THEN
      l_method := 2; /*Новая методика Цильмера 4%*/
    ELSE
      l_method := pkg_pol_cash_surr_method.metod_f_t(p_policy_id);
    END IF;
  
    log(p_policy_id, 'FT METHOD ' || l_method || ' ');
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    SELECT lob_brief INTO l_lob_brief FROM v_asset_cover_life WHERE p_cover_id = p_p_cover_id;
  
    /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
    В результате, в момент действия этой услуги расчет выкупных сумм не производится, при дальшейших вычислениях принимается во внимание
    период, в течение которого услуча не действовала. В результате, необходимо к периоду покрытия добавлять период простоя, чтобы получить период действия
    вновь подключенного покрытия. При этом для вычисления текущей годовщины указанный период, наоборот, отнимается от "настоящей" годовщины
    
    */
    IF l_pause_start_date IS NOT NULL
       AND l_pause_end_date IS NOT NULL
    THEN
      l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
      log(p_policy_id
         ,'FT METHOD l_fh_year ' || l_fh_year || ' p_n ' || p_n || ' pause_start_date ' ||
          to_char(l_pause_start_date, 'dd.mm.yyyy') || ' pause_end_date ' ||
          to_char(l_pause_end_date, 'dd.mm.yyyy'));
    
      /*l_n := p_n + floor(l_fh_year);*/
      l_n := p_n;
      /*l_t := p_t - ceil(l_fh_year);*/
      l_t := p_t;
    ELSE
      l_n := p_n;
      l_t := p_t;
    END IF;
  
    IF l_method IN (0, 1)
    THEN
    
      RESULT := document_a;
    
    ELSIF l_method = 2
    THEN
    
      RESULT := document_b;
    
    END IF;
  
    log(p_policy_id, 'FT n ' || l_n || ' t ' || p_t || ' result ' || RESULT);
  
    RETURN RESULT;
  END;

  /**
  *  @Author Marchuk A.
  * Функция расчета показателя Ft для SF_AVCR
  * @param p_n срок действия покрытия
  * @param p_t количество лет с момента начала действия договора
  * @param p_is_one_payment Признак единовременной оплаты
  */

  FUNCTION ft_avcr
  (
    p_policy_id      IN NUMBER
   ,p_p_cover_id     IN NUMBER
   ,p_n              IN NUMBER
   ,p_t              IN NUMBER
   ,p_is_one_payment IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT             NUMBER;
    l_method           NUMBER;
    l_n                NUMBER;
    l_t                NUMBER;
    l_pause_start_date DATE;
    l_pause_end_date   DATE;
    --
    l_fh_year   NUMBER;
    l_lob_brief VARCHAR2(100);
    v_m         NUMBER;
  
    FUNCTION document_a RETURN NUMBER IS
      RESULT NUMBER;
    BEGIN
      log(p_policy_id, 'DOCUMENT_A');
      RESULT := greatest(1 - 0.02 * (l_n - p_t), 0.8);
      RETURN RESULT;
    END;
  
    FUNCTION document_b RETURN NUMBER IS
      RESULT NUMBER;
    
      l_t_1 NUMBER;
      l_t_2 NUMBER;
      l_t_3 NUMBER;
    BEGIN
      SELECT p.fee_payment_term INTO v_m FROM ins.p_policy p WHERE p.policy_id = p_policy_id;
    
      log(p_policy_id, 'DOCUMENT_B');
    
      l_t_1 := 0;
      l_t_2 := 2;
      l_t_3 := 3;
    
      log(p_policy_id
         ,'DOCUMENT_B l_lob_brief ' || l_lob_brief || ' l_t_1 ' || l_t_1 || ' l_t_2 ' || l_t_2 ||
          ' l_t_3 ' || l_t_3);
    
      log(p_policy_id
         ,'DOCUMENT_B Периодический взнос. Срок страхования от 10 лет t=' || l_t || ' n ' || l_n);
      /*
        Данная часть кода расчитывает Ft в зависимости от годовщины и срока действия.
        При включении услуги фин каникулы значение годовщины и срока корректируется
      */
    
      IF l_t BETWEEN l_t_1 AND l_t_2
      THEN
        RESULT := 0;
      ELSIF l_t BETWEEN l_t_3 AND trunc(0.7 * (v_m + 9))
      THEN
        RESULT := 0.25 + (l_t - l_t_3) * 0.6 / (trunc(0.7 * (v_m + 9)) - l_t_3);
      ELSE
        RESULT := 0.85 + 0.13 * (l_t - 0.7 * (v_m + 9)) / (0.3 * (v_m + 9));
      END IF;
    
      RETURN RESULT;
    END;
  
  BEGIN
  
    log(p_policy_id, 'FT BRIEF ' || g_brief || ' p_t ' || p_t);
  
    l_method := pkg_pol_cash_surr_method.metod_f_t(p_policy_id);
  
    log(p_policy_id, 'FT METHOD ' || l_method || ' ');
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    SELECT lob_brief INTO l_lob_brief FROM v_asset_cover_life WHERE p_cover_id = p_p_cover_id;
  
    /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
    В результате, в момент действия этой услуги расчет выкупных сумм не производится, при дальшейших вычислениях принимается во внимание
    период, в течение которого услуча не действовала. В результате, необходимо к периоду покрытия добавлять период простоя, чтобы получить период действия
    вновь подключенного покрытия. При этом для вычисления текущей годовщины указанный период, наоборот, отнимается от "настоящей" годовщины
    
    */
    IF l_pause_start_date IS NOT NULL
       AND l_pause_end_date IS NOT NULL
    THEN
      l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
      log(p_policy_id
         ,'FT METHOD l_fh_year ' || l_fh_year || ' p_n ' || p_n || ' pause_start_date ' ||
          to_char(l_pause_start_date, 'dd.mm.yyyy') || ' pause_end_date ' ||
          to_char(l_pause_end_date, 'dd.mm.yyyy'));
    
      l_n := p_n + FLOOR(l_fh_year);
      l_t := p_t - CEIL(l_fh_year);
    ELSE
      l_n := p_n;
      l_t := p_t;
    END IF;
  
    IF l_method IN (0, 1)
    THEN
    
      RESULT := document_a;
    
    ELSIF l_method = 2
    THEN
    
      RESULT := document_b;
    
    END IF;
  
    log(p_policy_id, 'FT n ' || l_n || ' t ' || p_t || ' result ' || RESULT);
  
    RETURN RESULT;
  END;

  /**
  *  @Author Marchuk A.
  * Функция вычисления очередной годовщины через n лет
  * @param p_date Дата, от которой считаем
  * @param p_t Номер годовщины
  */

  FUNCTION get_year_date
  (
    p_date                IN DATE
   ,p_t                   IN NUMBER
   ,par_header_start_date DATE DEFAULT g_header_start_date
  ) RETURN DATE IS
    RESULT DATE;
    l_year NUMBER;
  BEGIN
    /*
      Капля П.
      Согласно договоренностям со всеми отделами, согласованной 
      Титовым О., Шагиевой К., Палвановой К., Кипричем Д.
      Утверждающий документ должен был появиться еще в марте 2014, но на 01.08.2014 такового еще не было.
      Тем не менее ожидается, что документ вскоре будет утвержден.
    */
    RETURN ADD_MONTHS(p_date, p_t * 12);
    /*если Договор заключен 29 февраля, то годовщины будут периодически смещатьяс на 28 число. При заключении договора 28 числа годовщины всегда
    должны быть 28 числа*/
    /*
    IF to_char(p_date, 'dd.mm') = '29.02'
    THEN
      RESULT := ADD_MONTHS(par_header_start_date, 12 * p_t);
    ELSE
      SELECT extract(YEAR FROM p_date) INTO l_year FROM dual;
      l_year := l_year + p_t;
      IF to_char(par_header_start_date, 'dd.mm') = '29.02'
      THEN
        IF MOD(extract(YEAR FROM p_date), 4) = 0
        THEN
          RESULT := to_date(to_char(par_header_start_date, 'dd.mm.') || to_char(l_year), 'dd.mm.yyyy');
        ELSE
          RESULT := ADD_MONTHS(par_header_start_date, 12 * p_t);
        END IF;
      ELSE
        ----Исправлено, т.к. в резервах расчет идет так
        RESULT := ADD_MONTHS(par_header_start_date, 12 * p_t);
        --result := to_date (to_char (g_header_start_date, 'dd.mm.')||to_char(l_year), 'dd.mm.yyyy');
      END IF;
    
    END IF;
    
    RETURN RESULT;
    */
  END;

  -- Байтин А.
  -- Вернул Инвестор. заявка (127125)
  FUNCTION investor_cash_surrender
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      --l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      log(p_p_policy_id, 'Calc_EVERY_YEAR POLICY_HEADER_ID ' || g_policy_header_id);
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR T_LOB_LINE_ID ' || p_t_lob_line_id || ' ASSET_HEADER_ID ' ||
          p_p_asset_header_id || ' RESERVE_DATE ' || l_reserve_date);
    
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      IF p_t = 0
      THEN
        l_ft := 0.25;
      ELSIF p_t = 1
      THEN
        l_ft := 0.5;
      ELSE
        l_ft := 0.75;
      END IF;
    
      RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
    IF nvl(l_fh_year, 0) > 0
    THEN
      p_p_period_year := r_policy.period_year_fh - ROUND(l_fh_year, 0);
    END IF;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      log(p_p_policy_id
         ,'INV_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'EVERY_YEAR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
        calc_every_year(g_header_start_date, r_policy.period_year, v_t, r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
      IF v_t - l_fh_year < 2
      THEN
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv /** result(result.count).ins_amount*/
       ;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  -- VESELEK
  -- 05.10.2012
  FUNCTION investor_plus
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      --l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      log(p_p_policy_id, 'Calc_EVERY_YEAR POLICY_HEADER_ID ' || g_policy_header_id);
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR T_LOB_LINE_ID ' || p_t_lob_line_id || ' ASSET_HEADER_ID ' ||
          p_p_asset_header_id || ' RESERVE_DATE ' || l_reserve_date);
    
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      IF p_n = 3
      THEN
        IF p_t = 0
        THEN
          l_ft := 0.15;
        ELSIF p_t = 1
        THEN
          l_ft := 0.45;
        ELSE
          l_ft := 0.70;
        END IF;
      ELSE
        IF p_t = 0
        THEN
          l_ft := 0.21;
        ELSIF p_t = 1
        THEN
          l_ft := 0.37;
        ELSIF p_t = 2
        THEN
          l_ft := 0.54;
        ELSIF p_t = 3
        THEN
          l_ft := 0.70;
        ELSE
          l_ft := 0.86;
        END IF;
      END IF;
    
      RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      log(p_p_policy_id
         ,'INV_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'EVERY_YEAR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
        calc_every_year(g_header_start_date, r_policy.period_year, v_t, r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv /** result(result.count).ins_amount*/
       ;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  /*
    Доброхотова И.
    Выкупные суммы по продукту Наследие
  */
  FUNCTION nasledie_cash
  (
    par_policy_id       IN NUMBER
   ,par_contact_id      IN NUMBER
   ,par_asset_header_id IN NUMBER
   ,par_lob_line_id     IN NUMBER
   ,par_cover_id        IN NUMBER
  ) RETURN tbl_cash_surrender IS
    vr_policy typ_policy_info;
    RESULT    tbl_cash_surrender;
  
    PROCEDURE add_cash_surr_detail
    (
      par_cash_surr_d OUT NOCOPY r_cash_surrender
     ,par_policy_info typ_policy_info
     ,par_schedule    typ_schedule
    ) IS
    BEGIN
      par_cash_surr_d.policy_header_id      := par_policy_info.policy_header_id;
      par_cash_surr_d.policy_id             := par_policy_info.poilcy_id;
      par_cash_surr_d.t_lob_line_id         := par_lob_line_id;
      par_cash_surr_d.contact_id            := par_contact_id;
      par_cash_surr_d.insurance_year_date   := to_date(NULL);
      par_cash_surr_d.start_cash_surr_date  := par_schedule.start_schedule_date;
      par_cash_surr_d.end_cash_surr_date    := par_schedule.end_schedule_date;
      par_cash_surr_d.insurance_year_number := par_schedule.insurance_year_number;
    END add_cash_surr_detail;
  
    -- Расчет
    PROCEDURE calc_one
    (
      par_cash_surr_d IN OUT NOCOPY r_cash_surrender
     ,par_policy_info typ_policy_info
     ,par_schedule    typ_schedule
    ) IS
      v_year_date     DATE;
      v_year_end_date DATE;
      l_p             NUMBER;
      l_vb            NUMBER;
      l_d             NUMBER;
    BEGIN
      v_year_date := get_year_date(par_policy_info.header_start_date
                                  ,par_schedule.insurance_year_number);
    
      par_cash_surr_d.insurance_year_date := v_year_date;
    
      v_year_end_date := ADD_MONTHS(par_policy_info.header_start_date
                                   ,12 * (par_schedule.insurance_year_number + 1)) - 1;
    
      l_vb := pkg_reserve_r_life.get_vb(par_cash_surr_d.policy_header_id
                                       ,par_cash_surr_d.policy_id
                                       ,par_cash_surr_d.t_lob_line_id
                                       ,par_asset_header_id
                                       ,v_year_end_date);
      CASE par_policy_info.number_of_payments
        WHEN 1 THEN
          l_p := 0;
        ELSE
          l_p := pkg_reserve_r_life.get_pp(par_cash_surr_d.policy_header_id
                                          ,par_cash_surr_d.policy_id
                                          ,par_cash_surr_d.t_lob_line_id
                                          ,par_asset_header_id
                                          ,v_year_end_date);
      END CASE;
    
      --      l_d := l_p * ((par_policy_info.number_of_payments - 1) / par_policy_info.number_of_payments -
      --             MONTHS_BETWEEN(v_year_end_date, par_schedule.start_schedule_date) / 12);
      IF vr_policy.payment_terms_brief = 'HALF_YEAR'
      THEN
        IF par_schedule.start_schedule_date = v_year_date
        THEN
          l_d := l_p * (1 / 2);
        ELSE
          l_d := 0;
        END IF;
      ELSIF vr_policy.payment_terms_brief = 'EVERY_QUARTER'
      THEN
        IF par_schedule.start_schedule_date = v_year_date
        THEN
          l_d := l_p * 3 / 4;
        ELSIF par_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 3)
        THEN
          l_d := l_p * 1 / 2;
        ELSIF par_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 6)
        THEN
          l_d := l_p * 1 / 4;
        ELSIF par_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 9)
        THEN
          l_d := 0;
        END IF;
      ELSE
        l_d := 0;
      END IF;
    
      par_cash_surr_d.reserve_value := l_vb - l_d;
    
      par_cash_surr_d.ins_amount := pkg_reserve_r_life.get_ss(par_cash_surr_d.policy_header_id
                                                             ,par_cash_surr_d.policy_id
                                                             ,par_cash_surr_d.t_lob_line_id
                                                             ,par_asset_header_id
                                                             ,v_year_end_date);
      -- доля резерва
      par_cash_surr_d.ft := nvl(pkg_tariff_calc.calc_coeff_val('YEAR_CASH_SURR'
                                                              ,t_number_type(par_policy_info.product_id
                                                                            ,par_policy_info.period_year
                                                                            ,par_cash_surr_d.insurance_year_number + 1))
                               ,0);
      -- сумма резерва
      par_cash_surr_d.cv             := ROUND(par_cash_surr_d.reserve_value * par_cash_surr_d.ft, 10);
      par_cash_surr_d.payment_number := par_schedule.schedule_num;
    
    END calc_one;
  
  BEGIN
    vr_policy := get_policy_info(par_policy_id, par_cover_id);
  
    FOR r_schedule IN c_schedule(vr_policy)
    LOOP
      DECLARE
        vr_cash_surr_d r_cash_surrender;
      BEGIN
        add_cash_surr_detail(vr_cash_surr_d, vr_policy, r_schedule);
      
        CASE
          WHEN vr_policy.payment_terms_brief IN ('EVERY_YEAR', 'EVERY_QUARTER', 'HALF_YEAR') THEN
            calc_one(vr_cash_surr_d, vr_policy, r_schedule);
          ELSE
            ex.raise_custom('Периодичность оплаты не поддерживается');
        END CASE;
      
        IF vr_cash_surr_d.cv < 0
        THEN
          vr_cash_surr_d.cv := 0;
        END IF;
      
        vr_cash_surr_d.value         := vr_cash_surr_d.cv * vr_cash_surr_d.ins_amount;
        vr_cash_surr_d.reserve_value := vr_cash_surr_d.reserve_value * vr_cash_surr_d.ins_amount;
      
        IF vr_cash_surr_d.cv IS NULL
           OR vr_cash_surr_d.value IS NULL
        THEN
          EXIT;
        END IF;
      
        RESULT(r_schedule.rn) := vr_cash_surr_d;
      END;
    END LOOP;
  
    RETURN RESULT;
  
  END nasledie_cash;

  /*
    Капля П.
    01.08.2014
    Рефакторинг процедуры расчета ВС по единовременным инвесторам
    Исправление алгоритма взятия резерва при расчета ВС
  */
  FUNCTION investor_lump_cash2
  (
    par_policy_id       IN NUMBER
   ,par_contact_id      IN NUMBER
   ,par_asset_header_id IN NUMBER
   ,par_lob_line_id     IN NUMBER
   ,par_cover_id        IN NUMBER
  ) RETURN tbl_cash_surrender IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'INVESTOR_LUMP_CASH2';
    vr_policy         typ_policy_info;
    v_product_line_id NUMBER;
    RESULT            tbl_cash_surrender;
  
    /*
      Необходимо будет отказаться от использования типа tbl_cash_surrender
      он содержит в себе тучу лишних полей, относящихся к policy_cash_surr
    */
    PROCEDURE add_cash_surr_detail
    (
      par_cash_surr_d OUT NOCOPY r_cash_surrender
     ,par_policy_info typ_policy_info
     ,par_schedule    typ_schedule
    ) IS
    BEGIN
      par_cash_surr_d.policy_header_id      := par_policy_info.policy_header_id;
      par_cash_surr_d.policy_id             := par_policy_info.poilcy_id;
      par_cash_surr_d.t_lob_line_id         := par_lob_line_id;
      par_cash_surr_d.contact_id            := par_contact_id;
      par_cash_surr_d.product_line_id       := v_product_line_id;
      par_cash_surr_d.insurance_year_date   := to_date(NULL);
      par_cash_surr_d.start_cash_surr_date  := par_schedule.start_schedule_date;
      par_cash_surr_d.end_cash_surr_date    := par_schedule.end_schedule_date;
      par_cash_surr_d.insurance_year_number := par_schedule.insurance_year_number;
    END add_cash_surr_detail;
  
    /*
      Капля П.
      Расчет при единовременной форме оплаты
    */
    PROCEDURE calc_one
    (
      par_cash_surr_d IN OUT NOCOPY r_cash_surrender
     ,par_policy_info typ_policy_info
     ,par_schedule    typ_schedule
    ) IS
      v_year_date       DATE;
      v_year_start_date DATE;
      v_year_end_date   DATE;
    BEGIN
      v_year_date := get_year_date(par_policy_info.header_start_date
                                  ,par_schedule.insurance_year_number);
    
      par_cash_surr_d.insurance_year_date := v_year_date;
      /*
      v_year_start_date                   := ADD_MONTHS(par_policy_info.header_start_date
                                                       ,12 * par_schedule.insurance_year_number) - 1;
      */
      v_year_end_date := ADD_MONTHS(par_policy_info.header_start_date
                                   ,12 * (par_schedule.insurance_year_number + 1)) - 1;
      --Резерв берется на начало года
      par_cash_surr_d.reserve_value := pkg_reserve_r_life.get_vs(par_cash_surr_d.policy_header_id
                                                                ,par_cash_surr_d.policy_id
                                                                ,par_cash_surr_d.t_lob_line_id
                                                                ,par_asset_header_id
                                                                ,v_year_end_date);
    
      par_cash_surr_d.ins_amount := pkg_reserve_r_life.get_ss(par_cash_surr_d.policy_header_id
                                                             ,par_cash_surr_d.policy_id
                                                             ,par_cash_surr_d.t_lob_line_id
                                                             ,par_asset_header_id
                                                             ,v_year_end_date);
    
      par_cash_surr_d.ft             := pkg_tariff_calc.calc_coeff_val('INVESTOR_LUMP_PARTNER_FT'
                                                                      ,t_number_type(par_cash_surr_d.product_line_id
                                                                                    ,par_cash_surr_d.insurance_year_number));
      par_cash_surr_d.cv             := ROUND(par_cash_surr_d.reserve_value * par_cash_surr_d.ft, 6);
      par_cash_surr_d.payment_number := par_schedule.schedule_num;
    
    END calc_one;
  
  BEGIN
    pkg_trace.add_variable('par_policy_id', par_policy_id);
    pkg_trace.add_variable('par_contact_id', par_contact_id);
    pkg_trace.add_variable('par_asset_header_id', par_asset_header_id);
    pkg_trace.add_variable('par_lob_line_id', par_lob_line_id);
    pkg_trace.add_variable('par_cover_id', par_cover_id);
    pkg_trace.trace_function_start(gc_pkg_name, c_proc_name);
  
    vr_policy := get_policy_info(par_policy_id, par_cover_id);
  
    v_product_line_id := pkg_tariff_calc.get_attribut(p_ent_id  => dml_p_cover.get_entity_id
                                                     ,p_obj_id  => par_cover_id
                                                     ,p_attr_id => dml_t_attribut.get_id_by_brief('PRODUCT_LINE'));
  
    FOR r_schedule IN c_schedule(vr_policy)
    LOOP
      DECLARE
        vr_cash_surr_d r_cash_surrender;
      BEGIN
        add_cash_surr_detail(vr_cash_surr_d, vr_policy, r_schedule);
      
        CASE vr_policy.payment_terms_brief
          WHEN 'Единовременно' THEN
            calc_one(vr_cash_surr_d, vr_policy, r_schedule);
          ELSE
            ex.raise_custom('Периодичность оплаты не поддерживается');
        END CASE;
      
        IF vr_cash_surr_d.cv < 0
        THEN
          vr_cash_surr_d.cv := 0;
        END IF;
      
        vr_cash_surr_d.value         := vr_cash_surr_d.cv * vr_cash_surr_d.ins_amount;
        vr_cash_surr_d.reserve_value := vr_cash_surr_d.reserve_value * vr_cash_surr_d.ins_amount;
      
        IF vr_cash_surr_d.cv IS NULL
           OR vr_cash_surr_d.value IS NULL
        THEN
          EXIT;
        END IF;
      
        RESULT(r_schedule.rn) := vr_cash_surr_d;
      END;
    END LOOP;
  
    pkg_trace.trace_function_end(gc_pkg_name, c_proc_name);
  
    RETURN RESULT;
  
  END investor_lump_cash2;

  FUNCTION investor_lump_cash
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT               tbl_cash_surrender;
    v_brief              VARCHAR2(200);
    v_start_date         DATE;
    v_header_start_date  DATE;
    v_period_year        NUMBER;
    v_year_date          DATE;
    v_policy_header_id   NUMBER;
    v_t                  NUMBER;
    l_pause_start_date   DATE;
    l_pause_end_date     DATE;
    l_fh_year            NUMBER;
    v_product_brief      VARCHAR2(200);
    p_p_period_year      NUMBER;
    v_agent_contract_num document.num%TYPE;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
    END;
  
    PROCEDURE calc_one
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date      DATE;
      l_id             NUMBER;
      l_reserve_date_1 DATE;
      l_reserve_date_2 DATE;
      l_ft             NUMBER;
    
      l_tvs_1 NUMBER;
      l_tvs_2 NUMBER;
      l_s     NUMBER;
    
      l_k_1      NUMBER;
      l_k_2      NUMBER;
      l_tvs_comm NUMBER := 0;
      l_vb       NUMBER;
    BEGIN
      log(p_p_policy_id, 'CALC_ONE ');
    
      log(p_p_policy_id
         ,'CALC_ONE n ' || p_n || ' t ' || p_t || 'START_DATE ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy'));
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date_2 := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      --Чирков изменил 309120: 1140308982 Пшеницын Денис Николаевич при переводе
      -- l_reserve_date_1 := ADD_MONTHS(l_reserve_date_2, -12);
      l_reserve_date_1 := ADD_MONTHS(g_header_start_date, 12 * p_t) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);
    
      log(p_p_policy_id, 'CALC_ONE POLICY_HEADER_ID ' || RESULT(l_id).policy_header_id);
      log(p_p_policy_id, 'CALC_ONE POLICY_ID ' || RESULT(l_id).policy_id);
      log(p_p_policy_id, 'CALC_ONE T_LOB_LINE_ID ' || RESULT(l_id).t_lob_line_id);
      log(p_p_policy_id, 'CALC_ONE P_ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      log(p_p_policy_id, 'CALC_ONE YEAR_DATE ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_1 ' || to_char(l_reserve_date_1, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_2 ' || to_char(l_reserve_date_2, 'dd.mm.yyyy'));
    
      l_tvs_1 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                          ,RESULT             (l_id).policy_id
                                          ,RESULT             (l_id).t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,l_reserve_date_1);
    
      l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                          ,RESULT             (l_id).policy_id
                                          ,RESULT             (l_id).t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,l_reserve_date_2);
    
      l_s := pkg_reserve_r_life.get_ss(RESULT             (l_id).policy_header_id
                                      ,RESULT             (l_id).policy_id
                                      ,RESULT             (l_id).t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date_2 /*l_year_date*/);
    
      log(p_p_policy_id, 'CALC_ONE tVS_1 ' || l_tvs_1 || ' tVS_2 ' || l_tvs_2);
    
      l_k_1 := (p_end_schedule_date - l_year_date + 1) / (l_reserve_date_2 - l_year_date + 1);
    
      l_k_1 := ROUND(l_k_1, 6);
      l_k_2 := 1 - l_k_1;
    
      log(p_p_policy_id, 'CALC_ONE l_k_1 ' || l_k_1 || ' l_k_2 ' || l_k_2);
    
      l_tvs_comm := (l_k_1 * l_tvs_2) + (l_k_2 * l_tvs_1);
      /*l_vB := pkg_reserve_r_life.get_vb(g_policy_header_id
      ,p_p_policy_id
      ,p_t_lob_line_id
      ,p_p_asset_header_id
      ,l_reserve_date_2);*/
      /*IF p_n = 3
      THEN
        IF p_t = 0
        THEN
          l_tVs_comm := l_vB * 0.80;
        ELSIF p_t = 1
        THEN
          l_tVs_comm := l_vB * 0.85;
        ELSE
          l_tVs_comm := l_vB * 0.90;
        END IF;
      ELSE
        IF p_t = 0
        THEN
          l_tVs_comm := l_vB * 0.70;
        ELSIF p_t = 1
        THEN
          l_tVs_comm := l_vB * 0.75;
        ELSIF p_t = 2
        THEN
          l_tVs_comm := l_vB * 0.80;
        ELSIF p_t = 3
        THEN
          l_tVs_comm := l_vB * 0.85;
        ELSE
          l_tVs_comm := l_vB * 0.90;
        END IF;
      END IF;*/
      IF p_n = 3
      THEN
        IF v_agent_contract_num = '44730'
        THEN
          DECLARE
            v_plo_brief t_prod_line_option.brief%TYPE;
          BEGIN
            SELECT plo.brief
              INTO v_plo_brief
              FROM p_cover            pc
                  ,t_prod_line_option plo
             WHERE pc.p_cover_id = p_p_cover_id
               AND pc.t_prod_line_option_id = plo.id;
          
            IF v_plo_brief IN ('PEPR_B', 'PEPR_A')
            THEN
              l_ft := 0.5;
            ELSE
              l_ft := 0.25;
            END IF;
          
          END;
        
        ELSE
          IF p_t = 0
          THEN
            l_ft := 0.80;
          ELSIF p_t = 1
          THEN
            l_ft := 0.85;
          ELSE
            l_ft := 0.90;
          END IF;
        END IF;
      ELSE
        IF p_t = 0
        THEN
          l_ft := 0.70;
        ELSIF p_t = 1
        THEN
          l_ft := 0.75;
        ELSIF p_t = 2
        THEN
          l_ft := 0.80;
        ELSIF p_t = 3
        THEN
          l_ft := 0.85;
        ELSE
          l_ft := 0.90;
        END IF;
      END IF;
    
      RESULT(l_id).cv := l_tvs_comm * l_ft;
      RESULT(l_id).cv := ROUND(RESULT(l_id).cv, 6);
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id, 'CALC_ONE PAYMENT_NUM ' || p_payment_num || ' tCV ' || RESULT(l_id).cv);
    
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      log(p_p_policy_id, 'Calc_EVERY_YEAR POLICY_HEADER_ID ' || g_policy_header_id);
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR T_LOB_LINE_ID ' || p_t_lob_line_id || ' ASSET_HEADER_ID ' ||
          p_p_asset_header_id || ' RESERVE_DATE ' || l_reserve_date);
    
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      IF p_t = 0
      THEN
        l_vb := l_vb * 0.25;
      ELSIF p_t = 1
      THEN
        l_vb := l_vb * 0.5;
      ELSE
        l_vb := l_vb * 0.75;
      END IF;
    
      RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
  
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    BEGIN
      SELECT num
        INTO v_agent_contract_num
        FROM document
       WHERE document_id = pkg_agn_control.get_current_policy_agent(r_policy.policy_header_id);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
    IF nvl(l_fh_year, 0) > 0
    THEN
      p_p_period_year := r_policy.period_year_fh - ROUND(l_fh_year, 0);
    END IF;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      log(p_p_policy_id
         ,'INV_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'EVERY_YEAR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
        calc_every_year(g_header_start_date, r_policy.period_year, v_t, r_schedule.schedule_num);
      ELSIF v_brief = 'Единовременно'
      THEN
        /*Расчет выкупной суммы при единовременном взносе*/
        calc_one(r_policy.period_year
                ,v_t
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
      IF v_t - l_fh_year < 2
      THEN
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv * RESULT(result.count).ins_amount;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  /**
  *  @Author Чирков В. Ю.
  * Функция расчета выкупных сумм по продукту <Приоритет Инвест (единовременный) Сбербанк>
  */
  FUNCTION invest_priority_lump_cash
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
    END;
  
    PROCEDURE calc_one
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date      DATE;
      l_id             NUMBER;
      l_reserve_date_1 DATE;
      l_reserve_date_2 DATE;
      l_ft             NUMBER;
    
      l_tvs_1 NUMBER;
      l_tvs_2 NUMBER;
      l_s     NUMBER;
    
      l_k_1      NUMBER;
      l_k_2      NUMBER;
      l_tvs_comm NUMBER := 0;
    BEGIN
      log(p_p_policy_id, 'CALC_ONE ');
    
      log(p_p_policy_id
         ,'CALC_ONE n ' || p_n || ' t ' || p_t || 'START_DATE ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy'));
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date_2 := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      --Чирков изменил 309120: 1140308982 Пшеницын Денис Николаевич при переводе
      -- l_reserve_date_1 := ADD_MONTHS(l_reserve_date_2, -12);
      l_reserve_date_1 := ADD_MONTHS(g_header_start_date, 12 * p_t) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);
    
      log(p_p_policy_id, 'CALC_ONE POLICY_HEADER_ID ' || RESULT(l_id).policy_header_id);
      log(p_p_policy_id, 'CALC_ONE POLICY_ID ' || RESULT(l_id).policy_id);
      log(p_p_policy_id, 'CALC_ONE T_LOB_LINE_ID ' || RESULT(l_id).t_lob_line_id);
      log(p_p_policy_id, 'CALC_ONE P_ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      log(p_p_policy_id, 'CALC_ONE YEAR_DATE ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_1 ' || to_char(l_reserve_date_1, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_2 ' || to_char(l_reserve_date_2, 'dd.mm.yyyy'));
    
      /*l_tVS_1 := pkg_reserve_r_life.get_VS(RESULT             (l_id).policy_header_id
      ,RESULT             (l_id).policy_id
      ,RESULT             (l_id).t_lob_line_id
      ,p_p_asset_header_id
      ,l_reserve_date_1);*/
    
      l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                          ,RESULT             (l_id).policy_id
                                          ,RESULT             (l_id).t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,l_reserve_date_2);
    
      l_s := pkg_reserve_r_life.get_s(RESULT             (l_id).policy_header_id
                                     ,RESULT             (l_id).policy_id
                                     ,RESULT             (l_id).t_lob_line_id
                                     ,p_p_asset_header_id
                                     ,l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      log(p_p_policy_id, 'CALC_ONE tVS_1 ' || l_tvs_1 || ' tVS_2 ' || l_tvs_2);
    
      /*l_k_1 := (p_end_schedule_date - l_year_date + 1) / (l_reserve_date_2 - l_year_date + 1);
      
      l_k_1 := ROUND(l_k_1, 6);
      l_k_2 := 1 - l_k_1;*/
    
      log(p_p_policy_id, 'CALC_ONE l_k_1 ' || l_k_1 || ' l_k_2 ' || l_k_2);
    
      /*l_tVs_comm := (l_k_1 * l_tVS_2) + (l_k_2 * l_tVS_1);*/
      l_tvs_comm := l_tvs_2;
      --Выкупные суммы = 15 % от резерва в течение всего времени действия полиса
      l_tvs_comm := l_tvs_comm * 0.15;
    
      RESULT(l_id).cv := l_tvs_comm;
      RESULT(l_id).cv := ROUND(RESULT(l_id).cv, 6);
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id, 'CALC_ONE PAYMENT_NUM ' || p_payment_num || ' tCV ' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
    IF nvl(l_fh_year, 0) > 0
    THEN
      p_p_period_year := r_policy.period_year_fh - ROUND(l_fh_year, 0);
    END IF;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      log(p_p_policy_id
         ,'INV_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'Единовременно'
      THEN
        /*Расчет выкупной суммы при единовременном взносе*/
        calc_one(r_policy.period_year
                ,v_t
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
      IF v_t - l_fh_year < 2
      THEN
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv * RESULT(result.count).ins_amount;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END invest_priority_lump_cash;

  /**
  *  @Author Чирков В. Ю.
  * Функция расчета выкупных сумм по продукту <Приоритет Инвест (регулярный) Сбербанк>
  */
  FUNCTION invest_priority_reg_cash
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      log(p_p_policy_id, 'Calc_EVERY_YEAR POLICY_HEADER_ID ' || g_policy_header_id);
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR T_LOB_LINE_ID ' || p_t_lob_line_id || ' ASSET_HEADER_ID ' ||
          p_p_asset_header_id || ' RESERVE_DATE ' || l_reserve_date);
    
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
    
      --Выкупные суммы = 25 % от резерва в течение всего времени действия полиса
      l_vb := l_vb * 0.25;
    
      RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
    IF nvl(l_fh_year, 0) > 0
    THEN
      p_p_period_year := r_policy.period_year_fh - ROUND(l_fh_year, 0);
    END IF;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      log(p_p_policy_id
         ,'INV_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'EVERY_YEAR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
        calc_every_year(g_header_start_date, r_policy.period_year, v_t, r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
      IF v_t - l_fh_year < 2
      THEN
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END invest_priority_reg_cash;

  /**
  *  @Author Marchuk A.
  * Функция расчета выкупных сумм по программе "Дожитие с возвратом взносов в случае смерти"
  * и "Смешанное страхование жизни"
  * @param p_policy_id ИД версии договора
  * @param p_contact_id ИД застрахованного (справочник контактов)
  * @param p_t_lob_line_id ИД страховой программы
  */
  FUNCTION end_cash_surrender
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
   ,p_ft_year_cash_surr BOOLEAN DEFAULT FALSE
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
            ,pt.number_of_payments
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    l_fh_exists         NUMBER := 0;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
    p_policy_start_date DATE;
  
    c_proc_name CONSTANT pkg_trace.t_object_name := 'END_CASH_SURRENDER';
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
            ,trunc(MONTHS_BETWEEN(start_schedule_date, r_policy.header_start_date) / 12) AS insurance_year_number
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
  
    FUNCTION ft_year_cash_surr
    (
      par_product_id      t_product.product_id%TYPE
     ,par_period_year     NUMBER
     ,par_ins_year_number NUMBER
    ) RETURN NUMBER IS
      RESULT NUMBER;
    BEGIN
      RESULT := nvl(pkg_tariff_calc.calc_coeff_val('YEAR_CASH_SURR'
                                                  ,t_number_type(par_product_id
                                                                ,par_period_year
                                                                ,par_ins_year_number + 1))
                   ,0);
      RETURN RESULT;
    END ft_year_cash_surr;
  
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
      RESULT(l_id).is_history := 1;
    
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date     IN DATE
     ,p_n                     NUMBER
     ,p_t                     NUMBER
     ,p_payment_num           IN NUMBER
     ,p_fh_year               NUMBER
     ,p_fh_exists             NUMBER
     ,p_period_pol            NUMBER
     ,p_insurance_year_number NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
      n              NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      /**/
      IF p_ft_year_cash_surr
      THEN
        l_ft := ft_year_cash_surr(pkg_products.get_product_id(v_product_brief)
                                 ,r_policy.period_year
                                 ,p_insurance_year_number);
      
      ELSE
        IF p_fh_exists = 1
           AND p_fh_year >= 0
        THEN
          /*Для Фин каникул*/
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_period_pol - p_fh_year, (p_t - p_fh_year) + 1);
        ELSE
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
        END IF;
      END IF;
      /**/
      /*l_Ft := Ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);*/
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      RESULT(l_id).reserve_value := l_vb;
    
      IF p_t = 0
      THEN
        RESULT(l_id).cv := 0;
      ELSIF p_t = 1
      THEN
        RESULT(l_id).cv := 0;
      ELSE
        RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
      END IF;
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
    PROCEDURE calc_every_year_sf_avcr
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_v            NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      v_payment_term NUMBER;
      v_sum_fee      NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      SELECT p.fee_payment_term INTO v_payment_term FROM p_policy p WHERE p.policy_id = p_p_policy_id;
    
      SELECT SUM(pc2.fee)
        INTO v_sum_fee
        FROM t_lob_line         ll2
            ,t_product_line     pl2
            ,t_prod_line_option plo2
            ,p_cover            pc2
            ,ven_status_hist    sh2
            ,as_asset           aa2
       WHERE 1 = 1
         AND aa2.p_policy_id = p_p_policy_id
         AND pc2.as_asset_id = aa2.as_asset_id
         AND sh2.status_hist_id = pc2.status_hist_id
         AND sh2.brief != 'DELETED'
         AND plo2.id = pc2.t_prod_line_option_id
         AND pl2.id = plo2.product_line_id
         AND ll2.t_lob_line_id = pl2.t_lob_line_id
         AND ll2.description <> 'Административные издержки';
    
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      IF p_ft_year_cash_surr
      THEN
        l_ft := ft_year_cash_surr(pkg_products.get_product_id(v_product_brief)
                                 ,r_policy.period_year
                                 ,r_schedule.insurance_year_number + 1);
      ELSE
        l_ft := ft_avcr(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      END IF;
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      log(p_p_policy_id, 'Calc_EVERY_YEAR POLICY_HEADER_ID ' || g_policy_header_id);
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR T_LOB_LINE_ID ' || p_t_lob_line_id || ' ASSET_HEADER_ID ' ||
          p_p_asset_header_id || ' RESERVE_DATE ' || l_reserve_date);
    
      IF p_t IN (0, 1)
      THEN
        l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                         ,p_p_policy_id
                                         ,p_t_lob_line_id
                                         ,p_p_asset_header_id
                                         ,l_reserve_date);
        RESULT(l_id).reserve_value := l_vb * l_s;
        RESULT(l_id).cv := 0;
        --Выкупные суммы для Софинансирования + с РФО
      ELSIF p_t + 1 <= v_payment_term
      THEN
        l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                         ,p_p_policy_id
                                         ,p_t_lob_line_id
                                         ,p_p_asset_header_id
                                         ,l_reserve_date);
        RESULT(l_id).reserve_value := l_vb * l_s;
        RESULT(l_id).cv := ROUND(l_ft * l_vb, 6) * l_s; --Домножить здесь на СС
      ELSIF p_t + 1 BETWEEN v_payment_term + 1 AND v_payment_term + 9
      THEN
        l_v := pkg_reserve_r_life.get_v(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
        RESULT(l_id).reserve_value := l_v * l_s;
        RESULT(l_id).cv := ROUND(l_ft * l_v, 6) * l_s; --Домножить здесь на СС
      ELSE
        l_v := pkg_reserve_r_life.get_v(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
        RESULT(l_id).reserve_value := l_v * l_s;
        RESULT(l_id).cv := 2 * v_payment_term * v_sum_fee;
      END IF;
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
    PROCEDURE calc_one
    (
      p_n                     IN NUMBER
     ,p_t                     IN NUMBER
     ,p_start_schedule_date   IN DATE
     ,p_end_schedule_date     IN DATE
     ,p_payment_num           IN NUMBER
     ,p_fh_year               NUMBER
     ,p_fh_exists             NUMBER
     ,p_period_pol            NUMBER
     ,p_insurance_year_number NUMBER
    ) IS
      l_year_date      DATE;
      l_id             NUMBER;
      l_reserve_date_1 DATE;
      l_reserve_date_2 DATE;
      l_ft             NUMBER;
    
      l_tvs_1 NUMBER;
      l_tvs_2 NUMBER;
      l_s     NUMBER;
    
      l_k_1      NUMBER;
      l_k_2      NUMBER;
      is_to_paid NUMBER;
    BEGIN
      log(p_p_policy_id, 'CALC_ONE ');
    
      log(p_p_policy_id
         ,'CALC_ONE n ' || p_n || ' t ' || p_t || 'START_DATE ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy'));
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date_2 := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      --Чирков изменил 309120: 1140308982 Пшеницын Денис Николаевич при переводе
      -- l_reserve_date_1 := ADD_MONTHS(l_reserve_date_2, -12);
      l_reserve_date_1 := ADD_MONTHS(g_header_start_date, 12 * p_t) - 1;
    
      /**/
      IF p_ft_year_cash_surr
      THEN
        l_ft := ft_year_cash_surr(pkg_products.get_product_id(v_product_brief)
                                 ,r_policy.period_year
                                 ,p_insurance_year_number);
      ELSE
        IF p_fh_exists = 1
           AND p_fh_year >= 0
        THEN
          /*Для Фин каникул*/
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_period_pol - p_fh_year, (p_t - p_fh_year) + 1, 1);
        ELSE
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);
        END IF;
      END IF;
      /**/
    
      /*l_Ft := Ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);*/
    
      log(p_p_policy_id, 'CALC_ONE POLICY_HEADER_ID ' || RESULT(l_id).policy_header_id);
      log(p_p_policy_id, 'CALC_ONE POLICY_ID ' || RESULT(l_id).policy_id);
      log(p_p_policy_id, 'CALC_ONE T_LOB_LINE_ID ' || RESULT(l_id).t_lob_line_id);
      log(p_p_policy_id, 'CALC_ONE P_ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      log(p_p_policy_id, 'CALC_ONE YEAR_DATE ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_1 ' || to_char(l_reserve_date_1, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_2 ' || to_char(l_reserve_date_2, 'dd.mm.yyyy'));
    
      SELECT ins.pkg_policy_checks.check_addendum_type(p_p_policy_id, 'POLICY_TO_PAYED')
        INTO is_to_paid
        FROM dual;
    
      IF is_to_paid = 1
      THEN
        l_tvs_1 := nvl(pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                                ,RESULT             (l_id).policy_id
                                                ,RESULT             (l_id).t_lob_line_id
                                                ,p_p_asset_header_id
                                                ,l_reserve_date_1)
                      ,pkg_reserve_r_life.get_vb_paid(RESULT             (l_id).policy_header_id
                                                     ,RESULT             (l_id).policy_id
                                                     ,RESULT             (l_id).t_lob_line_id
                                                     ,p_p_asset_header_id
                                                     ,l_reserve_date_1)) *
                   pkg_reserve_r_life.get_s(RESULT(l_id).policy_header_id
                                           ,RESULT(l_id).policy_id
                                           ,RESULT(l_id).t_lob_line_id
                                           ,p_p_asset_header_id
                                           ,l_reserve_date_1 + 1);
        l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                            ,RESULT             (l_id).policy_id
                                            ,RESULT             (l_id).t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,l_reserve_date_2) *
                   pkg_reserve_r_life.get_s(RESULT(l_id).policy_header_id
                                           ,RESULT(l_id).policy_id
                                           ,RESULT(l_id).t_lob_line_id
                                           ,p_p_asset_header_id
                                           ,l_reserve_date_2 + 1);
        l_s     := 1;
      ELSE
      
        l_tvs_1 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                            ,RESULT             (l_id).policy_id
                                            ,RESULT             (l_id).t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,l_reserve_date_1);
      
        l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                            ,RESULT             (l_id).policy_id
                                            ,RESULT             (l_id).t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,l_reserve_date_2);
      
        l_s := pkg_reserve_r_life.get_s(RESULT             (l_id).policy_header_id
                                       ,RESULT             (l_id).policy_id
                                       ,RESULT             (l_id).t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_year_date /*Get_year_date (l_year_date, 1)*/);
      END IF;
    
      log(p_p_policy_id, 'CALC_ONE tVS_1 ' || l_tvs_1 || ' tVS_2 ' || l_tvs_2);
    
      l_k_1 := (p_end_schedule_date - l_year_date + 1) / (l_reserve_date_2 - l_year_date + 1);
    
      l_k_1 := ROUND(l_k_1, 6);
      l_k_2 := 1 - l_k_1;
    
      log(p_p_policy_id, 'CALC_ONE l_k_1 ' || l_k_1 || ' l_k_2 ' || l_k_2);
    
      RESULT(l_id).reserve_value := (l_k_1 * l_tvs_2) + (l_k_2 * l_tvs_1);
      RESULT(l_id).cv := l_ft * RESULT(l_id).reserve_value;
      RESULT(l_id).cv := ROUND(RESULT(l_id).cv, 6);
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id, 'CALC_ONE PAYMENT_NUM ' || p_payment_num || ' tCV ' || RESULT(l_id).cv);
    
    END;
  
    PROCEDURE calc_half_year
    (
      p_n                     IN NUMBER
     ,p_t                     IN NUMBER
     ,p_start_schedule_date   IN DATE
     ,p_payment_num           NUMBER
     ,p_fh_year               NUMBER
     ,p_fh_exists             NUMBER
     ,p_period_pol            NUMBER
     ,p_insurance_year_number NUMBER
    ) IS
      l_year_date    DATE;
      l_id           NUMBER;
      l_reserve_date DATE;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_d            NUMBER;
      l_tv           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_year         NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      /**/
      IF p_ft_year_cash_surr
      THEN
        l_ft := ft_year_cash_surr(pkg_products.get_product_id(v_product_brief)
                                 ,r_policy.period_year
                                 ,p_insurance_year_number);
      ELSE
        IF p_fh_exists = 1
           AND p_fh_year >= 0
        THEN
          /*Для Фин каникул*/
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_period_pol - p_fh_year, (p_t - p_fh_year) + 1);
        ELSE
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
        END IF;
      END IF;
      /**/
      /*l_Ft := Ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);*/
    
      l_s := pkg_reserve_r_life.get_ss(RESULT             (l_id).policy_header_id
                                      ,RESULT             (l_id).policy_id
                                      ,RESULT             (l_id).t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      log(p_p_policy_id
         ,'Calc_HALF_YEAR policy_header_id ' || g_policy_header_id || ' t_lob_line_id ' ||
          p_t_lob_line_id || ' p_asset_header_id ' || p_p_asset_header_id || ' reserve_date ' ||
          to_char(l_reserve_date, 'dd.mm.yyyy'));
    
      l_p  := pkg_reserve_r_life.get_pp(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      l_vb := ROUND(pkg_reserve_r_life.get_vb(g_policy_header_id
                                             ,p_p_policy_id
                                             ,p_t_lob_line_id
                                             ,p_p_asset_header_id
                                             ,l_reserve_date)
                   ,6);
    
      IF p_start_schedule_date = l_year_date
      THEN
        l_d := l_p * (1 / 2);
      ELSE
        l_d := 0;
      END IF;
    
      RESULT(l_id).reserve_value := (l_vb - l_d);
    
      IF p_t = 0
      THEN
        RESULT(l_id).cv := 0;
      ELSIF p_t = 1
      THEN
        RESULT(l_id).cv := 0;
      ELSE
        RESULT(l_id).cv := ROUND(l_ft * RESULT(l_id).reserve_value, 6);
      END IF;
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_HALF_YEAR year_date ' || to_char(l_year_date, 'dd.mm.yyyy') || ' reserve_date ' ||
          to_char(l_reserve_date, 'dd.mm.yyyy') || ' P ' || l_p || ' S ' || ' D ' || l_d ||
          ' (VB-D)=' || (l_vb - l_d) || ' t ' || p_t || ' n ' || p_n || ' start_schedule_date ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy') || ' vB ' || l_vb || ' tCV ' || RESULT(l_id).cv ||
          ' Ft ' || l_ft);
    END;
  
    PROCEDURE calc_every_quarter
    (
      p_n                     IN NUMBER
     ,p_t                     IN NUMBER
     ,p_start_schedule_date   IN DATE
     ,p_payment_num           IN NUMBER
     ,p_fh_year               NUMBER
     ,p_fh_exists             NUMBER
     ,p_period_pol            NUMBER
     ,p_insurance_year_number NUMBER
    ) IS
      l_year_date    DATE;
      l_id           NUMBER;
      l_reserve_date DATE;
      l_ft           NUMBER;
      l_tv           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_d            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    
    BEGIN
      log(p_p_policy_id
         ,'CALC_EVERY_QUARTER POLICY_HEADER_ID ' || g_policy_header_id || ' T_LOB_LINE_ID ' ||
          p_t_lob_line_id || ' ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      log(p_p_policy_id, 'CALC_EVERY_QUARTER year_date ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_EVERY_QUARTER reserve_date ' || to_char(l_reserve_date, 'dd.mm.yyyy'));
    
      /**/
      IF p_ft_year_cash_surr
      THEN
        l_ft := ft_year_cash_surr(pkg_products.get_product_id(v_product_brief)
                                 ,r_policy.period_year
                                 ,p_insurance_year_number);
      ELSE
        IF p_fh_exists = 1
           AND p_fh_year >= 0
        THEN
          /*Для Фин каникул*/
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_period_pol - p_fh_year, (p_t - p_fh_year) + 1);
        ELSE
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
        END IF;
      END IF;
      /**/
      /*l_Ft := Ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);*/
    
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date/*Get_year_date (l_year_date, 1)*/);
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      RESULT(l_id).ins_amount := l_s;
    
      /* 2009/03/31 Modify */
      /* 2010/02/25 Modify */
      --l_P := pkg_reserve_r_life.get_P (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, Get_year_date (l_year_date, 1));
      l_p := pkg_reserve_r_life.get_pp(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      /* 2009/03/31 End Modify */
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      l_vb := ROUND(l_vb, 6);
    
      IF p_start_schedule_date = l_year_date
      THEN
        l_d := l_p * 3 / 4;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 3)
      THEN
        l_d := l_p * 1 / 2;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 6)
      THEN
        l_d := l_p * 1 / 4;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 9)
      THEN
        l_d := 0;
      END IF;
    
      l_d := ROUND(l_d, 6);
    
      RESULT(l_id).reserve_value := (l_vb - l_d);
    
      IF p_t = 0
      THEN
        RESULT(l_id).cv := 0;
      ELSIF p_t = 1
      THEN
        RESULT(l_id).cv := 0;
      ELSE
        RESULT(l_id).cv := ROUND(l_ft * RESULT(l_id).reserve_value, 6);
      END IF;
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id, 'CALC_EVERY_QUARTER NUM ' || p_payment_num);
      log(p_p_policy_id
         ,'CALC_EVERY_QUARTER  P ' || l_p || ' S ' || l_s || ' D ' || l_d || ' (VB-D)=' ||
          (l_vb - l_d) || ' v_t ' || p_t || ' n ' || p_n || ' schedule_date ' ||
          to_date(p_start_schedule_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_EVERY_QUARTER vB ' || l_vb || ' tCV ' || RESULT(l_id).cv);
    END;
  
    PROCEDURE calc_monthly
    (
      p_n                     IN NUMBER
     ,p_t                     IN NUMBER
     ,p_start_schedule_date   IN DATE
     ,p_payment_num           IN NUMBER
     ,p_fh_year               NUMBER
     ,p_fh_exists             NUMBER
     ,p_period_pol            NUMBER
     ,p_insurance_year_number NUMBER
    ) IS
      l_year_date    DATE;
      l_id           NUMBER;
      l_reserve_date DATE;
      l_ft           NUMBER;
      l_tv           NUMBER;
      l_p            NUMBER;
      l_vb           NUMBER;
      l_d            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      log(p_p_policy_id, 'Calc_MONTHLY');
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      /**/
      IF p_ft_year_cash_surr
      THEN
        l_ft := ft_year_cash_surr(pkg_products.get_product_id(v_product_brief)
                                 ,r_policy.period_year
                                 ,p_insurance_year_number);
      ELSE
        IF p_fh_exists = 1
           AND p_fh_year >= 0
        THEN
          /*Для Фин каникул*/
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_period_pol - p_fh_year, (p_t - p_fh_year) + 1);
        ELSE
          l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
        END IF;
      END IF;
      /**/
      /*l_Ft := Ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);*/
    
      log(p_p_policy_id
         ,'Calc_MONTHLY reserve_date ' || to_char(l_reserve_date, 'dd.mm.yyyy') || ' year_date ' ||
          to_char(l_year_date, 'dd.mm.yyyy'));
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date/*Get_year_date (l_year_date, 1)*/);
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      --l_P := pkg_reserve_r_life.get_P (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, Get_year_date (l_year_date, 1));
      l_p  := pkg_reserve_r_life.get_pp(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
    
      l_vb := ROUND(l_vb, 6);
    
      IF p_start_schedule_date = l_year_date
      THEN
        l_d := l_p * 11 / 12;
        log(p_p_policy_id, 'Calc_MONTHLY p_start_schedule_date = l_year_date');
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 1)
      THEN
        l_d := l_p * 10 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 2)
      THEN
        l_d := l_p * 9 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 3)
      THEN
        l_d := l_p * 8 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 4)
      THEN
        l_d := l_p * 7 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 5)
      THEN
        l_d := l_p * 6 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 6)
      THEN
        l_d := l_p * 5 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 7)
      THEN
        l_d := l_p * 4 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 8)
      THEN
        l_d := l_p * 3 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 9)
      THEN
        l_d := l_p * 2 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 10)
      THEN
        l_d := l_p * 1 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 11)
      THEN
        l_d := 0;
      END IF;
    
      l_d := ROUND(l_d, 6);
    
      RESULT(l_id).reserve_value := (l_vb - l_d);
    
      IF p_t = 0
      THEN
        RESULT(l_id).cv := 0;
      ELSIF p_t = 1
      THEN
        RESULT(l_id).cv := 0;
      ELSE
        RESULT(l_id).cv := ROUND(l_ft * RESULT(l_id).reserve_value, 6);
      END IF;
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_MONTHLY  P ' || l_p || ' S ' || l_s || ' D ' || l_d || ' (VB-D)=' || (l_vb - l_d) ||
          ' t ' || p_t || ' n ' || p_n || ' schedule_date ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy') || ' vB ' || l_vb || ' tCV ' || RESULT(l_id).cv);
      --
    END;
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => c_proc_name
                     ,par_message           => par_message);
    END trace;
  BEGIN
    pkg_trace.add_variable('p_p_policy_id', p_p_policy_id);
    pkg_trace.add_variable('p_contact_id', p_contact_id);
    pkg_trace.add_variable('p_p_asset_header_id', p_p_asset_header_id);
    pkg_trace.add_variable('p_t_lob_line_id', p_t_lob_line_id);
    pkg_trace.add_variable('p_start_date', p_start_date);
    pkg_trace.add_variable('p_end_date', p_end_date);
    pkg_trace.add_variable('p_p_cover_id', p_p_cover_id);
    pkg_trace.add_variable('p_ins_amount', p_ins_amount);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => c_proc_name);
  
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    pkg_trace.add_variable('v_brief', v_brief);
    pkg_trace.add_variable('v_start_date', v_start_date);
    pkg_trace.add_variable('g_header_start_date', g_header_start_date);
    pkg_trace.add_variable('g_policy_header_id', g_policy_header_id);
    pkg_trace.add_variable('v_product_brief', v_product_brief);
    trace('Получены данные по договору');
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    pkg_trace.add_variable('l_pause_start_date', l_pause_start_date);
    pkg_trace.add_variable('l_pause_end_date', l_pause_end_date);
    trace('Определение фин. каникул');
  
    IF l_pause_start_date IS NOT NULL
       AND l_pause_end_date IS NOT NULL
    THEN
      l_fh_exists := 1;
    ELSE
      l_fh_exists := 0;
    END IF;
    l_fh_year := FLOOR(MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12);
  
    p_p_period_year     := r_policy.period_year;
    p_policy_start_date := r_policy.start_date;
    /*  if nvl(l_fh_year,0) > 0 then
      p_p_period_year := r_policy.period_year_fh - FLOOR(l_fh_year);
      p_policy_start_date := g_header_start_date;
    end if;*/
  
    FOR r_schedule IN c_schedule(v_brief, p_policy_start_date, p_p_period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      pkg_trace.add_variable('r_schedule.schedule_num', r_schedule.schedule_num);
      pkg_trace.add_variable('r_schedule.start_schedule_date', r_schedule.start_schedule_date);
      pkg_trace.add_variable('r_schedule.end_schedule_date', r_schedule.end_schedule_date);
      pkg_trace.add_variable('v_t', v_t);
      trace('Начало расчета выкупных для периода оплаты');
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      IF v_brief = 'EVERY_YEAR'
         AND v_product_brief <> 'SF_AVCR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
        calc_every_year(g_header_start_date
                       ,p_p_period_year
                       ,v_t
                       ,r_schedule.schedule_num
                       ,nvl(l_fh_year, 0)
                       ,l_fh_exists
                       ,r_policy.period_year_fh
                       ,r_schedule.insurance_year_number);
      ELSIF v_brief = 'EVERY_YEAR'
            AND v_product_brief = 'SF_AVCR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе для SF_AVCR*/
        calc_every_year_sf_avcr(g_header_start_date
                               ,r_policy.period_year
                               ,v_t
                               ,r_schedule.schedule_num);
      
      ELSIF v_brief = 'Единовременно'
      THEN
        /*Расчет выкупной суммы при единовременном взносе*/
        calc_one(p_p_period_year /*r_policy.period_year*/
                ,v_t
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,r_schedule.schedule_num
                ,nvl(l_fh_year, 0)
                ,l_fh_exists
                ,r_policy.period_year_fh
                ,r_schedule.insurance_year_number);
      
      ELSIF v_brief = 'HALF_YEAR'
      THEN
      
        calc_half_year(p_p_period_year /*r_policy.period_year*/
                      ,v_t
                      ,r_schedule.start_schedule_date
                      ,r_schedule.schedule_num
                      ,nvl(l_fh_year, 0)
                      ,l_fh_exists
                      ,r_policy.period_year_fh
                      ,r_schedule.insurance_year_number);
      
      ELSIF v_brief = 'EVERY_QUARTER'
      THEN
      
        calc_every_quarter(p_p_period_year /*r_policy.period_year*/
                          ,v_t
                          ,r_schedule.start_schedule_date
                          ,r_schedule.schedule_num
                          ,nvl(l_fh_year, 0)
                          ,l_fh_exists
                          ,r_policy.period_year_fh
                          ,r_schedule.insurance_year_number);
      
      ELSIF v_brief = 'MONTHLY'
      THEN
        calc_monthly(p_p_period_year /*r_policy.period_year*/
                    ,v_t
                    ,r_schedule.start_schedule_date
                    ,r_schedule.schedule_num
                    ,nvl(l_fh_year, 0)
                    ,l_fh_exists
                    ,r_policy.period_year_fh
                    ,r_schedule.insurance_year_number);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
    
      /*IF v_t - l_fh_year < 2 THEN
        log (p_p_policy_id, 'END_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        result(result.count).cv := 0;
      END IF;*/
    
      IF v_product_brief <> 'SF_AVCR'
      THEN
        RESULT(result.count).value := RESULT(result.count).cv * RESULT(result.count).ins_amount;
        RESULT(result.count).reserve_value := RESULT(result.count)
                                              .reserve_value * RESULT(result.count).ins_amount;
      ELSIF v_product_brief = 'SF_AVCR'
      THEN
        RESULT(result.count).value := RESULT(result.count).cv;
      END IF;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'END_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;
  /*INVEST-RESERVE*/
  FUNCTION invreserve_cash_surrender
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
   ,p_pl_id             NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,(CASE
               WHEN (SELECT COUNT(*)
                       FROM ins.t_prod_line_option opt
                           ,ins.t_product_line     pl
                           ,ins.t_lob_line         ll
                      WHERE opt.id = pc.t_prod_line_option_id
                        AND opt.product_line_id = pl.id
                        AND pl.t_lob_line_id = ll.t_lob_line_id
                        AND ll.brief = 'PEPR_INVEST_RESERVE') > 0 THEN
                0
               ELSE
                pt.is_periodical
             END) is_periodical
             /*, pt.is_periodical*/
            ,(CASE
               WHEN (SELECT COUNT(*)
                       FROM ins.t_prod_line_option opt
                           ,ins.t_product_line     pl
                           ,ins.t_lob_line         ll
                      WHERE opt.id = pc.t_prod_line_option_id
                        AND opt.product_line_id = pl.id
                        AND pl.t_lob_line_id = ll.t_lob_line_id
                        AND ll.brief = 'PEPR_INVEST_RESERVE') > 0 THEN
                'Единовременно'
               ELSE
                pt.brief
             END) brief
             /*, pt.brief*/
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
             /*,(SELECT TRUNC(MONTHS_BETWEEN(pca.end_date + 1, pca.start_date) / 12)
              FROM ins.as_asset            a
                  ,ins.p_cover             pca
                  ,ins.status_hist         st
                  ,ins.t_prod_line_option  opt
                  ,ins.t_product_line      pl
                  ,ins.t_product_line_type plt
             WHERE a.p_policy_id = pp.policy_id
               AND a.as_asset_id = pca.as_asset_id
               AND pca.t_prod_line_option_id = opt.id
               AND pl.id = opt.product_line_id
               AND pl.product_line_type_id = plt.product_line_type_id
               AND plt.brief = 'RECOMMENDED'
               AND pca.status_hist_id = st.status_hist_id
               AND st.brief != 'DELETED') period_year*/
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
     ,p_pl_id               IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
      RESULT(l_id).product_line_id := p_pl_id;
    
    END;
  
    PROCEDURE calc_one
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date      DATE;
      l_id             NUMBER;
      l_reserve_date_1 DATE;
      l_reserve_date_2 DATE;
      l_ft             NUMBER;
    
      l_tvs_1 NUMBER;
      l_tvs_2 NUMBER;
      l_s     NUMBER;
    
      l_k_1 NUMBER;
      l_k_2 NUMBER;
    BEGIN
      log(p_p_policy_id, 'CALC_ONE ');
    
      log(p_p_policy_id
         ,'CALC_ONE n ' || p_n || ' t ' || p_t || 'START_DATE ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy'));
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date_2 := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      --Чирков изменил 309120: 1140308982 Пшеницын Денис Николаевич при переводе
      -- l_reserve_date_1 := ADD_MONTHS(l_reserve_date_2, -12);
      l_reserve_date_1 := ADD_MONTHS(g_header_start_date, 12 * p_t) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);
      --l_Ft := Ft(p_p_policy_id, p_p_cover_id, 14, 6 + 1, 0);
    
      log(p_p_policy_id, 'CALC_ONE POLICY_HEADER_ID ' || RESULT(l_id).policy_header_id);
      log(p_p_policy_id, 'CALC_ONE POLICY_ID ' || RESULT(l_id).policy_id);
      log(p_p_policy_id, 'CALC_ONE T_LOB_LINE_ID ' || RESULT(l_id).t_lob_line_id);
      log(p_p_policy_id, 'CALC_ONE P_ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      log(p_p_policy_id, 'CALC_ONE YEAR_DATE ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_1 ' || to_char(l_reserve_date_1, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_2 ' || to_char(l_reserve_date_2, 'dd.mm.yyyy'));
    
      l_tvs_1 := pkg_reserve_r_life.get_pl_vs(RESULT             (l_id).policy_header_id
                                             ,RESULT             (l_id).policy_id
                                             ,RESULT             (l_id).t_lob_line_id
                                             ,p_p_asset_header_id
                                             ,l_reserve_date_1
                                             ,RESULT             (l_id).product_line_id);
    
      l_tvs_2 := pkg_reserve_r_life.get_pl_vs(RESULT             (l_id).policy_header_id
                                             ,RESULT             (l_id).policy_id
                                             ,RESULT             (l_id).t_lob_line_id
                                             ,p_p_asset_header_id
                                             ,l_reserve_date_2
                                             ,RESULT             (l_id).product_line_id);
    
      /*l_S := pkg_reserve_r_life.get_S(RESULT             (l_id).policy_header_id
      ,RESULT             (l_id).policy_id
      ,RESULT             (l_id).t_lob_line_id
      ,p_p_asset_header_id
      ,l_year_date);*/
    
      l_s := pkg_reserve_r_life.get_pl_s(RESULT             (l_id).policy_header_id
                                        ,RESULT             (l_id).policy_id
                                        ,RESULT             (l_id).t_lob_line_id
                                        ,p_p_asset_header_id
                                        ,l_year_date
                                        ,RESULT             (l_id).product_line_id);
      log(p_p_policy_id, 'CALC_ONE tVS_1 ' || l_tvs_1 || ' tVS_2 ' || l_tvs_2);
    
      l_k_1 := (p_end_schedule_date - l_year_date + 1) / (l_reserve_date_2 - l_year_date + 1);
    
      l_k_1 := ROUND(l_k_1, 6);
      l_k_2 := 1 - l_k_1;
    
      log(p_p_policy_id, 'CALC_ONE l_k_1 ' || l_k_1 || ' l_k_2 ' || l_k_2);
    
      RESULT(l_id).cv := l_ft * ((l_k_1 * l_tvs_2) + (l_k_2 * l_tvs_1));
      RESULT(l_id).cv := ROUND(RESULT(l_id).cv, 6);
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id, 'CALC_ONE PAYMENT_NUM ' || p_payment_num || ' tCV ' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'END_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'END_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'END_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
    IF nvl(l_fh_year, 0) > 0
    THEN
      p_p_period_year := r_policy.period_year_fh - ROUND(l_fh_year, 0);
    END IF;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t
                ,p_pl_id);
    
      log(p_p_policy_id
         ,'END_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'Единовременно'
      THEN
        /*Расчет выкупной суммы при единовременном взносе*/
        calc_one(r_policy.period_year
                ,v_t
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
    
      IF v_t - l_fh_year < 2
      THEN
        log(p_p_policy_id
           ,'END_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv * RESULT(result.count).ins_amount;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'END_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;
  /**/

  FUNCTION inv2_cash_surrender
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id
         AND pc.start_date = ph.start_date
      UNION
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,pc.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id
         AND pc.start_date != ph.start_date;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO year_number ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
      log(p_p_policy_id, 'POLICYINFO result.count ' || result.count);
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      /*l_S := pkg_reserve_r_life.get_S (result(l_id).policy_header_id
      ,result(l_id).policy_id
      ,result(l_id).t_lob_line_id
      ,p_p_asset_header_id
      ,add_months (l_year_date, 12));*/
    
      l_s := pkg_reserve_r_life.get_ss(RESULT             (l_id).policy_header_id
                                      ,RESULT             (l_id).policy_id
                                      ,RESULT             (l_id).t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      log(p_p_policy_id, 'CALC_EVERY_YEAR policy_header_id ' || g_policy_header_id);
      log(p_p_policy_id
         ,'CALC_EVERY_YEAR t_lob_line_id ' || p_t_lob_line_id || ' asset_header_id ' ||
          p_p_asset_header_id || ' reserve_date ' || l_reserve_date);
    
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
      RESULT(l_id).value := l_s * RESULT(l_id).cv;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR PAYMENT_NUM ' || p_payment_num || ' reserve_date=' ||
          to_char(l_reserve_date, 'dd.mm.yyyy') || ' S' || l_s || ' Ft=' || l_ft || ' t=' || p_t ||
          ' n=' || p_n);
      log(p_p_policy_id
         , 'CALC_EVERY_YEAR vB=' || l_vb || ' tCV=' || RESULT(l_id).cv || ' Vvalue ' || RESULT(l_id)
          .value);
    
    END;
  
    PROCEDURE calc_one
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date      DATE;
      l_id             NUMBER;
      l_reserve_date_1 DATE;
      l_reserve_date_2 DATE;
      l_ft             NUMBER;
    
      l_tvs_1 NUMBER;
      l_tvs_2 NUMBER;
    
      l_k_1 NUMBER;
      l_k_2 NUMBER;
    
      l_s        NUMBER;
      is_to_paid NUMBER;
    
    BEGIN
      log(p_p_policy_id, 'CALC_ONE ');
    
      log(p_p_policy_id
         ,'CALC_ONE n ' || p_n || ' t ' || p_t || 'START_DATE ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy'));
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date_2 := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      --Чирков изменил 309120: 1140308982 Пшеницын Денис Николаевич при переводе
      -- l_reserve_date_1 := ADD_MONTHS(l_reserve_date_2, -12);
      l_reserve_date_1 := ADD_MONTHS(g_header_start_date, 12 * p_t) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);
    
      SELECT ins.pkg_policy_checks.check_addendum_type(p_p_policy_id, 'POLICY_TO_PAYED')
        INTO is_to_paid
        FROM dual;
    
      IF is_to_paid = 1
      THEN
        l_tvs_1 := nvl(pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                                ,RESULT             (l_id).policy_id
                                                ,RESULT             (l_id).t_lob_line_id
                                                ,p_p_asset_header_id
                                                ,l_reserve_date_1)
                      ,pkg_reserve_r_life.get_vb_paid(RESULT             (l_id).policy_header_id
                                                     ,RESULT             (l_id).policy_id
                                                     ,RESULT             (l_id).t_lob_line_id
                                                     ,p_p_asset_header_id
                                                     ,l_reserve_date_1)) *
                   pkg_reserve_r_life.get_s(RESULT(l_id).policy_header_id
                                           ,RESULT(l_id).policy_id
                                           ,RESULT(l_id).t_lob_line_id
                                           ,p_p_asset_header_id
                                           ,l_reserve_date_1 + 1);
        l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                            ,RESULT             (l_id).policy_id
                                            ,RESULT             (l_id).t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,l_reserve_date_2) *
                   pkg_reserve_r_life.get_s(RESULT(l_id).policy_header_id
                                           ,RESULT(l_id).policy_id
                                           ,RESULT(l_id).t_lob_line_id
                                           ,p_p_asset_header_id
                                           ,l_reserve_date_2 + 1);
        l_s     := 1;
      ELSE
      
        l_s := pkg_reserve_r_life.get_s(RESULT             (l_id).policy_header_id
                                       ,RESULT             (l_id).policy_id
                                       ,RESULT             (l_id).t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_year_date /*Get_year_date (l_year_date, 1)*/);
      
        l_tvs_1 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                            ,RESULT             (l_id).policy_id
                                            ,RESULT             (l_id).t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,l_reserve_date_1);
      
        l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                            ,RESULT             (l_id).policy_id
                                            ,RESULT             (l_id).t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,l_reserve_date_2);
      END IF;
    
      log(p_p_policy_id, 'CALC_ONE POLICY_HEADER_ID ' || RESULT(l_id).policy_header_id);
      log(p_p_policy_id, 'CALC_ONE POLICY_ID ' || RESULT(l_id).policy_id);
      log(p_p_policy_id, 'CALC_ONE T_LOB_LINE_ID ' || RESULT(l_id).t_lob_line_id);
      log(p_p_policy_id, 'CALC_ONE P_ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      log(p_p_policy_id, 'CALC_ONE YEAR_DATE ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_1 ' || to_char(l_reserve_date_1, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_ONE RESERVE_DATE_2 ' || to_char(l_reserve_date_2, 'dd.mm.yyyy'));
    
      log(p_p_policy_id, 'CALC_ONE tVS_1 ' || l_tvs_1 || ' tVS_2 ' || l_tvs_2);
    
      l_k_1 := (p_end_schedule_date - l_year_date + 1) / (l_reserve_date_2 - l_year_date + 1);
    
      l_k_1 := ROUND(l_k_1, 6);
      l_k_2 := 1 - l_k_1;
    
      log(p_p_policy_id, 'CALC_ONE l_k_1 ' || l_k_1 || ' l_k_2 ' || l_k_2);
    
      RESULT(l_id).cv := l_ft * ((l_k_1 * l_tvs_2) + (l_k_2 * l_tvs_1));
      RESULT(l_id).cv := ROUND(RESULT(l_id).cv, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
      RESULT(l_id).value := l_s * RESULT(l_id).cv;
    
      log(p_p_policy_id
         ,'CALC_ONE PAYMENT_NUM ' || r_schedule.schedule_num || ' tCV ' || RESULT(l_id).cv);
    
    END;
  
    PROCEDURE calc_half_year
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date    DATE;
      l_id           NUMBER;
      l_reserve_date DATE;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_d            NUMBER;
      l_tv           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
    
      /*l_S := pkg_reserve_r_life.get_S (result(l_id).policy_header_id
      ,result(l_id).policy_id
      ,result(l_id).t_lob_line_id
      ,p_p_asset_header_id
      ,add_months (l_year_date, 12)); */
    
      l_s := pkg_reserve_r_life.get_ss(RESULT             (l_id).policy_header_id
                                      ,RESULT             (l_id).policy_id
                                      ,RESULT             (l_id).t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      log(p_p_policy_id
         ,'Calc_HALF_YEAR policy_header_id ' || g_policy_header_id || ' t_lob_line_id ' ||
          p_t_lob_line_id || ' p_asset_header_id ' || p_p_asset_header_id || ' reserve_date ' ||
          to_char(l_reserve_date, 'dd.mm.yyyy'));
    
      --l_P := pkg_reserve_r_life.get_P (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date);
      l_p := pkg_reserve_r_life.get_pp(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      IF p_start_schedule_date = l_year_date
      THEN
        l_vb := ROUND(pkg_reserve_r_life.get_vb(g_policy_header_id
                                               ,p_p_policy_id
                                               ,p_t_lob_line_id
                                               ,p_p_asset_header_id
                                               ,l_reserve_date)
                     ,6);
        l_d  := l_p * (1 / 2);
      ELSE
        l_vb := ROUND(pkg_reserve_r_life.get_vb(g_policy_header_id
                                               ,p_p_policy_id
                                               ,p_t_lob_line_id
                                               ,p_p_asset_header_id
                                               ,l_reserve_date)
                     ,6);
        l_d  := 0;
      END IF;
    
      RESULT(l_id).cv := ROUND(l_ft * (l_vb - l_d), 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
      RESULT(l_id).value := l_s * RESULT(l_id).cv;
    
      log(p_p_policy_id
         ,'Calc_HALF_YEAR year_date ' || to_char(l_year_date, 'dd.mm.yyyy') || ' reserve_date ' ||
          to_char(l_reserve_date, 'dd.mm.yyyy') || ' P ' || l_p || ' S ' || l_s || ' D ' || l_d ||
          ' (VB-D)=' || (l_vb - l_d) || ' t ' || p_t || ' n ' || p_n || ' start_schedule_date ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy') || ' vB ' || l_vb || ' tCV ' || RESULT(l_id).cv ||
          ' Ft ' || l_ft || ' Value ' || RESULT(l_id).value);
    END;
  
    PROCEDURE calc_every_quarter
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date    DATE;
      l_id           NUMBER;
      l_reserve_date DATE;
      l_ft           NUMBER;
      l_tv           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_d            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    
    BEGIN
      log(p_p_policy_id, 'CALC_EVERY_QUARTER YEAR_DATE n' || p_n);
      log(p_p_policy_id, 'CALC_EVERY_QUARTER YEAR_DATE t' || p_t);
    
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      /*l_S := pkg_reserve_r_life.get_S (result(l_id).policy_header_id
      ,result(l_id).policy_id
      ,result(l_id).t_lob_line_id
      ,p_p_asset_header_id
      ,Get_year_date (l_year_date, 1));*/
    
      l_s := pkg_reserve_r_life.get_ss(RESULT             (l_id).policy_header_id
                                      ,RESULT             (l_id).policy_id
                                      ,RESULT             (l_id).t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      log(p_p_policy_id, 'CALC_EVERY_QUARTER YEAR_DATE ' || to_char(l_year_date, 'dd.mm.yyyy'));
      log(p_p_policy_id, 'CALC_EVERY_QUARTER RESERVE_DATE ' || to_char(l_reserve_date, 'dd.mm.yyyy'));
    
      log(p_p_policy_id
         ,'CALC_EVERY_QUARTER POLICY_HEADER_ID ' || g_policy_header_id || ' T_LOB_LINE_ID ' ||
          p_t_lob_line_id || ' P_ASSET_HEADER_ID ' || p_p_asset_header_id);
    
      --l_P := pkg_reserve_r_life.get_P (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date);
      l_p  := pkg_reserve_r_life.get_pp(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      l_vb := ROUND(l_vb, 6);
    
      IF p_start_schedule_date = l_year_date
      THEN
        l_d := l_p * 3 / 4;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 3)
      THEN
        l_d := l_p * 1 / 2;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 6)
      THEN
        l_d := l_p * 1 / 4;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 9)
      THEN
        l_d := 0;
      END IF;
    
      l_d := ROUND(l_d, 6);
      RESULT(l_id).cv := ROUND(l_ft * (l_vb - l_d), 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
      RESULT(l_id).value := l_s * RESULT(l_id).cv;
    
      log(p_p_policy_id
         ,'Calc_EVERY_QUARTER i.num ' || p_payment_num || ' P ' || l_p || ' D ' || l_d || ' (VB-D)=' ||
          (l_vb - l_d) || ' v_t ' || p_t || ' n ' || p_n || ' schedule_date ' ||
          to_date(p_start_schedule_date, 'dd.mm.yyyy') || 'vB ' || l_vb || ' tCV ' || RESULT(l_id).cv ||
          ' Value ' || RESULT(l_id).value);
    END;
  
    PROCEDURE calc_monthly
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date    DATE;
      l_id           NUMBER;
      l_reserve_date DATE;
      l_ft           NUMBER;
      l_tv           NUMBER;
      l_p            NUMBER;
      l_vb           NUMBER;
      l_d            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      log(p_p_policy_id, 'Calc_MONTHLY');
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
    
      log(p_p_policy_id
         ,'Calc_MONTHLY reserve_date ' || to_char(l_reserve_date, 'dd.mm.yyyy') || ' year_date ' ||
          to_char(l_year_date, 'dd.mm.yyyy'));
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, Get_year_date (l_year_date, 1));
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
    
      --l_P := pkg_reserve_r_life.get_P (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, Get_year_date (l_year_date, 1));
      l_p  := pkg_reserve_r_life.get_pp(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
    
      l_vb := ROUND(l_vb, 6);
    
      IF p_start_schedule_date = l_year_date
      THEN
        l_d := l_p * 11 / 12;
        log(p_p_policy_id, 'Calc_MONTHLY p_start_schedule_date = l_year_date');
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 1)
      THEN
        l_d := l_p * 10 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 2)
      THEN
        l_d := l_p * 9 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 3)
      THEN
        l_d := l_p * 8 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 4)
      THEN
        l_d := l_p * 7 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 5)
      THEN
        l_d := l_p * 6 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 6)
      THEN
        l_d := l_p * 5 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 7)
      THEN
        l_d := l_p * 4 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 8)
      THEN
        l_d := l_p * 3 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 9)
      THEN
        l_d := l_p * 2 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 10)
      THEN
        l_d := l_p * 1 / 12;
      ELSIF p_start_schedule_date = ADD_MONTHS(l_year_date, 11)
      THEN
        l_d := 0;
      END IF;
    
      l_d := ROUND(l_d, 6);
      RESULT(l_id).cv := ROUND(l_ft * (l_vb - l_d), 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_MONTHLY  P ' || l_p || ' S ' || l_s || ' D ' || l_d || ' (VB-D)=' || (l_vb - l_d) ||
          ' t ' || p_t || ' n ' || p_n || ' schedule_date ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy') || ' vB ' || l_vb || ' tCV ' || RESULT(l_id).cv);
      --
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV2_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV2_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV2_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' v_period_year ' ||
        v_period_year);
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      log(p_p_policy_id
         ,'INV2_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      IF v_brief = 'EVERY_YEAR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
      
        calc_every_year(g_header_start_date, r_policy.period_year, v_t, r_schedule.schedule_num);
      
      ELSIF v_brief = 'Единовременно'
      THEN
        /*Расчет выкупной суммы при единовременном взносе*/
        calc_one(r_policy.period_year
                ,v_t
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,r_schedule.schedule_num);
      
      ELSIF v_brief = 'HALF_YEAR'
      THEN
      
        calc_half_year(r_policy.period_year
                      ,v_t
                      ,r_schedule.start_schedule_date
                      ,r_schedule.schedule_num);
      
      ELSIF v_brief = 'EVERY_QUARTER'
      THEN
      
        calc_every_quarter(r_policy.period_year
                          ,v_t
                          ,r_schedule.start_schedule_date
                          ,r_schedule.schedule_num);
      
      ELSIF v_brief = 'MONTHLY'
      THEN
        calc_monthly(r_policy.period_year
                    ,v_t
                    ,r_schedule.start_schedule_date
                    ,r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv * RESULT(result.count).ins_amount;
    
      IF RESULT(result.count).cv IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id, 'cv IS NULL');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.05.2009 13:14:44
  -- Purpose : Расчет выкупных сумм для продукта Софинансирование +
  FUNCTION sf_cash_surrender
  (
    p_p_policy_id IN NUMBER
   ,p_start_date  IN DATE
   ,p_ins_amount  NUMBER
   ,p_ins_fee     NUMBER
  ) RETURN tbl_cash_surrender IS
    RESULT        tbl_cash_surrender;
    proc_name     VARCHAR2(20) := 'SF_Cash_Surrender';
    v_period_year NUMBER;
    v_t           NUMBER;
    l_d           PLS_INTEGER;
    ret_sum       NUMBER;
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
  
    r_schedule c_schedule%ROWTYPE;
  
  BEGIN
    SELECT ph.start_date header_start_date
          ,trunc(MONTHS_BETWEEN(pp.end_date + 1, p_start_date) / 12) period_year
      INTO g_header_start_date
          ,v_period_year
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    FOR r_schedule IN c_schedule('Единовременно', g_header_start_date, v_period_year)
    LOOP
      l_d := result.count + 1;
      v_t := FLOOR(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12) + 1;
      IF v_t = (MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12) + 1
      THEN
      
        CASE
          WHEN v_t = 1 THEN
            ret_sum := 0.5 * p_ins_fee;
          WHEN v_t BETWEEN 2 AND 3 THEN
            ret_sum := 0.75 * p_ins_fee;
          WHEN v_t BETWEEN 4 AND 10 THEN
            ret_sum := p_ins_fee;
          WHEN v_t BETWEEN 11 AND 20 THEN
            ret_sum := 2 * p_ins_fee;
          WHEN v_t BETWEEN 20 AND 31 THEN
            ret_sum := 3 * p_ins_fee;
        END CASE;
      
        RESULT(l_d).insurance_year_date := ADD_MONTHS(g_header_start_date, v_t * 12);
        RESULT(l_d).start_cash_surr_date := r_schedule.start_schedule_date;
        RESULT(l_d).end_cash_surr_date := r_schedule.end_schedule_date;
        RESULT(l_d).is_history := 0;
        RESULT(l_d).insurance_year_number := v_t - 1;
        RESULT(l_d).payment_number := l_d;
        RESULT(l_d).value := ret_sum;
        RESULT(l_d).ft := NULL;
        RESULT(l_d).ins_amount := p_ins_amount;
        RESULT(l_d).cv := NULL;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END sf_cash_surrender;

  -- Author  : ILYA.SLEZIN
  -- Created : 11.10.2009
  -- Purpose : Расчет выкупных сумм для продукта Семейный депозит (Family_Dep) (скопировано с SF_Cash_Surrender)
  FUNCTION family_dep_cash_surrender
  (
    p_p_policy_id IN NUMBER
   ,p_start_date  IN DATE
   ,p_ins_amount  NUMBER
  ) RETURN tbl_cash_surrender IS
    RESULT        tbl_cash_surrender;
    proc_name     VARCHAR2(40) := 'Family_Dep_Cash_Surrender';
    v_period_year NUMBER;
    v_t           NUMBER;
    v_ft          NUMBER;
    l_d           PLS_INTEGER;
    ret_sum       NUMBER;
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
  
    r_schedule c_schedule%ROWTYPE;
    v_brief    VARCHAR2(100);
  BEGIN
    SELECT ph.start_date header_start_date
          ,trunc(MONTHS_BETWEEN(pp.end_date + 1, p_start_date) / 12) period_year
      INTO g_header_start_date
          ,v_period_year
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    SELECT pt.brief
      INTO v_brief
      FROM t_payment_terms pt
          ,p_policy        p
     WHERE pt.id = p.payment_term_id
       AND p.policy_id = p_p_policy_id;
  
    FOR r_schedule IN c_schedule(v_brief, g_header_start_date, v_period_year)
    LOOP
      l_d := result.count + 1;
      v_t := FLOOR(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12) + 1;
      /*IF v_t = (MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date)/12)+1
      THEN*/
      IF v_brief = 'Единовременно'
      THEN
        IF v_t = (MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12) + 1
        THEN
          /* CASE
            WHEN v_t = 1 THEN
              ret_sum := p_ins_amount * 0.3856;
            WHEN v_t = 2 THEN
              ret_sum := p_ins_amount * 0.5076;
            WHEN v_t = 3 THEN
              ret_sum := p_ins_amount * 0.6499;
            WHEN v_t = 4 THEN
              ret_sum := p_ins_amount * 0.7708;
            WHEN v_t = 5 THEN
              ret_sum := p_ins_amount * 0.9;
            ELSE
              ret_sum := 0;
          END CASE;*/
          CASE
            WHEN v_t = 1 THEN
              v_ft := 0.3856;
            WHEN v_t = 2 THEN
              v_ft := 0.5076;
            WHEN v_t = 3 THEN
              v_ft := 0.6499;
            WHEN v_t = 4 THEN
              v_ft := 0.7708;
            WHEN v_t = 5 THEN
              v_ft := 0.9;
            ELSE
              v_ft := 0;
          END CASE;
          ret_sum := p_ins_amount * v_ft;
        END IF;
      ELSE
        --в рассрочку
        /*        CASE
          WHEN v_t = 1 THEN
            ret_sum := 0;
          WHEN v_t = 2 THEN
            ret_sum := 0;
          WHEN v_t = 3 THEN
            ret_sum := p_ins_amount * 0.1362;
          WHEN v_t = 3.5 THEN
            ret_sum := p_ins_amount * 0.1362;
          WHEN v_t = 4 THEN
            ret_sum := p_ins_amount * 0.3049;
          WHEN v_t = 4.5 THEN
            ret_sum := p_ins_amount * 0.3049;
          WHEN v_t = 5 THEN
            ret_sum := p_ins_amount * 0.7455;
          WHEN v_t = 5.5 THEN
            ret_sum := p_ins_amount * 0.7455;
          ELSE
            ret_sum := 0;
        END CASE;*/
        CASE
          WHEN v_t = 1 THEN
            v_ft := 0;
          WHEN v_t = 2 THEN
            v_ft := 0;
          WHEN v_t = 3 THEN
            v_ft := 0.1362;
          WHEN v_t = 3.5 THEN
            v_ft := 0.1362;
          WHEN v_t = 4 THEN
            v_ft := 0.3049;
          WHEN v_t = 4.5 THEN
            v_ft := 0.3049;
          WHEN v_t = 5 THEN
            v_ft := 0.7455;
          WHEN v_t = 5.5 THEN
            v_ft := 0.7455;
          ELSE
            v_ft := 0;
        END CASE;
        ret_sum := p_ins_amount * v_ft;
      END IF;
      RESULT(l_d).insurance_year_date := ADD_MONTHS(g_header_start_date, v_t * 12);
      RESULT(l_d).start_cash_surr_date := r_schedule.start_schedule_date;
      RESULT(l_d).end_cash_surr_date := r_schedule.end_schedule_date;
      RESULT(l_d).is_history := 0;
      RESULT(l_d).insurance_year_number := v_t - 1;
      RESULT(l_d).payment_number := l_d;
      RESULT(l_d).value := ret_sum;
      RESULT(l_d).ft := v_ft; --NULL;
      RESULT(l_d).ins_amount := p_ins_amount;
      RESULT(l_d).cv := NULL;
    
    END LOOP;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END family_dep_cash_surrender;
  /*
    Байтин А.
    Расчет выкупных сумм для продукта "Вклад в будущее (Инвестор) для ОАО Банк "Открытие""
    скопировано с единовременного
  */
  FUNCTION invest_in_future_cash
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
   ,p_p_cover_id        NUMBER
   ,p_ins_amount        NUMBER
  ) RETURN tbl_cash_surrender IS
    --
    CURSOR c_policy
    (
      p_policy_id  IN NUMBER
     ,p_p_cover_id IN NUMBER
    ) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date) / 12) period_year_fh
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
            ,p_cover         pc
       WHERE 1 = 1
         AND pp.policy_id = p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id
         AND pc.p_cover_id = p_p_cover_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    RESULT              tbl_cash_surrender;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    l_pause_start_date  DATE;
    l_pause_end_date    DATE;
    l_fh_year           NUMBER;
    v_product_brief     VARCHAR2(200);
    p_p_period_year     NUMBER;
  
    --
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
    PROCEDURE policyinfo
    (
      p_policy_header_id    IN NUMBER
     ,p_p_policy_id         IN NUMBER
     ,p_t_lob_line_id       IN NUMBER
     ,p_contact_id          IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_year_number         IN NUMBER
    ) IS
      l_id NUMBER;
    BEGIN
      log(p_p_policy_id, 'POLICYINFO YEAR_NUMBER (номер годовщины) ' || p_year_number);
    
      l_id := result.count + 1;
      RESULT(l_id).policy_header_id := p_policy_header_id;
      RESULT(l_id).policy_id := p_p_policy_id;
      RESULT(l_id).t_lob_line_id := p_t_lob_line_id;
      RESULT(l_id).contact_id := p_contact_id;
      RESULT(l_id).insurance_year_date := to_date(NULL);
      RESULT(l_id).start_cash_surr_date := p_start_schedule_date;
      RESULT(l_id).end_cash_surr_date := p_end_schedule_date;
      RESULT(l_id).insurance_year_number := p_year_number;
    
    END;
  
    PROCEDURE calc_one
    (
      p_n                   IN NUMBER
     ,p_t                   IN NUMBER
     ,p_start_schedule_date IN DATE
     ,p_end_schedule_date   IN DATE
     ,p_payment_num         IN NUMBER
    ) IS
      l_year_date      DATE;
      l_id             NUMBER;
      l_reserve_date_1 DATE;
      l_reserve_date_2 DATE;
      l_ft             NUMBER;
    
      l_tvs_1 NUMBER;
      l_tvs_2 NUMBER;
      l_s     NUMBER;
    
      l_k_1      NUMBER;
      l_k_2      NUMBER;
      l_tvs_comm NUMBER := 0;
    BEGIN
      log(p_p_policy_id, 'CALC_ONE ');
    
      log(p_p_policy_id
         ,'CALC_ONE n ' || p_n || ' t ' || p_t || 'START_DATE ' ||
          to_char(p_start_schedule_date, 'dd.mm.yyyy'));
    
      l_id := result.count;
    
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date_2 := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
      --Чирков изменил 309120: 1140308982 Пшеницын Денис Николаевич при переводе
      -- l_reserve_date_1 := ADD_MONTHS(l_reserve_date_2, -12);
      l_reserve_date_1 := ADD_MONTHS(g_header_start_date, 12 * p_t) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1, 1);
    
      /*l_tVS_1 := pkg_reserve_r_life.get_VS(RESULT             (l_id).policy_header_id
      ,RESULT             (l_id).policy_id
      ,RESULT             (l_id).t_lob_line_id
      ,p_p_asset_header_id
      ,l_reserve_date_1);*/
    
      l_tvs_2 := pkg_reserve_r_life.get_vs(RESULT             (l_id).policy_header_id
                                          ,RESULT             (l_id).policy_id
                                          ,RESULT             (l_id).t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,l_reserve_date_2);
    
      l_s  := pkg_reserve_r_life.get_ss(RESULT             (l_id).policy_header_id
                                       ,RESULT             (l_id).policy_id
                                       ,RESULT             (l_id).t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date_2 /*Get_year_date (l_year_date, 1)*/);
      l_ft := 0.60;
    
      RESULT(l_id).cv := l_tvs_2 * l_ft;
      RESULT(l_id).cv := ROUND(RESULT(l_id).cv, 6);
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
    END;
  
    PROCEDURE calc_every_year
    (
      p_header_start_date IN DATE
     ,p_n                 NUMBER
     ,p_t                 NUMBER
     ,p_payment_num       IN NUMBER
    ) IS
      l_year_date    DATE;
      l_reserve_date DATE;
      l_id           NUMBER;
      l_ft           NUMBER;
      l_vb           NUMBER;
      l_p            NUMBER;
      l_s            NUMBER;
      l_new_cover    NUMBER;
      p_type_reserve NUMBER;
    BEGIN
      l_id        := result.count;
      l_year_date := get_year_date(g_header_start_date, p_t);
    
      RESULT(l_id).insurance_year_date := l_year_date;
      l_reserve_date := ADD_MONTHS(g_header_start_date, 12 * (p_t + 1)) - 1;
    
      l_ft := ft(p_p_policy_id, p_p_cover_id, p_n, p_t + 1);
      --l_S := pkg_reserve_r_life.get_S (g_policy_header_id, p_p_policy_id, p_t_lob_line_id, p_p_asset_header_id, l_year_date /*Get_year_date (l_year_date, 1)*/);
    
      l_s := pkg_reserve_r_life.get_ss(g_policy_header_id
                                      ,p_p_policy_id
                                      ,p_t_lob_line_id
                                      ,p_p_asset_header_id
                                      ,l_reserve_date);
      --
      log(p_p_policy_id, 'Calc_EVERY_YEAR POLICY_HEADER_ID ' || g_policy_header_id);
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR T_LOB_LINE_ID ' || p_t_lob_line_id || ' ASSET_HEADER_ID ' ||
          p_p_asset_header_id || ' RESERVE_DATE ' || l_reserve_date);
    
      l_vb := pkg_reserve_r_life.get_vb(g_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,l_reserve_date);
      IF p_t = 0
      THEN
        l_vb := l_vb * 0.25;
      ELSIF p_t = 1
      THEN
        l_vb := l_vb * 0.5;
      ELSE
        l_vb := l_vb * 0.75;
      END IF;
    
      RESULT(l_id).cv := ROUND(l_ft * l_vb, 6);
    
      RESULT(l_id).ft := l_ft;
      RESULT(l_id).payment_number := p_payment_num;
      RESULT(l_id).ins_amount := l_s;
    
      log(p_p_policy_id
         ,'Calc_EVERY_YEAR i.num=' || r_schedule.schedule_num || ' reserve_date=' || l_reserve_date ||
          ' P=' || l_p || ' S ' || l_s || ' Ft=' || l_ft || ' t=' || p_t || ' n=' || p_n ||
          ' schedule_date=' || r_schedule.start_schedule_date || 'vB=' || l_vb || ' tCV=' || RESULT(l_id).cv);
    
    END;
  
  BEGIN
    --
    OPEN c_policy(p_p_policy_id, p_p_cover_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    SELECT tp.brief
      INTO v_product_brief
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    g_header_start_date := r_policy.header_start_date;
    g_policy_header_id  := r_policy.policy_header_id;
  
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER BRIEF ' || (v_brief) || ' policy_header_id ' || g_policy_header_id ||
        'version_num ' || r_policy.version_num);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER T_LOB_LINE_ID ' || p_t_lob_line_id || ' P_ASSET_HEADER_ID ' ||
        p_p_asset_header_id);
    log(p_p_policy_id
       ,'INV_CASH_SURRENDER START_DATE ' || to_char(v_start_date, 'dd.mm.yyyy') || ' period_year ' ||
        v_period_year);
  
    SELECT MAX(decline_date)
          ,MAX(start_date)
      INTO l_pause_start_date
          ,l_pause_end_date
      FROM p_cover pc
     START WITH p_cover_id = p_p_cover_id
    CONNECT BY PRIOR source_cover_id = p_cover_id;
  
    l_fh_year := MONTHS_BETWEEN(trunc(l_pause_end_date), trunc(l_pause_start_date)) / 12;
  
    p_p_period_year := r_policy.period_year;
    IF nvl(l_fh_year, 0) > 0
    THEN
      p_p_period_year := r_policy.period_year_fh - ROUND(l_fh_year, 0);
    END IF;
  
    FOR r_schedule IN c_schedule(v_brief, r_policy.start_date, r_policy.period_year)
    LOOP
    
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12);
    
      policyinfo(g_policy_header_id
                ,p_p_policy_id
                ,p_t_lob_line_id
                ,p_contact_id
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,v_t);
    
      log(p_p_policy_id
         ,'INV_CASH_SURRENDER t ' || v_t || ' PERIOD ' ||
          to_char(r_schedule.start_schedule_date, 'dd.mm.yyyy') || ' -- ' ||
          to_char(r_schedule.end_schedule_date, 'dd.mm.yyyy'));
    
      IF v_brief = 'EVERY_YEAR'
      THEN
        /*Расчет выкупной суммы при ежегодном взносе*/
        calc_every_year(g_header_start_date, r_policy.period_year, v_t, r_schedule.schedule_num);
      ELSIF v_brief = 'Единовременно'
      THEN
        /*Расчет выкупной суммы при единовременном взносе*/
        calc_one(r_policy.period_year
                ,v_t
                ,r_schedule.start_schedule_date
                ,r_schedule.end_schedule_date
                ,r_schedule.schedule_num);
      END IF;
    
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
    
      IF RESULT(result.count).cv < 0
      THEN
        RESULT(result.count).cv := 0;
      END IF;
    
      /* Покрытие временно отключалось. В настоящий момент такая ситуация возникает при включении услуги финансовые каникулы
        Необходимо проверить, с учетом дейтсвия ранее программы, какая полная годовщина в настоящий момент у программы.
        Если это 1 или 2 годовщина - выкупная сумма будет 0
      */
      IF v_t - l_fh_year < 2
      THEN
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER С учетом действия FH сейчас 1 или 2 годовщина. Выкупная сумма равна 0 ');
        RESULT(result.count).cv := 0;
      END IF;
    
      RESULT(result.count).value := RESULT(result.count).cv * RESULT(result.count).ins_amount;
    
      IF RESULT(result.count).cv IS NULL
          OR RESULT(result.count).value IS NULL
      THEN
        result.delete(result.count);
        log(p_p_policy_id
           ,'INV_CASH_SURRENDER Внимание. Выкупная сумма не расчитана.');
        EXIT;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END invest_in_future_cash;

  -- Author  : ILYA.SLEZIN
  -- Created : 31.07.2009
  -- Purpose : Расчет выкупных сумм для продукта Страховой депозит (INS_DEP) (скопировано с SF_Cash_Surrender)
  FUNCTION ins_dep_cash_surrender
  (
    p_p_policy_id IN NUMBER
   ,p_start_date  IN DATE
   ,p_ins_amount  NUMBER
   ,p_ins_fee     NUMBER
  ) RETURN tbl_cash_surrender IS
    RESULT        tbl_cash_surrender;
    proc_name     VARCHAR2(25) := 'INS_DEP_Cash_Surrender';
    v_period_year NUMBER;
    v_t           NUMBER;
    l_d           PLS_INTEGER;
    ret_sum       NUMBER;
    CURSOR c_schedule
    (
      p_brief       IN VARCHAR2
     ,p_start_date  IN DATE
     ,p_period_year IN NUMBER
    ) IS
      SELECT schedule_num
            ,start_schedule_date
            ,end_schedule_date
        FROM TABLE(pkg_policy_cash_surrender.get_schedule(p_p_policy_id
                                                         ,p_brief
                                                         ,p_start_date
                                                         ,p_period_year));
  
    r_schedule c_schedule%ROWTYPE;
  
  BEGIN
    SELECT ph.start_date header_start_date
          ,trunc(MONTHS_BETWEEN(pp.end_date + 1, p_start_date) / 12) period_year
      INTO g_header_start_date
          ,v_period_year
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE 1 = 1
       AND pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    FOR r_schedule IN c_schedule('Единовременно', g_header_start_date, v_period_year)
    LOOP
      l_d := result.count + 1;
      v_t := FLOOR(MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12) + 1;
    
      IF v_t = (MONTHS_BETWEEN(r_schedule.start_schedule_date, g_header_start_date) / 12) + 1
      THEN
        CASE
          WHEN v_period_year = 3
               AND v_t = 1 THEN
            ret_sum := 0.9 * p_ins_fee;
          WHEN v_period_year = 3
               AND v_t BETWEEN 2 AND 3 THEN
            ret_sum := p_ins_fee;
          WHEN v_period_year = 5
               AND v_t BETWEEN 1 AND 2 THEN
            ret_sum := 0.9 * p_ins_fee;
          WHEN v_period_year = 5
               AND v_t BETWEEN 3 AND 5 THEN
            ret_sum := p_ins_fee;
        END CASE;
        RESULT(l_d).insurance_year_date := ADD_MONTHS(g_header_start_date, v_t * 12);
        RESULT(l_d).start_cash_surr_date := r_schedule.start_schedule_date;
        RESULT(l_d).end_cash_surr_date := r_schedule.end_schedule_date;
        RESULT(l_d).is_history := 0;
        RESULT(l_d).insurance_year_number := v_t - 1;
        RESULT(l_d).payment_number := l_d;
        RESULT(l_d).value := ret_sum;
        RESULT(l_d).ft := NULL;
        RESULT(l_d).ins_amount := p_ins_amount;
        RESULT(l_d).cv := NULL;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END ins_dep_cash_surrender;

  /**
  *  @Author Marchuk A.
  * Расчет значений выкупной суммы на дату годовщин по ИД версии договора
  * @param p_policy_id ID версии полиса
  */

  PROCEDURE calc_cash_surrender(p_p_policy_id IN NUMBER) IS
    v_policy_cash_surr_id   NUMBER;
    v_p_policy_id           NUMBER;
    v_contact_id            NUMBER;
    v_cover_id              NUMBER;
    v_p_asset_header_id     NUMBER;
    v_t_lob_line_id         NUMBER;
    v_t_pepr_invest_reserve NUMBER := 0;
    l_ent_id                NUMBER;
    RESULT                  tbl_cash_surrender;
    t_insert                tbl_dest;
    t_insert_clear          tbl_dest;
  
  BEGIN
    log(p_p_policy_id, 'ENTER CALC_CASH_SURRENDER ');
    SELECT ent_id INTO l_ent_id FROM entity WHERE brief = 'POLICY_CASH_SURR_D';
  
    IF NOT
        pkg_tariff_calc.calc_fun('Cash_Surrender_Valid', ent.id_by_brief('P_POLICY'), p_p_policy_id) = 1
    THEN
      RETURN;
    END IF;
  
    /* Байтин А.
       Перенес удаление записей, чтобы не выполнялось каждый раз,
       т.к. в групповых договорах это очень долго работает
    */
    drop_cash_surrender(p_p_policy_id);
  
    FOR c_policy IN (SELECT ph.policy_header_id
                           ,aa.p_policy_id
                           ,pc.p_cover_id
                           ,aa.contact_id
                           ,aa.p_asset_header_id
                           ,ll.t_lob_line_id
                           ,ll.brief
                           ,ll.description
                           ,pc.fee
                           ,pc.ins_amount
                           ,pc.start_date
                           ,pc.end_date
                           ,tp.brief product
                           ,(SELECT SUM(pc2.fee)
                               FROM t_lob_line         ll2
                                   ,t_product_line     pl2
                                   ,t_prod_line_option plo2
                                   ,p_cover            pc2
                                   ,ven_status_hist    sh2
                                   ,as_asset           aa2
                              WHERE 1 = 1
                                AND aa2.p_policy_id = p_p_policy_id
                                AND pc2.as_asset_id = aa2.as_asset_id
                                AND sh2.status_hist_id = pc2.status_hist_id
                                AND sh2.brief != 'DELETED'
                                AND plo2.id = pc2.t_prod_line_option_id
                                AND pl2.id = plo2.product_line_id
                                AND ll2.t_lob_line_id = pl2.t_lob_line_id
                                AND ll2.description <> 'Административные издержки') sum_fee
                           ,pl.id pl_id
                       FROM t_lob_line         ll
                           ,t_product_line     pl
                           ,t_prod_line_option plo
                           ,p_cover            pc
                           ,ven_status_hist    sh
                           ,as_assured         aas
                           ,p_pol_header       ph
                           ,p_policy           pp
                           ,as_asset           aa
                           ,t_product          tp
                      WHERE 1 = 1
                        AND aa.p_policy_id = p_p_policy_id
                        AND pp.policy_id = p_p_policy_id
                        AND tp.product_id = ph.product_id
                        AND ph.policy_header_id = pp.pol_header_id
                        AND aas.as_assured_id = aa.as_asset_id
                        AND pc.as_asset_id = aa.as_asset_id
                        AND sh.status_hist_id = pc.status_hist_id
                        AND sh.brief != 'DELETED'
                        AND plo.id = pc.t_prod_line_option_id
                        AND pl.id = plo.product_line_id
                        AND ll.t_lob_line_id = pl.t_lob_line_id)
    LOOP
    
      --Drop_Cash_Surrender(c_policy.p_policy_id, c_policy.contact_id, c_policy.t_lob_line_id);
    
      v_p_policy_id       := c_policy.p_policy_id;
      v_p_asset_header_id := c_policy.p_asset_header_id;
      v_t_lob_line_id     := c_policy.t_lob_line_id;
      v_contact_id        := c_policy.contact_id;
      v_cover_id          := c_policy.p_cover_id;
    
      IF c_policy.product = 'SF_Plus'
      THEN
        g_brief := 'SF_Plus';
      ELSIF c_policy.product = 'INS_DEP'
      THEN
        g_brief := 'INS_DEP';
      ELSIF c_policy.product = 'Family_Dep'
      THEN
        g_brief := 'Family_Dep';
      ELSIF c_policy.product = 'Family_Dep_2011'
      THEN
        g_brief := 'Family_Dep';
      ELSIF c_policy.product = 'Family_Dep_2014'
      THEN
        g_brief := 'Family_Dep';
      ELSE
        g_brief := c_policy.brief;
      END IF;
    
      log(p_p_policy_id, 'ENTER CALC_CASH_SURRENDER BRIEF ' || g_brief);
      --
      dml_policy_cash_surr.insert_record(par_pol_header_id       => c_policy.policy_header_id
                                        ,par_policy_id           => c_policy.p_policy_id
                                        ,par_t_lob_line_id       => c_policy.t_lob_line_id
                                        ,par_contact_id          => c_policy.contact_id
                                        ,par_p_cover_id          => c_policy.p_cover_id
                                        ,par_policy_cash_surr_id => v_policy_cash_surr_id);
    
      t_insert.delete;
      result.delete;
    
      IF g_brief = 'END'
      THEN
        RESULT := end_cash_surrender(v_p_policy_id
                                    ,v_contact_id
                                    ,v_p_asset_header_id
                                    ,v_t_lob_line_id
                                    ,c_policy.start_date
                                    ,c_policy.end_date
                                    ,c_policy.p_cover_id
                                    ,c_policy.ins_amount
                                    ,c_policy.product = 'Dostoyanie');
      
      ELSIF g_brief = 'PEPR_INVEST_RESERVE'
      THEN
        RESULT := invreserve_cash_surrender(v_p_policy_id
                                           ,v_contact_id
                                           ,v_p_asset_header_id
                                           ,v_t_lob_line_id
                                           ,c_policy.start_date
                                           ,c_policy.end_date
                                           ,c_policy.p_cover_id
                                           ,c_policy.ins_amount
                                           ,c_policy.pl_id);
      ELSIF g_brief = 'PEPR'
      THEN
      
        RESULT := end_cash_surrender(v_p_policy_id
                                    ,v_contact_id
                                    ,v_p_asset_header_id
                                    ,v_t_lob_line_id
                                    ,c_policy.start_date
                                    ,c_policy.end_date
                                    ,c_policy.p_cover_id
                                    ,c_policy.ins_amount);
      
      ELSIF g_brief IN ('INVEST2', 'INVEST')
      THEN
      
        RESULT := inv2_cash_surrender(v_p_policy_id
                                     ,v_contact_id
                                     ,v_p_asset_header_id
                                     ,v_t_lob_line_id
                                     ,c_policy.start_date
                                     ,c_policy.end_date
                                     ,c_policy.p_cover_id
                                     ,c_policy.ins_amount);
      
      ELSIF g_brief = 'SF_Plus'
            AND c_policy.description <> 'Административные издержки'
      THEN
        RESULT := sf_cash_surrender(v_p_policy_id
                                   ,c_policy.start_date
                                   ,c_policy.ins_amount
                                   ,c_policy.fee);
      
      ELSIF g_brief = 'INS_DEP'
            AND c_policy.brief = 'PEPR'
      THEN
        RESULT := ins_dep_cash_surrender(v_p_policy_id
                                        ,c_policy.start_date
                                        ,c_policy.ins_amount
                                        ,c_policy.sum_fee);
      
      ELSIF g_brief = 'Family_Dep'
            AND c_policy.brief = 'END'
      THEN
        RESULT := family_dep_cash_surrender(v_p_policy_id, c_policy.start_date, c_policy.ins_amount);
        -- Байтин А.
        -- Вернул инвестор назад, т.к. по нему вообще ничего не считалось.
      ELSIF (upper(g_brief) = 'PEPR_C' OR upper(g_brief) = 'PEPR_B' OR upper(g_brief) = 'PEPR_A')
            AND (upper(c_policy.product) = 'INVESTOR' OR upper(c_policy.product) = 'INVESTORALFA')
      THEN
        /*Изменения ALFA*/
        RESULT := investor_cash_surrender(v_p_policy_id
                                         ,v_contact_id
                                         ,v_p_asset_header_id
                                         ,v_t_lob_line_id
                                         ,c_policy.start_date
                                         ,c_policy.end_date
                                         ,c_policy.p_cover_id
                                         ,c_policy.ins_amount);
      ELSIF upper(g_brief) IN ('PEPR_A_PLUS', 'PEPR_B', 'PEPR_A')
            AND
            pkg_product_category.is_product_in_category(par_product_brief       => c_policy.product
                                                       ,par_category_type_brief => 'POLICY_CASH_SURR_CALC_ALG'
                                                       ,par_category_brief      => 'INVESTOR_LUMP')
      --('INVESTOR_LUMP', 'INVESTOR_LUMP_OLD', 'INVESTOR_LUMP_CALL_CENTRE', 'INVESTOR_LUMP_ALPHA')
      THEN
        RESULT := investor_lump_cash(v_p_policy_id
                                    ,v_contact_id
                                    ,v_p_asset_header_id
                                    ,v_t_lob_line_id
                                    ,c_policy.start_date
                                    ,c_policy.end_date
                                    ,c_policy.p_cover_id
                                    ,c_policy.ins_amount);
      ELSIF upper(g_brief) IN ('PEPR_A_PLUS', 'PEPR_B', 'PEPR_A')
            AND
            pkg_product_category.is_product_in_category(par_product_brief       => c_policy.product
                                                       ,par_category_type_brief => 'POLICY_CASH_SURR_CALC_ALG'
                                                       ,par_category_brief      => 'INVESTOR_LUMP2')
      THEN
        RESULT := investor_lump_cash2(v_p_policy_id
                                     ,v_contact_id
                                     ,v_p_asset_header_id
                                     ,v_t_lob_line_id
                                     ,c_policy.p_cover_id);
      
      ELSIF upper(g_brief) IN ('PEPR_A_PLUS', 'PEPR_B', 'PEPR_A')
            AND upper(c_policy.product) = 'INVEST_IN_FUTURE'
      THEN
        RESULT := invest_in_future_cash(v_p_policy_id
                                       ,v_contact_id
                                       ,v_p_asset_header_id
                                       ,v_t_lob_line_id
                                       ,c_policy.start_date
                                       ,c_policy.end_date
                                       ,c_policy.p_cover_id
                                       ,c_policy.ins_amount);
        --Чирков 189210 Настройка продукта - Банк Сбережений и кредита
      ELSIF upper(g_brief) IN ('PEPR_A_PLUS', 'PEPR_B', 'PEPR_A')
            AND upper(c_policy.product) = 'PRIORITY_INVEST(LUMP)'
      THEN
        RESULT := invest_priority_lump_cash(v_p_policy_id
                                           ,v_contact_id
                                           ,v_p_asset_header_id
                                           ,v_t_lob_line_id
                                           ,c_policy.start_date
                                           ,c_policy.end_date
                                           ,c_policy.p_cover_id
                                           ,c_policy.ins_amount);
      ELSIF upper(g_brief) IN ('OIL', 'GOLD')
            AND upper(c_policy.product) = 'INVESTORPLUS'
      THEN
        RESULT := investor_plus(v_p_policy_id
                               ,v_contact_id
                               ,v_p_asset_header_id
                               ,v_t_lob_line_id
                               ,c_policy.start_date
                               ,c_policy.end_date
                               ,c_policy.p_cover_id
                               ,c_policy.ins_amount);
      ELSIF upper(g_brief) IN ('PEPR_C', 'PEPR_B', 'PEPR_A')
            AND upper(c_policy.product) = 'PRIORITY_INVEST(REGULAR)'
      THEN
        RESULT := invest_priority_reg_cash(v_p_policy_id
                                          ,v_contact_id
                                          ,v_p_asset_header_id
                                          ,v_t_lob_line_id
                                          ,c_policy.start_date
                                          ,c_policy.end_date
                                          ,c_policy.p_cover_id
                                          ,c_policy.ins_amount);
        --end_Чирков
      
      ELSIF g_brief = 'Ins_life_to_date'
            AND pkg_product_category.is_product_in_category(par_product_brief       => c_policy.product
                                                           ,par_category_type_brief => 'POLICY_CASH_SURR_CALC_ALG'
                                                           ,par_category_brief      => 'NASLEDIE')
      THEN
        RESULT := nasledie_cash(v_p_policy_id
                               ,v_contact_id
                               ,v_p_asset_header_id
                               ,v_t_lob_line_id
                               ,c_policy.p_cover_id);
      
      END IF;
    
      FOR i IN 1 .. result.count
      LOOP
        SELECT sq_policy_cash_surr_d.nextval INTO t_insert(i).policy_cash_surr_d_id FROM dual;
        t_insert(i).ent_id := l_ent_id;
        t_insert(i).policy_cash_surr_id := v_policy_cash_surr_id;
      
        t_insert(i).insurance_year_date := RESULT(i).insurance_year_date;
        t_insert(i).start_cash_surr_date := RESULT(i).start_cash_surr_date;
        t_insert(i).end_cash_surr_date := RESULT(i).end_cash_surr_date;
        -- В расчетах мы отталкивались от полной годовщины. В БД записываем текущий год
        IF RESULT(i).is_history = 1
        THEN
          t_insert(i).insurance_year_number := RESULT(i).insurance_year_number;
        ELSE
          t_insert(i).insurance_year_number := RESULT(i).insurance_year_number + 1;
        END IF;
        t_insert(i).payment_number := RESULT(i).payment_number;
        t_insert(i).value := RESULT(i).value;
        t_insert(i).ft := RESULT(i).ft;
        t_insert(i).ins_amount := RESULT(i).ins_amount;
        t_insert(i).cv := RESULT(i).cv;
        t_insert(i).reserve_value := RESULT(i).reserve_value;
      
        IF t_insert(i).value IS NULL
        THEN
          log(p_p_policy_id
             ,'ENTER CALC_CASH_SURRENDER ' || to_char(t_insert(i).start_cash_surr_date, 'dd.mm.yyyy') ||
              ' VALUE IS NULL ');
        END IF;
      END LOOP;
    
      FORALL i IN result.first .. result.last
        INSERT INTO policy_cash_surr_d VALUES t_insert (i);
    
    END LOOP;
  
    DELETE FROM policy_cash_surr a
     WHERE policy_id = v_p_policy_id
       AND NOT EXISTS
     (SELECT 1 FROM policy_cash_surr_d b WHERE b.policy_cash_surr_id = a.policy_cash_surr_id);
  
  END;

  /**
  *  @Author Marchuk A.
  * Удаление значений выкупной суммы на дату годовщин по ИД версии договора
  * @param p_policy_id ID версии полиса
  */

  PROCEDURE drop_cash_surrender
  (
    p_p_policy_id   IN NUMBER
   ,p_contact_id    IN NUMBER
   ,p_t_lob_line_id IN NUMBER
  ) IS
    CURSOR c_lock IS
      SELECT policy_cash_surr_id
        FROM ven_policy_cash_surr cs
       WHERE 1 = 1
         AND cs.policy_id = p_p_policy_id
         AND cs.contact_id = p_contact_id
         AND cs.t_lob_line_id = p_t_lob_line_id
         FOR UPDATE NOWAIT;
  BEGIN
  
    IF utils.get_null('new_policy_version', 0) = 1
    THEN
      RETURN;
    END IF;
    BEGIN
      OPEN c_lock;
      CLOSE c_lock;
    END;
  
    DELETE FROM ven_policy_cash_surr cs
     WHERE 1 = 1
       AND cs.policy_id = p_p_policy_id
       AND cs.contact_id = p_contact_id
       AND cs.t_lob_line_id = p_t_lob_line_id;
  END;

  PROCEDURE drop_cash_surrender(p_p_policy_id IN NUMBER) IS
    CURSOR c_lock IS
      SELECT policy_cash_surr_id
        FROM ven_policy_cash_surr cs
       WHERE 1 = 1
         AND cs.policy_id = p_p_policy_id
         FOR UPDATE NOWAIT;
  BEGIN
  
    IF utils.get_null('new_policy_version', 0) = 1
    THEN
      RETURN;
    END IF;
    BEGIN
      OPEN c_lock;
      CLOSE c_lock;
    END;
  
    DELETE FROM /*ven_*/ policy_cash_surr cs
     WHERE 1 = 1
       AND cs.policy_id = p_p_policy_id;
  END;

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД версии полиса И ИД застрахованного
  * @param p_policy_id ID версии полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value
  (
    p_policy_id  IN NUMBER
   ,p_contact_id IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(cs_d.value) RESULT
      INTO RESULT
      FROM ven_policy_cash_surr_d cs_d
          ,ven_policy_cash_surr   cs
     WHERE 1 = 1
       AND cs.policy_id = p_policy_id
       AND cs.contact_id = p_contact_id
       AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
       AND p_date BETWEEN cs_d.start_cash_surr_date AND cs_d.end_cash_surr_date;
    RETURN RESULT;
  END;

  /*
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД версии полиса И ИД застрахованного и ИД страховой программы
  * @param p_policy_id ID версии полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_t_lob_line_id ИД страховой программы
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value
  (
    p_policy_id     IN NUMBER
   ,p_contact_id    IN NUMBER
   ,p_t_lob_line_id IN NUMBER
   ,p_date          IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(cs_d.value) RESULT
      INTO RESULT
      FROM ven_policy_cash_surr_d cs_d
          ,ven_policy_cash_surr   cs
     WHERE 1 = 1
       AND cs.policy_id = p_policy_id
       AND cs.contact_id = p_contact_id
       AND cs.t_lob_line_id = p_t_lob_line_id
       AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
       AND p_date BETWEEN cs_d.start_cash_surr_date AND cs_d.end_cash_surr_date;
    RETURN RESULT;
  END;

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД покрытия
  * @param p_policy_id ID версии полиса
  * @param p_p_cover_id ИД страхового покрытия
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value_c
  (
    p_p_cover_id IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
    CURSOR c_value IS
    
      SELECT start_cash_surr_date
            ,cs_d.value
        FROM ven_policy_cash_surr_d cs_d
            ,ven_policy_cash_surr   cs
            ,ven_t_lob_line         ll
            ,ven_t_product_line     pl
            ,ven_t_prod_line_option plo
            ,ven_p_policy           pp
            ,ven_as_assured         aa
            ,ven_p_cover            pc
       WHERE 1 = 1
         AND pc.p_cover_id = p_p_cover_id
         AND aa.as_assured_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND cs.policy_id = pp.policy_id
         AND cs.contact_id = aa.assured_contact_id
         AND cs.t_lob_line_id = ll.t_lob_line_id
         AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
         AND p_date > cs_d.start_cash_surr_date
       ORDER BY cs_d.start_cash_surr_date DESC;
  
  BEGIN
    log(p_p_cover_id, 'GET_VALUE_C');
    /* олучаем выкупную сумму на начало периода, в который попадает дата */
    FOR cur IN c_value
    LOOP
      RESULT := cur.value;
      EXIT;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_value_c_mine
  (
    p_p_cover_id IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(cs_d.value) RESULT
      INTO RESULT
      FROM ven_policy_cash_surr_d cs_d
          ,ven_policy_cash_surr   cs
          ,ven_t_lob_line         ll
          ,ven_t_product_line     pl
          ,ven_t_prod_line_option plo
          ,ven_p_policy           pp
          ,ven_as_assured         aa
          ,ven_p_cover            pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND plo.id = pc.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND cs.policy_id = pp.policy_id
          --AND cs.contact_id = aa.assured_contact_id
       AND cs.t_lob_line_id = ll.t_lob_line_id
       AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
       AND p_date - 1 BETWEEN cs_d.start_cash_surr_date AND cs_d.end_cash_surr_date;
    RETURN RESULT;
  END;
  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД полиса И ИД застрахованного
  * @param p_policy_header_id ID полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value_h
  (
    p_policy_header_id IN NUMBER
   ,p_contact_id       IN NUMBER
   ,p_date             IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(cs_d.value) RESULT
      INTO RESULT
      FROM ven_policy_cash_surr_d cs_d
          ,ven_policy_cash_surr   cs
          ,ven_p_pol_header       ph
     WHERE 1 = 1
       AND ph.policy_header_id = p_policy_header_id
       AND cs.policy_id = ph.policy_id
       AND cs.pol_header_id = ph.policy_header_id
       AND cs.contact_id = p_contact_id
       AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
       AND p_date BETWEEN cs_d.start_cash_surr_date AND cs_d.end_cash_surr_date;
    RETURN RESULT;
  END;

  /**
  *  @Author Marchuk A.
  * Получение значения выкупной суммы на дату в разрезе ИД полиса И ИД застрахованного и ИД страховой программы
  * @param p_policy_header_id ID полиса
  * @param p_contact_id id ЗАСТРАХОВАННОГО
  * @param p_t_lob_line_id ИД страховой программы
  * @param p_date дата получения выкупной суммы
  */

  FUNCTION get_value_h
  (
    p_policy_header_id IN NUMBER
   ,p_contact_id       IN NUMBER
   ,p_t_lob_line_id    IN NUMBER
   ,p_date             IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT SUM(cs_d.value) RESULT
      INTO RESULT
      FROM ven_policy_cash_surr_d cs_d
          ,ven_policy_cash_surr   cs
          ,ven_p_pol_header       ph
     WHERE 1 = 1
       AND ph.policy_header_id = p_policy_header_id
       AND cs.policy_id = ph.policy_id
       AND cs.pol_header_id = ph.policy_header_id
       AND cs.contact_id = p_contact_id
       AND cs.t_lob_line_id = p_t_lob_line_id
       AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
       AND p_date BETWEEN cs_d.start_cash_surr_date AND cs_d.end_cash_surr_date;
    RETURN RESULT;
  END;

END;
/
