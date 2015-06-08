create or replace force view v_re_bordero_line as
select bl."RE_BORDERO_LINE_ID",bl."RE_BORDERO_ID",bl."POL_HEADER_ID",bl."POLICY_ID",bl."COVER_ID",bl."PAYMENT_ID",bl."PAYMENT_START_DATE",bl."PAYMENT_END_DATE",bl."AS_ASSURED_ID",bl."ASSURER_GENDER",bl."ASSURER_AGE",bl."PAYMENT_NUMBER",bl."YEAR_PAY_COUNT",bl."YEAR_REINSURER_PREMIUM",bl."RISK_BENEFIT_INSURED",bl."REINSURER_SHARE",bl."REINSURER_TARIFF",bl."K_MED",bl."K_NO_MED",bl."S_MED",bl."S_NO_MED",bl."PERIOD_REINSURER_PREMIUM",bl."MODAL_FACTOR",bl."INS_AMOUNT",bl."RE_COM_RATE",bl."RE_COMISION",bl."ORIGINAL_BENEFIT_INSURED",bl."ORIGINAL_BENEFIT_REINSURED",bl."INITIAL_RETENTION",bl."RETENTION",bl."INITIAL_SUM_ABOVE_RETENTION",bl."SUM_RISK_REINSURER",bl."SUM_ASSURED",bl."TV",bl."T_0_V",bl."A1_XN",bl."A_XN",bl."A_X_N",bl."CALC_YEAR_NUMBER",bl."TARIFF",bl."LIMIT_SUM",bl."LIMIT_PROC",bl."RESERVE",bl."POLICY_DECLINE_DATE",bl."PREMIUM_TYPE_ID",bl."FUND_ID",bl."RETURNED_PREMIUM",bl."RETURNED_COMISSION",bl."RE_START_DATE",bl."RE_EXPIRY_DATE",bl."CLAIM_ID",bl."POLICY_START_DATE",bl."CHANGE_POLICY_ID",bl."CHANGE_TYPE",bl."PARENT_LINE_ID",
ph.ids, p.pol_num, plo.description, c.obj_name_orig, bt.name as bordero_type_name, bpt.premium_type_name, pc.start_date, pc.end_date
from re_bordero_line bl
,p_cover pc
,t_prod_line_option plo
,as_assured asr
,contact c
,p_pol_header ph
,p_policy p
,re_bordero b
,re_bordero_type bt
,re_bordero_premium_type bpt
where pc.p_cover_id=bl.cover_id
and plo.id=pc.t_prod_line_option_id
and asr.as_assured_id=bl.as_assured_id
and c.contact_id=asr.assured_contact_id
and ph.policy_header_id=bl.pol_header_id
and p.policy_id=bl.policy_id
and bl.re_bordero_id=b.re_bordero_id
and bt.re_bordero_type_id=b.re_bordero_type_id
and bpt.premium_type_id=bl.premium_type_id;

