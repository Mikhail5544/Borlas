CREATE OR REPLACE VIEW INS.V_NEW_AGENTS_FOR_CARDS_NEW AS
SELECT --ac.ag_contract_header_id,
 cn.name "Фамилия"
 ,cn.first_name "Имя"
 ,cn.middle_name "Отчество"
 ,ac.num "Номер САД"
 ,cp.date_of_birth "Дата рождения"
 ,cp.place_of_birth "Место рождения"
 ,(SELECT g.description FROM ins.t_gender g WHERE cp.gender = g.id) "Пол"
 ,ci2.serial_nr || ci2.id_value "Паспорт"
 ,ci2.subdivision_code "Код подразделения"
 ,ci2.issue_date "Дата выдачи"
 ,ci2.place_of_issue "Кем выдан"
 ,vcca.address_type_name "Тип адреса"
 ,vcca.address_name "Полный адрес"
 ,nvl2(vcca.region_name, vcca.region_name || ' ' || vcca.region_type_name, NULL) AS "Район"
 ,nvl2(vcca.province_name, vcca.province_type_name|| ' ' || vcca.province_name, NULL) AS "Регион"
 ,nvl2(vcca.city_name, vcca.city_name || ' ' || vcca.city_type_name || '.', NULL) AS "Город"
 ,nvl2(vcca.district_name, vcca.district_type_name || '. ' || vcca.district_name, NULL) AS "Населенный пункт"
 ,nvl2(vcca.street_name, vcca.street_name || ' ' || vcca.street_type_name || '.', NULL) AS "Улица"
 ,vcca.house_nr AS "Дом"
 ,vcca.block_number "Корпус/строение"
 ,vcca.appartment_nr AS "Квартира"
 ,vcca.zip "Индекс"
 ,(SELECT t.telephone_number
    FROM ins.cn_contact_telephone t
   WHERE t.id = to_number(pkg_contact_rep_utils.get_last_phone_id_by_type(cn.contact_id, 'MOBIL'))) AS "Телефон"
 ,ci.id_value "ИНН"
 ,ispl_tab.issue_pl "Офис доставки"
 ,adt.description "Документ"
 ,dsr.name "Статус документа"
 ,trunc(ds.start_date, 'DD') AS "Дата статуса"
 ,(SELECT aca.category_name
    FROM ins.ag_category_agent aca
   WHERE aca.ag_category_agent_id = a.category_id) "Категория"
 ,(SELECT d.name FROM ins.department d WHERE d.department_id = ac.agency_id) AS "Агентство"
 ,sc.description "Канал продаж"
 ,tct.description AS "Юр. статус"
 ,decode(cn.resident_flag, 1, 'Да', 0, 'Нет') AS "Резидент"
 ,pkg_contact_rep_utils.get_bank_acc_by_mask(ccba.id, '<#BANK_NAME>') AS "Банк"
 ,pkg_contact_rep_utils.get_bank_acc_by_mask(ccba.id, '<#ACCOUNT_NR>') AS "Расчетный счет"
 ,pkg_contact_rep_utils.get_bank_acc_by_mask(ccba.id, '<#LIC_CODE>') AS "Лицевой счет"
 ,(SELECT adr.city_name
    FROM ins.cn_address adr
   WHERE adr.id = to_number(pkg_contact_rep_utils.get_bank_acc_by_mask(ccba.id, '<#PLACE_OF_ISSUE>'))) AS "Место выдачи"

  FROM ins.ven_ag_contract_header ac
      ,ins.ag_contract            a
      ,ins.ag_documents           ad
      ,ins.ag_doc_type            adt
      ,ins.document               d
      ,ins.doc_status             ds
      ,ins.doc_status_ref         dsr
      ,ins.t_sales_channel        sc
      ,ins.t_contact_type         tct
      ,ins.cn_person              cp
      ,ins.contact                cn
      ,ins.cn_contact_ident       ci
      ,ins.cn_contact_ident       ci2
       
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
           AND dsr.name = 'Проект'
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
           AND ad1.ag_doc_type_id IN (1, 3) -- Заключение АД, Изменение категории
           AND ad1.ag_documents_id = apc1.ag_documents_id
           AND apc1.is_accepted = 1
           AND apc1.ag_props_type_id = 1 -- Категория
           AND apc1.new_value = 2 -- Агент
              --and ad1.ag_contract_header_id = 97940167
           AND ds1.start_date BETWEEN --to_date('25.01.2014') AND to_date('31.01.2014')
                       (SELECT to_date(r.param_value)
                     FROM ins_dwh.rep_param r
                    WHERE r.rep_name = 'nafc_new'
                      AND r.param_name = 'DATE_FROM')
              AND (SELECT to_date(r.param_value) + INTERVAL '1439:59' minute TO SECOND
                     FROM ins_dwh.rep_param r
                    WHERE r.rep_name = 'nafc_new'
                      AND r.param_name = 'DATE_TO')
              
           AND ds1.doc_status_ref_id = 142
         GROUP BY ad1.ag_contract_header_id) ag_d
      ,ins.v_cn_contact_address vcca
      ,(SELECT MAX(ccba1.id) id
              ,ccba1.contact_id
          FROM ins.cn_contact_bank_acc ccba1
         WHERE ccba1.used_flag = 1
         GROUP BY ccba1.contact_id) ccba
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
   AND ccba.contact_id(+) = cn.contact_id
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
   AND ci.id_type(+) = 1 -- ИНН;;
   AND ci2.contact_id(+) = ac.agent_id
   AND ci2.id_type IN (20001, 20002) --Паспорт РФ/СССР
   AND ci2.issue_date = (SELECT MAX(cci2.issue_date)
                           FROM ins.cn_contact_ident cci2
                          WHERE cci2.contact_id = ci2.contact_id
                            AND cci2.id_type IN (20001, 20002));
