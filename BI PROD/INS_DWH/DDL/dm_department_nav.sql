create materialized view INS_DWH.DM_DEPARTMENT_NAV
refresh force on demand
as
select code, name from etl.department_nav;

