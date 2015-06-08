CREATE OR REPLACE FORCE VIEW V_24631_PP_W_EMPTY_CNADDR AS
SELECT
        ph.policy_header_id         "ID ��"
        ,pp.pol_ser                 "����� ��"
        ,pp.pol_num                 "����� ��������"
        ,pp.Notice_Ser              "����� ���������"
        ,pp.notice_num              "����� ���������"
        ,TRUNC(ph.start_date, 'dd') "���� ������ ��"
        ,cn_ins.obj_name_orig       "��� ������������"
        ,dep.NAME                   "������"
FROM
        p_policy                    pp
        ,p_pol_header               ph
        ,contact                    cn_ins
        ,ag_contract_header         ach
        ,department                 dep
        ,v_cn_contact_address       vcca
WHERE
        ph.policy_id                =   pp.policy_id
AND     cn_ins.contact_id           =   pkg_policy.get_policy_contact(pp.policy_id, '������������')
AND     ach.ag_contract_header_id   =   pkg_renlife_utils.get_p_agent_sale(ph.policy_header_id)
AND     ach.agency_id               =   dep.department_id
AND     cn_ins.contact_id           =   vcca.contact_id(+)
AND     TRANSLATE(vcca.address_name, 'x ', 'x') IS NULL
--AND     REPLACE(vcca.address_name, ' ', '') IS NULL
;

