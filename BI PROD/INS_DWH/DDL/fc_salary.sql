create materialized view INS_DWH.FC_SALARY
refresh force on demand
as
select t.account_date,
       t.contact_id_1s,
       t.company_id,
       t.salary_amount,
       t.salary_contract_num,
       t.sys_agent_name,
       t.sys_date_birth,
       t.sys_department_id,
       t.sys_departmnet_name,
       nvl(cfr.cfr_id,'Неопределен') cfr_id,
       t.sys_category_id,
       t.sys_category_name,
       --ag_category_agent_id,
       t.sys_salary_type_id,
       t.sys_salary_type_name,
       nvl(t.contact_id,-1) contact_id,
       decode(t.contact_id, null, 0, 1) is_matched_with_borlas,
       nvl(t.agency_id,-1) agency_id,
       nvl(t.ag_contract_header_id,-1) ag_contract_header_id,
       nvl(t.ag_category_agent_id,-1) ag_category_agent_id,
       nvl(sp.staff_position_id,-1) staff_position_type_id,
       nvl(st.is_calc,-1) is_for_calc,
       -- если данный сотрудник первый раз встречается в периоде и сотрудник имее типы начислений, которые учитываются в расчете
       -- то 1, иначе 0. Нужно для расчета кол-ва в периоде
       decode(st.is_calc,0,0,decode(row_number() over (partition by t.contact_id_1s/*t.sys_agent_name*/, t.account_date, t.agency_id, t.company_id, st.is_calc order by t.account_date, t.sys_salary_type_id),1,1,0)) is_uniq_period_person

  -- при связавании с фактом агент, оказалось, что есть два действующих договора в одном периоде. Таких договоров 18 штук.
  -- пришлось после связи с фактом агент, удалять эти дубликаты.
  from (select row_number() over(partition by s1.r, a.contact_id, s1.account_date order by a.begin_date_id desc) rn,
               s1.contact_id_1s,
               s1.account_date,
               --s1.contact_id,
               s1.company_id,
               s1.salary_amount,
               s1.salary_contract_num,
               s1.sys_department_id,
               s1.sys_departmnet_name,
               --s1.company_inn,
               --s1.company_kpp,
               --s1.company_name,
               s1.sys_agent_name,
               s1.sys_date_birth,
               --sys_source_id,
               --cfr.cfr_id,
               sys_category_id,
               sys_category_name,
               --ag_category_agent_id,
               sys_salary_type_id,
               sys_salary_type_name,

               a.contact_id,
               a.agency_id,
               a.ag_contract_header_id,
               a.ag_category_agent_id

          from (select rownum r, s.* from etl.jr_salary s) s1
                        left outer join fc_agent a on a.contact_id = s1.contact_id
                        /*
                                                  and a.date_id =
                                                      to_char(s1.account_date, 'yyyymmdd')
                                                      */
                                                  and (a.date_id between to_char(trunc(s1.account_date,'MM'), 'yyyymmdd') and
                                                      to_char(s1.account_date, 'yyyymmdd'))
                                                  and a.is_current = 1
                                                  and a.t_sales_channel_id in (12,121)) t

    left outer join etl.mp_staff_position sp on t.sys_category_id = sp.sys_category_id
    left outer join  etl.mp_salary_type st on t.sys_salary_type_id = st.sys_salary_type_id
    left outer join
    (select cfr_id, sys_department_id, start_date, end_date  from etl.mp_cfr where sys_source_id = '1S') cfr
         on  t.sys_department_id = cfr.sys_department_id
         and t.account_date between cfr.start_date and cfr.end_date
 where 1=1
 and t.rn = 1
 /*and lower(trim(t.sys_salary_type_name)) in (
 'оплата по окладу', 'доплата за совмещение (суммой)', 'премия по контракту', 'пос. по ух. за реб. до 3 л',
 'отпуск очередной', 'оплата б/л за счет работодателя', 'оплата по среднему заработку',
 'оплата по договору подряда', 'компенсация отпуска при увольнении', 'отпуск учебный', 'компенсация отпуска',
 'оплата б/л за счет работодателя (по 2009 г.)')
  and lower(t.sys_category_name) not like '%специалист%';*/;

