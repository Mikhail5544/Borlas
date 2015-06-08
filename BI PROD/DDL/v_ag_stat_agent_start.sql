CREATE OR REPLACE FORCE VIEW V_AG_STAT_AGENT_START AS
SELECT   A.   ag_attest_path_id,
 A.from_stat_id,
                                                        A.to_stat_id,
                                                        A.ag_templ_header_id,
                                                        A.notice,
                                                        A.is_up
       FROM ag_attest_path a, ag_stat_agent asa
      WHERE a.from_stat_id IS NULL AND asa.ag_stat_agent_id = a.to_stat_id
   ORDER BY TO_NUMBER (asa.ag_category_agent_id || asa.status_prior) ASC;

