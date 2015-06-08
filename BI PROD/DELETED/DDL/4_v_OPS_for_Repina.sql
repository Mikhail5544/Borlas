create or replace view v_OPS_for_Repina as

WITH all_agent AS 
    (SELECT ach.ag_contract_header_id agent_ag_id,
            ach.agent_id agent_id,
            ach.num ad_num,
            cna.obj_name_orig agent_name,
            aca.category_name agent_category,
            dep.NAME agent_agency,
            acs.DESCRIPTION agent_sales_chanel,
            aat.ag_parent_header_id,
            CASE WHEN aca.ag_category_agent_id = 3
                 THEN CASE WHEN to_date(decode(ach.date_break, TO_DATE('31.12.2999') , NULL , ach.date_break)) IS NOT NULL
                           THEN to_date(decode(ach.date_break, TO_DATE('31.12.2999') , NULL , ach.date_break))
                      ELSE (SELECT min(ac_f.date_begin)
                              FROM ins.ag_contract ac_f
                             WHERE ac_f.contract_id = ach.ag_contract_header_id
                               AND ac_f.category_id = 2
                               AND ac_f.date_begin > to_date((SELECT r.param_value
                                                              FROM ins_dwh.rep_param r
                                                              WHERE r.rep_name = 'OPS_REPINA'
                                                                AND r.param_name = 'ag_date'),'dd.mm.yyyy')/*&p_ag_date*/)
                      END
            END mng_break
       FROM ins.ven_ag_contract_header ach,
            ins.ag_contract ac,
            ins.contact cna,
            ins.ag_category_agent aca,
            ins.department dep,
            ins.t_sales_channel acs,
            ins.ag_agent_tree aat
      WHERE ach.ag_contract_header_id = ac.contract_id
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'OPS_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy')/*&p_ag_date*/ BETWEEN ac.date_begin AND ac.date_end
        AND ac.category_id = aca.ag_category_agent_id
        AND ac.agency_id = dep.department_id
        AND acs.ID = ach.t_sales_channel_id
        AND cna.contact_id = ach.agent_id
        AND aat.ag_contract_header_id = ach.ag_contract_header_id
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'OPS_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy')/*&p_ag_date*/ BETWEEN aat.date_begin AND aat.date_end)

SELECT num,
       epg_id,
       set_of_amt_rur,
       set_of_amt_rur set_of_amt_rur_everyquat,
       set_of_amt,
       set_of_date,
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
       num1,
       agent_ag_id,
       ad_num agent_id,
       agent_name,
       agent_category,
       agent_agency,
       agent_sales_chanel,
       policy_sales_channel,
       leader_ag_ad_id,
       leader_ad_num,
       leader_name,
       leader_cat,
       leader_agency,
       mng_break,
       'ОПС' sign,
       'NBV' NBV,
       CASE
         WHEN agent_category = 'Агент' THEN
          'Агент'
         ELSE
          ''
       END agent_new_sales,
       agent_name agmandir_new_sales,
       'ОПС' OPS_Life,
       CASE
         WHEN agent_category = 'Менеджер' THEN
          agent_name
         ELSE
          (CASE
         WHEN agent_category = 'Агент'
              AND leader_cat = 'Менеджер' THEN
          leader_name
         ELSE
          ''
       END) END group_manag,
       ag_contract_num,
       status_name,
       ops_is_kv       
  FROM (SELECT NOp.Policy_Num num,
               NULL epg_id,
               CASE
                 WHEN np.Birth_Date >= '01.01.1967' THEN
                  CASE
                 WHEN FLOOR(MONTHS_BETWEEN(NOp.sign_date, np.birth_date) / 12) >= 24 THEN
                  500
                 ELSE
                  0
               END ELSE 0 END set_of_amt_rur,
               NULL set_of_amt,
               NULL set_of_date,
               NULL set_off_rate,
               NULL payment_templ_title,
               NULL pay_date,
               NULL pp_reg_date,
               NULL pp_fund,
               NULL doc_set_off_id,
               NULL pd4_date,
               NULL coll_metod,
               NULL pol_header_id,
               NULL first_epg,
               nop.notice_date start_date,
               NULL is_group_flag,
               NULL plan_date,
               NULL num1,
               aa.agent_ag_id,
               aa.ad_num,
               aa.agent_name,
               aa.agent_category,
               aa.agent_agency,
               aa.agent_sales_chanel,
               la.agent_ag_id leader_ag_ad_id,
               la.ad_num leader_ad_num,
               la.agent_name leader_name,
               la.agent_category leader_cat,
               la.agent_agency leader_agency,
               nvl(aa.mng_break, la.mng_break) mng_break,
               NULL policy_sales_channel,
               nop.ag_contract_num,
               nsr.status_name status_name,
               nop.kv_flag ops_is_kv        
          FROM etl.npf_person np,
               etl.npf_ops_policy nop,
               etl.npf_product npr,
               etl.npf_status_ref nsr,
--               etl.npf_policy_assured_m npa,
               (SELECT prev.a2 num,
                       ach.ag_contract_header_id,
                       ach.agency_id,
                       ach.agent_id
                  FROM ins.ven_ag_contract_header ach,
                       (SELECT *
                          FROM (SELECT ach.ag_contract_header_id a1,
                                       ach.num                   a2
                                  FROM ins.ven_ag_contract_header ach
                                 WHERE ach.is_new = 1
                                UNION
                                SELECT apd.ag_contract_header_id,
                                       'S' || apd.num
                                  FROM ins.ag_prev_dog apd)) prev
                
                 WHERE ach.ag_contract_header_id = prev.a1
                   AND ach.is_new = 1) ach,
               all_agent aa,
               all_agent la
         WHERE 1=1
           AND nop.sign_date between to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'OPS_REPINA'
                                      AND r.param_name = 'date_from'),'dd.mm.yyyy') and
                                      to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'OPS_REPINA'
                                      AND r.param_name = 'date_to'),'dd.mm.yyyy') --&p_begin_date AND &p_end_date
           AND npr.product_id IN (1,5)
           AND npr.product_id = nop.product_id
           AND nop.person_id = np.person_id
           AND nop.status_ref_id = nsr.status_ref_id
           AND nop.ag_contract_num = ach.num (+)
           AND ach.ag_contract_header_id = aa.agent_ag_id(+)
           AND aa.ag_parent_header_id = la.agent_ag_id(+)
           AND NOp.policy_num NOT IN
               (SELECT a.ops_num FROM etl.tmp_ops_nums_for_delete a)
        );

/

GRANT SELECT ON v_OPS_for_Repina TO INS_EUL;