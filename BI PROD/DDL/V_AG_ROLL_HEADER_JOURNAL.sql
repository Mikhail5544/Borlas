CREATE OR REPLACE VIEW INS.V_AG_ROLL_HEADER_JOURNAL AS
SELECT vhead.AG_ROLL_HEADER_ID AS AG_ROLL_HEADER_ID,
          vhead.REG_DATE AS REG_DATE,
          vhead.NUM AS NUM,
          vhead.ENT_ID as ENT_ID,
          NULL as PERIOD,
          vhead.DATE_BEGIN AS DATE_BEGIN,
          vhead.DATE_END AS DATE_END,
          vhead.AG_ROLL_TYPE_ID AS AG_ROLL_TYPE_ID,
          vtype.NAME AS AG_ROLL_TYPE_NAME,
          vtype.BRIEF AS AG_ROLL_TYPE_BRIEF,
          vhead.AG_CATEGORY_AGENT_ID as AG_CATEGORY_AGENT_ID,
          vcat.CATEGORY_NAME AS AG_CATEGORY_AGENT_NAME,
          vcat.BRIEF AS AG_CATEGORY_AGENT_BRIEF,
          vhead.DOC_TEMPL_ID AS DOC_TEMPL_ID,
          vhead.NOTE AS NOTE,
          dsr.NAME AS AG_ROLL_STATUS_NAME,
          ds.USER_NAME AS STATUS_USER_NAME,
          ds.START_DATE AS STATUS_START_DATE,
          vtype.date_begin begin_roll,
          vtype.date_end end_roll,
          vhead.payment_date,
          vhead.trans_reg_date,
          vhead.ksp_roll_header_id,
          ksp_head.num ksp_num,
          vhead.conclude_date,
          vhead.ops_sign_date,
          vhead.sofi_begin_date,
          vhead.sofi_end_date,
          vtype.type_av
          /*TO_CHAR (TO_DATE (vhead.months_date || '01', 'yyyymmdd'),
                   'MONTH YYYY',
                   'NLS_DATE_LANGUAGE = russian'
                  ) AS date_num,*/
     FROM ins.ven_ag_roll_header vhead
     LEFT JOIN ven_ag_roll_type vtype on (vtype.ag_roll_type_id = vhead.ag_roll_type_id
                                          AND vtype.ag_roll_type_id IN (SELECT tp.ag_roll_type_id
                                                                        FROM ins.ag_roll_type tp
                                                                        WHERE (safety.check_right_custom('VIEW_RLA') = 1
                                                                               AND tp.brief LIKE 'RLA%'
                                                                              )
                                                                              OR
                                                                              (safety.check_right_custom('VIEW_RENLIFE') = 1
                                                                               AND tp.brief NOT LIKE 'RLA%'
                                                                              )
                                                                        )
                                          )
     LEFT JOIN ven_ag_category_agent vcat on vcat.ag_category_agent_id = vhead.ag_category_agent_id
     LEFT JOIN ven_doc_status ds on ds.doc_status_id = doc.get_last_doc_status_id(vhead.ag_roll_header_id)
     LEFT JOIN ven_doc_status_ref dsr on dsr.DOC_STATUS_REF_ID = ds.DOC_STATUS_REF_ID
     LEFT OUTER JOIN ven_ag_roll_header ksp_head ON ksp_head.ag_roll_header_id = vhead.ksp_roll_header_id
ORDER BY num DESC, date_end DESC, ag_roll_type_name;
grant select on INS.V_AG_ROLL_HEADER_JOURNAL to INS_READ;
