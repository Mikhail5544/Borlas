create or replace view v_agn_volume as
select agv.ag_roll_id AS AG_ROLL_ID,
       ar.num ar_num,
       dep.name AS AGENCY,
       sum(agv.trans_sum * agv.nbv_coef) cash,
       0 dop_sum,
       agh.date_begin DATE_BEGIN_AD,
       agh.num NUM_AGENT,
       c.obj_name_orig FIO_AGENT,
       agv.ag_contract_header_id
from ins.ag_volume agv,
     ins.ven_ag_roll ar,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_volume_type avt,
     ins.department dep
where 1=1
      and agv.ag_contract_header_id = agh.ag_contract_header_id
      and agh.agent_id = c.contact_id
      /*and agv.ag_roll_id = 76348221*/
      and agv.ag_volume_type_id = avt.ag_volume_type_id
      and avt.brief IN ('INV','NPF01','NPF02','NPF','RL','SOFI','FDep')
      /*******Настя закрыла**********************/
      /*and nvl(agv.pay_period,1) = 1
      and agv.is_nbv = 1
      and agv.nbv_coef > 0*/
      and agh.agency_id = dep.department_id (+)
      and ar.ag_roll_id = agv.ag_roll_id
group by agh.date_begin, agh.num, c.obj_name_orig, dep.name, agv.ag_roll_id, ar.num, agv.ag_contract_header_id;
