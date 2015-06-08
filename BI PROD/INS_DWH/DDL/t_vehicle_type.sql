create or replace force view ins_dwh.t_vehicle_type as
select "T_VEHICLE_TYPE_ID","ENT_ID","FILIAL_ID","EXT_ID","BRIEF","NAME" from ins.ven_t_vehicle_type;

