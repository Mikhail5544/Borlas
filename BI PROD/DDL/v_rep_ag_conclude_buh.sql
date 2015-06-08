create or replace view ins.v_rep_ag_conclude_buh
as
SELECT 
       d_h.num                     "Номер субагентского договора"
       ,nvl(h.DATE_BEGIN
                ,'01.01.1900')               
                                   "Дата начала действия САД"
       ,cat.category_name          "Категория"
       ,c.first_name               "Имя субагента"
       ,c.name                     "Фамилия субагента"
       ,c.middle_name              "Отчество субагента"
       ,nvl(cn.date_of_birth           
               ,'01.01.1900')  
                                   "Дата рождения"
       ,tg.description             "Пол"
       ,passporp.serial_nr
        ||passporp.id_value        "Серия и номер паспорта"              
       ,passporp.place_of_issue    "Кем выдан паспорт"
       ,nvl(passporp.issue_date
                ,'01.01.1900')        
                                   "Дата выдачи паспорта"
       ,ca.REGION_NAME             "Область/район"
       ,ca.PROVINCE_NAME           "Регион"
       ,ca.CITY_NAME               "Город"
       ,ca.DISTRICT_NAME           "Населенный пункт"
       ,ca.STREET_NAME             "Улица"       
       ,ca.HOUSE_NR                "Дом"
       ,ca.BLOCK_NUMBER            "Корпус/строение"
       ,ca.APPARTMENT_NR           "Квартира"
       ,ca.ZIP                     "Индекс"       
       ,pkg_utils.get_aggregated_string(cast(multiset(                                                            
                                                      select cct.telephone_number
                                                      from cn_contact_telephone cct
                                                          ,t_telephone_type ttt
                                                      where ttt.id = cct.telephone_type
                                                            and cct.status = 1 
                                                            and trim(cct.telephone_number) is not null        
                                                            and cct.contact_id = c.contact_id
                                                            and ttt.description  = 'Мобильный' 
                                                             
                                                                                                         
                                                     ) as ins.tt_one_col
                                             ), '; ') "Телефон"      
       ,INN.id_value               "ИНН"
       ,dep.NAME                   "Подразделение"
       ,doc_ad.doc_name            "Документ"       
       ,doc_ad.status_name         "Статус документа"
       

       , nvl(doc_ad.status_date
             ,'01.01.1900')        
                                   "Дата статуса"
       ,dsr_h.name                 "Статус договора"      
  FROM ag_contract_header     h,
       document               d_h, 
       doc_status_ref         dsr_h,        
       ag_contract            a,
       contact                c,
       ag_category_agent      cat,
       department             dep,
       cn_person              cn,
       t_gender               tg,
       
       (   
          select cci_.contact_id
                 , cci_.table_id
                 , cci_.serial_nr
                 , cci_.id_value
                 , cci_.place_of_issue
                 , cci_.issue_date                   
          from cn_contact_ident       cci_,
               t_id_type              tit_
          where  tit_.id             = cci_.id_type 
             and tit_.brief          = 'PASS_RF'
       ) passporp,       
       
       (
          select cci_.contact_id
                 , cci_.table_id
                 , cci_.serial_nr
                 , cci_.id_value
                 , cci_.place_of_issue
                 , cci_.issue_date                   
          from cn_contact_ident       cci_,
               t_id_type              tit_
          where  tit_.id             = cci_.id_type 
             and tit_.brief          = 'INN'
       )INN,  
                            
       (
         select agd_.ag_documents_id,
                agd_.ag_contract_header_id, 
                adt_.description             doc_name,
                --ds_.start_date               status_date,                                
                (
                   select max(ds_1.start_date)
                   from doc_status ds_1
                       ,doc_status_ref dsr_1
                   where ds_1.document_id            = d_.document_id
                         and dsr_1.doc_status_ref_id = ds_1.doc_status_ref_id
                         and ( (ds_1.doc_status_id  != ds_.doc_status_id
                                and dsr_1.brief      =  'CO_ACCEPTED'
                                and dsr_.brief       =  'CO_ACHIVE'                                
                               )
                              or
                               (ds_1.doc_status_id   = ds_.doc_status_id                                
                                and dsr_1.brief      = 'CO_ACCEPTED'
                                and dsr_.brief       = 'CO_ACCEPTED'                                
                               )
                              )
                ) status_date,
                dsr_.name                    status_name
         from ag_documents    agd_
              ,document       d_ 
              ,doc_status     ds_
              ,doc_status_ref dsr_ 
              ,ag_doc_type    adt_               
         where agd_.ag_documents_id = d_.document_id
               and d_.doc_status_id       = ds_.doc_status_id
               and dsr_.doc_status_ref_id = d_.doc_status_ref_id
               and adt_.ag_doc_type_id    = agd_.ag_doc_type_id
               and dsr_.brief             in ('CO_ACCEPTED','CO_ACHIVE')               
               
       ) doc_ad,   
     --doc_status             ds_date,     
     v_cn_contact_address   ca      
        
 WHERE a.contract_id            = h.ag_contract_header_id
   AND a.ag_contract_id         = h.last_ver_id
   AND h.agent_id               = c.contact_id
   AND h.ag_contract_header_id  = d_h.document_id
   AND d_h.doc_status_ref_id    = dsr_h.doc_status_ref_id
   AND dsr_h.brief              = 'CURRENT'
   AND h.is_new                 = 1
   AND cat.ag_category_agent_id = a.category_id
   AND a.agency_id              = dep.department_id (+) 
   AND c.contact_id             = cn.contact_id            
   AND c.contact_id             = passporp.contact_id(+) 
   AND c.contact_id             = inn.contact_id(+)
   AND c.contact_id             = ca.contact_id(+)   
   AND cn.gender                = tg.id(+)   
   AND doc_ad.ag_contract_header_id = h.ag_contract_header_id   
   
   --паспорт с флагом использован и максимальной датой 
   AND (not exists(select  1                                     
                    from cn_contact_ident       cci_,
                         t_id_type              tit_
                    where cci_.contact_id         = c.contact_id
                          and tit_.id             = cci_.id_type 
                          and tit_.brief          = 'PASS_RF'
                          and cci_.termination_date is null      
                                    
                    )   
              OR
             passporp.table_id in 
                               (select x.table_id
                                from (select cci_.contact_id
                                           , cci_.table_id
                                           , cci_.serial_nr
                                           , cci_.id_value
                                           , cci_.place_of_issue
                                           , cci_.issue_date                   
                                           , rank() over(partition by cci_.contact_id order by nvl(cci_.is_used,0) desc
                                                                                            , cci_.issue_date desc
                                                                                            , cci_.table_id desc) rn 
                                    from cn_contact_ident       cci_,
                                         t_id_type              tit_
                                    where tit_.id             = cci_.id_type 
                                          and tit_.brief    = 'PASS_RF'
                                          and cci_.termination_date is null
                                    ) x
                                where  x.contact_id = passporp.contact_id
                                     and rn = 1
                               )    
         )                       
   --ИНН с флагом использования и максимальной датой                      
   AND  (not exists(select 1                  
                    from cn_contact_ident       cci_,
                         t_id_type              tit_
                    where cci_.contact_id         = c.contact_id
                          and tit_.id             = cci_.id_type 
                          and tit_.brief          = 'INN'
                          and cci_.termination_date is null      
                                    
                    )   
              OR
              INN.table_id in 
                               (select x.table_id
                                from (select cci_.contact_id
                                           , cci_.table_id
                                           , cci_.serial_nr
                                           , cci_.id_value
                                           , cci_.place_of_issue
                                           , cci_.issue_date                   
                                           , rank() over(partition by cci_.contact_id order by nvl(cci_.is_used,0) desc
                                                                                               , cci_.issue_date desc
                                                                                               , cci_.table_id desc) rn 
                                    from cn_contact_ident       cci_,
                                         t_id_type              tit_
                                    where tit_.id             = cci_.id_type 
                                          and tit_.brief    = 'INN'
                                          and cci_.termination_date is null
                                    ) x
                                where  x.contact_id = inn.contact_id
                                     and rn = 1
                               )
                          
         )                       
   --Адрес с галочкой поумолчанию, статусом действует и Адрес постоянной регистрации имеет приоритет                                               
   AND  (not exists(select 1
                    from 
                         v_cn_contact_address ca_2     
                    where ca_2.contact_id = ca.contact_id                                         
                    )   
              OR
                ca.contact_address_id =       
                               (select x.contact_address_id
                                from 
                                   (select ca_.contact_address_id, ca_.contact_id
                                           , rank() over(partition by ca_.contact_id 
                                                         order by nvl(ca_.is_default,0)desc
                                                                , nvl(ca_.status,0) desc
                                                                , is_conts_adr desc
                                                                , ca_.contact_address_id desc) rn 
                                    from( 
                                         select ca_2.contact_address_id
                                                , ca_2.contact_id
                                                , nvl(ca_2.is_default,0) is_default
                                                , nvl(ca_2.status,0) status
                                                , decode(ca_2.address_type_name,'Адрес постоянной регистрации',1,0) is_conts_adr
                                         from 
                                          v_cn_contact_address ca_2 
                                        )ca_  
                                    ) x
                                where x.rn = 1
                                      and x.contact_id = ca.contact_id
                               )    
        )                       
    AND doc_ad.ag_documents_id in 
                      (
                       select ag_documents_id
                       from (         
                            select ag_documents_id
                                   ,ag_contract_header_id
                                   ,rank() over(partition by x_.ag_contract_header_id 
                                                order     by x_.ord      desc
                                                            ,x_.doc_date desc
                                                            ) rnk     
                            from  (                                    
                                    select ad_.ag_documents_id
                                          ,ad_.ag_contract_header_id
                                          ,ad_.doc_date
                                          ,1 ord
                                    from  ag_documents     ad_
                                         ,ag_doc_type     dt_
                                         ,ag_props_change pc_
                                         ,ag_props_type   pt_
                                    where  ad_.ag_doc_type_id      = dt_.ag_doc_type_id
                                      and dt_.brief                 = 'CAT_CHG'
                                      and ad_.ag_documents_id       = pc_.ag_documents_id
                                      and pc_.ag_props_type_id      = pt_.ag_props_type_id
                                      and pt_.brief                 = 'CAT_PROP'
                                      and pc_.new_value             = '2'                         --Агент  
                                      
                                     union
                                     
                                     select ad_.ag_documents_id
                                           ,ad_.ag_contract_header_id
                                           ,ad_.doc_date
                                           ,0 ord
                                     from ag_documents   ad_
                                         ,ag_doc_type    dt_  
                                     where ad_.ag_doc_type_id      = dt_.ag_doc_type_id
                                       and dt_.brief                 = 'NEW_AD'
                                   ) x_
                            )x  
                            where x.ag_contract_header_id = doc_ad.ag_contract_header_id
                                  and rnk = 1
                     );

grant select on ins.v_rep_ag_conclude_buh to ins_eul;      
         
   
