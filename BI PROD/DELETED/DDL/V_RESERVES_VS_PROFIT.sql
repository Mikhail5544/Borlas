create or replace view ins_dwh.v_reserves_vs_profit as
select
      "Current Policy ID"
      ,"POL_HEADER_ID"
      ,"ID"
      ,"Cover ID"
      ,"Policy number"
      ,"Policy_version"
      ,"Risk name progr"
      ,"Risk name (Borlas)"
      ,"Policy Type ID"
      ,"Accrual_Period_name"
      ,"Accrstatus"
      ,"Sex(Insurer)"
      ,"Sex(Policyholder)"
      ,Case
                When "Date orig" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date orig"
       End
       as "Date orig"
      ,Case
                When "END_DATE_RISK" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "END_DATE_RISK"
       End as "END_DATE_RISK"
      ,Case
                When "Date from 1" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date from 1"
       End as "Date from 1"
      ,Case
                When "Date to" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date to"
       End as "Date to"       
      ,"Cover value"
      ,"Cover premium"
      ,"Pay period name"
      ,"Med ep coef"
      ,"Med em coef"
      ,"Ep non med"
      ,"Em non med"
      ,"I sport coef"
      ,"I prof coef"
      ,"Re med ep coef"
      ,"Re med em coef"
      ,"Re ep non med"
      ,"Re em non med"
      ,"Re sport coef"
      ,"Re prof coef"
      ,"Policy note"
      ,Case
                When "Date of birth(Insurer)" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date of birth(Insurer)"
       End as "Date of birth(Insurer)" 
      ,Case
                When "Date of birth(Policyholder)" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date of birth(Policyholder)"
       End as "Date of birth(Policyholder)"       
      ,Case
                When "Date of death(Insurer)" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date of death(Insurer)"
       End as "Date of death(Insurer)"        
      
      ,"Insurer id"
      ,"Currency"
      ,"Insurance period"
      ,"Mort discount"
      ,"Ii rate"
      ,"Date Cancel"
      ,"Policy holder"
      ,"Corporate policy type"
      ,"FOR_RE"
      ,"Reinsured"
      
      ,Case
                When "Date orig (Borlas)" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date orig (Borlas)"
       End as "Date orig (Borlas)"       
      ,"Year com"
      ,"Charge Premium"
      ,"Risk type gaap"
      ,"Loading"
      ,"Ii rate benefit"
      ,"Benefit period name"
      ,"Date start benefit"
      ,"Date benefit end"
      ,"Benefit period"
      ,"Date guaranteed end"
      ,"Guaranteed period"
      ,"Date end premium"
      ,"Premium period"
      ,"Acquisition total"      
      ,Case
                When "Inst start" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Inst start"
       End as "Inst start"       
      ,Case
                When "Inst end" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Inst end"
       End as "Inst end"       
      ,"Commission"
      ,"actuar_age"
      ,"p_cover_id"
      ,"p_policy_id"
      ,"p_pol_header_id"
      ,"risk_ext_id"
      ,"policy_ext_ID"
      ,"Policy insurer"
      ,"Pay period coef"
      ,"bank product"
      ,"product name"
      ,"SALES_CH"
      ,Case
                When "Date from" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Date from"
       End as "Date from"        
      ,"Status"
      ,"Death Table"
      ,"Commission for UPR"
      ,"Commission for MSFO"
      ,"Acquisition"
      ,"Sex (Child)"
      ,"Date of birth (Child)"
      ,"K coef m (child)"
      ,"S coef m (child)"
      ,"K coef nm (child)"
      ,"S coef nm (child)"
      ,"Sport coef (child)"
      ,"Prof coef (child)"
      ,"K coef m re (child)"
      ,"S coef m re (child)"
      ,"K coef nm re (child)"
      ,"S coef nm re (child)"
      ,"Sport coef re (child)"
      ,"Prof coef re (child)"
      ,"Change"
      ,"Years before change"
      ,"Premium before change"
      ,"Pay period name before change"
      ,"Stop Date"
      ,"Renewal Date"
      ,"IS_AVTOPROLONGATION"
      ,"PAYMENT_PERIOD"
      ,"IDS"
      ,Case
                When "DATE_LAST_VERSION" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "DATE_LAST_VERSION"
       End as "DATE_LAST_VERSION"
      ,"TYPE_INSURANCE"
      ,"SUR"
      ,"BRIEF"
      ,"IS_GROUP_FLAG"
      ,"Номер ДС"
      ,"Заявление"
      ,"АД"
      ,"ID_АД"
      ,"Id Дс"
      ,"Валюта"
      ,"Страхователь"
      ,"Тип страхователя"
      ,"Кол-во застрахованных по ДС"
      ,"Статус посл версии"
      ,"DECLINE_REASON"
      ,"Дата расторжения"
      ,"Регион"
      ,"Агентство"
      ,"Рассрочка по Акт версии"
      ,"NUMBER_OF_PAYMENTS"
      ,"Год действия"
      ,Case
                When "Дата начала ДС" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Дата начала ДС"
       End as "Дата начала ДС" 
      ,Case
                When "Дата окончания ДС" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Дата окончания ДС"
       End as "Дата окончания ДС"        
      ,"Продукт"
      ,"Страховая сумма по акт версии"
      ,"ID Риска"
      ,"Программа"
      ,"FIST_TO_PAY_DATE"
      ,"IS_MANDATORY"
      ,Case
                When "PROGRAM_START" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "PROGRAM_START"
       End as "PROGRAM_START"        
      ,Case
                When "PROGRAM_END" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "PROGRAM_END"
       End as "PROGRAM_END" 
      ,"VERSION_NUM"
      ,"VERSION_ORDER_NUM"
      ,Case
                When "Минимальная дата неоплаты" between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then "Минимальная дата неоплаты"
       End as "Минимальная дата неоплаты"    
      ,"ФЛ (страхователя)"
      ,"IS_ADM_COST"


from(
    select pp.policy_id                               as "Current Policy ID",
           pp.pol_header_id                           as pol_header_id,
           pc.product_line_id                         as id,
           pc.p_cover_id                              as "Cover ID",
           nvl2(pp.pol_ser, pp.pol_ser || '-' || pp.pol_num, pp.pol_num) as  "Policy number",
           '(Текущая версия)'                         as "Policy_version",
           pc.ll_description                          as "Risk name progr",
           pc.plo_description                         as "Risk name (Borlas)",
           pc.ig_life_property "Policy Type ID",
           case
             when pc.ig_life_property = 'L' then
               case tpt.description
                 when 'Раз в полгода' then 2
                 when 'Единовременно' then 0
                 when 'Ежеквартально' then 4
                 when 'Ежемесячно' then 12
                 when 'Ежегодно' then 1
                 else 99
               end
             when pc.ig_life_property = 'C'
               and tpt.description = 'Единовременно' then 0
             else 1
           end as "Accrual_Period_name",
           case
             when
               case
                 when pc.ig_life_property = 'L' then
                   case tpt.description
                     when 'Раз в полгода' then 2
                     when 'Единовременно' then 0
                     when 'Ежеквартально' then 4
                     when 'Ежемесячно' then 12
                     when 'Ежегодно' then 1
                     else 99
                   end
                 when pc.ig_life_property = 'C'
                   and tpt.description = 'Единовременно' then 0
                 else 1
               end = 0
               and trunc(ph.start_date,'yyyy') != trunc(pkg_reserves_vs_profit.get_report_date,'yyyy')
             then 'should NOT be accrual'
             when
               case
                 when pc.ig_life_property = 'L' then
                   case tpt.description
                     when 'Раз в полгода' then 2
                     when 'Единовременно' then 0
                     when 'Ежеквартально' then 4
                     when 'Ежемесячно' then 12
                     when 'Ежегодно' then 1
                     else 99
                   end
                 when pc.ig_life_property = 'C'
                   and tpt.description = 'Единовременно' then 0
                 else 1
               end = 1
               and extract (month from ph.start_date) >= 7
               and trunc(ph.start_date,'yyyy') != trunc(pkg_reserves_vs_profit.get_report_date,'yyyy')
             then 'should NOT be accrual'
             else 'should be accrual'
           end       as "Accrstatus",
           case pc.ll_brief when 'PWOP' then
           decode(pp.gender, 0, 1, 1, 0)
           else
              decode(pc.cn_pol_insurer_gender, 0, 1, 1, 0)
           end
               "Sex(Insurer)",
           decode(pp.gender, 0, 1, 1, 0) "Sex(Policyholder)",
           trunc(pc.start_date,'dd') as "Date orig", --217453: Доработать выгрузки "На закрытие"           
           trunc(pc.end_date,'dd')   as end_date_risk, --217453: Доработать выгрузки "На закрытие"           
           
           trunc(case when decode(pc.is_avtoprolongation,1,'Да',0,'Нет','Нет') = 'Да'
                then (case when pc.ig_life_property = 'C'
                           then (case when mod(trunc(months_between(pp.end_date + 1, ph.start_date), 0) / 12,1) = 0
                                      then (case when extract(year from pc.end_date) - extract(year from pc.start_date) > 1
                                                 then (case extract(year from ph.start_date) when 2005
                                                                                             then ph.start_date + 364 + 364 + 365
                                                                                             when 2006
                                                                                             then ph.start_date + 364 + 365
                                                                                             when 2007
                                                                                             then ph.start_date + 365
                                                                                             when 2008
                                                                                             then ph.start_date
                                                                                             else pc.end_date - 364 end)

                                                 else pc.start_date end)
                                      else pc.start_date end)
                           else pc.start_date end)
               else pc.start_date
               end,'dd') "Date from 1",
           trunc(case when decode(pc.is_avtoprolongation,1,'Да',0,'Нет','Нет') = 'Да'
                then (case when pc.ig_life_property = 'C'
                           then (case when mod(trunc(months_between(pp.end_date + 1, ph.start_date), 0) / 12,1) = 0
                                      then (case when extract(year from pc.end_date) - extract(year from pc.start_date) > 1
                                                 then (case extract(year from ph.start_date) when 2005
                                                                                             then ph.start_date + 364 + 364 + 364 + 365
                                                                                             when 2006
                                                                                             then ph.start_date + 364 + 364 + 365
                                                                                             when 2007
                                                                                             then ph.start_date + 364 + 365
                                                                                             when 2008
                                                                                             then ph.start_date + 365
                                                                                             else pc.end_date end)
                                                  else pc.end_date end)
                                      else pc.end_date end)
                           else pc.end_date end)
               else pc.end_date
               end,'dd') "Date to",
           case when dch.ext_id is null then
             (case when pc.ll_description in ('Доп. программа №4 Защита страховых взносов','Доп. программа №3 Освобождение от уплаты дальнейших взносов','Доп. программа № 4 Защита страховых взносов','Доп. программа № 3 Освобождение от уплаты дальнейших взносов') then
                  (case tpt.description when 'Ежегодно' then pc.ins_amount
                                        when 'Раз в полгода' then pc.ins_amount / 2
                                        when 'Ежеквартально' then pc.ins_amount / 4
                                        when 'Ежемесячно' then pc.ins_amount / 12
                                        else pc.ins_amount end)
              else pc.ins_amount end)
           else pc.ins_amount end as "Cover value",
           pc.fee "Cover premium",
           case tpt.description when 'Раз в полгода' then 2
                                when 'Единовременно' then 0
                                when 'Ежеквартально' then 4
                                when 'Ежемесячно' then 12
                                when 'Ежегодно' then 1
                                else 99 end "Pay period name"
           ,pc.k_coef_m   as "Med ep coef"
           ,pc.s_coef_nm  as "Med em coef"
           ,pc.k_coef_nm  as "Ep non med"
           ,pc.s_coef_nm  as "Em non med"
          ,nvl(pca.sport_coef,1) "I sport coef",
           nvl(pca.prof_coef,1) "I prof coef",
           nvl(pca.k_coef_m_re,0) "Re med ep coef",
           nvl(pca.s_coef_m_re,0) "Re med em coef",
           nvl(pca.k_coef_nm_re,0) "Re ep non med",
           nvl(pca.s_coef_nm_re,0) "Re em non med",
           1 "Re sport coef",
           1 "Re prof coef",
           nvl(pc.is_avtoprolongation,0) "Policy note",
           trunc(case pc.ll_brief when 'PWOP' then
             pp.date_of_birth
           else
             pc.cn_pol_insurer_date_of_birth
           end,'dd') "Date of birth(Insurer)",
           trunc(pp.date_of_birth,'dd') "Date of birth(Policyholder)",
           trunc(
           case pc.ll_brief when 'PWOP' then
             pp.date_of_death
           else
             pc.cn_pol_insurer_date_of_death
           end,'dd') "Date of death(Insurer)",
          case pc.ll_brief when 'PWOP' then
            pp.contact_id
          else
            pc.cn_pol_insurer_contact_id
            end "Insurer id",

           case f.brief when 'RUR' then 1
                        when 'USD' then 2
                        when 'EUR' then 3
                        else 0 end "Currency",
           case pc.plo_description when 'Первичное диагностирование смертельно опасного заболевания'
                                then trunc(months_between(pc.end_date + 1, ph.start_date), 0) / 12
                                else trunc(months_between(pp.end_date + 1, ph.start_date), 0) / 12 end
           "Insurance period"
          ,pca.mort_discount "Mort discount"
          ,pc.normrate_value            "Ii rate"
          ,trunc(pc.decline_date,'dd') "Date Cancel"
          ,pp.obj_name "Policy holder"
          ,pp.is_group_flag "Corporate policy type"
          ,pc.for_re
          ,nvl(pca.reinsurer,pc.reinsured) "Reinsured"
          ,trunc(ph.start_date,'dd') "Date orig (Borlas)"
          ,0 "Year com"
          ,pc.charge_premium as "Charge Premium"
          ,case
             when months_between(pp.end_date + 1, ph.start_date) > 12 then
              case
                 when gt.life_property = 1 then
                    'long_life'
                  else 'long_ns'
               end
             else
               case
                 when gt.life_property = 1 then
                 'short_life'
                 else 'short_ns'
               end
            end as "Risk type gaap",
           pc.rvb_value            "Loading",
           0 "Ii rate benefit",
           0 "Benefit period name",
           0 "Date start benefit",
           0 "Date benefit end"
          ,0 "Benefit period"
          ,0 "Date guaranteed end"
          ,0 "Guaranteed period"
          ,0 "Date end premium"
          ,0 "Premium period"
          ,0 "Acquisition total"
          ,trunc(case tpt.is_periodical
             when 1 then ins.get_start_date_pmnt_period(pc.start_date,decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0,trunc(months_between(ins_dwh.pkg_reserves_vs_profit.get_report_date, pc.start_date)/decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0))
             when 0 then pc.start_date
           end,'dd')      "Inst start",
           trunc(case tpt.is_periodical
             when 1 then ins.get_start_date_pmnt_period(pc.start_date,decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0,(trunc(months_between(ins_dwh.pkg_reserves_vs_profit.get_report_date, pc.start_date)/decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0)+1)) - 1
             when 0 then pc.end_date
           end,'dd')           "Inst end",
           0  "Commission",
           pc.insured_age "actuar_age",
           pc.p_cover_id "p_cover_id",
           pp.policy_id "p_policy_id",
           ph.policy_header_id "p_pol_header_id",
           pc.ext_id  "risk_ext_id",
           ph.ext_id  "policy_ext_ID",
            case pc.ll_brief when 'PWOP' then
               pp.obj_name
             else
              pc.cn_pol_insurer_obj_name
            end                   as "Policy insurer"
           ,pay_coef.pcc_val      as "Pay period coef"
           ,ph.description/*cr_prod.description*/   as "bank product"
           ,ph.description      as "product name"
           ,tch.description       as sales_ch
           ,pc.start_date         as "Date from"
           ,pp.pol_status_on_date "Status" --дата изменений в договорах
           ,dpl.name "Death Table"
           ,0 "Commission for UPR"
           ,0 "Commission for MSFO"
           ,0 "Acquisition"
           ,pc.sex_child as "Sex (Child)"
           ,trunc(pc.date_birth_child,'dd') as "Date of birth (Child)"
           ,pc.pwop_0 "K coef m (child)"
           ,pc.pwop_0 "S coef m (child)"
           ,pc.pwop_0 "K coef nm (child)"
           ,pc.pwop_0 "S coef nm (child)"
           ,pc.pwop_1 "Sport coef (child)"
           ,pc.pwop_1 "Prof coef (child)"
           ,pc.pwop_0 "K coef m re (child)"
           ,pc.pwop_0 "S coef m re (child)"
           ,pc.pwop_0 "K coef nm re (child)"
           ,pc.pwop_0 "S coef nm re (child)"
           ,pc.pwop_1 "Sport coef re (child)"
           ,pc.pwop_1 "Prof coef re (child)"
           ,/*null*/'-' "Change"
           ,/*null*/'-' "Years before change"
           ,/*null*/'-' "Premium before change"
           ,/*null*/'-' "Pay period name before change"
           ,0                      as "Stop Date"
           ,0                      as "Renewal Date"
           ,pc.is_avtoprolongation
           ,pp.fee_payment_term    as Payment_period
           ,ph.ids                 as IDS
           ,trunc(poli.status_start_date,'dd') as date_last_version
           ,pc.type_insurance
            ,(select pcsd.value
               from ins.policy_cash_surr   pcs,
                    ins.policy_cash_surr_d pcsd
              where pcs.policy_id           = pp.policy_id
                and pcs.policy_cash_surr_id = pcsd.policy_cash_surr_id
                and ins_dwh.pkg_reserves_vs_profit.get_cash_sur_date between pcsd.start_cash_surr_date and pcsd.end_cash_surr_date
                and pcs.t_lob_line_id       = pc.ll_t_lob_line_id
                and rownum = 1
            ) as sur
           ,pc.sh_brief as brief
           ,pp.is_group_flag
    /*------------------------------------------------------------Журнал ДС------------------------------*/
           ,pp.pol_num    as "Номер ДС"
           ,pp.notice_num as "Заявление"
           ,(select ach.num || ' от ' || to_char(ach.date_begin, 'dd.mm.yyyy')|| ', ' || c.name
               from ins.ven_ag_contract_header ach
                   ,ins.contact c
              where ach.ag_contract_header_id = ph.current_agent_id
                and ach.agent_id=c.contact_id
            )                           as "АД"
           ,ph.current_agent_id         as "ID_АД"
           ,ph.policy_header_id         as "Id Дс",
    --        ph.ids,
            f.brief                     as "Валюта",
            pp.obj_name_orig as "Страхователь",
            case pp.tct_brief
              when 'ФЛ' then 'ФЛ'
              else 'Юрлицо'
            end                      as "Тип страхователя",
            ph.ass_count             as "Кол-во застрахованных по ДС",
            poli.status_name         as "Статус посл версии",
            poli.decline_reason_name as decline_reason,
            trunc(poli.decline_date,'dd')        as "Дата расторжения"
           ,nvl(ph.region_name
               ,(select province_name
                   from ins.t_province
                  where province_id = pp.region_id)
               ) as "Регион"
           ,'Убрано' as "Агентство"
           ,case pc.plo_description
              when 'Административные издержки' then
                'Ежегодно'
              else tpt.description
            end "Рассрочка по Акт версии",
           tpt.number_of_payments,
           CASE
             WHEN tpt.is_periodical = 0 THEN 1
             WHEN tpt.ID IN (162, 165,166) THEN
               MONTHS_BETWEEN(ins_dwh.pkg_reserves_vs_profit.get_report_date,ph.START_DATE)/12
             ELSE
               ceil(MONTHS_BETWEEN(ins_dwh.pkg_reserves_vs_profit.get_report_date,ph.START_DATE)/12)
           END as "Год действия", --par_date - Дата конца периода
           trunc(ph.start_date,'dd') as "Дата начала ДС",
           TRUNC(pp.end_date,'dd')   as "Дата окончания ДС",
           ph.DESCRIPTION            as "Продукт"
          ,pc.program_sum            as "Страховая сумма по акт версии",
           pc.plo_id "ID Риска"
          ,pc.plo_description "Программа"
          ,trunc(fp.fist_to_pay_date,'dd') as fist_to_pay_date
          ,pc.is_mandatory
          ,trunc(pc.program_start,'dd') as program_start
          ,trunc(pc.program_end,'dd') as program_end
          ,pp.version_num
          ,pp.version_order_num
          --
          ,pph.min_to_pay_date as "Минимальная дата неоплаты"
          ,ct.is_invididual as "ФЛ (страхователя)"
          ,pc.is_adm_cost
    --------------------------------------------------- FROM -----------------------------------------
      from ins_dwh.reserves_vs_profit_pol     pp
          ,ins_dwh.reserves_vs_profit_pheader ph
          ,ins_dwh.dm_p_pol_header            pph
          ,ins_dwh.dm_contact                 ct
          ,ins_dwh.reserves_vs_profit_fpays   fp
          ,ins_dwh.reserves_vs_profit_lstpol  poli
          ,ins.t_prod_line_rate      rpl
          ,ins.deathrate             dpl
          ,ins.document              dch
          ,ins.t_sales_channel       tch
          ,ins.t_payment_terms       tpt
          ,ins.fund                  f
          ,ins.gaap_pl_types         gt
          ,ins.p_cover_add_param     pca
          ,(select pcc.p_cover_id as pcc_p_cover_id
                  ,pcc.val        as pcc_val
              from ins.p_cover_coef pcc
                  ,ins.t_prod_coef_type pct
             where pcc.t_prod_coef_type_id = pct.t_prod_coef_type_id
               and pct.brief in ('Коэффициент рассрочки платежа', 'Coeff_payment_loss')
           ) pay_coef/*,
           (select prod1.description
                  ,prod1.product_id
              from ins.t_product prod1
             where prod1.brief like '%CR%'
           ) cr_prod*/
          ,ins_dwh.reserves_vs_profit_pcover pc
    where ph.policy_header_id              = dch.document_id
      and ph.sales_channel_id              = tch.id
      and pc.p_policy_id                   = pp.policy_id
      and poli.pol_header_id               = ph.policy_header_id
      and ph.policy_header_id              = pp.pol_header_id
      and pp.payment_term_id               = tpt.id
      and pay_coef.pcc_p_cover_id (+)      = pc.p_cover_id
      and f.fund_id                        = ph.fund_id
      --and ph.product_id                    = cr_prod.product_id  (+)
      and gt.id (+)                        = pc.product_line_id
      and pca.p_cover_id (+)               = pc.p_cover_id
      and ph.policy_header_id              = pph.policy_header_id
      and pp.contact_id                    = ct.contact_id
      and pc.product_line_id               = rpl.product_line_id (+)
      and rpl.deathrate_id                 = dpl.deathrate_id    (+)
      and ph.policy_header_id              = fp.policy_header_id (+)
);
