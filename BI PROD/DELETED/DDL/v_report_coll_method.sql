create or replace view ins_dwh.v_report_coll_method as
select p.pol_header_id,
       p.policy_id,
       ph.ids,
       cpol.obj_name_orig insurer_name,
       dep.name agency_name,
       ins.doc.get_doc_status_name(p.policy_id) status_name,
       m.description coll_method,
       p.day_of_charge_off
from ins.p_pol_header ph,
     ins.p_policy p,
     ins.t_collection_method m,
     ins.department dep,
     ins.t_contact_pol_role polr,
     ins.p_policy_contact pcnt,
     ins.contact cpol
where ph.policy_id = p.policy_id
      and p.collection_method_id = m.id
      and ins.pkg_policy.get_last_version_status(p.pol_header_id) NOT IN ('Готовится к расторжению','Приостановлен','Отменен','Расторгнут')
      and m.description = 'Прямое списание с карты'
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = p.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.agency_id = dep.department_id(+)