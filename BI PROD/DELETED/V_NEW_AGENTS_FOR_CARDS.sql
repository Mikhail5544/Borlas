CREATE OR REPLACE VIEW V_NEW_AGENTS_FOR_CARDS AS
select --ac.ag_contract_header_id,
       cn.name                           "Фамилия"
      ,cn.first_name                     "Имя"
      ,cn.middle_name                    "Отчество"
      ,ac.NUM                            "Номер САД"
      ,cp.date_of_birth                  "Дата рождения"
      ,cp.place_of_birth                 "Место рождения"
      ,(SELECT g.description
          FROM ins.t_gender g
         WHERE   cp.gender=g.id)         "Пол"
      ,cci.serial_nr||cci.id_value       "Паспорт"
      ,cci.SUBDIVISION_CODE              "Код подразделения"
      ,cci.issue_date                    "Дата выдачи"
      ,cci.place_of_issue                "Кем выдан"
      ,vcca.address_type_name            "Тип адреса"
      ,vcca.address_name                 "Полный адрес"
      ,vcca.region_name AS               "Район"
      ,vcca.province_name AS             "Регион"
      ,vcca.city_name AS                 "Город"
      ,vcca.district_name AS             "Населенный пункт"
      ,vcca.street_name AS               "Улица"
      ,vcca.house_nr AS                  "Дом"
      ,vcca.block_number                 "Корпус/строение"
      ,vcca.appartment_nr AS             "Квартира"
      ,vcca.zip                          "Индекс"
      ,(SELECT tel.telephone_number
          FROM ins.cn_contact_telephone tel
         WHERE tel.contact_id = cn.contact_id
           AND rownum = 1) as            "Телефон"
      ,ci.id_value                       "ИНН"
      ,ispl_tab.issue_pl                 "Офис доставки"
      , adt.description                  "Документ"
      , dsr.name                         "Статус документа"
      , trunc(ds.start_date,'DD') as     "Дата статуса"
      ,(select aca.category_name
              from ins.ag_category_agent aca
              where aca.ag_category_agent_id = a.category_id)
                                         "Категория"
      ,(select d.name
        from ins.department d
        where d.department_id = ac.agency_id)
        as                               "Агентство"
      ,sc.description                    "Канал продаж"
      ,tct.description                as "Юр. статус"
from ins.ven_ag_contract_header          ac
     , ins.ag_contract                   a
     , ins.ag_documents                  ad
     , ins.ag_doc_type                   adt
     , ins.document                      d
     , ins.doc_status                    ds
     , ins.doc_status_ref                dsr
     , ins.t_sales_channel               sc
     , ins.t_contact_type                tct
      ,(select * from ins.cn_contact_ident cci1
        where cci1.id_type in (20001, 20002) --Паспорт РФ/СССР
              and cci1.issue_date = (SELECT max(cci2.issue_date)
                               FROM ins.cn_contact_ident cci2
                              WHERE cci2.contact_id=cci1.contact_id
                                AND cci2.id_type in (20001, 20002) )
             )                           cci
      ,ins.cn_person                     cp
      ,ins.contact                       cn
      ,ins.cn_contact_ident              ci
      ,(SELECT cn.contact_id, coalesce(cad.city_name,cad.province_name, cad.district_name) issue_pl
            FROM ins.ven_cn_contact_bank_acc       ccba
                ,ins.contact                       cn
                ,ins.document                      dc
                ,ins.doc_status_ref                dsr
                ,ins.cn_document_bank_acc          dacc
                ,ins.ven_cn_address                cad
          WHERE ccba.bank_id                      = 836996
            AND cn.contact_id                     = ccba.contact_id
            AND dacc.cn_contact_bank_acc_id       = ccba.id
            AND dc.document_id                    = dacc.cn_document_bank_acc_id
            AND dsr.doc_status_ref_id             = dc.doc_status_ref_id
            AND dsr.name                          = 'Проект'
            and ccba.place_of_issue               = cad.id(+)
            )                             ispl_tab
     , (
      select ad1.ag_contract_header_id, max(ds1.start_date) as status_date from
             ins.ag_documents ad1
             , ins.document d1
             , ins.doc_status ds1
--             , ins.doc_status_ref dsr1
             , ins.ag_props_change apc1
      where ad1.ag_documents_id = d1.document_id
            and d1.document_id = ds1.document_id
            and ad1.ag_doc_type_id in  (1,3) -- Заключение АД, Изменение категории
            and ad1.ag_documents_id = apc1.ag_documents_id
            and apc1.is_accepted = 1
            and apc1.ag_props_type_id = 1 -- Категория
            and apc1.new_value = 2 -- Агент
            and ds1.start_date between /*to_date('12.12.2012')*/(SELECT to_date(r.param_value)
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'new_agents_for_cards'
                                            AND r.param_name = 'DATE_FROM')
                                        AND /*to_date('13.12.2012')*/(SELECT to_date(r.param_value)
                                               FROM ins_dwh.rep_param r
                                              WHERE r.rep_name = 'new_agents_for_cards'
                                                AND r.param_name = 'DATE_TO')
            and ds1.doc_status_ref_id = 142
--            and ad1.ag_contract_header_id = 60357130
      group by ad1.ag_contract_header_id
      ) ag_d
    ,ins.v_cn_contact_address          vcca
where ac.ag_contract_header_id = ag_d.ag_contract_header_id
      and ac.last_ver_id = a.ag_contract_id
      and a.category_id = 2
      and ad.ag_contract_header_id = ac.ag_contract_header_id
      and ad.ag_doc_type_id in (1,3)
      and ad.ag_documents_id = d.document_id
      and d.document_id = ds.document_id
      and ds.doc_status_ref_id = dsr.doc_status_ref_id
      and dsr.doc_status_ref_id = 142
      and ds.start_date = ag_d.status_date
      and adt.ag_doc_type_id = ad.ag_doc_type_id
      and ac.t_sales_channel_id= sc.id
      and sc.description in ('DSF', 'SAS', 'SAS 2')
      and cp.contact_id = ac.agent_id
      and cn.contact_id = ac.agent_id
      AND cci.contact_id(+)  = ac.agent_id
      and ispl_tab.contact_id (+) = ac.agent_id
      AND vcca.contact_id = ac.agent_id
      AND vcca.status = 1
      and vcca.address_type = 3
      and vcca.contact_address_id = (select max(vcca1.contact_address_id)
                                     from ins.v_cn_contact_address vcca1
                                     where  vcca1.contact_id = ac.agent_id
                                            and vcca1.status = 1
                                            and vcca1.address_type = 3)
      and ci.contact_id(+) = ac.agent_id
      and a.leg_pos = tct.id
      and ci.id_type(+) = 1 -- ИНН;
