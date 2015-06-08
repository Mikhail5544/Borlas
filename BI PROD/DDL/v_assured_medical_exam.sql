create or replace force view v_assured_medical_exam as
select distinct
       ver.notice_num,
       ver.notice_date,
       ver.policy_id,
       decode(ver.pol_ser, null, ver.pol_num, ver.pol_ser || '-' || ver.pol_num) pol_num,
       ic.obj_name_orig ins,
       insc.obj_name_orig insurer,
       ver.status_name,
       ver.status_date,
       ver.user_name,
       ver.start_date,
       tw.description waiting_period,
       ad.request_date,
       tad.name,
       ph.description,
       nvl(dep.name,dag.name)  as department,
       mt.name as type_med,
       nvl(m.status_date,m.exam_date) as exam_date,
       cag.obj_name_orig agent_name,
       cam.obj_name_orig manager,



       case ver.status_name when 'Андеррайтинг' then to_char(round(sysdate - ver.status_date,0)) else '-' end st_undrw,
       case ver.status_name when 'Запрос документов' then  to_char(round(((ver.status_date + 5) - sysdate),0)) else '-' end st_zprs,
       case ver.status_name when 'Мед обследование' then to_char(round(((ver.status_date + 14) - sysdate),0)) else '-' end st_medo

from v_policy_version_journal ver
     left join t_period tw on (tw.id = ver.waiting_period_id)
     left join p_pol_header ph on (ver.policy_header_id = ph.policy_header_id)
     left join department dep on (dep.department_id = ph.agency_id)
     left join p_policy_agent pag on (pag.policy_header_id = ph.policy_header_id and pag.status_id not in (2,4))
     left join ag_contract_header hag on (hag.ag_contract_header_id = pag.ag_contract_header_id)
     left join contact cag on (cag.contact_id = hag.agent_id)
     left join ag_contract agc on (agc.ag_contract_id = hag.last_ver_id)
     left join ag_contract_header mhag on (mhag.last_ver_id = agc.contract_leader_id)
     left join contact cam on (cam.contact_id = mhag.agent_id)

     left join department dag on (dag.department_id = hag.agency_id)
     left join p_policy_contact ii on (ii.policy_id = ver.policy_id and ii.contact_policy_role_id = 6)
     left join contact ic on (ic.contact_id = ii.contact_id)
     left join as_asset aa on (aa.p_policy_id = ver.policy_id)
     left join as_assured sur on (sur.as_assured_id = aa.as_asset_id)
     left join contact insc on (insc.contact_id = sur.assured_contact_id)
     left/*inner*/ join as_assured_docum ad on (ad.as_assured_id = sur.as_assured_id)
     left join assured_docum_type tad on (tad.assured_docum_type_id = ad.assured_docum_type_id)
     left join assured_medical_exam m on (m.as_assured_docum_id = ad.as_assured_docum_id)
     left join medical_exam_type mt on (mt.medical_exam_type_id = m.medical_exam_type_id)

where --ver.policy_id = ver.active_policy_id
      --2009.09.04 - Герасимов А.О. - изменения по заявке 44337 - необходимо выбирать данные только по ПОСЛЕДНЕЙ версии (а не по активной)
      ver.policy_id =   pkg_policy.get_last_version(ver.policy_header_id)
      and ver.status_name in ('Мед обследование','Запрос документов','Доработка','Приостановлен')
      and ver.user_name in ('NOVIKOVAN','OTITOV','NBOGORODSKAYA')
--    doc.get_doc_status_name(pp.policy_id,to_date('01-01-2999','dd-mm-yyyy')) in ('Мед обследование','Запрос документов','Доработка')
;

