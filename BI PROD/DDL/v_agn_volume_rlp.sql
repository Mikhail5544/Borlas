create or replace view v_agn_volume_rlp as
select agv.ag_roll_id AS AG_ROLL_ID,
       ar.num ar_num,
       dep.name AS AGENCY,
       SUM(agv.epg_ammount) cash,
       ROUND(SUM(agv.vol_sav),2) dop_sum,
       agh.date_begin DATE_BEGIN_AD,
       d.num NUM_AGENT,
       c.obj_name_orig FIO_AGENT,
       agv.ag_contract_header_id
from ins.ag_volume_rlp agv,
     ins.ven_ag_roll ar,
     ins.ag_roll_header arh,
     ins.ag_roll_type art,
     ins.ag_contract_header agh,
     ins.document d,
     ins.contact c,
     ins.ag_volume_type avt,
     ins.department dep
where 1=1
      and ar.ag_roll_header_id = arh.ag_roll_header_id
      AND arh.ag_roll_type_id = art.ag_roll_type_id
      AND art.brief = 'RLP_CASH_VOL'
      and agv.ag_contract_header_id = agh.ag_contract_header_id
      and agh.agent_id = c.contact_id
      and agv.ag_volume_type_id = avt.ag_volume_type_id
      and agh.agency_id = dep.department_id
      and ar.ag_roll_id = agv.ag_roll_id
      AND agh.ag_contract_header_id = d.document_id
      /*AND ar.ag_roll_id = 78407289*/
group by agh.date_begin, d.num, c.obj_name_orig, dep.name, agv.ag_roll_id, ar.num, agv.ag_contract_header_id;

GRANT SELECT ON ins.v_agn_volume_rlp TO INS_READ;
