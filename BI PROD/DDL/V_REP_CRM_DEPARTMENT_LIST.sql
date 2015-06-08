CREATE OR REPLACE VIEW V_REP_CRM_DEPARTMENT_LIST AS
SELECT d.department_id id
      ,d.name          name
FROM organisation_tree ot
    ,department        d
WHERE 1 = 1
  AND ot.organisation_tree_id = d.org_tree_id
  AND d.department_code IS NOT NULL
  AND ot.organisation_tree_id = 1000 -- Центральный офис
ORDER BY d.name
;
GRANT SELECT ON V_REP_CRM_DEPARTMENT_LIST TO INS_EUL, INS_READ;