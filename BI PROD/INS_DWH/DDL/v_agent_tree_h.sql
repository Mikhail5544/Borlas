CREATE OR REPLACE FORCE VIEW INS_DWH.V_AGENT_TREE_H AS
SELECT "MAX_LVL","LVL","CONTRACT_ID","������ ������� ��","����� ��","���","���������","������ ������","������ ��������","��������"
FROM (
 SELECT MAX(a.Lvl) over (PARTITION BY contract_id) max_lvl, a.*
 FROM (
 SELECT LEVEL lvl,
        CONNECT_BY_ROOT(ac.contract_id) contract_id,

        CONNECT_BY_ROOT(ins.doc.get_doc_status_name(ac.ag_contract_id)) "������ ������� ��",

        SYS_CONNECT_BY_PATH(
        (SELECT num FROM ins.ven_ag_contract_header v WHERE v.ag_contract_header_id = ac.contract_id), ' -> ') "����� ��",

        SYS_CONNECT_BY_PATH(
        (ins.pkg_renlife_utils.get_fio_by_ag_contract_id(ac.ag_contract_id)), ' -> ') "���",

        SYS_CONNECT_BY_PATH(
        decode(ac.category_id, 4, '���', 3, '���', 2, '�����', 1, '��� ���.', '����������'), ' -> ') "���������",

        SYS_CONNECT_BY_PATH(
        nvl(ins.pkg_renlife_utils.get_ag_stat_brief(ac.contract_id),'���'), ' -> ') "������ ������",

        SYS_CONNECT_BY_PATH(
        nvl(ins.doc.get_doc_status_name(ac.ag_contract_id),'����������') , ' -> ') "������ ��������",

        SYS_CONNECT_BY_PATH(
        nvl(ins.ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),ac.agency_id),'����������'), ' -> ') "��������"

   FROM ins.ven_ag_contract ac
  START WITH AC.ag_contract_id =  ins.pkg_agent_1.get_status_by_date(AC.contract_id, SYSDATE)
         AND (ac.category_id = 1
             OR (ac.category_id = 2 AND NOT EXISTS
               (SELECT 1
                  FROM ins.ag_contract a
                 WHERE a.ag_contract_id = ins.pkg_agent_1.get_status_by_date(A.contract_id, SYSDATE)
                   AND ins.doc.get_doc_status_name(a.ag_contract_id) NOT IN ('�������','������','����������','��������� � �����������')
                   AND a.contract_leader_id IN (SELECT a1.ag_contract_id FROM ins.ag_contract a1 WHERE a1.contract_id = ac.contract_id)))
             OR (ac.category_id = 3 AND NOT EXISTS
               (SELECT 1
                  FROM ins.ag_contract a
                 WHERE a.ag_contract_id = ins.pkg_agent_1.get_status_by_date(A.contract_id, SYSDATE)
                   AND ins.doc.get_doc_status_name(a.ag_contract_id) NOT IN ('�������','������','����������','��������� � �����������')
                   AND a.contract_leader_id IN (SELECT a1.ag_contract_id FROM ins.ag_contract a1 WHERE a1.contract_id = ac.contract_id)))
             OR (ac.category_id = 4 AND NOT EXISTS
               (SELECT 1
                  FROM ins.ag_contract a
                 WHERE a.ag_contract_id = ins.pkg_agent_1.get_status_by_date(A.contract_id, SYSDATE)
                   AND ins.doc.get_doc_status_name(a.ag_contract_id) NOT IN ('�������','������','����������','��������� � �����������')
                   AND a.contract_leader_id IN (SELECT a1.ag_contract_id FROM ins.ag_contract a1 WHERE a1.contract_id = ac.contract_id)))
             )
CONNECT BY NOCYCLE PRIOR (SELECT c1.contract_id FROM ins.ag_contract c1 WHERE c1.ag_contract_id= ac.contract_leader_id) = ac.contract_id
                      AND ins.pkg_agent_1.get_status_by_date(ac.contract_id, SYSDATE) = ac.ag_contract_id

) a,
ins.ag_contract_header ach,
ins.t_sales_channel    sc
where ach.ag_contract_header_id = a.contract_id
  and sc.id = ach.t_sales_channel_id
  and sc.description in ('DSF','SAS')
) WHERE lvl = max_lvl
  AND "������ ������� ��" NOT IN ('�������','������','����������','��������� � �����������');

