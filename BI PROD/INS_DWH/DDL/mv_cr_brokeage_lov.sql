create materialized view INS_DWH.MV_CR_BROKEAGE_LOV
refresh force on demand
as
select "CONTACT_ID",
       "CONTACT_NAME",
       "DEPARTMENT_ID",
       "DEPARTMENT_NAME",
       "ORGANISATION_TREE_ID",
       "ORGANISATION_NAME"
from ins.v_brokeage;

