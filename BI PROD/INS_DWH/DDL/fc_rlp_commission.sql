create materialized view INS_DWH.FC_RLP_COMMISSION
refresh force on demand
as
select
       add_months(to_date('01.'||lower(rc.acc_month) || '.' ||lower(rc.acc_year),'dd.month.yyyy'),1)-1 acc_date,
       --nvl(mp.sys_department_id,'Неопределен')
       'Неопределен' sys_department_id,
       --nvl(mp.cfr_id,'Неопределен')
       'Неопределен' cfr_id,
       rc.department_b2b,
       rc.agent_full_name,
       rc.agent_birth_date,
       rc.agent_pass_ser,
       rc.agent_pass_num,
       rc.agent_pass_issue,
       rc.agent_pass_org,
       rc.agent_contact_id_b2b,
       lower(rc.commission_type) commission_type,
       nvl(rc.count_quality_policy,0) count_quality_policy,
       nvl(rc.count_non_quality_policy,0) count_non_quality_policy,
       nvl(rc.price_quality_policy,0) price_quality_policy,
       nvl(rc.price_non_quality_policy,0) price_non_quality_policy,
       nvl(rc.commission_amount,0) commission_amount,
       -- кол-во качественных полисов по типам агентов
       case lower(rc.commission_type)
        when 'агентское' then nvl(rc.count_quality_policy,0)
        else 0
        end count_quality_policy_ag,
       case lower(rc.commission_type)
        when 'менеджерское' then nvl(rc.count_quality_policy,0)
        else 0
        end count_quality_policy_mang,
       case lower(rc.commission_type)
        when 'директорское' then nvl(rc.count_quality_policy,0)
        else 0
        end count_quality_policy_dir,
       -- кол-во некачественных полисов по типам агентов
       case lower(rc.commission_type)
        when 'агентское' then nvl(rc.count_non_quality_policy,0)
        else 0
        end count_non_quality_policy_ag,
       case lower(rc.commission_type)
        when 'менеджерское' then nvl(rc.count_non_quality_policy,0)
        else 0
        end count_non_quality_policy_mang,
       case lower(rc.commission_type)
        when 'директорское' then nvl(rc.count_non_quality_policy,0)
        else 0
        end count_non_quality_policy_dir,
       -- коммиссия по типам агентов
       case lower(rc.commission_type)
        when 'агентское' then commission_amount
        else 0
        end commission_amount_ag,
       case lower(rc.commission_type)
        when 'менеджерское' then commission_amount
        else 0
        end commission_amount_mang,
       case lower(rc.commission_type)
        when 'директорское' then commission_amount
        else 0
        end commission_amount_dir,
       rc.acc_month,
       rc.acc_year,
       nvl(s.contact_id,-1) contact_id,
       -1 agency_id,
       case lower(rc.commission_type)
        when 'агентское' then 2
        when 'менеджерское' then 3
        when 'директорское' then 4
        else -1
       end as ag_category_agent_id,
       '2' company_id,
       decode(s.contact_id, null, 0, 1) is_rl_agent,
       nvl(s.ag_contract_header_id,-1) ag_contract_header_id,
       nvl(city.city_name,'неопределено') city_name
/* -- ВАРИАНТ 3 (ФИО+Дата рождения) или  или Пасп. данные
   -- и дополнительное ограничение: контакт имеет не просто агентский договор, а агентский договор,
   -- действующий в отчетном периоде
*/
  from etl.jr_rlp_commission rc,
       etl.mm_department_b2b_city city,
       (select jjj.*,
             decode(t.contact_id, null, tt.contact_id, t.contact_id) contact_id,
              decode(t.ag_contract_header_id, null, tt.ag_contract_header_id, t.ag_contract_header_id) ag_contract_header_id,
              --tt.contact_id,
               row_number() over(partition by jjj.rn order by jjj.agent_contact_id_b2b desc) rn1
          from (select rownum rn, jj.*
                  from (select j.agent_contact_id_b2b,
                               j.agent_full_name,
                               j.agent_birth_date,
                               j.agent_pass_ser,
                               j.agent_pass_num,
                               add_months(to_date('01.' || lower(j.acc_month) || '.' ||
                                                  lower(j.acc_year),
                                                  'dd.month.yyyy'),
                                          1) - 1 acc_date
                          from etl.jr_rlp_commission j
                         group by j.agent_contact_id_b2b,
                                  j.agent_full_name,
                                  j.agent_birth_date,
                                  j.agent_pass_ser,
                                  j.agent_pass_num,
                                  add_months(to_date('01.' ||
                                                     lower(j.acc_month) || '.' ||
                                                     lower(j.acc_year),
                                                     'dd.month.yyyy'),
                                             1) - 1) jj) jjj

          left outer join (select c.contact_id,
                                  c.obj_name,
                                  c.pass,
                                  c.date_of_birth,
                                  to_date(to_char(a.date_id), 'yyyymmdd') agent_date
                                  ,a.ag_contract_header_id
                            from dm_contact c, fc_agent a
                           where 1 = 1
                             and a.contact_id = c.contact_id
                             and a.is_current = 1) tt on decode(pkg_load.is_date(jjj.agent_birth_date,
                                                                                 'dd.mm.yyyy'),
                                                                1,
                                                                to_date(jjj.agent_birth_date,
                                                                        'dd.mm.yyyy'),
                                                                null) =
                                                         tt.date_of_birth
                                                     and UPPER(jjj.agent_full_name) =
                                                         UPPER(tt.obj_name)
                                                     and trunc(tt.agent_date,'MM') = trunc(jjj.acc_date,'MM')

          left outer join (select c.contact_id,
                                 c.obj_name,
                                 c.pass,
                                 c.date_of_birth,
                                 to_date(to_char(a.date_id), 'yyyymmdd') agent_date
                                 ,a.ag_contract_header_id
                            from dm_contact c, fc_agent a
                           where 1 = 1
                             and a.contact_id = c.contact_id
                             and a.is_current = 1) t on jjj.agent_pass_ser || '#' ||
                                                          jjj.agent_pass_num =
                                                          t.pass

                                                        and trunc(t.agent_date,'MM') = trunc(jjj.acc_date,'MM')


                                                          ) s
 where 1 = 1
   and rc.agent_contact_id_b2b = s.agent_contact_id_b2b
   and rc.agent_full_name = s.agent_full_name
   and rc.agent_birth_date = s.agent_birth_date
   and rc.agent_pass_ser = s.agent_pass_ser
   and rc.agent_pass_num = s.agent_pass_num
   and add_months(to_date('01.' || lower(rc.acc_month) || '.' ||
                          lower(rc.acc_year),
                          'dd.month.yyyy'),
                  1) - 1 = s.acc_date
   and rc.department_b2b = city.department_b2b (+)
   and s.rn1 = 1;

