CREATE OR REPLACE FORCE VIEW VEN_XX_GAP_PROCESS_LOG AS
(SELECT "CODE","DOCUMENT_ID","STATUS_ID","STATUS_DATE","ID" FROM insi.xx_gap_process_log);

