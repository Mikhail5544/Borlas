create or replace force view v_policy_journal_old as
select
    d.num,
    d.reg_date,
    d.doc_folder_id,
    d.doc_templ_id,
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
    doc.get_doc_status_name(ph.policy_id) status_name,
    cont.contact_id insurer_id,
    ent.obj_name(cont.ent_id,cont.contact_id) insurer_name
  from p_pol_header ph
  join p_policy p on ph.policy_id = p.policy_id
  join document d on d.document_id = ph.policy_header_id
  join p_policy_contact pc on pc.policy_id = p.policy_id
                          and pc.contact_policy_role_id = (
                                                            select cpr.id
                                                            from t_contact_pol_role cpr
                                                            where cpr.brief = 'Страхователь'
                                                          )
  join contact cont on cont.contact_id = pc.contact_id
  join t_product prod on prod.product_id = ph.product_id
  join fund f_resp on f_resp.fund_id = ph.fund_id
  join fund f_pay on f_pay.fund_id = ph.fund_pay_id
  join t_sales_channel sch on sch.id = ph.sales_channel_id
 order by insurer_name, prod_desc, pol_ser, pol_num;

