CREATE OR REPLACE FORCE VIEW V_M_AG_STAT2AG_TEML AS
SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Мен1Кат' AND ach.templ_brief = 'DS_MN_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Мен2Кат' AND ach.templ_brief = 'DS_MN_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'МенРукОтдПр' AND ach.templ_brief = 'DS_MN_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Дир1Кат' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Дир2КатА' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Дир2КатБ' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Дир2КатВ' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'Дир2КатГ' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'ТерДир' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'РегДир' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'АгБезКат' AND ach.templ_brief = 'DS_AG_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = 'БезКатНетКат' AND ach.templ_brief = 'DS_AG_15_02_07';

