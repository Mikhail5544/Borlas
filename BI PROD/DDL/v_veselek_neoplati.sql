CREATE OR REPLACE FORCE VIEW V_VESELEK_NEOPLATI AS
select pp.pol_ser "Серия полиса",
       pp.num "Номер полиса",
       pp.ids,
       pp.insurer_name "Страхователь",
       pp.status_name "Статус",
       pkg_policy.get_last_version_status(pp.policy_header_id) "Статус последней версии",
       prod.description "Продукт",
       term.description "Периодичность",
       pp.f_resp "Валюта",
       a.plan_date "План график",
       a.plan_date + 45 "Льготный период",
       her.max_oplat "Дата оплаченного графика",
       a.amount "Сумма по договору",
       a.pay_amount "Зачтено по договору",

       Pkg_Payment.get_calc_amount(pp.policy_header_id) - Pkg_Payment.get_pay_pol_header_amount_pfa(TO_DATE('01.01.1900','DD.MM.YYYY'), TO_DATE('01.01.3000','DD.MM.YYYY'), pp.policy_header_id) "Задолженность по договору",
       dag.num "Аг договор",
       cag.name||' '||cag.first_name||' '||cag.middle_name "Агент",
       dep.name "Агентство",
       sh.description "Канал продаж",
       pp.start_date_header "Дата начала действия договора",


       /*t1.telephone_prefix||'-'||t1.telephone_number tel1,
       t2.telephone_prefix||'-'||t2.telephone_number tel2,
       t3.telephone_prefix||'-'||t3.telephone_number tel3,
       t4.telephone_prefix||'-'||t4.telephone_number tel4,*/
       ad1.name "Адрес",
       at.description "Тип адреса",
       (select wmsys.wm_concat(ttt.DESCRIPTION||'/'||ct.telephone_number)
          from cn_contact_telephone ct,
               t_telephone_type     ttt
         where ct.telephone_type = ttt.ID
           and ct.contact_id = pp.insurer_id --Страхователь
       )"Тип/тел",
       (select tpr.province_name
         from t_province tpr
        where tpr.province_id = p.region_id)
        "Регион"
       /*ad2.name "Почтовый адрес",
       ad3.name "Постоянной регистрации",
       ad6.name "Юридический адрес"*//*,
       Pkg_Payment.get_calc_amount(pp.policy_header_id) calc_amount,
       Pkg_Payment.get_pay_pol_header_amount_pfa(TO_DATE('01.01.1900','DD.MM.YYYY'), TO_DATE('01.01.3000','DD.MM.YYYY'), pp.policy_header_id)
       pay_amount*/

from v_policy_version_journal pp
left join p_policy p on (p.policy_id = pp.policy_id)
     left join t_product prod on (prod.product_id = pp.product_id)
     left join t_sales_channel sh on (sh.id = pp.sales_channel_id)
     left join t_payment_terms term on (term.id = pp.payment_term_id)
     left join p_policy_agent pc on (pc.policy_header_id = pp.policy_header_id and pc.status_id not in (2,4))
     left join ag_contract_header ag on (ag.ag_contract_header_id = pc.ag_contract_header_id)
     left join document dag on (dag.document_id = ag.ag_contract_header_id)
     left join contact cag on (cag.contact_id = ag.agent_id)
     left join department dep on (dep.department_id = ag.agency_id)
     left join (SELECT p.pol_header_id,
                       a.payment_id,
                       a.amount,
                       nvl(a.plan_date,a.due_date) plan_date,
                       a.due_date,
                       a.grace_date,
                       a.payment_number,
                       dd.parent_amount part_amount,
                       Pkg_Payment.get_set_off_amount(d.document_id, NULL,NULL) pay_amount,
                       Pkg_Payment.get_set_off_amount(d.document_id,p.pol_header_id,NULL) part_pay_amount
                 FROM DOCUMENT d,
                      AC_PAYMENT a,
                      DOC_TEMPL dt,
                      DOC_DOC dd,
                      P_POLICY p,
                      CONTACT c,
                      DOC_STATUS ds,
                      DOC_STATUS_REF dsr
                 WHERE d.document_id = a.payment_id
                       AND d.doc_templ_id = dt.doc_templ_id
                       AND dt.brief = 'PAYMENT'
                       AND dd.child_id = d.document_id
                       AND dd.parent_id = p.policy_id
                       AND a.contact_id = c.contact_id
                       AND ds.document_id = d.document_id
                       AND ds.start_date = (SELECT MAX(dss.start_date)
                                            FROM DOC_STATUS dss
                                            WHERE dss.document_id = d.document_id)
                       AND dsr.doc_status_ref_id = ds.doc_status_ref_id) a on (a.pol_header_id = pp.policy_header_id)
     left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                from doc_status ds
                where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (a.payment_id = ds.document_id )

/*left join cn_contact_telephone t1 on (t1.contact_id = pp.insurer_id and t1.telephone_type = 1)
left join cn_contact_telephone t2 on (t2.contact_id = pp.insurer_id and t2.telephone_type = 2)
left join cn_contact_telephone t3 on (t3.contact_id = pp.insurer_id and t3.telephone_type = 3)
left join cn_contact_telephone t4 on (t4.contact_id = pp.insurer_id and t4.telephone_type = 4)*/
left join cn_contact_address a1 on (a1.contact_id = pp.insurer_id)
left join cn_address ad1 on (ad1.id = a1.adress_id)
left join t_address_type at on (at.id = a1.address_type)
/*left join cn_contact_address a2 on (a2.contact_id = pp.insurer_id and a2.address_type = 2)
left join cn_address ad2 on (ad2.id = a2.adress_id)
left join cn_contact_address a3 on (a3.contact_id = pp.insurer_id and a3.address_type = 3)
left join cn_address ad3 on (ad3.id = a3.adress_id)
left join cn_contact_address a6 on (a6.contact_id = pp.insurer_id and a6.address_type = 6)
left join cn_address ad6 on (ad6.id = a6.adress_id)*/

left join ( select max(a.due_date) max_oplat,
                   a.pol_header_id
            from (SELECT p.pol_header_id,
                         a.payment_id,
                         a.amount,
                         nvl(a.plan_date,a.due_date) plan_date,
                         a.due_date,
                         a.grace_date,
                         a.payment_number,
                         dd.parent_amount part_amount,
                         Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL) pay_amount,
                         Pkg_Payment.get_set_off_amount(d.document_id, p.pol_header_id,NULL) part_pay_amount
                  FROM DOCUMENT d,
                       AC_PAYMENT a,
                       DOC_TEMPL dt,
                       DOC_DOC dd,
                       P_POLICY p,
                       CONTACT c,
                       DOC_STATUS ds,
                       DOC_STATUS_REF dsr
                  WHERE d.document_id = a.payment_id
                        AND d.doc_templ_id = dt.doc_templ_id
                        AND dt.brief = 'PAYMENT'
                        AND dd.child_id = d.document_id
                        AND dd.parent_id = p.policy_id
                        AND a.contact_id = c.contact_id
                        AND ds.document_id = d.document_id
                        AND ds.start_date = (SELECT MAX(dss.start_date)
                                             FROM DOC_STATUS dss
                                             WHERE dss.document_id = d.document_id)
                        AND dsr.doc_status_ref_id = ds.doc_status_ref_id) a
left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
           from doc_status ds
           where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (a.payment_id = ds.document_id )
where ds.name_pl = 'Оплачен'
group by a.pol_header_id ) her on (her.pol_header_id = pp.policy_header_id)

where ds.name_pl in ('К оплате')
      and pp.policy_id = pp.active_policy_id
      --and a.plan_date < to_date('28-02-2009','dd-mm-yyyy')+45
      and pp.status_name not in ('Отменен','Завершен','Расторгнут')
      --and pkg_policy.get_last_version_status(pp.policy_header_id) <> 'Готовится к расторжению'
      and sh.description = 'Агентский'
      and cag.name||' '||cag.first_name||' '||cag.middle_name not like '%Неопознанный Агент%'
      and dep.department_id <> 8127--in ('Брокерский','Банковский')--'Агентский'
;

