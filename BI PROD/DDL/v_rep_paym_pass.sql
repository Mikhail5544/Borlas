create or replace view v_rep_paym_pass
as       
  select 
      main.payment_num                  as "Номер ЭПГ"
     ,main.epg_amount                   as "Сумма ЭПГ"
     ,ph.ids                            as "ИДС"
     ,pol_num                           as "Номер договора"
     ,notice_num                        as "Номер заявления"
     ,vi.contact_name                   as "Страхователь"
     ,(    
          select cct.telephone_number
          from ven_cn_contact_telephone cct
          where cct.contact_id = vi.contact_id
                and cct.status = 1
                and rownum     = 1
       )                                as "Телефон"
     ,main.due_date                     as "Дата ЭПГ"  
  from(              
       --ЭПГ в статусе К оплате
       SELECT dd.parent_amount          as epg_amount
            ,ap_d.num                   as payment_num                        
            ,ap.due_date                as due_date
            ,pp.pol_header_id           as pol_header_id
            ,pp.policy_id               as policy_id
            ,pp.pol_num                 as pol_num
            ,pp.notice_num              as notice_num
       FROM  p_policy                   pp,
             doc_doc                    dd,
             ac_payment                 ap,
             document                   ap_d,
             doc_templ                  dt,
             doc_status_ref             ap_dsr 
       WHERE 
             pp.policy_id               = dd.parent_id
         AND dd.child_id                = ap.payment_id
         AND ap.payment_id              = ap_d.document_id
         AND ap_d.doc_templ_id          = dt.doc_templ_id
         AND ap_dsr.doc_status_ref_id   = ap_d.doc_status_ref_id
         AND dt.brief                   = 'PAYMENT'
         AND ap_dsr.brief               = 'TO_PAY'     
         --and pp.pol_header_id = 841461                                                               
    UNION ALL      
      --ЭПГ, оплаченные A7 и PD4 
      SELECT epg_amount
             ,payment_num
             ,due_date
             ,pol_header_id
             ,policy_id
             ,pol_num
             ,notice_num
      FROM(  
                 SELECT  dd.parent_amount            as epg_amount 
                       ,
                       (select (nvl(sum(apc.amount + apc.comm_amount),0) --ПД/А7 сумма
                                 -  nvl(sum(dso_ppvh.set_off_amount),0) --зачет ППвх сумма
                               )as diff
                        from 
                        
                             doc_set_off                dso,
                             ac_payment                 apd,
                             doc_doc                    ddc,
                             ac_payment                 apc,
                             doc_status_ref             dsr_apc,  
                             document                   dc,                                 
                             ac_payment_templ           pt,
                             doc_templ                  dt, 
                             ins.ven_ac_payment             ppvh,
                             ins.doc_set_off            dso_ppvh
                             
                             ,ins.payment_register_item pri 
                        where  dd.child_id                = dso.parent_doc_id
                           and apd.payment_id             = dso.child_doc_id
                           and apd.payment_templ_id       = pt.payment_templ_id
                           and pt.brief                   IN('A7', 'PD4')
                           and ddc.parent_id              = apd.payment_id
                           and apc.payment_id             = ddc.child_id
                           and apc.payment_id             = dc.document_id
                           and dc.doc_templ_id            = dt.doc_templ_id
                           and dt.brief                   IN('A7COPY', 'PD4COPY')
                           and dsr_apc.doc_status_ref_id  = dc.doc_status_ref_id
                           and dsr_apc.brief              != 'ANNULATED'                        
                           and dso_ppvh.parent_doc_id  =  apc.payment_id
                           and dso_ppvh.child_doc_id   =  ppvh.payment_id
                           
                           and pri.ac_payment_id = ppvh.payment_id
                           and rownum = 1
                           
                           )                    as diff                                
                    ,ap.num                     as payment_num
                    ,/*ap.due_date*/
                     to_date('01.01.1900'
                           , 'dd.mm.yyyy')      as due_date
                    ,pp.pol_header_id           as pol_header_id
                    ,pp.policy_id               as policy_id
                    ,pp.pol_num                 as pol_num
                    ,pp.notice_num              as notice_num
               FROM  p_policy                   pp,                                                              
                     doc_doc                    dd,
                     ven_ac_payment             ap                     
               WHERE 
                     pp.policy_id               = dd.parent_id                           
                 AND ap.payment_id              = dd.child_id
                 --and pp.pol_header_id = 841461
             )a_1

      WHERE diff != 0 --А7/ПД4 не привязаны ППвх (либо привязаны на сумму меньше А7/ПД4);  
     ) MAIN
      ,p_pol_header               ph
      ,v_pol_issuer               vi                  
            
  where ph.policy_header_id        = main.pol_header_id
    AND vi.policy_id               = main.policy_id            
  order by ph.ids, main.notice_num, main.payment_num;
grant select on v_rep_paym_pass to INS_READ;
grant select on v_rep_paym_pass to INS_EUL;
