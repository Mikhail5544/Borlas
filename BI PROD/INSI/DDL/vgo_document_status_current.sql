CREATE OR REPLACE FORCE VIEW VGO_DOCUMENT_STATUS_CURRENT AS
( 
SELECT "SD_1","DOC_STATUS_ID","ENT_ID","FILIAL_ID","DOCUMENT_ID","DOC_STATUS_REF_ID","START_DATE","EXT_ID","USER_NAME","CHANGE_DATE","STATUS_CHANGE_TYPE_ID","NOTE","SRC_DOC_STATUS_REF_ID" 
          FROM (SELECT MAX (ds.start_date) OVER (PARTITION BY ds.document_id) AS sd_1, 
                       ds.* 
                  FROM ins.doc_status ds 
                 WHERE ds.start_date <= SYSDATE) a 
         WHERE sd_1 = a.start_date);

