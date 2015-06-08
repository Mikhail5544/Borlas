create or replace view v_re_bordero_line_rep as
select case ar.re_bordero_type_id
         when 0 then 'Облигатор стандарт'
         when 1 then 'Облигатор не стандарт'
         when 2 then 'Факультатив'
       end as reinsurance_sign -- За счет этого поля появились дубли
      ,(select cc.latin_name
         from organisation_tree ot
             ,contact cc
        where ot.brief = 'ЦО'
          and ot.company_id = cc.contact_id) as benefit_campaign_code
      ,case p.is_group_flag
         when 1 then pic.name
       end as enterprise_ins
      ,tp.description as occupation
      ,case
         when p.is_group_flag = 1 then
           case
              when p.version_num = 1 then 'Новый договор'
              else pct.name||replace('('||pkg_utils.get_aggregated_string(cast(multiset(select adt.description
                                                                                          from p_pol_addendum_type pad
                                                                                              ,t_addendum_type     adt
                                                                                        where pad.p_policy_id        = p.policy_id
                                                                                          and pad.t_addendum_type_id = adt.t_addendum_type_id
                                                                                       ) as tt_one_col),','
                                                                         )||')','()'
                                    )
           end
       end as alt_type
      ,null as termination_date
      ,bt.short_name as bordero_part
      ,d.num || ' от ' || mc.sign_date as re_number
      ,bp.re_bordero_package_id
      ,ph.ids
      ,bl.pol_header_id
      ,bl.policy_id
      --,d2.num as policy_num
      ,case
         when p.pol_ser is not null and p.pol_num is not null then
            p.pol_ser||'-'|| p.pol_num
         when p.pol_num is not null then
           p.pol_num
         else
           to_char(ph.ids)
       end as policy_num
      ,prod.brief as prod_brief
      ,prod.description as prod_name
      ,pl.brief
      ,pl.msfo_brief as risk_code
      ,pl.description as risk_name
--      ,ca.obj_name_orig as fio
      ,c.obj_name_orig as fio
      ,c.contact_id     as insured_id
--      ,c.obj_name_orig
      ,to_char(cp.date_of_birth,'dd.mm.yyyy') as date_of_birth
      ,decode(cp.gender,1,'M','F') as sex
      ,bl.assurer_age
      ,to_char(pc.start_date,'dd.mm.yyyy') as start_date
      ,to_char(pc.end_date,'dd.mm.yyyy') as expiry_date
      ,to_char(bl.re_start_date,'dd.mm.yyyy') as re_start_date
      ,to_char(bl.re_expiry_date,'dd.mm.yyyy') as re_expiry_date
      ,/*tpr.period_value*/
       round(months_between(pc.end_date+1,pc.start_date)/12,2) as duration
      ,to_char(bl.payment_start_date,'dd.mm.yyyy') as payment_start_date
      ,to_char(bl.payment_end_date,'dd.mm.yyyy') as payment_end_date
      ,bl.ins_amount
      ,bl.initial_retention
      ,bl.retention
      ,bl.reserve
      ,bl.original_benefit_insured
      ,bl.reinsurer_share
      ,bl.original_benefit_reinsured
      ,bl.risk_benefit_insured
      ,bl.tariff
      ,bl.year_reinsurer_premium
      ,bl.k_med
      ,bl.k_no_med
      ,bl.s_med
      ,bl.s_no_med
      ,bl.modal_factor
      ,bl.period_reinsurer_premium
      ,bl.period_reinsurer_premium*acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as period_reinsurer_premium_rur
      ,null as returned_premium
      ,null as returned_premium_rur
      ,bl.fixed_com_rate
      ,bl.fixed_commission
      ,bl.add_com_rate
      ,bl.add_commission
      ,bl.re_com_rate
      ,bl.re_comision
      ,bl.re_comision*acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as re_comision_rur
      ,null as return_fixed_commission
      ,null as return_add_commission
      ,bl.returned_comission
      ,bl.returned_comission*acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as returned_comission_rur
      ,f.brief as fund_brief
      ,c1.obj_name_orig as reinsurer_name
      ,rbp.premium_type_name
      ,pt.description as payment_freq
      ,case
         when prod.brief = 'GN' and ct.brief in ('АКБ','КБ') and sc.brief = 'BANK' then 'Кредитный'
         when prod.brief like 'CR%' then 'Кредитный'
         when (prod.brief != 'GN' or ct.brief not in ('АКБ','КБ') or sc.brief != 'BANK') and p.is_group_flag = 1 then 'Корпоративный'
         else 'Индивидуальный'
       end as bordero_type
      ,to_char(bp.end_date,'q')||' кв '||to_char(bp.end_date,'yyyy') as Quarter
      ,case tl.brief
         when 'Acc' then 'C'
         when 'Life.Life' then 'L'
       end as life_non_life_ras
      ,case
         when tpr.period_value <= 1 then 'short'
         else 'long'
       end
       ||
       case tl.brief
         when 'Acc' then 'ns'
         when 'Life.Life' then 'life'
       end
       as short_long_ias
      ,to_char(bp.end_date,'yyyy') as bordero_year
      ,acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as currency_to_rur_rate
      ,(select tk.name||' '||tk.socr from t_kladr tk where tk.t_kladr_id = p.region_id) as region_name
      ,bl.period_reinsurer_premium - bl.re_comision as balance
      ,to_char(p.start_date,'dd.mm.yyyy') as eff_alt_date
      ,case pof.brief
         when 'Единовременно' then 0
         else pof.number_of_payments
       end as benefit_freqcode
      ,bl.initial_sum_above_retention
      ,bl.sum_risk_reinsurer
      ,bl.modal_factor*bl.tariff as periodicity_tariff
      ,s.work_group_id as class_occup
      ,0 as extra_charge
      ,cv.flg_profit as profit_com_part
      ,case ar.re_bordero_type_id
         when 0 then
           to_char(ret.reinsurance_code)
         else
           '1'||substr(to_char(ret.reinsurance_code),2)
       end as status
      ,case p.version_num
         when 1 then 'Договор страхования'
         else 'Дополнительное соглашение'||nvl2(p.version_order_num,' №'||p.version_order_num,null)
       end as comments
      ,to_char(p.confirm_date,'dd.mm.yyyy')            as wait_period_start_date
      ,to_char(p.waiting_period_end_date,'dd.mm.yyyy') as wait_period_end_date
      ,case
         when wpe.description != 'Нет' then
           wpe.description
         else
           '0'
       end                       as wait_period_duration
  from re_bordero_line         bl
      ,re_bordero              b
      ,re_bordero_type         bt
      ,re_bordero_package      bp
      ,re_bordero_premium_type rbp
      ,re_contract_version     cv
      ,re_main_contract        mc
      ,document                d
      ,contact                 c1
      ,p_cover                 pc
      ,t_period                tpr
      ,fund                    f
      ,t_prod_line_option      plo
      ,t_product_line          pl
      ,t_product_ver_lob       pvl
      ,t_lob                   tl
      ,t_product_version       pv
      ,t_product               prod
      ,as_asset                a
      ,as_assured              s
      ,contact                 c
      ,cn_person               cp
      ,p_policy                p
      ,p_pol_header            ph
      --,document                d2
      ,t_payment_terms         pt
      ,t_payment_terms         pof
      ,v_pol_issuer            pi
      ,contact                 pic
      ,t_contact_type          ct
      ,t_sales_channel         sc
      ,as_assured_re           ar
      ,t_profession            tp
      ,t_policy_change_type    pct
      ,re_reinsurance_type     ret
      ,t_period                wpe
 where bl.re_bordero_id          = b.re_bordero_id
   and b.re_bordero_package_id   = bp.re_bordero_package_id
   and pc.p_cover_id             = bl.cover_id
   and tpr.id                    = pc.period_id
   and plo.id                    = pc.t_prod_line_option_id
   and pl.id                     = plo.product_line_id
   and pl.product_ver_lob_id     = pvl.t_product_ver_lob_id
   and pvl.product_version_id    = pv.t_product_version_id
   and pv.product_id             = prod.product_id
   and a.as_asset_id             = pc.as_asset_id
   and s.as_assured_id           = a.as_asset_id
   and c.contact_id              = s.assured_contact_id
   and cp.contact_id             = c.contact_id
   and p.policy_id               = a.p_policy_id
   and ph.policy_header_id       = p.pol_header_id
   --and d2.document_id            = ph.policy_header_id
   and bt.re_bordero_type_id     = b.re_bordero_type_id
   and cv.re_contract_version_id = bp.re_contract_id
   and d.document_id             = cv.re_contract_version_id
   and mc.re_main_contract_id    = cv.re_main_contract_id
   and f.fund_id                 = b.fund_id
   and rbp.premium_type_id       = bl.premium_type_id
   and c1.contact_id             = mc.reinsurer_id
   and pt.id                     = p.payment_term_id
   and p.policy_id               = pi.policy_id
   and pi.contact_id             = pic.contact_id
   and pic.contact_type_id       = ct.id
   and ph.sales_channel_id       = sc.id
   and pvl.lob_id                = tl.t_lob_id
   and p.policy_id               = ar.p_policy_id
   and s.t_profession_id         = tp.id (+)
   and p.t_pol_change_type_id    = pct.t_policy_change_type_id (+)
   and p.paymentoff_term_id      = pof.id (+)
   and cv.re_insurance_type_id   = ret.reinsurance_type_id
   and cv.re_contract_version_id = ar.re_contract_version_id
   and p.waiting_period_id       = wpe.id
union all
select /*+ LEADING(CPR RC REB RBP B BT BP CV RET F MC BL D PC TPR PLO PL PVL TL PV PROD A P PCT POF PT WPE AR PH SC PI S TP C1 C CP PIC CT)*/
case ar.re_bordero_type_id
         when 0 then 'Облигатор стандарт'
         when 1 then 'Облигатор не стандарт'
         when 2 then 'Факультатив'
       end as reinsurance_sign -- За счет этого поля появились дубли
      ,(select cc.latin_name
         from organisation_tree ot
             ,contact cc
        where ot.brief = 'ЦО'
          and ot.company_id = cc.contact_id) as benefit_campaign_code
      ,case p.is_group_flag
         when 1 then pic.name
       end as enterprise_ins
      ,tp.description as occupation
      ,case
         when p.is_group_flag = 1 then
           case
              when p.version_num = 1 then 'Новый договор'
              else pct.name||replace('('||pkg_utils.get_aggregated_string(cast(multiset(select adt.description
                                                                                          from p_pol_addendum_type pad
                                                                                              ,t_addendum_type     adt
                                                                                        where pad.p_policy_id        = p.policy_id
                                                                                          and pad.t_addendum_type_id = adt.t_addendum_type_id
                                                                                       ) as tt_one_col),','
                                                                         )||')','()'
                                    )
           end
       end as alt_type
      ,to_char(rc.cancel_date,'dd.mm.yyyy') as termination_date
      ,bt.short_name as bordero_part
      ,d.num || ' от ' || mc.sign_date as re_number
      ,bp.re_bordero_package_id
      ,ph.ids
      ,bl.pol_header_id
      ,bl.policy_id
      --,d2.num as policy_num
      ,case
         when p.pol_ser is not null and p.pol_num is not null then
            p.pol_ser||'-'|| p.pol_num
         when p.pol_num is not null then
           p.pol_num
         else
           to_char(ph.ids)
       end as policy_num
      ,prod.brief as prod_brief
      ,prod.description as prod_name
      ,pl.brief
      ,pl.msfo_brief as risk_code
      ,pl.description as risk_name
--      ,ca.obj_name_orig as fio
      ,c.obj_name_orig as fio
      ,c.contact_id     as insured_id
      --,c.obj_name_orig
      ,to_char(cp.date_of_birth,'dd.mm.yyyy') as date_of_birth
      ,case cp.gender
         when 1 then 'M'
         else 'F'
       end as sex
      ,bl.assurer_age
      ,to_char(pc.start_date,'dd.mm.yyyy') as start_date
      ,to_char(pc.end_date,'dd.mm.yyyy') as expiry_date
      ,to_char(bl.re_start_date,'dd.mm.yyyy') as re_start_date
      ,to_char(bl.re_expiry_date,'dd.mm.yyyy') as re_expiry_date
      ,/*tpr.period_value*/
       round(months_between(pc.end_date+1,pc.start_date)/12,2)       as duration
      ,to_char(bl.payment_start_date,'dd.mm.yyyy') as payment_start_date
      ,to_char(bl.payment_end_date,'dd.mm.yyyy') as payment_end_date
      ,bl.ins_amount
      ,bl.initial_retention
      ,bl.retention
      ,bl.reserve
      ,bl.original_benefit_insured
      ,bl.reinsurer_share
      ,bl.original_benefit_reinsured
      ,bl.risk_benefit_insured
      ,bl.tariff
      ,null as year_reinsurer_premium
      ,bl.k_med
      ,bl.k_no_med
      ,bl.s_med
      ,bl.s_no_med
      ,bl.modal_factor
      ,null as period_reinsurer_premium
      ,null as period_reinsurer_premium_rur
      ,reb.returned_premium as returned_premium
      ,reb.returned_premium*acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as returned_premium_rur
      ,null as fixed_com_rate
      ,null as fixed_commission
      ,null as add_com_rate
      ,null as add_commission
      ,null as re_com_rate
      ,null as re_comision
      ,null as re_comision_rur
      ,reb.return_fixed_commission
      ,reb.return_add_commission
      ,reb.return_re_commission as returned_comission
      ,reb.return_re_commission*acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as returned_comission_rur
      ,f.brief as fund_brief
      ,c1.obj_name_orig as reinsurer_name
      ,rbp.premium_type_name
      ,pt.description as payment_freq
      ,case
         when prod.brief = 'GN' and ct.brief in ('АКБ','КБ') and sc.brief = 'BANK' then 'Кредитный'
         when prod.brief like 'CR%' then 'Кредитный'
         when (prod.brief != 'GN' or ct.brief not in ('АКБ','КБ') or sc.brief != 'BANK') and p.is_group_flag = 1 then 'Корпоративный'
         else 'Индивидуальный'
       end as bordero_type
      ,to_char(bp.end_date,'q')||' кв '||to_char(bp.end_date,'yyyy') as Quarter
      ,case tl.brief
         when 'Acc' then 'C'
         when 'Life.Life' then 'L'
       end as life_non_life_ras
      ,case
         when tpr.period_value <= 1 then 'short'
         else 'long'
       end
       ||
       case tl.brief
         when 'Acc' then 'ns'
         when 'Life.Life' then 'life'
       end
       as short_long_ias
      ,to_char(bp.end_date,'yyyy') as bordero_year
      ,acc_new.Get_Rate_By_ID(1/*ЦБ*/,f.fund_id, bp.end_date) as currency_to_rur_rate
      ,(select tk.name||' '||tk.socr from t_kladr tk where tk.t_kladr_id = p.region_id) as region_name
      ,null as balance
      ,to_char(p.start_date,'dd.mm.yyyy') as eff_alt_date
      ,case pof.brief
         when 'Единовременно' then 0
         else pof.number_of_payments
       end as benefit_freqcode
      ,bl.initial_sum_above_retention
      ,bl.sum_risk_reinsurer
      ,bl.modal_factor*bl.tariff as periodicity_tariff
      ,s.work_group_id as class_occup
      ,0 as extra_charge
      ,cv.flg_profit as profit_com_part
      ,case ar.re_bordero_type_id
         when 0 then
           to_char(ret.reinsurance_code)
         else
           '1'||substr(to_char(ret.reinsurance_code),2)
       end as status
      ,case p.version_num
         when 1 then 'Договор страхования'
         else 'Дополнительное соглашение'||nvl2(p.version_order_num,' №'||p.version_order_num,null)
       end comments
      ,to_char(p.confirm_date,'dd.mm.yyyy')            as wait_period_start_date
      ,to_char(p.waiting_period_end_date,'dd.mm.yyyy') as wait_period_end_date
      ,case
         when wpe.description != 'Нет' then
           wpe.description
         else
           '0'
       end                       as wait_period_duration
  from re_bordero_line         bl
      ,re_bordero              b
      ,re_bordero_type         bt
      ,re_bordero_package      bp
      ,re_bordero_premium_type rbp
      ,re_contract_version     cv
      ,re_main_contract        mc
      ,document                d
      ,contact                 c1
      ,p_cover                 pc
      ,t_period                tpr
      ,fund                    f
      ,t_prod_line_option      plo
      ,t_product_line          pl
      ,t_product_ver_lob       pvl
      ,t_lob                   tl
      ,t_product_version       pv
      ,t_product               prod
      ,as_asset                a
      ,as_assured              s
      ,contact                 c
      ,cn_person               cp
      ,p_policy                p
      ,p_pol_header            ph
      ,t_payment_terms         pt
      ,t_payment_terms         pof
      ,p_policy_contact        pi
      ,t_contact_pol_role      cpr
      ,contact                 pic
      ,t_contact_type          ct
      ,t_sales_channel         sc
      ,as_assured_re           ar
      ,t_profession            tp
      ,t_policy_change_type    pct
      ,rel_recover_bordero     reb
      ,re_cover                rc
      ,re_reinsurance_type     ret
      ,t_period                wpe
 where b.re_bordero_package_id   = bp.re_bordero_package_id
   and pc.p_cover_id             = bl.cover_id
   and tpr.id                    = pc.period_id
   and plo.id                    = pc.t_prod_line_option_id
   and pl.id                     = plo.product_line_id
   and pl.product_ver_lob_id     = pvl.t_product_ver_lob_id
   and pvl.product_version_id    = pv.t_product_version_id
   and pv.product_id             = prod.product_id
   and a.as_asset_id             = pc.as_asset_id
   and s.as_assured_id           = a.as_asset_id
   and c.contact_id              = s.assured_contact_id
   and cp.contact_id             = c.contact_id
   and p.policy_id               = a.p_policy_id
   and ph.policy_header_id       = p.pol_header_id
   and bt.re_bordero_type_id     = b.re_bordero_type_id
   and cv.re_contract_version_id = bp.re_contract_id
   and d.document_id             = cv.re_contract_version_id
   and mc.re_main_contract_id    = cv.re_main_contract_id
   and f.fund_id                 = b.fund_id
   and rbp.premium_type_id       = reb.premium_type_id
   and c1.contact_id             = mc.reinsurer_id
   and pt.id                     = p.payment_term_id
   and p.policy_id               = pi.policy_id
   and cpr.brief                 = 'Страхователь'
   and cpr.id                    = pi.contact_policy_role_id
   and pi.contact_id             = pic.contact_id
   and pic.contact_type_id       = ct.id
   and ph.sales_channel_id       = sc.id
   and pvl.lob_id                = tl.t_lob_id
   and p.policy_id               = ar.p_policy_id
   and s.t_profession_id         = tp.id (+)
   and p.t_pol_change_type_id    = pct.t_policy_change_type_id (+)
   and bl.re_bordero_line_id     = rc.re_bordero_line_id
   and rc.re_cover_id            = reb.re_cover_id
   and rc.re_bordero_id          = b.re_bordero_id
   and p.paymentoff_term_id      = pof.id (+)
   and cv.re_insurance_type_id   = ret.reinsurance_type_id
   and cv.re_contract_version_id = ar.re_contract_version_id
   and p.waiting_period_id       = wpe.id;
