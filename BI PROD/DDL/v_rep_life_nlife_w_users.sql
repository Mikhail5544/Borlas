CREATE OR REPLACE FORCE VIEW V_REP_LIFE_NLIFE_W_USERS AS
SELECT  agency_name     "Агентство"
        ,login          "Логин сотрудника"
        ,SUM(life)      "Жизнь"
        ,SUM(notlife)   "НеЖизнь"
        ,(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'l_nl_w_un' and param_name = 'begin_date')    "Дата с"
        ,(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'l_nl_w_un' and param_name = 'end_date')      "Дата по"
FROM (
SELECT
        ot.NAME||' - '||dep.NAME    agency_name
        ,ach.ag_contract_header_id
        ,ph.policy_header_id
        ,tp.DESCRIPTION
        ,CASE   WHEN tp.DESCRIPTION IN ('Гармония жизни','Будущее','Семья','Дети','Семейный депозит','Семья (Старая версия)','Гармония жизни (Старая версия)','Дети (Старая версия)','Будущее (Старая версия)','Софинансирование +')
                THEN 1 ELSE 0 END   life
        ,CASE   WHEN tp.DESCRIPTION NOT IN ('Гармония жизни','Будущее','Семья','Дети','Семейный депозит','Семья (Старая версия)','Гармония жизни (Старая версия)','Дети (Старая версия)','Будущее (Старая версия)','Софинансирование +')
                THEN 1 ELSE 0 END   notlife
        ,ds.user_name               login
FROM
        organisation_tree   ot
        ,department         dep
        ,ag_contract_header ach
        ,p_pol_header       ph
        ,t_product          tp
        ,p_policy           pp
        ,doc_status         ds
WHERE
        ot.organisation_tree_id     =   dep.org_tree_id(+)
AND     dep.department_id           =   ach.agency_id(+)
AND     ach.ag_contract_header_id   =   pkg_renlife_utils.get_p_agent_sale(ph.policy_header_id)
AND     ph.product_id               =   tp.product_id
AND     ph.policy_header_id         =   pp.pol_header_id
AND     pp.version_num              =   1
AND     pp.policy_id                =   ds.document_id
AND     ds.doc_status_id            =   (
                                        SELECT  a.doc_status_id
                                        FROM    (
                                                SELECT      ds2.doc_status_id
                                                            ,ds2.document_id
                                                FROM        doc_status ds2
                                                ORDER BY    ds2.change_date ASC
                                                )   a
                                                ,doc_status ds3
                                        WHERE   ds3.document_id = a.document_id
                                          AND   ds3.document_id = ds.document_id
                                          AND   ROWNUM  = 1
                                     )
AND     ds.change_date between  (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'l_nl_w_un' and param_name = 'begin_date')
                       and      (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'l_nl_w_un' and param_name = 'end_date')
)
GROUP BY agency_name, login
ORDER BY agency_name, login;

