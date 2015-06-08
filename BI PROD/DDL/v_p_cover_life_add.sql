CREATE OR REPLACE VIEW V_P_COVER_LIFE_ADD AS
SELECT   pc_prev.p_cover_id p_cover_id_prev,
            pc_curr.p_cover_id p_cover_id_curr,
            DECODE (pc_curr.p_cover_id, pc_prev.p_cover_id, 0, 1)
               is_add_found,
            pp_prev.policy_id policy_id_prev,
            pp_curr.policy_id policy_id_curr,
            vcp_curr.contact_id contact_id_prev,
            vcp_curr.contact_id contact_id_curr,
            aa_prev.p_asset_header_id asset_header_prev,
            aa_curr.p_asset_header_id asset_header_curr,
            DECODE (vcp_curr.contact_id, vcp_prev.contact_id, 0, 1)
               is_assured_change,
            pc_prev.ins_amount ins_amount_prev,
            pc_curr.ins_amount ins_amount_curr,
            DECODE (pc_prev.ins_amount, pc_curr.ins_amount, 0, 1)
               is_ins_amount_change,
            pc_prev.tariff tariff_prev,
            pc_curr.tariff tariff_curr,
            pc_prev.fee fee_prev,
            pc_curr.fee fee_curr,
            DECODE (pc_prev.fee, pc_curr.fee, 0, 1) is_fee_change,
            pc_prev.rvb_value f_prev,
            pc_curr.rvb_value f_curr,
            NVL (pc_prev.period_id, pp_prev.period_id) period_id_prev,
            NVL (pc_curr.period_id, pp_curr.period_id) period_id_curr,
            TRUNC (
               MONTHS_BETWEEN (pc_prev.end_date + 1, pc_prev.start_date) / 12
            )
               period_year_prev,
            TRUNC (
               MONTHS_BETWEEN (pc_curr.end_date + 1, pc_curr.start_date) / 12
            )
               period_year_curr,
            DECODE (
               TRUNC(MONTHS_BETWEEN (pc_prev.end_date + 1,
                                     pc_prev.start_date)
                     / 12),
               TRUNC(MONTHS_BETWEEN (pc_curr.end_date + 1,
                                     pc_curr.start_date)
                     / 12),
               0,
               1
            )
               is_period_change,
            pt_prev.ID payment_terms_id_prev,
            pt_curr.ID payment_terms_id_curr,
            DECODE (pt_prev.ID, pt_curr.ID, 0, 1) is_payment_terms_id_change,
            DECODE (pt_prev.is_periodical,
                    0,
                    1,
                    1,
                    0)
               is_one_payment_prev,
            DECODE (pt_curr.is_periodical,
                    0,
                    1,
                    1,
                    0)
               is_one_payment_curr,
            DECODE (pt_prev.is_periodical, pt_curr.is_periodical, 0, 1)
               is_periodical_change
     FROM   t_payment_terms pt_prev,
            t_payment_terms pt_curr,
            p_policy pp_prev,
            p_policy pp_curr,
            cn_person vcp_prev,
            contact vc_prev,
            as_assured vas_prev,
            cn_person vcp_curr,
            contact vc_curr,
            as_assured vas_curr,
            p_cover pc_prev,
            as_asset aa_prev,
            as_asset aa_curr,
            p_cover pc_curr,
            status_hist sh_curr,
            status_hist sh_prev
    WHERE       1 = 1
            AND aa_curr.as_asset_id = pc_curr.as_asset_id
            AND aa_prev.p_asset_header_id = aa_curr.p_asset_header_id
            AND aa_prev.as_asset_id = pc_prev.as_asset_id
            AND (aa_prev.p_policy_id, pc_prev.p_cover_id, aa_prev.as_asset_id) =
                  (SELECT   aa.p_policy_id, pc.p_cover_id, aa.as_asset_id
                     FROM   p_policy pp,
                            as_asset aa,
                            p_cover pc,
                            status_hist sh
                    WHERE       /*pp.version_num = (pp_curr.version_num - 1)*/
                            pp.policy_id = pp_curr.prev_ver_id
                                          /*(SELECT p.policy_id
                                            FROM ins.p_policy p,
                                                 ins.document d,
                                                 ins.doc_status_ref rf
                                            WHERE p.policy_id = pp_curr.prev_ver_id
                                              AND p.policy_id = d.document_id
                                              AND d.doc_status_ref_id = rf.doc_status_ref_id
                                              AND rf.brief != 'CANCEL'
                                            ) */                                       
                            AND pp.pol_header_id = pp_curr.pol_header_id
                            AND aa.p_policy_id = pp.policy_id
                            AND pc.as_asset_id = aa.as_asset_id
                            AND aa.P_ASSET_HEADER_ID = aa_curr.P_ASSET_HEADER_ID
                            AND sh.status_hist_id = pc.status_hist_id
                            AND sh.brief != 'DELETED'
                            AND pc.t_prod_line_option_id =
                                  pc_curr.t_prod_line_option_id
                   UNION
                   SELECT   aa.p_policy_id, pc.p_cover_id, aa.as_asset_id
                     FROM   p_policy pp,
                            as_asset aa,
                            p_cover pc,
                            status_hist sh
                    WHERE       pp.version_num = (pp_curr.version_num)
                            AND pp.pol_header_id = pp_curr.pol_header_id
                            AND aa.p_policy_id = pp.policy_id
                            AND aa.P_ASSET_HEADER_ID = aa_curr.P_ASSET_HEADER_ID
                            AND pc.as_asset_id = aa.as_asset_id
                            AND sh.status_hist_id = pc.status_hist_id
                            AND sh.brief != 'DELETED'
                            AND pc.t_prod_line_option_id =
                                  pc_curr.t_prod_line_option_id
                            AND NOT EXISTS
                                  (SELECT   1
                                     FROM   p_policy pp,
                                            as_asset aa,
                                            p_cover pc,
                                            status_hist sh
                                    WHERE   /*pp.version_num = (pp_curr.version_num - 1)*/
                                            pp.policy_id = pp_curr.prev_ver_id
                                                           /*(SELECT p.policy_id
                                                            FROM ins.p_policy p,
                                                                 ins.document d,
                                                                 ins.doc_status_ref rf
                                                            WHERE p.policy_id = pp_curr.prev_ver_id
                                                              AND p.policy_id = d.document_id
                                                              AND d.doc_status_ref_id = rf.doc_status_ref_id
                                                              AND rf.brief != 'CANCEL'
                                                            )*/
                                            AND pp.pol_header_id = pp_curr.pol_header_id
                                            AND aa.p_policy_id = pp.policy_id
                                            AND aa.P_ASSET_HEADER_ID = aa_curr.P_ASSET_HEADER_ID
                                            AND pc.as_asset_id = aa.as_asset_id
                                            AND sh.status_hist_id = pc.status_hist_id
                                            AND sh.brief != 'DELETED'
                                            AND pc.t_prod_line_option_id = pc_curr.t_prod_line_option_id
                                    )
                     )
            AND sh_curr.status_hist_id = pc_curr.status_hist_id
            AND sh_prev.status_hist_id = pc_prev.status_hist_id
            AND vas_curr.as_assured_id = pc_curr.as_asset_id
            AND vc_curr.contact_id(+) = vas_curr.assured_contact_id
            AND vcp_curr.contact_id(+) = vc_curr.contact_id
            AND vas_prev.as_assured_id = pc_prev.as_asset_id
            AND vc_prev.contact_id(+) = vas_prev.assured_contact_id
            AND vcp_prev.contact_id(+) = vc_prev.contact_id
            AND pp_prev.policy_id = aa_prev.p_policy_id
            AND pp_curr.policy_id = aa_curr.p_policy_id
            AND pt_prev.ID = pp_prev.payment_term_id
            AND pt_curr.ID = pp_curr.payment_term_id;
