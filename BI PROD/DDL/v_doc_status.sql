CREATE OR REPLACE FORCE VIEW V_DOC_STATUS AS
SELECT ds.document_id, ds.doc_status_ref_id
  FROM doc_status ds,
       (SELECT MAX(start_date) start_date, document_id
          FROM doc_status
         WHERE start_date <= SYSDATE
         GROUP BY document_id) q
 WHERE ds.start_date = q.start_date
   AND ds.document_id = q.document_id;

