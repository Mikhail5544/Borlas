CREATE OR REPLACE PACKAGE pkg_discoverer_utils IS

  -- Author  : MMIROVICH
  -- Created : 18.10.2007 17:15:52
  -- Purpose : Пакет для формирования отчетов в Discoverer

  /**
  * Переменные для пакета типа дата
  */
  P_DATA_START DATE; -- дата начала
  P_DATA_END   DATE; -- дата окончания
  P_REP_DATA   DATE; -- дата отчета

  /**
  * Запись для выгрузки по резервам
  */
  TYPE t_res_dwh_main IS RECORD(
     rep_date          DATE -- дата отчета
    ,Empty0            VARCHAR2(200)
    ,Current_Policy_ID NUMBER
    ,Cover_ID          NUMBER
    ,Policy_number     VARCHAR2(200)
    
    ,Policy_version   VARCHAR2(100)
    ,Risk_name        VARCHAR2(300)
    ,Policy_Type_ID   VARCHAR2(10)
    ,Empty1           VARCHAR2(200)
    ,Sex_Insurer      VARCHAR2(10)
    ,Empty2           VARCHAR2(200)
    ,Sex_Policyholder VARCHAR2(10)
    ,Date_from        DATE
    ,Date_to          DATE
    ,Empty3           VARCHAR2(200)
    
    ,Cover_value                NUMBER
    ,Cover_premium              NUMBER
    ,Empty4                     VARCHAR2(200)
    ,Pay_period_name            VARCHAR2(200)
    ,Med_ep_coef                NUMBER
    ,Med_em_coef                NUMBER
    ,Ep_non_med                 NUMBER
    ,Em_non_med                 NUMBER
    ,I_sport_coef               NUMBER
    ,I_prof_coef                NUMBER
    ,Re_med_ep_coef             NUMBER
    ,Re_med_em_coef             NUMBER
    ,Re_ep_non_med              NUMBER
    ,Re_em_non_med              NUMBER
    ,Re_sport_coef              VARCHAR2(200)
    ,Re_prof_coef               VARCHAR2(200)
    ,Policy_note                VARCHAR2(10)
    ,Date_of_birth_Insurer      DATE
    ,Date_of_birth_Policyholder DATE
    ,Date_of_death_Insurer      DATE
    ,Insurer_id                 NUMBER
    
    ,Empty5                VARCHAR2(200)
    ,Currency              VARCHAR2(200)
    ,Empty6                VARCHAR2(200)
    ,Empty7                VARCHAR2(200)
    ,Empty8                VARCHAR2(200)
    ,Insurance_period      NUMBER
    ,Empty9                VARCHAR2(200)
    ,Mort_discount         NUMBER
    ,Ii_rate               NUMBER
    ,Date_Cancel           DATE
    ,Empty10               VARCHAR2(200)
    ,Empty11               VARCHAR2(200)
    ,Empty12               VARCHAR2(200)
    ,Empty13               VARCHAR2(200)
    ,Policy_holder         VARCHAR2(200)
    ,Empty14               VARCHAR2(200)
    ,Empty15               VARCHAR2(200)
    ,Empty16               VARCHAR2(200)
    ,Empty17               VARCHAR2(200)
    ,Empty18               VARCHAR2(200)
    ,Corporate_policy_type VARCHAR2(10)
    
    ,Empty19        VARCHAR2(200)
    ,Reinsured      VARCHAR2(200)
    ,Empty20        VARCHAR2(200)
    ,Empty21        VARCHAR2(200)
    ,Date_orig      DATE
    ,Empty22        VARCHAR2(200)
    ,Empty23        VARCHAR2(200)
    ,Empty24        VARCHAR2(200)
    ,Empty25        VARCHAR2(200)
    ,Empty26        VARCHAR2(200)
    ,Empty27        VARCHAR2(200)
    ,Empty28        VARCHAR2(200)
    ,Empty29        VARCHAR2(200)
    ,Empty30        VARCHAR2(200)
    ,Empty31        VARCHAR2(200)
    ,Empty32        VARCHAR2(200)
    ,Empty33        VARCHAR2(200)
    ,Empty34        VARCHAR2(200)
    ,Empty35        VARCHAR2(200)
    ,Empty36        VARCHAR2(200)
    ,Empty37        VARCHAR2(200)
    ,Year_com       VARCHAR2(10)
    ,Empty38        VARCHAR2(200)
    ,Empty39        VARCHAR2(200)
    ,Empty40        VARCHAR2(200)
    ,Empty41        VARCHAR2(200)
    ,Empty42        VARCHAR2(200)
    ,Empty43        VARCHAR2(200)
    ,Empty44        VARCHAR2(200)
    ,Empty45        VARCHAR2(200)
    ,Charge_Premium NUMBER
    ,Empty47        VARCHAR2(200)
    ,Empty48        VARCHAR2(200)
    ,Empty49        VARCHAR2(200)
    ,Empty50        VARCHAR2(200)
    ,Empty51        VARCHAR2(200)
    ,Empty52        VARCHAR2(200)
    ,Empty53        VARCHAR2(200)
    
    ,Risk_type_gaap      VARCHAR2(10)
    ,Empty54             VARCHAR2(200)
    ,Empty55             VARCHAR2(200)
    ,Empty56             VARCHAR2(200)
    ,Empty57             VARCHAR2(200)
    ,Loading             NUMBER
    ,Ii_rate_benefit     VARCHAR2(100)
    ,Benefit_period_name VARCHAR2(200)
    ,Date_start_benefit  VARCHAR2(200)
    ,Date_benefit_end    VARCHAR2(200)
    ,Benefit_period      VARCHAR2(200)
    ,Date_guaranteed_end VARCHAR2(200)
    ,Guaranteed_period   VARCHAR2(200)
    ,Date_end_premium    VARCHAR2(200)
    ,Premium_period      VARCHAR2(200)
    ,Empty58             VARCHAR2(200)
    ,Empty59             VARCHAR2(200)
    ,Empty60             VARCHAR2(200)
    ,Empty61             VARCHAR2(200)
    ,Empty62             VARCHAR2(200)
    ,Empty63             VARCHAR2(200)
    ,Empty64             VARCHAR2(200)
    ,Empty65             VARCHAR2(200)
    ,Acquisition_total   VARCHAR2(200)
    
    ,Inst_start      DATE
    ,Inst_end        DATE
    ,Commission      NUMBER
    ,actuar_age      NUMBER
    ,p_cover_id      NUMBER
    ,p_policy_id     NUMBER
    ,p_pol_header_id NUMBER
    ,risk_ext_id     VARCHAR2(200)
    ,policy_ext_ID   VARCHAR2(200)
    ,Policy_insurer  VARCHAR2(200)
    ,Pay_period_coef NUMBER
    ,bank_product    VARCHAR2(200)
    ,product_name    VARCHAR2(200)
    
    );

  /**
  * Сводная таблица для выгрузки по резервам
  */
  TYPE tbl_res_dwh_main IS TABLE OF t_res_dwh_main;

  -- задает значение глобальный переменных
  FUNCTION set_p_dates
  (
    f_date_start DATE
   ,f_date_end   DATE
   ,f_rep_data   DATE
  ) RETURN VARCHAR2;

  -- возвращает таблицу для выгрузки резервов
  FUNCTION get_tbl_res_dwh_main RETURN tbl_res_dwh_main
    PIPELINED;

END pkg_discoverer_utils;
/
CREATE OR REPLACE PACKAGE BODY pkg_discoverer_utils IS

  FUNCTION set_p_dates
  (
    f_date_start DATE
   ,f_date_end   DATE
   ,f_rep_data   DATE
  ) RETURN VARCHAR2 AS
    str VARCHAR2(50);
  BEGIN
    pkg_discoverer_utils.P_DATA_START := f_date_start;
    pkg_discoverer_utils.P_DATA_END   := f_date_end;
    pkg_discoverer_utils.P_REP_DATA   := f_rep_data;
    IF pkg_discoverer_utils.P_REP_DATA IS NOT NULL
    THEN
      str := pkg_discoverer_utils.P_REP_DATA;
    ELSE
      str := pkg_discoverer_utils.P_DATA_START || ' - ' || pkg_discoverer_utils.P_DATA_END;
    END IF;
    RETURN str;
  END;

  FUNCTION get_tbl_res_dwh_main RETURN tbl_res_dwh_main
    PIPELINED AS
  BEGIN
    --pkg_discoverer_utils.P_REP_DATA:= to_date ('30.09.2007', 'dd.mm.yyyy');
    FOR rec IN (SELECT p_rep_data
                      ,NULL "Empty0"
                       ,pp.policy_id "Current Policy ID"
                       ,pc.p_cover_id "Cover ID"
                       ,decode(pp.pol_ser, NULL, pp.pol_num, pp.pol_ser || '-' || pp.pol_num) "Policy number"
                       ,'ю(Текущая версия)' "Policy_version"
                       ,ll.description "Risk name"
                       ,decode(ig.life_property, 0, 'C', 1, 'L', NULL) "Policy Type ID"
                       ,NULL "Empty1"
                       ,decode(cn_pol_insurer.gender, 0, 'F', 1, 'M') "Sex(Insurer)"
                       ,NULL "Empty2"
                       ,decode(cn_pol_holder_person.gender, 0, 'F', 1, 'M') "Sex(Policyholder)"
                       ,pc.start_date "Date from"
                       ,pc.end_date "Date to"
                       ,NULL "Empty3"
                       
                       ,pc.ins_amount "Cover value"
                       ,pc.fee "Cover premium"
                       ,NULL "Empty4"
                       ,tpt.description "Pay period name"
                       ,pc.k_coef_m "Med ep coef"
                       ,pc.s_coef_nm "Med em coef"
                       ,pc.k_coef_nm "Ep non med"
                       ,pc.s_coef_nm "Em non med"
                       ,pca.sport_coef "I sport coef"
                       ,pca.prof_coef "I prof coef"
                       ,pca.k_coef_m_re "Re med ep coef"
                       ,pca.s_coef_m_re "Re med em coef"
                       ,pca.k_coef_nm_re "Re ep non med"
                       ,pca.s_coef_nm_re "Re em non med"
                       ,NULL "Re sport coef"
                       ,NULL "Re prof coef"
                       ,decode(pc.is_avtoprolongation, 1, 'Да', 0, 'Нет', 'Нет') "Policy note"
                       ,cn_pol_insurer.date_of_birth "Date of birth(Insurer)"
                       ,cn_pol_holder_person.date_of_birth "Date of birth(Policyholder)"
                       ,cn_pol_insurer.date_of_death "Date of death(Insurer)"
                       ,aa.p_asset_header_id "Insurer id"
                       
                       ,NULL "Empty5"
                       ,f.brief "Currency"
                       ,NULL "Empty6"
                       ,NULL "Empty7"
                       ,NULL "Empty8"
                       ,trunc(MONTHS_BETWEEN(pp.end_date + 1, ph.start_date), 0) / 12 "Insurance period"
                       ,NULL "Empty9"
                       ,pca.mort_discount "Mort discount" -- этого у нас нет
                       ,pc.NORMRATE_VALUE "Ii rate"
                       ,pc.decline_date "Date Cancel"
                       ,NULL "Empty10"
                       ,NULL "Empty11"
                       ,NULL "Empty12"
                       ,NULL "Empty13"
                       ,cn_pol_holder.obj_name "Policy holder"
                       ,NULL "Empty14"
                       ,NULL "Empty15"
                       ,NULL "Empty16"
                       ,NULL "Empty17"
                       ,NULL "Empty18"
                       ,decode(pp.is_group_flag, 0, 'I', 1, 'C', 'I') "Corporate policy type"
                       
                       ,NULL "Empty19"
                       ,nvl(pca.reinsurer, bordero_reinsurer.reinsurer_name) "Reinsured"
                       ,NULL "Empty20"
                       ,NULL "Empty21"
                       ,ph.start_date "Date orig"
                       ,NULL "Empty22"
                       ,NULL "Empty23"
                       ,NULL "Empty24"
                       ,NULL "Empty25"
                       ,NULL "Empty26"
                       ,NULL "Empty27"
                       ,NULL "Empty28"
                       ,NULL "Empty29"
                       ,NULL "Empty30"
                       ,NULL "Empty31"
                       ,NULL "Empty32"
                       ,NULL "Empty33"
                       ,NULL "Empty34"
                       ,NULL "Empty35"
                       ,NULL "Empty36"
                       ,NULL "Empty37"
                       ,NULL "Year com"
                       ,NULL "Empty38"
                       ,NULL "Empty39"
                       ,NULL "Empty40"
                       ,NULL "Empty41"
                       ,NULL "Empty42"
                       ,NULL "Empty43"
                       ,NULL "Empty44"
                       ,NULL "Empty45"
                       ,charging.s "Charge Premium"
                       ,NULL "Empty47"
                       ,NULL "Empty48"
                       ,NULL "Empty49"
                       ,NULL "Empty50"
                       ,NULL "Empty51"
                       ,NULL "Empty52"
                       ,NULL "Empty53"
                       
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
                       END "Risk type gaap"
                       
                       ,NULL         "Empty54"
                       ,NULL         "Empty55"
                       ,NULL         "Empty56"
                       ,NULL         "Empty57"
                       ,pc.rvb_value "Loading"
                       ,NULL         "Ii rate benefit"
                       ,NULL         "Benefit period name"
                       ,NULL         "Date start benefit"
                       ,NULL         "Date benefit end"
                       ,NULL         "Benefit period"
                       ,NULL         "Date guaranteed end"
                       ,NULL         "Guaranteed period"
                       ,NULL         "Date end premium"
                       ,NULL         "Premium period"
                       ,NULL         "Empty58"
                       ,NULL         "Empty59"
                       ,NULL         "Empty60"
                       ,NULL         "Empty61"
                       ,NULL         "Empty62"
                       ,NULL         "Empty63"
                       ,NULL         "Empty64"
                       ,NULL         "Empty65"
                       ,NULL         "Acquisition total"
                       
                       ,CASE tpt.is_periodical
                         WHEN 1 THEN
                          get_start_date_pmnt_period(pc.start_date
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
                                                    ,trunc(MONTHS_BETWEEN(P_REP_DATA, pc.start_date) /
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
                       END "Inst start"
                       ,CASE tpt.is_periodical
                         WHEN 1 THEN
                          get_start_date_pmnt_period(pc.start_date
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
                                                    ,(trunc(MONTHS_BETWEEN(P_REP_DATA, pc.start_date) /
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
                       END "Inst end"
                       
                       ,nvl(av_trans.s, 0) "Commission"
                       ,pc.insured_age "actuar_age"
                       ,pc.p_cover_id "p_cover_id"
                       ,pp.policy_id "p_policy_id"
                       ,ph.policy_header_id "p_pol_header_id"
                       ,pc.ext_id "risk_ext_id"
                       ,ph.ext_id "policy_ext_ID"
                       ,cn_pol_insurer.obj_name "Policy insurer"
                       ,pay_coef.pcc_val "Pay period coef"
                       ,cr_prod.description "bank product"
                       ,prod.description "product name"
                
                  FROM p_cover            pc
                      ,ven_as_assured     aa
                      ,ven_p_policy       pp
                      ,status_hist        sh
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                      ,t_lob_line         ll
                      ,t_insurance_group  ig
                      ,t_product          prod
                      ,ven_p_pol_header   ph
                      ,contact            cn_pol_holder
                      ,cn_person          cn_pol_holder_person
                      ,ven_cn_person      cn_pol_insurer
                      ,t_payment_terms    tpt
                      ,fund               f
                      ,gaap_pl_types      gt
                      ,p_cover_add_param  pca
                      ,
                       --    contact reinsurer_contact,
                       (SELECT polc.policy_id
                              ,polc.contact_id
                          FROM p_policy_contact   polc
                              ,t_contact_pol_role pr
                         WHERE polc.contact_policy_role_id = pr.id
                           AND pr.brief = 'Страхователь') insurers
                      , --страхователи по договорам 
                       (SELECT policy_id
                          FROM (SELECT MAX(pp.version_num) over(PARTITION BY pp.pol_header_id) m
                                      ,pp.policy_id
                                      ,pp.version_num
                                  FROM p_policy pp
                                 WHERE doc.get_doc_status_brief(pp.policy_id, P_REP_DATA) NOT IN
                                       ('PROJECT', 'STOPED', 'BREAK', 'CANCEL'))
                         WHERE m = version_num) active_policy_on_date
                      , --действующие на дату версии
                       (SELECT pcc.p_cover_id pcc_p_cover_id
                              ,pcc.val        pcc_val
                          FROM p_cover_coef     pcc
                              ,t_prod_coef_type pct
                         WHERE pcc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                              --  and pcc.p_cover_id = pc.p_cover_id
                           AND pct.brief IN ('Коэффициент рассрочки платежа'
                                            ,'Coeff_payment_loss')) pay_coef
                      , (SELECT SUM(t1.trans_amount) s
                               ,a1.p_asset_header_id
                               ,pc1.t_prod_line_option_id --, t1.trans_date
                           FROM -- ins.ven_p_policy     pp,
                                -- ins.ven_p_pol_header ph,
                                 p_cover   pc1
                               ,as_asset  a1
                               ,ven_trans t1
                          WHERE
                         --ph.start_date between :first_day and :dright
                         -- and ph.policy_header_id = pp.pol_header_id(+)
                         --  t.trans_date between :first_day and :dright
                          a1.as_asset_id = pc1.as_asset_id
                       AND t1.ct_account_id = 186
                       AND t1.A4_ct_URO_ID = pc1.t_prod_line_option_id
                       AND t1.a3_ct_uro_id = a1.p_asset_header_id
                          GROUP BY a1.p_asset_header_id
                                  ,pc1.t_prod_line_option_id
                         --   and t.trans_date between pc.start_date and pc.end_date
                         ) charging
                      , -- проводки по начислению премии
                       (SELECT prod1.description
                              ,prod1.product_id
                          FROM t_product prod1
                         WHERE prod1.brief LIKE '%CR%') cr_prod
                      ,(SELECT SUM(av1.trans_amount) s
                              ,av1.p_cover_id
                          FROM trans_av_dwh av1
                         GROUP BY av1.p_cover_id) av_trans
                      ,(SELECT DISTINCT mc.reinsurer_id
                                       ,rc.p_cover_id
                                       ,con.obj_name reinsurer_name
                          FROM re_cover         rc
                              ,re_main_contract mc
                              ,contact          con
                         WHERE mc.re_main_contract_id = rc.re_m_contract_id
                           AND mc.reinsurer_id = con.contact_id) bordero_reinsurer
                
                 WHERE pc.as_asset_id = aa.as_assured_id
                   AND aa.p_policy_id = pp.policy_id
                   AND pc.status_hist_id = sh.status_hist_id
                      -- действующие на дату версии
                   AND pp.policy_id = active_policy_on_date.policy_id
                      -- действующие на дату покрытия по действущим версиям
                   AND pc.start_date <= P_REP_DATA
                   AND pc.end_date > P_REP_DATA
                   AND sh.brief <> 'DELETED'
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND pl.t_lob_line_id = ll.t_lob_line_id
                   AND ll.insurance_group_id = ig.t_insurance_group_id
                   AND ph.policy_header_id = pp.pol_header_id
                   AND prod.product_id = ph.product_id
                      --and polc.contact_policy_role_id = 6
                   AND insurers.policy_id = pp.policy_id
                   AND cn_pol_holder.contact_id = insurers.contact_id
                      --  and pp.policy_id = 830007
                   AND cn_pol_insurer.contact_id = aa.assured_contact_id
                   AND cn_pol_holder.contact_id = cn_pol_holder_person.contact_id(+)
                   AND pp.payment_term_id = tpt.id
                   AND pay_coef.pcc_p_cover_id(+) = pc.p_cover_id
                   AND f.fund_id = ph.fund_id
                   AND charging.p_asset_header_id = aa.p_asset_header_id
                   AND charging.t_prod_line_option_id = pc.t_prod_line_option_id
                   AND prod.product_id = cr_prod.product_id(+)
                   AND gt.id(+) = pl.id
                   AND pca.p_cover_id(+) = pc.p_cover_id
                   AND pp.is_group_flag <> 1
                   AND av_trans.p_cover_id(+) = pc.p_cover_id
                   AND bordero_reinsurer.p_cover_id(+) = pc.p_cover_id
                --and bordero_reinsurer.reinsurer_id = reinsurer_contact.contact_id 
                )
    LOOP
      PIPE ROW(rec);
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END;
END pkg_discoverer_utils;
/
