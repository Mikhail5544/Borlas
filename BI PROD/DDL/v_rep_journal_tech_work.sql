create or replace view v_rep_journal_tech_work
as
select   jtw.journal_tech_work_id              as "ИД работы"
       , case jtw.work_type 
          when 0 then 'Технические работы'
          when 1 then 'Рассмотрение в СБ'
          when 2 then 'Рассмотрение в ЮУ'  
         end                                   as "Тип работы"
       , jtw.start_date                        as "Дата начала работы"
       , jtw.end_date                          as "Дата окончания работы"
       , su.name                               as "Автор работы"
       , ts.name                               as "Отдел, ведущий работы"
       , twr.description                       as "Причина работы"
       , jtw.comments                          as "Комментарий"
       , ph.ids                                as "ИДС"    
       , pp.pol_num                            as "Номер договора"
       , pp.notice_num                         as "Номер заявления"
       , vi.contact_name                       as "Страхователь"
       , (  select dep_.name
            from   p_policy_agent_doc pad_
                 , document           d_pad_
                 , doc_status_ref     dsr_pad_
                 , ag_contract_header ach_
                 , department         dep_
                 , p_pol_header       ph_
            where pad_.policy_header_id        = ph_.policy_header_id
              and pad_.ag_contract_header_id   = ach_.ag_contract_header_id
              and pad_.p_policy_agent_doc_id   = d_pad_.document_id
              and ach_.agency_id               = dep_.department_id
              and d_pad_.doc_status_ref_id     = dsr_pad_.doc_status_ref_id
              and dsr_pad_.brief							 = 'CURRENT'
              and ph_.ids            				   = ph.IDS)
                                               as "Агентство"
       , ent.obj_name('T_PAYMENT_TERMS'
                      ,pp.paymentoff_term_id)  as "Периодичность уплаты взносов"
       --ДАТА ПЕРЕВОДА В ДЕЙСТВУЮЩИЙ               
       , (
           select   ds_.start_date
             from   ins.doc_status             ds_ 
                  , ins.doc_status_ref         dsr_  
            where   ds_.document_id            = jtw.journal_tech_work_id
              and   ds_.doc_status_ref_id      = dsr_.doc_status_ref_id
              and   dsr_.brief                 = 'CURRENT'
         ) cur_date
       --ДАТА СТАТУСА СЛЕДУЮЩЕГО ЗА ДЕЙСТВУЮЩИМ  
       , nvl((
               select   min(ds_.start_date)
                 from   ins.doc_status             ds_ 
                      , ins.doc_status_ref         dsr_  
                where   ds_.document_id            = jtw.journal_tech_work_id
                  and   ds_.doc_status_ref_id      = dsr_.doc_status_ref_id
                  and   dsr_.brief                 != 'CURRENT'
                  and   ds_.start_date             > (
                                                       select ds_1.start_date
                                                       from   ins.doc_status             ds_1
                                                            , ins.doc_status_ref         dsr_1  
                                                      where   ds_1.document_id           = ds_.document_id
                                                        and   ds_1.doc_status_ref_id     = dsr_1.doc_status_ref_id
                                                        and   dsr_1.brief                = 'CURRENT'                                    
                                                     )
              ),'31.12.2999'
         ) aft_cur_date  
         
  from   ins.ven_journal_tech_work             jtw
       , ins.ven_sys_user                      su
       , ins.t_subdivisions                    ts
       , ins.t_work_reason                     twr
       , ins.p_pol_header                      ph 
       , ins.p_policy                          pp 
       , ins.v_pol_issuer                      vi 
       
 where jtw.author_id                           = su.sys_user_id
   and jtw.t_subdivisions_id                   = ts.t_subdivisions_id
   and jtw.t_work_reason_id                    = twr.t_work_reason_id
   and jtw.policy_header_id                    = ph.policy_header_id
   and ph.policy_id                            = pp.policy_id                            
   and pp.policy_id                            = vi.policy_id
   and not exists(
                   select 1
                     from   ins.doc_status     ds_1
                          , ins.doc_status_ref dsr_1  
                    where ds_1.document_id            = jtw.journal_tech_work_id
                      and ds_1.doc_status_ref_id      = dsr_1.doc_status_ref_id
                      and dsr_1.brief                 = 'CANCEL' 
                 )
   
   
 order by ph.ids, jtw.start_date;
grant select on v_rep_journal_tech_work to INS_READ;
grant select on v_rep_journal_tech_work to INS_EUL;
