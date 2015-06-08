CREATE OR REPLACE VIEW V_SECOND_RLA AS
SELECT ag_fio "ФИО агента",
       agent_num "Номер агента",
       manager_name "Менеджер",
       recruter_name "Раздатчик",
       direct_agent "Прямой агент по договору",
       direct_agent_recruter "Раздатчик прямого агента",
       prem_detail_name "Тип премии",
       product "Продукт",
       Ids "ИДС",
       pol_num "Номер полиса",
       insuer "Страхователь",
       trans_sum "Сумма транзакции",
       epg "Номер ЭПГ",
       epg_date "Дата ЭПГ",
       payment_DATE "Дата платежа",
       pay_period "Период оплаты",
       ins_period "Период страхования",
       vol_amount "Сумма",
       vol_rate "Тариф",
       vol_units "Единицы",
       vol_kv "КВ",
       vol_decrease "Понижающий коэфф.",
       vol_kv_to "КВ к перечислению" 
FROM
(
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product,
       Ids,
       pol_num,
       insuer,
       trans_sum,
       epg,
       epg_date,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       (CASE WHEN vol_rate = -1 THEN 0 ELSE vol_rate END) vol_rate,
       vol_units,
       vol_amount * (CASE WHEN vol_rate = -1 THEN 1 ELSE vol_rate END) * vol_units vol_kv,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE vol_decrease END vol_decrease,
       vol_amount * (CASE WHEN vol_rate = -1 THEN 1 ELSE vol_rate END) * vol_units * vol_decrease vol_kv_to      
       /*ROUND(vol_amount,2) "Сумма",
       ROUND(vol_rate,2) "Тариф",
       ROUND(vol_units,2) "Единицы",
       ROUND(vol_amount * vol_rate * vol_units,2) "КВ",
       CASE WHEN vol_decrease = 1 THEN 0 ELSE ROUND(vol_decrease,2) END "Понижающий коэфф.",
       ROUND(vol_amount * vol_rate * vol_units * vol_decrease,2) "КВ к перечислению"*/       
FROM
(
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       risk product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       vol_rate,
       SUM(vol_units) vol_units,
       vol_decrease,
       epg_date
FROM
(
SELECT arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig--||'_'||DECODE(agc.leg_pos,1,'ФЛ',3,'ФЛ',101,'ЮЛ','ПБОЮЛ')
        FROM ins.ag_contract ag,
             ins.ag_contract agc,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_recrut_id
          AND ag.contract_id = agc.contract_id
          AND arh.date_end BETWEEN agc.date_begin AND agc.date_end
          AND agc.contract_id = aghr.ag_contract_header_id
          AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       (SELECT ag_ds.num||'_'||c.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ven_ag_contract_header ag_ds
            ,ins.contact c
            /*,ins.document d
            ,ins.doc_status_ref rf*/
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.agent_id = c.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent,
       (SELECT agh_lead.num||'_'||c_lead.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ag_contract_header ag_ds
            /*,ins.document d
            ,ins.doc_status_ref rf*/
            ,ins.ag_contract ag
            ,ins.ag_contract ag_lead
            ,ins.ven_ag_contract_header agh_lead
            ,ins.contact c_lead
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.contract_recrut_id = ag_lead.ag_contract_id
          AND ag_lead.contract_id = agh_lead.ag_contract_header_id
          AND agh_lead.agent_id = c_lead.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent_recruter,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_rate,0) vol_rate,
       NVL(apv.vol_units,0) vol_units,
       NVL(apv.vol_amount,0) vol_amount,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sec_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'sec_rla'
                AND r.param_name = 'ver_ved')
   /*AND arh.num= '000424'
   AND ar.num = 1*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_MANAG_STRUCTURE','RLA_CONTRIB_YEARS')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
   AND tp.brief IN ('END','END_2','PEPR','PEPR_2','CHI','CHI_2','TERM','TERM_2')
   /*AND ph.ids = 1920057169*/
)
GROUP BY ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       risk,
       Ids,
       pol_num,
       insuer,
       epg,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       vol_rate,
       vol_decrease,
       epg_date
UNION ALL
/*Группировка для не Семья, Дети, Будущее, Гармония*/
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product_name product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       vol_rate,
       SUM(vol_units) vol_units,
       vol_decrease,
       epg_date
FROM
(
SELECT arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig--||'_'||DECODE(agc.leg_pos,1,'ФЛ',3,'ФЛ',101,'ЮЛ','ПБОЮЛ')
        FROM ins.ag_contract ag,
             ins.ag_contract agc,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_recrut_id
          AND ag.contract_id = agc.contract_id
          AND arh.date_end BETWEEN agc.date_begin AND agc.date_end
          AND agc.contract_id = aghr.ag_contract_header_id
          AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       (SELECT ag_ds.num||'_'||c.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ven_ag_contract_header ag_ds
            ,ins.contact c
            /*,ins.document d
            ,ins.doc_status_ref rf*/
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.agent_id = c.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent,
       (SELECT agh_lead.num||'_'||c_lead.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ag_contract_header ag_ds
            /*,ins.document d
            ,ins.doc_status_ref rf*/
            ,ins.ag_contract ag
            ,ins.ag_contract ag_lead
            ,ins.ven_ag_contract_header agh_lead
            ,ins.contact c_lead
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.contract_recrut_id = ag_lead.ag_contract_id
          AND ag_lead.contract_id = agh_lead.ag_contract_header_id
          AND agh_lead.agent_id = c_lead.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent_recruter,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_rate,0) vol_rate,
       NVL(apv.vol_units,0) vol_units,
       NVL(apv.vol_amount,0) vol_amount,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date,
       tp.description product_name
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sec_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'sec_rla'
                AND r.param_name = 'ver_ved')
   /*AND arh.num= '000424'
   AND ar.num = 1*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_MANAG_STRUCTURE','RLA_CONTRIB_YEARS')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
   AND tp.brief NOT IN ('END','END_2','PEPR','PEPR_2','CHI','CHI_2','TERM','TERM_2')
   /*AND ph.ids = 1920057169*/
)
GROUP BY ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product_name,
       Ids,
       pol_num,
       insuer,
       epg,
       payment_DATE,
       pay_period,
       ins_period,
       vol_amount,
       vol_rate,
       vol_decrease,
       epg_date
/**/
)
UNION ALL
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       risk product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       epg_date,
       payment_DATE,
       pay_period,
       ins_period,
       detail_rate detail_amt,
       SUM(detail_vol_units) detail_rate,
       SUM(detail_amt) vol_units,
       SUM(detail_commis) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE vol_decrease END vol_decrease,
       SUM(detail_commis) * vol_decrease
       /*ROUND(SUM(detail_amt),2) detail_amt,
       ROUND(detail_rate,2) detail_rate,
       ROUND(SUM(detail_vol_units),2) vol_units,
       ROUND(SUM(detail_commis),2) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE ROUND(vol_decrease,2) END vol_decrease,
       ROUND(SUM(detail_commis) * vol_decrease,2)*/
FROM
(
SELECT arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig--||'_'||DECODE(agc.leg_pos,1,'ФЛ',3,'ФЛ',101,'ЮЛ','ПБОЮЛ')
        FROM ins.ag_contract ag,
             ins.ag_contract agc,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_recrut_id
          AND ag.contract_id = agc.contract_id
          AND arh.date_end BETWEEN agc.date_begin AND agc.date_end
          AND agc.contract_id = aghr.ag_contract_header_id
          AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       (SELECT ag_ds.num||'_'||c.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ven_ag_contract_header ag_ds
            ,ins.contact c
            /*,ins.document d
            ,ins.doc_status_ref rf*/
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.agent_id = c.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent,
       (SELECT agh_lead.num||'_'||c_lead.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ag_contract_header ag_ds
            /*,ins.document d
            ,ins.doc_status_ref rf*/
            ,ins.ag_contract ag
            ,ins.ag_contract ag_lead
            ,ins.ven_ag_contract_header agh_lead
            ,ins.contact c_lead
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.contract_recrut_id = ag_lead.ag_contract_id
          AND ag_lead.contract_id = agh_lead.ag_contract_header_id
          AND agh_lead.agent_id = c_lead.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent_recruter,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_amount,0) detail_amt,
       NVL(apv.vol_rate,0) detail_rate,
       NVL(apv.vol_units,0) detail_vol_units,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.vol_amount*apv.vol_rate detail_commis,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sec_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'sec_rla'
                AND r.param_name = 'ver_ved')
   /*AND arh.num= '000424'
   AND ar.num = 1*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_PERSONAL_POL')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
   AND tp.brief IN ('END','END_2','PEPR','PEPR_2','CHI','CHI_2','TERM','TERM_2')
   /*AND ph.ids = 1920057169*/
)
GROUP BY ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       risk,
       Ids,
       pol_num,
       insuer,
       payment_DATE,
       pay_period,
       epg,
       detail_rate,
       ins_period,
       vol_decrease,
       epg_date
UNION ALL
/*Группировка для не Семья, Дети, Будущее, Гармония*/
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product_name product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       epg_date,
       payment_DATE,
       pay_period,
       ins_period,
       detail_rate detail_amt,
       SUM(detail_vol_units) detail_rate,
       SUM(detail_amt) vol_units,
       SUM(detail_commis) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE vol_decrease END vol_decrease,
       SUM(detail_commis) * vol_decrease
       /*ROUND(SUM(detail_amt),2) detail_amt,
       ROUND(detail_rate,2) detail_rate,
       ROUND(SUM(detail_vol_units),2) vol_units,
       ROUND(SUM(detail_commis),2) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE ROUND(vol_decrease,2) END vol_decrease,
       ROUND(SUM(detail_commis) * vol_decrease,2)*/
FROM
(
SELECT arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig--||'_'||DECODE(agc.leg_pos,1,'ФЛ',3,'ФЛ',101,'ЮЛ','ПБОЮЛ')
        FROM ins.ag_contract ag,
             ins.ag_contract agc,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_recrut_id
          AND ag.contract_id = agc.contract_id
          AND arh.date_end BETWEEN agc.date_begin AND agc.date_end
          AND agc.contract_id = aghr.ag_contract_header_id
          AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       (SELECT ag_ds.num||'_'||c.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ven_ag_contract_header ag_ds
            ,ins.contact c
            /*,ins.document d
            ,ins.doc_status_ref rf*/
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.agent_id = c.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent,
       (SELECT agh_lead.num||'_'||c_lead.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ag_contract_header ag_ds
            /*,ins.document d
            ,ins.doc_status_ref rf*/
            ,ins.ag_contract ag
            ,ins.ag_contract ag_lead
            ,ins.ven_ag_contract_header agh_lead
            ,ins.contact c_lead
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.contract_recrut_id = ag_lead.ag_contract_id
          AND ag_lead.contract_id = agh_lead.ag_contract_header_id
          AND agh_lead.agent_id = c_lead.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent_recruter,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_amount,0) detail_amt,
       NVL(apv.vol_rate,0) detail_rate,
       NVL(apv.vol_units,0) detail_vol_units,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.vol_amount*apv.vol_rate detail_commis,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date,
       tp.description product_name
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sec_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'sec_rla'
                AND r.param_name = 'ver_ved')
   /*AND arh.num= '000424'
   AND ar.num = 1*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_PERSONAL_POL')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
   AND tp.brief NOT IN ('END','END_2','PEPR','PEPR_2','CHI','CHI_2','TERM','TERM_2')
   /*AND ph.ids = 1920057169*/
)
GROUP BY ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product_name,
       Ids,
       pol_num,
       insuer,
       payment_DATE,
       pay_period,
       epg,
       detail_rate,
       ins_period,
       vol_decrease,
       epg_date
/**/
/*RLA_VOLUME_GROUP*/
UNION ALL
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       risk product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       epg_date,
       payment_DATE,
       pay_period,
       ins_period,
       SUM(detail_amt) detail_amt,
       detail_rate,
       SUM(detail_vol_units) vol_units,
       SUM(detail_commis) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE vol_decrease END vol_decrease,
       SUM(detail_commis)
       /*ROUND(SUM(detail_amt),2) detail_amt,
       ROUND(detail_rate,2) detail_rate,
       ROUND(SUM(detail_vol_units),2) vol_units,
       ROUND(SUM(detail_commis),2) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE ROUND(vol_decrease,2) END vol_decrease,
       ROUND(SUM(detail_commis),2)*/
FROM
(
SELECT arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig--||'_'||DECODE(agc.leg_pos,1,'ФЛ',3,'ФЛ',101,'ЮЛ','ПБОЮЛ')
        FROM ins.ag_contract ag,
             ins.ag_contract agc,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_recrut_id
          AND ag.contract_id = agc.contract_id
          AND arh.date_end BETWEEN agc.date_begin AND agc.date_end
          AND agc.contract_id = aghr.ag_contract_header_id
          AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       (SELECT ag_ds.num||'_'||c.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ven_ag_contract_header ag_ds
            ,ins.contact c
            /*,ins.document d
            ,ins.doc_status_ref rf*/
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.agent_id = c.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent,
       (SELECT agh_lead.num||'_'||c_lead.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ag_contract_header ag_ds
            /*,ins.document d
            ,ins.doc_status_ref rf*/
            ,ins.ag_contract ag
            ,ins.ag_contract ag_lead
            ,ins.ven_ag_contract_header agh_lead
            ,ins.contact c_lead
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.contract_recrut_id = ag_lead.ag_contract_id
          AND ag_lead.contract_id = agh_lead.ag_contract_header_id
          AND agh_lead.agent_id = c_lead.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent_recruter,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_amount,0) detail_amt,
       NVL(apv.vol_rate,0) detail_rate,
       NVL(apv.vol_units,0) detail_vol_units,
       apv.vol_amount*apv.vol_rate*NVL(apv.vol_decrease,1) detail_commis,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sec_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'sec_rla'
                AND r.param_name = 'ver_ved')
   /*AND arh.num= '000424'
   AND ar.num = 1*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_VOLUME_GROUP')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
   AND tp.brief IN ('END','END_2','PEPR','PEPR_2','CHI','CHI_2','TERM','TERM_2')
   /*AND ph.ids = 1920057169*/
)
GROUP BY ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       risk,
       Ids,
       pol_num,
       insuer,
       payment_DATE,
       pay_period,
       epg,
       detail_rate,
       ins_period,
       vol_decrease,
       epg_date
UNION ALL
/*Группировка для не СЕмья, Дети, Будущее, Гармония*/
SELECT ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product_name product,
       Ids,
       pol_num,
       insuer,
       SUM(trans_sum) trans_sum,
       epg,
       epg_date,
       payment_DATE,
       pay_period,
       ins_period,
       SUM(detail_amt) detail_amt,
       detail_rate,
       SUM(detail_vol_units) vol_units,
       SUM(detail_commis) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE vol_decrease END vol_decrease,
       SUM(detail_commis)
       /*ROUND(SUM(detail_amt),2) detail_amt,
       ROUND(detail_rate,2) detail_rate,
       ROUND(SUM(detail_vol_units),2) vol_units,
       ROUND(SUM(detail_commis),2) detail_commis,
       CASE WHEN vol_decrease = 1 THEN 0 ELSE ROUND(vol_decrease,2) END vol_decrease,
       ROUND(SUM(detail_commis),2)*/
FROM
(
SELECT arh.num vedom,
       ar.num vedom_ver,
       ts.DESCRIPTION sales_ch,
       dep.NAME agency,
       aca.category_name,
       cn_a.obj_name_orig ag_fio,
       ach.num agent_num,
       tct.DESCRIPTION leg_pos,
       leader_ach.num leader_num,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig--||'_'||DECODE(agc.leg_pos,1,'ФЛ',3,'ФЛ',101,'ЮЛ','ПБОЮЛ')
        FROM ins.ag_contract ag,
             ins.ag_contract agc,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ac.contract_recrut_id
          AND ag.contract_id = agc.contract_id
          AND arh.date_end BETWEEN agc.date_begin AND agc.date_end
          AND agc.contract_id = aghr.ag_contract_header_id
          AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       (SELECT ag_ds.num||'_'||c.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ven_ag_contract_header ag_ds
            ,ins.contact c
            /*,ins.document d
            ,ins.doc_status_ref rf*/
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.agent_id = c.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent,
       (SELECT agh_lead.num||'_'||c_lead.obj_name_orig
        FROM ins.p_policy_agent_doc pad
            ,ins.ag_contract_header ag_ds
            /*,ins.document d
            ,ins.doc_status_ref rf*/
            ,ins.ag_contract ag
            ,ins.ag_contract ag_lead
            ,ins.ven_ag_contract_header agh_lead
            ,ins.contact c_lead
        WHERE pad.policy_header_id = ph.policy_header_id
          AND pad.ag_contract_header_id = ag_ds.ag_contract_header_id
          /*AND pad.p_policy_agent_doc_id = d.document_id
          AND d.doc_status_ref_id = rf.doc_status_ref_id
          AND rf.brief = 'CURRENT'*/
          AND av.payment_date_orig BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
          AND ag_ds.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.contract_recrut_id = ag_lead.ag_contract_id
          AND ag_lead.contract_id = agh_lead.ag_contract_header_id
          AND agh_lead.agent_id = c_lead.contact_id
          AND pad.p_policy_agent_doc_id = (SELECT MAX(pada.p_policy_agent_doc_id)
                                           FROM ins.p_policy_agent_doc pada
                                               ,ins.ag_contract_header ag_dsa
                                               /*,ins.document da
                                               ,ins.doc_status_ref rfa*/
                                           WHERE pada.ag_contract_header_id = ag_dsa.ag_contract_header_id
                                             AND pada.policy_header_id = ph.policy_header_id
                                             /*AND pada.p_policy_agent_doc_id = da.document_id
                                             AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                             AND rfa.brief = 'CURRENT'*/
                                             AND av.payment_date_orig BETWEEN pada.date_begin AND pada.date_end - 1 / 24 / 3600
                                           )
        ) direct_agent_recruter,
       cn_leader.obj_name_orig leader_fio,
       (SELECT asp.plan_value
         FROM ins.ag_sale_plan asp
        WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
          AND asp.plan_type = 1
          AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value,
       art.NAME prem_detail_name,
       avt.DESCRIPTION vol_type,
       ach_s.num agent_ad,
       cn_as.obj_name_orig agent_fio,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       ph.Ids,
       pp.pol_num,
       ph.start_date,
       cn_i.obj_name_orig insuer,
       NULL assured_birf_date,
       NULL gender,
       (SELECT num FROM ins.document d WHERE d.document_id=av.epg_payment) epg,
       NVL(av.payment_date_orig,av.payment_date) payment_date,
       tplo.DESCRIPTION risk,
       av.pay_period,
       av.ins_period,
       pt.DESCRIPTION payment_term,
       av.nbv_coef,
       av.trans_sum ,
       av.index_delta_sum,
       NVL(apv.vol_amount,0) detail_amt,
       NVL(apv.vol_rate,0) detail_rate,
       NVL(apv.vol_units,0) detail_vol_units,
       apv.vol_amount*apv.vol_rate*NVL(apv.vol_decrease,1) detail_commis,
       NVL(apv.vol_decrease,1) vol_decrease,
       apv.ag_perf_work_vol_id,
       apd.ag_perfom_work_det_id,
       av.epg_date,
       tp.description product_name
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.ven_ag_contract_header ach_s,
       ins.ven_ag_contract_header leader_ach,
       ins.ven_ag_contract leader_ac,
       ins.contact cn_leader,
       ins.contact cn_as,
       ins.contact cn_a,
       ins.department dep,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.t_contact_type tct,
       ins.p_pol_header ph,
       ins.t_product tp,
       ins.t_prod_line_option tplo,
       ins.t_payment_terms pt,
       ins.p_policy pp,
       ins.contact cn_i
 WHERE 1=1
   AND arh.num= LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sec_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                FROM ins_dwh.rep_param r
                WHERE r.rep_name = 'sec_rla'
                AND r.param_name = 'ver_ved')
   /*AND arh.num= '000424'
   AND ar.num = 1*/
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND art.brief IN ('RLA_VOLUME_GROUP')
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND apv.ag_volume_id = av.ag_volume_id
   AND av.policy_header_id = ph.policy_header_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_contract_header_id = ach_s.ag_contract_header_id
   AND ach_s.agent_id = cn_as.contact_id
   AND ac.contract_f_lead_id = leader_ac.ag_contract_id (+)
   AND leader_ac.contract_id = leader_ach.ag_contract_header_id (+)
   AND leader_ach.agent_id = cn_leader.contact_id (+)
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = tp.product_id
   AND tplo.id = av.t_prod_line_option_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_i.contact_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.agency_id = dep.department_id
   AND ac.ag_sales_chn_id = ts.ID
   AND ac.category_id = aca.ag_category_agent_id
   AND cn_a.contact_id = ach.agent_id
   AND tct.id = ac.leg_pos
   AND pt.id = av.payment_term_id
   AND tp.brief NOT IN ('END','END_2','PEPR','PEPR_2','CHI','CHI_2','TERM','TERM_2')
   /*AND ph.ids = 1920057169*/
)
GROUP BY ag_fio,
       agent_num,
       manager_name,
       recruter_name,
       direct_agent,
       direct_agent_recruter,
       prem_detail_name,
       product_name,
       Ids,
       pol_num,
       insuer,
       payment_DATE,
       pay_period,
       epg,
       detail_rate,
       ins_period,
       vol_decrease,
       epg_date
)
WHERE (UPPER(direct_agent) LIKE '%'||UPPER('Мирумян Ромуальд Владимирович')||'%'
       AND UPPER(ag_fio) LIKE '%'||UPPER('Мальшакова Елена Викторовна')||'%'
      AND prem_detail_name NOT IN ('Комиссионное вознаграждение за руководство структурами','Комиссионное вознаграждение за взносы последующих лет')
      ) OR (UPPER(direct_agent) LIKE '%'||UPPER('Мирумян Ромуальд Владимирович')||'%'
            AND UPPER(ag_fio) NOT LIKE '%'||UPPER('Мальшакова Елена Викторовна')||'%')
        OR (UPPER(direct_agent) NOT LIKE '%'||UPPER('Мирумян Ромуальд Владимирович')||'%')
        OR (direct_agent IS NULL)
ORDER BY ag_fio, pol_num, product ASC, payment_DATE DESC;
