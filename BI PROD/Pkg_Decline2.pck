CREATE OR REPLACE PACKAGE Pkg_Decline2 AS

  FUNCTION active_in_waiting_period(per_cover_id NUMBER) RETURN NUMBER;
  FUNCTION Simple_proportional_return_sum(par_cover_id NUMBER) RETURN NUMBER;
  FUNCTION get_cover_accident_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_cover_life_per_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_cover_admin_exp_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN Pkg_Payment.t_amount;
  FUNCTION get_cover_cash_surr_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN Pkg_Payment.t_amount;
  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
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

  PROCEDURE calc_decline_cover
  (
    per_cover_id           NUMBER
   ,p_decline_date         DATE DEFAULT NULL
   ,p_decline_reason_id    NUMBER DEFAULT NULL
   ,p_decline_party_id     NUMBER DEFAULT NULL
   ,p_decline_initiator_id NUMBER DEFAULT NULL
   ,p_is_charge            NUMBER DEFAULT NULL
   ,p_is_comm              NUMBER DEFAULT NULL
   ,p_is_decl_payoff       NUMBER DEFAULT NULL
  );

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

  PROCEDURE decline_child_covers
  (
    par_cover_id           IN NUMBER
   ,p_decline_date         DATE DEFAULT NULL
   ,p_decline_reason_id    NUMBER DEFAULT NULL
   ,p_decline_party_id     NUMBER DEFAULT NULL
   ,p_decline_initiator_id NUMBER DEFAULT NULL
   ,p_is_charge            NUMBER DEFAULT NULL
   ,p_is_comm              NUMBER DEFAULT NULL
   ,p_is_decl_payoff       NUMBER DEFAULT NULL
  );

  /*
    Байтин А.
    
    Измененная процедура calc_decline_cover, оптимизирована для групповой заливки застрахованных
  */
  PROCEDURE calc_decline_cover_group
  (
    par_cover_id             NUMBER
   ,par_as_asset_id          NUMBER
   ,par_prod_line_option_id  NUMBER
   ,par_policy_id            NUMBER
   ,par_decline_date         DATE DEFAULT NULL
   ,par_decline_reason_id    NUMBER DEFAULT NULL
   ,par_decline_party_id     NUMBER DEFAULT NULL
   ,par_decline_initiator_id NUMBER DEFAULT NULL
   ,par_is_charge            NUMBER DEFAULT 0
   ,par_is_comm              NUMBER DEFAULT 0
   ,par_is_decl_payoff       NUMBER DEFAULT 0
  );

END;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Decline2 AS

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
    --v_policy P_POLICY%ROWTYPE;
    v_pol_h_start_date DATE;
  BEGIN
    /*      --Каткевич А.Г. теперь считаем дату от которой отсчитывать расторжение через ПГ
    SELECT due_date INTO p_end_date 
      FROM (
           SELECT vap.due_date
             FROM p_pol_header ph,
                  p_policy pp,
                  doc_doc dd,
                  ven_ac_payment vap,
                  doc_templ acpt
            WHERE ph.policy_header_id =  (SELECT max(p.POL_HEADER_ID) FROM p_policy p WHERE p.policy_id =p_pol_id)
              AND ph.policy_header_id = pp.pol_header_id
              AND pp.policy_id = dd.parent_id
              AND dd.child_id = vap.payment_id
              AND acpt.doc_templ_id = vap.doc_templ_id
              AND acpt.brief = 'PAYMENT'
              AND doc.get_doc_status_brief(vap.payment_id) = 'PAID'
            ORDER BY vap.payment_number DESC
            ) 
      WHERE ROWNUM = 1;*/
  
    /*       SELECT * 
     INTO v_policy 
     FROM P_POLICY 
    WHERE policy_id = p_pol_id;*/
  
    --Каткевич А.Г. дату будем брать сразу с начала действия ДС
    SELECT ph.start_date
      INTO v_pol_h_start_date
      FROM p_policy     pp
          ,p_pol_header ph
     WHERE pp.pol_header_id = ph.policy_header_id
       AND pp.policy_id = p_pol_id;
  
    p_start_date := v_pol_h_start_date; --v_policy.start_date;
    p_end_date   := ADD_MONTHS(p_start_date, p_period) + 0.99999; --Покрытие заканчивается в 23:59:59
  
    WHILE p_date > p_end_date
    LOOP
      p_start_date := p_end_date;
      p_end_date   := ADD_MONTHS(p_start_date, p_period);
    END LOOP;
  
    p_end_date := p_end_date - 1;
  
  END get_undewriting_pol_year;

  PROCEDURE prepare_data_for_accounting
  (
    per_cover_id              NUMBER
   ,p_decl_party_brief        OUT NOCOPY VARCHAR2
   ,p_decl_reason_brief       OUT NOCOPY VARCHAR2
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
   ,p_decl_party_brief        OUT NOCOPY VARCHAR2
   ,p_decl_reason_brief       OUT NOCOPY VARCHAR2
   ,p_waiting_period_end_date OUT DATE
   ,p_active_in_wp            OUT NUMBER
   ,p_decline_date            OUT DATE
   ,p_p_cover                 OUT NOCOPY P_COVER%ROWTYPE
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

  FUNCTION get_cover_cash_surr_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
  ) RETURN Pkg_Payment.t_amount IS
    v_decline_date            DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    amount                    Pkg_Payment.t_amount;
    v_cover                   P_COVER%ROWTYPE;
  BEGIN
  
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
  
    RETURN amount;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.03.2009 12:30:53
  -- Purpose : Простой пропорциональный расчет Прорато
  FUNCTION Simple_proportional_return_sum(par_cover_id NUMBER) RETURN NUMBER IS
    v_decline_date            DATE;
    v_start_date              DATE;
    v_end_date                DATE;
    v_waiting_period_end_date DATE;
    v_decl_reason_brief       VARCHAR2(100);
    v_decl_party_brief        VARCHAR2(100);
    v_active_in_wp            NUMBER;
    v_cover                   P_COVER%ROWTYPE;
    amount                    Pkg_Payment.t_amount;
    amt                       NUMBER;
    v_payed_amount            NUMBER;
    v_pay_term_brief          VARCHAR2(100);
    v_number_of_payments      NUMBER;
    v_pol_id                  NUMBER;
    proc_name                 VARCHAR2(30) := 'Simple_proportional_return_sum';
  BEGIN
    prepare_data_for_accounting(par_cover_id
                               ,v_decl_party_brief
                               ,v_decl_reason_brief
                               ,v_waiting_period_end_date
                               ,v_active_in_wp
                               ,v_decline_date
                               ,v_cover);
    amount.fund_amount     := 0;
    amount.pay_fund_amount := 0;
  
    SELECT policy_id
      INTO v_pol_id
      FROM p_cover  pc
          ,as_asset ass
          ,p_policy pp
     WHERE pc.p_cover_id = par_cover_id
       AND pc.As_Asset_Id = ASs.As_Asset_Id
       AND ass.p_policy_id = pp.policy_id;
    -- AND ROWNUM = 1;
  
    IF v_decl_party_brief IN ('Страхователь', 'По соглашению сторон')
    THEN
      SELECT brief
            ,number_of_payments
        INTO v_pay_term_brief
            ,v_number_of_payments
        FROM P_COVER         c
            ,AS_ASSET        a
            ,P_POLICY        p
            ,T_PAYMENT_TERMS pt
       WHERE c.P_COVER_ID = par_cover_id
         AND c.as_asset_id = a.as_asset_id
         AND p.POLICY_ID = a.P_POLICY_ID
         AND pt.ID = p.payment_term_id;
      --AND rownum=1;
    
      IF v_pay_term_brief = 'Единовременно'
      THEN
        amount := Pkg_Payment.get_pay_cover_amount(par_cover_id);
        amt    := amount.fund_amount;
        -- amount.fund_amount:= amount.fund_amount*(v_cover.end_date - v_decline_date)/(v_cover.end_date-v_cover.start_date+1);
        amt := amt * (v_cover.end_date - v_decline_date) / (v_cover.end_date - v_cover.start_date);
        --RETURN amount;
      ELSE
        get_undewriting_pol_year(v_pol_id
                                ,v_decline_date
                                ,v_start_date
                                ,v_end_date
                                ,12 / v_number_of_payments);
        --amt:= Pkg_Payment.get_pay_cover_amount_epg(v_start_date , v_end_date, par_cover_id);
        amt := Pkg_Payment.get_pay_cover_amount_epg(v_start_date, v_decline_date, par_cover_id);
        --amount.fund_amount:= amount.fund_amount*(v_end_date - v_decline_date)/(v_end_date-v_start_date+1);
        amt := amt * (v_end_date - v_decline_date) / (v_end_date - v_start_date);
      END IF;
    
    ELSIF v_decl_party_brief IN ('Страховщик')
    THEN
      IF v_decl_reason_brief IN ('НеоплВзноса', 'ВыполнОбязат')
      THEN
        amount.fund_amount     := 0;
        amount.pay_fund_amount := 0;
      ELSE
        amount := Pkg_Payment.get_pay_cover_amount(par_cover_id);
        amt    := amount.fund_amount;
      END IF;
    
    END IF;
    RETURN amt;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END Simple_proportional_return_sum;

  FUNCTION get_cover_accident_return_sum
  (
    p_pol_header_id NUMBER
   ,per_cover_id    NUMBER
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
    v_payed_amount            NUMBER;
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
           WHERE pt.ID = p.payment_term_id
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
         WHERE pt.ID = p.payment_term_id
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
          amount := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
          -- pkg_renlife_utils.tmp_log_writer('amount.found_amount 1 '||amount.fund_amount||' v_end_date '||v_end_date);
          v_payed_amount := nvl(Pkg_Payment.get_pay_cover_amount(v_cover.p_cover_id).fund_amount, 0);
        
          --Каткевич А.Г. 25,11,2008 Изменил алгоритм расчета расторжения покрытия
          --amount.fund_amount:=v_payed_amount-(amount.fund_amount*(v_decline_date-v_cover.start_date)/(v_cover.end_date-v_cover.start_date+1));
          --amount.pay_fund_amount:=v_payed_amount-(amount.fund_amount*(v_decline_date-v_cover.start_date)/(v_cover.end_date-v_cover.start_date+1));
          --Веселуха Е.В. 15-05-2009 Поспорю с изменением и оставлю прежний алгоритм
          amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                    (v_cover.end_date - v_cover.start_date + 1);
          -- pkg_renlife_utils.tmp_log_writer('amount.found_amount 2 '||amount.fund_amount);
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
            amount                 := Pkg_Payment.get_charge_cover_amount(per_cover_id, 'PROLONG');
            amount.fund_amount     := amount.fund_amount * (v_end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
            amount.pay_fund_amount := amount.pay_fund_amount * (v_end_date - v_decline_date) /
                                      (v_cover.end_date - v_cover.start_date + 1);
          END IF;
        ELSE
          amount := Pkg_Payment.get_pay_cover_amount(per_cover_id);
        END IF;
      END IF;
    END IF;
    RETURN amount;
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
           WHERE pt.ID = p.payment_term_id
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
                          FROM AC_PAYMENT ap
                              ,DOC_DOC    dd
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
         WHERE pt.ID = p.payment_term_id
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
                        FROM AC_PAYMENT ap
                            ,DOC_DOC    dd
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
        ELSIF v_decl_reason_brief IN ('НевыпУслДог' /*,'НесогласУсловия'*/)
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
    RETURN amount;
  END;

  PROCEDURE calc_decline_sums
  (
    p_pol_header_id    NUMBER
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
    v_form_type_brief   VARCHAR2(30);
    v_period            NUMBER;
    v_name_risk         VARCHAR2(100);
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
      INTO v_decline_date
          ,v_cancel_pol_id
          ,v_cancel_pol_ver
          ,v_decl_reason_brief
      FROM P_POLICY         p
          ,T_DECLINE_REASON dr
     WHERE p.pol_header_id = p_pol_header_id
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
                       AND plo.ID = pc.t_prod_line_option_id
                       AND pl.ID = plo.product_line_id
                       AND pl.product_line_type_id = plt.product_line_type_id(+))
        LOOP
        
          v_name_risk    := pct.description;
          v_debt_fee_sum := NVL(Pkg_Payment.get_debt_cover_amount(pc.p_cover_id).fund_amount, 0);
          /*
          IF        v_debt_fee_sum!=0 AND v_decl_reason_brief!='НеоплВзноса' THEN
            RAISE_APPLICATION_ERROR(-20120, 'Есть задолженность по программе '||pct.description||'.Причиной расторжения должна быть Неоплата');
          END IF;*/
          p_debt_fee_sum := p_debt_fee_sum + v_debt_fee_sum;
        
          v_cover_ret := NVL(Pkg_Tariff_Calc.calc_fun(pct.metod_func_id
                                                     ,Ent.id_by_brief('P_COVER')
                                                     ,pc.p_cover_id)
                            ,0);
        
          p_zsp_sum     := p_zsp_sum + v_cover_ret;
          v_cover_added := NVL(Pkg_Payment.get_charge_cover_amount( /*pc.start_date,
                                                                                               pc.end_date,*/ pc.p_cover_id, 'PROLONG')
                               .fund_amount
                              ,0);
        
          p_added_sum   := p_added_sum + v_cover_added;
          v_cover_payed := NVL(Pkg_Payment.get_pay_cover_amount( /*pc.start_date,
                                                                                               v_decline_date,*/ pc.p_cover_id)
                               .fund_amount
                              ,0);
        
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
      
        IF v_decl_reason_brief NOT IN ('ОтказВпредПокр', 'СообщЛожСвед')
        THEN
          IF v_name_risk IN ('ИНВЕСТ'
                            ,'ИНВЕСТ2'
                            ,'Смешанное страхование жизни'
                            ,'Дожитие с возвратом взносов в случае смерти'
                            ,'Дожитие с возвратом взносов в случае смерти (Дети)')
          THEN
            --Смешанное страхование жизни; Дожитие с возвратом взносов в случае смерти
            v_cover_topay := v_cover_ret;
          ELSE
            IF nvl(ROUND(v_cover_added, 0), 0) > nvl(ROUND(v_cover_payed, 0), 0)
            THEN
              v_cover_topay := 0;
              v_cover_ret   := 0;
            ELSE
              v_cover_topay := v_cover_ret;
            END IF;
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
  
    IF v_decl_reason_brief NOT IN ('ОтказВпредПокр', 'СообщЛожСвед')
    THEN
    
      IF nvl(p_debt_fee_sum, 0) > NVL(p_payoff_sum, 0)
      THEN
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
  
    --для продуктов КАСКО при сроке страхования < 1 года выплаты страхователю не производятся
    SELECT pft.brief
          ,MONTHS_BETWEEN(p.end_date + 1, ph.start_date)
      INTO v_form_type_brief
          ,v_period
      FROM P_POL_HEADER       ph
          ,T_PRODUCT          p
          ,T_POLICY_FORM_TYPE pft
          ,P_POLICY           p
     WHERE ph.policy_header_id = p_pol_header_id
       AND p.product_id = ph.product_id
       AND pft.t_policy_form_type_id(+) = p.t_policy_form_type_id
       AND p.policy_id = ph.policy_id;
    IF v_form_type_brief = 'Автокаско'
       AND v_period < 12
    THEN
      p_zsp_sum := 0;
    END IF;
  
    UPDATE P_POLICY
       SET premium      = v_pol_prem
          ,decline_summ = p_payoff_sum
          ,return_summ  = p_zsp_sum
          ,added_summ   = p_added_sum
          ,payed_summ   = p_payed_sum
          ,debt_summ    = p_debt_fee_sum
          ,start_date   = decline_date
     WHERE policy_id = v_cancel_pol_id;
  
    SELECT NVL(SUM(pc.AG_COMM_SUM), 0)
          ,NVL(SUM(pc.add_exp_sum), 0)
          ,NVL(SUM(pc.payoff_sum), 0)
      INTO v_ag_com_sum
          ,v_add_exp_sum
          ,v_payoff_sum
      FROM P_COVER  pc
          ,AS_ASSET a
     WHERE pc.AS_ASSET_ID = a.AS_ASSET_ID
       AND a.P_POLICY_ID = v_cancel_pol_id;
  
    UPDATE P_POLICY
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
          ,pc.IS_DECLINE_CHARGE    = NVL(p_is_charge, 0)
          ,pc.IS_DECLINE_COMISSION = NVL(p_is_comm, 0)
          ,pc.decline_initiator_id = p_decline_initiator_id
          ,pc.IS_DECLINE_PAYOFF    = NVL(p_is_decl_payoff, 0)
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
    -- На удаление передаём только родительские покрытия, так как дочерние для них удаляются автоматически.
    FOR pc IN (SELECT pc.*
                 FROM p_cover            pc
                     ,t_prod_line_option plo
                WHERE pc.as_asset_id = p_asset_id
                  AND pc.status_hist_id <> Pkg_Cover.status_hist_id_del
                  AND pc.t_prod_line_option_id = plo.id
                  AND plo.product_line_id IN
                      (SELECT ppl.t_parent_prod_line_id
                         FROM parent_prod_line ppl
                        WHERE ppl.t_parent_prod_line_id IN
                              (SELECT plop.product_line_id
                                 FROM t_prod_line_option plop
                                     ,p_cover            pcv
                                WHERE plop.id = pcv.t_prod_line_option_id
                                  AND pcv.as_asset_id = p_asset_id)))
    LOOP
      Pkg_Cover.exclude_cover(pc.P_COVER_ID);
    END LOOP;
  
  END decline_asset_covers;

  PROCEDURE rollback_cover_decline
  (
    per_cover_id NUMBER
   ,p_full       NUMBER DEFAULT 0
  ) IS
  BEGIN
    UPDATE P_COVER
       SET premium = old_premium - NVL(payed_summ, 0) + NVL(added_summ, 0)
     WHERE p_cover_id = per_cover_id
       AND decline_date IS NOT NULL
       AND premium = old_premium + NVL(payed_summ, 0) - NVL(added_summ, 0);
  
    UPDATE P_COVER
       SET decline_summ         = NULL
          ,return_summ          = NULL
          ,added_summ           = NULL
          ,payed_summ           = NULL
          ,debt_summ            = NULL
          ,add_exp_sum          = NULL
          ,ag_comm_sum          = NULL
          ,is_decline_charge    = DECODE(p_full, 1, 0, is_decline_charge)
          ,is_decline_comission = DECODE(p_full, 1, 0, is_decline_comission)
          ,is_decline_payoff    = DECODE(p_full, 1, 0, is_decline_payoff)
          ,decline_date         = DECODE(p_full, 1, NULL, decline_date)
          ,decline_reason_id    = DECODE(p_full, 1, NULL, decline_reason_id)
          ,decline_party_id     = DECODE(p_full, 1, NULL, decline_party_id)
          ,decline_initiator_id = DECODE(p_full, 1, NULL, decline_initiator_id)
     WHERE p_cover_id = per_cover_id
       AND decline_date IS NOT NULL;
  END;

  PROCEDURE calc_decline_cover
  (
    per_cover_id           NUMBER
   ,p_decline_date         DATE DEFAULT NULL
   ,p_decline_reason_id    NUMBER DEFAULT NULL
   ,p_decline_party_id     NUMBER DEFAULT NULL
   ,p_decline_initiator_id NUMBER DEFAULT NULL
   ,p_is_charge            NUMBER DEFAULT NULL
   ,p_is_comm              NUMBER DEFAULT NULL
   ,p_is_decl_payoff       NUMBER DEFAULT NULL
  ) IS
    v_cover         P_COVER%ROWTYPE; -- Покрытие, которое расторгается
    v_cover_current P_COVER%ROWTYPE; -- Покрытие действующей версии
    v_debt_fee_sum  NUMBER;
    v_cover_ret     NUMBER;
    v_cover_added   NUMBER;
    v_cover_payed   NUMBER;
    v_meth_func_id  NUMBER;
  BEGIN
    decline_child_covers(per_cover_id, p_decline_date, p_decline_reason_id, p_decline_party_id);
    -- Если покрытие уже расторгалось, то обнулить результаты предыдущего расторжения
    rollback_cover_decline(per_cover_id);
  
    SELECT * INTO v_cover FROM P_COVER WHERE p_cover_id = per_cover_id;
  
    UPDATE P_COVER
       SET decline_date         = p_decline_date
          ,DECLINE_PARTY_ID     = p_decline_party_id
          ,DECLINE_REASON_ID    = p_decline_reason_id
          ,IS_DECLINE_CHARGE    = NVL(p_is_charge, 0)
          ,IS_DECLINE_COMISSION = NVL(p_is_comm, 0)
          ,decline_initiator_id = p_decline_initiator_id
          ,IS_DECLINE_PAYOFF    = NVL(p_is_decl_payoff, 0)
     WHERE p_cover_id = per_cover_id;
  
    UPDATE P_POLICY
       SET decline_date      = NULL
          ,is_charge         = NULL
          ,is_comission      = NULL
          ,is_decline_payoff = NULL
     WHERE policy_id = (SELECT p.policy_id
                          FROM P_POLICY p
                              ,AS_ASSET a
                         WHERE a.AS_ASSET_ID = v_cover.as_asset_id
                           AND p.POLICY_ID = a.p_policy_id);
  
    BEGIN
      SELECT *
        INTO v_cover_current
        FROM P_COVER
       WHERE p_cover_id = (SELECT MAX(pc.p_cover_id)
                             FROM P_COVER  pc
                                 ,P_COVER  pc1
                                 ,AS_ASSET a
                                 ,AS_ASSET A1
                            WHERE pc.AS_ASSET_ID = a.AS_ASSET_ID
                              AND pc1.AS_ASSET_ID = A1.AS_ASSET_ID
                              AND A1.P_ASSET_HEADER_ID = a.P_ASSET_HEADER_ID
                              AND pc.T_PROD_LINE_OPTION_ID = pc1.T_PROD_LINE_OPTION_ID
                              AND pc.P_COVER_ID < per_cover_id
                              AND pc1.P_COVER_ID = per_cover_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
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
       AND plo.ID = v_cover.t_prod_line_option_id
       AND pl.ID = plo.product_line_id
       AND pl.product_line_type_id = plt.product_line_type_id(+);
  
    /* v_debt_fee_sum:= NVL(Pkg_Payment.get_debt_cover_amount(v_cover_current.p_cover_id).fund_amount, 0);
    v_cover_ret:=     NVL(Pkg_Tariff_Calc.calc_fun(v_meth_func_id,
                             Ent.id_by_brief('P_COVER'),
                             v_cover_current.p_cover_id), 0);
    v_cover_added:=  NVL(Pkg_Payment.get_charge_cover_amount(
                               v_cover_current.p_cover_id,
                               'PROLONG').fund_amount,0);
    v_cover_payed:=     NVL(Pkg_Payment.get_pay_cover_amount(
                               v_cover_current.p_cover_id).fund_amount,0);*/
    v_debt_fee_sum := NVL(Pkg_Payment.get_debt_cover_amount(per_cover_id).fund_amount, 0);
    --pkg_renlife_utils.tmp_log_writer(v_debt_fee_sum||' v_debt_fee_sum');
  
    v_cover_ret := NVL(Pkg_Tariff_Calc.calc_fun(v_meth_func_id
                                               ,Ent.id_by_brief('P_COVER')
                                               ,v_cover.p_cover_id)
                      ,0);
    --pkg_renlife_utils.tmp_log_writer(v_cover_ret||' v_cover_ret');
  
    v_cover_added := NVL(Pkg_Payment.get_charge_cover_amount(v_cover.p_cover_id, 'PROLONG').fund_amount
                        ,0);
    --pkg_renlife_utils.tmp_log_writer(v_cover_added||' v_cover_added');
  
    v_cover_payed := NVL(Pkg_Payment.get_pay_cover_amount(v_cover.p_cover_id).fund_amount, 0);
    --pkg_renlife_utils.tmp_log_writer(v_cover_payed||' v_cover_payed');
  
    UPDATE P_COVER
       SET premium      = v_cover_payed - v_cover_added + old_premium
          ,decline_summ = v_cover_ret
          ,return_summ  = v_cover_ret
          ,added_summ   = v_cover_added
          ,payed_summ   = v_cover_payed
          ,debt_summ    = v_debt_fee_sum
     WHERE p_cover_id = per_cover_id;
  END calc_decline_cover;

  PROCEDURE decline_child_covers
  (
    par_cover_id           IN NUMBER
   ,p_decline_date         DATE DEFAULT NULL
   ,p_decline_reason_id    NUMBER DEFAULT NULL
   ,p_decline_party_id     NUMBER DEFAULT NULL
   ,p_decline_initiator_id NUMBER DEFAULT NULL
   ,p_is_charge            NUMBER DEFAULT NULL
   ,p_is_comm              NUMBER DEFAULT NULL
   ,p_is_decl_payoff       NUMBER DEFAULT NULL
  ) IS
    v_parent_cover P_COVER%ROWTYPE;
  BEGIN
    SELECT pc.* INTO v_parent_cover FROM P_COVER pc WHERE pc.P_COVER_ID = par_cover_id;
  
    FOR pcov IN (SELECT pc.*
                   FROM P_COVER            pc
                       ,T_PROD_LINE_OPTION plo
                  WHERE pc.AS_ASSET_ID =
                        (SELECT as_asset_id FROM P_COVER WHERE p_cover_id = par_cover_id)
                    AND pc.STATUS_HIST_ID <> Pkg_Cover.status_hist_id_del
                    AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                    AND plo.PRODUCT_LINE_ID IN
                        (SELECT ppl.T_PROD_LINE_ID
                           FROM PARENT_PROD_LINE ppl
                          WHERE ppl.T_PARENT_PROD_LINE_ID IN
                                (SELECT plop.PRODUCT_LINE_ID
                                   FROM T_PROD_LINE_OPTION plop
                                       ,P_COVER            pcv
                                  WHERE plop.ID = pcv.T_PROD_LINE_OPTION_ID
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
    
      decline_child_covers(pcov.p_cover_id, p_decline_date, p_decline_reason_id, p_decline_party_id);
    
      calc_decline_cover(pcov.p_cover_id, p_decline_date, p_decline_reason_id, p_decline_party_id);
    
    END LOOP;
  END;

  /*
    Байтин А.
    
    Измененная процедура calc_decline_cover, оптимизирована для групповой заливки застрахованных
  */
  PROCEDURE calc_decline_cover_group
  (
    par_cover_id             NUMBER
   ,par_as_asset_id          NUMBER
   ,par_prod_line_option_id  NUMBER
   ,par_policy_id            NUMBER
   ,par_decline_date         DATE DEFAULT NULL
   ,par_decline_reason_id    NUMBER DEFAULT NULL
   ,par_decline_party_id     NUMBER DEFAULT NULL
   ,par_decline_initiator_id NUMBER DEFAULT NULL
   ,par_is_charge            NUMBER DEFAULT 0
   ,par_is_comm              NUMBER DEFAULT 0
   ,par_is_decl_payoff       NUMBER DEFAULT 0
  ) IS
    v_cover_current_id p_cover.p_cover_id%TYPE; -- Текущее покрытие
    v_debt_fee_sum     NUMBER;
    v_cover_ret        NUMBER;
    v_cover_added      NUMBER;
    v_cover_payed      NUMBER;
    v_meth_func_id     NUMBER;
  BEGIN
    /*       decline_child_covers(par_cover_id
    ,par_decline_date
    ,par_decline_reason_id
    ,par_decline_party_id);*/
    /*-------------------------------*/
    FOR pcov IN (SELECT pc.p_cover_id
                   FROM P_COVER            pc
                       ,T_PROD_LINE_OPTION plo
                  WHERE pc.AS_ASSET_ID = par_as_asset_id
                    AND pc.STATUS_HIST_ID <> Pkg_Cover.status_hist_id_del
                    AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                    AND plo.PRODUCT_LINE_ID IN
                        (SELECT ppl.T_PROD_LINE_ID
                           FROM PARENT_PROD_LINE ppl
                          WHERE ppl.T_PARENT_PROD_LINE_ID IN
                                (SELECT plop.PRODUCT_LINE_ID
                                   FROM T_PROD_LINE_OPTION plop
                                       ,P_COVER            pcv
                                  WHERE plop.ID = pcv.T_PROD_LINE_OPTION_ID
                                    AND pcv.P_COVER_ID = par_cover_id)))
    LOOP
      calc_decline_cover_group(pcov.p_cover_id
                              ,par_as_asset_id
                              ,par_prod_line_option_id
                              ,par_policy_id
                              ,par_decline_date
                              ,par_decline_reason_id
                              ,par_decline_party_id);
    
    END LOOP;
    /*-----------------------------*/
    BEGIN
      SELECT p_cover_id
        INTO v_cover_current_id
        FROM P_COVER
       WHERE p_cover_id = (SELECT MAX(pc.p_cover_id)
                             FROM P_COVER  pc
                                 ,P_COVER  pc1
                                 ,AS_ASSET a
                                 ,AS_ASSET A1
                            WHERE pc.AS_ASSET_ID = a.AS_ASSET_ID
                              AND pc1.AS_ASSET_ID = A1.AS_ASSET_ID
                              AND A1.P_ASSET_HEADER_ID = a.P_ASSET_HEADER_ID
                              AND pc.T_PROD_LINE_OPTION_ID = pc1.T_PROD_LINE_OPTION_ID
                              AND pc.P_COVER_ID < par_cover_id
                              AND pc1.P_COVER_ID = par_cover_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Не найдена действующая версия исключаемого покрытия p_cover_id=' ||
                                par_cover_id);
    END;
  
    SELECT md.metod_func_id
      INTO v_meth_func_id
      FROM T_PROD_LINE_MET_DECL plmd
          ,T_METOD_DECLINE      md
          ,T_PROD_LINE_OPTION   plo
          ,T_PRODUCT_LINE       pl
     WHERE md.t_metod_decline_id = plmd.t_prodline_metdec_met_decl_id
       AND plo.product_line_id = plmd.t_prodline_metdec_prod_line_id
       AND plo.ID = par_prod_line_option_id
       AND pl.ID = plo.product_line_id;
  
    v_debt_fee_sum := NVL(Pkg_Payment.get_debt_cover_amount(par_cover_id).fund_amount, 0);
  
    v_cover_ret := NVL(Pkg_Tariff_Calc.calc_fun(v_meth_func_id
                                               ,Ent.id_by_brief('P_COVER')
                                               ,par_cover_id)
                      ,0);
  
    v_cover_added := NVL(Pkg_Payment.get_charge_cover_amount(par_cover_id, 'PROLONG').fund_amount, 0);
  
    v_cover_payed := NVL(Pkg_Payment.get_pay_cover_amount(par_cover_id).fund_amount, 0);
  
    UPDATE P_COVER
       SET premium              = v_cover_payed - v_cover_added + old_premium
          ,decline_summ         = v_cover_ret
          ,return_summ          = v_cover_ret
          ,added_summ           = v_cover_added
          ,payed_summ           = v_cover_payed
          ,debt_summ            = v_debt_fee_sum
          ,decline_date         = par_decline_date
          ,decline_party_id     = par_decline_party_id
          ,decline_reason_id    = par_decline_reason_id
          ,is_decline_charge    = par_is_charge
          ,is_decline_comission = par_is_comm
          ,decline_initiator_id = par_decline_initiator_id
          ,is_decline_payoff    = par_is_decl_payoff
          ,add_exp_sum          = NULL
          ,ag_comm_sum          = NULL
     WHERE p_cover_id = par_cover_id;
  
    UPDATE P_POLICY
       SET decline_date      = NULL
          ,is_charge         = NULL
          ,is_comission      = NULL
          ,is_decline_payoff = NULL
     WHERE policy_id = par_policy_id;
  END calc_decline_cover_group;

END;
/
