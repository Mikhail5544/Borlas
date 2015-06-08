create or replace force view v_rep_stoped_policy as
select 
       ph.ids,
       prod.description product,
       cpol.obj_name_orig holder,
       NVL(adr.name, pkg_contact.get_address_name(adr.id)) address_holder,
       ci.obj_name_orig insurer,
       NVL(adri.name, pkg_contact.get_address_name(adri.id)) address_insurer,
       cb.obj_name_orig beneficiary,
       ph.start_date start_date_header,
       pp.end_date end_date_version,
       pp.decline_date,
       pkg_policy.get_last_version_status(ph.policy_header_id) last_status,
       (select sum(pc.premium)
       from p_cover pc
       where pc.as_asset_id = a.as_asset_id) ins_premium,
       trm.description period_term,
       pkg_renlife_utils.First_unpaid(ph.policy_header_id,1) last_paid,
       pkg_renlife_utils.First_unpaid(ph.policy_header_id,2) first_unpaid,
       f.brief currency,
       mt.description type_paid,
       dep.name department,
       agt.num agent_num,
       agt.agent_name,
       agt.adr_agent,
       agt.num_leader,
       agt.leader_name,
       agt.adr_leader
from p_pol_header ph,
     department dep,
     p_policy pp,
     t_payment_terms trm,
     t_product prod,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol,
     ins.cn_address adr,
     as_asset a,
     as_assured ass,
     contact ci,
     ins.cn_address adri,
     ven_as_beneficiary ben,
     contact cb,
     fund f,
     t_collection_method mt,
     (select pad.policy_header_id, 
             agh.num, 
             ca.obj_name_orig agent_name, 
             NVL(adra.name, pkg_contact.get_address_name(adra.id)) adr_agent,
             aghl.num num_leader,
             cal.obj_name_orig leader_name,
             NVL(adral.name, pkg_contact.get_address_name(adral.id)) adr_leader
     from ins.p_policy_agent_doc pad,
          ven_ag_contract_header agh,
          ag_contract ag,
          contact ca,
          ins.cn_address adra,
          ag_contract agl,
          ven_ag_contract_header aghl,
          contact cal,
          ins.cn_address adral
     where pad.ag_contract_header_id = agh.ag_contract_header_id
           and agh.agent_id = ca.contact_id
           and agh.is_new = 1
           and ag.contract_id = agh.ag_contract_header_id
           and sysdate between ag.date_begin and ag.date_end
           and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           and pkg_contact.get_primary_address(ca.contact_id) = adra.ID(+)
           and ag.contract_leader_id = agl.ag_contract_id(+)
           and agl.contract_id = aghl.ag_contract_header_id(+)
           and aghl.agent_id = cal.contact_id(+)
           and pkg_contact.get_primary_address(cal.contact_id) = adral.ID(+)
     union
     select pad.policy_header_id, 
             agh.num, 
             ca.obj_name_orig agent_name, 
             NVL(adra.name, pkg_contact.get_address_name(adra.id)) adr_agent,
             aghl.num num_leader,
             cal.obj_name_orig leader_name,
             NVL(adral.name, pkg_contact.get_address_name(adral.id)) adr_leader
     from ins.p_policy_agent_doc pad,
          ven_ag_contract_header agh,
          ag_contract ag,
          contact ca,
          ins.cn_address adra,
          ag_contract agl,
          ven_ag_contract_header aghl,
          contact cal,
          ins.cn_address adral
     where pad.ag_contract_header_id = agh.ag_contract_header_id
           and agh.agent_id = ca.contact_id
           and nvl(agh.is_new,0) = 0
           and ag.ag_contract_id = agh.last_ver_id
           and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           and pkg_contact.get_primary_address(ca.contact_id) = adra.ID(+)
           and ag.contract_leader_id = agl.ag_contract_id(+)
           and agl.contract_id = aghl.ag_contract_header_id(+)
           and aghl.agent_id = cal.contact_id(+)
           and pkg_contact.get_primary_address(cal.contact_id) = adral.ID(+)
     ) agt
where pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
      and pp.payment_term_id = trm.id
      and ph.agency_id = dep.department_id(+)
      and ph.product_id = prod.product_id
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and pkg_contact.get_primary_address(cpol.contact_id) = adr.ID(+)
      and pp.policy_id = a.p_policy_id
      and a.as_asset_id = ass.as_assured_id
      and ci.contact_id = ass.assured_contact_id
      and pkg_contact.get_primary_address(ci.contact_id) = adri.ID(+)
      and ben.as_asset_id(+) = a.as_asset_id
      and ben.contact_id = cb.contact_id(+)
      and ph.fund_id = f.fund_id
      and pp.collection_method_id = mt.id
      and agt.policy_header_id(+) = ph.policy_header_id
      and pkg_policy.get_last_version_status(ph.policy_header_id) in ('Готовится к расторжению',
                                                                     'Завершен',
                                                                     'К прекращению',
                                                                     'К прекращению. Готов для проверки',
                                                                     'К прекращению. Проверен',
                                                                     'Отменен',
                                                                     'Прекращен. Запрос реквизитов',
                                                                     'Расторгнут')
      --and ph.ids in (1010000996,1010001421);
;

