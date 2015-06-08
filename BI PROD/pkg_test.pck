CREATE OR REPLACE PACKAGE pkg_test IS

-- Author  : ABUDKOVA
-- Created : 14.09.2007 16:03:59
-- Purpose : 

END pkg_test;
/
CREATE OR REPLACE PACKAGE BODY pkg_test IS
  ---///процедура производит расчет основного агентского вознаграждения (ОАВ) по конкретному агенту
  PROCEDURE av_oav_one
  (
    p_vedom_id       IN NUMBER --иди ведомости расчета вознаграждений посреднику
   ,p_data_begin     IN DATE --дата начала отчетного периода
   ,policy_agent_id  IN NUMBER -- Ид агента по договору страхзования
   ,p_method_payment IN NUMBER --метод расчета АВ(от пулученной премии , от годовой премии)
   ,p_category_id    IN NUMBER --категория агента
   ,p_err_code       IN OUT NUMBER --ошибки выполнения функции
  ) IS
  
    v_err_num      NUMBER := 0;
    v_ag_ch_id     NUMBER;
    v_ag_av_id     NUMBER;
    v_type_r_brief VARCHAR2(100);
    CURSOR k_tran IS
      SELECT t.trans_id -- иди транзакции
            ,pac.p_policy_agent_com_id
            ,pac.ag_type_defin_rate_id
            ,pac.ag_type_rate_value_id
            ,pac.t_prod_coef_type_id
            ,pac.val_com
            ,pa.part_agent -- доля агента в договоре
            ,pp.policy_id -- иди версии договора страхования
            ,t.trans_date -- дата транзакции
            ,t.acc_amount -- сумма в валюте счета по оплате премии
            ,t.acc_rate -- курс 
            ,NVL(pt.number_of_payments, 1) NOP -- количество выплат в году
            ,NVL(pp.premium, 0) GP -- сумма премии
            ,ph.start_date -- дата начала договора страхования
            ,'PERCENT' brief -- краткое наименование доли агента
        FROM ven_ac_payment      acp1 -- счет
            ,ac_payment_templ    apt
            ,doc_set_off         dso
            ,oper                o
            ,trans               t
            ,trans_templ         tt
            ,p_policy            pp
            ,p_policy_agent      pa -- aгенты по договору страхования
            ,p_pol_header        ph -- заголовок договора страхования
            ,p_policy_agent_com  pac
            ,t_payment_terms     pt
            ,t_prod_line_option  plo -- группа рисков по полиси (программа страхования)
            ,policy_agent_status pas -- статусы агентов по договору страхования
       WHERE apt.payment_templ_id = acp1.payment_templ_id
         AND apt.brief = 'PAYMENT'
         AND dso.parent_doc_id = acp1.payment_id -- счет
         AND doc.get_doc_status_brief(acp1.payment_id, SYSDATE) = 'PAID'
         AND dso.doc_set_off_id = o.document_id
         AND o.oper_id = t.oper_id
         AND tt.trans_templ_id = t.trans_templ_id
         AND tt.brief = 'СтраховаяПремияОплачена'
         AND NOT EXISTS
       (SELECT 1
                FROM trans tr
               WHERE tr.oper_id = o.oper_id
               GROUP BY tr.oper_id
              HAVING MAX(tr.trans_date) > last_day(p_data_begin)) -- дата окончания периода
         AND t.a2_ct_uro_id = pp.policy_id
         AND t.a4_ct_uro_id = plo.id
         AND ph.policy_header_id = pa.policy_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pac.p_policy_agent_id = pa.p_policy_agent_id
         AND pt.id = pp.payment_term_id
         AND plo.product_line_id = pac.t_product_line_id
         AND pa.status_id = pas.policy_agent_status_id
            --агент действовал или действует на дату окончания периода
         AND (pas.brief IN ('CURRENT', 'CANCEL') AND pa.date_end >= LAST_DAY(p_data_begin) AND
             pa.date_start < LAST_DAY(p_data_begin))
         AND pa.p_policy_agent_id = policy_agent_id -- выборка по конкретному агенту УСЛОВИЕ ДЛ ПРОЦЕДУРЫ
            -- нет в предыдущих расчетах этих проводок 
         AND NOT EXISTS (SELECT arc.agent_report_cont_id
                FROM agent_report_cont arc
               WHERE arc.p_policy_agent_com_id = pac.p_policy_agent_com_id
                 AND arc.trans_id = t.trans_id);
  
    v_tran k_tran%ROWTYPE;
    v_OAV  NUMBER := 0;
    v_SAV  NUMBER := 0;
    --v_category_brief          number;
    --v_count                   number :=0;
    v_report_id  NUMBER;
    v_part_agent NUMBER;
    v_r_brief    VARCHAR2(50);
  BEGIN
    SELECT pa3.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ven_p_policy_agent pa3
     WHERE pa3.p_policy_agent_id = policy_agent_id;
  
    SELECT t.t_ag_av_id INTO v_ag_av_id FROM ven_t_ag_av t WHERE t.brief = 'ОАВ';
  
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    BEGIN
      SELECT ar.agent_report_id
        INTO v_report_id
        FROM ven_agent_report ar
       WHERE v_ag_ch_id = ar.ag_contract_h_id
         AND ar.ag_vedom_av_id = p_vedom_id
      --and   ar.pr_part_agent    = v_part_agent
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_report_id := 0;
    END;
  
    -- при отсутствии записи в agent_report гененриться новая запись
    IF v_report_id = 0
    THEN
      v_report_id := pkg_agent_rate.av_insert_report(p_vedom_id
                                                    ,v_ag_ch_id
                                                    ,v_ag_av_id
                                                    ,v_part_agent
                                                    ,p_err_code);
    END IF;
  
    OPEN k_tran;
    LOOP
      FETCH k_tran
        INTO v_tran.trans_id
            ,v_tran.p_policy_agent_com_id
            ,v_tran.ag_type_defin_rate_id
            ,v_tran.ag_type_rate_value_id
            ,v_tran.t_prod_coef_type_id
            ,v_tran.val_com
            ,v_tran.part_agent
            ,v_tran.policy_id
            ,v_tran.trans_date
            ,v_tran.acc_amount
            ,v_tran.acc_rate
            ,v_tran.nop
            ,v_tran.gp
            ,v_tran.start_date
            ,v_tran.brief;
      EXIT WHEN k_tran%NOTFOUND;
      -- начальные значения переменных
      v_OAV := 0;
      v_SAV := 0;
    
      Pkg_Agent_Rate.date_pay := v_tran.trans_date;
      v_sav                   := Pkg_Agent_Rate.get_rate_oab(v_tran.p_policy_agent_com_id);
    
      BEGIN
        SELECT rv.brief
          INTO v_r_brief
          FROM ven_ag_type_rate_value rv
         WHERE rv.ag_type_rate_value_id = v_tran.ag_type_rate_value_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_r_brief := '0';
      END;
      IF v_r_brief = 'ABSOL'
      THEN
        v_oav := v_sav * v_tran.part_agent / 100;
      ELSIF v_r_brief = 'PERCENT'
      THEN
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) * v_tran.acc_amount;
      ELSE
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) * v_tran.acc_amount;
        ---ошибка
      END IF;
    
      -- определение BRIEF категории агента
      /*   begin
          select ca.brief into v_category_brief
          from ven_ag_category_agent ca
          where ca.ag_category_agent_id = p_category_id;
         exception when others then raise_application_error(sqlcode,'определение BRIEF категории агента '||sqlerrm);
          --p_err_num:=sqlcode;
         end;
         -- анализ категории агента
         if v_category_brief ='BZ' then
              --- ????? вызов функции по расчету САВ
              -- расчет ОАВ
              null;
         else
              -- анализ метода расчета: '0' = от полученной премии ,'1' = от годовой премии
              if p_method_payment = 0 then
                 --- ????? вызов функции по расчету САВ
                 -- расчет ОАВ
                 null;
              else
                    --анализ v_tran.nop (number_of_payments) -- количества выплат в году
                    if v_tran.nop = 1
                       then
                       --- ????? вызов функции по расчету САВ
                       -- расчет ОАВ
                       null;
                    elsif v_tran.nop <> 1 and  v_tran.start_date >= add_months(p_data_begin,12) -- менее года
                       then
                       --- ????? вызов функции по расчету САВ
                       -- расчет1 ОАВ (без учета процентов)
                       null;
                    elsif v_tran.nop <> 1 and  v_tran.start_date < add_months(p_data_begin,12) -- более года                               -- если <> 1 и дата заключения полиси > года
                       then
                       --- ????? вызов функции по расчету САВ
                       -- расчет1 ОАВ (без учета процентов)
                       null;
                    end if; -- анализ количества выплат в году
              end if ;  -- анализ метода расчета
      
         -- проверка условия существования записи в таблице agent_report_cont
         -- условия :метод расчета = "от годовой премии",количества выплат >1, policy_id, дата транзакции < года)
        if p_method_payment = 1 then -- метод расчета = "от годовой премии"
            begin
                select count(*)  into  v_count
                from  ven_agent_report ar
                join  ven_agent_report_cont arc on (arc.agent_report_id=ar.agent_report_id)
                where ar.ag_contract_h_id = p_ag_contract_header_id  -- по агенту
                and   arc.policy_id = v_tran.policy_id -- по договору страхования
                and   v_tran.nop > 1       -- количество выплат > 1
                ;
            exception when no_data_found then  v_count:=0 ;
            end;
      
             if    v_count= 0    then  -- записи не существует
                  --OAV*80%
                  null;
             elsif v_count=1     then  -- запись одна
                if     v_tran.start_date >   add_months(p_data_begin,11) -- договор менее 11 месяцев
                then
                  null; -- рано ему еще насчитывать вообще что либо!!!
                elsif v_tran.start_date < add_months(p_data_begin,11) -- договор более года
                then
                  --OAV*20%
                  null;
                end if;
             else -- записей тьма -- считаем как для обычных клиентов
                 null;
             end if;
         end if;  -- метод расчета = "от годовой премии"
      
        end if; -- анализа категории агента
      */
      -- запись в таблицы
    
      -- проверка условия существования записи в таблице agent_report (p_vedom_id + доля агента)
      -- проверка доли агента в этом деле
      /* if    ( v_TRAN.brief = 'PERCENT' and   v_TRAN.part_agent= 100 ) -- процент
       then    v_part_agent:=0;
       else    v_part_agent:=1;
       end if;
      */
      --????
    
      -- вызов процедуры вставки в таблицу agent_report_cont
      /*av_insert_report_cont( ROUND(v_oav,2)        --сумма комиссии
                          , v_report_id -- ИД акта
                          , 0           -- c удержанием/без
                          , v_tran.p_policy_agent_com_id
                          , v_tran.trans_id -- транс
                          , NULL --тип доли ag_type_rate_value_id
                          , v_tran.part_agent
                          , v_sav --ставка %
                          , v_tran.policy_id
                          , v_tran.trans_date
                          , v_tran.acc_amount
                          ,0
                          ,p_err_code);
      */
    END LOOP;
    CLOSE k_tran;
  
    --exception when others then p_err_code:=sqlcode;
  END;
END pkg_test;
/
