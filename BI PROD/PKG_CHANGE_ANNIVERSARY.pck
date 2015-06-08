CREATE OR REPLACE PACKAGE pkg_change_anniversary IS

  -- Author  : VESELEK
  -- Created : 15.05.2012 11:36:49
  -- Purpose : Изменения в годовщину

  TYPE info_cover IS RECORD(
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
  /*Проверяет наличие активной версии
  в годовщину с типом изменений Перераспределение
  или Увеличие взноса в годовщину*/
  FUNCTION check_exists_add(par_policy_id NUMBER) RETURN NUMBER;
  /*Проверка ограничений при переводе статуса*/
  PROCEDURE check_investor(par_policy_id NUMBER);
  /*Информация по покрытиям текущей и предыдущей версии*/
  FUNCTION get_cover_info(par_cover_id IN NUMBER) RETURN info_cover;
  /*Основная процедура пересчета Инвестор в годовщину:
  Проверка наличия типов изменений: Перераспределение или Увеличение взноса в годовщину;
  Набор данных (премия, страховая сумма, возраст, тариф и .т.д)
  по версиям, необходимым для расчета: обязательно первая, рассчитываемая и предыдущая рассчитываемой;
  Определение процентажа между премиями по программам;
  Определение пени за перераспределение взноса;
  Сохранение параметров по покрытиям;
  Сохранение необходимых данных для личного кабинета*/
  PROCEDURE increase_size_total_premium(par_policy_id IN NUMBER);
  /*Расчет весов для 2-ого и 3-его годов*/
  PROCEDURE get_weigth(par_policy_id IN NUMBER);
  /*Огромная куча апдейтов для получения всех необходимых значений
  для каждого года при изменении последовательно*/
  PROCEDURE another_update
  (
    par_policy_id  NUMBER
   ,par_prod_brief VARCHAR2
  );
  /*Расчет актуарных значений*/
  PROCEDURE actuar_value(par_policy_id NUMBER);
  /*Расчет помесячной доходности*/
  FUNCTION get_savings
  (
    par_cover_id       NUMBER
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_t              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_net_prem_act_2 NUMBER DEFAULT 0
   ,par_net_prem_act_3 NUMBER DEFAULT 0
  ) RETURN NUMBER;

  FUNCTION get_savings_investorplus
  (
    par_cover_id       NUMBER
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_t              NUMBER
   ,par_opt_brief      VARCHAR2
   ,par_n              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_net_prem_act_2 NUMBER DEFAULT 0
   ,par_net_prem_act_3 NUMBER DEFAULT 0
   ,par_net_prem_act_4 NUMBER DEFAULT 0
   ,par_net_prem_act_5 NUMBER DEFAULT 0
  ) RETURN NUMBER;
  /*Процедура пересчета стратегий по Инвестор с единовременной
  формой оплаты*/
  PROCEDURE change_strategy_investor_lump(par_policy_id NUMBER);
  /*Процедура набора параметров ДС по версиям*/
  PROCEDURE add_inform_cover
  (
    par_header_id  NUMBER
   ,par_val_period NUMBER
  );
  /**/
  PROCEDURE add_actuar_value(par_policy_id NUMBER);
  PROCEDURE add_get_weigth(par_period NUMBER);
  PROCEDURE add_another_update(par_period_id NUMBER);
  PROCEDURE update_investorplus(par_period_id NUMBER);
  FUNCTION get_savings_lump
  (
    par_opt_brief      VARCHAR2
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_t              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_cover_id       NUMBER
  ) RETURN NUMBER;
  /*Процедуры для квартальных изменений по Инвестор*/
  PROCEDURE inform_cover_quart
  (
    par_header_id  NUMBER
   ,par_val_period NUMBER
   ,par_policy_id  NUMBER
  );
  PROCEDURE actuar_value_quart(par_policy_id NUMBER);
  PROCEDURE get_weigth_quart(par_period NUMBER);
  PROCEDURE another_update_quart(par_period_id NUMBER);
  /*для единовременного при ежеквартальных изменениях*/
  FUNCTION get_savings_quart
  (
    par_opt_brief      VARCHAR2
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_period         NUMBER /*период*/
   ,par_t              NUMBER /*всегда 3, кроме последнего периода*/
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_cover_id       NUMBER
  ) RETURN NUMBER;
  /*для регулярного при ежеквартальных изменениях*/
  FUNCTION get_savings_reg_quart
  (
    par_opt_brief     VARCHAR2
   ,par_date_begin    DATE
   ,par_date_end      DATE
   ,par_period        NUMBER
   ,par_t             NUMBER
   ,par_change_year   NUMBER
   ,par_net_prem      NUMBER
   ,par_net_prem_prev NUMBER
   ,par_savings_prev  NUMBER
   ,par_cover_id      NUMBER
  ) RETURN NUMBER;
  PROCEDURE calc_investor_plus
  (
    par_pol_header NUMBER
   ,par_policy_id  NUMBER
   ,par_period     NUMBER
  );
END pkg_change_anniversary;
/
CREATE OR REPLACE PACKAGE BODY pkg_change_anniversary IS
  /*
    *********************************************
    * Создана по заявке: 250261: таблицы доходности
    * Определяет дату начала действия ДС по cover_id
    * @autor Чирков В.Ю.
    * @param PAR_COVER_ID - id покрытия ДС
    **********************************************
  */

  g_new_client_date DATE := to_date('01.10.2013', 'DD.MM.YYYY');

  FUNCTION getpolstartdatebycoverid(par_cover_id NUMBER) RETURN DATE IS
    v_pol_header_start_date DATE;
  BEGIN
    SELECT ph.start_date
      INTO v_pol_header_start_date
      FROM ins.p_cover      pc
          ,ins.as_asset     aa
          ,ins.p_policy     pp
          ,ins.p_pol_header ph
     WHERE pc.p_cover_id = par_cover_id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    RETURN v_pol_header_start_date;
  END getpolstartdatebycoverid;

  /**/
  /*
  Функция Контроль наличия активных изменений по Инвестор CONTROL_EXISTS_CHANGE_INVESTOR на создание допника
  Процедура на переход:
  Проверки перед созданием версии (Инвестор) PKG_CHANGE_ANNIVERSARY.CHECK_INVESTOR
  Перераспределение суммы премии (Инвестор) PKG_CHANGE_ANNIVERSARY.INCREASE_SIZE_TOTAL_PREMIUM
  */
  /**/
  FUNCTION get_cover_info(par_cover_id IN NUMBER) RETURN info_cover IS
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
    r_prev_version c_prev_version%ROWTYPE;
  
    RESULT info_cover;
  
  BEGIN
    OPEN c_prev_version(par_cover_id);
    FETCH c_prev_version
      INTO r_prev_version;
    -- При отсутствии предыдущей версии покрытия искуственно указываем, что это первая версия
    result.p_cover_id_prev := nvl(r_prev_version.p_cover_id_prev, par_cover_id);
    result.p_cover_id_curr := nvl(r_prev_version.p_cover_id_curr, par_cover_id);
  
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
  
    RETURN RESULT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_COVER_INFO: ' || SQLERRM);
  END;
  /**/
  FUNCTION check_exists_add(par_policy_id NUMBER) RETURN NUMBER IS
    v_pol_start_date        DATE;
    v_pol_header_id         NUMBER;
    is_exists_investor      NUMBER;
    is_exists_priority      NUMBER;
    v_pol_header_start_date DATE;
    is_exists_yield         NUMBER;
    v_cnt_brief             NUMBER;
    v_max_date              DATE;
  BEGIN
  
    SELECT pol.start_date
          ,ph.policy_header_id
          ,ph.start_date
          ,CASE
             WHEN upper(prod.brief) IN ('INVESTOR_LUMP_OLD'
                                       ,'INVESTOR'
                                       ,'INVESTOR_LUMP'
                                       ,'INVEST_IN_FUTURE'
                                       ,'INVESTORALFA'
                                       ,'INVESTORPLUS') THEN
              1
             WHEN upper(prod.brief) IN ('PRIORITY_INVEST(LUMP)', 'PRIORITY_INVEST(REGULAR)') THEN
              2
             ELSE
              0
           END cnt_brief
      INTO v_pol_start_date
          ,v_pol_header_id
          ,v_pol_header_start_date
          ,v_cnt_brief
      FROM ins.p_policy     pol
          ,ins.p_pol_header ph
          ,ins.t_product    prod
     WHERE pol.policy_id = par_policy_id
       AND pol.pol_header_id = ph.policy_header_id
       AND ph.product_id = prod.product_id;
    IF v_cnt_brief = 1
    THEN
      SELECT COUNT(*)
        INTO is_exists_investor
        FROM ins.p_policy            p
            ,ins.p_pol_addendum_type ppat
            ,ins.t_addendum_type     t
            ,ins.document            d
            ,ins.doc_status_ref      rf
       WHERE p.pol_header_id = v_pol_header_id
         AND p.start_date = v_pol_start_date
         AND ppat.p_policy_id = p.policy_id
         AND ppat.t_addendum_type_id = t.t_addendum_type_id
         AND t.brief IN ('CHANGE_STRATEGY_OF_THE_PREMIUM', 'INCREASE_SIZE_OF_THE_TOTAL_PREMIUM')
         AND p.policy_id != par_policy_id
         AND p.policy_id = d.document_id
         AND d.doc_status_ref_id = rf.doc_status_ref_id
         AND rf.brief != 'CANCEL';
      IF is_exists_investor > 0
      THEN
        pkg_forms_message.put_message('Внимание! Обнаружена активная версия изменения стратегий за проверяемый период (год), создание версии запрещено');
        raise_application_error(-20000, 'Ошибка');
      END IF;
    END IF;
    /**/
    IF v_cnt_brief = 2
    THEN
      BEGIN
        SELECT MAX(p.start_date)
          INTO v_max_date
          FROM ins.p_policy            p
              ,ins.p_pol_addendum_type ppat
              ,ins.t_addendum_type     t
              ,ins.document            d
              ,ins.doc_status_ref      rf
         WHERE p.pol_header_id = v_pol_header_id
           AND ppat.p_policy_id = p.policy_id
           AND ppat.t_addendum_type_id = t.t_addendum_type_id
           AND t.brief IN ('INCREASE_SIZE_QUARTER', 'CHANGE_STRATEGY_QUARTER')
           AND p.policy_id != par_policy_id
           AND p.policy_id = d.document_id
           AND d.doc_status_ref_id = rf.doc_status_ref_id
           AND rf.brief != 'CANCEL';
      EXCEPTION
        WHEN no_data_found THEN
          v_max_date := to_date('01.01.1999', 'DD.MM.YYYY');
      END;
      SELECT CASE
               WHEN MONTHS_BETWEEN(v_pol_start_date, v_pol_header_start_date) -
                    FLOOR(MONTHS_BETWEEN(v_max_date, v_pol_header_start_date)) < 3 THEN
                1
               ELSE
                0
             END
        INTO is_exists_priority
        FROM dual;
      IF is_exists_priority > 0
      THEN
        pkg_forms_message.put_message('Внимание! Обнаружена активная версия изменения стратегий за проверяемый период (квартал), создание версии запрещено');
        raise_application_error(-20000, 'Ошибка');
      END IF;
    END IF;
    /**/
  
    --Чирков/добавлено условие/ по заявке 250261: таблицы доходности
    IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
    THEN
      SELECT COUNT(*)
        INTO is_exists_yield
        FROM ins.t_reference_yield_profile ty
       WHERE ty.t_date_yield = trunc(v_pol_header_start_date, 'MM');
    ELSE
      SELECT COUNT(*)
        INTO is_exists_yield
        FROM ins.t_reference_yield ty
       WHERE ty.t_date_yield = trunc(v_pol_header_start_date, 'MM');
    END IF;
    --
  
    IF is_exists_yield = 0
    THEN
      pkg_forms_message.put_message('Внимание! На дату начала договора страхования не обнаружены ставки доходности, создание версии невозможно');
      raise_application_error(-20000, 'Ошибка');
    END IF;
  
    RETURN 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_COVER_INFO: ' || SQLERRM);
  END;
  /**/
  PROCEDURE check_investor(par_policy_id NUMBER) IS
    proc_name            VARCHAR2(25) := 'CHECK_INVESTOR';
    is_continue          NUMBER;
    is_addendum_change   NUMBER;
    is_addendum_increase NUMBER;
    v_sum_investor       NUMBER;
    no_role_cover    EXCEPTION;
    no_role_sum      EXCEPTION;
    no_decrease_sum  EXCEPTION;
    no_premium_cover EXCEPTION;
    v_progr      VARCHAR2(255);
    v_sum_after  NUMBER;
    v_sum_before NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO is_continue
      FROM ins.p_policy     pol
          ,ins.p_pol_header ph
          ,ins.t_product    prod
     WHERE pol.pol_header_id = ph.policy_header_id
       AND ph.product_id = prod.product_id
       AND prod.brief IN ('Investor')
       AND pol.policy_id = par_policy_id;
  
    IF is_continue > 0
    THEN
    
      SELECT nvl(SUM(nvl(pc.fee, 0)), 0)
        INTO v_sum_investor
        FROM ins.p_policy           pp
            ,ins.as_asset           a
            ,ins.p_cover            pc
            ,ins.t_prod_line_option opt
            ,ins.t_product_line     pl
            ,ins.t_lob_line         lb
            ,ins.t_lob              l
       WHERE pp.policy_id = par_policy_id
         AND pp.policy_id = a.p_policy_id
         AND a.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = opt.id
         AND opt.product_line_id = pl.id
         AND pl.description NOT IN
             ('Административные издержки'
             ,'Административные издержки на восстановление')
         AND pl.t_lob_line_id = lb.t_lob_line_id
         AND lb.t_lob_id = l.t_lob_id
         AND lb.brief != 'Penalty'
         AND l.brief != 'Acc';
    
      FOR cur IN (SELECT nvl(pc.fee, 0) ins_premium
                        ,opt.description progr
                    FROM ins.p_policy           pp
                        ,ins.as_asset           a
                        ,ins.p_cover            pc
                        ,ins.t_prod_line_option opt
                        ,ins.t_product_line     pl
                        ,ins.t_lob_line         lb
                        ,ins.t_lob              l
                   WHERE pp.policy_id = par_policy_id
                     AND pp.policy_id = a.p_policy_id
                     AND a.as_asset_id = pc.as_asset_id
                     AND pc.t_prod_line_option_id = opt.id
                     AND opt.product_line_id = pl.id
                     AND pl.description NOT IN
                         ('Административные издержки'
                         ,'Административные издержки на восстановление')
                     AND pl.t_lob_line_id = lb.t_lob_line_id
                     AND lb.t_lob_id = l.t_lob_id
                     AND lb.brief != 'Penalty'
                     AND l.brief != 'Acc')
      
      LOOP
        IF cur.ins_premium < v_sum_investor * 0.1
        THEN
          v_progr := cur.progr;
          RAISE no_role_cover;
        END IF;
      END LOOP;
    
      SELECT COUNT(*)
        INTO is_addendum_change
        FROM ins.p_policy pol
       WHERE pol.policy_id = par_policy_id
         AND EXISTS (SELECT NULL
                FROM ins.p_pol_addendum_type ppat
                    ,ins.t_addendum_type     t
               WHERE ppat.p_policy_id = pol.policy_id
                 AND ppat.t_addendum_type_id = t.t_addendum_type_id
                 AND t.brief = 'CHANGE_STRATEGY_OF_THE_PREMIUM');
      SELECT COUNT(*)
        INTO is_addendum_increase
        FROM ins.p_policy pol
       WHERE pol.policy_id = par_policy_id
         AND EXISTS (SELECT NULL
                FROM ins.p_pol_addendum_type ppat
                    ,ins.t_addendum_type     t
               WHERE ppat.p_policy_id = pol.policy_id
                 AND ppat.t_addendum_type_id = t.t_addendum_type_id
                 AND t.brief = 'INCREASE_SIZE_OF_THE_TOTAL_PREMIUM');
      SELECT nvl(SUM(nvl(pc.fee, 0)), 0)
        INTO v_sum_after
        FROM ins.p_policy pp
            ,ins.as_asset a
            ,ins.p_cover  pc
       WHERE pp.policy_id = par_policy_id
         AND pp.policy_id = a.p_policy_id
         AND a.as_asset_id = pc.as_asset_id;
      SELECT nvl(SUM(nvl(pc.fee, 0)), 0)
        INTO v_sum_before
        FROM ins.p_policy pp
            ,ins.p_policy pol
            ,ins.as_asset a
            ,ins.p_cover  pc
       WHERE pp.policy_id = par_policy_id
         AND pol.pol_header_id = pp.pol_header_id
         AND pol.policy_id = pp.prev_ver_id
         AND pol.policy_id = a.p_policy_id
         AND a.as_asset_id = pc.as_asset_id;
    
      IF (is_addendum_change > 0 AND is_addendum_increase = 0)
      THEN
        IF v_sum_after != v_sum_before
        THEN
          RAISE no_role_sum;
        END IF;
      ELSIF (is_addendum_change = 0 AND is_addendum_increase > 0)
      THEN
        FOR cur IN (SELECT nvl(pc.fee, 0) ins_premium
                          ,opt.description progr
                          ,ver_pred.ins_premium ins_premium_pred
                      FROM ins.p_policy pp
                          ,ins.as_asset a
                          ,ins.p_cover pc
                          ,ins.t_prod_line_option opt
                          ,ins.t_product_line pl
                          ,ins.t_lob_line lb
                          ,(SELECT nvl(pcr.fee, 0) ins_premium
                                  ,optr.product_line_id
                              FROM ins.p_policy           ppr
                                  ,ins.p_policy           polr
                                  ,ins.as_asset           ar
                                  ,ins.p_cover            pcr
                                  ,ins.t_prod_line_option optr
                             WHERE ppr.policy_id = par_policy_id
                               AND polr.pol_header_id = ppr.pol_header_id
                               AND polr.policy_id = ppr.prev_ver_id
                               AND polr.policy_id = ar.p_policy_id
                               AND ar.as_asset_id = pcr.as_asset_id
                               AND pcr.t_prod_line_option_id = optr.id) ver_pred
                     WHERE pp.policy_id = par_policy_id
                       AND pp.policy_id = a.p_policy_id
                       AND a.as_asset_id = pc.as_asset_id
                       AND pc.t_prod_line_option_id = opt.id
                       AND opt.product_line_id = pl.id
                       AND pl.description NOT IN
                           ('Административные издержки'
                           ,'Административные издержки на восстановление')
                       AND pl.t_lob_line_id = lb.t_lob_line_id
                       AND lb.brief != 'Penalty'
                       AND ver_pred.product_line_id = opt.product_line_id)
        
        LOOP
          IF cur.ins_premium < cur.ins_premium_pred
          THEN
            v_progr := cur.progr;
            RAISE no_premium_cover;
          END IF;
        END LOOP;
      ELSIF (is_addendum_change > 0 AND is_addendum_increase > 0)
      THEN
        IF v_sum_after < v_sum_before
        THEN
          RAISE no_decrease_sum;
        END IF;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN no_role_cover THEN
      raise_application_error(-20001
                             ,'Внимание! Размер взноса по программе ' || v_progr ||
                              ' не может быть меньше 10% от взноса по договору. Перевод в статус Новый невозможен.');
    WHEN no_decrease_sum THEN
      raise_application_error(-20001
                             ,'Внимание! Размер общего брутто-взноса не должен уменьшиться. Перевод в статус Новый невозможен.');
    WHEN no_role_sum THEN
      raise_application_error(-20001
                             ,'Внимание! Размер общего брутто-взноса не должен измениться. Перевод в статус Новый невозможен.');
    WHEN no_premium_cover THEN
      raise_application_error(-20001
                             ,'Внимание! Размер брутто-взноса по программе ' || v_progr ||
                              ' не должен уменьшиться. Перевод в статус Новый невозможен.');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' || SQLERRM);
  END check_investor;
  /**/
  PROCEDURE increase_size_total_premium(par_policy_id NUMBER) IS
    proc_name          VARCHAR2(27) := 'INCREASE_SIZE_TOTAL_PREMIUM';
    proc_penalty       NUMBER := 0.03;
    is_continue_annual NUMBER;
    is_continue_quart  NUMBER;
    pv_pol_header_id   NUMBER;
    pv_prod_brief      VARCHAR2(255);
    pv_val_period      NUMBER;
    v_ins_amount       NUMBER;
  BEGIN
  
    BEGIN
      SELECT upper(prod.brief)
        INTO pv_prod_brief
        FROM ins.p_policy     pol
            ,ins.p_pol_header ph
            ,ins.t_product    prod
       WHERE pol.policy_id = par_policy_id
         AND pol.pol_header_id = ph.policy_header_id
         AND ph.product_id = prod.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        pv_prod_brief := 'Не определен';
    END;
  
    IF pv_prod_brief IN ('INVESTOR_LUMP'
                        ,'INVESTOR_LUMP_OLD'
                        ,'PRIORITY_INVEST(LUMP)'
                        ,'INVEST_IN_FUTURE'
                        ,'INVESTOR_LUMP_ALPHA'
                        ,'INVESTOR_LUMP_AKBARS'
                        ,'INVESTOR_LUMP_GLOBEKS'
                        ,'INVESTOR_LUMP_VTB5'
                        ,'INVESTOR_LUMP_HKF5'
                        ,'INVESTOR_LUMP_TATFOND'
                        ,'INVESTOR_LUMP_HKF3')
    THEN
      ins.pkg_change_anniversary.change_strategy_investor_lump(par_policy_id);
    ELSE
    
      SELECT COUNT(*)
        INTO is_continue_annual
        FROM ins.p_policy            pol
            ,ins.p_pol_addendum_type ppat
            ,ins.t_addendum_type     t
            ,ins.p_pol_header        ph
            ,ins.t_product           prod
       WHERE pol.policy_id = ppat.p_policy_id
         AND ppat.t_addendum_type_id = t.t_addendum_type_id
         AND t.brief IN ('INCREASE_SIZE_OF_THE_TOTAL_PREMIUM', 'CHANGE_STRATEGY_OF_THE_PREMIUM')
         AND pol.pol_header_id = ph.policy_header_id
         AND ph.product_id = prod.product_id
         AND upper(prod.brief) IN ('INVESTOR', 'INVESTORALFA', 'INVESTORPLUS')
         AND pol.policy_id = par_policy_id;
      SELECT COUNT(*)
        INTO is_continue_quart
        FROM ins.p_policy            pol
            ,ins.p_pol_addendum_type ppat
            ,ins.t_addendum_type     t
            ,ins.p_pol_header        ph
            ,ins.t_product           prod
       WHERE pol.policy_id = ppat.p_policy_id
         AND ppat.t_addendum_type_id = t.t_addendum_type_id
         AND t.brief IN ('INCREASE_SIZE_QUARTER', 'CHANGE_STRATEGY_QUARTER')
         AND pol.pol_header_id = ph.policy_header_id
         AND ph.product_id = prod.product_id
         AND upper(prod.brief) = 'PRIORITY_INVEST(REGULAR)'
         AND pol.policy_id = par_policy_id;
      BEGIN
        SELECT p.pol_header_id
              ,MONTHS_BETWEEN(trunc(p.end_date) + 1, ph.start_date) / 12
          INTO pv_pol_header_id
              ,pv_val_period
          FROM ins.p_policy     p
              ,ins.p_pol_header ph
         WHERE p.policy_id = par_policy_id
           AND p.pol_header_id = ph.policy_header_id;
      EXCEPTION
        WHEN no_data_found THEN
          pv_pol_header_id := 0;
      END;
      IF is_continue_annual > 0
      THEN
        IF pv_prod_brief = 'INVESTORPLUS'
        THEN
          ins.pkg_change_anniversary.calc_investor_plus(pv_pol_header_id
                                                       ,par_policy_id
                                                       ,pv_val_period);
        ELSE
          DELETE FROM ins.t_inform_cover;
          /**/
          INSERT INTO ins.t_inform_cover
            (opt_brief
            ,ver1_cover_id
            ,cur_cover_id
            ,old_cover_id
            ,ver1_policy_id
            ,cur_policy_id
            ,old_policy_id
            ,start_date
            ,end_date
            ,ver1_amount
            ,ver1_prem
            ,ver1_fee
            ,ver1_pl_id
            ,ver1_sum_prem
            ,cur_ins_amount
            ,cur_premium
            ,cur_fee
            ,cur_pl_id
            ,cur_sum_prem
            ,old_ins_amount
            ,old_premium
            ,old_fee
            ,old_pl_id
            ,old_sum_prem
            ,deathrate_id
            ,fact_yield_rate
            ,sex
            ,age
            ,f_loading
            ,const_tariff
            ,change_year)
            SELECT opt.brief opt_brief
                  ,pc.p_cover_id ver1_cover_id
                  ,cur_param.p_cover_id cur_cover_id
                  ,nvl(old_param.p_cover_id, old_param_ver1.p_cover_id) old_cover_id
                  ,pol.policy_id ver1_policy_id
                  ,cur_param.policy_id cur_policy_id
                  ,nvl(old_param.policy_id, old_param_ver1.policy_id) old_policy_id
                  ,ph.start_date
                  ,pol.end_date
                  ,
                   /**/pc.ins_amount ver1_amount
                  ,pc.premium ver1_prem
                  ,pc.fee ver1_fee
                  ,pl.id ver1_pl_id
                  ,(SELECT SUM(pca.fee)
                      FROM ins.p_cover            pca
                          ,ins.t_prod_line_option opta
                          ,ins.t_product_line     pla
                          ,ins.t_lob_line         lb
                     WHERE pca.as_asset_id = a.as_asset_id
                       AND pca.t_prod_line_option_id = opta.id
                       AND opta.product_line_id = pla.id
                       AND pla.description NOT IN
                           ('Административные издержки'
                           ,'Административные издержки на восстановление')
                       AND pla.t_lob_line_id = lb.t_lob_line_id
                       AND lb.brief != 'Penalty'
                       AND lb.t_lob_id NOT IN
                           (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) ver1_sum_prem
                  ,
                   /**/cur_param.ins_amount   cur_ins_amount
                  ,cur_param.premium      cur_premium
                  ,cur_param.fee          cur_fee
                  ,cur_param.pl_id        cur_pl_id
                  ,cur_param.cur_sum_prem
                  ,
                   /**/nvl(old_param.ins_amount, old_param_ver1.ins_amount) old_ins_amount
                  ,nvl(old_param.premium, old_param_ver1.premium) old_premium
                  ,nvl(old_param.fee, old_param_ver1.fee) old_fee
                  ,nvl(old_param.pl_id, old_param_ver1.pl_id) old_pl_id
                  ,nvl(old_param.old_sum_prem, old_param_ver1.old_sum_prem) old_sum_prem
                  ,
                   /**/decode(plr.func_id
                         ,NULL
                         ,plr.deathrate_id
                         ,ins.pkg_tariff_calc.calc_fun(plr.func_id
                                                      ,ins.ent.id_by_brief('P_COVER')
                                                      ,pc.p_cover_id)) deathrate_id
                  ,pc.normrate_value fact_yield_rate
                  ,decode(per.gender, 0, 'w', 1, 'm') sex
                  ,pc.insured_age age
                  ,pc.rvb_value
                  ,CASE opt.brief
                     WHEN 'PEPR_A' THEN
                      2.9743
                     WHEN 'PEPR_C' THEN
                      3.21
                     WHEN 'PEPR_B' THEN
                      3.028
                   END const_tariff
                  ,CASE
                     WHEN MONTHS_BETWEEN(cur_param.start_date, ph.start_date) / 12 + 1 = 3 THEN
                      2
                     ELSE
                      3
                   END
              FROM ins.p_policy pol
                  ,ins.p_pol_header ph
                  ,ins.as_asset a
                  ,ins.as_assured ass
                  ,ins.cn_person per
                  ,ins.p_cover pc
                  ,ins.t_prod_line_option opt
                  ,ins.t_product_line pl
                  ,ins.t_lob_line lba
                  ,ins.t_prod_line_rate plr
                  ,(SELECT pold.pol_header_id
                          ,pcd.ins_amount
                          ,pcd.premium
                          ,pcd.fee
                          ,pld.id pl_id
                          ,pcd.p_cover_id
                          ,pold.policy_id
                          ,pold.version_num
                          ,(SELECT SUM(pcad.fee)
                              FROM ins.p_cover            pcad
                                  ,ins.t_prod_line_option optad
                                  ,ins.t_product_line     plad
                                  ,ins.t_lob_line         lb
                             WHERE pcad.as_asset_id = ad.as_asset_id
                               AND pcad.t_prod_line_option_id = optad.id
                               AND optad.product_line_id = plad.id
                               AND plad.description NOT IN
                                   ('Административные издержки'
                                   ,'Административные издержки на восстановление')
                               AND plad.t_lob_line_id = lb.t_lob_line_id
                               AND lb.brief != 'Penalty'
                               AND lb.t_lob_id NOT IN
                                   (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) cur_sum_prem
                          ,pold.start_date
                      FROM ins.p_policy           pold
                          ,ins.as_asset           ad
                          ,ins.p_cover            pcd
                          ,ins.t_prod_line_option optd
                          ,ins.t_product_line     pld
                          ,ins.t_lob_line         lbd
                     WHERE pold.policy_id = ad.p_policy_id
                       AND ad.as_asset_id = pcd.as_asset_id
                       AND pcd.t_prod_line_option_id = optd.id
                       AND optd.product_line_id = pld.id
                       AND pold.policy_id = par_policy_id
                       AND pld.description NOT IN
                           ('Административные издержки'
                           ,'Административные издержки на восстановление')
                       AND pld.t_lob_line_id = lbd.t_lob_line_id
                       AND lbd.brief != 'Penalty'
                       AND lbd.t_lob_id NOT IN
                           (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) cur_param
                  ,(SELECT pold.pol_header_id
                          ,pcd.ins_amount
                          ,pcd.premium
                          ,pcd.fee
                          ,pld.id pl_id
                          ,pcd.p_cover_id
                          ,pold.policy_id
                          ,pold.version_num
                          ,(SELECT SUM(pcad.fee)
                              FROM ins.p_cover            pcad
                                  ,ins.t_prod_line_option optad
                                  ,ins.t_product_line     plad
                                  ,ins.t_lob_line         lb
                             WHERE pcad.as_asset_id = ad.as_asset_id
                               AND pcad.t_prod_line_option_id = optad.id
                               AND optad.product_line_id = plad.id
                               AND plad.description NOT IN
                                   ('Административные издержки'
                                   ,'Административные издержки на восстановление')
                               AND plad.t_lob_line_id = lb.t_lob_line_id
                               AND lb.brief != 'Penalty'
                               AND lb.t_lob_id NOT IN
                                   (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) old_sum_prem
                      FROM ins.p_policy           pold
                          ,ins.as_asset           ad
                          ,ins.p_cover            pcd
                          ,ins.t_prod_line_option optd
                          ,ins.t_product_line     pld
                          ,ins.t_lob_line         lbd
                          ,ins.p_pol_header       phd
                          ,ins.document           d
                          ,ins.doc_status_ref     rf
                     WHERE pold.policy_id = ad.p_policy_id
                       AND ad.as_asset_id = pcd.as_asset_id
                       AND pold.policy_id = d.document_id
                       AND d.doc_status_ref_id = rf.doc_status_ref_id
                       AND rf.brief != 'CANCEL'
                       AND pcd.t_prod_line_option_id = optd.id
                       AND optd.product_line_id = pld.id
                       AND pold.pol_header_id = pv_pol_header_id
                       AND pold.version_num != 1
                       AND pold.pol_header_id = phd.policy_header_id
                       AND pold.start_date = ADD_MONTHS(phd.start_date, 12)
                       AND pld.description NOT IN
                           ('Административные издержки'
                           ,'Административные издержки на восстановление')
                       AND pld.t_lob_line_id = lbd.t_lob_line_id
                       AND lbd.brief != 'Penalty'
                       AND lbd.t_lob_id NOT IN
                           (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')
                          /*AND pold.policy_id != PAR_POLICY_ID*/
                       AND pold.start_date = (SELECT MAX(ppl.start_date)
                                                FROM ins.p_policy       ppl
                                                    ,ins.document       da
                                                    ,ins.doc_status_ref rfa
                                               WHERE ppl.pol_header_id = pv_pol_header_id
                                                 AND ppl.start_date = ADD_MONTHS(phd.start_date, 12)
                                                 AND ppl.policy_id = da.document_id
                                                 AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                                 AND rfa.brief != 'CANCEL'
                                              /*AND ppl.policy_id != PAR_POLICY_ID*/
                                              )) old_param
                  ,(SELECT pold.pol_header_id
                          ,pcd.ins_amount
                          ,pcd.premium
                          ,pcd.fee
                          ,pld.id pl_id
                          ,pcd.p_cover_id
                          ,pold.policy_id
                          ,pold.version_num
                          ,(SELECT SUM(pcad.fee)
                              FROM ins.p_cover            pcad
                                  ,ins.t_prod_line_option optad
                                  ,ins.t_product_line     plad
                                  ,ins.t_lob_line         lb
                             WHERE pcad.as_asset_id = ad.as_asset_id
                               AND pcad.t_prod_line_option_id = optad.id
                               AND optad.product_line_id = plad.id
                               AND plad.description NOT IN
                                   ('Административные издержки'
                                   ,'Административные издержки на восстановление')
                               AND plad.t_lob_line_id = lb.t_lob_line_id
                               AND lb.brief != 'Penalty'
                               AND lb.t_lob_id NOT IN
                                   (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) old_sum_prem
                      FROM ins.p_policy           pold
                          ,ins.as_asset           ad
                          ,ins.p_cover            pcd
                          ,ins.t_prod_line_option optd
                          ,ins.t_product_line     pld
                          ,ins.t_lob_line         lbd
                     WHERE pold.policy_id = ad.p_policy_id
                       AND ad.as_asset_id = pcd.as_asset_id
                       AND pcd.t_prod_line_option_id = optd.id
                       AND optd.product_line_id = pld.id
                       AND pld.description NOT IN
                           ('Административные издержки'
                           ,'Административные издержки на восстановление')
                       AND pld.t_lob_line_id = lbd.t_lob_line_id
                       AND lbd.brief != 'Penalty'
                       AND lbd.t_lob_id NOT IN
                           (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')
                       AND pold.pol_header_id = pv_pol_header_id
                       AND pold.version_num = 1) old_param_ver1
             WHERE pol.pol_header_id = pv_pol_header_id
               AND pol.pol_header_id = ph.policy_header_id
               AND pol.policy_id = a.p_policy_id
               AND a.as_asset_id = pc.as_asset_id
               AND a.as_asset_id = ass.as_assured_id
               AND ass.assured_contact_id = per.contact_id(+)
               AND pc.t_prod_line_option_id = opt.id
               AND opt.product_line_id = pl.id
               AND plr.product_line_id = pl.id
               AND pl.description NOT IN
                   ('Административные издержки'
                   ,'Административные издержки на восстановление')
               AND pl.t_lob_line_id = lba.t_lob_line_id
               AND lba.brief != 'Penalty'
               AND lba.t_lob_id NOT IN (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')
               AND pol.version_num = 1
                  /**/
               AND cur_param.pl_id = pl.id
                  /**/
               AND old_param.pl_id(+) = pl.id
                  /**/
               AND old_param_ver1.pl_id(+) = pl.id;
          /**/
          UPDATE ins.t_inform_cover cv
             SET cv.perc_first_year  = cv.ver1_fee / cv.ver1_sum_prem * 100
                ,cv.perc_second_year = (CASE
                                         WHEN cv.change_year = 2 THEN
                                          cv.old_fee / cv.old_sum_prem * 100
                                         ELSE
                                          cv.cur_fee / cv.cur_sum_prem * 100
                                       END)
                ,cv.perc_third_year = (CASE
                                        WHEN cv.change_year = 2 THEN
                                         cv.cur_fee / cv.cur_sum_prem * 100
                                        ELSE
                                         cv.old_fee / cv.old_sum_prem * 100
                                      END)
                ,
                 /*cv.cur_fee / cv.cur_sum_prem * 100,*/cv.pen_first_year  = 0
                ,cv.pen_second_year = (CASE
                                        WHEN cv.change_year = 2 THEN
                                         greatest(cv.ver1_fee -
                                                  cv.old_sum_prem * (cv.old_fee / cv.old_sum_prem)
                                                 ,0) * proc_penalty
                                        ELSE
                                         greatest(cv.ver1_fee -
                                                  cv.cur_sum_prem * (cv.cur_fee / cv.cur_sum_prem)
                                                 ,0) * proc_penalty
                                      END)
                ,cv.pen_third_year  = greatest(cv.old_fee -
                                               cv.cur_sum_prem * (cv.cur_fee / cv.cur_sum_prem)
                                              ,0) * proc_penalty;
          /**/
          pkg_change_anniversary.actuar_value(par_policy_id);
          pkg_change_anniversary.get_weigth(par_policy_id);
          pkg_change_anniversary.another_update(par_policy_id, pv_prod_brief);
        
          UPDATE /*+ USE_NL(p cva)*/ ins. /*ven_*/ p_cover p
             SET (p.ins_amount
                ,p.is_handchange_amount
                ,p.is_handchange_tariff
                ,p.is_handchange_fee
                ,p.is_handchange_premium) =
                 (SELECT ROUND(cv.s3, 0)
                        ,1
                        ,1
                        ,1
                        ,1
                    FROM ins.t_inform_cover cv
                   WHERE p.p_cover_id = cv.cur_cover_id)
           WHERE EXISTS
           (SELECT NULL FROM ins.t_inform_cover cva WHERE p.p_cover_id = cva.cur_cover_id);
        
          /**/
          DELETE FROM ins.p_pol_change ch WHERE ch.p_policy_id = par_policy_id;
          INSERT INTO ins.p_pol_change
            (p_pol_change_id
            ,p_policy_id
            ,p_cover_id
            ,t_prod_line_id
            ,net_premium_act
            ,acc_net_prem_after_change
            ,delta_deposit1
            ,delta_deposit2
            ,penalty
            ,par_t
            ,start_date_pc
            ,end_date_pc
            ,ins_amount
            ,fee)
            SELECT sq_p_pol_change.nextval
                  ,cv.cur_policy_id
                  ,cv.cur_cover_id
                  ,ta.t_product_line_id
                  ,ta.net_prem_act
                  ,CASE
                     WHEN ta.par_t = 1 THEN
                      ta.net_prem_act
                     WHEN ta.par_t = 2 THEN
                      (CASE
                        WHEN ta.net_prem_act != 0 THEN
                         (SELECT SUM(v.net_prem_act)
                            FROM ins.t_actuar_value v
                           WHERE v.par_t IN (1, 2)
                             AND v.p_cover_id = ta.p_cover_id) + cv.delta_deposit1
                        ELSE
                         0
                      END)
                     WHEN ta.par_t = 3 THEN
                      (CASE
                        WHEN ta.net_prem_act != 0 THEN
                         (SELECT SUM(v.net_prem_act)
                            FROM ins.t_actuar_value v
                           WHERE v.par_t IN (1, 2, 3)
                             AND v.p_cover_id = ta.p_cover_id) + cv.delta_deposit2
                        ELSE
                         0
                      END)
                   END
                  ,cv.delta_deposit1
                  ,cv.delta_deposit2
                  ,CASE
                     WHEN ta.par_t = 1 THEN
                      cv.pen_first_year
                     WHEN ta.par_t = 2 THEN
                      cv.pen_second_year
                     WHEN ta.par_t = 3 THEN
                      cv.pen_third_year
                     ELSE
                      0
                   END
                  ,ta.par_t
                  ,cv.start_date
                  ,cv.end_date
                  ,CASE
                     WHEN ta.par_t = 1 THEN
                      ta.sa
                     WHEN ta.par_t = 2 THEN
                      ROUND(cv.s2, 2)
                     WHEN ta.par_t = 3 THEN
                      ROUND(cv.s3, 2)
                     ELSE
                      0
                   END
                  ,CASE
                     WHEN ta.par_t = 1 THEN
                      cv.ver1_fee
                     WHEN ta.par_t = 2 THEN
                      (CASE
                        WHEN cv.change_year = 2 THEN
                         cv.old_fee
                        ELSE
                         cv.cur_fee
                      END) /*NVL(cv.old_fee,cv.cur_fee)*/
                     WHEN ta.par_t = 3 THEN
                      (CASE
                        WHEN cv.change_year = 3 THEN
                         cv.old_fee
                        ELSE
                         cv.cur_fee
                      END) /*cv.cur_fee*/
                     ELSE
                      0
                   END
              FROM ins.t_actuar_value ta
                  ,ins.t_inform_cover cv
             WHERE ta.par_t != 0
               AND ta.p_cover_id = cv.ver1_cover_id;
          /**/
        END IF;
      END IF;
      IF is_continue_quart > 0
      THEN
      
        DELETE FROM ins.t_inform_cover_lump;
        /**/
        ins.pkg_change_anniversary.inform_cover_quart(pv_pol_header_id, pv_val_period, par_policy_id);
        ins.pkg_change_anniversary.actuar_value_quart(par_policy_id);
        ins.pkg_change_anniversary.get_weigth_quart(pv_val_period * 4);
        ins.pkg_change_anniversary.another_update_quart(pv_val_period * 4);
        /**/
        UPDATE /*+ USE_NL(p v)*/ ins.p_cover p
           SET (p.ins_amount
              ,p.is_handchange_amount
              ,p.is_handchange_tariff
              ,p.is_handchange_fee
              ,p.is_handchange_premium) =
               (SELECT ROUND(va.s1, 0)
                      ,1
                      ,1
                      ,1
                      ,1
                  FROM ins.t_actuar_value      va
                      ,ins.t_inform_cover_lump lp
                 WHERE p.p_cover_id = lp.cover_id
                   AND lp.opt_brief = va.opt_brief
                   AND lp.quart_value = va.par_quart
                   AND lp.is_change = 1)
         WHERE EXISTS (SELECT NULL
                  FROM ins.t_actuar_value      v
                      ,ins.t_inform_cover_lump lpv
                 WHERE p.p_cover_id = lpv.cover_id
                   AND lpv.opt_brief = v.opt_brief
                   AND lpv.quart_value = v.par_quart
                   AND lpv.is_change = 1);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' || SQLERRM);
  END increase_size_total_premium;
  /**/
  PROCEDURE calc_investor_plus
  (
    par_pol_header NUMBER
   ,par_policy_id  NUMBER
   ,par_period     NUMBER
  ) IS
    proc_name VARCHAR2(20) := 'CALC_INVESTOR_PLUS';
  BEGIN
    DELETE FROM ins.t_inform_cover_lump;
    ins.pkg_change_anniversary.add_inform_cover(par_pol_header, par_period);
    ins.pkg_change_anniversary.add_actuar_value(par_policy_id);
    ins.pkg_change_anniversary.add_get_weigth(par_period);
    ins.pkg_change_anniversary.update_investorplus(par_period);
  
    UPDATE /*+ USE_NL(p cva)*/ ins.p_cover p
       SET (p.ins_amount
          ,p.is_handchange_amount
          ,p.is_handchange_tariff
          ,p.is_handchange_fee
          ,p.is_handchange_premium) =
           (SELECT ROUND(va.s1, 0)
                  ,1
                  ,1
                  ,1
                  ,1
              FROM ins.t_actuar_value      va
                  ,ins.t_inform_cover_lump lp
             WHERE p.p_cover_id = lp.cover_id
               AND va.par_t = par_period
               AND lp.opt_brief = va.opt_brief
               AND lp.change_year = va.par_t)
     WHERE EXISTS (SELECT NULL
              FROM ins.t_actuar_value      v
                  ,ins.t_inform_cover_lump lpv
             WHERE p.p_cover_id = lpv.cover_id
               AND v.par_t = par_period
               AND lpv.opt_brief = v.opt_brief
               AND lpv.change_year = v.par_t);
  
    DELETE FROM ins.p_pol_change ch WHERE ch.p_policy_id = par_policy_id;
    INSERT INTO ins.p_pol_change
      (p_pol_change_id
      ,p_policy_id
      ,p_cover_id
      ,t_prod_line_id
      ,net_premium_act
      ,acc_net_prem_after_change
      ,delta_deposit1
      ,delta_deposit2
      ,delta_deposit3
      ,delta_deposit4
      ,penalty
      ,par_t
      ,start_date_pc
      ,end_date_pc
      ,ins_amount
      ,fee)
      SELECT sq_p_pol_change.nextval
            ,par_policy_id policy_id /*ta.policy_id*/
            ,ta.p_cover_id
            ,cv.pl_id t_product_line_id
            ,ta.net_prem_act
            ,CASE
               WHEN ta.par_t = 1 THEN
                ta.net_prem_act
               WHEN ta.par_t = 2 THEN
                (CASE
                  WHEN ta.net_prem_act != 0 THEN
                   (SELECT SUM(v.net_prem_act)
                      FROM ins.t_actuar_value v
                     WHERE v.par_t IN (1, 2)
                       AND v.p_cover_id = ta.p_cover_id) +
                   (SELECT lp.delta_deposit
                      FROM ins.t_inform_cover_lump lp
                     WHERE lp.opt_brief = cv.opt_brief
                       AND lp.change_year = 2)
                  ELSE
                   0
                END)
               WHEN ta.par_t = 3 THEN
                (CASE
                  WHEN ta.net_prem_act != 0 THEN
                   (SELECT SUM(v.net_prem_act)
                      FROM ins.t_actuar_value v
                     WHERE v.par_t IN (1, 2, 3)
                       AND v.p_cover_id = ta.p_cover_id) +
                   (SELECT lp.delta_deposit
                      FROM ins.t_inform_cover_lump lp
                     WHERE lp.opt_brief = cv.opt_brief
                       AND lp.change_year = 3)
                  ELSE
                   0
                END)
               WHEN ta.par_t = 4 THEN
                (CASE
                  WHEN ta.net_prem_act != 0 THEN
                   (SELECT SUM(v.net_prem_act)
                      FROM ins.t_actuar_value v
                     WHERE v.par_t IN (1, 2, 3, 4)
                       AND v.p_cover_id = ta.p_cover_id) +
                   (SELECT lp.delta_deposit
                      FROM ins.t_inform_cover_lump lp
                     WHERE lp.opt_brief = cv.opt_brief
                       AND lp.change_year = 4)
                  ELSE
                   0
                END)
               WHEN ta.par_t = 5 THEN
                (CASE
                  WHEN ta.net_prem_act != 0 THEN
                   (SELECT SUM(v.net_prem_act)
                      FROM ins.t_actuar_value v
                     WHERE v.par_t IN (1, 2, 3, 4, 5)
                       AND v.p_cover_id = ta.p_cover_id) +
                   (SELECT lp.delta_deposit
                      FROM ins.t_inform_cover_lump lp
                     WHERE lp.opt_brief = cv.opt_brief
                       AND lp.change_year = 5)
                  ELSE
                   0
                END)
             END
            ,(SELECT lp.delta_deposit
                FROM ins.t_inform_cover_lump lp
               WHERE lp.opt_brief = cv.opt_brief
                 AND lp.change_year = 2) delta_deposit1
            ,(SELECT lp.delta_deposit
                FROM ins.t_inform_cover_lump lp
               WHERE lp.opt_brief = cv.opt_brief
                 AND lp.change_year = 3) delta_deposit2
            ,(SELECT lp.delta_deposit
                FROM ins.t_inform_cover_lump lp
               WHERE lp.opt_brief = cv.opt_brief
                 AND lp.change_year = 4) delta_deposit3
            ,(SELECT lp.delta_deposit
                FROM ins.t_inform_cover_lump lp
               WHERE lp.opt_brief = cv.opt_brief
                 AND lp.change_year = 5) delta_deposit4
            ,ROUND(cv.pen_for_year, 2) pen_for_year
            ,ta.par_t
            ,cv.start_date
            ,cv.end_date
            ,CASE
               WHEN ta.par_t = 1 THEN
                ROUND(ta.sa, 2)
               ELSE
                ROUND(ta.s1, 2)
             END
            ,ta.cur_fee
        FROM ins.t_actuar_value      ta
            ,ins.t_inform_cover_lump cv
       WHERE ta.par_t != 0
         AND ta.opt_brief = cv.opt_brief
         AND ta.par_t = cv.change_year;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' || SQLERRM);
  END calc_investor_plus;
  /**/
  PROCEDURE actuar_value(par_policy_id NUMBER) IS
  
  BEGIN
    DELETE FROM ins.t_actuar_value;
    INSERT INTO ins.t_actuar_value
      SELECT res.policy_id
            ,res.pol_header_id
            ,ph.start_date
            ,pol.end_date
            ,res.t_product_line_id
            ,res.p_cover_id
            ,rv.insurance_year_date
            ,NULL
            ,NULL
            ,NULL
            ,
             /*rv.p,
             rv.g,
             rv.tv_p,*/rv.plan
            ,rv.fact
            ,rv.insurance_year_number par_t
            ,pc.age par_values_age
            ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 par_n
            ,pc.sex sex_vh
            ,pc.deathrate_id
            ,pc.fact_yield_rate
            ,pc.f_loading
            ,ROUND(ins.pkg_amath.a_xn(pc.age + rv.insurance_year_number /*par_t*/
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 /*par_n*/
                                      -rv.insurance_year_number /*par_t*/
                                     ,pc.sex
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,pc.deathrate_id /*par_values.deathrate_id*/
                                     ,pc.fact_yield_rate /*par_values.fact_yield_rate*/)
                  ,10) v_a_xn
            ,ROUND(ins.pkg_amath.a_xn(pc.age
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12
                                     ,pc.sex
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,pc.deathrate_id
                                     ,pc.fact_yield_rate)
                  ,10) v_a_x_n
            ,ROUND(ins.pkg_amath.ax1n(pc.age + rv.insurance_year_number
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                      rv.insurance_year_number
                                     ,pc.sex
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,pc.deathrate_id
                                     ,pc.fact_yield_rate)
                  ,10) v_a1xn
            ,ROUND(ins.pkg_amath.iax1n(pc.age + rv.insurance_year_number
                                      ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                       rv.insurance_year_number
                                      ,pc.sex
                                      ,0 /*par_values.k_coef*/
                                      ,0 /*par_values.s_coef*/
                                      ,pc.deathrate_id
                                      ,pc.fact_yield_rate)
                  ,10) v_ia1xn
            ,ROUND(ins.pkg_amath.nex(pc.age + rv.insurance_year_number
                                    ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                     rv.insurance_year_number
                                    ,pc.sex
                                    ,0 /*par_values.k_coef*/
                                    ,0 /*par_values.s_coef*/
                                    ,pc.deathrate_id
                                    ,pc.fact_yield_rate)
                  ,10) v_nex
            ,(CASE pc.opt_brief
               WHEN 'PEPR_A' THEN
                2.9743
               WHEN 'PEPR_C' THEN
                3.21
               WHEN 'PEPR_B' THEN
                3.028
               WHEN 'OIL' THEN
                (CASE
                  WHEN MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                   2.77726
                  ELSE
                   4.61298
                END)
               WHEN 'GOLD' THEN
                (CASE
                  WHEN MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                   2.77726
                  ELSE
                   4.61298
                END)
             END) * pc.ver1_fee sa
            ,
             /*Pkg_cover.round_ins_amount(pc.cur_cover_id, pc.ver1_fee  / pkg_cover.calc_tariff(pc.cur_cover_id))\* * pc.const_tariff*\ sa,*/NULL
            ,CASE
               WHEN rv.insurance_year_number = 0 THEN
                NULL
               ELSE
                (pc.ver1_fee - pc.pen_second_year) * (1 - pc.f_loading)
             END p_1
            ,CASE
               WHEN rv.insurance_year_number = 0 THEN
                NULL
               WHEN rv.insurance_year_number = 1 THEN
                pc.ver1_fee
               WHEN rv.insurance_year_number = 2 THEN
                (CASE
                  WHEN pc.change_year = 2 THEN
                   pc.old_fee - pc.pen_second_year
                  ELSE
                   pc.cur_fee - pc.pen_second_year
                END)
               ELSE
                (CASE
                  WHEN pc.change_year = 2 THEN
                   pc.cur_fee - pc.pen_third_year
                  ELSE
                   pc.old_fee - pc.pen_third_year
                END)
             END cur_fee
            ,pc.opt_brief
            ,(1 - (CASE
               WHEN pc.opt_brief = 'PEPR_C' THEN
                0.05
               WHEN pc.opt_brief = 'PEPR_A' THEN
                0.1
               WHEN pc.opt_brief IN ('PEPR_B', 'OIL', 'GOLD') THEN
                0.07
               ELSE
                0
             END)) * (CASE
               WHEN rv.insurance_year_number = 0 THEN
                NULL
               WHEN rv.insurance_year_number = 1 THEN
                pc.ver1_fee
               WHEN rv.insurance_year_number = 2 THEN
                (CASE
                  WHEN pc.change_year = 2 THEN
                   pc.old_fee - nvl(pc.pen_second_year, 0)
                  ELSE
                   pc.cur_fee - nvl(pc.pen_second_year, 0)
                END)
               ELSE
                (CASE
                  WHEN pc.change_year = 3 THEN
                   pc.old_fee
                  ELSE
                   pc.cur_fee
                END) /*pc.cur_fee*/
                - /*pc.pen_second_year -*/ /*Заявка №182604*/
                nvl(pc.pen_third_year, 0)
             END) net_prem_act
            ,NULL
            ,CASE
               WHEN rv.insurance_year_number = 0 THEN
                0
               ELSE
                pc.ver1_fee * pc.const_tariff * rv.tv_p
             END
            ,NULL
            ,0
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
        FROM reserve.r_reserve       res
            ,reserve.r_reserve_value rv
            ,ins.t_inform_cover      pc
            ,ins.p_pol_header        ph
            ,ins.p_policy            pol
       WHERE res.policy_id = (SELECT p.policy_id
                                FROM ins.p_policy pp
                                    ,ins.p_policy p
                               WHERE pp.policy_id = par_policy_id
                                 AND pp.pol_header_id = p.pol_header_id
                                 AND p.version_num = 1)
         AND rv.reserve_id = res.id
         AND res.t_product_line_id = pc.cur_pl_id
         AND ph.policy_header_id = res.pol_header_id
         AND pol.policy_id = res.policy_id;
    /**/
    UPDATE ins.t_actuar_value a
       SET (a.g, a.p) =
           (SELECT ap.v_nex / (ap.v_a_xn * (1 - ap.f_loading) - ap.v_ia1xn)
                  ,(ap.v_nex / (ap.v_a_xn * (1 - ap.f_loading) - ap.v_ia1xn)) * (1 - ap.f_loading)
              FROM ins.t_actuar_value ap
             WHERE ap.p_cover_id = a.p_cover_id
               AND ap.par_t = 0);
    /**/
    UPDATE ins.t_actuar_value a
       SET a.tv_p    = a.v_nex + a.g * (a.par_t * a.v_a1xn + a.v_ia1xn) - a.p * a.v_a_xn
          ,a.net_res =
           (a.v_nex + a.g * (a.par_t * a.v_a1xn + a.v_ia1xn) - a.p * a.v_a_xn) * a.sa;
    /**/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ACTUAR_VALUE: ' || SQLERRM);
  END actuar_value;

  /**/
  /*PROCEDURE get_weigth(par_policy_id NUMBER) IS
    fa_increase        NUMBER := 0;
    sum_prem_no_change NUMBER := 0;
    fee_decrease       NUMBER := 0;
    pcnt_str_increase  NUMBER := 0;
  BEGIN
    \*для 2-ого года*\
    FOR cur IN (SELECT pc.opt_brief
                      ,pc.ver1_fee old_fee
                      ,(CASE
                         WHEN pc.change_year = 2 THEN
                          pc.old_fee
                         ELSE
                          pc.cur_fee
                       END) cur_fee
                      ,pc.ver1_sum_prem old_sum_prem
                      ,(CASE
                         WHEN pc.change_year = 2 THEN
                          pc.old_sum_prem
                         ELSE
                          pc.cur_sum_prem
                       END) cur_sum_prem
                      ,(CASE
                         WHEN pc.change_year = 2 THEN
                          pc.old_cover_id
                         ELSE
                          pc.cur_cover_id
                       END) p_cover_id
                  FROM ins.t_inform_cover pc)
    LOOP
      IF cur.cur_fee > cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_increase1 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fa_increase := fa_increase + 1;
      END IF;
      IF cur.old_sum_prem = cur.cur_sum_prem
      THEN
        sum_prem_no_change := 1;
      END IF;
      IF cur.cur_fee < cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_decrease1 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fee_decrease := fee_decrease + 1;
      END IF;
    END LOOP;
  
    UPDATE ins.t_inform_cover pc
       SET w2 = (CASE
                  WHEN pc.change_year = 2 THEN
                   pc.old_fee / pc.ver1_sum_prem
                  ELSE
                   pc.cur_fee / pc.ver1_sum_prem
                END) \*(pc.cur_fee / pc.old_sum_prem)*\
     WHERE pc.fee_decrease1 = 1;
    IF fa_increase = 3
    THEN
      UPDATE ins.t_inform_cover pc SET w2 = pc.perc_first_year / 100;
    ELSE
      IF sum_prem_no_change = 1
      THEN
        UPDATE ins.t_inform_cover pc
           SET w2 = (CASE
                      WHEN pc.change_year = 2 THEN
                       pc.old_fee / pc.old_sum_prem
                      ELSE
                       pc.cur_fee / pc.cur_sum_prem
                    END) \*(pc.cur_fee / pc.cur_sum_prem)*\
        ;
      ELSE
        IF fa_increase = 1
        THEN
          UPDATE ins.t_inform_cover pca
             SET w2 = (CASE
                        WHEN pca.change_year = 2 THEN
                         (pca.old_fee - (pca.old_sum_prem - pca.ver1_sum_prem)) / pca.ver1_sum_prem
                        ELSE
                         (pca.cur_fee - (pca.cur_sum_prem - pca.ver1_sum_prem)) / pca.ver1_sum_prem
                      END) \*(pca.cur_fee - (pca.cur_sum_prem - pca.old_sum_prem) ) / pca.old_sum_prem*\
           WHERE pca.fee_increase1 = 1;
          UPDATE ins.t_inform_cover pca
             SET w2 = (CASE
                        WHEN pca.change_year = 2 THEN
                         pca.old_fee / pca.ver1_sum_prem
                        ELSE
                         pca.cur_fee / pca.ver1_sum_prem
                      END) \*pca.cur_fee / pca.old_sum_prem*\
           WHERE nvl(pca.fee_increase1, 0) != 1;
        ELSE
          IF fa_increase = 2
          THEN
            SELECT COUNT(*)
              INTO pcnt_str_increase
              FROM ins.t_inform_cover pc
             WHERE abs(nvl(pc.old_fee, pc.cur_fee) - pc.ver1_fee) >
                   (nvl(pc.old_sum_prem, pc.cur_sum_prem) - pc.ver1_sum_prem)
               AND pc.fee_increase1 = 1;
            IF pcnt_str_increase = 1
            THEN
              UPDATE ins.t_inform_cover pc
                 SET w2 = ((CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_fee
                            ELSE
                             pc.cur_fee
                          END) - ((CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_sum_prem
                            ELSE
                             pc.cur_sum_prem
                          END) - pc.ver1_sum_prem)) / pc.ver1_sum_prem
               WHERE abs((CASE
                           WHEN pc.change_year = 2 THEN
                            pc.old_fee
                           ELSE
                            pc.cur_fee
                         END) - pc.ver1_fee) > ((CASE
                                                  WHEN pc.change_year = 2 THEN
                                                   pc.old_sum_prem
                                                  ELSE
                                                   pc.cur_sum_prem
                                                END) - pc.ver1_sum_prem)
                 AND pc.fee_increase1 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w2 = (CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_fee
                            ELSE
                             pc.cur_fee
                          END) / pc.ver1_sum_prem
               WHERE abs((CASE
                           WHEN pc.change_year = 2 THEN
                            pc.old_fee
                           ELSE
                            pc.cur_fee
                         END) - pc.ver1_fee) <= ((CASE
                                                   WHEN pc.change_year = 2 THEN
                                                    pc.old_sum_prem
                                                   ELSE
                                                    pc.cur_sum_prem
                                                 END) - pc.ver1_sum_prem)
                 AND pc.fee_increase1 = 1;
            ELSE
              UPDATE ins.t_inform_cover pc
                 SET w2 =
                     (pc.ver1_fee + (SELECT (pca.ver1_fee - (CASE
                                              WHEN pc.change_year = 2 THEN
                                               pc.old_sum_prem
                                              ELSE
                                               pc.cur_sum_prem
                                            END)) / 2
                                       FROM ins.t_inform_cover pca
                                      WHERE pca.fee_decrease1 = 1)) / pc.ver1_sum_prem
               WHERE pc.fee_increase1 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w2 = ((CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_sum_prem
                            ELSE
                             pc.cur_sum_prem
                          END) / pc.ver1_sum_prem)
               WHERE pc.fee_decrease1 = 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    \**\
    IF fa_increase != 3
    THEN
      UPDATE ins.t_inform_cover pc
         SET w2 =
             (SELECT (CASE
                       WHEN ver1_fee_b > old_fee_b THEN
                        old_fee_b / ver1_sum_prem
                       ELSE
                        (CASE
                          WHEN ver1_fee_a > old_fee_a THEN
                           (CASE
                             WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                              (old_fee_b - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                                 (old_fee_b / ver1_sum_prem)
                                ELSE
                                 (ver1_fee_b + abs(old_fee_a - ver1_fee_a) / 2) / ver1_sum_prem
                              END)
                           END)
                          ELSE
                           (CASE
                             WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                              (old_fee_b - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                                 old_fee_b / ver1_sum_prem
                                ELSE
                                 (ver1_fee_b + abs(old_fee_c - ver1_fee_c) / 2) / ver1_sum_prem
                              END)
                           END)
                        END)
                     END) w_b
                FROM (SELECT pcc.opt_brief     c
                            ,pca.opt_brief     a
                            ,pcb.opt_brief     b
                            ,pcc.ver1_fee      ver1_fee_c
                            ,pca.ver1_fee      ver1_fee_a
                            ,pcb.ver1_fee      ver1_fee_b
                            ,pca.ver1_sum_prem
                            ,pcc.old_fee       old_fee_c
                            ,pca.old_fee       old_fee_a
                            ,pcb.old_fee       old_fee_b
                            ,pcc.old_sum_prem
                            ,pcc.cur_fee       cur_fee_c
                            ,pca.cur_fee       cur_fee_a
                            ,pcb.cur_fee       cur_fee_b
                            ,pcc.cur_sum_prem
                        FROM ins.t_inform_cover pcc
                            ,ins.t_inform_cover pca
                            ,ins.t_inform_cover pcb
                       WHERE pcc.opt_brief = 'PEPR_C'
                         AND pca.opt_brief = 'PEPR_A'
                         AND pcb.opt_brief = 'PEPR_B'))
       WHERE pc.opt_brief = 'PEPR_B';
      UPDATE ins.t_inform_cover pc
         SET w2 =
             (SELECT (CASE
                       WHEN ver1_fee_a > old_fee_a THEN
                        old_fee_a / ver1_sum_prem
                       ELSE
                        (CASE
                          WHEN ver1_fee_c > old_fee_c THEN
                           (CASE
                             WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                              (old_fee_c - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                                 (old_fee_a / ver1_sum_prem)
                                ELSE
                                 (ver1_fee_a + abs(old_fee_c - ver1_fee_c) / 2) / ver1_sum_prem
                              END)
                           END)
                          ELSE
                           (CASE
                             WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                              (old_fee_a - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                                 old_fee_a / ver1_sum_prem
                                ELSE
                                 (ver1_fee_a + abs(old_fee_b - ver1_fee_b) / 2) / ver1_sum_prem
                              END)
                           END)
                        END)
                     END) w_a
                FROM (SELECT pcc.opt_brief     c
                            ,pca.opt_brief     a
                            ,pcb.opt_brief     b
                            ,pcc.ver1_fee      ver1_fee_c
                            ,pca.ver1_fee      ver1_fee_a
                            ,pcb.ver1_fee      ver1_fee_b
                            ,pca.ver1_sum_prem
                            ,pcc.old_fee       old_fee_c
                            ,pca.old_fee       old_fee_a
                            ,pcb.old_fee       old_fee_b
                            ,pcc.old_sum_prem
                            ,pcc.cur_fee       cur_fee_c
                            ,pca.cur_fee       cur_fee_a
                            ,pcb.cur_fee       cur_fee_b
                            ,pcc.cur_sum_prem
                        FROM ins.t_inform_cover pcc
                            ,ins.t_inform_cover pca
                            ,ins.t_inform_cover pcb
                       WHERE pcc.opt_brief = 'PEPR_C'
                         AND pca.opt_brief = 'PEPR_A'
                         AND pcb.opt_brief = 'PEPR_B'))
       WHERE pc.opt_brief = 'PEPR_A';
      UPDATE ins.t_inform_cover pc
         SET w2 =
             (SELECT (CASE
                       WHEN ver1_fee_c > old_fee_c THEN
                        old_fee_c / ver1_sum_prem
                       ELSE
                        (CASE
                          WHEN ver1_fee_a > old_fee_a THEN
                           (CASE
                             WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                              (old_fee_c - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                                 (old_fee_c / ver1_sum_prem)
                                ELSE
                                 (ver1_fee_c + abs(old_fee_a - ver1_fee_a) / 2) / ver1_sum_prem
                              END)
                           END)
                          ELSE
                           (CASE
                             WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                              (old_fee_c - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                                 old_fee_c / ver1_sum_prem
                                ELSE
                                 (ver1_fee_c + abs(old_fee_b - ver1_fee_b) / 2) / ver1_sum_prem
                              END)
                           END)
                        END)
                     END) w_c
                FROM (SELECT pcc.opt_brief     c
                            ,pca.opt_brief     a
                            ,pcb.opt_brief     b
                            ,pcc.ver1_fee      ver1_fee_c
                            ,pca.ver1_fee      ver1_fee_a
                            ,pcb.ver1_fee      ver1_fee_b
                            ,pca.ver1_sum_prem
                            ,pcc.old_fee       old_fee_c
                            ,pca.old_fee       old_fee_a
                            ,pcb.old_fee       old_fee_b
                            ,pcc.old_sum_prem
                            ,pcc.cur_fee       cur_fee_c
                            ,pca.cur_fee       cur_fee_a
                            ,pcb.cur_fee       cur_fee_b
                            ,pcc.cur_sum_prem
                        FROM ins.t_inform_cover pcc
                            ,ins.t_inform_cover pca
                            ,ins.t_inform_cover pcb
                       WHERE pcc.opt_brief = 'PEPR_C'
                         AND pca.opt_brief = 'PEPR_A'
                         AND pcb.opt_brief = 'PEPR_B'))
       WHERE pc.opt_brief = 'PEPR_C';
    END IF;
    \**\
    \*для 3-ого года*\
    fa_increase        := 0;
    sum_prem_no_change := 0;
    fee_decrease       := 0;
    pcnt_str_increase  := 0;
    FOR cur IN (SELECT pc.opt_brief
                      ,(CASE
                         WHEN pc.change_year = 3 THEN
                          pc.old_fee
                         ELSE
                          pc.cur_fee
                       END) old_fee
                      ,
                       \* NVL(pc.old_fee,pc.cur_fee) old_fee,*\pc.cur_fee
                      ,(CASE
                         WHEN pc.change_year = 3 THEN
                          pc.old_sum_prem
                         ELSE
                          pc.cur_sum_prem
                       END) old_sum_prem
                      ,
                       \*NVL(pc.old_sum_prem,pc.cur_sum_prem) old_sum_prem,*\pc.cur_sum_prem
                      ,pc.cur_cover_id p_cover_id
                  FROM ins.t_inform_cover pc
                \*where pc.old_cover_id is not null*\
                )
    LOOP
      IF cur.cur_fee > cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_increase2 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fa_increase := fa_increase + 1;
      END IF;
      IF cur.old_sum_prem = cur.cur_sum_prem
      THEN
        sum_prem_no_change := 1;
      END IF;
      IF cur.cur_fee < cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_decrease2 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fee_decrease := fee_decrease + 1;
      END IF;
    END LOOP;
  
    UPDATE ins.t_inform_cover pc
       SET w3 = (CASE
                  WHEN pc.change_year = 3 THEN
                   pc.old_fee / pc.ver1_sum_prem
                  ELSE
                   pc.cur_fee / pc.old_sum_prem
                END) \*(pc.cur_fee / pc.old_sum_prem)*\
     WHERE pc.fee_decrease2 = 1;
    IF fa_increase = 3
    THEN
      UPDATE ins.t_inform_cover pc SET w3 = pc.perc_second_year / 100;
    ELSE
      IF sum_prem_no_change = 1
      THEN
        UPDATE ins.t_inform_cover pc
           SET w3 = (CASE
                      WHEN pc.change_year = 3 THEN
                       pc.old_fee / pc.old_sum_prem
                      ELSE
                       pc.cur_fee / pc.cur_sum_prem
                    END) \*(pc.cur_fee / pc.cur_sum_prem)*\
        ;
      ELSE
        IF fa_increase = 1
        THEN
          UPDATE ins.t_inform_cover pca
             SET w3 = (CASE
                        WHEN pca.change_year = 3 THEN
                         (pca.old_fee - (pca.old_sum_prem - pca.cur_sum_prem)) / pca.cur_sum_prem
                        ELSE
                         (pca.cur_fee - (pca.cur_sum_prem - pca.old_sum_prem)) / pca.old_sum_prem
                      END) \*(pca.cur_fee - (pca.cur_sum_prem - pca.old_sum_prem) ) / pca.old_sum_prem*\
           WHERE pca.fee_increase2 = 1;
          UPDATE ins.t_inform_cover pca
             SET w3 = (CASE
                        WHEN pca.change_year = 3 THEN
                         pca.old_fee / pca.cur_sum_prem
                        ELSE
                         pca.cur_fee / pca.old_sum_prem
                      END) \*pca.cur_fee / pca.old_sum_prem*\
           WHERE nvl(pca.fee_increase2, 0) != 1;
        ELSE
          IF fa_increase = 2
          THEN
            SELECT COUNT(*)
              INTO pcnt_str_increase
              FROM ins.t_inform_cover pc
             WHERE abs(pc.cur_fee - pc.old_fee) > (pc.cur_sum_prem - pc.old_sum_prem)
               AND pc.fee_increase2 = 1;
            IF pcnt_str_increase = 1
            THEN
              UPDATE ins.t_inform_cover pc
                 SET w3 =
                     (pc.cur_sum_prem - pc.cur_fee) / pc.old_sum_prem
               WHERE abs(pc.cur_fee - pc.old_fee) > (pc.cur_sum_prem - pc.old_sum_prem)
                 AND pc.fee_increase2 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w3 = pc.cur_fee / pc.old_sum_prem
               WHERE abs(pc.cur_fee - pc.old_fee) <= (pc.cur_sum_prem - pc.old_sum_prem)
                 AND pc.fee_increase2 = 1;
            ELSE
              UPDATE ins.t_inform_cover pc
                 SET w3 =
                     (pc.old_fee + (SELECT (pca.old_fee - pca.cur_fee) / 2
                                      FROM ins.t_inform_cover pca
                                     WHERE pca.fee_decrease2 = 1)) / pc.cur_sum_prem
               WHERE pc.fee_increase2 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w3 =
                     (pc.cur_fee / pc.old_sum_prem)
               WHERE pc.fee_decrease2 = 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_WEIGTH: ' || SQLERRM);
  END get_weigth;*/
  PROCEDURE get_weigth(par_policy_id NUMBER) IS
    fa_increase        NUMBER := 0;
    sum_prem_no_change NUMBER := 0;
    fee_decrease       NUMBER := 0;
    pcnt_str_increase  NUMBER := 0;
  BEGIN
    /*для 2-ого года*/
    FOR cur IN (SELECT pc.opt_brief
                      ,pc.ver1_fee      old_fee
                      ,pc.old_fee       cur_fee
                      ,pc.ver1_sum_prem old_sum_prem
                      ,pc.old_sum_prem  cur_sum_prem
                      ,pc.old_cover_id  p_cover_id
                  FROM ins.t_inform_cover pc)
    LOOP
      IF cur.cur_fee > cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_increase1 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fa_increase := fa_increase + 1;
      END IF;
      IF cur.old_sum_prem = cur.cur_sum_prem
      THEN
        sum_prem_no_change := 1;
      END IF;
      IF cur.cur_fee < cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_decrease1 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fee_decrease := fee_decrease + 1;
      END IF;
    END LOOP;
  
    UPDATE ins.t_inform_cover pc
       SET w2 = (CASE
                  WHEN pc.change_year = 2 THEN
                   pc.old_fee / pc.ver1_sum_prem
                  ELSE
                   pc.cur_fee / pc.ver1_sum_prem
                END) /*(pc.cur_fee / pc.old_sum_prem)*/
     WHERE pc.fee_decrease1 = 1;
    IF fa_increase = 3
    THEN
      UPDATE ins.t_inform_cover pc SET w2 = pc.perc_first_year / 100;
    ELSE
      IF sum_prem_no_change = 1
      THEN
        UPDATE ins.t_inform_cover pc
           SET w2 = (CASE
                      WHEN pc.change_year = 2 THEN
                       pc.old_fee / pc.old_sum_prem
                      ELSE
                       pc.cur_fee / pc.cur_sum_prem
                    END) /*(pc.cur_fee / pc.cur_sum_prem)*/
        ;
      ELSE
        IF fa_increase = 1
        THEN
          UPDATE ins.t_inform_cover pca
             SET w2 = (CASE
                        WHEN pca.change_year = 2 THEN
                         (pca.old_fee - (pca.old_sum_prem - pca.ver1_sum_prem)) / pca.ver1_sum_prem
                        ELSE
                         (pca.cur_fee - (pca.cur_sum_prem - pca.ver1_sum_prem)) / pca.ver1_sum_prem
                      END) /*(pca.cur_fee - (pca.cur_sum_prem - pca.old_sum_prem) ) / pca.old_sum_prem*/
           WHERE pca.fee_increase1 = 1;
          UPDATE ins.t_inform_cover pca
             SET w2 = (CASE
                        WHEN pca.change_year = 2 THEN
                         pca.old_fee / pca.ver1_sum_prem
                        ELSE
                         pca.cur_fee / pca.ver1_sum_prem
                      END) /*pca.cur_fee / pca.old_sum_prem*/
           WHERE nvl(pca.fee_increase1, 0) != 1;
        ELSE
          IF fa_increase = 2
          THEN
            SELECT COUNT(*)
              INTO pcnt_str_increase
              FROM ins.t_inform_cover pc
             WHERE abs(nvl(pc.old_fee, pc.cur_fee) - pc.ver1_fee) >
                   (nvl(pc.old_sum_prem, pc.cur_sum_prem) - pc.ver1_sum_prem)
               AND pc.fee_increase1 = 1;
            IF pcnt_str_increase = 1
            THEN
              UPDATE ins.t_inform_cover pc
                 SET w2 = ((CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_fee
                            ELSE
                             pc.cur_fee
                          END) - ((CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_sum_prem
                            ELSE
                             pc.cur_sum_prem
                          END) - pc.ver1_sum_prem)) / pc.ver1_sum_prem
               WHERE abs((CASE
                           WHEN pc.change_year = 2 THEN
                            pc.old_fee
                           ELSE
                            pc.cur_fee
                         END) - pc.ver1_fee) > ((CASE
                                                  WHEN pc.change_year = 2 THEN
                                                   pc.old_sum_prem
                                                  ELSE
                                                   pc.cur_sum_prem
                                                END) - pc.ver1_sum_prem)
                 AND pc.fee_increase1 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w2 = (CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_fee
                            ELSE
                             pc.cur_fee
                          END) / pc.ver1_sum_prem
               WHERE abs((CASE
                           WHEN pc.change_year = 2 THEN
                            pc.old_fee
                           ELSE
                            pc.cur_fee
                         END) - pc.ver1_fee) <= ((CASE
                                                   WHEN pc.change_year = 2 THEN
                                                    pc.old_sum_prem
                                                   ELSE
                                                    pc.cur_sum_prem
                                                 END) - pc.ver1_sum_prem)
                 AND pc.fee_increase1 = 1;
            ELSE
              UPDATE ins.t_inform_cover pc
                 SET w2 =
                     (pc.ver1_fee + (SELECT (pca.ver1_fee - (CASE
                                              WHEN pc.change_year = 2 THEN
                                               pc.old_sum_prem
                                              ELSE
                                               pc.cur_sum_prem
                                            END)) / 2
                                       FROM ins.t_inform_cover pca
                                      WHERE pca.fee_decrease1 = 1)) / pc.ver1_sum_prem
               WHERE pc.fee_increase1 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w2 = ((CASE
                            WHEN pc.change_year = 2 THEN
                             pc.old_sum_prem
                            ELSE
                             pc.cur_sum_prem
                          END) / pc.ver1_sum_prem)
               WHERE pc.fee_decrease1 = 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    /**/
    IF fa_increase != 3
    THEN
      UPDATE ins.t_inform_cover pc
         SET w2 =
             (SELECT (CASE
                       WHEN ver1_fee_b > old_fee_b THEN
                        old_fee_b / ver1_sum_prem
                       ELSE
                        (CASE
                          WHEN ver1_fee_a > old_fee_a THEN
                           (CASE
                             WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                              (old_fee_b - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                                 (old_fee_b / ver1_sum_prem)
                                ELSE
                                 (ver1_fee_b + abs(old_fee_a - ver1_fee_a) / 2) / ver1_sum_prem
                              END)
                           END)
                          ELSE
                           (CASE
                             WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                              (old_fee_b - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                                 old_fee_b / ver1_sum_prem
                                ELSE
                                 (ver1_fee_b + abs(old_fee_c - ver1_fee_c) / 2) / ver1_sum_prem
                              END)
                           END)
                        END)
                     END) w_b
                FROM (SELECT pcc.opt_brief     c
                            ,pca.opt_brief     a
                            ,pcb.opt_brief     b
                            ,pcc.ver1_fee      ver1_fee_c
                            ,pca.ver1_fee      ver1_fee_a
                            ,pcb.ver1_fee      ver1_fee_b
                            ,pca.ver1_sum_prem
                            ,pcc.old_fee       old_fee_c
                            ,pca.old_fee       old_fee_a
                            ,pcb.old_fee       old_fee_b
                            ,pcc.old_sum_prem
                            ,pcc.cur_fee       cur_fee_c
                            ,pca.cur_fee       cur_fee_a
                            ,pcb.cur_fee       cur_fee_b
                            ,pcc.cur_sum_prem
                        FROM ins.t_inform_cover pcc
                            ,ins.t_inform_cover pca
                            ,ins.t_inform_cover pcb
                       WHERE pcc.opt_brief = 'PEPR_C'
                         AND pca.opt_brief = 'PEPR_A'
                         AND pcb.opt_brief = 'PEPR_B'))
       WHERE pc.opt_brief = 'PEPR_B';
      UPDATE ins.t_inform_cover pc
         SET w2 =
             (SELECT (CASE
                       WHEN ver1_fee_a > old_fee_a THEN
                        old_fee_a / ver1_sum_prem
                       ELSE
                        (CASE
                          WHEN ver1_fee_c > old_fee_c THEN
                           (CASE
                             WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                              (old_fee_c - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_c - ver1_fee_c) / 2 THEN
                                 (old_fee_a / ver1_sum_prem)
                                ELSE
                                 (ver1_fee_a + abs(old_fee_c - ver1_fee_c) / 2) / ver1_sum_prem
                              END)
                           END)
                          ELSE
                           (CASE
                             WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                              (old_fee_a - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                                 old_fee_a / ver1_sum_prem
                                ELSE
                                 (ver1_fee_a + abs(old_fee_b - ver1_fee_b) / 2) / ver1_sum_prem
                              END)
                           END)
                        END)
                     END) w_a
                FROM (SELECT pcc.opt_brief     c
                            ,pca.opt_brief     a
                            ,pcb.opt_brief     b
                            ,pcc.ver1_fee      ver1_fee_c
                            ,pca.ver1_fee      ver1_fee_a
                            ,pcb.ver1_fee      ver1_fee_b
                            ,pca.ver1_sum_prem
                            ,pcc.old_fee       old_fee_c
                            ,pca.old_fee       old_fee_a
                            ,pcb.old_fee       old_fee_b
                            ,pcc.old_sum_prem
                            ,pcc.cur_fee       cur_fee_c
                            ,pca.cur_fee       cur_fee_a
                            ,pcb.cur_fee       cur_fee_b
                            ,pcc.cur_sum_prem
                        FROM ins.t_inform_cover pcc
                            ,ins.t_inform_cover pca
                            ,ins.t_inform_cover pcb
                       WHERE pcc.opt_brief = 'PEPR_C'
                         AND pca.opt_brief = 'PEPR_A'
                         AND pcb.opt_brief = 'PEPR_B'))
       WHERE pc.opt_brief = 'PEPR_A';
      UPDATE ins.t_inform_cover pc
         SET w2 =
             (SELECT (CASE
                       WHEN ver1_fee_c > old_fee_c THEN
                        old_fee_c / ver1_sum_prem
                       ELSE
                        (CASE
                          WHEN ver1_fee_a > old_fee_a THEN
                           (CASE
                             WHEN abs(old_fee_b - ver1_fee_b) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                              (old_fee_c - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_a - ver1_fee_a) / 2 THEN
                                 (old_fee_c / ver1_sum_prem)
                                ELSE
                                 (ver1_fee_c + abs(old_fee_a - ver1_fee_a) / 2) / ver1_sum_prem
                              END)
                           END)
                          ELSE
                           (CASE
                             WHEN abs(old_fee_a - ver1_fee_a) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                              (old_fee_c - (old_sum_prem - ver1_sum_prem)) / ver1_sum_prem
                             ELSE
                              (CASE
                                WHEN abs(old_fee_c - ver1_fee_c) < abs(old_fee_b - ver1_fee_b) / 2 THEN
                                 old_fee_c / ver1_sum_prem
                                ELSE
                                 (ver1_fee_c + abs(old_fee_b - ver1_fee_b) / 2) / ver1_sum_prem
                              END)
                           END)
                        END)
                     END) w_c
                FROM (SELECT pcc.opt_brief     c
                            ,pca.opt_brief     a
                            ,pcb.opt_brief     b
                            ,pcc.ver1_fee      ver1_fee_c
                            ,pca.ver1_fee      ver1_fee_a
                            ,pcb.ver1_fee      ver1_fee_b
                            ,pca.ver1_sum_prem
                            ,pcc.old_fee       old_fee_c
                            ,pca.old_fee       old_fee_a
                            ,pcb.old_fee       old_fee_b
                            ,pcc.old_sum_prem
                            ,pcc.cur_fee       cur_fee_c
                            ,pca.cur_fee       cur_fee_a
                            ,pcb.cur_fee       cur_fee_b
                            ,pcc.cur_sum_prem
                        FROM ins.t_inform_cover pcc
                            ,ins.t_inform_cover pca
                            ,ins.t_inform_cover pcb
                       WHERE pcc.opt_brief = 'PEPR_C'
                         AND pca.opt_brief = 'PEPR_A'
                         AND pcb.opt_brief = 'PEPR_B'))
       WHERE pc.opt_brief = 'PEPR_C';
    END IF;
    /**/
    /*для 3-ого года*/
    fa_increase        := 0;
    sum_prem_no_change := 0;
    fee_decrease       := 0;
    pcnt_str_increase  := 0;
    FOR cur IN (SELECT pc.opt_brief
                      ,pc.old_fee
                      ,pc.cur_fee
                      ,pc.old_sum_prem
                      ,pc.cur_sum_prem
                      ,pc.cur_cover_id p_cover_id
                  FROM ins.t_inform_cover pc)
    LOOP
      IF cur.cur_fee > cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_increase2 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fa_increase := fa_increase + 1;
      END IF;
      IF cur.old_sum_prem = cur.cur_sum_prem
      THEN
        sum_prem_no_change := 1;
      END IF;
      IF cur.cur_fee < cur.old_fee
      THEN
        UPDATE ins.t_inform_cover pc SET pc.fee_decrease2 = 1 WHERE pc.opt_brief = cur.opt_brief;
        fee_decrease := fee_decrease + 1;
      END IF;
    END LOOP;
  
    UPDATE ins.t_inform_cover pc
       SET w3 = (CASE
                  WHEN pc.change_year = 3 THEN
                   pc.old_fee / pc.ver1_sum_prem
                  ELSE
                   pc.cur_fee / pc.old_sum_prem
                END) /*(pc.cur_fee / pc.old_sum_prem)*/
     WHERE pc.fee_decrease2 = 1;
    IF fa_increase = 3
    THEN
      UPDATE ins.t_inform_cover pc SET w3 = pc.perc_second_year / 100;
    ELSE
      IF sum_prem_no_change = 1
      THEN
        UPDATE ins.t_inform_cover pc
           SET w3 = (CASE
                      WHEN pc.change_year = 3 THEN
                       pc.old_fee / pc.old_sum_prem
                      ELSE
                       pc.cur_fee / pc.cur_sum_prem
                    END) /*(pc.cur_fee / pc.cur_sum_prem)*/
        ;
      ELSE
        IF fa_increase = 1
        THEN
          UPDATE ins.t_inform_cover pca
             SET w3 = (CASE
                        WHEN pca.change_year = 3 THEN
                         (pca.old_fee - (pca.old_sum_prem - pca.cur_sum_prem)) / pca.cur_sum_prem
                        ELSE
                         (pca.cur_fee - (pca.cur_sum_prem - pca.old_sum_prem)) / pca.old_sum_prem
                      END) /*(pca.cur_fee - (pca.cur_sum_prem - pca.old_sum_prem) ) / pca.old_sum_prem*/
           WHERE pca.fee_increase2 = 1;
          UPDATE ins.t_inform_cover pca
             SET w3 = (CASE
                        WHEN pca.change_year = 3 THEN
                         pca.old_fee / pca.cur_sum_prem
                        ELSE
                         pca.cur_fee / pca.old_sum_prem
                      END) /*pca.cur_fee / pca.old_sum_prem*/
           WHERE nvl(pca.fee_increase2, 0) != 1;
        ELSE
          IF fa_increase = 2
          THEN
            SELECT COUNT(*)
              INTO pcnt_str_increase
              FROM ins.t_inform_cover pc
             WHERE abs(pc.cur_fee - pc.old_fee) > (pc.cur_sum_prem - pc.old_sum_prem)
               AND pc.fee_increase2 = 1;
            IF pcnt_str_increase = 1
            THEN
              UPDATE ins.t_inform_cover pc
                 SET w3 =
                     (pc.cur_sum_prem - pc.cur_fee) / pc.old_sum_prem
               WHERE abs(pc.cur_fee - pc.old_fee) > (pc.cur_sum_prem - pc.old_sum_prem)
                 AND pc.fee_increase2 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w3 = pc.cur_fee / pc.old_sum_prem
               WHERE abs(pc.cur_fee - pc.old_fee) <= (pc.cur_sum_prem - pc.old_sum_prem)
                 AND pc.fee_increase2 = 1;
            ELSE
              UPDATE ins.t_inform_cover pc
                 SET w3 =
                     (pc.old_fee + (SELECT (pca.old_fee - pca.cur_fee) / 2
                                      FROM ins.t_inform_cover pca
                                     WHERE pca.fee_decrease2 = 1)) / pc.cur_sum_prem
               WHERE pc.fee_increase2 = 1;
              UPDATE ins.t_inform_cover pc
                 SET w3 =
                     (pc.cur_fee / pc.old_sum_prem)
               WHERE pc.fee_decrease2 = 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_WEIGTH: ' || SQLERRM);
  END get_weigth;

  /**/
  PROCEDURE another_update
  (
    par_policy_id  NUMBER
   ,par_prod_brief VARCHAR2
  ) IS
  BEGIN
  
    /*первый год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT (pkg_change_anniversary.get_savings(pc.ver1_cover_id
                                                      ,pc.start_date
                                                      ,trunc(pc.end_date)
                                                      ,ta.par_t
                                                      ,ta.net_prem_act)) /** 0.99*/ /*Заявка №182604*/
              FROM ins.t_inform_cover pc
             WHERE pc.ver1_cover_id = ta.p_cover_id)
     WHERE ta.par_t = 1;
    /**/
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - ta.net_res
    /*(SELECT t.savings - (SELECT pc.ver1_fee * pc.const_tariff * ta.tv_p
                        FROM ins.t_inform_cover pc
                        WHERE pc.ver1_cover_id = ta.p_cover_id
                        )
    FROM ins.t_actuar_value t
    WHERE ta.p_cover_id = t.p_cover_id
      AND t.par_t = 1)*/
     WHERE ta.par_t = 1;
    /**/
    UPDATE ins.t_inform_cover pc
       SET pc.delta_w1    = pc.w2 * 100 - pc.perc_first_year
          ,pc.priznak1 = (CASE
                           WHEN nvl(pc.w2 * 100 - pc.perc_first_year, 0) > 0 THEN
                            1
                           ELSE
                            0
                         END)
          ,pc.up_priznak1 = (CASE
                              WHEN pc.ver1_fee < (CASE
                                     WHEN pc.change_year = 2 THEN
                                      pc.old_fee
                                     ELSE
                                      pc.cur_fee
                                   END) /*NVL(pc.old_fee,pc.cur_fee)*/
                               THEN
                               1
                              ELSE
                               (CASE
                                 WHEN (CASE
                                        WHEN pc.change_year = 2 THEN
                                         pc.old_fee
                                        ELSE
                                         pc.cur_fee
                                      END) /*NVL(pc.old_fee,pc.cur_fee)*/
                                      = pc.ver1_fee THEN
                                  2
                                 ELSE
                                  0
                               END)
                            END);
    UPDATE ins.t_inform_cover pc
       SET pc.delta_w2    = pc.w3 * 100 - pc.perc_second_year
          ,pc.priznak2 = (CASE
                           WHEN nvl(pc.w3 * 100 - pc.perc_second_year, 0) > 0 THEN
                            1
                           ELSE
                            0
                         END)
          ,pc.up_priznak2 = (CASE
                              WHEN (CASE
                                     WHEN pc.change_year = 2 THEN
                                      pc.old_fee
                                     ELSE
                                      pc.cur_fee
                                   END) /*NVL(pc.old_fee,pc.cur_fee)*/
                                   < pc.cur_fee THEN
                               1
                              ELSE
                               (CASE
                                 WHEN (CASE
                                        WHEN pc.change_year = 2 THEN
                                         pc.old_fee
                                        ELSE
                                         pc.cur_fee
                                      END) /*NVL(pc.old_fee,pc.cur_fee)*/
                                      = pc.cur_fee THEN
                                  2
                                 ELSE
                                  0
                               END)
                            END);
    /**/
    UPDATE ins.t_inform_cover pc
       SET pc.type_recalc_f6 =
           (SELECT CASE
                     WHEN (f2 < 0 AND f3 < 0 AND f4 > 0)
                          OR (f2 < 0 AND f3 > 0 AND f4 < 0)
                          OR (f2 > 0 AND f3 < 0 AND f4 < 0) THEN
                      'из двух в одну'
                     ELSE
                      (CASE
                        WHEN (f2 < 0 AND f3 > 0 AND f4 > 0)
                             OR (f2 > 0 AND f3 < 0 AND f4 > 0)
                             OR (f2 > 0 AND f3 > 0 AND f4 < 0) THEN
                         'из одной в две'
                        ELSE
                         (CASE
                           WHEN (f2 = 0 AND f3 = 0 AND f4 = 0) THEN
                            'нет изменений'
                           ELSE
                            'из одной в одну'
                         END)
                      END)
                   END
              FROM (SELECT pcc.opt_brief c
                          ,pcc.delta_w1  f4
                          ,pca.opt_brief a
                          ,pca.delta_w1  f3
                          ,pcb.opt_brief b
                          ,pcb.delta_w1  f2
                      FROM ins.t_inform_cover pcc
                          ,ins.t_inform_cover pca
                          ,ins.t_inform_cover pcb
                     WHERE pcc.opt_brief = 'PEPR_C'
                       AND pca.opt_brief = 'PEPR_A'
                       AND pcb.opt_brief = 'PEPR_B'));
    UPDATE ins.t_inform_cover pc
       SET pc.type_recalc_b6 =
           (SELECT CASE
                     WHEN (CASE
                            WHEN pca.ver1_sum_prem != (CASE
                                   WHEN pca.change_year = 2 THEN
                                    pca.old_sum_prem
                                   ELSE
                                    pca.cur_sum_prem
                                 END) /*NVL(pca.old_sum_prem,pca.cur_sum_prem)*/
                             THEN
                             1
                            ELSE
                             0
                          END) = 0 THEN
                      pca.type_recalc_f6
                     ELSE
                      (CASE
                        WHEN (CASE
                               WHEN (SELECT (CASE
                                              WHEN pca.change_year = 2 THEN
                                               SUM(abs(pcad.old_fee - pcad.ver1_fee))
                                              ELSE
                                               SUM(abs(pcad.cur_fee - pcad.ver1_fee))
                                            END) /*SUM(ABS(NVL(pcad.old_fee,pcad.cur_fee) - pcad.ver1_fee))*/
                                       FROM ins.t_inform_cover pcad) = (CASE
                                      WHEN pca.change_year = 2 THEN
                                       (pca.old_sum_prem - pca.ver1_sum_prem)
                                      ELSE
                                       (pca.cur_sum_prem - pca.ver1_sum_prem)
                                    END) /*(NVL(pca.old_sum_prem,pca.cur_sum_prem) - pca.ver1_sum_prem)*/
                                THEN
                                1
                               ELSE
                                0
                             END) = 1 THEN
                         'нет изменений'
                        ELSE
                         (CASE
                           WHEN (SELECT SUM(pcad.up_priznak1) FROM ins.t_inform_cover pcad) = 1 THEN
                            'из двух в одну'
                           ELSE
                            (CASE
                              WHEN (SELECT SUM(pcad.up_priznak1) FROM ins.t_inform_cover pcad) = 2 THEN
                               'из одной в две'
                              ELSE
                               'из одной в одну'
                            END)
                         END)
                      END)
                   END
              FROM ins.t_inform_cover pca
             WHERE pc.ver1_cover_id = pca.ver1_cover_id);
    /**/
    UPDATE ins.t_inform_cover pc
       SET pc.type_recalc_f7 =
           (SELECT CASE
                     WHEN (f2 < 0 AND f3 < 0 AND f4 > 0)
                          OR (f2 < 0 AND f3 > 0 AND f4 < 0)
                          OR (f2 > 0 AND f3 < 0 AND f4 < 0) THEN
                      'из двух в одну'
                     ELSE
                      (CASE
                        WHEN (f2 < 0 AND f3 > 0 AND f4 > 0)
                             OR (f2 > 0 AND f3 < 0 AND f4 > 0)
                             OR (f2 > 0 AND f3 > 0 AND f4 < 0) THEN
                         'из одной в две'
                        ELSE
                         (CASE
                           WHEN (f2 = 0 AND f3 = 0 AND f4 = 0) THEN
                            'нет изменений'
                           ELSE
                            'из одной в одну'
                         END)
                      END)
                   END
              FROM (SELECT pcc.opt_brief c
                          ,pcc.delta_w2  f4
                          ,pca.opt_brief a
                          ,pca.delta_w2  f3
                          ,pcb.opt_brief b
                          ,pcb.delta_w2  f2
                      FROM ins.t_inform_cover pcc
                          ,ins.t_inform_cover pca
                          ,ins.t_inform_cover pcb
                     WHERE pcc.opt_brief = 'PEPR_C'
                       AND pca.opt_brief = 'PEPR_A'
                       AND pcb.opt_brief = 'PEPR_B'));
    UPDATE ins.t_inform_cover pc
       SET pc.type_recalc_b7 =
           (SELECT CASE
                     WHEN (CASE
                            WHEN pca.cur_sum_prem != pca.old_sum_prem THEN
                             1
                            ELSE
                             0
                          END) = 0 THEN
                      pca.type_recalc_f7
                     ELSE
                      (CASE
                        WHEN (CASE
                               WHEN (SELECT SUM(abs(pcad.cur_fee - pcad.old_fee)) FROM ins.t_inform_cover pcad) =
                                    (pca.cur_sum_prem - pca.old_sum_prem) THEN
                                1
                               ELSE
                                0
                             END) = 1 THEN
                         'нет изменений'
                        ELSE
                         (CASE
                           WHEN (SELECT SUM(pcad.up_priznak2) FROM ins.t_inform_cover pcad) = 1 THEN
                            'из двух в одну'
                           ELSE
                            (CASE
                              WHEN (SELECT SUM(pcad.up_priznak2) FROM ins.t_inform_cover pcad) = 2 THEN
                               'из одной в две'
                              ELSE
                               'из одной в одну'
                            END)
                         END)
                      END)
                   END
              FROM ins.t_inform_cover pca
             WHERE pc.ver1_cover_id = pca.ver1_cover_id);
    /**/
    UPDATE ins.t_inform_cover pcw
       SET pcw.delta_res1 =
           (SELECT (w_for_distrib * reserve_distrib) - (w_for_take * reserve_distrib) delta_res1
              FROM (SELECT (SELECT CASE
                                     WHEN (a.btype_recalc_b6 = 'из одной в две' OR
                                          a.btype_recalc_b6 = 'из двух в одну' OR
                                          a.btype_recalc_b6 = 'из одной в одну') THEN
                                      - ((1 - a.bpriznak1) * (a.f2 / 100) *
                                         (SELECT ta.net_res
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.bp_cover_id
                                             AND ta.par_t = 1) +
                                         (1 - a.apriznak1) * (a.f3 / 100) *
                                         (SELECT ta.net_res
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.ap_cover_id
                                             AND ta.par_t = 1) +
                                         (1 - a.cpriznak1) * (a.f4 / 100) *
                                         (SELECT ta.net_res
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.cp_cover_id
                                             AND ta.par_t = 1))
                                     ELSE
                                      0
                                   END reserve_distrib
                              FROM (SELECT pcc.opt_brief      c
                                          ,pcc.ver1_cover_id  cp_cover_id
                                          ,pcc.delta_w1       f4
                                          ,pcc.type_recalc_b6 ctype_recalc_b6
                                          ,pcc.priznak1       cpriznak1
                                          ,pca.opt_brief      a
                                          ,pca.ver1_cover_id  ap_cover_id
                                          ,pca.delta_w1       f3
                                          ,pca.type_recalc_b6 atype_recalc_b6
                                          ,pca.priznak1       apriznak1
                                          ,pcb.opt_brief      b
                                          ,pcb.ver1_cover_id  bp_cover_id
                                          ,pcb.delta_w1       f2
                                          ,pcb.type_recalc_b6 btype_recalc_b6
                                          ,pcb.priznak1       bpriznak1
                                      FROM ins.t_inform_cover pcc
                                          ,ins.t_inform_cover pca
                                          ,ins.t_inform_cover pcb
                                     WHERE pcc.opt_brief = 'PEPR_C'
                                       AND pca.opt_brief = 'PEPR_A'
                                       AND pcb.opt_brief = 'PEPR_B') a) reserve_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak1) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((pc.delta_w1 * pc.priznak1) /
                              (SELECT SUM(pca.delta_w1 * pca.priznak1) FROM ins.t_inform_cover pca))
                           END w_for_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak1) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((1 - pc.priznak1) * pc.delta_w1 /
                              (SELECT SUM((1 - pca.priznak1) * pca.delta_w1) FROM ins.t_inform_cover pca))
                           END w_for_take
                          ,pc.ver1_cover_id
                          ,pc.opt_brief
                      FROM ins.t_inform_cover pc) b
             WHERE b.ver1_cover_id = pcw.ver1_cover_id);
  
    UPDATE ins.t_inform_cover pcw
       SET pcw.delta_eib1 =
           (SELECT ((greatest(reserve_distrib * w_for_distrib, 0) -
                   (SELECT SUM(v.pen_second_year) FROM ins.t_inform_cover v) * w_for_distrib)) -
                   abs(w_for_take * reserve_distrib) delta_res1
              FROM (SELECT (SELECT CASE
                                     WHEN (a.btype_recalc_b6 = 'из одной в две' OR
                                          a.btype_recalc_b6 = 'из двух в одну' OR
                                          a.btype_recalc_b6 = 'из одной в одну') THEN
                                      - ((1 - a.bpriznak1) * (a.f2 / 100) *
                                         (SELECT ta.eib_theor
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.bp_cover_id
                                             AND ta.par_t = 1) +
                                         (1 - a.apriznak1) * (a.f3 / 100) *
                                         (SELECT ta.eib_theor
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.ap_cover_id
                                             AND ta.par_t = 1) +
                                         (1 - a.cpriznak1) * (a.f4 / 100) *
                                         (SELECT ta.eib_theor
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.cp_cover_id
                                             AND ta.par_t = 1))
                                     ELSE
                                      0
                                   END reserve_distrib
                              FROM (SELECT pcc.opt_brief      c
                                          ,pcc.ver1_cover_id  cp_cover_id
                                          ,pcc.delta_w1       f4
                                          ,pcc.type_recalc_b6 ctype_recalc_b6
                                          ,pcc.priznak1       cpriznak1
                                          ,pca.opt_brief      a
                                          ,pca.ver1_cover_id  ap_cover_id
                                          ,pca.delta_w1       f3
                                          ,pca.type_recalc_b6 atype_recalc_b6
                                          ,pca.priznak1       apriznak1
                                          ,pcb.opt_brief      b
                                          ,pcb.ver1_cover_id  bp_cover_id
                                          ,pcb.delta_w1       f2
                                          ,pcb.type_recalc_b6 btype_recalc_b6
                                          ,pcb.priznak1       bpriznak1
                                      FROM ins.t_inform_cover pcc
                                          ,ins.t_inform_cover pca
                                          ,ins.t_inform_cover pcb
                                     WHERE pcc.opt_brief = 'PEPR_C'
                                       AND pca.opt_brief = 'PEPR_A'
                                       AND pcb.opt_brief = 'PEPR_B') a) reserve_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak1) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((pc.delta_w1 * pc.priznak1) /
                              (SELECT SUM(pca.delta_w1 * pca.priznak1) FROM ins.t_inform_cover pca))
                           END w_for_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak1) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((1 - pc.priznak1) * pc.delta_w1 /
                              (SELECT SUM((1 - pca.priznak1) * pca.delta_w1) FROM ins.t_inform_cover pca))
                           END w_for_take
                          ,pc.ver1_cover_id
                          ,pc.opt_brief
                      FROM ins.t_inform_cover pc) b
             WHERE b.ver1_cover_id = pcw.ver1_cover_id);
    /**/
    UPDATE ins.t_inform_cover pcw
       SET pcw.bt =
           (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
              FROM ins.t_actuar_value ta
             WHERE ta.p_cover_id = pcw.ver1_cover_id
               AND ta.par_t = 1);
    UPDATE ins.t_inform_cover pcw
       SET pcw.s2 = (CASE
                      WHEN pcw.ver1_fee = (CASE
                             WHEN pcw.change_year = 2 THEN
                              pcw.old_fee
                             ELSE
                              pcw.cur_fee
                           END) THEN
                       pcw.ver1_amount
                      ELSE
                       pcw.ver1_amount +
                       (pcw.ver1_fee - (CASE
                         WHEN pcw.change_year = 2 THEN
                          pcw.old_fee
                         ELSE
                          pcw.cur_fee
                       END)) * pcw.bt / (SELECT ta.v_nex
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.p_cover_id = pcw.ver1_cover_id
                                            AND ta.par_t = 1) +
                       pcw.delta_eib1 / (SELECT ta.v_nex
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.p_cover_id = pcw.ver1_cover_id
                                            AND ta.par_t = 1) +
                       pcw.delta_res1 / (SELECT ta.v_nex
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.p_cover_id = pcw.ver1_cover_id
                                            AND ta.par_t = 1)
                    /*(SELECT (ta.net_res + pcw.delta_res1 + pcw.delta_eib1 - (
                           (CASE WHEN pcw.change_year = 2
                                  THEN pcw.old_fee
                                 ELSE pcw.cur_fee
                            END) - pcw.pen_second_year)*pcw.bt) / ta.v_nex
                    FROM ins.t_actuar_value ta
                    WHERE ta.p_cover_id = pcw.ver1_cover_id
                      AND ta.par_t = 1)*/
                    END);
    /**/
    UPDATE ins.t_actuar_value ta
       SET (ta.s1, ta.p1, ta.g1) =
           (SELECT (CASE
                     WHEN ta.par_t = 0 THEN
                      NULL
                     ELSE
                      pcw.s2
                   END)
                  ,(CASE
                     WHEN ta.par_t = 0 THEN
                      NULL
                     ELSE
                      ((CASE
                        WHEN pcw.change_year = 2 THEN
                         pcw.old_fee
                        ELSE
                         pcw.cur_fee
                      END) /*- pcw.pen_second_year*/
                      ) * (1 - ta.f_loading)
                   END)
                  ,(CASE
                     WHEN ta.par_t = 0 THEN
                      NULL
                     ELSE
                      ((CASE
                        WHEN pcw.change_year = 2 THEN
                         pcw.old_fee
                        ELSE
                         pcw.cur_fee
                      END) - pcw.pen_second_year)
                   END)
              FROM ins.t_inform_cover pcw
             WHERE pcw.ver1_cover_id = ta.p_cover_id);
    FOR cur IN (SELECT ta.par_t
                      ,ta.g1
                      ,ta.p_cover_id
                      ,ta.opt_brief
                  FROM ins.t_actuar_value ta
                 ORDER BY ta.p_cover_id
                         ,ta.par_t)
    LOOP
      IF cur.par_t = 0
      THEN
        UPDATE ins.t_actuar_value ta
           SET ta.sumg1 = NULL
         WHERE ta.p_cover_id = cur.p_cover_id
           AND ta.par_t = cur.par_t;
      END IF;
      /*IF cur.opt_brief = 'PEPR_A' THEN*/
      IF cur.par_t = 1
      THEN
        UPDATE ins.t_actuar_value ta
           SET ta.sumg1 = ta.cur_fee
         WHERE ta.p_cover_id = cur.p_cover_id
           AND ta.par_t = cur.par_t;
      END IF;
      IF cur.par_t > 1
      THEN
        UPDATE ins.t_actuar_value ta
           SET ta.sumg1 =
               (SELECT nvl(taa.sumg1, 0) + ta.g1
                  FROM ins.t_actuar_value taa
                 WHERE taa.p_cover_id = cur.p_cover_id
                   AND taa.par_t = cur.par_t - 1)
         WHERE ta.p_cover_id = cur.p_cover_id
           AND ta.par_t = cur.par_t;
      END IF;
      /*ELSE
        IF cur.par_t = 1 THEN
          UPDATE ins.t_actuar_value ta
          SET ta.sumg1 = 0
          WHERE ta.p_cover_id = cur.p_cover_id
            AND ta.par_t = cur.par_t;
        END IF;
        IF cur.par_t > 1 THEN
          UPDATE ins.t_actuar_value ta
          SET ta.sumg1 = (SELECT taa.sumg1 + ta.g1
                          FROM ins.t_actuar_value taa
                          WHERE taa.p_cover_id = cur.p_cover_id
                            AND taa.par_t = cur.par_t - 1) 
          WHERE ta.p_cover_id = cur.p_cover_id
            AND ta.par_t = cur.par_t;
        END IF;
      END IF;*/
    END LOOP;
    /**/
    UPDATE ins.t_actuar_value ta
       SET ta.tv_p2 = CASE
                        WHEN ta.par_t = 0 THEN
                         NULL
                        ELSE
                         ta.s1 * ta.v_nex + ta.sumg1 * ta.v_a1xn + ta.g1 * ta.v_ia1xn -
                         ta.p1 * ta.v_a_xn
                      END;
  
    UPDATE ins.t_actuar_value tat
       SET tat.tv_p3 =
           (SELECT CASE
                     WHEN (SELECT t.cur_fee
                             FROM ins.t_actuar_value t
                            WHERE t.par_t = 2
                              AND t.p_cover_id = ta.p_cover_id) =
                          (SELECT t.cur_fee
                             FROM ins.t_actuar_value t
                            WHERE t.par_t = 1
                              AND t.p_cover_id = ta.p_cover_id) THEN
                      ta.net_res
                     ELSE
                      ta.tv_p2
                   END
              FROM ins.t_actuar_value ta
             WHERE ta.p_cover_id = tat.p_cover_id
               AND ta.par_t = 2)
     WHERE tat.par_t = 2;
    /*изменение вклада 1 год*/
    UPDATE ins.t_inform_cover pcw
       SET pcw.delta_deposit1 =
           (SELECT (w_for_distrib * reserve_distrib) - (w_for_take * reserve_distrib) delta_res1
              FROM (SELECT (SELECT CASE
                                     WHEN (a.btype_recalc_b6 = 'из одной в две' OR
                                          a.btype_recalc_b6 = 'из двух в одну' OR
                                          a.btype_recalc_b6 = 'из одной в одну') THEN
                                      - ((1 - a.bpriznak1) * (a.f2 / 100) *
                                         (SELECT ta.savings
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.bp_cover_id
                                             AND ta.par_t = 1) +
                                         (1 - a.apriznak1) * (a.f3 / 100) *
                                         (SELECT ta.savings
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.ap_cover_id
                                             AND ta.par_t = 1) +
                                         (1 - a.cpriznak1) * (a.f4 / 100) *
                                         (SELECT ta.savings
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.cp_cover_id
                                             AND ta.par_t = 1))
                                     ELSE
                                      0
                                   END reserve_distrib
                              FROM (SELECT pcc.opt_brief      c
                                          ,pcc.ver1_cover_id  cp_cover_id
                                          ,pcc.delta_w1       f4
                                          ,pcc.type_recalc_b6 ctype_recalc_b6
                                          ,pcc.priznak1       cpriznak1
                                          ,pca.opt_brief      a
                                          ,pca.ver1_cover_id  ap_cover_id
                                          ,pca.delta_w1       f3
                                          ,pca.type_recalc_b6 atype_recalc_b6
                                          ,pca.priznak1       apriznak1
                                          ,pcb.opt_brief      b
                                          ,pcb.ver1_cover_id  bp_cover_id
                                          ,pcb.delta_w1       f2
                                          ,pcb.type_recalc_b6 btype_recalc_b6
                                          ,pcb.priznak1       bpriznak1
                                      FROM ins.t_inform_cover pcc
                                          ,ins.t_inform_cover pca
                                          ,ins.t_inform_cover pcb
                                     WHERE pcc.opt_brief = 'PEPR_C'
                                       AND pca.opt_brief = 'PEPR_A'
                                       AND pcb.opt_brief = 'PEPR_B') a) reserve_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak1) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((pc.delta_w1 * pc.priznak1) /
                              (SELECT SUM(pca.delta_w1 * pca.priznak1) FROM ins.t_inform_cover pca))
                           END w_for_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak1) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((1 - pc.priznak1) * pc.delta_w1 /
                              (SELECT SUM((1 - pca.priznak1) * pca.delta_w1) FROM ins.t_inform_cover pca))
                           END w_for_take
                          ,pc.ver1_cover_id
                          ,pc.opt_brief
                      FROM ins.t_inform_cover pc) b
             WHERE b.ver1_cover_id = pcw.ver1_cover_id);
    /*второй год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT (pkg_change_anniversary.get_savings(pc.ver1_cover_id
                                                      ,pc.start_date
                                                      ,trunc(pc.end_date)
                                                      ,ta.par_t
                                                      ,(SELECT tat.net_prem_act
                                                         FROM ins.t_actuar_value tat
                                                        WHERE tat.par_t = 1
                                                          AND tat.p_cover_id = pc.ver1_cover_id)
                                                      ,ta.net_prem_act)) /** 0.99*/ /*Заявка №182604*/
              FROM ins.t_inform_cover pc
             WHERE pc.ver1_cover_id = ta.p_cover_id)
     WHERE ta.par_t = 2;
    /*EIB theor 2-ий год*/
    UPDATE ins.t_actuar_value t SET t.eib_theor = t.savings - t.tv_p3 WHERE t.par_t = 2;
    /*delta_res2*/
    UPDATE ins.t_inform_cover pcw
       SET pcw.delta_res2 =
           (SELECT (w_for_distrib * reserve_distrib) - (w_for_take * reserve_distrib) delta_res1
              FROM (SELECT (SELECT CASE
                                     WHEN (a.btype_recalc_b6 = 'из одной в две' OR
                                          a.btype_recalc_b6 = 'из двух в одну' OR
                                          a.btype_recalc_b6 = 'из одной в одну') THEN
                                      - ((1 - a.bpriznak2) * (a.f2 / 100) *
                                         (SELECT ta.tv_p3
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.bp_cover_id
                                             AND ta.par_t = 2) +
                                         (1 - a.apriznak2) * (a.f3 / 100) *
                                         (SELECT ta.tv_p3
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.ap_cover_id
                                             AND ta.par_t = 2) +
                                         (1 - a.cpriznak2) * (a.f4 / 100) *
                                         (SELECT ta.tv_p3
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.cp_cover_id
                                             AND ta.par_t = 2))
                                     ELSE
                                      0
                                   END reserve_distrib
                              FROM (SELECT pcc.opt_brief      c
                                          ,pcc.ver1_cover_id  cp_cover_id
                                          ,pcc.delta_w2       f4
                                          ,pcc.type_recalc_b7 ctype_recalc_b6
                                          ,pcc.priznak2       cpriznak2
                                          ,pca.opt_brief      a
                                          ,pca.ver1_cover_id  ap_cover_id
                                          ,pca.delta_w2       f3
                                          ,pca.type_recalc_b7 atype_recalc_b6
                                          ,pca.priznak2       apriznak2
                                          ,pcb.opt_brief      b
                                          ,pcb.ver1_cover_id  bp_cover_id
                                          ,pcb.delta_w2       f2
                                          ,pcb.type_recalc_b7 btype_recalc_b6
                                          ,pcb.priznak2       bpriznak2
                                      FROM ins.t_inform_cover pcc
                                          ,ins.t_inform_cover pca
                                          ,ins.t_inform_cover pcb
                                     WHERE pcc.opt_brief = 'PEPR_C'
                                       AND pca.opt_brief = 'PEPR_A'
                                       AND pcb.opt_brief = 'PEPR_B') a) reserve_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak2) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((pc.delta_w2 * pc.priznak2) /
                              (SELECT SUM(pca.delta_w2 * pca.priznak2) FROM ins.t_inform_cover pca))
                           END w_for_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak2) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((1 - pc.priznak2) * pc.delta_w2 /
                              (SELECT SUM((1 - pca.priznak2) * pca.delta_w2) FROM ins.t_inform_cover pca))
                           END w_for_take
                          ,pc.ver1_cover_id
                          ,pc.opt_brief
                      FROM ins.t_inform_cover pc) b
             WHERE b.ver1_cover_id = pcw.ver1_cover_id);
    /*delta_eib2*/
    UPDATE ins.t_inform_cover pcw
       SET pcw.delta_eib2 =
           (SELECT ((greatest(reserve_distrib * w_for_distrib, 0) -
                   (SELECT SUM(v.pen_third_year) FROM ins.t_inform_cover v) * w_for_distrib)) -
                   abs(w_for_take * reserve_distrib) delta_res1
              FROM (SELECT (SELECT CASE
                                     WHEN (a.btype_recalc_b6 = 'из одной в две' OR
                                          a.btype_recalc_b6 = 'из двух в одну' OR
                                          a.btype_recalc_b6 = 'из одной в одну') THEN
                                      - ((1 - a.bpriznak2) * (a.f2 / 100) *
                                         (SELECT ta.eib_theor
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.bp_cover_id
                                             AND ta.par_t = 2) +
                                         (1 - a.apriznak2) * (a.f3 / 100) *
                                         (SELECT ta.eib_theor
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.ap_cover_id
                                             AND ta.par_t = 2) +
                                         (1 - a.cpriznak2) * (a.f4 / 100) *
                                         (SELECT ta.eib_theor
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.cp_cover_id
                                             AND ta.par_t = 2))
                                     ELSE
                                      0
                                   END reserve_distrib
                              FROM (SELECT pcc.opt_brief      c
                                          ,pcc.ver1_cover_id  cp_cover_id
                                          ,pcc.delta_w2       f4
                                          ,pcc.type_recalc_b7 ctype_recalc_b6
                                          ,pcc.priznak2       cpriznak2
                                          ,pca.opt_brief      a
                                          ,pca.ver1_cover_id  ap_cover_id
                                          ,pca.delta_w2       f3
                                          ,pca.type_recalc_b7 atype_recalc_b6
                                          ,pca.priznak2       apriznak2
                                          ,pcb.opt_brief      b
                                          ,pcb.ver1_cover_id  bp_cover_id
                                          ,pcb.delta_w2       f2
                                          ,pcb.type_recalc_b7 btype_recalc_b6
                                          ,pcb.priznak2       bpriznak2
                                      FROM ins.t_inform_cover pcc
                                          ,ins.t_inform_cover pca
                                          ,ins.t_inform_cover pcb
                                     WHERE pcc.opt_brief = 'PEPR_C'
                                       AND pca.opt_brief = 'PEPR_A'
                                       AND pcb.opt_brief = 'PEPR_B') a) reserve_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak2) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((pc.delta_w2 * pc.priznak2) /
                              (SELECT SUM(pca.delta_w2 * pca.priznak2) FROM ins.t_inform_cover pca))
                           END w_for_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak2) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((1 - pc.priznak2) * pc.delta_w2 /
                              (SELECT SUM((1 - pca.priznak2) * pca.delta_w2) FROM ins.t_inform_cover pca))
                           END w_for_take
                          ,pc.ver1_cover_id
                          ,pc.opt_brief
                      FROM ins.t_inform_cover pc) b
             WHERE b.ver1_cover_id = pcw.ver1_cover_id);
    /**/
    /*изменение вклада 2 год*/
    UPDATE ins.t_inform_cover pcw
       SET pcw.delta_deposit2 =
           (SELECT (w_for_distrib * reserve_distrib) - (w_for_take * reserve_distrib) delta_res1
              FROM (SELECT (SELECT CASE
                                     WHEN (a.btype_recalc_b6 = 'из одной в две' OR
                                          a.btype_recalc_b6 = 'из двух в одну' OR
                                          a.btype_recalc_b6 = 'из одной в одну') THEN
                                      - ((1 - a.bpriznak1) * (a.f2 / 100) *
                                         (SELECT ta.savings
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.bp_cover_id
                                             AND ta.par_t = 2) +
                                         (1 - a.apriznak1) * (a.f3 / 100) *
                                         (SELECT ta.savings
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.ap_cover_id
                                             AND ta.par_t = 2) +
                                         (1 - a.cpriznak1) * (a.f4 / 100) *
                                         (SELECT ta.savings
                                            FROM ins.t_actuar_value ta
                                           WHERE ta.p_cover_id = a.cp_cover_id
                                             AND ta.par_t = 2))
                                     ELSE
                                      0
                                   END reserve_distrib
                              FROM (SELECT pcc.opt_brief      c
                                          ,pcc.ver1_cover_id  cp_cover_id
                                          ,pcc.delta_w2       f4
                                          ,pcc.type_recalc_b7 ctype_recalc_b6
                                          ,pcc.priznak2       cpriznak1
                                          ,pca.opt_brief      a
                                          ,pca.ver1_cover_id  ap_cover_id
                                          ,pca.delta_w2       f3
                                          ,pca.type_recalc_b7 atype_recalc_b6
                                          ,pca.priznak2       apriznak1
                                          ,pcb.opt_brief      b
                                          ,pcb.ver1_cover_id  bp_cover_id
                                          ,pcb.delta_w2       f2
                                          ,pcb.type_recalc_b7 btype_recalc_b6
                                          ,pcb.priznak2       bpriznak1
                                      FROM ins.t_inform_cover pcc
                                          ,ins.t_inform_cover pca
                                          ,ins.t_inform_cover pcb
                                     WHERE pcc.opt_brief = 'PEPR_C'
                                       AND pca.opt_brief = 'PEPR_A'
                                       AND pcb.opt_brief = 'PEPR_B') a) reserve_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak2) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((pc.delta_w2 * pc.priznak2) /
                              (SELECT SUM(pca.delta_w2 * pca.priznak2) FROM ins.t_inform_cover pca))
                           END w_for_distrib
                          ,CASE
                             WHEN (SELECT SUM(pca.priznak2) FROM ins.t_inform_cover pca) = 0 THEN
                              0
                             ELSE
                              ((1 - pc.priznak2) * pc.delta_w2 /
                              (SELECT SUM((1 - pca.priznak2) * pca.delta_w2) FROM ins.t_inform_cover pca))
                           END w_for_take
                          ,pc.ver1_cover_id
                          ,pc.opt_brief
                      FROM ins.t_inform_cover pc) b
             WHERE b.ver1_cover_id = pcw.ver1_cover_id);
    /*третий год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT (pkg_change_anniversary.get_savings(pc.ver1_cover_id
                                                      ,pc.start_date
                                                      ,trunc(pc.end_date)
                                                      ,ta.par_t
                                                      ,(SELECT tat.net_prem_act
                                                         FROM ins.t_actuar_value tat
                                                        WHERE tat.par_t = 1
                                                          AND tat.p_cover_id = pc.ver1_cover_id)
                                                      ,(SELECT tat.net_prem_act
                                                         FROM ins.t_actuar_value tat
                                                        WHERE tat.par_t = 2
                                                          AND tat.p_cover_id = pc.ver1_cover_id)
                                                      ,ta.net_prem_act)) /** 0.99*/ /*Заявка №182604*/
              FROM ins.t_inform_cover pc
             WHERE pc.ver1_cover_id = ta.p_cover_id)
     WHERE ta.par_t = 3;
    /**/
    UPDATE ins.t_inform_cover pcw
       SET pcw.bt2 =
           (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
              FROM ins.t_actuar_value ta
             WHERE ta.p_cover_id = pcw.ver1_cover_id
               AND ta.par_t = 2);
    UPDATE ins.t_inform_cover pcw
       SET pcw.s3 = (CASE
                      WHEN (CASE
                             WHEN pcw.change_year = 2 THEN
                              pcw.old_fee
                             ELSE
                              pcw.cur_fee
                           END) = pcw.cur_fee THEN
                       pcw.s2
                      ELSE
                       pcw.s2 + ((CASE
                         WHEN pcw.change_year = 2 THEN
                          pcw.old_fee
                         ELSE
                          pcw.cur_fee
                       END) - pcw.cur_fee) * pcw.bt2 /
                       (SELECT ta.v_nex
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.p_cover_id = pcw.ver1_cover_id
                                    AND ta.par_t = 2) +
                       pcw.delta_eib2 / (SELECT ta.v_nex
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.p_cover_id = pcw.ver1_cover_id
                                            AND ta.par_t = 2) +
                       pcw.delta_res2 / (SELECT ta.v_nex
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.p_cover_id = pcw.ver1_cover_id
                                            AND ta.par_t = 2)
                    /*(SELECT (ta.tv_p3 + pcw.delta_res2 + pcw.delta_eib2 - (pcw.cur_fee - pcw.pen_third_year)*pcw.bt2) / ta.v_nex
                    FROM ins.t_actuar_value ta
                    WHERE ta.p_cover_id = pcw.ver1_cover_id
                      AND ta.par_t = 2
                    )*/
                    END);
    /**/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ANOTHER_UPDATE: ' || SQLERRM);
  END another_update;

  /**/
  FUNCTION get_savings
  (
    par_cover_id       NUMBER
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_t              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_net_prem_act_2 NUMBER DEFAULT 0
   ,par_net_prem_act_3 NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    t_type_prog             VARCHAR2(25);
    v_yield_min             NUMBER;
    res_1                   NUMBER := 0;
    res_2                   NUMBER := 0;
    res_3                   NUMBER := 0;
    v_days                  NUMBER := 0;
    v_date_begin            DATE;
    v_delta_deposit1        NUMBER := 0;
    v_delta_deposit2        NUMBER := 0;
    v_loop                  NUMBER := 12;
    v_days_f15              NUMBER;
    v_days_f39              NUMBER;
    v_pol_header_start_date DATE;
  BEGIN
  
    SELECT pc.opt_brief
      INTO t_type_prog
      FROM ins.t_inform_cover pc
     WHERE pc.ver1_cover_id = par_cover_id;
  
    FOR i IN 1 .. v_loop * par_t
    LOOP
      IF i = 1
      THEN
        v_days := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
      ELSE
        v_days := 30;
      END IF;
      v_date_begin := trunc(par_date_begin, 'MM');
    
      --Чирков/добавлено условие/ по заявке 250261: таблицы доходности
      --****************************   
      v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
    
      IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
      THEN
        SELECT CASE t_type_prog
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield_profile ty
         WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
      ELSE
        SELECT CASE t_type_prog
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield ty
         WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
      END IF;
      --*****************************       
    
      IF i = 1
      THEN
        res_1 := ROUND(par_net_prem_act_1 * (1 + (v_yield_min / 30) * v_days), 2);
      ELSIF i = 13
      THEN
        v_days_f15 := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39 := par_date_end - trunc(par_date_end, 'MM') + 1;
        SELECT nvl(pc.delta_deposit1, 0)
          INTO v_delta_deposit1
          FROM ins.t_inform_cover pc
         WHERE pc.ver1_cover_id = par_cover_id;
        IF v_delta_deposit1 = 0
        THEN
          res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
        ELSE
          res_1 := ROUND((res_1 * (1 + v_yield_min * v_days_f39 / 30) + v_delta_deposit1) *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        END IF;
      ELSE
        res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
      END IF;
    END LOOP;
  
    FOR i IN 1 .. v_loop * (par_t - 1)
    LOOP
      IF i = 1
      THEN
        v_days := trunc(ADD_MONTHS(par_date_begin, 13), 'MM') - ADD_MONTHS(par_date_begin, 12) - 1;
      ELSE
        v_days := 30;
      END IF;
      v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12), 'MM');
    
      --Чирков/добавлено условие/ по заявке 250261: таблицы доходности  
      IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
      THEN
        SELECT CASE t_type_prog
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield_profile ty
         WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
      ELSE
        SELECT CASE t_type_prog
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield ty
         WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
      END IF;
      --         
    
      IF i = 1
      THEN
        res_2 := ROUND(par_net_prem_act_2 * (1 + (v_yield_min / 30) * v_days), 2);
      ELSIF i = 13
      THEN
        v_days_f15 := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39 := par_date_end - trunc(par_date_end, 'MM') + 1;
        SELECT nvl(pc.delta_deposit2, 0)
          INTO v_delta_deposit2
          FROM ins.t_inform_cover pc
         WHERE pc.ver1_cover_id = par_cover_id;
        IF v_delta_deposit2 = 0
        THEN
          res_2 := ROUND(res_2 * (1 + v_yield_min), 2);
        ELSE
          res_2 := ROUND((res_2 * (1 + v_yield_min * v_days_f39 / 30) + v_delta_deposit2) *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        END IF;
      ELSE
        res_2 := ROUND(res_2 * (1 + v_yield_min), 2);
      END IF;
    
    END LOOP;
  
    FOR i IN 1 .. v_loop * (par_t - 2)
    LOOP
      IF i = 1
      THEN
        v_days := trunc(ADD_MONTHS(par_date_begin, 25), 'MM') - ADD_MONTHS(par_date_begin, 24) - 1;
      ELSE
        v_days := 30;
      END IF;
      v_date_begin := trunc(ADD_MONTHS(par_date_begin, 24), 'MM');
    
      --Чирков/добавлено условие/ по заявке 250261: таблицы доходности  
      IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
      THEN
        SELECT CASE t_type_prog
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield_profile ty
         WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
      ELSE
        SELECT CASE t_type_prog
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield ty
         WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
      END IF;
      --                
    
      IF i = 1
      THEN
        res_3 := ROUND(par_net_prem_act_3 * (1 + (v_yield_min / 30) * v_days), 2);
      ELSIF i = 13
      THEN
        v_days_f39 := par_date_end - trunc(par_date_end, 'MM') + 1;
        res_3      := ROUND(res_3 * (1 + (v_yield_min / 30) * v_days_f39), 2);
      ELSE
        res_3 := ROUND(res_3 * (1 + v_yield_min), 2);
      END IF;
    
    END LOOP;
  
    RETURN ROUND(res_1 + res_2 + res_3, 2);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_SAVINGS: ' || SQLERRM);
  END get_savings;

  /**/
  FUNCTION get_savings_investorplus
  (
    par_cover_id       NUMBER
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_t              NUMBER
   ,par_opt_brief      VARCHAR2
   ,par_n              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_net_prem_act_2 NUMBER DEFAULT 0
   ,par_net_prem_act_3 NUMBER DEFAULT 0
   ,par_net_prem_act_4 NUMBER DEFAULT 0
   ,par_net_prem_act_5 NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    t_type_prog                 VARCHAR2(25);
    v_yield_min                 NUMBER;
    res_1                       NUMBER := 0;
    res_2                       NUMBER := 0;
    res_3                       NUMBER := 0;
    res_4                       NUMBER := 0;
    res_5                       NUMBER := 0;
    v_days                      NUMBER := 0;
    v_date_begin                DATE;
    v_delta_deposit1            NUMBER := 0;
    v_delta_deposit2            NUMBER := 0;
    v_delta_deposit3            NUMBER := 0;
    v_delta_deposit4            NUMBER := 0;
    v_delta_deposit5            NUMBER := 0;
    v_loop                      NUMBER := 12;
    v_days_f15                  NUMBER;
    v_days_f39                  NUMBER;
    v_pol_header_start_date     DATE;
    v_share_of_risky_assets     NUMBER := 20 / 100;
    v_share_in_defensive_assets NUMBER := 80 / 100;
    v_risk_of_accumulation      NUMBER := 0;
    v_protective_storage        NUMBER := 0;
    v_current_par_n             NUMBER;
    v_i13                       NUMBER := 0;
  BEGIN
  
    FOR k IN 1 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 1
        THEN
          res_1 := ROUND(par_net_prem_act_1 * v_share_of_risky_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_1 := ROUND(res_1 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 2
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit1
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit1 = 0
            THEN
              res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
            ELSE
              res_1 := ROUND((res_1 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit1 * v_share_of_risky_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 2 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 2
        THEN
          res_2 := ROUND(par_net_prem_act_2 * v_share_of_risky_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_2 := ROUND(res_2 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 3
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit2
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit2 = 0
            THEN
              res_2 := ROUND(res_2 * (1 + v_yield_min), 2);
            ELSE
              res_2 := ROUND((res_2 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit2 * v_share_of_risky_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_2 := ROUND(res_2 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 3 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 3
        THEN
          res_3 := ROUND(par_net_prem_act_3 * v_share_of_risky_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_3 := ROUND(res_3 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 4
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit3
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit3 = 0
            THEN
              res_3 := ROUND(res_3 * (1 + v_yield_min), 2);
            ELSE
              res_3 := ROUND((res_3 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit3 * v_share_of_risky_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_3 := ROUND(res_3 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 4 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 4
        THEN
          res_4 := ROUND(par_net_prem_act_4 * v_share_of_risky_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_4 := ROUND(res_4 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 5
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit4
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit4 = 0
            THEN
              res_4 := ROUND(res_4 * (1 + v_yield_min), 2);
            ELSE
              res_4 := ROUND((res_4 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit4 * v_share_of_risky_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_4 := ROUND(res_4 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 5 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_peril_min
                   WHEN 'GOLD' THEN
                    ty.gold_peril_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 5
        THEN
          res_5 := ROUND(par_net_prem_act_5 * v_share_of_risky_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_5 := ROUND(res_5 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k > 5
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit5
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit5 = 0
            THEN
              res_5 := ROUND(res_5 * (1 + v_yield_min), 2);
            ELSE
              res_5 := ROUND((res_5 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit5 * v_share_of_risky_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_5 := ROUND(res_5 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    v_risk_of_accumulation := ROUND(res_1 + res_2 + res_3 + res_4 + res_5, 2);
  
    /*Рассчитаем накопления по защитной части*/
    res_1 := 0;
    res_2 := 0;
    res_3 := 0;
    res_4 := 0;
    res_5 := 0;
  
    FOR k IN 1 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 1
        THEN
          res_1 := ROUND(par_net_prem_act_1 * v_share_in_defensive_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_1 := ROUND(res_1 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 2
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit1
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit1 = 0
            THEN
              res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
            ELSE
              res_1 := ROUND((res_1 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit1 * v_share_in_defensive_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 2 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 2
        THEN
          res_2 := ROUND(par_net_prem_act_2 * v_share_in_defensive_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_2 := ROUND(res_2 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 3
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit2
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit2 = 0
            THEN
              res_2 := ROUND(res_2 * (1 + v_yield_min), 2);
            ELSE
              res_2 := ROUND((res_2 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit2 * v_share_in_defensive_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_2 := ROUND(res_2 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 3 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 3
        THEN
          res_3 := ROUND(par_net_prem_act_3 * v_share_in_defensive_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_3 := ROUND(res_3 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 4
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit3
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit3 = 0
            THEN
              res_3 := ROUND(res_3 * (1 + v_yield_min), 2);
            ELSE
              res_3 := ROUND((res_3 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit3 * v_share_in_defensive_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_3 := ROUND(res_3 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 4 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 4
        THEN
          res_4 := ROUND(par_net_prem_act_4 * v_share_in_defensive_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_4 := ROUND(res_4 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k = 5
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit4
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit4 = 0
            THEN
              res_4 := ROUND(res_4 * (1 + v_yield_min), 2);
            ELSE
              res_4 := ROUND((res_4 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit4 * v_share_in_defensive_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_4 := ROUND(res_4 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    FOR k IN 5 .. par_t
    LOOP
      IF par_t = par_n
         AND k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        v_days_f15              := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
        v_days_f39              := par_date_end - trunc(par_date_end, 'MM') + 1;
        v_days                  := 30;
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'OIL' THEN
                    ty.petroleum_prot_min
                   WHEN 'GOLD' THEN
                    ty.gold_prot_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
      
        IF i = 1
           AND k = 5
        THEN
          res_5 := ROUND(par_net_prem_act_5 * v_share_in_defensive_assets *
                         (1 + (v_yield_min / 30) * v_days_f15)
                        ,2);
        ELSIF i = 13
        THEN
          res_5 := ROUND(res_5 * (1 + (v_yield_min / 30) * v_days_f39), 2);
        ELSE
          IF i = 1
             AND k > 5
          THEN
            SELECT nvl(pc.delta_deposit, 0)
              INTO v_delta_deposit5
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = par_opt_brief
               AND pc.change_year = k;
            IF v_delta_deposit5 = 0
            THEN
              res_5 := ROUND(res_5 * (1 + v_yield_min), 2);
            ELSE
              res_5 := ROUND((res_5 * (1 + v_yield_min * v_days_f39 / 30) +
                             v_delta_deposit5 * v_share_in_defensive_assets) *
                             (1 + (v_yield_min / 30) * v_days_f15)
                            ,2);
            END IF;
          ELSE
            res_5 := ROUND(res_5 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  
    v_protective_storage := ROUND(res_1 + res_2 + res_3 + res_4 + res_5, 2);
  
    RETURN v_risk_of_accumulation + v_protective_storage;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_SAVINGS_INVESTORPLUS: ' || SQLERRM);
  END get_savings_investorplus;

  /**/
  PROCEDURE change_strategy_investor_lump(par_policy_id NUMBER) IS
    proc_name          VARCHAR2(30) := 'CHANGE_STRATEGY_INVESTOR_LUMP';
    is_continue_annual NUMBER;
    is_continue_quart  NUMBER;
    pv_pol_header_id   NUMBER;
    pv_val_period      NUMBER;
    no_period EXCEPTION;
  BEGIN
  
    SELECT COUNT(*)
      INTO is_continue_annual
      FROM ins.p_policy            pol
          ,ins.p_pol_addendum_type ppat
          ,ins.t_addendum_type     t
          ,ins.p_pol_header        ph
          ,ins.t_product           prod
     WHERE pol.policy_id = ppat.p_policy_id
       AND ppat.t_addendum_type_id = t.t_addendum_type_id
       AND t.brief IN ('CHANGE_STRATEGY_OF_THE_PREMIUM')
       AND pol.pol_header_id = ph.policy_header_id
       AND ph.product_id = prod.product_id
       AND prod.brief IN ('INVESTOR_LUMP'
                         ,'INVESTOR_LUMP_OLD'
                         ,'Invest_in_future'
                         ,'INVESTOR_LUMP_ALPHA'
                         ,'INVESTOR_LUMP_AKBARS'
                         ,'INVESTOR_LUMP_GLOBEKS'
                         ,'INVESTOR_LUMP_VTB5'
                         ,'INVESTOR_LUMP_HKF5'
                         ,'INVESTOR_LUMP_TATFOND'
                         ,'INVESTOR_LUMP_HKF3')
       AND pol.policy_id = par_policy_id;
    SELECT COUNT(*)
      INTO is_continue_quart
      FROM ins.p_policy            pol
          ,ins.p_pol_addendum_type ppat
          ,ins.t_addendum_type     t
          ,ins.p_pol_header        ph
          ,ins.t_product           prod
     WHERE pol.policy_id = ppat.p_policy_id
       AND ppat.t_addendum_type_id = t.t_addendum_type_id
       AND t.brief IN ('CHANGE_STRATEGY_QUARTER')
       AND pol.pol_header_id = ph.policy_header_id
       AND ph.product_id = prod.product_id
       AND prod.brief IN ('Priority_Invest(lump)')
       AND pol.policy_id = par_policy_id;
    BEGIN
      SELECT p.pol_header_id
            ,MONTHS_BETWEEN(p.end_date + 24 / 60 / 3600, ph.start_date) / 12
        INTO pv_pol_header_id
            ,pv_val_period
        FROM ins.p_policy     p
            ,ins.p_pol_header ph
       WHERE p.policy_id = par_policy_id
         AND p.pol_header_id = ph.policy_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        pv_pol_header_id := 0;
        pv_val_period    := 0;
    END;
    IF is_continue_annual > 0
    THEN
      DELETE FROM ins.t_inform_cover_lump;
      /**/
      ins.pkg_change_anniversary.add_inform_cover(pv_pol_header_id, pv_val_period);
    
      ins.pkg_change_anniversary.add_actuar_value(par_policy_id);
      ins.pkg_change_anniversary.add_get_weigth(pv_val_period);
      ins.pkg_change_anniversary.add_another_update(pv_val_period);
    
      UPDATE /*+ USE_NL(p cva)*/ ins.p_cover p
         SET (p.ins_amount
            ,p.is_handchange_amount
            ,p.is_handchange_tariff
            ,p.is_handchange_fee
            ,p.is_handchange_premium) =
             (SELECT ROUND(va.s1, 0)
                    ,1
                    ,1
                    ,1
                    ,1
                FROM ins.t_actuar_value      va
                    ,ins.t_inform_cover_lump lp
               WHERE p.p_cover_id = lp.cover_id
                 AND va.par_t = pv_val_period
                 AND lp.opt_brief = va.opt_brief
                 AND lp.change_year = va.par_t)
       WHERE EXISTS (SELECT NULL
                FROM ins.t_actuar_value      v
                    ,ins.t_inform_cover_lump lpv
               WHERE p.p_cover_id = lpv.cover_id
                 AND v.par_t = pv_val_period
                 AND lpv.opt_brief = v.opt_brief
                 AND lpv.change_year = v.par_t);
    
      DELETE FROM ins.p_pol_change ch WHERE ch.p_policy_id = par_policy_id;
      INSERT INTO ins.p_pol_change
        (p_pol_change_id
        ,p_policy_id
        ,p_cover_id
        ,t_prod_line_id
        ,net_premium_act
        ,acc_net_prem_after_change
        ,delta_deposit1
        ,delta_deposit2
        ,delta_deposit3
        ,delta_deposit4
        ,penalty
        ,par_t
        ,start_date_pc
        ,end_date_pc
        ,ins_amount
        ,fee)
        SELECT sq_p_pol_change.nextval
              ,par_policy_id policy_id /*ta.policy_id*/
              ,ta.p_cover_id
              ,cv.pl_id t_product_line_id
              ,ta.net_prem_act
              ,CASE
                 WHEN ta.par_t = 1 THEN
                  ta.net_prem_act
                 WHEN ta.par_t = 2 THEN
                  (CASE
                    WHEN ta.net_prem_act != 0 THEN
                     (SELECT SUM(v.net_prem_act)
                        FROM ins.t_actuar_value v
                       WHERE v.par_t IN (1, 2)
                         AND v.p_cover_id = ta.p_cover_id) +
                     (SELECT lp.delta_deposit
                        FROM ins.t_inform_cover_lump lp
                       WHERE lp.opt_brief = cv.opt_brief
                         AND lp.change_year = 2)
                    ELSE
                     0
                  END)
                 WHEN ta.par_t = 3 THEN
                  (CASE
                    WHEN ta.net_prem_act != 0 THEN
                     (SELECT SUM(v.net_prem_act)
                        FROM ins.t_actuar_value v
                       WHERE v.par_t IN (1, 2, 3)
                         AND v.p_cover_id = ta.p_cover_id) +
                     (SELECT lp.delta_deposit
                        FROM ins.t_inform_cover_lump lp
                       WHERE lp.opt_brief = cv.opt_brief
                         AND lp.change_year = 3)
                    ELSE
                     0
                  END)
                 WHEN ta.par_t = 4 THEN
                  (CASE
                    WHEN ta.net_prem_act != 0 THEN
                     (SELECT SUM(v.net_prem_act)
                        FROM ins.t_actuar_value v
                       WHERE v.par_t IN (1, 2, 3, 4)
                         AND v.p_cover_id = ta.p_cover_id) +
                     (SELECT lp.delta_deposit
                        FROM ins.t_inform_cover_lump lp
                       WHERE lp.opt_brief = cv.opt_brief
                         AND lp.change_year = 4)
                    ELSE
                     0
                  END)
                 WHEN ta.par_t = 5 THEN
                  (CASE
                    WHEN ta.net_prem_act != 0 THEN
                     (SELECT SUM(v.net_prem_act)
                        FROM ins.t_actuar_value v
                       WHERE v.par_t IN (1, 2, 3, 4, 5)
                         AND v.p_cover_id = ta.p_cover_id) +
                     (SELECT lp.delta_deposit
                        FROM ins.t_inform_cover_lump lp
                       WHERE lp.opt_brief = cv.opt_brief
                         AND lp.change_year = 5)
                    ELSE
                     0
                  END)
               END
              ,(SELECT lp.delta_deposit
                  FROM ins.t_inform_cover_lump lp
                 WHERE lp.opt_brief = cv.opt_brief
                   AND lp.change_year = 2) delta_deposit1
              ,(SELECT lp.delta_deposit
                  FROM ins.t_inform_cover_lump lp
                 WHERE lp.opt_brief = cv.opt_brief
                   AND lp.change_year = 3) delta_deposit2
              ,(SELECT lp.delta_deposit
                  FROM ins.t_inform_cover_lump lp
                 WHERE lp.opt_brief = cv.opt_brief
                   AND lp.change_year = 4) delta_deposit3
              ,(SELECT lp.delta_deposit
                  FROM ins.t_inform_cover_lump lp
                 WHERE lp.opt_brief = cv.opt_brief
                   AND lp.change_year = 5) delta_deposit4
              ,ROUND(cv.pen_for_year, 2) pen_for_year
              ,ta.par_t
              ,cv.start_date
              ,cv.end_date
              ,CASE
                 WHEN ta.par_t = 1 THEN
                  ROUND(ta.sa, 2)
                 ELSE
                  ROUND(ta.s1, 2)
               END
              ,ta.cur_fee
          FROM ins.t_actuar_value      ta
              ,ins.t_inform_cover_lump cv
         WHERE ta.par_t != 0
           AND ta.opt_brief = cv.opt_brief
           AND ta.par_t = cv.change_year;
    END IF;
  
    IF is_continue_quart > 0
    THEN
      DELETE FROM ins.t_inform_cover_lump;
      /**/
      ins.pkg_change_anniversary.inform_cover_quart(pv_pol_header_id, pv_val_period, par_policy_id);
      ins.pkg_change_anniversary.actuar_value_quart(par_policy_id);
      ins.pkg_change_anniversary.get_weigth_quart(pv_val_period * 4);
      ins.pkg_change_anniversary.another_update_quart(pv_val_period * 4);
      /**/
      UPDATE /*+ USE_NL(p cva)*/ ins.p_cover p
         SET (p.ins_amount
            ,p.is_handchange_amount
            ,p.is_handchange_tariff
            ,p.is_handchange_fee
            ,p.is_handchange_premium) =
             (SELECT ROUND(va.s1, 0)
                    ,1
                    ,1
                    ,1
                    ,1
                FROM ins.t_actuar_value      va
                    ,ins.t_inform_cover_lump lp
               WHERE p.p_cover_id = lp.cover_id
                 AND lp.opt_brief = va.opt_brief
                 AND lp.quart_value = va.par_quart
                 AND lp.is_change = 1)
       WHERE EXISTS (SELECT NULL
                FROM ins.t_actuar_value      v
                    ,ins.t_inform_cover_lump lpv
               WHERE p.p_cover_id = lpv.cover_id
                 AND lpv.opt_brief = v.opt_brief
                 AND lpv.quart_value = v.par_quart
                 AND lpv.is_change = 1);
    END IF;
  
  EXCEPTION
    WHEN no_period THEN
      raise_application_error(-20001
                             ,'Внимание! Перераспределение вклада по Инвестор для периода ' ||
                              to_char(pv_val_period) ||
                              ' не реализован. Обратитесь в Управление актуарных расчетов.');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' || SQLERRM);
  END change_strategy_investor_lump;
  /**/
  PROCEDURE add_inform_cover
  (
    par_header_id  NUMBER
   ,par_val_period NUMBER
  ) IS
    proc_name    VARCHAR2(20) := 'ADD_INFORM_COVER';
    v_continue   BOOLEAN := FALSE;
    k            NUMBER := 0;
    proc_penalty NUMBER := 0.03;
  BEGIN
  
    IF par_val_period > 0
    THEN
      v_continue := TRUE;
    END IF;
  
    IF v_continue
    THEN
      FOR i IN 1 .. par_val_period
      LOOP
        INSERT INTO ins.t_inform_cover_lump
          (opt_brief
          ,header_id
          ,cover_id
          ,policy_id
          ,start_date
          ,end_date
          ,amount
          ,prem
          ,fee
          ,pl_id
          ,sum_prem
          ,deathrate_id
          ,fact_yield_rate
          ,sex
          ,age
          ,f_loading
          ,const_tariff
          ,change_year)
          SELECT opt.brief
                ,ph.policy_header_id
                ,pc.p_cover_id
                ,p.policy_id
                ,ph.start_date
                ,p.end_date
                ,pc.ins_amount
                ,pc.premium
                ,pc.fee
                ,pl.id pl_id
                ,(SELECT SUM(pca.premium)
                    FROM ins.p_cover            pca
                        ,ins.t_prod_line_option opta
                        ,ins.t_product_line     pla
                        ,ins.t_lob_line         lba
                   WHERE pca.as_asset_id = a.as_asset_id
                     AND pca.t_prod_line_option_id = opta.id
                     AND opta.product_line_id = pla.id
                     AND pla.description NOT IN
                         ('Административные издержки'
                         ,'Административные издержки на восстановление')
                     AND pla.t_lob_line_id = lba.t_lob_line_id
                     AND lba.brief != 'Penalty'
                     AND lba.t_lob_id NOT IN
                         (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) sum_prem
                ,decode(plr.func_id
                       ,NULL
                       ,plr.deathrate_id
                       ,ins.pkg_tariff_calc.calc_fun(plr.func_id
                                                    ,ins.ent.id_by_brief('P_COVER')
                                                    ,pc.p_cover_id)) deathrate_id
                ,pc.normrate_value fact_yield_rate
                ,decode(per.gender, 0, 'w', 1, 'm') sex
                ,pc.insured_age age
                ,pc.rvb_value
                ,(CASE
                   WHEN MONTHS_BETWEEN(p.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                    (CASE opt.brief
                      WHEN 'PEPR_A' THEN
                       0.9482
                      WHEN 'PEPR_A_PLUS' THEN
                       0.8052
                      WHEN 'PEPR_B' THEN
                       1.0070
                      WHEN 'OIL' THEN
                       2.77726
                      WHEN 'GOLD' THEN
                       2.77726
                    END)
                   ELSE
                    (CASE opt.brief
                      WHEN 'PEPR_A' THEN
                       0.9452
                      WHEN 'PEPR_A_PLUS' THEN
                       0.8043
                      WHEN 'PEPR_B' THEN
                       1.0492
                      WHEN 'OIL' THEN
                       4.6130
                      WHEN 'GOLD' THEN
                       4.6130
                    END)
                 END) const_tariff
                ,i
            FROM ins.p_pol_header       ph
                ,ins.p_policy           p
                ,ins.as_asset           a
                ,ins.as_assured         ass
                ,ins.cn_person          per
                ,ins.p_cover            pc
                ,ins.t_prod_line_option opt
                ,ins.t_product_line     pl
                ,ins.t_lob_line         lb
                ,ins.t_prod_line_rate   plr
           WHERE ph.policy_header_id = p.pol_header_id
             AND p.policy_id = a.p_policy_id
             AND a.as_asset_id = ass.as_assured_id
             AND ass.assured_contact_id = per.contact_id(+)
             AND a.as_asset_id = pc.as_asset_id
             AND pc.t_prod_line_option_id = opt.id
             AND opt.product_line_id = pl.id
             AND pl.id = plr.product_line_id
             AND ph.policy_header_id = par_header_id
             AND p.start_date = ADD_MONTHS(ph.start_date, 12 * (i - 1))
             AND pl.description NOT IN
                 ('Административные издержки'
                 ,'Административные издержки на восстановление')
             AND pl.t_lob_line_id = lb.t_lob_line_id
             AND lb.brief != 'Penalty'
             AND lb.t_lob_id NOT IN (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')
             AND p.version_num =
                 (SELECT MAX(ppl.version_num)
                    FROM ins.p_policy       ppl
                        ,ins.document       d
                        ,ins.doc_status_ref rf
                   WHERE ppl.pol_header_id = par_header_id
                     AND ppl.policy_id = d.document_id
                     AND d.doc_status_ref_id = rf.doc_status_ref_id
                     AND rf.brief != 'CANCEL'
                     AND ppl.start_date = ADD_MONTHS(ph.start_date, 12 * (i - 1)));
        IF SQL%ROWCOUNT = 0
        THEN
          k := k + 1;
          INSERT INTO ins.t_inform_cover_lump
            (opt_brief
            ,header_id
            ,cover_id
            ,policy_id
            ,start_date
            ,end_date
            ,amount
            ,prem
            ,fee
            ,pl_id
            ,sum_prem
            ,deathrate_id
            ,fact_yield_rate
            ,sex
            ,age
            ,f_loading
            ,const_tariff
            ,change_year)
            SELECT lp.opt_brief
                  ,lp.header_id
                  ,lp.cover_id
                  ,lp.policy_id
                  ,lp.start_date
                  ,lp.end_date
                  ,lp.amount
                  ,lp.prem
                  ,lp.fee
                  ,lp.pl_id
                  ,lp.sum_prem
                  ,lp.deathrate_id
                  ,lp.fact_yield_rate
                  ,lp.sex
                  ,lp.age
                  ,lp.f_loading
                  ,lp.const_tariff
                  ,lp.change_year + k
              FROM ins.t_inform_cover_lump lp
             WHERE lp.header_id = par_header_id
               AND lp.change_year = i - k;
        ELSE
          k := 0;
        END IF;
      
      END LOOP;
    END IF;
    /**/
    UPDATE ins.t_inform_cover_lump cv SET cv.perc_for_year = cv.fee / cv.sum_prem * 100;
  
    FOR i IN 1 .. par_val_period
    LOOP
      IF i = 1
      THEN
        UPDATE ins.t_inform_cover_lump cv SET cv.pen_for_year = 0 WHERE cv.change_year = i;
      ELSE
        UPDATE ins.t_inform_cover_lump cv
           SET cv.pen_for_year = greatest((SELECT l.fee
                                             FROM ins.t_inform_cover_lump l
                                            WHERE l.change_year = i - 1
                                              AND l.opt_brief = cv.opt_brief) -
                                          cv.sum_prem * (cv.fee / cv.sum_prem)
                                         ,0) * proc_penalty
              ,cv.delta_prem   = abs((SELECT cv.fee - l.fee
                                       FROM ins.t_inform_cover_lump l
                                      WHERE l.change_year = i - 1
                                        AND l.opt_brief = cv.opt_brief))
         WHERE cv.change_year = i;
      END IF;
    END LOOP;
    /**/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' || SQLERRM);
  END add_inform_cover;
  /**/
  PROCEDURE add_actuar_value(par_policy_id NUMBER) IS
    const_act_loading_3          NUMBER := 0.0613;
    const_act_loading_5          NUMBER := 0.0643;
    const_act_loading_fbase_5    NUMBER := 0.09;
    const_act_loading_fagr_5     NUMBER := 0.08;
    const_act_loading_fagrplus_5 NUMBER := 0.0643;
    const_act_loading_invesplus  NUMBER := 0.07;
    const_act_loading_fnewclient NUMBER := 0.11;
    const_act_loading_alphab     NUMBER := 0.1;
    const_act_loading_alphaa     NUMBER := 0.07;
    const_act_loading_alphaap    NUMBER := 0.07;
  BEGIN
    DELETE FROM ins.t_actuar_value;
    INSERT INTO ins.t_actuar_value
      SELECT res.policy_id
            ,res.pol_header_id
            ,ph.start_date
            ,pol.end_date
            ,res.t_product_line_id
            ,res.p_cover_id
            ,rv.insurance_year_date
            ,NULL
            ,NULL
            ,NULL
            ,rv.plan
            ,rv.fact
            ,rv.insurance_year_number par_t
            ,inf.par_values_age
            ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 par_n
            ,inf.sex_vh
            ,inf.deathrate_id
            ,inf.fact_yield_rate
            ,inf.f_loading
            ,ROUND(ins.pkg_amath.a_xn(inf.par_values_age + rv.insurance_year_number /*par_t*/
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 /*par_n*/
                                      -rv.insurance_year_number /*par_t*/
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,inf.deathrate_id /*par_values.deathrate_id*/
                                     ,inf.fact_yield_rate /*par_values.fact_yield_rate*/)
                  ,10) v_a_xn
            ,ROUND(ins.pkg_amath.a_xn(inf.par_values_age
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,inf.deathrate_id
                                     ,inf.fact_yield_rate)
                  ,10) v_a_x_n
            ,ROUND(ins.pkg_amath.ax1n(inf.par_values_age + rv.insurance_year_number
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                      rv.insurance_year_number
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,inf.deathrate_id
                                     ,inf.fact_yield_rate)
                  ,10) v_a1xn
            ,ROUND(ins.pkg_amath.iax1n(inf.par_values_age + rv.insurance_year_number
                                      ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                       rv.insurance_year_number
                                      ,inf.sex_vh
                                      ,0 /*par_values.k_coef*/
                                      ,0 /*par_values.s_coef*/
                                      ,inf.deathrate_id
                                      ,inf.fact_yield_rate)
                  ,10) v_ia1xn
            ,ROUND(ins.pkg_amath.nex(inf.par_values_age + rv.insurance_year_number
                                    ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                     rv.insurance_year_number
                                    ,inf.sex_vh
                                    ,0 /*par_values.k_coef*/
                                    ,0 /*par_values.s_coef*/
                                    ,inf.deathrate_id
                                    ,inf.fact_yield_rate)
                  ,10) v_nex
            ,(CASE
               WHEN MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                (CASE opt.brief
                  WHEN 'PEPR_A' THEN
                   0.9482
                  WHEN 'PEPR_A_PLUS' THEN
                   0.8052
                  WHEN 'PEPR_B' THEN
                   1.0070
                  WHEN 'OIL' THEN
                   2.77726
                  WHEN 'GOLD' THEN
                   2.77726
                END)
               ELSE
                (CASE opt.brief
                  WHEN 'PEPR_A' THEN
                   0.9452
                  WHEN 'PEPR_A_PLUS' THEN
                   0.8043
                  WHEN 'PEPR_B' THEN
                   1.0492
                  WHEN 'OIL' THEN
                   4.6130
                  WHEN 'GOLD' THEN
                   4.6130
                END)
             END) * inf.fee sa
            ,NULL
            ,CASE
               WHEN rv.insurance_year_number = 0 THEN
                NULL
               ELSE
                (inf.fee - (SELECT l.pen_for_year
                              FROM ins.t_inform_cover_lump l
                             WHERE l.pl_id = res.t_product_line_id
                               AND l.change_year = 2)) * (1 - inf.f_loading)
             END p_1
            ,CASE
               WHEN rv.insurance_year_number = 0 THEN
                NULL
               WHEN rv.insurance_year_number = 1 THEN
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.change_year = 1)
               WHEN rv.insurance_year_number = 2 THEN
                (SELECT l.fee
                 /*CASE WHEN l.fee - l.pen_for_year < 0
                      THEN 0
                     ELSE l.fee - l.pen_for_year
                 END*/
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.change_year = 2)
               WHEN rv.insurance_year_number = 3 THEN
                (SELECT l.fee
                 /*CASE WHEN l.fee - l.pen_for_year < 0
                      THEN 0
                     ELSE l.fee - l.pen_for_year
                 END*/
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.change_year = 3)
               WHEN rv.insurance_year_number = 4 THEN
                (SELECT l.fee
                 /*CASE WHEN l.fee - l.pen_for_year < 0
                      THEN 0
                     ELSE l.fee - l.pen_for_year
                 END*/
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.change_year = 4)
               ELSE
                (SELECT l.fee
                 /*CASE WHEN l.fee - l.pen_for_year < 0
                      THEN 0
                     ELSE l.fee - l.pen_for_year
                 END*/
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.change_year = 5)
             END cur_fee
            ,opt.brief
             -- Вероятнее всего здесь inf.cover_id 
            ,coalesce(pkg_cover.calc_fee_investment_part(inf.cover_id)
                     ,(1 - (CASE
                        WHEN MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                         CASE
                           WHEN prod.brief = 'InvestorPlus' THEN
                            const_act_loading_invesplus
                           WHEN prod.brief = 'INVESTOR_LUMP_ALPHA' THEN
                            CASE (SELECT num
                                FROM document
                               WHERE document_id = pkg_agn_control.get_current_policy_agent(ph.policy_header_id))
                              WHEN '45130' THEN
                               CASE opt.brief
                                 WHEN 'PEPR_B' THEN
                                  0.14
                                 WHEN 'PEPR_A' THEN
                                  0.13
                                 WHEN 'PEPR_A_PLUS' THEN
                                  0.11
                               END
                              WHEN '50592' THEN --ВТБ24 новый
                               CASE
                                 WHEN pol.start_date >= to_date('01.12.2014', 'dd.mm.yyyy') THEN
                                  CASE opt.brief
                                    WHEN 'PEPR_B' THEN
                                     0.197
                                    WHEN 'PEPR_A' THEN
                                     0.194
                                    WHEN 'PEPR_A_PLUS' THEN
                                     0.182
                                    ELSE
                                     1
                                  END
                                 ELSE
                                  CASE opt.brief
                                    WHEN 'PEPR_B' THEN
                                     0.14
                                    WHEN 'PEPR_A' THEN
                                     0.13
                                    WHEN 'PEPR_A_PLUS' THEN
                                     0.11
                                    ELSE
                                     1
                                  END
                               END
                              WHEN '44730' THEN
                               CASE
                                 WHEN pol.start_date >= to_date('01.04.2014', 'dd.mm.yyyy') THEN
                                  (CASE opt.brief
                                    WHEN 'PEPR_B' THEN
                                     0.14
                                    WHEN 'PEPR_A' THEN
                                     0.13
                                    WHEN 'PEPR_A_PLUS' THEN
                                     0.11
                                  END)
                                 ELSE
                                  (CASE opt.brief
                                    WHEN 'PEPR_B' THEN
                                     0.11
                                    WHEN 'PEPR_A' THEN
                                     0.09
                                    WHEN 'PEPR_A_PLUS' THEN
                                     0.07
                                    ELSE
                                     1
                                  END)
                               END
                              ELSE
                               (CASE opt.brief
                                 WHEN 'PEPR_A' THEN
                                  const_act_loading_alphaa
                                 WHEN 'PEPR_A_PLUS' THEN
                                  const_act_loading_alphaap
                                 WHEN 'PEPR_B' THEN
                                  const_act_loading_alphab
                               END)
                            END
                           ELSE
                            const_act_loading_3
                         END
                        ELSE
                         (CASE
                           WHEN prod.brief = 'Invest_in_future' THEN
                            (CASE
                              WHEN ph.start_date >= g_new_client_date THEN
                               const_act_loading_fnewclient
                              ELSE
                               (CASE opt.brief
                                 WHEN 'PEPR_A' THEN
                                  const_act_loading_fagr_5
                                 WHEN 'PEPR_A_PLUS' THEN
                                  const_act_loading_fagrplus_5
                                 WHEN 'PEPR_B' THEN
                                  const_act_loading_fbase_5
                               END)
                            END)
                           ELSE
                            CASE
                              WHEN prod.brief = 'InvestorPlus' THEN
                               const_act_loading_invesplus
                              ELSE
                               const_act_loading_5
                            END
                         END)
                      END))) * (CASE
                                  WHEN rv.insurance_year_number = 0 THEN
                                   NULL
                                  WHEN rv.insurance_year_number = 1 THEN
                                   (SELECT l.fee
                                      FROM ins.t_inform_cover_lump l
                                     WHERE l.pl_id = res.t_product_line_id
                                       AND l.change_year = 1)
                                  WHEN rv.insurance_year_number = 2 THEN
                                   (SELECT CASE
                                             WHEN l.fee - l.pen_for_year < 0 THEN
                                              0
                                             ELSE
                                              l.fee - l.pen_for_year
                                           END
                                      FROM ins.t_inform_cover_lump l
                                     WHERE l.pl_id = res.t_product_line_id
                                       AND l.change_year = 2)
                                  WHEN rv.insurance_year_number = 3 THEN
                                   (SELECT CASE
                                             WHEN l.fee - l.pen_for_year < 0 THEN
                                              0
                                             ELSE
                                              l.fee - l.pen_for_year
                                           END
                                      FROM ins.t_inform_cover_lump l
                                     WHERE l.pl_id = res.t_product_line_id
                                       AND l.change_year = 3)
                                  WHEN rv.insurance_year_number = 4 THEN
                                   (SELECT CASE
                                             WHEN l.fee - l.pen_for_year < 0 THEN
                                              0
                                             ELSE
                                              l.fee - l.pen_for_year
                                           END
                                      FROM ins.t_inform_cover_lump l
                                     WHERE l.pl_id = res.t_product_line_id
                                       AND l.change_year = 4)
                                  ELSE
                                   (SELECT CASE
                                             WHEN l.fee - l.pen_for_year < 0 THEN
                                              0
                                             ELSE
                                              l.fee - l.pen_for_year
                                           END
                                      FROM ins.t_inform_cover_lump l
                                     WHERE l.pl_id = res.t_product_line_id
                                       AND l.change_year = 5)
                                END) net_prem_act
            ,NULL
            ,NULL
            ,NULL
            ,0
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,
             /**/0.0025
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
        FROM reserve.r_reserve res
            ,reserve.r_reserve_value rv
            ,ins.p_pol_header ph
            ,ins.t_product prod
            ,ins.p_policy pol
            ,ins.t_prod_line_option opt
            ,(SELECT pc.age             par_values_age
                    ,pc.sex             sex_vh
                    ,pc.deathrate_id
                    ,pc.fact_yield_rate
                    ,pc.f_loading
                    ,pc.pl_id
                    ,pc.fee
                    ,pc.cover_id
                FROM ins.t_inform_cover_lump pc
               WHERE pc.change_year = 1) inf
       WHERE res.policy_id = (SELECT p.policy_id
                                FROM ins.p_policy pp
                                    ,ins.p_policy p
                               WHERE pp.policy_id = par_policy_id
                                 AND pp.pol_header_id = p.pol_header_id
                                 AND p.version_num = 1)
         AND rv.reserve_id = res.id
         AND ph.policy_header_id = res.pol_header_id
         AND pol.policy_id = res.policy_id
         AND res.t_product_line_id = opt.product_line_id
         AND opt.product_line_id = inf.pl_id
         AND prod.product_id = ph.product_id;
    /**/
    UPDATE ins.t_actuar_value a
       SET (a.g, a.p) =
           (SELECT ap.v_nex / (ap.v_a_xn * (1 - ap.f_loading) - ap.v_ia1xn)
                  ,(ap.v_nex / (ap.v_a_xn * (1 - ap.f_loading) - ap.v_ia1xn)) * (1 - ap.f_loading)
              FROM ins.t_actuar_value ap
             WHERE ap.p_cover_id = a.p_cover_id
               AND ap.par_t = 0)
     WHERE a.opt_brief IN ('GOLD', 'OIL');
  
    UPDATE ins.t_actuar_value a
       SET (a.g, a.p) =
           (SELECT ap.v_nex / (1 - ap.f_loading - ap.v_a1xn)
                  ,(ap.v_nex / (1 - ap.f_loading - ap.v_a1xn)) * (1 - ap.f_loading)
              FROM ins.t_actuar_value ap
             WHERE ap.p_cover_id = a.p_cover_id
               AND ap.par_t = 0)
     WHERE a.opt_brief NOT IN ('GOLD', 'OIL');
    /**/
    UPDATE ins.t_actuar_value a
       SET a.tv_p    = a.v_nex + a.g * (a.par_t * a.v_a1xn + a.v_ia1xn) - a.p * a.v_a_xn
          ,a.net_res =
           (a.v_nex + a.g * (a.par_t * a.v_a1xn + a.v_ia1xn) - a.p * a.v_a_xn) * a.sa
     WHERE a.opt_brief IN ('GOLD', 'OIL');
  
    UPDATE ins.t_actuar_value a
       SET a.tv_p     = a.v_nex + a.g * a.v_a1xn
          ,a.net_res =
           (a.v_nex + a.g * a.v_a1xn) * a.sa
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.sa
          ,a.tv_p3   =
           (a.v_nex + a.g * a.v_a1xn) * (SELECT (CASE
                                                  WHEN a.par_n = 3 THEN
                                                   (CASE lp.opt_brief
                                                     WHEN 'PEPR_A' THEN
                                                      0.9482
                                                     WHEN 'PEPR_A_PLUS' THEN
                                                      0.8052
                                                     WHEN 'PEPR_B' THEN
                                                      1.0070
                                                   END)
                                                  ELSE
                                                   (CASE lp.opt_brief
                                                     WHEN 'PEPR_A' THEN
                                                      0.9452
                                                     WHEN 'PEPR_A_PLUS' THEN
                                                      0.8043
                                                     WHEN 'PEPR_B' THEN
                                                      1.0492
                                                   END)
                                                END) * lp.fee
                                           FROM ins.t_inform_cover_lump lp
                                          WHERE lp.opt_brief = a.opt_brief
                                            AND lp.change_year = 1)
          ,a.ad = (CASE
                    WHEN (a.par_t = 0 AND a.opt_brief = 'PEPR_A_PLUS') THEN
                     (a.f_loading - (SELECT va.f_loading
                                       FROM ins.t_actuar_value va
                                      WHERE va.opt_brief = 'PEPR_A'
                                        AND a.par_t = va.par_t)) *
                     (a.v_nex / (1 - a.f_loading - a.v_a1xn)) /*a.g*/
                    ELSE
                     0
                  END)
          ,a.adres = (CASE
                       WHEN (a.par_t = 0 AND a.opt_brief = 'PEPR_A_PLUS') THEN
                        (a.f_loading - (SELECT va.f_loading
                                          FROM ins.t_actuar_value va
                                         WHERE va.opt_brief = 'PEPR_A'
                                           AND a.par_t = va.par_t)) *
                        (a.v_nex / (1 - a.f_loading - a.v_a1xn)) /*a.g*/
                       ELSE
                        0
                     END) * a.sa
     WHERE a.opt_brief NOT IN ('GOLD', 'OIL');
    /**/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ADD_ACTUAR_VALUE: ' || SQLERRM);
  END add_actuar_value;
  /**/
  PROCEDURE add_get_weigth(par_period NUMBER) IS
    fa_increase        NUMBER := 0;
    sum_prem_no_change NUMBER := 0;
    fee_decrease       NUMBER := 0;
    pcnt_str_increase  NUMBER := 0;
  BEGIN
    FOR i IN 1 .. par_period - 1
    LOOP
      fa_increase        := 0;
      fee_decrease       := 0;
      sum_prem_no_change := 0;
      pcnt_str_increase  := 0;
      FOR cur IN (SELECT pc_1.opt_brief
                        ,pc_1.fee       old_fee
                        ,pc_2.fee       cur_fee
                        ,pc_1.sum_prem  old_sum_prem
                        ,pc_2.sum_prem  cur_sum_prem
                        ,pc_2.cover_id
                    FROM ins.t_inform_cover_lump pc_1
                        ,ins.t_inform_cover_lump pc_2
                   WHERE pc_1.change_year = i
                     AND pc_1.pl_id = pc_2.pl_id
                     AND pc_2.change_year = i + 1)
      LOOP
        IF cur.cur_fee > cur.old_fee
        THEN
          UPDATE ins.t_inform_cover_lump pc
             SET pc.fee_increase = 1
           WHERE pc.opt_brief = cur.opt_brief
             AND pc.change_year = i + 1;
          fa_increase := fa_increase + 1;
        END IF;
        IF cur.old_sum_prem = cur.cur_sum_prem
        THEN
          sum_prem_no_change := 1;
        END IF;
        IF cur.cur_fee < cur.old_fee
        THEN
          UPDATE ins.t_inform_cover_lump pc
             SET pc.fee_decrease = 1
           WHERE pc.opt_brief = cur.opt_brief
             AND pc.change_year = i + 1;
          fee_decrease := fee_decrease + 1;
        END IF;
      END LOOP;
    
      UPDATE ins.t_inform_cover_lump pc
         SET w = pc.fee / pc.sum_prem
       WHERE pc.fee_decrease = 1
         AND pc.change_year = i + 1;
    
      IF fa_increase = 3
      THEN
        UPDATE ins.t_inform_cover_lump pc
           SET w = pc.perc_for_year /* / 100*/
         WHERE pc.change_year = i + 1;
      ELSE
        IF sum_prem_no_change = 1
        THEN
          UPDATE ins.t_inform_cover_lump pc SET w = pc.fee / pc.sum_prem WHERE pc.change_year = i + 1;
        ELSE
          IF fa_increase = 1
          THEN
            UPDATE ins.t_inform_cover_lump pca
               SET w =
                   (SELECT (pca.fee - (pca.sum_prem - pc.sum_prem)) / pc.sum_prem
                      FROM ins.t_inform_cover_lump pc
                     WHERE pc.pl_id = pca.pl_id
                       AND pc.change_year = i)
             WHERE pca.fee_increase = 1
               AND pca.change_year = i + 1;
            UPDATE ins.t_inform_cover_lump pca
               SET w =
                   (SELECT pca.fee - pc.sum_prem
                      FROM ins.t_inform_cover_lump pc
                     WHERE pc.pl_id = pca.pl_id
                       AND pc.change_year = i)
             WHERE nvl(pca.fee_increase, 0) != 1
               AND pca.change_year = i + 1;
          ELSE
            IF fa_increase = 2
            THEN
              SELECT COUNT(*)
                INTO pcnt_str_increase
                FROM ins.t_inform_cover_lump pc
                    ,ins.t_inform_cover_lump pca
               WHERE pc.fee_increase = 1
                 AND pc.change_year = i + 1
                 AND pc.pl_id = pca.pl_id
                 AND pca.change_year = i
                 AND abs(pc.fee - pca.fee) > (pc.sum_prem - pca.sum_prem);
              IF pcnt_str_increase = 1
              THEN
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT (pc.fee - (pc.sum_prem - pca.sum_prem)) / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.change_year = i)
                 WHERE EXISTS (SELECT NULL
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.change_year = i
                           AND abs((pc.fee - pca.fee)) > (pc.sum_prem - pca.sum_prem))
                   AND pc.fee_increase = 1
                   AND pc.change_year = i + 1;
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT pc.fee / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.change_year = i)
                 WHERE EXISTS (SELECT NULL
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.change_year = i
                           AND abs((pc.fee - pca.fee)) > (pc.sum_prem - pca.sum_prem))
                   AND pc.fee_increase = 1
                   AND pc.change_year = i + 1;
              ELSE
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT (pca.fee + (SELECT (p1.fee - p2.sum_prem) / 2
                                             FROM ins.t_inform_cover_lump p1
                                                 ,ins.t_inform_cover_lump p2
                                            WHERE p1.pl_id = pca.pl_id
                                              AND p1.fee_decrease = 1
                                              AND p2.pl_id = p1.pl_id
                                              AND p2.fee_decrease = 1
                                              AND p1.change_year = i
                                              AND p2.change_year = i + 1)) / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.change_year = i)
                 WHERE pc.fee_increase = 1
                   AND pc.change_year = i + 1;
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT pc.fee / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.change_year = i)
                 WHERE pc.fee_decrease = 1
                   AND pc.change_year = i + 1;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    
      UPDATE ins.t_inform_cover_lump pc
         SET (pc.delta_w) =
             (SELECT CASE
                       WHEN pca.fee = 0 THEN
                        (CASE
                          WHEN pc.fee = 0 THEN
                           0
                          ELSE
                           1
                        END)
                       ELSE
                        CASE
                          WHEN pc.opt_brief IN ('GOLD', 'OIL') THEN
                           (pc.fee / pc.sum_prem - pca.fee / pca.sum_prem)
                          ELSE
                           (pc.fee - pca.fee) / pca.fee
                        END
                     END * 100
                FROM ins.t_inform_cover_lump pca
               WHERE pca.pl_id = pc.pl_id
                 AND pca.change_year = i)
       WHERE pc.change_year = i + 1;
      UPDATE ins.t_inform_cover_lump pc
         SET pc.priznak = (CASE
                            WHEN pc.delta_w > 0 THEN
                             1
                            ELSE
                             0
                          END)
       WHERE pc.change_year = i + 1;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ADD_GET_WEIGTH: ' || SQLERRM);
  END add_get_weigth;
  /**/
  PROCEDURE add_another_update(par_period_id NUMBER) IS
    const_act_loading_3          NUMBER := 0.0613;
    const_act_loading_5          NUMBER := 0.0643;
    const_act_loading_fbase_5    NUMBER := 0.09;
    const_act_loading_fagr_5     NUMBER := 0.08;
    const_act_loading_fagrplus_5 NUMBER := 0.0643;
    const_act_loading_fnewclient NUMBER := 0.11;
    const_act_loading_alphab     NUMBER := 0.1;
    const_act_loading_alphaa     NUMBER := 0.07;
    const_act_loading_alphaap    NUMBER := 0.07;
  BEGIN
  
    /*первый год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_lump(pc.opt_brief
                                                          ,pc.start_date
                                                          ,trunc(pc.end_date)
                                                          ,ta.par_t
                                                          ,ta.net_prem_act
                                                          ,pc.cover_id)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.cover_id = ta.p_cover_id
               AND pc.change_year = 1)
     WHERE ta.par_t = 1;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value va
       SET va.tv_p3 = (CASE
                        WHEN va.par_n = 5 THEN
                         nvl(va.s1, va.sa) * va.tv_p
                        ELSE
                         va.tv_p3
                      END)
     WHERE va.par_t = 1;
    /*резерв 1 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      abs((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 2;
    /**/
    UPDATE ins.t_actuar_value a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 1
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE ins.t_actuar_value a
       SET a.adres = a.ad * a.sa
    /*(CASE
      WHEN a.par_n = 3 THEN
       (CASE
         WHEN (SELECT (CASE
                        WHEN pc.priznak = 1 THEN
                         pc.reserve_distrib
                        ELSE
                         -pc.reserve_take
                      END)
                 FROM ins.t_inform_cover_lump pc
                WHERE pc.opt_brief = a.opt_brief
                  AND pc.change_year = a.par_t + 1) < 0 THEN
          0
         ELSE
          a.ad * a.sa + (SELECT (CASE
                                  WHEN pc.priznak = 1 THEN
                                   pc.reserve_distrib
                                  ELSE
                                   -pc.reserve_take
                                END)
                           FROM ins.t_inform_cover_lump pc
                          WHERE pc.opt_brief = a.opt_brief
                            AND pc.change_year = a.par_t + 1) *
          (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                FROM ins.t_actuar_value ta
                               WHERE ta.par_t = a.par_t - 1
                                 AND ta.opt_brief = a.opt_brief))
       END)
      ELSE
       a.ad * a.sa
    END)*/
     WHERE a.par_t = 1
       AND a.opt_brief = 'PEPR_A_PLUS';
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 2;
    /*вклад 1 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                abs((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 1) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 2;
    /*доп доход 1 год*/
    UPDATE ins.t_actuar_value a
       SET a.tv_p2    = a.sa * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.sa
     WHERE a.par_t = 1;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 1;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 1;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            abs((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 1) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 2;
  
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 2;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.net_res
     WHERE ta.par_t = 1;
    /*СС 1 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         ta.sa
                        ELSE
                         ((((SELECT SUM(t.did_res) FROM ins.t_actuar_value t WHERE t.par_t = ta.par_t - 1) -
                         (SELECT SUM(lp.pen_for_year)
                               FROM ins.t_inform_cover_lump lp
                              WHERE lp.change_year = ta.par_t)) *
                         (SELECT lp.w
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t)) * (CASE
                           WHEN ta.opt_brief = 'PEPR_A_PLUS' THEN
                            (SELECT t.tv_p
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) /
                            ((SELECT t.tv_p
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) +
                            (SELECT t.ad
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 2
                                 AND t.opt_brief = ta.opt_brief))
                           ELSE
                            1
                         END) - ta.cur_fee * (SELECT t.v_a1xn
                                                 FROM ins.t_actuar_value t
                                                WHERE t.par_t = ta.par_t - 1
                                                  AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 2;
    /*UPDATE ins.t_actuar_value ta
      SET ta.s1 = (CASE
                    WHEN ta.cur_fee = 0 THEN
                     0
                    ELSE
                     (CASE
                       WHEN (SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                        ta.sa
                       ELSE
                        ((SELECT t.net_res
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief) +
                        (SELECT pc.delta_res + pc.delta_eib
                            FROM ins.t_inform_cover_lump pc
                           WHERE pc.opt_brief = ta.opt_brief
                             AND pc.change_year = ta.par_t) -
                        ta.cur_fee * (SELECT t.v_a1xn
                                         FROM ins.t_actuar_value t
                                        WHERE t.par_t = ta.par_t - 1
                                          AND t.opt_brief = ta.opt_brief)) /
                        (SELECT t.v_nex
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                     END)
                  END)
    WHERE ta.par_t = 2;*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 2;
    /*второй год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act = ta.cur_fee * coalesce(pkg_cover.calc_fee_investment_part(ta.p_cover_id)
                                                  ,(1 - (CASE
                                                     WHEN ta.par_n = 3 THEN
                                                      (CASE
                                                        WHEN (SELECT COUNT(*)
                                                                FROM ins.p_pol_header ph
                                                                    ,ins.t_product    prod
                                                               WHERE ph.policy_header_id = ta.pol_header_id
                                                                 AND ph.product_id = prod.product_id
                                                                 AND prod.brief = 'INVESTOR_LUMP_ALPHA') > 0 THEN
                                                         CASE (SELECT num
                                                             FROM document
                                                            WHERE document_id =
                                                                  pkg_agn_control.get_current_policy_agent(ta.pol_header_id))
                                                           WHEN '45130' THEN
                                                            CASE ta.opt_brief
                                                              WHEN 'PEPR_B' THEN
                                                               0.14
                                                              WHEN 'PEPR_A' THEN
                                                               0.13
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               0.11
                                                            END
                                                           WHEN '50592' THEN --ВТБ24 новый
                                                            CASE
                                                              WHEN (SELECT ph.start_date
                                                                      FROM ins.p_pol_header ph
                                                                     WHERE ph.policy_header_id = ta.pol_header_id) >=
                                                                   to_date('01.12.2014', 'dd.mm.yyyy') THEN
                                                               CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.197
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.194
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.182
                                                                 ELSE
                                                                  1
                                                               END
                                                              ELSE
                                                               CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.14
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.13
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.11
                                                                 ELSE
                                                                  1
                                                               END
                                                            END
                                                           WHEN '44730' THEN
                                                            CASE
                                                              WHEN (SELECT ph.start_date
                                                                      FROM ins.p_pol_header ph
                                                                     WHERE ph.policy_header_id = ta.pol_header_id) >=
                                                                   to_date('01.04.2014', 'dd.mm.yyyy') THEN
                                                               (CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.14
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.13
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.11
                                                               END)
                                                              ELSE
                                                               (CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.11
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.09
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.07
                                                                 ELSE
                                                                  1
                                                               END)
                                                            END
                                                           ELSE
                                                            (CASE ta.opt_brief
                                                              WHEN 'PEPR_A' THEN
                                                               const_act_loading_alphaa
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               const_act_loading_alphaap
                                                              WHEN 'PEPR_B' THEN
                                                               const_act_loading_alphab
                                                            END)
                                                         END
                                                        ELSE
                                                         const_act_loading_3
                                                      END)
                                                     ELSE
                                                      (CASE
                                                        WHEN (SELECT COUNT(*)
                                                                FROM ins.p_pol_header ph
                                                                    ,ins.t_product    prod
                                                               WHERE ph.policy_header_id = ta.pol_header_id
                                                                 AND ph.product_id = prod.product_id
                                                                 AND prod.brief = 'Invest_in_future') > 0 THEN
                                                         (CASE
                                                           WHEN (SELECT MAX(ph.start_date)
                                                                   FROM ins.p_pol_header ph
                                                                  WHERE ph.policy_header_id = ta.pol_header_id) >= g_new_client_date THEN
                                                            const_act_loading_fnewclient
                                                           ELSE
                                                            (CASE ta.opt_brief
                                                              WHEN 'PEPR_A' THEN
                                                               const_act_loading_fagr_5
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               const_act_loading_fagrplus_5
                                                              WHEN 'PEPR_B' THEN
                                                               const_act_loading_fbase_5
                                                            END)
                                                         END)
                                                        ELSE
                                                         const_act_loading_5
                                                      END)
                                                   END)))
     WHERE ta.par_t = 2;
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_lump(pc.opt_brief
                                                          ,pc.start_date
                                                          ,trunc(pc.end_date)
                                                          ,ta.par_t
                                                          ,(SELECT tat.net_prem_act
                                                             FROM ins.t_actuar_value tat
                                                            WHERE tat.par_t = 1
                                                              AND tat.opt_brief = pc.opt_brief)
                                                          ,pc.cover_id)
            
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 2;
    /*Обновление net_res 2 год*/
    UPDATE ins.t_actuar_value ta SET ta.net_res = nvl(ta.s1, ta.sa) * ta.tv_p WHERE ta.par_t = 2;
    /*резерв 2 год*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN (SELECT va.cur_fee
                               FROM ins.t_actuar_value va
                              WHERE va.opt_brief = v.opt_brief
                                AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                        v.net_res
                       ELSE
                        (v.s1 * v.v_nex + v.cur_fee * v.v_a1xn)
                     END)
     WHERE v.par_t = 2;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value va
       SET va.tv_p3 = (CASE
                        WHEN va.par_n = 5 THEN
                         nvl(va.s1, va.sa) * va.tv_p
                        ELSE
                         va.tv_p3
                      END)
     WHERE va.par_t = 2;
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      abs((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 3;
    /**/
    UPDATE ins.t_actuar_value a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 2
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE ins.t_actuar_value a
       SET a.adres = a.ad * a.s1
    /*(CASE
      WHEN a.par_n = 3 THEN
       (CASE
         WHEN (SELECT (CASE
                        WHEN pc.priznak = 1 THEN
                         pc.reserve_distrib
                        ELSE
                         -pc.reserve_take
                      END)
                 FROM ins.t_inform_cover_lump pc
                WHERE pc.opt_brief = a.opt_brief
                  AND pc.change_year = a.par_t + 1) < 0 THEN
          0
         ELSE
          a.ad * a.s1 + (SELECT (CASE
                                  WHEN pc.priznak = 1 THEN
                                   pc.reserve_distrib
                                  ELSE
                                   -pc.reserve_take
                                END)
                           FROM ins.t_inform_cover_lump pc
                          WHERE pc.opt_brief = a.opt_brief
                            AND pc.change_year = a.par_t + 1) *
          (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                FROM ins.t_actuar_value ta
                               WHERE ta.par_t = a.par_t - 1
                                 AND ta.opt_brief = a.opt_brief))
       END)
      ELSE
       a.ad * a.s1
    END)*/
     WHERE a.par_t = 2
       AND a.opt_brief = 'PEPR_A_PLUS';
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 3;
    /*вклад 2 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                abs((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 2) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                abs((SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                      FROM ins.t_inform_cover_lump p
                                     WHERE p.change_year = pc.change_year))
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 3;
    /*доп доход 2 год*/
    UPDATE ins.t_actuar_value a
       SET a.tv_p2    = a.s1 * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.s1
     WHERE a.par_t = 2;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 2;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 2;
  
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            abs((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 2) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 3;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.tv_p3
     WHERE ta.par_t = 2;
    /*СС 2 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         (SELECT t.s1
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                        ELSE
                         ((((SELECT SUM(t.did_res) FROM ins.t_actuar_value t WHERE t.par_t = ta.par_t - 1) -
                         (SELECT SUM(lp.pen_for_year)
                               FROM ins.t_inform_cover_lump lp
                              WHERE lp.change_year = ta.par_t)) *
                         (SELECT lp.w
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t)) * (CASE
                           WHEN ta.opt_brief = 'PEPR_A_PLUS' THEN
                            (SELECT t.tv_p
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) /
                            ((SELECT t.tv_p
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) +
                            (SELECT t.ad
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 2
                                 AND t.opt_brief = ta.opt_brief))
                           ELSE
                            1
                         END) - ta.cur_fee * (SELECT t.v_a1xn
                                                 FROM ins.t_actuar_value t
                                                WHERE t.par_t = ta.par_t - 1
                                                  AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 3;
    /*    UPDATE ins.t_actuar_value ta
      SET ta.s1 = (CASE
                    WHEN ta.cur_fee = 0 THEN
                     0
                    ELSE
                     (CASE
                       WHEN (SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                        (SELECT t.s1
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                       ELSE
                        ((SELECT t.tv_p3
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief) +
                        (SELECT pc.delta_res + pc.delta_eib
                            FROM ins.t_inform_cover_lump pc
                           WHERE pc.opt_brief = ta.opt_brief
                             AND pc.change_year = ta.par_t) -
                        ta.cur_fee * (SELECT t.v_a1xn
                                         FROM ins.t_actuar_value t
                                        WHERE t.par_t = ta.par_t - 1
                                          AND t.opt_brief = ta.opt_brief)) /
                        (SELECT t.v_nex
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                     END)
                  END)
    WHERE ta.par_t = 3;*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 3;
    /****************************************************************/
    /*третий год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act = ta.cur_fee * coalesce(pkg_cover.calc_fee_investment_part(ta.p_cover_id)
                                                  ,(1 - (CASE
                                                     WHEN ta.par_n = 3 THEN
                                                      (CASE
                                                        WHEN (SELECT COUNT(*)
                                                                FROM ins.p_pol_header ph
                                                                    ,ins.t_product    prod
                                                               WHERE ph.policy_header_id = ta.pol_header_id
                                                                 AND ph.product_id = prod.product_id
                                                                 AND prod.brief = 'INVESTOR_LUMP_ALPHA') > 0 THEN
                                                         CASE (SELECT num
                                                             FROM document
                                                            WHERE document_id =
                                                                  pkg_agn_control.get_current_policy_agent(ta.pol_header_id))
                                                           WHEN '45130' THEN
                                                            CASE ta.opt_brief
                                                              WHEN 'PEPR_B' THEN
                                                               0.14
                                                              WHEN 'PEPR_A' THEN
                                                               0.13
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               0.11
                                                            END
                                                           WHEN '50592' THEN --ВТБ24 новый
                                                            CASE
                                                              WHEN (SELECT ph.start_date
                                                                      FROM ins.p_pol_header ph
                                                                     WHERE ph.policy_header_id = ta.pol_header_id) >=
                                                                   to_date('01.12.2014', 'dd.mm.yyyy') THEN
                                                               CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.197
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.194
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.182
                                                                 ELSE
                                                                  1
                                                               END
                                                              ELSE
                                                               CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.14
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.13
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.11
                                                                 ELSE
                                                                  1
                                                               END
                                                            END
                                                           WHEN '44730' THEN
                                                            CASE
                                                              WHEN (SELECT ph.start_date
                                                                      FROM ins.p_pol_header ph
                                                                     WHERE ph.policy_header_id = ta.pol_header_id) >=
                                                                   to_date('01.04.2014', 'dd.mm.yyyy') THEN
                                                               (CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.14
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.13
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.11
                                                               END)
                                                              ELSE
                                                               (CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.11
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.09
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.07
                                                                 ELSE
                                                                  1
                                                               END)
                                                            END
                                                           ELSE
                                                            (CASE ta.opt_brief
                                                              WHEN 'PEPR_A' THEN
                                                               const_act_loading_alphaa
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               const_act_loading_alphaap
                                                              WHEN 'PEPR_B' THEN
                                                               const_act_loading_alphab
                                                            END)
                                                         END
                                                        ELSE
                                                         const_act_loading_3
                                                      END)
                                                     ELSE
                                                      (CASE
                                                        WHEN (SELECT COUNT(*)
                                                                FROM ins.p_pol_header ph
                                                                    ,ins.t_product    prod
                                                               WHERE ph.policy_header_id = ta.pol_header_id
                                                                 AND ph.product_id = prod.product_id
                                                                 AND prod.brief = 'Invest_in_future') > 0 THEN
                                                         (CASE
                                                           WHEN (SELECT MAX(ph.start_date)
                                                                   FROM ins.p_pol_header ph
                                                                  WHERE ph.policy_header_id = ta.pol_header_id) >= g_new_client_date THEN
                                                            const_act_loading_fnewclient
                                                           ELSE
                                                            (CASE ta.opt_brief
                                                              WHEN 'PEPR_A' THEN
                                                               const_act_loading_fagr_5
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               const_act_loading_fagrplus_5
                                                              WHEN 'PEPR_B' THEN
                                                               const_act_loading_fbase_5
                                                            END)
                                                         END)
                                                        ELSE
                                                         const_act_loading_5
                                                      END)
                                                   END)))
     WHERE ta.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_lump(pc.opt_brief
                                                          ,pc.start_date
                                                          ,trunc(pc.end_date)
                                                          ,ta.par_t
                                                          ,(SELECT tat.net_prem_act
                                                             FROM ins.t_actuar_value tat
                                                            WHERE tat.par_t = 1
                                                              AND tat.opt_brief = pc.opt_brief)
                                                          ,pc.cover_id)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 3;
    /*Обновление net_res 3 год*/
    UPDATE ins.t_actuar_value ta SET ta.net_res = nvl(ta.s1, ta.sa) * ta.tv_p WHERE ta.par_t = 3;
    /*резерв 3 год*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN (SELECT va.cur_fee
                               FROM ins.t_actuar_value va
                              WHERE va.opt_brief = v.opt_brief
                                AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                        v.net_res
                       ELSE
                        (v.s1 * v.v_nex + v.cur_fee * v.v_a1xn)
                     END)
     WHERE v.par_t = 3;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value va
       SET va.tv_p3 = (CASE
                        WHEN va.par_n = 5 THEN
                         nvl(va.s1, va.sa) * va.tv_p
                        ELSE
                         va.tv_p3
                      END)
     WHERE va.par_t = 3;
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      abs((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 4;
    /**/
    UPDATE ins.t_actuar_value a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 3
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE ins.t_actuar_value a
       SET a.adres = a.ad * a.s1
    /*(CASE
      WHEN a.par_n = 3 THEN
       (CASE
         WHEN (SELECT (CASE
                        WHEN pc.priznak = 1 THEN
                         pc.reserve_distrib
                        ELSE
                         -pc.reserve_take
                      END)
                 FROM ins.t_inform_cover_lump pc
                WHERE pc.opt_brief = a.opt_brief
                  AND pc.change_year = a.par_t + 1) < 0 THEN
          0
         ELSE
          a.ad * a.s1 + (SELECT (CASE
                                  WHEN pc.priznak = 1 THEN
                                   pc.reserve_distrib
                                  ELSE
                                   -pc.reserve_take
                                END)
                           FROM ins.t_inform_cover_lump pc
                          WHERE pc.opt_brief = a.opt_brief
                            AND pc.change_year = a.par_t + 1) *
          (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                FROM ins.t_actuar_value ta
                               WHERE ta.par_t = a.par_t - 1
                                 AND ta.opt_brief = a.opt_brief))
       END)
      ELSE
       a.ad * a.s1
    END)*/
     WHERE a.par_t = 3
       AND a.opt_brief = 'PEPR_A_PLUS';
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 4;
    /*вклад 3 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                abs((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 3) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                abs((SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                      FROM ins.t_inform_cover_lump p
                                     WHERE p.change_year = pc.change_year))
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 4;
    /*доп доход 3 год*/
    UPDATE ins.t_actuar_value a
       SET a.tv_p2    = a.s1 * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.s1
     WHERE a.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 3;
  
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            abs((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 3) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 4;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.tv_p3
     WHERE ta.par_t = 3;
    /*СС 3 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         (SELECT t.s1
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                        ELSE
                         ((((SELECT SUM(t.did_res) FROM ins.t_actuar_value t WHERE t.par_t = ta.par_t - 1) -
                         (SELECT SUM(lp.pen_for_year)
                               FROM ins.t_inform_cover_lump lp
                              WHERE lp.change_year = ta.par_t)) *
                         (SELECT lp.w
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t)) * (CASE
                           WHEN ta.opt_brief = 'PEPR_A_PLUS' THEN
                            (SELECT t.tv_p
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) /
                            ((SELECT t.tv_p
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) +
                            (SELECT t.ad
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 2
                                 AND t.opt_brief = ta.opt_brief))
                           ELSE
                            1
                         END) - ta.cur_fee * (SELECT t.v_a1xn
                                                 FROM ins.t_actuar_value t
                                                WHERE t.par_t = ta.par_t - 1
                                                  AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 4;
    /*UPDATE ins.t_actuar_value ta
      SET ta.s1 = (CASE
                    WHEN ta.cur_fee = 0 THEN
                     0
                    ELSE
                     (CASE
                       WHEN (SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                        (SELECT t.s1
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                       ELSE
                        ((SELECT t.tv_p3
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief) +
                        (SELECT pc.delta_res + pc.delta_eib
                            FROM ins.t_inform_cover_lump pc
                           WHERE pc.opt_brief = ta.opt_brief
                             AND pc.change_year = ta.par_t) -
                        ta.cur_fee * (SELECT t.v_a1xn
                                         FROM ins.t_actuar_value t
                                        WHERE t.par_t = ta.par_t - 1
                                          AND t.opt_brief = ta.opt_brief)) /
                        (SELECT t.v_nex
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                     END)
                  END)
    WHERE ta.par_t = 4;*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 4;
    /****************************************************************/
    /*четвертый год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act = ta.cur_fee * coalesce(pkg_cover.calc_fee_investment_part(ta.p_cover_id)
                                                  ,(1 - (CASE
                                                     WHEN ta.par_n = 3 THEN
                                                      (CASE
                                                        WHEN (SELECT COUNT(*)
                                                                FROM ins.p_pol_header ph
                                                                    ,ins.t_product    prod
                                                               WHERE ph.policy_header_id = ta.pol_header_id
                                                                 AND ph.product_id = prod.product_id
                                                                 AND prod.brief = 'INVESTOR_LUMP_ALPHA') > 0 THEN
                                                         CASE (SELECT num
                                                             FROM document
                                                            WHERE document_id =
                                                                  pkg_agn_control.get_current_policy_agent(ta.pol_header_id))
                                                           WHEN '45130' THEN
                                                            CASE ta.opt_brief
                                                              WHEN 'PEPR_B' THEN
                                                               0.14
                                                              WHEN 'PEPR_A' THEN
                                                               0.13
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               0.11
                                                            END
                                                           WHEN '50592' THEN --ВТБ24 новый
                                                            CASE
                                                              WHEN (SELECT ph.start_date
                                                                      FROM ins.p_pol_header ph
                                                                     WHERE ph.policy_header_id = ta.pol_header_id) >=
                                                                   to_date('01.12.2014', 'dd.mm.yyyy') THEN
                                                               CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.197
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.194
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.182
                                                                 ELSE
                                                                  1
                                                               END
                                                              ELSE
                                                               CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.14
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.13
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.11
                                                                 ELSE
                                                                  1
                                                               END
                                                            END
                                                           WHEN '44730' THEN
                                                            CASE
                                                              WHEN (SELECT ph.start_date
                                                                      FROM ins.p_pol_header ph
                                                                     WHERE ph.policy_header_id = ta.pol_header_id) >=
                                                                   to_date('01.04.2014', 'dd.mm.yyyy') THEN
                                                               (CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.14
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.13
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.11
                                                               END)
                                                              ELSE
                                                               (CASE ta.opt_brief
                                                                 WHEN 'PEPR_B' THEN
                                                                  0.11
                                                                 WHEN 'PEPR_A' THEN
                                                                  0.09
                                                                 WHEN 'PEPR_A_PLUS' THEN
                                                                  0.07
                                                                 ELSE
                                                                  1
                                                               END)
                                                            END
                                                           ELSE
                                                            (CASE ta.opt_brief
                                                              WHEN 'PEPR_A' THEN
                                                               const_act_loading_alphaa
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               const_act_loading_alphaap
                                                              WHEN 'PEPR_B' THEN
                                                               const_act_loading_alphab
                                                            END)
                                                         END
                                                        ELSE
                                                         const_act_loading_3
                                                      END)
                                                     ELSE
                                                      (CASE
                                                        WHEN (SELECT COUNT(*)
                                                                FROM ins.p_pol_header ph
                                                                    ,ins.t_product    prod
                                                               WHERE ph.policy_header_id = ta.pol_header_id
                                                                 AND ph.product_id = prod.product_id
                                                                 AND prod.brief = 'Invest_in_future') > 0 THEN
                                                         (CASE
                                                           WHEN (SELECT MAX(ph.start_date)
                                                                   FROM ins.p_pol_header ph
                                                                  WHERE ph.policy_header_id = ta.pol_header_id) >= g_new_client_date THEN
                                                            const_act_loading_fnewclient
                                                           ELSE
                                                            (CASE ta.opt_brief
                                                              WHEN 'PEPR_A' THEN
                                                               const_act_loading_fagr_5
                                                              WHEN 'PEPR_A_PLUS' THEN
                                                               const_act_loading_fagrplus_5
                                                              WHEN 'PEPR_B' THEN
                                                               const_act_loading_fbase_5
                                                            END)
                                                         END)
                                                        ELSE
                                                         const_act_loading_5
                                                      END)
                                                   END)))
     WHERE ta.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_lump(pc.opt_brief
                                                          ,pc.start_date
                                                          ,trunc(pc.end_date)
                                                          ,ta.par_t
                                                          ,(SELECT tat.net_prem_act
                                                             FROM ins.t_actuar_value tat
                                                            WHERE tat.par_t = 1
                                                              AND tat.opt_brief = pc.opt_brief)
                                                          ,pc.cover_id)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 4;
    /*Обновление net_res 4 год*/
    UPDATE ins.t_actuar_value ta SET ta.net_res = nvl(ta.s1, ta.sa) * ta.tv_p WHERE ta.par_t = 4;
    /*резерв 4 год*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN (SELECT va.cur_fee
                               FROM ins.t_actuar_value va
                              WHERE va.opt_brief = v.opt_brief
                                AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                        v.net_res
                       ELSE
                        (v.s1 * v.v_nex + v.cur_fee * v.v_a1xn)
                     END)
     WHERE v.par_t = 4;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value va
       SET va.tv_p3 = (CASE
                        WHEN va.par_n = 5 THEN
                         nvl(va.s1, va.sa) * va.tv_p
                        ELSE
                         va.tv_p3
                      END)
     WHERE va.par_t = 4;
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      abs((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 5;
    /**/
    UPDATE ins.t_actuar_value a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 4
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE ins.t_actuar_value a
       SET a.adres = a.ad * a.s1
    /*(CASE
      WHEN a.par_n = 3 THEN
       (CASE
         WHEN (SELECT (CASE
                        WHEN pc.priznak = 1 THEN
                         pc.reserve_distrib
                        ELSE
                         -pc.reserve_take
                      END)
                 FROM ins.t_inform_cover_lump pc
                WHERE pc.opt_brief = a.opt_brief
                  AND pc.change_year = a.par_t + 1) < 0 THEN
          0
         ELSE
          a.ad * a.s1 + (SELECT (CASE
                                  WHEN pc.priznak = 1 THEN
                                   pc.reserve_distrib
                                  ELSE
                                   -pc.reserve_take
                                END)
                           FROM ins.t_inform_cover_lump pc
                          WHERE pc.opt_brief = a.opt_brief
                            AND pc.change_year = a.par_t + 1) *
          (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                FROM ins.t_actuar_value ta
                               WHERE ta.par_t = a.par_t - 1
                                 AND ta.opt_brief = a.opt_brief))
       END)
      ELSE
       a.ad * a.s1
    END)*/
     WHERE a.par_t = 4
       AND a.opt_brief = 'PEPR_A_PLUS';
    /**/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 5;
    /*вклад 4 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                abs((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 4) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                abs((SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                      FROM ins.t_inform_cover_lump p
                                     WHERE p.change_year = pc.change_year))
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 5;
    /*доп доход 4 год*/
    UPDATE ins.t_actuar_value a
       SET a.tv_p2    = a.s1 * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.s1
     WHERE a.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 4;
  
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            abs((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 4) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 5;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.tv_p3
     WHERE ta.par_t = 4;
    /*СС 4 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         (SELECT t.s1
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                        ELSE
                         ((((SELECT SUM(t.did_res) FROM ins.t_actuar_value t WHERE t.par_t = ta.par_t - 1) -
                         (SELECT SUM(lp.pen_for_year)
                               FROM ins.t_inform_cover_lump lp
                              WHERE lp.change_year = ta.par_t)) *
                         (SELECT lp.w
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t)) * (CASE
                           WHEN ta.opt_brief = 'PEPR_A_PLUS' THEN
                            (SELECT t.tv_p
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) /
                            ((SELECT t.tv_p
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) +
                            (SELECT t.ad
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 2
                                 AND t.opt_brief = ta.opt_brief))
                           ELSE
                            1
                         END) - ta.cur_fee * (SELECT t.v_a1xn
                                                 FROM ins.t_actuar_value t
                                                WHERE t.par_t = ta.par_t - 1
                                                  AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 5;
    /*    UPDATE ins.t_actuar_value ta
      SET ta.s1 = (CASE
                    WHEN ta.cur_fee = 0 THEN
                     0
                    ELSE
                     (CASE
                       WHEN (SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                        (SELECT t.s1
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                       ELSE
                        ((SELECT t.tv_p3
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief) +
                        (SELECT pc.delta_res + pc.delta_eib
                            FROM ins.t_inform_cover_lump pc
                           WHERE pc.opt_brief = ta.opt_brief
                             AND pc.change_year = ta.par_t) -
                        ta.cur_fee * (SELECT t.v_a1xn
                                         FROM ins.t_actuar_value t
                                        WHERE t.par_t = ta.par_t - 1
                                          AND t.opt_brief = ta.opt_brief)) /
                        (SELECT t.v_nex
                           FROM ins.t_actuar_value t
                          WHERE t.par_t = ta.par_t - 1
                            AND t.opt_brief = ta.opt_brief)
                     END)
                  END)
    WHERE ta.par_t = 5;*/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 5;
    /**/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ADD_ANOTHER_UPDATE: ' || SQLERRM);
  END add_another_update;

  PROCEDURE update_investorplus(par_period_id NUMBER) IS
    const_act_loading_3          NUMBER := 0.0613;
    const_act_loading_5          NUMBER := 0.0643;
    const_act_loading_fbase_5    NUMBER := 0.09;
    const_act_loading_fagr_5     NUMBER := 0.08;
    const_act_loading_fagrplus_5 NUMBER := 0.0643;
    const_act_loading_invesplus  NUMBER := 0.07;
  BEGIN
    /*первый год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_investorplus(pc.cover_id
                                                                  ,pc.start_date
                                                                  ,trunc(pc.end_date)
                                                                  ,ta.par_t
                                                                  ,ta.opt_brief
                                                                  ,ta.par_n
                                                                  ,ta.net_prem_act)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.cover_id = ta.p_cover_id
               AND pc.change_year = 1)
     WHERE ta.par_t = 1;
    /*обновление sumg1*/
    UPDATE ins.t_actuar_value ta SET ta.sumg1 = ta.cur_fee WHERE ta.par_t = 1;
    /*Обновление tv_p2*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p2 = nvl(v.s1, v.sa) * v.v_nex + v.sumg1 * v.v_a1xn + v.cur_fee * v.v_ia1xn -
                     v.cur_fee * (1 - v.f_loading) * v.v_a_xn
     WHERE v.par_t = 1;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value va
       SET va.tv_p3 = (CASE
                        WHEN va.par_n = 5 THEN
                         nvl(va.s1, va.sa) * va.tv_p
                        ELSE
                         nvl(va.tv_p3, va.net_res)
                      END)
     WHERE va.par_t = 1;
    /*резерв 1 год*/
    UPDATE ins.t_inform_cover_lump pca
       SET (pca.w_for_distrib, pca.w_for_take) =
           (SELECT (CASE
                     WHEN (SELECT SUM(p.priznak)
                             FROM ins.t_inform_cover_lump p
                            WHERE p.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (pc.priznak * pc.delta_w) /
                      (SELECT SUM(p.priznak * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                   END) distrib
                  ,(CASE
                     WHEN ((SELECT SUM(nvl(p.fee_decrease, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1 OR
                          (SELECT SUM(nvl(p.fee_increase, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1) THEN
                      nvl(((1 - pc.priznak) * pc.delta_w) /
                          (SELECT SUM((1 - p.priznak) * nullif(p.delta_w, 0))
                             FROM ins.t_inform_cover_lump p
                            WHERE p.change_year = pc.change_year)
                         ,0)
                     ELSE
                      0
                   END) take
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = pca.opt_brief
               AND pc.change_year = pca.change_year)
     WHERE pca.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.reserve_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 2)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 2)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END)
     WHERE pc.change_year = 2;
    /*вклад 1 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.deposit_take, pc.deposit_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 2)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 2)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 2;
    /*доп доход 1 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT nvl(t.adres, 0)
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (nvl(ta.tvexp_sa, 0) + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 1;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 1;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.did_take, pc.did_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 2)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 2)) * p.w_for_distrib -
                   (SELECT SUM(ll.pen_for_year)
                      FROM ins.t_inform_cover_lump ll
                     WHERE ll.change_year = p.change_year) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 2;
  
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 2;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.net_res
     WHERE ta.par_t = 1;
    /*СС 1 год*/
    UPDATE ins.t_inform_cover_lump pcw
       SET pcw.bt =
           (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
              FROM ins.t_actuar_value ta
             WHERE ta.opt_brief = pcw.opt_brief
               AND ta.par_t = 1
               AND ta.par_t = pcw.change_year)
     WHERE pcw.change_year = 1;
  
    UPDATE ins.t_actuar_value ta
       SET (ta.s1) = (CASE
                       WHEN ta.cur_fee = 0 THEN
                        0
                       ELSE
                        (CASE
                          WHEN (SELECT t.cur_fee
                                  FROM ins.t_actuar_value t
                                 WHERE t.par_t = ta.par_t - 1
                                   AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                           ta.sa
                          ELSE
                           nvl(ta.s1, ta.sa) + ((SELECT t.cur_fee
                                                   FROM ins.t_actuar_value t
                                                  WHERE t.par_t = ta.par_t - 1
                                                    AND t.opt_brief = ta.opt_brief) - ta.cur_fee) *
                           (SELECT lp.bt
                                                  FROM ins.t_inform_cover_lump lp
                                                 WHERE lp.opt_brief = ta.opt_brief
                                                   AND lp.change_year = ta.par_t - 1) /
                           (SELECT t.v_nex
                                                  FROM ins.t_actuar_value t
                                                 WHERE t.opt_brief = ta.opt_brief
                                                   AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_eib
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_res
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                        END)
                     END)
     WHERE ta.par_t = 2;
    /**/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 2;
    /*net_prem_act*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act =
           (ta.cur_fee - (SELECT lp.pen_for_year
                            FROM ins.t_inform_cover_lump lp
                           WHERE lp.opt_brief = ta.opt_brief
                             AND lp.change_year = ta.par_t)) * (1 - const_act_loading_invesplus)
     WHERE ta.par_t = 2;
    /*второй год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_investorplus(pc.cover_id
                                                                  ,pc.start_date
                                                                  ,trunc(pc.end_date)
                                                                  ,ta.par_t
                                                                  ,ta.opt_brief
                                                                  ,ta.par_n
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 1
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,ta.net_prem_act)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 2;
    /*Обновление net_res 2 год*/
    UPDATE ins.t_actuar_value a
       SET a.net_res =
           (a.v_nex + a.g * (a.par_t * a.v_a1xn + a.v_ia1xn) - a.p * a.v_a_xn) * a.sa;
    /*обновление sumg1*/
    UPDATE ins.t_actuar_value ta
       SET ta.sumg1 = ta.cur_fee + (SELECT t.sumg1
                                      FROM ins.t_actuar_value t
                                     WHERE t.opt_brief = ta.opt_brief
                                       AND t.par_t = ta.par_t - 1)
     WHERE ta.par_t = 2;
    /*обновление sumg2*/
    UPDATE ins.t_actuar_value ta
       SET ta.sumg2 = ta.cur_fee + (SELECT t.cur_fee
                                      FROM ins.t_actuar_value t
                                     WHERE t.opt_brief = ta.opt_brief
                                       AND t.par_t = ta.par_t - 1)
     WHERE ta.par_t = 2;
    /*обновление tv_p1*/
    UPDATE ins.t_actuar_value ta
       SET ta.tv_p1 = nvl(ta.s1, ta.sa) * ta.v_nex + ta.sumg2 * ta.v_a1xn + ta.cur_fee * ta.v_ia1xn -
                      ta.cur_fee * (1 - ta.f_loading) * ta.v_a_xn
     WHERE ta.par_t = 2;
    /*обновление g1*/
    UPDATE ins.t_actuar_value ta
       SET ta.g1 =
           (SELECT (SELECT t.cur_fee
                      FROM ins.t_actuar_value t
                     WHERE t.opt_brief = ta.opt_brief
                       AND t.par_t = 2) - (SELECT lp.pen_for_year
                                             FROM ins.t_inform_cover_lump lp
                                            WHERE lp.opt_brief = ta.opt_brief
                                              AND lp.change_year = 2)
              FROM dual)
     WHERE ta.par_t > 0;
    /*Обновление tv_p2*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p2 = nvl(v.s1, v.sa) * v.v_nex + v.sumg1 * v.v_a1xn + v.g1 * v.v_ia1xn -
                     v.cur_fee * (1 - v.f_loading) * v.v_a_xn
     WHERE v.par_t = 2;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN v.par_n = 5 THEN
                        v.tv_p * nvl(v.s1, v.sa)
                       ELSE
                        (CASE
                          WHEN (SELECT va.cur_fee
                                  FROM ins.t_actuar_value va
                                 WHERE va.opt_brief = v.opt_brief
                                   AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                           v.net_res
                          ELSE
                           v.tv_p2
                        END)
                     END)
     WHERE v.par_t = 2;
    /*резерв 2 год*/
    UPDATE ins.t_inform_cover_lump pca
       SET (pca.w_for_distrib, pca.w_for_take) =
           (SELECT (CASE
                     WHEN (SELECT SUM(p.priznak)
                             FROM ins.t_inform_cover_lump p
                            WHERE p.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (pc.priznak * pc.delta_w) /
                      (SELECT SUM(p.priznak * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                   END) distrib
                  ,(CASE
                     WHEN ((SELECT SUM(nvl(p.fee_decrease, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1 OR
                          (SELECT SUM(nvl(p.fee_increase, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1) THEN
                      ((1 - pc.priznak) * pc.delta_w) /
                      (SELECT SUM((1 - p.priznak) * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                     ELSE
                      0
                   END) take
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = pca.opt_brief
               AND pc.change_year = pca.change_year)
     WHERE pca.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.reserve_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 3)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 3)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END)
     WHERE pc.change_year = 3;
    /*вклад 2 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.deposit_take, pc.deposit_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 3)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 3)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 3;
    /*доп доход 2 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT nvl(t.adres, 0)
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (nvl(ta.tvexp_sa, 0) + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 2;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 2;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.did_take, pc.did_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 3)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 3)) * p.w_for_distrib -
                   (SELECT SUM(ll.pen_for_year)
                      FROM ins.t_inform_cover_lump ll
                     WHERE ll.change_year = p.change_year) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 3;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.net_res
     WHERE ta.par_t = 2;
    /*СС 2 год*/
    UPDATE ins.t_inform_cover_lump pcw
       SET pcw.bt =
           (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
              FROM ins.t_actuar_value ta
             WHERE ta.opt_brief = pcw.opt_brief
               AND ta.par_t = 2
               AND ta.par_t = pcw.change_year)
     WHERE pcw.change_year = 2;
  
    UPDATE ins.t_actuar_value ta
       SET (ta.s1) = (CASE
                       WHEN ta.cur_fee = 0 THEN
                        0
                       ELSE
                        (CASE
                          WHEN (SELECT t.cur_fee
                                  FROM ins.t_actuar_value t
                                 WHERE t.par_t = ta.par_t - 1
                                   AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                           (SELECT t.s1
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                          ELSE
                           (SELECT nvl(t.s1, t.sa)
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           ((SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) - ta.cur_fee) *
                           (SELECT lp.bt
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t - 1) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_eib
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_res
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                        END)
                     END)
     WHERE ta.par_t = 3;
    /**/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 3;
    /*net_prem_act*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act =
           (ta.cur_fee - (SELECT lp.pen_for_year
                            FROM ins.t_inform_cover_lump lp
                           WHERE lp.opt_brief = ta.opt_brief
                             AND lp.change_year = ta.par_t)) * (1 - const_act_loading_invesplus)
     WHERE ta.par_t = 3;
    /****************************************************************/
    /*третий год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_investorplus(pc.cover_id
                                                                  ,pc.start_date
                                                                  ,trunc(pc.end_date)
                                                                  ,ta.par_t
                                                                  ,ta.opt_brief
                                                                  ,ta.par_n
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 1
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 2
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,ta.net_prem_act)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 3;
    /*обновление sumg1*/
    UPDATE ins.t_actuar_value ta
       SET ta.sumg1 = ta.g1 + (SELECT t.sumg1
                                 FROM ins.t_actuar_value t
                                WHERE t.opt_brief = ta.opt_brief
                                  AND t.par_t = ta.par_t - 1)
     WHERE ta.par_t = 3;
    /*обновление g2*/
    UPDATE ins.t_actuar_value ta
       SET ta.g2 =
           (SELECT (SELECT t.cur_fee
                      FROM ins.t_actuar_value t
                     WHERE t.opt_brief = ta.opt_brief
                       AND t.par_t = 3) - (SELECT lp.pen_for_year
                                             FROM ins.t_inform_cover_lump lp
                                            WHERE lp.opt_brief = ta.opt_brief
                                              AND lp.change_year = 3)
              FROM dual)
     WHERE ta.par_t > 0;
    /*обновление sumg2*/
    UPDATE ins.t_actuar_value ta
       SET ta.sumg2 = ta.g2 + (SELECT t.sumg2
                                 FROM ins.t_actuar_value t
                                WHERE t.opt_brief = ta.opt_brief
                                  AND t.par_t = ta.par_t - 1)
     WHERE ta.par_t = 3;
    /*обновление tv_p1*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p1 = nvl(v.s1, v.sa) * v.v_nex + v.sumg2 * v.v_a1xn + v.g2 * v.v_ia1xn -
                     v.cur_fee * (1 - v.f_loading) * v.v_a_xn
     WHERE v.par_t = 3;
    /*Обновление tv_p2*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p2 = nvl(v.s1, v.sa) * v.v_nex + v.sumg1 * v.v_a1xn + v.g1 * v.v_ia1xn -
                     v.cur_fee * (1 - v.f_loading) * v.v_a_xn
     WHERE v.par_t = 3;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN v.par_n = 5 THEN
                        v.tv_p * nvl(v.s1, v.sa)
                       ELSE
                        (CASE
                          WHEN (SELECT va.cur_fee
                                  FROM ins.t_actuar_value va
                                 WHERE va.opt_brief = v.opt_brief
                                   AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                          
                           (CASE
                             WHEN (SELECT va.cur_fee
                                     FROM ins.t_actuar_value va
                                    WHERE va.opt_brief = v.opt_brief
                                      AND va.par_t = v.par_t - 2) =
                                  (SELECT va.cur_fee
                                     FROM ins.t_actuar_value va
                                    WHERE va.opt_brief = v.opt_brief
                                      AND va.par_t = v.par_t - 1) THEN
                              v.net_res
                             ELSE
                              v.tv_p2
                           END)
                          ELSE
                           v.tv_p1
                        END)
                     END)
     WHERE v.par_t = 3;
    /*резерв 3 год*/
    UPDATE ins.t_inform_cover_lump pca
       SET (pca.w_for_distrib, pca.w_for_take) =
           (SELECT (CASE
                     WHEN (SELECT SUM(p.priznak)
                             FROM ins.t_inform_cover_lump p
                            WHERE p.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (pc.priznak * pc.delta_w) /
                      (SELECT SUM(p.priznak * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                   END) distrib
                  ,(CASE
                     WHEN ((SELECT SUM(nvl(p.fee_decrease, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1 OR
                          (SELECT SUM(nvl(p.fee_increase, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1) THEN
                      ((1 - pc.priznak) * pc.delta_w) /
                      (SELECT SUM((1 - p.priznak) * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                     ELSE
                      0
                   END) take
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = pca.opt_brief
               AND pc.change_year = pca.change_year)
     WHERE pca.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.reserve_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 4)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 4)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END)
     WHERE pc.change_year = 4;
    /*вклад 3 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.deposit_take, pc.deposit_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 4)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 4)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 4;
    /*доп доход 3 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT nvl(t.adres, 0)
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (nvl(ta.tvexp_sa, 0) + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.did_take, pc.did_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 4)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 4)) * p.w_for_distrib -
                   (SELECT SUM(ll.pen_for_year)
                      FROM ins.t_inform_cover_lump ll
                     WHERE ll.change_year = p.change_year) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 4;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.net_res
     WHERE ta.par_t = 3;
    /*СС 3 год*/
    UPDATE ins.t_inform_cover_lump pcw
       SET pcw.bt =
           (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
              FROM ins.t_actuar_value ta
             WHERE ta.opt_brief = pcw.opt_brief
               AND ta.par_t = 3
               AND ta.par_t = pcw.change_year)
     WHERE pcw.change_year = 3;
  
    UPDATE ins.t_actuar_value ta
       SET (ta.s1) = (CASE
                       WHEN ta.cur_fee = 0 THEN
                        0
                       ELSE
                        (CASE
                          WHEN (SELECT t.cur_fee
                                  FROM ins.t_actuar_value t
                                 WHERE t.par_t = ta.par_t - 1
                                   AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                           (SELECT t.s1
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                          ELSE
                           (SELECT nvl(t.s1, t.sa)
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           ((SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) - ta.cur_fee) *
                           (SELECT lp.bt
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t - 1) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_eib
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_res
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                        END)
                     END)
     WHERE ta.par_t = 4;
    /**/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 4;
    /*net_prem_act*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act =
           (ta.cur_fee - (SELECT lp.pen_for_year
                            FROM ins.t_inform_cover_lump lp
                           WHERE lp.opt_brief = ta.opt_brief
                             AND lp.change_year = ta.par_t)) * (1 - const_act_loading_invesplus)
     WHERE ta.par_t = 4;
    /****************************************************************/
    /*четвертый год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_investorplus(pc.cover_id
                                                                  ,pc.start_date
                                                                  ,trunc(pc.end_date)
                                                                  ,ta.par_t
                                                                  ,ta.opt_brief
                                                                  ,ta.par_n
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 1
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 2
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 3
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,ta.net_prem_act)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 4;
    /*обновление sumg1*/
    UPDATE ins.t_actuar_value ta
       SET ta.sumg1 = ta.g1 + (SELECT t.sumg1
                                 FROM ins.t_actuar_value t
                                WHERE t.opt_brief = ta.opt_brief
                                  AND t.par_t = ta.par_t - 1)
     WHERE ta.par_t = 4;
    /*обновление sumg2*/
    UPDATE ins.t_actuar_value ta
       SET ta.sumg2 = ta.g2 + (SELECT t.sumg2
                                 FROM ins.t_actuar_value t
                                WHERE t.opt_brief = ta.opt_brief
                                  AND t.par_t = ta.par_t - 1)
     WHERE ta.par_t = 4;
    /*обновление tv_p1*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p1 = nvl(v.s1, v.sa) * v.v_nex + v.sumg2 * v.v_a1xn + v.g2 * v.v_ia1xn -
                     v.cur_fee * (1 - v.f_loading) * v.v_a_xn
     WHERE v.par_t = 4;
    /*Обновление tv_p2*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p2 = nvl(v.s1, v.sa) * v.v_nex + v.sumg1 * v.v_a1xn + v.g1 * v.v_ia1xn -
                     v.cur_fee * (1 - v.f_loading) * v.v_a_xn
     WHERE v.par_t = 4;
    /*Обновление tv_p3*/
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN v.par_n = 5 THEN
                        v.tv_p * nvl(v.s1, v.sa)
                       ELSE
                        (CASE
                          WHEN (SELECT va.cur_fee
                                  FROM ins.t_actuar_value va
                                 WHERE va.opt_brief = v.opt_brief
                                   AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                          
                           (CASE
                             WHEN (SELECT va.cur_fee
                                     FROM ins.t_actuar_value va
                                    WHERE va.opt_brief = v.opt_brief
                                      AND va.par_t = v.par_t - 2) =
                                  (SELECT va.cur_fee
                                     FROM ins.t_actuar_value va
                                    WHERE va.opt_brief = v.opt_brief
                                      AND va.par_t = v.par_t - 1) THEN
                              v.net_res
                             ELSE
                              v.tv_p2
                           END)
                          ELSE
                           v.tv_p1
                        END)
                     END)
     WHERE v.par_t = 4;
    /*резерв 4 год*/
    UPDATE ins.t_inform_cover_lump pca
       SET (pca.w_for_distrib, pca.w_for_take) =
           (SELECT (CASE
                     WHEN (SELECT SUM(p.priznak)
                             FROM ins.t_inform_cover_lump p
                            WHERE p.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (pc.priznak * pc.delta_w) /
                      (SELECT SUM(p.priznak * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                   END) distrib
                  ,(CASE
                     WHEN ((SELECT SUM(nvl(p.fee_decrease, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1 OR
                          (SELECT SUM(nvl(p.fee_increase, 0))
                              FROM ins.t_inform_cover_lump p
                             WHERE p.change_year = pc.change_year) = 1) THEN
                      ((1 - pc.priznak) * pc.delta_w) /
                      (SELECT SUM((1 - p.priznak) * p.delta_w)
                         FROM ins.t_inform_cover_lump p
                        WHERE p.change_year = pc.change_year)
                     ELSE
                      0
                   END) take
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = pca.opt_brief
               AND pc.change_year = pca.change_year)
     WHERE pca.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.reserve_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 5)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.tv_p3
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 5)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END)
     WHERE pc.change_year = 5;
    /*вклад 4 год*/
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.deposit_take, pc.deposit_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 5)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.savings
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 5)) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 5;
    /*доп доход 4 год*/
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT nvl(t.adres, 0)
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (nvl(ta.tvexp_sa, 0) + greatest(ta.tv_p3, 0))
     WHERE ta.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.did_take, pc.did_distrib) =
           (SELECT (SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 5)) * p.w_for_take
                  ,(SELECT (- ((1 - pro) * wo * so + (1 - prg) * wg * sg))
                      FROM (SELECT pco.priznak pro
                                  ,pco.delta_w / 100 wo
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pco.opt_brief
                                       AND ta.par_t = pco.change_year - 1) so
                                  ,pcg.priznak prg
                                  ,pcg.delta_w / 100 wg
                                  ,(SELECT ta.eib_theor
                                      FROM ins.t_actuar_value ta
                                     WHERE ta.opt_brief = pcg.opt_brief
                                       AND ta.par_t = pcg.change_year - 1) sg
                              FROM ins.t_inform_cover_lump pco
                                  ,ins.t_inform_cover_lump pcg
                             WHERE pco.change_year = pcg.change_year
                               AND pco.opt_brief = 'OIL'
                               AND pcg.opt_brief = 'GOLD'
                               AND pco.change_year = 5)) * p.w_for_distrib -
                   (SELECT SUM(ll.pen_for_year)
                      FROM ins.t_inform_cover_lump ll
                     WHERE ll.change_year = p.change_year) * p.w_for_distrib
              FROM ins.t_inform_cover_lump p
             WHERE p.change_year = pc.change_year
               AND p.opt_brief = pc.opt_brief)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 5;
    /*Обновление ДИД резерва*/
    UPDATE ins.t_actuar_value ta
       SET ta.did_res = greatest((ta.eib_theor * ta.v_nex), 0) + ta.net_res
     WHERE ta.par_t = 4;
    /*СС 4 год*/
    UPDATE ins.t_inform_cover_lump pcw
       SET pcw.bt =
           (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
              FROM ins.t_actuar_value ta
             WHERE ta.opt_brief = pcw.opt_brief
               AND ta.par_t = 4
               AND ta.par_t = pcw.change_year)
     WHERE pcw.change_year = 4;
  
    UPDATE ins.t_actuar_value ta
       SET (ta.s1) = (CASE
                       WHEN ta.cur_fee = 0 THEN
                        0
                       ELSE
                        (CASE
                          WHEN (SELECT t.cur_fee
                                  FROM ins.t_actuar_value t
                                 WHERE t.par_t = ta.par_t - 1
                                   AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                           (SELECT t.s1
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                          ELSE
                           (SELECT nvl(t.s1, t.sa)
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           ((SELECT t.cur_fee
                               FROM ins.t_actuar_value t
                              WHERE t.par_t = ta.par_t - 1
                                AND t.opt_brief = ta.opt_brief) - ta.cur_fee) *
                           (SELECT lp.bt
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t - 1) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_eib
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1) +
                           (SELECT lp.delta_res
                              FROM ins.t_inform_cover_lump lp
                             WHERE lp.opt_brief = ta.opt_brief
                               AND lp.change_year = ta.par_t) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.opt_brief = ta.opt_brief
                               AND t.par_t = ta.par_t - 1)
                        END)
                     END)
     WHERE ta.par_t = 5;
    /**/
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.s1 < 0 THEN
                      0
                     ELSE
                      ta.s1
                   END)
     WHERE ta.par_t = 5;
    /*net_prem_act*/
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act =
           (ta.cur_fee - (SELECT lp.pen_for_year
                            FROM ins.t_inform_cover_lump lp
                           WHERE lp.opt_brief = ta.opt_brief
                             AND lp.change_year = ta.par_t)) * (1 - const_act_loading_invesplus)
     WHERE ta.par_t = 5;
    /**********************************************/
    /*пятый год SAVINGS*/
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT pkg_change_anniversary.get_savings_investorplus(pc.cover_id
                                                                  ,pc.start_date
                                                                  ,trunc(pc.end_date)
                                                                  ,ta.par_t
                                                                  ,ta.opt_brief
                                                                  ,ta.par_n
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 1
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 2
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 3
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,(SELECT tat.net_prem_act
                                                                     FROM ins.t_actuar_value tat
                                                                    WHERE tat.par_t = 4
                                                                      AND tat.opt_brief = pc.opt_brief)
                                                                  ,ta.net_prem_act)
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 5;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении UPDATE_INVESTORPLUS: ' || SQLERRM);
  END update_investorplus;
  /**/
  FUNCTION get_savings_lump
  (
    par_opt_brief      VARCHAR2
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_t              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_cover_id       NUMBER
  ) RETURN NUMBER IS
    v_yield_min             NUMBER;
    res_1                   NUMBER := 0;
    res_2                   NUMBER := 0;
    res_3                   NUMBER := 0;
    res_4                   NUMBER := 0;
    res_5                   NUMBER := 0;
    v_days                  NUMBER := 0;
    v_date_begin            DATE;
    v_delta_deposit         NUMBER := 0;
    v_loop                  NUMBER := 12;
    const_days_1            NUMBER := 0;
    const_days_2            NUMBER := 0;
    v_pol_header_start_date DATE;
  BEGIN
  
    FOR k IN 1 .. par_t
    LOOP
      IF k = par_t
      THEN
        v_loop := 13;
      ELSE
        v_loop := 12;
      END IF;
      FOR i IN 1 .. v_loop
      LOOP
        IF k = 1
           AND i = 1
        THEN
          v_days       := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
          const_days_1 := v_days;
          const_days_2 := par_date_begin - trunc(par_date_begin, 'MM');
        ELSIF (k = 3 AND i = 13)
              OR (k = 5 AND i = 13)
        THEN
          v_days := par_date_end - ADD_MONTHS(v_date_begin, 12) + 1;
        ELSE
          v_days := 30;
        END IF;
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (k - 1)), 'MM');
      
        --Чирков/добавлено условие/ по заявке 250261: таблицы доходности 
        --******************************************   
        /*определение даты начала ДС по cover_id*/
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
        /**/
      
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'PEPR_B' THEN
                    ty.base_min
                   WHEN 'PEPR_A_PLUS' THEN
                    ty.aggressive_plus_min
                   WHEN 'PEPR_A' THEN
                    ty.aggressive_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'PEPR_B' THEN
                    ty.base_min
                   WHEN 'PEPR_A_PLUS' THEN
                    ty.aggressive_plus_min
                   WHEN 'PEPR_A' THEN
                    ty.aggressive_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = ADD_MONTHS(v_date_begin, i - 1);
        END IF;
        --******************************************                              
      
        IF k = 1
           AND i = 1
        THEN
          res_1 := ROUND((par_net_prem_act_1) * (1 + (v_yield_min / 30) * v_days), 2);
        ELSIF i = 13
        THEN
          v_days := par_date_begin - trunc(par_date_begin, 'MM');
          res_1  := ROUND(res_1 * (1 + (v_days / 30) * v_yield_min), 2);
        ELSE
          IF k > 1
             AND i = 1
          THEN
            BEGIN
              SELECT nvl(pc.delta_deposit, 0)
                INTO v_delta_deposit
                FROM ins.t_inform_cover_lump pc
               WHERE pc.opt_brief = par_opt_brief
                 AND pc.change_year = k;
            EXCEPTION
              WHEN no_data_found THEN
                v_delta_deposit := 0;
            END;
            IF v_delta_deposit = 0
            THEN
              res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
            ELSE
              res_1 := ROUND(((ROUND(res_1 * (1 + v_yield_min * const_days_2 / 30), 2)) +
                             v_delta_deposit) * (1 + (v_yield_min / 30) * const_days_1)
                            ,2);
            END IF;
          ELSE
            res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      
      END LOOP;
    
    END LOOP;
  
    RETURN ROUND(res_1 + res_2 + res_3 + res_4 + res_5, 2);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_SAVINGS_LUMP: ' || SQLERRM);
  END get_savings_lump;
  /**/
  PROCEDURE inform_cover_quart
  (
    par_header_id  NUMBER
   ,par_val_period NUMBER
   ,par_policy_id  NUMBER
  ) IS
    proc_name    VARCHAR2(30) := 'INFORM_COVER_QUART';
    v_continue   BOOLEAN := FALSE;
    m            NUMBER := 0;
    proc_penalty NUMBER := 0.03;
    v_quart      NUMBER := 4;
  BEGIN
  
    IF par_val_period > 0
    THEN
      v_continue := TRUE;
    END IF;
  
    IF v_continue
    THEN
      FOR i IN 1 .. par_val_period
      LOOP
        FOR l IN 1 .. v_quart
        LOOP
          m := m + 1;
          INSERT INTO ins.t_inform_cover_lump
            (opt_brief
            ,header_id
            ,cover_id
            ,policy_id
            ,start_date
            ,end_date
            ,amount
            ,prem
            ,fee
            ,pl_id
            ,sum_prem
            ,deathrate_id
            ,fact_yield_rate
            ,sex
            ,age
            ,f_loading
            ,const_tariff
            ,change_year
            ,quart_value
            ,is_change)
            SELECT opt.brief
                  ,ph.policy_header_id
                  ,pc.p_cover_id
                  ,p.policy_id
                  ,ph.start_date
                  ,p.end_date
                  ,pc.ins_amount
                  ,pc.premium
                  ,pc.fee
                  ,pl.id pl_id
                  ,(SELECT SUM(pca.premium)
                      FROM ins.p_cover            pca
                          ,ins.t_prod_line_option opta
                          ,ins.t_product_line     pla
                          ,ins.t_lob_line         lba
                     WHERE pca.as_asset_id = a.as_asset_id
                       AND pca.t_prod_line_option_id = opta.id
                       AND opta.product_line_id = pla.id
                       AND pla.description NOT IN
                           ('Административные издержки'
                           ,'Административные издержки на восстановление')
                       AND pla.t_lob_line_id = lba.t_lob_line_id
                       AND lba.brief != 'Penalty'
                       AND lba.t_lob_id NOT IN
                           (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')) sum_prem
                  ,decode(plr.func_id
                         ,NULL
                         ,plr.deathrate_id
                         ,ins.pkg_tariff_calc.calc_fun(plr.func_id
                                                      ,ins.ent.id_by_brief('P_COVER')
                                                      ,pc.p_cover_id)) deathrate_id
                  ,pc.normrate_value fact_yield_rate
                  ,decode(per.gender, 0, 'w', 1, 'm') sex
                  ,pc.insured_age age
                  ,pc.rvb_value
                  ,(CASE
                     WHEN prod.brief IN ('INVESTOR_LUMP'
                                        ,'INVESTOR_LUMP_OLD'
                                        ,'Priority_Invest(lump)'
                                        ,'Invest_in_future') THEN
                      (CASE
                        WHEN MONTHS_BETWEEN(p.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                         (CASE opt.brief
                           WHEN 'PEPR_A' THEN
                            0.9482
                           WHEN 'PEPR_A_PLUS' THEN
                            0.8052
                           WHEN 'PEPR_B' THEN
                            1.0070
                         END)
                        ELSE
                         (CASE opt.brief
                           WHEN 'PEPR_A' THEN
                            0.9452
                           WHEN 'PEPR_A_PLUS' THEN
                            0.8043
                           WHEN 'PEPR_B' THEN
                            1.0492
                         END)
                      END)
                     ELSE
                      (CASE opt.brief
                        WHEN 'PEPR_A' THEN
                         2.9743
                        WHEN 'PEPR_C' THEN
                         3.1614
                        WHEN 'PEPR_B' THEN
                         3.0451
                      END)
                   END) const_tariff
                  ,i
                  ,m
                  ,(SELECT 1
                     FROM dual
                    WHERE EXISTS
                    (SELECT NULL
                             FROM ins.p_pol_addendum_type pat
                                 ,ins.t_addendum_type     t
                            WHERE pat.p_policy_id = par_policy_id
                              AND pat.p_policy_id = p.policy_id
                              AND pat.t_addendum_type_id = t.t_addendum_type_id
                              AND t.brief IN ('INCREASE_SIZE_QUARTER', 'CHANGE_STRATEGY_QUARTER')))
              FROM ins.p_pol_header       ph
                  ,ins.p_policy           p
                  ,ins.as_asset           a
                  ,ins.as_assured         ass
                  ,ins.cn_person          per
                  ,ins.p_cover            pc
                  ,ins.t_prod_line_option opt
                  ,ins.t_product_line     pl
                  ,ins.t_lob_line         lb
                  ,ins.t_prod_line_rate   plr
                  ,ins.t_product          prod
             WHERE ph.policy_header_id = p.pol_header_id
               AND p.policy_id = a.p_policy_id
               AND a.as_asset_id = ass.as_assured_id
               AND ass.assured_contact_id = per.contact_id(+)
               AND a.as_asset_id = pc.as_asset_id
               AND pc.t_prod_line_option_id = opt.id
               AND opt.product_line_id = pl.id
               AND pl.id = plr.product_line_id
               AND ph.policy_header_id = par_header_id
               AND ph.product_id = prod.product_id
                  /*AND p.start_date BETWEEN ADD_MONTHS(ph.start_date, 3 * (l - 1) + (i - 1) * 12)
                  AND ADD_MONTHS(ADD_MONTHS(ph.start_date, 3 * (l - 1) + (i - 1) * 12),3)*/
               AND pl.description NOT IN
                   ('Административные издержки'
                   ,'Административные издержки на восстановление')
               AND pl.t_lob_line_id = lb.t_lob_line_id
               AND lb.brief != 'Penalty'
               AND lb.t_lob_id NOT IN (SELECT tl.t_lob_id FROM ins.t_lob tl WHERE tl.brief IN 'Acc')
               AND p.version_num =
                   (SELECT MAX(ppl.version_num)
                      FROM ins.p_policy       ppl
                          ,ins.document       d
                          ,ins.doc_status_ref rf
                     WHERE ppl.pol_header_id = par_header_id
                       AND ppl.policy_id = d.document_id
                       AND d.doc_status_ref_id = rf.doc_status_ref_id
                       AND rf.brief != 'CANCEL'
                       AND ppl.start_date BETWEEN ADD_MONTHS(ph.start_date, 3 * (l - 1) + (i - 1) * 12) AND
                           ADD_MONTHS(ADD_MONTHS(ph.start_date, 3 * (l - 1) + (i - 1) * 12), 3) -
                           1 / 24 / 3600);
          IF SQL%ROWCOUNT = 0
          THEN
            INSERT INTO ins.t_inform_cover_lump
              (opt_brief
              ,header_id
              ,cover_id
              ,policy_id
              ,start_date
              ,end_date
              ,amount
              ,prem
              ,fee
              ,pl_id
              ,sum_prem
              ,deathrate_id
              ,fact_yield_rate
              ,sex
              ,age
              ,f_loading
              ,const_tariff
              ,change_year
              ,quart_value)
              SELECT lp.opt_brief
                    ,lp.header_id
                    ,lp.cover_id
                    ,lp.policy_id
                    ,lp.start_date
                    ,lp.end_date
                    ,lp.amount
                    ,lp.prem
                    ,lp.fee
                    ,lp.pl_id
                    ,lp.sum_prem
                    ,lp.deathrate_id
                    ,lp.fact_yield_rate
                    ,lp.sex
                    ,lp.age
                    ,lp.f_loading
                    ,lp.const_tariff
                    ,i
                    ,m
                FROM ins.t_inform_cover_lump lp
               WHERE lp.header_id = par_header_id
                 AND lp.quart_value = m - 1;
          END IF;
        END LOOP;
      END LOOP;
      /**/
      UPDATE ins.t_inform_cover_lump cv SET cv.perc_for_year = cv.fee / cv.sum_prem * 100;
    
      FOR i IN 1 .. par_val_period * v_quart
      LOOP
        /*IF i < 5
        THEN
          UPDATE ins.t_inform_cover_lump cv SET cv.pen_for_year = 0 WHERE cv.quart_value = i;
        ELSE*/
        UPDATE ins.t_inform_cover_lump cv
           SET cv.pen_for_year = greatest((SELECT l.fee
                                             FROM ins.t_inform_cover_lump l
                                            WHERE l.quart_value = i - 1
                                              AND l.opt_brief = cv.opt_brief) -
                                          cv.sum_prem * (cv.fee / cv.sum_prem)
                                         ,0) * proc_penalty
              ,cv.delta_prem   = abs((SELECT cv.fee - l.fee
                                       FROM ins.t_inform_cover_lump l
                                      WHERE l.quart_value = i - 1
                                        AND l.opt_brief = cv.opt_brief))
         WHERE cv.quart_value = i;
        /*END IF;*/
      END LOOP;
      /**/
    END IF;
    /**/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' || SQLERRM);
  END inform_cover_quart;
  /**/
  PROCEDURE actuar_value_quart(par_policy_id NUMBER) IS
    pv_is_prod      NUMBER;
    pv_pen_year     NUMBER := 0;
    pv_change_quart NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO pv_is_prod
      FROM dual
     WHERE EXISTS (SELECT NULL FROM ins.t_inform_cover_lump lp WHERE lp.opt_brief = 'PEPR_A_PLUS');
    DELETE FROM ins.t_actuar_value;
    INSERT INTO ins.t_actuar_value
      SELECT res.policy_id
            ,res.pol_header_id
            ,ph.start_date
            ,pol.end_date
            ,res.t_product_line_id
            ,res.p_cover_id
            ,rv.insurance_year_date
            ,NULL
            ,NULL
            ,NULL
            ,rv.plan
            ,rv.fact
            ,rv.insurance_year_number par_t
            ,inf.par_values_age
            ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 par_n
            ,inf.sex_vh
            ,inf.deathrate_id
            ,inf.fact_yield_rate
            ,inf.f_loading
            ,ROUND(ins.pkg_amath.a_xn(inf.par_values_age + rv.insurance_year_number /*par_t*/
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 /*par_n*/
                                      -rv.insurance_year_number /*par_t*/
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,inf.deathrate_id /*par_values.deathrate_id*/
                                     ,inf.fact_yield_rate /*par_values.fact_yield_rate*/)
                  ,10) v_a_xn
            ,ROUND(ins.pkg_amath.a_xn(inf.par_values_age
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,inf.deathrate_id
                                     ,inf.fact_yield_rate)
                  ,10) v_a_x_n
            ,ROUND(ins.pkg_amath.ax1n(inf.par_values_age + rv.insurance_year_number
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                      rv.insurance_year_number
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,inf.deathrate_id
                                     ,inf.fact_yield_rate)
                  ,10) v_a1xn
            ,ROUND(ins.pkg_amath.iax1n(inf.par_values_age + rv.insurance_year_number
                                      ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                       rv.insurance_year_number
                                      ,inf.sex_vh
                                      ,0 /*par_values.k_coef*/
                                      ,0 /*par_values.s_coef*/
                                      ,inf.deathrate_id
                                      ,inf.fact_yield_rate)
                  ,10) v_ia1xn
            ,ROUND(ins.pkg_amath.nex(inf.par_values_age + rv.insurance_year_number
                                    ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                     rv.insurance_year_number
                                    ,inf.sex_vh
                                    ,0 /*par_values.k_coef*/
                                    ,0 /*par_values.s_coef*/
                                    ,inf.deathrate_id
                                    ,inf.fact_yield_rate)
                  ,10) v_nex
            ,(CASE
               WHEN pv_is_prod = 1 THEN
                (CASE
                  WHEN MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                   (CASE opt.brief
                     WHEN 'PEPR_A' THEN
                      0.9482
                     WHEN 'PEPR_A_PLUS' THEN
                      0.8052
                     WHEN 'PEPR_B' THEN
                      1.0070
                   END)
                  ELSE
                   (CASE opt.brief
                     WHEN 'PEPR_A' THEN
                      0.9452
                     WHEN 'PEPR_A_PLUS' THEN
                      0.8043
                     WHEN 'PEPR_B' THEN
                      1.0492
                   END)
                END)
               ELSE
                (CASE opt.brief
                  WHEN 'PEPR_A' THEN
                   2.9743
                  WHEN 'PEPR_C' THEN
                   3.1614
                  WHEN 'PEPR_B' THEN
                   3.0451
                END)
             END) * (CASE
               WHEN rv.insurance_year_number = 0
                    AND inf.quart_value - 1 = 0 THEN
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.quart_value = 1)
               ELSE
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.quart_value = inf.quart_value - 1)
             END) sa
            ,NULL
            ,NULL p_1
            ,(CASE
               WHEN rv.insurance_year_number = 0
                    AND inf.quart_value - 1 = 0 THEN
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.quart_value = 1)
               ELSE
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.quart_value = inf.quart_value - 1)
             END) cur_fee
            ,opt.brief
            ,(1 - (CASE
               WHEN pv_is_prod = 1 THEN
                (CASE opt.brief
                  WHEN 'PEPR_A' THEN
                   0.122
                  WHEN 'PEPR_A_PLUS' THEN
                   0.1
                  WHEN 'PEPR_B' THEN
                   0.14
                END)
               ELSE
                (CASE opt.brief
                  WHEN 'PEPR_C' THEN
                   0.09
                  WHEN 'PEPR_A' THEN
                   0.13
                  WHEN 'PEPR_B' THEN
                   0.14
                END)
             END)) * (CASE
               WHEN rv.insurance_year_number = 0
                    AND inf.quart_value - 1 = 0 THEN
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.quart_value = 1)
               ELSE
                (SELECT l.fee
                   FROM ins.t_inform_cover_lump l
                  WHERE l.pl_id = res.t_product_line_id
                    AND l.quart_value = inf.quart_value - 1)
             END) net_prem_act
            ,NULL
            ,NULL
            ,NULL
            ,0
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,(CASE
               WHEN pv_is_prod = 1 THEN
                0.0025
               ELSE
                0.04
             END)
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,inf.quart_value - 1
            ,NULL
            ,NULL
            ,NULL
            ,NULL
        FROM reserve.r_reserve res
            ,reserve.r_reserve_value rv
            ,ins.p_pol_header ph
            ,ins.p_policy pol
            ,ins.t_prod_line_option opt
            ,(SELECT pc.age             par_values_age
                    ,pc.sex             sex_vh
                    ,pc.deathrate_id
                    ,pc.fact_yield_rate
                    ,pc.f_loading
                    ,pc.pl_id
                    ,pc.fee
                    ,pc.change_year
                    ,pc.quart_value
                FROM ins.t_inform_cover_lump pc) inf
       WHERE res.policy_id = (SELECT p.policy_id
                                FROM ins.p_policy pp
                                    ,ins.p_policy p
                               WHERE pp.policy_id = par_policy_id
                                 AND pp.pol_header_id = p.pol_header_id
                                 AND p.version_num = 1)
         AND rv.reserve_id = res.id
         AND ph.policy_header_id = res.pol_header_id
         AND pol.policy_id = res.policy_id
         AND res.t_product_line_id = opt.product_line_id
         AND opt.product_line_id = inf.pl_id
         AND inf.change_year - 1 = rv.insurance_year_number
      UNION
      SELECT res.policy_id
            ,res.pol_header_id
            ,ph.start_date
            ,pol.end_date
            ,res.t_product_line_id
            ,res.p_cover_id
            ,rv.insurance_year_date
            ,NULL
            ,NULL
            ,NULL
            ,rv.plan
            ,rv.fact
            ,rv.insurance_year_number par_t
            ,inf.par_values_age
            ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 par_n
            ,inf.sex_vh
            ,inf.deathrate_id
            ,inf.fact_yield_rate
            ,inf.f_loading
            ,ROUND(ins.pkg_amath.a_xn(inf.par_values_age + rv.insurance_year_number /*par_t*/
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 /*par_n*/
                                      -rv.insurance_year_number /*par_t*/
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,inf.deathrate_id /*par_values.deathrate_id*/
                                     ,inf.fact_yield_rate /*par_values.fact_yield_rate*/)
                  ,10) v_a_xn
            ,ROUND(ins.pkg_amath.a_xn(inf.par_values_age
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,1
                                     ,inf.deathrate_id
                                     ,inf.fact_yield_rate)
                  ,10) v_a_x_n
            ,ROUND(ins.pkg_amath.ax1n(inf.par_values_age + rv.insurance_year_number
                                     ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                      rv.insurance_year_number
                                     ,inf.sex_vh
                                     ,0 /*par_values.k_coef*/
                                     ,0 /*par_values.s_coef*/
                                     ,inf.deathrate_id
                                     ,inf.fact_yield_rate)
                  ,10) v_a1xn
            ,ROUND(ins.pkg_amath.iax1n(inf.par_values_age + rv.insurance_year_number
                                      ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                       rv.insurance_year_number
                                      ,inf.sex_vh
                                      ,0 /*par_values.k_coef*/
                                      ,0 /*par_values.s_coef*/
                                      ,inf.deathrate_id
                                      ,inf.fact_yield_rate)
                  ,10) v_ia1xn
            ,ROUND(ins.pkg_amath.nex(inf.par_values_age + rv.insurance_year_number
                                    ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 -
                                     rv.insurance_year_number
                                    ,inf.sex_vh
                                    ,0 /*par_values.k_coef*/
                                    ,0 /*par_values.s_coef*/
                                    ,inf.deathrate_id
                                    ,inf.fact_yield_rate)
                  ,10) v_nex
            ,(CASE
               WHEN pv_is_prod = 1 THEN
                (CASE
                  WHEN MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 = 3 THEN
                   (CASE opt.brief
                     WHEN 'PEPR_A' THEN
                      0.9482
                     WHEN 'PEPR_A_PLUS' THEN
                      0.8052
                     WHEN 'PEPR_B' THEN
                      1.0070
                   END)
                  ELSE
                   (CASE opt.brief
                     WHEN 'PEPR_A' THEN
                      0.9452
                     WHEN 'PEPR_A_PLUS' THEN
                      0.8043
                     WHEN 'PEPR_B' THEN
                      1.0492
                   END)
                END)
               ELSE
                (CASE opt.brief
                  WHEN 'PEPR_A' THEN
                   2.9743
                  WHEN 'PEPR_C' THEN
                   3.1614
                  WHEN 'PEPR_B' THEN
                   3.0451
                END)
             END) * inf.fee sa
            ,NULL
            ,NULL p_1
            ,(SELECT l.fee
                FROM ins.t_inform_cover_lump l
               WHERE l.pl_id = res.t_product_line_id
                 AND l.quart_value =
                     MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 * 4) cur_fee
            ,opt.brief
            ,(1 - (CASE
               WHEN pv_is_prod = 1 THEN
                (CASE opt.brief
                  WHEN 'PEPR_A' THEN
                   0.122
                  WHEN 'PEPR_A_PLUS' THEN
                   0.1
                  WHEN 'PEPR_B' THEN
                   0.14
                END)
               ELSE
                (CASE opt.brief
                  WHEN 'PEPR_C' THEN
                   0.09
                  WHEN 'PEPR_A' THEN
                   0.13
                  WHEN 'PEPR_B' THEN
                   0.14
                END)
             END)) *
             (SELECT l.fee
                FROM ins.t_inform_cover_lump l
               WHERE l.pl_id = res.t_product_line_id
                 AND l.quart_value =
                     MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 * 4) net_prem_act
            ,NULL
            ,NULL
            ,NULL
            ,0
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,(CASE
               WHEN pv_is_prod = 1 THEN
                0.0025
               ELSE
                0.04
             END)
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 * 4
            ,NULL
            ,NULL
            ,NULL
            ,NULL
        FROM reserve.r_reserve res
            ,reserve.r_reserve_value rv
            ,ins.p_pol_header ph
            ,ins.p_policy pol
            ,ins.t_prod_line_option opt
            ,(SELECT pc.age             par_values_age
                    ,pc.sex             sex_vh
                    ,pc.deathrate_id
                    ,pc.fact_yield_rate
                    ,pc.f_loading
                    ,pc.pl_id
                    ,pc.fee
                    ,pc.change_year
                    ,pc.quart_value
                FROM ins.t_inform_cover_lump pc) inf
       WHERE res.policy_id = (SELECT p.policy_id
                                FROM ins.p_policy pp
                                    ,ins.p_policy p
                               WHERE pp.policy_id = par_policy_id
                                 AND pp.pol_header_id = p.pol_header_id
                                 AND p.version_num = 1)
         AND rv.reserve_id = res.id
         AND ph.policy_header_id = res.pol_header_id
         AND pol.policy_id = res.policy_id
         AND res.t_product_line_id = opt.product_line_id
         AND opt.product_line_id = inf.pl_id
         AND rv.insurance_year_number =
             MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12
         AND inf.quart_value = MONTHS_BETWEEN(pol.end_date + 1 / 24 / 3600, ph.start_date) / 12 * 4;
    /**/
    IF pv_is_prod = 0
    THEN
      FOR cur IN (SELECT is_change
                        ,quart_value
                        ,pen_for_year
                        ,fee
                        ,change_year
                        ,opt_brief
                        ,lag(opt_brief) over(ORDER BY 1) next_opt_brief
                    FROM (SELECT p.is_change
                                ,p.quart_value
                                ,p.pen_for_year
                                ,p.fee
                                ,p.change_year
                                ,p.opt_brief
                            FROM ins.t_inform_cover_lump pl
                                ,ins.t_inform_cover_lump p
                           WHERE pl.is_change = 1
                             AND pl.change_year = p.change_year
                             AND pl.opt_brief = p.opt_brief
                           ORDER BY p.opt_brief
                                   ,p.quart_value))
      LOOP
        IF cur.opt_brief != cur.next_opt_brief
           OR cur.next_opt_brief IS NULL
        THEN
          pv_pen_year     := 0;
          pv_change_quart := 9999;
        END IF;
        pv_pen_year := pv_pen_year + cur.pen_for_year;
        IF cur.is_change = 1
        THEN
          pv_change_quart := cur.quart_value;
        END IF;
        IF cur.quart_value >= pv_change_quart
        THEN
          UPDATE ins.t_actuar_value v
             SET v.net_prem_act = (1 - (CASE
                                    WHEN pv_is_prod = 1 THEN
                                     (CASE cur.opt_brief
                                       WHEN 'PEPR_A' THEN
                                        0.122
                                       WHEN 'PEPR_A_PLUS' THEN
                                        0.1
                                       WHEN 'PEPR_B' THEN
                                        0.14
                                     END)
                                    ELSE
                                     (CASE cur.opt_brief
                                       WHEN 'PEPR_C' THEN
                                        0.09
                                       WHEN 'PEPR_A' THEN
                                        0.13
                                       WHEN 'PEPR_B' THEN
                                        0.14
                                     END)
                                  END)) * (v.cur_fee - pv_pen_year)
           WHERE v.opt_brief = cur.opt_brief
             AND v.par_quart = cur.quart_value;
        END IF;
      END LOOP;
    END IF;
    /**/
    UPDATE ins.t_actuar_value a
       SET (a.g, a.p) =
           (SELECT CASE
                     WHEN pv_is_prod = 1 THEN
                      ap.v_nex / (1 - ap.f_loading - ap.v_a1xn)
                     ELSE
                      ap.v_nex / ((1 - ap.f_loading) * ap.v_a_xn - ap.v_ia1xn)
                   END
                  ,CASE
                     WHEN pv_is_prod = 1 THEN
                      (ap.v_nex / (1 - ap.f_loading - ap.v_a1xn)) * (1 - ap.f_loading)
                     ELSE
                      (ap.v_nex / ((1 - ap.f_loading) * ap.v_a_xn - ap.v_ia1xn)) * (1 - ap.f_loading)
                   END
              FROM ins.t_actuar_value ap
             WHERE ap.p_cover_id = a.p_cover_id
               AND ap.par_t = 0
               AND ap.par_quart = 0);
    /**/
    UPDATE ins.t_actuar_value a
       SET a.tv_p = (CASE
                      WHEN a.par_quart = 0 THEN
                       0
                      ELSE
                       (CASE
                         WHEN pv_is_prod = 1 THEN
                          a.v_nex + a.g * a.v_a1xn
                         ELSE
                          a.v_nex + a.g * (a.par_t * a.v_a1xn + a.v_ia1xn) - a.p * a.v_a_xn
                       END)
                    END)
          ,a.net_res =
           (a.v_nex + a.g * a.v_a1xn) * a.sa
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.sa
          ,a.tv_p3   =
           (a.v_nex + a.g * a.v_a1xn) * (SELECT (CASE
                                                  WHEN pv_is_prod = 1 THEN
                                                   (CASE
                                                     WHEN a.par_n = 3 THEN
                                                      (CASE lp.opt_brief
                                                        WHEN 'PEPR_A' THEN
                                                         0.9482
                                                        WHEN 'PEPR_A_PLUS' THEN
                                                         0.8052
                                                        WHEN 'PEPR_B' THEN
                                                         1.0070
                                                      END)
                                                     ELSE
                                                      (CASE lp.opt_brief
                                                        WHEN 'PEPR_A' THEN
                                                         0.9452
                                                        WHEN 'PEPR_A_PLUS' THEN
                                                         0.8043
                                                        WHEN 'PEPR_B' THEN
                                                         1.0492
                                                      END)
                                                   END)
                                                  ELSE
                                                   (CASE lp.opt_brief
                                                     WHEN 'PEPR_A' THEN
                                                      2.9743
                                                     WHEN 'PEPR_C' THEN
                                                      3.1614
                                                     WHEN 'PEPR_B' THEN
                                                      3.0451
                                                   END)
                                                END) * lp.fee
                                           FROM ins.t_inform_cover_lump lp
                                          WHERE lp.opt_brief = a.opt_brief
                                            AND lp.change_year = 1
                                            AND lp.quart_value = 1)
          ,a.ad = (CASE
                    WHEN (a.par_t = 0 AND a.par_quart = 0 AND a.opt_brief = 'PEPR_A_PLUS') THEN
                     (a.f_loading - (SELECT va.f_loading
                                       FROM ins.t_actuar_value va
                                      WHERE va.opt_brief = 'PEPR_A'
                                        AND a.par_t = va.par_t
                                        AND a.par_quart = va.par_quart)) *
                     (a.v_nex / (1 - a.f_loading - a.v_a1xn)) /*a.g*/
                    ELSE
                     0
                  END)
          ,a.adres = (CASE
                       WHEN (a.par_t = 0 AND a.par_quart = 0 AND a.opt_brief = 'PEPR_A_PLUS') THEN
                        (a.f_loading - (SELECT va.f_loading
                                          FROM ins.t_actuar_value va
                                         WHERE va.opt_brief = 'PEPR_A'
                                           AND a.par_t = va.par_t
                                           AND a.par_quart = va.par_quart)) *
                        (a.v_nex / (1 - a.f_loading - a.v_a1xn)) /*a.g*/
                       ELSE
                        0
                     END) * a.sa;
    /**/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ACTUAR_VALUE_QUART: ' || SQLERRM);
  END actuar_value_quart;
  /**/
  PROCEDURE get_weigth_quart(par_period NUMBER) IS
    fa_increase        NUMBER := 0;
    sum_prem_no_change NUMBER := 0;
    fee_decrease       NUMBER := 0;
    pcnt_str_increase  NUMBER := 0;
    pv_prod_check      NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO pv_prod_check
      FROM dual
     WHERE EXISTS (SELECT NULL FROM ins.t_inform_cover_lump lp WHERE lp.opt_brief = 'PEPR_A_PLUS');
  
    FOR i IN 1 .. par_period - 1
    LOOP
      fa_increase        := 0;
      fee_decrease       := 0;
      sum_prem_no_change := 0;
      pcnt_str_increase  := 0;
      FOR cur IN (SELECT pc_1.opt_brief
                        ,pc_1.fee       old_fee
                        ,pc_2.fee       cur_fee
                        ,pc_1.sum_prem  old_sum_prem
                        ,pc_2.sum_prem  cur_sum_prem
                        ,pc_2.cover_id
                    FROM ins.t_inform_cover_lump pc_1
                        ,ins.t_inform_cover_lump pc_2
                   WHERE pc_1.change_year = i
                     AND pc_1.pl_id = pc_2.pl_id
                     AND pc_2.quart_value = i + 1)
      LOOP
        IF cur.cur_fee > cur.old_fee
        THEN
          UPDATE ins.t_inform_cover_lump pc
             SET pc.fee_increase = 1
           WHERE pc.opt_brief = cur.opt_brief
             AND pc.quart_value = i + 1;
          fa_increase := fa_increase + 1;
        END IF;
        IF cur.old_sum_prem = cur.cur_sum_prem
        THEN
          sum_prem_no_change := 1;
        END IF;
        IF cur.cur_fee < cur.old_fee
        THEN
          UPDATE ins.t_inform_cover_lump pc
             SET pc.fee_decrease = 1
           WHERE pc.opt_brief = cur.opt_brief
             AND pc.quart_value = i + 1;
          fee_decrease := fee_decrease + 1;
        END IF;
      END LOOP;
    
      UPDATE ins.t_inform_cover_lump pc
         SET w = pc.fee / pc.sum_prem
       WHERE pc.fee_decrease = 1
         AND pc.quart_value = i + 1;
    
      IF fa_increase = 3
      THEN
        UPDATE ins.t_inform_cover_lump pc
           SET w = pc.perc_for_year /* / 100*/
         WHERE pc.quart_value = i + 1;
      ELSE
        IF sum_prem_no_change = 1
        THEN
          UPDATE ins.t_inform_cover_lump pc SET w = pc.fee / pc.sum_prem WHERE pc.quart_value = i + 1;
        ELSE
          IF fa_increase = 1
          THEN
            UPDATE ins.t_inform_cover_lump pca
               SET w =
                   (SELECT (pca.fee - (pca.sum_prem - pc.sum_prem)) / pc.sum_prem
                      FROM ins.t_inform_cover_lump pc
                     WHERE pc.pl_id = pca.pl_id
                       AND pc.quart_value = i)
             WHERE pca.fee_increase = 1
               AND pca.quart_value = i + 1;
            UPDATE ins.t_inform_cover_lump pca
               SET w =
                   (SELECT pca.fee - pc.sum_prem
                      FROM ins.t_inform_cover_lump pc
                     WHERE pc.pl_id = pca.pl_id
                       AND pc.quart_value = i)
             WHERE nvl(pca.fee_increase, 0) != 1
               AND pca.quart_value = i + 1;
          ELSE
            IF fa_increase = 2
            THEN
              SELECT COUNT(*)
                INTO pcnt_str_increase
                FROM ins.t_inform_cover_lump pc
                    ,ins.t_inform_cover_lump pca
               WHERE pc.fee_increase = 1
                 AND pc.quart_value = i + 1
                 AND pc.pl_id = pca.pl_id
                 AND pca.quart_value = i
                 AND abs(pc.fee - pca.fee) > (pc.sum_prem - pca.sum_prem);
              IF pcnt_str_increase = 1
              THEN
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT (pc.fee - (pc.sum_prem - pca.sum_prem)) / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.quart_value = i)
                 WHERE EXISTS (SELECT NULL
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.quart_value = i
                           AND abs((pc.fee - pca.fee)) > (pc.sum_prem - pca.sum_prem))
                   AND pc.fee_increase = 1
                   AND pc.quart_value = i + 1;
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT pc.fee / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.quart_value = i)
                 WHERE EXISTS (SELECT NULL
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.quart_value = i
                           AND abs((pc.fee - pca.fee)) > (pc.sum_prem - pca.sum_prem))
                   AND pc.fee_increase = 1
                   AND pc.quart_value = i + 1;
              ELSE
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT (pca.fee + (SELECT (p1.fee - p2.sum_prem) / 2
                                             FROM ins.t_inform_cover_lump p1
                                                 ,ins.t_inform_cover_lump p2
                                            WHERE p1.pl_id = pca.pl_id
                                              AND p1.fee_decrease = 1
                                              AND p2.pl_id = p1.pl_id
                                              AND p2.fee_decrease = 1
                                              AND p1.quart_value = i
                                              AND p2.quart_value = i + 1)) / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.quart_value = i)
                 WHERE pc.fee_increase = 1
                   AND pc.quart_value = i + 1;
                UPDATE ins.t_inform_cover_lump pc
                   SET w =
                       (SELECT pc.fee / pca.sum_prem
                          FROM ins.t_inform_cover_lump pca
                         WHERE pc.pl_id = pca.pl_id
                           AND pca.quart_value = i)
                 WHERE pc.fee_decrease = 1
                   AND pc.quart_value = i + 1;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    
      IF pv_prod_check = 1
      THEN
      
        UPDATE ins.t_inform_cover_lump pc
           SET (pc.delta_w) =
               (SELECT (CASE
                         WHEN pca.fee = 0 THEN
                          (CASE
                            WHEN pc.fee = 0 THEN
                             0
                            ELSE
                             1
                          END)
                         ELSE
                          (pc.fee - pca.fee) / pca.fee
                       END) * 100
                  FROM ins.t_inform_cover_lump pca
                 WHERE pca.pl_id = pc.pl_id
                   AND pca.quart_value = i)
         WHERE pc.quart_value = i + 1;
      
      ELSE
        UPDATE ins.t_inform_cover_lump pc
           SET (pc.delta_w) =
               (SELECT pc.perc_for_year - pca.perc_for_year
                  FROM ins.t_inform_cover_lump pca
                 WHERE pca.pl_id = pc.pl_id
                   AND pca.quart_value = i)
         WHERE pc.quart_value = i + 1;
      END IF;
    
      UPDATE ins.t_inform_cover_lump pc
         SET pc.priznak = (CASE
                            WHEN pc.delta_w > 0 THEN
                             1
                            ELSE
                             0
                          END)
       WHERE pc.quart_value = i + 1;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_WEIGTH_QUART: ' || SQLERRM);
  END get_weigth_quart;
  /*Обновление tV*/
  PROCEDURE update_tvp(par_prod_check NUMBER) IS
    v_prev_vp NUMBER;
    v_next_vp NUMBER;
  BEGIN
    FOR cur IN (SELECT ta.par_t
                      ,ta.par_quart
                      ,ta.opt_brief
                      ,(ta.par_quart / 4) - (CEIL(ta.par_quart / 4) - 1) k
                      ,ta.tv_p
                      ,lead(ta.tv_p, 4) over(ORDER BY ta.opt_brief) next_tv_p
                      ,par_prod_check check_prod
                      ,ta.v_nex + ta.g * ta.v_a1xn real_tvp
                  FROM ins.t_actuar_value ta
                 ORDER BY ta.opt_brief
                         ,ta.par_t
                         ,ta.par_quart)
    LOOP
      IF cur.k = 1
      THEN
        IF cur.par_quart = 0
           AND cur.check_prod = 0
        THEN
          v_prev_vp := 0;
        ELSE
          v_prev_vp := cur.real_tvp; --cur.tv_p;
        END IF;
        v_next_vp := cur.next_tv_p;
      ELSE
        UPDATE ins.t_actuar_value t
           SET t.tv_p =
               (v_prev_vp * (1 - cur.k) + v_next_vp * cur.k)
         WHERE t.opt_brief = cur.opt_brief
           AND t.par_quart = cur.par_quart;
      END IF;
    END LOOP;
    /**/
    UPDATE ins.t_actuar_value a SET a.tv_p2 = nvl(a.s1, a.sa) * a.tv_p WHERE a.par_quart = 0;
    /**/
    UPDATE ins.t_actuar_value a
       SET a.tv_p2    = nvl(a.s1, a.sa) * a.tv_p
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * nvl(a.s1, a.sa)
     WHERE a.par_quart = 1;
    /**/
  END update_tvp;
  /*Обновление savings*/
  PROCEDURE update_savings
  (
    par_quart_val  NUMBER
   ,par_prod_check NUMBER
  ) IS
  BEGIN
  
    IF par_prod_check = 1
    THEN
      UPDATE ins.t_actuar_value ta
         SET ta.savings =
             (SELECT pkg_change_anniversary.get_savings_quart(pc.opt_brief
                                                             ,pc.start_date
                                                             ,trunc(pc.end_date)
                                                             ,pc.quart_value
                                                             ,3
                                                             ,(SELECT va.net_prem_act
                                                                FROM ins.t_actuar_value va
                                                               WHERE va.opt_brief = ta.opt_brief
                                                                 AND va.par_quart = 0)
                                                             ,pc.cover_id)
                FROM ins.t_inform_cover_lump pc
               WHERE pc.opt_brief = ta.opt_brief
                 AND pc.quart_value = ta.par_quart)
       WHERE ta.par_quart = par_quart_val;
    ELSE
      UPDATE ins.t_actuar_value ta
         SET ta.savings =
             (SELECT pkg_change_anniversary.get_savings_reg_quart(pc.opt_brief
                                                                 ,pc.start_date
                                                                 ,trunc(pc.end_date)
                                                                 ,pc.quart_value -
                                                                  (pc.change_year - 1) * 4
                                                                 ,3
                                                                 ,pc.change_year
                                                                 ,(SELECT va.net_prem_act
                                                                    FROM ins.t_actuar_value va
                                                                   WHERE va.opt_brief = ta.opt_brief
                                                                     AND va.par_quart =
                                                                         (pc.change_year - 1) * 4 + 1 --ta.par_quart
                                                                  )
                                                                 ,(SELECT va.net_prem_act
                                                                    FROM ins.t_actuar_value va
                                                                   WHERE va.opt_brief = ta.opt_brief
                                                                     AND va.par_quart =
                                                                         ta.par_quart - 1)
                                                                 ,(SELECT nvl(va.savings, 0)
                                                                    FROM ins.t_actuar_value va
                                                                   WHERE va.opt_brief = ta.opt_brief
                                                                     AND va.par_quart =
                                                                         (pc.change_year - 1) * 4 --ta.par_quart - 1
                                                                  )
                                                                 ,pc.cover_id)
                FROM ins.t_inform_cover_lump pc
               WHERE pc.opt_brief = ta.opt_brief
                 AND pc.quart_value = ta.par_quart)
       WHERE ta.par_quart = par_quart_val;
    END IF;
  
  END update_savings;
  /*Обновление процент для раздачи; процент для забора; резерв забора*/
  PROCEDURE update_distr_take
  (
    par_quart_val  NUMBER
   ,par_prod_check NUMBER
  ) IS
  BEGIN
  
    IF par_prod_check = 1
    THEN
      UPDATE ins.t_inform_cover_lump pc
         SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
             (SELECT (CASE
                       WHEN pc.priznak = 0 THEN
                        abs((SELECT (v.tv_p2 + (SELECT vv.adres
                                                  FROM ins.t_actuar_value vv
                                                 WHERE vv.opt_brief = v.opt_brief
                                                   AND vv.par_quart = v.par_quart - 1))
                               FROM ins.t_actuar_value v
                              WHERE v.opt_brief = pc.opt_brief
                                AND v.par_quart = pc.quart_value - 1) * (pc.delta_w / 100))
                       ELSE
                        0
                     END)
                    ,(CASE
                       WHEN pc.priznak = 1 THEN
                        pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                           FROM ins.t_inform_cover_lump pca
                                          WHERE pca.quart_value = pc.quart_value
                                            AND pca.priznak = 0)
                       ELSE
                        0
                     END)
                    ,(CASE
                       WHEN (SELECT SUM(pca.priznak)
                               FROM ins.t_inform_cover_lump pca
                              WHERE pca.quart_value = pc.quart_value) = 0 THEN
                        0
                       ELSE
                        (1 - pc.priznak) * (pc.delta_w / 100)
                     END)
                FROM ins.t_inform_cover_lump c
               WHERE c.opt_brief = pc.opt_brief
                 AND c.quart_value = pc.quart_value)
       WHERE pc.quart_value = par_quart_val;
    ELSE
      UPDATE ins.t_inform_cover_lump pcl
         SET (pcl.w_for_distrib, pcl.w_for_take) =
             (SELECT CASE
                       WHEN (SELECT SUM(pca.priznak) FROM ins.t_inform_cover_lump pca) = 0 THEN
                        0
                       ELSE
                        ((pc.delta_w * pc.priznak) /
                        (SELECT SUM(pca.delta_w * pca.priznak) FROM ins.t_inform_cover_lump pca))
                     END
                    ,CASE
                       WHEN (SELECT SUM(pca.priznak) FROM ins.t_inform_cover_lump pca) = 0 THEN
                        0
                       ELSE
                        ((1 - pc.priznak) * pc.delta_w /
                        (SELECT SUM((1 - pca.priznak) * pca.delta_w) FROM ins.t_inform_cover_lump pca))
                     END
                FROM ins.t_inform_cover_lump pc
               WHERE pc.opt_brief = pcl.opt_brief
                 AND pc.quart_value = pcl.quart_value)
       WHERE pcl.quart_value = par_quart_val;
    END IF;
  
  END update_distr_take;
  /**/
  PROCEDURE update_reserve_distr
  (
    par_quart_val  NUMBER
   ,par_prod_check NUMBER
  ) IS
    v_change_c NUMBER := 0;
    v_change_b NUMBER := 0;
    v_change_a NUMBER := 0;
  BEGIN
    IF par_prod_check = 1
    THEN
      UPDATE ins.t_inform_cover_lump pc
         SET pc.reserve_distrib = pc.w_for_distrib *
                                  (SELECT SUM(p.reserve_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.quart_value = pc.quart_value)
            ,pc.w_for_take = (CASE
                               WHEN (SELECT SUM(p.w_for_take)
                                       FROM ins.t_inform_cover_lump p
                                      WHERE p.quart_value = pc.quart_value) = 0 THEN
                                0
                               ELSE
                                pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                   FROM ins.t_inform_cover_lump p
                                                  WHERE p.quart_value = pc.quart_value)
                             END)
       WHERE pc.quart_value = par_quart_val;
    ELSE
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_c
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_C'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_c := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_a
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_A'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_a := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_b
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_B'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_b := 0;
      END;
    
      IF v_change_b = 0
         AND v_change_a = 0
         AND v_change_c = 0
      THEN
        UPDATE ins.t_inform_cover_lump lp
           SET lp.reserve_distrib =
               (SELECT - ((1 - a.bpriznak1) * (a.f2 / 100) *
                         (SELECT ta.tv_p2
                            FROM ins.t_actuar_value ta
                           WHERE ta.opt_brief = a.b
                             AND ta.par_quart = a.quart_value - 1) +
                         (1 - a.apriznak1) * (a.f3 / 100) *
                         (SELECT ta.tv_p2
                            FROM ins.t_actuar_value ta
                           WHERE ta.opt_brief = a.a
                             AND ta.par_quart = a.quart_value - 1) +
                         (1 - a.cpriznak1) * (a.f4 / 100) *
                         (SELECT ta.tv_p2
                            FROM ins.t_actuar_value ta
                           WHERE ta.opt_brief = a.c
                             AND ta.par_quart = a.quart_value - 1))
                  FROM (SELECT pcc.opt_brief   c
                              ,pcc.delta_w     f4
                              ,pcc.priznak     cpriznak1
                              ,pca.opt_brief   a
                              ,pca.delta_w     f3
                              ,pca.priznak     apriznak1
                              ,pcb.opt_brief   b
                              ,pcb.delta_w     f2
                              ,pcb.priznak     bpriznak1
                              ,pcc.quart_value
                          FROM ins.t_inform_cover_lump pcc
                              ,ins.t_inform_cover_lump pca
                              ,ins.t_inform_cover_lump pcb
                         WHERE pcc.opt_brief = 'PEPR_C'
                           AND pca.opt_brief = 'PEPR_A'
                           AND pcb.opt_brief = 'PEPR_B'
                           AND pcc.quart_value = par_quart_val
                           AND pca.quart_value = pcc.quart_value
                           AND pcb.quart_value = pca.quart_value) a)
         WHERE lp.quart_value = par_quart_val;
      ELSE
        UPDATE ins.t_inform_cover_lump lp
           SET lp.reserve_take = CASE
                                   WHEN lp.priznak = 1 THEN
                                    0
                                   ELSE
                                    abs((SELECT va.tv_p
                                           FROM ins.t_actuar_value va
                                          WHERE va.par_quart = (CASE lp.change_year
                                                  WHEN 1 THEN
                                                   0
                                                  WHEN 2 THEN
                                                   5 - 1
                                                  WHEN 3 THEN
                                                   9 - 1
                                                  WHEN 4 THEN
                                                   13 - 1
                                                  WHEN 5 THEN
                                                   17 - 1
                                                  ELSE
                                                   lp.quart_value - 2
                                                END)
                                            AND va.opt_brief = lp.opt_brief) *
                                        (SELECT nvl(va.s1, va.sa)
                                           FROM ins.t_actuar_value va
                                          WHERE va.par_quart = lp.quart_value - 1
                                            AND va.opt_brief = lp.opt_brief) * (lp.delta_w / 100))
                                 END
         WHERE lp.quart_value = par_quart_val;
        UPDATE ins.t_inform_cover_lump lp
           SET lp.reserve_distrib = CASE
                                      WHEN lp.priznak = 1 THEN
                                       lp.w_for_distrib
                                      ELSE
                                       lp.w_for_take
                                    END * (SELECT SUM(l.reserve_take)
                                             FROM ins.t_inform_cover_lump l
                                            WHERE l.quart_value = lp.quart_value)
         WHERE lp.quart_value = par_quart_val;
      END IF;
    END IF;
  
  END update_reserve_distr;
  /*Обновление ad, adres*/
  PROCEDURE update_adres(par_quart_val NUMBER) IS
  BEGIN
    UPDATE ins.t_actuar_value a
       SET a.ad = power((1 + a.fact_yield_rate), 1 / 4) *
                  (SELECT va.ad
                     FROM ins.t_actuar_value va
                    WHERE va.opt_brief = a.opt_brief
                      AND va.par_quart = a.par_quart - 1)
     WHERE a.par_quart = par_quart_val
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE ins.t_actuar_value a
       SET a.adres = a.ad * nvl(a.s1, a.sa)
     WHERE a.par_quart = par_quart_val
       AND a.opt_brief = 'PEPR_A_PLUS';
    /**/
    UPDATE ins.t_actuar_value a
       SET a.ad    = 0
          ,a.adres = 0
     WHERE a.par_quart = par_quart_val
       AND a.opt_brief != 'PEPR_A_PLUS';
    /**/
  END update_adres;
  /*Обновление изменение резерва*/
  PROCEDURE update_delta_res
  (
    par_quart_val  NUMBER
   ,par_prod_check NUMBER
  ) IS
    v_change_c NUMBER := 0;
    v_change_b NUMBER := 0;
    v_change_a NUMBER := 0;
  BEGIN
    IF par_prod_check = 1
    THEN
      UPDATE ins.t_inform_cover_lump pc
         SET pc.delta_res = /*(CASE
                                                                                                                                                                                                                                                                                                                                       WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                                                                                                                                                                                                                                                                                                                                        (SELECT va.tv_p /
                                                                                                                                                                                                                                                                                                                                                (va.tv_p + (SELECT ta.ad
                                                                                                                                                                                                                                                                                                                                                              FROM ins.t_actuar_value ta
                                                                                                                                                                                                                                                                                                                                                             WHERE ta.par_quart = va.par_quart - 1
                                                                                                                                                                                                                                                                                                                                                               AND ta.opt_brief = va.opt_brief))
                                                                                                                                                                                                                                                                                                                                           FROM ins.t_actuar_value va
                                                                                                                                                                                                                                                                                                                                          WHERE va.opt_brief = pc.opt_brief
                                                                                                                                                                                                                                                                                                                                            AND va.par_quart = pc.quart_value - 1)
                                                                                                                                                                                                                                                                                                                                       ELSE
                                                                                                                                                                                                                                                                                                                                        1
                                                                                                                                                                                                                                                                                                                                     END) **/ (CASE
                                                                                                                                                                                                                                                                                                                                                WHEN pc.priznak = 1 THEN
                                                                                                                                                                                                                                                                                                                                                 pc.reserve_distrib
                                                                                                                                                                                                                                                                                                                                                ELSE
                                                                                                                                                                                                                                                                                                                                                 -pc.reserve_take
                                                                                                                                                                                                                                                                                                                                              END) /** (SELECT va.tv_p
                                                                                                                                                                              FROM ins.t_actuar_value va
                                                                                                                                                                             WHERE va.opt_brief = pc.opt_brief
                                                                                                                                                                               AND va.par_quart = pc.quart_value - 1)*/
       WHERE pc.quart_value = par_quart_val;
    ELSE
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_c
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_C'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_c := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_a
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_A'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_a := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_b
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_B'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_b := 0;
      END;
    
      IF v_change_b = 0
         AND v_change_a = 0
         AND v_change_c = 0
      THEN
        UPDATE ins.t_inform_cover_lump pcl
           SET pcl.delta_res =
               (pcl.w_for_distrib * pcl.reserve_distrib) - (pcl.w_for_take * pcl.reserve_distrib)
         WHERE pcl.quart_value = par_quart_val;
      ELSE
        UPDATE ins.t_inform_cover_lump pcl
           SET pcl.delta_res = (CASE
                                 WHEN pcl.priznak = 1 THEN
                                  pcl.reserve_distrib
                                 ELSE
                                  -pcl.reserve_take
                               END)
         WHERE pcl.quart_value = par_quart_val;
      END IF;
    
    END IF;
  END update_delta_res;
  /*Обновление вклада для забора, для раздачи, изменения вклада*/
  PROCEDURE update_deposit(par_quart_val NUMBER) IS
  BEGIN
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                abs((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_quart = par_quart_val - 1) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.quart_value = par_quart_val;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.quart_value = pc.quart_value)
     WHERE pc.quart_value = par_quart_val;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.quart_value = par_quart_val;
  END update_deposit;
  /*Обновление EIB theor*/
  PROCEDURE update_eib_theor(par_quart_val NUMBER) IS
    /*v_savings NUMBER;
    v_adres NUMBER;
    v_tvexp_sa NUMBER;
    v_tv_p2 NUMBER;
    v_eib_theor NUMBER;*/
  BEGIN
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN (SELECT COUNT(1)
                                    FROM dual
                                   WHERE EXISTS (SELECT NULL
                                            FROM ins.t_inform_cover_lump lp
                                           WHERE lp.header_id = ta.pol_header_id
                                             AND lp.opt_brief = 'PEPR_A_PLUS')) = 1 THEN
                             greatest(ta.savings - (SELECT t.adres
                                                      FROM ins.t_actuar_value t
                                                     WHERE t.opt_brief = ta.opt_brief
                                                       AND t.par_quart = ta.par_quart - 1) -
                                      (ta.tvexp_sa + greatest(ta.tv_p2, 0))
                                     ,0)
                            ELSE
                             ta.savings - ta.tv_p2
                          END)
     WHERE ta.par_quart = par_quart_val;
  
    /*SELECT a.savings
    INTO v_savings
    FROM ins.t_actuar_value a
    WHERE a.par_quart = PAR_QUART_VAL
      AND a.opt_brief = 'PEPR_B';
    SELECT a.adres
    INTO v_adres
    FROM ins.t_actuar_value a
    WHERE a.par_quart = PAR_QUART_VAL - 1
      AND a.opt_brief = 'PEPR_B';
    SELECT a.tvexp_sa
    INTO v_tvexp_sa
    FROM ins.t_actuar_value a
    WHERE a.par_quart = PAR_QUART_VAL
      AND a.opt_brief = 'PEPR_B';
    SELECT a.tv_p2
    INTO v_tv_p2
    FROM ins.t_actuar_value a
    WHERE a.par_quart = PAR_QUART_VAL
      AND a.opt_brief = 'PEPR_B';
    SELECT a.eib_theor
    INTO v_eib_theor
    FROM ins.t_actuar_value a
    WHERE a.par_quart = PAR_QUART_VAL
      AND a.opt_brief = 'PEPR_B';*/
  
  END update_eib_theor;
  /*Обновление доп дохода*/
  PROCEDURE update_did
  (
    par_quart_val  NUMBER
   ,par_prod_check NUMBER
  ) IS
    v_change_c NUMBER := 0;
    v_change_b NUMBER := 0;
    v_change_a NUMBER := 0;
  BEGIN
    IF par_prod_check = 1
    THEN
      UPDATE ins.t_inform_cover_lump pc
         SET pc.did_take = (CASE
                             WHEN pc.priznak = 0 THEN
                              abs((SELECT ta.eib_theor
                                     FROM ins.t_actuar_value ta
                                    WHERE ta.opt_brief = pc.opt_brief
                                      AND ta.par_quart = par_quart_val - 1) * (pc.delta_w / 100))
                             ELSE
                              0
                           END)
       WHERE pc.quart_value = par_quart_val;
      UPDATE ins.t_inform_cover_lump pc
         SET pc.did_distrib = pc.w_for_distrib *
                              (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                                 FROM ins.t_inform_cover_lump p
                                WHERE p.quart_value = pc.quart_value)
       WHERE pc.quart_value = par_quart_val;
    
      UPDATE ins.t_inform_cover_lump pc
         SET pc.delta_eib = (CASE
                              WHEN pc.priznak = 1 THEN
                               pc.did_distrib
                              ELSE
                               -pc.did_take
                            END)
       WHERE pc.quart_value = par_quart_val;
    ELSE
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_c
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_C'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_c := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_a
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_A'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_a := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_b
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_B'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_b := 0;
      END;
      IF v_change_b = 0
         AND v_change_a = 0
         AND v_change_c = 0
      THEN
        UPDATE ins.t_inform_cover_lump pcl
           SET pcl.did_distrib = greatest((SELECT - ((1 - a.bpriznak1) * (a.f2 / 100) *
                                                    (SELECT ta.eib_theor
                                                       FROM ins.t_actuar_value ta
                                                      WHERE ta.opt_brief = a.b
                                                        AND ta.par_quart = a.quart_value - 1) +
                                                    (1 - a.apriznak1) * (a.f3 / 100) *
                                                    (SELECT ta.eib_theor
                                                       FROM ins.t_actuar_value ta
                                                      WHERE ta.opt_brief = a.a
                                                        AND ta.par_quart = a.quart_value - 1) +
                                                    (1 - a.cpriznak1) * (a.f4 / 100) *
                                                    (SELECT ta.eib_theor
                                                       FROM ins.t_actuar_value ta
                                                      WHERE ta.opt_brief = a.c
                                                        AND ta.par_quart = a.quart_value - 1))
                                             FROM (SELECT pcc.opt_brief   c
                                                         ,pcc.delta_w     f4
                                                         ,pcc.priznak     cpriznak1
                                                         ,pca.opt_brief   a
                                                         ,pca.delta_w     f3
                                                         ,pca.priznak     apriznak1
                                                         ,pcb.opt_brief   b
                                                         ,pcb.delta_w     f2
                                                         ,pcb.priznak     bpriznak1
                                                         ,pcc.quart_value
                                                     FROM ins.t_inform_cover_lump pcc
                                                         ,ins.t_inform_cover_lump pca
                                                         ,ins.t_inform_cover_lump pcb
                                                    WHERE pcc.opt_brief = 'PEPR_C'
                                                      AND pca.opt_brief = 'PEPR_A'
                                                      AND pcb.opt_brief = 'PEPR_B'
                                                      AND pcc.quart_value = par_quart_val
                                                      AND pca.quart_value = pcc.quart_value
                                                      AND pcb.quart_value = pca.quart_value) a) *
                                          pcl.w_for_distrib
                                         ,0) -
                                 (SELECT SUM(p.pen_for_year)
                                    FROM ins.t_inform_cover_lump p
                                   WHERE p.quart_value = pcl.quart_value) * pcl.w_for_distrib
         WHERE pcl.quart_value = par_quart_val;
      
        UPDATE ins.t_inform_cover_lump pcl
           SET pcl.did_take = pcl.w_for_take *
                              (SELECT - ((1 - a.bpriznak1) * (a.f2 / 100) *
                                        (SELECT ta.eib_theor
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.opt_brief = a.b
                                            AND ta.par_quart = a.quart_value - 1) +
                                        (1 - a.apriznak1) * (a.f3 / 100) *
                                        (SELECT ta.eib_theor
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.opt_brief = a.a
                                            AND ta.par_quart = a.quart_value - 1) +
                                        (1 - a.cpriznak1) * (a.f4 / 100) *
                                        (SELECT ta.eib_theor
                                           FROM ins.t_actuar_value ta
                                          WHERE ta.opt_brief = a.c
                                            AND ta.par_quart = a.quart_value - 1))
                                 FROM (SELECT pcc.opt_brief   c
                                             ,pcc.delta_w     f4
                                             ,pcc.priznak     cpriznak1
                                             ,pca.opt_brief   a
                                             ,pca.delta_w     f3
                                             ,pca.priznak     apriznak1
                                             ,pcb.opt_brief   b
                                             ,pcb.delta_w     f2
                                             ,pcb.priznak     bpriznak1
                                             ,pcc.quart_value
                                         FROM ins.t_inform_cover_lump pcc
                                             ,ins.t_inform_cover_lump pca
                                             ,ins.t_inform_cover_lump pcb
                                        WHERE pcc.opt_brief = 'PEPR_C'
                                          AND pca.opt_brief = 'PEPR_A'
                                          AND pcb.opt_brief = 'PEPR_B'
                                          AND pcc.quart_value = par_quart_val
                                          AND pca.quart_value = pcc.quart_value
                                          AND pcb.quart_value = pca.quart_value) a)
         WHERE pcl.quart_value = par_quart_val;
      ELSE
        UPDATE ins.t_inform_cover_lump pcl
           SET pcl.did_take = CASE
                                WHEN pcl.priznak = 0 THEN
                                 abs(greatest((SELECT nvl(va.savings, 0)
                                                 FROM ins.t_actuar_value va
                                                WHERE va.par_quart = (CASE pcl.change_year
                                                        WHEN 1 THEN
                                                         0
                                                        WHEN 2 THEN
                                                         5 - 1
                                                        WHEN 3 THEN
                                                         9 - 1
                                                        WHEN 4 THEN
                                                         13 - 1
                                                        WHEN 5 THEN
                                                         17 - 1
                                                        ELSE
                                                         pcl.quart_value - 2
                                                      END)
                                                  AND va.opt_brief = pcl.opt_brief) -
                                              (SELECT nvl(va.tv_p, 0)
                                                 FROM ins.t_actuar_value va
                                                WHERE va.par_quart = (CASE pcl.change_year
                                                        WHEN 1 THEN
                                                         0
                                                        WHEN 2 THEN
                                                         5 - 1
                                                        WHEN 3 THEN
                                                         9 - 1
                                                        WHEN 4 THEN
                                                         13 - 1
                                                        WHEN 5 THEN
                                                         17 - 1
                                                        ELSE
                                                         pcl.quart_value - 2
                                                      END)
                                                  AND va.opt_brief = pcl.opt_brief) *
                                              (SELECT nvl(va.s1, va.sa)
                                                 FROM ins.t_actuar_value va
                                                WHERE va.par_quart = pcl.quart_value - 1
                                                  AND va.opt_brief = pcl.opt_brief)
                                             ,0) * (pcl.delta_w / 100))
                                ELSE
                                 0
                              END
         WHERE pcl.quart_value = par_quart_val;
        UPDATE ins.t_inform_cover_lump pcl
           SET pcl.did_distrib = pcl.w_for_distrib *
                                 (SELECT SUM(l.did_take) - SUM(l.pen_for_year)
                                    FROM ins.t_inform_cover_lump l
                                   WHERE l.quart_value = pcl.quart_value)
         WHERE pcl.quart_value = par_quart_val;
      END IF;
      /**/
      UPDATE ins.t_inform_cover_lump pcl
         SET pcl.delta_eib = pcl.did_distrib - abs(pcl.did_take)
       WHERE pcl.quart_value = par_quart_val;
    
      UPDATE ins.t_inform_cover_lump p
         SET p.bt =
             (SELECT ta.v_ia1xn - (1 - ta.f_loading) * ta.v_a_xn
                FROM ins.t_actuar_value ta
               WHERE ta.opt_brief = p.opt_brief
                 AND ta.par_quart = par_quart_val - 1)
       WHERE p.quart_value = par_quart_val;
    
    END IF;
  
  END update_did;
  /*Расчет и обвноление новой СС*/
  PROCEDURE update_ins_amount
  (
    par_quart_val  NUMBER
   ,par_prod_check NUMBER
  ) IS
    v_change_c      NUMBER := 0;
    v_change_b      NUMBER := 0;
    v_change_a      NUMBER := 0;
    v_new_delta_res NUMBER := 0;
  BEGIN
  
    IF par_prod_check = 1
    THEN
      UPDATE ins.t_actuar_value ta
         SET ta.s1 = (CASE
                       WHEN ta.cur_fee = 0 THEN
                        0
                       ELSE
                        (CASE
                          WHEN (SELECT t.cur_fee
                                  FROM ins.t_actuar_value t
                                 WHERE t.par_quart = ta.par_quart - 1
                                   AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                           (SELECT nvl(t.s1, t.sa)
                              FROM ins.t_actuar_value t
                             WHERE t.par_quart = ta.par_quart - 1
                               AND t.opt_brief = ta.opt_brief)
                          ELSE
                           ((SELECT t.tv_p2
                               FROM ins.t_actuar_value t
                              WHERE t.par_quart = ta.par_quart - 1
                                AND t.opt_brief = ta.opt_brief) +
                           (SELECT pc.delta_res + pc.delta_eib
                               FROM ins.t_inform_cover_lump pc
                              WHERE pc.opt_brief = ta.opt_brief
                                AND pc.quart_value = ta.par_quart) -
                           ta.cur_fee * (SELECT t.v_a1xn
                                            FROM ins.t_actuar_value t
                                           WHERE t.par_quart = ta.par_quart - 1
                                             AND t.opt_brief = ta.opt_brief)) /
                           (SELECT t.v_nex
                              FROM ins.t_actuar_value t
                             WHERE t.par_quart = ta.par_quart - 1
                               AND t.opt_brief = ta.opt_brief)
                        END)
                     END)
       WHERE ta.par_quart = par_quart_val;
    ELSE
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_c
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_C'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_c := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_a
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_A'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_a := 0;
      END;
      BEGIN
        SELECT lp.perc_for_year - lpa.perc_for_year
          INTO v_change_b
          FROM ins.t_inform_cover_lump lp
              ,ins.t_inform_cover_lump lpa
         WHERE lp.opt_brief = 'PEPR_B'
           AND lp.opt_brief = lpa.opt_brief
           AND lp.quart_value = par_quart_val
           AND lpa.quart_value = par_quart_val - 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_change_b := 0;
      END;
      IF v_change_b = 0
         AND v_change_a = 0
         AND v_change_c = 0
      THEN
        UPDATE ins.t_actuar_value ta
           SET ta.s1 = (CASE
                         WHEN (SELECT t.cur_fee
                                 FROM ins.t_actuar_value t
                                WHERE t.par_quart = ta.par_quart - 1
                                  AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                          (SELECT nvl(t.s1, t.sa)
                             FROM ins.t_actuar_value t
                            WHERE t.par_quart = ta.par_quart - 1
                              AND t.opt_brief = ta.opt_brief)
                         ELSE
                          (SELECT nvl(t.s1, t.sa)
                             FROM ins.t_actuar_value t
                            WHERE t.par_quart = ta.par_quart - 1
                              AND t.opt_brief = ta.opt_brief) +
                          ((SELECT t.cur_fee
                              FROM ins.t_actuar_value t
                             WHERE t.par_quart = ta.par_quart - 1
                               AND t.opt_brief = ta.opt_brief) - ta.cur_fee) *
                          (SELECT pc.bt
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.quart_value = ta.par_quart) /
                          (SELECT t.v_nex
                             FROM ins.t_actuar_value t
                            WHERE ta.opt_brief = t.opt_brief
                              AND t.par_quart = ta.par_quart - 1) +
                          (SELECT pc.delta_eib
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.quart_value = ta.par_quart) /
                          (SELECT t.v_nex
                             FROM ins.t_actuar_value t
                            WHERE ta.opt_brief = t.opt_brief
                              AND t.par_quart = ta.par_quart - 1) +
                          (SELECT pc.delta_res
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.quart_value = ta.par_quart) /
                          (SELECT t.v_nex
                             FROM ins.t_actuar_value t
                            WHERE ta.opt_brief = t.opt_brief
                              AND t.par_quart = ta.par_quart - 1)
                       END)
         WHERE ta.par_quart = par_quart_val;
      ELSE
        UPDATE ins.t_actuar_value ta
           SET ta.s1 = (CASE
                         WHEN (SELECT t.cur_fee
                                 FROM ins.t_actuar_value t
                                WHERE t.par_quart = ta.par_quart - 1
                                  AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                          (SELECT nvl(t.s1, t.sa)
                             FROM ins.t_actuar_value t
                            WHERE t.par_quart = ta.par_quart - 1
                              AND t.opt_brief = ta.opt_brief)
                         ELSE
                          (SELECT nvl(t.s1, t.sa)
                             FROM ins.t_actuar_value t
                            WHERE t.par_quart = ta.par_quart - 1
                              AND t.opt_brief = ta.opt_brief) +
                          ((SELECT t.cur_fee
                              FROM ins.t_actuar_value t
                             WHERE t.par_quart = ta.par_quart - 1
                               AND t.opt_brief = ta.opt_brief) - ta.cur_fee) *
                          (SELECT pc.bt
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.quart_value = ta.par_quart) /
                          (SELECT t.v_nex
                             FROM ins.t_actuar_value t
                            WHERE ta.opt_brief = t.opt_brief
                              AND t.par_quart = ta.par_quart - 1) +
                          (SELECT pc.delta_eib
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.quart_value = ta.par_quart) /
                          (SELECT t.v_nex
                             FROM ins.t_actuar_value t
                            WHERE ta.opt_brief = t.opt_brief
                              AND t.par_quart = ta.par_quart - 1) +
                          (SELECT pc.delta_res
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.quart_value = ta.par_quart) /
                          (SELECT t.v_nex
                             FROM ins.t_actuar_value t
                            WHERE ta.opt_brief = t.opt_brief
                              AND t.par_quart = ta.par_quart - 1)
                       END)
         WHERE ta.par_quart = par_quart_val;
      END IF;
    
    END IF;
  
  END update_ins_amount;
  /**/
  PROCEDURE another_update_quart(par_period_id NUMBER) IS
    v_prod_check NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_prod_check
      FROM dual
     WHERE EXISTS (SELECT NULL FROM ins.t_inform_cover_lump lp WHERE lp.opt_brief = 'PEPR_A_PLUS');
  
    /*обновляем tV поквартально*/
    update_tvp(v_prod_check);
  
    FOR i IN 1 .. par_period_id
    LOOP
      /*первый квартал SAVINGS*/
      update_savings(i, v_prod_check);
      /*первый квартал резерв забора*/
      update_distr_take(i + 1, v_prod_check);
      /*первый квартал резерв раздачи*/
      update_reserve_distr(i + 1, v_prod_check);
      /*Обновление ad, adres для PEPR_A_PLUS*/
      update_adres(i);
      /*Обновление изменение резерва*/
      update_delta_res(i + 1, v_prod_check);
      /*Обновление вклада для забора, для раздачи, изменения вклада*/
      update_deposit(i + 1);
      /**/
      UPDATE ins.t_actuar_value a
         SET a.tv_p2    = nvl(a.s1, a.sa) * a.tv_p
            ,a.tvexp    = a.az * a.g * a.v_a_xn
            ,a.tvexp_sa =
             (a.az * a.g * a.v_a_xn) * nvl(a.s1, a.sa)
       WHERE a.par_quart = i + 1;
      /*первый квартал доп доход*/
      update_eib_theor(i);
      /*Обновление ДИД для забора, для раздачи, изменения*/
      update_did(i + 1, v_prod_check);
      /*первый квартал новая Страховая сумма*/
      update_ins_amount(i + 1, v_prod_check);
      UPDATE ins.t_actuar_value a
         SET a.tv_p2    = nvl(a.s1, a.sa) * a.tv_p
            ,a.tvexp    = a.az * a.g * a.v_a_xn
            ,a.tvexp_sa =
             (a.az * a.g * a.v_a_xn) * nvl(a.s1, a.sa)
       WHERE a.par_quart = i + 1;
    END LOOP;
  
    /*
    
    \*резерв 2 год*\
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN (SELECT va.cur_fee
                               FROM ins.t_actuar_value va
                              WHERE va.opt_brief = v.opt_brief
                                AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                        v.net_res
                       ELSE
                        (v.s1 * v.v_nex + v.cur_fee * v.v_a1xn)
                     END)
     WHERE v.par_t = 2;
    \**\
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      ABS((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 3;
    \**\
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 2
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.adres = (CASE
                       WHEN a.par_n = 3 THEN
                        (CASE
                          WHEN (SELECT (CASE
                                         WHEN pc.priznak = 1 THEN
                                          pc.reserve_distrib
                                         ELSE
                                          -pc.reserve_take
                                       END)
                                  FROM ins.t_inform_cover_lump pc
                                 WHERE pc.opt_brief = a.opt_brief
                                   AND pc.change_year = a.par_t + 1) < 0 THEN
                           0
                          ELSE
                           a.ad * a.s1 + (SELECT (CASE
                                                   WHEN pc.priznak = 1 THEN
                                                    pc.reserve_distrib
                                                   ELSE
                                                    -pc.reserve_take
                                                 END)
                                            FROM ins.t_inform_cover_lump pc
                                           WHERE pc.opt_brief = a.opt_brief
                                             AND pc.change_year = a.par_t + 1) *
                           (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                                 FROM ins.t_actuar_value ta
                                                WHERE ta.par_t = a.par_t - 1
                                                  AND ta.opt_brief = a.opt_brief))
                        END)
                       ELSE
                        a.ad * a.s1
                     END)
     WHERE a.par_t = 2
       AND a.opt_brief = 'PEPR_A_PLUS';
    \**\
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 3;
    \*вклад 2 год*\
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                ABS((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 2) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                ABS((SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                      FROM ins.t_inform_cover_lump p
                                     WHERE p.change_year = pc.change_year))
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 3;
    \*доп доход 2 год*\
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.tv_p2    = a.s1 * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.s1
     WHERE a.par_t = 2;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + GREATEST(ta.tv_p2, 0))
     WHERE ta.par_t = 2;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 2;
    
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            ABS((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 2) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 3;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 3;
    \*СС 2 год*\
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         (SELECT t.s1
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                        ELSE
                         ((SELECT t.tv_p3
                             FROM ins.t_actuar_value t
                            WHERE t.par_t = ta.par_t - 1
                              AND t.opt_brief = ta.opt_brief) +
                         (SELECT pc.delta_res + pc.delta_eib
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.change_year = ta.par_t) -
                         ta.cur_fee * (SELECT t.v_a1xn
                                          FROM ins.t_actuar_value t
                                         WHERE t.par_t = ta.par_t - 1
                                           AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 3;
    \****************************************************************\
    \*третий год SAVINGS*\
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act = ta.cur_fee * (1 - (CASE
                               WHEN ta.par_n = 3 THEN
                                const_act_loading_3
                               ELSE
                                const_act_loading_5
                             END))
     WHERE ta.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT PKG_CHANGE_ANNIVERSARY.GET_SAVINGS_LUMP(pc.opt_brief
                                                          ,pc.start_date
                                                          ,TRUNC(pc.end_date)
                                                          ,ta.par_t
                                                          ,(SELECT tat.net_prem_act
                                                             FROM ins.t_actuar_value tat
                                                            WHERE tat.par_t = 1
                                                              AND tat.opt_brief = pc.opt_brief)
                                                          )
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 3;
    \*резерв 3 год*\
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN (SELECT va.cur_fee
                               FROM ins.t_actuar_value va
                              WHERE va.opt_brief = v.opt_brief
                                AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                        v.net_res
                       ELSE
                        (v.s1 * v.v_nex + v.cur_fee * v.v_a1xn)
                     END)
     WHERE v.par_t = 3;
    \**\
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      ABS((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 4;
    \**\
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 3
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.adres = (CASE
                       WHEN a.par_n = 3 THEN
                        (CASE
                          WHEN (SELECT (CASE
                                         WHEN pc.priznak = 1 THEN
                                          pc.reserve_distrib
                                         ELSE
                                          -pc.reserve_take
                                       END)
                                  FROM ins.t_inform_cover_lump pc
                                 WHERE pc.opt_brief = a.opt_brief
                                   AND pc.change_year = a.par_t + 1) < 0 THEN
                           0
                          ELSE
                           a.ad * a.s1 + (SELECT (CASE
                                                   WHEN pc.priznak = 1 THEN
                                                    pc.reserve_distrib
                                                   ELSE
                                                    -pc.reserve_take
                                                 END)
                                            FROM ins.t_inform_cover_lump pc
                                           WHERE pc.opt_brief = a.opt_brief
                                             AND pc.change_year = a.par_t + 1) *
                           (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                                 FROM ins.t_actuar_value ta
                                                WHERE ta.par_t = a.par_t - 1
                                                  AND ta.opt_brief = a.opt_brief))
                        END)
                       ELSE
                        a.ad * a.s1
                     END)
     WHERE a.par_t = 3
       AND a.opt_brief = 'PEPR_A_PLUS';
    \**\
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 4;
    \*вклад 3 год*\
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                ABS((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 3) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                ABS((SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                      FROM ins.t_inform_cover_lump p
                                     WHERE p.change_year = pc.change_year))
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 4;
    \*доп доход 3 год*\
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.tv_p2    = a.s1 * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.s1
     WHERE a.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + GREATEST(ta.tv_p2, 0))
     WHERE ta.par_t = 3;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 3;
    
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            ABS((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 3) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 4;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 4;
    \*СС 3 год*\
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         (SELECT t.s1
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                        ELSE
                         ((SELECT t.tv_p3
                             FROM ins.t_actuar_value t
                            WHERE t.par_t = ta.par_t - 1
                              AND t.opt_brief = ta.opt_brief) +
                         (SELECT pc.delta_res + pc.delta_eib
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.change_year = ta.par_t) -
                         ta.cur_fee * (SELECT t.v_a1xn
                                          FROM ins.t_actuar_value t
                                         WHERE t.par_t = ta.par_t - 1
                                           AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 4;
    \****************************************************************\
    \*четвертый год SAVINGS*\
    UPDATE ins.t_actuar_value ta
       SET ta.net_prem_act = ta.cur_fee * (1 - (CASE
                               WHEN ta.par_n = 3 THEN
                                const_act_loading_3
                               ELSE
                                const_act_loading_5
                             END))
     WHERE ta.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.savings =
           (SELECT PKG_CHANGE_ANNIVERSARY.GET_SAVINGS_LUMP(pc.opt_brief
                                                          ,pc.start_date
                                                          ,TRUNC(pc.end_date)
                                                          ,ta.par_t
                                                          ,(SELECT tat.net_prem_act
                                                             FROM ins.t_actuar_value tat
                                                            WHERE tat.par_t = 1
                                                              AND tat.opt_brief = pc.opt_brief)
                                                          )
              FROM ins.t_inform_cover_lump pc
             WHERE pc.opt_brief = ta.opt_brief
               AND pc.change_year = 1)
     WHERE ta.par_t = 4;
    \*резерв 4 год*\
    UPDATE ins.t_actuar_value v
       SET v.tv_p3 = (CASE
                       WHEN (SELECT va.cur_fee
                               FROM ins.t_actuar_value va
                              WHERE va.opt_brief = v.opt_brief
                                AND va.par_t = v.par_t - 1) = v.cur_fee THEN
                        v.net_res
                       ELSE
                        (v.s1 * v.v_nex + v.cur_fee * v.v_a1xn)
                     END)
     WHERE v.par_t = 4;
    \**\
    UPDATE ins.t_inform_cover_lump pc
       SET (pc.reserve_take, pc.w_for_distrib, pc.w_for_take) =
           (SELECT (CASE
                     WHEN pc.priznak = 0 THEN
                      ABS((SELECT (v.tv_p3 + (SELECT vv.adres
                                                FROM ins.t_actuar_value vv
                                               WHERE vv.opt_brief = v.opt_brief
                                                 AND vv.par_t = v.par_t - 1)) / v.tv_p
                             FROM ins.t_actuar_value v
                            WHERE v.opt_brief = pc.opt_brief
                              AND v.par_t = pc.change_year - 1) * (pc.delta_w / 100))
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN pc.priznak = 1 THEN
                      pc.delta_prem / (SELECT SUM(pca.delta_prem)
                                         FROM ins.t_inform_cover_lump pca
                                        WHERE pca.change_year = pc.change_year
                                          AND pca.priznak = 0)
                     ELSE
                      0
                   END)
                  ,(CASE
                     WHEN (SELECT SUM(pca.priznak)
                             FROM ins.t_inform_cover_lump pca
                            WHERE pca.change_year = pc.change_year) = 0 THEN
                      0
                     ELSE
                      (1 - pc.priznak) * (pc.delta_w / 100)
                   END)
              FROM ins.t_inform_cover_lump c
             WHERE c.opt_brief = pc.opt_brief
               AND c.change_year = pc.change_year)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.reserve_distrib = pc.w_for_distrib *
                                (SELECT SUM(p.reserve_take)
                                   FROM ins.t_inform_cover_lump p
                                  WHERE p.change_year = pc.change_year)
          ,pc.w_for_take = (CASE
                             WHEN (SELECT SUM(p.w_for_take)
                                     FROM ins.t_inform_cover_lump p
                                    WHERE p.change_year = pc.change_year) = 0 THEN
                              0
                             ELSE
                              pc.w_for_take / (SELECT SUM(p.w_for_take)
                                                 FROM ins.t_inform_cover_lump p
                                                WHERE p.change_year = pc.change_year)
                           END)
     WHERE pc.change_year = 5;
    \**\
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.ad =
           (1 + a.fact_yield_rate) * (SELECT va.ad
                                        FROM ins.t_actuar_value va
                                       WHERE va.opt_brief = a.opt_brief
                                         AND va.par_t = a.par_t - 1)
     WHERE a.par_t = 4
       AND a.opt_brief = 'PEPR_A_PLUS';
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.adres = (CASE
                       WHEN a.par_n = 3 THEN
                        (CASE
                          WHEN (SELECT (CASE
                                         WHEN pc.priznak = 1 THEN
                                          pc.reserve_distrib
                                         ELSE
                                          -pc.reserve_take
                                       END)
                                  FROM ins.t_inform_cover_lump pc
                                 WHERE pc.opt_brief = a.opt_brief
                                   AND pc.change_year = a.par_t + 1) < 0 THEN
                           0
                          ELSE
                           a.ad * a.s1 + (SELECT (CASE
                                                   WHEN pc.priznak = 1 THEN
                                                    pc.reserve_distrib
                                                   ELSE
                                                    -pc.reserve_take
                                                 END)
                                            FROM ins.t_inform_cover_lump pc
                                           WHERE pc.opt_brief = a.opt_brief
                                             AND pc.change_year = a.par_t + 1) *
                           (1 - (SELECT (ta.tv_p / (ta.tv_p + ta.ad))
                                                 FROM ins.t_actuar_value ta
                                                WHERE ta.par_t = a.par_t - 1
                                                  AND ta.opt_brief = a.opt_brief))
                        END)
                       ELSE
                        a.ad * a.s1
                     END)
     WHERE a.par_t = 4
       AND a.opt_brief = 'PEPR_A_PLUS';
    \**\
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_res = (CASE
                            WHEN pc.opt_brief = 'PEPR_A_PLUS' THEN
                             (SELECT va.tv_p /
                                     (va.tv_p + (SELECT ta.ad
                                                   FROM ins.t_actuar_value ta
                                                  WHERE ta.par_t = va.par_t - 1
                                                    AND ta.opt_brief = va.opt_brief))
                                FROM ins.t_actuar_value va
                               WHERE va.opt_brief = pc.opt_brief
                                 AND va.par_t = pc.change_year - 1)
                            ELSE
                             1
                          END) * (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.reserve_distrib
                            ELSE
                             -pc.reserve_take
                          END) * (SELECT va.tv_p
                                    FROM ins.t_actuar_value va
                                   WHERE va.opt_brief = pc.opt_brief
                                     AND va.par_t = pc.change_year - 1)
     WHERE pc.change_year = 5;
    \*вклад 4 год*\
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_take = (CASE
                               WHEN pc.priznak = 0 THEN
                                ABS((SELECT ta.savings
                                       FROM ins.t_actuar_value ta
                                      WHERE ta.opt_brief = pc.opt_brief
                                        AND ta.par_t = 4) * (pc.delta_w / 100))
                               ELSE
                                0
                             END)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.deposit_distrib = pc.w_for_distrib *
                                ABS((SELECT SUM(p.deposit_take) - SUM(p.pen_for_year)
                                      FROM ins.t_inform_cover_lump p
                                     WHERE p.change_year = pc.change_year))
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_deposit = (CASE
                                WHEN pc.priznak = 1 THEN
                                 pc.deposit_distrib
                                ELSE
                                 -pc.deposit_take
                              END)
     WHERE pc.change_year = 5;
    \*доп доход 4 год*\
    UPDATE INS.T_ACTUAR_VALUE a
       SET a.tv_p2    = a.s1 * a.v_nex + a.cur_fee * a.v_a1xn
          ,a.tvexp    = a.az * a.g * a.v_a_xn
          ,a.tvexp_sa =
           (a.az * a.g * a.v_a_xn) * a.s1
     WHERE a.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = ta.savings - (SELECT t.adres
                                          FROM ins.t_actuar_value t
                                         WHERE t.opt_brief = ta.opt_brief
                                           AND t.par_t = ta.par_t - 1) -
                          (ta.tvexp_sa + GREATEST(ta.tv_p2, 0))
     WHERE ta.par_t = 4;
    UPDATE ins.t_actuar_value ta
       SET ta.eib_theor = (CASE
                            WHEN ta.eib_theor < 0 THEN
                             0
                            ELSE
                             ta.eib_theor
                          END)
     WHERE ta.par_t = 4;
    
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_take = (CASE
                           WHEN pc.priznak = 0 THEN
                            ABS((SELECT ta.eib_theor
                                   FROM ins.t_actuar_value ta
                                  WHERE ta.opt_brief = pc.opt_brief
                                    AND ta.par_t = 4) * (pc.delta_w / 100))
                           ELSE
                            0
                         END)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.did_distrib = pc.w_for_distrib *
                            (SELECT SUM(p.did_take) - SUM(p.pen_for_year)
                               FROM ins.t_inform_cover_lump p
                              WHERE p.change_year = pc.change_year)
     WHERE pc.change_year = 5;
    UPDATE ins.t_inform_cover_lump pc
       SET pc.delta_eib = (CASE
                            WHEN pc.priznak = 1 THEN
                             pc.did_distrib
                            ELSE
                             -pc.did_take
                          END)
     WHERE pc.change_year = 5;
    \*СС 4 год*\
    UPDATE ins.t_actuar_value ta
       SET ta.s1 = (CASE
                     WHEN ta.cur_fee = 0 THEN
                      0
                     ELSE
                      (CASE
                        WHEN (SELECT t.cur_fee
                                FROM ins.t_actuar_value t
                               WHERE t.par_t = ta.par_t - 1
                                 AND t.opt_brief = ta.opt_brief) = ta.cur_fee THEN
                         (SELECT t.s1
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                        ELSE
                         ((SELECT t.tv_p3
                             FROM ins.t_actuar_value t
                            WHERE t.par_t = ta.par_t - 1
                              AND t.opt_brief = ta.opt_brief) +
                         (SELECT pc.delta_res + pc.delta_eib
                             FROM ins.t_inform_cover_lump pc
                            WHERE pc.opt_brief = ta.opt_brief
                              AND pc.change_year = ta.par_t) -
                         ta.cur_fee * (SELECT t.v_a1xn
                                          FROM ins.t_actuar_value t
                                         WHERE t.par_t = ta.par_t - 1
                                           AND t.opt_brief = ta.opt_brief)) /
                         (SELECT t.v_nex
                            FROM ins.t_actuar_value t
                           WHERE t.par_t = ta.par_t - 1
                             AND t.opt_brief = ta.opt_brief)
                      END)
                   END)
     WHERE ta.par_t = 5;*/
    /**/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ANOTHER_UPDATE_QUART: ' || SQLERRM);
  END another_update_quart;
  /**/
  FUNCTION get_savings_quart
  (
    par_opt_brief      VARCHAR2
   ,par_date_begin     DATE
   ,par_date_end       DATE
   ,par_period         NUMBER
   ,par_t              NUMBER
   ,par_net_prem_act_1 NUMBER DEFAULT 0
   ,par_cover_id       NUMBER
  ) RETURN NUMBER IS
    v_yield_min             NUMBER;
    res_1                   NUMBER := 0;
    v_days                  NUMBER := 0;
    v_date_begin            DATE;
    v_delta_deposit         NUMBER := 0;
    const_days_1            NUMBER := 0;
    const_days_2            NUMBER := 0;
    v_date_yield            DATE;
    v_is_change             NUMBER;
    v_par_n                 NUMBER;
    v_par_t                 NUMBER;
    v_pol_header_start_date DATE;
  BEGIN
  
    FOR k IN 1 .. par_period
    LOOP
      BEGIN
        SELECT nvl(l.is_change, 0)
              ,MONTHS_BETWEEN(l.end_date + 1 / 24 / 3600, l.start_date) / 12
          INTO v_is_change
              ,v_par_n
          FROM ins.t_inform_cover_lump l
         WHERE l.opt_brief = par_opt_brief
           AND l.quart_value = k;
      EXCEPTION
        WHEN no_data_found THEN
          v_is_change := 0;
          v_par_n     := 3;
      END;
      IF v_par_n * 4 = k
      THEN
        v_par_t := par_t + 1;
      ELSE
        v_par_t := par_t;
      END IF;
      FOR i IN 1 .. v_par_t
      LOOP
        IF k = 1
           AND i = 1
        THEN
          v_days       := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
          const_days_1 := v_days;
          const_days_2 := par_date_begin - trunc(par_date_begin, 'MM');
        ELSIF (v_is_change = 1 AND i = 1)
        THEN
          v_days := const_days_1;
        ELSE
          v_days := 30;
        END IF;
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (CEIL(k / 4) - 1)), 'MM');
      
        IF i = 4
        THEN
          v_date_yield := ADD_MONTHS(v_date_yield, 1);
        ELSE
          SELECT ADD_MONTHS(v_date_begin
                           ,decode(MOD((k - 1) * 3 + i, 12), 0, 12, MOD((k - 1) * 3 + i, 12)) - 1)
            INTO v_date_yield
            FROM dual;
        END IF;
      
        --Чирков/добавлено условие/ по заявке 250261: таблицы доходности
        --****************************   
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'PEPR_B' THEN
                    ty.base_min
                   WHEN 'PEPR_A_PLUS' THEN
                    ty.aggressive_plus_min
                   WHEN 'PEPR_A' THEN
                    ty.aggressive_min
                   WHEN 'PEPR_C' THEN
                    ty.conservative_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = v_date_yield;
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'PEPR_B' THEN
                    ty.base_min
                   WHEN 'PEPR_A_PLUS' THEN
                    ty.aggressive_plus_min
                   WHEN 'PEPR_A' THEN
                    ty.aggressive_min
                   WHEN 'PEPR_C' THEN
                    ty.conservative_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = v_date_yield;
        END IF;
        --*****************************                   
      
        IF k = 1
           AND i = 1
        THEN
          res_1 := ROUND((par_net_prem_act_1) * (1 + (v_yield_min / 30) * v_days), 2);
        ELSIF i = 4
        THEN
          res_1 := ROUND(res_1 * (1 + (v_yield_min / 30) * const_days_2), 2);
        ELSE
          IF (v_is_change = 1 AND i = 1)
          THEN
            BEGIN
              SELECT nvl(pc.delta_deposit, 0)
                INTO v_delta_deposit
                FROM ins.t_inform_cover_lump pc
               WHERE pc.opt_brief = par_opt_brief
                 AND pc.quart_value = k;
            EXCEPTION
              WHEN no_data_found THEN
                v_delta_deposit := 0;
            END;
            /*RES_1 := ROUND(((ROUND(RES_1 * (1 + V_YIELD_MIN * CONST_DAYS_2 / 30), 2)) +
             V_DELTA_DEPOSIT) * (1 + (V_YIELD_MIN / 30) * CONST_DAYS_1)
            ,2);*/
            res_1 := ROUND(((res_1 * (1 + v_yield_min * (30 - v_days) / 30)) + v_delta_deposit) *
                           (1 + v_yield_min * v_days / 30)
                          ,2);
          ELSE
            res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      
      END LOOP;
    
    END LOOP;
  
    RETURN ROUND(res_1, 2);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_SAVINGS_QUART: ' || SQLERRM);
  END get_savings_quart;
  /**/
  FUNCTION get_savings_reg_quart
  (
    par_opt_brief     VARCHAR2
   ,par_date_begin    DATE
   ,par_date_end      DATE
   ,par_period        NUMBER
   ,par_t             NUMBER
   ,par_change_year   NUMBER
   ,par_net_prem      NUMBER
   ,par_net_prem_prev NUMBER
   ,par_savings_prev  NUMBER
   ,par_cover_id      NUMBER
  ) RETURN NUMBER IS
    v_yield_min             NUMBER;
    res_1                   NUMBER := 0;
    res_2                   NUMBER := 0;
    v_days                  NUMBER := 0;
    v_date_begin            DATE;
    v_delta_deposit         NUMBER := 0;
    const_days_1            NUMBER := 0;
    const_days_2            NUMBER := 0;
    v_date_yield            DATE;
    v_is_change             NUMBER;
    v_par_n                 NUMBER;
    v_par_t                 NUMBER;
    v_net_prem_act          NUMBER;
    v_real_start            DATE;
    v_ch_1                  NUMBER;
    v_ch_2                  NUMBER;
    v_ch_3                  NUMBER;
    v_ch_4                  NUMBER;
    v_ch_quart              NUMBER;
    v_pol_header_start_date DATE;
  BEGIN
  
    FOR k IN 1 .. par_period
    LOOP
      /*рассчитать лишний месяц*/
      /*IF PAR_CHANGE_YEAR > 1 AND (PAR_NET_PREM_PREV != PAR_NET_PREM) AND k = 1 THEN
        V_DATE_BEGIN := TRUNC(ADD_MONTHS(PAR_DATE_BEGIN, 12 * (PAR_CHANGE_YEAR - 1)), 'MM');
        SELECT CASE PAR_OPT_BRIEF
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_A_PLUS' THEN
                  ty.aggressive_plus_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
               END
          INTO V_YIELD_MIN
          FROM ins.t_reference_yield ty
         WHERE ty.t_date_yield = V_DATE_BEGIN;
        BEGIN
          SELECT NVL(pc.delta_deposit, 0)
            INTO V_DELTA_DEPOSIT
            FROM ins.t_inform_cover_lump pc
           WHERE pc.opt_brief = PAR_OPT_BRIEF
             AND pc.quart_value = (PAR_CHANGE_YEAR * 4) + 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_DELTA_DEPOSIT := 0;
        END;
        RES_2 := ROUND(((PAR_SAVINGS_PREV * (1 + V_YIELD_MIN * (30 - CONST_DAYS_1) / 30)) +
                       V_DELTA_DEPOSIT) * (1 + V_YIELD_MIN * CONST_DAYS_1 / 30)
                      ,2);
      ELS*/
      IF par_change_year > 1
         AND /*(PAR_NET_PREM_PREV = PAR_NET_PREM) AND*/
         k = 1
      THEN
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (par_change_year - 1)), 'MM');
      
        --Чирков/добавлено условие/ по заявке 250261: таблицы доходности
        --****************************   
        v_pol_header_start_date := getpolstartdatebycoverid(par_cover_id);
      
        IF v_pol_header_start_date > to_date('01.06.2013', 'dd.mm.yyyy')
        THEN
          SELECT CASE par_opt_brief
                   WHEN 'PEPR_B' THEN
                    ty.base_min
                   WHEN 'PEPR_A_PLUS' THEN
                    ty.aggressive_plus_min
                   WHEN 'PEPR_A' THEN
                    ty.aggressive_min
                   WHEN 'PEPR_C' THEN
                    ty.conservative_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield_profile ty
           WHERE ty.t_date_yield = v_date_begin;
        ELSE
          SELECT CASE par_opt_brief
                   WHEN 'PEPR_B' THEN
                    ty.base_min
                   WHEN 'PEPR_A_PLUS' THEN
                    ty.aggressive_plus_min
                   WHEN 'PEPR_A' THEN
                    ty.aggressive_min
                   WHEN 'PEPR_C' THEN
                    ty.conservative_min
                 END
            INTO v_yield_min
            FROM ins.t_reference_yield ty
           WHERE ty.t_date_yield = v_date_begin;
        END IF;
        --*****************************     
      
        res_2 := ROUND(par_savings_prev * (1 + v_yield_min), 2);
      END IF;
      /**/
      SELECT SUM(abs(l.pen_for_year))
        INTO v_ch_1
        FROM ins.t_inform_cover_lump l
       WHERE l.quart_value = k + (par_change_year - 1) * 4;
      SELECT SUM(abs(l.delta_w))
        INTO v_ch_2
        FROM ins.t_inform_cover_lump l
       WHERE l.quart_value = k + (par_change_year - 1) * 4;
      SELECT SUM(nvl(l.priznak, 0))
        INTO v_ch_3
        FROM ins.t_inform_cover_lump l
       WHERE l.quart_value = k + (par_change_year - 1) * 4;
      SELECT SUM(nvl(l.is_change, 0))
        INTO v_ch_4
        FROM ins.t_inform_cover_lump l
       WHERE l.quart_value = k + (par_change_year - 1) * 4;
      SELECT k + (par_change_year - 1) * 4 INTO v_ch_quart FROM dual;
      IF nvl(v_ch_1, 0) + nvl(v_ch_2, 0) + nvl(v_ch_3, 0) + nvl(v_ch_4, 0) > 0
      THEN
        v_is_change := 1;
      ELSE
        v_is_change := 0;
      END IF;
      BEGIN
        SELECT l.change_year
              ,(SELECT pol.start_date FROM ins.p_policy pol WHERE pol.policy_id = l.policy_id)
          INTO v_par_n
              ,v_real_start
          FROM ins.t_inform_cover_lump l
         WHERE l.opt_brief = par_opt_brief
           AND l.quart_value = v_ch_quart
           AND v_is_change = 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_par_n      := 3;
          v_real_start := par_date_begin;
      END;
      v_par_t := par_t;
      FOR i IN 1 .. v_par_t
      LOOP
        IF k = 1
           AND i = 1
        THEN
          v_days       := trunc(ADD_MONTHS(par_date_begin, 1), 'MM') - par_date_begin - 1;
          const_days_1 := v_days;
          const_days_2 := par_date_begin - trunc(par_date_begin, 'MM');
        ELSIF (v_is_change = 1 AND i = 1)
        THEN
          v_days := const_days_1;
        ELSE
          v_days := 30;
        END IF;
        v_date_begin := trunc(ADD_MONTHS(par_date_begin, 12 * (par_change_year - 1)), 'MM');
      
        IF i = 4
        THEN
          v_date_yield := ADD_MONTHS(v_date_yield, 1);
        ELSE
          SELECT ADD_MONTHS(v_date_begin
                           ,decode(MOD((k - 1) * 3 + i, 12), 0, 12, MOD((k - 1) * 3 + i, 12)) - 1)
            INTO v_date_yield
            FROM dual;
        END IF;
      
        SELECT CASE par_opt_brief
                 WHEN 'PEPR_B' THEN
                  ty.base_min
                 WHEN 'PEPR_A_PLUS' THEN
                  ty.aggressive_plus_min
                 WHEN 'PEPR_A' THEN
                  ty.aggressive_min
                 WHEN 'PEPR_C' THEN
                  ty.conservative_min
               END
          INTO v_yield_min
          FROM ins.t_reference_yield ty
         WHERE ty.t_date_yield = v_date_yield;
      
        IF k = 1
           AND i = 1
        THEN
          res_1 := ROUND((par_net_prem) * (1 + (v_yield_min / 30) * v_days), 2);
        ELSIF i = 4
        THEN
          res_1 := ROUND(res_1 * (1 + (v_yield_min / 30) * const_days_2), 2);
        ELSIF par_change_year > 1
              AND k = 1
              AND i = 2
        THEN
          res_1 := ROUND((res_1 + res_2) * (1 + v_yield_min), 2);
        ELSE
          IF (v_is_change = 1 AND trunc(v_date_yield, 'MM') = trunc(v_real_start, 'MM'))
             OR (MOD(k, 4) = 0 AND i = 4)
          THEN
            BEGIN
              SELECT nvl(pc.delta_deposit, 0)
                INTO v_delta_deposit
                FROM ins.t_inform_cover_lump pc
               WHERE pc.opt_brief = par_opt_brief
                 AND pc.quart_value = k + (par_change_year - 1) * 4;
            EXCEPTION
              WHEN no_data_found THEN
                v_delta_deposit := 0;
            END;
            SELECT ADD_MONTHS(v_date_yield, 1) - v_real_start - 1 INTO v_days FROM dual;
            res_1 := ROUND(((res_1 * (1 + v_yield_min * (30 - v_days) / 30)) + v_delta_deposit) *
                           (1 + v_yield_min * v_days / 30)
                          ,2);
          ELSE
            res_1 := ROUND(res_1 * (1 + v_yield_min), 2);
          END IF;
        END IF;
      
      END LOOP;
    
    END LOOP;
  
    RETURN ROUND(res_1, 2);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении GET_SAVINGS_REG_QUART: ' || SQLERRM);
  END get_savings_reg_quart;

/**/
END pkg_change_anniversary;
/
