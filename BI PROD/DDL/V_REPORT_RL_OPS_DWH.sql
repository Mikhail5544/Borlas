CREATE OR REPLACE VIEW INS.V_REPORT_RL_OPS_DWH AS
SELECT num,
prod_desc,
epg_id,
set_of_amt_rur,
NVL(set_of_amt_rur_everyquat * NVL(nbv_koef_for_commiss,1),nvl(set_off_amt_rur_pd4_a7,set_of_amt_rur)) set_of_amt_rur_everyquat,
set_of_amt,
set_off_date,
set_off_rate,
payment_templ_title,
pay_date,
pp_reg_date,
pp_fund,
doc_set_off_id,
pd4_date,
coll_metod,
pol_header_id,
first_epg,
start_date,
is_group_flag,
plan_date,
num2,
agent_ag_id,
agent_id,
agent_name,
agent_category,
agent_agency,
agent_sales_chanel,
ag_mng_break,
policy_sales_channel,
leader_ag_ad_id,
leader_ad_num,
leader_name,
leader_cat,
leader_agency,
sign,
nbv,
agent_new_sales,
agmandir_new_sales,
ops_life,
(CASE WHEN group_manag_decret IS NOT NULL THEN '' ELSE group_manag END) group_manag,
group_manag_decret,
ag_contract_num,
status_name,
ops_is_kv,
leader_mng_break,
vedom_num,
version_num,
nbv_koef_for_commiss,
version_status,
nvl(set_off_amt_rur_pd4_a7,set_of_amt_rur) as set_off_amt_rur_all_payments,
td_ru_dep,
(CASE WHEN (CASE WHEN group_manag_decret IS NOT NULL
                  THEN ''
                 ELSE group_manag
            END) IS NOT NULL
       THEN (CASE WHEN agent_category = 'Менеджер'
                   THEN agent_id
                  WHEN agent_category = 'Агент' AND leader_cat = 'Менеджер'
                   THEN leader_ad_num
                  ELSE ''
             END)
       ELSE ''
 END ) id_group_manag,
(CASE WHEN (agent_category = 'Директор агентства 1 года' OR agent_category = 'Директор агентства 2 года')
       THEN agent_name
      WHEN agent_category = 'Менеджер' AND (leader_cat = 'Директор агентства 1 года' OR leader_cat = 'Директор агентства 2 года')
       THEN leader_name
      WHEN agent_category = 'Агент' AND (leader_cat = 'Директор агентства 1 года' OR leader_cat = 'Директор агентства 2 года')
       THEN leader_name
      WHEN agent_category = 'Агент' AND leader_cat = 'Агент'
       THEN (SELECT c.obj_name_orig
             FROM ins.ag_contract ag,
                  ins.ag_contract agl,
                  ins.ag_contract agt,
                  ins.ag_contract_header agh,
                  ins.contact c
             WHERE ag.contract_id = leader_ag_ad_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN ag.date_begin AND ag.date_end
               AND ag.contract_leader_id = agl.ag_contract_id
               AND agl.contract_id = agt.contract_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN agt.date_begin AND agt.date_end
               AND agt.contract_id = agh.ag_contract_header_id
               AND agh.agent_id = c.contact_id
               AND ROWNUM = 1
              )
      WHEN agent_category = 'Агент' AND leader_cat = 'Менеджер' AND (SELECT cat.category_name
                                                                     FROM ins.ag_contract ag,
                                                                          ins.ag_contract agl,
                                                                          ins.ag_contract agt,
                                                                          ins.ag_category_agent cat
                                                                     WHERE ag.contract_id = leader_ag_ad_id
                                                                       AND (SELECT trl.ag_tree_date
                                                                            FROM ins.t_rl_ops_date trl
                                                                            WHERE trl.enabled = 1) BETWEEN ag.date_begin AND ag.date_end
                                                                       AND ag.contract_leader_id = agl.ag_contract_id
                                                                       AND agl.contract_id = agt.contract_id
                                                                       AND (SELECT trl.ag_tree_date
                                                                            FROM ins.t_rl_ops_date trl
                                                                            WHERE trl.enabled = 1) BETWEEN agt.date_begin AND agt.date_end
                                                                       AND agt.category_id = cat.ag_category_agent_id
                                                                       AND ROWNUM = 1
                                                                     ) IN ('Директор агентства 1 года','Директор агентства 2 года')
       THEN (SELECT c.obj_name_orig
             FROM ins.ag_contract ag,
                  ins.ag_contract agl,
                  ins.ag_contract agt,
                  ins.ag_contract_header agh,
                  ins.contact c
             WHERE ag.contract_id = leader_ag_ad_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN ag.date_begin AND ag.date_end
               AND ag.contract_leader_id = agl.ag_contract_id
               AND agl.contract_id = agt.contract_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN agt.date_begin AND agt.date_end
               AND agt.contract_id = agh.ag_contract_header_id
               AND agh.agent_id = c.contact_id
               AND ROWNUM = 1
             )
 ELSE ''
 END) fio_director
FROM ins.RL_FOR_DWH
UNION all
SELECT num,
prod_desc,
epg_id,
set_off_amt_rur,
set_off_amt_rur_everyquat * NVL(nbv_koef_for_commiss,1) set_off_amt_rur_everyquat,
set_off_amt,
set_off_date,
set_off_rate,
payment_templ_title,
pay_date,
pp_reg_date,
pp_fund,
doc_set_off_id,
pd4_date,
coll_metod,
pol_header_id,
first_epg,
start_date,
is_group_flag,
plan_date,
num2,
agent_ag_id,
agent_id,
agent_name,
agent_category,
agent_agency,
agent_sales_chanel,
ag_mng_break,
policy_sales_channel,
leader_ag_ad_id,
leader_ad_num,
leader_name,
leader_cat,
leader_agency,
sign,
nbv,
agent_new_sales,
agmandir_new_sales,
ops_life,
(CASE WHEN group_manag_decret IS NOT NULL THEN '' ELSE group_manag END) group_manag,
group_manag_decret,
ag_contract_num,
status_name,
ops_is_kv,
leader_mng_break,
vedom_num,
version_num,
nbv_koef_for_commiss,
version_status,
null,
td_ru_dep,
(CASE WHEN (CASE WHEN group_manag_decret IS NOT NULL
                  THEN ''
                 ELSE group_manag
            END) IS NOT NULL
       THEN (CASE WHEN agent_category = 'Менеджер'
                   THEN agent_id
                  WHEN agent_category = 'Агент' AND leader_cat = 'Менеджер'
                   THEN leader_ad_num
                  ELSE ''
             END)
       ELSE ''
 END ) id_group_manag,
(CASE WHEN (agent_category = 'Директор агентства 1 года' OR agent_category = 'Директор агентства 2 года')
       THEN agent_name
      WHEN agent_category = 'Менеджер' AND (leader_cat = 'Директор агентства 1 года' OR leader_cat = 'Директор агентства 2 года')
       THEN leader_name
      WHEN agent_category = 'Агент' AND (leader_cat = 'Директор агентства 1 года' OR leader_cat = 'Директор агентства 2 года')
       THEN leader_name
      WHEN agent_category = 'Агент' AND leader_cat = 'Агент'
       THEN (SELECT c.obj_name_orig
             FROM ins.ag_contract ag,
                  ins.ag_contract agl,
                  ins.ag_contract agt,
                  ins.ag_contract_header agh,
                  ins.contact c
             WHERE ag.contract_id = leader_ag_ad_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN ag.date_begin AND ag.date_end
               AND ag.contract_leader_id = agl.ag_contract_id
               AND agl.contract_id = agt.contract_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN agt.date_begin AND agt.date_end
               AND agt.contract_id = agh.ag_contract_header_id
               AND agh.agent_id = c.contact_id
               AND ROWNUM = 1
              )
      WHEN agent_category = 'Агент' AND leader_cat = 'Менеджер' AND (SELECT cat.category_name
                                                                     FROM ins.ag_contract ag,
                                                                          ins.ag_contract agl,
                                                                          ins.ag_contract agt,
                                                                          ins.ag_category_agent cat
                                                                     WHERE ag.contract_id = leader_ag_ad_id
                                                                       AND (SELECT trl.ag_tree_date
                                                                            FROM ins.t_rl_ops_date trl
                                                                            WHERE trl.enabled = 1) BETWEEN ag.date_begin AND ag.date_end
                                                                       AND ag.contract_leader_id = agl.ag_contract_id
                                                                       AND agl.contract_id = agt.contract_id
                                                                       AND (SELECT trl.ag_tree_date
                                                                            FROM ins.t_rl_ops_date trl
                                                                            WHERE trl.enabled = 1) BETWEEN agt.date_begin AND agt.date_end
                                                                       AND agt.category_id = cat.ag_category_agent_id
                                                                       AND ROWNUM = 1
                                                                     ) IN ('Директор агентства 1 года','Директор агентства 2 года')
       THEN (SELECT c.obj_name_orig
             FROM ins.ag_contract ag,
                  ins.ag_contract agl,
                  ins.ag_contract agt,
                  ins.ag_contract_header agh,
                  ins.contact c
             WHERE ag.contract_id = leader_ag_ad_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN ag.date_begin AND ag.date_end
               AND ag.contract_leader_id = agl.ag_contract_id
               AND agl.contract_id = agt.contract_id
               AND (SELECT trl.ag_tree_date
                    FROM ins.t_rl_ops_date trl
                    WHERE trl.enabled = 1) BETWEEN agt.date_begin AND agt.date_end
               AND agt.contract_id = agh.ag_contract_header_id
               AND agh.agent_id = c.contact_id
               AND ROWNUM = 1
             )
 ELSE ''
 END) fio_director
FROM ins.OPS_FOR_DWH;
