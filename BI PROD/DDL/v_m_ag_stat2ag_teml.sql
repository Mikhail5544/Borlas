CREATE OR REPLACE FORCE VIEW V_M_AG_STAT2AG_TEML AS
SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���1���' AND ach.templ_brief = 'DS_MN_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���2���' AND ach.templ_brief = 'DS_MN_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '�����������' AND ach.templ_brief = 'DS_MN_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���1���' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���2����' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���2����' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���2����' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '���2����' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '������' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '������' AND ach.templ_brief = 'DS_DR_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '��������' AND ach.templ_brief = 'DS_AG_15_02_07'
   UNION ALL
   SELECT a.ag_stat_agent_id, a.brief, ach.templ_brief, ach.templ_name,
          ach.ag_contract_header_id
     FROM ag_stat_agent a, ag_contract_header ach
    WHERE a.brief = '������������' AND ach.templ_brief = 'DS_AG_15_02_07';

