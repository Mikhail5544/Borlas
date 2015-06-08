create or replace view v_mass_decline_rep  as  
SELECT ph.ids
      ,doc.num contract_number --Номер договора
      ,cont.obj_name_orig insuree_name --Страхователь
      ,dr.name decline_reason
      ,ph.start_date contract_start_date
      ,p.decline_date
      ,pt.description payment_term
      ,pcnd.description product_conds --полисные условия
      ,pd.reg_code region_code
      ,pd.act_date
      ,f_resp.name fund_name
      ,nvl(pd.issuer_return_sum, 0) issuer_return_sum --Сумма к возврату
      ,CASE
         WHEN pd.debt_fee_fact > 0 THEN
          -pd.debt_fee_fact
         ELSE
          nvl(pd.overpayment, 0)
       END debt_ovpmnt --Недоплата, Переплата
      ,nvl(pd.medo_cost, 0) medo_cost
      ,nvl(pd.state_duty, 0) state_duty
      ,nvl(pd.penalty, 0) penalty
      ,nvl(pd.other_court_fees, 0) other_court_fees
      ,nvl(pd.other_pol_sum, 0) other_pol_sum
      ,nvl(p.return_summ, 0) return_summ
      ,cont2.obj_name_orig insured_name --Застрахованный
      ,prl.description cover_name
      ,cd.cover_period
      ,nvl(cd.redemption_sum, 0) redemption_sum
      ,nvl(cd.add_invest_income, 0) add_surr_summ
      ,nvl(cd.add_invest_income, 0) add_invest_income
      ,nvl(cd.return_bonus_part, 0) return_bonus_part
      ,nvl(cd.admin_expenses, 0) admin_expenses
      ,nvl(cd.bonus_off_prev, 0) bonus_off_prev
      ,nvl(cd.bonus_off_current, 0) bonus_off_current
      ,nvl(cd.unpayed_premium_previous, 0) unpayed_premium_previous
      ,nvl(cd.unpayed_premium_current, 0) unpayed_premium_current
      ,nvl(cd.unpayed_premium_lp, 0) unpayed_premium_lp
      ,dpd.p_decline_pack_id
      ,p.policy_id
      ,pd.income_tax_sum
      ,ph.policy_header_id
  FROM p_decline_pack_detail dpd
      ,p_policy              p
      ,p_pol_header          ph
      ,ins.document          doc
      ,p_policy_contact      pc
      ,contact               cont
      ,t_decline_reason      dr
      ,t_payment_terms       pt
      ,p_pol_decline         pd
      ,t_product_conds       pcnd
      ,fund                  f_resp
      ,p_cover_decline       cd
      ,as_asset              a
      ,as_assured            asrd
      ,contact               cont2
      ,t_product_line        prl
 WHERE p.policy_id = dpd.p_policy_id
   AND ph.policy_id = p.policy_id
   AND doc.document_id = p.policy_id
   AND pc.policy_id = p.policy_id
   AND pc.contact_policy_role_id = 6 --Страхователь
   AND cont.contact_id = pc.contact_id
   AND p.decline_reason_id = dr.t_decline_reason_id
   AND pt.id = p.payment_term_id
   AND pd.p_policy_id = p.policy_id
   AND pcnd.t_product_conds_id(+) = pd.t_product_conds_id
   AND f_resp.fund_id = ph.fund_id
   AND cd.p_pol_decline_id = pd.p_pol_decline_id
   AND a.as_asset_id = cd.as_asset_id
   AND asrd.as_assured_id = a.as_asset_id
   AND cont2.contact_id = asrd.assured_contact_id
   AND prl.id = cd.t_product_line_id; 
/
