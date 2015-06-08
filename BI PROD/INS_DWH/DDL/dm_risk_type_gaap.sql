create materialized view INS_DWH.DM_RISK_TYPE_GAAP
refresh force on demand
as
select 1 RISK_TYPE_GAAP_ID, 'Короткая жизнь' name, 'short_life' brief
  from dual
union all
select 2 RISK_TYPE_GAAP_ID, 'Длинная жизнь' name, 'long_life' brief
  from dual
union all
select 3 RISK_TYPE_GAAP_ID, 'Короткий НС' name, 'short_ns' brief
  from dual
union all
select 4 RISK_TYPE_GAAP_ID, 'Длинный НС' name, 'long_ns' brief
  from dual
union all
select -1 RISK_TYPE_GAAP_ID, 'не определено' name, 'не определено' brief from dual;

