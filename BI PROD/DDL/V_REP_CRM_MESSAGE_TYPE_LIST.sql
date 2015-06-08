CREATE OR REPLACE VIEW V_REP_CRM_MESSAGE_TYPE_LIST AS
SELECT mt.t_message_type_id id
      ,mt.message_type_name name
FROM t_message_type mt
ORDER BY mt.message_type_name
;
GRANT SELECT ON V_REP_CRM_MESSAGE_TYPE_LIST TO INS_EUL, INS_READ;