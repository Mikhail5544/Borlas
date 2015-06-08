CREATE OR REPLACE FORCE VIEW V_AGENT_STAT_HIST AS
SELECT "AG_STAT_HIST_ID", "ENT_ID", "FILIAL_ID", "EXT_ID",
          "AG_CONTRACT_HEADER_ID", "NUM", "STAT_DATE", "AG_STAT_AGENT_ID",
          "K_SGP", "K_KD", "K_KSP", "AG_CATEGORY_AGENT_ID", "CRO"
     FROM (SELECT a.*,
                  COUNT (*) OVER (PARTITION BY a.ag_contract_header_id ORDER BY a.ag_stat_hist_id DESC)
                                                                       AS cro
             FROM ag_stat_hist a
            WHERE a.ag_contract_header_id =
                              pkg_rep_utils2.igetval ('AG_CONTRACT_HEADER_ID')
              AND a.ag_stat_hist_id <>
                           NVL (pkg_rep_utils2.igetval ('AG_STAT_HIST_ID'), 0)) b
    WHERE b.cro = 1;

