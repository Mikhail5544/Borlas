create or replace view ins_dwh.v_reserves_vs_profit_pheader as
SELECT ph.policy_header_id
      ,ph.fund_id
      ,ph.current_agent_id
      ,ph.product_id
      ,ph.sales_channel_id
      ,ph.start_date
      ,ph.ids
      ,ph.policy_id
      ,ph.ext_id
      ,ph.ass_count
      ,ph.description
      ,(SELECT dp.name
          FROM ins.ven_ag_contract_header ach
              ,ins.department             dp
         WHERE ach.ag_contract_header_id = ph.current_agent_id
           AND dp.department_id = ach.agency_id) AS region_name
  FROM (SELECT /*+ NO_MERGE */
         ph.policy_header_id
        ,ph.fund_id
        ,ins.pkg_renlife_utils.get_p_agent_current(ph.policy_header_id) AS current_agent_id
        ,ph.product_id
        ,ph.sales_channel_id
        ,ph.start_date
        ,ph.ids
        ,ph.policy_id
        ,dc.ext_id
        ,(SELECT COUNT(*)
            FROM ins.as_asset aas2
           WHERE aas2.p_policy_id = ph.policy_id
             AND aas2.status_hist_id != 3) AS ass_count
        ,pr.description
          FROM ins.p_pol_header ph
              ,ins.p_policy     pp
              ,ins.document     dc
              ,ins.t_product    pr
         WHERE ph.policy_header_id = dc.document_id
           AND ph.product_id = pr.product_id
           AND ph.policy_id = pp.policy_id -- Выгружаем только активную версию
        ) ph;
