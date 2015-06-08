create or replace force view v_agent_current_status as
(   select
         ah.ag_contract_header_id as HEAD_ID
         , doc.get_doc_status_brief(ah.ag_contract_header_id,PKG_AGENT_1.get_date) as HEAD_STATUS
         , ac.ag_contract_id as LAST_VER_ID
         , doc.get_doc_status_brief(ac.ag_contract_id,PKG_AGENT_1.get_date) as LAST_VER_STATUS
         , ac.category_id as CATEGORY_ID
         , ah.num as NUM_CONTR
         , c1.obj_name_orig as NAME_AGENT
         , c2.name as NAME_AGENCY
         , ca.category_name as NAME_CATEG
         , ac_cat.date_begin as DATE_CATEG
         , sa.name as NAME_STATUS
         , sh.stat_date as DATE_STATUS
         from ven_ag_contract_header ah
         join (select max(a1.num) num, a1.contract_id
               from ven_ag_contract a1
               where a1.date_begin < = PKG_AGENT_1.get_date
               group by  a1.contract_id ) ac_dat on (ac_dat.contract_id = ah.ag_contract_header_id)
         join  ven_ag_contract ac on (ac.contract_id = ah.ag_contract_header_id and ac.num = ac_dat.num)
         join  ven_ag_category_agent ca on (ca.ag_category_agent_id=ac.category_id and ca.brief in ('AG','MN'))
         join  ven_ag_contract ac_cat on (ac_cat.contract_id = ah.ag_contract_header_id)
         left join (select  max(h.num) num, h.ag_contract_header_id
                    from  ven_ag_stat_hist h
                    where h.stat_date < = PKG_AGENT_1.get_date
                    group by h.ag_contract_header_id) sh_all on (sh_all.ag_contract_header_id=ah.ag_contract_header_id)
         left join ven_ag_stat_hist sh on (sh.ag_contract_header_id=ah.ag_contract_header_id and sh_all.num = sh.num)
         left join ven_ag_stat_agent sa on (sa.ag_stat_agent_id=sh.ag_stat_agent_id)
         left join ven_contact c1 on (ah.agent_id=c1.contact_id)
         left join ven_department c2 on (ah.agency_id=c2.department_id)
         where  ac_cat.num = (select min (a2.num)
                              from ven_ag_contract a2
                              where a2.contract_id=ah.ag_contract_header_id
                              and a2.category_id=ac.category_id)
           and  doc.get_doc_status_brief(ac.ag_contract_id, PKG_AGENT_1.get_date)in ('CURRENT','PRINTED','NEW')
           and  doc.get_doc_status_brief(ah.ag_contract_header_id, PKG_AGENT_1.get_date)in ('CURRENT','PRINTED','NEW')
           and  ah.ag_contract_templ_k = 0 );

