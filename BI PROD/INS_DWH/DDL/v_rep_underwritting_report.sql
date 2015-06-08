CREATE OR REPLACE VIEW INS_DWH.V_REP_UNDERWRITTING_REPORT AS
WITH wpol_head AS
 (SELECT ph.*
        ,dep.name dep_name
        ,tp.description prod_name
        ,vi.contact_name insurer_name
        ,ll.description ins_risk_lev
        ,(SELECT MAX(pad.ag_contract_header_id) keep(dense_rank FIRST ORDER BY pad.date_begin DESC, pad.p_policy_agent_doc_id DESC)

            FROM ins.p_policy_agent_doc pad
           WHERE pad.policy_header_id = ph.policy_header_id
             AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN ('ERROR')) ag_cur_head_id
        ,(SELECT MAX(pad.ag_contract_header_id) keep(dense_rank FIRST ORDER BY pad.date_begin ASC, pad.p_policy_agent_doc_id ASC)

            FROM ins.p_policy_agent_doc pad
           WHERE pad.policy_header_id = ph.policy_header_id
             AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN ('ERROR')) ag_head_id

    FROM ins.p_pol_header ph
        ,ins.p_policy     pp
        ,ins.department   dep
        ,t_product        tp
        ,ins.v_pol_issuer vi
        ,ins.contact      cins
        ,ins.t_risk_level ll
   WHERE ph.policy_id = pp.policy_id
     AND dep.department_id(+) = ph.agency_id
     AND tp.product_id = ph.product_id
     AND pp.policy_id = vi.policy_id
     AND vi.contact_id = cins.contact_id
     AND cins.risk_level = ll.t_risk_level_id(+)
     AND pp.sign_date BETWEEN --to_date('01.01.2010','dd.mm.yyyy') and to_date('31.12.2013','dd.mm.yyyy')
         TO_DATE((SELECT r.param_value
                   FROM ins_dwh.rep_param r
                  WHERE r.rep_name = 'under_rep'
                    AND r.param_name = 'DATE_FROM')
                ,'dd.mm.yyyy')
     AND TO_DATE((SELECT r.param_value
                   FROM ins_dwh.rep_param r
                  WHERE r.rep_name = 'under_rep'
                    AND r.param_name = 'DATE_TO')
                ,'dd.mm.yyyy')

     AND tp.brief NOT IN ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')

  ),
wag_head AS
 (SELECT ph.policy_header_id
        ,ach.agent_id
        ,ach.agency_id
        ,ac_lead.contract_id       ac_lead_contract_id
        ,dep.name                  dep_name
        ,ach.is_new
        ,ach.ag_contract_header_id
        ,cagc.obj_name_orig        agent_current
        ,clead.obj_name_orig       lead_name
        ,ll.description            risk_level_name
    FROM ins.wpol_head          ph
        ,ins.ag_contract_header ach
        ,ins.ag_contract        ac
        ,ins.ag_contract        ac_lead
        ,ins.ag_contract_header ach_lead
        ,ins.department         dep
        ,ins.contact            cagc
        ,ins.contact            clead
        ,ins.t_risk_level       ll
   WHERE ach.ag_contract_header_id = ph.ag_head_id
     AND ach.agency_id = dep.department_id
     AND ach.last_ver_id = ac.ag_contract_id
     AND ac.contract_leader_id = ac_lead.ag_contract_id(+)
     AND ac_lead.contract_id = ach_lead.ag_contract_header_id(+)
     AND ach_lead.agent_id = clead.contact_id(+)
     AND cagc.contact_id = ach.agent_id
     AND cagc.risk_level = ll.t_risk_level_id(+)),
wag_cur_head AS
 (SELECT ph.policy_header_id
        ,ach.agent_id
        ,ach.agency_id
        ,ach.ag_contract_header_id
        ,cagc.obj_name_orig        agent_name
        ,ll.description            risk_level_name

    FROM ins.wpol_head          ph
        ,ins.ag_contract_header ach
        ,ins.contact            cagc
        ,ins.t_risk_level       ll
   WHERE ach.ag_contract_header_id = ph.ag_cur_head_id
     AND cagc.contact_id = ach.agent_id
     AND cagc.risk_level = ll.t_risk_level_id(+)),
qmain AS
 (

  SELECT --ins.ent.obj_name('DEPARTMENT',NVL(a.agency_id,ph.agency_id)),
   nvl(a.dep_name, dep_ph.name) "Агентство"
    ,nvl(a.lead_name, 'Нет руководителя') "ФИО Рук"
    ,ins.ent.obj_name('CONTACT', a.agent_id) "Агент по ДС"
    ,a.risk_level_name "Уровень риска Агента по ДС"
    ,pp.pol_ser "Серия ДС"
    ,pp.pol_num "Номер ДС"
    ,ph.prod_name "Продукт"
    ,ph.start_date "Дата начала ДС"
    ,ph.insurer_name "Страхователь"
    ,ph.ins_risk_lev "Уровень риска Страхователя"
    ,trunc(pp.sign_date, 'dd') "Дата акцепта ДС"
    ,to_char(pp.sign_date, 'YYYY') "Дата акцепта Год"
    ,to_char(pp.sign_date, 'mm') "Дата акцепта Месяц"
    ,dsr.name "Текщий статус"
    ,ins.pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии"
    ,(SELECT da.note
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Шаг процесса"
    ,(SELECT da.respons_pers
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Ответственный"
    ,ds.change_date "Дата присвоения статуса"
    ,ROUND(ds.change_date - pp.sign_date) "Длительность"
    ,(SELECT da.plan_duration
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Плановая длит."
    ,(SELECT da.plan_duration -
            ROUND(lead(ds.change_date, 1, SYSDATE) over(ORDER BY ds.change_date) - ds.change_date, 2)
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Отклонение"
    ,ph.ids "ИДС"
    ,ph.policy_header_id
    ,
    --

    (SELECT MIN(ins.doc.get_doc_status_name(ap.payment_id))
       FROM ins.p_policy       p2
           ,ins.ven_ac_payment ap
           ,ins.document       d
           ,ins.doc_templ      dt
           ,ins.doc_doc        dd
      WHERE dd.parent_id = p2.policy_id
        AND d.document_id = dd.child_id
        AND dt.doc_templ_id = d.doc_templ_id
        AND dt.brief = 'PAYMENT'
        AND ap.payment_id = dd.child_id
        AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
        AND ap.plan_date =
            (SELECT MIN(ap3.plan_date)
               FROM ins.p_policy       p3
                   ,ins.doc_doc        dd3
                   ,ins.ven_ac_payment ap3
                   ,ins.document       d3
                   ,ins.doc_templ      dt3
              WHERE p3.pol_header_id = p2.pol_header_id
                AND dd3.parent_id = p3.policy_id
                AND d3.document_id = dd3.child_id
                AND dt3.doc_templ_id = d3.doc_templ_id
                AND dt3.brief = 'PAYMENT'
                AND ap3.payment_id = dd3.child_id
                AND ins.doc.get_doc_status_brief(ap3.payment_id) <> 'ANNULATED')
        AND p2.pol_header_id = ph.policy_header_id) "Статус 1 ЭПГ"
    ,

    -- изменено по заявке №70663
    (SELECT cm.description FROM ins.t_collection_method cm WHERE cm.id = pp.collection_method_id) "Вид расчета"
    ,ds.user_name
    ,(SELECT trunc(ds.change_date - ds2.change_date)
       FROM (SELECT ds.change_date
                   ,ds.doc_status_id
                   ,ds.document_id
                   ,row_number() over(PARTITION BY ds.document_id ORDER BY ds.change_date DESC) c
               FROM ins.doc_status ds) a
           ,ins.doc_status ds2
      WHERE a.document_id = ds2.document_id
        AND ds2.doc_status_id = a.doc_status_id
        AND ds2.document_id = pp.policy_id
        AND a.c = 2) "дней от пред. до тек. статуса"
    ,(SELECT MIN(ds2.change_date)
       FROM ins.p_policy       p2
           ,ins.doc_status     ds2
           ,ins.doc_status_ref dsr2
      WHERE p2.pol_header_id = ph.policy_header_id
        AND ds2.document_id = p2.policy_id
        AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
        AND dsr2.brief IN ('CONCLUDED', 'CURRENT')) "мин дата статуса ДП или Д"
    ,nvl(pp.is_group_flag, 0) "Групповой ДС"
    ,a_cur.agent_name "Действующий агент"
    ,a_cur.risk_level_name "Уровень риска Действ агента"
    --Чирков /192022 Доработка АС BI в части обеспечения регистрации
    ,(SELECT CASE jtw.work_type
              WHEN 0 THEN
               'Технические работы'
              WHEN 1 THEN
               'Рассмотрение в СБ'
              WHEN 2 THEN
               'Рассмотрение в ЮУ'
            END "Технические работы"
       FROM ins.journal_tech_work jtw
      WHERE jtw.policy_header_id = ph.policy_header_id
        AND jtw.start_date = (SELECT MIN(jtw_.start_date)
                                FROM ins.journal_tech_work jtw_
                               WHERE jtw_.policy_header_id = jtw.policy_header_id)) "Технические работы"
  -- Чирков /192022//

    FROM wpol_head          ph
         ,ins.ven_p_policy   pp
         ,ins.doc_status     ds
         ,ins.doc_status_ref dsr
         ,wag_head           a
         ,wag_cur_head       a_cur
         ,ins.department     dep_ph

   WHERE ph.policy_id = pp.policy_id
     AND ph.policy_header_id = a.policy_header_id(+)
     AND ph.policy_header_id = a_cur.policy_header_id(+)
     AND ph.agency_id = dep_ph.department_id
     AND ds.doc_status_id = pp.doc_status_id
     AND pp.doc_status_ref_id = dsr.doc_status_ref_id
     AND (nvl(ph.dep_name, a.dep_name) IN --('Нижний Новгород', 'Нижний Новгород Подразделение 3', 'Нижний Новгород Подразделение 4', 'Нижний Новгород 2', 'Нижний Новгород-2', 'Нижний Новгород-5 SAS')
         (SELECT r.param_value
             FROM ins_dwh.rep_param r
            WHERE r.rep_name = 'under_rep'
              AND r.param_name = 'AGENCY')

         OR (to_char((SELECT to_char(r.param_value)
                        FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'under_rep'
                         AND r.param_name = 'AGENCY'
                         AND r.param_value = ' <Все>')) = ' <Все>'))

  )
SELECT

 "Агентство"
 ,"ФИО Рук"
 ,"Агент по ДС"
 ,"Серия ДС"
 ,"Номер ДС"
 ,"Продукт"
 ,"Дата начала ДС"
 ,"Страхователь"
 ,"Дата акцепта ДС"
 ,"Дата акцепта Год"
 ,"Дата акцепта Месяц"
 ,"Текщий статус"
 ,"Статус последней версии"
 ,"Шаг процесса"
 ,nvl("Ответственный", 'нет ответственного') "Ответственный"
 ,"Дата присвоения статуса"
 ,"Длительность"
 ,"Плановая длит."
 ,"Отклонение"
 ,"ИДС"
 ,policy_header_id
 ,"Статус 1 ЭПГ"
 ,"Вид расчета"
 ,user_name
 ,"дней от пред. до тек. статуса"
 ,"мин дата статуса ДП или Д"
 ,trunc("мин дата статуса ДП или Д", 'dd') - "Дата акцепта ДС" "Дней от акцепта до ДП или Д"
 ,CASE
   WHEN "мин дата статуса ДП или Д" IS NULL THEN
    'not issued'
   WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 8 THEN
    'до 7'
   WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 15 THEN
    'до 14'
   WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 22 THEN
    'до 21'
   WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 29 THEN
    'до 28'
   ELSE
    'дольше'
 END "Группа"
 ,"Групповой ДС"
 ,"Действующий агент"
 ,"Уровень риска Страхователя"
 ,"Уровень риска Агента по ДС"
 ,"Уровень риска Действ агента"
 ,"Технические работы"
  FROM qmain
 ORDER BY 1
         ,2
         ,5
         ,8
;
