CREATE OR REPLACE VIEW V_NEW_AGENTS_FOR_CARDS AS
SELECT --ac.ag_contract_header_id,
 cn.name "�������"
 ,cn.first_name "���"
 ,cn.middle_name "��������"
 ,ac.NUM "����� ���"
 ,cp.date_of_birth "���� ��������"
 ,cp.place_of_birth "����� ��������"
 ,(SELECT g.description FROM ins.t_gender g WHERE cp.gender = g.id) "���"
 ,ci2.serial_nr || ci2.id_value "�������"
 ,ci2.SUBDIVISION_CODE "��� �������������"
 ,ci2.issue_date "���� ������"
 ,ci2.place_of_issue "��� �����"
 ,vcca.address_type_name "��� ������"
 ,vcca.address_name "������ �����"
 ,vcca.region_name AS "�����"
 ,vcca.province_name AS "������"
 ,vcca.city_name AS "�����"
 ,vcca.district_name AS "���������� �����"
 ,vcca.street_name AS "�����"
 ,vcca.house_nr AS "���"
 ,vcca.block_number "������/��������"
 ,vcca.appartment_nr AS "��������"
 ,vcca.zip "������"
 ,(SELECT tel.telephone_number
    FROM ins.cn_contact_telephone tel
   WHERE tel.contact_id = cn.contact_id
     AND rownum = 1) AS "�������"
 ,ci.id_value "���"
 ,ispl_tab.issue_pl "���� ��������"
 ,adt.description "��������"
 ,dsr.name "������ ���������"
 ,trunc(ds.start_date, 'DD') AS "���� �������"
 ,(SELECT aca.category_name
    FROM ins.ag_category_agent aca
   WHERE aca.ag_category_agent_id = a.category_id) "���������"
 ,(SELECT d.name FROM ins.department d WHERE d.department_id = ac.agency_id) AS "���������"
 ,sc.description "����� ������"
 ,tct.description AS "��. ������"
  FROM ins.ven_ag_contract_header ac
      ,ins.ag_contract a
      ,ins.ag_documents ad
      ,ins.ag_doc_type adt
      ,ins.document d
      ,ins.doc_status ds
      ,ins.doc_status_ref dsr
      ,ins.t_sales_channel sc
      ,ins.t_contact_type tct
      ,ins.cn_person cp
      ,ins.contact cn
      ,ins.cn_contact_ident ci
      ,ins.cn_contact_ident ci2
      ,(SELECT cn.contact_id
              ,coalesce(cad.city_name, cad.province_name, cad.district_name) issue_pl
          FROM ins.ven_cn_contact_bank_acc ccba
              ,ins.contact                 cn
              ,ins.document                dc
              ,ins.doc_status_ref          dsr
              ,ins.cn_document_bank_acc    dacc
              ,ins.ven_cn_address          cad
         WHERE ccba.bank_id = 836996
           AND cn.contact_id = ccba.contact_id
           AND dacc.cn_contact_bank_acc_id = ccba.id
           AND dc.document_id = dacc.cn_document_bank_acc_id
           AND dsr.doc_status_ref_id = dc.doc_status_ref_id
           AND dsr.name = '������'
           AND ccba.place_of_issue = cad.id(+)) ispl_tab
      ,(SELECT ad1.ag_contract_header_id
              ,MAX(ds1.start_date) AS status_date
          FROM ins.ag_documents ad1
              ,ins.document     d1
              ,ins.doc_status   ds1
               --             , ins.doc_status_ref dsr1
              ,ins.ag_props_change apc1
         WHERE ad1.ag_documents_id = d1.document_id
           AND d1.document_id = ds1.document_id
           AND ad1.ag_doc_type_id IN (1, 3) -- ���������� ��, ��������� ���������
           AND ad1.ag_documents_id = apc1.ag_documents_id
           AND apc1.is_accepted = 1
           AND apc1.ag_props_type_id = 1 -- ���������
           AND apc1.new_value = 2 -- �����
           AND ds1.start_date BETWEEN (SELECT to_date(r.param_value)
                                         FROM ins_dwh.rep_param r
                                        WHERE r.rep_name = 'new_agents_for_cards'
                                          AND r.param_name = 'DATE_FROM') /*to_date('12.12.2012')*/
                                 AND (SELECT to_date(r.param_value)
                                        FROM ins_dwh.rep_param r
                                       WHERE r.rep_name = 'new_agents_for_cards'
                                         AND r.param_name = 'DATE_TO') /*to_date('15.01.2013')*/
           AND ds1.doc_status_ref_id = 142
        --            and ad1.ag_contract_header_id = 61220041
         GROUP BY ad1.ag_contract_header_id) ag_d
      ,ins.v_cn_contact_address vcca
 WHERE ac.ag_contract_header_id = ag_d.ag_contract_header_id
   AND ac.last_ver_id = a.ag_contract_id
   AND a.category_id = 2
   AND ad.ag_contract_header_id = ac.ag_contract_header_id
   AND ad.ag_doc_type_id IN (1, 3)
   AND ad.ag_documents_id = d.document_id
   AND d.document_id = ds.document_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.doc_status_ref_id = 142
   AND ds.start_date = ag_d.status_date
   AND adt.ag_doc_type_id = ad.ag_doc_type_id
   AND ac.t_sales_channel_id = sc.id
   AND sc.description IN ('DSF', 'SAS', 'SAS 2')
   AND cp.contact_id = ac.agent_id
   AND cn.contact_id = ac.agent_id
   AND ispl_tab.contact_id(+) = ac.agent_id
   AND vcca.contact_id = ac.agent_id
   AND vcca.contact_address_id =
       (SELECT MAX(cca.id)
          FROM cn_contact_address cca
         WHERE cca.contact_id = ac.agent_id
           AND cca.status = 1
           AND (cca.address_type IN (3, 803) OR NOT EXISTS
                (SELECT NULL
                   FROM cn_contact_address cca2
                  WHERE cca2.contact_id = cca.contact_id
                    AND cca2.status = 1
                    AND cca2.address_type IN (3, 803))))
   AND ci.contact_id(+) = ac.agent_id
   AND a.leg_pos = tct.id
   AND ci.id_type(+) = 1 -- ���;;
   AND ci2.contact_id(+) = ac.agent_id
   AND ci2.id_type IN (20001, 20002) --������� ��/����
   AND ci2.issue_date = (SELECT MAX(cci2.issue_date)
                           FROM ins.cn_contact_ident cci2
                          WHERE cci2.contact_id = ci2.contact_id
                            AND cci2.id_type IN (20001, 20002));
