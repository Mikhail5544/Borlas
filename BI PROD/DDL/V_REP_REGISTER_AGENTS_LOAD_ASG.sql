CREATE OR REPLACE VIEW V_REP_REGISTER_AGENTS_LOAD_ASG AS
WITH main AS
 (SELECT 4              "Код Страховой Компании"
         ,d_ach.num      "Номер действующего АД"
         ,ach.date_begin "Дата заключения АД"
         ,1              "Тип страхового посредника"
         ,NULL           "Полное наим брокера"
         ,NULL           "Сокр наим брокера"
         ,NULL           "Юр адр брокера"
         ,NULL           "ОГРН брокера"
         ,NULL           "ИНН посредника"
         ,NULL           "Сведения о руководителе"
         ,NULL           "Свед о размере фонда"
         
         ,cn.first_name  "Имя"
         ,cn.middle_name "Отчество"
         ,cn.name        "Фамилия"
         ,NULL           "ХешСНИЛС"
         ,NULL           "Организация получ свид-ва"
         ,NULL           "Номер Свидетельства"
         ,NULL           "Дата срока свид-ва"
         
         ,nvl(rpad(substr(ad.code, 1, 2), 13, '0')
            ,(SELECT tk.code
               FROM ins.t_kladr tk
              WHERE tk.code LIKE '__00000000000'
                AND tk.name = ad.province_name)) "Территория работы агента"
         ,CASE
           WHEN dsr_ach.brief = 'CURRENT' THEN
            10
           ELSE
            1
         END "Код статуса Агента"
         ,'Все продукты страхования жизни' "Продукты"
         
         ,NULL "Адрес офиса"
         ,NULL "Конт телефон офиса"
         
         ,aca.category_name         "Категория САД"
         ,dsr_ach.name              "Cтатус договора"
         ,sc.description            "Канал продаж"
         ,ach.ag_contract_header_id
    FROM ins.ag_contract        ac
        ,ins.department         dep
        ,ins.organisation_tree  ot
        ,ins.sales_dept_header  sdh
        ,ins.sales_dept         sd
        ,ins.t_tap_header       th
        ,ins.t_tap              tp
        ,ins.ag_contract_header ach
        ,ins.document           d_ach
        ,ins.doc_status_ref     dsr_ach
        ,ins.contact            cn
         
        ,ins.t_sales_channel   sc
        ,ins.ag_category_agent aca
         
        ,ins.ven_cn_entity_address ea
        ,ins.cn_address            ad
  
   WHERE dep.department_id = ac.agency_id
     AND ot.organisation_tree_id = dep.org_tree_id
     AND sdh.organisation_tree_id = ot.organisation_tree_id
     AND sd.sales_dept_id = sdh.last_sales_dept_id
     AND th.t_tap_header_id = sd.t_tap_header_id
     AND tp.t_tap_header_id = th.last_tap_id
     AND ach.last_ver_id = ac.ag_contract_id
     AND cn.contact_id = ach.agent_id
     AND ac.category_id = aca.ag_category_agent_id
        
     AND ach.ag_contract_header_id = d_ach.document_id
     AND dsr_ach.doc_status_ref_id = d_ach.doc_status_ref_id
     AND dsr_ach.brief in ('CURRENT', 'BREAK')
     AND ac.ag_sales_chn_id = sc.id
     AND ach.is_new = 1
        
     AND sd.ent_id = ea.ure_id
     AND sd.sales_dept_id = ea.uro_id
     AND ea.address_id = ad.id
  
  ),
doc_info AS
 (SELECT MAX(dsr_agd_.name) keep(dense_rank FIRST ORDER BY agd_.doc_date DESC NULLS LAST, ds_agd_.start_date DESC NULLS LAST) doc_status_name
        ,MAX(dsr_agd_.brief) keep(dense_rank FIRST ORDER BY agd_.doc_date DESC NULLS LAST, ds_agd_.start_date DESC NULLS LAST) doc_status_brief
        ,MAX(adt_.description) keep(dense_rank FIRST ORDER BY agd_.doc_date DESC NULLS LAST, ds_agd_.start_date DESC NULLS LAST) doc_desc
        ,m_.ag_contract_header_id
    FROM ins.ag_documents   agd_
        ,ins.document       d_agd_
        ,ins.doc_status_ref dsr_agd_
        ,ins.ag_doc_type    adt_
        ,ins.main           m_
        ,ins.doc_status     ds_agd_
   WHERE agd_.ag_contract_header_id = m_.ag_contract_header_id
     AND agd_.ag_documents_id = d_agd_.document_id
     AND ds_agd_.doc_status_id = d_agd_.doc_status_id
     AND dsr_agd_.doc_status_ref_id = d_agd_.doc_status_ref_id
     AND adt_.ag_doc_type_id = agd_.ag_doc_type_id
     AND adt_.brief IN ('NEW_AD', 'CAT_CHG')
   GROUP BY m_.ag_contract_header_id)
SELECT mm.*
      ,di.doc_status_name "Статус документа"
       ,di.doc_desc        "Документ"
  FROM main     mm
      ,doc_info di
 WHERE mm.ag_contract_header_id = di.ag_contract_header_id
   AND di.doc_status_brief IN ('CO_ACHIVE', 'CO_ACCEPTED', 'DEFICIENCY');
   
grant select on V_REP_REGISTER_AGENTS_LOAD_ASG to ins_read;
grant select on V_REP_REGISTER_AGENTS_LOAD_ASG to ins_eul;   



