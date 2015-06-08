CREATE OR REPLACE PACKAGE pkg_reins_payment IS
  --Содержимое платежа и информации по зачету содержимого
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
    , -- сумма зачета в валюте
    dso_trans_amount          NUMBER
    , -- сумма зачета в базовой валюте
    no_dso_acc_amount         NUMBER
    , -- незачтенная сумма в валюте
    no_dso_trans_amount       NUMBER
    , -- незачтенная сумма в базовой валюте
    total_no_dso_acc_amount   NUMBER
    , -- незачтенная сумма всего в валюте
    total_no_dso_trans_amount NUMBER
    , -- незачтенная сумма всего в базовой валюте
    count_cont                NUMBER); -- количество записей в содержимом

  --Курсор, возвращающий содержимое платежа
  TYPE t_paym_cont_cur IS REF CURSOR RETURN t_paym_cont;

  --Запись о сумме
  TYPE t_amount IS RECORD(
     fund_amount     NUMBER
    , --Сумма в валюте ответственности
    pay_fund_amount NUMBER --Сумма в валюте зачета
    );

  v_pay_acc_id NUMBER; -- счет оплаты

  /**
  * Процедура начисления бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  */
  PROCEDURE bordero_charge(p_bordero_id IN NUMBER);

  /**
  * Получить сумму по пакету бордеро
  * @author Сыровецкий Д.
  * @param p_pack_id ИД пакета бордеро
  * @param ret_flg определяет вид суммы, 0 - оплата, 1 - выплата, по умолчанию 0
  * @return итоговая сумма
  */
  FUNCTION get_bordero_amount
  (
    p_pack_id IN NUMBER
   ,ret_flg   IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Получить начисленную сумму по пакету бордеро (или конкретному бордеро в пакете)
  * @author Сыровецкий Д.
  * @param p_pack_id ИД пакета бордеро
  * @param p_bordero_id ИД бордеро (может быть пустым)
  * @param ret_flg определяет вид суммы, 0 - оплата, 1 - выплата, 2 - БП, 3 - комиссия, по умолчанию 0
  * @return Начисленная сумма
  */
  FUNCTION get_calc_amount
  (
    p_pack_id    IN NUMBER
   ,p_bordero_id IN NUMBER DEFAULT NULL
   ,ret_flg      IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Получить итогувую начисленную сумму по пакету бордеро (или конкретному бордеро в пакете)
  * @author Сыровецкий Д.
  * @param p_pack_id ИД пакета бордеро
  * @param p_bordero_id ИД бордеро (может быть пустым)
  * @return Начисленная сумма
  */
  FUNCTION get_calc_total
  (
    p_pack_id    IN NUMBER
   ,p_bordero_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить запланированную к оплате/выплате сумму пакету бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_pack_id ИД пакета бордеро
  * @return Запланированная сумма к оплате
  */
  FUNCTION get_plan_amount(p_bordero_pack_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную к оплате/выплате сумму пакету бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_pack_id ИД пакета бордеро
  * @return Начисленная сумма к оплате/выплате
  */
  FUNCTION get_to_pay_amount(p_bordero_pack_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить оплаченную сумму по пакету бордеро
  * @author Сыровецкий Д.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_bordero_pack_id ИД пакета бордеро
  * @return Оплаченная сумма пакета бордеро
  */
  FUNCTION get_pay_pack_amount_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_bordero_pack_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить оплаченную сумму по пакету бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_pack_id ИД пакета бордеро
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата
  * @return Оплаченная сумма пакета бордеро
  */
  FUNCTION get_pay_pack
  (
    p_bordero_pack_id NUMBER
   ,ret_flg           NUMBER
  ) RETURN NUMBER;

  /**
  * Получить оплаченную сумму по пакету бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_pack_id ИД пакета бордеро
  * @return Оплаченная сумма пакета бордеро
  */
  FUNCTION get_pay_amount(p_bordero_pack_id NUMBER) RETURN NUMBER;

  /**
  * Создать счета-распоряжения по бордеро
  * Создает, корректирует существующий планы-графики оплаты и выплаты
  * @author  Сыровецкий Д.
  * @param p_bordero_pack_id ИД пакета бордеро
  * @param p_Payment_Term_ID ИД условия рассрочки
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата, по умолчанию 0
  */
  PROCEDURE bordero_make_planning
  (
    p_bordero_pack_id IN NUMBER
   ,p_payment_term_id IN NUMBER
   ,ret_flg           IN NUMBER DEFAULT 0
  );

  /**
  * Смена статуса платежного документа
  * @author  Сыровецкий Д.
  * @param doc_id ИД платежного документа
  */
  PROCEDURE set_payment_status(doc_id IN NUMBER);

  /**
  * Получить курс для указанного бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  * @param p_date Дата, на которую нужно брать курс
  * @return Значение курса
  */
  FUNCTION get_bordero_rate
  (
    p_bordero_id IN NUMBER
   ,p_date       DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * Получить курс для указанного слипа
  * @author Сыровецкий Д.
  * @param p_slip_header_id ИД заголовка слипа
  * @param p_date Дата, на которую нужно брать курс
  * @return Значение курса
  */
  FUNCTION get_slip_rate
  (
    p_slip_header_id IN NUMBER
   ,p_date           IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * Процедура начисления премий слипа
  * @author Сыровецкий Д.
  * @param p_slip_id ИД слипа
  */
  PROCEDURE slip_charge(p_slip_id IN NUMBER);

  /**
  * Процедура начисления убытков слипа
  * @author Сыровецкий Д.
  * @param p_claim_id ИД убытка в перестраховании
  */
  PROCEDURE slip_claim_charge(p_claim_id IN NUMBER);

  /**
  * Получить сумму слипа
  * @author Сыровецкий Д.
  * @param p_id ИД заголовка слипа
  * @param p_type тип возвращаемой суммы 0 - итоговая сумма, 1 - сумма оплаты, 2 - сумма выплаты
  * @return Сумма слипа
  */
  FUNCTION get_slip_amount
  (
    p_id   IN NUMBER
   ,p_type IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Получить начисленную сумму по слипу
  * @author Сыровецкий Д.
  * @param p_slip_head_id ИД заголовка слипа
  * @param ret_flg определяет вид суммы, 0 - оплата, 1 - выплата, 2 - БП, 3-комиссия, по умолчанию 0
  * @return Начисленная сумма
  */
  FUNCTION get_slip_calc_amount
  (
    p_slip_head_id IN NUMBER
   ,ret_flg        IN NUMBER DEFAULT 0
   ,p_obj_id       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить запланированную сумму по слипу
  * @author Сыровецкий Д.
  * @param p_id ИД заголовкаслипа
  * @param ret_flg определяет вид суммы, 0 - оплата, 1 - выплата, по умолчанию 0
  * @return Запланированная сумма
  */
  FUNCTION get_slip_plan_amount
  (
    p_id    IN NUMBER
   ,ret_flg IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Создать счета-распоряжения по слипу
  * Создает, корректирует существующий планы-графики оплаты и выплаты
  * @author  Сыровецкий Д.
  * @param p_slip_id ИД слипа
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата, по умолчанию 0
  * @param p_sum Сумма, на которую нужно сформировать платежный документ. Если указан 0, то автоматический расчет
  * @param p_count_bild Кол-во платежных документов. Если 0, то автоматический расчет
  * @param p_flg_off Создание документа взаимозачета. 1 - создать, 0 - нет
  */
  PROCEDURE slip_make_planning
  (
    p_slip_id    IN NUMBER
   ,ret_flg      IN NUMBER DEFAULT 0
   ,p_sum        IN NUMBER DEFAULT 0
   ,p_count_bild IN NUMBER DEFAULT 0
   ,p_flg_off    IN NUMBER DEFAULT 0
  );

  /**
  * Получить начисленную к оплате/выплате сумму по слипу
  * @author Сыровецкий Д.
  * @param p_id ИД заголовка слипа
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата, по умолчанию 0
  * @return Начисленная сумма к оплате/выплате
  */
  FUNCTION get_slip_to_pay_amount
  (
    p_id    IN NUMBER
   ,ret_flg NUMBER
  ) RETURN NUMBER;

  /**
  * Получить зачтенную к оплате/выплате сумму по слипу/заголовку
  * @author Сыровецкий Д.
  * @param p_id ИД документа
  * @param p_doc_type Тип документа 0 - заголовок, 1 - слип, 2 - платежный документ
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата, по умолчанию 0
  * @return Начисленная сумма к оплате/выплате
  */
  FUNCTION get_slip_set_off_amount
  (
    p_id       IN NUMBER
   ,p_doc_type NUMBER
   ,ret_flg    NUMBER
  ) RETURN NUMBER;

  /**
  * Получить оплаченную/выплаченную сумму по слипу
  * @author Сыровецкий Д.
  * @param p_id ИД заголвка слипа
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата, по умолчанию 0
  * @return Оплаченная/выплаченная сумма слипа
  */
  FUNCTION get_slip_pay_amount_pfa
  (
    p_id    NUMBER
   ,ret_flg NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Процедура начислений при расторжении слипа
  * @author Сыровецкий Д.
  * @param p_slip_id ИД слипа
  */
  PROCEDURE SLIP_ABORT(p_slip_id NUMBER);

  /**
  * Процедура удаления неоплаченных счетов
  * @author Сыровецкий Д.
  * @param p_id ИД заголовочного документа
  * @param ret_flg определяет оплату/выплату, 0 - оплата, 1 - выплата, по умолчанию 0 
  */
  PROCEDURE delete_non_payment_acc_fak
  (
    p_id    NUMBER
   ,ret_flg NUMBER DEFAULT 0
  );

  /**
  * Процедура завершения действия слипа
  * @author Сыровецкий Д.
  * @param p_slip_id ИД слипа
  */
  PROCEDURE slip_finalize(p_slip_id NUMBER);

  /**
  * Процедура начисления тантьемы
  * @author Сыровецкий Д.
  * @param p_slip_id ИД счета тантьемы
  */
  PROCEDURE TANT_CHARGE(p_id NUMBER);

  /**
  * Создание графика платежей для тантьемы (один платеж)
  * @author Сыровецкий Д.
  * @param p_id ИД счета тантьемы
  */
  PROCEDURE tant_make_planning(p_id NUMBER);

  /**
  * Процедура начисления тантьемы к оплате
  * @author Сыровецкий Д.
  * @param p_id ИД платежного документа
  */
  PROCEDURE TANT_TO_PAY_CHARGE(p_id NUMBER);

  /**
  * Функция вычисляет начисленную сумму по тантьеме
  * @author Сыровецкий Д.
  * @param p_id ИД платежного документа
  * @return Сумма начисленных денег
  */
  FUNCTION get_tant_calc(p_id NUMBER) RETURN NUMBER;

  /**
  * Функция вычисляет сумму зачета по тантьеме
  * @author Сыровецкий Д.
  * @param p_id ИД платежного документа
  * @return Сумма зачета
  */
  FUNCTION get_tant_set_off(p_id NUMBER) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет расчетов с контрагентом по договору страхования"
  * @author Сыровецкий Д.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION GET_ACC_4_FAK_IN
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

END; -- Package spec
/
CREATE OR REPLACE PACKAGE BODY pkg_reins_payment IS
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE run_oper_by_template_R
  (
    p_oper_templ_id NUMBER
   ,p_doc_id        NUMBER
   ,p_ure_id        NUMBER
   ,p_uro_id        NUMBER
   ,p_sum           NUMBER
  ) IS
    v_res_id NUMBER;
  BEGIN
    v_res_id := acc_new.Run_Oper_By_Template(p_oper_templ_id
                                            ,p_doc_id
                                            ,p_ure_id
                                            ,p_uro_id
                                            ,doc.get_doc_status_id(p_doc_id)
                                            ,1
                                            ,p_sum
                                            ,'INS');
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE bordero_charge(p_bordero_id IN NUMBER) IS
    v_oper_templ_charge1_id NUMBER;
    v_oper_templ_charge2_id NUMBER;
    v_oper_templ_charge3_id NUMBER;
    v_oper_templ_charge4_id NUMBER;
    v_oper_templ_charge5_id NUMBER;
    v_oper_templ_charge6_id NUMBER;
    v_oper_templ_charge7_id NUMBER;
    v_type_bordero_brief    VARCHAR2(200);
    v_res_id                NUMBER;
    v_error_exit            NUMBER;
  
  BEGIN
  
    SELECT bt.brief
      INTO v_type_bordero_brief
      FROM re_bordero      b
          ,re_bordero_type bt
     WHERE b.re_bordero_id = p_bordero_id
       AND bt.re_bordero_type_id = b.re_bordero_type_id;
  
    UPDATE re_bordero b
       SET b.accept_date = doc.get_status_date(p_bordero_id, 'ACCEPTED')
     WHERE b.re_bordero_id = p_bordero_id;
  
    IF v_type_bordero_brief IN ('БОРДЕРО_ПРЕМИЙ'
                               ,'БОРДЕРО_ДОПЛАТ'
                               ,'БОРДЕРО_РАСТОРЖЕНИЙ'
                               ,'БОРДЕРО_ИЗМЕН')
    THEN
      BEGIN
        --получаем ИД шаблона операции
        v_error_exit := 1;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge1_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхПремияБрНач';
        v_error_exit := 2;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge2_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхКомиссияНач';
        v_error_exit := 3;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge3_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхПремияНтНач';
        v_error_exit := 4;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge4_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхПремияНтОплВзм';
        v_error_exit := 5;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge5_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхВозвратНач';
        v_error_exit := 6;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge6_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхВозвратНачОпл';
        v_error_exit := 7;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge7_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхВозвратОплВзм';
      
      EXCEPTION
        WHEN OTHERS THEN
          CASE v_error_exit
            WHEN 1 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхПремияБрНач". Обратитесь к администратору системы.');
            WHEN 2 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхКомиссияНач". Обратитесь к администратору системы.');
            WHEN 3 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхПремияНтНач". Обратитесь к администратору системы.');
            WHEN 4 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхПремияНтОплВзм". Обратитесь к администратору системы.');
            WHEN 5 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхВозвратНач". Обратитесь к администратору системы.');
            WHEN 6 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхВозвратНачОпл". Обратитесь к администратору системы.');
            WHEN 7 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхВозвратОплВзм". Обратитесь к администратору системы.');
            ELSE
              NULL;
          END CASE;
      END;
    
      BEGIN
      
        FOR cur IN ( --цикл по rel_recover 1
                    SELECT rrb.brutto_premium
                           ,rrb.commission
                           ,rrb.netto_premium
                           ,rrb.returned_premium
                           ,rrb.ins_premium_nach
                           ,rc.ins_premium
                           ,rrb.ent_id ent_relrecover
                           ,rrb.rel_recover_bordero_id
                           ,rc.p_asset_header_id
                           ,rc.t_product_line_id
                           ,decode(rb.FLG_DATE_RATE
                                  ,0
                                  ,pkg_reins_payment.get_bordero_rate(rb.RE_BORDERO_ID)
                                  ,pkg_reins_payment.get_bordero_rate(rb.RE_BORDERO_ID, rrb.FUND_DATE)) v_rate
                      FROM rel_recover_bordero rrb
                           ,re_cover            rc
                           ,re_bordero          rb
                     WHERE rrb.re_bordero_id = p_bordero_id
                       AND rc.re_cover_id = rrb.re_cover_id
                       AND rb.re_bordero_id = rrb.re_bordero_id)
        LOOP
          --цикл по rel_recover 2
        
          /*if nvl(cur.ins_premium_nach,0) <> 0 then
          --!!!!Нужно проверять остаток !!!!!!!!!!
          -- в итоге все суммы по начислениям должны быть равны БРУТТО_премии
          
            cur.brutto_premium := cur.brutto_premium*cur.ins_premium_nach/cur.ins_premium;
            cur.commission := cur.commission*cur.ins_premium_nach/cur.ins_premium;
          end if;*/
        
          --создаем операции по шаблону
          IF cur.brutto_premium > 0
          THEN
            v_error_exit := 1;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge1_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.brutto_premium * cur.v_rate
                                                        ,'INS');
          END IF;
          IF cur.commission > 0
          THEN
            v_error_exit := 2;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge2_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.commission * cur.v_rate
                                                        ,'INS');
          END IF;
          IF cur.netto_premium > 0
          THEN
            v_error_exit := 3;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge3_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.netto_premium * cur.v_rate
                                                        ,'INS');
            v_error_exit := 4;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge4_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.netto_premium * cur.v_rate
                                                        ,'INS');
          END IF;
          IF cur.returned_premium > 0
          THEN
            v_error_exit := 5;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge5_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.returned_premium * cur.v_rate
                                                        ,'INS');
            v_error_exit := 6;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge6_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.returned_premium * cur.v_rate
                                                        ,'INS');
            v_error_exit := 7;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge7_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relrecover
                                                        ,cur.rel_recover_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.returned_premium * cur.v_rate
                                                        ,'INS');
          END IF;
        END LOOP outer_loop; --цикл по rel_recover 3
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Ошибка при начислении проводок бордеро (премии).');
      END;
    END IF;
  
    IF v_type_bordero_brief = 'БОРДЕРО_ОПЛ_УБЫТКОВ'
    THEN
      BEGIN
        v_error_exit := 1;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge1_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхВозмещНач';
      
        v_error_exit := 2;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge2_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхВозмещНачОпл';
      
        v_error_exit := 3;
        SELECT ot.oper_templ_id
          INTO v_oper_templ_charge2_id
          FROM oper_templ ot
         WHERE ot.brief = 'ОпПрИсхВозмещОпл';
      
      EXCEPTION
        WHEN OTHERS THEN
          CASE v_error_exit
            WHEN 1 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхВозмещНач". Обратитесь к администратору системы.');
            WHEN 2 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхВозмещНачОпл". Обратитесь к администратору системы.');
            WHEN 3 THEN
              raise_application_error(-20000
                                     ,'Невозможно получить шаблон операции "ОпПрИсхВозмещОпл". Обратитесь к администратору системы.');
            ELSE
              NULL;
          END CASE;
      END;
    
      BEGIN
        FOR cur IN ( --цикл по rel_redamage 1
                    SELECT rrd.re_payment_sum
                           ,rrd.ent_id ent_relredamage
                           ,rrd.rel_redamage_bordero_id
                           ,get_bordero_rate(p_bordero_id) v_rate
                      FROM rel_redamage_bordero rrd
                     WHERE rrd.re_bordero_id = p_bordero_id)
        LOOP
          --цикл по rel_redamage 2
        
          --создаем операции по шаблону
          IF cur.re_payment_sum > 0
          THEN
            v_error_exit := 1;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge1_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relredamage
                                                        ,cur.rel_redamage_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.re_payment_sum * cur.v_rate
                                                        ,'INS');
            v_error_exit := 2;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge2_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relredamage
                                                        ,cur.rel_redamage_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.re_payment_sum * cur.v_rate
                                                        ,'INS');
            v_error_exit := 3;
            v_res_id     := acc_new.Run_Oper_By_Template(v_oper_templ_charge3_id
                                                        ,p_bordero_id
                                                        ,cur.ent_relredamage
                                                        ,cur.rel_redamage_bordero_id
                                                        ,doc.get_doc_status_id(p_bordero_id)
                                                        ,1
                                                        ,cur.re_payment_sum * cur.v_rate
                                                        ,'INS');
          END IF;
        
        END LOOP; --цикл по rel_redamage 3
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Ошибка при начислении проводок бордеро (возмещение).');
      END;
    END IF;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_bordero_amount
  (
    p_pack_id IN NUMBER
   ,ret_flg   IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    ret_val NUMBER;
  BEGIN
    ret_val := 0;
    IF ret_flg = 1
    THEN
      SELECT (nvl(summ_out, 0))
        INTO ret_val
        FROM re_bordero_package bp
       WHERE bp.re_bordero_package_id = p_pack_id;
    ELSIF ret_flg = 0
    THEN
      SELECT (nvl(summ_in, 0))
        INTO ret_val
        FROM re_bordero_package bp
       WHERE bp.re_bordero_package_id = p_pack_id;
    END IF;
    RETURN nvl(ret_val, 0);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_calc_amount
  (
    p_pack_id    IN NUMBER
   ,p_bordero_id IN NUMBER DEFAULT NULL
   ,ret_flg      IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_sum      NUMBER;
    v_temp_sum NUMBER;
    v_tt_brief VARCHAR2(255);
  BEGIN
    v_sum := 0;
  
    FOR cur IN (SELECT b.re_bordero_id
                      ,bt.brief
                  FROM re_bordero      b
                      ,re_bordero_type bt
                 WHERE b.re_bordero_package_id = p_pack_id
                   AND b.re_bordero_id = nvl(p_bordero_id, b.re_bordero_id)
                   AND bt.re_bordero_type_id = b.re_bordero_type_id)
    LOOP
    
      v_tt_brief := NULL;
    
      IF ret_flg = 1
         AND
         cur.brief IN
         ('БОРДЕРО_ПРЕМИЙ', 'БОРДЕРО_ДОПЛАТ', 'БОРДЕРО_ИЗМЕН')
      THEN
        v_tt_brief := 'ПрИсхПремияНтНач';
      END IF;
      IF ret_flg = 2
         AND
         cur.brief IN
         ('БОРДЕРО_ПРЕМИЙ', 'БОРДЕРО_ДОПЛАТ', 'БОРДЕРО_ИЗМЕН')
      THEN
        v_tt_brief := 'ПрИсхПремияБрНач';
      END IF;
      IF ret_flg = 3
         AND
         cur.brief IN
         ('БОРДЕРО_ПРЕМИЙ', 'БОРДЕРО_ДОПЛАТ', 'БОРДЕРО_ИЗМЕН')
      THEN
        v_tt_brief := 'ПрИсхКомиссияНач';
      END IF;
      IF ret_flg = 0
         AND cur.brief IN ('БОРДЕРО_ОПЛ_УБЫТКОВ')
      THEN
        v_tt_brief := 'ПрИсхВозмещНач';
      END IF;
      IF ret_flg = 0
         AND cur.brief IN ('БОРДЕРО_ИЗМЕН', 'БОРДЕРО_РАСТОРЖЕНИЙ')
      THEN
        v_tt_brief := 'ПрИсхВозвратНач';
      END IF;
    
      v_temp_sum := 0;
    
      IF v_tt_brief IS NOT NULL
      THEN
        SELECT nvl(SUM(t.acc_amount), 0)
          INTO v_temp_sum
          FROM oper        o
              ,trans       t
              ,trans_templ tt
         WHERE t.trans_templ_id = tt.trans_templ_id
           AND t.oper_id = o.oper_id
           AND o.document_id = cur.re_bordero_id
           AND tt.brief = v_tt_brief;
      END IF;
    
      v_sum := v_sum + v_temp_sum;
    END LOOP;
    RETURN nvl(v_sum, 0);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_calc_total
  (
    p_pack_id    IN NUMBER
   ,p_bordero_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    ret_val NUMBER := 0;
  BEGIN
    ret_val := get_calc_amount(p_pack_id, p_bordero_id, 0) -
               get_calc_amount(p_pack_id, p_bordero_id, 1);
  
    RETURN nvl(ret_val, 0);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_plan_amount(p_bordero_pack_id IN NUMBER) RETURN NUMBER IS
    v_result   NUMBER;
    v_type_pay VARCHAR2(255);
  BEGIN
  
    IF get_calc_total(p_bordero_pack_id) > 0
    THEN
      v_type_pay := 'AccOblOutReins';
    ELSE
      v_type_pay := 'PayOblOutReins';
    END IF;
  
    BEGIN
      SELECT nvl(SUM(dd.parent_amount), 0)
        INTO v_result
        FROM doc_doc        dd
            ,ven_ac_payment ap
            ,doc_templ      dt
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = p_bordero_pack_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief = v_type_pay;
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    v_result := v_result - get_to_pay_amount(p_bordero_pack_id);
    IF v_result < 0
    THEN
      v_result := 0;
    END IF;
    RETURN nvl(v_result, 0);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION get_to_pay_amount(p_bordero_pack_id IN NUMBER) RETURN NUMBER IS
    v_result   NUMBER;
    v_tt_brief VARCHAR2(255);
  BEGIN
  
    IF get_calc_total(p_bordero_pack_id) > 0
    THEN
      v_tt_brief := 'ПрИсхВзаимозачетОплНач';
    ELSE
      v_tt_brief := 'ПрИсхВзаимозачетВыплНач';
    END IF;
  
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
         AND dd.parent_id = p_bordero_pack_id
         AND tt.brief = v_tt_brief;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
  
    v_result := v_result - get_pay_amount(p_bordero_pack_id);
    IF v_result < 0
    THEN
      v_result := 0;
    END IF;
  
    RETURN nvl(v_result, 0);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_pay_pack_amount_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_bordero_pack_id NUMBER
  ) RETURN NUMBER IS
    v_result   NUMBER;
    v_tt_brief VARCHAR2(255);
  BEGIN
  
    v_result := 0;
  
    IF get_calc_total(p_bordero_pack_id) > 0
    THEN
      v_tt_brief := 'ПрИсхВзаимозачетОпл';
    ELSE
      v_tt_brief := 'ПрИсхВзаимозачетВыпл';
    END IF;
  
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_result
      FROM trans       t
          ,trans_templ tt
          ,oper        o
          ,doc_set_off dso
          ,ac_payment  ap
          ,doc_doc     dd
     WHERE t.trans_templ_id = tt.trans_templ_id
       AND tt.brief = v_tt_brief
       AND t.oper_id = o.oper_id
       AND o.document_id = dso.doc_set_off_id
       AND dso.parent_doc_id = ap.payment_id
       AND dd.child_id = ap.payment_id
       AND dd.parent_id = p_bordero_pack_id
       AND t.trans_date >= p_start_date
       AND t.trans_date <= p_end_date + 1;
  
    RETURN nvl(v_result, 0);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_pay_pack
  (
    p_bordero_pack_id NUMBER
   ,ret_flg           NUMBER
  ) RETURN NUMBER IS
    v_result   NUMBER;
    v_tt_brief VARCHAR2(255);
  BEGIN
  
    v_result := 0;
  
    IF ret_flg = 0
    THEN
      v_tt_brief := 'ПрИсхВзаимозачетОпл';
    ELSE
      v_tt_brief := 'ПрИсхВзаимозачетВыпл';
    END IF;
  
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_result
      FROM trans       t
          ,trans_templ tt
          ,oper        o
          ,doc_set_off dso
          ,ac_payment  ap
          ,doc_doc     dd
     WHERE t.trans_templ_id = tt.trans_templ_id
       AND tt.brief = v_tt_brief
       AND t.oper_id = o.oper_id
       AND o.document_id = dso.doc_set_off_id
       AND dso.parent_doc_id = ap.payment_id
       AND dd.child_id = ap.payment_id
       AND dd.parent_id = p_bordero_pack_id;
  
    RETURN nvl(v_result, 0);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_pay_amount(p_bordero_pack_id NUMBER) RETURN NUMBER IS
    v_date_start DATE;
    v_date_end   DATE;
  BEGIN
    SELECT start_date
          ,end_date
      INTO v_date_start
          ,v_date_end
      FROM re_bordero_package
     WHERE re_bordero_package_id = p_bordero_pack_id;
    RETURN get_pay_pack_amount_pfa(v_date_start, v_date_end, p_bordero_pack_id);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE bordero_make_planning
  (
    p_bordero_pack_id IN NUMBER
   ,p_payment_term_id IN NUMBER
   ,ret_flg           IN NUMBER DEFAULT 0
  ) IS
    --v_Payment_ID           number;
    v_fund_id             NUMBER;
    v_fund_pay_id         NUMBER;
    v_Payment_Templ_ID    NUMBER;
    v_Rate_Type_ID        NUMBER;
    v_Company_Bank_Acc_ID NUMBER;
    v_Total_Amount        NUMBER;
    v_Payment_Term_Id     NUMBER;
    v_brief               VARCHAR2(255);
    v_reg_date            DATE;
    v_reinsurer_id        NUMBER;
    v_sum                 NUMBER;
  BEGIN
  
    IF ret_flg = 1
    THEN
      v_brief := 'PayOblOutReins';
    ELSIF ret_flg = 0
    THEN
      v_brief := 'AccOblOutReins';
    ELSE
      RETURN;
    END IF;
  
    v_sum := abs(get_calc_total(p_bordero_pack_id));
  
    v_Total_Amount := v_sum - pkg_reins_payment.get_plan_amount(p_bordero_pack_id);
    --raise_application_error(-20000, v_total_amount);
    IF v_Total_Amount > 0
    THEN
    
      SELECT mc.fund_id
            ,bp.fund_pay_id
            ,bp.reg_date
            ,mc.reinsurer_id
        INTO v_fund_id
            ,v_fund_pay_id
            ,v_reg_date
            ,v_reinsurer_id
        FROM re_main_contract       mc
            ,ven_re_bordero_package bp
       WHERE bp.re_bordero_package_id = p_bordero_pack_id
         AND mc.re_main_contract_id = bp.re_m_contract_id;
    
      SELECT pt.payment_templ_id
        INTO v_Payment_Templ_ID
        FROM ac_payment_templ pt
       WHERE pt.brief = v_brief;
    
      SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
    
      SELECT cba.id
        INTO v_Company_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
         AND cba.id = (SELECT MAX(cbas.id)
                         FROM cn_contact_bank_acc cbas
                        WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
    
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
                                                               ,v_reg_date) <> 0 THEN
                                         acc_new.Get_Rate_By_ID(v_Rate_Type_ID, v_fund_id, v_reg_date) /
                                         acc_new.Get_Rate_By_ID(v_Rate_Type_ID
                                                               ,v_fund_pay_id
                                                               ,v_reg_date) ELSE 1.0 END END
                                        ,v_reinsurer_id
                                        ,NULL
                                        ,v_Company_Bank_Acc_ID
                                        ,v_reg_date
                                        ,p_bordero_pack_id);
    END IF;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE set_payment_status(doc_id IN NUMBER) IS
    id NUMBER;
    --    v_Parent_Doc_ID    number;
    v_cover_obj_id     NUMBER;
    v_cover_ent_id     NUMBER;
    v_Oper_Templ_ID    NUMBER;
    v_Is_Accepted      NUMBER;
    v_Real_Amount      NUMBER;
    v_Plan_Amount      NUMBER;
    v_Set_Off_Amount   NUMBER;
    v_Self_Amount      NUMBER;
    v_Count            NUMBER;
    v_Amount           NUMBER;
    v_Oper_Count       NUMBER;
    v_Oper_Amount      NUMBER;
    v_Total_Amount     NUMBER;
    v_Doc_Amount       NUMBER;
    v_Doc_Templ_Brief  VARCHAR2(30);
    v_Parent_Ent_Brief VARCHAR2(30);
    v_doc_status_id    NUMBER;
    v_doc_status       doc_status%ROWTYPE;
    v_is_storno        NUMBER(1);
    v_doc_status_ref   doc_status_ref%ROWTYPE;
    v_Storno_Amount    NUMBER;
    v_Company_Brief    VARCHAR2(30);
    v_Doc_Date         DATE;
    v_Is_First         NUMBER;
    --v_Is_Renlife       NUMBER;
    v_Is_Self NUMBER;
  
    v_parent_doc_id     NUMBER;
    v_payment_total_sum NUMBER; -- сумма платежных документов
    v_total_oper_amount NUMBER; -- общая сумма начислений
    v_sum_trans         NUMBER; --сумма по проводкам
    v_remain            NUMBER; --остаток
    v_cur_remain        NUMBER; -- текущий остаток от операции
    is_finish           NUMBER;
    --v_Val_Com          NUMBER;
    --v_Prod_Line_ID     NUMBER;
    --v_st                NUMBER;
    --v_key               NUMBER;
    --v_comm_amt          NUMBER;
  
    CURSOR c_Oper_bordero_back
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id             oper_templ_id
            ,1                          is_self
            ,dsr.is_accepted
            ,rrb.ent_id
            ,rrb.rel_recover_bordero_id
            ,rrb.netto_premium
            ,0                          Plan_Amount
            ,0                          Self_Amount
            ,0                          Set_Off_Amount
        FROM re_bordero_package  bp
            ,re_bordero          b
            ,re_bordero_type     bt
            ,rel_recover_bordero rrb
            ,doc_action_type     dat
            ,doc_doc             dd
            ,document            d
            ,doc_templ           dt
            ,doc_status_action   dsa
            ,doc_status_allowed  dsal
            ,doc_templ_status    sdts
            ,doc_templ_status    ddts
            ,doc_status_ref      dsr
       WHERE dd.parent_id = bp.re_bordero_package_id --csd.c_subr_doc_id  --!!!
         AND b.re_bordero_package_id = bp.re_bordero_package_id
         AND bt.re_bordero_type_id = b.re_bordero_type_id
         AND bt.brief IN ('БОРДЕРО_ПРЕМИЙ'
                         ,'БОРДЕРО_ДОПЛАТ'
                         ,'БОРДЕРО_ИЗМЕН')
         AND rrb.re_bordero_id = b.re_bordero_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND rrb.netto_premium > 0;
  
    CURSOR c_Oper_bordero
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id              oper_templ_id
            ,1                           is_self
            ,dsr.is_accepted
            ,rrb.ent_id
            ,rrb.rel_redamage_bordero_id
            ,rrb.re_payment_sum
            ,0                           Plan_Amount
            ,0                           Self_Amount
            ,0                           Set_Off_Amount
        FROM re_bordero_package   bp
            ,re_bordero           b
            ,re_bordero_type      bt
            ,rel_redamage_bordero rrb
            ,doc_action_type      dat
            ,doc_doc              dd
            ,document             d
            ,doc_templ            dt
            ,doc_status_action    dsa
            ,doc_status_allowed   dsal
            ,doc_templ_status     sdts
            ,doc_templ_status     ddts
            ,doc_status_ref       dsr
       WHERE dd.parent_id = bp.re_bordero_package_id --csd.c_subr_doc_id  --!!!
         AND b.re_bordero_package_id = bp.re_bordero_package_id
         AND bt.re_bordero_type_id = b.re_bordero_type_id
         AND bt.brief IN ('БОРДЕРО_ОПЛ_УБЫТКОВ')
         AND rrb.re_bordero_id = b.re_bordero_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
      UNION
      SELECT dsa.obj_uro_id             oper_templ_id
            ,1                          is_self
            ,dsr.is_accepted
            ,rrb.ent_id
            ,rrb.rel_recover_bordero_id
            ,rrb.returned_premium
            ,0                          Plan_Amount
            ,0                          Self_Amount
            ,0                          Set_Off_Amount
        FROM re_bordero_package  bp
            ,re_bordero          b
            ,re_bordero_type     bt
            ,rel_recover_bordero rrb
            ,doc_action_type     dat
            ,doc_doc             dd
            ,document            d
            ,doc_templ           dt
            ,doc_status_action   dsa
            ,doc_status_allowed  dsal
            ,doc_templ_status    sdts
            ,doc_templ_status    ddts
            ,doc_status_ref      dsr
       WHERE dd.parent_id = bp.re_bordero_package_id --csd.c_subr_doc_id  --!!!
         AND b.re_bordero_package_id = bp.re_bordero_package_id
         AND bt.re_bordero_type_id = b.re_bordero_type_id
         AND bt.brief IN ('БОРДЕРО_ИЗМЕН', 'БОРДЕРО_РАСТОРЖЕНИЙ')
         AND rrb.re_bordero_id = b.re_bordero_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND rrb.netto_premium > 0;
  
    CURSOR c_Oper_slip_back
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,1 is_self
            ,dsr.is_accepted
            ,rc.ent_id
            ,rc.re_cover_id
            ,nvl(ROUND(rc.brutto_premium *
                       get_slip_rate(s.re_slip_header_id, nvl(pc.start_date, rc.start_date))
                      ,2)
                ,0) - nvl(ROUND(rc.commission *
                                get_slip_rate(s.re_slip_header_id, nvl(pc.start_date, rc.start_date))
                               ,2)
                         ,0)
            ,0 Plan_Amount
            ,0 Self_Amount
            ,0 Set_Off_Amount
        FROM re_slip            s
            ,re_cover           rc
            ,p_cover            pc
            ,doc_action_type    dat
            ,doc_doc            dd
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE dd.parent_id = s.re_slip_id
         AND rc.re_slip_id = s.re_slip_id
         AND pc.p_cover_id = rc.p_cover_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND rc.netto_premium > 0;
  
    CURSOR c_Oper_slip
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,1 is_self
            ,dsr.is_accepted
            ,rd.ent_id
            ,rd.re_damage_id
            ,nvl(ROUND(rd.RE_PAYMENT_SUM *
                       get_slip_rate(s.re_slip_header_id, nvl(pc.start_date, rec.start_date))
                      ,2)
                ,0)
            ,0 Plan_Amount
            ,0 Self_Amount
            ,0 Set_Off_Amount
        FROM re_slip            s
            ,re_claim_header    rch
            ,re_claim           rc
            ,re_damage          rd
            ,re_cover           rec
            ,p_cover            pc
            ,doc_action_type    dat
            ,doc_doc            dd
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE dd.parent_id = s.re_slip_id
         AND rch.re_slip_id = s.re_slip_id
         AND rc.re_claim_header_id = rch.re_claim_header_id
         AND rec.re_cover_id = rd.RE_COVER_ID
         AND pc.p_cover_id(+) = rec.p_cover_id
         AND doc.get_doc_status_brief(rc.re_claim_id) = 'ACCEPTED'
         AND rd.re_claim_id = rc.re_claim_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND rd.re_payment_sum > 0;
  
    CURSOR c_Oper_tant
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id      oper_templ_id
            ,1                   is_self
            ,dsr.is_accepted
            ,ts.ent_id
            ,ts.re_tant_score_id
            ,ts.total
            ,0                   Plan_Amount
            ,0                   Self_Amount
            ,0                   Set_Off_Amount
        FROM ven_re_tant_score  ts
            ,doc_action_type    dat
            ,doc_doc            dd
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE dd.parent_id = ts.re_tant_score_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
  BEGIN
  
    v_doc_status_id := Doc.get_last_doc_status_id(doc_id);
  
    SELECT ap.grace_date
          ,CASE
             WHEN ap.note = 'Первый платеж' THEN
              1
             ELSE
              0
           END
      INTO v_Doc_Date
          ,v_Is_First
      FROM ven_ac_payment ap
     WHERE ap.payment_id = doc_id;
  
    IF v_doc_status_id IS NOT NULL
    THEN
    
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      SELECT *
        INTO v_doc_status_ref
        FROM doc_status_ref dsr
       WHERE dsr.doc_status_ref_id = v_doc_status.doc_status_ref_id;
    
      SELECT c.short_name
        INTO v_Company_Brief
        FROM contact c
       WHERE c.contact_id = Pkg_App_Param.get_app_param_u('WHOAMI');
    
      IF v_doc_status_ref.brief IN ('PAID', 'CANCEL')
      THEN
        v_is_storno := 1;
      ELSE
        v_is_storno := 0;
      END IF;
    
      BEGIN
        SELECT DISTINCT e.brief
          INTO v_Parent_Ent_Brief
          FROM entity   e
              ,document d
              ,doc_doc  dd
         WHERE dd.child_id = doc_id
           AND dd.parent_id = d.document_id
           AND d.ent_id = e.ent_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_Parent_Ent_Brief := NULL;
      END;
    
      BEGIN
        SELECT dt.brief
          INTO v_Doc_Templ_Brief
          FROM document  d
              ,doc_templ dt
         WHERE d.document_id = doc_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief IN ('AccOblOutReins'
                           ,'PayOblOutReins'
                           ,'AccFakOutReins'
                           ,'PayFakOutReins'
                           ,'AccPayTant'
                           ,'AccFakInReins'
                           ,'PayFakInReins'
                           ,'PayFakInReinsOff');
      EXCEPTION
        WHEN OTHERS THEN
          v_Doc_Templ_Brief := NULL;
      END;
    
      -- создание операций(проводок) для этого статуса документа
      BEGIN
      
        IF v_Doc_Templ_Brief IS NOT NULL
        THEN
          SELECT parent_id INTO v_parent_doc_id FROM doc_doc WHERE child_id = doc_id;
        
          --сумма всех платежных документов по родительскому объекту
          SELECT nvl(SUM(ap.amount), 0) SUM
            INTO v_payment_total_sum
            FROM doc_doc        dd
                ,doc_templ      dt
                ,ven_ac_payment ap
           WHERE dd.parent_id = v_parent_doc_id
             AND ap.payment_id = dd.child_id
             AND dt.doc_templ_id = ap.doc_templ_id
             AND dt.brief = v_Doc_Templ_Brief
             AND doc.get_doc_status_brief(ap.payment_id) IN ('TO_PAY', 'PAID');
        
          v_Count  := 0;
          v_Amount := 0;
        
          --сумма платежного документа
          SELECT nvl(SUM(dd.parent_amount), 0)
            INTO v_Doc_Amount
            FROM ac_payment ap
                ,doc_doc    dd
           WHERE ap.payment_id = doc_id
             AND ap.payment_id = dd.child_id;
        
          CASE
            WHEN v_Doc_Templ_Brief = 'PayOblOutReins' THEN
              OPEN c_Oper_bordero_back(v_doc_status.src_doc_status_ref_id
                                      ,v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief = 'AccOblOutReins' THEN
              OPEN c_Oper_bordero(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
              OPEN c_Oper_slip(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief IN ('PayFakOutReins', 'AccFakInReins') THEN
              OPEN c_Oper_slip_back(v_doc_status.src_doc_status_ref_id
                                   ,v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief = 'AccPayTant' THEN
              OPEN c_Oper_tant(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            ELSE
              NULL;
          END CASE;
          LOOP
            CASE
              WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
                FETCH c_Oper_bordero_back
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_bordero_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
                FETCH c_Oper_bordero
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_bordero%NOTFOUND;
              WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
                FETCH c_Oper_slip
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_slip%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
                FETCH c_Oper_slip_back
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_slip_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccPayTant' THEN
                FETCH c_Oper_tant
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_tant%NOTFOUND;
              ELSE
                NULL;
            END CASE;
            IF v_Is_Self = 1
            THEN
              IF (v_Real_Amount > v_Plan_Amount)
              THEN
                v_Count := v_Count + 1;
                --сумма по всем объектам
                v_Amount := v_Amount + v_Real_Amount - v_Plan_Amount;
              END IF;
            END IF;
          END LOOP;
          CASE
            WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
              CLOSE c_Oper_bordero_back;
            WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
              CLOSE c_Oper_bordero;
            WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
              CLOSE c_Oper_slip_back;
            WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
              CLOSE c_Oper_slip;
            WHEN v_doc_templ_brief = 'AccPayTant' THEN
              CLOSE c_Oper_tant;
            ELSE
              NULL;
          END CASE;
        
          -- проверка на зачисление последнего платежа
          is_finish := 0;
          IF v_payment_total_sum = v_Amount
          THEN
            -- сумма платежных документов = реальной сумме
            is_finish := 1;
          END IF;
        
          --теперь нужно узнать сколько реально мы хотим начислить
          v_total_amount := 0;
          CASE
            WHEN v_Doc_Templ_Brief = 'PayOblOutReins' THEN
              OPEN c_Oper_bordero_back(v_doc_status.src_doc_status_ref_id
                                      ,v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief = 'AccOblOutReins' THEN
              OPEN c_Oper_bordero(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
              OPEN c_Oper_slip(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief IN ('PayFakOutReins', 'AccFakInReins') THEN
              OPEN c_Oper_slip_back(v_doc_status.src_doc_status_ref_id
                                   ,v_doc_status.doc_status_ref_id);
            WHEN v_Doc_Templ_Brief = 'AccPayTant' THEN
              OPEN c_Oper_tant(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            ELSE
              NULL;
          END CASE;
          LOOP
            CASE
              WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
                FETCH c_Oper_bordero_back
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_bordero_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
                FETCH c_Oper_bordero
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_bordero%NOTFOUND;
              WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
                FETCH c_Oper_slip
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_slip%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
                FETCH c_Oper_slip_back
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_slip_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccPayTant' THEN
                FETCH c_Oper_tant
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_tant%NOTFOUND;
              ELSE
                NULL;
            END CASE;
            v_Oper_Amount := (v_Real_Amount - v_Plan_Amount) * v_Doc_Amount / v_Amount;
            -- урезаем v_oper_amount, чтобы начисляемая сумма
            -- всегда была <= сумме документа
            v_Oper_Amount       := trunc(v_Oper_Amount, 2);
            v_Total_oper_Amount := nvl(v_Total_oper_Amount, 0) + nvl(v_Oper_Amount, 0);
          END LOOP;
          CASE
            WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
              CLOSE c_Oper_bordero_back;
            WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
              CLOSE c_Oper_bordero;
            WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
              CLOSE c_Oper_slip_back;
            WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
              CLOSE c_Oper_slip;
            WHEN v_doc_templ_brief = 'AccPayTant' THEN
              CLOSE c_Oper_tant;
            ELSE
              NULL;
          END CASE;
        
          --остаток по платежному документу
          v_remain := v_doc_amount - v_total_oper_amount;
        
          -- создаем операции по шаблону
          v_Oper_Count   := 0;
          v_Total_Amount := 0;
        
          CASE
            WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
              OPEN c_Oper_bordero_back(v_doc_status.src_doc_status_ref_id
                                      ,v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
              OPEN c_Oper_bordero(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
              OPEN c_Oper_slip_back(v_doc_status.src_doc_status_ref_id
                                   ,v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
              OPEN c_Oper_slip(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'AccPayTant' THEN
              OPEN c_Oper_tant(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            ELSE
              NULL;
          END CASE;
          <<outer_loop>>
          LOOP
            CASE
              WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
                FETCH c_Oper_bordero_back
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_bordero_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
                FETCH c_Oper_bordero
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_bordero%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
                FETCH c_Oper_slip_back
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_slip_back%NOTFOUND;
              WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
                FETCH c_Oper_slip
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_slip%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccPayTant' THEN
                FETCH c_Oper_tant
                  INTO v_Oper_Templ_ID
                      ,v_Is_Self
                      ,v_Is_Accepted
                      ,v_Cover_Ent_ID
                      ,v_Cover_Obj_ID
                      ,v_Real_Amount
                      ,v_Plan_Amount
                      ,v_Self_Amount
                      ,v_Set_Off_Amount;
                EXIT WHEN c_Oper_tant%NOTFOUND;
              ELSE
                NULL;
            END CASE;
          
            IF v_Is_Storno = 0
            THEN
              IF (v_Real_Amount > v_Plan_Amount)
              THEN
                v_Oper_Amount := (v_Real_Amount - v_Plan_Amount) * v_Doc_Amount / v_Amount;
                v_Oper_Amount := nvl(trunc(v_Oper_Amount, 2), 0);
              
                -- узнаем сумму по уже существующим проводкам
                -- по конкретному объекту
                SELECT nvl(SUM(t.trans_amount), 0)
                  INTO v_sum_trans
                  FROM oper    o
                      ,trans   t
                      ,doc_doc dd
                 WHERE t.oper_id = o.oper_id
                   AND o.document_id = dd.child_id
                   AND dd.parent_id = v_parent_doc_id
                   AND o.oper_templ_id = v_Oper_Templ_ID
                   AND t.obj_ure_id = v_Cover_Ent_ID
                   AND t.obj_uro_id = v_Cover_Obj_ID;
                /*raise_application_error(-20000, 'v_trans='||v_sum_trans
                ||'; v_oper='||v_oper_amount
                ||'; v_total_oper='||v_total_oper_amount
                ||'; v_count='||v_count
                ||'; v_remain='||v_remain
                );*/
              
                IF is_finish = 1
                THEN
                  -- последний платеж, поэтому начисляем все отатки
                  v_oper_amount := (v_real_amount - v_plan_amount) - v_sum_trans;
                ELSE
                  -- нужно проверить: сможем ли начислить полученную сумму или нет
                  -- это может возникнуть в тех случаях, когда до этого по данному объекту
                  -- доначислялся остаток
                  v_cur_remain := (v_sum_trans + v_Oper_Amount) - (v_real_amount - v_plan_amount);
                
                  IF v_cur_remain >= 0
                  THEN
                    --сумма превышена
                    v_remain      := v_remain + v_cur_remain;
                    v_oper_amount := (v_real_amount - v_plan_amount) - v_sum_trans;
                  ELSE
                    --cумма позволяет начислить возможный остаток
                    v_cur_remain := abs(v_cur_remain);
                  
                    IF v_cur_remain > v_remain
                    THEN
                      -- весь остаток можно начислить
                      v_oper_amount := v_oper_amount + v_remain;
                      v_remain      := 0;
                    ELSE
                      v_remain      := v_remain - v_cur_remain;
                      v_oper_amount := v_oper_amount + v_cur_remain;
                    END IF;
                  END IF;
                END IF;
                --raise_application_error(-20000, 'v_oper_amount='||v_oper_amount||
                --                                ',v_total_oper_amount='||v_total_oper_amount);
              
                BEGIN
                  IF v_oper_amount > 0
                  THEN
                    id := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID
                                                      ,doc_id
                                                      ,v_Cover_Ent_ID
                                                      ,v_Cover_Obj_ID
                                                      ,v_doc_status.doc_status_ref_id
                                                      ,1
                                                      ,v_Oper_Amount);
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    raise_application_error(-20000, 'Error in Acc_New ' || SQLERRM);
                END;
              
              END IF;
            ELSE
              v_Storno_Amount := v_Self_Amount - v_Set_Off_Amount;
              IF v_Storno_Amount > 0
              THEN
                id := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID
                                                  ,doc_id
                                                  ,v_Cover_Ent_ID
                                                  ,v_Cover_Obj_ID
                                                  ,v_doc_status.doc_status_ref_id
                                                  ,1
                                                  ,-v_Storno_Amount);
              END IF;
            END IF;
          
          END LOOP outer_loop;
          CASE
            WHEN v_doc_templ_brief = 'PayOblOutReins' THEN
              CLOSE c_Oper_bordero_back;
            WHEN v_doc_templ_brief = 'AccOblOutReins' THEN
              CLOSE c_Oper_bordero;
            WHEN v_doc_templ_brief IN ('PayFakOutReins', 'AccFakInReins') THEN
              CLOSE c_Oper_slip_back;
            WHEN v_doc_templ_brief IN ('AccFakOutReins', 'PayFakInReins', 'PayFakInReinsOff') THEN
              CLOSE c_Oper_slip;
            WHEN v_doc_templ_brief = 'AccPayTant' THEN
              CLOSE c_Oper_tant;
            ELSE
              NULL;
          END CASE;
        
        END IF;
        --raise_application_error(-20000, get_slip_to_pay_amount(v_parent_doc_id,1));
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
          raise_application_error(-20000, SQLERRM);
      END;
    END IF;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_slip_rate
  (
    p_slip_header_id IN NUMBER
   ,p_date           IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    ret_val        NUMBER := 0;
    v_fund_id      NUMBER;
    v_fund_pay_id  NUMBER;
    v_rate_type_id NUMBER;
    v_rate_val     NUMBER;
    v_flg          NUMBER;
  
    v_temp_count NUMBER;
  BEGIN
  
    SELECT sh.FUND_ID
          ,sh.FUND_PAY_ID
          ,sh.RATE_TYPE_ID
          ,sh.RATE
          ,sh.FLG_USE_RATE_POL
      INTO v_fund_id
          ,v_fund_pay_id
          ,v_rate_type_id
          ,v_rate_val
          ,v_flg
      FROM re_slip_header sh
     WHERE sh.RE_SLIP_HEADER_ID = p_slip_header_id; --!!!!!!!  
  
    --валюты одинаковые
    IF v_fund_id = v_fund_pay_id
    THEN
      RETURN 1;
    END IF;
  
    --курс на указанную дату
    IF v_flg = 1
    THEN
      ret_val := acc.get_cross_rate_by_id(v_rate_type_id, v_fund_id, v_fund_pay_id, p_date);
      RETURN nvl(ret_val, 1);
    END IF;
  
    SELECT COUNT(1)
      INTO v_temp_count
      FROM rate_type
     WHERE rate_type_id = v_rate_type_id
       AND brief = 'ФИКС';
  
    --если это фиксированный курс
    IF v_temp_count = 1
    THEN
      RETURN nvl(v_rate_val, 1);
    END IF;
  
    --выбранный курс
    ret_val := acc.get_cross_rate_by_id(v_rate_type_id, v_fund_id, v_fund_pay_id);
  
    RETURN nvl(ret_val, 1);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_bordero_rate
  (
    p_bordero_id IN NUMBER
   ,p_date       DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    ret_val        NUMBER := 0;
    v_fund_id      NUMBER;
    v_fund_pay_id  NUMBER;
    v_rate_type_id NUMBER;
    v_rate_val     NUMBER;
    v_date         DATE;
  
    v_temp_count NUMBER;
  BEGIN
  
    SELECT b.fund_id
          ,bp.fund_pay_id
          ,b.rate_type_id
          ,nvl(b.rate_val, 0)
      INTO v_fund_id
          ,v_fund_pay_id
          ,v_rate_type_id
          ,v_rate_val
      FROM re_bordero         b
          ,re_bordero_package bp
     WHERE b.re_bordero_id = p_bordero_id
       AND bp.re_bordero_package_id = b.re_bordero_package_id;
  
    IF v_fund_id <> v_fund_pay_id
    THEN
    
      -- проверка на фиксированный курс
      SELECT COUNT(1)
        INTO v_temp_count
        FROM rate_type
       WHERE rate_type_id = v_rate_type_id
         AND brief = 'ФИКС';
    
      --если курс фиксированный, то нужно взять указанное значение
      IF v_temp_count > 0
      THEN
        ret_val := v_rate_val;
      
        --если курс не фиксированный, то нужно его получить
      ELSE
        --тип курса возможно не задан => устанавливаем курс ЦБ
        IF v_rate_type_id IS NULL
        THEN
          SELECT rate_type_id INTO v_rate_type_id FROM rate_type WHERE brief = 'ЦБ';
        END IF;
      
        ret_val := acc.get_cross_rate_by_id(v_rate_type_id, v_fund_id, v_fund_pay_id, p_date);
      
      END IF;
    ELSE
      --валюты одинаковые
      ret_val := 1;
    END IF;
  
    RETURN ret_val;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_charge(p_slip_id IN NUMBER) IS
  
    v_oper_templ_charge1_id NUMBER;
    v_oper_templ_charge2_id NUMBER;
    v_op_brief1             VARCHAR2(4000);
    v_op_brief2             VARCHAR2(4000);
    v_error                 NUMBER;
    v_res_id                NUMBER;
    v_date                  DATE;
  
    v_ver_num        NUMBER;
    v_slip_header_id NUMBER;
    v_slip_id        NUMBER;
  
    v_brutto     NUMBER;
    v_commission NUMBER;
  
    v_is_in NUMBER;
  
  BEGIN
  
    SELECT sh.is_in
          ,s.ver_num
          ,s.re_slip_header_id
      INTO v_is_in
          ,v_ver_num
          ,v_slip_header_id
      FROM re_slip_header sh
          ,re_slip        s
     WHERE s.re_slip_id = p_slip_id
       AND sh.re_slip_header_id = s.re_slip_header_id;
  
    IF v_ver_num > 0
    THEN
      -- это не первая версия
      -- поэтому нужно пройтись по всем версиям,
      -- и удалить неоплаченные счета
    
      delete_non_payment_acc_fak(v_slip_header_id, 0); --удаление счетов
      delete_non_payment_acc_fak(v_slip_header_id, 1); --удаление распоряжений
    END IF;
  
    v_date := doc.get_last_doc_status_date(p_slip_id);
  
    UPDATE ven_re_slip s SET s.accept_date = v_date WHERE s.re_slip_id = p_slip_id;
  
    IF v_is_in = 0
    THEN
      v_op_brief1 := 'ОпПрИсхПремияБрНач';
      v_op_brief2 := 'ОпПрИсхКомиссияНач';
    ELSIF v_is_in = 1
    THEN
      v_op_brief1 := 'ОпПрВхПремияБрНач';
      v_op_brief2 := 'ОпПрВхКомиссияНач';
    END IF;
  
    BEGIN
      SELECT ot.oper_templ_id
        INTO v_oper_templ_charge1_id
        FROM oper_templ ot
       WHERE ot.brief = v_op_brief1;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'Невозможно получить шаблон операции "' || v_op_brief1 ||
                                '". Обратитесь к администратору системы.');
    END;
    BEGIN
      SELECT ot.oper_templ_id
        INTO v_oper_templ_charge2_id
        FROM oper_templ ot
       WHERE ot.brief = v_op_brief2;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'Невозможно получить шаблон операции "' || v_op_brief2 ||
                                '". Обратитесь к администратору системы.');
    END;
  
    BEGIN
      v_error := 0;
      FOR cur IN (SELECT rc.re_cover_id
                        ,rc.ent_id
                        ,nvl(rc.brutto_premium, 0) brutto_premium
                        ,nvl(rc.commission, 0) commission
                        ,rc.T_PRODUCT_LINE_ID
                        ,rc.P_ASSET_HEADER_ID
                        ,s.ver_num
                        ,s.re_slip_header_id
                        ,pc.START_DATE
                    FROM ven_re_cover rc
                        ,ven_re_slip  s
                        ,p_cover      pc
                   WHERE rc.re_slip_id = p_slip_id --!!!!!!!!
                     AND s.re_slip_id = rc.re_slip_id
                     AND pc.p_cover_id(+) = rc.p_cover_id)
      LOOP
        --цикл по rel_recover 2
      
        v_brutto     := ROUND(cur.brutto_premium *
                              get_slip_rate(cur.re_slip_header_id, cur.start_date)
                             ,2);
        v_commission := ROUND(cur.commission * get_slip_rate(cur.re_slip_header_id, cur.start_date), 2);
      
        --если были предыдущие версии, то проводки нужно
        --начислять исходя из уже начисленных
        IF cur.ver_num > 0
        THEN
          v_brutto     := v_brutto -
                          pkg_reins_payment.GET_SLIP_CALC_AMOUNT(cur.re_slip_header_id
                                                                ,2
                                                                ,cur.re_cover_id);
          v_commission := v_commission -
                          pkg_reins_payment.GET_SLIP_CALC_AMOUNT(cur.re_slip_header_id
                                                                ,3
                                                                ,cur.re_cover_id);
        END IF;
      
        --создаем операции по шаблону
        IF v_brutto <> 0
        THEN
          v_error := 1;
          Run_Oper_By_Template_R(v_oper_templ_charge1_id
                                ,p_slip_id
                                ,cur.ent_id
                                ,cur.re_cover_id
                                ,v_brutto);
        END IF;
        IF v_commission <> 0
        THEN
          v_error := 2;
          Run_Oper_By_Template_R(v_oper_templ_charge2_id
                                ,p_slip_id
                                ,cur.ent_id
                                ,cur.re_cover_id
                                ,v_commission);
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        CASE v_error
          WHEN 1 THEN
            raise_application_error(-20000
                                   ,'Невозможно создать операции по шаблону "' || v_op_brief1 || '".' ||
                                    SQLERRM);
          WHEN 2 THEN
            raise_application_error(-20000
                                   ,'Невозможно создать операции по шаблону "' || v_op_brief2 ||
                                    '". Обратитесь к администратору системы.');
          ELSE
            raise_application_error(-20000, SQLERRM);
        END CASE;
    END;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_claim_charge(p_claim_id IN NUMBER) IS
    v_slip_id               NUMBER;
    v_oper_templ_charge1_id NUMBER;
    v_error                 NUMBER;
    v_res_id                NUMBER;
  
    v_is_in NUMBER;
    v_brief VARCHAR2(50);
  BEGIN
  
    UPDATE ven_re_claim s
       SET s.re_claim_status_date = doc.get_status_date(p_claim_id, 'ACCEPTED')
     WHERE s.re_claim_id = p_claim_id;
  
    SELECT nvl(sh.is_in, 0)
      INTO v_is_in
      FROM re_slip_header  sh
          ,re_slip         s
          ,re_claim_header ch
          ,re_claim        c
     WHERE ch.re_CLAIM_HEADER_ID = c.RE_CLAIM_HEADER_ID
       AND s.RE_SLIP_ID = ch.RE_SLIP_ID
       AND sh.RE_SLIP_HEADER_ID = s.RE_SLIP_HEADER_ID
       AND c.RE_CLAIM_ID = p_claim_id; -- !!!!!!!
  
    IF v_is_in = 0
    THEN
      v_brief := 'ОпПрИсхВозмещНач';
    ELSE
      v_brief := 'ОпПрВхВозвратНач';
    END IF;
  
    BEGIN
      SELECT ot.oper_templ_id
        INTO v_oper_templ_charge1_id
        FROM oper_templ ot
       WHERE ot.brief = v_brief;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'Невозможно получить шаблон операции "' || v_brief ||
                                '". Обратитесь к администратору системы.');
    END;
  
    FOR cur IN (SELECT rd.ent_id
                      ,rd.re_damage_id
                      ,ROUND(rd.re_payment_sum * get_slip_rate(s.re_slip_header_id, pc.start_date), 2) re_payment_sum
                      ,rc.re_claim_id
                  FROM ven_re_claim        rc
                      ,ven_re_claim_header rch
                      ,re_slip             s
                      ,ven_re_damage       rd
                      ,c_damage            cd
                      ,p_cover             pc
                 WHERE rc.re_claim_id = p_claim_id
                   AND rch.re_claim_header_id = rc.re_claim_header_id
                   AND s.re_slip_id = rch.RE_SLIP_ID
                   AND rd.re_claim_id = rc.re_claim_id
                   AND cd.C_DAMAGE_ID = rd.damage_id
                   AND pc.p_cover_id = cd.P_COVER_ID)
    LOOP
      BEGIN
        --создаем операции по шаблону
        IF cur.re_payment_sum > 0
        THEN
          v_error := 1;
          Run_Oper_By_Template_R(v_oper_templ_charge1_id
                                ,cur.re_claim_id
                                ,cur.ent_id
                                ,cur.re_damage_id
                                ,cur.re_payment_sum);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Невозможно создать операции по шаблону "' || v_brief || '". ' ||
                                  SQLERRM);
      END;
    END LOOP;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION get_slip_amount
  (
    p_id   IN NUMBER
   ,p_type IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
  
    /*
    p_type
     0 - общая сумма слипа
     1 - сумма, которую нам должны
     2 - сумма, которую мы должны
    */
    v_in    NUMBER := 0;
    v_out   NUMBER := 0;
    v_sum   NUMBER := 0;
    v_is_in NUMBER := 0;
  
  BEGIN
  
    SELECT nvl(sh.IS_IN, 0) INTO v_is_in FROM re_slip_header sh WHERE sh.re_slip_header_id = p_id; --!!!!!!!!  
  
    IF p_type IN (0, 1)
       AND v_is_in = 0
       OR p_type IN (0, 2)
       AND v_is_in = 1
    THEN
      SELECT nvl(SUM(ROUND(rd.re_payment_sum *
                           get_slip_rate(s.re_slip_header_id, nvl(pc.start_date, rec.start_date))
                          ,2))
                ,0)
        INTO v_sum
        FROM re_slip         s
            ,re_damage       rd
            ,re_claim        rc
            ,re_claim_header rch
            ,re_cover        rec
            ,p_cover         pc
       WHERE s.re_slip_header_id = p_id --!!!!
         AND rch.re_slip_id = s.re_slip_id
         AND rc.re_claim_header_id = rch.re_claim_header_id
         AND rec.re_cover_id = rch.re_cover_id
         AND pc.p_cover_id(+) = rec.p_cover_id
         AND rd.re_claim_id = rc.re_claim_id
         AND doc.get_last_doc_status_brief(rc.re_claim_id) IN ('CLOSE', 'ACCEPTED');
    
      IF v_is_in = 0
      THEN
        v_in := v_sum;
      ELSE
        v_out := v_sum;
      END IF;
    
    END IF;
  
    IF p_type IN (0, 2)
       AND v_is_in = 0
       OR p_type IN (0, 1)
       AND v_is_in = 1
    THEN
      SELECT nvl(SUM(ROUND(rc.brutto_premium *
                           get_slip_rate(sh.re_slip_header_id, nvl(pc.start_date, rc.start_date))
                          ,2))
                ,0) -
             nvl(SUM(ROUND(rc.commission *
                           get_slip_rate(sh.re_slip_header_id, nvl(pc.start_date, rc.start_date))
                          ,2))
                ,0)
        INTO v_sum
        FROM re_cover       rc
            ,re_slip_header sh
            ,re_slip        rs
            ,p_cover        pc
       WHERE sh.re_slip_header_id = p_id --!!!!!!!!
         AND rs.re_slip_header_id = sh.re_slip_header_id
         AND rc.re_slip_id = rs.re_slip_id
         AND pc.p_cover_id = rc.p_cover_id
         AND rc.re_cover_id IN
             (SELECT DISTINCT rc1.re_cover_id
                FROM re_cover rc1
                    ,re_slip  rs1
               WHERE rs1.re_slip_id = rc1.re_slip_id
                 AND rs1.re_slip_header_id = rs.re_slip_header_id
                 AND rs1.ver_num = (SELECT MAX(rs2.ver_num)
                                      FROM re_slip  rs2
                                          ,re_cover rc2
                                     WHERE rc2.p_asset_header_id = rc1.p_asset_header_id
                                       AND rc2.t_product_line_id = rc1.t_product_line_id
                                       AND rs2.re_slip_id = rc2.re_slip_id
                                       AND rs2.re_slip_header_id = rs.re_slip_header_id));
    
      IF v_is_in = 0
      THEN
        v_out := v_sum;
      ELSE
        v_in := v_sum;
      END IF;
    
    END IF;
  
    IF p_type = 1
    THEN
      RETURN v_in;
    ELSIF p_type = 2
    THEN
      RETURN v_out;
    ELSE
      RETURN v_in - v_out;
    END IF;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_slip_calc_amount
  (
    p_slip_head_id IN NUMBER
   ,ret_flg        IN NUMBER DEFAULT 0
   ,p_obj_id       IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_sum       NUMBER;
    v_temp_sum  NUMBER;
    v_tt_brief  VARCHAR2(255);
    v_tt_brief1 VARCHAR2(255);
  
    v_asset_header_id NUMBER;
    v_product_line_id NUMBER;
  
    v_is_in NUMBER;
  BEGIN
  
    v_tt_brief  := NULL;
    v_tt_brief1 := NULL;
  
    v_sum      := 0;
    v_temp_sum := 0;
  
    SELECT nvl(sh.IS_IN, 0)
      INTO v_is_in
      FROM re_slip_header sh
     WHERE sh.re_slip_header_id = p_slip_head_id;
  
    IF v_is_in = 0
    THEN
      IF ret_flg = 0
      THEN
        v_tt_brief := 'ПрИсхВозмещНач';
      ELSIF ret_flg = 1
      THEN
        v_tt_brief  := 'ПрИсхПремияБрНач';
        v_tt_brief1 := 'ПрИсхКомиссияНач';
      ELSIF ret_flg = 2
      THEN
        v_tt_brief := 'ПрИсхПремияБрНач';
      ELSIF ret_flg = 3
      THEN
        v_tt_brief := 'ПрИсхКомиссияНач';
      ELSE
        RETURN 0;
      END IF;
    ELSIF v_is_in = 1
    THEN
      IF ret_flg = 0
      THEN
        v_tt_brief  := 'ПрВхПремияБрНач';
        v_tt_brief1 := 'ПрВхКомиссияНач';
      ELSIF ret_flg = 1
      THEN
        v_tt_brief := 'ПрВхВозвратНач';
      ELSIF ret_flg = 2
      THEN
        v_tt_brief := 'ПрВхПремияБрНач';
      ELSIF ret_flg = 3
      THEN
        v_tt_brief := 'ПрВхКомиссияНач';
      ELSE
        RETURN 0;
      END IF;
    END IF;
  
    IF v_tt_brief IS NOT NULL
       AND ret_flg <> 0
       AND v_is_in = 0
       OR v_tt_brief IS NOT NULL
       AND ret_flg <> 1
       AND v_is_in = 1
    THEN
    
      IF p_obj_id IS NOT NULL
      THEN
        SELECT P_ASSET_HEADER_ID
              ,T_PRODUCT_LINE_ID
          INTO v_asset_header_id
              ,v_product_line_id
          FROM re_cover
         WHERE re_cover_id = p_obj_id;
      ELSE
        v_asset_header_id := NULL;
        v_product_line_id := NULL;
      END IF;
    
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_sum
        FROM oper        o
            ,trans       t
            ,trans_templ tt
            ,re_slip     s
            ,entity      e
            ,re_cover    rc
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = s.re_slip_id
         AND s.re_slip_header_id = p_slip_head_id --!!!!!!!!!
         AND tt.brief = v_tt_brief
         AND e.brief = 'RE_COVER'
         AND t.OBJ_URE_ID = e.ENT_ID
         AND t.OBJ_URO_ID = rc.re_cover_id
         AND rc.P_ASSET_HEADER_ID = nvl(v_asset_header_id, rc.p_asset_header_id)
         AND rc.T_PRODUCT_LINE_ID = nvl(v_product_line_id, rc.T_PRODUCT_LINE_ID);
    
    ELSIF v_tt_brief IS NOT NULL
          AND ret_flg = 0
          AND v_is_in = 0
          OR v_tt_brief IS NOT NULL
          AND ret_flg = 1
          AND v_is_in = 1
    THEN
    
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_sum
        FROM oper            o
            ,trans           t
            ,trans_templ     tt
            ,re_slip         s
            ,re_claim_header ch
            ,re_claim        c
            ,entity          e
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = c.re_claim_id
         AND c.re_claim_header_id = ch.re_claim_header_id
         AND ch.re_slip_id = s.re_slip_id
         AND s.re_slip_header_id = p_slip_head_id --!!!!!!!!!
         AND tt.brief = v_tt_brief
         AND e.brief = 'RE_DAMAGE'
         AND t.OBJ_URE_ID = e.ENT_ID
         AND t.OBJ_URO_ID = nvl(p_obj_id, t.obj_uro_id);
    
    END IF;
  
    IF v_tt_brief1 IS NOT NULL
    THEN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_temp_sum
        FROM oper        o
            ,trans       t
            ,trans_templ tt
            ,re_slip     s
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = s.re_slip_id
         AND s.re_slip_header_id = p_slip_head_id --!!!!!!!!!
         AND tt.brief = v_tt_brief1;
    END IF;
  
    v_sum := nvl(v_sum, 0) - nvl(v_temp_sum, 0);
  
    RETURN v_sum;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_slip_plan_amount
  (
    p_id    IN NUMBER
   ,ret_flg IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_result    NUMBER;
    v_brief     VARCHAR2(255);
    v_brief_add VARCHAR2(255);
    v_st        VARCHAR2(255);
    v_is_in     NUMBER;
  BEGIN
  
    SELECT nvl(is_in, 0) INTO v_is_in FROM re_slip_header WHERE re_slip_header_id = p_id;
  
    v_brief_add := 'no use';
    v_st        := 'NEW';
  
    IF v_is_in = 0
    THEN
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakOutReins';
      ELSIF ret_flg = 1
      THEN
        v_brief := 'PayFakOutReins';
      ELSE
        RETURN 0;
      END IF;
    ELSE
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakInReins';
      ELSIF ret_flg = 1
      THEN
        v_brief     := 'PayFakInReins';
        v_brief_add := 'PayFakInReinsOff';
        --этот случай используется для поиска всех 
        --платежей данного типа в любом статусе
      ELSIF ret_flg = 2
      THEN
        v_brief := 'PayFakInReinsOff';
        v_st    := NULL;
      ELSE
        RETURN 0;
      END IF;
    END IF;
  
    BEGIN
      SELECT nvl(SUM(dd.parent_amount), 0)
        INTO v_result
        FROM doc_doc        dd
            ,ven_ac_payment ap
            ,doc_templ      dt
            ,re_slip        s
       WHERE s.re_slip_header_id = p_id --!!!!!!!!!
         AND dd.parent_id = s.re_slip_id
         AND ap.payment_id = dd.child_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief IN (v_brief, v_brief_add)
         AND doc.get_doc_status_brief(ap.payment_id) =
             nvl(v_st, doc.get_doc_status_brief(ap.payment_id));
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_make_planning
  (
    p_slip_id    IN NUMBER
   ,ret_flg      IN NUMBER DEFAULT 0
   ,p_sum        IN NUMBER DEFAULT 0
   ,p_count_bild IN NUMBER DEFAULT 0
   ,p_flg_off    IN NUMBER DEFAULT 0
  ) IS
    --v_Payment_ID           number;
    v_fund_id             NUMBER;
    v_fund_pay_id         NUMBER;
    v_Payment_Templ_ID    NUMBER;
    v_Rate_Type_ID        NUMBER;
    v_Contact_Bank_Acc_ID NUMBER;
    v_Company_Bank_Acc_ID NUMBER;
    v_Total_Amount        NUMBER;
    v_Payment_Term_Id     NUMBER;
    v_brief               VARCHAR2(255);
    v_reg_date            DATE;
    v_reinsurer_id        NUMBER;
    v_insurer_id          NUMBER;
    v_doc_id              NUMBER;
    v_amount              NUMBER;
    v_rev_rate            NUMBER;
    v_rev_amount          NUMBER;
  
    v_number      NUMBER; --номер счета
    v_count       NUMBER; --текущее количество счетов
    v_total_count NUMBER; --общее количество счетов
  
    v_date       DATE;
    v_start_date DATE;
    v_end_date   DATE;
    v_grace_date DATE;
    v_period     NUMBER;
    v_payment_id NUMBER;
  
    v_slip_header_id NUMBER;
    v_is_in          NUMBER;
    v_temp_count     NUMBER;
  
    v_num_doc VARCHAR2(200);
  BEGIN
  
    SELECT sh.re_slip_header_id
          ,sh.last_slip_id
          ,sh.fund_pay_id
          ,sh.FUND_PAY_ID
          ,sh.REINSURER_ID
          ,sh.ASSIGNOR_ID
          ,sh.IS_IN
      INTO v_slip_header_id
          ,v_doc_id
          ,v_fund_id
          ,v_fund_pay_id
          ,v_reinsurer_id
          ,v_insurer_id
          ,v_is_in
      FROM re_slip        s
          ,re_slip_header sh
     WHERE s.re_slip_id = p_slip_id --!!!!!!!!
       AND sh.re_slip_header_id = s.re_slip_header_id;
  
    IF v_is_in = 0
    THEN
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakOutReins';
      ELSIF ret_flg = 1
      THEN
        v_brief := 'PayFakOutReins';
      ELSIF ret_flg = 2
      THEN
        v_brief := 'AccFakOutReinsRet';
      ELSE
        RETURN;
      END IF;
    ELSIF v_is_in = 1
    THEN
      v_reinsurer_id := v_insurer_id;
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakInReins';
      ELSIF ret_flg = 1
      THEN
        v_brief := 'PayFakInReins';
        IF p_flg_off = 1
        THEN
          v_brief := 'PayFakInReinsOff';
        END IF;
      ELSE
        RETURN;
      END IF;
    
    END IF;
  
    IF nvl(p_sum, 0) > 0
    THEN
      v_Total_Amount := p_sum;
    ELSE
      v_temp_count := pkg_reins_payment.get_slip_calc_amount(v_slip_header_id, ret_flg);
      IF v_temp_count <= 0
      THEN
        raise_application_error(-20000, 'Нулевая сумма начислений.');
      END IF;
      v_Total_Amount := v_temp_count -
                        pkg_reins_payment.get_slip_plan_amount(v_slip_header_id, ret_flg) -
                        pkg_reins_payment.get_slip_to_pay_amount(v_slip_header_id, ret_flg) -
                        pkg_reins_payment.get_slip_set_off_amount(v_slip_header_id, 0, ret_flg);
      --если идет расчет взаимозачета, то нужно получить 
      --сумму денег по всем счетам/распоряжениям в статусе к оплате
      IF p_flg_off = 1
      THEN
        v_temp_count := 0;
        IF v_is_in = 1
        THEN
          --для входящего это сумма счетов
          v_temp_count := pkg_reins_payment.get_slip_to_pay_amount(v_slip_header_id, 0);
          --за вычетом уже созданных платежей взаимозачета
          v_temp_count := v_temp_count - pkg_reins_payment.GET_SLIP_PLAN_AMOUNT(v_slip_header_id, 2);
        END IF;
        v_total_amount := least(v_temp_count, v_total_amount);
      END IF;
    END IF;
  
    IF v_Total_Amount <= 0
    THEN
      raise_application_error(-20000
                             ,'Нулевая сумма для формирования плана-графика.');
    END IF;
  
    SELECT pt.payment_templ_id
      INTO v_Payment_Templ_ID
      FROM ac_payment_templ pt
     WHERE pt.brief = v_brief;
  
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
  
    BEGIN
      SELECT cba.id
        INTO v_Company_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
         AND cba.id = (SELECT MAX(cbas.id)
                         FROM cn_contact_bank_acc cbas
                        WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Не указан счет компании.');
    END;
    BEGIN
      SELECT cba.id
        INTO v_Contact_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = v_reinsurer_id
         AND cba.id =
             (SELECT MAX(cbas.id) FROM cn_contact_bank_acc cbas WHERE cbas.contact_id = v_reinsurer_id);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Не указан счет контакта.');
    END;
  
    IF ret_flg = 1
    THEN
      SELECT s.PAYMENT_RET_TERM_ID
        INTO v_payment_term_id
        FROM re_slip s
       WHERE s.re_slip_id = v_doc_id; --!!!!!!!!
    ELSE
      SELECT s.PAYMENT_TERM_ID INTO v_payment_term_id FROM re_slip s WHERE s.re_slip_id = v_doc_id; --!!!!!!!!
    END IF;
  
    IF v_payment_term_id IS NULL
    THEN
      SELECT pt.ID
        INTO v_payment_term_id
        FROM t_payment_terms     pt
            ,t_collection_method cm
       WHERE cm.DESCRIPTION = 'Безналичный расчет'
         AND pt.COLLECTION_METHOD_ID = cm.id
         AND pt.IS_DEFAULT = 1
         AND rownum = 1;
    END IF;
  
    --Узнаем период оплаты, через кол-во платежей в год
    SELECT 12 / pt.number_of_payments
          ,pt.IS_PERIODICAL
      INTO v_period
          ,v_temp_count
      FROM t_payment_terms pt
     WHERE pt.ID = v_payment_term_id;
  
    IF v_temp_count = 0
    THEN
      v_period := 0;
    END IF;
  
    CASE
      WHEN v_fund_id = v_fund_pay_id THEN
        v_rev_rate := 1.0;
      ELSE
        CASE
          WHEN acc_new.Get_Rate_By_ID(v_Rate_Type_ID, v_fund_pay_id, v_reg_date) <> 0 THEN
            v_rev_rate := acc_new.Get_Rate_By_ID(v_Rate_Type_ID, v_fund_id, v_reg_date) /
                          acc_new.Get_Rate_By_ID(v_Rate_Type_ID, v_fund_pay_id, v_reg_date);
          ELSE
            v_rev_rate := 1.0;
        END CASE;
    END CASE;
  
    --нужно узнать сколько платежей уже было
    SELECT COUNT(1)
      INTO v_count
      FROM re_slip        s
          ,doc_doc        dd
          ,ven_ac_payment ap
          ,doc_templ      dt
     WHERE s.re_slip_header_id = v_slip_header_id
       AND dd.parent_id = s.re_slip_id
       AND ap.payment_id = dd.child_id
       AND dt.DOC_TEMPL_ID = ap.DOC_TEMPL_ID
       AND dt.BRIEF = v_brief;
  
    v_number := v_count + 1; -- очередной номер платежа
  
    --нужно узнать, сколько еще платежей нужно
    --для этого нужно узнать дату последнего платежа
    v_start_date := NULL;
  
    IF v_number = 1
    THEN
      --создаем первый платеж
    
      --возможно указана дата первого платежа на слипе
      SELECT CASE ret_flg
               WHEN 1 THEN
                first_ret_pay_date
               WHEN 0 THEN
                first_pay_date
             END
        INTO v_start_date
        FROM re_slip
       WHERE re_slip_id = v_doc_id; -- берем актуальную версию
    
      IF v_start_date IS NULL
      THEN
        --тогда дата начала договора
        SELECT start_date INTO v_start_date FROM re_slip WHERE re_slip_id = v_doc_id;
      
        --обновляем начальную дату платежа
        IF ret_flg = 1
        THEN
          UPDATE re_slip SET first_ret_pay_date = v_start_date WHERE re_slip_id = v_doc_id;
        ELSE
          UPDATE re_slip SET first_pay_date = v_start_date WHERE re_slip_id = v_doc_id;
        END IF;
      END IF;
    ELSE
      --это не первый платеж
      -- тогда берем предельную дату последнего платежа
    
      SELECT grace_date
        INTO v_start_date
        FROM ven_ac_payment ap
            ,doc_doc        dd
            ,re_slip        s
            ,doc_templ      dt
       WHERE s.re_slip_header_id = v_slip_header_id
         AND dd.parent_id = s.re_slip_id
         AND ap.payment_id = dd.child_id
         AND ap.PAYMENT_NUMBER = v_number - 1
         AND dt.doc_templ_id = ap.doc_templ_id
         AND dt.brief = v_brief;
      --возможно здесь будет ошибка, если не позаботиться о том, 
      --чтобы нельзя было удалять счета из середины списка
    END IF;
  
    --ну и предельной датой платежа должна быть датой окончания слина
    SELECT end_date INTO v_end_date FROM re_slip WHERE re_slip_id = v_doc_id;
  
    --теперь, наконец-то, можно узнать сколько всего нужно платежей
    v_date        := v_start_date;
    v_total_count := v_number;
    LOOP
      IF v_period > 0
      THEN
        v_date := ADD_MONTHS(v_date, v_period);
      ELSE
        v_date := v_end_date;
      END IF;
      EXIT WHEN v_date >= v_end_date;
      v_total_count := v_total_count + 1;
    END LOOP;
  
    --raise_application_error(-20000, 'total payments = '||v_total_count);
  
    v_date := v_start_date;
  
    --общее кол-во платежей указано однозначно
    IF nvl(p_count_bild, 0) > 0
    THEN
      v_total_count := v_number + p_count_bild - 1;
    END IF;
  
    v_amount := trunc(v_Total_Amount / (v_total_count - v_number + 1), 2);
  
    LOOP
    
      EXIT WHEN v_number > v_total_count;
    
      IF v_period = 0
      THEN
        v_grace_date := v_end_date;
      ELSE
        v_grace_date := least(v_end_date, ADD_MONTHS(v_date, v_period));
      END IF;
    
      IF v_number + 1 > v_total_count
      THEN
        --это последний платеж
        --поэтому на него вешаем весь остаток
        v_amount := v_total_amount;
      END IF;
    
      v_rev_amount := v_amount * v_rev_rate;
    
      SELECT num INTO v_num_doc FROM document WHERE document_id = v_doc_id;
      UPDATE document
         SET num = v_num_doc || '-' || substr(v_brief, 1, 1) || decode(p_flg_off, 1, 'O', '')
       WHERE document_id = v_doc_id;
    
      v_payment_id := pkg_payment.create_paymnt_by_templ(v_Payment_Templ_ID
                                                        ,v_Payment_Term_ID
                                                        ,v_number --!!!!
                                                        ,v_date --!!!!
                                                        ,v_grace_date --!!!!
                                                        ,v_amount --!!!!
                                                        ,v_fund_id
                                                        ,v_rev_amount
                                                        ,v_fund_pay_id
                                                        ,v_rate_type_id
                                                        ,v_rev_rate
                                                        ,v_reinsurer_id
                                                        ,v_Contact_Bank_Acc_ID
                                                        ,v_Company_Bank_Acc_ID
                                                        ,NULL --p_note
                                                        ,v_doc_id);
    
      UPDATE document SET num = v_num_doc WHERE document_id = v_doc_id;
    
      v_date         := ADD_MONTHS(v_date, v_period);
      v_number       := v_number + 1;
      v_total_amount := v_total_amount - v_amount;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      --raise_application_error(-20000, 'p_slip_id='||p_slip_id||',v_doc_id='||v_doc_id||';'||sqlerrm);
      raise_application_error(-20000
                             ,'Ошибка формирования графика. ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION get_slip_to_pay_amount
  (
    p_id    IN NUMBER
   ,ret_flg NUMBER
  ) RETURN NUMBER IS
    v_result    NUMBER;
    v_brief     VARCHAR2(255);
    v_brief_add VARCHAR2(255);
  
    v_is_in NUMBER;
  
  BEGIN
  
    /*К оплате означает
    Сумма всех счетов за вычетом
    - cумма запланированных
    - сумма оплаченных
    */
  
    SELECT is_in INTO v_is_in FROM re_slip_header WHERE re_slip_header_id = p_id;
  
    v_brief_add := 'not use';
  
    IF v_is_in = 0
    THEN
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakOutReins';
      ELSE
        v_brief := 'PayFakOutReins';
      END IF;
    ELSE
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakInReins';
      ELSE
        v_brief     := 'PayFakInReins';
        v_brief_add := 'PayFakInReinsOff';
      END IF;
    END IF;
  
    --cумма всех
    SELECT NVL(SUM(ac.amount), 0)
      INTO v_result
      FROM DOC_DOC        dd
          ,ven_ac_payment ac
          ,DOC_TEMPL      dt
          ,re_slip        s
     WHERE s.re_slip_header_id = p_id --!!!!!
       AND dd.parent_id = s.re_slip_id
       AND ac.PAYMENT_ID = dd.CHILD_ID
       AND ac.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
       AND dt.BRIEF IN (v_brief, v_brief_add);
  
    v_result := v_result - get_slip_plan_amount(p_id, ret_flg) -
                get_slip_set_off_amount(p_id, 0, ret_flg);
  
    RETURN v_result;
  
  EXCEPTION
    WHEN OTHERS THEN
      v_result := 0;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_slip_set_off_amount
  (
    p_id       IN NUMBER
   ,p_doc_type NUMBER
   ,ret_flg    NUMBER
  ) RETURN NUMBER IS
  
    v_sum    NUMBER := 0;
    v_result NUMBER := 0;
  
    v_id NUMBER;
  
    v_tt_brief     VARCHAR2(255);
    v_tt_brief_add VARCHAR2(255);
    v_is_in        NUMBER;
  
  BEGIN
  
    v_tt_brief_add := 'not use';
  
    IF p_doc_type = 0
    THEN
      SELECT nvl(sh.is_in, 0) INTO v_is_in FROM re_slip_header sh WHERE sh.re_slip_header_id = p_id;
    ELSIF p_doc_type = 1
    THEN
      SELECT nvl(sh.is_in, 0)
        INTO v_is_in
        FROM re_slip_header sh
            ,re_slip        s
       WHERE s.re_slip_id = p_id
         AND sh.re_slip_header_id = s.re_slip_header_id;
    ELSIF p_doc_type = 2
    THEN
      BEGIN
        SELECT nvl(sh.is_in, 0)
          INTO v_is_in
          FROM re_slip_header sh
              ,re_slip        s
              ,doc_doc        dd
         WHERE dd.CHILD_ID = p_id
           AND s.re_slip_id = dd.PARENT_ID
           AND sh.re_slip_header_id = s.re_slip_header_id;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN 0;
      END;
    END IF;
  
    IF v_is_in = 0
    THEN
      IF ret_flg = 1
      THEN
        v_tt_brief := 'ПрИсхПремияНтОпл';
      ELSIF ret_flg = 0
      THEN
        v_tt_brief := 'ПрИсхВозмещОпл';
      ELSE
        RETURN 0;
      END IF;
    ELSE
      IF ret_flg = 0
      THEN
        v_tt_brief := 'ПрВхПремияОпл';
      ELSIF ret_flg = 1
      THEN
        v_tt_brief     := 'ПрВхВозвратОпл';
        v_tt_brief_add := 'ПрВхВозвратОплВзв';
      ELSE
        RETURN 0;
      END IF;
    END IF;
  
    IF p_doc_type = 0
    THEN
      --заголовок слипа
      SELECT NVL(SUM(t.acc_amount), 0)
        INTO v_result
        FROM TRANS       t
            ,TRANS_TEMPL tt
            ,OPER        o
            ,DOC_SET_OFF dso
            ,doc_doc     dd
            ,re_slip     s
       WHERE s.re_slip_header_id = p_id --!!!!!!
         AND dd.parent_id = s.re_slip_id
         AND dso.parent_doc_id = dd.child_id
         AND o.document_id = dso.doc_set_off_id
         AND t.oper_id = o.oper_id
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.brief IN (v_tt_brief, v_tt_brief_add);
    
    ELSIF p_doc_type = 1
    THEN
      --слип
      SELECT NVL(SUM(t.acc_amount), 0)
        INTO v_result
        FROM TRANS       t
            ,TRANS_TEMPL tt
            ,OPER        o
            ,DOC_SET_OFF dso
            ,doc_doc     dd
       WHERE dd.parent_id = p_id --!!!!!!
         AND dso.parent_doc_id = dd.child_id
         AND o.document_id = dso.doc_set_off_id
         AND t.oper_id = o.oper_id
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.brief IN (v_tt_brief, v_tt_brief_add);
    
    ELSIF p_doc_type = 2
    THEN
      --платежный документ
      SELECT NVL(SUM(t.acc_amount), 0)
        INTO v_result
        FROM TRANS       t
            ,TRANS_TEMPL tt
            ,OPER        o
            ,DOC_SET_OFF dso
       WHERE (dso.parent_doc_id = p_id --!!!!!!
             OR dso.CHILD_DOC_ID = p_id)
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.brief IN (v_tt_brief, v_tt_brief_add);
    END IF;
  
    RETURN v_result;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_slip_pay_amount_pfa
  (
    p_id    NUMBER
   ,ret_flg NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_result   NUMBER;
    v_tt_brief VARCHAR2(255);
  BEGIN
  
    RETURN get_slip_set_off_amount(p_id, 0, ret_flg);
  
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE SLIP_ABORT(p_slip_id NUMBER) IS
    v_date     DATE;
    v_st_brief VARCHAR2(255);
  BEGIN
  
    --эта процедура вызывается дважды
    --1. при переходе из Акцептован -> Готовится к расторжению
    --2. Готовится к расторжению -> Расторгнут
  
    v_st_brief := doc.get_doc_status_brief(p_slip_id);
  
    --Готовится к расторжению 
    IF v_st_brief = 'READY_TO_CANCEL'
    THEN
    
      SELECT sh.abort_date
        INTO v_date
        FROM re_slip_header sh
            ,re_slip        s
       WHERE s.re_slip_id = p_slip_id
         AND sh.re_slip_header_id = s.re_slip_header_id;
    
      --если пытаются изменить статус не через интерфейс,
      --а обычной сменой статуса
      IF v_date IS NULL
      THEN
        raise_application_error(-20000
                               ,'Неверно указаны условия расторжения.');
      END IF;
    
      --Расторгнут
    ELSIF v_st_brief = 'BREAK'
    THEN
      NULL;
    END IF;
  
    --pkg_reins.change_slip_st(p_slip_id);
    --pkg_reins_payment.slip_charge(p_slip_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Ошибка расторжения слипа. ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE delete_non_payment_acc_fak
  (
    p_id    NUMBER
   ,ret_flg NUMBER DEFAULT 0
  ) IS
    v_id  NUMBER;
    v_num NUMBER;
  
    v_brief     VARCHAR2(255);
    v_brief_add VARCHAR2(255);
  
    v_sum_set_off NUMBER;
  
    v_is_in NUMBER;
  BEGIN
  
    v_brief_add := 'not use';
  
    SELECT sh.is_in INTO v_is_in FROM re_slip_header sh WHERE sh.re_slip_header_id = p_id;
  
    IF v_is_in = 0
    THEN
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakOutReins';
      ELSE
        v_brief := 'PayFakOutReins';
      END IF;
    ELSIF v_is_in = 1
    THEN
      IF ret_flg = 0
      THEN
        v_brief := 'AccFakInReins';
      ELSE
        v_brief     := 'PayFakInReins';
        v_brief_add := 'PayFakInReinsOff';
      END IF;
    ELSE
      RETURN;
    END IF;
  
    FOR cur IN (SELECT ap.amount
                      ,ap.REV_RATE
                      ,ap.REV_AMOUNT
                      ,ap.PAYMENT_ID
                  FROM doc_doc        dd
                      ,ven_ac_payment ap
                      ,doc_templ      dt
                      ,re_slip        s
                 WHERE s.re_slip_header_id = p_id --!!!!!!!!
                   AND dd.parent_id = s.re_slip_id
                   AND dd.child_id = ap.PAYMENT_ID
                   AND ap.DOC_TEMPL_ID = dt.doc_templ_id
                   AND dt.BRIEF IN (v_brief, v_brief_add)
                 ORDER BY ap.PAYMENT_NUMBER)
    LOOP
    
      --Получаем сумму зачета
      --if p_type_doc = 1 then
      v_sum_set_off := get_slip_set_off_amount(cur.payment_id, 2, ret_flg);
      --end if;
    
      --raise_application_error(-20000, v_sum_set_off);
    
      IF v_sum_set_off = 0
      THEN
        --нет зачета
      
        DELETE oper
         WHERE document_id IN
               (SELECT dso.doc_set_off_id FROM doc_set_off dso WHERE dso.parent_doc_id = cur.payment_id);
      
        DELETE doc_set_off WHERE parent_doc_id = cur.payment_id;
      
        DELETE oper WHERE document_id = cur.payment_id;
      
        DELETE ac_payment WHERE payment_id = cur.payment_id;
      
      ELSIF v_sum_set_off < cur.rev_amount
      THEN
        -- неполный зачет
        UPDATE ac_payment
           SET rev_amount = v_sum_set_off
              ,amount     = ROUND(v_sum_set_off / cur.rev_rate, 2)
         WHERE payment_id = cur.payment_id;
      
        UPDATE doc_doc dd
           SET dd.CHILD_AMOUNT  = ROUND(v_sum_set_off / cur.rev_rate, 2)
              ,dd.PARENT_AMOUNT = v_sum_set_off
         WHERE dd.child_id = cur.payment_id
           AND dd.parent_id = p_id;
      
        DELETE oper WHERE document_id = cur.payment_id;
      
        set_payment_status(cur.payment_id);
      
        doc.set_doc_status(cur.payment_id, 'PAID');
      END IF;
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Ошибка при удалении неоплаченных счетов. ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_finalize(p_slip_id NUMBER) IS
  
    v_ret_flg NUMBER;
    v_sum     NUMBER;
  
    v_slip_head_id NUMBER;
    v_slip_id      NUMBER;
  
    v_doc_st_brief VARCHAR2(200);
  
  BEGIN
  
    v_slip_id := p_slip_id;
  
    v_doc_st_brief := doc.get_doc_status_brief(p_slip_id);
    IF v_doc_st_brief = 'ACCEPTED'
    THEN
      BEGIN
        SELECT s.re_slip_id
          INTO v_slip_id
          FROM re_slip s_cur
              ,re_slip s
         WHERE s.re_slip_header_id = s_cur.re_slip_header_id
           AND s.ver_num = s_cur.ver_num - 1;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  
    --нужно проверить превышает ли сумма выплаченных
    --сумму начисленных
  
    SELECT re_slip_header_id INTO v_slip_head_id FROM re_slip WHERE re_slip_id = v_slip_id;
  
    -- проверяем это относительно распоряжений
    v_ret_flg := 1;
    v_sum     := pkg_reins_payment.GET_SLIP_CALC_AMOUNT(v_slip_head_id, v_ret_flg) -
                 pkg_reins_payment.GET_SLIP_SET_OFF_AMOUNT(v_slip_head_id, 0, v_ret_flg);
  
    --raise_application_error(-20000, 'v_sum = '||v_sum);
  
    IF v_sum < 0
    THEN
      BEGIN
        pkg_reins_payment.SLIP_MAKE_PLANNING(v_slip_id, 1 - v_ret_flg, v_sum * (-1), 1);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Ошибка создания платежа.' || SQLERRM);
      END;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Ошибка завершения слипа.' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE TANT_CHARGE(p_id NUMBER) IS
  
    v_oper_templ_charge_id NUMBER;
  
    v_date   DATE;
    v_ent_id NUMBER;
    v_sum    NUMBER;
  
    v_res_id NUMBER;
  
  BEGIN
  
    v_date := SYSDATE;
  
    UPDATE ven_re_tant_score ts SET ts.accept_date = v_date WHERE ts.re_tant_score_id = p_id;
  
    SELECT ts.TOTAL
          ,ts.ENT_ID
      INTO v_sum
          ,v_ent_id
      FROM ven_re_tant_score ts
     WHERE ts.re_tant_score_id = p_id;
  
    BEGIN
      SELECT ot.oper_templ_id
        INTO v_oper_templ_charge_id
        FROM oper_templ ot
       WHERE ot.brief = 'ОпПрИсхТантьемаНач';
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'Невозможно получить шаблон операции "ОпПрИсхТантьемаНач". Обратитесь к администратору системы.');
    END;
  
    BEGIN
      --создаем операции по шаблону
      IF v_sum <> 0
      THEN
        v_res_id := acc_new.Run_Oper_By_Template(v_oper_templ_charge_id
                                                ,p_id
                                                ,v_ent_id
                                                ,p_id
                                                ,doc.get_doc_status_id(p_id)
                                                ,1
                                                ,v_sum
                                                ,'INS');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'Невозможно создать операции по шаблону "ОпПрИсхТантьемаНач". ' ||
                                SQLERRM);
    END;
  
    --создаем платеж
    tant_make_planning(p_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,
                              -- 'Ошибка начисления тантьемы. '||
                              SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE tant_make_planning(p_id NUMBER) IS
    v_payment_id NUMBER;
  
    v_Payment_Templ_ID NUMBER;
    v_payment_term_id  NUMBER;
    v_reinsurer_id     NUMBER;
  
    v_Company_Bank_Acc_ID NUMBER;
    v_Contact_Bank_Acc_ID NUMBER;
  
    v_amount       NUMBER;
    v_number       NUMBER;
    v_date         DATE;
    v_grace_date   DATE;
    v_fund_id      NUMBER;
    v_fund_pay_id  NUMBER;
    v_rate_type_id NUMBER;
    v_rev_rate     NUMBER;
    v_rev_amount   NUMBER;
  BEGIN
  
    v_amount := nvl(get_tant_calc(p_id), 0);
  
    IF v_amount < 0
    THEN
      RETURN;
    END IF;
  
    SELECT pt.payment_templ_id
      INTO v_Payment_Templ_ID
      FROM ac_payment_templ pt
     WHERE pt.brief = 'AccPayTant';
  
    SELECT pt.ID
      INTO v_payment_term_id
      FROM t_payment_terms     pt
          ,t_collection_method cm
     WHERE cm.DESCRIPTION = 'Безналичный расчет'
       AND pt.COLLECTION_METHOD_ID = cm.id
       AND pt.IS_DEFAULT = 1
       AND rownum = 1;
  
    SELECT mc.fund_id
          ,mc.REINSURER_ID
      INTO v_fund_id
          ,v_reinsurer_id
      FROM re_tant_score    ts
          ,re_tantieme      t
          ,re_main_contract mc
     WHERE ts.re_tant_score_id = p_id
       AND t.re_tantieme_id = ts.re_tantieme_id
       AND mc.re_main_contract_id = t.re_main_contract_id;
  
    BEGIN
      SELECT cba.id
        INTO v_Company_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
         AND cba.id = (SELECT MAX(cbas.id)
                         FROM cn_contact_bank_acc cbas
                        WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Не указан счет компании.');
    END;
    BEGIN
      SELECT cba.id
        INTO v_Contact_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = v_reinsurer_id
         AND cba.id =
             (SELECT MAX(cbas.id) FROM cn_contact_bank_acc cbas WHERE cbas.contact_id = v_reinsurer_id);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Не указан счет контакта.');
    END;
  
    v_number     := 1;
    v_date       := SYSDATE;
    v_grace_date := ADD_MONTHS(v_date, 3);
  
    v_fund_pay_id := v_fund_id;
  
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
  
    v_rev_rate   := 1;
    v_rev_amount := v_amount;
  
    BEGIN
      v_payment_id := pkg_payment.create_paymnt_by_templ(v_Payment_Templ_ID
                                                        ,v_Payment_Term_ID
                                                        ,v_number
                                                        ,v_date
                                                        ,v_grace_date
                                                        ,v_amount
                                                        ,v_fund_id
                                                        ,v_rev_amount
                                                        ,v_fund_pay_id
                                                        ,v_rate_type_id
                                                        ,v_rev_rate
                                                        ,v_reinsurer_id
                                                        ,v_Contact_Bank_Acc_ID
                                                        ,v_Company_Bank_Acc_ID
                                                        ,NULL --p_note
                                                        ,p_id);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,
                                -- 'Ошибка счета тантьемы. '||
                                SQLERRM);
    END;
  END;

  --------------------------------------------------------------------------------
  -------------------------------------------------------------------------------- 

  PROCEDURE TANT_TO_PAY_CHARGE(p_id NUMBER) IS
  BEGIN
    set_payment_status(p_id);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_tant_calc(p_id NUMBER) RETURN NUMBER IS
  
    v_tt_brief VARCHAR2(50);
    v_sum      NUMBER;
  
  BEGIN
    v_tt_brief := 'ПрИсхТантьемаНач';
  
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_sum
      FROM oper        o
          ,trans       t
          ,trans_templ tt
     WHERE t.trans_templ_id = tt.trans_templ_id
       AND t.oper_id = o.oper_id
       AND o.document_id = p_id --!!!!!!!!!
       AND tt.brief = v_tt_brief;
  
    RETURN v_sum;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_tant_set_off(p_id NUMBER) RETURN NUMBER IS
    v_sum NUMBER;
  BEGIN
    SELECT NVL(SUM(t.acc_amount), 0)
      INTO v_sum
      FROM TRANS       t
          ,TRANS_TEMPL tt
          ,OPER        o
          ,DOC_SET_OFF dso
     WHERE dso.parent_doc_id = p_id --!!!!!!
       AND o.document_id = dso.doc_set_off_id
       AND o.oper_id = t.oper_id
       AND t.trans_templ_id = tt.trans_templ_id
       AND tt.brief = 'ПрИсхТантьемаОпл';
    RETURN v_sum;
  END;

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  FUNCTION GET_ACC_4_FAK_IN
  (
    p_Entity_ID NUMBER
   ,p_Object_ID NUMBER
   ,p_Fund_ID   NUMBER
   ,p_Date      DATE
   ,p_Doc_ID    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
  
    v_acc_id          NUMBER;
    v_doc_templ_brief VARCHAR2(50);
    v_account_num     VARCHAR2(20);
  BEGIN
  
    --raise_application_error(-20000, 'p_obj_id='||p_object_id||',p_ent_id='||p_entity_id);
  
    BEGIN
      SELECT dt.BRIEF
        INTO v_doc_templ_brief
        FROM document  d
            ,doc_templ dt
       WHERE dt.DOC_TEMPL_ID = d.DOC_TEMPL_ID
         AND d.DOCUMENT_ID = p_doc_id; --!!!!!!!!!!
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, 'p_doc_id=' || p_doc_id || SQLERRM);
    END;
  
    IF v_doc_templ_brief = 'PayFakInReinsOff'
    THEN
      v_account_num := '77.03.03';
    ELSE
      v_account_num := '77.00.01';
    END IF;
  
    SELECT account_id INTO v_acc_id FROM account WHERE num = v_account_num;
  
    RETURN v_acc_id;
  END;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

END;
/
