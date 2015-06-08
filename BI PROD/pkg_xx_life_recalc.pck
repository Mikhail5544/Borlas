CREATE OR REPLACE PACKAGE pkg_xx_life_recalc IS
  --
  PROCEDURE recalc
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  );
  FUNCTION getrecommendfee(p_as_asset_id IN NUMBER) RETURN NUMBER;
  FUNCTION recalc_property(p_as_asset_id IN NUMBER) RETURN NUMBER;
  --
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_xx_life_recalc IS
  --
  g_debug BOOLEAN := FALSE;
  --
  g_step_no NUMBER;

  TYPE calc_param IS RECORD(
     p_cover_id           NUMBER
    ,age                  NUMBER
    ,gender_type          VARCHAR2(1)
    ,assured_contact_id   NUMBER
    ,period_year          NUMBER
    ,s_coef               NUMBER
    ,k_coef               NUMBER
    ,s_coef_m             NUMBER
    ,k_coef_m             NUMBER
    ,s_coef_nm            NUMBER
    ,k_coef_nm            NUMBER
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
    ,is_in_waiting_period NUMBER
    ,number_of_payment    NUMBER);

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
    ,tariff_prev                NUMBER
    ,tariff_curr                NUMBER
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
    ,is_underwriting            NUMBER(1));
  --

  TYPE t_product_line_info IS RECORD(
     p_cover_id            NUMBER
    ,as_asset_id           NUMBER
    ,t_prod_line_option_id NUMBER
    ,start_date            DATE
    ,end_date              DATE
    ,ins_amount            NUMBER(30, 2)
    ,premium               NUMBER(30, 2)
    ,tariff                NUMBER
    ,t_deductible_type_id  NUMBER
    ,t_deduct_val_type_id  NUMBER
    ,deductible_value      NUMBER
    ,status_hist_id        NUMBER
    ,ent_id                NUMBER(6)
    ,filial_id             NUMBER(6)
    ,old_premium           NUMBER(30, 2)
    ,compensation_type     NUMBER
    ,fee                   NUMBER
    ,number_of_payments    NUMBER
    ,is_handchange_amount  NUMBER
    ,is_handchange_premium NUMBER
    ,is_handchange_tariff  NUMBER
    ,is_handchange_deduct  NUMBER(1)
    ,decline_date          DATE
    ,decline_summ          NUMBER
    ,is_decline_charge     NUMBER(1)
    ,is_decline_comission  NUMBER(1)
    ,is_handchange_decline NUMBER(1)
    ,is_aggregate          NUMBER(1)
    ,ins_price             NUMBER
    ,ext_id                VARCHAR2(50 BYTE)
    ,is_proportional       NUMBER(1)
    ,rvb_value             NUMBER(6, 5)
    ,k_coef                NUMBER(6, 5)
    ,s_coef                NUMBER(6, 5)
    ,normrate_value        NUMBER(6, 5)
    ,comments              VARCHAR2(500 BYTE)
    ,insured_age           NUMBER(3)
    ,premium_all_srok      NUMBER(30, 2)
    ,premia_base_type      NUMBER(1)
    ,added_summ            NUMBER
    ,payed_summ            NUMBER
    ,debt_summ             NUMBER
    ,return_summ           NUMBER
    ,accum_period_end_age  NUMBER
    ,is_avtoprolongation   NUMBER
    ,netto_tariff          NUMBER
    ,k_coef_m              NUMBER
    ,k_coef_nm             NUMBER
    ,s_coef_m              NUMBER
    ,s_coef_nm             NUMBER
    ,decline_party_id      NUMBER
    ,decline_reason_id     NUMBER
    ,period_id             NUMBER(9)
    ,tariff_netto          NUMBER
    ,is_handchange_fee     NUMBER(1)
    ,deathreate_id         NUMBER(15)
    ,pl_brief              VARCHAR2(100 BYTE)
    ,lob_brief             VARCHAR2(30 BYTE)
    ,sh_brief              VARCHAR2(30 BYTE)
    ,plt_brief             VARCHAR2(30 BYTE)
    ,imaging               VARCHAR2(10 BYTE)
    ,product_line_id       NUMBER(9)
    ,pl_premium_func_id    NUMBER(9));

  TYPE tbl_product_line_info IS TABLE OF t_product_line_info;

  FUNCTION get_cover_info(p_as_asset_id IN NUMBER) RETURN tbl_product_line_info IS
  
    RESULT tbl_product_line_info;
  
  BEGIN
  
    SELECT pc.p_cover_id
          ,pc.as_asset_id
          ,pc.t_prod_line_option_id
          ,pc.start_date
          ,pc.end_date
          ,pc.ins_amount
          ,pc.premium
          ,pc.tariff
          ,pc.t_deductible_type_id
          ,pc.t_deduct_val_type_id
          ,pc.deductible_value
          ,pc.status_hist_id
          ,pc.ent_id
          ,pc.filial_id
          ,old_premium
          ,compensation_type
          ,pc.fee
          ,pt.number_of_payments
          ,pc.is_handchange_amount
          ,pc.is_handchange_premium
          ,pc.is_handchange_tariff
          ,pc.is_handchange_deduct
          ,pc.decline_date
          ,pc.decline_summ
          ,pc.is_decline_charge
          ,pc.is_decline_comission
          ,pc.is_handchange_decline
          ,pl.is_aggregate
          ,pc.ins_price
          ,pc.ext_id
          ,is_proportional
          ,pc.rvb_value
          ,pc.k_coef
          ,pc.s_coef
          ,pc.normrate_value
          ,comments
          ,pc.insured_age
          ,premium_all_srok
          ,premia_base_type
          ,pc.added_summ
          ,pc.payed_summ
          ,pc.debt_summ
          ,pc.return_summ
          ,accum_period_end_age
          ,pc.is_avtoprolongation
          ,netto_tariff
          ,pc.k_coef_m
          ,pc.k_coef_nm
          ,pc.s_coef_m
          ,pc.s_coef_nm
          ,pc.decline_party_id
          ,pc.decline_reason_id
          ,pc.period_id
          ,tariff_netto
          ,is_handchange_fee
          ,deathreate_id
          ,pl.brief                 pl_brief
          ,ll.brief                 lob_brief
          ,sh.brief                 sh_brief
          ,plt.brief                plt_brief
          ,imaging
          ,product_line_id
          ,pl.premium_func_id       pl_premium_func_id
      BULK COLLECT
      INTO RESULT
      FROM t_lob_line          ll
          ,t_product_line_type plt
          ,t_product_line      pl
          ,t_payment_terms     pt
          ,p_policy            pp
          ,as_asset            aa
          ,p_cover             pc
          ,t_prod_line_option  plo
          ,ven_status_hist     sh
     WHERE 1 = 1
       AND pc.as_asset_id = p_as_asset_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND pt.id = pp.payment_term_id
       AND plo.id = pc.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND ll.t_lob_line_id = pl.t_lob_line_id
       AND plt.product_line_type_id = pl.product_line_type_id
       AND sh.status_hist_id = pc.status_hist_id
     ORDER BY pc.fee;
  
    RETURN RESULT;
  END;

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
        (p_p_cover_id, SYSDATE, 'INS.PKG_XX_LIFE_RECALC', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --
  FUNCTION get_calc_param(p_cover_id IN NUMBER) RETURN calc_param IS
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
    v_d_notice DATE;
    --
    v_header_start_date DATE;
    v_policy_start_date DATE;
    v_number_of_payment NUMBER;
    v_payment_terms_id  NUMBER;
    --
    v_deathrate_id       NUMBER;
    v_discount_f_id      NUMBER;
    v_gender_type        VARCHAR2(1);
    v_assured_contact_id NUMBER;
    --
    v_s_coef           NUMBER;
    v_k_coef           NUMBER;
    v_f                NUMBER;
    v_premia_base_type NUMBER;
    --
    v_ins_amount           NUMBER;
    v_tariff               NUMBER;
    v_tariff_netto         NUMBER;
    v_fee                  NUMBER;
    v_is_in_waiting_period NUMBER;
    --
    RESULT calc_param;
  BEGIN
    result.p_cover_id := p_cover_id;
    v_cover_id        := p_cover_id;
    --
    dbms_output.put_line('ID покрытия ' || v_cover_id);
    SELECT vas.as_assured_id
          ,decode(nvl(vcp.gender, vas.gender), 0, 'w', 1, 'm') gender_type
          ,assured_contact_id
      INTO v_as_assured_id
          ,v_gender_type
          ,v_assured_contact_id
      FROM ven_cn_person  vcp
          ,ven_contact    vc
          ,ven_as_assured vas
          ,ven_p_cover    vpc
     WHERE 1 = 1
       AND vpc.p_cover_id = v_cover_id
       AND vas.as_assured_id = vpc.as_asset_id
       AND vc.contact_id(+) = vas.assured_contact_id
       AND vcp.contact_id(+) = vc.contact_id;
    --
    dbms_output.put_line('ID застрахованного ' || v_as_assured_id);
    IF v_gender_type IS NULL
    THEN
      result.is_error := 1;
    END IF;
  
    --
    SELECT pp.policy_id
          ,nvl(s_coef, 0) s_coef
          ,nvl(k_coef, 0) k_koef
          ,s_coef_m
          ,k_coef_m
          ,s_coef_nm
          ,k_coef_nm
          ,rvb_value
          ,normrate_value
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
      INTO v_policy_id
          ,v_s_coef
          ,v_k_coef
          ,result.s_coef_m
          ,result.k_coef_m
          ,result.s_coef_nm
          ,result.k_coef_nm
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
      FROM t_payment_terms pt
          ,t_period        p
          ,p_pol_header    ph
          ,p_policy        pp
          ,ven_as_assured  aa
          ,p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = v_cover_id
       AND aa.as_assured_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND p.id = pp.period_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pt.id = pp.payment_term_id
    
    ;
    --
    dbms_output.put_line('ID версии договора (полиса) ' || v_policy_id);
    dbms_output.put_line('Возраст застрахованного ' || v_age);
    IF v_age IS NULL
    THEN
      dbms_output.put_line('Возраст застрахованного не расчитан...Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    IF v_f IS NULL
    THEN
      dbms_output.put_line('Нагрузка не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    /*
        if v_normrate is null then
          dbms_output.put_line ('Норма доходности не найдена....Устанавливаем флаг ошибки ');
          result.is_error := 1;
          return  result;
        end if;
    */
    --
    dbms_output.put_line('ID discount_f= ' || v_discount_f_id);
    --
    IF v_discount_f_id IS NULL
    THEN
      dbms_output.put_line('Базовая нагрузка по договору не найдена....Устанавливаем флаг ошибки ');
      result.is_error := 1;
    END IF;
    --
    dbms_output.put_line('Срок действия договора ' || to_char(v_period_year));
    --
    SELECT ll.t_lob_line_id
          ,lr.deathrate_id
      INTO v_lob_line_id
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
    dbms_output.put_line('ID страховой программы ' || v_lob_line_id);
    dbms_output.put_line('Количество платежей в год ' || v_number_of_payment);
    dbms_output.put_line('Код валюты ответственности ' || v_fund_id);
    --
    dbms_output.put_line('Установленная норма доходности для "страховой программы" ' || v_normrate);
    dbms_output.put_line('v_f = ' || v_f);
    dbms_output.put_line('deathrate_id = ' || v_deathrate_id);
    --
    result.age                := v_age;
    result.gender_type        := v_gender_type;
    result.assured_contact_id := v_assured_contact_id;
    result.period_year        := v_period_year;
    result.s_coef             := v_s_coef;
    result.k_coef             := v_k_coef;
    result.f                  := v_f;
    result.t                  := trunc(MONTHS_BETWEEN(v_policy_start_date, v_header_start_date) / 12);
    dbms_output.put_line('v_policy_start_date = ' || v_policy_start_date);
    dbms_output.put_line('v_header_start_date = ' || v_header_start_date);
    dbms_output.put_line('result.t = ' || result.t);
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
    --
    /*
        IF v_deathrate_id is NULL THEN
          dbms_output.put_line ('Таблица смертности не указана....Устанавливаем флаг ошибки ');
          result.is_error := 1;
        END IF;
    */
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
            ,is_ins_amount_change
            ,tariff_prev
            ,tariff_curr
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
    result.tariff_prev                := r_prev_version.tariff_prev;
    result.tariff_curr                := r_prev_version.tariff_curr;
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
    --
    RETURN RESULT;
    --
  END;

  FUNCTION getrefusedsumfee(p_as_asset_id IN NUMBER) RETURN NUMBER IS
    RESULT    NUMBER;
    tbl_cover tbl_product_line_info;
  BEGIN
  
    tbl_cover := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF (tbl_cover(i).sh_brief = 'DELETED')
      THEN
        RESULT := nvl(RESULT, 0) + tbl_cover(i).fee;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  END;

  FUNCTION getsumfee(p_as_asset_id IN NUMBER) RETURN NUMBER IS
    RESULT    NUMBER := 0;
    tbl_cover tbl_product_line_info;
  BEGIN
  
    tbl_cover := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
      THEN
        RESULT := nvl(RESULT, 0) + tbl_cover(i).fee;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  END;

  FUNCTION getsumaddfee
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
  ) RETURN NUMBER IS
    RESULT    NUMBER := 0;
    tbl_cover tbl_product_line_info;
  BEGIN
  
    tbl_cover := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
      THEN
        IF NOT (tbl_cover(i).p_cover_id = p_p_cover_id)
        THEN
          IF NOT (tbl_cover(i).lob_brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP'))
          THEN
            RESULT := nvl(RESULT, 0) + tbl_cover(i).fee;
          END IF;
        END IF;
      END IF;
    END LOOP;
  
    RETURN RESULT;
  
  END;

  FUNCTION getsumprevaddfee
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
  ) RETURN NUMBER IS
    RESULT     NUMBER DEFAULT 0;
    r_add_info add_info;
  BEGIN
    pkg_xx_as_asset.set_as_asset_id(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    FOR cur IN (SELECT fee
                      ,p_cover_id
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND p_cover_id != p_p_cover_id
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM t_lob_line     ll
                              ,t_product_line pl
                         WHERE pl.id = ac.id
                           AND ll.t_lob_line_id = pl.t_lob_line_id
                           AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')))
    LOOP
      r_add_info := get_add_info(cur.p_cover_id);
      RESULT     := RESULT + r_add_info.fee_prev;
      RETURN RESULT;
    END LOOP;
  END;

  PROCEDURE finalresult
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    resultset tbl_product_line_info;
  
    r_cover_param calc_param;
  
    l_temp_fee    NUMBER;
    l_temp_amount NUMBER;
    l_premium     NUMBER;
  
    l_all_fee     NUMBER;
    l_all_add_fee NUMBER;
  
    l_coef NUMBER;
  
  BEGIN
  
    resultset := get_cover_info(p_as_asset_id);
  
    log(p_p_cover_id, 'FINALRESULT Удаление "плавающих рублей"');
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    l_temp_fee := l_all_fee - p_fee_amount;
  
    log(p_p_cover_id
       ,'FINALRESULT "Плавающие рубли"' || l_temp_fee || ' Рекомендованный брутто взнос ' ||
        p_fee_amount || ' Текущий брутто взнос ' || l_all_fee);
  
    IF l_temp_fee > 0
    THEN
    
      /* Поиск решения по дополнительным программам */
      FOR i IN 1 .. resultset.count
      LOOP
        EXIT WHEN l_temp_fee = 0;
      
        IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
            AND NOT (resultset(i).p_cover_id = p_p_cover_id)
            AND NOT resultset(i).sh_brief = 'DELETED'
        THEN
        
          r_cover_param := get_calc_param(resultset(i).p_cover_id);
        
          resultset(i).fee := resultset(i).fee - least(1, abs(l_temp_fee));
          l_coef := nvl(pkg_tariff.calc_tarif_mul(resultset(i).p_cover_id), 0);
        
          IF l_coef != 0
          THEN
            resultset(i).ins_amount := resultset(i).fee / (l_coef * r_cover_param.tariff);
            log(resultset(i).p_cover_id, 'FINALRESULT INS_AMOUNT' || resultset(i).ins_amount);
            resultset(i).ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id
                                                                 ,resultset(i).ins_amount);
            log(resultset(i).p_cover_id, 'FINALRESULT INS_AMOUNT' || resultset(i).ins_amount);
          END IF;
        
          l_premium := resultset(i).fee * r_cover_param.number_of_payment;
        
          UPDATE p_cover
             SET fee        = resultset(i).fee
                ,ins_amount = resultset(i).ins_amount
                ,premium    = l_premium
           WHERE p_cover_id = resultset(i).p_cover_id;
        
          log(resultset(i).p_cover_id
             ,'FINALRESULT FEE ' || resultset(i).fee || ' PREMIUM ' || l_premium);
        
          l_temp_fee := l_temp_fee - least(1, abs(l_temp_fee));
        
        END IF;
      
      END LOOP;
    
      /* Поиск решения по основной программе */
      FOR i IN 1 .. resultset.count
      LOOP
        log(resultset(i).p_cover_id, 'FINALRESULT LL_BRIEF ' || resultset(i).lob_brief);
      
        EXIT WHEN l_temp_fee = 0;
      
        IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
            AND (resultset(i).p_cover_id = p_p_cover_id)
            AND NOT resultset(i).sh_brief = 'DELETED'
        THEN
        
          r_cover_param := get_calc_param(resultset(i).p_cover_id);
        
          resultset(i).fee := resultset(i).fee - least(1, abs(l_temp_fee));
          l_coef := nvl(pkg_tariff.calc_tarif_mul(resultset(i).p_cover_id), 0);
        
          IF l_coef != 0
          THEN
            resultset(i).ins_amount := resultset(i).fee / (l_coef * r_cover_param.tariff);
            log(resultset(i).p_cover_id, 'FINALRESULT INS_AMOUNT' || resultset(i).ins_amount);
            resultset(i).ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id
                                                                 ,resultset(i).ins_amount);
            log(resultset(i).p_cover_id, 'FINALRESULT INS_AMOUNT' || resultset(i).ins_amount);
          END IF;
        
          l_premium := resultset(i).fee * r_cover_param.number_of_payment;
        
          UPDATE p_cover
             SET fee        = resultset(i).fee
                ,ins_amount = resultset(i).ins_amount
                ,premium    = l_premium
           WHERE p_cover_id = resultset(i).p_cover_id;
        
          log(resultset(i).p_cover_id
             ,'FINALRESULT FEE ' || resultset(i).fee || ' PREMIUM ' || l_premium);
        
          l_temp_fee := l_temp_fee - least(1, abs(l_temp_fee));
        
        END IF;
      
      END LOOP;
    
    ELSIF l_temp_fee < 0
    THEN
    
      LOOP
        EXIT WHEN l_temp_fee = 0;
        FOR i IN 1 .. resultset.count
        LOOP
          EXIT WHEN l_temp_fee = 0;
        
          IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
              AND (resultset(i).p_cover_id = p_p_cover_id)
              AND NOT resultset(i).sh_brief = 'DELETED'
          THEN
          
            r_cover_param := get_calc_param(p_p_cover_id);
          
            resultset(i).fee := resultset(i).fee + least(1, abs(l_temp_fee));
            l_coef := nvl(pkg_tariff.calc_tarif_mul(resultset(i).p_cover_id), 0);
          
            IF l_coef != 0
            THEN
              resultset(i).ins_amount := resultset(i).fee / (l_coef * r_cover_param.tariff);
              resultset(i).ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id
                                                                   ,resultset(i).ins_amount);
            END IF;
          
            l_premium := resultset(i).fee * r_cover_param.number_of_payment;
          
            UPDATE p_cover
               SET fee        = resultset(i).fee
                  ,ins_amount = resultset(i).ins_amount
                  ,premium    = l_premium
             WHERE p_cover_id = resultset(i).p_cover_id;
          
            log(p_p_cover_id, 'FINALRESULT FEE ' || resultset(i).fee || ' PREMIUM ' || l_premium);
          
            l_temp_fee := l_temp_fee + least(1, abs(l_temp_fee));
          
          END IF;
          --          l_temp_fee := l_temp_fee + least(1, abs(l_temp_fee));
        END LOOP;
      
      END LOOP;
    
      /*    ELSIF l_temp_fee < 0
      THEN
        LOOP
          EXIT WHEN l_temp_fee = 0;
          FOR i IN 1 .. resultset.count
          LOOP
            EXIT WHEN l_temp_fee = 0;
          
            IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
                AND (resultset(i).p_cover_id = p_p_cover_id)
                AND NOT resultset(i).sh_brief = 'DELETED'
            THEN
            
              r_cover_param := get_calc_param(p_p_cover_id);
            
              resultset(i).fee := resultset(i).fee + least(1,abs(l_temp_fee));
              l_coef := nvl(pkg_tariff.calc_tarif_mul(resultset(i).p_cover_id), 0);
            
              IF l_coef != 0
              THEN
                resultset(i).ins_amount := resultset(i).fee / (l_coef * r_cover_param.tariff);
                resultset(i).ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id
                                                                     ,resultset(i).ins_amount);
              END IF;
            
              l_premium := resultset(i).fee * r_cover_param.number_of_payment;
            
              UPDATE p_cover
                 SET fee        = resultset(i).fee
                    ,ins_amount = resultset(i).ins_amount
                    ,premium    = l_premium
               WHERE p_cover_id = resultset(i).p_cover_id;
            
              log(p_p_cover_id, 'FINALRESULT FEE ' || resultset(i).fee || ' PREMIUM ' || l_premium);
            
              l_temp_fee := l_temp_fee + least(1,abs(l_temp_fee));
            
            END IF;
            l_temp_fee := l_temp_fee + least(1,abs(l_temp_fee));
          END LOOP;
        
        END LOOP;*/
    
    END IF;
  
  END;

  PROCEDURE inforesult
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
  ) IS
    resultset tbl_product_line_info;
  
    r_cover_param calc_param;
  
    l_temp_fee    NUMBER;
    l_temp_amount NUMBER;
    l_premium     NUMBER;
  
    l_coef NUMBER;
  
  BEGIN
    resultset := get_cover_info(p_as_asset_id);
    log(p_p_cover_id, 'INFORESULT ');
  
    FOR i IN 1 .. resultset.count
    LOOP
      IF NOT resultset(i).sh_brief = 'DELETED'
      THEN
      
        r_cover_param := get_calc_param(p_p_cover_id);
      
        log(resultset(i).p_cover_id, 'INFORESULT INS_AMOUNT ' || resultset(i).ins_amount);
        log(resultset(i).p_cover_id, 'INFORESULT INS_AMOUNT ' || resultset(i).fee);
        log(resultset(i).p_cover_id, 'INFORESULT INS_AMOUNT ' || resultset(i).premium);
      
      END IF;
    
    END LOOP;
  END;

  PROCEDURE insreaseaddinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_log         OUT VARCHAR2
  ) IS
    l_primary_ins_amount NUMBER;
    l_ins_amount         NUMBER;
  
    l_primary_fee          NUMBER;
    l_primary_premium      NUMBER;
    l_primary_tariff       NUMBER;
    l_primary_tariff_netto NUMBER;
  
    l_add_ins_amount NUMBER;
    l_add_fee        NUMBER;
    l_all_add_fee    NUMBER;
    l_add_premium    NUMBER;
  
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_temp_fee         NUMBER;
    --
    l_first_value NUMBER;
    l_coef        NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
  BEGIN
    pkg_xx_as_asset.set_as_asset_id(p_as_asset_id);
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    r_cover_param := get_calc_param(p_p_cover_id);
    l_primary_fee := r_add_info.fee_prev;
    l_ins_amount  := r_cover_param.ins_amount;
  
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND p_cover_id != p_p_cover_id
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM t_lob_line     ll
                              ,t_product_line pl
                         WHERE pl.id = ac.id
                           AND ll.t_lob_line_id = pl.t_lob_line_id
                           AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')))
    LOOP
      r_cover_param := get_calc_param(cur.p_cover_id);
      --
      l_temp_fee := cur.fee;
      IF l_all_add_fee <> 0
      THEN
        l_add_fee := l_temp_fee + (l_temp_fee / l_all_add_fee) * (p_fee_amount - l_all_fee);
      ELSE
        l_add_fee := 0;
      END IF;
      --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
      dbms_output.put_line('InsreaseAddInsSum Брутто взнос по договору ' || l_all_fee);
    
      log(p_p_cover_id
         ,'INSREASEADDINSSUM Брутто взнос по договору ' || l_all_fee);
      log(p_p_cover_id
         ,'INSREASEADDINSSUM Брутто взнос по договору (необходимый)' || p_fee_amount);
      log(p_p_cover_id
         ,'INSREASEADDINSSUM Сумма распределения ' || (p_fee_amount - l_all_fee));
      log(p_p_cover_id
         ,'INSREASEADDINSSUM По программе нужно чтобы брутто взнос был  ' || l_add_fee);
    
      l_coef := nvl(pkg_tariff.calc_tarif_mul(cur.p_cover_id), 0);
    
      log(p_p_cover_id
         ,'INSREASEADDINSSUM По дополнительной программе брутто взнос был равен ' || l_temp_fee);
      log(p_p_cover_id
         ,'INSREASEADDINSSUM По дополнительной программе брутто взнос равен ' || l_add_fee);
    
      log(p_p_cover_id
         ,'INSREASEADDINSSUM Итоговый коэффициент по покрытию ' || l_coef);
    
      IF l_coef != 0
      THEN
        l_add_ins_amount := l_add_fee / (l_coef * r_cover_param.tariff);
        --l_add_ins_amount := pkg_cover.round_ins_amount (cur.p_cover_id, l_add_ins_amount);
        IF l_add_ins_amount > l_ins_amount
        THEN
          l_add_ins_amount := l_ins_amount;
        END IF;
      
        log(p_p_cover_id
           ,'INSREASEADDINSSUM Расчетная страховая сумма ' || l_add_ins_amount);
      
      END IF;
    
      UPDATE ven_p_cover
         SET fee        = l_add_fee
            ,ins_amount = l_add_ins_amount
       WHERE p_cover_id = cur.p_cover_id;
    
      l_add_tariff := pkg_cover.calc_tariff(cur.p_cover_id);
      log(p_p_cover_id
         ,'INSREASEADDINSSUM Проверка необходимости пересчета тарифов по покрытию ');
    
      IF ROUND(l_add_tariff, 6) = ROUND(r_cover_param.tariff, 6)
      THEN
      
        log(p_p_cover_id, 'INSREASEADDINSSUM Пересчет не требуется ');
      
        l_add_fee := pkg_cover.calc_fee(cur.p_cover_id);
        --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = cur.p_cover_id;
      ELSE
        log(p_p_cover_id, 'INSREASEADDINSSUM Требуется пересчет');
      
        UPDATE ven_p_cover SET tariff = l_add_tariff WHERE p_cover_id = cur.p_cover_id;
        l_add_fee := pkg_cover.calc_fee(cur.p_cover_id);
        --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = cur.p_cover_id;
      END IF;
    
    END LOOP;
    --
  END;

  PROCEDURE restoreprevversion
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
  
    l_ins_amount NUMBER;
  
    l_fee          NUMBER;
    l_premium      NUMBER;
    l_tariff       NUMBER;
    l_tariff_netto NUMBER;
  
    --
    r_add_info add_info;
    --
    tbl_cover tbl_product_line_info;
    --
    r_cover_param      calc_param;
    r_cover_param_prev calc_param;
  
  BEGIN
  
    log(p_p_cover_id, 'RESTOREPREVVERSION ');
  
    tbl_cover := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
      THEN
      
        r_add_info := get_add_info(tbl_cover(i).p_cover_id);
      
        UPDATE p_cover
           SET ins_amount = r_add_info.ins_amount_prev
         WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        log(tbl_cover(i).p_cover_id
           ,'RESTOREPREVVERSION Восстановлена стр. сумма ' || tbl_cover(i).lob_brief || ' в размере ' ||
            r_add_info.ins_amount_prev);
      
        l_tariff_netto := pkg_cover.calc_tariff_netto(tbl_cover(i).p_cover_id);
      
        UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        l_tariff := pkg_cover.calc_tariff(tbl_cover(i).p_cover_id);
      
        UPDATE p_cover SET tariff = l_tariff WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        l_fee := nvl(pkg_cover.calc_fee(tbl_cover(i).p_cover_id), r_add_info.fee_prev);
      
        UPDATE p_cover SET fee = l_fee WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        IF tbl_cover(i).pl_premium_func_id IS NULL
        THEN
          l_premium := l_fee * tbl_cover(i).number_of_payments;
        ELSE
          l_premium := nvl(pkg_cover.calc_premium(tbl_cover(i).p_cover_id), r_add_info.fee_prev);
        END IF;
      
        UPDATE p_cover SET premium = l_premium WHERE p_cover_id = tbl_cover(i).p_cover_id;
      END IF;
    
    END LOOP;
  
  END;

  /*
    Пропорциональный пересчет всех дополнительных программ
    Для расчета берется сумма брутто взноса, из которой вычитается сумма основной и сервис программ
  */

  PROCEDURE proportionalrecalcalladd
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_add_tariff_netto   NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    l_fee_recalc         NUMBER;
    l_tariff_netto       NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
    --
    tbl_cover tbl_product_line_info;
  
  BEGIN
  
    log(p_p_cover_id, 'ProportionalRecalcAllAdd');
    log(p_p_cover_id, 'ProportionalRecalcAllAdd p_fee_amount ' || p_fee_amount);
    tbl_cover := get_cover_info(p_as_asset_id);
    --
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    l_fee_recalc := p_fee_amount - (l_all_fee - l_all_add_fee);
    log(p_p_cover_id
       ,'PROPORTIONALRECALCALLADD ALL_FEE ' || l_all_fee || ' ALL_ADD_FEE ' || l_all_add_fee);
    log(p_p_cover_id
       ,'PROPORTIONALRECALCALLADD Сумма, которая должна быть распределена между дополнительными программами = ' ||
        l_fee_recalc);
  
    --  Создание параметризованного представления
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
         AND NOT (tbl_cover(i).lob_brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life' /*, 'WOP', 'PWOP'*/))
         AND NOT (tbl_cover(i).p_cover_id = p_p_cover_id)
      THEN
      
        log(tbl_cover(i).p_cover_id
           , 'ProportionalRecalcAllAdd Покрытие ' || tbl_cover(i).p_cover_id || ' Программа ' || tbl_cover(i)
            .lob_brief);
      
        r_cover_param := get_calc_param(tbl_cover(i).p_cover_id);
        r_add_info    := get_add_info(tbl_cover(i).p_cover_id);
        --
        l_temp_fee := tbl_cover(i).fee;
        log(tbl_cover(i).p_cover_id, 'ProportionalRecalcAllAdd FEE ' || tbl_cover(i).fee);
        IF l_all_add_fee <> 0
        THEN
          l_add_fee := (l_temp_fee / l_all_add_fee) * l_fee_recalc;
        ELSE
          l_add_fee := 0;
        END IF;
      
        log(tbl_cover(i).p_cover_id
           ,'ProportionalRecalcAllAdd пересчитанный брутто взнос ' || l_add_fee);
      
        l_coef := nvl(pkg_tariff.calc_tarif_mul(tbl_cover(i).p_cover_id), 0);
      
        l_tariff_netto := pkg_cover.calc_tariff_netto(tbl_cover(i).p_cover_id);
        UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        tbl_cover(i).tariff := pkg_cover.calc_tariff(tbl_cover(i).p_cover_id);
      
        IF l_coef != 0
        THEN
          l_add_ins_amount := l_add_fee / (l_coef * tbl_cover(i).tariff);
          /*#407457*/
          ---          l_add_ins_amount := pkg_cover.round_ins_amount(tbl_cover(i).p_cover_id, l_add_ins_amount);
          log(tbl_cover(i).p_cover_id
             ,'ProportionalRecalcAllAdd Расчетная страховая сумма ' || l_add_ins_amount ||
              ' для тарифа ' || tbl_cover(i).tariff);
        END IF;
      
        UPDATE p_cover
           SET ins_amount = l_add_ins_amount
              ,tariff     = tbl_cover(i).tariff
         WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
        /*#407457*/
        --        l_add_fee := pkg_cover.round_fee(tbl_cover(i).p_cover_id, l_add_fee);
      
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
      
        /*
        
                l_add_ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id, l_add_ins_amount);
              
                log(resultset(i).p_cover_id
                   ,'RECALCWOPINSSUM Покрытие ' || resultset(i).p_cover_id || ' Округленная страховая сумма ' ||
                    l_add_ins_amount);
              
                UPDATE p_cover SET ins_amount = l_add_ins_amount WHERE p_cover_id = resultset(i).p_cover_id;
              
                l_add_tariff_netto := pkg_cover.calc_tariff_netto(resultset(i).p_cover_id);
                UPDATE p_cover SET tariff_netto = l_add_tariff WHERE p_cover_id = resultset(i).p_cover_id;
              
                l_add_tariff := pkg_cover.calc_tariff(resultset(i).p_cover_id);
              
                UPDATE p_cover SET tariff_netto = l_add_tariff WHERE p_cover_id = resultset(i).p_cover_id;
              
                l_add_fee := pkg_cover.calc_fee(resultset(i).p_cover_id);
                l_add_fee := pkg_cover.round_fee(resultset(i).p_cover_id, l_add_fee);
        */
      
        UPDATE p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
      END IF;
    END LOOP;
  
  END;

  /*
    Пропорциональный пересчет всех программ
    Для расчета берется сумма брутто взноса, из которой вычитается сумма основной и сервис программ
  */

  PROCEDURE proportionalrecalcall
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_add_tariff_netto   NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    l_fee_recalc         NUMBER;
    --
    r_cover_param calc_param;
    --
    tbl_cover tbl_product_line_info;
  
  BEGIN
  
    log(p_p_cover_id, 'ProportionalRecalcAll ');
  
    tbl_cover := get_cover_info(p_as_asset_id);
    --
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    l_fee_recalc := p_fee_amount - (l_all_fee - l_all_add_fee);
  
    log(p_p_cover_id
       ,'ProportionalRecalcAll Сумма, которая должна быть распределена между программами = ' ||
        l_fee_recalc);
  
    --  Создание параметризованного представления
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
         AND NOT (tbl_cover(i).lob_brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP'))
      THEN
      
        log(p_p_cover_id
           , 'ProportionalRecalcAll Покрытие ' || tbl_cover(i).p_cover_id || ' Программа ' || tbl_cover(i)
            .lob_brief);
      
        r_cover_param := get_calc_param(tbl_cover(i).p_cover_id);
        --
        l_temp_fee := tbl_cover(i).fee;
        log(tbl_cover(i).p_cover_id
           ,'ProportionalRecalcAll tbl_cover(i).fee ' || tbl_cover(i).fee ||
            ' tbl_cover(i).ins_amount ' || tbl_cover(i).ins_amount);
      
        l_add_fee := (l_temp_fee / l_all_fee) * p_fee_amount;
      
        log(p_p_cover_id
           ,'ProportionalRecalcAll пересчитанный брутто взнос ' || l_add_fee);
      
        l_coef := nvl(pkg_tariff.calc_tarif_mul(tbl_cover(i).p_cover_id), 0);
      
        IF l_coef != 0
        THEN
          l_add_ins_amount := l_add_fee / (l_coef * tbl_cover(i).tariff);
          /*#407457*/
          --          l_add_ins_amount := pkg_cover.round_ins_amount(tbl_cover(i).p_cover_id, l_add_ins_amount);
          log(tbl_cover(i).p_cover_id
             ,'PROPORTIONALRECALCALL Расчетная страховая сумма ' || l_add_ins_amount ||
              ' для тарифа ' || tbl_cover(i).tariff);
        
        END IF;
      
        UPDATE p_cover SET ins_amount = l_add_ins_amount WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        l_add_tariff_netto := pkg_cover.calc_tariff_netto(tbl_cover(i).p_cover_id);
      
        IF ROUND(l_add_tariff_netto, 6) = ROUND(tbl_cover(i).tariff_netto, 6)
        THEN
          l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
          --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
          /*#407457*/
          --          l_add_fee     := pkg_cover.round_fee(tbl_cover(i).p_cover_id, l_add_fee);
          l_add_premium := l_add_fee * r_cover_param.number_of_payment;
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
        
          log(tbl_cover(i).p_cover_id
             ,'PROPORTIONALRECALCALL FEE ' || l_add_fee || ' PREMIUM ' || l_add_premium);
        
        ELSE
          UPDATE p_cover
             SET tariff_netto = l_add_tariff_netto
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
        
          l_add_tariff := pkg_cover.calc_tariff(tbl_cover(i).p_cover_id);
        
          UPDATE p_cover SET tariff = l_add_tariff WHERE p_cover_id = tbl_cover(i).p_cover_id;
        
          l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
          --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
          l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
          log(tbl_cover(i).p_cover_id
             ,'PROPORTIONALRECALCALL FEE ' || l_add_fee || ' PREMIUM ' || l_add_premium);
        
        END IF;
      END IF;
    END LOOP;
  
  END;

  PROCEDURE primaryrecalc
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_ins_amount       NUMBER;
    l_primary_fee      NUMBER;
    l_primary_premium  NUMBER;
    l_primary_tariff   NUMBER;
    l_add_ins_amount   NUMBER;
    l_add_fee          NUMBER;
    l_all_add_fee      NUMBER;
    l_add_premium      NUMBER;
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_temp_fee         NUMBER;
    l_coef             NUMBER;
    l_fee_recalc       NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
    --
    tbl_cover tbl_product_line_info;
  
  BEGIN
  
    log(p_p_cover_id, 'PRIMARYRECALC ');
  
    tbl_cover := get_cover_info(p_as_asset_id);
    --
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    IF p_fee_amount IS NOT NULL
    THEN
      log(p_p_cover_id
         ,'PRIMARYRECALC Сумма взноса, которая должна быть добавлена ' || p_fee_amount);
    END IF;
    --  Создание параметризованного представления
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
         AND (tbl_cover(i).p_cover_id = p_p_cover_id)
      THEN
      
        r_add_info    := get_add_info(tbl_cover(i).p_cover_id);
        r_cover_param := get_calc_param(tbl_cover(i).p_cover_id);
        --
        l_coef := nvl(pkg_tariff.calc_tarif_mul(tbl_cover(i).p_cover_id), 0);
      
        IF l_coef != 0
        THEN
          IF p_fee_amount IS NULL
          THEN
            tbl_cover(i).fee := r_add_info.fee_prev;
          ELSE
            tbl_cover(i).fee := tbl_cover(i).fee + p_fee_amount;
          END IF;
        
          l_ins_amount := tbl_cover(i).fee / (l_coef * tbl_cover(i).tariff);
          log(tbl_cover(i).p_cover_id
             , 'PRIMARYRECALC Расчетная страховая сумма ' || l_ins_amount || ' для тарифа ' || tbl_cover(i)
              .tariff || ' COEF ' || l_coef || ' FEE ' || tbl_cover(i).fee);
        
        END IF;
      
        UPDATE p_cover SET ins_amount = l_ins_amount WHERE p_cover_id = tbl_cover(i).p_cover_id;
      
        l_add_tariff_netto := pkg_cover.calc_tariff_netto(tbl_cover(i).p_cover_id);
      
        IF ROUND(l_add_tariff_netto, 6) = ROUND(tbl_cover(i).tariff_netto, 6)
        THEN
          l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
          --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
          l_add_premium := l_add_fee * r_cover_param.number_of_payment;
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
          log(tbl_cover(i).p_cover_id
             ,'PRIMARYRECALC FEE ' || l_add_fee || ' PREMIUM ' || l_add_premium);
        
        ELSE
        
          UPDATE p_cover
             SET tariff_netto = l_add_tariff_netto
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
          l_add_tariff := pkg_cover.calc_tariff(tbl_cover(i).p_cover_id);
        
          UPDATE p_cover SET tariff = l_add_tariff WHERE p_cover_id = tbl_cover(i).p_cover_id;
          l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
          --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
          l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
          log(tbl_cover(i).p_cover_id
             ,'PRIMARYRECALC FEE ' || l_add_fee || ' PREMIUM ' || l_add_premium);
        
        END IF;
      END IF;
    END LOOP;
  
  END;

  PROCEDURE addrecalc
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_ins_amount       NUMBER;
    l_primary_fee      NUMBER;
    l_primary_premium  NUMBER;
    l_primary_tariff   NUMBER;
    l_add_ins_amount   NUMBER;
    l_add_fee          NUMBER;
    l_all_add_fee      NUMBER;
    l_add_premium      NUMBER;
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_temp_fee         NUMBER;
    l_coef             NUMBER;
    l_fee_recalc       NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
    --
    tbl_cover tbl_product_line_info;
  
  BEGIN
  
    log(p_p_cover_id, 'ADDRECALC ');
  
    tbl_cover := get_cover_info(p_as_asset_id);
    --
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    l_fee_recalc := p_fee_amount - (l_all_fee - l_all_add_fee);
  
    --  Создание параметризованного представления
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
         AND (tbl_cover(i).p_cover_id != p_p_cover_id)
         AND NOT (tbl_cover(i).lob_brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP'))
      THEN
      
        r_add_info    := get_add_info(tbl_cover(i).p_cover_id);
        r_cover_param := get_calc_param(tbl_cover(i).p_cover_id);
        --
        l_coef := nvl(pkg_tariff.calc_tarif_mul(tbl_cover(i).p_cover_id), 0);
      
        IF r_add_info.ins_amount_prev = r_cover_param.ins_amount
        THEN
          l_ins_amount := r_add_info.fee_prev / (l_coef * tbl_cover(i).tariff);
          UPDATE p_cover
             SET fee        = r_add_info.fee_prev
                ,ins_amount = l_ins_amount
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
          log(tbl_cover(i).p_cover_id
             ,'ADDRECALC FEE ' || r_add_info.fee_prev || ' INS_AMOUNT ' || l_ins_amount);
        END IF;
      
      END IF;
    END LOOP;
  
  END;

  PROCEDURE reusealladdinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    --
    r_cover_param calc_param;
    --
    tbl_cover tbl_product_line_info;
  
  BEGIN
  
    log(p_p_cover_id, 'RECALC P_AS_ASSET_ID ' || p_as_asset_id);
  
    tbl_cover := get_cover_info(p_as_asset_id);
    --
    --  Сумма брутто - взносов по основной  программеa
    SELECT ins_amount
          ,fee
      INTO l_primary_ins_amount
          ,l_primary_fee
      FROM v_asset_cover ac
     WHERE p_cover_id = p_p_cover_id;
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    log(p_p_cover_id
       ,'REUSEALLADDINSSUM Алгоритм переноса страховой премии дополнительных программ программ на основную программу');
  
    --
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).sh_brief = 'DELETED')
         AND NOT (tbl_cover(i).lob_brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP'))
         AND NOT (tbl_cover(i).p_cover_id = p_p_cover_id)
      THEN
      
        log(p_p_cover_id
           , 'REUSEALLADDINSSUM Покрытие ' || tbl_cover(i).p_cover_id || ' Программа ' || tbl_cover(i)
            .lob_brief);
      
        r_cover_param := get_calc_param(p_p_cover_id);
        --
        l_temp_fee := tbl_cover(i).fee;
        IF l_all_add_fee <> 0
        THEN
          l_add_fee := l_temp_fee - (l_temp_fee / l_all_add_fee) * (l_all_fee - p_fee_amount);
        ELSE
          l_add_fee := 0;
        END IF;
      
        log(p_p_cover_id
           ,'REUSEALLADDINSSUM Изменение брутто взноса договора ' || (l_all_fee - p_fee_amount) ||
            ' Сумма брутто доп программ ' || l_all_add_fee);
        log(p_p_cover_id
           ,'REUSEALLADDINSSUM По программе нужно чтобы брутто взнос был  ' || l_add_fee ||
            ' Сейчас брутто взнос ' || tbl_cover(i).fee);
      
        l_coef := nvl(pkg_tariff.calc_tarif_mul(tbl_cover(i).p_cover_id), 0);
      
        IF l_coef != 0
        THEN
          l_add_ins_amount := l_add_fee / (l_coef * tbl_cover(i).tariff);
          --l_add_ins_amount := pkg_cover.round_ins_amount (cur.p_cover_id, l_add_ins_amount);
        
          log(p_p_cover_id
             ,'REUSEALLADDINSSUM Расчетная страховая сумма ' || l_add_ins_amount);
        
        END IF;
      
        UPDATE p_cover SET ins_amount = l_add_ins_amount WHERE p_cover_id = tbl_cover(i).p_cover_id;
        l_add_tariff := pkg_cover.calc_tariff(tbl_cover(i).p_cover_id);
      
        IF ROUND(l_add_tariff, 6) = ROUND(tbl_cover(i).tariff, 6)
        THEN
          l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
          --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
          l_add_premium := l_add_fee * r_cover_param.number_of_payment;
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
        ELSE
          UPDATE p_cover SET tariff = l_add_tariff WHERE p_cover_id = tbl_cover(i).p_cover_id;
          l_add_fee := pkg_cover.calc_fee(tbl_cover(i).p_cover_id);
          --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
          l_add_premium := l_add_fee * r_cover_param.number_of_payment;
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = tbl_cover(i).p_cover_id;
        END IF;
      END IF;
    END LOOP;
  
  END;

  /*
    Уменьшение страховых сумм по доп. программам.
    Страховая сумма доп. программы не может быть больше, чем по основной программе
  */
  PROCEDURE decreasealladdinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_add_tariff_netto   NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    --
    r_add_info         add_info;
    r_cover_param      calc_param;
    r_cover_param_prev calc_param;
    resultset          tbl_product_line_info;
    --
  BEGIN
    --
  
    log(p_p_cover_id, 'DECREASEALLADDINSSUM');
  
    resultset := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. resultset.count
    LOOP
      IF resultset(i).p_cover_id = p_p_cover_id
      THEN
        l_primary_ins_amount := resultset(i).ins_amount;
        EXIT;
      END IF;
    END LOOP;
  
    FOR i IN 1 .. resultset.count
    LOOP
      /* Если программа дополнительная и подлежит пересчету, то */
      IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
          AND NOT resultset(i).p_cover_id = p_p_cover_id
          AND NOT resultset(i).sh_brief = 'DELETED'
      THEN
      
        IF resultset(i).ins_amount > l_primary_ins_amount
        THEN
          log(p_p_cover_id
             ,'DECREASEALLADDINSSUM INSAMOUNT ' || resultset(i).ins_amount || ' > ' ||
              l_primary_ins_amount);
        
          UPDATE p_cover
             SET ins_amount = l_primary_ins_amount
           WHERE p_cover_id = resultset(i).p_cover_id;
        
          r_add_info         := get_add_info(resultset(i).p_cover_id);
          r_cover_param      := get_calc_param(r_add_info.p_cover_id_curr);
          r_cover_param_prev := get_calc_param(r_add_info.p_cover_id_prev);
        
          UPDATE p_cover
             SET s_coef    = r_cover_param_prev.s_coef
                ,k_coef    = r_cover_param_prev.k_coef
                ,s_coef_m  = r_cover_param_prev.s_coef_m
                ,k_coef_m  = r_cover_param_prev.k_coef_m
                ,s_coef_nm = r_cover_param_prev.s_coef_nm
                ,k_coef_nm = r_cover_param_prev.k_coef_nm
           WHERE p_cover_id = resultset(i).p_cover_id;
        
          l_add_tariff_netto := pkg_cover.calc_tariff_netto(resultset(i).p_cover_id);
        
          UPDATE p_cover
             SET tariff_netto = l_add_tariff_netto
           WHERE p_cover_id = resultset(i).p_cover_id;
        
          l_add_tariff := pkg_cover.calc_tariff(resultset(i).p_cover_id);
        
          UPDATE p_cover SET tariff = l_add_tariff WHERE p_cover_id = resultset(i).p_cover_id;
        
          l_add_fee     := pkg_cover.calc_fee(resultset(i).p_cover_id);
          l_add_premium := resultset(i).number_of_payments * l_add_fee;
        
          UPDATE p_cover
             SET fee     = l_add_fee
                ,premium = l_add_premium
           WHERE p_cover_id = resultset(i).p_cover_id;
        
          log(p_p_cover_id
             ,'DECREASEALLADDINSSUM INSAMOUNT ' || l_primary_ins_amount || ' ADD_PREMIUM ' ||
              l_add_premium || ' ADD_FEE ' || l_add_fee);
        
          UPDATE p_cover
             SET s_coef    = r_cover_param.s_coef
                ,k_coef    = r_cover_param.k_coef
                ,s_coef_m  = r_cover_param.s_coef_m
                ,k_coef_m  = r_cover_param.k_coef_m
                ,s_coef_nm = r_cover_param.s_coef_nm
                ,k_coef_nm = r_cover_param.k_coef_nm
           WHERE p_cover_id = resultset(i).p_cover_id;
        END IF;
      END IF;
    END LOOP;
    --
  
  END;

  PROCEDURE decreasealladdinssumprevcoef
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_add_tariff_netto   NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    --
    r_add_info         add_info;
    r_cover_param      calc_param;
    r_cover_param_prev calc_param;
    resultset          tbl_product_line_info;
    --
  BEGIN
    --
  
    log(p_p_cover_id, 'DECREASEALLADDINSSUM');
  
    resultset := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. resultset.count
    LOOP
      IF resultset(i).p_cover_id = p_p_cover_id
      THEN
        l_primary_ins_amount := resultset(i).ins_amount;
        EXIT;
      END IF;
    END LOOP;
  
    FOR i IN 1 .. resultset.count
    LOOP
      /* Если программа дополнительная и подлежит пересчету, то */
      IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
          AND NOT resultset(i).p_cover_id = p_p_cover_id
          AND NOT resultset(i).sh_brief = 'DELETED'
      THEN
      
        IF resultset(i).ins_amount > l_primary_ins_amount
        THEN
          log(p_p_cover_id
             ,'DECREASEALLADDINSSUM INSAMOUNT ' || resultset(i).ins_amount || ' > ' ||
              l_primary_ins_amount);
        
          UPDATE p_cover
             SET ins_amount = l_primary_ins_amount
           WHERE p_cover_id = resultset(i).p_cover_id;
        END IF;
      
        r_add_info         := get_add_info(resultset(i).p_cover_id);
        r_cover_param      := get_calc_param(r_add_info.p_cover_id_curr);
        r_cover_param_prev := get_calc_param(r_add_info.p_cover_id_prev);
      
        UPDATE p_cover
           SET s_coef    = r_cover_param_prev.s_coef
              ,k_coef    = r_cover_param_prev.k_coef
              ,s_coef_m  = r_cover_param_prev.s_coef_m
              ,k_coef_m  = r_cover_param_prev.k_coef_m
              ,s_coef_nm = r_cover_param_prev.s_coef_nm
              ,k_coef_nm = r_cover_param_prev.k_coef_nm
         WHERE p_cover_id = resultset(i).p_cover_id;
      
        l_add_tariff_netto := pkg_cover.calc_tariff_netto(resultset(i).p_cover_id);
      
        UPDATE p_cover
           SET tariff_netto = l_add_tariff_netto
         WHERE p_cover_id = resultset(i).p_cover_id;
      
        l_add_tariff := pkg_cover.calc_tariff(resultset(i).p_cover_id);
      
        UPDATE p_cover SET tariff = l_add_tariff WHERE p_cover_id = resultset(i).p_cover_id;
      
        l_add_fee     := pkg_cover.calc_fee(resultset(i).p_cover_id);
        l_add_premium := resultset(i).number_of_payments * l_add_fee;
      
        UPDATE p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = resultset(i).p_cover_id;
      
        log(p_p_cover_id
           ,'DECREASEALLADDINSSUM INSAMOUNT ' || l_primary_ins_amount || ' ADD_PREMIUM ' ||
            l_add_premium || ' ADD_FEE ' || l_add_fee);
      
        UPDATE p_cover
           SET s_coef    = r_cover_param.s_coef
              ,k_coef    = r_cover_param.k_coef
              ,s_coef_m  = r_cover_param.s_coef_m
              ,k_coef_m  = r_cover_param.k_coef_m
              ,s_coef_nm = r_cover_param.s_coef_nm
              ,k_coef_nm = r_cover_param.k_coef_nm
         WHERE p_cover_id = resultset(i).p_cover_id;
      END IF;
    END LOOP;
    --
  
  END;

  PROCEDURE reuseoldaddinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_log         OUT VARCHAR2
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
    --
  BEGIN
    --
    --  Создание параметризованного представления
    pkg_xx_as_asset.set_as_asset_id(p_as_asset_id);
  
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND p_cover_id != p_p_cover_id
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM t_lob_line     ll
                              ,t_product_line pl
                         WHERE pl.id = ac.id
                           AND ll.t_lob_line_id = pl.t_lob_line_id
                           AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')))
    LOOP
      -- Набор параметров,характеризующих покрытие
      --
      log(p_p_cover_id, 'REUSEOLDADDINSSUM Покрытие ' || cur.p_cover_id);
      r_cover_param := get_calc_param(p_p_cover_id);
      r_add_info    := get_add_info(p_p_cover_id);
    
      --
      l_temp_fee := r_add_info.fee_curr;
      IF l_all_add_fee <> 0
      THEN
        l_add_fee := l_temp_fee - (l_temp_fee / l_all_add_fee) * (l_all_fee - p_fee_amount);
      ELSE
        l_add_fee := 0;
      END IF;
    
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM Брутто взнос по договору ' || l_all_fee);
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM Брутто взнос по договору (необходимый)' || p_fee_amount);
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM Изменение брутто взноса основной программы ' ||
          (l_all_fee - p_fee_amount));
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM По программе нужно чтобы брутто взнос был  ' || l_add_fee);
    
      l_coef := nvl(pkg_tariff.calc_tarif_mul(cur.p_cover_id), 0);
    
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM По основной программе брутто взнос равен ' || l_primary_fee);
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM По дополнительной программе брутто взнос равен ' || cur.fee);
      log(p_p_cover_id
         ,'REUSEOLDADDINSSUM Итоговый коэффициент по покрытию ' || l_coef);
    
      IF l_coef != 0
      THEN
        l_add_ins_amount := l_add_fee / (l_coef * cur.tariff);
        --l_add_ins_amount := pkg_cover.round_ins_amount (cur.p_cover_id, l_add_ins_amount);
      
        log(p_p_cover_id
           ,'REUSEOLDADDINSSUM Расчетная страховая сумма ' || l_add_ins_amount);
      
      END IF;
    
      UPDATE ven_p_cover SET ins_amount = l_add_ins_amount WHERE p_cover_id = cur.p_cover_id;
      l_add_tariff := pkg_cover.calc_tariff(cur.p_cover_id);
    
      IF ROUND(l_add_tariff, 6) = ROUND(cur.tariff, 6)
      THEN
        l_add_fee := pkg_cover.calc_fee(cur.p_cover_id);
        --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = cur.p_cover_id;
      ELSE
        UPDATE ven_p_cover SET tariff = l_add_tariff WHERE p_cover_id = cur.p_cover_id;
        l_add_fee := pkg_cover.calc_fee(cur.p_cover_id);
        --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = cur.p_cover_id;
      END IF;
    END LOOP;
  
    SELECT ins_amount
          ,fee
      INTO l_primary_ins_amount
          ,l_primary_fee
      FROM v_asset_cover
     WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id
       ,'REUSEOLDADDINSSUM По основной программе брутто взнос равен ' || l_primary_fee);
    --
  
  END;

  PROCEDURE reusefixedaddinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_log         OUT VARCHAR2
  ) IS
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    --
    r_cover_param calc_param;
    --
  BEGIN
    --
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED'))
    LOOP
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM' || 'ИД ' || cur.p_cover_id || ' cur.ins_amount ' || cur.ins_amount ||
          ' cur.fee ' || cur.fee);
    END LOOP;
  
    --  Сумма брутто - взносов по основной  программеa
    SELECT ins_amount
          ,fee
      INTO l_primary_ins_amount
          ,l_primary_fee
      FROM v_asset_cover ac
     WHERE p_cover_id = p_p_cover_id;
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    log(p_p_cover_id
       ,'REUSEFIXEDADDINSSUM Алгоритм переноса страховой премии дополнительных программ программ на основную программу');
  
    --
    --  Создание параметризованного представления
    pkg_xx_as_asset.set_as_asset_id(p_as_asset_id);
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND p_cover_id != p_p_cover_id
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM t_lob_line     ll
                              ,t_product_line pl
                         WHERE pl.id = ac.id
                           AND ll.t_lob_line_id = pl.t_lob_line_id
                           AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')))
    LOOP
      -- Набор параметров,характеризующих покрытие
      r_cover_param := get_calc_param(p_p_cover_id);
      --
      l_temp_fee := cur.fee;
      IF l_all_add_fee <> 0
      THEN
        l_add_fee := l_temp_fee - (l_temp_fee / l_all_add_fee) * (l_all_fee - p_fee_amount);
      ELSE
        l_add_fee := 0;
      END IF;
    
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM Брутто взнос по договору ' || l_all_fee);
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM Брутто взнос по договору (необходимый)' || p_fee_amount);
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM Изменение брутто взноса основной программы ' ||
          (l_all_fee - p_fee_amount));
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM По программе нужно чтобы брутто взнос был  ' || l_add_fee);
    
      l_coef := nvl(pkg_tariff.calc_tarif_mul(cur.p_cover_id), 0);
    
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM По основной программе брутто взнос равен ' || l_primary_fee);
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM По дополнительной программе брутто взнос равен ' || cur.fee);
      log(p_p_cover_id
         ,'REUSEFIXEDADDINSSUM Итоговый коэффициент по покрытию ' || l_coef);
    
      IF l_coef != 0
      THEN
        l_add_ins_amount := l_add_fee / (l_coef * cur.tariff);
        --l_add_ins_amount := pkg_cover.round_ins_amount (cur.p_cover_id, l_add_ins_amount);
      
        log(p_p_cover_id
           ,'REUSEFIXEDADDINSSUM Расчетная страховая сумма ' || l_add_ins_amount);
      
      END IF;
    
      UPDATE ven_p_cover SET ins_amount = l_add_ins_amount WHERE p_cover_id = cur.p_cover_id;
      l_add_tariff := pkg_cover.calc_tariff(cur.p_cover_id);
    
      IF ROUND(l_add_tariff, 6) = ROUND(cur.tariff, 6)
      THEN
        l_add_fee := pkg_cover.calc_fee(cur.p_cover_id);
        --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = cur.p_cover_id;
      ELSE
        UPDATE ven_p_cover SET tariff = l_add_tariff WHERE p_cover_id = cur.p_cover_id;
        l_add_fee := pkg_cover.calc_fee(cur.p_cover_id);
        --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
        l_add_premium := l_add_fee * r_cover_param.number_of_payment;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = cur.p_cover_id;
      END IF;
    END LOOP;
  
    SELECT ins_amount
          ,fee
      INTO l_primary_ins_amount
          ,l_primary_fee
      FROM v_asset_cover
     WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id
       ,'REUSEFIXEDADDINSSUM По основной программе брутто взнос равен ' || l_primary_fee);
    --
  
  END;

  PROCEDURE recalcwopinssum
  (
    p_as_asset_id IN NUMBER
   ,p_cover_id    IN NUMBER
  ) IS
    l_add_ins_amount   NUMBER;
    l_add_fee          NUMBER;
    l_all_add_fee      NUMBER;
    l_add_premium      NUMBER;
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_coef             NUMBER;
    --
    r_cover_param calc_param;
    r_cover_param calc_param;
    resultset     tbl_product_line_info;
    --
  BEGIN
    --
    resultset := get_cover_info(p_as_asset_id);
    --  Создание параметризованного представления
    log(p_cover_id, 'RECALCWOPINSSUM START');
    FOR i IN 1 .. resultset.count
    LOOP
      IF NOT (resultset(i).sh_brief = 'DELETED')
         AND (resultset(i).lob_brief IN ('WOP', 'PWOP', 'PWOP'))
      THEN
        log(resultset(i).p_cover_id
           ,'RECALCWOPINSSUM Покрытие ' || resultset(i).p_cover_id || ' Запускаем расчет стр. суммы ');
        l_add_ins_amount := pkg_cover.calc_ins_amount(resultset(i).p_cover_id);
        log(resultset(i).p_cover_id
           ,'RECALCWOPINSSUM Покрытие ' || resultset(i).p_cover_id || ' Страховая сумма ' ||
            l_add_ins_amount);
      
        l_add_ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id, l_add_ins_amount);
      
        log(resultset(i).p_cover_id
           ,'RECALCWOPINSSUM Покрытие ' || resultset(i).p_cover_id || ' Округленная страховая сумма ' ||
            l_add_ins_amount);
      
        UPDATE p_cover SET ins_amount = l_add_ins_amount WHERE p_cover_id = resultset(i).p_cover_id;
      
        l_add_tariff_netto := pkg_cover.calc_tariff_netto(resultset(i).p_cover_id);
        UPDATE p_cover SET tariff_netto = l_add_tariff WHERE p_cover_id = resultset(i).p_cover_id;
      
        l_add_tariff := pkg_cover.calc_tariff(resultset(i).p_cover_id);
      
        UPDATE p_cover SET tariff_netto = l_add_tariff WHERE p_cover_id = resultset(i).p_cover_id;
      
        l_add_fee := pkg_cover.calc_fee(resultset(i).p_cover_id);
        l_add_fee := pkg_cover.round_fee(resultset(i).p_cover_id, l_add_fee);
      
        log(resultset(i).p_cover_id
           ,'RECALCWOPINSSUM Покрытие ' || resultset(i).p_cover_id || ' Брутто взнос ' || l_add_fee);
      
        l_add_premium := l_add_fee * resultset(i).number_of_payments;
        UPDATE ven_p_cover
           SET fee     = l_add_fee
              ,premium = l_add_premium
         WHERE p_cover_id = resultset(i).p_cover_id;
      
      END IF;
    
    END LOOP;
  
    --
  
  END;

  PROCEDURE increaseprimaryinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_ins_amount         NUMBER;
  
    l_primary_fee          NUMBER;
    l_primary_premium      NUMBER;
    l_primary_tariff       NUMBER;
    l_primary_tariff_netto NUMBER;
  
    l_add_ins_amount NUMBER;
    l_add_fee        NUMBER;
    l_all_add_fee    NUMBER;
    l_add_premium    NUMBER;
  
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_temp_fee         NUMBER;
    --
    l_first_value NUMBER;
    l_coef        NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
  
    l_dropped_fee NUMBER;
  
    --
  BEGIN
    --  Создание параметризованного представления
  
    log(p_p_cover_id
       ,'INCREASEPRIMARYINSSUM Сумма брутто взносов по отключенным программам ' || l_dropped_fee);
    --
    r_cover_param := get_calc_param(p_p_cover_id);
    r_add_info    := get_add_info(p_p_cover_id);
  
    l_primary_fee := r_add_info.fee_prev + l_dropped_fee;
  
    log(p_p_cover_id
       ,'INCREASEPRIMARYINSSUM По основной программе новый взнос ' || l_primary_fee);
  
    l_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    IF l_coef != 0
    THEN
      l_primary_ins_amount := l_primary_fee / (l_coef * r_cover_param.tariff);
      --l_primary_ins_amount := pkg_cover.round_ins_amount (p_p_cover_id, l_primary_ins_amount);
    END IF;
  
    l_primary_premium := l_primary_fee * r_cover_param.number_of_payment;
  
    UPDATE p_cover
       SET fee        = l_primary_fee
          ,premium    = l_primary_premium
          ,ins_amount = l_primary_ins_amount
     WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id
       ,'INCREASEPRIMARYINSSUM По основной программе новая страховая сумма ' || l_primary_ins_amount);
  
    --
  END;

  PROCEDURE restoreprimaryinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_ins_amount         NUMBER;
  
    l_primary_fee          NUMBER;
    l_primary_premium      NUMBER;
    l_primary_tariff       NUMBER;
    l_primary_tariff_netto NUMBER;
  
    l_add_ins_amount NUMBER;
    l_add_fee        NUMBER;
    l_all_add_fee    NUMBER;
    l_add_premium    NUMBER;
  
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_temp_fee         NUMBER;
    --
    l_first_value NUMBER;
    l_coef        NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
  
    l_dropped_fee NUMBER;
  
    l_log VARCHAR2(32000);
    --
  BEGIN
    --  Создание параметризованного представления
    pkg_xx_as_asset.set_as_asset_id(p_as_asset_id);
  
    log(p_p_cover_id
       ,'RESTOREPRIMARYINSSUM Восстановление страховой суммы основной программы ');
    --
    r_cover_param := get_calc_param(p_p_cover_id);
    r_add_info    := get_add_info(p_p_cover_id);
  
    l_ins_amount := r_add_info.ins_amount_prev;
  
    log(p_p_cover_id
       ,'RESTOREPRIMARYINSSUM По основной программе устанавливаем страховую сумму  ' || l_ins_amount);
  
    UPDATE ven_p_cover SET ins_amount = l_ins_amount WHERE p_cover_id = p_p_cover_id;
  
    l_primary_tariff_netto := pkg_cover.calc_tariff_netto(p_p_cover_id);
    l_primary_tariff       := pkg_cover.calc_tariff(p_p_cover_id);
  
    UPDATE p_cover
       SET tariff_netto = l_primary_tariff_netto
          ,tariff       = l_primary_tariff
     WHERE p_cover_id = p_p_cover_id;
  
    l_primary_fee     := pkg_cover.calc_fee(p_p_cover_id);
    l_primary_fee     := pkg_cover.round_fee(p_p_cover_id, l_primary_fee);
    l_primary_premium := l_primary_fee * r_cover_param.number_of_payment;
  
    l_primary_premium := l_primary_fee * r_cover_param.number_of_payment;
  
    UPDATE p_cover
       SET fee     = l_primary_fee
          ,premium = l_primary_premium
     WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id
       ,'RESTOREPRIMARYINSSUM По основной программе новый брутто взнос ' || l_primary_fee);
    --
  END;

  PROCEDURE increaseinssum
  (
    p_as_asset_id   IN NUMBER
   ,p_p_cover_id    IN NUMBER
   ,p_fee_amount    IN NUMBER
   ,p_fee_up_amount IN NUMBER
  ) IS
  
    l_all_fee      NUMBER;
    l_fee          NUMBER;
    l_premium      NUMBER;
    l_tariff       NUMBER;
    l_tariff_netto NUMBER;
    l_ins_amount   NUMBER;
  
    l_coef NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
  
    --
  BEGIN
    --  Создание параметризованного представления
    --
    r_cover_param := get_calc_param(p_p_cover_id);
    r_add_info    := get_add_info(p_p_cover_id);
  
    l_all_fee := getsumfee(p_as_asset_id);
  
    l_fee := r_cover_param.fee + p_fee_up_amount;
  
    log(p_p_cover_id, 'INCREASEINSSUM По программе новый взнос ' || l_fee);
  
    l_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
  
    IF l_coef != 0
    THEN
      l_ins_amount := l_fee / (l_coef * r_cover_param.tariff);
    ELSE
      l_ins_amount := 0;
    END IF;
  
    l_premium := l_fee * r_cover_param.number_of_payment;
  
    UPDATE p_cover
       SET fee        = l_fee
          ,premium    = l_premium
          ,ins_amount = l_ins_amount
     WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id
       ,'INCREASEINSSUM По программе новая страховая сумма ' || l_ins_amount);
    --
  END;

  /*
  Изменение страховой суммы и брутто премии по всем программам, для поиска рекомендованного брутто взноса
  */

  PROCEDURE reuseallinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_ins_amount         NUMBER;
  
    l_primary_fee          NUMBER;
    l_primary_premium      NUMBER;
    l_primary_tariff       NUMBER;
    l_primary_tariff_netto NUMBER;
  
    l_add_ins_amount NUMBER;
    l_add_fee        NUMBER;
    l_all_add_fee    NUMBER;
    l_add_premium    NUMBER;
  
    l_add_tariff       NUMBER;
    l_add_tariff_netto NUMBER;
    l_all_fee          NUMBER;
    l_temp_fee         NUMBER;
    --
    l_first_value NUMBER;
    l_coef        NUMBER;
    --
    r_cover_param calc_param;
    r_add_info    add_info;
  
    l_log VARCHAR2(32000);
    --
  BEGIN
    --  Создание параметризованного представления
    pkg_xx_as_asset.set_as_asset_id(p_as_asset_id);
  
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED'))
    LOOP
      log(p_p_cover_id
         ,'REUSEALLINSSUM ' || 'ИД ' || cur.p_cover_id || ' cur.ins_amount ' || cur.ins_amount ||
          ' cur.fee ' || cur.fee);
    END LOOP;
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Алгоритм поиска страховых сумм по дополнительным программам (сумма доп программ меньше прироста основной');
    --
    r_cover_param := get_calc_param(p_p_cover_id);
    r_add_info    := get_add_info(p_p_cover_id);
    l_primary_fee := r_add_info.fee_prev;
    l_coef        := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
    l_ins_amount  := r_cover_param.ins_amount;
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Изменение суммы брутто взноса на значение пред. версии = ' || l_primary_fee);
  
    IF l_coef != 0
    THEN
      l_primary_ins_amount := l_primary_fee / (l_coef * r_cover_param.tariff);
      --l_primary_ins_amount := pkg_cover.round_ins_amount (p_p_cover_id, l_primary_ins_amount);
    END IF;
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Изменение страховой суммы для брутто взноса ' || l_primary_fee ||
        ' Полученная страховая сумма ' || l_primary_ins_amount);
  
    l_primary_premium := l_primary_fee * r_cover_param.number_of_payment;
    UPDATE ven_p_cover
       SET ins_amount = l_primary_ins_amount
          ,fee        = l_primary_fee
          ,premium    = l_primary_premium
     WHERE p_cover_id = p_p_cover_id;
  
    --  Сумма брутто - взносов по основной  программеa
    log(p_p_cover_id
       ,'REUSEALLINSSUM Изменение страховой суммы для дополнительных программ');
  
    l_first_value := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND p_cover_id != p_p_cover_id
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM t_lob_line     ll
                              ,t_product_line pl
                         WHERE pl.id = ac.id
                           AND ll.t_lob_line_id = pl.t_lob_line_id
                           AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')))
    LOOP
    
      IF cur.ins_amount > l_primary_ins_amount
      THEN
        UPDATE p_cover SET ins_amount = l_primary_ins_amount WHERE p_cover_id = cur.p_cover_id;
      
        log(p_p_cover_id
           ,'REUSEALLINSSUM Страховая сумма покрытия (' || cur.p_cover_id || ') откорректирована (' ||
            l_primary_ins_amount || ')');
      
      END IF;
    
    END LOOP;
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Расчет брутто взноса по дополнительным программам. исходя из новой стр. суммы');
  
    -- Расчет брутто взноса по дополнительным программам. исходя из новой стр. суммы
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND p_cover_id != p_p_cover_id
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM t_lob_line     ll
                              ,t_product_line pl
                         WHERE pl.id = ac.id
                           AND ll.t_lob_line_id = pl.t_lob_line_id
                           AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')))
    LOOP
      -- Набор параметров,характеризующих покрытие
      l_add_tariff_netto := pkg_cover.calc_tariff_netto(cur.p_cover_id);
      l_add_tariff       := pkg_cover.calc_tariff(cur.p_cover_id);
      l_add_fee          := pkg_cover.calc_fee(cur.p_cover_id);
      --l_add_fee := pkg_cover.round_fee (cur.p_cover_id, l_add_fee);
      l_add_premium := l_add_fee * r_cover_param.number_of_payment;
    
      log(p_p_cover_id
         ,'REUSEALLINSSUM Брутто взнос по дополнительной программе (' || cur.p_cover_id || ') ' ||
          l_add_fee || ' исходя из новой стр. суммы ' || cur.ins_amount);
    
      UPDATE p_cover
         SET tariff_netto = l_add_tariff_netto
            ,tariff       = l_add_tariff
            ,fee          = l_add_fee
            ,premium      = l_add_premium
       WHERE p_cover_id = cur.p_cover_id;
    
    END LOOP;
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    l_first_value := l_first_value - l_all_add_fee;
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Сумма брутто - взносов по всем программам после уменьшения стр. суммы ' ||
        l_all_fee);
    log(p_p_cover_id
       ,'REUSEALLINSSUM Сумма брутто - взносов по всем доп. программам после уменьшения стр. суммы ' ||
        l_all_add_fee);
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Поиск решения для выравнивания брутто взноса на величину ' ||
        (p_fee_amount - l_all_fee));
  
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED'))
    LOOP
      log(p_p_cover_id
         ,'REUSEALLINSSUM ' || 'ИД ' || cur.p_cover_id || ' cur.ins_amount ' || cur.ins_amount ||
          ' cur.fee ' || cur.fee);
    END LOOP;
  
    --
    SAVEPOINT try_lock_amount;
    --
    UPDATE ven_p_cover SET ins_amount = l_ins_amount WHERE p_cover_id = p_p_cover_id;
    l_primary_tariff_netto := pkg_cover.calc_tariff_netto(p_p_cover_id);
    l_primary_tariff       := pkg_cover.calc_tariff(p_p_cover_id);
  
    UPDATE ven_p_cover
       SET tariff       = l_primary_tariff
          ,tariff_netto = l_primary_tariff_netto
     WHERE p_cover_id = p_p_cover_id;
  
    l_primary_fee := pkg_cover.calc_fee(p_p_cover_id);
    --l_primary_fee := pkg_cover.round_fee (p_p_cover_id, l_primary_fee);
    l_add_premium := l_add_fee * r_cover_param.number_of_payment;
  
    UPDATE p_cover
       SET fee     = l_primary_fee
          ,premium = l_add_premium
     WHERE p_cover_id = p_p_cover_id;
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Проверка текущей суммы всех взносов (' || l_all_fee ||
        ') и рекомендуемого брутто взноса (' || p_fee_amount ||
        ') при попытке удержать стр. сумму по пред. версии');
  
    IF l_all_fee > p_fee_amount
    THEN
      log(p_p_cover_id
         ,'REUSEALLINSSUM Удержать страховую сумму не удалось. ');
      ROLLBACK TO try_lock_amount;
    END IF;
  
    FOR cur IN (SELECT *
                  FROM v_asset_cover ac
                 WHERE as_asset_id IS NOT NULL
                   AND NOT EXISTS (SELECT 1
                          FROM status_hist sh
                         WHERE sh.status_hist_id = ac.status_hist_id
                           AND sh.brief = 'DELETED'))
    LOOP
      log(p_p_cover_id
         ,'REUSEALLINSSUM ' || 'ИД ' || cur.p_cover_id || ' cur.ins_amount ' || cur.ins_amount ||
          ' cur.fee ' || cur.fee);
    END LOOP;
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    log(p_p_cover_id
       ,'REUSEALLINSSUM Сумма брутто - взносов по всем программам после удержания стр. суммы осн. программы ' ||
        l_all_fee);
    log(p_p_cover_id
       ,'REUSEALLINSSUM Cвободный брутто взнос ' || (p_fee_amount - l_all_fee) ||
        ' Освобожденный брутто взнос после корректировки доп программ ' || l_first_value);
  
    r_cover_param := get_calc_param(p_p_cover_id);
  
    l_primary_ins_amount := r_add_info.ins_amount_curr;
  
    IF r_cover_param.ins_amount = r_add_info.ins_amount_prev
       AND (p_fee_amount - l_all_fee) > 0
    THEN
      log(p_p_cover_id, 'REUSEALLINSSUM Условие 1');
      log(p_p_cover_id
         ,'REUSEALLINSSUM Сумма брутто - взносов по всем программам после удержания стр. суммы осн. программы ' ||
          l_all_fee);
    
      --  Перенос остатка брутто взноса  на дополнительные программы
      insreaseaddinssum(p_as_asset_id, p_p_cover_id, p_fee_amount, l_log);
    
    ELSIF r_cover_param.ins_amount < r_add_info.ins_amount_prev
          AND (p_fee_amount - l_all_fee) > 0
    THEN
      log(p_p_cover_id, 'REUSEALLINSSUM Условие 2');
      log(p_p_cover_id
         ,'REUSEALLINSSUM Сумма брутто - взносов по всем программам после удержания стр. суммы осн. программы ' ||
          l_all_fee);
      --  Перенос остатка брутто взноса  на дополнительные программы
      increaseinssum(p_as_asset_id, p_p_cover_id, p_fee_amount, (p_fee_amount - l_all_fee));
    
      --  Сумма брутто - взносов по всем программам
      l_all_fee := getsumfee(p_as_asset_id);
    
      --  Сумма брутто - взносов по дополнительным программам
      l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    
      log(p_p_cover_id
         ,'REUSEALLINSSUM Сумма брутто - взносов по всем программам после удержания стр. суммы осн. программы ' ||
          l_all_fee);
      log(p_p_cover_id
         ,'REUSEALLINSSUM Cвободный брутто взнос ' || (p_fee_amount - l_all_fee));
    
      FOR cur IN (SELECT *
                    FROM v_asset_cover ac
                   WHERE as_asset_id IS NOT NULL
                     AND NOT EXISTS (SELECT 1
                            FROM status_hist sh
                           WHERE sh.status_hist_id = ac.status_hist_id
                             AND sh.brief = 'DELETED'))
      LOOP
        log(p_p_cover_id
           ,'REUSEALLINSSUM ' || 'ИД ' || cur.p_cover_id || ' cur.ins_amount ' || cur.ins_amount ||
            ' cur.fee ' || cur.fee);
      END LOOP;
    
    ELSE
      log(p_p_cover_id, 'REUSEALLINSSUM Условие 3');
      r_cover_param := get_calc_param(p_p_cover_id);
      l_primary_fee := r_cover_param.fee + (p_fee_amount - l_all_fee);
    
      log(p_p_cover_id
         ,'REUSEALLINSSUM По основной программе новый взнос ' || l_primary_fee);
    
      l_coef := nvl(pkg_tariff.calc_tarif_mul(p_p_cover_id), 0);
    
      IF l_coef != 0
      THEN
        l_primary_ins_amount := l_primary_fee / (l_coef * r_cover_param.tariff);
        --l_primary_ins_amount := pkg_cover.round_ins_amount (p_p_cover_id, l_primary_ins_amount);
      END IF;
    
      log(p_p_cover_id
         ,'REUSEALLINSSUM По основной программе новая страховая сумма ' || l_primary_ins_amount);
    
      l_primary_premium := l_primary_fee * r_cover_param.number_of_payment;
      UPDATE ven_p_cover
         SET ins_amount = l_primary_ins_amount
            ,fee        = l_primary_fee
            ,premium    = l_primary_premium
       WHERE p_cover_id = p_p_cover_id;
    
      --  Сумма брутто - взносов по всем программам
      l_all_fee := getsumfee(p_as_asset_id);
    
      --  Сумма брутто - взносов по дополнительным программам
      l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    
      log(p_p_cover_id
         ,'REUSEALLINSSUM Сумма брутто - взносов по всем программам после пересчета стр. суммы основной программы ' ||
          l_all_fee);
      log(p_p_cover_id
         ,'REUSEALLINSSUM Сумма брутто - взносов по всем доп. программам ' || l_all_add_fee);
      log(p_p_cover_id
         ,'REUSEALLINSSUM Нераспределенный взнос ' || (p_fee_amount - l_all_fee));
    
      IF NOT (p_fee_amount - l_all_fee) = 0
      THEN
        --    Перенос остатка брутто взноса  на дополнительные программы
      
        insreaseaddinssum(p_as_asset_id, p_p_cover_id, p_fee_amount, l_log);
      
      END IF;
    END IF;
  
    --
  END;

  /*
    Изменение страховой суммы по доп программам, по которым было зафиксировано изменение тарифа
  */

  PROCEDURE reusechangedaddinssum
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    l_primary_ins_amount NUMBER;
    l_fee                NUMBER;
    l_premium            NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_add_fee            NUMBER;
    l_all_add_fee        NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    --
    r_cover_param      calc_param;
    r_cover_param_prev calc_param;
    r_add_info         add_info;
    --
    tbl_cover tbl_product_line_info;
  BEGIN
  
    tbl_cover := get_cover_info(p_as_asset_id);
    --
    log(p_p_cover_id
       ,'REUSECHANGEDADDINSSUM Алгоритм изменения страховой премии дополнительных программ по пр. версии');
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
      IF NOT (tbl_cover(i).p_cover_id = p_p_cover_id)
         AND NOT (tbl_cover(i).sh_brief = 'DELETED')
         AND NOT (tbl_cover(i).lob_brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP'))
      THEN
      
        r_add_info         := get_add_info(tbl_cover(i).p_cover_id);
        r_cover_param      := get_calc_param(r_add_info.p_cover_id_curr);
        r_cover_param_prev := get_calc_param(r_add_info.p_cover_id_prev);
      
        log(tbl_cover(i).p_cover_id
           ,'REUSECHANGEDADDINSSUM K_COEF ' || r_cover_param.k_coef || ' K_COEF_PREV ' ||
            r_cover_param_prev.k_coef);
        log(tbl_cover(i).p_cover_id
           ,'REUSECHANGEDADDINSSUM S_COEF ' || r_cover_param.s_coef || ' S_COEF_PREV ' ||
            r_cover_param_prev.s_coef);
      
        IF NOT ((r_cover_param.k_coef = r_cover_param_prev.k_coef) AND
            (r_cover_param.s_coef = r_cover_param_prev.s_coef))
        THEN
        
          log(tbl_cover(i).p_cover_id
             ,'REUSECHANGEDADDINSSUM Пересчет страховой суммы от брутто премии пред. версии');
        
          l_coef := nvl(pkg_tariff.calc_tarif_mul(tbl_cover(i).p_cover_id), 0);
        
          tbl_cover(i).fee := r_add_info.fee_prev;
        
          log(tbl_cover(i).p_cover_id
             ,'REUSECHANGEDADDINSSUM По программе брутто взнос меняется на ' || r_add_info.fee_prev);
          log(tbl_cover(i).p_cover_id
             ,'REUSECHANGEDADDINSSUM Итоговый коэффициент по покрытию ' || l_coef);
        
          IF l_coef != 0
          THEN
            tbl_cover(i).ins_amount := tbl_cover(i).fee / (l_coef * tbl_cover(i).tariff);
          
            UPDATE p_cover
               SET ins_amount = tbl_cover(i).ins_amount
                  ,fee        = tbl_cover(i).fee
             WHERE p_cover_id = tbl_cover(i).p_cover_id;
          
            log(tbl_cover(i).p_cover_id
               ,'REUSECHANGEDADDINSSUM INS_AMOUNT ' || tbl_cover(i).ins_amount);
          
            l_premium := pkg_cover.calc_premium(tbl_cover(i).p_cover_id);
            UPDATE p_cover SET premium = l_premium WHERE p_cover_id = tbl_cover(i).p_cover_id;
          END IF;
        ELSE
          log(tbl_cover(i).p_cover_id
             ,'REUSECHANGEDADDINSSUM Нагружающие коэффициенты не изменились ');
        
        END IF;
      END IF;
    END LOOP;
  
  END;

  /*
     Расчет покрытий при наличии отключенных рисков и повышающих коэффициентов по программам
  */
  PROCEDURE refuseaddprogupprimaryupadd
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
  BEGIN
  
    NULL;
  
  END;

  PROCEDURE recalcalg0110
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_is_not_wop  IN NUMBER
  ) IS
    v_qty         NUMBER := 0;
    l_all_fee     NUMBER;
    l_all_add_fee NUMBER;
    l_temp_fee    NUMBER;
  
    r_cover_param calc_param;
    tbl_cover     tbl_product_line_info;
  BEGIN
  
    log(p_p_cover_id
       ,'RECALC Применение повышающего коэффициента только по основной программе ');
  
    -- Сумма брутто - взносов по основной  программе
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    IF (l_all_add_fee > l_all_fee - p_fee_amount)
       AND (l_all_fee - p_fee_amount) > 0
    THEN
      -- пропорциональное уменьшение доп программ
      log(p_p_cover_id
         ,'RECALC Пропорциональное уменьшение доп программ');
    
      proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
      proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
    
    ELSE
    
      log(p_p_cover_id
         ,'RECALC Уменьшение взноса по основной и дополнительным программам');
    
      proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
      proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
    
    END IF;
  END;

  PROCEDURE recalcalg0111
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_is_not_wop  IN NUMBER
  ) IS
    v_qty         NUMBER := 0;
    l_all_fee     NUMBER;
    l_all_add_fee NUMBER;
    l_temp_fee    NUMBER;
  
    r_cover_param calc_param;
    tbl_cover     tbl_product_line_info;
  BEGIN
  
    log(p_p_cover_id, 'Процедура RECALCALG0111 ' || p_as_asset_id);
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    IF g_step_no = 1
    THEN
      decreasealladdinssumprevcoef(p_as_asset_id, p_p_cover_id, p_fee_amount);
    END IF;
  
    inforesult(p_as_asset_id, p_p_cover_id);
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
  
    log(p_p_cover_id
       ,'RECALCALG0111 ALL_FEE ' || l_all_fee || ' ALL_ADD_FEE ' || l_all_add_fee || ' ' ||
        (l_all_fee - p_fee_amount));
  
    IF (l_all_fee - p_fee_amount) = 0
    THEN
    
      RETURN;
    
    ELSIF l_all_add_fee > (l_all_fee - p_fee_amount)
    --          AND (p_is_not_wop = 1)
    THEN
    
      log(p_p_cover_id
         ,'RECALCALG0111 Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы ' ||
          l_all_add_fee || ' > ' || (l_all_fee - p_fee_amount));
    
      /*
          Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы
      */
    
      /*      RestorePrimaryInsSum (p_as_asset_id, p_p_cover_id, p_fee_amount);
      
            LOOP
              v_qty := v_qty  + 1;
      
              RecalcWOPInsSum(p_as_asset_id, p_p_cover_id);
      
              DecreaseAllAddInsSum (p_as_asset_id, p_p_cover_id, p_fee_amount);
      
        --  Сумма брутто - взносов по всем программам
              l_all_fee := GetSumFee (p_as_asset_id);
      
        --  Сумма брутто - взносов по дополнительным программам
              l_all_add_fee := GetSumAddFee (p_as_asset_id, p_p_cover_id);
      
              IF l_all_fee != p_fee_amount THEN
      /*
          Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы
      */
      IF p_is_not_wop = 1
      THEN
        proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
        --          DecreaseAllAddInsSum (p_as_asset_id, p_p_cover_id, p_fee_amount);
      
        --        END IF;
      
      ELSE
        proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
        --          recalcwopinssum(p_as_asset_id, p_p_cover_id);
        --          proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
        --          recalcwopinssum(p_as_asset_id, p_p_cover_id);
      END IF;
    
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
    
      --        exit when v_qty > 3;
    
      --      END LOOP;
    
    ELSE
      log(p_p_cover_id
         ,'RECALCALG0111 Сумма доп программ НЕДОСТАТОЧНА, чтобы удержать стр. сумму основной программы !(' ||
          l_all_add_fee || ' > ' || (l_all_fee - p_fee_amount) || ')');
    
      primaryrecalc(p_as_asset_id, p_p_cover_id, NULL);
      decreasealladdinssum(p_as_asset_id, p_p_cover_id, p_fee_amount);
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
    
      --  Сумма брутто - взносов по всем программам
      l_all_fee := getsumfee(p_as_asset_id);
    
      --  Сумма брутто - взносов по дополнительным программам
      l_temp_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    
      IF (l_all_add_fee - l_temp_fee) > 0
      THEN
        log(p_p_cover_id
           ,'RECALCALG0111 Сумма, освободившаяся в результате уменьшения доп программ ' ||
            (l_all_add_fee - l_temp_fee));
        primaryrecalc(p_as_asset_id, p_p_cover_id, l_all_add_fee - l_temp_fee);
      END IF;
    
      addrecalc(p_as_asset_id, p_p_cover_id, NULL);
    
      IF p_is_not_wop = 1
      THEN
        proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
      ELSE
        proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
      END IF;
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
    
      --  Сумма брутто - взносов по всем программам
      l_all_fee := getsumfee(p_as_asset_id);
    
      --  Сумма брутто - взносов по дополнительным программам
      l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    
      IF p_is_not_wop = 1
      THEN
        proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
      ELSE
        proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
      END IF;
      recalcwopinssum(p_as_asset_id, p_p_cover_id);
    
      --    l_all_fee := GetSumFee (p_as_asset_id);
    
      --    Сумма брутто - взносов по дополнительным программам
      --    l_all_add_fee := GetSumAddFee (p_as_asset_id, p_p_cover_id);
    END IF;
  
  END;

  PROCEDURE recalcalg0101
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_is_not_wop  IN NUMBER
  ) IS
    v_qty         NUMBER;
    l_all_fee     NUMBER;
    l_all_add_fee NUMBER;
    l_refused_fee NUMBER;
    r_cover_param calc_param;
  
  BEGIN
  
    -- Применение повышающего коэффициента по дополнительным программам
    log(p_p_cover_id
       ,'RECALC Применение повышающего коэффициента по дополнительным программам');
    --      RefuseAddProgUpPrimaryUpAdd (p_as_asset_id, p_p_cover_id, p_fee_amount);
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    --  Сумма брутто - взносов по отключенным программам
  
    log(p_p_cover_id
       ,'RECALC Сумма превышения брутто взноса над рекомендуемым ' || (l_all_fee - p_fee_amount));
  
    reusechangedaddinssum(p_as_asset_id, p_p_cover_id, p_fee_amount);
    inforesult(p_as_asset_id, p_p_cover_id);
  
    recalcwopinssum(p_as_asset_id, p_p_cover_id);
  
    v_qty := 0;
  
    LOOP
      IF v_qty > 3
      THEN
        EXIT;
      END IF;
    
      l_all_fee := getsumfee(p_as_asset_id);
    
      --  Сумма брутто - взносов по дополнительным программам
      l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
      --  Сумма брутто - взносов по отключенным программам
    
      IF (l_all_fee - p_fee_amount > 0)
      THEN
        IF p_is_not_wop = 1
        THEN
          proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
        ELSE
          proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
          proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
        END IF;
      ELSE
        EXIT;
      END IF;
    
      v_qty := v_qty + 1;
    
    END LOOP;
  
  END;

  PROCEDURE recalcalg1110
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_is_not_wop  IN NUMBER
  ) IS
  
    v_qty         NUMBER;
    l_all_fee     NUMBER;
    l_all_add_fee NUMBER;
    l_refused_fee NUMBER;
    r_cover_param calc_param;
  
  BEGIN
  
    -- Применение повышающего коэффициента по дополнительным программам и по основной программе и есть отключенный риск
    log(p_p_cover_id
       ,'RECALCALG1110 Применение повышающего коэффициента по дополнительным программам и по основной программе и есть отключенный риск');
    --      RefuseAddProgUpPrimaryUpAdd (p_as_asset_id, p_p_cover_id, p_fee_amount);
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    --  Сумма брутто - взносов по отключенным программам
    l_refused_fee := getrefusedsumfee(p_as_asset_id);
  
    log(p_p_cover_id
       ,'RECALCALG1110 Сумма превышения брутто взноса над рекомендуемым ' ||
        (l_all_fee - p_fee_amount));
  
    IF l_refused_fee > (l_all_fee - p_fee_amount)
    THEN
      v_qty := 0;
      LOOP
        increaseinssum(p_as_asset_id, p_p_cover_id, p_fee_amount, l_refused_fee);
        recalcwopinssum(p_as_asset_id, p_p_cover_id);
        v_qty := v_qty + 1;
        EXIT WHEN v_qty > 3;
      END LOOP;
      RETURN;
    ELSE
      IF l_all_add_fee > (l_all_fee - p_fee_amount)
      THEN
      
        log(p_p_cover_id
           ,'RECALCALG1110 Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы ' ||
            l_all_add_fee || ' > ' || (l_all_fee - p_fee_amount));
        /*
            Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы
        */
        restoreprimaryinssum(p_as_asset_id, p_p_cover_id, p_fee_amount);
        v_qty := 0;
      
        LOOP
          v_qty := v_qty + 1;
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
          decreasealladdinssum(p_as_asset_id, p_p_cover_id, p_fee_amount);
          --  Сумма брутто - взносов по всем программам
          l_all_fee := getsumfee(p_as_asset_id);
          --  Сумма брутто - взносов по дополнительным программам
          l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
        
          IF l_all_fee != p_fee_amount
          THEN
            /*
                Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы
            */
            proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
          
          END IF;
        
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
        
          EXIT WHEN v_qty > 3;
        
        END LOOP;
      ELSE
        v_qty := 0;
        LOOP
          v_qty := v_qty + 1;
          log(p_p_cover_id
             ,'RECALCALG0110 Сумма доп программ НЕДОСТАНОЧНА, чтобы удержать стр. сумму основной программы !(' ||
              l_all_add_fee || ' > ' || (l_all_fee - p_fee_amount) || ')');
          proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
          EXIT WHEN v_qty > 3;
        END LOOP;
      END IF;
    
    END IF;
  
  END;

  PROCEDURE recalcalg1111
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
   ,p_is_not_wop  IN NUMBER
  ) IS
    v_qty         NUMBER;
    l_all_fee     NUMBER;
    l_all_add_fee NUMBER;
    l_refused_fee NUMBER;
    r_cover_param calc_param;
  
  BEGIN
  
    -- Применение повышающего коэффициента по дополнительным программам и по основной программе и есть отключенный риск
    log(p_p_cover_id
       ,'RECALC Применение повышающего коэффициента по дополнительным программам и по основной программе и есть отключенный риск');
    --      RefuseAddProgUpPrimaryUpAdd (p_as_asset_id, p_p_cover_id, p_fee_amount);
  
    --  Сумма брутто - взносов по всем программам
    l_all_fee := getsumfee(p_as_asset_id);
  
    --  Сумма брутто - взносов по дополнительным программам
    l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
    --  Сумма брутто - взносов по отключенным программам
    l_refused_fee := getrefusedsumfee(p_as_asset_id);
  
    log(p_p_cover_id
       ,'RECALC Сумма превышения брутто взноса над рекомендуемым ' || (l_all_fee - p_fee_amount));
  
    IF l_refused_fee > (l_all_fee - p_fee_amount)
    THEN
      v_qty := 0;
      LOOP
        increaseinssum(p_as_asset_id, p_p_cover_id, p_fee_amount, l_refused_fee);
        recalcwopinssum(p_as_asset_id, p_p_cover_id);
        v_qty := v_qty + 1;
        EXIT WHEN v_qty > 3;
      END LOOP;
      RETURN;
    ELSE
      IF (l_all_add_fee > (l_all_fee - p_fee_amount))
         AND (p_is_not_wop = 1)
      THEN
      
        log(p_p_cover_id
           ,'RECALCALG1111 Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы ' ||
            l_all_add_fee || ' > ' || (l_all_fee - p_fee_amount));
        /*
            Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы
        */
        restoreprimaryinssum(p_as_asset_id, p_p_cover_id, p_fee_amount);
        v_qty := 0;
      
        LOOP
          v_qty := v_qty + 1;
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
          decreasealladdinssum(p_as_asset_id, p_p_cover_id, p_fee_amount);
          --  Сумма брутто - взносов по всем программам
          l_all_fee := getsumfee(p_as_asset_id);
          --  Сумма брутто - взносов по дополнительным программам
          l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
        
          IF (l_all_fee != p_fee_amount)
          THEN
            /*
                Сумма доп программ достаточна, чтобы удержать стр. сумму основной программы
            */
            proportionalrecalcalladd(p_as_asset_id, p_p_cover_id, p_fee_amount);
          
          END IF;
        
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
        
          EXIT WHEN v_qty > 3;
        
        END LOOP;
      ELSE
        v_qty := 0;
        LOOP
          v_qty := v_qty + 1;
          log(p_p_cover_id
             ,'RECALCALG0111 Сумма доп программ НЕДОСТАНОЧНА, чтобы удержать стр. сумму основной программы !(' ||
              l_all_add_fee || ' > ' || (l_all_fee - p_fee_amount) || ')');
          proportionalrecalcall(p_as_asset_id, p_p_cover_id, p_fee_amount);
          EXIT WHEN v_qty > 3;
        END LOOP;
      END IF;
    
    END IF;
  
  END;

  PROCEDURE roundresult
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
    resultset tbl_product_line_info;
  
    r_cover_param calc_param;
    r_add_info    add_info;
    tbl_cover     tbl_product_line_info;
  
    RESULT             NUMBER := 0;
    r_cover_param_prev calc_param;
  
    l_temp_fee    NUMBER;
    l_temp_amount NUMBER;
    l_premium     NUMBER;
  
    l_coef NUMBER;
  
  BEGIN
    resultset := get_cover_info(p_as_asset_id);
    log(p_p_cover_id, 'ROUNDRESULT ');
  
    FOR i IN 1 .. resultset.count
    LOOP
      IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
          AND NOT resultset(i).sh_brief = 'DELETED'
      THEN
      
        r_add_info         := get_add_info(resultset(i).p_cover_id);
        r_cover_param      := get_calc_param(r_add_info.p_cover_id_curr);
        r_cover_param_prev := get_calc_param(r_add_info.p_cover_id_prev);
      
        resultset(i).fee := pkg_cover.round_fee(resultset(i).p_cover_id, resultset(i).fee);
      
        log(resultset(i).p_cover_id, 'ROUNDRESULT FEE ' || resultset(i).fee || ' COEF ' || l_coef);
      
        l_coef := nvl(pkg_tariff.calc_tarif_mul(resultset(i).p_cover_id), 0);
      
        IF l_coef != 0
        THEN
          resultset(i).ins_amount := resultset(i).fee / (l_coef * resultset(i).tariff);
          log(resultset(i).p_cover_id, 'ROUNDRESULT INS_AMOUNT ' || resultset(i).ins_amount);
          resultset(i).ins_amount := pkg_cover.round_ins_amount(resultset(i).p_cover_id
                                                               ,resultset(i).ins_amount);
          log(resultset(i).p_cover_id, 'ROUNDRESULT INS_AMOUNT ' || resultset(i).ins_amount);
        END IF;
      
        IF ((r_cover_param.k_coef = r_cover_param_prev.k_coef) AND
           (r_cover_param.s_coef = r_cover_param_prev.s_coef))
        THEN
          IF r_cover_param_prev.fee = resultset(i).fee
          THEN
            resultset(i).ins_amount := r_cover_param_prev.ins_amount;
          END IF;
        
        END IF;
      
        l_premium := resultset(i).fee * r_cover_param.number_of_payment;
      
        UPDATE p_cover
           SET fee        = resultset(i).fee
              ,ins_amount = resultset(i).ins_amount
              ,premium    = l_premium
         WHERE p_cover_id = resultset(i).p_cover_id;
      
      END IF;
    
    END LOOP;
  END;

  /*
    Процедура контроля покрытий. Выполняет настроенные на программе функции контроля покрытий
  */
  PROCEDURE cover_control(p_as_asset_id IN NUMBER) IS
  
  BEGIN
    FOR cur IN (SELECT pc.p_cover_id
                      ,sh.brief sh_brief
                  FROM ven_status_hist sh
                      ,p_cover         pc
                 WHERE 1 = 1
                   AND pc.as_asset_id = p_as_asset_id
                   AND sh.status_hist_id = pc.status_hist_id
                   AND sh.brief != 'DELETED')
    LOOP
    
      pkg_cover_control.cover_control(cur.p_cover_id);
    
    END LOOP;
  
  END;

  FUNCTION analysecover(resultset IN tbl_product_line_info) RETURN VARCHAR2 IS
    RESULT VARCHAR2(5);
  
    v_algorithm_1 NUMBER(1) := 0;
    v_algorithm_2 NUMBER(1) := 0;
    v_algorithm_3 NUMBER(1) := 0;
    v_algorithm_4 NUMBER(1) := 0;
    v_algorithm_5 NUMBER(1) := 0;
  
    r_cover_param      calc_param;
    r_cover_param_prev calc_param;
    r_add_info         add_info;
  
  BEGIN
  
    FOR i IN 1 .. resultset.count
    LOOP
    
      r_add_info         := get_add_info(resultset(i).p_cover_id);
      r_cover_param      := get_calc_param(r_add_info.p_cover_id_curr);
      r_cover_param_prev := get_calc_param(r_add_info.p_cover_id_prev);
    
      IF resultset(i)
       .sh_brief = 'DELETED'
          AND resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
      THEN
      
        log(resultset(i).p_cover_id
           ,'ANALYSECOVER Найден отключенный риск (' || resultset(i).p_cover_id || ')');
        v_algorithm_1 := 1;
      
      END IF;
    
      IF NOT ((r_cover_param.k_coef = r_cover_param_prev.k_coef) AND
          (r_cover_param.s_coef = r_cover_param_prev.s_coef))
      THEN
      
        log(resultset(i).p_cover_id
           ,'ANALYSECOVER Найден тариф, отличающийся от пред. версии (' || resultset(i).plt_brief || ')' ||
            r_add_info.tariff_curr || ' ' || r_add_info.tariff_prev);
      
        v_algorithm_2 := 1;
      
        IF (resultset(i).plt_brief = 'RECOMMENDED')
           AND (resultset(i).sh_brief != 'DELETED')
        THEN
          v_algorithm_3 := 1;
        ELSIF (resultset(i).plt_brief IN ('OPTIONAL', 'MANDATORY'))
              AND (resultset(i).sh_brief != 'DELETED')
        THEN
          v_algorithm_4 := 1;
          IF resultset(i).lob_brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'WOP', 'PWOP')
          THEN
            v_algorithm_5 := 1;
          END IF;
        END IF;
      
      ELSE
      
        log(resultset(i).p_cover_id, 'ANALYSECOVER Условия не изменились ');
      
      END IF;
    
    END LOOP;
  
    RESULT := v_algorithm_1 || v_algorithm_2 || v_algorithm_3 || v_algorithm_4 || v_algorithm_5;
    RETURN RESULT;
  
  END;

  PROCEDURE recalc
  (
    p_as_asset_id IN NUMBER
   ,p_p_cover_id  IN NUMBER
   ,p_fee_amount  IN NUMBER
  ) IS
  
    v_type VARCHAR2(50);
    --
    l_primary_ins_amount NUMBER;
    l_primary_fee        NUMBER;
    l_primary_premium    NUMBER;
    l_primary_tariff     NUMBER;
    l_add_ins_amount     NUMBER;
    l_all_add_fee        NUMBER;
    l_add_fee            NUMBER;
    l_disabled_fee       NUMBER;
    l_add_premium        NUMBER;
    l_add_tariff         NUMBER;
    l_all_fee            NUMBER;
    l_temp_fee           NUMBER;
    l_coef               NUMBER;
    l_temp_amount        NUMBER;
    l_premium            NUMBER;
    l_is_not_wop         NUMBER;
  
    r_add_info add_info;
    l_log      VARCHAR2(16000);
    v_qty      NUMBER(2) DEFAULT 0;
  
    l_alg VARCHAR2(5);
  
    r_cover_param            calc_param;
    r_cover_param_prev       calc_param;
    l_deleted_cover_qty      NUMBER(12) DEFAULT 0;
    l_deleted_cover_qty_ctrl NUMBER(12) DEFAULT 0;
    tbl_cover                tbl_product_line_info;
  BEGIN
  
    log(p_p_cover_id, 'RECALC P_AS_ASSET_ID ' || p_as_asset_id);
  
    tbl_cover := get_cover_info(p_as_asset_id);
  
    l_alg := analysecover(tbl_cover);
  
    restoreprevversion(p_as_asset_id, p_p_cover_id, p_fee_amount);
  
    g_step_no := 1;
  
    LOOP
      l_is_not_wop := to_number(substr(l_alg, 5, 1));
      inforesult(p_as_asset_id, p_p_cover_id);
      --  Сумма брутто - взносов по всем программам
      l_all_fee := getsumfee(p_as_asset_id);
    
      --  Сумма брутто - взносов по дополнительным программам
      l_all_add_fee := getsumaddfee(p_as_asset_id, p_p_cover_id);
      log(p_p_cover_id, 'RECALC l_all_fee ' || l_all_fee || ' l_all_add_fee ' || l_all_add_fee);
    
      IF l_deleted_cover_qty_ctrl > l_deleted_cover_qty
      THEN
        v_qty := v_qty - 1;
      END IF;
    
      l_deleted_cover_qty := l_deleted_cover_qty_ctrl;
    
      IF v_qty = 2
         AND l_alg LIKE '0111%'
      THEN
        EXIT;
      ELSIF v_qty > 1
      THEN
        EXIT;
      END IF;
    
      v_qty := v_qty + 1;
    
      IF l_alg LIKE '0110%'
      THEN
        -- Применение повышающего коэффициента только по основной программе
      
        recalcalg0110(p_as_asset_id, p_p_cover_id, p_fee_amount, l_is_not_wop);
      
      ELSIF l_alg LIKE '0101%'
      THEN
        -- Применение повышающего коэффициента только по дополнительным программам
      
        log(p_p_cover_id
           ,'RECALC Применение повышающего коэффициента только по дополнительным программам');
        recalcalg0101(p_as_asset_id, p_p_cover_id, p_fee_amount, l_is_not_wop);
      
      ELSIF l_alg LIKE '0111%'
      THEN
        r_add_info := get_add_info(p_p_cover_id);
        -- Применение повышающего коэффициента по дополнительным программам и по основной программе
        log(p_p_cover_id
           ,'RECALC Применение повышающего коэффициента по дополнительным программам и по основной программе ');
        recalcalg0111(p_as_asset_id, p_p_cover_id, p_fee_amount, l_is_not_wop);
      
      ELSIF l_alg LIKE '1111%'
      THEN
      
        r_add_info := get_add_info(p_p_cover_id);
        -- Применение повышающего коэффициента по дополнительным программам и по основной программе
        log(p_p_cover_id
           ,'RECALC Применение повышающего коэффициента по дополнительным программам и по основной программе ');
        IF r_add_info.ins_amount_curr = r_add_info.ins_amount_prev
        THEN
        
          recalcalg1111(p_as_asset_id, p_p_cover_id, p_fee_amount, l_is_not_wop);
        
        ELSE
        
          restoreprevversion(p_as_asset_id, p_p_cover_id, p_fee_amount);
          recalcwopinssum(p_as_asset_id, p_p_cover_id);
          recalcalg1111(p_as_asset_id, p_p_cover_id, p_fee_amount, l_is_not_wop);
        
        END IF;
      
      ELSIF l_alg LIKE '1110%'
      THEN
        -- Есть отключенные риски Применение повышающего коэффициента по основной программе
      
        r_add_info := get_add_info(p_p_cover_id);
        -- Применение повышающего коэффициента по дополнительным программам и по основной программе
        log(p_p_cover_id
           ,'RECALC Есть отключенные риски. Применение повышающего коэффициента по основной программе');
        IF r_add_info.ins_amount_curr = r_add_info.ins_amount_prev
        THEN
        
          recalcalg1110(p_as_asset_id, p_p_cover_id, p_fee_amount, l_is_not_wop);
        
        END IF;
      
      END IF;
    
      cover_control(p_as_asset_id);
      --
      tbl_cover := get_cover_info(p_as_asset_id);
    
      l_deleted_cover_qty_ctrl := 0;
    
      l_alg := analysecover(tbl_cover);
    
      g_step_no := g_step_no + 1;
    
      inforesult(p_as_asset_id, p_p_cover_id);
    
    END LOOP;
  
    roundresult(p_as_asset_id, p_p_cover_id, p_fee_amount);
    --
    finalresult(p_as_asset_id, p_p_cover_id, p_fee_amount);
  
  END;

  FUNCTION getrecommendfee(p_as_asset_id IN NUMBER) RETURN NUMBER IS
    RESULT           NUMBER DEFAULT 0;
    l_prev_policy_id NUMBER;
    resultset        tbl_product_line_info;
  
    r_add_info add_info;
  
  BEGIN
    resultset := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. resultset.count
    LOOP
    
      r_add_info := get_add_info(resultset(i).p_cover_id);
      RESULT     := RESULT + r_add_info.fee_prev;
    
    END LOOP;
  
    RETURN RESULT;
  
  END;

  FUNCTION recalc_property(p_as_asset_id IN NUMBER) RETURN NUMBER IS
  
    r_add_info add_info;
    tbl_cover  tbl_product_line_info;
  
    RESULT             NUMBER := 0;
    r_cover_param      calc_param;
    r_cover_param_prev calc_param;
  
  BEGIN
  
    tbl_cover := get_cover_info(p_as_asset_id);
  
    FOR i IN 1 .. tbl_cover.count
    LOOP
    
      r_add_info         := get_add_info(tbl_cover(i).p_cover_id);
      r_cover_param      := get_calc_param(r_add_info.p_cover_id_curr);
      r_cover_param_prev := get_calc_param(r_add_info.p_cover_id_prev);
      log(tbl_cover(i).p_cover_id, 'RECALC_PROPERTY P_COVER_ID_PREV ' || r_add_info.p_cover_id_prev);
      log(tbl_cover(i).p_cover_id, 'RECALC_PROPERTY P_COVER_ID_CURR ' || r_add_info.p_cover_id_curr);
    
      log(tbl_cover(i).p_cover_id
         ,'RECALC_PROPERTY R_COVER_PARAM.K_COEF ' || r_cover_param.k_coef ||
          ' R_COVER_PARAM_PREV.K_COEF ' || r_cover_param_prev.k_coef);
      log(tbl_cover(i).p_cover_id
         ,'RECALC_PROPERTY R_COVER_PARAM.S_COEF ' || r_cover_param.s_coef ||
          ' R_COVER_PARAM_PREV.S_COEF ' || r_cover_param_prev.s_coef);
    
      IF NOT ((r_cover_param.k_coef = r_cover_param_prev.k_coef) AND
          (r_cover_param.s_coef = r_cover_param_prev.s_coef))
      THEN
        log(tbl_cover(i).p_cover_id, 'RECALC_PROPERTY COEF FOUND');
        RETURN 1;
      ELSE
        log(tbl_cover(i).p_cover_id, 'RECALC_PROPERTY COEF NOT FOUND');
      END IF;
    
    END LOOP;
  
    RETURN RESULT;
  
  END;

END;
/
