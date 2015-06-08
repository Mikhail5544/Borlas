CREATE OR REPLACE VIEW INS.V_REP_NONPAYMENT_2015_CC AS
SELECT ids "Идентификатор ДС"
       ,pol_num "Номер ДС"
       ,insurer "ФИО страхователя"
       ,status "Статус"
       ,last_ver_stat "Статус последней версии"
       ,prod_desc "Продукт"
       ,pay_term "Периодичность оплаты"
       ,coll_method "Тип расчетов"
       ,start_date "Дата начала ДС"
       ,end_date "Дата окончания ДС"
       ,fund "Валюта ответственности"
       ,"Дата ЭПГ" AS "Дата графика"
       ,min_to_pay_date AS "Минимальная дата неоплаты"
       ,CASE
         WHEN "Дата ЭПГ" = min_to_pay_date THEN
          NULL
         ELSE
          'Проверить в Борлас сумму задолженности!'
       END AS "Проверка"
       ,"Проверка 2"
       ,"Дата выставления"
       ,"Срок платежа"
       ,"Дней с даты ЭПГ" AS "Дней с даты графика"
       ,SUM("Сумма ЭПГ") AS "Сумма платежа, вал"
       ,"Оплачено, вал."
       ,SUM("Сумма ЭПГ") - "Оплачено, вал." AS "Задолженность, вал."
       ,SUM("Сумма ЭПГ р") AS "Сумма платежа, руб"
       ,CASE
         WHEN (SUM("Зачтенная по ЭПГ сумма р")) IS NULL THEN
          0
         ELSE
          (SUM("Зачтенная по ЭПГ сумма р"))
       END AS "Оплачено, руб"
       ,(SUM("Сумма ЭПГ р")) - (CASE
         WHEN (SUM("Зачтенная по ЭПГ сумма р")) IS NULL THEN
          0
         ELSE
          (SUM("Зачтенная по ЭПГ сумма р"))
       END) AS "Задолженность, руб"
       ,"Статус ЭПГ" AS "Статус платежа"
       ,agent_leader AS "Руководитель агента"
       ,AGENT "Агент"
       ,agency "Агентство"
       ,description "Наим канала продаж"
       ,address "Адрес страхователя"
       ,tel_home "Домашний тел."
       ,tel_pers "Личный тел."
       ,tel_work "Рабочий тел."
       ,tel_mobil "Мобильный тел."
       ,tel_cont "Контактный тел."
  FROM (SELECT nvl((SELECT SUM(CASE
                                WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN
                                 dso.set_off_amount
                                ELSE
                                 CASE
                                   WHEN ph.fund_id = 122 THEN
                                    (SELECT SUM(ROUND(dso2.set_off_child_amount *
                                                      ins.acc.get_cross_rate_by_id(1
                                                                                  ,acp.fund_id
                                                                                  ,122
                                                                                  ,dso2.set_off_date)
                                                     ,2))
                                       FROM ins.doc_doc     dd
                                           ,ins.doc_set_off dso2
                                           ,ins.ac_payment  acp
                                      WHERE dd.parent_id = dso.child_doc_id
                                        AND dd.child_id = dso2.parent_doc_id
                                        AND dso2.child_doc_id = acp.payment_id
                                        AND acp.payment_templ_id IN (2, 16123, 16125)
                                        AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
                                   ELSE
                                    (SELECT SUM(ROUND(dso2.set_off_amount *
                                                      ins.acc.get_cross_rate_by_id(1
                                                                                  ,acp.fund_id
                                                                                  ,ph.fund_id
                                                                                  ,pd4.due_date)
                                                     ,2))
                                       FROM ins.ac_payment  pd4
                                           ,ins.doc_doc     dd
                                           ,ins.doc_set_off dso2
                                           ,ins.ac_payment  acp
                                      WHERE dd.parent_id = dso.child_doc_id
                                        AND dd.child_id = dso2.parent_doc_id
                                        AND dso2.child_doc_id = acp.payment_id
                                        AND acp.payment_templ_id IN (2, 16123, 16125)
                                        AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED'
                                        AND pd4.payment_id = dso.child_doc_id)
                                 END
                              END)
                     FROM ins.doc_doc        dd
                         ,ins.p_policy       pp
                         ,ins.p_pol_header   ph
                         ,ins.doc_set_off    dso
                         ,ins.ven_ac_payment pay_doc
                    WHERE dso.parent_doc_id = acc.payment_id
                      AND dso.child_doc_id = pay_doc.payment_id
                      AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED'
                      AND dd.parent_id = pp.policy_id
                      AND dd.child_id = dso.parent_doc_id
                      AND ph.policy_header_id = pp.pol_header_id
                   
                   )
                  ,0) AS "Оплачено, вал."
               ,trunc(SYSDATE) - acc.plan_date AS "Дней с даты ЭПГ"
               ,CASE
                 WHEN ins.doc.get_doc_status_name(ph.last_ver_id) NOT IN
                      ('Действующий'
                      ,'Договор подписан'
                      ,'Индексация') THEN
                  'Проверить статус ДС'
                 ELSE
                  NULL
               END AS "Проверка 2"
               ,(SELECT adress.address_name
                  FROM (SELECT contact_id
                              ,adress_id
                              ,address_type
                          FROM (SELECT ca.contact_id
                                      ,ca.adress_id
                                      ,adt.description address_type
                                      ,row_number() over(PARTITION BY ca.contact_id ORDER BY decode(adt.id, 2, 1, 3, 1, 0) DESC, nvl(ca.is_default, 0) DESC) rn
                                  FROM ins.cn_contact_address ca
                                      ,ins.t_address_type     adt
                                 WHERE adt.id = ca.address_type) t
                         WHERE rn = 1) cad
                      ,(SELECT adr.id adr_id
                              ,nvl(adr.name, ins.pkg_contact.get_address_name(adr.id)) address_name
                          FROM ins.cn_address adr
                              ,ins.t_country  country
                         WHERE 1 = 1
                           AND country.id = adr.country_id) adress
                 WHERE cad.adress_id = adress.adr_id
                   AND cad.contact_id = c.contact_id) address
               ,tsc.description
               ,p.end_date
               ,f.brief fund
               ,p.pol_num
               ,tp.description prod_desc
               ,ph.start_date
               ,ins.doc.get_doc_status_name(ph.policy_id) status
               ,acc.plan_date "Дата ЭПГ"
               ,dsr.name "Статус ЭПГ"
               ,tpt.description pay_term
               ,(SELECT MAX(ins.ent.obj_name('DEPARTMENT', ach.agency_id)) keep(dense_rank FIRST ORDER BY pad.date_begin DESC)
                  FROM ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                 WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ac.ag_contract_id =
                       ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND pad.policy_header_id = ph.policy_header_id) agency
               ,(SELECT MAX(ins.ent.obj_name('CONTACT', ach.agent_id)) keep(dense_rank FIRST ORDER BY pad.date_begin DESC)
                  FROM ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                 WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ac.ag_contract_id =
                       ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND pad.policy_header_id = ph.policy_header_id) AGENT
               ,(SELECT MAX(ins.ent.obj_name('CONTACT'
                                           ,(SELECT ach_lead.agent_id
                                              FROM ins.ag_contract_header ach_lead
                                                  ,ins.ag_contract        ac_lead
                                             WHERE ach_lead.ag_contract_header_id = ac_lead.contract_id
                                               AND ac_lead.ag_contract_id = ac.contract_leader_id))) keep(dense_rank FIRST ORDER BY pad.date_begin DESC) ag_leader
                  FROM ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                 WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ac.ag_contract_id =
                       ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND pad.policy_header_id = ph.policy_header_id) agent_leader
               ,ins.doc.get_doc_status_name(ph.last_ver_id) last_ver_stat
               ,cm.description coll_method
               ,c.obj_name insurer
               ,ph.ids
               ,(SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                           cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                  FROM ins.cn_contact_telephone cnt
                      ,ins.t_telephone_type     tt
                 WHERE tt.id = cnt.telephone_type
                   AND tt.brief = 'HOME'
                   AND cnt.contact_id = c.contact_id) tel_home
               ,(SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                           cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                  FROM ins.cn_contact_telephone cnt
                      ,ins.t_telephone_type     tt
                 WHERE tt.id = cnt.telephone_type
                   AND tt.brief = 'PERS'
                   AND cnt.contact_id = c.contact_id) tel_pers
               ,(SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                           cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                  FROM ins.cn_contact_telephone cnt
                      ,ins.t_telephone_type     tt
                 WHERE tt.id = cnt.telephone_type
                   AND tt.brief = 'WORK'
                   AND cnt.contact_id = c.contact_id) tel_work
               ,(SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                           cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                  FROM ins.cn_contact_telephone cnt
                      ,ins.t_telephone_type     tt
                 WHERE tt.id = cnt.telephone_type
                   AND tt.brief = 'MOBIL'
                   AND cnt.contact_id = c.contact_id) tel_mobil
               ,(SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                           cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                  FROM ins.cn_contact_telephone cnt
                      ,ins.t_telephone_type     tt
                 WHERE tt.id = cnt.telephone_type
                   AND tt.brief = 'CONT'
                   AND cnt.contact_id = c.contact_id) tel_cont
               ,acc.due_date "Дата выставления"
               ,acc.grace_date "Срок платежа"
               ,(SELECT MIN(epg.plan_date)
                  FROM ins.p_policy       pp
                      ,ins.doc_doc        dd
                      ,ins.ven_ac_payment epg
                      ,ins.doc_templ      dt
                      ,ins.document       dc
                      ,ins.doc_status_ref dsr
                 WHERE pp.pol_header_id = ph.policy_header_id
                   AND dd.parent_id = pp.policy_id
                   AND dd.child_id = epg.payment_id
                   AND epg.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND epg.payment_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'TO_PAY'
                   AND (epg.amount - (SELECT nvl(SUM(dso.set_off_child_amount), 0)
                                        FROM ins.doc_set_off dso
                                       WHERE dso.parent_doc_id = epg.payment_id
                                         AND dso.cancel_date IS NULL)) >= 400) min_to_pay_date
               ,(acc.amount - nvl((SELECT SUM(dso.set_off_child_amount)
                                   FROM ins.doc_set_off dso
                                       ,ins.doc_doc     dd
                                  WHERE 1 = 1
                                    AND dso.parent_doc_id = acc.payment_id
                                    AND dd.child_id = dso.child_doc_id
                                    AND dd.parent_id = p.policy_id)
                                ,0)) *
               ins.acc.get_cross_rate_by_id(1
                                           ,ins.dml_fund.get_id_by_brief(f.brief)
                                           ,122
                                           ,acc.plan_date) "Сумма ЭПГ р"
               ,(SELECT SUM(CASE
                             WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN
                              dso.set_off_child_amount
                             ELSE
                              (SELECT SUM(dso2.set_off_child_amount)
                                 FROM ins.doc_doc     dd
                                     ,ins.doc_set_off dso2
                                     ,ins.ac_payment  acp
                                WHERE dd.parent_id = dso.child_doc_id
                                  AND dd.child_id = dso2.parent_doc_id
                                  AND dso2.child_doc_id = acp.payment_id
                                  AND acp.payment_templ_id IN (2, 16123, 16125)
                                  AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
                           END)
                  FROM ins.doc_set_off    dso
                      ,ins.ven_ac_payment pay_doc
                 WHERE dso.parent_doc_id = acc.payment_id
                   AND dso.child_doc_id = pay_doc.payment_id
                   AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') "Зачтенная по ЭПГ сумма р"
               
               ,(SELECT SUM(CASE
                             WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN
                              dso.set_off_amount
                             ELSE
                              CASE
                                WHEN ph.fund_id = 122 THEN
                                 (SELECT SUM(ROUND(dso2.set_off_child_amount *
                                                   ins.acc.get_cross_rate_by_id(1
                                                                               ,acp.fund_id
                                                                               ,122
                                                                               ,dso2.set_off_date)
                                                  ,2))
                                    FROM ins.doc_doc     dd
                                        ,ins.doc_set_off dso2
                                        ,ins.ac_payment  acp
                                   WHERE dd.parent_id = dso.child_doc_id
                                     AND dd.child_id = dso2.parent_doc_id
                                     AND dso2.child_doc_id = acp.payment_id
                                     AND acp.payment_templ_id IN (2, 16123, 16125)
                                     AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
                                ELSE
                                 (SELECT SUM(ROUND(dso2.set_off_amount *
                                                   ins.acc.get_cross_rate_by_id(1
                                                                               ,acp.fund_id
                                                                               ,ph.fund_id
                                                                               ,pd4.due_date)
                                                  ,2))
                                    FROM ins.ac_payment  pd4
                                        ,ins.doc_doc     dd
                                        ,ins.doc_set_off dso2
                                        ,ins.ac_payment  acp
                                   WHERE dd.parent_id = dso.child_doc_id
                                     AND dd.child_id = dso2.parent_doc_id
                                     AND dso2.child_doc_id = acp.payment_id
                                     AND acp.payment_templ_id IN (2, 16123, 16125)
                                     AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED'
                                     AND pd4.payment_id = dso.child_doc_id)
                              END
                           END)
                  FROM ins.doc_doc        dd
                      ,ins.p_policy       pp
                      ,ins.p_pol_header   ph
                      ,ins.doc_set_off    dso
                      ,ins.ven_ac_payment pay_doc
                 WHERE dso.parent_doc_id = acc.payment_id
                   AND dso.child_doc_id = pay_doc.payment_id
                   AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED'
                   AND dd.parent_id = pp.policy_id
                   AND dd.child_id = dso.parent_doc_id
                   AND ph.policy_header_id = pp.pol_header_id
                
                ) AS "Зачтенная по ЭПГ сумма"
               ,acc.amount - nvl((SELECT SUM(dso.set_off_child_amount)
                                  FROM ins.doc_set_off dso
                                      ,ins.doc_doc     dd
                                 WHERE 1 = 1
                                   AND dso.parent_doc_id = acc.payment_id
                                   AND dd.child_id = dso.child_doc_id
                                   AND dd.parent_id = p.policy_id)
                               ,0) AS "Сумма ЭПГ"
          FROM ac_payment acc
              ,document   d
              ,doc_templ  dt
              ,doc_doc    dd
               --   ,p_policy                      ppp
              ,doc_status_ref          dsr
              ,ins.p_pol_header        ph
              ,ins.p_policy            p
              ,ins.contact             c
              ,ins.fund                f
              ,ins.cn_person           cp
              ,ins.v_pol_issuer        insurers
              ,ins.t_sales_channel     tsc
              ,ins.t_collection_method cm
              ,ins.t_product           tp
              ,ins.t_payment_terms     tpt
         WHERE tsc.id = ph.sales_channel_id
              -- AND ph.policy_id = p.policy_id
           AND c.contact_id = cp.contact_id(+)
           AND cm.id = p.collection_method_id
           AND insurers.policy_id = ph.policy_id
           AND insurers.contact_id = c.contact_id
           AND ph.policy_header_id = p.pol_header_id
           AND dd.parent_id = p.policy_id
           AND d.document_id = acc.payment_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND dd.child_id = d.document_id
           AND d.doc_status_ref_id = dsr.doc_status_ref_id
           AND ph.fund_id = f.fund_id
           AND tp.product_id = ph.product_id
           AND tpt.id = p.payment_term_id
           AND acc.plan_date <= ADD_MONTHS(SYSDATE, 4)
           AND (cp.date_of_death IS NULL)
           AND (upper(tp.description) NOT LIKE upper('%cr%') AND
               upper(tsc.description) NOT IN
               (upper('Банковский'), upper('Корпоративный')))
           AND (tpt.description <> 'Единовременно')
           AND (SELECT MAX(ins.ent.obj_name('CONTACT', ach.agent_id)) keep(dense_rank FIRST ORDER BY pad.date_begin DESC)
                  FROM ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                 WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ac.ag_contract_id =
                       ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND pad.policy_header_id = ph.policy_header_id) <> 'Неопознанный Агент'
           AND (cm.description <> 'Прямое списание с карты')
           AND ((SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                            cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                   FROM ins.cn_contact_telephone cnt
                       ,ins.t_telephone_type     tt
                  WHERE tt.id = cnt.telephone_type
                    AND tt.brief = 'HOME'
                    AND cnt.contact_id = c.contact_id) IS NOT NULL OR
               (SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                            cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                   FROM ins.cn_contact_telephone cnt
                       ,ins.t_telephone_type     tt
                  WHERE tt.id = cnt.telephone_type
                    AND tt.brief = 'PERS'
                    AND cnt.contact_id = c.contact_id) IS NOT NULL OR
               (SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                            cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                   FROM ins.cn_contact_telephone cnt
                       ,ins.t_telephone_type     tt
                  WHERE tt.id = cnt.telephone_type
                    AND tt.brief = 'WORK'
                    AND cnt.contact_id = c.contact_id) IS NOT NULL OR
               (SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                            cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                   FROM ins.cn_contact_telephone cnt
                       ,ins.t_telephone_type     tt
                  WHERE tt.id = cnt.telephone_type
                    AND tt.brief = 'MOBIL'
                    AND cnt.contact_id = c.contact_id) IS NOT NULL OR
               (SELECT MAX(cnt.telephone_prefix || cnt.telephone_number || cnt.telephone_extension ||
                            cnt.remarks) keep(dense_rank FIRST ORDER BY cnt.id) tel
                   FROM ins.cn_contact_telephone cnt
                       ,ins.t_telephone_type     tt
                  WHERE tt.id = cnt.telephone_type
                    AND tt.brief = 'CONT'
                    AND cnt.contact_id = c.contact_id) IS NOT NULL)
           AND ins.doc.get_doc_status_name(ph.policy_id) NOT IN
               ('Расторгнут'
               ,'Завершен'
               ,'Отменен'
               ,'Приостановлен'
               ,'Готовится к расторжению'
               ,'Прекращен'
               ,'К прекращению. Готов для проверки'
               ,'Прекращен.К выплате'
               ,'К прекращению'
               ,'К прекращению. Проверен'
               ,'Прекращен.Запрос реквизитов')
           AND ins.doc.get_doc_status_name(ph.last_ver_id) NOT IN
               ('Расторгнут'
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
               ,'Ожидает подтверждения из B2B')
           AND acc.grace_date BETWEEN trunc(SYSDATE) - 13 AND trunc(SYSDATE) - 7
           AND dsr.name NOT IN ('Оплачен', 'Аннулирован')
           AND (p.is_group_flag = 0)
        --  AND ph.policy_header_id = 18889436
        -- and ph.pol_num = '1470099247'   
        --  and p.pol_num = '1730003856'     
        --   and ph.pol_num = '1560301450'  
        )
 GROUP BY ids
         ,pol_num
         ,insurer
         ,status
         ,last_ver_stat
         ,prod_desc
         ,pay_term
         ,coll_method
         ,start_date
         ,end_date
         ,fund
         ,"Дата ЭПГ"
          ,min_to_pay_date
          ,CASE
            WHEN "Дата ЭПГ" = min_to_pay_date THEN
             NULL
            ELSE
             'Проверить в Борлас сумму задолженности!'
          END
          ,"Проверка 2"
          ,"Дата выставления"
          ,"Срок платежа"
          ,"Дней с даты ЭПГ"
          ,"Оплачено, вал."
          ,"Статус ЭПГ"
          ,agent_leader
          ,AGENT
          ,agency
          ,description
          ,address
          ,tel_home
          ,tel_pers
          ,tel_work
          ,tel_mobil
          ,tel_cont
HAVING(((SUM("Сумма ЭПГ р")) - (CASE WHEN(SUM("Зачтенная по ЭПГ сумма р")) IS NULL THEN 0 ELSE(SUM("Зачтенная по ЭПГ сумма р")) END)) > 500) AND ((SUM("Сумма ЭПГ р")) <> 0)
 ORDER BY "Проверка"            DESC
          ,"Проверка 2"          DESC
          ,"Дней с даты ЭПГ" DESC;
