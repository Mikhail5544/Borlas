CREATE OR REPLACE FORCE VIEW V_GUNN_42918 AS
SELECT
        ach.ag_contract_header_id                                           "ID АД"
        ,d.num                                                              "№ АД"
        ,cn.obj_name_orig                                                   "ФИО агента"
        ,doc.get_doc_status_name(ach.ag_contract_header_id, SYSDATE)        "Статус АД"
        ,aca.category_name                                                  "Категория агента"
        ,dep.name                                                           "Агентство"
        ,TRUNC(ach.date_begin, 'dd')                                        "Дата начала АД"
        ,tsc.description                                                    "Канал продаж"
FROM
        ag_contract_header  ach
        ,ag_contract        ac
        ,contact            cn
        ,document           d
        ,department         dep
        ,ag_category_agent  aca
        ,t_sales_channel    tsc
WHERE
--№ АД
        ach.ag_contract_header_id   =   d.document_id
--активная вверсия
AND     ach.last_ver_id             =   ac.ag_contract_id
--ФИО Агента
AND     ach.agent_id                =   cn.contact_id
--Агентство
AND     ach.agency_id               =   dep.department_id
--категория агента = агент
AND     ac.category_id              =   2
--ограничиваем статусы АД
AND     doc.get_doc_status_name(ach.ag_contract_header_id, SYSDATE) IN ('Напечатан')
--агентский канал продаж
AND     ach.t_sales_channel_id      =   tsc.id
--категория агента
AND     aca.ag_category_agent_id    =   ac.category_id
;

