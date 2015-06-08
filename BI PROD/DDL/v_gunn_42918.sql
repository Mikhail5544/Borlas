CREATE OR REPLACE FORCE VIEW V_GUNN_42918 AS
SELECT
        ach.ag_contract_header_id                                           "ID ��"
        ,d.num                                                              "� ��"
        ,cn.obj_name_orig                                                   "��� ������"
        ,doc.get_doc_status_name(ach.ag_contract_header_id, SYSDATE)        "������ ��"
        ,aca.category_name                                                  "��������� ������"
        ,dep.name                                                           "���������"
        ,TRUNC(ach.date_begin, 'dd')                                        "���� ������ ��"
        ,tsc.description                                                    "����� ������"
FROM
        ag_contract_header  ach
        ,ag_contract        ac
        ,contact            cn
        ,document           d
        ,department         dep
        ,ag_category_agent  aca
        ,t_sales_channel    tsc
WHERE
--� ��
        ach.ag_contract_header_id   =   d.document_id
--�������� �������
AND     ach.last_ver_id             =   ac.ag_contract_id
--��� ������
AND     ach.agent_id                =   cn.contact_id
--���������
AND     ach.agency_id               =   dep.department_id
--��������� ������ = �����
AND     ac.category_id              =   2
--������������ ������� ��
AND     doc.get_doc_status_name(ach.ag_contract_header_id, SYSDATE) IN ('���������')
--��������� ����� ������
AND     ach.t_sales_channel_id      =   tsc.id
--��������� ������
AND     aca.ag_category_agent_id    =   ac.category_id
;

