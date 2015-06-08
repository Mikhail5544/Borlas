create materialized view INS_DWH.MV_CR_AGENTS
refresh force on demand
as
select agch.ag_contract_header_id, -- ид договора
       agc.ag_contract_id, --ид агентского договора
       agch.num, -- номер агентского договора
       ins.ent.obj_name('CONTACT',agch.agent_id) as agent, --фио агента или название брокера
       d.name, -- агенство
       ins.ent.obj_name('CONTACT',agchLead.agent_id) as agent_leader,-- руководитель агента
       agch.date_begin, --дата начала АД
      -- дата завершения АД (дата статуса закрыт, расторгунут, отменен)
      pkg_rep_utils_ins11.get_ag_contract_end_date(agc.ag_contract_id) as end_date,
      ins.pkg_contact.get_birth_date(agch.agent_id) as birth_date, -- дата рождения агента
      -- /*
      -- ИНН
      ins.pkg_contact.get_ident_seria(agch.agent_id,'INN')||
      ins.pkg_contact.get_ident_number(agch.agent_id,'INN')as INN,
      --*/
      -- /*
      -- номер пенсионного свидетельства
      ins.pkg_contact.get_ident_seria(agch.agent_id,'PENS')||
      ins.pkg_contact.get_ident_number(agch.agent_id,'PENS')as PENS,
      --*/
       decode(agc.leg_pos,1,'ДА','НЕТ') as is_pbul,-- признак ПБОЮЛ
       ins.doc.get_doc_status_name(agc.ag_contract_id) as doc_status,-- статус договора
       ins.ent.obj_name('CONTACT',agchRecr.agent_id) as agent_recruter, -- рекрутер
       ins.pkg_contact.get_address_name(ins.pkg_contact.get_address_by_brief(agch.agent_id,'CONST')) as const_address, -- адрес по паспорту
       ins.pkg_contact.get_address_name(ins.pkg_contact.get_address_by_brief(agch.agent_id,'POSTAL')) as post_address, -- адрес почтовый
       decode(agCatAg.Brief,'BZ',decode(sCh.brief,'MLM','НЕТ','ДА'),'НЕТ') as is_outside, -- признак внешнего агента
       decode(agCatAg.Brief,null,null,decode (sCh.brief,'BR','ДА','НЕТ')) as is_broker, -- признак брокера
       ins.pkg_contact.get_phone_number(agc.ag_contract_id, 'HOME'),-- домашний телефон
       ins.pkg_contact.get_phone_number(agc.ag_contract_id, 'MOB'),-- мобильный телефон
       d.code,-- префикс (код агенства)
       ins.pkg_contact.get_citizenry(agc.ag_contract_id), -- гражданство агента
       agCatAg.category_name, -- категория агента
       ins.pkg_contact.get_primary_doc(agc.ag_contract_id) as document, -- тип документа агента
      -- /*
       -- номер документа агента
      ins.pkg_contact.get_ident_seria(agch.agent_id, t.brief )||
      ins.pkg_contact.get_ident_number(agch.agent_id,t.brief) as doc_number,
      --*/
       ins.pkg_rep_utils.get_type_agent_code(agch.ag_contract_header_id) as type_ag_code,--тип агента (код)
       ins.pkg_rep_utils.get_type_agent_name(agch.ag_contract_header_id)as type_ag_name,--тип агента
      -- статус агента
      ins.pkg_agent_1.get_agent_status_name_by_date(agch.ag_contract_header_id,sysdate) as agent_status
from ins.ven_ag_contract_header agch
join ins.ven_ag_contract agc on agc.ag_contract_id = agch.last_ver_id
left join ins.ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
left join ins.ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
left join ins.ven_ag_contract agRecr on agRecr.ag_contract_id = agc.contract_recrut_id
left join ins.ven_ag_contract_header agchRecr on agchRecr.ag_contract_header_id = agRecr.contract_id
left join ins.ven_department d on d.department_id = agch.agency_id
left join ins.ven_t_sales_channel sCh on sCh.id = agch.t_sales_channel_id
left join ins.ven_ag_category_agent agCatAg on agCatAg.ag_category_agent_id = agc.category_id
left join ins.t_id_type t on t.description = ins.pkg_contact.get_primary_doc(agc.ag_contract_id);

