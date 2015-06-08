CREATE OR REPLACE VIEW INS.V_PAY_JOURNAL AS
SELECT d.num aph_num,
       aph.company company_name,
       d.reg_date,
       (select ds.user_name
        from doc_status ds
        where ds.document_id = d.document_id
              and ds.src_doc_status_ref_id = (select rf.doc_status_ref_id
                                              from doc_status_ref rf
                                              where rf.brief = 'NULL')
       ) user_name,
       (select rf.name
        from doc_status_ref rf
        where rf.doc_status_ref_id = d.doc_status_ref_id) state,
       aph.request_num,
       aph.ag_roll_header_id,
       aph.ag_roll_pay_header_id
FROM ins.ag_roll_pay_header aph,
     ins.document d
WHERE aph.ag_roll_pay_header_id = d.document_id;
grant select on INS.V_PAY_JOURNAL to INS_READ;
