CREATE OR REPLACE VIEW V_DECLINED_AGENTS AS
select distinct 
       ach.num as "Номер договора"
       , c.obj_name_orig "ФИО агента"
       , p.date_of_birth "Дара рождения"
       , ad.doc_date "Дата документа Расторжение АД"
       , trunc(ds.start_date,'DD') "Дата статуса Расторжение АД"
/*       , (select abp.account 
          from ins.ag_bank_props abp
          where abp.ag_contract_header_id = ach.ag_contract_header_id
                and abp.bank_id = 836996) */
       , abp.account         as "Счет ХКФ"
       , tsc.description as "Канал продаж"
       , tct.description as "Юр. статус"
from  ins.ven_ag_contract_header ach
     ,ins.t_sales_channel tsc
     ,ins.ag_documents        ad
     ,ins.ag_doc_type         adt
     ,ins.contact c
     ,ins.cn_person p
     ,(select abp1.ag_contract_header_id
              , abp1.account 
       from ins.ag_bank_props abp1 
       where abp1.bank_id = 836996) abp
     ,ins.document d
     ,ins.doc_status ds
     ,ins.ag_contract ac
     ,ins.t_contact_type                tct
     ,ins.ag_contract                   a
where 1=1--d.document_id = ach.ag_contract_header_id
      and tsc.brief in ('MLM','SAS','SAS 2') --'DSF'
      and ach.last_ver_id = ac.ag_contract_id
      and ac.category_id = 2
      and ach.t_sales_channel_id = tsc.id
      and ad.ag_contract_header_id = ach.ag_contract_header_id
      and adt.ag_doc_type_id = ad.ag_doc_type_id
      and adt.description = 'Расторжение АД'
      and c.contact_id = ach.agent_id
      and p.contact_id = c.contact_id
      and abp.ag_contract_header_id (+) = ach.ag_contract_header_id
      and ad.ag_documents_id = d.document_id
      and ds.doc_status_id = d.doc_status_id
      and ach.last_ver_id = a.ag_contract_id
      and a.leg_pos = tct.id
      and ds.start_date between (SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'declined_agents'
                                            AND r.param_name = 'DATE_FROM')
                                        AND (SELECT r.param_value
                                               FROM ins_dwh.rep_param r
                                              WHERE r.rep_name = 'declined_agents'
                                                AND r.param_name = 'DATE_TO')
--      and ds.start_date between to_date('13.11.2012','dd.mm.yyyy') AND to_date('10.12.2012','dd.mm.yyyy');
