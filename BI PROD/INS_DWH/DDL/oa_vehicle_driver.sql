create or replace force view ins_dwh.oa_vehicle_driver as
select avd.as_vehicle_id,
       cp.contact_id, 
       cp.gender,      
       cp.date_of_birth,
       cp.standing,
       bm.class DR_KLASS
from ins.VEN_AS_VEHICLE_DRIVER avd
     join ins.VEN_CN_PERSON cp on avd.cn_person_id = cp.contact_id 
left join T_BONUS_MALUS bm on avd.t_bonus_malus_id = bm.t_bonus_malus_id;

