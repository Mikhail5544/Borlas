create materialized view INS_DWH.FC_P_COVER
refresh force on demand
as
select
       nvl(dm_ph.policy_header_id, -1) policy_header_id,
       nvl(dm_rt.risk_type_id, -1) risk_type_id,
       (case
         when months_between(pp.end_date + 1, ph.start_date) > 12 then
          case
         when gt.life_property = 1 then
          2
         when gt.life_property = 0 then
          4
         else
          -1
       end else case
          when gt.life_property = 1 then
           1
          when gt.life_property = 0 then
           3
          else
           -1
        end end) risk_type_gaap_id,
       nvl(dm_assured.contact_id, -1) assured_contact_id,
       nvl(dm_insurer.contact_id, -1) insured_contact_id,
       pc.start_date start_date,
       pc.end_date end_date,
       pc.decline_date decline_date,
       pc.ins_amount ins_amount,
       pc.fee fee,
       -1 delta_fee, -- todo
       pc.p_cover_id,
       ins.doc.get_doc_status_name(pp.policy_id, sysdate) policy_status,
       tpt.number_of_payments,
       tpt.description pay_period_name,
       decl_reason.name decline_reason_name,
       pp.version_num,
       1 is_current, -- todo
       charging_rsbu.s charge_premium_rsbu,
       charging_ifrs.s charge_premium_ifrs,
       case tpt.is_periodical
         when 1 then
          ins.get_start_date_pmnt_period(pc.start_date,
                                         decode(tpt.number_of_payments,
                                                1,
                                                12,
                                                2,
                                                6,
                                                4,
                                                3,
                                                12,
                                                1,
                                                12),
                                         0,
                                         trunc(months_between(last_day(add_months(sysdate,-1)),
                                                              pc.start_date) /
                                               decode(tpt.number_of_payments,
                                                      1,
                                                      12,
                                                      2,
                                                      6,
                                                      4,
                                                      3,
                                                      12,
                                                      1,
                                                      12),
                                               0))
         when 0 then
          pc.start_date
       end inst_start,
       case tpt.is_periodical
         when 1 then
          ins.get_start_date_pmnt_period(pc.start_date,
                                         decode(tpt.number_of_payments,
                                                1,
                                                12,
                                                2,
                                                6,
                                                4,
                                                3,
                                                12,
                                                1,
                                                12),
                                         0,
                                         (trunc(months_between(last_day(add_months(sysdate,-1)),
                                                               pc.start_date) /
                                                decode(tpt.number_of_payments,
                                                       1,
                                                       12,
                                                       2,
                                                       6,
                                                       4,
                                                       3,
                                                       12,
                                                       1,
                                                       12),
                                                0) + 1)) - 1
         when 0 then
          pc.end_date
       end inst_end,
       p_cover_deathrate.name deathrate_name,
       pc.normrate_value normrate_value,
       pc.insured_age insured_age,
       decode(pc.is_avtoprolongation, 1, 'Д', 0, 'Н', 'Н') is_avtoprolongation,
       trunc(months_between(pp.end_date + 1, ph.start_date), 0) / 12 policy_period,
       trunc(months_between(pc.end_date + 1, pc.start_date), 0) / 12 cover_period,
       pc.rvb_value rvb_value,
       ' ' pension_periodicity, -- todo
       to_date('01011900','ddmmyyyy') start_repay_annuity_date, -- todo
       to_date('01011900','ddmmyyyy') end_repay_annuity_date, -- todo
       to_date('01011900','ddmmyyyy') fee_end_payment_date, -- todo
       ' ' fee_payment_term, -- todo
       ' ' bank_name, -- todo
       ins.acc_new.get_rate_by_id(1, f.fund_id, sysdate) rate,
       pc.k_coef_m k_coef_m,
       pc.s_coef_m s_coef_m,
       pc.k_coef_nm k_coef_nm,
       pc.s_coef_nm s_coef_nm,
       pca.sport_coef sport_coef,
       pca.prof_coef prof_coef,
       pca.k_coef_m_re k_coef_m_re,
       pca.s_coef_m_re s_coef_m_re,
       pca.k_coef_nm_re k_coef_nm_re,
       pca.s_coef_nm_re s_coef_nm_re,
       -1 sport_coef_re,
       -1 prof_coef_re,
       av_trans_oav.oav_agent,
       av_trans_oav.oav_manager,
       av_trans_oav.oav_director,
       av_trans_dav.dav_agent,
       av_trans_dav.dav_manager,
       av_trans_dav.dav_director,
       av_trans_oav_1year.oav_agent_1year,
       av_trans_oav_1year.oav_manager_1year,
       av_trans_oav_1year.oav_director_1year,
       sysdate created_date,
       sysdate modified_date

  from dm_p_pol_header dm_ph,
       dm_risk_type dm_rt,
       dm_contact dm_insurer,
       dm_contact dm_assured,
       ins.p_cover pc,
       ins.ven_as_assured aa,
       ins.ven_p_policy pp,
       ins.status_hist sh,
       ins.ven_p_pol_header ph,
       ins.t_prod_line_option plo,
       ins.t_payment_terms tpt,
       ins.fund f,
       ins.gaap_pl_types gt,
       ins.p_cover_add_param pca,
       ins.t_decline_reason decl_reason,
       (select polc.policy_id, polc.contact_id
          from ins.p_policy_contact polc, ins.t_contact_pol_role pr
         where polc.contact_policy_role_id = pr.id
           and pr.brief = 'Страхователь') insurers, -- страхователи по договорам страхования

       (select policy_id
          from (select max(pp.version_num) over(partition by pp.pol_header_id) m,
                       pp.policy_id,
                       pp.version_num
                  from ins.p_policy pp
                 where ins.doc.get_doc_status_brief(pp.policy_id,
                                                    sysdate
                                                    /*to_date('17.10.2007',
                                                    'DD.MM.YYYY')*/) not in
                       ('PROJECT', /*'STOPED', 'BREAK',*/ 'CANCEL'))
         where m = version_num) active_policy_on_date, -- действующие на дату версии
       (select pcc.p_cover_id pcc_p_cover_id, pcc.val pcc_val
          from ins.p_cover_coef pcc, ins.t_prod_coef_type pct
         where pcc.t_prod_coef_type_id = pct.t_prod_coef_type_id

           and pct.brief in
               ('Коэффициент рассрочки платежа', 'Coeff_payment_loss')) pay_coef,
       (select sum(t1.trans_amount) s,
                t1.a3_ct_uro_id p_asset_header_id,
                t1.a4_ct_uro_id t_prod_line_option_id --, t1.trans_date
           from ins.ven_trans t1
          where

             t1.ct_account_id = 186

          group by t1.a3_ct_uro_id,
                t1.a4_ct_uro_id

         ) charging_rsbu , -- проводки по начислению премии

       pre_cover_charging_ifrs charging_ifrs,

       /*
       (select sum(av1.trans_amount) s, av1.p_cover_id
          from ins.trans_av_dwh av1
         group by av1.p_cover_id) av_trans,
       */
       (select distinct mc.reinsurer_id,
                        rc.p_cover_id,
                        con.obj_name reinsurer_name
          from ins.re_cover rc, ins.re_main_contract mc, ins.contact con
         where mc.re_main_contract_id = rc.re_m_contract_id
           and mc.reinsurer_id = con.contact_id) bordero_reinsurer ,



       (select dri.p_cover_id, dr.name
          from (select pc.p_cover_id,
                       ll.t_lob_line_id,
                       decode(lr.func_id,
                              null,
                              lr.deathrate_id,
                              ins.pkg_tariff_calc.calc_fun(lr.func_id,
                                                           ins.ent.id_by_brief('P_COVER'),
                                                           pc.p_cover_id)) deathrate_id

                  from ins.t_lob_line         ll,
                       ins.t_prod_line_rate   lr,
                       ins.t_product_line     pl,
                       ins.t_prod_line_option plo,
                       ins.p_cover            pc

                 where 1 = 1
                      --  and pc.p_cover_id = v_cover_id
                   and plo.id = pc.t_prod_line_option_id
                   and pl.id = plo.product_line_id
                   and ll.t_lob_line_id = pl.t_lob_line_id
                   and lr.product_line_id(+) = pl.id) dri,
               ins.deathrate dr
         where dri.deathrate_id = dr.deathrate_id(+)) p_cover_deathrate



         ,
       (select sum(decode(agc.brief, 'AG', av1.trans_amount, 0)) oav_agent,
               sum(decode(agc.brief, 'MN', av1.trans_amount, 0)) oav_manager,
               sum(decode(agc.brief, 'DR', av1.trans_amount, 0)) oav_director,
               av1.p_cover_id
          from ins.trans_av_dwh      av1,
               ins.ag_category_agent agc,
               ins.t_ag_av           taa
         where av1.t_ag_av_id = taa.t_ag_av_id
           and av1.ag_category_agent_id = agc.ag_category_agent_id
           and taa.brief in ('ОАВ', 'ПР')
         group by av1.p_cover_id) av_trans_oav,

       (select sum(decode(agc.brief, 'AG', av1.trans_amount, 0)) dav_agent,
               sum(decode(agc.brief, 'MN', av1.trans_amount, 0)) dav_manager,
               sum(decode(agc.brief, 'DR', av1.trans_amount, 0)) dav_director,
               av1.p_cover_id
          from ins.trans_av_dwh      av1,
               ins.ag_category_agent agc,
               ins.t_ag_av           taa
         where av1.t_ag_av_id = taa.t_ag_av_id
           and av1.ag_category_agent_id = agc.ag_category_agent_id
           and taa.brief in ('ДАВ')
         group by av1.p_cover_id) av_trans_dav,

       (select sum(decode(agc.brief, 'AG', av1.trans_amount, 0)) oav_agent_1year,
               sum(decode(agc.brief, 'MN', av1.trans_amount, 0)) oav_manager_1year,
               sum(decode(agc.brief, 'DR', av1.trans_amount, 0)) oav_director_1year,
               av1.p_cover_id
          from ins.p_cover           pc3,
               ins.as_asset          aa3,
               ins.p_policy          pp3,
               ins.p_pol_header      ph3,
               ins.trans_av_dwh      av1,
               ins.ag_category_agent agc,
               ins.t_ag_av           taa
         where av1.t_ag_av_id = taa.t_ag_av_id
           and av1.ag_category_agent_id = agc.ag_category_agent_id
           and taa.brief in ('ОАВ', 'ПР')
           and pc3.p_cover_id = av1.p_cover_id
           and pc3.as_asset_id = aa3.as_asset_id
           and pp3.policy_id = aa3.p_policy_id
           and pp3.pol_header_id = ph3.policy_header_id
              -- дата выплаты в первом страховом году
           and av1.date_trance between ph3.start_date and
               add_months(ph3.start_date, 12) - 1
         group by av1.p_cover_id) av_trans_oav_1year

 where dm_ph.policy_header_id(+) = ph.policy_header_id
   and dm_rt.risk_type_id(+) = pc.t_prod_line_option_id
   and dm_insurer.contact_id(+) = insurers.contact_id
   and dm_assured.contact_id(+) = aa.assured_contact_id

   and pc.as_asset_id = aa.as_assured_id
   and aa.p_policy_id = pp.policy_id
   and pc.status_hist_id = sh.status_hist_id
   and sh.brief != 'DELETED'
      -- действующие на дату версии
   and pp.policy_id = active_policy_on_date.policy_id
      -- действующие на дату покрытия по действущим версиям
   and ph.policy_header_id = pp.pol_header_id
   and insurers.policy_id = pp.policy_id
   and pp.payment_term_id = tpt.id
   and pay_coef.pcc_p_cover_id(+) = pc.p_cover_id
   and f.fund_id = ph.fund_id
   and charging_rsbu.p_asset_header_id = aa.p_asset_header_id
   and charging_rsbu.t_prod_line_option_id = pc.t_prod_line_option_id

   and plo.id = pc.t_prod_line_option_id
   and gt.id(+) = plo.product_line_id
   and pca.p_cover_id(+) = pc.p_cover_id
 --  and av_trans.p_cover_id(+) = pc.p_cover_id
   and bordero_reinsurer.p_cover_id(+) = pc.p_cover_id
   and pp.decline_reason_id = decl_reason.t_decline_reason_id(+)
   and pc.p_cover_id = p_cover_deathrate.p_cover_id(+)

   and pc.p_cover_id = charging_ifrs.p_cover_id(+)

   and pc.p_cover_id = av_trans_oav.p_cover_id(+)
   and pc.p_cover_id = av_trans_dav.p_cover_id(+)
   and pc.p_cover_id = av_trans_oav_1year.p_cover_id(+);

