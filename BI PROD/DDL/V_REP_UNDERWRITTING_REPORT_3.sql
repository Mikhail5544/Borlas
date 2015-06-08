CREATE OR REPLACE VIEW V_REP_UNDERWRITTING_REPORT_3 AS
SELECT rep."���������"
       ,rep."��� ���"
       ,rep."����� �� ��"
       ,rep."����� ��"
       ,rep."����� ��"
       ,rep."�������"
       ,rep."���� ������ ��"
       ,rep."������������"
       ,rep."���� ������� ��"
       ,rep."C����� �������� ������"
       ,rep."������ ��������� ������"
       ,rep."��� ��������"
       ,nvl("�������������", '��� ��������������') "�������������"
       ,rep."���� ���������� �������"
       ,trunc(SYSDATE - rep."���� ������� ��") AS "�� ���� �������, ����"
       ,trunc(SYSDATE - rep."���� ���������� �������") AS "� ������� �������, ����"
       ,trunc(rep."���� ���������� �������" - rep."���� ������� ��") AS "����� �� ��������, ����"
       ,rep."���"
       ,rep."������ 1 ���"
       ,rep."��� �������"
       ,rep.user_name
       ,CASE
         WHEN "��� ���� ������� �� ��� �" IS NULL THEN
          'not issued'
         WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 8 THEN
          '�� 7'
         WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 15 THEN
          '�� 14'
         WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 22 THEN
          '�� 21'
         WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 29 THEN
          '�� 28'
         ELSE
          '������'
       END "������"
       ,rep."����������� �����"
  FROM (SELECT ins.ent.obj_name('DEPARTMENT', a.agency_id) "���������"
               ,nvl(ins.ent.obj_name('CONTACT'
                                   ,(SELECT ach_lead.agent_id
                                      FROM ins.ag_contract_header ach_lead
                                     WHERE ach_lead.ag_contract_header_id = a.ac_lead_contract_id))
                  ,'��� ������������') "��� ���"
               ,ins.ent.obj_name('CONTACT', a.agent_id) "����� �� ��"
               ,pp.pol_ser "����� ��"
               ,pp.pol_num "����� ��"
               ,tp.description "�������"
               ,ph.start_date "���� ������ ��"
               ,ins.ent.obj_name('CONTACT'
                               ,ins.pkg_policy.get_policy_contact(pp.policy_id
                                                                 ,'������������')) "������������"
               ,trunc(pp.sign_date, 'dd') "���� ������� ��"
               ,dsr.name "C����� �������� ������"
               ,ins.pkg_policy.get_last_version_status(ph.policy_header_id) "������ ��������� ������"
               ,(SELECT da.note
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "��� ��������"
               ,(SELECT da.respons_pers
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "�������������"
               ,ds.change_date "���� ���������� �������"
               ,ph.ids "���"
               ,ph.policy_header_id
               ,(SELECT MIN(ins.doc.get_doc_status_name(ap.payment_id)) keep(dense_rank FIRST ORDER BY plan_date DESC)
                  FROM ins.p_policy       p2
                      ,ins.ven_ac_payment ap
                      ,ins.document       d
                      ,ins.doc_templ      dt
                      ,ins.doc_doc        dd
                 WHERE dd.parent_id = p2.policy_id
                   AND d.document_id = dd.child_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ap.payment_id = dd.child_id
                   AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                   AND p2.pol_header_id = ph.policy_header_id) "������ 1 ���"
               ,(SELECT cm.description
                  FROM ins.t_collection_method cm
                 WHERE cm.id = pp.collection_method_id) "��� �������"
               ,ds.user_name
               ,(SELECT MIN(ds2.change_date)
                  FROM ins.p_policy       p2
                      ,ins.doc_status     ds2
                      ,ins.doc_status_ref dsr2
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND ds2.document_id = p2.policy_id
                   AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
                   AND dsr2.brief IN ('CONCLUDED', 'CURRENT')) "��� ���� ������� �� ��� �"
               ,ag_cur.agent_current "����������� �����"
          FROM ins.p_pol_header ph
              ,ins.ven_p_policy pp
              ,ins.document doc
              ,ins.t_product tp
              ,ins.doc_status ds
              ,ins.doc_status_ref dsr
              ,(SELECT ph.policy_header_id
                      ,ach.agent_id
                      ,ach.agency_id
                      ,ac_lead.contract_id       ac_lead_contract_id
                      ,dep.name                  dep_name
                      ,ach.is_new
                      ,ach.ag_contract_header_id
                  FROM ins.p_pol_header       ph
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                      ,ins.ag_contract        ac_lead
                      ,ins.department         dep
                 WHERE ach.ag_contract_header_id =
                       ins.pkg_renlife_utils.get_p_agent_sale_new(ph.policy_header_id)
                   AND ach.agency_id = dep.department_id
                   AND ach.last_ver_id = ac.ag_contract_id
                   AND ac.contract_leader_id = ac_lead.ag_contract_id(+)) a
              ,
               
               (SELECT ph.policy_header_id
                      ,ach.agent_id
                      ,ach.agency_id
                      ,ach.t_sales_channel_id
                      ,cagc.obj_name_orig agent_current
                  FROM ins.p_pol_header           ph
                      ,ins.ven_ag_contract_header ach
                      ,ins.contact                cagc
                 WHERE ach.ag_contract_header_id =
                       ins.pkg_renlife_utils.get_p_agent_current_new(ph.policy_header_id)
                   AND cagc.contact_id = ach.agent_id) ag_cur
         WHERE ph.policy_id = pp.policy_id
           AND pp.policy_id = doc.document_id
           AND tp.product_id = ph.product_id
           AND a.policy_header_id = ph.policy_header_id
           AND doc.doc_status_id = ds.doc_status_id
           AND ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'CONCLUDED'
           AND ph.policy_header_id = ag_cur.policy_header_id(+)
           AND tp.brief NOT LIKE 'CR92%'
           AND tp.brief NOT LIKE '%RenCap%'
           AND a.dep_name NOT IN (' ����� ������-�������'
                                 ,'Call center'
                                 ,'�����'
                                 ,'��������� RLA'
                                 ,'���������������� ����������'
                                 ,'���������������-�������������  �����'
                                 ,'������� GRS'
                                 ,'������� GRS-1'
                                 ,'�����������'
                                 ,'�������� GRS'
                                 ,'������� ������ � ���������'
                                 ,'��������� GRS'
                                 ,'������� GRS'
                                 ,'��� � �. �����-���������'
                                 ,'��� ����� ������������ �������� �. �����-���������'
                                 ,'����������� ������������� ������'
                                 ,'����������� ����������, PR � �������'
                                 ,'����������� �� ������������� ��������'
                                 ,'����������� �� �������� ����� ����� � ��������'
                                 ,'������������ GRS'
                                 ,'������������ ��� ���'
                                 ,'������� GRS'
                                 ,'����� GRS'
                                 ,'������ GRS'
                                 ,'������ GRS-2'
                                 ,'��������� GRS'
                                 ,'�������� GRS'
                                 ,'����-�����'
                                 ,'������������ ����������'
                                 ,'������� ����� 1'
                                 ,'������� GRS'
                                 ,'���������� GRS'
                                 ,'���������� GRS ������-1'
                                 ,'���������� GRS-1'
                                 ,'������ GRS'
                                 ,'������ ��'
                                 ,'������-1 GRS'
                                 ,'������-1 GRS-1'
                                 ,'������-1 GRS-3'
                                 ,'������-1 GRS-6'
                                 ,'������������ �����-1'
                                 ,'������������ �����-2'
                                 ,'������ �������� GRS'
                                 ,'������ �������� GRS ����� ������'
                                 ,'����������� GRS'
                                 ,'���� GRS'
                                 ,'�������� GRS'
                                 ,'������������ ����������'
                                 ,'����� ������'
                                 ,'����� ������������� ������'
                                 ,'����� ����������� � �������������'
                                 ,'����� ����������'
                                 ,'����� �� ������ � �������'
                                 ,'����� �� ������ � ��������� � ������������ ��������'
                                 ,'����� �� �������� ����������'
                                 ,'����� �� �������� � ����������'
                                 ,'����� �� ������ � ��������������� � �������'
                                 ,'����� �������� ��������'
                                 ,'����� ���������� ������������ �����������'
                                 ,'����� ����������'
                                 ,'����� ����������� ��������� � ������������� ��������'
                                 ,'����� �������������� ���������� � ������������'
                                 ,'����� �������������� �������'
                                 ,'����� �����'
                                 ,'����� ����������� ������� � ����������'
                                 ,'����� GRS'
                                 ,'������������� ��� ��������� ��� "�� "��������� �����"  � ������ ����������'
                                 ,'������������� ��� ��������� � �. ������������ ������� ��� "��" ��������� �����" � ������ ����������'
                                 ,'������������� ��� ��������� � �. ��������� ��� "��" ��������� �����" � ������ ����������'
                                 ,'������������� ��� � ������ ���������� ����� ������� ��� "�� "��������� �����" � ������ ������'
                                 ,'������������� ��� ������ �1 � �.��������� ��������� ��� "�� "��������� �����" � ������ ����������'
                                 ,'������������� ��� ����� ��������� ������ � �.��������� ��������� ��� "�� "��������� �����" � ������ ����������'
                                 ,'������������� ��� �2 � �.������������ ������� ��� "�� "��������� �����" � ������ �������������'
                                 ,'������������� ��� �2 � �.������ �������� ������� ��� "�� "��������� �����" � ������ ������ ��������'
                                 ,'������������� ��� �3 � �.��� ������� ��� "�� "��������� �����" � ������ ���'
                                 ,'������ �����������'
                                 ,'������������ ������������ ����������'
                                 ,'������� ��������'
                                 ,'��� 1'
                                 ,'��� 2'
                                 ,'������ �� ���� GRS'
                                 ,'������ GRS-2'
                                 ,'������ GRS-4'
                                 ,'�����-��������� GRS ���'
                                 ,'�����-��������� GRS �����������'
                                 ,'�����-��������� GRS ����������'
                                 ,'�����-��������� GRS ���������� �����������������'
                                 ,'�����-��������� GRS ����������'
                                 ,'�����-��������� GRS ������ ��������'
                                 ,'�����-��������� GRS ���������'
                                 ,'�����-��������� GRS ����������'
                                 ,'�����-��������� GRS �������������'
                                 ,'�����-��������� GRS ����� ��������-2'
                                 ,'�����-��������� GRS ����������'
                                 ,'�����-��������� GRS ����������'
                                 ,'�����-��������� GRS ��������'
                                 ,'�����-��������� GRS-1'
                                 ,'�����-��������� GRS-12'
                                 ,'�����-��������� GRS-2'
                                 ,'�����-��������� GRS-3'
                                 ,'�����-��������� GRS-4'
                                 ,'�����-��������� GRS-5'
                                 ,'������� GRS'
                                 ,'������� GRS'
                                 ,'���������� ��� "�� "��������� �����"'
                                 ,'����������� GRS-3'
                                 ,'��������_������ GRS'
                                 ,'������������ �����'
                                 ,'������ GRS'
                                 ,'����������  �������������� ����������'
                                 ,'���������� ��������� ��������'
                                 ,'���������� �������������, �����������, ��������������� � �������������� �������'
                                 ,'���������� ������'
                                 ,'���������� �� ������ � ����������'
                                 ,'���������� �� �������� �������������� ������'
                                 ,'���������� �� ������������� �������� (���)'
                                 ,'���������� �������� ������'
                                 ,'���������� ������������� �������� (����)'
                                 ,'���������� ������������� �������� (������)'
                                 ,'��� GRS'
                                 ,'������� �����'
                                 ,'�'
                                 ,'���������� ����������'
                                 ,'��������� GRS-1'
                                 ,'����������� ����������'
                                 ,'��������� GRS')
           AND a.dep_name IS NOT NULL) rep
 ORDER BY 1
         ,2
         ,5
         ,8;
