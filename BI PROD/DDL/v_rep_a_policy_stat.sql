CREATE OR REPLACE FORCE VIEW V_REP_A_POLICY_STAT AS
(
SELECT ins.ent.obj_name('DEPARTMENT',ach.agency_id) "Агентство",
       nvl(ins.ent.obj_name('CONTACT',(SELECT ach_lead.agent_id
                                FROM ins.ag_contract_header ach_lead
                               WHERE ach_lead.ag_contract_header_id = ac_lead.contract_id)), 'Нет руководителя') "ФИО Рук",
       ins.ent.obj_name('CONTACT', ach.agent_id) "Агент по ДС",
       pp.pol_ser "Серия ДС",
       pp.pol_num "Номер ДС",
       tp.DESCRIPTION "Продукт",
       ph.start_date "Дата начала ДС",
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) "Страхователь",
       trunc(pp.sign_date, 'dd') "Дата акцепта ДС",
       dsr.NAME "Текщий статус",
       ins.pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии",
       da.Note "Шаг процесса",
       da.respons_pers "Ответственный",
       ds.change_date "Дата присвоения статуса",
       round(ds.change_date-pp.sign_date)
       /*round(lead(ds.change_date,1,SYSDATE) OVER (PARTITION BY ph.policy_header_id ORDER BY ds.change_date)-pp.sign_date,2)*/ "Длительность",
       da.plan_duration "Плановая длит.",
       da.plan_duration-round(lead(ds.change_date,1,SYSDATE) OVER (ORDER BY ds.change_date)-ds.change_date,2) "Отклонение",
       ph.ids "ИДС",
       ph.policy_header_id,
       (select min(ins.doc.get_doc_status_name(ap.payment_id))
          from ins.p_policy   p2,
               ins.ven_ac_payment ap,
               ins.document   d,
               ins.doc_templ  dt,
               ins.doc_doc    dd
         where dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = dd.child_id
           and ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           and ap.plan_date = (select min(ap3.plan_date)
                                 from ins.p_policy p3,
                                      ins.doc_doc  dd3,
                                      ins.ven_ac_payment ap3,
                                      ins.document   d3,
                                      ins.doc_templ  dt3
                                where p3.pol_header_id = p2.pol_header_id
                                  and dd3.parent_id = p3.policy_id
                                  and d3.document_id = dd3.child_id
                                  and dt3.doc_templ_id = d3.doc_templ_id
                                  and dt3.brief = 'PAYMENT'
                                  and ap3.payment_id = dd3.child_id
                                  and ins.doc.get_doc_status_brief(ap3.payment_id) <> 'ANNULATED'
                               )
           and p2.pol_header_id = ph.policy_header_id
       ) "Статус 1 ЭПГ",
       (case when ins.pkg_policy.get_last_version_status(ph.policy_header_id) in ('Доработка','Новый') then
        (select decode(cm.description,'Прямое списание с карты',cm.description,'Перечисление средств Плательщиком',cm.description,null)
          from ins.t_collection_method cm
         where cm.id = pp.collection_method_id
        )end
       )"Вид расчета",
       ds.user_name,
       (select trunc(ds.change_date - ds2.change_date)
          from (select ds.change_date,
                       ds.doc_status_id,
                       ds.document_id,
                       row_number() over (partition by ds.document_id order by ds.change_date desc) c
                  from ins.doc_status ds
               )a,
               ins.doc_status ds2
         where a.document_id = ds2.document_id
           and ds2.doc_status_id = a.doc_status_id
           and ds2.document_id = pp.policy_id
           and a.c = 2
       ) "дней от пред. до тек. статуса",
       (select min(ds2.change_date)
          from ins.p_policy       p2,
               ins.doc_status     ds2,
               ins.doc_status_ref dsr2
         where p2.pol_header_id = ph.policy_header_id
           and ds2.document_id = p2.policy_id
           and dsr2.doc_status_ref_id = ds2.doc_status_ref_id
           and dsr2.brief in ('CONCLUDED','CURRENT')
       ) "мин дата статуса ДП или Д",
       (select min(ds2.change_date)
          from ins.p_policy       p2,
               ins.doc_status     ds2,
               ins.doc_status_ref dsr2
         where p2.pol_header_id = ph.policy_header_id
           and ds2.document_id = p2.policy_id
           and dsr2.doc_status_ref_id = ds2.doc_status_ref_id
           and dsr2.brief in ('CONCLUDED','CURRENT')
       ) - pp.sign_date "Дней от акцепта до ДП или Д"

  FROM ins.p_pol_header       ph,
       ins.ven_p_policy       pp,
       ins.t_product          tp,
       ins.ag_contract_header ach,
       ins.ag_contract        ac,
       ins.ag_contract        ac_lead,
       ins.department         dep,
       ins.doc_status         ds,
       ins.doc_templ_status   dts_src,
       ins.doc_templ_status   dts_dst,
       ins.doc_status_allowed da,
       ins.doc_status_ref     dsr
 WHERE ph.policy_id = pp.policy_id
   AND tp.product_id = ph.product_id
   AND ach.ag_contract_header_id = ins.pkg_renlife_utils.get_p_agent_current(ph.policy_header_id,ds.start_date)
   AND ach.agency_id = dep.department_id
   AND ach.last_ver_id = ac.ag_contract_id
   AND ac.contract_leader_id = ac_lead.ag_contract_id (+)
   AND ins.doc.get_doc_status_rec_id(pp.policy_id) = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ds.doc_status_ref_id = dts_dst.doc_status_ref_id
   AND dts_dst.doc_templ_id = pp.doc_templ_id
   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
   AND dts_src.doc_templ_id = pp.doc_templ_id
   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
   AND pp.sign_date BETWEEN (SELECT r.param_value
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'A_POLICY_ST'
                                AND r.param_name = 'DATE_FROM')
                            AND (SELECT r.param_value
                                   FROM ins_dwh.rep_param r
                                  WHERE r.rep_name = 'A_POLICY_ST'
                                    AND r.param_name = 'DATE_TO')
   AND dep.name IN (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'A_POLICY_ST'
                       AND r.param_name = 'AGENCY')
 )  ORDER BY 1,2,5,8;

