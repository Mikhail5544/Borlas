CREATE OR REPLACE FORCE VIEW V_VESELEK_POLICY_VERSION AS
SELECT pp.policy_header_id,
       nvl(pp.pol_ser,'')||'-'||pp.pol_num as pol_num,
       pp.notice_num as notice_num,
       pp.start_date,
       pp.insurer_id,
       pp.insurer_name,
       pp.agency_id,
       pp.agency_name,
       pp.sale_desc,
       pp.status_name,
       pp.product_id,
       pp.prod_desc,
       rf.name,
       dss.start_date as  status_date
FROM (SELECT
  p.num,
  p.reg_date,
	vds.start_date status_date,
  p.doc_folder_id,
  p.doc_templ_id,
  ph.policy_header_id,
  ph.product_id,
  prod.brief prod_desc,
  ph.sales_channel_id,
  sch.description sale_desc,
  ph.fund_id,
  f_resp.brief f_resp,
  ph.fund_pay_id,
  f_pay.brief f_pay,
  ph.filial_id,
  p.pol_ser pol_ser,
  p.pol_num pol_num,
	p.version_order_num,
  p.notice_date,
  p.sign_date,
  p.confirm_date,
  p.start_date,
  p.end_date,
  p.first_pay_date,
  p.ins_amount,
  p.premium,
  p.payment_term_id,
  p.period_id,
  NVL(Doc.get_doc_status_name(p.policy_id),Doc.get_doc_status_name(p.policy_id, p.start_date))  status_name,
  cont.contact_id insurer_id,
  cont.obj_name_orig insurer_name,
	p.policy_id,
	ph.policy_id active_policy_id,
  p.notice_ser,
	p.notice_num,
	p.is_group_flag,
	dep.name dept_name,
  ph.agency_ID,
  ot.organisation_tree_id org_id,
	ot.NAME filial_name,
	ot1.NAME||' - '||dep1.NAME agency_name,
	vpc.contact_name curator_name,
	ADD_MONTHS(p.first_pay_date, 12*p.fee_payment_term) PAY_PERIOD_END_DATE,
	p.PAYMENT_START_DATE,
	Ent.obj_name('T_PAYMENT_TERMS',p.PAYMENT_TERM_ID) pay_term_name,
	Ent.obj_name('T_PAYMENT_TERMS', p.PAYMENTOFF_TERM_ID) paymentoff_term_name,
  p.waiting_period_id,
	Pkg_Policy.is_in_waiting_period(p.policy_id, p.waiting_period_id, p.start_date) is_in_waiting_period
  FROM ven_p_pol_header ph
  join ven_p_policy p ON p.pol_header_id = ph.policy_header_id
  join T_CONTACT_POL_ROLE cpr ON cpr.brief = 'Страхователь'
  join P_POLICY_CONTACT pc ON pc.policy_id = p.policy_id
                          AND pc.contact_policy_role_id = cpr.id
  join CONTACT cont ON cont.contact_id = pc.contact_id
  join T_PRODUCT prod ON prod.product_id = ph.product_id
  join FUND f_resp ON f_resp.fund_id = ph.fund_id
  join FUND f_pay ON f_pay.fund_id = ph.fund_pay_id
  left join ven_department dep ON ph.COMPANY_TREE_ID = dep.department_id
  left join ORGANISATION_TREE ot ON ot.ORGANISATION_TREE_ID =  dep.org_tree_id
  left join v_pol_curator vpc ON p.policy_id = vpc.policy_id
  left join DOC_STATUS vds ON vds.doc_status_id =  Doc.get_doc_status_rec_id(p.policy_id)
  left outer join T_SALES_CHANNEL sch ON sch.id = ph.sales_channel_id
  left join ven_department dep1 ON ph.agency_ID = dep1.department_id
  left join ORGANISATION_TREE ot1 ON ot1.ORGANISATION_TREE_ID =  dep1.org_tree_id) pp

  left join doc_status dss on (dss.document_id = pp.policy_id)
  left join doc_status_ref rf on (dss.doc_status_ref_id = rf.doc_status_ref_id)
WHERE pp.policy_id = pp.active_policy_id
      --and pp.policy_header_id = 709563
;

