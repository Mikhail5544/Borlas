CREATE OR REPLACE VIEW INS.V_GROUP_OAV_FORM AS
SELECT DISTINCT
       t.ag_contract_header_id,
       t.ag_roll_id,
       t.ag_roll_header_id,
       t.agency,
       t.agent_num,
       t.date_begin_ad,
       t.agent_fio,
       t.rl_vol + t.inv_vol + t.ops_vol + t.ops2_vol + t.sofi_vol + t.ops9_vol + t.fdep_vol detail_vol_amt,
       (select sum(ta.detail_commis)
        from ins.T_GROUP_OAV_DETAIL ta
        where ta.ag_perfomed_work_act_id = t.ag_perfomed_work_act_id
       ) detail_commis,
       t.ag_perfomed_work_act_id
FROM ins.T_GROUP_OAV_DETAIL t;
grant select on INS.V_GROUP_OAV_FORM to INS_READ;
