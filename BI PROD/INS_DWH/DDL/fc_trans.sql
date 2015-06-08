create materialized view INS_DWH.FC_TRANS
refresh force on demand
as
select q.*,
       trunc(months_between(least(greatest(q.trans_date,q.pol_header_start_date),q.pol_header_end_date), q.pol_header_start_date) / 12) + 1 insurance_year_number,
       nvl(fc_a.agency_id,-1) agency_id,
       nvl(fc_a.t_sales_channel_id,-1) t_sales_channel_id,
       nvl(fc_a.ag_stat_agent_id,-1) ag_stat_agent_id,
       nvl(fc_a.ag_category_agent_id,-1) ag_category_agent_id,
       sysdate created_date,
       sysdate modified_date
       from (
select
       t.trans_id,
       nvl(dm_dd.date_id,-1) date_id,
       t.trans_date,
       nvl(dm_tt.trans_templ_id,-1) trans_templ_id,
       nvl(dm_dt.num,-1) dt_num,
       nvl(dm_ct.num,-1) ct_num,
       nvl(nvl(cover_info.pol_header_id,damage_info.pol_header_id), -1) pol_header_id,
       nvl(nvl(cover_info.insurer_contact_id,damage_info.insurer_contact_id),-1) insurer_contact_id,
       nvl(nvl(cover_info.assured_contact_id,damage_info.assured_contact_id),-1) assured_contact_id,
       nvl(nvl(cover_info.risk_type_id,damage_info.risk_type_id),-1) risk_type_id,
       nvl(nvl(cover_info.risk_type_gaap_id,damage_info.risk_type_gaap_id),-1) risk_type_gaap_id,
       t.trans_amount rur_amount,
       t.acc_amount   doc_amount,
       fa.brief       doc_fund,
       t.acc_rate rate,
       nvl(cover_info.start_date, damage_info.start_date) p_cover_start_date,
       nvl(cover_info.end_date, damage_info.end_date) p_cover_end_date,
       nvl(cover_info.is_avtoprolongation,damage_info.is_avtoprolongation) is_avtoprolongation,
       nvl(cover_info.fee,damage_info.fee) fee,
       nvl(cover_info.number_of_payments,damage_info.number_of_payments) number_of_payments,
       nvl(cover_info.pt_name,damage_info.pt_name) periodicity_name,
       nvl(cover_info.ag_contract_header_id,damage_info.ag_contract_header_id) ag_contract_header_id,
       nvl(cover_info.pol_header_start_date,damage_info.pol_header_start_date) pol_header_start_date,
       nvl(cover_info.pol_header_end_date,damage_info.pol_header_end_date) pol_header_end_date,
       nvl(damage_info.c_claim_header_id,-1) c_claim_header_id,
       nvl(damage_info.t_damage_code_id,-1) t_damage_code_id,
       nvl(cover_info.p_cover_id, damage_info.p_cover_id) p_cover_id,
       op.document_id,
       nvl(d.num,'неопределено') document_num,
       doc_templ.name document_templ_name,
       case when nvl(cover_info.ph_fund_id,damage_info.ph_fund_id) <> 122 and fa.brief /*это валюта документа по проводке*/ = 'RUR'
            then round(t.acc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, nvl(cover_info.ph_fund_id,damage_info.ph_fund_id), t.trans_date),0,1,
                                                                 ins.acc_new.Get_Rate_By_Id(1, nvl(cover_info.ph_fund_id,damage_info.ph_fund_id), t.trans_date))*100)/100
            else t.acc_amount end policy_amount, -- сумма в валюте ответственности

       case when ((dm_tt.brief in ('СтраховаяПремияОплачена', --правило оплаты
                      'ЗачВзнСтрАг',
                      'ПремияОплаченаПоср',
                      'СтраховаяПремияАвансОпл')
                    and dso.child_doc_templ_brief in ('ПП','ПП_ОБ','ПП_ПС')
                    )
                    or (dm_tt.brief in ('СтраховаяПремияАвансОпл','УдержКВ')
                        and dso.child_doc_templ_brief in ('PAYORDER_SETOFF','ЗачетУ_КВ')
                       )
                   ) then 'оплата'
             when (dm_tt.brief in ('НачПремия', -- проводки по начислению
                    'МСФОПремияНачAPE',
                    'МСФОПремияНач')) then 'начисление'
             else 'другое'
             end trans_super_type,


       t.doc_date trans_doc_date,
       t.reg_date trans_reg_date
      -- Байтин А.
      ,case
         when ac_dt.brief in ('ПП', 'ПП_ОБ', 'ПП_ПС', 'PAYORDER_SETOFF', 'ЗачетУ_КВ') then
           ac_dt.brief
       end as ac_dt_brief
      ,case
         when ac_dt.brief in ('ПП', 'ПП_ОБ', 'ПП_ПС', 'PAYORDER_SETOFF', 'ЗачетУ_КВ') then
           trunc(acp.due_date)
       end as trans_doc_date_2
  from -- Байтин А.
       -- Добавил VEN_AC_PAYMENT+DOC_TEMPL, чтобы получить tans_doc_date2 и dt_brief
       ins.ven_ac_payment acp
      ,ins.doc_templ      ac_dt
       --
      ,ins.trans t,
       ins.oper op,
       ins.ven_document d,
       ins.doc_templ doc_templ,
       dm_date dm_dd,
       dm_trans_templ dm_tt,
       dm_account dm_dt,
       dm_account dm_ct,
       ins.account dt,
       ins.account ct,
       (select dso.ent_id, dso.doc_set_off_id, dt1.brief child_doc_templ_brief, dso.child_doc_id
 from ins.ven_doc_set_off dso, ins.document d1, ins.doc_templ dt1
where dso.child_doc_id = d1.document_id
and d1.doc_templ_id = dt1.doc_templ_id) dso,
       ins.fund ft,
       ins.fund fa,
       (select p.pol_header_id,
               pc.p_cover_id,
               pc.start_date,
               pc.end_date,
               pt.number_of_payments,
               pt.description pt_name,
               pc.fee fee,
               pc.premium year_premium,
               pt.description pt_desc,
               ig.life_property is_life_rsbu,
               ll.description ll_desc,
               pr.description prod_desc,
               pc.ent_id,
               aa.assured_contact_id,
               insurers.contact_id insurer_contact_id,
               pc.t_prod_line_option_id risk_type_id,
               pc.is_avtoprolongation is_avtoprolongation,
               ph.start_date pol_header_start_date,
               p.end_date pol_header_end_date,
               ph.fund_id ph_fund_id,
               -- ВНИМАНИЕ используется российская классификация !!!
               (case
                 when months_between(p.end_date + 1, ph.start_date) > 12 then
                  case
                 when ig.life_property = 1 then
                  2
                 when ig.life_property = 0 then
                  4
                 else
                  -1
               end else case
                  when ig.life_property = 1 then
                   1
                  when ig.life_property = 0 then
                   3
                  else
                   -1
                end end) risk_type_gaap_id,
                pol_agent.ag_contract_header_id

                  from ins.ven_p_cover pc,
                       ins.as_asset a,
                       ins.as_assured aa,
                       ins.ven_p_policy p,
                       ins.ven_p_pol_header ph,
                       ins.t_prod_line_option plo,
                       ins.t_product_line pl,
                       ins.t_product_ver_lob pvl,
                       ins.t_product_version pv,
                       ins.t_product pr,
                       ins.t_lob_line ll,
                       ins.t_insurance_group ig,
                       ins.t_payment_terms pt,
                       (select pc1.policy_id, pc1.contact_id
                          from ins.p_policy_contact pc1
                         where pc1.contact_policy_role_id = 6) insurers,
                       (select pol_agent1.ag_contract_header_id,
                               pol_agent1.policy_header_id
                                  from (select pa.*,
                                               row_number() over(partition by pa.policy_header_id order by pa.ag_contract_header_id) rn
                                          from ins.p_policy_agent      pa,
                                               ins.policy_agent_status pas
                                         where pa.status_id = pas.policy_agent_status_id
                                           and pas.brief = 'CURRENT') pol_agent1
                                 where pol_agent1.rn = 1) pol_agent,
                       ins.gaap_pl_types gt
                 where pc.as_asset_id = a.as_asset_id
                   and a.p_policy_id = p.policy_id
                   and p.pol_header_id = ph.policy_header_id
                   and pc.t_prod_line_option_id = plo.id
                   and plo.product_line_id = pl.id
                   and pl.t_lob_line_id = ll.t_lob_line_id
                   and ll.insurance_group_id = ig.t_insurance_group_id
                   and pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                   and pv.t_product_version_id = pvl.product_version_id
                   and pv.product_id = pr.product_id
                   and p.payment_term_id = pt.id
                   and insurers.policy_id = p.policy_id
                   and a.as_asset_id = aa.as_assured_id
                   and pl.id = gt.id(+)
                   and ph.policy_header_id = pol_agent.policy_header_id(+)
        ) cover_info,
        (select
               p.pol_header_id,
               pc.p_cover_id,
               pc.start_date,
               pc.end_date,
               pt.number_of_payments,
               pt.description pt_name,
               pc.fee fee,
               pc.premium year_premium,
               pt.description pt_desc,
               ig.life_property is_life_rsbu,
               ll.description ll_desc,
               pr.description prod_desc,
               pc.ent_id,
               aa.assured_contact_id,
               insurers.contact_id insurer_contact_id,
               pc.t_prod_line_option_id risk_type_id,
               pc.is_avtoprolongation is_avtoprolongation,
               ph.start_date pol_header_start_date,
               p.end_date pol_header_end_date,
               ph.fund_id ph_fund_id,
               -- ВНИМАНИЕ используется российская классификация !!!
               (case
                 when months_between(p.end_date + 1, ph.start_date) > 12 then
                  case
                 when ig.life_property = 1 then
                  2
                 when ig.life_property = 0 then
                  4
                 else
                  -1
               end else case
                  when ig.life_property = 1 then
                   1
                  when ig.life_property = 0 then
                   3
                  else
                   -1
                end end) risk_type_gaap_id,
                pol_agent.ag_contract_header_id,
                cc.c_claim_header_id,
                cd.t_damage_code_id,
                cd.c_damage_id,
                cd.ent_id cd_ent_id

                  from ins.ven_p_cover pc,
                       ins.as_asset a,
                       ins.as_assured aa,
                       ins.ven_p_policy p,
                       ins.ven_p_pol_header ph,
                       ins.t_prod_line_option plo,
                       ins.t_product_line pl,
                       ins.t_product_ver_lob pvl,
                       ins.t_product_version pv,
                       ins.t_product pr,
                       ins.t_lob_line ll,
                       ins.t_insurance_group ig,
                       ins.t_payment_terms pt,

                       (select pc1.policy_id, pc1.contact_id
                          from ins.p_policy_contact pc1
                         where pc1.contact_policy_role_id = 6) insurers,
                       (select pol_agent1.ag_contract_header_id,
                               pol_agent1.policy_header_id
                                  from (select pa.*,
                                               row_number() over(partition by pa.policy_header_id order by pa.ag_contract_header_id) rn
                                          from ins.p_policy_agent      pa,
                                               ins.policy_agent_status pas
                                         where pa.status_id = pas.policy_agent_status_id
                                           and pas.brief = 'CURRENT') pol_agent1
                                 where pol_agent1.rn = 1) pol_agent,
                       ins.gaap_pl_types gt,
                       ins.c_damage cd,
                       ins.c_claim cc
                 where pc.as_asset_id = a.as_asset_id
                   and a.p_policy_id = p.policy_id
                   and p.pol_header_id = ph.policy_header_id
                   and pc.t_prod_line_option_id = plo.id
                   and plo.product_line_id = pl.id
                   and pl.t_lob_line_id = ll.t_lob_line_id
                   and ll.insurance_group_id = ig.t_insurance_group_id
                   and pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                   and pv.t_product_version_id = pvl.product_version_id
                   and pv.product_id = pr.product_id
                   and p.payment_term_id = pt.id
                   and insurers.policy_id = p.policy_id
                   and a.as_asset_id = aa.as_assured_id
                   and pl.id = gt.id(+)
                   and ph.policy_header_id = pol_agent.policy_header_id(+)
                   and cd.p_cover_id = pc.p_cover_id
                   and cd.c_claim_id = cc.c_claim_id
        ) damage_info
 where dm_tt.trans_templ_id (+) = t.trans_templ_id
   and t.oper_id = op.oper_id
   and op.document_id = d.document_id
   and d.doc_templ_id = doc_templ.doc_templ_id
   and dt.account_id = t.dt_account_id
   and ct.account_id = t.ct_account_id
   and ft.fund_id (+)= t.trans_fund_id
   and fa.fund_id (+)= t.acc_fund_id
   and t.obj_uro_id = cover_info.p_cover_id (+)
   and t.obj_ure_id = cover_info.ent_id (+)
   and t.obj_uro_id = damage_info.c_damage_id (+)
   and t.obj_ure_id = damage_info.cd_ent_id (+)
-- Байтин А.
--   and dm_dd.date_id (+)= to_number(to_char(trunc(t.trans_date,'DD'), 'yyyymmdd'))
   and dm_dd.date_id (+)= to_number(to_char(t.trans_date, 'yyyymmdd'))
   and dm_ct.num (+)= ct.num
   and dm_dt.num (+)= dt.num
   and d.document_id = dso.doc_set_off_id (+)
   -- Байтин А.
   and dso.child_doc_id = acp.payment_id (+)
   and acp.doc_templ_id = ac_dt.doc_templ_id (+)
) q,
 fc_agent fc_a
where
    q.date_id = fc_a.date_id (+)
and q.ag_contract_header_id = fc_a.ag_contract_header_id (+);

