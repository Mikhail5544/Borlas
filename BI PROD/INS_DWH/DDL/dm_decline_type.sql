create or replace force view ins_dwh.dm_decline_type as
select dt.t_decline_type_id, dt.name t_decline_type_name from ins.t_decline_type dt
union all
select -1, 'неопределен' from dual;

