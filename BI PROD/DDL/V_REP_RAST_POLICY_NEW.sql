CREATE OR REPLACE VIEW V_REP_RAST_POLICY_NEW AS
SELECT rownum AS rn /* Пп */
      ,CASE
         WHEN mn.add_type_brief = 'FULL_POLICY_RECOVER' THEN
          'Восстановление всего договора'
         WHEN mn.add_type_brief = 'RECOVER_MAIN' THEN
          'Восстановление основной программы'
         WHEN mn.add_type_brief = 'UNDERWRITING_CHANGE' THEN
          'Зачет'
         WHEN mn.add_type_brief = 'FIN_WEEK' THEN
          'Финансовые каникулы'
       --'Расторжение' --Чирков /заменил Расторжение на Возврат/ по заявке 185441
         WHEN mn.add_type_brief IN
              ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST')
              AND pol_id_head_transfer IS NULL THEN
          'Возврат'
       --добавлено условие с pol_id_head_transfer по заявке /307424: отчёт «Журнал расторжений» Зачёты/
         WHEN mn.add_type_brief IN
              ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST')
              AND pol_id_head_transfer IS NOT NULL THEN
          'Зачет'
         ELSE
          mn.add_type_brief
       END AS oper_type /* Тип операции */
      ,mn.ins_type /* Вид страхования */
      ,mn.pol_id_head /* POL_ID_Head */
      ,mn.ids /* ИДС */
      ,mn.pol_num /* № полиса */
      ,mn.notice_ser /* Серия заявления */
      ,mn.notice_num /* № заявления */
      ,mn.product /* Название программы */
      ,mn.risks /* Риски по договору */
      ,mn.p_cover_id /* ID Покрытия */
      ,mn.plo_id /* Id Наименования Риска */
      ,mn.department /* Регион */
      ,mn.dept_code /* Код региона */
      ,mn.insurer /* Страхователь */
      ,mn.insurer_id /* ID контакта (Страхователь) */
      ,mn.insurer_type /* Тип Страхователя (Физ лицо / Юр лицо) */
      ,mn.ins_resident /* Тип Страхователя (Резидент/Нерезидент) */
      ,mn.ins_country /* Страна Проживания Страхователя */
      ,mn.nav_contractor /* Contractor № из Navision */
       
       /*Новые стоблцы 11.3.2015*/
      ,(-1) * mn.underpayment_previous underpayment_previous /*Недоплата за прошлые периоды в валюте договора*/
      ,(-1) * mn.underpayment_current underpayment_current /*Недоплата за текущий период в валюте договора*/
      ,(-1) * mn.underpayment_lp underpayment_lp /*Недоплата  за ЛП в валюте договора*/
      ,mn.unpayed_premium_previous /*Начисленная премия к списанию по неоплате за прошлый период в валюте договора*/
      ,mn.unpayed_premium_current /*Начисленная премия к списанию по неоплате за текущий период в валюте договора*/
      ,mn.unpayed_premium_lp /*Начисленная премия к списанию по неоплате за ЛП в валюте договора*/
      ,mn.add_policy_surrender /*Дополнительная выкупная сумма в валюте договора*/
      ,mn.premium_msfo /*Начисленная премия МСФО к списанию в валюте договора*/
      ,mn.unpayed_msfo_prem_correction /*Корректировка неоплаченной премии МСФО в валюте договора*/
       
      ,mn.management_expenses /*Расходы на ведение судебного дела*/
      ,mn.state_duty /*Гос.пошлина*/
      ,mn.penalty /*Штраф*/
      ,mn.borrowed_money_percent /*Проценты за пользование чужими д/с*/
      ,mn.moral_damage /*Моральный вред*/
      ,mn.service_fee /*Оплата услуг*/
      ,mn.other_court_fees /*Прочие судебные расходы*/
       
      ,(-1) * mn.underpayment_previous * mn.rate underpayment_previous_rur /*Недоплата за прошлые периоды в рублях*/
      ,(-1) * mn.underpayment_current * mn.rate underpayment_current_rur /*Недоплата за текущий период в рублях*/
      ,(-1) * mn.underpayment_lp * mn.rate underpayment_lp_rur /*Недоплата  за ЛП в рублях*/
      ,mn.add_policy_surrender * mn.rate add_policy_surrender_rur /*Дополнительная выкупная сумма в рублях*/
      ,mn.unpayed_msfo_prem_correction * mn.rate unpayed_msfo_prem_correc_rur /*Корректировка неоплаченной премии МСФО в рублях*/
       
       /*Конец новые стоблцы 11.3.2015*/
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK')
              OR nvl(mn.issuer_return_date, to_date('01.01.1900', 'dd.mm.rrrr')) !=
              to_date('01.01.1900', 'dd.mm.rrrr') THEN
          mn.receiver
       END AS receiver /* Получатель страхового возмещения */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK')
              OR nvl(mn.issuer_return_date, to_date('01.01.1900', 'dd.mm.rrrr')) !=
              to_date('01.01.1900', 'dd.mm.rrrr') THEN
          mn.receiver_id
       END AS receiver_id /* ID Контакта (Получатель страхового возмещения) */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK')
              OR nvl(mn.issuer_return_date, to_date('01.01.1900', 'dd.mm.rrrr')) !=
              to_date('01.01.1900', 'dd.mm.rrrr') THEN
          (SELECT CASE
                    WHEN tpc.description != 'Физическое лицо' THEN
                     'Юридическое лицо'
                    ELSE
                     'Физическое лицо'
                  END
             FROM ins.ven_contact    c
                 ,ins.t_contact_type tpc
            WHERE c.contact_id = mn.receiver_id
              AND c.contact_type_id = tpc.id)
       END AS receiver_type /* Тип получателя страхового возмещения (Физ лицо/Юр лицо) */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK')
              OR nvl(mn.issuer_return_date, to_date('01.01.1900', 'dd.mm.rrrr')) !=
              to_date('01.01.1900', 'dd.mm.rrrr') THEN
          (SELECT CASE nvl(c.resident_flag, 0)
                    WHEN 0 THEN
                     'Нерезидент'
                    ELSE
                     'Резидент'
                  END
             FROM ins.ven_contact c
            WHERE c.contact_id = mn.receiver_id)
       END AS rec_resident /* Тип получателя страхового возмещения (Резидент/Нерезидент) */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          mn.ins_country
         ELSE
          (SELECT cca.country_name
             FROM ins.v_cn_contact_address cca
            WHERE cca.contact_id = mn.receiver_id
              AND ins.pkg_contact.get_primary_address(mn.receiver_id) = cca.id(+)
              AND rownum = 1)
       END AS rec_country /* Страна проживания получателя страхового возмещения */
      ,mn.agent_name /* Агент */
      ,mn.currency /* Валюта договора */
      ,mn.ins_amount /* Страховая сумма */
      ,mn.start_date /* Дата начала ответственности */
      ,mn.end_date /* Дата окончания ответственности */
      ,mn.rate /* Курс на отчетную дату (или дату оплаты) */
      ,mn.fee /* Сумма премии/взноса */
      ,mn.premium /* Годовая премия */
      ,mn.paym_term /* Периодичность уплаты взносов */
      ,mn.ins_fee /* Сумма страхового взноса в пересчете на один день */
      ,mn.day_count /* Кол-во дней страхования с даты расторжения до конца оплаченного периода */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          mn.redemption_sum
       END AS redemption_sum /* Выкупная сумма в валюте договора */
      ,CASE mn.add_type_brief
         WHEN 'UNDERWRITING_CHANGE' THEN
          mn.cover_sum
         WHEN 'FIN_WEEK' THEN
          0
         ELSE
          mn.return_bonus_part
       END AS return_bonus_part /* Возврат части премии в валюте договора */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          mn.add_invest_income
       END AS add_invest_income /* Доп. Инвест. Доход в валюте договора */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          mn.return_sum
       END AS return_sum /* Сумма к возврату в валюте договора */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          mn.underpayment_actual
       END AS underpayment_actual /* Недоплата (ППУ) в валюте договора */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          mn.admin_expenses
       END AS admin_expenses /* админ.изд.  в валюте договора */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          CASE
            WHEN rn_plo = 1 THEN
             mn.overpayment
            ELSE
             0
          END
       END AS overpayment /* переплата в валюте договора */
       /* переплата в валюте договора */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          0
         ELSE
          mn.medo_cost
       END AS medo_cost /* Стоимость МО в валюте договора */
      ,CASE mn.add_type_brief
         WHEN 'UNDERWRITING_CHANGE' THEN
          0
         ELSE
          mn.bonus_off_prev
       END AS bonus_off_prev /* 91 счет в валюте договора */
      ,CASE mn.add_type_brief
         WHEN 'UNDERWRITING_CHANGE' THEN
          0
         ELSE
          mn.bonus_off_current
       END AS bonus_off_current /* Сторно 92 счета в валюте договора */
      ,CASE
         WHEN rn_plo = 1 THEN
          mn.ndfl_sum_2
         ELSE
          0
       END AS ndfl_sum
       /* Сумма НДФЛ (для нулевых актов) */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          SYSDATE
         ELSE
          mn.real_act_date
       END AS real_act_date /* Дата акта */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          SYSDATE
         ELSE
          mn.issuer_return_date
       END AS issuer_return_date /* Дата выплаты */
      ,mn.court_expenses /* Судебные расходы */
      ,CASE
         WHEN mn.add_type_brief IN ('FIN_WEEK', 'UNDERWRITING_CHANGE') THEN
          mn.active_st_date
         ELSE
          mn.decline_date
       END AS decline_date /* Дата расторжения */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          'Дополнительное соглашение к договору страхования'
         ELSE
          mn.decline_reason
       END AS decline_reason /* Причина расторжения */
      ,CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK') THEN
          'Изменение условий'
       --Чирков добавил 230722: Журнал расторжений
         WHEN mn.add_type_brief IN ('QUIT_SETTLED'
                                   ,'QUIT_NONSETTLED'
                                   ,'QUIT_SETTLED_PAST'
                                   ,'QUIT_NONSETTLED_PAST'
                                   ,'FULL_POLICY_RECOVER'
                                   ,'RECOVER_MAIN') THEN
          'Досрочное расторжение'
       -- else mn.decline_reason2 --Чирков комментарий 230722: Журнал расторжений
       END AS decline_reason2 /* Причина расторжения для 2-С (Досрочное расторжение/Изменение условий) */
      ,CASE
         WHEN mn.add_type_brief = 'FIN_WEEK' THEN
          'Страхователь' --Чирков --доработка 129069
         WHEN mn.add_type_brief = 'UNDERWRITING_CHANGE' THEN
          'Страховщик' --Чирков --доработка 129069
         ELSE
          CASE mn.decline_reason
            WHEN 'Неоплата очередного взноса' THEN
             'Страховщик'
            WHEN 'Окончание выжидательного периода' THEN
             'Страховщик'
            WHEN 'Увеличение степени страхового риска' THEN
             'Страховщик'
            WHEN 'Неоплата первого взноса' THEN
             'Страховщик'
            WHEN 'Отказ Страховщика' THEN
             'Страховщик'
            WHEN 'Заявление клиента' THEN
             'Страхователь'
            WHEN 'Отказ страхователя от НУ' THEN
             'Страхователь'
            WHEN 'Решение суда (аннулирование)' THEN
             'Иное'
            WHEN 'Решение суда (расторжение)' THEN
             'Иное'
            WHEN 'Смерть Страхователя' THEN
             'Иное'
            WHEN 'Смерть Застрахованного' THEN
             'Иное'
            WHEN 'Отказ Страхователя от договора' THEN
             'Страхователь'
          END
       END AS initiator /* Инициатор */
       
      ,CASE
         WHEN mn.add_type_brief IN ('FIN_WEEK', 'UNDERWRITING_CHANGE') --Чирков --доработка 129069
          THEN
          to_char(mn.active_st_date, 'yyyy') --Чирков --доработка 129069
         ELSE
          mn.decline_year
       END decline_year /* Год расторжения */
      ,mn.pay_treansfer_other /* Перенос оплаты в счет оплаты по другому договору (№ договора) */
      ,mn.pol_id_head_transfer /* POL_ID_Head (перенос оплаты, другой договор) */
      ,CASE mn.add_type_brief
         WHEN 'UNDERWRITING_CHANGE' THEN
          mn.ids
         WHEN 'FIN_WEEK' THEN
          0
         ELSE
          mn.pay_treansfer_same
       END AS pay_treansfer_same /* Перенос оплаты в счет оплаты по тому же договору (№ договора) */
      ,mn.sum_91_92 /* Сумма 92 и 91 счета */
      , CASE
         WHEN mn.add_type_brief IN ('UNDERWRITING_CHANGE', 'FIN_WEEK')
              OR EXISTS (SELECT 1
                 FROM ins.p_pol_decline   pd
                     ,ins.p_cover_decline cd
                WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                  AND pd.p_policy_id = mn.decline_policy_id
                     /* Сумма к возврату в валюте договора */
                  AND abs(nvl(cd.return_bonus_part, 0) + nvl(cd.add_invest_income, 0) +
                          nvl(cd.redemption_sum, 0)) >
                     /* Недоплата (ППУ) в валюте договора */
                      nvl(cd.underpayment_actual, 0)) THEN
          NULL
         WHEN EXISTS (SELECT 1
                 FROM ins.p_pol_decline   pd
                     ,ins.p_cover_decline cd
                WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                  AND pd.p_policy_id = mn.decline_policy_id
                  AND (nvl(cd.underpayment_actual, 0) != 0 OR nvl(cd.bonus_off_prev, 0) != 0 OR
                      nvl(cd.bonus_off_current, 0) != 0)
                  AND NOT EXISTS
                (SELECT 1
                         FROM ins.p_pol_decline   pd_
                             ,ins.p_cover_decline cd_
                        WHERE pd_.p_pol_decline_id = cd_.p_pol_decline_id
                          AND pd_.p_policy_id = pd.p_policy_id
                             
                          AND (nvl(cd_.redemption_sum, 0) != 0 /* Выкупная сумма в валюте договора */
                              OR nvl(cd_.return_bonus_part, 0) != 0 /* Возврат части премии в валюте договора */
                              OR nvl(cd_.add_invest_income, 0) != 0 /* Доп. Инвест. Доход в валюте договора */
                              OR nvl(cd_.return_bonus_part, 0) + nvl(cd_.add_invest_income, 0) +
                              nvl(cd_.redemption_sum, 0) != 0 /* Сумма к возврату в валюте договора */
                              OR nvl(cd_.admin_expenses, 0) != 0 /* админ.изд. в валюте договора */
                              OR nvl(pd_.overpayment, 0) != 0 --Переплата в валюте договора
                              OR nvl(pd_.medo_cost, 0) != 0 --Стоимость МО
                              ))) THEN
          'Нулевой акт с премией к списанию'
         WHEN EXISTS (
               
               SELECT abs(SUM(nvl(cd.return_bonus_part, 0) + nvl(cd.add_invest_income, 0) +
                               nvl(cd.redemption_sum, 0))) AS return_sum
                       /* Недоплата (ППУ) в валюте договора */
                      ,abs(SUM(nvl(cd.underpayment_actual, 0))) AS underpayment_actual
                 FROM ins.p_pol_decline   pd
                      ,ins.p_cover_decline cd
                WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                  AND pd.p_policy_id = mn.decline_policy_id HAVING
               /* Сумма к возврату в валюте договора */
                abs(SUM(nvl(cd.return_bonus_part, 0) + nvl(cd.add_invest_income, 0) +
                              nvl(cd.redemption_sum, 0)))
                     /* Недоплата (ППУ) в валюте договора */
                      < abs(SUM(nvl(cd.underpayment_actual, 0)))
                   OR abs(SUM(nvl(cd.return_bonus_part, 0) + nvl(cd.add_invest_income, 0) +
                              nvl(cd.redemption_sum, 0))) = mn.ndfl_sum_2) THEN
          'Нулевой акт с учетом зачета'
         WHEN (SELECT SUM(abs(nvl(cd.redemption_sum, 0)) /* Выкупная сумма в валюте договора */
                          +abs(nvl(cd.return_bonus_part, 0)) /* Возврат части премии в валюте договора */
                          +abs(nvl(cd.add_invest_income, 0)) /* Доп. Инвест. Доход в валюте договора */
                          +abs(nvl(cd.return_bonus_part, 0) + nvl(cd.add_invest_income, 0) +
                               nvl(cd.redemption_sum, 0)) /* Сумма к возврату в валюте договора */
                          +abs(nvl(cd.underpayment_actual, 0)) /* Недоплата (ППУ) в валюте договора */
                          +abs(nvl(cd.admin_expenses, 0)) /* админ.изд. в валюте договора */
                          +abs(nvl(cd.bonus_off_prev, 0)) /* 91 счет в валюте договора */
                          +abs(nvl(cd.bonus_off_current, 0)) /* Сторно 92 счета в валюте договора */
                          +abs(nvl(pd.overpayment, 0)) --Переплата в валюте договора
                          + abs(nvl(pd.medo_cost, 0)) --Стоимость МО
                          )
                 FROM ins.p_pol_decline   pd
                     ,ins.p_cover_decline cd
                WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                  AND pd.p_policy_id = mn.decline_policy_id) = 0 THEN
          'Нулевой акт'
         ELSE
          'условие не найдено'
       END contract_sign
       /* Признак договора */
       
      ,mn.comments /* Комментарии */
      ,mn.total_pays_sum /* Общая Сумма Уплаченных Взносов */
      ,mn.agency /* Агентство */
      ,mn.branch /* Филиал */
      ,mn.okato_region /* Регион по ОКАТО */
      ,mn.asset_name /* Застрахованный */
      ,mn.asset_id /* Ид Контакта (Застрахованный) */
      ,mn.bank_product /* Наим Банковского Продукта */
      ,mn.risk_group_name /* Наименование группы риска */
      ,mn.invest_sign /* Признак наличия инвестиционной составляющей */
      ,mn.rent_sign /* Признак наличия ренты/аннуитета */
      ,CASE
         WHEN mn.policy_type = 2 THEN
          mn.renew_date
         WHEN mn.policy_type IN (0, 1, 3, 4) THEN
          (SELECT pkg_quit_journal_rep.get_recover_date(mn.policy_id)
             FROM p_policy               pp
                 ,as_asset               aa
                 ,p_cover                pc
                 ,status_hist            sh
                 ,ins.t_prod_line_option plo
            WHERE pp.policy_id = aa.p_policy_id
              AND pc.as_asset_id = aa.as_asset_id
              AND pc.status_hist_id = sh.status_hist_id
              AND sh.brief IN ('CURRENT', 'NEW') --Новый Действующий
              AND plo.id = pc.t_prod_line_option_id
              AND plo.product_line_id = mn.pl_id
              AND pp.policy_id = pkg_quit_journal_rep.get_recover_policy_id(mn.policy_id)
              AND rownum = 1 --320519 FW: Журнал расторжений
           )
       END renew_date
      ,mn.first_payment_doc_date /* Дата первого оплаченного взноса Капля 197174 */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.redemption_sum * mn.rate
       END AS redemption_sum_rur /* Выкупная сумма в рублях */
      ,CASE
         WHEN mn.add_type_brief = 'FIN_WEEK' THEN
          0
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.return_bonus_part * mn.rate
       END AS return_bonus_part_rur /* Возврат части премии в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.add_invest_income * mn.rate
       END AS add_invest_income_rur /* Доп. Инвест. Доход в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.return_sum * mn.rate
       END AS return_sum_sv_rur /* Сумма к возврату (СВ) в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.underpayment_actual * mn.rate
       END AS underpayment_actual_rur /* Недоплата (ППУ) в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.admin_expenses * mn.rate
       END AS admin_expenses_rur /* Адм Изд в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.overpayment * mn.rate
       END AS overpayment_rur /* Переплата в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.medo_cost * mn.rate
       END AS medocost_rur /* Стоимость МО в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.bonus_off_prev * mn.rate
       END AS bonus_off_prev_rur /* 91 счет в рублях */
      ,CASE
         WHEN mn.issuer_return_date IS NOT NULL THEN
          mn.bonus_off_current * mn.rate
       END AS bonus_off_current_rur /* Сторно 92 счета в рублях */
      ,sales_chn_gr
      ,product_group
/*Конец селект листа mn*/
  FROM (SELECT /*+LEADING(qj) NO_MERGE*/
         row_number() over(PARTITION BY ph.ids, qj.add_type_brief ORDER BY qj.t_prod_line_option_id) rn_plo
         /*Новые поля 11.3.2015*/
        ,qj.underpayment_previous
        ,qj.underpayment_current
        ,qj.underpayment_lp
        ,qj.unpayed_premium_previous
        ,qj.unpayed_premium_current
        ,qj.unpayed_premium_lp
        ,qj.add_policy_surrender
        ,qj.premium_msfo
        ,qj.unpayed_msfo_prem_correction
        ,qj.admin_expenses               cd_admin_expenses
         
        ,decode(qj.cover_number, 1, qj.management_expenses) management_expenses /*Отображать только для первой программы ДС*/
        ,decode(qj.cover_number, 1, qj.state_duty) state_duty
        ,decode(qj.cover_number, 1, qj.penalty) penalty
        ,decode(qj.cover_number, 1, qj.borrowed_money_percent) borrowed_money_percent
        ,decode(qj.cover_number, 1, qj.moral_damage) moral_damage
        ,decode(qj.cover_number, 1, qj.service_fee) service_fee
        ,decode(qj.cover_number, 1, qj.other_court_fees) other_court_fees
         /*Конец Новые поля 11.3.2015*/
         --
        ,qj.add_type_brief
        ,CASE ig.life_property
           WHEN 1 THEN
            'Ж'
           ELSE
            'НС'
         END AS ins_type /* Вид страхования */
        ,CASE qj.add_type_brief
         --Урегулированные убытки
           WHEN 'QUIT_SETTLED' THEN
            1
         --Неурегулированные (заявленные) убытки
           WHEN 'QUIT_NONSETTLED' THEN
            2
         --Восстановления и расторжения за пределами отчетного периода
           WHEN 'QUIT_SETTLED_PAST' THEN
            3
           WHEN 'QUIT_NONSETTLED_PAST' THEN
            4
           WHEN 'FULL_POLICY_RECOVER' THEN
            5
           WHEN 'RECOVER_MAIN' THEN
            6
         --Зачет/ Финансовые каникулы
           WHEN 'UNDERWRITING_CHANGE' THEN
            7
           WHEN 'FIN_WEEK' THEN
            8
           ELSE
            9
         END AS ord_1 /* Сортировка */
        ,pp.pol_header_id AS pol_id_head /* POL_ID_Head */
        ,pp.policy_id
        ,qj.decline_policy_id
        ,ph.ids /* ИДС */
        ,pp.pol_num /* № полиса */
        ,pp.notice_ser /* Серия заявления */
        ,pp.notice_num /* Номер заявления */
        ,pr.description AS product /* Название программы */
        ,plo.description AS risks /* Риски по договору */
        ,qj.p_cover_id /* ID Покрытия */
        ,plo.id AS plo_id /* ID Наименования риска */
        ,pl.id AS pl_id /* ID Наименование программы*/
        ,nvl(dp.name
            ,(SELECT depa.name
               FROM ins.p_pol_header       pha
                   ,ins.p_policy_agent_doc pad
                   ,ins.ag_contract_header ach
                   ,ins.ag_contract        ag
                   ,ins.department         depa
              WHERE pha.policy_header_id = ph.policy_header_id
                AND pha.policy_header_id = pad.policy_header_id
                AND pad.ag_contract_header_id = ach.ag_contract_header_id
                AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                AND ag.contract_id = ach.ag_contract_header_id
                AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
                AND ach.is_new = 1
                AND ag.agency_id = depa.department_id)) AS department /* Регион */
        ,CASE
           WHEN dp.name IS NULL THEN
            (SELECT lpad(ot.reg_code,2,'0')
               FROM ins.p_pol_header       pha
                   ,ins.p_policy_agent_doc pad
                   ,ins.ag_contract_header ach
                   ,ins.ag_contract        ag
                   ,ins.department         depa
                   ,organisation_tree ot
              WHERE pha.policy_header_id = ph.policy_header_id
                AND pha.policy_header_id = pad.policy_header_id
                AND pad.ag_contract_header_id = ach.ag_contract_header_id
                AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                AND ag.contract_id = ach.ag_contract_header_id
                AND ach.is_new = 1
                AND ag.agency_id = depa.department_id
                and depa.org_tree_id = ot.organisation_tree_id
                AND SYSDATE BETWEEN ag.date_begin AND ag.date_end)
           ELSE
            (select lpad(ot.reg_code,2,'0') from organisation_tree ot
             where ot.organisation_tree_id = dp.org_tree_id)
         END AS dept_code /* Код региона по КЛАДР*/
        ,co.obj_name_orig AS insurer /* Страхователь */
        ,co.contact_id AS insurer_id /* ID контакта страхователь */
        ,CASE ct.description
           WHEN 'Физическое лицо' THEN
            ct.description
           ELSE
            'Юридическое лицо'
         END AS insurer_type /* Тип Страхователя */
        ,CASE co.resident_flag
           WHEN 1 THEN
            'Резидент'
           ELSE
            'Нерезидент'
         END AS ins_resident /* Резиден/Нерезидент */
        ,(SELECT ca.country_name
            FROM ins.v_cn_address ca
           WHERE ca.id = ins.pkg_contact.get_primary_address(co.contact_id)) AS ins_country /* Страна проживания Страхователя */
        ,NULL AS nav_contractor 
        ,CASE
           WHEN qj.beneficiary_pay IS NOT NULL THEN
            qj.beneficiary_pay
           ELSE
            co.obj_name_orig
         END AS receiver /* Получатель страх.возмещения */
        ,CASE
           WHEN qj.beneficiary_pay IS NOT NULL THEN
            qj.beneficiary_id
           ELSE
            co.contact_id
         END AS receiver_id /* ИД Контакта(Пол.страх.возм.) */
        ,(SELECT cag.obj_name_orig
            FROM ins.p_pol_header       pha
                ,ins.p_policy_agent_doc pad
                ,ins.ag_contract_header ach
                ,ins.contact            cag
           WHERE pha.policy_header_id = ph.policy_header_id
             AND pha.policy_header_id = pad.policy_header_id
             AND pad.ag_contract_header_id = ach.ag_contract_header_id
             AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
             AND ach.is_new = 1
             AND ach.agent_id = cag.contact_id) AS agent_name /* Агент */
        ,fd.brief AS currency /* Валюта договора */
        ,nvl(pc.ins_amount, 0) AS ins_amount /* Страховая сумма */
        ,ph.start_date /* Дата начала отвественности */
        ,pp.end_date /* Дата окончания ответственности */
         /*Капля 197174*/
        ,CASE
           WHEN fd.brief != 'RUR' THEN
            CASE
              WHEN qj.issuer_return_date IS NOT NULL
                   OR trunc(SYSDATE, 'Q') < qj.issuer_return_date THEN
               ins.acc_new.get_rate_by_brief('ЦБ', fd.brief, qj.issuer_return_date)
              ELSE
               ins.acc_new.get_rate_by_brief('ЦБ'
                                            ,fd.brief
                                            ,ADD_MONTHS(trunc(qj.issuer_return_date, 'Q'), 3) - 1)
            END
           ELSE
            1
         END AS rate /* Курс на отчетную дату */
        ,pc.fee /* Сумма премии/взноса */
        ,pc.premium /* Годовая премия */
        ,tp.description AS paym_term /* Периодичноть уплаты взносов */
        ,NULL AS ins_fee /* Сумма страхового взноса в пересчете на один день */
        ,NULL AS day_count /* Кол-во дней страхования с даты расторжения до конца оплаченного периода */
        ,CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            qj.redemption_sum
           ELSE
            -qj.redemption_sum
         END AS redemption_sum /* Выкупная сумма в валюте договора */
        , /*-*/CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            1
           ELSE
            -1
         END * qj.return_bonus_part AS return_bonus_part /* Возврат части премии в валюте договора */
        , /*-*/CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            1
           ELSE
            -1
         END * qj.add_invest_income AS add_invest_income /* Доп. Инвест. Доход в валюте договора */
        ,qj.return_summ return_sum_2 --Итого к выплате нужно для расчета признака договора/Чирков 129069/
        , /*qj.return_summ*/(qj.return_bonus_part + qj.add_invest_income + qj.redemption_sum+qj.add_policy_surrender/*Добавлено 17.6.2015 Черных М.*/ ) * CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            1
           ELSE
            -1
         END AS return_sum /* Сумма к возврату в валюте договора */
        ,CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            -qj.underpayment_actual
           ELSE
            qj.underpayment_actual
         END AS underpayment_actual /* Недоплата (ППУ) в валюте договора */
        ,qj.admin_expenses /* админ.изд. в валюте договора */
        , /*-*/CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            1
           ELSE
            -1
         END * qj.overpayment AS overpayment /* переплата в валюте договора */
        ,-qj.medo_cost AS medo_cost /* Стоимость МО */
        ,CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            qj.bonus_off_prev
           ELSE
            -qj.bonus_off_prev
         END AS bonus_off_prev /* 91 счет в валюте договора */
        ,CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            qj.bonus_off_current
           ELSE
            -qj.bonus_off_current
         END AS bonus_off_current /* Сторно 92 счета в валюте договора */
        ,0 AS ndfl_sum /* Сумма НДФЛ (для нулевых актов) */
        ,ndfl_sum_2 AS ndfl_sum_2 /* Сумма НДФЛ из борласа*/
         
        ,qj.real_act_date /* Дата акта */
        ,qj.issuer_return_date /* Дата выплаты */
        ,0 AS court_expenses /* Судебные расходы */
        ,qj.decline_date /* Дата расторжения */
        ,CASE
           WHEN qj.add_type_brief IN ('FULL_POLICY_RECOVER', 'RECOVER_MAIN') THEN
           ----добавил Чирков 226638: отчёт <Журнал расторжений>
            CASE
              WHEN (SELECT COUNT(1)
                      FROM ins.ven_p_policy   pp_pred
                          ,ins.doc_status_ref dsr_pred
                     WHERE pp_pred.version_num = pp.version_num - 1
                       AND pp_pred.pol_header_id = pp.pol_header_id
                       AND dsr_pred.doc_status_ref_id = pp_pred.doc_status_ref_id
                       AND dsr_pred.brief = 'RECOVER_DENY') = 1 THEN
               (SELECT dr_.name
                  FROM ins.p_policy         pp_
                      ,ins.t_decline_reason dr_
                 WHERE pp_.pol_header_id = pp.pol_header_id
                   AND pp_.decline_reason_id = dr_.t_decline_reason_id
                   AND pp_.version_num = pp.version_num - 2)
              ELSE
               (SELECT dr_.name
                  FROM ins.p_policy         pp_
                      ,ins.t_decline_reason dr_
                 WHERE pp_.pol_header_id = pp.pol_header_id
                   AND pp_.decline_reason_id = dr_.t_decline_reason_id
                   AND pp_.version_num = pp.version_num - 1)
            END
         --
           ELSE
            (SELECT dr.name
               FROM ins.t_decline_reason dr
              WHERE pp.decline_reason_id = dr.t_decline_reason_id)
         END AS decline_reason /* Причина расторжения */
        ,to_char(qj.decline_date, 'yyyy') AS decline_year /* Год расторжения */
        , --null  --изменено по заявке 307424: отчёт «Журнал расторжений» Зачёты
         CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST')
                AND qj.other_policy_id IS NOT NULL THEN
            (SELECT pp_.pol_num FROM ins.p_policy pp_ WHERE pp_.policy_id = qj.other_policy_id)
         END
         
         AS pay_treansfer_other /* Перенос оплаты в счет оплаты по другому договору (№ договора) */
        , --null  --изменено по заявке 307424: отчёт «Журнал расторжений» Зачёты
         CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST')
                AND qj.other_policy_id IS NOT NULL THEN
            (SELECT pp_.pol_header_id FROM ins.p_policy pp_ WHERE pp_.policy_id = qj.other_policy_id)
         END AS pol_id_head_transfer /* POL_ID_Head (перенос оплаты, другой договор) */
        ,NULL AS pay_treansfer_same /* Перенос оплаты в счет оплаты по тому же договору (№ договора) */
        ,CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            qj.bonus_off_prev
           ELSE
            -qj.bonus_off_prev
         END + CASE
           WHEN qj.add_type_brief IN
                ('QUIT_SETTLED', 'QUIT_NONSETTLED', 'QUIT_SETTLED_PAST', 'QUIT_NONSETTLED_PAST') THEN
            qj.bonus_off_current
           ELSE
            -qj.bonus_off_current
         END AS sum_91_92 /* Сумма 92 и 91 счета */
         --,null                                    as contract_sign     /* Признак договора */
        ,NULL AS comments /* Комментарии */
        ,NULL AS total_pays_sum /* Общая Сумма Уплаченных Взносов */
        ,(SELECT /*+LEADING (pad)*/
           ro.roo_name || ' (' || CASE
             WHEN tpt.description IN ('Город', 'Республика') THEN
              tpt.description || ' '
             ELSE
              NULL
           END || tp.province_name || CASE
             WHEN tpt.description IN ('Автономный округ'
                                     ,'Автономная область'
                                     ,'Край'
                                     ,'Область') THEN
              ' ' || lower(tpt.description)
             ELSE
              NULL
           END || ', ' || substr(k.ocatd, 1, 2) || ')'
            FROM sales_dept_header  sh
                ,sales_dept         sd
                ,t_roo_header       rh
                ,t_roo              ro
                ,p_policy_agent_doc pad
                ,ag_contract_header ach
                ,department         dep
                ,document           d_pad
                ,doc_status_ref     dsr_pad
                ,organisation_tree  ot
                ,t_province         tp
                ,t_province_type    tpt
                ,t_kladr            k
           WHERE sh.last_sales_dept_id = sd.sales_dept_id
             AND sd.t_roo_header_id = rh.t_roo_header_id
             AND rh.last_roo_id = ro.t_roo_id
             AND sh.organisation_tree_id = dep.org_tree_id
             AND pad.ag_contract_header_id = ach.ag_contract_header_id
             AND ach.agency_id = dep.department_id
             AND pad.p_policy_agent_doc_id = d_pad.document_id
             AND d_pad.doc_status_ref_id = dsr_pad.doc_status_ref_id
             AND dsr_pad.brief = 'CURRENT'
             AND dep.org_tree_id = ot.organisation_tree_id
             AND pad.policy_header_id = ph.policy_header_id
             AND ot.province_id = tp.province_id(+)
             AND tp.province_type_id = tpt.province_type_id(+)
             AND rpad(lpad(ot.reg_code, 2, '0'), 13, '0') = k.code(+)) AS agency /* Агентство */
        ,(SELECT t.name
            FROM organisation_tree t
           WHERE t.parent_id = 1000
             AND t.code LIKE 'Ф_%'
           START WITH t.organisation_tree_id =
                      (SELECT ot.organisation_tree_id
                         FROM sales_dept_header  sh
                             ,sales_dept         sd
                             ,t_roo_header       rh
                             ,t_roo              ro
                             ,p_policy_agent_doc pad
                             ,ag_contract_header ach
                             ,department         dep
                             ,document           d_pad
                             ,doc_status_ref     dsr_pad
                             ,organisation_tree  ot
                        WHERE sh.last_sales_dept_id = sd.sales_dept_id
                          AND sd.t_roo_header_id = rh.t_roo_header_id
                          AND rh.last_roo_id = ro.t_roo_id
                          AND sh.organisation_tree_id = dep.org_tree_id
                          AND pad.ag_contract_header_id = ach.ag_contract_header_id
                          AND ach.agency_id = dep.department_id
                          AND pad.p_policy_agent_doc_id = d_pad.document_id
                          AND d_pad.doc_status_ref_id = dsr_pad.doc_status_ref_id
                          AND dsr_pad.brief = 'CURRENT'
                          AND dep.org_tree_id = ot.organisation_tree_id
                          AND pad.policy_header_id = ph.policy_header_id)
          CONNECT BY t.organisation_tree_id = PRIOR t.parent_id) AS branch /* Филиал */
        ,(SELECT /*+LEADING (pad)*/
           CASE
             WHEN tpt.description IN ('Город', 'Республика') THEN
              tpt.description || ' '
             ELSE
              NULL
           END || tp.province_name || CASE
             WHEN tpt.description IN ('Автономный округ'
                                     ,'Автономная область'
                                     ,'Край'
                                     ,'Область') THEN
              ' ' || lower(tpt.description)
             ELSE
              NULL
           END
            FROM sales_dept_header  sh
                ,sales_dept         sd
                ,t_roo_header       rh
                ,t_roo              ro
                ,p_policy_agent_doc pad
                ,ag_contract_header ach
                ,department         dep
                ,document           d_pad
                ,doc_status_ref     dsr_pad
                ,organisation_tree  ot
                ,t_province         tp
                ,t_province_type    tpt
           WHERE sh.last_sales_dept_id = sd.sales_dept_id
             AND sd.t_roo_header_id = rh.t_roo_header_id
             AND rh.last_roo_id = ro.t_roo_id
             AND sh.organisation_tree_id = dep.org_tree_id
             AND pad.ag_contract_header_id = ach.ag_contract_header_id
             AND ach.agency_id = dep.department_id
             AND pad.p_policy_agent_doc_id = d_pad.document_id
             AND d_pad.doc_status_ref_id = dsr_pad.doc_status_ref_id
             AND dsr_pad.brief = 'CURRENT'
             AND dep.org_tree_id = ot.organisation_tree_id
             AND pad.policy_header_id = ph.policy_header_id
             AND ot.province_id = tp.province_id(+)
             AND tp.province_type_id = tpt.province_type_id(+)) AS okato_region /* Регион по ОКАТО */
        ,sc.obj_name_orig AS asset_name /* Застрахованный */
        ,sc.contact_id AS asset_id /* Ид контакта (Застрахованный) */
        ,cpr.bank_product /* Наим банковского продукта */
        ,ll.description AS risk_group_name /* Наим группы риска */
        ,NULL AS invest_sign /* Признак наличия инвестиционной составляющей */
        ,NULL AS rent_sign /* Признак наличия ренты/аннуитета */
        ,CASE qj.policy_type
           WHEN 2 THEN
            qj.act_date
         END AS renew_date /* Дата восстановления договора */
        ,qj.policy_type
        ,qj.cover_sum
        ,qj.underpayment_actual_sum
        ,qj.bonus_off_prev_sum
        ,qj.redemption_sum_sum
        ,qj.bonus_off_current_sum
         /*Капля 197174 */
        ,(SELECT MAX(trunc(ds_.start_date))
            FROM document       d_
                ,doc_status     ds_
                ,doc_status_ref dsr_
           WHERE d_.document_id = pp.policy_id
             AND ds_.document_id = pp.policy_id
             AND dsr_.doc_status_ref_id = ds_.doc_status_ref_id
             AND dsr_.brief = 'ACTIVE') active_st_date
        ,pp.debt_summ
        ,(SELECT MAX(d.reg_date)
            FROM ins.doc_set_off dso
                ,ins.document    d
                ,ins.ac_payment  ap
           WHERE dso.child_doc_id = d.document_id
             AND ap.payment_id = dso.child_doc_id
             AND dso.parent_doc_id = (SELECT ap_1.payment_id
                                        FROM ins.p_policy   pp_1
                                            ,ins.doc_doc    dd_1
                                            ,ins.ac_payment ap_1
                                            ,ins.document   d_1
                                       WHERE 1 = 1
                                         AND dd_1.child_id = ap_1.payment_id
                                         AND ph.policy_header_id = pp_1.pol_header_id
                                         AND dd_1.parent_id = pp_1.policy_id
                                         AND d_1.doc_status_ref_id = 6 -- Оплачен
                                         AND d_1.document_id = ap_1.payment_id
                                         AND rownum = 1)
             AND ap.cancel_date IS NULL) AS first_payment_doc_date /* Дата первого оплаченного документа */
         --340932: FW: поля группа продукта/группа канала в отчетности 2014
        ,ins.pkg_policy.get_pol_sales_chn(ph.policy_header_id, 'group') sales_chn_gr
        ,ins.pkg_policy.get_pol_product_group(ph.policy_header_id) product_group
        ,pl.sort_order programm_sort_order
        /*Конец селект листа для qj,plo,pl и др.*/
        
          FROM (SELECT /*+LEADING(qj)*/
                 qj.*
                ,pd.*
                ,pp.return_summ
                ,(SELECT c.obj_name_orig
                    FROM ins.ven_ac_payment      ap
                        ,ins.doc_doc             dd
                        ,ins.ac_payment_templ    apt
                        ,ins.doc_templ           dt
                        ,ins.contact             c
                        ,ins.cn_contact_bank_acc ccba
                   WHERE dd.parent_id = qj.decline_policy_id
                     AND ap.payment_id = dd.child_id
                     AND ap.payment_templ_id = apt.payment_templ_id
                     AND apt.brief = 'PAYREQ'
                     AND ap.doc_templ_id = dt.doc_templ_id
                     AND dt.brief = 'PAYREQ'
                     AND ap.contact_bank_acc_id = ccba.id
                     AND ccba.owner_contact_id = c.contact_id
                     AND rownum = 1) beneficiary_pay
                ,(SELECT --ap.contact_id -- комментарий по заявке 209752
                   c.contact_id -- изменено по заявке 209752
                    FROM ins.ven_ac_payment      ap
                        ,ins.doc_doc             dd
                        ,ins.ac_payment_templ    apt
                        ,ins.doc_templ           dt
                        ,ins.contact             c
                        ,ins.cn_contact_bank_acc ccba
                   WHERE dd.parent_id = qj.decline_policy_id
                     AND ap.payment_id = dd.child_id
                     AND ap.payment_templ_id = apt.payment_templ_id
                     AND apt.brief = 'PAYREQ'
                     AND ap.doc_templ_id = dt.doc_templ_id
                     AND dt.brief = 'PAYREQ'
                        --Чирков добавил 209752 доработка получателя
                     AND ap.contact_bank_acc_id = ccba.id
                     AND ccba.owner_contact_id = c.contact_id
                        --
                     AND rownum = 1) beneficiary_id
                ,pp.decline_date
                 --договора по которым был произведен зачёт денежных средств на другой договор
                ,(SELECT pp_other_.policy_id
                    FROM ins.doc_doc        dd_
                        ,ins.ven_ac_payment ac_
                        ,ins.doc_templ      dt_
                        ,ins.ven_ac_payment epg_
                        ,ins.doc_set_off    dso_
                        ,ins.doc_doc        dd_other_
                        ,ins.p_policy       pp_other_
                  
                   WHERE dd_.parent_id = qj.policy_id
                     AND dd_.child_id = ac_.payment_id
                     AND ac_.doc_templ_id = dt_.doc_templ_id
                     AND dt_.brief = 'PAYMENT_SETOFF'
                     AND dso_.child_doc_id(+) = ac_.payment_id
                     AND dso_.parent_doc_id = epg_.payment_id
                        
                     AND dd_other_.child_id = epg_.payment_id
                     AND dd_other_.parent_id = pp_other_.policy_id
                     AND rownum = 1) other_policy_id
                  FROM (SELECT qj.*
                              ,po.product_line_id
                          FROM ins.tmp_quit_journal   qj
                              ,ins.t_prod_line_option po
                         WHERE qj.t_prod_line_option_id = po.id) qj
                      ,ins.p_policy pp
                      ,(SELECT pd.p_policy_id
                              ,row_number() over(PARTITION BY pd.p_pol_decline_id ORDER BY tpl.sort_order) cover_number /*Номер программы по порядку*/
                              ,pd.issuer_return_date
                              ,pd.issuer_return_sum
                              ,cd.t_product_line_id
                              ,cd.redemption_sum
                              ,SUM(cd.redemption_sum) over(PARTITION BY pd.p_pol_decline_id) AS redemption_sum_sum
                              ,cd.return_bonus_part
                              ,SUM(cd.return_bonus_part) over(PARTITION BY pd.p_pol_decline_id) AS return_bonus_part_sum
                              ,cd.add_invest_income
                              ,SUM(cd.add_invest_income) over(PARTITION BY pd.p_pol_decline_id) AS add_invest_income_sum
                              ,cd.underpayment_actual
                              ,SUM(cd.underpayment_actual) over(PARTITION BY pd.p_pol_decline_id) AS underpayment_actual_sum
                              ,cd.admin_expenses
                              ,SUM(cd.admin_expenses) over(PARTITION BY pd.p_pol_decline_id) AS admin_expenses_sum
                               /*Новые столбцы 10.3.2015*/
                              ,cd.underpayment_previous
                              ,cd.underpayment_current
                              ,cd.underpayment_lp
                              ,cd.unpayed_premium_previous
                              ,cd.unpayed_premium_current
                              ,cd.unpayed_premium_lp
                              ,cd.add_policy_surrender
                              ,cd.premium_msfo
                              ,cd.unpayed_msfo_prem_correction
                               
                              ,pd.management_expenses
                              ,pd.state_duty
                              ,pd.penalty
                              ,pd.borrowed_money_percent
                              ,pd.moral_damage
                              ,pd.service_fee
                              ,pd.other_court_fees
                               
                              ,pd.overpayment
                              ,pd.medo_cost
                              ,cd.bonus_off_prev
                              ,SUM(cd.bonus_off_prev) over(PARTITION BY pd.p_pol_decline_id) AS bonus_off_prev_sum
                              ,cd.bonus_off_current
                              ,SUM(cd.bonus_off_current) over(PARTITION BY pd.p_pol_decline_id) AS bonus_off_current_sum
                              ,pd.act_date AS real_act_date
                              ,pd.income_tax_sum AS ndfl_sum_2
                          FROM ins.p_pol_decline   pd
                              ,ins.p_cover_decline cd
                              ,ins.t_product_line  tpl
                         WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                           AND cd.t_product_line_id = tpl.id
                        ) pd
                 WHERE qj.decline_policy_id = pp.policy_id(+)
                   AND qj.decline_policy_id = pd.p_policy_id(+)
                   AND qj.product_line_id = pd.t_product_line_id(+)) qj
              ,ins.t_prod_line_option plo
              ,ins.t_product_line pl
              ,ins.t_lob_line ll
              ,ins.t_insurance_group ig
              ,ins.p_policy pp
              ,ins.p_pol_header ph
              ,ins.t_product pr
              ,ins.department dp
              ,ins.t_province tpr
              ,ins.p_policy_contact ppc
              ,ins.t_contact_pol_role tcr
              ,ins.contact co
              ,ins.t_contact_type ct
              ,ins.fund fd
              ,ins.p_cover pc
              ,ins.as_asset se
              ,ins.t_payment_terms tp
              ,ins.contact sc
              ,(SELECT pr.description AS bank_product
                      ,pr.product_id
                  FROM ins.t_product pr
                 WHERE pr.brief LIKE 'CR%') cpr
         WHERE qj.t_prod_line_option_id = plo.id
           AND plo.product_line_id = pl.id
           AND pl.t_lob_line_id = ll.t_lob_line_id
              --Чирков добавил по заявке 185441: Доработка - Отчет Журнал расторжений (новый) п.6
           AND ((qj.add_type_brief IN ('FULL_POLICY_RECOVER', 'RECOVER_MAIN') AND
               ll.description != 'Административные издержки на восстановление') OR
               qj.add_type_brief NOT IN ('FULL_POLICY_RECOVER', 'RECOVER_MAIN'))
              --
           AND ll.insurance_group_id = ig.t_insurance_group_id
           AND qj.policy_id = pp.policy_id
           AND pp.pol_header_id = ph.policy_header_id
           AND ph.product_id = pr.product_id
           AND ph.agency_id = dp.department_id(+)
           AND pp.region_id = tpr.province_id(+)
           AND pp.policy_id = ppc.policy_id
           AND ppc.contact_id = co.contact_id
           AND ppc.contact_policy_role_id = tcr.id
           AND tcr.brief = 'Страхователь'
           AND co.contact_type_id = ct.id
           AND ph.fund_id = fd.fund_id
           AND qj.p_cover_id = pc.p_cover_id
           AND pc.as_asset_id = se.as_asset_id
           AND se.contact_id = sc.contact_id
           AND pp.payment_term_id = tp.id
           AND ph.product_id = cpr.product_id(+)) mn
 ORDER BY ord_1
         ,real_act_date NULLS FIRST
         ,mn.programm_sort_order
;
