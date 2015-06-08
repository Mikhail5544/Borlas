CREATE OR REPLACE VIEW INS.V_FOUNDED_PAYM_DET AS
select tfp.ag_roll_id AS AG_ROLL_ID,
       tfp.ag_contract_header_id,
       dep.name AS AGENCY,
       sum(tfp.trans_sum * tfp.nbv_coef) dop_sum,
       agh.date_begin DATE_BEGIN_AD,
       agh.num NUM_AGENT,
       c.obj_name_orig FIO_AGENT,
       to_char(ph.ids) ids,
       epg.num epg_num,
       tfp.epg_payment epg_payment_id,
       tfp.epg_ammount,
       tfp.payment_date,
       acpt.title epg_pd_type,
       pd.num pd_payment,
       tfp.pd_payment pd_payment_id,
       acpd.amount,
       tfp.is_added,
       ph.policy_header_id
       /*tfp.ag_volume_type_id,
       tfp.policy_header_id,
       tfp.date_begin,
       tfp.conclude_date,
       tfp.ins_period,
       tfp.payment_term_id,
       tfp.last_status,
       tfp.active_status,
       tfp.fund,
       tfp.epg_payment,
       tfp.epg_date,
       tfp.pay_period,
       tfp.epg_status,
       tfp.epg_pd_type,
       tfp.pd_copy_status,
       tfp.pd_payment,
       tfp.pd_collection_method,
       tfp.t_prod_line_option_id,
       tfp.trans_id,
       tfp.trans_sum,
       tfp.index_delta_sum,
       tfp.nbv_coef,
       tfp.is_nbv*/
from ins.T_FOUNDED_PAYMENT tfp,
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
      and tfp.ag_contract_header_id = agh.ag_contract_header_id
      and agh.agent_id = c.contact_id
      and tfp.ag_volume_type_id = avt.ag_volume_type_id
      and avt.brief IN ('INV','NPF01','NPF02','NPF','RL','SOFI')
      and nvl(tfp.pay_period,1) = 1
      and tfp.is_nbv = 1
      and tfp.nbv_coef > 0
      and agh.agency_id = dep.department_id (+)
      and tfp.policy_header_id = ph.policy_header_id (+)
      and tfp.epg_payment = epg.document_id (+)
      and tfp.pd_payment = pd.document_id (+)
      and tfp.pd_payment = acpd.payment_id(+)
      and acpt.payment_templ_id = tfp.epg_pd_type
group by tfp.ag_roll_id,
         dep.name,
         agh.date_begin,
         agh.num,
         c.obj_name_orig,
         ph.ids,
         epg.num,
         tfp.epg_payment,
         tfp.epg_ammount,
         tfp.payment_date,
         acpt.title,
         pd.num,
         tfp.pd_payment,
         acpd.amount,
         tfp.ag_contract_header_id,
         tfp.is_added,
         ph.policy_header_id;
grant select on INS.V_FOUNDED_PAYM_DET to INS_READ;
