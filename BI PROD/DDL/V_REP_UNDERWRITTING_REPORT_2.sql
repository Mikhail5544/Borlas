CREATE OR REPLACE VIEW INS.V_REP_UNDERWRITTING_REPORT_2 AS
SELECT "���������"
       ,"��� ���"
       ,"����� �� ��"
       ,
       /*"����� �� �� ����",
       "����� ������ ���� ������",
       "��������� ����",*/"����� ��"
       ,"����� ��"
       ,"�������"
       ,"���� ������ ��"
       ,"������������"
       ,"���� ������� ��"
       ,"���� ������� ���"
       ,"���� ������� �����"
       ,"������ ������"
       ,"������ ��������� ������"
       ,"��� ��������"
       ,nvl("�������������", '��� ��������������') "�������������"
       ,"���� ���������� �������"
       ,"������������"
       ,"�������� ����."
       ,"����������"
       ,"���"
       ,policy_header_id
       ,"������ 1 ���"
       ,"��� �������"
       ,user_name
       ,"���� �� ����. �� ���. �������"
       ,"��� ���� ������� �� ��� �"
       ,trunc("��� ���� ������� �� ��� �", 'dd') - "���� ������� ��" "���� �� ������� �� �� ��� �"
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
       ,"��������� ��"
       ,"����������� �����"
       ,"������� ����� ������������"
       ,"������� ����� ������ �� ��"
       ,"������� ����� ������ ������"
  FROM (SELECT ins.ent.obj_name('DEPARTMENT', a.agency_id) "���������"
               ,nvl(ins.ent.obj_name('CONTACT'
                                   ,(SELECT ach_lead.agent_id
                                      FROM ins.ag_contract_header ach_lead
                                     WHERE ach_lead.ag_contract_header_id = a.ac_lead_contract_id))
                  ,'��� ������������') "��� ���"
               ,ins.ent.obj_name('CONTACT', a.agent_id) "����� �� ��"
               ,(SELECT ll.description
                  FROM ins.contact      c
                      ,ins.t_risk_level ll
                 WHERE c.contact_id = a.agent_id
                   AND c.risk_level = ll.t_risk_level_id) "������� ����� ������ �� ��"
               ,pp.pol_ser "����� ��"
               ,pp.pol_num "����� ��"
               ,tp.description "�������"
               ,ph.start_date "���� ������ ��"
               ,ins.ent.obj_name('CONTACT'
                               ,ins.pkg_policy.get_policy_contact(pp.policy_id
                                                                 ,'������������')) "������������"
               ,(SELECT ll.description
                  FROM ins.contact      c
                      ,ins.t_risk_level ll
                 WHERE c.contact_id =
                       ins.pkg_policy.get_policy_contact(pp.policy_id, '������������')
                   AND c.risk_level = ll.t_risk_level_id) "������� ����� ������������"
               ,trunc(pp.sign_date, 'dd') "���� ������� ��"
               ,to_char(pp.sign_date, 'YYYY') "���� ������� ���"
               ,to_char(pp.sign_date, 'mm') "���� ������� �����"
               ,
               
               dsr.name "������ ������"
               ,ins.pkg_policy.get_last_version_status(ph.policy_header_id) "������ ��������� ������"
               ,
               --(select rf.name from ins.doc_status_ref rf where rf.doc_status_ref_id = doc.doc_status_ref_id) "������ ��������� ������",
               (SELECT da.note
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
               ,ROUND(ds.change_date - pp.sign_date) "������������"
               ,(SELECT da.plan_duration
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "�������� ����."
               ,(SELECT da.plan_duration - ROUND(lead(ds.change_date, 1, SYSDATE)
                                                over(ORDER BY ds.change_date) - ds.change_date
                                               ,2)
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "����������"
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
               ,(SELECT trunc(ds.change_date - ds2.change_date)
                  FROM (SELECT ds.change_date
                              ,ds.doc_status_id
                              ,ds.document_id
                              ,row_number() over(PARTITION BY ds.document_id ORDER BY ds.change_date DESC) c
                          FROM ins.doc_status ds) a
                      ,ins.doc_status ds2
                 WHERE a.document_id = ds2.document_id
                   AND ds2.doc_status_id = a.doc_status_id
                   AND ds2.document_id = pp.policy_id
                   AND a.c = 2) "���� �� ����. �� ���. �������"
               ,(SELECT MIN(ds2.change_date)
                  FROM ins.p_policy       p2
                      ,ins.doc_status     ds2
                      ,ins.doc_status_ref dsr2
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND ds2.document_id = p2.policy_id
                   AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
                   AND dsr2.brief IN ('CONCLUDED', 'CURRENT')) "��� ���� ������� �� ��� �"
               ,nvl(pp.is_group_flag, 0) "��������� ��"
               ,ag_cur.agent_current "����������� �����"
               ,(SELECT ll.description
                  FROM ins.contact      c
                      ,ins.t_risk_level ll
                 WHERE c.contact_id = ag_cur.agent_id
                   AND c.risk_level = ll.t_risk_level_id) "������� ����� ������ ������"
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
              --and a.policy_header_id (+) = ph.policy_header_id
           AND a.policy_header_id = ph.policy_header_id
           AND ins.doc.get_doc_status_rec_id(pp.policy_id, '01.01.3000') = ds.doc_status_id
           AND ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND ph.policy_header_id = ag_cur.policy_header_id(+)
           AND tp.brief NOT IN ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')
              --and pp.policy_id = 62496530
              -------------------------------------------------------------------------------------------------------
              -- and pp.sign_date BETWEEN to_date('01.01.2015', 'dd.mm.yyyy') and to_date('01.02.2015', 'dd.mm.yyyy')
           AND pp.sign_date BETWEEN to_date((SELECT r.param_value
                                              FROM ins_dwh.rep_param r
                                             WHERE r.rep_name = 'under_rep_2'
                                               AND r.param_name = 'DATE_FROM')
                                           ,'dd.mm.yyyy')
           AND to_date((SELECT r.param_value
                         FROM ins_dwh.rep_param r
                        WHERE r.rep_name = 'under_rep_2'
                          AND r.param_name = 'DATE_TO')
                      ,'dd.mm.yyyy')
              -------------------------------------------------------------------------------------------------------
           AND (a.dep_name NOT IN (' ����� ������-�������'
                                  ,'Call center'
                                  ,'�����'
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
                                  ,'��������� GRS') OR
               --390998 ��������� �. ��������� ��������� �������� ������ �� �������� �������� � "������� ������ � ���������"
               (a.dep_name = '������� ������ � ���������' AND tp.brief IN ('Nasledie', 'Nasledie_HKF')))
           AND a.dep_name IS NOT NULL)
 ORDER BY 1
         ,2
         ,5
         ,8;
