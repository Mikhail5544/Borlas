CREATE OR REPLACE VIEW V_FIRST_UNPAID_FEE_PREV AS
SELECT
/*
Расторжение по неоплате первого взноса за прошлый месяц

Договоры страхования, с признаком «Групповой договор» равным «0 – нет», согласно условий отчета «DWH_отчет о неоплатах_анализ_неоплат_2011», 
у которых Дата начала действия договора страхования  равна дате последнего неоплаченного ЭПГ,  за исключением следующих договоров страхования:
•  ДС с активной версией в статусе «Проект» или «Доработка»;
•  ДС, у которых «Дата графика» ЭПГ в статусе «Оплачен» с максимальным ИД больше текущей даты.
Для ДС по каналу продаж «Банковский» или «Брокерский» к дате ЭПГ и сроку платежа необходимо добавить льготный период 45 дней.
В качестве параметров для отчета «DWH_отчет о неоплатах_анализ_неоплат_2011» использовать следующие значения:
•  «Дата платежа от» - 01.10.2008;
• «Срок платежа до» - последний день прошлого месяца.
30.1.2015 Черных М.
*/
DISTINCT (SELECT insp.policy_id
            FROM p_pol_header insp
           WHERE insp.policy_header_id = pph.policy_header_id) policy_id /*Активная версия ДС*/
        ,to_number(NULL) p_pol_change_notice_id
  FROM ins_dwh.dm_p_pol_header    pph
      ,ins_dwh.dm_t_sales_channel sc
      ,ins_dwh.dm_contact         c
      ,ins_dwh.fc_egp             e
 WHERE pph.sales_channel_id = sc.id
   AND pph.insurer_contact_id = c.contact_id(+) /*Инфо. Для отладки, т.к. нет даннных*/
   AND pph.policy_header_id = e."ID Договора Страхования"
   AND pph.is_tech_work = 0 /*Не понятно, что за флаг*/
   AND ins_dwh.pkg_renlife_rep_utils.check_save_date_kp(pph.policy_header_id
                                                       ,pph.agent_header_id
                                                       ,e."Срок платежа"
                                                        ,'DWH_отчет о неоплатах_анализ неплат_2011') = 0
      
   AND CASE
         WHEN sc.brief IN ('BANK', 'BR') THEN
          e."Срок платежа" + 45
         ELSE
          e."Срок платежа"
       END <= trunc(SYSDATE, 'mm') - 1 /*Для ДС по каналу продаж «Банковский» или «Брокерский» к дате ЭПГ и
                                                                                                                              сроку платежа необходимо добавить льготный период 45 дней. (Срок платежа до» - последний день прошлого месяца. )*/
   AND e."Статус ЭПГ" != 'Оплачен'
   AND pph.start_date = e."Дата ЭПГ" /*Дата начала действия договора страхования  равна дате последнего неоплаченного ЭПГ*/
   AND CASE
         WHEN sc.brief IN ('BANK', 'BR') THEN
          e."Дата ЭПГ" + 45
         ELSE
          e."Дата ЭПГ"
       END >= SYSDATE - 30 --to_date('01.10.2008', 'dd.mm.rrrr') /*«Дата платежа от» - 01.10.2008*/
   AND pph.is_group_flag = 0 /*Не групповой*/
   AND e."Статус ЭПГ" != 'Аннулирован'
      
   AND pph.status NOT IN ('Расторгнут'
                         ,'Завершен'
                         ,'Отменен'
                         ,'Приостановлен'
                         ,'Готовится к расторжению'
                         ,'Прекращен'
                         ,'К прекращению. Готов для проверки'
                         ,'Прекращен.К выплате'
                         ,'К прекращению'
                         ,'К прекращению. Проверен'
                         ,'Прекращен.Запрос реквизитов'
                         ,'Проект'
                         ,'Доработка') /*Статус текущей версии*/
   AND pph.last_ver_stat NOT IN ('Расторгнут'
                                ,'Завершен'
                                ,'Приостановлен'
                                ,'Готовится к расторжению'
                                ,'Заявление на прекращение'
                                ,'К прекращению'
                                ,'К прекращению. Готов для проверки'
                                ,'К прекращению. Проверен'
                                ,'Прекращен. Запрос реквизитов'
                                ,'Прекращен. Реквизиты получены'
                                ,'Прекращен.К выплате'
                                ,'Прекращен'
                                ,'Восстановление'
                                ,'Отказ в Восстановлении'
                                ,'Ожидает подтверждения из B2B') /*Статус последней версии*/
      
   AND NOT EXISTS
 (SELECT NULL
          FROM ac_payment last_pay
         WHERE last_pay.payment_id IN (SELECT MAX(ac.payment_id)
                                         FROM p_policy       pp
                                             ,doc_doc        dd
                                             ,ac_payment     ac
                                             ,document       d
                                             ,doc_status_ref dsr
                                        WHERE pp.pol_header_id = pph.policy_header_id
                                          AND pp.policy_id = dd.parent_id
                                          AND dd.child_id = ac.payment_id
                                          AND ac.payment_id = d.document_id
                                          AND d.doc_status_ref_id = dsr.doc_status_ref_id
                                          AND dsr.brief = 'PAID')
           AND last_pay.plan_date > SYSDATE) /*исключить ДС, у которых «Дата графика» ЭПГ в статусе «Оплачен» с максимальным ИД больше текущей даты.*/
   AND NOT EXISTS (SELECT NULL
          FROM p_policy             pp
              ,t_policyform_product tp
         WHERE pp.pol_header_id = pph.policy_header_id
           AND pp.t_product_conds_id = tp.t_policyform_product_id
           AND tp.is_handchange = 1) /*ИСКЛЮЧАЕМ ДС для которых связь полисных условий и продуктов помечена признаком «Ручной ввод» (старые полисные условия).  */
 GROUP BY pph.policy_header_id
HAVING SUM(e."Сумма ЭПГ р") - (CASE
  WHEN SUM(e."Зачтенная по ЭПГ сумма р") IS NULL THEN
   0
  ELSE
   SUM(e."Зачтенная по ЭПГ сумма р")
END) > 500 AND SUM(e."Сумма ЭПГ р") != 0;
