CREATE OR REPLACE FORCE VIEW V_AG_STAT_AGENT_UP AS
SELECT   aca.category_name AS category_name, asa.NAME AS status_name,
            asa.ag_stat_agent_id, aap.ag_attest_path_id
       FROM ag_stat_agent asa, ag_attest_path aap, ag_category_agent aca
      WHERE asa.ag_stat_agent_id = aap.to_stat_id
        AND aap.from_stat_id = pkg_rep_utils2.igetval ('AG_STAT_AGENT_ID')
        AND aca.ag_category_agent_id = asa.ag_category_agent_id
        AND aap.is_up = 1
   ORDER BY TO_NUMBER (asa.ag_category_agent_id || asa.status_prior) ASC;

