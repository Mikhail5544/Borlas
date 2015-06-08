CREATE OR REPLACE VIEW INS.V_28724_REP_AGENTS_REGION AS
select * from
(
SELECT   dep.NAME                                    "Регион"
        ,(  SELECT  min(ds.user_name)
            FROM    doc_status      ds
            WHERE   ds.document_id          =   agd.ag_documents_id
            AND     ds.doc_status_ref_id    =   16)  "Login сотрудника"
        ,dc_ach.num                                 "Номер АД"
        ,cn_ag.obj_name_orig                        "ФИО Агента"
        ,(  SELECT  MIN(TRUNC(ds.change_date, 'dd'))
            FROM    doc_status      ds
            WHERE   ds.document_id          =   agd.ag_documents_id
            AND     ds.doc_status_ref_id    =   16)  "Дата статуса 'Новый' АД"
        ,(  SELECT  MIN(TRUNC(ds.change_date, 'dd'))
            FROM    doc_status      ds
            WHERE   ds.document_id          =   agd.ag_documents_id
            AND     ds.doc_status_ref_id    =   20) "Дата статуса 'Напечатан' АД"
FROM
        department              dep
        ,ag_contract_header     ach
        ,document               dc_ach
        ,ag_contract            ac
        ,document               dc_ac
        , ins.ag_documents agd
        , ins.ag_doc_type dt
        ,contact                cn_ag
WHERE
        ach.agency_id               =   dep.department_id--(+)
AND     ach.ag_contract_header_id   =   dc_ach.document_id
AND     ach.ag_contract_header_id   =   ac.contract_id
AND     ach.agent_id                =   cn_ag.contact_id--(+)
AND     ac.ag_contract_id           =   dc_ac.document_id
and ach.is_new = 1
and ac.ag_documents_id = agd.ag_documents_id
and agd.ag_doc_type_id = dt.ag_doc_type_id
and dt.brief = 'NEW_AD'
union all
SELECT
        dep.NAME                                    "Регион"
        ,(  SELECT  ds.user_name
            FROM    doc_status      ds
            WHERE   ds.document_id          =   dc_ac.document_id
            AND     ds.doc_status_ref_id    =   1)  "Login сотрудника"
        ,dc_ach.num                                 "Номер АД"
        ,cn_ag.obj_name_orig                        "ФИО Агента"
        ,(  SELECT  MIN(TRUNC(ds.change_date, 'dd'))
            FROM    doc_status      ds
            WHERE   ds.document_id          =   dc_ac.document_id
            AND     ds.doc_status_ref_id    =   1)  "Дата статуса 'Новый' АД"
        ,(  SELECT  MIN(TRUNC(ds.change_date, 'dd'))
            FROM    doc_status      ds
            WHERE   ds.document_id          =   dc_ac.document_id
            AND     ds.doc_status_ref_id    =   20) "Дата статуса 'Напечатан' АД"
FROM
        department              dep
        ,ag_contract_header     ach
        ,document               dc_ach
        ,ag_contract            ac
        ,document               dc_ac
        ,contact                cn_ag
WHERE
        ach.agency_id               =   dep.department_id--(+)
AND     ach.ag_contract_header_id   =   dc_ach.document_id
AND     ach.ag_contract_header_id   =   ac.contract_id
AND     ach.agent_id                =   cn_ag.contact_id--(+)
AND     ac.ag_contract_id           =   dc_ac.document_id
and nvl(ach.is_new,0) = 0
AND     dc_ac.num                   =   '0')
--where st_new between to_date('03-04-2010','dd-mm-yyyy') and to_date('02-07-2010','dd-mm-yyyy') 