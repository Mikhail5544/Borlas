CREATE OR REPLACE FORCE VIEW V_25775_AG_PAUSED_WITH_KP AS
SELECT
        dep.NAME                                    "���������"
        ,dc.num                                     "����� ��"
        ,cn_ag.obj_name_orig                        "��� ������"
        ,aca.category_name                          "���������"
        ,doc.get_doc_status_name(ach.last_ver_id)   "������ ��"
        ,CASE   WHEN EXISTS  (SELECT  1
                              FROM    p_policy_agent  ppa
                                      ,p_pol_header   ph
                              WHERE   ach.ag_contract_header_id   =   ppa.ag_contract_header_id
                              AND     ppa.policy_header_id        =   ph.policy_header_id
                              AND     ppa.status_id               =   1)
                THEN '���� ����������� ��������' ELSE '��� ����������� ���������' END   "�������"
--"���� ���������� ��������"
FROM
        department              dep
        ,ag_contract_header     ach
        ,document               dc
        ,contact                cn_ag
        ,ag_category_agent      aca
        ,ag_contract            ac
WHERE
        ach.ag_contract_header_id   =   dc.document_id
AND     ach.agency_id               =   dep.department_id
AND     ach.agent_id                =   cn_ag.contact_id
AND     ach.last_ver_id             =   ac.ag_contract_id
AND     ac.category_id              =   aca.ag_category_agent_id
AND     doc.get_doc_status_name(ach.last_ver_id)    =   '�������������'
;

