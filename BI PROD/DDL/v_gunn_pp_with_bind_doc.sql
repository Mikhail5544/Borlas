CREATE OR REPLACE FORCE VIEW V_GUNN_PP_WITH_BIND_DOC AS
SELECT DISTINCT "Номер заявления","Номер договора","ID ДС","Дата начала ДС","Дата ок. выж. пер.","Дата акцепта в рег.","Статус первой версии","Дата статуса первой версии","Статус текущей версии","Дата статуса текущей версии","Пользователь текущей версии","Заключение андеррайтера","Филиал" FROM (
SELECT
        pp.Notice_Num                               "Номер заявления"
        ,pp.pol_num                                 "Номер договора"
        ,ph.policy_header_id                        "ID ДС"
        ,TRUNC(ph.start_date, 'dd')                 "Дата начала ДС"
        ,TRUNC(ph.start_date+60, 'dd')              "Дата ок. выж. пер."-- = Дата начала + 60 дней"
        ,TRUNC(pp.sign_date, 'dd')            "Дата акцепта в рег."
        ,doc.get_doc_status_name(  (SELECT pp2.policy_id
                                    FROM p_policy pp2
                                    WHERE pp2.pol_header_id = pp.pol_header_id
                                    AND pp2.version_num = 1))                                           "Статус первой версии"
        ,(  SELECT trunc(ds.change_date, 'dd')
            FROM doc_status ds
            WHERE ds.doc_status_id = doc.get_doc_status_rec_id((SELECT pp2.policy_id
                                                                FROM p_policy pp2
                                                                WHERE pp2.pol_header_id = pp.pol_header_id
                                                                AND pp2.version_num = 1)))                          "Дата статуса первой версии"
        ,doc.get_doc_status_name(pp.policy_id)                                                                      "Статус текущей версии"
        ,(SELECT trunc(ds.change_date, 'dd') FROM doc_status ds WHERE ds.doc_status_id = doc.get_doc_status_rec_id(pp.policy_id))   "Дата статуса текущей версии"
        ,(SELECT ds.user_name FROM doc_status ds WHERE ds.doc_status_id = doc.get_doc_status_rec_id(pp.policy_id))                  "Пользователь текущей версии"
        ,aau.underwriting_note                                                                                      "Заключение андеррайтера"

        ,dep.name                                   "Филиал"
FROM
        p_policy                pp
        ,p_pol_header           ph
        ,ag_contract_header     ach
        ,department             dep
        ,as_asset               aa1
        ,as_assured             aa2
        ,stored_files           sf
        ,as_asset               aa
        ,as_assured             aas
        ,as_assured_underwr     aau
WHERE
        ph.policy_id                =   pp.policy_id
AND     ach.ag_contract_header_id   =   pkg_renlife_utils.get_p_agent_sale(ph.policy_header_id)
AND     ach.agency_id               =   dep.department_id
AND     pp.policy_id                =   aa1.p_policy_id
AND     aa1.As_Asset_Id             =   aa2.as_assured_id
AND     aa1.as_asset_id             =   sf.parent_uro_id--только с привязанными файлами
AND     doc.get_doc_status_name(pp.policy_id) NOT IN  ('Завершен', 'Отменен', 'Расторгнут')
AND     pp.policy_id                =   aa.p_policy_id(+)
AND     aa.as_asset_id              =   aas.as_assured_id(+)
AND     aas.as_assured_id           =   aau.as_assured_id(+)
)
WHERE "Статус первой версии" <> "Статус текущей версии"
;

