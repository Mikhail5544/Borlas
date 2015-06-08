CREATE OR REPLACE FORCE VIEW REP_IS_EXIST_OPS AS
SELECT arh.num num_vedom,
       rl.num num_ver,
       agv.ag_volume_id,
       d.snils,
       d.ag_contract_num,
       d.kv_flag kv_flag_det,
       ops.policy_num ops_policy_num,
       ops.sign_date ops_sign_date,
       ops.ag_contract_num ops_ag_contract_num,
       ops.kv_flag ops_kv_flag
FROM etl.npf_ops_policy ops
     LEFT JOIN ins.ag_npf_volume_det d ON (d.snils LIKE '%'||SUBSTR((SUBSTR(ops.policy_num,INSTR(ops.policy_num,'-') + 1)),1,
                                                               (INSTR(SUBSTR(ops.policy_num,INSTR(ops.policy_num,'-') + 1),'-')) - 1
                                                               )||'%'
                                           )
     LEFT JOIN ins.ag_volume agv ON (d.ag_volume_id = agv.ag_volume_id)
     LEFT JOIN ins.ven_ag_roll rl ON (rl.ag_roll_id = agv.ag_roll_id)
     LEFT JOIN ins.ven_ag_roll_header arh ON (rl.ag_roll_header_id = arh.ag_roll_header_id)
WHERE ops.policy_num LIKE (SELECT r.param_value
                           FROM ins_dwh.rep_param r
                           WHERE r.rep_name = 'is_ops'
                             AND r.param_name = 'snils'
                           );

