CREATE OR REPLACE FORCE VIEW V_REP_POL_STATUS_DET AS
SELECT ent.obj_name('CONTACT',ach_lead.agent_id) "ФИО Рук",
       ent.obj_name('CONTACT', ach.agent_id) "Агент по ДС",
       pp.pol_ser "Серия ДС",
       pp.pol_num "Номер ДС",
       tp.DESCRIPTION "Продукт",
       ph.start_date "Дата начала ДС",
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) "Страхователь",
       --trunc(pp.sign_date, 'dd') "Дата акцепта ДС",
       CASE WHEN dsr2.brief='NULL' THEN 'Акцепт' ELSE dsr2.NAME END "Предидущий статус",
       ds.change_date "Дата присвоения статуса",
       dsr.NAME "Текщий статус",
       lead(ds.change_date,1,SYSDATE) OVER (PARTITION BY ph.policy_header_id ORDER BY ds.change_date) "Дата статуса",
       da.Note "Шаг процесса",
       da.respons_pers "Ответственный",
       ds.user_name "Изменил статус",
--       round(ds.change_date-pp.sign_date,2)
       round(lead(ds.change_date,1,SYSDATE) OVER (PARTITION BY ph.policy_header_id ORDER BY ds.change_date)-ds.change_date,2) "Длительность",
       da.plan_duration "Плановая длит.",
       da.plan_duration-round(lead(ds.change_date,1,SYSDATE) OVER (ORDER BY ds.change_date)-ds.change_date,2) "Отклонение"
  FROM p_pol_header       ph,
       ven_p_policy       pp,
       t_product          tp,
       ag_contract_header ach,
       ag_contract        ac,
       ag_contract        ac_lead,
       ag_contract_header ach_lead,
       department         dep,
       doc_status         ds,
       doc_templ_status   dts_src,
       doc_templ_status   dts_dst,
       doc_status_allowed da,
       doc_status_ref     dsr,
       doc_status_ref     dsr2,
       p_policy_agent     pa
 WHERE ph.policy_header_id = pp.pol_header_id
   AND tp.product_id = ph.product_id
   AND ph.policy_header_id = pa.policy_header_id
   AND pa.ag_contract_header_id = ach.ag_contract_header_id
   AND pa.date_start <= ds.start_date
   AND pa.date_end > ds.start_date
   AND pa.status_id <> 4
   AND ach.agency_id = dep.department_id
   AND ach.last_ver_id = ac.ag_contract_id
   AND ac.contract_leader_id = ac_lead.ag_contract_id
   AND ac_lead.contract_id = ach_lead.ag_contract_header_id
   AND ph.Ids IN (SELECT PARAM_VALUE FROM ins_dwh.rep_param WHERE rep_name = 'P_STAT_DET' AND param_name = 'PH_ID')
   --8759044 --8765214 --10194094
--   AND pp.policy_id = ds.document_id
   AND pp.policy_id = ds.document_id
   AND ds.src_doc_status_ref_id = dsr2.doc_status_ref_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND ds.doc_status_ref_id = dts_dst.doc_status_ref_id
   AND dts_dst.doc_templ_id = pp.doc_templ_id
   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
   AND dts_src.doc_templ_id = pp.doc_templ_id
   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
;

