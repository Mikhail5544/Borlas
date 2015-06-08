CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_A_POLICY_STAT_2 AS
(
SELECT ins.ent.obj_name('DEPARTMENT',ach.agency_id) "Агентство",
       NVL(ins.ent.obj_name('CONTACT',(SELECT ach_lead.agent_id
                                         FROM ins.ag_contract_header ach_lead,
                                              ins.ag_contract        ac_lead
                                        WHERE ach_lead.ag_contract_header_id = ac_lead.contract_id
                                          AND ac_lead.ag_contract_id = ac.contract_leader_id)
                           ), 'Нет руководителя') "ФИО Рук",
       ins.ent.obj_name('CONTACT', ach.agent_id) "Агент по ДС",
       pp.pol_ser "Серия ДС",
       pp.pol_num "Номер ДС",
       tp.DESCRIPTION "Продукт",
       ph.start_date "Дата начала ДС",
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) "Страхователь",
/*       (SELECT ent.obj_name('CONTACT', aas.assured_contact_id)
          FROM ins.as_asset aa,
               ins.as_assured aas
         WHERE aa.p_policy_id = ph.policy_id
           AND aas.as_assured_id = aa.as_asset_id
           AND ROWNUM = 1 --первый попавшийся
       )"Застрахованный", */
       TRUNC(pp.sign_date, 'dd') "Дата акцепта ДС",
       dsr.NAME "Текщий статус",
       ins.pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии",
       da.Note "Шаг процесса",
       da.respons_pers "Ответственный",

       CASE WHEN ds.change_date - ds.start_date > 1
            THEN ds.change_date
            ELSE ds.start_date
        END "Дата присвоения статуса",
       FLOOR(ds.change_date - pp.sign_date) "От даты акцепта до тек",
       FLOOR(SYSDATE - ds.change_date) "В текущем статусе",
       FLOOR(SYSDATE - pp.sign_date) "Всего по договору",
       ph.ids "ИДС",
       ds.user_name
  FROM ins.p_pol_header       ph,
       ins.ven_p_policy       pp,
       ins.t_product          tp,
       ins.ag_contract_header ach,
       ins.ag_contract        ac,
       ins.department         dep,
       ins.doc_status         ds,
       ins.doc_templ_status   dts_src,
       ins.doc_templ_status   dts_dst,
       ins.doc_status_allowed da,
       ins.doc_status_ref     dsr,
       ins.p_policy_agent     pa
 WHERE ph.policy_id = pp.policy_id
   AND tp.product_id = ph.product_id
   AND ph.policy_header_id = pa.policy_header_id
   AND pa.ag_contract_header_id = ach.ag_contract_header_id
   AND pa.date_start <= ds.start_date
   AND pa.date_end > ds.start_date
   AND pa.status_id <> 4
   AND dep.department_id = ach.agency_id
   AND ac.ag_contract_id = ins.PKG_AGENT_1.GET_STATUS_BY_DATE(ach.ag_contract_header_id, ds.start_date)
   AND ins.doc.get_doc_status_rec_id(pp.policy_id) = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ds.doc_status_ref_id = dts_dst.doc_status_ref_id
   AND dts_dst.doc_templ_id = pp.doc_templ_id
   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
   AND dts_src.doc_templ_id = pp.doc_templ_id
   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
   AND da.respons_pers IS NOT NULL
   AND pp.sign_date BETWEEN (SELECT r.param_value
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'A_POLICY_ST_2'
                                AND r.param_name = 'DATE_FROM')
                        AND (SELECT r.param_value
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'A_POLICY_ST_2'
                                AND r.param_name = 'DATE_TO')
   AND dep.name IN (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'A_POLICY_ST_2'
                       AND r.param_name = 'AGENCY')
   AND da.respons_pers IN (SELECT r.param_value
                             FROM ins_dwh.rep_param r
                            WHERE r.rep_name = 'A_POLICY_ST_2'
                              AND r.param_name = 'RESPONS_PERSON')
 )  ORDER BY 1,2,5,8
;

