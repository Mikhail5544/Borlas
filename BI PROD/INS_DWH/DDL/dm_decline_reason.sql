create or replace force view ins_dwh.dm_decline_reason as
select dr.t_decline_reason_id, nvl(dr.short_name, dr.name) t_decline_reason_name from ins.t_decline_reason dr
union all
select -1, 'неопределен' from dual;

