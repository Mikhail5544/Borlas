create or replace force view ins_dwh.v_active_agents as
select 'RL & RLP' active_type, tt.contact_id, tt.acc_date,
case when tt.period < 45  then 'New agent'
     when (tt.period >= 45 and tt.period <=180) then 'Equal or less than HY'
     when (tt.period >180 and tt.period <=365) then 'Equal or less than Year'
     when (tt.period > 365) then 'More than a year'
     else 'not available'
end as agent_type_period,
1 as counter,
2 as ag_category_agent_id,
-1 agency_id
   from (
select priority, contact_id, acc_date, business_date_begin, acc_date - business_date_begin period,  row_number() over(partition by contact_id, acc_date order by priority asc) rn from
(
select 0 priority , rc.contact_id, rc.acc_date, ah.business_date_begin
  from fc_rlp_commission rc, dm_ag_contract_header ah
 where 1=1
   and rc.ag_contract_header_id = ah.ag_contract_header_id
   and rc.commission_type = 'агентское'
  -- and trunc(rc.acc_date, 'MM') = to_date('01122009', 'ddmmyyyy')
 group by 'rlp', rc.contact_id, rc.acc_date, ah.business_date_begin
union all

select 1 priority, e.agent_id contact_id, add_months(trunc(e.plan_date, 'mm'),1)-1 acc_date, ah.business_date_begin
  from t_fc_epg e, dm_p_pol_header ph, dm_ag_contract_header ah
 where ph.policy_header_id = e.pol_header_id
   and ah.ag_contract_header_id = e.agent_ad_id
   and ph.sales_channel_id = 12
   and ph.is_group_flag = 0
   and e.ape_amount_rur > 0
   and e.first_epg = 1
   and e.agent_id is not null
   and e.plan_date between to_date('01012009','ddmmyyyy') and (select max(rc.acc_date) from fc_rlp_commission rc)
  -- and trunc(e.plan_date,'MM') = to_date('01122009','ddmmyyyy')
 group by  1, e.agent_id, add_months(trunc(e.plan_date, 'mm'),1)-1, ah.business_date_begin) t ) tt
 where tt.rn =1
 and tt.contact_id <> -1

union all

-- менеджеры жизнь+пенсия
select 'RL & RLP' active_type, rc.contact_id, rc.acc_date, 'RLP agents not registered in Life company', 1 as counter, 2 as ag_category_agent_id, -1 agency_id
from fc_rlp_commission rc where rc.contact_id = -1 and rc.commission_type = 'агентское'

union all

-- агенты жизнь
select 'RL' active_type, tt.contact_id, tt.acc_date,
case when tt.acc_date - tt.business_date_begin < 45  then 'New agent'
     when (tt.acc_date - tt.business_date_begin >= 45 and tt.acc_date - tt.business_date_begin <=180) then 'Equal or less than HY'
     when (tt.acc_date - tt.business_date_begin >180 and tt.acc_date - tt.business_date_begin <=365) then 'Equal or less than Year'
     when (tt.acc_date - tt.business_date_begin > 365) then 'More than a year'
     else 'not available'
end as agent_type_period,
1 as counter,
2 as ag_category_agent_id,
tt.agency_id
 from
(select  add_months(trunc(e.plan_date, 'mm'),1)-1 acc_date, e.agent_id contact_id, ah.business_date_begin, a.agency_id
from t_fc_epg e, dm_p_pol_header ph, dm_ag_contract_header ah, dm_agency a
 where ph.policy_header_id = e.pol_header_id
   and ah.ag_contract_header_id = e.agent_ad_id
   and ph.sales_channel_id = 12
   and ph.is_group_flag = 0
   and e.ape_amount_rur > 0
   and e.first_epg = 1
   and e.agent_id is not null
   and e.agent_agency = a.name(+)
   --and e.plan_date between to_date('01012009','ddmmyyyy') and (select max(rc.acc_date) from fc_rlp_commission rc)
   and e.plan_date >= to_date('01012009','ddmmyyyy')
   --and trunc(e.plan_date,'MM') = to_date('01122009','ddmmyyyy')
 group by add_months(trunc(e.plan_date, 'mm'),1)-1, e.agent_id, ah.business_date_begin, a.agency_id) tt

union all

-- менеджеры жизнь
select 'RL' active_type, tt.contact_id, tt.acc_date,
case when tt.acc_date - tt.business_date_begin < 45  then 'New agent'
     when (tt.acc_date - tt.business_date_begin >= 45 and tt.acc_date - tt.business_date_begin <=180) then 'Equal or less than HY'
     when (tt.acc_date - tt.business_date_begin >180 and tt.acc_date - tt.business_date_begin <=365) then 'Equal or less than Year'
     when (tt.acc_date - tt.business_date_begin > 365) then 'More than a year'
     else 'not available'
end as agent_type_period,
1 as counter,
3 as ag_category_agent_id,
tt.agency_id
from
(select  add_months(trunc(e.plan_date, 'mm'),1)-1 acc_date, e.manager_id contact_id, ah.business_date_begin, a.agency_id
  from t_fc_epg e, dm_p_pol_header ph, dm_ag_contract_header ah, dm_agency a
 where ph.policy_header_id = e.pol_header_id
   and ah.ag_contract_header_id = e.manager_ad_id
   and ph.sales_channel_id = 12
   and ph.is_group_flag = 0
   and e.ape_amount_rur > 0
   and e.first_epg = 1
   and e.manager_id is not null
   and e.manager_agency = a.name (+)
   --and e.plan_date between to_date('01012009','ddmmyyyy') and (select max(rc.acc_date) from fc_rlp_commission rc)
   and e.plan_date >= to_date('01012009','ddmmyyyy')
   --and trunc(e.plan_date,'MM') = to_date('01122009','ddmmyyyy')
 group by add_months(trunc(e.plan_date, 'mm'),1)-1, e.manager_id, ah.business_date_begin, a.agency_id) tt

union all

-- директоры жизнь
select 'RL' active_type, tt.contact_id, tt.acc_date,
case when tt.acc_date - tt.business_date_begin < 45  then 'New agent'
     when (tt.acc_date - tt.business_date_begin >= 45 and tt.acc_date - tt.business_date_begin <=180) then 'Equal or less than HY'
     when (tt.acc_date - tt.business_date_begin >180 and tt.acc_date - tt.business_date_begin <=365) then 'Equal or less than Year'
     when (tt.acc_date - tt.business_date_begin > 365) then 'More than a year'
     else 'not available'
end as agent_type_period,
1 as counter,
4 as ag_category_agent_id,
tt.agency_id
from
(select  add_months(trunc(e.plan_date, 'mm'),1)-1 acc_date, e.dir_id contact_id, ah.business_date_begin, a.agency_id
  from t_fc_epg e, dm_p_pol_header ph, dm_ag_contract_header ah, dm_agency a
 where ph.policy_header_id = e.pol_header_id
   and ah.ag_contract_header_id = e.dir_ad_id
   and ph.sales_channel_id = 12
   and ph.is_group_flag = 0
   and e.ape_amount_rur > 0
   and e.first_epg = 1
   and e.dir_agency = a.name (+)
   and e.dir_ad_id is not null
   --and e.plan_date between to_date('01012009','ddmmyyyy') and (select max(rc.acc_date) from fc_rlp_commission rc)
   and e.plan_date >= to_date('01012009','ddmmyyyy')
   --and trunc(e.plan_date,'MM') = to_date('01122009','ddmmyyyy')
 group by add_months(trunc(e.plan_date, 'mm'),1)-1, e.dir_id, ah.business_date_begin, a.agency_id) tt


union all

-- агенты пенсия
select 'RLP' active_type, tt.contact_id, tt.acc_date,
case when tt.acc_date - tt.business_date_begin < 45  then 'New agent'
     when (tt.acc_date - tt.business_date_begin >= 45 and tt.acc_date - tt.business_date_begin <=180) then 'Equal or less than HY'
     when (tt.acc_date - tt.business_date_begin >180 and tt.acc_date - tt.business_date_begin <=365) then 'Equal or less than Year'
     when (tt.acc_date - tt.business_date_begin > 365) then 'More than a year'
     else 'not available'
end as agent_type_period,
1 as counter,
2 as ag_category_agent_id,
-1 agency_id
from
(
select rc.contact_id, rc.acc_date, ah.business_date_begin
  from fc_rlp_commission rc, dm_ag_contract_header ah
 where 1=1
   and rc.ag_contract_header_id = ah.ag_contract_header_id
   and rc.commission_type = 'агентское'
   --and trunc(rc.acc_date, 'MM') = to_date('01122009', 'ddmmyyyy')
 group by rc.contact_id, rc.acc_date, ah.business_date_begin) tt

union all

-- заглушка
select 'RLP' active_type,
       rc.contact_id,
       rc.acc_date,
       'RLP agents not registered in Life company',
       1 as counter,
       2 as ag_category_agent_id,
       -1 agency_id
  from fc_rlp_commission rc
 where rc.contact_id = -1
   and rc.commission_type = 'агентское'
;

