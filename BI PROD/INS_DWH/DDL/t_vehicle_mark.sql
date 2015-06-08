create or replace force view ins_dwh.t_vehicle_mark as
select "T_VEHICLE_MARK_ID","ENT_ID","FILIAL_ID","EXT_ID","IS_DEFAULT","IS_NATIONAL_MARK","NAME" from ins.ven_t_vehicle_mark;

