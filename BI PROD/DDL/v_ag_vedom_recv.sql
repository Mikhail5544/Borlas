CREATE OR REPLACE FORCE VIEW V_AG_VEDOM_RECV AS
SELECT   CONCAT (CONCAT (ar.ag_roll_id, '/'), ar.num) num, ar.reg_date,
            ar.user_name,
            doc.get_doc_status_name (ar.ag_roll_id, SYSDATE) status
       FROM ven_ag_roll ar
   --where ar.ag_roll_header_id = 5582955
   ORDER BY ar.num ASC
;

