CREATE OR REPLACE VIEW INS_DWH.V_PAYMENT_QUIT_POL AS
SELECT DISTINCT pr.PAYMENT_REGISTER_ITEM_ID "��"
                ,pr.DUE_DATE "���� ��"
                ,pr.NUM "����� ��"
                ,pr.AMOUNT "����� �������"
                ,pr.sum2setoff "����� �������� �������"
                ,pr.TERRITORY "������"
                ,pr.PAYMENT_PURPOSE "����������"
                ,pr.set_off_state_descr "������ ������ ���������"
                ,pr.NOTE "�����������"
                ,pr.ids "���"--substr(pr.NOTE, 48, 10) 
                ,pp.pol_num "����� ������"
                ,cpol.obj_name_orig "������������"
                ,prod.description "�������"
                ,trm.description "�������������"
                ,(SELECT pp.decline_date
                   FROM ins.p_policy p
                  WHERE p.policy_id = ins.pkg_policy.get_last_version(ph.policy_header_id)) "���� �����������"
                ,(SELECT dr.name
                   FROM ins.p_policy             p
                       ,ins.ven_t_decline_reason dr
                  WHERE p.policy_id = ins.pkg_policy.get_last_version(ph.policy_header_id)
                    AND dr.t_decline_reason_id(+) = pp.decline_reason_id) "������� �����������"
                ,ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 2, SYSDATE) "��������� ����������"
                ,ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) "������ ������������"
                ,ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) + 70 "���� ������������� + 70"
                ,CASE
                  WHEN ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) + 70 >=
                       pr.DUE_DATE THEN
                   '������������ ��� �������������'
                  WHEN ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) + 70 <
                       pr.DUE_DATE THEN
                   '������������ ����������� �������'
                  ELSE
                   ''
                END "������� ��������������"
                ,dep.name "���������"
                ,d.num || ' ' || cag.obj_name_orig "�����"
                ,(SELECT dl.num || ' ' || cagl.obj_name_orig
                   FROM ins.ag_contract        ag
                       ,ins.ag_contract        agl
                       ,ins.ag_contract_header aghl
                       ,ins.contact            cagl
                       ,ins.document           dl
                  WHERE ag.contract_id = agh.ag_contract_header_id
                    AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
                    AND nvl(agh.is_new, 0) = 1
                    AND ag.contract_leader_id = agl.ag_contract_id
                    AND agl.contract_id = aghl.ag_contract_header_id
                    AND aghl.ag_contract_header_id = dl.document_id
                    AND aghl.agent_id = cagl.contact_id) "������������ ������"
                ,(SELECT tel.telephone_prefix || ' ' || tel.telephone_number tel
                   FROM ins.t_telephone_type     tt
                       ,ins.cn_contact_telephone tel
                  WHERE tel.contact_id = cpol.contact_id
                    AND tt.id = tel.telephone_type
                    AND tt.description IN ('���������� �������')
                    AND length(tel.telephone_number) > 3
                    AND rownum = 1) "���������� �������"
                ,(SELECT tel.telephone_prefix || ' ' || tel.telephone_number tel
                   FROM ins.t_telephone_type     tt
                       ,ins.cn_contact_telephone tel
                  WHERE tel.contact_id = cpol.contact_id
                    AND tt.id = tel.telephone_type
                    AND tt.description IN ('������ �������')
                    AND length(tel.telephone_number) > 3
                    AND rownum = 1) "������ �������"
                ,(SELECT tel.telephone_prefix || ' ' || tel.telephone_number tel
                   FROM ins.t_telephone_type     tt
                       ,ins.cn_contact_telephone tel
                  WHERE tel.contact_id = cpol.contact_id
                    AND tt.id = tel.telephone_type
                    AND tt.description IN ('���������')
                    AND length(tel.telephone_number) > 3
                    AND rownum = 1) "��������� �������"
                ,NVL(ca.name, ins.pkg_contact.get_address_name(ca.id)) "������ ������"
                ,(CASE
                  WHEN ca.street_name IS NOT NULL THEN
                   (CASE
                     WHEN ca.street_type IS NOT NULL THEN
                      ca.street_type
                     ELSE
                      '��.'
                   END) || ca.street_name
                  ELSE
                   ''
                END || CASE
                  WHEN ca.house_nr IS NOT NULL THEN
                   ',�.' || ca.house_nr
                  ELSE
                   ''
                END || CASE
                  WHEN ca.block_number IS NOT NULL THEN
                   ',' || ca.block_number
                  ELSE
                   ''
                END || CASE
                  WHEN ca.appartment_nr IS NOT NULL THEN
                   ',��.' || ca.appartment_nr
                  ELSE
                   ''
                END) "����������� ������ ������"
                ,(CASE
                  WHEN ca.city_name IS NOT NULL THEN
                   (CASE
                     WHEN ca.city_type IS NOT NULL THEN
                      ca.city_type
                     ELSE
                      '�.'
                   END) || ca.city_name
                  ELSE
                   ''
                END) "�����"
                ,CASE
                  WHEN ca.region_name IS NOT NULL THEN
                   (CASE
                     WHEN ca.region_type IS NOT NULL THEN
                      ca.region_type || ' '
                     ELSE
                      ''
                   END) || ca.region_name
                  ELSE
                   ''
                END "�����"
                ,CASE
                  WHEN ca.province_name IS NOT NULL THEN
                   (CASE
                     WHEN ca.province_type IS NOT NULL THEN
                      ca.province_type || ' '
                     ELSE
                      ''
                   END) || ca.province_name
                  ELSE
                   ''
                END "�������"
                ,CASE
                  WHEN ca.district_name IS NOT NULL THEN
                   (CASE
                     WHEN ca.district_type IS NOT NULL THEN
                      ca.district_type || ' '
                     ELSE
                      ''
                   END) || ca.district_name
                  ELSE
                   ''
                END "���������� �����"
                ,(SELECT DISTINCT tc.description FROM ins.t_country tc WHERE tc.id = ca.country_id) "������"
                ,ca.zip "������"

  FROM ins.V_PAYMENT_REGISTER pr
  JOIN ins.p_pol_header ph
    ON --to_char(ph.Ids) = substr(pr.NOTE, 48, 10)
       ph.ids=pr.ids--326315	FW: ����������� ����������� ����� ����������� �������� �� ������������ ���������
  JOIN ins.p_policy pp
    ON (ph.policy_id = pp.policy_id)
  JOIN ins.p_policy_contact pcnt
    ON (pcnt.policy_id = pp.policy_id)
  JOIN ins.t_contact_pol_role polr
    ON (pcnt.contact_policy_role_id = polr.id AND polr.brief = '������������')
  JOIN ins.contact cpol
    ON (cpol.contact_id = pcnt.contact_id)
  JOIN ins.t_product prod
    ON (prod.product_id = ph.product_id)
  JOIN ins.t_payment_terms trm
    ON (pp.payment_term_id = trm.id)
  LEFT OUTER JOIN ins.department dep
    ON (ph.agency_id = dep.department_id)
  LEFT OUTER JOIN ins.p_policy_agent_doc pad
    ON (pad.policy_header_id = ph.policy_header_id AND
       ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT')
  LEFT OUTER JOIN ins.ag_contract_header agh
    ON (agh.ag_contract_header_id = pad.ag_contract_header_id)
  LEFT OUTER JOIN ins.document d
    ON (d.document_id = agh.ag_contract_header_id)
  LEFT OUTER JOIN ins.contact cag
    ON (cag.contact_id = agh.agent_id)
  LEFT OUTER JOIN ins.cn_address ca
    ON (ins.pkg_contact.get_primary_address(cpol.contact_id) = ca.ID)

 WHERE pr.DUE_DATE BETWEEN --to_date('01-01-2011','dd-mm-yyyy') and to_date('31-01-2011','dd-mm-yyyy')
       (SELECT param_value
          FROM ins_dwh.rep_param
         WHERE rep_name = 'quit_pay'
           AND param_name = 'start_date')
   AND (SELECT param_value
          FROM ins_dwh.rep_param
         WHERE rep_name = 'quit_pay'
           AND param_name = 'end_date')
   AND pr.set_off_state_descr = '�����������'
--and pr.PAYMENT_PURPOSE like '%�������� ������ ���������� 004532-�������� ������ ����������';
;
