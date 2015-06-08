CREATE OR REPLACE VIEW V_POLICY_JOURNAL AS
SELECT /*+ FIRST_ROWS */
 p.num
,p.reg_date
,vds.start_date status_date
,p.doc_folder_id
,p.doc_templ_id
,ph.policy_header_id
,ph.product_id
,prod.brief prod_desc
,ph.sales_channel_id
,sch.description sale_desc
,ph.fund_id
,f_resp.brief f_resp
,ph.fund_pay_id
,f_pay.brief f_pay
,ph.filial_id
,p.pol_ser pol_ser
,p.pol_num pol_num
,p.version_order_num
,p.notice_date
,p.sign_date
,p.confirm_date
,p.start_date
,p.end_date
,p.first_pay_date
,p.ins_amount
,p.premium
,p.payment_term_id
,p.period_id
,doc.get_doc_status_name(ph.policy_id) status_name
,cont.contact_id insurer_id
,cont.obj_name_orig insurer_name
,p.policy_id
,p.notice_num
,p.is_group_flag
,dep.name dept_name
,dep.department_id
,ot.name || ' - ' || dep.name filial_name
,vpc.contact_name curator_name
,ADD_MONTHS(p.first_pay_date, 12 * p.fee_payment_term) pay_period_end_date
,p.payment_start_date
,ent.obj_name('T_PAYMENT_TERMS', p.payment_term_id) pay_term_name
,ent.obj_name('T_PAYMENT_TERMS', p.paymentoff_term_id) paymentoff_term_name
,p.waiting_period_id
,pkg_policy.is_in_waiting_period(p.policy_id, p.waiting_period_id, p.start_date) is_in_waiting_period
,ph.description
,CASE
   WHEN nvl(p.is_group_flag, 0) = 0
        AND (SELECT COUNT(*) FROM as_asset aa WHERE aa.p_policy_id = p.policy_id) < 2 THEN
    (SELECT aas.credit_account_number
       FROM as_asset   aa
           ,as_assured aas
      WHERE aa.p_policy_id = p.policy_id
        AND aas.as_assured_id = aa.as_asset_id)
 END credit_account_number
  FROM ven_p_pol_header ph
  JOIN ven_p_policy p
    ON ph.policy_id = p.policy_id
  JOIN ven_p_policy_contact pc
    ON pc.policy_id = p.policy_id
   AND pc.contact_policy_role_id = ent.get_obj_id('t_contact_pol_role', 'Страхователь')
  JOIN ven_contact cont
    ON cont.contact_id = pc.contact_id
  JOIN ven_t_product prod
    ON prod.product_id = ph.product_id
  JOIN ven_fund f_resp
    ON f_resp.fund_id = ph.fund_id
  JOIN ven_fund f_pay
    ON f_pay.fund_id = ph.fund_pay_id
  LEFT JOIN ven_department dep
    ON ph.company_tree_id = dep.department_id
  LEFT JOIN organisation_tree ot
    ON ot.organisation_tree_id = dep.org_tree_id
  LEFT JOIN v_pol_curator vpc
    ON p.policy_id = vpc.policy_id
  LEFT JOIN ven_doc_status vds
    ON vds.doc_status_id = doc.get_doc_status_rec_id(p.policy_id)
  LEFT OUTER JOIN ven_t_sales_channel sch
    ON sch.id = ph.sales_channel_id;
