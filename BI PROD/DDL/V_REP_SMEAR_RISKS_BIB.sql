CREATE OR REPLACE VIEW V_REP_SMEAR_RISKS_BIB AS
WITH tmp_tab AS
 (SELECT /*+ NO_MERGE*/
   nvl(t.pol_header_id, 0) AS ph
  ,decode(nvl(t.pol_header_id, 0), 0, t.pol_num, to_char(t.POL_HEADER_ID)) AS ph_num
  ,t.bonus_type AS bonus_type
  ,Upper(t.Agent_name) AS Agent_name
  ,SUM(DISTINCT t.prem_percent) AS prem_percent
  ,SUM(t.prem) AS prem
    FROM distibution_risks t
   GROUP BY nvl(t.pol_header_id, 0)
           ,decode(nvl(t.pol_header_id, 0), 0, t.pol_num, to_char(t.POL_HEADER_ID))
           ,t.agent_number
           ,t.bonus_type
           ,Upper(t.Agent_name)
           ,t.prem_percent),
tmp_tab_date AS
 (SELECT /*+ NO_MERGE*/
   nvl(t.pol_header_id, 0) AS ph
  ,decode(nvl(t.pol_header_id, 0), 0, t.pol_num, to_char(t.POL_HEADER_ID)) AS ph_num
  ,t.bonus_type AS bonus_type
  ,Upper(t.Agent_name) AS Agent_name
  ,t.date_register AS date_register
  ,t.otch_period AS otch_period
  ,SUM(DISTINCT t.prem_percent) AS prem_percent
  ,SUM(t.prem) AS prem
    FROM distibution_risks t
   GROUP BY nvl(t.pol_header_id, 0)
           ,decode(nvl(t.pol_header_id, 0), 0, t.pol_num, to_char(t.POL_HEADER_ID))
           ,t.agent_number
           ,t.bonus_type
           ,Upper(t.Agent_name)
           ,t.date_register
           ,t.otch_period
           ,t.prem_percent)


SELECT /*+ LEADING (t b)*/
 NULL AS vedom_num
 ,NULL AS version_num
 ,b.policy_header_id AS policy_header_id
 ,b.pol_ser AS pol_ser
 ,nvl(b.pol_num, t.ph_num) AS pol_num
 ,b.prod_id AS prod_id
 ,CASE
   WHEN b.policy_header_id IS NULL THEN
    'OPS'
   ELSE
    b.prod_name
 END AS prod_name
 ,b.t_prod_line_option_id AS tplo_id
 ,b.tplo_name AS tplo_name
 ,b.tplo_type AS tplo_type
 ,b.active_pol AS active_p_policy_id
 ,NULL AS AG_CONTRACT_HEADER_ID
 ,NULL AS AGENT_ID
 ,NULL AS agent_num
 ,t.Agent_name AS Agent_name
 ,NULL AS agent_category
 ,NULL AS agent_state
 ,t.bonus_type AS av_type
 ,t.prem_percent AS av_rate
 ,t.prem * nvl(b.premium_ind / b.premium
              ,1) AS commission
 ,t.date_register AS date_calc_borlas
 ,t.otch_period   AS date_report
 ,b.p_cover_id
 ,b.parent_cover_rsbu_id
 ,b.parent_cover_ifrs_id
 ,b.MR_Channel
 ,b.MR_product
 ,ins.pkg_policy.get_pol_sales_chn(policy_header_id,'group') CHN_GROUP
 ,ins.pkg_policy.get_pol_product_group(policy_header_id) PROD_GPOUP
  FROM tmp_tab_date t
      , --??? Таблица ОРКВ с данными по КВ по договору???
       (SELECT /*+ LEADING(tm ph) NO_MERGE*/
        DISTINCT ph.policy_header_id
                ,pp.pol_ser
                ,pp.pol_num
                ,ph.policy_id active_pol
                ,tp.product_id prod_id
                ,tp.DESCRIPTION prod_name
                ,pc.t_prod_line_option_id
                ,tplo.description tplo_name
                ,decode(ig.life_property, 1, 'Ж', 0, 'НС') tplo_type
                ,pc.p_cover_id
                ,pc.fee premium_ind
                ,pc.parent_cover_rsbu_id
                ,pc.parent_cover_ifrs_id
                ,sch.descr_for_rep as MR_Channel
                ,pr.description    as MR_product
                ,sum(pc.fee)over(partition by tm.ph_num) premium
          FROM as_asset           aas
              ,p_policy           pp
              ,status_hist        sha
              ,p_pol_header       ph
              ,p_cover            pc
              ,status_hist        shp
              ,t_product          tp
              ,t_prod_line_option tplo
              ,t_product_line     pl
              ,t_lob_line         ll
              ,t_insurance_group  ig
              ,t_sales_channel    sch
              ,t_product          pr
              ,tmp_tab            tm              
         WHERE ph.policy_header_id = tm.ph
           AND ph.policy_id = aas.p_policy_id
           AND ph.product_id = tp.product_id
           AND pp.policy_id = ph.policy_id
           AND pc.as_asset_id = aas.as_asset_id
           AND sha.status_hist_id = aas.status_hist_id
           AND sha.brief <> 'DELETED'
           AND tplo.ID = pc.t_prod_line_option_id
           AND shp.status_hist_id = pc.status_hist_id
           AND shp.brief <> 'DELETED'
           AND tplo.description <> 'Административные издержки'
           AND tplo.description != 'Не страховые убытки'
           AND pl.id = tplo.product_line_id
           AND ll.t_lob_line_id = pl.t_lob_line_id
           AND ig.t_insurance_group_id = ll.insurance_group_id
           AND ph.sales_channel_id = sch.id
           and ph.product_id = pr.product_id
        ) b
 WHERE 1 = 1
   AND t.ph = b.policy_header_id(+)
;
