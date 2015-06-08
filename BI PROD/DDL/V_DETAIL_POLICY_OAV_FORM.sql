CREATE OR REPLACE VIEW INS.V_DETAIL_POLICY_OAV_FORM AS
select t.policy_num,
       t.ids,
       NVL(t.product,'ноя') product,
       round(sum(t.detail_commis),2) detail_commis,
       t.prem_type,
       t.ag_contract_header_id,
       t.ag_perfomed_work_act_id
from ins.T_GROUP_OAV_DETAIL t
group by t.policy_num,
       t.ids,
       t.product,
       ag_contract_header_id,
       t.prem_type,
       t.ag_perfomed_work_act_id;
grant select on INS.V_DETAIL_POLICY_OAV_FORM to INS_READ;
