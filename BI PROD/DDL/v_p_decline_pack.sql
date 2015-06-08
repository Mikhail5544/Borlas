CREATE OR REPLACE VIEW V_P_DECLINE_PACK AS
SELECT
/*Информация по пакетам обработки (используется в форме "Журнал обработки прекращений"
Черных М. 23.1.2014
*/
 p.p_decline_pack_id
,p.t_decline_pack_type_id
,typ.name t_decline_pack_type_name
,typ.brief t_decline_pack_type_brief
,p.created_by
,a.sys_user_name authtor_name
,p.created_at
,p.last_user_id
,o.sys_user_name last_user_name
,p.last_run_date
,p.process_status
,decode(p.process_status, 1, 'Обработан', 'Не обработан') process_status_name
  FROM p_decline_pack      p
      ,sys_user            a
      ,sys_user            o
      ,t_decline_pack_type typ
 WHERE p.t_decline_pack_type_id = typ.t_decline_pack_type_id
   AND p.created_by = a.sys_user_id
   AND p.last_user_id = o.sys_user_id(+);
