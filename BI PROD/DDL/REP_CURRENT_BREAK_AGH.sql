CREATE OR REPLACE VIEW REP_CURRENT_BREAK_AGH AS
SELECT ag_num,
       ag_name,
       category_name,
       dep_name,
       contact_id,
       date_begin,
       sales_ch,
       ag_state,
       date_break,
       date_begin - LEAD(date_break) OVER (PARTITION BY ag_name ORDER BY ag_name) cnt_days,
       CASE WHEN LEAD(sales_ch) OVER (PARTITION BY ag_name ORDER BY ag_name ASC,date_begin DESC) != sales_ch
            THEN 'дю'
            WHEN LEAD(sales_ch) OVER (PARTITION BY ag_name ORDER BY ag_name ASC,date_begin DESC) = sales_ch
            THEN 'мер'
       END change_sales
FROM
(
SELECT agh1.num ag_num,
             co1.obj_name_orig ag_name,
             cato1.category_name,
             depo1.name dep_name,
             co1.contact_id,
             agh1.date_begin,
             cho1.description sales_ch,
             (SELECT agd1.doc_date
              FROM ins.ag_documents agd1,
                   ins.ag_doc_type adt1,
                   ins.document da1,
                   ins.doc_status_ref rfa1
              WHERE agd1.ag_contract_header_id = agh1.ag_contract_header_id
                AND agd1.ag_doc_type_id = adt1.ag_doc_type_id
                AND adt1.brief = 'BREAK_AD'
                AND da1.document_id = agd1.ag_documents_id
                AND da1.doc_status_ref_id = rfa1.doc_status_ref_id
                AND rfa1.brief = 'CONFIRMED'
                AND ROWNUM = 1
              ) date_break,
              rfo1.name ag_state
      FROM ins.ven_ag_contract_header agh1,
           ins.document do1,
           ins.doc_status_ref rfo1,
           ins.ag_contract ago1,
           ins.ag_category_agent cato1,
           ins.department depo1,
           ins.contact co1,
           ins.t_sales_channel cho1
      WHERE agh1.ag_contract_header_id = ago1.contract_id
        AND ago1.category_id = cato1.ag_category_agent_id
        AND ago1.agency_id = depo1.department_id
        AND agh1.agent_id = co1.contact_id
        AND ago1.ag_contract_id = agh1.last_ver_id
        AND agh1.ag_contract_header_id = do1.document_id
        AND do1.doc_status_ref_id = rfo1.doc_status_ref_id
        AND ago1.ag_sales_chn_id = cho1.id
        AND rfo1.brief = 'BREAK'
        AND agh1.is_new = 1
        AND (EXISTS (SELECT NULL
                    FROM ins.ven_ag_contract_header agh,
                         ins.document d,
                         ins.doc_status_ref rf
                    WHERE agh.agent_id = agh1.agent_id
                          AND agh.ag_contract_header_id = d.document_id
                          AND d.doc_status_ref_id = rf.doc_status_ref_id
                          AND agh.num != agh1.num
                          AND rf.brief = 'BREAK'
                          AND agh.is_new = 1 )
             OR
             EXISTS (SELECT NULL
                    FROM ins.ven_ag_contract_header aghc,
                         ins.document dc,
                         ins.doc_status_ref rfc
                    WHERE aghc.agent_id = agh1.agent_id
                          AND aghc.ag_contract_header_id = dc.document_id
                          AND dc.doc_status_ref_id = rfc.doc_status_ref_id
                          AND rfc.brief = 'CURRENT'
                          AND aghc.is_new = 1 )
             )
/*AND co1.contact_id = 485069*/
UNION
SELECT agho.num ag_num,
             co.obj_name_orig ag_name,
             cato.category_name,
             depo.name dep_name,
             co.contact_id,
             agho.date_begin,
             cho.description sales_ch,
             NULL,
             rfo.name ag_state
      FROM ins.ven_ag_contract_header agho,
           ins.document do,
           ins.doc_status_ref rfo,
           ins.ag_contract ago,
           ins.ag_category_agent cato,
           ins.department depo,
           ins.contact co,
           ins.t_sales_channel cho
      WHERE agho.ag_contract_header_id = ago.contract_id
        AND ago.category_id = cato.ag_category_agent_id
        AND ago.agency_id = depo.department_id
        AND agho.agent_id = co.contact_id
        AND ago.ag_contract_id = agho.last_ver_id
        AND agho.ag_contract_header_id = do.document_id
        AND do.doc_status_ref_id = rfo.doc_status_ref_id
        AND ago.ag_sales_chn_id = cho.id
        AND rfo.brief = 'CURRENT'
        AND agho.is_new = 1
        /*AND co.contact_id = 485069*/
AND EXISTS (SELECT NULL
              FROM ins.ven_ag_contract_header agh,
                   ins.document d,
                   ins.doc_status_ref rf
              WHERE agh.agent_id = agho.agent_id
                    AND agh.ag_contract_header_id = d.document_id
                    AND d.doc_status_ref_id = rf.doc_status_ref_id
                    AND rf.brief = 'BREAK'
                    AND agh.is_new = 1)
);
      
GRANT SELECT ON REP_CURRENT_BREAK_AGH TO INS_EUL;
GRANT SELECT ON REP_CURRENT_BREAK_AGH TO INS_READ;
