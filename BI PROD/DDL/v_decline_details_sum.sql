CREATE OR REPLACE FORCE VIEW V_DECLINE_DETAILS_SUM AS
SELECT nvl(pp.pol_ser,' ')||' '||pp.pol_num policy_num,
       pp.notice_num,
       tig.DESCRIPTION ins_type,
       '' ins_type_msfo,
       tpl.description ins_prog,
       vd.NAME agency,
       vpi.contact_name insuer,
       (SELECT obj_name_orig FROM ven_contact WHERE contact_id =  pkg_policy.get_policy_agent_id(pp.policy_id)) AGENT,
       vf.brief fund,
       CASE WHEN vph.fund_id=122
            THEN vpc.ins_amount
            ELSE acc_new.Get_Cross_Rate_By_Id(1, vph.fund_id, 122, pp.start_date)*vpc.ins_amount END ins_sum_r,
       CASE WHEN vph.fund_id<>122
            THEN vpc.ins_amount
            ELSE acc_new.Get_Cross_Rate_By_Id(1, 122, vph.fund_id, pp.start_date)*vpc.ins_amount END ins_sum_fund,
       /*“.к. все проводки у нас в рубл€х то не провер€ем*/
       pkg_renlife_utils.Cover_amount_from_trans(vpc.p_cover_id, 41) ins_prem_rsbu_rub,
       acc_new.Get_Cross_Rate_By_Id(1, 122, vph.fund_id, pp.start_date)*
       pkg_renlife_utils.Cover_amount_from_trans(vpc.p_cover_id, 41)ins_prem_rsbu_fund,

       pkg_renlife_utils.Cover_amount_from_trans(vpc.p_cover_id, 622) ins_prem_msfo_rub,
       acc_new.Get_Cross_Rate_By_Id(1, 122, vph.fund_id, pp.start_date)*
       pkg_renlife_utils.Cover_amount_from_trans(vpc.p_cover_id, 622)ins_prem_msfo_fund,

       CASE WHEN vph.fund_id=122
            THEN vpc.fee
            ELSE acc_new.Get_Cross_Rate_By_Id(1, vph.fund_id, 122, pp.start_date)*vpc.fee END fee_rub,
       CASE WHEN vph.fund_id<>122
            THEN vpc.fee
            ELSE acc_new.Get_Cross_Rate_By_Id(1, 122, vph.fund_id, pp.start_date)*vpc.fee END fee_fund,

       CASE WHEN vph.fund_id=122
            THEN vpc.premium
            ELSE acc_new.Get_Cross_Rate_By_Id(1, vph.fund_id, 122, pp.start_date)*vpc.premium END premium_rub,
       CASE WHEN vph.fund_id<>122
            THEN vpc.fee
            ELSE acc_new.Get_Cross_Rate_By_Id(1, 122, vph.fund_id, pp.start_date)*vpc.premium END premium_fund,

       pkg_renlife_utils.Cover_amount_from_trans(vpc.p_cover_id, 621) ins_prem_APE_rub,
       acc_new.Get_Cross_Rate_By_Id(1, 122, vph.fund_id, pp.start_date)*
       pkg_renlife_utils.Cover_amount_from_trans(vpc.p_cover_id, 621)ins_prem_APE_fund,

       vpc.start_date,
       vpc.end_date,
       vpt.DESCRIPTION pay_term,
       '' not_payed_amount,
       doc.get_doc_status_name(vph.policy_id) pol_head_status,
       doc.get_status_date(pp.policy_id,'READY_TO_CANCEL') rtc_satus_date,
       pp.decline_date,
       vdt.NAME decline_reason
  FROM p_policy pp,
       doc_status ds,
       ven_as_asset vas,
       ven_p_cover vpc,
       v_pol_issuer vpi,
       ven_p_pol_header vph,
       t_prod_line_option tplo,
       t_product_line tpl,
       t_lob_line tlb,
       t_insurance_group tig,
       ven_department vd,
       ven_fund vf,
       ven_t_payment_terms vpt,
       ven_t_decline_reason vdt
 WHERE pp.policy_id = (SELECT MAX(policy_id)
                         FROM p_policy po, doc_status ds
                        WHERE po.policy_id = ds.document_id
                          AND ds.doc_status_ref_id = 21
                          AND po.pol_header_id = pp.pol_header_id)
   AND ds.document_id = pp.policy_id
   AND ds.doc_status_ref_id = 21
   AND vas.p_policy_id(+) = vph.policy_id
   AND vas.as_asset_id = vpc.as_asset_id
   AND pp.pol_header_id = vph.policy_header_id
   AND vpi.policy_id (+) = pp.policy_id
   AND tplo.ID (+) =vpc.t_prod_line_option_id
   AND tplo.product_line_id = tpl.ID (+)
   AND tpl.t_lob_line_id = tlb.t_lob_line_id (+)
   AND tlb.insurance_group_id = tig.t_insurance_group_id (+)
   AND vd.department_id (+) = vph.agency_id
   AND vf.fund_id = vph.fund_id
   AND vpt.ID (+) = pp.payment_term_id
   AND vdt.t_decline_reason_id (+) = pp.decline_reason_id;

