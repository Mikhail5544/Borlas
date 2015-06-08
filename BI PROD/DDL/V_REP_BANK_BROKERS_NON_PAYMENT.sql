CREATE OR REPLACE VIEW V_REP_BANK_BROKERS_NON_PAYMENT AS
SELECT ins.ent.obj_name('CONTACT', ach.agent_id) "Брокер"
       ,ach.num "Номер агентского договора"
       ,c.obj_name "ФИО страхователя"
       ,prod.description "Продукт"
       ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) "Номер ДС"
       ,ph.ids "Идентификатор ДС"
       ,ph.start_date "Дата начала ДС"
       ,p.end_date "Дата окончания ДС"
       ,ins.doc.get_doc_status_name(ph.last_ver_id) "Статус последней версии ДС"
       ,ins.doc.get_doc_status_name(ph.policy_id) "Статус активной версии ДС"
       ,pt.description "Периодичность оплаты"
       ,CASE
         WHEN cm.description = 'Безналичный расчет' THEN
          'Оплата через банк'
         ELSE
          cm.description
       END "Тип расчетов"
       ,CASE
         WHEN pt.description = 'Единовременно' THEN
          1 || '/' || 1
         WHEN pt.description = 'Ежемесячно' THEN
          CEIL((MONTHS_BETWEEN(vpps.plan_date, ph.start_date) + 1) / 12) ||
          REPLACE('/' || to_char(MOD(MONTHS_BETWEEN(vpps.plan_date, ph.start_date) + 1, 12))
                 ,'/0'
                 ,'/12') -- replace нужен для случая, когда mod()=0. В других случаях тоже самое
         WHEN pt.description = 'Ежеквартально' THEN
          CEIL((ROUND(MONTHS_BETWEEN(vpps.plan_date, ph.start_date)) / 3 + 1) / 4) || '/' ||
          REPLACE(ROUND(MOD(MONTHS_BETWEEN(vpps.plan_date, ph.start_date) / 3 + 1, 4)), 0, 4)
         WHEN pt.description = 'Раз в полгода' THEN
          CEIL((MONTHS_BETWEEN(vpps.plan_date, ph.start_date) / 6 + 1) / 2) || '/' ||
          ROUND(REPLACE(MOD(MONTHS_BETWEEN(vpps.plan_date, ph.start_date) / 6 + 1, 2), 0, 2))
         WHEN pt.description = 'Ежегодно' THEN
          ROUND((MONTHS_BETWEEN(vpps.plan_date, ph.start_date)) / 12) + 1 || '/' || 1
         ELSE
          NULL
       END "Год_действия_пор_номер_платежа"
       ,vpps.num "Номер ЭПГ"
       ,vpps.doc_status_ref_name "Статус ЭПГ"
       ,vpps.plan_date "Дата ЭПГ"
       ,vpps.grace_date "Дата ЛП"
       ,f.brief "Валюта"
       ,vpps.amount - nvl((SELECT SUM(dso.set_off_child_amount)
                           FROM ins.doc_set_off dso
                               ,ins.doc_doc     dd
                          WHERE 1 = 1
                            AND dso.parent_doc_id = vpps.document_id
                            AND dd.child_id = dso.child_doc_id
                            AND dd.parent_id = vpps.policy_id)
                        ,0) "Сумма ЭПГ"
       ,(vpps.amount - nvl((SELECT SUM(dso.set_off_child_amount)
                            FROM ins.doc_set_off dso
                                ,ins.doc_doc     dd
                           WHERE 1 = 1
                             AND dso.parent_doc_id = vpps.document_id
                             AND dd.child_id = dso.child_doc_id
                             AND dd.parent_id = vpps.policy_id)
                         ,0)) *
       ins.acc.get_cross_rate_by_id(1, ins.dml_fund.get_id_by_brief(f.brief), 122, vpps.plan_date) "Сумма ЭПГ р"
       ,(SELECT MAX(CASE
                     WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN --ПП,ПП_ПС,ПП_ОБ
                      pay_doc.due_date
                     ELSE
                      (SELECT MAX(acp.due_date)
                         FROM ins.doc_doc     dd
                             ,ins.doc_set_off dso2
                             ,ins.ac_payment  acp
                        WHERE dd.parent_id = dso.child_doc_id
                          AND dd.child_id = dso2.parent_doc_id
                          AND dso2.child_doc_id = acp.payment_id
                          AND acp.payment_templ_id IN (2, 16123, 16125) --ПП,ПП_ПС,ПП_ОБ
                          AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
                   END)
          FROM ins.doc_set_off    dso
              ,ins.ven_ac_payment pay_doc
         WHERE dso.parent_doc_id = vpps.document_id
           AND dso.child_doc_id = pay_doc.payment_id
           AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') "Дата фактической оплаты"
       ,dt.name "Вид (платежные документы)"
       ,ap.reg_date "Дата документа"
       ,ap.num "Номер документа"
       ,dso.set_off_child_amount "Оплачено, руб"
       ,dso.set_off_amount "Оплачено в валюте договора"
       ,CASE
         WHEN ap.doc_templ_id = 13304 THEN -- ЗачетУ_КВ
          dso.set_off_child_amount
         ELSE
          0
       END "Удержанно в счет КВ р"
       ,pkg_policy.get_pol_sales_chn(ph.policy_header_id, 'descr') "Наим канала продаж"
       ,ins.ent.obj_name('CONTACT'
                       ,(SELECT ach_lead.agent_id
                          FROM ins.ag_contract_header ach_lead
                              ,ins.ag_contract        ac_lead
                         WHERE ach_lead.ag_contract_header_id = ac_lead.contract_id
                           AND ac_lead.ag_contract_id = ac.contract_leader_id)) "Руководитель Агента"
       ,ins.ent.obj_name('CONTACT'
                       ,(SELECT ach_rec.agent_id
                          FROM ins.ag_contract_header ach_rec
                              ,ins.ag_contract        ac_rec
                         WHERE ach_rec.ag_contract_header_id = ac_rec.contract_id
                           AND ac_rec.ag_contract_id = ac.contract_recrut_id)) "Раздатчик"
  FROM ins.p_pol_header ph
      ,ins.ven_p_policy p
      ,ins.t_collection_method cm
      ,(SELECT pc.policy_id
              ,pc.contact_id
          FROM ins.p_policy_contact pc
         WHERE pc.contact_policy_role_id = 6) insurers
      ,ins.contact c
      ,ins.t_payment_terms pt
      ,ins.fund f
      ,ins.t_product prod
      ,ins.p_policy_agent_doc pad
      ,ins.ven_ag_contract_header ach
      ,ins.ag_contract ac
      ,ins.contact ca
      ,ins.v_policy_payment_schedule vpps
      ,doc_status_ref dsf
      ,ins.doc_set_off dso
      ,ins.ven_ac_payment ap
      ,ins.doc_templ dt
 WHERE 1 = 1
   AND ph.policy_id = p.policy_id
   AND ph.policy_header_id = p.pol_header_id
   AND p.payment_term_id = pt.id
   AND cm.id = p.collection_method_id
   AND insurers.policy_id = p.policy_id
   AND insurers.contact_id = c.contact_id
   AND ph.product_id = prod.product_id
   AND ph.fund_id = f.fund_id
   AND pad.ag_contract_header_id = ach.ag_contract_header_id
   AND ac.ag_contract_id = ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
   AND ca.contact_id = ach.agent_id
   AND pad.policy_header_id(+) = ph.policy_header_id
   AND vpps.pol_header_id = ph.policy_header_id
   AND dso.parent_doc_id(+) = vpps.document_id
   AND dsf.doc_status_ref_id = vpps.doc_status_ref_id
   AND ap.payment_id(+) = dso.child_doc_id
   AND dt.doc_templ_id(+) = ap.doc_templ_id
   AND nvl(p.is_group_flag, 0) = 0
   AND dsf.brief <> 'ANNULATED'
      -- AND p.pol_num = '2530000666'
      -- AND ph.start_date BETWEEN to_date('01.01.2014', 'dd.mm.yyyy') AND
      --    to_date('31.12.2014', 'dd.mm.yyyy')
      --AND p.pol_num in ('1100005910', '1910060966')
      --and ach.num = '45129'
   AND (ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED' OR
       ins.doc.get_doc_status_brief(ap.payment_id) IS NULL)
   AND EXISTS (SELECT pkg_policy.get_pol_sales_chn(ph.policy_header_id, 'descr')
          FROM ins.p_pol_header phh
         WHERE ph.policy_header_id = phh.policy_header_id
           AND pkg_policy.get_pol_sales_chn(phh.policy_header_id, 'descr') IN
               ('Брокерский без скидки'
               ,'Брокерский'
               ,'RLA'
               ,'MBG'
               ,'НПФ партнеры'));
