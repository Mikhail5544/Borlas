create materialized view INS_DWH.PRE_AG_RECRUT
refresh force on demand
as
select ac_recrut.contract_id ag_contract_header_id, ah.date_begin, count(*) recrut_count
  from ins.ag_contract ac,
       ins.ag_contract_header ah,
       ins.ag_contract ac_recrut
 where ac_recrut.ag_contract_id = ac.contract_recrut_id
       and ac.contract_id = ah.ag_contract_header_id
       and ac.ag_contract_id = ah.last_ver_id
      -- and ac_recrut.contract_id = 569396
group by ac_recrut.contract_id,ah.date_begin;

