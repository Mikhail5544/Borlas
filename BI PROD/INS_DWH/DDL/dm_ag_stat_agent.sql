create materialized view INS_DWH.DM_AG_STAT_AGENT
refresh force on demand
as
select ags.ag_stat_agent_id, ags.name, ags.brief from ins.ag_stat_agent ags
union all
select -1 ag_stat_agent_id, 'неопределен' name, 'неопределен' brief from dual;

