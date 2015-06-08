create materialized view INS_DWH.DM_ACCOUNT
refresh force on demand
as
select a.num num, a.name name
  from ins.account a
 where a.account_id in
       (select t.dt_account_id
          from ins.trans t
        union
        select t.ct_account_id from ins.trans t)
union all
select '-1' num, 'неопределен' name
        from dual;

