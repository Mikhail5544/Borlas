create materialized view INS_DWH.PRE_AG_APE_POLICY
refresh force on demand
as
select sum(ape_rur_amount) ape_amount,
       count(plus_one) ape_policy_count,
       ag_contract_header_id,
       trans_date
 from
(
select ape_rur_amount,
      ag_contract_header_id,
      trans_date,
      policy_header_id,
      min(trans_date) over(partition by ag_contract_header_id, policy_header_id) first_date,
      case  when min(trans_date) over(partition by ag_contract_header_id, policy_header_id) = trans_date then
      1
      else 0
      end  plus_one

from (
select
      --count(*)
      --/*
      sum(agent_rate*ape_rur_amount) ape_rur_amount,
      ag_contract_header_id,
      trans_date,
      policy_header_id
      --*/
  from

  (select
         (case -- коэффициент доли агента при заключении договора
           when (ar.brief = 'PERCENT') then
            pa.part_agent / 100 -- процент
           when (ar.brief = 'ABSOL') then
            pa.part_agent -- абсолютная величина
           else
            pa.part_agent -- в противном случае доля агента, как абсолютная величина
         end) agent_rate,
         t.trans_amount ape_rur_amount,
         ch.ag_contract_header_id  ag_contract_header_id,
         t.trans_date trans_date,
         ph.policy_header_id



          from ins.ven_p_pol_header ph,
               ins.ven_p_policy pp,
               ins.ven_p_policy_agent pa,
               ins.ven_ag_contract_header ch,
               ins.ven_policy_agent_status pas,
               ins.ven_ag_type_rate_value ar,
               ins.trans t,
               ins.trans_templ tt,
               ins.p_cover pc,
               ins.as_asset aa

         where ph.policy_id = pp.policy_id

           and ph.policy_header_id = pa.policy_header_id
           and ch.ag_contract_header_id = pa.ag_contract_header_id
           and pa.status_id = pas.policy_agent_status_id
           and pa.ag_type_rate_value_id = ar.ag_type_rate_value_id
           and t.obj_ure_id = pc.ent_id
           and t.obj_uro_id = pc.p_cover_id
           and t.trans_templ_id = tt.trans_templ_id
           and tt.brief = 'МСФОПремияНачAPE'
           and pc.as_asset_id = aa.as_asset_id
           and aa.p_policy_id = pp.policy_id

           and pas.brief in ('CURRENT') -- статус агента по договору страхования

           -- не является страхователем
           and exists (select 1
                  from ins.ven_p_policy_contact   ppc,
                       ins.ven_t_contact_pol_role tcp
                 where tcp.id = ppc.contact_policy_role_id
                   and tcp.brief = 'Страхователь'
                   and ppc.policy_id = pp.policy_id
                   and ch.agent_id <> ppc.contact_id))

group by
      ag_contract_header_id,
      trans_date,
      policy_header_id
) )

group by
       ag_contract_header_id,
       trans_date;

