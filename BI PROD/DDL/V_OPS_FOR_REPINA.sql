CREATE OR REPLACE VIEW V_OPS_FOR_REPINA AS
WITH all_agent AS
    (SELECT ach.ag_contract_header_id agent_ag_id,
            ach.agent_id agent_id,
            ach.num ad_num,
            cna.obj_name_orig agent_name,
            aca.category_name agent_category,
            dep.NAME agent_agency,
            acs.DESCRIPTION agent_sales_chanel,
            DECODE(nvl(mat_leave.contact_id,0),0,'','Декрет') mat_lv,
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
                                                              WHERE r.rep_name = 'OPS_FOR_REPINA'
                                                                AND r.param_name = 'ag_date'),'dd.mm.yyyy'))
                      END
            END mng_break
       FROM ins.ven_ag_contract_header ach,
            ins.ag_contract ac,
            ins.contact cna,
            ins.ag_category_agent aca,
            ins.department dep,
            ins.t_sales_channel acs,
            ins.ag_agent_tree aat,
            (select * from
              (select ci.contact_id, ci.id_value id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
                from ins.cn_contact_ident ci, ins.t_id_type it
               where ci.id_type = it.id
                 and it.brief = 'MATERNITY_LEAVE'
                 and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'OPS_FOR_REPINA' and param_name = 'ag_date') between ci.issue_date and nvl(ci.termination_date,to_date('31.12.3000','dd.mm.yyyy'))
               ) lv
             where lv.rn = 1) mat_leave
      WHERE ach.ag_contract_header_id = ac.contract_id
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'OPS_FOR_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN ac.date_begin AND ac.date_end
        AND ac.category_id = aca.ag_category_agent_id
        AND ac.agency_id = dep.department_id
        AND acs.ID = ach.t_sales_channel_id
        AND cna.contact_id = ach.agent_id
        AND aat.ag_contract_header_id = ach.ag_contract_header_id
        AND mat_leave.contact_id(+) = cna.contact_id
        AND acs.id NOT IN (8,10,81,16)
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'OPS_FOR_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN aat.date_begin AND aat.date_end)
-- V_OPS_FOR_REPINA
SELECT num,
       prod_desc,
       epg_id,
       set_off_amt_rur,
       set_off_amt_rur set_off_amt_rur_everyquat,
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
       ad_num agent_id,
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
       CASE
         WHEN agent_category = 'Менеджер' THEN
          aa_leave
         ELSE
          (CASE
         WHEN agent_category = 'Агент'
              AND leader_cat = 'Менеджер' THEN
          la_leave
         ELSE
          ''
       END) END group_manag_decret,
       ag_contract_num,
       status_name,
       ops_is_kv,
       null as leader_mng_break
      ,vedom_num
      ,version_num
      ,null Nbv_koef_for_commiss
      ,version_status
  FROM (SELECT NOp.Policy_Num num,
               NULL epg_id,
               CASE
                 WHEN np.Birth_Date >= '01.01.1967' THEN
                  CASE
                 WHEN FLOOR(MONTHS_BETWEEN(NOp.sign_date, np.birth_date) / 12) >= 24 THEN
                  500
                 ELSE
                  0
               END ELSE 0 END set_off_amt_rur,
               NULL set_off_amt,
               NULL set_off_date,
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
               NULL num2,
               aa.agent_ag_id,
               aa.ad_num,
               aa.agent_name,
               aa.agent_category,
               aa.agent_agency,
               aa.agent_sales_chanel,
               aa.mat_lv aa_leave,
               la.agent_ag_id leader_ag_ad_id,
               la.ad_num leader_ad_num,
               la.agent_name leader_name,
               la.agent_category leader_cat,
               la.agent_agency leader_agency,
               nvl(aa.mng_break, la.mng_break) ag_mng_break,
               la.mat_lv la_leave,
               NULL policy_sales_channel,
               nop.ag_contract_num,
               nsr.status_name status_name,
               nop.kv_flag ops_is_kv
              ,npr.product_name as prod_desc
              ,rh.num           as vedom_num
              ,ar.num           as version_num
              ,dsr.name         as version_status
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
                   AND ach.is_new = 1
                   AND ach.t_sales_channel_id NOT IN (8,10,81,16)
                 ) ach
              ,all_agent aa
              ,all_agent la
              ,ins.ag_npf_volume_det  vd
              ,ins.ag_volume          av
              ,ins.ven_ag_roll        ar
              ,ins.ven_ag_roll_header rh
              ,document               dc
              ,doc_status_ref         dsr
         WHERE 1=1
           and np.snils             = vd.snils
           and vd.ag_volume_id      = av.ag_volume_id
           and av.ag_roll_id        = ar.ag_roll_id
           and ar.ag_roll_header_id = rh.ag_roll_header_id
           and ar.ag_roll_id        = dc.document_id
           and dc.doc_status_ref_id = dsr.doc_status_ref_id
           and rh.ops_sign_date between to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'OPS_FOR_REPINA'
                                      AND r.param_name = 'date_from_ops'),'dd.mm.yyyy') and
                                      to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'OPS_FOR_REPINA'
                                      AND r.param_name = 'date_to_ops'),'dd.mm.yyyy')
           AND nop.sign_date between to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'OPS_FOR_REPINA'
                                      AND r.param_name = 'date_from_ops'),'dd.mm.yyyy') and
                                      to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'OPS_FOR_REPINA'
                                      AND r.param_name = 'date_to_ops'),'dd.mm.yyyy')
           AND npr.product_id IN (1,5)
           AND npr.product_id = nop.product_id
           AND nop.person_id = np.person_id
           AND nop.status_ref_id = nsr.status_ref_id
           AND nop.ag_contract_num = ach.num (+)
           AND ach.ag_contract_header_id = aa.agent_ag_id(+)
           AND aa.ag_parent_header_id = la.agent_ag_id(+)
           and vd.npf_det_type        = 'OPS'
           AND nop.policy_num not in
               (select a.ops_num from etl.tmp_ops_nums_for_delete a)
        );
