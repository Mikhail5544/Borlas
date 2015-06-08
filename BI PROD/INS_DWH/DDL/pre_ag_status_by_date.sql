create materialized view INS_DWH.PRE_AG_STATUS_BY_DATE
refresh force on demand
as
select dd.date_id,
            dd.sql_date,
            nvl(status_hist.ag_contract_header_id,-1) ag_contract_header_id,
            nvl(status_hist.ag_stat_agent_id,-1) ag_stat_agent_id,
            nvl(status_hist.ag_category_agent_id,-1) ag_category_agent_id
       from dm_date dd,
            dm_ag_category_agent dm_cat,
            dm_ag_stat_agent dm_stat,
            dm_ag_contract_header dm_ah,
            -- история статусов и категорий договоров
            (select ash.ag_contract_header_id,
                    ash.ag_stat_agent_id,
                    ash.ag_category_agent_id,
                    trunc(ash.stat_date, 'dd') begin_date,
                    trunc(nvl((lead(ash.stat_date)
                               over(partition by ash.ag_contract_header_id
                                    order by ash.stat_date)) - 1,
                              ac1.date_end),
                          'dd') date_end
               from ins.ag_stat_hist       ash,
                    ins.ag_contract_header ah2,
                    ins.ag_contract        ac1
              where ash.ag_contract_header_id = ah2.ag_contract_header_id
                and ah2.last_ver_id = ac1.ag_contract_id
                and ah2.templ_brief is null) status_hist
      where dd.sql_date between status_hist.begin_date and
            status_hist.date_end
            and status_hist.ag_contract_header_id = dm_ah.ag_contract_header_id (+)
            and status_hist.ag_stat_agent_id = dm_stat.ag_stat_agent_id (+)
            and status_hist.ag_category_agent_id = dm_cat.ag_category_agent_id (+);

