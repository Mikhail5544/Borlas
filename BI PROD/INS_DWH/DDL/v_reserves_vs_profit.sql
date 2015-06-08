CREATE OR REPLACE VIEW INS_DWH.V_RESERVES_VS_PROFIT AS
SELECT "Current Policy ID"
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
       ,CASE
         WHEN "Date orig" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date orig"
       END AS "Date orig"
       ,CASE
         WHEN "END_DATE_RISK" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "END_DATE_RISK"
       END AS "END_DATE_RISK"
       ,CASE
         WHEN "Date from 1" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date from 1"
       END AS "Date from 1"
       ,CASE
         WHEN "Date to" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date to"
       END AS "Date to"
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
       ,CASE
         WHEN "Date of birth(Insurer)" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date of birth(Insurer)"
       END AS "Date of birth(Insurer)"
       ,CASE
         WHEN "Date of birth(Policyholder)" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date of birth(Policyholder)"
       END AS "Date of birth(Policyholder)"
       ,CASE
         WHEN "Date of death(Insurer)" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date of death(Insurer)"
       END AS "Date of death(Insurer)"
       
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
       
       ,CASE
         WHEN "Date orig (Borlas)" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date orig (Borlas)"
       END AS "Date orig (Borlas)"
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
       ,CASE
         WHEN "Inst start" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Inst start"
       END AS "Inst start"
       ,CASE
         WHEN "Inst end" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Inst end"
       END AS "Inst end"
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
       ,CASE
         WHEN "Date from" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Date from"
       END AS "Date from"
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
       ,CASE
         WHEN "DATE_LAST_VERSION" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "DATE_LAST_VERSION"
       END AS "DATE_LAST_VERSION"
       ,"TYPE_INSURANCE"
       ,"SUR"
       ,"BRIEF"
       ,"IS_GROUP_FLAG"
       ,"Номер ДС"
       ,"Заявление"
       ,current_agent_agreement
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
       ,CASE
         WHEN "Дата начала ДС" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Дата начала ДС"
       END AS "Дата начала ДС"
       ,CASE
         WHEN "Дата окончания ДС" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Дата окончания ДС"
       END AS "Дата окончания ДС"
       ,"Продукт"
       ,"Страховая сумма по акт версии"
       ,"ID Риска"
       ,"Программа"
       ,"FIST_TO_PAY_DATE"
       ,"IS_MANDATORY"
       ,CASE
         WHEN "PROGRAM_START" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "PROGRAM_START"
       END AS "PROGRAM_START"
       ,CASE
         WHEN "PROGRAM_END" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "PROGRAM_END"
       END AS "PROGRAM_END"
       ,"VERSION_NUM"
       ,"VERSION_ORDER_NUM"
       ,CASE
         WHEN "Минимальная дата неоплаты" BETWEEN to_date('01.01.1900', 'dd.mm.yyyy') AND
              to_date('31.12.2099', 'dd.mm.yyyy') THEN
          "Минимальная дата неоплаты"
       END AS "Минимальная дата неоплаты"
       ,"ФЛ (страхователя)"
       ,"IS_ADM_COST"
       ,version_risk_incl
       ,parent_cover_rsbu_id
       ,parent_cover_ifrs_id
       ,"Ep non med sys"
       ,is_assured_resident
       ,is_insurer_resident
       ,product_group_brief
       ,product_group_name AS product_group
       ,sc_gr AS sales_chn_group
       ,min_nonpay_per
       ,pol_privilege_period_name
       ,work_group_id
       ,decline_type_name --337234/Чирков/
       ,current_agent_name
       ,(SELECT num FROM ins.document d WHERE d.document_id = first_pol_agent) AS "agent_agreement_id"
       ,(SELECT c.obj_name_orig
          FROM ins.contact            c
              ,ins.ag_contract_header ah
         WHERE ah.ag_contract_header_id = first_pol_agent
           AND c.contact_id = ah.agent_id) AS "agent_agreement_number"
       ,max_epg_due_date
       ,date_act_rast
--------------------------------------------------- FROM -----------------------------------------
  FROM (SELECT pp.policy_id AS "Current Policy ID"
               ,pp.pol_header_id AS pol_header_id
               ,pc.product_line_id AS id
               ,pc.p_cover_id AS "Cover ID"
               ,nvl2(pp.pol_ser, pp.pol_ser || '-' || pp.pol_num, pp.pol_num) AS "Policy number"
               ,'(Текущая версия)' AS "Policy_version"
               ,pc.ll_description AS "Risk name progr"
               ,pc.plo_description AS "Risk name (Borlas)"
               ,pc.ig_life_property "Policy Type ID"
               ,CASE
                 WHEN pc.ig_life_property = 'L' THEN
                  CASE tpt.description
                    WHEN 'Раз в полгода' THEN
                     2
                    WHEN 'Единовременно' THEN
                     0
                    WHEN 'Ежеквартально' THEN
                     4
                    WHEN 'Ежемесячно' THEN
                     12
                    WHEN 'Ежегодно' THEN
                     1
                    ELSE
                     99
                  END
                 WHEN pc.ig_life_property = 'C'
                      AND tpt.description = 'Единовременно' THEN
                  0
                 ELSE
                  1
               END AS "Accrual_Period_name"
               ,CASE
                 WHEN CASE
                        WHEN pc.ig_life_property = 'L' THEN
                         CASE tpt.description
                           WHEN 'Раз в полгода' THEN
                            2
                           WHEN 'Единовременно' THEN
                            0
                           WHEN 'Ежеквартально' THEN
                            4
                           WHEN 'Ежемесячно' THEN
                            12
                           WHEN 'Ежегодно' THEN
                            1
                           ELSE
                            99
                         END
                        WHEN pc.ig_life_property = 'C'
                             AND tpt.description = 'Единовременно' THEN
                         0
                        ELSE
                         1
                      END = 0
                      AND trunc(ph.start_date, 'yyyy') !=
                      trunc(ins_dwh.pkg_reserves_vs_profit.get_report_date, 'yyyy') THEN
                  'should NOT be accrual'
                 WHEN CASE
                        WHEN pc.ig_life_property = 'L' THEN
                         CASE tpt.description
                           WHEN 'Раз в полгода' THEN
                            2
                           WHEN 'Единовременно' THEN
                            0
                           WHEN 'Ежеквартально' THEN
                            4
                           WHEN 'Ежемесячно' THEN
                            12
                           WHEN 'Ежегодно' THEN
                            1
                           ELSE
                            99
                         END
                        WHEN pc.ig_life_property = 'C'
                             AND tpt.description = 'Единовременно' THEN
                         0
                        ELSE
                         1
                      END = 1
                      AND extract(MONTH FROM ph.start_date) >= 7
                      AND trunc(ph.start_date, 'yyyy') !=
                      trunc(ins_dwh.pkg_reserves_vs_profit.get_report_date, 'yyyy') THEN
                  'should NOT be accrual'
                 ELSE
                  'should be accrual'
               END AS "Accrstatus"
               ,CASE pc.ll_brief
                 WHEN 'PWOP' THEN
                  decode(pp.gender, 0, 1, 1, 0)
                 ELSE
                  decode(pc.cn_pol_insurer_gender, 0, 1, 1, 0)
               END "Sex(Insurer)"
               ,decode(pp.gender, 0, 1, 1, 0) "Sex(Policyholder)"
               ,trunc(pc.start_date, 'dd') AS "Date orig"
               , --217453: Доработать выгрузки "На закрытие"
               trunc(pc.end_date, 'dd') AS end_date_risk
               , --217453: Доработать выгрузки "На закрытие"
               
               trunc(CASE
                       WHEN decode(pc.is_avtoprolongation, 1, 'Да', 0, 'Нет', 'Нет') = 'Да' THEN
                        (CASE
                          WHEN pc.ig_life_property = 'C' THEN
                           (CASE
                             WHEN MOD(trunc(MONTHS_BETWEEN(pp.end_date + 1, ph.start_date), 0) / 12, 1) = 0 THEN
                              (CASE
                                WHEN extract(YEAR FROM pc.end_date) - extract(YEAR FROM pc.start_date) > 1 THEN
                                 (CASE extract(YEAR FROM ph.start_date)
                                   WHEN 2005 THEN
                                    ph.start_date + 364 + 364 + 365
                                   WHEN 2006 THEN
                                    ph.start_date + 364 + 365
                                   WHEN 2007 THEN
                                    ph.start_date + 365
                                   WHEN 2008 THEN
                                    ph.start_date
                                   ELSE
                                    pc.end_date - 364
                                 END)
                              
                                ELSE
                                 pc.start_date
                              END)
                             ELSE
                              pc.start_date
                           END)
                          ELSE
                           pc.start_date
                        END)
                       ELSE
                        pc.start_date
                     END
                    ,'dd') "Date from 1"
               ,trunc(CASE
                       WHEN decode(pc.is_avtoprolongation, 1, 'Да', 0, 'Нет', 'Нет') = 'Да' THEN
                        (CASE
                          WHEN pc.ig_life_property = 'C' THEN
                           (CASE
                             WHEN MOD(trunc(MONTHS_BETWEEN(pp.end_date + 1, ph.start_date), 0) / 12, 1) = 0 THEN
                              (CASE
                                WHEN extract(YEAR FROM pc.end_date) - extract(YEAR FROM pc.start_date) > 1 THEN
                                 (CASE extract(YEAR FROM ph.start_date)
                                   WHEN 2005 THEN
                                    ph.start_date + 364 + 364 + 364 + 365
                                   WHEN 2006 THEN
                                    ph.start_date + 364 + 364 + 365
                                   WHEN 2007 THEN
                                    ph.start_date + 364 + 365
                                   WHEN 2008 THEN
                                    ph.start_date + 365
                                   ELSE
                                    pc.end_date
                                 END)
                                ELSE
                                 pc.end_date
                              END)
                             ELSE
                              pc.end_date
                           END)
                          ELSE
                           pc.end_date
                        END)
                       ELSE
                        pc.end_date
                     END
                    ,'dd') "Date to"
               ,CASE
                 WHEN dch.ext_id IS NULL THEN
                  (CASE
                    WHEN pc.ll_description IN
                         ('Доп. программа №4 Защита страховых взносов'
                         ,'Доп. программа №3 Освобождение от уплаты дальнейших взносов'
                         ,'Доп. программа № 4 Защита страховых взносов'
                         ,'Доп. программа № 3 Освобождение от уплаты дальнейших взносов') THEN
                     (CASE tpt.description
                       WHEN 'Ежегодно' THEN
                        pc.ins_amount
                       WHEN 'Раз в полгода' THEN
                        pc.ins_amount / 2
                       WHEN 'Ежеквартально' THEN
                        pc.ins_amount / 4
                       WHEN 'Ежемесячно' THEN
                        pc.ins_amount / 12
                       ELSE
                        pc.ins_amount
                     END)
                    ELSE
                     pc.ins_amount
                  END)
                 ELSE
                  pc.ins_amount
               END AS "Cover value"
               ,pc.fee "Cover premium"
               ,CASE tpt.description
                 WHEN 'Раз в полгода' THEN
                  2
                 WHEN 'Единовременно' THEN
                  0
                 WHEN 'Ежеквартально' THEN
                  4
                 WHEN 'Ежемесячно' THEN
                  12
                 WHEN 'Ежегодно' THEN
                  1
                 ELSE
                  99
               END "Pay period name"
               ,pc.k_coef_m AS "Med ep coef"
               ,pc.s_coef_nm AS "Med em coef"
               ,pc.k_coef_nm AS "Ep non med sys"
               ,nvl(pc.k_coef_nm, 0) + nvl(pc.ep_non_med_order, 0) - 100 AS "Ep non med"
               ,pc.s_coef_nm AS "Em non med"
               ,nvl(pca.sport_coef, 1) "I sport coef"
               ,nvl(pca.prof_coef, 1) "I prof coef"
               ,nvl(pca.k_coef_m_re, 0) "Re med ep coef"
               ,nvl(pca.s_coef_m_re, 0) "Re med em coef"
               ,nvl(pca.k_coef_nm_re, 0) "Re ep non med"
               ,nvl(pca.s_coef_nm_re, 0) "Re em non med"
               ,1 "Re sport coef"
               ,1 "Re prof coef"
               ,nvl(pc.is_avtoprolongation, 0) "Policy note"
               ,trunc(CASE pc.ll_brief
                       WHEN 'PWOP' THEN
                        pp.date_of_birth
                       ELSE
                        pc.cn_pol_insurer_date_of_birth
                     END
                    ,'dd') "Date of birth(Insurer)"
               ,trunc(pp.date_of_birth, 'dd') "Date of birth(Policyholder)"
               ,trunc(CASE pc.ll_brief
                       WHEN 'PWOP' THEN
                        pp.date_of_death
                       ELSE
                        pc.cn_pol_insurer_date_of_death
                     END
                    ,'dd') "Date of death(Insurer)"
               ,CASE pc.ll_brief
                 WHEN 'PWOP' THEN
                  pp.contact_id
                 ELSE
                  pc.cn_pol_insurer_contact_id
               END "Insurer id"
               ,
               
               CASE f.brief
                 WHEN 'RUR' THEN
                  1
                 WHEN 'USD' THEN
                  2
                 WHEN 'EUR' THEN
                  3
                 ELSE
                  0
               END "Currency"
               ,CASE pc.plo_description
                 WHEN 'Первичное диагностирование смертельно опасного заболевания' THEN
                  trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date), 0) / 12
                 ELSE
                  trunc(MONTHS_BETWEEN(pp.end_date + 1, ph.start_date), 0) / 12
               END "Insurance period"
               ,pca.mort_discount "Mort discount"
               ,pc.normrate_value "Ii rate"
               ,trunc(pc.decline_date, 'dd') "Date Cancel"
               ,pp.obj_name "Policy holder"
               ,pp.is_group_flag "Corporate policy type"
               ,pc.for_re
               ,nvl(pca.reinsurer, pc.reinsured) "Reinsured"
               ,trunc(ph.start_date, 'dd') "Date orig (Borlas)"
               ,0 "Year com"
               ,pc.charge_premium AS "Charge Premium"
               ,CASE
                 WHEN MONTHS_BETWEEN(pp.end_date + 1, ph.start_date) > 12 THEN
                  CASE
                    WHEN gt.life_property = 1 THEN
                     'long_life'
                    ELSE
                     'long_ns'
                  END
                 ELSE
                  CASE
                    WHEN gt.life_property = 1 THEN
                     'short_life'
                    ELSE
                     'short_ns'
                  END
               END AS "Risk type gaap"
               ,pc.rvb_value "Loading"
               ,0 "Ii rate benefit"
               ,0 "Benefit period name"
               ,0 "Date start benefit"
               ,0 "Date benefit end"
               ,0 "Benefit period"
               ,0 "Date guaranteed end"
               ,0 "Guaranteed period"
               ,0 "Date end premium"
               ,0 "Premium period"
               ,0 "Acquisition total"
               ,trunc(CASE tpt.is_periodical
                       WHEN 1 THEN
                        ins.get_start_date_pmnt_period(pc.start_date
                                                      ,decode(tpt.number_of_payments
                                                             ,1
                                                             ,12
                                                             ,2
                                                             ,6
                                                             ,4
                                                             ,3
                                                             ,12
                                                             ,1
                                                             ,12)
                                                      ,0
                                                      ,trunc(MONTHS_BETWEEN(ins_dwh.pkg_reserves_vs_profit.get_report_date
                                                                           ,pc.start_date) /
                                                             decode(tpt.number_of_payments
                                                                   ,1
                                                                   ,12
                                                                   ,2
                                                                   ,6
                                                                   ,4
                                                                   ,3
                                                                   ,12
                                                                   ,1
                                                                   ,12)
                                                            ,0))
                       WHEN 0 THEN
                        pc.start_date
                     END
                    ,'dd') "Inst start"
               ,trunc(CASE tpt.is_periodical
                       WHEN 1 THEN
                        ins.get_start_date_pmnt_period(pc.start_date
                                                      ,decode(tpt.number_of_payments
                                                             ,1
                                                             ,12
                                                             ,2
                                                             ,6
                                                             ,4
                                                             ,3
                                                             ,12
                                                             ,1
                                                             ,12)
                                                      ,0
                                                      ,(trunc(MONTHS_BETWEEN(ins_dwh.pkg_reserves_vs_profit.get_report_date
                                                                            ,pc.start_date) /
                                                              decode(tpt.number_of_payments
                                                                    ,1
                                                                    ,12
                                                                    ,2
                                                                    ,6
                                                                    ,4
                                                                    ,3
                                                                    ,12
                                                                    ,1
                                                                    ,12)
                                                             ,0) + 1)) - 1
                       WHEN 0 THEN
                        pc.end_date
                     END
                    ,'dd') "Inst end"
               ,0 "Commission"
               ,pc.insured_age "actuar_age"
               ,pc.p_cover_id "p_cover_id"
               ,pp.policy_id "p_policy_id"
               ,ph.policy_header_id "p_pol_header_id"
               ,pc.ext_id "risk_ext_id"
               ,ph.ext_id "policy_ext_ID"
               ,CASE pc.ll_brief
                 WHEN 'PWOP' THEN
                  pp.obj_name
                 ELSE
                  pc.cn_pol_insurer_obj_name
               END AS "Policy insurer"
               ,pay_coef.pcc_val AS "Pay period coef"
               ,ph.description /*cr_prod.description*/ AS "bank product"
               ,ph.description AS "product name"
               ,tch.description AS sales_ch
               ,pc.start_date AS "Date from"
               ,pp.pol_status_on_date "Status" --дата изменений в договорах
               ,dpl.name "Death Table"
               ,0 "Commission for UPR"
               ,0 "Commission for MSFO"
               ,0 "Acquisition"
               ,pc.sex_child AS "Sex (Child)"
               ,trunc(pc.date_birth_child, 'dd') AS "Date of birth (Child)"
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
               ,pc.parent_cover_rsbu_id
               ,pc.parent_cover_ifrs_id
               , /*null*/'-' "Change"
               , /*null*/'-' "Years before change"
               , /*null*/'-' "Premium before change"
               , /*null*/'-' "Pay period name before change"
               ,0 AS "Stop Date"
               ,0 AS "Renewal Date"
               ,pc.is_avtoprolongation
               ,pp.fee_payment_term AS payment_period
               ,ph.ids AS ids
               ,trunc(poli.status_start_date, 'dd') AS date_last_version
               ,pc.type_insurance
               ,(SELECT pcsd.value
                  FROM ins.policy_cash_surr   pcs
                      ,ins.policy_cash_surr_d pcsd
                 WHERE pcs.policy_id = pp.policy_id
                   AND pcs.policy_cash_surr_id = pcsd.policy_cash_surr_id
                   AND ins_dwh.pkg_reserves_vs_profit.get_cash_sur_date BETWEEN
                       pcsd.start_cash_surr_date AND pcsd.end_cash_surr_date
                   AND pcs.t_lob_line_id = pc.ll_t_lob_line_id
                   AND rownum = 1) AS sur
               ,pc.sh_brief AS brief
               ,pp.is_group_flag
               , --dph.min_nonpay_per
               (SELECT MIN(epg.grace_date)
                  FROM ins.p_policy       pp
                      ,ins.doc_doc        dd
                      ,ins.ven_ac_payment epg
                      ,ins.doc_templ      dt
                      ,ins.document       dc
                      ,ins.doc_status_ref dsr
                 WHERE pp.pol_header_id = dph.policy_header_id
                   AND dd.parent_id = pp.policy_id
                   AND dd.child_id = epg.payment_id
                   AND epg.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND epg.payment_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'TO_PAY'
                   AND (epg.amount - (SELECT nvl(SUM(dso.set_off_child_amount), 0)
                                        FROM ins.doc_set_off dso
                                       WHERE dso.parent_doc_id = epg.payment_id
                                         AND dso.cancel_date IS NULL)) >= 400) AS min_nonpay_per
               ,tpr.description AS pol_privilege_period_name
               /*------------------------------------------------------------Журнал ДС------------------------------*/
               ,pp.pol_num    AS "Номер ДС"
               ,pp.notice_num AS "Заявление"
               /*,(SELECT ach.num || ' от ' || to_char(ach.date_begin, 'dd.mm.yyyy') || ', ' || c.name
                FROM ins.ven_ag_contract_header ach
                    ,ins.contact                c
               WHERE ach.ag_contract_header_id = ph.current_agent_id
                 AND ach.agent_id = c.contact_id)*/ --352332  FW: добавление новых полей в журнал начислений
               ,ins.pkg_agn_control.get_current_policy_agent_num(ph.policy_header_id) AS current_agent_agreement
               ,ins.pkg_agn_control.get_current_policy_agent_name(ph.policy_header_id) AS current_agent_name
               ,ph.current_agent_id AS "ID_АД"
               ,ph.policy_header_id AS "Id Дс"
               ,
               --        ph.ids,
               f.brief AS "Валюта"
               ,pp.obj_name_orig AS "Страхователь"
               ,CASE pp.tct_brief
                 WHEN 'ФЛ' THEN
                  'ФЛ'
                 ELSE
                  'Юрлицо'
               END AS "Тип страхователя"
               ,ph.ass_count AS "Кол-во застрахованных по ДС"
               ,poli.status_name AS "Статус посл версии"
               ,poli.decline_reason_name AS decline_reason
               ,trunc(poli.decline_date, 'dd') AS "Дата расторжения"
               ,nvl(ph.region_name
                  ,(SELECT province_name FROM ins.t_province WHERE province_id = pp.region_id)) AS "Регион"
               ,'Убрано' AS "Агентство"
               ,CASE pc.plo_description
                 WHEN 'Административные издержки' THEN
                  'Ежегодно'
                 ELSE
                  tpt.description
               END "Рассрочка по Акт версии"
               ,tpt.number_of_payments
               ,CASE
                 WHEN tpt.is_periodical = 0 THEN
                  1
                 WHEN tpt.id IN (162, 165, 166) THEN
                  MONTHS_BETWEEN(ins_dwh.pkg_reserves_vs_profit.get_report_date, ph.start_date) / 12
                 ELSE
                  CEIL(MONTHS_BETWEEN(ins_dwh.pkg_reserves_vs_profit.get_report_date, ph.start_date) / 12)
               END AS "Год действия"
               , --par_date - Дата конца периода
               trunc(ph.start_date, 'dd') AS "Дата начала ДС"
               ,trunc(pp.end_date, 'dd') AS "Дата окончания ДС"
               ,ph.description AS "Продукт"
               ,pc.program_sum AS "Страховая сумма по акт версии"
               ,pc.plo_id "ID Риска"
               ,pc.plo_description "Программа"
               ,trunc(fp.fist_to_pay_date, 'dd') AS fist_to_pay_date
               ,pc.is_mandatory
               ,trunc(pc.program_start, 'dd') AS program_start
               ,trunc(pc.program_end, 'dd') AS program_end
               ,pp.version_num
               ,pp.version_order_num
               --
               , /*pph.min_to_pay_date*/(SELECT MIN(epg.plan_date)
                  FROM ins.p_policy       pp
                      ,ins.doc_doc        dd
                      ,ins.ven_ac_payment epg
                      ,ins.doc_templ      dt
                      ,ins.document       dc
                      ,ins.doc_status_ref dsr
                 WHERE pp.pol_header_id = ph.policy_header_id
                   AND dd.parent_id = pp.policy_id
                   AND dd.child_id = epg.payment_id
                   AND epg.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND epg.payment_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'TO_PAY'
                   AND (epg.amount -
                       (SELECT nvl(SUM(dso.set_off_child_amount), 0)
                           FROM ins.doc_set_off dso
                          WHERE dso.parent_doc_id = epg.payment_id
                            AND dso.cancel_date IS NULL)) >= 400) AS "Минимальная дата неоплаты"
               ,decode(ct.is_individual, 1, 'Д', 0, 'Н') AS "ФЛ (страхователя)"
               ,pc.is_adm_cost
               ,pc.version_risk_incl
               ,pc.is_assured_resident
               ,pp.is_insurer_resident
               ,(SELECT pg.brief
                  FROM ins.t_product       p
                      ,ins.t_product_group pg
                 WHERE ph.product_id = p.product_id
                   AND p.t_product_group_id = pg.t_product_group_id) product_group_brief
               
               --,dph.product_group_name
               ,(SELECT pg.name
                  FROM ins.t_product_group pg
                 WHERE prod.t_product_group_id = pg.t_product_group_id) product_group_name
               
               ,dtsc.descr_for_rep sc_gr
               ,pc.work_group_id
               ,tdt.name           AS decline_type_name
               
               ,(SELECT MAX(pad.ag_contract_header_id) keep(dense_rank LAST ORDER BY pad.p_policy_agent_doc_id)
                  FROM ins.p_policy_agent_doc pad
                 WHERE pad.policy_header_id = ph.policy_header_id
                   AND trunc(pad.date_begin) = trunc(ph.start_date)) first_pol_agent
               ,(SELECT MAX(a.due_date)
                
                  FROM ins.document       d
                      ,ins.ac_payment     a
                      ,ins.doc_templ      dt
                      ,ins.doc_doc        dd
                      ,ins.p_policy       p
                      ,ins.doc_status_ref dsr
                
                 WHERE d.document_id = a.payment_id
                   AND d.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND dd.child_id = d.document_id
                   AND dd.parent_id = p.policy_id
                   AND d.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief != 'ANNULATED'
                   AND p.pol_header_id = ph.policy_header_id) max_epg_due_date
               
               ,(SELECT pd.act_date
                  FROM ins.p_pol_decline pd
                 WHERE pd.p_policy_id = dph.max_uncancelled_policy_id) date_act_rast
        
        --------------------------------------------------- FROM -----------------------------------------
          FROM ins_dwh.reserves_vs_profit_pol pp
              ,ins_dwh.reserves_vs_profit_pheader ph
              ,ins_dwh.reserves_vs_profit_pcover pc
              ,ins.p_pol_header pph
              ,ins.p_policy last_ver
              ,ins.contact c
              ,ins.t_contact_type ct
              ,ins_dwh.reserves_vs_profit_fpays fp
              ,ins_dwh.reserves_vs_profit_lstpol poli
              ,ins.t_prod_line_rate rpl
              ,ins.deathrate dpl
              ,ins.document dch
              ,ins.t_sales_channel tch
              ,ins.t_payment_terms tpt
              ,ins.fund f
              ,ins.gaap_pl_types gt
              ,ins.p_cover_add_param pca
              ,ins.p_pol_header dph
              ,ins.t_product prod
              ,ins.t_sales_channel dtsc
              ,ins.t_period tpr
              ,ins.p_policy p_pol
              ,ins.t_decline_type tdt
              ,(SELECT pcc.p_cover_id AS pcc_p_cover_id
                      ,pcc.val        AS pcc_val
                  FROM ins.p_cover_coef     pcc
                      ,ins.t_prod_coef_type pct
                 WHERE pcc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                   AND pct.brief IN ('Коэффициент рассрочки платежа'
                                    ,'Coeff_payment_loss')) pay_coef
         WHERE ph.policy_header_id = dch.document_id
           AND ph.sales_channel_id = tch.id
           AND pc.p_policy_id = pp.policy_id
           AND poli.pol_header_id = ph.policy_header_id
           AND ph.policy_header_id = pp.pol_header_id
           AND pp.payment_term_id = tpt.id
           AND pay_coef.pcc_p_cover_id(+) = pc.p_cover_id
           AND f.fund_id = ph.fund_id
           AND gt.id(+) = pc.product_line_id
           AND pca.p_cover_id(+) = pc.p_cover_id
           AND ph.policy_header_id = pph.policy_header_id
           AND pp.contact_id = c.contact_id
           AND ct.id = c.contact_type_id
           AND pc.product_line_id = rpl.product_line_id(+)
           AND rpl.deathrate_id = dpl.deathrate_id(+)
           AND ph.policy_header_id = fp.policy_header_id(+)
           AND ph.policy_header_id = dph.policy_header_id
           AND dph.sales_channel_id = dtsc.id
           AND pp.policy_id = p_pol.policy_id
           AND p_pol.pol_privilege_period_id = tpr.id(+)
           AND last_ver.policy_id = pph.last_ver_id
           AND last_ver.decline_type_id = tdt.t_decline_type_id(+)
           AND ph.product_id = prod.product_id);
