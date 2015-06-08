CREATE OR REPLACE PACKAGE pkg_financy_weekend IS
  FUNCTION end_weekend(p_p_policy_id IN NUMBER) RETURN NUMBER;
  FUNCTION chi_weekend(p_p_policy_id IN NUMBER) RETURN NUMBER;
  FUNCTION pepr_weekend(p_p_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION end_restore_weekend
  (
    p_p_policy_id IN NUMBER
   ,p_source      IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION chi_restore_weekend
  (
    p_p_policy_id IN NUMBER
   ,p_source      IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION pepr_restore_weekend
  (
    p_p_policy_id IN NUMBER
   ,p_source      IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION calcpremiumacc(p_p_cover_id IN NUMBER) RETURN NUMBER;
  /*Возвращает 1, если покрытие - Инвест-Резерв
    Возвращает 0, если покрытие не Инвест-Резерв
  */
  FUNCTION is_invest_reserve(p_p_cover_id NUMBER) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_financy_weekend IS

  p_debug BOOLEAN DEFAULT TRUE;

  CURSOR c_asset(p_p_policy_id IN NUMBER) IS
    SELECT as_asset_id FROM as_asset WHERE p_policy_id = p_p_policy_id;
  --
  CURSOR c_cover(p_as_asset_id NUMBER) IS
  
    SELECT *
      FROM v_asset_cover_life
     WHERE as_asset_id = p_as_asset_id
       AND sh_brief != 'DELETED'
     ORDER BY pl_sort_order;

  --
  l_cover_id NUMBER;
  -- Тип для получения данных из курсора
  TYPE t_cover IS TABLE OF v_asset_cover_life%ROWTYPE INDEX BY BINARY_INTEGER;

  --
  resultset      t_cover;
  resultset_prev t_cover;
  --
  g_insured_age      NUMBER DEFAULT 0;
  g_premium          NUMBER DEFAULT 0;
  g_ins_amount       NUMBER;
  g_ins_amount_prev  NUMBER;
  g_ins_amount_curr  NUMBER;
  g_coef             NUMBER;
  l_fee              NUMBER DEFAULT 0;
  g_primary_cover_id NUMBER;
  g_ins_coef         NUMBER;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF p_debug
    THEN
      INSERT INTO p_cover_debug
        (p_cover_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_FINANCY_WEEKEND', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE create_schedule
  (
    p_policy_header_id IN NUMBER
   ,p_p_policy_id      IN NUMBER
  ) IS
    CURSOR c_payment_schedule IS
      SELECT document_id
            ,plan_date
            ,ps.doc_status_ref_name
            ,payment_term_id
        FROM v_policy_payment_schedule ps
            ,p_policy                  pp
       WHERE 1 = 1
         AND pp.policy_id = p_p_policy_id
         AND ps.pol_header_id = p_policy_header_id
         AND ps.plan_date = pp.start_date
         AND ps.doc_status_ref_name NOT IN ('Оплачен', 'Аннулирован');
    --
    CURSOR c_schedule IS
      SELECT document_id
            ,plan_date
            ,ps.doc_status_ref_name
            ,payment_term_id
        FROM v_policy_payment_schedule ps
            ,p_policy                  pp
       WHERE 1 = 1
         AND pp.policy_id = p_p_policy_id
         AND ps.pol_header_id = p_policy_header_id
         AND rownum = 1;
    --;
    l_id              NUMBER;
    l_payment_term_id NUMBER;
  
  BEGIN
    log(p_policy_header_id, 'CREATE_SCHEDULE');
  
    FOR cur IN c_schedule
    LOOP
      l_payment_term_id := cur.payment_term_id;
    END LOOP;
    --
    FOR cur IN c_payment_schedule
    LOOP
      l_id := 1;
    END LOOP;
    IF l_id IS NULL
    THEN
    
      log(p_policy_header_id, 'CREATE_SCHEDULE Элемент графика не обнаружен');
      pkg_payment.delete_unpayed(p_policy_header_id);
      log(p_policy_header_id
         ,'CREATE_SCHEDULE Неоплаченные элементы удалены');
      pkg_payment.policy_make_planning(pkg_policy.get_last_version(p_policy_header_id)
                                      ,l_payment_term_id
                                      ,'PAYMENT');
      log(p_policy_header_id
         ,'CREATE_SCHEDULE Переформирован график оплаты');
    
      FOR cur IN c_payment_schedule
      LOOP
        IF cur.doc_status_ref_name != 'К оплате'
        THEN
          doc.set_doc_status(cur.document_id, 'TO_PAY', SYSDATE, 'AUTO', NULL);
          log(p_policy_header_id
             ,'CREATE_SCHEDULE Элемент графика переведен к оплате');
        END IF;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      log(p_policy_header_id, 'CREATE_SCHEDULE Ошибка ' || SQLERRM);
    
  END;

  PROCEDURE set_decline(p_as_asset_id IN NUMBER) IS
    l_decline_reason_id NUMBER;
    l_decline_party_id  NUMBER;
    l_sh_brief          VARCHAR2(200);
  BEGIN
    SELECT t_decline_reason_id
          ,t_decline_party_id
      INTO l_decline_reason_id
          ,l_decline_party_id
      FROM t_decline_reason
     WHERE brief = 'Услуга Финансовые каникулы';
  
    FOR j IN 1 .. resultset.count
    LOOP
      SELECT sh_brief
        INTO l_sh_brief
        FROM v_asset_cover_life
       WHERE p_cover_id = resultset(j).p_cover_id;
      IF resultset(j).sh_brief != 'DELETED'
          AND l_sh_brief = 'DELETED'
      THEN
        log(resultset(j).p_cover_id
           ,'Финансовые каникулы. Устанавливаем причину прекращения ');
        UPDATE p_cover
           SET decline_reason_id = l_decline_reason_id
              ,decline_party_id  = l_decline_party_id
         WHERE p_cover_id = resultset(j).p_cover_id;
      END IF;
    END LOOP;
  
  END;

  PROCEDURE set_return_sum IS
    l_sh_brief VARCHAR2(200);
  BEGIN
    FOR j IN 1 .. resultset.count
    LOOP
      SELECT sh_brief
        INTO l_sh_brief
        FROM v_asset_cover_life
       WHERE p_cover_id = resultset(j).p_cover_id;
      IF resultset(j).sh_brief != 'DELETED'
          AND l_sh_brief = 'DELETED'
      THEN
        IF resultset(j).lob_brief IN ('INVEST2', 'I2', 'PEPR_INVEST_RESERVE', 'INVEST')
        THEN
          log(resultset(j).p_cover_id
             ,'SET_RETURN_SUM ' || ' Финансовые каникулы. ' || resultset(j).lob_brief ||
              ' Сумма возврата не обнуляется');
        ELSE
          log(resultset(j).p_cover_id
             ,'Финансовые каникулы. Сумма возврата ' || resultset(j).lob_brief || ' установлена 0');
          UPDATE p_cover SET return_summ = 0 WHERE p_cover_id = resultset(j).p_cover_id;
        END IF;
      END IF;
    END LOOP;
  END;

  PROCEDURE copy_cover_info
  (
    p_index                    IN NUMBER
   ,p_p_cover_id               IN NUMBER
   ,p_is_handchange_start_date IN NUMBER
  ) IS
  BEGIN
  
    log(p_p_cover_id
       ,'COPY_COVER_INFO start_date ' || to_char(resultset(p_index).start_date, 'dd.mm.yyyy') ||
        ' end_date ' || to_char(resultset(p_index).end_date, 'dd.mm.yyyy'));
  
    UPDATE ven_p_cover
       SET start_date               = resultset(p_index).start_date
          ,period_id                = resultset(p_index).period_id
          ,end_date                 = resultset(p_index).end_date
          ,insured_age              = g_insured_age
          ,is_handchange_s_coef_nm  = decode(resultset(p_index).s_coef_nm, 0, 0, NULL, 0, 1)
          ,is_handchange_k_coef_nm  = decode(resultset(p_index).k_coef_nm, 0, 0, NULL, 0, 1)
          ,k_coef_nm                = resultset(p_index).k_coef_nm
          ,s_coef_nm                = resultset(p_index).s_coef_nm
          ,k_coef_m                 = resultset(p_index).k_coef_m
          ,s_coef_m                 = resultset(p_index).s_coef_m
          ,s_coef                   = nvl(greatest(nvl(resultset(p_index).s_coef_m
                                                      ,resultset(p_index).s_coef_nm)
                                                  ,nvl(resultset(p_index).s_coef_nm
                                                      ,resultset(p_index).s_coef_m))
                                         ,0) / 1000
          ,k_coef                   = nvl(greatest(nvl(resultset(p_index).k_coef_m
                                                      ,resultset(p_index).k_coef_nm)
                                                  ,nvl(resultset(p_index).k_coef_nm
                                                      ,resultset(p_index).k_coef_m))
                                         ,0) / 100
          ,is_handchange_start_date = p_is_handchange_start_date
     WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id, 'COPY_COVER_INFO EXIT');
  
  END;

  PROCEDURE restore_cover_info
  (
    p_p_cover_id IN NUMBER
   ,p_resultset  IN v_asset_cover_life%ROWTYPE
  ) IS
    l_insured_age        NUMBER;
    l_as_asset_id        NUMBER;
    l_p_asset_header_id  NUMBER;
    l_assured_contact_id NUMBER;
    l_start_date         DATE;
    l_date_of_birth      DATE;
    l_ins_amount         NUMBER;
    l_normrate           NUMBER DEFAULT 0;
    l_tariff             NUMBER DEFAULT 0;
    l_tariff_netto       NUMBER DEFAULT 0;
    l_loading            NUMBER DEFAULT 0;
    l_number_of_payment  NUMBER DEFAULT 0;
    l_fee                NUMBER;
    l_premium            NUMBER;
    l_coef               NUMBER;
    l_pl_brief           VARCHAR2(100);
    l_lob_brief          VARCHAR2(100);
  
    PROCEDURE restorefield IS
    BEGIN
      log(p_p_cover_id
         ,'RESTOREFIELD resultset.period_id ' || p_resultset.period_id || ' end_date ' ||
          p_resultset.end_date);
    
      log(p_p_cover_id
         ,'RESTOREFIELD is_handchange_s_coef_nm ' || p_resultset.is_handchange_s_coef_nm);
      log(p_p_cover_id
         ,'RESTOREFIELD is_handchange_k_coef_nm ' || p_resultset.is_handchange_k_coef_nm);
      log(p_p_cover_id, 'RESTOREFIELD k_coef_nm ' || p_resultset.k_coef_nm);
      log(p_p_cover_id, 'RESTOREFIELD s_coef_nm ' || p_resultset.s_coef_nm);
      log(p_p_cover_id, 'RESTOREFIELD k_coef_m ' || p_resultset.k_coef_m);
      log(p_p_cover_id, 'RESTOREFIELD s_coef_m ' || p_resultset.s_coef_m);
      log(p_p_cover_id, 'RESTOREFIELD k_coef ' || p_resultset.k_coef);
      log(p_p_cover_id, 'RESTOREFIELD s_coef ' || p_resultset.s_coef);
    
      UPDATE p_cover
         SET is_handchange_s_coef_nm = p_resultset.is_handchange_s_coef_nm
            ,end_date                = p_resultset.end_date
            ,is_handchange_k_coef_nm = p_resultset.is_handchange_k_coef_nm
            ,k_coef_nm               = p_resultset.k_coef_nm
            ,s_coef_nm               = p_resultset.s_coef_nm
            ,k_coef_m                = p_resultset.k_coef_m
            ,s_coef_m                = p_resultset.s_coef_m
            ,s_coef                  = p_resultset.s_coef
            ,k_coef                  = p_resultset.k_coef
            ,period_id               = p_resultset.period_id
       WHERE p_cover_id = p_p_cover_id;
      log(p_p_cover_id, 'RESTOREFIELD EXIT');
    END;
  
    PROCEDURE calc_primary_program IS
    BEGIN
    
      log(p_p_cover_id, 'RESTORE_COVER_INFO CALC_PRIMARY_PROGRAM ');
      SELECT as_asset_id
            ,p_asset_header_id
        INTO l_as_asset_id
            ,l_p_asset_header_id
        FROM v_asset_cover_life pc
       WHERE p_cover_id = p_p_cover_id;
    
      l_fee := p_resultset.fee;
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO CALC_PRIMARY_PROGRAM ' || p_resultset.lob_brief || ' l_fee ' || l_fee);
      SELECT assured_contact_id
        INTO l_assured_contact_id
        FROM as_assured
       WHERE as_assured_id = l_as_asset_id;
    
      SELECT date_of_birth
        INTO l_date_of_birth
        FROM cn_person
       WHERE contact_id = l_assured_contact_id;
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO start_date ' || p_resultset.start_date || ' l_date_of_birth ' ||
          l_date_of_birth);
      l_insured_age := FLOOR(trunc(MONTHS_BETWEEN(p_resultset.start_date, l_date_of_birth) / 12));
    
      UPDATE p_cover
         SET insured_age     = l_insured_age
            ,source_cover_id = p_resultset.p_cover_id
       WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id, 'RESTORE_COVER_INFO insured_age ' || l_insured_age || ' fee ' || l_fee);
    
      restorefield;
    
      log(l_cover_id
         ,'RESTORE_COVER_INFO Calc_Primary_Program Подключение коэффициентов.');
      l_coef := pkg_tariff.calc_cover_coef(p_p_cover_id);
    
      l_normrate := pkg_productlifeproperty.calc_normrate_value(p_p_cover_id);
    
      l_loading := pkg_cover.calc_loading(p_p_cover_id);
    
      -- Сохраняем на покрытии информацию по нагрузке и норме доходности
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO Calc_Primary_Program l_normrate ' || l_normrate || ' l_loading ' ||
          l_loading || ' l_coef ' || l_coef);
      UPDATE p_cover
         SET rvb_value      = l_loading
            ,normrate_value = l_normrate
       WHERE p_cover_id = p_p_cover_id;
      --
      l_tariff_netto := pkg_cover.calc_tariff_netto(p_p_cover_id);
      UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = p_p_cover_id;
    
      l_tariff := pkg_cover.calc_tariff(p_p_cover_id);
      UPDATE p_cover SET tariff = l_tariff WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO Calc_Primary_Program l_tariff ' || l_tariff || ' l_tariff_netto ' ||
          l_tariff_netto);
    
      l_ins_amount := (l_fee / l_coef) / l_tariff;
      l_ins_amount := pkg_cover.round_ins_amount(p_p_cover_id, l_ins_amount);
    
      log(p_p_cover_id, 'RESTORE_COVER_INFO l_ins_amount ' || l_ins_amount);
      UPDATE p_cover SET ins_amount = l_ins_amount WHERE p_cover_id = p_p_cover_id;
      --
      l_fee := pkg_cover.calc_fee(p_p_cover_id);
      UPDATE ven_p_cover SET fee = l_fee WHERE p_cover_id = p_p_cover_id;
      --
      l_premium := pkg_cover.calc_premium(l_cover_id);
      UPDATE ven_p_cover SET premium = l_premium WHERE p_cover_id = p_p_cover_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        log(p_p_cover_id, 'RESTORE_COVER_INFO Calc_Primary_Program ERROR ' || SQLERRM);
        RAISE;
      
    END;
  
    PROCEDURE calc_secondary_program IS
      l_source_ins_amount NUMBER;
    BEGIN
      SELECT as_asset_id
            ,p_asset_header_id
        INTO l_as_asset_id
            ,l_p_asset_header_id
        FROM v_asset_cover_life pc
       WHERE p_cover_id = p_p_cover_id;
      log(p_p_cover_id, 'RESTORE_COVER_INFO Calc_Secondary_Program ');
    
      restorefield;
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO Calc_Secondary_Program Стр. сумма отключенного покрытия ' ||
          p_resultset.ins_amount || ' Коэффициент ' || g_ins_coef);
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO Calc_Secondary_Program g_ins_amount_prev ' || g_ins_amount_prev ||
          ' p_resultset.ins_amount ' || p_resultset.ins_amount);
    
      --    Расчет страховой суммы по дополнительной программе, с учетом коэффициента, который отражает изменение стр. суммы основной программы
      IF g_ins_amount_prev = p_resultset.ins_amount
      THEN
        l_ins_amount := g_ins_amount_curr;
        -- Cумма по основной программе после FH > суммы по основной программе из версии до FH, тогда
        -- страховая сумма по доп. программе после FH = страховая сумма по доп. программе до FH
      ELSIF g_ins_amount_curr > g_ins_amount_prev
      THEN
        l_ins_amount := p_resultset.ins_amount;
      ELSIF g_ins_amount_prev < p_resultset.ins_amount
      THEN
        l_ins_amount := g_ins_amount_curr;
        -- сумма по основной программе после FH < суммы по основной программе из версии до FH, тогда
        -- страховая сумма по доп. программе после FH= S(доп)/ S(осн)*S’
      ELSE
        l_ins_amount := pkg_cover.round_ins_amount(p_p_cover_id, g_ins_coef * p_resultset.ins_amount);
      END IF;
    
      UPDATE p_cover SET ins_amount = l_ins_amount WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO Calc_Secondary_Program  Подключение коэффициентов.');
      l_coef := pkg_tariff.calc_cover_coef(p_p_cover_id);
    
      --    Расчет текущего страхового возраста по покрытию
      SELECT assured_contact_id
        INTO l_assured_contact_id
        FROM as_assured
       WHERE as_assured_id = l_as_asset_id;
    
      SELECT date_of_birth
        INTO l_date_of_birth
        FROM cn_person
       WHERE contact_id = l_assured_contact_id;
    
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO start_date ' || p_resultset.start_date || ' l_date_of_birth ' ||
          l_date_of_birth);
      l_insured_age := FLOOR(trunc(MONTHS_BETWEEN(p_resultset.start_date, l_date_of_birth) / 12));
    
      UPDATE p_cover
         SET insured_age     = l_insured_age
            ,source_cover_id = p_resultset.p_cover_id
       WHERE p_cover_id = p_p_cover_id;
    
      l_normrate := pkg_productlifeproperty.calc_normrate_value(p_p_cover_id);
    
      l_loading := pkg_cover.calc_loading(p_p_cover_id);
    
      -- Сохраняем на покрытии информацию по нагрузке и норме доходности
      log(p_p_cover_id
         ,'RESTORE_COVER_INFO Calc_Secondary_Program l_normrate ' || l_normrate || ' l_loading ' ||
          l_loading);
      UPDATE p_cover
         SET rvb_value      = l_loading
            ,normrate_value = l_normrate
       WHERE p_cover_id = p_p_cover_id;
      --
      l_tariff_netto := pkg_cover.calc_tariff_netto(p_p_cover_id);
      log(p_p_cover_id, 'RESTORE_COVER_INFO Calc_Secondary_Program l_tariff_netto ' || l_tariff_netto);
      UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = p_p_cover_id;
    
      l_tariff := pkg_cover.calc_tariff(p_p_cover_id);
      log(p_p_cover_id, 'RESTORE_COVER_INFO Calc_Secondary_Program l_tariff ' || l_tariff);
      UPDATE p_cover SET tariff = l_tariff WHERE p_cover_id = p_p_cover_id;
    
      --
      l_fee := pkg_cover.calc_fee(p_p_cover_id);
      UPDATE ven_p_cover SET fee = l_fee WHERE p_cover_id = p_p_cover_id;
      --
      l_premium := pkg_cover.calc_premium(l_cover_id);
      UPDATE ven_p_cover SET premium = l_premium WHERE p_cover_id = p_p_cover_id;
    END;
  
    PROCEDURE calc_ins_coef IS
    BEGIN
      log(p_p_cover_id, 'RESTORE_COVER_INFO CALC_INS_COEF');
      g_ins_coef := l_ins_amount / p_resultset.ins_amount;
      log(p_p_cover_id, 'RESTORE_COVER_INFO CALC_INS_COEF g_ins_coef ' || g_ins_coef);
    END;
  
  BEGIN
    log(p_p_cover_id, 'RESTORE_COVER_INFO ');
  
    SELECT pl_brief
          ,lob_brief
      INTO l_pl_brief
          ,l_lob_brief
      FROM v_asset_cover_life pc
     WHERE p_cover_id = p_p_cover_id;
    log(p_p_cover_id, 'RESTORE_COVER_INFO ' || l_lob_brief || ' pl_brief ' || l_pl_brief);
  
    IF l_pl_brief IN ('Смешанное страхование жизни.Основная'
                     ,'Дожитие с возвратом взносов в случае смерти.Основная')
    THEN
      g_primary_cover_id := p_p_cover_id;
      g_ins_amount_prev  := p_resultset.ins_amount;
      calc_primary_program;
      calc_ins_coef;
      g_ins_amount_curr := l_ins_amount;
    ELSIF l_lob_brief IN ('INVEST', 'INVEST2')
    THEN
      calc_primary_program;
    
    ELSIF l_lob_brief IN ('DD')
    THEN
      calc_primary_program;
    ELSE
      calc_secondary_program;
    END IF;
    --
  
  END;

  PROCEDURE calc_cover
  (
    p_index      IN NUMBER
   ,p_p_cover_id IN NUMBER
  ) IS
    l_insured_age        NUMBER;
    l_as_asset_id        NUMBER;
    l_assured_contact_id NUMBER;
    l_start_date         DATE;
    l_date_of_birth      DATE;
    l_ins_amount         NUMBER;
    l_normrate           NUMBER DEFAULT 0;
    l_tariff             NUMBER DEFAULT 0;
    l_tariff_netto       NUMBER DEFAULT 0;
    l_loading            NUMBER DEFAULT 0;
    l_number_of_payment  NUMBER DEFAULT 0;
    l_fee                NUMBER;
    l_premium            NUMBER;
    l_coef               NUMBER;
  BEGIN
    log(l_cover_id, 'CALC_COVER');
  
    l_normrate := pkg_productlifeproperty.calc_normrate_value(p_p_cover_id);
    l_loading  := pkg_cover.calc_loading(p_p_cover_id);
    -- Сохраняем на покрытии информацию по нагрузке и норме доходности
    log(p_p_cover_id, 'CALC_COVER l_normrate ' || l_normrate || ' l_loading ' || l_loading);
    UPDATE p_cover
       SET rvb_value      = l_loading
          ,normrate_value = l_normrate
     WHERE p_cover_id = p_p_cover_id;
    --
    l_tariff       := pkg_cover.calc_tariff(p_p_cover_id);
    l_tariff_netto := pkg_cover.calc_tariff_netto(p_p_cover_id);
    log(p_p_cover_id, 'CALC_COVER l_tariff ' || l_tariff || ' l_tariff_netto ' || l_tariff_netto);
  
    UPDATE ven_p_cover
       SET tariff       = l_tariff
          ,tariff_netto = l_tariff_netto
     WHERE p_cover_id = p_p_cover_id;
  
    l_fee := pkg_cover.calc_fee(p_p_cover_id);
    UPDATE ven_p_cover SET fee = l_fee WHERE p_cover_id = p_p_cover_id;
    --
    l_premium := pkg_cover.calc_premium(l_cover_id);
    UPDATE ven_p_cover SET premium = l_premium WHERE p_cover_id = p_p_cover_id;
  
    log(p_p_cover_id, 'CALC_COVER l_fee ' || l_fee || ' g_premium ' || g_premium);
  
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_cover_id, 'CALC_COVER ERROR' || SQLERRM);
    
  END;

  /*
    Функция возвращает сумму премий по услуге Финансовые каникулы"
  */

  FUNCTION get_premium(p_as_asset_id IN NUMBER) RETURN NUMBER IS
    RESULT        NUMBER DEFAULT 0;
    l_as_asset_id NUMBER;
    l_p_cover_id  NUMBER;
    l_brief       VARCHAR2(100);
  BEGIN
  
    log(p_as_asset_id, 'GET_PREMIUM');
  
    SELECT p_cover_id
          ,lob_brief
      INTO l_p_cover_id
          ,l_brief
      FROM v_asset_cover_life
     WHERE as_asset_id = p_as_asset_id
       AND lob_brief IN ('END', 'PEPR')
       AND rownum < 2;
    log(p_as_asset_id, 'GET_PREMIUM ' || l_brief || ' l_p_cover_id ' || l_p_cover_id);
    --
    SELECT p_cover_id_prev
      INTO l_p_cover_id
      FROM v_p_cover_life_add
     WHERE p_cover_id_curr = l_p_cover_id;
    log(p_as_asset_id, 'GET_PREMIUM l_p_cover_id (prev) ' || l_p_cover_id);
    SELECT as_asset_id INTO l_as_asset_id FROM p_cover WHERE p_cover_id = l_p_cover_id;
    log(p_as_asset_id, 'GET_PREMIUM l_as_asset_id (prev) ' || l_as_asset_id);
  
    log(p_as_asset_id, 'GET_PREMIUM as_asset_id ' || l_as_asset_id);
    OPEN c_cover(l_as_asset_id);
    FETCH c_cover BULK COLLECT
      INTO resultset_prev;
    CLOSE c_cover;
  
    log(p_as_asset_id, 'GET_PREMIUM Количество программ ' || resultset_prev.count);
    FOR j IN 1 .. resultset_prev.count
    LOOP
    
      IF resultset_prev(j).lob_brief NOT IN ('Adm_Cost_Life', 'PEPR_INVEST_RESERVE')
      THEN
        RESULT := RESULT + nvl(resultset_prev(j).fee * resultset_prev(j).number_of_payments, 0);
        log(resultset_prev(j).p_cover_id
           ,'Финансовые каникулы. Страховая премия по программе ' || resultset_prev(j).lob_brief || ' ' ||
            nvl(resultset_prev(j).premium, 0));
      END IF;
    END LOOP;
    --
    RESULT := RESULT * 0.1;
  
    log(p_as_asset_id
       ,'Финансовые каникулы. Страховая премия на предыдущей версии ' || RESULT);
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      log(p_as_asset_id
         ,'Финансовые каникулы. Ошибка определениия премии ' || SQLERRM);
      ex.raise(par_message => 'Финансовые каникулы. Ошибка определениия премии ' || SQLERRM);
  END;

  /*
    Функция выполняет отключение и подключение покрытий, в соответствии с услугой "Финансовые каникулы"
  */

  FUNCTION end_weekend(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    --
    l_product_line_id  NUMBER; -- Идентификатор подключаемой программы
    l_policy_header_id NUMBER;
    --
    FUNCTION get_ins_amount(p_number_of_payment IN NUMBER) RETURN NUMBER IS
      RESULT              NUMBER DEFAULT 0;
      l_normrate          NUMBER DEFAULT 0;
      l_tariff            NUMBER DEFAULT 0;
      l_tariff_netto      NUMBER DEFAULT 0;
      l_loading           NUMBER DEFAULT 0;
      l_number_of_payment NUMBER DEFAULT 0;
    
    BEGIN
      log(l_cover_id, 'END_WEEKEND GET_INS_AMOUNT');
      l_normrate := pkg_productlifeproperty.calc_normrate_value(l_cover_id);
      log(l_cover_id, 'END_WEEKEND Норма доходности ' || l_normrate);
      l_loading := pkg_cover.calc_loading(l_cover_id);
      log(l_cover_id, 'END_WEEKEND Нагрузка ' || l_loading);
      -- Сохраняем на покрытии информацию по нагрузке и норме доходности
      UPDATE p_cover
         SET rvb_value      = l_loading
            ,normrate_value = l_normrate
       WHERE p_cover_id = l_cover_id;
      --
      l_tariff_netto := pkg_cover.calc_tariff_netto(l_cover_id);
      log(l_cover_id, 'END_WEEKEND Тариф нетто ' || l_tariff_netto);
    
      UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = l_cover_id;
      l_tariff := pkg_cover.calc_tariff(l_cover_id);
      log(l_cover_id, 'END_WEEKEND Тариф ' || l_tariff);
    
      UPDATE p_cover SET tariff = l_tariff WHERE p_cover_id = l_cover_id;
      --
      g_coef := pkg_tariff.calc_tarif_mul(l_cover_id);
    
      log(l_cover_id
         ,'END_WEEKEND GET_INS_AMOUNT g_premium ' || g_premium || p_number_of_payment || ' g_coef ' ||
          g_coef || 'l_tariff_netto ' || l_tariff_netto);
    
      RESULT := (g_premium / p_number_of_payment) * (1 - l_loading) / (l_tariff_netto * g_coef);
      RESULT := pkg_cover.round_ins_amount(l_cover_id, RESULT);
      log(l_cover_id, 'END_WEEKEND GET_INS_AMOUNT Страховая сумма ' || RESULT);
    
      UPDATE ven_p_cover SET ins_amount = RESULT WHERE p_cover_id = l_cover_id;
    
      RETURN RESULT;
      --
    END;
  
    /*
      Процедура подключает к договору программу "Страхование жизни на срок.Финансовые каникулы"
    */
  
    PROCEDURE add_program_one(p_index_id NUMBER) IS
      l_index_id NUMBER;
    BEGIN
    
      log(resultset(p_index_id).p_cover_id
         , 'END_WEEKEND ADD_PROGRAM_ONE product_ver_lob_id ' || resultset(p_index_id)
          .product_ver_lob_id);
    
      --  Получение возраста по основной программе
      g_insured_age := resultset(p_index_id).insured_age;
      --
      log(resultset(p_index_id).p_cover_id
         , 'END_WEEKEND ADD_PROGRAM_ONE Отключение покрытия ' || resultset(p_index_id).p_cover_id || ' ' || resultset(p_index_id)
          .lob_brief);
      pkg_cover.exclude_cover(resultset(p_index_id).p_cover_id);
      log(resultset(p_index_id).p_cover_id
         ,'END_WEEKEND ADD_PROGRAM_ONE Изменение суммы возврата на 0 ');
    
      SELECT pl.id
        INTO l_product_line_id
        FROM t_product_line pl
       WHERE pl.product_ver_lob_id IN
             (SELECT pv.t_product_ver_lob_id
                FROM t_product_ver_lob pv
                    ,t_product_ver_lob pv2
               WHERE pv.product_version_id = pv2.product_version_id
                 AND pv2.t_product_ver_lob_id = resultset(p_index_id).product_ver_lob_id)
         AND pl.brief = 'Страхование жизни на срок.Финансовые каникулы';
    
      log(resultset(p_index_id).p_cover_id
         ,'END_WEEKEND ADD_PROGRAM_ONE Поиск подключаемой программы. ' || l_product_line_id);
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
      log(l_cover_id, 'END_WEEKEND ADD_PROGRAM_ONE Покрытие подключено');
      -- Подключение коэффициентов
      log(l_cover_id
         ,'END_WEEKEND ADD_PROGRAM_ONE Подключение коэффициентов.');
      g_coef := pkg_tariff.calc_cover_coef(l_cover_id);
    
      -- Обновляем покрытие сроками отключенного покрытия
      log(l_cover_id
         ,'END_WEEKEND ADD_PROGRAM_ONE Переписываем даты покрытий ' ||
          to_char(resultset(p_index_id).start_date, 'dd.mm.yyyy') || ' ' ||
          to_char(resultset(p_index_id).end_date, 'dd.mm.yyyy'));
    
      copy_cover_info(p_index_id, l_cover_id, 1);
      g_ins_amount := get_ins_amount(resultset(p_index_id).number_of_payments);
      calc_cover(p_index_id, l_cover_id);
    
    END;
  
    PROCEDURE add_program_adm_cost_life(p_index_id NUMBER) IS
      l_index_id NUMBER;
    BEGIN
    
      log(resultset(p_index_id).p_cover_id, 'ADD_PROGRAM_ADM_COST_LIFE ');
    
      pkg_cover.exclude_cover(resultset(p_index_id).p_cover_id);
      l_product_line_id := resultset(p_index_id).pl_product_line_id;
      --
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Поиск подключаемой программы. ' ||
          l_product_line_id);
    
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. l_cover_id ' || l_cover_id);
    
      l_index_id := p_index_id;
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Подключение коэффициентов');
    
      g_coef := pkg_tariff.calc_cover_coef(l_cover_id);
      --    Копирование информации с отключенного покрытия
      copy_cover_info(p_index_id, l_cover_id, 0);
      --    Расчет подключенного покрытия
      calc_cover(l_index_id, l_cover_id);
    END;
    --
    PROCEDURE check_adm_cost_life IS
    BEGIN
      -- Проверяем наличие программы по брифу, если программы была - необходимо ее подключить повторно
      -- т.к. в процессе отключения она была отключена.
      FOR i IN 1 .. resultset.count
      LOOP
      
        IF resultset(i).lob_brief = 'Adm_Cost_Life'
        THEN
          --
          log(l_cover_id, 'END_WEEKEND Add_Program_Adm_Cost_Life');
          add_program_adm_cost_life(i);
        END IF;
      
      END LOOP;
    END;
  
    --
  BEGIN
    log(p_p_policy_id, 'END_WEEKEND');
    SELECT pol_header_id INTO l_policy_header_id FROM p_policy WHERE policy_id = p_p_policy_id;
    log(p_p_policy_id, 'END_WEEKEND');
  
    create_schedule(l_policy_header_id, p_p_policy_id);
  
    FOR cur IN c_asset(p_p_policy_id)
    LOOP
      log(p_p_policy_id, 'END_WEEKEND as_asset_id ' || cur.as_asset_id);
    
      OPEN c_cover(cur.as_asset_id);
    
      FETCH c_cover BULK COLLECT
        INTO resultset;
      log(p_p_policy_id, 'END_WEEKEND Количество программ ' || resultset.count);
      CLOSE c_cover;
    
      g_premium := get_premium(cur.as_asset_id);
      log(l_cover_id, 'END_WEEKEND Add_Program_One ' || g_premium);
    
      FOR i IN 1 .. resultset.count
      LOOP
      
        log(l_cover_id, 'END_WEEKEND resultset(i).lob_brief ' || resultset(i).lob_brief);
      
        IF resultset(i).lob_brief = 'END'
        THEN
          add_program_one(i);
        ELSE
          pkg_cover.exclude_cover(resultset(i).p_cover_id);
        END IF;
      
      -- Удаление неоплаяенных элементов графика
      --        pkg_payment.delete_unpayed(l_policy_header_id);
      
      END LOOP;
    
      --    Проверка наличия до фин каникул Администротивной программы (и ее повторное подключение)
      check_adm_cost_life;
    
      set_return_sum;
      set_decline(cur.as_asset_id);
    
    END LOOP;
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise_custom(par_message => SQLERRM);
  END;
  --
  FUNCTION chi_weekend(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    --
    l_p_cover_id          NUMBER;
    l_product_line_id     NUMBER;
    l_index_id            NUMBER;
    l_product_ver_lob_id  NUMBER;
    l_program_one_premium NUMBER;
    l_program_one_fee     NUMBER;
    l_policy_header_id    NUMBER;
    l_premium_week        NUMBER;
  
    PROCEDURE calculate_ins_amount
    (
      p_index_id     NUMBER
     ,p_index_id_cur NUMBER
    ) IS
      RESULT                NUMBER DEFAULT 0;
      l_normrate            NUMBER DEFAULT 0;
      l_tariff              NUMBER DEFAULT 0;
      l_tariff_netto        NUMBER DEFAULT 0;
      l_loading             NUMBER DEFAULT 0;
      l_number_of_payment   NUMBER DEFAULT 0;
      l_p_cover_id          NUMBER;
      l_p_policy_header_id  NUMBER;
      l_premium             NUMBER;
      l_coef                NUMBER;
      l_program_two_premium NUMBER;
      l_asset_header_id     NUMBER;
    BEGIN
      SELECT pp.pol_header_id
            ,aa.p_asset_header_id
        INTO l_p_policy_header_id
            ,l_asset_header_id
        FROM p_policy pp
            ,as_asset aa
            ,p_cover  pc
       WHERE pc.p_cover_id = resultset(p_index_id).p_cover_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id;
    
      log(l_p_cover_id, 'CALCULATE_INS_AMOUNT ' || resultset(p_index_id_cur).pl_brief);
    
      l_premium      := get_premium(resultset(p_index_id).as_asset_id);
      l_premium_week := l_premium;
    
      IF resultset(p_index_id_cur)
       .pl_brief = 'Смерть застрахованного по любой причине.Финансовые каникулы'
      THEN
      
        SELECT SUM(tr.acc_amount *
                   acc.get_cross_rate_by_id(1, tr.acc_fund_id, ph.fund_id, acp.plan_date))
          INTO resultset(p_index_id_cur).ins_amount
          FROM ins.doc_doc        dd
              ,ins.p_policy       pp
              ,ins.p_pol_header   ph
              ,ins.ac_payment     acp
              ,ins.doc_status_ref dsr
              ,ins.document       d
              ,ins.doc_templ      dt
              ,ins.fund           fh
              ,ins.fund           fp
              ,ins.oper           o
              ,ins.oper_templ     ot
              ,ins.trans          tr
         WHERE ph.policy_header_id = l_p_policy_header_id
           AND fh.fund_id = ph.fund_id
           AND fp.fund_id = acp.fund_id
           AND pp.pol_header_id = ph.policy_header_id
           AND dd.parent_id = pp.policy_id
           AND acp.payment_id = dd.child_id
           AND d.document_id = acp.payment_id
           AND d.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'PAID'
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYMENT'
              /**/
           AND d.document_id = o.document_id
           AND o.oper_id = tr.oper_id
           AND o.oper_templ_id = ot.oper_templ_id
           AND ot.brief = 'СтраховаяПремияОплачена'
           AND ((tr.a4_dt_ure_id = 310 AND
               tr.a4_dt_uro_id NOT IN
               (SELECT opt.id
                    FROM ins.t_prod_line_option opt
                        ,ins.t_product_line     pl
                   WHERE opt.product_line_id = pl.id
                     AND pl.t_lob_line_id IN
                         (SELECT ll.t_lob_line_id
                            FROM ins.t_lob_line ll
                           WHERE ll.brief IN
                                 ('Adm_Cost_Acc', 'Adm_Cost_Life', 'Penalty', 'PEPR_INVEST_RESERVE')))) OR
               (tr.a4_dt_ure_id = 310 AND
               tr.a4_dt_uro_id NOT IN
               (SELECT opt.id
                    FROM ins.t_prod_line_option opt
                        ,ins.t_product_line     pl
                   WHERE opt.product_line_id = pl.id
                     AND pl.t_lob_line_id IN
                         (SELECT ll.t_lob_line_id
                            FROM ins.t_lob_line ll
                           WHERE ll.brief IN
                                 ('Adm_Cost_Acc', 'Adm_Cost_Life', 'Penalty', 'PEPR_INVEST_RESERVE')))))
           AND ((tr.a3_dt_ure_id = 302 AND tr.a3_dt_uro_id = l_asset_header_id) OR
               (tr.a3_ct_ure_id = 302 AND tr.a3_ct_uro_id = l_asset_header_id));
      
        /*SELECT SUM(acp.amount*acc_new.get_rate_by_brief('ЦБ',fp.brief,acp.due_date)/acc_new.get_rate_by_brief('ЦБ',fh.brief,acp.due_date))
        INTO resultset(p_index_id_cur).ins_amount
        FROM ins.doc_doc dd,
             ins.p_policy pp,
             ins.p_pol_header ph,
             ins.ac_payment acp,
             ins.doc_status_ref dsr,
             ins.document d,
             ins.doc_templ dt,
             ins.fund fh,
             ins.fund fp
        WHERE ph.policy_header_id = l_p_policy_header_id
          AND fh.fund_id = ph.fund_id
          AND fp.fund_id = acp.fund_id
          AND pp.pol_header_id = ph.policy_header_id
          AND dd.parent_id  = pp.policy_id
          AND acp.payment_id = dd.child_id 
          AND d.document_id = acp.payment_id 
          AND d.doc_status_ref_id = dsr.doc_status_ref_id
          AND dsr.brief = 'PAID'
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief = 'PAYMENT';*/
      
        /*SELECT sum (part_PAY_AMOUNT) into resultset(p_index_id_cur).ins_amount
         FROM
           v_policy_payment_schedule ps
        WHERE 1=1
          and ps.pol_header_id = l_p_policy_header_id
          and doc_status_ref_name = 'Оплачен';*/
      
        resultset(p_index_id_cur).ins_amount := pkg_cover.round_ins_amount(resultset(p_index_id_cur)
                                                                           .p_cover_id
                                                                          ,resultset(p_index_id_cur)
                                                                           .ins_amount);
        log(resultset(p_index_id_cur).p_cover_id
           , 'ADD_PROGRAM_ONE CALCULATE_INS_AMOUNT Финансовые каникулы. Страховая сумма ' || resultset(p_index_id_cur)
            .ins_amount);
      
      ELSIF resultset(p_index_id_cur)
       .pl_brief = 'Смерть Застрахованного в результате несчастного случая.Финансовые каникулы'
      THEN
      
        log(resultset(p_index_id_cur).p_cover_id
           ,'ADD_PROGRAM_TWO CALCULATE_INS_AMOUNT l_Premium ' || l_premium);
        l_tariff := pkg_cover.calc_tariff(resultset(p_index_id_cur).p_cover_id);
        l_coef   := pkg_tariff.calc_tarif_mul(resultset(p_index_id_cur).p_cover_id);
      
        l_program_two_premium := (l_premium -
                                 l_program_one_fee * resultset(p_index_id_cur).number_of_payments) /
                                 (resultset(p_index_id_cur).number_of_payments * l_coef);
        log(resultset(p_index_id_cur).p_cover_id
           , 'ADD_PROGRAM_TWO CALCULATE_INS_AMOUNT l_tariff ' || l_tariff || ' l_Program_Two_Premium ' ||
             l_program_two_premium || ' l_coef ' || l_coef || ' number_of_payments ' || resultset(p_index_id_cur)
            .number_of_payments);
        resultset(p_index_id_cur).ins_amount := (l_program_two_premium) / (l_tariff);
        resultset(p_index_id_cur).ins_amount := pkg_cover.round_ins_amount(resultset(p_index_id_cur)
                                                                           .p_cover_id
                                                                          ,resultset(p_index_id_cur)
                                                                           .ins_amount);
        log(resultset(p_index_id_cur).p_cover_id
           , 'ADD_PROGRAM_TWO CALCULATE_INS_AMOUNT Страховая сумма ' || resultset(p_index_id_cur)
            .ins_amount);
      
      END IF;
    
      UPDATE p_cover
         SET ins_amount = resultset(p_index_id_cur).ins_amount
       WHERE p_cover_id = resultset(p_index_id_cur).p_cover_id
      RETURNING ins_amount INTO RESULT;
    
      log(resultset(p_index_id_cur).p_cover_id
         ,'CALCULATE_INS_AMOUNT Страховая сумма ' || RESULT);
    
      --
    END;
  
    PROCEDURE add_program_one(p_index_id NUMBER) IS
      l_index_id NUMBER;
    BEGIN
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ONE product_ver_lob_id ' || resultset(p_index_id).product_ver_lob_id);
    
      SELECT pl.id
        INTO l_product_line_id
        FROM t_product_line pl
       WHERE pl.product_ver_lob_id IN
             (SELECT pv.t_product_ver_lob_id
                FROM t_product_ver_lob pv
                    ,t_product_ver_lob pv2
               WHERE pv.product_version_id = pv2.product_version_id
                 AND pv2.t_product_ver_lob_id = resultset(p_index_id).product_ver_lob_id)
         AND pl.brief = 'Смерть застрахованного по любой причине.Финансовые каникулы';
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ONE Финансовые каникулы. Поиск подключаемой программы. ' || l_product_line_id);
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
      g_coef     := pkg_tariff.calc_cover_coef(l_cover_id);
      l_index_id := resultset.count + 1;
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      g_insured_age := resultset(p_index_id).insured_age;
    
      calculate_ins_amount(p_index_id, l_index_id);
    
      -- Обновляем покрытие сроками отключенного покрытия
      copy_cover_info(p_index_id, resultset(l_index_id).p_cover_id, 1);
      calc_cover(l_index_id, l_cover_id);
    
      SELECT premium INTO l_program_one_premium FROM p_cover WHERE p_cover_id = l_cover_id;
      SELECT fee INTO l_program_one_fee FROM p_cover WHERE p_cover_id = l_cover_id;
    
    END;
  
    /*
      Процедура подключения и расчета покрытий по услуге Финансовые каникулы
      Программа "Смерть Застрахованного в результате несчастного случая.Финансовые каникулы"
    */
  
    PROCEDURE add_program_two(p_index_id NUMBER) IS
      l_index_id      NUMBER;
      l_fee           NUMBER;
      l_ph_start_date DATE;
      l_pp_start_date DATE;
      l_pc_start_date DATE;
    
    BEGIN
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO product_ver_lob_id ' || resultset(p_index_id).product_ver_lob_id);
    
      SELECT pl.id
        INTO l_product_line_id
        FROM t_product_line pl
       WHERE pl.product_ver_lob_id IN
             (SELECT pv.t_product_ver_lob_id
                FROM t_product_ver_lob pv
                    ,t_product_ver_lob pv2
               WHERE pv.product_version_id = pv2.product_version_id
                 AND pv2.t_product_ver_lob_id = resultset(p_index_id).product_ver_lob_id)
         AND pl.brief = 'Смерть Застрахованного в результате несчастного случая.Финансовые каникулы';
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO Финансовые каникулы. Поиск подключаемой программы. ' || l_product_line_id);
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
      log(l_cover_id, 'ADD_PROGRAM_TWO Покрытие подключено');
    
      l_index_id := resultset.count + 1;
    
      SELECT ph.start_date
            ,pp.start_date
        INTO l_ph_start_date
            ,l_pp_start_date
        FROM p_policy     pp
            ,p_pol_header ph
            ,p_cover      pc
            ,as_asset     aa
       WHERE pc.p_cover_id = l_cover_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND ph.policy_header_id = pp.pol_header_id;
    
      l_pc_start_date := l_ph_start_date;
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO PC START_DATE ' || to_char(l_pc_start_date, 'dd.mm.yyyy') ||
          ' PP START_DATE ' || to_char(l_pp_start_date, 'dd.mm.yyyy'));
    
      LOOP
      
        IF trunc(ADD_MONTHS(l_pc_start_date, 12)) > trunc(l_pp_start_date)
        THEN
          log(resultset(p_index_id).p_cover_id
             ,'ADD_PROGRAM_TWO Поиск начала покрытия. ');
          EXIT;
        ELSE
          l_pc_start_date := ADD_MONTHS(l_pc_start_date, 12);
          log(resultset(p_index_id).p_cover_id
             ,'ADD_PROGRAM_TWO Поиск начала покрытия. ' || to_char(l_pc_start_date, 'dd.mm.yyyy'));
        END IF;
      
      END LOOP;
      BEGIN
      
        SELECT p.id
          INTO resultset(p_index_id).period_id
          FROM t_period_use_type  put
              ,t_period_type      pt
              ,t_period           p
              ,t_prod_line_period plp
         WHERE 1 = 1
           AND plp.product_line_id = l_product_line_id
           AND p.id = plp.period_id
           AND pt.id = p.period_type_id
           AND put.t_period_use_type_id = plp.t_period_use_type_id
              
           AND put.brief IN ('Срок страхования')
              
           AND plp.is_disabled = 0
           AND plp.is_default = 1;
      
      EXCEPTION
        WHEN no_data_found THEN
          pkg_forms_message.put_message('На настройке страховой программы не обнаружен "Срок страхования" по умолчанию. Услуга "Финансовые каникулы" не может быть применена');
          log(p_p_policy_id
             ,'На настройке страховой программы не обнаружен "Срок страхования" по умолчанию. Услуга "Финансовые каникулы" не может быть применена');
          raise_application_error(-20000, 'Ошибка');
      END;
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO PC START_DATE ' || to_char(l_pc_start_date, 'dd.mm.yyyy'));
    
      resultset(p_index_id).start_date := l_pc_start_date;
    
      resultset(p_index_id).end_date := ADD_MONTHS(l_pc_start_date, 12) - 1 / (24 * 60 * 60);
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO PC END_DATE' || resultset(p_index_id).end_date);
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      g_coef := pkg_tariff.calc_cover_coef(l_cover_id);
    
      calculate_ins_amount(p_index_id, l_index_id);
    
      -- Обновляем покрытие сроками отключенного покрытия
      copy_cover_info(p_index_id, resultset(l_index_id).p_cover_id, 1);
      calc_cover(l_index_id, l_cover_id);
    
    EXCEPTION
      WHEN OTHERS THEN
        log(resultset(p_index_id).p_cover_id, 'ADD_PROGRAM_TWO ' || SQLERRM);
        RAISE;
      
    END;
  
    PROCEDURE add_program_adm_cost_life(p_index_id NUMBER) IS
      l_index_id NUMBER;
    BEGIN
    
      log(resultset(p_index_id).p_cover_id, 'ADD_PROGRAM_ADM_COST_LIFE ');
    
      pkg_cover.exclude_cover(resultset(p_index_id).p_cover_id);
      l_product_line_id := resultset(p_index_id).pl_product_line_id;
      --
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Поиск подключаемой программы. ' ||
          l_product_line_id);
    
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
    
      l_index_id := resultset.count + 1;
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Подключение коэффициентов');
    
      g_coef := pkg_tariff.calc_cover_coef(l_cover_id);
      --    Копирование информации с отключенного покрытия
      copy_cover_info(p_index_id, l_cover_id, 0);
      --    Расчет подключенного покрытия
      calc_cover(l_index_id, l_cover_id);
    END;
    --
  BEGIN
  
    log(p_p_policy_id, 'CHI_WEEKEND');
    SELECT pol_header_id INTO l_policy_header_id FROM p_policy WHERE policy_id = p_p_policy_id;
    create_schedule(l_policy_header_id, p_p_policy_id);
  
    FOR cur IN c_asset(p_p_policy_id)
    LOOP
    
      OPEN c_cover(cur.as_asset_id);
      FETCH c_cover BULK COLLECT
        INTO resultset;
      CLOSE c_cover;
    
      log(p_p_policy_id, 'CHI_WEEKEND Всего программ ' || resultset.count);
    
      FOR i IN 1 .. resultset.count
      LOOP
      
        log(p_p_policy_id, 'CHI_WEEKEND Программа ' || resultset(i).pl_brief);
      
        IF resultset(i).pl_brief = 'Дожитие с возвратом взносов в случае смерти.Основная'
        THEN
          --
          log(p_p_policy_id
             ,'CHI_WEEKEND Отключение программы ' || resultset(i).pl_brief);
          pkg_cover.exclude_cover(resultset(i).p_cover_id);
        
          add_program_one(i);
        
          log(p_p_policy_id
             ,'CHI_WEEKEND l_Premium_Week ' || l_premium_week || ' l_Program_One_Premium ' ||
              l_program_one_premium);
          IF NOT (l_premium_week <= l_program_one_premium)
          THEN
            add_program_two(i);
          ELSE
            log(p_p_policy_id
               ,'CHI_WEEKEND Дополнительная программа не будет подключена ');
          END IF;
        
          --
        ELSIF resultset(i).lob_brief = 'Adm_Cost_Life'
        THEN
          --
          add_program_adm_cost_life(i);
          --
        ELSE
          pkg_cover.exclude_cover(resultset(i).p_cover_id);
        END IF;
      END LOOP;
    
      set_return_sum;
      set_decline(cur.as_asset_id);
    
    END LOOP;
    RETURN 1;
  END;
  --

  FUNCTION pepr_weekend(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    --
    l_p_cover_id          NUMBER;
    l_product_line_id     NUMBER;
    l_index_id            NUMBER;
    l_product_ver_lob_id  NUMBER;
    l_program_one_premium NUMBER;
    l_program_one_fee     NUMBER;
    l_policy_header_id    NUMBER;
    l_premium_week        NUMBER;
  
    PROCEDURE calculate_ins_amount
    (
      p_index_id     NUMBER
     ,p_index_id_cur NUMBER
    ) IS
      RESULT                NUMBER DEFAULT 0;
      l_normrate            NUMBER DEFAULT 0;
      l_tariff              NUMBER DEFAULT 0;
      l_tariff_netto        NUMBER DEFAULT 0;
      l_loading             NUMBER DEFAULT 0;
      l_number_of_payment   NUMBER DEFAULT 0;
      l_p_cover_id          NUMBER;
      l_p_policy_header_id  NUMBER;
      l_premium             NUMBER;
      l_coef                NUMBER;
      l_program_two_premium NUMBER;
      l_asset_header_id     NUMBER;
    BEGIN
      SELECT pp.pol_header_id
            ,aa.p_asset_header_id
        INTO l_p_policy_header_id
            ,l_asset_header_id
        FROM p_policy pp
            ,as_asset aa
            ,p_cover  pc
       WHERE pc.p_cover_id = resultset(p_index_id).p_cover_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id;
    
      log(l_p_cover_id, 'CALCULATE_INS_AMOUNT ' || resultset(p_index_id_cur).pl_brief);
    
      l_premium      := get_premium(resultset(p_index_id).as_asset_id);
      l_premium_week := l_premium;
    
      IF resultset(p_index_id_cur)
       .pl_brief = 'Смерть застрахованного по любой причине.Финансовые каникулы'
      THEN
      
        SELECT SUM(tr.acc_amount *
                   acc.get_cross_rate_by_id(1, tr.acc_fund_id, ph.fund_id, acp.plan_date))
          INTO resultset(p_index_id_cur).ins_amount
          FROM ins.doc_doc        dd
              ,ins.p_policy       pp
              ,ins.p_pol_header   ph
              ,ins.ac_payment     acp
              ,ins.doc_status_ref dsr
              ,ins.document       d
              ,ins.doc_templ      dt
              ,ins.fund           fh
              ,ins.fund           fp
              ,ins.oper           o
              ,ins.oper_templ     ot
              ,ins.trans          tr
         WHERE ph.policy_header_id = l_p_policy_header_id
           AND fh.fund_id = ph.fund_id
           AND fp.fund_id = acp.fund_id
           AND pp.pol_header_id = ph.policy_header_id
           AND dd.parent_id = pp.policy_id
           AND acp.payment_id = dd.child_id
           AND d.document_id = acp.payment_id
           AND d.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'PAID'
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYMENT'
              /**/
           AND d.document_id = o.document_id
           AND o.oper_id = tr.oper_id
           AND o.oper_templ_id = ot.oper_templ_id
           AND ot.brief = 'СтраховаяПремияОплачена'
           AND ((tr.a4_dt_ure_id = 310 AND
               tr.a4_dt_uro_id NOT IN
               (SELECT opt.id
                    FROM ins.t_prod_line_option opt
                        ,ins.t_product_line     pl
                   WHERE opt.product_line_id = pl.id
                     AND pl.t_lob_line_id IN
                         (SELECT ll.t_lob_line_id
                            FROM ins.t_lob_line ll
                           WHERE ll.brief IN
                                 ('Adm_Cost_Acc', 'Adm_Cost_Life', 'Penalty', 'PEPR_INVEST_RESERVE')))) OR
               (tr.a4_dt_ure_id = 310 AND
               tr.a4_dt_uro_id NOT IN
               (SELECT opt.id
                    FROM ins.t_prod_line_option opt
                        ,ins.t_product_line     pl
                   WHERE opt.product_line_id = pl.id
                     AND pl.t_lob_line_id IN
                         (SELECT ll.t_lob_line_id
                            FROM ins.t_lob_line ll
                           WHERE ll.brief IN
                                 ('Adm_Cost_Acc', 'Adm_Cost_Life', 'Penalty', 'PEPR_INVEST_RESERVE')))))
           AND ((tr.a3_dt_ure_id = 302 AND tr.a3_dt_uro_id = l_asset_header_id) OR
               (tr.a3_ct_ure_id = 302 AND tr.a3_ct_uro_id = l_asset_header_id));
        /*SELECT SUM(acp.amount*acc_new.get_rate_by_brief('ЦБ',fp.brief,acp.due_date)/acc_new.get_rate_by_brief('ЦБ',fh.brief,acp.due_date))
        INTO resultset(p_index_id_cur).ins_amount
        FROM ins.doc_doc dd,
             ins.p_policy pp,
             ins.p_pol_header ph,
             ins.ac_payment acp,
             ins.doc_status_ref dsr,
             ins.document d,
             ins.doc_templ dt,
             ins.fund fh,
             ins.fund fp
        WHERE ph.policy_header_id = l_p_policy_header_id
          AND fh.fund_id = ph.fund_id
          AND fp.fund_id = acp.fund_id
          AND pp.pol_header_id = ph.policy_header_id
          AND dd.parent_id  = pp.policy_id
          AND acp.payment_id = dd.child_id 
          AND d.document_id = acp.payment_id 
          AND d.doc_status_ref_id = dsr.doc_status_ref_id
          AND dsr.brief = 'PAID'
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief = 'PAYMENT';*/
        /*SELECT sum (part_PAY_AMOUNT) into resultset(p_index_id_cur).ins_amount
         FROM
           v_policy_payment_schedule ps
        WHERE 1=1
          and ps.pol_header_id = l_p_policy_header_id
          and doc_status_ref_name = 'Оплачен';*/
      
        resultset(p_index_id_cur).ins_amount := pkg_cover.round_ins_amount(resultset(p_index_id_cur)
                                                                           .p_cover_id
                                                                          ,resultset(p_index_id_cur)
                                                                           .ins_amount);
        log(resultset(p_index_id_cur).p_cover_id
           , 'ADD_PROGRAM_ONE CALCULATE_INS_AMOUNT Финансовые каникулы. Страховая сумма ' || resultset(p_index_id_cur)
            .ins_amount);
      
      ELSIF resultset(p_index_id_cur)
       .pl_brief = 'Смерть Застрахованного в результате несчастного случая.Финансовые каникулы'
      THEN
      
        log(resultset(p_index_id_cur).p_cover_id
           ,'ADD_PROGRAM_TWO CALCULATE_INS_AMOUNT l_Premium ' || l_premium);
        l_tariff := pkg_cover.calc_tariff(resultset(p_index_id_cur).p_cover_id);
        l_coef   := pkg_tariff.calc_tarif_mul(resultset(p_index_id_cur).p_cover_id);
      
        l_program_two_premium := (l_premium -
                                 l_program_one_fee * resultset(p_index_id_cur).number_of_payments) /
                                 (resultset(p_index_id_cur).number_of_payments * l_coef);
        log(resultset(p_index_id_cur).p_cover_id
           , 'ADD_PROGRAM_TWO CALCULATE_INS_AMOUNT l_tariff ' || l_tariff || ' l_Program_Two_Premium ' ||
             l_program_two_premium || ' l_coef ' || l_coef || ' number_of_payments ' || resultset(p_index_id_cur)
            .number_of_payments);
        resultset(p_index_id_cur).ins_amount := (l_program_two_premium) / (l_tariff);
        resultset(p_index_id_cur).ins_amount := pkg_cover.round_ins_amount(resultset(p_index_id_cur)
                                                                           .p_cover_id
                                                                          ,resultset(p_index_id_cur)
                                                                           .ins_amount);
        log(resultset(p_index_id_cur).p_cover_id
           , 'ADD_PROGRAM_TWO CALCULATE_INS_AMOUNT Страховая сумма ' || resultset(p_index_id_cur)
            .ins_amount);
      
      END IF;
    
      UPDATE p_cover
         SET ins_amount = resultset(p_index_id_cur).ins_amount
       WHERE p_cover_id = resultset(p_index_id_cur).p_cover_id
      RETURNING ins_amount INTO RESULT;
    
      log(resultset(p_index_id_cur).p_cover_id
         ,'CALCULATE_INS_AMOUNT Страховая сумма ' || RESULT);
    
      --
    END;
  
    PROCEDURE add_program_one(p_index_id NUMBER) IS
      l_index_id NUMBER;
    BEGIN
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ONE product_ver_lob_id ' || resultset(p_index_id).product_ver_lob_id);
    
      SELECT pl.id
        INTO l_product_line_id
        FROM t_product_line pl
       WHERE pl.product_ver_lob_id IN
             (SELECT pv.t_product_ver_lob_id
                FROM t_product_ver_lob pv
                    ,t_product_ver_lob pv2
               WHERE pv.product_version_id = pv2.product_version_id
                 AND pv2.t_product_ver_lob_id = resultset(p_index_id).product_ver_lob_id)
         AND pl.brief = 'Смерть застрахованного по любой причине.Финансовые каникулы';
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ONE Финансовые каникулы. Поиск подключаемой программы. ' || l_product_line_id);
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
      g_coef     := pkg_tariff.calc_cover_coef(l_cover_id);
      l_index_id := resultset.count + 1;
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      g_insured_age := resultset(p_index_id).insured_age;
    
      calculate_ins_amount(p_index_id, l_index_id);
    
      -- Обновляем покрытие сроками отключенного покрытия
      copy_cover_info(p_index_id, resultset(l_index_id).p_cover_id, 1);
      calc_cover(l_index_id, l_cover_id);
    
      SELECT premium INTO l_program_one_premium FROM p_cover WHERE p_cover_id = l_cover_id;
      SELECT fee INTO l_program_one_fee FROM p_cover WHERE p_cover_id = l_cover_id;
    
    END;
  
    /*
      Процедура подключения и расчета покрытий по услуге Финансовые каникулы
      Программа "Смерть Застрахованного в результате несчастного случая.Финансовые каникулы"
    */
  
    PROCEDURE add_program_two(p_index_id NUMBER) IS
      l_index_id      NUMBER;
      l_fee           NUMBER;
      l_ph_start_date DATE;
      l_pp_start_date DATE;
      l_pc_start_date DATE;
    
    BEGIN
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO product_ver_lob_id ' || resultset(p_index_id).product_ver_lob_id);
    
      SELECT pl.id
        INTO l_product_line_id
        FROM t_product_line pl
       WHERE pl.product_ver_lob_id IN
             (SELECT pv.t_product_ver_lob_id
                FROM t_product_ver_lob pv
                    ,t_product_ver_lob pv2
               WHERE pv.product_version_id = pv2.product_version_id
                 AND pv2.t_product_ver_lob_id = resultset(p_index_id).product_ver_lob_id)
         AND pl.brief = 'Смерть Застрахованного в результате несчастного случая.Финансовые каникулы';
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO Финансовые каникулы. Поиск подключаемой программы. ' || l_product_line_id);
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
      log(l_cover_id, 'ADD_PROGRAM_TWO Покрытие подключено');
    
      l_index_id := resultset.count + 1;
    
      SELECT ph.start_date
            ,pp.start_date
        INTO l_ph_start_date
            ,l_pp_start_date
        FROM p_policy     pp
            ,p_pol_header ph
            ,p_cover      pc
            ,as_asset     aa
       WHERE pc.p_cover_id = l_cover_id
         AND aa.as_asset_id = pc.as_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND ph.policy_header_id = pp.pol_header_id;
    
      l_pc_start_date := l_ph_start_date;
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO PC START_DATE ' || to_char(l_pc_start_date, 'dd.mm.yyyy') ||
          ' PP START_DATE ' || to_char(l_pp_start_date, 'dd.mm.yyyy'));
    
      --    Производим поиск даты покрытий по НС
      LOOP
      
        IF trunc(ADD_MONTHS(l_pc_start_date, 12)) > trunc(l_pp_start_date)
        THEN
          log(resultset(p_index_id).p_cover_id
             ,'ADD_PROGRAM_TWO Поиск начала покрытия. ');
          EXIT;
        ELSE
          l_pc_start_date := ADD_MONTHS(l_pc_start_date, 12);
          log(resultset(p_index_id).p_cover_id
             ,'ADD_PROGRAM_TWO Поиск начала покрытия. ' || to_char(l_pc_start_date, 'dd.mm.yyyy'));
        END IF;
      
      END LOOP;
      BEGIN
      
        SELECT p.id
          INTO resultset(p_index_id).period_id
          FROM t_period_use_type  put
              ,t_period_type      pt
              ,t_period           p
              ,t_prod_line_period plp
         WHERE 1 = 1
           AND plp.product_line_id = l_product_line_id
           AND p.id = plp.period_id
           AND pt.id = p.period_type_id
           AND put.t_period_use_type_id = plp.t_period_use_type_id
              
           AND put.brief IN ('Срок страхования')
              
           AND plp.is_disabled = 0
           AND plp.is_default = 1;
      
      EXCEPTION
        WHEN no_data_found THEN
          pkg_forms_message.put_message('На настройке страховой программы не обнаружен "Срок страхования" по умолчанию. Услуга "Финансовые каникулы" не может быть применена');
          log(p_p_policy_id
             ,'На настройке страховой программы не обнаружен "Срок страхования" по умолчанию. Услуга "Финансовые каникулы" не может быть применена');
          raise_application_error(-20000, 'Ошибка');
      END;
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO PC START_DATE ' || to_char(l_pc_start_date, 'dd.mm.yyyy'));
    
      resultset(p_index_id).start_date := l_pc_start_date;
    
      resultset(p_index_id).end_date := ADD_MONTHS(l_pc_start_date, 12) - 1 / (24 * 60 * 60);
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_TWO PC END_DATE' || resultset(p_index_id).end_date);
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      g_coef := pkg_tariff.calc_cover_coef(l_cover_id);
    
      calculate_ins_amount(p_index_id, l_index_id);
    
      -- Обновляем покрытие сроками отключенного покрытия
      copy_cover_info(p_index_id, resultset(l_index_id).p_cover_id, 1);
      calc_cover(l_index_id, l_cover_id);
    
    EXCEPTION
      WHEN OTHERS THEN
        log(resultset(p_index_id).p_cover_id, 'ADD_PROGRAM_TWO ' || SQLERRM);
        RAISE;
      
    END;
  
    PROCEDURE add_program_adm_cost_life(p_index_id NUMBER) IS
      l_index_id NUMBER;
    BEGIN
    
      log(resultset(p_index_id).p_cover_id, 'ADD_PROGRAM_ADM_COST_LIFE ');
    
      pkg_cover.exclude_cover(resultset(p_index_id).p_cover_id);
      l_product_line_id := resultset(p_index_id).pl_product_line_id;
      --
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Поиск подключаемой программы. ' ||
          l_product_line_id);
    
      l_cover_id := pkg_cover.include_cover(resultset(p_index_id).as_asset_id, l_product_line_id);
    
      l_index_id := p_index_id;
    
      SELECT vcl.*
        INTO resultset(l_index_id)
        FROM v_asset_cover_life vcl
       WHERE p_cover_id = l_cover_id;
    
      log(resultset(p_index_id).p_cover_id
         ,'ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Подключение коэффициентов');
    
      g_coef := pkg_tariff.calc_cover_coef(l_cover_id);
      --    Копирование информации с отключенного покрытия
      copy_cover_info(p_index_id, l_cover_id, 0);
      --    Расчет подключенного покрытия
      calc_cover(l_index_id, l_cover_id);
    END;
    --
  BEGIN
  
    log(p_p_policy_id, 'PEPR_WEEKEND ');
    SELECT pol_header_id INTO l_policy_header_id FROM p_policy WHERE policy_id = p_p_policy_id;
    create_schedule(l_policy_header_id, p_p_policy_id);
  
    FOR cur IN c_asset(p_p_policy_id)
    LOOP
    
      OPEN c_cover(cur.as_asset_id);
      FETCH c_cover BULK COLLECT
        INTO resultset;
      CLOSE c_cover;
    
      log(p_p_policy_id, 'PEPR_WEEKEND Всего программ ' || resultset.count);
    
      FOR i IN 1 .. resultset.count
      LOOP
      
        log(p_p_policy_id, 'PEPR_WEEKEND Программа ' || resultset(i).pl_brief);
      
        IF resultset(i).pl_brief = 'Дожитие с возвратом взносов в случае смерти.Основная'
        THEN
          --
          log(p_p_policy_id
             ,'PEPR_WEEKEND Отключение программы ' || resultset(i).pl_brief);
          pkg_cover.exclude_cover(resultset(i).p_cover_id);
        
          add_program_one(i);
        
          log(p_p_policy_id
             ,'PEPR_WEEKEND l_Premium_Week ' || l_premium_week || ' l_Program_One_Premium ' ||
              l_program_one_premium);
          IF NOT (l_premium_week <= l_program_one_premium)
          THEN
            add_program_two(i);
          ELSE
            log(p_p_policy_id
               ,'PEPR_WEEKEND Дополнительная программа не будет подключена ');
          END IF;
        
          --
        ELSIF resultset(i).lob_brief = 'Adm_Cost_Life'
        THEN
          --
          add_program_adm_cost_life(i);
          --
        ELSE
          pkg_cover.exclude_cover(resultset(i).p_cover_id);
        END IF;
      END LOOP;
    
      set_return_sum;
      set_decline(cur.as_asset_id);
    
    END LOOP;
    RETURN 1;
  END;

  /* */
  --Прекращение услуги "Финансовые каникулы" 
  FUNCTION end_restore_weekend
  (
    p_p_policy_id IN NUMBER
   ,p_source      IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    --
    l_product_line_id   NUMBER; -- Идентификатор подключаемой программы
    l_policy_header_id  NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_decline_reason_id NUMBER;
    l_policy_week_id    NUMBER;
    l_period_id         NUMBER;
    l_source            VARCHAR2(20) := 'END_RESTORE_WEEKEND';
    l_resultset         v_asset_cover_life%ROWTYPE;
    --Курсор определяет неотменную последнюю версию с типом изменения <Услуга Финансовые каникулы>
    CURSOR c_data(p_p_policy_id IN NUMBER) IS
      SELECT pp.policy_id
        FROM p_policy            pp
            ,p_pol_addendum_type pa
            ,t_addendum_type     at
            ,ins.document        d
            ,ins.doc_status_ref  rf
       WHERE pp.pol_header_id =
             (SELECT pol_header_id FROM p_policy pp1 WHERE policy_id = p_p_policy_id)
         AND pa.p_policy_id = pp.policy_id
         AND at.t_addendum_type_id = pa.t_addendum_type_id
         AND at.brief = 'FIN_WEEK'
         AND pp.policy_id = d.document_id
         AND d.doc_status_ref_id = rf.doc_status_ref_id
         AND rf.brief != 'CANCEL'
      -- Байтин А.
      -- Заявка 176472
      -- Необходимо брать последнюю версию
       ORDER BY pp.version_num;
  
    PROCEDURE restore_wop(p_as_asset_id IN NUMBER) IS
      r_resultset p_cover%ROWTYPE;
    BEGIN
    
      log(p_p_policy_id, l_source || ' RESTORE_WOP ');
      --для не отключенной по покрытию страховой программы (t_lob_line):
      -- Доп. программа №3 Освобождение от уплаты дальнейших взносов
      -- Доп. программа №4 Защита страховых взносов
      FOR cur IN (SELECT *
                    FROM v_asset_cover_life
                   WHERE as_asset_id = p_as_asset_id
                     AND sh_brief != 'DELETED'
                     AND lob_brief IN ('WOP', 'PWOP'))
      LOOP
        --расчитываем Страховую сумму по покрытию
        r_resultset.ins_amount := pkg_cover.calc_ins_amount(cur.p_cover_id);
        --обновляем Страховую сумм по покрытию
        UPDATE p_cover pc
           SET ins_amount = r_resultset.ins_amount
         WHERE pc.p_cover_id = cur.p_cover_id;
        --рассчитываем брутто-взнос
        r_resultset.fee := pkg_cover.calc_fee(cur.p_cover_id);
        --обновляем брутто взнос по покрытию
        UPDATE p_cover SET fee = r_resultset.fee WHERE p_cover_id = cur.p_cover_id;
        --рассчитываем премию
        r_resultset.premium := pkg_cover.calc_premium(cur.p_cover_id);
        --обновляем премию  по покрытию
        UPDATE p_cover SET premium = r_resultset.premium WHERE p_cover_id = cur.p_cover_id;
      
      END LOOP;
    
      log(p_p_policy_id, l_source || ' RESTORE_WOP EXIT');
    
    END;
  
    /** Подключение покрытия по административным расходам
    *, если оно было до отключения восстановлением фин каникул" 
    */
  
    PROCEDURE add_program_adm_cost_life(p_as_asset_id IN NUMBER) IS
      l_index_id NUMBER;
      l_coef     NUMBER;
      l_cover_id NUMBER;
    BEGIN
    
      log(p_p_policy_id, l_source || ' ADD_PROGRAM_ADM_COST_LIFE ');
    
      FOR cur IN (SELECT *
                    FROM v_asset_cover_life
                   WHERE as_asset_id = p_as_asset_id
                     AND lob_brief = 'Adm_Cost_Life')
      LOOP
        -- Проверяем, вдруг покрытие не отключено, тогда = отключаем
        pkg_cover.exclude_cover(cur.p_cover_id);
        l_product_line_id := cur.product_line_id;
        --
        log(p_p_policy_id
           ,l_source ||
            ' ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Поиск подключаемой программы. ' ||
            l_product_line_id);
      
        l_cover_id := pkg_cover.include_cover(p_as_asset_id, l_product_line_id);
      
        log(p_p_policy_id
           ,l_source || ' ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. l_cover_id ' || l_cover_id);
      
        log(p_p_policy_id
           ,l_source || ' ADD_PROGRAM_ADM_COST_LIFE Финансовые каникулы. Подключение коэффициентов');
      
        l_coef := pkg_tariff.calc_cover_coef(l_cover_id);
      END LOOP;
    END;
    --
  BEGIN
    l_source := nvl(p_source, l_source);
    log(p_p_policy_id, l_source);
  
    --обновляем ИД метода расчета вык. сумм(0-старая методика 3%, 1-старая 4%, 2-новая 4%)
    ins.pkg_pol_cash_surr_method.set_metod_f_t(p_p_policy_id, 2);
  
    --определяем ИД причиты рассторжения 'Услуга Финансовые каникулы'
    SELECT t_decline_reason_id
      INTO l_decline_reason_id
      FROM t_decline_reason
     WHERE brief = 'Услуга Финансовые каникулы';
  
    --определяем дату начала версии полиса 
    SELECT start_date INTO l_start_date FROM p_policy WHERE policy_id = p_p_policy_id;
  
    --находим неотменную последнюю версию с типом изменения <Услуга Финансовые каникулы>
    FOR cur IN c_data(p_p_policy_id)
    LOOP
      l_policy_week_id := cur.policy_id;
    END LOOP;
  
    --проходим по всем объектам страхования новой версии полиса
    FOR cur IN c_asset(p_p_policy_id)
    LOOP
      log(p_p_policy_id
         ,l_source || ' as_asset_id ' || cur.as_asset_id || ' policy_week_id ' || l_policy_week_id);
    
      OPEN c_cover(cur.as_asset_id);
    
      FETCH c_cover BULK COLLECT
        INTO resultset;
      log(p_p_policy_id, l_source || ' Количество программ ' || resultset.count);
      CLOSE c_cover;
    
      --проходим по всем не исключенным покрытиям найденного объекта страхования
      FOR i IN 1 .. resultset.count
      LOOP
        --если программы по покрытию 'Страхование жизни на срок.Финансовые каникулы'
        --                           'Смерть застрахованного по любой причине.Финансовые каникулы'
        IF resultset(i)
         .pl_brief IN ('Страхование жизни на срок.Финансовые каникулы'
                        ,'Смерть застрахованного по любой причине.Финансовые каникулы')
        THEN
          --  Получение возраста по основной программе
          log(resultset(i).p_cover_id
             ,l_source || ' Отключение покрытия ' || resultset(i).p_cover_id);
          --отключаем покрытие
          pkg_cover.exclude_cover(resultset(i).p_cover_id);
        
          --находим отключенное покрытие, которое было отключено в предыдущих версиях в версии с типом изменений Услуга Финансовые каникулы
          FOR cur_weekend IN ( /*select ac.* from v_asset_cover_life ac, p_policy pp, as_asset aa
                                                                                                                 where pp.policy_id = l_policy_week_id
                                                                                                                   and aa.p_policy_id = pp.policy_id
                                                                                                                   and ac.as_asset_id = aa.as_asset_id
                                                                                                                   and ac.SH_BRIEF = 'DELETED'
                                                                                                                   and ac.decline_reason_id = l_decline_reason_id
                                                                                                                   order by ac.pl_sort_order\*ac.p_cover_id*\*/
                              SELECT *
                                FROM (SELECT z.*
                                             ,row_number() over(PARTITION BY z.pl_product_line_id ORDER BY z.lvl DESC) AS rn
                                         FROM (SELECT xx.*
                                                     ,LEVEL AS lvl
                                                 FROM (SELECT /*+ NO_MERGE */
                                                        ac.pl_description
                                                       ,ac.pl_product_line_id
                                                       ,ac.lob_brief
                                                       ,ac.product_line_id
                                                       ,ac.end_date
                                                       ,ac.start_date
                                                       ,ac.fee
                                                       ,ac.ins_amount
                                                       ,ac.s_coef
                                                       ,ac.k_coef
                                                       ,ac.k_coef_m
                                                       ,ac.k_coef_nm
                                                       ,ac.s_coef_m
                                                       ,ac.s_coef_nm
                                                       ,ac.is_handchange_s_coef_nm
                                                       ,ac.is_handchange_k_coef_nm
                                                       ,ac.period_id
                                                       ,ac.p_cover_id
                                                       ,ac.pl_brief
                                                       ,ppl.t_parent_prod_line_id
                                                         FROM v_asset_cover_life ac
                                                             ,p_policy           pp
                                                             ,as_asset           aa
                                                             ,parent_prod_line   ppl
                                                             ,t_product_line     pl
                                                        WHERE pp.policy_id = l_policy_week_id
                                                          AND aa.p_policy_id = pp.policy_id
                                                          AND ac.as_asset_id = aa.as_asset_id
                                                          AND ac.sh_brief = 'DELETED'
                                                          AND ac.decline_reason_id = l_decline_reason_id
                                                          AND ac.pl_product_line_id = ppl.t_prod_line_id(+)
                                                          AND ppl.t_parent_prod_line_id = pl.id(+)) xx
                                               CONNECT BY xx.pl_product_line_id = PRIOR
                                                          xx.t_parent_prod_line_id) z)
                               WHERE rn = 1
                               ORDER BY lvl DESC)
          LOOP
          
            -- Программы Инвест не восстанавливаются
            IF cur_weekend.lob_brief NOT IN ('INVEST', 'INVEST2', 'PEPR_INVEST_RESERVE')
            THEN
              log(resultset(i).p_cover_id
                 ,l_source || ' ' || cur_weekend.lob_brief ||
                  ' Подключение покрытия product_line_id ' || cur_weekend.product_line_id);
              --Подключение покрытия в новую версию по объекту страхования
              --include заменен на cre по заявке 315264
              --l_cover_id := pkg_cover.include_cover(cur.as_asset_id, cur_weekend.product_line_id);
              l_cover_id := pkg_cover.cre_new_cover(cur.as_asset_id, cur_weekend.product_line_id);
            
              SELECT end_date
                    ,period_id
                INTO l_end_date
                    ,l_period_id
                FROM p_cover
               WHERE p_cover_id = l_cover_id;
              log(resultset(i).p_cover_id
                 ,l_source || ' ' || cur_weekend.lob_brief || ' end_date ' ||
                  to_char(l_end_date, 'dd.mm.yyyy') || ' l_period_id ' || l_period_id);
              log(resultset(i).p_cover_id
                 ,l_source || ' ' || cur_weekend.lob_brief || ' end_date ' ||
                  to_char(cur_weekend.end_date, 'dd.mm.yyyy') || ' weekend_period_id ' ||
                  cur_weekend.period_id);
            
              l_resultset.p_cover_id := cur_weekend.p_cover_id;
              l_resultset.start_date := l_start_date;
            
              IF cur_weekend.end_date < l_start_date
              THEN
                l_resultset.end_date := l_start_date + (cur_weekend.end_date - cur_weekend.start_date);
              ELSE
                l_resultset.end_date := cur_weekend.end_date;
              END IF;
              --          Копируем в запись параметры ранее отключенного покрытия, для восстановления данных в новом покрытии
              l_resultset.fee                     := cur_weekend.fee;
              l_resultset.ins_amount              := cur_weekend.ins_amount;
              l_resultset.s_coef                  := cur_weekend.s_coef;
              l_resultset.k_coef                  := cur_weekend.k_coef;
              l_resultset.k_coef_m                := cur_weekend.k_coef_m;
              l_resultset.k_coef_nm               := cur_weekend.k_coef_nm;
              l_resultset.s_coef_m                := cur_weekend.s_coef_m;
              l_resultset.s_coef_nm               := cur_weekend.s_coef_nm;
              l_resultset.is_handchange_s_coef_nm := cur_weekend.is_handchange_s_coef_nm;
              l_resultset.is_handchange_k_coef_nm := cur_weekend.is_handchange_k_coef_nm;
              l_resultset.period_id               := cur_weekend.period_id;
              l_resultset.source_cover_id         := cur_weekend.p_cover_id;
              l_resultset.lob_brief               := cur_weekend.lob_brief;
              l_resultset.pl_brief                := cur_weekend.pl_brief;
            
              -- Обновляем покрытие сроками отключенного покрытия      
            
              restore_cover_info(l_cover_id, l_resultset);
            END IF;
          END LOOP;
        
        END IF;
      
      END LOOP;
      --Подключение покрытия по административным расходам
      --, если оно было до отключения восстановлением фин каникул"
      add_program_adm_cost_life(cur.as_asset_id);
    
      log(p_p_policy_id, p_source || ' START RESTORE_WOP');
      --пересчитываем премию, Страх сумму, брутто взнос по WOP
      restore_wop(cur.as_asset_id);
    
      log(p_p_policy_id, p_source || ' START SET_RETURN_SUM');
      --обновляем сумму возврата
      set_return_sum;
    
      log(p_p_policy_id, p_source || ' SET_DECLINE');
      --обновляем параметры расторжения по покрытию
      set_decline(cur.as_asset_id);
    
    END LOOP;
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      log(l_cover_id, l_source || 'ERROR ' || SQLERRM);
      RETURN 0; --Поскряков 01.03.2012. Чтобы убрать ошибку ORA-06503: PL/SQL: Function returned without value
  END;

  FUNCTION chi_restore_weekend
  (
    p_p_policy_id NUMBER
   ,p_source      IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT   NUMBER;
    l_source VARCHAR2(20) := 'CHI_RESTORE_WEEKEND';
  BEGIN
    log(p_p_policy_id, l_source);
    RESULT := end_restore_weekend(p_p_policy_id, l_source);
    RETURN RESULT;
  END;

  /** Прекращение "Финансовые каникулы" для продукта "Будущее"
  *
  */
  FUNCTION pepr_restore_weekend
  (
    p_p_policy_id IN NUMBER
   ,p_source      IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    RESULT   NUMBER;
    l_source VARCHAR2(20) := 'PEPR_RESTORE_WEEKEND';
  BEGIN
    log(p_p_policy_id, l_source);
    RESULT := end_restore_weekend(p_p_policy_id, l_source);
    RETURN RESULT;
  END;

  /*
    Функция расчета страховой премии для покрытий, которые подключены в услуге Финансовые каникулы.
    Возвращает стр. премию в зависимости от даты вступления услуги"Финансовые каникулы"
  */
  FUNCTION calcpremiumacc(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    l_ph_start_date DATE;
    l_pp_start_date DATE;
    l_months        NUMBER;
    l_fee           NUMBER;
    l_qty           NUMBER;
    RESULT          NUMBER;
  
  BEGIN
    SELECT ph.start_date
          ,pp.start_date
      INTO l_ph_start_date
          ,l_pp_start_date
      FROM p_policy     pp
          ,p_pol_header ph
          ,p_cover      pc
          ,as_asset     aa
     WHERE pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.p_policy_id
       AND ph.policy_header_id = pp.pol_header_id;
  
    l_months := MONTHS_BETWEEN(l_pp_start_date, l_ph_start_date);
    LOOP
      IF l_months > 12
      THEN
        l_months := l_months - 12;
      ELSE
        EXIT;
      END IF;
    END LOOP;
  
    SELECT pc.fee
          ,pt.number_of_payments qty
      INTO l_fee
          ,l_qty
      FROM t_payment_terms pt
          ,t_period        tp
          ,p_pol_header    ph
          ,p_policy        pp
          ,as_asset        aa
          ,p_cover         pc
     WHERE 1 = 1
       AND pc.p_cover_id = p_p_cover_id
       AND aa.as_asset_id(+) = pc.as_asset_id
       AND pp.policy_id(+) = aa.p_policy_id
       AND tp.id(+) = pp.period_id
       AND ph.policy_header_id(+) = pp.pol_header_id
       AND pt.id(+) = pp.payment_term_id;
  
    RESULT := l_fee * l_qty;
    /*IF l_qty = 4
       AND l_months = 3
    THEN
      RESULT := l_fee * 3;
    ELSIF l_qty = 4
          AND l_months = 6
    THEN
      RESULT := l_fee * 2;
    ELSIF l_qty = 4
          AND l_months = 9
    THEN
      RESULT := l_fee * 1;
    ELSIF l_qty = 4
          AND l_months = 12
    THEN
      RESULT := l_fee * 4;
    END IF;
    
    IF l_qty = 2
       AND l_months = 6
    THEN
      RESULT := l_fee * 2;
    ELSE
      RESULT := l_fee * 2;
    END IF;
    
    IF l_qty = 1
    THEN
      RESULT := l_fee;
    END IF;*/
  
    RETURN RESULT;
    --
  END;
  /*Возвращает 1, если покрытие - Инвест-Резерв
    Возвращает 0, если покрытие не Инвест-Резерв
  */
  FUNCTION is_invest_reserve(p_p_cover_id NUMBER) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO res
      FROM ins.p_cover            pc
          ,ins.t_prod_line_option opt
          ,ins.t_product_line     pl
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.t_prod_line_option_id = opt.id
       AND opt.product_line_id = pl.id
       AND pl.t_lob_line_id IN
           (SELECT ll.t_lob_line_id FROM ins.t_lob_line ll WHERE ll.brief = 'PEPR_INVEST_RESERVE');
    RETURN res;
  END;
  --
END;
/
