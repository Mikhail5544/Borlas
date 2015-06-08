CREATE OR REPLACE VIEW V_REP_CRM_CLIENT_TYPE_LIST AS
SELECT cct.t_crm_client_type_id id
      ,cct.name                 name
FROM t_crm_client_type cct
;
GRANT SELECT ON V_REP_CRM_CLIENT_TYPE_LIST TO INS_EUL, INS_READ;