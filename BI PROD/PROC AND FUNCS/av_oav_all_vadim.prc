create or replace procedure av_oav_all_vadim -- 2008.06.04 для расчета ОАВ май без задвоенности, пока нет патча
		      (p_vedom_id    IN NUMBER 			--иди ведомости расчета вознаграждений посреднику
                      ,p_data_begin  IN DATE 			--дата начала отчетного периода
                      ,p_category_id IN NUMBER 			--категория агента
                      ,p_ag_head_id  IN NUMBER DEFAULT NULL 	--иди агентского договора
			)
IS
    v_rez NUMBER := 0; -- результат выполнения проверок
    p_err_code   NUMBER;

    v_err_num      NUMBER := 0;
    v_ag_ch_id     NUMBER;
    v_ag_av_id     NUMBER;
    v_type_r_brief VARCHAR2(100);
    v_pph          NUMBER;
    v_lead_head_id NUMBER;

    CURSOR k_tran(ppolh NUMBER, v_policy_agent_id NUMBER) IS
      SELECT t.trans_id -- иди транзакции
            ,pa.ag_contract_header_id header_id,
             pac.p_policy_agent_com_id,
             pac.ag_type_defin_rate_id,
             pac.ag_type_rate_value_id,
             pac.t_prod_coef_type_id,
             pac.val_com,
             pa.part_agent -- доля агента в договоре
            ,pp.policy_id -- иди версии договора страхования
            ,t.trans_date -- дата транзакции
            ,t.trans_amount -- сумма в валюте счета по оплате премии
            ,t.acc_rate -- курс
            ,NVL(pt.number_of_payments, 1) NOP -- количество выплат в году
            ,NVL(pp.premium, 0) GP -- сумма премии
            ,ph.start_date -- дата начала договора страхования
            ,'PERCENT' brief -- краткое наименование доли агента
            ,acp1.due_date plan_date -- дата эл-та плана-графика
      --, ph.start_date start_date
        FROM ven_ac_payment   acp1 -- счет
            ,AC_PAYMENT_TEMPL apt,
             DOC_SET_OFF      dso,
             OPER             o             -- сервак мощный не правда ли? но лучше этого не делать. кортезианский джоин исключим
            ,DOC_DOC             dd,
             TRANS               t,
             TRANS_TEMPL         tt,
             P_POLICY            pp,
             P_POLICY_AGENT      pa -- aгенты по договору страхования
            ,ven_p_pol_header    ph -- заголовок договора страхования
            ,P_POLICY_AGENT_COM  pac,
             T_PAYMENT_TERMS     pt,
             T_PROD_LINE_OPTION  plo -- группа рисков по полиси (программа страхования)
            ,POLICY_AGENT_STATUS pas -- статусы агентов по договору страхования
            ,DOCUMENT            d
       WHERE apt.payment_templ_id = acp1.payment_templ_id
         AND apt.brief = 'PAYMENT'
         AND dd.parent_id = pp.policy_id
         AND dd.child_id = acp1.payment_id
         AND dso.parent_doc_id = acp1.payment_id -- счет
         AND dso.child_doc_id = d.document_id --правил Колганов 18.12.2007
         AND d.reg_date > TO_DATE('31.07.2007', 'dd.mm.yyyy') --правил Колганов 18.12.2007
         AND Doc.get_doc_status_brief(acp1.payment_id,TO_DATE('31.12.9999', 'DD.MM.YYYY')) ='PAID'
         AND NVL(Doc.get_doc_status_brief(acp1.payment_id, TO_DATE('31.07.2007', 'DD.MM.YYYY')), '1') <> 'PAID'
         --правил Колганов 19.03.2008
         AND Pkg_Agent_Sub.A7_get_money_analyze(dso.child_doc_id, p_data_begin) = 1
         AND dso.doc_set_off_id = o.document_id
         AND o.oper_id = t.oper_id
         AND tt.trans_templ_id = t.trans_templ_id
         AND (tt.brief = 'СтраховаяПремияОплачена' OR
             tt.brief = 'СтраховаяПремияАвансОпл')
         AND NOT EXISTS
       (SELECT 1
                FROM TRANS tr
               WHERE tr.oper_id = o.oper_id HAVING
               MAX(tr.trans_date) > LAST_DAY(p_data_begin)) -- дата окончания периода
         AND t.a2_ct_uro_id = pp.policy_id
         AND t.a4_ct_uro_id = plo.ID
         AND ph.policy_header_id = pa.policy_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pac.p_policy_agent_id = pa.p_policy_agent_id
         AND pt.ID = pp.payment_term_id
         AND plo.product_line_id = pac.t_product_line_id
         AND pa.status_id = pas.policy_agent_status_id
            --правил Колганов 14.12.07
         AND EXISTS
       (SELECT '1'
                FROM (SELECT MAX(pp1.policy_id) OVER(PARTITION BY pp1.pol_header_id) m,
                             pp1.policy_id
                        FROM P_POLICY pp1, DOC_STATUS ds, DOC_STATUS_REF dsr
                       WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
                         AND pp1.policy_id = ds.document_id
                         AND TRUNC(ds.start_date) <=  TRUNC(LAST_DAY(p_data_begin)) --date
                         AND pp1.pol_header_id = ppolh
                         AND dsr.brief IN ('PRINTED', 'CURRENT', 'ACTIVE')
                       ORDER BY ds.start_date DESC) a --p_pol_header
               WHERE a.m = a.policy_id
                 AND ROWNUM = 1)
         AND plo.description <> 'Административные издержки'
         AND pa.p_policy_agent_id = v_policy_agent_id -- выборка по конкретному агенту УСЛОВИЕ ДЛ ПРОЦЕДУРЫ
            -- нет в предыдущих расчетах этих проводок
            and double_trans_analyze_vadim(pa.ag_contract_header_id, pa.part_agent, t.trans_id) = 1

        /* AND NOT EXISTS
       (SELECT arc.agent_report_cont_id
                FROM AGENT_REPORT_CONT arc
               WHERE arc.p_policy_agent_com_id = pac.p_policy_agent_com_id
                 AND arc.trans_id = t.trans_id)*/;

    v_tran       k_tran%ROWTYPE;
    v_OAV        NUMBER := 0;
    v_SAV        NUMBER := 0;
    v_report_id  NUMBER;
    v_part_agent NUMBER;
    v_r_brief    VARCHAR2(50);

  begin


-->>*************av_main****************

    -- удалим предыдущие АВ. Не понимаю почему ИНОГДА удаляются АВ, а иногда нет!
    -- подозреваю что это делается в FORMS и обернуто Эксепшн зен налл.
    BEGIN
      DELETE FROM ven_agent_report r
       WHERE r.ag_vedom_av_id = p_vedom_id
         AND r.ag_contract_h_id = NVL(p_ag_head_id, r.ag_contract_h_id);
    EXCEPTION
      WHEN OTHERS THEN

        RAISE_APPLICATION_ERROR(SQLCODE,'Невозможно удалить предыдущий расчет ' ||SQLERRM(SQLCODE));
    END;

--<<*************av_main****************

-->>*************av_oav_all****************

    -- определение договоров агентов, по которым будет рассчитаны вознаграждения
    -- (условия: агент на дату окончания отчетного периода был в соотв. категории,
    -- есть договора страхования у агента, где агент не в статусе Новый и дата окончания >= началу периода(т.е. не закончился на начало периода)),

  BEGIN
     FOR v_r IN (
     	SELECT pa.p_policy_agent_id,
              c.method_payment,
              ch.ag_contract_header_id
         FROM ven_ag_contract         c,
              ven_ag_contract_header  ch,
              ven_p_policy_agent      pa,
              ven_policy_agent_status ps
        WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id,
                                             LAST_DAY(p_data_begin)) =
              c.ag_contract_id
          AND pa.ag_contract_header_id = ch.ag_contract_header_id
          AND pa.ag_contract_header_id =
              NVL(p_ag_head_id, pa.ag_contract_header_id) -- по одному агенту / по всем
          AND pa.status_id = ps.policy_agent_status_id
          AND (ps.brief IN ('CURRENT', 'CANCEL', 'PRINTED') --агент действовал или действует на дату окончания периода
               AND pa.date_end > p_data_begin AND --правил Колганов 29.01.2008
               pa.date_start <= LAST_DAY(p_data_begin))
          AND c.category_id = p_category_id
           AND Doc.get_doc_status_brief(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) IN  ('CURRENT', 'PRINTED', 'RESUME')
         )
          LOOP
      -- вызов процедуры по расчету ОАВ по конкретному агенту
     /*
      Pkg_Agent_Rate.av_oav_one(p_vedom_id,
                 p_data_begin,
                 v_r.p_policy_agent_id,
                 v_r.method_payment,
                 p_category_id,
                 p_err_code);
      */
 -->>******************av_oav_one**********************

  BEGIN
    SELECT pa3.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ven_p_policy_agent pa3
     WHERE pa3.p_policy_agent_id = v_r.p_policy_agent_id; --policy_agent_id;

    SELECT t.t_ag_av_id
      INTO v_ag_av_id
      FROM ven_t_ag_av t
     WHERE t.brief = 'ОАВ';

    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);

    BEGIN
      SELECT ar.agent_report_id
        INTO v_report_id
        FROM ven_agent_report ar
       WHERE v_ag_ch_id = ar.ag_contract_h_id
         AND ar.ag_vedom_av_id = p_vedom_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_report_id := 0;
    END;

    -- при отсутствии записи в agent_report гененриться новая запись
    IF v_report_id = 0 THEN
      v_report_id := Pkg_Agent_Rate.av_insert_report(p_vedom_id,
                                      v_ag_ch_id,
                                      v_ag_av_id,
                                      v_part_agent,
                                      p_err_code);
    END IF;
    --правил Колганов 14.12.07
    SELECT ppa.policy_header_id
      INTO v_pph
      FROM P_POLICY_AGENT ppa
     WHERE ppa.p_policy_agent_id = v_r.p_policy_agent_id; --policy_agent_id;

    OPEN k_tran(v_pph,v_r.p_policy_agent_id);
    LOOP
      FETCH k_tran
        INTO v_tran.trans_id, v_tran.header_id, v_tran.p_policy_agent_com_id,
        v_tran.ag_type_defin_rate_id, v_tran.ag_type_rate_value_id,
        v_tran.t_prod_coef_type_id, v_tran.val_com, v_tran.part_agent,
        v_tran.policy_id, v_tran.trans_date, v_tran.trans_amount,
        v_tran.acc_rate, v_tran.nop, v_tran.gp, v_tran.start_date,
        v_tran.brief, v_tran.plan_date;
      EXIT WHEN k_tran%NOTFOUND;
      -- начальные значения переменных
      v_OAV := 0;
      v_SAV := 0;
      Pkg_Agent_Rate.date_pay  := v_tran.trans_date;
      Pkg_Agent_Rate.DATE_PLAN := v_tran.plan_date;
      v_sav                    := Pkg_Agent_Rate.get_rate_oab(v_tran.p_policy_agent_com_id);
      BEGIN
        SELECT rv.brief
          INTO v_r_brief
          FROM ven_ag_type_rate_value rv
         WHERE rv.ag_type_rate_value_id = v_tran.ag_type_rate_value_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_r_brief := '0';
      END;
      IF v_r_brief = 'ABSOL' THEN
        v_oav := v_sav * v_tran.part_agent / 100;
      ELSIF v_r_brief = 'PERCENT' THEN
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) *
                 v_tran.trans_amount;
      ELSE
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) *
                 v_tran.trans_amount;
      END IF;
      -- вызов процедуры вставки в таблицу agent_report_cont
      v_lead_head_id := Pkg_Agent_Sub.Get_Leader_Id_By_Date(p_data_begin,
                                                            v_tran.header_id,
                                                            v_tran.trans_date);

      av_insert_report_cont_vadim
      (ROUND(v_oav, 2) --сумма комиссии
                           ,v_report_id -- ИД акта
                           ,0 -- c удержанием/без
                           ,v_tran.p_policy_agent_com_id,
                            v_tran.trans_id -- транс
                           ,NULL --тип доли ag_type_rate_value_id
                           ,v_tran.part_agent,
                            v_sav --ставка %
                           ,v_tran.policy_id,
                            v_tran.trans_date,
                            v_tran.trans_amount,
                            0,
                            p_err_code,
                            v_lead_head_id);

    END LOOP;
    CLOSE k_tran;
  END;

--<<********************av_oav_one***********************

      -- вызов процедуры записи итоговых сумм АВ с учетом возврата в таблицу agent_report
      Pkg_Agent_Rate.av_update_report(p_vedom_id, v_r.ag_contract_header_id, p_err_code);

    END LOOP;
    --Удаляем все ОАВ без детализации из этой ведомости
    DELETE FROM AGENT_REPORT r
     WHERE r.ag_vedom_av_id = p_vedom_id
       AND NOT EXISTS
     (SELECT c.agent_report_cont_id
              FROM ven_agent_report_cont c
             WHERE c.agent_report_id = r.agent_report_id);
  EXCEPTION
    WHEN OTHERS THEN

      RAISE_APPLICATION_ERROR(-20001,'Ошибка расчета ОАВ. См. ошибку Oracle:' || SQLERRM(SQLCODE));

  END;

--<<*************av_oav_all****************

exception
     when OTHERS then
  rollback;
end av_oav_all_vadim;
/

