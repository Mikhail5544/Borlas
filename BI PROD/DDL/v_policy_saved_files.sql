CREATE OR REPLACE FORCE VIEW V_POLICY_SAVED_FILES AS
SELECT
        pp.Notice_Num                               "Номер заявления"
        ,pp.pol_num                                 "Номер договора"
        ,ph.policy_header_id                        "ID ДС"
        ,TRUNC(ph.start_date, 'dd')                 "Дата начала ДС"
        ,dep.name                                   "Филиал"
        ,TRUNC(ph.start_date+60, 'dd')              "Дата ок. выж. пер."-- = Дата начала + 60 дней""
        ,nvl(sf.file_origin_name,'-')                        "Хранимые файлы 1"-- (могут не быть)""
        ,nvl(sf.file_stored_name,'-')                        "Хранимые файлы 2"
        ,cn_insurer.obj_name_orig                   "ФИО Страхователя"
        ,cn_insured.obj_name_orig                   "ФИО застрахованного"-- (исключить групповые)""
        ,cn_ag.obj_name_orig                        "Агент (продавший)",
        pp.version_num "Номер версии",
        doc.get_doc_status_name(ph.policy_id) "Статус активной версии",
        cn_insurer.obj_name_orig "Страхователь"

FROM
        p_policy                pp
        ,p_pol_header           ph
        ,ag_contract_header     ach
        ,department             dep
        ,as_asset               aa1
        ,as_assured             aa2
        ,stored_files           sf
        ,contact                cn_insurer
        ,contact                cn_insured
        ,contact                cn_ag
WHERE
        ph.policy_id                =   pp.policy_id
AND     ach.ag_contract_header_id   =   pkg_renlife_utils.get_p_agent_sale(ph.policy_header_id)
AND     ach.agency_id               =   dep.department_id
AND     pp.policy_id                =   aa1.p_policy_id
AND     aa1.As_Asset_Id             =   aa2.as_assured_id
AND     aa1.as_asset_id             =   sf.parent_uro_id(+)
AND     cn_insurer.contact_id       =   pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь')
AND     cn_insured.contact_id       =   aa2.Assured_Contact_Id
AND     cn_ag.contact_id            =   ach.agent_id
--AND     doc.get_doc_status_name(ph.policy_id)   =   'Новый'
AND     pp.is_group_flag            =   0
--and ph.start_date between '26.06.2009' and '31.07.2009'
/*AND     ph.policy_id                =   ppc.policy_id
AND     ppc.contact_id              =   cn_insured.contact_id
AND     ppc.contact_policy_role_id  =   1--застрахованное лицо*/
;

