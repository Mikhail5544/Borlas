create materialized view INS_DWH.DM_T_DAMAGE_CODE
refresh force on demand
as
select d.*, per.description peril_desc
  from (select dc.id,
               dc.parent_id,
               dc.code,
               dc.description damage_code_desc,
               dc.limit_val,
               dc.is_insurance,
               dc.is_refundable,
               level lev,
               dc.peril peril_id
          from ins.t_damage_code dc
         start with dc.parent_id is null
        connect by prior dc.id = dc.parent_id) d,
       ins.t_peril per
 where d.peril_id = per.id
union all
select         -1 id,
               null parent_id,
               'неопределено' code,
               'неопределено' damage_code_desc,
               null limit_val,
               0 is_insurance,
               0 is_refundable,
               null lev,
               null peril_id,
               'неопределено' peril_desc
        from dual;

