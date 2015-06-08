CREATE OR REPLACE VIEW INS_DWH.V_DIRECT_PAY AS
select ROWNUM "№ п/п"
      ,(SELECT a.id_value
          from (select cci.id_value,
                       cci.contact_id
                  from ins.cn_contact_ident cci,
                       ins.t_id_type            tt
                 where tt.id = cci.id_type
                   and tt.brief = 'IPR_Card'
               )a,
               ins.contact c2
         where c2.contact_id = mn.contact_id
           and c2.contact_id = a.contact_id
           and rownum = 1
       ) "№ банковской карты"
      ,"ФИО плательщика"
      ,(SELECT nvl(ca.NAME,ins.pkg_contact.get_address_name(ca.id))
          FROM ins.cn_contact_address cca,
               ins.cn_address         ca
         WHERE cca.adress_id    = ca.ID
           and cca.contact_id = mn.contact_id --Страхователь
           and rownum = 1
           and ca.id = (SELECT max(cca2.adress_id)
                          FROM ins.cn_contact_address cca2,
                               ins.t_address_type     tat2
                         WHERE cca2.address_type = tat2.ID
                           and cca2.contact_id = cca.contact_id
                           and nvl(decode(cca2.is_default,1,1,null),tat2.is_default) = 1
                       )
       ) "Адрес плательщика"
      ,"Назначение платежа"
      ,"Номер ДС"
      ,"ФИО Страхователя"
      ,"Сумма платежа"
      ,"Сумма КВ"
      ,"Валюта платежа"
      ,"Дата списания"
      ,"Сумма по Заявлению на списание"
      ,"Очередность платежа"
      ,"Комментарии"
      ,"Продукт"
      ,"Вид страхования"
      ,ids
      ,"Дата ЭПГ"
      ,"Статус Активной версии"
      ,"Статус последней версии"
      ,(select c.obj_name_orig agent_fio
          from ins.p_policy_agent_doc pa,
               ins.p_pol_header pha,
               ins.ag_contract_header ach,
               ins.contact c
         where 1=1
         and pha.policy_header_id = pa.policy_header_id
         and ach.ag_contract_header_id = pa.ag_contract_header_id
         and pha.policy_header_id = mn.policy_header_id
         and ach.agent_id = c.contact_id
         and ins.doc.get_doc_status_brief(pa.p_policy_agent_doc_id) = 'CURRENT'
         and rownum = 1
       ) "Агент"
  from (SELECT /*+ NO_MERGE*/
       c.obj_name_orig "ФИО плательщика",
       null "Назначение платежа",
       p.pol_num "Номер ДС",
       c.obj_name_orig "ФИО Страхователя",
       dd.parent_amount - ins.Pkg_Payment.get_set_off_amount(ap.payment_id, p.pol_header_id,NULL) "Сумма платежа",
       (dd.parent_amount - ins.Pkg_Payment.get_set_off_amount(ap.payment_id, p.pol_header_id,NULL))*0.018 "Сумма КВ",
       f.brief "Валюта платежа",
       p.day_of_charge_off "Дата списания",
       p.amount_of_charge_off "Сумма по Заявлению на списание",
       ap.payment_number "Очередность платежа",
       case when sysdate - p.start_date > 335
            then 'Пролонгация'
            else null end "Комментарии",
       tp.description "Продукт",
       1 "Вид страхования",
       ph.ids,
       ap.plan_date "Дата ЭПГ",
       ins.doc.get_doc_status_name(ph.policy_id) "Статус Активной версии",
       ins.pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии"
      ,p.pol_header_id
      ,ap.payment_id
      ,dd.parent_amount
      ,ap.plan_date
      ,p.day_of_charge_off
      ,c.contact_id
      ,ph.policy_header_id
  FROM ins.p_pol_header ph,
       ins.p_policy     p,
       ins.t_product    tp,
       ins.contact      c,
       ins.p_policy     pp,
       ins.doc_doc      dd,
       ins.document     d,
       ins.ac_payment   ap,
       ins.doc_templ    dt,
       ins.t_collection_method cm,
       ins.fund                f,
       ins.t_payment_terms     tpt
 WHERE p.policy_id = ph.policy_id
   and tp.product_id = ph.product_id
   and ins.doc.get_doc_status_brief(ph.policy_id) not in ('CANCEL','STOP','PROJECT','STOPED','BREAK','RECOVER')
   and ins.pkg_policy.get_last_version_status(ph.policy_header_id) NOT IN ('Готовится к расторжению','Восстановление')
   and c.contact_id = ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь')
   and cm.id = p.collection_method_id
   and cm.description = 'Прямое списание с карты'
   and f.fund_id = ap.fund_id
   and tpt.id = p.payment_term_id
   AND pp.pol_header_id = ph.policy_header_id
   and dd.parent_id  = pp.policy_id
   and d.document_id = dd.child_id
   and ap.payment_id = dd.child_id
   and dt.doc_templ_id = d.doc_templ_id
   and dt.brief = 'PAYMENT'
   and ins.doc.get_doc_status_brief(ap.payment_id) in ('TO_PAY','NEW')
   AND p.day_of_charge_off = (SELECT to_number(r.param_value)
                                FROM ins_dwh.rep_param r
                               WHERE r.rep_name = 'V_DIRECT_PAY'
                                 AND r.param_name = 'day')
  and ap.grace_date >= to_date(lpad(to_char((SELECT r.param_value
                                       FROM ins_dwh.rep_param r
                                       WHERE r.rep_name = 'V_DIRECT_PAY'
                                         AND r.param_name = 'day')),2,'0')
                              ||to_char(sysdate,'mm')||to_char(sysdate,'yyyy'),'ddmmyyyy')
) mn
where  ((ins.doc.get_doc_status_brief(mn.payment_id) = 'TO_PAY'
         AND ABS(mn.plan_date - SYSDATE) <= 31
         OR ins.doc.get_doc_status_brief(mn.payment_id) = 'TO_PAY'
            AND ABS( (select min(ap3.plan_date)
                                       from ins.p_policy   p3,
                                            ins.doc_doc    dd3,
                                            ins.document   d3,
                                            ins.ac_payment ap3,
                                            ins.doc_templ  dt3
                                      where p3.pol_header_id = mn.pol_header_id
                                        and dd3.parent_id  = p3.policy_id
                                        and d3.document_id = dd3.child_id
                                        and ap3.payment_id = dd3.child_id
                                        and dt3.doc_templ_id = d3.doc_templ_id
                                        and dt3.brief = 'PAYMENT'
                                        and ins.doc.get_doc_status_brief(ap3.payment_id) in ('NEW')
                          ) - SYSDATE) -
                (to_number(nvl(to_char((select max(ap3.plan_date)
                                       from ins.p_policy   p3,
                                            ins.doc_doc    dd3,
                                            ins.document   d3,
                                            ins.ac_payment ap3,
                                            ins.doc_templ  dt3
                                      where p3.pol_header_id = mn.pol_header_id
                                        and dd3.parent_id  = p3.policy_id
                                        and d3.document_id = dd3.child_id
                                        and ap3.payment_id = dd3.child_id
                                        and dt3.doc_templ_id = d3.doc_templ_id
                                        and dt3.brief = 'PAYMENT'
                                        and ins.doc.get_doc_status_brief(ap3.payment_id) in ('TO_PAY')
                          ),'dd'),'0'))
         - mn.day_of_charge_off) <= 31
        )
       OR ins.doc.get_doc_status_brief(mn.payment_id) = 'NEW'
         AND ABS(mn.plan_date - SYSDATE) -
                (to_number(nvl(to_char((select max(ap3.plan_date)
                                       from ins.p_policy   p3,
                                            ins.doc_doc    dd3,
                                            ins.document   d3,
                                            ins.ac_payment ap3,
                                            ins.doc_templ  dt3
                                      where p3.pol_header_id = mn.pol_header_id
                                        and dd3.parent_id  = p3.policy_id
                                        and d3.document_id = dd3.child_id
                                        and ap3.payment_id = dd3.child_id
                                        and dt3.doc_templ_id = d3.doc_templ_id
                                        and dt3.brief = 'PAYMENT'
                                        and ins.doc.get_doc_status_brief(ap3.payment_id) in ('TO_PAY')
                            ),'dd'),'0')
                          ) - mn.day_of_charge_off) <= 31


       )
   and mn.plan_date = (select min(ap2.plan_date)
                         from ins.p_policy   p2,
                              ins.doc_doc    dd2,
                              ins.document   d2,
                              ins.ac_payment ap2,
                              ins.doc_templ  dt2
                        where p2.pol_header_id = mn.pol_header_id
                          and dd2.parent_id  = p2.policy_id
                          and d2.document_id = dd2.child_id
                          and ap2.payment_id = dd2.child_id
                          and dt2.doc_templ_id = d2.doc_templ_id
                          and dt2.brief = 'PAYMENT'
                          and ins.doc.get_doc_status_brief(ap2.payment_id) in ('TO_PAY','NEW')
                      )
   and mn.parent_amount - ins.Pkg_Payment.get_set_off_amount(mn.payment_id, mn.pol_header_id,NULL) > 0;
