CREATE OR REPLACE FORCE VIEW VE_REPORTS_BY_CONTEXT AS
SELECT "REP_REPORT_ID"
       ,"ENT_ID"
       ,"FILIAL_ID"
       ,"REP_TYPE_ID"
       ,"EXE_NAME"
       ,"PARENT_ID"
       ,"EXT_ID"
       ,"NAME"
       ,"PARAMETERS"
       ,"PARAM_FORM"
       ,"ORDER_BY"
       ,"CODE"
  FROM rep_report
 WHERE rep_report_id IN (SELECT column_value FROM TABLE(repcore.report_ids_by_context))
 ORDER BY order_by
         ,NAME;

GRANT SELECT ON VE_REPORTS_BY_CONTEXT TO INS_READ;

