create or replace view v_underwriting_report
as
/* Зыонг Р.: Заявка 286038
   Отчет: "ОС. Отчет Андеррайтинг" */
with
/* Предварительная выборка */
src_ph as
(
SELECT sc.description sales_channel_name
      ,ph.policy_header_id
      ,ph.policy_id active_ver_id
      ,ph.last_ver_id
      ,ph.ids
      ,ph.product_id
      ,ph.start_date ph_start_date
      ,ph.agency_id
      ,(SELECT MAX(ds.change_date)
          FROM ins.doc_status     ds
              ,ins.doc_status_ref dsr_src
              ,ins.doc_status_ref dsr_cur
         WHERE ds.src_doc_status_ref_id = dsr_src.doc_status_ref_id
           AND ds.doc_status_ref_id = dsr_cur.doc_status_ref_id
           AND dsr_src.brief = 'NULL'
           AND dsr_cur.brief = 'PROJECT'
           AND ds.document_id = p.policy_id) project_create_date
      ,(SELECT MAX(ds.start_date)
          FROM ins.doc_status     ds
              ,ins.doc_status_ref dsr
         WHERE ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'NONSTANDARD'
           AND ds.document_id = p.policy_id) nonstandard_status_date
      ,(SELECT MAX(ds.start_date)
          FROM ins.doc_status     ds
              ,ins.doc_status_ref dsr_src
              ,ins.doc_status_ref dsr_cur
         WHERE ds.src_doc_status_ref_id = dsr_src.doc_status_ref_id
           AND ds.doc_status_ref_id = dsr_cur.doc_status_ref_id
           AND dsr_src.brief = 'NONSTANDARD'
           AND dsr_cur.brief = 'UNDERWRITING'
           AND ds.document_id = p.policy_id) underwriting_status_date
      ,(SELECT MAX(ds.start_date)
          FROM ins.doc_status     ds
              ,ins.doc_status_ref dsr
         WHERE ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'MED_OBSERV'
           AND ds.document_id = p.policy_id) med_observ_status_date
      ,(SELECT MAX(ds.start_date)
          FROM ins.doc_status     ds
              ,ins.doc_status_ref dsr
         WHERE ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'RE_REQUEST'
           AND ds.document_id = p.policy_id) re_request_status_date
  FROM ins.p_pol_header    ph
      ,ins.p_policy        p
      ,ins.t_sales_channel sc
 WHERE ph.policy_header_id = p.pol_header_id
   AND ph.sales_channel_id = sc.id
   AND p.version_num = 1
   AND EXISTS
 (SELECT NULL
          FROM ins.doc_status     ds
              ,ins.doc_status_ref dsr_src
              ,ins.doc_status_ref dsr_cur
         WHERE ds.src_doc_status_ref_id = dsr_src.doc_status_ref_id
           AND ds.doc_status_ref_id = dsr_cur.doc_status_ref_id
           AND dsr_src.brief = 'NONSTANDARD'
           AND dsr_cur.brief = 'UNDERWRITING'
           AND ds.document_id = p.policy_id)
   AND (ph.sales_channel_id IN
       (SELECT id FROM ins.t_sales_channel WHERE brief IN ('BR', 'MLM', 'CC', 'BR_WDISC', 'RLA')) OR
       (ph.sales_channel_id IN (SELECT id FROM ins.t_sales_channel WHERE brief IN ('BANK')) AND
       ph.product_id = (SELECT product_id FROM t_product WHERE brief = 'Nasledie')))
),
/* Выборка данных о расторжаении ДС */
decline_info as
(
SELECT policy_header_id
      ,decline_date
      ,decline_reason_name
  FROM (SELECT ph_dec.policy_header_id
              ,p_dec.decline_date
              ,dr.name decline_reason_name
              ,row_number() over(PARTITION BY ph_dec.policy_header_id ORDER BY p_dec.decline_date DESC NULLS LAST) rn
          FROM ins.p_pol_header     ph_dec
              ,ins.p_policy         p_dec
              ,ins.t_decline_reason dr
         WHERE ph_dec.policy_header_id = p_dec.pol_header_id
           AND p_dec.decline_reason_id = dr.t_decline_reason_id
           AND (p_dec.decline_date IS NOT NULL OR p_dec.decline_reason_id IS NOT NULL))
 WHERE rn = 1
),
/* Выборка подразделений и их руководителей */
head_of_dep_info as
(
SELECT agency_id
      ,obj_name_orig
  FROM (SELECT sag.agency_id
              ,c.obj_name_orig
              ,row_number() over(PARTITION BY sag.agency_id ORDER BY LEVEL DESC NULLS LAST) rn
          FROM (SELECT s.agency_id
                      ,aat.ag_agent_tree_id
                  FROM (SELECT agency_id
                              ,MAX(ag_contract_header_id) max_ag_contract_header_id
                          FROM ins.ag_contract_header
                         WHERE t_sales_channel_id IN
                               (SELECT id FROM ins.t_sales_channel WHERE brief IN ('BANK', 'BR', 'MLM'))
                           AND trunc(SYSDATE) BETWEEN date_begin AND date_break
                           AND agency_id IS NOT NULL
                         GROUP BY agency_id) s
                      ,ins.ag_agent_tree aat
                 WHERE aat.ag_contract_header_id = s.max_ag_contract_header_id
                   AND trunc(SYSDATE) BETWEEN aat.date_begin AND aat.date_end) sag
              ,ins.ag_contract_header ach
              ,ins.ag_agent_tree aat
              ,ins.contact c
         WHERE ach.ag_contract_header_id = aat.ag_contract_header_id
           AND ach.agent_id = c.contact_id
           AND ach.agency_id = sag.agency_id
           AND trunc(SYSDATE) BETWEEN aat.date_begin AND aat.date_end
           AND trunc(SYSDATE) BETWEEN ach.date_begin AND ach.date_break
         START WITH aat.ag_agent_tree_id = sag.ag_agent_tree_id
        CONNECT BY nocycle PRIOR aat.ag_parent_header_id = aat.ag_contract_header_id)
 WHERE rn = 1
)

SELECT sph.sales_channel_name
      , /* Канал продаж */sph.ids /* ИДС договора */
      ,pr.description product_name /* Продукт */
      ,c.obj_name_orig insurer_name /* ФИО страхователя */
      ,ot.name || ' - ' || dep.name agency_name /* Филиал */
      ,hdi.obj_name_orig head_of_branch_fio /* ФИО руководителя филиала */
      ,sph.ph_start_date /* Дата начала ДС */
      ,sph.project_create_date /* Дата заведения ДС в систему */
      ,sph.nonstandard_status_date /* Дата статуса "Нестандартный" */
      ,sph.underwriting_status_date /* Дата статуса “Андеррайтинг” */
      ,doc.get_last_doc_status_name(sph.active_ver_id) active_version_status /* Статус активной версии */
      ,doc.get_last_doc_status_name(sph.last_ver_id) current_version_status /* Статус текущей версии */
      ,doc.get_last_doc_status_date(sph.active_ver_id) active_version_status_date /* Дата статуса активной версии  */
      ,ROUND(SYSDATE - doc.get_last_doc_status_date(sph.active_ver_id)) active_version_days_count /* Количество дней в активной версии */
      ,sph.med_observ_status_date /* Дата статуса “Мед обследование” */
      ,sph.re_request_status_date /* Дата статуса “Запрос перестрахования” */
      ,CASE
         WHEN doc.get_last_doc_status_brief(sph.active_ver_id) IN
              ('UNDERWRITING'
              ,'DOC_REQUEST'
              ,'RE_REQUEST'
              ,'MED_OBSERV'
              ,'TO_AGENT_DS'
              ,'TO_AGENT_NEW_CONDITION'
              ,'NEW_CONDITION'
              ,'FROM_AGENT_NEW_CONDITION'
              ,'FROM_AGENT_DS') THEN
          ROUND(SYSDATE - sph.underwriting_status_date)
         ELSE
          ROUND((SELECT MIN(ds.start_date)
                   FROM ins.p_policy       p
                       ,ins.doc_status     ds
                       ,ins.doc_status_ref dsr
                  WHERE p.policy_id = ds.document_id
                    AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                    AND dsr.brief IN ('ACTIVE', 'STOP')
                    AND ds.start_date > sph.underwriting_status_date
                    AND p.pol_header_id = sph.policy_header_id) - sph.underwriting_status_date)
       END underwriting_ver_days_count /* Количество дней в андеррайтинге */
      ,(SELECT p.waiting_period_end_date FROM ins.p_policy p WHERE p.policy_id = sph.active_ver_id) waiting_period_end_date /* Дата окончания выжидательного периода (вкладка Доп. реквизиты/поле Дата окончания) */
      ,(SELECT SUM(nvl(po.set_off_amount, 0))
          FROM ins.v_policy_payment_schedule ps
              ,ins.v_policy_payment_set_off  po
              ,ins.p_policy_contact          pc
              ,ins.t_contact_pol_role        cpr
         WHERE ps.pol_header_id = sph.policy_header_id
           AND ps.doc_status_ref_name != 'Аннулирован'
           AND ps.document_id = po.main_doc_id
           AND po.doc_status_ref_name != 'Аннулирован'
           AND ps.policy_id = pc.policy_id
           AND cpr.id = pc.contact_policy_role_id
           AND cpr.brief = 'Страхователь'
           AND ((pc.contact_id = ps.contact_id) OR
               (fn_check_double_contact(pc.contact_id, ps.contact_id) = 1))) sum_set_off_amount /* Сумма оплаченных взносов */
      ,di.decline_date /* Дата расторжения */
      ,di.decline_reason_name /* Причина расторжения */
  FROM src_ph                 sph
      ,ins.t_product          pr
      ,ins.p_policy_contact   pc
      ,ins.t_contact_pol_role cpr
      ,ins.contact            c
      ,ins.department         dep
      ,ins.organisation_tree  ot
      ,head_of_dep_info       hdi
      ,decline_info           di
 WHERE sph.product_id = pr.product_id
   AND sph.active_ver_id = pc.policy_id
   AND pc.contact_policy_role_id = cpr.id
   AND cpr.brief = 'Страхователь'
   AND pc.contact_id = c.contact_id
   AND sph.agency_id = dep.department_id(+)
   AND dep.org_tree_id = ot.organisation_tree_id(+)
   AND sph.agency_id = hdi.agency_id(+)
   AND sph.policy_header_id = di.policy_header_id(+);

grant select on ins.v_underwriting_report to ins_eul, ins_read;
