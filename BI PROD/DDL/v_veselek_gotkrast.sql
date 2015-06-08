create or replace force view v_veselek_gotkrast as
select pp.pol_ser "Серия полиса",
       pp.num "Номер полиса",
       pp.notice_num "Номер заявления",
       pp.insurer_name "Страхователь",
       prod.description "Продукт",
       term.description "Периодичность",
       pp.f_resp "Валюта",
       dag.num "Аг договор",
       cag.name||' '||cag.first_name||' '||cag.middle_name "Агент",
       dep.name "Агентство",
       sh.description "Канал продаж",
       pp.status_name "Статус",
       pkg_policy.get_last_version_status(pp.policy_header_id) "Статус последней версии",
       ds.start_date,
       res.name "Причина",
       (select ap.grace_date
          from ac_payment ap,
               doc_doc    dd,
               document   d,
               doc_templ  dt,
               p_policy   p
         where p.pol_header_id = pp.policy_header_id
           and dd.parent_id = p.policy_id
           and ap.payment_id = dd.child_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = (select a.payment_id
                                  from (select ap2.payment_id,
                                               ap2.plan_date,
                                               p2.pol_header_id
                                          from ac_payment ap2,
                                               doc_doc    dd2,
                                               document   d2,
                                               doc_templ  dt2,
                                               p_policy   p2
                                         where dd2.parent_id = p2.policy_id
                                           and ap2.payment_id = dd2.child_id
                                           and d2.document_id = dd2.child_id
                                           and dt2.doc_templ_id = d2.doc_templ_id
                                           and dt2.brief = 'PAYMENT'
                                           and doc.get_doc_status_brief(ap2.payment_id) = 'TO_PAY'
                                           and Pkg_Payment.get_set_off_amount(ap2.payment_id, p2.pol_header_id,NULL) = 0
                                        order by ap2.plan_date asc
                                       )a,
                                       p_pol_header ph2
                                 where rownum = 1
                                   and a.pol_header_id = ph2.policy_header_id
                                   and ph2.policy_header_id = p.pol_header_id
                                )
       ) "Срок платежа первой неоплаты",
       (select ap.plan_date
          from ac_payment ap,
               doc_doc    dd,
               document   d,
               doc_templ  dt,
               p_policy   p
         where p.pol_header_id = pp.policy_header_id
           and dd.parent_id = p.policy_id
           and ap.payment_id = dd.child_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = (select a.payment_id
                                  from (select ap2.payment_id,
                                               ap2.plan_date,
                                               p2.pol_header_id
                                          from ac_payment ap2,
                                               doc_doc    dd2,
                                               document   d2,
                                               doc_templ  dt2,
                                               p_policy   p2
                                         where dd2.parent_id = p2.policy_id
                                           and ap2.payment_id = dd2.child_id
                                           and d2.document_id = dd2.child_id
                                           and dt2.doc_templ_id = d2.doc_templ_id
                                           and dt2.brief = 'PAYMENT'
                                           and doc.get_doc_status_brief(ap2.payment_id) <> 'ANNULATED'
                                           and Pkg_Payment.get_set_off_amount(ap2.payment_id, p2.pol_header_id,NULL) <> 0
                                        order by ap2.plan_date desc
                                       )a,
                                       p_pol_header ph2
                                 where rownum = 1
                                   and a.pol_header_id = ph2.policy_header_id
                                   and ph2.policy_header_id = p.pol_header_id
                                )
      ) "последний оплаченный ЭПГ",
      (select ap.plan_date
          from ac_payment ap,
               doc_doc    dd,
               document   d,
               doc_templ  dt,
               p_policy   p
         where p.pol_header_id = pp.policy_header_id
           and dd.parent_id = p.policy_id
           and ap.payment_id = dd.child_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = (select a.payment_id
                                  from (select ap2.payment_id,
                                               ap2.plan_date,
                                               p2.pol_header_id
                                          from ac_payment ap2,
                                               doc_doc    dd2,
                                               document   d2,
                                               doc_templ  dt2,
                                               p_policy   p2
                                         where dd2.parent_id = p2.policy_id
                                           and ap2.payment_id = dd2.child_id
                                           and d2.document_id = dd2.child_id
                                           and dt2.doc_templ_id = d2.doc_templ_id
                                           and dt2.brief = 'PAYMENT'
                                           and doc.get_doc_status_brief(ap2.payment_id) <> 'ANNULATED'
                                           and Pkg_Payment.get_set_off_amount(ap2.payment_id, p2.pol_header_id,NULL) = 0
                                        order by ap2.plan_date asc
                                       )a,
                                       p_pol_header ph2
                                 where rownum = 1
                                   and a.pol_header_id = ph2.policy_header_id
                                   and ph2.policy_header_id = p.pol_header_id
                                )
      )"следующий ЭПГ"
from v_policy_version_journal pp
     join p_policy pol on (pol.policy_id = pp.policy_id)
     left join t_product prod on (prod.product_id = pp.product_id)
     left join t_sales_channel sh on (sh.id = pp.sales_channel_id)
     left join t_payment_terms term on (term.id = pp.payment_term_id)
     left join p_policy_agent pc on (pc.policy_header_id = pp.policy_header_id and pc.status_id = 1)
     left join ag_contract_header ag on (ag.ag_contract_header_id = pc.ag_contract_header_id)
     left join document dag on (dag.document_id = ag.ag_contract_header_id)
     left join contact cag on (cag.contact_id = ag.agent_id)
     left join department dep on (dep.department_id = ag.agency_id)
     left join p_policy pg on (pg.pol_header_id = pol.pol_header_id and pg.version_num = pol.version_num + 1)
     left join t_decline_reason res on (res.t_decline_reason_id = pg.decline_reason_id)
     left join doc_status ds on (ds.document_id = pg.policy_id and ds.doc_status_ref_id = 21)

where pp.policy_id = pp.active_policy_id
      and pp.status_name not in ('Отменен','Завершен','Расторгнут')
      and cag.name||' '||cag.first_name||' '||cag.middle_name not like '%Неопознанный агент%'
      and pkg_policy.get_last_version_status(pp.policy_header_id) = 'Готовится к расторжению'
--   and pp.policy_header_id = 795819

--select * from V_POLICY_PAYMENT_SCHEDULE
;

