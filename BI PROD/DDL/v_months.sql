create or replace force view v_months as
select month_num,
       to_char(to_date(lpad(month_num, 2, '0') || 2005, 'MMYYYY'), 'month') month_name
  from (select 1 month_num
          from dual
        union all
        select 2 month_num
          from dual
        union all
        select 3 month_num
          from dual
        union all
        select 4 month_num
          from dual
        union all
        select 5 month_num
          from dual
        union all
        select 6 month_num
          from dual
        union all
        select 7 month_num
          from dual
        union all
        select 8 month_num
          from dual
        union all
        select 9 month_num
          from dual
        union all
        select 10 month_num
          from dual
        union all
        select 11 month_num
          from dual
        union all
        select 12 month_num from dual);

