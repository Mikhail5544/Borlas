create or replace force view v_request_112288 as
select sc.description                        as sales_channel
      ,pp.pol_ser
      ,pp.pol_num
      ,doc_a.num                             as ad_num
      ,ent.obj_name(246,ch.agent_id)         as agent_name
      ,doc.get_doc_status_name(pp.policy_id) as last_ver_status
      ,c.obj_name_orig                       as contact_name
      ,prod.description as product_name
      ,(select tel.telephone_number tel
          from ins.t_telephone_type tt,
               ins.cn_contact_telephone tel
          where tel.contact_id = c.contact_id
            and tt.id          = tel.telephone_type
            and tt.description = 'Домашний телефон'
            and length(tel.telephone_number) > 3
            and rownum = 1
       ) tel_cont,
       (select tel.telephone_number tel
          from ins.t_telephone_type tt,
               ins.cn_contact_telephone tel
          where tel.contact_id = c.contact_id
            and tt.id          = tel.telephone_type
            and tt.description = 'Рабочий телефон'
            and length(tel.telephone_number) > 3
            and rownum = 1
       ) tel_own,
       (select tel.telephone_number tel
          from ins.t_telephone_type tt,
               ins.cn_contact_telephone tel
         where tel.contact_id = c.contact_id
           and tt.id          = tel.telephone_type
           and tt.description = 'Мобильный'
           and length(tel.telephone_number) > 3
           and rownum = 1
       ) tel
  from ins.p_pol_header         ph   --Шапка договора страхования
      ,ins.p_policy             pp   --Версии ДС
      ,ins.p_policy_agent_doc   pad  --Связь агента и шапки ДС
      ,ins.t_product            prod --Справочник продуктов
      ,ins.p_policy_contact     ppc  --Связь контактов с версией
      ,ins.t_contact_pol_role   prl  --Справочник ролей контактов
      ,ins.contact              c
      ,ins.ag_contract_header   ch
      ,ins.department           dp
      ,ins.t_sales_channel      sc
      ,ins.document             doc_a
 where ph.policy_header_id        = pp.pol_header_id
   and ph.policy_header_id        = pad.policy_header_id
   and pp.pol_header_id           = pad.policy_header_id
   and ph.product_id              = prod.product_id
   and ppc.policy_id              = pp.policy_id
   and ppc.contact_policy_role_id = prl.id
   and pad.ag_contract_header_id  = ch.ag_contract_header_id
   and ch.ag_contract_header_id   = doc_a.document_id
   and ppc.contact_id             = c.contact_id
   and prl.description            = 'Страхователь'
   and ph.agency_id               = dp.department_id
   and dp.name                    = 'Внешние агенты и агентства'
   and ph.sales_channel_id        = sc.id
   and sc.description             in ('Брокерский без скидки', 'Брокерский')
   and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
   and ins.pkg_policy.get_last_version(ph.policy_header_id)    = pp.policy_id
;

