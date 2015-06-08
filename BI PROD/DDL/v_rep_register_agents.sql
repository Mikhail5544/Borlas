CREATE OR REPLACE VIEW V_REP_REGISTER_AGENTS AS
SELECT        
       cn.first_name        "Имя"
     , cn.middle_name       "Отчество"
     , cn.name              "Фамилия"
     , null                 "Номер Сертификата "
     , null                 "Дата истечения Сертификата"
     , 4                    "Код Страховой Компании"
     , NVL(rpad(substr(ad.code,1,2),13,'0'),(SELECT tk.code 
                                               FROM ins.t_kladr tk 
                                              WHERE tk.code like '__00000000000'
                                                AND tk.name=ad.province_name))  "Код КЛАДР"
     , case when dsr_ach.brief = 'CURRENT' then 10
       else 1
       end                  "Код статуса Агента"
     , 'Все продукты страхования жизни'              "Виды страхования "
     , d_ach.num            "Номер действующего АД"
     , ach.date_begin       "Дата заключения АД"
     , (
         select cci_.id_value
           from ins.cn_contact_ident cci_
          where cci_.table_id = pkg_contact.get_contact_document_id(cn.contact_id,'INN')           
            and cci_.contact_id = cn.contact_id
       )                    "ИНН Агента"
     , (
         select cci_.id_value
           from ins.cn_contact_ident cci_
          where cci_.table_id = pkg_contact.get_contact_document_id(cn.contact_id,'PENS')           
            and cci_.contact_id = cn.contact_id
       )                    "СНИЛС Агента"
     , null                 "Иная информация об Агенте"
     , dsr_ach.name         "Статус АД"
     , dep.name             "Агентство"     
     ,(        
      
         ( 
           select max(agd_2.doc_date)
           from ag_documents     agd_2 
              , ag_doc_type      adt_2
              , document         d_agd_2 
              , doc_status_ref   dsr_agd_2 
          where agd_2.ag_contract_header_id = ach.ag_contract_header_id
            and agd_2.ag_doc_type_id        = adt_2.ag_doc_type_id
            and agd_2.ag_documents_id       = d_agd_2.document_id
            and dsr_agd_2.doc_status_ref_id = d_agd_2.doc_status_ref_id
            --and dsr_agd_2.brief             = 'CONFIRMED'
            --
            and adt_2.brief                 = 'AGR_PERS_DATA'
                                             
                                              
         )
      )                       "Дата документа на обработку"
      ,(           
       select dsr_agd_.name
         from ag_documents     agd_ 
            , ag_doc_type      adt_
            , document         d_agd_
            , doc_status_ref   dsr_agd_ 
        where agd_.ag_contract_header_id = ach.ag_contract_header_id
          and agd_.ag_doc_type_id        = adt_.ag_doc_type_id
          and adt_.brief                 = 'AGR_PERS_DATA'
          and agd_.ag_documents_id       = d_agd_.document_id
          and dsr_agd_.doc_status_ref_id = d_agd_.doc_status_ref_id
          AND rownum                     = 1          
          and agd_.doc_date              = 
                                         ( 
                                           select max(agd_2.doc_date)
                                           from ag_documents     agd_2 
                                              , ag_doc_type      adt_2                                              
                                          where agd_2.ag_contract_header_id = ach.ag_contract_header_id
                                            and agd_2.ag_doc_type_id        = adt_2.ag_doc_type_id                                            
                                            --
                                            and adt_2.brief                 = 'AGR_PERS_DATA'
                                             
                                              
                                         )
      )                       "Статус документа на обработку",
      sc.description          "Канал Продаж"            
     
     
  FROM ins.ag_contract        ac
      ,ins.department         dep
      ,ins.organisation_tree  ot
      ,ins.sales_dept_header  sdh
      ,ins.sales_dept         sd
      ,ins.t_tap_header       th
      ,ins.t_tap              tp
      ,ins.ag_contract_header ach
      ,ins.document           d_ach 
      ,ins.doc_status_ref     dsr_ach
      ,ins.contact            cn
      
      ,t_sales_channel        sc
      ,ins.ag_category_agent  aca
      
      ,ven_cn_entity_address ea
      ,cn_address ad

      

WHERE dep.department_id       = ac.agency_id
  AND ot.organisation_tree_id = dep.org_tree_id
  AND sdh.organisation_tree_id = ot.organisation_tree_id
  AND sd.sales_dept_id         = sdh.last_sales_dept_id
  AND th.t_tap_header_id       = sd.t_tap_header_id
  AND tp.t_tap_header_id       = th.last_tap_id
  AND ach.last_ver_id          = ac.ag_contract_id
  AND cn.contact_id            = ach.agent_id
  AND ac.category_id = aca.ag_category_agent_id

  and ach.ag_contract_header_id = d_ach.document_id
  and dsr_ach.doc_status_ref_id = d_ach.doc_status_ref_id
  and ac.ag_sales_chn_id        = sc.id
  and ach.is_new                = 1
  
  and sd.ent_id                 = ea.ure_id
  and sd.sales_dept_id          = ea.uro_id
  and ea.address_id             = ad.id;
