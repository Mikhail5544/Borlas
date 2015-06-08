CREATE OR REPLACE FORCE VIEW V_COMMIS_FACT_PREVIEW_OAV AS
SELECT pp.pol_header_id pol_header,
       appdp.epg_payment_id com_epg,
       ph.start_date Date_from,

       (SELECT sum(pc2.fee)*acc.Get_Cross_Rate_By_Id(1,ph.fund_id,122,ph.start_date)
         FROM p_policy pp2,
              as_asset ass2,
              p_cover pc2,
              t_prod_line_option tplo2
        WHERE pp2.pol_header_id = ph.policy_header_id
          AND pp2.version_num = 1
          AND pp2.policy_id = ass2.p_policy_id
          AND ass2.as_asset_id = pc2.as_asset_id
          AND pc2.status_hist_id <> 3
          AND pc2.t_prod_line_option_id = tplo2.ID
          AND tplo2.DESCRIPTION <> 'Административные издержки') fee,--"Брутто взнос по 1ой",

       (SELECT sum(pc2.fee)*acc.Get_Cross_Rate_By_Id(1,ph.fund_id,122,ph.start_date)
         FROM p_policy pp2,
              as_asset ass2,
              p_cover pc2,
              t_prod_line_option tplo2
        WHERE pp2.pol_header_id = ph.policy_header_id
          AND pp2.version_num = 1
          AND pp2.policy_id = ass2.p_policy_id
          AND ass2.as_asset_id = pc2.as_asset_id
          AND pc2.status_hist_id <> 3
          AND pc2.t_prod_line_option_id = tplo2.ID
          AND tplo2.DESCRIPTION = 'Административные издержки') adm_cost,-- "Издержки по 1ой",

       (SELECT tp2.number_of_payments
         FROM p_policy pp2,
              t_payment_terms tp2
        WHERE pp2.pol_header_id = ph.policy_header_id
          AND pp2.version_num = 1
          AND tp2.ID = pp2.payment_term_id) pay_term, --"Переодичность по 1ой",

       --pkg_agent_1.get_agent_start_contr(ph.policy_header_id,2) f_date, --"Дата оплаты 1ого ЭПГ", --Заменить на дату ПП

      pkg_agent_1.get_agent_start_contr(ph.policy_id,4) f_date,

      (SELECT SUM(CASE WHEN acpt.brief = 'ПП' THEN  dso.Set_Off_Child_Amount ELSE bank_doc.set_off_child_amount END)
         FROM doc_doc      d,
              ven_ac_payment   ap,
              DOC_SET_OFF      dso,
              ven_ac_payment   pa2,
              AC_PAYMENT_TEMPL acpt,
              P_POLICY         pp2,
              (SELECT dd2.parent_id,
                      dso2.set_off_child_amount
                 FROM doc_doc     dd2,
                      doc_set_off dso2
                WHERE dso2.parent_doc_id = dd2.child_id
                  AND doc.get_doc_status_brief(dd2.child_id)='PAID') bank_doc
        WHERE pp2.pol_header_id = ph.policy_header_id
          AND d.parent_id = pp2.policy_id
          AND acpt.payment_templ_id = pa2.payment_templ_id
          AND ap.payment_id = d.child_id
          AND doc.get_doc_status_brief(pa2.payment_id) <> 'ANNULATED'
          AND dso.parent_doc_id = ap.payment_id
          AND dso.child_doc_id = pa2.payment_id
          AND bank_doc.parent_id (+) = pa2.payment_id
          AND (acpt.brief = 'A7' OR acpt.brief = 'PD4' OR acpt.brief = 'ПП')
          AND ap.payment_number IN (SELECT acp2.payment_number
                                    FROM ac_payment acp2,
                                         doc_doc dd2,
                                         p_policy pp3
                                   WHERE Doc.get_doc_status_brief(acp2.payment_id) = 'PAID'
                                     AND acp2.payment_id = dd2.child_id
                                     and dd2.parent_id = pp3.policy_id
                                     AND pp3.pol_header_id = ph.policy_header_id
                                     AND acp2.plan_date = (SELECT min(acp3.plan_date) --BUG: заявка 24279
                                                            FROM ac_payment acp3,
                                                                 doc_doc dd3,
                                                                 p_policy pp4
                                                           WHERE acp3.payment_number =1
                                                             AND acp3.payment_id = dd3.child_id
                                                             AND dd3.parent_id =  pp4.policy_id
                                                             AND pp4.pol_header_id =ph.policy_header_id))) f_pay,--"Сумма оплаты 1ого ЭПГ",

       --Базовое СГП
       --Приведенное СГП

       ach.ag_contract_header_id sale_ad, --"ID пр. АД",
       decode(ac.category_id, 2, 'Агент', 3, 'Менеджер', 4, 'Директор', 'Неизвестно') cat_ad, --"Категрия пр. на дату вед.",
       pkg_renlife_utils.get_ag_stat_brief(ach.ag_contract_header_id, arh.date_end) stat_ad,--"Статус пр. агента",

       (SELECT ach2.ag_contract_header_id
          FROM ag_contract ac2,
               ag_contract_header ach2
         WHERE ac2.ag_contract_id = ac.contract_leader_id
           AND ach2.ag_contract_header_id = ac2.contract_id) mng_ad, --"ID АД рук.",

       (SELECT ent.obj_name('CONTACT',ach2.agent_id)
          FROM ag_contract ac2,
               ag_contract_header ach2
         WHERE ac2.ag_contract_id = ac.contract_leader_id
           AND ach2.ag_contract_header_id = ac2.contract_id) fio_mng,

       (SELECT ach2.num
          FROM ag_contract ac2,
               ven_ag_contract_header ach2
         WHERE ac2.ag_contract_id = ac.contract_leader_id
           AND ach2.ag_contract_header_id = ac2.contract_id) ad_num_mng,

       (SELECT decode(ac3.category_id, 2, 'Агент', 3, 'Менеджер', 4, 'Директор', 'Неизвестно')
          FROM ag_contract ac2,
               ag_contract ac3
         WHERE ac2.ag_contract_id = ac.contract_leader_id
           AND ac3.ag_contract_id = pkg_agent_1.get_status_by_date(ac2.contract_id , arh.date_end)) cat_mng, --"Категория рук.",
       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac2.contract_id, arh.date_end)
          FROM ag_contract ac2
         WHERE ac2.ag_contract_id = ac.contract_leader_id) stat_mng, --"Статус рук. агента",

       ach_p.ag_contract_header_id get_ad, --"ID получ. АД",
       ent.obj_name('CONTACT',ach_p.agent_id) fio_get,
       ach_p.num ad_num_get,
       decode(ac_p.category_id, 2, 'Агент', 3, 'Менеджер', 4, 'Директор', 'Неизвестно') cat_get, --"Категрия получ. на дату вед.",
       pkg_renlife_utils.get_ag_stat_brief(ac_p.contract_id, arh.date_end) stat_get, --"Статус получ. агента",
       ent.obj_name('DEPARTMENT',ach_p.agency_id) get_agency,
       NULL month_num,

       'ОАВ' type_av,-- "Тип АВ",

       (SELECT MAX(ds.change_date)
          FROM doc_status ds
         WHERE ds.document_id = ar.ag_roll_id) calc_date,-- "Дата расчета АВ",
       --to_char(arh.date_end, 'Month') calc_per,--"Отчетный период",
       arh.date_end calc_per,
       art.NAME sub_type_av, --"Вид АВ",

       (SELECT sum(apwt.sum_commission)
          FROM ag_perf_work_trans apwt
         WHERE apwt.ag_perf_work_pay_doc_id = appdp.ag_perf_work_pay_doc_id) com_summ
      /* apd.summ*(apdp.summ/(SELECT SUM(apd4.SUMm)
                              FROM ag_perfom_work_dpol apd4
                             WHERE apd4.ag_perfom_work_det_id = apd.ag_perfom_work_det_id)) com_summ--"Сумма начисленого АВ"       */
       --apwt.sum_commission com_summ --"Сумма начисленого АВ"

  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_perfom_work_dpol apdp,
       ins.ag_perf_work_pay_doc appdp,
/*       ins.ag_perf_work_trans apwt,*/
       ins.ag_rate_type art,
       ins.ven_ag_contract_header ach,
       ins.ag_contract ac,
       ins.ven_ag_contract_header ach_p,
       ins.ag_contract ac_p,
       ins.p_policy pp,
       ins.p_pol_header ph
 WHERE 1=1
   AND arh.note IS NULL
   AND arh.ag_roll_type_id = 42
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id = apw.ag_roll_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apdp.ag_perfom_work_det_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apdp.ag_perfom_work_dpol_id = appdp.ag_preformed_work_dpol_id
--   AND appdp.ag_perf_work_pay_doc_id = apwt.ag_perf_work_pay_doc_id
   AND apdp.policy_id = pp.policy_id
   AND ph.policy_header_id = pp.pol_header_id
  -- AND ph.policy_header_id = 5965261
   AND ach.ag_contract_header_id = apdp.ag_contract_header_ch_id
   AND ac.ag_contract_id = pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, arh.date_end)
   AND ach_p.ag_contract_header_id = apw.ag_contract_header_id
   AND ac_p.ag_contract_id = pkg_agent_1.get_status_by_date(ach_p.ag_contract_header_id, arh.date_end)
;

