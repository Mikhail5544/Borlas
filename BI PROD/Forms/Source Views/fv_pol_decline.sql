CREATE OR REPLACE VIEW FV_POL_DECLINE AS
SELECT pd.p_pol_decline_id
      ,ph.ids
      ,p.policy_id
      ,p.pol_header_id
      ,p.pol_num
      ,ph.start_date header_start_date
      ,fp.brief FUND_PAY_BRIEF
      ,pd.reg_code
      ,p.decline_date
      ,pd.management_expenses
      ,vi.contact_name ISSUER_NAME
      ,pt.description payment_terms_desc
      ,dr.name decline_reason_name
      ,il.description  illegal_decline_desc
      ,pd.state_duty
      ,pd.penalty
      ,pd.other_court_fees
      ,pd.borrowed_money_percent
      ,pd.moral_damage
      ,pd.service_fee
      ,pd.issuer_return_sum
      ,pd.debt_fee_fact
      ,p.debt_summ
      ,pd.medo_cost
      ,pd.overpayment
      ,p.return_summ
      ,pd.decline_notice_date
      ,pd.other_pol_sum
      ,pd.act_date
      ,pd.income_tax_sum
      ,pd.income_tax_date
      ,pd.issuer_return_date
      ,pd.total_fee_payment_sum
      ,p.ent_id
      ,pd.admin_expenses
      ,pd.other_pol_num
      ,p.pol_ser
      ,p.end_date
      ,fp.fund_id
      ,pd.t_product_conds_id
      ,p.decline_reason_id
      ,p.payment_term_id
      ,p.decline_party_id
      ,p.decline_type_id
      ,ph.agency_id
      ,ph.product_id
      ,p.description  policy_desc
      ,pd.t_illegal_decline_id
      ,p.version_num
      ,dr.brief decline_reason_brief
      ,pd.pay_doc_num
  FROM ven_p_policy      p
      ,t_decline_reason  dr
      ,p_pol_header      ph
      ,v_pol_issuer      vi
      ,fund              fp
      ,t_payment_terms   pt
      ,p_pol_decline     pd
      ,t_illegal_decline il
 WHERE p.decline_reason_id = dr.t_decline_reason_id(+)
   AND ph.policy_header_id = p.pol_header_id
   AND p.policy_id = vi.policy_id
   AND ph.fund_id = fp.fund_id
   AND pt.id = p.payment_term_id
   AND p.policy_id = pd.p_policy_id
   AND pd.t_illegal_decline_id = il.t_illegal_decline_id(+);
