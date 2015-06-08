create or replace force view v_notification_history as
select
  t.description,
  h.event_date,
  c.contact_id,
  c.obj_name_orig contact_name,
  u.sys_user_name,
  d.num
from ven_notification_history h
inner join ven_t_notification_type t on h.t_notification_type_id = t.t_notification_type_id
inner join contact c on c.contact_id = h.contact_id
inner join sys_user u on u.sys_user_id = h.sys_user_id
left outer join document d on d.document_id = h.document_id
order by h.event_date;

