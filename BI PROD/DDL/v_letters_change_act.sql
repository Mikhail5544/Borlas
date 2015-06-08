CREATE OR REPLACE VIEW ins.v_letters_change_act AS
SELECT p.policy_header_id pol_header_id
      ,p.policy_id document_id
      ,p.pol_start_date
      ,p.ids policy_number
      ,p.pol_num num
      ,p.contact_id
      ,p.contact_name
      ,NULL amount
      ,NULL pay_amount
      ,NULL grace_date
      ,trunc(MONTHS_BETWEEN(trunc(p.end_date) + 1, trunc(p.pol_start_date)) / 12, 2) payment_period
      ,(SELECT trunc(MIN(ds.start_date))
          FROM ins.doc_status     ds
              ,ins.doc_status_ref rf
         WHERE ds.document_id = p.policy_id
           AND ds.doc_status_ref_id = rf.doc_status_ref_id
           AND rf.brief IN ('CONCLUDED', 'CURRENT')) due_date
      ,NULL doc_status_ref_id
      ,NULL doc_status_ref_name
  FROM (SELECT /*+ LEADING (d) INDEX(pola PK_P_POLICY)*/ pola.*
              ,ph.policy_header_id
              ,ph.start_date pol_start_date
              ,ph.ids
              ,cpol.contact_id
              ,cpol.obj_name_orig contact_name
          FROM ins.p_pol_header ph
              ,ins.p_policy pola
              ,ins.p_policy_contact ppc
              ,ins.contact cpol
              ,(SELECT ppd.p_policy_id
                      ,t.brief
                  FROM ins.p_pol_addendum_type ppd
                      ,ins.t_addendum_type     t
                 WHERE ppd.t_addendum_type_id = t.t_addendum_type_id
                   AND t.brief IN ('FIN_WEEK'
                                  ,'UNDERWRITING_CHANGE'
                                  ,'FEE_CHANGE'
                                  ,'PREMIUM_CHANGE'
                                  ,'PRODUCT_CHANGE'
                                  ,'COVER_DELETING')) d
         WHERE ph.policy_header_id = pola.pol_header_id
           AND d.p_policy_id = pola.policy_id
           AND ppc.contact_id = cpol.contact_id
           AND ppc.policy_id = pola.policy_id
           AND ppc.contact_policy_role_id = 6
           AND ((d.brief = 'FIN_WEEK' AND
               to_char(pola.start_date, 'DDMM') != to_char(ph.start_date, 'DDMM')) OR
               d.brief != 'FIN_WEEK')
           AND EXISTS (SELECT NULL
                  FROM ins.doc_status     ds
                      ,ins.doc_status_ref rf
                 WHERE ds.document_id = pola.policy_id
                   AND ds.doc_status_ref_id = rf.doc_status_ref_id
                   AND rf.brief IN ('CONCLUDED', 'CURRENT')
                   AND trunc(ds.start_date) BETWEEN ins.pkg_notification_letters_fmb.get_date_from AND ins.pkg_notification_letters_fmb.get_date_to
                   )) p
 WHERE /*p.policy_id = 15093542
   AND */(EXISTS (SELECT NULL
           FROM ins.as_asset    a
               ,ins.p_cover     co
               ,ins.status_hist st
          WHERE a.p_policy_id = p.policy_id
            AND a.as_asset_id = co.as_asset_id
            AND co.status_hist_id = st.status_hist_id
            AND st.brief = 'DELETED') OR EXISTS (SELECT NULL
           FROM ins.as_asset           a
               ,ins.p_cover            co
               ,ins.t_prod_line_option po
                /**/
               ,ins.as_asset           aa
               ,ins.p_cover            pc
               ,ins.t_prod_line_option opt
          WHERE a.p_policy_id = p.policy_id
            AND a.as_asset_id = co.as_asset_id
            AND co.t_prod_line_option_id = po.id
               /**/
            AND p.prev_ver_id = aa.p_policy_id
            AND aa.p_asset_header_id = a.p_asset_header_id
            AND aa.as_asset_id = pc.as_asset_id
            AND pc.t_prod_line_option_id = opt.id
            AND opt.product_line_id = po.product_line_id
            AND pc.fee > co.fee));
      
GRANT SELECT ON ins.v_letters_change_act TO INS_EUL;
GRANT SELECT ON ins.v_letters_change_act TO INS_READ;
