CREATE OR REPLACE PACKAGE pkg_policy_decline_opers IS

  /*Данный пакет содержит функции формирования проводок
  (функционал вынесен из PKG_POLICY_DECLINE)
  */

  -- Начисление выкупной суммы
  PROCEDURE op_redemption_summ(par_policy_id p_policy.policy_id%TYPE);

  --Зачтена выплата ВС и ДИД
  PROCEDURE op_payment_vs_did(par_policy_id p_policy.policy_id%TYPE);

  -- Начисление дополнительного инвестиционного дохода
  PROCEDURE op_add_invest_income(par_policy_id p_policy.policy_id%TYPE);

  --  Начислен возврат СП при расторжении ДС
  PROCEDURE op_ret_sp_by_decline_ds(par_policy_id p_policy.policy_id%TYPE);

  --  Зачтена выплата возв 2 (по ВЧП)
  PROCEDURE op_payment_ret_vchp(par_policy_id p_policy.policy_id%TYPE);

  --  Зачтена выплата возв 2 (по переплате)
  PROCEDURE op_payment_ret_ovepayment(par_policy_id p_policy.policy_id%TYPE);

  --  Начислен возврат СП при расторжении ДС (для аннулирования) 
  PROCEDURE op_ret_sp_by_decline_ds_annul(par_policy_id p_policy.policy_id%TYPE);

  -- Госпошлина
  PROCEDURE op_state_duty(par_payment_id ac_payment.payment_id%TYPE);

  -- Штраф
  PROCEDURE op_penalty(par_payment_id ac_payment.payment_id%TYPE);

  -- Прочие судебные расходы
  PROCEDURE op_other_court_fees(par_payment_id ac_payment.payment_id%TYPE);

  -- Прочие доходы (доходы при аннулировании ДС)
  PROCEDURE op_other_income_ds_annul(par_payment_id ac_payment.payment_id%TYPE);

  -- Корректировка начисленной премии к списанию прошлых лет
  PROCEDURE op_correct_bonus_prev(par_policy_id p_policy.policy_id%TYPE);

  -- Сторно начисленной премии к списанию текущего года
  PROCEDURE op_storno_bonus_cur_year(par_policy_id p_policy.policy_id%TYPE);

  -- Корректировка неоплаченной премии прошлых лет
  PROCEDURE op_correct_unpayed_bonus_prev(par_policy_id p_policy.policy_id%TYPE);

  -- Корректировка неоплаченной премии текущего года
  PROCEDURE op_correct_unpayed_bonus_cur(par_policy_id p_policy.policy_id%TYPE);
  -- Корректировка начисленной премии (НУ НОБ)
  PROCEDURE op_correct_bonus_nu_nob(par_policy_id p_policy.policy_id%TYPE);

  -- Зачет ВС 
  PROCEDURE op_payment_vs(par_policy_id p_policy.policy_id%TYPE);

  -- Зачтена выплата ДИД  
  PROCEDURE op_payment_did(par_policy_id p_policy.policy_id%TYPE);
  -- Зачтена выплата возв  
  PROCEDURE op_payment_ret(par_policy_id p_policy.policy_id%TYPE);

  -- Возмещение МедО
  PROCEDURE op_contribute_medo(par_payment_id ac_payment.payment_id%TYPE);

  -- Переплата по договору
  PROCEDURE op_policy_ovepayment(par_policy_id p_policy.policy_id%TYPE);

  -- Удержан НДФЛ
  PROCEDURE op_deduct_ndfl(par_payment_id ac_payment.payment_id%TYPE);

  -- Промежуточная к оплате НДФЛ
  PROCEDURE op_intermediate_pay_ndfl(par_payment_id ac_payment.payment_id%TYPE);

  -- Сторно начисленной премии МСФО к списанию текущего года
  PROCEDURE op_storno_msfo_bonus_curr(par_policy_id p_policy.policy_id%TYPE);

  -- Корректировка неоплаченной премии МСФО
  PROCEDURE op_correct_unpayed_msfo(par_policy_id p_policy.policy_id%TYPE);

  -- Деньги выплачены безнал для ППИ
  PROCEDURE op_cashless_payment_ppi(par_payment_id ac_payment.payment_id%TYPE);

  -- Процент за пользование чужих денежных средств
  PROCEDURE op_borrowed_money_percent(par_payment_id ac_payment.payment_id%TYPE);

  -- Моральный вред
  PROCEDURE op_moral_damage(par_payment_id ac_payment.payment_id%TYPE);

  -- Оплата услуг
  PROCEDURE op_service_fee(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержана госпошлина
  PROCEDURE op_deduct_state_duty(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержан штраф
  PROCEDURE op_deduct_penalty(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержаны прочие судебные расходы
  PROCEDURE op_deduct_other_court_fees(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержан процент за пользование чужих денежных средств
  PROCEDURE op_deduct_borr_money_percent(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержан моральный вред
  PROCEDURE op_deduct_moral_damage(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержана оплата услуг
  PROCEDURE op_deduct_service_fee(par_payment_id ac_payment.payment_id%TYPE);

  -- Удержан МедО при выплате
  PROCEDURE op_deduct_medo(par_payment_id ac_payment.payment_id%TYPE);
  
  -- Зачет недоплаты, удерживаемой из выплаты
  PROCEDURE op_deduct_unpayment_amount(par_policy_id p_policy.policy_id%TYPE); 

END pkg_policy_decline_opers;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_decline_opers IS

  gc_vs_target_type   VARCHAR2(10) := 'VS';
  gc_did_target_type  VARCHAR2(10) := 'DID';
  gc_vchp_target_type VARCHAR2(10) := 'VCHP';

  gc_expense_code_50003 ac_payment_add_info.expense_code%TYPE := 50003;
  gc_expense_code_50004 ac_payment_add_info.expense_code%TYPE := 50004;

  CURSOR cur_data_for_program(cp_policy_id NUMBER) IS
    SELECT pd.p_policy_id
          ,cd.ent_id                       cover_ent_id
          ,cd.p_cover_decline_id
          ,cd.redemption_sum
          ,cd.add_invest_income
          ,cd.return_bonus_part
          ,cd.bonus_off_prev
          ,cd.bonus_off_current
          ,cd.underpayment_previous
          ,cd.underpayment_current
          ,cd.unpayed_premium_lp
          ,cd.premium_msfo
          ,cd.unpayed_msfo_prem_correction
          ,cd.add_policy_surrender
          ,cd.admin_expenses
          ,cd.unpayed_premium_previous
          ,cd.unpayed_premium_current
          ,cd.underpayment_lp
          ,cd.overpayment                  cd_overpayment
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
       AND pd.p_policy_id = cp_policy_id;

  CURSOR cur_data_for_policy(cp_policy_id NUMBER) IS
    SELECT pd.p_policy_id
          ,pd.p_pol_decline_id
          ,pd.ent_id           pd_ent_id
          ,pd.overpayment      pd_overpayment
          ,pd.state_duty
          ,pd.penalty
          ,pd.other_court_fees
          ,pd.debt_fee_fact
          ,pd.medo_cost
          ,pd.income_tax_sum
      FROM p_pol_decline pd
     WHERE pd.p_policy_id = cp_policy_id;

  CURSOR cur_data_by_payment(cp_payment_id NUMBER) IS
    SELECT pd.p_pol_decline_id
          ,pd.overpayment
          ,pd.state_duty
          ,pd.penalty
          ,pd.other_court_fees
          ,pd.debt_fee_fact
          ,pd.medo_cost
          ,pd.income_tax_sum
          ,pd.borrowed_money_percent
          ,pd.moral_damage
          ,pd.service_fee
          ,ap.payment_id             ap_payment_id
          ,pd.ent_id                 pd_ent_id
          ,ap.payment_id
          ,apai.expense_code
          ,522                       ap_ent_id
      FROM ac_payment          ap
          ,doc_doc             dd
          ,p_pol_decline       pd
          ,ac_payment_add_info apai
     WHERE ap.payment_id = dd.child_id
       AND dd.parent_id = pd.p_policy_id
       AND doc.get_doc_status_brief(pd.p_policy_id) = 'QUIT_TO_PAY'
       AND apai.ac_payment_add_info_id = ap.payment_id
       AND ap.payment_id = cp_payment_id;

  CURSOR cur_data_by_paym_with_cover(cp_payment_id NUMBER) IS
    SELECT pd.p_policy_id
          ,cd.p_cover_decline_id
          ,ap.payment_id                   ap_payment_id
          ,cd.redemption_sum
          ,cd.add_invest_income
          ,cd.return_bonus_part
          ,cd.bonus_off_prev
          ,cd.bonus_off_current
          ,cd.underpayment_previous
          ,cd.underpayment_current
          ,cd.unpayed_premium_lp
          ,cd.premium_msfo
          ,cd.unpayed_msfo_prem_correction
          ,cd.add_policy_surrender
          ,cd.admin_expenses
          ,cd.unpayed_premium_previous
          ,cd.unpayed_premium_current
          ,cd.underpayment_lp
          ,cd.ent_id                       cd_ent_id
          ,apai.expense_code
          ,522                             ap_ent_id
      FROM ac_payment          ap
          ,doc_doc             dd
          ,p_pol_decline       pd
          ,p_cover_decline     cd
          ,ac_payment_add_info apai
     WHERE ap.payment_id = dd.child_id
       AND dd.parent_id = pd.p_policy_id
       AND doc.get_doc_status_brief(pd.p_policy_id) = 'QUIT_TO_PAY'
       AND cd.p_pol_decline_id = pd.p_pol_decline_id
       AND apai.ac_payment_add_info_id = ap.payment_id
       AND ap.payment_id = cp_payment_id;

  -- возвращает 1, если id платежного поручения связан с версией договора прекращения
  FUNCTION check_paym_by_pol_decline(par_payment_id NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_res
      FROM p_pol_decline pd
          ,doc_doc       dd
          ,ac_payment    ap
     WHERE pd.p_policy_id = dd.parent_id
       AND ap.payment_id = dd.child_id
       AND ap.payment_id = par_payment_id;
  
    RETURN v_res;
  END check_paym_by_pol_decline;

  /** возвращает 1, если это программа с ВС, иначе 0
      @param par_policy_id - id версии ДС
      @param par_product_line_id - id программы  
  */
  FUNCTION check_exists_r_summ_in_progr
  (
    par_policy_id       NUMBER
   ,par_product_line_id NUMBER
  ) RETURN NUMBER IS
    v_cnt NUMBER;
    CURSOR cur
    (
      cp_policy_id       NUMBER
     ,cp_product_line_id NUMBER
    ) IS
      WITH all_cash_surrs AS
       (SELECT cs.policy_cash_surr_id
              ,csd.policy_cash_surr_d_id
              ,CASE
                 WHEN cs.p_cover_id IS NOT NULL THEN
                  (SELECT aas.assured_contact_id
                     FROM p_cover    pc
                         ,as_assured aas
                    WHERE pc.as_asset_id = aas.as_assured_id
                      AND pc.p_cover_id = cs.p_cover_id)
                 ELSE
                  cs.contact_id
               END contact_id
              ,CASE
                 WHEN cs.p_cover_id IS NOT NULL THEN
                  (SELECT plo.product_line_id
                     FROM p_cover            pc
                         ,t_prod_line_option plo
                    WHERE pc.p_cover_id = cs.p_cover_id
                      AND pc.t_prod_line_option_id = plo.id)
                 ELSE
                  (SELECT MAX(plo.product_line_id)
                     FROM p_cover            pc
                         ,t_prod_line_option plo
                         ,t_product_line     pl
                         ,as_asset           se
                    WHERE se.p_policy_id = cs.policy_id
                      AND pc.as_asset_id = se.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.t_lob_line_id = cs.t_lob_line_id)
               END product_line_id
              ,csd.start_cash_surr_date
              ,csd.end_cash_surr_date
              ,csd.value
          FROM policy_cash_surr cs
              ,policy_cash_surr_d csd
              ,(SELECT pp.policy_id
                  FROM p_policy pp
                 START WITH pp.policy_id = cp_policy_id
                CONNECT BY PRIOR pp.prev_ver_id = pp.policy_id) p
         WHERE cs.policy_id = p.policy_id
           AND cs.policy_cash_surr_id = csd.policy_cash_surr_id)
      SELECT COUNT(1)
        FROM all_cash_surrs t
       WHERE t.policy_cash_surr_d_id IN
             (SELECT MAX(policy_cash_surr_d_id)
                FROM all_cash_surrs t2
               WHERE t2.contact_id = t.contact_id
                 AND t2.product_line_id = t.product_line_id
                 AND t.start_cash_surr_date = t2.start_cash_surr_date)
         AND t.product_line_id = cp_product_line_id;
  BEGIN
    OPEN cur(par_policy_id, par_product_line_id);
    FETCH cur
      INTO v_cnt;
    CLOSE cur;
  
    IF v_cnt > 0
    THEN
      RETURN 1;
    END IF;
  
    RETURN 0;
  END;

  -- шаблон вызова метода acc_new.run_oper_by_template
  PROCEDURE run_oper_by_templ
  (
    par_oper_templ_name IN VARCHAR2
   ,par_document_id     IN NUMBER
   ,par_ent_id          IN NUMBER
   ,par_obj_id          IN NUMBER
   ,par_sum             IN NUMBER
  ) IS
  
    v_oper_id NUMBER;
  BEGIN
    IF par_sum <> 0
    THEN
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id  => dml_oper_templ.get_id_by_name(par_oper_templ_name)
                                               ,p_document_id    => par_document_id
                                               ,p_service_ent_id => par_ent_id
                                               ,p_service_obj_id => par_obj_id
                                               ,p_summ           => ROUND(par_sum, 2));
    END IF;
  END;
  -- Начисление выкупной суммы
  PROCEDURE op_redemption_summ(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
    
      run_oper_by_templ(par_oper_templ_name => 'Начисление выкупной суммы'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.redemption_sum); /*Выкупная сумма*/
    END LOOP;
  END op_redemption_summ;

  --Зачтена выплата ВС и ДИД
  PROCEDURE op_payment_vs_did(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата ВС и ДИД'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.redemption_sum); /*Выкупная сумма*/
      run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата ВС и ДИД'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.add_policy_surrender); /*Дополнительная выкупная сумма*/
      run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата ВС и ДИД'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.add_invest_income); /*Доп. инвест доход*/
    END LOOP;
  END op_payment_vs_did;

  -- Начисление дополнительного инвестиционного дохода
  PROCEDURE op_add_invest_income(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Начисление дополнительного инвестиционного дохода'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.add_policy_surrender); /*Дополнительная выкупная сумма*/
      run_oper_by_templ(par_oper_templ_name => 'Начисление дополнительного инвестиционного дохода'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.add_invest_income); /*Доп. инвест доход*/
    END LOOP;
  END op_add_invest_income;

  --  Начислен возврат СП при расторжении ДС
  PROCEDURE op_ret_sp_by_decline_ds(par_policy_id p_policy.policy_id%TYPE) IS
    v_is_annul NUMBER;
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      v_is_annul := pkg_policy_decline.is_policy_annulled(par_policy_id);
      IF (v_is_annul IS NULL OR v_is_annul = 0)
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Начислен возврат СП при расторжении ДС'
                         ,par_document_id     => rec.p_policy_id
                         ,par_ent_id          => rec.cover_ent_id
                         ,par_obj_id          => rec.p_cover_decline_id
                         ,par_sum             => rec.return_bonus_part); /*Возврат части премии*/
      END IF;
    END LOOP;
  END op_ret_sp_by_decline_ds;

  --  Зачтена выплата возв 2 (по ВЧП)
  PROCEDURE op_payment_ret_vchp(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата возв 2'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.return_bonus_part); /*Возврат части премии*/
    END LOOP;
  END op_payment_ret_vchp;

  --  Зачтена выплата возв 2 (по переплате)
  PROCEDURE op_payment_ret_ovepayment(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_policy(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата возв 2'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.pd_ent_id
                       ,par_obj_id          => rec.p_pol_decline_id
                       ,par_sum             => rec.pd_overpayment); /*Переплата*/
    END LOOP;
  
  END op_payment_ret_ovepayment;

  --  Начислен возврат СП при расторжении ДС (для аннулирования) 
  PROCEDURE op_ret_sp_by_decline_ds_annul(par_policy_id p_policy.policy_id%TYPE) IS
    v_is_annul NUMBER;
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      v_is_annul := pkg_policy_decline.is_policy_annulled(par_policy_id);
      IF (v_is_annul = 1)
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Начислен возврат СП при расторжении ДС (для аннулирования)'
                         ,par_document_id     => rec.p_policy_id
                         ,par_ent_id          => rec.cover_ent_id
                         ,par_obj_id          => rec.p_cover_decline_id
                         ,par_sum             => rec.return_bonus_part); /*Возврат части премии*/
      END IF;
    END LOOP;
  END op_ret_sp_by_decline_ds_annul;

  -- Госпошлина
  PROCEDURE op_state_duty(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
      
        run_oper_by_templ(par_oper_templ_name => 'Госпошлина'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.state_duty); /*Госпошлина*/
      
      END IF;
    END LOOP;
  END op_state_duty;

  -- Штраф
  PROCEDURE op_penalty(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Штраф'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.penalty); /*Штраф*/
      END IF;
    END LOOP;
  END op_penalty;

  -- Прочие судебные расходы
  PROCEDURE op_other_court_fees(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Прочие судебные расходы'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.other_court_fees); /*Прочие судебные расходы*/
      END IF;
    END LOOP;
  END op_other_court_fees;

  -- Процент за пользование чужих денежных средств
  PROCEDURE op_borrowed_money_percent(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => '% за пользование чужих денежных средств'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.borrowed_money_percent); /*Процент за пользование чужими ДС*/
      END IF;
    END LOOP;
  END op_borrowed_money_percent;

  -- Моральный вред
  PROCEDURE op_moral_damage(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Моральный вред'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.moral_damage); /*Моральный вред*/
      END IF;
    END LOOP;
  END op_moral_damage;

  -- Оплата услуг
  PROCEDURE op_service_fee(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Оплата услуг'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.service_fee); /*Оплата услуг*/
      END IF;
    END LOOP;
  END op_service_fee;

  -- Деньги выплачены безнал для  ППИ
  PROCEDURE op_cashless_payment_ppi(par_payment_id ac_payment.payment_id%TYPE) IS
    vr_ac_payment dml_ac_payment.tt_ac_payment;
  
  BEGIN
    IF check_paym_by_pol_decline(par_payment_id) = 1
    THEN
      vr_ac_payment := dml_ac_payment.get_record(par_payment_id => par_payment_id);
    
      run_oper_by_templ(par_oper_templ_name => 'Деньги выплачены безнал'
                       ,par_document_id     => par_payment_id
                       ,par_ent_id          => 522 /*AC_PAYMENT entity id*/
                       ,par_obj_id          => par_payment_id
                       ,par_sum             => vr_ac_payment.amount); /*сумма*/
    END IF;
  END op_cashless_payment_ppi;

  -- Удержана госпошлина
  PROCEDURE op_deduct_state_duty(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
      
        run_oper_by_templ(par_oper_templ_name => 'Удержана госпошлина'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.state_duty); /*Госпошлина*/
      
      END IF;
    END LOOP;
  END op_deduct_state_duty;

  -- Удержан штраф
  PROCEDURE op_deduct_penalty(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержан штраф'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.penalty); /*Штраф*/
      END IF;
    END LOOP;
  END op_deduct_penalty;

  -- Удержаны прочие судебные расходы
  PROCEDURE op_deduct_other_court_fees(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержаны прочие судебные расходы'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.other_court_fees); /*Прочие судебные расходы*/
      END IF;
    END LOOP;
  END op_deduct_other_court_fees;

  -- Удержан процент за пользование чужих денежных средств
  PROCEDURE op_deduct_borr_money_percent(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержан процент за пользование чужими ДС'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.borrowed_money_percent); /*Процент за пользование чужими ДС*/
      END IF;
    END LOOP;
  END op_deduct_borr_money_percent;

  -- Удержан моральный вред
  PROCEDURE op_deduct_moral_damage(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержан моральный вред'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.moral_damage); /*Моральный вред*/
      END IF;
    END LOOP;
  END op_deduct_moral_damage;

  -- Удержана оплата услуг
  PROCEDURE op_deduct_service_fee(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержана оплата услуг'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.service_fee); /*Оплата услуг*/
      END IF;
    END LOOP;
  END op_deduct_service_fee;

  -- Удержан МедО при выплате
  PROCEDURE op_deduct_medo(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержан МедО'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.ap_ent_id -- rec.pd_ent_id
                         ,par_obj_id          => rec.ap_payment_id -- rec.p_pol_decline_id
                         ,par_sum             => rec.medo_cost); /*расходы на МедО*/
      
      END IF;
    END LOOP;
  END op_deduct_medo;

  -- Прочие доходы (доходы при расторжении)
  PROCEDURE op_other_income_ds_annul(par_payment_id ac_payment.payment_id%TYPE) IS
    v_is_annul NUMBER;
  BEGIN
    FOR rec IN cur_data_by_paym_with_cover(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Прочие доходы (доходы при аннулировании)'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.cd_ent_id
                         ,par_obj_id          => rec.p_cover_decline_id
                         ,par_sum             => rec.admin_expenses); /*РВД по рискам*/
      END IF;
    END LOOP;
  END op_other_income_ds_annul;

  -- Корректировка начисленной премии к списанию прошлых лет
  PROCEDURE op_correct_bonus_prev(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Корректировка Начисленной премии к списанию прошлых лет'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.bonus_off_prev); /*Начисленная премия к списанию прошлых лет*/
    END LOOP;
  END op_correct_bonus_prev;

  -- Сторно начисленной премии к списанию текущего года
  PROCEDURE op_storno_bonus_cur_year(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Сторно Начисленной премии к списанию текущего года'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => -rec.bonus_off_current); /*Начисленная премия к списанию этого года*/
    END LOOP;
  END op_storno_bonus_cur_year;

  -- Корректировка неоплаченной премии прошлых лет
  PROCEDURE op_correct_unpayed_bonus_prev(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Корректировка неоплаченной премии прошлых лет'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.unpayed_premium_previous); /*Начисленная премия к списанию по неоплате за прошлый период*/
    END LOOP;
  END op_correct_unpayed_bonus_prev;

  -- Корректировка неоплаченной премии текущего года
  PROCEDURE op_correct_unpayed_bonus_cur(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Корректировка неоплаченной премии текущего года'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => -rec.unpayed_premium_current); /*Начисленная премия к списанию по неоплате за текущий период*/
    END LOOP;
  END op_correct_unpayed_bonus_cur;

  -- Корректировка начисленной премии (НУ НОБ)
  PROCEDURE op_correct_bonus_nu_nob(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Корректировка начисленной премии (НУ НОБ)'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.unpayed_premium_lp); /*Недоплата за ЛП*/
    END LOOP;
  END op_correct_bonus_nu_nob;

  -- Возмещение МедО
  PROCEDURE op_contribute_medo(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50004
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Возмещение МедО'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.pd_ent_id
                         ,par_obj_id          => rec.p_pol_decline_id
                         ,par_sum             => rec.medo_cost); /*Расходы на МедО*/
      END IF;
    END LOOP;
  END op_contribute_medo;

  -- Переплата по договору
  PROCEDURE op_policy_ovepayment(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Переплата по договору'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => rec.cd_overpayment); /*Переплата*/
    END LOOP;
  END op_policy_ovepayment;

  -- Удержан НДФЛ
  PROCEDURE op_deduct_ndfl(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50003
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Удержан НДФЛ'
                         ,par_document_id     => rec.ap_payment_id
                         ,par_ent_id          => rec.pd_ent_id
                         ,par_obj_id          => rec.p_pol_decline_id
                         ,par_sum             => -rec.income_tax_sum); /*Сумма НДФЛ*/
      END IF;
    END LOOP;
  END op_deduct_ndfl;

  -- Промежуточная к оплате НДФЛ
  PROCEDURE op_intermediate_pay_ndfl(par_payment_id ac_payment.payment_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_by_payment(par_payment_id)
    LOOP
      IF rec.expense_code = gc_expense_code_50003
         AND check_paym_by_pol_decline(par_payment_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Промежуточная к оплате НДФЛ'
                         ,par_document_id     => rec.payment_id
                         ,par_ent_id          => rec.pd_ent_id
                         ,par_obj_id          => rec.p_pol_decline_id
                         ,par_sum             => rec.income_tax_sum); /*Сумма НДФЛ*/
      END IF;
    END LOOP;
  END op_intermediate_pay_ndfl;

  -- Сторно начисленной премии МСФО к списанию текущего года
  PROCEDURE op_storno_msfo_bonus_curr(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Сторно начисленной премии МСФО к списанию текущего года'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => -rec.premium_msfo); /*Начисленная премия МСФО к списанию*/
    END LOOP;
  END op_storno_msfo_bonus_curr;

  -- Корректировка неоплаченной премии МСФО
  PROCEDURE op_correct_unpayed_msfo(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    FOR rec IN cur_data_for_program(par_policy_id)
    LOOP
      run_oper_by_templ(par_oper_templ_name => 'Сторно начисленной премии МСФО к списанию текущего года'
                       ,par_document_id     => rec.p_policy_id
                       ,par_ent_id          => rec.cover_ent_id
                       ,par_obj_id          => rec.p_cover_decline_id
                       ,par_sum             => -rec.unpayed_msfo_prem_correction); /*Корректировка неоплаченной премии МСФО*/
    END LOOP;
  END op_correct_unpayed_msfo;

  -- формирование проводок по "стакану"
  -- параметры:
  -- par_policy_id - policy_id 
  -- par_category  - категория программ(id стакана)
  -- par_debt      - сумма недоплаты, если передан параметр null,
  --                 рассчитывается 
  -- par_target    - код типа проводки, ожидаемые значения:
  --                 VS, DID, VCHP     
  PROCEDURE calc_level_and_make_op
  (
    par_policy_id NUMBER
   ,par_category  NUMBER
   ,par_debt      IN OUT NUMBER
   ,par_target    VARCHAR2
  ) IS
    --суммы по полису в зависимости от категории
    CURSOR cur_sums
    (
      cp_policy_id NUMBER
     ,cp_category  NUMBER -- категория программ (1/2/3/4 - осн/доп без АИ/осн,доп без АИ/АИ
    ) IS
      SELECT pol.debt_summ debt_summ -- недоплата фактическая  
            ,cd.p_pol_decline_id
            ,pd.p_policy_id
            ,pd.ent_id pd_ent_id
            ,cd.ent_id cd_end_id
            ,cd.redemption_sum -- ВС
            ,cd.add_invest_income -- ДИД
            ,cd.return_bonus_part -- ВЧП
            ,cd.admin_expenses -- РВД
            ,SUM(cd.redemption_sum) over() red_s_summ
            ,SUM(cd.add_invest_income) over() add_inv_inc_summ
            ,SUM(cd.return_bonus_part) over() ret_bon_part_summ
            ,SUM(cd.admin_expenses) over() adm_exp_summ
        FROM p_cover_decline     cd
            ,p_pol_decline       pd
            ,t_product_line      prl
            ,t_product_line_type plt
            ,t_prod_line_option  plo
            ,p_cover             pc
            ,p_policy            pol
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND prl.id = cd.t_product_line_id
         AND plt.product_line_type_id = prl.product_line_type_id
         AND plo.product_line_id = prl.id
         AND pc.t_prod_line_option_id = plo.id
         AND pc.as_asset_id = cd.as_asset_id
         AND pol.policy_id = pd.p_policy_id
         AND ( /*1, основные программы*/
              cp_category = 1 AND plt.brief IN ('MANDATORY', 'RECOMMENDED') OR
             /*2, дополнительные программы без адм. издержек*/
              cp_category = 2 AND plt.brief = 'OPTIONAL' AND
              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
             /*3, основные и дополнительные программы без адм. издержек*/
              cp_category = 3 AND plt.brief IN ('MANDATORY', 'RECOMMENDED', 'OPTIONAL') AND
              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
             /*4, адм. издержки*/
              cp_category = 3 AND plt.brief = 'OPTIONAL' AND
              (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty'))
         AND pd.p_policy_id = cp_policy_id;
    vr cur_sums%ROWTYPE;
  
    -- курсор для распределения средств в зависимости от значений 
    -- выкупных сумм по программам
    CURSOR cur_rs_for_trans
    (
      cp_policy_id NUMBER
     ,cp_coef      NUMBER -- распределяемая сумма
     ,cp_category  NUMBER -- категория программ (1/2/3/4 - осн/доп без АИ/осн,доп без АИ/АИ)  
    ) IS
      SELECT src_paym.p_cover_decline_id
            ,src_paym.cover_ent_id
            ,src_paym.part_payment + CASE
               WHEN src_paym.pp_summ > cp_coef
                    AND src_paym.redemption_sum = src_paym.max_rs
                    AND src_paym.rnum = 1 THEN
                -0.01
               ELSE
                0
             END + CASE
               WHEN src_paym.pp_summ < cp_coef
                    AND src_paym.redemption_sum = src_paym.max_rs
                    AND src_paym.rnum = 1 THEN
                0.01
               ELSE
                0
             END part_payment_result
        FROM (SELECT src.*
                    ,ROUND(src.redemption_sum * cp_coef / src.rs_summ, 2) part_payment -- часть выплаты 
                    ,SUM(ROUND(src.redemption_sum * cp_coef / src.rs_summ, 2)) over() pp_summ -- сумма всех частей
                    ,row_number() over(PARTITION BY src.redemption_sum ORDER BY src.redemption_sum DESC) rnum
                FROM (SELECT cd.p_cover_decline_id
                            ,cd.ent_id cover_ent_id
                            ,cd.redemption_sum
                            ,SUM(cd.redemption_sum) over() rs_summ -- СУМвс
                            ,MAX(cd.redemption_sum) over() max_rs -- МАХвс 
                        FROM p_cover_decline     cd
                            ,p_pol_decline       pd
                            ,t_product_line      prl
                            ,t_product_line_type plt
                            ,t_prod_line_option  plo
                            ,p_cover             pc
                       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
                         AND prl.id = cd.t_product_line_id
                         AND plt.product_line_type_id = prl.product_line_type_id
                         AND plo.product_line_id = prl.id
                         AND pc.t_prod_line_option_id = plo.id
                         AND pc.as_asset_id = cd.as_asset_id
                         AND ( /*1, основные программы*/
                              cp_category = 1 AND plt.brief IN ('MANDATORY', 'RECOMMENDED') OR
                             /*2, дополнительные программы без адм. издержек*/
                              cp_category = 2 AND plt.brief = 'OPTIONAL' AND
                              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
                             /*3, основные и дополнительные программы без адм. издержек*/
                              cp_category = 3 AND plt.brief IN ('MANDATORY', 'RECOMMENDED', 'OPTIONAL') AND
                              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
                             /*4, адм. издержки*/
                              cp_category = 3 AND plt.brief = 'OPTIONAL' AND
                              (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty'))
                         AND pd.p_policy_id = cp_policy_id) src) src_paym;
  
    -- курсор для распределения средств в зависимости от значений 
    CURSOR cur_aii_for_trans
    (
      cp_policy_id NUMBER
     ,cp_coef      NUMBER -- распределяемая сумма
     ,cp_category  NUMBER -- категория программ (1/2/3/4 - осн/доп без АИ/осн,доп без АИ/АИ)                       
    ) IS
      SELECT src_paym.p_cover_decline_id
            ,src_paym.cover_ent_id
            ,src_paym.part_payment + CASE
               WHEN src_paym.pp_summ > cp_coef
                    AND src_paym.add_invest_income = src_paym.max_aii
                    AND src_paym.rnum = 1 THEN
                -0.01
               ELSE
                0
             END + CASE
               WHEN src_paym.pp_summ < cp_coef
                    AND src_paym.add_invest_income = src_paym.max_aii
                    AND src_paym.rnum = 1 THEN
                0.01
               ELSE
                0
             END part_payment_result
        FROM (SELECT src.*
                    ,ROUND(src.add_invest_income * cp_coef / src.aii_summ, 2) part_payment -- часть выплаты 
                    ,SUM(ROUND(src.add_invest_income * cp_coef / src.aii_summ, 2)) over() pp_summ -- сумма всех частей
                    ,row_number() over(PARTITION BY src.add_invest_income ORDER BY src.add_invest_income DESC) rnum
                FROM (SELECT cd.p_cover_decline_id
                            ,cd.ent_id cover_ent_id
                            ,cd.add_invest_income
                            ,SUM(cd.add_invest_income) over() aii_summ -- СУМдид
                            ,MAX(cd.add_invest_income) over() max_aii -- МАХдид
                        FROM p_cover_decline     cd
                            ,p_pol_decline       pd
                            ,t_product_line      prl
                            ,t_product_line_type plt
                            ,t_prod_line_option  plo
                            ,p_cover             pc
                       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
                         AND prl.id = cd.t_product_line_id
                         AND plt.product_line_type_id = prl.product_line_type_id
                         AND plo.product_line_id = prl.id
                         AND pc.t_prod_line_option_id = plo.id
                         AND pc.as_asset_id = cd.as_asset_id
                         AND ( /*1, основные программы*/
                              cp_category = 1 AND plt.brief IN ('MANDATORY', 'RECOMMENDED') OR
                             /*2, дополнительные программы без адм. издержек*/
                              cp_category = 2 AND plt.brief = 'OPTIONAL' AND
                              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
                             /*3, основные и дополнительные программы без адм. издержек*/
                              cp_category = 3 AND plt.brief IN ('MANDATORY', 'RECOMMENDED', 'OPTIONAL') AND
                              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
                             /*4, адм. издержки*/
                              cp_category = 3 AND plt.brief = 'OPTIONAL' AND
                              (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty'))
                         AND pd.p_policy_id = cp_policy_id) src) src_paym;
  
    -- курсор для распределения средств в зависимости от значений 
    -- ВЧП по программам
    CURSOR cur_vchp_for_trans
    (
      cp_policy_id NUMBER
     ,cp_coef      NUMBER -- распределяемая сумма
     ,cp_category  NUMBER -- категория программ (1/2/3/4 - осн/доп без АИ/осн,доп без АИ/АИ)                       
    ) IS
      SELECT src_paym.p_cover_decline_id
            ,src_paym.cover_ent_id
            ,src_paym.part_payment + CASE
               WHEN src_paym.pp_summ > cp_coef
                    AND src_paym.return_bonus_part = src_paym.max_vchp
                    AND src_paym.rnum = 1 THEN
                -0.01
               ELSE
                0
             END + CASE
               WHEN src_paym.pp_summ < cp_coef
                    AND src_paym.return_bonus_part = src_paym.max_vchp
                    AND src_paym.rnum = 1 THEN
                0.01
               ELSE
                0
             END part_payment_result
        FROM (SELECT src.*
                    ,ROUND(src.return_bonus_part * cp_coef / src.vchp_summ, 2) part_payment -- часть выплаты 
                    ,SUM(ROUND(src.return_bonus_part * cp_coef / src.vchp_summ, 2)) over() pp_summ -- сумма всех частей
                    ,row_number() over(PARTITION BY src.return_bonus_part ORDER BY src.return_bonus_part DESC) rnum
                FROM (SELECT cd.p_cover_decline_id
                            ,cd.ent_id cover_ent_id
                            ,cd.return_bonus_part
                            ,SUM(cd.return_bonus_part) over() vchp_summ -- СУМдид
                            ,MAX(cd.return_bonus_part) over() max_vchp -- МАХдид
                        FROM p_cover_decline     cd
                            ,p_pol_decline       pd
                            ,t_product_line      prl
                            ,t_product_line_type plt
                            ,t_prod_line_option  plo
                            ,p_cover             pc
                       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
                         AND prl.id = cd.t_product_line_id
                         AND plt.product_line_type_id = prl.product_line_type_id
                         AND plo.product_line_id = prl.id
                         AND pc.t_prod_line_option_id = plo.id
                         AND pc.as_asset_id = cd.as_asset_id
                         AND ( /*1, основные программы*/
                              cp_category = 1 AND plt.brief IN ('MANDATORY', 'RECOMMENDED') OR
                             /*2, дополнительные программы без адм. издержек*/
                              cp_category = 2 AND plt.brief = 'OPTIONAL' AND
                              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
                             /*3, основные и дополнительные программы без адм. издержек*/
                              cp_category = 3 AND plt.brief IN ('MANDATORY', 'RECOMMENDED', 'OPTIONAL') AND
                              NOT (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty') OR
                             /*4, адм. издержки*/
                              cp_category = 3 AND plt.brief = 'OPTIONAL' AND
                              (plo.brief LIKE ('Adm_Cost%') OR plo.brief = 'Penalty'))
                         AND pd.p_policy_id = cp_policy_id) src) src_paym;
  
    --v_dpd  NUMBER; -- ДПД
    v_nuiv NUMBER; -- Недоплата, удерживаемая из Выплаты 
    v_coef NUMBER; -- распределяемая сумма
  
  BEGIN
    OPEN cur_sums(par_policy_id, par_category);
    FETCH cur_sums
      INTO vr;
    CLOSE cur_sums;
  
    v_nuiv := CASE
                WHEN par_debt IS NULL THEN
                 vr.debt_summ -- общий по договору
                ELSE
                 par_debt -- какая-то часть для расчета проводок для N-го стакана(из параметра)
              END;
  
    -- ВС
    v_coef := least(vr.red_s_summ, v_nuiv);
    IF (vr.red_s_summ > 0 AND v_nuiv > 0)
    THEN
      -- сумма ВС >0, иначе не из чего делать вычет
      -- и недоплата не нулевая
      FOR rec_trans IN cur_rs_for_trans(par_policy_id, v_coef, par_category)
      LOOP
        IF par_target = gc_vs_target_type
        THEN
          run_oper_by_templ(par_oper_templ_name => 'Зачет ВС'
                           ,par_document_id     => par_policy_id
                           ,par_ent_id          => rec_trans.cover_ent_id
                           ,par_obj_id          => rec_trans.p_cover_decline_id
                           ,par_sum             => rec_trans.part_payment_result);
        ELSE
          NULL;
        END IF;
      END LOOP;
    END IF;
    v_nuiv := v_nuiv - v_coef;
  
    v_coef := least(vr.add_inv_inc_summ, v_nuiv);
    IF (vr.add_inv_inc_summ > 0 AND v_nuiv > 0)
    THEN
      -- сумма ДИД >0, иначе не из чего делать вычет
      -- и недоплата не нулевая
      FOR rec_trans IN cur_aii_for_trans(par_policy_id, v_coef, par_category)
      LOOP
        IF par_target = gc_did_target_type
        THEN
          run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата ДИД'
                           ,par_document_id     => par_policy_id
                           ,par_ent_id          => rec_trans.cover_ent_id
                           ,par_obj_id          => rec_trans.p_cover_decline_id
                           ,par_sum             => rec_trans.part_payment_result);
        ELSE
          NULL;
        END IF;
      END LOOP;
    END IF;
    v_nuiv := v_nuiv - v_coef;
  
    -- ВЧП  
    v_coef := least(vr.ret_bon_part_summ, v_nuiv);
    IF (vr.ret_bon_part_summ > 0 AND v_nuiv > 0)
    THEN
      -- сумма ВЧП >0, иначе не из чего делать вычет
      -- и недоплата не нулевая
      FOR rec_trans IN cur_vchp_for_trans(par_policy_id, v_coef, par_category)
      LOOP
        IF par_target = gc_vchp_target_type
        THEN
          run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата возв'
                           ,par_document_id     => par_policy_id
                           ,par_ent_id          => rec_trans.cover_ent_id
                           ,par_obj_id          => rec_trans.p_cover_decline_id
                           ,par_sum             => rec_trans.part_payment_result);
        ELSE
          NULL;
        END IF;
      END LOOP;
    END IF;
    v_nuiv := v_nuiv - v_coef;
  
    par_debt := v_nuiv; -- возвращаем остаток недоплаты
  END calc_level_and_make_op;

  -- процедура по формированию зачетов по ВС,ДИД,ВЧП
  -- вторым параметром передается целевой тип - VS, DID, VCHP
  PROCEDURE op_payment_vs_did_vchp
  (
    par_policy_id NUMBER
   ,par_target    VARCHAR2
  ) IS
    v_debt                    NUMBER := NULL;
    v_payment_proporcial_rule NUMBER;
  BEGIN
    -- определяем, будет 2 стакана, или 3
    BEGIN
      SELECT pfp.payment_proporcial_rule
        INTO v_payment_proporcial_rule
        FROM p_policy pp
        JOIN p_pol_header ph
          ON ph.policy_header_id = pp.pol_header_id
        JOIN t_policyform_product pfp
          ON pfp.t_policyform_product_id = pp.t_product_conds_id
       WHERE pp.policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_payment_proporcial_rule := 0;
    END;
  
    IF (v_payment_proporcial_rule = 0 OR v_payment_proporcial_rule IS NULL)
    THEN
      -- 3 "стакана" 
      calc_level_and_make_op(par_policy_id, 1, v_debt, par_target); -- по основным программам
      calc_level_and_make_op(par_policy_id, 2, v_debt, par_target); -- по дополнительным без адм. изд.
      calc_level_and_make_op(par_policy_id, 4, v_debt, par_target); -- адм. изд.
    ELSE
      -- 2 "стакана"
      calc_level_and_make_op(par_policy_id, 3, v_debt, par_target); -- по основным программам, по дополнительным без адм. изд.
      calc_level_and_make_op(par_policy_id, 4, v_debt, par_target); -- адм. изд.
    END IF;
  END op_payment_vs_did_vchp;

  -- Зачет ВС 
  PROCEDURE op_payment_vs(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    op_payment_vs_did_vchp(par_policy_id, gc_vs_target_type);
  END op_payment_vs;

  -- Зачтена выплата ДИД  
  PROCEDURE op_payment_did(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    op_payment_vs_did_vchp(par_policy_id, gc_did_target_type);
  END op_payment_did;

  -- Зачтена выплата возв  
  PROCEDURE op_payment_ret(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    op_payment_vs_did_vchp(par_policy_id, gc_vchp_target_type);
  END op_payment_ret;

  -- Зачет недоплаты, удерживаемой из выплаты
  PROCEDURE op_deduct_unpayment_amount(par_policy_id p_policy.policy_id%TYPE) IS
    CURSOR cur_covers(cp_policy_id NUMBER) IS
      SELECT cd.p_cover_decline_id
            ,cd.ent_id cover_ent_id
            ,cd.t_product_line_id
            ,nvl(cd.underpayment_actual, 0) /*недоплата фактическая*/
            ,nvl(cd.unpayed_premium_previous, 0) /*Начисленная премия к списанию по неоплате за прошлый период*/
            ,nvl(cd.unpayed_premium_current, 0) /*Начисленная премия к списанию по неоплате за текущий период*/
            ,nvl(cd.unpayed_premium_lp, 0) /*Начисленная премия к списанию по неоплате за льготный период*/
            ,nvl(cd.underpayment_actual, 0) - nvl(cd.unpayed_premium_previous, 0) -
             nvl(cd.unpayed_premium_current, 0) - nvl(cd.unpayed_premium_lp, 0) amount /*величина проводки*/
        FROM p_cover_decline cd
            ,p_pol_decline   pd
            ,p_policy        p
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND p.policy_id = pd.p_policy_id
         AND pd.p_policy_id = cp_policy_id
         AND NOT (nvl(p.debt_summ, 0) = 0); /*Недоплата по полису, удерживаемая из выплаты, не равна нулю*/
  BEGIN
    FOR rec IN cur_covers(par_policy_id)
    LOOP
      -- разный шаблон, в зависимости от начилия ВС по программе
      IF check_exists_r_summ_in_progr(par_policy_id, rec.t_product_line_id) = 1
      THEN
        run_oper_by_templ(par_oper_templ_name => 'Зачет ВС'
                         ,par_document_id     => par_policy_id
                         ,par_ent_id          => rec.cover_ent_id
                         ,par_obj_id          => rec.p_cover_decline_id
                         ,par_sum             => rec.amount);
      ELSE
        run_oper_by_templ(par_oper_templ_name => 'Зачтена выплата возв'
                         ,par_document_id     => par_policy_id
                         ,par_ent_id          => rec.cover_ent_id
                         ,par_obj_id          => rec.p_cover_decline_id
                         ,par_sum             => rec.amount);
      END IF;
    END LOOP;
  END;

END pkg_policy_decline_opers;
/
