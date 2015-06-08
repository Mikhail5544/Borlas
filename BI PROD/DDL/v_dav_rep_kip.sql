CREATE OR REPLACE FORCE VIEW V_DAV_REP_KIP AS
SELECT c.ved_num "Номер ведомости",
       c.ver_num "Версия ведомости",
       ph.policy_header_id,
       pp.pol_ser,
       pp.pol_num,
       tp.product_id,
       tp.description "Продукт",
       tplo.id "id Риска",
       tplo.description "Риск",
       (select decode(ig.life_property, 1, 'Ж', 0, 'НС')
          from t_product_line pl, t_lob_line ll, t_insurance_group ig
         where pl.id = tplo.product_line_id
           and pl.t_lob_line_id = ll.t_lob_line_id
           and ll.insurance_group_id = ig.t_insurance_group_id) "Признак Ж/НС",
       ph.policy_id active_p_policy_id,
       ach.ag_contract_header_id,
       ach.agent_id,
       ach.num "Номер АД",
       ent.obj_name('CONTACT', ach.agent_id) "Агент ФИО",
       decode(ash.ag_category_agent_id,
              1,
              'Агент без категории',
              2,
              'Агент',
              3,
              'Менеджер',
              4,
              'Директор') "Категория агента на дату вед",
       (select a.name
          from ag_stat_agent a
         where a.ag_stat_agent_id = ash.ag_stat_agent_id) "Статус агента на дату вед",
       art.name "Тип АВ",

       null "Ставка",
       c.comiss_by_risk,
       c.date_calc "Дата расчёта BORLAS",
       calc_period "Отчётный период"

  FROM (select a.ved_num,
               a.ver_num,
               a.ag_roll_type_id,
               a.policy_id,
               a.date_calc,
               a.calc_period,
               a.ag_contract_header_id,
               a.ag_stat_hist_id,
               b.t_prod_line_option_id,
               a.apw_per_pol * b.premium / sum(b.premium) over(partition by a.ag_perfomed_work_act_id, a.policy_id) comiss_by_risk
          from (SELECT arh.num ved_num,
                       ar.num ver_num,
                       arh.date_begin || ' - ' || arh.date_end calc_period,
                       arh.ag_roll_type_id,
                       a.policy_id,
                       apw.date_calc,
                       apw.ag_contract_header_id,
                       apw.ag_stat_hist_id,
                       apw.ag_perfomed_work_act_id,
                       --apw.SUM,
                       apw.SUM *a.summ / sum(a.summ) over(partition by apw.ag_perfomed_work_act_id) apw_per_pol
                  FROM ven_ag_roll_header   arh,
                       ven_ag_roll          ar,
                       ag_perfomed_work_act apw,
                       (select apd.ag_perfomed_work_act_id,
                               apdp.policy_id,
                               sum(apdp.summ) summ
                          from ag_perfom_work_dpol  apdp,
                               ag_perfom_work_det   apd
                         where apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                       group by apd.ag_perfomed_work_act_id,
                                apdp.policy_id
                       ) a
                 WHERE 1 = 1 --arh.num = '000151'
                   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','DKIPRICH')
                   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav_kip' and param_name = 'rep_num')
                   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'rep_oav_kip' and param_name = 'version_num')
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND apw.ag_roll_id = ar.ag_roll_id
                   AND a.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                   --and apw.ag_perfomed_work_act_id = 14827406
                   and apw.SUM <> 0
                   ) a,
               (select aa.p_policy_id,
                       pc.t_prod_line_option_id,
                       sum(pc.premium) premium
                  from as_asset    aa,
                       status_hist sha,
                       p_cover     pc,
                       status_hist shp
                 where 1 = 1
                   and sha.status_hist_id = aa.status_hist_id
                   and sha.brief <> 'DELETED'
                   and pc.as_asset_id = aa.as_asset_id
                   and shp.status_hist_id = pc.status_hist_id
                   and shp.brief <> 'DELETED'
                 group by aa.p_policy_id, pc.t_prod_line_option_id) b
         where b.p_policy_id = a.policy_id) c,
       ag_stat_hist ash,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       t_prod_line_option tplo,
       t_product tp,
       ag_roll_type art
 WHERE 1 = 1
   AND pp.policy_id = c.policy_id
   AND pp.pol_header_id = ph.policy_header_id
   AND ach.ag_contract_header_id = c.ag_contract_header_id
   AND ash.ag_stat_hist_id = c.ag_stat_hist_id
   AND tplo.ID = c.t_prod_line_option_id
   AND ph.product_id = tp.product_id
   and art.ag_roll_type_id = c.ag_roll_type_id
;

