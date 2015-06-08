create or replace force view v_ad_with_bank_req as
select ach.num "Номер АД",
       ent.obj_name('CONTACT',ach.agent_id) "ФИО Агента",
       ent.obj_name('DEPARTMENT',ach.agency_id) "Агентство",
       ach.date_begin "Дата начала АД",
       cb.bank_name    "Банк",
       cb.account_nr   "Расчетный счет",
       cb.account_corr "Корреспондентский счет",
       cci.serial_nr      "Серия ПР",
       cci.id_value       "№ платёжного реквизита",
       ent.obj_name('T_COUNTRY',cci.country_id) "Страна",
       cci.place_of_issue "Выдан",
       cci.issue_date     "Дата выдачи"

  from ven_ag_contract_header ach,
       cn_contact_bank_acc    cb,
       cn_contact_ident   cci,
       t_id_type          it
 where doc.get_doc_status_brief(ach.ag_contract_header_id) in ('PRINTED','CURRENT')
   and cb.contact_id = ach.agent_id
   and cci.contact_id = ach.agent_id
   and it.id = cci.id_type
   and it.description = 'Платежные реквизиты';

