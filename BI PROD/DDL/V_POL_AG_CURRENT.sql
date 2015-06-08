CREATE OR REPLACE VIEW V_POL_AG_CURRENT AS
-- ��. ����������� �������� �� ������
SELECT ac.obj_name_orig "��� ������"
       ,pp.pol_num "����� ������"
       ,pph.ids "�������������"
       ,c.obj_name_orig "��� ������������"
       ,decode(cct.telephone_type, 2, cct.telephone_number, NULL) "������� �������"
       ,decode(cct.telephone_type, 3, cct.telephone_number, NULL) "�������� �������"
       ,decode(cct.telephone_type, 4, cct.telephone_number, NULL) "��������� �������"
       ,cp.date_of_birth "���� �������� ������������"
       ,tp.description "�������"
       ,de.name "���������"
       ,pph.start_date "���� ������ ��������"
       ,trunc(pp.end_date) "���� ��������� ��������"
       ,dsr_lv.name "������ ����. ������ ��������"
       --,ins.pkg_policy.get_last_version_status(pph.policy_header_id) "������ ����. ������ ��������"
       ,pt.description "������������� ������"
       ,MIN(CASE
             WHEN pps.plan_date >= SYSDATE
                  AND pps.doc_status_ref_name != '�������' THEN
              pps.plan_date
           END) "���� ���������� �������"
       ,MIN(CASE
             WHEN pps.grace_date >= SYSDATE
                  AND pps.doc_status_ref_name != '�������' THEN
              pps.grace_date
           END) "���� ���������� �������"
       ,MAX(CASE
             WHEN pps.plan_date <= SYSDATE
                  AND pps.doc_status_ref_name != '�������' THEN
              pps.plan_date
           END) "���� ���������� �������."
       ,pkg_renlife_utils.first_unpaid(pph.policy_header_id, 2) "���� ����. ����������� �������"
       ,SUM(pps.amount) "����� �������"
       ,SUM(pps.pay_amount) "��������"
       ,SUM(pps.amount) - SUM(pps.pay_amount) "�������������"
       ,tc.description "������"
       ,ca.zip "������"
       ,ca.region_name "�����"
       ,ca.province_name "�������"
       ,ca.city_name "�����"
       ,ca.district_name "��������� �����"
       ,ca.street_name "�����"
       ,ca.house_nr "���"
       ,ca.block_number "������"
       ,ca.building_name "��������"
       ,ca.appartment_nr "��������"
       ,sc.description "����� ������"
  FROM ins.ag_contract_header ach
  JOIN ins.ag_contract cn
    ON ach.last_ver_id = cn.ag_contract_id
  JOIN ins.t_sales_channel sc
    ON cn.ag_sales_chn_id = sc.id
  JOIN ins.contact ac
    ON ac.contact_id = ach.agent_id
  JOIN ins.ven_p_policy_agent_doc pad
    ON pad.ag_contract_header_id = ach.ag_contract_header_id
   AND ins.pkg_readonly.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
  JOIN ins.p_pol_header pph
    ON pph.policy_header_id = pad.policy_header_id
--309346: �������� � ����� ��. ����� - ����������� �������� �� /������/
  JOIN ins.document dpad
    ON pad.p_policy_agent_doc_id = dpad.document_id
  JOIN ins.doc_status dspad
    ON dpad.doc_status_id = dspad.doc_status_id
--
  JOIN ins.ven_p_policy pp
    ON pp.policy_id = pph.policy_id
   AND pp.is_group_flag != 1
  JOIN ins.p_policy_contact ppc
    ON ppc.policy_id = pp.policy_id
  JOIN ins.t_contact_pol_role cpr
    ON cpr.id = ppc.contact_policy_role_id
   AND cpr.description = '������������'
  JOIN ins.contact c
    ON c.contact_id = ppc.contact_id
  LEFT JOIN ins.cn_contact_telephone cct
    ON cct.contact_id = c.contact_id
   AND cct.telephone_type IN (2, 3, 4) -- ���, ���, ���
  LEFT JOIN ins.cn_person cp
    ON cp.contact_id = c.contact_id
--<< �� ��� ������� � ������� �������
  LEFT JOIN ins.cn_contact_address cca
    ON cca.contact_id = c.contact_id
  LEFT JOIN ins.cn_address ca
    ON ca.id = cca.adress_id
  LEFT JOIN ins.t_country tc
    ON tc.id = ca.country_id
/*LEFT JOIN ins.t_region tr ON tr.region_id = ca.region_id
LEFT JOIN ins.t_province tpr ON tpr.province_id = ca.province_id
LEFT JOIN ins.t_city tci ON tci.city_id = ca.city_id
LEFT JOIN ins.t_street ts ON ts.street_id = ca.street_id
LEFT JOIN ins.t_district td ON td.district_id = ca.district_id*/
-->>
  JOIN ins.t_product tp
    ON tp.product_id = pph.product_id
   AND tp.description NOT LIKE '�� %'
  LEFT JOIN ins.department de
    ON de.department_id = pph.agency_id
  JOIN ins.t_payment_terms pt
    ON pt.id = pp.payment_term_id
  JOIN ins.v_policy_payment_schedule pps
    ON pps.pol_header_id = pph.policy_header_id
   AND pps.plan_date >= TO_DATE('20080101', 'YYYYMMDD')

 , ins.ven_p_policy lv, ins.doc_status_ref dsr_lv, ins.doc_status_ref dsr_av
 WHERE lv.policy_id = pph.last_ver_id
   AND dsr_lv.doc_status_ref_id = lv.doc_status_ref_id
   AND pp.doc_status_ref_id = dsr_av.doc_status_ref_id
   AND
      --������� �������� �� ������ 309346/316299
       (dsr_lv.name IN ('��������'
                       ,'��������������'
                       ,'�����������'
                       ,'������� ��������'
                       ,'���������'
                       ,'����������'
                       ,'���������'
                       ,'�����'
                       ,'����� � ��������������'
                       ,'�������� ������'
                       ,'���������. ������ ����������'
                       ,'������')
       --��������� � �������, �������� � �����������, ����������, ���������
       OR (dsr_lv.name = '�������' AND
       dsr_av.name IN ('�����������', '����������', '���������')))
      
      --and pph.start_date BETWEEN date '2007-01-01' and date'2014-04-01'
      --��� ������ ��������
      --���� �������� �� ������ ������������� ������ ���� ���������
   AND dspad.start_date >= TO_DATE((SELECT r.param_value
                                     FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'v_pol_ag_current'
                                      AND r.param_name = 'date_direct_suport')
                                  ,'dd.mm.yyyy')
      --and pph.ids = 1950062695
      
      -- ��������1 - �������� ��� ������ �������� ��������
   AND pph.start_date BETWEEN TO_DATE((SELECT r.param_value
                                        FROM ins_dwh.rep_param r
                                       WHERE r.rep_name = 'v_pol_ag_current'
                                         AND r.param_name = 'date_from')
                                     ,'dd.mm.yyyy')
   AND TO_DATE((SELECT r.param_value
                 FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'v_pol_ag_current'
                  AND r.param_name = 'date_to')
              ,'dd.mm.yyyy')
      -- ��������2 - �����, �� ������� ��������� �������
      --����������� �� ������ 309346  
   /*
    ������ 332603 ������� �� ������ �������������
    ����������� �.  
    � ���� ������ ������������� �������� (329826)
    �������� ��� ���  � ����������� �� ������ ������ (8187958, 8187959, 8187960)
  */
   AND ac.contact_id IN (329826, 8187958, 8187959, 8187960, 1116423) /*������������ ����� ������������ � ������ ������������� ��������*/ /*������ �. ������ 178659*/
--    AND ids = 2420039565
 GROUP BY ac.obj_name_orig
         ,pp.pol_num
         ,pph.ids
         ,c.obj_name_orig
         ,cct.telephone_type
         ,cct.telephone_number
         ,cp.date_of_birth
         ,tp.description
         ,de.name
         ,pph.start_date
         ,pp.end_date
         ,pt.description
         ,pph.policy_header_id
         ,pps.pol_header_id
         ,tc.description
         ,ca.zip
         ,ca.region_name
         ,ca.province_name
         ,ca.city_name
         ,ca.district_name
         ,ca.street_name
         ,ca.house_nr
         ,ca.block_number
         ,ca.building_name
         ,ca.appartment_nr
         ,sc.description --)
         ,dsr_lv.name
