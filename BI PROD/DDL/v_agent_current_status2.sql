CREATE OR REPLACE FORCE VIEW V_AGENT_CURRENT_STATUS2 AS
(SELECT ah.ag_contract_header_id AS head_id,
           doc.get_doc_status_brief
                       (ah.ag_contract_header_id,
                        pkg_rep_utils2.dgetval ('CURRENT_DATE')
                       ) AS head_status,
           ac.ag_contract_id AS last_ver_id,
           doc.get_doc_status_brief
                   (ac.ag_contract_id,
                    pkg_rep_utils2.dgetval ('CURRENT_DATE')
                   ) AS last_ver_status,
           ac.category_id AS category_id, ah.num AS num_contr,
           c1.obj_name_orig AS name_agent, c2.NAME AS name_agency,
           ca.category_name AS name_categ, ac_cat.date_begin AS date_categ,
           sa.NAME AS name_status, sh.stat_date AS date_status,
           sh.ag_stat_agent_id AS ag_stat_agent_id
      FROM ven_ag_contract_header ah
           JOIN
           (SELECT   MAX (a1.num) num, a1.contract_id
                FROM ven_ag_contract a1
               WHERE a1.date_begin < = pkg_rep_utils2.dgetval ('CURRENT_DATE')
            GROUP BY a1.contract_id) ac_dat
           ON (ac_dat.contract_id = ah.ag_contract_header_id)
           JOIN ven_ag_contract ac
           ON (    ac.contract_id = ah.ag_contract_header_id
               AND ac.num = ac_dat.num
              )
           JOIN ven_ag_category_agent ca
           ON (ca.ag_category_agent_id = ac.category_id)
           JOIN ven_ag_contract ac_cat
           ON (ac_cat.contract_id = ah.ag_contract_header_id)
           LEFT JOIN
           (SELECT   MAX (h.num) num, h.ag_contract_header_id
                FROM ven_ag_stat_hist h
               WHERE h.stat_date < = pkg_rep_utils2.dgetval ('CURRENT_DATE')
            GROUP BY h.ag_contract_header_id) sh_all
           ON (sh_all.ag_contract_header_id = ah.ag_contract_header_id)
           LEFT JOIN ven_ag_stat_hist sh
           ON (    sh.ag_contract_header_id = ah.ag_contract_header_id
               AND sh_all.num = sh.num
              )
           LEFT JOIN ven_ag_stat_agent sa
           ON (sa.ag_stat_agent_id = sh.ag_stat_agent_id)
           LEFT JOIN ven_contact c1 ON (ah.agent_id = c1.contact_id)
           LEFT JOIN ven_department c2 ON (ah.agency_id = c2.department_id)
     WHERE ac_cat.num =
              (SELECT MIN (a2.num)
                 FROM ven_ag_contract a2
                WHERE a2.contract_id = ah.ag_contract_header_id
                  AND a2.category_id = ac.category_id)
       AND doc.get_doc_status_brief (ac.ag_contract_id,
                                     pkg_rep_utils2.dgetval ('CURRENT_DATE')
                                    ) IN ('CURRENT', 'PRINTED', 'NEW')
       AND doc.get_doc_status_brief (ah.ag_contract_header_id,
                                     pkg_rep_utils2.dgetval ('CURRENT_DATE')
                                    ) IN ('CURRENT', 'PRINTED', 'NEW')
       AND ah.ag_contract_templ_k = 0);

