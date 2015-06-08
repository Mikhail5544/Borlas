CREATE OR REPLACE VIEW RESERVE.V_REGISTRY_HIST_VALUES
(policy_header_id, policy_id, contact_id, insurance_variant_id, t_product_line_id, policy_version_num, policy_version_start_date, policy_number, policy_fact_yield_rate, is_periodical, periodicity, payment_duration, start_date, end_date, payment, insurance_amount, b, rent_periodicity, rent_payment, rent_duration, rent_start_date, has_additional, payment_base, sex, age, death_date, k_coef, s_coef, rvb_value, g, p, g_re, p_re, k_coef_re, s_coef_re, deathrate_id, ins_premium)
AS
SELECT ph.policy_header_id AS policy_header_id
                                                 -- ИД договора страхования жизни
          ,
          p.policy_id AS policy_id          --  ИД версии договора страхования
                                  ,
          cn.contact_id AS contact_id                    -- ИД застрахованного
                                     ,
          pl.t_lob_line_id AS insurance_variant_id  -- ИД варианта страхования
                                                  ,
          pl.ID AS t_product_line_id                -- ИД варианта страхования
                                    ,
          p.version_num AS policy_version_num           -- номер версии полиса
                                             ,
          p.start_date AS policy_version_start_date             -- дата версии
                                                   ,
          p.pol_num || '-' || p.pol_num AS policy_number
                                                        -- номер договора страхования жизни
          ,
          pc.normrate_value AS policy_fact_yield_rate
                                                     -- фактическая норма доходности
          ,
          (CASE WHEN (SELECT COUNT(*)
                      FROM ins.t_lob_line ll
                      WHERE ll.t_lob_line_id = pl.t_lob_line_id
                            AND ll.brief = 'PEPR_INVEST_RESERVE'
                      ) > 0 THEN 0
                ELSE pt.is_periodical
          END) is_periodical -- является ли график периодичным
          /*pt.is_periodical*/                   
                          ,
          (CASE WHEN (SELECT COUNT(*)
                      FROM ins.t_lob_line ll
                      WHERE ll.t_lob_line_id = pl.t_lob_line_id
                            AND ll.brief = 'PEPR_INVEST_RESERVE'
                      ) > 0 THEN 1
                ELSE pt.number_of_payments
          END) AS periodicity -- число платежей в год
          /*pt.number_of_payments AS periodicity*/         
                                              ,
          p.fee_payment_term AS payment_duration        -- срок уплаты взносов
                                                ,
          pc.start_date AS start_date           -- дата начала ответственности
                                     ,
          pc.end_date AS end_date             -- дата окончания ответсвенности
                                 ,
          pc.fee AS payment                                    -- брутто-взнос
                           ,
          pc.ins_amount AS insurance_amount                 -- страховая сумма
                                           ,
          NULL AS b                                           -- коэффициент В
                   ,
          NULL AS rent_periodicity              -- периодичность выплаты ренты
                                  ,
          NULL AS rent_payment      -- размер одной рассроченной выплаты ренты
                              ,
          NULL AS rent_duration                          -- срок выплаты ренты
                               ,
          NULL AS rent_start_date                  -- дата начала выплты ренты
                                 ,
          0 AS has_additional             -- имеется ли дополнительный вариант
                             ,
          0 AS payment_base
-- сумма рассроченных взносов по вариантам страхования в договоре за исключением iv_13
          , pers.gender AS sex                                      -- ид пола
                              ,
          pc.insured_age AS age                           -- страховой возраст
                               ,
          pers.date_of_death AS death_date                      -- дата сметри
                                          ,
          pc.k_coef, pc.s_coef, pc.rvb_value, pc.tariff AS g,
          pc.tariff_netto AS p, pc_11.g g_re, pc_11.p p_re,
          pc_11.s_coef s_coef_re, pc_11.k_coef k_coef_re,

          /* Добавил Марчук А баг 950 выполено 2007.11.29 */
          DECODE
             (plr.func_id,
              NULL, plr.deathrate_id,
              ins.pkg_tariff_calc.calc_fun (plr.func_id,
                                            ins.ent.id_by_brief ('P_COVER'),
                                            pc.p_cover_id
                                           )
             ) deathrate_id,
             pc.premium as ins_premium --премия
--
   FROM   ins.t_product prod,
          ins.p_pol_header ph,
          ins.p_policy p,
          ins.document d,
          ins.doc_status_ref rf,
          ins.t_payment_terms pt,
          ins.as_asset a,
          ins.contact cn,
          ins.cn_person pers,
          ins.as_assured ass,
          ins.p_cover_11 pc_11,
          ins.p_cover pc,
   --    ins.status_hist      as_sh,
     --  ins.status_hist      cover_sh,
--
          ins.t_prod_line_option plo,
          ins.t_product_line pl,
          ins.t_prod_line_rate plr
    WHERE prod.brief IN (
             SELECT p.brief
               FROM ins.t_product p,
                    ins.t_product_version pv,
                    ins.t_product_ver_lob pvl,
                    ins.t_product_line pl
              WHERE p.product_id = pv.product_id
                AND pv.t_product_version_id = pvl.product_version_id
                AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                AND pl.t_lob_line_id IN (SELECT v.ID
                                           FROM reserve.v_ins_variant v))
      AND ph.product_id = prod.product_id
      AND p.pol_header_id = ph.policy_header_id
      AND p.policy_id = d.document_id
      AND d.doc_status_ref_id = rf.doc_status_ref_id
      --AND rf.brief != 'CANCEL'
      AND a.p_policy_id = p.policy_id
      AND p.payment_term_id = pt.ID
      AND ass.as_assured_id = a.as_asset_id
      AND cn.contact_id = ass.assured_contact_id
      AND pers.contact_id = cn.contact_id
      AND pc.as_asset_id = a.as_asset_id
      AND plr.product_line_id = pl.ID
        -- временно закомментировал для показа (DI)
      /*  and a.status_hist_id = as_sh.status_hist_id
        and (as_sh.brief = 'NEW' or as_sh.brief = 'CURRENT')
        and pc.status_hist_id = cover_sh.status_hist_id
        and (cover_sh.brief = 'NEW' or cover_sh.brief = 'CURRENT') */
      AND pc.t_prod_line_option_id = plo.ID
      AND pc_11.p_cover_11_id(+) = pc.p_cover_id
      AND plo.product_line_id = pl.ID;
