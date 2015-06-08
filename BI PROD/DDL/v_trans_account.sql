CREATE OR REPLACE FORCE VIEW V_TRANS_ACCOUNT AS
SELECT decode(pp.pol_ser, null, pp.pol_num, pp.pol_ser || '-' || pp.pol_num) "Номер полиса",
       pp.pol_ser "Серия полиса",
       pp.pol_num "Полис",
       pp.policy_id,
       pp.version_num "Версия",
       cn.name||' '||cn.first_name||' '||cn.middle_name "Страхователь",
       pp.start_date "Дата начала",
       trm.description "Периодичность",
       pc.fee "Брутто-взнос",
       tmpl.name "Шаблон проводки",
       t.trans_id,
       acc1.num "Счет дебет",
       acc2.num "Счет кредит",
       t.trans_date "Дата проводки",
       ftrans.brief "Валюта проводки",
       facc.brief "Валюта плана счетов",
       opt.description "Риск",
       pc.p_cover_id,
       t.acc_amount "Сумма в валюте счета",
       t.trans_amount "Сумма проводки"
  FROM trans t,
       p_policy pp,
       p_policy_contact pcn,
       contact cn,
       fund ftrans,
       fund facc,
       t_payment_terms trm,
       as_asset aa,
       p_cover pc,
       t_prod_line_option opt,
       trans_templ tmpl,
       account acc1,
       account acc2
 WHERE pp.pol_header_id = pp.pol_header_id
       --(pp.policy_id = 711783 OR 711783 IS NULL)
   and aa.p_policy_id = pp.policy_id
   and pp.policy_id = pcn.policy_id and pcn.contact_policy_role_id = 6
   and cn.contact_id = pcn.contact_id
   and pp.payment_term_id = trm.id
   and ftrans.fund_id = t.trans_fund_id
   and facc.fund_id = t.acc_fund_id
   and t.dt_account_id = acc1.account_id
   and t.ct_account_id = acc2.account_id
   and pc.t_prod_line_option_id = opt.id
   --and pp.version_num = 2
   and t.trans_templ_id = tmpl.trans_templ_id
   and pc.as_asset_id = aa.as_asset_id
   and ((t.a1_dt_ure_id = 305 AND t.a1_dt_uro_id = pc.p_cover_id)
   or (t.a2_dt_ure_id = 305 AND t.a2_dt_uro_id = pc.p_cover_id)
   or (t.a3_dt_ure_id = 305 AND t.a3_dt_uro_id = pc.p_cover_id)
   or (t.a4_dt_ure_id = 305 AND t.a4_dt_uro_id = pc.p_cover_id)
   or (t.a5_dt_ure_id = 305 AND t.a5_dt_uro_id = pc.p_cover_id)
   or (t.a1_ct_ure_id = 305 AND t.a1_ct_uro_id = pc.p_cover_id)
   or (t.a2_ct_ure_id = 305 AND t.a2_ct_uro_id = pc.p_cover_id)
   or (t.a3_ct_ure_id = 305 AND t.a3_ct_uro_id = pc.p_cover_id)
   or (t.a4_ct_ure_id = 305 AND t.a4_ct_uro_id = pc.p_cover_id)
   or (t.a5_ct_ure_id = 305 AND t.a5_ct_uro_id = pc.p_cover_id))
order by pp.policy_id,pp.version_num,tmpl.name,t.trans_date
;

