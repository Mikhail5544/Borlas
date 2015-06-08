create or replace view v_sales_dept_mn_for_1c as
select to_char(sh.universal_code,'FM0009') as universal_code -- Универсальный код подразделения
      ,co.contact_id    -- Код Контакта (менеджера или директора)
      ,co.name          -- Фамилия
      ,co.first_name    -- Имя
      ,co.middle_name   -- Отчество
      ,ps.date_of_birth -- Дата рождения
      ,(select min(do.doc_date)
          from ag_props_change pc
              ,ag_documents    do
         where pc.ag_props_type_id      = 3 -- Агентство
           and pc.ag_documents_id       = do.ag_documents_id
           and do.ag_contract_header_id = ch.ag_contract_header_id
           and pc.new_value             = dp.department_id
       ) as first_day_at_agency -- Дата с которой агент в подразделении
  from sales_dept_header  sh
      ,department         dp
      ,ag_contract        cn
      ,ag_contract_header ch
      ,document           dc
      ,doc_status_ref     dsr
      ,contact            co
      ,cn_person          ps
 where sh.organisation_tree_id  = dp.org_tree_id
   and dp.department_id         = cn.agency_id
   and cn.ag_contract_id        = ch.last_ver_id
   and ch.ag_contract_header_id = dc.document_id
   and dc.doc_status_ref_id     = dsr.doc_status_ref_id
   and dsr.brief                = 'CURRENT'
   and ch.is_new                = 1
   and ch.agent_id              = co.contact_id
   and co.contact_id            = ps.contact_id
   and cn.category_id in (select ca.ag_category_agent_id
                            from ag_category_agent ca
                           where ca.sort_id >= 2 -- Выше агента
                         );
