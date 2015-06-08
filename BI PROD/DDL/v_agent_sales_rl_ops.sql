CREATE OR REPLACE FORCE VIEW V_AGENT_SALES_RL_OPS AS
select agent_name,
       sales_ch,
       department,
       leader_name,
       date_begin,
       start_date,
       tel_home,
       tel_work,
       tel_mobile,
       days,
       period,
       is_to_break,
       address
from
(
select agent_name, sales_ch, department, leader_name, date_begin, greatest(nvl(mn.start_date,'01.01.1900'), nvl(mn.ops_start_date,'01.01.1900') ) start_date,
                       (select tel.telephone_number tel
                          from ins.t_telephone_type tt,
                               ins.cn_contact_telephone tel
                          where tel.contact_id = mn.contact_id
                                and tt.id = tel.telephone_type
                                and tt.description = 'Домашний телефон'
                                and length(tel.telephone_number) > 3
                                and rownum = 1
                       ) tel_home,
                       (select tel.telephone_number tel
                          from ins.t_telephone_type tt,
                               ins.cn_contact_telephone tel
                          where tel.contact_id = mn.contact_id
                                and tt.id = tel.telephone_type
                                and tt.description = 'Рабочий телефон'
                                and length(tel.telephone_number) > 3
                                and rownum = 1
                       ) tel_work,
                       (select tel.telephone_number tel
                          from ins.t_telephone_type tt,
                               ins.cn_contact_telephone tel
                         where tel.contact_id = mn.contact_id
                               and tt.id = tel.telephone_type
                               and tt.description = 'Мобильный'
                               and length(tel.telephone_number) > 3
                               and rownum = 1
                       ) tel_mobile,
                       round(sysdate - greatest(nvl(mn.start_date,'01.01.1900'), nvl(mn.ops_start_date,'01.01.1900') ),0) days
                      ,case
                         when trunc(to_date((SELECT r.param_value
                                             FROM ins_dwh.rep_param r
                                             WHERE r.rep_name = 'agent_nosell'
                                               AND r.param_name = 'date_period'), 'dd.mm.yyyy'),'dd') - coalesce(greatest(change_date,manager_end),change_date,manager_end) < 60
                         then '< 60 дней'
                         when trunc(to_date((SELECT r.param_value
                                             FROM ins_dwh.rep_param r
                                             WHERE r.rep_name = 'agent_nosell'
                                               AND r.param_name = 'date_period'), 'dd.mm.yyyy'),'dd') - coalesce(greatest(change_date,manager_end),change_date,manager_end) > 60
                         then '> 60 дней'
                         when trunc(to_date((SELECT r.param_value
                                             FROM ins_dwh.rep_param r
                                             WHERE r.rep_name = 'agent_nosell'
                                               AND r.param_name = 'date_period'), 'dd.mm.yyyy'),'dd') - coalesce(greatest(change_date,manager_end),change_date,manager_end) = 60
                         then '= 60 дням'
                       end as period
                      ,case
                        when break_ad_date > trunc(to_date((SELECT r.param_value
                                                          FROM ins_dwh.rep_param r
                                                          WHERE r.rep_name = 'agent_nosell'
                                                            AND r.param_name = 'date_period'), 'dd.mm.yyyy'),'dd') then 'Да'
                        else 'Нет'
                       end as is_to_break,
                       mn.address,
                      /*,docs.change_date
                      ,chng.manager_end
                      ,br.break_ad_date*/
                      doc_cat_chg1.ag_contract_header_id header_id_1,
                      doc_cat_chg2.ag_contract_header_id header_id_2,
                      mn.ag_contract_header_id header_id
                  from (select d.num ||' '||c.obj_name_orig agent_name,
                               ch.description sales_ch,
                               dep.name department,
                               dl.num ||' '|| cl.obj_name_orig leader_name,
                               agh.date_begin,
                               start_date,
                               ops_start_date,
                               c.contact_id,
                               agh.ag_contract_header_id,
                               NVL(adr.name, pkg_contact.get_address_name(adr.id)) address
                               /*(case when adr.street_name is not null then 'ул.'||adr.street_name else '' end ||
                               case when adr.house_nr is not null then ',д.'||adr.house_nr else '' end ||
                               case when adr.block_number is not null then ','||adr.block_number else '' end ||
                               case when adr.appartment_nr is not null then ',кв.'||adr.appartment_nr else '' end) fadr,
                               (case when adr.city_name is not null then 'г.'||adr.city_name else '' end) city_name,
                               case when reg.region_name is not null then reg.region_name||' '||treg.description_short else '' end region_name,
                               case when prov.province_name is not null then prov.province_name||' '||tprov.description_short else '' end province_name,
                               case when distr.district_name is not null then tdistr.description_short||' '||distr.district_name else '' end distr_name,
                               (select distinct tc.description from t_country tc where tc.id = adr.country_id) country_name,
                               adr.zip*/
                          from ins.ven_ag_contract_header agh,
                               ins.document d,
                               ins.ag_contract ag,
                               ins.contact c,
                               ins.cn_address adr,

                               /*t_province prov,
                               t_region reg,
                               t_district distr,
                               t_region_type treg,
                               t_province_type tprov,
                               t_district_type tdistr,*/

                               ins.t_sales_channel ch,
                               ins.department dep,
                               ins.ag_category_agent cat,
                               ins.ag_contract agl,
                               ins.ag_contract_header aghl,
                               ins.contact cl,
                               ins.document dl
                              ,(select agh.ag_contract_header_id,
                                       max(pad.date_begin) start_date
                                from ins.p_policy_agent_doc pad,
                                     ins.ag_contract_header agh
                                where pad.ag_contract_header_id = agh.ag_contract_header_id
                                      and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) not in ('ERROR')
                                      --and pad.ag_contract_header_id = 21819553
                                      and pkg_agent_1.get_agent_new_to_policy(pad.policy_header_id,
                                                 to_date((SELECT r.param_value
                                                          FROM ins_dwh.rep_param r
                                                          WHERE r.rep_name = 'agent_nosell'
                                                            AND r.param_name = 'date_period'),
                                                                'dd.mm.yyyy')) = agh.ag_contract_header_id
                                group by agh.ag_contract_header_id
                               ) sl,
                               (select max(ops.sales_date) ops_start_date,
                                       ops.agent_num
                                from ins.agn_sales_ops ops
                                group by ops.agent_num
                                ) so
                          where sl.ag_contract_header_id(+) = agh.ag_contract_header_id
                                and agh.ag_contract_header_id = ag.contract_id
                                and agh.is_new = 1
                                and sysdate between ag.date_begin and ag.date_end
                                and agh.agent_id = c.contact_id
                                and agh.t_sales_channel_id = ch.id
                                and ag.agency_id = dep.department_id
                                and ag.category_id = cat.ag_category_agent_id
                                and cat.category_name = 'Агент'
                                and ins.doc.get_doc_status_brief(agh.ag_contract_header_id) = 'CURRENT'
                                and agh.ag_contract_header_id = d.document_id
                                and ag.contract_leader_id = agl.ag_contract_id(+)
                                and agl.contract_id = aghl.ag_contract_header_id(+)
                                and aghl.agent_id = cl.contact_id(+)
                                and aghl.ag_contract_header_id = dl.document_id(+)
                                and so.agent_num(+) = agh.num
                                and pkg_contact.get_primary_address(c.contact_id) = adr.ID(+)
                                and agh.ag_contract_header_id not in
                                      (
                                      select agd.ag_contract_header_id
                                      from ins.ag_contract_header agha,
                                           ins.ag_documents agd,
                                           ins.ag_doc_type tp
                                      where agha.ag_contract_header_id = agh.ag_contract_header_id
                                            and agha.ag_contract_header_id = agd.ag_contract_header_id
                                            and agd.ag_doc_type_id = tp.ag_doc_type_id
                                            and tp.brief = 'NEW_AD'
                                            and doc.get_doc_status_brief(agd.ag_documents_id) in ('CONFIRMED','PRINTED','RECEIVED_FROM_AGENT','REVISION')
                                      )

                                /*and adr.region_id = reg.region_id(+)
                                and adr.province_id = prov.province_id(+)
                                and adr.district_id = distr.district_id(+)
                                and reg.region_type_id = treg.region_type_id(+)
                                and prov.province_type_id = tprov.province_type_id(+)
                                and distr.district_type_id = tdistr.district_type_id(+)*/
                       ) mn
                      -- дата статуса АД "подтвержден"/"доработан агентом"
                      ,(select ad.ag_contract_header_id
                              ,trunc(max(ds.change_date),'dd') as change_date
                          from ins.doc_status     ds
                              ,ins.doc_status_ref dsr
                              ,ins.ag_documents   ad
                              ,ins.ag_doc_type    dt
                         where ad.ag_documents_id   = ds.document_id
                           and ds.doc_status_ref_id = dsr.doc_status_ref_id
                           and ad.ag_doc_type_id = dt.ag_doc_type_id
                           and dt.brief = 'NEW_AD'
                           and dsr.brief in ('CO_ACCEPTED')
                         group by ad.ag_contract_header_id
                       ) docs
                       -- дата смены категории с менеджера/директора на агента
                      ,(select ad.ag_contract_header_id contract_id
                              ,trunc(max(ds.start_date),'dd') as manager_end
                          from ins.doc_status     ds
                              ,ins.doc_status_ref dsr
                              ,ins.ag_documents   ad
                              ,ins.ag_doc_type    dt
                              ,ins.ag_props_change prop
                              ,ins.ag_props_type   tp
                         where ad.ag_documents_id   = ds.document_id
                           and ds.doc_status_ref_id = dsr.doc_status_ref_id
                           and ad.ag_doc_type_id = dt.ag_doc_type_id
                           and dt.brief = 'CAT_CHG'
                           and dsr.brief in ('CO_ACCEPTED')
                           and ad.ag_documents_id = prop.ag_documents_id
                           and prop.ag_props_type_id = tp.ag_props_type_id
                           and tp.brief = 'CAT_PROP'
                           and prop.new_value = '2'
                         group by ad.ag_contract_header_id
                       ) chng
                       -- тип документа "Расторжение АД" находится в статусе "Подтвержден", но дата расторжения еще не наступила
                      ,(select ad.ag_contract_header_id
                              ,max(ad.doc_date)        as break_ad_date
                          from ins.ag_documents       ad
                              ,ins.ag_doc_type        dt
                              ,ins.doc_status         docs
                              ,ins.doc_status_ref     docr
                         where ad.ag_doc_type_id       = dt.ag_doc_type_id
                           and dt.brief                = 'BREAK_AD'
                           and ad.ag_documents_id      = docs.document_id
                           and docs.doc_status_ref_id  = docr.doc_status_ref_id
                           and docr.brief              = 'CONFIRMED'
                         group by ad.ag_contract_header_id
                       ) br,
                       (select trunc(max(ds.start_date),'dd'),
                               ad.ag_contract_header_id
                       from ins.doc_status     ds
                           ,ins.doc_status_ref dsr
                           ,ins.ag_documents   ad
                           ,ins.ag_doc_type    dt
                           ,ins.ag_props_change prop
                           ,ins.ag_props_type   tp
                       where ad.ag_documents_id   = ds.document_id
                         and ds.doc_status_ref_id = dsr.doc_status_ref_id
                         and ad.ag_doc_type_id = dt.ag_doc_type_id
                         and dt.brief = 'CAT_CHG'
                         and ad.ag_documents_id = prop.ag_documents_id
                         and prop.ag_props_type_id = tp.ag_props_type_id
                         and tp.brief = 'CAT_PROP'
                         and prop.new_value = '2'
                         and dsr.brief in ('CO_ACCEPTED')
                       group by ad.ag_contract_header_id) doc_cat_chg1,
                       (select trunc(max(ds.start_date),'dd'),
                               ad.ag_contract_header_id
                       from ins.doc_status     ds
                           ,ins.doc_status_ref dsr
                           ,ins.ag_documents   ad
                           ,ins.ag_doc_type    dt
                           ,ins.ag_props_change prop
                           ,ins.ag_props_type   tp
                       where ad.ag_documents_id   = ds.document_id
                         and ds.doc_status_ref_id = dsr.doc_status_ref_id
                         and ad.ag_doc_type_id = dt.ag_doc_type_id
                         and dt.brief = 'CAT_CHG'
                         and ad.ag_documents_id = prop.ag_documents_id
                         and prop.ag_props_type_id = tp.ag_props_type_id
                         and tp.brief = 'CAT_PROP'
                         and prop.new_value = '2'
                       group by ad.ag_contract_header_id) doc_cat_chg2
                  where mn.ag_contract_header_id  = docs.ag_contract_header_id (+)
                    and mn.ag_contract_header_id  = chng.contract_id           (+)
                    and mn.ag_contract_header_id  = br.ag_contract_header_id   (+)
                    and mn.ag_contract_header_id  = doc_cat_chg1.ag_contract_header_id (+)
                    and mn.ag_contract_header_id  = doc_cat_chg2.ag_contract_header_id (+)
                    -- дата расторжения АД меньше даты окончания выбранного периода
                    and nvl(br.break_ad_date,sysdate) >= to_date(
                                                         (SELECT r.param_value
                                                          FROM ins_dwh.rep_param r
                                                          WHERE r.rep_name = 'agent_nosell'
                                                            AND r.param_name = 'date_period'),
                                                                'dd.mm.yyyy')
                    and greatest(nvl(mn.start_date,'01.01.1900'), nvl(mn.ops_start_date,'01.01.1900') ) <> '01.01.1900'
) a
where header_id not in (select case when nvl(header_id_1,0) > 0 then 0
                         else nvl(header_id_2,0) end from dual)
;

