create or replace force view ins_dwh.v_cbnt_cover as
select nvl(to_char(pc.p_cover_id),'null') p_cover_id,
       nvl(to_char(pp.POLICY_ID),'null') policy_id,
       nvl(to_char(pc.start_date,'dd.mm.yyyy'),'null') date_begin,
       nvl(to_char(pc.end_date,'dd.mm.yyyy'),'null') date_end,
       to_char(nvl(pc.ins_amount,0)) insurance_sum,
       to_char(nvl(pc.fee,0)) fee,
       pl.description cover_type_name
      ,'null'         as annual
      ,'null'         as loan
      ,'null'         as net_premium_act
      ,'null'         as delta_deposit1
      ,'null'         as penalty
      ,'null'         as payment_sign
  from ins.p_cover pc, ins.as_asset a, ins_dwh.cbnt_policy_tmp pp, ins.t_prod_line_option plo, ins.t_product_line pl
      ,ins.p_pol_header ph--, ins.t_product tp
 where pc.as_asset_id = a.as_asset_id
   and a.p_policy_id = pp.POLICY_ID
   and plo.product_line_id = pl.id
   and pc.t_prod_line_option_id = plo.id
   -- Байтин А. Выбираем все, кроме "Инвестора"
   and pp.policy_header_id = ph.policy_header_id
--   and ph.product_id       = tp.product_id
   --and tp.brief not in ('Investor','INVESTOR_LUMP','INVESTOR_LUMP_OLD','InvestorALFA')
   and pp.product_brief not in ('Investor','INVESTOR_LUMP','INVESTOR_LUMP_OLD','InvestorALFA','Invest_in_future')
-- Для продукта "Инвестор", исключаем административные издержки, а также генерим по три дополнительные строчки для каждого риска
union all
select nvl(to_char(pc.p_cover_id),'null') p_cover_id,
       nvl(to_char(pp.POLICY_ID),'null') policy_id,
       nvl(to_char(pc.start_date,'dd.mm.yyyy'),'null') date_begin,
       nvl(to_char(pc.end_date,'dd.mm.yyyy'),'null') date_end,
       to_char(nvl(pc.ins_amount,0)) insurance_sum,
       to_char(nvl(pc.fee,0)) fee,
       pl.description cover_type_name
      ,to_char(an.annual)         as annual
      ,'null'                     as loan

      ,to_char(
      CASE WHEN pp.payment_term = 'Единовременно' THEN
           (CASE WHEN MONTHS_BETWEEN(pc.end_date + 1/3600, pc.start_date) / 12 = 3 THEN
                 (case plo.brief
                     when 'PEPR_B' then 0.9387
                     when 'PEPR_A' then 0.9387
                     when 'PEPR_A_PLUS' then 0.9387
                     else 1
                  end)
                 WHEN MONTHS_BETWEEN(pc.end_date + 1/3600, pc.start_date) / 12 = 5 THEN
                 (case plo.brief
                     when 'PEPR_B' then 0.9357
                     when 'PEPR_A' then 0.9357
                     when 'PEPR_A_PLUS' then 0.9357
                     else 1
                  end)
                 ELSE 1
           END)
           ELSE
             (case plo.brief
                 when 'PEPR_C' then 0.95
                 when 'PEPR_B' then 0.93
                 when 'PEPR_A' then 0.9
                 else 1
              end)
      END * nvl(pc.fee,0)
              )     as net_premium_act
      ,'null'                     as delta_deposit1
      ,'null'                     as penalty
      ,case (select cp.epg_status_brief
               from ins_dwh.cbnt_payment_tmp cp
              where cp.pol_header_id = ph.policy_header_id
                and cp.payment_num   = an.annual
            )
         when 'PAID' then
           '1'
         else '0'
       end as payment_sign
  from ins.p_cover pc
      ,ins.as_asset a
      ,ins_dwh.cbnt_policy_tmp pp
      ,ins.t_prod_line_option plo
      ,ins.t_product_line     pl
      ,ins.p_pol_header       ph--, ins.t_product tp
      ,(select level as annual
          from dual
         connect by level <= 3
       ) an
 where pc.as_asset_id           = a.as_asset_id
   and a.p_policy_id            = to_number(pp.policy_id)
   and plo.product_line_id      = pl.id
   and pc.t_prod_line_option_id = plo.id
   and ph.policy_header_id      = to_number(pp.policy_header_id)
--   and ph.product_id            = tp.product_id
   --and tp.brief in ('Investor','INVESTOR_LUMP','INVESTOR_LUMP_OLD','InvestorALFA')
   and pp.product_brief in ('Investor','INVESTOR_LUMP','INVESTOR_LUMP_OLD','InvestorALFA','Invest_in_future')
   and pl.description          != 'Административные издержки'
   and not exists (select null
                     from ins.p_pol_change poc
                    where poc.p_cover_id = pc.p_cover_id
                  )
union all
select nvl(to_char(pc.p_cover_id),'null') p_cover_id,
       nvl(to_char(pt.POLICY_ID),'null') policy_id,
       nvl(to_char(pc.start_date,'dd.mm.yyyy'),'null') date_begin,
       nvl(to_char(pc.end_date,'dd.mm.yyyy'),'null') date_end,
       to_char(nvl(pc.ins_amount,0)) insurance_sum,
       to_char(nvl(pc.fee,0)) fee,
       pl.description cover_type_name
      ,to_char(poc.par_t)     as annual
      ,to_char(poc.acc_net_prem_after_change)    as loan
      ,to_char(poc.net_premium_act)              as net_premium_act
      ,to_char(poc.delta_deposit1)               as delta_deposit1
      ,to_char(poc.penalty)                      as penalty
      ,case (select cp.epg_status_brief
               from ins_dwh.cbnt_payment_tmp cp
              where cp.pol_header_id = ph.policy_header_id
                and cp.payment_num   = poc.par_t
            )
         when 'PAID' then
           '1'
         else '0'
       end as payment_sign
  from ins_dwh.cbnt_policy_tmp pt
      ,ins.p_pol_header        ph
      ,ins.as_asset            se
      ,ins.p_cover             pc
      ,ins.t_prod_line_option  plo
      ,ins.t_product_line      pl
--      ,ins.t_product           tp
      ,ins.p_pol_change        poc
 where ph.policy_header_id      = to_number(pt.policy_header_id)
   and se.p_policy_id           = to_number(pt.policy_id)
   and se.as_asset_id           = pc.as_asset_id
   and pc.p_cover_id            = poc.p_cover_id
   and pc.t_prod_line_option_id = plo.id
   and plo.product_line_id      = pl.id
   --and ph.product_id            = tp.product_id
   --and tp.brief in ('Investor','INVESTOR_LUMP','INVESTOR_LUMP_OLD','InvestorALFA')
   and pt.product_brief in ('Investor','INVESTOR_LUMP','INVESTOR_LUMP_OLD','InvestorALFA','Invest_in_future')
   and pl.description          != 'Административные издержки'
;

