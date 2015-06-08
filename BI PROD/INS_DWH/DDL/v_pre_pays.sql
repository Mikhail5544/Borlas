create or replace force view ins_dwh.v_pre_pays as
select
       t.date_id,
       t.pol_header_id,
       t.insurer_contact_id,
       t.assured_contact_id,
       ap.contact_id pay_contact_id,
       t.risk_type_id,
       t.risk_type_gaap_id,
       t.agency_id,
       t.t_sales_channel_id,
       t.ag_contract_header_id,
       t.doc_fund,
       t.rate,
       ins.acc_new.Get_Rate_By_Brief(1, t.doc_fund,ap.due_date) rate_on_due_date,
       ap.num,
       ap.amount doc_amount,
       nvl(dd.date_id,-1) due_date_id,
       sum(case when (t.dt_num = '77.00.01') and
       (t.ct_num = '77.01.02' or t.ct_num = '77.05.02') then t.rur_amount else 0 end)  pay_rur_amount,
       sum(case when (t.dt_num = '77.00.01') and
       (t.ct_num = '77.01.02' or t.ct_num = '77.05.02') then t.doc_amount else 0 end)  pay_doc_amount,
       sum(case when t.dt_num = '77.01.01' and t.ct_num = '92.01' then t.rur_amount else 0 end) charge_rsbu_rur_amount,
       sum(case when t.dt_num = '77.01.01' and t.ct_num = '92.01' then t.doc_amount else 0 end) charge_rsbu_doc_amount,
       sum(case when t.dt_num = 'лятн.77.01.01' and t.ct_num = 'лятн.92.01.01' then t.rur_amount else 0 end) charge_ifrs_rur_amount,
       sum(case when t.dt_num = 'лятн.77.01.01' and t.ct_num = 'лятн.92.01.01' then t.doc_amount else 0 end) charge_ifrs_doc_amount


  from fc_trans            t,
       ins.ven_doc_set_off d,
       dm_trans_templ      tt,
       ins.ven_ac_payment  ap,
       dm_date dd

 where t.document_id = d.doc_set_off_id (+) -- DOC_SET_OFF
   and tt.trans_templ_id = t.trans_templ_id
   and t.dt_num in ('77.00.01','77.01.01','лятн.77.01.01')
   and t.ct_num in ('77.01.02', '77.05.02','92.01','лятн.92.01.01')
   and d.child_doc_id = ap.payment_id (+)
   and ap.due_date = dd.sql_date (+)

group by
       t.date_id,
       t.pol_header_id,
       t.insurer_contact_id,
       t.assured_contact_id,
       ap.contact_id,
       t.risk_type_id,
       t.risk_type_gaap_id,
       t.doc_fund,
       t.rate,
       ins.acc_new.Get_Rate_By_Brief(1, t.doc_fund,ap.due_date),
       t.agency_id,
       t.t_sales_channel_id,
       t.ag_contract_header_id,
       nvl(dd.date_id,-1),
       ap.num,
       ap.amount

--)
--and
;

