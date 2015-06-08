create materialized view INS_DWH.MV_CR_SALES_CHANNEL
build deferred
refresh force on demand
as
select pr.description product_name, -- Продукт
	   ins.ent.obj_name('P_POLICY',ph.policy_id) pol_ser_num, -- Серия-номер договора
       ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- страхователь
	   sc.description sales_channel, -- канал продаж,
	   ap.num order_num, --(где номер ПП/ПКО)
       t.trans_date pay_date, -- дата бухгалтерской проводки
       t.trans_amount pay_amount,  -- сумма оплаты
       f1.brief pay_fund,        -- вылюта опдаты
       t.acc_amount amount,    -- сумма оплаты в валюте ответственности
       f2.brief fund -- валюта ответственности
from ins.ven_trans t
  join ins.ven_trans_templ tt on tt.trans_templ_id = t.trans_templ_id and tt.brief = 'ЗачВзнСтрАг'
  join ins.oper o on o.oper_id = t.oper_id
  join ins.doc_set_off d on d.doc_set_off_id = o.document_id
  join ins.ven_ac_payment ap on ap.payment_id = d.child_doc_id
  join ins.p_policy pp on t.a2_ct_uro_id = pp.policy_id
  join ins.p_pol_header ph on ph.policy_header_id = pp.pol_header_id
  join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
  join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = 'Страхователь'
  join ins.ven_contact c on c.contact_id = ppc.contact_id
  join ins.ven_t_product pr on pr.product_id = ph.product_id
  join ins.t_sales_channel sc on sc.id = ph.sales_channel_id
  join ins.fund f1 on f1.fund_id = t.trans_fund_id
  join ins.fund f2 on f2.fund_id = ph.fund_id;

