CREATE OR REPLACE VIEW v_bso_transfer_contacts AS
SELECT t.contact_id
      ,(SELECT c.obj_name_orig FROM contact c WHERE c.contact_id = t.contact_id) obj_name_orig
      ,t.department_id
      ,(SELECT dep.name FROM department dep WHERE dep.department_id = t.department_id) AS department_name
      ,t.organisation_tree_id AS organisation_tree_id
      ,(SELECT org.name
          FROM organisation_tree org
         WHERE t.organisation_tree_id = org.organisation_tree_id) AS organisation_name
      ,(SELECT d.num FROM document d WHERE d.document_id = t.ag_contract_doc_id) contract_number
  FROM (SELECT ach.agent_id              contact_id
              ,dep.department_id
              ,org.organisation_tree_id  AS organisation_tree_id
              ,ach.ag_contract_header_id ag_contract_doc_id
          FROM ag_contract_header ach
              ,department         dep
              ,organisation_tree  org
         WHERE ach.is_new = 1
           AND dep.department_id = ach.agency_id
           AND org.organisation_tree_id = dep.org_tree_id
           AND EXISTS (SELECT NULL
                  FROM document       d
                      ,doc_status     ds
                      ,doc_status_ref dsr
                 WHERE ach.ag_contract_header_id = d.document_id
                   AND d.doc_status_id = ds.doc_status_id
                   AND ds.start_date <= nvl(pkg_bso_fmb.get_act_date(), SYSDATE)
                   AND d.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'CURRENT')
        UNION
        SELECT ee.contact_id
              ,NULL                     department_id
              ,org.organisation_tree_id AS organisation_tree_id
              ,NULL                     ag_contract_doc_id
          FROM employee          ee
              ,employee_hist     eh
              ,organisation_tree org
         WHERE ee.organisation_id = org.organisation_tree_id
           AND ee.employee_id = eh.employee_id
           AND eh.employee_hist_id = (SELECT MAX(eh2.employee_hist_id)
                                        FROM employee_hist eh2
                                       WHERE eh2.employee_id = ee.employee_id)
           AND eh.is_brokeage = 1
           AND org.code = 'ЦО'
           AND EXISTS (SELECT NULL
                  FROM cn_contact_role cr
                      ,t_contact_role  r
                 WHERE ee.contact_id = cr.contact_id
                   AND cr.role_id = r.id
                   AND r.brief = 'WORKER')
           AND EXISTS (SELECT NULL
                  FROM cn_contact_role cr
                      ,t_contact_role  r
                 WHERE ee.contact_id = cr.contact_id
                   AND cr.role_id = r.id
                   AND r.brief IN ('BSO_USER', 'BSO_RESPONSE'))
           AND NOT EXISTS
         (SELECT NULL
                  FROM ag_contract_header ah
                 WHERE ah.agent_id = ee.contact_id
                   AND ah.is_new = 1
                   AND doc.get_doc_status_brief(ah.ag_contract_header_id
                                               ,nvl(pkg_bso_fmb.get_act_date(), SYSDATE)) = 'CURRENT')
        
        /*До выяснения того, как они будут определены*/
        UNION
        SELECT c.contact_id
              ,NULL         department_id
              ,NULL         organisation_tree_id
              ,NULL         ag_contract_doc_id
          FROM contact c
         WHERE EXISTS (SELECT NULL
                  FROM cn_contact_role cr
                      ,t_contact_role  r
                 WHERE c.contact_id = cr.contact_id
                   AND cr.role_id = r.id
                   AND r.brief = 'BSO_AGENT_BROKER')
        UNION
        SELECT cn.contact_id
              ,NULL          AS department_id
              ,NULL          AS organisation_tree_id
              ,NULL          AS ag_contract_doc_id
          FROM contact cn
         WHERE cn.contact_id IN (pkg_bso_fmb.get_supplier_contact_id()
                                ,pkg_bso_fmb.get_warehouse_contact_id()
                                ,pkg_bso_fmb.get_rlp_contact_id())) t;
