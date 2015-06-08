CREATE OR REPLACE PACKAGE PKG_REGR_PAYMENT IS

  /**
  * Содержимое платежа и информации по зачету содержимого
  */
  TYPE t_paym_cont IS RECORD(
     ac_payment_id             NUMBER
    , -- ид платежа
    obj_ure_id                NUMBER
    , -- объект учета
    obj_uro_id                NUMBER
    , -- объект учета
    acc_fund_id               NUMBER
    , -- валюта счета
    trans_fund_id             NUMBER
    , -- валюта проводки
    acc_amount                NUMBER
    , -- сумма содержимого в валюте счета
    trans_amount              NUMBER
    , -- сумма содержимого в валюте проводки
    dso_acc_amount            NUMBER
    , -- сумма зачета
    dso_trans_amount          NUMBER
    ,no_dso_acc_amount         NUMBER
    , -- незачтенная сумма
    no_dso_trans_amount       NUMBER
    ,total_no_dso_acc_amount   NUMBER
    , -- незачтенная сумма всего
    total_no_dso_trans_amount NUMBER
    ,count_cont                NUMBER); -- количество записей в содержимом

  /**
  * Курсор, возвращающий содержимое платежа
  *
  */
  TYPE t_paym_cont_cur IS REF CURSOR RETURN t_paym_cont;

  TYPE t_amount IS RECORD(
     fund_amount     NUMBER
    ,pay_fund_amount NUMBER);

  v_pay_acc_id NUMBER; -- счет оплаты

  -- расчитать запланированную сумму оплаты по регрессному делу
  FUNCTION get_plan_amount(p_c_subr_doc_id IN NUMBER) RETURN NUMBER;

  -- расчитать начисленную сумму по регрессному делу
  FUNCTION get_calc_amount(p_c_subr_doc_id IN NUMBER) RETURN NUMBER;

  -- расчитать сумму к оплате по регрессному делу
  FUNCTION get_to_pay_amount(p_c_subr_doc_id IN NUMBER) RETURN NUMBER;

  -- расчитать оплаченную за период сумму по регрессному делу
  FUNCTION get_pay_subrog_amount_pfa
  (
    p_start_date    DATE
   ,p_end_date      DATE
   ,p_c_subr_doc_id NUMBER
  ) RETURN NUMBER;

  /**
  * Создать счета-распоряжения по регрессному делу
  * Создает, корректирует существующий планы-графики оплаты и выплаты
  * @author   Denis Sergeev
  * @param p_c_subr_doc_id ИД регрессного дела
  */
  PROCEDURE subrog_make_planning
  (
    p_c_subr_doc_id   NUMBER
   ,p_Payment_Term_ID NUMBER
  );

  --начисление регрессного иска
  PROCEDURE subrog_charge(p_c_subr_doc_id NUMBER);

  /**
  * Процедура удаляет неоплаченные счета
  * @author Sergeev D.
  * @param doc_id ИД документа
  */
  PROCEDURE delete_unpayed(doc_id IN NUMBER);

END PKG_REGR_PAYMENT;
/
CREATE OR REPLACE PACKAGE BODY PKG_REGR_PAYMENT IS

  -- расчитать запланированную сумму оплаты по регрессному делу
  FUNCTION get_plan_amount(p_c_subr_doc_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(dd.parent_amount), 0)
        INTO v_result
        FROM doc_doc        dd
            ,ven_ac_payment ap
            ,doc_templ      dt
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = p_c_subr_doc_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'AccPayRegress';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать начисленную сумму по регрессному делу
  FUNCTION get_calc_amount(p_c_subr_doc_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = p_c_subr_doc_id
         AND tt.brief = 'РегрессныйИскНачислен';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать сумму к оплате по регрессному делу
  FUNCTION get_to_pay_amount(p_c_subr_doc_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM doc_doc     dd
            ,ac_payment  ap
            ,oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = ap.payment_id
         AND ap.payment_id = dd.child_id
         AND dd.parent_id = p_c_subr_doc_id
         AND tt.brief = 'РегрессныйИскНачисленКОплате';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  /**
  * Получить сумму оплаты
  * @author Denis Sergeev
  */
  FUNCTION get_pay_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_A1_ID      NUMBER DEFAULT NULL
   ,p_A2_ID      NUMBER DEFAULT NULL
   ,p_A3_ID      NUMBER DEFAULT NULL
   ,p_A4_ID      NUMBER DEFAULT NULL
   ,p_A5_ID      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest acc_new.t_Turn_Rest;
    v_ret_val   t_amount;
  BEGIN
    v_turn_rest               := acc_new.Get_Acc_Turn_Rest(v_pay_acc_id
                                                          ,p_fund_id
                                                          ,p_start_date
                                                          ,p_end_date
                                                          ,p_A1_ID
                                                          ,0
                                                          ,p_A2_ID
                                                          ,0
                                                          ,p_A3_ID
                                                          ,0
                                                          ,p_A4_ID
                                                          ,0
                                                          ,p_A5_ID
                                                          ,0);
    v_ret_val.fund_amount     := v_turn_rest.Turn_Ct_Fund;
    v_ret_val.pay_fund_amount := v_turn_rest.Turn_Ct_Base_Fund;
    RETURN v_ret_val;
  END;

  /**
  * Получить оплаченную сумму по регрессному делу
  * @author Denis Sergeev
  * @param p_c_subr_doc_id ид регрессного дела
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_subrog_amount
  (
    p_start_date    DATE
   ,p_end_date      DATE
   ,p_c_subr_doc_id NUMBER
  ) RETURN t_amount IS
    v_fund_id     NUMBER;
    v_ret_val     t_amount;
    v_temp_amount t_amount;
  BEGIN
    v_ret_val.fund_amount     := 0;
    v_ret_val.pay_fund_amount := 0;
    v_temp_amount             := get_pay_amount(v_fund_id, p_start_date, NULL, p_c_subr_doc_id);
    v_ret_val.fund_amount     := v_temp_amount.fund_amount;
    v_ret_val.pay_fund_amount := v_temp_amount.pay_fund_amount;
    RETURN v_ret_val;
  END;

  -- расчитать оплаченную за период сумму по регрессному делу
  FUNCTION get_pay_subrog_amount_pfa
  (
    p_start_date    DATE
   ,p_end_date      DATE
   ,p_c_subr_doc_id NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    /*
    return get_pay_subrog_amount(p_start_date,
                                 p_end_date,
                                 p_c_subr_doc_id).fund_amount;
    */
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_result
      FROM trans       t
          ,trans_templ tt
          ,oper        o
          ,doc_set_off dso
          ,ac_payment  ap
          ,doc_doc     dd
     WHERE t.trans_templ_id = tt.trans_templ_id
       AND tt.brief = 'РегрессныйИскОплачен'
       AND t.oper_id = o.oper_id
       AND o.document_id = dso.doc_set_off_id
       AND dso.parent_doc_id = ap.payment_id
       AND dd.child_id = ap.payment_id
       AND dd.parent_id = p_c_subr_doc_id
       AND t.trans_date >= p_start_date
       AND t.trans_date <= p_end_date + 1;
    RETURN v_result;
  END;

  PROCEDURE subrog_make_planning
  (
    p_c_subr_doc_id   NUMBER
   ,p_Payment_Term_ID NUMBER
  ) IS
    v_subr_doc            ven_c_subr_doc%ROWTYPE;
    v_Payment_ID          NUMBER;
    v_fund_id             NUMBER;
    v_fund_pay_id         NUMBER;
    v_Payment_Templ_ID    NUMBER;
    v_Rate_Type_ID        NUMBER;
    v_Company_Bank_Acc_ID NUMBER;
    v_Total_Amount        NUMBER;
    v_Payment_Term_Id     NUMBER;
  BEGIN
    SELECT * INTO v_subr_doc FROM ven_c_subr_doc d WHERE d.c_subr_doc_id = p_c_subr_doc_id;
  
    SELECT d.fund_id
          ,d.fund_id
      INTO v_fund_id
          ,v_fund_pay_id
      FROM c_subr_doc d
     WHERE d.c_subr_doc_id = p_c_subr_doc_id;
  
    -- проверить наличие созданных счетов на оплату
    IF pkg_regr_payment.get_plan_amount(p_c_subr_doc_id) = v_subr_doc.subr_amount
    THEN
      v_Payment_ID := 1;
    ELSE
      v_Payment_ID := NULL;
    END IF;
  
    IF v_Payment_Id IS NULL
    THEN
    
      SELECT pt.payment_templ_id
        INTO v_Payment_Templ_ID
        FROM ac_payment_templ pt
       WHERE pt.brief = 'AccPayRegress';
    
      SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
    
      SELECT cba.id
        INTO v_Company_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
         AND cba.id = (SELECT MAX(cbas.id)
                         FROM cn_contact_bank_acc cbas
                        WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
    
      v_Total_Amount := v_subr_doc.subr_amount - get_plan_amount(p_c_subr_doc_id);
    
      IF v_Total_Amount > 0
      THEN
        v_Payment_Term_ID := p_payment_term_id;
        pkg_payment.create_paymnt_sheduler(v_Payment_Templ_ID
                                          ,v_Payment_Term_ID
                                          ,v_Total_Amount
                                          ,v_fund_id
                                          ,v_fund_pay_id
                                          ,v_Rate_Type_ID
                                          ,CASE WHEN v_fund_id = v_fund_pay_id THEN 1.0 ELSE CASE WHEN
                                           acc_new.Get_Rate_By_ID(v_Rate_Type_ID
                                                                 ,v_fund_pay_id
                                                                 ,v_subr_doc.reg_date) <> 0 THEN
                                           acc_new.Get_Rate_By_ID(v_Rate_Type_ID
                                                                 ,v_fund_id
                                                                 ,v_subr_doc.reg_date) /
                                           acc_new.Get_Rate_By_ID(v_Rate_Type_ID
                                                                 ,v_fund_pay_id
                                                                 ,v_subr_doc.reg_date) ELSE 1.0 END END
                                          ,v_subr_doc.defendant_id
                                          ,NULL
                                          ,v_Company_Bank_Acc_ID
                                          ,v_subr_doc.reg_date
                                          ,v_subr_doc.c_subr_doc_id);
      END IF;
    END IF;
  END;

  PROCEDURE subrog_charge(p_c_subr_doc_id NUMBER) IS
    v_oper_templ_charge_id NUMBER;
    v_res_id               NUMBER;
    v_amount               NUMBER;
    v_count                NUMBER;
    v_total_amount         NUMBER;
    v_subr_amount          NUMBER;
    i                      NUMBER;
    v_oper_amount          NUMBER;
  BEGIN
  
    SELECT ot.oper_templ_id
      INTO v_oper_templ_charge_id
      FROM oper_templ ot
     WHERE ot.brief = 'РегрессноеДелоНачисление';
  
    SELECT csd.subr_amount
      INTO v_subr_amount
      FROM c_subr_doc csd
     WHERE csd.c_subr_doc_id = p_c_subr_doc_id;
  
    SELECT COUNT(*)
          ,SUM(dam.payment_sum)
      INTO v_count
          ,v_total_amount
      FROM c_damage        dam
          ,c_damage_status ds
          ,status_hist     sh
          ,c_claim         c
          ,c_claim_header  ch
          ,c_subr_doc      csd
     WHERE csd.c_subr_doc_id = p_c_subr_doc_id
       AND ch.c_claim_header_id = csd.c_claim_header_id
       AND dam.c_claim_id = c.c_claim_id
       AND c.c_claim_header_id = ch.c_claim_header_id
       AND dam.c_damage_status_id = ds.c_damage_status_id
       AND dam.status_hist_id = sh.status_hist_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT');
  
    i        := 0;
    v_Amount := 0;
  
    FOR c_claim IN (SELECT dam.c_damage_id
                          ,dam.ent_id
                          ,dam.payment_sum payment_sum
                      FROM c_damage        dam
                          ,c_damage_status ds
                          ,status_hist     sh
                          ,c_claim         c
                          ,c_claim_header  ch
                          ,c_subr_doc      csd
                     WHERE csd.c_subr_doc_id = p_c_subr_doc_id
                       AND ch.c_claim_header_id = csd.c_claim_header_id
                       AND dam.c_claim_id = c.c_claim_id
                       AND c.c_claim_header_id = ch.c_claim_header_id
                       AND dam.c_damage_status_id = ds.c_damage_status_id
                       AND dam.status_hist_id = sh.status_hist_id
                       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
                       AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
    
      i := i + 1;
    
      IF i < v_Count
      THEN
        v_oper_amount := ROUND(c_claim.payment_sum * v_Subr_Amount / v_Total_Amount, 2);
        v_amount      := v_amount + v_oper_Amount;
      ELSE
        v_oper_amount := v_subr_amount - v_amount;
      END IF;
    
      v_res_id := acc_new.Run_Oper_By_Template(v_oper_templ_charge_id
                                              ,p_c_subr_doc_id
                                              ,c_claim.ent_id
                                              ,c_claim.c_damage_id
                                              ,doc.get_doc_status_id(p_c_subr_doc_id)
                                              ,1
                                              ,v_oper_amount
                                              ,'INS');
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR subr_doc_charge ' || p_c_subr_doc_id);
      dbms_output.put_line(SQLERRM);
      RAISE;
  END;

  PROCEDURE delete_unpayed(doc_id IN NUMBER) IS
  BEGIN
    FOR rc IN (SELECT ap.payment_id
                     ,ap.amount
                 FROM ven_ac_payment ap
                     ,doc_doc        dd
                     ,doc_templ      dt
                WHERE dd.child_id = ap.payment_id
                  AND dd.parent_id = doc_id
                  AND dt.doc_templ_id = ap.doc_templ_id
                  AND dt.brief = 'AccPayRegress')
    LOOP
      CASE doc.get_doc_status_brief(rc.payment_id)
        WHEN 'NEW' THEN
          DELETE FROM document d WHERE document_id = rc.payment_id;
        WHEN 'TO_PAY' THEN
          FOR rc_dso IN (SELECT nvl(SUM(dso.set_off_amount), 0) s
                           FROM doc_set_off dso
                          WHERE dso.parent_doc_id = rc.payment_id)
          LOOP
            IF rc_dso.s = 0
            THEN
              doc.set_doc_status(rc.payment_id, 'NEW');
              DELETE FROM document d WHERE document_id = rc.payment_id;
            ELSIF rc_dso.s < rc.amount
            THEN
              UPDATE ac_payment ap
                 SET ap.amount     = rc_dso.s
                    ,ap.rev_amount = ROUND(ap.rev_rate * rc_dso.s, 2)
               WHERE ap.payment_id = rc.payment_id;
              doc.set_doc_status(rc.payment_id, 'PAID');
            END IF;
          END LOOP;
        ELSE
          NULL;
      END CASE;
    END LOOP;
  END;

BEGIN

  SELECT a.account_id INTO v_pay_acc_id FROM account a WHERE a.num = '76.02.02';

END PKG_REGR_PAYMENT;
/
