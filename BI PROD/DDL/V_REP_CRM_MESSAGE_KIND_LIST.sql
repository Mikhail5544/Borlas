CREATE OR REPLACE VIEW V_REP_CRM_MESSAGE_KIND_LIST AS
SELECT rk.t_message_kind_id id
      ,mk.message_kind_name name
FROM t_crm_request_kind rk
    ,t_message_kind     mk
WHERE 1 = 1
  AND rk.t_message_kind_id = mk.t_message_kind_id
;
GRANT SELECT ON V_REP_CRM_MESSAGE_KIND_LIST TO INS_EUL, INS_READ;