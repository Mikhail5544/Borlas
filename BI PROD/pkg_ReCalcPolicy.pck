CREATE OR REPLACE PACKAGE pkg_recalcpolicy IS

  TYPE calc_param IS RECORD(
     p_cover_id           NUMBER
    ,age                  NUMBER
    ,gender_type          VARCHAR2(1)
    ,assured_contact_id   NUMBER
    ,period_year          NUMBER
    ,s_coef_m             NUMBER
    ,s_coef_nm            NUMBER
    ,s_coef               NUMBER
    ,k_coef_m             NUMBER
    ,k_coef_nm            NUMBER
    ,k_coef               NUMBER
    ,f                    NUMBER
    ,t                    NUMBER
    ,normrate             NUMBER
    ,deathrate_id         NUMBER
    ,payment_terms_id     NUMBER
    ,tariff               NUMBER
    ,tariff_netto         NUMBER
    ,fee                  NUMBER
    ,as_assured_id        NUMBER
    ,ins_amount           NUMBER
    ,payment_base_type    NUMBER
    ,premia_base_type     NUMBER(1)
    ,is_one_payment       NUMBER
    ,is_error             NUMBER
    ,is_error_desc        VARCHAR2(200)
    ,is_in_waiting_period NUMBER
    ,number_of_payment    NUMBER
    ,brief                VARCHAR2(25)
    ,header_start_date    DATE
    ,header_id            NUMBER
    ,lob_line_id          NUMBER
    ,asset_header_id      NUMBER
    ,dop_brief            VARCHAR2(25));

  --
  TYPE add_info IS RECORD(
     p_cover_id_prev            NUMBER
    ,p_cover_id_curr            NUMBER
    ,is_add_found               NUMBER(1)
    ,policy_id_prev             NUMBER
    ,policy_id_curr             NUMBER
    ,contact_id_prev            NUMBER
    ,contact_id_curr            NUMBER
    ,is_assured_change          NUMBER(1)
    ,ins_amount_prev            NUMBER
    ,ins_amount_curr            NUMBER
    ,is_ins_amount_change       NUMBER(1)
    ,fee_prev                   NUMBER
    ,fee_curr                   NUMBER
    ,is_fee_change              NUMBER(1)
    ,payment_terms_id_prev      NUMBER
    ,payment_terms_id_curr      NUMBER
    ,is_payment_terms_id_change NUMBER(1)
    ,period_id_prev             NUMBER
    ,period_id_curr             NUMBER
    ,is_period_change           NUMBER(1)
    ,is_one_payment_prev        NUMBER(1)
    ,is_one_payment_curr        NUMBER(1)
    ,is_periodical_change       NUMBER(1)
    ,ins_fund_id_curr           NUMBER
    ,ins_fund_id_prev           NUMBER
    ,is_fund_id_change          NUMBER(1)
    ,is_underwriting            NUMBER(1)
    ,a_header_prev              NUMBER
    ,a_header_curr              NUMBER);

  FUNCTION get_add_info(p_cover_id IN NUMBER) RETURN add_info;
  FUNCTION get_calc_param
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN calc_param;

  /*Процедура пересчета договора страхования при уменьшении страхового взноса
  **Веселуха Е.В.
  **13.01.2009
  */
  PROCEDURE reprem
  (
    par_policy_id IN NUMBER
   ,p_new_fee     IN NUMBER
   ,par_cover_id  IN NUMBER
   ,p_re_sign     IN NUMBER DEFAULT NULL
  );

  /*Процедура выбора необходимого кавера для пересчета и проверка возможности такого пересчета
  **Веселуха Е.В.
  **14.01.2009
  */
  PROCEDURE recoverpolicy(par_policy_id IN PLS_INTEGER);
  /*Веселуха Е.В.
   10.05.2011
  */
  PROCEDURE resumpolicy(par_policy_id IN PLS_INTEGER);
  PROCEDURE resum
  (
    par_policy_id IN NUMBER
   ,p_new_amount  IN NUMBER
   ,par_cover_id  IN NUMBER
   ,p_re_sign     IN NUMBER DEFAULT NULL
  );

  /*
    Байтин А.
    Уменьшение срока действия ДС
  */
  PROCEDURE decrease_period(par_policy_id NUMBER);

END pkg_recalcpolicy;
/
CREATE OR REPLACE PACKAGE BODY pkg_recalcpolicy IS

  --

  gv_debug BOOLEAN;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF gv_debug
    THEN
      INSERT INTO p_cover_debug
        (p_cover_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_ReCalcPolicy', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION get_calc_param
  (
    p_cover_id IN NUMBER
   ,p_re_sign  IN NUMBER DEFAULT NULL
  ) RETURN calc_param IS
    --
    v_cover_id    NUMBER;
    v_age         NUMBER;
    v_period_year NUMBER;
    --
    v_as_assured_id NUMBER;
    v_lob_line_id   NUMBER;
    v_policy_id     NUMBER;
    --
    v_fund_id  NUMBER;
    v_normrate NUMBER;
    --
    v_header_start_date DATE;
    v_policy_start_date DATE;
    v_number_of_payment NUMBER;
    v_payment_terms_id  NUMBER;
    --
    v_deathrate_id       NUMBER;
    v_discount_f_id      NUMBER;
    v_gender_type        VARCHAR2(1);
    v_brief              VARCHAR2(25);
    v_dop_brief          VARCHAR2(25);
    v_assured_contact_id NUMBER;
    --
    v_s_coef           NUMBER;
    v_k_coef           NUMBER;
    v_s_coef_m         NUMBER;
    v_k_coef_m         NUMBER;
    v_s_coef_nm        NUMBER;
    v_k_coef_nm        NUMBER;
    v_f                NUMBER;
    v_premia_base_type NUMBER;
    --
    v_ins_amount           NUMBER;
    v_tariff               NUMBER;
    v_tariff_netto         NUMBER;
    v_fee                  NUMBER;
    v_is_in_waiting_period NUMBER;
    v_head_start           DATE;
    v_header_id            NUMBER;
    v_asset_header_id      NUMBER;
    --
    RESULT calc_param;
  BEGIN
    result.p_cover_id := p_cover_id;
    v_cover_id        := p_cover_id;
    --
    dbms_output.put_line('GET_CALC_PARAM ID покрытия ' || v_cover_id);
    SELECT vas.as_assured_id
          ,decode(nvl(vcp.gender, vas.gender), 0, 'w', 1, 'm') gender_type
          ,assured_contact_id
      INTO v_as_assured_id
          ,v_gender_type
          ,v_assured_contact_id
      FROM ven_cn_person  vcp
          ,ven_contact    vc
          ,ven_as_assured vas
          ,p_cover        pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND vas.as_assured_id = pc.as_asset_id
       AND vc.contact_id(+) = vas.assured_contact_id
       AND vcp.contact_id(+) = vc.contact_id;
    --
    dbms_output.put_line('ID застрахованного ' || v_as_assured_id);
    IF v_gender_type IS NULL
    THEN
      result.is_error      := 1;
      result.is_error_desc := 'Не определен тип застрахованного лица';
    END IF;
  
    --  Признак p_re_sign исключает возможность расчета тарифов при повышающих коэффициентах K и S
  
    SELECT pp.policy_id
          ,decode(p_re_sign, 1, least(nvl(s_coef, 0), 0), nvl(s_coef, 0)) s_coef
          ,decode(p_re_sign, 1, least(nvl(k_coef, 0), 0), nvl(k_coef, 0)) k_koef
          ,decode(p_re_sign, 1, least(nvl(s_coef_m, 0), 0), nvl(s_coef_m, 0)) s_coef_m
          ,decode(p_re_sign, 1, least(nvl(k_coef_m, 0), 0), nvl(k_coef_m, 0)) k_koef_m
          ,decode(p_re_sign, 1, least(nvl(s_coef_nm, 0), 0), nvl(s_coef_nm, 0)) s_coef_nm
          ,decode(p_re_sign, 1, least(nvl(k_coef_nm, 0), 0), nvl(k_coef_nm, 0)) k_koef_nm
           
          ,pc.rvb_value
           --, pkg_cover.calc_loading(v_cover_id)
          ,pc.normrate_value
          ,nvl(pc.insured_age, aa.insured_age) insured_age
          ,pc.tariff
          ,pc.tariff_netto
          ,pc.fee
          ,pc.ins_amount
          ,pc.premia_base_type
           --         , ven_p_policy.discount_f_id, decode (ven_t_period.period_value, null, trunc(months_between(ven_p_policy.end_date, ph.start_date)/12), ven_t_period.period_value)
          ,pp.discount_f_id
          ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
          ,ph.fund_id
          ,pp.start_date
          ,ph.start_date
          ,pt.number_of_payments
          ,pt.id
          ,decode(pt.is_periodical, 0, 1, 1, 0) is_one_payment
          ,pkg_policy.is_in_waiting_period(pp.policy_id, pp.waiting_period_id, pp.start_date) is_in_waiting_period
          ,CASE
             WHEN prod.brief IN ('END', 'END_2') THEN
              'END'
             WHEN prod.brief IN ('PEPR', 'PEPR_2', 'CHI', 'CHI_2') THEN
              'PEPR'
           --when 'PRIN' then 'PEPR'
           --when 'PRIN_DP_NEW' then 'PEPR'
           --when 'PRIN_DP' then 'PEPR'
           --when 'Platinum_LA' then 'PEPR'
           --when 'Baby_LA' then 'PEPR'
             WHEN prod.brief IN ('TERM', 'TERM_2') THEN
              'TERM'
           --when 'Family La' then 'TERM'
           --when 'Life_GF' then 'TERM'
             ELSE
              prod.brief
           END brief
           
          ,ph.start_date
          ,ph.policy_header_id
          ,aa.p_asset_header_id
      INTO v_policy_id
          ,v_s_coef
          ,v_k_coef
          ,v_s_coef_m
          ,v_k_coef_m
          ,v_s_coef_nm
          ,v_k_coef_nm
          ,v_f
          ,v_normrate
          ,v_age
          ,v_tariff
          ,v_tariff_netto
          ,v_fee
          ,v_ins_amount
          ,v_premia_base_type
          ,v_discount_f_id
          ,v_period_year
          ,v_fund_id
          ,v_policy_start_date
          ,v_header_start_date
          ,v_number_of_payment
          ,v_payment_terms_id
          ,result.is_one_payment
          ,v_is_in_waiting_period
          ,v_brief
          ,v_head_start
          ,v_header_id
          ,v_asset_header_id
      FROM t_payment_terms pt
          ,t_period        tp
          ,p_pol_header    ph
          ,t_product       prod
          ,p_policy        pp
          ,ven_as_assured  aa
          ,p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND tp.id = pp.period_id
       AND ph.product_id = prod.product_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id;
  
    --
    dbms_output.put_line('ID версии договора (полиса) ' || v_policy_id);
    dbms_output.put_line('Возраст застрахованного ' || v_age);
    IF v_age IS NULL
    THEN
      dbms_output.put_line('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Возраст застрахованного не расчитан';
    END IF;
    --
    IF v_f IS NULL
    THEN
      dbms_output.put_line('Нагрузка не найдена....Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Нагрузка не найдена';
    END IF;
    --
    dbms_output.put_line('ID discount_f= ' || v_discount_f_id);
    --
    IF v_discount_f_id IS NULL
    THEN
      dbms_output.put_line('Базовая нагрузка по договору не найдена....Устанавливаем флаг ошибки ');
      result.is_error      := 1;
      result.is_error_desc := 'Базовая нагрузка по договору не найдена';
    END IF;
    --
    dbms_output.put_line('Срок действия договора ' || to_char(v_period_year));
    --
    SELECT ll.t_lob_line_id
          ,ll.brief
          ,decode(lr.func_id
                 ,NULL
                 ,lr.deathrate_id
                 ,pkg_tariff_calc.calc_fun(lr.func_id, ent.id_by_brief('P_COVER'), v_cover_id))
      INTO v_lob_line_id
          ,v_dop_brief
          ,v_deathrate_id
      FROM ven_t_lob_line         ll
          ,ven_t_prod_line_rate   lr
          ,ven_t_product_line
          ,ven_t_prod_line_option
          ,ven_p_cover
     WHERE 1 = 1
       AND ven_p_cover.p_cover_id = v_cover_id
       AND ven_t_prod_line_option.id = ven_p_cover.t_prod_line_option_id
       AND ven_t_product_line.id = ven_t_prod_line_option.product_line_id
       AND ll.t_lob_line_id = ven_t_product_line.t_lob_line_id
       AND lr.product_line_id(+) = ven_t_product_line.id;
    --
    /*DBMS_OUTPUT.PUT_LINE ('ID страховой программы '||v_lob_line_id);
    DBMS_OUTPUT.PUT_LINE ('Количество платежей в год '||v_number_of_payment);
    DBMS_OUTPUT.PUT_LINE ('Код валюты ответственности '||v_fund_id);*/
    --
    /*DBMS_OUTPUT.PUT_LINE ('Установленная норма доходности для "страховой программы" '||v_normrate);
    DBMS_OUTPUT.PUT_LINE ('v_f = '||v_f);
    DBMS_OUTPUT.PUT_LINE ('deathrate_id = '||v_deathrate_id);*/
    --
    result.age                  := v_age;
    result.gender_type          := v_gender_type;
    result.assured_contact_id   := v_assured_contact_id;
    result.period_year          := v_period_year;
    result.s_coef               := v_s_coef;
    result.k_coef               := v_k_coef;
    result.s_coef_m             := v_s_coef_m;
    result.k_coef_m             := v_k_coef_m;
    result.s_coef_nm            := v_s_coef_nm;
    result.k_coef_nm            := v_k_coef_nm;
    result.f                    := v_f;
    result.t                    := trunc(MONTHS_BETWEEN(v_policy_start_date, v_header_start_date) / 12);
    result.deathrate_id         := v_deathrate_id;
    result.normrate             := v_normrate;
    result.tariff               := v_tariff;
    result.tariff_netto         := v_tariff_netto;
    result.fee                  := v_fee;
    result.ins_amount           := v_ins_amount;
    result.as_assured_id        := v_as_assured_id;
    result.payment_terms_id     := v_payment_terms_id;
    result.premia_base_type     := v_premia_base_type;
    result.is_in_waiting_period := v_is_in_waiting_period;
    result.number_of_payment    := v_number_of_payment;
    result.brief                := v_brief;
    result.header_start_date    := v_head_start;
    result.header_id            := v_header_id;
    result.lob_line_id          := v_lob_line_id;
    result.asset_header_id      := v_asset_header_id;
    result.dop_brief            := v_dop_brief;
    --
    RETURN RESULT;
    --
  END;
  FUNCTION get_add_info(p_cover_id IN NUMBER) RETURN add_info IS
    -- Курсор для определения доп. соглашения
    CURSOR c_prev_version(p_p_cover_id IN NUMBER) IS
      SELECT p_cover_id_prev
            ,p_cover_id_curr
            ,is_add_found
            ,policy_id_prev
            ,policy_id_curr
            ,contact_id_prev
            ,contact_id_curr
            ,is_assured_change
            ,ins_amount_prev
            ,ins_amount_curr
            ,asset_header_prev
            ,asset_header_curr
            ,is_ins_amount_change
            ,fee_prev
            ,fee_curr
            ,is_fee_change
            ,payment_terms_id_prev
            ,payment_terms_id_curr
            ,is_payment_terms_id_change
            ,period_id_prev
            ,period_id_curr
            ,is_period_change
            ,is_one_payment_prev
            ,is_one_payment_curr
            ,is_periodical_change
            ,decode(doc.get_doc_status_brief(policy_id_prev), 'UNDERWRITING', 1, 0) is_underwriting
        FROM v_p_cover_life_add
       WHERE 1 = 1
         AND p_cover_id_curr = p_p_cover_id;
    --
    r_prev_version c_prev_version%ROWTYPE;
    --
    RESULT add_info;
  BEGIN
    OPEN c_prev_version(p_cover_id);
    FETCH c_prev_version
      INTO r_prev_version;
    -- При отсутствии предыдущей версии покрытия искуственно указываем, что это первая версия
    result.p_cover_id_prev := nvl(r_prev_version.p_cover_id_prev, p_cover_id);
    result.p_cover_id_curr := nvl(r_prev_version.p_cover_id_curr, p_cover_id);
    --
    result.is_add_found               := r_prev_version.is_add_found;
    result.policy_id_prev             := r_prev_version.policy_id_prev;
    result.policy_id_curr             := r_prev_version.policy_id_curr;
    result.contact_id_prev            := r_prev_version.contact_id_prev;
    result.contact_id_curr            := r_prev_version.contact_id_curr;
    result.is_assured_change          := r_prev_version.is_assured_change;
    result.ins_amount_prev            := r_prev_version.ins_amount_prev;
    result.ins_amount_curr            := r_prev_version.ins_amount_curr;
    result.is_ins_amount_change       := r_prev_version.is_ins_amount_change;
    result.fee_prev                   := r_prev_version.fee_prev;
    result.fee_curr                   := r_prev_version.fee_curr;
    result.is_fee_change              := r_prev_version.is_fee_change;
    result.payment_terms_id_prev      := r_prev_version.payment_terms_id_prev;
    result.payment_terms_id_curr      := r_prev_version.payment_terms_id_curr;
    result.is_payment_terms_id_change := r_prev_version.is_payment_terms_id_change;
    result.period_id_prev             := r_prev_version.period_id_prev;
    result.period_id_curr             := r_prev_version.period_id_curr;
    result.is_period_change           := r_prev_version.is_period_change;
    result.is_one_payment_prev        := r_prev_version.is_one_payment_prev;
    result.is_one_payment_curr        := r_prev_version.is_one_payment_curr;
    result.is_periodical_change       := r_prev_version.is_periodical_change;
    result.is_underwriting            := r_prev_version.is_underwriting;
    result.a_header_prev              := r_prev_version.asset_header_prev;
    result.a_header_curr              := r_prev_version.asset_header_curr;
    --
    RETURN RESULT;
    --
  END;

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
        /* Единовременный взнос*/
      
        /* В формуле пришлось написать (p_t + 1), т.к. не совсем понятно,как в единовременном
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
          IF l_t BETWEEN l_t_1 AND l_t_2
          THEN
            RESULT := 0;
          ELSE
            RESULT := 0.25 + 0.75 * (l_t - l_t_3) / 9;
          END IF;
        
        END IF;
      
      END IF;
    
      RETURN RESULT;
    END;
  
  BEGIN
    log(p_policy_id, ' p_t ' || p_t);
  
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

  PROCEDURE recoverpolicy(par_policy_id IN PLS_INTEGER) IS
    is_exist NUMBER := 0; --наличие доп соглашения Уменьшение размера страхового взноса
    not_exist EXCEPTION;
    cover_info   add_info;
    p_p_cover_id NUMBER;
    p_p_new_fee  NUMBER;
  
    CURSOR cur_recover IS
      SELECT pc.p_cover_id
            ,pc.fee p_new_fee
        FROM ven_t_lob_line         ll
            ,ven_t_prod_line_rate   lr
            ,ven_t_product_line     pl
            ,ven_t_prod_line_option opt
            ,t_product_line_type    plt
            ,ven_p_cover            pc
            ,as_asset               a
       WHERE 1 = 1
         AND a.p_policy_id = par_policy_id
         AND opt.id = pc.t_prod_line_option_id
         AND pl.id = opt.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND lr.product_line_id(+) = pl.id
         AND pl.product_line_type_id = plt.product_line_type_id
         AND (plt.brief IN ('RECOMMENDED') OR ll.brief IN ('I2', 'INVEST2', 'INVEST'))
         AND ll.brief NOT IN ('Adm_Cost_Life', 'Adm_Cost_Acc')
         AND a.as_asset_id = pc.as_asset_id;
  
  BEGIN
  
    SELECT COUNT(*)
      INTO is_exist
      FROM p_policy            pp
          ,p_pol_addendum_type tp
          ,t_addendum_type     t
     WHERE pp.policy_id = tp.p_policy_id
       AND t.t_addendum_type_id = tp.t_addendum_type_id
       AND t.description = 'Уменьшение размера страхового взноса'
       AND pp.policy_id = par_policy_id;
  
    IF nvl(is_exist, 0) > 0
    THEN
    
      OPEN cur_recover;
      LOOP
        FETCH cur_recover
          INTO p_p_cover_id
              ,p_p_new_fee;
        EXIT WHEN cur_recover%NOTFOUND;
        cover_info := get_add_info(p_p_cover_id);
        IF cover_info.fee_prev <> cover_info.fee_curr
        THEN
          reprem(par_policy_id, p_p_new_fee, p_p_cover_id, 0);
        END IF;
      END LOOP;
      CLOSE cur_recover;
      ins.pkg_pol_cash_surr_method.set_metod_f_t(par_policy_id, 2);
    ELSE
      NULL;
      --RAISE not_exist;
    END IF;
  
  END;

  PROCEDURE reprem
  (
    par_policy_id IN NUMBER
   ,p_new_fee     IN NUMBER
   ,par_cover_id  IN NUMBER
   ,p_re_sign     IN NUMBER DEFAULT NULL
  ) IS
  
    r_calc_param        calc_param;
    r_add_info          add_info;
    km                  NUMBER; --коэффициент рассрочки
    kt                  NUMBER;
    g_n                 NUMBER; --новая годовая брутто премия
    a                   NUMBER; --доля новой годовой брутто премии
    p_n                 NUMBER; --новая годовая нетто премия
    v_axn_re            NUMBER; --единовременная нетто-ставка при смешанном (дожитие и смерть) страховании
    v_a_xn_re           NUMBER; --аннуитет пренумерандо при сроке страхования n лет
    vt                  NUMBER; --математический нетто резерв в момент времени t
    vt_n                NUMBER; --доля от нетто резерва, которая участвует в расчете новой страховой суммы
    v_ft                NUMBER; --доля от страхового резерва
    vbt                 NUMBER; --балансовый резерв, рассчитанный на дату изменения
    cvt                 NUMBER; --выкупная сумма
    cvt_n               NUMBER; --доля от выкупной суммы
    s_n                 NUMBER; --новая страховая сумма
    v_nex               NUMBER; --единовременная нетто ставка на дожитие
    sumgt               NUMBER; --сумма годовых брутто взносов за период равный t
    sumgt_1             NUMBER; --сумма годовых брутто взносов за период равный t-1
    v_a1xn              NUMBER; --единовременная нетто ставка при страховании на случай смерти (выплата сразу после смерти) на срок n лет
    v_ia1xn             NUMBER; --единовременная нетто ставка при страховании на случай смерти (выплата сразу после смерти Застрахованного) на срок n лет
    s_nd                NUMBER; --страховая сумма по риску новая
    g_nd                NUMBER; --брутто взнос по риску новый
    p_nd                NUMBER; --нетто взнос по риску новый
    vt_nd               NUMBER; --доля от нетто резерва, которая участвует в расчете новой страховой суммы по риску
    pc_fee_osn          NUMBER;
    a_z                 NUMBER; --фактор Цильмера
    vt_1                NUMBER;
    vzt                 NUMBER; --резерв Цильмера на t
    vzt_1               NUMBER; --резерв Цильмера на t-1
    vt_1_axn_re         NUMBER;
    vt_1_a_xn_re        NUMBER;
    vt_1_a1xn           NUMBER;
    vt_1_nex            NUMBER;
    vt_1_ia1xn          NUMBER;
    v_a_xn_i            NUMBER;
    vt_1_a_xn_i         NUMBER;
    pd_p_cover_id       NUMBER;
    pd_p_brief          VARCHAR2(50);
    pd_p_description    VARCHAR2(150);
    pd_p_old_ins_amount NUMBER;
    pd_p_tariff         NUMBER;
    pd_p_f              NUMBER;
    pd_p_old_fee        NUMBER;
    pd_p_period_year    NUMBER;
    pd_p_k              NUMBER;
    pd_p_s              NUMBER;
    pd_p_koef           NUMBER;
  
    axn_s   NUMBER;
    a_xn_s  NUMBER;
    nex_s   NUMBER;
    ia1xn_s NUMBER;
    a1xn_s  NUMBER;
  
    a_xn_dd NUMBER;
    a1xn_dd NUMBER;
  
    CURSOR cur_cover IS
      SELECT pc.p_cover_id
            ,CASE
               WHEN opt.description = 'Защита страховых взносов' THEN
                ll.brief || '_old'
               WHEN opt.description = 'Освобождение от уплаты дальнейших взносов' THEN
                ll.brief || '_old'
               WHEN opt.description = 'Освобождение от уплаты страховых взносов' THEN
                ll.brief || '_old'
               ELSE
                ll.brief
             END brief
            ,ll.description
            ,pc.ins_amount old_ins_amount
            ,CASE
               WHEN ll.brief = 'AD' THEN
                pkg_tariff_calc.calc_fun(7726, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('H') THEN
                pkg_tariff_calc.calc_fun(7728, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('H_any') THEN
                pkg_tariff_calc.calc_fun(7766, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('ADis', 'ADis_any') THEN
                pkg_tariff_calc.calc_fun(7727, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('ATD') THEN
                pkg_tariff_calc.calc_fun(7730, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('TPD') THEN
                pkg_tariff_calc.calc_fun(7731, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('Dism') THEN
                pkg_tariff_calc.calc_fun(7729, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('Surg') THEN
                pkg_tariff_calc.calc_fun(6363, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('WOP', 'WOP_Life') THEN
                pkg_tariff_calc.calc_fun(3645, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('PWOP_Life', 'PWOP') THEN
                pkg_tariff_calc.calc_fun(3791, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               ELSE
                pc.tariff
             END tariff
             /*,CASE
               WHEN ll.brief IN ('AD') THEN
                1 --смерть
               WHEN ll.brief IN ('ADis', 'ADis_any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 1) --инвалидность
               WHEN ll.brief IN ('H', 'H_any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.5) --госпитализация
               WHEN ll.brief IN ('ATD', 'ATD_Any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.75) --временная утрата трудоспособности
               WHEN ll.brief IN ('Dism') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.75) --телесные повреждения
               WHEN ll.brief IN ('Surg', 'Surg_ACC', 'Surg_any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.5) --хирургические вмешательства
               ELSE
                1
             END koef*/
            ,CASE
               WHEN ll.brief IN ('AD'
                                ,'ADis'
                                ,'ADis_any'
                                ,'H'
                                ,'H_any'
                                ,'ATD'
                                ,'ATD_Any'
                                ,'Dism'
                                ,'Surg'
                                ,'Surg_ACC'
                                ,'Surg_any') THEN
                (SELECT pca.ins_amount
                   FROM ins.p_policy poli
                       ,ins.as_asset ass
                       ,ins.p_cover  pca
                  WHERE poli.policy_id = pol.prev_ver_id
                    AND poli.policy_id = ass.p_policy_id
                    AND ass.as_asset_id = pca.as_asset_id
                    AND pca.t_prod_line_option_id = opt.id) /
                (SELECT p.ins_amount
                   FROM ins.p_policy            pi
                       ,ins.as_asset            aa
                       ,ins.p_cover             p
                       ,ins.t_prod_line_option  ot
                       ,ins.t_product_line      tpl
                       ,ins.t_product_line_type t
                  WHERE pi.policy_id = pol.prev_ver_id
                    AND aa.p_policy_id = pi.policy_id
                    AND aa.as_asset_id = p.as_asset_id
                    AND p.t_prod_line_option_id = ot.id
                    AND ot.product_line_id = tpl.id
                    AND tpl.product_line_type_id = t.product_line_type_id
                    AND t.brief = 'RECOMMENDED')
               ELSE
                1
             END koef
            ,(nvl(greatest(nvl(pc.k_coef_m, pc.k_coef_nm), nvl(pc.k_coef_nm, pc.k_coef_m)), 0) + 100) / 100 k
            ,nvl(greatest(nvl(pc.s_coef_m, pc.s_coef_nm), nvl(pc.s_coef_nm, pc.s_coef_m)), 0) s
            ,pc.rvb_value f
            ,pc.fee old_fee
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
        FROM ins.t_lob_line          ll
            ,ins.t_prod_line_rate    lr
            ,ins.t_product_line      pl
            ,ins.t_prod_line_option  opt
            ,ins.t_product_line_type plt
            ,ins.p_cover             pc
            ,ins.as_asset            a
            ,ins.p_policy            pol
       WHERE 1 = 1
         AND a.p_policy_id = par_policy_id
         AND a.p_policy_id = pol.policy_id
         AND opt.id = pc.t_prod_line_option_id
         AND pl.id = opt.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND lr.product_line_id(+) = pl.id
         AND pl.product_line_type_id = plt.product_line_type_id
         AND plt.brief NOT IN ('RECOMMENDED')
         AND ll.brief NOT IN
             ('Adm_Cost_Life', 'Adm_Cost_Acc', 'I2', 'INVEST2', 'PEPR_INVEST_RESERVE', 'INVEST')
         AND a.as_asset_id = pc.as_asset_id;
  
  BEGIN
    r_calc_param := get_calc_param(par_cover_id, p_re_sign);
    r_add_info   := get_add_info(par_cover_id);
    /*
    **Методика. Шаг 1
    */
  
    CASE r_calc_param.payment_terms_id
      WHEN 162 THEN
        km := 0.53;
      WHEN 165 THEN
        km := 0.27;
      WHEN 166 THEN
        km := 0.09;
      ELSE
        km := 1;
    END CASE;
  
    g_n := p_new_fee / km;
    p_n := g_n * (1 - r_calc_param.f);
  
    /*
    **Методика. Шаг 2
    */
  
    a := g_n / (r_add_info.fee_prev / km);
  
    /*
    **Методика. Шаг 3
    */
  
    IF r_calc_param.brief = 'END'
       AND r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      v_axn_re  := ins.pkg_amath.axn(r_calc_param.age + r_calc_param.t
                                    ,r_calc_param.period_year - r_calc_param.t
                                    ,r_calc_param.gender_type
                                    ,r_calc_param.k_coef
                                    ,r_calc_param.s_coef
                                    ,r_calc_param.deathrate_id
                                    ,r_calc_param.normrate);
      v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                     ,r_calc_param.period_year - r_calc_param.t
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,1
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      --для пересчета ставки
      axn_s  := ins.pkg_amath.axn(r_calc_param.age
                                 ,r_calc_param.period_year
                                 ,r_calc_param.gender_type
                                 ,r_calc_param.k_coef
                                 ,r_calc_param.s_coef
                                 ,r_calc_param.deathrate_id
                                 ,r_calc_param.normrate);
      a_xn_s := ins.pkg_amath.a_xn(r_calc_param.age
                                  ,r_calc_param.period_year
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.s_coef
                                  ,1
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.normrate);
      --для резерва
      vt_1_axn_re  := ins.pkg_amath.axn(r_calc_param.age + (r_calc_param.t - 1)
                                       ,r_calc_param.period_year - (r_calc_param.t - 1)
                                       ,r_calc_param.gender_type
                                       ,r_calc_param.k_coef
                                       ,r_calc_param.s_coef
                                       ,r_calc_param.deathrate_id
                                       ,r_calc_param.normrate);
      vt_1_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + (r_calc_param.t - 1)
                                        ,r_calc_param.period_year - (r_calc_param.t - 1)
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,1
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
      --Vt_1 := vt_1_Axn_re * r_add_info.ins_amount_prev - ((r_add_info.fee_prev / Km) * (1 - r_calc_param.f)) * vt_1_a_xn_re;
      vt_1 := vt_1_axn_re * r_add_info.ins_amount_prev -
              ((axn_s / a_xn_s) * r_add_info.ins_amount_prev) * vt_1_a_xn_re;
      --
      --Vt := v_Axn_re * r_add_info.ins_amount_prev - ((r_add_info.fee_prev / Km) * (1 - r_calc_param.f)) * v_a_xn_re;
      vt   := v_axn_re * r_add_info.ins_amount_prev -
              ((axn_s / a_xn_s) * r_add_info.ins_amount_prev) * v_a_xn_re;
      a    := g_n / (((axn_s / a_xn_s) * r_add_info.ins_amount_prev) / (1 - r_calc_param.f));
      vt_n := vt * a;
    ELSIF r_calc_param.brief = 'PEPR'
          OR (r_calc_param.dop_brief = 'I2' OR r_calc_param.dop_brief IN ('INVEST2', 'INVEST'))
    THEN
      --для пересчета ставки
      nex_s   := ins.pkg_amath.nex(r_calc_param.age
                                  ,r_calc_param.period_year
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.s_coef
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.normrate);
      ia1xn_s := ins.pkg_amath.iax1n(r_calc_param.age
                                    ,r_calc_param.period_year
                                    ,r_calc_param.gender_type
                                    ,r_calc_param.k_coef
                                    ,r_calc_param.s_coef
                                    ,r_calc_param.deathrate_id
                                    ,r_calc_param.normrate);
      a_xn_s  := ins.pkg_amath.a_xn(r_calc_param.age
                                   ,r_calc_param.period_year
                                   ,r_calc_param.gender_type
                                   ,r_calc_param.k_coef
                                   ,r_calc_param.s_coef
                                   ,1
                                   ,r_calc_param.deathrate_id
                                   ,r_calc_param.normrate);
      --
      v_nex := ins.pkg_amath.nex(r_calc_param.age + r_calc_param.t
                                ,r_calc_param.period_year - r_calc_param.t
                                ,r_calc_param.gender_type
                                ,r_calc_param.k_coef
                                ,r_calc_param.s_coef
                                ,r_calc_param.deathrate_id
                                ,r_calc_param.normrate);
      --sumGt := (r_add_info.fee_prev / Km) * r_calc_param.t;
      sumgt     := ((nex_s * (1 - r_calc_param.f) * r_add_info.ins_amount_prev /
                   ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) / (1 - r_calc_param.f)) * r_calc_param.t;
      v_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                     ,r_calc_param.period_year - r_calc_param.t
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      v_ia1xn   := ins.pkg_amath.iax1n(r_calc_param.age + r_calc_param.t
                                      ,r_calc_param.period_year - r_calc_param.t
                                      ,r_calc_param.gender_type
                                      ,r_calc_param.k_coef
                                      ,r_calc_param.s_coef
                                      ,r_calc_param.deathrate_id
                                      ,r_calc_param.normrate);
      v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                     ,r_calc_param.period_year - r_calc_param.t
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,1
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      v_a_xn_i  := ins.pkg_amath.a_xn(r_calc_param.age
                                     ,r_calc_param.period_year
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,1
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      --для резерва
      vt_1_nex   := ins.pkg_amath.nex(r_calc_param.age + (r_calc_param.t - 1)
                                     ,r_calc_param.period_year - (r_calc_param.t - 1)
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      vt_1_a1xn  := ins.pkg_amath.ax1n(r_calc_param.age + (r_calc_param.t - 1)
                                      ,r_calc_param.period_year - (r_calc_param.t - 1)
                                      ,r_calc_param.gender_type
                                      ,r_calc_param.k_coef
                                      ,r_calc_param.s_coef
                                      ,r_calc_param.deathrate_id
                                      ,r_calc_param.normrate);
      vt_1_ia1xn := ins.pkg_amath.iax1n(r_calc_param.age + (r_calc_param.t - 1)
                                       ,r_calc_param.period_year - (r_calc_param.t - 1)
                                       ,r_calc_param.gender_type
                                       ,r_calc_param.k_coef
                                       ,r_calc_param.s_coef
                                       ,r_calc_param.deathrate_id
                                       ,r_calc_param.normrate);
      --sumGt_1 := (r_add_info.fee_prev / Km) * (r_calc_param.t-1);
      sumgt_1      := ((nex_s * (1 - r_calc_param.f) * r_add_info.ins_amount_prev /
                      ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) / (1 - r_calc_param.f)) *
                      (r_calc_param.t - 1);
      vt_1_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + (r_calc_param.t - 1)
                                        ,r_calc_param.period_year - (r_calc_param.t - 1)
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,1
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
      vt_1_a_xn_i  := ins.pkg_amath.a_xn(r_calc_param.age
                                        ,r_calc_param.period_year
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,1
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
      --Vt_1 := (r_add_info.ins_amount_prev * vt_1_nEx) + (sumGt_1 * vt_1_A1xn) + ((r_add_info.fee_prev / Km) * vt_1_IA1xn) - ((r_add_info.fee_prev / Km) * (1 - r_calc_param.f) * vt_1_a_xn_re);
      vt_1 := (r_add_info.ins_amount_prev * vt_1_nex) + (sumgt_1 * vt_1_a1xn) +
              ((nex_s * r_add_info.ins_amount_prev / ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) *
              vt_1_ia1xn) - ((nex_s * (1 - r_calc_param.f) * r_add_info.ins_amount_prev /
              ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) * vt_1_a_xn_re);
      --
      --Vt := (r_add_info.ins_amount_prev * v_nEx) + (sumGt * v_A1xn) + ((r_add_info.fee_prev / Km) * v_IA1xn) - ((r_add_info.fee_prev / Km) * (1 - r_calc_param.f) * v_a_xn_re);
      vt   := (r_add_info.ins_amount_prev * v_nex) + (sumgt * v_a1xn) +
              ((nex_s * r_add_info.ins_amount_prev / ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) *
              v_ia1xn) - ((nex_s * (1 - r_calc_param.f) * r_add_info.ins_amount_prev /
              ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) * v_a_xn_re);
      a    := g_n / ((nex_s * (1 - r_calc_param.f) * r_add_info.ins_amount_prev /
              ((1 - r_calc_param.f) * a_xn_s - ia1xn_s)) / (1 - r_calc_param.f));
      vt_n := vt * a;
    ELSIF r_calc_param.brief = 'TERM'
          AND r_calc_param.dop_brief <> 'I2'
          AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      --для пересчета ставки
      a1xn_s := ins.pkg_amath.ax1n(r_calc_param.age
                                  ,r_calc_param.period_year
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.s_coef
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.normrate);
      a_xn_s := ins.pkg_amath.a_xn(r_calc_param.age
                                  ,r_calc_param.period_year
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.s_coef
                                  ,1
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.normrate);
      --
      v_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                     ,r_calc_param.period_year - r_calc_param.t
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                     ,r_calc_param.period_year - r_calc_param.t
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,1
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      --для резерва
      vt_1_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + (r_calc_param.t - 1)
                                        ,r_calc_param.period_year - (r_calc_param.t - 1)
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
      vt_1_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + (r_calc_param.t - 1)
                                        ,r_calc_param.period_year - (r_calc_param.t - 1)
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,1
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
      --Vt_1 := r_add_info.ins_amount_prev * vt_1_A1xn - (r_add_info.fee_prev / Km) * (1 - r_calc_param.f) * vt_1_a_xn_re;
      vt_1 := r_add_info.ins_amount_prev * vt_1_a1xn -
              (a1xn_s / a_xn_s * r_add_info.ins_amount_prev) * vt_1_a_xn_re;
      --
      --Vt := r_add_info.ins_amount_prev * v_A1xn - (r_add_info.fee_prev / Km) * (1 - r_calc_param.f) * v_a_xn_re;
      vt   := r_add_info.ins_amount_prev * v_a1xn -
              (a1xn_s / a_xn_s * r_add_info.ins_amount_prev) * v_a_xn_re;
      a    := g_n / ((a1xn_s / a_xn_s * r_add_info.ins_amount_prev) / (1 - r_calc_param.f));
      vt_n := vt * a;
    ELSE
      NULL;
    END IF;
  
    /*
    **Методика. Шаг 4
    */
  
    v_ft := ft(par_policy_id
              ,par_cover_id
              ,r_calc_param.period_year
              ,r_calc_param.t
              ,r_calc_param.is_one_payment);
  
    IF r_calc_param.header_start_date <= to_date('30.03.2007', 'dd.mm.yyyy')
    THEN
      a_z := 0.03;
    ELSE
      a_z := 0.04;
    END IF;
  
    IF (r_calc_param.brief = 'END')
       AND r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
    
      vzt   := vt - (a_z * (r_add_info.ins_amount_prev - vt));
      vzt_1 := vt_1 - (a_z * (r_add_info.ins_amount_prev - vt_1));
      vbt   := (vzt + vzt_1 + ((r_add_info.fee_prev / km) * (1 - r_calc_param.f))) / 2;
      --VBt := (VZt + VZt_1+ (((Axn_s / a_xn_s) * r_add_info.ins_amount_prev))) / 2;
    
      IF r_calc_param.t IN (1, 2)
      THEN
        cvt := 0;
      ELSE
        cvt := ROUND(v_ft * vbt, 6);
      END IF;
      cvt_n := cvt * (1 - a);
    
    ELSIF (r_calc_param.dop_brief = 'I2' OR r_calc_param.dop_brief IN ('INVEST2', 'INVEST') OR
          r_calc_param.brief = 'PEPR')
    THEN
    
      vzt   := vt - a_z * r_add_info.ins_amount_prev * (v_a_xn_re / v_a_xn_i);
      vzt_1 := vt_1 - a_z * r_add_info.ins_amount_prev * (vt_1_a_xn_re / vt_1_a_xn_i);
      vbt   := (vzt + vzt_1 + ((r_add_info.fee_prev / km) * (1 - r_calc_param.f))) / 2;
      --VBt := (VZt + VZt_1+ ((nEx_s*(1-r_calc_param.f)*r_add_info.ins_amount_prev/((1-r_calc_param.f)*a_xn_s-IA1xn_s)))) / 2;
    
      IF r_calc_param.brief = 'PEPR'
      THEN
        IF r_calc_param.t IN (1, 2)
        THEN
          cvt := 0;
        ELSE
          cvt := ROUND(v_ft * vbt, 6);
        END IF;
      ELSE
        cvt := ROUND(v_ft * vbt, 6);
      END IF;
      IF cvt < 0
      THEN
        cvt := 0;
      END IF;
      cvt_n := cvt * (1 - a);
    
    ELSE
      NULL;
    END IF;
  
    /*
    **Методика. Расчет новой страховой суммы
    */
  
    IF r_calc_param.brief = 'END'
       AND r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      s_n := FLOOR((vt_n + 0.9 * cvt_n + p_n * v_a_xn_re) / v_axn_re);
    ELSIF r_calc_param.brief = 'PEPR'
          OR (r_calc_param.dop_brief = 'I2' OR r_calc_param.dop_brief IN ('INVEST2', 'INVEST'))
    THEN
      s_n := FLOOR((vt_n + 0.9 * cvt_n - sumgt * v_a1xn - g_n * v_ia1xn + p_n * v_a_xn_re) / v_nex);
    ELSIF r_calc_param.brief = 'TERM'
          AND r_calc_param.dop_brief <> 'I2'
          AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      s_n := FLOOR((vt_n + p_n * v_a_xn_re) / v_a1xn);
    ELSE
      NULL;
    END IF;
  
    /*
    **Запись всех значений в базу
    */
  
    CASE r_calc_param.payment_terms_id
      WHEN 162 THEN
        kt := 2;
      WHEN 165 THEN
        kt := 4;
      WHEN 166 THEN
        kt := 12;
      ELSE
        kt := 1;
    END CASE;
  
    --Основная программа или Инвест
    UPDATE ven_p_cover p
       SET p.ins_amount           = s_n
          ,p.fee                  = p_new_fee
          ,p.premium              = p_new_fee * kt
          ,p.is_handchange_amount = 1
          ,p.is_handchange_tariff = 1
          ,p.is_handchange_fee    = 1
     WHERE p.p_cover_id = par_cover_id;
    UPDATE ven_p_cover p
       SET p.tariff_netto = p_n / s_n --pkg_cover.calc_tariff_netto(p.p_cover_id)
     WHERE p.p_cover_id = par_cover_id;
    UPDATE ven_p_cover p
       SET p.tariff =
           (p_n / s_n) / (1 - r_calc_param.f) --pkg_cover.calc_tariff(p.p_cover_id)
     WHERE p.p_cover_id = par_cover_id;
  
    IF r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      --Поиск остальных рисков кроме Инвест
    
      OPEN cur_cover;
      LOOP
        FETCH cur_cover
          INTO pd_p_cover_id
              ,pd_p_brief
              ,pd_p_description
              ,pd_p_old_ins_amount
              ,pd_p_tariff
              ,pd_p_koef
              ,pd_p_k
              ,pd_p_s
              ,pd_p_f
              ,pd_p_old_fee
              ,pd_p_period_year;
        EXIT WHEN cur_cover%NOTFOUND;
      
        IF pd_p_brief IN ('AD'
                         ,'ADis'
                         ,'ADis_any'
                         ,'ATD'
                         ,'Dism'
                         ,'H'
                         ,'H_any'
                         ,'Surg'
                         ,'Surg_ACC'
                         ,'Surg_any'
                         ,'TPD'
                         ,'INS_ACC')
        THEN
          IF pd_p_brief = 'TPD'
          THEN
            s_nd := FLOOR((s_n * pd_p_old_ins_amount) / r_add_info.ins_amount_prev * pd_p_koef);
          ELSE
            s_nd := FLOOR(s_n * pd_p_koef);
          END IF;
          g_nd := s_nd * (pd_p_tariff * pd_p_k + pd_p_s) * km;
        
          UPDATE ven_p_cover p
             SET p.ins_amount           = s_nd
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
                ,p.tariff               = pd_p_tariff * pd_p_k + pd_p_s
           WHERE p.p_cover_id = pd_p_cover_id;
        
        ELSIF pd_p_brief IN ('DD')
        THEN
          s_nd := FLOOR((s_n * pd_p_old_ins_amount) / r_add_info.ins_amount_prev);
          --
          v_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,
                                          --r_calc_param.k_coef,
                                          ((pd_p_k * 100) - 100) / 100
                                         ,pd_p_s / 1000
                                         ,
                                          --r_calc_param.s_coef,
                                          41
                                         ,r_calc_param.normrate);
          v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,
                                          --r_calc_param.k_coef,
                                          --r_calc_param.s_coef,
                                          ((pd_p_k * 100) - 100) / 100
                                         ,pd_p_s / 1000
                                         ,1
                                         ,41
                                         ,r_calc_param.normrate);
          --
          a1xn_dd := ins.pkg_amath.ax1n(r_calc_param.age
                                       ,pd_p_period_year
                                       ,r_calc_param.gender_type
                                       ,((pd_p_k * 100) - 100) / 100
                                       ,pd_p_s / 1000
                                       ,41
                                       ,r_calc_param.normrate);
          a_xn_dd := ins.pkg_amath.a_xn(r_calc_param.age
                                       ,pd_p_period_year
                                       ,r_calc_param.gender_type
                                       ,((pd_p_k * 100) - 100) / 100
                                       ,pd_p_s / 1000
                                       ,1
                                       ,41
                                       ,r_calc_param.normrate);
          --
          --P_nd := (pd_p_old_fee / Km * (1 - pd_p_f)) + (S_nd - pd_p_old_ins_amount)*(v_A1xn/v_a_xn_re);
          p_nd := (s_nd * v_a1xn - (pd_p_old_ins_amount * v_a1xn -
                  (a1xn_dd / a_xn_dd * pd_p_old_ins_amount) * v_a_xn_re)) / v_a_xn_re;
          g_nd := p_nd / (1 - pd_p_f);
        
          UPDATE ven_p_cover p
             SET p.ins_amount           = s_nd
                ,p.fee                  = CEIL(g_nd * km)
                ,p.premium              = CEIL(g_nd * km) * kt
                ,p.is_handchange_tariff = 1
           WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p SET p.tariff_netto = p_nd / s_nd WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p
             SET p.tariff =
                 (p_nd / s_nd) / (1 - pd_p_f)
           WHERE p.p_cover_id = pd_p_cover_id;
        
        ELSIF pd_p_brief IN ('TERM_2', 'TERM', 'PPJL')
        THEN
          s_nd      := FLOOR((s_n * pd_p_old_ins_amount) / r_add_info.ins_amount_prev);
          v_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,r_calc_param.k_coef
                                         ,r_calc_param.s_coef
                                         ,r_calc_param.deathrate_id
                                         ,r_calc_param.normrate);
          v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,r_calc_param.k_coef
                                         ,r_calc_param.s_coef
                                         ,1
                                         ,r_calc_param.deathrate_id
                                         ,r_calc_param.normrate);
          vt_nd     := (pd_p_old_ins_amount * v_a1xn - (pd_p_old_fee / km) * (1 - pd_p_f) * v_a_xn_re) /** a*/
           ;
          p_nd      := (s_nd * v_a1xn - vt_nd) / v_a_xn_re;
          g_nd      := p_nd / (1 - pd_p_f) * km;
        
          UPDATE ven_p_cover p
             SET p.ins_amount           = s_nd
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
           WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p SET p.tariff_netto = p_nd / s_nd WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p
             SET p.tariff =
                 (p_nd / s_nd) / (1 - pd_p_f)
           WHERE p.p_cover_id = pd_p_cover_id;
        
        ELSE
          NULL;
        END IF;
      
      END LOOP;
      CLOSE cur_cover;
    
      OPEN cur_cover;
      LOOP
        FETCH cur_cover
          INTO pd_p_cover_id
              ,pd_p_brief
              ,pd_p_description
              ,pd_p_old_ins_amount
              ,pd_p_tariff
              ,pd_p_koef
              ,pd_p_k
              ,pd_p_s
              ,pd_p_f
              ,pd_p_old_fee
              ,pd_p_period_year;
        EXIT WHEN cur_cover%NOTFOUND;
        --Защита и Освобождение рассчитанное по Основной
        IF pd_p_brief IN ('PWOP', 'PWOP_life', 'WOP', 'WOP_life')
        THEN
        
          CASE r_calc_param.payment_terms_id
            WHEN 162 THEN
              km := 0.50;
            WHEN 165 THEN
              km := 0.25;
            WHEN 166 THEN
              km := 0.08333;
            ELSE
              km := 1;
          END CASE;
        
          SELECT SUM(pc.fee)
            INTO pc_fee_osn
            FROM ven_t_lob_line         ll
                ,ven_t_prod_line_rate   lr
                ,ven_t_product_line     pl
                ,ven_t_prod_line_option opt
                ,t_product_line_type    plt
                ,ven_p_cover            pc
                ,as_asset               a
           WHERE 1 = 1
             AND a.p_policy_id = par_policy_id
             AND opt.id = pc.t_prod_line_option_id
             AND pl.id = opt.product_line_id
             AND ll.t_lob_line_id = pl.t_lob_line_id
             AND lr.product_line_id(+) = pl.id
             AND pl.product_line_type_id = plt.product_line_type_id
             AND plt.brief IN ('RECOMMENDED')
             AND ll.brief NOT IN ('Adm_Cost_Life', 'Adm_Cost_Acc', 'I2', 'INVEST2', 'INVEST')
             AND a.as_asset_id = pc.as_asset_id;
          g_nd := (pc_fee_osn * kt) * ((pd_p_tariff * pd_p_k + pd_p_s) * km);
        
          UPDATE ven_p_cover p
             SET p.ins_amount          =
                 (pc_fee_osn * kt)
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
                ,p.tariff               = pd_p_tariff * pd_p_k + pd_p_s
           WHERE p.p_cover_id = pd_p_cover_id;
        
        END IF;
        --Защита и Освобождение рассчитанное по сумме взносов
        IF pd_p_brief IN ('PWOP_old', 'PWOP_life_old', 'WOP_old', 'WOP_life_old')
        THEN
        
          CASE r_calc_param.payment_terms_id
            WHEN 162 THEN
              km := 0.50;
            WHEN 165 THEN
              km := 0.25;
            WHEN 166 THEN
              km := 0.08333;
            ELSE
              km := 1;
          END CASE;
        
          SELECT SUM(pc.fee)
            INTO pc_fee_osn
            FROM ven_t_lob_line         ll
                ,ven_t_prod_line_rate   lr
                ,ven_t_product_line     pl
                ,ven_t_prod_line_option opt
                ,t_product_line_type    plt
                ,ven_p_cover            pc
                ,as_asset               a
           WHERE 1 = 1
             AND a.p_policy_id = par_policy_id
             AND opt.id = pc.t_prod_line_option_id
             AND pl.id = opt.product_line_id
             AND ll.t_lob_line_id = pl.t_lob_line_id
             AND lr.product_line_id(+) = pl.id
             AND pl.product_line_type_id = plt.product_line_type_id
             AND ll.brief NOT IN ('Adm_Cost_Life'
                                 ,'Adm_Cost_Acc'
                                 ,'I2'
                                 ,'INVEST2'
                                 ,'PWOP'
                                 ,'PWOP_life'
                                 ,'WOP'
                                 ,'WOP_life'
                                 ,'INVEST')
             AND a.as_asset_id = pc.as_asset_id;
          g_nd := (pc_fee_osn * kt) * ((pd_p_tariff * pd_p_k + pd_p_s) * km);
        
          UPDATE ven_p_cover p
             SET p.ins_amount          =
                 (pc_fee_osn * kt)
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
                ,p.tariff               = pd_p_tariff * pd_p_k + pd_p_s
           WHERE p.p_cover_id = pd_p_cover_id;
        
        END IF;
      
      END LOOP;
      CLOSE cur_cover;
      ----
    END IF;
  
  END;

  /*
  Методика увеличения страховой суммы
  10.05.2011 Веселуха
  */
  PROCEDURE resumpolicy(par_policy_id IN PLS_INTEGER) IS
    is_exist NUMBER := 0; --наличие доп соглашения Увеличение размера страховой суммы
    not_exist EXCEPTION;
    cover_info          add_info;
    p_p_cover_id        NUMBER;
    p_new_amount        NUMBER;
    p_method            NUMBER;
    p_header_start_date DATE;
    no_exist_add EXCEPTION;
    proc_name VARCHAR2(25) := 'ReSumPolicy';
  
    CURSOR cur_recover IS
      SELECT pc.p_cover_id
            ,pc.ins_amount p_new_amount
        FROM ven_t_lob_line         ll
            ,ven_t_prod_line_rate   lr
            ,ven_t_product_line     pl
            ,ven_t_prod_line_option opt
            ,t_product_line_type    plt
            ,ven_p_cover            pc
            ,as_asset               a
       WHERE 1 = 1
         AND a.p_policy_id = par_policy_id
         AND opt.id = pc.t_prod_line_option_id
         AND pl.id = opt.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND lr.product_line_id(+) = pl.id
         AND pl.product_line_type_id = plt.product_line_type_id
         AND (plt.brief IN ('RECOMMENDED')
             /*or ll.brief in ('I2','INVEST2')*/
             )
         AND ll.brief NOT IN ('Adm_Cost_Life', 'Adm_Cost_Acc')
         AND a.as_asset_id = pc.as_asset_id;
  
  BEGIN
  
    SELECT COUNT(*)
      INTO is_exist
      FROM p_policy            pp
          ,p_pol_addendum_type tp
          ,t_addendum_type     t
     WHERE pp.policy_id = tp.p_policy_id
       AND t.t_addendum_type_id = tp.t_addendum_type_id
       AND t.description = 'Увеличение размера страховой суммы'
       AND pp.policy_id = par_policy_id;
  
    IF nvl(is_exist, 0) > 0
    THEN
    
      OPEN cur_recover;
      LOOP
        FETCH cur_recover
          INTO p_p_cover_id
              ,p_new_amount;
        EXIT WHEN cur_recover%NOTFOUND;
        cover_info := get_add_info(p_p_cover_id);
        IF cover_info.ins_amount_prev < cover_info.ins_amount_curr
        THEN
          resum(par_policy_id, p_new_amount, p_p_cover_id, 0);
        ELSE
          RAISE no_exist_add;
        END IF;
      END LOOP;
      CLOSE cur_recover;
    
      BEGIN
        SELECT ins.pkg_pol_cash_surr_method.metod_f_t(pp.policy_id)
              ,ph.start_date
          INTO p_method
              ,p_header_start_date
          FROM p_policy     p
              ,p_pol_header ph
              ,p_policy     pp
         WHERE p.policy_id = par_policy_id
           AND ph.policy_header_id = p.pol_header_id
           AND pp.pol_header_id = p.pol_header_id
           AND pp.version_num = p.version_num - 1;
      EXCEPTION
        WHEN no_data_found THEN
          p_method            := 2;
          p_header_start_date := to_date('01.02.2009', 'dd.mm.yyyy');
      END;
    
      IF p_header_start_date < to_date('01.02.2009', 'dd.mm.yyyy')
      THEN
        ins.pkg_pol_cash_surr_method.set_metod_f_t(par_policy_id, p_method);
      ELSE
        ins.pkg_pol_cash_surr_method.set_metod_f_t(par_policy_id, 2);
      END IF;
    
    ELSE
      NULL;
    END IF;
  
  EXCEPTION
    WHEN no_exist_add THEN
      raise_application_error(-20001
                             ,'Страховая сумма по предыдущей версии ' || cover_info.ins_amount_prev ||
                              ' больше или равна сумме текущей версии: ' ||
                              cover_info.ins_amount_curr || '. Версия не может быть создана.');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
    
  END;

  PROCEDURE resum
  (
    par_policy_id IN NUMBER
   ,p_new_amount  IN NUMBER
   ,par_cover_id  IN NUMBER
   ,p_re_sign     IN NUMBER DEFAULT NULL
  ) IS
  
    r_calc_param        calc_param;
    r_add_info          add_info;
    km                  NUMBER; --коэффициент рассрочки
    kt                  NUMBER;
    g_n                 NUMBER; --новая годовая брутто премия
    g                   NUMBER;
    a                   NUMBER; --доля новой годовой брутто премии
    p                   NUMBER; --старая годовая нетто премия
    p_n                 NUMBER; --новая годовая нетто премия
    v_axn_re            NUMBER; --единовременная нетто-ставка при смешанном (дожитие и смерть) страховании
    v_a_xn_re           NUMBER; --аннуитет пренумерандо при сроке страхования n лет
    v_axn_re1           NUMBER; --единовременная нетто-ставка при смешанном (дожитие и смерть) страховании
    v_a_xn_re1          NUMBER; --аннуитет пренумерандо при сроке страхования n лет
    vt                  NUMBER; --математический нетто резерв в момент времени t
    vt_n                NUMBER; --доля от нетто резерва, которая участвует в расчете новой страховой суммы
    v_ft                NUMBER; --доля от страхового резерва
    vbt                 NUMBER; --балансовый резерв, рассчитанный на дату изменения
    cvt                 NUMBER; --выкупная сумма
    cvt_n               NUMBER; --доля от выкупной суммы
    s_n                 NUMBER; --новая страховая сумма
    v_nex               NUMBER; --единовременная нетто ставка на дожитие
    sumgt               NUMBER; --сумма годовых брутто взносов за период равный t
    sumgt_1             NUMBER; --сумма годовых брутто взносов за период равный t-1
    v_a1xn              NUMBER; --единовременная нетто ставка при страховании на случай смерти (выплата сразу после смерти) на срок n лет
    v_ia1xn             NUMBER; --единовременная нетто ставка при страховании на случай смерти (выплата сразу после смерти Застрахованного) на срок n лет
    s_nd                NUMBER; --страховая сумма по риску новая
    g_nd                NUMBER; --брутто взнос по риску новый
    p_nd                NUMBER; --нетто взнос по риску новый
    vt_nd               NUMBER; --доля от нетто резерва, которая участвует в расчете новой страховой суммы по риску
    pc_fee_osn          NUMBER;
    a_z                 NUMBER; --фактор Цильмера
    vt_1                NUMBER;
    vzt                 NUMBER; --резерв Цильмера на t
    vzt_1               NUMBER; --резерв Цильмера на t-1
    vt_1_axn_re         NUMBER;
    vt_1_a_xn_re        NUMBER;
    vt_1_a1xn           NUMBER;
    vt_1_nex            NUMBER;
    vt_1_ia1xn          NUMBER;
    v_a_xn_i            NUMBER;
    vt_1_a_xn_i         NUMBER;
    pd_p_cover_id       NUMBER;
    pd_p_brief          VARCHAR2(50);
    pd_p_description    VARCHAR2(150);
    pd_p_new_ins_amount NUMBER;
    pd_p_old_ins_amount NUMBER;
    pd_p_tariff         NUMBER;
    pd_p_f              NUMBER;
    pd_p_new_fee        NUMBER;
    pd_p_period_year    NUMBER;
    pd_p_k              NUMBER;
    pd_p_s              NUMBER;
    pd_p_koef           NUMBER;
  
    axn_s   NUMBER;
    a_xn_s  NUMBER;
    nex_s   NUMBER;
    ia1xn_s NUMBER;
    a1xn_s  NUMBER;
    vt_a_xn NUMBER;
    bt      NUMBER;
  
    a_xn_dd NUMBER;
    a1xn_dd NUMBER;
  
    CURSOR cur_cover IS
      SELECT pc.p_cover_id
            ,CASE
               WHEN opt.description = 'Защита страховых взносов' THEN
                ll.brief || '_old'
               WHEN opt.description = 'Освобождение от уплаты дальнейших взносов' THEN
                ll.brief || '_old'
               WHEN opt.description = 'Освобождение от уплаты страховых взносов' THEN
                ll.brief || '_old'
               ELSE
                ll.brief
             END brief
            ,ll.description
            ,pc.ins_amount new_ins_amount
            ,CASE
               WHEN ll.brief = 'AD' THEN
                pkg_tariff_calc.calc_fun(7726, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('H') THEN
                pkg_tariff_calc.calc_fun(7728, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('H_any') THEN
                pkg_tariff_calc.calc_fun(7766, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('ADis', 'ADis_any') THEN
                pkg_tariff_calc.calc_fun(7727, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('ATD') THEN
                pkg_tariff_calc.calc_fun(7730, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('TPD') THEN
                pkg_tariff_calc.calc_fun(7731, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('Dism') THEN
                pkg_tariff_calc.calc_fun(7729, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('Surg') THEN
                pkg_tariff_calc.calc_fun(6363, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('WOP', 'WOP_Life') THEN
                pkg_tariff_calc.calc_fun(3645, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               WHEN ll.brief IN ('PWOP_Life', 'PWOP') THEN
                pkg_tariff_calc.calc_fun(3791, ent.id_by_brief('P_COVER'), pc.p_cover_id)
               ELSE
                pc.tariff
             END tariff
             /*,CASE
               WHEN ll.brief IN ('AD') THEN
                1 --смерть
               WHEN ll.brief IN ('ADis', 'ADis_any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 1) --инвалидность
               WHEN ll.brief IN ('H', 'H_any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.5) --госпитализация
               WHEN ll.brief IN ('ATD', 'ATD_Any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.75) --временная утрата трудоспособности
               WHEN ll.brief IN ('Dism') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.75) --телесные повреждения
               WHEN ll.brief IN ('Surg', 'Surg_ACC', 'Surg_any') THEN
                LEAST((pc.ins_amount / pc_ad.ins_amount), 0.5) --хирургические вмешательства
               ELSE
                1
             END koef*/
            ,CASE
               WHEN ll.brief IN ('AD'
                                ,'ADis'
                                ,'ADis_any'
                                ,'H'
                                ,'H_any'
                                ,'ATD'
                                ,'ATD_Any'
                                ,'Dism'
                                ,'Surg'
                                ,'Surg_ACC'
                                ,'Surg_any') THEN
                (SELECT pca.ins_amount
                   FROM ins.p_policy poli
                       ,ins.as_asset ass
                       ,ins.p_cover  pca
                  WHERE poli.policy_id = pol.prev_ver_id
                    AND poli.policy_id = ass.p_policy_id
                    AND ass.as_asset_id = pca.as_asset_id
                    AND pca.t_prod_line_option_id = opt.id) /
                (SELECT p.ins_amount
                   FROM ins.p_policy            pi
                       ,ins.as_asset            aa
                       ,ins.p_cover             p
                       ,ins.t_prod_line_option  ot
                       ,ins.t_product_line      tpl
                       ,ins.t_product_line_type t
                  WHERE pi.policy_id = pol.prev_ver_id
                    AND aa.p_policy_id = pi.policy_id
                    AND aa.as_asset_id = p.as_asset_id
                    AND p.t_prod_line_option_id = ot.id
                    AND ot.product_line_id = tpl.id
                    AND tpl.product_line_type_id = t.product_line_type_id
                    AND t.brief = 'RECOMMENDED')
               ELSE
                1
             END koef
            ,(nvl(greatest(nvl(pc.k_coef_m, pc.k_coef_nm), nvl(pc.k_coef_nm, pc.k_coef_m)), 0) + 100) / 100 k
            ,nvl(greatest(nvl(pc.s_coef_m, pc.s_coef_nm), nvl(pc.s_coef_nm, pc.s_coef_m)), 0) s
            ,pc.rvb_value f
            ,pc.fee new_fee
            ,trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12) period_year
            ,old_pc.ins_amount old_ins_amount
        FROM ins.t_lob_line ll
            ,ins.t_prod_line_rate lr
            ,ins.t_product_line pl
            ,ins.t_prod_line_option opt
            ,ins.t_product_line_type plt
            ,ins.p_cover pc
            ,ins.as_asset a
            ,ins.p_policy pol
            ,(SELECT opt_prev.id
                    ,pc_prev.p_cover_id
                    ,pc_prev.ins_amount
                FROM ins.p_policy           p_cur
                    ,ins.p_policy           p_prev
                    ,ins.as_asset           a_prev
                    ,ins.p_cover            pc_prev
                    ,ins.t_prod_line_option opt_prev
                    ,ins.document           d_cur
                    ,ins.doc_status_ref     rf_cur
               WHERE p_cur.policy_id = par_policy_id
                 AND p_prev.pol_header_id = p_cur.pol_header_id
                 AND p_prev.version_num = p_cur.version_num - 1
                 AND a_prev.p_policy_id = p_prev.policy_id
                 AND pc_prev.as_asset_id = a_prev.as_asset_id
                 AND pc_prev.t_prod_line_option_id = opt_prev.id
                 AND p_cur.policy_id = d_cur.document_id
                 AND d_cur.doc_status_ref_id = rf_cur.doc_status_ref_id
                 AND rf_cur.brief != 'CANCEL') old_pc
       WHERE 1 = 1
         AND a.p_policy_id = par_policy_id
         AND a.p_policy_id = pol.policy_id
         AND opt.id = pc.t_prod_line_option_id
         AND pl.id = opt.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND lr.product_line_id(+) = pl.id
         AND pl.product_line_type_id = plt.product_line_type_id
         AND plt.brief NOT IN ('RECOMMENDED')
         AND ll.brief NOT IN
             ('Adm_Cost_Life', 'Adm_Cost_Acc', 'I2', 'INVEST2', 'PEPR_INVEST_RESERVE', 'INVEST')
         AND a.as_asset_id = pc.as_asset_id
         AND opt.id = old_pc.id(+);
  
  BEGIN
    r_calc_param := get_calc_param(par_cover_id, p_re_sign);
    r_add_info   := get_add_info(par_cover_id);
  
    CASE r_calc_param.payment_terms_id
      WHEN 162 THEN
        km := 0.53;
      WHEN 165 THEN
        km := 0.27;
      WHEN 166 THEN
        km := 0.09;
      ELSE
        km := 1;
    END CASE;
  
    IF r_calc_param.brief = 'END'
       AND r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      v_axn_re := ins.pkg_amath.axn(r_calc_param.age + r_calc_param.t
                                   ,r_calc_param.period_year - r_calc_param.t
                                   ,r_calc_param.gender_type
                                   ,r_calc_param.k_coef
                                   ,r_calc_param.s_coef
                                   ,r_calc_param.deathrate_id
                                   ,r_calc_param.normrate);
      --
      v_a_xn_re    := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                        ,r_calc_param.period_year - r_calc_param.t
                                        ,r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,1
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
      vt_1_axn_re  := ins.pkg_amath.axn(r_calc_param.age
                                       , -- + r_calc_t,
                                        r_calc_param.period_year
                                       , -- - r_calc_t,
                                        r_calc_param.gender_type
                                       ,r_calc_param.k_coef
                                       ,r_calc_param.s_coef
                                       ,r_calc_param.deathrate_id
                                       ,r_calc_param.normrate);
      vt_1_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age
                                        , -- + r_calc_t,
                                         r_calc_param.period_year
                                        , -- - r_calc_t,
                                         r_calc_param.gender_type
                                        ,r_calc_param.k_coef
                                        ,r_calc_param.s_coef
                                        ,1
                                        ,r_calc_param.deathrate_id
                                        ,r_calc_param.normrate);
    
      p   := (r_add_info.ins_amount_prev * vt_1_axn_re) / vt_1_a_xn_re;
      p_n := p + (p_new_amount - r_add_info.ins_amount_prev) * (v_axn_re / v_a_xn_re);
      g_n := p_n / (1 - r_calc_param.f);
    
    ELSIF r_calc_param.brief = 'PEPR'
          OR (r_calc_param.dop_brief = 'I2' OR r_calc_param.dop_brief IN ('INVEST2', 'INVEST'))
    THEN
    
      vt_1_nex   := ins.pkg_amath.nex(r_calc_param.age + (r_calc_param.t - 1)
                                     ,r_calc_param.period_year - (r_calc_param.t - 1)
                                     ,r_calc_param.gender_type
                                     ,r_calc_param.k_coef
                                     ,r_calc_param.s_coef
                                     ,r_calc_param.deathrate_id
                                     ,r_calc_param.normrate);
      vt_1_a1xn  := ins.pkg_amath.ax1n(r_calc_param.age + (r_calc_param.t - 1)
                                      ,r_calc_param.period_year - (r_calc_param.t - 1)
                                      ,r_calc_param.gender_type
                                      ,r_calc_param.k_coef
                                      ,r_calc_param.s_coef
                                      ,r_calc_param.deathrate_id
                                      ,r_calc_param.normrate);
      vt_1_ia1xn := ins.pkg_amath.iax1n(r_calc_param.age + (r_calc_param.t - 1)
                                       ,r_calc_param.period_year - (r_calc_param.t - 1)
                                       ,r_calc_param.gender_type
                                       ,r_calc_param.k_coef
                                       ,r_calc_param.s_coef
                                       ,r_calc_param.deathrate_id
                                       ,r_calc_param.normrate);
      vt_a_xn    := ins.pkg_amath.a_xn(r_calc_param.age
                                      ,r_calc_param.period_year
                                      ,r_calc_param.gender_type
                                      ,r_calc_param.k_coef
                                      ,r_calc_param.s_coef
                                      ,1
                                      ,r_calc_param.deathrate_id
                                      ,r_calc_param.normrate);
      g          := (r_add_info.ins_amount_prev * vt_1_nex) /
                    (vt_a_xn * (1 - r_calc_param.f) - vt_1_ia1xn);
      p          := g * (1 - r_calc_param.f);
      --------------------------   
      nex_s   := ins.pkg_amath.nex(r_calc_param.age + r_calc_param.t
                                  ,r_calc_param.period_year - r_calc_param.t
                                  ,r_calc_param.gender_type
                                  ,r_calc_param.k_coef
                                  ,r_calc_param.s_coef
                                  ,r_calc_param.deathrate_id
                                  ,r_calc_param.normrate);
      ia1xn_s := ins.pkg_amath.iax1n(r_calc_param.age + r_calc_param.t
                                    ,r_calc_param.period_year - r_calc_param.t
                                    ,r_calc_param.gender_type
                                    ,r_calc_param.k_coef
                                    ,r_calc_param.s_coef
                                    ,r_calc_param.deathrate_id
                                    ,r_calc_param.normrate);
      a_xn_s  := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                   ,r_calc_param.period_year - r_calc_param.t
                                   ,r_calc_param.gender_type
                                   ,r_calc_param.k_coef
                                   ,r_calc_param.s_coef
                                   ,1
                                   ,r_calc_param.deathrate_id
                                   ,r_calc_param.normrate);
      a1xn_s  := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                   ,r_calc_param.period_year - r_calc_param.t
                                   ,r_calc_param.gender_type
                                   ,r_calc_param.k_coef
                                   ,r_calc_param.s_coef
                                   ,r_calc_param.deathrate_id
                                   ,r_calc_param.normrate);
      bt      := ia1xn_s - (1 - r_calc_param.f) * a_xn_s;
      g_n     := g - (p_new_amount - r_add_info.ins_amount_prev) * (nex_s / bt);
      g_n     := CEIL(g_n * km);
      p_n     := g_n * (1 - r_calc_param.f);
    
    ELSE
      NULL;
    END IF;
  
    IF r_calc_param.brief = 'END'
       AND r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      g_n := CEIL(g_n * km);
    ELSIF r_calc_param.brief = 'PEPR'
          OR (r_calc_param.dop_brief = 'I2' OR r_calc_param.dop_brief IN ('INVEST2', 'INVEST'))
    THEN
      g_n := g_n;
    ELSE
      NULL;
    END IF;
  
    /*
    **Запись всех значений в базу
    */
  
    CASE r_calc_param.payment_terms_id
      WHEN 162 THEN
        kt := 2;
      WHEN 165 THEN
        kt := 4;
      WHEN 166 THEN
        kt := 12;
      ELSE
        kt := 1;
    END CASE;
  
    --Основная программа или Инвест
    UPDATE ven_p_cover p
       SET p.ins_amount            = p_new_amount
          ,p.fee                   = g_n
          ,p.premium               = g_n * kt
          ,p.is_handchange_amount  = 1
          ,p.is_handchange_tariff  = 1
          ,p.is_handchange_fee     = 1
          ,p.is_handchange_premium = 1
     WHERE p.p_cover_id = par_cover_id;
    UPDATE ven_p_cover p
       SET p.tariff_netto = p_n / p_new_amount --pkg_cover.calc_tariff_netto(p.p_cover_id)
     WHERE p.p_cover_id = par_cover_id;
    UPDATE ven_p_cover p
       SET p.tariff =
           (p_n / p_new_amount) / (1 - r_calc_param.f) --pkg_cover.calc_tariff(p.p_cover_id)
     WHERE p.p_cover_id = par_cover_id;
  
    IF r_calc_param.dop_brief <> 'I2'
       AND r_calc_param.dop_brief NOT IN ('INVEST2', 'INVEST')
    THEN
      --Поиск остальных рисков кроме Инвест
    
      OPEN cur_cover;
      LOOP
        FETCH cur_cover
          INTO pd_p_cover_id
              ,pd_p_brief
              ,pd_p_description
              ,pd_p_new_ins_amount
              ,pd_p_tariff
              ,pd_p_koef
              ,pd_p_k
              ,pd_p_s
              ,pd_p_f
              ,pd_p_new_fee
              ,pd_p_period_year
              ,pd_p_old_ins_amount;
        EXIT WHEN cur_cover%NOTFOUND;
      
        IF pd_p_brief IN ('AD'
                         ,'ADis'
                         ,'ADis_any'
                         ,'ATD'
                         ,'Dism'
                         ,'H'
                         ,'H_any'
                         ,'Surg'
                         ,'Surg_ACC'
                         ,'Surg_any'
                         ,'TPD'
                         ,'INS_ACC')
        THEN
        
          IF pd_p_brief = 'TPD'
          THEN
            s_nd := FLOOR((p_new_amount * pd_p_new_ins_amount) / r_add_info.ins_amount_prev *
                          pd_p_koef);
          ELSE
            s_nd := FLOOR(p_new_amount * pd_p_koef);
          END IF;
        
          IF pd_p_new_ins_amount = pd_p_old_ins_amount
          THEN
            s_nd := pd_p_old_ins_amount;
          ELSE
            s_nd := pd_p_new_ins_amount;
          END IF;
        
          g_nd := s_nd * (pd_p_tariff * pd_p_k + pd_p_s) * km;
        
          UPDATE ven_p_cover p
             SET p.ins_amount           = s_nd
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
                ,p.tariff               = pd_p_tariff * pd_p_k + pd_p_s
           WHERE p.p_cover_id = pd_p_cover_id;
        
        ELSIF pd_p_brief IN ('DD')
        THEN
          s_nd := FLOOR((p_new_amount * pd_p_new_ins_amount) / r_add_info.ins_amount_prev);
          --
          IF pd_p_new_ins_amount = pd_p_old_ins_amount
          THEN
            s_nd := pd_p_old_ins_amount;
          ELSE
            s_nd := pd_p_new_ins_amount;
          END IF;
          --
          v_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,((pd_p_k * 100) - 100) / 100
                                         ,pd_p_s / 1000
                                         ,41
                                         ,r_calc_param.normrate);
          v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,((pd_p_k * 100) - 100) / 100
                                         ,pd_p_s / 1000
                                         ,1
                                         ,41
                                         ,r_calc_param.normrate);
          --
          a1xn_dd := ins.pkg_amath.ax1n(r_calc_param.age
                                       ,pd_p_period_year
                                       ,r_calc_param.gender_type
                                       ,((pd_p_k * 100) - 100) / 100
                                       ,pd_p_s / 1000
                                       ,41
                                       ,r_calc_param.normrate);
          a_xn_dd := ins.pkg_amath.a_xn(r_calc_param.age
                                       ,pd_p_period_year
                                       ,r_calc_param.gender_type
                                       ,((pd_p_k * 100) - 100) / 100
                                       ,pd_p_s / 1000
                                       ,1
                                       ,41
                                       ,r_calc_param.normrate);
        
          p_nd := (s_nd * v_a1xn - (pd_p_new_ins_amount * v_a1xn -
                  (a1xn_dd / a_xn_dd * pd_p_new_ins_amount) * v_a_xn_re)) / v_a_xn_re;
          g_nd := p_nd / (1 - pd_p_f);
        
          UPDATE ven_p_cover p
             SET p.ins_amount           = s_nd
                ,p.fee                  = CEIL(g_nd * km)
                ,p.premium              = CEIL(g_nd * km) * kt
                ,p.is_handchange_tariff = 1
           WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p SET p.tariff_netto = p_nd / s_nd WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p
             SET p.tariff =
                 (p_nd / s_nd) / (1 - pd_p_f)
           WHERE p.p_cover_id = pd_p_cover_id;
        
        ELSIF pd_p_brief IN ('TERM_2', 'TERM', 'PPJL')
        THEN
          s_nd := FLOOR((p_new_amount * pd_p_new_ins_amount) / r_add_info.ins_amount_prev);
        
          IF pd_p_new_ins_amount = pd_p_old_ins_amount
          THEN
            s_nd := pd_p_old_ins_amount;
          ELSE
            s_nd := pd_p_new_ins_amount;
          END IF;
        
          v_a1xn    := ins.pkg_amath.ax1n(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,r_calc_param.k_coef
                                         ,r_calc_param.s_coef
                                         ,r_calc_param.deathrate_id
                                         ,r_calc_param.normrate);
          v_a_xn_re := ins.pkg_amath.a_xn(r_calc_param.age + r_calc_param.t
                                         ,pd_p_period_year - r_calc_param.t
                                         ,r_calc_param.gender_type
                                         ,r_calc_param.k_coef
                                         ,r_calc_param.s_coef
                                         ,1
                                         ,r_calc_param.deathrate_id
                                         ,r_calc_param.normrate);
          vt_nd     := (pd_p_new_ins_amount * v_a1xn - (pd_p_new_fee / km) * (1 - pd_p_f) * v_a_xn_re) /** a*/
           ;
          p_nd      := (s_nd * v_a1xn - vt_nd) / v_a_xn_re;
          g_nd      := p_nd / (1 - pd_p_f) * km;
        
          UPDATE ven_p_cover p
             SET p.ins_amount           = s_nd
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
           WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p SET p.tariff_netto = p_nd / s_nd WHERE p.p_cover_id = pd_p_cover_id;
          UPDATE ven_p_cover p
             SET p.tariff =
                 (p_nd / s_nd) / (1 - pd_p_f)
           WHERE p.p_cover_id = pd_p_cover_id;
        
        ELSE
          NULL;
        END IF;
      
      END LOOP;
      CLOSE cur_cover;
    
      OPEN cur_cover;
      LOOP
        FETCH cur_cover
          INTO pd_p_cover_id
              ,pd_p_brief
              ,pd_p_description
              ,pd_p_new_ins_amount
              ,pd_p_tariff
              ,pd_p_koef
              ,pd_p_k
              ,pd_p_s
              ,pd_p_f
              ,pd_p_new_fee
              ,pd_p_period_year
              ,pd_p_old_ins_amount;
        EXIT WHEN cur_cover%NOTFOUND;
        --Защита и Освобождение рассчитанное по Основной
        IF pd_p_brief IN ('PWOP', 'PWOP_life', 'WOP', 'WOP_life')
        THEN
        
          CASE r_calc_param.payment_terms_id
            WHEN 162 THEN
              km := 0.50;
            WHEN 165 THEN
              km := 0.25;
            WHEN 166 THEN
              km := 0.08333;
            ELSE
              km := 1;
          END CASE;
        
          SELECT SUM(pc.fee)
            INTO pc_fee_osn
            FROM ven_t_lob_line         ll
                ,ven_t_prod_line_rate   lr
                ,ven_t_product_line     pl
                ,ven_t_prod_line_option opt
                ,t_product_line_type    plt
                ,ven_p_cover            pc
                ,as_asset               a
           WHERE 1 = 1
             AND a.p_policy_id = par_policy_id
             AND opt.id = pc.t_prod_line_option_id
             AND pl.id = opt.product_line_id
             AND ll.t_lob_line_id = pl.t_lob_line_id
             AND lr.product_line_id(+) = pl.id
             AND pl.product_line_type_id = plt.product_line_type_id
             AND plt.brief IN ('RECOMMENDED')
             AND ll.brief NOT IN ('Adm_Cost_Life', 'Adm_Cost_Acc', 'I2', 'INVEST2', 'INVEST')
             AND a.as_asset_id = pc.as_asset_id;
          g_nd := (pc_fee_osn * kt) * ((pd_p_tariff * pd_p_k + pd_p_s) * km);
        
          UPDATE ven_p_cover p
             SET p.ins_amount          =
                 (pc_fee_osn * kt)
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
                ,p.tariff               = pd_p_tariff * pd_p_k + pd_p_s
           WHERE p.p_cover_id = pd_p_cover_id;
        
        END IF;
        --Защита и Освобождение рассчитанное по сумме взносов
        IF pd_p_brief IN ('PWOP_old', 'PWOP_life_old', 'WOP_old', 'WOP_life_old')
        THEN
        
          CASE r_calc_param.payment_terms_id
            WHEN 162 THEN
              km := 0.50;
            WHEN 165 THEN
              km := 0.25;
            WHEN 166 THEN
              km := 0.08333;
            ELSE
              km := 1;
          END CASE;
        
          SELECT SUM(pc.fee)
            INTO pc_fee_osn
            FROM ven_t_lob_line         ll
                ,ven_t_prod_line_rate   lr
                ,ven_t_product_line     pl
                ,ven_t_prod_line_option opt
                ,t_product_line_type    plt
                ,ven_p_cover            pc
                ,as_asset               a
           WHERE 1 = 1
             AND a.p_policy_id = par_policy_id
             AND opt.id = pc.t_prod_line_option_id
             AND pl.id = opt.product_line_id
             AND ll.t_lob_line_id = pl.t_lob_line_id
             AND lr.product_line_id(+) = pl.id
             AND pl.product_line_type_id = plt.product_line_type_id
             AND ll.brief NOT IN ('Adm_Cost_Life'
                                 ,'Adm_Cost_Acc'
                                 ,'I2'
                                 ,'INVEST2'
                                 ,'PWOP'
                                 ,'PWOP_life'
                                 ,'WOP'
                                 ,'WOP_life'
                                 ,'INVEST')
             AND a.as_asset_id = pc.as_asset_id;
          g_nd := (pc_fee_osn * kt) * ((pd_p_tariff * pd_p_k + pd_p_s) * km);
        
          UPDATE ven_p_cover p
             SET p.ins_amount          =
                 (pc_fee_osn * kt)
                ,p.fee                  = CEIL(g_nd)
                ,p.premium              = CEIL(g_nd) * kt
                ,p.is_handchange_tariff = 1
                ,p.tariff               = pd_p_tariff * pd_p_k + pd_p_s
           WHERE p.p_cover_id = pd_p_cover_id;
        
        END IF;
      
      END LOOP;
      CLOSE cur_cover;
      ----
    END IF;
  
  END;

  /*
    Байтин А.
    Уменьшение срока действия ДС
  */
  PROCEDURE decrease_period(par_policy_id NUMBER) IS
    v_pol_start_date         DATE;
    v_start_date             DATE;
    v_new_end_date           DATE;
    v_old_end_date           DATE;
    v_is_period_change       NUMBER(1);
    v_is_group_policy        NUMBER(1);
    v_ins_amount_after       NUMBER;
    v_fee_after              NUMBER;
    v_lock_fee               NUMBER(1) NOT NULL := 0;
    v_ins_amount_main_before NUMBER;
    v_ins_amount_main_after  NUMBER;
    v_pol_premium            NUMBER;
    v_pol_ins_amount         NUMBER;
    v_ins_period_before      NUMBER(2);
    v_ins_period_after       NUMBER(2);
    v_t                      NUMBER(2);
  
    -- Пересчет 'Дожитие с возвратом взносов в случае смерти'
    PROCEDURE calc_pepr
    (
      par_tariff            p_cover.tariff%TYPE
     ,par_ins_amount        p_cover.ins_amount%TYPE
     ,par_insured_age       p_cover.insured_age%TYPE
     ,par_gender            VARCHAR2
     ,par_k_coef            p_cover.k_coef%TYPE
     ,par_s_coef            p_cover.s_coef%TYPE
     ,par_normrate_value    p_cover.normrate_value%TYPE
     ,par_t                 NUMBER
     ,par_ins_period_before NUMBER
     ,par_ins_period_after  NUMBER
     ,par_ins_amount_after  OUT p_cover.ins_amount%TYPE
    ) IS
      c_f_before CONSTANT NUMBER(3, 1) := 0.2;
      c_f_after  CONSTANT NUMBER(3, 2) := 0.54;
      v_g            NUMBER;
      v_nex_before   NUMBER;
      v_nex_after    NUMBER;
      v_iax1n_before NUMBER;
      v_iax1n_after  NUMBER;
      v_a_xn_before  NUMBER;
      v_a_xn_after   NUMBER;
      v_ax1n_before  NUMBER;
      v_ax1n_after   NUMBER;
      v_ft_before    NUMBER;
      v_ft_after     NUMBER;
    BEGIN
      v_g := par_tariff * par_ins_amount;
    
      /* nEx до изменений */
      v_nex_before := ins.pkg_amath.nex(x          => par_insured_age + par_t
                                       ,n          => par_ins_period_before - par_t
                                       ,p_sex      => par_gender
                                       ,k_koeff    => par_k_coef
                                       ,s_koeff    => par_s_coef
                                       ,p_table_id => 1
                                       ,p_i        => par_normrate_value);
    
      /* nEx после изменений */
      v_nex_after := ins.pkg_amath.nex(x          => par_insured_age + par_t
                                      ,n          => par_ins_period_after - par_t /* Период страхования */
                                      ,p_sex      => par_gender
                                      ,k_koeff    => par_k_coef
                                      ,s_koeff    => par_s_coef
                                      ,p_table_id => 1
                                      ,p_i        => par_normrate_value -- норма доходности
                                       );
    
      /* (IA)1x:n до изменений */
      v_iax1n_before := ins.pkg_amath.iax1n(x          => par_insured_age + par_t
                                           ,n          => par_ins_period_before - par_t
                                           ,p_sex      => par_gender
                                           ,k_koeff    => par_k_coef
                                           ,s_koeff    => par_s_coef
                                           ,p_table_id => 1
                                           ,p_i        => par_normrate_value);
    
      /* A1x:n до изменений */
      v_ax1n_before := ins.pkg_amath.ax1n(x          => par_insured_age + par_t
                                         ,n          => par_ins_period_before - par_t
                                         ,p_sex      => par_gender
                                         ,k_koeff    => par_k_coef
                                         ,s_koeff    => par_s_coef
                                         ,p_table_id => 1
                                         ,p_i        => par_normrate_value);
    
      /* ax:n до изменений */
      v_a_xn_before := ins.pkg_amath.a_xn(x              => par_insured_age + par_t
                                         ,n              => par_ins_period_before - par_t
                                         ,p_sex          => par_gender
                                         ,k_koeff        => par_k_coef
                                         ,s_koeff        => par_s_coef
                                         ,isprenumerando => 1
                                         ,p_table_id     => 1
                                         ,p_i            => par_normrate_value);
    
      v_ft_before := v_iax1n_before - (1 - c_f_before) * v_a_xn_before + v_ax1n_before * /*v_year_number*/
                     par_t;
    
      /* (IA)1x:n после изменений */
      v_iax1n_after := ins.pkg_amath.iax1n(x          => par_insured_age + par_t
                                          ,n          => v_ins_period_after - par_t
                                          ,p_sex      => par_gender
                                          ,k_koeff    => par_k_coef
                                          ,s_koeff    => par_s_coef
                                          ,p_table_id => 1
                                          ,p_i        => par_normrate_value);
    
      /* A1x:n после изменений */
      v_ax1n_after := ins.pkg_amath.ax1n(x          => par_insured_age + par_t
                                        ,n          => v_ins_period_after - par_t
                                        ,p_sex      => par_gender
                                        ,k_koeff    => par_k_coef
                                        ,s_koeff    => par_s_coef
                                        ,p_table_id => 1
                                        ,p_i        => par_normrate_value);
    
      /* ax:n после изменений */
      v_a_xn_after := ins.pkg_amath.a_xn(x              => par_insured_age + par_t
                                        ,n              => v_ins_period_after - par_t
                                        ,p_sex          => par_gender
                                        ,k_koeff        => par_k_coef
                                        ,s_koeff        => par_s_coef
                                        ,isprenumerando => 1
                                        ,p_table_id     => 1
                                        ,p_i            => par_normrate_value);
    
      v_ft_after := v_iax1n_after + v_ax1n_after * par_t - v_a_xn_after * (1 - c_f_after);
    
      par_ins_amount_after := FLOOR(par_ins_amount * v_nex_before / v_nex_after +
                                    v_g * (v_ft_before - v_ft_after) / v_nex_after);
    END calc_pepr;
  
    -- Пересчет 'Смешанное страхование жизни'
    PROCEDURE calc_combined_life_ins
    (
      par_tariff_netto      p_cover.tariff_netto%TYPE
     ,par_ins_amount        p_cover.ins_amount%TYPE
     ,par_insured_age       p_cover.insured_age%TYPE
     ,par_par_gender        VARCHAR2
     ,par_k_coef            p_cover.k_coef%TYPE
     ,par_s_coef            p_cover.s_coef%TYPE
     ,par_normrate_value    p_cover.normrate_value%TYPE
     ,par_t                 NUMBER
     ,par_ins_period_before NUMBER
     ,par_ins_period_after  NUMBER
     ,par_ins_amount_after  OUT p_cover.ins_amount%TYPE
    ) IS
      v_p           NUMBER;
      v_a_xn_before NUMBER;
      v_a_xn_after  NUMBER;
      v_axn_before  NUMBER;
      v_axn_after   NUMBER;
    BEGIN
      v_p := par_tariff_netto * par_ins_amount;
    
      v_axn_before := ins.pkg_amath.axn(x          => par_insured_age + par_t
                                       ,n          => par_ins_period_before - par_t
                                       ,p_sex      => par_par_gender
                                       ,k_koeff    => par_k_coef
                                       ,s_koeff    => par_s_coef
                                       ,p_table_id => 1
                                       ,p_i        => par_normrate_value);
    
      v_axn_after := ins.pkg_amath.axn(x          => par_insured_age + par_t
                                      ,n          => par_ins_period_after - par_t
                                      ,p_sex      => par_par_gender
                                      ,k_koeff    => par_k_coef
                                      ,s_koeff    => par_s_coef
                                      ,p_table_id => 1
                                      ,p_i        => par_normrate_value);
    
      /* ax:n до изменений */
      v_a_xn_before := ins.pkg_amath.a_xn(x              => par_insured_age + par_t
                                         ,n              => par_ins_period_before - par_t
                                         ,p_sex          => par_par_gender
                                         ,k_koeff        => par_k_coef
                                         ,s_koeff        => par_s_coef
                                         ,isprenumerando => 1
                                         ,p_table_id     => 1
                                         ,p_i            => par_normrate_value);
    
      /* ax:n после изменений */
      v_a_xn_after := ins.pkg_amath.a_xn(x              => par_insured_age + par_t
                                        ,n              => par_ins_period_after - par_t
                                        ,p_sex          => par_par_gender
                                        ,k_koeff        => par_k_coef
                                        ,s_koeff        => par_s_coef
                                        ,isprenumerando => 1
                                        ,p_table_id     => 1
                                        ,p_i            => par_normrate_value);
    
      par_ins_amount_after := FLOOR(par_ins_amount * v_axn_before / v_axn_after +
                                    v_p * (v_a_xn_after - v_a_xn_before) / v_axn_after);
    END calc_combined_life_ins;
  
    -- Пересчет 'Первичное диагностирование смертельно опасного заболевания'
    PROCEDURE calc_dd
    (
      par_ins_amount             p_cover.ins_amount%TYPE
     ,par_ins_amount_main_before p_cover.ins_amount%TYPE
     ,par_ins_amount_main_after  p_cover.ins_amount%TYPE
     ,par_insured_age            p_cover.insured_age%TYPE
     ,par_ins_period_after       NUMBER
     ,par_gender                 VARCHAR2
     ,par_k_coef                 p_cover.k_coef%TYPE
     ,par_s_coef                 p_cover.s_coef%TYPE
     ,par_normrate_value         p_cover.normrate_value%TYPE
     ,par_loading                p_cover.rvb_value%TYPE
     ,par_ins_amount_after       OUT p_cover.ins_amount%TYPE
     ,par_fee_after              OUT p_cover.fee%TYPE
    ) IS
      v_p          NUMBER;
      v_g          NUMBER;
      v_a_xn_after NUMBER;
      v_ax1n_after NUMBER;
    BEGIN
      par_ins_amount_after := FLOOR(par_ins_amount / par_ins_amount_main_before *
                                    par_ins_amount_main_after);
    
      v_ax1n_after := ins.pkg_amath.ax1n(x          => par_insured_age -- + v_t
                                        ,n          => par_ins_period_after -- - v_t
                                        ,p_sex      => par_gender
                                        ,k_koeff    => par_k_coef
                                        ,s_koeff    => par_s_coef
                                        ,p_table_id => 41
                                        ,p_i        => par_normrate_value);
    
      /* ax:n после изменений */
      v_a_xn_after := ins.pkg_amath.a_xn(x              => par_insured_age -- + v_t
                                        ,n              => par_ins_period_after -- - v_t
                                        ,p_sex          => par_gender
                                        ,k_koeff        => par_k_coef
                                        ,s_koeff        => par_s_coef
                                        ,isprenumerando => 1
                                        ,p_table_id     => 41
                                        ,p_i            => par_normrate_value);
    
      v_p := v_ax1n_after / v_a_xn_after;
      v_g := (v_p / (1 - par_loading)) * par_ins_amount_after;
    
      par_fee_after := CEIL(v_g * 0.09);
    
    END calc_dd;
  
    -- Пересчет 'ИНВЕСТ2'
    PROCEDURE calc_invest2
    (
      par_ins_amount       p_cover.ins_amount%TYPE
     ,par_ins_amount_after OUT p_cover.ins_amount%TYPE
     ,par_fee_after        OUT p_cover.fee%TYPE
    ) IS
    BEGIN
      par_ins_amount_after := par_ins_amount;
      par_fee_after        := 0;
    END calc_invest2;
  BEGIN
    -- Проверяем тип изменений
    SELECT COUNT(1)
      INTO v_is_period_change
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_pol_addendum_type pt
                  ,t_addendum_type     ty
             WHERE pt.p_policy_id = par_policy_id
               AND pt.t_addendum_type_id = ty.t_addendum_type_id
               AND ty.brief = 'PERIOD_CHANGE');
  
    IF v_is_period_change = 1
    THEN
      SELECT COUNT(1)
        INTO v_is_group_policy
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy pp
               WHERE pp.policy_id = par_policy_id
                 AND pp.is_group_flag = 1);
    
      -- Проверка, что это не групповой договор
      IF v_is_group_policy = 0
      THEN
        SELECT ph.start_date
              ,pp.start_date
              ,pp.end_date
              ,(SELECT prev.end_date
                 FROM p_policy prev
                WHERE prev.pol_header_id = pp.pol_header_id
                  AND prev.policy_id = pp.prev_ver_id)
          INTO v_pol_start_date
              ,v_start_date
              ,v_new_end_date
              ,v_old_end_date
          FROM p_policy     pp
              ,p_pol_header ph
         WHERE pp.policy_id = par_policy_id
           AND ph.policy_header_id = pp.pol_header_id;
      
        -- Проверяем, было ли изменение даты окончания относительно предыдущей версии.
        IF v_old_end_date IS NOT NULL
           AND v_new_end_date != v_old_end_date
        THEN
          v_ins_period_before := CEIL(MONTHS_BETWEEN(v_old_end_date, v_pol_start_date) / 12);
          v_ins_period_after  := CEIL(MONTHS_BETWEEN(v_new_end_date, v_pol_start_date) / 12);
          v_t                 := trunc(MONTHS_BETWEEN(v_start_date, v_pol_start_date) / 12);
        
          -- пересчитываем страховые суммы и взносы
          FOR vr_rec IN (SELECT pc.insured_age
                               ,CASE cp.gender
                                  WHEN 0 THEN
                                   'w'
                                  ELSE
                                   'm'
                                END AS gender
                               ,pc.k_coef
                               ,pc.s_coef
                               ,pc.normrate_value
                               ,plo.brief AS prod_line_brief
                               ,pc.ins_amount
                               ,pc.tariff
                               ,pc.fee
                               ,pc.tariff_netto
                               ,pc.rvb_value AS loading
                               ,pc.rowid AS pc_rid
                           FROM as_asset            se
                               ,as_assured          su
                               ,cn_person           cp
                               ,p_cover             pc
                               ,t_prod_line_option  plo
                               ,t_product_line      pl
                               ,t_product_line_type plt
                          WHERE se.p_policy_id = par_policy_id
                            AND se.as_asset_id = pc.as_asset_id
                            AND se.as_asset_id = su.as_assured_id
                            AND su.assured_contact_id = cp.contact_id
                            AND pc.t_prod_line_option_id = plo.id
                            AND plo.product_line_id = pl.id
                            AND pl.product_line_type_id = plt.product_line_type_id
                               -- Админ. издержки не трогаем
                            AND plo.description NOT IN
                                ('Административные издержки'
                                ,'Административные издержки на восстановление')
                               -- И не трогаем
                               -- Защита страховых взносов рассчитанная по основной программе'
                               -- Освобождение от уплаты взносов рассчитанное по основной программе
                            AND plo.brief NOT IN ('PWOP', 'WOP')
                               -- Считаем если есть Дожитие или Смешанное страхование жизни,
                               -- т.к. от них считается все остальное, кроме Инвест2
                            AND EXISTS (SELECT NULL
                                   FROM p_cover            pc_
                                       ,t_prod_line_option plo_
                                  WHERE pc_.as_asset_id = se.as_asset_id
                                    AND pc_.t_prod_line_option_id = plo_.id
                                    AND plo_.brief IN ('PEPR' --'Дожитие с возвратом взносов в случае смерти'
                                                      ,'COMBINED_LIFE_INS' --'Смешанное страхование жизни'
                                                       ))
                         
                         -- Чтобы сначала получить значения основной программы,
                         -- а потом посчитать остальные
                          ORDER BY CASE plt.brief
                                     WHEN 'RECOMMENDED' THEN
                                      0
                                     ELSE
                                      1
                                   END)
          LOOP
            -- 'Дожитие с возвратом взносов в случае смерти'
            --'ИНВЕСТ2'
            IF vr_rec.prod_line_brief IN ('PEPR', 'INVEST2', 'INVEST')
            THEN
              calc_pepr(par_tariff            => vr_rec.tariff
                       ,par_ins_amount        => vr_rec.ins_amount
                       ,par_insured_age       => vr_rec.insured_age
                       ,par_gender            => vr_rec.gender
                       ,par_k_coef            => vr_rec.k_coef
                       ,par_s_coef            => vr_rec.s_coef
                       ,par_normrate_value    => vr_rec.normrate_value
                       ,par_t                 => v_t
                       ,par_ins_period_before => v_ins_period_before
                       ,par_ins_period_after  => v_ins_period_after
                       ,par_ins_amount_after  => v_ins_amount_after);
            
              v_ins_amount_main_before := vr_rec.ins_amount;
              v_ins_amount_main_after  := v_ins_amount_after;
              v_lock_fee               := 1;
              --'ИНВЕСТ2'
              /*ELSIF vr_rec.prod_line_brief = 'INVEST2'
              THEN
                calc_invest2(par_ins_amount       => vr_rec.ins_amount
                            ,par_ins_amount_after => v_ins_amount_after
                            ,par_fee_after        => v_fee_after);
                v_lock_fee               := 1;*/
              --'Смешанное страхование жизни'
            ELSIF vr_rec.prod_line_brief = 'COMBINED_LIFE_INS'
            THEN
              calc_combined_life_ins(par_tariff_netto      => vr_rec.tariff_netto
                                    ,par_ins_amount        => vr_rec.ins_amount
                                    ,par_insured_age       => vr_rec.insured_age
                                    ,par_par_gender        => vr_rec.gender
                                    ,par_k_coef            => vr_rec.k_coef
                                    ,par_s_coef            => vr_rec.s_coef
                                    ,par_normrate_value    => vr_rec.normrate_value
                                    ,par_t                 => v_t
                                    ,par_ins_period_before => v_ins_period_before
                                    ,par_ins_period_after  => v_ins_period_after
                                    ,par_ins_amount_after  => v_ins_amount_after);
            
              v_ins_amount_main_before := vr_rec.ins_amount;
              v_ins_amount_main_after  := v_ins_amount_after;
              v_lock_fee               := 1;
              --'Первичное диагностирование смертельно опасного заболевания'
            ELSIF vr_rec.prod_line_brief = 'DD'
            THEN
              calc_dd(par_ins_amount             => vr_rec.ins_amount
                     ,par_ins_amount_main_before => v_ins_amount_main_before
                     ,par_ins_amount_main_after  => v_ins_amount_main_after
                     ,par_insured_age            => vr_rec.insured_age
                     ,par_ins_period_after       => v_ins_period_after
                     ,par_gender                 => vr_rec.gender
                     ,par_k_coef                 => vr_rec.k_coef
                     ,par_s_coef                 => vr_rec.s_coef
                     ,par_normrate_value         => vr_rec.normrate_value
                     ,par_ins_amount_after       => v_ins_amount_after
                     ,par_loading                => vr_rec.loading
                     ,par_fee_after              => v_fee_after);
            
              v_lock_fee := 1;
              -- Все прочие
            ELSE
              v_ins_amount_after := vr_rec.ins_amount *
                                    (v_ins_amount_main_after / v_ins_amount_main_before);
            
              v_lock_fee := 0;
            END IF;
          
            UPDATE p_cover pc
               SET pc.fee = CASE
                              WHEN pc.fee != v_fee_after THEN
                               v_fee_after
                              ELSE
                               pc.fee
                            END
                  ,pc.ins_amount = v_ins_amount_after
                   -- Чтобы не пересчитывались при переходах статусов и сохранялись в следующих версиях
                  ,pc.is_handchange_amount = 1
                  ,pc.is_handchange_fee    = v_lock_fee
                  ,pc.is_handchange_tariff = 1
             WHERE pc.rowid = vr_rec.pc_rid;
          END LOOP;
        
          -- Меняем у всех покрытий, выходящих за пределы даты окончания версии, дату окончания
          UPDATE p_cover pc
             SET pc.end_date  = v_new_end_date
                ,pc.period_id =
                 (SELECT nvl(MIN(tp.id), 9) -- По умолчанию, Другой
                    FROM t_prod_line_period pl
                        ,t_period_use_type  ut
                        ,t_period           tp
                        ,t_period_type      pt
                        ,t_prod_line_option plo
                   WHERE plo.id = pc.t_prod_line_option_id
                     AND plo.product_line_id = pl.product_line_id
                     AND pl.t_period_use_type_id = ut.t_period_use_type_id
                     AND pl.period_id = tp.id
                     AND tp.period_type_id = pt.id
                     AND ut.brief IN ('Срок страхования'
                                     ,'Срок страхования по объекту страхования')
                     AND CASE pt.description
                           WHEN 'Дни' THEN
                            v_new_end_date - tp.period_value
                           WHEN 'Месяцы' THEN
                            ADD_MONTHS(v_new_end_date, -tp.period_value)
                           WHEN 'Годы' THEN
                            ADD_MONTHS(v_new_end_date, -tp.period_value * 12)
                           WHEN 'Кварталы' THEN
                            ADD_MONTHS(v_new_end_date, -tp.period_value * 4)
                         END = pc.start_date - INTERVAL '1' SECOND)
           WHERE pc.rowid IN (SELECT pc_.rowid
                                FROM as_asset           se
                                    ,p_cover            pc_
                                    ,t_prod_line_option plo
                                    ,t_product_line     pl
                                    ,t_product_ver_lob  vl
                                    ,t_lob              tl
                               WHERE se.p_policy_id = par_policy_id
                                 AND se.as_asset_id = pc_.as_asset_id
                                 AND pc_.t_prod_line_option_id = plo.id
                                 AND plo.product_line_id = pl.id
                                 AND pl.product_ver_lob_id = vl.t_product_ver_lob_id
                                 AND vl.lob_id = tl.t_lob_id
                                 AND tl.brief = 'Life.Life'
                                 AND pc_.end_date > v_new_end_date);
        
          -- Устанавливаем у всех застрахованных дату окончания = максимальной дате окончания относящихся к нему покрытий
          UPDATE as_asset se
             SET se.end_date =
                 (SELECT MAX(pc.end_date) FROM p_cover pc WHERE pc.as_asset_id = se.as_asset_id)
           WHERE se.p_policy_id = par_policy_id;
        
          -- Устанавливаем новый срок уплаты взносов и период у договора
          UPDATE p_policy pp
             SET pp.fee_payment_term = v_ins_period_after
                ,pp.period_id       =
                 (SELECT nvl(MIN(tp.id), 9) -- По умолчанию, Другой
                    FROM p_pol_header      ph
                        ,t_product_period  prp
                        ,t_period_use_type ut
                        ,t_period          tp
                        ,t_period_type     pt
                   WHERE ph.policy_header_id = pp.pol_header_id
                     AND ph.product_id = prp.product_id
                     AND prp.t_period_use_type_id = ut.t_period_use_type_id
                     AND ut.brief IN ('Срок страхования'
                                     ,'Срок страхования по объекту страхования')
                     AND prp.period_id = tp.id
                     AND tp.period_type_id = pt.id
                     AND CASE pt.description
                           WHEN 'Дни' THEN
                            v_new_end_date - tp.period_value
                           WHEN 'Месяцы' THEN
                            ADD_MONTHS(v_new_end_date, -tp.period_value)
                           WHEN 'Годы' THEN
                            ADD_MONTHS(v_new_end_date, -tp.period_value * 12)
                           WHEN 'Кварталы' THEN
                            ADD_MONTHS(v_new_end_date, -tp.period_value * 4)
                         END = ph.start_date - INTERVAL '1' SECOND)
           WHERE pp.policy_id = par_policy_id;
        
          pkg_policy.update_policy_sum(p_p_policy_id => par_policy_id
                                      ,p_premium     => v_pol_premium
                                      ,p_ins_amount  => v_pol_ins_amount);
          -- Считаем выкупные
          pkg_pol_cash_surr_method.set_metod_f_t(p_p_policy_id => par_policy_id, p_metod_id => 2);
          pkg_pol_cash_surr_method.recalccashsurrmethod(p_policy_id => par_policy_id);
        END IF;
      END IF;
    END IF;
  END decrease_period;

BEGIN

  sys.dbms_output.disable;

  DECLARE
    v_is_debug NUMBER;
  BEGIN
    SELECT t.value INTO v_is_debug FROM t_debug_config t WHERE t.brief = 'RECALC_POLICY_LOG';
    gv_debug := v_is_debug = 1;
  EXCEPTION
    WHEN no_data_found THEN
      gv_debug := FALSE;
  END;
END pkg_recalcpolicy;
/
