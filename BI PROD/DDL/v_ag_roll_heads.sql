CREATE OR REPLACE FORCE VIEW V_AG_ROLL_HEADS AS
SELECT   arh.ag_roll_header_id roll_num, arh.date_begin, arh.date_end,
            art.NAME roll_type, aca.category_name cname,
            doc.get_doc_status_name (arh.ag_roll_header_id, SYSDATE) status,
            arh.note
       FROM ven_ag_roll_header arh JOIN ven_ag_roll_type art
            ON (arh.ag_roll_type_id = art.ag_roll_type_id)
            JOIN ven_ag_category_agent aca
            ON (aca.ag_category_agent_id = arh.ag_category_agent_id)
   ORDER BY aca.category_name, art.NAME;

