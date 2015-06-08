create materialized view INS_DWH.MV_CR_FIN_OPERATION
build deferred
refresh force on demand
as
select t.trans_id as "ИД проводки",
       tt.name as "Тип проводки",
       dt.num as "Дебет",
       ct.num as "Кредит",
       t.trans_date as "Дата проводки",
       t.acc_amount as "Сумма в валюте док-та",
       fa.brief as "Валюта док-та",
       t.trans_amount as "Сумма в валюте баланса",
       ft.brief as "Валюта баланса",
       atdt1.name as "Тип аналитики Д1",
       ins.ent.obj_name(t.a1_dt_ure_id, t.a1_dt_uro_id) as "Знач аналитики Д1",
       atdt2.name as "Тип аналитики Д2",
       ins.ent.obj_name(t.a2_dt_ure_id, t.a2_dt_uro_id) as "Знач аналитики Д2",
       atdt3.name as "Тип аналитики Д3",
       ins.ent.obj_name(t.a3_dt_ure_id, t.a3_dt_uro_id) as "Знач аналитики Д3",
       atdt4.name as "Тип аналитики Д4",
       ins.ent.obj_name(t.a4_dt_ure_id, t.a4_dt_uro_id) as "Знач аналитики Д4",
       atdt5.name as "Тип аналитики Д5",
       ins.ent.obj_name(t.a5_dt_ure_id, t.a5_dt_uro_id) as "Знач аналитики Д5",
       atct1.name as "Тип аналитики К1",
       ins.ent.obj_name(t.a1_dt_ure_id, t.a1_dt_uro_id) as "Знач аналитики К1",
       atct2.name as "Тип аналитики К2",
       ins.ent.obj_name(t.a2_dt_ure_id, t.a2_dt_uro_id) as "Знач аналитики К2",
       atct3.name as "Тип аналитики К3",
       ins.ent.obj_name(t.a3_dt_ure_id, t.a3_dt_uro_id) as "Знач аналитики К3",
       atct4.name as "Тип аналитики К4",
       ins.ent.obj_name(t.a4_dt_ure_id, t.a4_dt_uro_id) as "Знач аналитики К4",
       atct5.name as "Тип аналитики К5",
       ins.ent.obj_name(t.a5_dt_ure_id, t.a5_dt_uro_id) as "Знач аналитики К5",
       cover_info."Номер договора",cover_info."Номер заявления",cover_info."ИД договора BI",cover_info."ИД договора LIS",cover_info."ИД покрытия BI",cover_info."ИД покрытия LIS",cover_info."Дата начала покрытия",cover_info."Дата окончания покрытия",cover_info."Кол-во платежей в год",cover_info."Взнос по покрытию",cover_info."Годовая премия на покрытии",cover_info."Усл-е рассрочки",cover_info."Жизнь",cover_info."Программа",cover_info."Продукт",cover_info."ИД сущности"
  from ins.trans t,
       ins.trans_templ tt,
       ins.account dt,
       ins.account ct,
       ins.fund ft,
       ins.fund fa,
       ins.analytic_type atdt1,
       ins.analytic_type atdt2,
       ins.analytic_type atdt3,
       ins.analytic_type atdt4,
       ins.analytic_type atdt5,
       ins.analytic_type atct1,
       ins.analytic_type atct2,
       ins.analytic_type atct3,
       ins.analytic_type atct4,
       ins.analytic_type atct5,
       (select p.pol_ser || '-' || p.pol_num as "Номер договора",
               p.notice_ser || '-' || p.notice_num as "Номер заявления",
               p.pol_header_id as "ИД договора BI",
               p.ext_id as "ИД договора LIS",
               pc.p_cover_id as "ИД покрытия BI",
               pc.ext_id as "ИД покрытия LIS",
               pc.start_date as "Дата начала покрытия",
               pc.end_date as "Дата окончания покрытия",
               pt.number_of_payments as "Кол-во платежей в год",
               pc.fee as "Взнос по покрытию",
               pc.premium as "Годовая премия на покрытии",
               pt.description as "Усл-е рассрочки",
               ig.life_property as "Жизнь",
               ll.description as "Программа",
               pr.description as "Продукт",
               pc.ent_id as "ИД сущности"
          from ins.ven_p_cover        pc,
               ins.as_asset           a,
               ins.ven_p_policy       p,
               ins.t_prod_line_option plo,
               ins.t_product_line     pl,
               ins.t_product_ver_lob  pvl,
               ins.t_product_version  pv,
               ins.t_product          pr,
               ins.t_lob_line         ll,
               ins.t_insurance_group  ig,
               ins.t_payment_terms    pt
         where pc.as_asset_id = a.as_asset_id
           and a.p_policy_id = p.policy_id
           and pc.t_prod_line_option_id = plo.id
           and plo.product_line_id = pl.id
           and pl.t_lob_line_id = ll.t_lob_line_id
           and ll.insurance_group_id = ig.t_insurance_group_id
           and pvl.t_product_ver_lob_id = pl.product_ver_lob_id
           and pv.t_product_version_id = pvl.product_version_id
           and pv.product_id = pr.product_id
           and p.payment_term_id = pt.id) cover_info
 where tt.trans_templ_id = t.trans_templ_id
   and dt.account_id = t.dt_account_id
   and ct.account_id = t.ct_account_id
   and ft.fund_id = t.trans_fund_id
   and fa.fund_id = t.acc_fund_id
   and dt.a1_analytic_type_id = atdt1.analytic_type_id (+)
   and dt.a2_analytic_type_id = atdt2.analytic_type_id (+)
   and dt.a3_analytic_type_id = atdt3.analytic_type_id (+)
   and dt.a4_analytic_type_id = atdt4.analytic_type_id (+)
   and dt.a5_analytic_type_id = atdt5.analytic_type_id (+)
   and ct.a1_analytic_type_id = atct1.analytic_type_id (+)
   and ct.a2_analytic_type_id = atct2.analytic_type_id (+)
   and ct.a3_analytic_type_id = atct3.analytic_type_id (+)
   and ct.a4_analytic_type_id = atct4.analytic_type_id (+)
   and ct.a5_analytic_type_id = atct5.analytic_type_id (+)
   and t.obj_uro_id = cover_info."ИД покрытия BI"(+)
   and t.obj_ure_id = cover_info."ИД сущности"(+);

