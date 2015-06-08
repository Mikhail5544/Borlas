CREATE OR REPLACE PACKAGE PKG_POLICY_PAID_FROM_PAID IS

  -- Author  : VESELEK
  -- Created : 22.11.2012 13:19:35
  -- Purpose : Дополнительное соглашение Перевод в Оплаченный, Восстановление из Оплаченного

  TYPE COVER_VALUES IS RECORD(
     ins_amount          NUMBER
    ,age                 NUMBER
    ,sex                 VARCHAR2(1)
    ,s_koef              NUMBER
    ,k_koef              NUMBER
    ,deathrate_id        NUMBER
    ,fact_yield_rate     NUMBER
    ,n                   NUMBER
    ,t                   NUMBER
    ,netto               NUMBER
    ,brutto              NUMBER
    ,f_loading           NUMBER
    ,pc_period_id        NUMBER
    ,pc_date_end         DATE
    ,pp_fee_payment_term NUMBER
    ,fee                 NUMBER
    ,premium             NUMBER
    ,payment_term_id     NUMBER
    ,number_of_payments  NUMBER
    ,id_policy           NUMBER
    ,plt_brief           VARCHAR2(255));

  FUNCTION GET_COVER_VALUE(par_cover_id NUMBER) RETURN COVER_VALUES;
  FUNCTION CHECK_CONDITION_PAID(par_policy_id NUMBER) RETURN NUMBER;
  FUNCTION RECOUNT_TO_PAID(par_policy_id NUMBER) RETURN NUMBER;
  PROCEDURE RECOUNT_END(par_cover_id NUMBER);
  PROCEDURE RECOUNT_PEPR(par_cover_id NUMBER);
  /**/
  FUNCTION CHECK_CONDITION_RECOV(p_policy_id NUMBER) RETURN NUMBER;
  FUNCTION RECOUNT_FROM_PAID(par_policy_id NUMBER) RETURN NUMBER;
  PROCEDURE RECOVER_END
  (
    par_cover_id     NUMBER
   ,par_old_cover_id NUMBER
  );
  PROCEDURE RECOVER_PEPR
  (
    par_cover_id     NUMBER
   ,par_old_cover_id NUMBER
  );

END PKG_POLICY_PAID_FROM_PAID;
/
CREATE OR REPLACE PACKAGE BODY PKG_POLICY_PAID_FROM_PAID IS

  G_DEBUG BOOLEAN DEFAULT FALSE;

  PROCEDURE LOG
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO P_POLICY_DEBUG
        (p_policy_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_policy_id, SYSDATE, 'PKG_POLICY_PAID_FROM_PAID', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /* VESELEK
     05.12.2012
     Реквизиты покрытия
  */
  FUNCTION GET_COVER_VALUE(par_cover_id NUMBER) RETURN COVER_VALUES IS
    CURRENT_VALUE COVER_VALUES;
    proc_name     VARCHAR2(20) := 'GET_COVER_VALUE';
  
    CURSOR COV_VAL IS
      SELECT pc.ins_amount AS insurance_amount
            ,pc.insured_age AS age
            ,DECODE(pers.gender, 1, 'm', 'w') AS sex
            ,pc.s_coef
            ,pc.k_coef
            ,
             /*DECODE
             (plr.func_id,
              NULL, plr.deathrate_id,
              ins.pkg_tariff_calc.calc_fun (plr.func_id,
                                            ins.ent.id_by_brief ('P_COVER'),
                                            pc.p_cover_id
                                           )
             ) deathrate_id,*/plr.deathrate_id
            ,CASE
               WHEN ph.start_date < TO_DATE('10.04.2006', 'DD.MM.YYYY') THEN
                (CASE
                  WHEN ph.fund_id = 122 THEN
                   0.03
                  ELSE
                   pc.normrate_value
                END)
               ELSE
                pc.normrate_value
             END AS policy_fact_yield_rate
            ,MONTHS_BETWEEN(p.end_date + 1, ph.start_date) / 12 n
            ,MONTHS_BETWEEN(p.start_date, ph.start_date) / 12 t
            ,pc.tariff_netto AS p
            ,pc.tariff
            ,pc.rvb_value
            ,(CASE
               WHEN pl.description = 'Первичное диагностирование смертельно опасного заболевания' THEN
                (SELECT pr.id FROM ins.t_period pr WHERE pr.description = 'Другой')
               ELSE
                pc.period_id
             END) pc_period_id
            ,pc.end_date pc_end_date
            ,p.fee_payment_term pp_fee_payment_term
            ,pc.fee
            ,pc.premium
            ,p.payment_term_id
            ,CASE pt.number_of_payments
               WHEN 2 THEN
                0.53
               WHEN 4 THEN
                0.27
               WHEN 12 THEN
                0.09
               ELSE
                1
             END number_of_payments
            ,p.policy_id id_policy
            ,plt.brief plt_brief
        FROM ins.t_product           prod
            ,ins.p_pol_header        ph
            ,ins.p_policy            p
            ,ins.t_payment_terms     pt
            ,ins.as_asset            a
            ,ins.contact             cn
            ,ins.cn_person           pers
            ,ins.as_assured          ass
            ,ins.p_cover_11          pc_11
            ,ins.p_cover             pc
            ,ins.t_prod_line_option  plo
            ,ins.t_product_line      pl
            ,ins.t_prod_line_rate    plr
            ,ins.t_product_line_type plt
       WHERE ph.product_id = prod.product_id
         AND p.pol_header_id = ph.policy_header_id
         AND a.p_policy_id = p.policy_id
         AND p.payment_term_id = pt.ID
         AND ass.as_assured_id = a.as_asset_id
         AND cn.contact_id = ass.assured_contact_id
         AND pers.contact_id = cn.contact_id
         AND pc.as_asset_id = a.as_asset_id
         AND plr.product_line_id = pl.ID
         AND pc.t_prod_line_option_id = plo.ID
         AND pc_11.p_cover_11_id(+) = pc.p_cover_id
         AND plo.product_line_id = pl.ID
         AND pl.product_line_type_id = plt.product_line_type_id
         AND pc.p_cover_id = par_cover_id;
  
  BEGIN
    OPEN COV_VAL;
    FETCH COV_VAL
      INTO CURRENT_VALUE;
  
    RETURN CURRENT_VALUE;
  EXCEPTION
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось определить расчетные коэффициенты для покрытия.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось определить расчетные коэффициенты для покрытия.');
  END GET_COVER_VALUE;
  /**/

  /* VESELEK
     22.11.2012
     Проверка полиса при создании дополнительного соглашения Перевод в Оплаченный
  */
  FUNCTION CHECK_CONDITION_PAID(par_policy_id NUMBER) RETURN NUMBER IS
    IS_EXIST_ADDENDUM NUMBER;
    EXIST_ADDENDUM EXCEPTION;
    IS_EXIST_COVER NUMBER;
    EXIST_COVER EXCEPTION;
    IS_TERM_INS NUMBER;
    EXIST_TERM_INS EXCEPTION;
    IS_EXIST_TO_PAY NUMBER;
    EXIST_TO_PAY EXCEPTION;
    IS_PAYM_TERM NUMBER;
    PAYM_TERM EXCEPTION;
    IS_EXIST_STATE NUMBER;
    EXIST_STATE EXCEPTION;
    proc_name VARCHAR2(25) := 'CHECK_CONDITION_PAID';
  BEGIN
    /*По договору существует версия с типом «Перевод договора в оплаченный»*/
    SELECT COUNT(*)
      INTO IS_EXIST_ADDENDUM
      FROM ins.p_policy       pol
          ,ins.p_policy       pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE pol.policy_id = par_policy_id
       AND pol.pol_header_id = pp.pol_header_id
       AND d.document_id = pp.policy_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief NOT IN ('CANCEL')
       AND pp.policy_id != par_policy_id
       AND ins.pkg_policy_checks.Check_Addendum_Type(pp.policy_id, 'POLICY_TO_PAYED') = 1;
  
    IF IS_EXIST_ADDENDUM > 0
    THEN
      RAISE EXIST_ADDENDUM;
    END IF;
  
    /*Если статус Активной версии: отменен, завершен, 
    проект, готовится к расторжению, прекращен, прекращен …, к прекращению … */
    SELECT COUNT(*)
      INTO IS_EXIST_STATE
      FROM ins.p_policy       pol
          ,ins.p_pol_header   ph
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE pol.policy_id = par_policy_id
       AND pol.pol_header_id = ph.policy_header_id
       AND ph.policy_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief IN ('PROJECT'
                       ,'STOPED'
                       ,'CANCEL'
                       ,'READY_TO_CANCEL'
                       ,'QUIT'
                       ,'QUIT_REQ_QUERY'
                       ,'QUIT_REQ_GET'
                       ,'QUIT_TO_PAY'
                       ,'TO_QUIT'
                       ,'TO_QUIT_CHECK_READY'
                       ,'TO_QUIT_CHECKED');
    IF IS_EXIST_STATE > 0
    THEN
      RAISE EXIST_STATE;
    END IF;
    /*В программе не содержится риска “Дожитие застрахованного до конца срока страхования”*/
    SELECT COUNT(*)
      INTO IS_EXIST_COVER
      FROM ins.as_asset           a
          ,ins.p_cover            pc
          ,ins.t_prod_line_option opt
          ,ins.t_product_line     pl
          ,ins.status_hist        st
     WHERE a.p_policy_id = par_policy_id
       AND a.as_asset_id = pc.as_asset_id
       AND pc.t_prod_line_option_id = opt.id
       AND opt.product_line_id = pl.id
       AND EXISTS (SELECT NULL
              FROM ins.t_prod_line_opt_peril optper
                  ,ins.t_peril               per
             WHERE opt.id = optper.product_line_option_id
               AND per.id = optper.peril_id
               AND per.description =
                   'Дожитие Застрахованного лица до установленной даты или даты окончания срока страхования')
       AND pc.status_hist_id = st.status_hist_id
       AND st.brief NOT IN ('DELETED');
  
    IF IS_EXIST_COVER = 0
    THEN
      RAISE EXIST_COVER;
    END IF;
    /*Проверка срока действия договора страхования*/
    SELECT MONTHS_BETWEEN(pol.start_date, pol_ver.start_date) / 12
      INTO IS_TERM_INS
      FROM ins.p_policy pol
          ,ins.p_policy pol_ver
     WHERE pol.policy_id = par_policy_id
       AND pol.pol_header_id = pol_ver.pol_header_id
       AND pol_ver.version_num = 1;
  
    IF IS_TERM_INS < 5
    THEN
      RAISE EXIST_TERM_INS;
    END IF;
    /*Проверка оплаченных периодов*/
    SELECT COUNT(*)
      INTO IS_EXIST_TO_PAY
      FROM ins.doc_doc        dd
          ,ins.ac_payment     ac
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE dd.parent_id IN (SELECT pol1.policy_id
                              FROM ins.p_policy pol
                                  ,ins.p_policy pol1
                             WHERE pol.policy_id = par_policy_id
                               AND pol.pol_header_id = pol1.pol_header_id)
       AND dd.child_id = ac.payment_id
       AND ac.payment_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief IN ('TO_PAY')
       AND ac.plan_date <
           (SELECT pol.start_date FROM ins.p_policy pol WHERE pol.policy_id = par_policy_id);
  
    IF IS_EXIST_TO_PAY > 0
    THEN
      RAISE EXIST_TO_PAY;
    END IF;
    /**/
    SELECT COUNT(*)
      INTO IS_PAYM_TERM
      FROM ins.p_policy        pol
          ,ins.t_payment_terms trm
     WHERE pol.policy_id = par_policy_id
       AND pol.payment_term_id = trm.id
       AND trm.brief = 'Единовременно';
  
    IF IS_PAYM_TERM > 0
    THEN
      RAISE PAYM_TERM;
    END IF;
    /**/
    RETURN 1;
  
  EXCEPTION
    WHEN EXIST_ADDENDUM THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Перевод договора в оплаченный возможен не более 1-го раза в течение действия договора.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Перевод договора в оплаченный возможен не более 1-го раза в течение действия договора.');
    WHEN EXIST_STATE THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Перевод договора в оплаченный невозможен при статусах активной версии Проект, Завершен, Отменен, К прекрщению.., Прекращен..');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Перевод договора в оплаченный невозможен при статусах активной версии Проект, Завершен, Отменен, К прекрщению.., Прекращен..');
    WHEN EXIST_COVER THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Перевод договора в оплаченный возможен только для договоров с риском "Дожитие.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Перевод договора в оплаченный возможен только для договоров с риском "Дожитие.');
    WHEN EXIST_TERM_INS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Перевод договора в оплаченный возможен только для договоров, действующих на момент перевода 5 и более лет.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Перевод договора в оплаченный возможен только для договоров, действующих на момент перевода 5 и более лет.');
    WHEN EXIST_TO_PAY THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Перевод договора в оплаченный возможен только при полной оплате предыдущих периодов.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Перевод договора в оплаченный возможен только при полной оплате предыдущих периодов.');
    WHEN PAYM_TERM THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Перевод договора с единовременной периодичностью уплаты взносов в оплаченный запрещен.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Перевод договора с единовременной периодичностью уплаты взносов в оплаченный запрещен.');
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name);
      RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении ' || proc_name);
  END CHECK_CONDITION_PAID;
  /* VESELEK
     22.11.2012
     Пересчет полиса при создании дополнительного соглашения Перевод в Оплаченный
  */
  FUNCTION RECOUNT_TO_PAID(par_policy_id NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(15) := 'RECOUNT_TO_PAID';
    NOEXIST_RECOUNT EXCEPTION;
  BEGIN
  
    FOR CUR_PC IN (SELECT pc.p_cover_id
                         ,opt.description prog_name
                     FROM ins.as_asset           a
                         ,ins.p_cover            pc
                         ,ins.t_prod_line_option opt
                         ,ins.t_product_line     pl
                         ,ins.status_hist        st
                    WHERE a.p_policy_id = par_policy_id
                      AND a.as_asset_id = pc.as_asset_id
                      AND pc.t_prod_line_option_id = opt.id
                      AND opt.product_line_id = pl.id
                      AND NOT EXISTS (SELECT NULL
                             FROM ins.t_prod_line_opt_peril optper
                                 ,ins.t_peril               per
                            WHERE opt.id = optper.product_line_option_id
                              AND per.id = optper.peril_id
                              AND per.description IN
                                  ('Дожитие Застрахованного лица до установленной даты или даты окончания срока страхования'))
                      AND st.status_hist_id = pc.status_hist_id
                      AND st.brief NOT IN ('DELETED')
                      AND opt.description NOT IN ('Не страховые убытки'))
    LOOP
      ins.pkg_cover.exclude_cover(cur_pc.p_cover_id);
    END LOOP;
  
    FOR CUR_PROG IN (SELECT (CASE
                              WHEN opt.description = 'Смешанное страхование жизни' THEN
                               'COUNT_END'
                              WHEN opt.description IN
                                   ('ИНВЕСТ', 'ИНВЕСТ2', 'ИНВЕСТ2_1') THEN
                               'COUNT_INVEST'
                              WHEN opt.description IN
                                   ('Дожитие с возвратом взносов'
                                   ,'Дожитие с возвратом взносов в случае смерти'
                                   ,'Дожитие с возвратом взносов в случае смерти (Дети)'
                                   ,'Дожитие Застрахованного до даты окончания действия договора'
                                   ,'Дожитие Застрахованного до окончания срока действия договора страхования с возвратом страховых взносов в случае смерти') THEN
                               'COUNT_PEPR'
                              ELSE
                               'NONE'
                            END) count_brief
                           ,pc.p_cover_id
                       FROM ins.p_policy           pol
                           ,ins.as_asset           a
                           ,ins.p_cover            pc
                           ,ins.t_prod_line_option opt
                           ,ins.status_hist        st
                      WHERE pol.policy_id = par_policy_id
                        AND pol.policy_id = a.p_policy_id
                        AND a.as_asset_id = pc.as_asset_id
                        AND pc.t_prod_line_option_id = opt.id
                        AND st.status_hist_id = pc.status_hist_id
                        AND st.brief != 'DELETED'
                        AND opt.description NOT IN ('Не страховые убытки'))
    LOOP
    
      IF cur_prog.count_brief = 'COUNT_END'
      THEN
        ins.pkg_pol_cash_surr_method.SET_METOD_F_T(par_policy_id, 2);
        INS.PKG_POLICY_PAID_FROM_PAID.RECOUNT_END(cur_prog.p_cover_id);
      ELSIF cur_prog.count_brief IN ('COUNT_INVEST', 'COUNT_PEPR')
      THEN
        ins.pkg_pol_cash_surr_method.SET_METOD_F_T(par_policy_id, 2);
        INS.PKG_POLICY_PAID_FROM_PAID.RECOUNT_PEPR(cur_prog.p_cover_id);
      ELSE
        RAISE NOEXIST_RECOUNT;
      END IF;
    
    END LOOP;
  
    RETURN 1;
  
  EXCEPTION
    WHEN NOEXIST_RECOUNT THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Нет необходимого риска для пересчета.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Нет необходимого риска для пересчета.');
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось выполнить пересчет программ. Пожалуйста, проверьте конфигурацию пакета программ последней версии по договору.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось выполнить пересчет программ. Пожалуйста, проверьте конфигурацию пакета программ последней версии по договору.');
  END RECOUNT_TO_PAID;
  /* VESELEK
     05.12.2012
     Пересчет программы Смешанное страхование
  */
  PROCEDURE RECOUNT_END(par_cover_id NUMBER) IS
    proc_name        VARCHAR2(15) := 'RECOUNT_END';
    v_Axn            NUMBER := 0;
    v_a_xn           NUMBER := 0;
    par_new_s        NUMBER := 0;
    par_paym_term_id NUMBER;
    par_values       INS.PKG_POLICY_PAID_FROM_PAID.COVER_VALUES;
  BEGIN
    par_values := INS.PKG_POLICY_PAID_FROM_PAID.GET_COVER_VALUE(par_cover_id);
    v_Axn      := ins.pkg_amath.Axn(par_values.age + par_values.t
                                   ,par_values.n - par_values.t
                                   ,par_values.sex
                                   ,par_values.k_koef
                                   ,par_values.s_koef
                                   ,par_values.deathrate_id
                                   ,par_values.fact_yield_rate);
  
    v_a_xn := ins.pkg_amath.a_xn(par_values.age + par_values.t
                                ,par_values.n - par_values.t
                                ,par_values.sex
                                ,par_values.k_koef
                                ,par_values.s_koef
                                ,1
                                ,par_values.deathrate_id
                                ,par_values.fact_yield_rate);
    IF par_values.number_of_payments = 1
    THEN
      par_new_s := par_values.ins_amount -
                   ((par_values.netto * par_values.ins_amount) * v_a_xn / v_Axn);
    ELSE
      par_new_s := (par_values.ins_amount - ((par_values.fee / par_values.number_of_payments) *
                   (1 - par_values.f_loading)) * v_a_xn / v_Axn);
    END IF;
    /*PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.age = ' || par_values.age);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.t = ' || par_values.t);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.n = ' || par_values.n);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.sex = ' || par_values.sex);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.deathrate_id = ' || par_values.deathrate_id);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.fact_yield_rate = ' || par_values.fact_yield_rate);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.ins_amount = ' || par_values.ins_amount);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_values.netto = ' || par_values.netto);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('v_a_xn = ' || v_a_xn);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('v_Axn = ' || v_Axn);
    PKG_FORMS_MESSAGE.PUT_MESSAGE('par_new_s = ' || par_new_s);
    RETURN;*/
  
    SELECT trm.id
      INTO par_paym_term_id
      FROM ins.t_payment_terms trm
     WHERE trm.description = 'Единовременно';
  
    UPDATE ins.p_policy pol
       SET pol.payment_term_id = par_paym_term_id
     WHERE EXISTS (SELECT NULL
              FROM ins.as_asset a
                  ,ins.p_cover  pc
             WHERE a.p_policy_id = pol.policy_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = par_cover_id);
  
    UPDATE ins.p_cover p
       SET p.ins_amount            = FLOOR(par_new_s)
          ,p.fee                   = par_values.fee
          ,p.premium               = par_values.fee
          ,p.is_handchange_amount  = 1
          ,p.is_handchange_tariff  = 1
          ,p.is_handchange_fee     = 1
          ,p.is_handchange_premium = 1
     WHERE p.p_cover_id = par_cover_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось пересчитать END.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось пересчитать END.');
  END RECOUNT_END;
  /* VESELEK
     05.12.2012
     Пересчет программы Будущее, Дети - Дожитие
  */
  PROCEDURE RECOUNT_PEPR(par_cover_id NUMBER) IS
    proc_name        VARCHAR2(15) := 'RECOUNT_PEPR';
    v_IA1xn          NUMBER := 0;
    v_a_xn           NUMBER := 0;
    v_nEx            NUMBER := 0;
    Bt               NUMBER := 0;
    par_new_s        NUMBER := 0;
    par_values       INS.PKG_POLICY_PAID_FROM_PAID.COVER_VALUES;
    par_paym_term_id NUMBER;
  BEGIN
    par_values := INS.PKG_POLICY_PAID_FROM_PAID.GET_COVER_VALUE(par_cover_id);
    v_a_xn     := ins.pkg_amath.a_xn(par_values.age + par_values.t
                                    ,par_values.n - par_values.t
                                    ,par_values.sex
                                    ,par_values.k_koef
                                    ,par_values.s_koef
                                    ,1
                                    ,par_values.deathrate_id
                                    ,par_values.fact_yield_rate);
    v_IA1xn    := ROUND(ins.pkg_AMATH.IAx1n(par_values.age + par_values.t
                                           ,par_values.n - par_values.t
                                           ,par_values.sex
                                           ,par_values.k_koef
                                           ,par_values.s_koef
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                       ,10);
    v_nEx      := ROUND(ins.pkg_AMATH.nEx(par_values.age + par_values.t
                                         ,par_values.n - par_values.t
                                         ,par_values.sex
                                         ,par_values.k_koef
                                         ,par_values.s_koef
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                       ,10);
  
    Bt        := v_IA1xn - (1 - par_values.f_loading) * v_a_xn;
    par_new_s := par_values.ins_amount + ((par_values.brutto * par_values.ins_amount) * Bt / v_nEx);
  
    SELECT trm.id
      INTO par_paym_term_id
      FROM ins.t_payment_terms trm
     WHERE trm.description = 'Единовременно';
  
    UPDATE ins.p_policy pol
       SET pol.payment_term_id = par_paym_term_id
     WHERE EXISTS (SELECT NULL
              FROM ins.as_asset a
                  ,ins.p_cover  pc
             WHERE a.p_policy_id = pol.policy_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = par_cover_id);
  
    UPDATE ins.p_cover p
       SET p.ins_amount            = par_new_s
          ,p.fee                   = par_values.fee
          ,p.premium               = par_values.fee
          ,p.is_handchange_amount  = 1
          ,p.is_handchange_tariff  = 1
          ,p.is_handchange_fee     = 1
          ,p.is_handchange_premium = 1
     WHERE p.p_cover_id = par_cover_id;
  EXCEPTION
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось пересчитать PEPR.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось пересчитать PEPR.');
  END RECOUNT_PEPR;
  /* VESELEK
     06.12.2012
     Проверка полиса при создании дополнительного соглашения Восстановление из Оплаченного
  */
  FUNCTION CHECK_CONDITION_RECOV(p_policy_id NUMBER) RETURN NUMBER IS
    IS_EXIST_PAID NUMBER;
    EXIST_PAID EXCEPTION;
    IS_EXIST_ADDENDUM NUMBER;
    EXIST_ADDENDUM EXCEPTION;
    proc_name VARCHAR2(25) := 'CHECK_CONDITION_RECOV';
  BEGIN
    /*По договору существует версия с типом «Перевод договора в оплаченный»*/
    SELECT COUNT(*)
      INTO IS_EXIST_PAID
      FROM ins.p_policy       pol
          ,ins.p_policy       pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE pol.policy_id = p_policy_id
       AND pol.pol_header_id = pp.pol_header_id
       AND d.document_id = pp.policy_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief NOT IN ('CANCEL')
       AND pp.policy_id != p_policy_id
       AND ins.pkg_policy_checks.Check_Addendum_Type(pp.policy_id, 'POLICY_TO_PAYED') = 1;
  
    IF IS_EXIST_PAID = 0
    THEN
      RAISE EXIST_PAID;
    END IF;
    /*По договору существует версия с типом «Восстановление из оплаченного»*/
    SELECT COUNT(*)
      INTO IS_EXIST_ADDENDUM
      FROM ins.p_policy       pol
          ,ins.p_policy       pp
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE pol.policy_id = p_policy_id
       AND pol.pol_header_id = pp.pol_header_id
       AND d.document_id = pp.policy_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief NOT IN ('CANCEL')
       AND pp.policy_id != p_policy_id
       AND ins.pkg_policy_checks.Check_Addendum_Type(pp.policy_id, 'POLICY_FROM_PAYED') = 1;
  
    IF IS_EXIST_ADDENDUM > 0
    THEN
      RAISE EXIST_ADDENDUM;
    END IF;
    /**/
    RETURN 1;
  
  EXCEPTION
    WHEN EXIST_PAID THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Восстановление полиса из оплаченного возможен только после перевода в оплаченный.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Восстановление полиса из оплаченного возможен только после перевода в оплаченный.');
    WHEN EXIST_ADDENDUM THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! По договору невозможно создать более одной версии с типом «Восстановление полиса из оплаченного».');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! По договору невозможно создать более одной версии с типом «Восстановление полиса из оплаченного».');
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name);
      RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении ' || proc_name);
  END CHECK_CONDITION_RECOV;
  /* VESELEK
     06.12.2012
     Пересчет полиса при создании дополнительного соглашения Восстановление из Оплаченного
  */
  FUNCTION RECOUNT_FROM_PAID(par_policy_id NUMBER) RETURN NUMBER IS
    proc_name VARCHAR2(25) := 'RECOUNT_FROM_PAID';
    NOEXIST_RECOUNT EXCEPTION;
    l_cover_id     NUMBER;
    p_period_id    NUMBER;
    p_part         NUMBER;
    l_tariff_netto NUMBER;
    l_loading      NUMBER;
    l_normrate     NUMBER;
    l_tariff       NUMBER;
    l_fee          NUMBER;
  BEGIN
  
    SELECT pr.id INTO p_period_id FROM ins.t_period pr WHERE pr.description = 'Другой';
  
    FOR CUR_PROG IN (SELECT (CASE
                              WHEN opt.description = 'Смешанное страхование жизни' THEN
                               'RECOV_END'
                              WHEN opt.description IN
                                   ('ИНВЕСТ', 'ИНВЕСТ2', 'ИНВЕСТ2_1') THEN
                               'RECOV_INVEST'
                              WHEN opt.description IN
                                   ('Дожитие с возвратом взносов'
                                   ,'Дожитие с возвратом взносов в случае смерти'
                                   ,'Дожитие с возвратом взносов в случае смерти (Дети)'
                                   ,'Дожитие Застрахованного до даты окончания действия договора'
                                   ,'Дожитие Застрахованного до окончания срока действия договора страхования с возвратом страховых взносов в случае смерти') THEN
                               'RECOV_PEPR'
                              ELSE
                               'NONE'
                            END) count_brief
                           ,pc.p_cover_id
                           ,(SELECT pca.p_cover_id
                               FROM ins.p_policy           pol
                                   ,ins.p_policy           pp
                                   ,ins.document           d
                                   ,ins.doc_status_ref     rf
                                   ,ins.p_policy           p
                                   ,ins.as_asset           aa
                                   ,ins.p_cover            pca
                                   ,ins.t_prod_line_option opta
                              WHERE pol.policy_id = par_policy_id
                                AND pol.pol_header_id = pp.pol_header_id
                                AND d.document_id = pp.policy_id
                                AND d.doc_status_ref_id = rf.doc_status_ref_id
                                AND rf.brief NOT IN ('CANCEL')
                                AND pp.policy_id != par_policy_id
                                AND ins.pkg_policy_checks.Check_Addendum_Type(pp.policy_id
                                                                             ,'POLICY_TO_PAYED') = 1
                                AND p.pol_header_id = pol.pol_header_id
                                AND p.policy_id = aa.p_policy_id
                                AND p.policy_id = pp.prev_ver_id
                                AND aa.as_asset_id = pca.as_asset_id
                                AND pca.t_prod_line_option_id = opta.id
                                AND opta.product_line_id = opt.product_line_id
                                AND opta.description NOT IN ('Не страховые убытки')) old_p_cover_id
                       FROM ins.p_policy            pol
                           ,ins.as_asset            a
                           ,ins.p_cover             pc
                           ,ins.t_prod_line_option  opt
                           ,ins.status_hist         st
                           ,ins.t_product_line      pl
                           ,ins.t_product_line_type plt
                      WHERE pol.policy_id = par_policy_id
                        AND pol.policy_id = a.p_policy_id
                        AND a.as_asset_id = pc.as_asset_id
                        AND pc.t_prod_line_option_id = opt.id
                        AND st.status_hist_id = pc.status_hist_id
                        AND st.brief != 'DELETED'
                        AND opt.description NOT IN ('Не страховые убытки')
                        AND opt.product_line_id = pl.id
                        AND pl.product_line_type_id = plt.product_line_type_id
                        AND (plt.brief = 'RECOMMENDED' OR
                            pl.description IN ('ИНВЕСТ', 'ИНВЕСТ2')))
    LOOP
    
      IF cur_prog.count_brief = 'RECOV_END'
      THEN
        ins.pkg_pol_cash_surr_method.SET_METOD_F_T(par_policy_id, 2);
        INS.PKG_POLICY_PAID_FROM_PAID.RECOVER_END(cur_prog.p_cover_id, cur_prog.old_p_cover_id);
      ELSIF cur_prog.count_brief IN ('RECOV_INVEST', 'RECOV_PEPR')
      THEN
        ins.pkg_pol_cash_surr_method.SET_METOD_F_T(par_policy_id, 2);
        INS.PKG_POLICY_PAID_FROM_PAID.RECOVER_PEPR(cur_prog.p_cover_id, cur_prog.old_p_cover_id);
      ELSE
        RAISE NOEXIST_RECOUNT;
      END IF;
    
    END LOOP;
  
    /*Поиск версии, с которой возьмем отключенные ранее риски*/
    FOR CUR_RECOVER IN (SELECT ac.*
                              ,(SELECT pc.ins_amount
                                  FROM ins.p_policy            poli
                                      ,ins.as_asset            asi
                                      ,ins.p_cover             pc
                                      ,ins.t_prod_line_option  opt
                                      ,ins.t_product_line      pl
                                      ,ins.t_product_line_type lt
                                      ,ins.status_hist         st
                                      ,ins.document            d
                                      ,ins.doc_status_ref      rf
                                 WHERE 1 = 1
                                   AND poli.pol_header_id = pol.pol_header_id
                                   AND ins.pkg_policy_checks.Check_Addendum_Type(poli.policy_id
                                                                                ,'POLICY_FROM_PAYED') = 1
                                   AND poli.policy_id = asi.p_policy_id
                                   AND pc.as_asset_id = asi.as_asset_id
                                   AND pc.t_prod_line_option_id = opt.id
                                   AND opt.product_line_id = pl.id
                                   AND pl.product_line_type_id = lt.product_line_type_id
                                   AND lt.brief = 'RECOMMENDED'
                                   AND st.status_hist_id = pc.status_hist_id
                                   AND st.brief != 'DELETED'
                                   AND poli.policy_id = d.document_id
                                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                                   AND rf.brief != 'CANCEL') rec_ins_amount
                          FROM ins.p_policy           pol
                              ,ins.p_policy           pp
                              ,ins.document           d_pp
                              ,ins.doc_status_ref     rf_pp
                              ,ins.as_asset           a
                              ,ins.v_asset_cover_life ac
                        /*'Первичное диагностирование смертельно опасного заболевания'*/
                         WHERE ins.pkg_policy_checks.Check_Addendum_Type(pp.policy_id
                                                                        ,'POLICY_TO_PAYED') = 1
                           AND pol.pol_header_id = pp.pol_header_id
                           AND pol.policy_id = par_policy_id
                           AND pp.policy_id = d_pp.document_id
                           AND d_pp.doc_status_ref_id = rf_pp.doc_status_ref_id
                           AND rf_pp.brief != 'CANCEL'
                           AND pp.policy_id = a.p_policy_id
                           AND ac.sh_brief = 'DELETED'
                           AND ac.as_asset_id = a.as_asset_id
                           AND ac.product_line_id NOT IN
                               (SELECT pl.id
                                  FROM ins.t_product_line pl
                                 WHERE pl.description IN ('ИНВЕСТ', 'ИНВЕСТ2'))
                         ORDER BY ac.pl_sort_order)
    LOOP
      BEGIN
        SELECT pc.ins_amount / (SELECT pc.ins_amount
                                  FROM ins.p_cover             pc
                                      ,ins.t_prod_line_option  opt
                                      ,ins.t_product_line      pl
                                      ,ins.t_product_line_type lt
                                      ,ins.status_hist         st
                                 WHERE 1 = 1
                                   AND pc.as_asset_id = a.as_asset_id
                                   AND pc.t_prod_line_option_id = opt.id
                                   AND opt.product_line_id = pl.id
                                   AND pl.product_line_type_id = lt.product_line_type_id
                                   AND lt.brief = 'RECOMMENDED'
                                   AND st.status_hist_id = pc.status_hist_id
                                   AND st.brief != 'DELETED')
          INTO p_part
          FROM ins.p_policy       pol
              ,ins.p_policy       pp
              ,ins.document       d
              ,ins.doc_status_ref rf
              ,ins.p_policy       pol_cur
              ,ins.as_asset       a
              ,ins.p_cover        pc
         WHERE pol.policy_id = par_policy_id
           AND pol.pol_header_id = pp.pol_header_id
           AND ins.pkg_policy_checks.Check_Addendum_Type(pp.policy_id, 'POLICY_TO_PAYED') = 1
           AND pp.policy_id = d.document_id
           AND d.doc_status_ref_id = rf.doc_status_ref_id
           AND rf.brief != 'CANCEL'
           AND pol_cur.pol_header_id = pp.pol_header_id
           AND pol_cur.policy_id = (SELECT MAX(p.policy_id)
                                      FROM ins.p_policy       p
                                          ,ins.document       dp
                                          ,ins.doc_status_ref rfd
                                     WHERE p.pol_header_id = pp.pol_header_id
                                       AND p.version_num < pp.version_num
                                       AND p.policy_id = dp.document_id
                                       AND dp.doc_status_ref_id = rfd.doc_status_ref_id
                                       AND rfd.brief != 'CANCEL')
           AND pol_cur.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = CUR_RECOVER.T_PROD_LINE_OPTION_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_part := 1;
      END;
    
      FOR CUR_ASSET IN (SELECT aa.as_asset_id
                              ,pol.start_date
                              ,pol.end_date
                          FROM ins.as_asset aa
                              ,ins.p_policy pol
                         WHERE aa.p_policy_id = par_policy_id
                           AND aa.p_policy_id = pol.policy_id)
      LOOP
        l_cover_id := ins.pkg_cover.create_cover(par_as_asset_id          => CUR_ASSET.AS_ASSET_ID
                                                ,par_prod_line_option_id  => CUR_RECOVER.T_PROD_LINE_OPTION_ID
                                                ,par_period_id            => (CASE
                                                                               WHEN CUR_RECOVER.LIFE_PROPERTY = 1 THEN
                                                                                p_period_id
                                                                               ELSE
                                                                                CUR_RECOVER.Period_Id
                                                                             END)
                                                ,par_insured_age          => CUR_RECOVER.Insured_Age
                                                ,par_start_date           => CUR_ASSET.Start_Date
                                                ,par_end_date             => (CASE
                                                                               WHEN CUR_RECOVER.LIFE_PROPERTY = 1 THEN
                                                                                CUR_RECOVER.End_Date
                                                                               ELSE
                                                                                ADD_MONTHS(CUR_ASSET.Start_Date, 12) - 1 / 24 / 3600
                                                                             END)
                                                ,par_ins_price            => CUR_RECOVER.Ins_Price
                                                ,par_ins_amount           => CUR_RECOVER.rec_ins_amount *
                                                                             p_part
                                                ,par_fee                  => CUR_RECOVER.Fee
                                                ,par_premium              => CUR_RECOVER.Fee
                                                ,par_is_autoprolongation  => CUR_RECOVER.Is_Avtoprolongation
                                                ,par_accum_period_end_age => CUR_RECOVER.Accum_Period_End_Age
                                                ,par_status_hist_id       => 1);
        l_loading      := ins.pkg_cover.calc_loading(l_cover_id);
        l_normrate     := ins.pkg_ProductLifeProperty.Calc_Normrate_Value(l_cover_id);
        l_tariff_netto := ins.pkg_cover.calc_tariff_netto(l_cover_id);
        l_tariff       := ins.pkg_cover.calc_tariff(l_cover_id);
        l_fee          := ins.pkg_cover.calc_fee(l_cover_id);
        UPDATE ins.p_cover pc
           SET pc.tariff_netto   = l_tariff_netto
              ,pc.tariff         = l_tariff
              ,pc.normrate_value = l_normrate
              ,pc.rvb_value      = l_loading
              ,pc.fee            = l_fee
         WHERE pc.p_cover_id = l_cover_id;
        /*l_cover_coef := pkg_tariff.calc_cover_coef(l_cover_id);*/
      END LOOP;
    END LOOP;
  
    /**/
    RETURN 1;
  
  EXCEPTION
    WHEN NOEXIST_RECOUNT THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Нет необходимого риска для пересчета.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! Нет необходимого риска для пересчета.');
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось выполнить пересчет программ. Пожалуйста, проверьте конфигурацию пакета программ последней версии по договору.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось выполнить пересчет программ. Пожалуйста, проверьте конфигурацию пакета программ последней версии по договору.');
  END RECOUNT_FROM_PAID;
  /* VESELEK
     11.12.2012
     Восстановление программы Смешанное страхование
  */
  PROCEDURE RECOVER_END
  (
    par_cover_id     NUMBER
   ,par_old_cover_id NUMBER
  ) IS
    proc_name        VARCHAR2(15) := 'RECOVER_END';
    v_Axn            NUMBER := 0;
    v_a_xn           NUMBER := 0;
    par_new_s        NUMBER := 0;
    par_paym_term_id NUMBER;
    par_values       INS.PKG_POLICY_PAID_FROM_PAID.COVER_VALUES;
    par_values_old   INS.PKG_POLICY_PAID_FROM_PAID.COVER_VALUES;
  BEGIN
    par_values     := INS.PKG_POLICY_PAID_FROM_PAID.GET_COVER_VALUE(par_cover_id);
    par_values_old := INS.PKG_POLICY_PAID_FROM_PAID.GET_COVER_VALUE(par_old_cover_id);
  
    v_Axn := ins.pkg_amath.Axn(par_values.age + par_values.t
                              ,par_values.n - par_values.t
                              ,par_values.sex
                              ,par_values.k_koef
                              ,par_values.s_koef
                              ,par_values.deathrate_id
                              ,par_values.fact_yield_rate);
  
    v_a_xn := ins.pkg_amath.a_xn(par_values.age + par_values.t
                                ,par_values.n - par_values.t
                                ,par_values.sex
                                ,par_values.k_koef
                                ,par_values.s_koef
                                ,1
                                ,par_values.deathrate_id
                                ,par_values.fact_yield_rate);
    IF par_values_old.number_of_payments = 1
    THEN
      par_new_s := par_values.ins_amount +
                   ((par_values_old.netto * par_values_old.ins_amount) * v_a_xn / v_Axn);
    ELSE
      par_new_s := (par_values.ins_amount + ((par_values_old.fee / par_values_old.number_of_payments) *
                   (1 - par_values.f_loading)) * v_a_xn / v_Axn);
    END IF;
  
    UPDATE ins.p_policy pol
       SET pol.payment_term_id  = par_values_old.payment_term_id
          ,pol.fee_payment_term = par_values_old.pp_fee_payment_term
     WHERE pol.policy_id = par_values.id_policy;
  
    UPDATE ins.p_cover p
       SET p.ins_amount            = FLOOR(par_new_s)
          ,p.fee                  =
           (CASE par_values_old.number_of_payments
             WHEN 1 THEN
              par_values_old.ins_amount * par_values_old.brutto
             ELSE
              par_values_old.fee
           END)
          ,p.premium              =
           (CASE par_values_old.number_of_payments
             WHEN 1 THEN
              par_values_old.ins_amount * par_values_old.brutto
             ELSE
              par_values_old.premium
           END)
          ,p.is_handchange_amount  = 1
          ,p.is_handchange_tariff  = 1
          ,p.is_handchange_fee     = 1
          ,p.is_handchange_premium = 1
     WHERE p.p_cover_id = par_cover_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось пересчитать END.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось пересчитать END.');
  END RECOVER_END;
  /* VESELEK
     11.12.2012
     Восстановление программы Дожитие и Инвест
  */
  PROCEDURE RECOVER_PEPR
  (
    par_cover_id     NUMBER
   ,par_old_cover_id NUMBER
  ) IS
    proc_name        VARCHAR2(15) := 'RECOVER_PEPR';
    v_Axn            NUMBER := 0;
    v_a_xn           NUMBER := 0;
    par_new_s        NUMBER := 0;
    par_paym_term_id NUMBER;
    par_values       INS.PKG_POLICY_PAID_FROM_PAID.COVER_VALUES;
    par_values_old   INS.PKG_POLICY_PAID_FROM_PAID.COVER_VALUES;
  BEGIN
    par_values     := INS.PKG_POLICY_PAID_FROM_PAID.GET_COVER_VALUE(par_cover_id);
    par_values_old := INS.PKG_POLICY_PAID_FROM_PAID.GET_COVER_VALUE(par_old_cover_id);
  
    v_Axn := ins.pkg_amath.Axn(par_values.age + par_values.t
                              ,par_values.n - par_values.t
                              ,par_values.sex
                              ,par_values.k_koef
                              ,par_values.s_koef
                              ,par_values.deathrate_id
                              ,par_values.fact_yield_rate);
  
    v_a_xn    := ins.pkg_amath.a_xn(par_values.age + par_values.t
                                   ,par_values.n - par_values.t
                                   ,par_values.sex
                                   ,par_values.k_koef
                                   ,par_values.s_koef
                                   ,1
                                   ,par_values.deathrate_id
                                   ,par_values.fact_yield_rate);
    par_new_s := par_values.ins_amount +
                 ((par_values_old.netto * par_values_old.ins_amount) * v_a_xn / v_Axn);
  
    IF par_values.plt_brief = 'RECOMMENDED'
    THEN
      UPDATE ins.p_policy pol
         SET pol.payment_term_id  = par_values_old.payment_term_id
            ,pol.fee_payment_term = par_values_old.pp_fee_payment_term
       WHERE pol.policy_id = par_values.id_policy;
    END IF;
  
    UPDATE ins.p_cover p
       SET p.ins_amount            = par_new_s
          ,p.fee                   = par_values_old.ins_amount * par_values_old.brutto
          ,p.premium               = par_values_old.ins_amount * par_values_old.brutto
          ,p.is_handchange_amount  = 1
          ,p.is_handchange_tariff  = 1
          ,p.is_handchange_fee     = 1
          ,p.is_handchange_premium = 1
     WHERE p.p_cover_id = par_cover_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      PKG_FORMS_MESSAGE.PUT_MESSAGE('Ошибка при выполнении ' || proc_name || ': ' ||
                                    'Внимание! Не удалось пересчитать END.');
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Внимание! Не удалось пересчитать END.');
  END RECOVER_PEPR;
  /**/
END PKG_POLICY_PAID_FROM_PAID;
/
