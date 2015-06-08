create or replace view ins_dwh.v_reserves_vs_profit_pheader as
select ph.POLICY_HEADER_ID
      ,ph.FUND_ID
      ,ph.CURRENT_AGENT_ID
      ,ph.PRODUCT_ID
      ,ph.SALES_CHANNEL_ID
      ,ph.START_DATE
      ,ph.IDS
      ,ph.POLICY_ID
      ,ph.EXT_ID
      ,ph.ASS_COUNT
      ,ph.DESCRIPTION
      ,(select dp.name
          from ins.ven_ag_contract_header ach
              ,ins.department             dp
         where ach.ag_contract_header_id = ph.current_agent_id
           and dp.department_id          = ach.agency_id
       ) as region_name
  from (select /*+ NO_MERGE */
              ph.policy_header_id
             ,ph.fund_id
             ,ins.pkg_renlife_utils.get_p_agent_current(ph.policy_header_id) as current_agent_id
             ,ph.product_id
             ,ph.sales_channel_id
             ,ph.start_date
             ,ph.ids
             ,ph.policy_id
             ,dc.ext_id
             ,(select count(*)
                 from ins.as_asset aas2
                where aas2.p_policy_id     = ph.policy_id
                  and aas2.status_hist_id != 3
              ) as ass_count
             ,pr.description
         from ins.p_pol_header ph
             ,ins.p_policy     pp
             ,ins.document     dc
             ,ins.t_product    pr
        where ph.policy_header_id = dc.document_id
          and ph.product_id       = pr.product_id
          and ph.policy_id          = pp.policy_id -- Выгружаем только активную версию
          AND ((ins_dwh.pkg_reserves_vs_profit.get_mode = 0
                and pr.brief not in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
                and pp.is_group_flag = 0
               )or
               (ins_dwh.pkg_reserves_vs_profit.get_mode = 1
                and pr.brief in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
               )or
               (ins_dwh.pkg_reserves_vs_profit.get_mode = 2
                and pp.is_group_flag = 1
               )
              )  
      ) ph;
