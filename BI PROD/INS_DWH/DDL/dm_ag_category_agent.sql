create materialized view INS_DWH.DM_AG_CATEGORY_AGENT
refresh force on demand
as
select ac.ag_category_agent_id, ac.category_name, ac.brief from ins.ag_category_agent ac
union all
select -1 ag_category_agent_id, 'неопределен' name, 'неопределен' brief from dual;

