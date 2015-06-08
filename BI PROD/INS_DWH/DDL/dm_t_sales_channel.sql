create materialized view INS_DWH.DM_T_SALES_CHANNEL
refresh force on demand
as
select sc.id, sc.description, nvl(sc.brief,'NULL') brief, sc.descr_for_rep from ins.t_sales_channel sc
union all
select -1 id, 'неопределен' description, 'неопределен' brief, 'неопределен' descr_for_rep from dual;

