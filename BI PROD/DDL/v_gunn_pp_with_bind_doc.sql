CREATE OR REPLACE FORCE VIEW V_GUNN_PP_WITH_BIND_DOC AS
SELECT DISTINCT "����� ���������","����� ��������","ID ��","���� ������ ��","���� ��. ���. ���.","���� ������� � ���.","������ ������ ������","���� ������� ������ ������","������ ������� ������","���� ������� ������� ������","������������ ������� ������","���������� ������������","������" FROM (
SELECT
        pp.Notice_Num                               "����� ���������"
        ,pp.pol_num                                 "����� ��������"
        ,ph.policy_header_id                        "ID ��"
        ,TRUNC(ph.start_date, 'dd')                 "���� ������ ��"
        ,TRUNC(ph.start_date+60, 'dd')              "���� ��. ���. ���."-- = ���� ������ + 60 ����"
        ,TRUNC(pp.sign_date, 'dd')            "���� ������� � ���."
        ,doc.get_doc_status_name(  (SELECT pp2.policy_id
                                    FROM p_policy pp2
                                    WHERE pp2.pol_header_id = pp.pol_header_id
                                    AND pp2.version_num = 1))                                           "������ ������ ������"
        ,(  SELECT trunc(ds.change_date, 'dd')
            FROM doc_status ds
            WHERE ds.doc_status_id = doc.get_doc_status_rec_id((SELECT pp2.policy_id
                                                                FROM p_policy pp2
                                                                WHERE pp2.pol_header_id = pp.pol_header_id
                                                                AND pp2.version_num = 1)))                          "���� ������� ������ ������"
        ,doc.get_doc_status_name(pp.policy_id)                                                                      "������ ������� ������"
        ,(SELECT trunc(ds.change_date, 'dd') FROM doc_status ds WHERE ds.doc_status_id = doc.get_doc_status_rec_id(pp.policy_id))   "���� ������� ������� ������"
        ,(SELECT ds.user_name FROM doc_status ds WHERE ds.doc_status_id = doc.get_doc_status_rec_id(pp.policy_id))                  "������������ ������� ������"
        ,aau.underwriting_note                                                                                      "���������� ������������"

        ,dep.name                                   "������"
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
AND     aa1.as_asset_id             =   sf.parent_uro_id--������ � ������������ �������
AND     doc.get_doc_status_name(pp.policy_id) NOT IN  ('��������', '�������', '����������')
AND     pp.policy_id                =   aa.p_policy_id(+)
AND     aa.as_asset_id              =   aas.as_assured_id(+)
AND     aas.as_assured_id           =   aau.as_assured_id(+)
)
WHERE "������ ������ ������" <> "������ ������� ������"
;

