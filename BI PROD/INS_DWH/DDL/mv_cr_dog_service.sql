create materialized view INS_DWH.MV_CR_DOG_SERVICE
build deferred
refresh force on demand
as
select as_prop.dog_num,                 --номер договора
       as_prop.policy_header_id,        --ИД договора
       as_prop.policy_num policy_num,    --номер версии договора
       as_prop.policy_id policy_id,                 --ИД версии договора
       as_prop.dog_start,                           --дата начала договора
       as_prop.dog_end,                             --дата окончания договора
       as_prop.card_num,                            --номер полиса
       as_prop.assured_start_date,                  --дата начала полиса
       as_prop.assured_stop_date,                   --дата аннулирования полиса
       as_prop.code,                                --код программы страхования
       aa.assured_contact_id,                       --ИД застрахованного
       as_prop.contact_id,                          --ИД ЛПУ
       sm.c_service_med_id,                          --ИД оказанной услуги
       ins.ent.obj_name(tp.ent_id,tp.id) med_type,        --вид медицинской помощи
       as_prop.prod_type,                             --тип програмы
       as_prop.note                                   --примечание
from ins.ven_c_service_med sm
     left join ins.ven_dms_rel_serv_act rsa on rsa.c_service_med_id=sm.c_service_med_id
     join ins.ven_as_assured aa on aa.as_assured_id=sm.as_asset_id
     join ins.v_cr_assured_prop as_prop on as_prop.assured_contact_id=aa.assured_contact_id
     join ins.v_cr_pol_assured ass on ass.assured_contact_id=as_prop.assured_contact_id
     join ins.v_cr_lpu_list lpu on lpu.contact_id=as_prop.contact_id
     left join ins.ven_t_peril tp on tp.id=sm.dms_aid_type_id and tp.is_dms_code=1;

