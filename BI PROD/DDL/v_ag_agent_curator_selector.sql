CREATE OR REPLACE FORCE VIEW V_AG_AGENT_CURATOR_SELECTOR AS
WITH history_stat AS
        (SELECT DISTINCT (ag_stat_agent_id), ag_contract_header_id
                    FROM (SELECT hist.ag_stat_agent_id,
                                 hist.ag_contract_header_id,
                                 MAX (hist.stat_date) OVER (PARTITION BY hist.ag_contract_header_id ORDER BY hist.stat_date DESC)
                                                             AS max_stat_date,
                                 hist.stat_date
                            FROM ag_stat_hist hist
                           WHERE hist.stat_date <= SYSDATE) t
                   WHERE t.max_stat_date = t.stat_date)
   SELECT c.ag_contract_id, ch.num || '/' || c.num num, ca.category_name,
          ch.ag_contract_header_id, con.obj_name_orig name_leader,
          dsr.NAME status
     FROM ven_ag_contract c,
          ven_ag_contract_header ch,
          ven_ag_category_agent ca,
          ven_contact con,
          doc_status ds,
          doc_status_ref dsr,
          history_stat history_worker,
          history_stat history_curator,
          ag_agent_curator aac
    WHERE c.ag_contract_id =
              pkg_agent_1.get_status_contr_activ_id (ch.ag_contract_header_id)
      AND ch.ag_contract_header_id = c.contract_id
      AND ca.ag_category_agent_id = c.category_id
      AND history_curator.ag_contract_header_id = ch.ag_contract_header_id
      AND history_worker.ag_contract_header_id =
                              pkg_rep_utils2.igetval ('AG_CONTRACT_HEADER_ID')
      AND aac.ag_worker_id = history_worker.ag_stat_agent_id
      AND history_curator.ag_stat_agent_id IN (aac.ag_curator_id)
      AND con.contact_id = ch.agent_id
      AND ds.document_id = c.ag_contract_id
      AND ds.start_date IN (SELECT MAX (start_date)
                              FROM doc_status
                             WHERE document_id = c.ag_contract_id)
      AND dsr.doc_status_ref_id = ds.doc_status_ref_id
      AND (   ch.agency_id = pkg_rep_utils2.igetval ('AGENCY_ID')
           OR (    pkg_rep_utils2.igetval ('AGENCY_ID') IS NULL
               AND ch.agency_id IS NULL
              )
          )
      AND doc.get_doc_status_brief (c.ag_contract_id) IN
                                                 ('RESUME', 'CURRENT', 'NEW')
      AND c.contract_id != pkg_rep_utils2.igetval ('AG_CONTRACT_HEADER_ID');

