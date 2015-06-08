create or replace force view ins_dwh.oa_events_contact as
select cec.C_EVENT_ID,
       cec.cn_person_id,
       cecr.brief
from ins.ven_c_event_contact cec
join c_event_contact_role cecr on cecr.c_event_contact_role_id = cec.c_event_contact_role_id;

