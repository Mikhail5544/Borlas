CREATE OR REPLACE PACKAGE pkg_policy_cash_surrender IS
  /**
  * Алгоритмы для вариантов страхования жизни
  * @author Ivanov D.
  * @version Reserve For Life 1.1
  * @since 1.1
  * @headcom
  */

  TYPE r_schedule IS RECORD(
     schedule_num        NUMBER(4)
    ,start_schedule_date DATE
    ,end_schedule_date   DATE
    
    );

  TYPE tbl_schedule IS TABLE OF r_schedule;
  --
  --
  TYPE r_cash_surrender_value IS RECORD(
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
    ,VALUE                 NUMBER);

  TYPE tbl_cash_surrender_value IS TABLE OF r_cash_surrender_value INDEX BY BINARY_INTEGER;
  --

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
  /**
  *  @Author Marchuk A.
  * Функция расчета выкупных сумм по программе "Дожитие с возвратом взносов в случае смерти"
  * и "Смешанное страхование жизни"
  * @param p_policy_id ИД версии договора
  * @param p_contact_id ИД застрахованного (справочник контактов)
  * @param p_t_lob_line_id ИД страховой программы
  */

  FUNCTION end_get_cash_surrender_value
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
  ) RETURN tbl_cash_surrender_value;

  /**
  *  @Author Marchuk A.
  * Функция расчета выкупных сумм по программе "ИНВЕСТ2"
  * @param p_policy_id ИД версии договора
  * @param p_contact_id ИД застрахованного (справочник контактов)
  * @param p_t_lob_line_id ИД страховой программы
  */

  FUNCTION inv2_get_cash_surrender_value
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
  ) RETURN tbl_cash_surrender_value;
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
CREATE OR REPLACE PACKAGE BODY pkg_policy_cash_surrender AS

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
    v_policy_end_date        DATE;
    RESULT                   r_schedule;
    p_per_year               NUMBER;
    p_doc_status             NUMBER;
    p_version_start_date     DATE;
    p_header_start_date      DATE;
    p_start_date_decl        DATE;
    p_date_start_used        DATE;
    p_inv_lump               NUMBER := 0;
    v_product_brief          t_product.brief%TYPE;
  BEGIN
  
    p_date_start_used := p_start_date;
  
    /*begin
     select count(*)
     into p_inv_lump
     from p_policy pol,
          p_pol_header ph,
          t_product prod
     where pol.policy_id = p_p_policy_id
           and pol.pol_header_id = ph.policy_header_id
           and prod.product_id = ph.product_id
           and prod.brief = 'INVESTOR_LUMP';
    end;*/
  
    BEGIN
      SELECT decode(doc.get_doc_status_brief(p.policy_id, to_date('31.12.2999', 'dd.mm.yyyy'))
                   ,'RECOVER'
                   ,1
                   ,0)
            ,p.start_date
            ,ph.start_date
            ,prod.brief
        INTO p_doc_status
            ,p_version_start_date
            ,p_header_start_date
            ,v_product_brief
        FROM p_policy     p
            ,p_pol_header ph
            ,t_product    prod
       WHERE p.policy_id = p_p_policy_id
         AND ph.policy_header_id = p.pol_header_id
         AND prod.product_id = ph.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_doc_status         := 0;
        p_version_start_date := p_start_date;
        p_header_start_date  := p_start_date;
    END;
  
    IF p_doc_status >= 1
       AND (v_product_brief NOT IN ('Family_Dep', 'Family_Dep_2011', 'Family_Dep_2014'))
    THEN
    
      /*if to_char(p_version_start_date,'dd.mm') <> to_char(p_header_start_date,'dd.mm') then
      
       if to_char(ADD_MONTHS(p_version_start_date,3),'dd.mm') = to_char(p_header_start_date,'dd.mm') then
           v_schedule_num := 1;
      
           result.schedule_num := v_schedule_num;
           result.start_schedule_date := p_date_start_used\*p_start_date*\;
           result.end_schedule_date := ADD_MONTHS(v_year_date , 3) -1;
           pipe ROW (result);
       elsif to_char(ADD_MONTHS(p_version_start_date,6),'dd.mm') = to_char(p_header_start_date,'dd.mm') then
      
       elsif to_char(ADD_MONTHS(p_version_start_date,9),'dd.mm') = to_char(p_header_start_date,'dd.mm') then
      
       else
      
      end if;*/
    
      BEGIN
        SELECT pp.start_date
          INTO p_start_date_decl
          FROM p_policy     p
              ,p_pol_header ph
              ,p_policy     pp
         WHERE p.policy_id = p_p_policy_id
           AND ph.policy_header_id = p.pol_header_id
           AND pp.pol_header_id = ph.policy_header_id
           AND pp.version_num = p.version_num - 2;
      EXCEPTION
        WHEN no_data_found THEN
          p_start_date_decl := to_date('01.01.1900', 'dd.mm.yyyy');
      END;
    
      IF p_start_date_decl = to_date('01.01.1900', 'dd.mm.yyyy')
      THEN
        NULL;
      ELSE
        p_date_start_used := p_start_date_decl;
      END IF;
    END IF;
  
    IF (p_brief = 'Единовременно' OR p_brief = 'EVERY_QUARTER')
       AND /*p_inv_lump = 0*/
       NOT pkg_product_category.is_product_in_category(par_product_brief       => v_product_brief
                                                      ,par_category_type_brief => 'PROD_WITH_SPEC_SCHED_SURR_VAL'
                                                      ,par_category_brief      => 'EVERY_YEAR')
      THEN v_end_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * p_year);
    
      FOR j IN 1 .. p_year
      LOOP
        v_year_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (j - 1));
        IF j = 1
        THEN
          v_schedule_num := 1;
        
          result.schedule_num        := v_schedule_num;
          result.start_schedule_date := p_date_start_used /*p_start_date*/
           ;
          result.end_schedule_date   := ADD_MONTHS(v_year_date, 3) - 1;
          PIPE ROW(RESULT);
        ELSE
          v_schedule_num := v_schedule_num + 1;
        
          result.schedule_num        := v_schedule_num;
          result.start_schedule_date := ADD_MONTHS(v_year_date, 0);
          result.end_schedule_date   := ADD_MONTHS(v_year_date, 3) - 1; --ADD_MONTHS(result.start_schedule_date, 3) - 1;
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
        result.end_schedule_date   := ADD_MONTHS(v_year_date, 6) - 1; --ADD_MONTHS(result.start_schedule_date, 3) - 1;
      
        PIPE ROW(RESULT);
      
        --    Третий квартал
        v_schedule_num             := v_schedule_num + 1;
        result.schedule_num        := v_schedule_num;
        result.start_schedule_date := ADD_MONTHS(v_year_date, 6);
        result.end_schedule_date   := ADD_MONTHS(v_year_date, 9) - 1; --ADD_MONTHS(result.start_schedule_date, 3) - 1;
      
        PIPE ROW(RESULT);
      
        --    Четвертый квартал
        v_schedule_num             := v_schedule_num + 1;
        result.schedule_num        := v_schedule_num;
        result.start_schedule_date := ADD_MONTHS(v_year_date, 9);
        result.end_schedule_date   := ADD_MONTHS(v_year_date, 12) - 1; --ADD_MONTHS(result.start_schedule_date, 3) - 1;
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'Единовременно'
          AND /*p_inv_lump > 0*/
          pkg_product_category.is_product_in_category(par_product_brief       => v_product_brief
                                                     ,par_category_type_brief => 'PROD_WITH_SPEC_SCHED_SURR_VAL'
                                                     ,par_category_brief      => 'EVERY_YEAR')
    THEN
      FOR j IN 1 .. (p_year)
      LOOP
      
        result.schedule_num        := j;
        result.start_schedule_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (j - 1));
        IF j = (p_year + 1)
        THEN
          result.end_schedule_date := result.start_schedule_date;
        ELSE
          result.end_schedule_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (j)) - 1;
        END IF;
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'EVERY_YEAR'
    THEN
    
      FOR j IN 1 .. (p_year)
      LOOP
      
        result.schedule_num        := j;
        result.start_schedule_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (j - 1));
        IF j = (p_year + 1)
        THEN
          result.end_schedule_date := result.start_schedule_date;
        ELSE
          result.end_schedule_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (j)) - 1;
        END IF;
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'HALF_YEAR'
    THEN
    
      FOR j IN 1 .. (p_year)
      LOOP
      
        result.schedule_num        := j;
        result.start_schedule_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (j - 1));
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 6) - 1;
      
        PIPE ROW(RESULT);
      
        result.start_schedule_date := result.end_schedule_date + 1;
        result.end_schedule_date   := ADD_MONTHS(result.start_schedule_date, 6) - 1;
      
        PIPE ROW(RESULT);
      
      END LOOP;
    ELSIF p_brief = 'MONTHLY'
    THEN
    
      SELECT trunc(MONTHS_BETWEEN(pp.start_date, ph.start_date) / 12) period_year
            ,pp.end_date
        INTO p_per_year
            ,v_policy_end_date
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE 1 = 1
         AND pp.policy_id = p_p_policy_id
         AND ph.policy_header_id = pp.pol_header_id;
    
      v_end_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (p_year - p_per_year)) - 1;
      FOR i IN /*(SELECT ROWNUM schedule_num, plan_date,  NVL (lead (plan_date - 1) OVER (ORDER BY plan_date), v_end_date)
                                                                                                          FROM (SELECT plan_date FROM v_policy_payment_schedule
                                                                                                         WHERE 1=1
                                                                                                           AND policy_id = p_p_policy_id ORDER BY grace_date)*/
       (SELECT rownum schedule_num
              ,plan_date
              ,nvl(lead(plan_date - 1) over(ORDER BY plan_date)
                  ,least(ADD_MONTHS(plan_date, 1) - 1, v_policy_end_date) /*v_end_date*/)
          FROM (SELECT DISTINCT plan_date
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
                 ORDER BY /*grace_date*/ plan_date))
      LOOP
        PIPE ROW(i);
      END LOOP;
    ELSE
      v_end_date := ADD_MONTHS(p_date_start_used /*p_start_date*/, 12 * (p_year)) - 1;
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
  */

  FUNCTION ft
  (
    p_n IN NUMBER
   ,p_t IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := greatest(1 - 0.02 * (p_n - p_t), 0.8);
    RETURN RESULT;
  END;

  /**
  *  @Author Marchuk A.
  * ППроцедура сохранения выкупных сумм в БД сумм
  * @param resultset PL/SQL таблица с данными расчета
  */

  /**
  *  @Author Marchuk A.
  * Функция расчета выкупных сумм по программе "Дожитие с возвратом взносов в случае смерти"
  * и "Смешанное страхование жизни"
  * @param p_policy_id ИД версии договора
  * @param p_contact_id ИД застрахованного (справочник контактов)
  * @param p_t_lob_line_id ИД страховой программы
  */

  FUNCTION end_get_cash_surrender_value
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
  ) RETURN tbl_cash_surrender_value IS
    --
    CURSOR c_policy(v_policy_id IN NUMBER) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(p_end_date + 1, p_start_date) / 12) period_year
        FROM t_payment_terms pt
            ,p_pol_header    ph
            ,p_policy        pp
       WHERE 1 = 1
         AND pp.policy_id = v_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    CURSOR c_prev
    (
      p_policy_header_id IN NUMBER
     ,p_version_num      IN NUMBER
     ,p_start_date       IN DATE
    ) IS
      SELECT pp.pol_header_id
            ,pp.policy_id
            ,p_t_lob_line_id            t_lob_line_id
            ,p_contact_id               contact_id
            ,pc_d.start_cash_surr_date
            ,pc_d.end_cash_surr_date
            ,pc_d.insurance_year_number
            ,pc_d.insurance_year_date
            ,pc_d.value
        FROM policy_cash_surr_d pc_d
            ,policy_cash_surr pc
            ,(SELECT pp.policy_id
                    ,pp.pol_header_id
                    ,pp.version_num
                    ,pp.start_date
                    ,nvl((lead(pp.start_date)
                          over(PARTITION BY pp.pol_header_id ORDER BY pp.version_num) - 1)
                        ,trunc(pp.end_date)) end_date
                FROM p_policy     pp
                    ,p_pol_header ph
               WHERE 1 = 1
                 AND ph.policy_header_id = p_policy_header_id
                 AND pp.pol_header_id = ph.policy_header_id) pp
       WHERE 1 = 1
         AND pp.version_num < p_version_num
         AND pc.policy_id = pp.policy_id
         AND pc.t_lob_line_id = p_t_lob_line_id
         AND pc.contact_id = p_contact_id
         AND pc_d.policy_cash_surr_id = pc.policy_cash_surr_id
         AND pp.start_date < p_start_date
         AND pc_d.start_cash_surr_date BETWEEN trunc(pp.start_date) AND trunc(end_date)
       ORDER BY pc_d.start_cash_surr_date;
    --
    RESULT              tbl_cash_surrender_value;
    v_brief             VARCHAR2(200);
    v_start_date        DATE;
    v_header_start_date DATE;
    v_reserve_date      DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    v_n                 NUMBER;
    vb                  NUMBER;
    v_ft                NUMBER;
    v_d                 NUMBER;
    v_p                 NUMBER;
    v_y                 NUMBER;
    v_tv                NUMBER;
    v_t_v               NUMBER;
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
  BEGIN
    --
    OPEN c_policy(p_p_policy_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    v_header_start_date := r_policy.header_start_date;
    v_period_year       := r_policy.period_year;
    v_policy_header_id  := r_policy.policy_header_id;
    v_n                 := v_period_year;
    v_i                 := 0;
  
    --DBMS_OUTPUT.PUT_LINE (' v_brief='||(v_brief)||' v_policy_header_id '||v_policy_header_id||'version_num '||r_policy.version_num||' p_t_lob_line_id '||p_t_lob_line_id||' p_contact_id '||p_contact_id);
    --DBMS_OUTPUT.PUT_LINE (' v_start_date '||v_start_date||'v_header_start_date '||v_header_start_date||' v_period_year '||v_period_year);
    --
    FOR cur IN c_prev(v_policy_header_id, r_policy.version_num, v_start_date)
    LOOP
      IF cur.value IS NOT NULL
      THEN
        v_i := v_i + 1;
        --DBMS_OUTPUT.PUT_LINE (' Данные с предыдущей версии ...');
        RESULT(v_i).policy_header_id := cur.pol_header_id;
        RESULT(v_i).policy_id := cur.policy_id;
        RESULT(v_i).t_lob_line_id := cur.t_lob_line_id;
        RESULT(v_i).contact_id := cur.contact_id;
        RESULT(v_i).insurance_year_date := cur.insurance_year_date;
        RESULT(v_i).start_cash_surr_date := cur.start_cash_surr_date;
        RESULT(v_i).end_cash_surr_date := cur.end_cash_surr_date;
        RESULT(v_i).insurance_year_number := cur.insurance_year_number;
        RESULT(v_i).payment_number := NULL;
        RESULT(v_i).is_history := 1;
        RESULT(v_i).value := cur.value;
      END IF;
      --DBMS_OUTPUT.PUT_LINE ('start_cash_surr_date '||result(v_i).start_cash_surr_date||' end_cash_surr_date '||result(v_i).end_cash_surr_date||' '||result(v_i).VALUE);
    END LOOP;
  
    --DBMS_OUTPUT.PUT_LINE (' v_start_date '||v_start_date||' v_period_year '||v_period_year);
  
    OPEN c_schedule(v_brief, v_start_date, v_period_year);
    LOOP
      FETCH c_schedule
        INTO r_schedule;
      IF c_schedule%NOTFOUND
      THEN
        EXIT;
      END IF;
      v_i := v_i + 1;
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, v_header_start_date) / 12);
    
      RESULT(v_i).policy_header_id := v_policy_header_id;
      RESULT(v_i).policy_id := p_p_policy_id;
      RESULT(v_i).t_lob_line_id := p_t_lob_line_id;
      RESULT(v_i).contact_id := p_contact_id;
      RESULT(v_i).insurance_year_date := to_date(NULL);
      RESULT(v_i).start_cash_surr_date := r_schedule.start_schedule_date;
      RESULT(v_i).end_cash_surr_date := r_schedule.end_schedule_date;
      RESULT(v_i).insurance_year_number := v_t + 1;
      RESULT(v_i).payment_number := NULL;
      IF v_brief = 'EVERY_YEAR'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        --DBMS_OUTPUT.PUT_LINE ('v_policy_header_id '||v_policy_header_id||' p_p_policy_id '||p_p_policy_id||' p_t_lob_line_id '|| p_t_lob_line_id||' p_p_asset_header_id '||p_p_asset_header_id||' v_reserve_date '||v_reserve_date);
        IF v_t = 0
        THEN
          RESULT(v_i).value := 0;
        ELSIF v_t = 1
        THEN
          RESULT(v_i).value := 0;
        ELSE
          vb := pkg_reserve_r_life.get_vb(v_policy_header_id
                                         ,p_p_policy_id
                                         ,p_t_lob_line_id
                                         ,p_p_asset_header_id
                                         ,v_reserve_date);
          RESULT(v_i).value := ROUND(v_ft * vb, 6);
        END IF;
        --DBMS_OUTPUT.PUT_LINE (' i.num='||r_schedule.schedule_num||' v_reserve_date='||v_reserve_date||' v_P='||v_P||' v_Ft='||v_Ft||' v_t='||v_t||' v_n='||v_n||' schedule_date='||r_schedule.start_schedule_date||'vB='||vB||' tCV='||result(v_i).VALUE);
      ELSIF v_brief = 'Единовременно'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        v_tv := pkg_reserve_r_life.get_v(v_policy_header_id
                                        ,p_p_policy_id
                                        ,p_t_lob_line_id
                                        ,p_p_asset_header_id
                                        ,v_reserve_date);
        IF v_t = 0
        THEN
          v_t_v := 0;
        ELSE
          v_t_v := pkg_reserve_r_life.get_v(v_policy_header_id
                                           ,p_p_policy_id
                                           ,p_t_lob_line_id
                                           ,p_p_asset_header_id
                                           ,v_year_date - 1);
          --DBMS_OUTPUT.PUT_LINE (' v_t_V '||v_t_V ||' v_tV '||v_tV||' '||v_policy_header_id||' p_t_lob_line_id '|| p_t_lob_line_id||' p_p_asset_header_id '||p_p_asset_header_id||' '||v_reserve_date);
        END IF;
        v_y  := (r_schedule.start_schedule_date - v_year_date) / (v_reserve_date - v_year_date);
        v_y  := ROUND(v_y, 6);
        v_ft := ft(v_n, v_t + 1);
        IF r_schedule.start_schedule_date = v_header_start_date
        THEN
          RESULT(v_i).value := 0;
        ELSE
          RESULT(v_i).value := ROUND(v_ft * ((1 - v_y) * v_t_v + v_y * v_tv), 6);
        END IF;
        --DBMS_OUTPUT.PUT_LINE (' i.num='||r_schedule.schedule_num||' v_year_date '||v_year_date||' r_schedule.start_schedule_date='||r_schedule.start_schedule_date||'v_reserve_date='||v_reserve_date||' v_Ft='||v_Ft||' v_P='||v_P||' v_Y='||v_Y||' v_tV='||v_tV||' v_t_V='||v_t_V||' tCV '||result(v_i).VALUE);
      ELSIF v_brief = 'HALF_YEAR'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        --DBMS_OUTPUT.PUT_LINE ('v_policy_header_id '||v_policy_header_id||' p_p_policy_id '||p_p_policy_id||' p_t_lob_line_id '|| p_t_lob_line_id||' p_p_asset_header_id '||p_p_asset_header_id||' v_reserve_date '||v_reserve_date);
        IF v_t = 0
        THEN
          RESULT(v_i).value := 0;
        ELSIF v_t = 1
        THEN
          RESULT(v_i).value := 0;
        ELSE
          v_p := pkg_reserve_r_life.get_p(v_policy_header_id
                                         ,p_p_policy_id
                                         ,p_t_lob_line_id
                                         ,p_p_asset_header_id
                                         ,v_year_date);
        
          IF r_schedule.start_schedule_date = v_year_date
          THEN
            vb  := ROUND(pkg_reserve_r_life.get_vb(v_policy_header_id
                                                  ,p_p_policy_id
                                                  ,p_t_lob_line_id
                                                  ,p_p_asset_header_id
                                                  ,v_reserve_date)
                        ,6);
            v_d := v_p * (1 / 2);
          ELSE
            vb  := ROUND(pkg_reserve_r_life.get_vb(v_policy_header_id
                                                  ,p_p_policy_id
                                                  ,p_t_lob_line_id
                                                  ,p_p_asset_header_id
                                                  ,v_reserve_date)
                        ,6);
            v_d := 0;
          END IF;
        
          RESULT(v_i).value := ROUND(v_ft * (vb - v_d), 6);
        END IF;
        --DBMS_OUTPUT.PUT_LINE ('v_year_date '||v_year_date||' v_reserve_date '||v_reserve_date||' i.num '||r_schedule.schedule_num||' v_P '||v_P||' v_D '||v_D||' (VB-D)='||(vB - v_D)||' v_t '||v_t||' v_n '||v_n||'start_schedule_date '||r_schedule.start_schedule_date||'vB '||vB||' tCV '||result(v_i).VALUE||'v_Ft '||v_Ft);
      
      ELSIF v_brief = 'EVERY_QUARTER'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        --DBMS_OUTPUT.PUT_LINE ('v_policy_header_id '||v_policy_header_id||' p_p_policy_id '||p_p_policy_id||' p_t_lob_line_id '|| p_t_lob_line_id||' p_p_asset_header_id '||p_p_asset_header_id||' v_reserve_date '||v_reserve_date);
        IF v_t = 0
        THEN
          RESULT(v_i).value := 0;
        ELSIF v_t = 1
        THEN
          RESULT(v_i).value := 0;
        ELSE
          v_p := pkg_reserve_r_life.get_p(v_policy_header_id
                                         ,p_p_policy_id
                                         ,p_t_lob_line_id
                                         ,p_p_asset_header_id
                                         ,v_year_date);
          IF r_schedule.start_schedule_date = v_year_date
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 3 / 4;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 3)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 1 / 2;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 6)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 1 / 4;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 9)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := 0;
          END IF;
          RESULT(v_i).value := ROUND(v_ft * (vb - v_d), 6);
        END IF;
        --DBMS_OUTPUT.PUT_LINE (' i.num '||r_schedule.schedule_num||' v_P '||v_P||' v_D '||v_D||' (VB-D)='||(vB - v_D)||' v_t '||v_t||' v_n '||v_n||' schedule_date '||r_schedule.start_schedule_date||'vB '||vB||' tCV '||result(v_i).VALUE);
      ELSIF v_brief = 'MONTHLY'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        --DBMS_OUTPUT.PUT_LINE ('v_reserve_date '||v_reserve_date);
        IF v_t = 0
        THEN
          RESULT(v_i).value := 0;
        ELSIF v_t = 1
        THEN
          RESULT(v_i).value := 0;
        ELSE
          v_p := pkg_reserve_r_life.get_p(v_policy_header_id
                                         ,p_p_policy_id
                                         ,p_t_lob_line_id
                                         ,p_p_asset_header_id
                                         ,v_year_date);
          IF r_schedule.start_schedule_date = v_year_date
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,r_schedule.start_schedule_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 11 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 1)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 10 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 2)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 9 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 3)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 8 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 4)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 7 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 5)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 6 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 6)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 5 / 12;
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 7)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 4 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 8)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 3 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 9)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 2 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 10)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := v_p * 1 / 12;
            v_d := ROUND(v_d, 6);
          ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 11)
          THEN
            vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                            ,p_p_policy_id
                                            ,p_t_lob_line_id
                                            ,p_p_asset_header_id
                                            ,v_reserve_date);
            vb  := ROUND(vb, 6);
            v_d := 0;
          END IF;
          RESULT(v_i).value := ROUND(v_ft * (vb - v_d), 6);
        END IF;
        --DBMS_OUTPUT.PUT_LINE (' i.num '||r_schedule.schedule_num||' v_P '||v_P||' v_D '||v_D||' (VB-D)='||(vB - v_D)||' v_t '||v_t||' v_n '||v_n||' schedule_date '||r_schedule.start_schedule_date||'vB '||vB||' tCV '||result(v_i).VALUE);
      END IF;
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
      IF RESULT(v_i).value < 0
      THEN
        RESULT(v_i).value := 0;
      END IF;
    
      IF RESULT(v_i).value IS NULL
      THEN
        result.delete(v_i);
        EXIT;
      END IF;
    END LOOP;
    RETURN RESULT;
  
  END;

  /**
  *  @Author Marchuk A.
  * Функция расчета выкупных сумм по программе "Дожитие с возвратом взносов в случае смерти"
  * и "Смешанное страхование жизни"
  * @param p_policy_id ИД версии договора
  * @param p_contact_id ИД застрахованного (справочник контактов)
  * @param p_t_lob_line_id ИД страховой программы
  */
  --05.08.2008 Каткевич: Внес изменения в код
  FUNCTION inv2_get_cash_surrender_value
  (
    p_p_policy_id       IN NUMBER
   ,p_contact_id        IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
  ) RETURN tbl_cash_surrender_value IS
    --
    CURSOR c_policy(v_policy_id IN NUMBER) IS
    --
      SELECT ph.policy_header_id
            ,pt.is_periodical
            ,pt.brief
            ,ph.start_date header_start_date
            ,trunc(pp.start_date) start_date
            ,pp.version_num
            ,trunc(MONTHS_BETWEEN(p_end_date + 1, p_start_date) / 12) period_year
        FROM ven_t_payment_terms pt
            ,ven_p_pol_header    ph
            ,ven_p_policy        pp
       WHERE 1 = 1
         AND pp.policy_id = v_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pt.id = pp.payment_term_id;
    --
    r_policy c_policy%ROWTYPE;
    --
    CURSOR c_prev
    (
      p_policy_header_id IN NUMBER
     ,p_version_num      IN NUMBER
     ,p_start_date       IN DATE
    ) IS
      SELECT pp.pol_header_id
            ,pp.policy_id
            ,p_t_lob_line_id            t_lob_line_id
            ,p_contact_id               contact_id
            ,pc_d.start_cash_surr_date
            ,pc_d.end_cash_surr_date
            ,pc_d.insurance_year_date
            ,pc_d.insurance_year_number
            ,pc_d.value
        FROM policy_cash_surr_d pc_d
            ,policy_cash_surr pc
            ,(SELECT pp.policy_id
                    ,pp.pol_header_id
                    ,pp.version_num
                    ,pp.start_date
                    ,nvl((lead(pp.start_date)
                          over(PARTITION BY pp.pol_header_id ORDER BY pp.version_num) - 1)
                        ,trunc(pp.end_date)) end_date
                FROM p_policy     pp
                    ,p_pol_header ph
               WHERE 1 = 1
                 AND ph.policy_header_id = p_policy_header_id
                 AND pp.pol_header_id = ph.policy_header_id) pp
       WHERE 1 = 1
         AND pp.version_num < p_version_num
         AND pc.policy_id = pp.policy_id
         AND pc.t_lob_line_id = p_t_lob_line_id
         AND pc.contact_id = p_contact_id
         AND pc_d.policy_cash_surr_id = pc.policy_cash_surr_id
         AND pp.start_date < p_start_date
         AND pc_d.start_cash_surr_date BETWEEN trunc(pp.start_date) AND trunc(end_date)
       ORDER BY pc_d.start_cash_surr_date;
    --
    RESULT              tbl_cash_surrender_value;
    v_brief             VARCHAR2(200);
    v_header_start_date DATE;
    v_start_date        DATE;
    v_reserve_date      DATE;
    v_period_year       NUMBER;
    v_year_date         DATE;
    v_policy_header_id  NUMBER;
    v_t                 NUMBER;
    v_n                 NUMBER;
    vb                  NUMBER;
    v_ft                NUMBER;
    v_d                 NUMBER;
    v_p                 NUMBER;
    v_y                 NUMBER;
    v_tv                NUMBER;
    v_t_v               NUMBER;
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
                                                         ,p_period_year))
      --Добавил это условие чтобы не формировать график платежей за пределами окончания договора
       WHERE start_schedule_date <= p_end_date;
    --
    r_schedule c_schedule%ROWTYPE;
    v_i        NUMBER;
    --
  BEGIN
    --
    --DBMS_OUTPUT.PUT_LINE ('INV2_GET_CASH_SURRENDER_VALUE');
  
    OPEN c_policy(p_p_policy_id);
    FETCH c_policy
      INTO r_policy;
    CLOSE c_policy;
  
    v_brief             := r_policy.brief;
    v_start_date        := r_policy.start_date;
    v_header_start_date := r_policy.header_start_date;
    v_period_year       := r_policy.period_year;
    v_policy_header_id  := r_policy.policy_header_id;
    v_n                 := v_period_year;
    v_i                 := 0;
  
    --DBMS_OUTPUT.PUT_LINE (' v_brief='||(v_brief)||' v_policy_header_id '||v_policy_header_id||'version_num '||r_policy.version_num||' p_t_lob_line_id '||p_t_lob_line_id||' p_contact_id '||p_contact_id);
    --DBMS_OUTPUT.PUT_LINE (' v_start_date '||(v_start_date)||'v_header_start_date '||v_header_start_date||' v_period_year '||v_period_year);
    --
    -- pkg_renlife_utils.tmp_log_writer('1 '||p_start_date||' '||p_end_date);
    FOR cur IN c_prev(v_policy_header_id, r_policy.version_num, v_start_date)
    LOOP
    
      IF cur.value IS NOT NULL
      THEN
      
        --DBMS_OUTPUT.PUT_LINE (' Данные с предыдущей версии ...');
        v_i := v_i + 1;
        RESULT(v_i).policy_header_id := cur.pol_header_id;
        RESULT(v_i).policy_id := cur.policy_id;
        RESULT(v_i).t_lob_line_id := cur.t_lob_line_id;
        RESULT(v_i).contact_id := cur.contact_id;
        RESULT(v_i).insurance_year_date := cur.insurance_year_date;
        RESULT(v_i).start_cash_surr_date := cur.start_cash_surr_date;
        RESULT(v_i).end_cash_surr_date := cur.end_cash_surr_date;
        RESULT(v_i).insurance_year_number := cur.insurance_year_number;
        RESULT(v_i).payment_number := NULL;
        RESULT(v_i).is_history := 1;
        RESULT(v_i).value := cur.value;
        --  pkg_renlife_utils.tmp_log_writer('INV 1 '||result(v_i).VALUE);
        --DBMS_OUTPUT.PUT_LINE ('start_cash_surr_date '||result(v_i).start_cash_surr_date);
        --DBMS_OUTPUT.PUT_LINE ('end_cash_surr_date '||result(v_i).end_cash_surr_date);
      
      END IF;
    
    END LOOP;
  
    --DBMS_OUTPUT.PUT_LINE (' v_brief '||(v_brief)||'v_policy_header_id '||v_policy_header_id||' p_t_lob_line_id '||p_t_lob_line_id||' p_p_asset_header_id '||p_p_asset_header_id);
    --
    --pkg_renlife_utils.tmp_log_writer('2');
    OPEN c_schedule(v_brief, v_start_date, v_period_year);
  
    LOOP
      FETCH c_schedule
        INTO r_schedule;
      IF c_schedule%NOTFOUND
      THEN
        EXIT;
      END IF;
      v_i := v_i + 1;
      v_t := trunc(MONTHS_BETWEEN(r_schedule.start_schedule_date, v_header_start_date) / 12);
    
      RESULT(v_i).policy_header_id := v_policy_header_id;
      RESULT(v_i).policy_id := p_p_policy_id;
      RESULT(v_i).t_lob_line_id := p_t_lob_line_id;
      RESULT(v_i).contact_id := p_contact_id;
      RESULT(v_i).insurance_year_date := to_date(NULL);
      RESULT(v_i).start_cash_surr_date := r_schedule.start_schedule_date;
      RESULT(v_i).end_cash_surr_date := r_schedule.end_schedule_date;
      RESULT(v_i).insurance_year_number := v_t + 1;
      RESULT(v_i).payment_number := NULL;
    
      IF v_brief = 'EVERY_YEAR'
      THEN
      
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        /*
              if v_t = 0 then
                result(v_i).value               := 0;
              elsif v_t = 1 then
                result(v_i).value               := 0;
              else
        */
        vb := pkg_reserve_r_life.get_vb(v_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,v_reserve_date);
        RESULT(v_i).value := greatest(0, ROUND(v_ft * vb, 6));
        /*
              end if;
        */
        --DBMS_OUTPUT.PUT_LINE (' i.num='||r_schedule.schedule_num||' v_reserve_date='||v_reserve_date||' v_P='||v_P||' v_Ft='||v_Ft||' v_t='||v_t||' v_n='||v_n||' schedule_date='||r_schedule.start_schedule_date||'vB='||vB||' tCV='||result(v_i).VALUE);
      
      ELSIF v_brief = 'Единовременно'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
        --DBMS_OUTPUT.PUT_LINE ('v_reserve_date '||v_reserve_date||'r_schedule.start_schedule_date '||r_schedule.start_schedule_date||'v_year_date '||v_year_date);
        v_tv := pkg_reserve_r_life.get_v(v_policy_header_id
                                        ,p_p_policy_id
                                        ,p_t_lob_line_id
                                        ,p_p_asset_header_id
                                        ,v_reserve_date);
      
        IF v_t = 0
        THEN
          v_t_v := 0;
        ELSE
          v_t_v := pkg_reserve_r_life.get_v(v_policy_header_id
                                           ,p_p_policy_id
                                           ,p_t_lob_line_id
                                           ,p_p_asset_header_id
                                           ,v_year_date - 1);
        END IF;
        v_y := (r_schedule.start_schedule_date - v_year_date) / (v_reserve_date - v_year_date);
        v_y := ROUND(v_y, 6);
      
        IF r_schedule.start_schedule_date = v_header_start_date
        THEN
          RESULT(v_i).value := 0;
        ELSE
          RESULT(v_i).value := greatest(0, v_ft * ((1 - v_y) * v_t_v + v_y * v_tv));
        END IF;
        --DBMS_OUTPUT.PUT_LINE (' i.num '||r_schedule.schedule_num||' v_Ft='||v_Ft||' v_P='||v_P||' v_Y='||v_Y||' v_tV='||v_tV||' v_t_V='||v_t_V||' tCV '||result(v_i).VALUE);
      ELSIF v_brief = 'HALF_YEAR'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
      
        --DBMS_OUTPUT.PUT_LINE ('v_reserve_date '||v_reserve_date||'r_schedule.start_schedule_date '||r_schedule.start_schedule_date||'v_year_date '||v_year_date);
      
        v_ft := ft(v_n, v_t + 1);
      
        v_p := pkg_reserve_r_life.get_p(v_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,v_year_date);
      
        --pkg_renlife_utils.tmp_log_writer('inv 3 '||' v_year_date  '||v_year_date||'  r_schedule.start_schedule_date '||r_schedule.start_schedule_date);
        IF r_schedule.start_schedule_date = v_year_date
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          v_d := v_p * (1 / 2);
        ELSE
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          v_d := 0;
        END IF;
        -- pkg_renlife_utils.tmp_log_writer('inv 4 '||' v_policy_header_id  '||v_policy_header_id
        -- ||'  p_p_policy_id '||p_p_policy_id||' p_t_lob_line_id '||p_t_lob_line_id||' p_p_asset_header_id '||p_p_asset_header_id||' v_reserve_date '||v_reserve_date);
      
        RESULT(v_i).value := greatest(0, ROUND(v_ft * (vb - v_d), 6));
      
        --  pkg_renlife_utils.tmp_log_writer('inv 3 '||' v_ft  '||v_ft||'  vb '||vb||' v_d'||v_D);
      
        --DBMS_OUTPUT.PUT_LINE (' i.num='||r_schedule.schedule_num||' v_reserve_date='||v_reserve_date||' v_P='||v_P||' v_Ft='||v_Ft||' v_t='||v_t||' v_n='||v_n||' schedule_date='||r_schedule.start_schedule_date||'vB='||vB||' tCV='||result(v_i).VALUE);
      
      ELSIF v_brief = 'EVERY_QUARTER'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
      
        --DBMS_OUTPUT.PUT_LINE ('v_reserve_date '||v_reserve_date||'r_schedule.start_schedule_date '||r_schedule.start_schedule_date||'v_year_date '||v_year_date);
      
        v_p := pkg_reserve_r_life.get_p(v_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,v_year_date);
      
        IF r_schedule.start_schedule_date = v_year_date
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 3 / 4;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 3)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 1 / 2;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 6)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 1 / 4;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 9)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := 0;
        END IF;
      
        RESULT(v_i).value := greatest(0, ROUND(v_ft * (vb - v_d), 6));
        /*
              end if;
        */
      
        --DBMS_OUTPUT.PUT_LINE (' i.num='||r_schedule.schedule_num||' v_reserve_date='||v_reserve_date||' v_P='||v_P||' v_Ft='||v_Ft||' v_t='||v_t||' v_n='||v_n||' schedule_date='||r_schedule.start_schedule_date||'vB='||vB||' tCV='||result(v_i).VALUE);
      
      ELSIF v_brief = 'MONTHLY'
      THEN
        v_year_date := ADD_MONTHS(v_header_start_date, 12 * v_t);
        RESULT(v_i).insurance_year_date := v_year_date;
        v_reserve_date := ADD_MONTHS(v_header_start_date, 12 * (v_t + 1)) - 1;
        v_ft := ft(v_n, v_t + 1);
      
        --DBMS_OUTPUT.PUT_LINE ('v_reserve_date '||v_reserve_date||'r_schedule.start_schedule_date '||r_schedule.start_schedule_date||'v_year_date '||v_year_date);
      
        /*
              if v_t = 0 then
                result(v_i).value               := 0;
              elsif v_t = 1 then
                result(v_i).value               := 0;
              else
        */
        v_p := pkg_reserve_r_life.get_p(v_policy_header_id
                                       ,p_p_policy_id
                                       ,p_t_lob_line_id
                                       ,p_p_asset_header_id
                                       ,v_year_date);
      
        IF r_schedule.start_schedule_date = v_year_date
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,r_schedule.start_schedule_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 11 / 12;
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 1)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 10 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 2)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 9 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 3)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 8 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 4)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 7 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 5)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 6 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 6)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 5 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 7)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          v_d := v_p * 4 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 8)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 3 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 9)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 2 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 10)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := v_p * 1 / 12;
          v_d := ROUND(v_d, 6);
        ELSIF r_schedule.start_schedule_date = ADD_MONTHS(v_year_date, 11)
        THEN
          vb  := pkg_reserve_r_life.get_vb(v_policy_header_id
                                          ,p_p_policy_id
                                          ,p_t_lob_line_id
                                          ,p_p_asset_header_id
                                          ,v_reserve_date);
          vb  := ROUND(vb, 6);
          v_d := 0;
        END IF;
      
        RESULT(v_i).value := greatest(0, ROUND(v_ft * (vb - v_d), 6));
        /*
              end if;
        */
        --DBMS_OUTPUT.PUT_LINE (' i.num='||r_schedule.schedule_num||' v_reserve_date='||v_reserve_date||' v_P='||v_P||' v_Ft='||v_Ft||' v_t='||v_t||' v_n='||v_n||' schedule_date='||r_schedule.start_schedule_date||'vB='||vB||' tCV='||result(v_i).VALUE);
      
      END IF;
      /* Marchuk A modify 2007.11.30 Bug 1001'*/
      IF RESULT(v_i).value < 0
      THEN
        RESULT(v_i).value := 0;
      END IF;
    
      -- pkg_renlife_utils.tmp_log_writer('inv 2 '||v_brief||'  '||RESULT(v_i).VALUE);
    
    END LOOP;
    RETURN RESULT;
  
  END;

  /**
  *  @Author Marchuk A.
  * Расчет значений выкупной суммы на дату годовщин по ИД версии договора
  * @param p_policy_id ID версии полиса
  */

  PROCEDURE calc_cash_surrender(p_p_policy_id IN NUMBER) IS
    v_policy_cash_surr_id NUMBER;
    v_p_policy_id         NUMBER;
    v_contact_id          NUMBER;
    v_p_asset_header_id   NUMBER;
    v_t_lob_line_id       NUMBER;
    RESULT                tbl_cash_surrender_value;
  
  BEGIN
    --DBMS_OUTPUT.PUT_LINE ('ENTER Calc_Cash_Surrender ');
  
    IF NOT
        pkg_tariff_calc.calc_fun('Cash_Surrender_Valid', ent.id_by_brief('P_POLICY'), p_p_policy_id) = 1
    THEN
      RETURN;
    END IF;
    FOR c_policy IN (SELECT ph.policy_header_id
                           ,aa.p_policy_id
                           ,aa.contact_id
                           ,aa.p_asset_header_id
                           ,ll.t_lob_line_id
                           ,ll.brief
                           ,pc.ins_amount
                           ,pc.start_date
                           ,pc.end_date
                       FROM t_lob_line         ll
                           ,t_product_line     pl
                           ,t_prod_line_option plo
                           ,p_cover            pc
                           ,as_assured         aas
                           ,p_pol_header       ph
                           ,p_policy           pp
                           ,as_asset           aa
                      WHERE 1 = 1
                        AND aa.p_policy_id = p_p_policy_id
                        AND pp.policy_id = p_p_policy_id
                        AND ph.policy_header_id = pp.pol_header_id
                        AND aas.as_assured_id = aa.as_asset_id
                        AND pc.as_asset_id = aa.as_asset_id
                        AND plo.id = pc.t_prod_line_option_id
                        AND pl.id = plo.product_line_id
                        AND ll.t_lob_line_id = pl.t_lob_line_id)
    LOOP
    
      drop_cash_surrender(c_policy.p_policy_id, c_policy.contact_id, c_policy.t_lob_line_id);
    
      v_p_policy_id       := c_policy.p_policy_id;
      v_p_asset_header_id := c_policy.p_asset_header_id;
      v_t_lob_line_id     := c_policy.t_lob_line_id;
      v_contact_id        := c_policy.contact_id;
      --
      SELECT sq_policy_cash_surr.nextval INTO v_policy_cash_surr_id FROM dual;
      --
      INSERT INTO ven_policy_cash_surr
        (policy_cash_surr_id, pol_header_id, policy_id, t_lob_line_id, contact_id)
        SELECT v_policy_cash_surr_id
              ,c_policy.policy_header_id
              ,c_policy.p_policy_id
              ,c_policy.t_lob_line_id
              ,c_policy.contact_id
          FROM dual;
    
      IF c_policy.brief = 'END'
      THEN
      
        --DBMS_OUTPUT.PUT_LINE ('END BEFORE END_get_Cash_Surrender_value');
      
        RESULT := end_get_cash_surrender_value(v_p_policy_id
                                              ,v_contact_id
                                              ,v_p_asset_header_id
                                              ,v_t_lob_line_id
                                              ,c_policy.start_date
                                              ,c_policy.end_date);
      
        --DBMS_OUTPUT.PUT_LINE ('END AFTER END_get_Cash_Surrender_value');
      
        FOR i IN 1 .. result.count
        LOOP
          IF RESULT(i).is_history = 1
          THEN
            --pkg_renlife_utils.tmp_log_writer('END '||result(i).VALUE);
            --DBMS_OUTPUT.PUT_LINE (' result(i).start_cash_surr_date (is_histary) '|| result(i).start_cash_surr_date);
            INSERT INTO ven_policy_cash_surr_d
              (policy_cash_surr_d_id
              ,policy_cash_surr_id
              ,insurance_year_date
              ,start_cash_surr_date
              ,end_cash_surr_date
              ,insurance_year_number
              ,payment_number
              ,VALUE)
            VALUES
              (NULL
              ,v_policy_cash_surr_id
              ,RESULT(i).insurance_year_date
              ,RESULT(i).start_cash_surr_date
              ,RESULT(i).end_cash_surr_date
              ,RESULT(i).insurance_year_number
              ,RESULT(i).payment_number
              ,RESULT(i).value);
          ELSE
            --pkg_renlife_utils.tmp_log_writer('END '||result(i).VALUE);
            --DBMS_OUTPUT.PUT_LINE (' result(i).start_cash_surr_date '|| result(i).start_cash_surr_date);
            INSERT INTO ven_policy_cash_surr_d
              (policy_cash_surr_d_id
              ,policy_cash_surr_id
              ,insurance_year_date
              ,start_cash_surr_date
              ,end_cash_surr_date
              ,insurance_year_number
              ,payment_number
              ,VALUE)
            VALUES
              (NULL
              ,v_policy_cash_surr_id
              ,RESULT(i).insurance_year_date
              ,RESULT(i).start_cash_surr_date
              ,RESULT(i).end_cash_surr_date
              ,RESULT(i).insurance_year_number
              ,RESULT(i).payment_number
              ,RESULT(i).value * c_policy.ins_amount);
          END IF;
        END LOOP;
      
      ELSIF c_policy.brief = 'PEPR'
      THEN
      
        --DBMS_OUTPUT.PUT_LINE ('PEPR BEFORE END_get_Cash_Surrender_value ');
      
        RESULT := end_get_cash_surrender_value(v_p_policy_id
                                              ,v_contact_id
                                              ,v_p_asset_header_id
                                              ,v_t_lob_line_id
                                              ,c_policy.start_date
                                              ,c_policy.end_date);
      
        --DBMS_OUTPUT.PUT_LINE ('PEPR AFTER END_get_Cash_Surrender_value');
      
        FOR i IN 1 .. result.count
        LOOP
          IF RESULT(i).is_history = 1
          THEN
            --pkg_renlife_utils.tmp_log_writer('PEPR '||RESULT(i).VALUE);
            --DBMS_OUTPUT.PUT_LINE (' result(i).start_cash_surr_date (is_histary) '|| result(i).start_cash_surr_date);
            INSERT INTO ven_policy_cash_surr_d
              (policy_cash_surr_d_id
              ,policy_cash_surr_id
              ,insurance_year_date
              ,start_cash_surr_date
              ,end_cash_surr_date
              ,insurance_year_number
              ,payment_number
              ,VALUE)
            VALUES
              (NULL
              ,v_policy_cash_surr_id
              ,RESULT(i).insurance_year_date
              ,RESULT(i).start_cash_surr_date
              ,RESULT(i).end_cash_surr_date
              ,RESULT(i).insurance_year_number
              ,RESULT(i).payment_number
              ,RESULT(i).value);
          ELSE
            -- pkg_renlife_utils.tmp_log_writer('PEPR '||RESULT(i).VALUE);
            --DBMS_OUTPUT.PUT_LINE (' result(i).start_cash_surr_date '|| result(i).start_cash_surr_date);
            INSERT INTO ven_policy_cash_surr_d
              (policy_cash_surr_d_id
              ,policy_cash_surr_id
              ,insurance_year_date
              ,start_cash_surr_date
              ,end_cash_surr_date
              ,insurance_year_number
              ,payment_number
              ,VALUE)
            VALUES
              (NULL
              ,v_policy_cash_surr_id
              ,RESULT(i).insurance_year_date
              ,RESULT(i).start_cash_surr_date
              ,RESULT(i).end_cash_surr_date
              ,RESULT(i).insurance_year_number
              ,RESULT(i).payment_number
              ,RESULT(i).value * c_policy.ins_amount);
          END IF;
        END LOOP;
      ELSIF c_policy.brief IN ('INVEST2', 'INVEST')
      THEN
      
        --DBMS_OUTPUT.PUT_LINE ('INVEST2 BEFORE END_get_Cash_Surrender_value');
      
        RESULT := inv2_get_cash_surrender_value(v_p_policy_id
                                               ,v_contact_id
                                               ,v_p_asset_header_id
                                               ,v_t_lob_line_id
                                               ,c_policy.start_date
                                               ,c_policy.end_date);
      
        --DBMS_OUTPUT.PUT_LINE ('INVEST2 AFTER END_get_Cash_Surrender_value');
      
        FOR i IN 1 .. result.count
        LOOP
          IF RESULT(i).is_history = 1
          THEN
            pkg_renlife_utils.tmp_log_writer('INV ' || RESULT(i).value);
            INSERT INTO ven_policy_cash_surr_d
              (policy_cash_surr_d_id
              ,policy_cash_surr_id
              ,insurance_year_date
              ,start_cash_surr_date
              ,end_cash_surr_date
              ,insurance_year_number
              ,payment_number
              ,VALUE)
            VALUES
              (NULL
              ,v_policy_cash_surr_id
              ,RESULT(i).insurance_year_date
              ,RESULT(i).start_cash_surr_date
              ,RESULT(i).end_cash_surr_date
              ,RESULT(i).insurance_year_number
              ,RESULT(i).payment_number
              ,RESULT(i).value);
          ELSE
            pkg_renlife_utils.tmp_log_writer('INV ' || RESULT(i).value);
            INSERT INTO ven_policy_cash_surr_d
              (policy_cash_surr_d_id
              ,policy_cash_surr_id
              ,insurance_year_date
              ,start_cash_surr_date
              ,end_cash_surr_date
              ,insurance_year_number
              ,payment_number
              ,VALUE)
            VALUES
              (NULL
              ,v_policy_cash_surr_id
              ,RESULT(i).insurance_year_date
              ,RESULT(i).start_cash_surr_date
              ,RESULT(i).end_cash_surr_date
              ,RESULT(i).insurance_year_number
              ,RESULT(i).payment_number
              ,RESULT(i).value * c_policy.ins_amount);
          END IF;
        END LOOP;
      END IF;
    
    END LOOP;
  
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
  
    DELETE FROM ven_policy_cash_surr cs
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
       AND cs.contact_id = aa.assured_contact_id
       AND cs.t_lob_line_id = ll.t_lob_line_id
       AND cs_d.policy_cash_surr_id = cs.policy_cash_surr_id
       AND p_date BETWEEN cs_d.start_cash_surr_date AND cs_d.end_cash_surr_date;
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
--
/
