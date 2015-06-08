CREATE OR REPLACE VIEW V_REKRUIT_SAD_REP AS
--Хранится не в ОС отчетности, а в Выгрузках
SELECT ach.num "Номер субагента"
       ,c2.obj_name_orig "ФИО субагента"
       ,to_char(ach.date_begin, 'dd.mm.yyyy') "Дата начала действия договора"
       ,d.name "Агентство субагента"
       ,aca.category_name "Категория субагента"
       ,doc.get_doc_status_name(ach.ag_contract_header_id
                              ,to_date((SELECT param_value
                                         FROM ins_dwh.rep_param
                                        WHERE rep_name = 'sub_agent_report'
                                          AND param_name = 'start_date')
                                      ,'dd.mm.yyyy')) "Статус субагента"
       ,req_info.num "Номер рекрутера"
       ,req_info.obj_name_orig "ФИО рекрутера"
       ,to_char(req_info.date_begin, 'dd.mm.yyyy') "Дата начала действия рекрутера"
       ,req_info.name "Агентство рекрутера"
       ,req_info.category_name "Категория рекрутера"
       ,doc.get_doc_status_name(req_info.ag_contract_header_id
                              ,to_date((SELECT param_value
                                         FROM ins_dwh.rep_param
                                        WHERE rep_name = 'sub_agent_report'
                                          AND param_name = 'start_date')
                                      ,'dd.mm.yyyy')) "Статус рекрутера"
  FROM ven_ag_contract_header ach
      ,contact c
      ,ag_contract ac
      ,contact c2
      ,department d
      ,ag_category_agent aca
      ,(SELECT ac1.ag_contract_id
              ,ach1.ag_contract_header_id
              ,ach1.num /*ID рекрутера*/
              ,c.obj_name_orig /*ФИО рекрутера Субагента*/
              ,ach1.date_begin /*Дата начала действия САД рекрутера*/
              ,d1.name /*агентство рекрутера*/
              ,aca1.category_name /*Категория ректурета*/
          FROM ag_contract            ac1
              ,ag_contract            ac2
              ,ven_ag_contract_header ach1
              ,contact                c
              ,ag_category_agent      aca1
              ,department             d1
         WHERE ac1.contract_id = ach1.ag_contract_header_id
           AND c.contact_id = ach1.agent_id
           AND aca1.ag_category_agent_id = ac2.category_id
           AND d1.department_id = ac2.agency_id
           AND ac2.contract_id = ach1.ag_contract_header_id
           AND to_date((SELECT param_value
                         FROM ins_dwh.rep_param
                        WHERE rep_name = 'sub_agent_report'
                          AND param_name = 'start_date')
                      ,'dd.mm.yyyy') BETWEEN ac2.date_begin AND ac2.date_end
        
        ) req_info
 WHERE c.contact_id = ach.agent_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND ach.is_new = 1
   AND to_date((SELECT param_value
                 FROM ins_dwh.rep_param
                WHERE rep_name = 'sub_agent_report'
                  AND param_name = 'start_date')
              ,'dd.mm.yyyy') BETWEEN ac.date_begin AND ac.date_end
   AND c2.contact_id = ach.agent_id
   AND d.department_id = ac.agency_id
   AND aca.ag_category_agent_id = ac.category_id
   AND req_info.ag_contract_id = ac.contract_recrut_id
   --AND ach.num IN ('53663', '28922')
 ORDER BY ach.num;