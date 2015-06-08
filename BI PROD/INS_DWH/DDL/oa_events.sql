create or replace force view ins_dwh.oa_events as
select ce.C_EVENT_ID,
       ce.AS_ASSET_ID,
       ce.EVENT_DATE,
       ce.DATE_DECLARE
from ins.ven_c_event ce;

