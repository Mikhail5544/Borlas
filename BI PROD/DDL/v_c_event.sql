CREATE OR REPLACE FORCE VIEW V_C_EVENT
(event_id, date_declare, event_date, event_addr, event_addr_name, event_note, event_vehicles, vehicle_damage_note, asset_id, cn_person_id, c_event_contact_id, informator, emergency_commissar_org, emergency_operator, commisar_date_out_fio, evacuation_org, evacuation_operator, evacuation_place, dispatcher_fio, dispatcher_fio_id, num, reg_date, diagnose)
AS
SELECT ev.c_event_id,
    ev.date_declare,
    ev.event_date,
    ev.cn_address,
    ent.obj_name('CN_ADDRESS', ev.cn_address),
    ev.note,
    ev.event_vehicles,
    ev.vehicle_damage_note,
    ev.as_asset_id,
    ec.cn_person_id,
    ec.c_event_contact_id,
    ent.obj_name('CN_PERSON', ec.cn_person_id),
    ev.emergency_commissar_org,
    ev.emergency_operator,
    ev.commisar_date_out_fio,
    ev.evacuation_org,
    ev.evacuation_operator,
    ev.evacuation_place,
    (SELECT NAME FROM v_sys_user WHERE sys_user_id=ev.dispatcher_fio_id) dispatcher_fio,
    ev.dispatcher_fio_id,
     ev.num,
     ev.reg_date,
     ev.diagnose
FROM ven_c_event ev
 LEFT JOIN  ven_c_event_contact ec ON   ev.C_EVENT_ID  = ec.C_EVENT_ID 
   AND ec.c_event_contact_role_id  IN (SELECT c_event_contact_role_id 
                                       FROM ven_c_event_contact_role 
                                       WHERE brief = 'Информатор'
                                      )
   AND ec.c_claim_header_id IS NULL;

