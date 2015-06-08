CREATE OR REPLACE PACKAGE Pkg_Decline_veselek AS

  FUNCTION active_in_waiting_period(per_cover_id NUMBER) RETURN NUMBER;
  FUNCTION get_cover_accident_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_cover_life_per_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_cover_admin_exp_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_cover_cash_surr_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_surr_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_date          DATE
  ) RETURN Pkg_Payment.t_amount;
  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
   ,p_rules            NUMBER
   ,p_zsp_sum          OUT NUMBER
   ,p_added_sum        OUT NUMBER
   ,p_payed_sum        OUT NUMBER
   ,p_extra_profit_sum OUT NUMBER
   ,p_debt_fee_sum     OUT NUMBER
   ,p_payoff_sum       OUT NUMBER
   ,p_admin_cost_sum   OUT NUMBER
  );
  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
   ,p_rules            NUMBER
   ,p_zsp_sum          OUT NUMBER
   ,p_added_sum        OUT NUMBER
   ,p_payed_sum        OUT NUMBER
   ,p_extra_profit_sum OUT NUMBER
   ,p_debt_fee_sum     OUT NUMBER
   ,p_payoff_sum       OUT NUMBER
   ,p_admin_cost_sum   OUT NUMBER
   ,p_ag_comm_sum      OUT NUMBER
   ,p_add_exp_sum      OUT NUMBER
   ,p_prem_payoff_sum  OUT NUMBER
  );
  PROCEDURE get_undewriting_pol_year
  (
    p_pol_id     NUMBER
   ,p_date       DATE
   ,p_start_date OUT DATE
   ,p_end_date   OUT DATE
   ,p_period     NUMBER DEFAULT 12
  );

  PROCEDURE calc_decline_cover(per_cover_id NUMBER);
  PROCEDURE decline_asset_covers
  (
    p_asset_id             NUMBER
   ,p_decline_date         DATE
   ,p_decline_reason_id    NUMBER
   ,p_decline_party_id     NUMBER
   ,p_decline_initiator_id NUMBER DEFAULT NULL
   ,p_is_charge            NUMBER DEFAULT NULL
   ,p_is_comm              NUMBER DEFAULT NULL
   ,p_is_decl_payoff       NUMBER DEFAULT NULL
  );
  PROCEDURE rollback_cover_decline
  (
    per_cover_id NUMBER
   ,p_full       NUMBER DEFAULT 0
  );
END;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Decline_veselek AS

  -- В процедуры calc_decline_cover, decline_child_covers, decline_asset_covers передаутся объекты из текущей(расторгаемой версии)
  -- В функции расчета возврата - действующие

  PROCEDURE get_undewriting_pol_year
  (
    p_pol_id     NUMBER
   ,p_date       DATE
   ,p_start_date OUT DATE
   ,p_end_date   OUT DATE
   ,p_period     NUMBER DEFAULT 12
  ) IS
    v_policy P_POLICY%ROWTYPE;
  BEGIN
    SELECT * INTO v_policy FROM P_POLICY WHERE policy_id = p_pol_id;
    p_start_date := v_policy.start_date;
    p_end_date   := ADD_MONTHS(p_start_date, p_period);
    WHILE p_date > p_end_date
    LOOP
      p_start_date := p_end_date;
      p_end_date   := ADD_MONTHS(p_start_date, p_period);
    END LOOP;
    p_end_date := p_end_date - 1;
  END;
  PROCEDURE prepare_data_for_accounting
  (
    per_cover_id              NUMBER
   ,p_decl_party_brief        OUT VARCHAR2
   ,p_decl_reason_brief       OUT VARCHAR2
   ,p_waiting_period_end_date OUT DATE
   ,p_active_in_wp            OUT NUMBER
   ,p_decline_date            OUT DATE
  ) IS
  
    v_pol_header_id NUMBER;
  BEGIN
  
    SELECT dp.brief
          ,dr.brief
          ,p.WAITING_PERIOD_END_DATE
          ,p.POL_HEADER_ID
          ,c.DECLINE_DATE
      INTO p_decl_party_brief
          ,p_decl_reason_brief
          ,p_waiting_period_end_date
          ,v_pol_header_id
          ,p_decline_date
      FROM T_DECLINE_REASON dr
          ,T_DECLINE_PARTY  dp
          ,P_COVER          c
          ,AS_ASSET         a
          ,P_POLICY         p
     WHERE c.P_COVER_ID = per_cover_id
       AND a.AS_ASSET_ID = c.AS_ASSET_ID
       AND p.POLICY_ID = a.P_POLICY_ID
       AND c.DECLINE_PARTY_ID = dp.t_decline_party_id(+)
       AND c.decline_reason_id = dr.t_decline_reason_id(+);
  
    p_active_in_wp := active_in_waiting_period(per_cover_id);
  
    -- Если данных по расторжению нет на покрытии -> расторгается договор полностью,а не конкретное покрытие
    -- и данные по расторжению надо взять с договора
  
    SELECT NVL(p_decline_date, p.decline_date)
          ,NVL(p_decl_party_brief, dp.BRIEF)
          ,NVL(p_decl_reason_brief, dr.BRIEF)
      INTO p_decline_date
          ,p_decl_party_brief
          ,p_decl_reason_brief
      FROM P_POLICY         P
          ,T_DECLINE_REASON dr
          ,T_DECLINE_PARTY  dp
     WHERE p.DECLINE_PARTY_ID = dp.t_decline_party_id(+)
       AND p.decline_reason_id = dr.t_decline_reason_id(+)
       AND p.policy_id = Pkg_Policy.get_last_version(v_pol_header_id);
  
  END;
  PROCEDURE prepare_data_for_accounting
  (
    per_cover_id              NUMBER
   ,p_decl_party_brief        OUT VARCHAR2
   ,p_decl_reason_brief       OUT VARCHAR2
   ,p_waiting_period_end_date OUT DATE
   ,p_active_in_wp            OUT NUMBER
   ,p_decline_date            OUT DATE
   ,p_p_cover                 OUT P_COVER%ROWTYPE
  ) IS
  BEGIN
    SELECT * INTO p_p_cover FROM P_COVER WHERE p_cover_id = per_cover_id;
    prepare_data_for_accounting(per_cover_id
                               ,p_decl_party_brief
                               ,p_decl_reason_brief
                               ,p_waiting_period_end_date
                               ,p_active_in_wp
                               ,p_decline_date);
  END;

  FUNCTION get_cover_cash_surr_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_date          DATE
  ) RETURN Pkg_Payment.t_amount IS
    amount Pkg_Payment.t_amount;
  BEGIN
    amount.fund_amount     := Pkg_Policy_Cash_Surrender.Get_Value_C(per_cover_id, p_date);
    amount.pay_fund_amount := amount.fund_amount;
    RETURN amount;
  END;

  FUNCTION get_surr_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_date          DATE
  ) RETURN Pkg_Payment.t_amount IS
    amount Pkg_Payment.t_amount;
  BEGIN
    RETURN get_cover_cash_surr_sum(p_pol_header_id, per_cover_id, p_date);
  END;

  FUNCTION get_cover_cash_surr_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount IS
    v_decline_date            DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    amount                    Pkg_Payment.t_amount;
    v_cover                   P_COVER%ROWTYPE;
  BEGIN
    /*if p_rules = 1 then
     amount:= Pkg_Payment.get_pay_cover_amount(per_cover_id);
    else*/
    prepare_data_for_accounting(per_cover_id
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_decline_date
                               ,v_cover);
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    IF v_decline_date > v_cover.end_date
       OR v_decline_date < v_cover.start_date
    THEN
      RETURN amount;
    END IF;
  
    IF v_decline_date <= v_waiting_period_end_date
    THEN
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        IF v_active_in_wp = 1
        THEN
          RETURN get_cover_cash_surr_sum(p_pol_header_id, per_cover_id, v_decline_date);
        
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
        RETURN amount;
      END IF;
    ELSE
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        RETURN get_cover_cash_surr_sum(p_pol_header_id, per_cover_id, v_decline_date);
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN
           ('НеоплВзноса', /*'НесогласУсловия',*/ 'НевыпУслДог')
        THEN
          RETURN get_cover_cash_surr_sum(p_pol_header_id, per_cover_id, v_decline_date);
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      END IF;
    END IF;
  
    /*end if;*/
  
    RETURN amount;
  END;

  FUNCTION get_cover_accident_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount IS
    v_decline_date            DATE;
    v_start_date              DATE;
    v_end_date                DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    v_cover                   P_COVER%ROWTYPE;
    amount                    Pkg_Payment.t_amount;
    v_pay_term_brief          VARCHAR2(100);
    v_number_of_payments      NUMBER;
    v_pol_id                  NUMBER;
  BEGIN
    prepare_data_for_accounting(per_cover_id
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_decline_date
                               ,v_cover);
    SELECT policy_id INTO v_pol_id FROM P_POL_HEADER WHERE policy_header_id = p_pol_header_id;
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    IF v_decline_date > v_cover.end_date
       OR v_decline_date < v_cover.start_date
    THEN
      RETURN amount;
    END IF;
  
    /*if p_rules = 1 then
     amount:= Pkg_Payment.get_pay_cover_amount(per_cover_id);
     RETURN amount;
    else*/
  
    IF v_decline_date <= v_waiting_period_end_date
    THEN
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        IF v_active_in_wp = 1
        THEN
          SELECT brief
                ,number_of_payments
            INTO v_pay_term_brief
                ,v_number_of_payments
            FROM T_PAYMENT_TERMS pt
                ,P_POLICY        p
                ,AS_ASSET        a
                ,P_COVER         c
           WHERE pt.id = p.payment_term_id
             AND p.POLICY_ID = a.P_POLICY_ID
             AND c.as_asset_id = a.as_asset_id
             AND c.P_COVER_ID = per_cover_id;
          IF v_pay_term_brief = 'Единовременно'
          THEN
            amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
            amount.fund_amount     := amount.fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            RETURN amount;
          ELSE
            get_undewriting_pol_year(v_pol_id
                                    ,v_decline_date
                                    ,v_start_date
                                    ,v_end_date
                                    ,12 / v_number_of_payments);
            amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
            amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
          END IF;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
        RETURN amount;
      END IF;
    ELSE
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        SELECT brief
              ,number_of_payments
          INTO v_pay_term_brief
              ,v_number_of_payments
          FROM T_PAYMENT_TERMS pt
              ,P_POLICY        p
              ,AS_ASSET        a
              ,P_COVER         c
         WHERE pt.id = p.payment_term_id
           AND p.POLICY_ID = a.P_POLICY_ID
           AND c.as_asset_id = a.as_asset_id
           AND c.P_COVER_ID = per_cover_id;
        IF v_pay_term_brief = 'Единовременно'
        THEN
          amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
          amount.fund_amount     := amount.fund_amount * (v_cover.end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          amount.pay_fund_amount := amount.pay_fund_amount * (v_cover.end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          RETURN amount;
        ELSE
          get_undewriting_pol_year(v_pol_id
                                  ,v_decline_date
                                  ,v_start_date
                                  ,v_end_date
                                  ,12 / v_number_of_payments);
          amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
          amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
        END IF;
      
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSIF v_decl_reason_brief IN ('НевыпУслДог', 'НесогласУсловия')
        THEN
          SELECT brief
                ,number_of_payments
            INTO v_pay_term_brief
                ,v_number_of_payments
            FROM T_PAYMENT_TERMS pt
                ,P_POLICY        p
                ,AS_ASSET        a
                ,P_COVER         c
           WHERE pt.id = p.payment_term_id
             AND p.POLICY_ID = a.P_POLICY_ID
             AND c.as_asset_id = a.as_asset_id
             AND c.P_COVER_ID = per_cover_id;
          IF v_pay_term_brief = 'Единовременно'
          THEN
            amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
            amount.fund_amount     := amount.fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            RETURN amount;
          ELSE
            get_undewriting_pol_year(v_pol_id
                                    ,v_decline_date
                                    ,v_start_date
                                    ,v_end_date
                                    ,12 / v_number_of_payments);
          
            IF p_rules = 1
            THEN
              amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
            ELSE
              amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
              amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                        (v_cover.end_date - v_cover.start_date + 1);
              amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                        (v_cover.end_date - v_cover.start_date + 1);
            END IF;
          END IF;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      END IF;
    END IF;
    RETURN amount;
  
    /*end if;*/
  END;

  FUNCTION active_in_waiting_period(per_cover_id NUMBER) RETURN NUMBER IS
    v_is_active NUMBER;
  BEGIN
    SELECT DECODE(pl.is_active_in_waitring_period, 0, 0, 1)
      INTO v_is_active
      FROM T_PRODUCT_LINE     pl
          ,T_PROD_LINE_OPTION tplo
          ,P_COVER            pc
     WHERE pc.p_cover_id = per_cover_id
       AND pc.T_PROD_LINE_OPTION_ID = tplo.ID
       AND tplo.PRODUCT_LINE_ID = pl.ID;
    RETURN v_is_active;
  END;

  FUNCTION get_cover_admin_exp_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount IS
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    v_cover                   P_COVER%ROWTYPE;
    v_decline_date            DATE;
    amount                    Pkg_Payment.t_amount;
  BEGIN
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    prepare_data_for_accounting(per_cover_id
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_decline_date
                               ,v_cover);
  
    IF v_decl_party_brief NOT IN ('Страхователь', 'По соглашению сторон')
    THEN
      IF v_decl_reason_brief NOT IN
         ('НеоплВзноса', 'НевыпУслДог', 'НесогласУсловия')
      THEN
        amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
      
      END IF;
    END IF;
    RETURN amount;
  END;

  FUNCTION get_cover_life_per_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
   ,p_rules         NUMBER
  ) RETURN Pkg_Payment.t_amount IS
    v_start_date              DATE;
    v_end_date                DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    amount                    Pkg_Payment.t_amount;
    v_amount                  Pkg_Payment.t_amount;
    v_cover                   P_COVER%ROWTYPE;
    v_pay_term_brief          VARCHAR2(100);
    v_number_of_payments      NUMBER;
    v_decline_date            DATE;
    v_pol_id                  NUMBER;
  BEGIN
    /*if p_rules = 1 then
     amount:= Pkg_Payment.get_pay_cover_amount(per_cover_id);
    else*/
    prepare_data_for_accounting(per_cover_id
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_decline_date
                               ,v_cover);
    SELECT policy_id INTO v_pol_id FROM P_POL_HEADER WHERE policy_header_id = p_pol_header_id;
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
    IF v_decline_date > v_cover.end_date
       OR v_decline_date < v_cover.start_date
    THEN
      RETURN amount;
    END IF;
  
    IF v_decline_date <= v_waiting_period_end_date
    THEN
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        IF v_active_in_wp = 1
        THEN
          SELECT brief
                ,number_of_payments
            INTO v_pay_term_brief
                ,v_number_of_payments
            FROM T_PAYMENT_TERMS pt
                ,P_POLICY        p
                ,AS_ASSET        a
                ,P_COVER         c
           WHERE pt.id = p.payment_term_id
             AND p.POLICY_ID = a.P_POLICY_ID
             AND c.as_asset_id = a.as_asset_id
             AND c.P_COVER_ID = per_cover_id;
          IF v_pay_term_brief = 'Единовременно'
          THEN
            amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
            amount.fund_amount     := amount.fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date);
            RETURN amount;
          ELSE
            get_undewriting_pol_year(v_pol_id
                                    ,v_decline_date
                                    ,v_start_date
                                    ,v_end_date
                                    ,12 / v_number_of_payments);
            -- Сколько начислено премий и возврата(?) за данный период
            FOR acp IN (SELECT ap.*
                          FROM ac_payment ap
                              ,doc_doc    dd
                         WHERE dd.PARENT_ID = v_pol_id
                           AND dd.CHILD_ID = ap.PAYMENT_ID
                           AND TRUNC(ap.PLAN_DATE, 'DD') = TRUNC(v_start_date, 'DD'))
            LOOP
              v_amount               := Pkg_Payment.get_charge_cover_amount(per_cover_id
                                                                           ,'ACC'
                                                                           ,acp.payment_id);
              amount.fund_amount     := NVL(amount.fund_amount, 0) + NVL(v_amount.fund_amount, 0);
              amount.pay_fund_amount := NVL(amount.pay_fund_amount, 0) +
                                        NVL(v_amount.pay_fund_amount, 0);
            END LOOP;
            amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                      (v_end_date - v_start_date);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                      (v_end_date - v_start_date);
          END IF;
        
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      END IF;
    ELSE
      IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
      THEN
        SELECT brief
              ,number_of_payments
          INTO v_pay_term_brief
              ,v_number_of_payments
          FROM T_PAYMENT_TERMS pt
              ,P_POLICY        p
              ,AS_ASSET        a
              ,P_COVER         c
         WHERE pt.id = p.payment_term_id
           AND p.POLICY_ID = a.P_POLICY_ID
           AND c.as_asset_id = a.as_asset_id
           AND c.P_COVER_ID = per_cover_id;
        IF v_pay_term_brief = 'Единовременно'
        THEN
          amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
          amount.fund_amount     := amount.fund_amount * (v_cover.end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date);
          amount.pay_fund_amount := amount.pay_fund_amount * (v_cover.end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date);
          RETURN amount;
        ELSE
          get_undewriting_pol_year(v_pol_id
                                  ,v_decline_date
                                  ,v_start_date
                                  ,v_end_date
                                  ,12 / v_number_of_payments);
          FOR acp IN (SELECT ap.*
                        FROM ac_payment ap
                            ,doc_doc    dd
                       WHERE dd.PARENT_ID = v_pol_id
                         AND dd.CHILD_ID = ap.PAYMENT_ID
                         AND TRUNC(ap.PLAN_DATE, 'DD') = TRUNC(v_start_date, 'DD'))
          LOOP
            v_amount               := Pkg_Payment.get_charge_cover_amount(per_cover_id
                                                                         ,'ACC'
                                                                         ,acp.payment_id);
            amount.fund_amount     := NVL(amount.fund_amount, 0) + NVL(v_amount.fund_amount, 0);
            amount.pay_fund_amount := NVL(amount.pay_fund_amount, 0) +
                                      NVL(v_amount.pay_fund_amount, 0);
          END LOOP;
          amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                    (v_end_date - v_start_date);
          amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                    (v_end_date - v_start_date);
        END IF;
      ELSIF v_decl_party_brief IN ('Страховщик')
      THEN
        IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
        THEN
          amount.fund_amount     := 0;
          amount.pay_fund_amount := 0;
        ELSIF v_decl_reason_brief IN ('НевыпУслДог', 'НесогласУсловия')
        THEN
          SELECT brief
                ,number_of_payments
            INTO v_pay_term_brief
                ,v_number_of_payments
            FROM T_PAYMENT_TERMS pt
                ,P_POLICY        p
                ,AS_ASSET        a
                ,P_COVER         c
           WHERE pt.id = p.payment_term_id
             AND p.POLICY_ID = a.P_POLICY_ID
             AND c.as_asset_id = a.as_asset_id
             AND c.P_COVER_ID = per_cover_id;
          IF v_pay_term_brief = 'Единовременно'
          THEN
            amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
            amount.fund_amount     := amount.fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_cover.end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date);
            RETURN amount;
          ELSE
            get_undewriting_pol_year(v_pol_id
                                    ,v_decline_date
                                    ,v_start_date
                                    ,v_end_date
                                    ,12 / v_number_of_payments);
            FOR acp IN (SELECT ap.*
                          FROM ac_payment ap
                              ,doc_doc    dd
                         WHERE dd.PARENT_ID = v_pol_id
                           AND dd.CHILD_ID = ap.PAYMENT_ID
                           AND TRUNC(ap.PLAN_DATE, 'DD') = TRUNC(v_start_date, 'DD'))
            LOOP
              v_amount               := Pkg_Payment.get_charge_cover_amount(per_cover_id
                                                                           ,'ACC'
                                                                           ,acp.payment_id);
              amount.fund_amount     := NVL(amount.fund_amount, 0) + NVL(v_amount.fund_amount, 0);
              amount.pay_fund_amount := NVL(amount.pay_fund_amount, 0) +
                                        NVL(v_amount.pay_fund_amount, 0);
            END LOOP;
            amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                      (v_end_date - v_start_date);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                      (v_end_date - v_start_date);
          END IF;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      END IF;
    END IF;
  
    /*end if;*/
  
    RETURN amount;
  END;

  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
   ,p_rules            NUMBER
   ,p_zsp_sum          OUT NUMBER
   ,p_added_sum        OUT NUMBER
   ,p_payed_sum        OUT NUMBER
   ,p_extra_profit_sum OUT NUMBER
   ,p_debt_fee_sum     OUT NUMBER
   ,p_payoff_sum       OUT NUMBER
   ,p_admin_cost_sum   OUT NUMBER
   ,p_ag_comm_sum      OUT NUMBER
   ,p_add_exp_sum      OUT NUMBER
   ,p_prem_payoff_sum  OUT NUMBER
  ) IS
  BEGIN
    calc_decline_sums(p_pol_header_id
                     ,p_rules
                     ,p_zsp_sum
                     ,p_added_sum
                     ,p_payed_sum
                     ,p_extra_profit_sum
                     ,p_debt_fee_sum
                     ,p_payoff_sum
                     ,p_admin_cost_sum);
    SELECT p.AG_COMM_SUM
          ,p.ADD_EXP_SUM
          ,p.PAYOFF_SUM
      INTO p_ag_comm_sum
          ,p_add_exp_sum
          ,p_prem_payoff_sum
      FROM P_POLICY p
     WHERE p.pol_header_id = p_pol_header_id
       AND Doc.get_last_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL';
  
  END;

  -- p_payoff_sum = сумма к выплате
  -- p_prem_payoff_sum(v_payoff_sum) = сумма выплаченного возмещения!
  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
   ,p_rules            NUMBER
   ,p_zsp_sum          OUT NUMBER
   ,p_added_sum        OUT NUMBER
   ,p_payed_sum        OUT NUMBER
   ,p_extra_profit_sum OUT NUMBER
   ,p_debt_fee_sum     OUT NUMBER
   ,p_payoff_sum       OUT NUMBER
   ,p_admin_cost_sum   OUT NUMBER
  ) IS
    v_cover_prem        NUMBER := 0; -- Премия по покрытию
    v_cover_ret         NUMBER := 0; -- Возврат по покрытию
    v_cover_topay       NUMBER := 0; -- К выплате по покрытию
    v_cover_added       NUMBER := 0; -- начислено по покрытию
    v_cover_payed       NUMBER := 0; -- оплачено по покрытию
    v_debt_fee_sum      NUMBER := 0;
    v_decline_date      DATE;
    v_cancel_pol_id     NUMBER;
    v_pol_prem          NUMBER := 0;
    v_cancel_pol_ver    NUMBER := 0;
    v_decl_reason_brief VARCHAR2(100);
    v_ag_com_sum        NUMBER;
    v_add_exp_sum       NUMBER;
    v_payoff_sum        NUMBER;
    v_name_risk         VARCHAR2(200);
    v_srok              NUMBER;
    v_fund              NUMBER;
  
    v_decl_party_brief        VARCHAR(200);
    v_waiting_period_end_date DATE;
    v_active_in_wp            NUMBER;
    v_cover                   P_COVER%ROWTYPE;
  
  BEGIN
    p_zsp_sum          := 0;
    p_added_sum        := 0;
    p_payed_sum        := 0;
    p_extra_profit_sum := 0;
    p_debt_fee_sum     := 0;
    p_admin_cost_sum   := 0;
    p_payoff_sum       := 0;
    SELECT p.decline_date
          ,p.policy_id
          ,p.version_num
          ,dr.brief
          ,ph.fund_id
      INTO v_decline_date
          ,v_cancel_pol_id
          ,v_cancel_pol_ver
          ,v_decl_reason_brief
          ,v_fund
      FROM P_POLICY         p
          ,T_DECLINE_REASON dr
          ,p_pol_header     ph
     WHERE p.pol_header_id = p_pol_header_id
       AND ph.policy_header_id = p_pol_header_id
       AND Doc.get_last_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
       AND dr.t_decline_reason_id = p.decline_reason_id;
  
    FOR pol IN (SELECT p.*
                  FROM P_POLICY p
                 WHERE p.pol_header_id = p_pol_header_id
                   AND version_num = v_cancel_pol_ver - 1)
    LOOP
      FOR pc IN (SELECT pc.*
                   FROM P_COVER  pc
                       ,AS_ASSET a
                  WHERE a.as_asset_id = pc.as_asset_id
                    AND a.p_policy_id = pol.policy_id
                    AND a.status_hist_id <> Pkg_Cover.status_hist_id_del
                    AND pc.status_hist_id <> Pkg_Cover.status_hist_id_del)
      LOOP
        FOR pct IN (SELECT md.metod_func_id
                          ,pl.brief
                          ,plt.brief plt_brief
                          ,pl.description
                      FROM T_PROD_LINE_MET_DECL plmd
                          ,T_METOD_DECLINE      md
                          ,T_PROD_LINE_OPTION   plo
                          ,T_PRODUCT_LINE       pl
                          ,T_PRODUCT_LINE_TYPE  plt
                     WHERE md.t_metod_decline_id = plmd.t_prodline_metdec_met_decl_id
                       AND plmd.t_prodline_metdec_prod_line_id = plo.product_line_id
                       AND plo.id = pc.t_prod_line_option_id
                       AND pl.id = plo.product_line_id
                       AND pl.product_line_type_id = plt.product_line_type_id(+))
        LOOP
        
          prepare_data_for_accounting(pc.p_cover_id
                                     ,v_decl_party_brief
                                     ,v_decl_reason_brief
                                     ,v_waiting_period_end_date
                                     ,v_active_in_wp
                                     ,v_decline_date
                                     ,v_cover);
        
          v_srok      := extract(YEAR FROM to_date(pc.end_date, 'dd.mm.yyyy')) -
                         extract(YEAR FROM to_date(pc.start_date, 'dd.mm.yyyy'));
          v_name_risk := pct.description;
        
          --if v_fund = 122 then
        
          v_debt_fee_sum := NVL(Pkg_Payment.get_debt_cover_amount(pc.p_cover_id).fund_amount, 0);
        
          p_debt_fee_sum := p_debt_fee_sum + v_debt_fee_sum;
        
          /*if pct.metod_func_id = 4006 then
             v_cover_ret:=     NVL(Pkg_Tariff_Calc_vk.calc_fun(pct.metod_func_id,
                                   Ent.id_by_brief('P_COVER'),
                                   pc.p_cover_id,p_rules), 0);
              --v_cover_ret:= 0;                     
          else*/
          v_cover_ret := NVL(Pkg_Tariff_Calc.calc_fun(pct.metod_func_id
                                                     ,Ent.id_by_brief('P_COVER')
                                                     ,pc.p_cover_id)
                            ,0) -
                         nvl(pkg_payment.get_vzch_amount(pc.p_cover_id, 'PROLONG').fund_amount, 0);
          --end if;
        
          IF p_rules <> 2
          THEN
            p_zsp_sum := p_zsp_sum + v_cover_ret;
          END IF;
          --p_zsp_sum:= p_zsp_sum+ v_cover_ret;
          v_cover_added := NVL(Pkg_Payment.get_charge_cover_amount( /*pc.start_date,
                                                                                                   pc.end_date,*/ pc.p_cover_id, 'PROLONG')
                               .fund_amount
                              ,0) -
                           nvl(pkg_payment.get_vzch_amount(pc.p_cover_id, 'PROLONG').fund_amount, 0);
        
          p_added_sum   := p_added_sum + v_cover_added;
          v_cover_payed := NVL(Pkg_Payment.get_pay_cover_amount( /*pc.start_date,
                                                                                                   v_decline_date,*/ pc.p_cover_id)
                               .fund_amount
                              ,0) -
                           nvl(pkg_payment.get_vzch_amount(pc.p_cover_id, 'PROLONG').fund_amount, 0);
        
          p_payed_sum := p_payed_sum + v_cover_payed;
          IF pct.brief = 'ADMIN_EXPENCES'
          THEN
            p_admin_cost_sum := Pkg_Payment.get_pay_cover_amount( /*pc.start_date,
                                                                                        v_decline_date,*/
                                pc.p_cover_id).fund_amount;
          END IF;
        
          IF pct.plt_brief = 'RECOMMENDED'
          THEN
            FOR pol_decl IN (SELECT dp.brief
                                   ,p.med_cost
                               FROM T_DECLINE_PARTY dp
                                   ,P_POLICY        p
                              WHERE p.decline_party_id = dp.t_decline_party_id
                                AND Doc.get_last_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
                                AND p.version_num = pol.version_num + 1
                                AND p.pol_header_id = p_pol_header_id)
            LOOP
              IF pol_decl.brief IN ('Страхователь', 'Страховщик')
              THEN
                p_zsp_sum := p_zsp_sum - NVL(pol_decl.med_cost, 0);
              END IF;
            END LOOP;
          END IF;
        END LOOP;
        -- Запоминаем премию и возврат по покрытию
        -- v_cover_topay:= GREATEST(v_cover_ret- v_debt_fee_sum, 0);
        -- Ф.Ганичев. Е. Воинова
        v_cover_topay := v_cover_ret;
        p_payoff_sum  := p_payoff_sum + v_cover_topay;
        v_cover_prem  := pc.premium + v_cover_payed - v_cover_topay;
        v_pol_prem    := v_pol_prem + v_cover_prem;
      
        IF p_rules = 1
        THEN
        
          IF v_decl_reason_brief NOT IN ('ОтказВпредПокр', 'СообщЛожСвед')
          THEN
            IF v_name_risk IN ('ИНВЕСТ'
                              ,'ИНВЕСТ2'
                              ,'Вариант № 2'
                              ,'Смешанное страхование жизни'
                              ,'Дожитие с возвратом взносов в случае смерти'
                              ,'Дожитие с возвратом взносов в случае смерти (Дети)')
            THEN
              --Смешанное страхование жизни; Дожитие с возвратом взносов в случае смерти
              v_cover_topay := v_cover_ret;
            ELSE
              /* if nvl(round(v_cover_added,0),0) > nvl(round(v_cover_payed,0),0) then
               v_cover_topay := 0;
               v_cover_ret := 0;
              else*/
              v_cover_topay := v_cover_ret;
              --end if;
            END IF;
          END IF;
        ELSE
          IF v_decl_reason_brief IN ('ЗаявСтрахователя')
          THEN
            IF v_name_risk IN
               ('Первичное диагностирование смертельно опасного заболевания'
               ,'Инвалидность Застрахованного по любой причине (1,2 группы)'
               ,'Смерть Застрахованного по любой причине'
               ,'Смерть по любой причине'
               ,'Инвалидность Застрахованного по любой причине'
               ,'Смерть застрахованного по любой причине'
               ,'Инвалидность по любой причине'
               ,'Страхование жизни на срок'
               ,'Доп. программа №1 Первичное диагностирование смертельно опасного заболевания')
               AND v_srok > 1
            THEN
              v_cover_topay := 0;
              v_cover_ret   := 0;
            ELSIF nvl(ROUND(v_cover_added, 0), 0) > nvl(ROUND(v_cover_payed, 0), 0)
            THEN
              IF v_decline_date - v_waiting_period_end_date <= 61
              THEN
                v_cover_topay := v_cover_ret;
                p_payoff_sum  := p_payoff_sum + v_cover_topay;
                p_zsp_sum     := p_zsp_sum + v_cover_ret;
                v_cover_prem  := pc.premium + v_cover_payed - v_cover_topay;
                v_pol_prem    := v_pol_prem + v_cover_prem;
              ELSE
                v_cover_topay := 0;
                v_cover_ret   := 0;
              END IF;
            ELSE
              v_cover_topay := v_cover_ret;
              p_payoff_sum  := p_payoff_sum + v_cover_topay;
              p_zsp_sum     := p_zsp_sum + v_cover_ret;
              v_cover_prem  := pc.premium + v_cover_payed - v_cover_topay;
              v_pol_prem    := v_pol_prem + v_cover_prem;
            END IF;
          ELSE
            IF v_decl_reason_brief IN ('НеоплВзноса', 'ЗаявСтрахователя')
            THEN
              IF v_name_risk LIKE 'ИНВЕСТ%'
              THEN
                v_cover_topay := v_cover_ret;
                p_payoff_sum  := p_payoff_sum + v_cover_topay;
                p_zsp_sum     := p_zsp_sum + v_cover_ret;
                v_cover_prem  := pc.premium + v_cover_payed - v_cover_topay;
                v_pol_prem    := v_pol_prem + v_cover_prem;
              ELSE
                v_cover_topay := 0;
                v_cover_ret   := 0;
                p_payoff_sum  := p_payoff_sum + v_cover_ret;
                p_zsp_sum     := p_zsp_sum + v_cover_ret;
              END IF;
            ELSE
              /*if nvl(round(v_cover_added,0),0) > nvl(round(v_cover_payed,0),0) then
                v_cover_topay := 0;
                v_cover_ret := 0;
              else*/
              v_cover_ret  := v_cover_payed;
              p_payoff_sum := p_payoff_sum + v_cover_ret;
              p_zsp_sum    := p_zsp_sum + v_cover_ret;
              --v_debt_fee_sum:=v_cover_added-v_cover_payed;
              --p_debt_fee_sum:= p_debt_fee_sum+ v_debt_fee_sum;
            
              --end if;    
            END IF;
          
            --end if;
          
          END IF;
        END IF;
      
        FOR pc_declare IN (SELECT pc_dec.*
                             FROM P_COVER  pc_dec
                                 ,AS_ASSET a
                                 ,P_POLICY p
                            WHERE p.POL_HEADER_ID = pol.pol_header_id
                              AND Doc.get_last_doc_status_brief(p.policy_id) = 'READY_TO_CANCEL'
                              AND p.version_num = pol.version_num + 1
                              AND a.P_POLICY_ID = p.POLICY_ID
                              AND pc_dec.AS_ASSET_ID = a.AS_ASSET_ID
                              AND pc.T_PROD_LINE_OPTION_ID = pc_dec.T_PROD_LINE_OPTION_ID)
        LOOP
          UPDATE P_COVER
             SET old_premium  = pc.PREMIUM
                ,premium      = v_cover_prem
                ,decline_summ = v_cover_topay
                ,return_summ  = v_cover_ret
                ,added_summ   = v_cover_added
                ,payed_summ   = v_cover_payed
                ,debt_summ    = v_debt_fee_sum
           WHERE p_cover_id = pc_declare.P_COVER_ID;
          --dbms_output.put_line('pc_dec.P_COVER_ID = '||pc_declare.P_COVER_ID||' '||v_cover_prem);
        END LOOP;
      END LOOP;
    END LOOP;
    --p_payoff_sum:= p_zsp_sum - p_debt_fee_sum;
    p_payoff_sum := NVL(p_payoff_sum, 0);
  
    IF p_rules = 1
    THEN
    
      IF v_decl_reason_brief NOT IN ('ОтказВпредПокр', 'СообщЛожСвед')
      THEN
      
        IF nvl(p_debt_fee_sum, 0) > NVL(p_payoff_sum, 0)
        THEN
          --nvl(p_added_sum,0) > NVL(p_payed_sum, 0) then
          IF nvl(ROUND(p_added_sum, 0), 0) > nvl(ROUND(p_payed_sum, 0), 0)
          THEN
            p_payoff_sum := 0;
            p_zsp_sum    := 0;
          ELSE
            p_payoff_sum := NVL(p_payoff_sum, 0);
          END IF;
        ELSE
          p_payoff_sum := NVL(p_payoff_sum, 0) - nvl(p_debt_fee_sum, 0);
        END IF;
      
      END IF;
    
    ELSE
    
      IF v_decl_reason_brief IN ('ЗаявСтрахователя')
      THEN
        p_zsp_sum    := nvl(p_zsp_sum, 0); --nvl(p_payed_sum,0) - nvl(p_debt_fee_sum,0);
        p_payoff_sum := nvl(p_payoff_sum, 0);
        /* if nvl(p_debt_fee_sum,0) > NVL(p_payoff_sum, 0) then
              if nvl(round(p_added_sum,0),0) > nvl(round(p_payed_sum,0),0) then
               p_payoff_sum := 0;
               p_zsp_sum := 0;
              else
               p_payoff_sum:= NVL(p_payoff_sum, 0);
              end if;
        else
              p_payoff_sum:= NVL(p_payoff_sum, 0) - nvl(p_debt_fee_sum,0);
        end if;*/
      ELSE
        IF v_decl_reason_brief NOT IN ('ОтказВпредПокр'
                                      ,'СообщЛожСвед'
                                      ,'НесогласУсловия')
        THEN
          IF nvl(p_debt_fee_sum, 0) > nvl(p_payed_sum, 0)
          THEN
            p_zsp_sum    := 0;
            p_payoff_sum := 0;
          ELSE
            p_zsp_sum    := nvl(p_zsp_sum, 0); --nvl(p_payed_sum,0) - nvl(p_debt_fee_sum,0);
            p_payoff_sum := nvl(p_payoff_sum, 0); --nvl(p_payed_sum,0) - nvl(p_debt_fee_sum,0);
          END IF;
        ELSE
          p_zsp_sum    := nvl(p_zsp_sum, 0);
          p_payoff_sum := nvl(p_payoff_sum, 0);
        END IF;
      END IF;
    
    END IF;
  
    UPDATE P_POLICY
       SET premium      = v_pol_prem
          ,decline_summ = p_payoff_sum
          ,return_summ  = p_zsp_sum
          ,added_summ   = p_added_sum
          ,payed_summ   = p_payed_sum
          ,debt_summ    = p_debt_fee_sum
          ,start_date   = decline_date
          ,type_calc    = p_rules
     WHERE policy_id = v_cancel_pol_id;
  
    SELECT nvl(SUM(pc.AG_COMM_SUM), 0)
          ,nvl(SUM(pc.add_exp_sum), 0)
          ,nvl(SUM(pc.payoff_sum), 0)
      INTO v_ag_com_sum
          ,v_add_exp_sum
          ,v_payoff_sum
      FROM p_cover  pc
          ,as_asset a
     WHERE pc.AS_ASSET_ID = a.AS_ASSET_ID
       AND a.P_POLICY_ID = v_cancel_pol_id;
  
    UPDATE p_policy
       SET add_exp_sum = v_add_exp_sum
          ,ag_comm_sum = v_ag_com_sum
          ,payoff_sum  = v_payoff_sum
     WHERE policy_id = v_cancel_pol_id;
  
  END;

  PROCEDURE decline_asset_covers
  (
    p_asset_id             NUMBER
   ,p_decline_date         DATE
   ,p_decline_reason_id    NUMBER
   ,p_decline_party_id     NUMBER
   ,p_decline_initiator_id NUMBER DEFAULT NULL
   ,p_is_charge            NUMBER DEFAULT NULL
   ,p_is_comm              NUMBER DEFAULT NULL
   ,p_is_decl_payoff       NUMBER DEFAULT NULL
  ) IS
    v_n NUMBER;
  BEGIN
    BEGIN
      SELECT 1
        INTO v_n
        FROM AS_ASSET a
            ,P_POLICY p
       WHERE (p_decline_date + 1 > a.END_DATE OR p_decline_date + 1 > p.end_date OR
             p_decline_date + 1 < a.start_date OR p_decline_date + 1 < p.START_DATE)
         AND a.P_POLICY_ID = p.POLICY_ID
         AND a.AS_ASSET_ID = p_asset_id
         AND ROWNUM < 2;
      RAISE_APPLICATION_ERROR(-20100
                             ,'Дата исключения покрытий выходит за период действия объекта или версии договора');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    UPDATE P_COVER pc
       SET pc.decline_date         = p_decline_date
          ,pc.DECLINE_PARTY_ID     = p_decline_party_id
          ,pc.DECLINE_REASON_ID    = p_decline_reason_id
          ,pc.IS_DECLINE_CHARGE    = nvl(p_is_charge, 0)
          ,pc.IS_DECLINE_COMISSION = nvl(p_is_comm, 0)
          ,pc.decline_initiator_id = p_decline_initiator_id
          ,pc.IS_DECLINE_PAYOFF    = nvl(p_is_decl_payoff, 0)
     WHERE pc.AS_ASSET_ID = p_asset_id
       AND pc.STATUS_HIST_ID = Pkg_Cover.status_hist_id_curr;
    -- Считаем возврат
    FOR pc IN (SELECT *
                 FROM P_COVER
                WHERE AS_ASSET_ID = p_asset_id
                  AND STATUS_HIST_ID <> Pkg_Cover.status_hist_id_del)
    LOOP
      IF pc.STATUS_HIST_ID = Pkg_Cover.status_hist_id_curr
      THEN
        calc_decline_cover(pc.P_COVER_ID);
      END IF;
    END LOOP;
    -- Исключаем покрытия. Это сделано в отдельном цикле,т.к. при удалении ролительских удалятся и дочернии
    -- по ним возврат должен уже быть посчитан
    FOR pc IN (SELECT *
                 FROM P_COVER
                WHERE AS_ASSET_ID = p_asset_id
                  AND STATUS_HIST_ID <> Pkg_Cover.status_hist_id_del)
    LOOP
      Pkg_Cover.exclude_cover(pc.P_COVER_ID);
    END LOOP;
  
  END;

  PROCEDURE decline_child_covers(par_cover_id IN NUMBER);

  PROCEDURE rollback_cover_decline
  (
    per_cover_id NUMBER
   ,p_full       NUMBER DEFAULT 0
  ) IS
  BEGIN
    UPDATE p_cover
       SET premium = old_premium - nvl(payed_summ, 0) + nvl(added_summ, 0)
     WHERE p_cover_id = per_cover_id
       AND decline_date IS NOT NULL
       AND premium = old_premium + nvl(payed_summ, 0) - nvl(added_summ, 0);
  
    UPDATE p_cover
       SET decline_summ         = NULL
          ,return_summ          = NULL
          ,added_summ           = NULL
          ,payed_summ           = NULL
          ,debt_summ            = NULL
          ,add_exp_sum          = NULL
          ,ag_comm_sum          = NULL
          ,is_decline_charge    = decode(p_full, 1, 0, is_decline_charge)
          ,is_decline_comission = decode(p_full, 1, 0, is_decline_comission)
          ,is_decline_payoff    = decode(p_full, 1, 0, is_decline_payoff)
          ,decline_date         = decode(p_full, 1, NULL, decline_date)
          ,decline_reason_id    = decode(p_full, 1, NULL, decline_reason_id)
          ,decline_party_id     = decode(p_full, 1, NULL, decline_party_id)
          ,decline_initiator_id = decode(p_full, 1, NULL, decline_initiator_id)
     WHERE p_cover_id = per_cover_id
       AND decline_date IS NOT NULL;
  
  END;

  PROCEDURE calc_decline_cover(per_cover_id NUMBER) IS
    v_cover         P_COVER%ROWTYPE; -- Покрытие, которое расторгается
    v_cover_current P_COVER%ROWTYPE; -- Покрытие действующей версии
  
    v_debt_fee_sum NUMBER;
    v_cover_ret    NUMBER;
    v_cover_added  NUMBER;
    v_cover_payed  NUMBER;
    v_meth_func_id NUMBER;
  BEGIN
  
    decline_child_covers(per_cover_id);
    -- Если покрытие уже расторгалось, то обнулить результаты предыдущего расторжения
    rollback_cover_decline(per_cover_id);
  
    SELECT * INTO v_cover FROM P_COVER WHERE p_cover_id = per_cover_id;
  
    UPDATE p_policy
       SET decline_date      = NULL
          ,is_charge         = NULL
          ,is_comission      = NULL
          ,is_decline_payoff = NULL
     WHERE policy_id = (SELECT p.policy_id
                          FROM p_policy p
                              ,as_asset a
                         WHERE a.AS_ASSET_ID = v_cover.as_asset_id
                           AND p.POLICY_ID = a.p_policy_id);
  
    BEGIN
      SELECT *
        INTO v_cover_current
        FROM p_cover
       WHERE p_cover_id = (SELECT MAX(pc.p_cover_id)
                             FROM p_cover  pc
                                 ,p_cover  pc1
                                 ,as_asset a
                                 ,as_asset a1
                            WHERE pc.AS_ASSET_ID = a.AS_ASSET_ID
                              AND pc1.AS_ASSET_ID = a1.AS_ASSET_ID
                              AND a1.P_ASSET_HEADER_ID = a.P_ASSET_HEADER_ID
                              AND pc.T_PROD_LINE_OPTION_ID = pc1.T_PROD_LINE_OPTION_ID
                              AND pc.P_COVER_ID < per_cover_id
                              AND pc1.P_COVER_ID = per_cover_id);
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найдена действующая версия исключаемого покрытия p_cover_id=' ||
                                per_cover_id);
    END;
    SELECT md.metod_func_id
      INTO v_meth_func_id
      FROM T_PROD_LINE_MET_DECL plmd
          ,T_METOD_DECLINE      md
          ,T_PROD_LINE_OPTION   plo
          ,T_PRODUCT_LINE       pl
          ,T_PRODUCT_LINE_TYPE  plt
     WHERE md.t_metod_decline_id = plmd.t_prodline_metdec_met_decl_id
       AND plmd.t_prodline_metdec_prod_line_id = plo.product_line_id
       AND plo.id = v_cover.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND pl.product_line_type_id = plt.product_line_type_id(+);
  
    v_debt_fee_sum := NVL(Pkg_Payment.get_debt_cover_amount(per_cover_id).fund_amount, 0);
    v_cover_ret    := NVL(Pkg_Tariff_Calc.calc_fun(v_meth_func_id
                                                  ,Ent.id_by_brief('P_COVER')
                                                  ,v_cover.p_cover_id)
                         ,0);
    v_cover_added  := NVL(Pkg_Payment.get_charge_cover_amount(v_cover.p_cover_id, 'PROLONG')
                          .fund_amount
                         ,0);
    v_cover_payed  := NVL(Pkg_Payment.get_pay_cover_amount(v_cover.p_cover_id).fund_amount, 0);
  
    UPDATE P_COVER
       SET premium      = v_cover_payed - v_cover_added + old_premium
          ,decline_summ = v_cover_ret
          ,return_summ  = v_cover_ret
          ,added_summ   = v_cover_added
          ,payed_summ   = v_cover_payed
          ,debt_summ    = v_debt_fee_sum
     WHERE p_cover_id = per_cover_id;
    --  UPDATE P_POLICY p SET p.decline_summ = NVL(p.DECLINE_SUMM,0)+        v_cover_ret,
    --                                               p.return_summ =  NVL(p.return_SUMM,0)+        v_cover_ret
    --                                      WHERE p.policy_id = (SELECT a.p_policy_id FROM AS_ASSET a, P_COVER c
    --                                                                            WHERE a.AS_ASSET_ID = c.AS_ASSET_ID
    --                                                                        AND c.P_COVER_ID = per_cover_id);
  END;

  PROCEDURE decline_child_covers(par_cover_id IN NUMBER) IS
    v_parent_cover P_COVER%ROWTYPE;
  BEGIN
    SELECT pc.* INTO v_parent_cover FROM P_COVER pc WHERE pc.P_COVER_ID = par_cover_id;
    FOR pcov IN (SELECT pc.*
                   FROM P_COVER            pc
                       ,T_PROD_LINE_OPTION plo
                  WHERE pc.AS_ASSET_ID =
                        (SELECT as_asset_id FROM P_COVER WHERE p_cover_id = par_cover_id)
                    AND pc.STATUS_HIST_ID <> Pkg_Cover.status_hist_id_del
                    AND pc.T_PROD_LINE_OPTION_ID = plo.id
                    AND plo.PRODUCT_LINE_ID IN
                        (SELECT ppl.T_PROD_LINE_ID
                           FROM PARENT_PROD_LINE ppl
                          WHERE ppl.T_PARENT_PROD_LINE_ID IN
                                (SELECT plop.PRODUCT_LINE_ID
                                   FROM T_PROD_LINE_OPTION plop
                                       ,P_COVER            pcv
                                  WHERE plop.id = pcv.T_PROD_LINE_OPTION_ID
                                    AND pcv.P_COVER_ID = par_cover_id)))
    LOOP
      UPDATE P_COVER
         SET decline_date         = v_parent_cover.decline_date
            ,decline_party_id     = v_parent_cover.decline_party_id
            ,decline_reason_id    = v_parent_cover.decline_reason_id
            ,decline_initiator_id = v_parent_cover.decline_initiator_id
            ,is_decline_charge    = v_parent_cover.is_decline_charge
            ,is_decline_comission = v_parent_cover.is_decline_comission
            ,is_decline_payoff    = v_parent_cover.is_decline_payoff
       WHERE p_cover_id = pcov.p_cover_id;
      decline_child_covers(pcov.p_cover_id);
      calc_decline_cover(pcov.p_cover_id);
    END LOOP;
  END;

END;
/
