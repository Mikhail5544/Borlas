create or replace force view ins_dwh.fc_costs_by_man_count as
select dc.acc_date,
       nvl(sal.num,0) num_by_cfr,
       dc.costs costs_by_dept_nav,
       nvl(sum(num) over(partition by dc.acc_date, dc.department_id_nav),0) num_by_dept_nav,

       round(decode(nvl(sum(num)
                    over(partition by dc.acc_date, dc.department_id_nav),0),
                    0,
                    decode(row_number() over(partition by dc.acc_date, dc.department_id_nav order by cfr.cfr_id), 1, dc.costs,0),
--                    dc.costs,
                    nvl(sal.num,0) * dc.costs /
                    (sum(num)
                     over(partition by dc.acc_date, dc.department_id_nav))),
             2) costs_by_cfr,
                      dc.department_id_nav,
               dc.department_name_nav,
       cfr.cfr_id,
       cfr.crf_name,
       c.city_name
  from (select add_months(trunc(d.account_date, 'MM'), 1) - 1 acc_date,
               d.department_id_nav,
               d.department_name_nav,
               sum(d.costs_amount) costs
          from fc_direct_costs d
         group by add_months(trunc(d.account_date, 'MM'), 1) - 1,
                  d.cfr_id,
                  d.department_id_nav,
                  d.department_name_nav) dc
 inner join etl.mp_cfr cfr on cfr.sys_department_id = dc.department_id_nav
                          and cfr.sys_source_id = 'NAV'
                          and dc.acc_date between cfr.start_date and
                              cfr.end_date
                          and cfr.cfr_id not in ('non DSF','5613')
 inner join dm_cfr c on c.cfr_id = cfr.cfr_id
  left outer join (select sum(s.is_uniq_period_person) num,
                          s.account_date acc_date,
                         -- s.cfr_id -- через агентство агентам
                          s.agency_id cfr_id
                     from fc_salary s
                    where s.staff_position_type_id in (1, 2)

                      and s.agency_id <> -1
                    group by s.account_date, s.agency_id) sal on trunc(dc.acc_date,'MM') =
                                                              trunc(sal.acc_date,'MM')

                                                          --and cfr.cfr_id = sal.cfr_id
                                                          and c.cfr_id = to_char(sal.cfr_id)

where 1 = 1
;

