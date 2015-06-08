CREATE OR REPLACE VIEW INS.V_AGN_VOLUME_DET AS
select agv.ag_roll_id AS AG_ROLL_ID,
       agh.ag_contract_header_id,
       ar.num ar_num,
       dep.name AS AGENCY,
       sum(agv.trans_sum * agv.nbv_coef) cash,
       0 dop_sum,
       agh.date_begin DATE_BEGIN_AD,
       agh.num NUM_AGENT,
       c.obj_name_orig FIO_AGENT,
       to_char(ph.ids) ids,
       epg.num epg_num,
       agv.epg_ammount,
       agv.payment_date,
       acpt.title epg_pd_type,
       pd.num pd_payment,
       acpd.amount,
       agv.is_added,
       agv.is_calc,
       agv.policy_header_id,
       agv.epg_payment epg_payment_id,
       agv.pd_payment pd_payment_id
from ins.ag_volume agv,
     ins.ven_ag_roll ar,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_volume_type avt,
     ins.department dep,
     ins.p_pol_header ph,
     ins.document epg,
     ins.document pd,
     ins.ac_payment acpd,
     ins.ac_payment_templ acpt
where 1=1
      and agv.ag_contract_header_id = agh.ag_contract_header_id
      and agh.agent_id = c.contact_id
      --and agv.ag_roll_id = 35526601
      and agv.ag_volume_type_id = avt.ag_volume_type_id
      and avt.brief IN ('INV','NPF01','NPF02','NPF','RL','SOFI')
      /*********Настя закрыла********************/
      /*and nvl(agv.pay_period,1) = 1
      and agv.is_nbv = 1
      and agv.nbv_coef > 0*/
      and agh.agency_id = dep.department_id (+)
      and ar.ag_roll_id = agv.ag_roll_id
      and agv.policy_header_id = ph.policy_header_id (+)
      and agv.epg_payment = epg.document_id (+)
      and agv.pd_payment = pd.document_id (+)
      and agv.pd_payment = acpd.payment_id(+)
      and acpt.payment_templ_id = agv.epg_pd_type
      --and ph.ids = 1560162454
group by agv.ag_roll_id,
         ar.num,
         dep.name,
         agh.date_begin,
         agh.num,
         c.obj_name_orig,
         ph.ids,
         epg.num,
         agv.epg_ammount,
         agv.payment_date,
         acpt.title,
         pd.num,
         acpd.amount,
         agh.ag_contract_header_id,
         agv.is_added,
         agv.is_calc,
         agv.policy_header_id,
         agv.epg_payment,
         agv.pd_payment;
grant select on INS.V_AGN_VOLUME_DET to INS_READ;
