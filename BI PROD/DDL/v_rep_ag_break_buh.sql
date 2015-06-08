create or replace view ins.v_rep_ag_break_buh
as  
  SELECT 
       d_h.num                       "Номер субагентского договора"
       ,ent.obj_name('CONTACT'
                    , c.contact_id)  "ФИО"
       ,cat.category_name            "Категория"       
       ,nvl(cn.date_of_birth
                ,'01.01.1900')           
                                     "Дата рождения"
       ,dep.NAME                     "Подразделение"                     
       ,nvl(doc_ad.doc_date              
                ,'01.01.1900') 
                                     "Дата документа"
       ,dsr_h.name                   "Статус договора"  
       ,doc_ad.status_date           "Дата статуса"     
       ,(
          select bp_.account
          from ven_ag_bank_props bp_                         
               ,contact c_
               ,t_contact_type ct_ 
          where bp_.ag_contract_header_id = h.ag_contract_header_id
            and bp_.bank_id               = c_.contact_id
            and c_.contact_type_id        = ct_.id
            and ct_.brief                 = 'КБ'
            and bp_.enable                = 1
            and c_.obj_name_orig          = 'ООО "ХКФ БАНК"'
            and rownum = 1
         )                           "Реквизиты"
  FROM ag_contract_header     h,
       document               d_h, 
       doc_status_ref         dsr_h,        
       ag_contract            a,
       contact                c,
       ag_category_agent      cat,
       department             dep,
       cn_person              cn,
       (
         select agd_.ag_documents_id,
                agd_.ag_contract_header_id, 
                agd_.doc_date,
                adt_.description             doc_name,
                ds_.start_date               status_date,
                dsr_.name                    status_name,
                dsr_.brief                
         from ag_documents    agd_
              ,document       d_ 
              ,doc_status     ds_
              ,doc_status_ref dsr_ 
              ,ag_doc_type    adt_ 
         where agd_.ag_documents_id = d_.document_id
               and d_.doc_status_id       = ds_.doc_status_id
               and dsr_.doc_status_ref_id = d_.doc_status_ref_id
               and adt_.ag_doc_type_id    = agd_.ag_doc_type_id               
       ) doc_ad
       
     
   
 WHERE a.contract_id            = h.ag_contract_header_id
   AND a.ag_contract_id         = h.last_ver_id
   AND h.agent_id               = c.contact_id
   AND h.ag_contract_header_id  = d_h.document_id
   AND d_h.doc_status_ref_id    = dsr_h.doc_status_ref_id
   AND dsr_h.brief              = 'BREAK'
   AND h.is_new                 = 1
   AND cat.ag_category_agent_id = a.category_id
   AND a.agency_id              = dep.department_id (+) 
   AND c.contact_id             = cn.contact_id            
   AND h.ag_contract_header_id  = doc_ad.ag_contract_header_id
   AND doc_ad.ag_documents_id   = (SELECT x.ag_documents_id
                                   FROM 
                                      (
                                        SELECT  doc_ag_.ag_documents_id
                                               ,doc_ag_.ag_contract_header_id
                                               ,rank() over(partition by doc_ag_.ag_contract_header_id 
                                                            order     by doc_ag_.doc_date desc
                                                                        ,doc_ag_.ag_documents_id desc) rnk    
                                        FROM ag_documents doc_ag_
                                            ,ag_doc_type  agt_
                                        WHERE doc_ag_.ag_doc_type_id    = agt_.ag_doc_type_id
                                              AND agt_.brief                = 'BREAK_AD'
                                      ) x
                                   WHERE x.ag_contract_header_id = h.ag_contract_header_id
                                         AND x.rnk = 1
                                   );

   
