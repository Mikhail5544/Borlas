create materialized view INS_DWH.DM_TRANS_TEMPL
refresh force on demand
as
select tt.trans_templ_id trans_templ_id, tt.name, tt.brief
  from ins.trans_templ tt
 where tt.trans_templ_id in (select t.trans_templ_id from ins.trans t)
union all
select -1 trans_templ_id, 'неопределен' name, 'неопределен' brief from dual;

