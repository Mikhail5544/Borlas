CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_A_POLICY_STAT AS
(SELECT /*+ ORDERED */ ins.ent.obj_name ('DEPARTMENT', ach.agency_id) "Агентство",
           NVL
              (ins.ent.obj_name ('CONTACT',
                                 (SELECT ach_lead.agent_id
                                    FROM ins.ag_contract_header ach_lead
                                   WHERE ach_lead.ag_contract_header_id =
                                                           ac_lead.contract_id)
                                ),
               'Нет руководителя'
              ) "ФИО Рук",
           ins.ent.obj_name ('CONTACT', ach.agent_id) "Агент по ДС",
           pp.pol_ser "Серия ДС", pp.pol_num "Номер ДС",
           tp.description "Продукт", ph.start_date "Дата начала ДС",
           ins.ent.obj_name
              ('CONTACT',
               ins.pkg_policy.get_policy_contact (pp.policy_id,
                                                  'Страхователь')
              ) "Страхователь",
           TRUNC (pp.sign_date, 'dd') "Дата акцепта ДС",
           dsr.NAME "Текщий статус",
           ins.pkg_policy.get_last_version_status
                               (ph.policy_header_id)
                                                    "Статус последней версии",
           da.note "Шаг процесса", da.respons_pers "Ответственный",
           ds.change_date "Дата присвоения статуса",
           ROUND (ds.change_date - pp.sign_date)
                                                /*round(lead(ds.change_date,1,SYSDATE) OVER (PARTITION BY ph.policy_header_id ORDER BY ds.change_date)-pp.sign_date,2)*/
           "Длительность", da.plan_duration "Плановая длит.",
             da.plan_duration
           - ROUND (  LEAD (ds.change_date, 1, SYSDATE) OVER (ORDER BY ds.change_date)
                    - ds.change_date,
                    2
                   ) "Отклонение",
           ph.ids "ИДС", ph.policy_header_id,
           (SELECT MIN
                      (ins.doc.get_doc_status_name (ap.payment_id)
                      )
              FROM ins.p_policy p2,
                   ins.ven_ac_payment ap,
                   ins.document d,
                   ins.doc_templ dt,
                   ins.doc_doc dd
             WHERE dd.parent_id = p2.policy_id
               AND d.document_id = dd.child_id
               AND dt.doc_templ_id = d.doc_templ_id
               AND dt.brief = 'PAYMENT'
               AND ap.payment_id = dd.child_id
               AND ins.doc.get_doc_status_brief (ap.payment_id) <> 'ANNULATED'
               AND ap.plan_date =
                      (SELECT MIN (ap3.plan_date)
                         FROM ins.p_policy p3,
                              ins.doc_doc dd3,
                              ins.ven_ac_payment ap3,
                              ins.document d3,
                              ins.doc_templ dt3
                        WHERE p3.pol_header_id = p2.pol_header_id
                          AND dd3.parent_id = p3.policy_id
                          AND d3.document_id = dd3.child_id
                          AND dt3.doc_templ_id = d3.doc_templ_id
                          AND dt3.brief = 'PAYMENT'
                          AND ap3.payment_id = dd3.child_id
                          AND ins.doc.get_doc_status_brief (ap3.payment_id) <>
                                                                   'ANNULATED')
               AND p2.pol_header_id = ph.policy_header_id) "Статус 1 ЭПГ",
           (CASE
               WHEN ins.pkg_policy.get_last_version_status
                                                          (ph.policy_header_id) IN
                                                       ('Доработка', 'Новый')
                  THEN (SELECT DECODE (cm.description,
                                       'Прямое списание с карты', cm.description,
                                       'Перечисление средств Плательщиком', cm.description,
                                       NULL
                                      )
                          FROM ins.t_collection_method cm
                         WHERE cm.ID = pp.collection_method_id)
            END
           ) "Вид расчета",
           ds.user_name,
           (SELECT TRUNC (ds.change_date - ds2.change_date
                         )
              FROM (SELECT ds.change_date, ds.doc_status_id, ds.document_id,
                           ROW_NUMBER () OVER (PARTITION BY ds.document_id ORDER BY ds.change_date DESC)
                                                                            c
                      FROM ins.doc_status ds) a,
                   ins.doc_status ds2
             WHERE a.document_id = ds2.document_id
               AND ds2.doc_status_id = a.doc_status_id
               AND ds2.document_id = pp.policy_id
               AND a.c = 2) "дней от пред. до тек. статуса",
           (SELECT MIN (ds2.change_date)
              FROM ins.p_policy p2,
                   ins.doc_status ds2,
                   ins.doc_status_ref dsr2
             WHERE p2.pol_header_id = ph.policy_header_id
               AND ds2.document_id = p2.policy_id
               AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
               AND dsr2.brief IN ('CONCLUDED', 'CURRENT'))
                                                  "мин дата статуса ДП или Д",
             (SELECT MIN (ds2.change_date)
                FROM ins.p_policy p2,
                     ins.doc_status ds2,
                     ins.doc_status_ref dsr2
               WHERE p2.pol_header_id = ph.policy_header_id
                 AND ds2.document_id = p2.policy_id
                 AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
                 AND dsr2.brief IN ('CONCLUDED', 'CURRENT'))
           - pp.sign_date "Дней от акцепта до ДП или Д"
      FROM ins.p_pol_header ph,
           ins.ven_p_policy pp,
           ins.t_product tp,
           ins.ag_contract_header ach,
           ins.ag_contract ac,
           ins.ag_contract ac_lead,
           ins.department dep,
           ins.doc_status ds,
           ins.doc_templ_status dts_src,
           ins.doc_templ_status dts_dst,
           ins.doc_status_allowed da,
           ins.doc_status_ref dsr
     WHERE ph.policy_id = pp.policy_id
       AND tp.product_id = ph.product_id
       AND ach.ag_contract_header_id =
              ins.pkg_renlife_utils.get_p_agent_current (ph.policy_header_id,
                                                         ds.start_date
                                                        )
       AND ach.agency_id = dep.department_id
       AND ach.last_ver_id = ac.ag_contract_id
       AND ac.contract_leader_id = ac_lead.ag_contract_id(+)
       AND ins.doc.get_doc_status_rec_id (pp.policy_id) = ds.doc_status_id
       AND ds.doc_status_ref_id = dsr.doc_status_ref_id
       AND ds.doc_status_ref_id = dts_dst.doc_status_ref_id
       AND dts_dst.doc_templ_id = pp.doc_templ_id
       AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
       AND dts_src.doc_templ_id = pp.doc_templ_id
       AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
       AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
       AND pp.sign_date BETWEEN --to_date('01-12-2010','dd-mm-yyyy') and to_date('01-03-2012','dd-mm-yyyy')
                                (SELECT r.param_value
                                   FROM ins_dwh.rep_param r
                                  WHERE r.rep_name = 'A_POLICY_ST'
                                    AND r.param_name = 'DATE_FROM')
                            AND (SELECT r.param_value
                                   FROM ins_dwh.rep_param r
                                  WHERE r.rep_name = 'A_POLICY_ST'
                                    AND r.param_name = 'DATE_TO')
       AND dep.NAME IN /*'Сбербанк'*/(
                  SELECT r.param_value
                    FROM ins_dwh.rep_param r
                   WHERE r.rep_name = 'A_POLICY_ST'
                         AND r.param_name = 'AGENCY'))
   ORDER BY 1, 2, 5, 8
;

