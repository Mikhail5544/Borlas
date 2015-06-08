create or replace force view v_sell_and_count_2007 as
select vv.prod_desc,
       sum(vv.premium*vv.kf) as sell,
       count(vv.active_policy_id) as count,
       case extract(month from to_date(vv.stt_date,'dd.mm.yyyy')) when 1 then '01'
                                                                 when 2 then '02'
                                                                 when 3 then '03'
                                                                 when 4 then '04'
                                                                 when 5 then '05'
                                                                 when 6 then '06'
                                                                 when 7 then '07'
                                                                 when 8 then '08'
                                                                 when 9 then '09'
                                                                 when 10 then '10'
                                                                 when 11 then '11'
                                                                 when 12 then '12' else '' end as mont
from
(
sELECT  /*+ FIRST_ROWS */
    p.num,
    p.reg_date,
	vds.start_date status_date,
    p.doc_folder_id,
    p.doc_templ_id,
    ph.policy_header_id,
    ph.product_id,
    prod.description prod_desc,
    ph.sales_channel_id,
    sch.description sale_desc,
    ph.fund_id,
    case f_resp.brief when 'RUR' then 1 when 'USD' then 25 when 'EUR' then 35 else 1 end as kf,
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
    --doc.get_doc_status_name(ph.policy_id) status_name,
	NVL(Doc.get_doc_status_name(p.policy_id),Doc.get_doc_status_name(p.policy_id, p.start_date))  status_name,
    cont.contact_id insurer_id,
    --Ent.obj_name(cont.ent_id,cont.contact_id) insurer_name,
    cont.obj_name_orig insurer_name,
	p.policy_id,
	ph.policy_id active_policy_id,
  ph.start_date as stt_date,
	p.notice_num,
	p.is_group_flag,
	dep.name dept_name,
  --dep.department_id,
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
                          AND pc.contact_policy_role_id = cpr.id  --Ent.get_obj_id('t_contact_pol_role','Страхователь')
--  join ven_contact cont ON cont.contact_id = pc.contact_id
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
  left join ORGANISATION_TREE ot1 ON ot1.ORGANISATION_TREE_ID =  dep1.org_tree_id

) vv
where policy_id = active_policy_id
      and vv.status_name not like 'Отменен'
      and (to_char(vv.stt_date, 'DD.MM.RRRR') LIKE '%.%.2007')
      --and vv.stt_date between to_date('01-12-2007','dd-mm-yyyy') and  to_date('31-12-2007','dd-mm-yyyy')
group by vv.prod_desc,
         case extract(month from to_date(vv.stt_date,'dd.mm.yyyy')) when 1 then '01'
                                                                 when 2 then '02'
                                                                 when 3 then '03'
                                                                 when 4 then '04'
                                                                 when 5 then '05'
                                                                 when 6 then '06'
                                                                 when 7 then '07'
                                                                 when 8 then '08'
                                                                 when 9 then '09'
                                                                 when 10 then '10'
                                                                 when 11 then '11'
                                                                 when 12 then '12' else '' end
;

